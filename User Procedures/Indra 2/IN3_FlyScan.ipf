#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.04
#include <Peak AutoFind>


Constant IN3_FlyImportVersionNumber=0.19
Constant IN3_DeleteRawData=1

//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/
//1.04 removed spec file name as folder under USAXS, not needed with SAXS and WAXS not having it anyway. 
//1.03 added UserSampleName to be used to avoid long file names limits...
//1.02 fixed reading old data without UPDsize in the metadata
//1.01 fixed BKG5overwrite which was not read correctly into the system. 
//1.00 added support for Import & process GUI. 
//0.39 modified IN3_FlyScanSelectDataPath to handle presence on USAXS computers with usaxscontrol samba drive
//0.38 fixes for 2016-02, sorting for new naming system
//0.37 scaling of panels and added Remove from name string
//0.36 fixed the need for using the HDF5 Browser, it was easy. Much quicker...  
//0.35 fixed problem with too long name of spec file and therefore flyscan folder. 
//0.34 fixed problem with too long names of flyscan hdf files and delete all raw data - too large, not necessary. 
//0.33 more fixes for 9ID. 
//0.32 fixes for 9ID, 02-08-2015, Modified function creating gain changes - needs fixing for I0 and I00.
//0.31 added some fixes for flyscan gain issues and DSM support. 
//0.30 added Ê/entry/flyScan/is_2D_USAXS_scan
//0.29 fixed problem with liberal h5 file names (containing ".") which caused havock in addressing folders.  
//0.28 fixed I0 gaincalcualtions (and fixed FLyscan program on LAX). 
//0.27 Attempt to fix vibrations when happen... 
//0.26 Added three modes for FlyScans (Array, Trajectory, Fixed)
//0.25 modified to handle too long file anmes as users cannot learn not to do this... 
//0.24 modified to use Rebinninng procedure from General procedures - requires Gen Proc version 1.71 nad higher
//0.23 changed defaults to 5000 points on import. 
//0.22 improvement to backward compatibility from February 2014
//0.21 fixed gain creation
//0.20 changed DCM_energy to energy as changed in the files
//0.19 fixed missing checkbox procedure and added first attempt to support xpcs data 
//0.18 modified for new file format (3/1/2014), version =1, use dead time from Pvs etc., moved raw folder in spec file FLy folder. 
//0.17  fixed for use of only 3 mcs channels (removed upd and I0 gains). 
//0.16 modified sorting of the h5 files in the GUI. 
//0.15 many changes, I0gain, new gain change masking method, use records from mca changes to create UPD_gain etc.  
// 0.11 added transmission handling
//version 0.1 developement of import functions and GUIs


