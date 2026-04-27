#pragma rtGlobals=3 // Use strict wave reference mode and runtime bounds checking
#pragma version=2.44
#pragma IgorVersion = 9.04



Constant IR1IversionNumber      = 2.42
Constant IR1IversionNumber2     = 2.36
Constant IR1IversionNumberNexus = 2.36

//*************************************************************************\
//* Copyright (c) 2005 - 2026, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution.
//*************************************************************************/

//2.44 IP9 and higher only, remove import of hdf5 cxop
//2.43 fix issue with satle dQ import controls which caused issues when after importing dQ one decided not to import it. 
//2.42 added Force UTF-8 = /ENCG={1,4} to LoadWave commands to be able to import ASCII from 12IDB
//2.41 fix for HDF5 changes in IP9
//2.40 minor fixes for importing Slit smeared data.
//2.39 made long names capable for Igor 8 when user chooses.
//2.38 Modified Screen Size check to match the needs
//2.37 added Plot button to SAXS importer also.
//2.36 added GetHelp button
//2.35 fixed lack of too many points message and remvoed hidden tfiles from dialogs.
//2.34 fixed problems with negative intensities which screwed up errors. Added abs(Int) for error generation and avoided error message when error was not used.
//2.33 added Nexus file importer.
//2.32 fixed window naming issue which prevented scaling from work.
//2.31 Added non SAS import tool, needs debugging and testing for all of teh known types. Not finished yet.
//2.30 fixes for labels presentation, added cleanup for imported names removing bad characters.
//2.29 added slit smearing and dq wave name
//2.28 changes for panel scaling
//2.27 fixes for naming of USAXS weave which seemed to have typo in naming system.
//2.26 added check for Error import - will abort import if Errors contain negative values, 0, INFs or NANs. Check import works with csv files.
//2.25 minor fix for data with too many columns of data - Irena can handle only first 6 columns...
//2.24 minor change in how calibration units are displayed in the panel.
//2.23 added sorting of imported waves as some users seem to have data which are not increasing in q. Weird, but possible... DOne before optional rebinning.
//2.22 changed Import rebinning on log scale to match minimum step (defined as the difference between first two original points left after trimming and 0 int removal).
//2.21 changed import to load data as double precision waves. SOme users were running out of precision.
//2.20 added RemoveStringFromName to remove part of name which user does not want to see...
//2.19 Removed error when file being imported has less columns than found originally, if these are not being imported and used.
//		enabled use of following characters in names: (){}%#^$?|&@
//2.18 modified log-rebinning to use more simple log-scale, control parameter is removed. Changed to rtGlobals=2
//         modified so any separator and leading spaces are removed when storing header info in wave note.
//         Remove negative intensities now removes 0 also (Int<=0 are removed). Same for Q<=0.
//2.17 added controls for Units - Arbitrary, cm2/cm3, and cm2/g are known units for now...
//2.16 added cleanup of weird characters (,),%, {, } of names. Allowed by igor but cause problems to my opther code.
//2.15 added vertical scrolling for panel.
//2.14 added option to trunkate long names in front or end.
//2.13 FIxed bug when selection Qmax for trimming larger than Qmax f data resulted in no data in the file at all. Fixed note when scaling data.
//2.12 removed popup to select fodler. Confusing users, keep putting data into Packages folder. Users need to type new folder names in.
//2.11 modified GUI and added ability to reduce number of points to meaningful number, added too high number of points warning.
//2.10 removed all font and font size from panel definitions to enable user control
//2.09 added ability to trim data Q range on import and small cosmetic changes.
//2.08 added match string for name of data files imported and fixed bug created in last release when data without "errors" gave Igor code error.
//2.07 modified to default to use File names for Folder Names and use qrs wave names. Clean up the waves for negative q and optionally negative intensities
//		added check for version update and forced reload.
//2.06 adds checking for snesible %error scaling (larger than 1e-12) to prevent users from creating errors with 0 in them for all points. Really happened!
//2.05 added license for ANL

//2.03 adds checking for presence of columns of data in the folder - in case user chooses wrong number of columns.
//2.02 added some print commands in history to let user know what is happening
//2.04 5/10/2010 FIxed issue with naming of the waves. Used || instead of &&, how come it actually worked (ever)?

//this should allow user to import data to Igor - let's deal with 3 column data in ASCII for now

