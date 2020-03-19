#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.1
constant IR3JversionNumber = 0.1			//Data merging panel version number

//*************************************************************************\
//* Copyright (c) 2005 - 2020, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.1 combined this ipf with "Simple fits models"
//1.0 Simple Fits tool first release version 



///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3J_SimpleFits()

	IN2G_CheckScreenSize("width",1200)
	DoWIndow IR3J_SimpleFitsPanel
	if(V_Flag)
		DoWindow/F IR3J_SimpleFitsPanel
	else
		IR3J_InitSimpleFits()
		IR1T_InitFormFactors()
		IR3J_SimpleFitsPanelFnct()
		ING2_AddScrollControl()
		IR1_UpdatePanelVersionNumber("IR3J_SimpleFitsPanel", IR3JversionNumber,1)
		IR3C_MultiUpdateListOfAvailFiles("root:Packages:Irena:SimpleFits")	
	endif
	IR3J_CreateCheckGraphs()
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR3J_SimpleFitsPanelFnct()
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,530,800) as "Multi Sample Fits"
	DoWIndow/C IR3J_SimpleFitsPanel
	TitleBox MainTitle title="Multi-Sample Simple Fits",pos={200,2},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fSize=22,fColor=(0,0,52224)
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena:SimpleFits","IR3J_SimpleFitsPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	IR3C_MultiAppendControls("Irena:SimpleFits","IR3J_SimpleFitsPanel", "IR3J_CopyAndAppendData",1,0)
	//hide what is not needed
	checkbox UseResults, disable=1
	SetVariable DataQEnd,pos={290,90},size={170,15}, proc=IR3J_SetVarProc,title="Q max for fitting    "
	Setvariable DataQEnd, variable=root:Packages:Irena:SimpleFits:DataQEnd, limits={-inf,inf,0}
	SetVariable DataQstart,pos={290,110},size={170,15}, proc=IR3J_SetVarProc,title="Q min for fitting     "
	Setvariable DataQstart, variable=root:Packages:Irena:SimpleFits:DataQstart, limits={-inf,inf,0}
	SetVariable DataBackground,pos={280,130},size={170,15}, proc=IR3J_SetVarProc,title="Background    "
	Setvariable DataBackground, variable=root:Packages:Irena:SimpleFits:DataBackground, limits={-inf,inf,0}

	PopupMenu SimpleModel,pos={280,175},size={200,20},fStyle=2,proc=IR3J_PopMenuProc,title="Model to fit : "
	SVAR SimpleModel = root:Packages:Irena:SimpleFits:SimpleModel
	PopupMenu SimpleModel,mode=1,popvalue=SimpleModel,value= #"root:Packages:Irena:SimpleFits:ListOfSimpleModels" 
	
	//Guinier controls
	SetVariable Guinier_I0,pos={240,230},size={220,15}, proc=IR3J_SetVarProc,title="Scaling I0  ", bodywidth=80
	Setvariable Guinier_I0, variable=root:Packages:Irena:SimpleFits:Guinier_I0, limits={1e-20,inf,0}, help={"Guinier prefactor I0"}
	SetVariable Guinier_Rg,pos={240,260},size={220,15}, proc=IR3J_SetVarProc,title="Rg [A] ", bodywidth=80
	Setvariable Guinier_Rg, variable=root:Packages:Irena:SimpleFits:Guinier_Rg, limits={3,inf,0}, help={"Guinier Rg value"}
	//Porod
	SetVariable Porod_Constant,pos={240,230},size={220,15}, proc=IR3J_SetVarProc,title="Porod Constant ", bodywidth=80
	Setvariable Porod_Constant, variable=root:Packages:Irena:SimpleFits:Porod_Constant, limits={1e-20,inf,0}, help={"Porod constant"}
	//Sphere controls
	SetVariable Sphere_ScalingConstant,pos={240,230},size={220,15}, proc=IR3J_SetVarProc,title="Scaling ", bodywidth=80
	Setvariable Sphere_ScalingConstant, variable=root:Packages:Irena:SimpleFits:Sphere_ScalingConstant, limits={1e-20,inf,0}, help={"Scaling prefactor, I0"}
	SetVariable Sphere_Radius,pos={240,260},size={220,15}, proc=IR3J_SetVarProc,title="Radius [A] ", bodywidth=80
	Setvariable Sphere_Radius, variable=root:Packages:Irena:SimpleFits:Sphere_Radius, limits={3,inf,0}, help={"Radius of a sphere"}

	//Guinier controls
	SetVariable Spheroid_ScalingConstant,pos={240,230},size={220,15}, proc=IR3J_SetVarProc,title="Scaling ", bodywidth=80
	Setvariable Spheroid_ScalingConstant, variable=root:Packages:Irena:SimpleFits:Spheroid_ScalingConstant, limits={1e-20,inf,0}, help={"Scaling constant"}
	SetVariable Spheroid_Radius,pos={240,260},size={220,15}, proc=IR3J_SetVarProc,title="Radius [A] ", bodywidth=80
	Setvariable Spheroid_Radius, variable=root:Packages:Irena:SimpleFits:Spheroid_Radius, limits={3,inf,0}, help={"Radius of particle, particle is R x R x Beta*R"}
	SetVariable Spheroid_Beta,pos={240,290},size={220,15}, proc=IR3J_SetVarProc,title="Beta (RxRxBR)", bodywidth=80
	Setvariable Spheroid_Beta, variable=root:Packages:Irena:SimpleFits:Spheroid_Beta, limits={0.001,1000,0}, help={"Particle aspect ratio, beta, particle is R x R x Beta*R"}


	SetVariable DataBackground,pos={240,320},size={220,15}, proc=IR3J_SetVarProc,title="Flat Background ", bodywidth=80
	Setvariable DataBackground, variable=root:Packages:Irena:SimpleFits:DataBackground, limits={-inf,inf,0}, help={"Flat background for scattering intensity"}



	Button FitCurrentDataSet,pos={280,450},size={180,20}, proc=IR3J_ButtonProc,title="Fit Current (one) Dataset", help={"Fit current data set"}
	SetVariable AchievedChiSquare,pos={270,480},size={220,15}, noproc,title="Achieved chi-square"
	Setvariable AchievedChiSquare, variable=root:Packages:Irena:SimpleFits:AchievedChiSquare, disable=2

	Button RecordCurrentresults,pos={280,530},size={180,20}, proc=IR3J_ButtonProc,title="Record results", help={"Record results in notebook and table"}
	Button FitSelectionDataSet,pos={280,560},size={180,20}, proc=IR3J_ButtonProc,title="Fit (All) Selected Data", help={"Fit all data selected in listbox"}

	Button GetTableWithResults,pos={280,590},size={180,20}, proc=IR3J_ButtonProc,title="Get Table With Results", help={"Open Table with results for current Model"}

	Button GetNotebookWithResults,pos={280,620},size={180,20}, proc=IR3J_ButtonProc,title="Get Notebook With Results", help={"Open Notebook with results for current Model"}

	Button DeleteOldResults,pos={280,690},size={180,20}, proc=IR3J_ButtonProc,title="Delete Existing Results", help={"Delete results for the current model"}, fColor=(34952,34952,34952)


//	Display /W=(521,10,1183,400) /HOST=# /N=LogLogDataDisplay
//	SetActiveSubwindow ##
//	//Display /W=(521,350,1183,410) /HOST=# /N=ResidualDataDisplay
//	//SetActiveSubwindow ##
//	Display /W=(521,410,1183,750) /HOST=# /N=LinearizedDataDisplay
//	SetActiveSubwindow ##
//	//SetWindow IR3J_LogLogDataDisplay, hook(SimpleFitsLogLog) = IR3J_GraphWindowHook

	TitleBox Instructions1 title="\Zr100Double click to add data to graph",size={330,15},pos={4,680},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions2 title="\Zr100Shift-click to select range of data",size={330,15},pos={4,695},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions3 title="\Zr100Ctrl/Cmd-click to select one data set",size={330,15},pos={4,710},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions4 title="\Zr100Regex for not contain: ^((?!string).)*$",size={330,15},pos={4,725},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions5 title="\Zr100Regex for contain:  string, two: str2.*str1",size={330,15},pos={4,740},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions6 title="\Zr100Regex for case independent:  (?i)string",size={330,15},pos={4,755},frame=0,fColor=(0,0,65535),labelBack=0
	
	//and fix which controls are displayed:
	
	IR3J_SetupControlsOnMainpanel()
end

//************************************************************************************************************
//************************************************************************************************************
Function IR3J_CreateCheckGraphs()
	
	variable exists1=0
	DoWIndow IR3J_LogLogDataDisplay
	if(V_Flag)
		DoWIndow/hide=? IR3J_LogLogDataDisplay
		if(V_Flag==2)
			DoWIndow/F IR3J_LogLogDataDisplay
		endif
	else
		Display /W=(521,10,1183,400)/K=1 /N=IR3J_LogLogDataDisplay
		ShowInfo/W=IR3J_LogLogDataDisplay
		exists1=1
	endif

	variable exists2=0
	DoWIndow IR3J_LinDataDisplay
	if(V_Flag)
		DoWIndow/hide=? IR3J_LinDataDisplay
		if(V_Flag==2)
			DoWIndow/F IR3J_LinDataDisplay
		endif
	else
		Display /W=(521,10,1183,400)/K=1 /N=IR3J_LinDataDisplay
		ShowInfo/W=IR3J_LinDataDisplay
		exists2=1
	endif
	
	if(exists1 || exists2)
		AutoPositionWindow/M=0/R=IR3J_SimpleFitsPanel IR3J_LogLogDataDisplay	
		AutoPositionWindow/M=1/R=IR3J_LogLogDataDisplay IR3J_LinDataDisplay	
	endif
end


//**********************************************************************************************************
//	ListOfVariables+="DataBackground;"
//	ListOfVariables+="Guinier_Rg;Guinier_I0;"
//	ListOfVariables+="ProcessManually;ProcessSequentially;OverwriteExistingData;AutosaveAfterProcessing;"
//	ListOfVariables+="DataQEnd;DataQstart;"
				//	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,148},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
				//	TitleBox FakeLine2 title=" ",fixedSize=1,size={330,3},pos={16,428},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
				//	TitleBox FakeLine3 title=" ",fixedSize=1,size={330,3},pos={16,512},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
				//	TitleBox FakeLine4 title=" ",fixedSize=1,size={330,3},pos={16,555},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
				//	TitleBox Info1 title="Modify data 1                            Modify Data 2",pos={36,325},frame=0,fstyle=1, fixedSize=1,size={350,20},fSize=12
				//	TitleBox FakeLine5 title=" ",fixedSize=1,size={330,3},pos={16,300},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
