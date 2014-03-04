#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=0.19
Constant IN3_FlyImportVersionNumber=0.19


//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//0.19 fixed missing checkbox procedure and added first attempt to support xpcs data 
//0.18 modified for new file format (3/1/2014), version =1, use dead time from Pvs etc., moved raw folder in spec file FLy folder. 
//0.17  fixed for use of only 3 mcs channels (removed upd and I0 gains). 
//0.16 modified sorting of the h5 files in the GUI. 
//0.15 many changes, I0gain, new gain change masking method, use records from mca changes to create UPD_gain etc.  
// 0.11 added transmission handling
//version 0.1 developement of import functions and GUIs


//note, to run somthign just after hdf5 file import use function 
//		AfterFlyImportHook(RawFolderWithData)
//	parameter is string with hdf file location. 

//FlyScan data reduction
//this is for early data only, now this is in hdf file. 
Constant AmplifierRange1BlockTime=0.00
Constant AmplifierRange2BlockTime=0.00
Constant AmplifierRange3BlockTime=0.00
Constant AmplifierRange4BlockTime=0.00
Constant AmplifierRange5BlockTime=0.4




//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IN3_FlyScanMain()
	DoWindow IN3_FlyScanImportPanel
	if(V_Flag)
		DoWIndow/K IN3_FlyScanImportPanel
	endif
	IN3_FlyScanInitializeImport()
	IN3_FlyScanImportPanelFnct()
	ING2_AddScrollControl()
	IN3_UpdatePanelVersionNumber("IN3_FlyScanImportPanel", IN3_FlyImportVersionNumber)
	IN3_FSUpdateListOfFilesInWvs()
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IN3_FlyScanCheckVersion()	
	DoWindow IN3_FlyScanImportPanel
	if(V_Flag)
		if(!IN3_CheckPanelVersionNumber("IN3_FlyScanImportPanel", IN3_FlyImportVersionNumber))
			DoAlert /T="The Fly Scan Import panel was created by old version of Indra " 1, "FlyScan Import needs to be restarted to work properly. Restart now?"
			if(V_flag==1)
				Execute/P("IN3_FlyScanMain()")
			else		//at least reinitialize the variables so we avoid major crashes...
				IN3_FlyScanInitializeImport()
			endif
		endif
	endif
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IN3_FlyScanImportPanelFnct() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(49,49,412,535) as "USAXS FlyScan Import data"
	DoWindow/C IN3_FlyScanImportPanel
	TitleBox MainTitle,pos={40,5},size={360,24},title="Import USAXS Data "
	TitleBox MainTitle,font="Times New Roman",fSize=22,frame=0,fStyle=3
	TitleBox MainTitle,fColor=(0,0,52224),fixedSize=1
	TitleBox FakeLine1,pos={16,40},size={330,3},title=" ",labelBack=(0,0,52224)
	TitleBox FakeLine1,frame=0,fColor=(0,0,52224),fixedSize=1
	TitleBox Info1,pos={11,112},size={120,20},title="List of available files :"
	TitleBox Info1,fSize=12,frame=0,fStyle=1,fColor=(0,0,52224),fixedSize=1
	Button SelectDataPath,pos={35,53},size={130,20}, proc=IN3_FlyScanButtonProc,title="Select data path"
	Button SelectDataPath,help={"Select data path to the data"}
	Button RefreshHDF5Data,pos={220,53},size={90,20}, proc=IN3_FlyScanButtonProc,title="Refresh"
	Button RefreshHDF5Data,help={"Refresh data in Listbox"}
	SetVariable DataPathString,pos={6,83},size={348,15},title="Data path :"
	SetVariable DataPathString,help={"This is currently selected data path where Igor looks for the data"}
	SetVariable DataPathString,limits={-inf,inf,0},value= root:Packages:USAXS_FlyScanImport:DataPathString,noedit= 1
	SetVariable DataExtensionString,pos={202,107},size={150,15},proc=IN3_FlyScanSetVarProc,title="Data extension:"
	SetVariable DataExtensionString,help={"Insert extension string to mask data of only some type (dat, txt, ...)"}
	SetVariable DataExtensionString,value= root:Packages:USAXS_FlyScanImport:DataExtension
	ListBox ListOfAvailableData,pos={9,133},size={320,232},proc=IN3_FlyScanImportListBoxProc
	ListBox ListOfAvailableData,help={"Select files from this location you want to import"}
	ListBox ListOfAvailableData,listWave=root:Packages:USAXS_FlyScanImport:WaveOfFiles
	ListBox ListOfAvailableData,selWave=root:Packages:USAXS_FlyScanImport:WaveOfSelections
	ListBox ListOfAvailableData,mode= 9
	SetVariable NameMatchString,pos={10,370},size={180,15},proc=IN3_FlyScanSetVarProc,title="Match name (string):"
	SetVariable NameMatchString,help={"Insert name match string to display only some data"}
	SetVariable NameMatchString,value= root:Packages:USAXS_FlyScanImport:NameMatchString
	CheckBox LatestOnTopInPanel,pos={240,370},size={16,14},proc=IN3_FlyCheckProc,title="Latest on top?",variable= root:Packages:USAXS_FlyScanImport:LatestOnTopInPanel, help={"Check to display latest files at the top"}
	CheckBox ReduceXPCSdata,pos={240,390},size={16,14},proc=IN3_FlyCheckProc,title="Reduce XPCS data?",variable= root:Packages:USAXS_FlyScanImport:ReduceXPCSdata, help={"Check to redeuce XPCS not USAXS data"}

	Button SelectAll,pos={7,395},size={100,20},proc=IN3_FlyScanButtonProc,title="Select All"
	Button SelectAll,help={"Select all waves in the list"}
	Button DeSelectAll,pos={120,395},size={100,20},proc=IN3_FlyScanButtonProc,title="Deselect All"
	Button DeSelectAll,help={"Deselect all waves in the list"}
	Button OpenFileInBrowser,pos={7,440},size={100,30},proc=IN3_FlyScanButtonProc,title="Open in Browser"
	Button OpenFileInBrowser,help={"Check file in HDF5 Browser"}
	Button ImportData,pos={120,440},size={100,30},proc=IN3_FlyScanButtonProc,title="Import"
	Button ImportData,help={"Import the selected data files."}
	Button ConfigureBehavior,pos={240,440},size={100,20},proc=IN3_FlyScanButtonProc,title="Configure"
	Button ConfigureBehavior,help={"Import the selected data files."}



