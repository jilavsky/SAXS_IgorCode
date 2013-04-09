#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.17
Constant IR1IversionNumber = 2.17
Constant IR1TrimNameLength = 28
//*************************************************************************\
//* Copyright (c) 2005 - 2013, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

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


Function IR1I_ImportDataMain()
	//IR1_KillGraphsAndPanels()
	IN2G_CheckScreenSize("height",740)
	DoWindow IR1I_ImportData
	if(V_Flag)
		DoWIndow/K IR1I_ImportData
	endif
	IR1I_InitializeImportData()
	Execute("IR1I_ImportData()")
	ING2_AddScrollControl()
	UpdatePanelVersionNumber("IR1I_ImportData", IR1IversionNumber)
	//fix checboxes
	IR1I_FIxCheckboxesForWaveTypes()
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_MainCheckVersion()	
	DoWindow IR1I_ImportData
	if(V_Flag)
		if(!CheckPanelVersionNumber("IR1I_ImportData", IR1IversionNumber))
			DoAlert /T="The ASCII Import panel was created by old version of Irena " 1, "Import ASCII may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				Execute/P("IR1I_ImportDataMain()")
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

Proc IR1I_ImportData() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(3,40,430,720) as "Import data"
	DoWindow/C IR1I_ImportData
//	SetDrawLayer UserBack
//	SetDrawEnv fsize= 18,fstyle= 1,textrgb= (16384,16384,65280)
//	DrawText 84,31,"Import Data in Igor"
	TitleBox MainTitle title="Import Data in Igor",pos={40,5},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,24},fSize=22,fColor=(0,0,52224)
//	SetDrawEnv linethick= 2,linefgc= (16384,16384,65280)
//	DrawLine 21,44,363,44
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,40},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
//	DrawText 41,123,"List of available files"
	TitleBox Info1 title="List of available files",pos={30,107},frame=0,fstyle=1, fixedSize=1,size={120,20},fSize=12,fColor=(0,0,52224)
//	DrawText 216,231,"Column 1"
	TitleBox Info21 title="Column 1",pos={216,215},frame=0,fstyle=2, fixedSize=1,size={150,20},fSize=12
//	DrawText 216,248,"Column 2"
	TitleBox Info22 title="Column 2",pos={216,232},frame=0,fstyle=2, fixedSize=1,size={150,20},fSize=12
//	DrawText 216,265,"Column 3"
	TitleBox Info23 title="Column 3",pos={216,249},frame=0,fstyle=2, fixedSize=1,size={150,20},fSize=12
//	DrawText 216,282,"Column 4"
	TitleBox Info24 title="Column 4",pos={216,266},frame=0,fstyle=2, fixedSize=1,size={150,20},fSize=12
//	DrawText 216,299,"Column 5"
	TitleBox Info25 title="Column 5",pos={216,283},frame=0,fstyle=2, fixedSize=1,size={150,20},fSize=12
//	DrawText 216,316,"Column 6"
	TitleBox Info26 title="Column 6",pos={216,300},frame=0,fstyle=2, fixedSize=1,size={150,20},fSize=12
//	DrawText 291,211,"Qvec  Int      Err   QErr"
	TitleBox Info6 title="Qvec  Int      Err   QErr",pos={285,195},frame=0,fstyle=2, fixedSize=0,size={40,15},fSize=12

//	TitleBox Info3 title="Fit?",pos={200,262},frame=0,fstyle=2, fixedSize=0,size={20,15},fSize=12
//	TitleBox Info4 title="Low limit:    High Limit:",pos={230,262},frame=0,fstyle=2, fixedSize=0,size={120,15},fSize=12
//	TitleBox Info5 title="Fit using least square fitting ?",pos={2,583},frame=0,fstyle=2, fixedSize=0,size={140,15},fSize=10,fColor=(0,0,52224)



	Button SelectDataPath,pos={99,53},size={130,20}, proc=IR1I_ButtonProc,title="Select data path"
	Button SelectDataPath,help={"Select data path to the data"}
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
	ListBox ListOfAvailableData,mode= 4, proc=IR1_ImportListBoxProc

	SetVariable NameMatchString,pos={10,375},size={180,19},proc=IR1I_SetVarProc,title="Match name (RegEx):"
	SetVariable NameMatchString,help={"Insert RegEx select only data with matching name (uses grep)"}
	SetVariable NameMatchString,value= root:Packages:ImportData:NameMatchString

	CheckBox SkipLines,pos={220,133},size={16,14},proc=IR1I_CheckProc,title="Skip lines?",variable= root:Packages:ImportData:SkipLines, help={"Check if you want to skip lines in header. Needed ONLY for weird headers..."}
	SetVariable SkipNumberOfLines,pos={300,133},size={70,19},proc=IR1I_SetVarProc,title=" "
	SetVariable SkipNumberOfLines,help={"Insert number of lines to skip"}
	SetVariable SkipNumberOfLines,variable= root:Packages:ImportData:SkipNumberOfLines, disable=(!root:Packages:ImportData:SkipLines)

	Button TestImport,pos={210,152},size={80,15}, proc=IR1I_ButtonProc,title="Test"
	Button TestImport,help={"Test how if import can be succesful and how many waves are found"}
	Button Preview,pos={300,152},size={80,15}, proc=IR1I_ButtonProc,title="Preview"
	Button Preview,help={"Preview selected file."}

	TitleBox TooManyPointsWarning variable=root:Packages:ImportData:TooManyPointsWarning,fColor=(0,0,0)
	TitleBox TooManyPointsWarning pos={220,170},size={150,19}, disable=1
	