//note, to run something just after hdf5 file import use function 
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
//Function AfterFlyImportHook(RawFolderWithData)
//	string RawFolderWithData
//	
//	//print RawFolderWithData
//	//go to folder and fins mca1, display it and see, what  is happening. 
//	wave timePulses=$(RawFolderWithData+":entry:flyScan:mca1")
//	wave AnglePositions=$(RawFolderWithData+":entry:flyScan:Ar_PulsePositions")
//	display/K=1 timePulses 
////	display/K=1 timePulses vs AnglePositions
////	SetAxis bottom 10.895,10.914
//	ModifyGraph log=1
//	DoWindow/C $(stringFromList(3,RawFolderWithData,":")) 
//end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IN3_FlyScanMain()
	DoWIndow IN3_FlyScanImportPanel
	if(V_Flag)
		DoWIndow/K IN3_FlyScanImportPanel
	endif
	//KillWIndow/Z IN3_FlyScanImportPanel
	DoWIndow USAXSDataReduction
	if(V_Flag)
		DoWIndow/K USAXSDataReduction
	endif
	//KillWIndow/Z USAXSDataReduction
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
	NewPanel /K=1 /W=(49,49,412,545) as "USAXS FlyScan Import data"
	DoWindow/C IN3_FlyScanImportPanel
	TitleBox MainTitle,pos={13,5},size={330,24},title="\Zr210Import USAXS Data "
	TitleBox MainTitle,font="Times New Roman",frame=0,fStyle=3,anchor=MC
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
	SetVariable NameMatchString,pos={10,370},size={230,15},proc=IN3_FlyScanSetVarProc,title="Match name (string):"
	SetVariable NameMatchString,help={"Insert name match string to display only some data"}
	SetVariable NameMatchString,value= root:Packages:USAXS_FlyScanImport:NameMatchString
	SetVariable RemoveFromNameString,pos={10,395},size={230,15},proc=IN3_FlyScanSetVarProc,title="Remove From name (str):"
	SetVariable RemoveFromNameString,help={"String which will be removed from data name"}
	SetVariable RemoveFromNameString,value= root:Packages:USAXS_FlyScanImport:RemoveFromNameString
	CheckBox LatestOnTopInPanel,pos={244,370},size={16,14},proc=IN3_FlyCheckProc,title="Latest on top?",variable= root:Packages:USAXS_FlyScanImport:LatestOnTopInPanel, help={"Check to display latest files at the top"}
	CheckBox ReduceXPCSdata,pos={244,390},size={16,14},proc=IN3_FlyCheckProc,title="Reduce XPCS data?",variable= root:Packages:USAXS_FlyScanImport:ReduceXPCSdata, help={"Check to redeuce XPCS not USAXS data"}

	Button SelectAll,pos={7,420},size={100,20},proc=IN3_FlyScanButtonProc,title="Select All"
	Button SelectAll,help={"Select all waves in the list"}
	Button DeSelectAll,pos={120,420},size={100,20},proc=IN3_FlyScanButtonProc,title="Deselect All"
	Button DeSelectAll,help={"Deselect all waves in the list"}
	Button OpenFileInBrowser,pos={7,450},size={100,30},proc=IN3_FlyScanButtonProc,title="Open in Browser"
	Button OpenFileInBrowser,help={"Check file in HDF5 Browser"}
	Button ImportData,pos={120,450},size={100,30},proc=IN3_FlyScanButtonProc,title="Import"
	Button ImportData,help={"Import the selected data files."}
	Button ConfigureBehavior,pos={240,450},size={100,20},proc=IN3_FlyScanButtonProc,title="Configure"
	Button ConfigureBehavior,help={"Import the selected data files."}

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
	
	//check if we are running on USAXS computers
	GetFileFOlderInfo/Q/Z "Z:USAXS_data:"
	if(V_isFolder)
		//OK, this computer has Z:USAXS_data 
		PathInfo USAXSHDFPath
		if(V_flag==0)
			NewPath/Q  USAXSHDFPath, "Z:USAXS_data:"
			pathinfo/S USAXSHDFPath
		endif
	endif
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
			//decide if using old or new naming system
			if(grepstring(WaveOfFiles[i],"^S[0-9]+"))//OLD METHOD
				TmpSortWv[i] = str2num(StringFromList(0, WaveOfFiles[i] , "_")[1,inf])
			else	//number at the end... 
				TmpSortWv[i] = str2num(StringFromList(ItemsInList(WaveOfFiles[i] , "_")-1, WaveOfFiles[i] , "_")[1,inf])
			endif
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
	SVAR RemoveFromNameString = root:Packages:USAXS_FlyScanImport:RemoveFromNameString	
	NVAR ReduceXPCSdata = root:Packages:USAXS_FlyScanImport:ReduceXPCSdata
	
	variable NumSelFiles=sum(WaveOfSelections)	
	variable OpenMultipleFiles=0
	if(NumSelFiles==0)
		return 0
	endif	
	variable i, Overwrite
	string FileName, ListOfExistingFolders, tmpDtaFldr, shortNameBckp, TargetRawFoldername
	String browserName, shortFileName, RawFolderWithData, SpecFileName, RawFolderWithFldr
	String newShortName
	Variable locFileID
	For(i=0;i<numpnts(WaveOfSelections);i+=1)
		if(WaveOfSelections[i])
			FileName= WaveOfFiles[i]
			shortFileName = ReplaceString("."+DataExtension, FileName, "")
			newShortName = ReplaceString(RemoveFromNameString,shortFileName,"")[0,30]
			shortFileName = shortFileName[0,30]
			//check if such data exist already...
			ListOfExistingFolders = DataFolderDir(1)
			HDF5OpenFile/R /P=USAXSHDFPath locFileID as FileName
			if (V_flag == 0)					// Open OK?
				HDF5LoadGroup /O /R /T /IMAG=1 :, locFileID, "/"			
				if(!ReduceXPCSdata)			//this is valid only for USAXS fly scan data, not for XPCS. 
					KillWaves/Z Config_Version
					HDF5LoadData/Z /A="config_version"/Q  /Type=2 locFileID , "/entry/program_name" 
					if(V_Flag!=0)
						Make/T/N=1 Config_Version
						Config_Version[0]="0"
					endif
					Wave/T Config_Version
				endif
				//need to figure out, if the file name was not just too long for Igor, so this will be bit more complciated...
				string TempStrName=PossiblyQuoteName(shortFileName)
				string TempStrNameShort=PossiblyQuoteName(newShortName)
				if(DataFolderExists(shortFileName))		//Name exists and folder is fine... 
					RawFolderWithData = GetDataFOlder(1)+TempStrName
					RawFolderWithFldr = GetDataFolder(1)
				else		//something failed. Expect too long name
						Abort "Cannot find raw data, something went wrong. Send Nexus file to Jan so we can get this fixed."
				endif
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
				if(strlen(TargetRawFoldername)>30)
					//DoAlert /T="Too long folder name warning" 0, "The folder name is too long for Igor Pro, it will be cut to 30 characters"
					print "*****    ERROR MESSAGE  ***** "
					print "The folder name was too long for Igor Pro, it will be cut to 30 characters, it is now:   " +TargetRawFoldername[0,30] 
					print "^^^^^^    ERROR MESSAGE  ^^^^^^"		
					TargetRawFoldername = TargetRawFoldername[0,30]  
				endif
				NewDataFolder/O $(TargetRawFoldername)
				string targetFldrname=":"+possiblyquoteName(TargetRawFoldername)+":"+TempStrNameShort
				if(DataFolderExists(targetFldrname))
					DoAlert /T="RAW data folder exists" 2, "Folder with RAW folder with name "+ targetFldrname+" already exists. Overwrite (Yes), Rename (No), or Cancel?"
					if(V_Flag==1)
						KillDataFolder/Z targetFldrname
						//MoveDataFolder $(TempStrName), $(":"+possiblyquoteName(TargetRawFoldername))				
						DuplicateDataFolder $(TempStrName), $(":"+possiblyquoteName(TargetRawFoldername)+":"+TempStrNameShort)
						KillDataFolder $(TempStrName)
					elseif(V_Flag==2)
						string OldDf1=getDataFolder(1)
						SetDataFolder TargetRawFoldername
						string TempStrNameNew = possiblyquoteName(UniqueName(IN2G_RemoveExtraQuote(TempStrNameShort,1,1), 11, 0 ))
						SetDataFolder OldDf1		
						DuplicateDataFolder $(TempStrName), $(":"+possiblyquoteName(TargetRawFoldername)+":"+TempStrNameNew)
						TempStrNameShort = TempStrNameNew		
						KillDataFolder $(TempStrName)
					else
						Abort 
					endif
				else
					//MoveDataFolder $(shortFileName), $(":"+possiblyquoteName(TargetRawFoldername))				
					DuplicateDataFolder $(shortFileName), $(":"+possiblyquoteName(TargetRawFoldername)+":"+TempStrNameShort)
					KillDataFolder $(shortFileName)
				endif
				RawFolderWithData = RawFolderWithFldr+possiblyquoteName(TargetRawFoldername)+":"+TempStrNameShort
				print "Imported HDF5 file : "+RawFolderWithData
#if(exists("AfterFlyImportHook")==6)  
			AfterFlyImportHook(RawFolderWithData)
#endif	
				if(ReduceXPCSdata)
					print "here belongs XPCS data conversion routine in the future" 
					print "IN3_FlyScanLoadHdf5File()"
				else
					IN3_FSConvertToUSAXS(RawFolderWithData, FileName)	
					print "Converted : "+RawFolderWithData+" into USAXS data"
					if(IN3_DeleteRawData)
						KillDataFOlder RawFolderWithData
						//print "Deleted RAW folder : "+ RawFolderWithData +" - not necessary and takes too much space in files" 
					endif
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

Function/T IN3_FSConvertToUSAXS(RawFolderWithData, origFileName)
	string RawFolderWithData, origFileName

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
	Wave/Z UPDsize=:entry:metadata:UPDsize	
	if(!WaveExists(UPDsize))
		make/O/N=1 :entry:metadata:UPDsize
		Wave UPDsize=:entry:metadata:UPDsize	
		UPDsize[0] = 5.5
	endif
	Wave/T SampleNameW=:entry:sample:name
	Wave SampleThicknessW = :entry:sample:thickness
	Wave/Z DCM_energyW=:entry:instrument:monochromator:energy
	if(!WaveExists(DCM_energyW))
		Wave/Z DCM_energyW=:entry:instrument:monochromator:DCM_energy
	endif
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
	Wave/Z  AR_Finish = :entry:flyScan:AR_Finish
	Wave/Z  AR_NumPulsePositions = :entry:flyScan:AR_NumPulsePositions
	Wave/Z  AR_PulseMode = :entry:flyScan:AR_PulseMode
	if(!WaveExists(AR_PulseMode))
		Make/O/N=1 :entry:flyScan:AR_PulseMode
		Wave  AR_PulseMode = :entry:flyScan:AR_PulseMode
		AR_PulseMode = 0
	endif
	variable is2DScan		//2D collimated USAXS?
	is2DScan = 0
	Wave/Z is_2D_USAXS_scan= :entry:flyScan:is_2D_USAXS_scan
	if(WaveExists(is_2D_USAXS_scan))
		is2DScan = is_2D_USAXS_scan[0]
	endif
	Wave/Z  AR_PulsePositions = :entry:flyScan:AR_PulsePositions
	Wave/Z  AR_pulses= :entry:flyScan:AR_pulses
	Wave/Z  AR_waypoints= :entry:flyScan:AR_waypoints