//	Button Preview,pos={300,152},size={80,15}, proc=IR1I_ButtonProc,title="Preview"
//	Button Preview,help={"Preview selected file."}

//	TitleBox TooManyPointsWarning variable=root:Packages:ImportData:TooManyPointsWarning,fColor=(0,0,0)
//	TitleBox TooManyPointsWarning pos={220,170},size={150,19}, disable=1
	
//	CheckBox ReduceNumPnts,pos={10,507},size={16,14},proc=IR1I_CheckProc,title="Reduce points?",variable= root:Packages:ImportData:ReduceNumPnts, help={"Check to log-reduce number of points"}
//	SetVariable TargetNumberOfPoints, pos={110,505}, size={110,20},title="Num points=", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:ReduceNumPnts)
//	SetVariable TargetNumberOfPoints limits={10,1000,0},value= root:packages:ImportData:TargetNumberOfPoints,help={"Target number of points after reduction. Uses same method as Data manipualtion I"}
//
////	PopupMenu SelectFolderNewData,pos={1,525},size={250,21},proc=IR1I_PopMenuProc,title="Select data folder", help={"Select folder with data"}
////	PopupMenu SelectFolderNewData,mode=1,popvalue="---",value= #"\"---;\"+IR1_GenStringOfFolders(0, 0,0,0)"

EndMacro

//************************************************************************************************************
//************************************************************************************************************
Function IN3_FlyCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(stringmatch(cba.ctrlName,"LatestOnTopInPanel"))
				IN3_FSUpdateListOfFilesInWvs()
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************
//************************************************************************************************************

Function IN3_FlyScanSelectDataPath()

	NewPath /M="Select path to data to be imported" /O USAXSHDFPath
	if (V_Flag!=0)
		abort
	endif 
	PathInfo USAXSHDFPath
	SVAR DataPathString=root:Packages:USAXS_FlyScanImport:DataPathString
	DataPathString = S_Path
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IN3_FSUpdateListOfFilesInWvs()

	SVAR DataPathName = root:Packages:USAXS_FlyScanImport:DataPathString
	SVAR DataExtension  = root:Packages:USAXS_FlyScanImport:DataExtension
	SVAR NameMatchString = root:Packages:USAXS_FlyScanImport:NameMatchString
	NVAR LatestOnTopInPanel = root:Packages:USAXS_FlyScanImport:LatestOnTopInPanel
	
	Wave/T WaveOfFiles      = root:Packages:USAXS_FlyScanImport:WaveOfFiles
	Wave WaveOfSelections = root:Packages:USAXS_FlyScanImport:WaveOfSelections
	string ListOfAllFiles
	string LocalDataExtension
	variable i, imax
	LocalDataExtension = DataExtension
	if (cmpstr(LocalDataExtension[0],".")!=0)
		LocalDataExtension = "."+LocalDataExtension
	endif
	PathInfo USAXSHDFPath
	if(V_Flag && strlen(DataPathName)>0)
		if (strlen(LocalDataExtension)<=1)
			ListOfAllFiles = IndexedFile(USAXSHDFPath,-1,"????")
		else		
			ListOfAllFiles = IndexedFile(USAXSHDFPath,-1,LocalDataExtension)
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
		Duplicate/Free WaveOfSelections, TmpSortWv
		for (i=0;i<imax;i+=1)
			WaveOfFiles[i] = stringFromList(i, ListOfAllFiles,";")
		endfor
		For(i=0;i<numpnts(TmpSortWv);i+=1)
			TmpSortWv[i] = str2num(StringFromList(0, WaveOfFiles[i] , "_")[1,inf])
		endfor
		if(LatestOnTopInPanel)
			Sort/R TmpSortWv, WaveOfFiles
		else
			Sort TmpSortWv, WaveOfFiles
		endif
	else
		Redimension/N=0 WaveOfSelections
		Redimension/N=0 WaveOfFiles
	endif 
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IN3_FSSelectDeselectAll(SetNumber)
		variable setNumber
		
		Wave WaveOfSelections=root:Packages:USAXS_FlyScanImport:WaveOfSelections

		WaveOfSelections = SetNumber
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IN3_FlyScanOpenHdf5File()
	
	Wave/T WaveOfFiles      = root:Packages:USAXS_FlyScanImport:WaveOfFiles
	Wave WaveOfSelections = root:Packages:USAXS_FlyScanImport:WaveOfSelections
	
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
			CreateNewHDF5Browser()
		 	browserName = WinName(0, 64)
			HDF5OpenFile/R /P=USAXSHDFPath locFileID as FileName
			if (V_flag == 0)					// Open OK?
				HDf5Browser#UpdateAfterFileCreateOrOpen(0, browserName, locFileID, S_path, S_fileName)
			endif
			if(!OpenMultipleFiles)
				return 0
			endif
		endif
	endfor
	//HDf5Browser#LoadGroupButtonProc("LoadGroup")
	
	//HDf5Browser#CloseFileButtonProc("CloseFIle")
	
	//KillWindow $(browserName)
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IN3_FlyScanCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	NVAR DoubleClickImports=root:Packages:USAXS_FlyScanImport:DoubleClickImports
	NVAR DoubleClickOpensInBrowser=root:Packages:USAXS_FlyScanImport:DoubleClickOpensInBrowser


	if(cmpstr(ctrlName,"DoubleClickImports")==0)	
		DoubleClickImports = 1
		DoubleClickOpensInBrowser = 0
	endif
	if(cmpstr(ctrlName,"DoubleClickOpensInBrowser")==0)	
		DoubleClickImports = 0
		DoubleClickOpensInBrowser = 1
	endif
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IN3_FlyScanLoadHdf5File()
	
	string OldDf=getDataFolder(1)
	setDataFolder root:
	NewDataFolder/O root:raw
	SetDataFolder root:raw
	Wave/T WaveOfFiles      = root:Packages:USAXS_FlyScanImport:WaveOfFiles
	Wave WaveOfSelections = root:Packages:USAXS_FlyScanImport:WaveOfSelections
	SVAR DataExtension = root:Packages:USAXS_FlyScanImport:DataExtension
	NVAR ReduceXPCSdata = root:Packages:USAXS_FlyScanImport:ReduceXPCSdata
	
	variable NumSelFiles=sum(WaveOfSelections)	
	variable OpenMultipleFiles=0
	if(NumSelFiles==0)
		return 0
	endif	
	variable i, Overwrite
	string FileName, ListOfExistingFolders, tmpDtaFldr, shortNameBckp, TargetRawFoldername
	String browserName, shortFileName, RawFolderWithData, SpecFileName, RawFolderWithFldr
	Variable locFileID
	For(i=0;i<numpnts(WaveOfSelections);i+=1)
		if(WaveOfSelections[i])
			FileName= WaveOfFiles[i]
			shortFileName = ReplaceString("."+DataExtension, FileName, "")
			//check if such data exist already...
			ListOfExistingFolders = DataFolderDir(1)
			if(StringMatch(ListOfExistingFolders, "*"+shortFileName+"*" ))
				DoAlert /T="Non unique name alert..." 1, "Raw folder with "+shortFileName+" name already found, Overwrite?" 
				if(V_Flag==3)
					return 0
				endif	
			endif
			CreateNewHDF5Browser()
		 	browserName = WinName(0, 64)
		 	DoWindow/Hide=1 browserName
			HDF5OpenFile/R /P=USAXSHDFPath locFileID as FileName
			if (V_flag == 0)					// Open OK?
				HDf5Browser#UpdateAfterFileCreateOrOpen(0, browserName, locFileID, S_path, S_fileName)
			
				HDf5Browser#LoadGroupButtonProc("LoadGroup")
				
				if(!ReduceXPCSdata)			//this is valid only for USAXS fly scan data, not for XPCS. 
					KillWaves/Z Config_Version
					HDF5LoadData /A="config_version"/Q  /Type=2 locFileID , "/entry/program_name" 
					Wave/T Config_Version
				endif
				HDf5Browser#CloseFileButtonProc("CloseFIle")
	
				KillWindow $(browserName)
				RawFolderWithData = GetDataFOlder(1)+shortFileName
				RawFolderWithFldr = GetDataFolder(1)
				if(!ReduceXPCSdata)			//this is valid only for USAXS fly scan data, not for XPCS. 
					variable/g $(RawFolderWithData+":HdfWriterVersion")
					NVAR HdfWriterVersion = $(RawFolderWithData+":HdfWriterVersion")
					HdfWriterVersion = str2num(Config_Version[0])
					KillWaves/Z Config_Version					
					Wave/T SpecFileNameWv=$(RawFolderWithData+":entry:metadata:SPEC_data_file")
					SpecFileName=SpecFileNameWv[0]
					SpecFileName=stringFromList(0,SpecFileName,".")
					TargetRawFoldername = SpecFileName+"_Fly"
				else
					TargetRawFoldername = "Mythen_data"
				endif
				NewDataFolder/O $(TargetRawFoldername)
				if(DataFolderExists(":"+possiblyquoteName(TargetRawFoldername)+":"+shortFileName))
					DoAlert /T="Folder name conflict" 1, "Folder : "+shortFileName+" already exists, overwrite (Yes) it or create unique name (No)?"
					if(V_Flag==1)
						KillDataFolder  $(":"+possiblyquoteName(TargetRawFoldername)+":"+shortFileName)
					elseif(V_Flag==2)
						tmpDtaFldr = GetDataFolder(1)
						setDataFolder (SpecFileName+"_Fly")
						shortNameBckp = shortFileName
						shortFileName = UniqueName(shortFileName, 11, 0 )
					      setDataFolder tmpDtaFldr
					      RenameDataFolder $(shortNameBckp), $(shortFileName)
					endif
				endif
				MoveDataFolder $(shortFileName), $(":"+possiblyquoteName(TargetRawFoldername))
				
				RawFolderWithData = RawFolderWithFldr+possiblyquoteName(TargetRawFoldername)+":"+shortFileName
				print "Imported HDF5 file : "+RawFolderWithData
