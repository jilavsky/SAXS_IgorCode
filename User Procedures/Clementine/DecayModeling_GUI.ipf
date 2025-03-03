#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.3
#include <Peak AutoFind>


// This is part of package called "Clementine" for modeling of decay kinetics using Maximum Entropy method
// Jan Ilavsky, PhD June 1 2008
// 1.2 JIL, 7/7/2011 Added reset time for x-scaled data
// 1.3 JIL, 2/18/2025 fixed GUI control issue which prevented operations on IP9
//****************************************
// Main Evaluation procedure:
//****************************************
Function DecJIL_mainFunction()

//	IN2G_CheckScreenSize("height",670)

	DoWindow DecJIL_UserInputGraph
	if (V_Flag)
		DoWindow/K DecJIL_UserInputGraph	
	endif
	DoWindow DecJIL_InputPanel
	if (V_Flag)
		DoWindow/K DecJIL_InputPanel	
	endif
	DecJIL_Initialize()	
	Execute("DecJIL_InputPanel()")

	//fix tabs
	STRUCT WMTabControlAction locStruct
	locStruct.eventCode=2
	locStruct.tab=0
	 DecJIL_TabProc(locStruct) 
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Window DecJIL_InputPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(6,10,372,650) as "Decay time fitting"
	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman", save

	SetDrawEnv fsize= 20,fstyle= 1,textrgb= (0,15872,65280)
	DrawText 20,22,"Decay fitting input panel"
	DrawLine 8,33,100,33
//	DrawLine 8,209,349,209
//	DrawLine 9,291,350,291
//	DrawLine 8,388,348,388
//	DrawLine 140,470,348,470
	DrawLine 8,580,348,580
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (65280,0,0)
	DrawText 5,54,"Data"
	DrawText 20,600,"You need to store the results or they are lost!!"
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,52224)
	DrawText 48,635,"Set range of data to fit with cursors!!"

	Button GetHelp,pos={290,10},size={60,10},font="Times New Roman",fSize=10,proc=DecJIL_ButtonProc,title="Help", help={"Push to get help "}


	CheckBox Use1InputDataWave,pos={55,45},size={160,14},title="Data with x-scaling?", mode=0, proc=DECJIL_CheckProc
	CheckBox Use1InputDataWave,variable= root:Packages:DecayModeling:Use1InputDataWave, help={"Select if data are one wave with x-scaling"}
	CheckBox UseErrorInputDataWave,pos={230,45},size={60,16},title="Errors wave? ", help={"Select if you have error wave, if not availabel errors will be generated"}
	CheckBox UseErrorInputDataWave,variable=root:Packages:DecayModeling:UseErrorInputDataWave, proc=DECJIL_CheckProc, mode=0

	CheckBox RemovePrePeakArea,pos={55,62},size={160,14},title="Remove pre-Peak Area?", mode=0
	CheckBox RemovePrePeakArea,variable= root:Packages:DecayModeling:RemovePrePeakArea, help={"Check, if you want to use remove data before maximum in user data (pre peak area)"}
	CheckBox UseInstr_Response_Funct,pos={230,62},size={60,16},title="Instr response Data? ", help={"Select to enable use of the instrument response data"}
	CheckBox UseInstr_Response_Funct,variable=root:Packages:DecayModeling:UseInstr_Response_Funct, proc=DECJIL_CheckProc, mode=0




	PopupMenu SelectFolder,pos={10,85},size={144,21},proc=DecJIL_PopMenuProc,title="Folder with data ", help={"Select folder with data you want to analyze"}
	PopupMenu SelectFolder,mode=1,popvalue="---",value= #"\"---;\"+DecJIL_FindFolderWithWaveTypes(\"root:\", 20, \"*\", 1)"
	PopupMenu SelectDataWave,pos={17,110},size={135,21},proc=DecJIL_PopMenuProc,title="Measured Emission Data ", help={"Select wave with Emission decay profile"}
	PopupMenu SelectDataWave,mode=1,popvalue="---",value= #"\"---;\"+DecJIL_CreateListOfItemsFldr(\"root:Packages:DecayModeling:DataFolderName\",2)"

	PopupMenu SelectTimesDataWave,pos={17,135},size={135,21},proc=DecJIL_PopMenuProc,title="Meas. times Wv ", help={"Select wave with times for measured data"}
	PopupMenu SelectTimesDataWave,mode=1,popvalue="---",value= #"\"---;\"+DecJIL_CreateListOfItemsFldr(\"root:Packages:DecayModeling:DataFolderName\",2)"
	PopupMenu SelectTimesDataWave disable=(root:Packages:DecayModeling:Use1InputDataWave)

	PopupMenu InputTimeWaveUnit,pos={250,135},size={80,21},proc=DecJIL_PopMenuProc,title="Units:", help={"Select units for input time wave"}
	PopupMenu InputTimeWaveUnit,mode=DecJIL_PopMenCorMode(),value= "sec;milisec;microsec;nanosec;picosec;"
	PopupMenu InputTimeWaveUnit disable=(root:Packages:DecayModeling:Use1InputDataWave)

	PopupMenu SelectErrorsDataWave,pos={17,160},size={135,21},proc=DecJIL_PopMenuProc,title="Errors for Emission Dta:", help={"Select wave with errors for measured data"}
	PopupMenu SelectErrorsDataWave,mode=1,popvalue="---",value= #"\"---;\"+DecJIL_CreateListOfItemsFldr(\"root:Packages:DecayModeling:DataFolderName\",2)"
	PopupMenu SelectErrorsDataWave disable=!(root:Packages:DecayModeling:UseErrorInputDataWave)

	PopupMenu ResolutionDataName,pos={17,185},size={135,21},proc=DecJIL_PopMenuProc,title="Instr response fnct:", help={"Select wave with Instrument response function"}
	PopupMenu ResolutionDataName,mode=1,popvalue="---",value= #"\"---;\"+DecJIL_CreateListOfItemsFldr(\"root:Packages:DecayModeling:DataFolderName\",2)"
	PopupMenu ResolutionDataName disable=!(root:Packages:DecayModeling:UseInstr_Response_Funct)
	 

	CheckBox RebinTheData,pos={90,215},size={60,16},title="Rebin Data? ", help={"Rebin the data to log scale? "}
	CheckBox RebinTheData,variable=root:Packages:DecayModeling:RebinTheData, proc=DECJIL_CheckProc, mode=0
	CheckBox ResetTime0,pos={200,215},size={60,16},title="Start time 0 at max? ", help={"Change starting time to 0 in max point? "}
	CheckBox ResetTime0,variable=root:Packages:DecayModeling:ResetTime0, proc=DECJIL_CheckProc, mode=0




	
	SetVariable numOfPoints,pos={10,240},size={120,16},title="Rebin to :   ", help={"Number of bins to rebin the user data to"}, proc=DecJIL_SetVarProc
	SetVariable numOfPoints,limits={0,5000,25},variable=root:Packages:DecayModeling:numOfPoints, disable=!(root:Packages:DecayModeling:RebinTheData)
	SetVariable LogBinParameter,pos={155,240},size={180,16},proc=DecJIL_SetVarProc,title="Log binning paramter     ", disable=!(root:Packages:DecayModeling:RebinTheData)
	SetVariable LogBinParameter,limits={0.49,15,0.5},value= root:Packages:DecayModeling:LogBinParameter, help={"This parameter influences how the binning of data is done."}

	Button GraphIfAllowed,pos={40,258},size={180,20},font="Times New Roman",fSize=10,proc=DecJIL_ButtonProc,title="Copy data and graph", help={"Push to graph data"}



	Tabcontrol MethodControl tabLabel(0)="MaxEnt", tabLabel(1)="Fitting", value=0, pos={2,280}, size={360,300}
	Tabcontrol MethodControl labelBack=(34952,34952,34952), help={"Select modeling method"}, proc=DecJIL_TabProc

//MaxEnt parameters
	TitleBox ModelDecayTimeRange title="Model Decay Time range",pos={70,310}, frame=0
	TitleBox ModelDecayTimeRange font="Times",fSize=16,fstyle=3,fColor=(65280,1,1)
	SetVariable TauMin,pos={13,337},size={150,16},title="Minimum [sec]", help={"Input minimum for decay tau to be assumed"}
	SetVariable TauMin,limits={0,Inf,0},value= root:Packages:DecayModeling:TauMin
	SetVariable TauMax,pos={199,337},size={150,16},title="Maximum [sec]", help={"Input maximum for decay Tau to be assumed"}
	SetVariable TauMax,limits={0,Inf,0},value= root:Packages:DecayModeling:TauMax
	SetVariable TauSteps,pos={13,364},size={150,16},title="Number of Bins"
	SetVariable TauSteps,limits={1,Inf,25},value= root:Packages:DecayModeling:TauSteps, help={"Number of bins in Tau to be modeled."}

	TitleBox DataFittingParams title="Data fitting parameters",pos={70,390}, frame=0
	TitleBox DataFittingParams font="Times",fSize=16,fstyle=3,fColor=(65280,1,1)

	CheckBox FitOffset,pos={270,415},size={60,16},title="Fit offset? ", help={"Fit the offset (= background)? "}
	CheckBox FitOffset,variable=root:Packages:DecayModeling:FitOffset, proc=DECJIL_CheckProc, mode=0
	SetVariable Background,pos={5,415},size={220,16},proc=DecJIL_SetVarProc,title="Subtract offset                   ", disable=(2*root:Packages:DecayModeling:FitOffset)
	SetVariable Background,limits={-Inf,Inf,root:Packages:DecayModeling:Bckg/10},value= root:Packages:DecayModeling:Bckg, help={"Value for flat offset of measured data"}
	SetVariable ErrorMultiplier,pos={5,440},size={220,16},title="Multiply Errors by :                        ", proc=DecJIL_SetVarProc		//, disable=!(root:Packages:DecayModeling:UseUserErrors || root:Packages:DecayModeling:UseSQRTErrors)
	SetVariable ErrorMultiplier,limits={0,Inf,root:Packages:DecayModeling:ErrorsMultiplier/20},value= root:Packages:DecayModeling:ErrorsMultiplier, help={"Errors scaling factor"}
