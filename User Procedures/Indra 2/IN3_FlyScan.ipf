#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=0.1
Constant IN3_FlyImportVersionNumber=0.1
//FlyScan data reduction
Constant AmplifierPreRage1BlockTime=0.09
Constant AmplifierPreRage2BlockTime=0.12
Constant AmplifierPreRage3BlockTime=0.13
Constant AmplifierPreRage4BlockTime=0.16
Constant AmplifierRange1BlockTime=0.02
Constant AmplifierRange2BlockTime=0.04
Constant AmplifierRange3BlockTime=0.04
Constant AmplifierRange4BlockTime=0.25

//version 0.1 developement of import functions and GUIs



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
	UpdatePanelVersionNumber("IN3_FlyScanImportPanel", IN3_FlyImportVersionNumber)

end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IN3_FlyScanCheckVersion()	
	DoWindow IN3_FlyScanImportPanel
	if(V_Flag)
		if(!CheckPanelVersionNumber("IN3_FlyScanImportPanel", IN3_FlyImportVersionNumber))
			DoAlert /T="The Fly Scan Import panel was created by old version of Nika " 1, "FlyScan Import needs to be restarted to work properly. Restart now?"
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
	Button SelectAll,pos={7,395},size={100,20},proc=IN3_FlyScanButtonProc,title="Select All"
	Button SelectAll,help={"Select all waves in the list"}
	Button DeSelectAll,pos={120,395},size={100,20},proc=IN3_FlyScanButtonProc,title="Deselect All"
	Button DeSelectAll,help={"Deselect all waves in the list"}
	Button OpenFileInBrowser,pos={7,440},size={100,30},proc=IN3_FlyScanButtonProc,title="Open in Browser"
	Button OpenFileInBrowser,help={"Check file in HDF5 Browser"}
	Button ImportData,pos={120,440},size={100,30},proc=IN3_FlyScanButtonProc,title="Import"
	Button ImportData,help={"Import the selected data files."}
	Button ConfigureBehavior,pos={240,395},size={100,20},proc=IN3_FlyScanButtonProc,title="Configure"
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
	
	variable NumSelFiles=sum(WaveOfSelections)	
	variable OpenMultipleFiles=0
	if(NumSelFiles==0)
		return 0
	endif	
	variable i, Overwrite
	string FileName, ListOfExistingFolders
	String browserName, shortFileName, RawFolderWithData
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
			HDF5OpenFile/R /P=USAXSHDFPath locFileID as FileName
			if (V_flag == 0)					// Open OK?
				HDf5Browser#UpdateAfterFileCreateOrOpen(0, browserName, locFileID, S_path, S_fileName)
			endif
			HDf5Browser#LoadGroupButtonProc("LoadGroup")
	
			HDf5Browser#CloseFileButtonProc("CloseFIle")
	
			KillWindow $(browserName)
			RawFolderWithData = GetDataFOlder(1)+shortFileName
			print "Imported HDF5 file : "+RawFolderWithData
			IN3_FSConvertToUSAXS(RawFolderWithData)
			print "Converted : "+RawFolderWithData+" into USAXS data"
		endif
	endfor
	setDataFolder OldDf
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IN3_FSConvertToUSAXS(RawFolderWithData)
	string RawFolderWithData
	
	string OldDf=GetDataFolder(1)
	setDataFolder RawFolderWithData
	//here we need to deal with hdf5 data
	//spec file name
	string SpecFileName
	Wave/T SpecFileNameWv=:entry:metadata:SPEC_data_file
	SpecFileName=SpecFileNameWv[0]
	SpecFileName=stringFromList(0,SpecFileName,".")
	//wave data to locate
	Wave TimeWv=:entry:flyScan:mca1
	Wave I0Wv=:entry:flyScan:mca2
	Wave updWv=:entry:flyScan:mca3
	Wave GainWv=:entry:flyScan:mca4
	Duplicate/Free TimeWv, ArValues
	Redimension /D ArValues
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
	//here we copy data to new place
	newDataFolder/O/S root:USAXS
	newDataFolder/O/S $(SpecFileName)
	string FileName, ListOfExistingFolders
	FileName=StringFromList(ItemsInList(RawFolderWithData ,":")-1, RawFolderWithData,  ":")
	ListOfExistingFolders = DataFolderDir(1)
		if(StringMatch(ListOfExistingFolders, "*,"+FileName+",*" ))
			DoAlert /T="Non unique name alert..." 1, "USAXS Folder with "+FileName+" name already found, Overwrite?" 
			if(V_Flag!=1)
				return 0
			endif	
		endif
 	newDataFolder/O/S $(FileName)
	Duplicate/O TimeWv, MeasTime
	Duplicate/O I0Wv, Monitor
	Duplicate/O updWv, USAXS_PD
	Duplicate/O GainWv, PD_range
	ArValues = Ar_start[0] - Ar_increment[0]*p
	Duplicate/O ArValues, Ar_encoder
	
	//need to appedn the wave notes...
	//DATAFILE=12_09_flyusaxs2.dat;EPOCH=1386631536;TZ=-6;SCAN_N=15;SECONDS=3469455865;DATE=Mon, Dec 9, 2013;HOUR=17:44:25
	//COMMENT=PS_spheres_1_3um;SpecCommand=uascan  ar 17.8217 17.8206 14.5895 2e-05  26.2812 793 -0.1 189 1 600 0.333333;
	//SpecComment=PS_spheres_1_3um;SpecScan=spec15;USAXSDataFolder=root:USAXS:'12_09_flyusaxs2':S15_PS_spheres_1_3um
	//;RawFolder=root:raw:'12_09_flyusaxs2':spec15:;UserSampleName=S15_PS_spheres_1_3um;Wname=AR_encoder;
	string WaveNote
	WaveNote="DATAFILE="+SpecFileNameWv[0]+";DATE="+TimeW[0]+";COMMENT="+SampleNameW[0]+";SpecCommand="+"flyScan  ar 17.8217 17.8206 14.5895 2e-05  26.2812 "+num2str(SDDW[0])+" -0.1 "+num2str(SADW[0])+" "+num2str(SampleThicknessW[0])+" 100 1"
	WaveNote+=";SpecComment="+SampleNameW[0]+";"
	note/K MeasTime, WaveNote
	note/K Monitor, WaveNote
	note/K USAXS_PD, WaveNote
	note/K PD_range, WaveNote
	note/K Ar_encoder, WaveNote
	
	redimension/D Ar_encoder, MeasTime, Monitor, USAXS_PD, PD_range
	PD_range = PD_range/MeasTime
	PD_range = round(PD_range*500)+1
	MeasTime*=2e-08		//convert to seconds
	//Need to shift Ar_encoder by something to get really log scale rebinning... Cannot be negative, so need to calculate some small offset 
	//now we need to mask off the bad points... 
	IN3_FlyScanMaskGainChanges(Ar_encoder, MeasTime, Monitor, USAXS_PD, PD_range)
	variable ArOffset, scanningDown
	scanningDown = (Ar_encoder[0] > Ar_encoder[1]) ? 1 : 0
	if(scanningDown)	//scanning down in angle
		ArOffset = Ar_encoder[0] - (Ar_encoder[10]-Ar_encoder[0])
		Ar_encoder -= ArOffset
		Ar_encoder = abs(Ar_encoder)
	else		//scanning up in angle
		ArOffset = Ar_encoder[0] + (Ar_encoder[10]-Ar_encoder[0])
		Ar_encoder -= ArOffset
	endif
	NVAR NumberOfTempPoints = root:Packages:USAXS_FlyScanImport:NumberOfTempPoints
	IN3_FlyScanRebinData(Ar_encoder, MeasTime, Monitor, USAXS_PD, PD_range,NumberOfTempPoints)
	Ar_encoder +=ArOffset
	//put AR on regular angular scale...
	//fix cases when PD_range is not integer, if they are still there...
	PD_range[] = (PD_range[p]-floor(PD_range[p])==0) ? PD_range : nan
	IN2G_RemoveNaNsFrom5Waves(Ar_encoder, MeasTime, Monitor, USAXS_PD, PD_range)
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
	//DCM_energy=10.5;UPD2mode=2;UPD2range=4;UPD2vfc=100000;UPD2gain=1000000000000;UPD2selected=1;
	//UPD2gain1=10000;UPD2bkg1=2;UPD2bkgErr1=0;UPD2gain2=1000000;UPD2bkg2=2;UPD2bkgErr2=0;
	//UPD2gain3=100000000;UPD2bkg3=2;UPD2bkgErr3=0;UPD2gain4=10000000000;UPD2bkg4=182.4;UPD2bkgErr4=4.77493;
	//UPD2gain5=1000000000000;UPD2bkg5=17440.4;UPD2bkgErr5=824.622;thickness=1;ARenc_0=17.8206;SAD=189;
	//SDD=793;CCD_DX=0;CCD_DY=44.5;DIODE_DX=64.9087;DIODE_DY=26.2812;UATERM=1;USAXSPinT_Measure=0
	//USAXSPinT_AyPosition=11.1724;USAXSPinT_Time=3;USAXSPinT_pinCounts=0;USAXSPinT_pinGain=0;USAXSPinT_I0Counts=0;USAXSPinT_I0Gain=0;
	//
	MeasurementParameters="DCM_energy="+num2str(DCM_energyW[0])+";SAD="+num2str(SADW[0])+";SDD="+num2str(SDDW[0])+";thickness="+num2str(SampleThicknessW[0])+";"
	MeasurementParameters+=";I0AmpDark=;I0AmpGain="+num2str(I0GainW[0])+";I00AmpGain="+num2str(I00GainW[0])+";"
	MeasurementParameters+="Vfc=100000;Gain1="+num2str(updG1[0])+";Gain2="+num2str(updG2[0])+";Gain3="+num2str(updG3[0])+";Gain4="+num2str(updG4[0])+";Gain5="+num2str(updG5[0])
	MeasurementParameters+=";Bkg1="+num2str(updBkg1[0])+";Bkg2="+num2str(updBkg2[0])+";Bkg3="+num2str(updBkg3[0])+";Bkg4="+num2str(updBkg4[0])+";Bkg5="+num2str(updBkg5[0])
	MeasurementParameters+=";Bkg1Err="+num2str(updBkgErr1[0])+";Bkg2Err="+num2str(updBkgErr2[0])+";Bkg3Err="+num2str(updBkgErr3[0])+";Bkg4Err="+num2str(updBkgErr4[0])+";Bkg5Err="+num2str(updBkgErr5[0])
	
	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IN3_FlyScanMaskGainChanges(Ar_encoder, MeasTime, Monitor, USAXS_PD, PD_range)
	wave Ar_encoder, MeasTime, Monitor, USAXS_PD, PD_range
	
	make/Free/N=5 TimeRangeAfter, TimeRangeBefore
	TimeRangeBefore={AmplifierPreRage1BlockTime,AmplifierPreRage2BlockTime,AmplifierPreRage3BlockTime,AmplifierPreRage4BlockTime,0}
	TimeRangeAfter = {AmplifierRange1BlockTime,AmplifierRange2BlockTime,AmplifierRange3BlockTime,AmplifierRange4BlockTime,0}
	variable NumPntsW=numpnts(MeasTime)
	Differentiate/METH=1  PD_range /D=GainChanges
	GainChanges = abs(GainChanges)
	//contains 0 where gain does not change and 1 where the gain changes... 
	variable i, curGain, maskTime, j, maskTimeUp
	For(i=0;i<numpnts(PD_range);i+=1)
		if(GainChanges[i]>0)
			//OK, the gain is being just changed
			curGain = PD_range[i]
			curGain = (curGain<6) ? curGain : 5
			maskTime = TimeRangeAfter[curGain-1]
			maskTimeUp = TimeRangeBefore[curGain-1]
			USAXS_PD[i]=nan
			j=1
			Do
				USAXS_PD[i+j]=nan
				maskTime -=MeasTime[i+j]
				j+=1
			 while ((maskTime>0)&&((i+j)<NumPntsW))
			j=1
			Do
				USAXS_PD[i-j]=nan
				maskTimeUp -=MeasTime[i-j]
				j+=1
			 while (maskTimeUp>0&&((i-j)>=0))
		endif
	
	endfor
	IN2G_RemoveNaNsFrom5Waves(Ar_encoder, MeasTime, Monitor, USAXS_PD, PD_range)
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IN3_FlyScanRebinData(WvX, WvTime, Wv2, Wv3, Wv4,NumberOfPoints)
	wave WvX, WvTime, Wv2, Wv3, Wv4
	variable NumberOfPoints
	//note, Wv2, Wv3, Wv4 are averages, but Time is full time (no avergaing).... 
	string OldDf
	variable OldNumPnts=numpnts(WvX)
	if(OldNumPnts<NumberOfPoints)
		print "User requested rebinning of data, but old number of points is less than requested point number, no rebinning done"
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
	make/O/D/FREE/N=(NumberOfPoints) Rebinned_WvX, Rebinned_WvTime, Rebinned_Wv2,Rebinned_Wv3, Rebinned_Wv4
	Rebinned_WvTime=0
	Rebinned_Wv2=0	
	Rebinned_Wv3=0	
	Rebinned_Wv4=0	
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
				Rebinned_WvX[i] += WvX[j]
				Rebinned_WvTime[i]+=WvTime[j]
				Rebinned_Wv2[i]+=Wv2[j]
				Rebinned_Wv3[i] += Wv3[j]
				Rebinned_Wv4[i] += Wv4[j]
				cntPoints+=1
				j+=1
			While(WvX[j-1]<BinHighEdge && j<OldNumPnts)
		else
			Do
				Rebinned_WvX[i] += WvX[j]
				Rebinned_WvTime[i]+=WvTime[j]
				Rebinned_Wv2[i]+=Wv2[j]
				Rebinned_Wv3[i] += Wv3[j]
				Rebinned_Wv4[i] += Wv4[j]
				cntPoints+=1
				j+=1
			While((WvX[j-1]>BinHighEdge) && (j<OldNumPnts))
		endif
		Rebinned_WvTime[i]/=cntPoints		//need average time per exposure for backgground subtraction... 
		Rebinned_Wv2[i]/=cntPoints
		Rebinned_Wv3[i]/=cntPoints
		Rebinned_Wv4[i]/=cntPoints
		Rebinned_WvX[i]/=cntPoints
	endfor
	
	Redimension/N=(numpnts(Rebinned_WvX))/D WvX, WvTime, Wv2, Wv3, Wv4
	WvX=Rebinned_WvX
	WvTime=Rebinned_WvTime
	Wv2=Rebinned_Wv2
	Wv3=Rebinned_Wv3
	Wv4=Rebinned_Wv4
		
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
//	ListOfStrings+="NewQWaveName;NewErrorWaveName;NewQErrorWavename;;TooManyPointsWarning;RemoveStringFromName;"
	ListOfVariables = "NumberOfOutputPoints;DoubleClickImports;DoubleClickOpensInBrowser;NumberOfTempPoints;"
