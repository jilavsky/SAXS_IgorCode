#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.15
Constant IR2PrversionNumber=1.13

//*************************************************************************\
//* Copyright (c) 2005 - 2021, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.15 combined together with IR2Pr_Regularization.ipf

//1.13 added better graph size controls for screen size using IN2G_GetGraphWidthHeight
//1.13  removed unused functions
//1.12 added getHelp button calling to www manual
//1.11 changed to IR1B_SmearData which is more optimized slit smearing function. 
//1.10 fixes for WIndows GUI
//1.09 changes for panel scaling
//1.08 fixed bug of useSMR data which screwed up Control Procedures
//1.07 removed wave/d, Function/d and variable/d. Obsolete
//1.06 minor cahnge for notebook call function. 
//1.05 added panel version control and made panel vertically scrollable
//1.04  Modified all controls not to define font and font size to enable proper control by user 
//1.03 added graph with Gamma(r) per request
//1.02 added license for ANL

// notes from IR2Pr_Regularization.ipf
//1.03 Igor 7 required change - remobed use of MatrixLUBkSub and changed to MatrixLinearSolve, MatrixLUBkSub is deprecated. 
//1.02 contains GNOM-type output


//need to check these files are included... Just to make sure we can make this self standing, if necessary


//JIL, August 19, 2008 original developemnt GUI
//version 1.01 includes GNOM-type file output.


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2Pr_MainPDDF()

	IN2G_CheckScreenSize("height",670)

	IR2Pr_InitializePDDF()
	
	DoWindow IR2Pr_ControlPanel
	if(V_Flag)
		DoWIndow /K IR2Pr_ControlPanel
	endif
	Execute("IR2Pr_ControlPanel()")
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("IR2Pr_ControlPanel", IR2PrversionNumber,1)


end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2Pr_MainCheckVersion()	
	DoWindow IR2Pr_ControlPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR2Pr_ControlPanel", IR2PrversionNumber))
			DoAlert /T="The Pair distance dist. panel was created by incorrect version of Irena " 1, "Pair distance dist. may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				IR2Pr_MainPDDF()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR2Pr_InitializePDDF()					//this may be OK now... 
			endif
		endif
	endif
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2Pr_InitializePDDF()

	DFref oldDf= GetDataFolderDFR()

	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:Irena_PDDF

	
	string/g ListOfVariables
	string/g ListOfStrings

	ListOfVariables="UseIndra2Data;UseQRSdata;UseSMRData;SlitLength;UseRegularization;UseMoore;"
	ListOfVariables+="MaximumR;NumberOfBins;Background;ErrorMultiplier;NumberIterations;Evalue;"
	ListOfVariables+="UseUserErrors;UseSQRTErrors;UsePercentErrors;PercentErrorsValue;"
	ListOfVariables+="GraphLogTopAxis;GraphLogRightAxis;StartFitQvalue;EndFitQvalue;CurrentChiSq;CurChiSqMinusAlphaEntropy;"
	ListOfVariables+="FittedNumberOfpoints;Chisquare;"
	ListOfVariables+="Moore_NumOfFncts;Moore_DetNumFncts;Moore_FitBckg;Moore_HoldMaxSize;"

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	ListOfStrings+="MethodRun;"
	
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	NVAR Evalue
	Evalue=0.01	
	
	NVAR Moore_NumOfFncts
	NVAR Moore_DetNumFncts
	NVAR Moore_FitBckg
	NVAR Moore_HoldMaxSize
	if(Moore_NumOfFncts==0)
		Moore_NumOfFncts=20
	endif
	NVAR UseRegularization
	NVAR useMoore
	if(useMoore + useRegularization !=1)
		useRegularization=1
		useMoore = 0
	endif
	NVAR MaximumR
	if(MaximumR<=0)
		MaximumR=101
	endif
	NVAR NumberOfBins
	if(NumberOfBins<10)
		NumberOfBins=101
	endif
	NVAR ErrorMultiplier
	if(ErrorMultiplier<=0)
		ErrorMultiplier=1
	endif
	NVAR UseUserErrors
	NVAR UseSQRTErrors
	NVAR UsePercentErrors
	NVAR PercentErrorsValue
	if(PercentErrorsValue<=0)
		PercentErrorsValue=5
	endif
	If(UseUserErrors+UseSQRTErrors+UsePercentErrors!=1)
		UseUserErrors =1
		UseSQRTErrors=0
		UsePercentErrors=0
	endif
	setDataFolder OldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Window IR2Pr_ControlPanel() 
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(2.25,43.25,390,690) as "Pair Distnce Dist function panel"

	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("Irena_PDDF","IR2Pr_ControlPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,0)

	root:Packages:Irena_PDDF:DataFolderName = "---"
	root:Packages:Irena_PDDF:IntensityWaveName = "---"
	root:Packages:Irena_PDDF:QWaveName = "---"
	root:Packages:Irena_PDDF:ErrorWaveName = "---"

	TitleBox MainTitle title="\Zr170Pair Distance Dist Fnct input panel",pos={20,0},frame=0,fstyle=3, size={350,24},anchor=MC,fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,181},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info1 title="\Zr140Data input",pos={10,30},frame=0,fstyle=1, fixedSize=0,size={80,20},fColor=(0,0,52224)
	TitleBox Info2 title="\Zr140Model input",pos={10,188},frame=0,fstyle=1, fixedSize=0,size={150,20}
	TitleBox Info6 title="\Zr140Errors handling:",pos={15,335},frame=0,fstyle=1, fixedSize=0,size={40,15},fColor=(0,0,52224)
	
	CheckBox UseSMRData,pos={170,40},size={141,14},proc=IR2Pr_InputPanelCheckboxProc,title="SMR data"
	CheckBox UseSMRData,variable= root:packages:Irena_PDDF:UseSMRData, help={"Check, if you are using slit smeared data"}
	SetVariable SlitLength,limits={0,Inf,0},value= root:Packages:Irena_PDDF:SlitLength, disable=!root:packages:Irena_PDDF:UseSMRData
	SetVariable SlitLength,pos={260,40},size={100,16},title="SL=",noproc, help={"slit length"}

	Button DrawGraphs,pos={56,158},size={100,20}, proc=IR2Pr_InputPanelButtonProc,title="Graph", help={"Create a graph (log-log) of your experiment data"}
	Button GetHelp,pos={305,105},size={80,15},fColor=(65535,32768,32768), proc=IR2Pr_InputPanelButtonProc,title="Get Help", help={"Open www manual page for this tool"}

//	CheckBox UseRegularization,pos={250,185},size={141,14},noproc,title="Regularization", disable=2, mode=1
//	CheckBox UseRegularization,variable= root:packages:Irena_PDDF:UseRegularization, help={"Check, if you want to use Regularization as modeling method"}
//	CheckBox UseMoore,pos={250,200},size={141,14},noproc,title="Moore", disable=2, mode=1
//	CheckBox useMoore,variable= root:packages:Irena_PDDF:UseMoore, help={"Check, if you want to use Morre method"}

	TabControl ModelControlsTab,pos={2,220},size={380,320},proc=IR2Pr_TabPanelControl
	TabControl ModelControlsTab,tabLabel(0)="\Zr120Regularization",tabLabel(1)="\Zr120Moore"

	SetVariable RmaxInput,pos={20,250},size={200,16},bodyWidth=90, title="Maximum r [A]", help={"Input maximum diamter of particles being modeled"}
	SetVariable RmaxInput,limits={1,Inf,1},value= root:Packages:Irena_PDDF:MaximumR
	Button GuessMaximum,pos={230,255},size={140,18}, proc=IR2Pr_ButtonProc,title="Guess maximum", help={"Push to save data to neotebook"}
	SetVariable RadiaSteps,pos={20,275},size={200,16},title="Bins in radii", bodyWidth=60
	SetVariable RadiaSteps,limits={1,Inf,1},value= root:Packages:Irena_PDDF:NumberOfBins, help={"Number of bins modeled."}

	SetVariable Background,pos={20, 300},size={300,16}, bodyWidth=70,proc=IR2Pr_BackgroundInput,title="Subtract Background   :   "
	SetVariable Background,limits={-Inf,Inf,0.001},value= root:Packages:Irena_PDDF:Background, help={"Value for flat backgound"}


	CheckBox UseUserErrors,pos={5,360},size={90,14},proc=IR2Pr_InputPanelCheckboxProc,title="User errors?", mode=1
	CheckBox UseUserErrors,variable= root:packages:Irena_PDDF:UseUserErrors, help={"Check, if you want to use errors provided by you from error wave"}
	CheckBox UseSQRTErrors,pos={120,360},size={90,14},proc=IR2Pr_InputPanelCheckboxProc,title="Sqrt errors?", mode=1
	CheckBox UseSQRTErrors,variable= root:packages:Irena_PDDF:UseSQRTErrors, help={"Check, if you want to use errors equal square root of intensity"}
	CheckBox UsePercentErrors,pos={235,360},size={90,14},proc=IR2Pr_InputPanelCheckboxProc,title=" % errors?", mode=1
	CheckBox UsePercentErrors,variable= root:packages:Irena_PDDF:UsePercentErrors, help={"Check, if you want to use errors equal n% of intensity"}
//	CheckBox UseNoErrors,pos={290,360},size={100,14},proc=IR2Pr_InputPanelCheckboxProc,title="No errors?", mode=1
//	CheckBox UseNoErrors,variable= root:packages:Irena_PDDF:UseConstantErrors, help={"Check, if you do not want to use errors"}

	SetVariable ErrorMultiplier,pos={20,380},size={200,16},bodyWidth=60, title="Multiply Errors by : ", proc=IR2Pr_SetVarProc, disable=!(root:packages:Irena_PDDF:UseUserErrors || root:packages:Irena_PDDF:UseSQRTErrors)
	SetVariable ErrorMultiplier,limits={0,Inf,root:Packages:Irena_PDDF:ErrorMultiplier/10},value= root:Packages:Irena_PDDF:ErrorMultiplier, help={"Errors scaling factor"}
	SetVariable PercentErrorsValue,pos={20,380},size={200,16},bodyWidth=60, title="% errors to use : ", proc=IR2Pr_SetVarProc, disable=!(root:packages:Irena_PDDF:UsePercentErrors)
	SetVariable PercentErrorsValue,limits={0,Inf,root:Packages:Irena_PDDF:PercentErrorsValue/10},value= root:Packages:Irena_PDDF:PercentErrorsValue, help={"% errors wehn using this setting"}

	SetVariable Moore_NumOfFncts,pos={13,430},size={320,16},bodyWidth=70,title="Moore number of functions :      ", disable=!(root:packages:Irena_PDDF:UseMoore)
	SetVariable Moore_NumOfFncts,limits={0,Inf,5},value= root:Packages:Irena_PDDF:Moore_NumOfFncts, help={"Numberof functions used to fit with Moore method"}
	CheckBox Moore_DetNumFncts,pos={10,455},size={150,14},title="Determine number of functions?", proc=IR2Pr_InputPanelCheckboxProc
	CheckBox Moore_DetNumFncts,variable= root:packages:Irena_PDDF:Moore_DetNumFncts, help={"Check, if you want to use determine the right number of functions automatically"}
	CheckBox Moore_FitBckg,pos={10,480},size={150,14},title="Fit background?"
	CheckBox Moore_FitBckg,variable= root:packages:Irena_PDDF:Moore_FitBckg, help={"Check, if you want to use fit background also"}
	CheckBox Moore_HoldMaxSize,pos={10,505},size={150,14},title="Fit maximum size?"
	CheckBox Moore_HoldMaxSize,variable= root:packages:Irena_PDDF:Moore_HoldMaxSize, help={"Check, if you want to use hold maximum size"}

	Button RunFittings,pos={150,550},size={200,20}, proc=IR2Pr_PdfFitting,title="Run Fitting", help={"Push to run fitting using method selected above"}
	Button SaveDataToFldr,pos={5,580},size={120,20}, proc=IR2Pr_ButtonProc,title="Save Results", help={"Push to save data back to folder"}

	Button SaveResultsToNotebook,pos={5,610},size={120,20}, proc=IR2Pr_ButtonProc,title="Paste to Notebook", help={"Push to save data to notebook"}
	Button SetExportPath,pos={130,613},size={110,15}, proc=IR2Pr_ButtonProc,title="Set Export path", help={"Export GNOM out data file for use with other tools"}
	Button ExportGNOMFile,pos={250,610},size={140,20}, proc=IR2Pr_ButtonProc,title="Export GNOM out data", help={"Export GNOM out data file for use with other tools"}


	IR2Pr_TabPanelControl("",0)
	IR2Pr_UpdateErrorWave()
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2Pr_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"SaveDataToFldr"))
				//save data here...
				IR2Pr_SaveResultsToFldr()
			endif
			if(stringmatch(ba.ctrlName,"SaveResultsToNotebook"))
				//save data here...
				IR2Pr_SaveResultsToNotebook()
			endif
			if(stringmatch(ba.ctrlName,"GuessMaximum"))
				//save data here...
				IR2Pr_EstimateDmax()
			endif
			if(stringmatch(ba.ctrlName,"ExportGNOMFile"))
				//save data here...
				IR2Pr_ExportGNOMoutFile()
			endif
			if(stringmatch(ba.ctrlName,"SetExportPath"))
				//save data here...
				IR2Pr_SetExportGNOMoutFile()
			endif
			break
	endswitch

	return 0
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2Pr_EstimateDmax()
	variable level
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_PDDF

	Wave OriginalIntensity=root:Packages:Irena_PDDF:Intensity
	Wave OriginalQvector=root:Packages:Irena_PDDF:Q_vec
	Wave OriginalError=root:Packages:Irena_PDDF:Errors

	variable Rg
	Variable G
	Variable B
	G = OriginalIntensity[0]
	FindLevel /P/Q OriginalIntensity, OriginalIntensity[0]*0.3
	variable GetQAtRg=OriginalQvector[V_levelX]
	Rg = 1/GetQAtRg
	B = OriginalIntensity[V_levelX]*OriginalQvector[V_levelX]^4
	Make /N=3/O W_coef, LocalEwave
	Make/N=3/T/O T_Constraints
	T_Constraints[0] = {"K1 > 0"}
	T_Constraints[1] = {"K0 > 0"}
	T_Constraints[2] = {"K2 > 0"}
	Variable V_FitError=0			//This should prevent errors from being generated
	W_coef[0]=G 	//G
	W_coef[1]=Rg	//Rg
	W_coef[2]=B	//B