//Function IR1I_ImportSASASCIIDataMain()
// 	IN2G_CheckScreenSize("height", 720)
//	DoWindow IR1I_ImportOtherASCIIData
//	if(V_Flag)
//		DoALert/T="Window conflict notice" 1, "Import Other ASCII data cannot be open while using this tool, close (Yes) or abort (no)?"
//		if(V_flag == 1)
//			KillWIndow/Z IR1I_ImportOtherASCIIData
//		else
//			abort
//		endif
//	endif
//	DoWindow IR1I_ImportNexusCanSASData
//	if(V_Flag)
//		DoALert/T="Window conflict notice" 1, "Import Nexus data cannot be open while using this tool, close (Yes) or abort (no)?"
//		if(V_flag == 1)
//			KillWIndow/Z IR1I_ImportNexusCanSASData
//		else
//			abort
//		endif
//	endif
//	KillWIndow/Z IR1I_ImportData
//	IR1I_InitializeImportData()
//	Execute("IR1I_ImportSASASCIIData()")
//	ING2_AddScrollControl()
//	IR1_UpdatePanelVersionNumber("IR1I_ImportData", IR1IversionNumber, 1)
//	//fix checboxes
//	IR1I_FIxCheckboxesForWaveTypes()
//End
//
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
//
//Function IR1I_MainCheckVersion()
// 	DoWindow IR1I_ImportData
//	if(V_Flag)
//		if(!IR1_CheckPanelVersionNumber("IR1I_ImportData", IR1IversionNumber))
//			DoAlert/T="The ASCII Import panel was created by incorrect version of Irena " 1, "Import ASCII may need to be restarted to work properly. Restart now?"
//			if(V_flag == 1)
//				IR3I_ImportDataMain()
//			else //at least reinitialize the variables so we avoid major crashes...
//				IR3I_InitializeImportData()
//			endif
//		endif
//	endif
//End
////************************************************************************************************************
////************************************************************************************************************
//
////Function IR1I_MainCheckVersion2()
//// 	DoWindow IR1I_ImportOtherASCIIData
////	if(V_Flag)
////		if(!IR1_CheckPanelVersionNumber("IR1I_ImportOtherASCIIData", IR1IversionNumber2))
////			DoAlert/T="The non-SAS Import panel was created by incorrect version of Irena " 1, "Import non-SAS may need to be restarted to work properly. Restart now?"
////			if(V_flag == 1)
////				IR1I_ImportOtherASCIIMain()
////			else //at least reinitialize the variables so we avoid major crashes...
////				IR1I_InitializeImportData()
////			endif
////		endif
////	endif
////End
////************************************************************************************************************
////************************************************************************************************************
//
////Function IR1I_MainCheckVersionNexus()
//// 	DoWindow IR1I_ImportNexusCanSASData
////	if(V_Flag)
////		if(!IR1_CheckPanelVersionNumber("IR1I_ImportNexusCanSASData", IR1IversionNumberNexus))
////			DoAlert/T="The Nexus Import panel was created by incorrect version of Irena " 1, "Import Nexus canSAS may need to be restarted to work properly. Restart now?"
////			if(V_flag == 1)
////				Execute/P ("IR1I_ImportNexusCanSASMain()")
////			else //at least reinitialize the variables so we avoid major crashes...
////				IR1I_InitializeImportData()
////			endif
////		endif
////	endif
////End
//
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
//
//Proc IR1I_ImportSASASCIIData()
// 	PauseUpdate // building window...
//	NewPanel/K=1/W=(3, 40, 430, 760)/N=IR1I_ImportData as "Import SAXS/SANS data"
//	TitleBox MainTitle, title="\Zr200Import SAS ASCII Data in Igor", pos={20, 5}, frame=0, fstyle=3, fixedSize=1, font="Times New Roman", size={350, 24}, anchor=MC, fColor=(0, 0, 52224)
//	TitleBox FakeLine1, title=" ", fixedSize=1, size={330, 3}, pos={16, 40}, frame=0, fColor=(0, 0, 52224), labelBack=(0, 0, 52224)
//	TitleBox Info1, title="\Zr140List of available files", pos={30, 107}, frame=0, fstyle=1, fixedSize=1, size={120, 20}, fColor=(0, 0, 52224)
//	TitleBox Info21, title="\Zr140Column 1", pos={216, 215}, frame=0, fstyle=2, fixedSize=1, size={150, 20}
//	TitleBox Info22, title="\Zr140Column 2", pos={216, 232}, frame=0, fstyle=2, fixedSize=1, size={150, 20}
//	TitleBox Info23, title="\Zr140Column 3", pos={216, 249}, frame=0, fstyle=2, fixedSize=1, size={150, 20}
//	TitleBox Info24, title="\Zr140Column 4", pos={216, 266}, frame=0, fstyle=2, fixedSize=1, size={150, 20}
//	TitleBox Info25, title="\Zr140Column 5", pos={216, 283}, frame=0, fstyle=2, fixedSize=1, size={150, 20}
//	TitleBox Info26, title="\Zr140Column 6", pos={216, 300}, frame=0, fstyle=2, fixedSize=1, size={150, 20}
//	TitleBox Info6, title="\Zr150Q", pos={287, 195}, frame=0, fstyle=2, fixedSize=0, size={40, 15}
//	TitleBox Info7, title="\Zr150Int", pos={318, 195}, frame=0, fstyle=2, fixedSize=0, size={40, 15}
//	TitleBox Info8, title="\Zr150Err", pos={351, 195}, frame=0, fstyle=2, fixedSize=0, size={40, 15}
//	TitleBox Info9, title="\Zr150dQ", pos={382, 195}, frame=0, fstyle=2, fixedSize=0, size={40, 15}
//	Button SelectDataPath, pos={99, 53}, size={130, 20}, proc=IR1I_ButtonProc, title="Select data path"
//	Button SelectDataPath, help={"Select data path to the data"}
//	Button GetHelp, pos={335, 60}, size={80, 15}, fColor=(65535, 32768, 32768), proc=IR1I_ButtonProc, title="Get Help", help={"Open www manual page for this tool"}
//	SetVariable DataPathString, pos={2, 85}, size={415, 19}, title="Data path :", noedit=1
//	SetVariable DataPathString, help={"This is currently selected data path where Igor looks for the data"}
//	SetVariable DataPathString, limits={-Inf, Inf, 0}, value=root:Packages:ImportData:DataPathName
//	SetVariable DataExtensionString, pos={220, 110}, size={150, 19}, proc=IR1I_SetVarProc, title="Data extension:"
//	SetVariable DataExtensionString, help={"Insert extension string to mask data of only some type (dat, txt, ...)"}
//	//SetVariable DataExtensionString,fSize=12
//	SetVariable DataExtensionString, value=root:Packages:ImportData:DataExtension
//
//	ListBox ListOfAvailableData, pos={7, 128}, size={196, 244}
//	ListBox ListOfAvailableData, help={"Select files from this location you want to import"}
//	ListBox ListOfAvailableData, listWave=root:Packages:ImportData:WaveOfFiles
//	ListBox ListOfAvailableData, selWave=root:Packages:ImportData:WaveOfSelections
//	ListBox ListOfAvailableData, mode=4, proc=IR1_ImportListBoxProc, special={0, 0, 1} //this will scale the width of column, users may need to slide right using slider at the bottom.
//
//	SetVariable NameMatchString, pos={10, 375}, size={180, 19}, proc=IR1I_SetVarProc, title="Match name (string):"
//	SetVariable NameMatchString, help={"Insert RegEx select only data with matching name (uses grep)"}
//	SetVariable NameMatchString, value=root:Packages:ImportData:NameMatchString
//
//	Button SelectAll, pos={5, 396}, size={80, 17}, proc=IR1I_ButtonProc, title="Select All"
//	Button SelectAll, help={"Select all waves in the list"}
//
//	Button DeSelectAll, pos={100, 396}, size={80, 17}, proc=IR1I_ButtonProc, title="Deselect All"
//	Button DeSelectAll, help={"Deselect all waves in the list"}
//
//	CheckBox SkipLines, pos={220, 133}, size={16, 14}, proc=IR1I_CheckProc, title="Skip lines?", variable=root:Packages:ImportData:SkipLines, help={"Check if you want to skip lines in header. Needed ONLY for weird headers..."}
//	SetVariable SkipNumberOfLines, pos={300, 133}, size={70, 19}, proc=IR1I_SetVarProc, title=" "
//	SetVariable SkipNumberOfLines, help={"Insert number of lines to skip"}
//	SetVariable SkipNumberOfLines, variable=root:Packages:ImportData:SkipNumberOfLines, disable=(!root:Packages:ImportData:SkipLines)
//
//	Button TestImport, pos={205, 152}, size={70, 15}, proc=IR1I_ButtonProc, title="Test"
//	Button TestImport, help={"Test how if import can be succesful and how many waves are found"}
//	Button Preview, pos={278, 152}, size={70, 15}, proc=IR1I_ButtonProc, title="Preview"
//	Button Preview, help={"Preview selected file."}
//	Button Plot, pos={350, 152}, size={70, 15}, proc=IR1I_ButtonProc, title="Plot"
//	Button Plot, help={"Preview selected file."}
//
//	TitleBox TooManyPointsWarning, variable=root:Packages:ImportData:TooManyPointsWarning, fColor=(0, 0, 0)
//	TitleBox TooManyPointsWarning, pos={220, 170}, size={150, 19}, disable=1
//	CheckBox Col1Qvec, pos={289, 216}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col1Qvec, help={"What does this column contain?"}
//	CheckBox Col1Int, pos={321, 216}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col1Int, help={"What does this column contain?"}
//	CheckBox Col1Error, pos={354, 216}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col1Err, help={"What does this column contain?"}
//	CheckBox Col1QError, pos={384, 216}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col1QErr, help={"What does this column contain?"}
//
//	CheckBox Col2Qvec, pos={289, 233}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col2Qvec, help={"What does this column contain?"}
//	CheckBox Col2Int, pos={321, 233}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col2Int, help={"What does this column contain?"}
//	CheckBox Col2Error, pos={354, 233}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col2Err, help={"What does this column contain?"}
//	CheckBox Col2QError, pos={384, 233}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col2QErr, help={"What does this column contain?"}
//
//	CheckBox Col3Qvec, pos={289, 250}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col3Qvec, help={"What does this column contain?"}
//	CheckBox Col3Int, pos={321, 250}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col3Int, help={"What does this column contain?"}
//	CheckBox Col3Error, pos={354, 250}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col3Err, help={"What does this column contain?"}
//	CheckBox Col3QError, pos={384, 250}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col3QErr, help={"What does this column contain?"}
//
//	CheckBox Col4Qvec, pos={289, 267}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col4Qvec, help={"What does this column contain?"}
//	CheckBox Col4Int, pos={321, 267}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col4Int, help={"What does this column contain?"}
//	CheckBox Col4Error, pos={354, 267}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col4Err, help={"What does this column contain?"}
//	CheckBox Col4QError, pos={384, 267}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col4QErr, help={"What does this column contain?"}
//
//	CheckBox Col5Qvec, pos={289, 284}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col5Qvec, help={"What does this column contain?"}
//	CheckBox Col5Int, pos={321, 284}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col5Int, help={"What does this column contain?"}
//	CheckBox Col5Error, pos={354, 284}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col5Err, help={"What does this column contain?"}
//	CheckBox Col5QError, pos={384, 284}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col5QErr, help={"What does this column contain?"}
//
//	CheckBox Col6Qvec, pos={289, 301}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col6Qvec, help={"What does this column contain?"}
//	CheckBox Col6Int, pos={321, 301}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col6Int, help={"What does this column contain?"}
//	CheckBox Col6Error, pos={354, 301}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col6Err, help={"What does this column contain?"}
//	CheckBox Col6QError, pos={384, 301}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col6QErr, help={"What does this column contain?"}
//
//	SetVariable FoundNWaves, pos={220, 320}, size={150, 19}, title="Found columns :", proc=IR1I_SetVarProc
//	SetVariable FoundNWaves, help={"This is how many columns were found in the tested file"}, disable=2
//	SetVariable FoundNWaves, limits={0, Inf, 0}, value=root:Packages:ImportData:FoundNWaves
//
//	CheckBox QvectorInA, pos={210, 340}, size={16, 14}, proc=IR1I_CheckProc, title="Qvec units [A^-1]", variable=root:Packages:ImportData:QvectInA, help={"What units is Q in? Select if in Angstroems ^-1"}
//	CheckBox QvectorInNM, pos={210, 355}, size={16, 14}, proc=IR1I_CheckProc, title="Qvec units [nm^-1]", variable=root:Packages:ImportData:QvectInNM, help={"What units is Q in? Select if in nanometers ^-1. WIll be converted to inverse Angstroems"}
//	CheckBox CreateSQRTErrors, pos={210, 370}, size={16, 14}, proc=IR1I_CheckProc, title="Create SQRT Errors?", variable=root:Packages:ImportData:CreateSQRTErrors, help={"If input data do not contain errors, create errors as sqrt of intensity?"}
//	CheckBox CreatePercentErrors, pos={210, 385}, size={16, 14}, proc=IR1I_CheckProc, title="Create n% Errors?", variable=root:Packages:ImportData:CreatePercentErrors, help={"If input data do not contain errors, create errors as n% of intensity?, select how many %"}
//	SetVariable PercentErrorsToUse, pos={210, 403}, size={100, 20}, title="Error %?:", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:CreatePercentErrors)
//	SetVariable PercentErrorsToUse, value=root:packages:ImportData:PercentErrorsToUse, help={"Input how many percent error you want to create."}
//
//	CheckBox ForceUTF8, pos={340, 340}, size={16, 14}, proc=IR1I_CheckProc, title="UTF-8?", variable=root:Packages:ImportData:ForceUTF8, help={"Select if you have encoding problems"}
//
//	CheckBox UseFileNameAsFolder, pos={10, 420}, size={16, 14}, proc=IR1I_CheckProc, title="Use File Nms as Fldr Nms?", variable=root:Packages:ImportData:UseFileNameAsFolder, help={"Use names of imported files as folder names for the data?"}
//	CheckBox IncludeExtensionInName, pos={240, 420}, size={16, 14}, proc=IR1I_CheckProc, title="Include Extn?", variable=root:Packages:ImportData:IncludeExtensionInName, help={"Include file extension in imported data foldername?"}, disable=!(root:Packages:ImportData:UseFileNameAsFolder)
//	CheckBox UseIndra2Names, pos={10, 436}, size={16, 14}, proc=IR1I_CheckProc, title="Use USAXS names?", variable=root:Packages:ImportData:UseIndra2Names, help={"Use wave names using Indra 2 name structure? (DSM_Int, DSM_Qvec, DSM_Error)"}
//	CheckBox ImportSMRdata, pos={150, 436}, size={16, 14}, proc=IR1I_CheckProc, title="Slit smeared?", variable=root:Packages:ImportData:ImportSMRdata, help={"Check if the data are slit smeared, changes suggested Indra data names to SMR_Qvec, SMR_Int, SMR_Error"}
//	CheckBox ImportSMRdata, disable=!root:Packages:ImportData:UseIndra2Names
//	CheckBox UseQRSNames, pos={10, 452}, size={16, 14}, proc=IR1I_CheckProc, title="Use QRS wave names?", variable=root:Packages:ImportData:UseQRSNames, help={"Use QRS name structure? (Q_filename, R_filename, S_filename)"}
//	CheckBox UseQISNames, pos={150, 452}, size={16, 14}, proc=IR1I_CheckProc, title="Use QIS (NIST) wv nms?", variable=root:Packages:ImportData:UseQISNames, help={"Use QIS name structure? (filename_q, filename_i, filename_s)"}
//
//	CheckBox AutomaticallyOverwrite, pos={300, 452}, size={16, 14}, proc=IR1I_CheckProc, title="Auto overwrite?", variable=root:Packages:ImportData:AutomaticallyOverwrite, help={"Automatically overwrite imported data if same data exist?"}, disable=!(root:Packages:ImportData:UseFileNameAsFolder)
//
//	CheckBox ScaleImportedDataCheckbox, pos={10, 472}, size={16, 14}, proc=IR1I_CheckProc, title="Scale Imported data?", variable=root:Packages:ImportData:ScaleImportedData, help={"Check to scale (multiply by) factor imported data. Both Intensity and error will be scaled by same number. Insert appriate number right."}
//	SetVariable ScaleImportedDataBy, pos={200, 472}, size={140, 20}, title="Scaling factor?:", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:ScaleImportedData)
//	SetVariable ScaleImportedDataBy, limits={1e-32, Inf, 1}, value=root:packages:ImportData:ScaleImportedDataBy, help={"Input number by which you want to multiply the imported intensity and errors."}
//	CheckBox SlitSmearDataCheckbox, pos={10, 490}, size={16, 14}, proc=IR1I_CheckProc, title="Slit Smear Imp. data?", variable=root:Packages:ImportData:SlitSmearData, help={"Check to slit smear imported data. Both Intensity and error will be smeared. Insert appriate number right."}
//	SetVariable SlitLength, pos={200, 490}, size={140, 20}, title="Slit length?:", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:SlitSmearData)
//	SetVariable SlitLength, limits={1e-32, Inf, 0}, value=root:packages:ImportData:SlitLength, help={"Input slit length in Q units."}
//
//	CheckBox RemoveNegativeIntensities, pos={10, 507}, size={16, 14}, proc=IR1I_CheckProc, title="Remove Int<=0?", variable=root:Packages:ImportData:RemoveNegativeIntensities, help={"Remove Intensities smaller than 0?"}
//
//	CheckBox TrimData, pos={10, 526}, size={16, 14}, proc=IR1I_CheckProc, title="Trim data?", variable=root:Packages:ImportData:TrimData, help={"Check to trim Q range of the imported data."}
//	SetVariable TrimDataQMin, pos={110, 524}, size={110, 20}, title="Qmin=", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:TrimData)
//	SetVariable TrimDataQMin, limits={1e-32, Inf, 0}, value=root:packages:ImportData:TrimDataQMin, help={"Qmin for trimming data. Leave 0 if not trimming at low q is needed."}
//	SetVariable TrimDataQMax, pos={240, 524}, size={110, 20}, title="Qmax=", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:TrimData)
//	SetVariable TrimDataQMax, limits={1e-32, Inf, 0}, value=root:packages:ImportData:TrimDataQMax, help={"Qmax for trimming data. Leave 0 if not trimming at low q is needed."}
//
//	CheckBox ReduceNumPnts, pos={10, 543}, size={16, 14}, proc=IR1I_CheckProc, title="Reduce points?", variable=root:Packages:ImportData:ReduceNumPnts, help={"Check to log-reduce number of points"}
//	SetVariable TargetNumberOfPoints, pos={110, 541}, size={110, 20}, title="Num points=", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:ReduceNumPnts)
//	SetVariable TargetNumberOfPoints, limits={10, 1000, 0}, value=root:packages:ImportData:TargetNumberOfPoints, help={"Target number of points after reduction. Uses same method as Data manipualtion I"}
//
//	CheckBox TrunkateStart, pos={10, 560}, size={16, 14}, proc=IR1I_CheckProc, title="Truncate start of long names?", variable=root:Packages:ImportData:TrunkateStart, help={"Truncate names longer than 24 characters in front"}
//	CheckBox TrunkateEnd, pos={240, 560}, size={16, 14}, proc=IR1I_CheckProc, title="Truncate end of long names?", variable=root:Packages:ImportData:TrunkateEnd, help={"Truncate names longer than 24 characters at the end"}
//	SetVariable RemoveStringFromName, pos={5, 578}, size={320, 20}, title="Remove Str From Name=", noproc
//	SetVariable RemoveStringFromName, value=root:packages:ImportData:RemoveStringFromName, help={"Input string to be removed from name, leve empty if none"}
//
//	CheckBox DataCalibratedArbitrary, pos={10, 597}, size={16, 14}, mode=1, proc=IR1I_CheckProc, title="Calibration Arbitrary\S \M", variable=root:Packages:ImportData:DataCalibratedArbitrary, help={"Data not calibrated (on relative scale)"}
//	CheckBox DataCalibratedVolume, pos={150, 597}, size={16, 14}, mode=1, proc=IR1I_CheckProc, title="Calibration cm\S-1\Msr\S-1\M", variable=root:Packages:ImportData:DataCalibratedVolume, help={"Data calibrated to volume"}
//	CheckBox DataCalibratedWeight, pos={290, 597}, size={16, 14}, mode=1, proc=IR1I_CheckProc, title="Calibration cm\S2\Mg\S-1\Msr\S-1\M", variable=root:Packages:ImportData:DataCalibratedWeight, help={"Data calibrated to weight"}
//
//	SetVariable NewDataFolderName, pos={5, 620}, size={410, 20}, title="New data folder:", proc=IR1I_setvarProc
//	SetVariable NewDataFolderName, value=root:packages:ImportData:NewDataFolderName, help={"Folder for the new data. Will be created, if does not exist. Use popup above to preselect."}
//	SetVariable NewQwaveName, pos={5, 640}, size={320, 20}, title="Q wave names ", proc=IR1I_setvarProc
//	SetVariable NewQwaveName, value=root:packages:ImportData:NewQWaveName, help={"Input name for the new Q wave"}
//	SetVariable NewIntensityWaveName, pos={5, 660}, size={320, 20}, title="Intensity names", proc=IR1I_setvarProc
//	SetVariable NewIntensityWaveName, value=root:packages:ImportData:NewIntensityWaveName, help={"Input name for the new intensity wave"}
//	SetVariable NewErrorWaveName, pos={5, 680}, size={320, 20}, title="Error wv names", proc=IR1I_setvarProc
//	SetVariable NewErrorWaveName, value=root:packages:ImportData:NewErrorWaveName, help={"Input name for the new Error wave"}
//	SetVariable NewQErrorWaveName, pos={5, 700}, size={320, 20}, title="dQ wv names  ", proc=IR1I_setvarProc
//	SetVariable NewQErrorWaveName, value=root:packages:ImportData:NewQErrorWaveName, help={"Input name for the new Q data Error wave"}
//
//	Button ImportData, pos={330, 660}, size={80, 30}, proc=IR1I_ButtonProc, title="Import"
//	Button ImportData, help={"Import the selected data files."}
//
//	IR1I_CheckProc("UseQRSNames", 1)
//
//EndMacro
//
////************************************************************************************************************
////************************************************************************************************************
//Function IR1_ImportListBoxProc(lba) : ListBoxControl
//	STRUCT WMListboxAction &lba
// 
//	variable row      = lba.row
//	variable col      = lba.col
//	WAVE/Z/T listWave = lba.listWave
//	WAVE/Z   selWave  = lba.selWave
//
//	switch(lba.eventCode)
//		case -1: // control being killed
//			break
//		case 1: // mouse down
//			break
//		case 3: // double click
//			IR1I_testImport()
//			IR1I_TestImportNotebook()
//			break
//		case 4: // cell selection
//		case 5: // cell selection plus shift key
//			break
//		case 6: // begin edit
//			break
//		case 7: // finish edit
//			break
//		case 13: // checkbox clicked (Igor 6.2 or later)
//			break
//	endswitch
//
//	return 0
//End
////************************************************************************************************************
////************************************************************************************************************
//Function IR1I_ImportDataFnct()
// 
//	string TopPanel         = WinName(0, 64)
//	string OldDf            = getDataFolder(1)
//	WAVE/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
//	WAVE   WaveOfSelections = root:Packages:ImportData:WaveOfSelections
//
//	IR1I_CheckForProperNewFolder()
//	variable i, imax, icount
//	string SelectedFile
//	imax   = numpnts(WaveOfSelections)
//	icount = 0
//	for(i = 0; i < imax; i += 1)
//		if(WaveOfSelections[i])
//			selectedfile = WaveOfFiles[i]
//			IR1I_CreateImportDataFolder(selectedFile)
//			KillWaves/Z TempIntensity, TempQvector, TempError
//			IR1I_ImportOneFile(selectedFile)
//			IR1I_ProcessImpWaves(selectedFile) //this thing also creates new error waves, removes negative qs and intesities and does everything else
//			IR1I_RecordResults(selectedFile)
//			icount += 1
//		endif
//	endfor
//	print "Imported " + num2str(icount) + " data file(s) in total"
//	setDataFolder OldDf
//End
//
////**********************************************************************************************************
////**********************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
//
//Function IR1I_PopMenuProc(ctrlName, popNum, popStr) : PopupMenuControl
//	string   ctrlName
//	variable popNum
//	string   popStr
// 
//	if(Cmpstr(ctrlName, "SelectFolderNewData") == 0)
//		SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
//		NewDataFolderName = popStr
//		NVAR UseFileNameAsFolder = root:Packages:ImportData:UseFileNameAsFolder
//		if(UseFileNameAsFolder)
//			NewDataFolderName += "<fileName>:"
//		endif
//	endif
//	if(Cmpstr(ctrlName, "SelectFolderNewData2") == 0)
//		SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
//		if(stringMatch(popStr, "---"))
//			NewDataFolderName = "root:ImportedData:"
//		else
//			NewDataFolderName = popStr
//		endif
//		NVAR UseFileNameAsFolder = root:Packages:ImportData:UseFileNameAsFolder
//		if(UseFileNameAsFolder)
//			NewDataFolderName += "<fileName>:"
//		endif
//	endif
//	if(Cmpstr(ctrlName, "ImportDataType") == 0)
//		SVAR DataTypeToImport = root:Packages:ImportData:DataTypeToImport
//		DataTypeToImport = popStr
//		SetVariable Wavelength, win=IR1I_ImportOtherASCIIData, disable=!StringMatch(DataTypeToImport, "Tth-Int")
//		IR1I_ImportOtherSetNames()
//	endif
//End
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
//
//Function IR1I_SetVarProc(ctrlName, varNum, varStr, varName) : SetVariableControl
//	string   ctrlName
//	variable varNum
//	string   varStr
//	string   varName
// 
//	if(cmpstr(ctrlName, "DataExtensionString") == 0)
//		IR1I_UpdateListOfFilesInWvs()
//	endif
//	if(cmpstr(ctrlName, "NameMatchString") == 0)
//		IR1I_UpdateListOfFilesInWvs()
//	endif
//	if(cmpstr(ctrlName, "FoundNWaves") == 0)
//		IR1I_FIxCheckboxesForWaveTypes()
//	endif
//
//End
//
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
//Function IR1I_ButtonProc(ctrlName) : ButtonControl
//	string ctrlName
// 
//	if(cmpstr(ctrlName, "SelectDataPath") == 0)
//		IR1I_SelectDataPath()
//		IR1I_UpdateListOfFilesInWvs()
//	endif
//	if(cmpstr(ctrlName, "TestImport") == 0)
//		IR1I_testImport()
//	endif
//	if(cmpstr(ctrlName, "GetHelp") == 0)
//		//Open www manual with the right page
//		IN2G_OpenWebManual("Irena/ImportData.html")
//	endif
//	if(cmpstr(ctrlName, "Preview") == 0)
//		IR1I_TestImportNotebook()
//	endif
//	if(cmpstr(ctrlName, "Plot") == 0)
//		IR1I_TestPlotData()
//	endif
//	if(cmpstr(ctrlName, "SelectAll") == 0)
//		IR1I_SelectDeselectAll(1)
//	endif
//	if(cmpstr(ctrlName, "DeselectAll") == 0)
//		IR1I_SelectDeselectAll(0)
//	endif
//	if(cmpstr(ctrlName, "ImportData") == 0)
//		IR1I_ImportDataFnct()
//	endif
//	if(cmpstr(ctrlName, "ImportData2") == 0)
//		IR1I_ImportDataFnct2()
//	endif
//	if(cmpstr(ctrlName, "ImportDataNexus") == 0)
//		IR1I_ImportDataFnctNexus()
//	endif
//	if(cmpstr(ctrlName, "OpenFileInBrowser") == 0)
//		IR1I_NexusOpenHdf5File("ImportDataPath")
//	endif
//
//End
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
//
////Function IR1I_ImportOtherASCIIMain()
//// 	//IR1_KillGraphsAndPanels()
////	IN2G_CheckScreenSize("height", 720)
////	DoWindow IR1I_ImportData
////	if(V_Flag)
////		DoALert/T="Window conflict notice" 1, "Import SAS ASCII data cannot be open while using this tool, close (Yes) or abort (no)?"
////		if(V_flag == 1)
////			KillWIndow/Z IR1I_ImportData
////		else
////			abort
////		endif
////	endif
////	DoWindow IR1I_ImportNexusCanSASData
////	if(V_Flag)
////		DoALert/T="Window conflict notice" 1, "Import Nexus data cannot be open while using this tool, close (Yes) or abort (no)?"
////		if(V_flag == 1)
////			KillWIndow/Z IR1I_ImportNexusCanSASData
////		else
////			abort
////		endif
////	endif
////	KillWIndow/Z IR1I_ImportOtherASCIIData
////	IR1I_InitializeImportData()
////	IR1I_ImportOtherASCIIDataFnct()
////	ING2_AddScrollControl()
////	IR1_UpdatePanelVersionNumber("IR1I_ImportOtherASCIIData", IR1IversionNumber2, 1)
////	//fix checboxes
////	//IR1I_FIxCheckboxesForWaveTypes()
////End
//
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
//
//Function IR1I_ImportOtherASCIIDataFnct()
// 	PauseUpdate // building window...
//	NewPanel/K=1/W=(3, 40, 430, 760)/N=IR1I_ImportOtherASCIIData as "Import non-SAS data"
//	TitleBox MainTitle, title="\Zr200Import non SAS ASCII Data in Igor", pos={20, 5}, frame=0, fstyle=3, fixedSize=1, font="Times New Roman", size={400, 24}, anchor=MC, fColor=(0, 0, 52224)
//	TitleBox FakeLine1, title=" ", fixedSize=1, size={330, 3}, pos={16, 40}, frame=0, fColor=(0, 0, 52224), labelBack=(0, 0, 52224)
//	TitleBox Info21, title="\Zr140Col. 1", pos={239, 192}, frame=0, fstyle=2, fixedSize=1, size={150, 20}
//	TitleBox Info22, title="\Zr140Col. 2", pos={239, 209}, frame=0, fstyle=2, fixedSize=1, size={150, 20}
//	TitleBox Info23, title="\Zr140Col. 3", pos={239, 226}, frame=0, fstyle=2, fixedSize=1, size={150, 20}
//	TitleBox Info24, title="\Zr140Col. 4", pos={239, 243}, frame=0, fstyle=2, fixedSize=1, size={150, 20}
//	TitleBox Info25, title="\Zr140Col. 5", pos={239, 260}, frame=0, fstyle=2, fixedSize=1, size={150, 20}
//	TitleBox Info26, title="\Zr140Col. 6", pos={239, 277}, frame=0, fstyle=2, fixedSize=1, size={150, 20}
//	TitleBox Info6, title="\Zr150X", pos={298, 172}, frame=0, fstyle=2, fixedSize=0, size={40, 15}
//	TitleBox Info7, title="\Zr150Y", pos={330, 172}, frame=0, fstyle=2, fixedSize=0, size={40, 15}
//	TitleBox Info8, title="\Zr150dY", pos={360, 172}, frame=0, fstyle=2, fixedSize=0, size={40, 15}
//	TitleBox Info9, title="\Zr150dX", pos={392, 172}, frame=0, fstyle=2, fixedSize=0, size={40, 15}
//
//	IR3C_AddDataControls("ImportDataPath", "ImportData", "IR1I_ImportOtherASCIIData", "", "", "", "IR1I_DoubleClickFUnction")
//	ListBox ListOfAvailableData, size={220, 277}, pos={5, 113}
//	Button SelectAll, pos={5, 395}
//	Button DeSelectAll, pos={120, 395}
//
//	CheckBox SkipLines, pos={230, 133}, size={16, 14}, proc=IR1I_CheckProc, title="Skip lines?", variable=root:Packages:ImportData:SkipLines, help={"Check if you want to skip lines in header. Needed ONLY for weird headers..."}
//	SetVariable SkipNumberOfLines, pos={300, 133}, size={70, 19}, proc=IR1I_SetVarProc, title=" "
//	SetVariable SkipNumberOfLines, help={"Insert number of lines to skip"}
//	NVAR DisableSkipLines = root:Packages:ImportData:SkipLines
//	SetVariable SkipNumberOfLines, variable=root:Packages:ImportData:SkipNumberOfLines, disable=(!DisableSkipLines)
//
//	Button TestImport, pos={230, 152}, size={80, 15}, proc=IR1I_ButtonProc, title="Test"
//	Button TestImport, help={"Test how if import can be succesful and how many waves are found"}
//	Button Preview, pos={330, 152}, size={80, 15}, proc=IR1I_ButtonProc, title="Preview"
//	Button Preview, help={"Preview selected file."}
//	Button GetHelp, pos={335, 60}, size={80, 15}, fColor=(65535, 32768, 32768), proc=IR1I_ButtonProc, title="Get Help", help={"Open www manual page for this tool"}
//	//
//	CheckBox Col1Qvec, pos={299, 192}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col1Qvec, help={"What does this column contain?"}
//	CheckBox Col1Int, pos={331, 192}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col1Int, help={"What does this column contain?"}
//	CheckBox Col1Error, pos={364, 192}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col1Err, help={"What does this column contain?"}
//	CheckBox Col1QError, pos={394, 192}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col1QErr, help={"What does this column contain?"}
//
//	CheckBox Col2Qvec, pos={299, 209}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col2Qvec, help={"What does this column contain?"}
//	CheckBox Col2Int, pos={331, 209}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col2Int, help={"What does this column contain?"}
//	CheckBox Col2Error, pos={364, 209}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col2Err, help={"What does this column contain?"}
//	CheckBox Col2QError, pos={394, 209}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col2QErr, help={"What does this column contain?"}
//
//	CheckBox Col3Qvec, pos={299, 226}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col3Qvec, help={"What does this column contain?"}
//	CheckBox Col3Int, pos={331, 226}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col3Int, help={"What does this column contain?"}
//	CheckBox Col3Error, pos={364, 226}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col3Err, help={"What does this column contain?"}
//	CheckBox Col3QError, pos={394, 226}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col3QErr, help={"What does this column contain?"}
//
//	CheckBox Col4Qvec, pos={299, 243}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col4Qvec, help={"What does this column contain?"}
//	CheckBox Col4Int, pos={331, 243}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col4Int, help={"What does this column contain?"}
//	CheckBox Col4Error, pos={364, 243}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col4Err, help={"What does this column contain?"}
//	CheckBox Col4QError, pos={394, 243}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col4QErr, help={"What does this column contain?"}
//
//	CheckBox Col5Qvec, pos={299, 260}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col5Qvec, help={"What does this column contain?"}
//	CheckBox Col5Int, pos={331, 260}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col5Int, help={"What does this column contain?"}
//	CheckBox Col5Error, pos={364, 260}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col5Err, help={"What does this column contain?"}
//	CheckBox Col5QError, pos={394, 260}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col5QErr, help={"What does this column contain?"}
//
//	CheckBox Col6Qvec, pos={299, 277}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col6Qvec, help={"What does this column contain?"}
//	CheckBox Col6Int, pos={331, 277}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col6Int, help={"What does this column contain?"}
//	CheckBox Col6Error, pos={364, 277}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col6Err, help={"What does this column contain?"}
//	CheckBox Col6QError, pos={394, 277}, size={16, 14}, proc=IR1I_CheckProc, title="", variable=root:Packages:ImportData:Col6QErr, help={"What does this column contain?"}
//
//	//
//	//
//	SetVariable FoundNWaves, pos={239, 296}, size={160, 19}, title="Found cols.:  ", proc=IR1I_SetVarProc
//	SetVariable FoundNWaves, help={"This is how many columns were found in the tested file"}, disable=2
//	SetVariable FoundNWaves, limits={0, Inf, 0}, value=root:Packages:ImportData:FoundNWaves
//
//	Button Plot, pos={330, 317}, size={80, 15}, proc=IR1I_ButtonProc, title="Plot"
//	Button Plot, help={"Preview selected file."}
//
//	CheckBox QvectorInA, pos={240, 340}, size={16, 14}, proc=IR1I_CheckProc, title="X units [1/A, deg, A]", variable=root:Packages:ImportData:QvectInA, help={"What units is X in? Select if in 1/A for Q, A for d, degree for TwoTheta"}
//	CheckBox QvectorInNM, pos={240, 355}, size={16, 14}, proc=IR1I_CheckProc, title="X units [1/nm or nm]", variable=root:Packages:ImportData:QvectInNM, help={"What units is X in? Select if in 1/nm for Q or nm for d. WIll be converted to 1/A or A"}
//	//CheckBox QvectInDegrees,pos={240,355},size={16,14},proc=IR1I_CheckProc,title="X units [degree]",variable= root:Packages:ImportData:QvectInDegrees, help={"What units is X axis in? Select if in degrees... WIll be converted to inverse Angstroems"}
//
//	CheckBox CreateSQRTErrors, pos={240, 370}, size={16, 14}, proc=IR1I_CheckProc, title="Create SQRT dY?", variable=root:Packages:ImportData:CreateSQRTErrors, help={"If input data do not contain errors, create errors as sqrt of intensity?"}
//	CheckBox CreatePercentErrors, pos={240, 385}, size={16, 14}, proc=IR1I_CheckProc, title="Create n% dY?", variable=root:Packages:ImportData:CreatePercentErrors, help={"If input data do not contain errors, create errors as n% of intensity?, select how many %"}
//	NVAR DiablePctErr = root:Packages:ImportData:CreatePercentErrors
//	SetVariable PercentErrorsToUse, pos={240, 403}, size={100, 20}, title="dY %?:", proc=IR1I_setvarProc, disable=!(DiablePctErr)
//	SetVariable PercentErrorsToUse, value=root:packages:ImportData:PercentErrorsToUse, help={"Input how many percent error you want to create."}
//	CheckBox UseFileNameAsFolder, pos={10, 420}, size={16, 14}, proc=IR1I_CheckProc, title="Use File Nms as Fldr Nms?", variable=root:Packages:ImportData:UseFileNameAsFolder, help={"Use names of imported files as folder names for the data?"}
//	NVAR DisableExt  = root:Packages:ImportData:UseFileNameAsFolder
//	NVAR DisableOver = root:Packages:ImportData:UseFileNameAsFolder
//	CheckBox AutomaticallyOverwrite, pos={240, 420}, size={16, 14}, proc=IR1I_CheckProc, title="Overwrite existing data?", variable=root:Packages:ImportData:AutomaticallyOverwrite, help={"Automatically overwrite imported data if same data exist?"}, disable=!(DisableOver)
//
//	SVAR DataTypeToImport     = root:Packages:ImportData:DataTypeToImport
//	SVAR ListOfKnownDataTypes = root:Packages:ImportData:ListOfKnownDataTypes
//	PopupMenu ImportDataType, pos={10, 450}, size={250, 21}, proc=IR1I_PopMenuProc, title="Data Type", help={"Select waht data are being imported for proper naming"}
//	PopupMenu ImportDataType, mode=1, popvalue=DataTypeToImport, value=#"root:Packages:ImportData:ListOfKnownDataTypes"
//	SetVariable Wavelength, pos={260, 453}, size={150, 10}, variable=root:Packages:ImportData:Wavelength, noproc, help={"For Two Theta (Tth) we need wavelength in A"}
//	SetVariable Wavelength, disable=!StringMatch(DataTypeToImport, "Tth-Int")
//
//	CheckBox ScaleImportedDataCheckbox, pos={10, 475}, size={16, 14}, proc=IR1I_CheckProc, title="Scale Imported data?", variable=root:Packages:ImportData:ScaleImportedData, help={"Check to scale (multiply by) factor imported data. Both Intensity and error will be scaled by same number. Insert appriate number right."}
//	NVAR DisableScale = root:Packages:ImportData:ScaleImportedData
//	SetVariable ScaleImportedDataBy, pos={200, 475}, size={140, 20}, title="Scaling factor?:", proc=IR1I_setvarProc, disable=!(DisableScale)
//	SetVariable ScaleImportedDataBy, limits={1e-32, Inf, 1}, value=root:packages:ImportData:ScaleImportedDataBy, help={"Input number by which you want to multiply the imported intensity and errors."}
//	CheckBox RemoveNegativeIntensities, pos={10, 500}, size={16, 14}, proc=IR1I_CheckProc, title="Remove Int<=0?", variable=root:Packages:ImportData:RemoveNegativeIntensities, help={"Remove Intensities smaller than 0?"}
//	NVAR DisableTrim = root:Packages:ImportData:TrimData
//	CheckBox TrimData, pos={10, 526}, size={16, 14}, proc=IR1I_CheckProc, title="Trim data?", variable=root:Packages:ImportData:TrimData, help={"Check to trim Q range of the imported data."}
//	SetVariable TrimDataQMin, pos={110, 524}, size={110, 20}, title="X min=", proc=IR1I_setvarProc, disable=!(DisableTrim)
//	SetVariable TrimDataQMin, limits={0, Inf, 0}, value=root:packages:ImportData:TrimDataQMin, help={"Xmin for trimming data. Leave 0 if not trimming at low q is needed."}
//	SetVariable TrimDataQMax, pos={240, 524}, size={110, 20}, title="X max=", proc=IR1I_setvarProc, disable=!(DisableTrim)
//	SetVariable TrimDataQMax, limits={0, Inf, 0}, value=root:packages:ImportData:TrimDataQMax, help={"Xmax for trimming data. Leave 0 if not trimming at low q is needed."}
//	//
//	CheckBox TrunkateStart, pos={10, 545}, size={16, 14}, proc=IR1I_CheckProc, title="Truncate start of long names?", variable=root:Packages:ImportData:TrunkateStart, help={"Truncate names longer than 24 characters in front"}
//	CheckBox TrunkateEnd, pos={240, 545}, size={16, 14}, proc=IR1I_CheckProc, title="Truncate end of long names?", variable=root:Packages:ImportData:TrunkateEnd, help={"Truncate names longer than 24 characters at the end"}
//	SetVariable RemoveStringFromName, pos={5, 565}, size={320, 20}, title="Remove Str From Name=", noproc
//	SetVariable RemoveStringFromName, value=root:packages:ImportData:RemoveStringFromName, help={"Input string to be removed from name, leve empty if none"}
//	PopupMenu SelectFolderNewData2, pos={10, 590}, size={250, 21}, proc=IR1I_PopMenuProc, title="Select data folder", help={"Select folder with data"}
//	PopupMenu SelectFolderNewData2, mode=1, popvalue="---", value=#"\"---;\"+IN2G_NewFindFolderWithWaveTypes(\"root:\", 10, \"*\", 1)"
//	SetVariable NewDataFolderName, pos={5, 620}, size={410, 20}, title="New data folder:", proc=IR1I_setvarProc
//	SetVariable NewDataFolderName, value=root:packages:ImportData:NewDataFolderName, help={"Folder for the new data. Will be created, if does not exist.Or pick one ip popup above"}
//	SetVariable NewQwaveName, pos={5, 640}, size={320, 20}, title="X wave names ", proc=IR1I_setvarProc
//	SetVariable NewQwaveName, value=root:packages:ImportData:NewQWaveName, help={"Input name for the new Q wave"}
//	SetVariable NewIntensityWaveName, pos={5, 660}, size={320, 20}, title="Y wave names", proc=IR1I_setvarProc
//	SetVariable NewIntensityWaveName, value=root:packages:ImportData:NewIntensityWaveName, help={"Input name for the new intensity wave"}
//	SetVariable NewErrorWaveName, pos={5, 680}, size={320, 20}, title="dY wv names", proc=IR1I_setvarProc
//	SetVariable NewErrorWaveName, value=root:packages:ImportData:NewErrorWaveName, help={"Input name for the new Error wave"}
//	SetVariable NewQErrorWaveName, pos={5, 700}, size={320, 20}, title="dX wv names  ", proc=IR1I_setvarProc
//	SetVariable NewQErrorWaveName, value=root:packages:ImportData:NewQErrorWaveName, help={"Input name for the new Q data Error wave"}
//
//	Button ImportData2, pos={330, 660}, size={80, 30}, proc=IR1I_ButtonProc, title="Import"
//	Button ImportData2, help={"Import the selected data files."}
//
//	IR1I_ImportOtherSetNames()
//
//End
//
////************************************************************************************************************
////************************************************************************************************************
//Function IR1I_DoubleClickFUnction()
//
//	IR1I_ButtonProc("TestImport")
//
//End
//
////************************************************************************************************************
////************************************************************************************************************
//Function IR1I_ImportDataFnct2()
// 
//	string TopPanel = WinName(0, 64)
//	string OldDf    = getDataFolder(1)
//
//	WAVE/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
//	WAVE   WaveOfSelections = root:Packages:ImportData:WaveOfSelections
//
//	IR1I_CheckForProperNewFolder()
//	variable i, imax, icount
//	string SelectedFile
//	imax   = numpnts(WaveOfSelections)
//	icount = 0
//	for(i = 0; i < imax; i += 1)
//		if(WaveOfSelections[i])
//			selectedfile = WaveOfFiles[i]
//			IR1I_CreateImportDataFolder(selectedFile)
//			KillWaves/Z TempIntensity, TempQvector, TempError
//			IR1I_ImportOneFile(selectedFile)
//			IR1I_ProcessImpWaves2(selectedFile) //this thing also creates new error waves, removes negative qs and intesities and does everything else
//			IR1I_RecordResults(selectedFile)
//			icount += 1
//		endif
//	endfor
//	print "Imported " + num2str(icount) + " data file(s) in total"
//	setDataFolder OldDf
//End
//
////************************************************************************************************************
////************************************************************************************************************
////		Nexus Import functions
//
////************************************************************************************************************
////************************************************************************************************************
////
////Function IR1I_ImportNexusCanSASMain()
//// 	//IR1_KillGraphsAndPanels()
////	IN2G_CheckScreenSize("height", 720)
////	DoWindow IR1I_ImportData
////	if(V_Flag)
////		DoALert/T="Window conflict notice" 1, "Import SAS ASCII data cannot be open while using this tool, close (Yes) or abort (no)?"
////		if(V_flag == 1)
////			KillWIndow/Z IR1I_ImportData
////		else
////			abort
////		endif
////	endif
////	DoWindow IR1I_ImportOtherASCIIData
////	if(V_Flag)
////		DoALert/T="Window conflict notice" 1, "Import Nexus data cannot be open while using this tool, close (Yes) or abort (no)?"
////		if(V_flag == 1)
////			KillWIndow/Z IR1I_ImportOtherASCIIData
////		else
////			abort
////		endif
////	endif
////	KillWIndow/Z IR1I_ImportOtherASCIIData
////	IR1I_InitializeImportData()
////	IR1I_ImportNexusDataFnct()
////	ING2_AddScrollControl()
////	IR1_UpdatePanelVersionNumber("IR1I_ImportNexusCanSASData", IR1IversionNumberNexus, 1)
////	//fix these checkboxes;
////	NVAR UseFileNameasFolder     = root:Packages:ImportData:UseFileNameasFolder
////	NVAR UsesasEntryNameAsFolder = root:Packages:ImportData:UsesasEntryNameAsFolder
////	NVAR UseTitleNameAsFolder    = root:Packages:ImportData:UseTitleNameAsFolder
////	if((UseFileNameasFolder + UsesasEntryNameAsFolder + UseTitleNameAsFolder) != 1)
////		UseFileNameasFolder     = 0
////		UsesasEntryNameAsFolder = 0
////		UseTitleNameAsFolder    = 1
////	endif
////
////End
//
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
//
//Function IR1I_ImportNexusDataFnct()
// 	PauseUpdate // building window...
//	NewPanel/K=1/W=(3, 40, 430, 620)/N=IR1I_ImportNexusCanSASData as "Import Nexus canSAS data"
//	TitleBox MainTitle, title="\Zr200Import Nexus canSAS Data in Igor", pos={20, 5}, frame=0, fstyle=3, fixedSize=1, font="Times New Roman", size={400, 24}, anchor=MC, fColor=(0, 0, 52224)
//	IR3C_AddDataControls("ImportDataPath", "ImportData", "IR1I_ImportNexusCanSASData", "", "", "", "IR1I_NexusDoubleClickFUnction")
//	ListBox ListOfAvailableData, size={410, 250}
//	Button SelectDataPath, pos={110, 40}
//	SetVariable DataPathString, pos={2, 62}
//	SetVariable NameMatchString, pos={5, 85}
//	SetVariable DataExtensionString, pos={260, 85}
//	//CheckBox QvectorInA,pos={240,405},size={16,14},proc=IR1I_CheckProc,title="Q in [A^-1]",variable= root:Packages:ImportData:QvectInA, help={"What units is Q in? Select if in Angstroems ^-1"}
//	//CheckBox QvectorInNM,pos={240,422},size={16,14},proc=IR1I_CheckProc,title="Q in [nm^-1]",variable= root:Packages:ImportData:QvectInNM, help={"What units is Q in? Select if in nanometers ^-1. WIll be converted to inverse Angstroems"}
//	CheckBox UseFileNameAsFolderNX, pos={10, 400}, size={16, 14}, proc=IR1I_CheckProc, title="Use File Nms as Fldr Nms?", variable=root:Packages:ImportData:UseFileNameAsFolder, help={"Use names of imported files as folder names for the data?"}
//	CheckBox UsesasEntryNameAsFolderNX, pos={10, 415}, size={16, 14}, proc=IR1I_CheckProc, title="Use sasEntry Nms as Fldr Nms?", variable=root:Packages:ImportData:UsesasEntryNameAsFolder, help={"Use names of imported files as folder names for the data?"}
//	CheckBox UseTitleNameAsFolderNX, pos={10, 430}, size={16, 14}, proc=IR1I_CheckProc, title="Use sasTitle as Fldr Nms?", variable=root:Packages:ImportData:UseTitleNameAsFolder, help={"Use names of imported files as folder names for the data?"}
//
//	Button OpenFileInBrowser, pos={250, 400}, size={150, 20}, proc=IR1I_ButtonProc, title="Open File in Browser"
//	Button OpenFileInBrowser, help={"Check file in HDF5 Browser"}
//	Button GetHelp, pos={335, 60}, size={80, 15}, fColor=(65535, 32768, 32768), proc=IR1I_ButtonProc, title="Get Help", help={"Open www manual page for this tool"}
//
//	CheckBox NX_InclsasInstrument, pos={230, 420}, size={16, 14}, noproc, title="Incl sasInstrument in WVnote?", variable=root:Packages:ImportData:NX_InclsasInstrument, help={"Include values from sasInstrument group in wave note?"}
//	CheckBox NX_Incl_sasSample, pos={230, 435}, size={16, 14}, noproc, title="Incl sasSample in WVnote?", variable=root:Packages:ImportData:NX_Incl_sasSample, help={"Include values from sasSample group in wave note?"}
//	CheckBox NX_Inclsasnote, pos={230, 450}, size={16, 14}, noproc, title="Incl sasNote in WVnote?", variable=root:Packages:ImportData:NX_Inclsasnote, help={"Include values from sasNote group in wave note?"}
//
//	//CheckBox DataCalibratedArbitrary,pos={10,442},size={16,14},mode=1,proc=IR1I_CheckProc,title="Calibration Arbitrary\S \M",variable= root:Packages:ImportData:DataCalibratedArbitrary, help={"Data not calibrated (on relative scale)"}
//	//CheckBox DataCalibratedVolume,pos={150,442},size={16,14},mode=1,proc=IR1I_CheckProc,title="Calibration cm\S-1\Msr\S-1\M",variable= root:Packages:ImportData:DataCalibratedVolume, help={"Data calibrated to volume"}
//	//CheckBox DataCalibratedWeight,pos={290,442},size={16,14},mode=1,proc=IR1I_CheckProc,title="Calibration cm\S2\Mg\S-1\Msr\S-1\M",variable= root:Packages:ImportData:DataCalibratedWeight, help={"Data calibrated to weight"}
//	SetVariable NewDataFolderName, pos={5, 470}, size={410, 20}, title="New data folder:", proc=IR1I_setvarProc
//	SetVariable NewDataFolderName, value=root:packages:ImportData:NewDataFolderName, help={"Folder for the new data. Will be created, if does not exist.Or pick one ip popup above"}
//	SetVariable NewQwaveName, pos={5, 490}, size={320, 20}, title="Q wave names ", proc=IR1I_setvarProc, bodyWidth=230
//	SetVariable NewQwaveName, value=root:packages:ImportData:NewQWaveName, help={"Input name for the new Q wave"}
//	SetVariable NewIntensityWaveName, pos={5, 510}, size={320, 20}, title="I wave names", proc=IR1I_setvarProc, bodyWidth=230
//	SetVariable NewIntensityWaveName, value=root:packages:ImportData:NewIntensityWaveName, help={"Input name for the new intensity wave"}
//	SetVariable NewErrorWaveName, pos={5, 530}, size={320, 20}, title="Idev wv names", proc=IR1I_setvarProc, bodyWidth=230
//	SetVariable NewErrorWaveName, value=root:packages:ImportData:NewErrorWaveName, help={"Input name for the new uncertyaintiy wave"}
//	SetVariable NewQErrorWaveName, pos={5, 550}, size={320, 20}, title="Qres wv names  ", proc=IR1I_setvarProc, bodyWidth=230
//	SetVariable NewQErrorWaveName, value=root:packages:ImportData:NewQErrorWaveName, help={"Input name for the new Q resolution wave"}
//
//	Button ImportDataNexus, pos={330, 510}, size={80, 30}, proc=IR1I_ButtonProc, title="Import"
//	Button ImportDataNexus, help={"Import the selected data files."}
//
//	IR1I_ImportOtherSetNames()
//	//
//	//	PopupMenu SelectFolderNewData2,pos={10,590},size={250,21},proc=IR1I_PopMenuProc,title="Select data folder", help={"Select folder with data"}
//	//	PopupMenu SelectFolderNewData2,mode=1,popvalue="---",value= #"\"---;\"+IN2G_NewFindFolderWithWaveTypes(\"root:\", 10, \"*\", 1)"
//	//	CheckBox CreateSQRTErrors,pos={240,370},size={16,14},proc=IR1I_CheckProc,title="Create SQRT dY?",variable= root:Packages:ImportData:CreateSQRTErrors, help={"If input data do not contain errors, create errors as sqrt of intensity?"}
//	//	CheckBox CreatePercentErrors,pos={240,385},size={16,14},proc=IR1I_CheckProc,title="Create n% dY?",variable= root:Packages:ImportData:CreatePercentErrors, help={"If input data do not contain errors, create errors as n% of intensity?, select how many %"}
//	//	NVAR DiablePctErr=root:Packages:ImportData:CreatePercentErrors
//	//	SetVariable PercentErrorsToUse, pos={240,403}, size={100,20},title="dY %?:", proc=IR1I_setvarProc, disable=!(DiablePctErr)
//	//	SetVariable PercentErrorsToUse value= root:packages:ImportData:PercentErrorsToUse,help={"Input how many percent error you want to create."}
//	//
//	//	NVAR DisableExt=root:Packages:ImportData:UseFileNameAsFolder
//	//	CheckBox IncludeExtensionInName,pos={260,418},size={16,14},proc=IR1I_CheckProc,title="Include Extn?",variable= root:Packages:ImportData:IncludeExtensionInName, help={"Include file extension in imported data foldername?"}, disable=!(DisableExt)
//	////	CheckBox UseIndra2Names,pos={10,436},size={16,14},proc=IR1I_CheckProc,title="Use USAXS names?",variable= root:Packages:ImportData:UseIndra2Names, help={"Use wave names using Indra 2 name structure? (DSM_Int, DSM_Qvec, DSM_Error)"}
//	////	CheckBox ImportSMRdata,pos={150,436},size={16,14},proc=IR1I_CheckProc,title="Slit smeared?",variable= root:Packages:ImportData:ImportSMRdata, help={"Check if the data are slit smeared, changes suggested Indra data names to SMR_Qvec, SMR_Int, SMR_Error"}
//	////	CheckBox ImportSMRdata, disable= !root:Packages:ImportData:UseIndra2Names
//	//	CheckBox UseQRSNames,pos={10,452},size={16,14},proc=IR1I_CheckProc,title="Use QRS wave names?",variable= root:Packages:ImportData:UseQRSNames, help={"Use QRS name structure? (Q_filename, R_filename, S_filename)"}
//	////	CheckBox UseQISNames,pos={150,452},size={16,14},proc=IR1I_CheckProc,title="Use QIS (NIST) wv nms?",variable= root:Packages:ImportData:UseQISNames, help={"Use QIS name structure? (filename_q, filename_i, filename_s)"}
//	//
//	//	NVAR DisableOver=root:Packages:ImportData:UseFileNameAsFolder
//	//	CheckBox AutomaticallyOverwrite,pos={240,420},size={16,14},proc=IR1I_CheckProc,title="Overwrite existing data?",variable= root:Packages:ImportData:AutomaticallyOverwrite, help={"Automatically overwrite imported data if same data exist?"}, disable=!(DisableOver)
//
//	//	SVAR DataTypeToImport=root:Packages:ImportData:DataTypeToImport
//	//	SVAR ListOfKnownDataTypes=root:Packages:ImportData:ListOfKnownDataTypes
//	//	PopupMenu ImportDataType,pos={10,450},size={250,21},proc=IR1I_PopMenuProc,title="Data Type", help={"Select waht data are being imported for proper naming"}
//	//	PopupMenu ImportDataType,mode=1,popvalue=DataTypeToImport,value= #"root:Packages:ImportData:ListOfKnownDataTypes"
//	//	SetVariable Wavelength, pos={260,453}, size={150,10}, variable=root:Packages:ImportData:Wavelength, noproc, help={"For Two Theta (Tth) we need wavelength in A"}
//	//	SetVariable Wavelength, disable = !StringMatch(DataTypeToImport,"Tth-Int")
//
//	//	CheckBox ScaleImportedDataCheckbox,pos={10,475},size={16,14},proc=IR1I_CheckProc,title="Scale Imported data?",variable= root:Packages:ImportData:ScaleImportedData, help={"Check to scale (multiply by) factor imported data. Both Intensity and error will be scaled by same number. Insert appriate number right."}
//	//	NVAR DisableScale=root:Packages:ImportData:ScaleImportedData
//	//	SetVariable ScaleImportedDataBy, pos={200,475}, size={140,20},title="Scaling factor?:", proc=IR1I_setvarProc, disable=!(DisableScale)
//	//	SetVariable ScaleImportedDataBy limits={1e-32,inf,1},value= root:packages:ImportData:ScaleImportedDataBy,help={"Input number by which you want to multiply the imported intensity and errors."}
//	//	CheckBox RemoveNegativeIntensities,pos={10,500},size={16,14},proc=IR1I_CheckProc,title="Remove Int<=0?",variable= root:Packages:ImportData:RemoveNegativeIntensities, help={"Remove Intensities smaller than 0?"}
//	//	NVAR DisableTrim=root:Packages:ImportData:TrimData
//	//	CheckBox TrimData,pos={10,526},size={16,14},proc=IR1I_CheckProc,title="Trim data?",variable= root:Packages:ImportData:TrimData, help={"Check to trim Q range of the imported data."}
//	//	SetVariable TrimDataQMin, pos={110,524}, size={110,20},title="X min=", proc=IR1I_setvarProc, disable=!(DisableTrim)
//	//	SetVariable TrimDataQMin limits={0,inf,0},value= root:packages:ImportData:TrimDataQMin,help={"Xmin for trimming data. Leave 0 if not trimming at low q is needed."}
//	//	SetVariable TrimDataQMax, pos={240,524}, size={110,20},title="X max=", proc=IR1I_setvarProc, disable=!(DisableTrim)
//	//	SetVariable TrimDataQMax limits={0,inf,0},value= root:packages:ImportData:TrimDataQMax,help={"Xmax for trimming data. Leave 0 if not trimming at low q is needed."}
//	//
//	//	CheckBox ReduceNumPnts,pos={10,543},size={16,14},proc=IR1I_CheckProc,title="Reduce points?",variable= root:Packages:ImportData:ReduceNumPnts, help={"Check to log-reduce number of points"}
//	//	NVAR ReduceNumPnts = root:Packages:ImportData:ReduceNumPnts
//	//	SetVariable TargetNumberOfPoints, pos={140,541}, size={110,20},title="Num points=", proc=IR1I_setvarProc, disable=!(ReduceNumPnts)
//	//	SetVariable TargetNumberOfPoints limits={10,1000,0},value= root:packages:ImportData:TargetNumberOfPoints,help={"Target number of points after reduction. Uses same method as Data manipulation I"}
//	//
//	//	CheckBox TrunkateStart,pos={10,545},size={16,14},proc=IR1I_CheckProc,title="Truncate start of long names?",variable= root:Packages:ImportData:TrunkateStart, help={"Truncate names longer than 24 characters in front"}
//	//	CheckBox TrunkateEnd,pos={240,545},size={16,14},proc=IR1I_CheckProc,title="Truncate end of long names?",variable= root:Packages:ImportData:TrunkateEnd, help={"Truncate names longer than 24 characters at the end"}
//	//	SetVariable RemoveStringFromName, pos={5,565}, size={320,20},title="Remove Str From Name=", noproc
//	//	SetVariable RemoveStringFromName value= root:packages:ImportData:RemoveStringFromName,help={"Input string to be removed from name, leve empty if none"}
//	//
//
//End
//
////************************************************************************************************************
////************************************************************************************************************
//Function IR1I_NexusDoubleClickFUnction()
//
//	//IR1I_ButtonProc("TestImport")
//	IR1I_ImportDataFnctNexus()
//End
//
////************************************************************************************************************
////************************************************************************************************************
//Function IR1I_ImportDataFnctNexus()
// 
//	string TopPanel = WinName(0, 64)
//	string OldDf    = getDataFolder(1)
//	variable timerRefNum, microSeconds
//	timerRefNum = startMSTimer
//
//	WAVE/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
//	WAVE   WaveOfSelections = root:Packages:ImportData:WaveOfSelections
//
//	NVAR UseFolder = root:Packages:ImportData:UseFileNameasFolder
//	NVAR UseEntry  = root:Packages:ImportData:UsesasEntryNameAsFolder
//	NVAR UseTitle  = root:Packages:ImportData:UseTitleNameAsFolder
//
//	NVAR NX_SasIns  = root:Packages:ImportData:NX_InclsasInstrument
//	NVAR NX_SASSam  = root:Packages:ImportData:NX_Incl_sasSample
//	NVAR NX_SASNote = root:Packages:ImportData:NX_Inclsasnote
//
//	IR1I_CheckForProperNewFolder()
//	variable i, imax, icount
//	string SelectedFile
//	imax   = numpnts(WaveOfSelections)
//	icount = 0
//	for(i = 0; i < imax; i += 1)
//		if(WaveOfSelections[i])
//			selectedfile = WaveOfFiles[i]
//			NEXUS_NXcanSASDataReader("ImportDataPath", selectedFile, 1, 0, UseFolder, UseEntry, UseTitle, NX_SasIns, NX_SASSam, NX_SASNote)
//			icount += 1
//		endif
//	endfor
//	microSeconds = StopMSTimer(timerRefNum)
//	Print microSeconds / 1e6, "Seconds for import"
//	print "Imported " + num2str(icount) + " data file(s) in total"
//	setDataFolder root:Packages:ImportData
//	//clean up the experiment..
//	KillDataFolder/Z root:Packages:NexusImportTMP
//End
//
