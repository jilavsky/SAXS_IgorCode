#pragma TextEncoding = "UTF-8"
#pragma rtGlobals = 3
#pragma DefaultTab = {3, 20, 4}
#pragma IgorVersion = 9.04
#pragma version = 1.04

// IR3_HDF5Browser.ipf
//
// Custom HDF5 browser for the Irena suite. Two-pane Data-Browser-style
// window showing a collapsible tree of two independently opened HDF5 files
// with a value-display widget below for the selected node.
//
// Phase 1 scope: open via dialog, tree display (groups + datasets),
// expand/collapse, value display for scalars/strings and 1D/2D arrays,
// attribute listing.
//
// Phase 2 (future): copy buttons + right-click context menu transfers
// between panes and into Igor.
// Phase 3 (future): HDF5 -> Igor full load and Igor -> HDF5 write-back.
//
// Version history
// 1.04 (2026-05-13) - Phase 5: Drag-and-drop between tree panes (and within
//                     the same pane). Cross-pane drag = COPY; same-pane drag
//                     = MOVE (copy + delete source). Movement threshold of
//                     4 px distinguishes drag from click. Drop into own
//                     descendant is refused. Visual ghost is a TitleBox
//                     following the mouse, per the Wavemetrics drag-drop
//                     pattern (also used in IN3_SamplePlate.ipf).
// 1.03 (2026-05-12) - Phase 4: HDF5 attribute preservation across all copy
//                     directions. Dataset attrs <-> Igor wave notes. Group
//                     attrs <-> sidecar wave Igor___folder_attributes inside
//                     the folder (compatible with CanSAS HDF5gateway). Free-
//                     text wave notes save as single IgorWaveNote attr.
//                     Recursive: HDF5<->HDF5 walks the whole subtree;
//                     HDF5<->Igor likewise. Multi-value attrs encoded as
//                     [v1,v2,v3]. Attribute pane shows wave note / folder
//                     sidecar contents when an Igor item is selected.
// 1.02 (2026-05-12) - Phase 2: Copy buttons (Copy ->, <- Copy) in middle column
//                     for transfer between panes; right-click context menu on
//                     tree rows: copy to other pane, copy to current Igor
//                     data folder, show metadata dialog, plot 1D wave. Copy
//                     supports all four directions (HDF5<->HDF5, HDF5<->Igor,
//                     Igor<->Igor) with recursive group/folder copy and
//                     silent overwrite on name collision. Trees narrowed
//                     to 270 px to make room for the middle column.
// 1.01 (2026-05-12) - added "Igor" source button per pane: each pane can browse
//                     either an HDF5 file or the current Igor experiment
//                     (root: data folder, walking sub-folders / waves /
//                     variables / strings).
// 1.00 (2026-05-12) - initial Phase 1: two-pane browser, collapsible tree,
//                     value display widget for scalars/strings and 1D/2D
//                     numeric/text datasets, attribute listing.

Constant IR3HB_PanelVersion = 1.04
Constant IR3HB_PreviewMaxRows = 50
Constant IR3HB_PreviewMaxCols = 10
StrConstant IR3HB_PkgPath = "root:Packages:Irena:HDF5Browser"
StrConstant IR3HB_PanelName = "IR3HB_BrowserPanel"

// Attribute-preservation conventions
StrConstant IR3HB_FolderSidecarName = "Igor___folder_attributes"   // matches CanSAS HDF5gateway
StrConstant IR3HB_WaveNoteAttrName  = "IgorWaveNote"               // fallback attr for free-text notes
StrConstant IR3HB_AttrTempFolder    = "root:Packages:Irena:HDF5Browser:attrTemp"

//============================================================================
// PUBLIC ENTRY POINT
//============================================================================

Function IR3HB_HDF5Browser()
	DoWindow $IR3HB_PanelName
	if (V_Flag)
		if (!IR1_CheckPanelVersionNumber(IR3HB_PanelName, IR3HB_PanelVersion))
			DoAlert /T="HDF5 Browser version mismatch" 1, "Panel was created by a different version. Restart now?"
			if (V_Flag == 1)
				KillWindow /Z $IR3HB_PanelName
			else
				DoWindow /F $IR3HB_PanelName
				return 0
			endif
		else
			DoWindow /F $IR3HB_PanelName
			return 0
		endif
	endif
	IR3HB_InitPackage()
	IR3HB_PanelFnct()
	IR1_UpdatePanelVersionNumber(IR3HB_PanelName, IR3HB_PanelVersion, 1)
End

//============================================================================
// PACKAGE INITIALIZATION
//============================================================================

Function IR3HB_InitPackage()
	DFREF saveDF = GetDataFolderDFR()
	NewDataFolder /O root:Packages
	NewDataFolder /O root:Packages:Irena
	NewDataFolder /O root:Packages:Irena:HDF5Browser
	IR3HB_InitSide("Left")
	IR3HB_InitSide("Right")
	// Shared selection / display state
	SetDataFolder $IR3HB_PkgPath
	string /G LastClickedSide = ""
	string /G SelectedPath    = ""
	string /G SelectedKind    = ""
	string /G SelectedDType   = ""
	string /G SelectedShape   = ""
	string /G ScalarValueStr  = ""
	// Shared preview / attribute waves used by both panes
	Make /O /T /N=(0, 1) PreviewListWave
	Make /O /N=(0, 1) PreviewSelWave
	Make /O /T /N=(0, 2) AttrListWave
	Make /O /N=(0, 1) AttrSelWave
	SetDataFolder saveDF
End

static Function IR3HB_InitSide(side)
	string side
	DFREF saveDF = GetDataFolderDFR()
	string sidePath = IR3HB_SidePath(side)
	NewDataFolder /O $sidePath
	NewDataFolder /O $(sidePath + ":Preview")
	SetDataFolder $sidePath
	// File state
	string /G FilePath = ""
	string /G FileName = ""
	string /G SourceType = ""    // "" = empty, "HDF5" = HDF5 file open, "Igor" = browsing root:
	variable /G FileID = -1
	variable /G IsReadOnly = 0             // 1 if HDF5 file was opened read-only (write ops will fail)
	variable /G SelectedFullTreeIdx = -1   // index into FullTreeText/Meta of currently-selected row, or -1
	// FullTree text wave (rows = nodes; cols = path, name, kind)
	Make /O /T /N=(0, 3) FullTreeText
	// FullTree numeric metadata (rows = nodes; cols = depth, parentRow, hasChildren)
	Make /O /N=(0, 3) FullTreeMeta
	// Expanded state, parallel to FullTree (1 = expanded, 0 = collapsed)
	Make /O /N=0 ExpandedState
	// Visible row indices into FullTree
	Make /O /N=0 VisibleRows
	// ListWave fed to the tree ListBox: col 0 = marker, col 1 = indented name
	Make /O /T /N=(0, 2) TreeListWave
	// SelWave for the tree ListBox (rows x 1)
	Make /O /N=(0, 1) TreeSelWave
	SetDataFolder saveDF
End

//============================================================================
// PANEL BUILD
//============================================================================

Function IR3HB_PanelFnct()
	PauseUpdate
	variable yPos = 0
	variable panelW = 640
	variable panelH = 790
	NewPanel /K=1 /W=(150, 80, 150 + panelW, 80 + panelH) as "HDF5 Browser"
	DoWindow /C $IR3HB_PanelName

	// Title
	TitleBox MainTitle, title="\Zr200HDF5 Browser", pos={140, 5}, frame=0, fstyle=3, fixedSize=1, font="Times New Roman", size={360, 30}, fColor=(0, 0, 52224)
	TitleBox FakeLine1, title=" ", labelBack=(0, 0, 52224), pos={5, 38}, size={panelW - 10, 3}, frame=0
	Button GetHelp, pos={panelW - 85, 8}, size={80, 15}, fColor=(65535, 32768, 32768), proc=IR3HB_ButtonProc, title="Get Help", help={"Open www manual page for this tool"}
	yPos = 45

	// Section labels for the two panes
	TitleBox LeftPaneLabel,  title="\Zr140Left Pane",  pos={5,   yPos}, size={270, 18}, frame=0, fstyle=1, fColor=(0, 0, 52224), fixedSize=1
	TitleBox RightPaneLabel, title="\Zr140Right Pane", pos={365, yPos}, size={270, 18}, frame=0, fstyle=1, fColor=(0, 0, 52224), fixedSize=1
	yPos += 22

	// Per-pane source controls (Open HDF5 | Show Igor | Close | source name display)
	Button OpenLeft,  pos={5,   yPos}, size={57, 22}, proc=IR3HB_ButtonProc, title="HDF5...",  fColor=(32768, 65535, 49386), help={"Choose an HDF5/NeXus/h5xp file to browse in the left pane"}
	Button IgorLeft,  pos={64,  yPos}, size={49, 22}, proc=IR3HB_ButtonProc, title="Igor",     fColor=(49386, 49386, 65535), help={"Browse the current Igor experiment (root: data folder) in the left pane"}
	Button CloseLeft, pos={115, yPos}, size={35, 22}, proc=IR3HB_ButtonProc, title="Close",    help={"Close the source currently shown in the left pane"}
	SetVariable LeftFileName, pos={152, yPos + 3}, size={123, 18}, title=" ", noedit=1, frame=0, fStyle=2, value=$(IR3HB_SidePath("Left") + ":FileName"), help={"Source currently shown in the left pane"}
	Button OpenRight,  pos={365, yPos}, size={57, 22}, proc=IR3HB_ButtonProc, title="HDF5...",  fColor=(32768, 65535, 49386), help={"Choose an HDF5/NeXus/h5xp file to browse in the right pane"}
	Button IgorRight,  pos={424, yPos}, size={49, 22}, proc=IR3HB_ButtonProc, title="Igor",     fColor=(49386, 49386, 65535), help={"Browse the current Igor experiment (root: data folder) in the right pane"}
	Button CloseRight, pos={475, yPos}, size={35, 22}, proc=IR3HB_ButtonProc, title="Close",    help={"Close the source currently shown in the right pane"}
	SetVariable RightFileName, pos={512, yPos + 3}, size={123, 18}, title=" ", noedit=1, frame=0, fStyle=2, value=$(IR3HB_SidePath("Right") + ":FileName"), help={"Source currently shown in the right pane"}
	yPos += 27

	// Tree ListBoxes side by side, with copy buttons in the middle column
	ListBox LeftTreeListBox, pos={5,   yPos}, size={270, 360}, mode=2, widths={28, 240}, proc=IR3HB_ListBoxProc, frame=2, help={"Click [+]/[-] to expand a group; click a row to select; right-click for context menu"}
	ListBox LeftTreeListBox, listWave=$(IR3HB_SidePath("Left") + ":TreeListWave")
	ListBox LeftTreeListBox, selWave=$(IR3HB_SidePath("Left") + ":TreeSelWave")

	ListBox RightTreeListBox, pos={365, yPos}, size={270, 360}, mode=2, widths={28, 240}, proc=IR3HB_ListBoxProc, frame=2, help={"Click [+]/[-] to expand a group; click a row to select; right-click for context menu"}
	ListBox RightTreeListBox, listWave=$(IR3HB_SidePath("Right") + ":TreeListWave")
	ListBox RightTreeListBox, selWave=$(IR3HB_SidePath("Right") + ":TreeSelWave")

	// Middle-column copy buttons (vertically centered between the two trees)
	Button CopyLR, pos={285, yPos + 150}, size={70, 25}, proc=IR3HB_ButtonProc, title="Copy →", fColor=(32768, 65535, 49386), help={"Copy selected item from LEFT pane into RIGHT pane (at right pane's selected destination)"}
	Button CopyRL, pos={285, yPos + 185}, size={70, 25}, proc=IR3HB_ButtonProc, title="← Copy", fColor=(32768, 65535, 49386), help={"Copy selected item from RIGHT pane into LEFT pane (at left pane's selected destination)"}
	yPos += 365

	// Selected path display (full width)
	SetVariable SelectedPathDisp, pos={5, yPos + 3}, size={panelW - 10, 18}, title="Selected:", noedit=1, frame=0, fStyle=2, valueColor=(0, 0, 52224), value=$(IR3HB_PkgPath + ":SelectedPath"), help={"Full HDF5 path of the most recently clicked node"}
	yPos += 22

	// Info row: Kind, DType, Shape
	SetVariable InfoKind,  pos={5,   yPos + 3}, size={150, 18}, title="Kind:",  noedit=1, frame=0, fStyle=2, value=$(IR3HB_PkgPath + ":SelectedKind"),  help={"G = group, D = dataset"}
	SetVariable InfoDType, pos={170, yPos + 3}, size={200, 18}, title="DType:", noedit=1, frame=0, fStyle=2, value=$(IR3HB_PkgPath + ":SelectedDType"), help={"HDF5 datatype class of the selected dataset"}
	SetVariable InfoShape, pos={385, yPos + 3}, size={250, 18}, title="Shape:", noedit=1, frame=0, fStyle=2, value=$(IR3HB_PkgPath + ":SelectedShape"), help={"Dimensions of the selected dataset"}
	yPos += 22

	// Section labels for preview / attributes
	TitleBox PreviewLabel,    title="\Zr120Value preview (first " + num2str(IR3HB_PreviewMaxRows) + " rows / " + num2str(IR3HB_PreviewMaxCols) + " cols)", pos={5,   yPos}, size={420, 16}, frame=0, fstyle=1, fColor=(0, 0, 52224), fixedSize=1
	TitleBox AttributesLabel, title="\Zr120Attributes", pos={430, yPos}, size={205, 16}, frame=0, fstyle=1, fColor=(0, 0, 52224), fixedSize=1
	yPos += 18

	// Scalar value display (used when selection is a scalar / string)
	SetVariable ScalarValueDisp, pos={5, yPos + 3}, size={420, 18}, title="Value:", noedit=1, frame=0, fStyle=2, valueColor=(0, 32768, 0), value=$(IR3HB_PkgPath + ":ScalarValueStr"), help={"Value of the selected scalar / string dataset"}

	// Preview ListBox for 1D / 2D arrays
	ListBox PreviewListBox, pos={5, yPos + 25}, size={420, 175}, mode=2, frame=2, help={"Preview of the selected dataset (truncated for large arrays)"}
	ListBox PreviewListBox, listWave=$(IR3HB_PkgPath + ":PreviewListWave")
	ListBox PreviewListBox, selWave=$(IR3HB_PkgPath + ":PreviewSelWave")

	// Attribute ListBox (right side)
	ListBox AttrListBox, pos={430, yPos}, size={205, 200}, mode=2, widths={80, 120}, frame=2, help={"Attributes of the selected node (HDF5 attribute name and string value)"}
	ListBox AttrListBox, listWave=$(IR3HB_PkgPath + ":AttrListWave")
	ListBox AttrListBox, selWave=$(IR3HB_PkgPath + ":AttrSelWave")
	yPos += 205

	// Hints
	TitleBox Hint1, title="\Zr100[+] / [-] in left column toggles a group's expand state; left-click selects",                  pos={5, yPos},      size={panelW - 10, 14}, frame=0, fColor=(0, 0, 65535)
	TitleBox Hint2, title="\Zr100Right-click any row for context menu (copy / inspect / plot); destination = selected row",     pos={5, yPos + 14}, size={panelW - 10, 14}, frame=0, fColor=(0, 0, 65535)
	TitleBox Hint3, title="\Zr100On copy: name collisions OVERWRITE silently; group/folder copies are recursive",                pos={5, yPos + 28}, size={panelW - 10, 14}, frame=0, fColor=(32768, 32768, 32768)
	TitleBox Hint4, title="\Zr100Drag-and-drop: same pane = MOVE; between panes = COPY. (≥4 px movement required to distinguish drag from click)",  pos={5, yPos + 42}, size={panelW - 10, 14}, frame=0, fColor=(32768, 32768, 32768)

	// Window hook for clean-up on kill
	SetWindow $IR3HB_PanelName, hook(IR3HB)=IR3HB_WindowHook
