#pragma rtGlobals=3		// Use modern global access method and strict wave access
#pragma version=1.00
#pragma IgorVersion = 9.04

//*************************************************************************\
//* Copyright (c) 2005 - 2026, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution.
//*************************************************************************/

// IR3_ImportData.ipf
// Combined SAXS / WAXS / Nexus CanSAS data import tool.
// This package merges the functionality of the three separate import panels
// (IR1I_ImportSASASCIIDataMain, IR1I_ImportOtherASCIIMain, IR1I_ImportNexusCanSASMain)
// into a single unified panel.  All processing logic is delegated to the
// existing functions in IR1_ImportData.ipf and IRNI_NexusSupport.ipf so
// that those tools remain fully functional without modification.
//
// Entry point:  IR3I_ImportDataMain()
//
// Version history:
// 1.00  Initial combined import panel.

Constant IR3IversionNumber = 1.00

//************************************************************************************************************
//************************************************************************************************************
//  Main entry point called from the Irena SAS menu.
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_ImportDataMain()

	// If the old separate panels are open they share the same globals, so
	// we must close them to avoid conflicts.
	DoWindow IR1I_ImportData
	if(V_Flag)
		DoAlert/T="Window conflict" 1, "The ASCII SAS import panel is open and uses the same data space. Close it (Yes) or cancel (No)?"
		if(V_flag == 1)
			KillWindow/Z IR1I_ImportData
		else
			abort
		endif
	endif
	DoWindow IR1I_ImportOtherASCIIData
	if(V_Flag)
		DoAlert/T="Window conflict" 1, "The ASCII non-SAS import panel is open and uses the same data space. Close it (Yes) or cancel (No)?"
		if(V_flag == 1)
			KillWindow/Z IR1I_ImportOtherASCIIData
		else
			abort
		endif
	endif
	DoWindow IR1I_ImportNexusCanSASData
	if(V_Flag)
		DoAlert/T="Window conflict" 1, "The Nexus import panel is open and uses the same data space. Close it (Yes) or cancel (No)?"
		if(V_flag == 1)
			KillWindow/Z IR1I_ImportNexusCanSASData
		else
			abort
		endif
	endif

	KillWindow/Z IR3I_ImportData
	IR3I_InitializeImportData()
	Execute("IR3I_ImportDataPanel()")
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("IR3I_ImportData", IR3IversionNumber, 1)
	IR3I_UpdateFormatUI()
	IR1I_FIxCheckboxesForWaveTypes()

End

//************************************************************************************************************
//************************************************************************************************************
//  Version check – called from AfterCompiledHook or similar.
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_MainCheckVersion()

	DoWindow IR3I_ImportData
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR3I_ImportData", IR3IversionNumber))
			DoAlert/T="Panel version mismatch" 1, "The combined import panel may need to be restarted. Restart now?"
			if(V_flag == 1)
				IR3I_ImportDataMain()
			else
				IR3I_InitializeImportData()
			endif
		endif
	endif

End

//************************************************************************************************************
//************************************************************************************************************
//  Initialization – extends the existing IR1I package globals with the
//  one new global (DataFormatType) required by this combined panel.
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_InitializeImportData()

	// Reuse the existing initializer so all shared globals are created.
	IR1I_InitializeImportData()

	// Add the one new global that is unique to the combined panel.
	setDataFolder root:Packages:ImportData
	IN2G_CreateItem("string", "DataFormatType")
	SVAR DataFormatType = root:Packages:ImportData:DataFormatType
	if(strlen(DataFormatType) < 2)
		DataFormatType = "ASCII SAXS/SANS"
	endif

	// SAXSData / WAXSData radio choice (mirrors bioSAXS importer pattern).
	IN2G_CreateItem("variable", "SAXSData")
	IN2G_CreateItem("variable", "WAXSData")
	NVAR SAXSData = root:Packages:ImportData:SAXSData
	NVAR WAXSData = root:Packages:ImportData:WAXSData
	if((SAXSData + WAXSData) != 1)
		SAXSData = 1
		WAXSData = 0
	endif

	setDataFolder root:

End

