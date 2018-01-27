#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.18

//	This procedure does desmearing using Lake method


//**********************************
//**********************************This routine desmears data using Lake method****************************
//**********************************************************************************************************

Function IN2D_DesmearSlowMain()

	IN2G_UniversalFolderScan("root:USAXS:", 5, "IN2G_CheckTheFolderName()")  //here we fix the folder names/sample names in wave notes if necessary
	
	
		IN2A_CleanupAllWIndows()						//cleanup all open windows from Indra 2
		IN2D_SelectDesmearData()				//this function selects data folder
		IN2D_GetDesmearParameters(0)			//here we get rest of desmear parameters, go to Packages:DesmearWorkFolder
		IN2D_TrimTheData()						//calls next routine to trim the data		
			PauseForUser TrimGraph				//wait for end of trim procedure
		IN2D_CheckTheBackgroundExtns()			//here we check background extension
			PauseForUser CheckGraph1			//wait to finish
		IN2D_CheckIfNoProblemExtrap()			//check if we do not have problems extrapolating...
		IN2D_DoDesmearingSteps()				//here we do desmearing step by step
			PauseForUser SmearingProcess		//wait for user to finish stepwise desmearing
		IN2D_FinishDesmearing()					//end the desmearing with creating output waves and final plot
end



Function  IN2D_CheckIfNoProblemExtrap()		//check if we do not have problems extrapolating...
		NVAR ExtrapolationFunctionProblem	
		if (ExtrapolationFunctionProblem)
			abort
		endif
end



//*******Part 1/6********************************************************************************************
Function IN2D_SelectDesmearData()			//This procedure just sets folder where are the data
	
	string df
	Prompt df, "Select folder with data to desmear", popup, IN2D_NextDSMDataToDo()+";"+IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, "*SMR_Int", 1)
	DoPrompt "Desmearing folder selection", df
	if (V_Flag)
		Abort 
	endif	
			
	SetDataFolder df
	SVAR CurrentDSM=root:Packages:DesmearWorkFolder:CurrentDSMFolder
	CurrentDSM = df
	IN2G_AppendAnyText("Desmearing procedure started for  :"+ df)

end
 
 Function/T IN2D_NextDSMDataToDo()					//this returns next Folder in order to evaluate 

	string ListOfData=IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, "*SMR_Int", 1)	
	SVAR/Z LastDSM=root:Packages:DesmearWorkFolder:CurrentDSMFolder	//global string for current folder info
	if (!SVAR_Exists(LastDSM))
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:DesmearWorkFolder
		string/g root:packages:DesmearWorkFolder:CurrentDSMFolder		//create if nesessary
		SVAR LastDSM=root:Packages:DesmearWorkFolder:CurrentDSMFolder
		LastDSM=""
	endif
	variable start=FindListItem(LastDSM, ListOfData)
	if (start==-1)
		return StringFromList(0,ListOfdata)
	else
		ListOfdata=ListOfData[start,inf]
		return StringFromList(1,ListOfdata)
	endif
end

 //******Part 2/6********************************
Function IN2D_GetDesmearParameters(QuickSLow)		//***************input IntwaveL,QwaveL,EwaveL,SelectedFunction,LslitLength,QminToE
	variable QuickSlow		//if 1 then running Quick method, if two running slow method
	
	if (!DataFolderExists("root:Packages:DesmearWorkFolder:"))
		NewDataFolder root:Packages:DesmearWorkFolder		//create Desmear folder, if it does not exist
	endif

	SVAR MeasurementParameters
	SVAR/Z DesmearParameters
	if (!SVAR_Exists(DesmearParameters))
		string/g DesmearParameters=""
		SVAR DesmearParameters
	endif
	SVAR/Z DesmearParametersW=root:Packages:DesmearWorkFolder:DesmearParametersW
	if (!SVAR_Exists(DesmearParametersW))
		string/g root:Packages:DesmearWorkFolder:DesmearParametersW=""
		SVAR DesmearParametersW=root:Packages:DesmearWorkFolder:DesmearParametersW
	endif	
	
	variable QminToE=numberByKey("QToStartExtrap",DesmearParametersW,"=")
	variable LslitLength=NumberByKey("SlitLength", MeasurementParameters,"=")
	variable iterations=numberByKey("MaxIterations",DesmearParametersW,"=")
	string SelectedFunction=stringByKey("BckgFunction",DesmearParametersW,"=")
	if (strlen(SelectedFunction)<1)		//no function selected yet
		SelectedFunction="flat"
	endif
	if (numtype(QminToE)==2)			//no Q min selected yet
		QminToE = 0.1
	endif
	if (iterations<1)					//no iterations selected yet
		iterations = 1
	endif
		

	string IntwaveL, QwaveL, EwaveL

	Prompt IntwaveL, "Which wave contains Intensity to desmear?", popup, IN2D_FindSMRwave("SMR_Int")+";"+WaveList("*", ";", "")
	Prompt LslitLength, "Check Slit Length:"
	Prompt QwaveL, "Which wave contains Q data?", popup, IN2D_FindSMRwave("SMR_Qvec")+";"+WaveList("*", ";", "")
	Prompt SelectedFunction, "What function use for background extrapolation?", popup, SelectedFunction+";flat;linear;power law;Porod;PowerLaw w flat;polynom2;polynom3"		//
	Prompt EwaveL, "Which wave contains errors?", popup, IN2D_FindSMRwave("SMR_Error")+";"+WaveList("*", ";", "")	//StrVarOrDefault("SelectedFunction","flat")
	Prompt QminToE, "At which Q start with background extrapolation?"
	Prompt iterations, "How many iterations? (set only if running fast desmear)"
	
	if (QuickSlow==1)		//running fast method
		DoPrompt "Select parameters for desmearing", IntwaveL, QwaveL, EwaveL, LslitLength, SelectedFunction, QminToE, iterations
	else			//running slow method
		DoPrompt "Select parameters for desmearing", IntwaveL, QwaveL, EwaveL, LslitLength	
	endif
	
	
	if (V_flag)
		Abort 
	endif
	//here we record the name of the Intensity wave name so we can figure out later on what was input
	DesmearParameters=ReplaceStringByKey("IntensityWvNm",DesmearParameters,IntwaveL,"=")
	DesmearParameters=ReplaceStringByKey("QvectorWvNm",DesmearParameters,QwaveL,"=")
	DesmearParameters=ReplaceStringByKey("ErrorWvNm",DesmearParameters,EwaveL,"=")
	
	string dFsaveL=GetDataFolder(1)				//get the forlder where we are
	IntwaveL=dFsaveL+IntwaveL				//create proper pointers to the data we want ot desmear 
	QwaveL=dFsaveL+QwaveL
	EwaveL=dFsaveL+EwaveL

	DesmearParameters=ReplaceStringByKey("Intensity",DesmearParameters,IntwaveL,"=")
	DesmearParameters=ReplaceStringByKey("Qvector",DesmearParameters,QwaveL,"=")
	DesmearParameters=ReplaceStringByKey("Error",DesmearParameters,EwaveL,"=")
	DesmearParameters=ReplaceStringByKey("DataSource",DesmearParameters,dFsaveL,"=")
	DesmearParameters=ReplaceStringByKey("SlitLength",DesmearParameters,num2str(LslitLength),"=")
	DesmearParameters=ReplaceStringByKey("MaxIterations",DesmearParameters,num2str(iterations),"=")
	DesmearParameters=ReplaceStringByKey("QToStartExtrap",DesmearParameters,num2str(QminToE),"=")
	DesmearParameters=ReplaceStringByKey("BckgFunction",DesmearParameters,SelectedFunction,"=")
	
	setDataFolder root:Packages:DesmearWorkFolder:					//Go to desmear folder

	IN2G_AppendAnyText("List of desmearing parameters used :\r"+DesmearParameters)

	DesmearParametersW=DesmearParameters