//	LocalEwave[0]=(G/20)
//	LocalEwave[1]=(Rg/20)

	FuncFit IR2Pr_IntensityFit W_coef OriginalIntensity /X=OriginalQvector /C=T_Constraints //W=OriginalError //I=1//E=LocalEwave 
	if (V_FitError!=0)	//there was error in fitting
		beep
		Abort "Fitting error, Cannot fit Rg" 
	endif
	Duplicate/O OriginalIntensity, QstarVector, GuessFitScattProfile
	QstarVector = OriginalQvector / (erf(OriginalQvector*w_coef[1]/sqrt(6)))^3
	GuessFitScattProfile =  w_coef[0]*exp(-OriginalQvector^2*w_coef[1]^2/3)+(w_coef[2]/QstarVector^4) 
	CheckDisplayed /W=IR2Pr_PDFInputGraph  GuessFitScattProfile  
	if(!V_flag)
		GetAxis /W=IR2Pr_PDFInputGraph /Q left
		AppendToGraph  /W=IR2Pr_PDFInputGraph  GuessFitScattProfile  vs OriginalQvector
		SetAxis/W=IR2Pr_PDFInputGraph left, V_min, V_max
		ModifyGraph /W=IR2Pr_PDFInputGraph lstyle(GuessFitScattProfile)=8,lsize(GuessFitScattProfile)=3
		ModifyGraph /W=IR2Pr_PDFInputGraph rgb(GuessFitScattProfile)=(1,3,39321)
		Tag/C/N=GuessRg/L=0/TL=0/W=IR2Pr_PDFInputGraph GuessFitScattProfile, numpnts(GuessFitScattProfile)/10,"\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("TagSize")+"Estimated Rg = "+num2str(W_Coef[1])
	endif
	NVAR dmax=root:Packages:Irena_PDDF:MaximumR
	dmax=2.5*abs(W_coef[1])
	KillWaves/Z LocalEwave, W_coef, T_constraints
	SetDataFolder oldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2Pr_IntensityFit(w,q) : FitFunc
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
	//CurveFitDialog/ w[2] = Porod prefactor

	w[0]=abs(w[0])
	w[1]=abs(w[1])
	w[2]=abs(w[2])
	variable qstar=q/(erf(q*w[1]/sqrt(6)))^3
	return w[0]*exp(-q^2*w[1]^2/3)+(w[2]/qstar^4)
//	QstarVector=QvectorWave/(erf(QvectorWave*Rg/sqrt(6)))^3
//G*exp(-QvectorWave^2*Rg^2/3)+(B/QstarVector^P) 

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2Pr_SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	DoWindow/F IR2Pr_ControlPanel
	IR1G_UpdateSetVarStep(ctrlName,0.05)
//
//	if(cmpstr("MaxsasIter",ctrlName)==0)
//		NVAR test=root:Packages:Sizes:MaxsasNumIter
//		test=floor(test)
//	endif
	if(cmpstr("ErrorMultiplier",ctrlName)==0)
		IR2Pr_UpdateErrorWave()
	endif
	if(cmpstr("PercentErrorsValue",ctrlName)==0)
		IR2Pr_UpdateErrorWave()
	endif
	DoWIndow/F IR2Pr_ControlPanel

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2Pr_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_PDDF
	NVAR UseUserErrors=root:packages:Irena_PDDF:UseUserErrors
	NVAR UseSQRTErrors=root:packages:Irena_PDDF:UseSQRTErrors
	NVAR UsePercentErrors=root:packages:Irena_PDDF:UsePercentErrors
//	NVAR UseNoErrors=root:packages:Irena_PDDF:UseConstantErrors
	SVAR ErrorWaveName=root:Packages:Irena_PDDF:ErrorWaveName
	if(cmpstr(ctrlName,"UseUserErrors")==0 && !(cmpstr(ErrorWaveName,"---")==0 || cmpstr(ErrorWaveName,"'---'")==0))
		UseUserErrors=1
		UseSQRTErrors=0
		UsePercentErrors=0
//		UseNoErrors=0
		IR2Pr_UpdateErrorWave()
	elseif(cmpstr(ctrlName,"UseUserErrors")==0 && (cmpstr(ErrorWaveName,"---")==0 || cmpstr(ErrorWaveName,"'---'")==0))
		UseUserErrors=0
		UseSQRTErrors=1
		UsePercentErrors=0
//		UseNoErrors=1
		IR2Pr_UpdateErrorWave()
	endif
	if(cmpstr(ctrlName,"UseSQRTErrors")==0)
		UseUserErrors=0
		//UseSQRTErrors=0
		UsePercentErrors=0
//		UseNoErrors=0
		IR2Pr_UpdateErrorWave()
	endif
	if(cmpstr(ctrlName,"UsePercentErrors")==0)
		UseUserErrors=0
		UseSQRTErrors=0
		//UsePercentErrors=0
//		UseNoErrors=0
		IR2Pr_UpdateErrorWave()
	endif
//	if(cmpstr(ctrlName,"UseNoErrors")==0)
//		UseUserErrors=0
//		UseSQRTErrors=0
//		UsePercentErrors=0
//		//UseNoErrors=0
//		IR2Pr_UpdateErrorWave()
//	endif
	if (cmpstr(ctrlName,"UseSMRData")==0)
		//here we control the data structure checkbox
		NVAR UseIndra2Data=root:Packages:Irena_PDDF:UseIndra2Data
		NVAR UseQRSData=root:Packages:Irena_PDDF:UseQRSData
		NVAR UseSMRData=root:Packages:Irena_PDDF:UseSMRData
		SetVariable SlitLength,win=IR2Pr_ControlPanel, disable=!UseSMRData
		Checkbox UseIndra2Data,win=IR2Pr_ControlPanel, value=UseIndra2Data
		Checkbox UseQRSData,win=IR2Pr_ControlPanel, value=UseQRSData
		SVAR Dtf=root:Packages:Irena_PDDF:DataFolderName
		SVAR IntDf=root:Packages:Irena_PDDF:IntensityWaveName
		SVAR QDf=root:Packages:Irena_PDDF:QWaveName
		SVAR EDf=root:Packages:Irena_PDDF:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder,win=IR2Pr_ControlPanel, mode=1
			PopupMenu IntensityDataName,  mode=1,win=IR2Pr_ControlPanel, value="---"
			PopupMenu QvecDataName, mode=1,win=IR2Pr_ControlPanel, value="---"
			PopupMenu ErrorDataName, mode=1,win=IR2Pr_ControlPanel, value="---"
		   //here we control the data structure checkbox
			execute("PopupMenu SelectDataFolder,mode=1,popvalue=\"---\",value= \"---;\"+IR2P_GenStringOfFolders(winNm=\""+"IR2Pr_ControlPanel"+"\")")
	endif

	SetVariable ErrorMultiplier,disable=!(UseUserErrors||UseSQRTErrors)
	SetVariable PercentErrorsValue, disable=!(UsePercentErrors)
//	PopupMenu SizesPowerToUse, disable=!(UseNoErrors)
	if(cmpstr(ctrlName,"Moore_DetNumFncts")==0)
		NVAR Moore_NumOfFncts=root:Packages:Irena_PDDF:Moore_NumOfFncts
		NVAR maximumR=root:Packages:Irena_PDDF:maximumR	
		Wave Q_vec=root:Packages:Irena_PDDF:Q_vec
		variable qmaxpos=Q_vec[numpnts(Q_vec)-1]
		Moore_NumOfFncts=round(maximumR*qmaxpos/pi)-1

	endif

	SETDATaFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2Pr_UpdateErrorWave()

	//let's use this now also to display user messing up the errors...
		NVAR PercentErrorToUse=root:Packages:Irena_PDDF:PercentErrorsValue
		NVAR ErrorsMultiplier=root:Packages:Irena_PDDF:ErrorMultiplier
	NVAR UseUserErrors=root:packages:Irena_PDDF:UseUserErrors
	NVAR UseSQRTErrors=root:packages:Irena_PDDF:UseSQRTErrors
	NVAR UsePercentErrors=root:packages:Irena_PDDF:UsePercentErrors
//	NVAR UseNoErrors=root:packages:Irena_PDDF:UseConstantErrors
		Wave/Z DeletePointsMaskErrorWave=root:Packages:Irena_PDDF:DeletePointsMaskErrorWave
		if(!WaveExists(DeletePointsMaskErrorWave))
			return 0
		endif
		Wave ErrorsOriginal=root:Packages:Irena_PDDF:ErrorsOriginal
		Wave IntensityOriginal=root:Packages:Irena_PDDF:IntensityOriginal
		
		if(UsePercentErrors)
			DeletePointsMaskErrorWave = IntensityOriginal * PercentErrorToUse / 100
			Smooth 5, DeletePointsMaskErrorWave
//		elseif(UseNoErrors)
//			DeletePointsMaskErrorWave = 0
		elseif(UseSQRTErrors)
			DeletePointsMaskErrorWave = sqrt(IntensityOriginal) * ErrorsMultiplier
			Smooth 5, DeletePointsMaskErrorWave
		elseif(UseUserErrors)
			DeletePointsMaskErrorWave = ErrorsOriginal * ErrorsMultiplier
		endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2Pr_TabPanelControl(name,tab)
	String name
	Variable tab

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_PDDF

	NVAR UseRegularization= root:packages:Irena_PDDF:UseRegularization
	NVAR useMoore= root:packages:Irena_PDDF:UseMoore

	if(tab==1)
		useMoore=1
		useRegularization=0
		Button RunFittings,title="Run Fitting using Moore method"
	else
		useMoore=0
		useRegularization=1
		Button RunFittings,title="Run Fitting using Regularization"
		DoWindow IR2Pr_PDFInputGraph
		if(V_Flag)
			TextBox/W=IR2Pr_PDFInputGraph/N=MooreFitNote /K 
		endif
	endif
//	SetVariable RminInput,disable =  (tab!=0)
//	SetVariable RmaxInput,disable =  (tab!=0)
//	PopupMenu Binning,disable =  (tab!=0)
//	SetVariable RadiaSteps,disable =  (tab!=0)
//	SetVariable Background,disable =  (tab!=0)
	SetVariable Moore_NumOfFncts,disable =  (tab!=1)
	CheckBox Moore_DetNumFncts,disable =  (tab!=1)
	CheckBox Moore_FitBckg,disable =  (tab!=1)
	CheckBox Moore_HoldMaxSize,disable =  (tab!=1)

//thse are always present...
	NVAR UseUserErrors=root:packages:Irena_PDDF:UseUserErrors
	NVAR UseSQRTErrors=root:packages:Irena_PDDF:UseSQRTErrors
	NVAR UsePercentErrors=root:packages:Irena_PDDF:UsePercentErrors
///	NVAR UseNoErrors=root:packages:Irena_PDDF:UseConstantErrors
	CheckBox UseUserErrors,disable =  0
	CheckBox UseSQRTErrors,disable =  0
	CheckBox UsePercentErrors,disable =  0
//	CheckBox UseNoErrors,disable =  0
	SetVariable ErrorMultiplier,disable =  (UsePercentErrors)
	SetVariable PercentErrorsValue,disable =  (UseUserErrors ||UseSQRTErrors )

	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************



Function IR2Pr_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_PDDF
	

	if(cmpstr(ctrlName,"GetHelp")==0)
		//Open www manual with the right page
		IN2G_OpenWebManual("Irena/PairDistanceDist.html")
	endif
	if (cmpstr(ctrlName,"DrawGraphs")==0 || cmpstr(ctrlName,"DrawGraphsSkipDialogs")==0)
		//here goes what is done, when user pushes Graph button
		SVAR DFloc=root:Packages:Irena_PDDF:DataFolderName
		SVAR DFInt=root:Packages:Irena_PDDF:IntensityWaveName
		SVAR DFQ=root:Packages:Irena_PDDF:QWaveName
		SVAR DFE=root:Packages:Irena_PDDF:ErrorWaveName
		variable IsAllAllRight=1
		if (cmpstr(DFloc,"---")==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFInt,"---")==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFQ,"---")==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFE,"---")==0)
			IsAllAllRight=0
		endif
		
		if (IsAllAllRight)
			if(cmpstr(ctrlName,"DrawGraphsSkipDialogs")!=0)
//				variable recovered = IR1A_RecoverOldParameters()	//recovers old parameters and returns 1 if done so...
			endif
			IR2Pr_GraphIfAllowed(ctrlName)
			Execute("IR2Pr_PdfInputGraph()")				//this creates the graph

//			IR2D_RecoverOldParameters()
		else
			Abort "Data not selected properly"
		endif
	endif


//	if (cmpstr(ctrlName,"RunFittings")==0)
//		
//	endif
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Proc  IR2Pr_PdfInputGraph() 
	PauseUpdate    		// building window...
	SetDataFolder root:Packages:Irena_PDDF:
	Display/K=1 /W=(0,0,IN2G_GetGraphWidthHeight("width"),IN2G_GetGraphWidthHeight("height")) IntensityOriginal vs Q_vecOriginal
	//Display/K=1 /W=(35*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("height"),95*IN2G_ScreenWidthHeight("width"),80*IN2G_ScreenWidthHeight("height")) IntensityOriginal vs Q_vecOriginal
	DoWindow/C IR2Pr_PDFInputGraph
	DoWindow/T IR2Pr_PDFInputGraph,"Pair distribution function"
	DoWIndow IR2Pr_ControlPanel
	if(V_Flag)
		AutoPositionWindow/M=0/R=IR2Pr_ControlPanel  IR2Pr_PDFInputGraph	
	endif
	IR2Pr_AppendIntOriginal()	//appends original Intensity 
//	IN2G_AppendSizeTopWave("IR1R_SizesInputGraph",Q_vecOriginal, IntensityOriginal,-25,0,40)		//appends the size wave
//	removed on request of Pete
	ModifyGraph mirror=1
	AppendToGraph BackgroundWave vs Q_vecOriginal
	ModifyGraph/Z margin(top)=80
	ControlBar /T 60
	Button RemovePointR pos={115,5}, size={120,15},  title="Remove pnt w/csrA", proc=IR2Pr_RemovePointWithCursorA
	Button ReturnAllPoints pos={115,25}, size={120,15},  title="Return All deleted points", proc=IR2Pr_ReturnAllDeletedPoints
	Button KillThisWindow pos={5,5}, size={90,15},  title="Kill window", proc=IN2G_KillGraphsAndTables
	Button ResetWindow pos={5,25}, size={90,15},  title="Reset window", proc=IN2G_ResetGraph
//	Button CalculateVolume pos={250,40}, size={100,15},  title="Calculate Parameters", proc=IN2R_CalculateVolume, help={"Calculates volume, mean, mode and median of  scatterers between cursors. Set cursors on bar graph."}
	Checkbox LogParticleAxis, pos={250,5}, title="Log Particle size axis?", proc = IR2Pr_GraphCheckboxes, help={"Check to have logarithmic particle size (top) axis"}
	Checkbox LogParticleAxis, variable=root:Packages:Irena_PDDF:GraphLogTopAxis
	Checkbox LogDistVolumeAxis, pos={250,20}, title="Log Particle Volume axis?", proc = IR2Pr_GraphCheckboxes, help={"Check to have logarithmic particle voilume distribution (right) axis"}
	Checkbox LogDistVolumeAxis, variable=root:Packages:Irena_PDDF:GraphLogRightAxis
	ModifyGraph log=1
	Label left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity"
	ModifyGraph lblPos(left)=50
	Label bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M]"
	ShowInfo
	variable testQRS
	testQRS = root:Packages:Irena_PDDF:UseQRSdata
	if(strlen(StringByKey("UserSampleName", note(IntensityOriginal), "="))>1)
		Textbox/N=text0/S=3/A=RT "The sample evaluated is:  "+StringByKey("UserSampleName", note(IntensityOriginal), "=")
	else
		if(testQRS==1)
			Textbox/N=text0/S=3/A=RT "\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"The sample evaluated is:  "+root:Packages:Irena_PDDF:IntensityWaveName
		else
			Textbox/K/N=text0
		endif	
	endif
	//and now some controls
//	ControlBar 30
//	Button SaveStyle size={80,20}, pos={50,5},proc=IR1U_StyleButtonCotrol,title="Save Style"
//	Button ApplyStyle size={80,20}, pos={150,5},proc=IR1U_StyleButtonCotrol,title="Apply Style"
	TextBox/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	DoUpdate