//	ListOfVariables += "CreateSQRTErrors;Col1Int;Col1Qvec;Col1Err;Col1QErr;FoundNWaves;"	
//	ListOfVariables += "Col2Int;Col2Qvec;Col2Err;Col2QErr;Col3Int;Col3Qvec;Col3Err;Col3QErr;Col4Int;Col4Qvec;Col4Err;Col4QErr;"	
//	ListOfVariables += "Col5Int;Col5Qvec;Col5Err;Col5QErr;Col6Int;Col6Qvec;Col6Err;Col6QErr;Col7Int;Col7Qvec;Col7Err;Col7QErr;"	
//	ListOfVariables += "QvectInA;QvectInNM;CreateSQRTErrors;CreatePercentErrors;PercentErrorsToUse;"
//	ListOfVariables += "ScaleImportedData;ScaleImportedDataBy;ImportSMRdata;SkipLines;SkipNumberOfLines;"	
//	ListOfVariables += "IncludeExtensionInName;RemoveNegativeIntensities;AutomaticallyOverwrite;"	
//	ListOfVariables += "TrimData;TrimDataQMin;TrimDataQMax;ReduceNumPnts;TargetNumberOfPoints;ReducePntsParam;"	
//	ListOfVariables += "NumOfPointsFound;TrunkateStart;TrunkateEnd;"	
//	ListOfVariables += "DataCalibratedArbitrary;DataCalibratedVolume;DataCalibratedWeight;"	

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
