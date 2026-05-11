#pragma rtGlobals=3		// Use modern global access method and strict wave access
#pragma version=1.01
#pragma IgorVersion = 9.04

//*************************************************************************\
//* Copyright (c) 2005 - 2026, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution.
//*************************************************************************/

// 1.02 AI checked
// 1.01  Combined with IR1_ImportData and remove that package from dependencies. 
// 1.00  Initial combined import panel.
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

Constant IR3IversionNumber 		= 1.00
Constant IR3TrimNameLength     = 28


// Entry point called from the Irena SAS menu.
// Closes any conflicting legacy import panels, then opens the unified import panel.
Function IR3I_ImportDataMain()

	// If the old separate panels are open they share the same globals, so
	// we must close them to avoid conflicts.
	DoWindow IR1I_ImportData
	if(V_Flag)
		KillWindow/Z IR1I_ImportData
	endif
	DoWindow IR1I_ImportOtherASCIIData
	if(V_Flag)
		KillWindow/Z IR1I_ImportOtherASCIIData
	endif
	DoWindow IR1I_ImportNexusCanSASData
	if(V_Flag)
		KillWindow/Z IR1I_ImportNexusCanSASData
	endif

	KillWindow/Z IR3I_ImportData
	IR3I_InitializeImportData()
	IR3I_ImportDataPanel()
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("IR3I_ImportData", IR3IversionNumber, 1)
	IR3I_UpdateFormatUI()

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
//  Panel definition.
//  Layout follows the bioSAXS-style design from GUI.jpg:
//    Left  (x=5–225)   : file list managed by IR3C_AddDataControls
//    Right (x=230–420) : data format selector and format-specific controls
//    Bottom (y=622+)   : common processing options, naming options, import button
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_ImportDataPanel()

	PauseUpdate	// building window …

	NewPanel/K=1/W=(3, 40, 430, 850)/N=IR3I_ImportData as "Import SAXS/WAXS/Nexus Data"

	// ── Title ───────────────────────────────────────────────────────────────
	TitleBox MainTitle, title="\Zr200Import SAXS / WAXS / Nexus Data in Igor", pos={20, 5}, frame=0, fstyle=3
	TitleBox MainTitle, fixedSize=1, font="Times New Roman", size={400, 24}, anchor=MC, fColor=(0, 0, 52224)
	TitleBox FakeLine1, title=" ", fixedSize=1, size={330, 3}, pos={16, 40}, frame=0, fColor=(0, 0, 52224), labelBack=(0, 0, 52224)

	// ── File selection (IR3C_AddDataControls places: Select Data Path, data path
	//    display, match name, extension, sort popup, list box, Select All,
	//    Deselect All).  We override the list box size and button positions. ──
	IR3C_AddDataControls("ImportDataPath", "ImportData", "IR3I_ImportData", "", "", "", "IR3I_DoubleClickFnct")
	Button SelectDataPath, proc= IR3I_ButtonProc
	ListBox ListOfAvailableData, size={220, 320}, pos={5, 113}
	Button SelectAll, pos={5, 440}
	Button DeSelectAll, pos={120, 440}
	SetVariable NameMatchString, pos={5,90}, size={155,20}
	PopupMenu SortOptionString, pos={165, 90}
	SetVariable DataExtensionString, pos={305,90}, size={105,20},title="Data ext:"

	// Get Help button (top-right corner)
	Button GetHelp, pos={335, 53}, size={80, 15}, fColor=(65535, 32768, 32768), proc=IR3I_ButtonProc, title="Get Help"
	Button GetHelp, help={"Open the online manual page for this tool"}

	// ── Section A: Data format and SAXS/WAXS selection ───────────────────────
	//    Always visible on the right side of the panel.

	TitleBox FormatTitle, title="\Zr140Data format & type", pos={230, 113}, frame=0, fstyle=1, fixedSize=1, size={185, 18}, fColor=(0, 0, 52224)

	PopupMenu DataFormatPopup, pos={230, 133}, size={185, 21}, proc=IR3I_PopMenuProc, title="Format:"
	PopupMenu DataFormatPopup, help={"Select the type of data file to import"}
	SVAR DFMT=root:Packages:ImportData:DataFormatType
	PopupMenu DataFormatPopup, mode=1, popvalue=DFMT
	PopupMenu DataFormatPopup, value="ASCII SAXS/SANS;ASCII WAXS;Nexus NXcanSAS"

	CheckBox SAXSData, pos={250, 160}, size={16, 14}, proc=IR3I_CheckProc, title="SAXS data?", mode=1
	CheckBox SAXSData, variable=root:Packages:ImportData:SAXSData
	CheckBox SAXSData, help={"Select for SAXS data (Q-space). Default folder: root:SAS"}

	CheckBox WAXSData, pos={250, 178}, size={16, 14}, proc=IR3I_CheckProc, title="WAXS data?", mode=1
	CheckBox WAXSData, variable=root:Packages:ImportData:WAXSData
	CheckBox WAXSData, help={"Select for WAXS data (real space / 2-theta). Default folder: root:WAXS"}

	// WAXS data sub-type – only relevant for ASCII WAXS format
	PopupMenu ImportDataType, pos={230, 198}, size={185, 21}, proc=IR3I_PopMenuProc, title="X-axis:"
	PopupMenu ImportDataType, help={"For ASCII WAXS: choose what the X column represents"}
	SVAR DTP=root:Packages:ImportData:DataTypeToImport
	PopupMenu ImportDataType, mode=1, popvalue=DTP
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

	TitleBox NXTitle, title="\Zr140Nexus folder naming", pos={230, 246}, frame=0, fstyle=1, fixedSize=1, size={185, 18}, disable=1

	CheckBox UseFileNameAsFolderNX,      pos={230, 268}, size={16, 14}, proc=IR3I_CheckProc, mode=1, disable=1
	CheckBox UseFileNameAsFolderNX,      title="Use file name as folder name"
	CheckBox UseFileNameAsFolderNX,      variable=root:Packages:ImportData:UseFileNameAsFolder
	CheckBox UseFileNameAsFolderNX,      help={"Name the data folder after the HDF5 file name"}

	CheckBox UsesasEntryNameAsFolderNX,  pos={230, 286}, size={16, 14}, proc=IR3I_CheckProc, mode=1, disable=1
	CheckBox UsesasEntryNameAsFolderNX,  title="Use sasEntry name as folder"
	CheckBox UsesasEntryNameAsFolderNX,  variable=root:Packages:ImportData:UsesasEntryNameAsFolder
	CheckBox UsesasEntryNameAsFolderNX,  help={"Name the data folder after the NXcanSAS entry name"}

	CheckBox UseTitleNameAsFolderNX,     pos={230, 304}, size={16, 14}, proc=IR3I_CheckProc, mode=1, disable=1
	CheckBox UseTitleNameAsFolderNX,     title="Use sasTitle as folder name"
	CheckBox UseTitleNameAsFolderNX,     variable=root:Packages:ImportData:UseTitleNameAsFolder
	CheckBox UseTitleNameAsFolderNX,     help={"Name the data folder after the sample title stored in the file"}

	Button OpenFileInBrowser, pos={230, 326}, size={185, 20}, proc=IR3I_ButtonProc, title="Open File in HDF5 Browser", disable=1
	Button OpenFileInBrowser, help={"Inspect the selected HDF5/Nexus file in the HDF5 browser"}

	TitleBox NXMetaTitle, title="\Zr140Include in wave note", pos={230, 352}, frame=0, fstyle=1, fixedSize=1, size={185, 18}, disable=1

	CheckBox NX_InclsasInstrument, pos={230, 372}, size={16, 14}, noproc, title="Include sasInstrument?", disable=1
	CheckBox NX_InclsasInstrument, variable=root:Packages:ImportData:NX_InclsasInstrument
	CheckBox NX_InclsasInstrument, help={"Add sasInstrument group values to wave note on import"}

	CheckBox NX_Incl_sasSample, pos={230, 390}, size={16, 14}, noproc, title="Include sasSample?", disable=1
	CheckBox NX_Incl_sasSample, variable=root:Packages:ImportData:NX_Incl_sasSample
	CheckBox NX_Incl_sasSample, help={"Add sasSample group values to wave note on import"}

	CheckBox NX_Inclsasnote, pos={230, 408}, size={16, 14}, noproc, title="Include sasNote?", disable=1
	CheckBox NX_Inclsasnote, variable=root:Packages:ImportData:NX_Inclsasnote
	CheckBox NX_Inclsasnote, help={"Add sasNote group values to wave note on import"}

	// Preview button also works for Nexus (to inspect a file in the notebook)
	//Button PreviewNX, pos={240, 430}, size={175, 18}, proc=IR3I_ButtonProc, title="Preview file in notebook", disable=1
	//Button PreviewNX, help={"Open the selected file as text in a notebook (for ASCII inspection)"}

	// ── Bottom section: common processing and naming options ─────────────────
	//    Full-width controls, start at y=622 so they fall below the file list.
	//    Panel is scrollable so users can reach them.

	// Header divider
	TitleBox ProcessTitle, title="\Zr140─────  Data processing options  ─────", pos={25, 460}, frame=0, fstyle=1, fixedSize=1, size={415, 18}, fColor=(0, 0, 52224)

	// Skip header lines (ASCII only – hidden for Nexus)
	CheckBox SkipLines, pos={5, 475}, size={16, 14}, proc=IR3I_CheckProc, title="Skip header lines?", variable=root:Packages:ImportData:SkipLines
	CheckBox SkipLines, help={"Manually skip a fixed number of header lines before numeric data"}
	SetVariable SkipNumberOfLines, pos={70, 485}, size={80, 19}, proc=IR3I_SetVarProc, title="Count:"
	SetVariable SkipNumberOfLines, help={"Number of header lines to skip"}, variable=root:Packages:ImportData:SkipNumberOfLines
	NVAR skip=root:Packages:ImportData:SkipLines
	SetVariable SkipNumberOfLines, disable=(!skip)

	// Q / X units
	CheckBox QvectorInA,  pos={160, 480}, size={16, 14}, proc=IR3I_CheckProc, title="Q/X units [1/A, deg, A]"
	CheckBox QvectorInA,  variable=root:Packages:ImportData:QvectInA
	CheckBox QvectorInA,  help={"X axis is in 1/Angstrom, degree, or Angstrom – no conversion needed"}
	CheckBox QvectorInNM, pos={300, 480}, size={16, 14}, proc=IR3I_CheckProc, title="Q/X units [1/nm or nm]"
	CheckBox QvectorInNM, variable=root:Packages:ImportData:QvectInNM
	CheckBox QvectorInNM, help={"X axis is in 1/nm or nm – will be converted to 1/A or A"}

	// Error creation (ASCII only – hidden for Nexus)
	CheckBox CreateSQRTErrors,    pos={5, 500}, size={16, 14}, proc=IR3I_CheckProc, title="Create SQRT(I) errors?"
	CheckBox CreateSQRTErrors,    variable=root:Packages:ImportData:CreateSQRTErrors
	CheckBox CreateSQRTErrors,    help={"If file has no error column, create errors as sqrt(Intensity)"}
	CheckBox CreatePercentErrors, pos={160, 500}, size={16, 14}, proc=IR3I_CheckProc, title="Create n% errors?"
	CheckBox CreatePercentErrors, variable=root:Packages:ImportData:CreatePercentErrors
	CheckBox CreatePercentErrors, help={"Create errors as a fixed percentage of intensity"}
	SetVariable PercentErrorsToUse, pos={300, 500}, size={70, 19}, proc=IR3I_SetVarProc, title="n%:"
	SetVariable PercentErrorsToUse, value=root:packages:ImportData:PercentErrorsToUse
	NVAR pct=root:Packages:ImportData:CreatePercentErrors
	SetVariable PercentErrorsToUse, disable=!(pct)
	SetVariable PercentErrorsToUse, help={"Percentage to use when creating percentage-based errors"}

	// Miscellaneous flags
	CheckBox ForceUTF8,               pos={300, 450}, size={16, 14}, proc=IR3I_CheckProc, title="Force UTF-8 encoding?"
	CheckBox ForceUTF8,               variable=root:Packages:ImportData:ForceUTF8
	CheckBox ForceUTF8,               help={"Force UTF-8 file encoding – use if you have import encoding problems"}
	CheckBox RemoveNegativeIntensities,pos={300, 465}, size={16, 14}, proc=IR3I_CheckProc, title="Remove Int<=0?"
	CheckBox RemoveNegativeIntensities,variable=root:Packages:ImportData:RemoveNegativeIntensities
	CheckBox RemoveNegativeIntensities,help={"Remove data points where intensity is zero or negative"}

	// Q-range trimming
	CheckBox TrimData, pos={5, 515}, size={16, 14}, proc=IR3I_CheckProc, title="Trim Q/X range?"
	CheckBox TrimData, variable=root:Packages:ImportData:TrimData
	CheckBox TrimData, help={"Trim the X/Q range of imported data"}
	SetVariable TrimDataQMin, pos={140, 515}, size={100, 19}, title="Min=", proc=IR3I_SetVarProc
	SetVariable TrimDataQMin, limits={0, Inf, 0}, value=root:packages:ImportData:TrimDataQMin
	NVAR trim=root:Packages:ImportData:TrimData
	SetVariable TrimDataQMin, disable=!(trim)
	SetVariable TrimDataQMin, help={"Minimum Q (or X) value – points below this are removed"}
	SetVariable TrimDataQMax, pos={285, 515}, size={100, 19}, title="Max=", proc=IR3I_SetVarProc
	SetVariable TrimDataQMax, limits={0, Inf, 0}, value=root:packages:ImportData:TrimDataQMax
	SetVariable TrimDataQMax, disable=!(trim)
	SetVariable TrimDataQMax, help={"Maximum Q (or X) value – points above this are removed"}

	// Log-scale point reduction
	CheckBox ReduceNumPnts, pos={5, 530}, size={16, 14}, proc=IR3I_CheckProc, title="Reduce to N log-spaced points?"
	CheckBox ReduceNumPnts, variable=root:Packages:ImportData:ReduceNumPnts
	CheckBox ReduceNumPnts, help={"Rebin data onto a log-spaced Q grid with the target number of points"}
	SetVariable TargetNumberOfPoints, pos={180, 530}, size={150, 19}, title="Target N pts:", proc=IR3I_SetVarProc
	SetVariable TargetNumberOfPoints, limits={10, 2000, 0}, value=root:packages:ImportData:TargetNumberOfPoints, bodywidth=80
	NVAR reduce=root:Packages:ImportData:ReduceNumPnts
	SetVariable TargetNumberOfPoints, disable=!(reduce)
	SetVariable TargetNumberOfPoints, help={"Target number of points after log-scale rebinning"}

	// Scaling
	CheckBox ScaleImportedDataCheckbox, pos={5, 545}, size={16, 14}, proc=IR3I_CheckProc, title="Scale imported data?"
	CheckBox ScaleImportedDataCheckbox, variable=root:Packages:ImportData:ScaleImportedData
	CheckBox ScaleImportedDataCheckbox, help={"Multiply intensity (and error) by a constant factor on import"}
	SetVariable ScaleImportedDataBy, pos={180, 545}, size={150, 19}, title="Factor:", proc=IR3I_SetVarProc
	SetVariable ScaleImportedDataBy, limits={1e-32, Inf, 1}, value=root:packages:ImportData:ScaleImportedDataBy, bodywidth=80
	NVAR scale=root:Packages:ImportData:ScaleImportedData
	SetVariable ScaleImportedDataBy, disable=!(scale)
	SetVariable ScaleImportedDataBy, help={"Multiplicative scaling factor applied to intensity and errors"}

	// Slit smearing (SAS ASCII only)
	CheckBox SlitSmearDataCheckbox, pos={5, 560}, size={16, 14}, proc=IR3I_CheckProc, title="Slit-smear imported data?"
	CheckBox SlitSmearDataCheckbox, variable=root:Packages:ImportData:SlitSmearData
	CheckBox SlitSmearDataCheckbox, help={"Apply slit-smearing convolution to intensity and errors on import"}
	SetVariable SlitLength, pos={200, 560}, size={150, 19}, title="Slit length [1/A]:", proc=IR3I_SetVarProc
	SetVariable SlitLength, limits={1e-32, Inf, 0}, value=root:packages:ImportData:SlitLength
	NVAR smear=root:Packages:ImportData:SlitSmearData
	SetVariable SlitLength, disable=!(smear)
	SetVariable SlitLength, help={"Slit length in Q units (1/Angstrom) for smearing convolution"}

	// Calibration units (radio buttons)
	CheckBox DataCalibratedArbitrary, pos={25, 575}, size={16, 14}, mode=1, proc=IR3I_CheckProc
	CheckBox DataCalibratedArbitrary, title="Relative scale", variable=root:Packages:ImportData:DataCalibratedArbitrary
	CheckBox DataCalibratedArbitrary, help={"Intensity is on a relative / arbitrary scale"}
	CheckBox DataCalibratedVolume,    pos={150, 575}, size={16, 14}, mode=1, proc=IR3I_CheckProc
	CheckBox DataCalibratedVolume,    title="cm\S-1\Msr\S-1\M", variable=root:Packages:ImportData:DataCalibratedVolume
	CheckBox DataCalibratedVolume,    help={"Intensity is calibrated to absolute volume units cm^-1 sr^-1"}
	CheckBox DataCalibratedWeight,    pos={270, 575}, size={16, 14}, mode=1, proc=IR3I_CheckProc
	CheckBox DataCalibratedWeight,    title="cm\S2\Mg\S-1\Msr\S-1\M", variable=root:Packages:ImportData:DataCalibratedWeight
	CheckBox DataCalibratedWeight,    help={"Intensity is calibrated to absolute weight units cm^2/g sr^-1"}

	// ── Naming options ────────────────────────────────────────────────────────
	TitleBox NamingTitle, title="\Zr140─────  Naming & wave conventions  ─────", pos={55, 590}, frame=0, fstyle=1, fixedSize=1, size={415, 18}, fColor=(0, 0, 52224)

	CheckBox UseFileNameAsFolder,     pos={5, 610}, size={16, 14}, proc=IR3I_CheckProc, title="Use file name as folder name?"
	CheckBox UseFileNameAsFolder,     variable=root:Packages:ImportData:UseFileNameAsFolder
	CheckBox UseFileNameAsFolder,     help={"Create a sub-folder named after each imported file"}
	CheckBox IncludeExtensionInName,  pos={260, 610}, size={16, 14}, proc=IR3I_CheckProc, title="Include extension?"
	CheckBox IncludeExtensionInName,  variable=root:Packages:ImportData:IncludeExtensionInName
	NVAR SameFldr=root:Packages:ImportData:UseFileNameAsFolder
	CheckBox IncludeExtensionInName,  disable=!(SameFldr)
	CheckBox IncludeExtensionInName,  help={"Include the file extension in the folder/wave name"}

	CheckBox UseIndra2Names, pos={5, 625}, size={16, 14}, proc=IR3I_CheckProc, title="Use USAXS (Indra) names?"
	CheckBox UseIndra2Names, variable=root:Packages:ImportData:UseIndra2Names
	CheckBox UseIndra2Names, help={"Wave naming: DSM_Qvec / DSM_Int / DSM_Error (Indra 2 convention)"}
	CheckBox ImportSMRdata,  pos={200, 625}, size={16, 14}, proc=IR3I_CheckProc, title="Slit-smeared data?"
	CheckBox ImportSMRdata,  variable=root:Packages:ImportData:ImportSMRdata
	NVAR useIndra2=root:Packages:ImportData:UseIndra2Names
	CheckBox ImportSMRdata,  disable=!useIndra2
	CheckBox ImportSMRdata,  help={"Changes Indra names to SMR_Qvec / SMR_Int / SMR_Error"}

	CheckBox UseQRSNames, pos={5, 640}, size={16, 14}, proc=IR3I_CheckProc, title="Use QRS wave names?"
	CheckBox UseQRSNames, variable=root:Packages:ImportData:UseQRSNames
	CheckBox UseQRSNames, help={"Wave naming: Q_<name> / R_<name> / S_<name> / W_<name>"}
	CheckBox UseQISNames, pos={170, 640}, size={16, 14}, proc=IR3I_CheckProc, title="Use QIS (NIST) names?"
	CheckBox UseQISNames, variable=root:Packages:ImportData:UseQISNames
	CheckBox UseQISNames, help={"Wave naming: <name>_q / <name>_i / <name>_s / <name>_w (NIST convention)"}
	CheckBox AutomaticallyOverwrite, pos={330, 640}, size={16, 14}, proc=IR3I_CheckProc, title="Auto overwrite?"
	CheckBox AutomaticallyOverwrite, variable=root:Packages:ImportData:AutomaticallyOverwrite
	CheckBox AutomaticallyOverwrite, disable=!(SameFldr)
	CheckBox AutomaticallyOverwrite, help={"Silently overwrite existing waves of the same name"}

	// Name truncation options
	CheckBox TrunkateStart, pos={5, 655}, size={16, 14}, proc=IR3I_CheckProc, title="Truncate long names at start?"
	CheckBox TrunkateStart, variable=root:Packages:ImportData:TrunkateStart
	CheckBox TrunkateStart, help={"For names longer than the Igor limit, remove characters from the front"}
	CheckBox TrunkateEnd,   pos={240, 655}, size={16, 14}, proc=IR3I_CheckProc, title="Truncate at end?"
	CheckBox TrunkateEnd,   variable=root:Packages:ImportData:TrunkateEnd
	CheckBox TrunkateEnd,   help={"For names longer than the Igor limit, remove characters from the end"}

	SetVariable RemoveStringFromName, pos={5, 675}, size={310, 19}, title="Remove string from name:", noproc
	SetVariable RemoveStringFromName, value=root:packages:ImportData:RemoveStringFromName
	SetVariable RemoveStringFromName, help={"Any occurrences of this string are removed from the imported name"}

	// Wave and folder name fields
	SetVariable NewDataFolderName, pos={5, 695}, size={410, 19}, title="Data folder:", proc=IR3I_SetVarProc
	SetVariable NewDataFolderName, value=root:packages:ImportData:NewDataFolderName
	SetVariable NewDataFolderName, help={"Target Igor folder. Use <fileName> as a placeholder for the file name."}

	SetVariable NewQwaveName, pos={5, 715}, size={300, 19}, title="Q / X wave name:", proc=IR3I_SetVarProc
	SetVariable NewQwaveName, value=root:packages:ImportData:NewQWaveName
	SetVariable NewQwaveName, help={"Name for the Q (or X) wave. Use <fileName> for the file name."}

	SetVariable NewIntensityWaveName, pos={5, 735}, size={300, 19}, title="Intensity wave name:", proc=IR3I_SetVarProc
	SetVariable NewIntensityWaveName, value=root:packages:ImportData:NewIntensityWaveName
	SetVariable NewIntensityWaveName, help={"Name for the intensity (Y) wave. Use <fileName> for the file name."}

	SetVariable NewErrorWaveName, pos={5, 755}, size={300, 19}, title="Error wave name:", proc=IR3I_SetVarProc
	SetVariable NewErrorWaveName, value=root:packages:ImportData:NewErrorWaveName
	SetVariable NewErrorWaveName, help={"Name for the intensity-uncertainty wave. Use <fileName> for the file name."}

	SetVariable NewQErrorWaveName, pos={5, 775}, size={300, 19}, title="dQ / dX wave name:", proc=IR3I_SetVarProc
	SetVariable NewQErrorWaveName, value=root:packages:ImportData:NewQErrorWaveName
	SetVariable NewQErrorWaveName, help={"Name for the Q-resolution wave. Use <fileName> for the file name."}

	// ── Import button ─────────────────────────────────────────────────────────
	Button ImportData, pos={310, 725}, size={110, 40}, proc=IR3I_ButtonProc, title="Import Selected Data"
	Button ImportData, help={"Import all selected files using the settings above"}, fColor=(0,65535,0)


	//fix GUI
	//IR3I_PopMenuProc("DataFormatPopup", whichListItem(DFMT,"ASCII SAXS/SANS;ASCII WAXS;Nexus CanSAS")+1, DFMT)