End

//============================================================================
// FILE OPEN / CLOSE
//============================================================================

Function IR3HB_OpenFile(side)
	string side
	DFREF saveDF = GetDataFolderDFR()
	DFREF dfr = $IR3HB_SidePath(side)
	NVAR fileID = dfr:FileID
	NVAR isReadOnly = dfr:IsReadOnly
	SVAR filePath = dfr:FilePath
	SVAR fileName = dfr:FileName
	SVAR sourceType = dfr:SourceType
	// If a source is already in use in this pane, close it first
	if (fileID >= 0 || strlen(sourceType) > 0)
		IR3HB_CloseFile(side)
	endif
	// Open file via dialog. Try read-write first (so copy-into can work);
	// if that fails (locked / read-only volume / permissions), retry read-only.
	variable locFileID
	HDF5OpenFile /I locFileID as ""
	variable rwErr = V_Flag
	string rwPath = S_path
	string rwName = S_fileName
	if (rwErr != 0)
		// User may have cancelled, or write access denied. If they cancelled,
		// S_fileName will be empty and we should bail. Otherwise retry /R.
		if (strlen(S_fileName) == 0)
			SetDataFolder saveDF
			return 0
		endif
		HDF5OpenFile /R locFileID as rwPath + rwName
		if (V_Flag != 0)
			Printf "HDF5 Browser: could not open '%s' (V_Flag=%d on RW, %d on RO)\r", rwName, rwErr, V_Flag
			SetDataFolder saveDF
			return 0
		endif
		isReadOnly = 1
		Printf "HDF5 Browser: '%s' opened READ-ONLY (write/copy into this pane will be blocked)\r", S_fileName
	else
		isReadOnly = 0
	endif
	fileID = locFileID
	filePath = S_path
	fileName = S_fileName
	sourceType = "HDF5"
	// Build the tree
	IR3HB_BuildFullTree(side, locFileID)
	// Initial expanded state: root expanded, everything else collapsed
	WAVE expanded = dfr:ExpandedState
	if (numpnts(expanded) > 0)
		expanded = 0
		expanded[0] = 1
	endif
	IR3HB_RebuildVisibleRows(side)
	SetDataFolder saveDF
	return 1
End

Function IR3HB_CloseFile(side)
	string side
	DFREF saveDF = GetDataFolderDFR()
	DFREF dfr = $IR3HB_SidePath(side)
	NVAR fileID = dfr:FileID
	NVAR isReadOnly = dfr:IsReadOnly
	SVAR filePath = dfr:FilePath
	SVAR fileName = dfr:FileName
	SVAR sourceType = dfr:SourceType
	NVAR selectedIdx = dfr:SelectedFullTreeIdx
	if (fileID >= 0)
		HDF5CloseFile /Z fileID
	endif
	fileID = -1
	isReadOnly = 0
	filePath = ""
	fileName = ""
	sourceType = ""
	selectedIdx = -1
	WAVE/T fullTreeText = dfr:FullTreeText
	WAVE   fullTreeMeta = dfr:FullTreeMeta
	WAVE   expanded     = dfr:ExpandedState
	WAVE   visibleRows  = dfr:VisibleRows
	WAVE/T treeListWave = dfr:TreeListWave
	WAVE   treeSelWave  = dfr:TreeSelWave
	Redimension /N=(0, 3) fullTreeText
	Redimension /N=(0, 3) fullTreeMeta
	Redimension /N=0      expanded
	Redimension /N=0      visibleRows
	Redimension /N=(0, 2) treeListWave
	Redimension /N=(0, 1) treeSelWave
	// Clear preview folder for this side
	string previewFolder = IR3HB_SidePath(side) + ":Preview"
	if (DataFolderExists(previewFolder))
		KillDataFolder /Z $previewFolder
		NewDataFolder /O $previewFolder
	endif
	// If the cleared side was the last clicked, clear the shared display too
	SVAR lastSide = $(IR3HB_PkgPath + ":LastClickedSide")
	if (cmpstr(lastSide, side) == 0)
		IR3HB_ClearSharedDisplay()
	endif
	SetDataFolder saveDF
	return 0
End

//============================================================================
// IGOR EXPERIMENT BROWSE
//============================================================================

Function IR3HB_ShowIgor(side)
	string side
	DFREF saveDF = GetDataFolderDFR()
	DFREF dfr = $IR3HB_SidePath(side)
	NVAR fileID = dfr:FileID
	SVAR filePath = dfr:FilePath
	SVAR fileName = dfr:FileName
	SVAR sourceType = dfr:SourceType
	// Drop any prior source
	if (fileID >= 0 || strlen(sourceType) > 0)
		IR3HB_CloseFile(side)
	endif
	sourceType = "Igor"
	filePath   = "root:"
	fileName   = "(current Igor experiment)"
	IR3HB_BuildIgorTree(side, "root:")
	WAVE expanded = dfr:ExpandedState
	if (numpnts(expanded) > 0)
		expanded = 0
		expanded[0] = 1
	endif
	IR3HB_RebuildVisibleRows(side)
	SetDataFolder saveDF
	return 1
End

static Function IR3HB_BuildIgorTree(side, startPath)
	string side, startPath
	DFREF dfr = $IR3HB_SidePath(side)
	WAVE/T fullTreeText = dfr:FullTreeText
	WAVE   fullTreeMeta = dfr:FullTreeMeta
	WAVE   expanded     = dfr:ExpandedState
	Redimension /N=(0, 3) fullTreeText
	Redimension /N=(0, 3) fullTreeMeta
	Redimension /N=0      expanded
	IR3HB_RecursiveListFolder(side, startPath, -1, 0)
End

static Function IR3HB_RecursiveListFolder(side, folderPath, parentRow, depth)
	string side, folderPath
	variable parentRow, depth
	DFREF folderRef = $folderPath
	if (!DataFolderRefStatus(folderRef))
		return 0
	endif
	variable nWaves   = CountObjectsDFR(folderRef, 1)
	variable nVars    = CountObjectsDFR(folderRef, 2)
	variable nStrs    = CountObjectsDFR(folderRef, 3)
	variable nFolders = CountObjectsDFR(folderRef, 4)
	variable hasChildren = (nWaves + nVars + nStrs + nFolders) > 0
	IR3HB_AppendTreeRow(side, folderPath, IR3HB_IgorBaseName(folderPath), "G", depth, parentRow, hasChildren)
	DFREF dfr = $IR3HB_SidePath(side)
	WAVE/T fullTreeText = dfr:FullTreeText
	variable myRow = DimSize(fullTreeText, 0) - 1
	variable i
	string itemName, itemPath
	for (i = 0; i < nWaves; i += 1)
		itemName = GetIndexedObjNameDFR(folderRef, 1, i)
		itemPath = IR3HB_IgorJoinPath(folderPath, itemName)
		IR3HB_AppendTreeRow(side, itemPath, itemName, "D", depth + 1, myRow, 0)
	endfor
	for (i = 0; i < nVars; i += 1)
		itemName = GetIndexedObjNameDFR(folderRef, 2, i)
		itemPath = IR3HB_IgorJoinPath(folderPath, itemName)
		IR3HB_AppendTreeRow(side, itemPath, itemName, "V", depth + 1, myRow, 0)
	endfor
	for (i = 0; i < nStrs; i += 1)
		itemName = GetIndexedObjNameDFR(folderRef, 3, i)
		itemPath = IR3HB_IgorJoinPath(folderPath, itemName)
		IR3HB_AppendTreeRow(side, itemPath, itemName, "S", depth + 1, myRow, 0)
	endfor
	for (i = 0; i < nFolders; i += 1)
		itemName = GetIndexedObjNameDFR(folderRef, 4, i)
		itemPath = IR3HB_IgorJoinPath(folderPath, itemName)
		IR3HB_RecursiveListFolder(side, itemPath, myRow, depth + 1)
	endfor
End

static Function/S IR3HB_IgorBaseName(path)
	string path
	if (CmpStr(path, "root:") == 0)
		return "root:"
	endif
	// Strip trailing colon if present
	variable L = strlen(path)
	if (L > 0 && CmpStr(path[L - 1, L - 1], ":") == 0)
		path = path[0, L - 2]
	endif
	variable n = ItemsInList(path, ":")
	if (n == 0)
		return path
	endif
	return StringFromList(n - 1, path, ":")
End

static Function/S IR3HB_IgorJoinPath(parent, child)
	string parent, child
	if (strlen(parent) == 0)
		return child
	endif
	variable L = strlen(parent)
	if (CmpStr(parent[L - 1, L - 1], ":") == 0)
		return parent + child
	endif
	return parent + ":" + child
End

//============================================================================
// TREE BUILD
//============================================================================

static Function IR3HB_BuildFullTree(side, fileID)
	string side
	variable fileID
	DFREF dfr = $IR3HB_SidePath(side)
	WAVE/T fullTreeText = dfr:FullTreeText
	WAVE   fullTreeMeta = dfr:FullTreeMeta
	WAVE   expanded     = dfr:ExpandedState
	Redimension /N=(0, 3) fullTreeText
	Redimension /N=(0, 3) fullTreeMeta
	Redimension /N=0      expanded
	IR3HB_RecursiveListGroup(side, fileID, "/", -1, 0)
End

static Function IR3HB_RecursiveListGroup(side, fileID, groupPath, parentRow, depth)
	string side
	variable fileID
	string groupPath
	variable parentRow
	variable depth
	// Datasets in this group only
	HDF5ListGroup /TYPE=2 /Z fileID, groupPath
	string datasetList = SelectString(V_Flag == 0, "", S_HDF5ListGroup)
	// Sub-groups in this group only
	HDF5ListGroup /TYPE=1 /Z fileID, groupPath
	string subGroupList = SelectString(V_Flag == 0, "", S_HDF5ListGroup)
	variable nDatasets = ItemsInList(datasetList)
	variable nSubGroups = ItemsInList(subGroupList)
	variable hasChildren = (nDatasets + nSubGroups) > 0
	// Append this group row first
	IR3HB_AppendTreeRow(side, groupPath, IR3HB_GetBaseName(groupPath), "G", depth, parentRow, hasChildren)
	DFREF dfr = $IR3HB_SidePath(side)
	WAVE/T fullTreeText = dfr:FullTreeText
	variable myRow = DimSize(fullTreeText, 0) - 1
	// Append datasets in this group
	variable i
	string dsName, dsPath
	for (i = 0; i < nDatasets; i += 1)
		dsName = StringFromList(i, datasetList)
		dsPath = IR3HB_JoinPath(groupPath, dsName)
		IR3HB_AppendTreeRow(side, dsPath, dsName, "D", depth + 1, myRow, 0)
	endfor
	// Recurse into sub-groups
	string sgName, sgPath
	for (i = 0; i < nSubGroups; i += 1)
		sgName = StringFromList(i, subGroupList)
		sgPath = IR3HB_JoinPath(groupPath, sgName)
		IR3HB_RecursiveListGroup(side, fileID, sgPath, myRow, depth + 1)
	endfor
End

static Function IR3HB_AppendTreeRow(side, fullPath, name, kind, depth, parentRow, hasChildren)
	string side
	string fullPath, name, kind
	variable depth, parentRow, hasChildren
	DFREF dfr = $IR3HB_SidePath(side)
	WAVE/T fullTreeText = dfr:FullTreeText
	WAVE   fullTreeMeta = dfr:FullTreeMeta
	WAVE   expanded     = dfr:ExpandedState
	variable n = DimSize(fullTreeText, 0)
	Redimension /N=(n + 1, 3) fullTreeText
	Redimension /N=(n + 1, 3) fullTreeMeta
	Redimension /N=(n + 1)    expanded
	fullTreeText[n][0] = fullPath
	fullTreeText[n][1] = name
	fullTreeText[n][2] = kind
	fullTreeMeta[n][0] = depth
	fullTreeMeta[n][1] = parentRow
	fullTreeMeta[n][2] = hasChildren
	expanded[n] = 0
End

//============================================================================
// VISIBLE ROW REBUILD
//============================================================================

static Function IR3HB_RebuildVisibleRows(side)
	string side
	DFREF dfr = $IR3HB_SidePath(side)
	WAVE/T fullTreeText = dfr:FullTreeText
	WAVE   fullTreeMeta = dfr:FullTreeMeta
	WAVE   expanded     = dfr:ExpandedState
	WAVE   visibleRows  = dfr:VisibleRows
	WAVE/T treeListWave = dfr:TreeListWave
	WAVE   treeSelWave  = dfr:TreeSelWave
	variable nTotal = DimSize(fullTreeText, 0)
	Redimension /N=(nTotal) visibleRows
	variable nVis = 0
	variable skipDepth = -1
	variable i
	variable rowDepth, rowHasChildren
	string rowKind
	for (i = 0; i < nTotal; i += 1)
		rowDepth = fullTreeMeta[i][0]
		if (skipDepth >= 0)
			if (rowDepth > skipDepth)
				continue
			endif
			skipDepth = -1
		endif
		visibleRows[nVis] = i
		nVis += 1
		rowKind = fullTreeText[i][2]
		rowHasChildren = fullTreeMeta[i][2]
		if (cmpstr(rowKind, "G") == 0 && rowHasChildren && expanded[i] == 0)
			skipDepth = rowDepth
		endif
	endfor
	Redimension /N=(nVis) visibleRows
	Redimension /N=(nVis, 2) treeListWave
	Redimension /N=(nVis, 1) treeSelWave
	treeSelWave = 0
	// Render visible rows into the ListWave
	variable j, idx, d
	string marker, name, indent
	for (j = 0; j < nVis; j += 1)
		idx    = visibleRows[j]
		d      = fullTreeMeta[idx][0]
		name   = fullTreeText[idx][1]
		rowKind = fullTreeText[idx][2]
		rowHasChildren = fullTreeMeta[idx][2]
		if (cmpstr(rowKind, "G") == 0 && rowHasChildren)
			marker = SelectString(expanded[idx], "[+]", "[-]")
		else
			marker = ""
		endif
		indent = IR3HB_RepeatStr("   ", d)
		treeListWave[j][0] = marker
		treeListWave[j][1] = indent + name
	endfor
End

//============================================================================
// EXPAND / COLLAPSE / SELECT
//============================================================================

static Function IR3HB_ToggleExpand(side, fullTreeRow)
	string side
	variable fullTreeRow
	DFREF dfr = $IR3HB_SidePath(side)
	WAVE expanded = dfr:ExpandedState
	if (fullTreeRow < 0 || fullTreeRow >= numpnts(expanded))
		return 0
	endif
	expanded[fullTreeRow] = (expanded[fullTreeRow]) ? 0 : 1
	IR3HB_RebuildVisibleRows(side)
	// After rebuild, restore selection on the toggled row
	WAVE visibleRows = dfr:VisibleRows
	variable i
	for (i = 0; i < numpnts(visibleRows); i += 1)
		if (visibleRows[i] == fullTreeRow)
			IR3HB_SetTreeSelRow(side, i)
			break
		endif
	endfor
	return 0
End