#if(exists("AfterFlyImportHook")==6)
			AfterFlyImportHook(RawFolderWithData)
#endif	
				if(ReduceXPCSdata)
					print "here belongs XPCS data conversion routine in the future" 
					print "IN3_FlyScanLoadHdf5File()"
				else
					IN3_FSConvertToUSAXS(RawFolderWithData)	
					print "Converted : "+RawFolderWithData+" into USAXS data"
				endif
			else
				DoAlert 0, "Could not open "+FileName
			endif

		endif
	endfor
	setDataFolder OldDf
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function/T IN3_FSConvertToUSAXS(RawFolderWithData)
	string RawFolderWithData
	
	string OldDf=GetDataFolder(1)
	setDataFolder RawFolderWithData
	//here we need to deal with hdf5 data
	//spec file name
	string SpecFileName
	Wave/T SpecFileNameWv=:entry:metadata:SPEC_data_file
	SpecFileName=SpecFileNameWv[0]
	SpecFileName=stringFromList(0,SpecFileName,".")
	NVAR HdfWriterVersion = HdfWriterVersion
	//wave data to locate
	Wave TimeWv=:entry:flyScan:mca1
	Wave I0Wv=:entry:flyScan:mca2
	Wave updWv=:entry:flyScan:mca3
	Wave Ar_start=:entry:flyScan:AR_start
	Wave Ar_increment=:entry:flyScan:Ar_increment
	Wave updG1=:entry:metadata:upd_gain0
	Wave updG2=:entry:metadata:upd_gain1
	Wave updG3=:entry:metadata:upd_gain2
	Wave updG4=:entry:metadata:upd_gain3
	Wave updG5=:entry:metadata:upd_gain4	
	Wave updBkg1=:entry:metadata:upd_bkg0
	Wave updBkg2=:entry:metadata:upd_bkg1
	Wave updBkg3=:entry:metadata:upd_bkg2
	Wave updBkg4=:entry:metadata:upd_bkg3
	Wave updBkg5=:entry:metadata:upd_bkg4	
	Wave updBkgErr1=:entry:metadata:upd_bkg_err0
	Wave updBkgErr2=:entry:metadata:upd_bkgErr1
	Wave updBkgErr3=:entry:metadata:upd_bkgErr2
	Wave updBkgErr4=:entry:metadata:upd_bkgErr3
	Wave updBkgErr5=:entry:metadata:upd_bkgErr4	
	Wave/T SampleNameW=:entry:sample:name
	Wave SampleThicknessW = :entry:sample:thickness
	Wave DCM_energyW=:entry:instrument:monochromator:DCM_energy
	Wave SDDW=:entry:metadata:detector_distance
	Wave SADW=:entry:metadata:analyzer_distance
	Wave/T SpecSourceFilenameW=:entry:metadata:SPEC_data_file
	Wave I00GainW =:entry:metadata:I00AmpGain
	Wave I0GainW = :entry:metadata:I0AmpGain
	Wave/T TimeW=:entry:metadata:timeStamp
	Wave/Z USAXSPinT_I0Counts=:entry:metadata:trans_I0_counts
	Wave/Z USAXSPinT_I0Gain=:entry:metadata:trans_I0_gain
	Wave/Z USAXSPinT_AyPosition=:entry:metadata:trans_pin_aypos
	Wave/Z USAXSPinT_pinCounts=:entry:metadata:trans_pin_counts
	Wave/Z USAXSPinT_pinGain=:entry:metadata:trans_pin_gain
	Wave/Z USAXSPinT_Time= :entry:metadata:trans_pin_time

	//USAXSPinT_Measure=1;USAXSPinT_AyPosition=11.1725;USAXSPinT_Time=3;USAXSPinT_pinCounts=1918487;
	//USAXSPinT_pinGain=1000000;USAXSPinT_I0Counts=219754;USAXSPinT_I0Gain=10000000;
	make/Free/N=5 TimeRangeAfterUPD, TimeRangeAfterI0
	if(HdfWriterVersion<1)
		Wave mcsChangePnts = :entry:flyScan:changes_mcsChan
		Wave ampGain = :entry:flyScan:changes_ampGain
		Wave ampReqGain = :entry:flyScan:changes_ampReqGain
		TimeRangeAfterUPD = {AmplifierRange1BlockTime,AmplifierRange2BlockTime,AmplifierRange3BlockTime,AmplifierRange4BlockTime,AmplifierRange5BlockTime}
		TimeRangeAfterI0 = {0,0,0,0,0}
	elseif(HdfWriterVersion==1)
		Wave AmplifierUsed = :entry:flyScan:upd_flyScan_amplifier		//1 for DDPCA300, 0 for DLPCA200
		Wave DDPCA300_ampGain = :entry:flyScan:changes_DDPCA300_ampGain
		Wave DDPCA300_ampReqGain = :entry:flyScan:changes_DDPCA300_ampReqGain
		Wave DDPCA300_mcsChan = :entry:flyScan:changes_DDPCA300_mcsChan
		Wave DLPCA200_ampGain = :entry:flyScan:changes_DLPCA200_ampGain
		Wave DLPCA200_ampReqGain = :entry:flyScan:changes_DLPCA200_ampReqGain
		Wave DLPCA200_mcsChan = :entry:flyScan:changes_DLPCA200_mcsChan
		Wave I00_ampGain = :entry:flyScan:changes_I00_ampGain
		Wave I00_ampReqGain = :entry:flyScan:changes_I00_ampReqGain
		Wave I00_mcsChan = :entry:flyScan:changes_I00_mcsChan
		Wave I0_ampGain = :entry:flyScan:changes_I0_ampGain
		Wave I0_ampReqGain = :entry:flyScan:changes_I0_ampReqGain
		Wave I0_mcsChan = :entry:flyScan:changes_I0_mcsChan
		Wave mcaFrequency = :entry:flyScan:mca_clock_frequency
		Wave updMaskR1 = :entry:metadata:upd_amp_change_mask_time0
		Wave updMaskR2 = :entry:metadata:upd_amp_change_mask_time1
		Wave updMaskR3 = :entry:metadata:upd_amp_change_mask_time2
		Wave updMaskR4 = :entry:metadata:upd_amp_change_mask_time3
		Wave updMaskR5 = :entry:metadata:upd_amp_change_mask_time4
		TimeRangeAfterUPD = {updMaskR1[0],updMaskR2[0],updMaskR3[0],updMaskR4[0],updMaskR5[0]}
		TimeRangeAfterI0 = {0,0,0,0,0}
	endif
	//here we copy data to new place
	newDataFolder/O/S root:USAXS
	newDataFolder/O/S $(SpecFileName)
	string FileName, ListOfExistingFolders
	FileName=StringFromList(ItemsInList(RawFolderWithData ,":")-1, RawFolderWithData,  ":")
	ListOfExistingFolders = DataFolderDir(1)
		if(StringMatch(ListOfExistingFolders, "*,"+FileName+",*" ))
			DoAlert /T="Non unique name alert..." 1, "USAXS Folder with "+FileName+" name already found, Overwrite?" 
			if(V_Flag!=1)
				return ""
			endif	
		endif

 	newDataFolder/O/S $(FileName)
	Duplicate/O TimeWv, MeasTime
	Duplicate/O I0Wv, Monitor
	Duplicate/O updWv, USAXS_PD
	Duplicate/O TimeWv, PD_range
	Duplicate/O TimeWv, I0gain
	//create AR data
	Duplicate/Free TimeWv, ArValues
	Redimension /D ArValues
	ArValues = abs(Ar_increment[0])*p
	Duplicate/O ArValues, Ar_encoder	
	redimension/D MeasTime, Monitor, USAXS_PD
	//need to append the wave notes...
	string WaveNote
	WaveNote="DATAFILE="+SpecFileNameWv[0]+";DATE="+TimeW[0]+";COMMENT="+SampleNameW[0]+";SpecCommand="+"flyScan  ar 17.8217 17.8206 14.5895 2e-05  26.2812 "+num2str(SDDW[0])+" -0.1 "+num2str(SADW[0])+" "+num2str(SampleThicknessW[0])+" 100 1"
	WaveNote+=";SpecComment="+SampleNameW[0]+";"
	note/K MeasTime, WaveNote
	note/K Monitor, WaveNote
	note/K USAXS_PD, WaveNote
	note/K PD_range, WaveNote
	note/K Ar_encoder, WaveNote
	//create PD_range using records, not mca channel...
	if(HdfWriterVersion<1)
		MeasTime*=2e-08				//convert to seconds
		IN3_FSCreateGainWave(PD_range,ampReqGain,ampGain,mcsChangePnts, TimeRangeAfterUPD,MeasTime)
		I0gain = I0gainW[0]
	elseif(HdfWriterVersion==1)
		MeasTime/=mcaFrequency[0]		//convert to seconds
		if(AmplifierUsed)		//DDPCA300
			IN3_FSCreateGainWave(PD_range,DDPCA300_ampReqGain,DDPCA300_ampGain,DDPCA300_mcsChan, TimeRangeAfterUPD,MeasTime)
		else						//DLPCA200
			IN3_FSCreateGainWave(PD_range,DLPCA200_ampReqGain,DLPCA200_ampGain,DLPCA200_mcsChan, TimeRangeAfterUPD,MeasTime)
		endif
		IN3_FSCreateGainWave(I0gain,I0_ampReqGain,I0_ampGain,I0_mcsChan, TimeRangeAfterI0,MeasTime)
	
	endif
				//	variable ArOffset, scanningDown
				//	scanningDown = (Ar_encoder[0] > Ar_encoder[1]) ? 1 : 0
				//	if(scanningDown)	//scanning down in angle
				//		Ar_encoder = abs(Ar_encoder)
				//	else		//scanning up in angle
				//		Ar_encoder = abs(Ar_encoder)
				//	endif
	NVAR NumberOfTempPoints = root:Packages:USAXS_FlyScanImport:NumberOfTempPoints
	IN3_FlyScanRebinData(Ar_encoder, MeasTime, Monitor, USAXS_PD, PD_range, I0gain, NumberOfTempPoints, Ar_increment[0])
	IN2G_RemoveNaNsFrom6Waves(Ar_encoder, MeasTime, Monitor, USAXS_PD, PD_range, I0gain)
	
	//let's make some standard strings we need.
	string/g PathToRawData
	PathToRawData=RawFolderWithData
	string/g SpecCommand
	SpecCommand="flyScan  ar 17.8217 17.8206 14.5895 2e-05  26.2812 "+num2str(SDDW[0])+" -0.1 "+num2str(SADW[0])+" "+num2str(SampleThicknessW[0])+" 100 1"
	string/g SpecComment
	string/g SpecSourceFileName
	SpecSourceFileName=SpecSourceFilenameW[0]
	SpecComment = SampleNameW[0]
	string/g UPDParameters
	UPDParameters="Vfc=100000;Gain1="+num2str(updG1[0])+";Gain2="+num2str(updG2[0])+";Gain3="+num2str(updG3[0])+";Gain4="+num2str(updG4[0])+";Gain5="+num2str(updG5[0])
	UPDParameters+=";Bkg1="+num2str(updBkg1[0])+";Bkg2="+num2str(updBkg2[0])+";Bkg3="+num2str(updBkg3[0])+";Bkg4="+num2str(updBkg4[0])+";Bkg5="+num2str(updBkg5[0])
	UPDParameters+=";Bkg1Err="+num2str(updBkgErr1[0])+";Bkg2Err="+num2str(updBkgErr2[0])+";Bkg3Err="+num2str(updBkgErr3[0])+";Bkg4Err="+num2str(updBkgErr4[0])+";Bkg5Err="+num2str(updBkgErr5[0])
	UPDParameters+=";I0AmpDark=;I0AmpGain="+num2str(I0GainW[0])+";I00AmpGain="+num2str(I00GainW[0])+";"
	string/g MeasurementParameters
	MeasurementParameters="DCM_energy="+num2str(DCM_energyW[0])+";SAD="+num2str(SADW[0])+";SDD="+num2str(SDDW[0])+";thickness="+num2str(SampleThicknessW[0])+";"
	MeasurementParameters+=";I0AmpDark=;I0AmpGain="+num2str(I0GainW[0])+";I00AmpGain="+num2str(I00GainW[0])+";"
	MeasurementParameters+="Vfc=100000;Gain1="+num2str(updG1[0])+";Gain2="+num2str(updG2[0])+";Gain3="+num2str(updG3[0])+";Gain4="+num2str(updG4[0])+";Gain5="+num2str(updG5[0])
	MeasurementParameters+=";Bkg1="+num2str(updBkg1[0])+";Bkg2="+num2str(updBkg2[0])+";Bkg3="+num2str(updBkg3[0])+";Bkg4="+num2str(updBkg4[0])+";Bkg5="+num2str(updBkg5[0])
	MeasurementParameters+=";Bkg1Err="+num2str(updBkgErr1[0])+";Bkg2Err="+num2str(updBkgErr2[0])+";Bkg3Err="+num2str(updBkgErr3[0])+";Bkg4Err="+num2str(updBkgErr4[0])+";Bkg5Err="+num2str(updBkgErr5[0])
	if(WaveExists(USAXSPinT_pinCounts))
		if(USAXSPinT_pinCounts[0]>100)
		MeasurementParameters+=";USAXSPinT_Measure=1;USAXSPinT_AyPosition="+num2str(USAXSPinT_AyPosition[0])+";USAXSPinT_Time="+num2str(USAXSPinT_Time[0])+";USAXSPinT_pinCounts="+num2str(USAXSPinT_pinCounts[0])+";"
		MeasurementParameters+="USAXSPinT_pinGain="+num2str(USAXSPinT_pinGain[0])+";USAXSPinT_I0Counts="+num2str(USAXSPinT_I0Counts[0])+";USAXSPinT_I0Gain="+num2str(USAXSPinT_I0Gain[0])+";"
		endif
	endif
	setDataFolder OldDf
	return SpecFileName
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IN3_FSCreateGainWave(GainWv,ampGainReq,ampGain,mcsChangePnts, TimeRangeAfter, MeasTime)
	wave GainWv,ampGainReq,ampGain,mcsChangePnts, TimeRangeAfter, MeasTime 
	
	variable iii, iiimax=numpnts(mcsChangePnts)-1
	variable StartRc, EndRc
	if(iiimax<1)		//Fix for scanning when no range changes happen... 
		GainWv = 4
	endif
	For(iii=0;iii<iiimax;iii+=1)
		if(mcsChangePnts[iii]>0 || iii<4)
			if(ampGain[iii]!=ampGainReq[iii])
				StartRc = mcsChangePnts[iii]
			endif
			if(ampGain[iii]==ampGainReq[iii])
				EndRc = mcsChangePnts[iii]
				GainWv[StartRc,EndRc] = nan
				GainWv[EndRc+1,] = ampGain[iii]+1
				IN3_MaskPointsForGivenTime(GainWv,MeasTime,EndRc+1, TimeRangeAfter[ampGain[iii]])
			endif
		endif
	endfor
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//
//Function IN3_FlyScanMaskGainChanges(Ar_encoder, MeasTime, Monitor, USAXS_PD, PD_range)
//	wave Ar_encoder, MeasTime, Monitor, USAXS_PD, PD_range
//	
//	make/Free/N=5 TimeRangeAfter, TimeRangeBefore
//	TimeRangeBefore={AmplifierPreRage1BlockTime,AmplifierPreRage2BlockTime,AmplifierPreRage3BlockTime,AmplifierPreRage4BlockTime,0}
//	TimeRangeAfter = {AmplifierRange1BlockTime,AmplifierRange2BlockTime,AmplifierRange3BlockTime,AmplifierRange4BlockTime,0}
//	variable NumPntsW=numpnts(MeasTime)
//	//Differentiate/METH=1  PD_range /D=GainChanges
//	//GainChanges = abs(GainChanges)
//	//contains 0 where gain does not change and 1 where the gain changes... 
//	variable i, curGain, maskTime, j, maskTimeUp
//	//deal with range change for gain 1
//	FindLevels/Q  /D=RangeChanges  /P  PD_range, 1.1 
//	For(i=0;i<numpnts(RangeChanges);i+=1)
//		IN3_MaskPointsForGivenTime(USAXS_PD,MeasTime,RangeChanges[i],AmplifierPreRage1BlockTime, AmplifierRange1BlockTime)
//	endfor
//	FindLevels /Q /D=RangeChanges  /P  PD_range, 2.1 
//	For(i=0;i<numpnts(RangeChanges);i+=1)
//		IN3_MaskPointsForGivenTime(USAXS_PD,MeasTime,RangeChanges[i],AmplifierPreRage2BlockTime, AmplifierRange2BlockTime)
//	endfor
//	FindLevels /Q /D=RangeChanges  /P  PD_range, 3.1 
//	For(i=0;i<numpnts(RangeChanges);i+=1)
//		IN3_MaskPointsForGivenTime(USAXS_PD,MeasTime,RangeChanges[i],AmplifierPreRage3BlockTime, AmplifierRange3BlockTime)
//	endfor
//	FindLevels /Q /D=RangeChanges  /P  PD_range, 4.1 
//	For(i=0;i<numpnts(RangeChanges);i+=1)
//		IN3_MaskPointsForGivenTime(USAXS_PD,MeasTime,RangeChanges[i],AmplifierPreRage4BlockTime, AmplifierRange4BlockTime)
//	endfor
//end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IN3_MaskPointsForGivenTime(MaskedWave,TimeWv,PointNum, MaskTimeDown)
	wave MaskedWave,TimeWv
	variable PointNum, MaskTimeDown
	variable NumPntsW
	NumPntsW = numpnts(MaskedWave)
	variable i, maskTime
	i=0
	if(MaskTimeDown>0)
		Do
			MaskedWave[PointNum+i]=nan
			maskTimeDown -=TimeWv[PointNum+i]
			i+=1
		 while ((maskTimeDown>0)&&((PointNum+i)<NumPntsW))
	endif