//************************************************************************************************************
//************************************************************************************************************
//  Panel definition.
//  Layout follows the bioSAXS-style design from GUI.jpg:
//    Left  (x=5–225)   : file list managed by IR3C_AddDataControls
//    Right (x=230–420) : data format selector and format-specific controls
//    Bottom (y=622+)   : common processing options, naming options, import button
//************************************************************************************************************
//************************************************************************************************************
Proc IR3I_ImportDataPanel()

	PauseUpdate	// building window …

	NewPanel/K=1/W=(3, 40, 430, 760)/N=IR3I_ImportData as "Import SAXS/WAXS/Nexus Data"

	// ── Title ───────────────────────────────────────────────────────────────
	TitleBox MainTitle, title="\Zr200Import SAXS / WAXS / Nexus Data in Igor", pos={20, 5}, frame=0, fstyle=3
	TitleBox MainTitle, fixedSize=1, font="Times New Roman", size={400, 24}, anchor=MC, fColor=(0, 0, 52224)
	TitleBox FakeLine1, title=" ", fixedSize=1, size={330, 3}, pos={16, 40}, frame=0, fColor=(0, 0, 52224), labelBack=(0, 0, 52224)

	// ── File selection (IR3C_AddDataControls places: Select Data Path, data path
	//    display, match name, extension, sort popup, list box, Select All,
	//    Deselect All).  We override the list box size and button positions. ──
	IR3C_AddDataControls("ImportDataPath", "ImportData", "IR3I_ImportData", "", "", "", "IR3I_DoubleClickFnct")
	ListBox ListOfAvailableData, size={220, 477}, pos={5, 113}
	Button SelectAll, pos={5, 595}
	Button DeSelectAll, pos={120, 595}
	PopupMenu SortOptionString, pos={5, 90}

	// Get Help button (top-right corner)
	Button GetHelp, pos={335, 53}, size={80, 15}, fColor=(65535, 32768, 32768), proc=IR3I_ButtonProc, title="Get Help"
	Button GetHelp, help={"Open the online manual page for this tool"}

	// ── Section A: Data format and SAXS/WAXS selection ───────────────────────
	//    Always visible on the right side of the panel.

	TitleBox FormatTitle, title="\Zr140Data format & type", pos={230, 113}, frame=0, fstyle=1, fixedSize=1, size={185, 18}, fColor=(0, 0, 52224)

	PopupMenu DataFormatPopup, pos={230, 133}, size={185, 21}, proc=IR3I_PopMenuProc, title="Format:"
	PopupMenu DataFormatPopup, help={"Select the type of data file to import"}
	PopupMenu DataFormatPopup, mode=1, popvalue=root:Packages:ImportData:DataFormatType
	PopupMenu DataFormatPopup, value="ASCII SAXS/SANS;ASCII WAXS;Nexus CanSAS"

	CheckBox SAXSData, pos={230, 160}, size={16, 14}, proc=IR3I_CheckProc, title="SAXS data?", mode=1
	CheckBox SAXSData, variable=root:Packages:ImportData:SAXSData
	CheckBox SAXSData, help={"Select for SAXS data (Q-space). Default folder: root:SAS"}

	CheckBox WAXSData, pos={230, 178}, size={16, 14}, proc=IR3I_CheckProc, title="WAXS data?", mode=1
	CheckBox WAXSData, variable=root:Packages:ImportData:WAXSData
	CheckBox WAXSData, help={"Select for WAXS data (real space / 2-theta). Default folder: root:WAXS"}

	// WAXS data sub-type – only relevant for ASCII WAXS format
	PopupMenu ImportDataType, pos={230, 198}, size={185, 21}, proc=IR3I_PopMenuProc, title="X-axis:"
	PopupMenu ImportDataType, help={"For ASCII WAXS: choose what the X column represents"}
	PopupMenu ImportDataType, mode=1, popvalue=root:Packages:ImportData:DataTypeToImport
	PopupMenu ImportDataType, value=#"root:Packages:ImportData:ListOfKnownDataTypes"

	// Wavelength – only required when WAXS + Tth-Int is selected
	SetVariable Wavelength, pos={230, 222}, size={185, 19}, variable=root:Packages:ImportData:Wavelength, noproc
	SetVariable Wavelength, title="Wavelength [A]:", help={"Wavelength in Angstrom – required for 2-theta conversion"}

	// ── Section B: ASCII column mapping ──────────────────────────────────────
	//    Shown for ASCII SAXS/SANS and ASCII WAXS; hidden (disable=2) for Nexus.

	TitleBox ColMapTitle, title="\Zr140Column assignment", pos={230, 246}, frame=0, fstyle=1, fixedSize=1, size={185, 18}

	// Column header labels
	TitleBox ColHdrCol,  title="\Zr140Col",  pos={230, 266}, frame=0, fstyle=2, fixedSize=0, size={36, 15}
	TitleBox ColHdrQ,    title="\Zr150Q/X",  pos={275, 266}, frame=0, fstyle=2, fixedSize=0, size={36, 15}
	TitleBox ColHdrInt,  title="\Zr150Y",    pos={308, 266}, frame=0, fstyle=2, fixedSize=0, size={36, 15}
	TitleBox ColHdrErr,  title="\Zr150dY",   pos={340, 266}, frame=0, fstyle=2, fixedSize=0, size={36, 15}
	TitleBox ColHdrQErr, title="\Zr150dX",   pos={373, 266}, frame=0, fstyle=2, fixedSize=0, size={36, 15}

	// Row labels
	TitleBox Info21, title="\Zr140Col. 1", pos={230, 284}, frame=0, fstyle=2, fixedSize=1, size={44, 17}
	TitleBox Info22, title="\Zr140Col. 2", pos={230, 301}, frame=0, fstyle=2, fixedSize=1, size={44, 17}
	TitleBox Info23, title="\Zr140Col. 3", pos={230, 318}, frame=0, fstyle=2, fixedSize=1, size={44, 17}
	TitleBox Info24, title="\Zr140Col. 4", pos={230, 335}, frame=0, fstyle=2, fixedSize=1, size={44, 17}
	TitleBox Info25, title="\Zr140Col. 5", pos={230, 352}, frame=0, fstyle=2, fixedSize=1, size={44, 17}
	TitleBox Info26, title="\Zr140Col. 6", pos={230, 369}, frame=0, fstyle=2, fixedSize=1, size={44, 17}

	// Column checkboxes (Q/X, Y/Int, dY/Err, dX/QErr)
	CheckBox Col1Qvec,  pos={277, 284}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col1Qvec
	CheckBox Col1Int,   pos={310, 284}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col1Int
	CheckBox Col1Error, pos={342, 284}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col1Err
	CheckBox Col1QError,pos={375, 284}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col1QErr

	CheckBox Col2Qvec,  pos={277, 301}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col2Qvec
	CheckBox Col2Int,   pos={310, 301}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col2Int
	CheckBox Col2Error, pos={342, 301}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col2Err
	CheckBox Col2QError,pos={375, 301}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col2QErr

	CheckBox Col3Qvec,  pos={277, 318}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col3Qvec
	CheckBox Col3Int,   pos={310, 318}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col3Int
	CheckBox Col3Error, pos={342, 318}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col3Err
	CheckBox Col3QError,pos={375, 318}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col3QErr

	CheckBox Col4Qvec,  pos={277, 335}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col4Qvec
	CheckBox Col4Int,   pos={310, 335}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col4Int
	CheckBox Col4Error, pos={342, 335}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col4Err
	CheckBox Col4QError,pos={375, 335}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col4QErr

	CheckBox Col5Qvec,  pos={277, 352}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col5Qvec
	CheckBox Col5Int,   pos={310, 352}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col5Int
	CheckBox Col5Error, pos={342, 352}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col5Err
	CheckBox Col5QError,pos={375, 352}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col5QErr

	CheckBox Col6Qvec,  pos={277, 369}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col6Qvec
	CheckBox Col6Int,   pos={310, 369}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col6Int
	CheckBox Col6Error, pos={342, 369}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col6Err
	CheckBox Col6QError,pos={375, 369}, size={16, 14}, proc=IR3I_CheckProc, title="", variable=root:Packages:ImportData:Col6QErr

	// Found-columns display and action buttons
	SetVariable FoundNWaves, pos={230, 390}, size={185, 19}, title="Found columns:", proc=IR3I_SetVarProc
	SetVariable FoundNWaves, help={"Number of numeric columns found in the test file"}, disable=2
	SetVariable FoundNWaves, limits={0, Inf, 0}, value=root:Packages:ImportData:FoundNWaves

	Button TestImport, pos={230, 413}, size={58, 15}, proc=IR3I_ButtonProc, title="Test"
	Button TestImport, help={"Test-load the first selected file to detect columns"}
	Button Preview,    pos={295, 413}, size={58, 15}, proc=IR3I_ButtonProc, title="Preview"
	Button Preview,    help={"Open the first selected file in a notebook for inspection"}
	Button Plot,       pos={360, 413}, size={55, 15}, proc=IR3I_ButtonProc, title="Plot"
	Button Plot,       help={"Quick-plot the first selected file"}

	// ── Section C: Nexus-specific options ────────────────────────────────────
	//    Placed in the same y-range as Section B; shown/hidden via IR3I_UpdateFormatUI().
	//    These controls start invisible (disable=2) and are revealed for Nexus format.

	TitleBox NXTitle, title="\Zr140Nexus folder naming", pos={230, 246}, frame=0, fstyle=1, fixedSize=1, size={185, 18}, disable=2

	CheckBox UseFileNameAsFolderNX,      pos={230, 268}, size={16, 14}, proc=IR3I_CheckProc, mode=1, disable=2
	CheckBox UseFileNameAsFolderNX,      title="Use file name as folder name"
	CheckBox UseFileNameAsFolderNX,      variable=root:Packages:ImportData:UseFileNameAsFolder
	CheckBox UseFileNameAsFolderNX,      help={"Name the data folder after the HDF5 file name"}

	CheckBox UsesasEntryNameAsFolderNX,  pos={230, 286}, size={16, 14}, proc=IR3I_CheckProc, mode=1, disable=2
	CheckBox UsesasEntryNameAsFolderNX,  title="Use sasEntry name as folder"
	CheckBox UsesasEntryNameAsFolderNX,  variable=root:Packages:ImportData:UsesasEntryNameAsFolder
	CheckBox UsesasEntryNameAsFolderNX,  help={"Name the data folder after the NXcanSAS entry name"}

	CheckBox UseTitleNameAsFolderNX,     pos={230, 304}, size={16, 14}, proc=IR3I_CheckProc, mode=1, disable=2
	CheckBox UseTitleNameAsFolderNX,     title="Use sasTitle as folder name"
	CheckBox UseTitleNameAsFolderNX,     variable=root:Packages:ImportData:UseTitleNameAsFolder
	CheckBox UseTitleNameAsFolderNX,     help={"Name the data folder after the sample title stored in the file"}

	Button OpenFileInBrowser, pos={230, 326}, size={185, 20}, proc=IR3I_ButtonProc, title="Open File in HDF5 Browser", disable=2
	Button OpenFileInBrowser, help={"Inspect the selected HDF5/Nexus file in the HDF5 browser"}

	TitleBox NXMetaTitle, title="\Zr140Include in wave note", pos={230, 352}, frame=0, fstyle=1, fixedSize=1, size={185, 18}, disable=2

	CheckBox NX_InclsasInstrument, pos={230, 372}, size={16, 14}, noproc, title="Include sasInstrument?", disable=2
	CheckBox NX_InclsasInstrument, variable=root:Packages:ImportData:NX_InclsasInstrument
	CheckBox NX_InclsasInstrument, help={"Add sasInstrument group values to wave note on import"}

	CheckBox NX_Incl_sasSample, pos={230, 390}, size={16, 14}, noproc, title="Include sasSample?", disable=2
	CheckBox NX_Incl_sasSample, variable=root:Packages:ImportData:NX_Incl_sasSample
	CheckBox NX_Incl_sasSample, help={"Add sasSample group values to wave note on import"}

	CheckBox NX_Inclsasnote, pos={230, 408}, size={16, 14}, noproc, title="Include sasNote?", disable=2
	CheckBox NX_Inclsasnote, variable=root:Packages:ImportData:NX_Inclsasnote
	CheckBox NX_Inclsasnote, help={"Add sasNote group values to wave note on import"}

	// Preview button also works for Nexus (to inspect a file in the notebook)
	Button PreviewNX, pos={230, 430}, size={185, 20}, proc=IR3I_ButtonProc, title="Preview file in notebook", disable=2
	Button PreviewNX, help={"Open the selected file as text in a notebook (for ASCII inspection)"}

	// ── Bottom section: common processing and naming options ─────────────────
	//    Full-width controls, start at y=622 so they fall below the file list.
	//    Panel is scrollable so users can reach them.

	// Header divider
	TitleBox ProcessTitle, title="\Zr140─────  Data processing options  ─────", pos={5, 622}, frame=0, fstyle=1, fixedSize=1, size={415, 18}, fColor=(0, 0, 52224)

	// Skip header lines (ASCII only – hidden for Nexus)
	CheckBox SkipLines, pos={5, 643}, size={16, 14}, proc=IR3I_CheckProc, title="Skip header lines?", variable=root:Packages:ImportData:SkipLines
	CheckBox SkipLines, help={"Manually skip a fixed number of header lines before numeric data"}
	SetVariable SkipNumberOfLines, pos={160, 643}, size={90, 19}, proc=IR3I_SetVarProc, title="Count:"
	SetVariable SkipNumberOfLines, help={"Number of header lines to skip"}, variable=root:Packages:ImportData:SkipNumberOfLines
	SetVariable SkipNumberOfLines, disable=(!root:Packages:ImportData:SkipLines)

	// Q / X units
	CheckBox QvectorInA,  pos={5, 666}, size={16, 14}, proc=IR3I_CheckProc, title="Q/X units [1/A, deg, A]"
	CheckBox QvectorInA,  variable=root:Packages:ImportData:QvectInA
	CheckBox QvectorInA,  help={"X axis is in 1/Angstrom, degree, or Angstrom – no conversion needed"}
	CheckBox QvectorInNM, pos={220, 666}, size={16, 14}, proc=IR3I_CheckProc, title="Q/X units [1/nm or nm]"
	CheckBox QvectorInNM, variable=root:Packages:ImportData:QvectInNM
	CheckBox QvectorInNM, help={"X axis is in 1/nm or nm – will be converted to 1/A or A"}

	// Error creation (ASCII only – hidden for Nexus)
	CheckBox CreateSQRTErrors,    pos={5, 686}, size={16, 14}, proc=IR3I_CheckProc, title="Create SQRT(I) errors?"
	CheckBox CreateSQRTErrors,    variable=root:Packages:ImportData:CreateSQRTErrors
	CheckBox CreateSQRTErrors,    help={"If file has no error column, create errors as sqrt(Intensity)"}
	CheckBox CreatePercentErrors, pos={200, 686}, size={16, 14}, proc=IR3I_CheckProc, title="Create n% errors?"
	CheckBox CreatePercentErrors, variable=root:Packages:ImportData:CreatePercentErrors
	CheckBox CreatePercentErrors, help={"Create errors as a fixed percentage of intensity"}
	SetVariable PercentErrorsToUse, pos={340, 686}, size={70, 19}, proc=IR3I_SetVarProc, title="n%:"
	SetVariable PercentErrorsToUse, value=root:packages:ImportData:PercentErrorsToUse
	SetVariable PercentErrorsToUse, disable=!(root:Packages:ImportData:CreatePercentErrors)
	SetVariable PercentErrorsToUse, help={"Percentage to use when creating percentage-based errors"}

	// Miscellaneous flags
	CheckBox ForceUTF8,               pos={5, 706}, size={16, 14}, proc=IR3I_CheckProc, title="Force UTF-8 encoding?"
	CheckBox ForceUTF8,               variable=root:Packages:ImportData:ForceUTF8
	CheckBox ForceUTF8,               help={"Force UTF-8 file encoding – use if you have import encoding problems"}
	CheckBox RemoveNegativeIntensities,pos={220, 706}, size={16, 14}, proc=IR3I_CheckProc, title="Remove Int<=0?"
	CheckBox RemoveNegativeIntensities,variable=root:Packages:ImportData:RemoveNegativeIntensities
	CheckBox RemoveNegativeIntensities,help={"Remove data points where intensity is zero or negative"}

	// Q-range trimming
	CheckBox TrimData, pos={5, 726}, size={16, 14}, proc=IR3I_CheckProc, title="Trim Q/X range?"
	CheckBox TrimData, variable=root:Packages:ImportData:TrimData
	CheckBox TrimData, help={"Trim the X/Q range of imported data"}
	SetVariable TrimDataQMin, pos={140, 724}, size={130, 19}, title="Min=", proc=IR3I_SetVarProc
	SetVariable TrimDataQMin, limits={0, Inf, 0}, value=root:packages:ImportData:TrimDataQMin
	SetVariable TrimDataQMin, disable=!(root:Packages:ImportData:TrimData)
	SetVariable TrimDataQMin, help={"Minimum Q (or X) value – points below this are removed"}
	SetVariable TrimDataQMax, pos={285, 724}, size={130, 19}, title="Max=", proc=IR3I_SetVarProc
	SetVariable TrimDataQMax, limits={0, Inf, 0}, value=root:packages:ImportData:TrimDataQMax
	SetVariable TrimDataQMax, disable=!(root:Packages:ImportData:TrimData)
	SetVariable TrimDataQMax, help={"Maximum Q (or X) value – points above this are removed"}

	// Log-scale point reduction
	CheckBox ReduceNumPnts, pos={5, 746}, size={16, 14}, proc=IR3I_CheckProc, title="Reduce to N log-spaced points?"
	CheckBox ReduceNumPnts, variable=root:Packages:ImportData:ReduceNumPnts
	CheckBox ReduceNumPnts, help={"Rebin data onto a log-spaced Q grid with the target number of points"}
	SetVariable TargetNumberOfPoints, pos={230, 744}, size={185, 19}, title="Target N pts:", proc=IR3I_SetVarProc
	SetVariable TargetNumberOfPoints, limits={10, 2000, 0}, value=root:packages:ImportData:TargetNumberOfPoints
	SetVariable TargetNumberOfPoints, disable=!(root:Packages:ImportData:ReduceNumPnts)
	SetVariable TargetNumberOfPoints, help={"Target number of points after log-scale rebinning"}

	// Scaling
	CheckBox ScaleImportedDataCheckbox, pos={5, 766}, size={16, 14}, proc=IR3I_CheckProc, title="Scale imported data?"
	CheckBox ScaleImportedDataCheckbox, variable=root:Packages:ImportData:ScaleImportedData
	CheckBox ScaleImportedDataCheckbox, help={"Multiply intensity (and error) by a constant factor on import"}
	SetVariable ScaleImportedDataBy, pos={200, 764}, size={215, 19}, title="Factor:", proc=IR3I_SetVarProc
	SetVariable ScaleImportedDataBy, limits={1e-32, Inf, 1}, value=root:packages:ImportData:ScaleImportedDataBy
	SetVariable ScaleImportedDataBy, disable=!(root:Packages:ImportData:ScaleImportedData)
	SetVariable ScaleImportedDataBy, help={"Multiplicative scaling factor applied to intensity and errors"}

	// Slit smearing (SAS ASCII only)
	CheckBox SlitSmearDataCheckbox, pos={5, 786}, size={16, 14}, proc=IR3I_CheckProc, title="Slit-smear imported data?"
	CheckBox SlitSmearDataCheckbox, variable=root:Packages:ImportData:SlitSmearData
	CheckBox SlitSmearDataCheckbox, help={"Apply slit-smearing convolution to intensity and errors on import"}
	SetVariable SlitLength, pos={200, 784}, size={215, 19}, title="Slit length:", proc=IR3I_SetVarProc
	SetVariable SlitLength, limits={1e-32, Inf, 0}, value=root:packages:ImportData:SlitLength
	SetVariable SlitLength, disable=!(root:Packages:ImportData:SlitSmearData)
	SetVariable SlitLength, help={"Slit length in Q units (1/Angstrom) for smearing convolution"}

	// Calibration units (radio buttons)
	CheckBox DataCalibratedArbitrary, pos={5, 806}, size={16, 14}, mode=1, proc=IR3I_CheckProc
	CheckBox DataCalibratedArbitrary, title="Relative scale", variable=root:Packages:ImportData:DataCalibratedArbitrary
	CheckBox DataCalibratedArbitrary, help={"Intensity is on a relative / arbitrary scale"}
	CheckBox DataCalibratedVolume,    pos={130, 806}, size={16, 14}, mode=1, proc=IR3I_CheckProc
	CheckBox DataCalibratedVolume,    title="cm\S-1\Msr\S-1\M", variable=root:Packages:ImportData:DataCalibratedVolume
	CheckBox DataCalibratedVolume,    help={"Intensity is calibrated to absolute volume units cm^-1 sr^-1"}
	CheckBox DataCalibratedWeight,    pos={260, 806}, size={16, 14}, mode=1, proc=IR3I_CheckProc
	CheckBox DataCalibratedWeight,    title="cm\S2\Mg\S-1\Msr\S-1\M", variable=root:Packages:ImportData:DataCalibratedWeight
	CheckBox DataCalibratedWeight,    help={"Intensity is calibrated to absolute weight units cm^2/g sr^-1"}

	// ── Naming options ────────────────────────────────────────────────────────
	TitleBox NamingTitle, title="\Zr140─────  Naming & wave conventions  ─────", pos={5, 828}, frame=0, fstyle=1, fixedSize=1, size={415, 18}, fColor=(0, 0, 52224)

	CheckBox UseFileNameAsFolder,     pos={5, 849}, size={16, 14}, proc=IR3I_CheckProc, title="Use file name as folder name?"
	CheckBox UseFileNameAsFolder,     variable=root:Packages:ImportData:UseFileNameAsFolder
	CheckBox UseFileNameAsFolder,     help={"Create a sub-folder named after each imported file"}
	CheckBox IncludeExtensionInName,  pos={260, 849}, size={16, 14}, proc=IR3I_CheckProc, title="Include extension?"
	CheckBox IncludeExtensionInName,  variable=root:Packages:ImportData:IncludeExtensionInName
	CheckBox IncludeExtensionInName,  disable=!(root:Packages:ImportData:UseFileNameAsFolder)
	CheckBox IncludeExtensionInName,  help={"Include the file extension in the folder/wave name"}

	CheckBox UseIndra2Names, pos={5, 867}, size={16, 14}, proc=IR3I_CheckProc, title="Use USAXS (Indra) names?"
	CheckBox UseIndra2Names, variable=root:Packages:ImportData:UseIndra2Names
	CheckBox UseIndra2Names, help={"Wave naming: DSM_Qvec / DSM_Int / DSM_Error (Indra 2 convention)"}
	CheckBox ImportSMRdata,  pos={200, 867}, size={16, 14}, proc=IR3I_CheckProc, title="Slit-smeared data?"
	CheckBox ImportSMRdata,  variable=root:Packages:ImportData:ImportSMRdata
	CheckBox ImportSMRdata,  disable=!root:Packages:ImportData:UseIndra2Names
	CheckBox ImportSMRdata,  help={"Changes Indra names to SMR_Qvec / SMR_Int / SMR_Error"}

	CheckBox UseQRSNames, pos={5, 885}, size={16, 14}, proc=IR3I_CheckProc, title="Use QRS wave names?"
	CheckBox UseQRSNames, variable=root:Packages:ImportData:UseQRSNames
	CheckBox UseQRSNames, help={"Wave naming: Q_<name> / R_<name> / S_<name> / W_<name>"}
	CheckBox UseQISNames, pos={170, 885}, size={16, 14}, proc=IR3I_CheckProc, title="Use QIS (NIST) names?"
	CheckBox UseQISNames, variable=root:Packages:ImportData:UseQISNames
	CheckBox UseQISNames, help={"Wave naming: <name>_q / <name>_i / <name>_s / <name>_w (NIST convention)"}
	CheckBox AutomaticallyOverwrite, pos={330, 885}, size={16, 14}, proc=IR3I_CheckProc, title="Auto overwrite?"
	CheckBox AutomaticallyOverwrite, variable=root:Packages:ImportData:AutomaticallyOverwrite
	CheckBox AutomaticallyOverwrite, disable=!(root:Packages:ImportData:UseFileNameAsFolder)
	CheckBox AutomaticallyOverwrite, help={"Silently overwrite existing waves of the same name"}

	// Name truncation options
	CheckBox TrunkateStart, pos={5, 903}, size={16, 14}, proc=IR3I_CheckProc, title="Truncate long names at start?"
	CheckBox TrunkateStart, variable=root:Packages:ImportData:TrunkateStart
	CheckBox TrunkateStart, help={"For names longer than the Igor limit, remove characters from the front"}
	CheckBox TrunkateEnd,   pos={240, 903}, size={16, 14}, proc=IR3I_CheckProc, title="Truncate at end?"
	CheckBox TrunkateEnd,   variable=root:Packages:ImportData:TrunkateEnd
	CheckBox TrunkateEnd,   help={"For names longer than the Igor limit, remove characters from the end"}

	SetVariable RemoveStringFromName, pos={5, 923}, size={410, 19}, title="Remove string from name:", noproc
	SetVariable RemoveStringFromName, value=root:packages:ImportData:RemoveStringFromName
	SetVariable RemoveStringFromName, help={"Any occurrences of this string are removed from the imported name"}

	// Wave and folder name fields
	SetVariable NewDataFolderName, pos={5, 945}, size={410, 19}, title="Data folder:", proc=IR3I_SetVarProc
	SetVariable NewDataFolderName, value=root:packages:ImportData:NewDataFolderName
	SetVariable NewDataFolderName, help={"Target Igor folder. Use <fileName> as a placeholder for the file name."}

	SetVariable NewQwaveName, pos={5, 967}, size={200, 19}, title="Q / X wave name:", proc=IR3I_SetVarProc
	SetVariable NewQwaveName, value=root:packages:ImportData:NewQWaveName
	SetVariable NewQwaveName, help={"Name for the Q (or X) wave. Use <fileName> for the file name."}

	SetVariable NewIntensityWaveName, pos={5, 987}, size={200, 19}, title="Intensity wave name:", proc=IR3I_SetVarProc
	SetVariable NewIntensityWaveName, value=root:packages:ImportData:NewIntensityWaveName
	SetVariable NewIntensityWaveName, help={"Name for the intensity (Y) wave. Use <fileName> for the file name."}

	SetVariable NewErrorWaveName, pos={5, 1007}, size={200, 19}, title="Error wave name:", proc=IR3I_SetVarProc
	SetVariable NewErrorWaveName, value=root:packages:ImportData:NewErrorWaveName
	SetVariable NewErrorWaveName, help={"Name for the intensity-uncertainty wave. Use <fileName> for the file name."}

	SetVariable NewQErrorWaveName, pos={5, 1027}, size={200, 19}, title="dQ / dX wave name:", proc=IR3I_SetVarProc
	SetVariable NewQErrorWaveName, value=root:packages:ImportData:NewQErrorWaveName
	SetVariable NewQErrorWaveName, help={"Name for the Q-resolution wave. Use <fileName> for the file name."}

	// ── Import button ─────────────────────────────────────────────────────────
	Button ImportData, pos={280, 980}, size={130, 40}, proc=IR3I_ButtonProc, title="Import Selected Data"
	Button ImportData, help={"Import all selected files using the settings above"}