static Function IR3HB_OnSelect(side, visibleRow)
	string side
	variable visibleRow
	DFREF dfr = $IR3HB_SidePath(side)
	WAVE visibleRows = dfr:VisibleRows
	WAVE/T fullTreeText = dfr:FullTreeText
	WAVE   fullTreeMeta = dfr:FullTreeMeta
	NVAR   selectedIdx  = dfr:SelectedFullTreeIdx
	if (visibleRow < 0 || visibleRow >= numpnts(visibleRows))
		selectedIdx = -1
		return 0
	endif
	variable idx = visibleRows[visibleRow]
	selectedIdx = idx
	SVAR lastSide = $(IR3HB_PkgPath + ":LastClickedSide")
	SVAR selPath  = $(IR3HB_PkgPath + ":SelectedPath")
	SVAR selKind  = $(IR3HB_PkgPath + ":SelectedKind")
	lastSide = side
	selPath = fullTreeText[idx][0]
	selKind = fullTreeText[idx][2]
	IR3HB_RefreshValueDisplay()
	return 0
End

static Function IR3HB_SetTreeSelRow(side, visibleRow)
	string side
	variable visibleRow
	string ctrlName = side + "TreeListBox"
	ListBox $ctrlName, win=$IR3HB_PanelName, selRow=visibleRow
End

//============================================================================
// VALUE DISPLAY REFRESH
//============================================================================

static Function IR3HB_RefreshValueDisplay()
	SVAR lastSide = $(IR3HB_PkgPath + ":LastClickedSide")
	SVAR selPath  = $(IR3HB_PkgPath + ":SelectedPath")
	SVAR selKind  = $(IR3HB_PkgPath + ":SelectedKind")
	SVAR selDType = $(IR3HB_PkgPath + ":SelectedDType")
	SVAR selShape = $(IR3HB_PkgPath + ":SelectedShape")
	SVAR scalarStr = $(IR3HB_PkgPath + ":ScalarValueStr")
	WAVE/T previewListWave = $(IR3HB_PkgPath + ":PreviewListWave")
	WAVE   previewSelWave  = $(IR3HB_PkgPath + ":PreviewSelWave")
	// Reset display fields
	selDType = ""
	selShape = ""
	scalarStr = ""
	Redimension /N=(0, 1) previewListWave
	Redimension /N=(0, 1) previewSelWave
	if (strlen(lastSide) == 0 || strlen(selPath) == 0)
		IR3HB_RefreshAttributes("", "", "")
		return 0
	endif
	DFREF dfr = $IR3HB_SidePath(lastSide)
	SVAR sourceType = dfr:SourceType
	// Igor experiment branch
	if (cmpstr(sourceType, "Igor") == 0)
		IR3HB_RefreshIgorDisplay(lastSide, selPath, selKind)
		return 0
	endif
	// HDF5 branch
	NVAR fileID = dfr:FileID
	if (fileID < 0)
		IR3HB_RefreshAttributes("", "", "")
		return 0
	endif
	if (cmpstr(selKind, "G") == 0)
		selDType = "(group)"
		selShape = ""
		IR3HB_RefreshAttributes(lastSide, selPath, "G")
		return 0
	endif
	// Dataset: query metadata
	STRUCT HDF5DataInfo di
	InitHDF5DataInfo(di)
	variable err = HDF5DatasetInfo(fileID, selPath, 1, di)
	if (err != 0)
		selDType = "(info unavailable)"
		IR3HB_RefreshAttributes(lastSide, selPath, "D")
		return 0
	endif
	selDType = IR3HB_DataTypeClassToString(di.datatype_class) + " (" + num2str(di.datatype_size) + " B)"
	selShape = IR3HB_FormatShape(di)
	// Decide what to do based on rank / size
	if (di.ndims <= 2)
		IR3HB_LoadAndDisplayPreview(lastSide, selPath, di)
	else
		scalarStr = "(rank " + num2str(di.ndims) + " not previewed)"
	endif
	IR3HB_RefreshAttributes(lastSide, selPath, "D")
	return 0
End

static Function IR3HB_RefreshIgorDisplay(side, igorPath, kind)
	string side, igorPath, kind
	SVAR selDType  = $(IR3HB_PkgPath + ":SelectedDType")
	SVAR selShape  = $(IR3HB_PkgPath + ":SelectedShape")
	SVAR scalarStr = $(IR3HB_PkgPath + ":ScalarValueStr")
	// Populate attribute pane from Igor wave note / folder sidecar (replaces HDF5 attr list)
	IR3HB_FillAttrListFromIgor(igorPath, kind)
	if (cmpstr(kind, "G") == 0)
		// Data folder
		selDType = "(folder)"
		selShape = ""
		DFREF folderRef = $igorPath
		if (DataFolderRefStatus(folderRef))
			variable nW = CountObjectsDFR(folderRef, 1)
			variable nV = CountObjectsDFR(folderRef, 2)
			variable nS = CountObjectsDFR(folderRef, 3)
			variable nF = CountObjectsDFR(folderRef, 4)
			scalarStr = num2str(nW) + " waves, " + num2str(nV) + " vars, " + num2str(nS) + " strs, " + num2str(nF) + " subfolders"
		else
			scalarStr = "(folder not found)"
		endif
		return 0
	endif
	if (cmpstr(kind, "V") == 0)
		// Numeric variable
		NVAR /Z var = $igorPath
		selDType = "variable"
		selShape = "scalar"
		if (NVAR_Exists(var))
			scalarStr = num2str(var)
		else
			scalarStr = "(variable not found)"
		endif
		return 0
	endif
	if (cmpstr(kind, "S") == 0)
		// String variable
		SVAR /Z str = $igorPath
		selDType = "string"
		if (SVAR_Exists(str))
			scalarStr = str
			selShape = "scalar (" + num2str(strlen(str)) + " chars)"
		else
			scalarStr = "(string not found)"
			selShape = "scalar"
		endif
		return 0
	endif
	// Wave (kind == "D")
	WAVE /Z wv = $igorPath
	if (!WaveExists(wv))
		selDType = "(wave not found)"
		selShape = ""
		return 0
	endif
	selDType = IR3HB_WaveTypeToString(wv)
	selShape = IR3HB_FormatWaveShape(wv)
	IR3HB_DispatchWavePreview(wv)
	return 0
End

static Function/S IR3HB_WaveTypeToString(wv)
	WAVE wv
	variable wt = WaveType(wv)
	if (wt == 0)
		return "text"
	endif
	string base = ""
	if (wt & 0x02)
		base = "float32"
	elseif (wt & 0x04)
		base = "float64"
	elseif (wt & 0x08)
		base = "int8"
	elseif (wt & 0x10)
		base = "int16"
	elseif (wt & 0x20)
		base = "int32"
	elseif (wt & 0x80)
		base = "int64"
	else
		base = "type " + num2str(wt)
	endif
	if (wt & 0x40)
		base = "u" + base
	endif
	if (wt & 0x01)
		base = "complex " + base
	endif
	return base
End

static Function/S IR3HB_FormatWaveShape(wv)
	WAVE wv
	variable d0 = DimSize(wv, 0)
	variable d1 = DimSize(wv, 1)
	variable d2 = DimSize(wv, 2)
	variable d3 = DimSize(wv, 3)
	if (d0 == 0)
		return "empty"
	endif
	string result = num2str(d0)
	if (d1 > 0)
		result += " x " + num2str(d1)
	endif
	if (d2 > 0)
		result += " x " + num2str(d2)
	endif
	if (d3 > 0)
		result += " x " + num2str(d3)
	endif
	return result
End

static Function IR3HB_LoadAndDisplayPreview(side, hdfPath, di)
	string side
	string hdfPath
	STRUCT HDF5DataInfo &di
	DFREF saveDF = GetDataFolderDFR()
	DFREF dfr = $IR3HB_SidePath(side)
	NVAR fileID = dfr:FileID
	string previewFolder = IR3HB_SidePath(side) + ":Preview"
	// Clear previous preview waves
	if (DataFolderExists(previewFolder))
		KillDataFolder /Z $previewFolder
	endif
	NewDataFolder /O $previewFolder
	SetDataFolder $previewFolder
	HDF5LoadData /Z /O /N=hdf5_preview /TYPE=2 fileID, hdfPath
	variable loadErr = V_Flag
	SetDataFolder saveDF
	SVAR scalarStr = $(IR3HB_PkgPath + ":ScalarValueStr")
	WAVE/T previewListWave = $(IR3HB_PkgPath + ":PreviewListWave")
	if (loadErr != 0)
		scalarStr = "(preview unavailable for this datatype)"
		return 0
	endif
	// Find the loaded wave (HDF5LoadData typically creates "hdf5_preview" but compound
	// data may produce other names; we look for the first wave in the preview folder)
	string loadedList = IR3HB_FirstWaveInFolder(previewFolder)
	if (strlen(loadedList) == 0)
		scalarStr = "(no preview data)"
		return 0
	endif
	string fullName = previewFolder + ":" + loadedList
	WAVE/Z previewWv = $fullName
	if (!WaveExists(previewWv))
		scalarStr = "(unsupported preview type)"
		return 0
	endif
	IR3HB_DispatchWavePreview(previewWv)
	return 0
End

static Function IR3HB_DispatchWavePreview(wv)
	WAVE wv
	SVAR scalarStr = $(IR3HB_PkgPath + ":ScalarValueStr")
	WAVE/T previewListWave = $(IR3HB_PkgPath + ":PreviewListWave")
	WAVE   previewSelWave  = $(IR3HB_PkgPath + ":PreviewSelWave")
	variable n = numpnts(wv)
	if (n == 0)
		scalarStr = "(empty wave)"
		Redimension /N=(0, 1) previewListWave
		Redimension /N=(0, 1) previewSelWave
		return 0
	endif
	variable rank = WaveDims(wv)
	if (rank > 2)
		scalarStr = "(rank " + num2str(rank) + " not previewed)"
		Redimension /N=(0, 1) previewListWave
		Redimension /N=(0, 1) previewSelWave
		return 0
	endif
	if (WaveType(wv) == 0)
		WAVE/T txt = wv
		IR3HB_PopulateTextPreview(txt)
	else
		IR3HB_PopulateNumericPreview(wv)
	endif
End

static Function IR3HB_PopulateNumericPreview(wv)
	WAVE wv
	SVAR scalarStr = $(IR3HB_PkgPath + ":ScalarValueStr")
	WAVE/T previewListWave = $(IR3HB_PkgPath + ":PreviewListWave")
	WAVE   previewSelWave  = $(IR3HB_PkgPath + ":PreviewSelWave")
	variable n = numpnts(wv)
	if (n == 1)
		// Scalar
		scalarStr = num2str(wv[0])
		Redimension /N=(0, 1) previewListWave
		Redimension /N=(0, 1) previewSelWave
		return 0
	endif
	variable rows = DimSize(wv, 0)
	variable cols = DimSize(wv, 1)
	if (cols == 0)
		// 1D wave
		variable showRows = min(rows, IR3HB_PreviewMaxRows)
		Redimension /N=(showRows, 2) previewListWave
		Redimension /N=(showRows, 1) previewSelWave
		previewSelWave = 0
		variable i
		for (i = 0; i < showRows; i += 1)
			previewListWave[i][0] = num2str(i)
			previewListWave[i][1] = num2str(wv[i])
		endfor
		scalarStr = "(showing " + num2str(showRows) + " of " + num2str(rows) + " points)"
		return 0
	endif
	// 2D wave
	variable showR = min(rows, IR3HB_PreviewMaxRows)
	variable showC = min(cols, IR3HB_PreviewMaxCols)
	Redimension /N=(showR, showC + 1) previewListWave
	Redimension /N=(showR, 1) previewSelWave
	previewSelWave = 0
	variable r, c
	for (r = 0; r < showR; r += 1)
		previewListWave[r][0] = "[" + num2str(r) + "]"
		for (c = 0; c < showC; c += 1)
			previewListWave[r][c + 1] = num2str(wv[r][c])
		endfor
	endfor
	scalarStr = "(showing " + num2str(showR) + "x" + num2str(showC) + " of " + num2str(rows) + "x" + num2str(cols) + ")"
	return 0
End

static Function IR3HB_PopulateTextPreview(wv)
	WAVE/T wv
	SVAR scalarStr = $(IR3HB_PkgPath + ":ScalarValueStr")
	WAVE/T previewListWave = $(IR3HB_PkgPath + ":PreviewListWave")
	WAVE   previewSelWave  = $(IR3HB_PkgPath + ":PreviewSelWave")
	variable n = numpnts(wv)
	if (n == 1)
		scalarStr = wv[0]
		Redimension /N=(0, 1) previewListWave
		Redimension /N=(0, 1) previewSelWave
		return 0
	endif
	variable rows = DimSize(wv, 0)
	variable cols = DimSize(wv, 1)
	if (cols == 0)
		variable showRows = min(rows, IR3HB_PreviewMaxRows)
		Redimension /N=(showRows, 2) previewListWave
		Redimension /N=(showRows, 1) previewSelWave
		previewSelWave = 0
		variable i
		for (i = 0; i < showRows; i += 1)
			previewListWave[i][0] = num2str(i)
			previewListWave[i][1] = wv[i]
		endfor
		scalarStr = "(showing " + num2str(showRows) + " of " + num2str(rows) + " strings)"
		return 0
	endif
	scalarStr = "(2D text preview not implemented)"
	return 0
End

//============================================================================
// ATTRIBUTES
//============================================================================

static Function IR3HB_RefreshAttributes(side, hdfPath, kind)
	string side, hdfPath, kind
	WAVE/T attrListWave = $(IR3HB_PkgPath + ":AttrListWave")
	WAVE   attrSelWave  = $(IR3HB_PkgPath + ":AttrSelWave")
	Redimension /N=(0, 2) attrListWave
	Redimension /N=(0, 1) attrSelWave
	if (strlen(side) == 0 || strlen(hdfPath) == 0)
		return 0
	endif
	DFREF dfr = $IR3HB_SidePath(side)
	NVAR fileID = dfr:FileID
	if (fileID < 0)
		return 0
	endif
	variable typeFlag = (cmpstr(kind, "G") == 0) ? 1 : 2
	HDF5ListAttributes /TYPE=(typeFlag) /Z fileID, hdfPath
	if (V_Flag != 0)
		return 0
	endif
	string attrList = S_HDF5ListAttributes
	variable nAttrs = ItemsInList(attrList)
	if (nAttrs == 0)
		return 0
	endif
	Redimension /N=(nAttrs, 2) attrListWave
	Redimension /N=(nAttrs, 1) attrSelWave
	attrSelWave = 0
	variable i
	string attrName
	for (i = 0; i < nAttrs; i += 1)
		attrName = StringFromList(i, attrList)
		attrListWave[i][0] = attrName
		attrListWave[i][1] = IR3HB_LoadAttributeAsString(side, hdfPath, attrName, typeFlag)
	endfor
	return 0
End

static Function/S IR3HB_LoadAttributeAsString(side, hdfPath, attrName, typeFlag)
	string side, hdfPath, attrName
	variable typeFlag
	DFREF saveDF = GetDataFolderDFR()
	DFREF dfr = $IR3HB_SidePath(side)
	NVAR fileID = dfr:FileID
	string previewFolder = IR3HB_SidePath(side) + ":Preview"
	if (!DataFolderExists(previewFolder))
		NewDataFolder /O $previewFolder
	endif
	SetDataFolder $previewFolder
	HDF5LoadData /A=attrName /O /Z /N=hdf5_attr /TYPE=(typeFlag) fileID, hdfPath
	variable loadErr = V_Flag
	SetDataFolder saveDF
	if (loadErr != 0)
		return "(unreadable)"
	endif
	WAVE/Z numAttr = $(previewFolder + ":hdf5_attr")
	WAVE/Z/T txtAttr = $(previewFolder + ":hdf5_attr")
	string result = ""
	if (WaveExists(numAttr) && WaveType(numAttr) != 0)
		variable n = numpnts(numAttr)
		if (n == 1)
			result = num2str(numAttr[0])
		else
			result = "[" + num2str(n) + " values]"
		endif
	elseif (WaveExists(txtAttr))
		variable nt = numpnts(txtAttr)
		if (nt == 1)
			result = txtAttr[0]
		else
			result = "[" + num2str(nt) + " strings]"
		endif
	else
		result = "(empty)"
	endif
	return result