///	SetVariable NumOfPointsFound,pos={220,170},size={150,19},title="Found points :",proc=IR1I_SetVarProc
//	SetVariable NumOfPointsFound,help={"This is how many points are in the file. If more than 300 consider reducing"}, disable=2
//	SetVariable NumOfPointsFound,limits={0,Inf,0},value= root:Packages:ImportData:NumOfPointsFound

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

	CheckBox QvectorInA,pos={240,340},size={16,14},proc=IR1I_CheckProc,title="Qvec units [A^-1]",variable= root:Packages:ImportData:QvectInA, help={"What units is Q in? Select if in Angstroems ^-1"}
	CheckBox QvectorInNM,pos={240,355},size={16,14},proc=IR1I_CheckProc,title="Qvec units [nm^-1]",variable= root:Packages:ImportData:QvectInNM, help={"What units is Q in? Select if in nanometers ^-1. WIll be converted to inverse Angstroems"}
	CheckBox CreateSQRTErrors,pos={240,370},size={16,14},proc=IR1I_CheckProc,title="Create SQRT Errors?",variable= root:Packages:ImportData:CreateSQRTErrors, help={"If input data do not contain errors, create errors as sqrt of intensity?"}
	CheckBox CreatePercentErrors,pos={240,385},size={16,14},proc=IR1I_CheckProc,title="Create n% Errors?",variable= root:Packages:ImportData:CreatePercentErrors, help={"If input data do not contain errors, create errors as n% of intensity?, select how many %"}
	SetVariable PercentErrorsToUse, pos={240,403}, size={100,20},title="Error %?:", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:CreatePercentErrors)
	SetVariable PercentErrorsToUse value= root:packages:ImportData:PercentErrorsToUse,help={"Input how many percent error you want to create."}


	Button SelectAll,pos={5,396},size={100,20}, proc=IR1I_ButtonProc,title="Select All"
	Button SelectAll,help={"Select all waves in the list"}

	Button DeSelectAll,pos={120,396},size={100,20}, proc=IR1I_ButtonProc,title="Deselect All"
	Button DeSelectAll,help={"Deselect all waves in the list"}

	CheckBox UseFileNameAsFolder,pos={10,420},size={16,14},proc=IR1I_CheckProc,title="Use File Nms As Fldr Nms?",variable= root:Packages:ImportData:UseFileNameAsFolder, help={"Use names of imported files as folder names for the data?"}
	CheckBox IncludeExtensionInName,pos={240,420},size={16,14},proc=IR1I_CheckProc,title="Include Extension in fldr nm?",variable= root:Packages:ImportData:IncludeExtensionInName, help={"Include file extension in imported data foldername?"}, disable=!(root:Packages:ImportData:UseFileNameAsFolder)
	CheckBox UseIndra2Names,pos={10,436},size={16,14},proc=IR1I_CheckProc,title="Use USAXS names?",variable= root:Packages:ImportData:UseIndra2Names, help={"Use wave names using Indra 2 name structure? (DSM_Int, DSM_Qvec, DSM_Error)"}
	CheckBox ImportSMRdata,pos={150,436},size={16,14},proc=IR1I_CheckProc,title="Slit smeared?",variable= root:Packages:ImportData:ImportSMRdata, help={"Check if the data are slit smeared, changes suggested Indra data names to SMR_Qvec, SMR_Int, SMR_error"}
	CheckBox ImportSMRdata, disable= !root:Packages:ImportData:UseIndra2Names
	CheckBox UseQRSNames,pos={10,452},size={16,14},proc=IR1I_CheckProc,title="Use QRS wave names?",variable= root:Packages:ImportData:UseQRSNames, help={"Use QRS name structure? (Q_filename, R_filename, S_filename)"}
	CheckBox UseQISNames,pos={150,452},size={16,14},proc=IR1I_CheckProc,title="Use QIS (NIST) wv nms?",variable= root:Packages:ImportData:UseQISNames, help={"Use QIS name structure? (filename_q, filename_i, filename_s)"}
	CheckBox RemoveNegativeIntensities,pos={10,468},size={16,14},proc=IR1I_CheckProc,title="Remove Int<0?",variable= root:Packages:ImportData:RemoveNegativeIntensities, help={"Remove Intensities smaller than 0?"}


	CheckBox ScaleImportedDataCheckbox,pos={240,436},size={16,14},proc=IR1I_CheckProc,title="Scale Imported data?",variable= root:Packages:ImportData:ScaleImportedData, help={"Check to scale (multiply by) factor imported data. Both Intensity and error will be scaled by same number. Insert appriate number below."}
	SetVariable ScaleImportedDataBy, pos={280,452}, size={140,20},title="Scaling factor?:", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:ScaleImportedData)
	SetVariable ScaleImportedDataBy limits={1e-32,inf,1},value= root:packages:ImportData:ScaleImportedDataBy,help={"Input number by which you want to multiply the imported intensity and errors."}
	CheckBox AutomaticallyOverwrite,pos={240,468},size={16,14},proc=IR1I_CheckProc,title="Auto overwrite?",variable= root:Packages:ImportData:AutomaticallyOverwrite, help={"Automatically overwrite imported data if same data exist?"}, disable=!(root:Packages:ImportData:UseFileNameAsFolder)

	CheckBox TrimData,pos={10,487},size={16,14},proc=IR1I_CheckProc,title="Trim data?",variable= root:Packages:ImportData:TrimData, help={"Check to trim Q range of the imported data."}
	SetVariable TrimDataQMin, pos={110,485}, size={110,20},title="Qmin=", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:TrimData)
	SetVariable TrimDataQMin limits={1e-32,inf,0},value= root:packages:ImportData:TrimDataQMin,help={"Qmin for trimming data. Leave 0 if not trimming at low q is needed."}
	SetVariable TrimDataQMax, pos={240,485}, size={110,20},title="Qmax=", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:TrimData)
	SetVariable TrimDataQMax limits={1e-32,inf,0},value= root:packages:ImportData:TrimDataQMax,help={"Qmax for trimming data. Leave 0 if not trimming at low q is needed."}

	CheckBox ReduceNumPnts,pos={10,507},size={16,14},proc=IR1I_CheckProc,title="Reduce points?",variable= root:Packages:ImportData:ReduceNumPnts, help={"Check to log-reduce number of points"}
	SetVariable TargetNumberOfPoints, pos={110,505}, size={110,20},title="Num points=", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:ReduceNumPnts)
	SetVariable TargetNumberOfPoints limits={10,1000,0},value= root:packages:ImportData:TargetNumberOfPoints,help={"Target number of points after reduction. Uses same method as Data manipualtion I"}
	SetVariable ReducePntsParam, pos={240,505}, size={170,20},title="Red. pnts. Param=", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:ReduceNumPnts)
	SetVariable ReducePntsParam limits={0.5,10,0},value= root:packages:ImportData:ReducePntsParam,help={"Log reduce points parameter, typically 3-5"}

	CheckBox TrunkateStart,pos={10,527},size={16,14},proc=IR1I_CheckProc,title="Truncate start of long names?",variable= root:Packages:ImportData:TrunkateStart, help={"Truncate names longer than 24 characters in front"}
	CheckBox TrunkateEnd,pos={240,527},size={16,14},proc=IR1I_CheckProc,title="Truncate end of long names?",variable= root:Packages:ImportData:TrunkateEnd, help={"Truncate names longer than 24 characters at the end"}