end

//
//Function IN3_MaskPointsForGivenTime(IntWv,TimeWv,PointNum,MaskTimeUp, MaskTimeDown)
//	wave IntWv,TimeWv
//	variable PointNum,MaskTimeUp, MaskTimeDown
//	variable NumPntsW
//	NumPntsW = numpnts(IntWv)
//	variable i, maskTime
//	i=0
//	Do
//		IntWv[PointNum+i]=nan
//		maskTimeDown -=TimeWv[PointNum+i]
//		i+=1
//	 while ((maskTimeDown>0)&&((PointNum+i)<NumPntsW))
//	i =1
//	Do
//		IntWv[PointNum-i]=nan
//		maskTimeUp -=TimeWv[PointNum-i]
//		i+=1
//	 while (maskTimeUp>0&&((PointNum-i)>=0))
//	
//	
//end
//**********************************************************************************************************
//**********************************************************************************************************
Function IN3_FlyScanRebinData(WvX, WvTime, Wv2, Wv3, Wv4,Wv5,NumberOfPoints, MinStep)
	wave WvX, WvTime, Wv2, Wv3, Wv4, Wv5
	variable NumberOfPoints, MinStep
	//	IN3_FlyScanRebinData(Ar_encoder, MeasTime, Monitor, USAXS_PD, PD_range,NumberOfTempPoints)
	//note, WvX, Wv4 (pd_range), and WvTime is averages, but others are full time (no avergaing).... also, do not count if Wv3 are Nans
	string OldDf
	variable OldNumPnts=numpnts(WvX)
	if(OldNumPnts<NumberOfPoints)
		print "User requested rebinning of data, but old number of points is less than requested point number, no rebinning done"
		return 0
	endif
	variable StartX, EndX, iii, isGrowing, CorrectStart, logStartX, logEndX
	CorrectStart = WvX[0]
	StartX = IN2G_FindCorrectStart(WvX[0],WvX[numpnts(WvX)-1],NumberOfPoints,MinStep)
	EndX = StartX +abs(WvX[numpnts(WvX)-1] -  WvX[0])
	//Log rebinning, if requested.... 
	//create log distribution of points...
	isGrowing = (WvX[0] < WvX[numpnts(WvX)-1]) ? 1 : 0
	make/O/D/FREE/N=(NumberOfPoints) tempNewLogDist, tempNewLogDistBinWidth
	logstartX=log(startX)
	logendX=log(endX)
	tempNewLogDist = logstartX + p*(logendX-logstartX)/numpnts(tempNewLogDist)
	tempNewLogDist = 10^(tempNewLogDist)
	startX = tempNewLogDist[0]
	tempNewLogDist += CorrectStart - StartX
	
	redimension/N=(numpnts(tempNewLogDist)+1) tempNewLogDist
	tempNewLogDist[numpnts(tempNewLogDist)-1]=2*tempNewLogDist[numpnts(tempNewLogDist)-2]-tempNewLogDist[numpnts(tempNewLogDist)-3]
	tempNewLogDistBinWidth = tempNewLogDist[p+1] - tempNewLogDist[p]
	make/O/D/FREE/N=(NumberOfPoints) Rebinned_WvX, Rebinned_WvTime, Rebinned_Wv2,Rebinned_Wv3, Rebinned_Wv4, Rebinned_Wv5
	Rebinned_WvTime=0
	Rebinned_Wv2=0	
	Rebinned_Wv3=0	
	Rebinned_Wv4=0	
	Rebinned_Wv5=0	
	variable i, j	//, startIntg=TempQ[1]-TempQ[0]
	//first assume that we can step through this easily...
	variable cntPoints, BinHighEdge
	//variable i will be from 0 to number of new points, moving through destination waves
	j=0		//this variable goes through data to be reduced, therefore it goes from 0 to numpnts(TempInt)
	For(i=0;i<NumberOfPoints;i+=1)
		cntPoints=0
		BinHighEdge = tempNewLogDist[i]+tempNewLogDistBinWidth[i]/2
		if(isGrowing)
			Do
				if(numtype(Wv3[j])==0)
					Rebinned_WvX[i] += WvX[j]
					Rebinned_WvTime[i]+=WvTime[j]
					Rebinned_Wv2[i]+=Wv2[j]
					Rebinned_Wv3[i] += Wv3[j]
					Rebinned_Wv4[i] += Wv4[j]
					Rebinned_Wv5[i] += Wv5[j]
					cntPoints+=1
				endif
				j+=1
			While(WvX[j-1]<BinHighEdge && j<OldNumPnts)
		else
			Do
				if(numtype(Wv3[j])==0)
					Rebinned_WvX[i] += WvX[j]
					Rebinned_WvTime[i]+=WvTime[j]
					Rebinned_Wv2[i]+=Wv2[j]
					Rebinned_Wv3[i] += Wv3[j]
					Rebinned_Wv4[i] += Wv4[j]
					Rebinned_Wv5[i] += Wv5[j]
					cntPoints+=1
				endif
				j+=1
			While((WvX[j-1]>BinHighEdge) && (j<OldNumPnts))
		endif
		Rebinned_WvTime[i]/=cntPoints		//need average time per exposure for background subtraction... 
		//Rebinned_Wv2[i]/=cntPoints
		//Rebinned_Wv3[i]/=cntPoints
		Rebinned_Wv4[i]/=cntPoints
		Rebinned_WvX[i]/=cntPoints
		Rebinned_Wv5[i]/=cntPoints
	endfor
	
	Redimension/N=(numpnts(Rebinned_WvX))/D WvX, WvTime, Wv2, Wv3, Wv4, Wv5
	WvX=Rebinned_WvX
	WvTime=Rebinned_WvTime
	Wv2=Rebinned_Wv2
	Wv3=Rebinned_Wv3
	Wv4=Rebinned_Wv4
	Wv5=Rebinned_Wv5
		