//temp for developement today...
//HdfWriterVersion = 1.1
	//USAXSPinT_Measure=1;USAXSPinT_AyPosition=11.1725;USAXSPinT_Time=3;USAXSPinT_pinCounts=1918487;
	//USAXSPinT_pinGain=1000000;USAXSPinT_I0Counts=219754;USAXSPinT_I0Gain=10000000;
	make/Free/N=5 TimeRangeAfterUPD, TimeRangeAfterI0
	if(HdfWriterVersion<1)
		Wave mcsChangePnts = :entry:flyScan:changes_mcsChan
		Wave ampGain = :entry:flyScan:changes_ampGain
		Wave ampReqGain = :entry:flyScan:changes_ampReqGain
		TimeRangeAfterUPD = {AmplifierRange1BlockTime,AmplifierRange2BlockTime,AmplifierRange3BlockTime,AmplifierRange4BlockTime,AmplifierRange5BlockTime}
		TimeRangeAfterI0 = {0,0,0,0,0}
	elseif(HdfWriterVersion>=1)
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
		TimeRangeAfterI0 = {0.05,0.05,0.05,0.05,0.05}
		//we need to mask at least 50ms for each change...
		TimeRangeAfterUPD = TimeRangeAfterUPD[p]>0.05 ? TimeRangeAfterUPD[p] : 0.05
		//Ar positions read at 10Hz 
		Wave changes_AR_PSOpulse = :entry:flyScan:changes_AR_PSOpulse
		Wave changes_AR_angle = :entry:flyScan:changes_AR_angle
	endif
	//here we copy data to new place
	newDataFolder/O/S root:USAXS
	//newDataFolder/O/S $(SpecFileName)
	string FileName, ListOfExistingFolders
	FileName=StringFromList(ItemsInList(RawFolderWithData ,":")-1, RawFolderWithData,  ":")
	FileName = IN2G_RemoveExtraQuote(FileName,1,1)
	ListOfExistingFolders = DataFolderDir(1)
	NVAR OverWriteExistingData=root:Packages:Indra3:OverWriteExistingData
	if(StringMatch(ListOfExistingFolders, "*"+IN2G_RemoveExtraQuote(FileName,1,1)+";*" ) && (OverWriteExistingData==0))
		DoAlert /T="Non unique name alert..." 1, "USAXS Folder with "+FileName+" name already found, Overwrite?" 
			if(V_Flag!=1)
				return ""
			endif	
	endif

 	newDataFolder/O/S $(FileName)
	string/g UserSampleName=	stringFromList(0,origFileName,".")
	Duplicate/O TimeWv, MeasTime
	Duplicate/O I0Wv, Monitor
	Duplicate/O updWv, USAXS_PD
	Duplicate/O TimeWv, PD_range
	Duplicate/O TimeWv, I0gain
	variable OscillationsFound
	OscillationsFound=0
	//create AR data
	if(HdfWriterVersion<1.1)
		Duplicate/Free TimeWv, ArValues
		Redimension /D ArValues
		ArValues = abs(Ar_increment[0])*p
	else
		if(AR_PulseMode[0]==0)		//trajectory using fixed point system.
			Duplicate/Free TimeWv, ArValues
			Redimension /D ArValues
			ArValues = abs(Ar_increment[0])*p
		elseif(AR_PulseMode[0]==1)		// this is using PSO pulse positions, typically 2-8k points, need to also trim extra end as we always save 8k points
			Duplicate/Free AR_PulsePositions, ArValues
			Redimension /D/N=(AR_pulses[0]) ArValues
			ArValues[1,numpnts(ArValues)-1] = (ArValues[p]+ArValues[p-1])/2		// shift to have mean AR value for each point and not the end of the AR value, when the system advanced to next point. 
			DeletePoints 0, 1, ArValues					//the system does not report any data for first channel. HLe settings.
			if(numpnts(MeasTime)!=numpnts(ArValues))
				OscillationsFound=1
			endif
		elseif(AR_PulseMode[0]==2)		//this is using trajectory way points, typically 200 points
			Duplicate/Free AR_waypoints, ArValues
			Redimension /D ArValues
			ArValues[1,numpnts(ArValues)-1] = (ArValues[p]+ArValues[p-1])/2		// shift to have mean AR value for each point and not the end of the AR value, when the system advanced to next point. 
			DeletePoints 0, 1, ArValues					//the system does not report any data for first channel. HLe settings.
			if(numpnts(MeasTime)!=numpnts(ArValues))
				OscillationsFound=1
			endif
		else
			Abort "Unknown data collection method" 
		endif
	endif
	Duplicate/O ArValues, Ar_encoder	
	if(OscillationsFound)
		//let's figure out, if all worked as expected.
		Duplicate/O/Free changes_AR_PSOpulse, AR_PSOpulse
		Duplicate/O/Free changes_AR_angle, AR_angle, DiffARValues
		variable EndOFData = BinarySearch(AR_angle, 0.1)
		DeletePoints  EndOFData, (numpnts(AR_angle)-EndOFData), AR_angle, AR_PSOpulse, DiffARValues
		//OK, let's fix the weird PSOpulse errors we see. Not sure where these come from. 
		print "Found that there were likely vibrations during scan, doing fix using PSO channel record" 
		IN3_CleanUpStaleMCAChannel(AR_PSOpulse, AR_angle)
		Redimension /D/N=(numpnts(MeasTime)) ArValues
		IN3_LocateAndRemoveOscillations(AR_encoder,AR_PSOpulse,AR_angle)
	endif
	redimension/D MeasTime, Monitor, USAXS_PD
	redimension/S PD_range, I0gain
	//need to append the wave notes...
	string WaveNote
	if(is2DScan)
		WaveNote="DATAFILE="+SpecFileNameWv[0]+";DATE="+TimeW[0]+";COMMENT="+SampleNameW[0]+";SpecCommand="+"sbflyScan  ar 17.8217 17.8206 14.5895 2e-05  26.2812 "+num2str(SDDW[0])+" -0.1 "+num2str(SADW[0])+" "+num2str(SampleThicknessW[0])+" 100 1"
	else
		WaveNote="DATAFILE="+SpecFileNameWv[0]+";DATE="+TimeW[0]+";COMMENT="+SampleNameW[0]+";SpecCommand="+"flyScan  ar 17.8217 17.8206 14.5895 2e-05  26.2812 "+num2str(SDDW[0])+" -0.1 "+num2str(SADW[0])+" "+num2str(SampleThicknessW[0])+" 100 1"		
	endif
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
	elseif(HdfWriterVersion>=1 && HdfWriterVersion<=1.2) 
		MeasTime/=mcaFrequency[0]		//convert to seconds
		if(AmplifierUsed[0])		//DDPCA300
			IN3_FSCreateGainWave(PD_range,DDPCA300_ampReqGain,DDPCA300_ampGain,DDPCA300_mcsChan, TimeRangeAfterUPD,MeasTime)
		else						//DLPCA200
			IN3_FSCreateGainWave(PD_range,DLPCA200_ampReqGain,DLPCA200_ampGain,DLPCA200_mcsChan, TimeRangeAfterUPD,MeasTime)
		endif
		IN3_FSCreateGainWave(I0gain,I0_ampReqGain,I0_ampGain,I0_mcsChan, TimeRangeAfterI0,MeasTime)
		I0gain = 10^(I0gain[p]+5)
	endif
	if(AR_PulseMode[0]==0)		//only needed for fixed point positions, the others are already manageable number of points.
		NVAR NumberOfTempPoints = root:Packages:USAXS_FlyScanImport:NumberOfTempPoints
		IN2G_RebinLogData(Ar_encoder,MeasTime,NumberOfTempPoints,Ar_increment[0],W1=USAXS_PD, W2=Monitor, W3=PD_range, W4=I0gain)
	endif
	IN2G_RemoveNaNsFrom6Waves(Ar_encoder, MeasTime, Monitor, USAXS_PD, PD_range, I0gain)
	//let's make some standard strings we need.
	string/g PathToRawData
	PathToRawData=RawFolderWithData
	string/g SpecCommand
	if(is2DScan)
		SpecCommand="sbflyScan  ar 17.8217 17.8206 14.5895 2e-05  26.2812 "+num2str(SDDW[0])+" -0.1 "+num2str(SADW[0])+" "+num2str(SampleThicknessW[0])+" 100 1"
	else
		SpecCommand="flyScan  ar 17.8217 17.8206 14.5895 2e-05  26.2812 "+num2str(SDDW[0])+" -0.1 "+num2str(SADW[0])+" "+num2str(SampleThicknessW[0])+" 100 1"
	endif
	string/g SpecComment
	string/g SpecSourceFileName
	SpecSourceFileName=SpecSourceFilenameW[0]
	SpecComment = SampleNameW[0]
	string/g UPDParameters
	UPDParameters="Vfc=100000;Gain1="+num2str(updG1[0])+";Gain2="+num2str(updG2[0])+";Gain3="+num2str(updG3[0])+";Gain4="+num2str(updG4[0])+";Gain5="+num2str(updG5[0])
	UPDParameters+=";Bkg1="+num2str(updBkg1[0])+";Bkg2="+num2str(updBkg2[0])+";Bkg3="+num2str(updBkg3[0])+";Bkg4="+num2str(updBkg4[0])+";Bkg5="+num2str(updBkg5[0])
	UPDParameters+=";Bkg1Err="+num2str(updBkgErr1[0])+";Bkg2Err="+num2str(updBkgErr2[0])+";Bkg3Err="+num2str(updBkgErr3[0])+";Bkg4Err="+num2str(updBkgErr4[0])+";Bkg5Err="+num2str(updBkgErr5[0])
	UPDParameters+=";I0AmpDark=;I0AmpGain="+num2str(I0GainW[0])+";I00AmpGain="+num2str(I00GainW[0])+";UPDsize="+num2str(UPDsize[0])+";"
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
	//overwrite the UPD5Bkg if user chose to do so. 
	DoWIndow USAXSDataReduction 
	if(V_FLag)
		ControlInfo /W=USAXSDataReduction Bkg5Overwrite
		NVAR UPD_DK5=root:Packages:Indra3:UPD_DK5
		if(V_Value!=0)
				UPD_DK5 = V_Value
				UPDParameters=ReplaceNumberByKey("Bkg5",UPDParameters, UPD_DK5,"=")
		else
				SVAR MeasurementParameters = MeasurementParameters
				UPD_DK5 = NumberByKey("Bkg5", MeasurementParameters, "=", ";")
				UPDParameters=ReplaceNumberByKey("Bkg5",UPDParameters, UPD_DK5,"=")
		endif
	endif
	string DataFolderName=GetDataFOlder(1)
	setDataFolder OldDf
	return DataFolderName
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IN3_CleanUpStaleMCAChannel(PSO_Wave, AnglesWave)
	wave PSO_Wave, AnglesWave
	
	variable i, j, jstart, NumNANsRemoved, NumPointsFixed
	//first remove all points which have 0 chan in them (except the last one). Any motion here is before we start moving.  
	For(i=0;i<numpnts(PSO_Wave);i+=1)
		if(PSO_Wave[i]==0 && PSO_Wave[i+1]==0)
			PSO_Wave[i]=NaN
			NumNANsRemoved+=1
		else
			break
		endif
	endfor
	//note, now we may need to clean up the end of same positions in PSO pulse, which is indication, that we had failure somehwere upstream... 
	For(i=numpnts(PSO_Wave)-1;i>0;i-=1)
		if((PSO_Wave[i]-PSO_Wave[i-1])<0.5)
			PSO_Wave[i]=NaN
			NumNANsRemoved+=1
		else
			break
		endif
	endfor
	IN2G_RemoveNaNsFrom2Waves(PSO_Wave, AnglesWave)
	//now fix the hickups...
	//Duplicate/O PSO_Wave, PSO_WaveBackup
	Differentiate/METH=2 PSO_Wave/D=PSO_Wave_DIF
	jstart=-1
	For(i=0;i<numpnts(PSO_Wave_DIF);i+=1)
		if(PSO_Wave_DIF[i]==0)
			j+=1
			if(jstart<0)
				jstart=i-1
			endif
			NumPointsFixed+=1
		else			
			if(j>0&& (PSO_Wave_DIF[jstart+j+1]>1))			//need to avoid counting cases when the stage is within one PSO pulse for long time. 	
				PSO_Wave[jstart,jstart+j] = ceil(PSO_Wave[jstart]+ ((p-jstart)/(j+1))*(PSO_Wave_DIF[jstart+j+1]))
			else
				NumPointsFixed-=j
			endif
			j=0
			jstart=-1
		endif
	endfor	
	//now colapse the points where multiple points are same by averaging the points. 
	Duplicate/Free PSO_Wave, PSOWaveShort, AnglesWaveShort
	PSOWaveShort=nan
	AnglesWaveShort=nan
	variable tempPSO, tempAr, NumSamePts
	tempPSO=0
	tempAr=0
	NumSamePts=0
	j=0
	For(i=0;i<numpnts(PSO_Wave)-1;i+=1)
		if(PSO_Wave[i]==PSO_Wave[i+1])
			tempPSO+=PSO_Wave[i]
			tempAr+=AnglesWave[i]
			NumSamePts+=1
		else
			tempPSO+=PSO_Wave[i]
			tempAr+=AnglesWave[i]
			NumSamePts+=1
			PSOWaveShort[j]  = tempPSO/NumSamePts
			AnglesWaveShort[j]=  tempAr/NumSamePts
			tempPSO=0
			tempAr=0
			NumSamePts=0
			j+=1
		endif
	endfor
	PSO_Wave=nan
	AnglesWave=nan
	IN2G_RemoveNaNsFrom2Waves(PSOWaveShort, AnglesWaveShort)
	PSO_Wave[0,numpnts(PSOWaveShort)-1] = PSOWaveShort[p]