////MaxENT stuf

	TitleBox MaxEntParams title="Maximum Entropy parameters ",pos={70,475}, frame=0
	TitleBox MaxEntParams font="Times",fSize=16,fstyle=3,fColor=(65280,1,1)
	SetVariable SizesStabilityParam,pos={10,500},size={240,16},title="Sizes precision param              "//, proc=IR1R_SetVarProc
	SetVariable SizesStabilityParam,limits={0,Inf,1},value= root:Packages:DecayModeling:MaxEntStabilityParam, help={"Internal precision parameter for Maximum Entropy, usually ~0.01, range 0 to 0.5. Lower value requires resulting chi^2 to be closer to target "}
	SetVariable MaxsasIter,pos={10,520},size={240,16},title="MaxEnt max Num of Iterations "//, proc=IR1R_SetVarProc, disable=!(root:Packages:DecayModeling:UseMaxEnt)
	SetVariable MaxsasIter,limits={0,Inf,50},value= root:Packages:DecayModeling:MaximumNumIter, help={"Maximum Entropy maximum number of iterations"}
	SetVariable MaxSkyBckg,pos={10,540},size={200,16},title="MaxEnt sky backg      "//, proc=IR1R_SetVarProc, disable=!(root:Packages:DecayModeling:UseMaxEnt)
	SetVariable MaxSkyBckg,limits={0,Inf,1e-06},value= root:Packages:DecayModeling:MaxEntSkyBckg, help={"Parameter for Maximum Entropy"}
	SetVariable SuggestedSkyBackground,pos={230,540},title="Suggested:"
	SetVariable SuggestedSkyBackground,limits={0,Inf,0},value= root:Packages:DecayModeling:SuggestedSkyBackground, help={"Suggested value forParameter for Maximum Entropy"}
	SetVariable SuggestedSkyBackground size={130,16},noedit=1,frame=0
	SetVariable SuggestedSkyBackground font="Times New Roman",fstyle=0
	Button SetMaxEntSkyBckg,pos={230,560},size={100,16},font="Times New Roman",fSize=10,proc=DecJIL_ButtonProc,title="Set", help={"Set suggested MaxEnt Sky background to suggested value"}
//LSQF/Gen Opt method fitting parameters

//	Tabcontrol FittingCntrl tabLabel(0)="Dec 1", tabLabel(1)="Dec 1", tabLabel(2)="Dec 2", tabLabel(3)="Dec 3", tabLabel(4)="Dec 4",  tabLabel(5)="Dec 5"
//	Tabcontrol FittingCntrl value=0, pos={2,380}, size={355,200}, fSize=10
//	Tabcontrol FittingCntrl labelBack=(39321,39321,39321), help={"Setup fitting parameters"}//, proc=DecJIL_TabProc

	CheckBox AutoUpdate,pos={190,280},size={40,16},title="Auto Update?", help={"Update the model when any change to parameters is made?"}
	CheckBox AutoUpdate,variable=root:Packages:DecayModeling:AutoUpdate, proc=DECJIL_CheckProc, mode=0
	Button DisplayModel,pos={280,280},size={70,15},font="Times New Roman",fSize=10,proc=DecJIL_ButtonProc,title="Update", help={"Push to display current model in the graph"}

	TitleBox ModelParams title="Model Parameters ",pos={25,303}, frame=0
	TitleBox ModelParams font="Times",fSize=14,fstyle=1,fColor=(0,0,0)
	TitleBox FittingLimits title="Low   -  limits  -  high",pos={215,303}, frame=0
	TitleBox FittingLimits font="Times",fSize=14,fstyle=1,fColor=(0,0,0)

	SetVariable TimeOffset,pos={5,320},size={160,16},title="Meas. Time offset ", proc=DECJIL_SetVarProc2
	SetVariable TimeOffset,limits={0,Inf,0},value= root:Packages:DecayModeling:TimeOffset, help={"Time offset of measured data against real exposure. Small number!"}
	CheckBox FitTimeOffset,pos={175,320},size={60,16},title="Fit? ", help={"Fit the time offset? "}
	CheckBox FitTimeOffset,variable=root:Packages:DecayModeling:FitTimeOffset, proc=DECJIL_CheckProc, mode=0
	SetVariable LLTimeOffset,pos={215,320},size={50,16},title=" "
	SetVariable LLTimeOffset,limits={0,Inf,0},value= root:Packages:DecayModeling:LLTimeOffset, help={"Lower fitting limit"}
	SetVariable UlTimeOffset,pos={300,320},size={50,16},title=" "
	SetVariable UlTimeOffset,limits={0,Inf,0},value= root:Packages:DecayModeling:UlTimeOffset, help={"Upper fitting limit"}

	SetVariable MeasOffset,pos={5,340},size={160,16},title="Signal offset        ", proc=DECJIL_SetVarProc2
	SetVariable MeasOffset,limits={0,Inf,0},value= root:Packages:DecayModeling:MeasOffset, help={"Offset of measured signal (vertical) data. Background... "}
	CheckBox FitMeasOffset,pos={175,340},size={60,16},title="Fit? ", help={"Fit the offset? "}
	CheckBox FitMeasOffset,variable=root:Packages:DecayModeling:FitMeasOffset, proc=DECJIL_CheckProc, mode=0
	SetVariable LLMeasOffset,pos={215,340},size={50,16},title=" "
	SetVariable LLMeasOffset,limits={0,Inf,0},value= root:Packages:DecayModeling:LLMeasOffset, help={"Lower fitting limit"}
	SetVariable UlMeasOffset,pos={300,340},size={50,16},title=" "
	SetVariable UlMeasOffset,limits={0,Inf,0},value= root:Packages:DecayModeling:UlMeasOffset, help={"Upper fitting limit"}

	TitleBox DecayTimePops title="Decay time populations ",pos={125,360}, frame=0
	TitleBox DecayTimePops font="Times",fSize=14,fstyle=1,fColor=(0,0,0)
	TitleBox UseDT title="Use? ",pos={2,360}, frame=0
	TitleBox UseDT font="Times",fSize=10,fstyle=1,fColor=(0,0,0)

	CheckBox UseDecayTime_1,pos={5,375},size={20,16},title=" ", help={"Use Decay Time 1? "}
	CheckBox UseDecayTime_1,variable=root:Packages:DecayModeling:UseDecayTime_1, proc=DECJIL_CheckProc, mode=0
	SetVariable DecayTime_1,pos={25,375},size={140,16},title="Decay Time 1 ", proc=DECJIL_SetVarProc2, format="%1.4g"
	SetVariable DecayTime_1,limits={0,Inf,0},value= root:Packages:DecayModeling:DecayTime_1, help={"Decay Time 1 starting value. "}
	CheckBox FitDecayTime_1,pos={175,375},size={60,16},title="Fit? ", help={"Fit the offset? "}
	CheckBox FitDecayTime_1,variable=root:Packages:DecayModeling:FitDecayTime_1, proc=DECJIL_CheckProc, mode=0
	SetVariable LLDecayTime_1,pos={215,375},size={50,16},title=" ", format="%1.4g"
	SetVariable LLDecayTime_1,limits={0,Inf,0},value= root:Packages:DecayModeling:LLDecayTime_1, help={"Lower fitting limit"}
	SetVariable ULDecayTime_1,pos={300,375},size={50,16},title=" ", format="%1.4g"
	SetVariable ULDecayTime_1,limits={0,Inf,0},value= root:Packages:DecayModeling:ULDecayTime_1, help={"Upper fitting limit"}

	SetVariable SFDecayTime_1,pos={35,395},size={130,16},title="Scaling 1  ", proc=DECJIL_SetVarProc2, format="%1.4g"
	SetVariable SFDecayTime_1,limits={0,Inf,0},value= root:Packages:DecayModeling:SFDecayTime_1, help={"Scaling for Decay Time 1 . "}
	CheckBox FitSFDecayTime_1,pos={175,395},size={60,16},title="Fit? ", help={"Fit the offset? "}
	CheckBox FitSFDecayTime_1,variable=root:Packages:DecayModeling:FitSFDecayTime_1, proc=DECJIL_CheckProc, mode=0
	SetVariable LLSFDecayTime_1,pos={215,395},size={50,16},title=" ", format="%1.4g"
	SetVariable LLSFDecayTime_1,limits={0,Inf,0},value= root:Packages:DecayModeling:LLSFDecayTime_1, help={"Lower fitting limit"}
	SetVariable ULSFDecayTime_1,pos={300,395},size={50,16},title=" ", format="%1.4g"
	SetVariable ULSFDecayTime_1,limits={0,Inf,0},value= root:Packages:DecayModeling:ULSFDecayTime_1, help={"Upper fitting limit"}


	CheckBox UseDecayTime_2,pos={5,415},size={20,16},title=" ", help={"Use Decay Time 2? "}, format="%1.4g"
	CheckBox UseDecayTime_2,variable=root:Packages:DecayModeling:UseDecayTime_2, proc=DECJIL_CheckProc, mode=0
	SetVariable DecayTime_2,pos={25,415},size={140,16},title="Decay Time 2 ", proc=DECJIL_SetVarProc2
	SetVariable DecayTime_2,limits={0,Inf,0},value= root:Packages:DecayModeling:DecayTime_2, help={"Decay Time 2 starting value. "}
	CheckBox FitDecayTime_2,pos={175,415},size={60,16},title="Fit? ", help={"Fit the offset? "}
	CheckBox FitDecayTime_2,variable=root:Packages:DecayModeling:FitDecayTime_2, proc=DECJIL_CheckProc, mode=0
	SetVariable LLDecayTime_2,pos={215,415},size={50,16},title=" ", format="%1.4g"
	SetVariable LLDecayTime_2,limits={0,Inf,0},value= root:Packages:DecayModeling:LLDecayTime_2, help={"Lower fitting limit"}
	SetVariable ULDecayTime_2,pos={300,415},size={50,16},title=" ", format="%1.4g"
	SetVariable ULDecayTime_2,limits={0,Inf,0},value= root:Packages:DecayModeling:ULDecayTime_2, help={"Upper fitting limit"}

	SetVariable SFDecayTime_2,pos={35,435},size={130,16},title="Scaling 2  ", proc=DECJIL_SetVarProc2, format="%1.4g"
	SetVariable SFDecayTime_2,limits={0,Inf,0},value= root:Packages:DecayModeling:SFDecayTime_2, help={"Scaling for Decay Time 2 . "}
	CheckBox FitSFDecayTime_2,pos={175,435},size={60,16},title="Fit? ", help={"Fit the offset? "}
	CheckBox FitSFDecayTime_2,variable=root:Packages:DecayModeling:FitSFDecayTime_2, proc=DECJIL_CheckProc, mode=0
	SetVariable LLSFDecayTime_2,pos={215,435},size={50,16},title=" ", format="%1.4g"
	SetVariable LLSFDecayTime_2,limits={0,Inf,0},value= root:Packages:DecayModeling:LLSFDecayTime_2, help={"Lower fitting limit"}
	SetVariable ULSFDecayTime_2,pos={300,435},size={50,16},title=" ", format="%1.4g"
	SetVariable ULSFDecayTime_2,limits={0,Inf,0},value= root:Packages:DecayModeling:ULSFDecayTime_2, help={"Upper fitting limit"}



	CheckBox UseDecayTime_3,pos={5,455},size={20,16},title=" ", help={"Use Decay Time 3? "}
	CheckBox UseDecayTime_3,variable=root:Packages:DecayModeling:UseDecayTime_3, proc=DECJIL_CheckProc, mode=0
	SetVariable DecayTime_3,pos={25,455},size={140,16},title="Decay Time 3 ", proc=DECJIL_SetVarProc2, format="%1.4g"
	SetVariable DecayTime_3,limits={0,Inf,0},value= root:Packages:DecayModeling:DecayTime_3, help={"Decay Time 3 starting value. "}
	CheckBox FitDecayTime_3,pos={175,455},size={60,16},title="Fit? ", help={"Fit the offset? "}
	CheckBox FitDecayTime_3,variable=root:Packages:DecayModeling:FitDecayTime_3, proc=DECJIL_CheckProc, mode=0
	SetVariable LLDecayTime_3,pos={215,455},size={50,16},title=" ", format="%1.4g"
	SetVariable LLDecayTime_3,limits={0,Inf,0},value= root:Packages:DecayModeling:LLDecayTime_3, help={"Lower fitting limit"}
	SetVariable ULDecayTime_3,pos={300,455},size={50,16},title=" ", format="%1.4g"
	SetVariable ULDecayTime_3,limits={0,Inf,0},value= root:Packages:DecayModeling:ULDecayTime_3, help={"Upper fitting limit"}

	SetVariable SFDecayTime_3,pos={35,475},size={130,16},title="Scaling 3  ", proc=DECJIL_SetVarProc2, format="%1.4g"
	SetVariable SFDecayTime_3,limits={0,Inf,0},value= root:Packages:DecayModeling:SFDecayTime_3, help={"Scaling for Decay Time 3. "}
	CheckBox FitSFDecayTime_3,pos={175,475},size={60,16},title="Fit? ", help={"Fit the offset? "}
	CheckBox FitSFDecayTime_3,variable=root:Packages:DecayModeling:FitSFDecayTime_3, proc=DECJIL_CheckProc, mode=0
	SetVariable LLSFDecayTime_3,pos={215,475},size={50,16},title=" ", format="%1.4g"
	SetVariable LLSFDecayTime_3,limits={0,Inf,0},value= root:Packages:DecayModeling:LLSFDecayTime_3, help={"Lower fitting limit"}
	SetVariable ULSFDecayTime_3,pos={300,475},size={50,16},title=" ", format="%1.4g"
	SetVariable ULSFDecayTime_3,limits={0,Inf,0},value= root:Packages:DecayModeling:ULSFDecayTime_3, help={"Upper fitting limit"}


	CheckBox UseDecayTime_4,pos={5,495},size={20,16},title=" ", help={"Use Decay Time 4? "}
	CheckBox UseDecayTime_4,variable=root:Packages:DecayModeling:UseDecayTime_4, proc=DECJIL_CheckProc, mode=0
	SetVariable DecayTime_4,pos={25,495},size={140,16},title="Decay Time 4 ", proc=DECJIL_SetVarProc2, format="%1.4g"
	SetVariable DecayTime_4,limits={0,Inf,0},value= root:Packages:DecayModeling:DecayTime_4, help={"Decay Time 4 starting value. "}
	CheckBox FitDecayTime_4,pos={175,495},size={60,16},title="Fit? ", help={"Fit the offset? "}
	CheckBox FitDecayTime_4,variable=root:Packages:DecayModeling:FitDecayTime_4, proc=DECJIL_CheckProc, mode=0
	SetVariable LLDecayTime_4,pos={215,495},size={50,16},title=" ", format="%1.4g"
	SetVariable LLDecayTime_4,limits={0,Inf,0},value= root:Packages:DecayModeling:LLDecayTime_4, help={"Lower fitting limit"}
	SetVariable ULDecayTime_4,pos={300,495},size={50,16},title=" ", format="%1.4g"
	SetVariable ULDecayTime_4,limits={0,Inf,0},value= root:Packages:DecayModeling:ULDecayTime_4, help={"Upper fitting limit"}

	SetVariable SFDecayTime_4,pos={35,515},size={130,16},title="Scaling 4  ", proc=DECJIL_SetVarProc2, format="%1.4g"
	SetVariable SFDecayTime_4,limits={0,Inf,0},value= root:Packages:DecayModeling:SFDecayTime_4, help={"Scaling for Decay Time 4 "}
	CheckBox FitSFDecayTime_4,pos={175,515},size={60,16},title="Fit? ", help={"Fit the offset? "}
	CheckBox FitSFDecayTime_4,variable=root:Packages:DecayModeling:FitSFDecayTime_4, proc=DECJIL_CheckProc, mode=0
	SetVariable LLSFDecayTime_4,pos={215,515},size={50,16},title=" ", format="%1.4g"
	SetVariable LLSFDecayTime_4,limits={0,Inf,0},value= root:Packages:DecayModeling:LLSFDecayTime_4, help={"Lower fitting limit"}
	SetVariable ULSFDecayTime_4,pos={300,515},size={50,16},title=" ", format="%1.4g"
	SetVariable ULSFDecayTime_4,limits={0,Inf,0},value= root:Packages:DecayModeling:ULSFDecayTime_4, help={"Upper fitting limit"}


	CheckBox UseDecayTime_5,pos={5,535},size={20,16},title=" ", help={"Use Decay Time 5? "}
	CheckBox UseDecayTime_5,variable=root:Packages:DecayModeling:UseDecayTime_5, proc=DECJIL_CheckProc, mode=0
	SetVariable DecayTime_5,pos={25,535},size={140,16},title="Decay Time 5 ", proc=DECJIL_SetVarProc2, format="%1.4g"
	SetVariable DecayTime_5,limits={0,Inf,0},value= root:Packages:DecayModeling:DecayTime_5, help={"Decay Time 4 starting value. "}
	CheckBox FitDecayTime_5,pos={175,535},size={60,16},title="Fit? ", help={"Fit the offset? "}
	CheckBox FitDecayTime_5,variable=root:Packages:DecayModeling:FitDecayTime_5, proc=DECJIL_CheckProc, mode=0
	SetVariable LLDecayTime_5,pos={215,535},size={50,16},title=" ", format="%1.4g"
	SetVariable LLDecayTime_5,limits={0,Inf,0},value= root:Packages:DecayModeling:LLDecayTime_5, help={"Lower fitting limit"}
	SetVariable ULDecayTime_5,pos={300,535},size={50,16},title=" ", format="%1.4g"
	SetVariable ULDecayTime_5,limits={0,Inf,0},value= root:Packages:DecayModeling:ULDecayTime_5, help={"Upper fitting limit"}

	SetVariable SFDecayTime_5,pos={35,555},size={130,16},title="Scaling 5  ", proc=DECJIL_SetVarProc2, format="%1.4g"
	SetVariable SFDecayTime_5,limits={0,Inf,0},value= root:Packages:DecayModeling:SFDecayTime_5, help={"Scaling for Decay Time 5 "}
	CheckBox FitSFDecayTime_5,pos={175,555},size={60,16},title="Fit? ", help={"Fit the offset? "}
	CheckBox FitSFDecayTime_5,variable=root:Packages:DecayModeling:FitSFDecayTime_5, proc=DECJIL_CheckProc, mode=0
	SetVariable LLSFDecayTime_5,pos={215,555},size={50,16},title=" ", format="%1.4g"
	SetVariable LLSFDecayTime_5,limits={0,Inf,0},value= root:Packages:DecayModeling:LLSFDecayTime_5, help={"Lower fitting limit"}
	SetVariable ULSFDecayTime_5,pos={300,555},size={50,16},title=" ", format="%1.4g"
	SetVariable ULSFDecayTime_5,limits={0,Inf,0},value= root:Packages:DecayModeling:ULSFDecayTime_5, help={"Upper fitting limit"}

	Button AppendResultsToGraph,pos={250,583},size={100,15},font="Times New Roman",fSize=10,proc=DecJIL_ButtonProc,title="Append results", help={"Push to display current model in the graph"}