end


//************************************************************************************************************
//************************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IN3_FlyScanRebinData2(WvX, Wv1, Wv2,NumberOfPoints)
	wave WvX, Wv1, Wv2
	variable NumberOfPoints
	//assume W2 is error!!!!
	string OldDf
	variable OldNumPnts=numpnts(WvX)
	if(OldNumPnts<NumberOfPoints)
		print "User requeseted rebinning of data, but old number of points is less than requested point number, no rebinning done"
		return 0
	endif
	//Log rebinning, if requested.... 
	//create log distribution of points...
	make/O/D/FREE/N=(NumberOfPoints) tempNewLogDist, tempNewLogDistBinWidth
	variable StartX, EndX, iii, isGrowing
	isGrowing = (WvX[0] < WvX[numpnts(WvX)-1]) ? 1 : 0
	startX=log(WvX[0])
	endX=log(WvX[numpnts(WvX)-1])
	tempNewLogDist = startX + p*(endX-startX)/numpnts(tempNewLogDist)
	tempNewLogDist = 10^(tempNewLogDist)
	redimension/N=(numpnts(tempNewLogDist)+1) tempNewLogDist
	tempNewLogDist[numpnts(tempNewLogDist)-1]=2*tempNewLogDist[numpnts(tempNewLogDist)-2]-tempNewLogDist[numpnts(tempNewLogDist)-3]
	tempNewLogDistBinWidth = tempNewLogDist[p+1] - tempNewLogDist[p]
	make/O/D/FREE/N=(NumberOfPoints) Rebinned_WvX, Rebinned_Wv1, Rebinned_Wv2
	Rebinned_Wv1=0
	Rebinned_Wv2=0	
	variable i, j	//, startIntg=TempQ[1]-TempQ[0]
	//first assume that we can step through this easily...
	variable cntPoints, BinHighEdge
	//variable i will be from 0 to number of new points, moving through destination waves
	j=0		//this variable goes through data to be reduced, therefore it goes from 0 to numpnts(TempInt)
	For(i=0;i<NumberOfPoints;i+=1)
		cntPoints=0
		BinHighEdge = tempNewLogDist[i]+tempNewLogDistBinWidth[i]/2
		if(isGrowing)
			Do
				Rebinned_Wv1[i]+=Wv1[j]
				Rebinned_Wv2[i]+=(Wv2[j])^2		//sum of squares
				Rebinned_WvX[i] += WvX[j]
				cntPoints+=1
				j+=1
			While(WvX[j-1]<BinHighEdge && j<OldNumPnts)
		else
			Do
				Rebinned_Wv1[i]+=Wv1[j]
				Rebinned_Wv2[i]+=(Wv2[j])^2		//sum of squares
				Rebinned_WvX[i] += WvX[j]
				cntPoints+=1
				j+=1
			While(WvX[j-1]>BinHighEdge && j<OldNumPnts)
		endif
		Rebinned_Wv1[i]/=cntPoints
		Rebinned_Wv2[i]/=cntPoints		
		Rebinned_Wv2[i]=sqrt(Rebinned_Wv2[i])		//this is standard deviation
		Rebinned_Wv2[i]/=sqrt(cntPoints)			//and this makes is SEM - standard error of mean
		Rebinned_WvX[i]/=cntPoints
		if(j>=OldNumPnts-1)
			break
		endif
	endfor	
	Redimension/N=(numpnts(Rebinned_WvX))/D WvX, Wv1, Wv2
	WvX=Rebinned_WvX
	Wv1=Rebinned_Wv1
	Wv2=Rebinned_Wv2		
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IN3_FlyScanConfigureFnct()

	IN3_FlyScanConfigurePnlF()
	PauseForUser IN3_FlyScanConfigurePnl 

