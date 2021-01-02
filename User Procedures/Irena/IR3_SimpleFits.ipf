#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.12
constant IR3JversionNumber = 0.3			//Simple Fit panel version number

//*************************************************************************\
//* Copyright (c) 2005 - 2021, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

constant SimpleFitsLinPlotMaxScale = 1.07
constant SimpleFitsLinPlotMinScale = 0.8

//1.12 	Added Invariant calculation. 
//1.1 		combined this ipf with "Simple fits models"
//1.0 		Simple Fits tool first release version 


//To add new function:
//at this moment we have: 	ListOfSimpleModels="Guinier;Porod;Sphere;Spheroid;Guinier Rod;Guinier Sheet;"
//IR3J_InitSimpleFits()	
//			add to: ListOfSimpleModels list as new data type ("Guinier")
//			add any new parameters, which will need to be fit. Keep in mind, all will be fit. 
//IR3J_SimpleFitsPanelFnct()
//			set controls for the new parameters.
//IR3J_PopMenuProc()
//			make sure controls show as needed only
//IR3J_CreateLinearizedData()
//			create new linearized data if needed. Example: Guiniers, Porod... 
//IR3J_AppendDataToGraphModel()
//			if linearized data exist, append them here... 
//IR3J_CalculateModel()
//			Add model calculations here... 
//IR3J_FitData()
//			Add fitting function and fit here. 				
//IR3J_SaveResultsToNotebook()
//IR3J_SaveResultsToFolder()
//IR3J_SaveResultsToWaves()
//			Add to both of these above string results in appropriate media... 
//IR3J_GetTableWithResults()
//			here create proper table to present to users... 
//IR3J_DeleteExistingModelResults()
//			add here how to delete new data types being created... 
//add also results type to IR2_PanelControLProcedures.ipf 
//			Procedure is IR2C_InitControls
//existing:  	AllCurrentlyAllowedTypes+="SimFitYGuinier;SimFitYGuinierR;SimFitYGuinierS;SimFitYSphere;SimFitYSpheroid;"

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3J_SimpleFits()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
		IR3C_MultiUpdListOfAvailFiles("Irena:SimpleFits")	
	endif
	IR3J_CreateCheckGraphs()
end
//************************************************************************************************************
Function IR1B_SimpleFitsMainCheckVersion()	
	DoWindow IR3J_SimpleFitsPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR3J_SimpleFitsPanel", IR3JversionNumber))
			DoAlert /T="The Simple Fits panel was created by incorrect version of Irena " 1, "Import Simple Fits needa to be restarted to work properly. Restart now?"
			if(V_flag==1)
				KillWIndow/Z IR3J_SimpleFitsPanel
				IR3J_SimpleFits()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR3J_InitSimpleFits()
				IR1T_InitFormFactors()  
			endif
		endif
	endif
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR3J_SimpleFitsPanelFnct()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(2.25,43.25,530,800) as "Simple Fits & Analysis tool"
	DoWIndow/C IR3J_SimpleFitsPanel
	TitleBox MainTitle title="Simple Fists & Analysis tool",pos={120,2},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fSize=22,fColor=(0,0,52224)
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena:SimpleFits","IR3J_SimpleFitsPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	IR3C_MultiAppendControls("Irena:SimpleFits","IR3J_SimpleFitsPanel", "IR3J_CopyAndAppendData","",1,0)
	//hide what is not needed
	checkbox UseResults, disable=0
	SetVariable DataQEnd,pos={290,90},size={190,15}, proc=IR3J_SetVarProc,title="Q max for fitting    "
	Setvariable DataQEnd, variable=root:Packages:Irena:SimpleFits:DataQEnd, limits={-inf,inf,0}
	SetVariable DataQstart,pos={290,110},size={190,15}, proc=IR3J_SetVarProc,title="Q min for fitting     "
	Setvariable DataQstart, variable=root:Packages:Irena:SimpleFits:DataQstart, limits={-inf,inf,0}
	SetVariable DataFolderName,noproc,title=" ",pos={250,140},size={270,17},frame=0, fstyle=1,valueColor=(0,0,65535)
	Setvariable DataFolderName, variable=root:Packages:Irena:SimpleFits:DataFolderName, noedit=1

	Button SelectAll,pos={200,680},size={80,15}, proc=IR3J_ButtonProc,title="SelectAll", help={"Select All data in Listbox"}
	Button GetHelp,pos={430,50},size={80,15},fColor=(65535,32768,32768), proc=IR3J_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}

	PopupMenu SimpleModel,pos={280,175},size={200,20},fStyle=2,proc=IR3J_PopMenuProc,title="Model to fit : "
	SVAR SimpleModel = root:Packages:Irena:SimpleFits:SimpleModel
	PopupMenu SimpleModel,mode=1,popvalue=SimpleModel,value= #"root:Packages:Irena:SimpleFits:ListOfSimpleModels" 
	
	//Guinier controls
	SetVariable Guinier_I0,pos={240,230},size={220,15}, proc=IR3J_SetVarProc,title="Scaling I0  ", bodywidth=80
	Setvariable Guinier_I0, variable=root:Packages:Irena:SimpleFits:Guinier_I0, limits={1e-20,inf,0}, help={"Guinier prefactor I0"}
	SetVariable Guinier_Rg,pos={240,260},size={220,15}, proc=IR3J_SetVarProc,title="Rg [A] ", bodywidth=80
	Setvariable Guinier_Rg, variable=root:Packages:Irena:SimpleFits:Guinier_Rg, limits={3,inf,0}, help={"Guinier Rg value"}
	//Porod
	SetVariable Porod_Constant,pos={290,230},size={220,15}, proc=IR3J_SetVarProc,title="Porod Con. [cm2/cm3/A^4] ", bodywidth=80
	Setvariable Porod_Constant, variable=root:Packages:Irena:SimpleFits:Porod_Constant, limits={1e-20,inf,0}, help={"Porod constant"}
	SetVariable ScatteringContrast,pos={290,260},size={220,15}, proc=IR3J_SetVarProc,title="Contrast [10^20 cm^-4]", bodywidth=80
	Setvariable ScatteringContrast, variable=root:Packages:Irena:SimpleFits:ScatteringContrast, limits={1,inf,0}, help={"Scattering Contrast for the scatterers"}
	SetVariable Porod_SpecificSurface,pos={290,290},size={220,15}, proc=IR3J_SetVarProc,title="Spec. Sfc area [cm2/cm3]", bodywidth=80, limits={0,inf,0}
	Setvariable Porod_SpecificSurface, variable=root:Packages:Irena:SimpleFits:Porod_SpecificSurface, disable=0, noedit=1, help={"Porod constant"}
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

	//Invariant controls
	PopupMenu InvBackgModel,pos={260,230},size={200,20},fStyle=2,proc=IR3J_PopMenuProc,title="Bckg model: "
	SVAR InvBackgModel = root:Packages:Irena:SimpleFits:InvBackgModel
	SVAR InvBackgModelList = root:Packages:Irena:SimpleFits:InvBackgModelList
	print WhichListItem(InvBackgModel, InvBackgModelList)
	PopupMenu InvBackgModel,value= #"root:Packages:Irena:SimpleFits:InvBackgModelList" ,mode=(WhichListItem(InvBackgModel, InvBackgModelList)+1) 
	SetVariable InvBckgMinQ,pos={240,320},size={220,15}, proc=IR3J_SetVarProc,title="Backg Fit Qmin", bodywidth=80
	Setvariable InvBckgMinQ, variable=root:Packages:Irena:SimpleFits:InvBckgMinQ, limits={0,10,0}, help={"Start of range to fit background"}
	SetVariable InvBckgMaxQ,pos={240,340},size={220,15}, proc=IR3J_SetVarProc,title="Bckg Fit Qmax ", bodywidth=80
	Setvariable InvBckgMaxQ, variable=root:Packages:Irena:SimpleFits:InvBckgMaxQ, limits={-inf,inf,0}, help={"End of Q range to fit background"}
	SetVariable invariant,pos={240,380},size={220,15}, noproc,title="Invariant = ", bodywidth=80, noedit=1, limits={0,inf,0}
	Setvariable invariant, variable=root:Packages:Irena:SimpleFits:invariant, help={"Start of range to fit background"}
	TitleBox invariantInfo title="\Zr100Inv. units: [(mol e-^2/cm^3)^3]",size={330,15},pos={300,405},frame=0,fColor=(0,0,65535),labelBack=0
	SetVariable InvQmaxUsed,pos={240,425},size={220,15}, noproc,title="Qmax used = ", bodywidth=80, noedit=1, limits={0,inf,0}
	Setvariable InvQmaxUsed, variable=root:Packages:Irena:SimpleFits:InvQmaxUsed, limits={0,10,0}, help={"Calculated Qmax used in evaluation"}

	//other stuff...
	Button FitCurrentDataSet,pos={280,450},size={180,20}, proc=IR3J_ButtonProc,title="Fit Current (one) Dataset", help={"Fit current data set"}
	Button FitSelectionDataSet,pos={280,480},size={180,20}, proc=IR3J_ButtonProc,title="Fit (All) Selected Data", help={"Fit all data selected in listbox"}
	SetVariable AchievedChiSquare,pos={270,510},size={220,15}, noproc,title="Achieved chi-square"
	Setvariable AchievedChiSquare, variable=root:Packages:Irena:SimpleFits:AchievedChiSquare, disable=2, limits={0,inf,0}, format="%3.2f"

	Checkbox SaveToNotebook, pos={280,537},size={76,14},title="Record to Notebook?", noproc, variable=root:Packages:Irena:SimpleFits:SaveToNotebook, help={"Record results in notebook"}
	Checkbox SaveToWaves, pos={280,552},size={76,14},title="Record to Waves?", noproc, variable=root:Packages:Irena:SimpleFits:SaveToWaves, help={"Record results in waves, can then create a table"}
	Checkbox SaveToFolder, pos={280,567},size={76,14},title="Record to Folder?", noproc, variable=root:Packages:Irena:SimpleFits:SaveToFolder, help={"Saves Intensity and Q in teh data folder"}

	Button RecordCurrentresults,pos={280,590},size={180,20}, proc=IR3J_ButtonProc,title="Record Results", help={"Record results in notebook and table"}
	Button GetTableWithResults,pos={280,620},size={180,20}, proc=IR3J_ButtonProc,title="Get Table With Results", help={"Open Table with results for current Model"}
	Button GetNotebookWithResults,pos={280,650},size={180,20}, proc=IR3J_ButtonProc,title="Get Notebook With Results", help={"Open Notebook with results for current Model"}
	Button DeleteOldResults,pos={280,705},size={180,20}, proc=IR3J_ButtonProc,title="Delete Existing Results", help={"Delete results for the current model"}, fColor=(34952,34952,34952)

	SetVariable DelayBetweenProcessing,pos={260,735},size={220,15}, noproc,title="Delay between Processing ", bodywidth=80
	Setvariable DelayBetweenProcessing, variable=root:Packages:Irena:SimpleFits:DelayBetweenProcessing, limits={0,20,0.2}, help={"Delay between two processing steps, set o 0 for none. "}


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
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	SVAR SimpleModel = root:Packages:Irena:SimpleFits:SimpleModel

	if(StringMatch(SimpleModel,"Guinier*") || StringMatch(SimpleModel,"Porod*"))
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
	else
		KillWindow/Z IR3J_LinDataDisplay
		exists2=0
	endif
	if(exists1 && exists2)
		AutoPositionWindow/M=0/R=IR3J_SimpleFitsPanel IR3J_LogLogDataDisplay	
		AutoPositionWindow/M=1/R=IR3J_LogLogDataDisplay IR3J_LinDataDisplay	
	elseif(exists1 && exists2==0)
		AutoPositionWindow/M=0/R=IR3J_SimpleFitsPanel IR3J_LogLogDataDisplay	
	endif
end

//**********************************************************************************************************
//**********************************************************************************************************

Function IR3J_InitSimpleFits()	


	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()
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
	//parameters for Invariant
	ListOfStrings+="InvBackgModel;InvBackgModelList;"

	ListOfVariables="UseIndra2Data1;UseQRSdata1;"
	ListOfVariables+="DataBackground;AchievedChiSquare;ScatteringContrast;"
	ListOfVariables+="Guinier_Rg;Guinier_I0;"
	ListOfVariables+="Porod_Constant;Porod_SpecificSurface;Sphere_Radius;Sphere_ScalingConstant;"
	ListOfVariables+="Spheroid_Radius;Spheroid_ScalingConstant;Spheroid_Beta;"
	ListOfVariables+="ProcessManually;ProcessSequentially;OverwriteExistingData;AutosaveAfterProcessing;DelayBetweenProcessing;"
	ListOfVariables+="DataQEnd;DataQstart;DataQEndPoint;DataQstartPoint;"
	ListOfVariables+="SaveToNotebook;SaveToWaves;SaveToFolder;"
	//parameters for Invariant
	ListOfVariables+="InvBckgMinQ;InvBckgMaxQ;Invariant;InvQmaxUsed;"
	 
	ListOfVariables+="VOlSD_Rg;VolSD_Volume;VolSD_MeanDiameter;VolSD_MedianDiameter;VOlSD_ModeDiamater;"
	ListOfVariables+="NumSD_NumPartPerCm3;NumSD_MeanDiameter;NumSD_MedianDiameter;NumSD_ModeDiamater;"

	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;"
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
	SVAR InvBackgModelList
	SVAR InvBackgModel
	InvBackgModelList = "Porod+y0;PowerLaw+y0;Constant;Gauss y0+A*exp((X-X0)^2/width;Ruland A*exp(B*X^2)+y0;None;"
	if(strlen(InvBackgModel)<2)
		InvBackgModel = "Constant" 
	endif
	SVAR ListOfSimpleModels
	ListOfSimpleModels="Guinier;Porod;Sphere;Spheroid;Guinier Rod;Guinier Sheet;"
	ListOfSimpleModels+="Invariant;Volume Size Distribution;Number Size Distribution;"
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
	NVAR DelayBetweenProcessing
	if(DelayBetweenProcessing<=0)
		DelayBetweenProcessing = 2
	endif
	NVAR ScatteringContrast
	if(ScatteringContrast<1)
		ScatteringContrast = 1
	endif
	NVAR InvBckgMinQ
	//InvBckgMinQ = 0
	NVAR InvBckgMaxQ
	//InvBckgMaxQ = 0
	NVAR Invariant
	Invariant = 0
	NVAR InvQmaxUsed
	InvQmaxUsed = 0
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
				if(tempP>numpnts(OriginalDataQWave)-2)
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
			if(stringmatch(sva.ctrlName,"InvBckgMinQ"))		//invariant background fitting function
				NVAR InvBckgMinQ = root:Packages:Irena:SimpleFits:InvBckgMinQ
				WAVE OriginalDataQWave = root:Packages:Irena:SimpleFits:OriginalDataQWave
				tempP = BinarySearch(OriginalDataQWave, InvBckgMinQ )
				if(tempP<1)
					print "Wrong Q value set, Data Q min must be at least 1 point from the start of Data"
					tempP = 1
					InvBckgMinQ = OriginalDataQWave[tempP]
				endif
				IR3J_InvSyncBckgCursors(0)
			endif
			if(stringmatch(sva.ctrlName,"InvBckgMaxQ"))		//invariant background fitting function
				NVAR InvBckgMaxQ = root:Packages:Irena:SimpleFits:InvBckgMaxQ
				WAVE OriginalDataQWave = root:Packages:Irena:SimpleFits:OriginalDataQWave
				tempP = BinarySearch(OriginalDataQWave, InvBckgMaxQ )
				if(tempP>numpnts(OriginalDataQWave)-2)
					print "Wrong Q value set, Data Q max must be at most 1 point before the end of Data"
					tempP = numpnts(OriginalDataQWave)-2
					InvBckgMaxQ = OriginalDataQWave[tempP]
				endif
				IR3J_InvSyncBckgCursors(0)
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
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:SimpleFits					//go into the folder
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
		UseUserDefinedData = 0
		UseModelData = 0
		//get the names of waves, assume this tool actually works. May not under some conditions. In that case this tool will not work. 
		IR3C_SelectWaveNamesData("Irena:SimpleFits", FolderNameStr)			//this routine will preset names in strings as needed,		
		Wave/Z SourceIntWv=$(DataFolderName+possiblyQUoteName(IntensityWaveName))
		Wave/Z SourceQWv=$(DataFolderName+possiblyQUoteName(QWavename))
		Wave/Z SourceErrorWv=$(DataFolderName+possiblyQUoteName(ErrorWaveName))
		Wave/Z SourcedQWv=$(DataFolderName+possiblyQUoteName(dQWavename))
		if(!WaveExists(SourceIntWv)||	!WaveExists(SourceQWv))//||!WaveExists(SourceErrorWv))
			Abort "Data selection failed for Data in Simple/basic fits routine IR3J_CopyAndAppendData"
		endif
		Duplicate/O SourceIntWv, OriginalDataIntWave
		Duplicate/O SourceQWv, OriginalDataQWave
		if(WaveExists(SourceErrorWv))
			Duplicate/O SourceErrorWv, OriginalDataErrorWave
		else
			Duplicate/O SourceIntWv, OriginalDataErrorWave
			OriginalDataErrorWave = 0
		endif
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
		//done cleaning... 
		DoWIndow IR3J_LogLogDataDisplay
		if(V_Flag)
			RemoveFromGraph /W=IR3J_LogLogDataDisplay /Z NormalizedResidualLogLog
			DoWIndow/F IR3J_LogLogDataDisplay
		endif
		DoWIndow IR3J_LinDataDisplay
		if(V_Flag)
			RemoveFromGraph /W=IR3J_LinDataDisplay /Z NormalizedResidualLinLin
			DoWIndow/F IR3J_LinDataDisplay
		endif
		pauseUpdate
		IR3J_AppendDataToGraphLogLog()
		//now this deals with linearized data, if needed...
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

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()

	SetDataFolder root:Packages:Irena:SimpleFits					//go into the folder
	Wave OriginalDataIntWave=root:Packages:Irena:SimpleFits:OriginalDataIntWave
	Wave OriginalDataQWave=root:Packages:Irena:SimpleFits:OriginalDataQWave
	Wave OriginalDataErrorWave=root:Packages:Irena:SimpleFits:OriginalDataErrorWave
	SVAR SimpleModel=root:Packages:Irena:SimpleFits:SimpleModel
	Duplicate/O OriginalDataIntWave, LinModelDataIntWave	
	Duplicate/O OriginalDataQWave, LinModelDataQWave
	Duplicate/O OriginalDataErrorWave, LinModelDataEWave
	
	strswitch(SimpleModel)				// string switch
		case "Guinier":						// execute if case matches expression
			LinModelDataIntWave = ln(OriginalDataIntWave)
			LinModelDataEWave = OriginalDataErrorWave/OriginalDataIntWave			//error propagation, see: https://terpconnect.umd.edu/~toh/models/ErrorPropagation.pdf
			LinModelDataQWave = OriginalDataQWave^2
			break								// exit from switch
		case "Guinier Rod":				// execute if case matches expression
			LinModelDataIntWave = ln(OriginalDataIntWave*LinModelDataQWave)
			LinModelDataEWave = OriginalDataErrorWave/OriginalDataIntWave			//error propagation, see: https://terpconnect.umd.edu/~toh/models/ErrorPropagation.pdf
			LinModelDataQWave = OriginalDataQWave^2
			break
		case "Guinier Sheet":				// execute if case matches expression
			LinModelDataIntWave = ln(OriginalDataIntWave*LinModelDataQWave^2)
			LinModelDataEWave = OriginalDataErrorWave/OriginalDataIntWave			//error propagation, see: https://terpconnect.umd.edu/~toh/models/ErrorPropagation.pdf
			LinModelDataQWave = OriginalDataQWave^2
			break
		case "Porod":				// execute if case matches expression
			LinModelDataIntWave = OriginalDataIntWave*OriginalDataQWave^4
			LinModelDataEWave = OriginalDataErrorWave*OriginalDataQWave^4			//error propagation, see: https://terpconnect.umd.edu/~toh/models/ErrorPropagation.pdf
			LinModelDataQWave = OriginalDataQWave^4
			break
		default:							// optional default expression executed
			//no linearization graphs needed for "Sphere", "Spheroid",...
			KillWaves/Z LinModelDataIntWave, LinModelDataEWave, LinModelDataQWave			// when no case matches
	endswitch
	SetDataFolder oldDf
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************