End

//============================================================================
// SHARED-DISPLAY CLEAR
//============================================================================

static Function IR3HB_ClearSharedDisplay()
	SVAR selPath  = $(IR3HB_PkgPath + ":SelectedPath")
	SVAR selKind  = $(IR3HB_PkgPath + ":SelectedKind")
	SVAR selDType = $(IR3HB_PkgPath + ":SelectedDType")
	SVAR selShape = $(IR3HB_PkgPath + ":SelectedShape")
	SVAR scalarStr = $(IR3HB_PkgPath + ":ScalarValueStr")
	SVAR lastSide = $(IR3HB_PkgPath + ":LastClickedSide")
	WAVE/T previewListWave = $(IR3HB_PkgPath + ":PreviewListWave")
	WAVE   previewSelWave  = $(IR3HB_PkgPath + ":PreviewSelWave")
	WAVE/T attrListWave    = $(IR3HB_PkgPath + ":AttrListWave")
	WAVE   attrSelWave     = $(IR3HB_PkgPath + ":AttrSelWave")
	selPath = ""
	selKind = ""
	selDType = ""
	selShape = ""
	scalarStr = ""
	lastSide = ""
	Redimension /N=(0, 1) previewListWave
	Redimension /N=(0, 1) previewSelWave
	Redimension /N=(0, 2) attrListWave
	Redimension /N=(0, 1) attrSelWave
End

//============================================================================
// HELPERS
//============================================================================

static Function/S IR3HB_SidePath(side)
	string side
	return IR3HB_PkgPath + ":" + side
End

static Function/S IR3HB_SideFromCtrl(ctrlName)
	string ctrlName
	if (stringmatch(ctrlName, "Left*"))
		return "Left"
	elseif (stringmatch(ctrlName, "Right*"))
		return "Right"
	endif
	return ""
End

static Function/S IR3HB_GetBaseName(path)
	string path
	if (cmpstr(path, "/") == 0)
		return "/"
	endif
	variable n = ItemsInList(path, "/")
	if (n == 0)
		return path
	endif
	string result = StringFromList(n - 1, path, "/")
	if (strlen(result) == 0 && n >= 2)
		result = StringFromList(n - 2, path, "/")
	endif
	return result
End

static Function/S IR3HB_JoinPath(parent, child)
	string parent, child
	if (cmpstr(parent, "/") == 0)
		return "/" + child
	endif
	return parent + "/" + child
End

static Function/S IR3HB_RepeatStr(str, n)
	string str
	variable n
	string result = ""
	variable i
	for (i = 0; i < n; i += 1)
		result += str
	endfor
	return result
End

static Function/S IR3HB_DataTypeClassToString(class)
	variable class
	// HDF5 H5T type-class codes; see the HDF5 Help for full list
	switch (class)
		case 0:
			return "integer"
		case 1:
			return "float"
		case 3:
			return "string"
		case 4:
			return "bitfield"
		case 5:
			return "opaque"
		case 6:
			return "compound"
		case 7:
			return "reference"
		case 8:
			return "enum"
		case 9:
			return "vlen"
		case 10:
			return "array"
		default:
			return "class " + num2str(class)
	endswitch
End

static Function/S IR3HB_FormatShape(di)
	STRUCT HDF5DataInfo &di
	if (di.ndims == 0)
		return "scalar"
	endif
	string result = ""
	variable i
	for (i = 0; i < di.ndims; i += 1)
		if (i > 0)
			result += " x "
		endif
		result += num2str(di.dims[i])
	endfor
	return result
End

static Function/S IR3HB_FirstWaveInFolder(folderPath)
	string folderPath
	if (!DataFolderExists(folderPath))
		return ""
	endif
	DFREF saveDF = GetDataFolderDFR()
	SetDataFolder $folderPath
	string list = WaveList("*", ";", "")
	SetDataFolder saveDF
	if (ItemsInList(list) == 0)
		return ""
	endif
	return StringFromList(0, list)
End

//============================================================================
// COPY OPERATIONS (Phase 2)
//============================================================================

Function IR3HB_CopyItem(srcSide, dstSide)
	string srcSide, dstSide
	DFREF srcDfr = $IR3HB_SidePath(srcSide)
	DFREF dstDfr = $IR3HB_SidePath(dstSide)
	SVAR srcType = srcDfr:SourceType
	SVAR dstType = dstDfr:SourceType
	if (strlen(srcType) == 0)
		DoAlert /T="HDF5 Browser" 0, "Source pane (" + srcSide + ") has no source loaded. Open an HDF5 file or click 'Igor' first."
		return 0
	endif
	if (strlen(dstType) == 0)
		DoAlert /T="HDF5 Browser" 0, "Destination pane (" + dstSide + ") has no source loaded. Open an HDF5 file or click 'Igor' first."
		return 0
	endif
	variable srcIdx = IR3HB_GetSelectedFullTreeIdx(srcSide)
	if (srcIdx < 0)
		DoAlert /T="HDF5 Browser" 0, "Select an item to copy in the " + srcSide + " pane first."
		return 0
	endif
	WAVE/T srcText = srcDfr:FullTreeText
	string srcPath = srcText[srcIdx][0]
	string srcKind = srcText[srcIdx][2]
	string srcName = IR3HB_PathBaseName(srcPath, srcType)
	// Determine destination parent path
	string dstParentPath = IR3HB_ResolveDestParent(dstSide, dstType)
	// Dispatch
	variable ok = 0
	string mode = srcType + "->" + dstType
	strswitch (mode)
		case "HDF5->HDF5":
			ok = IR3HB_CopyHDF5toHDF5(srcDfr, srcPath, srcKind, srcName, dstDfr, dstParentPath)
			break
		case "HDF5->Igor":
			ok = IR3HB_CopyHDF5toIgor(srcDfr, srcPath, srcKind, srcName, dstParentPath)
			break
		case "Igor->HDF5":
			ok = IR3HB_CopyIgorToHDF5(srcPath, srcKind, srcName, dstDfr, dstParentPath)
			break
		case "Igor->Igor":
			ok = IR3HB_CopyIgorToIgor(srcPath, srcKind, srcName, dstParentPath)
			break
	endswitch
	if (ok)
		Printf "HDF5 Browser: copied '%s' (%s) -> %s pane at %s\r", srcPath, srcKind, dstSide, dstParentPath
		IR3HB_RefreshTree(dstSide)
	else
		Printf "HDF5 Browser: copy of '%s' (%s -> %s) failed\r", srcPath, srcType, dstType
	endif
	return ok
End

static Function/S IR3HB_ResolveDestParent(dstSide, dstType)
	string dstSide, dstType
	DFREF dstDfr = $IR3HB_SidePath(dstSide)
	variable dstIdx = IR3HB_GetSelectedFullTreeIdx(dstSide)
	string rootPath = SelectString(cmpstr(dstType, "HDF5") == 0, "root:", "/")
	if (dstIdx < 0)
		return rootPath
	endif
	WAVE/T dstText = dstDfr:FullTreeText
	string dstSelPath = dstText[dstIdx][0]
	string dstSelKind = dstText[dstIdx][2]
	if (cmpstr(dstSelKind, "G") == 0)
		return dstSelPath
	endif
	// Selected a leaf -> use its parent
	if (cmpstr(dstType, "HDF5") == 0)
		return IR3HB_GetHDF5ParentPath(dstSelPath)
	endif
	return IR3HB_GetIgorParentPath(dstSelPath)
End

//---------------------------------------------------------------------------
// HDF5 -> HDF5
//---------------------------------------------------------------------------

static Function IR3HB_CopyHDF5toHDF5(srcDfr, srcPath, srcKind, srcName, dstDfr, dstParentPath)
	DFREF srcDfr, dstDfr
	string srcPath, srcKind, srcName, dstParentPath
	NVAR srcFileID = srcDfr:FileID
	NVAR dstFileID = dstDfr:FileID
	NVAR dstReadOnly = dstDfr:IsReadOnly
	if (srcFileID < 0 || dstFileID < 0)
		Print "HDF5 Browser: HDF5->HDF5 copy aborted: source or destination file not open"
		return 0
	endif
	if (dstReadOnly)
		DoAlert /T="HDF5 Browser" 0, "Destination HDF5 file is open READ-ONLY (locked or write access denied). Close it and reopen with write access to copy into it."
		return 0
	endif
	DFREF saveDF = GetDataFolderDFR()
	string tempFolder = IR3HB_PkgPath + ":copyTemp"
	KillDataFolder /Z $tempFolder
	NewDataFolder /O $tempFolder
	if (cmpstr(srcKind, "G") == 0)
		// Group -> stage via Igor folder
		SetDataFolder $tempFolder
		HDF5LoadGroup /Z /R /O /L=7 /T=$srcName :, srcFileID, srcPath
		variable loadErr = V_Flag
		SetDataFolder saveDF
		if (loadErr != 0)
			Printf "HDF5 Browser: HDF5LoadGroup failed for '%s' (V_Flag=%d)\r", srcPath, loadErr
			KillDataFolder /Z $tempFolder
			return 0
		endif
		string dstGroupPath = IR3HB_HDF5JoinPath(dstParentPath, srcName)
		// HDF5SaveGroup needs the destination group itself to exist (it populates it),
		// not just the parent. Walk the full path.
		IR3HB_HDF5EnsureGroupChain(dstFileID, dstGroupPath)
		HDF5SaveGroup /Z /R /O $(tempFolder + ":" + srcName), dstFileID, dstGroupPath
		variable saveErr = V_Flag
		if (saveErr != 0)
			Printf "HDF5 Browser: HDF5SaveGroup failed for dst '%s' (V_Flag=%d)\r", dstGroupPath, saveErr
		else
			// Preserve attributes recursively across the whole subtree
			IR3HB_HDF5CopyAttrsRecursive(srcFileID, srcPath, dstFileID, dstGroupPath)
		endif
		KillDataFolder /Z $tempFolder
		return (saveErr == 0)
	endif
	// Dataset -> load to temp wave, save to dst
	SetDataFolder $tempFolder
	HDF5LoadData /Z /O /N=$srcName srcFileID, srcPath
	variable lerr = V_Flag
	SetDataFolder saveDF
	if (lerr != 0)
		Printf "HDF5 Browser: HDF5LoadData failed for '%s' (V_Flag=%d)\r", srcPath, lerr
		KillDataFolder /Z $tempFolder
		return 0
	endif
	WAVE /Z tempWv = $(tempFolder + ":" + srcName)
	if (!WaveExists(tempWv))
		Printf "HDF5 Browser: loaded wave '%s' not found in %s\r", srcName, tempFolder
		KillDataFolder /Z $tempFolder
		return 0
	endif
	IR3HB_HDF5EnsureGroupChain(dstFileID, dstParentPath)
	string dstDsPath = IR3HB_HDF5JoinPath(dstParentPath, srcName)
	HDF5SaveData /Z /O tempWv, dstFileID, dstDsPath
	variable serr = V_Flag
	if (serr != 0)
		Printf "HDF5 Browser: HDF5SaveData failed for dst '%s' (V_Flag=%d)\r", dstDsPath, serr
	else
		// Preserve dataset attributes
		IR3HB_HDF5CopyOneAttrSet(srcFileID, srcPath, 2, dstFileID, dstDsPath, 2)
	endif
	KillDataFolder /Z $tempFolder
	return (serr == 0)
End

//---------------------------------------------------------------------------
// HDF5 -> Igor
//---------------------------------------------------------------------------

static Function IR3HB_CopyHDF5toIgor(srcDfr, srcPath, srcKind, srcName, dstParentPath)
	DFREF srcDfr
	string srcPath, srcKind, srcName, dstParentPath
	NVAR srcFileID = srcDfr:FileID
	if (srcFileID < 0)
		return 0
	endif
	IR3HB_IgorEnsureFolderChain(dstParentPath)
	DFREF saveDF = GetDataFolderDFR()
	SetDataFolder $dstParentPath
	if (cmpstr(srcKind, "G") == 0)
		HDF5LoadGroup /Z /R /O /L=7 /T=$srcName :, srcFileID, srcPath
	else
		HDF5LoadData /Z /Q /O /N=$srcName srcFileID, srcPath
	endif
	variable err = V_Flag
	SetDataFolder saveDF
	if (err != 0)
		return 0
	endif
	// Attribute preservation
	if (cmpstr(srcKind, "G") == 0)
		string igorTopFolder = IR3HB_IgorJoinPath(dstParentPath, srcName)
		IR3HB_HDF5TreeToIgorAttrsRecursive(srcFileID, srcPath, igorTopFolder)
	else
		string wavePath = IR3HB_IgorJoinPath(dstParentPath, srcName)
		WAVE /Z wv = $wavePath
		if (WaveExists(wv))
			string noteStr = IR3HB_HDF5AttrsToNoteString(srcFileID, srcPath, 2)
			if (strlen(noteStr) > 0)
				Note /K wv
				Note wv, noteStr
			endif
		endif
	endif
	return 1
End

//---------------------------------------------------------------------------
// Igor -> HDF5
//---------------------------------------------------------------------------

static Function IR3HB_CopyIgorToHDF5(srcPath, srcKind, srcName, dstDfr, dstParentPath)
	string srcPath, srcKind, srcName, dstParentPath
	DFREF dstDfr
	NVAR dstFileID = dstDfr:FileID
	NVAR dstReadOnly = dstDfr:IsReadOnly
	if (dstFileID < 0)
		Print "HDF5 Browser: Igor->HDF5 copy aborted: destination file not open"
		return 0
	endif
	if (dstReadOnly)
		DoAlert /T="HDF5 Browser" 0, "Destination HDF5 file is open READ-ONLY (locked or write access denied). Close it and reopen with write access to copy into it."
		return 0
	endif
	string dstFullPath = IR3HB_HDF5JoinPath(dstParentPath, srcName)
	variable err = 0
	if (cmpstr(srcKind, "G") == 0)
		// HDF5SaveGroup needs the destination group itself to exist
		IR3HB_HDF5EnsureGroupChain(dstFileID, dstFullPath)
		HDF5SaveGroup /Z /R /O $srcPath, dstFileID, dstFullPath
		err = V_Flag
		if (err != 0)
			Printf "HDF5 Browser: HDF5SaveGroup failed for src '%s' -> '%s' (V_Flag=%d)\r", srcPath, dstFullPath, err
			return 0
		endif
		// Attribute preservation: walk Igor folder tree, write notes/sidecars as HDF5 attrs
		IR3HB_IgorTreeToHDF5AttrsRecursive(srcPath, dstFileID, dstFullPath)
		return 1
	endif
	// For datasets / variables / strings the parent must exist; the dataset itself does not
	IR3HB_HDF5EnsureGroupChain(dstFileID, dstParentPath)
	if (cmpstr(srcKind, "D") == 0)
		WAVE /Z wv = $srcPath
		if (!WaveExists(wv))
			Printf "HDF5 Browser: source wave '%s' not found\r", srcPath
			return 0
		endif
		HDF5SaveData /Z /O wv, dstFileID, dstFullPath
		err = V_Flag
		if (err != 0)
			Printf "HDF5 Browser: HDF5SaveData failed for '%s' -> '%s' (V_Flag=%d)\r", srcPath, dstFullPath, err
			return 0
		endif
		// Attribute preservation: wave note -> HDF5 attrs
		string wnote = note(wv)
		if (strlen(wnote) > 0)
			IR3HB_NoteStringToHDF5Attrs(wnote, dstFileID, dstFullPath, 2)
		endif
		return 1
	endif
	if (cmpstr(srcKind, "V") == 0)
		NVAR /Z var = $srcPath
		if (!NVAR_Exists(var))
			Printf "HDF5 Browser: source variable '%s' not found\r", srcPath
			return 0
		endif
		Make /O /D /FREE /N=1 tempScalar
		tempScalar[0] = var
		HDF5SaveData /Z /O tempScalar, dstFileID, dstFullPath
		err = V_Flag
		if (err != 0)
			Printf "HDF5 Browser: HDF5SaveData (variable) failed for '%s' (V_Flag=%d)\r", dstFullPath, err
		endif
		return (err == 0)
	endif
	if (cmpstr(srcKind, "S") == 0)
		SVAR /Z str = $srcPath
		if (!SVAR_Exists(str))
			Printf "HDF5 Browser: source string '%s' not found\r", srcPath
			return 0
		endif
		Make /O /T /FREE /N=1 tempStr
		tempStr[0] = str
		HDF5SaveData /Z /O tempStr, dstFileID, dstFullPath
		err = V_Flag
		if (err != 0)
			Printf "HDF5 Browser: HDF5SaveData (string) failed for '%s' (V_Flag=%d)\r", dstFullPath, err
		endif
		return (err == 0)
	endif
	Printf "HDF5 Browser: unknown source kind '%s' for Igor->HDF5 copy\r", srcKind
	return 0