EndMacro

//************************************************************************************************************
//************************************************************************************************************
//  List-box event handler.  Double-click triggers a test-import.
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_DoubleClickFnct()

	IR3I_ButtonProc("TestImport")

End

//************************************************************************************************************
//************************************************************************************************************
//  Button handler.
//  Delegates to existing IR1I functions wherever possible.
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_ButtonProc(ctrlName) : ButtonControl
	string ctrlName

	if(cmpstr(ctrlName, "SelectDataPath") == 0)
		IR1I_SelectDataPath()
		IR1I_UpdateListOfFilesInWvs()
	endif
	if(cmpstr(ctrlName, "TestImport") == 0)
		IR1I_testImport()
	endif
	if(cmpstr(ctrlName, "Preview") == 0 || cmpstr(ctrlName, "PreviewNX") == 0)
		IR1I_TestImportNotebook()
	endif
	if(cmpstr(ctrlName, "Plot") == 0)
		IR1I_TestPlotData()
	endif
	if(cmpstr(ctrlName, "SelectAll") == 0)
		IR1I_SelectDeselectAll(1)
	endif
	if(cmpstr(ctrlName, "DeSelectAll") == 0 || cmpstr(ctrlName, "DeselectAll") == 0)
		IR1I_SelectDeselectAll(0)
	endif
	if(cmpstr(ctrlName, "ImportData") == 0)
		IR3I_ImportSelectedData()
	endif
	if(cmpstr(ctrlName, "OpenFileInBrowser") == 0)
		IR1I_NexusOpenHdf5File()
	endif
	if(cmpstr(ctrlName, "GetHelp") == 0)
		// Points to the same online manual section as the old ASCII importer.
		IN2G_OpenWebManual("Irena/ImportData.html")
	endif