EndMacro

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2Pr_AppendIntOriginal()		//appends (and removes) and configures in graph IntOriginal vs Qvec Original
	
	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF
	
	Wave IntensityOriginal=root:Packages:Irena_PDDF:IntensityOriginal
	Wave Q_vecOriginal=root:Packages:Irena_PDDF:Q_vecOriginal
	Wave DeletePointsMaskErrorWave=root:Packages:Irena_PDDF:DeletePointsMaskErrorWave
	variable csrApos
	variable csrBpos
	
	if (strlen(csrWave(A))!=0)
		csrApos=pcsr(A)
	else
		csrApos=0
	endif	
		
	 
	if (strlen(csrWave(B))!=0)
		csrBpos=pcsr(B)
	else
		csrBpos=numpnts(IntensityOriginal)-1
	endif	

	RemoveFromGraph/Z IntensityOriginal
	AppendToGraph IntensityOriginal vs Q_vecOriginal
	
	Label left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity"
	ModifyGraph lblPos(left)=50
	Label bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M]"

	ModifyGraph mode(IntensityOriginal)=3
	ModifyGraph msize(IntensityOriginal)=2
	ModifyGraph rgb(IntensityOriginal)=(0,52224,0)
	ModifyGraph zmrkNum(IntensityOriginal)={DeletePointsMaskWave}
	ErrorBars IntensityOriginal Y,wave=(DeletePointsMaskErrorWave,DeletePointsMaskErrorWave)
	Cursor/P A IntensityOriginal, csrApos
	Cursor/P B IntensityOriginal, csrBpos
	
	setDataFolder OldDf
end

//*****************************************************************************************************************
//
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR2Pr_GraphIfAllowed(ctrlName)
		string ctrlName

		KillWIndow/Z IR2Pr_PDFInputGraph
 		SVAR FldrNm=root:Packages:Irena_PDDF:DataFolderName

		SVAR IntNm=root:Packages:Irena_PDDF:IntensityWaveName
		SVAR QvcNm=root:Packages:Irena_PDDF:QWavename
		SVAR ErrNm=root:Packages:Irena_PDDF:ErrorWaveName	
		//fix for liberal names
		IntNm=IN2G_RemoveExtraQuote(IntNm,1,1)
		QvcNm=IN2G_RemoveExtraQuote(QvcNm,1,1)
		ErrNm=IN2G_RemoveExtraQuote(ErrNm,1,1)
		IntNm= PossiblyQuoteName(IntNm)
		QvcNm= PossiblyQuoteName(QvcNm)
		ErrNm= PossiblyQuoteName(ErrNm)

	//check if slit smeared data used...
	if(stringmatch(IntNm, "*SMR_Int") && stringmatch(ErrNm, "*SMR_Error") && stringmatch(QvcNm, "*SMR_Qvec"))
		NVAR UseSlitSmearedData=root:Packages:Irena_PDDF:UseSMRData
//		SVAR SizesParameters=root:Packages:Irena_PDDF:SizesParameters
//		SlitSmeared="yes"
		//UseSMRData=1
		UseSlitSmearedData=1
//		SizesParameters=ReplaceStringByKey("RegSlitSmearedData",SizesParameters,SlitSmeared,"=")
		SetVariable SlitLength,disable=0
	elseif(stringmatch(IntNm, "*DSM_Int") && stringmatch(ErrNm, "*DSM_Error") && stringmatch(QvcNm, "*DSM_Qvec"))
		NVAR UseSlitSmearedData=root:Packages:Irena_PDDF:UseSMRData
//		SVAR SizesParameters=root:Packages:Sizes:SizesParameters
//		SlitSmeared="no"
		UseSlitSmearedData=0
//		SizesParameters=ReplaceStringByKey("RegSlitSmearedData",SizesParameters,SlitSmeared,"=")
		SetVariable SlitLength,disable=1
	endif
		
	if ((strlen(IN2G_RemoveExtraQuote(IntNm,1,1))>0)&&(strlen(IN2G_RemoveExtraQuote(QvcNm,1,1))>0)&&(strlen(IN2G_RemoveExtraQuote(ErrNm,1,1))>0))
		Wave Int=$(FldrNm+IntNm)
		Wave Qvc=$(FldrNm+QvcNm)
		Wave/Z Err=$(FldrNm+ErrNm)
		
		if ((numpnts(Int)==numpnts(Qvc))&&(!WaveExists(Err)||(numpnts(Int)==numpnts(Err))))
			IR2Pr_SelectAndCopyData()
			if(cmpstr(ctrlName,"GraphIfAllowedSkipRecover")!=0)
				IR2Pr_RecoverOldParameters()							//this function recovers fitting parameters, if sizes were run already on the data
			endif
		else
			DoAlert 0, "The data DO NOT have same number of points. This indicates problem with data. Please fix the data to same length and try again..." 
		endif
	
	endif

	DoWIndow/F IR2Pr_PDFInputGraph
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2Pr_SelectAndCopyData()		//this function selects data to be used and copies them with proper names to Sizes folder

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF


	SVAR DataFolderName=root:Packages:Irena_PDDF:DataFolderName
	SVAR Intname=root:Packages:Irena_PDDF:IntensityWaveName
	SVAR Qname=root:Packages:Irena_PDDF:QWavename
	SVAR Ename=root:Packages:Irena_PDDF:ErrorWaveName
	NVAR UseUserErrors=root:packages:Irena_PDDF:UseUserErrors
	NVAR UseSQRTErrors=root:packages:Irena_PDDF:UseSQRTErrors
	NVAR UsePercentErrors=root:packages:Irena_PDDF:UsePercentErrors
//	NVAR UseNoErrors=root:packages:Irena_PDDF:UseConstantErrors


	
	Duplicate/O $(DataFolderName+possiblyQuoteName(Intname)), root:Packages:Irena_PDDF:IntensityOriginal			//here goes original Intensity
	Redimension/D root:Packages:Irena_PDDF:IntensityOriginal
	Duplicate/O $(DataFolderName+possiblyQuoteName(Intname)), root:Packages:Irena_PDDF:Intensity					//and its second copy, for fixing
	Redimension/D root:Packages:Irena_PDDF:Intensity
	Duplicate/O $(DataFolderName+possiblyQuoteName(Qname)), root:Packages:Irena_PDDF:Q_vec					//Q vector 
	Redimension/D root:Packages:Irena_PDDF:Q_vec
	Duplicate/O $(DataFolderName+possiblyQuoteName(Qname)), root:Packages:Irena_PDDF:Q_vecOriginal				//second copy of the Q vector
	Redimension/D root:Packages:Irena_PDDF:Q_vecOriginal
	Wave/Z ErrorOrg=$(DataFolderName+possiblyQuoteName(Ename))
	if(WaveExists(ErrorOrg))
		Duplicate/O $(DataFolderName+possiblyQuoteName(Ename)), root:Packages:Irena_PDDF:Errors						//errors
		Redimension/D root:Packages:Irena_PDDF:Errors
		Duplicate/O $(DataFolderName+possiblyQuoteName(Ename)), root:Packages:Irena_PDDF:ErrorsOriginal
		Redimension/D root:Packages:Irena_PDDF:ErrorsOriginal
//		UseNoErrors = 0
		UseUserErrors=1
		UseSQRTErrors=0
		UsePercentErrors=0
		DoWIndow IR2Pr_ControlPanel
		if(V_Flag)
			SetVariable ErrorMultiplier,disable=!(UseUserErrors||UseSQRTErrors), WIN=IR2Pr_ControlPanel
			SetVariable PercentErrorToUse, disable=!(UsePercentErrors), WIN=IR2Pr_ControlPanel
		endif
//		PopupMenu SizesPowerToUse, disable=!(UseNoErrors), WIN=IR2Pr_ControlPanel
	else	//errors do not exist, create errors with 0 in them...
		Duplicate/O $(DataFolderName+Intname), root:Packages:Irena_PDDF:Errors						//errors
		Redimension/D root:Packages:Irena_PDDF:Errors
		Duplicate/O $(DataFolderName+Intname), root:Packages:Irena_PDDF:ErrorsOriginal
		Redimension/D root:Packages:Irena_PDDF:ErrorsOriginal
		wave Err1=root:Packages:Irena_PDDF:Errors
		Err1=0
		wave Err2=root:Packages:Irena_PDDF:ErrorsOriginal
		Err2=0
//		UseNoErrors = 1
		UseUserErrors=0
		UseSQRTErrors=0
		UsePercentErrors=0
		DoWIndow IR2Pr_ControlPanel
		if(V_Flag)
			SetVariable ErrorMultiplier,disable=!(UseUserErrors||UseSQRTErrors), WIN=IR2Pr_ControlPanel
			SetVariable PercentErrorToUse, disable=!(UsePercentErrors), WIN=IR2Pr_ControlPanel
		endif
	//	PopupMenu SizesPowerToUse, disable=!(UseNoErrors), WIN=IR2Pr_ControlPanel
	endif
		
	Wave IntensityOriginal=root:Packages:Irena_PDDF:IntensityOriginal
	Wave ErrorsOriginal=root:Packages:Irena_PDDF:ErrorsOriginal

	Duplicate/O IntensityOriginal BackgroundWave			//this background wave is to help user to subtract background
	Duplicate/O IntensityOriginal DeletePointsMaskWave		//this wave is used to delete points by using this as amark wave and seting points to 
	Duplicate/O ErrorsOriginal DeletePointsMaskErrorWave		//delete to NaN. Then Intensity is at appropriate time mulitplied by this wave (and divided)
	IR2Pr_UpdateErrorWave()
														//to set points to delete to NaNs
	DeletePointsMaskWave=7								//this is symbol number used...
	
	//set the background...
//	Wavestats/Q root:Packages:Irena_PDDF:IntensityOriginal
	NVAR Bckg=root:Packages:Irena_PDDF:Background
//	Bckg=V_min
	BackgroundWave=Bckg

	NVAR SlitLength=root:Packages:Irena_PDDF:SlitLength
	SlitLength=NumberByKey("SlitLength", Note(IntensityOriginal), "=")
	
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1_CreateResultsNbk()

	SVAR/Z nbl=root:Packages:Irena:ResultsNotebookName
	if(!SVAR_Exists(nbl))
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena 
		String/G root:Packages:Irena:ResultsNotebookName=""
		SVAR nbl=root:Packages:Irena:ResultsNotebookName
		nbL="ResultsNotebook"
	endif
	
	string nbLL=nbl
	
	    
	if (strsearch(WinList("*",";","WIN:16"),nbL,0)!=-1) 		///Logbook exists
		DoWindow/F $nbl
	else
		NewNotebook/K=3/V=0/N=$nbl/F=1/V=1/W=(235.5,44.75,817.5,592.25) as nbl+""
		Notebook $nbl defaultTab=144, statusWidth=238, pageMargins={72,72,72,72}
		Notebook $nbl showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nbl newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={2.5*72, 3.5*72 + 8192, 5*72 + 3*8192}, rulerDefaults={"Arial",10,0,(0,0,0)}
		Notebook $nbl ruler=Normal; Notebook $nbl  justification=1, rulerDefaults={"Arial",14,1,(0,0,0)}
		Notebook $nbl text="Results of modeling with Irena package.\r"
		Notebook $nbl text="\r"
		Notebook $nbl ruler=Normal
		IR1_InsertDateAndTime(nbl)
	endif



	DoWIndow ModelingII_Results
	if(V_Flag)
		DoWIndow/F ModelingII_Results
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_AppendAnyGraph(GraphName)		//this function checks for existance of notebook
	string GraphName						//and appends text to the end of the notebook
	    
	string TextToBeInserted="\r"
    SVAR/Z nbl=root:Packages:Irena:ResultsNotebookName
	if(SVAR_exists(nbl))
		if (strsearch(WinList("*",";","WIN:16"),nbl,0)!=-1)				//Logs data in Logbook
			Notebook $nbl selection={endOfFile, endOfFile}
			Notebook $nbl scaling={50,50}, picture={$GraphName, 2, 1 }
			Notebook $nbl text=TextToBeInserted
		endif
	endif
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1_AppendAnyText(TextToBeInserted, style)		//this function checks for existance of notebook
	string TextToBeInserted						//and appends text to the end of the notebook
	variable style
	    
	TextToBeInserted=TextToBeInserted+"\r"
    SVAR/Z nbl=root:Packages:Irena:ResultsNotebookName
	if(SVAR_exists(nbl))
		if (strsearch(WinList("*",";","WIN:16"),nbl,0)!=-1)				//Logs data in Logbook
			Notebook $nbl selection={endOfFile, endOfFile}
			if(style==0)
					Notebook $nbl ruler=Normal,  justification=0, rulerDefaults={"TImes",8,0,(0,0,0)}, fstyle=-1
			elseif(style==1)
					Notebook $nbl  newruler=Header, justification=1, rulerDefaults={"Arial",18,3,(0,0,0)}
					Notebook $nbl ruler=Header
			elseif(style==2)
					Notebook $nbl  newruler=SubHeader, justification=1, rulerDefaults={"Arial",14,3,(0,0,0)}
					Notebook $nbl ruler=SubHeader
			endif
			
			Notebook $nbl text=TextToBeInserted
			Notebook $nbl ruler=Normal
		endif
	endif
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2Pr_GenGmatrixForPDF(G_matrix,Q_vec,R_distribution)
	wave G_matrix,Q_vec,R_distribution

		variable M=numpnts(Q_vec)
		variable N=numpnts(R_distribution)
		variable NumIntgPoints=200
		redimension/D/N=(M,N) G_matrix				//redimension G matrix to right size
		Make/D/O/N=(M) TempWave 					//create temp work wave
		Make/O/N=(NumIntgPoints)/D tempIntgWv

		variable i, j, currentR, currentRdif
		For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
			currentR=R_distribution[i]								//this is current radius
			if(i==0)
				SetScale/I x R_distribution[i],(R_distribution[i+1]+R_distribution[i])/2,"", tempIntgWv
				//currentRdif = (R_distribution[i+1]+R_distribution[i])/2  - R_distribution[i]
			elseif (i==N-1)
				SetScale/I x (R_distribution[i-1]+R_distribution[i])/2, R_distribution[i], "", tempIntgWv
				//currentRdif = R_distribution[i] - (R_distribution[i-1]+R_distribution[i])/2 
			else
				SetScale/I x (R_distribution[i-1]+R_distribution[i])/2,(R_distribution[i+1]+R_distribution[i])/2,"", tempIntgWv
				//currentRdif = (R_distribution[i+1]+R_distribution[i])/2   -  (R_distribution[i-1]+R_distribution[i])/2 
			endif
			For(j=0;j<M;j+=1)						//j runs through all Q values (rows)
				tempIntgWv =  (sinc(Q_vec[j] * x))	
			//	G_matrix[j][i] =4 *pi*sum(tempIntgWv) * currentRdif / NumIntgPoints
				G_matrix[j][i] =4 *pi*sum(tempIntgWv) / NumIntgPoints
			endfor
		endfor
		//variable temp= 
		//MatrixOp/O G_matrix = G_matrix * temp 
	//	G_matrix/=pi
		KillWaves/Z tempWave
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IR2Pr_FitMooreAutocorrelation()

	DFref oldDf= GetDataFolderDFR()

	setDataFOlder root:Packages:Irena_PDDF

	NVAR Moore_DetNumFncts=root:Packages:Irena_PDDF:Moore_DetNumFncts
	NVAR Moore_NumOfFncts=root:Packages:Irena_PDDF:Moore_NumOfFncts
	NVAR Moore_FitBckg=root:Packages:Irena_PDDF:Moore_FitBckg
	NVAR Moore_HoldMaxSize=root:Packages:Irena_PDDF:Moore_HoldMaxSize
	NVAR maximumR=root:Packages:Irena_PDDF:maximumR
	variable dmax=maximumR
	NVAR Background=root:Packages:Irena_PDDF:Background
	Wave Q_vec=root:Packages:Irena_PDDF:Q_vec
	Wave Intensity=root:Packages:Irena_PDDF:Intensity
	Wave Errors=root:Packages:Irena_PDDF:Errors