End

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
//  Button handler – dispatches to the appropriate action.
//  Using elseif so only the matching branch executes.
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_ButtonProc(ctrlName) : ButtonControl
	string ctrlName

	if(cmpstr(ctrlName, "SelectDataPath") == 0)
		IR3I_SelectDataPath()
		IR3I_UpdateListOfFilesInWvs()
	elseif(cmpstr(ctrlName, "TestImport") == 0)
		IR3I_testImport()
	elseif(cmpstr(ctrlName, "Preview") == 0 || cmpstr(ctrlName, "PreviewNX") == 0)
		IR3I_TestImportNotebook()
	elseif(cmpstr(ctrlName, "Plot") == 0)
		IR3I_TestPlotData()
	elseif(cmpstr(ctrlName, "SelectAll") == 0)
		IR3I_SelectDeselectAll(1)
	elseif(cmpstr(ctrlName, "DeSelectAll") == 0 || cmpstr(ctrlName, "DeselectAll") == 0)
		IR3I_SelectDeselectAll(0)
	elseif(cmpstr(ctrlName, "ImportData") == 0)
		IR3I_ImportSelectedData()
	elseif(cmpstr(ctrlName, "OpenFileInBrowser") == 0)
		IR3I_NexusOpenHdf5File("ImportDataPath")
	elseif(cmpstr(ctrlName, "GetHelp") == 0)
		IN2G_OpenWebManual("Irena/ImportData.html")
	endif
End

//************************************************************************************************************
//************************************************************************************************************
//  Checkbox handler.
//  Handles the new format/type controls, then delegates to the existing
//  IR3I_CheckProc for all standard checkboxes (it uses WinName(0,64) so it
//  acts on whatever panel is currently in front).
//************************************************************************************************************
//************************************************************************************************************
//Function IR3I_CheckProc(ctrlName, checked) : CheckBoxControl
//	string   ctrlName
//	variable checked
//
//	// All other checkboxes are handled by the existing (shared) handler.
//	IR3I_CheckProc(ctrlName, checked)
//
//End

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
		IR3I_UpdateListOfFilesInWvs()
	endif
	if(cmpstr(ctrlName, "NameMatchString") == 0)
		IR3I_UpdateListOfFilesInWvs()
	endif
	if(cmpstr(ctrlName, "FoundNWaves") == 0)
		IR3I_FIxCheckboxesForWaveTypes()
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
		IR3I_UpdateListOfFilesInWvs()
		// When switching back to ASCII mode, reset/update the wave names.
		if(!stringMatch(popStr, "Nexus NXcanSAS"))
			IR3I_ImportOtherSetNames()
		endif
	endif

	// WAXS X-axis type (Q-Int / D-Int / Tth-Int)
	if(cmpstr(ctrlName, "ImportDataType") == 0)
		SVAR DataTypeToImport = root:Packages:ImportData:DataTypeToImport
		DataTypeToImport = popStr
		// Show wavelength field only when 2-theta conversion is needed.
		SetVariable Wavelength, win=IR3I_ImportData, disable=!StringMatch(DataTypeToImport, "Tth-Int")
		IR3I_ImportOtherSetNames()
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

	variable isASCII  = !StringMatch(DataFormatType, "Nexus NXcanSAS")
	variable isNexus  = StringMatch(DataFormatType, "Nexus NXcanSAS")
	variable isWAXS   = StringMatch(DataFormatType, "ASCII WAXS") && (NVAR_Exists(WAXSData) ? WAXSData : 0)
	variable isTthInt = isWAXS && SVAR_Exists(DataTypeToImport) && StringMatch(DataTypeToImport, "Tth-Int")

	// WAXS sub-type popup and wavelength – only for ASCII WAXS
	PopupMenu ImportDataType,   win=IR3I_ImportData, disable=(!isWAXS * 2)
	SetVariable Wavelength,     win=IR3I_ImportData, disable=(!isTthInt * 2)

	// Section B – ASCII column mapping
	variable asciiDisable = isNexus ? 1 : 0
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
	//SetVariable FoundNWaves, win=IR3I_ImportData, disable=(isNexus ? 2 : 2)  // always read-only display
	SetVariable FoundNWaves, win=IR3I_ImportData, disable=(isNexus ? 1 : 2)  // always read-only display
	Button TestImport, win=IR3I_ImportData, disable=asciiDisable
	Button Plot,       win=IR3I_ImportData, disable=asciiDisable
	Button Preview,       win=IR3I_ImportData, disable=asciiDisable
	

	// Section C – Nexus-specific controls
	variable nexusDisable = isASCII ? 1 : 0
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

	IR3I_CheckForProperNewFolder()

	variable i, imax, icount
	string   SelectedFile
	imax   = numpnts(WaveOfSelections)
	icount = 0

	if(StringMatch(DataFormatType, "ASCII SAXS/SANS"))
		// ── ASCII SAXS/SANS: delegate to the SAS ASCII back-end ──
		for(i = 0; i < imax; i += 1)
			if(WaveOfSelections[i])
				selectedFile = WaveOfFiles[i]
				IR3I_CreateImportDataFolder(selectedFile)
				KillWaves/Z TempIntensity, TempQvector, TempError, TempQError
				IR3I_ImportOneFile(selectedFile)
				IR3I_ProcessImpWaves(selectedFile)
				IR3I_RecordResults(selectedFile)
				icount += 1
			endif
		endfor

	elseif(StringMatch(DataFormatType, "ASCII WAXS"))
		// ── ASCII WAXS: delegate to the non-SAS ASCII back-end ──
		for(i = 0; i < imax; i += 1)
			if(WaveOfSelections[i])
				selectedFile = WaveOfFiles[i]
				IR3I_CreateImportDataFolder(selectedFile)
				KillWaves/Z TempIntensity, TempQvector, TempError, TempQError
				IR3I_ImportOneFile(selectedFile)
				IR3I_ProcessImpWaves2(selectedFile)
				IR3I_RecordResults(selectedFile)
				icount += 1
			endif
		endfor

	elseif(StringMatch(DataFormatType, "Nexus NXcanSAS"))
		// ── Nexus NXcanSAS: delegate to the Nexus reader ──
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
	KillDataFolder/Z root:ImportedData
	print "Imported " + num2str(icount) + " file(s) using format: " + DataFormatType
	setDataFolder OldDf