//	Button ProcessSaveData, pos={490,135}, size={20,500}, title="S\rA\rV\rE\r\rD\rA\rT\rA", proc=IR3D_MergeButtonProc, help={"Saves data which were automtaticaly processed already. "}, labelBack=(65535,60076,49151)
//	//TextBox/C/N=text1/O=90/A=MC "Save Data", TextBox/C/N=text1/A=MC "S\rA\rV\rE\r\rD\rA\rT\rA"
//
//	Checkbox ProcessTest, pos={520,30},size={76,14},title="Test mode", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessTest
//	Checkbox ProcessMerge, pos={520,50},size={76,14},title="Merge mode", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessMerge
//	Checkbox ProcessMerge2, pos={520,70},size={76,14},title="Merge 2 mode", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessMerge2
//
//	Checkbox ProcessManually, pos={650,30},size={76,14},title="Process individually", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessManually
//	Checkbox ProcessSequentially, pos={650,50},size={76,14},title="Process as sequence", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessSequentially
//
//	Checkbox AutosaveAfterProcessing, pos={780,30},size={76,14},title="Save Immediately", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:AutosaveAfterProcessing, disable=!root:Packages:Irena:SASDataMerging:ProcessManually
//	Checkbox OverwriteExistingData, pos={780,50},size={76,14},title="Overwrite existing data", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:OverwriteExistingData
//	TitleBox SavedDataMessage title="",fixedSize=1,size={100,17}, pos={780,70}, variable= root:Packages:Irena:SASDataMerging:SavedDataMessage
//	TitleBox SavedDataMessage help={"Are the data saved?"}, fColor=(65535,16385,16385), frame=0, fSize=12,fstyle=1
//
//	TitleBox UserMessage title="",fixedSize=1,size={470,20}, pos={480,90}, variable= root:Packages:Irena:SASDataMerging:UserMessageString
//	TitleBox UserMessage help={"This is what will happen"}
//
//		
//	Button AutoScale,pos={520,117},size={100,17}, proc=IR3D_MergeButtonProc,title="Test AutoScale", help={"Autoscales. Set cursors on data overlap and the data 2 will be scaled to Data 1 using integral intensity"}, disable=!root:Packages:Irena:SASDataMerging:ProcessTest
//	Button MergeData,pos={640,117},size={100,17}, proc=IR3D_MergeButtonProc,title="Test Merge", help={"Scales data 2 to data 1 and sets background for data 1 for merging. Sets checkboxes and trims. Saves data also"}, disable=!root:Packages:Irena:SASDataMerging:ProcessTest
//	SetVariable DataFolderName1,pos={550,625},size={510,15}, noproc,variable=root:Packages:Irena:SASDataMerging:DataFolderName1, title="Data 1:       ", disable=2
//	SetVariable DataFolderName2,pos={550,642},size={510,15}, noproc,variable=root:Packages:Irena:SASDataMerging:DataFolderName2, title="Data 2:       ", disable=2
//	SetVariable NewDataFolderName,pos={550,659},size={510,15}, noproc,variable=root:Packages:Irena:SASDataMerging:NewDataFolderName, title="Merged Data: "



//**********************************************************************************************************
//**********************************************************************************************************