end

Function/T IN2D_FindSMRwave(str)
	string str
	
	string str1=WaveList("M_"+str+"*",";","")
	string str2=WaveList(str+"*",";","")

	if (strlen(str1)>0)
		return str1+";"+str2
	else
		return str2
	endif
end

//******Part 3/6********************************
Function IN2D_TrimTheData()							//this function trims the data before desmearing.
	
	SVAR DesmearParametersW
	string IntwaveL, QwaveL, EwaveL 
	IntwaveL=stringByKey("Intensity",DesmearParametersW,"=")
	QwaveL= stringByKey("Qvector",DesmearParametersW,"=")
	EwaveL=stringByKey("Error",DesmearParametersW,"=")
	Wave Intensity = $IntwaveL
	Wave Qvector = $QwaveL
	Wave Error = $EwaveL 
	
	Duplicate/O Intensity, OrgIntwave
	Duplicate/O Qvector, OrgQwave
	Duplicate/O Error, OrgEwave
	
	IN2G_ReplaceNegValsByNaNWaves(OrgIntWave,OrgQwave,OrgEwave)		//here we remove negative values by setting them to NaNs
	IN2G_RemoveNaNsFrom3Waves(OrgIntWave,OrgQwave,OrgEwave)			//and here we remove NaNs all together

	PauseUpdate; Silent 1		// building window...
	Display/K=1 /W=(0.3*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("heigth"),60*IN2G_ScreenWidthHeight("width"),70*IN2G_ScreenWidthHeight("height")) OrgIntwave vs OrgQwave as "Trim the data"
	DoWindow/C TrimGraph 
	ModifyGraph mode=4,margin(top)=100, mirror=1, minor=1
	showinfo												//shows info
	ShowTools/A											//show tools
	cursor/P A, OrgIntwave, (BinarySearch(OrgQwave, 0.00015)+1)
	cursor/P B, OrgIntwave, (numpnts(OrgIntwave)-1)
	ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
	Button KillThisWindow pos={10,10}, size={100,25}, title="Kill window", proc=IN2G_KillGraphsTablesEnd
	Button ResetWindow pos={10,40}, size={100,25}, title="Reset window", proc=IN2G_ResetGraph
	ModifyGraph mode=3
	ModifyGraph log=1
	Label left "Intensity"
	Label bottom "Q vector"
	Button button0 , pos={140, 10}, proc=IN2D_Trim,title="Trim"
	Button button0 size={100,25}
	Button button1 , pos={140, 40}, proc=IN2G_KillTopGraph,title="Continue"
	Button button1 size={100,25}
	Button RemovePointDSM pos={0,100}, size={140,20}, title="Remove pnt w/csrA", proc=IN2G_RemovePointWithCursorA
	ResumeUpdate
	ModifyGraph width=0, height=0
end	

Function IN2D_Trim(ctrlName) : ButtonControl
	String ctrlName
	
	if (strlen(CsrWave(B))==0 || strlen(CsrWave(A))==0)
		DoAlert 0, "One of the cursors is not in the graph. Position both cursors and select the area which you want to desmear in the graph first before triming."
	else
		variable AP=pcsr (A)
		variable BP=pcsr (B)
		deletePoints 0, AP, OrgIntwave, OrgQwave, OrgEwave
		variable newLength=numpnts(OrgIntwave)
		deletePoints (BP-AP+1), (newLength), OrgIntwave, OrgQwave, OrgEwave
		cursor/P A, OrgIntwave, 0
		cursor/P B, OrgIntwave, (numpnts(OrgIntwave)-1)
	endif
End

//******Part 4/6********************************
Function IN2D_CheckTheBackgroundExtns()

	Wave OrgIntwave
	Wave OrgQwave
	Wave OrgEwave
	SVAR DesmearParametersW
	
	IN2G_ReplaceNegValsByNaNWaves(OrgIntWave,OrgQwave,OrgEwave)		//here we remove negative values by setting them to NaNs
	IN2G_RemoveNaNsFrom3Waves(OrgIntWave,OrgQwave,OrgEwave)			//and here we remove NaNs all together

	Variable/G SlitLength=numberByKey("Slitlength", DesmearParametersW, "=")
	Variable/G BckgStartQ=numberByKey("QToStartExtrap", DesmearParametersW, "=")
	String/G BackgroundFunction=stringByKey("BckgFunction", DesmearParametersW, "=")
	
	Duplicate/O OrgIntwave, BlaIntwave, ColorWave
	Duplicate/O OrgQwave, BlaQwave
	Duplicate/O OrgEwave, BlaErrWave
	ColorWave=0				//make the colors to be one, this will change later...
	variable/G numOfPoints=numpnts(OrgQwave)
	
	PauseUpdate; Silent 1		// building window...
	Display/K=1 /W=(0.3*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("heigth"),60*IN2G_ScreenWidthHeight("width"),70*IN2G_ScreenWidthHeight("height")) BlaIntwave vs BlaQwave as "Check bckg functions sel."
	DoWindow/C CheckGraph1 
	ModifyGraph mode=4,	margin(top)=100, mirror=1, minor=1
	ModifyGraph zColor(BlaIntwave)={ColorWave,0,2,Rainbow}
	showinfo												//shows info
	ShowTools/A											//show tools
	ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
	Button KillThisWindow pos={10,10}, size={100,25}, title="Kill window", proc=IN2G_KillGraphsTablesEnd
	Button ResetWindow pos={10,40}, size={100,25}, title="Reset window", proc=IN2G_ResetGraph
	ModifyGraph mode=3
	ModifyGraph log=1
	Label left "Intensity"
	Label bottom "Q vector"
	ShowTools
	SetVariable BackgroundStart,pos={10,80},size={300,18},proc=IN2D_RecalcBkg,title="Start Bckg extrapolation at Q:   "
	SetVariable BackgroundStart,limits={0,100,0},noedit=1,value= root:Packages:DesmearWorkFolder:BckgStartQ
	PopupMenu BackgroundFnct,pos={140,50},size={178,21},proc=IN2D_ChangeBkgFunction,title="background function :   "
	PopupMenu BackgroundFnct,mode=1,value= "flat;linear;PowerLaw w flat;power law;Porod;polynom2;polynom3",popvalue=BackgroundFunction
	Button button0 , pos={140, 10}, proc=IN2D_ContinueDesmear,title="Continue"
	Button button0 size={100,25}
	Button RemovePointDSM pos={0,100}, size={140,20}, title="Remove pnt w/csrA", proc=IN2G_RemovePointWithCursorA
	ResumeUpdate
	ModifyGraph width=0, height=0

	IN2D_SetCsrAToExtendData()				//position cursor
	redimension /N=(numofPoints) BlaIntwave, BlaQwave, BlaErrWave
	IN2D_ExtendData(BlaIntwave, BlaQwave, BlaErrWave, SlitLength, BckgStartQ, BackgroundFunction,0) 	//extend data to 2xnumOfPoints to Qmax+2.1xSlitLength