End

//************************************************************************************************************
//************************************************************************************************************


//************************************************************************************************************
//************************************************************************************************************

Function IR3I_CheckForProperNewFolder()
 
	SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
	if(strlen(NewDataFolderName) > 0 && cmpstr(":", NewDataFolderName[strlen(NewDataFolderName) - 1]) != 0)
		NewDataFolderName = NewDataFolderName + ":"
	endif
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
// Write an import record to the Irena logbook notebook and print a summary to the history.
Function IR3I_RecordResults(selectedFile)
	string selectedFile

	DFREF oldDf = GetDataFolderDFR()
	setdataFolder root:Packages:ImportData

	SVAR DataPathName         = root:Packages:ImportData:DataPathName
	SVAR NewDataFolderName    = root:Packages:ImportData:NewDataFolderName
	SVAR NewIntensityWaveName = root:Packages:ImportData:NewIntensityWaveName
	SVAR NewQWaveName         = root:Packages:ImportData:NewQWaveName
	SVAR NewErrorWaveName     = root:Packages:ImportData:NewErrorWaveName
	SVAR NewQErrorWaveName    = root:Packages:ImportData:NewQErrorWaveName
	SVAR RemoveStringFromName = root:Packages:ImportData:RemoveStringFromName
	NVAR TrunkateStart        = root:Packages:ImportData:TrunkateStart
	NVAR TrunkateEnd          = root:Packages:ImportData:TrunkateEnd

	// inclExt=0: log always uses base name without extension.
	string NewFldrNm  = IR3I_ResolveWaveName(NewDataFolderName,    selectedFile, 0, TrunkateStart, TrunkateEnd, RemoveStringFromName)
	string NewIntName = IR3I_ResolveWaveName(NewIntensityWaveName, selectedFile, 0, TrunkateStart, TrunkateEnd, RemoveStringFromName)
	string NewQName   = IR3I_ResolveWaveName(NewQWaveName,         selectedFile, 0, TrunkateStart, TrunkateEnd, RemoveStringFromName)
	string NewEName   = IR3I_ResolveWaveName(NewErrorWaveName,     selectedFile, 0, TrunkateStart, TrunkateEnd, RemoveStringFromName)
	string NewQEName  = IR3I_ResolveWaveName(NewQErrorWaveName,    selectedFile, 0, TrunkateStart, TrunkateEnd, RemoveStringFromName)

	NVAR DataContainErrors   = root:Packages:ImportData:DataContainErrors
	NVAR CreateSQRTErrors    = root:Packages:ImportData:CreateSQRTErrors
	NVAR CreatePercentErrors = root:Packages:ImportData:CreatePercentErrors
	NVAR PercentErrorsToUse  = root:Packages:ImportData:PercentErrorsToUse
	NVAR ScaleImportedData   = root:Packages:ImportData:ScaleImportedData
	NVAR ScaleImportedDataBy = root:Packages:ImportData:ScaleImportedDataBy
	NVAR ImportSMRdata       = root:Packages:ImportData:ImportSMRdata
	NVAR SkipLines           = root:Packages:ImportData:SkipLines
	NVAR SkipNumberOfLines   = root:Packages:ImportData:SkipNumberOfLines
	NVAR QvectInA            = root:Packages:ImportData:QvectInA
	NVAR QvectInNM           = root:Packages:ImportData:QvectInNM

	NVAR DataCalibratedArbitrary = root:Packages:ImportData:DataCalibratedArbitrary
	NVAR DataCalibratedVolume    = root:Packages:ImportData:DataCalibratedVolume
	NVAR DataCalibratedWeight    = root:Packages:ImportData:DataCalibratedWeight

	IR1_CreateLoggbook() //this creates the logbook
	SVAR nbl = root:Packages:SAS_Modeling:NotebookName

	IR1L_AppendAnyText("     ")
	IR1L_AppendAnyText("***********************************************")
	IR1L_AppendAnyText("***********************************************")
	IR1L_AppendAnyText("Data load record ")
	IR1_InsertDateAndTime(nbl)
	IR1L_AppendAnyText("File path and file name \t" + DataPathName + selectedFile)
	IR1L_AppendAnyText(" ")
	IR1L_AppendAnyText("Loaded on       \t\t\t" + Date() + "    " + time())
	IR1L_AppendAnyText("Data stored in : \t\t \t" + NewFldrNm)
	IR1L_AppendAnyText("New waves named (Int,q,error) :  \t" + NewIntName + "\t" + NewQName + "\t" + NewEName)
	IR1L_AppendAnyText("Comments and processing:")
	if(DataContainErrors)
		IR1L_AppendAnyText("Data Contained errors")
	elseif(CreateSQRTErrors)
		IR1L_AppendAnyText("Data did not contain errors, created sqrt(int) errors")
	elseif(CreatePercentErrors)
		IR1L_AppendAnyText("Data did not contain errors, created %(Int) errors, used " + num2str(PercentErrorsToUse) + "  %")
	endif
	if(ScaleImportedData)
		IR1L_AppendAnyText("Data (Intensity and error) scaled by \t " + num2str(ScaleImportedDataBy))
	endif
	if(QvectInA)
		IR1L_AppendAnyText("Q was in A")
	elseif(QvectInNM)
		IR1L_AppendAnyText("Q was in nm, scaled to A ")
	endif
	if(DataCalibratedArbitrary)
		IR1L_AppendAnyText("Intensity was imported on relative scale")
	elseif(DataCalibratedVolume)
		IR1L_AppendAnyText("Intensity was imported with volume calibration [cm2/cm3]")
	elseif(DataCalibratedWeight)
		IR1L_AppendAnyText("Intensity was imported with weight calibration [cm2/g]")
	endif
	if(SkipLines)
		IR1L_AppendAnyText("Following number of lines was skiped from the original file " + num2str(SkipNumberOfLines))
	endif

	//and print in history, so user has some feedback...
	print "Imported data from :" + DataPathName + selectedFile + "\r"
	print "\tData stored in :\t\t\t" + IR3I_RemoveBadCharacters(NewFldrNm)
	if(DataContainErrors || CreateSQRTErrors || CreatePercentErrors)
		print "\tNew Wave names are :\t" + IR3I_RemoveBadCharacters(NewIntName) + "\t" + IR3I_RemoveBadCharacters(NewQName) + "\t" + IR3I_RemoveBadCharacters(NewEName) + "\r"
	else //no errors...
		print "\tNew Wave names are :\t" + NewIntName + "\t" + NewQName + "\r"
		print "\tNo errors were loaded or created \r"
	endif
	setdataFolder oldDf
End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
// Strip RemoveStringFromName from InputName and return a valid Igor name via IN2G_CreateUserName.
// TrunkateStart/TrunkateEnd are accepted but handled internally by IN2G_CreateUserName.
Function/S IR3I_TrunkateName(InputName, TrunkateStart, TrunkateEnd, RemoveStringFromName)
	string   InputName, RemoveStringFromName
	variable TrunkateStart, TrunkateEnd

	string ModName = ReplaceString(RemoveStringFromName, InputName, "")
	return IN2G_CreateUserName(ModName, 31, 0, 11)
End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