Function IR3J_InitSimpleFits()	


	string oldDf=GetDataFolder(1)
	string ListOfVariables
	string ListOfStrings
	variable i
		
	if (!DataFolderExists("root:Packages:Irena:SimpleFits"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena
		NewDataFolder/O root:Packages:Irena:SimpleFits
	endif
	SetDataFolder root:Packages:Irena:SimpleFits					//go into the folder

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;DataUnits;"
	ListOfStrings+="DataStartFolder;DataMatchString;FolderSortString;FolderSortStringAll;"
	ListOfStrings+="UserMessageString;SavedDataMessage;"
	ListOfStrings+="SimpleModel;ListOfSimpleModels;"

	ListOfVariables="UseIndra2Data1;UseQRSdata1;"
	ListOfVariables+="DataBackground;AchievedChiSquare;"
	ListOfVariables+="Guinier_Rg;Guinier_I0;"
	ListOfVariables+="Porod_Constant;Sphere_Radius;Sphere_ScalingConstant;"
	ListOfVariables+="Spheroid_Radius;Spheroid_ScalingConstant;Spheroid_Beta;"
	ListOfVariables+="ProcessManually;ProcessSequentially;OverwriteExistingData;AutosaveAfterProcessing;"
	ListOfVariables+="DataQEnd;DataQstart;DataQEndPoint;DataQstartPoint;"

	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;"
//	ListOfStrings+="NewDataFolderName;NewIntensityWaveName;NewQWavename;NewErrorWaveName;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR teststr=$(StringFromList(i,ListOfStrings))
		teststr =""
	endfor		
	ListOfStrings="DataMatchString;FolderSortString;FolderSortStringAll;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR teststr=$(StringFromList(i,ListOfStrings))
		if(strlen(teststr)<1)
			teststr =""
		endif
	endfor		
	ListOfStrings="DataStartFolder;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR teststr=$(StringFromList(i,ListOfStrings))
		if(strlen(teststr)<1)
			teststr ="root:"
		endif
	endfor		
	SVAR ListOfSimpleModels
	ListOfSimpleModels="Guinier;Porod;Sphere;Spheroid;"
//	SVAR FolderSortStringAll
//	FolderSortStringAll = "Alphabetical;Reverse Alphabetical;_xyz;_xyz.ext;Reverse _xyz;Reverse _xyz.ext;Sxyz_;Reverse Sxyz_;_xyzmin;_xyzC;_xyzpct;_xyz_000;Reverse _xyz_000;"
	SVAR SimpleModel
	if(strlen(SimpleModel)<1)
		SimpleModel="Guinier"
	endif
	NVAR Guinier_Rg
	NVAR Guinier_I0
	if(Guinier_Rg<5)
		Guinier_Rg=50
	endif
	if(Guinier_I0<1e-22)
		Guinier_I0 = 10
	endif
	NVAR Porod_Constant
	if(Porod_Constant<1e-22)
		Porod_Constant = 1
	endif
	NVAR Sphere_Radius
	if(Sphere_Radius<5)
		Sphere_Radius = 50
	endif
	NVAR Sphere_ScalingConstant
	if(Sphere_ScalingConstant<1e-22)
		Sphere_ScalingConstant=1
	endif
	NVAR Spheroid_Radius
	if(Spheroid_Radius<5)
		Spheroid_Radius = 50
	endif
	NVAR Spheroid_ScalingConstant
	if(Spheroid_ScalingConstant<1e-22)
		Spheroid_ScalingConstant = 1
	endif
	NVAR Spheroid_Beta
	if(Spheroid_Beta<0.001)
		Spheroid_Beta = 1
	endif

	Make/O/T/N=(0) ListOfAvailableData
	Make/O/N=(0) SelectionOfAvailableData
	SetDataFolder oldDf

end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3J_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR UseIndra2Data =  root:Packages:Irena:SimpleFits:UseIndra2Data
			NVAR UseQRSData =  root:Packages:Irena:SimpleFits:UseQRSData
			SVAR DataStartFolder = root:Packages:Irena:SimpleFits:DataStartFolder
  		
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3J_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	variable tempP
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
			NVAR DataQstart=root:Packages:Irena:SimpleFits:DataQstart
			NVAR DataQEnd=root:Packages:Irena:SimpleFits:DataQEnd
			NVAR DataQEndPoint = root:Packages:Irena:SimpleFits:DataQEndPoint
			NVAR DataQstartPoint = root:Packages:Irena:SimpleFits:DataQstartPoint
			
			if(stringmatch(sva.ctrlName,"DataQEnd"))
				WAVE OriginalDataQWave = root:Packages:Irena:SimpleFits:OriginalDataQWave
				tempP = BinarySearch(OriginalDataQWave, DataQEnd )
				if(tempP<1)
					print "Wrong Q value set, Data Q max must be at most 1 point before the end of Data"
					tempP = numpnts(OriginalDataQWave)-2
					DataQEnd = OriginalDataQWave[tempP]
				endif
				DataQEndPoint = tempP			
				IR3J_SyncCursorsTogether("OriginalDataIntWave","B",tempP)
				IR3J_SyncCursorsTogether("LinModelDataIntWave","B",tempP)
			endif
			if(stringmatch(sva.ctrlName,"DataQstart"))
				WAVE OriginalDataQWave = root:Packages:Irena:SimpleFits:OriginalDataQWave
				tempP = BinarySearch(OriginalDataQWave, DataQstart )
				if(tempP<1)
					print "Wrong Q value set, Data Q min must be at least 1 point from the start of Data"
					tempP = 1
					DataQstart = OriginalDataQWave[tempP]
				endif
				DataQstartPoint=tempP
				IR3J_SyncCursorsTogether("OriginalDataIntWave","A",tempP)
				IR3J_SyncCursorsTogether("LinModelDataIntWave","A",tempP)
		endif
			break

		case 3: // live update
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//**************************************************************************************
//**************************************************************************************
Function IR3J_CopyAndAppendData(FolderNameStr)
	string FolderNameStr
	
	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena:SimpleFits					//go into the folder
	//IR3D_SetSavedNotSavedMessage(0)

		SVAR DataStartFolder=root:Packages:Irena:SimpleFits:DataStartFolder
		SVAR DataFolderName=root:Packages:Irena:SimpleFits:DataFolderName
		SVAR IntensityWaveName=root:Packages:Irena:SimpleFits:IntensityWaveName
		SVAR QWavename=root:Packages:Irena:SimpleFits:QWavename
		SVAR ErrorWaveName=root:Packages:Irena:SimpleFits:ErrorWaveName
		SVAR dQWavename=root:Packages:Irena:SimpleFits:dQWavename
		NVAR UseIndra2Data=root:Packages:Irena:SimpleFits:UseIndra2Data
		NVAR UseQRSdata=root:Packages:Irena:SimpleFits:UseQRSdata
		//these are variables used by the control procedure
		NVAR  UseResults=  root:Packages:Irena:SimpleFits:UseResults
		NVAR  UseUserDefinedData=  root:Packages:Irena:SimpleFits:UseUserDefinedData
		NVAR  UseModelData = root:Packages:Irena:SimpleFits:UseModelData
		SVAR DataFolderName  = root:Packages:Irena:SimpleFits:DataFolderName 
		SVAR IntensityWaveName = root:Packages:Irena:SimpleFits:IntensityWaveName
		SVAR QWavename = root:Packages:Irena:SimpleFits:QWavename
		SVAR ErrorWaveName = root:Packages:Irena:SimpleFits:ErrorWaveName
		UseResults = 0
		UseUserDefinedData = 0
		UseModelData = 0
		//get the names of waves, assume this tool actually works. May not under some conditions. In that case this tool will not work. 
		DataFolderName = DataStartFolder+FolderNameStr
		QWavename = stringFromList(0,IR2P_ListOfWaves("Xaxis","", "IR3J_SimpleFitsPanel"))
		IntensityWaveName = stringFromList(0,IR2P_ListOfWaves("Yaxis","*", "IR3J_SimpleFitsPanel"))
		ErrorWaveName = stringFromList(0,IR2P_ListOfWaves("Error","*", "IR3J_SimpleFitsPanel"))
		if(UseIndra2Data)
			dQWavename = ReplaceString("Qvec", QWavename, "dQ")
		elseif(UseQRSdata)
			dQWavename = "w"+QWavename[1,31]
		else
			dQWavename = ""
		endif
		Wave/Z SourceIntWv=$(DataFolderName+IntensityWaveName)
		Wave/Z SourceQWv=$(DataFolderName+QWavename)
		Wave/Z SourceErrorWv=$(DataFolderName+ErrorWaveName)
		Wave/Z SourcedQWv=$(DataFolderName+dQWavename)
		if(!WaveExists(SourceIntWv)||	!WaveExists(SourceQWv)||!WaveExists(SourceErrorWv))
			Abort "Data selection failed for Data 1"
		endif
		Duplicate/O SourceIntWv, OriginalDataIntWave
		Duplicate/O SourceQWv, OriginalDataQWave
		Duplicate/O SourceErrorWv, OriginalDataErrorWave
		if(WaveExists(SourcedQWv))
			Duplicate/O SourcedQWv, OriginalDatadQWave
		else
			dQWavename=""
		endif
		IR3J_CreateCheckGraphs()
		//clear obsolete data:
		Wave/Z NormRes1=root:Packages:Irena:SimpleFits:NormalizedResidualLinLin
		Wave/Z NormRes2=root:Packages:Irena:SimpleFits:NormalizedResidualLogLog
		if(WaveExists(NormRes1))
			NormRes1=0
		endif
		if(WaveExists(NormRes2))
			NormRes2=0
		endif
		RemoveFromGraph /W=IR3J_LogLogDataDisplay /Z NormalizedResidualLogLog
		RemoveFromGraph /W=IR3J_LinDataDisplay /Z NormalizedResidualLinLin
		//done cleaning... 
		DoWIndow IR3J_LogLogDataDisplay
		if(V_Flag)
			DoWIndow/F IR3J_LogLogDataDisplay
		endif
		DoWIndow IR3J_LinDataDisplay
		if(V_Flag)
			DoWIndow/F IR3J_LinDataDisplay
		endif
		pauseUpdate
		IR3J_AppendDataToGraphLogLog()
		IR3J_CreateLinearizedData()
		IR3J_AppendDataToGraphModel()
		DoUpdate
		print "Added Data from folder : "+DataFolderName
	SetDataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3J_CreateLinearizedData()

	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena:SimpleFits					//go into the folder
	Wave OriginalDataIntWave=root:Packages:Irena:SimpleFits:OriginalDataIntWave
	Wave OriginalDataQWave=root:Packages:Irena:SimpleFits:OriginalDataQWave
	Wave OriginalDataErrorWave=root:Packages:Irena:SimpleFits:OriginalDataErrorWave
	SVAR SimpleModel=root:Packages:Irena:SimpleFits:SimpleModel
	Duplicate/O OriginalDataIntWave, LinModelDataIntWave	///, ModelNormalizedResidual
	Duplicate/O OriginalDataQWave, LinModelDataQWave//, ModelNormResXWave
	Duplicate/O OriginalDataErrorWave, LinModelDataEWave
	if(stringmatch(SimpleModel,"Guinier"))
		LinModelDataIntWave = ln(OriginalDataIntWave)
		LinModelDataEWave = OriginalDataErrorWave/OriginalDataIntWave			//error propagation, see: https://terpconnect.umd.edu/~toh/models/ErrorPropagation.pdf
		LinModelDataQWave = OriginalDataQWave^2
	elseif(stringmatch(SimpleModel,"Porod"))
		LinModelDataIntWave = OriginalDataIntWave*OriginalDataQWave^4
		LinModelDataEWave = OriginalDataErrorWave*OriginalDataQWave^4			//error propagation, see: https://terpconnect.umd.edu/~toh/models/ErrorPropagation.pdf
		LinModelDataQWave = OriginalDataQWave^4
	elseif(stringmatch(SimpleModel,"Sphere"))
		LinModelDataIntWave = ln(OriginalDataIntWave)
		LinModelDataEWave = OriginalDataErrorWave/OriginalDataIntWave			//error propagation, see: https://terpconnect.umd.edu/~toh/models/ErrorPropagation.pdf
		LinModelDataQWave = OriginalDataQWave^2
	elseif(stringmatch(SimpleModel,"Spheroid"))
		LinModelDataIntWave = ln(OriginalDataIntWave)
		LinModelDataEWave = OriginalDataErrorWave/OriginalDataIntWave			//error propagation, see: https://terpconnect.umd.edu/~toh/models/ErrorPropagation.pdf
		LinModelDataQWave = OriginalDataQWave^2
	endif
	SetDataFolder oldDf
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************



Function IR3J_AppendDataToGraphModel()
	
	IR3J_CreateCheckGraphs()
	variable WhichLegend=0
	variable startQp, endQp, tmpStQ
	
	Wave LinModelDataIntWave=root:Packages:Irena:SimpleFits:LinModelDataIntWave
	Wave LinModelDataQWave=root:Packages:Irena:SimpleFits:LinModelDataQWave
	Wave LinModelDataEWave=root:Packages:Irena:SimpleFits:LinModelDataEWave
	CheckDisplayed /W=IR3J_LinDataDisplay LinModelDataIntWave
	if(!V_flag)
		AppendToGraph /W=IR3J_LinDataDisplay  LinModelDataIntWave  vs LinModelDataQWave
		ErrorBars /W=IR3J_LinDataDisplay LinModelDataIntWave Y,wave=(LinModelDataEWave,LinModelDataEWave)		
	endif
	NVAR DataQEnd = root:Packages:Irena:SimpleFits:DataQEnd
	NVAR DataQstart = root:Packages:Irena:SimpleFits:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:SimpleFits:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:SimpleFits:DataQstartPoint
	SetWindow IR3J_LinDataDisplay, hook(SimpleFitsLinCursorMoved) = $""
	cursor /W=IR3J_LinDataDisplay B, LinModelDataIntWave, DataQEndPoint
	cursor /W=IR3J_LinDataDisplay A, LinModelDataIntWave, DataQstartPoint
	SetWindow IR3J_LinDataDisplay, hook(SimpleFitsLinCursorMoved) = IR3J_GraphWindowHook
	variable tempMaxQ
	tempMaxQ = LinModelDataQWave[DataQEndPoint]
	SetAxis/W=IR3J_LinDataDisplay bottom 0,tempMaxQ*1.5
	SVAR SimpleModel = root:Packages:Irena:SimpleFits:SimpleModel
	strswitch(SimpleModel)	// string switch
		case "Guinier":			// execute if case matches expression
				ModifyGraph /W=IR3J_LinDataDisplay log=0, mirror(bottom)=1
				SetAxis/A/W=IR3J_LinDataDisplay 
				Label /W=IR3J_LinDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"ln(Intensity)"
				Label /W=IR3J_LinDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q\\S2\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"[A\\S-2\\M"+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
			break		// exit from switch
		case "Sphere":			// execute if case matches expression
				ModifyGraph /W=IR3J_LinDataDisplay log=0, mirror(bottom)=1
				SetAxis/A/W=IR3J_LinDataDisplay
				Label /W=IR3J_LinDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"ln(Intensity)"
				Label /W=IR3J_LinDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q\\S2\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"[A\\S-2\\M"+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
			break		// exit from switch
		case "Spheroid":			// execute if case matches expression
				ModifyGraph /W=IR3J_LinDataDisplay log=0, mirror(bottom)=1
				SetAxis/A/W=IR3J_LinDataDisplay
				Label /W=IR3J_LinDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"ln(Intensity)"
				Label /W=IR3J_LinDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q\\S2\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"[A\\S-2\\M"+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
			break		// exit from switch
		case "Porod":	// execute if case matches expression
				ModifyGraph /W=IR3J_LinDataDisplay log=0, mirror(bottom)=1
				SetAxis/A/W=IR3J_LinDataDisplay
				SetAxis/W=IR3J_LinDataDisplay left 0,*
				Label /W=IR3J_LinDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Int * Q\\S4"
				Label /W=IR3J_LinDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q\\S4\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"[A\\S-4\\M"+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
			break
		default:			// optional default expression executed
			//<code>]		// when no case matches
	endswitch

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


Function IR3J_AppendDataToGraphLogLog()
	
	IR3J_CreateCheckGraphs()
	variable WhichLegend=0
	Wave OriginalDataIntWave=root:Packages:Irena:SimpleFits:OriginalDataIntWave
	Wave OriginalDataQWave=root:Packages:Irena:SimpleFits:OriginalDataQWave
	Wave OriginalDataErrorWave=root:Packages:Irena:SimpleFits:OriginalDataErrorWave
	CheckDisplayed /W=IR3J_LogLogDataDisplay OriginalDataIntWave
	if(!V_flag)
		AppendToGraph /W=IR3J_LogLogDataDisplay  OriginalDataIntWave  vs OriginalDataQWave
		ModifyGraph /W=IR3J_LogLogDataDisplay log=1, mirror(bottom)=1
		Label /W=IR3J_LogLogDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity"
		Label /W=IR3J_LogLogDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q[A\\S-1\\M"+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
		ErrorBars /W=IR3J_LogLogDataDisplay OriginalDataIntWave Y,wave=(OriginalDataErrorWave,OriginalDataErrorWave)		
	endif
	NVAR DataQEnd = root:Packages:Irena:SimpleFits:DataQEnd
	NVAR DataQstart = root:Packages:Irena:SimpleFits:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:SimpleFits:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:SimpleFits:DataQstartPoint
	if(DataQstart>0)	 		//old Q min already set.
		DataQstartPoint = BinarySearch(OriginalDataQWave, DataQstart)
	endif
	if(DataQstartPoint<1)	//Qmin not set or not found. Set to point 2 on that wave. 
		DataQstart = OriginalDataQWave[1]
		DataQstartPoint = 1
	endif
	if(DataQEnd>0)	 		//old Q max already set.
		DataQEndPoint = BinarySearch(OriginalDataQWave, DataQEnd)
	endif
	if(DataQEndPoint<1)	//Qmax not set or not found. Set to last point-1 on that wave. 
		DataQEnd = OriginalDataQWave[numpnts(OriginalDataQWave)-2]
		DataQEndPoint = numpnts(OriginalDataQWave)-2
	endif
	SetWindow IR3J_LogLogDataDisplay, hook(SimpleFitsLogCursorMoved) = $""
	cursor /W=IR3J_LogLogDataDisplay B, OriginalDataIntWave, DataQEndPoint
	cursor /W=IR3J_LogLogDataDisplay A, OriginalDataIntWave, DataQstartPoint
	SetWindow IR3J_LogLogDataDisplay, hook(SimpleFitsLogCursorMoved) = IR3J_GraphWindowHook

	
	switch(V_Flag)	// numeric switch
		case 0:		// execute if case matches expression
			Legend/W=IR3J_LogLogDataDisplay /N=text0/K
			break						// exit from switch
//		case 1:		// execute if case matches expression
//			SVAR DataFolderName=root:Packages:Irena:SimpleFits:DataFolderName
//			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
//			Legend/W=IR3J_LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1
//			break
//		case 2:
//			SVAR DataFolderName=root:Packages:Irena:SimpleFits:DataFolderName
//			Shortname2 = StringFromList(ItemsInList(DataFolderName2, ":")-1, DataFolderName2  ,":")
//			Legend/W=IR3J_LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData2IntWave) " + Shortname2		
//			break
//		case 3:
//			SVAR DataFolderName=root:Packages:Irena:SimpleFits:DataFolderName
//			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
//			Legend/W=IR3J_LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2
//			break
//		case 7:
//			SVAR DataFolderName=root:Packages:Irena:SimpleFits:DataFolderName
//			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
//			Legend/W=IR3J_LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2+"\r\\s(ResultIntensity) Merged Data"
			break
	endswitch

	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3J_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"FitCurrentDataSet"))
				IR3J_FitData()
			endif
			if(stringmatch(ba.ctrlName,"RecordCurrentresults"))
				IR3J_SaveResultsToNotebook()
				IR3J_SaveResultsToWaves()
			endif
			if(stringmatch(ba.ctrlName,"FitSelectionDataSet"))
				IR3J_FitSequenceOfData()
			endif
			if(stringmatch(ba.ctrlName,"GetTableWithResults"))
				IR3J_GetTableWithresults()	
			endif
			if(stringmatch(ba.ctrlName,"DeleteOldResults"))
				IR3J_DeleteExistingModelResults()	
			endif
			if(stringmatch(ba.ctrlName,"GetNotebookWithResults"))
				IR1_CreateResultsNbk()
			endif


			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


//	Display /W=(521,10,1183,340) /HOST=# /N=LogLogDataDisplay
//	SetActiveSubwindow ##
//	Display /W=(521,420,1183,750) /HOST=# /N=LinearizedDataDisplay
//	SetActiveSubwindow ##
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3J_FitData()

	SVAR SimpleModel = root:Packages:Irena:SimpleFits:SimpleModel
	strswitch(SimpleModel)	// string switch
		case "Guinier":	// execute if case matches expression
			IR3J_FitGuinier()
			IR3J_CalculateModel()		
			break		// exit from switch
		case "Porod":	// execute if case matches expression
			IR3J_FitPorod()
			IR3J_CalculateModel()		
			break
		case "Sphere":	// execute if case matches expression
			IR3J_FitSphere()
			IR3J_CalculateModel()		
			break
		case "Spheroid":	// execute if case matches expression
			IR3J_FitSpheroid()
			IR3J_CalculateModel()		
			break
		default:			// optional default expression executed
	endswitch

end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3J_FitSequenceOfData()

		Wave SelectionOfAvailableData = root:Packages:Irena:SimpleFits:SelectionOfAvailableData
		Wave/T ListOfAvailableData = root:Packages:Irena:SimpleFits:ListOfAvailableData
		variable i, imax
		imax = numpnts(ListOfAvailableData)
		For(i=0;i<imax;i+=1)
			if(SelectionOfAvailableData[i]>0.5)		//data set selected
				IR3J_CopyAndAppendData(ListOfAvailableData[i])
				IR3J_FitData()
				IR3J_SaveResultsToNotebook()
				IR3J_SaveResultsToWaves()
				DoUpdate 
				sleep/S/C=6/M="Fitted data for "+ListOfAvailableData[i] 2
			endif
		endfor
		print "all selected data processed"
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3J_GraphWindowHook(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0

	switch(s.eventCode)
		case 0:				// Activate
			// Handle activate
			break

		case 1:				// Deactivate
			// Handle deactivate
			break
		case 7:				//coursor moved
//			print "Cursor moved" 
//			print s.winName 
//			print s.cursorName
//			print s.pointNumber
			IR3J_SyncCursorsTogether(s.traceName,s.cursorName,s.pointNumber)
			hookResult = 1
		// And so on . . .
	endswitch

	return hookResult	// 0 if nothing done, else 1
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3J_SyncCursorsTogether(traceName,CursorName,PointNumber)
	string traceName,CursorName
	variable PointNumber

	IR3J_CreateCheckGraphs()
	NVAR DataQEnd = root:Packages:Irena:SimpleFits:DataQEnd
	NVAR DataQstart = root:Packages:Irena:SimpleFits:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:SimpleFits:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:SimpleFits:DataQstartPoint
	Wave OriginalDataQWave=root:Packages:Irena:SimpleFits:OriginalDataQWave
	Wave LinModelDataIntWave=root:Packages:Irena:SimpleFits:LinModelDataIntWave
	Wave OriginalDataIntWave=root:Packages:Irena:SimpleFits:OriginalDataIntWave
	Wave LinModelDataQWave=root:Packages:Irena:SimpleFits:LinModelDataQWave
	variable tempMaxQ, tempMaxQY, tempMinQY
	
	//check if user removed cursor from graph, in which case do nothing for now...
	if(numtype(PointNumber)==0)
		if(stringmatch(CursorName,"A"))		//moved cursor A, which is start of Q range
			DataQstartPoint = PointNumber
			DataQstart = OriginalDataQWave[PointNumber]
			//now move the cursor in the other graph... 
			if(StringMatch(traceName, "OriginalDataIntWave" ))
				checkDisplayed /W=IR3J_LinDataDisplay LinModelDataIntWave
				if(V_Flag)
					cursor /W=IR3J_LinDataDisplay A, LinModelDataIntWave, DataQstartPoint
				endif
			elseif(StringMatch(traceName, "LinModelDataIntWave" ))
				checkDisplayed /W=IR3J_LogLogDataDisplay OriginalDataIntWave
				if(V_Flag)
					cursor /W=IR3J_LogLogDataDisplay A, OriginalDataIntWave, DataQstartPoint
				endif
			endif
		endif
		if(stringmatch(CursorName,"B"))		//moved cursor B, which is end of Q range
			DataQEndPoint = PointNumber
			DataQEnd = OriginalDataQWave[PointNumber]
			//now move the cursor in the other graph... 
			if(StringMatch(traceName, "OriginalDataIntWave" ))
				checkDisplayed /W=IR3J_LinDataDisplay LinModelDataIntWave
				if(V_Flag)
					cursor /W=IR3J_LinDataDisplay B, LinModelDataIntWave, DataQEndPoint
					tempMaxQ = LinModelDataQWave[DataQEndPoint]
					SetAxis/W=IR3J_LinDataDisplay bottom 0,tempMaxQ*1.5
					tempMaxQY = 0.8*LinModelDataIntWave[DataQstartPoint]
					tempMinQY = 1.2*LinModelDataIntWave[DataQEndPoint]
					//SetAxis/W=IR3J_LinDataDisplay left 0.5*tempMinQY,tempMaxQY*1.5
					SetAxis/W=IR3J_LinDataDisplay left tempMinQY, tempMaxQY
				endif
			elseif(StringMatch(traceName, "LinModelDataIntWave" ))
				checkDisplayed /W=IR3J_LogLogDataDisplay OriginalDataIntWave
				if(V_Flag)
					cursor /W=IR3J_LogLogDataDisplay B, OriginalDataIntWave, DataQEndPoint
				endif
			endif
		endif
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3J_FitGuinier()

	IR3J_CreateCheckGraphs()
	DFref oldDf= GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:SimpleFits					//go into the folder
	NVAR DataQEnd = root:Packages:Irena:SimpleFits:DataQEnd
	NVAR DataQstart = root:Packages:Irena:SimpleFits:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:SimpleFits:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:SimpleFits:DataQstartPoint
	NVAR Guinier_I0 = root:Packages:Irena:SimpleFits:Guinier_I0
	NVAR Guinier_Rg=root:Packages:Irena:SimpleFits:Guinier_Rg
	NVAR AchievedChiSquare=root:Packages:Irena:SimpleFits:AchievedChiSquare
	Make/D/N=0/O W_coef, LocalEwave
	Make/D/T/N=0/O T_Constraints
	Wave/Z W_sigma
	Redimension /N=2 W_coef, LocalEwave
	Redimension/N=2 T_Constraints
	Wave/Z CursorAWave = CsrWaveRef(A, "IR3J_LogLogDataDisplay")
	Wave/Z CursorBWave = CsrWaveRef(B, "IR3J_LogLogDataDisplay")
	Wave CursorAXWave= CsrXWaveRef(A, "IR3J_LogLogDataDisplay")
	Wave OriginalDataErrorWave=root:Packages:Irena:SimpleFits:OriginalDataErrorWave
	if(!WaveExists(CursorAWave)||!WaveExists(CursorBWave))
		Abort "Cursors are not properly set on same wave"
	endif
	//make a good starting guesses:
	Guinier_I0 = CursorAXWave[DataQstartPoint]
	Guinier_Rg = pi/(DataQEnd/2)
	
	W_coef[0]=Guinier_I0  	//G
	W_coef[1]=Guinier_Rg		//Rg

	T_Constraints[0] = {"K1 > "+num2str(Guinier_Rg/10)}
	T_Constraints[1] = {"K0 > 0"}

	LocalEwave[0]=(Guinier_I0/20)
	LocalEwave[1]=(Guinier_Rg/20)
	variable/g V_FitError
	V_FitError=0			//This should prevent errors from being generated
	//if (FitUseErrors && WaveExists(ErrorWave))
	FuncFit IR1_GuinierFit W_coef CursorAWave[DataQstartPoint,DataQEndPoint] /X=CursorAXWave /D /C=T_Constraints /W=OriginalDataErrorWave /I=1
	//		else
	//FuncFit IR1_GuinierFit W_coef CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D /C=T_Constraints 
	//	endif
	if (V_FitError!=0)	//there was error in fitting
		RemoveFromGraph $("fit_"+NameOfWave(CursorAWave))
		beep
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	Wave W_sigma
	string TagText
	TagText = "Fitted Guinier  "+"Int = G*exp(-q^2*Rg^2/3))"+" \r G = "+num2str(W_coef[0])+"\r Rg = "+num2str(W_coef[1])
	//if (FitUseErrors && WaveExists(ErrorWave))
	TagText+="\r chi-square = "+num2str(V_chisq)
	//endif
	string TagName= "GuinierFit" //UniqueName("GuinierFit",14,0,"IR3J_LogLogDataDisplay")
	Tag/C/W=IR3J_LogLogDataDisplay/N=$(TagName)/L=2/X=-15.00/Y=-15.00  $NameOfWave(CursorAWave), ((DataQstartPoint + DataQEndPoint)/2),TagText	
		
	Guinier_I0=W_coef[0] 	//G
	Guinier_Rg=W_coef[1]	//Rg

	SetDataFolder oldDf

end

//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3J_FitPorod()
	
	IR3J_CreateCheckGraphs()
	DFref oldDf= GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:SimpleFits					//go into the folder
	NVAR DataQEnd = root:Packages:Irena:SimpleFits:DataQEnd
	NVAR DataQstart = root:Packages:Irena:SimpleFits:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:SimpleFits:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:SimpleFits:DataQstartPoint
	NVAR Porod_Constant = root:Packages:Irena:SimpleFits:Porod_Constant
	NVAR DataBackground=root:Packages:Irena:SimpleFits:DataBackground
	NVAR AchievedChiSquare=root:Packages:Irena:SimpleFits:AchievedChiSquare
	Make/D/N=0/O W_coef, LocalEwave
	Make/D/T/N=0/O T_Constraints
	Wave/Z W_sigma
	Redimension /N=2 W_coef, LocalEwave
	Redimension/N=1 T_Constraints
	T_Constraints[0] = {"K1 > 0"}
	W_coef = {Porod_Constant,DataBackground}
	Wave/Z CursorAWave = CsrWaveRef(A, "IR3J_LogLogDataDisplay")
	Wave/Z CursorBWave = CsrWaveRef(B, "IR3J_LogLogDataDisplay")
	Wave CursorAXWave= CsrXWaveRef(A, "IR3J_LogLogDataDisplay")
	Wave OriginalDataErrorWave=root:Packages:Irena:SimpleFits:OriginalDataErrorWave
	if(!WaveExists(CursorAWave)||!WaveExists(CursorBWave))
		Abort "Cursors are not properly set on same wave"
	endif
	//make a good starting guesses:
	Porod_Constant=CursorAWave[DataQstartPoint]/(CursorAXWave[DataQstartPoint]^(-4))
	DataBackground=CursorAwave[DataQEndPoint]
	
	LocalEwave[0]=(Porod_Constant/20)
	LocalEwave[1]=(DataBackground/20)

	variable/g V_FitError=0			//This should prevent errors from being generated
//		if (FitUseErrors && WaveExists(ErrorWave))
	FuncFit PorodInLogLog W_coef CursorAWave[DataQstartPoint,DataQEndPoint] /X=CursorAXWave /D /C=T_Constraints /W=OriginalDataErrorWave /I=1
//		else
//			FuncFit PorodInLogLog W_coef CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D /C=T_Constraints			
//		endif
	if (V_FitError!=0)	//there was error in fitting
		RemoveFromGraph $("fit_"+NameOfWave(CursorAWave))
		beep
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	Wave W_sigma
	string TagText
	TagText = "Fitted Porod  "+"Int = PC * Q^(-4) + background"+" \r PC = "+num2str(W_coef[0])+"\r Background = "+num2str(W_coef[1])
	TagText+="\r chi-square = "+num2str(V_chisq)
	string TagName= "PorodFit" 
	Tag/C/W=IR3J_LogLogDataDisplay/N=$(TagName)/L=2/X=-15.00/Y=-15.00  $NameOfWave(CursorAWave), ((DataQstartPoint + DataQEndPoint)/2),TagText	
	Porod_Constant=W_coef[0] 	//PC
	DataBackground=W_coef[1]	//Background
	SetDataFolder oldDf

end

//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3J_FitSphere()
	
	IR3J_CreateCheckGraphs()
	DFref oldDf= GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:SimpleFits					//go into the folder
	NVAR DataQEnd = root:Packages:Irena:SimpleFits:DataQEnd
	NVAR DataQstart = root:Packages:Irena:SimpleFits:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:SimpleFits:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:SimpleFits:DataQstartPoint
	NVAR SphereRadius = root:Packages:Irena:SimpleFits:Sphere_Radius
	NVAR SphereScalingConst = root:Packages:Irena:SimpleFits:Sphere_ScalingConstant
	NVAR DataBackground=root:Packages:Irena:SimpleFits:DataBackground
	NVAR AchievedChiSquare=root:Packages:Irena:SimpleFits:AchievedChiSquare
	Make/D/N=0/O W_coef, LocalEwave
	Make/D/T/N=0/O T_Constraints
	Wave/Z W_sigma
	Redimension /N=3 W_coef, LocalEwave
	Redimension/N=2 T_Constraints
	T_Constraints[0] = {"K0 > 0"}
	T_Constraints[1] = {"K1 > 3"}
	W_coef = {SphereScalingConst, SphereRadius,DataBackground}
	Wave/Z CursorAWave = CsrWaveRef(A, "IR3J_LogLogDataDisplay")
	Wave/Z CursorBWave = CsrWaveRef(B, "IR3J_LogLogDataDisplay")
	Wave CursorAXWave= CsrXWaveRef(A, "IR3J_LogLogDataDisplay")
	Wave OriginalDataErrorWave=root:Packages:Irena:SimpleFits:OriginalDataErrorWave
	if(!WaveExists(CursorAWave)||!WaveExists(CursorBWave))
		Abort "Cursors are not properly set on same wave"
	endif
	//make a good starting guesses:
	SphereScalingConst=CursorAWave[DataQstartPoint]
	SphereRadius=2*pi/CursorAWave[DataQstartPoint]
	DataBackground=0.05*CursorAwave[DataQEndPoint]
	
	LocalEwave[0]=(SphereScalingConst/20)
	LocalEwave[1]=(SphereRadius/20)
	LocalEwave[2]=(DataBackground/20)

	variable/g V_FitError=0			//This should prevent errors from being generated
//		if (FitUseErrors && WaveExists(ErrorWave))
	FuncFit IR3J_SphereFormfactor W_coef CursorAWave[DataQstartPoint,DataQEndPoint] /X=CursorAXWave /D /C=T_Constraints /W=OriginalDataErrorWave /I=1
//		else
//			FuncFit PorodInLogLog W_coef CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D /C=T_Constraints			
//		endif
	if (V_FitError!=0)	//there was error in fitting
		RemoveFromGraph $("fit_"+NameOfWave(CursorAWave))
		beep
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	Wave W_sigma
	string TagText
	TagText = "Fitted Sphere Form Factor   \r"+"Int=Scale*3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))+bck"+" \r Radius [A] = "+num2str(W_coef[1])+" \r Scale = "+num2str(W_coef[0])+"\r Background = "+num2str(W_coef[2])
	TagText+="\r chi-square = "+num2str(V_chisq)
	string TagName= "SphereFit" 
	Tag/C/W=IR3J_LogLogDataDisplay/N=$(TagName)/L=2/X=-15.00/Y=-15.00  $NameOfWave(CursorAWave), ((DataQstartPoint + DataQEndPoint)/2),TagText	
	SphereScalingConst=W_coef[0] 	//PC
	SphereRadius=W_coef[1]	//Radius
	DataBackground=W_coef[2]	//Background
	SetDataFolder oldDf

end

//**********************************************************************************************************
//**********************************************************************************************************
Function IR3J_SphereFormfactor(w,Q) : FitFunc
	Wave w
	Variable Q

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(Q) = ScalingParameter * BesJ(QR) + Background
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ Q
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = ScalingParameter
	//CurveFitDialog/ w[1] = Radius
	//CurveFitDialog/ w[2] = Background

	variable QR=Q*w[1]

	return w[0] * (3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR))) + w[2]