End

//************************************************************************************************************
//************************************************************************************************************
//  Checkbox handler.
//  Handles the new format/type controls, then delegates to the existing
//  IR1I_CheckProc for all standard checkboxes (it uses WinName(0,64) so it
//  acts on whatever panel is currently in front).
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_CheckProc(ctrlName, checked) : CheckBoxControl
	string   ctrlName
	variable checked

	SVAR DataFormatType = root:Packages:ImportData:DataFormatType
	NVAR SAXSData = root:Packages:ImportData:SAXSData
	NVAR WAXSData = root:Packages:ImportData:WAXSData

	// SAXS / WAXS radio selection
	if(cmpstr(ctrlName, "SAXSData") == 0)
		SAXSData = checked
		WAXSData = !checked
		IR3I_UpdateFormatUI()
		return 0
	endif
	if(cmpstr(ctrlName, "WAXSData") == 0)
		WAXSData = checked
		SAXSData = !checked
		IR3I_UpdateFormatUI()
		return 0
	endif

	// All other checkboxes are handled by the existing (shared) handler.
	IR1I_CheckProc(ctrlName, checked)

End

//************************************************************************************************************
//************************************************************************************************************
//  SetVariable handler.
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_SetVarProc(ctrlName, varNum, varStr, varName) : SetVariableControl
	string   ctrlName
	variable varNum
	string   varStr
	string   varName

	if(cmpstr(ctrlName, "DataExtensionString") == 0)
		IR1I_UpdateListOfFilesInWvs()
	endif
	if(cmpstr(ctrlName, "NameMatchString") == 0)
		IR1I_UpdateListOfFilesInWvs()
	endif
	if(cmpstr(ctrlName, "FoundNWaves") == 0)
		IR1I_FIxCheckboxesForWaveTypes()
	endif