//	ListOfVariables+="TimeOffset;FitTimeOffset;LLTimeOffset;UlTimeOffset;"
//	ListOfVariables+="MeasOffset;FitMeasOffset;LLMeasOffset;UlMeasOffset;"
//	ListOfVariables+="UseDecayTime_1;DecayTime_1;FitDecayTime_1;LLDecayTime_1;ULDecayTime_1;"
//	ListOfVariables+="SFDecayTime_1;FitSFDecayTime_1;LLSFDecayTime_1;ULSFDecayTime_1;"

//
//	CheckBox UseUserErrors,pos={250,310},size={141,14},proc=IR1R_InputPanelCheckboxProc,title="Use user errors?", mode=1
//	CheckBox UseUserErrors,variable= root:Packages:DecayModeling:UseUserErrors, help={"Check, if you want to use errors provided by you from error wave"}
//	CheckBox UseSQRTErrors,pos={250,330},size={141,14},proc=IR1R_InputPanelCheckboxProc,title="Use sqrt errors?", mode=1
//	CheckBox UseSQRTErrors,variable= root:Packages:DecayModeling:UseSQRTErrors, help={"Check, if you want to use errors equal square root of intensity"}
//	CheckBox UsePercentErrors,pos={250,350},size={141,14},proc=IR1R_InputPanelCheckboxProc,title="Use % errors?", mode=1
//	CheckBox UsePercentErrors,variable= root:Packages:DecayModeling:UsePercentErrors, help={"Check, if you want to use errors equal n% of intensity"}
//	CheckBox UseNoErrors,pos={250,370},size={141,14},proc=IR1R_InputPanelCheckboxProc,title="Use No errors?", mode=1
//	CheckBox UseNoErrors,variable= root:Packages:DecayModeling:UseNoErrors, help={"Check, if you do not want to use errors"}

//	SetVariable PercentErrorToUse,pos={5,358},size={220,16},title="Errors % ofintensity :                     ", proc=IR1R_SetVarProc, disable=!(root:Packages:DecayModeling:UsePercentErrors)
//	SetVariable PercentErrorToUse,limits={0,Inf,1},value= root:Packages:DecayModeling:PercentErrorToUse, help={"Percent errors of intensity"}
//


////end buttons
	Button SaveResults,pos={10,600},size={150,20},font="Times New Roman",fSize=10,proc=DecJIL_ButtonProc,title="Save Results", help={"Push to graph data"}
	Button RunFitting,pos={200,600},size={150,20},font="Times New Roman",fSize=10,proc=DecJIL_ButtonProc,title="Run Fitting", help={"Push to run fitting"}