//	PSO_Wave[numpnts(PSOWaveShort), numpnts(PSO_Wave)-1]  = PSOWaveShort[numpnts(PSOWaveShort)-1]+p-numpnts(PSOWaveShort)
	AnglesWave[0,numpnts(PSOWaveShort)-1] = AnglesWaveShort[p]
//	AnglesWave[numpnts(PSOWaveShort), numpnts(PSO_Wave)-1]  = AnglesWaveShort[numpnts(PSOWaveShort)-1]
	IN2G_RemoveNaNsFrom2Waves(PSO_Wave, AnglesWave)
	KillWaves PSO_Wave_DIF

//	variable OrgLength=numpnts(PSO_Wave)
//	Duplicate/O PSO_Wave, PSO_WaveSmooth
//	PSO_WaveSmooth[10,numpnts(PSO_Wave)-3] = ((PSO_Wave[p]/(PSO_Wave[p-2]+PSO_Wave[p-1]+PSO_Wave[p+1]+PSO_Wave[p+2])>2)) ? PSO_Wave[p] : (PSO_Wave[p-2]+PSO_Wave[p-1]+PSO_Wave[p+1]+PSO_Wave[p+2])/4 
//	//IN2G_RemoveNaNsFrom2Waves(PSO_Wave, AnglesWave)
//	NumNANsRemoved+=OrgLength - numpnts(PSO_Wave)
	Print "PSO_Angles data needed to remove "+num2str(NumNANsRemoved)+" start/end points and redistribute Stale PSO pulses over "+num2str(NumPointsFixed)+" points"