End

//************************************************************************************************************
//************************************************************************************************************
//  Popup-menu handler.
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_PopMenuProc(ctrlName, popNum, popStr) : PopupMenuControl
	string   ctrlName
	variable popNum
	string   popStr

	if(cmpstr(ctrlName, "DataFormatPopup") == 0)
		SVAR DataFormatType = root:Packages:ImportData:DataFormatType
		DataFormatType = popStr
		IR3I_UpdateFormatUI()
		// When switching back to ASCII mode, reset/update the wave names.
		if(!stringMatch(popStr, "Nexus CanSAS"))
			IR1I_ImportOtherSetNames()
		endif
	endif

	// WAXS X-axis type (Q-Int / D-Int / Tth-Int)
	if(cmpstr(ctrlName, "ImportDataType") == 0)
		SVAR DataTypeToImport = root:Packages:ImportData:DataTypeToImport
		DataTypeToImport = popStr
		// Show wavelength field only when 2-theta conversion is needed.
		SetVariable Wavelength, win=IR3I_ImportData, disable=!StringMatch(DataTypeToImport, "Tth-Int")
		IR1I_ImportOtherSetNames()
	endif

End

//************************************************************************************************************
//************************************************************************************************************
//  IR3I_UpdateFormatUI
//  Shows and hides control sections depending on the selected data format
//  and SAXS/WAXS choice.  Uses ModifyControl with disable=0/2 so controls
//  are fully hidden (not just greyed) when not applicable.
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_UpdateFormatUI()

	SVAR/Z DataFormatType   = root:Packages:ImportData:DataFormatType
	SVAR/Z DataTypeToImport = root:Packages:ImportData:DataTypeToImport
	NVAR/Z WAXSData         = root:Packages:ImportData:WAXSData
	if(!SVAR_Exists(DataFormatType))
		return 0		// package not yet initialized — nothing to update
	endif

	// Read checkbox-state globals needed for SetVariable disable= expressions
	NVAR/Z SkipLines           = root:Packages:ImportData:SkipLines
	NVAR/Z CreatePercentErrors = root:Packages:ImportData:CreatePercentErrors
	NVAR/Z SlitSmearData       = root:Packages:ImportData:SlitSmearData

	variable isASCII  = !StringMatch(DataFormatType, "Nexus CanSAS")
	variable isNexus  = StringMatch(DataFormatType, "Nexus CanSAS")
	variable isWAXS   = StringMatch(DataFormatType, "ASCII WAXS") && (NVAR_Exists(WAXSData) ? WAXSData : 0)
	variable isTthInt = isWAXS && SVAR_Exists(DataTypeToImport) && StringMatch(DataTypeToImport, "Tth-Int")

	// WAXS sub-type popup and wavelength – only for ASCII WAXS
	PopupMenu ImportDataType,   win=IR3I_ImportData, disable=(!isWAXS * 2)
	SetVariable Wavelength,     win=IR3I_ImportData, disable=(!isTthInt * 2)

	// Section B – ASCII column mapping
	variable asciiDisable = isNexus ? 2 : 0
	TitleBox  ColMapTitle,  win=IR3I_ImportData, disable=asciiDisable
	TitleBox  ColHdrCol,    win=IR3I_ImportData, disable=asciiDisable
	TitleBox  ColHdrQ,      win=IR3I_ImportData, disable=asciiDisable
	TitleBox  ColHdrInt,    win=IR3I_ImportData, disable=asciiDisable
	TitleBox  ColHdrErr,    win=IR3I_ImportData, disable=asciiDisable
	TitleBox  ColHdrQErr,   win=IR3I_ImportData, disable=asciiDisable
	TitleBox  Info21,       win=IR3I_ImportData, disable=asciiDisable
	TitleBox  Info22,       win=IR3I_ImportData, disable=asciiDisable
	TitleBox  Info23,       win=IR3I_ImportData, disable=asciiDisable
	TitleBox  Info24,       win=IR3I_ImportData, disable=asciiDisable
	TitleBox  Info25,       win=IR3I_ImportData, disable=asciiDisable
	TitleBox  Info26,       win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col1Qvec,   win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col1Int,    win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col1Error,  win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col1QError, win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col2Qvec,   win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col2Int,    win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col2Error,  win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col2QError, win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col3Qvec,   win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col3Int,    win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col3Error,  win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col3QError, win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col4Qvec,   win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col4Int,    win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col4Error,  win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col4QError, win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col5Qvec,   win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col5Int,    win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col5Error,  win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col5QError, win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col6Qvec,   win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col6Int,    win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col6Error,  win=IR3I_ImportData, disable=asciiDisable
	CheckBox Col6QError, win=IR3I_ImportData, disable=asciiDisable
	SetVariable FoundNWaves, win=IR3I_ImportData, disable=(isNexus ? 2 : 2)  // always read-only display
	Button TestImport, win=IR3I_ImportData, disable=asciiDisable
	Button Plot,       win=IR3I_ImportData, disable=asciiDisable

	// Section C – Nexus-specific controls
	variable nexusDisable = isASCII ? 2 : 0
	TitleBox  NXTitle,                   win=IR3I_ImportData, disable=nexusDisable
	CheckBox  UseFileNameAsFolderNX,     win=IR3I_ImportData, disable=nexusDisable
	CheckBox  UsesasEntryNameAsFolderNX, win=IR3I_ImportData, disable=nexusDisable
	CheckBox  UseTitleNameAsFolderNX,    win=IR3I_ImportData, disable=nexusDisable
	Button    OpenFileInBrowser,         win=IR3I_ImportData, disable=nexusDisable
	TitleBox  NXMetaTitle,               win=IR3I_ImportData, disable=nexusDisable
	CheckBox  NX_InclsasInstrument,      win=IR3I_ImportData, disable=nexusDisable
	CheckBox  NX_Incl_sasSample,         win=IR3I_ImportData, disable=nexusDisable
	CheckBox  NX_Inclsasnote,            win=IR3I_ImportData, disable=nexusDisable
	Button    PreviewNX,                 win=IR3I_ImportData, disable=nexusDisable

	// Bottom-section controls that are ASCII-only
	CheckBox SkipLines,            win=IR3I_ImportData, disable=asciiDisable
	SetVariable SkipNumberOfLines, win=IR3I_ImportData, disable=(isNexus ? 2 : !SkipLines)
	CheckBox CreateSQRTErrors,    win=IR3I_ImportData, disable=asciiDisable
	CheckBox CreatePercentErrors, win=IR3I_ImportData, disable=asciiDisable
	SetVariable PercentErrorsToUse, win=IR3I_ImportData, disable=(isNexus ? 2 : !CreatePercentErrors)
	// Slit smearing makes sense only for SAS (not WAXS, not Nexus)
	variable slitDisable = (!StringMatch(DataFormatType, "ASCII SAXS/SANS")) ? 2 : 0
	CheckBox SlitSmearDataCheckbox, win=IR3I_ImportData, disable=slitDisable
	SetVariable SlitLength, win=IR3I_ImportData, disable=(slitDisable > 0 ? 2 : !SlitSmearData)