EndMacro
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function DecJIL_SetVarProc2(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

//	switch( sva.eventCode )
//		case 1: // mouse up
//		case 2: // Enter key
//		case 3: // Live update
	if(sva.eventCode>0)
		Variable dval = sva.dval
		String sval = sva.sval
		NVAR Val=$("root:Packages:DecayModeling:"+sva.ctrlName)			
		NVAR UL=$("root:Packages:DecayModeling:UL"+sva.ctrlName)			
		NVAR LL=$("root:Packages:DecayModeling:LL"+sva.ctrlName)			
		UL=10*Val
		LL=Val/10
		Execute("SetVariable "+sva.ctrlName+",limits={0,Inf,"+num2str(Val/10)+"}, win=DecJIL_InputPanel")	
		DecJIL_RecalculateIfRequested()
	endif	
//			break
//	endswitch

	return 0
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function DecJIL_TabProc(tca) : TabControl
	STRUCT WMTabControlAction &tca

	switch( tca.eventCode )
		case 2: // mouse up
			Variable tab = tca.tab
	SetVariable TauMin, disable=(tab!=0)
	SetVariable TauMax, disable=(tab!=0)
	SetVariable TauSteps, disable=(tab!=0)
	CheckBox FitOffset, disable=(tab!=0)
	SetVariable Background, disable=(tab!=0)
	SetVariable ErrorMultiplier, disable=(tab!=0)
	SetVariable SizesStabilityParam, disable=(tab!=0)
	SetVariable MaxsasIter, disable=(tab!=0)
	SetVariable MaxSkyBckg, disable=(tab!=0)
	SetVariable SuggestedSkyBackground, disable=(tab!=0)
	Button SetMaxEntSkyBckg, disable=(tab!=0)
	TitleBox ModelDecayTimeRange, disable=(tab!=0)	
	TitleBox DataFittingParams, disable=(tab!=0)			
	TitleBox MaxEntParams	, disable=(tab!=0)	
			
	//
//	Tabcontrol FittingCntrl, disable=(tab!=1)		
	TitleBox ModelParams , disable=(tab!=1)
	TitleBox FittingLimits , disable=(tab!=1)
	TitleBox DecayTimePops, disable=(tab!=1)
	TitleBox UseDT, disable=(tab!=1)
	Checkbox AutoUpdate, disable=(tab!=1)
	NVAR FitTimeOffset=root:Packages:DecayModeling:FitTimeOffset
	NVAR FitMeasOffset=root:Packages:DecayModeling:FitMeasOffset
	SetVariable TimeOffset, disable=(tab!=1)
	CheckBox FitTimeOffset, disable=(tab!=1)
	SetVariable LLTimeOffset, disable=(tab!=1 || !FitTimeOffset)
	SetVariable UlTimeOffset, disable=(tab!=1 || !FitTimeOffset)
	SetVariable MeasOffset, disable=(tab!=1)
	CheckBox FitMeasOffset, disable=(tab!=1)
	SetVariable LLMeasOffset, disable=(tab!=1 || !FitMeasOffset)
	SetVariable UlMeasOffset, disable=(tab!=1 ||!FitMeasOffset)

	NVAR Disable1=root:Packages:DecayModeling:UseDecayTime_1
	NVAR FitDecayTime_1=root:Packages:DecayModeling:FitDecayTime_1
	NVAR FitSFDecayTime_1=root:Packages:DecayModeling:FitSFDecayTime_1
	CheckBox UseDecayTime_1, disable=(tab!=1 )
	SetVariable DecayTime_1, disable=(tab!=1 || !Disable1)
	CheckBox FitDecayTime_1, disable=(tab!=1 || !Disable1)
	SetVariable LLDecayTime_1, disable=(tab!=1 || !Disable1 || !FitDecayTime_1)
	SetVariable ULDecayTime_1, disable=(tab!=1 || !Disable1 || !FitDecayTime_1)
	SetVariable SFDecayTime_1, disable=(tab!=1 || !Disable1)
	CheckBox FitSFDecayTime_1, disable=(tab!=1 || !Disable1)
	SetVariable LLSFDecayTime_1, disable=(tab!=1 || !Disable1 || !FitSFDecayTime_1)
	SetVariable ULSFDecayTime_1, disable=(tab!=1 || !Disable1 || !FitSFDecayTime_1)
			
	NVAR Disable2=root:Packages:DecayModeling:UseDecayTime_2
	NVAR FitDecayTime_2=root:Packages:DecayModeling:FitDecayTime_2
	NVAR FitSFDecayTime_2=root:Packages:DecayModeling:FitSFDecayTime_2
	CheckBox UseDecayTime_2, disable=(tab!=1)
	SetVariable DecayTime_2, disable=(tab!=1 || !Disable2)
	CheckBox FitDecayTime_2, disable=(tab!=1 || !Disable2)
	SetVariable LLDecayTime_2, disable=(tab!=1 || !Disable2 || !FitDecayTime_2)
	SetVariable ULDecayTime_2, disable=(tab!=1 || !Disable2 || !FitDecayTime_2)
	SetVariable SFDecayTime_2, disable=(tab!=1 || !Disable2)
	CheckBox FitSFDecayTime_2, disable=(tab!=1 || !Disable2)
	SetVariable LLSFDecayTime_2, disable=(tab!=1 || !Disable2 || !FitSFDecayTime_2)
	SetVariable ULSFDecayTime_2, disable=(tab!=1 || !Disable2 || !FitSFDecayTime_2)
			
	NVAR Disable_3=root:Packages:DecayModeling:UseDecayTime_3
	NVAR FitDecayTime_3=root:Packages:DecayModeling:FitDecayTime_3
	NVAR FitSFDecayTime_3=root:Packages:DecayModeling:FitSFDecayTime_3
	CheckBox UseDecayTime_3, disable=(tab!=1)
	SetVariable DecayTime_3, disable=(tab!=1 || !Disable_3)
	CheckBox FitDecayTime_3, disable=(tab!=1 || !Disable_3)
	SetVariable LLDecayTime_3, disable=(tab!=1 || !Disable_3 || !FitDecayTime_3)
	SetVariable ULDecayTime_3, disable=(tab!=1 || !Disable_3 || !FitDecayTime_3)
	SetVariable SFDecayTime_3, disable=(tab!=1 || !Disable_3)
	CheckBox FitSFDecayTime_3, disable=(tab!=1 || !Disable_3)
	SetVariable LLSFDecayTime_3, disable=(tab!=1 || !Disable_3 || !FitSFDecayTime_3)
	SetVariable ULSFDecayTime_3, disable=(tab!=1 || !Disable_3 || !FitSFDecayTime_3)
			
	NVAR Disable_4=root:Packages:DecayModeling:UseDecayTime_4
	NVAR FitDecayTime_4=root:Packages:DecayModeling:FitDecayTime_4
	NVAR FitSFDecayTime_4=root:Packages:DecayModeling:FitSFDecayTime_4
	CheckBox UseDecayTime_4, disable=(tab!=1)
	SetVariable DecayTime_4, disable=(tab!=1 || !Disable_4)
	CheckBox FitDecayTime_4, disable=(tab!=1 || !Disable_4)
	SetVariable LLDecayTime_4, disable=(tab!=1 || !Disable_4 || !FitDecayTime_4)
	SetVariable ULDecayTime_4, disable=(tab!=1 || !Disable_4 || !FitDecayTime_4)
	SetVariable SFDecayTime_4, disable=(tab!=1 || !Disable_4)
	CheckBox FitSFDecayTime_4, disable=(tab!=1 || !Disable_4)
	SetVariable LLSFDecayTime_4, disable=(tab!=1 || !Disable_4 || !FitSFDecayTime_4)
	SetVariable ULSFDecayTime_4, disable=(tab!=1 || !Disable_4 || !FitSFDecayTime_4)
			
	NVAR Disable_5=root:Packages:DecayModeling:UseDecayTime_5
	NVAR FitDecayTime_5=root:Packages:DecayModeling:FitDecayTime_5
	NVAR FitSFDecayTime_5=root:Packages:DecayModeling:FitSFDecayTime_5
	CheckBox UseDecayTime_5, disable=(tab!=1)
	SetVariable DecayTime_5, disable=(tab!=1 || !Disable_5)
	CheckBox FitDecayTime_5, disable=(tab!=1 || !Disable_5)
	SetVariable LLDecayTime_5, disable=(tab!=1 || !Disable_5 || !FitDecayTime_5)
	SetVariable ULDecayTime_5, disable=(tab!=1 || !Disable_5 || !FitDecayTime_5)
	SetVariable SFDecayTime_5, disable=(tab!=1 || !Disable_5)
	CheckBox FitSFDecayTime_5, disable=(tab!=1 || !Disable_5)
	SetVariable LLSFDecayTime_5, disable=(tab!=1 || !Disable_5 || !FitSFDecayTime_5)
	SetVariable ULSFDecayTime_5, disable=(tab!=1 || !Disable_5 || !FitSFDecayTime_5)
		
	Button DisplayModel, disable=(tab!=1)	
	
	DecJIL_FormatGraphTabChange(tab)
			break
	endswitch

	return 0
End

//*****************************************************************************************************************
//*****************************************************************************************************************

//	Constant kMili = 1e-3
//	Constant kMicro = 1e-6
//	Constant kNano = 1e-9
//	Constant kPico = 1e-12

Function DecJIL_PopMenCorMode()
	string ModeString="sec;milisec;microsec;nanosec;"
	NVAR ScaleInputTimeBy = root:Packages:DecayModeling:ScaleInputTimeBy

	
	if(ScaleInputTimeBy==1)
		return 1
	elseif(ScaleInputTimeBy==1e-3)
		return 2
	elseif(ScaleInputTimeBy==1e-6)
		return 3
	elseif(ScaleInputTimeBy==1e-9)
		return 4
	elseif(ScaleInputTimeBy==1e-12)
		return 5
	else
		return 0
	endif
	
//	
//	switch(ScaleInputTimeBy)	// numeric switch
//		case 1:		// execute if case matches expression
//			return 1
//			break						// exit from switch
//		case 1e-3:		// execute if case matches expression
//			return 2
//			break
//		case 1e-6:		// execute if case matches expression
//			return 3
//			break
//		case 1e-9:		// execute if case matches expression
//			return 4
//			break
//		case 1e-12:		// execute if case matches expression
//			return 5
//			break
//		default:								// optional default expression executed
//			return 0					// when no case matches
//	endswitch
//			


end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function DecJIL_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	Variable popNum
	String popStr
	switch( pa.eventCode )
		case 2: // mouse up
			if(stringmatch(pa.ctrlName,"SelectFolder"))
				popNum = pa.popNum
				popStr = pa.popStr
				SVAR DataFolderName = root:Packages:DecayModeling:DataFolderName
				DataFolderName = popStr
				Execute("PopupMenu SelectDataWave win=DecJIL_InputPanel, value=DecJIL_CreateListOfItemsFldr(root:Packages:DecayModeling:DataFolderName,2)")
				Execute("PopupMenu SelectTimesDataWave win=DecJIL_InputPanel, value=DecJIL_CreateListOfItemsFldr(root:Packages:DecayModeling:DataFolderName,2)")
				Execute("PopupMenu SelectErrorsDataWave win=DecJIL_InputPanel, value=DecJIL_CreateListOfItemsFldr(root:Packages:DecayModeling:DataFolderName,2)")
				Execute("PopupMenu ResolutionDataName win=DecJIL_InputPanel, value=DecJIL_CreateListOfItemsFldr(root:Packages:DecayModeling:DataFolderName,2)")
			endif
			if(stringmatch(pa.ctrlName ,"SelectDataWave"))
				popNum = pa.popNum
				popStr = pa.popStr
				SVAR DataWaveName = root:Packages:DecayModeling:OriginalDataName
				DataWaveName = popStr
			endif
			if(stringmatch(pa.ctrlName ,"SelectTimesDataWave"))
				popNum = pa.popNum
				popStr = pa.popStr
				SVAR OriginalTImeDataName = root:Packages:DecayModeling:OriginalTImeDataName
				OriginalTImeDataName = popStr
			endif
			if(stringmatch(pa.ctrlName ,"SelectErrorsDataWave"))
				popNum = pa.popNum
				popStr = pa.popStr
				SVAR OriginalErrorDataName = root:Packages:DecayModeling:OriginalErrorDataName
				OriginalErrorDataName = popStr
			endif
			if(stringmatch(pa.ctrlName ,"ResolutionDataName"))
				popNum = pa.popNum
				popStr = pa.popStr
				SVAR ResolutionDataName = root:Packages:DecayModeling:ResolutionDataName
				ResolutionDataName = popStr
			endif
			if(stringmatch(pa.ctrlName ,"InputTimeWaveUnit"))
				popNum = pa.popNum
				popStr = pa.popStr
				NVAR ScaleInputTimeBy = root:Packages:DecayModeling:ScaleInputTimeBy
				strswitch(popStr)	// numeric switch
					case "sec":		// execute if case matches expression
						ScaleInputTimeBy=1
						break						// exit from switch
					case "milisec":		// execute if case matches expression
						ScaleInputTimeBy=1e-3
						break
					case "microsec":		// execute if case matches expression
						ScaleInputTimeBy=1e-6
						break
					case "nanosec":		// execute if case matches expression
						ScaleInputTimeBy=1e-9
						break
					case "picosec":		// execute if case matches expression
						ScaleInputTimeBy=1e-12
						break
					default:								// optional default expression executed
						ScaleInputTimeBy=1						// when no case matches
				endswitch
			endif




			break


	endswitch

	return 0
End
//**********************************************************************************************
//**********************************************************************************************

Function DecJIL_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"GraphIfAllowed"))
				//Copy data and create graph...
				DECJIL_CopyAndGraphData()
				AutoPositionWindow/E/M=0 /R=DecJIL_InputPanel DecJIL_UserInputGraph
			endif
			if(stringmatch(ba.ctrlName,"SetMaxEntSkyBckg"))
				NVAR  MaxEntSkyBckg = root:Packages:DecayModeling:MaxEntSkyBckg
				NVAR SuggestedSkyBackground= root:Packages:DecayModeling:SuggestedSkyBackground
				MaxEntSkyBckg = SuggestedSkyBackground
				Button SetMaxEntSkyBckg win=DecJIL_InputPanel, fColor=(0,0,0)
			endif
			if(stringmatch(ba.ctrlName,"RunFitting"))
				ControlInfo/W=DecJIL_InputPanel  MethodControl
				if(V_Value==0)
					DecJIL_RunMEMFittingOnData()
				elseif(V_Value==1)
					DecJIL_Fitting()
				endif
			endif
			if(stringmatch(ba.ctrlName,"SaveResults"))
				DecJIL_SaveData()
			endif
			if(stringmatch(ba.ctrlName,"DisplayModel"))
				DecJIL_CalcModelManually(1)
				DecJIL_FormatGraphTabChange(1)
			endif
			if(stringmatch(ba.ctrlName,"AppendResultsToGraph"))
				DecJIL_AppendResToGraph()
			endif
			if(stringmatch(ba.ctrlName,"GetHelp"))
				DisplayHelpTopic "Clementine MEM decay kinetics modeling"
			endif

			break
	endswitch

	return 0