End

//---------------------------------------------------------------------------
// Igor -> Igor
//---------------------------------------------------------------------------

static Function IR3HB_CopyIgorToIgor(srcPath, srcKind, srcName, dstParentPath)
	string srcPath, srcKind, srcName, dstParentPath
	IR3HB_IgorEnsureFolderChain(dstParentPath)
	string dstFullPath = IR3HB_IgorJoinPath(dstParentPath, srcName)
	if (cmpstr(srcPath, dstFullPath) == 0)
		// Self-copy: nothing to do
		return 1
	endif
	if (cmpstr(srcKind, "G") == 0)
		KillDataFolder /Z $dstFullPath
		DuplicateDataFolder $srcPath, $dstFullPath
		return 1
	endif
	if (cmpstr(srcKind, "D") == 0)
		WAVE /Z wv = $srcPath
		if (!WaveExists(wv))
			return 0
		endif
		Duplicate /O wv, $dstFullPath
		return 1
	endif
	if (cmpstr(srcKind, "V") == 0)
		NVAR /Z var = $srcPath
		if (!NVAR_Exists(var))
			return 0
		endif
		variable v = var
		DFREF saveDF = GetDataFolderDFR()
		SetDataFolder $dstParentPath
		Variable /G $srcName
		NVAR newVar = $srcName
		newVar = v
		SetDataFolder saveDF
		return 1
	endif
	if (cmpstr(srcKind, "S") == 0)
		SVAR /Z str = $srcPath
		if (!SVAR_Exists(str))
			return 0
		endif
		string s = str
		DFREF saveDF2 = GetDataFolderDFR()
		SetDataFolder $dstParentPath
		String /G $srcName
		SVAR newStr = $srcName
		newStr = s
		SetDataFolder saveDF2
		return 1
	endif
	return 0
End

//---------------------------------------------------------------------------
// Path / folder helpers
//---------------------------------------------------------------------------

static Function/S IR3HB_PathBaseName(path, sourceType)
	string path, sourceType
	if (cmpstr(sourceType, "HDF5") == 0)
		return IR3HB_GetBaseName(path)
	endif
	return IR3HB_IgorBaseName(path)
End

static Function/S IR3HB_GetHDF5ParentPath(path)
	string path
	if (cmpstr(path, "/") == 0)
		return "/"
	endif
	variable lastSlash = strsearch(path, "/", inf, 1)
	if (lastSlash <= 0)
		return "/"
	endif
	return path[0, lastSlash - 1]
End

static Function/S IR3HB_GetIgorParentPath(path)
	string path
	if (cmpstr(path, "root:") == 0)
		return "root:"
	endif
	// Strip trailing colon
	variable L = strlen(path)
	if (L > 0 && cmpstr(path[L - 1, L - 1], ":") == 0)
		path = path[0, L - 2]
	endif
	variable lastColon = strsearch(path, ":", inf, 1)
	if (lastColon <= 0)
		return "root:"
	endif
	return path[0, lastColon] // include the trailing colon
End

static Function/S IR3HB_HDF5JoinPath(parent, child)
	string parent, child
	if (cmpstr(parent, "/") == 0)
		return "/" + child
	endif
	return parent + "/" + child
End

static Function IR3HB_HDF5EnsureGroupChain(fileID, hdfPath)
	variable fileID
	string hdfPath
	if (cmpstr(hdfPath, "/") == 0 || strlen(hdfPath) == 0)
		return 0
	endif
	// Walk components and create each missing group
	variable n = ItemsInList(hdfPath, "/")
	string accumPath = ""
	variable i, newGroupID
	string part
	for (i = 0; i < n; i += 1)
		part = StringFromList(i, hdfPath, "/")
		if (strlen(part) == 0)
			continue
		endif
		accumPath += "/" + part
		HDF5CreateGroup /Z fileID, accumPath, newGroupID
		if (V_Flag == 0)
			HDF5CloseGroup /Z newGroupID
		endif
	endfor
	return 0
End

static Function IR3HB_IgorEnsureFolderChain(igorPath)
	string igorPath
	if (DataFolderExists(igorPath))
		return 0
	endif
	// Strip trailing colon
	variable L = strlen(igorPath)
	if (L > 0 && cmpstr(igorPath[L - 1, L - 1], ":") == 0)
		igorPath = igorPath[0, L - 2]
	endif
	variable n = ItemsInList(igorPath, ":")
	if (n == 0)
		return 0
	endif
	string accum = ""
	variable i
	string part
	for (i = 0; i < n; i += 1)
		part = StringFromList(i, igorPath, ":")
		if (strlen(part) == 0)
			continue
		endif
		if (i == 0)
			accum = part
		else
			accum += ":" + part
		endif
		if (i > 0 && !DataFolderExists(accum))
			NewDataFolder /O $accum
		endif
	endfor
	return 0
End

//---------------------------------------------------------------------------
// Selection accessor + tree refresh
//---------------------------------------------------------------------------

static Function IR3HB_GetSelectedFullTreeIdx(side)
	string side
	DFREF dfr = $IR3HB_SidePath(side)
	NVAR /Z selectedIdx = dfr:SelectedFullTreeIdx
	if (!NVAR_Exists(selectedIdx))
		return -1
	endif
	WAVE/T fullTreeText = dfr:FullTreeText
	if (selectedIdx < 0 || selectedIdx >= DimSize(fullTreeText, 0))
		return -1
	endif
	return selectedIdx
End

static Function IR3HB_RefreshTree(side)
	string side
	DFREF dfr = $IR3HB_SidePath(side)
	SVAR sourceType = dfr:SourceType
	NVAR fileID = dfr:FileID
	// Snapshot expanded paths so we can restore them after rebuild
	WAVE/T fullTreeText = dfr:FullTreeText
	WAVE   expanded     = dfr:ExpandedState
	variable nOld = DimSize(fullTreeText, 0)
	Make /O /T /FREE /N=(nOld) oldExpandedPaths
	variable nKept = 0
	variable i
	for (i = 0; i < nOld; i += 1)
		if (i < numpnts(expanded) && expanded[i])
			oldExpandedPaths[nKept] = fullTreeText[i][0]
			nKept += 1
		endif
	endfor
	Redimension /N=(nKept) oldExpandedPaths
	// Rebuild
	if (cmpstr(sourceType, "HDF5") == 0 && fileID >= 0)
		IR3HB_BuildFullTree(side, fileID)
	elseif (cmpstr(sourceType, "Igor") == 0)
		IR3HB_BuildIgorTree(side, "root:")
	endif
	// Restore expanded state by path matching
	WAVE/T newText = dfr:FullTreeText
	WAVE   newExpanded = dfr:ExpandedState
	variable nNew = DimSize(newText, 0)
	if (nNew > 0)
		newExpanded = 0
		newExpanded[0] = 1
	endif
	variable j
	for (i = 0; i < nKept; i += 1)
		for (j = 0; j < nNew; j += 1)
			if (cmpstr(newText[j][0], oldExpandedPaths[i]) == 0)
				newExpanded[j] = 1
				break
			endif
		endfor
	endfor
	IR3HB_RebuildVisibleRows(side)
End

//============================================================================
// RIGHT-CLICK CONTEXT MENU + INSPECT / PLOT
//============================================================================

static Function IR3HB_HandleRightClick(side, visibleRow)
	string side
	variable visibleRow
	DFREF dfr = $IR3HB_SidePath(side)
	WAVE visibleRows = dfr:VisibleRows
	if (visibleRow < 0 || visibleRow >= numpnts(visibleRows))
		return 0
	endif
	// Update selection so right-click acts on the row that was right-clicked
	IR3HB_OnSelect(side, visibleRow)
	IR3HB_SetTreeSelRow(side, visibleRow)
	variable fullIdx = visibleRows[visibleRow]
	WAVE/T fullTreeText = dfr:FullTreeText
	string rowKind = fullTreeText[fullIdx][2]
	string otherSide = SelectString(cmpstr(side, "Left") == 0, "Left", "Right")
	string menuItems = "Copy to other pane (" + otherSide + ");"
	menuItems += "Copy to Igor (current data folder);"
	menuItems += "New Folder-Group...;"
	menuItems += "Delete...;"
	menuItems += "Show metadata;"
	menuItems += "Plot 1D wave;"
	PopupContextualMenu menuItems
	switch (V_Flag)
		case 1:
			IR3HB_CopyItem(side, otherSide)
			break
		case 2:
			IR3HB_CopyToCurrentDF(side)
			break
		case 3:
			IR3HB_NewObjectAtSelected(side)
			break
		case 4:
			IR3HB_DeleteSelected(side)
			break
		case 5:
			IR3HB_ShowMetadataDialog(side)
			break
		case 6:
			IR3HB_PlotSelected(side)
			break
	endswitch
	return 0
End

static Function IR3HB_CopyToCurrentDF(side)
	string side
	DFREF dfr = $IR3HB_SidePath(side)
	SVAR srcType = dfr:SourceType
	if (strlen(srcType) == 0)
		return 0
	endif
	variable srcIdx = IR3HB_GetSelectedFullTreeIdx(side)
	if (srcIdx < 0)
		return 0
	endif
	WAVE/T srcText = dfr:FullTreeText
	string srcPath = srcText[srcIdx][0]
	string srcKind = srcText[srcIdx][2]
	string srcName = IR3HB_PathBaseName(srcPath, srcType)
	string dstParentPath = GetDataFolder(1)
	variable ok
	if (cmpstr(srcType, "HDF5") == 0)
		ok = IR3HB_CopyHDF5toIgor(dfr, srcPath, srcKind, srcName, dstParentPath)
	else
		ok = IR3HB_CopyIgorToIgor(srcPath, srcKind, srcName, dstParentPath)
	endif
	if (ok)
		Printf "HDF5 Browser: copied '%s' (%s) -> current data folder %s\r", srcPath, srcKind, dstParentPath
	else
		Printf "HDF5 Browser: copy of '%s' to current data folder failed\r", srcPath
	endif
	return ok
End

static Function IR3HB_ShowMetadataDialog(side)
	string side
	DFREF dfr = $IR3HB_SidePath(side)
	SVAR srcType = dfr:SourceType
	variable srcIdx = IR3HB_GetSelectedFullTreeIdx(side)
	if (srcIdx < 0)
		return 0
	endif
	WAVE/T srcText = dfr:FullTreeText
	string srcPath = srcText[srcIdx][0]
	string srcKind = srcText[srcIdx][2]
	string msg = "Pane:   " + side + "\rSource: " + srcType + "\rPath:   " + srcPath + "\rKind:   " + srcKind + "\r"
	if (cmpstr(srcType, "HDF5") == 0)
		NVAR fileID = dfr:FileID
		if (fileID >= 0 && cmpstr(srcKind, "G") != 0)
			STRUCT HDF5DataInfo di
			InitHDF5DataInfo(di)
			variable err = HDF5DatasetInfo(fileID, srcPath, 1, di)
			if (err == 0)
				msg += "DType:  " + IR3HB_DataTypeClassToString(di.datatype_class) + " (" + num2str(di.datatype_size) + " B)\r"
				msg += "Shape:  " + IR3HB_FormatShape(di) + "\r"
			endif
			HDF5ListAttributes /TYPE=2 /Z fileID, srcPath
			if (V_Flag == 0)
				msg += "Attrs:  " + S_HDF5ListAttributes + "\r"
			endif
		endif
	else
		// Igor source
		strswitch (srcKind)
			case "D":
				WAVE /Z wv = $srcPath
				if (WaveExists(wv))
					msg += "DType:  " + IR3HB_WaveTypeToString(wv) + "\r"
					msg += "Shape:  " + IR3HB_FormatWaveShape(wv) + "\r"
				endif
				break
			case "V":
				NVAR /Z var = $srcPath
				if (NVAR_Exists(var))
					msg += "Value:  " + num2str(var) + "\r"
				endif
				break
			case "S":
				SVAR /Z str = $srcPath
				if (SVAR_Exists(str))
					msg += "Length: " + num2str(strlen(str)) + " chars\r"
				endif
				break
		endswitch
	endif
	DoAlert /T="HDF5 Browser - selected item" 0, msg
	return 0
End

static Function IR3HB_PlotSelected(side)
	string side
	DFREF dfr = $IR3HB_SidePath(side)
	SVAR srcType = dfr:SourceType
	variable srcIdx = IR3HB_GetSelectedFullTreeIdx(side)
	if (srcIdx < 0)
		return 0
	endif
	WAVE/T srcText = dfr:FullTreeText
	string srcPath = srcText[srcIdx][0]
	string srcKind = srcText[srcIdx][2]
	if (cmpstr(srcKind, "D") != 0)
		DoAlert /T="HDF5 Browser" 0, "Plot is only supported for 1D numeric datasets / waves."
		return 0
	endif
	WAVE /Z plotWv
	string previewFolder
	if (cmpstr(srcType, "HDF5") == 0)
		// Load to a dedicated _plotTemp folder
		previewFolder = IR3HB_PkgPath + ":plotTemp"
		KillDataFolder /Z $previewFolder
		NewDataFolder /O $previewFolder
		NVAR fileID = dfr:FileID
		DFREF saveDF = GetDataFolderDFR()
		SetDataFolder $previewFolder
		HDF5LoadData /Z /O /N=plot_wave fileID, srcPath
		variable err = V_Flag
		SetDataFolder saveDF
		if (err != 0)
			DoAlert /T="HDF5 Browser" 0, "Could not load dataset for plotting."
			return 0
		endif
		WAVE /Z plotWv = $(previewFolder + ":plot_wave")
	else
		WAVE /Z plotWv = $srcPath
	endif
	if (!WaveExists(plotWv))
		DoAlert /T="HDF5 Browser" 0, "Wave for plotting not found."
		return 0
	endif
	if (WaveType(plotWv) == 0 || WaveDims(plotWv) != 1)
		DoAlert /T="HDF5 Browser" 0, "Plot supports 1D numeric data only."
		return 0
	endif
	Display /K=1 plotWv as "HDF5 Browser - " + srcPath
	return 0
End

//---------------------------------------------------------------------------
// New folder / group at selected location
//---------------------------------------------------------------------------

