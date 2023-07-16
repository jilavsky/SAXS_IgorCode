#pragma rtGlobals = 3	// Use strict wave reference mode and runtime bounds checking
#pragma version=2.42

#if(IgorVersion()<9)  	//no need to include, Igor 9 has this by default.  
#include <HDF5 Browser>
#endif


Constant IR1IversionNumber = 2.42
Constant IR1IversionNumber2 = 2.36
Constant IR1IversionNumberNexus = 2.36
Constant IR1TrimNameLength = 28


//*************************************************************************\
//* Copyright (c) 2005 - 2023, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

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


Function IR1I_ImportSASASCIIDataMain()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IN2G_CheckScreenSize("height",720)
	DoWindow IR1I_ImportOtherASCIIData
	if(V_Flag)
		DoALert/T="Window conflict notice" 1, "Import Other ASCII data cannot be open while using this tool, close (Yes) or abort (no)?"
		if(V_flag==1)
			KillWIndow/Z IR1I_ImportOtherASCIIData
		else
			abort
		endif
	endif
	DoWindow IR1I_ImportNexusCanSASData
	if(V_Flag)
		DoALert/T="Window conflict notice" 1, "Import Nexus data cannot be open while using this tool, close (Yes) or abort (no)?"
		if(V_flag==1)
			KillWIndow/Z IR1I_ImportNexusCanSASData
		else
			abort
		endif
	endif
	KillWIndow/Z IR1I_ImportData
	IR1I_InitializeImportData()
	Execute("IR1I_ImportSASASCIIData()")
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("IR1I_ImportData", IR1IversionNumber,1)
	//fix checboxes
	IR1I_FIxCheckboxesForWaveTypes()
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_MainCheckVersion()	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DoWindow IR1I_ImportData
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR1I_ImportData", IR1IversionNumber))
			DoAlert /T="The ASCII Import panel was created by incorrect version of Irena " 1, "Import ASCII may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				IR1I_ImportSASASCIIDataMain()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR1I_InitializeImportData()
			endif
		endif
	endif
end
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_MainCheckVersion2()	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DoWindow IR1I_ImportOtherASCIIData
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR1I_ImportOtherASCIIData", IR1IversionNumber2))
			DoAlert /T="The non-SAS Import panel was created by incorrect version of Irena " 1, "Import non-SAS may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				IR1I_ImportOtherASCIIMain()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR1I_InitializeImportData()
			endif
		endif
	endif
end
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_MainCheckVersionNexus()	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DoWindow IR1I_ImportNexusCanSASData
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR1I_ImportNexusCanSASData", IR1IversionNumberNexus))
			DoAlert /T="The Nexus Import panel was created by incorrect version of Irena " 1, "Import Nexus canSAS may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				Execute/P("IR1I_ImportNexusCanSASMain()")
			else		//at least reinitialize the variables so we avoid major crashes...
				IR1I_InitializeImportData()
			endif
		endif
	endif
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Proc IR1I_ImportSASASCIIData() 
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(3,40,430,760)/N=IR1I_ImportData as "Import SAXS/SANS data"
	TitleBox MainTitle title="\Zr200Import SAS ASCII Data in Igor",pos={20,5},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={350,24},anchor=MC,fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,40},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info1 title="\Zr140List of available files",pos={30,107},frame=0,fstyle=1, fixedSize=1,size={120,20},fColor=(0,0,52224)
	TitleBox Info21 title="\Zr140Column 1",pos={216,215},frame=0,fstyle=2, fixedSize=1,size={150,20}
	TitleBox Info22 title="\Zr140Column 2",pos={216,232},frame=0,fstyle=2, fixedSize=1,size={150,20}
	TitleBox Info23 title="\Zr140Column 3",pos={216,249},frame=0,fstyle=2, fixedSize=1,size={150,20}
	TitleBox Info24 title="\Zr140Column 4",pos={216,266},frame=0,fstyle=2, fixedSize=1,size={150,20}
	TitleBox Info25 title="\Zr140Column 5",pos={216,283},frame=0,fstyle=2, fixedSize=1,size={150,20}
	TitleBox Info26 title="\Zr140Column 6",pos={216,300},frame=0,fstyle=2, fixedSize=1,size={150,20}
	TitleBox Info6 title="\Zr150Q",pos={287,195},frame=0,fstyle=2, fixedSize=0,size={40,15}
	TitleBox Info7 title="\Zr150Int",pos={318,195},frame=0,fstyle=2, fixedSize=0,size={40,15}
	TitleBox Info8 title="\Zr150Err",pos={351,195},frame=0,fstyle=2, fixedSize=0,size={40,15}
	TitleBox Info9 title="\Zr150dQ",pos={382,195},frame=0,fstyle=2, fixedSize=0,size={40,15}
	Button SelectDataPath,pos={99,53},size={130,20}, proc=IR1I_ButtonProc,title="Select data path"
	Button SelectDataPath,help={"Select data path to the data"}
	Button GetHelp,pos={335,60},size={80,15},fColor=(65535,32768,32768), proc=IR1I_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}
	SetVariable DataPathString,pos={2,85},size={415,19},title="Data path :", noedit=1
	SetVariable DataPathString,help={"This is currently selected data path where Igor looks for the data"}
	SetVariable DataPathString,limits={-Inf,Inf,0},value= root:Packages:ImportData:DataPathName
	SetVariable DataExtensionString,pos={220,110},size={150,19},proc=IR1I_SetVarProc,title="Data extension:"
	SetVariable DataExtensionString,help={"Insert extension string to mask data of only some type (dat, txt, ...)"}
	//SetVariable DataExtensionString,fSize=12
	SetVariable DataExtensionString,value= root:Packages:ImportData:DataExtension


	ListBox ListOfAvailableData,pos={7,128},size={196,244}
	ListBox ListOfAvailableData,help={"Select files from this location you want to import"}
	ListBox ListOfAvailableData,listWave=root:Packages:ImportData:WaveOfFiles
	ListBox ListOfAvailableData,selWave=root:Packages:ImportData:WaveOfSelections
	ListBox ListOfAvailableData,mode= 4, proc=IR1_ImportListBoxProc, special={0,0,1 }		//this will scale the width of column, users may need to slide right using slider at the bottom. 


	SetVariable NameMatchString,pos={10,375},size={180,19},proc=IR1I_SetVarProc,title="Match name (string):"
	SetVariable NameMatchString,help={"Insert RegEx select only data with matching name (uses grep)"}
	SetVariable NameMatchString,value= root:Packages:ImportData:NameMatchString


	Button SelectAll,pos={5,396},size={80,17}, proc=IR1I_ButtonProc,title="Select All"
	Button SelectAll,help={"Select all waves in the list"}

	Button DeSelectAll,pos={100,396},size={80,17}, proc=IR1I_ButtonProc,title="Deselect All"
	Button DeSelectAll,help={"Deselect all waves in the list"}


	CheckBox SkipLines,pos={220,133},size={16,14},proc=IR1I_CheckProc,title="Skip lines?",variable= root:Packages:ImportData:SkipLines, help={"Check if you want to skip lines in header. Needed ONLY for weird headers..."}
	SetVariable SkipNumberOfLines,pos={300,133},size={70,19},proc=IR1I_SetVarProc,title=" "
	SetVariable SkipNumberOfLines,help={"Insert number of lines to skip"}
	SetVariable SkipNumberOfLines,variable= root:Packages:ImportData:SkipNumberOfLines, disable=(!root:Packages:ImportData:SkipLines)

	Button TestImport,pos={205,152},size={70,15}, proc=IR1I_ButtonProc,title="Test"
	Button TestImport,help={"Test how if import can be succesful and how many waves are found"}
	Button Preview,pos={278,152},size={70,15}, proc=IR1I_ButtonProc,title="Preview"
	Button Preview,help={"Preview selected file."}
	Button Plot,pos={350,152},size={70,15}, proc=IR1I_ButtonProc,title="Plot"
	Button Plot,help={"Preview selected file."}


	TitleBox TooManyPointsWarning variable=root:Packages:ImportData:TooManyPointsWarning,fColor=(0,0,0)
	TitleBox TooManyPointsWarning pos={220,170},size={150,19}, disable=1
	CheckBox Col1Qvec,pos={289,216},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col1Qvec, help={"What does this column contain?"}
	CheckBox Col1Int,pos={321,216},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col1Int, help={"What does this column contain?"}
	CheckBox Col1Error,pos={354,216},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col1Err, help={"What does this column contain?"}
	CheckBox Col1QError,pos={384,216},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col1QErr, help={"What does this column contain?"}

	CheckBox Col2Qvec,pos={289,233},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col2Qvec, help={"What does this column contain?"}
	CheckBox Col2Int,pos={321,233},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col2Int, help={"What does this column contain?"}
	CheckBox Col2Error,pos={354,233},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col2Err, help={"What does this column contain?"}
	CheckBox Col2QError,pos={384,233},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col2QErr, help={"What does this column contain?"}

	CheckBox Col3Qvec,pos={289,250},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col3Qvec, help={"What does this column contain?"}
	CheckBox Col3Int,pos={321,250},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col3Int, help={"What does this column contain?"}
	CheckBox Col3Error,pos={354,250},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col3Err, help={"What does this column contain?"}
	CheckBox Col3QError,pos={384,250},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col3QErr, help={"What does this column contain?"}

	CheckBox Col4Qvec,pos={289,267},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col4Qvec, help={"What does this column contain?"}
	CheckBox Col4Int,pos={321,267},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col4Int, help={"What does this column contain?"}
	CheckBox Col4Error,pos={354,267},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col4Err, help={"What does this column contain?"}
	CheckBox Col4QError,pos={384,267},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col4QErr, help={"What does this column contain?"}

	CheckBox Col5Qvec,pos={289,284},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col5Qvec, help={"What does this column contain?"}
	CheckBox Col5Int,pos={321,284},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col5Int, help={"What does this column contain?"}
	CheckBox Col5Error,pos={354,284},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col5Err, help={"What does this column contain?"}
	CheckBox Col5QError,pos={384,284},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col5QErr, help={"What does this column contain?"}

	CheckBox Col6Qvec,pos={289,301},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col6Qvec, help={"What does this column contain?"}
	CheckBox Col6Int,pos={321,301},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col6Int, help={"What does this column contain?"}
	CheckBox Col6Error,pos={354,301},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col6Err, help={"What does this column contain?"}
	CheckBox Col6QError,pos={384,301},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col6QErr, help={"What does this column contain?"}


	SetVariable FoundNWaves,pos={220,320},size={150,19},title="Found columns :",proc=IR1I_SetVarProc
	SetVariable FoundNWaves,help={"This is how many columns were found in the tested file"}, disable=2
	SetVariable FoundNWaves,limits={0,Inf,0},value= root:Packages:ImportData:FoundNWaves

	CheckBox QvectorInA,pos={210,340},size={16,14},proc=IR1I_CheckProc,title="Qvec units [A^-1]",variable= root:Packages:ImportData:QvectInA, help={"What units is Q in? Select if in Angstroems ^-1"}
	CheckBox QvectorInNM,pos={210,355},size={16,14},proc=IR1I_CheckProc,title="Qvec units [nm^-1]",variable= root:Packages:ImportData:QvectInNM, help={"What units is Q in? Select if in nanometers ^-1. WIll be converted to inverse Angstroems"}
	CheckBox CreateSQRTErrors,pos={210,370},size={16,14},proc=IR1I_CheckProc,title="Create SQRT Errors?",variable= root:Packages:ImportData:CreateSQRTErrors, help={"If input data do not contain errors, create errors as sqrt of intensity?"}
	CheckBox CreatePercentErrors,pos={210,385},size={16,14},proc=IR1I_CheckProc,title="Create n% Errors?",variable= root:Packages:ImportData:CreatePercentErrors, help={"If input data do not contain errors, create errors as n% of intensity?, select how many %"}
	SetVariable PercentErrorsToUse, pos={210,403}, size={100,20},title="Error %?:", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:CreatePercentErrors)
	SetVariable PercentErrorsToUse value= root:packages:ImportData:PercentErrorsToUse,help={"Input how many percent error you want to create."}

	CheckBox ForceUTF8,pos={340,340},size={16,14},proc=IR1I_CheckProc,title="UTF-8?",variable= root:Packages:ImportData:ForceUTF8, help={"Select if you have encoding problems"}


	CheckBox UseFileNameAsFolder,pos={10,420},size={16,14},proc=IR1I_CheckProc,title="Use File Nms as Fldr Nms?",variable= root:Packages:ImportData:UseFileNameAsFolder, help={"Use names of imported files as folder names for the data?"}
	CheckBox IncludeExtensionInName,pos={240,420},size={16,14},proc=IR1I_CheckProc,title="Include Extn?",variable= root:Packages:ImportData:IncludeExtensionInName, help={"Include file extension in imported data foldername?"}, disable=!(root:Packages:ImportData:UseFileNameAsFolder)
	CheckBox UseIndra2Names,pos={10,436},size={16,14},proc=IR1I_CheckProc,title="Use USAXS names?",variable= root:Packages:ImportData:UseIndra2Names, help={"Use wave names using Indra 2 name structure? (DSM_Int, DSM_Qvec, DSM_Error)"}
	CheckBox ImportSMRdata,pos={150,436},size={16,14},proc=IR1I_CheckProc,title="Slit smeared?",variable= root:Packages:ImportData:ImportSMRdata, help={"Check if the data are slit smeared, changes suggested Indra data names to SMR_Qvec, SMR_Int, SMR_Error"}
	CheckBox ImportSMRdata, disable= !root:Packages:ImportData:UseIndra2Names
	CheckBox UseQRSNames,pos={10,452},size={16,14},proc=IR1I_CheckProc,title="Use QRS wave names?",variable= root:Packages:ImportData:UseQRSNames, help={"Use QRS name structure? (Q_filename, R_filename, S_filename)"}
	CheckBox UseQISNames,pos={150,452},size={16,14},proc=IR1I_CheckProc,title="Use QIS (NIST) wv nms?",variable= root:Packages:ImportData:UseQISNames, help={"Use QIS name structure? (filename_q, filename_i, filename_s)"}

	CheckBox AutomaticallyOverwrite,pos={300,452},size={16,14},proc=IR1I_CheckProc,title="Auto overwrite?",variable= root:Packages:ImportData:AutomaticallyOverwrite, help={"Automatically overwrite imported data if same data exist?"}, disable=!(root:Packages:ImportData:UseFileNameAsFolder)

	CheckBox ScaleImportedDataCheckbox,pos={10,472},size={16,14},proc=IR1I_CheckProc,title="Scale Imported data?",variable= root:Packages:ImportData:ScaleImportedData, help={"Check to scale (multiply by) factor imported data. Both Intensity and error will be scaled by same number. Insert appriate number right."}
	SetVariable ScaleImportedDataBy, pos={200,472}, size={140,20},title="Scaling factor?:", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:ScaleImportedData)
	SetVariable ScaleImportedDataBy limits={1e-32,inf,1},value= root:packages:ImportData:ScaleImportedDataBy,help={"Input number by which you want to multiply the imported intensity and errors."}
	CheckBox SlitSmearDataCheckbox,pos={10,490},size={16,14},proc=IR1I_CheckProc,title="Slit Smear Imp. data?",variable= root:Packages:ImportData:SlitSmearData, help={"Check to slit smear imported data. Both Intensity and error will be smeared. Insert appriate number right."}
	SetVariable SlitLength, pos={200,490}, size={140,20},title="Slit length?:", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:SlitSmearData)
	SetVariable SlitLength limits={1e-32,inf,0},value= root:packages:ImportData:SlitLength,help={"Input slit length in Q units."}

	CheckBox RemoveNegativeIntensities,pos={10,507},size={16,14},proc=IR1I_CheckProc,title="Remove Int<=0?",variable= root:Packages:ImportData:RemoveNegativeIntensities, help={"Remove Intensities smaller than 0?"}

	CheckBox TrimData,pos={10,526},size={16,14},proc=IR1I_CheckProc,title="Trim data?",variable= root:Packages:ImportData:TrimData, help={"Check to trim Q range of the imported data."}
	SetVariable TrimDataQMin, pos={110,524}, size={110,20},title="Qmin=", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:TrimData)
	SetVariable TrimDataQMin limits={1e-32,inf,0},value= root:packages:ImportData:TrimDataQMin,help={"Qmin for trimming data. Leave 0 if not trimming at low q is needed."}
	SetVariable TrimDataQMax, pos={240,524}, size={110,20},title="Qmax=", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:TrimData)
	SetVariable TrimDataQMax limits={1e-32,inf,0},value= root:packages:ImportData:TrimDataQMax,help={"Qmax for trimming data. Leave 0 if not trimming at low q is needed."}

	CheckBox ReduceNumPnts,pos={10,543},size={16,14},proc=IR1I_CheckProc,title="Reduce points?",variable= root:Packages:ImportData:ReduceNumPnts, help={"Check to log-reduce number of points"}
	SetVariable TargetNumberOfPoints, pos={110,541}, size={110,20},title="Num points=", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:ReduceNumPnts)
	SetVariable TargetNumberOfPoints limits={10,1000,0},value= root:packages:ImportData:TargetNumberOfPoints,help={"Target number of points after reduction. Uses same method as Data manipualtion I"}

	CheckBox TrunkateStart,pos={10,560},size={16,14},proc=IR1I_CheckProc,title="Truncate start of long names?",variable= root:Packages:ImportData:TrunkateStart, help={"Truncate names longer than 24 characters in front"}
	CheckBox TrunkateEnd,pos={240,560},size={16,14},proc=IR1I_CheckProc,title="Truncate end of long names?",variable= root:Packages:ImportData:TrunkateEnd, help={"Truncate names longer than 24 characters at the end"}
	SetVariable RemoveStringFromName, pos={5,578}, size={320,20},title="Remove Str From Name=", noproc
	SetVariable RemoveStringFromName value= root:packages:ImportData:RemoveStringFromName,help={"Input string to be removed from name, leve empty if none"}

	CheckBox DataCalibratedArbitrary,pos={10,597},size={16,14},mode=1,proc=IR1I_CheckProc,title="Calibration Arbitrary\S \M",variable= root:Packages:ImportData:DataCalibratedArbitrary, help={"Data not calibrated (on relative scale)"}
	CheckBox DataCalibratedVolume,pos={150,597},size={16,14},mode=1,proc=IR1I_CheckProc,title="Calibration cm\S-1\Msr\S-1\M",variable= root:Packages:ImportData:DataCalibratedVolume, help={"Data calibrated to volume"}
	CheckBox DataCalibratedWeight,pos={290,597},size={16,14},mode=1,proc=IR1I_CheckProc,title="Calibration cm\S2\Mg\S-1\Msr\S-1\M",variable= root:Packages:ImportData:DataCalibratedWeight, help={"Data calibrated to weight"}

	SetVariable NewDataFolderName, pos={5,620}, size={410,20},title="New data folder:", proc=IR1I_setvarProc
	SetVariable NewDataFolderName value= root:packages:ImportData:NewDataFolderName,help={"Folder for the new data. Will be created, if does not exist. Use popup above to preselect."}
	SetVariable NewQwaveName, pos={5,640}, size={320,20},title="Q wave names ", proc=IR1I_setvarProc
	SetVariable NewQwaveName, value= root:packages:ImportData:NewQWaveName,help={"Input name for the new Q wave"}
	SetVariable NewIntensityWaveName, pos={5,660}, size={320,20},title="Intensity names", proc=IR1I_setvarProc
	SetVariable NewIntensityWaveName, value= root:packages:ImportData:NewIntensityWaveName,help={"Input name for the new intensity wave"}
	SetVariable NewErrorWaveName, pos={5,680}, size={320,20},title="Error wv names", proc=IR1I_setvarProc
	SetVariable NewErrorWaveName, value= root:packages:ImportData:NewErrorWaveName,help={"Input name for the new Error wave"}
	SetVariable NewQErrorWaveName, pos={5,700}, size={320,20},title="dQ wv names  ", proc=IR1I_setvarProc
	SetVariable NewQErrorWaveName, value= root:packages:ImportData:NewQErrorWaveName,help={"Input name for the new Q data Error wave"}

	Button ImportData,pos={330,660},size={80,30}, proc=IR1I_ButtonProc,title="Import"
	Button ImportData,help={"Import the selected data files."}

	IR1I_CheckProc("UseQRSNames",1)