End
//**********************************************************************************************
//**********************************************************************************************
Function DecJIL_AppendResToGraph()

	string OldDf
	OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:DecayModeling
	ControlInfo/W=DecJIL_InputPanel  MethodControl
	variable methodToAppend = V_Value	//0= MaxEnt, 1= LSQF
//				if(V_Value==0)
//					DecJIL_RunMEMFittingOnData()
//				elseif(V_Value==1)
//					DecJIL_Fitting()
//				endif
	DoWindow DecJIL_UserInputGraph
	If(!V_Flag)
		return 0
	endif
	variable i
	string tempTagStr
	if(methodToAppend==1)	//LSQF
		//need to test all populations, if used and if so, append to graph some results.	
			Wave Model_LSQF
			Wave Model_LSQFMeasTimes
			For(i=1;i<6;i+=1)
				NVAR UseMe=$("root:Packages:DecayModeling:UseDecayTime_"+num2str(i))
				CheckDisplayed /W=DecJIL_UserInputGraph Model_LSQF
				if(UseMe && V_Flag)
					NVAR DecayTime=$("root:Packages:DecayModeling:DecayTime_"+num2str(i))
					NVAR ScaleDecayTime=$("root:Packages:DecayModeling:SFDecayTime_"+num2str(i))
					tempTagStr = "Decay Time    "+num2str(i)+"\r"+"Decay Time = "+num2str(DecayTime)+"   sec    \r"
					tempTagStr += "Scale factor = "+num2str(ScaleDecayTime)
					Tag/C/N=$("Decay_"+num2str(i))/A=LB/TL=0/X=-20.00/Y=-20.00   Model_LSQF, pnt2x(Model_LSQF,BinarySearch(Model_LSQFMeasTimes, DecayTime )), tempTagStr
				endif
			endfor

	
	elseif(methodToAppend==0)
		Wave Model_Lifetime_Dist=root:Packages:DecayModeling:Model_Lifetime_Dist
		Wave DecayTimes=root:Packages:DecayModeling:DecayTimes
		Checkdisplayed/W=DecJIL_UserInputGraph  Model_Lifetime_Dist
		if(!V_Flag)
			return 0
		endif
		FindPeak /Q Model_Lifetime_Dist
		if(V_Flag==0)		//Peak was found...
			Variable pBegin=0, pEnd= numpnts(Model_Lifetime_Dist)-1
			Variable/C estimates= EstPeakNoiseAndSmfact(Model_Lifetime_Dist,pBegin, pEnd)
			Variable noiselevel=real(estimates)
			Variable smoothingFactor=imag(estimates)
			NVAR MEMFindPeakPar = root:Packages:DecayModeling:MEMFindPeakPar
			Variable peaksFound= AutoFindPeaks(Model_Lifetime_Dist,pBegin,pEnd,noiseLevel,smoothingFactor,10)
			if( peaksFound > 0 )
				WAVE W_AutoPeakInfo
				// Remove too-small peaks
				peaksFound= TrimAmpAutoPeakInfo(W_AutoPeakInfo,MEMFindPeakPar/100)
				if( peaksFound > 0 )
					SetDimLabel 1, 0, center, W_AutoPeakInfo
					SetDimLabel 1, 1, width, W_AutoPeakInfo
					SetDimLabel 1, 2, height, W_AutoPeakInfo
					For(i=0;i<peaksFound;i+=1)
						
						tempTagStr = "Decay Time Peak   "+num2str(i+1)+"\r"+"Decay Time = "+num2str(DecayTimes[W_AutoPeakInfo[i][0]])+"   sec    \r"
						variable temp = DecayTimes[W_AutoPeakInfo[i][0]+ W_AutoPeakInfo[i][1]] - DecayTimes[W_AutoPeakInfo[i][0] - W_AutoPeakInfo[i][1]]
						tempTagStr += "FWHM = "+num2str(temp)+"  sec \r"
						tempTagStr += "Scale factor = "+num2str(W_AutoPeakInfo[i][2])
						Tag/C/N=$("MEM_"+num2str(i))/A=LB/TL=0/X=-20.00/Y=-20.00   Model_Lifetime_Dist, pnt2x(Model_Lifetime_Dist,W_AutoPeakInfo[i][0]), tempTagStr
					endfor
					
				endif
			endif
		endif
	endif

	
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************