static Function IR3HB_NewObjectAtSelected(side)
	string side
	DFREF dfr = $IR3HB_SidePath(side)
	SVAR srcType = dfr:SourceType
	if (strlen(srcType) == 0)
		DoAlert /T="HDF5 Browser" 0, "Pane has no source loaded."
		return 0
	endif
	if (cmpstr(srcType, "HDF5") == 0)
		NVAR isReadOnly = dfr:IsReadOnly
		if (isReadOnly)
			DoAlert /T="HDF5 Browser" 0, "HDF5 file is open READ-ONLY. Reopen with write access to create new groups."
			return 0
		endif
	endif
	string parentPath = IR3HB_ResolveDestParent(side, srcType)
	string label = SelectString(cmpstr(srcType, "HDF5") == 0, "data folder", "group")
	string newName = ""
	Prompt newName, "New " + label + " name:"
	DoPrompt "Create new " + label + " in " + parentPath, newName
	if (V_Flag != 0)
		return 0
	endif
	if (strlen(newName) == 0)
		DoAlert /T="HDF5 Browser" 0, "Name cannot be empty."
		return 0
	endif
	string cleanName
	if (cmpstr(srcType, "HDF5") == 0)
		cleanName = IR3HB_SanitizeHDF5Name(newName)
	else
		cleanName = CleanupName(newName, 0)
	endif
	if (strlen(cleanName) == 0)
		DoAlert /T="HDF5 Browser" 0, "Could not derive a valid name from '" + newName + "'."
		return 0
	endif
	if (cmpstr(cleanName, newName) != 0)
		Printf "HDF5 Browser: name '%s' sanitized to '%s'\r", newName, cleanName
	endif
	variable ok = 0
	if (cmpstr(srcType, "HDF5") == 0)
		NVAR fileID = dfr:FileID
		IR3HB_HDF5EnsureGroupChain(fileID, parentPath)
		string newPath = IR3HB_HDF5JoinPath(parentPath, cleanName)
		variable newGid
		HDF5CreateGroup /Z fileID, newPath, newGid
		if (V_Flag == 0)
			HDF5CloseGroup /Z newGid
			ok = 1
		else
			Printf "HDF5 Browser: HDF5CreateGroup failed for '%s' (V_Flag=%d)\r", newPath, V_Flag
		endif
	else
		IR3HB_IgorEnsureFolderChain(parentPath)
		string newFullPath = IR3HB_IgorJoinPath(parentPath, cleanName)
		NewDataFolder /O $newFullPath
		ok = DataFolderExists(newFullPath)
	endif
	if (ok)
		Printf "HDF5 Browser: created new %s '%s' in %s pane at %s\r", label, cleanName, side, parentPath
		IR3HB_RefreshTree(side)
	endif
	return ok
End

static Function/S IR3HB_SanitizeHDF5Name(name)
	string name
	name = TrimString(name)
	name = ReplaceString("/", name, "_")
	name = ReplaceString("\\", name, "_")
	if (strlen(name) == 0)
		return ""
	endif
	return name
End

//---------------------------------------------------------------------------
// Delete selected object
//---------------------------------------------------------------------------

static Function IR3HB_DeleteSelected(side)
	string side
	DFREF dfr = $IR3HB_SidePath(side)
	SVAR srcType = dfr:SourceType
	if (strlen(srcType) == 0)
		return 0
	endif
	if (cmpstr(srcType, "HDF5") == 0)
		NVAR isReadOnly = dfr:IsReadOnly
		if (isReadOnly)
			DoAlert /T="HDF5 Browser" 0, "HDF5 file is open READ-ONLY. Reopen with write access to delete."
			return 0
		endif
	endif
	variable idx = IR3HB_GetSelectedFullTreeIdx(side)
	if (idx < 0)
		DoAlert /T="HDF5 Browser" 0, "Select an item to delete first."
		return 0
	endif
	WAVE/T fullTreeText = dfr:FullTreeText
	string itemPath = fullTreeText[idx][0]
	string itemKind = fullTreeText[idx][2]
	// Refuse to delete root
	if (cmpstr(srcType, "HDF5") == 0 && cmpstr(itemPath, "/") == 0)
		DoAlert /T="HDF5 Browser" 0, "Cannot delete the root group."
		return 0
	endif
	if (cmpstr(srcType, "Igor") == 0 && cmpstr(itemPath, "root:") == 0)
		DoAlert /T="HDF5 Browser" 0, "Cannot delete the root data folder."
		return 0
	endif
	DoAlert /T="Confirm Delete" 1, "Permanently delete this item from the " + side + " pane?\r\r" + itemPath + "\r\rThis cannot be undone."
	if (V_Flag != 1)
		return 0
	endif
	variable ok = 0
	if (cmpstr(srcType, "HDF5") == 0)
		NVAR fileID = dfr:FileID
		HDF5UnlinkObject /Z fileID, itemPath
		ok = (V_Flag == 0)
		if (!ok)
			Printf "HDF5 Browser: HDF5UnlinkObject failed for '%s' (V_Flag=%d)\r", itemPath, V_Flag
		endif
	else
		ok = IR3HB_DeleteIgorItem(itemPath, itemKind)
	endif
	if (ok)
		Printf "HDF5 Browser: deleted '%s' from %s pane\r", itemPath, side
		// Selection no longer valid after delete
		NVAR selectedIdx = dfr:SelectedFullTreeIdx
		selectedIdx = -1
		IR3HB_RefreshTree(side)
	endif
	return ok
End

static Function IR3HB_DeleteIgorItem(itemPath, itemKind)
	string itemPath, itemKind
	DFREF saveDF = GetDataFolderDFR()
	string parentPath = IR3HB_GetIgorParentPath(itemPath)
	string itemName   = IR3HB_IgorBaseName(itemPath)
	variable ok = 0
	strswitch (itemKind)
		case "G":
			KillDataFolder /Z $itemPath
			ok = !DataFolderExists(itemPath)
			break
		case "D":
			KillWaves /Z $itemPath
			WAVE /Z chk = $itemPath
			ok = !WaveExists(chk)
			break
		case "V":
			SetDataFolder $parentPath
			KillVariables /Z $itemName
			SetDataFolder saveDF
			NVAR /Z chkV = $itemPath
			ok = !NVAR_Exists(chkV)
			break
		case "S":
			SetDataFolder $parentPath
			KillStrings /Z $itemName
			SetDataFolder saveDF
			SVAR /Z chkS = $itemPath
			ok = !SVAR_Exists(chkS)
			break
	endswitch
	return ok
End

//============================================================================
// ATTRIBUTE PRESERVATION (Phase 4)
//
// HDF5 attributes survive copies as follows:
//   HDF5 dataset/group <-> HDF5 dataset/group : direct attr-by-attr copy
//   HDF5 dataset       -> Igor wave           : attrs encoded into wave note
//                                               as "key=value;..." (Irena style)
//   HDF5 group         -> Igor folder         : sidecar wave Igor___folder_attributes
//                                               in the folder, attrs in its wave note
//   Igor wave          -> HDF5 dataset        : wave note parsed; if all items are
//                                               key=value pairs, each becomes an attr.
//                                               Otherwise the whole note is saved as
//                                               a single "IgorWaveNote" attr
//   Igor folder        -> HDF5 group          : look for sidecar wave; if present,
//                                               its note is parsed like a wave note
//
// Multi-value attrs are encoded "[v1,v2,v3]" inside the value position.
// Recursion: implemented for HDF5<->HDF5 (parallel walk) and HDF5<->Igor
// (walk source tree, address corresponding destination).
//============================================================================

//---------------------------------------------------------------------------
// Read all HDF5 attrs of one object, return "key=value;..." string
//---------------------------------------------------------------------------

static Function/S IR3HB_HDF5AttrsToNoteString(fileID, hdfPath, typeFlag)
	variable fileID, typeFlag
	string hdfPath
	HDF5ListAttributes /TYPE=(typeFlag) /Z fileID, hdfPath
	if (V_Flag != 0)
		return ""
	endif
	string attrList = S_HDF5ListAttributes
	variable nAttrs = ItemsInList(attrList)
	if (nAttrs == 0)
		return ""
	endif
	string result = ""
	variable i
	string attrName, attrValue
	for (i = 0; i < nAttrs; i += 1)
		attrName = StringFromList(i, attrList)
		attrValue = IR3HB_HDF5AttrToEncodedString(fileID, hdfPath, attrName, typeFlag)
		result += attrName + "=" + attrValue + ";"
	endfor
	return result
End

static Function/S IR3HB_HDF5AttrToEncodedString(fileID, hdfPath, attrName, typeFlag)
	variable fileID, typeFlag
	string hdfPath, attrName
	DFREF saveDF = GetDataFolderDFR()
	NewDataFolder /O $IR3HB_AttrTempFolder
	SetDataFolder $IR3HB_AttrTempFolder
	HDF5LoadData /A=attrName /O /Q /Z /N=tmpAttr /TYPE=(typeFlag) fileID, hdfPath
	variable err = V_Flag
	SetDataFolder saveDF
	if (err != 0)
		return ""
	endif
	string fullName = IR3HB_AttrTempFolder + ":tmpAttr"
	WAVE/Z   numAttr = $fullName
	WAVE/Z/T txtAttr = $fullName
	if (WaveExists(numAttr) && WaveType(numAttr) != 0)
		variable n = numpnts(numAttr)
		if (n == 1)
			return num2str(numAttr[0])
		endif
		string r = "["
		variable i
		for (i = 0; i < n; i += 1)
			if (i > 0)
				r += ","
			endif
			r += num2str(numAttr[i])
		endfor
		return r + "]"
	endif
	if (WaveExists(txtAttr))
		variable nt = numpnts(txtAttr)
		if (nt == 1)
			return txtAttr[0]
		endif
		string rt = "["
		variable j
		for (j = 0; j < nt; j += 1)
			if (j > 0)
				rt += ","
			endif
			rt += txtAttr[j]
		endfor
		return rt + "]"
	endif
	return ""
End

//---------------------------------------------------------------------------
// Parse "key=value;..." string and write each pair as HDF5 attribute
// (or save the whole string as a single IgorWaveNote attr if it doesn't fit)
//---------------------------------------------------------------------------

static Function IR3HB_NoteStringToHDF5Attrs(noteStr, fileID, hdfPath, typeFlag)
	string noteStr
	variable fileID, typeFlag
	string hdfPath
	if (strlen(noteStr) == 0)
		return 0
	endif
	variable nItems = ItemsInList(noteStr, ";")
	variable validPairs = 0, totalNonEmpty = 0
	variable i, equalPos
	string item
	for (i = 0; i < nItems; i += 1)
		item = StringFromList(i, noteStr, ";")
		if (strlen(item) == 0)
			continue
		endif
		totalNonEmpty += 1
		equalPos = strsearch(item, "=", 0)
		if (equalPos > 0)
			validPairs += 1
		endif
	endfor
	if (totalNonEmpty == 0)
		return 0
	endif
	string key, value
	if (validPairs == totalNonEmpty)
		// Pure key=value;... format - save each individually
		for (i = 0; i < nItems; i += 1)
			item = StringFromList(i, noteStr, ";")
			if (strlen(item) == 0)
				continue
			endif
			equalPos = strsearch(item, "=", 0)
			key   = item[0, equalPos - 1]
			value = item[equalPos + 1, inf]
			IR3HB_WriteSingleHDF5Attr(fileID, hdfPath, typeFlag, key, value)
		endfor
	else
		// Free-text or mixed - save whole note as one attr
		IR3HB_WriteSingleHDF5Attr(fileID, hdfPath, typeFlag, IR3HB_WaveNoteAttrName, noteStr)
	endif
	return 0
End

static Function IR3HB_WriteSingleHDF5Attr(fileID, hdfPath, typeFlag, attrName, valueStr)
	variable fileID, typeFlag
	string hdfPath, attrName, valueStr
	DFREF saveDF = GetDataFolderDFR()
	NewDataFolder /O $IR3HB_AttrTempFolder
	SetDataFolder $IR3HB_AttrTempFolder
	KillWaves /Z tmpAttrW, tmpAttrTxt
	variable L = strlen(valueStr)
	variable isArray = (L >= 2 && cmpstr(valueStr[0, 0], "[") == 0 && cmpstr(valueStr[L - 1, L - 1], "]") == 0)
	if (isArray)
		string inner = valueStr[1, L - 2]
		variable nVals = ItemsInList(inner, ",")
		variable allNumeric = 1
		variable k
		string tok
		for (k = 0; k < nVals; k += 1)
			tok = StringFromList(k, inner, ",")
			if (numtype(str2num(tok)) != 0)
				allNumeric = 0
				break
			endif
		endfor
		if (allNumeric)
			Make /O /D /N=(nVals) tmpAttrW
			for (k = 0; k < nVals; k += 1)
				tmpAttrW[k] = str2num(StringFromList(k, inner, ","))
			endfor
			HDF5SaveData /A=attrName /Q /Z tmpAttrW, fileID, hdfPath
		else
			Make /O /T /N=(nVals) tmpAttrTxt
			for (k = 0; k < nVals; k += 1)
				tmpAttrTxt[k] = StringFromList(k, inner, ",")
			endfor
			HDF5SaveData /A=attrName /Q /Z tmpAttrTxt, fileID, hdfPath
		endif
	else
		variable v = str2num(valueStr)
		if (numtype(v) == 0 && strlen(valueStr) > 0)
			Make /O /D /N=1 tmpAttrW
			tmpAttrW[0] = v
			HDF5SaveData /A=attrName /Q /Z tmpAttrW, fileID, hdfPath
		else
			Make /O /T /N=1 tmpAttrTxt
			tmpAttrTxt[0] = valueStr
			HDF5SaveData /A=attrName /Q /Z tmpAttrTxt, fileID, hdfPath
		endif
	endif
	KillWaves /Z tmpAttrW, tmpAttrTxt
	SetDataFolder saveDF
	return 0
End

//---------------------------------------------------------------------------
// Folder sidecar wave (Igor___folder_attributes)
//---------------------------------------------------------------------------

static Function IR3HB_HDF5AttrsToFolderSidecar(fileID, hdfPath, igorFolderPath)
	variable fileID
	string hdfPath, igorFolderPath
	string noteStr = IR3HB_HDF5AttrsToNoteString(fileID, hdfPath, 1)
	if (strlen(noteStr) == 0)
		return 0
	endif
	if (!DataFolderExists(igorFolderPath))
		return 0
	endif
	DFREF saveDF = GetDataFolderDFR()
	SetDataFolder $igorFolderPath
	Make /O /T /N=1 $IR3HB_FolderSidecarName
	WAVE /T sidecar = $IR3HB_FolderSidecarName
	sidecar[0] = ""
	Note /K sidecar
	Note sidecar, noteStr
	SetDataFolder saveDF
	return 1
End

static Function IR3HB_FolderSidecarToHDF5Attrs(igorFolderPath, fileID, hdfPath)
	string igorFolderPath
	variable fileID
	string hdfPath
	string sidecarPath = IR3HB_IgorJoinPath(igorFolderPath, IR3HB_FolderSidecarName)
	WAVE /Z /T sidecar = $sidecarPath
	if (!WaveExists(sidecar))
		return 0
	endif
	string noteStr = note(sidecar)
	if (strlen(noteStr) == 0)
		return 0
	endif
	IR3HB_NoteStringToHDF5Attrs(noteStr, fileID, hdfPath, 1)
	return 1
End

//---------------------------------------------------------------------------
// Path helpers used by the recursive walkers
//---------------------------------------------------------------------------