end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function IN3_FlyScanConfigurePnlF()

	NewPanel /K=1/W=(322,85,667,305) as "Configure FlyScan Import"
	DoWindow/C IN3_FlyScanConfigurePnl
	TitleBox MainTitle,pos={5,5},size={360,24},title="Configure FlyScan import params"
	TitleBox MainTitle,font="Times New Roman",fSize=22,frame=0,fStyle=3
	TitleBox MainTitle,fColor=(0,0,52224),fixedSize=1
	CheckBox DoubleClickImports,pos={15,40},size={16,14},proc=IN3_FlyScanCheckProc,title="Import on DblClick",variable= root:Packages:USAXS_FlyScanImport:DoubleClickImports, help={"Import when double clicked"}
	CheckBox DoubleClickOpensInBrowser,pos={15,65},size={16,14},proc=IN3_FlyScanCheckProc,title="Browse on DblClick",variable= root:Packages:USAXS_FlyScanImport:DoubleClickOpensInBrowser, help={"Open in Browser on Double click"}

	NVAR NumberOfTempPoints = root:Packages:USAXS_FlyScanImport:NumberOfTempPoints
	PopupMenu SelectTempNumPoints,pos={15,90},size={250,21},proc=IN3_FlyScanPopMenuProc,title="Temp Number of points", help={"For slower computers select smaller number"}
	PopupMenu SelectTempNumPoints,mode=(1+WhichListItem(num2str(NumberOfTempPoints), "20000;10000;5000;")),value= "20000;10000;5000;"