End

//************************************************************************************************************
//************************************************************************************************************
//  IR3I_ImportSelectedData
//  Dispatches to the appropriate import back-end depending on the
//  selected data format.
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_ImportSelectedData()

	string OldDf = getDataFolder(1)
	SVAR DataFormatType = root:Packages:ImportData:DataFormatType

	WAVE/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
	WAVE   WaveOfSelections = root:Packages:ImportData:WaveOfSelections

	IR1I_CheckForProperNewFolder()

	variable i, imax, icount
	string   SelectedFile
	imax   = numpnts(WaveOfSelections)
	icount = 0

	if(StringMatch(DataFormatType, "ASCII SAXS/SANS"))
		// ── ASCII SAXS/SANS: delegate to the SAS ASCII back-end ──
		for(i = 0; i < imax; i += 1)
			if(WaveOfSelections[i])
				selectedFile = WaveOfFiles[i]
				IR1I_CreateImportDataFolder(selectedFile)
				KillWaves/Z TempIntensity, TempQvector, TempError, TempQError
				IR1I_ImportOneFile(selectedFile)
				IR1I_ProcessImpWaves(selectedFile)
				IR1I_RecordResults(selectedFile)
				icount += 1
			endif
		endfor

	elseif(StringMatch(DataFormatType, "ASCII WAXS"))
		// ── ASCII WAXS: delegate to the non-SAS ASCII back-end ──
		for(i = 0; i < imax; i += 1)
			if(WaveOfSelections[i])
				selectedFile = WaveOfFiles[i]
				IR1I_CreateImportDataFolder(selectedFile)
				KillWaves/Z TempIntensity, TempQvector, TempError, TempQError
				IR1I_ImportOneFile(selectedFile)
				IR1I_ProcessImpWaves2(selectedFile)
				IR1I_RecordResults(selectedFile)
				icount += 1
			endif
		endfor

	elseif(StringMatch(DataFormatType, "Nexus CanSAS"))
		// ── Nexus CanSAS: delegate to the Nexus reader ──
		variable timerRefNum = startMSTimer
		NVAR UseFolder  = root:Packages:ImportData:UseFileNameAsFolder
		NVAR UseEntry   = root:Packages:ImportData:UsesasEntryNameAsFolder
		NVAR UseTitle   = root:Packages:ImportData:UseTitleNameAsFolder
		NVAR NX_SasIns  = root:Packages:ImportData:NX_InclsasInstrument
		NVAR NX_SASSam  = root:Packages:ImportData:NX_Incl_sasSample
		NVAR NX_SASNote = root:Packages:ImportData:NX_Inclsasnote

		for(i = 0; i < imax; i += 1)
			if(WaveOfSelections[i])
				selectedFile = WaveOfFiles[i]
				NEXUS_NXcanSASDataReader("ImportDataPath", selectedFile, 1, 0, UseFolder, UseEntry, UseTitle, NX_SasIns, NX_SASSam, NX_SASNote)
				icount += 1
			endif
		endfor

		variable microSeconds = StopMSTimer(timerRefNum)
		print num2str(microSeconds / 1e6) + " seconds for Nexus import"
		// Clean up the temporary import folder used by the Nexus reader.
		KillDataFolder/Z root:Packages:NexusImportTMP
	endif

	print "Imported " + num2str(icount) + " file(s) using format: " + DataFormatType
	setDataFolder OldDf

End

//************************************************************************************************************
//************************************************************************************************************