end 

////**********************************************************************************************************
////**********************************************************************************************************
////**********************************************************************************************************
Function IN3_LocateAndRemoveOscillations(AR_encoder,AR_PSOpulse,AR_angle)
	wave AR_encoder,AR_PSOpulse,AR_angle
	
	//just fix the AR_encoder to use PSO records
	//AR_encoder is angle vs PSO pulse as x coordinate
	//AR_angle is angle and PSO pulse is its PSO coordinate, this is sparse data set. 
	variable i, CurArVal,  curPnt, curEnc
	For(i=0;i<numpnts(AR_encoder);i+=1)
		curPnt = BinarySearchInterp(AR_PSOpulse, i )
		if(numtype(curPnt)==0)
			CurArVal = AR_angle[BinarySearchInterp(AR_PSOpulse, i )]
			curEnc = AR_encoder[i]
			//and fix the AR_encoder only if the value is different by mroe then "slopy" factor of 2e-5
			if(abs(AR_encoder[i]-CurArVal)>1e-5)
				AR_encoder[i] = CurArVal
			endif
		else
			AR_encoder[i] = nan
		endif
	endfor
	
	
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

//Function IN3_LocateAndRemoveOscillations(AR_encoder,AR_PSOpulse,AR_angle)
//	wave AR_encoder,AR_PSOpulse,AR_angle
//	
//	duplicate/Free AR_angle, DiffARValues, DiffARValuesNorm
//	DiffARValues[1,numpnts(DiffARValues)-2] = (AR_angle - Ar_encoder[AR_PSOpulse[p]])
//	DiffARValuesNorm[1,numpnts(DiffARValues)-2] = (AR_angle - Ar_encoder[AR_PSOpulse[p]])/(Ar_encoder[AR_PSOpulse[p]]-Ar_encoder[AR_PSOpulse[p]-1])
//	DiffARValues[0]=DiffARValues[1]
//	DiffARValuesNorm[0]=DiffARValuesNorm[1]
//	Duplicate/Free DiffARValuesNorm,DiffARValues_Smooth
//	Smooth/M=0 2, DiffARValues_Smooth
//	Differentiate/METH=2 DiffARValues_Smooth/D=DiffARValues_SMDIF
//	DiffARValues_SMDIF=DiffARValues_SMDIF[p]*(1-p/numpnts(DiffARValues_SMDIF))
//	DiffARValues_SMDIF*=-1		//convert minima to maxima...
//	WAVE/Z wx=$("_calculated_")
//	Variable/C estimates= EstPeakNoiseAndSmfact(DiffARValues_SMDIF,0, 0.5*numpnts(DiffARValues_SMDIF)-1)
//	Variable noiselevel=real(estimates)
//	Variable smoothingFactor=imag(estimates)
//	variable PeaksFound=IN3_AutoFindPeaksWorker(DiffARValues_SMDIF,wx , 0, numpnts(DiffARValues_SMDIF)-1, 100, 3, noiseLevel, smoothingFactor)
//	if(PeaksFound>0)
//		wave W_AutoPeakInfo
//		variable i, numPks, posPnt, StartPnt, EndPnt, MaxValue, WidthOfPeak
//		numPks = DimSize(W_AutoPeakInfo, 0)
//		//need to srort this since it seems not to come sorted...
//		make/O/N=(numPks) PeakPositionsWv, PeakWidthWv,MaxValueWv
//		PeakPositionsWv = W_AutoPeakInfo[p][0]
//		PeakWidthWv = W_AutoPeakInfo[p][1]
//		MaxValueWv = W_AutoPeakInfo[p][2]
//		sort PeakPositionsWv, PeakPositionsWv, PeakWidthWv,MaxValueWv
//		//clear up peaks too low (less then 0.5 MaxValue) 
//		For(i=0;i<numpnts(MaxValueWv);i+=1)
//			if(MaxValueWv[i]<0.5)
//				MaxValueWv[i]=Nan
//			endif
//		endfor
//		IN2G_RemoveNaNsFrom3Waves(PeakPositionsWv, PeakWidthWv,MaxValueWv)
//		numPks=numpnts(PeakPositionsWv)
//		if(numPks>0)
//			make/O/N=(numPks+1,3) RemoveInformation		//q=0 is average value before teh first point, q=1 is position of the first point, q=2 is position of the last point
//			// if q=1 = value of last point it's value till the end. 
//			RemoveInformation=0
//			variable priorAveStartP, NumPeaks
//			priorAveStartP = 2
//			NumPeaks=0
//			For(i=0;i<numPks;i+=1)
//				//locate the peaks start and end and create list of points to remove from 
//		//		print "Position"+num2str(W_AutoPeakInfo[i][0])
//		//		print "Width "+num2str(W_AutoPeakInfo[i][1])
//				MaxValue = MaxValueWv[i]
//				MaxValue = (MaxValue/20>0.5) ? (MaxValue/20>0.5) : 0.5
//				posPnt=PeakPositionsWv[i]
//				WidthOfPeak = PeakWidthWv[i]
//				StartPnt=floor(posPnt-1.3*PeakWidthWv[i])
//				EndPnt = ceil(posPnt+1.3*PeakWidthWv[i])
//			//	print "Height "+num2str(W_AutoPeakInfo[i][2])
//			//	FindPeak /B=2 /M=2/N/P/R=(StartPnt,EndPnt) DiffARValues_SMDIF
//				FindLevels /D=FIndLevelsPeak/Q /N=2 /P  /R=(StartPnt,EndPnt) DiffARValues_SMDIF, MaxValue
//				Wave FIndLevelsPeak
//				if (numpnts(FIndLevelsPeak)>1)
//					//print "Start p : "+num2str(floor(FIndLevelsPeak[0])) + "     End p : "+num2str(ceil(FIndLevelsPeak[1]))
//					RemoveInformation[i][1]	= AR_PSOpulse[floor(FIndLevelsPeak[0])]
//					RemoveInformation[i][2]	= AR_PSOpulse[ceil(FIndLevelsPeak[1])]
//					RemoveInformation[i][0]	= mean(DiffARValues , priorAveStartP, FIndLevelsPeak[0])
//					priorAveStartP = FIndLevelsPeak[1]+1
//					NumPeaks+=1
//				endif
//			endfor
//			RemoveInformation[NumPeaks][1]	= AR_PSOpulse(numpnts(AR_PSOpulse)-1)
//			RemoveInformation[NumPeaks][2]	= inf
//			RemoveInformation[NumPeaks][0]	= mean(DiffARValues , priorAveStartP, priorAveStartP+200)			//avoid end effects, seems to bomb at the end due to speed. 
//			print "Found following oscillations areas : line 0 - average offset before oscillation, line 1 start point, line 2 end point."
//			print RemoveInformation
//			IN3_FixTheOscilllations()
//			print "Attempted to remove the oscillations"
//			IN3_FailedPositionsFixedGraph()
//		else
//			print "NO osciallations found, no attempt to fix them" 
//			killwaves /Z RemoveInformation
//		endif
//	else
//		print "NO osciallations found, no attempt to fix them" 
//		killwaves /Z RemoveInformation
//	endif
//	KIllwaves/Z DiffARValues_SMDIF, RemoveInformation, W_AutoPeakInfo, FIndLevelsPeak, PeakPositionsWv, PeakWidthWv,MaxValueWv
//	KIllwaves/Z WA_PeakCentersY,WA_PeakCentersX
//end
	
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IN3_AutoFindPeaksWorker(w, wx, pBegin, pEnd, maxPeaks, minPeakPercent, noiseLevel, smoothingFactor)
	WAVE w
	WAVE/Z wx
	Variable pBegin, pEnd
	Variable maxPeaks, minPeakPercent, noiseLevel, smoothingFactor
	
	Variable peaksFound= AutoFindPeaks(w,pBegin,pEnd,noiseLevel,smoothingFactor,maxPeaks)
	if( peaksFound > 0 )
		WAVE W_AutoPeakInfo
		// Remove too-small peaks
		peaksFound= TrimAmpAutoPeakInfo(W_AutoPeakInfo,minPeakPercent/100)
		if( peaksFound > 0 )
			// Make waves to display in a graph
			// The x values in W_AutoPeakInfo are still actually points, not X
			Make/O/N=(peaksFound) WA_PeakCentersY = w[W_AutoPeakInfo[p][0]]
			AdjustAutoPeakInfoForX(W_AutoPeakInfo,w,wx)
			Make/O/N=(peaksFound) WA_PeakCentersX = W_AutoPeakInfo[p][0]
		endif
	endif
	if( peaksFound < 1 )
		return 0
	endif
	return peaksFound