// Process and finalize an ASCII SAXS/SANS import: maps raw columns to Temp waves,
// applies unit conversion, error creation, slit smearing, trimming, rebinning,
// validates errors, then saves to final wave names in the current data folder.
Function IR3I_ProcessImpWaves(selectedFile)
	string selectedFile

	variable i, numOfInts, numOfQs, numOfErrs, numOfQErrs, refNum
	numOfInts  = 0
	numOfQs    = 0
	numOfErrs  = 0
	numOfQErrs = 0
	string   HeaderFromData    = ""
	NVAR     SkipNumberOfLines = root:Packages:ImportData:SkipNumberOfLines
	NVAR     SkipLines         = root:Packages:ImportData:SkipLines
	NVAR     FoundNWaves       = root:Packages:ImportData:FoundNWaves
	NVAR     TrunkateStart     = root:Packages:ImportData:TrunkateStart
	NVAR     TrunkateEnd       = root:Packages:ImportData:TrunkateEnd
	variable GenError          = 0

	if(!SkipLines) //lines automatically skipped, so the header may make sense, add to header...
		Open/R/P=ImportDataPath refNum as selectedFile
		HeaderFromData = ""
		variable j
		string   text
		for(j = 0; j < SkipNumberOfLines; j += 1)
			FReadLine refNum, text
			HeaderFromData += ZapNonLetterNumStart(IN2G_ZapControlCodes(text)) + ";"
		endfor
		Close refNum
	endif
	NVAR DataContainErrors = root:Packages:ImportData:DataContainErrors
	DataContainErrors = 0
	variable LimitFoundWaves = (FoundNWaves <= 6) ? FoundNWaves : 7
	for(i = 0; i < LimitFoundWaves; i += 1)
		NVAR   testIntStr   = $("root:Packages:ImportData:Col" + num2str(i + 1) + "Int")
		NVAR   testQvecStr  = $("root:Packages:ImportData:Col" + num2str(i + 1) + "Qvec")
		NVAR   testErrStr   = $("root:Packages:ImportData:Col" + num2str(i + 1) + "Err")
		NVAR   testQErrStr  = $("root:Packages:ImportData:Col" + num2str(i + 1) + "QErr")
		WAVE/Z CurrentWave  = $("wave" + num2str(i))
		SVAR   DataPathName = root:Packages:ImportData:DataPathName
		if(testIntStr && WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempIntensity
			//print "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData+";"
			note/NOCR TempIntensity, "Data imported from folder=" + DataPathName + ";Data file name=" + selectedFile + ";Data header (1st line)=" + HeaderFromData + ";"
			//print note(TempIntensity)
			numOfInts += 1
		endif
		if(testQvecStr && WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempQvector
			note/NOCR TempQvector, "Data imported from folder=" + DataPathName + ";Data file name=" + selectedFile + ";Data header (1st line)=" + HeaderFromData + ";"
			numOfQs += 1
		endif
		if(testErrStr && WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempError
			note/NOCR TempError, "Data imported from folder=" + DataPathName + ";Data file name=" + selectedFile + ";Data header (1st line)=" + HeaderFromData + ";"
			numOfErrs        += 1
			DataContainErrors = 1
		endif
		if(testQErrStr && WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempQError
			note TempQError, "Data imported from folder=" + DataPathName + ";Data file name=" + selectedFile + ";Data header (1st line)=" + HeaderFromData + ";"
			numOfQErrs += 1
		endif
		if(!testQErrStr && WaveExists(TempQError))
			killwaves/Z TempQError
		endif
		if(!WaveExists(CurrentWave))
			GenError = 0
			string Messg = "Error, the column of data selected did not exist in the data file. The missing column is : "
			if(testIntStr)
				Messg   += "Intensity"
				GenError = 1
			elseif(testQvecStr)
				Messg   += "Q vector"
				GenError = 1
			elseif(testErrStr)
				Messg   += "Error"
				GenError = 1
			elseif(testQErrStr)
				Messg   += "Q Error"
				GenError = 1
			endif
			if(GenError)
				DoAlert 0, Messg
			endif
		endif
	endfor
	if(numOfInts != 1 || numOfQs != 1 || numOfErrs > 1 || numOfQErrs > 1)
		Abort "Import waves problem, check values in checkboxes which indicate which column contains Intensity, Q and error"
	endif

	//here we will modify the data if user wants to do so...
	NVAR QvectInA            = root:Packages:ImportData:QvectInA
	NVAR QvectInNM           = root:Packages:ImportData:QvectInNM
	NVAR ScaleImportedData   = root:Packages:ImportData:ScaleImportedData
	NVAR ScaleImportedDataBy = root:Packages:ImportData:ScaleImportedDataBy
	if(QvectInNM)
		TempQvector = TempQvector / 10 //converts nm-1 in A-1  ???
		note TempQvector, "Q data converted from nm to A-1;"
		if(WaveExists(TempQError))
			TempQError = TempQError / 10
			note/NOCR TempQError, "Q error converted from nm to A-1;"
		endif
	endif
	if(ScaleImportedData)
		TempIntensity = TempIntensity * ScaleImportedDataBy //scales imported data for user
		note/NOCR TempIntensity, "Data scaled by=" + num2str(ScaleImportedDataBy) + ";"
		if(WaveExists(TempError))
			TempError = TempError * ScaleImportedDataBy //scales imported data for user
			note/NOCR TempError, "Data scaled by=" + num2str(ScaleImportedDataBy) + ";"
		endif
	endif
	//lets insert here the Units into the wave notes...
	NVAR DataCalibratedArbitrary = root:Packages:ImportData:DataCalibratedArbitrary
	NVAR DataCalibratedVolume    = root:Packages:ImportData:DataCalibratedVolume
	NVAR DataCalibratedWeight    = root:Packages:ImportData:DataCalibratedWeight
	if(DataCalibratedWeight)
		note/NOCR TempIntensity, "Units=cm2/g;"
	elseif(DataCalibratedVolume)
		note/NOCR TempIntensity, "Units=cm2/cm3;"
	elseif(DataCalibratedArbitrary)
		note/NOCR TempIntensity, "Units=Arbitrary;"
	endif

	//here we will deal with erros, if the user needs to create them
	NVAR CreateSQRTErrors    = root:Packages:ImportData:CreateSQRTErrors
	NVAR CreatePercentErrors = root:Packages:ImportData:CreatePercentErrors
	NVAR PercentErrorsToUse  = root:Packages:ImportData:PercentErrorsToUse
	if((CreatePercentErrors || CreateSQRTErrors) && WaveExists(TempError))
		DoAlert 0, "Debugging message: Should create SQRT errors, but error wave exists. Mess in the checkbox values..."
	endif
	if(CreatePercentErrors && PercentErrorsToUse < 1e-12)
		DoAlert 0, "You want to create percent error wave, but your error fraction is extremally small. This is likely error, so please, check the number and reimport the data"
		abort
	endif
	if(CreateSQRTErrors && !WaveExists(TempError))
		Duplicate/O TempIntensity, TempError
		TempError = sqrt(TempIntensity)
		note TempError, "Error data created for user as SQRT of intensity;"
	endif
	if(CreatePercentErrors && !WaveExists(TempError))
		Duplicate/O TempIntensity, TempError
		TempError = TempIntensity * (PercentErrorsToUse / 100)
		note TempError, "Error data created for user as percentage of intensity;Amount of error as percentage=" + num2str(PercentErrorsToUse / 100) + ";"
	endif
	// Remove Q <= 0 points, then sort ascending.
	TempQvector = TempQvector[p] <= 0 ? NaN : TempQvector[p]
	IR3I_RemoveNaNsFromTempWaves()
	IR3I_SortTempWaves()
	//smear the data, 	this may remove some negative intensities, so do it first
	NVAR SlitSmearData = root:Packages:ImportData:SlitSmearData
	NVAR SlitLength    = root:Packages:ImportData:SlitLength
	if(SlitSmearData && (SlitLength > 0)) //slit smear the data here...
		Duplicate/FREE TempIntensity, TempIntToSmear
		IR1B_SmearData(TempIntToSmear, TempQvector, SlitLength, TempIntensity)
		note/NOCR TempIntensity, "Slitlength=" + num2str(SlitLength) + ";"
		//next smear errors. Assume we can smear them same as intensities for now. Probably incorrect assumption, need to check somehow.
		if(WaveExists(TempError))
			Duplicate/FREE TempError, TempErrorToSmear
			IR1B_SmearData(TempErrorToSmear, TempQvector, SlitLength, TempError)
			note/NOCR TempError, "Slitlength=" + num2str(SlitLength) + ";"
		endif
		//now we need to sort out the resolution. Two choices - user provided a resolution, needs to be convoluted with slit length here
		//of user did not provide resolution, need to create here and set = slit length...
		if(!WaveExists(TempQError))
			Duplicate/O TempQvector, TempQError
			TempQError = 0
		endif
		TempQError = sqrt(TempQError[p]^2 + SlitLength^2)
	endif
	//add slit length if imported data are slit smeared...
	NVAR ImportSMRdata = root:Packages:ImportData:ImportSMRdata
	if(ImportSMRdata)
		if(SlitLength < 0.0001)
			//SLit length not set, we need tyo get that set by user...
			variable SlitLengthLocal
			Prompt SlitLengthLocal, "Bad slit length found, need correct value in [1/A]"
			DoPrompt "Missing Slit length input needed", SlitLengthLocal
			if(V_Flag)
				abort
			endif
			SlitLength = SlitLengthLocal
		endif
		note/NOCR TempIntensity, "Slitlength=" + num2str(SlitLength) + ";"
		if(WaveExists(TempError))
			note/NOCR TempError, "Slitlength=" + num2str(SlitLength) + ";"
		endif
	endif

	NVAR RemoveNegativeIntensities = root:packages:ImportData:RemoveNegativeIntensities
	if(RemoveNegativeIntensities)
		TempIntensity = TempIntensity[p] <= 0 ? NaN : TempIntensity[p]
		IR3I_RemoveNaNsFromTempWaves()
	endif

	NVAR TrimData     = root:packages:ImportData:TrimData
	NVAR TrimDataQMin = root:packages:ImportData:TrimDataQMin
	NVAR TrimDataQMax = root:packages:ImportData:TrimDataQMax
	if(TrimData)
		variable StartPointsToRemove = 0
		if(TrimDataQMin > 0)
			StartPointsToRemove = binarysearch(TempQvector, TrimDataQMin)
		endif
		variable EndPointsToRemove = numpnts(TempQvector)
		if(TrimDataQMax > 0 && TrimDataQMax < TempQvector[Inf])
			EndPointsToRemove = binarysearch(TempQvector, TrimDataQMax)
		endif
		if(TrimDataQMin > 0 && StartPointsToRemove > 0)
			TempQvector[0, StartPointsToRemove] = NaN
		endif
		if(TrimDataQMax > 0 && TrimDataQMax < TempQvector[Inf] && EndPointsToRemove > 0)
			TempQvector[EndPointsToRemove + 1, Inf] = NaN
		endif
		IR3I_RemoveNaNsFromTempWaves()
	endif

	//here rebind the data down....
	NVAR ReduceNumPnts        = root:packages:ImportData:ReduceNumPnts
	NVAR TargetNumberOfPoints = root:packages:ImportData:TargetNumberOfPoints
	if(ReduceNumPnts)
		variable tempMinStep = TempQvector[1] - TempQvector[0]
		if(WaveExists(TempError) && WaveExists(TempQError)) //have 4 waves
			IN2G_RebinLogData(TempQvector, TempIntensity, TargetNumberOfPoints, tempMinStep, Wsdev = TempError, Wxsdev = TempQError)
		elseif(WaveExists(TempError) && !WaveExists(TempQError)) //have 3 waves
			Duplicate/O TempError, TempQError
			IN2G_RebinLogData(TempQvector, TempIntensity, TargetNumberOfPoints, tempMinStep, Wsdev = TempError, Wxwidth = TempQError)
		elseif(!WaveExists(TempError) && WaveExists(TempQError)) //have 3 waves
			Duplicate/O TempQError, TempError
			IN2G_RebinLogData(TempQvector, TempIntensity, TargetNumberOfPoints, tempMinStep, Wsdev = TempError, Wxwidth = TempQError)
		else //only 2 waves
			Duplicate/O TempIntensity, TempError, TempQError
			IN2G_RebinLogData(TempQvector, TempIntensity, TargetNumberOfPoints, tempMinStep, Wsdev = TempError, Wxwidth = TempQError)
		endif
	endif
	//check on TempError if it contains meaningful number and stop user if not...
	if(!WaveExists(TempError))
		abort "The Errors (Uncertainities) data do NOT exist. Please, select a method to create them and try again."
	endif
	wavestats/Q TempError
	if((V_min <= 0) || (V_numNANs > 0) || (V_numINFs > 0))
		abort "The Errors (Uncertainities) contain negative values, 0, NANs, or INFs. This is not acceptable. Import aborted. Please, check the input data or use % or SQRT errors"
	endif

	SVAR NewIntensityWaveName   = root:packages:ImportData:NewIntensityWaveName
	SVAR NewQwaveName           = root:packages:ImportData:NewQWaveName
	SVAR NewErrorWaveName       = root:packages:ImportData:NewErrorWaveName
	SVAR NewQErrorWaveName      = root:packages:ImportData:NewQErrorWaveName
	SVAR RemoveStringFromName   = root:Packages:ImportData:RemoveStringFromName
	NVAR IncludeExtensionInName = root:packages:ImportData:IncludeExtensionInName
	string NewIntName = IR3I_ResolveWaveName(NewIntensityWaveName, selectedFile, IncludeExtensionInName, TrunkateStart, TrunkateEnd, RemoveStringFromName)
	string NewQName   = IR3I_ResolveWaveName(NewQwaveName,         selectedFile, IncludeExtensionInName, TrunkateStart, TrunkateEnd, RemoveStringFromName)
	string NewEName   = IR3I_ResolveWaveName(NewErrorWaveName,     selectedFile, IncludeExtensionInName, TrunkateStart, TrunkateEnd, RemoveStringFromName)
	string NewQEName  = IR3I_ResolveWaveName(NewQErrorWaveName,    selectedFile, IncludeExtensionInName, TrunkateStart, TrunkateEnd, RemoveStringFromName)

	if(IR3I_SaveTempWaves(NewQName, NewIntName, NewEName, NewQEName))
		abort
	endif
End
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
//************************************************************************************************************
// Replace characters that are valid in Igor names but break Irena's string parsing.
Function/S IR3I_RemoveBadCharacters(StringName)
	string StringName

	StringName = ReplaceString("(", StringName, "_")
	StringName = ReplaceString(")", StringName, "_")
	StringName = ReplaceString("{", StringName, "_")
	StringName = ReplaceString("}", StringName, "_")
	StringName = ReplaceString("%", StringName, "_")
	StringName = ReplaceString("&", StringName, "_")
	StringName = ReplaceString("$", StringName, "_")
	StringName = ReplaceString("#", StringName, "_")
	StringName = ReplaceString("@", StringName, "_")
	StringName = ReplaceString("*", StringName, "_")
	return StringName
End
//************************************************************************************************************
//************************************************************************************************************
// IR3I_GetFirstSelectedFile
// Returns the file name of the first checked entry in the list box, or "" if none are selected.
// Used by TestImport, TestImportNotebook, and TestPlotData to avoid code duplication.
//************************************************************************************************************
//************************************************************************************************************
Function/S IR3I_GetFirstSelectedFile()

	WAVE/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
	WAVE   WaveOfSelections = root:Packages:ImportData:WaveOfSelections
	variable i
	for(i = 0; i < numpnts(WaveOfSelections); i += 1)
		if(WaveOfSelections[i])
			return WaveOfFiles[i]
		endif
	endfor
	return ""
End

//************************************************************************************************************
//************************************************************************************************************
// IR3I_ResolveWaveName
// Resolves a wave-name template that may contain the "<fileName>" placeholder.
// When the placeholder is absent the literal template is cleaned and returned as-is.
// When present the placeholder is replaced with the (possibly extension-stripped) file base name.
//************************************************************************************************************
//************************************************************************************************************
Function/S IR3I_ResolveWaveName(template, selectedFile, inclExt, trunkStart, trunkEnd, removeStr)
	string   template, selectedFile, removeStr
	variable inclExt, trunkStart, trunkEnd

	if(!stringMatch(template, "*<fileName>*"))
		// Literal template — clean it directly.
		return IR3I_TrunkateName(CleanupName(IR3I_RemoveBadCharacters(template), 1), trunkStart, trunkEnd, removeStr)
	endif

	variable pos     = strsearch(template, "<fileName>", 0)
	string   prefix  = template[0, pos - 1]
	string   suffix  = template[pos + 10, Inf]
	string   baseName

	if(inclExt)
		baseName = selectedFile
	else
		// Strip the trailing extension (everything after last ".").
		string ext = StringFromList(ItemsInList(selectedFile, ".") - 1, selectedFile, ".")
		baseName   = RemoveEnding(selectedFile, "." + ext)
	endif

	baseName = IR3I_TrunkateName(baseName, trunkStart, trunkEnd, removeStr)
	return CleanupName(IR3I_RemoveBadCharacters(prefix + baseName + suffix), 1)
End

//************************************************************************************************************
//************************************************************************************************************
// IR3I_ClearColCheckboxes
// Enforces the mutual-exclusion rules for the column-assignment checkbox grid.
// Rule 1: each data type (Int/Qvec/Err/QErr) may be assigned to at most one column.
// Rule 2: each column may be assigned to at most one data type.
// Parses ctrlName of the form "ColNType" and zeroes conflicting globals.
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_ClearColCheckboxes(ctrlName)
	string ctrlName

	variable colNum = str2num(ctrlName[3])    // "Col3Qvec" -> 3
	string ctrlSuffix = ctrlName[4, Inf]      // "Int", "Qvec", "Error", "QError"

	// Map control suffix to global suffix (Error->Err, QError->QErr).
	string globalSuffix
	if(cmpstr(ctrlSuffix, "Error") == 0)
		globalSuffix = "Err"
	elseif(cmpstr(ctrlSuffix, "QError") == 0)
		globalSuffix = "QErr"
	else
		globalSuffix = ctrlSuffix
	endif

	string pkg  = "root:Packages:ImportData:"
	string types = "Int;Qvec;Err;QErr;"
	variable j

	// Clear same data type in all other columns.
	for(j = 1; j <= 6; j += 1)
		if(j != colNum)
			NVAR v = $(pkg + "Col" + num2str(j) + globalSuffix)
			v = 0
		endif
	endfor

	// Clear all other data types in the same column.
	for(j = 0; j < 4; j += 1)
		string t = StringFromList(j, types)
		if(cmpstr(t, globalSuffix) != 0)
			NVAR v2 = $(pkg + "Col" + num2str(colNum) + t)
			v2 = 0
		endif
	endfor
End

//************************************************************************************************************
//************************************************************************************************************
// IR3I_RemoveNaNsFromTempWaves
// Calls the appropriate IN2G_RemoveNaNsFromNWaves depending on which Temp waves exist.
// Avoids repeating the same 4-branch block multiple times per import function.
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_RemoveNaNsFromTempWaves()

	WAVE   TempQvector, TempIntensity
	WAVE/Z TempError, TempQError

	if(WaveExists(TempError) && WaveExists(TempQError))
		IN2G_RemoveNaNsFrom4Waves(TempQvector, TempIntensity, TempError, TempQError)
	elseif(WaveExists(TempError) && !WaveExists(TempQError))
		IN2G_RemoveNaNsFrom3Waves(TempQvector, TempIntensity, TempError)
	elseif(!WaveExists(TempError) && WaveExists(TempQError))
		IN2G_RemoveNaNsFrom3Waves(TempQvector, TempIntensity, TempQError)
	else
		IN2G_RemoveNaNsFrom2Waves(TempQvector, TempIntensity)
	endif
End

//************************************************************************************************************
//************************************************************************************************************
// IR3I_SortTempWaves
// Sorts TempQvector (and the waves that travel with it) into ascending order.
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_SortTempWaves()

	WAVE   TempQvector, TempIntensity
	WAVE/Z TempError, TempQError

	if(WaveExists(TempError))
		if(WaveExists(TempQError))
			sort TempQvector, TempQvector, TempIntensity, TempError, TempQError
		else
			sort TempQvector, TempQvector, TempIntensity, TempError
		endif
	else
		sort TempQvector, TempQvector, TempIntensity
	endif
End

//************************************************************************************************************
//************************************************************************************************************
// IR3I_SaveTempWaves
// Checks for name collisions, then duplicates Temp waves to their final names and cleans up.
// Returns 1 if the user aborted, 0 on success.
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_SaveTempWaves(newQName, newIntName, newEName, newQEName)
	string newQName, newIntName, newEName, newQEName

	NVAR   AutomaticallyOverwrite = root:Packages:ImportData:AutomaticallyOverwrite
	WAVE/Z TempError, TempQError
	WAVE/Z testI = $newIntName
	WAVE/Z testQ = $newQName
	WAVE/Z testE = $newEName
	WAVE/Z testQE = $newQEName

	if(WaveExists(testI) || WaveExists(testQ) || WaveExists(testE) || WaveExists(testQE))
		if(!AutomaticallyOverwrite)
			DoAlert 1, "The data of this name : " + newIntName + " , " + newQName + " , " + newEName + " , or " + newQEName + "  exist. DO you want to overwrite them?"
			if(V_Flag == 2)
				return 1
			endif
		else
			print "The data of this name : " + newIntName + " , " + newQName + " , " + newEName + " , or " + newQEName + "  existed. Due to user selection, old data were deleted and replaced with newly imported ones."
		endif
	endif

	Duplicate/O testQ,   $newQName
	Duplicate/O testI, $newIntName
	if(WaveExists(testE))
		Duplicate/O testE, $newEName
	endif
	if(WaveExists(testQE))
		Duplicate/O testQE, $newQEName
	endif
	KillWaves/Z testI, testQ, testE, testQE
	IR3I_KillAutoWaves()
	return 0
End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

// Load a single file using LoadWave, respecting SkipLines and ForceUTF8 settings.
// When not skipping manually, auto-detects the header line count via IR3I_CountHeaderLines.
Function IR3I_ImportOneFile(selectedFile)
	string selectedFile

	NVAR SkipNumberOfLines = root:Packages:ImportData:SkipNumberOfLines
	NVAR SkipLines         = root:Packages:ImportData:SkipLines
	NVAR ForceUTF8         = root:Packages:ImportData:ForceUTF8

	IR3I_KillAutoWaves()
	//Variable err
	if(SkipLines)
		if(ForceUTF8)
			LoadWave/Q/A/D/G/L={0, SkipNumberOfLines, 0, 0, 0}/P=ImportDataPath/ENCG={1, 4} selectedfile
		else
			LoadWave/Q/A/D/G/L={0, SkipNumberOfLines, 0, 0, 0}/P=ImportDataPath selectedfile
		endif
	else
		if(ForceUTF8)
			LoadWave/Q/A/D/G/P=ImportDataPath/ENCG={1, 4} selectedfile
		else
			LoadWave/Q/A/D/G/P=ImportDataPath selectedfile
		endif
		//; err = GetRTError(0)
		//if (err != 0)
		//	String message = GetErrMessage(err)
		//	string usermessage
		//	sprintf usermessage, "Error loading data: %s\r", message
		//	DoAlert /T="Error loading" 0, usermessage
		//	err = GetRTError(1)			// Clear error state
		//	abort
		//endif
		SkipNumberOfLines = IR3I_CountHeaderLines("ImportDataPath", selectedfile)
	endif

End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

// Count non-numeric header lines at the top of a file by reading until a line
// that begins with a number is found.  Returns -1 if the file cannot be opened.
Function IR3I_CountHeaderLines(pathName, fileName)
	string pathName   // symbolic path name
	string fileName   // file name within that path
 
	variable refNum = 0

	Open/R/P=$pathName refNum as fileName
	if(refNum == 0)
		return -1 // File was not opened. Probably bad file name.
	endif

	variable tmp
	variable count = 0
	string text
	do
		FReadLine refNum, text
		if(strlen(text) == 0)
			break
		endif

		sscanf text, "%g", tmp
		if(V_flag == 1) // Found a number at the start of the line?
			break // This marks the start of the numeric data.
		endif
		//			if( strsearch(text, FirstPoint, 0) >= 0)
		//			        break   //found first data point
		//			endif
		count += 1
	while(1)

	Close refNum

	return count
End
//************************************************************************************************************
//************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
//
// Kill the auto-named waves (wave0..wave100) created by LoadWave/A after they have been mapped.
Function IR3I_KillAutoWaves()

	variable i
	for(i = 0; i <= 100; i += 1)
		WAVE/Z test = $("wave" + num2str(i))
		KillWaves/Z test
	endfor
End
////************************************************************************************************************
////************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR3I_CreateImportDataFolder(selectedFile)
	string selectedFile
 
	SVAR NewDataFolderName      = root:packages:ImportData:NewDataFolderName
	NVAR IncludeExtensionInName = root:packages:ImportData:IncludeExtensionInName
	NVAR TrunkateStart          = root:packages:ImportData:TrunkateStart
	NVAR TrunkateEnd            = root:packages:ImportData:TrunkateEnd
	SVAR RemoveStringFromName   = root:Packages:ImportData:RemoveStringFromName
	SVAR ExtensionStr           = root:Packages:ImportData:DataExtension
	string RealExtension

	variable i
	string tempFldrName, tempSelectedFile
	setDataFolder root:
	for(i = 0; i < ItemsInList(NewDataFolderName, ":"); i += 1)
		tempFldrName = StringFromList(i, NewDataFolderName, ":")
		if(cmpstr(tempFldrName, "<fileName>") != 0)
			if(cmpstr(tempFldrName, "root") != 0)
				NewDataFolder/O/S $(cleanupName(IN2G_RemoveExtraQuote(tempFldrName, 1, 1), 1))
			endif
		else
			if(!IncludeExtensionInName)
				//selectedFile = stringFromList(0,selectedFile,".")	//5-25-2022, this removes anything from first "."
				RealExtension = stringFromList(ItemsInList(selectedFile, ".") - 1, selectedFile, ".")
				//selectedFile = removeEnding(selectedFile,"."+ExtensionStr)	//this removed user provided extension
				selectedFile = removeEnding(selectedFile, "." + RealExtension) //this removes anything behind last "." in name.
			endif
			selectedFile = IR3I_TrunkateName(selectedFile, TrunkateStart, TrunkateEnd, RemoveStringFromName)
			selectedFile = IR3I_RemoveBadCharacters(selectedFile)
			selectedFile = CleanupName(selectedFile, 1)
			NewDataFolder/O/S $selectedFile
		endif
	endfor
End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR3I_SelectDeselectAll(SetNumber)
	variable setNumber
 
	WAVE WaveOfSelections = root:Packages:ImportData:WaveOfSelections

	WaveOfSelections = SetNumber
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
// Test-load the first selected file to detect column count and update the checkbox grid.
Function IR3I_TestImport()

	string TopPanel = WinName(0, 64)

	NVAR FoundNWaves          = root:Packages:ImportData:FoundNWaves
	NVAR SkipNumberOfLines    = root:Packages:ImportData:SkipNumberOfLines
	NVAR SkipLines            = root:Packages:ImportData:SkipLines
	NVAR NumOfPointsFound     = root:Packages:ImportData:NumOfPointsFound
	SVAR TooManyPointsWarning = root:Packages:ImportData:TooManyPointsWarning
	TooManyPointsWarning = ""
	FoundNWaves          = 0
	NumOfPointsFound     = 0

	string selectedFile = IR3I_GetFirstSelectedFile()
	if(strlen(selectedFile) == 0)
		abort
	endif

	killWaves/Z wave0, wave1, wave2, wave3, wave4, wave5, wave6, wave7, wave8, wave9

	NVAR ForceUTF8 = root:Packages:ImportData:ForceUTF8
	if(SkipLines)
		if(ForceUTF8)
			LoadWave/Q/A/D/G/L={0, SkipNumberOfLines, 0, 0, 0}/P=ImportDataPath/ENCG={1, 4} selectedfile
			FoundNWaves = V_Flag
		else
			LoadWave/Q/A/D/G/L={0, SkipNumberOfLines, 0, 0, 0}/P=ImportDataPath selectedfile
			FoundNWaves = V_Flag
		endif
	else
		if(ForceUTF8)
			LoadWave/Q/A/D/G/P=ImportDataPath/ENCG={1, 4} selectedfile
			FoundNWaves = V_Flag
		else
			LoadWave/Q/A/D/G/P=ImportDataPath selectedfile
			FoundNWaves = V_Flag
		endif
	endif
	WAVE wave0
	NumOfPointsFound = numpnts(wave0)
	if(stringmatch(TopPanel, "IR3I_ImportData"))
		if(NumOfPointsFound < 300)
			sprintf TooManyPointsWarning, "Found %g data points", NumOfPointsFound
			TitleBox TooManyPointsWarning, win=IR3I_ImportData, fColor=(0, 0, 0), disable=0
		else
			sprintf TooManyPointsWarning, "%g data points, consider reduction ", NumOfPointsFound
			TitleBox TooManyPointsWarning, win=IR3I_ImportData, fColor=(65200, 0, 0), disable=0
		endif
	endif
	//now fix the checkboxes as needed
	IR3I_FIxCheckboxesForWaveTypes()
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
// Open the first selected file as read-only in a Notebook window for inspection.
Function IR3I_TestImportNotebook()

	string TopPanel    = WinName(0, 64)
	string selectedFile = IR3I_GetFirstSelectedFile()
	if(strlen(selectedFile) == 0)
		abort
	endif

	//LoadWave/Q/A/G/P=ImportDataPath  selectedfile
	KillWIndow/Z FilePreview
	NVAR ForceUTF8 = root:Packages:ImportData:ForceUTF8
	if(ForceUTF8)
		OpenNotebook/K=1/N=FilePreview/ENCG={1, 4}/P=ImportDataPath/R/V=1 selectedfile
	else
		OpenNotebook/K=1/N=FilePreview/P=ImportDataPath/R/V=1 selectedfile
	endif
	MoveWindow/W=FilePreview 450, 5, 1000, 400
	AutoPositionWindow/M=0/R=$(TopPanel) FilePreview
End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
// Import and plot the first selected file in a temporary preview graph.
Function IR3I_TestPlotData()

	string TopPanel    = WinName(0, 64)
	string OldDf       = getDataFolder(1)
	NVAR   FoundNWaves = root:Packages:ImportData:FoundNWaves

	string selectedFile = IR3I_GetFirstSelectedFile()
	if(strlen(selectedFile) == 0)
		abort
	endif

	NewDataFOlder/O/S root:Packages:IrenaImportTemp
	KillWIndow/Z FilePlotPreview
	KillWaves/Z TempIntensity, TempQvector, TempError, TempQError
	IR3I_KillAutoWaves()
	//LoadWave/Q/A/G/P=ImportDataPath  selectedfile
	IR3I_ImportOneFile(selectedFile)
	variable LimitFoundWaves = (FoundNWaves <= 6) ? FoundNWaves : 7
	variable i
	for(i = 0; i < LimitFoundWaves; i += 1)
		NVAR   testIntStr   = $("root:Packages:ImportData:Col" + num2str(i + 1) + "Int")
		NVAR   testQvecStr  = $("root:Packages:ImportData:Col" + num2str(i + 1) + "Qvec")
		NVAR   testErrStr   = $("root:Packages:ImportData:Col" + num2str(i + 1) + "Err")
		NVAR   testQErrStr  = $("root:Packages:ImportData:Col" + num2str(i + 1) + "QErr")
		WAVE/Z CurrentWave  = $("wave" + num2str(i))
		SVAR   DataPathName = root:Packages:ImportData:DataPathName
		if(testIntStr && WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempIntensity
		endif
		if(testQvecStr && WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempQvector
		endif
		if(testErrStr && WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempError
		endif
		if(testQErrStr && WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempQError
		endif
	endfor
	WAVE/Z TempIntensity
	WAVE/Z TempQvector
	WAVE/Z TempError
	WAVE/Z TempQError
	if(WaveExists(TempIntensity) && WaveExists(TempQvector))
		Display/K=1/N=IR3I_ImportDataPlot TempIntensity vs TempQvector as "Preview of the data"
		MoveWindow/W=IR3I_ImportDataPlot 450, 5, 1000, 400
		AutoPositionWindow/M=0/R=$(TopPanel) IR3I_ImportDataPlot
		DoWIndow FilePreview
		if(V_Flag)
			AutoPositionWindow/M=1/R=FilePreview IR3I_ImportDataPlot
		endif
		TextBox/C/N=text0/A=MC selectedfile
		if(WaveExists(TempError))
			if(!WaveExists(TempQError))
				ErrorBars TempIntensity, Y, wave=(TempError, TempError)
			else
				ErrorBars TempIntensity, XY, wave=(TempQError, TempQError), wave=(TempError, TempError)
			endif
		endif
		DoWindow IR3I_ImportData
		NVAR 	SAXSData=root:Packages:ImportData:SAXSData
		if(V_Flag && SAXSData)
			ModifyGraph log=1
		endif
	endif
End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

// Enable checkbox rows 1–FoundNWaves and disable rows beyond that,
// zeroing globals for disabled rows so they cannot influence the import.
Function IR3I_FIxCheckboxesForWaveTypes()

	string TopPanel    = WinName(0, 64)
	NVAR   FoundNWaves = root:Packages:ImportData:FoundNWaves
	variable maxWaves, i
	maxWaves = FoundNWaves
	if(MaxWaves > 6)
		MaxWaves = 6
	endif

	for(i = 1; i <= MaxWaves; i += 1)
		CheckBox $("Col" + num2str(i) + "Int"), disable=0, win=$(TopPanel)
		CheckBox $("Col" + num2str(i) + "Qvec"), disable=0, win=$(TopPanel)
		CheckBox $("Col" + num2str(i) + "Error"), disable=0, win=$(TopPanel)
		CheckBox $("Col" + num2str(i) + "QError"), disable=0, win=$(TopPanel)
	endfor
	for(i = FoundNWaves + 1; i <= 6; i += 1)
		CheckBox $("Col" + num2str(i) + "Int"), disable=1, win=$(TopPanel)
		CheckBox $("Col" + num2str(i) + "Qvec"), disable=1, win=$(TopPanel)
		CheckBox $("Col" + num2str(i) + "Error"), disable=1, win=$(TopPanel)
		CheckBox $("Col" + num2str(i) + "QError"), disable=1, win=$(TopPanel)
		NVAR ColInt  = $("root:Packages:ImportData:Col" + num2str(i) + "Int")
		NVAR ColQvec = $("root:Packages:ImportData:Col" + num2str(i) + "Qvec")
		NVAR ColErr  = $("root:Packages:ImportData:Col" + num2str(i) + "Err")
		NVAR ColQErr = $("root:Packages:ImportData:Col" + num2str(i) + "QErr")
		ColInt  = 0
		ColQvec = 0
		ColErr  = 0
		ColQErr = 0
	endfor

	NVAR Col1QErr = root:Packages:ImportData:Col1QErr
	NVAR Col2QErr = root:Packages:ImportData:Col2QErr
	NVAR Col3QErr = root:Packages:ImportData:Col3QErr
	NVAR Col4QErr = root:Packages:ImportData:Col4QErr
	NVAR Col5QErr = root:Packages:ImportData:Col5QErr
	NVAR Col6QErr = root:Packages:ImportData:Col6QErr
	if(Col6QErr || Col5QErr || Col4QErr || Col3QErr || Col2QErr || Col1QErr)
		SetVariable NewQErrorWaveName, disable=0
	else
		SetVariable NewQErrorWaveName, disable=1
	endif

End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

// Prompt user to select the folder containing data files and update DataPathName.
Function IR3I_SelectDataPath()

	NewPath/M="Select path to data to be imported"/O ImportDataPath
	if(V_Flag != 0)
		abort
	endif
	PathInfo ImportDataPath
	SVAR DataPathName = root:Packages:ImportData:DataPathName
	DataPathName = S_Path
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

// Master checkbox handler.  Enforces radio-button groups (SAXS/WAXS, calibration scale,
// folder naming, Q units, error type) and updates dependent control visibility.
// Column assignment grid (Col1Int..Col6QError) is delegated to IR3I_ClearColCheckboxes.
Function IR3I_CheckProc(ctrlName, checked) : CheckBoxControl
	string   ctrlName
	variable checked
	string TopPanel = WinName(0, 64)

	NVAR Col1Int  = root:Packages:ImportData:Col1Int
	NVAR Col1Qvec = root:Packages:ImportData:Col1Qvec
	NVAR Col1Err  = root:Packages:ImportData:Col1Err
	NVAR Col1QErr = root:Packages:ImportData:Col1QErr

	NVAR Col2Int  = root:Packages:ImportData:Col2Int
	NVAR Col2Qvec = root:Packages:ImportData:Col2Qvec
	NVAR Col2Err  = root:Packages:ImportData:Col2Err
	NVAR Col2QErr = root:Packages:ImportData:Col2QErr

	NVAR Col3Int  = root:Packages:ImportData:Col3Int
	NVAR Col3Qvec = root:Packages:ImportData:Col3Qvec
	NVAR Col3Err  = root:Packages:ImportData:Col3Err
	NVAR Col3QErr = root:Packages:ImportData:Col3QErr

	NVAR Col4Int  = root:Packages:ImportData:Col4Int
	NVAR Col4Qvec = root:Packages:ImportData:Col4Qvec
	NVAR Col4Err  = root:Packages:ImportData:Col4Err
	NVAR Col4QErr = root:Packages:ImportData:Col4QErr

	NVAR Col5Int  = root:Packages:ImportData:Col5Int
	NVAR Col5Qvec = root:Packages:ImportData:Col5Qvec
	NVAR Col5Err  = root:Packages:ImportData:Col5Err
	NVAR Col5QErr = root:Packages:ImportData:Col5QErr

	NVAR Col6Int  = root:Packages:ImportData:Col6Int
	NVAR Col6Qvec = root:Packages:ImportData:Col6Qvec
	NVAR Col6Err  = root:Packages:ImportData:Col6Err
	NVAR Col6QErr = root:Packages:ImportData:Col6QErr

	NVAR QvectInA            = root:Packages:ImportData:QvectInA
	NVAR QvectInNM           = root:Packages:ImportData:QvectInNM
	NVAR CreateSQRTErrors    = root:Packages:ImportData:CreateSQRTErrors
	NVAR CreatePercentErrors = root:Packages:ImportData:CreatePercentErrors

	NVAR UseFileNameAsFolder = root:Packages:ImportData:UseFileNameAsFolder
	NVAR UseIndra2Names      = root:Packages:ImportData:UseIndra2Names
	NVAR UseQRSNames         = root:Packages:ImportData:UseQRSNames
	NVAR UseQISNames         = root:Packages:ImportData:UseQISNames

	NVAR SkipLines         = root:Packages:ImportData:SkipLines
	NVAR SkipNumberOfLines = root:Packages:ImportData:SkipNumberOfLines
	NVAR DataContainErrors = root:Packages:ImportData:DataContainErrors

	NVAR TrunkateStart = root:Packages:ImportData:TrunkateStart
	NVAR TrunkateEnd   = root:Packages:ImportData:TrunkateEnd

	NVAR SlitSmearData = root:Packages:ImportData:SlitSmearData
	NVAR SlitLength    = root:Packages:ImportData:SlitLength
	NVAR ImportSMRdata = root:Packages:ImportData:ImportSMRdata

	SVAR NewDataFolderName    = root:packages:ImportData:NewDataFolderName
	SVAR NewIntensityWaveName = root:packages:ImportData:NewIntensityWaveName
	SVAR NewQwaveName         = root:packages:ImportData:NewQWaveName
	SVAR NewErrorWaveName     = root:packages:ImportData:NewErrorWaveName
	SVAR NewQErrorWaveName    = root:packages:ImportData:NewQErrorWaveName

	NVAR UseFileNameAsFolder     = root:Packages:ImportData:UseFileNameAsFolder
	NVAR UsesasEntryNameAsFolder = root:Packages:ImportData:UsesasEntryNameAsFolder
	NVAR UseTitleNameAsFolder    = root:Packages:ImportData:UseTitleNameAsFolder
	
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


	
	if(cmpstr(ctrlName, "UseFileNameAsFolderNX") == 0)
		//UseFileNameAsFolder = 0
		UsesasEntryNameAsFolder = 0
		UseTitleNameAsFolder    = 0
	endif
	if(cmpstr(ctrlName, "UsesasEntryNameAsFolderNX") == 0)
		UseFileNameAsFolder = 0
		//UsesasEntryNameAsFolder = 0
		UseTitleNameAsFolder = 0
	endif
	if(cmpstr(ctrlName, "UseTitleNameAsFolderNX") == 0)
		UseFileNameAsFolder     = 0
		UsesasEntryNameAsFolder = 0
		//UseTitleNameAsFolder = 0
	endif

	NVAR DataCalibratedArbitrary = root:Packages:ImportData:DataCalibratedArbitrary
	NVAR DataCalibratedVolume    = root:Packages:ImportData:DataCalibratedVolume
	NVAR DataCalibratedWeight    = root:Packages:ImportData:DataCalibratedWeight
	if(cmpstr(ctrlName, "DataCalibratedArbitrary") == 0)
		//DataCalibratedArbitrary = 0
		DataCalibratedVolume = 0
		DataCalibratedWeight = 0
	endif
	if(cmpstr(ctrlName, "DataCalibratedVolume") == 0)
		DataCalibratedArbitrary = 0
		//DataCalibratedVolume = 0
		DataCalibratedWeight = 0
	endif
	if(cmpstr(ctrlName, "DataCalibratedWeight") == 0)
		DataCalibratedArbitrary = 0
		DataCalibratedVolume    = 0
		//DataCalibratedWeight = 0
	endif

	NVAR DataCalibratedArbitrary = root:Packages:ImportData:DataCalibratedArbitrary
	NVAR DataCalibratedVolume    = root:Packages:ImportData:DataCalibratedVolume
	NVAR DataCalibratedWeight    = root:Packages:ImportData:DataCalibratedWeight
	if(cmpstr(ctrlName, "DataCalibratedArbitrary") == 0)
		//DataCalibratedArbitrary = 0
		DataCalibratedVolume = 0
		DataCalibratedWeight = 0
	endif
	if(cmpstr(ctrlName, "DataCalibratedVolume") == 0)
		DataCalibratedArbitrary = 0
		//DataCalibratedVolume = 0
		DataCalibratedWeight = 0
	endif
	if(cmpstr(ctrlName, "DataCalibratedWeight") == 0)
		DataCalibratedArbitrary = 0
		DataCalibratedVolume    = 0
		//DataCalibratedWeight = 0
	endif

	if(cmpstr(ctrlName, "SlitSmearDataCheckbox") == 0)
		if(checked)
			SetVariable SlitLength, disable=0
			if(UseIndra2Names)
				ImportSMRdata = 1
			endif
			DoAlert/T="Just checking..." 1, "Do you really want to slit smear imported data?"
			if(V_Flag > 1)
				ImportSMRdata = 0
				SetVariable SlitLength, disable=1
				NVAR SlitSmearData = root:Packages:ImportData:SlitSmearData
				SlitSmearData = 0
			endif
		else
			SetVariable SlitLength, disable=1
			if(UseIndra2Names)
				ImportSMRdata = 0
			endif
		endif
		IR3I_CheckProc("UseIndra2Names", UseIndra2Names)
	endif

	if(cmpstr(ctrlName, "UseFileNameAsFolder") == 0)
		CheckBox IncludeExtensionInName, disable=!(checked)
		if(checked && UseIndra2Names)
			CheckBox ImportSMRdata, disable=0
		else
			CheckBox ImportSMRdata, disable=1
		endif
		if(!checked)
			//UseFileNameAsFolder = 1
			//UseQRSNames = 0
			UseIndra2Names = 0
			if(!UseQRSNames)
				NewDataFolderName    = ""
				NewIntensityWaveName = ""
				NewQwaveName         = ""
				NewErrorWaveName     = ""
			endif
			if(stringmatch(NewDataFolderName, "*<fileName>*"))
				NewDataFolderName = RemoveFromList("<fileName>", NewDataFolderName, ":")
			endif
		else
			if(!stringmatch(NewDataFolderName, "*<fileName>*"))
				if(strlen(NewDataFolderName) == 0)
					NewDataFolderName = "root:"
				endif
				NewDataFolderName += "<fileName>:"
			endif
		endif
	endif
	if(cmpstr(ctrlName, "UseIndra2Names") == 0)
		CheckBox ImportSMRdata, disable=!checked
		if(checked)
			UseFileNameAsFolder = 1
			UseQRSNames         = 0
			UseQISNames         = 0
			//UseIndra2Names = 0
			if(ImportSMRdata)
				NewDataFolderName    = "root:USAXS:ImportedData:<fileName>:"
				NewIntensityWaveName = "SMR_Int"
				NewQwaveName         = "SMR_Qvec"
				NewErrorWaveName     = "SMR_Error"
				NewQErrorWavename    = "SMR_dQ"
			else
				NewDataFolderName    = "root:USAXS:ImportedData:<fileName>:"
				NewIntensityWaveName = "DSM_Int"
				NewQwaveName         = "DSM_Qvec"
				NewErrorWaveName     = "DSM_Error"
				NewQErrorWavename    = "DSM_dQ"
			endif
		endif
	endif

	if(cmpstr(ctrlName, "ImportSMRdata") == 0)
		NVAR UseIndra2Names = root:Packages:ImportData:UseIndra2Names
		if(checked)
			UseFileNameAsFolder = 1
			UseQRSNames         = 0
			UseQISNames         = 0
			SetVariable SlitLength, disable=0
			//UseIndra2Names = 0
			if(UseIndra2Names)
				NewDataFolderName    = "root:USAXS:ImportedData:<fileName>:"
				NewIntensityWaveName = "SMR_Int"
				NewQwaveName         = "SMR_Qvec"
				NewErrorWaveName     = "SMR_Error"
				NewQErrorWavename    = "SMR_dQ"
			endif
		else
			SetVariable SlitLength, disable=1
			if(UseIndra2Names)
				NewDataFolderName    = "root:USAXS:ImportedData:<fileName>:"
				NewIntensityWaveName = "DSM_Int"
				NewQwaveName         = "DSM_Qvec"
				NewErrorWaveName     = "DSM_Error"
				NewQErrorWavename    = "DSM_dQ"
			endif
		endif
	endif

	if(cmpstr(ctrlName, "UseQRSNames") == 0)
		if(!checked && UseIndra2Names)
			CheckBox ImportSMRdata, disable=0
		else
			CheckBox ImportSMRdata, disable=1
		endif
		if(checked)
			//UseFileNameAsFolder = 1
			UseQISNames       = 0
			UseIndra2Names    = 0
			NewDataFolderName = "root:SAS:ImportedData:"
			if(UseFileNameAsFolder)
				NewDataFolderName += "<fileName>:"
			endif
			NewIntensityWaveName = "R_<fileName>"
			NewQwaveName         = "Q_<fileName>"
			NewErrorWaveName     = "S_<fileName>"
			NewQErrorWaveName    = "W_<fileName>"
		endif
	endif
	if(cmpstr(ctrlName, "UseQISNames") == 0)
		if(!checked && UseIndra2Names)
			CheckBox ImportSMRdata, disable=0
		else
			CheckBox ImportSMRdata, disable=1
		endif
		if(checked)
			//UseFileNameAsFolder = 1
			UseQRSNames       = 0
			UseIndra2Names    = 0
			NewDataFolderName = "root:"
			//if (UseFileNameAsFolder)
			NewDataFolderName += "<fileName>:"
			//endif
			NewIntensityWaveName = "<fileName>_i"
			NewQwaveName         = "<fileName>_q"
			NewErrorWaveName     = "<fileName>_s"
			NewQErrorWaveName    = "<fileName>_w"
		endif
	endif

	if(cmpstr(ctrlName, "QvectorInA") == 0)
		if(checked)
			QvectInNM = 0
		else
			QvectInNM = 1
		endif
	endif
	if(cmpstr(ctrlName, "QvectorInNM") == 0)
		if(checked)
			QvectInA = 0
		else
			QvectInA = 1
		endif
	endif

	if(cmpstr(ctrlName, "TrimData") == 0)
		SetVariable TrimDataQMin, win=$(TopPanel), disable=!(checked)
		SetVariable TrimDataQMax, win=$(TopPanel), disable=!(checked)
	endif
	if(cmpstr(ctrlName, "TrunkateStart") == 0)
		if(checked)
			TrunkateEnd = 0
		else
			TrunkateEnd = 1
		endif
	endif

	if(cmpstr(ctrlName, "TrunkateEnd") == 0)
		if(checked)
			TrunkateStart = 0
		else
			TrunkateStart = 1
		endif
	endif

	// Column-assignment checkboxes: enforce that each type has exactly one column
	// and each column has exactly one type.  IR3I_ClearColCheckboxes does the work.
	if(GrepString(ctrlName, "^Col[1-6](Int|Qvec|Error|QError)$") && checked)
		IR3I_ClearColCheckboxes(ctrlName)
	endif
	if(stringmatch(TopPanel, "IR3I_ImportData") || stringmatch(TopPanel, "IR3I_ImportOtherASCIIData"))
		if(Col1Err || Col2Err || Col3Err || Col4Err || Col5Err || Col6Err)
			CheckBox CreateSQRTErrors, disable=1, win=$(TopPanel)
			CheckBox CreatePercentErrors, disable=1, win=$(TopPanel)
			CreateSQRTErrors    = 0
			CreatePercentErrors = 0
			SetVariable PercentErrorsToUse, disable=1
		else
			CheckBox CreateSQRTErrors, disable=0, win=$(TopPanel)
			CheckBox CreatePercentErrors, disable=0, win=$(TopPanel)
			SetVariable PercentErrorsToUse, disable=!(CreatePercentErrors)
		endif

		if(Col6QErr || Col5QErr || Col4QErr || Col3QErr || Col2QErr || Col1QErr)
			SetVariable NewQErrorWaveName, disable=0
		else
			SetVariable NewQErrorWaveName, disable=1
		endif
	endif
	if(cmpstr(ctrlName, "CreateSQRTErrors") == 0)
		if(checked)
			CreatePercentErrors = 0
			SetVariable PercentErrorsToUse, disable=1
		endif
	endif
	if(cmpstr(ctrlName, "CreatePercentErrors") == 0)
		if(checked)
			CreateSQRTErrors = 0
			SetVariable PercentErrorsToUse, disable=0
		else
			SetVariable PercentErrorsToUse, disable=1
		endif
	endif
	if(cmpstr(ctrlName, "ReduceNumPnts") == 0)
		if(checked)
			SetVariable TargetNumberOfPoints, disable=0
			//SetVariable ReducePntsParam, disable=0
		else
			SetVariable TargetNumberOfPoints, disable=1
			//SetVariable ReducePntsParam, disable=1
		endif
	endif

	if(cmpstr(ctrlName, "ScaleImportedDataCheckbox") == 0)
		if(checked)
			SetVariable ScaleImportedDataBy, disable=0
		else
			SetVariable ScaleImportedDataBy, disable=1
		endif
	endif

	if(cmpstr(ctrlName, "SkipLines") == 0)
		if(checked)
			SetVariable SkipNumberOfLines, disable=0
		else
			SetVariable SkipNumberOfLines, disable=1
		endif
	endif

End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_UpdateListOfFilesInWvs()

 	SVAR   DataPathName     = root:Packages:ImportData:DataPathName
	SVAR   DataExtension    = root:Packages:ImportData:DataExtension
	SVAR   NameMatchString  = root:Packages:ImportData:NameMatchString
	WAVE/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
	WAVE   WaveOfSelections = root:Packages:ImportData:WaveOfSelections
	SVAR	 DataFormatType   = root:Packages:ImportData:DataFormatType
	string ListOfAllFiles
	string LocalDataExtension
	variable i, imax
	LocalDataExtension = DataExtension
	if(cmpstr(LocalDataExtension[0], ".") != 0)
		LocalDataExtension = "." + LocalDataExtension
	endif
	PathInfo ImportDataPath
	if(V_Flag && strlen(DataPathName) > 0)
		if(strlen(LocalDataExtension) <= 1)
			ListOfAllFiles = IndexedFile(ImportDataPath, -1, "????")
		else
			ListOfAllFiles = IndexedFile(ImportDataPath, -1, LocalDataExtension)
		endif
		//if using Nexus NXcanSAS limit extensions to .hdf, .h5, .hdf5,  .nxs
		if(stringmatch(DataFormatType,"Nexus NXcanSAS"))
			ListOfAllFiles = GrepList(ListOfAllFiles, "(?i)\\.(hdf|h5|hdf5|nsx)$")
		endif
		if(strlen(NameMatchString) > 0)
			ListOfAllFiles = GrepList(ListOfAllFiles, NameMatchString)
		endif
		//remove Invisible Mac files, .DS_Store and .plist
		ListOfAllFiles = IN2G_RemoveInvisibleFiles(ListOfAllFiles)

		imax = ItemsInList(ListOfAllFiles, ";")
		Redimension/N=(imax) WaveOfSelections
		Redimension/N=(imax) WaveOfFiles
		for(i = 0; i < imax; i += 1)
			WaveOfFiles[i] = stringFromList(i, ListOfAllFiles, ";")
		endfor
	else
		Redimension/N=0 WaveOfSelections
		Redimension/N=0 WaveOfFiles
	endif
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR3I_InitializeImportData()

 	string OldDf = GetDataFolder(1)

	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:ImportData
	


	string   ListOfStrings
	string   ListOfVariables
	variable i

	ListOfStrings    = "DataPathName;DataExtension;IntName;QvecName;ErrorName;NewDataFolderName;NewIntensityWaveName;DataTypeToImport;"
	ListOfStrings   += "NewQWaveName;NewErrorWaveName;NewQErrorWavename;NameMatchString;TooManyPointsWarning;RemoveStringFromName;"
	ListOfStrings   += "DataFormatType;"
	ListOfVariables  = "UseFileNameAsFolder;UseIndra2Names;UseQRSNames;DataContainErrors;UseQISNames;ForceUTF8;"
	ListOfVariables += "SlitSmearData;SlitLength;UsesasEntryNameAsFolder;UseTitleNameAsFolder;"
	ListOfVariables += "CreateSQRTErrors;Col1Int;Col1Qvec;Col1Err;Col1QErr;FoundNWaves;"
	ListOfVariables += "Col2Int;Col2Qvec;Col2Err;Col2QErr;Col3Int;Col3Qvec;Col3Err;Col3QErr;Col4Int;Col4Qvec;Col4Err;Col4QErr;"
	ListOfVariables += "Col5Int;Col5Qvec;Col5Err;Col5QErr;Col6Int;Col6Qvec;Col6Err;Col6QErr;Col7Int;Col7Qvec;Col7Err;Col7QErr;"
	ListOfVariables += "QvectInA;QvectInNM;QvectInDegrees;CreateSQRTErrors;CreatePercentErrors;PercentErrorsToUse;"
	ListOfVariables += "ScaleImportedData;ScaleImportedDataBy;ImportSMRdata;SkipLines;SkipNumberOfLines;"
	ListOfVariables += "IncludeExtensionInName;RemoveNegativeIntensities;AutomaticallyOverwrite;"
	ListOfVariables += "TrimData;TrimDataQMin;TrimDataQMax;ReduceNumPnts;TargetNumberOfPoints;ReducePntsParam;"
	ListOfVariables += "NumOfPointsFound;TrunkateStart;TrunkateEnd;Wavelength;SAXSData;WAXSData;"
	ListOfVariables += "DataCalibratedArbitrary;DataCalibratedVolume;DataCalibratedWeight;"
	//Nexus
	ListOfVariables += "NX_InclsasInstrument;NX_Incl_sasSample;NX_Inclsasnote;"


	//and here we create them
	for(i = 0; i < itemsInList(ListOfVariables); i += 1)
		IN2G_CreateItem("variable", StringFromList(i, ListOfVariables))
	endfor

	for(i = 0; i < itemsInList(ListOfStrings); i += 1)
		IN2G_CreateItem("string", StringFromList(i, ListOfStrings))
	endfor

	SVAR TooManyPointsWarning
	TooManyPointsWarning = " "

	Make/O/T/N=0 WaveOfFiles
	Make/O/N=0 WaveOfSelections

	ListOfVariables  = "CreateSQRTErrors;Col1Int;Col1Qvec;Col1Err;Col1QErr;"
	ListOfVariables += "Col2Int;Col2Qvec;Col2Err;Col2QErr;Col3Int;Col3Qvec;Col3Err;Col3QErr;Col4Int;Col4Qvec;Col4Err;Col4QErr;"
	ListOfVariables += "Col5Int;Col5Qvec;Col5Err;Col5QErr;Col6Int;Col6Qvec;Col6Err;Col6QErr;Col7Int;Col7Qvec;Col7Err;Col7QErr;"
	ListOfVariables += "QvectInNM;CreateSQRTErrors;CreatePercentErrors;"
	ListOfVariables += "ScaleImportedData;ImportSMRdata;SkipLines;SkipNumberOfLines;UseQISNames;UseIndra2Names;NumOfPointsFound;"

	//We need list of known Data types for non-SAS importer
	string/G ListOfKnownDataTypes
	ListOfKnownDataTypes = "Q-Int;D-Int;Tth-Int;" //VolumeDistribution(Radius);VolumeDistribution(Diameter);"
	SVAR DataTypeToImport
	if(strlen(DataTypeToImport) < 2)
		DataTypeToImport = StringFromList(0, ListOfKnownDataTypes)
	endif
	//Set numbers to 0
	for(i = 0; i < itemsInList(ListOfVariables); i += 1)
		NVAR test = $(StringFromList(i, ListOfVariables))
		test = 0
	endfor
	ListOfVariables = "QvectInA;PercentErrorsToUse;ScaleImportedDataBy;UseFileNameAsFolder;UseQRSNames;Wavelength;"
	//Set numbers to 1
	for(i = 0; i < itemsInList(ListOfVariables); i += 1)
		NVAR test = $(StringFromList(i, ListOfVariables))
		test = 1
	endfor
	ListOfVariables = "TargetNumberOfPoints;"
	//Set numbers to 1
	for(i = 0; i < itemsInList(ListOfVariables); i += 1)
		NVAR test = $(StringFromList(i, ListOfVariables))
		if(test < 1)
			test = 200
		endif
	endfor
	ListOfVariables = "ReducePntsParam;"
	//Set numbers to 1
	for(i = 0; i < itemsInList(ListOfVariables); i += 1)
		NVAR test = $(StringFromList(i, ListOfVariables))
		if(test < 0.5)
			test = 5
		endif
	endfor

	NVAR DataCalibratedArbitrary
	NVAR DataCalibratedVolume
	NVAR DataCalibratedWeight
	if(DataCalibratedArbitrary + DataCalibratedVolume + DataCalibratedWeight != 1)
		DataCalibratedArbitrary = 0
		DataCalibratedVolume    = 1
		DataCalibratedWeight    = 0
	endif
	NVAR TrunkateStart
	NVAR TrunkateEnd
	if(TrunkateStart + TrunkateEnd != 1)
		TrunkateStart = 0
		TrunkateEnd   = 1
	endif
	NVAR QvectInA
	NVAR QvectInNM
	NVAR QvectInDegrees
	if(QvectInA + QvectInNM + QvectInDegrees != 1)
		QvectInA       = 1
		QvectInNM      = 0
		QvectInDegrees = 0
	endif

	SVAR DataFormatType = root:Packages:ImportData:DataFormatType
	if(strlen(DataFormatType) < 2)
		DataFormatType = "ASCII SAXS/SANS"
	endif
	NVAR SAXSData = root:Packages:ImportData:SAXSData
	NVAR WAXSData = root:Packages:ImportData:WAXSData
	if((SAXSData + WAXSData) != 1)
		SAXSData = 1
		WAXSData = 0
	endif

	//fix names, is faling when not run
	IR3I_ImportOtherSetNames()
	setDataFolder root:
	
	IR3I_UpdateListOfFilesInWvs()
End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

//IR3I_TestPlotData()

// Set default wave names based on the selected X-axis data type and whether file-name folders are used.
// The Q-wave prefix distinguishes data types: Q_ for Q-Int, D_ for D-Int, T_ for Tth-Int.
Function IR3I_ImportOtherSetNames()

	SVAR NewDataFolderName    = root:packages:ImportData:NewDataFolderName
	SVAR NewIntensityWaveName = root:packages:ImportData:NewIntensityWaveName
	SVAR NewQwaveName         = root:packages:ImportData:NewQWaveName
	SVAR NewErrorWaveName     = root:packages:ImportData:NewErrorWaveName
	SVAR NewQErrorWaveName    = root:packages:ImportData:NewQErrorWaveName
	NVAR UseFileNameAsFolder  = root:Packages:ImportData:UseFileNameAsFolder
	SVAR DataTypeToImport     = root:Packages:ImportData:DataTypeToImport

	if(!stringmatch(NewDataFolderName[0, 3], "root"))
		NewDataFolderName = "root:ImportedData:"
	endif
	if(UseFileNameAsFolder && (!GrepString(NewDataFolderName, "<fileName>")))
		NewDataFolderName += "<fileName>:"
	endif

	// Determine the Q-wave prefix from the data type.
	string qPrefix
	if(StringMatch(DataTypeToImport, "Q-Int"))
		qPrefix = "Q_"
	elseif(StringMatch(DataTypeToImport, "D-Int"))
		qPrefix = "D_"
	elseif(StringMatch(DataTypeToImport, "Tth-Int"))
		qPrefix = "T_"
	else
		qPrefix = "Q_"   // fallback for any future type
	endif

	if(UseFileNameAsFolder)
		NewQwaveName         = qPrefix + "<fileName>"
		NewIntensityWaveName = "R_<fileName>"
		NewErrorWaveName     = "S_<fileName>"
		NewQErrorWaveName    = "W_<fileName>"
	else
		NewQwaveName         = qPrefix + "ChangeMe"
		NewIntensityWaveName = "R_"
		NewErrorWaveName     = "S_"
		NewQErrorWaveName    = "W_"
	endif
End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

// Process and finalize an ASCII WAXS import (Q-Int, D-Int, or Tth-Int).
// Mirrors IR3I_ProcessImpWaves but omits slit-smearing and negative-Q removal,
// and applies data-type-specific unit conversions (nm→A, nm→A for D-spacing).
Function IR3I_ProcessImpWaves2(selectedFile)
	string selectedFile

	variable i, numOfInts, numOfQs, numOfErrs, numOfQErrs, refNum
	numOfInts  = 0
	numOfQs    = 0
	numOfErrs  = 0
	numOfQErrs = 0
	string   HeaderFromData    = ""
	NVAR     SkipNumberOfLines = root:Packages:ImportData:SkipNumberOfLines
	NVAR     SkipLines         = root:Packages:ImportData:SkipLines
	NVAR     FoundNWaves       = root:Packages:ImportData:FoundNWaves
	NVAR     TrunkateStart     = root:Packages:ImportData:TrunkateStart
	NVAR     TrunkateEnd       = root:Packages:ImportData:TrunkateEnd
	variable GenError          = 0

	if(!SkipLines) //lines automatically skipped, so the header may make sense, add to header...
		Open/R/P=ImportDataPath refNum as selectedFile
		HeaderFromData = ""
		variable j
		string   text
		for(j = 0; j < SkipNumberOfLines; j += 1)
			FReadLine refNum, text
			HeaderFromData += ZapNonLetterNumStart(IN2G_ZapControlCodes(text)) + ";"
		endfor
		Close refNum
	endif
	NVAR DataContainErrors = root:Packages:ImportData:DataContainErrors
	DataContainErrors = 0
	variable LimitFoundWaves = (FoundNWaves <= 6) ? FoundNWaves : 7
	for(i = 0; i < LimitFoundWaves; i += 1)
		NVAR   testIntStr   = $("root:Packages:ImportData:Col" + num2str(i + 1) + "Int")
		NVAR   testQvecStr  = $("root:Packages:ImportData:Col" + num2str(i + 1) + "Qvec")
		NVAR   testErrStr   = $("root:Packages:ImportData:Col" + num2str(i + 1) + "Err")
		NVAR   testQErrStr  = $("root:Packages:ImportData:Col" + num2str(i + 1) + "QErr")
		WAVE/Z CurrentWave  = $("wave" + num2str(i))
		SVAR   DataPathName = root:Packages:ImportData:DataPathName
		if(testIntStr && WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempIntensity
			//print "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData+";"
			note/NOCR TempIntensity, "Data imported from folder=" + DataPathName + ";Data file name=" + selectedFile + ";" + HeaderFromData + ";"
			//print note(TempIntensity)
			numOfInts += 1
		endif
		if(testQvecStr && WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempQvector
			note/NOCR TempQvector, "Data imported from folder=" + DataPathName + ";Data file name=" + selectedFile + ";" + HeaderFromData + ";"
			numOfQs += 1
		endif
		if(testErrStr && WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempError
			note/NOCR TempError, "Data imported from folder=" + DataPathName + ";Data file name=" + selectedFile + ";" + HeaderFromData + ";"
			numOfErrs        += 1
			DataContainErrors = 1
		endif
		if(testQErrStr && WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempQError
			note TempQError, "Data imported from folder=" + DataPathName + ";Data file name=" + selectedFile + ";" + HeaderFromData + ";"
			numOfQErrs += 1
		endif
		if(!WaveExists(CurrentWave))
			GenError = 0
			string Messg = "Error, the column of data selected did not exist in the data file. The missing column is : "
			if(testIntStr)
				Messg   += "Intensity"
				GenError = 1
			elseif(testQvecStr)
				Messg   += "Q vector"
				GenError = 1
			elseif(testErrStr)
				Messg   += "Error"
				GenError = 1
			elseif(testQErrStr)
				Messg   += "Q Error"
				GenError = 1
			endif
			if(GenError)
				DoAlert 0, Messg
			endif
		endif
	endfor
	if(numOfInts != 1 || numOfQs != 1 || numOfErrs > 1 || numOfQErrs > 1)
		Abort "Import waves problem, check values in checkboxes which indicate which column contains Intensity, Q and error"
	endif

	//here we will modify the data if user wants to do so...
	NVAR QvectInA            = root:Packages:ImportData:QvectInA
	NVAR QvectInNM           = root:Packages:ImportData:QvectInNM
	NVAR ScaleImportedData   = root:Packages:ImportData:ScaleImportedData
	NVAR ScaleImportedDataBy = root:Packages:ImportData:ScaleImportedDataBy
	SVAR DataTypeToImport    = root:Packages:ImportData:DataTypeToImport
	if(QvectInNM)
		if(stringMatch(DataTypeToImport, "Q-Int"))
			TempQvector = TempQvector / 10 //converts nm-1 in A-1
			note TempQvector, "Q data converted from nm to A-1;"
			if(WaveExists(TempQError))
				TempQError = TempQError / 10
				note/NOCR TempQError, "Q error converted from nm to A-1;"
			endif
		elseif(stringMatch(DataTypeToImport, "D-Int"))
			TempQvector = TempQvector * 10 //converts nm in A
			note TempQvector, "d data converted from nm to A;"
			if(WaveExists(TempQError))
				TempQError = TempQError / 10
				note/NOCR TempQError, "d error converted from nm to A;"
			endif
		endif
	endif
	if(ScaleImportedData)
		TempIntensity = TempIntensity * ScaleImportedDataBy //scales imported data for user
		note/NOCR TempIntensity, "Data scaled by=" + num2str(ScaleImportedDataBy) + ";"
		if(WaveExists(TempError))
			TempError = TempError * ScaleImportedDataBy //scales imported data for user
			note/NOCR TempError, "Data scaled by=" + num2str(ScaleImportedDataBy) + ";"
		endif
	endif
	//lets insert here the Units into the wave notes...
	//deal with wavelength if data are Tth-Int:
	if(StringMatch(DataTypeToImport, "Tth-Int"))
		NVAR Wavelength = root:Packages:ImportData:Wavelength
		note/NOCR TempIntensity, "wavelength=" + num2str(Wavelength) + ";"
		if(WaveExists(TempError))
			note/NOCR TempError, "wavelength=" + num2str(Wavelength) + ";"
		endif
		if(WaveExists(TempQError))
			note/NOCR TempQError, "wavelength=" + num2str(Wavelength) + ";"
		endif
	endif
	//here we will deal with erros, if the user needs to create them
	NVAR CreateSQRTErrors    = root:Packages:ImportData:CreateSQRTErrors
	NVAR CreatePercentErrors = root:Packages:ImportData:CreatePercentErrors
	NVAR PercentErrorsToUse  = root:Packages:ImportData:PercentErrorsToUse
	if((CreatePercentErrors || CreateSQRTErrors) && WaveExists(TempError))
		DoAlert 0, "Debugging message: Should create SQRT errors, but error wave exists. Mess in the checkbox values..."
	endif
	if(CreatePercentErrors && PercentErrorsToUse < 1e-12)
		DoAlert 0, "You want to create percent error wave, but your error fraction is extremally small. This is likely error, so please, check the number and reimport the data"
		abort
	endif
	if(CreateSQRTErrors && !WaveExists(TempError))
		Duplicate/O TempIntensity, TempError
		TempError = sqrt(TempIntensity)
		note TempError, "Error data created for user as SQRT of intensity;"
	endif
	if(CreatePercentErrors && !WaveExists(TempError))
		Duplicate/O TempIntensity, TempError
		TempError = abs(TempIntensity) * (PercentErrorsToUse / 100)
		note TempError, "Error data created for user as percentage of intensity;Amount of error as percentage=" + num2str(PercentErrorsToUse / 100) + ";"
	endif
	NVAR RemoveNegativeIntensities = root:packages:ImportData:RemoveNegativeIntensities
	if(RemoveNegativeIntensities)
		TempIntensity = TempIntensity[p] <= 0 ? NaN : TempIntensity[p]
		IR3I_RemoveNaNsFromTempWaves()
	endif
	IR3I_SortTempWaves()

	NVAR TrimData     = root:packages:ImportData:TrimData
	NVAR TrimDataQMin = root:packages:ImportData:TrimDataQMin
	NVAR TrimDataQMax = root:packages:ImportData:TrimDataQMax
	if(TrimData)
		variable StartPointsToRemove = 0
		if(TrimDataQMin > 0)
			StartPointsToRemove = binarysearch(TempQvector, TrimDataQMin)
		endif
		variable EndPointsToRemove = numpnts(TempQvector)
		if(TrimDataQMax > 0 && TrimDataQMax < TempQvector[Inf])
			EndPointsToRemove = binarysearch(TempQvector, TrimDataQMax)
		endif
		if(TrimDataQMin > 0)
			TempQvector[0, StartPointsToRemove] = NaN
		endif
		if(TrimDataQMax > 0 && TrimDataQMax < TempQvector[Inf])
			TempQvector[EndPointsToRemove + 1, Inf] = NaN
		endif
		IR3I_RemoveNaNsFromTempWaves()
	endif

	if(WaveExists(TempError))
		wavestats/Q TempError
		if((V_min <= 0) || (V_numNANs > 0) || (V_numINFs > 0))
			abort "The Errors (Uncertainities) contain negative values, 0, NANs, or INFs. This is not acceptable. Import aborted. Please, check the input data or use % or SQRT errors"
		endif
	endif

	SVAR NewIntensityWaveName   = root:packages:ImportData:NewIntensityWaveName
	SVAR NewQwaveName           = root:packages:ImportData:NewQWaveName
	SVAR NewErrorWaveName       = root:packages:ImportData:NewErrorWaveName
	SVAR NewQErrorWaveName      = root:packages:ImportData:NewQErrorWaveName
	SVAR RemoveStringFromName   = root:Packages:ImportData:RemoveStringFromName
	NVAR IncludeExtensionInName = root:packages:ImportData:IncludeExtensionInName
	string NewIntName = IR3I_ResolveWaveName(NewIntensityWaveName, selectedFile, IncludeExtensionInName, TrunkateStart, TrunkateEnd, RemoveStringFromName)
	string NewQName   = IR3I_ResolveWaveName(NewQwaveName,         selectedFile, IncludeExtensionInName, TrunkateStart, TrunkateEnd, RemoveStringFromName)
	string NewEName   = IR3I_ResolveWaveName(NewErrorWaveName,     selectedFile, IncludeExtensionInName, TrunkateStart, TrunkateEnd, RemoveStringFromName)
	string NewQEName  = IR3I_ResolveWaveName(NewQErrorWaveName,    selectedFile, IncludeExtensionInName, TrunkateStart, TrunkateEnd, RemoveStringFromName)

	if(IR3I_SaveTempWaves(NewQName, NewIntName, NewEName, NewQEName))
		abort
	endif
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR3I_NexusOpenHdf5File(PathName)
	string PathName

	WAVE/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
	WAVE   WaveOfSelections = root:Packages:ImportData:WaveOfSelections

	variable NumSelFiles       = sum(WaveOfSelections)
	variable OpenMultipleFiles = 0
	if(NumSelFiles == 0)
		return 0
	endif
	if(NumSelFiles > 1)
		DoAlert/T="Choose what to do:" 2, "You have selected multiple files, do you want to open the first one [Yes], all [No], or cancel?"
		if(V_Flag == 0)
			return 0
		elseif(V_Flag == 2)
			OpenMultipleFiles = 1
		endif
	endif

	variable i
	string   FileName
	string   browserName
	variable locFileID
	for(i = 0; i < numpnts(WaveOfSelections); i += 1)
		if(WaveOfSelections[i])
			FileName = WaveOfFiles[i]
			browserName = FileName
			//			HDf5Browser#CreateNewHDF5Browser()
			//		 	browserName = WinName(0, 64)
			//			HDF5OpenFile/R /P=ImportDataPath locFileID as FileName
			//			if (V_flag == 0)					// Open OK?
			//				HDf5Browser#UpdateAfterFileCreateOrOpen(0, browserName, locFileID, S_path, S_fileName)
			//			endif
			HDf5Browser#CreateNewHDF5Browser(PathName, FileName, 1, browserName)
			if(!OpenMultipleFiles)
				return 0
			endif
		endif
	endfor
End

//************************************************************************************************************
//************************************************************************************************************