//	PopupMenu SelectFolderNewData,pos={1,525},size={250,21},proc=IR1I_PopMenuProc,title="Select data folder", help={"Select folder with data"}
//	PopupMenu SelectFolderNewData,mode=1,popvalue="---",value= #"\"---;\"+IR1_GenStringOfFolders(0, 0,0,0)"

	CheckBox DataCalibratedArbitrary,pos={10,547},size={16,14},mode=1,proc=IR1I_CheckProc,title="Calibration Arbitrary",variable= root:Packages:ImportData:DataCalibratedArbitrary, help={"Data not calibrated (on relative scale)"}
	CheckBox DataCalibratedVolume,pos={150,547},size={16,14},mode=1,proc=IR1I_CheckProc,title="Calibration cm2/cm3",variable= root:Packages:ImportData:DataCalibratedVolume, help={"Data calibrated to volume"}
	CheckBox DataCalibratedWeight,pos={290,547},size={16,14},mode=1,proc=IR1I_CheckProc,title="Calibration cm2/g",variable= root:Packages:ImportData:DataCalibratedWeight, help={"Data calibrated to weight"}

	SetVariable NewDataFolderName, pos={5,570}, size={410,20},title="New data folder:", proc=IR1I_setvarProc
	SetVariable NewDataFolderName value= root:packages:ImportData:NewDataFolderName,help={"Folder for the new data. Will be created, if does not exist. Use popup above to preselect."}
	SetVariable NewQwaveName, pos={5,590}, size={320,20},title="Q wave names ", proc=IR1I_setvarProc
	SetVariable NewQwaveName, value= root:packages:ImportData:NewQWaveName,help={"Input name for the new Q wave"}
	SetVariable NewIntensityWaveName, pos={5,610}, size={320,20},title="Intensity names", proc=IR1I_setvarProc
	SetVariable NewIntensityWaveName, value= root:packages:ImportData:NewIntensityWaveName,help={"Input name for the new intensity wave"}
	SetVariable NewErrorWaveName, pos={5,630}, size={320,20},title="Error wv names", proc=IR1I_setvarProc
	SetVariable NewErrorWaveName, value= root:packages:ImportData:NewErrorWaveName,help={"Input name for the new Error wave"}
	SetVariable NewQErrorWaveName, pos={5,650}, size={320,20},title="Q Error wv names", proc=IR1I_setvarProc
	SetVariable NewQErrorWaveName, value= root:packages:ImportData:NewQErrorWaveName,help={"Input name for the new Q data Error wave"}

	Button ImportData,pos={330,610},size={80,30}, proc=IR1I_ButtonProc,title="Import"
	Button ImportData,help={"Import the selected data files."}

	IR1I_CheckProc("UseQRSNames",1)

EndMacro

//************************************************************************************************************
//************************************************************************************************************
Function IR1_ImportListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

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
			IR1I_NameImportedWaves(selectedFile)		//this thing also creates new error waves, removes negative qs and intesities
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