end	

Function IN2D_ContinueDesmear(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K CheckGraph1
	KillWaves/Z BlaIntwave, BlaQwave
End

//*****************************************************

Function IN2D_CursorMoved()
	
	SVAR info=root:Packages:DesmearWorkFolder:CsrMoveInfo
	String oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:DesmearWorkFolder:

	Variable isB = cmpstr(StringByKey("CURSOR",info), "A")
	
	if (isB==0)
		String tName= StringByKey("TNAME", info)
		if( strlen(tName) )	// cursor still on
			//Result needs to be passed to the rest of the procedures
			//but before we need to check that the cursor has not moved on last 5 points
			Wave w= TraceNameToWaveRef("CheckGraph1", tName)
			Wave BlaIntWave
			Variable pointNum= NumberByKey("POINT",info)
			NVAR Wlength=root:Packages:DesmearWorkFolder:numOfPoints
			NVAR BckgStart=root:Packages:DesmearWorkFolder:BckgStartQ
			
			variable CurentBckgStart=hcsr(A)
			if (cmpstr(TNAME,"BlaIntwave")!=0)			//cursor is not on right wave
				Cursor /P /W=CheckGraph1 A BlaIntwave BinarySearch(BlaIntWave, CurentBckgStart )
			endif
			
			pointNum = pcsr(A)		//update the cursor position
			
			if (pointNum>Wlength-6)			//cursor is not at least 5 points from end move further
				Cursor /P /W=CheckGraph1 A BlaIntwave (Wlength-6)
			endif		

			BckgStart = hcsr(A)
		
			IN2D_RecalcBackgroundExt()
		endif
	endif	
	SetDataFolder oldDf
End

Function IN2D_SetCsrAToExtendData()

	Wave BlaQwave=root:Packages:DesmearWorkFolder:BlaQwave
	NVAR Wlength=root:Packages:DesmearWorkFolder:numOfPoints
	NVAR BckgStart=root:Packages:DesmearWorkFolder:BckgStartQ

	if (BckgStart<BlaQwave[Wlength-6])
		Cursor /P /W=CheckGraph1 A BlaIntwave BinarySearch(BlaQwave,BckgStart)
	else
		Cursor /P /W=CheckGraph1 A BlaIntwave (Wlength-10)
		BckgStart=BlaQwave(Wlength-10)
	endif		


end
//**********************************************************
Function IN2D_RecalcBackgroundExt()

	WAVE BlaIntwave
	WAVE BlaQwave
	WAVE BlaErrWave
	NVAR SlitLength
	NVAR BckgStartQ
	SVAR BackgroundFunction
	NVAR numOfPoints
	
	Redimension/N=(numOfPoints) BlaIntwave, BlaQwave, BlaErrWave
	IN2D_ExtendData(BlaIntwave, BlaQwave, BlaErrWave, SlitLength, BckgStartQ, BackgroundFunction,0)

End


Function IN2D_RecalcBkg (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable

	WAVE BlaIntwave
	WAVE BlaQwave
	WAVE BlaErrWave
	NVAR SlitLength
	NVAR BckgStartQ
	SVAR BackgroundFunction
	NVAR numOfPoints
	
	Redimension/N=(numOfPoints) BlaIntwave, BlaQwave, BlaErrWave
	IN2D_ExtendData(BlaIntwave, BlaQwave, BlaErrWave, SlitLength, BckgStartQ, BackgroundFunction,0)

End


Function IN2D_ChangeBkgFunction(ctrlname, popNum, popStr)  : PopupMenuControl 	
	string ctrlName
	variable popNum
	string popStr
	
	SVAR BackgroundFunction=BackgroundFunction
	BackgroundFunction=popStr
	WAVE BlaIntwave=BlaIntwave
	WAVE BlaQwave=BlaQwave
	Wave BlaErrWave=BlaErrWave
	NVAR BckgStartQ=BckgStartQ
	NVAR numOfPoints=numOfPoints
	NVAR SlitLength=SlitLength
	SVAR DesmearParametersW
	
	DesmearParametersW=ReplaceStringByKey("BckgFunction",DesmearParametersW,BackgroundFunction,"=")
	
	Redimension/N=(numOfPoints) BlaIntwave, BlaQwave, BlaErrWave
	IN2D_ExtendData(BlaIntwave, BlaQwave, BlaErrWave, SlitLength, BckgStartQ, BackgroundFunction,0)
end

//******Part 5/6********************************

Function IN2D_DoDesmearingSteps()
	// this is continuation of dismearing procedure1, Here we return after trimming the data and checking the background extrapolation
	
	Wave OrgIntWave
	Wave OrgQwave
	Wave OrgEwave
	Wave fit_BlaIntWave
	Wave ColorWave

	SVAR DesmearParametersW
	NVAR BckgStartQ
	
	DesmearParametersW=ReplaceStringByKey("QToStartExtrap",DesmearParametersW,num2str(BckgStartQ),"=")

	IN2G_RemoveNaNsFrom3Waves(OrgIntWave,OrgQwave,OrgEwave)					//remove NaNs from remove point with cursor
	
	Duplicate/O OrgIntwave, FitIntensity, SmFitIntensity, NormalizedError, UpErr, DownErr		//creates new waves to work on
	Duplicate/O OrgQwave, Qvector
	Duplicate/O OrgEwave, SmErrors, DsmError	

	UpErr=1
	DownErr=-1
	NormalizedError=0
	
	variable/G NumOfIterationsIs=0 
				
	string UserSampleName=StringByKey("UserSampleName", note(OrgIntWave) , "=", ";")
	SVAR BackgroundFunction=root:Packages:DesmearWorkFolder:BackgroundFunction	
			
			//***************graph
				PauseUpdate
				Display/K=1 /W=(0.3*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("heigth"),60*IN2G_ScreenWidthHeight("width"),70*IN2G_ScreenWidthHeight("height")) OrgIntWave vs OrgQwave as "Intensity vs Q plot"
				DoWindow/C SmearingProcess
				ModifyGraph mode=4,	margin(top)=100, mirror=1, minor=1
				showinfo										//shows info
				ShowTools/A										//show tools
				ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
				Button KillThisWindow pos={10,10}, size={100,25}, title="Kill window", proc=IN2G_KillGraphsTablesEnd
				Button ResetWindow pos={10,40}, size={100,25}, title="Reset window", proc=IN2G_ResetGraph
				AppendToGraph FitIntensity vs Qvector
				AppendToGraph fit_BlaIntWave
				ModifyGraph mode=3,rgb(OrgIntWave)=(0,8704,13056)
				ModifyGraph log=1
				Label left "Intensity"
				Label bottom "Q vector"	
				AppendToGraph /R NormalizedError vs Qvector 
				ModifyGraph mode=3,marker(NormalizedError)=8,mrkThick(NormalizedError)=0.1;
				AppendToGraph /R UpErr vs Qvector 
				AppendToGraph /R DownErr vs Qvector 
				ModifyGraph lstyle(UpErr)=3,rgb(UpErr)=(0,0,0),lstyle(DownErr)=3
				ModifyGraph rgb(DownErr)=(0,0,0)
				ModifyGraph rgb(NormalizedError)=(0,0,0)
				ModifyGraph zero(right)=3
				SetAxis/A/E=2 right
				ModifyGraph mode(fit_BlaIntwave)=0,lstyle(fit_BlaIntwave)=3
				ModifyGraph rgb(fit_BlaIntwave)=(0,15872,65280)
				ModifyGraph lsize(fit_BlaIntwave)=2
				ModifyGraph zColor(FitIntensity)={ColorWave,0,2,Rainbow}
//				string bucketXX=stringByKey("comment", note(OrgIntwave))
				Legend/N=text0/J/F=0/A=LB/B=1 "\\s(OrgIntWave) Smeared data\r\\s(FitIntensity) Current desmeared fit"
				AppendText "\\s(NormalizedError) Standardized residual\r"
				AppendText "User sample name:  "+UserSampleName
				AppendText "Used extrapolation function:  "+BackgroundFunction
				AppendText "Extrapolation starts at Q =  "+num2str(BckgStartQ)
				Button button1 , pos={140, 40}, proc=IN2D_DesmearIterations,title="Do one iteration"
				Button button1 size={100,25}
				Button button3 , pos={140, 70}, proc=IN2D_DesmearIterations,title="Do 5 iterations"
				Button button3 size={100,25}
				SetVariable setvar0 size={180,20},title="Number of iterations:", pos={140, 10}
				SetVariable setvar0 limits={-Inf,Inf,0},value= NumOfIterationsIs, noedit=1
				Button button2 , pos={10, 70}, proc=IN2G_KillTopGraph,title="Continue"
				Button button2 size={100,25}

				ResumeUpdate
				ModifyGraph width=0, height=0		
				//***************graph end	
end

Function IN2D_ContinueDesmearBtn(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K SmearingProcess
	
	Execute("IN2D_DersmearContinues2()")			//Lets give user chance to see his background selection - and change it
End

Function IN2D_DesmearIterations(ctrlName) : ButtonControl
	String ctrlName

	variable i, tickStart
	tickStart=ticks
	if (cmpstr(ctrlName,"Button1")==0)
		IN2D_OneDesmearIteration()
	endif
	
	if (cmpstr(ctrlName,"Button3")==0)
		For (i=0;i<5;i+=1)
			IN2D_OneDesmearIteration()
		endfor
	endif
	if ((ticks-TickStart)/60 > 5)			//thsi is going to beep for longer desemaring steps, set now to 5 sec per step
		beep
	endif

end

Function IN2D_OneDesmearIteration()
	String ctrlName
	
	SVAR BackgroundFunction=BackgroundFunction
//	SVAR Intwave=Intwave
	NVAR slitLength=slitLength
	NVAR BckgStartQ=BckgStartQ
	NVAR numOfPoints=numOfPoints
	WAVE FitIntensity=FitIntensity
	WAVE Qvector=Qvector
	WAVE OrgIntwave=OrgIntwave
	Wave BlaErrWave=BlaErrWave
	WAVE SmFitIntensity=SmFitIntensity
	WAVE NormalizedError=NormalizedError
	WAVE SmErrors=SmErrors
	NVAR NumOfIterationsIs=NumOfIterationsIs
	SVAR DesmearParametersW

	//	numOfPoints=numpnts(FitIntensity)
	
		IN2D_ExtendData(FitIntensity, Qvector, BlaErrWave, slitLength, BckgStartQ, BackgroundFunction,1) 			//extend data to 2xnumOfPoints to Qmax+2.1xSlitLength
		IN2D_SmearData(FitIntensity, Qvector, slitLength, SmFitIntensity)						//smear the data, output is SmFitIntensity
		Redimension/N=(numOfPoints) SmFitIntensity, FitIntensity, Qvector, NormalizedError		//cut the data back to original length (Qmax, numOfPoints)
	
		FitIntensity*=OrgIntwave/SmFitIntensity								//Here we apply the correction on input data, FitIntensity is our best estimate for desmeared data
		NormalizedError=(OrgIntwave-SmFitIntensity)/SmErrors			//NormalizedError (input-my Smeared data)/input errors
		
	NumOfIterationsIs+=1
	
	DesmearParametersW=ReplaceStringByKey("MaxIterations",DesmearParametersW,num2str(NumOfIterationsIs),"=")
End


//******Part 6/6********************************
	
Function IN2D_FinishDesmearing()
	
	SVAR DesmearParametersW
	Wave SMErrors
	Wave OrgIntWave
	Wave FitIntensity
	Wave DSMError
	Wave Qvector
	NVAR NumOfIterationsIs
	
	IN2D_GetErrors(SmErrors, OrgIntwave, FitIntensity, DsmError, Qvector)			//this routine gets the errors
	
	DesmearParametersW=ReplaceStringByKey("MaxIterations",DesmearParametersW,num2str(NumOfIterationsIs),"=")

	string Intwave=stringByKey("Intensity", DesmearParametersW, "=")
	string Outwave
	if (stringmatch(Intwave,"*SMR_Int"))											//create output waves and put data in them
		if (stringmatch(Intwave,"*M_SMR_Int"))
			Outwave=RemoveFromList("M_SMR_Int", Intwave, ":")+"M_DSM_Int"
		else
			Outwave=RemoveFromList("SMR_Int", Intwave, ":")+"DSM_Int"
		endif
	else
		Outwave=Intwave+"_DSM"
	endif

	string Qwave=stringByKey("Qvector", DesmearParametersW, "=")	
	string OutQwave
	if (stringmatch(Qwave,"*SMR_Qvec"))
		if (stringmatch(Qwave,"*M_SMR_Qvec"))
			OutQwave=RemoveFromList("M_SMR_Qvec", Qwave, ":")+"M_DSM_Qvec"
		else
			OutQwave=RemoveFromList("SMR_Qvec", Qwave, ":")+"DSM_Qvec"
		endif
	else
		OutQwave=Qwave+"_DSM"
	endif

	string Ewave=stringByKey("Error", DesmearParametersW, "=")
	string OutError
	if (stringmatch(Ewave,"*SMR_Error"))
		if (stringmatch(Ewave,"*M_SMR_Error"))
			OutError=RemoveFromList("M_SMR_Error", Ewave, ":")+"M_DSM_Error"
		else
			OutError=RemoveFromList("SMR_Error", Ewave, ":")+"DSM_Error"
		endif
	else
		OutError=Ewave+"_DSM"
	endif
	
	string SampleName=StringByKey("COMMENT",note(FitIntensity),"=")
	string SourceSpecFile=StringByKey("DATAFILE",note(FitIntensity),"=")

	Duplicate/O FitIntensity, $Outwave	
	Duplicate/O Qvector, $OutQwave
	Duplicate/O DsmError, $OutError
	
	IN2G_AppendorReplaceWaveNote(Outwave,"Wname",stringFromList(itemsInList(Outwave,":")-1,Outwave,":") )
	IN2G_AppendorReplaceWaveNote(OutQwave,"Wname",stringFromList(itemsInList(OutQwave,":")-1,OutQwave,":") )
	IN2G_AppendorReplaceWaveNote(OutError,"Wname",stringFromList(itemsInList(OutError,":")-1,OutError,":")) 

	
	IN2G_AppendorReplaceWaveNote(Outwave,"Desmeared","Yes")						
	IN2G_AppendorReplaceWaveNote(Outwave,"DSM_steps",stringByKey("MaxIterations",DesmearParametersW,"="))						
	IN2G_AppendorReplaceWaveNote(Outwave,"DSM_QExtrapStart",stringByKey("QToStartExtrap",DesmearParametersW,"="))						
	IN2G_AppendorReplaceWaveNote(Outwave,"DSM_ExtrapFunction",stringByKey("BckgFunction",DesmearParametersW,"="))						
	IN2G_AppendorReplaceWaveNote(OutQwave,"Desmeared","Yes")						
	IN2G_AppendorReplaceWaveNote(OutQwave,"DSM_steps",stringByKey("MaxIterations",DesmearParametersW,"="))						
	IN2G_AppendorReplaceWaveNote(OutQwave,"DSM_QExtrapStart",stringByKey("QToStartExtrap",DesmearParametersW,"="))						
	IN2G_AppendorReplaceWaveNote(OutQwave,"DSM_ExtrapFunction",stringByKey("BckgFunction",DesmearParametersW,"="))						
	IN2G_AppendorReplaceWaveNote(OutError,"Desmeared","Yes")						
	IN2G_AppendorReplaceWaveNote(OutError,"DSM_steps",stringByKey("MaxIterations",DesmearParametersW,"="))						
	IN2G_AppendorReplaceWaveNote(OutError,"DSM_QExtrapStart",stringByKey("QToStartExtrap",DesmearParametersW,"="))						
	IN2G_AppendorReplaceWaveNote(OutError,"DSM_ExtrapFunction",stringByKey("BckgFunction",DesmearParametersW,"="))						
	
	IN2G_AppendAnyText("Finished with following parameters :\r"+DesmearParametersW)
	
	KillWaves/Z FitIntensity, Qvector, DsmError, SmFitIntensity, Correction, SmErrors, NormalizedError	//cleanup after the process
	
	//*************** another graph with output
	PauseUpdate
	Display/K=1 /W=(0.3*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("heigth"),60*IN2G_ScreenWidthHeight("width"),70*IN2G_ScreenWidthHeight("height")) $Intwave vs $Qwave as "Intensity vs Q plot"
	DoWindow/C FinalDesmeared
	AppendToGraph $Outwave vs $OutQwave
	ModifyGraph mode=4,margin(top)=100, mirror=1, minor=1
	string bucketXX1=stringFromList((ItemsInList(Intwave,":")-1),Intwave, ":")
	string bucketXX2=stringFromList((ItemsInList(Outwave,":")-1),Outwave, ":")
	Legend/N=text0/J/F=0/A=LB "\\s("+bucketXX1+") Input data\r\\s("+bucketXX2+") Desmeared  data"
	Legend/N=text1/J/F=0/A=RT "Sample name is:  "+SampleName +"\r from Spec data file:  "+ SourceSpecFile
	ErrorBars $bucketXX2 Y,wave=($OutError,$OutError)
	ErrorBars $bucketXX1 Y,wave=($Ewave,$Ewave)
	showinfo												//shows info
	ShowTools/A											//show tools
	ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
	ModifyGraph marker($bucketXX2)=19,rgb($bucketXX2)=(0,0,0)
	Button KillThisWindow pos={10,10}, size={100,25}, title="Kill window", proc=IN2G_KillGraphsTablesEnd
	Button ResetWindow pos={10,40}, size={100,25}, title="Reset window", proc=IN2G_ResetGraph
	Button StartAgain pos={150,40}, size={100,25}, title="Start again", proc=IN2D_StartAgain
	Button SaveData pos={150,10}, size={100,25}, title="Export DSM", proc=IN2D_ExportDSM
	ModifyGraph mode=3, msize=2
	ModifyGraph log=1
	Label left "Intensity"
	Label bottom "Q vector"	
	ModifyGraph width=0, height=0
	ResumeUpdate
	
	setDataFolder $stringByKey("DataSource", DesmearParametersW, "=")
end
	
Function IN2D_ExportDSM(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR DesmearParametersW=root:Packages:DesmearWorkFolder:DesmearParametersW
	string Intwave=stringByKey("IntensityWvNm", DesmearParametersW, "=")
	string Qwave=stringByKey("QvectorWvNm", DesmearParametersW, "=")
	string Ewave=stringByKey("ErrorWvNm", DesmearParametersW, "=")
	string Outwave
	if (stringmatch(Intwave,"*SMR_Int"))											//create output waves and put data in them
		if (stringmatch(Intwave,"*M_SMR_Int"))
			IN2G_WriteSetOfData("M_DSM")
		else
			IN2G_WriteSetOfData("DSM")
		endif
	else
		IN2D_WriteSetOfData(Intwave,Qwave,Ewave)
	endif

End

Function IN2D_StartAgain(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K FinalDesmeared
	
	IN2D_DesmearSlowMain()
End


//******Common procedures********************************
	
//**********************************Calculates error estimates******************
Function IN2D_GetErrors(SmErrors, SmIntensity, FitIntensity, DsmErrors, Qvector)		//calculates errors using Petes formulas
	wave SmErrors, SmIntensity, FitIntensity, DsmErrors, Qvector
	
	Silent 1	
	
	DsmErrors=FitIntensity*(SmErrors/SmIntensity)						//error proportional to input data
	WAVE W_coef=W_coef
	variable i=1, imax=numpnts(SmErrors)
	
	Do
		CurveFit/Q line, FitIntensity (i-1, i+1) /X=Qvector				//linear function here 
		DsmErrors[i]+=abs(W_coef[0]+W_coef[1]*Qvector[i] - FitIntensity[i])	//error due to scatter of data
	i+=1
	while (i<imax-1)

	DsmErrors[0]=DsmErrors[1]									//some error needed for 1st point
	DsmErrors[imax]=DsmErrors[imax-1]								//and error for last point	

	Smooth /E=2 3, DsmErrors
	
end



//*************************************Extends the data using user specified parameters***************
Function IN2D_ExtendData(Int_wave, Q_vct, Err_wave, slitLength, Qstart, SelectedFunction, RecordFitParam) 
	wave Int_wave, Q_vct, Err_wave
	variable slitLength, Qstart, RecordFitParam		//RecordFitParam=1 when we should record fit parameters in logbook
	string SelectedFunction
	

	WAVE ColorWave=ColorWave
	WAVE/Z W_coef=W_coef
		if (WaveExists(W_coef)!=1)					
			make/N=2 W_coef
		endif
	W_coef=0		//reset for recording purposes...
	
	string ProblemsWithQ=""
	string ProblemWithFit=""
	string ProblemsWithInt=""
	variable DataLengths=numpnts(Q_vct)-1							//get number of original data points
	variable Qstep=((Q_vct(DataLengths)/Q_vct(DataLengths-1))-1)*Q_vct(DataLengths)
	variable ExtendByQ=sqrt(Q_vct(DataLengths)^2 + (1.5*slitLength)^2) - Q_vct(DataLengths)
	if (ExtendByQ<2.1*Qstep)
		ExtendByQ=2.1*Qstep
	endif
	variable NumNewPoints=floor(ExtendByQ/Qstep)	
	if (NumNewPoints<1)
		NumNewPoints=1
	endif	
	variable newLength=numpnts(Q_vct)+NumNewPoints				//New length of waves
	variable FitFrom=binarySearch(Q_vct, Qstart)					//get at which point of Q start fitting for extension
	if (FitFrom<=0)		                 								//error in selection of Q fitting range
		FitFrom=DataLengths-10
		ProblemsWithQ="I did reset Fitting Q range for you..."
	endif
	//There seems to be bug, which prevents me from using /D in FuncFit and cursor control
	//therefore we will have to now handle this ourselves...
	//FIrst check if the wave exists
	Wave/Z fit_BlaIntwave
	if (!WaveExists(fit_BlaIntwave))
		Make/O/N=200 fit_BlaIntwave
	endif
	//Now we need to set it's x scaling to the range of Q values we need to study
	SetScale/I x Q_vct[FitFrom],Q_vct[DataLengths-1],"", fit_BlaIntwave
	//reset the fit wave to constant value
	fit_BlaIntwave=Int_wave[DataLengths-1]
		
	Redimension /N=(newLength) Int_wave, Q_vct, Err_wave			//increase length of the two waves
	
	if(exists("ColorWave")==1)
		Redimension /N=(newLength) ColorWave
		ColorWave=0
		ColorWave[FitFrom,DataLengths-1]=1
		ColorWave[DataLengths+1, ]=2	
	endif
	
	variable i=0, ii=0	
	variable/g V_FitError=0					//this is way to avoid bombing due to numerical problems
	variable/g V_FitOptions=4				//this should suppress the window showing progress (4) & force robust fitting (6)
										//using robust fitting caused problems, do not use...
//	variable/g V_FitTol=0.00001				//and this should force better fit
	variable/g V_FitMaxIters=50
//	variable/g V_FitNumIters
	
	DoWindow CheckGraph1
	if (V_flag)
		RemoveFromGraph /W=CheckGraph1 /Z Fit_BlaIntwave
	endif
	//***********here start different ways to extend the data

	if (cmpstr(SelectedFunction,"flat")==0)				//flat background, for some reason only way this works is 
	//lets setup parameters for FuncFit
		if (exists("W_coef")!=1)					//using my own function to fit. Crazy!!
			make/N=2 W_coef
		endif
		Redimension/D/N=1 W_coef
		Make/O/N=1 E_wave
		E_wave[0]=1e-6
		W_coef[0]=Int_wave[((FitFrom+DataLengths)/2)]			//here is starting guesses
		K0=W_coef[0]										//another way to get starting guess in
	 	V_FitError=0											//this is way to avoid bombing due to numerical problems
		//now lets do the fitting
		FuncFit/N/Q IN2D_FlatFnct W_coef Int_wave [FitFrom, DataLengths-1] /I=1 /W=Err_Wave /E=E_Wave /X=Q_vct	//Here we get the fit to the Int_wave in
		//now check for the convergence
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Linear fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]								//extend Int
			EndFor
			fit_BlaIntwave=W_coef[0]
		endif
	endif


	if (cmpstr(SelectedFunction,"power law")==0)			//power law background
	 	V_FitError=0					//this is way to avoid bombing due to numerical problems
		//now lets do the fitting	
		K0 = 0;
		CurveFit/N/Q/H="100" Power Int_wave[FitFrom, DataLengths-1] /X=Q_vct /W=Err_Wave /I=1 
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Power law fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]= W_coef[1]*(Q_vct[DataLengths+i])^W_coef[2]			//extend Int
			endfor
			fit_BlaIntwave=W_coef[1]*(x)^W_coef[2]
		endif
	endif


	if (cmpstr(SelectedFunction,"Porod")==0)				//Porod background
		if (exists("W_coef")!=1)
			make/N=2 W_coef
		endif
		Redimension/D/N=2 W_coef
		variable estimate1_w0=Int_wave[(DataLengths-1)]
		variable estimate1_w1=Q_vct[(FitFrom)]^4*Int_wave[(FitFrom)]
		W_coef={estimate1_w0,estimate1_w1}							//here are starting guesses, may need to be fixed.
		K0=estimate1_w0
		K1=estimate1_w1
	 	V_FitError=0					//this is way to avoid bombing due to numerical problems
		//now lets do the fitting	
		FuncFit/N/Q IN2D_Porod W_coef Int_wave [FitFrom, DataLengths-1] /I=1 /W=Err_Wave /X=Q_vct			//Porod function here
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Porod fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]=W_coef[0]+W_coef[1]/(Q_vct[DataLengths+i])^4		//extend Int
			endfor
			fit_BlaIntwave=W_coef[0]+W_coef[1]/(x)^4
		endif
	endif


	if (cmpstr(SelectedFunction,"linear")==0)					//fit line
		CurveFit/N/Q line Int_wave [FitFrom, DataLengths-1] /I=1 /W=Err_Wave /X=Q_vct		//linear function here
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Linear fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)^2	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]+W_coef[1]*Q_vct[DataLengths+i]			//extend Int
			endfor
			fit_BlaIntwave=W_coef[0]+W_coef[1]*x	
		endif
	endif

	if (cmpstr(SelectedFunction,"polynom2")==0)				//fit polynom 2st degree
		CurveFit/N/Q poly 3, Int_wave [FitFrom, DataLengths-1] /I=1 /W=Err_Wave /X=Q_vct		//polynom 2st degree function here
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Polynomic fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]+W_coef[1]*Q_vct[DataLengths+i]+W_coef[2]*(Q_vct[DataLengths+i])^2
			endfor
			fit_BlaIntwave=W_coef[0]+W_coef[1]*x+W_coef[2]*(x)^2
		endif
	endif


	if (cmpstr(SelectedFunction,"polynom3")==0)				//fit polynom 3rd degree
		CurveFit/N/Q poly 4, Int_wave [FitFrom, DataLengths-1] /I=1 /W=Err_Wave /X=Q_vct			//polynom 3rd degree function here
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Plolynomic fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]+W_coef[1]*Q_vct[DataLengths+i]+W_coef[2]*(Q_vct[DataLengths+i])^2+W_coef[3]*(Q_vct[DataLengths+i])^3
			endFor
			fit_BlaIntwave=W_coef[0]+W_coef[1]*x+W_coef[2]*(x)^2+W_coef[3]*(x)^3
		endif
	endif
	

	if (cmpstr(SelectedFunction,"PowerLaw w flat")==0)				//fit polynom 3rd degree
		if (exists("W_coef")!=1)
			make/N=3 W_coef
		endif
		Make/O/T CTextWave={"K1 > 0"," K2 < 0","K0 > 0", "K2 > -6"}
		Redimension/D/N=3 W_coef
	 	V_FitError=0					//this is way to avoid bombing due to numerical problems
			Curvefit/N/Q power Int_wave [FitFrom, DataLengths-1] /I=1 /C=CTextWave/X=Q_vct /W=Err_Wave		
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Power Law with flat fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]+W_coef[1]*(Q_vct[DataLengths+i]^W_coef[2])
			endfor
			fit_BlaIntwave=W_coef[0]+W_coef[1]*(x^W_coef[2])
			endif
		endif

		wavestats/Q Int_wave
		if (V_min<0)
			ProblemsWithInt="Extrapolated Intensity <0, select different function" 
		endif

	string ErrorMessages=""
	if (strlen(ProblemsWithQ)!=0)
		ErrorMessages=ProblemsWithQ+"\r"
	endif
	if (strlen(ProblemsWithInt)!=0)
		ErrorMessages=ProblemsWithInt+"\r"
	endif
	if (strlen(ProblemWithFit)!=0)
		ErrorMessages+=ProblemWithFit
	endif
	
	Variable/G ExtrapolationFunctionProblem
	NVAR ExtrapolationFunctionProblem
	ExtrapolationFunctionProblem=0
	
	DoWindow CheckGraph1
	if (V_flag)
		AppendToGraph /W=CheckGraph1 fit_BlaIntwave
		ModifyGraph /W=CheckGraph1 /Z rgb(fit_BlaIntwave)=(0,0,65280), lstyle(fit_BlaIntwave)=3

		//Error messages
		//First remove the old one
		if (stringMatch(WinRecreation("",0),"*/N=ErrorMessageTextBox*"))
			TextBox/W=CheckGraph1/K/N=ErrorMessageTextBox
		endif
		if (strlen(ErrorMessages)!=0)
			TextBox/W=CheckGraph1/C/N=ErrorMessageTextBox/B=(65280,32512,16384)/D=3/A=RT "\\Z09"+ErrorMessages
			ExtrapolationFunctionProblem=1
		endif
	endif

	DoWindow CheckGraph1
	if (!V_flag)
		If (strlen(ErrorMessages)!=0)
			DoAlert 0,  ErrorMessages
		endif
	endif
	Wave/Z W_sigma
	
	//Now recording results, if asked for
	if (RecordFitParam)
		NVAR NumOfIterationsIs=NumOfIterationsIs
		IN2G_AppendAnyText("Record of extension fitting from desmearing iteration "+num2str(NumOfIterationsIs+1))
		IN2G_AppendAnyText("Used function: "+SelectedFunction)
		variable NumOfParam=numpnts(W_coef)
		For(i=0;i<NumOfParam;i+=1)
			if (WaveExists(W_sigma))
				IN2G_AppendAnyText("Parameter "+num2str(i+1)+" = "+num2str(W_coef[i])+"  +/-  "+num2str(W_sigma[i]))
			else
				IN2G_AppendAnyText("Parameter "+num2str(i+1)+" = "+num2str(W_coef[i]))
			endif
		endfor
	endif