End
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IN3_FailedPositionsFixedGraph() : Graph
	PauseUpdate; Silent 1		// building window...
	wave MeasTime
	wave Ar_encoder
	Display/K=1 /W=(640,52,1250,753) MeasTime vs Ar_encoder
	ModifyGraph log=1
	SetAxis left 266169.802796858,26038485.0119416
	SetAxis bottom 10.895,10.914
EndMacro

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IN3_FixTheOscilllations()
	//uses information from prior code which finds oscillations and removes them.
	Wave MeasTime
	Wave Monitor
	Wave USAXS_PD
	Wave PD_range
	Wave I0gain
	wave AR_PSOpulse
	wave AR_angle
	Wave/Z RemoveInformation
	variable shiftARPSOpulse
	if(WaveExists(RemoveInformation))
		Wave Ar_encoder	
		Variable i, StartARshift, StartRemoval, EndRemoval, ShiftArBy
		StartARshift = 0
		For(i=0;i<dimsize(RemoveInformation,0);i+=1)
			if(RemoveInformation[i][1]>0)		//seems to get some errors with lines containing only 0
				StartRemoval= RemoveInformation[i][1]
				EndRemoval=RemoveInformation[i][2]
				ShiftArBy=RemoveInformation[i][0]
				Ar_encoder[StartARshift,StartRemoval-1]+=ShiftArBy		//?????
				if(numtype(EndRemoval)==0)
					shiftARPSOpulse= BinarySearch(AR_PSOpulse, EndRemoval)		//this fixes the PSO record
					AR_PSOpulse[shiftARPSOpulse,numpnts(AR_PSOpulse)-1] -= EndRemoval - StartRemoval
					Ar_encoder[StartRemoval,1.4*EndRemoval]=NaN
				endif
				StartARshift=EndRemoval+1
			endif
		endfor
		IN2G_RemoveNaNsFrom6Waves(MeasTime,Monitor,USAXS_PD,PD_range,I0gain,Ar_encoder)
	else
	//	print "Nothing to fix here"
	endif
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
	
//Function IN3_FSCreateGainWave(GainWv,ampGainReq,ampGain,mcsChangePnts, TimeRangeAfter, MeasTime)
//	wave GainWv,ampGainReq,ampGain,mcsChangePnts, TimeRangeAfter, MeasTime 
//	
//	GainWv = ampGain[0]
//	variable iii, iiimax=numpnts(mcsChangePnts)-1
//	variable StartRc, EndRc
//	if(iiimax<1)		//Fix for scanning when no range changes happen... 
//		GainWv = 4
//	endif
//	StartRc = NaN
//	EndRc = 0
//	For(iii=0;iii<iiimax;iii+=1)
//		if(mcsChangePnts[iii]>0 || (iii>0 && iii<3) )
//			if(ampGain[iii]!=ampGainReq[iii])
//				StartRc = mcsChangePnts[iii]
//			endif
//			if(ampGain[iii]==ampGainReq[iii])
//				EndRc = mcsChangePnts[iii]
//				if((EndRc<numpnts(GainWv)-1)&&(numtype(StartRc)==0))
//					GainWv[StartRc,EndRc] = nan
//					GainWv[EndRc+1,] = ampGain[iii]+1
//					IN3_MaskPointsForGivenTime(GainWv,MeasTime,EndRc+1, TimeRangeAfter[ampGain[iii]])
//				endif
//			endif
//		endif
//	endfor
//end