Function  IR1I_ImportRebinData(TempInt,TempQ,TempE,TempQr,NumberOfPoints, LogBinParam)
	wave TempInt,TempQ,TempE, TempQr
	variable NumberOfPoints, LogBinParam

	string OldDf
	OldDf = GetDataFOlder(1)
	NewDataFolder/O/S root:packages
	NewDataFolder/O/S root:packages:TempDataRebin
	
	//Log rebinning, if requested.... 
	//create log distribution of points...
	make/O/D/FREE/N=(NumberOfPoints) tempNewLogDist, tempNewLogDistBinWidth
	make/O/D/FREE/N=(NumberOfPoints) Rebinned_TempQ, Rebinned_tempInt, Rebinned_TempErr
	tempNewLogDist = exp((0.8*LogBinParam/100) * p)
	variable tempLogDistRange = tempNewLogDist[numpnts(tempNewLogDist)-1] - tempNewLogDist[0]
	tempNewLogDist =((tempNewLogDist-1)/tempLogDistRange)
	variable StartQ, EndQ
	startQ=TempQ[0]
	endQ=TempQ[numpnts(TempQ)-1]
	tempNewLogDist = startQ + (tempNewLogDist[p])*((endQ-startQ))
	tempNewLogDistBinWidth = tempNewLogDist[p+1] - tempNewLogDist[p]
	tempNewLogDistBinWidth[numpnts(tempNewLogDistBinWidth)-1] = tempNewLogDistBinWidth[numpnts(tempNewLogDistBinWidth)-2]
	Rebinned_tempInt=0
	Rebinned_TempErr=0	
	variable i, j	//, startIntg=TempQ[1]-TempQ[0]
	//first assume that we can step through this easily...
	variable cntPoints, BinHighEdge
	//variable i will be from 0 to number of new points, moving through destination waves
	j=0		//this variable goes through data to be reduced, therefore it goes from 0 to numpnts(TempInt)
	For(i=0;i<NumberOfPoints;i+=1)
		cntPoints=0
		BinHighEdge = tempNewLogDist[i]+tempNewLogDistBinWidth[i]/2
		Do
			Rebinned_tempInt[i]+=TempInt[j]
			Rebinned_TempErr[i]+=TempE[j]
			Rebinned_TempQ[i] += TempQ[j]
			cntPoints+=1
		j+=1
		While(TempQ[j]<BinHighEdge && j<numpnts(TempInt))
		Rebinned_tempInt[i]/=	cntPoints
		Rebinned_TempErr[i]/=cntPoints
		Rebinned_TempQ[i]/=cntPoints
	endfor
	
	Rebinned_TempQ = (Rebinned_TempQ[p]>0) ? Rebinned_TempQ[p] : NaN
	//Rebinned_TempQ[numpnts(Rebinned_TempQ)-1]=NaN
	
	IN2G_RemoveNaNsFrom3Waves(Rebinned_tempInt,Rebinned_TempErr,Rebinned_TempQ)

	
	Redimension/N=(numpnts(Rebinned_tempInt))/D TempInt,TempQ,TempE, TempQr
	TempInt=Rebinned_tempInt
	TempQ=Rebinned_TempQ
	TempE=Rebinned_TempErr
	//temp Qr has changed, it now is represented by Q lmits of the new Q wave
	
	TempQr = (TempQ[p]-TempQ[p-1])/2 + (TempQ[p+1] - TempQ[p])/2
	TempQr[0] = TempQ[1]-TempQ[0]
	TempQr[numpnts(TempQ)-1] = TempQ[numpnts(TempQ)-1] - TempQ[numpnts(TempQ)-2]

	setDataFolder OldDF
	KillDataFolder/Z root:packages:TempDataRebin
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_CheckForProperNewFolder()

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

	string OldDF=GetDataFolder(1)
	setdataFolder root:Packages:ImportData

	SVAR DataPathName=root:Packages:ImportData:DataPathName
	SVAR NewDataFolderName=root:Packages:ImportData:NewDataFolderName
	SVAR NewIntensityWaveName=root:Packages:ImportData:NewIntensityWaveName
	SVAR NewQWaveName=root:Packages:ImportData:NewQWaveName
	SVAR NewErrorWaveName=root:Packages:ImportData:NewErrorWaveName	
	SVAR NewQErrorWaveName=root:Packages:ImportData:NewQErrorWaveName	
	string NewFldrNm,NewIntName, NewQName, NewEName, NewQEName, tempFirstPart, tempLastPart
	NVAR TrunkateStart=root:Packages:ImportData:TrunkateStart	
	NVAR TrunkateEnd=root:Packages:ImportData:TrunkateEnd	
	
	if(stringMatch(NewDataFolderName,"*<fileName>*")==0)
		NewFldrNm = CleanupName(NewDataFolderName, 1 )
		NewFldrNm=IR1I_TrunkateName(NewFldrNm,TrunkateStart,TrunkateEnd)
	else
		TempFirstPart = NewDataFolderName[0,strsearch(NewDataFolderName, "<fileName>", 0 )-1]
		tempLastPart  = NewDataFolderName[strsearch(NewDataFolderName, "<fileName>", 0 )+10,inf]
		NewFldrNm = TempFirstPart+CleanupName(IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd), 1 )+tempLastPart
	endif
	if(stringMatch(NewIntensityWaveName,"*<fileName>*")==0)
		NewIntName = CleanupName(NewIntensityWaveName, 1 )
		NewIntName = IR1I_TrunkateName(NewIntensityWaveName,TrunkateStart,TrunkateEnd)
	else
		TempFirstPart = NewIntensityWaveName[0,strsearch(NewIntensityWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewIntensityWaveName[strsearch(NewIntensityWaveName, "<fileName>", 0 )+10,inf]
		NewIntName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd)+tempLastPart
		NewIntName = CleanupName(NewIntName, 1 )
	endif
	if(stringMatch(NewQwaveName,"*<fileName>*")==0)
		NewQName = CleanupName(NewQwaveName, 1 )
		NewQName = IR1I_TrunkateName(NewQwaveName,TrunkateStart,TrunkateEnd)
	else
		TempFirstPart = NewQwaveName[0,strsearch(NewQwaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewQwaveName[strsearch(NewQwaveName, "<fileName>", 0 )+10,inf]
		NewQName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd)+tempLastPart
		NewQName = CleanupName(NewQName, 1 )
	endif
	if(stringMatch(NewErrorWaveName,"*<fileName>*")==0)
		NewEName = CleanupName(NewErrorWaveName, 1 )
		NewEName = IR1I_TrunkateName(NewErrorWaveName,TrunkateStart,TrunkateEnd)
	else
		TempFirstPart = NewErrorWaveName[0,strsearch(NewErrorWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewErrorWaveName[strsearch(NewErrorWaveName, "<fileName>", 0 )+10,inf]
		NewEName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd)+tempLastPart
		NewEName = CleanupName(NewEName, 1 )
	endif
	if(stringMatch(NewQErrorWaveName,"*<fileName>*")==0)
		NewQEName = CleanupName(NewQErrorWaveName, 1 )
		NewQEName=IR1I_TrunkateName(NewQErrorWaveName,TrunkateStart,TrunkateEnd)
	else
		TempFirstPart = NewQErrorWaveName[0,strsearch(NewQErrorWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewQErrorWaveName[strsearch(NewQErrorWaveName, "<fileName>", 0 )+10,inf]
		NewQEName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd)+tempLastPart
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
Function/S IR1I_TrunkateName(InputName,TrunkateStart,TrunkateEnd)
	string InputName
	variable TrunkateStart,TrunkateEnd
	
	variable inpuLength=strlen(InputName)
	variable removePoints=inpuLength - IR1TrimNameLength
	string TempStr=InputName	
	if(removePoints>0)
		if(TrunkateEnd)
			tempStr=InputName[0,IR1TrimNameLength-1]
		elseif(TrunkateStart)
			tempStr=InputName[removePoints,inf]
		endif
	endif
	return cleanupName(tempStr,1)
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_NameImportedWaves(selectedFile)
	string selectedFile

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

	if(!SkipLines)			//lines automatically skipped, so the header may make sense, add to header...
	        Open/R/P=ImportDataPath refNum as selectedFile
		HeaderFromData=""
	        Variable j
 	       String text
  	      For(j=0;j<SkipNumberOfLines;j+=1)
   	             FReadLine refNum, text
 			HeaderFromData+=IN2G_ZapControlCodes(text)+";"
		endfor        
	      Close refNum
	endif	
	NVAR DataContainErrors=root:Packages:ImportData:DataContainErrors
	DataContainErrors=0
	For(i=0;i<FoundNWaves;i+=1)	
		NVAR testIntStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"Int")
		NVAR testQvecStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"Qvec")
		NVAR testErrStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"Err")
		NVAR testQErrStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"QErr")
		Wave/Z CurrentWave = $("wave"+num2str(i))
		SVAR DataPathName=root:Packages:ImportData:DataPathName
		if (testIntStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempIntensity
			//print "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData
			note/NOCR TempIntensity, "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData
			//print note(TempIntensity)
			numOfInts+=1
		endif
		if (testQvecStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempQvector
			note/NOCR TempQvector, "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData
			numOfQs+=1
		endif
		if (testErrStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempError
			note/NOCR TempError, "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData
			numOfErrs+=1
			DataContainErrors=1
		endif
		if (testQErrStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempQError
			note TempQError, "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData
			numOfQErrs+=1
		endif
		if(!WaveExists(CurrentWave))
			string Messg="Error, the column of data selected did not exist in the data file. The missing column is : "
			if(testIntStr)
				Messg+="Intensity"
			elseif(testQvecStr)
				Messg+="Q vector"
			elseif(testErrStr)
				Messg+="Error"
			elseif(testQErrStr)
				Messg+="Q Error"
			endif
			DoAlert 0, Messg 
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
			//note/NOCR TempIntensity, "Q error converted from nm to A-1;"
			//note/NOCR TempError, "Q error converted from nm to A-1;"
		endif
	endif
	if (ScaleImportedData)
		TempIntensity=TempIntensity*ScaleImportedDataBy		//scales imported data for user
		note/NOCR TempIntensity, "Data scaled by="+num2str(ScaleImportedDataBy)+";"
		//note/NOCR TempQError, "Data scaled by="+num2str(ScaleImportedDataBy)+";"
		if (WaveExists(TempError))
			TempError=TempError*ScaleImportedDataBy		//scales imported data for user
			note/NOCR TempError, "Data scaled by="+num2str(ScaleImportedDataBy)+";"
		endif
	endif
	//lets insert here thre Units intot he wave notes...
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
	//let's celan up the data from negative Qs, if there are any...
	//data are in  		TempQvector, TempIntensity, TempError
	//w = w[p]==0 ? NaN : w[p]
	TempQvector = TempQvector[p]<0 ?  NaN :  TempQvector[p]
	NVAR RemoveNegativeIntensities = root:packages:ImportData:RemoveNegativeIntensities
	if(RemoveNegativeIntensities)
		TempIntensity = TempIntensity[p]<0 ?  NaN :  TempIntensity[p]	
	endif

	if(WaveExists(TempError)&&WaveExists(TempQError))	//have 4 waves
		IN2G_RemoveNaNsFrom4Waves(TempQvector, TempIntensity, TempError,TempQError)
	elseif(WaveExists(TempError)&&!WaveExists(TempQError))	//have 3 waves
		IN2G_RemoveNaNsFrom3Waves(TempQvector, TempIntensity, TempError)
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
		else	//only 2 waves 
			IN2G_RemoveNaNsFrom2Waves(TempQvector, TempIntensity)
		endif
	endif	
	//here rebind the data down....
	NVAR ReduceNumPnts= root:packages:ImportData:ReduceNumPnts
	NVAR TargetNumberOfPoints= root:packages:ImportData:TargetNumberOfPoints
	if(ReduceNumPnts)
	
		if(WaveExists(TempError)&&WaveExists(TempQError))	//have 4 waves
			IR1I_ImportRebinData(TempIntensity,TempQvector,TempError,TempQError,TargetNumberOfPoints, 3)
		elseif(WaveExists(TempError)&&!WaveExists(TempQError))	//have 3 waves
			Duplicate/O TempError, TempQError
			IR1I_ImportRebinData(TempIntensity,TempQvector,TempError,TempQError,TargetNumberOfPoints, 3)
		else	//only 2 waves 
			Duplicate/O TempIntensity, TempError, TempQError
			IR1I_ImportRebinData(TempIntensity,TempQvector,TempError,TempQError,TargetNumberOfPoints, 3)
			KillWaves TempError, TempQError
		endif
	endif
	
	

	SVAR NewIntensityWaveName= root:packages:ImportData:NewIntensityWaveName
	SVAR NewQwaveName= root:packages:ImportData:NewQWaveName
	SVAR NewErrorWaveName= root:packages:ImportData:NewErrorWaveName
	SVAR NewQErrorWaveName= root:packages:ImportData:NewQErrorWaveName
	NVAR IncludeExtensionInName=root:packages:ImportData:IncludeExtensionInName
	string NewIntName, NewQName, NewEName, NewQEName, tempFirstPart, tempLastPart
	
	if(stringMatch(NewIntensityWaveName,"*<fileName>*")==0)
		NewIntName = IR1I_RemoveBadCharacters(NewIntName)
		NewIntName = CleanupName(NewIntensityWaveName, 1 )
		NewIntName=IR1I_TrunkateName(NewIntName,TrunkateStart,TrunkateEnd)
	else
		TempFirstPart = NewIntensityWaveName[0,strsearch(NewIntensityWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewIntensityWaveName[strsearch(NewIntensityWaveName, "<fileName>", 0 )+10,inf]
		if(IncludeExtensionInName)
			NewIntName = TempFirstPart+IR1I_TrunkateName(selectedFile,TrunkateStart,TrunkateEnd)+tempLastPart
		else
			NewIntName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd)+tempLastPart
		endif
		NewIntName = IR1I_RemoveBadCharacters(NewIntName)
		NewIntName = CleanupName(NewIntName, 1 )
	endif
	if(stringMatch(NewQwaveName,"*<fileName>*")==0)
		NewQName =IR1I_RemoveBadCharacters(NewQName)
		NewQName = CleanupName(NewQwaveName, 1 )
		NewQName=IR1I_TrunkateName(NewQName,TrunkateStart,TrunkateEnd)
	else
		TempFirstPart = NewQwaveName[0,strsearch(NewQwaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewQwaveName[strsearch(NewQwaveName, "<fileName>", 0 )+10,inf]
		if(IncludeExtensionInName)
			NewQName = TempFirstPart+IR1I_TrunkateName(selectedFile,TrunkateStart,TrunkateEnd)+tempLastPart
		else
			NewQName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd)+tempLastPart
		endif
		NewQName =IR1I_RemoveBadCharacters(NewQName)
		NewQName = CleanupName(NewQName, 1 )
	endif
	if(stringMatch(NewErrorWaveName,"*<fileName>*")==0)
		NewEName =IR1I_RemoveBadCharacters(NewEName)
		NewEName = CleanupName(NewErrorWaveName, 1 )
		NewEName=IR1I_TrunkateName(NewEName,TrunkateStart,TrunkateEnd)
	else
		TempFirstPart = NewErrorWaveName[0,strsearch(NewErrorWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewErrorWaveName[strsearch(NewErrorWaveName, "<fileName>", 0 )+10,inf]
		if(IncludeExtensionInName)
			NewEName = TempFirstPart+IR1I_TrunkateName(selectedFile,TrunkateStart,TrunkateEnd)+tempLastPart
		else
			NewEName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd)+tempLastPart
		endif
		NewEName =IR1I_RemoveBadCharacters(NewEName)
		NewEName = CleanupName(NewEName, 1 )
	endif
	if(stringMatch(NewQErrorWaveName,"*<fileName>*")==0)
		NewQEName =IR1I_RemoveBadCharacters(NewQEName)
		NewQEName = CleanupName(NewQErrorWaveName, 1 )
		NewQEName=IR1I_TrunkateName(NewQEName,TrunkateStart,TrunkateEnd)
	else
		TempFirstPart = NewQErrorWaveName[0,strsearch(NewQErrorWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewQErrorWaveName[strsearch(NewQErrorWaveName, "<fileName>", 0 )+10,inf]
		if(IncludeExtensionInName)
			NewQEName = TempFirstPart+IR1I_TrunkateName(selectedFile,TrunkateStart,TrunkateEnd)+tempLastPart
		else
			NewQEName = TempFirstPart+IR1I_TrunkateName(StringFromList(0,selectedFile,"."),TrunkateStart,TrunkateEnd)+tempLastPart
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

//	NVAR UseFileNameAsFolder = root:Packages:ImportData:UseFileNameAsFolder
//	NVAR UseIndra2Names = root:Packages:ImportData:UseIndra2Names
//	NVAR UseQRSNames = root:Packages:ImportData:UseQRSNames
//
//	SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
//	SVAR NewIntensityWaveName= root:packages:ImportData:NewIntensityWaveName
//	SVAR NewQwaveName= root:packages:ImportData:NewQWaveName
//	SVAR NewErrorWaveName= root:packages:ImportData:NewErrorWaveName

	IR1I_KillAutoWaves()
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function/S IR1I_RemoveBadCharacters(StringName)
	string StringName
	
	//here we can clean up waht Igor allows but would be major problem with my code, such as ( or ) from names
	make/Free/T/N=0 ListOfBadChars
	ListOfBadChars = {"(", ")", "{","}","%","&","$","#","@"}
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
		
	NVAR SkipNumberOfLines=root:Packages:ImportData:SkipNumberOfLines
	NVAR SkipLines=root:Packages:ImportData:SkipLines	
	IR1I_KillAutoWaves()
//	LoadWave/Q/A/G/P=ImportDataPath  selectedfile
	if (SkipLines)
		LoadWave/Q/A/G/L={0, SkipNumberOfLines, 0, 0, 0}/P=ImportDataPath  selectedfile
	else
		LoadWave/Q/A/G/P=ImportDataPath  selectedfile
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

	SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
	NVAR IncludeExtensionInName = root:packages:ImportData:IncludeExtensionInName
	NVAR TrunkateStart = root:packages:ImportData:TrunkateStart
	NVAR TrunkateEnd = root:packages:ImportData:TrunkateEnd
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
				selectedFile = stringFromList(0,selectedFile,".")
			endif
			selectedFile=IR1I_TrunkateName(selectedFile,TrunkateStart,TrunkateEnd)
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

	if (Cmpstr(ctrlName,"SelectFolderNewData")==0)
		SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
		NewDataFolderName = popStr
			NVAR UseFileNameAsFolder = root:Packages:ImportData:UseFileNameAsFolder
			if (UseFileNameAsFolder)
				NewDataFolderName+="<fileName>:"
			endif		
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
	
	if(cmpstr(ctrlName,"SelectDataPath")==0)
		IR1I_SelectDataPath()	
		IR1I_UpdateListOfFilesInWvs()
	endif
	if(cmpstr(ctrlName,"TestImport")==0)
		IR1I_testImport()
	endif
	if(cmpstr(ctrlName,"Preview")==0)
		IR1I_TestImportNotebook()
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
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_SelectDeselectAll(SetNumber)
		variable setNumber
		
		Wave WaveOfSelections=root:Packages:ImportData:WaveOfSelections

		WaveOfSelections = SetNumber
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR1I_TestImport()
	
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
	
	if (SkipLines)
		LoadWave/Q/A/G/L={0, SkipNumberOfLines, 0, 0, 0}/P=ImportDataPath  selectedfile
		FoundNWaves = V_Flag
	else
		LoadWave/Q/A/G/P=ImportDataPath  selectedfile
		FoundNWaves = V_Flag
	endif
	wave wave0
	NumOfPointsFound=numpnts(wave0)
	if(NumOfPointsFound<300)
		sprintf TooManyPointsWarning, "Found %g data points",NumOfPointsFound
		TitleBox TooManyPointsWarning win=IR1I_ImportData ,fColor=(0,0,0), disable=0
	else
		sprintf TooManyPointsWarning, "%g data points, consider reduction ",NumOfPointsFound
		TitleBox TooManyPointsWarning win=IR1I_ImportData ,fColor=(65200,0,0), disable=0
	endif
	//now fix the checkboxes as needed
	IR1I_FIxCheckboxesForWaveTypes()
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR1I_TestImportNotebook()

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
	DOwindow FilePreview
	if (V_Flag)
		DoWindow/K FilePreview
	endif
	OpenNotebook /K=1 /N=FilePreview /P=ImportDataPath /R /V=1 selectedfile
	MoveWindow /W=FilePreview 450, 5, 1000, 400	
	AutoPositionWindow/M=0 /R=IR1I_ImportData FilePreview
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_FIxCheckboxesForWaveTypes()

	NVAR FoundNWaves = root:Packages:ImportData:FoundNWaves
	variable maxWaves, i
	maxWaves = FoundNWaves
	if (MaxWaves>6)
		MaxWaves = 6
	endif

	For (i=1;i<=MaxWaves;i+=1)
		CheckBox $("Col"+num2str(i)+"Int") disable=0, win=IR1I_ImportData
		CheckBox $("Col"+num2str(i)+"Qvec") disable=0, win=IR1I_ImportData
		CheckBox $("Col"+num2str(i)+"Error") disable=0, win=IR1I_ImportData
		CheckBox $("Col"+num2str(i)+"QError") disable=0, win=IR1I_ImportData
	endfor
	For (i=FoundNWaves+1;i<=6;i+=1)
		CheckBox $("Col"+num2str(i)+"Int") disable=1, win=IR1I_ImportData
		CheckBox $("Col"+num2str(i)+"Qvec") disable=1, win=IR1I_ImportData
		CheckBox $("Col"+num2str(i)+"Error") disable=1, win=IR1I_ImportData
		CheckBox $("Col"+num2str(i)+"QError") disable=1, win=IR1I_ImportData
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
	
	SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
	SVAR NewIntensityWaveName= root:packages:ImportData:NewIntensityWaveName
	SVAR NewQwaveName= root:packages:ImportData:NewQWaveName
	SVAR NewErrorWaveName= root:packages:ImportData:NewErrorWaveName
	SVAR NewQErrorWaveName= root:packages:ImportData:NewQErrorWaveName

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
		NVAR ImportSMRdata=root:Packages:ImportData:ImportSMRdata
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
			else
				NewDataFolderName = "root:USAXS:ImportedData:<fileName>:"	
				NewIntensityWaveName= "DSM_Int"
				NewQwaveName= "DSM_Qvec"
				NewErrorWaveName= "DSM_Error"
			endif
		endif
	endif

	if(cmpstr(ctrlName,"ImportSMRdata")==0)
		NVAR UseIndra2Names=root:Packages:ImportData:UseIndra2Names
		if(checked)
			UseFileNameAsFolder = 1
			UseQRSNames = 0
			UseQISNames = 0
			//UseIndra2Names = 0
			if (UseIndra2Names)
				NewDataFolderName = "root:USAXS:ImportedData:<fileName>:"	
				NewIntensityWaveName= "SMR_Int"
				NewQwaveName= "SMR_Qvec"
				NewErrorWaveName= "SMR_Error"
			endif
		else
			if (UseIndra2Names)
				NewDataFolderName = "root:USAXS:ImportedData:<fileName>:"	
				NewIntensityWaveName= "DSM_Int"
				NewQwaveName= "DSM_Qvec"
				NewErrorWaveName= "DSM_Error"
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
				SetVariable TrimDataQMin, win=IR1I_ImportData, disable=!(checked)
				SetVariable TrimDataQMax, win=IR1I_ImportData, disable=!(checked)
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

	if (Col1Err || Col2Err || Col3Err || Col4Err || Col5Err || Col6Err)
		CheckBox CreateSQRTErrors, disable=1, win=IR1I_ImportData
		CheckBox CreatePercentErrors, disable=1, win=IR1I_ImportData
		CreateSQRTErrors=0
		CreatePercentErrors=0
		SetVariable PercentErrorsToUse, disable=1
	else
		CheckBox CreateSQRTErrors, disable=0, win=IR1I_ImportData
		CheckBox CreatePercentErrors, disable=0, win=IR1I_ImportData
		SetVariable PercentErrorsToUse, disable=!(CreatePercentErrors)
	endif
	
	if(Col6QErr || Col5QErr || Col4QErr || Col3QErr || Col2QErr || Col1QErr)
		SetVariable NewQErrorWaveName, disable = 0 
	else	
		SetVariable NewQErrorWaveName, disable = 1
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
			SetVariable ReducePntsParam, disable=0	
		else
			SetVariable TargetNumberOfPoints, disable=1
			SetVariable ReducePntsParam, disable=1
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
		ListOfAllFiles = RemoveFromList(".DS_Store", ListOfAllFiles)
		ListOfAllFiles = RemoveFromList("EagleFiler Metadata.plist", ListOfAllFiles)
	
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
	
	string OldDf = GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:ImportData
	
	string ListOfStrings
	string ListOfVariables
	variable i
	
	ListOfStrings = "DataPathName;DataExtension;IntName;QvecName;ErrorName;NewDataFolderName;NewIntensityWaveName;"
	ListOfStrings+="NewQWaveName;NewErrorWaveName;NewQErrorWavename;NameMatchString;TooManyPointsWarning;"
	ListOfVariables = "UseFileNameAsFolder;UseIndra2Names;UseQRSNames;DataContainErrors;UseQISNames;"
	ListOfVariables += "CreateSQRTErrors;Col1Int;Col1Qvec;Col1Err;Col1QErr;FoundNWaves;"	
	ListOfVariables += "Col2Int;Col2Qvec;Col2Err;Col2QErr;Col3Int;Col3Qvec;Col3Err;Col3QErr;Col4Int;Col4Qvec;Col4Err;Col4QErr;"	
	ListOfVariables += "Col5Int;Col5Qvec;Col5Err;Col5QErr;Col6Int;Col6Qvec;Col6Err;Col6QErr;Col7Int;Col7Qvec;Col7Err;Col7QErr;"	
	ListOfVariables += "QvectInA;QvectInNM;CreateSQRTErrors;CreatePercentErrors;PercentErrorsToUse;"
	ListOfVariables += "ScaleImportedData;ScaleImportedDataBy;ImportSMRdata;SkipLines;SkipNumberOfLines;"	
	ListOfVariables += "IncludeExtensionInName;RemoveNegativeIntensities;AutomaticallyOverwrite;"	
	ListOfVariables += "TrimData;TrimDataQMin;TrimDataQMax;ReduceNumPnts;TargetNumberOfPoints;ReducePntsParam;"	
	ListOfVariables += "NumOfPointsFound;TrunkateStart;TrunkateEnd;"	
	ListOfVariables += "DataCalibratedArbitrary;DataCalibratedVolume;DataCalibratedWeight;"	

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

	//Set numbers to 0
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test=$(StringFromList(i,ListOfVariables))
		test =0
	endfor		
	ListOfVariables = "QvectInA;PercentErrorsToUse;ScaleImportedDataBy;UseFileNameAsFolder;UseQRSNames;"	
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
	IR1I_UpdateListOfFilesInWvs()
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