End

//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3J_FitSpheroid()
	
	IR3J_CreateCheckGraphs()
	DFref oldDf= GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:SimpleFits					//go into the folder
	NVAR DataQEnd = root:Packages:Irena:SimpleFits:DataQEnd
	NVAR DataQstart = root:Packages:Irena:SimpleFits:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:SimpleFits:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:SimpleFits:DataQstartPoint
	NVAR Spheroid_Beta = root:Packages:Irena:SimpleFits:Spheroid_Beta
	NVAR Spheroid_Radius = root:Packages:Irena:SimpleFits:Spheroid_Radius
	NVAR Spheroid_ScalingConstant = root:Packages:Irena:SimpleFits:Spheroid_ScalingConstant
	NVAR DataBackground=root:Packages:Irena:SimpleFits:DataBackground
	NVAR AchievedChiSquare=root:Packages:Irena:SimpleFits:AchievedChiSquare
	Make/D/N=0/O W_coef, LocalEwave
	Make/D/T/N=0/O T_Constraints
	Wave/Z W_sigma
	Redimension /N=4 W_coef, LocalEwave
	Redimension/N=4 T_Constraints
	T_Constraints[0] = {"K0 > 0"}
	T_Constraints[1] = {"K1 > 3"}
	T_Constraints[2] = {"K2 < 10"}
	T_Constraints[3] = {"K2 > 0.1"}
	W_coef = {Spheroid_ScalingConstant, Spheroid_Radius,Spheroid_Beta, DataBackground}
	Wave/Z CursorAWave = CsrWaveRef(A, "IR3J_LogLogDataDisplay")
	Wave/Z CursorBWave = CsrWaveRef(B, "IR3J_LogLogDataDisplay")
	Wave CursorAXWave= CsrXWaveRef(A, "IR3J_LogLogDataDisplay")
	Wave OriginalDataErrorWave=root:Packages:Irena:SimpleFits:OriginalDataErrorWave
	if(!WaveExists(CursorAWave)||!WaveExists(CursorBWave))
		Abort "Cursors are not properly set on same wave"
	endif
	//make a good starting guesses:
	Spheroid_ScalingConstant=CursorAWave[DataQstartPoint]
	Spheroid_Radius=2*pi/CursorAWave[DataQstartPoint]
	DataBackground=0.05*CursorAwave[DataQEndPoint]
	Spheroid_Beta = 1
	
	LocalEwave[0]=(Spheroid_ScalingConstant/20)
	LocalEwave[1]=(Spheroid_Radius/20)
	LocalEwave[2]=(1/20)
	LocalEwave[3]=(DataBackground/20)

	variable/g V_FitError=0			//This should prevent errors from being generated