//CurrentResultPdf
	Wave/Z CurrentResultPdf= root:Packages:Irena_PDDF:CurrentResultPdf
	if(WaveExists(CurrentResultPdf))
		CurrentResultPdf=0
	endif 
	if (Moore_DetNumFncts)
		variable qmaxpos=Q_vec[numpnts(Q_vec)-1]
		Moore_NumOfFncts=round(dmax*qmaxpos/pi)-1
	endif
	MAKE/d/N=(Moore_NumOfFncts+5)/O MooreParametersV, MooreParametersS	
	MooreParametersV=0
	MooreParametersS=0
	MooreParametersV[0]=Q_vec[0]
	MooreParametersV[Moore_NumOfFncts]=Background
	MooreParametersV[Moore_NumOfFncts+1]=Moore_NumOfFncts
	MooreParametersV[Moore_NumOfFncts+2]=dmax 		
	variable j=0
	String hold=""
	do
		hold+="0"
		j+=1
	while (j<Moore_NumOfFncts)
	hold+=num2str(1-Moore_FitBckg)
	hold+="1"+num2str(1-Moore_HoldMaxSize)+"11"
//	print hold
	make/d/o/n=(numpnts(Intensity)) PdfFitIntensity=NaN		
	DoWindow IR2Pr_PDFInputGraph
	if(V_Flag)
		RemoveFromGraph/Z /W=IR2Pr_PDFInputGraph PdfFitIntensity
		AppendToGraph /W=IR2Pr_PDFInputGraph PdfFitIntensity vs Q_vec
		ModifyGraph/W=IR2Pr_PDFInputGraph rgb(PDFFitIntensity)=(0,0,52224)	
		ModifyGraph/W=IR2Pr_PDFInputGraph  lsize(PDFFitIntensity)=3		
	endif
	
	variable/g V_FitNumIters
	FuncFit/Q /H=hold IR2Pr_MooreIORFF,MooreParametersV,Intensity /X=Q_vec  /D=PdfFitIntensity /I=1 /W=Errors
	
	
	Duplicate/O Intensity, NormalizedResidual, ChisquaredWave	//waves for data
	IN2G_AppendorReplaceWaveNote("NormalizedResidual","Units"," ")
	NormalizedResidual=(Intensity-PdfFitIntensity)/Errors		//we need this for graph
	ChisquaredWave=NormalizedResidual^2			//and this is wave with Chisquared

	Wave w_sigma
	variable rchisq=V_chisq/(V_npnts-V_nterms+V_nheld)
	variable temp=numpnts(w_sigma)-1
	MooreParametersS[0,temp]=w_sigma
	make/d/o/n=(numpnts(MooreParametersV)) tempwv=MooreParametersS
	tempwv[Moore_NumOfFncts+1]=Moore_NumOfFncts
	tempwv[Moore_NumOfFncts+2]=dmax
	MooreParametersV[Moore_NumOfFncts+3]=IR2Pr_MooreINaught(MooreParametersV,0)
	MooreParametersS[Moore_NumOfFncts+3]=IR2Pr_MooreINaught(tempwv,0)
	tempwv[Moore_NumOfFncts+3]=MooreParametersV[Moore_NumOfFncts+3]
	MooreParametersV[Moore_NumOfFncts+4]=sqrt(IR2Pr_MooreRg(MooreParametersV,0))
	MooreParametersS[Moore_NumOfFncts+4]=sqrt((IR2Pr_MooreRg(tempwv,0))^2+(MooreParametersS[Moore_NumOfFncts+3]*MooreParametersV[Moore_NumOfFncts+4]/MooreParametersV[Moore_NumOfFncts+3])^2)
	MooreParametersS[Moore_NumOfFncts+4]=MooreParametersS[Moore_NumOfFncts+4]/(2*MooreParametersV[Moore_NumOfFncts+4])
	maximumR=MooreParametersV[Moore_NumOfFncts+2]
	string FitNote="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("TagSize")+"Fit using Moore's indirect Fourier transform"
	Fitnote+="\rMaximum extent = "+num2str(maximumR)+" ± "+num2str(MooreParametersS[Moore_NumOfFncts+2])+" ≈"
	Fitnote+="\r"+num2str(Moore_NumOfFncts)+" basis functions used"
	fitnote+="\rScale Factor = "+num2str(MooreParametersV[Moore_NumOfFncts+3])+" ± "+num2str(MooreParametersS[Moore_NumOfFncts+3])
	fitnote+="\rRadius of Gyration = "+num2str(MooreParametersV[Moore_NumOfFncts+4])+" ± "+num2str(MooreParametersS[Moore_NumOfFncts+4])+" ≈"
	Fitnote+="\rBackground = "+num2str(MooreParametersV[Moore_NumOfFncts])+" ± "+num2str(MooreParametersS[Moore_NumOfFncts])
	Fitnote+="\rReduced Chi Squared = "+num2str(rchisq)
	variable/g CurrentRg = MooreParametersV[Moore_NumOfFncts+4]
	variable/g CurrentRgError = MooreParametersS[Moore_NumOfFncts+4]
	print fitnote
	string/g FittingResults
	FittingResults=FitNote
	TextBox/W=IR2Pr_PDFInputGraph/C/N=MooreFitNote/A=MC fitnote 
	NVAR NumberIterations=root:Packages:Irena_PDDF:NumberIterations
	NumberIterations= V_FitNumIters
	NVAR NumberOfBins = root:Packages:Irena_PDDF:NumberOfBins
	variable stepInBin=(round(MooreParametersV[Moore_NumOfFncts+2])+1 )/(NumberOfBins-1)
	make/o/n=(NumberOfBins) R_distribution, CurrentResultPdf	//,$spor
	redimension/d CurrentResultPdf
	R_distribution=p*stepInBin
	CurrentResultPdf=IR2Pr_MoorePOR(MooreParametersV,R_distribution[p],dmax)/2
	//calculate errors here... Use MonteCarlo method on results using errors from LSQF... Probably wrong, but what the hell else?
	
	variable i, MontCarloMax=100		//number of MonteCarlo iterations
	Duplicate/O CurrentresultPdf, CurrentResultMontCarlo, PDDFErrors
	Make/O/N=(numpnts(R_distribution), (MontCarloMax)) MontStatWave
	For(i=0;i<MontCarloMax;i+=1)
		MooreParametersV = MooreParametersV+gNoise(1)/3*MooreParametersS	//this will create new parameters from par values + Gaussian e-noise * Error, practically ideal, if this is proper Sdev error... 
		CurrentResultMontCarlo=IR2Pr_MoorePOR(MooreParametersV,R_distribution[p],dmax)/2
		MontStatWave[][i]=CurrentResultMontCarlo[p]
	endfor	
	For(i=0;i<Numpnts(R_distribution);i+=1)
		Duplicate/O/R=[i][] MontStatWave, testWv
		wavestats/Q testWv
		PDDFErrors[i] = V_sdev
	endfor
//	MatrixOP/O RegPDFErrors = varCols(MontStatWave)
//	MatrixOP/O RegPDFErrors = RegPDFErrors^t
	KillWaves/Z  testWv, MontStatWave, CurrentResultMontCarlo
	SetDataFolder OldDf

	

	setDataFOlder OldDf
EndMacro


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IR2Pr_RecoverOldParameters()
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_PDDF
	SVAR ListOfStrings
	SVAR ListOfVariables	
	SVAR DataFolderName=root:Packages:Irena_PDDF:DataFolderName

	variable DataExists=0,i
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(DataFolderName, 2)
	string tempString
	if (stringmatch(ListOfWaves, "*PDDFIntensity*" ))
		string ListOfSolutions=""
		For(i=0;i<itemsInList(ListOfWaves);i+=1)
			if (stringmatch(stringFromList(i,ListOfWaves),"*PDDFIntensity*"))
				tempString=stringFromList(i,ListOfWaves)
				Wave tempwv=$(DataFolderName+tempString)
				tempString=stringByKey("UsersComment",note(tempwv),"=")
				ListOfSolutions+=stringFromList(i,ListOfWaves)+"*  "+tempString+";"
			endif
		endfor
		DataExists=1
		string ReturnSolution=""
		Prompt ReturnSolution, "Select solution to recover", popup,  ListOfSolutions+";Start fresh"
		DoPrompt "Previous solutions found, select one to recover", ReturnSolution
		if (V_Flag)
			abort
		endif
	endif
	SVAR MethodRun

	if (DataExists==1 && cmpstr("Start fresh", ReturnSolution)!=0)
		ReturnSolution=ReturnSolution[0,strsearch(ReturnSolution, "*", 0 )-1]
		Wave/Z OldDistribution=$(DataFolderName+ReturnSolution)

		string OldNote=note(OldDistribution)
		
		MethodRun=StringByKey("MethodRun", OldNote , "=", ";")
		string LocalListOFStrings = ReplaceString("DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;", ListOfStrings, "")
		For(i=0;i<ItemsInList(ListOfStrings);i+=1)
			SVAR tempStr=$StringFromList(i,ListOfStrings)
			tempStr=StringByKey(StringFromList(i,ListOfStrings), OldNote , "=", ";")
		endfor
		For(i=0;i<ItemsInList(ListOfVariables);i+=1)
			NVAR tempNum=$StringFromList(i,ListOfVariables)
			tempNum=NumberByKey(StringFromList(i,ListOfVariables), OldNote , "=", ";")
		endfor
	//	return 1
	else
	//	return 0
	
	endif
	variable tabUse=0
	if(stringmatch(MethodRun,"Moore"))
		tabUse=1
	endif
	TabControl ModelControlsTab value=tabUse, win=IR2Pr_ControlPanel
	IR2Pr_TabPanelControl("",tabUse)
	IR2Pr_UpdateErrorWave()

	SetDataFolder OldDf

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IR2Pr_SaveResultsToFldr()
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_PDDF
	//save data here... For Moore include "Fittingresults" which is Intensity Fit stuff
	//Parameters: 
	SVAR MethodRun
	string UsersComment="PDDF results using "+MethodRun +" from "+date()+"  "+time()
	
	Prompt UsersComment, "Modify comment to be included with these results"
	DoPrompt "Copy data back to folder comment", UsersComment
	if (V_Flag)
		abort
	endif
	SVAR ListOFVariables
	SVAR ListOfStrings
	String NewWaveNote="UsersComment="+UsersComment+";"
	variable i
	For(i=0;i<ItemsInList(ListOfStrings);i+=1)
		SVAR tempStr=$StringFromList(i,ListOfStrings)
		NewWavenote+=StringFromList(i,ListOfStrings)+"="+tempStr+";"
	endfor
	For(i=0;i<ItemsInList(ListOfVariables);i+=1)
		NVAR tempVar=$StringFromList(i,ListOfVariables)
		NewWavenote+=StringFromList(i,ListOfVariables)+"="+num2str(tempVar)+";"
	endfor
	SVAR/Z Fittingresults
	if (!SVAR_Exists(Fittingresults))
		string/g Fittingresults
		Fittingresults=""
	endif
	Wave R_distribution=root:Packages:Irena_PDDF:R_distribution
	Wave CurrentResultPdf = root:Packages:Irena_PDDF:CurrentResultPdf
	Wave CurrentResultsGamma = root:Packages:Irena_PDDF:CurrentResultsGamma
	Wave PDDFErrors = root:Packages:Irena_PDDF:PDDFErrors
	Wave Q_vec = root:Packages:Irena_PDDF:Q_vec
	Wave CurrentChiSq=root:Packages:Irena_PDDF:ChisquaredWave
	Wave PdfFitIntensity=root:Packages:Irena_PDDF:PdfFitIntensity
	SVAR DataFolderName=root:Packages:Irena_PDDF:DataFolderName

	Duplicate/O R_distribution, tempR_distribution
	Duplicate/O CurrentResultPdf, tempCurrentResultPdf
	Duplicate/O CurrentResultsGamma, tempCurrentResultsGamma
	Duplicate/O PDDFErrors, tempPDDFErrors
	Duplicate/O Q_vec, tempQ_vec
	Duplicate/O CurrentChiSq, tempCurrentChiSq
	Duplicate/O PdfFitIntensity, tempPdfFitIntensity
	string ListOfWavesForNotes="tempR_distribution;tempCurrentResultPdf;tempQ_vec;tempCurrentChiSq;tempPdfFitIntensity;tempPDDFErrors;tempCurrentResultsGamma;"
	For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)
		IN2G_AddListToWaveNote(stringFromList(i,ListOfWavesForNotes),NewWavenote)
		IN2G_AddListToWaveNote(stringFromList(i,ListOfWavesForNotes),Fittingresults)
	endfor
	setDataFolder $DataFolderName
	string tempname 
	variable ii=0
	For(ii=0;ii<1000;ii+=1)
		tempname="PDDFIntensity_"+num2str(ii)
		if (checkname(tempname,1)==0)
			break
		endif
	endfor
	Duplicate /O tempPdfFitIntensity, $tempname
	tempname="PDDFQvector_"+num2str(ii)
	Duplicate /O tempQ_vec, $tempname
	tempname="PDDFChiSquared_"+num2str(ii)
	Duplicate /O tempCurrentChiSq, $tempname
	tempname="PDDFDistFunction_"+num2str(ii)
	Duplicate /O tempCurrentResultPdf, $tempname
	tempname="PDDFErrors_"+num2str(ii)
	Duplicate /O tempPDDFErrors, $tempname
	tempname="PDDFDistances_"+num2str(ii)
	Duplicate /O tempR_distribution, $tempname
	tempname="PDDFGammaFunction_"+num2str(ii)
	Duplicate /O tempCurrentResultsGamma, $tempname
	
	print "Saved data to folder "+getDataFolder(1)+" , data generation is "+num2str(ii)
	Killwaves/Z tempR_distribution, tempCurrentResultPdf, tempQ_vec, tempCurrentChiSq, tempPdfFitIntensity, tempPDDFErrors, tempCurrentResultsGamma
	
	SetDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IR2Pr_SaveResultsToNotebook()

	IR1_CreateResultsNbk()
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_PDDF
	SVAR  DataFolderName=root:Packages:Irena_PDDF:DataFolderName
	SVAR  IntensityWaveName=root:Packages:Irena_PDDF:IntensityWaveName
	SVAR  QWavename=root:Packages:Irena_PDDF:QWavename
	SVAR  ErrorWaveName=root:Packages:Irena_PDDF:ErrorWaveName
	SVAR  MethodRun=root:Packages:Irena_PDDF:MethodRun
	IR1_AppendAnyText("\r Results of Pair distance distribution function fitting\r",1)	
	IR1_AppendAnyText("Date & time: \t"+Date()+"   "+time(),0)	
	IR1_AppendAnyText("Data from folder: \t"+DataFolderName,0)	
	IR1_AppendAnyText("Intensity: \t"+IntensityWaveName,0)	
	IR1_AppendAnyText("Q: \t"+QWavename,0)	
	IR1_AppendAnyText("Error: \t"+ErrorWaveName,0)	
	IR1_AppendAnyText("Method used: \t"+MethodRun,0)	
	
	IR1_AppendAnyGraph("IR2Pr_PDFInputGraph")
	//save data here... For Moore include "Fittingresults" which is Intensity Fit stuff
	SVAR FittingResults = root:Packages:Irena_PDDF:FittingResults
	IR1_AppendAnyText(FittingResults,0)	
	IR1_AppendAnyText("******************************************\r",0)	
	SetDataFolder OldDf
	SVAR/Z nbl=root:Packages:Irena:ResultsNotebookName	
	DoWindow/F $nbl
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2Pr_regRg(PDF,Rdist)
	wave PDF, Rdist
	
	Duplicate/O Rdist, diffRdist, tempWv
	diffRdist = Rdist[p+1] - Rdist[p]
	diffRdist[numpnts(diffRdist)-1]=diffRdist[numpnts(diffRdist)-2]
	tempWv = PDF * Rdist^2 * diffRdist
	variable Rg=sum(tempWv)
	tempWv = PDF*diffRdist
	Rg/=sum(tempWv)
	Killwaves/Z tempWv, diffRdist
	return sqrt(Rg/2)
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function  IR2Pr_MooreRg(cw,q)
	wave cw; variable q
	variable n=0,nmax=numpnts(cw)-5
	variable POR=0.0,dmax=cw[nmax+2]
	do
		POR+=cw[n]*((-1)^n)*((pi*(n+1))^2-6)/((n+1)^3)
		n+=1
	while (n<nmax)
	return POR*4*(dmax^4)/((pi^2)*cw[nmax+3])
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function  IR2Pr_MoorePOR(cw,r,dmax)
	wave cw; variable r,dmax
	variable n=0,nmax=numpnts(cw)-5
	variable POR=0.0
	if (r<=dmax) 
	do
		POR+=4*r*cw[n]*sin((n+1)*pi*r/dmax)
		n+=1
	while (n<nmax)
	endif
	return POR
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************