EndMacro

//************************************************************************************************************
//************************************************************************************************************
Function IR1_ImportListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	Variable row = lba.row
	Variable col = lba.col
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
			break
		case 3: // double click
			IR1I_testImport()
			IR1I_TestImportNotebook()
			break
		case 4: // cell selection
		case 5: // cell selection plus shift key
			break
		case 6: // begin edit
			break
		case 7: // finish edit
			break
		case 13: // checkbox clicked (Igor 6.2 or later)
			break
	endswitch

	return 0
End
//************************************************************************************************************
//************************************************************************************************************
Function IR1I_ImportDataFnct()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	string TopPanel=WinName(0, 64)
	string OldDf = getDataFolder(1)
	Wave/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
	Wave WaveOfSelections = root:Packages:ImportData:WaveOfSelections

	IR1I_CheckForProperNewFolder()
	variable i, imax, icount
	string SelectedFile
	imax = numpnts(WaveOfSelections)
	icount = 0
	for(i=0;i<imax;i+=1)
		if (WaveOfSelections[i])
			selectedfile = WaveOfFiles[i]
			IR1I_CreateImportDataFolder(selectedFile)
			KillWaves/Z TempIntensity, TempQvector, TempError
			IR1I_ImportOneFile(selectedFile)
			IR1I_ProcessImpWaves(selectedFile)		//this thing also creates new error waves, removes negative qs and intesities and does everything else
			IR1I_RecordResults(selectedFile)
			icount+=1
		endif
	endfor
	print "Imported "+num2str(icount)+" data file(s) in total"
	setDataFolder OldDf
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//replaced by IN2G_RebinLogData(Wx,Wy,NumberOfPoints,MinStep,[Wsdev,Wxwidth,W1, W2, W3, W4, W5])
//Function  IR1I_ImportRebinData(TempInt,TempQ,TempE,TempQr,NumberOfPoints, LogBinParam)
//	wave TempInt,TempQ,TempE, TempQr
//	variable NumberOfPoints, LogBinParam
//
//	string OldDf
//	OldDf = GetDataFOlder(1)
//	NewDataFolder/O/S root:packages
//	NewDataFolder/O/S root:packages:TempDataRebin
//	
//	//Log rebinning, if requested.... 
//	//create log distribution of points...
//	make/O/D/FREE/N=(NumberOfPoints) tempNewLogDist, tempNewLogDistBinWidth
//	make/O/D/FREE/N=(NumberOfPoints) Rebinned_TempQ, Rebinned_tempInt, Rebinned_TempErr
//	variable StartQ, EndQ
//	variable RealStart, RealEnd, MinStep, StartX,EndX,startOld
//	if(TempQ[0]<1e-8)
//		findlevel/P TempQ, 1e-8
//		startQ=log(TempQ[ceil(V_LevelX)])
//		RealStart = TempQ[ceil(V_LevelX)]
//		MinStep = TempQ[ceil(V_LevelX)+1] - TempQ[ceil(V_LevelX)]
//	else
//		startQ=log(TempQ[0])
//		RealStart =TempQ[0]
//		MinStep = TempQ[1] - TempQ[0]
//	endif
//	endQ=log(TempQ[numpnts(TempQ)-1])
//	RealEnd = TempQ[numpnts(TempQ)-1]
//	//this did not guarrantee minimum step... Use method developed for Fly USAXS scans 12/2013
//	StartX = IN2G_FindCorrectLogScaleStart(RealStart,RealEnd,NumberOfPoints,MinStep)
//	EndX = StartX +(RealEnd - RealStart)
//	startQ=log(StartX)
//	endQ = log(EndX)
//	tempNewLogDist = startQ + p*(endQ-startQ)/numpnts(tempNewLogDist)
//	tempNewLogDist = 10^(tempNewLogDist)
//	startOld = tempNewLogDist[0]
//	tempNewLogDist += RealStart - startOld
//	tempNewLogDistBinWidth = tempNewLogDist[p+1] - tempNewLogDist[p]
//	tempNewLogDistBinWidth[numpnts(tempNewLogDistBinWidth)-1] = tempNewLogDistBinWidth[numpnts(tempNewLogDistBinWidth)-2]
//	Rebinned_tempInt=0
//	Rebinned_TempErr=0	
//	variable i, j	//, startIntg=TempQ[1]-TempQ[0]
//	//first assume that we can step through this easily...
//	variable cntPoints, BinHighEdge
//	//variable i will be from 0 to number of new points, moving through destination waves
//	j=0		//this variable goes through data to be reduced, therefore it goes from 0 to numpnts(TempInt)
//	For(i=0;i<NumberOfPoints;i+=1)
//		cntPoints=0
//		BinHighEdge = tempNewLogDist[i]+tempNewLogDistBinWidth[i]/2
//		Do
//			Rebinned_tempInt[i]+=TempInt[j]
//			Rebinned_TempErr[i]+=TempE[j]
//			Rebinned_TempQ[i] += TempQ[j]
//			cntPoints+=1
//		j+=1
//		While(TempQ[j]<BinHighEdge && j<numpnts(TempInt))
//		Rebinned_tempInt[i]/=	cntPoints
//		Rebinned_TempErr[i]/=cntPoints
//		Rebinned_TempQ[i]/=cntPoints
//	endfor
//	
//	Rebinned_TempQ = (Rebinned_TempQ[p]>0) ? Rebinned_TempQ[p] : NaN
//	//Rebinned_TempQ[numpnts(Rebinned_TempQ)-1]=NaN
//	
//	IN2G_RemoveNaNsFrom3Waves(Rebinned_tempInt,Rebinned_TempErr,Rebinned_TempQ)
//
//	
//	Redimension/N=(numpnts(Rebinned_tempInt))/D TempInt,TempQ,TempE, TempQr
//	TempInt=Rebinned_tempInt
//	TempQ=Rebinned_TempQ
//	TempE=Rebinned_TempErr
//	//temp Qr has changed, it now is represented by Q lmits of the new Q wave
//	
//	TempQr = (TempQ[p]-TempQ[p-1])/2 + (TempQ[p+1] - TempQ[p])/2
//	TempQr[0] = TempQ[1]-TempQ[0]
//	TempQr[numpnts(TempQ)-1] = TempQ[numpnts(TempQ)-1] - TempQ[numpnts(TempQ)-2]
//
//	setDataFolder OldDF
//	KillDataFolder/Z root:packages:TempDataRebin
//end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_CheckForProperNewFolder()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
	if (strlen(NewDataFolderName)>0 && cmpstr(":",NewDataFolderName[strlen(NewDataFolderName)-1])!=0)
		NewDataFolderName = NewDataFolderName + ":"
	endif
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR1I_RecordResults(selectedFile)
	string selectedFile	//before or after - that means fit...
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	DFref oldDf= GetDataFolderDFR()

	setdataFolder root:Packages:ImportData

	SVAR DataPathName=root:Packages:ImportData:DataPathName
	SVAR NewDataFolderName=root:Packages:ImportData:NewDataFolderName
	SVAR NewIntensityWaveName=root:Packages:ImportData:NewIntensityWaveName
	SVAR NewQWaveName=root:Packages:ImportData:NewQWaveName
	SVAR NewErrorWaveName=root:Packages:ImportData:NewErrorWaveName	
	SVAR NewQErrorWaveName=root:Packages:ImportData:NewQErrorWaveName	
	SVAR RemoveStringFromName=root:Packages:ImportData:RemoveStringFromName
	string NewFldrNm,NewIntName, NewQName, NewEName, NewQEName, tempFirstPart, tempLastPart
	NVAR TrunkateStart=root:Packages:ImportData:TrunkateStart	
	NVAR TrunkateEnd=root:Packages:ImportData:TrunkateEnd	
	
	if(stringMatch(NewDataFolderName,"*<fileName>*")==0)
		NewFldrNm = CleanupName(NewDataFolderName, 1 )
		NewFldrNm=IR1I_TrunkateName(NewFldrNm,TrunkateStart,TrunkateEnd,RemoveStringFromName)
	else
		TempFirstPart = NewDataFolderName[0,strsearch(NewDataFolderName, "<fileName>", 0 )-1]
		tempLastPart  = NewDataFolderName[strsearch(NewDataFolderName, "<fileName>", 0 )+10,inf]
		NewFldrNm = TempFirstPart+CleanupName(IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd,RemoveStringFromName), 1 )+tempLastPart
	endif
	if(stringMatch(NewIntensityWaveName,"*<fileName>*")==0)
		NewIntName = CleanupName(NewIntensityWaveName, 1 )
		NewIntName = IR1I_TrunkateName(NewIntensityWaveName,TrunkateStart,TrunkateEnd,RemoveStringFromName)
	else
		TempFirstPart = NewIntensityWaveName[0,strsearch(NewIntensityWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewIntensityWaveName[strsearch(NewIntensityWaveName, "<fileName>", 0 )+10,inf]
		NewIntName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		NewIntName = CleanupName(NewIntName, 1 )
	endif
	if(stringMatch(NewQwaveName,"*<fileName>*")==0)
		NewQName = CleanupName(NewQwaveName, 1 )
		NewQName = IR1I_TrunkateName(NewQwaveName,TrunkateStart,TrunkateEnd,RemoveStringFromName)
	else
		TempFirstPart = NewQwaveName[0,strsearch(NewQwaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewQwaveName[strsearch(NewQwaveName, "<fileName>", 0 )+10,inf]
		NewQName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		NewQName = CleanupName(NewQName, 1 )
	endif
	if(stringMatch(NewErrorWaveName,"*<fileName>*")==0)
		NewEName = CleanupName(NewErrorWaveName, 1 )
		NewEName = IR1I_TrunkateName(NewErrorWaveName,TrunkateStart,TrunkateEnd,RemoveStringFromName)
	else
		TempFirstPart = NewErrorWaveName[0,strsearch(NewErrorWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewErrorWaveName[strsearch(NewErrorWaveName, "<fileName>", 0 )+10,inf]
		NewEName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		NewEName = CleanupName(NewEName, 1 )
	endif
	if(stringMatch(NewQErrorWaveName,"*<fileName>*")==0)
		NewQEName = CleanupName(NewQErrorWaveName, 1 )
		NewQEName=IR1I_TrunkateName(NewQErrorWaveName,TrunkateStart,TrunkateEnd,RemoveStringFromName)
	else
		TempFirstPart = NewQErrorWaveName[0,strsearch(NewQErrorWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewQErrorWaveName[strsearch(NewQErrorWaveName, "<fileName>", 0 )+10,inf]
		NewQEName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		NewQEName = CleanupName(NewQEName, 1 )
	endif

	NVAR DataContainErrors=root:Packages:ImportData:DataContainErrors
	NVAR CreateSQRTErrors=root:Packages:ImportData:CreateSQRTErrors
	NVAR CreatePercentErrors=root:Packages:ImportData:CreatePercentErrors
	NVAR PercentErrorsToUse=root:Packages:ImportData:PercentErrorsToUse
	NVAR ScaleImportedData=root:Packages:ImportData:ScaleImportedData
	NVAR ScaleImportedDataBy=root:Packages:ImportData:ScaleImportedDataBy
	NVAR ImportSMRdata=root:Packages:ImportData:ImportSMRdata
	NVAR SkipLines=root:Packages:ImportData:SkipLines
	NVAR SkipNumberOfLines =root:Packages:ImportData:SkipNumberOfLines
	NVAR QvectInA=root:Packages:ImportData:QvectInA
	NVAR QvectInNM=root:Packages:ImportData:QvectInNM

	NVAR DataCalibratedArbitrary=root:Packages:ImportData:DataCalibratedArbitrary
	NVAR DataCalibratedVolume=root:Packages:ImportData:DataCalibratedVolume
	NVAR DataCalibratedWeight=root:Packages:ImportData:DataCalibratedWeight

	IR1_CreateLoggbook()		//this creates the logbook
	SVAR nbl=root:Packages:SAS_Modeling:NotebookName

	IR1L_AppendAnyText("     ")
	IR1L_AppendAnyText("***********************************************")
	IR1L_AppendAnyText("***********************************************")
	IR1L_AppendAnyText("Data load record ")
	IR1_InsertDateAndTime(nbl)
	IR1L_AppendAnyText("File path and file name \t"+DataPathName+selectedFile)
	IR1L_AppendAnyText(" ")
	IR1L_AppendAnyText("Loaded on       \t\t\t"+ Date()+"    "+time())
	IR1L_AppendAnyText("Data stored in : \t\t \t"+ NewFldrNm)
	IR1L_AppendAnyText("New waves named (Int,q,error) :  \t"+ NewIntName+"\t"+NewQName+"\t"+NewEName)
	IR1L_AppendAnyText("Comments and processing:")
	if(DataContainErrors)
		IR1L_AppendAnyText("Data Contained errors")	
	elseif(CreateSQRTErrors)
		IR1L_AppendAnyText("Data did not contain errors, created sqrt(int) errors")	
	elseif(CreatePercentErrors)
		IR1L_AppendAnyText("Data did not contain errors, created %(Int) errors, used "+num2str(PercentErrorsToUse)+"  %")	
	endif
	if(ScaleImportedData)
		IR1L_AppendAnyText("Data (Intensity and error) scaled by \t "+num2str(ScaleImportedDataBy))	
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
		IR1L_AppendAnyText("Following number of lines was skiped from the original file "+num2str(SkipNumberOfLines))	
	endif

	//and print in history, so user has some feedback...
	print "Imported data from :"+DataPathName+selectedFile+"\r"
	print "\tData stored in :\t\t\t"+IR1I_RemoveBadCharacters(NewFldrNm)
	if(DataContainErrors || CreateSQRTErrors || CreatePercentErrors)
		print  "\tNew Wave names are :\t"+ IR1I_RemoveBadCharacters(NewIntName)+"\t"+IR1I_RemoveBadCharacters(NewQName)+"\t"+IR1I_RemoveBadCharacters(NewEName)+"\r"
	else //no errors...
		print  "\tNew Wave names are :\t"+ NewIntName+"\t"+NewQName+"\r"
		print  "\tNo errors were loaded or created \r"
	endif
	setdataFolder oldDf
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function/S IR1I_TrunkateName(InputName,TrunkateStart,TrunkateEnd, RemoveStringFromName)
	string InputName, RemoveStringFromName
	variable TrunkateStart,TrunkateEnd
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	
	NVAR Igor8UseLongNames = root:Packages:IrenaConfigFolder:Igor8UseLongNames
	string ModName=ReplaceString(RemoveStringFromName, InputName, "")
	if(Igor8UseLongNames && IgorVersion()>7.99)		//Igor 8 and user wants long names 
		return IN2G_CreateUserName(ModName,31, 0, 11)
	endif
	variable inpuLength=strlen(ModName)
	variable removePoints=inpuLength - IR1TrimNameLength
	string TempStr=ModName	
	if(removePoints>0)
		if(TrunkateEnd)
			tempStr=ModName[0,IR1TrimNameLength-1]
		elseif(TrunkateStart)
			tempStr=ModName[removePoints,inf]
		endif
	endif
	return cleanupName(tempStr,1)
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_ProcessImpWaves(selectedFile)
	string selectedFile
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	variable i, numOfInts, numOfQs, numOfErrs, numOfQErrs, refNum
	numOfInts  = 0
	numOfQs   = 0
	numOfErrs = 0
	numOfQErrs = 0
	string HeaderFromData=""
	NVAR SkipNumberOfLines=root:Packages:ImportData:SkipNumberOfLines
	NVAR SkipLines=root:Packages:ImportData:SkipLines	
	NVAR FoundNWaves = root:Packages:ImportData:FoundNWaves
	NVAR TrunkateStart = root:Packages:ImportData:TrunkateStart
	NVAR TrunkateEnd = root:Packages:ImportData:TrunkateEnd
	variable GenError=0

	if(!SkipLines)			//lines automatically skipped, so the header may make sense, add to header...
	        Open/R/P=ImportDataPath refNum as selectedFile
		HeaderFromData=""
	        Variable j
 	       String text
  	      For(j=0;j<SkipNumberOfLines;j+=1)
   	             FReadLine refNum, text
 			HeaderFromData+=ZapNonLetterNumStart(IN2G_ZapControlCodes(text))+";"
		endfor        
	      Close refNum
	endif	
	NVAR DataContainErrors=root:Packages:ImportData:DataContainErrors
	DataContainErrors=0
	variable LimitFoundWaves = (FoundNWaves<=6) ? FoundNWaves : 7 
	For(i=0;i<LimitFoundWaves;i+=1)	
		NVAR testIntStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"Int")
		NVAR testQvecStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"Qvec")
		NVAR testErrStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"Err")
		NVAR testQErrStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"QErr")
		Wave/Z CurrentWave = $("wave"+num2str(i))
		SVAR DataPathName=root:Packages:ImportData:DataPathName
		if (testIntStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempIntensity
			//print "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData+";"
			note/NOCR TempIntensity, "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";Data header (1st line)="+HeaderFromData+";"
			//print note(TempIntensity)
			numOfInts+=1
		endif
		if (testQvecStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempQvector
			note/NOCR TempQvector, "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";Data header (1st line)="+HeaderFromData+";"
			numOfQs+=1
		endif
		if (testErrStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempError
			note/NOCR TempError, "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";Data header (1st line)="+HeaderFromData+";"
			numOfErrs+=1
			DataContainErrors=1
		endif
		if (testQErrStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempQError
			note TempQError, "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";Data header (1st line)="+HeaderFromData+";"
			numOfQErrs+=1
		endif
		if(!WaveExists(CurrentWave))
			GenError=0
			string Messg="Error, the column of data selected did not exist in the data file. The missing column is : "
			if(testIntStr)
				Messg+="Intensity"
				GenError=1
			elseif(testQvecStr)
				Messg+="Q vector"
				GenError=1
			elseif(testErrStr)
				Messg+="Error"
				GenError=1
			elseif(testQErrStr)
				Messg+="Q Error"
				GenError=1
			endif
			if(GenError)
				DoAlert 0, Messg 
			endif
		endif
	endfor
	if (numOfInts!=1 || numOfQs!=1 || numOfErrs>1|| numOfQErrs>1)
		Abort "Import waves problem, check values in checkboxes which indicate which column contains Intensity, Q and error"
	endif

	//here we will modify the data if user wants to do so...
	NVAR QvectInA=root:Packages:ImportData:QvectInA
	NVAR QvectInNM=root:Packages:ImportData:QvectInNM
	NVAR ScaleImportedData=root:Packages:ImportData:ScaleImportedData
	NVAR ScaleImportedDataBy=root:Packages:ImportData:ScaleImportedDataBy
	if (QvectInNM)
		TempQvector=TempQvector/10			//converts nm-1 in A-1  ???
		note TempQvector, "Q data converted from nm to A-1;"
		if(WaveExists(TempQError))
			TempQError = TempQError/10
			note/NOCR TempQError, "Q error converted from nm to A-1;"
		endif
	endif
	if (ScaleImportedData)
		TempIntensity=TempIntensity*ScaleImportedDataBy		//scales imported data for user
		note/NOCR TempIntensity, "Data scaled by="+num2str(ScaleImportedDataBy)+";"
		if (WaveExists(TempError))
			TempError=TempError*ScaleImportedDataBy		//scales imported data for user
			note/NOCR TempError, "Data scaled by="+num2str(ScaleImportedDataBy)+";"
		endif
	endif
	//lets insert here the Units into the wave notes...
	NVAR DataCalibratedArbitrary=root:Packages:ImportData:DataCalibratedArbitrary
	NVAR DataCalibratedVolume=root:Packages:ImportData:DataCalibratedVolume
	NVAR DataCalibratedWeight=root:Packages:ImportData:DataCalibratedWeight
	if(DataCalibratedWeight)
		note/NOCR TempIntensity, "Units=cm2/g;"	
	elseif(DataCalibratedVolume)
		note/NOCR TempIntensity, "Units=cm2/cm3;"	
	elseif(DataCalibratedArbitrary)
		note/NOCR TempIntensity, "Units=Arbitrary;"	
	endif
	
	//here we will deal with erros, if the user needs to create them
	NVAR CreateSQRTErrors=root:Packages:ImportData:CreateSQRTErrors
	NVAR CreatePercentErrors=root:Packages:ImportData:CreatePercentErrors
	NVAR PercentErrorsToUse=root:Packages:ImportData:PercentErrorsToUse
	if ((CreatePercentErrors||CreateSQRTErrors) && WaveExists(TempError))	
		DoAlert 0, "Debugging message: Should create SQRT errors, but error wave exists. Mess in the checkbox values..."
	endif
	if (CreatePercentErrors && PercentErrorsToUse<1e-12)
		DoAlert 0, "You want to create percent error wave, but your error fraction is extremally small. This is likely error, so please, check the number and reimport the data"
		abort
	endif
	if (CreateSQRTErrors && !WaveExists(TempError))
		Duplicate/O TempIntensity, TempError
		TempError = sqrt(TempIntensity)
		note TempError, "Error data created for user as SQRT of intensity;"
	endif
	if (CreatePercentErrors && !WaveExists(TempError))
		Duplicate/O TempIntensity, TempError
		TempError = TempIntensity * (PercentErrorsToUse/100)
		note TempError, "Error data created for user as percentage of intensity;Amount of error as percentage="+num2str(PercentErrorsToUse/100)+";"
	endif
	//let's clean up the data from negative Qs, if there are any...
	//data are in  		TempQvector, TempIntensity, TempError
	//w = w[p]==0 ? NaN : w[p]
	TempQvector = TempQvector[p]<=0 ?  NaN :  TempQvector[p]
	if(WaveExists(TempError)&&WaveExists(TempQError))	//have 4 waves
		IN2G_RemoveNaNsFrom4Waves(TempQvector, TempIntensity, TempError,TempQError)
	elseif(WaveExists(TempError)&&!WaveExists(TempQError))	//have 3 waves
		IN2G_RemoveNaNsFrom3Waves(TempQvector, TempIntensity, TempError)
	else	//only 2 waves 
		IN2G_RemoveNaNsFrom2Waves(TempQvector, TempIntensity)
	endif
	//just in case, we need to sort the data (some users have data which are not sorted...
	if(WaveExists(TempError))
		if(waveExists(TempQError))
			sort TempQvector,TempQvector, TempIntensity, TempError,TempQError
		else
			sort TempQvector,TempQvector, TempIntensity, TempError
		endif
	else
		sort TempQvector,TempQvector, TempIntensity
	endif
	//smear the data, 	this may remove some negative intensities, so do it first
	NVAR SlitSmearData = root:Packages:ImportData:SlitSmearData
	NVAR SlitLength = root:Packages:ImportData:SlitLength	
	if(SlitSmearData && (SlitLength>0))			//slit smear the data here...
		Duplicate/Free TempIntensity, TempIntToSmear
		IR1B_SmearData(TempIntToSmear, TempQvector, SlitLength, TempIntensity)	
		note/NOCR TempIntensity, "Slitlength="+num2str(SlitLength)+";"	
		//next smear errors. Assume we can smear them same as intensities for now. Probably incorrect assumption, need to check somehow. 
		if(WaveExists(TempError))		
			Duplicate/Free TempError, TempErrorToSmear
			IR1B_SmearData(TempErrorToSmear, TempQvector, SlitLength, TempError)	
			note/NOCR TempError, "Slitlength="+num2str(SlitLength)+";"				
		endif
		//now we need to sort out the resolution. Two choices - user provided a resolution, needs to be convoluted with slit length here
		//of user did not provide resolution, need to create here and set = slit length...
		if(!WaveExists(TempQError))
			Duplicate/O TempQvector, TempQError
			TempQError = 0
		endif
		TempQError = sqrt(TempQError[p]^2+SlitLength^2)
	endif
	//add slit length if imported data are slit smeared... 
	NVAR ImportSMRdata=root:Packages:ImportData:ImportSMRdata
	if(ImportSMRdata)
		if(SlitLength<0.0001)
			//SLit length not set, we need tyo get that set by user...
			variable SlitLengthLocal
			Prompt SlitLengthLocal, "Bad slit length found, need correct value in [1/A]"
			DoPrompt "Missing Slit length input needed", SlitLengthLocal
			if(V_Flag)
				abort
			endif
			SlitLength = SlitLengthLocal
		endif
		note/NOCR TempIntensity, "Slitlength="+num2str(SlitLength)+";"	
		if(WaveExists(TempError))		
			note/NOCR TempError, "Slitlength="+num2str(SlitLength)+";"				
		endif		
	endif
	
	//now remove negative intensities. If there are still some left and asked for. 
	NVAR RemoveNegativeIntensities = root:packages:ImportData:RemoveNegativeIntensities
	if(RemoveNegativeIntensities)
		TempIntensity = TempIntensity[p]<=0 ?  NaN :  TempIntensity[p]	
	endif
	if(WaveExists(TempError)&&WaveExists(TempQError))	//have 4 waves
		IN2G_RemoveNaNsFrom4Waves(TempQvector, TempIntensity, TempError,TempQError)
	elseif(WaveExists(TempError)&&!WaveExists(TempQError))	//have 3 waves
		IN2G_RemoveNaNsFrom3Waves(TempQvector, TempIntensity, TempError)
	elseif(!WaveExists(TempError)&&WaveExists(TempQError))	//have 3 waves
		IN2G_RemoveNaNsFrom3Waves(TempQvector, TempIntensity, TempQError)
	else	//only 2 waves 
		IN2G_RemoveNaNsFrom2Waves(TempQvector, TempIntensity)
	endif
	//all negative qs are removed...
	//optionally trim the Q range here...
	NVAR TrimData= root:packages:ImportData:TrimData
	NVAR TrimDataQMin= root:packages:ImportData:TrimDataQMin
	NVAR TrimDataQMax= root:packages:ImportData:TrimDataQMax
	if(TrimData)
		variable StartPointsToRemove=0
		if(TrimDataQMin>0)
			StartPointsToRemove=binarysearch(TempQvector,TrimDataQMin)
		endif
		variable EndPointsToRemove=numpnts(TempQvector)
		if(TrimDataQMax>0 && TrimDataQMax<TempQvector[inf])
			EndPointsToRemove=binarysearch(TempQvector,TrimDataQMax)
		endif
		if(TrimDataQMin>0 && StartPointsToRemove>0)
			TempQvector[0,StartPointsToRemove]=NaN
		endif
		if(TrimDataQMax>0 && TrimDataQMax<TempQvector[inf] && EndPointsToRemove>0)
			TempQvector[EndPointsToRemove+1,inf]=NaN
		endif
		if(WaveExists(TempError)&&WaveExists(TempQError))	//have 4 waves
			IN2G_RemoveNaNsFrom4Waves(TempQvector, TempIntensity, TempError,TempQError)
		elseif(WaveExists(TempError)&&!WaveExists(TempQError))	//have 3 waves
			IN2G_RemoveNaNsFrom3Waves(TempQvector, TempIntensity, TempError)
		elseif(!WaveExists(TempError)&&WaveExists(TempQError))	//have 3 waves
			IN2G_RemoveNaNsFrom3Waves(TempQvector, TempIntensity, TempQError)
		else	//only 2 waves 
			IN2G_RemoveNaNsFrom2Waves(TempQvector, TempIntensity)
		endif
	endif	

	//here rebind the data down....
	NVAR ReduceNumPnts= root:packages:ImportData:ReduceNumPnts
	NVAR TargetNumberOfPoints= root:packages:ImportData:TargetNumberOfPoints
	if(ReduceNumPnts)
		variable tempMinStep=TempQvector[1]-TempQvector[0]
		if(WaveExists(TempError)&&WaveExists(TempQError))	//have 4 waves
			IN2G_RebinLogData(TempQvector,TempIntensity,TargetNumberOfPoints,tempMinStep,Wsdev=TempError,Wxsdev=TempQError)
		elseif(WaveExists(TempError)&&!WaveExists(TempQError))	//have 3 waves
			Duplicate/O TempError, TempQError
			IN2G_RebinLogData(TempQvector,TempIntensity,TargetNumberOfPoints,tempMinStep,Wsdev=TempError,Wxwidth=TempQError)
		elseif(!WaveExists(TempError)&&WaveExists(TempQError))	//have 3 waves
			Duplicate/O TempQError, TempError
			IN2G_RebinLogData(TempQvector,TempIntensity,TargetNumberOfPoints,tempMinStep,Wsdev=TempError,Wxwidth=TempQError)
		else	//only 2 waves 
			Duplicate/O TempIntensity, TempError, TempQError
			IN2G_RebinLogData(TempQvector,TempIntensity,TargetNumberOfPoints,tempMinStep, Wsdev=TempError, Wxwidth=TempQError)
		endif
	endif
	//check on TempError if it contains meaningful number and stop user if not...
	if(!WaveExists(TempError))
		abort "The Errors (Uncertainities) data do NOT exist. Please, select a method to create them and try again."
	endif
	wavestats/Q TempError
	if((V_min<=0)||(V_numNANs>0)||(V_numINFs>0))
		abort "The Errors (Uncertainities) contain negative values, 0, NANs, or INFs. This is not acceptable. Import aborted. Please, check the input data or use % or SQRT errors"
	endif

	SVAR NewIntensityWaveName= root:packages:ImportData:NewIntensityWaveName
	SVAR NewQwaveName= root:packages:ImportData:NewQWaveName
	SVAR NewErrorWaveName= root:packages:ImportData:NewErrorWaveName
	SVAR NewQErrorWaveName= root:packages:ImportData:NewQErrorWaveName
	SVAR RemoveStringFromName=root:Packages:ImportData:RemoveStringFromName
	NVAR IncludeExtensionInName=root:packages:ImportData:IncludeExtensionInName
	string NewIntName, NewQName, NewEName, NewQEName, tempFirstPart, tempLastPart
	
	if(stringMatch(NewIntensityWaveName,"*<fileName>*")==0)
		NewIntName = IR1I_RemoveBadCharacters(NewIntensityWaveName)
		NewIntName = CleanupName(NewIntName, 1 )
		NewIntName=IR1I_TrunkateName(NewIntName,TrunkateStart,TrunkateEnd,RemoveStringFromName)
	else
		TempFirstPart = NewIntensityWaveName[0,strsearch(NewIntensityWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewIntensityWaveName[strsearch(NewIntensityWaveName, "<fileName>", 0 )+10,inf]
		if(IncludeExtensionInName)
			NewIntName = TempFirstPart+IR1I_TrunkateName(selectedFile,TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		else
			NewIntName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		endif
		NewIntName = IR1I_RemoveBadCharacters(NewIntName)
		NewIntName = CleanupName(NewIntName, 1 )
	endif
	if(stringMatch(NewQwaveName,"*<fileName>*")==0)
		NewQName =IR1I_RemoveBadCharacters(NewQwaveName)
		NewQName = CleanupName(NewQName, 1 )
		NewQName=IR1I_TrunkateName(NewQName,TrunkateStart,TrunkateEnd,RemoveStringFromName)
	else
		TempFirstPart = NewQwaveName[0,strsearch(NewQwaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewQwaveName[strsearch(NewQwaveName, "<fileName>", 0 )+10,inf]
		if(IncludeExtensionInName)
			NewQName = TempFirstPart+IR1I_TrunkateName(selectedFile,TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		else
			NewQName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		endif
		NewQName =IR1I_RemoveBadCharacters(NewQName)
		NewQName = CleanupName(NewQName, 1 )
	endif
	if(stringMatch(NewErrorWaveName,"*<fileName>*")==0)
		NewEName =IR1I_RemoveBadCharacters(NewErrorWaveName)
		NewEName = CleanupName(NewEName, 1 )
		NewEName=IR1I_TrunkateName(NewEName,TrunkateStart,TrunkateEnd,RemoveStringFromName)
	else
		TempFirstPart = NewErrorWaveName[0,strsearch(NewErrorWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewErrorWaveName[strsearch(NewErrorWaveName, "<fileName>", 0 )+10,inf]
		if(IncludeExtensionInName)
			NewEName = TempFirstPart+IR1I_TrunkateName(selectedFile,TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		else
			NewEName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		endif
		NewEName =IR1I_RemoveBadCharacters(NewEName)
		NewEName = CleanupName(NewEName, 1 )
	endif
	if(stringMatch(NewQErrorWaveName,"*<fileName>*")==0)
		NewQEName =IR1I_RemoveBadCharacters(NewQErrorWaveName)
		NewQEName = CleanupName(NewQEName, 1 )
		NewQEName=IR1I_TrunkateName(NewQEName,TrunkateStart,TrunkateEnd,RemoveStringFromName)
	else
		TempFirstPart = NewQErrorWaveName[0,strsearch(NewQErrorWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewQErrorWaveName[strsearch(NewQErrorWaveName, "<fileName>", 0 )+10,inf]
		if(IncludeExtensionInName)
			NewQEName = TempFirstPart+IR1I_TrunkateName(selectedFile,TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		else
			NewQEName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		endif
		NewQEName =IR1I_RemoveBadCharacters(NewQEName)
		NewQEName = CleanupName(NewQEName, 1 )
	endif
	NVAr AutomaticallyOverwrite = root:Packages:ImportData:AutomaticallyOverwrite
	Wave/Z testE=$NewEName
	Wave/Z testQ=$NewQName
	Wave/Z testI=$NewIntName
	Wave/Z testQE=$NewQEName
	if ((WaveExists(testI) || WaveExists(testQ)||WaveExists(testE)||WaveExists(testQE))&&!AutomaticallyOverwrite)
		DoAlert 1, "The data of this name : "+NewIntName+" , "+NewQName+ " , "+NewEName+" , or "+NewQEName+"  exist. DO you want to overwrite them?"
		if (V_Flag==2)
			abort
		endif
	elseif((WaveExists(testI) || WaveExists(testQ)||WaveExists(testE)||WaveExists(testQE))&&AutomaticallyOverwrite)
		//we ovewrote some data, let's at least know about it
		print "The data of this name : "+NewIntName+" , "+NewQName+ " , "+NewEName+" , or "+NewQEName+"  existed. Due to user selection, old data were deleted and replaced with newly imported ones."
	endif
		
	Duplicate/O TempQvector, $NewQName
	Duplicate/O TempIntensity, $NewIntName
	if(WaveExists(TempError))
		Duplicate/O TempError, $NewEName
	endif	
	if(WaveExists(TempQError))
		Duplicate/O TempQError, $NewQEName
	else
//		//fake resolution here
//		Duplicate/Free TempQvector, TempdQvector
//		TempdQvector[1,numpnts(TempdQvector)-1]=TempdQvector[p]-TempdQvector[p-1]
//		TempdQvector[0]=TempdQvector[1]
//		print "Q Resolution not provided, Import function faked them with dQ difference between points. This may be totally wrong, BE AWARE." 
//		Duplicate/O TempdQvector, $NewQEName
	endif	
	KillWaves/Z tempError, tempQvector, TempIntensity, TempQError
	IR1I_KillAutoWaves()
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function/S IR1I_RemoveBadCharacters(StringName)
	string StringName
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	
	//here we can clean up what Igor allows but would be major problem with my code, such as ( or ) from names
	make/Free/T/N=0 ListOfBadChars
	ListOfBadChars = {"(", ")", "{","}","%","&","$","#","@","*"}
	variable i
	For (i=0;i<numpnts(ListOfBadChars);i+=1)
		StringName = ReplaceString(ListOfBadChars[i], StringName, "_" )
	endfor
	return StringName
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_ImportOneFile(selectedFile)
	string selectedFile
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		
	NVAR SkipNumberOfLines=root:Packages:ImportData:SkipNumberOfLines
	NVAR SkipLines=root:Packages:ImportData:SkipLines	
	NVAR ForceUTF8=root:Packages:ImportData:ForceUTF8	
	
		IR1I_KillAutoWaves()
		//Variable err
	if (SkipLines)
		if(ForceUTF8)
			LoadWave/Q/A/D/G/L={0, SkipNumberOfLines, 0, 0, 0}/P=ImportDataPath/ENCG={1,4}  selectedfile
		else
			LoadWave/Q/A/D/G/L={0, SkipNumberOfLines, 0, 0, 0}/P=ImportDataPath  selectedfile
		endif
	else
		if(ForceUTF8)
			LoadWave/Q/A/D/G/P=ImportDataPath/ENCG={1,4}  selectedfile
		else
			LoadWave/Q/A/D/G/P=ImportDataPath  selectedfile
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
		SkipNumberOfLines = IR1I_CountHeaderLines("ImportDataPath", selectedfile)
	endif

end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_CountHeaderLines(pathName, fileName)
        String pathName         // Symbolic path name
        String fileName                 // File name or full path
        String FirstPoint		//string containing first point number.... 
			//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
        
        Variable refNum = 0
        
        Open/R/P=$pathName refNum as fileName
        if (refNum == 0)
                return -1                                               // File was not opened. Probably bad file name.
        endif
        
        Variable tmp
        Variable count = 0
        String text
        do
                FReadLine refNum, text
                if (strlen(text) == 0)
                        break
                endif
                
                sscanf text, "%g", tmp
                if (V_flag == 1)                                // Found a number at the start of the line?
                        break                                           // This marks the start of the numeric data.
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
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_KillAutoWaves()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	variable i
	for(i=0;i<=100;i+=1)
		Wave/Z test = $("wave"+num2str(i))
		KillWaves/Z test
	endfor
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_CreateImportDataFolder(selectedFile)
	string selectedFile
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
	NVAR IncludeExtensionInName = root:packages:ImportData:IncludeExtensionInName
	NVAR TrunkateStart = root:packages:ImportData:TrunkateStart
	NVAR TrunkateEnd = root:packages:ImportData:TrunkateEnd
	SVAR RemoveStringFromName=root:Packages:ImportData:RemoveStringFromName
	SVAR ExtensionStr=root:Packages:ImportData:DataExtension
	string RealExtension

	variable i
	string tempFldrName, tempSelectedFile
	setDataFolder root:
	For (i=0;i<ItemsInList(NewDataFolderName, ":");i+=1)
		tempFldrName = StringFromList(i, NewDataFolderName , ":")
		if (cmpstr(tempFldrName,"<fileName>")!=0 )
			if(cmpstr(tempFldrName,"root")!=0)
				NewDataFolder/O/S $(cleanupName(IN2G_RemoveExtraQuote(tempFldrName,1,1),1))
			endif
		else
			if(!IncludeExtensionInName)
				//selectedFile = stringFromList(0,selectedFile,".")	//5-25-2022, this removes anything from first "."
				RealExtension = stringFromList(ItemsInList(selectedFile, ".")-1,selectedFile,".")
				//selectedFile = removeEnding(selectedFile,"."+ExtensionStr)	//this removed user provided extension
				selectedFile = removeEnding(selectedFile,"."+RealExtension)		//this removes anything behind last "." in name. 
			endif
			selectedFile=IR1I_TrunkateName(selectedFile,TrunkateStart,TrunkateEnd,RemoveStringFromName)
			selectedFile =IR1I_RemoveBadCharacters(selectedFile)
			selectedFile = CleanupName(selectedFile, 1 )
			NewDataFolder/O/S $selectedFile
		endif
	endfor
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function IR1I_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	if (Cmpstr(ctrlName,"SelectFolderNewData")==0)
		SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
		NewDataFolderName = popStr
			NVAR UseFileNameAsFolder = root:Packages:ImportData:UseFileNameAsFolder
			if (UseFileNameAsFolder)
				NewDataFolderName+="<fileName>:"
			endif		
	endif
	if (Cmpstr(ctrlName,"SelectFolderNewData2")==0)
		SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
		if(stringMatch(popStr,"---"))
			NewDataFolderName = "root:ImportedData:"		
		else
			NewDataFolderName = popStr
		endif
			NVAR UseFileNameAsFolder = root:Packages:ImportData:UseFileNameAsFolder
			if (UseFileNameAsFolder)
				NewDataFolderName+="<fileName>:"
			endif		
	endif
	if (Cmpstr(ctrlName,"ImportDataType")==0)
		SVAR DataTypeToImport=root:Packages:ImportData:DataTypeToImport
		DataTypeToImport = popStr
		SetVariable Wavelength, win=IR1I_ImportOtherASCIIData, disable = !StringMatch(DataTypeToImport,"Tth-Int")
		IR1I_ImportOtherSetNames()
	endif
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	if (cmpstr(ctrlName,"DataExtensionString")==0)
		IR1I_UpdateListOfFilesInWvs()
	endif
	if (cmpstr(ctrlName,"NameMatchString")==0)
		IR1I_UpdateListOfFilesInWvs()
	endif
	if (cmpstr(ctrlName,"FoundNWaves")==0)
		IR1I_FIxCheckboxesForWaveTypes()
	endif
	
End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR1I_ButtonProc(ctrlName) : ButtonControl
	String ctrlName
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	
	if(cmpstr(ctrlName,"SelectDataPath")==0)
		IR1I_SelectDataPath()	
		IR1I_UpdateListOfFilesInWvs()
	endif
	if(cmpstr(ctrlName,"TestImport")==0)
		IR1I_testImport()
	endif
	if(cmpstr(ctrlName,"GetHelp")==0)
		//Open www manual with the right page
		IN2G_OpenWebManual("Irena/ImportData.html")
	endif
	if(cmpstr(ctrlName,"Preview")==0)
		IR1I_TestImportNotebook()
	endif
	if(cmpstr(ctrlName,"Plot")==0)
		IR1I_TestPlotData()
	endif
	if(cmpstr(ctrlName,"SelectAll")==0)
		IR1I_SelectDeselectAll(1)
	endif
	if(cmpstr(ctrlName,"DeselectAll")==0)
		IR1I_SelectDeselectAll(0)
	endif
	if(cmpstr(ctrlName,"ImportData")==0)
		IR1I_ImportDataFnct()
	endif
	if(cmpstr(ctrlName,"ImportData2")==0)
		IR1I_ImportDataFnct2()
	endif
	if(cmpstr(ctrlName,"ImportDataNexus")==0)
		IR1I_ImportDataFnctNexus()
	endif
	if(cmpstr(ctrlName,"OpenFileInBrowser")==0)
		IR1I_NexusOpenHdf5File()
	endif

End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_SelectDeselectAll(SetNumber)
		variable setNumber
		//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		
		Wave WaveOfSelections=root:Packages:ImportData:WaveOfSelections

		WaveOfSelections = SetNumber
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR1I_TestImport()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	string TopPanel=WinName(0, 64)
	
	Wave/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
	Wave WaveOfSelections = root:Packages:ImportData:WaveOfSelections
	NVAR FoundNWaves = root:Packages:ImportData:FoundNWaves
	NVAR SkipNumberOfLines=root:Packages:ImportData:SkipNumberOfLines
	NVAR SkipLines=root:Packages:ImportData:SkipLines
	NVAR NumOfPointsFound=root:Packages:ImportData:NumOfPointsFound
	SVAR TooManyPointsWarning=root:Packages:ImportData:TooManyPointsWarning
	TooManyPointsWarning=""
	FoundNWaves = 0
	NumOfPointsFound=0
	
	variable i, imax, firstSelectedPoint, maxWaves
	string SelectedFile
	imax = numpnts(WaveOfSelections)
	firstSelectedPoint = NaN
	For(i=0;i<numpnts(WaveOfSelections);i+=1)
		if(WaveOfSelections[i]==1)
			firstSelectedPoint = i
			break
		endif
	endfor
	if (numtype(firstSelectedPoint)==2)
		abort
	endif
	selectedfile = WaveOfFiles[firstSelectedPoint]
	
	killWaves/Z wave0, wave1, wave2, wave3, wave4, wave5, wave6,wave7,wave8,wave9
	
	NVAR ForceUTF8=root:Packages:ImportData:ForceUTF8	
	if (SkipLines)
		if(ForceUTF8)
			LoadWave/Q/A/D/G/L={0, SkipNumberOfLines, 0, 0, 0}/P=ImportDataPath/ENCG={1,4}  selectedfile
			FoundNWaves = V_Flag
		else
			LoadWave/Q/A/D/G/L={0, SkipNumberOfLines, 0, 0, 0}/P=ImportDataPath  selectedfile
			FoundNWaves = V_Flag
		endif
	else
		if(ForceUTF8)
			LoadWave/Q/A/D/G/P=ImportDataPath/ENCG={1,4}  selectedfile
			FoundNWaves = V_Flag
		else
			LoadWave/Q/A/D/G/P=ImportDataPath  selectedfile
			FoundNWaves = V_Flag
		endif
	endif
	wave wave0
	NumOfPointsFound=numpnts(wave0)
	if(stringmatch(TopPanel,"IR1I_ImportData"))
		if(NumOfPointsFound<300)
			sprintf TooManyPointsWarning, "Found %g data points",NumOfPointsFound
			TitleBox TooManyPointsWarning win=IR1I_ImportData  ,fColor=(0,0,0), disable=0
		else
			sprintf TooManyPointsWarning, "%g data points, consider reduction ",NumOfPointsFound
			TitleBox TooManyPointsWarning win=IR1I_ImportData  ,fColor=(65200,0,0), disable=0
		endif
	endif
	//now fix the checkboxes as needed
	IR1I_FIxCheckboxesForWaveTypes()
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR1I_TestImportNotebook()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	string TopPanel=WinName(0, 64)
	Wave/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
	Wave WaveOfSelections = root:Packages:ImportData:WaveOfSelections
	variable i, imax, firstSelectedPoint, maxWaves
	string SelectedFile
	imax = numpnts(WaveOfSelections)
	firstSelectedPoint = NaN
	For(i=0;i<numpnts(WaveOfSelections);i+=1)
		if(WaveOfSelections[i]==1)
			firstSelectedPoint = i
			break
		endif
	endfor
	if (numtype(firstSelectedPoint)==2)
		abort
	endif
	selectedfile = WaveOfFiles[firstSelectedPoint]
	
	
	//LoadWave/Q/A/G/P=ImportDataPath  selectedfile
	KillWIndow/Z FilePreview
	NVAR ForceUTF8=root:Packages:ImportData:ForceUTF8
	if(ForceUTF8)
		OpenNotebook /K=1 /N=FilePreview/ENCG={1,4} /P=ImportDataPath /R /V=1 selectedfile
	else
		OpenNotebook /K=1 /N=FilePreview /P=ImportDataPath /R /V=1 selectedfile
	endif
	MoveWindow /W=FilePreview 450, 5, 1000, 400	
	AutoPositionWindow/M=0 /R=$(TopPanel) FilePreview
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR1I_TestPlotData()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	string TopPanel=WinName(0, 64)
	string OldDf = getDataFolder(1)
	
	Wave/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
	Wave WaveOfSelections 	= root:Packages:ImportData:WaveOfSelections
	NVAR FoundNWaves 			= root:Packages:ImportData:FoundNWaves
	variable i, imax, firstSelectedPoint, maxWaves
	string SelectedFile
	imax = numpnts(WaveOfSelections)
	firstSelectedPoint = NaN
	For(i=0;i<numpnts(WaveOfSelections);i+=1)
		if(WaveOfSelections[i]==1)
			firstSelectedPoint = i
			break
		endif
	endfor
	if (numtype(firstSelectedPoint)==2)
		abort
	endif
	selectedfile = WaveOfFiles[firstSelectedPoint]

	NewDataFOlder/O/S root:Packages:IrenaImportTemp
	KillWIndow/Z FilePlotPreview
	KillWaves/Z TempIntensity, TempQvector, TempError, TempQError
	IR1I_KillAutoWaves()
	//LoadWave/Q/A/G/P=ImportDataPath  selectedfile
	IR1I_ImportOneFile(selectedFile)
	variable LimitFoundWaves = (FoundNWaves<=6) ? FoundNWaves : 7 
	For(i=0;i<LimitFoundWaves;i+=1)	
		NVAR testIntStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"Int")
		NVAR testQvecStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"Qvec")
		NVAR testErrStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"Err")
		NVAR testQErrStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"QErr")
		Wave/Z CurrentWave = $("wave"+num2str(i))
		SVAR DataPathName=root:Packages:ImportData:DataPathName
		if (testIntStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempIntensity
		endif
		if (testQvecStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempQvector
		endif
		if (testErrStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempError
		endif
		if (testQErrStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempQError
		endif
	endfor
	Wave/Z TempIntensity
	Wave/Z TempQvector
	Wave/Z TempError
	Wave/Z TempQError
	if(WaveExists(TempIntensity) && WaveExists(TempQvector))
		Display /K=1/N=FilePlotPreview TempIntensity vs TempQvector as "Preview of the data"
		MoveWindow /W=FilePlotPreview 450, 5, 1000, 400	
		AutoPositionWindow/M=0 /R=$(TopPanel) FilePlotPreview
		TextBox/C/N=text0/A=MC selectedfile
		if(WaveExists(TempError))
			if(!WaveExists(TempQError))
				ErrorBars TempIntensity Y,wave=(TempError,TempError)
			else
				ErrorBars TempIntensity XY,wave=(TempQError,TempQError),wave=(TempError,TempError)
			endif
		endif
		DoWindow IR1I_ImportData
		if(V_Flag)
			ModifyGraph log=1
		endif
	endif
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_FIxCheckboxesForWaveTypes()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	string TopPanel=WinName(0, 64)
	NVAR FoundNWaves = root:Packages:ImportData:FoundNWaves
	variable maxWaves, i
	maxWaves = FoundNWaves
	if (MaxWaves>6)
		MaxWaves = 6
	endif

	For (i=1;i<=MaxWaves;i+=1)
		CheckBox $("Col"+num2str(i)+"Int") disable=0, win=$(TopPanel) 
		CheckBox $("Col"+num2str(i)+"Qvec") disable=0, win=$(TopPanel)  
		CheckBox $("Col"+num2str(i)+"Error") disable=0, win=$(TopPanel)  
		CheckBox $("Col"+num2str(i)+"QError") disable=0, win=$(TopPanel)  
	endfor
	For (i=FoundNWaves+1;i<=6;i+=1)
		CheckBox $("Col"+num2str(i)+"Int") disable=1, win=$(TopPanel)  
		CheckBox $("Col"+num2str(i)+"Qvec") disable=1, win=$(TopPanel)  
		CheckBox $("Col"+num2str(i)+"Error") disable=1, win=$(TopPanel)  
		CheckBox $("Col"+num2str(i)+"QError") disable=1, win=$(TopPanel)  
		NVAR ColInt=$("root:Packages:ImportData:Col"+num2str(i)+"Int")
		NVAR ColQvec=$("root:Packages:ImportData:Col"+num2str(i)+"Qvec")
		NVAR ColErr=$("root:Packages:ImportData:Col"+num2str(i)+"Err")
		NVAR ColQErr=$("root:Packages:ImportData:Col"+num2str(i)+"QErr")
		ColInt=0
		ColQvec=0
		ColErr=0
		ColQErr=0
	endfor
	
	NVAR Col1QErr=root:Packages:ImportData:Col1QErr
	NVAR Col2QErr=root:Packages:ImportData:Col2QErr
	NVAR Col3QErr=root:Packages:ImportData:Col3QErr
	NVAR Col4QErr=root:Packages:ImportData:Col4QErr
	NVAR Col5QErr=root:Packages:ImportData:Col5QErr
	NVAR Col6QErr=root:Packages:ImportData:Col6QErr
	if(Col6QErr || Col5QErr || Col4QErr || Col3QErr || Col2QErr || Col1QErr)
		SetVariable NewQErrorWaveName, disable = 0 
	else	
		SetVariable NewQErrorWaveName, disable = 1
	endif

end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_SelectDataPath()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	NewPath /M="Select path to data to be imported" /O ImportDataPath
	if (V_Flag!=0)
		abort
	endif 
	PathInfo ImportDataPath
	SVAR DataPathName=root:Packages:ImportData:DataPathName
	DataPathName = S_Path
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_CheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string TopPanel=WinName(0, 64)
	
	NVAR Col1Int=root:Packages:ImportData:Col1Int
	NVAR Col1Qvec=root:Packages:ImportData:Col1Qvec
	NVAR Col1Err=root:Packages:ImportData:Col1Err
	NVAR Col1QErr=root:Packages:ImportData:Col1QErr

	NVAR Col2Int=root:Packages:ImportData:Col2Int
	NVAR Col2Qvec=root:Packages:ImportData:Col2Qvec
	NVAR Col2Err=root:Packages:ImportData:Col2Err
	NVAR Col2QErr=root:Packages:ImportData:Col2QErr

	NVAR Col3Int=root:Packages:ImportData:Col3Int
	NVAR Col3Qvec=root:Packages:ImportData:Col3Qvec
	NVAR Col3Err=root:Packages:ImportData:Col3Err
	NVAR Col3QErr=root:Packages:ImportData:Col3QErr

	NVAR Col4Int=root:Packages:ImportData:Col4Int
	NVAR Col4Qvec=root:Packages:ImportData:Col4Qvec
	NVAR Col4Err=root:Packages:ImportData:Col4Err
	NVAR Col4QErr=root:Packages:ImportData:Col4QErr

	NVAR Col5Int=root:Packages:ImportData:Col5Int
	NVAR Col5Qvec=root:Packages:ImportData:Col5Qvec
	NVAR Col5Err=root:Packages:ImportData:Col5Err
	NVAR Col5QErr=root:Packages:ImportData:Col5QErr

	NVAR Col6Int=root:Packages:ImportData:Col6Int
	NVAR Col6Qvec=root:Packages:ImportData:Col6Qvec
	NVAR Col6Err=root:Packages:ImportData:Col6Err
	NVAR Col6QErr=root:Packages:ImportData:Col6QErr

	NVAR QvectInA=root:Packages:ImportData:QvectInA
	NVAR QvectInNM=root:Packages:ImportData:QvectInNM
	NVAR CreateSQRTErrors=root:Packages:ImportData:CreateSQRTErrors
	NVAR CreatePercentErrors=root:Packages:ImportData:CreatePercentErrors

	NVAR UseFileNameAsFolder = root:Packages:ImportData:UseFileNameAsFolder
	NVAR UseIndra2Names = root:Packages:ImportData:UseIndra2Names
	NVAR UseQRSNames = root:Packages:ImportData:UseQRSNames
	NVAR UseQISNames = root:Packages:ImportData:UseQISNames

	NVAR SkipLines = root:Packages:ImportData:SkipLines
	NVAR SkipNumberOfLines = root:Packages:ImportData:SkipNumberOfLines
	NVAR DataContainErrors=root:Packages:ImportData:DataContainErrors

	NVAR TrunkateStart = root:Packages:ImportData:TrunkateStart
	NVAR TrunkateEnd = root:Packages:ImportData:TrunkateEnd

	NVAR SlitSmearData = root:Packages:ImportData:SlitSmearData
	NVAR SlitLength = root:Packages:ImportData:SlitLength
	NVAR ImportSMRdata=root:Packages:ImportData:ImportSMRdata
	
	SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
	SVAR NewIntensityWaveName= root:packages:ImportData:NewIntensityWaveName
	SVAR NewQwaveName= root:packages:ImportData:NewQWaveName
	SVAR NewErrorWaveName= root:packages:ImportData:NewErrorWaveName
	SVAR NewQErrorWaveName= root:packages:ImportData:NewQErrorWaveName

	NVAR UseFileNameAsFolder= root:Packages:ImportData:UseFileNameAsFolder
	NVAR UsesasEntryNameAsFolder= root:Packages:ImportData:UsesasEntryNameAsFolder
	NVAR UseTitleNameAsFolder= root:Packages:ImportData:UseTitleNameAsFolder
	if(cmpstr(ctrlName,"UseFileNameAsFolderNX")==0)	
		//UseFileNameAsFolder = 0
		UsesasEntryNameAsFolder = 0
		UseTitleNameAsFolder = 0
	endif
	if(cmpstr(ctrlName,"UsesasEntryNameAsFolderNX")==0)	
		UseFileNameAsFolder = 0
		//UsesasEntryNameAsFolder = 0
		UseTitleNameAsFolder = 0
	endif
	if(cmpstr(ctrlName,"UseTitleNameAsFolderNX")==0)	
		UseFileNameAsFolder = 0
		UsesasEntryNameAsFolder = 0
		//UseTitleNameAsFolder = 0
	endif
	
	NVAR DataCalibratedArbitrary = root:Packages:ImportData:DataCalibratedArbitrary
	NVAR DataCalibratedVolume = root:Packages:ImportData:DataCalibratedVolume
	NVAR DataCalibratedWeight = root:Packages:ImportData:DataCalibratedWeight
	if(cmpstr(ctrlName,"DataCalibratedArbitrary")==0)	
		//DataCalibratedArbitrary = 0
		DataCalibratedVolume = 0
		DataCalibratedWeight = 0
	endif
	if(cmpstr(ctrlName,"DataCalibratedVolume")==0)	
		DataCalibratedArbitrary = 0
		//DataCalibratedVolume = 0
		DataCalibratedWeight = 0
	endif
	if(cmpstr(ctrlName,"DataCalibratedWeight")==0)	
		DataCalibratedArbitrary = 0
		DataCalibratedVolume = 0
		//DataCalibratedWeight = 0
	endif



	NVAR DataCalibratedArbitrary = root:Packages:ImportData:DataCalibratedArbitrary
	NVAR DataCalibratedVolume = root:Packages:ImportData:DataCalibratedVolume
	NVAR DataCalibratedWeight = root:Packages:ImportData:DataCalibratedWeight
	if(cmpstr(ctrlName,"DataCalibratedArbitrary")==0)	
		//DataCalibratedArbitrary = 0
		DataCalibratedVolume = 0
		DataCalibratedWeight = 0
	endif
	if(cmpstr(ctrlName,"DataCalibratedVolume")==0)	
		DataCalibratedArbitrary = 0
		//DataCalibratedVolume = 0
		DataCalibratedWeight = 0
	endif
	if(cmpstr(ctrlName,"DataCalibratedWeight")==0)	
		DataCalibratedArbitrary = 0
		DataCalibratedVolume = 0
		//DataCalibratedWeight = 0
	endif

	if(cmpstr(ctrlName,"SlitSmearDataCheckbox")==0)
		if(checked)
			SetVariable SlitLength, disable=0
			if(UseIndra2Names)
				ImportSMRdata=1
			endif
			DoAlert /T="Just checking..." 1, "Do you really want to slit smear imported data?"
			if(V_Flag>1)
				ImportSMRdata=0
				SetVariable SlitLength, disable=1
				NVAR SlitSmearData = root:Packages:ImportData:SlitSmearData
				SlitSmearData = 0
			endif
		else
			SetVariable SlitLength, disable=1
			if(UseIndra2Names)
				ImportSMRdata=0
			endif
		endif
		IR1I_CheckProc("UseIndra2Names",UseIndra2Names)
	endif


	if(cmpstr(ctrlName,"UseFileNameAsFolder")==0)	
		CheckBox IncludeExtensionInName, disable=!(checked)
		if (checked && UseIndra2Names)
			CheckBox ImportSMRdata, disable=0
		else
			CheckBox ImportSMRdata, disable=1
		endif
		if(!checked)
			//UseFileNameAsFolder = 1
			//UseQRSNames = 0
			UseIndra2Names = 0
			if (!UseQRSNames)
				NewDataFolderName = ""	
				NewIntensityWaveName= ""
				NewQwaveName= ""
				NewErrorWaveName= ""
			endif
			if (stringmatch(NewDataFolderName, "*<fileName>*"))
				NewDataFolderName = RemoveFromList("<fileName>", NewDataFolderName , ":")
			endif
		else
			if (!stringmatch(NewDataFolderName, "*<fileName>*"))
				if(strlen(NewDataFolderName)==0)
					NewDataFolderName="root:"
				endif
				NewDataFolderName+="<fileName>:"
			endif		
		endif
	endif
	if(cmpstr(ctrlName,"UseIndra2Names")==0)
		CheckBox ImportSMRdata, disable= !checked
		if(checked)
			UseFileNameAsFolder = 1
			UseQRSNames = 0
			UseQISNames = 0
			//UseIndra2Names = 0
			if (ImportSMRdata)
				NewDataFolderName = "root:USAXS:ImportedData:<fileName>:"	
				NewIntensityWaveName= "SMR_Int"
				NewQwaveName= "SMR_Qvec"
				NewErrorWaveName= "SMR_Error"
				NewQErrorWavename = "SMR_dQ"
			else
				NewDataFolderName = "root:USAXS:ImportedData:<fileName>:"	
				NewIntensityWaveName= "DSM_Int"
				NewQwaveName= "DSM_Qvec"
				NewErrorWaveName= "DSM_Error"
				NewQErrorWavename = "DSM_dQ"
			endif
		endif
	endif

	if(cmpstr(ctrlName,"ImportSMRdata")==0)
		NVAR UseIndra2Names=root:Packages:ImportData:UseIndra2Names
		if(checked)
			UseFileNameAsFolder = 1
			UseQRSNames = 0
			UseQISNames = 0
			SetVariable SlitLength, disable=0
			//UseIndra2Names = 0
			if (UseIndra2Names)
				NewDataFolderName = "root:USAXS:ImportedData:<fileName>:"	
				NewIntensityWaveName= "SMR_Int"
				NewQwaveName= "SMR_Qvec"
				NewErrorWaveName= "SMR_Error"
				NewQErrorWavename = "SMR_dQ"
			endif
		else
			SetVariable SlitLength, disable=1
			if (UseIndra2Names)
				NewDataFolderName = "root:USAXS:ImportedData:<fileName>:"	
				NewIntensityWaveName= "DSM_Int"
				NewQwaveName= "DSM_Qvec"
				NewErrorWaveName= "DSM_Error"
				NewQErrorWavename = "DSM_dQ"
			endif
		endif
	endif


	if(cmpstr(ctrlName,"UseQRSNames")==0)
		if (!checked && UseIndra2Names)
			CheckBox ImportSMRdata, disable=0
		else
			CheckBox ImportSMRdata, disable=1
		endif
		if(checked)
			//UseFileNameAsFolder = 1
			UseQISNames = 0
			UseIndra2Names = 0
			NewDataFolderName = "root:SAS:ImportedData:"	
			if (UseFileNameAsFolder)
				NewDataFolderName+="<fileName>:"
			endif		
			NewIntensityWaveName= "R_<fileName>"
			NewQwaveName= "Q_<fileName>"
			NewErrorWaveName= "S_<fileName>"
			NewQErrorWaveName= "W_<fileName>"
		endif
	endif
	if(cmpstr(ctrlName,"UseQISNames")==0)
		if (!checked && UseIndra2Names)
			CheckBox ImportSMRdata, disable=0
		else
			CheckBox ImportSMRdata, disable=1
		endif
		if(checked)
			//UseFileNameAsFolder = 1
			UseQRSNames = 0
			UseIndra2Names = 0
			NewDataFolderName = "root:"	
			//if (UseFileNameAsFolder)
				NewDataFolderName+="<fileName>:"
			//endif		
			NewIntensityWaveName= "<fileName>_i"
			NewQwaveName= "<fileName>_q"
			NewErrorWaveName= "<fileName>_s"
			NewQErrorWaveName= "<fileName>_w"
		endif
	endif
	
	if(cmpstr(ctrlName,"QvectorInA")==0)
		if(checked)
			QvectInNM = 0
		else
			QvectInNM = 1
		endif
	endif
	if(cmpstr(ctrlName,"QvectorInNM")==0)
		if(checked)
			QvectInA = 0
		else
			QvectInA = 1	
		endif
	endif

	if(cmpstr(ctrlName,"TrimData")==0)
				SetVariable TrimDataQMin, win=$(TopPanel) , disable=!(checked)
				SetVariable TrimDataQMax, win=$(TopPanel) , disable=!(checked)
	endif
	if(cmpstr(ctrlName,"TrunkateStart")==0)
			if(checked)
				TrunkateEnd=0
			else
				TrunkateEnd=1
			endif
	endif

	if(cmpstr(ctrlName,"TrunkateEnd")==0)
			if(checked)
				TrunkateStart=0
			else
				TrunkateStart=1
			endif
	endif

	if(cmpstr(ctrlName,"Col1Int")==0)
		//fix others for col 1
		if(checked)
			//Col1Int=0
			Col2Int=0
			Col3Int=0
			Col4Int=0
			Col5Int=0
			Col6Int=0
			Col1Qvec=0
			Col1Err=0			
			Col1QErr=0			
		endif
	endif
	if(cmpstr(ctrlName,"Col1Qvec")==0)
			Col1Int=0
			//Col1Qvec=0
			Col2Qvec=0
			Col3Qvec=0
			Col4Qvec=0
			Col5Qvec=0
			Col6Qvec=0
			Col1Err=0			
			Col1QErr=0			
	endif
	if(cmpstr(ctrlName,"Col1Error")==0)
			Col1Int=0
			Col1Qvec=0
			//Col1Err=0			
			Col2Err=0			
			Col3Err=0			
			Col4Err=0			
			Col5Err=0			
			Col6Err=0			
			Col1QErr=0		
	endif
	if(cmpstr(ctrlName,"Col1QError")==0)
			Col1Int=0
			Col1Qvec=0
			//Col1Err=0			
			Col2QErr=0			
			Col3QErr=0			
			Col4QErr=0			
			Col5QErr=0			
			Col6QErr=0			
			Col1Err=0			
	endif


	if(cmpstr(ctrlName,"Col2Int")==0)
		if(checked)
			Col1Int=0
			//Col2Int=0
			Col3Int=0
			Col4Int=0
			Col5Int=0
			Col6Int=0
			Col2Qvec=0
			Col2Err=0			
			Col2QErr=0			
		endif
	endif
	if(cmpstr(ctrlName,"Col2Qvec")==0)
			Col2Int=0
			Col1Qvec=0
			//Col2Qvec=0
			Col3Qvec=0
			Col4Qvec=0
			Col5Qvec=0
			Col6Qvec=0
			Col2Err=0			
			Col2QErr=0			
	endif
	if(cmpstr(ctrlName,"Col2Error")==0)
			Col2Int=0
			Col2Qvec=0
			Col1Err=0			
			//Col2Err=0			
			Col3Err=0			
			Col4Err=0			
			Col5Err=0			
			Col6Err=0			
			Col2QErr=0			
	endif
	if(cmpstr(ctrlName,"Col2QError")==0)
			Col2Int=0
			Col2Qvec=0
			Col1QErr=0			
			//Col2Err=0			
			Col3QErr=0			
			Col4QErr=0			
			Col5QErr=0			
			Col6QErr=0			
			Col2Err=0			
	endif
	
	if(cmpstr(ctrlName,"Col3Int")==0)
		if(checked)
			Col1Int=0
			Col2Int=0
			//Col3Int=0
			Col4Int=0
			Col5Int=0
			Col6Int=0
			Col3Qvec=0
			Col3Err=0			
			Col3QErr=0			
		endif
	endif
	if(cmpstr(ctrlName,"Col3Qvec")==0)
			Col3Int=0
			Col1Qvec=0
			Col2Qvec=0
			//Col3Qvec=0
			Col4Qvec=0
			Col5Qvec=0
			Col6Qvec=0
			Col3Err=0			
			Col3QErr=0			
	endif
	if(cmpstr(ctrlName,"Col3Error")==0)
			Col3Int=0
			Col3Qvec=0
			Col1Err=0			
			Col2Err=0			
			//Col3Err=0			
			Col4Err=0			
			Col5Err=0			
			Col6Err=0			
			Col3QErr=0			
	endif
	if(cmpstr(ctrlName,"Col3QError")==0)
			Col3Int=0
			Col3Qvec=0
			Col1QErr=0			
			Col2QErr=0			
			//Col3Err=0			
			Col4QErr=0			
			Col5QErr=0			
			Col6QErr=0			
			Col3Err=0			
	endif
	
	if(cmpstr(ctrlName,"Col4Int")==0)
		if(checked)
			Col1Int=0
			Col2Int=0
			Col3Int=0
			//Col4Int=0
			Col5Int=0
			Col6Int=0
			Col4Qvec=0
			Col4Err=0			
			Col4QErr=0			
		endif
	endif
	if(cmpstr(ctrlName,"Col4Qvec")==0)
			Col4Int=0
			Col1Qvec=0
			Col2Qvec=0
			Col3Qvec=0
			//Col4Qvec=0
			Col5Qvec=0
			Col6Qvec=0
			Col4Err=0			
			Col4QErr=0			
	endif
	if(cmpstr(ctrlName,"Col4Error")==0)
			Col4Int=0
			Col4Qvec=0
			Col1Err=0			
			Col2Err=0			
			Col3Err=0			
			//Col4Err=0			
			Col5Err=0			
			Col6Err=0			
			Col4QErr=0			
	endif
	if(cmpstr(ctrlName,"Col4QError")==0)
			Col4Int=0
			Col4Qvec=0
			Col1QErr=0			
			Col2QErr=0			
			Col3QErr=0			
			//Col4Err=0			
			Col5QErr=0			
			Col6QErr=0			
			Col4Err=0			
	endif

	if(cmpstr(ctrlName,"Col5Int")==0)
		if(checked)
			Col1Int=0
			Col2Int=0
			Col3Int=0
			Col4Int=0
			//Col5Int=0
			Col6Int=0
			Col5Qvec=0
			Col5Err=0			
			Col5QErr=0			
		endif
	endif
	if(cmpstr(ctrlName,"Col5Qvec")==0)
			Col5Int=0
			Col1Qvec=0
			Col2Qvec=0
			Col3Qvec=0
			Col4Qvec=0
			//Col5Qvec=0
			Col6Qvec=0
			Col5Err=0			
			Col5QErr=0			
	endif
	if(cmpstr(ctrlName,"Col5Error")==0)
			Col5Int=0
			Col5Qvec=0
			Col1Err=0			
			Col2Err=0			
			Col3Err=0			
			Col4Err=0			
			//Col5Err=0			
			Col6Err=0			
			Col5QErr=0			
	endif
	if(cmpstr(ctrlName,"Col5QError")==0)
			Col5Int=0
			Col5Qvec=0
			Col1QErr=0			
			Col2QErr=0			
			Col3QErr=0			
			Col4QErr=0			
			//Col5Err=0			
			Col6QErr=0			
			Col5Err=0			
	endif

	if(cmpstr(ctrlName,"Col6Int")==0)
		if(checked)
			Col1Int=0
			Col2Int=0
			Col3Int=0
			Col4Int=0
			Col5Int=0
			//Col6Int=0
			Col6Qvec=0
			Col6Err=0			
			Col6QErr=0			
		endif
	endif
	if(cmpstr(ctrlName,"Col6Qvec")==0)
			Col6Int=0
			Col1Qvec=0
			Col2Qvec=0
			Col3Qvec=0
			Col4Qvec=0
			Col5Qvec=0
			//Col6Qvec=0
			Col6Err=0			
			Col6QErr=0			
	endif
	if(cmpstr(ctrlName,"Col6Error")==0)
			Col6Int=0
			Col6Qvec=0
			Col1Err=0			
			Col2Err=0			
			Col3Err=0			
			Col4Err=0			
			Col5Err=0			
			//Col6Err=0			
			Col6QErr=0			
	endif
	if(cmpstr(ctrlName,"Col6QError")==0)
			Col6Int=0
			Col6Qvec=0
			Col1QErr=0			
			Col2QErr=0			
			Col3QErr=0			
			Col4QErr=0			
			Col5QErr=0			
			//Col6Err=0			
			Col6Err=0			
	endif
	if(stringmatch(TopPanel,"IR1I_ImportData") || stringmatch(TopPanel,"IR1I_ImportOtherASCIIData") )
		if (Col1Err || Col2Err || Col3Err || Col4Err || Col5Err || Col6Err)
			CheckBox CreateSQRTErrors, disable=1, win=$(TopPanel) 
			CheckBox CreatePercentErrors, disable=1, win=$(TopPanel) 
			CreateSQRTErrors=0
			CreatePercentErrors=0
			SetVariable PercentErrorsToUse, disable=1
		else
			CheckBox CreateSQRTErrors, disable=0, win=$(TopPanel) 
			CheckBox CreatePercentErrors, disable=0, win=$(TopPanel) 
			SetVariable PercentErrorsToUse, disable=!(CreatePercentErrors)
		endif
		
		if(Col6QErr || Col5QErr || Col4QErr || Col3QErr || Col2QErr || Col1QErr)
			SetVariable NewQErrorWaveName, disable = 0 
		else	
			SetVariable NewQErrorWaveName, disable = 1
		endif
	endif	
	if(cmpstr(ctrlName,"CreateSQRTErrors")==0)
		if(checked)
			CreatePercentErrors=0
			SetVariable PercentErrorsToUse, disable=1
		endif
	endif
	if(cmpstr(ctrlName,"CreatePercentErrors")==0)
		if(checked)
			CreateSQRTErrors=0
			SetVariable PercentErrorsToUse, disable=0
		else
			SetVariable PercentErrorsToUse, disable=1
		endif
	endif
	if(cmpstr(ctrlName,"ReduceNumPnts")==0)
		if(checked)
			SetVariable TargetNumberOfPoints, disable=0
			//SetVariable ReducePntsParam, disable=0	
		else
			SetVariable TargetNumberOfPoints, disable=1
			//SetVariable ReducePntsParam, disable=1
		endif
	endif
	
	if(cmpstr(ctrlName,"ScaleImportedDataCheckbox")==0)
		if(checked)
			SetVariable ScaleImportedDataBy, disable=0
		else
			SetVariable ScaleImportedDataBy, disable=1
		endif
	endif



	if(cmpstr(ctrlName,"SkipLines")==0)
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
Function IR1I_UpdateListOfFilesInWvs()

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR DataPathName = root:Packages:ImportData:DataPathName
	SVAR DataExtension  = root:Packages:ImportData:DataExtension
	SVAR NameMatchString = root:Packages:ImportData:NameMatchString
	Wave/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
	Wave WaveOfSelections = root:Packages:ImportData:WaveOfSelections
	string ListOfAllFiles
	string LocalDataExtension
	variable i, imax
	LocalDataExtension = DataExtension
	if (cmpstr(LocalDataExtension[0],".")!=0)
		LocalDataExtension = "."+LocalDataExtension
	endif
	PathInfo ImportDataPath
	if(V_Flag && strlen(DataPathName)>0)
		if (strlen(LocalDataExtension)<=1)
			ListOfAllFiles = IndexedFile(ImportDataPath,-1,"????")
		else		
			ListOfAllFiles = IndexedFile(ImportDataPath,-1,LocalDataExtension)
		endif
		if(strlen(NameMatchString)>0)
			ListOfAllFiles = GrepList(ListOfAllFiles, NameMatchString )
		endif
		//remove Invisible Mac files, .DS_Store and .plist
		ListOfAllFiles = IN2G_RemoveInvisibleFiles(ListOfAllFiles)
	
		imax = ItemsInList(ListOfAllFiles,";")
		Redimension/N=(imax) WaveOfSelections
		Redimension/N=(imax) WaveOfFiles
		for (i=0;i<imax;i+=1)
			WaveOfFiles[i] = stringFromList(i, ListOfAllFiles,";")
		endfor
	else
		Redimension/N=0 WaveOfSelections
		Redimension/N=0 WaveOfFiles
	endif 
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function IR1I_InitializeImportData()
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf = GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:ImportData
	
	string ListOfStrings
	string ListOfVariables
	variable i
	
	ListOfStrings = "DataPathName;DataExtension;IntName;QvecName;ErrorName;NewDataFolderName;NewIntensityWaveName;DataTypeToImport;"
	ListOfStrings+="NewQWaveName;NewErrorWaveName;NewQErrorWavename;NameMatchString;TooManyPointsWarning;RemoveStringFromName;"
	ListOfVariables = "UseFileNameAsFolder;UseIndra2Names;UseQRSNames;DataContainErrors;UseQISNames;ForceUTF8;"
	ListOfVariables += "SlitSmearData;SlitLength;UsesasEntryNameAsFolder;UseTitleNameAsFolder;"	
	ListOfVariables += "CreateSQRTErrors;Col1Int;Col1Qvec;Col1Err;Col1QErr;FoundNWaves;"	
	ListOfVariables += "Col2Int;Col2Qvec;Col2Err;Col2QErr;Col3Int;Col3Qvec;Col3Err;Col3QErr;Col4Int;Col4Qvec;Col4Err;Col4QErr;"	
	ListOfVariables += "Col5Int;Col5Qvec;Col5Err;Col5QErr;Col6Int;Col6Qvec;Col6Err;Col6QErr;Col7Int;Col7Qvec;Col7Err;Col7QErr;"	
	ListOfVariables += "QvectInA;QvectInNM;QvectInDegrees;CreateSQRTErrors;CreatePercentErrors;PercentErrorsToUse;"
	ListOfVariables += "ScaleImportedData;ScaleImportedDataBy;ImportSMRdata;SkipLines;SkipNumberOfLines;"	
	ListOfVariables += "IncludeExtensionInName;RemoveNegativeIntensities;AutomaticallyOverwrite;"	
	ListOfVariables += "TrimData;TrimDataQMin;TrimDataQMax;ReduceNumPnts;TargetNumberOfPoints;ReducePntsParam;"	
	ListOfVariables += "NumOfPointsFound;TrunkateStart;TrunkateEnd;Wavelength;"	
	ListOfVariables += "DataCalibratedArbitrary;DataCalibratedVolume;DataCalibratedWeight;"	
	//Nexus
	ListOfVariables += "NX_InclsasInstrument;NX_Incl_sasSample;NX_Inclsasnote;"	
	

		//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	SVAR TooManyPointsWarning
	TooManyPointsWarning=" "
	
	Make/O/T/N=0 WaveOfFiles
	Make/O/N=0 WaveOfSelections
	
	ListOfVariables = "CreateSQRTErrors;Col1Int;Col1Qvec;Col1Err;Col1QErr;"	
	ListOfVariables += "Col2Int;Col2Qvec;Col2Err;Col2QErr;Col3Int;Col3Qvec;Col3Err;Col3QErr;Col4Int;Col4Qvec;Col4Err;Col4QErr;"	
	ListOfVariables += "Col5Int;Col5Qvec;Col5Err;Col5QErr;Col6Int;Col6Qvec;Col6Err;Col6QErr;Col7Int;Col7Qvec;Col7Err;Col7QErr;"	
	ListOfVariables += "QvectInNM;CreateSQRTErrors;CreatePercentErrors;"	
	ListOfVariables += "ScaleImportedData;ImportSMRdata;SkipLines;SkipNumberOfLines;UseQISNames;UseIndra2Names;NumOfPointsFound;"	

	//We need list of known Data types for non-SAS importer
	string/g ListOfKnownDataTypes
	ListOfKnownDataTypes = "Q-Int;D-Int;Tth-Int;"//VolumeDistribution(Radius);VolumeDistribution(Diameter);"
	SVAR DataTypeToImport
	if(strlen(DataTypeToImport)<2)
		DataTypeToImport = StringFromList(0,ListOfKnownDataTypes)
	endif
	//Set numbers to 0
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test=$(StringFromList(i,ListOfVariables))
		test =0
	endfor		
	ListOfVariables = "QvectInA;PercentErrorsToUse;ScaleImportedDataBy;UseFileNameAsFolder;UseQRSNames;Wavelength;"	
	//Set numbers to 1
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test=$(StringFromList(i,ListOfVariables))
		test =1
	endfor		
	ListOfVariables = "TargetNumberOfPoints;"	
	//Set numbers to 1
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test=$(StringFromList(i,ListOfVariables))
		if(test<1)
			test =200
		endif
	endfor		
	ListOfVariables = "ReducePntsParam;"	
	//Set numbers to 1
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test=$(StringFromList(i,ListOfVariables))
		if(test<0.5)
			test =5
		endif
	endfor		
	
	NVAR DataCalibratedArbitrary
	NVAR DataCalibratedVolume
	NVAR DataCalibratedWeight
	if(DataCalibratedArbitrary+DataCalibratedVolume+DataCalibratedWeight!=1)
		DataCalibratedArbitrary = 1
		DataCalibratedVolume = 0
		DataCalibratedWeight = 0
	endif
	NVAR TrunkateStart
	NVAR TrunkateEnd
	if(TrunkateStart+TrunkateEnd!=1)
		TrunkateStart=0
		TrunkateEnd=1
	endif
	NVAR QvectInA
	NVAR QvectInNM
	NVAR QvectInDegrees
	if(QvectInA+QvectInNM+QvectInDegrees!=1)
		QvectInA=1
		QvectInNM=0
		QvectInDegrees=0
	endif
	
	IR1I_UpdateListOfFilesInWvs()
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_ImportOtherASCIIMain()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		//IR1_KillGraphsAndPanels()
	IN2G_CheckScreenSize("height",720)
	DoWindow IR1I_ImportData
	if(V_Flag)
		DoALert/T="Window conflict notice" 1, "Import SAS ASCII data cannot be open while using this tool, close (Yes) or abort (no)?"
		if(V_flag==1)
			KillWIndow/Z IR1I_ImportData
		else
			abort
		endif
	endif
	DoWindow IR1I_ImportNexusCanSASData
	if(V_Flag)
		DoALert/T="Window conflict notice" 1, "Import Nexus data cannot be open while using this tool, close (Yes) or abort (no)?"
		if(V_flag==1)
			KillWIndow/Z IR1I_ImportNexusCanSASData
		else
			abort
		endif
	endif
	KillWIndow/Z IR1I_ImportOtherASCIIData
	IR1I_InitializeImportData()
	IR1I_ImportOtherASCIIDataFnct()
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("IR1I_ImportOtherASCIIData", IR1IversionNumber2,1)
	//fix checboxes
	//IR1I_FIxCheckboxesForWaveTypes()
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_ImportOtherASCIIDataFnct() 
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(3,40,430,760)/N=IR1I_ImportOtherASCIIData as "Import non-SAS data"
	TitleBox MainTitle title="\Zr200Import non SAS ASCII Data in Igor",pos={20,5},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={400,24},anchor=MC,fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,40},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info21 title="\Zr140Col. 1",pos={239,192},frame=0,fstyle=2, fixedSize=1,size={150,20}
	TitleBox Info22 title="\Zr140Col. 2",pos={239,209},frame=0,fstyle=2, fixedSize=1,size={150,20}
	TitleBox Info23 title="\Zr140Col. 3",pos={239,226},frame=0,fstyle=2, fixedSize=1,size={150,20}
	TitleBox Info24 title="\Zr140Col. 4",pos={239,243},frame=0,fstyle=2, fixedSize=1,size={150,20}
	TitleBox Info25 title="\Zr140Col. 5",pos={239,260},frame=0,fstyle=2, fixedSize=1,size={150,20}
	TitleBox Info26 title="\Zr140Col. 6",pos={239,277},frame=0,fstyle=2, fixedSize=1,size={150,20}
	TitleBox Info6 title="\Zr150X",pos={298,172},frame=0,fstyle=2, fixedSize=0,size={40,15}
	TitleBox Info7 title="\Zr150Y",pos={330,172},frame=0,fstyle=2, fixedSize=0,size={40,15}
	TitleBox Info8 title="\Zr150dY",pos={360,172},frame=0,fstyle=2, fixedSize=0,size={40,15}
	TitleBox Info9 title="\Zr150dX",pos={392,172},frame=0,fstyle=2, fixedSize=0,size={40,15}
	
	IR3C_AddDataControls("ImportDataPath", "ImportData", "IR1I_ImportOtherASCIIData","", "","","IR1I_DoubleClickFUnction")
	ListBox ListOfAvailableData,size={220,277}, pos={5,113}
	Button SelectAll,pos={5,395}
	Button DeSelectAll, pos={120,395}

	CheckBox SkipLines,pos={230,133},size={16,14},proc=IR1I_CheckProc,title="Skip lines?",variable= root:Packages:ImportData:SkipLines, help={"Check if you want to skip lines in header. Needed ONLY for weird headers..."}
	SetVariable SkipNumberOfLines,pos={300,133},size={70,19},proc=IR1I_SetVarProc,title=" "
	SetVariable SkipNumberOfLines,help={"Insert number of lines to skip"}
	NVAR DisableSkipLines=root:Packages:ImportData:SkipLines
	SetVariable SkipNumberOfLines,variable= root:Packages:ImportData:SkipNumberOfLines, disable=(!DisableSkipLines)

	Button TestImport,pos={230,152},size={80,15}, proc=IR1I_ButtonProc,title="Test"
	Button TestImport,help={"Test how if import can be succesful and how many waves are found"}
	Button Preview,pos={330,152},size={80,15}, proc=IR1I_ButtonProc,title="Preview"
	Button Preview,help={"Preview selected file."}
	Button GetHelp,pos={335,60},size={80,15},fColor=(65535,32768,32768), proc=IR1I_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}
//
	CheckBox Col1Qvec,pos={299,192},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col1Qvec, help={"What does this column contain?"}
	CheckBox Col1Int,pos={331,192},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col1Int, help={"What does this column contain?"}
	CheckBox Col1Error,pos={364,192},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col1Err, help={"What does this column contain?"}
	CheckBox Col1QError,pos={394,192},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col1QErr, help={"What does this column contain?"}

	CheckBox Col2Qvec,pos={299,209},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col2Qvec, help={"What does this column contain?"}
	CheckBox Col2Int,pos={331,209},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col2Int, help={"What does this column contain?"}
	CheckBox Col2Error,pos={364,209},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col2Err, help={"What does this column contain?"}
	CheckBox Col2QError,pos={394,209},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col2QErr, help={"What does this column contain?"}

	CheckBox Col3Qvec,pos={299,226},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col3Qvec, help={"What does this column contain?"}
	CheckBox Col3Int,pos={331,226},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col3Int, help={"What does this column contain?"}
	CheckBox Col3Error,pos={364,226},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col3Err, help={"What does this column contain?"}
	CheckBox Col3QError,pos={394,226},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col3QErr, help={"What does this column contain?"}

	CheckBox Col4Qvec,pos={299,243},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col4Qvec, help={"What does this column contain?"}
	CheckBox Col4Int,pos={331,243},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col4Int, help={"What does this column contain?"}
	CheckBox Col4Error,pos={364,243},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col4Err, help={"What does this column contain?"}
	CheckBox Col4QError,pos={394,243},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col4QErr, help={"What does this column contain?"}

	CheckBox Col5Qvec,pos={299,260},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col5Qvec, help={"What does this column contain?"}
	CheckBox Col5Int,pos={331,260},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col5Int, help={"What does this column contain?"}
	CheckBox Col5Error,pos={364,260},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col5Err, help={"What does this column contain?"}
	CheckBox Col5QError,pos={394,260},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col5QErr, help={"What does this column contain?"}

	CheckBox Col6Qvec,pos={299,277},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col6Qvec, help={"What does this column contain?"}
	CheckBox Col6Int,pos={331,277},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col6Int, help={"What does this column contain?"}
	CheckBox Col6Error,pos={364,277},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col6Err, help={"What does this column contain?"}
	CheckBox Col6QError,pos={394,277},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col6QErr, help={"What does this column contain?"}

//
//
	SetVariable FoundNWaves,pos={239,296},size={160,19},title="Found cols.:  ",proc=IR1I_SetVarProc
	SetVariable FoundNWaves,help={"This is how many columns were found in the tested file"}, disable=2
	SetVariable FoundNWaves,limits={0,Inf,0},value= root:Packages:ImportData:FoundNWaves

	Button Plot,pos={330,317},size={80,15}, proc=IR1I_ButtonProc,title="Plot"
	Button Plot,help={"Preview selected file."}

	CheckBox QvectorInA,pos={240,340},size={16,14},proc=IR1I_CheckProc,title="X units [1/A, deg, A]",variable= root:Packages:ImportData:QvectInA, help={"What units is X in? Select if in 1/A for Q, A for d, degree for TwoTheta"}
	CheckBox QvectorInNM,pos={240,355},size={16,14},proc=IR1I_CheckProc,title="X units [1/nm or nm]",variable= root:Packages:ImportData:QvectInNM, help={"What units is X in? Select if in 1/nm for Q or nm for d. WIll be converted to 1/A or A"}
	//CheckBox QvectInDegrees,pos={240,355},size={16,14},proc=IR1I_CheckProc,title="X units [degree]",variable= root:Packages:ImportData:QvectInDegrees, help={"What units is X axis in? Select if in degrees... WIll be converted to inverse Angstroems"}

	CheckBox CreateSQRTErrors,pos={240,370},size={16,14},proc=IR1I_CheckProc,title="Create SQRT dY?",variable= root:Packages:ImportData:CreateSQRTErrors, help={"If input data do not contain errors, create errors as sqrt of intensity?"}
	CheckBox CreatePercentErrors,pos={240,385},size={16,14},proc=IR1I_CheckProc,title="Create n% dY?",variable= root:Packages:ImportData:CreatePercentErrors, help={"If input data do not contain errors, create errors as n% of intensity?, select how many %"}
	NVAR DiablePctErr=root:Packages:ImportData:CreatePercentErrors
	SetVariable PercentErrorsToUse, pos={240,403}, size={100,20},title="dY %?:", proc=IR1I_setvarProc, disable=!(DiablePctErr)
	SetVariable PercentErrorsToUse value= root:packages:ImportData:PercentErrorsToUse,help={"Input how many percent error you want to create."}
	CheckBox UseFileNameAsFolder,pos={10,420},size={16,14},proc=IR1I_CheckProc,title="Use File Nms as Fldr Nms?",variable= root:Packages:ImportData:UseFileNameAsFolder, help={"Use names of imported files as folder names for the data?"}
	NVAR DisableExt=root:Packages:ImportData:UseFileNameAsFolder
	NVAR DisableOver=root:Packages:ImportData:UseFileNameAsFolder
	CheckBox AutomaticallyOverwrite,pos={240,420},size={16,14},proc=IR1I_CheckProc,title="Overwrite existing data?",variable= root:Packages:ImportData:AutomaticallyOverwrite, help={"Automatically overwrite imported data if same data exist?"}, disable=!(DisableOver)

	SVAR DataTypeToImport=root:Packages:ImportData:DataTypeToImport
	SVAR ListOfKnownDataTypes=root:Packages:ImportData:ListOfKnownDataTypes
	PopupMenu ImportDataType,pos={10,450},size={250,21},proc=IR1I_PopMenuProc,title="Data Type", help={"Select waht data are being imported for proper naming"}
	PopupMenu ImportDataType,mode=1,popvalue=DataTypeToImport,value= #"root:Packages:ImportData:ListOfKnownDataTypes"
	SetVariable Wavelength, pos={260,453}, size={150,10}, variable=root:Packages:ImportData:Wavelength, noproc, help={"For Two Theta (Tth) we need wavelength in A"}
	SetVariable Wavelength, disable = !StringMatch(DataTypeToImport,"Tth-Int")

	CheckBox ScaleImportedDataCheckbox,pos={10,475},size={16,14},proc=IR1I_CheckProc,title="Scale Imported data?",variable= root:Packages:ImportData:ScaleImportedData, help={"Check to scale (multiply by) factor imported data. Both Intensity and error will be scaled by same number. Insert appriate number right."}
	NVAR DisableScale=root:Packages:ImportData:ScaleImportedData
	SetVariable ScaleImportedDataBy, pos={200,475}, size={140,20},title="Scaling factor?:", proc=IR1I_setvarProc, disable=!(DisableScale)
	SetVariable ScaleImportedDataBy limits={1e-32,inf,1},value= root:packages:ImportData:ScaleImportedDataBy,help={"Input number by which you want to multiply the imported intensity and errors."}
	CheckBox RemoveNegativeIntensities,pos={10,500},size={16,14},proc=IR1I_CheckProc,title="Remove Int<=0?",variable= root:Packages:ImportData:RemoveNegativeIntensities, help={"Remove Intensities smaller than 0?"}
	NVAR DisableTrim=root:Packages:ImportData:TrimData
	CheckBox TrimData,pos={10,526},size={16,14},proc=IR1I_CheckProc,title="Trim data?",variable= root:Packages:ImportData:TrimData, help={"Check to trim Q range of the imported data."}
	SetVariable TrimDataQMin, pos={110,524}, size={110,20},title="X min=", proc=IR1I_setvarProc, disable=!(DisableTrim)
	SetVariable TrimDataQMin limits={0,inf,0},value= root:packages:ImportData:TrimDataQMin,help={"Xmin for trimming data. Leave 0 if not trimming at low q is needed."}
	SetVariable TrimDataQMax, pos={240,524}, size={110,20},title="X max=", proc=IR1I_setvarProc, disable=!(DisableTrim)
	SetVariable TrimDataQMax limits={0,inf,0},value= root:packages:ImportData:TrimDataQMax,help={"Xmax for trimming data. Leave 0 if not trimming at low q is needed."}
//
	CheckBox TrunkateStart,pos={10,545},size={16,14},proc=IR1I_CheckProc,title="Truncate start of long names?",variable= root:Packages:ImportData:TrunkateStart, help={"Truncate names longer than 24 characters in front"}
	CheckBox TrunkateEnd,pos={240,545},size={16,14},proc=IR1I_CheckProc,title="Truncate end of long names?",variable= root:Packages:ImportData:TrunkateEnd, help={"Truncate names longer than 24 characters at the end"}
	SetVariable RemoveStringFromName, pos={5,565}, size={320,20},title="Remove Str From Name=", noproc
	SetVariable RemoveStringFromName value= root:packages:ImportData:RemoveStringFromName,help={"Input string to be removed from name, leve empty if none"}
	PopupMenu SelectFolderNewData2,pos={10,590},size={250,21},proc=IR1I_PopMenuProc,title="Select data folder", help={"Select folder with data"}
	PopupMenu SelectFolderNewData2,mode=1,popvalue="---",value= #"\"---;\"+IN2G_NewFindFolderWithWaveTypes(\"root:\", 10, \"*\", 1)"
	SetVariable NewDataFolderName, pos={5,620}, size={410,20},title="New data folder:", proc=IR1I_setvarProc
	SetVariable NewDataFolderName value= root:packages:ImportData:NewDataFolderName,help={"Folder for the new data. Will be created, if does not exist.Or pick one ip popup above"}
	SetVariable NewQwaveName, pos={5,640}, size={320,20},title="X wave names ", proc=IR1I_setvarProc
	SetVariable NewQwaveName, value= root:packages:ImportData:NewQWaveName,help={"Input name for the new Q wave"}
	SetVariable NewIntensityWaveName, pos={5,660}, size={320,20},title="Y wave names", proc=IR1I_setvarProc
	SetVariable NewIntensityWaveName, value= root:packages:ImportData:NewIntensityWaveName,help={"Input name for the new intensity wave"}
	SetVariable NewErrorWaveName, pos={5,680}, size={320,20},title="dY wv names", proc=IR1I_setvarProc
	SetVariable NewErrorWaveName, value= root:packages:ImportData:NewErrorWaveName,help={"Input name for the new Error wave"}
	SetVariable NewQErrorWaveName, pos={5,700}, size={320,20},title="dX wv names  ", proc=IR1I_setvarProc
	SetVariable NewQErrorWaveName, value= root:packages:ImportData:NewQErrorWaveName,help={"Input name for the new Q data Error wave"}

	Button ImportData2,pos={330,660},size={80,30}, proc=IR1I_ButtonProc,title="Import"
	Button ImportData2,help={"Import the selected data files."}

	IR1I_ImportOtherSetNames()

EndMacro

//************************************************************************************************************
//************************************************************************************************************
Function IR1I_DoubleClickFUnction()

	IR1I_ButtonProc("TestImport")
	
end


//************************************************************************************************************
//************************************************************************************************************
Function IR1I_ImportDataFnct2()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	string TopPanel=WinName(0, 64)
	string OldDf = getDataFolder(1)
	
	Wave/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
	Wave WaveOfSelections = root:Packages:ImportData:WaveOfSelections

	IR1I_CheckForProperNewFolder()
	variable i, imax, icount
	string SelectedFile
	imax = numpnts(WaveOfSelections)
	icount = 0
	for(i=0;i<imax;i+=1)
		if (WaveOfSelections[i])
			selectedfile = WaveOfFiles[i]
			IR1I_CreateImportDataFolder(selectedFile)
			KillWaves/Z TempIntensity, TempQvector, TempError
			IR1I_ImportOneFile(selectedFile)
			IR1I_ProcessImpWaves2(selectedFile)		//this thing also creates new error waves, removes negative qs and intesities and does everything else
			IR1I_RecordResults(selectedFile)
			icount+=1
		endif
	endfor
	print "Imported "+num2str(icount)+" data file(s) in total"
	setDataFolder OldDf
end

//************************************************************************************************************
//************************************************************************************************************


//IR1I_TestPlotData()

Function IR1I_ImportOtherSetNames()

	SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
	SVAR NewIntensityWaveName= root:packages:ImportData:NewIntensityWaveName
	SVAR NewQwaveName= root:packages:ImportData:NewQWaveName
	SVAR NewErrorWaveName= root:packages:ImportData:NewErrorWaveName
	SVAR NewQErrorWaveName= root:packages:ImportData:NewQErrorWaveName
	NVAR UseFileNameAsFolder = root:Packages:ImportData:UseFileNameAsFolder
	SVAR DataTypeToImport=root:Packages:ImportData:DataTypeToImport
	
	if(!stringmatch(NewDataFolderName[0,3],"root"))
			NewDataFolderName = "root:ImportedData:"		
	endif
	if(UseFileNameAsFolder&&(!GrepString(NewDataFolderName, "<fileName>")))	
			NewDataFolderName+="<fileName>:"
	endif
	//	ListOfKnownDataTypes = "Q-Int;D-Int;Tth-Int;VolumeDistribution(Radius);VolumeDistribution(Diameter);"
	if(StringMatch(DataTypeToImport, "Q-Int"))
		if(UseFileNameAsFolder)			
			NewQwaveName= "Q_<fileName>"
			NewIntensityWaveName= "R_<fileName>"
			NewErrorWaveName= "S_<fileName>"
			NewQErrorWaveName= "W_<fileName>"
		else
			NewQwaveName= "Q_ChangeMe"
			NewIntensityWaveName= "R_"
			NewErrorWaveName= "S_"
			NewQErrorWaveName= "W_"	
		endif
	elseif(StringMatch(DataTypeToImport, "D-Int")	)
		if(UseFileNameAsFolder)			
			NewQwaveName= "D_<fileName>"
			NewIntensityWaveName= "R_<fileName>"
			NewErrorWaveName= "S_<fileName>"
			NewQErrorWaveName= "W_<fileName>"
		else
			NewQwaveName= "D_ChangeMe"
			NewIntensityWaveName= "R_"
			NewErrorWaveName= "S_"
			NewQErrorWaveName= "W_"	
		endif
	elseif(StringMatch(DataTypeToImport, "Tth-Int")	)
		if(UseFileNameAsFolder)			
			NewQwaveName= "T_<fileName>"
			NewIntensityWaveName= "R_<fileName>"
			NewErrorWaveName= "S_<fileName>"
			NewQErrorWaveName= "W_<fileName>"
		else
			NewQwaveName= "T_ChangeMe"
			NewIntensityWaveName= "R_"
			NewErrorWaveName= "S_"
			NewQErrorWaveName= "W_"	
		endif
	elseif(StringMatch(DataTypeToImport, "VolumeDistribution(Radius)")	)
		if(UseFileNameAsFolder)			
			NewQwaveName= "Radius"
			NewIntensityWaveName= "VoluemDistribution"
			NewErrorWaveName= "S_<fileName>"
			NewQErrorWaveName= "W_<fileName>"
		else
			NewQwaveName= "D_ChangeMe"
			NewIntensityWaveName= "R_"
			NewErrorWaveName= "S_"
			NewQErrorWaveName= "W_"	
		endif
	elseif(StringMatch(DataTypeToImport, "VolumeDistribution(Diameter)"))	
		if(UseFileNameAsFolder)			
			NewQwaveName= "Diameter"
			NewIntensityWaveName= "VolumeDistribution"
			NewErrorWaveName= "S_<fileName>"
			NewQErrorWaveName= "W_<fileName>"
		else
			NewQwaveName= "D_ChangeMe"
			NewIntensityWaveName= "R_"
			NewErrorWaveName= "S_"
			NewQErrorWaveName= "W_"	
		endif

	else
		if(UseFileNameAsFolder)			
			NewQwaveName= "Q_<fileName>"
			NewIntensityWaveName= "R_<fileName>"
			NewErrorWaveName= "S_<fileName>"
			NewQErrorWaveName= "W_<fileName>"
		else
			NewQwaveName= "Q_ChangeMe"
			NewIntensityWaveName= "R_"
			NewErrorWaveName= "S_"
			NewQErrorWaveName= "W_"	
		endif
	endif

end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_ProcessImpWaves2(selectedFile)
	string selectedFile
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	variable i, numOfInts, numOfQs, numOfErrs, numOfQErrs, refNum
	numOfInts  = 0
	numOfQs   = 0
	numOfErrs = 0
	numOfQErrs = 0
	string HeaderFromData=""
	NVAR SkipNumberOfLines=root:Packages:ImportData:SkipNumberOfLines
	NVAR SkipLines=root:Packages:ImportData:SkipLines	
	NVAR FoundNWaves = root:Packages:ImportData:FoundNWaves
	NVAR TrunkateStart = root:Packages:ImportData:TrunkateStart
	NVAR TrunkateEnd = root:Packages:ImportData:TrunkateEnd
	variable GenError=0

	if(!SkipLines)			//lines automatically skipped, so the header may make sense, add to header...
	        Open/R/P=ImportDataPath refNum as selectedFile
		HeaderFromData=""
	        Variable j
 	       String text
  	      For(j=0;j<SkipNumberOfLines;j+=1)
   	             FReadLine refNum, text
 			HeaderFromData+=ZapNonLetterNumStart(IN2G_ZapControlCodes(text))+";"
		endfor        
	      Close refNum
	endif	
	NVAR DataContainErrors=root:Packages:ImportData:DataContainErrors
	DataContainErrors=0
	variable LimitFoundWaves = (FoundNWaves<=6) ? FoundNWaves : 7 
	For(i=0;i<LimitFoundWaves;i+=1)	
		NVAR testIntStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"Int")
		NVAR testQvecStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"Qvec")
		NVAR testErrStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"Err")
		NVAR testQErrStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"QErr")
		Wave/Z CurrentWave = $("wave"+num2str(i))
		SVAR DataPathName=root:Packages:ImportData:DataPathName
		if (testIntStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempIntensity
			//print "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData+";"
			note/NOCR TempIntensity, "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData+";"
			//print note(TempIntensity)
			numOfInts+=1
		endif
		if (testQvecStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempQvector
			note/NOCR TempQvector, "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData+";"
			numOfQs+=1
		endif
		if (testErrStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempError
			note/NOCR TempError, "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData+";"
			numOfErrs+=1
			DataContainErrors=1
		endif
		if (testQErrStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempQError
			note TempQError, "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData+";"
			numOfQErrs+=1
		endif
		if(!WaveExists(CurrentWave))
			GenError=0
			string Messg="Error, the column of data selected did not exist in the data file. The missing column is : "
			if(testIntStr)
				Messg+="Intensity"
				GenError=1
			elseif(testQvecStr)
				Messg+="Q vector"
				GenError=1
			elseif(testErrStr)
				Messg+="Error"
				GenError=1
			elseif(testQErrStr)
				Messg+="Q Error"
				GenError=1
			endif
			if(GenError)
				DoAlert 0, Messg 
			endif
		endif
	endfor
	if (numOfInts!=1 || numOfQs!=1 || numOfErrs>1|| numOfQErrs>1)
		Abort "Import waves problem, check values in checkboxes which indicate which column contains Intensity, Q and error"
	endif

	//here we will modify the data if user wants to do so...
	NVAR QvectInA=root:Packages:ImportData:QvectInA
	NVAR QvectInNM=root:Packages:ImportData:QvectInNM
	NVAR ScaleImportedData=root:Packages:ImportData:ScaleImportedData
	NVAR ScaleImportedDataBy=root:Packages:ImportData:ScaleImportedDataBy
	SVAR DataTypeToImport=root:Packages:ImportData:DataTypeToImport
	if (QvectInNM)
		if(stringMatch(DataTypeToImport,"Q-Int"))
			TempQvector=TempQvector/10			//converts nm-1 in A-1  
			note TempQvector, "Q data converted from nm to A-1;"
			if(WaveExists(TempQError))
				TempQError = TempQError/10
				note/NOCR TempQError, "Q error converted from nm to A-1;"
			endif
		elseif(stringMatch(DataTypeToImport,"D-Int"))
			TempQvector=TempQvector*10			//converts nm in A
			note TempQvector, "d data converted from nm to A;"
			if(WaveExists(TempQError))
				TempQError = TempQError/10
				note/NOCR TempQError, "d error converted from nm to A;"
			endif
		endif
	endif
	if (ScaleImportedData)
		TempIntensity=TempIntensity*ScaleImportedDataBy		//scales imported data for user
		note/NOCR TempIntensity, "Data scaled by="+num2str(ScaleImportedDataBy)+";"
		if (WaveExists(TempError))
			TempError=TempError*ScaleImportedDataBy		//scales imported data for user
			note/NOCR TempError, "Data scaled by="+num2str(ScaleImportedDataBy)+";"
		endif
	endif
	//lets insert here the Units into the wave notes...
	//deal with wavelength if data are Tth-Int:
	if(StringMatch(DataTypeToImport,"Tth-Int"))
		NVAR Wavelength=root:Packages:ImportData:Wavelength
		note/NOCR TempIntensity, "wavelength="+num2str(Wavelength)+";"
		if(WaveExists(TempError))
			note/NOCR TempError, "wavelength="+num2str(Wavelength)+";"
		endif
		if(WaveExists(TempQError))
			note/NOCR TempQError, "wavelength="+num2str(Wavelength)+";"	
		endif
	endif
	//here we will deal with erros, if the user needs to create them
	NVAR CreateSQRTErrors=root:Packages:ImportData:CreateSQRTErrors
	NVAR CreatePercentErrors=root:Packages:ImportData:CreatePercentErrors
	NVAR PercentErrorsToUse=root:Packages:ImportData:PercentErrorsToUse
	if ((CreatePercentErrors||CreateSQRTErrors) && WaveExists(TempError))	
		DoAlert 0, "Debugging message: Should create SQRT errors, but error wave exists. Mess in the checkbox values..."
	endif
	if (CreatePercentErrors && PercentErrorsToUse<1e-12)
		DoAlert 0, "You want to create percent error wave, but your error fraction is extremally small. This is likely error, so please, check the number and reimport the data"
		abort
	endif
	if (CreateSQRTErrors && !WaveExists(TempError))
		Duplicate/O TempIntensity, TempError
		TempError = sqrt(TempIntensity)
		note TempError, "Error data created for user as SQRT of intensity;"
	endif
	if (CreatePercentErrors && !WaveExists(TempError))
		Duplicate/O TempIntensity, TempError
		TempError = abs(TempIntensity) * (PercentErrorsToUse/100)
		note TempError, "Error data created for user as percentage of intensity;Amount of error as percentage="+num2str(PercentErrorsToUse/100)+";"
	endif
	//now remove negative intensities. If there are still some left and asked for. 
	NVAR RemoveNegativeIntensities = root:packages:ImportData:RemoveNegativeIntensities
	if(RemoveNegativeIntensities)
		TempIntensity = TempIntensity[p]<=0 ?  NaN :  TempIntensity[p]	
	endif
	if(WaveExists(TempError)&&WaveExists(TempQError))	//have 4 waves
		IN2G_RemoveNaNsFrom4Waves(TempQvector, TempIntensity, TempError,TempQError)
	elseif(WaveExists(TempError)&&!WaveExists(TempQError))	//have 3 waves
		IN2G_RemoveNaNsFrom3Waves(TempQvector, TempIntensity, TempError)
	elseif(!WaveExists(TempError)&&WaveExists(TempQError))	//have 3 waves
		IN2G_RemoveNaNsFrom3Waves(TempQvector, TempIntensity, TempQError)
	else	//only 2 waves 
		IN2G_RemoveNaNsFrom2Waves(TempQvector, TempIntensity)
	endif
	//just in case, we need to sort the data (some users have data which are not sorted...
	if(WaveExists(TempError))
		if(waveExists(TempQError))
			sort TempQvector,TempQvector, TempIntensity, TempError,TempQError
		else
			sort TempQvector,TempQvector, TempIntensity, TempError
		endif
	else
		sort TempQvector,TempQvector, TempIntensity	
	endif
	//all negative qs are removed...
	//optionally trim the Q range here...
	NVAR TrimData= root:packages:ImportData:TrimData
	NVAR TrimDataQMin= root:packages:ImportData:TrimDataQMin
	NVAR TrimDataQMax= root:packages:ImportData:TrimDataQMax
	if(TrimData)
		variable StartPointsToRemove=0
		if(TrimDataQMin>0)
			StartPointsToRemove=binarysearch(TempQvector,TrimDataQMin)
		endif
		variable EndPointsToRemove=numpnts(TempQvector)
		if(TrimDataQMax>0 && TrimDataQMax<TempQvector[inf])
			EndPointsToRemove=binarysearch(TempQvector,TrimDataQMax)
		endif
		if(TrimDataQMin>0)
			TempQvector[0,StartPointsToRemove]=NaN
		endif
		if(TrimDataQMax>0 && TrimDataQMax<TempQvector[inf])
			TempQvector[EndPointsToRemove+1,inf]=NaN
		endif
		if(WaveExists(TempError)&&WaveExists(TempQError))	//have 4 waves
			IN2G_RemoveNaNsFrom4Waves(TempQvector, TempIntensity, TempError,TempQError)
		elseif(WaveExists(TempError)&&!WaveExists(TempQError))	//have 3 waves
			IN2G_RemoveNaNsFrom3Waves(TempQvector, TempIntensity, TempError)
		elseif(!WaveExists(TempError)&&WaveExists(TempQError))	//have 3 waves
			IN2G_RemoveNaNsFrom3Waves(TempQvector, TempIntensity, TempQError)
		else	//only 2 waves 
			IN2G_RemoveNaNsFrom2Waves(TempQvector, TempIntensity)
		endif
	endif	
	//check on TempError if it contains meaningful number and stop user if not...
	if(WaveExists(TempError))
		wavestats/Q TempError
		if((V_min<=0)||(V_numNANs>0)||(V_numINFs>0))
			abort "The Errors (Uncertainities) contain negative values, 0, NANs, or INFs. This is not acceptable. Import aborted. Please, check the input data or use % or SQRT errors"
		endif
	endif

	SVAR NewIntensityWaveName= root:packages:ImportData:NewIntensityWaveName
	SVAR NewQwaveName= root:packages:ImportData:NewQWaveName
	SVAR NewErrorWaveName= root:packages:ImportData:NewErrorWaveName
	SVAR NewQErrorWaveName= root:packages:ImportData:NewQErrorWaveName
	SVAR RemoveStringFromName=root:Packages:ImportData:RemoveStringFromName
	NVAR IncludeExtensionInName=root:packages:ImportData:IncludeExtensionInName
	string NewIntName, NewQName, NewEName, NewQEName, tempFirstPart, tempLastPart
	
	if(stringMatch(NewIntensityWaveName,"*<fileName>*")==0)
		NewIntName = IR1I_RemoveBadCharacters(NewIntensityWaveName)
		NewIntName = CleanupName(NewIntName, 1 )
		NewIntName=IR1I_TrunkateName(NewIntName,TrunkateStart,TrunkateEnd,RemoveStringFromName)
	else
		TempFirstPart = NewIntensityWaveName[0,strsearch(NewIntensityWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewIntensityWaveName[strsearch(NewIntensityWaveName, "<fileName>", 0 )+10,inf]
		if(IncludeExtensionInName)
			NewIntName = TempFirstPart+IR1I_TrunkateName(selectedFile,TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		else
			NewIntName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		endif
		NewIntName = IR1I_RemoveBadCharacters(NewIntName)
		NewIntName = CleanupName(NewIntName, 1 )
	endif
	if(stringMatch(NewQwaveName,"*<fileName>*")==0)
		NewQName =IR1I_RemoveBadCharacters(NewQwaveName)
		NewQName = CleanupName(NewQName, 1 )
		NewQName=IR1I_TrunkateName(NewQName,TrunkateStart,TrunkateEnd,RemoveStringFromName)
	else
		TempFirstPart = NewQwaveName[0,strsearch(NewQwaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewQwaveName[strsearch(NewQwaveName, "<fileName>", 0 )+10,inf]
		if(IncludeExtensionInName)
			NewQName = TempFirstPart+IR1I_TrunkateName(selectedFile,TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		else
			NewQName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		endif
		NewQName =IR1I_RemoveBadCharacters(NewQName)
		NewQName = CleanupName(NewQName, 1 )
	endif
	if(stringMatch(NewErrorWaveName,"*<fileName>*")==0)
		NewEName =IR1I_RemoveBadCharacters(NewErrorWaveName)
		NewEName = CleanupName(NewEName, 1 )
		NewEName=IR1I_TrunkateName(NewEName,TrunkateStart,TrunkateEnd,RemoveStringFromName)
	else
		TempFirstPart = NewErrorWaveName[0,strsearch(NewErrorWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewErrorWaveName[strsearch(NewErrorWaveName, "<fileName>", 0 )+10,inf]
		if(IncludeExtensionInName)
			NewEName = TempFirstPart+IR1I_TrunkateName(selectedFile,TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		else
			NewEName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		endif
		NewEName =IR1I_RemoveBadCharacters(NewEName)
		NewEName = CleanupName(NewEName, 1 )
	endif
	if(stringMatch(NewQErrorWaveName,"*<fileName>*")==0)
		NewQEName =IR1I_RemoveBadCharacters(NewQEName)
		NewQEName = CleanupName(NewQErrorWaveName, 1 )
		NewQEName=IR1I_TrunkateName(NewQEName,TrunkateStart,TrunkateEnd,RemoveStringFromName)
	else
		TempFirstPart = NewQErrorWaveName[0,strsearch(NewQErrorWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewQErrorWaveName[strsearch(NewQErrorWaveName, "<fileName>", 0 )+10,inf]
		if(IncludeExtensionInName)
			NewQEName = TempFirstPart+IR1I_TrunkateName(selectedFile,TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		else
			NewQEName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd,RemoveStringFromName)+tempLastPart
		endif
		NewQEName =IR1I_RemoveBadCharacters(NewQEName)
		NewQEName = CleanupName(NewQEName, 1 )
	endif
	NVAr AutomaticallyOverwrite = root:Packages:ImportData:AutomaticallyOverwrite
	Wave/Z testE=$NewEName
	Wave/Z testQ=$NewQName
	Wave/Z testI=$NewIntName
	Wave/Z testQE=$NewQEName
	if ((WaveExists(testI) || WaveExists(testQ)||WaveExists(testE)||WaveExists(testQE))&&!AutomaticallyOverwrite)
		DoAlert 1, "The data of this name : "+NewIntName+" , "+NewQName+ " , "+NewEName+" , or "+NewQEName+"  exist. DO you want to overwrite them?"
		if (V_Flag==2)
			abort
		endif
	elseif((WaveExists(testI) || WaveExists(testQ)||WaveExists(testE)||WaveExists(testQE))&&AutomaticallyOverwrite)
		//we ovewrote some data, let's at least know about it
		print "The data of this name : "+NewIntName+" , "+NewQName+ " , "+NewEName+" , or "+NewQEName+"  existed. Due to user selection, old data were deleted and replaced with newly imported ones."
	endif
		
	Duplicate/O TempQvector, $NewQName
	Duplicate/O TempIntensity, $NewIntName
	if(WaveExists(TempError))
		Duplicate/O TempError, $NewEName
	endif	
	if(WaveExists(TempQError))
		Duplicate/O TempQError, $NewQEName
	endif	
	KillWaves/Z tempError, tempQvector, TempIntensity, TempQError
	IR1I_KillAutoWaves()
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//		Nexus Import functions 

//************************************************************************************************************
//************************************************************************************************************

Function IR1I_ImportNexusCanSASMain()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		//IR1_KillGraphsAndPanels()
	IN2G_CheckScreenSize("height",720)
	DoWindow IR1I_ImportData
	if(V_Flag)
		DoALert/T="Window conflict notice" 1, "Import SAS ASCII data cannot be open while using this tool, close (Yes) or abort (no)?"
		if(V_flag==1)
			KillWIndow/Z IR1I_ImportData
		else
			abort
		endif
	endif
	DoWindow IR1I_ImportOtherASCIIData
	if(V_Flag)
		DoALert/T="Window conflict notice" 1, "Import Nexus data cannot be open while using this tool, close (Yes) or abort (no)?"
		if(V_flag==1)
			KillWIndow/Z IR1I_ImportOtherASCIIData
		else
			abort
		endif
	endif
	KillWIndow/Z IR1I_ImportOtherASCIIData
	IR1I_InitializeImportData()
	IR1I_ImportNexusDataFnct()
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("IR1I_ImportNexusCanSASData", IR1IversionNumberNexus,1)
	//fix these checkboxes;
	NVAR UseFileNameasFolder = root:Packages:ImportData:UseFileNameasFolder
	NVAR UsesasEntryNameAsFolder = root:Packages:ImportData:UsesasEntryNameAsFolder
	NVAR UseTitleNameAsFolder = root:Packages:ImportData:UseTitleNameAsFolder
	if((UseFileNameasFolder+UsesasEntryNameAsFolder+UseTitleNameAsFolder)!=1)
		UseFileNameasFolder  =0
		UsesasEntryNameAsFolder = 0
		UseTitleNameAsFolder = 1
	endif

end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_ImportNexusDataFnct() 
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(3,40,430,620)/N=IR1I_ImportNexusCanSASData as "Import Nexus canSAS data"
	TitleBox MainTitle title="\Zr200Import Nexus canSAS Data in Igor",pos={20,5},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={400,24},anchor=MC,fColor=(0,0,52224)
	IR3C_AddDataControls("ImportDataPath", "ImportData", "IR1I_ImportNexusCanSASData","", "","","IR1I_NexusDoubleClickFUnction")
	ListBox ListOfAvailableData,size={410,250}
	Button SelectDataPath pos={110,40}
	SetVariable DataPathString pos={2,62}
	SetVariable NameMatchString pos={5,85}
	SetVariable DataExtensionString pos={260,85}
	//CheckBox QvectorInA,pos={240,405},size={16,14},proc=IR1I_CheckProc,title="Q in [A^-1]",variable= root:Packages:ImportData:QvectInA, help={"What units is Q in? Select if in Angstroems ^-1"}
	//CheckBox QvectorInNM,pos={240,422},size={16,14},proc=IR1I_CheckProc,title="Q in [nm^-1]",variable= root:Packages:ImportData:QvectInNM, help={"What units is Q in? Select if in nanometers ^-1. WIll be converted to inverse Angstroems"}
	CheckBox UseFileNameAsFolderNX,pos={10,400},size={16,14},proc=IR1I_CheckProc,title="Use File Nms as Fldr Nms?",variable= root:Packages:ImportData:UseFileNameAsFolder, help={"Use names of imported files as folder names for the data?"}
	CheckBox UsesasEntryNameAsFolderNX,pos={10,415},size={16,14},proc=IR1I_CheckProc,title="Use sasEntry Nms as Fldr Nms?",variable= root:Packages:ImportData:UsesasEntryNameAsFolder, help={"Use names of imported files as folder names for the data?"}
	CheckBox UseTitleNameAsFolderNX,pos={10,430},size={16,14},proc=IR1I_CheckProc,title="Use sasTitle as Fldr Nms?",variable= root:Packages:ImportData:UseTitleNameAsFolder, help={"Use names of imported files as folder names for the data?"}

	Button OpenFileInBrowser,pos={250,400},size={150,20},proc=IR1I_ButtonProc,title="Open File in Browser"
	Button OpenFileInBrowser,help={"Check file in HDF5 Browser"}
	Button GetHelp,pos={335,60},size={80,15},fColor=(65535,32768,32768), proc=IR1I_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}

	CheckBox NX_InclsasInstrument,pos={230,420},size={16,14},noproc,title="Incl sasInstrument in WVnote?",variable= root:Packages:ImportData:NX_InclsasInstrument, help={"Include values from sasInstrument group in wave note?"}
	CheckBox NX_Incl_sasSample,pos={230,435},size={16,14},noproc,title="Incl sasSample in WVnote?",variable= root:Packages:ImportData:NX_Incl_sasSample, help={"Include values from sasSample group in wave note?"}
	CheckBox NX_Inclsasnote,pos={230,450},size={16,14},noproc,title="Incl sasNote in WVnote?",variable= root:Packages:ImportData:NX_Inclsasnote, help={"Include values from sasNote group in wave note?"}

	//CheckBox DataCalibratedArbitrary,pos={10,442},size={16,14},mode=1,proc=IR1I_CheckProc,title="Calibration Arbitrary\S \M",variable= root:Packages:ImportData:DataCalibratedArbitrary, help={"Data not calibrated (on relative scale)"}
	//CheckBox DataCalibratedVolume,pos={150,442},size={16,14},mode=1,proc=IR1I_CheckProc,title="Calibration cm\S-1\Msr\S-1\M",variable= root:Packages:ImportData:DataCalibratedVolume, help={"Data calibrated to volume"}
	//CheckBox DataCalibratedWeight,pos={290,442},size={16,14},mode=1,proc=IR1I_CheckProc,title="Calibration cm\S2\Mg\S-1\Msr\S-1\M",variable= root:Packages:ImportData:DataCalibratedWeight, help={"Data calibrated to weight"}
	SetVariable NewDataFolderName, pos={5,470}, size={410,20},title="New data folder:", proc=IR1I_setvarProc
	SetVariable NewDataFolderName value= root:packages:ImportData:NewDataFolderName,help={"Folder for the new data. Will be created, if does not exist.Or pick one ip popup above"}
	SetVariable NewQwaveName, pos={5,490}, size={320,20},title="Q wave names ", proc=IR1I_setvarProc, bodyWidth=230
	SetVariable NewQwaveName, value= root:packages:ImportData:NewQWaveName,help={"Input name for the new Q wave"}
	SetVariable NewIntensityWaveName, pos={5,510}, size={320,20},title="I wave names", proc=IR1I_setvarProc, bodyWidth=230
	SetVariable NewIntensityWaveName, value= root:packages:ImportData:NewIntensityWaveName,help={"Input name for the new intensity wave"}
	SetVariable NewErrorWaveName, pos={5,530}, size={320,20},title="Idev wv names", proc=IR1I_setvarProc, bodyWidth=230
	SetVariable NewErrorWaveName, value= root:packages:ImportData:NewErrorWaveName,help={"Input name for the new uncertyaintiy wave"}
	SetVariable NewQErrorWaveName, pos={5,550}, size={320,20},title="Qres wv names  ", proc=IR1I_setvarProc, bodyWidth=230
	SetVariable NewQErrorWaveName, value= root:packages:ImportData:NewQErrorWaveName,help={"Input name for the new Q resolution wave"}

	Button ImportDataNexus,pos={330,510},size={80,30}, proc=IR1I_ButtonProc,title="Import"
	Button ImportDataNexus,help={"Import the selected data files."}

	IR1I_ImportOtherSetNames()
//
//	PopupMenu SelectFolderNewData2,pos={10,590},size={250,21},proc=IR1I_PopMenuProc,title="Select data folder", help={"Select folder with data"}
//	PopupMenu SelectFolderNewData2,mode=1,popvalue="---",value= #"\"---;\"+IN2G_NewFindFolderWithWaveTypes(\"root:\", 10, \"*\", 1)"
//	CheckBox CreateSQRTErrors,pos={240,370},size={16,14},proc=IR1I_CheckProc,title="Create SQRT dY?",variable= root:Packages:ImportData:CreateSQRTErrors, help={"If input data do not contain errors, create errors as sqrt of intensity?"}
//	CheckBox CreatePercentErrors,pos={240,385},size={16,14},proc=IR1I_CheckProc,title="Create n% dY?",variable= root:Packages:ImportData:CreatePercentErrors, help={"If input data do not contain errors, create errors as n% of intensity?, select how many %"}
//	NVAR DiablePctErr=root:Packages:ImportData:CreatePercentErrors
//	SetVariable PercentErrorsToUse, pos={240,403}, size={100,20},title="dY %?:", proc=IR1I_setvarProc, disable=!(DiablePctErr)
//	SetVariable PercentErrorsToUse value= root:packages:ImportData:PercentErrorsToUse,help={"Input how many percent error you want to create."}
//
//	NVAR DisableExt=root:Packages:ImportData:UseFileNameAsFolder
//	CheckBox IncludeExtensionInName,pos={260,418},size={16,14},proc=IR1I_CheckProc,title="Include Extn?",variable= root:Packages:ImportData:IncludeExtensionInName, help={"Include file extension in imported data foldername?"}, disable=!(DisableExt)
////	CheckBox UseIndra2Names,pos={10,436},size={16,14},proc=IR1I_CheckProc,title="Use USAXS names?",variable= root:Packages:ImportData:UseIndra2Names, help={"Use wave names using Indra 2 name structure? (DSM_Int, DSM_Qvec, DSM_Error)"}
////	CheckBox ImportSMRdata,pos={150,436},size={16,14},proc=IR1I_CheckProc,title="Slit smeared?",variable= root:Packages:ImportData:ImportSMRdata, help={"Check if the data are slit smeared, changes suggested Indra data names to SMR_Qvec, SMR_Int, SMR_Error"}
////	CheckBox ImportSMRdata, disable= !root:Packages:ImportData:UseIndra2Names
//	CheckBox UseQRSNames,pos={10,452},size={16,14},proc=IR1I_CheckProc,title="Use QRS wave names?",variable= root:Packages:ImportData:UseQRSNames, help={"Use QRS name structure? (Q_filename, R_filename, S_filename)"}
////	CheckBox UseQISNames,pos={150,452},size={16,14},proc=IR1I_CheckProc,title="Use QIS (NIST) wv nms?",variable= root:Packages:ImportData:UseQISNames, help={"Use QIS name structure? (filename_q, filename_i, filename_s)"}
//
//	NVAR DisableOver=root:Packages:ImportData:UseFileNameAsFolder
//	CheckBox AutomaticallyOverwrite,pos={240,420},size={16,14},proc=IR1I_CheckProc,title="Overwrite existing data?",variable= root:Packages:ImportData:AutomaticallyOverwrite, help={"Automatically overwrite imported data if same data exist?"}, disable=!(DisableOver)

//	SVAR DataTypeToImport=root:Packages:ImportData:DataTypeToImport
//	SVAR ListOfKnownDataTypes=root:Packages:ImportData:ListOfKnownDataTypes
//	PopupMenu ImportDataType,pos={10,450},size={250,21},proc=IR1I_PopMenuProc,title="Data Type", help={"Select waht data are being imported for proper naming"}
//	PopupMenu ImportDataType,mode=1,popvalue=DataTypeToImport,value= #"root:Packages:ImportData:ListOfKnownDataTypes"
//	SetVariable Wavelength, pos={260,453}, size={150,10}, variable=root:Packages:ImportData:Wavelength, noproc, help={"For Two Theta (Tth) we need wavelength in A"}
//	SetVariable Wavelength, disable = !StringMatch(DataTypeToImport,"Tth-Int")

//	CheckBox ScaleImportedDataCheckbox,pos={10,475},size={16,14},proc=IR1I_CheckProc,title="Scale Imported data?",variable= root:Packages:ImportData:ScaleImportedData, help={"Check to scale (multiply by) factor imported data. Both Intensity and error will be scaled by same number. Insert appriate number right."}
//	NVAR DisableScale=root:Packages:ImportData:ScaleImportedData
//	SetVariable ScaleImportedDataBy, pos={200,475}, size={140,20},title="Scaling factor?:", proc=IR1I_setvarProc, disable=!(DisableScale)
//	SetVariable ScaleImportedDataBy limits={1e-32,inf,1},value= root:packages:ImportData:ScaleImportedDataBy,help={"Input number by which you want to multiply the imported intensity and errors."}
//	CheckBox RemoveNegativeIntensities,pos={10,500},size={16,14},proc=IR1I_CheckProc,title="Remove Int<=0?",variable= root:Packages:ImportData:RemoveNegativeIntensities, help={"Remove Intensities smaller than 0?"}
//	NVAR DisableTrim=root:Packages:ImportData:TrimData
//	CheckBox TrimData,pos={10,526},size={16,14},proc=IR1I_CheckProc,title="Trim data?",variable= root:Packages:ImportData:TrimData, help={"Check to trim Q range of the imported data."}
//	SetVariable TrimDataQMin, pos={110,524}, size={110,20},title="X min=", proc=IR1I_setvarProc, disable=!(DisableTrim)
//	SetVariable TrimDataQMin limits={0,inf,0},value= root:packages:ImportData:TrimDataQMin,help={"Xmin for trimming data. Leave 0 if not trimming at low q is needed."}
//	SetVariable TrimDataQMax, pos={240,524}, size={110,20},title="X max=", proc=IR1I_setvarProc, disable=!(DisableTrim)
//	SetVariable TrimDataQMax limits={0,inf,0},value= root:packages:ImportData:TrimDataQMax,help={"Xmax for trimming data. Leave 0 if not trimming at low q is needed."}
//
//	CheckBox ReduceNumPnts,pos={10,543},size={16,14},proc=IR1I_CheckProc,title="Reduce points?",variable= root:Packages:ImportData:ReduceNumPnts, help={"Check to log-reduce number of points"}
//	NVAR ReduceNumPnts = root:Packages:ImportData:ReduceNumPnts
//	SetVariable TargetNumberOfPoints, pos={140,541}, size={110,20},title="Num points=", proc=IR1I_setvarProc, disable=!(ReduceNumPnts)
//	SetVariable TargetNumberOfPoints limits={10,1000,0},value= root:packages:ImportData:TargetNumberOfPoints,help={"Target number of points after reduction. Uses same method as Data manipulation I"}
//
//	CheckBox TrunkateStart,pos={10,545},size={16,14},proc=IR1I_CheckProc,title="Truncate start of long names?",variable= root:Packages:ImportData:TrunkateStart, help={"Truncate names longer than 24 characters in front"}
//	CheckBox TrunkateEnd,pos={240,545},size={16,14},proc=IR1I_CheckProc,title="Truncate end of long names?",variable= root:Packages:ImportData:TrunkateEnd, help={"Truncate names longer than 24 characters at the end"}
//	SetVariable RemoveStringFromName, pos={5,565}, size={320,20},title="Remove Str From Name=", noproc
//	SetVariable RemoveStringFromName value= root:packages:ImportData:RemoveStringFromName,help={"Input string to be removed from name, leve empty if none"}
//

EndMacro
 
 //************************************************************************************************************
//************************************************************************************************************
Function IR1I_NexusDoubleClickFUnction()

	//IR1I_ButtonProc("TestImport")
	IR1I_ImportDataFnctNexus()
end

 //************************************************************************************************************
//************************************************************************************************************
Function IR1I_ImportDataFnctNexus()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	string TopPanel=WinName(0, 64)
	string OldDf = getDataFolder(1)
	Variable timerRefNum, microSeconds
	timerRefNum = startMSTimer
	
	Wave/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
	Wave WaveOfSelections = root:Packages:ImportData:WaveOfSelections

	NVAR UseFolder = root:Packages:ImportData:UseFileNameasFolder
	NVAR UseEntry = root:Packages:ImportData:UsesasEntryNameAsFolder
	NVAR UseTitle = root:Packages:ImportData:UseTitleNameAsFolder

	NVAR NX_SasIns = root:Packages:ImportData:NX_InclsasInstrument
	NVAR NX_SASSam = root:Packages:ImportData:NX_Incl_sasSample
	NVAR NX_SASNote = root:Packages:ImportData:NX_Inclsasnote

	IR1I_CheckForProperNewFolder()
	variable i, imax, icount
	string SelectedFile
	imax = numpnts(WaveOfSelections)
	icount = 0
	for(i=0;i<imax;i+=1)
		if (WaveOfSelections[i])
			selectedfile = WaveOfFiles[i]
			NEXUS_NXcanSASDataReader("ImportDataPath",selectedFile,1,0, UseFolder, UseEntry,UseTitle, NX_SasIns,NX_SASSam,NX_SASNote)	
			icount+=1
		endif
	endfor
	microSeconds = StopMSTimer(timerRefNum)
	Print microSeconds/1e6, "Seconds for import"
	print "Imported "+num2str(icount)+" data file(s) in total"
	setDataFolder root:Packages:ImportData
	//clean up the experiment..
	KillDataFolder/Z root:Packages:NexusImportTMP	
end

//************************************************************************************************************
//************************************************************************************************************
Function IR1I_NexusOpenHdf5File()
	
	Wave/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
	Wave WaveOfSelections = root:Packages:ImportData:WaveOfSelections
	
	variable NumSelFiles=sum(WaveOfSelections)	
	variable OpenMultipleFiles=0
	if(NumSelFiles==0)
		return 0
	endif
	if(NumSelFiles>1)
		DoAlert /T="Choose what to do:" 2, "You have selected multiple files, do you want to open the first one [Yes], all [No], or cancel?" 
		if(V_Flag==0)
			return 0
		elseif(V_Flag==2)
			OpenMultipleFiles=1
		endif
	endif
	
	variable i
	string FileName
	String browserName
	Variable locFileID
	For(i=0;i<numpnts(WaveOfSelections);i+=1)
		if(WaveOfSelections[i])
			FileName= WaveOfFiles[i]
//			HDf5Browser#CreateNewHDF5Browser()
//		 	browserName = WinName(0, 64)
//			HDF5OpenFile/R /P=ImportDataPath locFileID as FileName
//			if (V_flag == 0)					// Open OK?
//				HDf5Browser#UpdateAfterFileCreateOrOpen(0, browserName, locFileID, S_path, S_fileName)
//			endif
#if(IgorVersion()<9)
			HDf5Browser#CreateNewHDF5Browser()
		 	browserName = WinName(0, 64)
			HDF5OpenFile/R /P=Convert2Dto1DDataPath locFileID as FileName
			if (V_flag == 0)					// Open OK?
				HDf5Browser#UpdateAfterFileCreateOrOpen(0, browserName, locFileID, S_path, S_fileName)
			endif
#else
			HDf5Browser#CreateNewHDF5Browser("Convert2Dto1DDataPath", FileName, 1, browserName)
#endif

			if(!OpenMultipleFiles)
				return 0
			endif
		endif
	endfor
end

//************************************************************************************************************
//************************************************************************************************************