//		if (FitUseErrors && WaveExists(ErrorWave))
	FuncFit IR3J_SpheroidFormfactor W_coef CursorAWave[DataQstartPoint,DataQEndPoint] /X=CursorAXWave /D /C=T_Constraints /W=OriginalDataErrorWave /I=1
//		else
//			FuncFit PorodInLogLog W_coef CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D /C=T_Constraints			
//		endif
	if (V_FitError!=0)	//there was error in fitting
		RemoveFromGraph $("fit_"+NameOfWave(CursorAWave))
		beep
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	Wave W_sigma
	string TagText
	TagText = "Fitted Spheroid Form Factor   \r"+"Int=Scale*SpheroidFF(Q,R,beta)+bck"+" \r Radius [A] = "+num2str(W_coef[1])+" \r Aspect ratio = "+num2str(W_coef[2])+" \r Scale = "+num2str(W_coef[0])+"\r Background = "+num2str(W_coef[3])
	TagText+="\r chi-square = "+num2str(V_chisq)
	string TagName= "SpheroidFit" 
	Tag/C/W=IR3J_LogLogDataDisplay/N=$(TagName)/L=2/X=-15.00/Y=-15.00  $NameOfWave(CursorAWave), ((DataQstartPoint + DataQEndPoint)/2),TagText	
	Spheroid_ScalingConstant	=W_coef[0] 	//scale
	Spheroid_Radius				=W_coef[1]	//Radius
	Spheroid_Beta				=W_coef[2]	//beta
	DataBackground				=W_coef[3]	//Background
	SetDataFolder oldDf