Function  IR2Pr_MooreIORFF(cw,q)
	wave cw; variable q
	variable n=0,nmax=numpnts(cw)-5
	variable POR=0.0,dmax=cw[nmax+2]
	variable dq=dmax*q
	variable fpd=8*(pi^2)*dmax*(sin(dq))/q
	do
		POR+=cw[n]*(n+1)*((-1)^n)*fpd/(((n+1)*pi)^2-dq^2)
		n+=1
	while (n<nmax)
	return POR+cw[nmax]
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function  IR2Pr_MooreINaught(cw,q)
	wave cw; variable q
	variable n=0,nmax=numpnts(cw)-5
	variable POR=0.0,dmax=cw[nmax+2]
	do
		POR+=cw[n]*8*(dmax^2)*((-1)^n)/(n+1)
		n+=1
	while (n<nmax)
	return POR
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2Pr_RemovePointWithCursorA(ctrlname) : Buttoncontrol			// Removes point in wave
	string ctrlname

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF
	
	Wave DeletePointsMaskWave=root:Packages:Irena_PDDF:DeletePointsMaskWave
	Wave DeletePointsMaskErrorWave=root:Packages:Irena_PDDF:DeletePointsMaskErrorWave
	
	DeletePointsMaskWave[pcsr(A)]=NaN
	DeletePointsMaskErrorWave[pcsr(A)]=NaN
	
	IR2Pr_AppendIntOriginal()	

	setDataFolder OldDf