end 
//****************************************************
Function IN2D_PowerLaw(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = w_0*x^w_1
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = w_0
	//CurveFitDialog/ w[1] = w_1

	return w[0]*x^w[1]
End

Function IN2D_Porod(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = c1+c2*(x^(-4))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = c1
	//CurveFitDialog/ w[1] = c2

	return w[0]+w[1]*(x^(-4))
End

Function IN2D_FlatFnct(w,x) : FitFunc
	wave w
	variable x
	
	return w[0]
end


Function IN2D_FreePorod(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = c1+c2*(x^pwr)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = c1
	//CurveFitDialog/ w[1] = c2
	//CurveFitDialog/ w[2] = pwr

	return w[0]+w[1]/(x^w[2])
End

//*****************************This function smears data***********************
Function IN2D_SmearData(Int_to_smear, Q_vec_sm, slitLength, Smeared_int)
	wave Int_to_smear, Q_vec_sm, Smeared_int
	variable slitLength
	
	Make/D/O/N=(0.5*numpnts(Q_vec_sm)) Smear_Q, Smear_Int							
		//Q's in L spacing and intensitites in the l's will go to Smear_Int (intensity distribution in the slit, changes for each point)

	variable DataLengths=numpnts(Q_vec_sm)
	
	Smear_Q=1.1*slitLength*(Q_vec_sm[2*p]-Q_vec_sm[0])/(Q_vec_sm[DataLengths-1]-Q_vec_sm[0])		//create distribution of points in the l's which mimics the aroginal distribution of pointsd
	//the 1.1* added later, because without it I di dno  cover the whole slit length range... 
	variable i=0
	
	For(i=0;i<DataLengths;i+=1) 
		Smear_Int=interp(sqrt((Q_vec_sm[i])^2+(Smear_Q[p])^2), Q_vec_sm, Int_to_smear)		//put the distribution of intensities in the slit for each point 
		Smeared_int[i]=areaXY(Smear_Q, Smear_Int, 0, slitLength) 							//integrate the intensity over the slit 
	endfor

	Smeared_int*= 1 / slitLength															//normalize
	
	KillWaves Smear_Int, Smear_Q														//cleanup temp waves
end
//**************End common******************************




//**************************************************FAST now******************
//*****************************************************************************
//*****************************************************************************
//*****************************************************************************




//**********************This routine desmears data FAST using Lake method. Skips few steps

Function IN2D_DesmearFastMain()

	IN2G_UniversalFolderScan("root:USAXS:", 5, "IN2G_CheckTheFolderName()")  //here we fix the folder names/sample names in wave notes if necessary
	
		IN2D_SelectDesmearData()				//this function selects data folder
		IN2D_GetDesmearParameters(1)			//here we get rest of desmear parameters, go to Packages:DesmearWorkFolder
		IN2D_TrimTheData()						//calls next routine to trim the data		
			PauseForUser TrimGraph				//wait for end of trim procedure
//these parts from "slow" procedure are skipped
//		IN2D_CheckTheBackgroundExtns()			//here we check background extension
//			PauseForUser CheckGraph1			//wait to finish
//		IN2D_DoDesmearingSteps()				//here we do desmearing step by step
//			PauseForUser SmearingProcess		//wait for user to finish stepwise desmearing

		IN2D_DoAllDesmearSteps()				//here we do all desmear steps together
		IN2D_FinishDesmearing()					//end the desmearing with creating output waves and final plot
end
 

Function IN2D_DoAllDesmearSteps()						//this does all desmear steps at once
	
	Wave OrgIntWave
	Wave OrgQwave
	Wave OrgEwave
	
	IN2G_RemoveNaNsFrom3Waves(OrgIntWave,OrgQwave,OrgEwave)			//remove NaNs caused by remove points
	
	Duplicate/O OrgIntwave, FitIntensity, SmFitIntensity, NormalizedError, UpErr, DownErr		//creates new waves to work on
	Duplicate/O OrgQwave, Qvector
	Duplicate/O OrgEwave, SmErrors, DsmError	

	UpErr=1
	DownErr=-1
	NormalizedError=0
	
	SVAR DesmearParametersW
	variable MaxIter=NumberByKey("MaxIterations", DesmearParametersW,"=")
	variable i=0
	variable/G NumOfIterationsIs=0 
	
	For (i=0;i<MaxIter;i+=1)
		IN2D_OneDesmearIteration()
		NumOfIterationsIs+=1
	endfor	

end

Function IN2D_StartAgainFast(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K FinalDesmeared
	KillWaves/Z FitIntensity, Qvector, DsmErrors, SmFitIntensity, Correction, SmErrors, NormalizedError	//cleanup after the process

	
	Execute("IN2D_DesmearDataFast()")
End

//*************************END FAST*******************************************************
//****************************************************************************************
//****************************************************************************************
//*****************************************************************************************


Function IN2D_WriteSetOfData(whichInt,whichQ,whichErr)		//this procedure saves selected data from current folder
	string whichInt,whichQ,whichErr
	
	PathInfo ExportDatapath
	NewPath/C/O/M="Select folder for exported data..." ExportDatapath
		if (V_flag!=0)
			abort
		endif
	
	string IncludeData="yes"
	
	Prompt IncludeData, "Evaluation and Description data include within file or separate?", popup, "within;separate"
	DoPrompt "Export Data dialog", IncludeData
	if (V_flag)
		abort
	endif

	
	string filename=IN2G_FixTheFileName2()
	if (cmpstr(IgorInfo(2),"P")>0) 										// for Windows this cmpstr (IgorInfo(2)...)=1
		filename=filename[0,30]										//30 letter should be more than enough...
	else																//running on Mac, need shorter name
		filename=filename[0,20]										//lets see if 20 letters will not cause problems...
	endif	
	filename=IN2G_GetUniqueFileName(filename)
	if (cmpstr(filename,"noname")==0)
		return 1
	endif
	string filename1
	Make/T/O WaveNoteWave 
	
	Wave DSM_QvecL=$(whichQ+"_DSM")
	Wave DSM_IntL=$(whichInt+"_DSM")
	Wave DSM_ErrorL=$(whichErr+"_DSM")
	
//	Proc ExportDSMWaves()
		filename1 = filename+".dsm"
			Duplicate/O DSM_QvecL, Exp_Qvec
			Duplicate/O DSM_IntL, Exp_Int
			Duplicate/O DSM_ErrorL, Exp_Error
			IN2G_TrimExportWaves(Exp_Qvec,Exp_Int, Exp_Error)
			
			IN2G_PasteWnoteToWave("Exp_Int", WaveNoteWave,"#   ")
		if (cmpstr(IncludeData,"within")==0)
			Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave,Exp_Qvec,Exp_Int, Exp_Error as filename1
		else
			Save/I/G/M="\r\n"/P=ExportDatapath Exp_Qvec,Exp_Int, Exp_Error as filename1				///P=Datapath			
			filename1 = filename1[0, strlen(filename1)-5]+"_dsm.txt"											//here we include description of the 
			Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1		//samples with this name
		endif		
	
//	KillWaves/Z WaveNoteWave, Exp_Qvec, Exp_Int, Exp_Error
end