end
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3J_SpheroidFormfactor(w,Q) : FitFunc
	Wave w
	Variable Q

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(Q) = ScalingParameter * SpheroidFF(Q, R, beta) + Background
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ Q
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = ScalingParameter
	//CurveFitDialog/ w[1] = Radius
	//CurveFitDialog/ w[2] = Beta - aspect ratio
	//CurveFitDialog/ w[3] = Background

	return w[0]*IR1T_CalcIntgSpheroidFFPoints(Q,w[1],w[2])+ w[3]
End




//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function IR3J_CalculateModel()

	IR3J_CreateCheckGraphs()
	DFref oldDf= GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:SimpleFits					//go into the folder
	NVAR DataQEnd = root:Packages:Irena:SimpleFits:DataQEnd
	NVAR DataQstart = root:Packages:Irena:SimpleFits:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:SimpleFits:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:SimpleFits:DataQstartPoint
	Wave OriginalDataIntWave		=root:Packages:Irena:SimpleFits:OriginalDataIntWave
	Wave OriginalDataQWave		=root:Packages:Irena:SimpleFits:OriginalDataQWave
	Wave OriginalDataErrorWave	=root:Packages:Irena:SimpleFits:OriginalDataErrorWave
	Wave LinModelDataIntWave		=root:Packages:Irena:SimpleFits:LinModelDataIntWave
	Wave LinModelDataQWave		=root:Packages:Irena:SimpleFits:LinModelDataQWave
	Wave LinModelDataEWave		=root:Packages:Irena:SimpleFits:LinModelDataEWave
	NVAR AchievedChiSquare		=root:Packages:Irena:SimpleFits:AchievedChiSquare
	NVAR Guinier_I0 				= root:Packages:Irena:SimpleFits:Guinier_I0
	NVAR Guinier_Rg					=root:Packages:Irena:SimpleFits:Guinier_Rg
	NVAR Porod_Constant			=root:Packages:Irena:SimpleFits:Porod_Constant
	NVAR Sphere_Radius				=root:Packages:Irena:SimpleFits:Sphere_Radius
	NVAR Sphere_ScalingConstant	=root:Packages:Irena:SimpleFits:Sphere_ScalingConstant
	NVAR Spheroid_Radius			=root:Packages:Irena:SimpleFits:Spheroid_Radius
	NVAR Spheroid_ScalingConstant=root:Packages:Irena:SimpleFits:Spheroid_ScalingConstant
	NVAR Spheroid_Beta				=root:Packages:Irena:SimpleFits:Spheroid_Beta
	NVAR DataBackground			=root:Packages:Irena:SimpleFits:DataBackground
	SVAR SimpleModel 				= root:Packages:Irena:SimpleFits:SimpleModel

	Duplicate/O/R=[DataQstartPoint,DataQEndPoint] OriginalDataQWave, ModelLogLogQ, ModelLogLogInt, NormalizedResidualLogLogQ
	Duplicate/O/R=[DataQstartPoint,DataQEndPoint] LinModelDataQWave, ModelLlinLinQ2, ModelLinLinLogInt, NormalizedResidualLinLinQ
	Duplicate/O/R=[DataQstartPoint,DataQEndPoint] OriginalDataIntWave, NormalizedResidualLogLog
	Duplicate/O/R=[DataQstartPoint,DataQEndPoint] LinModelDataIntWave, NormalizedResidualLinLin

	Duplicate/Free/R=[DataQstartPoint,DataQEndPoint] OriginalDataIntWave, TempOriginalIntensity
	Duplicate/Free/R=[DataQstartPoint,DataQEndPoint] OriginalDataErrorWave, TempOriginalError
	Duplicate/Free/R=[DataQstartPoint,DataQEndPoint] LinModelDataEWave, TempLinError
	Duplicate/Free/R=[DataQstartPoint,DataQEndPoint] LinModelDataIntWave, TempLinIntensity
	
	strswitch(SimpleModel)	// string switch
		case "Guinier":	// execute if case matches expression
			ModelLogLogInt = Guinier_I0 *exp(-ModelLogLogQ[p]^2*Guinier_Rg^2/3)
			ModelLinLinLogInt = ln(ModelLogLogInt)	
			break		// exit from switch
		case "Porod":	// execute if case matches expression
			ModelLogLogInt = DataBackground+Porod_Constant * ModelLogLogQ^(-4)
			ModelLinLinLogInt = ModelLogLogInt*ModelLogLogQ^4	
			break
		case "Sphere":	// execute if case matches expression
			ModelLogLogInt = DataBackground + 	Sphere_ScalingConstant * (3/(ModelLogLogQ[p]*Sphere_Radius)^3)*(sin(ModelLogLogQ[p]*Sphere_Radius)-(ModelLogLogQ[p]*Sphere_Radius*cos(ModelLogLogQ[p]*Sphere_Radius)))
			ModelLinLinLogInt = ln(ModelLogLogInt)	
			break
		case "Spheroid":	// execute if case matches expression
			ModelLogLogInt = 	DataBackground +  Spheroid_ScalingConstant*IR1T_CalcIntgSpheroidFFPoints(ModelLogLogQ[p],Spheroid_Radius,Spheroid_Beta)
			ModelLinLinLogInt = ln(ModelLogLogInt)	
			break
		default:			// optional default expression executed

	endswitch
	NormalizedResidualLogLog = (TempOriginalIntensity-ModelLogLogInt)/TempOriginalError
	NormalizedResidualLinLin = (TempLinIntensity-ModelLinLinLogInt)/TempLinError
	
	Duplicate/Free NormalizedResidualLogLog, ChiSquareTemp
	ChiSquareTemp = ((TempOriginalIntensity-ModelLogLogInt)/TempOriginalError)^2
	AchievedChiSquare = (sum(ChiSquareTemp))

	CheckDisplayed /W=IR3J_LogLogDataDisplay ModelLogLogInt
	if(!V_flag)
		AppendToGraph /W=IR3J_LogLogDataDisplay  ModelLogLogInt  vs ModelLogLogQ
		ModifyGraph/W=IR3J_LogLogDataDisplay  lsize(ModelLogLogInt)=2,rgb(ModelLogLogInt)=(0,0,0)
	endif

	CheckDisplayed /W=IR3J_LogLogDataDisplay NormalizedResidualLogLog
	if(!V_flag)
		AppendToGraph /W=IR3J_LogLogDataDisplay/R  NormalizedResidualLogLog  vs NormalizedResidualLogLogQ
		ModifyGraph/W=IR3J_LogLogDataDisplay  mode(NormalizedResidualLogLog)=2,lsize(NormalizedResidualLogLog)=3,rgb(NormalizedResidualLogLog)=(0,0,0)
		Label/W=IR3J_LogLogDataDisplay right "Normalized residuals"
	endif



	CheckDisplayed /W=IR3J_LinDataDisplay ModelLinLinLogInt
	if(!V_flag)
		AppendToGraph /W=IR3J_LinDataDisplay  ModelLinLinLogInt  vs ModelLlinLinQ2
		ModifyGraph/W=IR3J_LinDataDisplay  lsize(ModelLinLinLogInt)=2,rgb(ModelLinLinLogInt)=(0,0,0)
	endif

	CheckDisplayed /W=IR3J_LinDataDisplay NormalizedResidualLinLin
	if(!V_flag)
		AppendToGraph /W=IR3J_LinDataDisplay/R  NormalizedResidualLinLin  vs NormalizedResidualLinLinQ
		ModifyGraph/W=IR3J_LinDataDisplay mode(NormalizedResidualLinLin)=2,lsize(NormalizedResidualLinLin)=3,rgb(NormalizedResidualLinLin)=(0,0,0)
		Label/W=IR3J_LinDataDisplay right "Normalized residuals"
	endif
	
	
	SetDataFolder oldDf

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function IR3J_SaveResultsToNotebook()

	IR1_CreateResultsNbk()
	
	DFref oldDf= GetDataFolderDFR()	
	SetDataFolder root:Packages:Irena:SimpleFits								//go into the folder
	SVAR  DataFolderName=root:Packages:Irena:SimpleFits:DataFolderName
	SVAR  IntensityWaveName=root:Packages:Irena:SimpleFits:IntensityWaveName
	SVAR  QWavename=root:Packages:Irena:SimpleFits:QWavename
	SVAR  ErrorWaveName=root:Packages:Irena:SimpleFits:ErrorWaveName
	SVAR SimpleModel=root:Packages:Irena:SimpleFits:SimpleModel
	NVAR DataQEnd = root:Packages:Irena:SimpleFits:DataQEnd
	NVAR DataQstart = root:Packages:Irena:SimpleFits:DataQstart
	NVAR AchievedChiSquare=root:Packages:Irena:SimpleFits:AchievedChiSquare
	NVAR Guinier_I0 				= root:Packages:Irena:SimpleFits:Guinier_I0
	NVAR Guinier_Rg					=root:Packages:Irena:SimpleFits:Guinier_Rg
	NVAR Porod_Constant			=root:Packages:Irena:SimpleFits:Porod_Constant
	NVAR Sphere_Radius				=root:Packages:Irena:SimpleFits:Sphere_Radius
	NVAR Sphere_ScalingConstant	=root:Packages:Irena:SimpleFits:Sphere_ScalingConstant
	NVAR Spheroid_Radius			=root:Packages:Irena:SimpleFits:Spheroid_Radius
	NVAR Spheroid_ScalingConstant=root:Packages:Irena:SimpleFits:Spheroid_ScalingConstant
	NVAR Spheroid_Beta				=root:Packages:Irena:SimpleFits:Spheroid_Beta
	NVAR DataBackground			=root:Packages:Irena:SimpleFits:DataBackground
	SVAR SimpleModel 				= root:Packages:Irena:SimpleFits:SimpleModel

	IR1_AppendAnyText("\r Results of "+SimpleModel+" fitting\r",1)	
	IR1_AppendAnyText("Date & time: \t"+Date()+"   "+time(),0)	
	IR1_AppendAnyText("Data from folder: \t"+DataFolderName,0)	
	IR1_AppendAnyText("Intensity: \t"+IntensityWaveName,0)	
	IR1_AppendAnyText("Q: \t"+QWavename,0)	
	IR1_AppendAnyText("Error: \t"+ErrorWaveName,0)	
	IR1_AppendAnyText(" ",0)	
	if(stringmatch(SimpleModel,"Guinier"))
		IR1_AppendAnyText("\tRg = "+num2str(Guinier_Rg),0)
		IR1_AppendAnyText("\tI0 = "+num2str(Guinier_I0),0)
	elseif(stringmatch(SimpleModel,"Porod"))
		IR1_AppendAnyText("\tPorod Constant = "+num2str(Porod_Constant),0)
		IR1_AppendAnyText("\tBackground = "+num2str(DataBackground),0)
	elseif(stringmatch(SimpleModel,"Sphere"))
		IR1_AppendAnyText("\tSphere Radius [A] = "+num2str(Sphere_Radius),0)
		IR1_AppendAnyText("\tScaling constant = "+num2str(Sphere_ScalingConstant),0)
		IR1_AppendAnyText("\tBackground = "+num2str(DataBackground),0)
	elseif(stringmatch(SimpleModel,"Spheroid"))
		IR1_AppendAnyText("\tSpheroid Radius [A] = "+num2str(Spheroid_Radius),0)
		IR1_AppendAnyText("\tScaling constant = "+num2str(Spheroid_ScalingConstant),0)
		IR1_AppendAnyText("\Spheroid Beta = "+num2str(Spheroid_Beta),0)
		IR1_AppendAnyText("\tBackground = "+num2str(DataBackground),0)
	endif

	IR1_AppendAnyText("Achieved Normalized chi-square = "+num2str(AchievedChiSquare),0)
	IR1_AppendAnyText("Qmin = "+num2str(DataQstart),0)
	IR1_AppendAnyText("Qmax = "+num2str(DataQEnd),0)
	IR1_AppendAnyGraph("IR3J_LogLogDataDisplay")
	IR1_AppendAnyGraph("IR3J_LinDataDisplay")
	IR1_AppendAnyText("******************************************\r",0)	
	SetDataFolder OldDf
	SVAR/Z nbl=root:Packages:Irena:ResultsNotebookName	
	DoWindow/F $nbl