//**********************************************************************************************
//**********************************************************************************************
Function DecJIL_SaveData()

	string OldDf
	OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:DecayModeling
	SVAR DataFolderName = root:Packages:DecayModeling:DataFolderName
	ControlInfo/W=DecJIL_InputPanel  MethodControl
	variable methodToAppend = V_Value	//0= MaxEnt, 1= LSQF

	string NewDataUniqueName
	String NewEnding
	string NewNote=""

	IF(methodToAppend==0)
		
		Wave/Z ModelTimeAxis=root:Packages:DecayModeling:DecayTimes
		Wave/Z ModelResults = root:Packages:DecayModeling:Model_Lifetime_Dist
		Wave/Z CalcDataFromModel = root:Packages:DecayModeling:Model_Fit_Function
		Wave/Z CalcDataFromModelXaxis=root:Packages:DecayModeling:FitRebinnedDataMeasTimes
		Wave/Z NormRes=root:Packages:DecayModeling:NormalizedResidual
		if(!WaveExists(ModelTimeAxis) ||!WaveExists(ModelResults))
			Abort "Data do nto exist, run the fitting first"
		endif
		
		setDataFolder DataFolderName
	      NewDataUniqueName="MEMDecayTimesDist_"
		NewDataUniqueName = UniqueName(NewDataUniqueName, 1, 0 )
		 NewEnding = StringFromList(1, NewDataUniqueName , "_")
		Duplicate/O ModelResults, $("MEMDecayTimesDist_"+NewEnding)
		Duplicate/O ModelTimeAxis, $("MEMDecayTimesDistX_"+NewEnding)
		Duplicate/O CalcDataFromModel, $("MEMCalcModel_"+NewEnding)
		Duplicate/O CalcDataFromModelXaxis, $("MEMCalcModelX_"+NewEnding)
		Duplicate/O NormRes, $("MEMCalcModelNormRes_"+NewEnding)
		
		NVAR chisq=root:Packages:DecayModeling:CurrentChiSq
		NVAR LogBinPar = root:Packages:DecayModeling:LogBinParameter
		NVAR UseResWv=root:Packages:DecayModeling:UseInstr_Response_Funct
		NVAR errMult=root:Packages:DecayModeling:ErrorsMultiplier
		NVAR UseErrs=root:Packages:DecayModeling:UseErrorInputDataWave
		NVAR Rebin=root:Packages:DecayModeling:RebinTheData
		NVAR RebinPnts=root:Packages:DecayModeling:numOfPoints
		NVAR Xscaling=root:Packages:DecayModeling:Use1InputDataWave
		NVAR MEMIter=root:Packages:DecayModeling:NumberIterations
		SVAR DataName=root:Packages:DecayModeling:OriginalDataName
		SVAR ResName=root:Packages:DecayModeling:ResolutionDataName
		SVAR TimeName = root:Packages:DecayModeling:OriginalTImeDataName
		SVAR ErrName=root:Packages:DecayModeling:OriginalErrorDataName
		Wave NewDtaWv=$("MEMDecayTimesDist_"+NewEnding)
		Wave NewDtaModWv=$("MEMCalcModel_"+NewEnding)
		 NewNote=""
		NewNote+= "Result of MEM fitting from:"+Date()+", "+time()+";"
		NewNote+= "Original Data Wave Name:"+DataName+";"
		if(Xscaling)
			NewNote+= "For time used Original Data Wave X-scaling"+";"
		else
			NewNote+= "Time Data Wave Name:"+TimeName+";"
		endif
		if(UseResWv)
			NewNote+= "Resolution Data Wave Name:"+ResName+";"
		else
			NewNote+= "No Resolution Data Wave used"+";"
		endif
		if(UseErrs)
			NewNote+= "Error Data Wave Name:"+ErrName+";"
		else
			NewNote+= "Used automatically created errors"+";"
		endif
		NewNote+= "Used Error multiplier:"+num2str(errMult)+";"
		NewNote+= "Achieved chi-square:"+num2str(chisq)+";"
		NewNote+= "Number of iterations:"+num2str(MEMIter)+";"
		
		if(rebin)
			NewNote+= "Data rebinned to points:"+Num2str(RebinPnts)+";"
			NewNote+= "Data rebinned with param:"+Num2str(LogBinPar)+";"
		else
			NewNote+= "Data were not rebinned"+";"		
		endif
	
	
		note NewDtaWv, NewNote
	elseif(methodToAppend==1)
		
		Wave/Z CalcDataFromModel = root:Packages:DecayModeling:Model_LSQF
		Wave/Z CalcDataFromModelXaxis=root:Packages:DecayModeling:Model_LSQFMeasTimes
		Wave/Z NormRes=root:Packages:DecayModeling:NormalizedResidual
		if(!WaveExists(CalcDataFromModel) ||!WaveExists(NormRes))
			Abort "Data do not exist, run the fitting first"
		endif
		
		setDataFolder DataFolderName
		NewDataUniqueName="LSQFDecayModel_"
		NewDataUniqueName = UniqueName(NewDataUniqueName, 1, 0 )
		 NewEnding = StringFromList(1, NewDataUniqueName , "_")
		Duplicate/O CalcDataFromModel, $("LSQFDecayModel_"+NewEnding)
		Duplicate/O CalcDataFromModelXaxis, $("LSQFDecayModelX_"+NewEnding)
		Duplicate/O NormRes, $("LSQFDecayModelNormRes_"+NewEnding)
		
		NVAR chisq=root:Packages:DecayModeling:CurrentChiSq
		NVAR LogBinPar = root:Packages:DecayModeling:LogBinParameter
		NVAR UseResWv=root:Packages:DecayModeling:UseInstr_Response_Funct
		NVAR UseErrs=root:Packages:DecayModeling:UseErrorInputDataWave
		NVAR Rebin=root:Packages:DecayModeling:RebinTheData
		NVAR RebinPnts=root:Packages:DecayModeling:numOfPoints
		NVAR Xscaling=root:Packages:DecayModeling:Use1InputDataWave
		NVAR MEMIter=root:Packages:DecayModeling:NumberIterations
		SVAR DataName=root:Packages:DecayModeling:OriginalDataName
		SVAR ResName=root:Packages:DecayModeling:ResolutionDataName
		SVAR TimeName = root:Packages:DecayModeling:OriginalTImeDataName
		SVAR ErrName=root:Packages:DecayModeling:OriginalErrorDataName
		Wave NewDtaModWv=$("LSQFDecayModel_"+NewEnding)
		 NewNote=""
		NewNote+= "Result of LSQF fitting from:"+Date()+", "+time()+";"
		NewNote+= "Original Data Wave Name:"+DataName+";"
		if(Xscaling)
			NewNote+= "For time used Original Data Wave X-scaling"+";"
		else
			NewNote+= "Time Data Wave Name:"+TimeName+";"
		endif
		if(UseResWv)
			NewNote+= "Resolution Data Wave Name:"+ResName+";"
		else
			NewNote+= "No Resolution Data Wave used"+";"
		endif
		if(UseErrs)
			NewNote+= "Error Data Wave Name:"+ErrName+";"
		else
			NewNote+= "Used automatically created errors"+";"
		endif
		NewNote+= "Achieved chi-square:"+num2str(chisq)+";"
		NewNote+= "Number of iterations:"+num2str(MEMIter)+";"
		
		if(rebin)
			NewNote+= "Data rebinned to points:"+Num2str(RebinPnts)+";"
			NewNote+= "Data rebinned with param:"+Num2str(LogBinPar)+";"
		else
			NewNote+= "Data were not rebinned"+";"		
		endif
		//now results...
		variable i
		NVAR timeOffset=root:Packages:DecayModeling:TimeOffset
		NVAR Backg=root:Packages:DecayModeling:MeasOffset
		NewNote+= "Results of modeling using LSQF part of Clemetine;"
		if(TimeOffset!=0)
			NewNote+="Time axis offset ="+num2str(timeOffset)+";"
		endif
		if(Backg!=0)
			NewNote+="measured signal offset ="+num2str(Backg)+";"
		endif
		For(i=1;i<6;i+=1)
			NVAR UseMe=$("root:Packages:DecayModeling:UseDecayTime_"+num2str(i))
			NVAR DecayTime=$("root:Packages:DecayModeling:DecayTime_"+num2str(i))
			NVAR ScaleDecayTime=$("root:Packages:DecayModeling:SFDecayTime_"+num2str(i))
			if(UseMe)
				NewNote+="Used population : "+num2str(i)+";"
				NewNote+="Decay time = "+num2str(DecayTime)+";"
				NewNote+="Scale for this Decay time = "+num2str(ScaleDecayTime)+";"	
			endif
		endfor
	
		note NewDtaModWv, NewNote
	endif
	
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
Function DECJIL_CopyAndGraphData()

				DecJIL_CopyData()
				//here the data (if exist) are in: Full_Emission_Decay_Prof,OriginalFullUserTimeData,OriginalFullUserErrorsData,OriginalFullUserResData
				DecJIL_ResetVariousCounters()		//cleanup few counters, nothing important... 
				DecJIL_ConvertResolution()		//if resolution is used convert to usable form...
				//created CenteredResolutionWv with usable resolution wave. Note, this is meaningful ONLY for data with x-scaling or equidistand spacing in time... You are warned. 
				DECJIL_RebinDataIfAppropriate() 	//if user requested, attemt to rebin data onto log scale... 

				DecJIL_SuggestFittingValues()
				DecJIL_CreateOffsetWave()
				DecJIL_PlotData()

end

//**********************************************************************************************
//**********************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function DecJIL_SuggestFittingValues()

	string OldDf
	OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:DecayModeling
	//set appropriate values as per user data here...
	
	Wave DataWv = root:Packages:DecayModeling:Rebinned_Decay_Prof
	Wave TimesWv = root:Packages:DecayModeling:Rebinned_Decay_ProfMeasTimes
	NVAR TauMin=root:Packages:DecayModeling:TauMin
	NVAR TauMax = root:Packages:DecayModeling:TauMax
	NVAR Use1InputDataWave = root:Packages:DecayModeling:Use1InputDataWave
	NVAR UseInstr_Response_Funct = root:Packages:DecayModeling:UseInstr_Response_Funct
	NVAR ScaleInputTimeBy = root:Packages:DecayModeling:ScaleInputTimeBy
	Wavestats/Q DataWv
	NVAR Bckg=root:Packages:DecayModeling:Bckg
	Bckg = DataWv[numpnts(DataWv)-1]
	NVAR MaxEntSkyBckg = root:Packages:DecayModeling:MaxEntSkyBckg
	if(UseInstr_Response_Funct)
		MaxEntSkyBckg= V_max * 1e-6
	else
		MaxEntSkyBckg= V_max * 0.001
	endif
	if(Use1InputDataWave) 
	//	FindLevel DataWv, (V_min+V_max)/2
		tauMin = 10^round(log(abs(TimesWv[0]))-1)
		tauMax = 10^round(log(TimesWv[inf]))
	else
		tauMin = 10^round(log(abs(TimesWv[0]))-1)
		tauMax = 10^round(log(TimesWv[inf]))
	endif
	
	setDataFolder OldDf
end

//**********************************************************************************************
//**********************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function DecJIL_ResetVariousCounters()	
	NVAR CurrentChiSq = root:Packages:DecayModeling:CurrentChiSq
	NVAR NumberIterations = root:Packages:DecayModeling:NumberIterations
	CurrentChiSq = nan
	NumberIterations = 0
end
//**********************************************************************************************
//**********************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function DecJIL_ConvertResolution()

	string OldDf
	OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:DecayModeling
	NVAR UseInstr_Response_Funct=UseInstr_Response_Funct
	if(UseInstr_Response_Funct)
		Wave OriginalFullUserResData = root:Packages:DecayModeling:OriginalFullUserResData		//original user resolution data
		FindLevels/Q/P OriginalFullUserResData, WaveMax(OriginalFullUserResData)/2
		Wave W_FindLevels
		variable midpoint=abs(W_FindLevels[1]+W_FindLevels[0])/2		//position of centroid of the resolution in point numbers
		variable width = abs(W_FindLevels[1]-W_FindLevels[0])			//width of the resolution in point numbers 
		variable tempWidth=round(width*3)
		variable NewResNumPoints = 2*tempWidth+1					//this is 2n+1 data points for new res wave. Need to center the res on the center here
		Make/O/N=(NewResNumPoints) CenteredResolutionWv
		//now need to set scale correctly on this new wave...
		variable centerXoldWave=pnt2x(OriginalFullUserResData, midpoint )
		variable stepXOldWave=deltax(OriginalFullUserResData)
		variable startXNewResWv = centerXoldWave - stepXOldWave*(tempWidth)		//this is start X of the new wave
		SetScale/P x startXNewResWv,stepXOldWave,"s", CenteredResolutionWv
		
		CenteredResolutionWv = OriginalFullUserResData(x)
		variable endVal=CenteredResolutionWv(inf)
		CenteredResolutionWv = (CenteredResolutionWv[p]>endVal) ? CenteredResolutionWv[p] : endVal  
	//	CenteredResolutionWv -=endVal
		variable scaleBy=sum(CenteredResolutionWv,-inf,inf)
	//	CenteredResolutionWv/=scaleBy
		//now we have appropriate resolution wave to do convolve/A with G matrix rows.
	else
//		Make/O/N=(1) CenteredResolutionWv
//		CenteredResolutionWv = 1
	endif
	setDataFolder oldDf

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function DecJIL_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

//	switch( sva.eventCode )
//		case 1: // mouse up
//		case 2: // Enter key
//		case 3: // Live update
	if(sva.eventCode==1 || sva.eventCode==2)
			Variable dval = sva.dval
			String sval = sva.sval
			if(stringmatch(sva.ctrlName,"ErrorMultiplier"))
				//Update background subtraction (offset)
				NVAR ErrMultiplier = root:Packages:DecayModeling:ErrorsMultiplier
				ErrMultiplier = dval
				Wave OrgRebinned_Decay_ProfErrors =root:Packages:DecayModeling:OrgRebinned_Decay_ProfErrors
				Wave Rebinned_Decay_ProfErrors =root:Packages:DecayModeling:Rebinned_Decay_ProfErrors
				Rebinned_Decay_ProfErrors = ErrMultiplier * OrgRebinned_Decay_ProfErrors
				SetVariable ErrorMultiplier  win=DecJIL_InputPanel,limits={0,Inf,ErrMultiplier/20}
			endif
			if(stringmatch(sva.ctrlName,"Background"))
				//Update background subtraction (offset)
				NVAR Bckg = root:Packages:DecayModeling:Bckg
				Bckg = dval
				Wave Offset =root:Packages:DecayModeling:Offset
				Offset = Bckg
				SetVariable Background,win=DecJIL_InputPanel, limits={-Inf,Inf,Bckg/10}
			endif
			if(stringmatch(sva.ctrlName,"LogBinParameter") ||  stringmatch(sva.ctrlName,"numOfPoints"))
				//NVAR ToPoints = root:Packages:DecayModeling:numOfPoints
				//NVAR removePeak = root:Packages:DecayModeling:RemovePrePeakArea
				//Wave MeasData=root:Packages:DecayModeling:Full_Emission_Decay_Prof		
				DECJIL_RebinDataIfAppropriate()
				DecJIL_CreateOffsetWave()
				//DecJIL_RebinData1(ToPoints,MeasData, removePeak)
			endif		
	endif
			