// Relative HDF5 path of subPath under rootPath. ("/a/b", "/a/b/c/d") -> "c/d"
static Function/S IR3HB_HDF5RelativePath(rootPath, subPath)
	string rootPath, subPath
	if (cmpstr(rootPath, "/") == 0)
		if (strlen(subPath) > 0 && cmpstr(subPath[0, 0], "/") == 0)
			return subPath[1, inf]
		endif
		return subPath
	endif
	variable rootLen = strlen(rootPath)
	if (strlen(subPath) > rootLen && cmpstr(subPath[0, rootLen - 1], rootPath) == 0)
		return subPath[rootLen + 1, inf]
	endif
	return subPath
End

// Convert HDF5 relative path "a/b/c" to Igor full path under igorRoot
static Function/S IR3HB_HDF5RelToIgor(igorRoot, hdfRel)
	string igorRoot, hdfRel
	string igorRel = ReplaceString("/", hdfRel, ":")
	return IR3HB_IgorJoinPath(igorRoot, igorRel)
End

//---------------------------------------------------------------------------
// HDF5 -> HDF5: copy attrs at every node in a subtree
//---------------------------------------------------------------------------

static Function IR3HB_HDF5CopyOneAttrSet(srcFileID, srcPath, srcType, dstFileID, dstPath, dstType)
	variable srcFileID, srcType, dstFileID, dstType
	string srcPath, dstPath
	HDF5ListAttributes /TYPE=(srcType) /Z srcFileID, srcPath
	if (V_Flag != 0)
		return 0
	endif
	string attrList = S_HDF5ListAttributes
	variable n = ItemsInList(attrList)
	if (n == 0)
		return 0
	endif
	DFREF saveDF = GetDataFolderDFR()
	NewDataFolder /O $IR3HB_AttrTempFolder
	SetDataFolder $IR3HB_AttrTempFolder
	variable i
	string attrName
	for (i = 0; i < n; i += 1)
		attrName = StringFromList(i, attrList)
		KillWaves /Z tmpCopyAttr
		HDF5LoadData /A=attrName /O /Q /Z /N=tmpCopyAttr /TYPE=(srcType) srcFileID, srcPath
		if (V_Flag != 0)
			continue
		endif
		WAVE /Z tmpCopyAttr = $(IR3HB_AttrTempFolder + ":tmpCopyAttr")
		if (!WaveExists(tmpCopyAttr))
			continue
		endif
		HDF5SaveData /A=attrName /Q /Z tmpCopyAttr, dstFileID, dstPath
	endfor
	KillWaves /Z $(IR3HB_AttrTempFolder + ":tmpCopyAttr")
	SetDataFolder saveDF
	return 0
End

static Function IR3HB_HDF5CopyAttrsRecursive(srcFileID, srcPath, dstFileID, dstPath)
	variable srcFileID, dstFileID
	string srcPath, dstPath
	IR3HB_HDF5CopyOneAttrSet(srcFileID, srcPath, 1, dstFileID, dstPath, 1)
	HDF5ListGroup /F /R=2 /TYPE=1 /Z srcFileID, srcPath
	string allSubGroups = SelectString(V_Flag == 0, "", S_HDF5ListGroup)
	variable nSub = ItemsInList(allSubGroups)
	variable i, j
	string srcSubPath, relPath, dstSubPath, groupPath, datasetList, dsName, srcDsPath, dstDsPath
	for (i = 0; i < nSub; i += 1)
		srcSubPath = StringFromList(i, allSubGroups)
		relPath = IR3HB_HDF5RelativePath(srcPath, srcSubPath)
		dstSubPath = IR3HB_HDF5JoinPath(dstPath, relPath)
		IR3HB_HDF5CopyOneAttrSet(srcFileID, srcSubPath, 1, dstFileID, dstSubPath, 1)
	endfor
	string allGroups = srcPath + ";" + allSubGroups
	variable nG = ItemsInList(allGroups)
	for (i = 0; i < nG; i += 1)
		groupPath = StringFromList(i, allGroups)
		HDF5ListGroup /TYPE=2 /Z srcFileID, groupPath
		if (V_Flag != 0)
			continue
		endif
		datasetList = S_HDF5ListGroup
		variable nDs = ItemsInList(datasetList)
		for (j = 0; j < nDs; j += 1)
			dsName = StringFromList(j, datasetList)
			srcDsPath = IR3HB_HDF5JoinPath(groupPath, dsName)
			relPath = IR3HB_HDF5RelativePath(srcPath, srcDsPath)
			dstDsPath = IR3HB_HDF5JoinPath(dstPath, relPath)
			IR3HB_HDF5CopyOneAttrSet(srcFileID, srcDsPath, 2, dstFileID, dstDsPath, 2)
		endfor
	endfor
	return 0
End

//---------------------------------------------------------------------------
// HDF5 -> Igor: walk source tree, attach attrs as Igor wave notes / sidecars
//---------------------------------------------------------------------------

static Function IR3HB_HDF5TreeToIgorAttrsRecursive(srcFileID, srcHdfPath, igorRootPath)
	variable srcFileID
	string srcHdfPath, igorRootPath
	IR3HB_HDF5AttrsToFolderSidecar(srcFileID, srcHdfPath, igorRootPath)
	HDF5ListGroup /F /R=2 /TYPE=1 /Z srcFileID, srcHdfPath
	string allSubGroups = SelectString(V_Flag == 0, "", S_HDF5ListGroup)
	variable nSub = ItemsInList(allSubGroups)
	variable i, j
	string srcSubHdfPath, relPath, igorSubFolderPath, groupHdfPath, datasetList, dsName, srcDsHdfPath, igorWavePath, dsNoteStr
	for (i = 0; i < nSub; i += 1)
		srcSubHdfPath = StringFromList(i, allSubGroups)
		relPath = IR3HB_HDF5RelativePath(srcHdfPath, srcSubHdfPath)
		igorSubFolderPath = IR3HB_HDF5RelToIgor(igorRootPath, relPath)
		IR3HB_HDF5AttrsToFolderSidecar(srcFileID, srcSubHdfPath, igorSubFolderPath)
	endfor
	string allGroups = srcHdfPath + ";" + allSubGroups
	variable nG = ItemsInList(allGroups)
	for (i = 0; i < nG; i += 1)
		groupHdfPath = StringFromList(i, allGroups)
		HDF5ListGroup /TYPE=2 /Z srcFileID, groupHdfPath
		if (V_Flag != 0)
			continue
		endif
		datasetList = S_HDF5ListGroup
		variable nDs = ItemsInList(datasetList)
		for (j = 0; j < nDs; j += 1)
			dsName = StringFromList(j, datasetList)
			srcDsHdfPath = IR3HB_HDF5JoinPath(groupHdfPath, dsName)
			relPath = IR3HB_HDF5RelativePath(srcHdfPath, srcDsHdfPath)
			igorWavePath = IR3HB_HDF5RelToIgor(igorRootPath, relPath)
			WAVE /Z wv = $igorWavePath
			if (!WaveExists(wv))
				continue
			endif
			dsNoteStr = IR3HB_HDF5AttrsToNoteString(srcFileID, srcDsHdfPath, 2)
			if (strlen(dsNoteStr) > 0)
				Note /K wv
				Note wv, dsNoteStr
			endif
		endfor
	endfor
	return 0
End

//---------------------------------------------------------------------------
// Igor -> HDF5: walk Igor tree, write notes/sidecars as HDF5 attrs
//---------------------------------------------------------------------------

static Function IR3HB_IgorTreeToHDF5AttrsRecursive(igorRootPath, fileID, hdfRootPath)
	string igorRootPath
	variable fileID
	string hdfRootPath
	IR3HB_WalkIgorFolderForAttrs(igorRootPath, fileID, hdfRootPath)
	return 0
End

static Function IR3HB_WalkIgorFolderForAttrs(igorPath, fileID, hdfPath)
	string igorPath
	variable fileID
	string hdfPath
	DFREF dfr = $igorPath
	if (!DataFolderRefStatus(dfr))
		return 0
	endif
	IR3HB_FolderSidecarToHDF5Attrs(igorPath, fileID, hdfPath)
	variable nW = CountObjectsDFR(dfr, 1)
	variable i
	string wname, wpath, dsHdfPath, noteStr, fname, subIgor, subHdf
	for (i = 0; i < nW; i += 1)
		wname = GetIndexedObjNameDFR(dfr, 1, i)
		if (cmpstr(wname, IR3HB_FolderSidecarName) == 0)
			continue
		endif
		wpath = IR3HB_IgorJoinPath(igorPath, wname)
		WAVE /Z wv = $wpath
		if (!WaveExists(wv))
			continue
		endif
		noteStr = note(wv)
		if (strlen(noteStr) == 0)
			continue
		endif
		dsHdfPath = IR3HB_HDF5JoinPath(hdfPath, wname)
		IR3HB_NoteStringToHDF5Attrs(noteStr, fileID, dsHdfPath, 2)
	endfor
	variable nF = CountObjectsDFR(dfr, 4)
	for (i = 0; i < nF; i += 1)
		fname = GetIndexedObjNameDFR(dfr, 4, i)
		subIgor = IR3HB_IgorJoinPath(igorPath, fname)
		subHdf  = IR3HB_HDF5JoinPath(hdfPath, fname)
		IR3HB_WalkIgorFolderForAttrs(subIgor, fileID, subHdf)
	endfor
	return 0
End

//---------------------------------------------------------------------------
// Show Igor wave note / folder sidecar in the attribute pane
//---------------------------------------------------------------------------

static Function IR3HB_FillAttrListFromIgor(igorPath, kind)
	string igorPath, kind
	string noteStr = ""
	if (cmpstr(kind, "D") == 0)
		WAVE /Z wv = $igorPath
		if (WaveExists(wv))
			noteStr = note(wv)
		endif
	elseif (cmpstr(kind, "G") == 0)
		string sidecarPath = IR3HB_IgorJoinPath(igorPath, IR3HB_FolderSidecarName)
		WAVE /Z /T sidecar = $sidecarPath
		if (WaveExists(sidecar))
			noteStr = note(sidecar)
		endif
	endif
	IR3HB_FillAttrListFromString(noteStr)
End

static Function IR3HB_FillAttrListFromString(noteStr)
	string noteStr
	WAVE/T attrListWave = $(IR3HB_PkgPath + ":AttrListWave")
	WAVE   attrSelWave  = $(IR3HB_PkgPath + ":AttrSelWave")
	Redimension /N=(0, 2) attrListWave
	Redimension /N=(0, 1) attrSelWave
	if (strlen(noteStr) == 0)
		return 0
	endif
	variable nItems = ItemsInList(noteStr, ";")
	variable validPairs = 0
	variable i, equalPos
	string item
	for (i = 0; i < nItems; i += 1)
		item = StringFromList(i, noteStr, ";")
		if (strlen(item) == 0)
			continue
		endif
		equalPos = strsearch(item, "=", 0)
		if (equalPos > 0)
			validPairs += 1
		endif
	endfor
	if (validPairs == 0)
		// Free-text wave note - show as single row
		Redimension /N=(1, 2) attrListWave
		Redimension /N=(1, 1) attrSelWave
		attrListWave[0][0] = "(note)"
		attrListWave[0][1] = noteStr
		return 0
	endif
	Redimension /N=(validPairs, 2) attrListWave
	Redimension /N=(validPairs, 1) attrSelWave
	variable row = 0
	for (i = 0; i < nItems; i += 1)
		item = StringFromList(i, noteStr, ";")
		if (strlen(item) == 0)
			continue
		endif
		equalPos = strsearch(item, "=", 0)
		if (equalPos <= 0)
			continue
		endif
		attrListWave[row][0] = item[0, equalPos - 1]
		attrListWave[row][1] = item[equalPos + 1, inf]
		row += 1
	endfor
	return 0
End

//============================================================================
// DRAG AND DROP (Phase 5)
//
// Adapted from the Wavemetrics canonical pattern
// (https://www.wavemetrics.com/code-snippet/listbox-drag-drop) and the
// in-house IN3_SamplePlate.ipf implementation. The visual "ghost" of the
// dragged item is a TitleBox control that follows the mouse during a
// synchronous GetMouse poll inside the mousedown handler.
//
// Semantics:
//   Drag within the same pane  -> MOVE (copy + delete source)
//   Drag across panes          -> COPY (existing copy logic)
//   Drop on the same row       -> no-op (treated as a click)
//   Drop on a leaf             -> use that leaf's parent as target
//   Drop on a group/folder     -> drop INTO that group/folder
//   Drop into own descendant   -> refused (would be cyclical)
//
// Drag is initiated only on left-click of column 1 (the name column);
// column 0 [+]/[-] clicks remain dedicated to expand-toggle.
//============================================================================

Constant IR3HB_DragThresholdPx = 4   // mouse movement before drag visual starts

static Function IR3HB_PointInControl(mouseLoc, win, ctrlName)
	STRUCT point &mouseLoc
	string win, ctrlName
	ControlInfo /W=$win $ctrlName
	if (V_Flag == 0)
		return 0
	endif
	variable f = 72 / PanelResolution(win)
	variable hpoint = mouseLoc.h * f
	variable vpoint = mouseLoc.v * f
	return (hpoint > V_left && hpoint < V_right && vpoint > V_top && vpoint < (V_top + V_height))
End

// Identify which tree listbox the mouse is over; returns "Left" / "Right" / ""
static Function/S IR3HB_DropTargetSide(mouseLoc, win)
	STRUCT point &mouseLoc
	string win
	if (IR3HB_PointInControl(mouseLoc, win, "LeftTreeListBox"))
		return "Left"
	endif
	if (IR3HB_PointInControl(mouseLoc, win, "RightTreeListBox"))
		return "Right"
	endif
	return ""
End

// Compute which visible row of a tree listbox the mouse is over.
// Returns the computed row (may be negative or >= row count); the caller
// validates against the actual visible-rows wave.
// Units match IN3S_DragDropListBoxProc:
//   mouseLoc.v is in pixels, V_top is in points, V_rowHeight is in pixels.
//   (V_top / f) converts V_top to pixels so the subtraction makes sense.
static Function IR3HB_DropTargetVisibleRow(mouseLoc, win, ctrlName)
	STRUCT point &mouseLoc
	string win, ctrlName
	ControlInfo /W=$win $ctrlName
	if (V_Flag == 0)
		return -1
	endif
	variable f = 72 / PanelResolution(win)
	return V_startRow + floor((mouseLoc.v - V_top / f) / V_rowHeight)
End

// Is hdfPathB a descendant of hdfPathA? (for refusing cyclical drops)
static Function IR3HB_PathIsDescendant(parentPath, candidatePath, sep)
	string parentPath, candidatePath, sep
	if (cmpstr(parentPath, candidatePath) == 0)
		return 1
	endif
	variable pL = strlen(parentPath)
	if (strlen(candidatePath) <= pL)
		return 0
	endif
	if (cmpstr(candidatePath[0, pL - 1], parentPath) != 0)
		return 0
	endif
	// Next char must be separator (avoid "/foo" matching "/foobar")
	return (cmpstr(candidatePath[pL, pL], sep) == 0)
End

//---------------------------------------------------------------------------
// Start drag: synchronous mouse loop with movement-threshold ghost
// Returns 1 if a drag was actually performed (visual started); 0 if click only.
// On real drag, sets userdata(drag)="started" so the subsequent mouseup
// event delivers the drop in IR3HB_HandleDrop.
//---------------------------------------------------------------------------