End


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2Pr_ReturnAllDeletedPoints(ctrlname) : Buttoncontrol			// Removes point in wave
	string ctrlname

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF
	
	Wave DeletePointsMaskWave=root:Packages:Irena_PDDF:DeletePointsMaskWave
	Wave DeletePointsMaskErrorWave=root:Packages:Irena_PDDF:DeletePointsMaskErrorWave
	Wave ErrorsOriginal=root:Packages:Irena_PDDF:ErrorsOriginal
	
	DeletePointsMaskErrorWave=ErrorsOriginal
	DeletePointsMaskWave=7

	IR2Pr_AppendIntOriginal()	

	setDataFolder OldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2Pr_GraphCheckboxes(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	NVAR GraphLogTopAxis		=root:Packages:Irena_PDDF:GraphLogTopAxis
	NVAR GraphLogRightAxis 	=root:Packages:Irena_PDDF:GraphLogRightAxis
	if(cmpstr(ctrlName,"LogParticleAxis")==0)
		if (stringmatch(AxisList("IR2Pr_PDFInputGraph"), "*top*"))		//axis used
			ModifyGraph/W=IR2Pr_PDFInputGraph log(top)=GraphLogTopAxis
		endif
	endif
	if(cmpstr(ctrlName,"LogDistVolumeAxis")==0)
		if (stringmatch(AxisList("IR2Pr_PDFInputGraph"), "*right*"))		//axis used
			Wave CurrentResultPdf=root:Packages:Irena_PDDF:CurrentResultPdf
			WaveStats/Q CurrentResultPdf
			if(GraphLogRightAxis)		//log scaling
					SetAxis/W=IR2Pr_PDFInputGraph/N=1 right (V_max*1e-6),V_max*1.1
			else						//lin scailng
				if (V_min>0)
					SetAxis/W=IR2Pr_PDFInputGraph/N=1 right 0,V_max*1.1 
				else
					SetAxis/W=IR2Pr_PDFInputGraph/N=1 right -(V_max*0.1),V_max*1.1
				endif
			endif
			ModifyGraph/W=IR2Pr_PDFInputGraph log(right)=GraphLogRightAxis
		endif

	endif

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2Pr_BackgroundInput(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF
	DOWIndow/F IR2Pr_ControlPanel
	IR1G_UpdateSetVarStep("Background",0.1)

	Wave Q_vec=root:Packages:Irena_PDDF:Q_vec
	Duplicate/O Q_vecOriginal BackgroundWave
	BackgroundWave=varNum
	CheckDisplayed BackgroundWave 
	if (!V_Flag)
		AppendToGraph BackgroundWave vs Q_vecOriginal
	endif

	DoWIndow/F IR2Pr_ControlPanel
	setDataFolder OldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//
//Function IR2Pr_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//
////	SVAR SizesParameters=root:Packages:Sizes:SizesParameters
//
//	if(cmpstr(ctrlName,"Binning")==0)
//		SVAR LogDist=root:Packages:Irena_PDDF:LogBinning	
//		LogDist=popStr
////		SizesParameters=ReplaceStringByKey("RegLogRBinning",SizesParameters,popStr,"=")
//		NVAR GraphLogTopAxis=root:Packages:Irena_PDDF:GraphLogTopAxis
//		if(stringmatch(popStr,"Yes"))
//			GraphLogTopAxis=1
//		else
//			GraphLogTopAxis=0
//		endif
//		IR2Pr_GraphCheckboxes("LogParticleAxis",GraphLogTopAxis)
//	endif
//end
////*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2Pr_PdfFitting(ctrlName) : ButtonControl			//this function is called by button from the panel
	String ctrlName

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF
	
	DoWindow/F IR2Pr_PDFInputGraph				//pulls the control graph, in case it is not the top...
	if ( ((strlen(CsrWave(A))!=0) && (strlen(CsrWave(B))!=0) ) && (pcsr (A)!=pcsr (B)) )	//this should make sure, that both cursors are in the graph and not on the same point
		//make sure the cursors are on the right waves..
		Wave QvectorTmp=root:Packages:Irena_PDDF:Q_vecOriginal
		if (cmpstr(CsrWave(A, "IR2Pr_PDFInputGraph"),"IntensityOriginal")!=0)
			Cursor/P/W=IR2Pr_PDFInputGraph A  IntensityOriginal  binarysearch(QvectorTmp, CsrXWaveRef(A) [pcsr(A, "IR2Pr_PDFInputGraph")])
		endif
		if (cmpstr(CsrWave(B, "IR2Pr_PDFInputGraph"),"IntensityOriginal")!=0)
			Cursor/P /W=IR2Pr_PDFInputGraph B  IntensityOriginal  binarysearch(QvectorTmp,CsrXWaveRef(B) [pcsr(B, "IR2Pr_PDFInputGraph")])
		endif
	endif

	RemoveFromGraph/Z/W=IR2Pr_PDFInputGraph GuessFitScattProfile
	Tag/K/W=IR2Pr_PDFInputGraph/N=GuessRg
	DoUpdate
	
	IR2Pr_FinishSetupOfRegParam()					//finishes the setup of parametes
	TextBox/K/N=MooreFitNote

	NVAR UseRegularization=root:Packages:Irena_PDDF:UseRegularization
	NVAR UseMoore=root:Packages:Irena_PDDF:UseMoore
	NVAR SlitSmearedData=root:Packages:Irena_PDDF:UseSMRData	
	if(UseMoore+UseRegularization !=1)
		abort "Bad use variables in the IR2Pr_PdfFitting function"
	endif
	if(UseMoore && SlitSmearedData)
		abort "Moore cannot use slit smeared data"
	endif 

	if(UseRegularization)
		if (SlitSmearedData)				//if we are working with slit smeared data
			IR2Pr_ExtendQVecForSmearing()				//here we extend them by slitLength
		endif		
	
		//testing....	New Formfactor calculations Check that the G matrix actually exists. We need it... 
		//we will setup only form factor G matrix G_matrixFF, which will be scaled by contrast later on...
		Wave/Z G_matrix=root:Packages:Irena_PDDF:G_matrix
		Wave Q_vec=root:Packages:Irena_PDDF:Q_vec
		Wave R_distribution=root:Packages:Irena_PDDF:R_distribution
		variable M=numpnts(Q_vec)
		variable N=numpnts(R_distribution)
		if(!WaveExists(G_matrix))
			Make/D/O/N=(M,N) $("G_matrix")
			Wave G_matrix=root:Packages:Irena_PDDF:G_matrix
		endif	
		//generate G matrix... 
		IR2Pr_GenGmatrixForPDF(G_matrix,Q_vec,R_distribution)
	
		//now handle the contarst by copying data into the G_matrix
	//		G_matrix=G_matrixFF * ScatteringContrast*1e20		//this multiplyies by scattering contrast
		//done with G matrix processing, if it slit smeared let's fix it and that is all....
		if (SlitSmearedData)				//if we are working with slit smeared data
			IR2Pr_SmearGMatrix()							//here we smear the Columns in the G matrix
			IR2Pr_ShrinkGMatrixAfterSmear()			//here we cut the G matrix back in length
		endif		
	endif
	SVAR MethodRun=root:Packages:Irena_PDDF:MethodRun
	MethodRun = ""
	if (UseMoore)		//run internal maxEnt
		IR2Pr_FitMooreAutocorrelation()						//run Moore fitting 
		MethodRun="Moore"
	else												//regularization
		IR2Pr_DoInternalRegularization()				//run regularization
		MethodRun="Regularization"
		IR2Pr_PDDFCalculatePrVariation()				//calculate errors using MonteCarloMethod... 
//		Wave CurrentResultPdf=CurrentResultPdf
//		CurrentResultPdf*=pi
		
	endif
	//scaling to get same scaling as GNOM??? Why the hell to do this?
	
	//create gamma distribution as requested in 2010
	//these are results
	Wave CurrentResultPdf=root:Packages:Irena_PDDF:CurrentResultPdf
	Wave R_distribution=root:Packages:Irena_PDDF:R_distribution
	Duplicate/O CurrentResultPdf, CurrentResultsGamma
	CurrentResultsGamma = CurrentResultPdf/(4*pi*R_distribution^2)

	IR2Pr_FinishGraph()								//finish the graph to proper shape
	
	setDataFolder OldDf
end	
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

  Function IR2Pr_FinishGraph()			//finish the graph to proper way,  this will be really difficult to make Mac compatible

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

	DoWindow  IR2Pr_PDFInputGraph	
	if(!V_Flag)
		abort
	endif
	string fldrName
	Wave CurrentResultPdf=root:Packages:Irena_PDDF:CurrentResultPdf
	Wave R_distribution=root:Packages:Irena_PDDF:R_distribution
	Wave PDFFitIntensity=root:Packages:Irena_PDDF:PDFFitIntensity
	Wave Q_vec=root:Packages:Irena_PDDF:Q_vec
	Wave IntensityOriginal=root:Packages:Irena_PDDF:IntensityOriginal
	Wave NormalizedResidual=root:Packages:Irena_PDDF:NormalizedResidual
	Wave Q_vecOriginal=root:Packages:Irena_PDDF:Q_vecOriginal
	Wave/Z PDDFErrors = root:Packages:Irena_PDDF:PDDFErrors
//	SVAR SizesParameters=root:Packages:Irena_PDDF:SizesParameters
	Wave BackgroundWave=root:Packages:Irena_PDDF:BackgroundWave
	SVAR MethodRun=root:Packages:Irena_PDDF:MethodRun
	NVAR NumberIterations=root:Packages:Irena_PDDF:NumberIterations
//	NVAR MaxsasNumIter=root:Packages:Irena_PDDF:MaxsasNumIter
	NVAR GraphLogTopAxis		=root:Packages:Irena_PDDF:GraphLogTopAxis
	NVAR GraphLogRightAxis 	=root:Packages:Irena_PDDF:GraphLogRightAxis
	
	variable csrApos
	variable csrBpos
	
	DoWindow/F IR2Pr_PDFInputGraph
	
	if (strlen(csrWave(A))!=0)
		csrApos=pcsr(A)
	else
		csrApos=0
	endif	
	 
	if (strlen(csrWave(B))!=0)
		csrBpos=pcsr(B)
	else
		csrBpos=numpnts(IntensityOriginal)-1
	endif	
	DoWIndow /F IR2Pr_PDFInputGraph
	//PauseUpdate
	RemoveFromGraph/Z/W=IR2Pr_PDFInputGraph PDFFitIntensity
	RemoveFromGraph/Z/W=IR2Pr_PDFInputGraph BackgroundWave
	RemoveFromGraph/Z/W=IR2Pr_PDFInputGraph CurrentResultPdf
	RemoveFromGraph/Z/W=IR2Pr_PDFInputGraph NormalizedResidual
	RemoveFromGraph/Z/W=IR2Pr_PDFInputGraph IntensityOriginal
	RemoveFromGraph/Z/W=IR2Pr_PDFInputGraph Intensity
	
	AppendToGraph/T/R/W=IR2Pr_PDFInputGraph CurrentResultPdf vs R_distribution
	if(WaveExists(PDDFErrors))
		ErrorBars CurrentResultPdf Y,wave=(PDDFErrors,PDDFErrors)
	endif
	WaveStats/Q CurrentResultPdf
	if(GraphLogRightAxis)		//log scaling
			SetAxis/W=IR2Pr_PDFInputGraph/N=1 right (V_max*1e-5),V_max*1.1
	else						//lin scailng
		if (V_min>0)
			SetAxis/W=IR2Pr_PDFInputGraph/N=1 right 0,V_max*1.1 
		else
			SetAxis/W=IR2Pr_PDFInputGraph/N=1 right -(V_max*0.1),V_max*1.1
		endif
	endif
	AppendToGraph/W=IR2Pr_PDFInputGraph Intensity vs Q_vec
	AppendToGraph/W=IR2Pr_PDFInputGraph PDFFitIntensity vs Q_vec
	AppendToGraph/W=IR2Pr_PDFInputGraph BackgroundWave vs Q_vecOriginal
	AppendToGraph/W=IR2Pr_PDFInputGraph IntensityOriginal vs Q_vecOriginal
	AppendToGraph/W=IR2Pr_PDFInputGraph/L=ChisquaredAxis NormalizedResidual vs Q_vec
	ModifyGraph/W=IR2Pr_PDFInputGraph log(left)=1
	ModifyGraph/W=IR2Pr_PDFInputGraph log(bottom)=1
	ModifyGraph/W=IR2Pr_PDFInputGraph log(top)=GraphLogTopAxis
	ModifyGraph/W=IR2Pr_PDFInputGraph log(right)=GraphLogRightAxis
	Label/W=IR2Pr_PDFInputGraph top "Distance [A]"
	ModifyGraph/W=IR2Pr_PDFInputGraph lblMargin(top)=30,lblLatPos(top)=100
	Label/W=IR2Pr_PDFInputGraph right "Pair distribution function"
	Label/W=IR2Pr_PDFInputGraph left "Intensity"
	ModifyGraph/W=IR2Pr_PDFInputGraph lblPos(left)=50
	ModifyGraph/W=IR2Pr_PDFInputGraph lblMargin(right)=20
	Label/W=IR2Pr_PDFInputGraph bottom "Q [A\\S-1\\M]"	
	ModifyGraph/W=IR2Pr_PDFInputGraph axisEnab(left)={0.15,1}
	ModifyGraph/W=IR2Pr_PDFInputGraph axisEnab(right)={0.15,1}
	ModifyGraph/W=IR2Pr_PDFInputGraph lblMargin(top)=30
	ModifyGraph/W=IR2Pr_PDFInputGraph axisEnab(ChisquaredAxis)={0,0.15}
	ModifyGraph/W=IR2Pr_PDFInputGraph freePos(ChisquaredAxis)=0
	Label/W=IR2Pr_PDFInputGraph ChisquaredAxis "Residuals"
	ModifyGraph/W=IR2Pr_PDFInputGraph lblPos(ChisquaredAxis)=50,lblLatPos=0
	ModifyGraph/W=IR2Pr_PDFInputGraph mirror(ChisquaredAxis)=1
	SetAxis/W=IR2Pr_PDFInputGraph /A/E=2 ChisquaredAxis
	ModifyGraph/W=IR2Pr_PDFInputGraph nticks(ChisquaredAxis)=3

	ModifyGraph/W=IR2Pr_PDFInputGraph mode(Intensity)=3,marker(Intensity)=5,msize(Intensity)=3
	
	Cursor/P/W=IR2Pr_PDFInputGraph A IntensityOriginal, csrApos
	Cursor/P/W=IR2Pr_PDFInputGraph B IntensityOriginal, csrBpos
	
	ModifyGraph/W=IR2Pr_PDFInputGraph rgb(PDFFitIntensity)=(0,0,52224)	
	ModifyGraph/W=IR2Pr_PDFInputGraph  lsize(PDFFitIntensity)=3	
	ModifyGraph/W=IR2Pr_PDFInputGraph lstyle(BackgroundWave)=3

	ModifyGraph/W=IR2Pr_PDFInputGraph mode(IntensityOriginal)=3
	ModifyGraph/W=IR2Pr_PDFInputGraph msize(IntensityOriginal)=2
	ModifyGraph/W=IR2Pr_PDFInputGraph rgb(IntensityOriginal)=(0,52224,0)
	ModifyGraph/W=IR2Pr_PDFInputGraph zmrkNum(IntensityOriginal)={DeletePointsMaskWave}
	ErrorBars/W=IR2Pr_PDFInputGraph IntensityOriginal Y,wave=(DeletePointsMaskErrorWave,DeletePointsMaskErrorWave)

	ModifyGraph/W=IR2Pr_PDFInputGraph mode(CurrentResultPdf)=5
	ModifyGraph/W=IR2Pr_PDFInputGraph hbFill(CurrentResultPdf)=4	
	ModifyGraph/W=IR2Pr_PDFInputGraph useNegRGB(CurrentResultPdf)=1
	ModifyGraph/W=IR2Pr_PDFInputGraph usePlusRGB(CurrentResultPdf)=1
	ModifyGraph/W=IR2Pr_PDFInputGraph hbFill(CurrentResultPdf)=12
	ModifyGraph/W=IR2Pr_PDFInputGraph plusRGB(CurrentResultPdf)=(32768,65280,0)
	ModifyGraph/W=IR2Pr_PDFInputGraph negRGB(CurrentResultPdf)=(32768,65280,0)
	ModifyGraph/W=IR2Pr_PDFInputGraph  lblMargin(right)=41,lblMargin(top)=20
	ModifyGraph/W=IR2Pr_PDFInputGraph  lblPos(left)=75,lblPos(ChisquaredAxis)=77
	ModifyGraph/W=IR2Pr_PDFInputGraph  lblLatPos(right)=1,lblLatPos(top)=-45,lblLatPos(left)=-14,lblLatPos(ChisquaredAxis)=-6
	ModifyGraph/W=IR2Pr_PDFInputGraph  freePos(ChisquaredAxis)=0
	ModifyGraph/W=IR2Pr_PDFInputGraph  axisEnab(right)={0.15,1}
	ModifyGraph/W=IR2Pr_PDFInputGraph  axisEnab(left)={0.15,1}
	ModifyGraph/W=IR2Pr_PDFInputGraph  axisEnab(ChisquaredAxis)={0,0.15}

	ModifyGraph/W=IR2Pr_PDFInputGraph mode(NormalizedResidual)=3,marker(NormalizedResidual)=19
	ModifyGraph/W=IR2Pr_PDFInputGraph msize(NormalizedResidual)=1
	TextBox/W=IR2Pr_PDFInputGraph/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	
	NVAR Chisquare=root:Packages:Irena_PDDF:CurrentChiSq
	variable/G FittedNumberOfpoints=numpnts(Intensity)
	SetVariable Chisquared size={180,15}, pos={400,5}, title="Chisquared reached", win=IR2Pr_PDFInputGraph
	SetVariable Chisquared limits={-Inf,Inf,0},value= root:Packages:Irena_PDDF:CurrentChiSq, win=IR2Pr_PDFInputGraph
	SetVariable NumFittedPoints size={180,15}, pos={400,25}, title="Number of fitted points", win=IR2Pr_PDFInputGraph
	SetVariable NumFittedPoints limits={-Inf,Inf,0},value= root:Packages:Irena_PDDF:FittedNumberOfpoints, win=IR2Pr_PDFInputGraph

	variable legendSize=str2num(IN2G_LkUpDfltVar("LegendSize"))
	IN2G_GenerateLegendForGraph(legendSize,0,1)
	Legend/J/C/N=Legend1/J/A=LB/X=-8/Y=-8/W=IR2Pr_PDFInputGraph
	string LegendText2="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("TagSize")+"\K(0,0,65280)Method used: "+MethodRun+"\r"
	if(numtype(NumberIterations)!=0)
		LegendText2+="No success, change parameters and run again"
	elseif(NumberIterations==0)
		LegendText2+="working...."
//	elseif(cmpstr(MethodRun,"MaxEnt")==0 && (NumberIterations>=MaxsasNumIter))
//		LegendText2+="No success, change parameters and run again"
	else
		LegendText2+="Number of iterations ="+num2str(NumberIterations)				
	endif

	TextBox/C/F=0/N=Legend2/X=0.00/Y=-14.00 LegendText2

	DoUpdate						//and here we again record what we have done


	//Create Gamma plot.
	Wave/Z CurrentResultsGamma=root:Packages:Irena_PDDF:CurrentResultsGamma
	if(WaveExists(CurrentResultsGamma ))
		DoWindow IR2PR_GammaFunction
		if(!V_Flag)
			Display/K=1 /W=(92,155,635,463)  CurrentResultsGamma vs R_distribution as "Gamma distribution"
			DoWindow/C IR2PR_GammaFunction
			ModifyGraph mode=3
			ModifyGraph mirror=1
			Label left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Gamma(r) = pdf(r)/(4*pi*r^2)"
			Label bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Distance [A]"
			SetAxis left 0,*
		endif	
	endif
	setDataFolder OldDf
end

//***********************************************************************************************************
//***********************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR2Pr_ShrinkGMatrixAfterSmear()		//this shrinks the G_matrix and Q_vec back
												//Errors are used to get originasl length

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

	Wave G_matrix=root:Packages:Irena_PDDF:G_matrix
	Wave Q_vec=root:Packages:Irena_PDDF:Q_vec
	Wave Errors=root:Packages:Irena_PDDF:Errors
	
	variable OldLength=numpnts(Errors)				//this is old number of points (Erros length did not change during smearing)
	
	redimension/N=(OldLength) Q_vec				//this shrinks the Q_veck to old length
	
	redimension/N=(OldLength,-1) G_matrix			//this shrinks the G_matrix to original number of rows, columns stay same

	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR2Pr_SmearGMatrix()			//this function smears the colums in the G matrix

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

	Wave G_matrix=root:Packages:Irena_PDDF:G_matrix
	Wave Q_vec=root:Packages:Irena_PDDF:Q_vec
	NVAR SlitLength=root:Packages:Irena_PDDF:SlitLength

	variable M=DimSize(G_matrix, 0)							//rows, i.e, measured points 
	variable N=DimSize(G_matrix, 1)							//columns, i.e., bins in radius distribution
	variable i=0
	Make/D/O/N=(M) tempOrg, tempSmeared									//points = measured Q points

	for (i=0;i<N;i+=1)					//for each column (radius point)
		tempOrg=G_matrix[p][i]			//column -> temp
		
		//IR2Pr_SmearData(tempOrg, Q_vec, slitLength, tempSmeared)			//temp is smeared (Q_vec, SlitLength) ->  tempSmeared
		IR1B_SmearData(tempOrg, Q_vec, slitLength, tempSmeared)			//this is more optimized version
	
		G_matrix[][i]=tempSmeared[p]		//column in G is set to smeared value
	endfor

	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

////*****************************This function smears data***********************
//static  Function IR2Pr_SmearData(Int_to_smear, Q_vec_sm, slitLength, Smeared_int)
//	wave Int_to_smear, Q_vec_sm, Smeared_int
//	variable slitLength
//
//	string OldDf
//	OldDf=GetDataFolder(1)
//	setDataFolder root:Packages:Irena_PDDF
//	
//	Make/D/O/N=(0.5*numpnts(Q_vec_sm)) Smear_Q, Smear_Int							
//		//Q's in L spacing and intensitites in the l's will go to Smear_Int (intensity distribution in the slit, changes for each point)
//
//	variable DataLengths=numpnts(Q_vec_sm)
//	
//	Smear_Q=1.1*slitLength*(Q_vec_sm[2*p]-Q_vec_sm[0])/(Q_vec_sm[DataLengths-1]-Q_vec_sm[0])		//create distribution of points in the l's which mimics the aroginal distribution of pointsd
//	//the 1.1* added later, because without it I di dno  cover the whole slit length range... 
//	variable i=0
//	
//	For(i=0;i<DataLengths;i+=1) 
//		Smear_Int=interp(sqrt((Q_vec_sm[i])^2+(Smear_Q[p])^2), Q_vec_sm, Int_to_smear)		//put the distribution of intensities in the slit for each point 
//		Smeared_int[i]=areaXY(Smear_Q, Smear_Int, 0, slitLength) 							//integrate the intensity over the slit 
//	endfor
//
//	Smeared_int*= 1 / slitLength															//normalize
//	
//	KillWaves/Z Smear_Int, Smear_Q														//cleanup temp waves
//	setDataFolder OldDf
//end
////**************End common******************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static  Function IR2Pr_FinishSetupOfRegParam()			//Finish the preparation for parameters selected in the panel

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_PDDF
	
	Wave DeletePointsMaskWave	=root:Packages:Irena_PDDF:DeletePointsMaskWave
	Wave IntensityOriginal			=root:Packages:Irena_PDDF:IntensityOriginal
	Wave/Z Intensity				=root:Packages:Irena_PDDF:Intensity
	Wave/Z Q_vec					=root:Packages:Irena_PDDF:Q_vec
	Wave Q_vecOriginal				=root:Packages:Irena_PDDF:Q_vecOriginal
	Wave/Z Errors					=root:Packages:Irena_PDDF:Errors
	Wave ErrorsOriginal			=root:Packages:Irena_PDDF:ErrorsOriginal
//	SVAR SizesParameters		=root:Packages:Irena_PDDF:SizesParameters				
//	SVAR LogDist					=root:Packages:Irena_PDDF:LogBinning
	NVAR SlitSmearedData			=root:Packages:Irena_PDDF:UseSMRData
	NVAR Bckg						=root:Packages:Irena_PDDF:Background
	NVAR numOfPoints				=root:Packages:Irena_PDDF:NumberOfBins
//	NVAR Rmin						=root:Packages:Irena_PDDF:MinimumR
	NVAR Rmax						=root:Packages:Irena_PDDF:MaximumR
//	NVAR ScatteringContrast		=root:Packages:Sizes:ScatteringContrast
	NVAR ErrorsMultiplier			=root:Packages:Irena_PDDF:ErrorMultiplier
	NVAR SlitLength					=root:Packages:Irena_PDDF:SlitLength
	
//	NVAR NNLS_MaxNumIterations	=root:Packages:Sizes:NNLS_MaxNumIterations
//	NVAR NNLS_ApproachParameter	=root:Packages:Sizes:NNLS_ApproachParameter
	NVAR UseRegularization		=root:Packages:Irena_PDDF:UseRegularization
	NVAR UseMaxEnt			=root:Packages:Irena_PDDF:UseMoore
// NVAR UseTNNLS			=root:Packages:Sizes:UseTNNLS


	NVAR UseUserErrors			=root:Packages:Irena_PDDF:UseUserErrors
	NVAR UseSQRTErrors			=root:Packages:Irena_PDDF:UseSQRTErrors
	NVAR UsePercentErrors			=root:Packages:Irena_PDDF:UsePercentErrors
//	NVAR UseNoErrors				=root:Packages:Irena_PDDF:UseConstantErrors

	NVAR PercentErrorToUse		=root:Packages:Irena_PDDF:PercentErrorsValue

	Duplicate/O IntensityOriginal, Intensity, NormalizedResidual	//here we return in the original data, which will be trimmed next
	redimension/D Intensity
	Duplicate/O Q_vecOriginal, Q_vec
	Redimension/D Q_vec
	Duplicate/O ErrorsOriginal, Errors
	Redimension/D Errors
	if(UseUserErrors)
		Errors=ErrorsMultiplier*ErrorsOriginal						//mulitply the erros by user selected multiplier
	elseif(UseSQRTErrors)
		Errors=sqrt(Intensity)* ErrorsMultiplier						//sqrt of intensity requested by user
		Smooth 5, Errors
	elseif(UsePercentErrors)
		Errors=Intensity*PercentErrorToUse/100						//% of intensity requested by user
		Smooth 5, Errors
//	elseif(UseNoErrors)
//		Errors=1													//should be equivavlent to no errors at all
	else
		Errors=1													//should be equivavlent to no errors at all
	endif


	Intensity=Intensity*(DeletePointsMaskWave/7)				//since DeletePointsMaskWave contains NaNs for points which we want to delete
															//at this moment we set these points in intensity to NaNs
	Intensity=Intensity-Bckg									//subtract background from Intensity
	if ( ((strlen(CsrWave(A))!=0) && (strlen(CsrWave(B))!=0) ) && (pcsr (A)!=pcsr (B)) )	//this should make sure, that both cursors are in the graph and not on the same point
		//make sure the cursors are on the right waves..
		IR2Pr_TrimData(Intensity,Q_vec,Errors)					//this trims the data with cursors
	endif
	IN2G_RemoveNaNsFrom3Waves(Intensity,Q_vec,Errors)		//this should remove NaNs from the important waves
//	Rmax=Dmax/2										//create radia from user input
//	Rmin=Dmin/2
	make /D/O/N=(numOfPoints) R_distribution, temp		//this part creates the distribution of radia
//	if (cmpstr(LogDist,"no")==0)							//linear binninig
	R_distribution=p*((Rmax)/(numOfPoints-1))
//	else													//log binnning (default)
//		temp=log(Rmin)+p*((log(Rmax)-log(Rmin))/(numOfPoints-1))
//		R_distribution=10^temp
//	endif
	Killwaves/Z temp										//kill this wave, not needed anymore
	Duplicate/O R_distribution  ModelDistribution, InitialModelBckg	//and create the Diameter distribution wave and modelWave
	Redimension/D R_Distribution
	NVAR StartFitQvalue
	StartFitQvalue=Q_vec[0]
	NVAR EndFitQvalue
	EndFitQvalue=Q_vec[numpnts(Q_vec)-1]

	setDataFolder oldDf
end

//*********************************************************************************************
//*********************************************************************************************
//*****************************************************************************************************************
//*********************************************************************************************
//*********************************************************************************************

static  Function IR2Pr_TrimData(wave1, wave2, wave3) 				//this is local trimming procedure
	Wave wave1, wave2, wave3
	
	variable AP=pcsr (A)
	variable BP=pcsr (B)
	
	deletePoints 0, AP, wave1, wave2, wave3
	variable newLength=numpnts(wave1)
	deletePoints (BP-AP+1), (newLength),  wave1, wave2, wave3
End

////*********************************************************************************************
////*********************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR2Pr_ExtendQVecForSmearing()		//this is function extends the Q vector for smearing

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

	Wave Q_vec=root:Packages:Irena_PDDF:Q_vec
	NVAR SlitLength=root:Packages:Irena_PDDF:SlitLength

	variable OldPnts=numpnts(Q_vec)
	variable qmax=Q_vec[OldPnts-1]
	variable newNumPnts=0
	
	Duplicate/O Q_vec, TempWv	
	Redimension/D TempWv
	TempWv=log(Q_vec)

	if (qmax<SlitLength)
		NewNumPnts=numpnts(Q_vec)
	else
		NewNumPnts=numpnts(Q_vec)-BinarySearch(Q_vec, (Q_vec[OldPnts-1]-SlitLength) )
	endif
	
	if (NewNumPnts<10)
		NewNumPnts=10
	endif
	
	Make/O/D/N=(NewNumPnts) Extension
	Extension=Q_vec[OldPnts-1]+p*(SlitLength/NewNumPnts)
	Redimension /N=(OldPnts+NewNumPnts) Q_vec
	Q_vec[OldPnts, OldPnts+NewNumPnts-1]=Extension[p-OldPnts]
	
	KillWaves/Z TempWv, Extension

	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2Pr_SetExportGNOMoutFile()
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_PDDF
	
	NewPath/O/Q/M="Select path for saving GNOM output files" GNOMOutputPath



	SetDataFolder oldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2Pr_ExportGNOMoutFile()
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_PDDF
	
	PathInfo GNOMOutputPath
	if(V_Flag==0)
		IR2Pr_SetExportGNOMoutFile()
	endif
	
	SVAR DataFolderName = root:Packages:Irena_PDDF:DataFolderName
//	SVAR MethodRun = root:Packages:Irena_PDDF:MethodRun
//	NVAR Evalue = root:Packages:Irena_PDDF:Evalue
	string FlNm=cleanupName(stringFromList(ItemsInList(DataFolderName,":")-1,DataFolderName,":"),0)
	FlNm=IN2G_RemoveExtraQuote(FlNm,1,1)		//OK, now we have output name which should be OK... 
	FlNm=FlNm+".out"
	variable refnum
	Do
		Open/Z=1/R/P=GNOMOutputPath refnum as FlNm
		if(V_Flag==0)
			DoAlert 2, "The file with this name: "+FlNm+ " in this location already exists, overwrite (Yes) or rename (No) or Cancel?"
			if(V_Flag==1)
				close/A
				//user wants to delete the file
				OpenNotebook/V=0/P=GNOMOutputPath/N=JunkNbk  FlNm
				DoWindow/D /K JunkNbk
			elseif(V_Flag==2)
				string FlNmL=FlNm
				Prompt FlNmL, "Modify the name for output file"
				DoPrompt "Modify the name", FlNmL
				if(V_Flag)
					abort
				endif
				FlNmL=ReplaceString(".out", FlNmL, "")
				FlNm = cleanupName(FlNmL,0)
				FLNm=FLNm+".out"
			else
				abort
			endif
		else
			break
		endif
	while (1)
	close/A

	SVAR DataFileName=root:Packages:Irena_PDDF:DataFolderName
	SVAR DataName=root:Packages:Irena_PDDF:IntensityWaveName
	Wave PDDF=root:Packages:Irena_PDDF:CurrentResultPdf
	Wave PDDF_err=root:Packages:Irena_PDDF:PDDFErrors
	Wave Radii = root:Packages:Irena_PDDF:R_distribution
	Wave J_vec = root:Packages:Irena_PDDF:Intensity
	Wave S_vec=root:Packages:Irena_PDDF:Q_vec
	Wave Error=root:Packages:Irena_PDDF:Errors
	Wave Jreg_Ireg=root:Packages:Irena_PDDF:PDFFitIntensity
	IR2Pr_GenerateMissingData()
	Wave MissingInt=root:Packages:Irena_PDDF:MissingInt
	Wave MissingQ=root:Packages:Irena_PDDF:MissingQ
	NVAR Intensity_0=root:Packages:Irena_PDDF:Intensity_0
	variable MinSize=Radii[0]
	variable MaxSize= Radii[numpnts(Radii)-1]
	NVAR CurrentRg = root:Packages:Irena_PDDF:CurrentRg
	NVAR CurrentRgError=root:Packages:Irena_PDDF:CurrentRgError
	
	string TempStr=""
	String nb = "GNOM_OUT"
	NewNotebook/N=$nb/F=0/V=1/K=0/W=(573,44,1415,812)
	Notebook $nb defaultTab=20, statusWidth=252, pageMargins={72,72,72,72}
	Notebook $nb text="\r"
	Notebook $nb text="           ####    G N O M   ---    Version 4.4       ####\r"			//must stay as it is
	Notebook $nb text="\r"
	Notebook $nb text="                                                   "+IR2Pr_CreateGNOMDate()+"\r"		//this works... 
	Notebook $nb text="           ===    Run No   1   ===\r"
	Notebook $nb text=" Run title:  "+DataFileName+DataName+"\r"		//OK, this works
	Notebook $nb text="\r"
	Notebook $nb text="\r"
	Notebook $nb text="   *******    Input file(s) : "+DataName+"\r"		//Ok, this works also
	Notebook $nb text="           Condition P(rmin) = 0 is used. \r"
	Notebook $nb text="           Condition P(rmax) = 0 is used. \r"
	Notebook $nb text="\r"
	Notebook $nb text="          Highest ALPHA is found to be   1\r"		//this works fine also, this package does nto report ALPHA... 
	Notebook $nb text="\r"
	Notebook $nb text="\r"
	Notebook $nb text="\r"
	Notebook $nb text="\r"
	Notebook $nb text="             ####            Final results            ####\r"
	Notebook $nb text="\r"
	sprintf TempStr, "   Angular   range    :     from    %0.4f   to    %0.4f\r" , S_vec[0], S_vec[numpnts(S_vec)-1]
	Notebook $nb text=TempStr
	sprintf TempStr, "  Real space range   :     from      %0.2f   to    %0.2f\r" , MinSize, maxSize
	Notebook $nb text=TempStr
	Notebook $nb text="\r"
	Notebook $nb text="  Current ALPHA         : "+IR2Pr_FormatNumber(1, 2)+"   Rg :  "+IR2Pr_FormatNumber(CurrentRg, 3)+"   I(0) : "+IR2Pr_FormatNumber(Intensity_0, 3)+"\r"		//OK, seems like formating here works when changed. 
	Notebook $nb text=TempStr
	Notebook $nb text="\r"
	Notebook $nb text="\r"
	Notebook $nb text="      S          J EXP       ERROR       J REG       I REG\r"
	Notebook $nb text="\r"

	variable i
	For(i=0;i<numpnts(MissingInt);i+=1)
		Notebook $nb text=IR2Pr_FormatNumber(MissingQ[i],4)+"                                    "+IR2Pr_FormatNumber(MissingInt[i],4)+"\r"
	endfor
	For(i=0;i<numpnts(J_vec);i+=1)
		Notebook $nb text=IR2Pr_FormatNumber(S_vec[i],4)+IR2Pr_FormatNumber(J_vec[i], 4)+IR2Pr_FormatNumber(Error[i], 4)+IR2Pr_FormatNumber(Jreg_Ireg[i], 4)+IR2Pr_FormatNumber(Jreg_Ireg[i], 4)+"\r" 
	endfor
	Notebook $nb text="\r"
	Notebook $nb text="           Distance distribution  function of particle  \r"
	Notebook $nb text="\r"
	Notebook $nb text="\r"
	Notebook $nb text="       R          P(R)      ERROR\r"
	Notebook $nb text="\r"
	For(i=0;i<numpnts(Radii);i+=1)
		Notebook $nb text=IR2Pr_FormatNumber(Radii[i],4)+IR2Pr_FormatNumber(PDDF[i],4)+IR2Pr_FormatNumber(PDDF_err[i],4)+"\r" 
	endfor
	Notebook $nb text="          Reciprocal space: Rg =   "+num2str(CurrentRg)+"     , I(0) ="+IR2Pr_FormatNumber(Intensity_0,4)+"\r"
	Notebook $nb text="     Real space: Rg =   "+num2str(CurrentRg)+" +-"+IR2Pr_FormatNumber(0,3)+"   I(0) = "+IR2Pr_FormatNumber(Intensity_0,4)+" +-  0.000E+00\r"

	SaveNotebook /O/P=GNOMOutputPath /S=6  GNOM_OUT as FlNm
	KillWIndow/Z GNOM_OUT
	PathInfo GNOMOutputPath
	Print "GNOM data output was saved to :       "+S_path+FlNm
	close/A
	SetDataFolder oldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function/S IR2Pr_CreateGNOMDate()

	string FinalDate
	string temp1=Secs2Date(DateTime,2)	//Mon, Mar 15, 1993
	string temp2=Secs2Time(DateTime,3)
	FinalDate = stringFromList(0,temp1,",")+stringFromList(1,temp1,",")+" "+temp2+stringFromList(2,temp1,",")
	return FinalDate
end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2Pr_GenerateMissingData()
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_PDDF
	Wave S_vec=root:Packages:Irena_PDDF:Q_vec
	Wave PDDF=root:Packages:Irena_PDDF:CurrentResultPdf
	Wave Radii = root:Packages:Irena_PDDF:R_distribution
	variable step=S_vec[1]-S_vec[0]
	variable Numpoints=round(S_vec[0]/(step))
	step = S_vec[0] / Numpoints
	Make/O/N=(Numpoints) MissingInt, MissingQ
	MissingQ=step*p
	variable i
	Duplicate/O  PDDF, PDDF_temp
	For(i=0;i<NumPoints;i+=1)
		PDDF_temp = 4*pi*sinc(MissingQ[i]*Radii[p])*PDDF[p]
		MissingInt[i]=sum(PDDF_temp)*(Radii[1]-Radii[0])
	endfor
	
	variable/g Intensity_0
	Intensity_0 = MissingInt[0]
//	print Intensity_0
	KillWaves/Z PDDF_temp
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function/S IR2Pr_FormatNumber(num, numDigits)
	variable num, numDigits
	variable isNegative
	isNegative=  num<0 ? 1 : 0 
	if(isNegative)
		num*=-1
	endif	//OK, now is positive and we know about its sign... 
	string tempStr
	sprintf tempStr, "%0."+num2str(numDigits-1)+"E", num
	string Mant=StringFromList(0, tempStr , "E")
	Mant = ReplaceString(".", Mant, "")
	string Expn=StringFromList(1, tempStr , "E")
	variable ExpnV=str2num(Expn)+1
	if(ExpnV>9)
		Expn="+"+num2str(ExpnV)
	elseif(ExpnV>=0)
		Expn="+0"+num2str(ExpnV)
	elseif(ExpnV>-10)
		Expn="-0"+num2str(-1*ExpnV)	
	else
		Expn="-"+num2str(-1*ExpnV)
	endif
	string outStr=" "
	if(isNegative)
		outStr+="-0."
	else
		outStr+=" 0."
	endif	
	outStr+=Mant+"E"+Expn
	return  outStr
end
//or:
//function /s ASCIIforFortran(num)
//	variable num
//	
//	variable exponent=floor(log(abs(num))+1)
//	variable base=num*10^-exponent
//	
//	string s_out
//	
//	sprintf s_out, "%6.4fE%+2.2d\r" , base, exponent
//	
//	return s_out
//end
//

	
//	or:
//	
//function testPrintF (theWave)
//	wave thewave
//	
//	variable ii, nP = numpnts (theWave)
//	variable theVal, expVal
//	string tStr
//	for (ii =0; ii < nP; ii += 1)
//		theVal = theWave [ii]
//		sprintf tStr, "%+1.3E\r", theVal
//		// tStr is 11 characters long, and has wrong decimal place, and needs to start with 0
//		// swap decimal place, and add 0.
//		tStr [1,2] = "0." + tStr [1]
//		//Now tSTr is 12 characters wide, and starts with a 0, but exp is off by 1
//		tStr [10,11] = padstring (num2str (str2num (tStr [10,11]) + 1), 2, 0)
//		print tStr
//	endfor
//end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2Pr_DoInternalRegularization()

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

	//Now we need to create new waves with data scaled by Int^N to provide fitting in more ballanced space...
	Wave Q_vec=root:Packages:Irena_PDDF:Q_vec
	Wave Intensity=root:Packages:Irena_PDDF:Intensity
	Wave Errors=root:Packages:Irena_PDDF:Errors
	Wave G_matrix=root:Packages:Irena_PDDF:G_matrix

		IR2Pr_MakeHmatrix()				//creates H matrix
		
		IR2Pr_CalculateBVector()			//creates B vector
	
		IR2Pr_CalculateDMatrix()			//creates D matrix
	
//		IR2Pr_SetupDiagnostics()			//setup diagnostics graphs if needed
	
		NVAR Evalue=root:Packages:Irena_PDDF:Evalue
		NVAR NumberIterations=root:Packages:Irena_PDDF:NumberIterations

		NumberIterations=IR2Pr_FindOptimumAvalue(Evalue)	//does the  fitting for given e value, for now set here to a value 0.1

		Wave CurrentResultPdf = root:Packages:Irena_PDDF:CurrentResultPdf
		Wave PDFFitIntensity=root:Packages:Irena_PDDF:PDFFitIntensity
		Wave NormalizedResidual=root:Packages:Irena_PDDF:NormalizedResidual

		NVAR Chisquare=root:Packages:Irena_PDDF:Chisquare
	
		if ((numtype(NumberIterations)!=0)||(numberIterations>numpnts(PDFFitIntensity)))	//no solution found
			PDFFitIntensity=0
			CurrentResultPdf = 0
			NormalizedResidual = 0
			Chisquare = 0			//new Chisquared
		endif
		setDataFolder OldDf
	
end 
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR2Pr_FindOptimumAvalue(Evalue)						//does the fitting itself, call with precision (e~0.1 or so)
	variable Evalue	

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

	Wave Intensity=root:Packages:Irena_PDDF:Intensity
	Wave Errors=root:Packages:Irena_PDDF:Errors
	Wave R_distribution=root:Packages:Irena_PDDF:R_distribution
	NVAR NumberIterations=root:Packages:Irena_PDDF:NumberIterations

	variable LogAmax=100, LogAmin=-100, M=numpnts(Intensity)
	variable tolerance=Evalue*sqrt(2*M)
	variable Chisquared, MidPoint, Avalue, i=0, logAval, LogChisquarerdDivN, Smoothness, priorChisquared=1e10
	NumberIterations=0
	do
		MidPoint=(LogAmax+LogAmin)/2
		Avalue=10^MidPoint								//calculate A
		IR2Pr_CalculateAmatrix(Avalue)
		Wave A_matrix
//		MatrixLUD A_matrix								//decompose A_matrix 
//		Wave M_Lower									//results in these matrices for next step:
//		Wave M_Upper
//		Wave W_LUPermutation
		Wave B_vector
//		MatrixLUBkSub M_Lower, M_Upper, W_LUPermutation, B_vector				//Backsubstitute B to get x[]=inverse(A[][]) B[]	
 		MatrixLinearSolve/M=1 A_matrix  B_vector
		Wave M_B
		Duplicate/O M_B, M_x
		//Wave M_x=M_B										//this is created by MatrixMultiply

		Redimension/D/N=(-1,0) M_x							//create from M_x[..][0] only M_x[..] so it is simple wave
		Duplicate/O M_x CurrentResultPdf					//put the data into the wave 
		Note/K CurrentResultPdf
		Note CurrentResultPdf, note(intensity)
		
		//Need to fix binning effect, if it was not accounted for in G matrix we need to take bin width out now...
		variable iv
		Wave CurrentResultPdf = root:Packages:Irena_PDDF:CurrentResultPdf
		For(iv=0;iv<numpnts(ModelDistribution);iv+=1)
			CurrentResultPdf[iv] = CurrentResultPdf[iv] / IR2Pr_BinWidthInRadia(iv)
		endfor
		Chisquared=IR2Pr_CalculateChisquared()				//Calculate C 	C=|| I - G M_x ||
		
		Wave PDFFitIntensity=root:Packages:Irena_PDDF:PDFFitIntensity		//produced by IR1R_CalculateChisquared
		Duplicate/O CurrentResultPdf, diffWave
		Duplicate/O R_distribution, diffWaveX
		Differentiate diffWave
		Differentiate diffWaveX
		diffWave=abs(diffWave)/abs(diffWaveX)		//this is suppose to create derivative of the CurrentSizeDistribution
		Smoothness=sum(diffWave,-inf,inf)
//		NVAR CurrentEntropy=root:Packages:Sizes:CurrentEntropy
		NVAR CurrentChiSq=root:Packages:Irena_PDDF:CurrentChiSq
		NVAR CurChiSqMinusAlphaEntropy=root:Packages:Irena_PDDF:CurChiSqMinusAlphaEntropy
		Duplicate/O PDFFitIntensity, zscratch2
		
		zscratch2 = (( Intensity[p] - PDFFitIntensity[p]) / Errors[p])^2	//residuals
		CurrentChiSq = sum(zscratch2)			//new Chisquared
		
		CurChiSqMinusAlphaEntropy=CurrentChiSq - tolerance*Smoothness
		KillWaves/Z diffWave, diffWaveX, zscratch2	
		IR2Pr_FinishGraph()
		DoUpdate

//		print "("+num2str(i+1)+")     Chi squared value:  " + num2str(Chisquarered) + ",    target value:   "+num2str(M)
  
		if (Chisquared>M)
			LogAMax=MidPoint
		else
			LogAmin=MidPoint
		endif
		i+=1
		if (i>M || (Chisquared - PriorChisquared)==0)											//no solution found
			return NaN
		endif
		NumberIterations+=1
		PriorChisquared = Chisquared
	while(abs(Chisquared-M)>tolerance)				//how much can I divide 200 points interval before it is useless?
	
	NVAR Chisquare=root:Packages:Irena_PDDF:Chisquare
	Chisquare=Chisquared
	NVAR Background=root:Packages:Irena_PDDF:Background
	NVAR maximumR=root:Packages:Irena_PDDF:maximumR

	variable/g CurrentRg=IR2Pr_regRg(CurrentResultPdf,R_distribution)
	variable/g CurrentRgError=NaN
	string FitNote="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("TagSize")+"Fit using Regularization "
	Fitnote+="\rMaximum extent = "+num2str(maximumR)+"  A"//+" ± "+num2str(MooreParametersS[Moore_NumOfFncts+2])+" ≈"
//	Fitnote+="\r"+num2str(Moore_NumOfFncts)+" basis functions used"
//	fitnote+="\rScale Factor = "+num2str(MooreParametersV[Moore_NumOfFncts+3])+" ± "+num2str(MooreParametersS[Moore_NumOfFncts+3])
	fitnote+="\rRadius of Gyration = "+num2str(CurrentRg)+"  A"
	Fitnote+="\rBackground = "+num2str(Background)
//	Fitnote+="\rReduced Chi Squared "+num2str(Chisquared/(numpnts(Intensity)-1))
	print fitnote
	string/g FittingResults
	FittingResults=FitNote
	TextBox/W=IR2Pr_PDFInputGraph/C/N=MooreFitNote/A=MC fitnote 

	return i
	SetDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2Pr_PDDFCalculatePrVariation()

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF
	Wave Intensity=root:Packages:Irena_PDDF:Intensity
	Wave Errors=root:Packages:Irena_PDDF:Errors
	Wave R_distribution=root:Packages:Irena_PDDF:R_distribution
	NVAR Evalue=root:Packages:Irena_PDDF:Evalue

	//Wave M_Lower									//results in these matrices for next step:
	//Wave M_Upper
	//Wave W_LUPermutation
	Wave A_matrix
	Wave G_matrix	=root:Packages:Irena_PDDF:G_matrix
	Duplicate/O R_distribution, BinWidth, PDDFErrors
	BinWidth = IR2Pr_BinWidthInRadia(p)
	//and here we need to do the MonteCarlo method... 
	variable i, MontCarloMax=100		//number of MonteCarlo iterations
	Duplicate/O Intensity, MontIntensity
	Make/O/N=(numpnts(R_distribution), (MontCarloMax)) MontStatWave
	For(i=0;i<MontCarloMax;i+=1)
		MontIntensity = Intensity+gNoise(1)*Errors	//this will create new intensity - original + Gaussian e-noise * Error, practically ideal, if this is proper Sdev error... 
		MatrixOp/O B_vector = G_matrix^t x (MontIntensity /(Errors*Errors))	
		Wave B_vector
		//MatrixLUBkSub M_Lower, M_Upper, W_LUPermutation, B_vector				//Backsubstitute B to get x[]=inverse(A[][]) B[]	
		MatrixLinearSolve/M=1 A_matrix, B_vector
		Wave M_B																		//this is created by MatrixLUBkSub
		Redimension/D/N=(-1,0) M_B													//create from M_x[..][0] only M_x[..] so it is simple wave
		MatrixOp/O CurrentResultMontCarlo = M_B / BinWidth
		MontStatWave[][i]=CurrentResultMontCarlo[p]
	endfor
	
	For(i=0;i<Numpnts(R_distribution);i+=1)
		Duplicate/O/R=[i][] MontStatWave, testWv
		wavestats/Q testWv
		PDDFErrors[i] = V_sdev
	endfor
//	MatrixOP/O RegPDFErrors = varCols(MontStatWave)
//	MatrixOP/O RegPDFErrors = RegPDFErrors^t
	KillWaves/Z  testWv, MontStatWave, BinWidth, CurrentResultMontCarlo
	SetDataFolder OldDf

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
 static Function IR2Pr_BinWidthInRadia(i)			//calculates the width in radia by taking half distance to point before and after
	variable i								//returns number in A

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

	Wave R_distribution=root:Packages:Irena_PDDF:R_distribution
	variable width
	variable Imax=numpnts(R_distribution)
	
	if (i==0)
		width=R_distribution[1]-R_distribution[0]
	elseif (i==Imax-1)
		width=R_distribution[i]-R_distribution[i-1]
	else
		width=((R_distribution[i]-R_distribution[i-1])/2)+((R_distribution[i+1]-R_distribution[i])/2)
	endif
	return width
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR2Pr_CalculateAmatrix(aValue)					//generates A matrix
	variable aValue

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

	Wave D_matrix=root:Packages:Irena_PDDF:D_matrix
	Wave H_matrix=root:Packages:Irena_PDDF:H_matrix
	
	Duplicate/O D_matrix A_matrix
	A_matrix=0
	A_matrix=D_matrix[p][q]+aValue*H_matrix[p][q]
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR2Pr_CalculateChisquared()			//calculates Chisquared difference between the data
		//in Intensity and result calculated by G_matrix x x_vector

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

	Wave Intensity=root:Packages:Irena_PDDF:Intensity
	Wave G_matrix=root:Packages:Irena_PDDF:G_matrix
	Wave Errors=root:Packages:Irena_PDDF:Errors
	Wave M_x=root:Packages:Irena_PDDF:M_x

	Duplicate/O Intensity, NormalizedResidual, ChisquaredWave	//waves for data
	IN2G_AppendorReplaceWaveNote("NormalizedResidual","Units"," ")
	
	
	MatrixMultiply  G_matrix, M_x				//generates scattering intensity from current result (M_x - before correction for contrast and diameter)
	Wave M_product	
	Redimension/D/N=(-1,0) M_product			//again make the matrix with one dimension 0 into regular wave

	Duplicate/O M_product PDFFitIntensity
	Note/K PDFFitIntensity
	Note PDFFitIntensity, note(Intensity)

	NormalizedResidual=(Intensity-M_product)/Errors		//we need this for graph
	ChisquaredWave=NormalizedResidual^2			//and this is wave with Chisquared
	setDataFolder OldDf
	return (sum(ChisquaredWave,-inf,inf))				//return sum of Chisquared
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//		Diagnostic functions

static  Function IR2Pr_SetupDiagnostics()
	
	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

//	NVAR Diagnostics=root:Packages:Irena_PDDF:ShowDiagnostics
//	
//	DoWindow IR1S_RegDiagnosticsWindow
//	if (V_Flag)
//		DoWindow/K IR1S_RegDiagnosticsWindow
//	endif	
//	
//	if (Diagnostics)
//		//here we need to setup the waves and graphs as needed
//	//	Make/O/N=0 DiagLogAVal, DiagLogChisquareDivN, DiagSmoothness
//		
//		execute ("IR1S_RegDiagnosticsWindow()")
//		
//	endif
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR2Pr_MakeHmatrix()									//makes the H matrix

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

	Wave R_distribution=root:Packages:Irena_PDDF:R_distribution
	
	variable numOfPoints=numpnts(R_Distribution), i=0, j=0

	Make/D/O/N=(numOfPoints,numOfPoints) H_matrix			//make the matrix
	H_matrix=0												//zero the matrix
	
	For(i=2;i<numOfPoints-2;i+=1)								//this fills with 1 -4 6 -4 1 most of the matrix
		For(j=0;j<numOfPoints;j+=1)
			if(j==i-2)
				H_matrix[i][j]=1
			endif
			if(j==i-1)
				H_matrix[i][j]=-4
			endif
			if(j==i)
				H_matrix[i][j]=6
			endif
			if(j==i+1)
				H_matrix[i][j]=-4
			endif
			if(j==i+2)
				H_matrix[i][j]=1
			endif
		endfor
	endfor
															//now we need to fill in the first and last parts
	H_matrix[0][0]=1											//beginning of the H matrix
	H_matrix[0][1]=-2
	H_matrix[0][2]=1
	H_matrix[1][0]=-2
	H_matrix[1][1]=5
	H_matrix[1][2]=-4
	H_matrix[1][3]=1

	H_matrix[numOfPoints-2][numOfPoints-4]=1					//end of the H matrix
	H_matrix[numOfPoints-2][numOfPoints-3]=-4
	H_matrix[numOfPoints-2][numOfPoints-2]=5
	H_matrix[numOfPoints-2][numOfPoints-1]=-2
	H_matrix[numOfPoints-1][numOfPoints-3]=1
	H_matrix[numOfPoints-1][numOfPoints-2]=-2
	H_matrix[numOfPoints-1][numOfPoints-1]=1

	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR2Pr_CalculateBVector()								//makes new B vector and calculates values from G, Int and errors

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF
	
	Wave G_matrix	=root:Packages:Irena_PDDF:G_matrix
	Wave Intensity	=root:Packages:Irena_PDDF:Intensity 
	Wave Errors		=root:Packages:Irena_PDDF:Errors
//	variable M=DimSize(G_matrix, 0)							//rows, i.e, measured points number
//	variable N=DimSize(G_matrix, 1)							//columns, i.e., bins in distribution
//	variable i=0, j=0
//	Make/D/O/N=(N) B_vector									//points = bins in size dist.
//	B_vector=0
//	for (i=0;i<N;i+=1)					
//		For (j=0;j<M;j+=1)
//			B_vector[i]+=((G_matrix[j][i]*Intensity[j])/(Errors[j]*Errors[j]))
//		endfor
//	endfor
	MatrixOp/O B_vector = G_matrix^t x (Intensity /(Errors*Errors))

	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR2Pr_CalculateDMatrix()								//makes new D matrix and calculates values from G, Int and errors

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF
	
	Wave G_matrix=root:Packages:Irena_PDDF:G_matrix
	Wave Errors=root:Packages:Irena_PDDF:Errors
//	Wave G_matrix=root:Packages:Sizes:G_matrixQ2N
//	Wave Errors=root:Packages:Sizes:ErrorsQ2N
	
	variable N=DimSize(G_matrix, 1)							//rows, i.e, measured points number
	variable M=DimSize(G_matrix, 0)							//columns, i.e., bins in distribution
	variable i=0, j=0, k=0
	Make/D/O/N=(N,N) D_matrix	
	Duplicate/O Errors, Errors2
	Errors2=Errors^2

//	variable tiskst=ticks			
	D_matrix=0
	Duplicate/O G_matrix, G_matrix_ErrScaled
	for (i=0;i<N;i+=1)	
		for (j=0;j<M;j+=1)				
			G_matrix_ErrScaled[j][i]=G_matrix[j][i]/(Errors2[j])
		endfor
	endfor	
	MatrixOp/O D_matrix =  G_matrix_ErrScaled^t x G_matrix
//	D_matrix = testM
	KillWaves/Z Errors2, testM, G_matrix_ErrScaled

	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