//			break
//	endswitch

	return 0
End
//**********************************************************************************************
//**********************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function DecJIL_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(stringmatch(cba.ctrlName,"DisplayLogX"))
				ModifyGraph log(bottom)=checked
			endif
			if(stringmatch(cba.ctrlName,"DisplayLogY"))
				ModifyGraph log(left)=checked
			endif
			if(stringmatch(cba.ctrlName,"UseInstr_Response_Funct"))
				NVAR UseInstr_Response_Funct = root:Packages:DecayModeling:UseInstr_Response_Funct
				PopupMenu ResolutionDataName disable=!(UseInstr_Response_Funct)
			endif		
			if(stringmatch(cba.ctrlName,"RebinTheData"))
				NVAR RebinTheData = root:Packages:DecayModeling:RebinTheData
				SetVariable numOfPoints disable=!(RebinTheData)
				SetVariable LogBinParameter disable=!(RebinTheData)
				if(RebinTheData)
					DECJIL_RebinDataIfAppropriate()
				endif
			endif		
			if(stringmatch(cba.ctrlName,"Use1InputDataWave"))
				NVAR Use1InputDataWave = root:Packages:DecayModeling:Use1InputDataWave
				PopupMenu SelectTimesDataWave disable=(Use1InputDataWave)
				PopupMenu InputTimeWaveUnit disable=(Use1InputDataWave)
			endif		
			if(stringmatch(cba.ctrlName,"UseErrorInputDataWave"))
				NVAR UseErrorInputDataWave = root:Packages:DecayModeling:UseErrorInputDataWave
				PopupMenu SelectErrorsDataWave disable=!(UseErrorInputDataWave)
			endif		
			if(stringmatch(cba.ctrlName,"FitOffset"))
				NVAR FitOffset = root:Packages:DecayModeling:FitOffset
				SetVariable Background disable=2*FitOffset
			endif		
			if(stringmatch(cba.ctrlName,"*DecayTime*") || stringmatch(cba.ctrlName,"FitTimeOffset") || stringmatch(cba.ctrlName,"FitMeasOffset"))
				STRUCT WMTabControlAction LocalStruct
				LocalStruct.eventCode=2
				LocalStruct.tab=1
				DecJIL_TabProc(LocalStruct)
			endif		

	endswitch
	return 0
End
//**********************************************************************************************
//**********************************************************************************************
//**********************************************************************************************
//**********************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function DecJIL_PlotData() : Graph
	PauseUpdate; Silent 1		// building window...

	string OldDf
	OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:DecayModeling
	Wave Full_Emission_Decay_Prof=root:Packages:DecayModeling:Full_Emission_Decay_Prof
	Wave Rebinned_Decay_Prof=root:Packages:DecayModeling:Rebinned_Decay_Prof
	Wave Rebinned_Decay_ProfMeasTimes=root:Packages:DecayModeling:Rebinned_Decay_ProfMeasTimes
	Wave Rebinned_Decay_ProfErrors=root:Packages:DecayModeling:Rebinned_Decay_ProfErrors
	Wave Offset =root:Packages:DecayModeling:Offset
	NVAR DisplayLogX = root:Packages:DecayModeling:DisplayLogX
	NVAR DisplayLogY = root:Packages:DecayModeling:DisplayLogY
	NVAR CurrentChiSq = root:Packages:DecayModeling:CurrentChiSq
	NVAR TargetChiSquared = root:Packages:DecayModeling:TargetChiSquared
	NVAR NumberIterations = root:Packages:DecayModeling:NumberIterations
	Wave/Z OriginalFullUserTimeData=root:Packages:DecayModeling:OriginalFullUserTimeData

	DoWindow DecJIL_UserInputGraph
	if(V_Flag)
		DoWindow/K DecJIL_UserInputGraph
	endif
	NVAR Use1InputDataWave=root:Packages:DecayModeling:Use1InputDataWave
	if(Use1InputDataWave)
		Display /K=1/W=(369,44,1100,550) Full_Emission_Decay_Prof
	else
		Display /K=1/W=(369,44,1100,550) Full_Emission_Decay_Prof vs OriginalFullUserTimeData
	endif
	DoWindow/C DecJIL_UserInputGraph
	//***
	ControlBar /T/W=DecJIL_UserInputGraph 40
	CheckBox DisplayLogX,pos={10,5},size={141,14},proc=DecJIL_CheckProc,title="Display log X axis?"
	CheckBox DisplayLogX,variable= root:Packages:DecayModeling:DisplayLogX, help={"Display X axis as log axis?"}
	CheckBox DisplayLogY,pos={10,20},size={141,14},proc=DecJIL_CheckProc,title="Display log Y axis?"
	CheckBox DisplayLogY,variable= root:Packages:DecayModeling:DisplayLogY, help={"Display Y axis as log axis?"}
	SetVariable CurrentChiSq, pos={210,5}, size={150,14}, variable=root:Packages:DecayModeling:CurrentChiSq, disable=2, title="Current chi-squared "
	SetVariable TargetChiSquared, pos={210,20}, size={150,14}, variable=root:Packages:DecayModeling:TargetChiSquared, disable=2, title="Target chi-squared "

	SetVariable NumberIterations, pos={420,5}, size={150,14}, variable=root:Packages:DecayModeling:NumberIterations, disable=2, title="Current iteration "
	SetVariable MEMFindPeakPar, pos={420,20}, size={200,14}, variable=root:Packages:DecayModeling:MEMFindPeakPar,  title="MEM Peak find par [% height] "

	//***
	AppendToGraph Rebinned_Decay_Prof vs Rebinned_Decay_ProfMeasTimes
	AppendToGraph Offset vs Rebinned_Decay_ProfMeasTimes
	ModifyGraph lstyle(Offset)=4,rgb(Offset)=(52428,1,41942)
	ModifyGraph mode(Rebinned_Decay_Prof)=3
	ModifyGraph marker(Rebinned_Decay_Prof)=26
	ModifyGraph rgb(Rebinned_Decay_Prof)=(0,0,0)
	ModifyGraph log(bottom)=1
	Label left "Signal"
	Label bottom "Time"
	ErrorBars Rebinned_Decay_Prof Y,wave=(root:Packages:DecayModeling:Rebinned_Decay_ProfErrors,root:Packages:DecayModeling:Rebinned_Decay_ProfErrors)
	Legend/C/N=text0/J/F=0/A=MC/X=-36.74/Y=-39.88 "\\s(Full_Emission_Decay_Prof) Full_Emission_Decay_Prof\r\\s(Rebinned_Decay_Prof) Rebinned_Decay_Prof"

	setAxis bottom, Rebinned_Decay_ProfMeasTimes[0], Rebinned_Decay_ProfMeasTimes[numpnts(Rebinned_Decay_ProfMeasTimes)-1]
	showinfo
	ModifyGraph log(left)= DisplayLogY
	ModifyGraph log(bottom) = DisplayLogX
	wavestats/Q  Rebinned_Decay_Prof
	Cursor /P /W=DecJIL_UserInputGraph A  Rebinned_Decay_Prof  x2pnt(Rebinned_Decay_Prof, V_maxLoc )
	Cursor /P /W=DecJIL_UserInputGraph B  Rebinned_Decay_Prof  (numpnts(Rebinned_Decay_ProfMeasTimes)-1) 
	SetDataFolder OldDf
	AutoPositionWindow/M=0 /R=DecJIL_InputPanel  DecJIL_UserInputGraph
	
EndMacro
//**********************************************************************************************
//**********************************************************************************************
//**********************************************************************************************
//**********************************************************************************************
Function DecJIL_CreateOffsetWave()

	string OldDf
	OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:DecayModeling
	Wave Rebinned_Decay_Prof=root:Packages:DecayModeling:Rebinned_Decay_Prof
	Wave Rebinned_Decay_ProfMeasTimes=root:Packages:DecayModeling:Rebinned_Decay_ProfMeasTimes
	Duplicate /O Rebinned_Decay_Prof, Offset
	NVAR Bckg = root:Packages:DecayModeling:Bckg
	Offset = Bckg
	SetDataFolder OldDf
	
EndMacro
//**********************************************************************************************
//**********************************************************************************************
//**********************************************************************************************
//**********************************************************************************************

Function/T DecJIL_CreateListOfItemsFldr(df,item)			//Generates list of items in given folder
	String df
	variable item										//1-directories, 2-waves, 4 - variables, 8- strings
	
	String dfSave
	dfSave=GetDataFolder(1)
	string MyList=""
	
	if (DataFolderExists(df))
		SetDataFolder $df
		MyList= RemoveListItem(0, DataFolderDir(item) , ":")
		SetDataFolder $dfSave
	else
		MyList=""
	endif
	MyList = ReplaceString(",", MyList, ";" )
	return MyList
end
//**********************************************************************************************
//**********************************************************************************************
//**********************************************************************************************
//**********************************************************************************************


Function/S DecJIL_FindFolderWithWaveTypes(startDF, levels, WaveTypes, LongShortType)
        String startDF, WaveTypes                  // startDF requires trailing colon.
        Variable levels, LongShortType		//set 1 for long type and 0 for short type return
        			 
        String dfSave
        String list = "", templist, tempWvName
        variable i, skipRest
        
        dfSave = GetDataFolder(1)
  	
  	if (!DataFolderExists(startDF))
  		return ""
  	endif
  	
        SetDataFolder startDF
        
        templist = DataFolderDir(0)
        skipRest=0
 	//first treat the empty folders... 
 	if(strlen(WaveList("*",";",""))==0 && cmpstr(WaveTypes,"*")==0)
 		if (LongShortType)
	            		list += startDF + ";"
				skipRest=1
	      	else
     		      		list += GetDataFolder(0) + ";"
      				skipRest=1
      		endif	
 	endif
 	//and notw the non-empty folders...
	  For(i=0;i<ItemsInList(WaveList("*",";",""));i+=1)
		tempWvName = StringFromList(i, WaveList("*",";","") ,";")
	 //   	 if (Stringmatch(WaveList("*",";",""),WaveTypes))
		if(skipRest)
			//nothing needs to be done
		else
		    	 if (Stringmatch(tempWvName,WaveTypes))
				if (LongShortType)
			            		list += startDF + ";"
						skipRest=1
			      	else
		     		      		list += GetDataFolder(0) + ";"
	      					skipRest=1
		      		endif
	        	endif
	        endif
        endfor
 
 
        levels -= 1
        if (levels <= 0)
                return list
        endif
        
        String subDF
        Variable index = 0
        do
                String temp
                temp = PossiblyQuoteName(GetIndexedObjName(startDF, 4, index))     	// Name of next data folder.
                if (strlen(temp) == 0)
                        break                                                                           			// No more data folders.
                endif
     	              subDF = startDF + temp + ":"
            		 list += DecJIL_FindFolderWithWaveTypes(subDF, levels, WaveTypes, LongShortType)       	// Recurse.
                index += 1
        while(1)
        
        SetDataFolder(dfSave)
        return list