Function IR3J_AppendDataToGraphModel()
	//this deals with lin-lin model. 
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IR3J_CreateCheckGraphs()
	variable WhichLegend=0
	variable startQp, endQp, tmpStQ

	SVAR SimpleModel = root:Packages:Irena:SimpleFits:SimpleModel
	if(StringMatch(SimpleModel,"Guinier*") || StringMatch(SimpleModel,"Porod*"))		
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
		SVAR SimpleModel = root:Packages:Irena:SimpleFits:SimpleModel
		strswitch(SimpleModel)	// string switch
			case "Guinier":			// execute if case matches expression
					ModifyGraph /W=IR3J_LinDataDisplay log=0, mirror(bottom)=1
					ModifyGraph /W=IR3J_LinDataDisplay  mode(LinModelDataIntWave)=3,marker(LinModelDataIntWave)=8
					SetAxis/A/W=IR3J_LinDataDisplay 
					Label /W=IR3J_LinDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"ln(Intensity)"
					Label /W=IR3J_LinDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q\\S2\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"[A\\S-2\\M"+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
				break		// exit from switch
			case "Guinier rod":			// execute if case matches expression
					ModifyGraph /W=IR3J_LinDataDisplay log=0, mirror(bottom)=1
					ModifyGraph /W=IR3J_LinDataDisplay  mode(LinModelDataIntWave)=3,marker(LinModelDataIntWave)=8
					SetAxis/A/W=IR3J_LinDataDisplay 
					Label /W=IR3J_LinDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"ln(Q*Intensity)"
					Label /W=IR3J_LinDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q\\S2\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"[A\\S-2\\M"+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
				break		// exit from switch
			case "Guinier sheet":			// execute if case matches expression
					ModifyGraph /W=IR3J_LinDataDisplay log=0, mirror(bottom)=1
					ModifyGraph /W=IR3J_LinDataDisplay  mode(LinModelDataIntWave)=3,marker(LinModelDataIntWave)=8
					SetAxis/A/W=IR3J_LinDataDisplay 
					Label /W=IR3J_LinDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"ln(Q\\S2\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"*Intensity)"
					Label /W=IR3J_LinDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q\\S2\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"[A\\S-2\\M"+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
				break		// exit from switch
			case "Porod":	// execute if case matches expression
					ModifyGraph /W=IR3J_LinDataDisplay log=0, mirror(bottom)=1
					ModifyGraph /W=IR3J_LinDataDisplay mode(LinModelDataIntWave)=3,marker(LinModelDataIntWave)=8
					SetAxis/A/W=IR3J_LinDataDisplay
					SetAxis/W=IR3J_LinDataDisplay left 0,*
					Label /W=IR3J_LinDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Int * Q\\S4"
					Label /W=IR3J_LinDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q\\S4\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"[A\\S-4\\M"+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
				break
			default:			// optional default expression executed
				//<code>]		// when no case matches
		endswitch
		//and set limtis on axis
		variable tempMaxQ
		tempMaxQ = LinModelDataQWave[DataQEndPoint]
		SetAxis/W=IR3J_LinDataDisplay bottom 0,tempMaxQ*SimpleFitsLinPlotMaxScale
		variable tempMaxQY, tempMinQY, maxY, minY
		tempMaxQY = LinModelDataIntWave[DataQstartPoint]
		tempMinQY = LinModelDataIntWave[DataQEndPoint]
		maxY = max(tempMaxQY, tempMinQY)
		minY = min(tempMaxQY, tempMinQY)
		if(maxY>0)
			maxY*=SimpleFitsLinPlotMaxScale
		else
			maxY*=SimpleFitsLinPlotMinScale
		endif
		if(minY>0)
			minY*=SimpleFitsLinPlotMinScale
		else
			minY*=SimpleFitsLinPlotMaxScale
		endif
		SetAxis/W=IR3J_LinDataDisplay left minY, maxY
	else
		KillWindow/Z IR3J_LinDataDisplay
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


Function IR3J_AppendDataToGraphLogLog()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	// for "Size Distribution" use linear left axis.  
	SVAR SimpleModel = root:Packages:Irena:SimpleFits:SimpleModel
	if(StringMatch(SimpleModel, "*size distribution"))
		ModifyGraph /W=IR3J_LogLogDataDisplay log(left)=0, mirror=1
	endif
	//this is from Invariant and needs to be removed if it exists.. 
	Wave/Z InvBckgWaveModel = root:Packages:Irena:SimpleFits:InvBckgWaveModel
	if(WaveExists(InvBckgWaveModel))	//this is used to show how Porod and Powerlaw fit... 
		RemoveFromGraph /W=IR3J_LogLogDataDisplay /Z InvBckgWaveModel
		KillWaves/Z InvBckgWaveModel, QWaveModel	
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

	SVAR SimpleModel = root:Packages:Irena:SimpleFits:SimpleModel
	if(StringMatch(SimpleModel, "Invariant" ))
		IR3J_InvInitializeBackground()			//init background and add CD cursors in graph
	else
		SetWindow IR3J_LogLogDataDisplay, hook(InvariantBackgroundHook) = $""
	endif	
	
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
				NVAR SaveToNotebook=root:Packages:Irena:SimpleFits:SaveToNotebook
				NVAR SaveToWaves=root:Packages:Irena:SimpleFits:SaveToWaves
				NVAR SaveToFolder=root:Packages:Irena:SimpleFits:SaveToFolder
				if(SaveToNotebook+SaveToWaves+SaveToFolder<1)
					Abort "Nothing is selected to Record, check at least on checkbox above" 
				endif	
				IR3J_SaveResultsToNotebook()
				IR3J_SaveResultsToWaves()
				//IR3J_CleanUnusedParamWaves()
				IR3J_SaveResultsToFolder()
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
			if(stringmatch(ba.ctrlName,"SelectAll"))
				Wave/Z SelectionOfAvailableData = root:Packages:Irena:SimpleFits:SelectionOfAvailableData
				if(WaveExists(SelectionOfAvailableData))
					SelectionOfAvailableData=1
				endif
			endif

			if(stringmatch(ba.ctrlName,"GetHelp"))
				IN2G_OpenWebManual("Irena/bioSAXS.html#basic-fits")				//fix me!!			
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
static Function IR3J_CleanUnusedParamWaves()

	Wave/Z TimeWave
	if(sum(TimeWave)<=0 || numtype(sum(TimeWave))!=0)
		KillWaves/Z  TimeWave
	endif
	Wave/Z TemperatureWave
	if(sum(TemperatureWave)<=0 || numtype(sum(TemperatureWave))!=0)
		KillWaves/Z  TemperatureWave
	endif
	Wave/Z PercentWave
	if(sum(PercentWave)<=0|| numtype(sum(PercentWave))!=0)
		KillWaves/Z  PercentWave
	endif
	Wave/Z OrderWave
	if(sum(OrderWave)<=0|| numtype(sum(OrderWave))!=0)
		KillWaves/Z  OrderWave
	endif

end
//
////**********************************************************************************************************
//**********************************************************************************************************

static Function IR3J_FitData()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR SimpleModel = root:Packages:Irena:SimpleFits:SimpleModel
	strswitch(SimpleModel)	// string switch
		case "Guinier":				// Regular Guinier, aka: Sphere, globular. 
			IR3J_FitGuinier("Sphere")
			IR3J_CalculateModel()		
			break			
		case "Guinier Rod":		// Guinier for rod
			IR3J_FitGuinier("Rod")
			IR3J_CalculateModel()		
			break			
		case "Guinier Sheet":		// Guinier for sheet
			IR3J_FitGuinier("Sheet")
			IR3J_CalculateModel()		
			break		
		case "Porod":				// Porod
			IR3J_FitPorod()
			IR3J_CalculateModel()		
			break
		case "Sphere":				// Sphere
			IR3J_FitSphere()
			IR3J_CalculateModel()		
			break
		case "Spheroid":			// Spheroid
			IR3J_FitSpheroid()
			IR3J_CalculateModel()		
			break
		case "Invariant":			// Spheroid
			IR3J_InvFitBackground()
			IR3J_InvCalculateInvariant()	
			break
		case "Volume Size Distribution":			// Spheroid
			IR3J_FitSizeDistribution("Volume")
			//IR3J_CalculateModel()		
			break
		case "Number Size Distribution":			// Spheroid
			IR3J_FitSizeDistribution("Number")
			//IR3J_CalculateModel()		
			break
		default:			
		//nothing here.
		Abort "No model calculated in static IR3J_FitData()" 
	endswitch

end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3J_FitSequenceOfData()

		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		//warn user if not saving results...
		NVAR SaveToNotebook=root:Packages:Irena:SimpleFits:SaveToNotebook
		NVAR SaveToWaves=root:Packages:Irena:SimpleFits:SaveToWaves
		NVAR SaveToFolder=root:Packages:Irena:SimpleFits:SaveToFolder
		NVAR DelayBetweenProcessing=root:Packages:Irena:SimpleFits:DelayBetweenProcessing
		if(SaveToNotebook+SaveToWaves+SaveToFolder<1)
			DoAlert /T="Results not being saved anywhere" 1, "Results of the fits are not being saved anywhere. Do you want to continue (Yes) or abort (No)?"
			if(V_Flag==2)
				abort
			endif
		endif	
		if(SaveToFolder)
			print "Fit results will be saved in original fits as Intensity and Q vector"
		endif
		if(SaveToWaves)
			print "Fit results will be saved in waves to create a table"
		endif
		if(SaveToNotebook)
			print "Fit results will be saved in notebook"
		endif
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
				IR3J_SaveResultsToFolder()
				DoUpdate 
				sleep/S/C=6/M="Fitted data for "+ListOfAvailableData[i] DelayBetweenProcessing
			endif
		endfor
		//IR3J_CleanUnusedParamWaves()
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
		case 7:				//cursor moved
			if(StringMatch(s.cursorName, "A")||StringMatch(s.cursorName, "B"))
				IR3J_SyncCursorsTogether(s.traceName,s.cursorName,s.pointNumber)
			elseif(StringMatch(s.cursorName, "C")||StringMatch(s.cursorName, "D"))
				//this resets Qmin and Qmax even when added through code and cursors moved due to 
				//code setting cursor to nearest point. There does not seem to be any way to catch this
				//in both cases we get cursor moved event 7 and no other info
				//the only thing which seems to be useful is, that mouse loc may be outside the graph...  
				//still will fail, if user moves mouse inside the graph while running sequence. Not sur ehow to fix that. 
				GetWindow /Z IR3J_LogLogDataDisplay  gsize 
				//V_left, V_right, V_top, and V_bottom
				if( s.mouseLoc.v>V_top && s.mouseLoc.v<(V_bottom-V_top) && s.mouseLoc.h>V_left && s.mouseLoc.h<(V_right-V_left)) 
					//print "fixed position"
					//print s.mouseLoc.v
					//print s.mouseLoc.h
					IR3J_InvSyncBckgCursors(1)
				endif
			endif
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

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IR3J_CreateCheckGraphs()
	NVAR DataQEnd = root:Packages:Irena:SimpleFits:DataQEnd
	NVAR DataQstart = root:Packages:Irena:SimpleFits:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:SimpleFits:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:SimpleFits:DataQstartPoint
	Wave OriginalDataQWave=root:Packages:Irena:SimpleFits:OriginalDataQWave
	Wave/Z LinModelDataIntWave=root:Packages:Irena:SimpleFits:LinModelDataIntWave
	Wave OriginalDataIntWave=root:Packages:Irena:SimpleFits:OriginalDataIntWave
	Wave/Z LinModelDataQWave=root:Packages:Irena:SimpleFits:LinModelDataQWave
	variable tempMaxQ, tempMaxQY, tempMinQY, maxY, minY
	variable LinDataExist = 0
	DoWIndow IR3J_LinDataDisplay		//does linearization graph even exist???
	if(V_Flag)
		LinDataExist = 1
	endif
	//check if user removed cursor from graph, in which case do nothing for now...
	if(numtype(PointNumber)==0)
		if(stringmatch(CursorName,"A"))		//moved cursor A, which is start of Q range
			DataQstartPoint = PointNumber
			DataQstart = OriginalDataQWave[PointNumber]
			//now move the cursor in the other graph... 
			if(StringMatch(traceName, "OriginalDataIntWave" ))
				if(LinDataExist)
					checkDisplayed /W=IR3J_LinDataDisplay LinModelDataIntWave
					if(V_Flag)
						//GetAxis/W=IR3J_LinDataDisplay /Q left
						cursor /W=IR3J_LinDataDisplay A, LinModelDataIntWave, DataQstartPoint
						tempMaxQ = LinModelDataQWave[DataQEndPoint]
						tempMaxQY = LinModelDataIntWave[DataQstartPoint]
						tempMinQY = LinModelDataIntWave[DataQEndPoint]
						maxY = max(tempMaxQY, tempMinQY)
						minY = min(tempMaxQY, tempMinQY)
						if(maxY>0)
							maxY*=SimpleFitsLinPlotMaxScale
						else
							maxY*=SimpleFitsLinPlotMinScale
						endif
						if(minY>0)
							minY*=SimpleFitsLinPlotMinScale
						else
							minY*=SimpleFitsLinPlotMaxScale
						endif
						if(maxY>0)
							maxY*=SimpleFitsLinPlotMaxScale
						else
							maxY*=SimpleFitsLinPlotMinScale
						endif
						SetAxis /W=IR3J_LinDataDisplay left minY, maxY
						SetAxis/W=IR3J_LinDataDisplay bottom 0,tempMaxQ*SimpleFitsLinPlotMaxScale
					endif
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
				if(LinDataExist)
					checkDisplayed /W=IR3J_LinDataDisplay LinModelDataIntWave
					if(V_Flag)
						cursor /W=IR3J_LinDataDisplay B, LinModelDataIntWave, DataQEndPoint
						tempMaxQ = LinModelDataQWave[DataQEndPoint]
						tempMaxQY = LinModelDataIntWave[DataQstartPoint]
						tempMinQY = LinModelDataIntWave[DataQEndPoint]
						maxY = max(tempMaxQY, tempMinQY)
						minY = min(tempMaxQY, tempMinQY)
						if(maxY>0)
							maxY*=SimpleFitsLinPlotMaxScale
						else
							maxY*=SimpleFitsLinPlotMinScale
						endif
						if(minY>0)
							minY*=SimpleFitsLinPlotMinScale
						else
							minY*=SimpleFitsLinPlotMaxScale
						endif
						SetAxis/W=IR3J_LinDataDisplay left minY, maxY
						GetAxis/W=IR3J_LinDataDisplay/Q bottom
						SetAxis/W=IR3J_LinDataDisplay bottom V_min, SimpleFitsLinPlotMaxScale*LinModelDataQWave[DataQEndPoint]
					endif
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