end
//**********************************************************************************************************
//**********************************************************************************************************
static Function IR3J_SaveResultsToWaves()
	
	DFref oldDf= GetDataFolderDFR()	
	SetDataFolder root:Packages:Irena:SimpleFits								//go into the folder
	SVAR  DataFolderName=root:Packages:Irena:SimpleFits:DataFolderName
	SVAR  IntensityWaveName=root:Packages:Irena:SimpleFits:IntensityWaveName
	SVAR  QWavename=root:Packages:Irena:SimpleFits:QWavename
	SVAR  ErrorWaveName=root:Packages:Irena:SimpleFits:ErrorWaveName
	SVAR SimpleModel=root:Packages:Irena:SimpleFits:SimpleModel
	NVAR DataQEnd = root:Packages:Irena:SimpleFits:DataQEnd
	NVAR DataQstart = root:Packages:Irena:SimpleFits:DataQstart
	NVAR Guinier_I0 = root:Packages:Irena:SimpleFits:Guinier_I0
	NVAR Guinier_Rg=root:Packages:Irena:SimpleFits:Guinier_Rg
	NVAR AchievedChiSquare=root:Packages:Irena:SimpleFits:AchievedChiSquare
	NVAR Guinier_I0 				= root:Packages:Irena:SimpleFits:Guinier_I0
	NVAR Guinier_Rg					=root:Packages:Irena:SimpleFits:Guinier_Rg
	NVAR Porod_Constant			=root:Packages:Irena:SimpleFits:Porod_Constant
	NVAR Sphere_Radius				=root:Packages:Irena:SimpleFits:Sphere_Radius
	NVAR Sphere_ScalingConstant	=root:Packages:Irena:SimpleFits:Sphere_ScalingConstant
	NVAR Spheroid_Radius			=root:Packages:Irena:SimpleFits:Spheroid_Radius
	NVAR Spheroid_ScalingConstant=root:Packages:Irena:SimpleFits:Spheroid_ScalingConstant
	NVAR Spheroid_Beta				=root:Packages:Irena:SimpleFits:Spheroid_Beta
	NVAR DataBackground			=root:Packages:Irena:SimpleFits:DataBackground
	SVAR SimpleModel 				= root:Packages:Irena:SimpleFits:SimpleModel

	variable curlength
	if(stringmatch(SimpleModel,"Guinier"))
		//tabulate data for Guinier
		NewDATAFolder/O/S root:GuinierFitResults
		Wave/Z GuinierRg
		if(!WaveExists(GuinierRg))
			make/O/N=0 GuinierRg, GuinierI0, GuinierQmin, GuinierQmax, GuinierChiSquare
			make/O/N=0/T SampleName
		endif
		curlength = numpnts(GuinierRg)
		redimension/N=(curlength+1) SampleName,GuinierRg, GuinierI0, GuinierQmin, GuinierQmax, GuinierChiSquare 
		SampleName[curlength] = DataFolderName
		GuinierRg[curlength] = Guinier_Rg
		GuinierI0[curlength] = Guinier_I0
		GuinierQmin[curlength] = DataQstart
		GuinierQmax[curlength] = DataQEnd
		GuinierChiSquare[curlength] = AchievedChiSquare
		IR3J_GetTableWithresults()
	elseif(stringmatch(SimpleModel,"Porod"))
		//tabulate data for Porod
		NewDATAFolder/O/S root:PorodFitResults
		Wave/Z PorodConstant
		if(!WaveExists(PorodConstant))
			make/O/N=0 PorodConstant, PorodBackground, PorodQmin, PorodQmax, PorodChiSquare
			make/O/N=0/T SampleName
		endif
		curlength = numpnts(PorodConstant)
		redimension/N=(curlength+1) SampleName,PorodConstant, PorodBackground, PorodQmin, PorodQmax, PorodChiSquare 
		SampleName[curlength] = DataFolderName
		PorodConstant[curlength] = Porod_Constant
		PorodBackground[curlength]=DataBackground
		PorodQmin[curlength] = DataQstart
		PorodQmax[curlength] = DataQEnd
		PorodChiSquare[curlength] = AchievedChiSquare
		IR3J_GetTableWithresults()
	elseif(stringmatch(SimpleModel,"Sphere"))
		//tabulate data for Porod
		NewDATAFolder/O/S root:SphereFitResults
		Wave/Z SphereRadius
		if(!WaveExists(SphereRadius))
			make/O/N=0 SphereRadius, SphereScalingFactor, SphereBackground, SphereQmin, SphereQmax, SphereChiSquare
			make/O/N=0/T SampleName
		endif
		curlength = numpnts(SphereRadius)
		redimension/N=(curlength+1) SampleName,SphereRadius, SphereScalingFactor, SphereBackground, SphereQmin, SphereQmax, SphereChiSquare 
		SampleName[curlength] = DataFolderName
		SphereRadius[curlength] = Sphere_Radius
		SphereScalingFactor[curlength] = Sphere_ScalingConstant
		SphereBackground[curlength]=DataBackground
		SphereQmin[curlength] = DataQstart
		SphereQmax[curlength] = DataQEnd
		SphereChiSquare[curlength] = AchievedChiSquare
		IR3J_GetTableWithresults()
	elseif(stringmatch(SimpleModel,"Spheroid"))
		//tabulate data for Porod
		NewDATAFolder/O/S root:SpheroidFitResults
		Wave/Z SpheroidRadius
		if(!WaveExists(SpheroidRadius))
			make/O/N=0 SpheroidRadius, SpheroidScalingFactor, SpheroidAspectRatio, SpheroidBackground, SpheroidQmin, SpheroidQmax, SpheroidChiSquare
			make/O/N=0/T SampleName
		endif
		curlength = numpnts(SpheroidRadius)
		redimension/N=(curlength+1) SampleName,SpheroidRadius, SpheroidScalingFactor, SpheroidAspectRatio, SpheroidBackground, SpheroidQmin, SpheroidQmax, SpheroidChiSquare 
		SampleName[curlength] 			= DataFolderName
		SpheroidRadius[curlength] 			= Spheroid_Radius
		SpheroidScalingFactor[curlength] = Spheroid_ScalingConstant
		SpheroidAspectRatio[curlength] 	= Spheroid_Beta
		SpheroidBackground[curlength]	= DataBackground
		SpheroidQmin[curlength]			= DataQstart
		SpheroidQmax[curlength] 			= DataQEnd
		SpheroidChiSquare[curlength] 	= AchievedChiSquare
		IR3J_GetTableWithresults()
	endif
	
end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3J_GetTableWithresults()

	SVAR SimpleModel 				= root:Packages:Irena:SimpleFits:SimpleModel
	strswitch(SimpleModel)	// string switch
		case "Guinier":	// execute if case matches expression
			DoWindow IR3J_GuinierFitResultsTable
			if(V_Flag)
				DoWIndow/F IR3J_GuinierFitResultsTable
			else
				IR3J_GuinierFitResultsTableFnct()
			endif		
			break		// exit from switch
		case "Porod":	// execute if case matches expression
			DoWindow IR3J_PorodFitResultsTable
			if(V_Flag)
				DoWindow/F IR3J_PorodFitResultsTable
			else
				IR3J_PorodFitResultsTableFnct() 
			endif 
			break
		case "Sphere":	// execute if case matches expression
			DoWindow IR3J_SphereFFFitResultsTable
			if(V_Flag)
				DoWindow/F IR3J_SphereFFFitResultsTable
			else
				IR3J_SphereFFFitResultsTableFnct() 
			endif 
			break
		case "Spheroid":	// execute if case matches expression
			DoWindow IR3J_SpheroidFFFitResultsTable
			if(V_Flag)
				DoWindow/F IR3J_SpheroidFFFitResultsTable
			else
				IR3J_SpheroidFFFitResultsTableFnct() 
			endif 
			break
		default:			// optional default expression executed

	endswitch