static Function IR3HB_StartDrag(side, lba)
	string side
	STRUCT WMListboxAction &lba
	DFREF dfr = $IR3HB_SidePath(side)
	WAVE visibleRows = dfr:VisibleRows
	if (lba.row < 0 || lba.row >= numpnts(visibleRows))
		return 0
	endif
	WAVE/T fullTreeText = dfr:FullTreeText
	variable srcFullIdx = visibleRows[lba.row]
	string srcName = fullTreeText[srcFullIdx][1]
	variable f = 72 / PanelResolution(lba.win)
	// Capture original mouse position for movement-threshold check
	variable startH = lba.mouseLoc.h
	variable startV = lba.mouseLoc.v
	// Capture current ListBox mode so we can restore it
	ControlInfo /W=$lba.win $lba.ctrlName
	string strMode, strFsize
	SplitString /E=("mode=\\s?([[:digit:]]+)") S_recreation, strMode
	variable modeOrig  = strlen(strMode)  ? str2num(strMode)  : 2
	SplitString /E=("fSize=\\s?([[:digit:]]+)") S_recreation, strFsize
	variable fontSize  = strlen(strFsize) ? str2num(strFsize) : 9
	// Ghost is created lazily once the mouse passes the movement threshold
	variable visualStarted = 0
	string ghostName = "IR3HB_DragGhost"
	string otherSide = SelectString(cmpstr(side, "Left") == 0, "Left", "Right")
	string otherCtrl = otherSide + "TreeListBox"
	variable buttondown = 1
	variable dx, dy
	do
		GetMouse /W=$lba.win
		buttondown = V_flag & 1
		if (!visualStarted)
			if (abs(V_left - startH) > IR3HB_DragThresholdPx || abs(V_top - startV) > IR3HB_DragThresholdPx)
				// Threshold passed - start the visual
				visualStarted = 1
				ListBox $lba.ctrlName, win=$lba.win, userdata(drag)="started", mode=0
				variable height = f * (V_rowHeight - 1)
				variable width  = f * (lba.ctrlRect.right - lba.ctrlRect.left)
				variable top    = f * (lba.ctrlRect.top + (lba.row - V_startRow) * V_rowHeight + 1.5)
				variable left   = f * lba.ctrlRect.left
				string strTitle
				sprintf strTitle, "\\sa%+03d\\x%+03d %s", 3 - (fontSize > 12), (20 - fontSize) * 0.625, srcName
				TitleBox $ghostName, win=$lba.win, title=strTitle, labelBack=(41760, 52715, 65482), pos={left, top}
				TitleBox $ghostName, win=$lba.win, fsize=fontSize, fixedSize=1, frame=0, size={width, height}
				lba.mouseLoc.h = V_left
				lba.mouseLoc.v = V_top
			endif
		endif
		if (visualStarted)
			dx = V_left - lba.mouseLoc.h
			dy = V_top  - lba.mouseLoc.v
			lba.mouseLoc.h = V_left
			lba.mouseLoc.v = V_top
			TitleBox /Z $ghostName, win=$lba.win, pos+={dx, dy}
			// Highlight the listbox under the mouse with a focus ring
			STRUCT point currentMouse
			currentMouse.h = V_left
			currentMouse.v = V_top
			string targetSide = IR3HB_DropTargetSide(currentMouse, lba.win)
			ListBox LeftTreeListBox,  win=$lba.win, focusRing=(cmpstr(targetSide, "Left")  == 0 ? 1 : 0)
			ListBox RightTreeListBox, win=$lba.win, focusRing=(cmpstr(targetSide, "Right") == 0 ? 1 : 0)
			DoUpdate /W=$lba.win
		endif
	while (buttondown)
	if (visualStarted)
		KillControl /W=$lba.win $ghostName
		ListBox LeftTreeListBox,  win=$lba.win, focusRing=0
		ListBox RightTreeListBox, win=$lba.win, focusRing=0
		ListBox $lba.ctrlName, win=$lba.win, mode=modeOrig
		// Use the FINAL polled mouse position (V_left/V_top from the last
		// GetMouse) as the drop point. The mouseup event Igor delivers after
		// this function returns carries stale mouseLoc, so don't rely on it.
		STRUCT point dropPoint
		dropPoint.h = V_left
		dropPoint.v = V_top
		IR3HB_HandleDrop(side, lba, dropPoint)
	endif
	return visualStarted
End

//---------------------------------------------------------------------------
// Handle drop: dispatched from IR3HB_ListBoxProc on the mouseup event
// that follows a drag.
//---------------------------------------------------------------------------

static Function IR3HB_HandleDrop(srcSide, lba, dropPoint)
	string srcSide
	STRUCT WMListboxAction &lba
	STRUCT point &dropPoint
	DFREF srcDfr = $IR3HB_SidePath(srcSide)
	SVAR srcType = srcDfr:SourceType
	NVAR srcSelectedIdx = srcDfr:SelectedFullTreeIdx
	if (srcSelectedIdx < 0 || strlen(srcType) == 0)
		return 0
	endif
	WAVE/T srcFullText = srcDfr:FullTreeText
	string srcPath = srcFullText[srcSelectedIdx][0]
	string srcKind = srcFullText[srcSelectedIdx][2]
	string srcName = IR3HB_PathBaseName(srcPath, srcType)
	// Where did the drop land?
	string dstSide = IR3HB_DropTargetSide(dropPoint, lba.win)
	if (strlen(dstSide) == 0)
		return 0
	endif
	DFREF dstDfr = $IR3HB_SidePath(dstSide)
	SVAR dstType = dstDfr:SourceType
	if (strlen(dstType) == 0)
		Print "HDF5 Browser: drop ignored - destination pane has no source loaded"
		return 0
	endif
	// Figure out the target row in the destination listbox
	string dstCtrl = dstSide + "TreeListBox"
	variable dstVisRow = IR3HB_DropTargetVisibleRow(dropPoint, lba.win, dstCtrl)
	WAVE dstVisibleRows = dstDfr:VisibleRows
	WAVE/T dstFullText  = dstDfr:FullTreeText
	string dstParentPath
	string dstSelKind = ""
	string dstSelPath = ""
	if (dstVisRow < 0 || dstVisRow >= numpnts(dstVisibleRows))
		// Dropped past the last row - treat as drop at root
		dstParentPath = SelectString(cmpstr(dstType, "HDF5") == 0, "root:", "/")
	else
		variable dstFullIdx = dstVisibleRows[dstVisRow]
		dstSelPath = dstFullText[dstFullIdx][0]
		dstSelKind = dstFullText[dstFullIdx][2]
		if (cmpstr(dstSelKind, "G") == 0)
			dstParentPath = dstSelPath
		else
			dstParentPath = SelectString(cmpstr(dstType, "HDF5") == 0, IR3HB_GetIgorParentPath(dstSelPath), IR3HB_GetHDF5ParentPath(dstSelPath))
		endif
	endif
	// Same-pane / same-source / same-path = no-op (click-like)
	variable sameSide = (cmpstr(srcSide, dstSide) == 0)
	if (sameSide && cmpstr(srcType, dstType) == 0)
		string sep = SelectString(cmpstr(srcType, "HDF5") == 0, ":", "/")
		string wouldBePath = SelectString(cmpstr(srcType, "HDF5") == 0, IR3HB_IgorJoinPath(dstParentPath, srcName), IR3HB_HDF5JoinPath(dstParentPath, srcName))
		if (cmpstr(srcPath, wouldBePath) == 0)
			// Dropped at exactly the same place - no-op
			return 0
		endif
		// Refuse drop into own descendant
		if (IR3HB_PathIsDescendant(srcPath, dstParentPath, sep))
			DoAlert /T="HDF5 Browser" 0, "Cannot move an item into one of its own descendants."
			return 0
		endif
	endif
	// Read-only HDF5 destination guard (mirrors IR3HB_CopyItem behavior)
	if (cmpstr(dstType, "HDF5") == 0)
		NVAR dstReadOnly = dstDfr:IsReadOnly
		if (dstReadOnly)
			DoAlert /T="HDF5 Browser" 0, "Destination HDF5 file is open READ-ONLY. Reopen with write access to copy/move into it."
			return 0
		endif
	endif
	// Dispatch directly to the per-direction copy function with explicit src/dst
	// values. Going through IR3HB_CopyItem would re-read SelectedFullTreeIdx from
	// globals and, for same-pane drops, see the destination index (since src/dst
	// share the same data folder when sameSide).
	variable copied = 0
	string mode = srcType + "->" + dstType
	strswitch (mode)
		case "HDF5->HDF5":
			copied = IR3HB_CopyHDF5toHDF5(srcDfr, srcPath, srcKind, srcName, dstDfr, dstParentPath)
			break
		case "HDF5->Igor":
			copied = IR3HB_CopyHDF5toIgor(srcDfr, srcPath, srcKind, srcName, dstParentPath)
			break
		case "Igor->HDF5":
			copied = IR3HB_CopyIgorToHDF5(srcPath, srcKind, srcName, dstDfr, dstParentPath)
			break
		case "Igor->Igor":
			copied = IR3HB_CopyIgorToIgor(srcPath, srcKind, srcName, dstParentPath)
			break
	endswitch
	if (!copied)
		Printf "HDF5 Browser: drop of '%s' (%s -> %s) failed\r", srcPath, srcType, dstType
		return 0
	endif
	Printf "HDF5 Browser: %s '%s' (%s) -> %s pane at %s\r", SelectString(sameSide, "copied", "moved"), srcPath, srcKind, dstSide, dstParentPath
	IR3HB_RefreshTree(dstSide)
	// Same-pane = MOVE: delete source after successful copy
	if (sameSide)
		// Re-locate source by path (tree may have been refreshed) and delete it
		srcSelectedIdx = IR3HB_FindFullTreeIdxByPath(srcSide, srcPath)
		if (srcSelectedIdx >= 0)
			IR3HB_DeleteSelectedSilent(srcSide)
		endif
	endif
	return 1
End

// Like IR3HB_DeleteSelected but skips the confirmation dialog (drag-drop move)
static Function IR3HB_DeleteSelectedSilent(side)
	string side
	DFREF dfr = $IR3HB_SidePath(side)
	SVAR srcType = dfr:SourceType
	if (strlen(srcType) == 0)
		return 0
	endif
	if (cmpstr(srcType, "HDF5") == 0)
		NVAR isReadOnly = dfr:IsReadOnly
		if (isReadOnly)
			return 0
		endif
	endif
	variable idx = IR3HB_GetSelectedFullTreeIdx(side)
	if (idx < 0)
		return 0
	endif
	WAVE/T fullTreeText = dfr:FullTreeText
	string itemPath = fullTreeText[idx][0]
	string itemKind = fullTreeText[idx][2]
	if (cmpstr(srcType, "HDF5") == 0 && cmpstr(itemPath, "/") == 0)
		return 0
	endif
	if (cmpstr(srcType, "Igor") == 0 && cmpstr(itemPath, "root:") == 0)
		return 0
	endif
	variable ok = 0
	if (cmpstr(srcType, "HDF5") == 0)
		NVAR fileID = dfr:FileID
		HDF5UnlinkObject /Z fileID, itemPath
		ok = (V_Flag == 0)
	else
		ok = IR3HB_DeleteIgorItem(itemPath, itemKind)
	endif
	if (ok)
		Printf "HDF5 Browser: moved (deleted source) '%s' from %s pane\r", itemPath, side
		NVAR selectedIdx = dfr:SelectedFullTreeIdx
		selectedIdx = -1
		IR3HB_RefreshTree(side)
	endif
	return ok
End

// Look up a path's full-tree index after a tree rebuild
static Function IR3HB_FindFullTreeIdxByPath(side, path)
	string side, path
	DFREF dfr = $IR3HB_SidePath(side)
	WAVE/T fullTreeText = dfr:FullTreeText
	variable n = DimSize(fullTreeText, 0)
	variable i
	for (i = 0; i < n; i += 1)
		if (cmpstr(fullTreeText[i][0], path) == 0)
			return i
		endif
	endfor
	return -1
End

//============================================================================
// CONTROL PROCS
//============================================================================

Function IR3HB_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	if (ba.eventCode != 2)
		return 0
	endif
	strswitch (ba.ctrlName)
		case "OpenLeft":
			IR3HB_OpenFile("Left")
			break
		case "IgorLeft":
			IR3HB_ShowIgor("Left")
			break
		case "CloseLeft":
			IR3HB_CloseFile("Left")
			break
		case "OpenRight":
			IR3HB_OpenFile("Right")
			break
		case "IgorRight":
			IR3HB_ShowIgor("Right")
			break
		case "CloseRight":
			IR3HB_CloseFile("Right")
			break
		case "CopyLR":
			IR3HB_CopyItem("Left", "Right")
			break
		case "CopyRL":
			IR3HB_CopyItem("Right", "Left")
			break
		case "GetHelp":
			IR3HB_OpenHelpPage()
			break
	endswitch
	return 0
End

static Function IR3HB_OpenHelpPage()
	BrowseURL "https://saxs-igorcodedocs.readthedocs.io/en/latest/Irena/HDF5Browser.html"
End

Function IR3HB_ListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba
	string side = IR3HB_SideFromCtrl(lba.ctrlName)
	if (strlen(side) == 0)
		return 0
	endif
	variable dragStarted = strlen(GetUserData(lba.win, lba.ctrlName, "drag")) > 0
	// Mouseup that arrives after a drag: drop already happened inside StartDrag's
	// mouse loop using live GetMouse coords; just consume this stale event.
	if (lba.eventCode == 2 && dragStarted)
		ListBox $lba.ctrlName, win=$lba.win, userdata(drag)=""
		return 0
	endif
	// Right-click (eventMod bit 4 / value 16) on mouse-down -> contextual menu
	if (lba.eventCode == 1 && (lba.eventMod & 0x10))
		IR3HB_HandleRightClick(side, lba.row)
		return 0
	endif
	// Mousedown on column 1 of a real row -> may start a drag (movement-thresholded)
	if (lba.eventCode == 1 && !dragStarted && lba.col == 1)
		DFREF dfrCheck = $IR3HB_SidePath(side)
		WAVE visRowsCheck = dfrCheck:VisibleRows
		if (lba.row >= 0 && lba.row < numpnts(visRowsCheck))
			// Update selection BEFORE the synchronous drag loop so the value pane
			// reflects what the user is dragging
			IR3HB_OnSelect(side, lba.row)
			IR3HB_StartDrag(side, lba)
			// If StartDrag set userdata(drag), the upcoming mouseup-event 2 will
			// hit the drop handler above. If not (movement < threshold), fall
			// through to normal mouseup handling below.
		endif
		return 0
	endif
	// Otherwise only handle mouseup (event 2) for selection / expand-toggle
	if (lba.eventCode != 2)
		return 0
	endif
	DFREF dfr = $IR3HB_SidePath(side)
	WAVE visibleRows = dfr:VisibleRows
	if (lba.row < 0 || lba.row >= numpnts(visibleRows))
		return 0
	endif
	variable fullTreeIdx = visibleRows[lba.row]
	WAVE/T fullTreeText = dfr:FullTreeText
	WAVE   fullTreeMeta = dfr:FullTreeMeta
	string rowKind = fullTreeText[fullTreeIdx][2]
	variable rowHasChildren = fullTreeMeta[fullTreeIdx][2]
	// Always update selection / value display
	IR3HB_OnSelect(side, lba.row)
	// If user clicked the marker column on a group with children, also toggle
	if (lba.col == 0 && cmpstr(rowKind, "G") == 0 && rowHasChildren)
		IR3HB_ToggleExpand(side, fullTreeIdx)
	endif
	return 0
End

Function IR3HB_WindowHook(s)
	STRUCT WMWinHookStruct &s
	if (s.eventCode == 2)
		// Window being killed - close any open files cleanly
		IR3HB_CloseFile("Left")
		IR3HB_CloseFile("Right")
	endif
	return 0
End