static Function IR3J_FitGuinier(which)
	string which			//Sphere, Rod, Sheet
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	if(!WaveExists(CursorAWave)||!WaveExists(CursorBWave))
		Abort "Daat do not exist or cursors are not properly set on same wave"
	endif
	Wave CursorAXWave= CsrXWaveRef(A, "IR3J_LogLogDataDisplay")
	Wave OriginalDataErrorWave=root:Packages:Irena:SimpleFits:OriginalDataErrorWave
	//make a good starting guesses:
	Guinier_I0 = CursorAXWave[DataQstartPoint]
	Guinier_Rg = pi/(DataQEnd/2)
	W_coef[0]=Guinier_I0  	//G
	W_coef[1]=Guinier_Rg		//Rg
	T_Constraints[0] = {"K0 > 0"}
	T_Constraints[1] = {"K1 > "+num2str(Guinier_Rg/10)}
	LocalEwave[0]=(Guinier_I0/50)
	LocalEwave[1]=(Guinier_Rg/50)
	variable QminFit, QmaxFit
	QminFit = CursorAXWave[DataQstartPoint]
	QmaxFit = CursorAXWave[DataQEndPoint]
	variable/g V_FitError
	
	V_FitError=0			//This should prevent errors from being generated
	strswitch(which)		// string switch
		case "Sphere":		// execute if case matches expression
			FuncFit IR1_GuinierFit W_coef CursorAWave[DataQstartPoint,DataQEndPoint] /X=CursorAXWave /C=T_Constraints /W=OriginalDataErrorWave /I=1 /E=LocalEwave
			break					// exit from switch
		case "Rod":	// execute if case matches expression
			FuncFit IR1_GuinierRodFit W_coef CursorAWave[DataQstartPoint,DataQEndPoint] /X=CursorAXWave /C=T_Constraints /W=OriginalDataErrorWave /I=1 /E=LocalEwave
			break
		case "Sheet":	// execute if case matches expression
			FuncFit IR1_GuinierSheetFit W_coef CursorAWave[DataQstartPoint,DataQEndPoint] /X=CursorAXWave /C=T_Constraints /W=OriginalDataErrorWave /I=1 /E=LocalEwave
			break
		default:			// optional default expression executed
			abort
	endswitch
	if (V_FitError!=0)	//there was error in fitting
		RemoveFromGraph/W=IR3J_LogLogDataDisplay /Z $("fit_"+NameOfWave(CursorAWave))
		beep
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	Wave W_sigma
	W_coef =  abs(W_coef)
	string TagText, TagTextLin
	AchievedChiSquare = V_chisq/(DataQEndPoint-DataQstartPoint)
	string QminRg, QmaxRg, AchiCHiStr
	sprintf QminRg, "%2.2f",(W_coef[1]*QminFit)
	sprintf QmaxRg, "%2.2f",(W_coef[1]*QmaxFit)
	sprintf AchiCHiStr, "%2.2f",(AchievedChiSquare)
	strswitch(which)		// string switch
		case "Sphere":		// execute if case matches expression
			TagText = "Fited Guinier : I(Q) = I(0)*exp(-q\\S2\\M*Rg\\S2\\M/3)\rI(0) = "+num2str(W_coef[0])+"\tRg = "+num2str(W_coef[1])
			TagText+="\rQ\Bmin\MRg = "+QminRg+"\tQ\Bmax\MRg = "+QmaxRg
			TagText+="\rχ\\S2\\M  = "+AchiCHiStr
			TagTextLin = "I(0) = "+num2str(W_coef[0])+"\tRg = "+num2str(W_coef[1])
			TagTextLin+="\rQ\Bmin\MRg = "+QminRg+"\tQ\Bmax\MRg = "+QmaxRg
			TagTextLin +="\rχ\\S2\\M  = "+AchiCHiStr
			break					// exit from switch
		case "Rod":	// execute if case matches expression
//			TagText = "Fitted Guinier  "+"Int*Q = G*exp(-q^2*Rg^2/2))"+" \r G = "+num2str(W_coef[0])+"\r Rc = "+num2str(W_coef[1])
//			TagText+="\rchi-square = "+num2str(V_chisq)
			TagText = "Fited Guinier : I(Q)*Q = I(0)*exp(-q\\S2\\M*Rg\\S2\\M/2)\rI(0) = "+num2str(W_coef[0])+";   Rc = "+num2str(W_coef[1])
			TagText+="\rQ\Bmin\MRg = "+QminRg+"\tQ\Bmax\MRg = "+QmaxRg
			TagText+="\rχ\\S2\\M  = "+AchiCHiStr
			TagTextLin = "I(0) = "+num2str(W_coef[0])+"\t\tRc = "+num2str(W_coef[1])
			TagTextLin+="\rQ\Bmin\MRg = "+QminRg+"\tQ\Bmax\MRg = "+QmaxRg
			TagTextLin +="\rχ\\S2\\M  = "+AchiCHiStr
			break
		case "Sheet":	// execute if case matches expression
//			TagText = "Fitted Guinier  "+"Int*Q^2 = G*exp(-q^2*Rg^2))"+" \r G = "+num2str(W_coef[0])+"\r Rg = "+num2str(W_coef[1])
//			TagText+="\r Thickness = "+num2str(W_coef[1]*sqrt(12))
//			TagText+="\r chi-square = "+num2str(V_chisq)
			TagText = "Fited Guinier : I(Q)*Q\S2\M = I(0)*exp(-q\\S2\\M*Rg\\S2\\M)\rI(0) = "+num2str(W_coef[0])+"\tRg = "+num2str(W_coef[1])
			TagText+="\rThickness = "+num2str(W_coef[1]*sqrt(12))
			TagText+="\rQ\Bmin\MRg = "+QminRg+"\tQ\Bmax\MRg = "+QmaxRg
			TagText+="\rχ\\S2\\M  = "+AchiCHiStr
			TagTextLin = "I(0) = "+num2str(W_coef[0])+"\tRg = "+num2str(W_coef[1])
			TagTextLin+="\rThickness = "+num2str(W_coef[1]*sqrt(12))
			TagTextLin+="\rQ\Bmin\MRg = "+QminRg+"\tQ\Bmax\MRg = "+QmaxRg
			TagTextLin +="\rχ\\S2\\M  = "+AchiCHiStr
			break
		default:			// optional default expression executed
			abort
	endswitch
	string TagName= "GuinierFit" //UniqueName("GuinierFit",14,0,"IR3J_LogLogDataDisplay")
	Tag/C/W=IR3J_LogLogDataDisplay/N=$(TagName)/L=2/X=-15.00/Y=-15.00  $NameOfWave(CursorAWave), ((DataQstartPoint + DataQEndPoint)/2),TagText	
	
	DoWindow IR3J_LinDataDisplay
	if(V_Flag)
		Wave/Z CursorAWaveLin = CsrWaveRef(A, "IR3J_LinDataDisplay")	
		Tag/C/W=IR3J_LinDataDisplay/N=$(TagName)/L=2/X=15.00/Y=15.00  $NameOfWave(CursorAWaveLin), ((DataQstartPoint + DataQEndPoint)/2),TagTextLin	
	endif
	
	Guinier_I0=W_coef[0] 	//G
	Guinier_Rg=W_coef[1]	//Rg

	SetDataFolder oldDf

end


//**********************************************************************************************************
//**********************************************************************************************************
Function IR1_GuinierRodFit(w,q) : FitFunc
	Wave w
	Variable q

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ Prefactor=abs(Prefactor)
	//CurveFitDialog/ Rg=abs(Rg)
	//CurveFitDialog/ f(q) = Prefactor*exp(-q^2*Rg^2/3))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Prefactor
	//CurveFitDialog/ w[1] = Rg

	w[0]=abs(w[0])
	w[1]=abs(w[1])
	return w[0]*exp(-q^2 * w[1]^2/2)/q
End
//**********************************************************************************************************
Function IR1_GuinierSheetFit(w,q) : FitFunc
	Wave w
	Variable q

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ Prefactor=abs(Prefactor)
	//CurveFitDialog/ Rg=abs(Rg)
	//CurveFitDialog/ f(q) = Prefactor*exp(-q^2*Rg^2/3))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Prefactor
	//CurveFitDialog/ w[1] = Rg

	w[0]=abs(w[0])
	w[1]=abs(w[1])
	return w[0]/(q*q) * exp(-q^2*w[1]^2)