End
//**********************************************************************************************
//**********************************************************************************************
//*****************************************************************************************************************
Function DecJIL_CopyData()
	
	SVAR DtaFldr=root:Packages:DecayModeling:DataFolderName
	SVAR DataWvName=root:Packages:DecayModeling:OriginalDataName
	SVAR DataResWvName=root:Packages:DecayModeling:ResolutionDataName
	SVAR OriginalTImeDataName = root:Packages:DecayModeling:OriginalTImeDataName
	SVAR OriginalErrorDataName = root:Packages:DecayModeling:OriginalErrorDataName
	NVAR UseInstr_Response_Funct=root:Packages:DecayModeling:UseInstr_Response_Funct
	NVAR Use1InputDataWave = root:Packages:DecayModeling:Use1InputDataWave
	NVAR UseErrorInputDataWave = root:Packages:DecayModeling:UseErrorInputDataWave
	
	string OldDf
	OldDf=GetDataFolder(1)
	variable wasErrorWhileCopying = 0
	SetDataFolder root:Packages:DecayModeling
	Wave/Z DataWv=$(DtaFldr+DataWvName)
	Wave/Z resWv=$(DtaFldr+DataResWvName)
	Wave/Z TimeWv=$(DtaFldr+OriginalTImeDataName)
	Wave/Z ErrorsWv=$(DtaFldr+OriginalErrorDataName)
	IF(WAVEEXISTS(DataWv))			//copy data, this has to be done always...
		Duplicate/O DataWv, Full_Emission_Decay_Prof
	else
		wasErrorWhileCopying=1
	endif
		
	if(!Use1InputDataWave)			//here copy x-axis (times) for data (if exists)
		IF(WAVEEXISTS(TimeWv))
			NVAR ScaleInputTimeBy = root:Packages:DecayModeling:ScaleInputTimeBy
			Duplicate/O TimeWv, OriginalFullUserTimeData
			OriginalFullUserTimeData *=ScaleInputTimeBy
		else
			wasErrorWhileCopying=1
		endif
	else
		KIllwaves/Z OriginalFullUserTimeData
	endif


	if(UseErrorInputDataWave)			//here copy errors for data (if exists)
		IF(WAVEEXISTS(ErrorsWv))
			Duplicate/O ErrorsWv, OriginalFullUserErrorsData
		else
			wasErrorWhileCopying=1
		endif
	else
		KIllwaves/Z OriginalFullUserErrorsData
	endif


	if(UseInstr_Response_Funct)				//and here resolution wave, if it exists... This will be tough to do if user provides times wave - likely makes no sense... 
		IF(WAVEEXISTS(resWv))
			Duplicate/O resWv, OriginalFullUserResData
		else
			wasErrorWhileCopying=1
		endif
	else
		KIllwaves/Z OriginalFullUserResData
	endif
	
	setDataFolder OldDf
end
////**********************************************************************************************
////**********************************************************************************************
////*****************************************************************************************************************
//Function DecJIL_GraphData()
//	
//	SVAR DtaFldr=root:Packages:DecayModeling:DataFolderName
//	SVAR DataWvName=root:Packages:DecayModeling:OriginalDataName
//	SVAR DataResWvName=root:Packages:DecayModeling:ResolutionDataName
//	
//	string OldDf
//	OldDf=GetDataFolder(1)
//	SetDataFolder root:Packages:DecayModeling
//	Wave/Z DataWv=$(DtaFldr+DataWvName)
//	Wave/Z resWv=$(DtaFldr+DataResWvName)
//
//
//
//
//	setDataFolder OldDf
//end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function DecJIL_Initialize()			//dialog for radius wave creation, simple linear binning now.

	string OldDf
	OldDf=GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:DecayModeling
	
	//initializes the Maximum lentropy part of Sizes
	
	string ListOfVariables
	string ListOfStrings
	variable i

	ListOfVariables="Chisquare;SuggestedSkyBackground;RemovePrePeakArea;TauSteps;"
	ListOfVariables+="MaxEntSkyBckg;MaxEntRegular;MaximumNumIter;numOfPoints;TauMin;TauMax;Bckg;"
	ListOfVariables+="CurrentEntropy;CurrentChiSq;CurChiSqMinusAlphaEntropy;BinWidthInGMatrix;GraphLogTopAxis;GraphLogRightAxis;"
	ListOfVariables+="ErrorsMultiplier;MaxEntStabilityParam;NumberIterations;UseInstr_Response_Funct;"	
	ListOfVariables+="DisplayLogX;DisplayLogY;TargetChiSquared;LogBinParameter;"	
	ListOfVariables+="Use1InputDataWave;UseErrorInputDataWave;RebinTheData;FitOffset;"	
	ListOfVariables+="ScaleInputTimeBy;MEMFindPeakPar;ResetTime0;"	
	
	//controls for fitting...
	ListOfVariables+="NumberOfDecays;AutoUpdate;"
	ListOfVariables+="TimeOffset;FitTimeOffset;LLTimeOffset;ULTimeOffset;"
	ListOfVariables+="MeasOffset;FitMeasOffset;LLMeasOffset;ULMeasOffset;"
	ListOfVariables+="UseDecayTime_1;DecayTime_1;FitDecayTime_1;LLDecayTime_1;ULDecayTime_1;"
	ListOfVariables+="UseDecayTime_2;DecayTime_2;FitDecayTime_2;LLDecayTime_2;ULDecayTime_2;"
	ListOfVariables+="UseDecayTime_3;DecayTime_3;FitDecayTime_3;LLDecayTime_3;ULDecayTime_3;"
	ListOfVariables+="UseDecayTime_4;DecayTime_4;FitDecayTime_4;LLDecayTime_4;ULDecayTime_4;"
	ListOfVariables+="UseDecayTime_5;DecayTime_5;FitDecayTime_5;LLDecayTime_5;ULDecayTime_5;"

	ListOfVariables+="SFDecayTime_1;FitSFDecayTime_1;LLSFDecayTime_1;ULSFDecayTime_1;"
	ListOfVariables+="SFDecayTime_2;FitSFDecayTime_2;LLSFDecayTime_2;ULSFDecayTime_2;"
	ListOfVariables+="SFDecayTime_3;FitSFDecayTime_3;LLSFDecayTime_3;ULSFDecayTime_3;"
	ListOfVariables+="SFDecayTime_4;FitSFDecayTime_4;LLSFDecayTime_4;ULSFDecayTime_4;"
	ListOfVariables+="SFDecayTime_5;FitSFDecayTime_5;LLSFDecayTime_5;ULSFDecayTime_5;"
	ListOfVariables+="SFDecayTime_6;FitSFDecayTime_6;LLSFDecayTime_6;ULSFDecayTime_6;"
	
	ListOfStrings="DataFolderName;OriginalDataName;ResolutionDataName;OriginalTImeDataName;OriginalErrorDataName;"
	
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		DecJIL_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		DecJIL_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor		
	NVAR GraphLogTopAxis=root:Packages:DecayModeling:GraphLogTopAxis
	GraphLogTopAxis=1
	
	SVAR DataFolderName
	SVAR OriginalDataName
	SVAR ResolutionDataName
	DataFolderName="---"
	OriginalDataName="---"
	ResolutionDataName="---"
	NVAR UseInstr_Response_Funct
	UseInstr_Response_Funct=0
//	NVAR UseUserErrors
//	NVAR UseSQRTErrors
//	NVAR UsePercentErrors
//	NVAR PercentErrorToUse
//	NVAR UseNoErrors
//	
//	if(UseUserErrors+UseSQRTErrors+UsePercentErrors+UseNoErrors!=1)
//		UseUserErrors=1
//		UseSQRTErrors=0
//		UsePercentErrors=0
//		UseNoErrors=0
//	endif
//	if(PercentErrorToUse==0)
//		PercentErrorToUse = 5
//	endif
//
	
	NVAR SuggestedSkyBackground=root:Packages:DecayModeling:SuggestedSkyBackground
	if(SuggestedSkyBackground==0)
		SuggestedSkyBackground=1e-6
	endif
	NVAR MEMFindPeakPar=root:Packages:DecayModeling:MEMFindPeakPar
	if(MEMFindPeakPar==0)
		MEMFindPeakPar=5
	endif

	NVAR MaxEntStabilityParam=root:Packages:DecayModeling:MaxEntStabilityParam
	if (MaxEntStabilityParam==0)
		MaxEntStabilityParam=0.01
	endif
	NVAR LogBinParameter=root:Packages:DecayModeling:LogBinParameter
	if (LogBinParameter==0)
		LogBinParameter=5
	endif
	NVAR ScaleInputTimeBy=root:Packages:DecayModeling:ScaleInputTimeBy
	if (ScaleInputTimeBy==0)
		ScaleInputTimeBy=1
	endif
	NVAR MaxEntSkyBckg=root:Packages:DecayModeling:MaxEntSkyBckg
	if (MaxEntSkyBckg==0)
		MaxEntSkyBckg=1e-6
	endif
	NVAR MaximumNumIter=root:Packages:DecayModeling:MaximumNumIter
	if (MaximumNumIter==0)
		MaximumNumIter=100
	endif
	NVAR numOfPoints=root:Packages:DecayModeling:numOfPoints
	if (numOfPoints==0)
		numOfPoints=100
	endif
	NVAR TauMin=root:Packages:DecayModeling:TauMin
	if (TauMin==0)
		TauMin=1e-9
	endif
	NVAR TauMax=root:Packages:DecayModeling:TauMax
	if (TauMax==0)
		TauMax=1e-7
	endif	
	NVAR Bckg=root:Packages:DecayModeling:Bckg
	if (Bckg==0)
		Bckg=0
	endif
	NVAR TauSteps=root:Packages:DecayModeling:TauSteps
	if (TauSteps==0)
		TauSteps=200
	endif
	NVAR DisplayLogX=root:Packages:DecayModeling:DisplayLogX
	if (DisplayLogX==0)
		DisplayLogX=0
	endif

	NVAR ErrorsMultiplier =root:Packages:DecayModeling:ErrorsMultiplier
	if (ErrorsMultiplier==0)
		ErrorsMultiplier=1
	endif
	NVAR BinWidthInGMatrix=root:Packages:DecayModeling:BinWidthInGMatrix
	BinWidthInGMatrix=0		//this is right setting, will default to this one...
	
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//**********************************************************************************************
//**********************************************************************************************
Function DecJIL_CreateItem(TheSwitch,NewName)
	string TheSwitch, NewName
//this function creates strings or variables with the name passed
	if (cmpstr(TheSwitch,"string")==0)
		SVAR/Z test=$NewName
		if (!SVAR_Exists(test))
			string/g $NewName
			SVAR testS=$NewName
			testS=""
		endif
	endif
	if (cmpstr(TheSwitch,"variable")==0)
		NVAR/Z testNum=$NewName
		if (!NVAR_Exists(testNum))
			variable/g $NewName
			NVAR testV=$NewName
			testV=0
		endif
	endif
end
//**********************************************************************************************
//**********************************************************************************************