Function IN3_FSCreateGainWave(GainWv,ampGainReq,ampGain,mcsChangePnts, TimeRangeAfter, MeasTime)
	wave GainWv,ampGainReq,ampGain,mcsChangePnts, TimeRangeAfter, MeasTime 
	//creates amplfier gains for upd or I0/I00 from mcs channel records
	Duplicate/Free mcsChangePnts, tmpmcsChangePnts
	Duplicate/Free ampGainReq, tmpampGainReq
	Duplicate/Free ampGain, tmpampGain
	variable i
	i = numpnts(tmpmcsChangePnts)-1
	Do		//this simply removes any tailing change points in teh records, whichscrew up the working code
		if(tmpmcsChangePnts[i]==0)
			tmpmcsChangePnts[i]=nan
		else
			break
		endif
		i-=1
	while (i>0 && tmpmcsChangePnts[i] <1)
	//this blasts on these 3 waves any lines, which contain NaN in any of the three waves. 
	IN2G_RemoveNaNsFrom3Waves(tmpmcsChangePnts,tmpampGainReq,tmpampGain)
	//set Gains to first point on record
	GainWv = tmpampGain[0]
	variable iii, iiimax=numpnts(tmpmcsChangePnts)-1
	variable StartRc, EndRc
	if(iiimax<1)		//Fix for scanning when no range changes happen... 
		GainWv = tmpampGain[0]	//this seem unnecessary... hm, it was here before. 
	else
		StartRc = 0
		EndRc = 0
		For(iii=0;iii<iiimax+1;iii+=1)		//find points when we requested ranege change and when we got it, record and deal with it
			if(tmpampGain[iii]!=tmpampGainReq[iii])		//requested gain change
				StartRc = tmpmcsChangePnts[iii]	
			elseif(tmpampGain[iii]==tmpampGainReq[iii])	//got the requested range cahnge, from here we should have the gains set
				EndRc = tmpmcsChangePnts[iii]
					if((EndRc<numpnts(GainWv)-1)&&(numtype(StartRc)==0))
						GainWv[StartRc,EndRc] = nan	//while we were changing, set points to NaNs 
						GainWv[EndRc+1,] = ampGain[iii]+1	//set rest fo teh measured points to the gain we set
						IN3_MaskPointsForGivenTime(GainWv,MeasTime,EndRc+1, TimeRangeAfter[ampGain[iii]])	//mask for time, if needed. 
					endif			
			endif
		endfor
	endif

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//
//Function IN3_FSCreateGainWave(GainWv,ampGainReq,ampGain,mcsChangePnts, TimeRangeAfter, MeasTime)
//	wave GainWv,ampGainReq,ampGain,mcsChangePnts, TimeRangeAfter, MeasTime 
//	
//	GainWv = ampGain[0]
//	variable iii, iiimax=numpnts(mcsChangePnts)-1
//	variable StartRc, EndRc
//	if(iiimax<1)		//Fix for scanning when no range changes happen... 
//		GainWv = 4
//	endif
//	ampGainReq[0] = ampGain[0]
//	StartRc = 0
//	EndRc = 0
//	For(iii=0;iii<iiimax;iii+=1)
//		if(mcsChangePnts[iii]>0 ||  iii<3 )
//			if(ampGain[iii]!=ampGainReq[iii])
//				StartRc = mcsChangePnts[iii]
//			endif
//			if(ampGain[iii]==ampGainReq[iii])
//				EndRc = mcsChangePnts[iii]
//				if((EndRc<numpnts(GainWv)-1))
//					GainWv[StartRc,EndRc] = nan
//					GainWv[EndRc+1,] = ampGain[iii]+1
//					IN3_MaskPointsForGivenTime(GainWv,MeasTime,EndRc+1, TimeRangeAfter[ampGain[iii]])
//				endif
//			endif
//		endif
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