End
//*****************************************************************************************************************
Function IR3J_Gauss1D(w,q) : FitFunc
	Wave w
	Variable q

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(q) = (A / (sigma*sqrt(2*pi)) * exp((-1/2)*((q-q0)/sigma)^2)+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = q0
	//CurveFitDialog/ w[2] = sigma
	//CurveFitDialog/ w[3] = y0

	return w[0]/(w[2]*sqrt(2*pi))*exp((-1/2)*((q-w[1])/w[2])^2) + w[3]
End
Function IR3J_Porod_Ruland(w,q) : FitFunc
	Wave w
	Variable q

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(q) = A*exp(B*q^2)+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = B
	//CurveFitDialog/ w[2] = y0

	return w[0]*exp(w[1]*q^2)+w[2]
End


//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3J_FitPorod()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	Wave/Z CursorAWave = CsrWaveRef(A, "IR3J_LogLogDataDisplay")
	Wave/Z CursorBWave = CsrWaveRef(B, "IR3J_LogLogDataDisplay")
	Wave CursorAXWave= CsrXWaveRef(A, "IR3J_LogLogDataDisplay")
	Wave OriginalDataErrorWave=root:Packages:Irena:SimpleFits:OriginalDataErrorWave
	Make/D/N=0/O W_coef, LocalEwave
	Make/D/T/N=0/O T_Constraints
	Wave/Z W_sigma
	Redimension /N=2 W_coef, LocalEwave
	Redimension/N=1 T_Constraints
	T_Constraints[0] = {"K1 > 0"}
	if(!WaveExists(CursorAWave)||!WaveExists(CursorBWave))
		Abort "Cursors are not properly set on same wave"
	endif
	//make a good starting guesses:
	Porod_Constant=CursorAWave[DataQstartPoint]/(CursorAXWave[DataQstartPoint]^(-4))
	DataBackground=CursorAwave[DataQEndPoint]
	W_coef = {Porod_Constant,DataBackground}
	LocalEwave[0]=(Porod_Constant/20)
	LocalEwave[1]=(DataBackground/20)

	variable/g V_FitError=0			//This should prevent errors from being generated
	FuncFit PorodInLogLog W_coef CursorAWave[DataQstartPoint,DataQEndPoint] /X=CursorAXWave /C=T_Constraints /W=OriginalDataErrorWave /I=1
	if (V_FitError==0)	// fitting was fine... 
		Wave W_sigma
		AchievedChiSquare = V_chisq/(DataQEndPoint-DataQstartPoint)
		string QminRg, QmaxRg, AchiCHiStr
		sprintf AchiCHiStr, "%2.2f",(AchievedChiSquare)
		string TagText
		TagText = "Fitted Porod  "+"I(Q) = P\BC\M * Q\S-4\M + background"+" \r P\BC\M = "+num2str(W_coef[0])+"\r Background = "+num2str(W_coef[1])
		TagText +="\rχ\\S2\\M  = "+AchiCHiStr
		string TagName= "PorodFit" 
		Tag/C/W=IR3J_LogLogDataDisplay/N=$(TagName)/L=2/X=-15.00/Y=-15.00  $NameOfWave(CursorAWave), ((DataQstartPoint + DataQEndPoint)/2),TagText	
		Porod_Constant=W_coef[0] 	//PC
		DataBackground=W_coef[1]	//Background
	else
		RemoveFromGraph/Z $("fit_"+NameOfWave(CursorAWave))
		beep
		Print "Fitting error, check starting parameters and fitting limits" 
		Porod_Constant=0 	//PC
		DataBackground=0	//Background
		AchievedChiSquare = 0
	endif
	SetDataFolder oldDf
end



//**********************************************************************************************************
//**********************************************************************************************************

Function IR3J_FitSizeDistribution(Which)
	string Which			//"Volume" or "Number" 
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	Wave/Z CursorAWave = CsrWaveRef(A, "IR3J_LogLogDataDisplay")
	Wave/Z CursorBWave = CsrWaveRef(B, "IR3J_LogLogDataDisplay")
	Wave CursorAXWave= CsrXWaveRef(A, "IR3J_LogLogDataDisplay")
	Wave OriginalDataErrorWave=root:Packages:Irena:SimpleFits:OriginalDataErrorWave
	NVAR VOlSD_Rg					=root:Packages:Irena:SimpleFits:VOlSD_Rg
	NVAR VolSD_Volume				=root:Packages:Irena:SimpleFits:VolSD_Volume
	NVAR VolSD_MeanDiameter		=root:Packages:Irena:SimpleFits:VolSD_MeanDiameter
	NVAR VolSD_MedianDiameter	=root:Packages:Irena:SimpleFits:VolSD_MedianDiameter
	NVAR VOlSD_ModeDiamater		=root:Packages:Irena:SimpleFits:VOlSD_ModeDiamater
	NVAR NumSD_NumPartPerCm3		=root:Packages:Irena:SimpleFits:NumSD_NumPartPerCm3
	NVAR NumSD_MeanDiameter		=root:Packages:Irena:SimpleFits:NumSD_MeanDiameter
	NVAR NumSD_MedianDiameter	=root:Packages:Irena:SimpleFits:NumSD_MedianDiameter
	NVAR NumSD_ModeDiamater		=root:Packages:Irena:SimpleFits:NumSD_ModeDiamater
	SVAR QWavename 					=root:Packages:Irena:SimpleFits:QWavename

	if(!WaveExists(CursorAWave)||!WaveExists(CursorBWave))
		Abort "Cursors are not properly set on same wave"
	endif
	Duplicate/Free/R=[DataQstartPoint, DataQEndPoint] CursorAXWave, TempXWave
	Duplicate/Free/R=[DataQstartPoint, DataQEndPoint] CursorAWave, TempYWave, temp_cumulative, temp_probability, Another_temp
	Another_temp=temp_probability*tempXwave
	variable Rg, MeanDia, MedianDia, modeDia
	string TagText
	variable AreaUnderTheCurve = areaXY(CursorAXWave, CursorAWave, DataQstart, DataQEnd)
	if(StringMatch(QWavename, "*Diame*" ))
		Rg=IR2L_CalculateRg(TempXWave,TempYWave,1)		//Dimension is diameter, 3rd parameter is 1 if DimensionIsDiameter
		MeanDia=areaXY(tempXwave, Another_temp,0,inf)	/ areaXY(tempXwave, temp_probability,0,inf)				//Sum P(D)*D*deltaD/P(D)*deltaD
		//median
		Temp_Cumulative=areaXY(tempXwave, Temp_Probability, tempXwave[0], tempXwave[p] )
		MedianDia = tempXwave[BinarySearchInterp(Temp_Cumulative, 0.5*Temp_Cumulative[numpnts(Temp_Cumulative)-1] )]		//R for which cumulative probability=0.5
		//mode
		FindPeak/P/Q Temp_Probability
		modeDia=tempXwave[V_PeakLoc]								//location of maximum on the P(R)
	else
		Rg=IR2L_CalculateRg(TempXWave,TempYWave,0)		//Dimension is radius, 3rd parameter is 0 
		MeanDia=2*areaXY(tempXwave, Another_temp,0,inf)	/ areaXY(tempXwave, temp_probability,0,inf)				//Sum P(D)*D*deltaD/P(D)*deltaD, corrected to diameter
		//median
		Temp_Cumulative=areaXY(tempXwave, Temp_Probability, tempXwave[0], tempXwave[p] )
		MedianDia = 2* tempXwave[BinarySearchInterp(Temp_Cumulative, 0.5*Temp_Cumulative[numpnts(Temp_Cumulative)-1] )]		//Diameter for which cumulative probability=0.5
		//mode
		FindPeak/P/Q Temp_Probability
		modeDia=2* tempXwave[V_PeakLoc]								//location of maximum on the P(D)
	endif
	if(StringMatch(Which, "Number" ))
		NumSD_NumPartPerCm3 	= AreaUnderTheCurve
		NumSD_MeanDiameter  	= MeanDia
		NumSD_MedianDiameter	= MedianDia
		NumSD_ModeDiamater		= modeDia 
		TagText = "Number Size Distribution analysis \r"+"Number of particles/cm3 = "+num2str(AreaUnderTheCurve)
		TagText+="\r Mean Diameter [A] = "+num2str(MeanDia)
		TagText+="\r Mode Dia [A] = "+num2str(modeDia)+"\tMedian Diameter [A] = "+num2str(MedianDia)
	else		//default is volume
		VOlSD_Rg					= Rg
		VolSD_Volume				= AreaUnderTheCurve
		VolSD_MeanDiameter		= MeanDia
		VolSD_MedianDiameter 	= MedianDia
		VOlSD_ModeDiamater		= modeDia
		TagText = "Volume Size Distribution analysis \r"+"Volume fraction = "+num2str(AreaUnderTheCurve)
		TagText+="\r Rg = "+num2str(Rg)+"\tMean Diameter [A] = "+num2str(MeanDia)
		TagText+="\r Mode Dia [A] = "+num2str(modeDia)+"\tMedian Diameter [A] = "+num2str(MedianDia)
	endif
	//make a good starting guesses:
	AchievedChiSquare = 0
	string TagName= "SizeDistribution" 
	Tag/C/W=IR3J_LogLogDataDisplay/N=$(TagName)/L=2/X=-15.00/Y=-15.00  $NameOfWave(CursorAWave), ((DataQstartPoint + DataQEndPoint)/2),TagText	
	SetDataFolder oldDf

end

//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3J_FitSphere()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	W_coef = {SphereScalingConst, SphereRadius,DataBackground}	
	LocalEwave[0]=(SphereScalingConst/20)
	LocalEwave[1]=(SphereRadius/20)
	LocalEwave[2]=(DataBackground/20)

	variable/g V_FitError=0			//This should prevent errors from being generated
//		if (FitUseErrors && WaveExists(ErrorWave))
	FuncFit IR3J_SphereFormfactor W_coef CursorAWave[DataQstartPoint,DataQEndPoint] /X=CursorAXWave /C=T_Constraints /W=OriginalDataErrorWave /I=1
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
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	T_Constraints[2] = {"K2 < 20"}
	T_Constraints[3] = {"K2 > 0.05"}
	T_Constraints[4] = {"K3 < K0/20"}
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
	DataBackground=0.01*CursorAwave[DataQEndPoint]
	Spheroid_Beta = 1
	W_coef = {Spheroid_ScalingConstant, Spheroid_Radius,Spheroid_Beta,DataBackground}
	
	LocalEwave[0]=(Spheroid_ScalingConstant/20)
	LocalEwave[1]=(Spheroid_Radius/20)
	LocalEwave[2]=(1/20)
	LocalEwave[3]=(DataBackground/20)

	variable/g V_FitError=0			//This should prevent errors from being generated
//		if (FitUseErrors && WaveExists(ErrorWave))
	FuncFit IR3J_SpheroidFormfactor W_coef CursorAWave[DataQstartPoint,DataQEndPoint] /X=CursorAXWave /C=T_Constraints /W=OriginalDataErrorWave /I=1
//		else
//			FuncFit PorodInLogLog W_coef CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D /C=T_Constraints			
//		endif
	if (V_FitError!=0)	//there was error in fitting
		RemoveFromGraph $("fit_"+NameOfWave(CursorAWave))
		beep
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	Wave W_sigma
	AchievedChiSquare = V_chisq/(DataQEndPoint-DataQstartPoint)
	string TagText
	TagText = "Fitted Spheroid Form Factor   \r"+"Int=Scale*SpheroidFF(Q,R,beta)+bck"+" \r Radius [A] = "+num2str(W_coef[1])+" \r Aspect ratio = "+num2str(W_coef[2])+" \r Scale = "+num2str(W_coef[0])
	TagText+="\r Background = "+num2str(W_coef[3])
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

	return w[0]*IR1T_CalcIntgSpheroidFFPoints(Q,w[1],w[2])+w[3]
End




//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function IR3J_CalculateModel()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	Wave/Z LinModelDataIntWave		=root:Packages:Irena:SimpleFits:LinModelDataIntWave
	Wave/Z LinModelDataQWave		=root:Packages:Irena:SimpleFits:LinModelDataQWave
	Wave/Z LinModelDataEWave		=root:Packages:Irena:SimpleFits:LinModelDataEWave
	NVAR AchievedChiSquare		=root:Packages:Irena:SimpleFits:AchievedChiSquare
	NVAR Guinier_I0 				= root:Packages:Irena:SimpleFits:Guinier_I0
	NVAR Guinier_Rg					=root:Packages:Irena:SimpleFits:Guinier_Rg
	NVAR Porod_Constant				=root:Packages:Irena:SimpleFits:Porod_Constant
	NVAR Porod_SpecificSurface	=root:Packages:Irena:SimpleFits:Porod_SpecificSurface
	NVAR ScatteringContrast		=root:Packages:Irena:SimpleFits:ScatteringContrast
	NVAR Sphere_Radius				=root:Packages:Irena:SimpleFits:Sphere_Radius
	NVAR Sphere_ScalingConstant	=root:Packages:Irena:SimpleFits:Sphere_ScalingConstant
	NVAR Spheroid_Radius			=root:Packages:Irena:SimpleFits:Spheroid_Radius
	NVAR Spheroid_ScalingConstant=root:Packages:Irena:SimpleFits:Spheroid_ScalingConstant
	NVAR Spheroid_Beta				=root:Packages:Irena:SimpleFits:Spheroid_Beta
	NVAR DataBackground			=root:Packages:Irena:SimpleFits:DataBackground
	SVAR SimpleModel 				= root:Packages:Irena:SimpleFits:SimpleModel

	Duplicate/O/R=[DataQstartPoint,DataQEndPoint] OriginalDataQWave, ModelLogLogQ, ModelLogLogInt, NormalizedResidualLogLogQ
	Duplicate/O/R=[DataQstartPoint,DataQEndPoint] OriginalDataIntWave, NormalizedResidualLogLog, ZeroLineResidualLogLog
	ZeroLineResidualLogLog = 0
	//do we need linearized data? 
	variable UsingLinearizedModel=0
	if(WaveExists(LinModelDataIntWave))
		UsingLinearizedModel=1
		Duplicate/O/R=[DataQstartPoint,DataQEndPoint] LinModelDataQWave, ModelLlinLinQ2, ModelLinLinLogInt, NormalizedResidualLinLinQ
		Duplicate/O/R=[DataQstartPoint,DataQEndPoint] LinModelDataIntWave, NormalizedResidualLinLin, ZeroLineResidualLinLin
		ZeroLineResidualLinLin = 0
	else
		UsingLinearizedModel=0
		KillWaves/Z ModelLinLinQ2, ModelLinLinLogInt, NormalizedResidualLinLinQ, NormalizedResidualLinLin, ZeroLineResidualLinLin
	endif

	Duplicate/Free/R=[DataQstartPoint,DataQEndPoint] OriginalDataIntWave, TempOriginalIntensity
	Duplicate/Free/R=[DataQstartPoint,DataQEndPoint] OriginalDataErrorWave, TempOriginalError
	if(UsingLinearizedModel)
		Duplicate/Free/R=[DataQstartPoint,DataQEndPoint] LinModelDataEWave, TempLinError
		Duplicate/Free/R=[DataQstartPoint,DataQEndPoint] LinModelDataIntWave, TempLinIntensity
	endif
	//now calculate the data... 
	strswitch(SimpleModel)				// Guinier
		case "Guinier":						// execute if case matches expression
			ModelLogLogInt = Guinier_I0 *exp(-ModelLogLogQ[p]^2*Guinier_Rg^2/3)
			if(UsingLinearizedModel)
				ModelLinLinLogInt = ln(ModelLogLogInt)	
			endif
			break								// exit from switch
		case "Guinier Rod":				// Guinier rod
			ModelLogLogInt = Guinier_I0*exp(-ModelLogLogQ[p]^2*Guinier_Rg^2/2)/ModelLogLogQ
			if(UsingLinearizedModel)
				ModelLinLinLogInt = ln(ModelLogLogInt*ModelLogLogQ)	
			endif
			break		
		case "Guinier Sheet":				// Guinier Sheet
			ModelLogLogInt = Guinier_I0 *exp(-ModelLogLogQ[p]^2*Guinier_Rg^2)*ModelLogLogQ^(-2)
			if(UsingLinearizedModel)
				ModelLinLinLogInt = ln(ModelLogLogInt*ModelLogLogQ^2)	
			endif
			break		
		case "Porod":						// Porod
			Porod_SpecificSurface =Porod_Constant *1e32 / (2*pi*ScatteringContrast*1e20)
			ModelLogLogInt = DataBackground+Porod_Constant * ModelLogLogQ^(-4)
			if(UsingLinearizedModel)
				ModelLinLinLogInt = ModelLogLogInt*ModelLogLogQ^4	
			endif
			break
		case "Sphere":						// spehre calculation
			ModelLogLogInt = DataBackground + 	Sphere_ScalingConstant * (3/(ModelLogLogQ[p]*Sphere_Radius)^3)*(sin(ModelLogLogQ[p]*Sphere_Radius)-(ModelLogLogQ[p]*Sphere_Radius*cos(ModelLogLogQ[p]*Sphere_Radius)))
			break
		case "Spheroid":					// spheroid
			ModelLogLogInt = 	DataBackground +  Spheroid_ScalingConstant*IR1T_CalcIntgSpheroidFFPoints(ModelLogLogQ[p],Spheroid_Radius,Spheroid_Beta)
			break
		default:						// optional default expression executed
		//nothing is default here, so set values to 0 to know there is problem. 
		ModelLogLogInt = 0
		if(UsingLinearizedModel)
			ModelLinLinLogInt = 0	
		endif		
	endswitch
	//calculate residuals, chi^2 and append to graph
	NormalizedResidualLogLog = (TempOriginalIntensity-ModelLogLogInt)/TempOriginalError
	Duplicate/Free NormalizedResidualLogLog, ChiSquareTemp
	ChiSquareTemp = ((TempOriginalIntensity-ModelLogLogInt)/TempOriginalError)^2
	AchievedChiSquare = (sum(ChiSquareTemp)/numpnts(ChiSquareTemp))
	CheckDisplayed /W=IR3J_LogLogDataDisplay ModelLogLogInt
	if(!V_flag)
		AppendToGraph /W=IR3J_LogLogDataDisplay  ModelLogLogInt  vs ModelLogLogQ
		ModifyGraph/W=IR3J_LogLogDataDisplay  lsize(ModelLogLogInt)=3,rgb(ModelLogLogInt)=(0,0,0)
	endif
	CheckDisplayed /W=IR3J_LogLogDataDisplay NormalizedResidualLogLog
	if(!V_flag)
			//ModifyGraph /W=IR3J_LogLogDataDisplay standoff(left)=0,axisEnab(left)={0,1}
			AppendToGraph /W=IR3J_LogLogDataDisplay /L=VertCrossing NormalizedResidualLogLog vs NormalizedResidualLogLogQ
			ModifyGraph/W=IR3J_LogLogDataDisplay mode(NormalizedResidualLogLog)=2,rgb(NormalizedResidualLogLog)=(0,0,0)
			ModifyGraph/W=IR3J_LogLogDataDisplay  mirror=1,nticks(VertCrossing)=0,axisEnab(VertCrossing)={0,0.1},freePos(VertCrossing)=0
			SetAxis/W=IR3J_LogLogDataDisplay /A/E=2 VertCrossing
			ModifyGraph/W=IR3J_LogLogDataDisplay standoff=0
			//Label/W=IR3J_LogLogDataDisplay VertCrossing "Norm res"
			AppendToGraph /W=IR3J_LogLogDataDisplay /L=VertCrossing ZeroLineResidualLogLog vs NormalizedResidualLogLogQ
			ModifyGraph/W=IR3J_LogLogDataDisplay rgb(ZeroLineResidualLogLog)=(0,0,0)
	endif
	//now same, if we are using linearized data
	if(UsingLinearizedModel)
		NormalizedResidualLinLin = (TempLinIntensity-ModelLinLinLogInt)/TempLinError
		CheckDisplayed /W=IR3J_LinDataDisplay ModelLinLinLogInt
		if(!V_flag)
			AppendToGraph /W=IR3J_LinDataDisplay  ModelLinLinLogInt  vs ModelLlinLinQ2
			ModifyGraph/W=IR3J_LinDataDisplay  lsize(ModelLinLinLogInt)=2,rgb(ModelLinLinLogInt)=(0,0,0)
		endif
	
		CheckDisplayed /W=IR3J_LinDataDisplay NormalizedResidualLinLin
		if(!V_flag)
			//AppendToGraph /W=IR3J_LinDataDisplay/R  NormalizedResidualLinLin  vs NormalizedResidualLinLinQ
			//ModifyGraph/W=IR3J_LinDataDisplay mode(NormalizedResidualLinLin)=2,lsize(NormalizedResidualLinLin)=3,rgb(NormalizedResidualLinLin)=(0,0,0)
			//Label/W=IR3J_LinDataDisplay right "Norm res"
			//ModifyGraph /W=IR3J_LinDataDisplay standoff(left)=0,axisEnab(left)={0,1}
			AppendToGraph /W=IR3J_LinDataDisplay /L=VertCrossing NormalizedResidualLinLin vs NormalizedResidualLinLinQ
			ModifyGraph/W=IR3J_LinDataDisplay mode(NormalizedResidualLinLin)=2,rgb(NormalizedResidualLinLin)=(0,0,0)
			ModifyGraph/W=IR3J_LinDataDisplay  mirror=1,nticks(VertCrossing)=0,axisEnab(VertCrossing)={0,0.1},freePos(VertCrossing)=0
			SetAxis/W=IR3J_LinDataDisplay /A/E=2 VertCrossing
			ModifyGraph/W=IR3J_LinDataDisplay standoff=0
			AppendToGraph /W=IR3J_LinDataDisplay /L=VertCrossing ZeroLineResidualLinLin vs NormalizedResidualLinLinQ
			ModifyGraph /W=IR3J_LinDataDisplay rgb(ZeroLineResidualLinLin)=(0,0,0)
		endif

	endif
	SetDataFolder oldDf

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function IR3J_SaveResultsToNotebook()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR SaveToNotebook=root:Packages:Irena:SimpleFits:SaveToNotebook
	NVAR SaveToWaves=root:Packages:Irena:SimpleFits:SaveToWaves
	NVAR SaveToFolder=root:Packages:Irena:SimpleFits:SaveToFolder
	if(!SaveToNotebook)
		return 0
	endif	
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
	NVAR Porod_SpecificSurface			=root:Packages:Irena:SimpleFits:Porod_SpecificSurface
	NVAR ScatteringContrast			=root:Packages:Irena:SimpleFits:ScatteringContrast
	NVAR Sphere_Radius				=root:Packages:Irena:SimpleFits:Sphere_Radius
	NVAR Sphere_ScalingConstant	=root:Packages:Irena:SimpleFits:Sphere_ScalingConstant
	NVAR Spheroid_Radius			=root:Packages:Irena:SimpleFits:Spheroid_Radius
	NVAR Spheroid_ScalingConstant=root:Packages:Irena:SimpleFits:Spheroid_ScalingConstant
	NVAR Spheroid_Beta				=root:Packages:Irena:SimpleFits:Spheroid_Beta
	NVAR DataBackground			=root:Packages:Irena:SimpleFits:DataBackground
	SVAR SimpleModel 				= root:Packages:Irena:SimpleFits:SimpleModel

	NVAR VOlSD_Rg					=root:Packages:Irena:SimpleFits:VOlSD_Rg
	NVAR VolSD_Volume				=root:Packages:Irena:SimpleFits:VolSD_Volume
	NVAR VolSD_MeanDiameter		=root:Packages:Irena:SimpleFits:VolSD_MeanDiameter
	NVAR VolSD_MedianDiameter	=root:Packages:Irena:SimpleFits:VolSD_MedianDiameter
	NVAR VOlSD_ModeDiamater		=root:Packages:Irena:SimpleFits:VOlSD_ModeDiamater
	NVAR NumSD_NumPartPerCm3		=root:Packages:Irena:SimpleFits:NumSD_NumPartPerCm3
	NVAR NumSD_MeanDiameter		=root:Packages:Irena:SimpleFits:NumSD_MeanDiameter
	NVAR NumSD_MedianDiameter	=root:Packages:Irena:SimpleFits:NumSD_MedianDiameter
	NVAR NumSD_ModeDiamater		=root:Packages:Irena:SimpleFits:NumSD_ModeDiamater

	NVAR InvQmaxUsed =	root:Packages:Irena:SimpleFits:InvQmaxUsed
	NVAR Invariant =	root:Packages:Irena:SimpleFits:invariant
	NVAR DataQEnd = 	root:Packages:Irena:SimpleFits:DataQEnd
	NVAR DataQstart = 	root:Packages:Irena:SimpleFits:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:SimpleFits:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:SimpleFits:DataQstartPoint
	SVAR InvBackgModel = root:Packages:Irena:SimpleFits:InvBackgModel
	NVAR InvBckgMinQ = root:Packages:Irena:SimpleFits:InvBckgMinQ
	NVAR InvBckgMaxQ = root:Packages:Irena:SimpleFits:InvBckgMaxQ

	Wave/Z ModelInt = root:Packages:Irena:SimpleFits:ModelLogLogInt
	Wave/Z ModelQ = root:Packages:Irena:SimpleFits:ModelLogLogQ
	//others can be created via Simple polots as needed... 
	//if(!WaveExists(modelInt)||!WaveExists(ModelQ))
	//	return 0			//cannot do anything, bail out. 
	//endif

	IR1_AppendAnyText("\r Results of "+SimpleModel+" fitting\r",1)	
	IR1_AppendAnyText("Date & time: \t"+Date()+"   "+time(),0)	
	IR1_AppendAnyText("Data from folder: \t"+DataFolderName,0)	
	IR1_AppendAnyText("Intensity: \t"+IntensityWaveName,0)	
	IR1_AppendAnyText("Q: \t"+QWavename,0)	
	IR1_AppendAnyText("Error: \t"+ErrorWaveName,0)	
	IR1_AppendAnyText(" ",0)	
	if(stringmatch(SimpleModel,"Guinier"))
		IR1_AppendAnyText("\tRg                  = "+num2str(Guinier_Rg),0)
		IR1_AppendAnyText("\tI0                  = "+num2str(Guinier_I0),0)
	elseif(stringmatch(SimpleModel,"Guinier Rod"))
		IR1_AppendAnyText("\tRc                  = "+num2str(Guinier_Rg),0)
		IR1_AppendAnyText("\tI0                  = "+num2str(Guinier_I0),0)
	elseif(stringmatch(SimpleModel,"Guinier Sheet"))
		IR1_AppendAnyText("\tThickness           = "+num2str(sqrt(12)*Guinier_Rg),0)
		IR1_AppendAnyText("\tI0                  = "+num2str(Guinier_I0),0)
	elseif(stringmatch(SimpleModel,"Porod"))
		IR1_AppendAnyText("\tPorod Constant [1/cm 1/A^4] = "+num2str(Porod_Constant),0)
		IR1_AppendAnyText("\tSpecific Surface [cm2/cm3] = "+num2str(Porod_SpecificSurface),0)
		IR1_AppendAnyText("\tContrast [10^20 cm^-4] = "+num2str(Porod_Constant),0)
		IR1_AppendAnyText("\tBackground          = "+num2str(DataBackground),0)
	elseif(stringmatch(SimpleModel,"Sphere"))
		IR1_AppendAnyText("\tSphere Radius [A]   = "+num2str(Sphere_Radius),0)
		IR1_AppendAnyText("\tScaling constant    = "+num2str(Sphere_ScalingConstant),0)
		IR1_AppendAnyText("\tBackground = "+num2str(DataBackground),0)
	elseif(stringmatch(SimpleModel,"Spheroid"))
		IR1_AppendAnyText("\tSpheroid Radius [A] = "+num2str(Spheroid_Radius),0)
		IR1_AppendAnyText("\tScaling constant    = "+num2str(Spheroid_ScalingConstant),0)
		IR1_AppendAnyText("\tSpheroid Beta       = "+num2str(Spheroid_Beta),0)
		IR1_AppendAnyText("\tBackground          = "+num2str(DataBackground),0)
	elseif(stringmatch(SimpleModel,"Invariant"))
		IR1_AppendAnyText("\tInvariant [(mol e-^2/cm^3)^3] 	= "+num2str(Invariant),0)
		IR1_AppendAnyText("\tQmax used for calc.				= "+num2str(InvQmaxUsed),0)
		IR1_AppendAnyText("\tBackground Model				= "+InvBackgModel,0)
		IR1_AppendAnyText("\tBckg Q start         					= "+num2str(InvBckgMinQ),0)
		IR1_AppendAnyText("\tBckg Q end          					= "+num2str(InvBckgMaxQ),0)
	elseif(stringmatch(SimpleModel,"Volume Size Distribution"))
		IR1_AppendAnyText("\tRg [A]              =  "+num2str(VOlSD_Rg),0)
		IR1_AppendAnyText("\tVolume fraction     =  "+num2str(VolSD_Volume),0)
		IR1_AppendAnyText("\tMean Diameter [A]   =  "+num2str(VolSD_MeanDiameter),0)
		IR1_AppendAnyText("\tMedian Diameter [A] =  "+num2str(VolSD_MedianDiameter),0)
		IR1_AppendAnyText("\tMode Diameter [A]   =  "+num2str(VOlSD_ModeDiamater),0)
	elseif(stringmatch(SimpleModel,"Number Size Distribution"))
		IR1_AppendAnyText("\tNum Particles/cm3   =  "+num2str(NumSD_NumPartPerCm3),0)
		IR1_AppendAnyText("\tMean Diameter [A]   =  "+num2str(NumSD_MeanDiameter),0)
		IR1_AppendAnyText("\tMedian Diameter [A] =  "+num2str(NumSD_MedianDiameter),0)
		IR1_AppendAnyText("\tMode Diameter [A]   =  "+num2str(NumSD_ModeDiamater),0)
	endif

	IR1_AppendAnyText("Achieved Normalized chi-square = "+num2str(AchievedChiSquare),0)
	IR1_AppendAnyText("Qmin = "+num2str(DataQstart),0)
	IR1_AppendAnyText("Qmax = "+num2str(DataQEnd),0)
	IR1_AppendAnyGraph("IR3J_LogLogDataDisplay")
	DOWIndow IR3J_LinDataDisplay
	if(V_Flag)
		IR1_AppendAnyGraph("IR3J_LinDataDisplay")
	endif
	IR1_AppendAnyText("******************************************\r",0)	
	SetDataFolder OldDf
	SVAR/Z nbl=root:Packages:Irena:ResultsNotebookName	
	DoWindow/F $nbl
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function IR3J_SaveResultsToFolder()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()	
	SetDataFolder root:Packages:Irena:SimpleFits								//go into the folder
	NVAR SaveToFolder=root:Packages:Irena:SimpleFits:SaveToFolder
	if(!SaveToFolder)
		return 0
	endif	
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
	NVAR Porod_SpecificSurface			=root:Packages:Irena:SimpleFits:Porod_SpecificSurface
	NVAR ScatteringContrast			=root:Packages:Irena:SimpleFits:ScatteringContrast
	NVAR Sphere_Radius				=root:Packages:Irena:SimpleFits:Sphere_Radius
	NVAR Sphere_ScalingConstant	=root:Packages:Irena:SimpleFits:Sphere_ScalingConstant
	NVAR Spheroid_Radius			=root:Packages:Irena:SimpleFits:Spheroid_Radius
	NVAR Spheroid_ScalingConstant=root:Packages:Irena:SimpleFits:Spheroid_ScalingConstant
	NVAR Spheroid_Beta				=root:Packages:Irena:SimpleFits:Spheroid_Beta
	NVAR DataBackground			=root:Packages:Irena:SimpleFits:DataBackground
	SVAR SimpleModel 				= root:Packages:Irena:SimpleFits:SimpleModel
	NVAR SaveToNotebook=root:Packages:Irena:SimpleFits:SaveToNotebook
	NVAR SaveToWaves=root:Packages:Irena:SimpleFits:SaveToWaves
	//create new results names...
	//AllCurrentlyAllowedTypes+="SimFitGuinierY;SimFitGuinierRY;SimFitGuinierSY;SimFitSphereY;SimFitSpheroidY;"
	//save these waves here:
	Wave/Z ModelInt = root:Packages:Irena:SimpleFits:ModelLogLogInt
	Wave/Z ModelQ = root:Packages:Irena:SimpleFits:ModelLogLogQ
	//others can be created via Simple polots as needed... 
	if(!WaveExists(modelInt)||!WaveExists(ModelQ)&&!StringMatch(SimpleModel, "Invariant" ))
		return 0			//cannot do anything, bail out. 
	endif
	//note, there is nothing to do here for : 
	// Volume Size Distribution and Number Size Distribution
	//get old note here... 
	Wave/Z SourceIntWv=$(DataFolderName+IntensityWaveName)
	string OldNote=note(SourceIntWv)
	string NoteWithResults=""
	variable generation=0
	NoteWithResults="Results of "+SimpleModel+" fitting;"+date()+";"+time()+";DataFolder="+DataFolderName+";Intensity="+IntensityWaveName+";"
	NoteWithResults+="Q="+QWavename+";"+"Error="+ErrorWaveName+";"+"ChiSquared="+num2str(AchievedChiSquare)+";"
	strswitch(SimpleModel)	
		case "Guinier":	
			NoteWithResults+="Rg="+num2str(Guinier_Rg)+";"+"I0="+num2str(Guinier_I0)+";"
			NoteWithResults+=OldNote
			generation=IN2G_FindAVailableResultsGen("SimFitGuinierI", DataFolderName)
			Duplicate/O ModelInt, $(DataFolderName+"SimFitGuinierI_"+num2str(generation))
			Duplicate/O ModelQ, $(DataFolderName+"SimFitGuinierQ_"+num2str(generation))
			Wave ResultInt=$(DataFolderName+"SimFitGuinierI_"+num2str(generation))
			Wave ResuldQ = $(DataFolderName+"SimFitGuinierQ_"+num2str(generation))
			Note /K/NOCR ResultInt, NoteWithResults
			Note /K/NOCR ResuldQ, NoteWithResults
			break	
		case "Guinier Rod":	// execute if case matches expression
			NoteWithResults+="Rc="+num2str(Guinier_Rg)+";"+"I0="+num2str(Guinier_I0)+";"
			NoteWithResults+=OldNote
			generation=IN2G_FindAVailableResultsGen("SimFitGuinierRI", DataFolderName)
			Duplicate/O ModelInt, $(DataFolderName+"SimFitGuinierRI_"+num2str(generation))
			Duplicate/O ModelQ, $(DataFolderName+"SimFitGuinierRQ_"+num2str(generation))
			Wave ResultInt=$(DataFolderName+"SimFitGuinierRI_"+num2str(generation))
			Wave ResuldQ = $(DataFolderName+"SimFitGuinierRQ_"+num2str(generation))
			Note /K/NOCR ResultInt, NoteWithResults
			Note /K/NOCR ResuldQ, NoteWithResults
			break	
		case "Guinier Sheet":	// execute if case matches expression
			NoteWithResults+="Thickness="+num2str(sqrt(12)*Guinier_Rg)+";"+"I0="+num2str(Guinier_I0)+";"
			NoteWithResults+=OldNote
			generation=IN2G_FindAVailableResultsGen("SimFitGuinierSI", DataFolderName)
			Duplicate/O ModelInt, $(DataFolderName+"SimFitGuinierSI_"+num2str(generation))
			Duplicate/O ModelQ, $(DataFolderName+"SimFitGuinierSQ_"+num2str(generation))
			Wave ResultInt=$(DataFolderName+"SimFitGuinierSI_"+num2str(generation))
			Wave ResuldQ = $(DataFolderName+"SimFitGuinierSQ_"+num2str(generation))
			Note /K/NOCR ResultInt, NoteWithResults
			Note /K/NOCR ResuldQ, NoteWithResults
			break	
		case "Porod":	// execute if case matches expression
			NoteWithResults+="PorodConstant="+num2str(Porod_Constant)+";"+"DataBackground="+num2str(DataBackground)+";"
			NoteWithResults+="ScatteringContrast="+num2str(ScatteringContrast)+";"+"Porod_SpecificSurface="+num2str(Porod_SpecificSurface)+";"
			NoteWithResults+=OldNote
			generation=IN2G_FindAVailableResultsGen("SimFitPorodI_", DataFolderName)
			Duplicate/O ModelInt, $(DataFolderName+"SimFitPorodI_"+num2str(generation))
			Duplicate/O ModelQ, $(DataFolderName+"SimFitPorodQ_"+num2str(generation))
			Wave ResultInt=$(DataFolderName+"SimFitPorodI_"+num2str(generation))
			Wave ResuldQ = $(DataFolderName+"SimFitPorodQ_"+num2str(generation))
			Note /K/NOCR ResultInt, NoteWithResults
			Note /K/NOCR ResuldQ, NoteWithResults
			break	
		case "Sphere":	// execute if case matches expression
			NoteWithResults+="SphereRadius="+num2str(Sphere_Radius)+";"+"SphereScalingFactor="+num2str(Sphere_ScalingConstant)+";"+"SphereBackground="+num2str(DataBackground)+";"
			NoteWithResults+=OldNote
			generation=IN2G_FindAVailableResultsGen("SimFitSphereI_", DataFolderName)
			Duplicate/O ModelInt, $(DataFolderName+"SimFitSphereI_"+num2str(generation))
			Duplicate/O ModelQ, $(DataFolderName+"SimFitSphereQ_"+num2str(generation))
			Wave ResultInt=$(DataFolderName+"SimFitSphereI_"+num2str(generation))
			Wave ResuldQ = $(DataFolderName+"SimFitSphereQ_"+num2str(generation))
			Note /K/NOCR ResultInt, NoteWithResults
			Note /K/NOCR ResuldQ, NoteWithResults
			break	
		case "Spheroid":	// execute if case matches expression
			NoteWithResults+="SpheroidRadius="+num2str(Spheroid_Radius)+";"+"SpheroidAspectRatio="+num2str(Spheroid_Beta)+";"
			NoteWithResults+="SpheroidScalingFactor="+num2str(Spheroid_ScalingConstant)+";"+"SpheroidBackground="+num2str(DataBackground)+";"
			NoteWithResults+=OldNote
			generation=IN2G_FindAVailableResultsGen("SimFitSpheroidI_", DataFolderName)
			Duplicate/O ModelInt, $(DataFolderName+"SimFitSpheroidI_"+num2str(generation))
			Duplicate/O ModelQ, $(DataFolderName+"SimFitSpheroidQ_"+num2str(generation))
			Wave ResultInt=$(DataFolderName+"SimFitSpheroidI_"+num2str(generation))
			Wave ResuldQ = $(DataFolderName+"SimFitSpheroidQ_"+num2str(generation))
			Note /K/NOCR ResultInt, NoteWithResults
			Note /K/NOCR ResuldQ, NoteWithResults
			break
		case "Invariant":	// nothing to do here...
			variable/g  $(DataFolderName+"Invariant")
			NVAR InvariantResult = $(DataFolderName+"Invariant")
			NVAR Invariant =	root:Packages:Irena:SimpleFits:invariant
			InvariantResult = Invariant
			break
		case "Volume Size Distribution":	// nothing to do here...
			break
		case "Number Size Distribution":	// nothing to do here...
			break
		default:			// optional default expression executed
			Abort "Unknown data type, cannot save the data"
	endswitch	
end
//*****************************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function IR3J_SaveResultsToWaves()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()	
	NVAR SaveToNotebook=root:Packages:Irena:SimpleFits:SaveToNotebook
	NVAR SaveToWaves=root:Packages:Irena:SimpleFits:SaveToWaves
	NVAR SaveToFolder=root:Packages:Irena:SimpleFits:SaveToFolder
	if(!SaveToWaves)
		return 0
	endif
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
	NVAR Porod_SpecificSurface			=root:Packages:Irena:SimpleFits:Porod_SpecificSurface
	NVAR ScatteringContrast			=root:Packages:Irena:SimpleFits:ScatteringContrast
	NVAR Sphere_Radius				=root:Packages:Irena:SimpleFits:Sphere_Radius
	NVAR Sphere_ScalingConstant	=root:Packages:Irena:SimpleFits:Sphere_ScalingConstant
	NVAR Spheroid_Radius			=root:Packages:Irena:SimpleFits:Spheroid_Radius
	NVAR Spheroid_ScalingConstant=root:Packages:Irena:SimpleFits:Spheroid_ScalingConstant
	NVAR Spheroid_Beta				=root:Packages:Irena:SimpleFits:Spheroid_Beta
	NVAR DataBackground			=root:Packages:Irena:SimpleFits:DataBackground

	SVAR SimpleModel 				= root:Packages:Irena:SimpleFits:SimpleModel

	NVAR InvQmaxUsed =	root:Packages:Irena:SimpleFits:InvQmaxUsed
	NVAR Invariant =	root:Packages:Irena:SimpleFits:invariant
	NVAR DataQEnd = 	root:Packages:Irena:SimpleFits:DataQEnd
	NVAR DataQstart = 	root:Packages:Irena:SimpleFits:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:SimpleFits:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:SimpleFits:DataQstartPoint
	SVAR InvBackgModel = root:Packages:Irena:SimpleFits:InvBackgModel
	NVAR InvBckgMinQ = root:Packages:Irena:SimpleFits:InvBckgMinQ
	NVAR InvBckgMaxQ = root:Packages:Irena:SimpleFits:InvBckgMaxQ


	NVAR VOlSD_Rg					=root:Packages:Irena:SimpleFits:VOlSD_Rg
	NVAR VolSD_Volume				=root:Packages:Irena:SimpleFits:VolSD_Volume
	NVAR VolSD_MeanDiameter		=root:Packages:Irena:SimpleFits:VolSD_MeanDiameter
	NVAR VolSD_MedianDiameter	=root:Packages:Irena:SimpleFits:VolSD_MedianDiameter
	NVAR VOlSD_ModeDiamater		=root:Packages:Irena:SimpleFits:VOlSD_ModeDiamater
	NVAR NumSD_NumPartPerCm3		=root:Packages:Irena:SimpleFits:NumSD_NumPartPerCm3
	NVAR NumSD_MeanDiameter		=root:Packages:Irena:SimpleFits:NumSD_MeanDiameter
	NVAR NumSD_MedianDiameter	=root:Packages:Irena:SimpleFits:NumSD_MedianDiameter
	NVAR NumSD_ModeDiamater		=root:Packages:Irena:SimpleFits:NumSD_ModeDiamater
	Wave/Z ModelInt = root:Packages:Irena:SimpleFits:ModelLogLogInt
	Wave/Z ModelQ = root:Packages:Irena:SimpleFits:ModelLogLogQ
	//others can be created via Simple polots as needed... 
	//if(!WaveExists(modelInt)||!WaveExists(ModelQ))		//Volume Size Distribution;Number Size Distribution do not have output waqves... 
	//	return 0			//cannot do anything, bail out. 
	//endif

	variable curlength
	if(stringmatch(SimpleModel,"Guinier"))
		//tabulate data for Guinier
		NewDATAFolder/O/S root:GuinierFitResults
		Wave/Z GuinierRg
		if(!WaveExists(GuinierRg))
			make/O/N=0 GuinierRg, GuinierI0, GuinierQmin, GuinierQmax, GuinierChiSquare, TimeWave, TemperatureWave, PercentWave, OrderWave
			make/O/N=0/T SampleName
			SetScale/P x 0,1,"A", GuinierRg
			SetScale/P x 0,1,"1/A", GuinierQmin, GuinierQmax
		endif
		curlength = numpnts(GuinierRg)
		redimension/N=(curlength+1) SampleName,GuinierRg, GuinierI0, GuinierQmin, GuinierQmax, GuinierChiSquare, TimeWave, TemperatureWave, PercentWave, OrderWave 
		SampleName[curlength] = DataFolderName
		TimeWave[curlength]				=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzmin")
		TemperatureWave[curlength]  	=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzC")
		PercentWave[curlength] 			=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzpct")
		OrderWave[curlength]				= 	IN2G_IdentifyNameComponent(DataFolderName, "_xyz")
		GuinierRg[curlength] 				= Guinier_Rg
		GuinierI0[curlength] 				= Guinier_I0
		GuinierQmin[curlength] 			= DataQstart
		GuinierQmax[curlength] 			= DataQEnd
		GuinierChiSquare[curlength] 	= AchievedChiSquare
		IR3J_GetTableWithresults()
	elseif(stringmatch(SimpleModel,"Invariant"))
		//tabulate data for Invariant
		NewDATAFolder/O/S root:InvariantFitResults
		Wave/Z InvariantWV
		if(!WaveExists(InvariantWV))
			make/O/N=0 InvariantWV, InvariantQmax, TimeWave, TemperatureWave, PercentWave, OrderWave
			make/O/N=0/T SampleName
			SetScale/P x 0,1,"(mol e-^2/cm^3)^3", InvariantWV
			SetScale/P x 0,1,"1/A", InvariantQmax
		endif
		curlength = numpnts(InvariantWV)
		redimension/N=(curlength+1) SampleName, InvariantWV, InvariantQmax, TimeWave, TemperatureWave, PercentWave, OrderWave 
		SampleName[curlength] = DataFolderName
		TimeWave[curlength]				=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzmin")
		TemperatureWave[curlength]  	=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzC")
		PercentWave[curlength] 			=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzpct")
		OrderWave[curlength]				= 	IN2G_IdentifyNameComponent(DataFolderName, "_xyz")
		InvariantWV[curlength] = Invariant
		InvariantQmax[curlength] = InvQmaxUsed
		IR3J_GetTableWithresults()
	elseif(stringmatch(SimpleModel,"Guinier Rod"))
		//tabulate data for Guinier
		NewDATAFolder/O/S root:GuinierRodFitResults
		Wave/Z GuinierRc
		if(!WaveExists(GuinierRc))
			make/O/N=0 GuinierRc, GuinierI0, GuinierQmin, GuinierQmax, GuinierChiSquare, TimeWave, TemperatureWave, PercentWave, OrderWave
			make/O/N=0/T SampleName
			SetScale/P x 0,1,"A", GuinierRc
			SetScale/P x 0,1,"1/A", GuinierQmin, GuinierQmax
		endif
		curlength = numpnts(GuinierRc)
		redimension/N=(curlength+1) SampleName,GuinierRc, GuinierI0, GuinierQmin, GuinierQmax, GuinierChiSquare, TimeWave, TemperatureWave, PercentWave, OrderWave 
		SampleName[curlength] = DataFolderName
		TimeWave[curlength]				=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzmin")
		TemperatureWave[curlength]  	=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzC")
		PercentWave[curlength] 			=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzpct")
		OrderWave[curlength]				= 	IN2G_IdentifyNameComponent(DataFolderName, "_xyz")
		GuinierRc[curlength] = Guinier_Rg
		GuinierI0[curlength] = Guinier_I0
		GuinierQmin[curlength] = DataQstart
		GuinierQmax[curlength] = DataQEnd
		GuinierChiSquare[curlength] = AchievedChiSquare
		IR3J_GetTableWithresults()
	elseif(stringmatch(SimpleModel,"Guinier Sheet"))
		//tabulate data for Guinier
		NewDATAFolder/O/S root:GuinierSheetFitResults
		Wave/Z GuinierTh
		if(!WaveExists(GuinierTh))
			make/O/N=0 GuinierTh, GuinierI0, GuinierQmin, GuinierQmax, GuinierChiSquare, TimeWave, TemperatureWave, PercentWave, OrderWave
			make/O/N=0/T SampleName
			SetScale/P x 0,1,"A", GuinierTh
			SetScale/P x 0,1,"1/A", GuinierQmin, GuinierQmax
		endif
		curlength = numpnts(GuinierTh)
		redimension/N=(curlength+1) SampleName,GuinierTh, GuinierI0, GuinierQmin, GuinierQmax, GuinierChiSquare, TimeWave, TemperatureWave, PercentWave, OrderWave 
		SampleName[curlength] = DataFolderName
		TimeWave[curlength]				=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzmin")
		TemperatureWave[curlength]  	=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzC")
		PercentWave[curlength] 			=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzpct")
		OrderWave[curlength]				= 	IN2G_IdentifyNameComponent(DataFolderName, "_xyz")
		GuinierTh[curlength] = sqrt(12)*Guinier_Rg
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
			make/O/N=0 PorodConstant, PorodBackground, PorodQmin, PorodQmax, PorodChiSquare, TimeWave, TemperatureWave, PercentWave, OrderWave, ScatteringContrastWave, PorodSpecificSurfaceWave 
			make/O/N=0/T SampleName
			SetScale/P x 0,1,"1/cm 1/A^4", PorodConstant			//Unified fit GUI source
			SetScale/P x 0,1,"1/A", PorodQmin, PorodQmax
		endif
		curlength = numpnts(PorodConstant)
		redimension/N=(curlength+1) SampleName, PorodConstant, PorodBackground, PorodQmin, PorodQmax, PorodChiSquare, TimeWave, TemperatureWave, PercentWave, OrderWave, ScatteringContrastWave, PorodSpecificSurfaceWave 
		SampleName[curlength] = DataFolderName
		TimeWave[curlength]				=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzmin")
		TemperatureWave[curlength]  	=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzC")
		PercentWave[curlength] 			=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzpct")
		OrderWave[curlength]				= 	IN2G_IdentifyNameComponent(DataFolderName, "_xyz")
		PorodConstant[curlength] = Porod_Constant
		PorodBackground[curlength]=DataBackground
		PorodQmin[curlength] = DataQstart
		PorodQmax[curlength] = DataQEnd
		PorodChiSquare[curlength] = AchievedChiSquare
		ScatteringContrastWave[curlength] = ScatteringContrast
		PorodSpecificSurfaceWave[curlength] = Porod_SpecificSurface
		IR3J_GetTableWithresults()
	elseif(stringmatch(SimpleModel,"Sphere"))
		//tabulate data for Porod
		NewDATAFolder/O/S root:SphereFitResults
		Wave/Z SphereRadius
		if(!WaveExists(SphereRadius))
			make/O/N=0 SphereRadius, SphereScalingFactor, SphereBackground, SphereQmin, SphereQmax, SphereChiSquare, TimeWave, TemperatureWave, PercentWave, OrderWave
			make/O/N=0/T SampleName
			SetScale/P x 0,1,"A", SphereRadius
			SetScale/P x 0,1,"1/A", SphereQmin, SphereQmax
		endif
		curlength = numpnts(SphereRadius)
		redimension/N=(curlength+1) SampleName,SphereRadius, SphereScalingFactor, SphereBackground, SphereQmin, SphereQmax, SphereChiSquare, TimeWave, TemperatureWave, PercentWave, OrderWave 
		SampleName[curlength] = DataFolderName
		TimeWave[curlength]				=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzmin")
		TemperatureWave[curlength]  	=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzC")
		PercentWave[curlength] 			=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzpct")
		OrderWave[curlength]				= 	IN2G_IdentifyNameComponent(DataFolderName, "_xyz")
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
			make/O/N=0 SpheroidRadius, SpheroidScalingFactor, SpheroidAspectRatio, SpheroidBackground, SpheroidQmin, SpheroidQmax, SpheroidChiSquare, TimeWave, TemperatureWave, PercentWave, OrderWave
			make/O/N=0/T SampleName
			SetScale/P x 0,1,"A", SpheroidRadius
			SetScale/P x 0,1,"1/A", SpheroidQmin, SpheroidQmax
		endif
		curlength = numpnts(SpheroidRadius)
		redimension/N=(curlength+1) SampleName,SpheroidRadius, SpheroidScalingFactor, SpheroidAspectRatio, SpheroidBackground, SpheroidQmin, SpheroidQmax, SpheroidChiSquare, TimeWave, TemperatureWave, PercentWave, OrderWave 
		SampleName[curlength] 			= DataFolderName
		TimeWave[curlength]				=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzmin")
		TemperatureWave[curlength]  	=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzC")
		PercentWave[curlength] 			=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzpct")
		OrderWave[curlength]				= 	IN2G_IdentifyNameComponent(DataFolderName, "_xyz")
		SpheroidRadius[curlength] 			= Spheroid_Radius
		SpheroidScalingFactor[curlength] = Spheroid_ScalingConstant
		SpheroidAspectRatio[curlength] 	= Spheroid_Beta
		SpheroidBackground[curlength]	= DataBackground
		SpheroidQmin[curlength]			= DataQstart
		SpheroidQmax[curlength] 			= DataQEnd
		SpheroidChiSquare[curlength] 	= AchievedChiSquare
		IR3J_GetTableWithresults()
	elseif(stringmatch(SimpleModel,"Volume Size Distribution"))
		//tabulate data for Porod
		NewDATAFolder/O/S root:VolSizeDistResults
		Wave/Z Rg
		if(!WaveExists(Rg))
			make/O/N=0 Rg, VolumeFraction, MeanDiaVolDist, ModeDiaVolDist, MeadianDiaVolDist, TimeWave, TemperatureWave, PercentWave, OrderWave
			make/O/N=0/T SampleName
			SetScale/P x 0,1,"A", Rg, MeanDiaVolDist, ModeDiaVolDist, MeadianDiaVolDist
			SetScale/P x 0,1,"Fraction", VolumeFraction		
		endif
		curlength = numpnts(Rg)
		redimension/N=(curlength+1) SampleName,Rg, VolumeFraction, MeanDiaVolDist, ModeDiaVolDist, MeadianDiaVolDist, TimeWave, TemperatureWave, PercentWave, OrderWave 
		SampleName[curlength] 			= DataFolderName
		TimeWave[curlength]				=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzmin")
		TemperatureWave[curlength]  	=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzC")
		PercentWave[curlength] 			=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzpct")
		OrderWave[curlength]				= 	IN2G_IdentifyNameComponent(DataFolderName, "_xyz")
		Rg[curlength] 						= VOlSD_Rg
		VolumeFraction[curlength]		= VolSD_Volume
		MeanDiaVolDist[curlength] 		= VolSD_MeanDiameter
		ModeDiaVolDist[curlength]		= VOlSD_ModeDiamater
		MeadianDiaVolDist[curlength]	= VolSD_MedianDiameter

		//IR3J_GetTableWithresults()
	elseif(stringmatch(SimpleModel,"Number Size Distribution"))
		//tabulate data for Porod
		NewDATAFolder/O/S root:NumbSizeDistResults
		Wave/Z NumPartsPercm3
		if(!WaveExists(NumPartsPercm3))	
			make/O/N=0 NumPartsPercm3, MeanDiaNumDist, ModeDiaNumDist, MeadianDiaNumDist, TimeWave, TemperatureWave, PercentWave, OrderWave
			make/O/N=0/T SampleName
			SetScale/P x 0,1,"A", MeanDiaNumDist, ModeDiaNumDist, MeadianDiaNumDist
			SetScale/P x 0,1,"1/cm3", NumPartsPercm3		
		endif
		curlength = numpnts(NumPartsPercm3)
		redimension/N=(curlength+1) SampleName, NumPartsPercm3, MeanDiaNumDist, ModeDiaNumDist, MeadianDiaNumDist, TimeWave, TemperatureWave, PercentWave, OrderWave 
		SampleName[curlength] 			= DataFolderName
		TimeWave[curlength]				=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzmin")
		TemperatureWave[curlength]  	=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzC")
		PercentWave[curlength] 			=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzpct")
		OrderWave[curlength]				= 	IN2G_IdentifyNameComponent(DataFolderName, "_xyz")
		NumPartsPercm3[curlength] 		= NumSD_NumPartPerCm3
		MeanDiaNumDist[curlength] 		= NumSD_MeanDiameter
		ModeDiaNumDist[curlength]		= NumSD_ModeDiamater
		MeadianDiaNumDist[curlength]	= NumSD_MedianDiameter

		//IR3J_GetTableWithresults()
	endif
	
end
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR3J_GetTableWithResults()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
		case "Guinier Rod":	// execute if case matches expression
			DoWindow IR3J_GuinierRodFitResultsTable
			if(V_Flag)
				DoWIndow/F IR3J_GuinierRodFitResultsTable
			else
				IR3J_GuinRodFitResTblFnct()
			endif		
			break		// exit from switch
		case "Guinier Sheet":	// execute if case matches expression
			DoWindow IR3J_GuinierSheetFitResTable
			if(V_Flag)
				DoWIndow/F IR3J_GuinierSheetFitResTable
			else
				IR3J_GuinSheetFitResTblFnct()
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
				IR3J_SphFFFitResTblFnct() 
			endif 
			break
		case "Spheroid":	// execute if case matches expression
			DoWindow IR3J_SpheroidFFFitResultsTable
			if(V_Flag)
				DoWindow/F IR3J_SpheroidFFFitResultsTable
			else
				IR3J_SpheroidFFFitResTblFnct() 
			endif 
			break
		case "Invariant":	// execute if case matches expression
			DoWindow IR3J_InvResultsTable
			if(V_Flag)
				DoWindow/F IR3J_InvResultsTable
			else
				IR3J_InvResultsTableFnct() 
			endif 
			break
		case "Volume Size Distribution":	// execute if case matches expression
			DoWindow IR3J_VolSDResultsTable
			if(V_Flag)
				DoWindow/F IR3J_VolSDResultsTable
			else
				IR3J_VolumeSDResTblFnct() 
			endif 
			break
		case "Number Size Distribution":	// execute if case matches expression
			DoWindow IR3J_NumberSDResultsTable
			if(V_Flag)
				DoWindow/F IR3J_NumberSDResultsTable
			else
				IR3J_NumberSDResTblFnct() 
			endif 
			break

		default:			// optional default expression executed

	endswitch

end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3J_DeleteExistingModelResults()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR SimpleModel 	= root:Packages:Irena:SimpleFits:SimpleModel
	DoAlert /T="This is delete resutls warning" 1, "This will delete all existing results for model : "+SimpleModel+". Do you WANT to continue?"
	if(V_Flag==1)
		strswitch(SimpleModel)	// string switch
			case "Guinier":	// execute if case matches expression
				DoWindow/K/Z IR3J_GuinierFitResultsTable
				if(DataFolderExists("root:GuinierFitResults"))
					KillDataFolder/Z root:GuinierFitResults:
					if(V_Flag!=0)
						DoAlert/T="Could not delete data folder" 0, "Guinier results folder root:GuinierFitResults could not be deleted. It is likely used in some graph or table. Close graphs/tables and try again."
					endif
				endif
				break		// exit from switch
			case "Guinier Rod":	// execute if case matches expression
				DoWindow/K/Z IR3J_GuinierRodFitResultsTable
				if(DataFolderExists("root:GuinierRodFitResults"))
					KillDataFolder/Z root:GuinierRodFitResults:
					if(V_Flag!=0)
						DoAlert/T="Could not delete data folder" 0, "Guinier results folder root:GuinierRodFitResults could not be deleted. It is likely used in some graph or table. Close graphs/tables and try again."
					endif
				endif
				break		// exit from switch
			case "Guinier Sheet":	// execute if case matches expression
				DoWindow/K/Z IR3J_GuinierSheetFitResTable
				if(DataFolderExists("root:GuinierSheetFitResults"))
					KillDataFolder/Z root:GuinierSheetFitResults:
					if(V_Flag!=0)
						DoAlert/T="Could not delete data folder" 0, "Guinier results folder root:GuinierSheetFitResults could not be deleted. It is likely used in some graph or table. Close graphs/tables and try again."
					endif
				endif
				break		// exit from switch
			case "Porod":	// execute if case matches expression
				DoWindow/K/Z  IR3J_PorodFitResultsTable
				if(DataFolderExists("root:PorodFitResults"))
					KillDataFolder/Z root:PorodFitResults:
					if(V_Flag!=0)
						DoAlert/T="Could not delete data folder" 0, "Porod results folder root:PorodFitResults could not be deleted. It is likely used in some graph or table. Close graphs/tables and try again."
					endif
				endif
				break
			case "Sphere":	// execute if case matches expression
				DoWindow/K/Z  IR3J_SphereFFFitResultsTable
				if(DataFolderExists("root:SphereFitResults"))
					KillDataFolder/Z root:SphereFitResults:
					if(V_Flag!=0)
						DoAlert/T="Could not delete data folder" 0, "Sphere FF results folder root:SphereFitResults could not be deleted. It is likely used in some graph or table. Close graphs/tables and try again."
					endif
				endif
				break
			case "Spheroid":	// execute if case matches expression
				DoWindow/K/Z IR3J_SpheroidFFFitResultsTable
				if(DataFolderExists("root:SpheroidFitResults"))
					KillDataFolder/Z root:SpheroidFitResults:
					if(V_Flag!=0)
						DoAlert/T="Could not delete data folder" 0, "Spheroid FF results folder root:SpheroidFitResults could not be deleted. It is likely used in some graph or table. Close graphs/tables and try again."
					endif
				endif
				break
			case "Invariant":	// execute if case matches expression
				DoWindow/K/Z IR3J_InvResultsTable
				if(DataFolderExists("root:InvariantFitResults:"))
					KillDataFolder/Z root:InvariantFitResults:
					if(V_Flag!=0)
						DoAlert/T="Could not delete data folder" 0, "Invariant results folder root:InvariantFitResults could not be deleted. It is likely used in some graph or table. Close graphs/tables and try again."
					endif
				endif
				break
			case "Volume Size Distribution":	// execute if case matches expression
				DoWindow/K/Z IR3J_VolSDResultsTable
				if(DataFolderExists("root:VolSizeDistResults"))
					KillDataFolder/Z root:VolSizeDistResults:
					if(V_Flag!=0)
						DoAlert/T="Could not delete data folder" 0, "Volume Size distribution analysis results folder root:VolSizeDistResults could not be deleted. It is likely used in some graph or table. Close graphs/tables and try again."
					endif
				endif
				break
			case "Number Size Distribution":	// execute if case matches expression
				DoWindow/K/Z IR3J_NumberSDResultsTable
				if(DataFolderExists("root:NumbSizeDistResults"))
					KillDataFolder/Z root:NumbSizeDistResults:
					if(V_Flag!=0)
						DoAlert/T="Could not delete data folder" 0, "Number Size distribution analysis results folder root:NumbSizeDistResults could not be deleted. It is likely used in some graph or table. Close graphs/tables and try again."
					endif
				endif
				break
			default:			// optional default expression executed
		endswitch
	endif
end


//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IR3J_GuinierFitResultsTableFnct() : Table
	PauseUpdate    		// building window...
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
static Function IR3J_GuinRodFitResTblFnct() : Table
	PauseUpdate    		// building window...
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()	
	if(!DataFolderExists("root:GuinierRodFitResults:"))
		Abort "No Guinier Rod Fit data exist."
	endif
	SetDataFolder root:GuinierRodFitResults:
	Wave/T SampleName
	Wave GuinierRc,GuinierI0,GuinierChiSquare,GuinierQmax,GuinierQmin
	Edit/K=1/W=(860,772,1831,1334)/N=IR3J_GuinierRodFitResultsTable SampleName,GuinierRc,GuinierI0,GuinierChiSquare,GuinierQmax as "Guinier Rod fitting results Table"
	AppendToTable GuinierQmin
	ModifyTable format(Point)=1,width(SampleName)=304,title(SampleName)="Sample Folder"
	ModifyTable alignment(GuinierRc)=1,sigDigits(GuinierRc)=4,title(GuinierRc)="Rc [A]"
	ModifyTable alignment(GuinierI0)=1,sigDigits(GuinierI0)=4,width(GuinierI0)=100,title(GuinierI0)="Guinier I0"
	ModifyTable alignment(GuinierChiSquare)=1,sigDigits(GuinierChiSquare)=4,width(GuinierChiSquare)=104
	ModifyTable title(GuinierChiSquare)="Chi^2",alignment(GuinierQmax)=1,sigDigits(GuinierQmax)=4
	ModifyTable width(GuinierQmax)=92,title(GuinierQmax)="Qmax [1/A]",alignment(GuinierQmin)=1
	ModifyTable sigDigits(GuinierQmin)=4,width(GuinierQmin)=110,title(GuinierQmin)="Qmin [1/A]"
	SetDataFolder oldDf
EndMacro
//*****************************************************************************************************************
static Function IR3J_GuinSheetFitResTblFnct() : Table
	PauseUpdate    		// building window...
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()	
	if(!DataFolderExists("root:GuinierSheetFitResults:"))
		Abort "No Guinier Sheet Fit data exist."
	endif
	SetDataFolder root:GuinierSheetFitResults:
	Wave/T SampleName
	Wave GuinierTh,GuinierI0,GuinierChiSquare,GuinierQmax,GuinierQmin
	Edit/K=1/W=(860,772,1831,1334)/N=IR3J_GuinierSheetFitResTable SampleName,GuinierTh,GuinierI0,GuinierChiSquare,GuinierQmax as "Guinier Sheet fitting results Table"
	AppendToTable GuinierQmin
	ModifyTable format(Point)=1,width(SampleName)=304,title(SampleName)="Sample Folder"
	ModifyTable alignment(GuinierTh)=1,sigDigits(GuinierTh)=4,title(GuinierTh)="Tc [A]"
	ModifyTable alignment(GuinierI0)=1,sigDigits(GuinierI0)=4,width(GuinierI0)=100,title(GuinierI0)="Guinier I0"
	ModifyTable alignment(GuinierChiSquare)=1,sigDigits(GuinierChiSquare)=4,width(GuinierChiSquare)=104
	ModifyTable title(GuinierChiSquare)="Chi^2",alignment(GuinierQmax)=1,sigDigits(GuinierQmax)=4
	ModifyTable width(GuinierQmax)=92,title(GuinierQmax)="Qmax [1/A]",alignment(GuinierQmin)=1
	ModifyTable sigDigits(GuinierQmin)=4,width(GuinierQmin)=110,title(GuinierQmin)="Qmin [1/A]"
	SetDataFolder oldDf
EndMacro

//*****************************************************************************************************************
Function IR3J_PorodFitResultsTableFnct() : Table
	PauseUpdate    		// building window...
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String fldrSav0= GetDataFolder(1)
	if(!DataFolderExists("root:PorodFitResults:"))
		Abort "No Porod Fit data exist."
	endif
	SetDataFolder root:PorodFitResults:
	Wave/T SampleName
	Wave PorodConstant,PorodBackground,PorodChiSquare, PorodQmax,PorodQmin, ScatteringContrastWave, PorodSpecificSurfaceWave
	Edit/K=1/W=(576,346,1528,878)/N=IR3J_PorodFitResultsTable SampleName,PorodConstant,PorodSpecificSurfaceWave, PorodBackground,PorodChiSquare as "Porod fitting results Table"
	AppendToTable PorodQmax,PorodQmin, ScatteringContrastWave
	ModifyTable format(Point)=1,width(SampleName)=314,title(SampleName)="Sample Folder"
	ModifyTable alignment(PorodConstant)=1,sigDigits(PorodConstant)=4,width(PorodConstant)=122
	ModifyTable title(PorodConstant)="Porod Constant",alignment(PorodBackground)=1,sigDigits(PorodBackground)=4
	ModifyTable width(PorodBackground)=110,title(PorodBackground)="Background",alignment(PorodChiSquare)=1
	ModifyTable sigDigits(PorodChiSquare)=4,width(PorodChiSquare)=106,title(PorodChiSquare)="Chi^2"
	ModifyTable alignment(PorodQmax)=1,sigDigits(PorodQmax)=4,title(PorodQmax)="Qmax [1/A]"
	ModifyTable alignment(PorodQmin)=1,sigDigits(PorodQmin)=4,width(PorodQmin)=94,title(PorodQmin)="Qmin [1/A]"
	ModifyTable alignment(PorodSpecificSurfaceWave)=1,sigDigits(PorodSpecificSurfaceWave)=7,width(PorodSpecificSurfaceWave)=94,title(PorodQmin)="Spec Surface [cm2/cm3]"
	ModifyTable alignment(ScatteringContrastWave)=1,sigDigits(ScatteringContrastWave)=4,width(ScatteringContrastWave)=94,title(ScatteringContrastWave)="Contrast [10^20 cm^-4]"
	SetDataFolder fldrSav0
EndMacro
//*****************************************************************************************************************
Function IR3J_SphFFFitResTblFnct() : Table
	PauseUpdate    		// building window...
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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

Function IR3J_SpheroidFFFitResTblFnct() : Table
	PauseUpdate    		// building window...
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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

Function IR3J_VolumeSDResTblFnct() : Table
	PauseUpdate    		// building window...
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String fldrSav0= GetDataFolder(1)
	if(!DataFolderExists("root:VolSizeDistResults:"))
		Abort "No Volume Size Distribution analysis data exist."
	endif
	SetDataFolder root:VolSizeDistResults:
	Wave/T SampleName
	Wave Rg,VolumeFraction,MeanDiaVolDist,ModeDiaVolDist,MeadianDiaVolDist  
	Edit/K=1/W=(238,397,1078,679)/N=IR3J_VolSDResultsTable SampleName,Rg,VolumeFraction,MeanDiaVolDist,ModeDiaVolDist as "Volume Size Distribution Analysis"
	AppendToTable MeadianDiaVolDist
	ModifyTable format(Point)=1,width(SampleName)=264,title(SampleName)="Sample name"
	ModifyTable alignment(Rg)=1,sigDigits(Rg)=4,title(Rg)="Rg [A]",alignment(VolumeFraction)=1
	ModifyTable sigDigits(VolumeFraction)=3,title(VolumeFraction)="Vol. Fraction",alignment(MeanDiaVolDist)=1
	ModifyTable sigDigits(MeanDiaVolDist)=4,title(MeanDiaVolDist)="Mean Dia [A]",alignment(ModeDiaVolDist)=1
	ModifyTable sigDigits(ModeDiaVolDist)=4,title(ModeDiaVolDist)="Mode dia [A]",alignment(MeadianDiaVolDist)=1
	ModifyTable sigDigits(MeadianDiaVolDist)=4,width(MeadianDiaVolDist)=100,title(MeadianDiaVolDist)="Meadian Dia [A]"
	SetDataFolder fldrSav0
EndMacro
//*****************************************************************************************************************

Function IR3J_InvResultsTableFnct() : Table
	PauseUpdate    		// building window...
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String fldrSav0= GetDataFolder(1)
	if(!DataFolderExists("root:InvariantFitResults:"))
		Abort "No Invariant data exist."
	endif
	SetDataFolder root:InvariantFitResults:
	Wave/T SampleName
	Wave InvariantWV, InvariantQmax, TimeWave, TemperatureWave, PercentWave, OrderWave  
	Edit/K=1/W=(238,397,1078,679)/N=IR3J_InvResultsTable SampleName,InvariantWV, InvariantQmax, TimeWave, TemperatureWave, PercentWave as "Volume Size Distribution Analysis"
	AppendToTable OrderWave
	ModifyTable format(Point)=1,width(SampleName)=264,title(SampleName)="Sample name"
	ModifyTable alignment(InvariantWV)=1,sigDigits(InvariantWV)=4,title(InvariantWV)="Invariant",alignment(InvariantQmax)=1
	ModifyTable sigDigits(InvariantQmax)=3,title(InvariantQmax)="Invariant Qmax"
//	alignment(MeanDiaVolDist)=1
//	ModifyTable sigDigits(MeanDiaVolDist)=4,title(MeanDiaVolDist)="Mean Dia [A]",alignment(ModeDiaVolDist)=1
//	ModifyTable sigDigits(ModeDiaVolDist)=4,title(ModeDiaVolDist)="Mode dia [A]",alignment(MeadianDiaVolDist)=1
//	ModifyTable sigDigits(MeadianDiaVolDist)=4,width(MeadianDiaVolDist)=100,title(MeadianDiaVolDist)="Meadian Dia [A]"
	SetDataFolder fldrSav0
EndMacro

//*****************************************************************************************************************

Function IR3J_NumberSDResTblFnct() : Table
	PauseUpdate    		// building window...
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String fldrSav0= GetDataFolder(1)
	if(!DataFolderExists("root:NumbSizeDistResults:"))
		Abort "No Number Size Distribution analysis data exist."
	endif
	SetDataFolder root:NumbSizeDistResults:
	Wave/T SampleName
	Wave NumPartsPercm3,MeanDiaNumDist,ModeDiaNumDist,MeadianDiaNumDist 
	Edit/K=1/W=(238,397,1078,679)/N=IR3J_NumberSDResultsTable SampleName,NumPartsPercm3,MeanDiaNumDist,ModeDiaNumDist,MeadianDiaNumDist as "Volume Size Distribution Analysis"
	ModifyTable format(Point)=1,width(SampleName)=264,title(SampleName)="Sample name"
	ModifyTable alignment(NumPartsPercm3)=1,sigDigits(NumPartsPercm3)=4,title(NumPartsPercm3)="Num Particles [1/cm3]"
	ModifyTable alignment(MeanDiaNumDist)=1, width(NumPartsPercm3)=120
	ModifyTable sigDigits(MeanDiaNumDist)=4,title(MeanDiaNumDist)="Mean Dia [A]",alignment(ModeDiaNumDist)=1
	ModifyTable sigDigits(ModeDiaNumDist)=4,title(ModeDiaNumDist)="Mode dia [A]",alignment(MeadianDiaNumDist)=1
	ModifyTable sigDigits(MeadianDiaNumDist)=4,width(MeadianDiaNumDist)=100,title(MeadianDiaNumDist)="Meadian Dia [A]"
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
				KillWaves/Z $("root:Packages:Irena:SimpleFits:ModelLogLogInt")
				KillWaves/Z $("root:Packages:Irena:SimpleFits:ModelLogLogQ")
				KillWIndow/Z IR3J_LinDataDisplay
				KillWindow/Z IR3J_LogLogDataDisplay
				IR3J_CreateCheckGraphs()
				if(StringMatch(SimpleModel, "Invariant" ))
					IR3J_InvInitializeBackground()
					IR3J_InvFitBackground()
				endif	
			endif
			if(StringMatch(pa.ctrlName, "InvBackgModel" ))
				SVAR InvBackgModel = root:Packages:Irena:SimpleFits:InvBackgModel
				InvBackgModel = popStr
				IR3J_InvFitBackground()
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
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
		SetVariable Porod_SpecificSurface, disable=1
		SetVariable ScatteringContrast, disable=1
		PopupMenu InvBackgModel, disable=1
		SetVariable InvBckgMinQ, disable=1
		Setvariable InvBckgMaxQ, disable=1
		Setvariable invariant, disable=1
		TitleBox invariantInfo, disable=1
		Setvariable InvQmaxUsed, disable=1

		strswitch(SimpleModel)	// string switch
			case "Guinier":	// execute if case matches expression
				Setvariable Guinier_I0, disable=0
				SetVariable Guinier_Rg, disable=0
				break		// exit from switch
			case "Porod":	// execute if case matches expression
				SetVariable Porod_Constant, disable=0
				SetVariable Porod_SpecificSurface, disable=0
				SetVariable ScatteringContrast, disable=0
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
			case "Invariant":	// execute if case matches expression
				PopupMenu InvBackgModel, disable=0
				SetVariable InvBckgMinQ, disable=0
				Setvariable InvBckgMaxQ, disable=0
				Setvariable invariant, disable=0
				TitleBox invariantInfo, disable=0
				Setvariable InvQmaxUsed, disable=0
				break


			default:			// optional default expression executed

		endswitch
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

FUnction IR3J_InvInitializeBackground()
	DoWIndow IR3J_LogLogDataDisplay
	if(!V_Flag)
		return 0 //nothing to do here...  
	endif
	
	NVAR InvBckgMinQ = root:Packages:Irena:SimpleFits:InvBckgMinQ
	NVAR InvBckgMaxQ = root:Packages:Irena:SimpleFits:InvBckgMaxQ
	SVAR InvBackgModel = root:Packages:Irena:SimpleFits:InvBackgModel
	Wave/Z IntWave = root:Packages:Irena:SimpleFits:OriginalDataIntWave
	
	if(WaveExists(IntWave))
		Wave QWave = root:Packages:Irena:SimpleFits:OriginalDataQWave
		variable DataPoints=numpnts(QWave)
		if((InvBckgMinQ<QWave[0] || InvBckgMaxQ<QWave[0] || InvBckgMinQ>QWave[DataPoints-1] || InvBckgMaxQ>QWave[DataPoints-1] || InvBckgMinQ>=InvBckgMaxQ) && !(StringMatch(InvBackgModel, "none" )))
			//bad setting for fitting background range. 
			InvBckgMinQ= QWave[2*DataPoints/3]
			InvBckgMaxQ= QWave[DataPoints-2]	
		endif
		CheckDisplayed /W=IR3J_LogLogDataDisplay  IntWave
		if(V_Flag>0)
			Cursor/W=IR3J_LogLogDataDisplay /A=1/N=1/P  C  OriginalDataIntWave  BinarySearch(QWave, InvBckgMinQ )
			Cursor/W=IR3J_LogLogDataDisplay /A=1/N=1/P  D  OriginalDataIntWave  BinarySearch(QWave, InvBckgMaxQ )
		endif
	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3J_InvSyncBckgCursors(variable PreferCursors)
	//if PreferCursors=1 overwrite variables with cursors, 0 opposite
	DoWIndow IR3J_LogLogDataDisplay
	if(!V_Flag)
		return 0 //nothing to do here...  
	endif
	//cursor positions now:
	variable MinQcsrP
	if(strlen(CsrInfo(C, "IR3J_LogLogDataDisplay")) > 0 && stringMatch(CsrWave(C, "IR3J_LogLogDataDisplay", 0),"OriginalDataIntWave"))
		MinQcsrP = pcsr(C, "IR3J_LogLogDataDisplay")
	else
		MinQcsrP = 0
		PreferCursors = 0
	endif
	variable MaxQcsrP
	if(strlen(CsrInfo(D, "IR3J_LogLogDataDisplay")) > 0&& stringMatch(CsrWave(D, "IR3J_LogLogDataDisplay", 0),"OriginalDataIntWave"))
		MaxQcsrP = pcsr(D, "IR3J_LogLogDataDisplay")
	else
		MaxQcsrP = 0
		PreferCursors = 0
	endif
	
	NVAR InvBckgMinQ = root:Packages:Irena:SimpleFits:InvBckgMinQ
	NVAR InvBckgMaxQ = root:Packages:Irena:SimpleFits:InvBckgMaxQ
	Wave QWave = root:Packages:Irena:SimpleFits:OriginalDataQWave
	if(PreferCursors)
		if(MinQcsrP>0)
			InvBckgMinQ = QWave[MinQcsrP]
		endif	
		if(MaxQcsrP>0)
			InvBckgMaxQ = QWave[MaxQcsrP]
		endif	
	else
		//set cursors...
		Cursor/W=IR3J_LogLogDataDisplay /A=1/N=1/P  C  OriginalDataIntWave  BinarySearch(QWave, InvBckgMinQ )
		Cursor/W=IR3J_LogLogDataDisplay /A=1/N=1/P  D  OriginalDataIntWave  BinarySearch(QWave, InvBckgMaxQ )
	endif
	IR3J_InvFitBackground()

end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3J_InvFitBackground()

	//check we are doing Invariant and if not, get out...
	SVAR SimpleModel = root:Packages:Irena:SimpleFits:SimpleModel
	if(!Stringmatch(SimpleModel,"Invariant"))
		return 0
	endif
	dfref OldDf
	OldDf = GetDataFolderDFR
	setDataFolder root:Packages:Irena:SimpleFits:
	SVAR InvBackgModel = root:Packages:Irena:SimpleFits:InvBackgModel
	Wave IntWave = root:Packages:Irena:SimpleFits:OriginalDataIntWave
	Wave QWave = root:Packages:Irena:SimpleFits:OriginalDataQWave
	NVAR InvBckgMinQ = root:Packages:Irena:SimpleFits:InvBckgMinQ
	NVAR InvBckgMaxQ = root:Packages:Irena:SimpleFits:InvBckgMaxQ
	Duplicate/O IntWave, root:Packages:Irena:SimpleFits:InvBckgWave
	Wave InvBckgWave = root:Packages:Irena:SimpleFits:InvBckgWave
	Wave/Z Ewave = root:Packages:Irena:SimpleFits:OriginalDataErrorWave
	if(!WaveExists(Ewave))
		Duplicate/Free IntWave, Ewave
		Ewave*=0.01
	endif
	variable StartPnt, EndPnt
	StartPnt = BinarySearch(QWave, InvBckgMinQ )
	EndPnt   = BinarySearch(QWave, InvBckgMaxQ )
	variable A, B, C, D
	Wave/Z InvBckgWaveModel = root:Packages:Irena:SimpleFits:InvBckgWaveModel
	if(WaveExists(InvBckgWaveModel))	//this is used to show how Porod and Powerlaw fit... 
		RemoveFromGraph /W=IR3J_LogLogDataDisplay /Z InvBckgWaveModel
		KillWaves/Z InvBckgWaveModel, QWaveModel	
	endif
	//Calculate background to be subtracted based on user input for fn type
	If (StringMatch(InvBackgModel, "Gauss y0+A*exp((X-X0)^2/width" ))
		//Print "Fit Function is 'Gaussian'."
		Make/N=4/O/D r_bkgd_coef
		WaveStats/Q/R=[StartPnt,EndPnt]  IntWave
		//A=0.1;B=0.48;C=0.1;D=0.05
		//Prompt A,"Coefficient A"
		//Prompt B,"Coefficient X0"
		//Prompt C,"Coefficient width"
		//Prompt D,"Coefficient y0"
		A = V_max
		B = QWave[V_maxloc]
		C = (QWave[EndPnt]-QWave[StartPnt])/5
		D = V_min/10	
		r_bkgd_coef = {A,B,C,D}
		FuncFit/X=1/Q IR3J_Gauss1D kwCWave=r_bkgd_coef IntWave[StartPnt,EndPnt] /X=QWave/W=Ewave/I=1
		InvBckgWave = IR3J_Gauss1D(r_bkgd_coef,QWave)
	ElseIf (StringMatch(InvBackgModel, "Ruland A*exp(B*X^2)+y0" ))
		//Print "Fit Function is 'Ruland'."
		Make/N=3/O/D r_bkgd_coef
		WaveStats/Q/R=[StartPnt,EndPnt]  IntWave
		//A=0.1;B=0.48;C=0.1;D=0.05
		//Prompt A,"Coefficient A"
		//Prompt B,"Coefficient B"
		//Prompt D,"Coefficient y0"
		A = V_max
		B = (ln(IntWave[EndPnt-1]/A))/(QWave[EndPnt-1])^2
		D = V_min	
		r_bkgd_coef = {A,B,D}
		FuncFit/X=1/Q IR3J_Porod_Ruland, r_bkgd_coef, IntWave[StartPnt,EndPnt] /X=QWave/W=Ewave/I=1
		InvBckgWave = IR3J_Porod_Ruland(r_bkgd_coef,QWave)
	ElseIf (StringMatch(InvBackgModel, "Porod+y0" ))
		//Print "Fit Function is 'Ruland'."
		Make/N=2/O/D r_bkgd_coef, ewaveStep
		WaveStats/Q/R=[StartPnt,EndPnt]  IntWave
		A = (V_max-V_min)*(QWave[StartPnt]^4)
		D = V_min	
		r_bkgd_coef = {A,D}
		ewaveStep = {0.1*A,0.1*D}
		Make/D/T/N=0/O T_Constraints
		//find the error wave and make it available, if exists
		//Variable V_FitError=0			//This should prevent errors from being generated
		Redimension/N=1 T_Constraints
		T_Constraints[0] = {"K1 > 0"}
		FuncFit/Q PorodInLogLog, r_bkgd_coef, IntWave[StartPnt,EndPnt]  /C=T_Constraints /X=QWave /E=ewaveStep /W=Ewave /I=1
		//InvBckgWave = PorodInLogLog(r_bkgd_coef,QWave)
		InvBckgWave = r_bkgd_coef[1]
		Duplicate/O/R=[StartPnt,EndPnt] InvBckgWave, InvBckgWaveModel
		Duplicate/O/R=[StartPnt,EndPnt] QWave, QWaveModel
		InvBckgWaveModel = PorodInLogLog(r_bkgd_coef,QWaveModel)
	ElseIf (StringMatch(InvBackgModel, "PowerLaw+y0" ))
		//Print "Fit Function is 'Ruland'."
		Make/N=3/O/D r_bkgd_coef, ewaveStep
		WaveStats/Q/R=[StartPnt,EndPnt]  IntWave
		Make/D/T/N=0/O T_Constraints
		//find the error wave and make it available, if exists
		//Variable V_FitError=0			//This should prevent errors from being generated
		A = (V_max-V_min)*(QWave[StartPnt]^3.7)
		B = 3.5
		D = V_min	>0 ? V_min : abs(IntWave[EndPnt-3])
		Redimension/N=4 T_Constraints
		T_Constraints[0] = {"K0 > 0"}
		T_Constraints[1] = {"K1 > 1"}
		T_Constraints[2] = {"K1 < 5"}
		T_Constraints[3] = {"K2 > 0"}
		r_bkgd_coef = {A,B,D}
		ewaveStep = {0.1*A,0.03*B,0.1*D}
		//print " "
		//print r_bkgd_coef
		FuncFit/Q IR3J_PowerLawAndFlat, r_bkgd_coef, IntWave[StartPnt,EndPnt] /C=T_Constraints /X=QWave /E=ewaveStep /W=Ewave /I=1
		//print r_bkgd_coef
		InvBckgWave = r_bkgd_coef[2]
		Duplicate/O/R=[StartPnt,EndPnt] InvBckgWave, InvBckgWaveModel
		Duplicate/O/R=[StartPnt,EndPnt] QWave, QWaveModel
		InvBckgWaveModel = IR3J_PowerLawAndFlat(r_bkgd_coef,QWaveModel)
	ElseIf (StringMatch(InvBackgModel, "Constant" ))
		InvBckgWave = sum(IntWave, StartPnt, EndPnt) / (EndPnt - StartPnt)
	ElseIf (StringMatch(InvBackgModel, "None" ))
		WaveStats/Q/R=[StartPnt,EndPnt]  IntWave
		InvBckgWave = V_min/10
	EndIf
	
	CheckDisplayed /W=IR3J_LogLogDataDisplay IntWave, InvBckgWave 
	if(V_Flag==1)
		AppendToGraph /W=IR3J_LogLogDataDisplay InvBckgWave vs QWave
		ModifyGraph rgb(InvBckgWave)=(0,0,0)
	endif
	Wave/Z InvBckgWaveModel
	if(WaveExists(InvBckgWaveModel))
		CheckDisplayed /W=IR3J_LogLogDataDisplay IntWave, InvBckgWaveModel
		if(V_Flag) 
			AppendToGraph /W=IR3J_LogLogDataDisplay InvBckgWaveModel vs QWaveModel
			ModifyGraph lstyle(InvBckgWaveModel)=3,rgb(InvBckgWaveModel)=(1,12815,52428)
		endif
	endif
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3J_PowerLawAndFlat(w,q) : FitFunc
	Wave w
	Variable q

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ Prefactor=abs(Prefactor)
	//CurveFitDialog/ Slope=abs(slope)
	//CurveFitDialog/ f(q) = Prefactor*q^(-Slope)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Prefactor
	//CurveFitDialog/ w[1] = Slope
	//CurveFitDialog/ w[2] = Flat Background

	w[0]=abs(w[0])
	w[1]=abs(w[1])
	return w[0]*q^(-w[1])+w[2]
End

//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3J_InvCalculateInvariant()

	dfref oldDF
	OldDf = GetDataFolderDFR
	setDataFolder root:Packages:Irena:SimpleFits:
	NVAR Invariant =	root:Packages:Irena:SimpleFits:invariant
	NVAR DataQEnd = 	root:Packages:Irena:SimpleFits:DataQEnd
	NVAR DataQstart = 	root:Packages:Irena:SimpleFits:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:SimpleFits:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:SimpleFits:DataQstartPoint
	SVAR InvBackgModel = root:Packages:Irena:SimpleFits:InvBackgModel
	Wave IntWave = root:Packages:Irena:SimpleFits:OriginalDataIntWave
	Wave QWave = root:Packages:Irena:SimpleFits:OriginalDataQWave
	NVAR InvBckgMinQ = root:Packages:Irena:SimpleFits:InvBckgMinQ
	NVAR InvBckgMaxQ = root:Packages:Irena:SimpleFits:InvBckgMaxQ
	NVAR InvQmaxUsed =	root:Packages:Irena:SimpleFits:InvQmaxUsed
	
	Wave InvBckgWave = root:Packages:Irena:SimpleFits:InvBckgWave
	variable StartPnt, EndPnt
	StartPnt = BinarySearch(QWave, InvBckgMinQ )
	EndPnt   = BinarySearch(QWave, InvBckgMaxQ )

	Duplicate/O IntWave, InvariantIntWaveCorr
	//Correct data for background and add corrected data to graph
	InvariantIntWaveCorr = IntWave - InvBckgWave
	CheckDisplayed /W=IR3J_LogLogDataDisplay InvariantIntWaveCorr
	if(!V_Flag)
		AppendToGraph/W=IR3J_LogLogDataDisplay InvariantIntWaveCorr vs QWave
		ModifyGraph/W=IR3J_LogLogDataDisplay rgb(InvariantIntWaveCorr)=(0,65535,0)
	endif
	//Calculate q^2*I(q) for integral
	Duplicate/Free InvariantIntWaveCorr, Integrand
	Integrand = InvariantIntWaveCorr*QWave^2
	//endforce use of A and B curosrs to limit Q range if needed
	Duplicate/Free/R=[DataQstartPoint, DataQEndPoint] Integrand, IntegrandTrimmed
	Duplicate/O Integrand, IntegrantInt
	Duplicate/O/R=[DataQstartPoint, DataQEndPoint] QWave, QWaveTrimmed
	//Integrate, divide by 2*pi^2 when calculating from 1D I(q) data.
	Integrate/T IntegrandTrimmed /X=QWaveTrimmed/D=IntegrantInt
	IntegrantInt = IntegrantInt/(2*pi^2)		
			
	//Add Integrand_int to graph with Iq^2
	CheckDisplayed /W=IR3J_LogLogDataDisplay IntegrantInt
	if(!V_Flag)
		AppendToGraph/R/W=IR3J_LogLogDataDisplay IntegrantInt vs QWaveTrimmed
		//Label/W=IR3J_LogLogDataDisplay right "\\K(65535,0,0)\\Z14Invariant (cm\\S-1\\M\\Z14A\\S-3\\M\\Z14)"
		//SetAxis/W=IR3J_LogLogDataDisplay right 8.0271834e-10,8.792794e-05
		ModifyGraph/W=IR3J_LogLogDataDisplay log(right)=1,standoff(right)=0
	endif
	//Determine point at which slope of integral becomes zero and use that value as Q
	//checks value of integrand_int_DIF_smth at [index], and if is < 0, records Q
	//Need to use < 0 because is unlikely to be exactly 0, but will go from (+) to (-)
	Duplicate/Free IntegrantInt IntegrantInt_DIF IntegrantInt_DIF_smth
	Differentiate IntegrantInt /X=QWaveTrimmed/D=IntegrantInt_DIF
	IntegrantInt_DIF_smth = IntegrantInt_DIF 
	Smooth/EVEN/B 20, IntegrantInt_DIF_smth

	variable index, NumPntsMax=numpnts(IntegrantInt_DIF_smth)
	invariant=0
	index=0
	do
		if(IntegrantInt_DIF_smth[index]<0)		 
			invariant=IntegrantInt[index]
		endif
		index = index+1
	while(invariant==0 && index<NumPntsMax )								
	if(invariant==0)
		invariant = IntegrantInt[NumPntsMax-1]	//no cross o ver with 0 found. 
		index = NumPntsMax-1
	endif
	
	//Correct Output for unit
	//Divide twice by re to put I(q) in terms of e-^2/cm^3
	//Divide twice by Avogadro's Number to convert # of e- into mol e-
	//Convert from 1/A to 1/cm for q (three times)
	//Final units should be (mol e-/cm^3)^2
	invariant = invariant*(1e8)^3/(2.81794e-13)^2/(6.022e23)^2
	InvQmaxUsed = QWaveTrimmed[index-1]
//	//Report final values
//	Print "**********************************************"
//	//Print "Input wave is",rwave_str
//	Print "The invariant is",invariant,"(mol e-^2/cm^3)^3"
//	Print "Value of q for invariant is",QWaveTrimmed[index-1]
//	Print "**********************************************"	
	setDataFolder OldDf
end



//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