end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function IN3_FlyScanPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if (Cmpstr(ctrlName,"SelectTempNumPoints")==0)
		NVAR NumberOfTempPoints = root:Packages:USAXS_FlyScanImport:NumberOfTempPoints
		NumberOfTempPoints = str2num(popStr)
	endif
End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

 //************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IN3_FlyScanButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if(cmpstr(ctrlName,"SelectDataPath")==0)
		IN3_FlyScanSelectDataPath()	
		IN3_FSUpdateListOfFilesInWvs()
	endif
	if(cmpstr(ctrlName,"OpenFileInBrowser")==0)
		IN3_FlyScanOpenHdf5File()
	endif
	if(cmpstr(ctrlName,"RefreshHDF5Data")==0)
		IN3_FSUpdateListOfFilesInWvs()
	endif
	if(cmpstr(ctrlName,"SelectAll")==0)
		IN3_FSSelectDeselectAll(1)
	endif
	if(cmpstr(ctrlName,"DeselectAll")==0)
		IN3_FSSelectDeselectAll(0)
	endif
	if(cmpstr(ctrlName,"ImportData")==0)
		IN3_FlyScanLoadHdf5File()
	endif
	if(cmpstr(ctrlName,"ConfigureBehavior")==0)
		IN3_FlyScanConfigureFnct()
	endif
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IN3_FlyScanSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	if (cmpstr(ctrlName,"DataExtensionString")==0)
		IN3_FSUpdateListOfFilesInWvs()
	endif
	if (cmpstr(ctrlName,"NameMatchString")==0)
		IN3_FSUpdateListOfFilesInWvs()
	endif
	