//**********************************************************************************************************
//**********************************************************************************************************
//Function IN3_FlyScanRebinData(WvX, WvTime, Wv2, Wv3, Wv4,Wv5,NumberOfPoints, MinStep)
//	wave WvX, WvTime, Wv2, Wv3, Wv4, Wv5
//	variable NumberOfPoints, MinStep
//	//	IN3_FlyScanRebinData(Ar_encoder, MeasTime, Monitor, USAXS_PD, PD_range,NumberOfTempPoints)
//	//note, WvX, Wv4 (pd_range), and WvTime is averages, but others are full time (no avergaing).... also, do not count if Wv3 are Nans
//	string OldDf
//	variable OldNumPnts=numpnts(WvX)
//	if(OldNumPnts<NumberOfPoints)
//		print "User requested rebinning of data, but old number of points is less than requested point number, no rebinning done"
//		return 0
//	endif
//	variable StartX, EndX, iii, isGrowing, CorrectStart, logStartX, logEndX
//	CorrectStart = WvX[0]
//	StartX = IN2G_FindCorrectStart(WvX[0],WvX[numpnts(WvX)-1],NumberOfPoints,MinStep)
//	EndX = StartX +abs(WvX[numpnts(WvX)-1] -  WvX[0])
//	//Log rebinning, if requested.... 
//	//create log distribution of points...
//	isGrowing = (WvX[0] < WvX[numpnts(WvX)-1]) ? 1 : 0
//	make/O/D/FREE/N=(NumberOfPoints) tempNewLogDist, tempNewLogDistBinWidth
//	logstartX=log(startX)
//	logendX=log(endX)
//	tempNewLogDist = logstartX + p*(logendX-logstartX)/numpnts(tempNewLogDist)
//	tempNewLogDist = 10^(tempNewLogDist)
//	startX = tempNewLogDist[0]
//	tempNewLogDist += CorrectStart - StartX
//	
//	redimension/N=(numpnts(tempNewLogDist)+1) tempNewLogDist
//	tempNewLogDist[numpnts(tempNewLogDist)-1]=2*tempNewLogDist[numpnts(tempNewLogDist)-2]-tempNewLogDist[numpnts(tempNewLogDist)-3]
//	tempNewLogDistBinWidth = tempNewLogDist[p+1] - tempNewLogDist[p]
//	make/O/D/FREE/N=(NumberOfPoints) Rebinned_WvX, Rebinned_WvTime, Rebinned_Wv2,Rebinned_Wv3, Rebinned_Wv4, Rebinned_Wv5
//	Rebinned_WvTime=0
//	Rebinned_Wv2=0	
//	Rebinned_Wv3=0	
//	Rebinned_Wv4=0	
//	Rebinned_Wv5=0	
//	variable i, j	//, startIntg=TempQ[1]-TempQ[0]
//	//first assume that we can step through this easily...
//	variable cntPoints, BinHighEdge
//	//variable i will be from 0 to number of new points, moving through destination waves
//	j=0		//this variable goes through data to be reduced, therefore it goes from 0 to numpnts(TempInt)
//	For(i=0;i<NumberOfPoints;i+=1)
//		cntPoints=0
//		BinHighEdge = tempNewLogDist[i]+tempNewLogDistBinWidth[i]/2
//		if(isGrowing)
//			Do
//				if(numtype(Wv3[j])==0)
//					Rebinned_WvX[i] += WvX[j]
//					Rebinned_WvTime[i]+=WvTime[j]
//					Rebinned_Wv2[i]+=Wv2[j]
//					Rebinned_Wv3[i] += Wv3[j]
//					Rebinned_Wv4[i] += Wv4[j]
//					Rebinned_Wv5[i] += Wv5[j]
//					cntPoints+=1
//				endif
//				j+=1
//			While(WvX[j-1]<BinHighEdge && j<OldNumPnts)
//		else
//			Do
//				if(numtype(Wv3[j])==0)
//					Rebinned_WvX[i] += WvX[j]
//					Rebinned_WvTime[i]+=WvTime[j]
//					Rebinned_Wv2[i]+=Wv2[j]
//					Rebinned_Wv3[i] += Wv3[j]
//					Rebinned_Wv4[i] += Wv4[j]
//					Rebinned_Wv5[i] += Wv5[j]
//					cntPoints+=1
//				endif
//				j+=1
//			While((WvX[j-1]>BinHighEdge) && (j<OldNumPnts))
//		endif
//		Rebinned_WvTime[i]/=cntPoints		//need average time per exposure for background subtraction... 
//		//Rebinned_Wv2[i]/=cntPoints
//		//Rebinned_Wv3[i]/=cntPoints
//		Rebinned_Wv4[i]/=cntPoints
//		Rebinned_WvX[i]/=cntPoints
//		Rebinned_Wv5[i]/=cntPoints
//	endfor
//	
//	Redimension/N=(numpnts(Rebinned_WvX))/D WvX, WvTime, Wv2, Wv3, Wv4, Wv5
//	WvX=Rebinned_WvX
//	WvTime=Rebinned_WvTime
//	Wv2=Rebinned_Wv2
//	Wv3=Rebinned_Wv3
//	Wv4=Rebinned_Wv4
//	Wv5=Rebinned_Wv5
//		
//end
//

//************************************************************************************************************
//************************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//Function IN3_FlyScanRebinData2(WvX, Wv1, Wv2,NumberOfPoints)
//	wave WvX, Wv1, Wv2
//	variable NumberOfPoints
//	//assume W2 is error!!!!
//	string OldDf
//	variable OldNumPnts=numpnts(WvX)
//	if(OldNumPnts<NumberOfPoints)
//		print "User requeseted rebinning of data, but old number of points is less than requested point number, no rebinning done"
//		return 0
//	endif
//	//Log rebinning, if requested.... 
//	//create log distribution of points...
//	make/O/D/FREE/N=(NumberOfPoints) tempNewLogDist, tempNewLogDistBinWidth
//	variable StartX, EndX, iii, isGrowing
//	isGrowing = (WvX[0] < WvX[numpnts(WvX)-1]) ? 1 : 0
//	startX=log(WvX[0])
//	endX=log(WvX[numpnts(WvX)-1])
//	tempNewLogDist = startX + p*(endX-startX)/numpnts(tempNewLogDist)
//	tempNewLogDist = 10^(tempNewLogDist)
//	redimension/N=(numpnts(tempNewLogDist)+1) tempNewLogDist
//	tempNewLogDist[numpnts(tempNewLogDist)-1]=2*tempNewLogDist[numpnts(tempNewLogDist)-2]-tempNewLogDist[numpnts(tempNewLogDist)-3]
//	tempNewLogDistBinWidth = tempNewLogDist[p+1] - tempNewLogDist[p]
//	make/O/D/FREE/N=(NumberOfPoints) Rebinned_WvX, Rebinned_Wv1, Rebinned_Wv2
//	Rebinned_Wv1=0
//	Rebinned_Wv2=0	
//	variable i, j	//, startIntg=TempQ[1]-TempQ[0]
//	//first assume that we can step through this easily...
//	variable cntPoints, BinHighEdge
//	//variable i will be from 0 to number of new points, moving through destination waves
//	j=0		//this variable goes through data to be reduced, therefore it goes from 0 to numpnts(TempInt)
//	For(i=0;i<NumberOfPoints;i+=1)
//		cntPoints=0
//		BinHighEdge = tempNewLogDist[i]+tempNewLogDistBinWidth[i]/2
//		if(isGrowing)
//			Do
//				Rebinned_Wv1[i]+=Wv1[j]
//				Rebinned_Wv2[i]+=(Wv2[j])^2		//sum of squares
//				Rebinned_WvX[i] += WvX[j]
//				cntPoints+=1
//				j+=1
//			While(WvX[j-1]<BinHighEdge && j<OldNumPnts)
//		else
//			Do
//				Rebinned_Wv1[i]+=Wv1[j]
//				Rebinned_Wv2[i]+=(Wv2[j])^2		//sum of squares
//				Rebinned_WvX[i] += WvX[j]
//				cntPoints+=1
//				j+=1
//			While(WvX[j-1]>BinHighEdge && j<OldNumPnts)
//		endif
//		Rebinned_Wv1[i]/=cntPoints
//		Rebinned_Wv2[i]/=cntPoints		
//		Rebinned_Wv2[i]=sqrt(Rebinned_Wv2[i])		//this is standard deviation
//		Rebinned_Wv2[i]/=sqrt(cntPoints)			//and this makes is SEM - standard error of mean
//		Rebinned_WvX[i]/=cntPoints
//		if(j>=OldNumPnts-1)
//			break
//		endif
//	endfor	
//	Redimension/N=(numpnts(Rebinned_WvX))/D WvX, Wv1, Wv2
//	WvX=Rebinned_WvX
//	Wv1=Rebinned_Wv1
//	Wv2=Rebinned_Wv2		
//end
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
	PopupMenu SelectTempNumPoints,mode=(1+WhichListItem(num2str(NumberOfTempPoints), "5000;10000;20000;")),value= "5000;10000;20000;"

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
	
	ListOfStrings = "DataPathString;DataExtension;SelectedFileName;NewDataFolderName;NameMatchString;RemoveFromNameString;"

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
		NumberOfTempPoints=5000
	endif
	Make/O/T/N=0 WaveOfFiles
	Make/O/N=0 WaveOfSelections

end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