end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3J_DeleteExistingModelResults()

	SVAR SimpleModel 	= root:Packages:Irena:SimpleFits:SimpleModel
	DoAlert /T="This is delete resutls warning" 1, "This will delete all existing results for model : "+SimpleModel+"  . Do you WANT to continue?"
	if(V_Flag==1)
		strswitch(SimpleModel)	// string switch
			case "Guinier":	// execute if case matches expression
				DoWindow/K/Z IR3J_GuinierFitResultsTable
				KillDataFolder/Z root:GuinierFitResults:
				if(V_Flag!=0)
					DoAlert/T="Could not delete data folder" 0, "Guinier results folder root:GuinierFitResults could not be deleted. It is likely used in some graph or table. Close graphs/tables and try again."
				endif
				break		// exit from switch
			case "Porod":	// execute if case matches expression
				DoWindow/K/Z  IR3J_PorodFitResultsTable
				KillDataFolder/Z root:PorodFitResults:
				if(V_Flag!=0)
					DoAlert/T="Could not delete data folder" 0, "Porod results folder root:PorodFitResults could not be deleted. It is likely used in some graph or table. Close graphs/tables and try again."
				endif
				break
			case "Sphere":	// execute if case matches expression
				DoWindow/K/Z  IR3J_SphereFFFitResultsTable
				KillDataFolder/Z root:SphereFitResults:
				if(V_Flag!=0)
					DoAlert/T="Could not delete data folder" 0, "Sphere FF results folder root:SphereFitResults could not be deleted. It is likely used in some graph or table. Close graphs/tables and try again."
				endif
				break
			case "Spheroid":	// execute if case matches expression
				DoWindow/K/Z IR3J_SpheroidFFFitResultsTable
				KillDataFolder/Z root:SpheroidFitResults:
				if(V_Flag!=0)
					DoAlert/T="Could not delete data folder" 0, "Spheroid FF results folder root:SpheroidFitResults could not be deleted. It is likely used in some graph or table. Close graphs/tables and try again."
				endif
				break
			default:			// optional default expression executed
	
		endswitch
	endif
end


//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IR3J_GuinierFitResultsTableFnct() : Table
	PauseUpdate; Silent 1		// building window...
	DFref oldDf= GetDataFolderDFR()	
	if(!DataFolderExists("root:GuinierFitResults:"))
		Abort "No Guinier Fit data exist."
	endif
	SetDataFolder root:GuinierFitResults:
	Wave/T SampleName
	Wave GuinierRg,GuinierI0,GuinierChiSquare,GuinierQmax,GuinierQmin
	Edit/K=1/W=(860,772,1831,1334)/N=IR3J_GuinierFitResultsTable SampleName,GuinierRg,GuinierI0,GuinierChiSquare,GuinierQmax as "Guinier fitting results Table"
	AppendToTable GuinierQmin
	ModifyTable format(Point)=1,width(SampleName)=304,title(SampleName)="Sample Folder"
	ModifyTable alignment(GuinierRg)=1,sigDigits(GuinierRg)=4,title(GuinierRg)="Rg [A]"
	ModifyTable alignment(GuinierI0)=1,sigDigits(GuinierI0)=4,width(GuinierI0)=100,title(GuinierI0)="Guinier I0"
	ModifyTable alignment(GuinierChiSquare)=1,sigDigits(GuinierChiSquare)=4,width(GuinierChiSquare)=104
	ModifyTable title(GuinierChiSquare)="Chi^2",alignment(GuinierQmax)=1,sigDigits(GuinierQmax)=4
	ModifyTable width(GuinierQmax)=92,title(GuinierQmax)="Qmax [1/A]",alignment(GuinierQmin)=1
	ModifyTable sigDigits(GuinierQmin)=4,width(GuinierQmin)=110,title(GuinierQmin)="Qmin [1/A]"
	SetDataFolder oldDf
EndMacro

//*****************************************************************************************************************
Function IR3J_PorodFitResultsTableFnct() : Table
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	if(!DataFolderExists("root:PorodFitResults:"))
		Abort "No Porod Fit data exist."
	endif
	SetDataFolder root:PorodFitResults:
	Wave/T SampleName
	Wave PorodConstant,PorodBackground,PorodChiSquare, PorodQmax,PorodQmin
	Edit/K=1/W=(576,346,1528,878)/N=IR3J_PorodFitResultsTable SampleName,PorodConstant,PorodBackground,PorodChiSquare as "Porod fitting results Table"
	AppendToTable PorodQmax,PorodQmin
	ModifyTable format(Point)=1,width(SampleName)=314,title(SampleName)="Sample Folder"
	ModifyTable alignment(PorodConstant)=1,sigDigits(PorodConstant)=4,width(PorodConstant)=122
	ModifyTable title(PorodConstant)="Porod Constant",alignment(PorodBackground)=1,sigDigits(PorodBackground)=4
	ModifyTable width(PorodBackground)=110,title(PorodBackground)="Background",alignment(PorodChiSquare)=1
	ModifyTable sigDigits(PorodChiSquare)=4,width(PorodChiSquare)=106,title(PorodChiSquare)="Chi^2"
	ModifyTable alignment(PorodQmax)=1,sigDigits(PorodQmax)=4,title(PorodQmax)="Qmax [1/A]"
	ModifyTable alignment(PorodQmin)=1,sigDigits(PorodQmin)=4,width(PorodQmin)=94,title(PorodQmin)="Qmin [1/A]"
	SetDataFolder fldrSav0
EndMacro
//*****************************************************************************************************************
Function IR3J_SphereFFFitResultsTableFnct() : Table
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	if(!DataFolderExists("root:SphereFitResults:"))
		Abort "No Sphere FF Fit data exist."
	endif
	SetDataFolder root:SphereFitResults:
	Wave/T SampleName
	Wave SphereRadius,SphereScalingFactor,SphereBackground,SphereChiSquare,SphereQmax,SphereQmin 
	Edit/K=1/W=(576,784,1527,1226)/N=IR3J_SphereFFFitResultsTable SampleName,SphereRadius,SphereScalingFactor,SphereBackground as "Sphere FF fiting results table"
	AppendToTable SphereChiSquare,SphereQmax,SphereQmin
	ModifyTable format(Point)=1,width(SampleName)=330,title(SampleName)="Sample Folder"
	ModifyTable alignment(SphereRadius)=1,sigDigits(SphereRadius)=4,width(SphereRadius)=86
	ModifyTable title(SphereRadius)="Radius [A]",alignment(SphereScalingFactor)=1,sigDigits(SphereScalingFactor)=4
	ModifyTable title(SphereScalingFactor)="Scaling fact.",alignment(SphereBackground)=1
	ModifyTable sigDigits(SphereBackground)=4,title(SphereBackground)="Background",alignment(SphereChiSquare)=1
	ModifyTable sigDigits(SphereChiSquare)=4,title(SphereChiSquare)="Chi^2",alignment(SphereQmax)=1
	ModifyTable sigDigits(SphereQmax)=4,title(SphereQmax)="Qmax [1/A]",alignment(SphereQmin)=1
	ModifyTable sigDigits(SphereQmin)=4,width(SphereQmin)=88,title(SphereQmin)="Qmin [1/A]"
	SetDataFolder fldrSav0
EndMacro
//*****************************************************************************************************************

Function IR3J_SpheroidFFFitResultsTableFnct() : Table
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	if(!DataFolderExists("root:SpheroidFitResults:"))
		Abort "No Spheroid FF Fit data exist."
	endif
	SetDataFolder root:SpheroidFitResults:
	Wave/T SampleName
	Wave SpheroidRadius,SpheroidAspectRatio,SpheroidScalingFactor,SpheroidChiSquare,SpheroidBackground,SpheroidQmax,SpheroidQmin 
	Edit/K=1/W=(528,552,1494,1048)/N=IR3J_SpheroidFFFitResultsTable SampleName,SpheroidRadius,SpheroidAspectRatio,SpheroidScalingFactor as "Spheroid FF fitting results table"
	AppendToTable SpheroidChiSquare,SpheroidBackground,SpheroidQmax,SpheroidQmin
	ModifyTable format(Point)=1,width(SampleName)=306,title(SampleName)="Sample Folder"
	ModifyTable alignment(SpheroidRadius)=1,sigDigits(SpheroidRadius)=4,title(SpheroidRadius)="Radius [A]"
	ModifyTable alignment(SpheroidAspectRatio)=1,sigDigits(SpheroidAspectRatio)=3,title(SpheroidAspectRatio)="Aspect Ratio"
	ModifyTable alignment(SpheroidScalingFactor)=1,sigDigits(SpheroidScalingFactor)=4
	ModifyTable title(SpheroidScalingFactor)="Scaling fact.",alignment(SpheroidChiSquare)=1
	ModifyTable sigDigits(SpheroidChiSquare)=4,title(SpheroidChiSquare)="Chi^2",alignment(SpheroidBackground)=1
	ModifyTable sigDigits(SpheroidBackground)=4,title(SpheroidBackground)="Background"
	ModifyTable alignment(SpheroidQmax)=1,sigDigits(SpheroidQmax)=4,title(SpheroidQmax)="Qmax [1/A]"
	ModifyTable alignment(SpheroidQmin)=1,sigDigits(SpheroidQmin)=4,title(SpheroidQmin)="Qmin [1/A]"
	SetDataFolder fldrSav0
EndMacro
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3J_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(StringMatch(pa.ctrlName, "SimpleModel" ))
				SVAR SimpleModel = root:Packages:Irena:SimpleFits:SimpleModel
				SimpleModel = popStr
				IR3J_SetupControlsOnMainpanel()
				KillWIndow/Z IR3J_LinDataDisplay
				KillWindow/Z IR3J_LogLogDataDisplay
				IR3J_CreateCheckGraphs()
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR3J_SetupControlsOnMainpanel()
	
	SVAR SimpleModel = root:Packages:Irena:SimpleFits:SimpleModel
	DoWindow IR3J_SimpleFitsPanel
	if(V_Flag)

		Setvariable Guinier_I0, disable=1
		SetVariable Guinier_Rg, disable=1
		SetVariable Porod_Constant, disable=1
		Setvariable Sphere_ScalingConstant,  disable=1
		SetVariable Sphere_Radius, disable=1
		Setvariable Spheroid_ScalingConstant,  disable=1
		SetVariable Spheroid_Radius, disable=1
		Setvariable Spheroid_Beta,  disable=1
		SetVariable DataBackground,  disable=1

		strswitch(SimpleModel)	// string switch
			case "Guinier":	// execute if case matches expression
				Setvariable Guinier_I0, disable=0
				SetVariable Guinier_Rg, disable=0
				break		// exit from switch
			case "Porod":	// execute if case matches expression
				SetVariable Porod_Constant, disable=0
				SetVariable DataBackground,  disable=0
				break
			case "Sphere":	// execute if case matches expression
				Setvariable Sphere_ScalingConstant,  disable=0
				SetVariable Sphere_Radius, disable=0
				SetVariable DataBackground,  disable=0
				break
			case "Spheroid":	// execute if case matches expression
				Setvariable Spheroid_ScalingConstant,  disable=0
				SetVariable Spheroid_Radius, disable=0
				Setvariable Spheroid_Beta,  disable=0
				SetVariable DataBackground,  disable=0
				break
			default:			// optional default expression executed

		endswitch
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//		SetWindow IR3J_LogLogDataDisplay, hook(SimpleFitsLogCursorMoved) = IR3J_GraphWindowHook
//		SetWindow IR3J_LinDataDisplay, hook(SimpleFitsLinCursorMoved) = IR3J_GraphWindowHook