End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IN3_FlyScanImportListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable row = lba.row
	Variable col = lba.col
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave
	NVAR DoubleClickImports=root:Packages:USAXS_FlyScanImport:DoubleClickImports
	NVAR DoubleClickOpensInBrowser=root:Packages:USAXS_FlyScanImport:DoubleClickOpensInBrowser

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
			break
		case 3: // double click
			if(DoubleClickImports)
				IN3_FlyScanLoadHdf5File()
			else
				IN3_FlyScanOpenHdf5File()
			endif
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
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function IN3_FlyScanInitializeImport()
	
	string OldDf = GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:USAXS_FlyScanImport
	
	string ListOfStrings
	string ListOfVariables
	variable i
	
	ListOfStrings = "DataPathString;DataExtension;SelectedFileName;NewDataFolderName;NameMatchString;"

	ListOfVariables = "NumberOfOutputPoints;DoubleClickImports;DoubleClickOpensInBrowser;NumberOfTempPoints;"
	ListOfVariables += "LatestOnTopInPanel;ReduceXPCSdata;"

		//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	SVAR DataExtension
	DataExtension="h5"
	NVAR DoubleClickImports
	NVAR DoubleClickOpensInBrowser
	if(DoubleClickImports+DoubleClickOpensInBrowser!=1)
		DoubleClickImports=1
		DoubleClickOpensInBrowser=0
	endif
	NVAR NumberOfTempPoints
	if(NumberOfTempPoints<5000)
		NumberOfTempPoints=20000
	endif
	Make/O/T/N=0 WaveOfFiles
	Make/O/N=0 WaveOfSelections
//	
//	ListOfVariables = "CreateSQRTErrors;Col1Int;Col1Qvec;Col1Err;Col1QErr;"	
//	ListOfVariables += "Col2Int;Col2Qvec;Col2Err;Col2QErr;Col3Int;Col3Qvec;Col3Err;Col3QErr;Col4Int;Col4Qvec;Col4Err;Col4QErr;"	
//	ListOfVariables += "Col5Int;Col5Qvec;Col5Err;Col5QErr;Col6Int;Col6Qvec;Col6Err;Col6QErr;Col7Int;Col7Qvec;Col7Err;Col7QErr;"	
//	ListOfVariables += "QvectInNM;CreateSQRTErrors;CreatePercentErrors;"	
//	ListOfVariables += "ScaleImportedData;ImportSMRdata;SkipLines;SkipNumberOfLines;UseQISNames;UseIndra2Names;NumOfPointsFound;"	
//
//	//Set numbers to 0
//	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
//		NVAR test=$(StringFromList(i,ListOfVariables))
//		test =0
//	endfor		
//	ListOfVariables = "QvectInA;PercentErrorsToUse;ScaleImportedDataBy;UseFileNameAsFolder;UseQRSNames;"	
//	//Set numbers to 1
//	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
//		NVAR test=$(StringFromList(i,ListOfVariables))
//		test =1
//	endfor		
//	ListOfVariables = "TargetNumberOfPoints;"	
//	//Set numbers to 1
//	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
//		NVAR test=$(StringFromList(i,ListOfVariables))
//		if(test<1)
//			test =200
//		endif
//	endfor		
//	ListOfVariables = "ReducePntsParam;"	
//	//Set numbers to 1
//	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
//		NVAR test=$(StringFromList(i,ListOfVariables))
//		if(test<0.5)
//			test =5
//		endif
//	endfor		
//	
//	NVAR DataCalibratedArbitrary
//	NVAR DataCalibratedVolume
//	NVAR DataCalibratedWeight
//	if(DataCalibratedArbitrary+DataCalibratedVolume+DataCalibratedWeight!=1)
//		DataCalibratedArbitrary = 1
//		DataCalibratedVolume = 0
//		DataCalibratedWeight = 0
//	endif
//	NVAR TrunkateStart
//	NVAR TrunkateEnd
//	if(TrunkateStart+TrunkateEnd!=1)
//		TrunkateStart=0
//		TrunkateEnd=1
//	endif
//	IR1I_UpdateListOfFilesInWvs()
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
