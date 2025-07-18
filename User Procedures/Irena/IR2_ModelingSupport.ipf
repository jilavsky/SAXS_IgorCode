#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.53


constant ChangeFromGaussToSlit=2
//*************************************************************************\
//* Copyright (c) 2005 - 2025, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.53 add requested feature to add ccontrols to have graph axis linear-or-log and change color of model_set1
//1.52 reviewed pixel smearing (still think it is working correctly) and modified IR2L_FinishSmearingOfData() to use multiple threads. 
//1.51 added option to save population results from scripting tool. 
//1.50 merged togetehr with IR2L_NLSQFCalc.ipf
//1.42 added Ardell distributions support
//1.41 added getHelp button calling to www manual
//1.40 added modifiers to stepping by clicking on step arrows fro setVariables. With modifier step is 10x smaller now. 
//1.39 fixed code which did nto have full paths to waves and was failing when called in some cases. 
//1.38 added lookup of SlitLength from data when checkbox is selected. Looks inside wave note of Intensity to see, if there is Slitlength there. Even wehn using qrs or other naming ssytem. 
//			note: this is done when checkbox is selected, not when data are imported (unless USAXS data). 
//1.37 fixed bug in IR2L_CreateResidulas which failed when was called with wrong working folder. 
//1.36 minor (R_min setVariable) GUI fix. 
//1.35 catch Log-Normal min size when it is too small. 
//1.34 fixed non-functioning data scailing feature. Now shoudl scale data first and then, optionally scale Errors or modify as requested. 
//1.33 removed most Executes as fix for Igor 7
//1.32 modified Tab procedures and removed Execute constructs as these will be very slow in Igor 7. 
//1.31 bug fixes and modifications to Other graph outputs - colorization etc. 
//1.30 added checkboxes for displaying Size distributions, Residuals and IQ4 vs Q graphs and code shupporting it. 
//1.29 added Fractals as models
//1.28 added User Name for each population - when displayed Indiv. Pops. - to dispay in the graph, so user can make it easier to read. 
//1.27	added check that Scripting tool does not have "UseResults" selected. This caused bug with two different types of data selected in ST.
//1.26 changed in Unicertainity analysis length of paramName to 20 characters. 
//1.25 fixed Notebook recording of Shulz-Zimm distribution type
//1.24 minor fix in Uncertainity evaluation. 
//1.23 Propagated through Modeling Intensity units. Removed option to combine SphereWithLocallyMonodispersedSq with any structrue factor. 
//1.22 fixed bug when Analyze uncertainities would not get number of fitted points due to changed folder. 
//1.21 fixed Background GUI which has step set to 0 after chanigng the tabs.
//1.20 added to Unified level ability to link B to G/Rg/P based on Guinier/Porod theory. Remoeved abuility to fit RgCO at all. 
//1.19 fixed IR2L_FixLimits function to set some high limit when parameter=0, added support for NoFitLimits feature
//		support for changet the tab of used tabs names.. 
//1.18 fixed bug when reinitialization of Unified levels would add G=100 even when Rg=1e10. Fix GUI issue when adding new data set and recovering the stored result. 
//		Fixes for too long ParamNames in Analysis of uncertainities.
//1.17 fixed bug when scripting tool got out of sync with main Modeling panel. 
//1.16 fixed fix limits check so if the value is negative, it sorts out limits correctly. Needed for core shell systems with negative SLD
//1.15 added Form and Structrue factor description as Igor help file. Added buttons to call the help file from GUI. 
//1.14 Modified to handle Janus CoreShell Micelle FF
//1.13 modified data stored in wavenote to minimize stuff saved there.
//1.12 removed express calls to font and fsize for panels to enable user controls over these parameters
//1.11 Modifed local Guinier and Power law fits to handle multiple contrasts for data when using multiple input data sets. 
//1.10 Added Scripting tool button and features around it, it is enabled ONLY for Single Data set input
//1.09 fixed bug in fitting local P and B in unified model which was setting wrong limits. Added ability to remove points from data.
//1.08 Modified for Scripting tool 
//1.07 added button to graph to select fitting Q range with cursors from the graph
//1.06 modified to 10 populations, changed handling of Unified fit and diffraction peaks.
//1.05 fix problem with "Use" checkbox and not redrawing the tab view. Fixed display of G limits when using Unified level.
//1.04 fix the popup for help notebook when users select User FF
//1.03 fix logging into logbook (someone is actually using it!) where it wrongly choose distribution type. 
//1.02 added Unified Fit level as Form factor
//1.01 added license for ANL

//content from IR2L_NLSQFCalc.ipf
//1.15 added Ardell distributions support
//1.14 fixed bug where the change in Diametrer vs Radius was not reflected in Size distribution graph and calculated properly. Fixed FWHM for diff peaks calcualtion. 
//1.13 minor fixes for existence of Size distribution graphs so we do tno get errors. 
//1.12 removed most Executes in preparation for Igor 7
//1.11  bug fixes and modifications to Other graph outputs - colorization etc. 
//1.10 added checkboxes for displaying Size distributions, Residuals and IQ4 vs Q graphs and code shupporting it. 
//1.09 added checkboxes for displaying Size distributions, Residuals and IQ4 vs Q graphs and code shupporting it. 
//1.08 added to Unified fit ability to calculate B from G/Rg/P based on Guinier/Porod model. 
//1.07 fix to catch error for peak FWHM when data raneg is not good enough to calculate
//1.06 added Janus CoreShell Micelle
//1.05 fixed problem with calculations of peak positions
//1.04 changed min size used by the tool to 1A. Lot of users seems to be using this at really high qs... 
//1.03 Add Diffraction peak and Unified level as Populations, increase number of populations to 10
//1.02 added Unified level as Form factor
//1.01 added license for ANL


//calculations for Least square fit 2

////To calculate intensity we need to do following:
//	1. Calcualte for all used populations the distributions
//	2. Calculate for all used data sets the intensity generated by each population
//	3. Sum the intensities of all used populations for each used data set 
//	4. Display, calculate residuals etc.
//	  




//**********************************************************************************
//**********************************************************************************
//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IR2L_RecalculateIfSelected()

	NVAR RecalculateAutomatically=root:Packages:IR2L_NLSQF:RecalculateAutomatically
	string topWinNm=WinName(0,64) 
	if(RecalculateAutomatically)
		IR2L_CalculateIntensity(0,0)
	endif
	DoWIndow/F $(topWinNm)
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_InputGraphButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	if(cmpstr(ctrlName,"AutoSetAxis")==0)
			IR2L_AutosetGraphAxis(1)
	endif
	if(cmpstr(ctrlName,"SetAxis")==0)
			IR2L_AutosetGraphAxis(0)
	endif
	if(cmpstr(ctrlName,"SelectQRangeofData")==0)
		//	NEED TO FIGURE OUT IF THE CURSORS ARE SET ON Intensity and same one, which data set it is and then pass it to the right function...
		if(strlen(csrInfo(A))<1 || strlen(csrInfo(B))<1)
			Abort "Cursors are not set correctly. Place cursors on Intensity data and try again"
		endif
		string TnameA=stringByKey("TNAME",csrinfo(A))
		string TnameB=stringByKey("TNAME",csrinfo(B))
		if(!stringmatch(TnameA,TnameB) || !stringmatch(TnameA,"Intensity_set*") || !stringmatch(TnameB,"Intensity_set*"))
			abort "Cursors are not set correctly. Set cursors on SAME Intensity data and try again"
		endif
		variable setValue=str2num(ReplaceString("Intensity_set", TnameA, ""))
		print setValue
		IR2L_SetQminQmaxWCursors(setValue)
	endif


	DoWIndow/F LSQF_MainGraph
	setDataFolder oldDF
end
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
Function IR2L_RemovePntCsrA(DataTabNumber)
	variable DataTabNumber

	variable DataSetNumber=DataTabNumber+1
	
	DoWIndow LSQF_MainGraph
	if(!V_flag)
		print "Modeling main graph does not exist"
		return 0
	endif
	if (strlen(csrInfo(A,"LSQF_MainGraph"))<1)
		print "Cursor A is not set in the graph, set onto data point you want to remove"
		DoAlert 0,  "Cursor A is not set in the graph, set onto data point you want to remove first"
		return 0
	else		//cursor A is set, now check if it is on the right wave
		String IntWvName="Intensity_set"+num2str(DataSetNumber)
		if(!stringMatch(IntWvName,StringByKey("TNAME", csrInfo(A,"LSQF_MainGraph") )))
			print "Cursor A is not set on the right wave, expected to be set on : "+IntWvName
			DoAlert 0,  "Cursor A is not set on the right wave, expected to be set on : "+IntWvName
			return 0
		else	//OK, it is on the right wave, need to remove the point from the three waves and return 1 to recalculate model...
			Wave IntWv = $("root:Packages:IR2L_NLSQF:Intensity_set"+num2str(DataSetNumber))
			Wave QWv = $("root:Packages:IR2L_NLSQF:Q_set"+num2str(DataSetNumber))
			Wave EWv = $("root:Packages:IR2L_NLSQF:Error_set"+num2str(DataSetNumber))
			Wave  MaskWv = $("root:Packages:IR2L_NLSQF:IntensityMask_set"+num2str(DataSetNumber))
			Duplicate/Free MaskWv, tempWvF
			IntWv[pcsr(A,"LSQF_MainGraph")]=NaN
			print "removed Point number " + num2str(pcsr(A,"LSQF_MainGraph")) +" from wave : "+IntWvName
			IN2G_RemoveNaNsFrom5Waves(IntWv,QWv,EWv,MaskWv,tempWvF)
			return 1
		endif

	endif
	
end
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************


//****************************************************************************************************************
//****************************************************************************************************************


Function IR2L_FitLocalGuinier(Level)
	variable level
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	//first set to display local fits
	//check if the cursors are set...
	if(strlen(CsrWave(A  , "LSQF_MainGraph" ))<1 || strlen(CsrWave(B  , "LSQF_MainGraph" ))<1)
		beep
		Abort "Set cursors for fitting first first. Both need to be on the same wave."
	endif
	if(!stringMatch(CsrWave(A  , "LSQF_MainGraph" ), CsrWave(B  , "LSQF_MainGraph" )))
		beep
		Abort "Set cursors on the same wave first"
	endif
	Wave/Z OriginalIntensity=CsrWaveRef(A  , "LSQF_MainGraph" )
	Wave/Z OriginalQvector=CsrXWaveRef(A , "LSQF_MainGraph" )

	Duplicate/O OriginalIntensity, $("FitLevel"+num2str(Level)+"Guinier")

	Wave FitInt=$("root:Packages:IR2L_NLSQF:FitLevel"+num2str(Level)+"Guinier")
	string FitIntName="FitLevel"+num2str(Level)+"Guinier"
	
	NVAR Rg=$("root:Packages:IR2L_NLSQF:UF_Rg_pop"+num2str(level))
	NVAR G=$("root:Packages:IR2L_NLSQF:UF_G_pop"+num2str(level))
	NVAR RgMin=$("root:Packages:IR2L_NLSQF:UF_RgMin_pop"+num2str(level))
	NVAR GMin=$("root:Packages:IR2L_NLSQF:UF_GMin_pop"+num2str(level))
	NVAR RgMax=$("root:Packages:IR2L_NLSQF:UF_RgMax_pop"+num2str(level))
	NVAR GMax=$("root:Packages:IR2L_NLSQF:UF_GMax_pop"+num2str(level))
	
	NVAR FitRg=$("root:Packages:IR2L_NLSQF:UF_RgFit_pop"+num2str(level))
	NVAR FitG=$("root:Packages:IR2L_NLSQF:UF_GFit_pop"+num2str(level))

	if (!FitG && !FitRg)
		beep
		abort "No fitting parameter allowed to vary, select parameters to vary and set fitting limits"
	endif
	DoWIndow/F LSQF_MainGraph
	Make/D/O/N=2 New_FitCoefficients, CoefficientInput, LocalEwave
	Make/O/T/N=2 CoefNames
	New_FitCoefficients[0] = G
	New_FitCoefficients[1] = Rg
	LocalEwave[0]=(G/20)
	LocalEwave[1]=(Rg/20)
	CoefficientInput[0]={G,Rg}
	CoefNames={"UF_G_pop"+num2str(level),"UF_Rg_pop"+num2str(level)}
	variable tempLength

	Variable V_FitError=0			//This should prevent errors from being generated
	//modifed 12 20 2004 to use fit at once function to allow use on smeared data

	FuncFit/Q/H=(num2str(abs(FitG-1))+num2str(abs(FitRg-1)))/N IR2L_GuinierFitAllAtOnce New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /E=LocalEwave // /W=OriginalError/I=1 

	if (V_FitError!=0)	//there was error in fitting
		beep
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	IR2L_GuinierFitAllAtOnce(New_FitCoefficients,FitInt,OriginalQvector)
	//terminate data outside user intensity range... 
	NVAR GraphYmin
	NVAR GraphYMax
	FitInt = (FitInt[p]<GraphYMax && FitInt[p]>GraphYMin) ? FitInt[p] : NaN 

	CheckDisplayed FitInt
	if(!V_Flag)
		AppendToGraph/W=LSQF_MainGraph FitInt vs OriginalQvector
		String name = NameOfWave(FitInt)
		ModifyGraph mode($name)=0,lstyle($name)=7
		ModifyGraph lsize($name)=2,rgb($name)=(1,16019,65535)
	endif
//	SetAxis left GraphYmin, GraphYMax
//	SetAxis bottom GraphXmin, GraphXMax
	G=abs(New_FitCoefficients[0])
	Rg=abs(New_FitCoefficients[1])
	RgMin=Rg/5
	RgMax=Rg*5
	GMin=G/5
	GMax=G*5
	
	SetDataFolder oldDf
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR2L_FitLocalPorod(Level)
	variable level
	DFref oldDf= GetDataFolderDFR()

	
	setDataFolder root:Packages:IR2L_NLSQF

	//first set to display local fits
	//check if the cursors are set...
	if(strlen(CsrWave(A  , "LSQF_MainGraph" ))<1 || strlen(CsrWave(B  , "LSQF_MainGraph" ))<1)
		beep
		Abort "Set cursors for fitting first first. Both need to be on the same wave."
	endif
	if(!stringMatch(CsrWave(A  , "LSQF_MainGraph" ), CsrWave(B  , "LSQF_MainGraph" )))
		beep
		Abort "Set cursors on the same wave first"
	endif
	Wave/Z OriginalIntensity=CsrWaveRef(A  , "LSQF_MainGraph" )
	Wave/Z OriginalQvector=CsrXWaveRef(A , "LSQF_MainGraph" )

	Duplicate/O OriginalIntensity, $("FitLevel"+num2str(Level)+"PowerLaw")

	Wave FitInt=$("root:Packages:IR2L_NLSQF:FitLevel"+num2str(Level)+"PowerLaw")
	string FitIntName="FitLevel"+num2str(Level)+"Powerlaw"
	
	NVAR Pval=$("root:Packages:IR2L_NLSQF:UF_P_pop"+num2str(level))
	NVAR B=$("root:Packages:IR2L_NLSQF:UF_B_pop"+num2str(level))
	NVAR PMin=$("root:Packages:IR2L_NLSQF:UF_PMin_pop"+num2str(level))
	NVAR BMin=$("root:Packages:IR2L_NLSQF:UF_BMin_pop"+num2str(level))
	NVAR PMax=$("root:Packages:IR2L_NLSQF:UF_PMax_pop"+num2str(level))
	NVAR BMax=$("root:Packages:IR2L_NLSQF:UF_BMax_pop"+num2str(level))
	
	NVAR FitP=$("root:Packages:IR2L_NLSQF:UF_PFit_pop"+num2str(level))
	NVAR FitB=$("root:Packages:IR2L_NLSQF:UF_BFit_pop"+num2str(level))

	if (!FitP && !FitB)
		beep
		abort "No fitting parameter allowed to vary, select parameters to vary and set fitting limits"
	endif

	Make/D/O/N=2 CoefficientInput, New_FitCoefficients, LocalEwave
	Make/O/T/N=2 CoefNames
	CoefficientInput[0]=B
	CoefficientInput[1]=Pval
	LocalEwave[0]=B/20
	LocalEwave[1]=Pval/20
	CoefNames={"UF_B_pop"+num2str(level),"UF_P_pop"+num2str(level)}
	
	Make/D/O/N=2 New_FitCoefficients
	New_FitCoefficients[0] = {B,Pval}
	Make/O/T/N=2 T_Constraints
	T_Constraints = {"K1 > 1","K1 < 4.2"}

	Variable V_FitError=0			//This should prevent errors from being generated
	DoWIndow/F LSQF_MainGraph
	if (FitP)
		FuncFit/H=(num2str(abs(FitB-1))+num2str(abs(FitP-1)))/N IR2L_PowerLawFitAllATOnce New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector  /E=LocalEwave  /C=T_Constraints ///W=OriginalError /I=1
	else
		FuncFit/H=(num2str(abs(FitB-1))+num2str(abs(FitP-1)))/N IR2L_PowerLawFitAllATOnce New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector //W=OriginalError /I=1 //E=LocalEwave 
	endif

	if (V_FitError!=0)	//there was error in fitting
		beep
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif

	IR2L_PowerLawFitAllATOnce(New_FitCoefficients,FitInt,OriginalQvector)
	//terminate data outside user intensity range... 
	NVAR GraphYmin
	NVAR GraphYMax
	FitInt = (FitInt[p]<GraphYMax && FitInt[p]>GraphYMin) ? FitInt[p] : NaN 

	CheckDisplayed FitInt
	if(!V_Flag)
		AppendToGraph/W=LSQF_MainGraph FitInt vs OriginalQvector
		String name = NameOfWave(FitInt)
		ModifyGraph mode($name)=0,lstyle($name)=9
		ModifyGraph lsize($name)=2,rgb($name)=(1,4,52428)
	endif

	B=abs(New_FitCoefficients[0])
	PVal=abs(New_FitCoefficients[1])
	PMin=1
	PMax=4.2
	BMin=B/5
	BMax=B*5
	
	SetDataFolder oldDf
end
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR2L_PowerLawFitAllATOnce(parwave,ywave,xwave) : FitFunc
	Wave parwave,xwave,ywave

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

	variable Prefactor=abs(parwave[0])
	variable slope=abs(parwave[1])
	
	ControlInfo/W=LSQF2_MainPanel DataTabs
	string IntWaveName=CsrWave(A  , "LSQF_MainGraph" )
	variable SetVar = str2num(IntWaveName[strsearch( IntWaveName, "_set", 0)+4,inf])
	NVAR UseSMRData=$("root:Packages:IR2L_NLSQF:SlitSmeared_set"+num2str(SetVar))
	NVAR SlitLengthUnif=$("root:Packages:IR2L_NLSQF:SlitLength_set"+num2str(SetVar))
	ControlInfo/W=LSQF2_MainPanel DistTabs
	variable currentTab=V_Value+1
	NVAR Contrast=$("root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(currentTab))
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	if(MultipleInputData)
		string setNum=NameOfWave(CsrWaveRef(A , "LSQF_MainGraph" ) )[13,inf]
		NVAR Contrast=$("root:Packages:IR2L_NLSQF:Contrast_set"+setNum+"_pop"+num2str(currentTab))
	endif
	Wave OriginalQvector=CsrXWaveRef(A , "LSQF_MainGraph" )

	Duplicate/O OriginalQvector, tempPowerLawInt
	// w[0]*q^(-w[1])
	tempPowerLawInt =Contrast* Prefactor * OriginalQvector^(-slope)
	if(UseSMRData)
		duplicate/O  tempPowerLawInt, tempPowerLawIntSM
		IR1B_SmearData(tempPowerLawInt, OriginalQvector, SlitLengthUnif, tempPowerLawIntSM)
		tempPowerLawInt=tempPowerLawIntSM
	endif
	
	ywave = tempPowerLawInt[binarysearch(OriginalQvector,xwave[0])+p]
	KillWaves/Z tempGunIntSM, tempGunInt
End

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
Function IR2L_GuinierFitAllAtOnce(parwave,ywave,xwave) : FitFunc
	Wave parwave,xwave,ywave

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

	variable Prefactor=abs(parwave[0])
	variable Rg=abs(parwave[1])
	ControlInfo/W=LSQF2_MainPanel DataTabs
	string IntWaveName=CsrWave(A  , "LSQF_MainGraph" )
	variable SetVar = str2num(IntWaveName[strsearch( IntWaveName, "_set", 0)+4,inf])
	NVAR UseSMRData=$("root:Packages:IR2L_NLSQF:SlitSmeared_set"+num2str(SetVar))
	NVAR SlitLengthUnif=$("root:Packages:IR2L_NLSQF:SlitLength_set"+num2str(SetVar))
	ControlInfo/W=LSQF2_MainPanel DistTabs
	variable currentTab=V_Value+1
	NVAR Contrast=$("root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(currentTab))
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	if(MultipleInputData)
		string setNum=NameOfWave(CsrWaveRef(A , "LSQF_MainGraph" ) )[13,inf]
		NVAR Contrast=$("root:Packages:IR2L_NLSQF:Contrast_set"+setNum+"_pop"+num2str(currentTab))
	endif
	
	Wave OriginalQvector=CsrXWaveRef(A , "LSQF_MainGraph" )
	Duplicate/O OriginalQvector, tempGunInt
	//w[0]*exp(-q^2*w[1]^2/3)
	tempGunInt = Contrast* Prefactor * exp(-OriginalQvector^2 * Rg^2/3)
	if(UseSMRData)
		duplicate/O  tempGunInt, tempGunIntSM
		IR1B_SmearData(tempGunInt, OriginalQvector, SlitLengthUnif, tempGunIntSM)
		tempGunInt=tempGunIntSM
	endif
	
	ywave = tempGunInt[binarysearch(OriginalQvector,xwave[0])+p]
	KillWaves/Z tempGunIntSM, tempGunInt
	
	return 1
End
//****************************************************************************************************************
//****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_RemoveAllDataSets()
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	variable i
	DoAlert 1, "All data sets will be removed. Do you really want to do it?"
	if(V_Flag==1) 
		
		For(i=1;i<11;i+=1)
			IR2L_RemoveDataFromGraph(i)		//remove the data from graph
			NVAR UseTheData_set=$("UseTheData_set"+num2str(i))	//set them not to be used
			UseTheData_set=0
			SVAR Fldr=$("root:Packages:IR2L_NLSQF:FolderName_set"+num2str(i))
			SVAR Int=$("root:Packages:IR2L_NLSQF:IntensityDataName_set"+num2str(i))
			SVAR Qvec=$("root:Packages:IR2L_NLSQF:QvecDataName_set"+num2str(i))
			SVAR Err = $("root:Packages:IR2L_NLSQF:ErrorDataName_set"+num2str(i))
			Fldr=""
			Int=""
			Qvec=""
			Err=""
			Wave/Z IntWv=$("root:Packages:IR2L_NLSQF:Intensity_set"+num2str(i))
			Wave/Z QWv=$("root:Packages:IR2L_NLSQF:Q_set"+num2str(i))
			Wave/Z ErrWv=$("root:Packages:IR2L_NLSQF:Error_set"+num2str(i))
			if(WaveExists(IntWv))
				KillWaves/Z IntWv
			endif
			if(WaveExists(QWv))
				KillWaves/Z QWv
			endif
			if(WaveExists(ErrWv))
				KillWaves/Z ErrWv
			endif
		endfor
		ControlInfo/W=LSQF2_MainPanel DataTabs
		IR2L_Data_TabPanelControl("",V_Value)
	endif
	setDataFolder oldDF
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_unUseAllDataSets()
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	variable i
	For(i=1;i<11;i+=1)
		IR2L_RemoveDataFromGraph(i)
		NVAR UseTheData_set=$("UseTheData_set"+num2str(i))
		UseTheData_set=0
	endfor
	ControlInfo/W=LSQF2_MainPanel DataTabs
	IR2L_Data_TabPanelControl("",V_Value)
	setDataFolder oldDF
end


//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_CheckForTooManyUniflevels()
	//let use know that only one unified level should be used. 
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	variable i, numberOfUFs
	numberOfUFs=0
	For(i=1;i<11;i+=1)
		SVAR Model=$("root:Packages:IR2L_NLSQF:Model_pop"+num2str(i))
		if(stringMatch(Model,"Unified level"))
			numberOfUFs+=1
		endif
	endfor
	if(numberOfUFs>1)	//raise allert, but only sometimes
		NVAR/Z LastChecked
		if(NVAR_Exists(LastChecked)&& (DateTime - LastChecked)<60*60*24)
			print "NOTE: Only one Unified level should be used at once in Modeling. For more levels use Unified Fit tool"
		else
			DoAlert 0, "NOTE: Only one Unified level should be used at once in Modeling. For more levels use Unified Fit tool"
		endif
		variable/g LastChecked
		LastChecked = DateTime
	endif
	setDataFolder oldDF
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2L_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	if (stringmatch(ctrlName,"FormFactorPop"))
		ControlInfo/W=LSQF2_MainPanel DistTabs
		SVAR FormFactor = $("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(V_Value+1))
		FormFactor = popStr
		IR2L_Model_TabPanelControl("",V_Value)
		IR2L_CallPanelFromFFpackage(V_Value+1)
		if(stringmatch(FormFactor,"User"))
			IR1T_GenerateHelpForUserFF()
		endif
		//SphereWHSLocMonoSq
		if(stringmatch(popStr,"SphereWHSLocMonoSq"))
			SVAR StrFac=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(V_Value+1))
			StrFac = "Dilute system"
			PopupMenu StructureFactorModel win=LSQF2_MainPanel, value=#"(root:Packages:StructureFactorCalc:ListOfStructureFactors)"
			SVAR StrB=root:Packages:StructureFactorCalc:ListOfStructureFactors
			PopupMenu StructureFactorModel win=LSQF2_MainPanel, mode=WhichListItem("Dilute system",StrB )+1
		endif
	endif

	if (stringmatch(ctrlName,"ModelColor"))
		SVAR rgbIntensityLine_set1 = root:Packages:IR2L_NLSQF:rgbIntensityLine_set1
		rgbIntensityLine_set1 = popStr
		IR2L_FormatInputGraph()
	endif
	
	if (stringmatch(ctrlName,"DataUnits"))
		IR2L_SetDataUnits(popStr)
	endif

	if (stringmatch(ctrlName,"DiffPeakProfile"))
		ControlInfo/W=LSQF2_MainPanel DistTabs
		SVAR DiffPeakProfile = $("root:Packages:IR2L_NLSQF:DiffPeakProfile_pop"+num2str(V_Value+1))
		DiffPeakProfile = popStr
		IR2L_Model_TabPanelControl("",V_Value)
	endif

	if (stringmatch(ctrlName,"SurfFrQcWidth"))
		ControlInfo/W=LSQF2_MainPanel DistTabs
		NVAR Width = $("root:Packages:IR2L_NLSQF:SurfFrQcWidth_pop"+num2str(V_Value+1))
		Width = 0.01*str2num(popStr)
		IR2L_Model_TabPanelControl("",V_Value)
	endif


	if (stringmatch(ctrlName,"KFactor"))
		ControlInfo/W=LSQF2_MainPanel DistTabs
		NVAR UF_K = $("root:Packages:IR2L_NLSQF:UF_K_pop"+num2str(V_Value+1))
		UF_K = str2num(popStr)
	endif
	
	if (stringmatch(ctrlName,"PopSizeDistShape"))
		ControlInfo/W=LSQF2_MainPanel DistTabs
		SVAR PopSizeDistShape = $("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(V_Value+1))
		PopSizeDistShape = popStr
		//IR2L_FixDistTypeFittingChckbxs(V_Value+1, PopSizeDistShape)
		IR2L_Model_TabPanelControl("",V_Value)
	endif
	if (stringmatch(ctrlName,"PopulationType"))
		ControlInfo/W=LSQF2_MainPanel DistTabs
		SVAR Model = $("root:Packages:IR2L_NLSQF:Model_pop"+num2str(V_Value+1))
		Model = popStr
		IR2L_Model_TabPanelControl("",V_Value)
		if(stringmatch(popStr,"Unified level"))
			IR2L_CheckForTooManyUniflevels()
		endif
	endif

	if(stringmatch(ctrlName,"StructureFactorModel") )
			variable whichDataSet
			ControlInfo/W=LSQF2_MainPanel DistTabs
			whichDataSet= V_Value+1
			SVAR StrFac=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(whichDataSet))
			SVAR FormFactor = $("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(whichDataSet))
			if(stringmatch(FormFactor,"SphereWHSLocMonoSq"))
				StrFac = "Dilute system"			
				PopupMenu StructureFactorModel win=LSQF2_MainPanel, value=#"(root:Packages:StructureFactorCalc:ListOfStructureFactors)"
				SVAR StrB=root:Packages:StructureFactorCalc:ListOfStructureFactors
				PopupMenu StructureFactorModel win=LSQF2_MainPanel, mode=WhichListItem("Dilute system",StrB )+1
			else
				StrFac = popStr
			endif
			KillWIndow/Z StructureFactorControlScreen
//	ListOfPopulationVariables+="StructureParam3;StructureParam3Fit;StructureParam3Min;StructureParam3Max;StructureParam4;StructureParam4Fit;StructureParam4Min;StructureParam4Max;"
///	ListOfPopulationVariables+="StructureParam5;StructureParam5Fit;StructureParam5Min;StructureParam5Max;"

			string TitleStr= "Structure Factor for Pop"+num2str(whichDataSet)+" of LSQF2 modeling"
			string SFStr = "root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(whichDataSet)
			string P1Str = "root:Packages:IR2L_NLSQF:StructureParam1_pop"+num2str(whichDataSet)
			string FitP1Str = "root:Packages:IR2L_NLSQF:StructureParam1Fit_pop"+num2str(whichDataSet)
			string LowP1Str = "root:Packages:IR2L_NLSQF:StructureParam1Min_pop"+num2str(whichDataSet)
			string HighP1Str = "root:Packages:IR2L_NLSQF:StructureParam1Max_pop"+num2str(whichDataSet)
			string P2Str = "root:Packages:IR2L_NLSQF:StructureParam2_pop"+num2str(whichDataSet)
			string FitP2Str = "root:Packages:IR2L_NLSQF:StructureParam2Fit_pop"+num2str(whichDataSet)
			string LowP2Str = "root:Packages:IR2L_NLSQF:StructureParam2Min_pop"+num2str(whichDataSet)
			string HighP2Str = "root:Packages:IR2L_NLSQF:StructureParam2Max_pop"+num2str(whichDataSet)

			string P3Str = "root:Packages:IR2L_NLSQF:StructureParam3_pop"+num2str(whichDataSet)
			string FitP3Str = "root:Packages:IR2L_NLSQF:StructureParam3Fit_pop"+num2str(whichDataSet)
			string LowP3Str = "root:Packages:IR2L_NLSQF:StructureParam3Min_pop"+num2str(whichDataSet)
			string HighP3Str = "root:Packages:IR2L_NLSQF:StructureParam3Max_pop"+num2str(whichDataSet)

			string P4Str = "root:Packages:IR2L_NLSQF:StructureParam4_pop"+num2str(whichDataSet)
			string FitP4Str = "root:Packages:IR2L_NLSQF:StructureParam4Fit_pop"+num2str(whichDataSet)
			string LowP4Str = "root:Packages:IR2L_NLSQF:StructureParam4Min_pop"+num2str(whichDataSet)
			string HighP4Str = "root:Packages:IR2L_NLSQF:StructureParam4Max_pop"+num2str(whichDataSet)

			string P5Str = "root:Packages:IR2L_NLSQF:StructureParam5_pop"+num2str(whichDataSet)
			string FitP5Str = "root:Packages:IR2L_NLSQF:StructureParam5Fit_pop"+num2str(whichDataSet)
			string LowP5Str = "root:Packages:IR2L_NLSQF:StructureParam5Min_pop"+num2str(whichDataSet)
			string HighP5Str = "root:Packages:IR2L_NLSQF:StructureParam5Max_pop"+num2str(whichDataSet)

			string P6Str = "root:Packages:IR2L_NLSQF:StructureParam6_pop"+num2str(whichDataSet)
			string FitP6Str = "root:Packages:IR2L_NLSQF:StructureParam6Fit_pop"+num2str(whichDataSet)
			string LowP6Str = "root:Packages:IR2L_NLSQF:StructureParam6Min_pop"+num2str(whichDataSet)
			string HighP6Str = "root:Packages:IR2L_NLSQF:StructureParam6Max_pop"+num2str(whichDataSet)

			string SFUserSFformula = "root:Packages:IR2L_NLSQF:SFUserSQFormula_pop"+num2str(whichDataSet)
			//the Structure factor package will take of making the fit parameters fo hidden parameters uncheckedm if they are checked.  
			NVAR NoFittingLimits = root:Packages:IR2L_NLSQF:NoFittingLimits
			IR2S_MakeSFParamPanel(TitleStr,SFStr,P1Str,FitP1Str,LowP1Str,HighP1Str,P2Str,FitP2Str,LowP2Str,HighP2Str,P3Str,FitP3Str,LowP3Str,HighP3Str,P4Str,FitP4Str,LowP4Str,HighP4Str,P5Str,FitP5Str,LowP5Str,HighP5Str,P6Str,FitP6Str,LowP6Str,HighP6Str,SFUserSFformula,NoFittingLimits=NoFittingLimits)
			DoWIndow  StructureFactorControlScreen
			if(V_Flag)
					SetWindow StructureFactorControlScreen  hook(Update)=IR2L_UpdateHook
					SetDrawEnv /W=StructureFactorControlScreen fstyle= 3
	//				DrawText/W=StructureFactorControlScreen 4,220,"Hit enter twice to auto recalculate (if Auto recalculate is selected)"
			endif
	endif
	IR2L_RecalculateIfSelected() 
	DoWIndow UserDefinedSQ_Help
	if(V_Flag)
		DoWIndow/F UserDefinedSQ_Help
	endif
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//
//Function IR2L_FixDistTypeFittingChckbxs(PopNumber, PopSizeDistShape)
//	variable popNumber
//	string PopSizeDistShape
//	
//	//LogNormal;Gauss;LSW;Schulz-Zimm
//	
//	
//	if(!stringmatch(PopSizeDistShape,"LogNormal"))
//		NVAR  FitPar1=$("root:Packages:IR2L_NLSQF:LNMinSizeFit_pop"+num2str(popNumber))
//		NVAR FitPar2=$("root:Packages:IR2L_NLSQF:LNMeanSizeFit_pop"+num2str(popNumber))
//		NVAR FitPar3=$("root:Packages:IR2L_NLSQF:LNSdeviationFit_pop"+num2str(popNumber))
//		FitPar1 = 0
//		FitPar2 = 0
//		FitPar3 = 0
//	endif
//	if(!stringmatch(PopSizeDistShape,"Gauss"))
//		NVAR FitPar1=$("root:Packages:IR2L_NLSQF:GMeanSizeFit_pop"+num2str(popNumber))
//		NVAR FitPar2=$("root:Packages:IR2L_NLSQF:GWidthFit_pop"+num2str(popNumber))
//		FitPar1 = 0
//		FitPar2 = 0
//	endif
//	if(!stringmatch(PopSizeDistShape,"Schulz-Zimm"))
//		NVAR FitPar1=$("root:Packages:IR2L_NLSQF:SZMeanSizeFit_pop"+num2str(popNumber))
//		NVAR FitPar2=$("root:Packages:IR2L_NLSQF:SZWidthFit_pop"+num2str(popNumber))
//		FitPar1 = 0
//		FitPar2 = 0
//	endif
//	if(!stringmatch(PopSizeDistShape,"LSW"))
//		NVAR FitPar1=$("root:Packages:IR2L_NLSQF:LSWLocationFit_pop"+num2str(popNumber))
//		FitPar1 = 0
//	endif
//	
//
//
//end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_UpdateHook(H_Struct)
	STRUCT WMWinHookStruct &H_Struct

	 if(stringmatch(H_Struct.eventName,"Keyboard"))
		IR2L_RecalculateIfSelected() 
	 endif
//	<code to test and process events>
//	...
//	return statusCode		// 0 if nothing done, else 1
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function  IR2L_CallPanelFromFFpackage(which)
	variable which

	NVAR NoFittingLimits=root:Packages:IR2L_NLSQF:NoFittingLimits

	SVAR FormFactor = $("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(which))
	if(stringmatch(FormFactor,"Unified_Level"))
		string TitleStr11="Unified Fit parameters for Population "+num2str(which)
		//UF_RGCO;UF_K;UF_LinkRGCO;UF_LinkRGCOLevel		
		IR2L_MakeFFParamPanel(TitleStr11, which)
	else	
		string TitleStr="Form factor parameters for Population "+num2str(which)
		string FFStr="root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(which)
		string P1Str="root:Packages:IR2L_NLSQF:FormFactor_Param1_pop"+num2str(which)
		string FitP1Str="root:Packages:IR2L_NLSQF:FormFactor_Param1Fit_pop"+num2str(which)
		string LowP1Str="root:Packages:IR2L_NLSQF:FormFactor_Param1Min_pop"+num2str(which)
		string HighP1Str="root:Packages:IR2L_NLSQF:FormFactor_Param1Max_pop"+num2str(which)
		string P2Str="root:Packages:IR2L_NLSQF:FormFactor_Param2_pop"+num2str(which)
		string FitP2Str="root:Packages:IR2L_NLSQF:FormFactor_Param2Fit_pop"+num2str(which)
		string LowP2Str="root:Packages:IR2L_NLSQF:FormFactor_Param2Min_pop"+num2str(which)
		string HighP2Str="root:Packages:IR2L_NLSQF:FormFactor_Param2Max_pop"+num2str(which)
		string P3Str="root:Packages:IR2L_NLSQF:FormFactor_Param3_pop"+num2str(which)
		string FitP3Str="root:Packages:IR2L_NLSQF:FormFactor_Param3Fit_pop"+num2str(which)
		string LowP3Str="root:Packages:IR2L_NLSQF:FormFactor_Param3Min_pop"+num2str(which)
		string HighP3Str="root:Packages:IR2L_NLSQF:FormFactor_Param3Max_pop"+num2str(which)
		string P4Str="root:Packages:IR2L_NLSQF:FormFactor_Param4_pop"+num2str(which)
		string FitP4Str="root:Packages:IR2L_NLSQF:FormFactor_Param4Fit_pop"+num2str(which)
		string LowP4Str="root:Packages:IR2L_NLSQF:FormFactor_Param4Min_pop"+num2str(which)
		string HighP4Str="root:Packages:IR2L_NLSQF:FormFactor_Param4Max_pop"+num2str(which)
		string P5Str="root:Packages:IR2L_NLSQF:FormFactor_Param5_pop"+num2str(which)
		string FitP5Str="root:Packages:IR2L_NLSQF:FormFactor_Param5Fit_pop"+num2str(which)
		string LowP5Str="root:Packages:IR2L_NLSQF:FormFactor_Param5Min_pop"+num2str(which)
		string HighP5Str="root:Packages:IR2L_NLSQF:FormFactor_Param5Max_pop"+num2str(which)
		string FFUserFFformula="root:Packages:IR2L_NLSQF:FFUserFFformula_pop"+num2str(which)
		string FFUserVolumeFormula="root:Packages:IR2L_NLSQF:FFUserVolumeFormula_pop"+num2str(which)
			
		string P6Str="root:Packages:IR2L_NLSQF:FormFactor_Param6_pop"+num2str(which)
		string FitP6Str="root:Packages:IR2L_NLSQF:FormFactor_Param6Fit_pop"+num2str(which)
		string LowP6Str="root:Packages:IR2L_NLSQF:FormFactor_Param6Min_pop"+num2str(which)
		string HighP6Str="root:Packages:IR2L_NLSQF:FormFactor_Param6Max_pop"+num2str(which)
	 
	 	IR1T_MakeFFParamPanel(TitleStr,FFStr,P1Str,FitP1Str,LowP1Str,HighP1Str,P2Str,FitP2Str,LowP2Str,HighP2Str,P3Str,FitP3Str,LowP3Str,HighP3Str,P4Str,FitP4Str,LowP4Str,HighP4Str,P5Str,FitP5Str,LowP5Str,HighP5Str,FFUserFFformula,FFUserVolumeFormula, P6Str=P6Str,FitP6Str=FitP6Str,LowP6Str=LowP6Str,HighP6Str=HighP6Str,NoFittingLimits=NoFittingLimits)
	endif
	
	DoWIndow  FormFactorControlScreen
	if(V_Flag)
			SetWindow FormFactorControlScreen  hook(Update)=IR2L_UpdateHook
			SetDrawEnv /W=FormFactorControlScreen fstyle= 3
	endif

end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_MakeFFParamPanel(TitleStr, which)
	variable which
	string TitleStr
	
	DFref oldDf= GetDataFolderDFR()

	
	KillWIndow/Z FormFactorControlScreen
 	//make the new panel 
	NewPanel/K=1 /W=(96,94,530,370) as "FormFactorControlScreen"
	DoWindow/C FormFactorControlScreen
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 3,textrgb= (0,12800,52224)
	DrawText 32,34,TitleStr
	SetDrawEnv fstyle= 1
	DrawText 80,93,"Parameter value"
	SetDrawEnv fstyle= 1
	DrawText 201,93,"Fit?"
	SetDrawEnv fstyle= 1
	DrawText 236,93,"Low limit?"
	SetDrawEnv fstyle= 1
	DrawText 326,93,"High Limit"
		//UF_RGCO;UF_K;UF_LinkRGCO;UF_LinkRGCOLevel
//first variable......
	NVAR UF_RGCO=$("root:Packages:IR2L_NLSQF:UF_RGCO_pop"+num2str(which))
	SetVariable UF_RGCO,limits={0,Inf,0},variable= $("root:Packages:IR2L_NLSQF:UF_RGCO_pop"+num2str(which)), noproc//=IR1T_FFCntrlPnlSetVarProc
	SetVariable UF_RGCO,pos={5,100},size={180,15},title="Rg cut off = ", help={"Rg cut off for higher Unified levels, see reference or manual for meaning"}
	CheckBox FitP1Value,pos={200,100},size={25,16},title=" ",noproc//=IR1T_FFCntrlPnlCheckboxProc
	CheckBox FitP1Value,variable= $("root:Packages:IR2L_NLSQF:UF_RGCOFit_pop"+num2str(which)), help={"Fit this parameter?"}
	SetVariable P1LowLim,limits={0,Inf,0},variable=$("root:Packages:IR2L_NLSQF:UF_RGCOMin_pop"+num2str(which))//, disable=!disableMe
	SetVariable P1LowLim,pos={220,100},size={80,15},title=" ", help={"Low limit for fitting param 1"}
	SetVariable P1HighLim,limits={0,Inf,0},variable= $("root:Packages:IR2L_NLSQF:UF_RGCOMax_pop"+num2str(which))//, disable=!disableMe
	SetVariable P1HighLim,pos={320,100},size={80,15},title=" ", help={"High limit for fitting param 1"}

//	PopupMenu KFactor,pos={10,135},size={170,21},proc=IR2L_PanelPopupControl,title="k factor :"
//	PopupMenu KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}
	
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_Data_TabPanelControl(name,tab)
	String name
	Variable tab

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

		SVAR rgbIntensity_set=$("root:Packages:IR2L_NLSQF:rgbIntensity_set"+num2str(tab+1))
		Execute("Button AddDataSet,win=LSQF2_MainPanel, fColor="+rgbIntensity_set)
		variable i
		NVAR DisplayInputDataControls=root:Packages:IR2L_NLSQF:DisplayInputDataControls
		NVAR DisplayModelControls=root:Packages:IR2L_NLSQF:DisplayModelControls
		NVAR displayControls = $("UseTheData_set"+num2str(tab+1))
		NVAR DisplayFitRange = $("BackgroundFit_set"+num2str(tab+1))
		NVAR DisplaySlitSmeared = $("SlitSmeared_set"+num2str(tab+1))
		Wave/Z InputIntensity= $("Intensity_set"+num2str(tab+1))
		Wave/Z InputQ=$("Q_set"+num2str(tab+1))
		Wave/Z InputError= $("Error_set"+num2str(tab+1))
		variable displayUseCheckbox=1
		if(!WaveExists(InputIntensity) || !WaveExists(InputQ) || !WaveExists(InputError))
			displayUseCheckbox=0
			displayControls = 0
		endif

		Button AddDataSet, win=LSQF2_MainPanel, disable=( !DisplayInputDataControls)
		Button RemovePointWcsrA, win=LSQF2_MainPanel, disable=( !DisplayInputDataControls || !displayControls) 
		Button ReadCursors, win=LSQF2_MainPanel,disable=( !DisplayInputDataControls || !displayControls) 
		CheckBox UseTheData_set ,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:$("UseTheData_set"+num2str(tab+1)), disable=( !DisplayInputDataControls|| !displayUseCheckbox)
//		Execute("CheckBox UseTheData_set ,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(tab+1)+", disable=( !"+num2str(DisplayInputDataControls)+"||!"+num2str(displayUseCheckbox)+")")
		CheckBox UseSmearing_set ,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:$("UseSmearing_set"+num2str(tab+1)), disable=( !(displayControls)||!(DisplayInputDataControls))
//		SetVariable SlitLength_set ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:$("SlitLength_set"+num2str(tab+1)), disable=( !(displayControls)||!(DisplaySlitSmeared)||!(DisplayInputDataControls))
		SetVariable FolderName_set ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:$("FolderName_set"+num2str(tab+1)), disable=( !(DisplayInputDataControls)||!(displayUseCheckbox))
		SetVariable UserDataSetName_set ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:$("UserDataSetName_set"+num2str(tab+1)), disable=( !(DisplayInputDataControls)||!(displayUseCheckbox))
		SetVariable Qmin_set ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:$("Qmin_set"+num2str(tab+1)), disable=( !(displayControls)||!(DisplayInputDataControls))
		SetVariable Qmax_set ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:$("Qmax_set"+num2str(tab+1)), disable=( !(displayControls)||!(DisplayInputDataControls))
		
		NVAR Background = $("root:Packages:IR2L_NLSQF:Background_set"+num2str(tab+1))
		NVAR BckgStep = $("root:Packages:IR2L_NLSQF:BackgStep_set"+num2str(tab+1))
		BckgStep = 0.05 * Background 
		SetVariable Background ,win=LSQF2_MainPanel ,limits={0,Inf,BckgStep}, variable=root:Packages:IR2L_NLSQF:$("Background_set"+num2str(tab+1)), disable=( !(displayControls)||!(DisplayInputDataControls))
//		Execute("SetVariable Background ,win=LSQF2_MainPanel ,limits={0,Inf,"+num2str(BckgStep)+"}, variable=root:Packages:IR2L_NLSQF:Background_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		SetVariable BackgroundMin ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:$("BackgroundMin_set"+num2str(tab+1)), disable=( !(displayControls)||!(DisplayFitRange)||!(DisplayInputDataControls))
		SetVariable BackgroundMax ,win=LSQF2_MainPanel ,variable=root:Packages:IR2L_NLSQF:$("BackgroundMax_set"+num2str(tab+1)), disable=( !(displayControls)||!(DisplayFitRange)||!(DisplayInputDataControls))
		CheckBox BackgroundFit_set ,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:$("BackgroundFit_set"+num2str(tab+1)), disable=( !(displayControls)||!(DisplayInputDataControls))		
		SetVariable DataScalingFactor_set,win=LSQF2_MainPanel,value= root:Packages:IR2L_NLSQF:$("DataScalingFactor_set"+num2str(tab+1)), disable=( !(displayControls)||!(DisplayInputDataControls))
		CheckBox UseUserErrors_set,win=LSQF2_MainPanel, variable= root:Packages:IR2L_NLSQF:$("UseUserErrors_set"+num2str(tab+1)), disable=( !(displayControls)||!(DisplayInputDataControls))
		CheckBox UseSQRTErrors_set,win=LSQF2_MainPanel, variable= root:Packages:IR2L_NLSQF:$("UseSQRTErrors_set"+num2str(tab+1)), disable=( !(displayControls)||!(DisplayInputDataControls))
		CheckBox UsePercentErrors_set,win=LSQF2_MainPanel, variable= root:Packages:IR2L_NLSQF:$("UsePercentErrors_set"+num2str(tab+1)), disable=( !(displayControls)||!(DisplayInputDataControls))
		SetVariable ErrorScalingFactor_set,win=LSQF2_MainPanel,value= root:Packages:IR2L_NLSQF:$("ErrorScalingFactor_set"+num2str(tab+1)), disable=( !(displayControls)||!(DisplayInputDataControls))
			
	setDataFolder OldDf
	IR2L_AppendOrRemoveLocalPopInts()
	DoWindow/F LSQF2_MainPanel
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_Model_TabPanelControl(name,tab)
	String name
	Variable tab

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	
	NVAR DisplayInputDataControls=root:Packages:IR2L_NLSQF:DisplayInputDataControls
	NVAR DisplayModelControls=root:Packages:IR2L_NLSQF:DisplayModelControls
	NVAR NoFittingLimits = root:Packages:IR2L_NLSQF:NoFittingLimits
	NVAR UsePop=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(tab+1))
	NVAR RdistAuto=$("root:Packages:IR2L_NLSQF:RdistAuto_pop"+num2str(tab+1))
	NVAR RdistManual=$("root:Packages:IR2L_NLSQF:RdistMan_pop"+num2str(tab+1))
	NVAR DisplayVolumeLims=$("root:Packages:IR2L_NLSQF:VolumeFit_pop"+num2str(tab+1))
	NVAR SameContr=root:Packages:IR2L_NLSQF:SameContrastForDataSets
	NVAR MID=root:Packages:IR2L_NLSQF:MultipleInputData
	NVAR UD1=UseTheData_set1
	NVAR UD2=UseTheData_set2
	NVAR UD3=UseTheData_set3
	NVAR UD4=UseTheData_set4
	NVAR UD5=UseTheData_set5
	NVAR UD6=UseTheData_set6
	NVAR UD7=UseTheData_set7
	NVAR UD8=UseTheData_set8
	NVAR UD9=UseTheData_set9
	NVAR UD10=UseTheData_set10
	SVAR Shape=$("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(tab+1))
	SVAR FormFactor=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(tab+1))
	SVAR Model=$("root:Packages:IR2L_NLSQF:Model_pop"+num2str(tab+1))
	SVAR PeakProfile=$("root:Packages:IR2L_NLSQF:DiffPeakProfile_pop"+num2str(tab+1))
	variable S_sw, F_sw,CS_sw, Dif_sw, tempVar
	string tempStr
	if(stringmatch(PeakProfile, "Pseudo-Voigt")||stringmatch(PeakProfile, "Pearson_VII")||stringmatch(PeakProfile, "Modif_Gauss")||stringmatch(PeakProfile, "SkewedNormal"))
		Dif_sw=1
	else
		Dif_sw=0
	endif
	
	
	if(stringmatch(Model, "Unified level"))
		F_sw=0
	elseif(stringmatch(Model, "Size dist."))
		F_sw=1			//we have Particulate system.
	elseif(stringmatch(Model, "Diffraction Peak"))
		F_sw=2			//we have Diffraction peak.
	elseif(stringmatch(Model, "MassFractal"))
		F_sw=3		//MassFractal.
	elseif(stringmatch(Model, "SurfaceFractal"))
		F_sw=4		//SurfaceFractal.
	else
		F_sw=5		//unused yet.
	endif
	if(stringmatch(FormFactor, "CoreShell*") || stringmatch(FormFactor, "Janus CoreShell Micelle*"))
		CS_sw=0
	else
		CS_sw=1			//we have delta rho squared not rho here.
	endif
	
	if(stringmatch(Shape, "LogNormal"))
		S_sw=1
	elseif(stringmatch(Shape, "Gauss"))
		S_sw=2
	elseif(stringmatch(Shape, "Schulz-Zimm"))
		S_sw=4
	elseif(stringmatch(Shape, "Ardell"))
		S_sw=5
	else
		S_sw=3			//we have LSW....
	endif


		CheckBox UseThePop,win=LSQF2_MainPanel ,variable=root:Packages:IR2L_NLSQF:$("UseThePop_pop"+num2str(tab+1)), disable=(!(DisplayModelControls))
		SetVariable UserName,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UserName_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(UsePop))
		SVAR tempSVR=$("root:Packages:IR2L_NLSQF:Model_pop"+num2str(tab+1))
		PopupMenu PopulationType,win=LSQF2_MainPanel, mode=(WhichListItem(tempSVR,"Size dist.;Unified level;Diffraction Peak;MassFractal;SurfaceFractal;")+1), disable=(!(DisplayModelControls)|| !(UsePop))
		
		
		CheckBox RdistAuto,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:$("RdistAuto_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(UsePop))
		CheckBox RdistrSemiAuto,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:$("RdistrSemiAuto_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(UsePop))
		CheckBox RdistMan,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:$("RdistMan_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(UsePop))

		SetVariable RdistNumPnts,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("RdistNumPnts_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(UsePop))
		SetVariable RdistManMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("RdistManMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(UsePop)|| (!RdistManual))
		SetVariable RdistManMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("RdistManMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(UsePop)|| (!RdistManual))

		SetVariable RdistNeglectTails,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("RdistNeglectTails_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(UsePop)|| (RdistManual))

		CheckBox RdistLog,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:$("RdistLog_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(UsePop))

		SVAR tempSVR=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(tab+1))
		SVAR tempSVR2=root:Packages:FormFactorCalc:ListOfFormFactors
		PopupMenu FormFactorPop,win=LSQF2_MainPanel, mode=(WhichListItem(tempSVR,tempSVR2+"Unified_Level;")+1), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(UsePop))
		SetVariable SizeDist_DimensionType,win=LSQF2_MainPanel,  disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(UsePop))
		Button GetFFHelp,win=LSQF2_MainPanel, disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(UsePop))

		SVAR tempSVR=$("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(tab+1))
		PopupMenu PopSizeDistShape,win=LSQF2_MainPanel, mode=(WhichListItem(tempSVR,"LogNormal;Gauss;LSW;Schulz-Zimm;Ardell;")+1), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(UsePop))
		//diffraction stuff
		SVAR tempSVR=$("root:Packages:IR2L_NLSQF:DiffPeakProfile_pop"+num2str(tab+1))
		SVAR tempSVR2=root:Packages:IR2L_NLSQF:ListOfKnownPeakShapes
		PopupMenu DiffPeakProfile,win=LSQF2_MainPanel, mode=(WhichListItem(tempSVR,tempSVR2)+1), disable=(!(DisplayModelControls)|| !(F_sw==2)|| !(UsePop))
		SetVariable DiffPeakPar1,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakPar1_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==2)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:DiffPeakPar1_pop"+num2str(tab+1))
		SetVariable DiffPeakPar1,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox DiffPeakPar1Fit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakPar1Fit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==2)|| !(UsePop))
		SetVariable DiffPeakPar1Min,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakPar1Min_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==2)|| !(UsePop))
		SetVariable DiffPeakPar1Max,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakPar1Max_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==2)|| !(UsePop))

		SetVariable DiffPeakPar2,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakPar2_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==2)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:DiffPeakPar2_pop"+num2str(tab+1))
		SetVariable DiffPeakPar2,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox DiffPeakPar2Fit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakPar2Fit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==2)|| !(UsePop))
		SetVariable DiffPeakPar2Min,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakPar2Min_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==2)|| !(UsePop))
		SetVariable DiffPeakPar2Max,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakPar2Max_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==2)|| !(UsePop))

		SetVariable DiffPeakPar3,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakPar3_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==2)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:DiffPeakPar3_pop"+num2str(tab+1))
		SetVariable DiffPeakPar3,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox DiffPeakPar3Fit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakPar3Fit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==2)|| !(UsePop))
		SetVariable DiffPeakPar3Min,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakPar3Min_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==2)|| !(UsePop))
		SetVariable DiffPeakPar3Max,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakPar3Max_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==2)|| !(UsePop))
		
		if(stringmatch(PeakProfile, "Pseudo-Voigt"))
			SetVariable DiffPeakPar4,win=LSQF2_MainPanel, title="Eta           = "
		elseif(stringmatch(PeakProfile, "Pearson_VII")||stringmatch(PeakProfile, "Modif_Gauss"))
			SetVariable DiffPeakPar4,win=LSQF2_MainPanel, title="Tail Param = "
		elseif(stringmatch(PeakProfile, "SkewedNormal"))	
			SetVariable DiffPeakPar4,win=LSQF2_MainPanel, title="Skewness = "
		endif
		SetVariable DiffPeakPar4,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakPar4_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(Dif_sw==1)|| !(F_sw==2)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:DiffPeakPar4_pop"+num2str(tab+1))
		SetVariable DiffPeakPar4,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox DiffPeakPar4Fit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakPar4Fit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(Dif_sw==1)|| !(F_sw==2)|| !(UsePop))
		SetVariable DiffPeakPar4Min,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakPar4Min_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(Dif_sw==1)|| !(F_sw==2)|| !(UsePop))
		SetVariable DiffPeakPar4Max,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakPar4Max_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(Dif_sw==1)|| !(F_sw==2)|| !(UsePop))
		variable tempSw
		if((DisplayModelControls)&&(F_sw==2)&&(UsePop==1))
			tempSw=2
		else
			tempSw=1
		endif
		SetVariable DiffPeakDPos,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakDPos_pop"+num2str(tab+1)), disable=((tempSw))
		SetVariable DiffPeakQPos,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakQPos_pop"+num2str(tab+1)), disable=((tempSw))
		SetVariable DiffPeakQFWHM,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakQFWHM_pop"+num2str(tab+1)), disable=((tempSw))
		SetVariable DiffPeakIntgInt,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("DiffPeakIntgInt_pop"+num2str(tab+1)), disable=((tempSw))

		//MassFractal
		//PopupMenu DiffPeakProfile,win=LSQF2_MainPanel, mode=(WhichListItem(root:Packages:IR2L_NLSQF:$("DiffPeakProfile_pop"+num2str(tab+1)),root:Packages:IR2L_NLSQF:$("ListOfKnownPeakShapes)+1), disable=(!(DisplayModelControls)|| !(F_sw==2)|| !(UsePop))")
		SetVariable MassFrPhi,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrPhi_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==3)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:MassFrPhi_pop"+num2str(tab+1))
		SetVariable MassFrPhi,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox MassFrPhiFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrPhiFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==3)|| !(UsePop))
		SetVariable MassFrPhiMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrPhiMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==3)|| !(UsePop))
		SetVariable MassFrPhiMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrPhiMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==3)|| !(UsePop))

		SetVariable MassFrRadius,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrRadius_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==3)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:MassFrRadius_pop"+num2str(tab+1))
		SetVariable MassFrRadius,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox MassFrRadiusFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrRadiusFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==3)|| !(UsePop))
		SetVariable MassFrRadiusMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrRadiusMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==3)|| !(UsePop))
		SetVariable MassFrRadiusMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrRadiusMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==3)|| !(UsePop))

		SetVariable MassFrDv,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrDv_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==3)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:MassFrDv_pop"+num2str(tab+1))
		SetVariable MassFrDv,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox MassFrDvFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrDvFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==3)|| !(UsePop))
		SetVariable MassFrDvMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrDvMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==3)|| !(UsePop))
		SetVariable MassFrDvMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrDvMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==3)|| !(UsePop))

		SetVariable MassFrKsi,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrKsi_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==3)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:MassFrKsi_pop"+num2str(tab+1))
		SetVariable MassFrKsi,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox MassFrUseUFFF,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrUseUFFF_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==3)|| !(UsePop))
		Checkbox MassFrKsiFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrKsiFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==3)|| !(UsePop))
		SetVariable MassFrKsiMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrKsiMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==3)|| !(UsePop))
		SetVariable MassFrKsiMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrKsiMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==3)|| !(UsePop))

		SetVariable MassFrEta,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrEta_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==3)|| !(UsePop))
		SetVariable MassFrIntgNumPnts,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrIntgNumPnts_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==3)|| !(UsePop))
		NVAR UseUFFF = $("root:Packages:IR2L_NLSQF:MassFrUseUFFF_pop"+num2str(tab+1))
		SetVariable MassFrPDI,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrPDI_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==3)|| !(UsePop) || !UseUFFF)
		SetVariable MassFrBeta,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("MassFrBeta_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==3)|| !(UsePop) || UseUFFF)


		//SurfaceFractal
		//PopupMenu SurfFr1_QcW,win=LSQF2_MainPanel, mode=(WhichListItem(root:Packages:IR2L_NLSQF:$("DiffPeakProfile_pop"+num2str(tab+1)),root:Packages:IR2L_NLSQF:$("ListOfKnownPeakShapes)+1), disable=(!(DisplayModelControls)|| !(F_sw==2)|| !(UsePop))")
		//		SVAR tempSVR=$("root:Packages:IR2L_NLSQF:Model_pop"+num2str(tab+1))

		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:SurfFrQcWidth_pop"+num2str(tab+1))
		PopupMenu SurfFrQcWidth,win=LSQF2_MainPanel, mode=(whichListItem(num2str(100*tempNVR), "5;10;15;20;25;")+1), disable=(!(DisplayModelControls)|| !(F_sw==4)|| !(UsePop))
		
		SetVariable SurfFrSurf,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SurfFrSurf_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==4)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:SurfFrSurf_pop"+num2str(tab+1))
		SetVariable SurfFrSurf,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox SurfFrSurfFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SurfFrSurfFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==4)|| !(UsePop))
		SetVariable SurfFrSurfMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SurfFrSurfMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==4)|| !(UsePop))
		SetVariable SurfFrSurfMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SurfFrSurfMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==4)|| !(UsePop))

		SetVariable SurfFrDS,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SurfFrDS_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==4)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:SurfFrDS_pop"+num2str(tab+1))
		SetVariable SurfFrDS,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox SurfFrDSFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SurfFrDSFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==4)|| !(UsePop))
		SetVariable SurfFrDSMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SurfFrDSMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==4)|| !(UsePop))
		SetVariable SurfFrDSMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SurfFrDSMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==4)|| !(UsePop))

		SetVariable SurfFrKsi,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SurfFrKsi_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==4)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:SurfFrKsi_pop"+num2str(tab+1))
		SetVariable SurfFrKsi,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox SurfFrKsiFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SurfFrKsiFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==4)|| !(UsePop))
		SetVariable SurfFrKsiMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SurfFrKsiMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==4)|| !(UsePop))
		SetVariable SurfFrKsiMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SurfFrKsiMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==4)|| !(UsePop))

		SetVariable SurfFrQc,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SurfFrQc_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==4)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:SurfFrQc_pop"+num2str(tab+1))
		SetVariable SurfFrQc,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}

		//size dist controls

		SetVariable Volume,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("Volume_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:Volume_pop"+num2str(tab+1))
		SetVariable Volume,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox FitVolume,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("VolumeFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(UsePop))
		SetVariable VolumeMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("VolumeMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(UsePop)|| !(DisplayVolumeLims))
		SetVariable VolumeMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("VolumeMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(UsePop)|| !(DisplayVolumeLims))

		NVAR DLNM1=$("root:Packages:IR2L_NLSQF:LNMinSizeFit_pop"+num2str(tab+1))
		SetVariable LNMinSize,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("LNMinSize_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==1)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:LNMinSize_pop"+num2str(tab+1))
		SetVariable LNMinSize,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox LNMinSizeFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("LNMinSizeFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==1)|| !(UsePop))
		SetVariable LNMinSizeMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("LNMinSizeMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==1)|| !(UsePop)|| !(DLNM1))
		SetVariable LNMinSizeMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("LNMinSizeMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==1)|| !(UsePop)|| !(DLNM1))

		NVAR DLNM2=$("root:Packages:IR2L_NLSQF:LNMeanSizeFit_pop"+num2str(tab+1))
		SetVariable LNMeanSize,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("LNMeanSize_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==1)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:LNMeanSize_pop"+num2str(tab+1))
		SetVariable LNMeanSize,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox LNMeanSizeFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("LNMeanSizeFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==1)|| !(UsePop))
		SetVariable LNMeanSizeMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("LNMeanSizeMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==1)|| !(UsePop)|| !(DLNM2))
		SetVariable LNMeanSizeMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("LNMeanSizeMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==1)|| !(UsePop)|| !(DLNM2))

		NVAR DLNM3=$("root:Packages:IR2L_NLSQF:LNSdeviationFit_pop"+num2str(tab+1))
		SetVariable LNSdeviation,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("LNSdeviation_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==1)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:LNSdeviation_pop"+num2str(tab+1))
		SetVariable LNSdeviation,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox LNSdeviationFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("LNSdeviationFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==1)|| !(UsePop))
		SetVariable LNSdeviationMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("LNSdeviationMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==1)|| !(UsePop)|| !(DLNM3))
		SetVariable LNSdeviationMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("LNSdeviationMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==1)|| !(UsePop)|| !(DLNM3))

		NVAR DGM1=$("root:Packages:IR2L_NLSQF:GMeanSizeFit_pop"+num2str(tab+1))
		SetVariable GMeanSize,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("GMeanSize_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==2)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:GMeanSize_pop"+num2str(tab+1))
		SetVariable GMeanSize,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox GMeanSizeFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("GMeanSizeFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==2)|| !(UsePop))
		SetVariable GMeanSizeMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("GMeanSizeMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==2)|| !(UsePop)|| !(DGM1))
		SetVariable GMeanSizeMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("GMeanSizeMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==2)|| !(UsePop)|| !(DGM1))

		NVAR DGM2=$("root:Packages:IR2L_NLSQF:GWidthFit_pop"+num2str(tab+1))
		SetVariable GWidth,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("GWidth_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==2)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(tab+1))
		SetVariable GWidth,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox GWidthFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("GWidthFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==2)|| !(UsePop))
		SetVariable GWidthMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("GWidthMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==2)|| !(UsePop)|| !(DGM2))
		SetVariable GWidthMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("GWidthMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==2)|| !(UsePop)|| !(DGM2))

		NVAR DSZM1=$("root:Packages:IR2L_NLSQF:SZMeanSizeFit_pop"+num2str(tab+1))
		SetVariable SZMeanSize,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SZMeanSize_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==4)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:SZMeanSize_pop"+num2str(tab+1))
		SetVariable SZMeanSize,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox SZMeanSizeFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SZMeanSizeFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==4)|| !(UsePop))
		SetVariable SZMeanSizeMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SZMeanSizeMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==4)|| !(UsePop)|| !(DSZM1))
		SetVariable SZMeanSizeMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SZMeanSizeMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==4)|| !(UsePop)|| !(DSZM1))

		NVAR DSZM2=$("root:Packages:IR2L_NLSQF:SZWidthFit_pop"+num2str(tab+1))
		SetVariable SZWidth,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SZWidth_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==4)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:SZWidth_pop"+num2str(tab+1))
		SetVariable SZWidth,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox SZWidthFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SZWidthFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==4)|| !(UsePop))
		SetVariable SZWidthMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SZWidthMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==4)|| !(UsePop)|| !(DSZM2))
		SetVariable SZWidthMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("SZWidthMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==4)|| !(UsePop)|| !(DSZM2))


		NVAR DLSW1=$("root:Packages:IR2L_NLSQF:LSWLocationFit_pop"+num2str(tab+1))
		SetVariable LSWLocation,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("LSWLocation_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==3)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:LSWLocation_pop"+num2str(tab+1))
		SetVariable LSWLocation,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox LSWLocationFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("LSWLocationFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==3)|| !(UsePop))
		SetVariable LSWLocationMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("LSWLocationMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==3)|| !(UsePop)|| !(DLSW1))
		SetVariable LSWLocationMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("LSWLocationMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==3)|| !(UsePop)|| !(DLSW1))


		NVAR ASZM1=$("root:Packages:IR2L_NLSQF:ArdLocationFit_pop"+num2str(tab+1))
		SetVariable ArdLocation,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("ArdLocation_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==5)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:ArdLocation_pop"+num2str(tab+1))
		SetVariable ArdLocation,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox ArdLocationFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("ArdLocationFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==5)|| !(UsePop))
		SetVariable ArdLocationMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("ArdLocationMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==5)|| !(UsePop)|| !(ASZM1))
		SetVariable ArdLocationMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("ArdLocationMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==5)|| !(UsePop)|| !(ASZM1))

		NVAR ASZM2=$("root:Packages:IR2L_NLSQF:ArdParameterFit_pop"+num2str(tab+1))
		SetVariable ArdParameter,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("ArdParameter_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==5)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:ArdParameter_pop"+num2str(tab+1))
		SetVariable ArdParameter,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox ArdParameterFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("ArdParameterFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(F_sw==1)|| !(S_sw==5)|| !(UsePop))
		SetVariable ArdParameterMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("ArdParameterMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==5) || !(UsePop)|| !(ASZM2))
		SetVariable ArdParameterMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("ArdParameterMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| !(F_sw==1)|| !(S_sw==5)|| !(UsePop)|| !(ASZM2))


		//unified fit controls		
		Button FitRgAndG,win=LSQF2_MainPanel,disable=(!(DisplayModelControls)|| (F_sw)|| !(UsePop))
		Button FitPandB,win=LSQF2_MainPanel,disable=(!(DisplayModelControls)|| (F_sw)|| !(UsePop))

		NVAR UNF1=$("root:Packages:IR2L_NLSQF:UF_GFit_pop"+num2str(tab+1))
		SetVariable UF_G,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_G_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (F_sw)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:UF_G_pop"+num2str(tab+1))
		SetVariable UF_G,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox UF_GFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_GFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (F_sw)|| !(UsePop))
		SetVariable UF_GMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_GMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| (F_sw)|| !(UsePop)|| !(UNF1))
		SetVariable UF_GMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_GMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| (F_sw)|| !(UsePop)|| !(UNF1))

		NVAR UNF2=$("root:Packages:IR2L_NLSQF:UF_RgFit_pop"+num2str(tab+1))
		SetVariable UF_Rg,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_Rg_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (F_sw)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:UF_Rg_pop"+num2str(tab+1))
		SetVariable UF_Rg,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox UF_RgFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_RgFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (F_sw)|| !(UsePop))
		SetVariable UF_RgMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_RgMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| (F_sw)|| !(UsePop)|| !(UNF2))
		SetVariable UF_RgMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_RgMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| (F_sw)|| !(UsePop)|| !(UNF2))

		NVAR UFLB=$("root:Packages:IR2L_NLSQF:UF_LinkB_pop"+num2str(tab+1))
		NVAR UNF3=$("root:Packages:IR2L_NLSQF:UF_BFit_pop"+num2str(tab+1))
		variable showB = !DisplayModelControls || F_sw || !UsePop
		showB = (!showB) && UFLB  ? 2 : showB
		//SetVariable UF_B,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_B_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (F_sw)|| !(UsePop))")
		SetVariable UF_B,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_B_pop"+num2str(tab+1)), disable=((showB))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:UF_B_pop"+num2str(tab+1))
		SetVariable UF_B,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox UF_BFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_BFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (F_sw)|| (UFLB)|| !(UsePop))
		SetVariable UF_BMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_BMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| (UFLB)|| (F_sw)|| !(UsePop)|| !(UNF3))
		SetVariable UF_BMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_BMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| (UFLB)|| (F_sw)|| !(UsePop)|| !(UNF3))

		CheckBox UF_LinkB,variable= root:Packages:IR2L_NLSQF:$("UF_LinkB_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (F_sw)|| !(UsePop))

		NVAR UNF4=$("root:Packages:IR2L_NLSQF:UF_PFit_pop"+num2str(tab+1))
		SetVariable UF_P,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_P_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (F_sw)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:UF_P_pop"+num2str(tab+1))
		SetVariable UF_P,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		Checkbox UF_PFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_PFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (F_sw)|| !(UsePop))
		SetVariable UF_PMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_PMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| (F_sw)|| !(UsePop)|| !(UNF4))
		SetVariable UF_PMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_PMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| (F_sw)|| !(UsePop)|| !(UNF4))

		NVAR UNF5=$("root:Packages:IR2L_NLSQF:UF_RGCOFit_pop"+num2str(tab+1))
		SetVariable UF_RGCO,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_RGCO_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (F_sw)|| !(UsePop))
		NVAR tempNVR=$("root:Packages:IR2L_NLSQF:UF_RGCO_pop"+num2str(tab+1))
		SetVariable UF_RGCO,win=LSQF2_MainPanel, Limits= {0,inf,0.05*tempNVR}
		//Checkbox UF_RGCOFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_RGCOFit_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (F_sw)|| !(UsePop))")
		//SetVariable UF_RGCOMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_RGCOMin_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| (F_sw)|| !(UsePop)|| !(UNF5))")
		//SetVariable UF_RGCOMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("UF_RGCOMax_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| (NoFittingLimits)|| (F_sw)|| !(UsePop)|| !(UNF5))")
		
//		NVAR UF_K=$("root:Packages:IR2L_NLSQF:UF_K_pop"+num2str(tab+1))
//		PopupMenu KFactor,win=LSQF2_MainPanel, mode=(WhichListItem(num2str(UF_K),"1;1.06;")+1), disable=(!(DisplayModelControls)|| (F_sw)|| !(UsePop))

		SVAR StrA=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(tab+1))
		SVAR StrB=root:Packages:StructureFactorCalc:ListOfStructureFactors
		PopupMenu StructureFactorModel win=LSQF2_MainPanel, mode=WhichListItem(StrA,StrB)+1, disable=(!(DisplayModelControls)||! (F_sw<=1)|| !(UsePop))
		Button GetSFHelp win=LSQF2_MainPanel, disable=(!(DisplayModelControls)||! (F_sw<=1)|| !(UsePop))
		//contrasts
		SetVariable Contrast,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("Contrast_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(CS_sw)|| !(UsePop)|| !(!SameContr || !MID))

		SetVariable Contrast_set1,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("Contrast_set1_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(CS_sw)|| !(UD1)|| !(UsePop)|| (!SameContr || !MID))
		SetVariable Contrast_set2,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("Contrast_set2_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(CS_sw)|| !(UD2)|| !(UsePop)|| (!SameContr || !MID))
		SetVariable Contrast_set3,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("Contrast_set3_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(CS_sw)|| !(UD3)|| !(UsePop)|| (!SameContr || !MID))
		SetVariable Contrast_set4,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("Contrast_set4_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(CS_sw)|| !(UD4)|| !(UsePop)|| (!SameContr || !MID))
		SetVariable Contrast_set5,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("Contrast_set5_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(CS_sw)|| !(UD5)|| !(UsePop)|| (!SameContr || !MID))
		SetVariable Contrast_set6,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("Contrast_set6_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(CS_sw)|| !(UD6)|| !(UsePop)|| (!SameContr || !MID))
		SetVariable Contrast_set7,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("Contrast_set7_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(CS_sw)|| !(UD7)|| !(UsePop)|| (!SameContr || !MID))
		SetVariable Contrast_set8,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("Contrast_set8_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(CS_sw)|| !(UD8)|| !(UsePop)|| (!SameContr || !MID))
		SetVariable Contrast_set9,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("Contrast_set9_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(CS_sw)|| !(UD9)|| !(UsePop)|| (!SameContr || !MID))
		SetVariable Contrast_set10,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:$("Contrast_set10_pop"+num2str(tab+1)), disable=(!(DisplayModelControls)|| !(CS_sw)|| !(UD10)|| !(UsePop)|| (!SameContr || !MID))
		
	setDataFolder OldDf
	
	//update the graph with displayed Mean mode etc...
	IR2L_RemLocalGuinPorodFits()
	IR2L_GraphSizeDistUpdate()
	IR2L_AppendOrRemoveLocalPopInts()
	DoWindow/F LSQF2_MainPanel
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_RemLocalGuinPorodFits()
	//remove Local fits from LSQF_MainGraph
	string ListOFDisplayedWave=TraceNameList("LSQF_MainGraph", ";", 5)
	variable i
	For(i=ItemsInList(ListOFDisplayedWave);i>=0;i-=1)
		if(stringmatch(stringfromList(i,ListOFDisplayedWave), "*PowerLaw*" )||stringmatch(stringfromList(i,ListOFDisplayedWave), "*Guinier*" ))
			RemoveFromGraph/W=LSQF_MainGraph $(stringfromList(i,ListOFDisplayedWave))
		endif
	endfor
	
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_SetQminQmaxWCursors(WhichDataSet)
	variable WhichDataSet
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	Wave CurQ=$("Q_set"+num2str(whichDataSet))
	NVAR Qmax_set=$("Qmax_set"+num2str(whichDataSet))
	NVAR Qmin_set=$("Qmin_set"+num2str(whichDataSet))

	if(cmpstr("Intensity_set"+num2str(whichDataSet),stringByKey("TNAME",CsrInfo(A ,"LSQF_MainGraph")))==0)
		Qmin_set=CurQ[pcsr(A, "LSQF_MainGraph")]
	endif
	if(cmpstr("Intensity_set"+num2str(whichDataSet),stringByKey("TNAME",CsrInfo(B ,"LSQF_MainGraph")))==0)
		Qmax_set=CurQ[pcsr(B, "LSQF_MainGraph")]
	endif
	if(Qmin_set>Qmax_set)
		variable tempS
		tempS=Qmin_set
		Qmin_set=Qmax_set
		Qmax_set=tempS
	endif
	IR2L_setQMinMax(whichDataSet)
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_PopSetVarProc(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
//Function IR2L_PopSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName = SV_Struct.ctrlName
	Variable varNum = SV_Struct.dVal
	//String varStr	= SV_Struct.varStr
	String varName = SV_Struct.Vname
	Variable eventMod=SV_Struct.eventMod		
		//Int32 eventMod	Bit 0:	A mouse button is down.
		//	Bit 1:	Shift key is down.
		//	Bit 2:	Option (Macintosh ) or Alt (Windows ) is down.
		//	Bit 3:	Command (Macintosh ) or Ctrl (Windows ) is down.
		//	Bit 4:	Contextual menu click occurred.
	if(SV_struct.eventcode==1 || SV_struct.eventcode==2)
			SV_struct.blockReentry = 1
			DFref oldDf= GetDataFolderDFR()

			setDataFolder root:Packages:IR2L_NLSQF
			variable whichDataSet
			//BackgStep_set
			ControlInfo/W=LSQF2_MainPanel DistTabs
			whichDataSet= V_Value+1
			if(stringmatch(ctrlName,"UF_G"))
				//set volume limits... 
				NVAR UF_G=$("root:Packages:IR2L_NLSQF:UF_G_pop"+num2str(whichDataSet))
				NVAR UF_Rg=$("root:Packages:IR2L_NLSQF:UF_Rg_pop"+num2str(whichDataSet))
				NVAR UF_GFit=$("root:Packages:IR2L_NLSQF:UF_GFit_pop"+num2str(whichDataSet))
				NVAR UF_RgFit=$("root:Packages:IR2L_NLSQF:UF_RgFit_pop"+num2str(whichDataSet))
				if(UF_G<=0)
					UF_Rg=1e10
					UF_GFit=0
					UF_RgFit=0
					IR2L_Model_TabPanelControl("",V_Value)
				else
					NVAR UF_GMin=$("root:Packages:IR2L_NLSQF:UF_GMin_pop"+num2str(whichDataSet))
					NVAR UF_GMax=$("root:Packages:IR2L_NLSQF:UF_GMax_pop"+num2str(whichDataSet))
					UF_GMin= varNum*0.1
					UF_GMax=varNum*10
					if(eventMod>3)		//any key is down, make small step
						SetVariable UF_G,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}	
					else
						SetVariable UF_G,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}	
					endif
				endif
			endif
			if(stringmatch(ctrlName,"UF_Rg"))
				//set volume limits... 
				NVAR UF_RgMin=$("root:Packages:IR2L_NLSQF:UF_RgMin_pop"+num2str(whichDataSet))
				NVAR UF_RgMax=$("root:Packages:IR2L_NLSQF:UF_RgMax_pop"+num2str(whichDataSet))
				UF_RgMin= varNum*0.1
				UF_RgMax=varNum*10
				if(eventMod>3)		//any key is down, make small step
					SetVariable UF_Rg,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}	
				else
					SetVariable UF_Rg,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}	
				endif			
			endif
			if(stringmatch(ctrlName,"UF_RgCO"))
				//set volume limits... 
				NVAR UF_RgCOMin=$("root:Packages:IR2L_NLSQF:UF_RgCOMin_pop"+num2str(whichDataSet))
				NVAR UF_RgCOMax=$("root:Packages:IR2L_NLSQF:UF_RgCOMax_pop"+num2str(whichDataSet))
				UF_RgCOMin= varNum*0.1
				UF_RgCOMax=varNum*10
				if(eventMod>3)		//any key is down, make small step
					SetVariable UF_RgCO,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}	
				else
					SetVariable UF_RgCO,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}	
				endif
			endif
			if(stringmatch(ctrlName,"UF_B"))
				//set volume limits... 
				NVAR UF_BMin=$("root:Packages:IR2L_NLSQF:UF_BMin_pop"+num2str(whichDataSet))
				NVAR UF_BMax=$("root:Packages:IR2L_NLSQF:UF_BMax_pop"+num2str(whichDataSet))
				UF_BMin= varNum*0.1
				UF_BMax=varNum*10
				if(eventMod>3)		//any key is down, make small step
					SetVariable UF_B,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}	
				else
					SetVariable UF_B,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}	
				endif
			endif
			if(stringmatch(ctrlName,"UF_P"))
				//set volume limits... 
				NVAR UF_PMin=$("root:Packages:IR2L_NLSQF:UF_PMin_pop"+num2str(whichDataSet))
				NVAR UF_PMax=$("root:Packages:IR2L_NLSQF:UF_PMax_pop"+num2str(whichDataSet))
				UF_PMin= (varNum*0.2)>1 ? varNum*0.2 : 1
				UF_PMax=(varNum*2)<4.5 ? (varNum*2) : 4.5
				//SetVariable UF_P,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}	
				if(eventMod>3)		//any key is down, make small step
					SetVariable UF_P,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}	
				else
					SetVariable UF_P,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}	
				endif
			endif
		
				//Fractals
			if(stringmatch(ctrlName,"SurfFrDS"))
				//set fractal dimension limits... 
				NVAR SurfFrDSMin=$("root:Packages:IR2L_NLSQF:SurfFrDSMin_pop"+num2str(whichDataSet))
				NVAR SurfFrDSMax=$("root:Packages:IR2L_NLSQF:SurfFrDSMax_pop"+num2str(whichDataSet))
				SurfFrDSMin= 2.001
				SurfFrDSMax=2.999
				if(eventMod>3)		//any key is down, make small step
					SetVariable SurfFrDS,win=LSQF2_MainPanel,limits={2.001,2.999,(varNum*0.005)}		
				else
					SetVariable SurfFrDS,win=LSQF2_MainPanel,limits={2.001,2.999,(varNum*0.05)}		
				endif
			endif
			if(stringmatch(ctrlName,"MassFrDv"))
				//set fractal dimension limits... 
				NVAR MassFrDvMin=$("root:Packages:IR2L_NLSQF:MassFrDvMin_pop"+num2str(whichDataSet))
				NVAR MassFrDvMax=$("root:Packages:IR2L_NLSQF:MassFrDvMax_pop"+num2str(whichDataSet))
				MassFrDvMin= 1
				MassFrDvMax=2.999					
				if(eventMod>3)		//any key is down, make small step
					SetVariable MassFrDv,win=LSQF2_MainPanel,limits={1,2.999,(varNum*0.005)}	
				else
					SetVariable MassFrDv,win=LSQF2_MainPanel,limits={1,2.999,(varNum*0.05)}	
				endif
			endif
			
		
			if(stringmatch(ctrlName,"DiffPeakPar1"))
				//set volume limits... 
				NVAR VolMin=$("root:Packages:IR2L_NLSQF:DiffPeakPar1Min_pop"+num2str(whichDataSet))
				NVAR VolMax=$("root:Packages:IR2L_NLSQF:DiffPeakPar1Max_pop"+num2str(whichDataSet))
				VolMin= varNum*0.5
				VolMax=varNum*2
					
				if(eventMod>3)		//any key is down, make small step
					SetVariable DiffPeakPar1,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}	
				else
					SetVariable DiffPeakPar1,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}	
				endif
			endif
			if(stringmatch(ctrlName,"DiffPeakPar2"))
				//set volume limits... 
				NVAR VolMin=$("root:Packages:IR2L_NLSQF:DiffPeakPar2Min_pop"+num2str(whichDataSet))
				NVAR VolMax=$("root:Packages:IR2L_NLSQF:DiffPeakPar2Max_pop"+num2str(whichDataSet))
				VolMin= varNum*0.5
				VolMax=varNum*2					
				if(eventMod>3)		//any key is down, make small step
					SetVariable DiffPeakPar2,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}	
				else
					SetVariable DiffPeakPar2,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}	
				endif
			endif
			if(stringmatch(ctrlName,"DiffPeakPar3"))
				//set volume limits... 
				NVAR VolMin=$("root:Packages:IR2L_NLSQF:DiffPeakPar3Min_pop"+num2str(whichDataSet))
				NVAR VolMax=$("root:Packages:IR2L_NLSQF:DiffPeakPar3Max_pop"+num2str(whichDataSet))
				VolMin= varNum*0.5
				VolMax=varNum*2				
				if(eventMod>3)		//any key is down, make small step
					SetVariable DiffPeakPar3,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}	
				else
					SetVariable DiffPeakPar3,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}	
				endif
			endif
			if(stringmatch(ctrlName,"DiffPeakPar4"))
				//set volume limits... 
				NVAR VolMin=$("root:Packages:IR2L_NLSQF:DiffPeakPar4Min_pop"+num2str(whichDataSet))
				NVAR VolMax=$("root:Packages:IR2L_NLSQF:DiffPeakPar4Max_pop"+num2str(whichDataSet))
				VolMin= varNum*0.5
				VolMax=varNum*2					
				if(eventMod>3)		//any key is down, make small step
					SetVariable DiffPeakPar4,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}	
				else
					SetVariable DiffPeakPar4,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}	
				endif
			endif
		
		
		
			if(stringmatch(ctrlName,"Volume"))
				//set volume limits... 
				NVAR VolMin=$("root:Packages:IR2L_NLSQF:VolumeMin_pop"+num2str(whichDataSet))
				NVAR VolMax=$("root:Packages:IR2L_NLSQF:VolumeMax_pop"+num2str(whichDataSet))
				VolMin= varNum*0.5
				VolMax=varNum*2
					
				if(eventMod>3)		//any key is down, make small step
					SetVariable Volume,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}	
				else
					SetVariable Volume,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}	
				endif
			endif
				//LN controls...
		if(stringmatch(ctrlName,"ArdLocation"))
				//set LNMinSize limits... 
				NVAR ArdLocation=$("root:Packages:IR2L_NLSQF:ArdLocation_pop"+num2str(whichDataSet))
				NVAR ArdLocationMin=$("root:Packages:IR2L_NLSQF:ArdLocationMin_pop"+num2str(whichDataSet))
				NVAR ArdLocationMax=$("root:Packages:IR2L_NLSQF:ArdLocationMax_pop"+num2str(whichDataSet))
				if(varNum<3)
					varNum=3
					ArdLocation = 3
					print "Cannot have Log-Normal min size smaller than ~3A, Small-angle scattering theory fails. Reset the value for user."
				endif
				ArdLocationMin= varNum*0.5
				ArdLocationMax=varNum*2			
				if(eventMod>3)		//any key is down, make small step
					SetVariable ArdLocation,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}	
				else
					SetVariable ArdLocation,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}	
				endif
			endif

		if(stringmatch(ctrlName,"ArdParameter"))
				//set LNMinSize limits... 
				NVAR ArdParameter=$("root:Packages:IR2L_NLSQF:ArdParameter_pop"+num2str(whichDataSet))
				NVAR ArdParameterMin=$("root:Packages:IR2L_NLSQF:ArdParameterMin_pop"+num2str(whichDataSet))
				NVAR ArdParameterMax=$("root:Packages:IR2L_NLSQF:ArdParameterMax_pop"+num2str(whichDataSet))
				if(varNum>3)
					varNum=3
					ArdParameter = 3
					print "Ardell parametr is defined only between 2 and 3."
				endif
				if(varNum<2)
					varNum=2
					ArdParameter = 2
					print "Ardell parametr is defined only between 2 and 3."
				endif
				ArdParameterMin= 2
				ArdParameterMax=3			
				if(eventMod>3)		//any key is down, make small step
					SetVariable ArdParameter,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}	
				else
					SetVariable ArdParameter,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}	
				endif
			endif


			if(stringmatch(ctrlName,"LNMinSize"))
				//set LNMinSize limits... 
				NVAR LNMinSize=$("root:Packages:IR2L_NLSQF:LNMinSize_pop"+num2str(whichDataSet))
				NVAR LNMinSizeMin=$("root:Packages:IR2L_NLSQF:LNMinSizeMin_pop"+num2str(whichDataSet))
				NVAR LNMinSizeMax=$("root:Packages:IR2L_NLSQF:LNMinSizeMax_pop"+num2str(whichDataSet))
				if(varNum<2)
					varNum=2
					LNMinSize = 1
					print "Cannot have Log-Normal min size smaller than ~2A, Small-angle scattering theory fails. Reset the value for user."
				endif
				LNMinSizeMin= varNum*0.5
				LNMinSizeMax=varNum*2			
				if(eventMod>3)		//any key is down, make small step
					SetVariable LNMinSize,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}	
				else
					SetVariable LNMinSize,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}	
				endif
			endif
			if(stringmatch(ctrlName,"LNMeanSize"))
				//set LNMeanSize limits... 
				NVAR LNMeanSizeMin=$("root:Packages:IR2L_NLSQF:LNMeanSizeMin_pop"+num2str(whichDataSet))
				NVAR LNMeanSizeMax=$("root:Packages:IR2L_NLSQF:LNMeanSizeMax_pop"+num2str(whichDataSet))
				LNMeanSizeMin= varNum*0.5
				LNMeanSizeMax=varNum*2			
				if(eventMod>3)		//any key is down, make small step
					SetVariable LNMeanSize,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}	
				else
					SetVariable LNMeanSize,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}	
				endif
			endif
			if(stringmatch(ctrlName,"LNSdeviation"))
				//set LNSdeviation limits... 
				NVAR LNSdeviationMin=$("root:Packages:IR2L_NLSQF:LNSdeviationMin_pop"+num2str(whichDataSet))
				NVAR LNSdeviationMax=$("root:Packages:IR2L_NLSQF:LNSdeviationMax_pop"+num2str(whichDataSet))
				LNSdeviationMin= varNum*0.5
				LNSdeviationMax=varNum*2			
				if(eventMod>3)		//any key is down, make small step
						SetVariable LNSdeviation,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}
				else
						SetVariable LNSdeviation,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}
				endif
			endif
				//GW controls
			if(stringmatch(ctrlName,"GMeanSize"))
				//set GMeanSize limits... 
				NVAR GMeanSizeMin=$("root:Packages:IR2L_NLSQF:GMeanSizeMin_pop"+num2str(whichDataSet))
				NVAR GMeanSizeMax=$("root:Packages:IR2L_NLSQF:GMeanSizeMax_pop"+num2str(whichDataSet))
				GMeanSizeMin= varNum*0.5
				GMeanSizeMax=varNum*2
				if(eventMod>3)		//any key is down, make small step
					SetVariable  GMeanSize,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}
				else
					SetVariable  GMeanSize,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}
				endif
			endif
			if(stringmatch(ctrlName,"GWidth"))
				//set GWidth limits... 
				NVAR GWidthMin=$("root:Packages:IR2L_NLSQF:GWidthMin_pop"+num2str(whichDataSet))
				NVAR GWidthMax=$("root:Packages:IR2L_NLSQF:GWidthMax_pop"+num2str(whichDataSet))
				GWidthMin= varNum*0.5
				GWidthMax=varNum*2				
				if(eventMod>3)		//any key is down, make small step
						SetVariable  GWidth,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}
				else
						SetVariable  GWidth,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}
				endif
			endif
				//SZ controls
			if(stringmatch(ctrlName,"SZMeanSize"))
				//set GMeanSize limits... 
				NVAR GMeanSizeMin=$("root:Packages:IR2L_NLSQF:SZMeanSizeMin_pop"+num2str(whichDataSet))
				NVAR GMeanSizeMax=$("root:Packages:IR2L_NLSQF:SZMeanSizeMax_pop"+num2str(whichDataSet))
				GMeanSizeMin= varNum*0.5
				GMeanSizeMax=varNum*2				
				if(eventMod>3)		//any key is down, make small step
						SetVariable  SZMeanSize,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}
				else
						SetVariable  SZMeanSize,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}
				endif
			endif
			if(stringmatch(ctrlName,"SZWidth"))
				//set GWidth limits... 
				NVAR GWidthMin=$("root:Packages:IR2L_NLSQF:SZWidthMin_pop"+num2str(whichDataSet))
				NVAR GWidthMax=$("root:Packages:IR2L_NLSQF:SZWidthMax_pop"+num2str(whichDataSet))
				GWidthMin= varNum*0.5
				GWidthMax=varNum*2				
				if(eventMod>3)		//any key is down, make small step
						SetVariable  SZWidth,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.5)}
				else
						SetVariable  SZWidth,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}
				endif
			endif
				//LSW params		
			if(stringmatch(ctrlName,"LSWLocation"))
				//set LSWLocation limits... 
				NVAR LSWLocationMin=$("root:Packages:IR2L_NLSQF:LSWLocationMin_pop"+num2str(whichDataSet))
				NVAR LSWLocationMax=$("root:Packages:IR2L_NLSQF:LSWLocationMax_pop"+num2str(whichDataSet))
				LSWLocationMin= varNum*0.5
				LSWLocationMax=varNum*2				
				if(eventMod>3)		//any key is down, make small step
						SetVariable  LSWLocation,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}
				else
						SetVariable  LSWLocation,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}
				endif
			endif
			if(stringmatch(ctrlName,"StructureParam1"))
				//set LSWLocation limits... 
				NVAR StructureParam1Min=$("root:Packages:IR2L_NLSQF:StructureParam1Min_pop"+num2str(whichDataSet))
				NVAR StructureParam1Max=$("root:Packages:IR2L_NLSQF:StructureParam1Max_pop"+num2str(whichDataSet))
				StructureParam1Min= varNum*0.5
				StructureParam1Max=varNum*2				
				if(eventMod>3)		//any key is down, make small step
						SetVariable  StructureParam1,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}
				else
						SetVariable  StructureParam1,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}
				endif
			endif
			if(stringmatch(ctrlName,"StructureParam2"))
				//set LSWLocation limits... 
				NVAR StructureParam2Min=$("root:Packages:IR2L_NLSQF:StructureParam2Min_pop"+num2str(whichDataSet))
				NVAR StructureParam2Max=$("root:Packages:IR2L_NLSQF:StructureParam2Max_pop"+num2str(whichDataSet))
				StructureParam2Min= varNum*0.5
				StructureParam2Max=varNum*2				
				if(eventMod>3)		//any key is down, make small step
						SetVariable  StructureParam2,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.005)}
				else
						SetVariable  StructureParam2,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}
				endif
			endif
			//contrasts
			
			setDataFolder OldDf
			IR2L_RecalculateIfSelected() 
	endif
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_DataTabSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	variable whichDataSet
	//BackgStep_set
	ControlInfo/W=LSQF2_MainPanel DataTabs
	whichDataSet= V_Value+1
	if(stringmatch(ctrlName, "BackgStep_set"))
		NVAR tmpV = $("root:Packages:IR2L_NLSQF:BackgStep_set"+num2str(whichDataSet))
		SetVariable Background_set,limits={0,Inf,tmpV},win=LSQF2_MainPanel
	endif
	if(stringmatch(ctrlName, "Qmin_set"))
		IR2L_setQMinMax(whichDataSet)
		IR2L_RecalculateIfSelected() 
	endif
	if(stringmatch(ctrlName, "Qmax_set"))
		IR2L_setQMinMax(whichDataSet)
		IR2L_RecalculateIfSelected() 
	endif
	if(stringmatch(ctrlName, "Background"))
		//set Background limits... 
		NVAR BackgroundMin_set=$("root:Packages:IR2L_NLSQF:BackgroundMin_set"+num2str(whichDataSet))
		NVAR BackgroundMax_set=$("root:Packages:IR2L_NLSQF:BackgroundMax_set"+num2str(whichDataSet))
		BackgroundMin_set= varNum*0.01
		BackgroundMax_set=varNum*10
		SetVariable Background,win=LSQF2_MainPanel,limits={0,Inf,(varNum*0.05)}	
		IR2L_RecalculateIfSelected() 
	endif
	if(stringmatch(ctrlName, "UserDataSetName_set"))
		IR2L_FormatLegend()
	endif
	if(stringmatch(ctrlName, "ErrorScalingFactor_set"))
		IR2L_RecalculateIntAndErrors(WhichDataSet)
	endif
	if(stringmatch(ctrlName, "DataScalingFactor_set"))
		IR2L_RecalculateIntAndErrors(WhichDataSet)
	endif

	if(stringMatch(ctrlName,"GraphXMin") ||stringMatch(ctrlName,"GraphXMax") ||stringMatch(ctrlName,"GraphYMin") ||stringMatch(ctrlName,"GraphYMax"))
		IR2L_FormatInputGraph()
	endif
	
	setDataFolder OldDf
end	


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_setQMinMax(whichDataSet)
	variable whichDataSet
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	Wave CurMask=$("IntensityMask_set"+num2str(whichDataSet))
	Wave CurQ=$("Q_set"+num2str(whichDataSet))
	NVAR Qmax_set=$("Qmax_set"+num2str(whichDataSet))
	NVAR Qmin_set=$("Qmin_set"+num2str(whichDataSet))

	variable QminPoint=binarysearch(CurQ, Qmin_set)
	if(QminPoint<0)
		Qmin_set=CurQ[0]
	endif
	if(CurQ[QminPoint]<0)
		QminPoint=binarysearch(CurQ, 0)+1
		Qmin_set = CurQ[QminPoint]
	endif
	
	variable QmaxPoint=binarysearch(CurQ, Qmax_set)
	if(QmaxPoint<0)
		QmaxPoint=numpnts(CurQ)
		Qmax_set=CurQ[inf]
	endif
	
	CurMask[0,QminPoint]=1
	CurMask[QminPoint,QmaxPoint+1]=5
	CurMask[QmaxPoint,inf]=1
	DoWindow LSQF_MainGraph
	if(V_Flag)
		ModifyGraph/Z/W=LSQF_MainGraph zmrkSize( $("Intensity_set"+num2str(whichDataSet)))={$("IntensityMask_set"+num2str(whichDataSet)),0,5,0.5,3}
	endif

	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2L_SetTabsNames()

	//change tab names to have * if used...
	variable i
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	if(MultipleInputData)
		For(i=1;i<=10;i+=1)
			NVAR UseTheTab=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(i))
			if(UseTheTab)
				TabControl DataTabs, win=LSQF2_MainPanel, tabLabel((i-1))="\\Zr125\\K(65535,0,0)"+num2str(i)+"."
			else
				TabControl DataTabs, win=LSQF2_MainPanel, tabLabel((i-1))="\\Zr100\\K(0,0,0)"+num2str(i)+"."
			endif
		endfor
	endif
	For(i=1;i<=10;i+=1)
		NVAR UseTheTab=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(i))
		if(UseTheTab)
			tabControl DistTabs, win=LSQF2_MainPanel, tabLabel(i-1)="\\Zr125\\K(65535,0,0)"+num2str(i)+"P"
		else
			tabControl DistTabs, win=LSQF2_MainPanel, tabLabel(i-1)="\\Zr100\\K(0,0,0)"+num2str(i)+" P"
		endif
	endfor
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************



Function IR2L_ModelTabCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	

	ControlInfo/W=LSQF2_MainPanel DistTabs
	variable WhichPopSet= V_Value+1

	if (stringMatch(ctrlName,"UseThePop"))
		IR2L_SetTabsNames()
	endif
	//RdistrSemiAuto, RdistMan, RdistAuto
	NVAR RdistrSemiAuto=$("root:Packages:IR2L_NLSQF:RdistrSemiAuto_pop"+num2str(WhichPopSet))
	NVAR RdistMan=$("root:Packages:IR2L_NLSQF:RdistMan_pop"+num2str(WhichPopSet))
	NVAR RdistAuto=$("root:Packages:IR2L_NLSQF:RdistAuto_pop"+num2str(WhichPopSet))
	if (stringMatch(ctrlName,"RdistAuto"))
		if(checked)
			RdistAuto=1
			RdistrSemiAuto=0
			RdistMan = 0
		else
			RdistAuto=0
			RdistrSemiAuto=1
			RdistMan = 0
		endif
		SetVariable RdistManMin,win=LSQF2_MainPanel,disable=((RdistAuto))
		SetVariable RdistManMax,win=LSQF2_MainPanel,disable=((RdistAuto))
		SetVariable RdistNeglectTails,win=LSQF2_MainPanel, disable=(!(RdistAuto))
	endif
	if (stringMatch(ctrlName,"RdistrSemiAuto"))
		if(checked)
			RdistAuto=0
			RdistrSemiAuto=1
			RdistMan = 0
		else
			RdistAuto=1
			RdistrSemiAuto=0
			RdistMan = 0
		endif
		SetVariable RdistManMin,win=LSQF2_MainPanel,disable=((RdistrSemiAuto))
		SetVariable RdistManMax,win=LSQF2_MainPanel,disable=((RdistrSemiAuto))
		SetVariable RdistNeglectTails,win=LSQF2_MainPanel, disable=(!(RdistrSemiAuto))
	endif
	if (stringMatch(ctrlName,"RdistMan"))
		if(checked)
			RdistAuto=0
			RdistrSemiAuto=0
			RdistMan = 1
		else
			RdistAuto=1
			RdistrSemiAuto=0
			RdistMan = 0
		endif
		SetVariable RdistManMin,win=LSQF2_MainPanel,disable=(!(RdistMan))
		SetVariable RdistManMax,win=LSQF2_MainPanel,disable=(!(RdistMan))
		SetVariable RdistNeglectTails,win=LSQF2_MainPanel, disable=((RdistMan))
	endif
	
/////////////////////////////
	variable whichDataSet
	//BackgStep_set
	ControlInfo/W=LSQF2_MainPanel DistTabs
	whichDataSet= V_Value+1
	
	if(stringmatch(ctrlName,"FitVolume"))
		//set volume limits... 
		NVAR Vol=$("root:Packages:IR2L_NLSQF:Volume_pop"+num2str(whichDataSet))
		NVAR VolMin=$("root:Packages:IR2L_NLSQF:VolumeMin_pop"+num2str(whichDataSet))
		NVAR VolMax=$("root:Packages:IR2L_NLSQF:VolumeMax_pop"+num2str(whichDataSet))
		VolMin= Vol*0.2
		VolMax=Vol*5
		SetVariable Volume,win=LSQF2_MainPanel,limits={0,Inf,(Vol*0.05)}	
	endif
		//LN controls...
	if(stringmatch(ctrlName,"LNMinSizeFit"))
		//set LNMinSize limits... 
		NVAR LNMinSize=$("root:Packages:IR2L_NLSQF:LNMinSize_pop"+num2str(whichDataSet))
		NVAR LNMinSizeMin=$("root:Packages:IR2L_NLSQF:LNMinSizeMin_pop"+num2str(whichDataSet))
		NVAR LNMinSizeMax=$("root:Packages:IR2L_NLSQF:LNMinSizeMax_pop"+num2str(whichDataSet))
		LNMinSizeMin= LNMinSize*0.1
		LNMinSizeMax=LNMinSize*10
		SetVariable LNMinSize,win=LSQF2_MainPanel,limits={0,Inf,(LNMinSize*0.05)}
	endif
	if(stringmatch(ctrlName,"LNMeanSizeFit"))
		//set LNMeanSize limits... 
		NVAR LNMeanSize=$("root:Packages:IR2L_NLSQF:LNMeanSize_pop"+num2str(whichDataSet))
		NVAR LNMeanSizeMin=$("root:Packages:IR2L_NLSQF:LNMeanSizeMin_pop"+num2str(whichDataSet))
		NVAR LNMeanSizeMax=$("root:Packages:IR2L_NLSQF:LNMeanSizeMax_pop"+num2str(whichDataSet))
		LNMeanSizeMin= LNMeanSize*0.1
		LNMeanSizeMax=LNMeanSize*10
		SetVariable LNMeanSize,win=LSQF2_MainPanel,limits={0,Inf,(LNMeanSize*0.05)}
	endif
	if(stringmatch(ctrlName,"LNSdeviationFit"))
		//set LNSdeviation limits... 
		NVAR LNSdeviation=$("root:Packages:IR2L_NLSQF:LNSdeviation_pop"+num2str(whichDataSet))
		NVAR LNSdeviationMin=$("root:Packages:IR2L_NLSQF:LNSdeviationMin_pop"+num2str(whichDataSet))
		NVAR LNSdeviationMax=$("root:Packages:IR2L_NLSQF:LNSdeviationMax_pop"+num2str(whichDataSet))
		LNSdeviationMin= LNSdeviation*0.1
		LNSdeviationMax=LNSdeviation*10
		SetVariable LNSdeviation,win=LSQF2_MainPanel,limits={0,Inf,(LNSdeviation*0.05)}
	endif
		//GW controls
	if(stringmatch(ctrlName,"GMeanSizeFit"))
		//set GMeanSize limits... 
		NVAR GMeanSize=$("root:Packages:IR2L_NLSQF:GMeanSize_pop"+num2str(whichDataSet))
		NVAR GMeanSizeMin=$("root:Packages:IR2L_NLSQF:GMeanSizeMin_pop"+num2str(whichDataSet))
		NVAR GMeanSizeMax=$("root:Packages:IR2L_NLSQF:GMeanSizeMax_pop"+num2str(whichDataSet))
		GMeanSizeMin= GMeanSize*0.1
		GMeanSizeMax=GMeanSize*10
		SetVariable  GMeanSize,win=LSQF2_MainPanel,limits={0,Inf,(GMeanSize*0.05)}
	endif
	if(stringmatch(ctrlName,"GWidthFit"))
		//set GWidth limits... 
		NVAR GWidth=$("root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(whichDataSet))
		NVAR GWidthMin=$("root:Packages:IR2L_NLSQF:GWidthMin_pop"+num2str(whichDataSet))
		NVAR GWidthMax=$("root:Packages:IR2L_NLSQF:GWidthMax_pop"+num2str(whichDataSet))
		GWidthMin= GWidth*0.1
		GWidthMax=GWidth*10
		SetVariable  GWidth,win=LSQF2_MainPanel,limits={0,Inf,(GWidth*0.05)}
	endif
		//SZ controls
	if(stringmatch(ctrlName,"SZMeanSizeFit"))
		//set GMeanSize limits... 
		NVAR SZMeanSize=$("root:Packages:IR2L_NLSQF:SZMeanSize_pop"+num2str(whichDataSet))
		NVAR SZMeanSizeMin=$("root:Packages:IR2L_NLSQF:SZMeanSizeMin_pop"+num2str(whichDataSet))
		NVAR SZMeanSizeMax=$("root:Packages:IR2L_NLSQF:SZMeanSizeMax_pop"+num2str(whichDataSet))
		SZMeanSizeMin= SZMeanSize*0.1
		SZMeanSizeMax=SZMeanSize*10
		SetVariable  SZMeanSize,win=LSQF2_MainPanel,limits={0,Inf,(SZMeanSize*0.05)}
	endif
	if(stringmatch(ctrlName,"SZWidthFit"))
		//set GWidth limits... 
		NVAR SZWidth=$("root:Packages:IR2L_NLSQF:SZWidth_pop"+num2str(whichDataSet))
		NVAR SZWidthMin=$("root:Packages:IR2L_NLSQF:SZWidthMin_pop"+num2str(whichDataSet))
		NVAR SZWidthMax=$("root:Packages:IR2L_NLSQF:SZWidthMax_pop"+num2str(whichDataSet))
		SZWidthMin= SZWidth*0.1
		SZWidthMax=SZWidth*10
		SetVariable  SZWidth,win=LSQF2_MainPanel,limits={0,Inf,(SZWidth*0.05)}
	endif
		//LSW params		
	if(stringmatch(ctrlName,"LSWLocationFit"))
		//set LSWLocation limits... 
		NVAR LSWLocation=$("root:Packages:IR2L_NLSQF:LSWLocation_pop"+num2str(whichDataSet))
		NVAR LSWLocationMin=$("root:Packages:IR2L_NLSQF:LSWLocationMin_pop"+num2str(whichDataSet))
		NVAR LSWLocationMax=$("root:Packages:IR2L_NLSQF:LSWLocationMax_pop"+num2str(whichDataSet))
		LSWLocationMin= LSWLocation*0.1
		LSWLocationMax=LSWLocation*10
		SetVariable  LSWLocation,win=LSQF2_MainPanel,limits={0,Inf,(LSWLocation*0.05)}
	endif

/////////////////////////////
	ControlInfo/W=LSQF2_MainPanel DistTabs
	variable whichModel= V_Value+1
	if(stringmatch(ctrlName,"UF_LinkB"))	
		NVAR FitB=$("root:Packages:IR2L_NLSQF:UF_BFit_pop"+num2str(whichModel))
		NVAR G=$("root:Packages:IR2L_NLSQF:UF_G_pop"+num2str(whichModel))
		NVAR Rg=$("root:Packages:IR2L_NLSQF:UF_Rg_pop"+num2str(whichModel))
		NVAR LinkB=$("root:Packages:IR2L_NLSQF:UF_LinkB_pop"+num2str(whichModel))
		if(checked)
			if(G==0 || RG>9e9)
				LinkB = 0
				CheckBox UF_LinkB, win=LSQF2_MainPanel, value =0
				Abort "Cannot use this feature when G/Rg are not real particle."
			endif
			FitB=0
		endif
	endif	
	IR2L_Model_TabPanelControl("",V_Value)
	DoWindow/F LSQF2_MainPanel
	if(!stringMatch(ctrlName,"*Fit*"))	//skip recalculations when user select what to fit... No real change was done... 
		IR2L_RecalculateIfSelected()
	endif
	
	
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_RecalculateIntAndErrors(WhichDataSet)
	variable WhichDataSet
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF


	NVAR UseUserErrors = $("UseUserErrors_set"+num2str(WhichDataSet))
	NVAR UseSQRTErrors = $("UseSQRTErrors_set"+num2str(WhichDataSet))
	NVAR UsePercentErrors = $("UsePercentErrors_set"+num2str(WhichDataSet))
	NVAR ErrorScalingFactor = $("ErrorScalingFactor_set"+num2str(WhichDataSet))
		SVAR NewFldrName=$("root:Packages:IR2L_NLSQF:FolderName_set"+num2str(whichDataSet))
		SVAR NewIntName = $("root:Packages:IR2L_NLSQF:IntensityDataName_set"+num2str(whichDataSet))
		SVAR NewQName=$("root:Packages:IR2L_NLSQF:QvecDataName_set"+num2str(whichDataSet))
		SVAR NewErrorName=$("root:Packages:IR2L_NLSQF:ErrorDataName_set"+num2str(whichDataSet))
		NVAR SlitSmeared_set=$("root:Packages:IR2L_NLSQF:SlitSmeared_set"+num2str(whichDataSet))
		NVAR DataScalingFactor_set=$("root:Packages:IR2L_NLSQF:DataScalingFactor_set"+num2str(whichDataSet))
		NVAR RebinDataTo = root:Packages:IR2L_NLSQF:RebinDataTo

	setDataFolder NewFldrName
	wave/Z inputI=$(NewIntName)
	wave/Z inputQ=$(NewQName)
	wave/Z inputE=$(NewErrorName)
	if(!WaveExists(inputE))
		UseUserErrors=0
		if(UseSQRTErrors+UsePercentErrors!=1)
			UseSQRTErrors=1
			UsePercentErrors=0
		endif
	endif
	setDataFolder root:Packages:IR2L_NLSQF
	//first handle restoring proper user data... 
	Duplicate/O inputI, $("Intensity_set"+num2str(whichDataSet))
	Wave IntWv = $("Intensity_set"+num2str(whichDataSet))
	IntWv = DataScalingFactor_set * IntWv						//scale by user factor, if requested. 
	Duplicate/O inputQ, $("Q_set"+num2str(whichDataSet))
	Wave QWv = $("Q_set"+num2str(whichDataSet))
	
	
	if(UseUserErrors)		//handle special cases of errors not loaded in Igor
		Duplicate/O inputE, $("Error_set"+num2str(whichDataSet))		
	elseif(UseSQRTErrors)
		Duplicate/O inputI, $("Error_set"+num2str(whichDataSet))	
		Wave ErrorWv=$("Error_set"+num2str(whichDataSet))	
		Wave IntWv= $("Intensity_set"+num2str(whichDataSet))
		ErrorWv=sqrt(IntWv)
	else
		Duplicate/O inputI, $("Error_set"+num2str(whichDataSet))	
		Wave ErrorWv=$("Error_set"+num2str(whichDataSet))	
		Wave IntWv= $("Intensity_set"+num2str(whichDataSet))
		ErrorWv=0.01*(IntWv)
	endif
	Wave ErrorWv=$("Error_set"+num2str(whichDataSet))	
	ErrorWv = ErrorWv * ErrorScalingFactor
	variable i
	wavestats/Q ErrorWv
	ErrorWv = (numtype(ErrorWv[p])==0) ? ErrorWv[p] : V_min

	//need to make sure all waves are double precision due to some users using weird scaling...
	redimension/D IntWv, QWv, ErrorWv
	
	if(RebinDataTo>0)
		//IR1D_rebinData(IntWv,QWv,ErrorWv,RebinDataTo, 1)
		IN2G_RebinLogData(QWv,IntWv,RebinDataTo,0,Wsdev=ErrorWv)
	endif

	setDataFolder OldDf

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_Initialize()

	DFref oldDf= GetDataFolderDFR()

	setdatafolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S IR2L_NLSQF

	string/g ListOfVariables, ListOfDataVariables, ListOfPopulationVariables, ListOfPopulationVariablesSD, ListOfPopulationVariablesDP, ListOfPopulationVariablesUF, ListOfPopulationVariablesFR
	string/g ListOfStrings, ListOfDataStrings, ListOfPopulationsStrings
	variable i, j
	
	ListOfPopulationsStrings=""	
	ListOfDataStrings=""	

	//here define the lists of variables and strings needed, separate names by ;...
	
	//Main parameters
	ListOfVariables="UseIndra2Data;UseQRSdata;UseSMRData;MultipleInputData;UseNumberDistributions;RecalculateAutomatically;DisplaySinglePopInt;NoFittingLimits;RebinDataTo;"
	ListOfVariables+="SameContrastForDataSets;VaryContrastForDataSets;DisplayInputDataControls;DisplayModelControls;UseGeneticOptimization;UseLSQF;"
	ListOfVariables+="SizeDist_DimensionIsDiameter;DisplaySizeDistPlot;DisplayResidualsPlot;DisplayIQ4vsQplot;"
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;ListOfKnownPeakShapes;"
	ListOfStrings+="DataCalibrationUnits;PanelVolumeDesignation;IntCalibrationUnits;VolDistCalibrationUnits;NumDistCalibrationUnits;"	
	ListOfStrings+="ConfEvListOfParameters;ConEvSelParameter;ConEvMethod;SizeDist_DimensionType;"
	//SizeDist_DimensionType = "Radius" or "Diameter"

	ListOfVariables+="GraphXMin;GraphXMax;GraphYMin;GraphYMax;SizeDistDisplayNumDist;SizeDistDisplayVolDist;"
	ListOfVariables+="GraphXLog;GraphYLog;"
	ListOfVariables+="SizeDistLogVolDist;SizeDistLogNumDist;SizeDistLogX;"
	ListOfVariables+="ConfEvMinVal;ConfEvMaxVal;ConfEvNumSteps;ConfEvVaryParam;ConfEvChiSq;ConfEvAutoOverwrite;ConfEvFixRanges;"
	ListOfVariables+="ConfEvTargetChiSqRange;ConfEvAutoCalcTarget;"

	//Input Data parameters... Will have _setX attached, in this method background needs to be here...
	ListOfDataVariables="UseTheData;SlitSmeared;UseSmearing;SlitLength;SmearingFWHM;SmearingGaussWidth;SmearingMaxNumPnts;Qmin;Qmax;"
	ListOfDataVariables+="SmearingIgnoreSmalldQ;"
	ListOfDataVariables+="Background;BackgroundFit;BackgroundMin;BackgroundMax;BackgErr;BackgStep;"
	ListOfDataVariables+="DataScalingFactor;ErrorScalingFactor;UseUserErrors;UseSQRTErrors;UsePercentErrors;"


	ListOfDataStrings ="FolderName;IntensityDataName;QvecDataName;ErrorDataName;UserDataSetName;SmearingType;SmearingWaveName;"
	
	
	//Common Size distribution Model parameters, these need to have _popX attached at the end of name
	ListOfPopulationVariables="UseThePop;"
	ListOfPopulationVariables+="Contrast;Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"	
		//Form factor parameters
	ListOfPopulationsStrings+="Model;FormFactor;FFUserFFformula;FFUserVolumeFormula;StructureFactor;PopSizeDistShape;SFUserSQFormula;UserName;"	

		//R distribution parameters
	ListOfPopulationVariablesSD="RdistAuto;RdistrSemiAuto;RdistMan;RdistManMin;RdistManMax;RdistLog;RdistNumPnts;RdistNeglectTails;"	
	ListOfPopulationVariablesSD+="FormFactor_Param1;FormFactor_Param1Fit;FormFactor_Param1Min;FormFactor_Param1Max;"	
	ListOfPopulationVariablesSD+="FormFactor_Param2;FormFactor_Param2Fit;FormFactor_Param2Min;FormFactor_Param2Max;"	
	ListOfPopulationVariablesSD+="FormFactor_Param3;FormFactor_Param3Fit;FormFactor_Param3Min;FormFactor_Param3Max;"	
	ListOfPopulationVariablesSD+="FormFactor_Param4;FormFactor_Param4Fit;FormFactor_Param4Min;FormFactor_Param4Max;"	
	ListOfPopulationVariablesSD+="FormFactor_Param5;FormFactor_Param5Fit;FormFactor_Param5Min;FormFactor_Param5Max;"	
	ListOfPopulationVariablesSD+="FormFactor_Param6;FormFactor_Param6Fit;FormFactor_Param6Min;FormFactor_Param6Max;"	
	ListOfPopulationVariablesSD+="FormFactor_Param7;FormFactor_Param7Fit;FormFactor_Param7Min;FormFactor_Param7Max;"	
	ListOfPopulationVariablesSD+="FormFactor_Param8;FormFactor_Param8Fit;FormFactor_Param8Min;FormFactor_Param8Max;"	
	ListOfPopulationVariablesSD+="FormFactor_Param9;FormFactor_Param9Fit;FormFactor_Param9Min;FormFactor_Param9Max;"	
		//Distribution parameters
	ListOfPopulationVariablesSD+="Volume;VolumeFit;VolumeMin;VolumeMax;Mean;Mode;Median;FWHM;Rg;"	
	ListOfPopulationVariablesSD+="LNMinSize;LNMinSizeFit;LNMinSizeMin;LNMinSizeMax;LNMeanSize;LNMeanSizeFit;LNMeanSizeMin;LNMeanSizeMax;LNSdeviation;LNSdeviationFit;LNSdeviationMin;LNSdeviationMax;"	
	ListOfPopulationVariablesSD+="GMeanSize;GMeanSizeFit;GMeanSizeMin;GMeanSizeMax;GWidth;GWidthFit;GWidthMin;GWidthMax;LSWLocation;LSWLocationFit;LSWLocationMin;LSWLocationMax;"	
	ListOfPopulationVariablesSD+="SZMeanSize;SZMeanSizeFit;SZMeanSizeMin;SZMeanSizeMax;SZWidth;SZWidthFit;SZWidthMin;SZWidthMax;"	
	ListOfPopulationVariablesSD+="ArdLocation;ArdLocationFit;ArdLocationMin;ArdLocationMax;ArdParameter;ArdParameterFit;ArdParameterMin;ArdParameterMax;"	

	ListOfPopulationVariablesSD+="StructureParam1;StructureParam1Fit;StructureParam1Min;StructureParam1Max;StructureParam2;StructureParam2Fit;StructureParam2Min;StructureParam2Max;"
	ListOfPopulationVariablesSD+="StructureParam3;StructureParam3Fit;StructureParam3Min;StructureParam3Max;StructureParam4;StructureParam4Fit;StructureParam4Min;StructureParam4Max;"
	ListOfPopulationVariablesSD+="StructureParam5;StructureParam5Fit;StructureParam5Min;StructureParam5Max;StructureParam6;StructureParam6Fit;StructureParam6Min;StructureParam6Max;"
	
		
		//Unified level parameters
	ListOfPopulationVariablesUF="UF_G;UF_GFit;UF_GMin;UF_GMax;UF_Rg;UF_RgFit;UF_RgMin;UF_RgMax;UF_B;UF_BFit;UF_BMin;UF_BMax;UF_P;UF_PFit;UF_PMin;UF_PMax;UF_K;UF_LinkRGCO;UF_LinkRGCOLevel;"//SZWidthMin;SZWidthMax;"	
	ListOfPopulationVariablesUF+="UF_RGCO;UF_RGCOFit;UF_RGCOMin;UF_RGCOMax;UF_LinkB;"
		
		//Diffraction peak parameters
	ListOfPopulationsStrings+="DiffPeakProfile;"	
	ListOfPopulationVariablesDP="DiffPeakDPos;DiffPeakQPos;DiffPeakDFWHM;DiffPeakQFWHM;DiffPeakIntgInt;"	
	ListOfPopulationVariablesDP+="DiffPeakPar1;DiffPeakPar1Fit;DiffPeakPar1Min;DiffPeakPar1Max;"	
	ListOfPopulationVariablesDP+="DiffPeakPar2;DiffPeakPar2Fit;DiffPeakPar2Min;DiffPeakPar2Max;"	
	ListOfPopulationVariablesDP+="DiffPeakPar3;DiffPeakPar3Fit;DiffPeakPar3Min;DiffPeakPar3Max;"	
	ListOfPopulationVariablesDP+="DiffPeakPar4;DiffPeakPar4Fit;DiffPeakPar4Min;DiffPeakPar4Max;"	
	ListOfPopulationVariablesDP+="DiffPeakPar5;DiffPeakPar5Fit;DiffPeakPar5Min;DiffPeakPar5Max;"	
	
		//Fractals parameters - Mass
	ListOfPopulationVariablesFR+="MassFrPhi;MassFrRadius;MassFrDv;MassFrKsi;MassFrBeta;MassFrEta;MassFrIntgNumPnts;"
	ListOfPopulationVariablesFR+="MassFrPhiFit;MassFrRadiusFit;MassFrDvFit;MassFrKsiFit;MassFrUseUFFF;MassFrPDI;"
	//ListOfPopulationVariables+="MassFrUseUFFF;"
	ListOfPopulationVariablesFR+="MassFrPhiMin;MassFrRadiusMin;MassFrDvMin;MassFrKsiMin;"
	ListOfPopulationVariablesFR+="MassFrPhiMax;MassFrRadiusMax;MassFrDvMax;MassFrKsiMax;"
		
		//Fractals parameters - Surface
	ListOfPopulationVariablesFR+="SurfFrSurf;SurfFrKsi;SurfFrDS;"
	ListOfPopulationVariablesFR+="SurfFrSurfFit;SurfFrKsiFit;SurfFrDSFit;"
	ListOfPopulationVariablesFR+="SurfFrSurfMin;SurfFrKsiMin;SurfFrDSMin;"
	ListOfPopulationVariablesFR+="SurfFrSurfMax;SurfFrKsiMax;SurfFrDSMax;"
	ListOfPopulationVariablesFR+="SurfFrQc;SurfFrQcWidth;"
	
	
	
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
	//following needs to run 10 times to create 10 sets for 10 data sets...
	for(j=1;j<=10;j+=1)	
		for(i=0;i<itemsInList(ListOfDataVariables);i+=1)	
			IN2G_CreateItem("variable",StringFromList(i,ListOfDataVariables)+"_set"+num2str(j))
		endfor	
	endfor
	//following needs to run 10 times to create 10 different populations sets of variables and strings	
	for(j=1;j<=10;j+=1)	
		for(i=0;i<itemsInList(ListOfPopulationVariables);i+=1)	
			IN2G_CreateItem("variable",StringFromList(i,ListOfPopulationVariables)+"_pop"+num2str(j))
		endfor
	endfor		
	for(j=1;j<=10;j+=1)	
		for(i=0;i<itemsInList(ListOfPopulationVariablesSD);i+=1)	
			IN2G_CreateItem("variable",StringFromList(i,ListOfPopulationVariablesSD)+"_pop"+num2str(j))
		endfor
	endfor		
	for(j=1;j<=10;j+=1)	
		for(i=0;i<itemsInList(ListOfPopulationVariablesDP);i+=1)	
			IN2G_CreateItem("variable",StringFromList(i,ListOfPopulationVariablesDP)+"_pop"+num2str(j))
		endfor
	endfor		
	for(j=1;j<=10;j+=1)	
		for(i=0;i<itemsInList(ListOfPopulationVariablesUF);i+=1)	
			IN2G_CreateItem("variable",StringFromList(i,ListOfPopulationVariablesUF)+"_pop"+num2str(j))
		endfor
	endfor		
	for(j=1;j<=10;j+=1)	
		for(i=0;i<itemsInList(ListOfPopulationVariablesFR);i+=1)	
			IN2G_CreateItem("variable",StringFromList(i,ListOfPopulationVariablesFR)+"_pop"+num2str(j))
		endfor
	endfor		
	//following 10 times as these are data sets
	for(j=1;j<=10;j+=1)	
		for(i=0;i<itemsInList(ListOfDataStrings);i+=1)	
			IN2G_CreateItem("string",StringFromList(i,ListOfDataStrings)+"_set"+num2str(j))
		endfor	
	endfor		
	for(j=1;j<=10;j+=1)	
		for(i=0;i<itemsInList(ListOfPopulationsStrings);i+=1)	
			IN2G_CreateItem("string",StringFromList(i,ListOfPopulationsStrings)+"_pop"+num2str(j))
		endfor	
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	NVAR UseGeneticOptimization
	NVAR UseLSQF
	UseLSQF = !UseGeneticOptimization
	
		SVAR SizeDist_DimensionType= root:Packages:IR2L_NLSQF:SizeDist_DimensionType
		NVAR SizeDist_DimensionIsDiameter= root:Packages:IR2L_NLSQF:SizeDist_DimensionIsDiameter
		NVAR SizeDistDisplayNumDist = root:Packages:IR2L_NLSQF:SizeDistDisplayNumDist
		NVAR SizeDistDisplayVolDist = root:Packages:IR2L_NLSQF:SizeDistDisplayVolDist
		SizeDist_DimensionType= ""
		if(SizeDistDisplayNumDist)
			SizeDist_DimensionType = "Number distribution of "
		else
			SizeDist_DimensionType = "Volume distribution of "
		endif
		if(SizeDist_DimensionIsDiameter)
			SizeDist_DimensionType += "Diameters"
		else
			SizeDist_DimensionType += "Radia"
		endif

	String/g rgbIntensity_set1="(52224,0,0)"
	String/g rgbIntensity_set2="(0,39168,0)"
	String/g rgbIntensity_set3="(0,9472,39168)"
	String/g rgbIntensity_set4="(39168,0,31232)"
	String/g rgbIntensity_set5="(65280,16384,16384)"
	String/g rgbIntensity_set6="(16384,65280,16384)"
	String/g rgbIntensity_set7="(16384,28160,65280)"
	String/g rgbIntensity_set8="(65280,16384,55552)"
	String/g rgbIntensity_set9="(0,0,0)"
	String/g rgbIntensity_set10="(34816,34816,34816)"

	String/g rgbIntensityLine_set10="(52224,0,0)"
	String/g rgbIntensityLine_set9="(0,39168,0)"
	String/g rgbIntensityLine_set8="(0,9472,39168)"
	String/g rgbIntensityLine_set7="(39168,0,31232)"
	String/g rgbIntensityLine_set6="(65280,16384,16384)"
	String/g rgbIntensityLine_set5="(16384,65280,16384)"
	String/g rgbIntensityLine_set4="(16384,28160,65280)"
	String/g rgbIntensityLine_set3="(65280,16384,55552)"
	String/g rgbIntensityLine_set2="(0,0,0)"
	String/g rgbIntensityLine_set1="(34816,34816,34816)"

	for(j=1;j<=6;j+=1)	
		for(i=0;i<itemsInList(ListOfPopulationsStrings);i+=1)	
			SVAR testStr = $( "StructureFactor_pop"+num2str(j))
			if(strlen(testStr)==0)
				testStr="Dilute system"
			endif
		endfor	
	endfor		
	setDataFolder OldDf

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_SetInitialValues(enforce)
	variable enforce
	//and here set default values...

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	
//	abort "finish me - IE2L_SetInitialValues"
	string ListOfVariables, ListOfStrings
	variable i, j
//set initial values....
	//set starting conditions here....
	//SameContrastForDataSets;VaryContrastForDataSets;DisplayInputDataControls;DisplayModelControls
	NVAR SameContrastForDataSets
	NVAR VaryContrastForDataSets
	if((VaryContrastForDataSets + SameContrastForDataSets)!=1)
		VaryContrastForDataSets=0
		SameContrastForDataSets =1
	endif
	NVAR DisplayInputDataControls
	NVAR DisplayModelControls
	if((DisplayInputDataControls+DisplayModelControls)!=1)
		DisplayInputDataControls = 1
		DisplayModelControls = 0
	endif
	SVAR ListOfKnownPeakShapes
	ListOfKnownPeakShapes="Gauss;Lorenz;LorenzSquared;Pseudo-Voigt;Gumbel;Pearson_VII;Modif_Gauss;SkewedNormal;"
	NVAR SizeDistDisplayNumDist
	NVAR SizeDistDisplayVolDist
	if(SizeDistDisplayNumDist + SizeDistDisplayVolDist <1)
		SizeDistDisplayVolDist=1
	endif

	SVAR DataCalibrationUnits
	SVAR PanelVolumeDesignation
	SVAR IntCalibrationUnits
	SVAR VolDistCalibrationUnits
	SVAR NumDistCalibrationUnits
	if(strlen(DataCalibrationUnits)<2)
		DataCalibrationUnits="Arbitrary"
		PanelVolumeDesignation="Scale"
		IntCalibrationUnits="Arbitrary"
		VolDistCalibrationUnits="Arbitrary"
		NumDistCalibrationUnits="Arbitrary"
	endif

	for(i=1;i<=10;i+=1)	
		NVAR UseUserErrors=$("UseUserErrors_set"+num2str(i))
		NVAR UseSQRTErrors=$("UseSQRTErrors_set"+num2str(i))
		NVAR UsePercentErrors=$("UsePercentErrors_set"+num2str(i))
		if(UseUserErrors+UseSQRTErrors+UsePercentErrors!=0)
			UseUserErrors=1
			UseSQRTErrors=0
			UsePercentErrors=0
		endif
	endfor

		for(j=1;j<=10;j+=1)	//Smearing max Points
			ListOfVariables = "SmearingMaxNumPnts;"
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_set"+num2str(j))
				if(testVar==0)
					testVar=7
				endif
			endfor
		endfor
		for(j=1;j<=10;j+=1)	//Smearing max Points
			ListOfVariables = "SmearingIgnoreSmalldQ;"
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_set"+num2str(j))
				if(testVar==0)
					testVar=5
				endif
			endfor
		endfor


		for(j=1;j<=10;j+=1)	//Slit type
			ListOfStrings = "SmearingType;"
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				SVAR/Z testStr=$(StringFromList(i,ListOfStrings)+"_set"+num2str(j))
				if(strlen(testStr)==0)
					testStr="None"
				endif
			endfor
		endfor
		for(j=1;j<=10;j+=1)	//SmearingWaveName
			ListOfStrings = "SmearingWaveName;"
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				SVAR/Z testStr=$(StringFromList(i,ListOfStrings)+"_set"+num2str(j))
				if(strlen(testStr)==0)
					testStr="Fixed dQ [1/A]"
				endif
			endfor
		endfor



	for(i=1;i<=10;i+=1)	
		SVAR Model=$("Model_pop"+num2str(i))
		if(strlen(Model)<3)
			Model="Size dist."
		endif
	endfor
	for(i=1;i<=10;i+=1)	
		SVAR Model=$("DiffPeakProfile_pop"+num2str(i))
		if(strlen(Model)<3)
			Model="Gauss"
		endif
	endfor

	for(i=1;i<=10;i+=1)	
		SVAR FormFactor=$("FormFactor_pop"+num2str(i))
		if(strlen(FormFactor)<3)
			FormFactor="Spheroid"
		endif
	endfor
	for(i=1;i<=10;i+=1)	//RdistAuto;RdistrSemiAuto;RdistMan
		NVAR RdistAuto=$("RdistAuto_pop"+num2str(i))
		NVAR RdistrSemiAuto=$("RdistrSemiAuto_pop"+num2str(i))
		NVAR RdistMan=$("RdistMan_pop"+num2str(i))
		if(RdistMan+RdistrSemiAuto+RdistAuto !=1)
			RdistAuto=1
			RdistMan=0
			RdistrSemiAuto=0
			//RdistManMin;RdistManMax;RdistLog;RdistNumPnts;RdistNeglectTails
			NVAR RdistManMin=$("RdistManMin_pop"+num2str(i))
			NVAR RdistManMax=$("RdistManMax_pop"+num2str(i))
			NVAR RdistLog=$("RdistLog_pop"+num2str(i))
			NVAR RdistNumPnts=$("RdistNumPnts_pop"+num2str(i))
			NVAR RdistNeglectTails=$("RdistNeglectTails_pop"+num2str(i))
			RdistNeglectTails=0.01
			RdistNumPnts=50
			RdistLog=1
			RdistManMin=10
			RdistManMax=10000
			SVAR PopSizeDistShape=$("PopSizeDistShape_pop"+num2str(i))
			PopSizeDistShape="LogNormal"
			SVAR FormFactor=$("FormFactor_pop"+num2str(i))
			FormFactor="Spheroid"
			NVAR Par1=$("FormFactor_Param1_pop"+num2str(i))
			NVAR Par2=$("FormFactor_Param2_pop"+num2str(i))
			NVAR Par3=$("FormFactor_Param3_pop"+num2str(i))
			NVAR Par4=$("FormFactor_Param4_pop"+num2str(i))
			NVAR Par5=$("FormFactor_Param5_pop"+num2str(i))
			NVAR Par6=$("FormFactor_Param6_pop"+num2str(i))
			NVAR Par7=$("FormFactor_Param7_pop"+num2str(i))
			NVAR Par8=$("FormFactor_Param8_pop"+num2str(i))
			NVAR Par9=$("FormFactor_Param9_pop"+num2str(i))
			Par1=1
			Par2=1
			Par3=1
			Par4=1
			Par5=1
			Par6=1
			Par7=1
			Par8=1
			Par9=1
		endif
	endfor

		for(j=1;j<=10;j+=1)	//"Contrast;Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
			ListOfVariables = "Contrast;Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=100
				endif
			endfor
		endfor

		for(j=1;j<=10;j+=1)	//"Contrast;Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
			ListOfVariables = "UF_Rg;"
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=100
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=10
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=1000		
				endif
			endfor

			ListOfVariables = "UF_G;"
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				NVAR/Z testVarRg=$(ReplaceString("_G",StringFromList(i,ListOfVariables),"_Rg")+"_pop"+num2str(j))
				if(testVar==0 && testVarRg<1e+10)
					testVar=100
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=10
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=1000		
				endif
			endfor


			ListOfVariables = "UF_B;"
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=1
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=0.001
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=1000		
				endif
			endfor
			ListOfVariables = "UF_P;"
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=4
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=1
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=4.2		
				endif
			endfor
			ListOfVariables = "UF_K;"
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=1
				endif
			endfor
			//diffraction
			ListOfVariables = "DiffPeakPar1;"		//prefactor
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=1
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=0.1
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=10		
				endif
			endfor
			ListOfVariables = "DiffPeakPar2;"		//Q position
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=0.07
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=0.03
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=0.12		
				endif
			endfor
			ListOfVariables = "DiffPeakPar3;"		//Q width
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=0.01
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=0.002
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=0.02		
				endif
			endfor
			ListOfVariables = "DiffPeakPar4;"		//other parameter
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=1
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=0.001
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=2		
				endif
			endfor
		//FRACTALS
			ListOfVariables = "MassFrPhi;"		//other parameter
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=0.1
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=0.01
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=1		
				endif
			endfor
			ListOfVariables = "MassFrRadius;"		//other parameter
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=50
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=10
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=500		
				endif
			endfor
			ListOfVariables = "MassFrDv;MassFrBeta;"		//other parameter
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=2
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=1
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=3		
				endif
			endfor
			ListOfVariables = "SurfFrDS;"		//other parameter
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=2.5
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=2
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=2.999		
				endif
			endfor
			ListOfVariables = "MassFrKsi;MassFrIntgNumPnts;SurfFrKsi;"		//other parameter
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=500
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=10
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=1e4		
				endif
			endfor
			ListOfVariables = "SurfFrSurf;"		//other parameter
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=2500
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=500
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=10000		
				endif
			endfor
			ListOfVariables = "MassFrEta;"		//other parameter
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=0.5
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=0.01
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=1		
				endif
			endfor
			
			ListOfVariables = "MassFrPDI;"		//other parameter
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=3
				endif
			endfor
			ListOfVariables = "SurfFrQcWidth;"		//other parameter
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=15
				endif
			endfor
		endfor

	for(i=1;i<=10;i+=1)	
		NVAR DataScalingFactor=$("root:Packages:IR2L_NLSQF:DataScalingFactor_set"+num2str(i))
		NVAR ErrorScalingFactor=$("root:Packages:IR2L_NLSQF:ErrorScalingFactor_set"+num2str(i))
		if(DataScalingFactor==0)
			DataScalingFactor=1
		endif
		if(ErrorScalingFactor==0)
			ErrorScalingFactor=1
		endif
	endfor

//	//Model parameters, these need to have _popX attached at the end of name
//	ListOfPopulationVariables+="Volume;VolumeFit;VolumeMin;VolumeMax;"	
//	ListOfPopulationVariables+="LNMinSize;LNMinSizeFit;LNMinSizeMin;LNMinSizeMax;LNMeanSize;LNMeanSizeFit;LNMeanSizeMin;LNMeanSizeMax;LNSdeviation;LNSdeviationFit;LNSdeviationMin;LNSdeviationMax;"	
//	ListOfPopulationVariables+="GMeanSize;GMeanSizeFit;GMeanSizeMin;GMeanSizeMax;GWidth;GWidthFit;GWidthMin;GWidthMax;LSWLocation;LSWLocationFit;LSWLocationMin;LSWLocationMax;"	

	for(j=1;j<=10;j+=1)	//RdistAuto;RdistrSemiAuto;RdistMan
		ListOfVariables = "Volume"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
			if(testVar==0)
				testVar=0.05
			endif
		endfor
		ListOfVariables = "LNSdeviation"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
			if(testVar==0)
				testVar=0.5
			endif
		endfor
		ListOfVariables = "GWidth;SZWidth;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
			if(testVar==0)
				testVar=50*j
			endif
		endfor
		
		ListOfVariables = "LNMeanSize;GMeanSize;SZMeanSize;LSWLocation;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
			if(testVar==0)
				testVar=j*150
			endif
		endfor
		ListOfVariables = "LNMinSize;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
			if(testVar==0)
				testVar=3
			endif
		endfor

			ListOfVariables = "ArdParameter;"		//other parameter
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=2.5
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=2
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=3	
				endif
			endfor


			ListOfVariables = "ArdLocation;"		//other parameter
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=100
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Min_pop"+num2str(j))
					testVar=50
					NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Max_pop"+num2str(j))
					testVar=200
				endif
			endfor

	endfor
	//here is check that smearing is in check... 
	for(i=1;i<=10;i+=1)	
		NVAR UseSmearing_set=$("UseSmearing_set"+num2str(i))
		NVAR SlitSmeared_set=$("SlitSmeared_set"+num2str(i))
		SVAR SmearingType_set=$("SmearingType_set"+num2str(i))
		if(SlitSmeared_set || !StringMatch(SmearingType_set, "None" ))
			UseSmearing_set=1
		endif
	endfor
	
	NVAR GraphXLog
	NVAR GraphYLog
	GraphXLog = 1
	GraphYLog = 1
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_SaveResultsInNotebook()

	IR2L_SvNbk_CreateNbk()		//create notebook

	IR2L_SvNbk_SampleInf()		//store data information
	
	IR2L_SvNbk_Graphs(1)		//insert graphs
	
	IR2L_SvNbk_ModelInf()		//store model information
	
	//summary?
	IR2L_SvNbk_PgBreak()		//page break at the end
end 
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_AddRemoveTagsToGraph(AddAlso)
	variable AddAlso		//set to 1 if you want to add new tags not only removce old ones
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	variable k, i
	string ListOfPopulationVariables
	string TagName
	variable LocationPnt
	string TagText
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	variable LastDataSet
	LastDataSet = (MultipleInputData) ? 10 : 1
	//remove old tags
	For(k=1;k<11;k+=1)
		For(i=1;i<11;i+=1)
			TagName  = "ModelingIITag"+num2str(i)+"set"+num2str(k)	
			Tag/K/W=LSQF_MainGraph /N=$(TagName)							
		endfor
	endfor
	if(!AddAlso)
		return 0
	endif	
	For(k=1;k<=LastDataSet;k+=1)
		NVAR UseTheSet=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(k))
		if(UseTheSet||(LastDataSet==1))
			Wave/Z Qvec=$("root:Packages:IR2L_NLSQF:Q_set"+num2str(k)) 
			Wave/Z Intensity=$("root:Packages:IR2L_NLSQF:Intensity_set"+num2str(k)) 
			
			//And now the populations
			For(i=1;i<11;i+=1)	
				NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(i))	
				SVAR FormFactor=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(i))
				SVAR Model=$("root:Packages:IR2L_NLSQF:Model_pop"+num2str(i))
				if(UseThePop)
					if(stringmatch(Model,"Size dist."))
						//here append tag for Size distribution model
						
						SVAR PopSizeDistShape = $("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(i))		
						NVAR GMeanSize =  $("root:Packages:IR2L_NLSQF:GMeanSize_pop"+num2str(i))	
						NVAR GWidth =  $("root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(i))	
						NVAR LNMinSize =  $("root:Packages:IR2L_NLSQF:LNMinSize_pop"+num2str(i))	
						NVAR LNMeanSize =  $("root:Packages:IR2L_NLSQF:LNMeanSize_pop"+num2str(i))	
						NVAR LNSdeviation =  $("root:Packages:IR2L_NLSQF:LNSdeviation_pop"+num2str(i))	
						NVAR LSWLocation =  $("root:Packages:IR2L_NLSQF:LSWLocation_pop"+num2str(i))	
						NVAR MeanVal =  $("root:Packages:IR2L_NLSQF:Mean_pop"+num2str(i))
						NVAR Rg =  $("root:Packages:IR2L_NLSQF:Rg_pop"+num2str(i))
						NVAR ModeVal =  $("root:Packages:IR2L_NLSQF:Mode_pop"+num2str(i))
						NVAR MedianVal =  $("root:Packages:IR2L_NLSQF:Median_pop"+num2str(i))
						NVAR FWHMVal =  $("root:Packages:IR2L_NLSQF:FWHM_pop"+num2str(i))
						SVAR StrFac=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(i))
						NVAR SFParam1= $("root:Packages:IR2L_NLSQF:StructureParam1_pop"+num2str(i))
						NVAR SFParam2= $("root:Packages:IR2L_NLSQF:StructureParam2_pop"+num2str(i))
						NVAR SFParam3= $("root:Packages:IR2L_NLSQF:StructureParam3_pop"+num2str(i))
						NVAR SFParam4= $("root:Packages:IR2L_NLSQF:StructureParam4_pop"+num2str(i))
						NVAR SFParam5= $("root:Packages:IR2L_NLSQF:StructureParam5_pop"+num2str(i))
						NVAR SFParam6= $("root:Packages:IR2L_NLSQF:StructureParam6_pop"+num2str(i))
						SVAR FormFac=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(i))
						SVAR U1FormFac=$("root:Packages:IR2L_NLSQF:FFUserFFformula_pop"+num2str(i))
						SVAR U2FormFac=$("root:Packages:IR2L_NLSQF:FFUserVolumeFormula_pop"+num2str(i))
						NVAR FFParam1= $("root:Packages:IR2L_NLSQF:FormFactor_Param1_pop"+num2str(i))
						NVAR FFParam2= $("root:Packages:IR2L_NLSQF:FormFactor_Param2_pop"+num2str(i))
						NVAR FFParam3= $("root:Packages:IR2L_NLSQF:FormFactor_Param3_pop"+num2str(i))
						NVAR FFParam4= $("root:Packages:IR2L_NLSQF:FormFactor_Param4_pop"+num2str(i))
						NVAR FFParam5= $("root:Packages:IR2L_NLSQF:FormFactor_Param5_pop"+num2str(i))
						
						TagName  = "ModelingIITag"+num2str(i)+"set"+num2str(k)
						LocationPnt = BinarySearch(Qvec, 1.7/ModeVal )
						TagText="\\Z"+IN2G_LkUpDfltVar("TagSize")+"Size distribution "+num2str(i)+"P\r"
						TagText+="Distribution : "+PopSizeDistShape+"  \r"
						TagText+="Rg : "+num2str(Rg)+" [A]  \r"
						TagText+="Mean / Mode / Median / FWHM  \r"
						TagText+=num2str(MeanVal)+" / "+num2str(ModeVal)+" / "+num2str(MedianVal)+" / "+num2str(FWHMVal)+"  \r"

						TagText+="Form Factor : "+FormFac+"  \r"
						if(stringmatch(FormFac, "*User*"))
							TagText+="FFUserFFformula = "+U1FormFac+"  \r"						
							TagText+="FFUserVolumeformula = "+U2FormFac+"  \r"		
						endif				
						if(strlen(IR1T_IdentifyFFParamName(FormFac,1))>0)
							TagText+=IR1T_IdentifyFFParamName(FormFac,1)+" = "+num2str(FFParam1)+"  \r"
						endif
						if(strlen(IR1T_IdentifyFFParamName(FormFac,2))>0)
							TagText+=IR1T_IdentifyFFParamName(FormFac,2)+" = "+num2str(FFParam2)+"  \r"
						endif
						if(strlen(IR1T_IdentifyFFParamName(FormFac,3))>0)
							TagText+=IR1T_IdentifyFFParamName(FormFac,3)+" = "+num2str(FFParam3)+"  \r"
						endif
						if(strlen(IR1T_IdentifyFFParamName(FormFac,4))>0)
							TagText+=IR1T_IdentifyFFParamName(FormFac,4)+" = "+num2str(FFParam4)+"  \r"
						endif
						if(strlen(IR1T_IdentifyFFParamName(FormFac,5))>0)
							TagText+=IR1T_IdentifyFFParamName(FormFac,5)+" = "+num2str(FFParam5)+"  \r"
						endif							
						if(!stringmatch(StrFac, "*Dilute system*"))
							TagText+="Structure Factor : "+StrFac+" \r"
							TagText+=IR1T_IdentifySFParamName(StrFac,1)+" = "+num2str(SFParam1)+" \r"
							if(strlen(IR1T_IdentifySFParamName(StrFac,2))>0)
								TagText+=IR1T_IdentifySFParamName(StrFac,2)+" = "+num2str(SFParam2)+" \r"
							endif
							if(strlen(IR1T_IdentifySFParamName(StrFac,3))>0)
								TagText+=IR1T_IdentifySFParamName(StrFac,3)+" = "+num2str(SFParam3)+" \r"
							endif
							if(strlen(IR1T_IdentifySFParamName(StrFac,4))>0)
								TagText+=IR1T_IdentifySFParamName(StrFac,4)+" = "+num2str(SFParam4)+" \r"
							endif
							if(strlen(IR1T_IdentifySFParamName(StrFac,5))>0)
								TagText+=IR1T_IdentifySFParamName(StrFac,5)+" = "+num2str(SFParam5)+" \r"
							endif
							if(strlen(IR1T_IdentifySFParamName(StrFac,6))>0)
								TagText+=IR1T_IdentifySFParamName(StrFac,6)+" = "+num2str(SFParam6)+" \r"
							endif
						else
							//TagText+="Dilute system assumed \r"
						endif
						if(LastDataSet>1)
							TagText =  RemoveEnding(TagText, "\r" )+"set"+num2str(k)
						else
							TagText =  RemoveEnding(TagText, "\r" )
						endif
						Tag/C/W=LSQF_MainGraph /N=$(TagName)/F=0/L=2/TL=0 $("IntensityModel_set"+num2str(k)), LocationPnt, TagText						

					elseif(stringmatch(Model,"Unified level"))			//Unified level results
						//here appedn tag for Unified level model
	
						NVAR Rg=$("root:Packages:IR2L_NLSQF:UF_Rg_pop"+num2str(i))
						NVAR G=$("root:Packages:IR2L_NLSQF:UF_G_pop"+num2str(i))
						NVAR P=$("root:Packages:IR2L_NLSQF:UF_P_pop"+num2str(i))
						NVAR B=$("root:Packages:IR2L_NLSQF:UF_B_pop"+num2str(i))
						NVAR RgCO=$("root:Packages:IR2L_NLSQF:UF_RgCO_pop"+num2str(i))
						NVAR Kval=$("root:Packages:IR2L_NLSQF:UF_K_pop"+num2str(i))
						SVAR StrFac=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(i))
						NVAR SFParam1= $("root:Packages:IR2L_NLSQF:StructureParam1_pop"+num2str(i))
						NVAR SFParam2= $("root:Packages:IR2L_NLSQF:StructureParam2_pop"+num2str(i))
						NVAR SFParam3= $("root:Packages:IR2L_NLSQF:StructureParam3_pop"+num2str(i))
						NVAR SFParam4= $("root:Packages:IR2L_NLSQF:StructureParam4_pop"+num2str(i))
						NVAR SFParam5= $("root:Packages:IR2L_NLSQF:StructureParam5_pop"+num2str(i))
						NVAR SFParam6= $("root:Packages:IR2L_NLSQF:StructureParam6_pop"+num2str(i))
						TagName  = "ModelingIITag"+num2str(i)+"set"+num2str(k)
						LocationPnt = BinarySearch(Qvec, 1.8/Rg )
							TagText="\\Z"+IN2G_LkUpDfltVar("TagSize")+"Unified level "+num2str(i)+"P\r"
							TagText+="G = "+num2str(G)+"  \r"
							TagText+="Rg = "+num2str(Rg)+"  [A]\r"
							TagText+="B = "+num2str(B)+"\r"
							TagText+="P = "+num2str(P)+" \r"
							if(!stringmatch(StrFac, "*Dilute system*"))
								TagText+="Structure Factor : "+StrFac+" \r"
								TagText+=IR1T_IdentifySFParamName(StrFac,1)+" = "+num2str(SFParam1)+" \r"
								if(strlen(IR1T_IdentifySFParamName(StrFac,2))>0)
									TagText+=IR1T_IdentifySFParamName(StrFac,2)+" = "+num2str(SFParam2)+" \r"
								endif
								if(strlen(IR1T_IdentifySFParamName(StrFac,3))>0)
									TagText+=IR1T_IdentifySFParamName(StrFac,3)+" = "+num2str(SFParam3)+" \r"
								endif
								if(strlen(IR1T_IdentifySFParamName(StrFac,4))>0)
									TagText+=IR1T_IdentifySFParamName(StrFac,4)+" = "+num2str(SFParam4)+" \r"
								endif
								if(strlen(IR1T_IdentifySFParamName(StrFac,5))>0)
									TagText+=IR1T_IdentifySFParamName(StrFac,5)+" = "+num2str(SFParam5)+" \r"
								endif
								if(strlen(IR1T_IdentifySFParamName(StrFac,6))>0)
									TagText+=IR1T_IdentifySFParamName(StrFac,6)+" = "+num2str(SFParam6)+" \r"
								endif
							else
								//TagText+="Dilute system assumed \r"
							endif
							if(LastDataSet>1)
								TagText =  RemoveEnding(TagText, "\r" )+"set"+num2str(k)
							else
								TagText =  RemoveEnding(TagText, "\r" )
							endif
							Tag/C/W=LSQF_MainGraph /N=$(TagName)/F=0/L=2/TL=0 $("IntensityModel_set"+num2str(k)), LocationPnt, TagText						
					elseif(stringmatch(Model,"SurfaceFractal"))			//Surface Fractal results
						//here appedn tag for Unified level model
	
						NVAR SurfFrSurf=$("root:Packages:IR2L_NLSQF:SurfFrSurf_pop"+num2str(i))
						NVAR SurfFrKsi=$("root:Packages:IR2L_NLSQF:SurfFrKsi_pop"+num2str(i))
						NVAR SurfFrDS=$("root:Packages:IR2L_NLSQF:SurfFrDS_pop"+num2str(i))
						NVAR SurfFrQcWidth=$("root:Packages:IR2L_NLSQF:SurfFrQcWidth_pop"+num2str(i))
						NVAR SurfFrQc=$("root:Packages:IR2L_NLSQF:SurfFrQc_pop"+num2str(i))
						TagName  = "ModelingIITag"+num2str(i)+"set"+num2str(k)
						LocationPnt = BinarySearch(Qvec, 1.8/Rg )
							TagText="\\Z"+IN2G_LkUpDfltVar("TagSize")+"Surface Fractal "+num2str(i)+"P\r"
							TagText+="Smooth Surface = "+num2str(SurfFrSurf)+"  \r"
							TagText+="Corr. Length = "+num2str(SurfFrKsi)+"  [A]\r"
							TagText+="Fractal Dim.  = "+num2str(SurfFrDS)+"\r"
							if(SurfFrQc>0)
								TagText+="Terminal Qc  = "+num2str(SurfFrQc)+"[1/A]\r"
								TagText+="assumed width Qc  = "+num2str(100*SurfFrQcWidth)+"%\r"
							endif
							if(LastDataSet>1)
								TagText =  RemoveEnding(TagText, "\r" )+"set"+num2str(k)
							else
								TagText =  RemoveEnding(TagText, "\r" )
							endif
							Tag/C/W=LSQF_MainGraph /N=$(TagName)/F=0/L=2/TL=0 $("IntensityModel_set"+num2str(k)), LocationPnt, TagText						
					elseif(stringmatch(Model,"MassFractal"))			//Surface Fractal results
						//here append tag for Mass Fractal model
	
						NVAR MassFrPhi=$("root:Packages:IR2L_NLSQF:MassFrPhi_pop"+num2str(i))
						NVAR MassFrRadius=$("root:Packages:IR2L_NLSQF:MassFrRadius_pop"+num2str(i))
						NVAR MassFrDv=$("root:Packages:IR2L_NLSQF:MassFrDv_pop"+num2str(i))
						NVAR MassFrKsi=$("root:Packages:IR2L_NLSQF:MassFrKsi_pop"+num2str(i))
						NVAR MassFrBeta=$("root:Packages:IR2L_NLSQF:MassFrBeta_pop"+num2str(i))
						NVAR MassFrEta=$("root:Packages:IR2L_NLSQF:MassFrEta_pop"+num2str(i))
						NVAR MassFrIntgNumPnts=$("root:Packages:IR2L_NLSQF:MassFrDv_pop"+num2str(i))
						TagName  = "ModelingIITag"+num2str(i)+"set"+num2str(k)
						LocationPnt = BinarySearch(Qvec, 1.8/Rg )
							TagText="\\Z"+IN2G_LkUpDfltVar("TagSize")+"Mass Fractal "+num2str(i)+"P\r"
							TagText+="Particle volume = "+num2str(MassFrPhi)+"  \r"
							TagText+="Particle radius = "+num2str(MassFrRadius)+"  [A]\r"
							TagText+="Corr. Length = "+num2str(MassFrKsi)+"  [A]\r"
							TagText+="Fractal Dim.  = "+num2str(MassFrDv)+"\r"
							TagText+="Particle AR  = "+num2str(MassFrBeta)+";   Volume filling  = "+num2str(MassFrEta)+"\r"
							if(LastDataSet>1)
								TagText =  RemoveEnding(TagText, "\r" )+"set"+num2str(k)
							else
								TagText =  RemoveEnding(TagText, "\r" )
							endif
							Tag/C/W=LSQF_MainGraph /N=$(TagName)/F=0/L=2/TL=0 $("IntensityModel_set"+num2str(k)), LocationPnt, TagText						
					elseif(stringmatch(Model,"Diffraction Peak"))
						//here append tag for Diffraction peak
						SVAR PeakProfile = $("root:Packages:IR2L_NLSQF:DiffPeakProfile_pop"+num2str(i))
						NVAR DiffPeakDPos=$("root:Packages:IR2L_NLSQF:DiffPeakDPos_pop"+num2str(i))
						NVAR DiffPeakQPos=$("root:Packages:IR2L_NLSQF:DiffPeakQPos_pop"+num2str(i))
						NVAR DiffPeakQFWHM=$("root:Packages:IR2L_NLSQF:DiffPeakQFWHM_pop"+num2str(i))
						NVAR DiffPeakIntgInt=$("root:Packages:IR2L_NLSQF:DiffPeakIntgInt_pop"+num2str(i))
						NVAR DiffPeakPar1=$("root:Packages:IR2L_NLSQF:DiffPeakPar1_pop"+num2str(i))
						NVAR DiffPeakPar2=$("root:Packages:IR2L_NLSQF:DiffPeakPar2_pop"+num2str(i))
						NVAR DiffPeakPar3=$("root:Packages:IR2L_NLSQF:DiffPeakPar3_pop"+num2str(i))
						NVAR DiffPeakPar4=$("root:Packages:IR2L_NLSQF:DiffPeakPar4_pop"+num2str(i))
						NVAR DiffPeakPar5=$("root:Packages:IR2L_NLSQF:DiffPeakPar5_pop"+num2str(i))
						TagName  = "ModelingIITag"+num2str(i)+"set"+num2str(k)
						LocationPnt = BinarySearch(Qvec, DiffPeakPar2 )
							TagText="\\Z"+IN2G_LkUpDfltVar("TagSize")+"Diffraction Peak "+num2str(i)+"P\r"
							TagText+="Shape  :   "+PeakProfile+"\r"
							TagText+="Position (d) = "+num2str(DiffPeakDPos)+"  [A]\r"
							TagText+="Position (Q) = "+num2str(DiffPeakQPos)+"  [A^-1]\r"
							TagText+="Integral intensity = "+num2str(DiffPeakIntgInt)+"\r"
							TagText+="FWHM (Q) = "+num2str(DiffPeakQFWHM)+" [A^-1]"
							if(LastDataSet>1)
								TagText =  RemoveEnding(TagText, "\r" )+"set"+num2str(k)
							else
								TagText =  RemoveEnding(TagText, "\r" )
							endif
							Tag/C/W=LSQF_MainGraph /N=$(TagName)/F=0/L=2/TL=0 $("IntensityModel_set"+num2str(k)), LocationPnt, TagText
	
					endif
				endif
			endfor
		endif
	endfor			
end	
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2L_SvNbk_ModelInf()
	//this function saves information about the samples
	//and header
	
	SVAR/Z nbl=root:Packages:IR2L_NLSQF:NotebookName
	if(!SVAR_Exists(nbl))
		abort
	endif
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	variable k, i
	string ListOfPopulationVariables
	k=0
	For(i=1;i<11;i+=1)
		NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(i))
		k+=UseThePop
	endfor
	
//	//write header here... separator and some heading to divide the record.... 
	IR2L_AppendAnyText("   ",2)	//separate
	IR2L_AppendAnyText("Model data for "+num2str(k)+" population(s) used to obtain above results"+"\r",1)	
	//IR2L_AppendAnyText("     ",0)	
	
	//And now the populations
	For(i=1;i<11;i+=1)	
		NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(i))	
		SVAR FormFactor=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(i))
		SVAR Model=$("root:Packages:IR2L_NLSQF:Model_pop"+num2str(i))
		if(UseThePop)
			if(stringmatch(Model,"Size dist."))
				IR2L_AppendAnyText("Summary results for population "+num2str(i),1)	
				IR2L_AppendAnyText("     ",0)	
				IR2L_AppendAnyText("               This population was Size Distribution ",0)	
				ListOfPopulationVariables="Mean;Mode;Median;FWHM;"	
				SVAR PanelVolumeDesignation=root:Packages:IR2L_NLSQF:PanelVolumeDesignation	
				NVAR testVar = $("root:Packages:IR2L_NLSQF:Volume"+"_pop"+num2str(i))
				IR2L_AppendAnyText(PanelVolumeDesignation+"\t=\t"+num2str(testVar),0)
				for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)	
					NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
					IR2L_AppendAnyText(StringFromList(k,ListOfPopulationVariables)+"\t=\t"+num2str(testVar),0)
				endfor
			
				IR2L_AppendAnyText("  ",0)	
				//IR2L_AppendAnyText("Distribution type for "+num2str(i)+" population",1)	
				SVAR PopSizeDistShape = $("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(i))		
				if(stringMatch(PopSizeDistShape, "Gauss") )
					IR2L_AppendAnyText("Distribution Type"+"\t=\t Gauss",0)
					NVAR GMeanSize =  $("root:Packages:IR2L_NLSQF:GMeanSize_pop"+num2str(i))	
					IR2L_AppendAnyText("GaussMean"+"\t=\t"+num2str(GMeanSize),0)
					NVAR GWidth =  $("root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(i))	
					IR2L_AppendAnyText("GaussWidth"+"\t=\t"+num2str(GWidth),0)
				elseif(stringMatch(PopSizeDistShape, "LogNormal" ))
					IR2L_AppendAnyText("DistributionShape"+"\t=\tLogNormal",0)
					NVAR LNMinSize =  $("root:Packages:IR2L_NLSQF:LNMinSize_pop"+num2str(i))	
					IR2L_AppendAnyText("LogNormalMin"+"\t=\t"+num2str(LNMinSize),0)
					NVAR LNMeanSize =  $("root:Packages:IR2L_NLSQF:LNMeanSize_pop"+num2str(i))	
					IR2L_AppendAnyText("LogNormalMean"+"\t=\t"+num2str(LNMeanSize),0)
					NVAR LNSdeviation =  $("root:Packages:IR2L_NLSQF:LNSdeviation_pop"+num2str(i))	
					IR2L_AppendAnyText("LogNormalSdeviation"+"\t=\t"+num2str(LNSdeviation),0)
				elseif(stringMatch(PopSizeDistShape, "Schulz-Zimm" ))
					IR2L_AppendAnyText("DistributionShape"+"\t=\tSchulz-Zimm",0)
					NVAR SZMeanSize =  $("root:Packages:IR2L_NLSQF:SZMeanSize_pop"+num2str(i))	
					IR2L_AppendAnyText("Schulz-Zimm Mean"+"\t=\t"+num2str(SZMeanSize),0)
					NVAR SZdeviation =  $("root:Packages:IR2L_NLSQF:SZWidth_pop"+num2str(i))	
					IR2L_AppendAnyText("Schulz-Zimm Width"+"\t=\t"+num2str(SZdeviation),0)
				elseif(stringMatch(PopSizeDistShape, "Ardell" ))
					IR2L_AppendAnyText("DistributionShape"+"\t=\tArdell",0)
					NVAR ArdLocation =  $("root:Packages:IR2L_NLSQF:ArdLocation_pop"+num2str(i))	
					IR2L_AppendAnyText("Ardell Location"+"\t=\t"+num2str(ArdLocation),0)
					NVAR ArdParameter =  $("root:Packages:IR2L_NLSQF:ArdParameter_pop"+num2str(i))	
					IR2L_AppendAnyText("Ardell Parameter"+"\t=\t"+num2str(ArdParameter),0)
				else //LSW
					IR2L_AppendAnyText("DistributionShape"+"\t=\tLSW",0)
					NVAR LSWLocation =  $("root:Packages:IR2L_NLSQF:LSWLocation_pop"+num2str(i))	
					IR2L_AppendAnyText("LSWLocation"+"\t=\t"+num2str(LSWLocation),0)				
				endif
					
				NVAR VaryContrast=root:Packages:IR2L_NLSQF:SameContrastForDataSets
				NVAR UseMultipleData=root:Packages:IR2L_NLSQF:MultipleInputData
				IR2L_AppendAnyText("  ",0)	
					if(VaryContrast && UseMultipleData	)
						IR2L_AppendAnyText("Contrasts for different data sets : ",1)	
						ListOfPopulationVariables="Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
						for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)	
							NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
							IR2L_AppendAnyText(StringFromList(k,ListOfPopulationVariables)+"="+num2str(testVar),0)
						endfor
						IR2L_AppendAnyText("  ",0)	
					else 		//same contrast for all sets... 
						NVAR Contrast = $("root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(i))
						IR2L_AppendAnyText("Contrast "+"\t=\t"+num2str(Contrast),0)				
					endif
//				// Form factor parameters.... messy... 
				SVAR FormFac=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(i))
				IR2L_AppendAnyText("  ",0)	
				//IR2L_AppendAnyText("Form factor description and parameters  ",1)	
				IR2L_AppendAnyText("FormFactor"+"\t=\t"+FormFac,0)
					if(stringmatch(FormFac, "*User*"))
						SVAR U1FormFac=$("root:Packages:IR2L_NLSQF:FFUserFFformula_pop"+num2str(i))
						IR2L_AppendAnyText("FFUserFFformula_pop"+num2str(i)+"\t=\t"+U1FormFac,0)
						SVAR U2FormFac=$("root:Packages:IR2L_NLSQF:FFUserVolumeFormula_pop"+num2str(i))
						IR2L_AppendAnyText("FFUserVolumeFormula_pop"+num2str(i)+"\t=\t"+U2FormFac,0)
					endif
					NVAR FFParam1= $("root:Packages:IR2L_NLSQF:FormFactor_Param1_pop"+num2str(i))
					if(strlen(IR1T_IdentifyFFParamName(FormFac,1))>0)
						IR2L_AppendAnyText(IR1T_IdentifyFFParamName(FormFac,1)+"  ("+"FormFactor_Param1)"+"\t=\t"+num2str(FFParam1),0)
					endif
					NVAR FFParam2= $("root:Packages:IR2L_NLSQF:FormFactor_Param2_pop"+num2str(i))
					if(strlen(IR1T_IdentifyFFParamName(FormFac,2))>0)
						IR2L_AppendAnyText(IR1T_IdentifyFFParamName(FormFac,2)+"  ("+"FormFactor_Param2)"+"\t=\t"+num2str(FFParam2),0)
					endif
					NVAR FFParam3= $("root:Packages:IR2L_NLSQF:FormFactor_Param3_pop"+num2str(i))
					if(strlen(IR1T_IdentifyFFParamName(FormFac,3))>0)
						IR2L_AppendAnyText(IR1T_IdentifyFFParamName(FormFac,3)+"  ("+"FormFactor_Param3)"+"\t=\t"+num2str(FFParam3),0)
					endif
					NVAR FFParam4= $("root:Packages:IR2L_NLSQF:FormFactor_Param4_pop"+num2str(i))
					if(strlen(IR1T_IdentifyFFParamName(FormFac,4))>0)
						IR2L_AppendAnyText(IR1T_IdentifyFFParamName(FormFac,4)+"  ("+"FormFactor_Param4)"+"\t=\t"+num2str(FFParam4),0)
					endif
					NVAR FFParam5= $("root:Packages:IR2L_NLSQF:FormFactor_Param5_pop"+num2str(i))
					if(strlen(IR1T_IdentifyFFParamName(FormFac,5))>0)
						IR2L_AppendAnyText(IR1T_IdentifyFFParamName(FormFac,5)+"  ("+"FormFactor_Param5)"+"="+num2str(FFParam5),0)
					endif

					SVAR StrFac=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(i))
					IR2L_AppendAnyText("  ",0)	
					//IR2L_AppendAnyText("Structure factor description and parameters  ",0)	
					IR2L_AppendAnyText("StructureFactor"+"\t=\t"+StrFac,0)
					if(!stringmatch(StrFac, "*Dilute system*"))
						NVAR SFParam1= $("root:Packages:IR2L_NLSQF:StructureParam1_pop"+num2str(i))
						if(strlen(IR1T_IdentifySFParamName(StrFac,1))>0)
							IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,1)+" ("+"StructureParam1"+")\t=\t"+num2str(SFParam1),0)
						endif
						NVAR SFParam2= $("root:Packages:IR2L_NLSQF:StructureParam2_pop"+num2str(i))
						if(strlen(IR1T_IdentifySFParamName(StrFac,2))>0)
							IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,2)+" ("+"StructureParam2"+")\t=\t"+num2str(SFParam2),0)
						endif
						NVAR SFParam3= $("root:Packages:IR2L_NLSQF:StructureParam3_pop"+num2str(i))
						if(strlen(IR1T_IdentifySFParamName(StrFac,3))>0)
							IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,3)+" ("+"StructureParam3"+")\t=\t"+num2str(SFParam3),0)
						endif
						NVAR SFParam4= $("root:Packages:IR2L_NLSQF:StructureParam4_pop"+num2str(i))
						if(strlen(IR1T_IdentifySFParamName(StrFac,4))>0)
							IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,4)+" ("+"StructureParam4"+")\t=\t"+num2str(SFParam4),0)
						endif
						NVAR SFParam5= $("root:Packages:IR2L_NLSQF:StructureParam5_pop"+num2str(i))
						if(strlen(IR1T_IdentifySFParamName(StrFac,5))>0)
							IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,5)+" ("+"StructureParam5"+")\t=\t"+num2str(SFParam5),0)
						endif
						NVAR SFParam6= $("root:Packages:IR2L_NLSQF:StructureParam6_pop"+num2str(i))
						if(strlen(IR1T_IdentifySFParamName(StrFac,6))>0)
							IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,6)+" ("+"StructureParam6"+")\t=\t"+num2str(SFParam6),0)
						endif
					endif	

				elseif(stringmatch(Model,"Unified level"))			//Unified level results

					IR2L_AppendAnyText("Summary results for population "+num2str(i),1)	
					IR2L_AppendAnyText("     ",0)	
					IR2L_AppendAnyText("               This population was Unified level ",0)						
					IR2L_AppendAnyText("  ",0)							
					NVAR VaryContrast=root:Packages:IR2L_NLSQF:SameContrastForDataSets
					NVAR UseMultipleData=root:Packages:IR2L_NLSQF:MultipleInputData
					if(VaryContrast && UseMultipleData	)
						IR2L_AppendAnyText("Contrasts for different data sets : ",1)	
						ListOfPopulationVariables="Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
						for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)	
							NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
							IR2L_AppendAnyText(StringFromList(k,ListOfPopulationVariables)+"="+num2str(testVar),0)
						endfor
						IR2L_AppendAnyText("  ",0)	
					else 		//same contrast for all sets... 
						NVAR Contrast = $("root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(i))
						IR2L_AppendAnyText("Contrast "+"\t=\t"+num2str(Contrast),0)				
					endif
					NVAR Rg=$("root:Packages:IR2L_NLSQF:UF_Rg_pop"+num2str(i))
					NVAR G=$("root:Packages:IR2L_NLSQF:UF_G_pop"+num2str(i))
					NVAR P=$("root:Packages:IR2L_NLSQF:UF_P_pop"+num2str(i))
					NVAR B=$("root:Packages:IR2L_NLSQF:UF_B_pop"+num2str(i))
					NVAR RgCO=$("root:Packages:IR2L_NLSQF:UF_RgCO_pop"+num2str(i))
					NVAR Kval=$("root:Packages:IR2L_NLSQF:UF_K_pop"+num2str(i))
					IR2L_AppendAnyText("Unified level Rg "+"\t=\t"+num2str(Rg),0)
					IR2L_AppendAnyText("Unified level G "+"\t=\t"+num2str(G),0)
					IR2L_AppendAnyText("Unified level B "+"\t=\t"+num2str(B),0)
					IR2L_AppendAnyText("Unified level P "+"\t=\t"+num2str(P),0)
					IR2L_AppendAnyText("Unified level RGCo "+"\t=\t"+num2str(RGCO),0)
					IR2L_AppendAnyText("Unified level K "+"\t=\t"+num2str(Kval),0)
		
					SVAR StrFac=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(i))
					IR2L_AppendAnyText("  ",0)	
					IR2L_AppendAnyText("Structure factor description and parameters  ",0)	
					IR2L_AppendAnyText("StructureFactor"+"\t=\t"+StrFac,0)
					if(!stringmatch(StrFac, "*Dilute system*"))
						NVAR SFParam1= $("root:Packages:IR2L_NLSQF:StructureParam1_pop"+num2str(i))
						if(strlen(IR1T_IdentifySFParamName(StrFac,1))>0)
							IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,1)+"\t"+"StructureParam1"+"\t=\t"+num2str(SFParam1),0)
						endif
						NVAR SFParam2= $("root:Packages:IR2L_NLSQF:StructureParam2_pop"+num2str(i))
						if(strlen(IR1T_IdentifySFParamName(StrFac,2))>0)
							IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,2)+"\t"+"StructureParam2"+"\t=\t"+num2str(SFParam2),0)
						endif
						NVAR SFParam3= $("root:Packages:IR2L_NLSQF:StructureParam3_pop"+num2str(i))
						if(strlen(IR1T_IdentifySFParamName(StrFac,3))>0)
							IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,3)+"\t"+"StructureParam3"+"\t=\t"+num2str(SFParam3),0)
						endif
						NVAR SFParam4= $("root:Packages:IR2L_NLSQF:StructureParam4_pop"+num2str(i))
						if(strlen(IR1T_IdentifySFParamName(StrFac,4))>0)
							IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,4)+"\t"+"StructureParam4"+"\t=\t"+num2str(SFParam4),0)
						endif
						NVAR SFParam5= $("root:Packages:IR2L_NLSQF:StructureParam5_pop"+num2str(i))
						if(strlen(IR1T_IdentifySFParamName(StrFac,5))>0)
							IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,5)+"\t"+"StructureParam5"+"\t=\t"+num2str(SFParam5),0)
						endif
						NVAR SFParam6= $("root:Packages:IR2L_NLSQF:StructureParam6_pop"+num2str(i))
						if(strlen(IR1T_IdentifySFParamName(StrFac,6))>0)
							IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,6)+"\t"+"StructureParam6"+"\t=\t"+num2str(SFParam6),0)
						endif
					endif

				elseif(stringmatch(Model,"MassFractal"))			//Mass Fractal results
					IR2L_AppendAnyText("Summary results for population "+num2str(i),1)	
					IR2L_AppendAnyText("     ",0)	
					IR2L_AppendAnyText("               This population was Mass Fractal ",0)						
					IR2L_AppendAnyText("  ",0)							
					NVAR VaryContrast=root:Packages:IR2L_NLSQF:SameContrastForDataSets
					NVAR UseMultipleData=root:Packages:IR2L_NLSQF:MultipleInputData
					if(VaryContrast && UseMultipleData	)
						IR2L_AppendAnyText("Contrasts for different data sets : ",1)	
						ListOfPopulationVariables="Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
						for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)	
							NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
							IR2L_AppendAnyText(StringFromList(k,ListOfPopulationVariables)+"="+num2str(testVar),0)
						endfor
						IR2L_AppendAnyText("  ",0)	
					else 		//same contrast for all sets... 
						NVAR Contrast = $("root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(i))
						IR2L_AppendAnyText("Contrast "+"\t=\t"+num2str(Contrast),0)				
					endif
						NVAR MassFrPhi=$("root:Packages:IR2L_NLSQF:MassFrPhi_pop"+num2str(i))
						NVAR MassFrRadius=$("root:Packages:IR2L_NLSQF:MassFrRadius_pop"+num2str(i))
						NVAR MassFrDv=$("root:Packages:IR2L_NLSQF:MassFrDv_pop"+num2str(i))
						NVAR MassFrKsi=$("root:Packages:IR2L_NLSQF:MassFrKsi_pop"+num2str(i))
						NVAR MassFrBeta=$("root:Packages:IR2L_NLSQF:MassFrBeta_pop"+num2str(i))
						NVAR MassFrEta=$("root:Packages:IR2L_NLSQF:MassFrEta_pop"+num2str(i))
						NVAR MassFrIntgNumPnts=$("root:Packages:IR2L_NLSQF:MassFrIntgNumPnts_pop"+num2str(i))
					IR2L_AppendAnyText("Mass Fractal Particle volume "+"\t=\t"+num2str(MassFrPhi),0)
					IR2L_AppendAnyText("Mass Fractal Particle radius [A]"+"\t=\t"+num2str(MassFrRadius),0)
					IR2L_AppendAnyText("Mass Fractal Fractal dim. "+"\t=\t"+num2str(MassFrDv),0)
					IR2L_AppendAnyText("Mass Fractal Corr. Length [A]"+"\t=\t"+num2str(MassFrKsi),0)
					IR2L_AppendAnyText("Mass Fractal Part. Asp. Rat. "+"\t=\t"+num2str(MassFrBeta),0)
					IR2L_AppendAnyText("Mass Fractal Volume filling "+"\t=\t"+num2str(MassFrEta),0)
		

				elseif(stringmatch(Model,"SurfaceFractal"))			//Mass Fractal results
					IR2L_AppendAnyText("Summary results for population "+num2str(i),1)	
					IR2L_AppendAnyText("     ",0)	
					IR2L_AppendAnyText("               This population was Surface Fractal ",0)						
					IR2L_AppendAnyText("  ",0)							
					NVAR VaryContrast=root:Packages:IR2L_NLSQF:SameContrastForDataSets
					NVAR UseMultipleData=root:Packages:IR2L_NLSQF:MultipleInputData
					if(VaryContrast && UseMultipleData	)
						IR2L_AppendAnyText("Contrasts for different data sets : ",1)	
						ListOfPopulationVariables="Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
						for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)	
							NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
							IR2L_AppendAnyText(StringFromList(k,ListOfPopulationVariables)+"="+num2str(testVar),0)
						endfor
						IR2L_AppendAnyText("  ",0)	
					else 		//same contrast for all sets... 
						NVAR Contrast = $("root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(i))
						IR2L_AppendAnyText("Contrast "+"\t=\t"+num2str(Contrast),0)				
					endif
						NVAR SurfFrSurf=$("root:Packages:IR2L_NLSQF:SurfFrSurf_pop"+num2str(i))
						NVAR SurfFrKsi=$("root:Packages:IR2L_NLSQF:SurfFrKsi_pop"+num2str(i))
						NVAR SurfFrDS=$("root:Packages:IR2L_NLSQF:SurfFrDS_pop"+num2str(i))
						NVAR SurfFrQc=$("root:Packages:IR2L_NLSQF:SurfFrQc_pop"+num2str(i))
						NVAR SurfFrQcWidth=$("root:Packages:IR2L_NLSQF:SurfFrQcWidth_pop"+num2str(i))
					IR2L_AppendAnyText("Surf. Fractal Smooth surface "+"\t=\t"+num2str(SurfFrSurf),0)
					IR2L_AppendAnyText("Surf. Fractal Fractal dim. "+"\t=\t"+num2str(SurfFrDS),0)
					IR2L_AppendAnyText("Surf. Fractal Corr. Length [A]"+"\t=\t"+num2str(SurfFrKsi),0)
					IR2L_AppendAnyText("Surf. Fractal End Q [1/A]"+"\t=\t"+num2str(SurfFrQc),0)
					IR2L_AppendAnyText("Surf. Fractal End Qw [%]"+"\t=\t"+num2str(100*SurfFrQcWidth),0)				
				elseif(stringmatch(Model,"Diffraction Peak"))
					IR2L_AppendAnyText("Summary results for population "+num2str(i),1)	
					IR2L_AppendAnyText("     ",0)	
					IR2L_AppendAnyText("               This population was Diffraction Peak ",0)						
					IR2L_AppendAnyText("  ",0)							
					NVAR VaryContrast=root:Packages:IR2L_NLSQF:SameContrastForDataSets
					NVAR UseMultipleData=root:Packages:IR2L_NLSQF:MultipleInputData
					if(VaryContrast && UseMultipleData	)
						IR2L_AppendAnyText("Contrasts for different data sets : ",1)	
						ListOfPopulationVariables="Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
						for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)	
							NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
							IR2L_AppendAnyText(StringFromList(k,ListOfPopulationVariables)+"="+num2str(testVar),0)
						endfor
						IR2L_AppendAnyText("  ",0)	
					else 		//same contrast for all sets... 
						NVAR Contrast = $("root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(i))
						IR2L_AppendAnyText("Contrast "+"\t=\t"+num2str(Contrast),0)				
					endif
					SVAR PeakProfile = $("root:Packages:IR2L_NLSQF:DiffPeakProfile_pop"+num2str(i))
					NVAR DiffPeakDPos=$("root:Packages:IR2L_NLSQF:DiffPeakDPos_pop"+num2str(i))
					NVAR DiffPeakQPos=$("root:Packages:IR2L_NLSQF:DiffPeakQPos_pop"+num2str(i))
					NVAR DiffPeakQFWHM=$("root:Packages:IR2L_NLSQF:DiffPeakQFWHM_pop"+num2str(i))
					NVAR DiffPeakIntgInt=$("root:Packages:IR2L_NLSQF:DiffPeakIntgInt_pop"+num2str(i))
					NVAR DiffPeakPar1=$("root:Packages:IR2L_NLSQF:DiffPeakPar1_pop"+num2str(i))
					NVAR DiffPeakPar2=$("root:Packages:IR2L_NLSQF:DiffPeakPar2_pop"+num2str(i))
					NVAR DiffPeakPar3=$("root:Packages:IR2L_NLSQF:DiffPeakPar3_pop"+num2str(i))
					NVAR DiffPeakPar4=$("root:Packages:IR2L_NLSQF:DiffPeakPar4_pop"+num2str(i))
					NVAR DiffPeakPar5=$("root:Packages:IR2L_NLSQF:DiffPeakPar5_pop"+num2str(i))

					IR2L_AppendAnyText("Peak profile shape "+"\t=\t"+PeakProfile,0)
					IR2L_AppendAnyText("Peak D position [A] "+"\t=\t"+num2str(DiffPeakDPos),0)
					IR2L_AppendAnyText("Peak Q position [A^-1] "+"\t=\t"+num2str(DiffPeakQPos),0)
					IR2L_AppendAnyText("Peak FWHM (Q) "+"\t=\t"+num2str(DiffPeakQFWHM),0)
					IR2L_AppendAnyText("Peak Integral Intensity "+"\t=\t"+num2str(DiffPeakIntgInt),0)
					IR2L_AppendAnyText("Prefactor "+"\t=\t"+num2str(DiffPeakPar1),0)
					IR2L_AppendAnyText("Position "+"\t=\t"+num2str(DiffPeakPar2),0)
					IR2L_AppendAnyText("Width "+"\t=\t"+num2str(DiffPeakPar3),0)
					string Par4name=""
					if(stringmatch(PeakProfile,"Pseudo-Voigt"))
						Par4name="Eta"
					elseif(stringmatch(PeakProfile,"Pearson_VII") || stringmatch(PeakProfile,"Modifif_Gauss")||stringmatch(PeakProfile,"SkewedNormal"))
						Par4name="Tail Param"
					endif
					if(strlen(Par4name)<0)
						IR2L_AppendAnyText("Eta "+"\t=\t"+num2str(DiffPeakPar4),0)
					endif
				
				endif
				IR2L_AppendAnyText("  ",0)	
				IR2L_AppendAnyText("  ",0)	
		endif
	endfor

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_SvNbk_Graphs(color)
	variable color
	    
	SVAR nbl=root:Packages:IR2L_NLSQF:NotebookName
	DoWIndow LSQF_MainGraph
	if(V_Flag)
		Notebook $nbl text="\r"
		Notebook $nbl selection={endOfFile, endOfFile}
		Notebook $nbl scaling={80,80}, frame=1, picture={LSQF_MainGraph,1,color}
		Notebook $nbl text="\r"
		Notebook $nbl text=IN2G_WindowTitle("LSQF_MainGraph")
		Notebook $nbl text="\r"
	endif

	DoWIndow LSQF_ResidualsGraph
	if(V_Flag)
		Notebook $nbl text="\r"
		Notebook $nbl selection={endOfFile, endOfFile}
		Notebook $nbl scaling={80,80}, frame=1, picture={LSQF_ResidualsGraph,1,color}
		Notebook $nbl text="\r"
		Notebook $nbl text=IN2G_WindowTitle("LSQF_ResidualsGraph")
		Notebook $nbl text="\r"
	endif
	DoWIndow GraphSizeDistributions
	if(V_Flag)
		Notebook $nbl text="\r"
		Notebook $nbl selection={endOfFile, endOfFile}
		Notebook $nbl scaling={80,80}, frame=1, picture={GraphSizeDistributions,1,color}
		Notebook $nbl text="\r"
		Notebook $nbl text=IN2G_WindowTitle("GraphSizeDistributions")
		Notebook $nbl text="\r"
	endif
End

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_SvNbk_PgBreak()
	
	    
	SVAR nbl=root:Packages:IR2L_NLSQF:NotebookName
	Notebook $nbl selection={endOfFile, endOfFile}
	Notebook $nbl SpecialChar={1,0,""}
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_SvNbk_SampleInf()
	//this function saves information about the samples
	//and header
	
	SVAR/Z nbl=root:Packages:IR2L_NLSQF:NotebookName
	if(!SVAR_Exists(nbl))
		abort
	endif
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	
	//write header here... separator and some heading to divide the record.... 
	IR2L_AppendAnyText("************************************************\r",2)	
	IR2L_AppendAnyText("Results saved on " + date() +"   "+time()+"\r",1)	
	IR2L_AppendAnyText("     ",0)	

	
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	variable i
	if(MultipleInputData)
		//multiple data selected, need to return to multiple places....
		IR2L_AppendAnyText("Multiple data sets used, listing of data sets and associated parameters\r",2)	
		for(i=1;i<11;i+=1)
			NVAR UseSet=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(i))
			if(UseSet)
				IR2L_SvNbk_DataSetSave(i)
				IR2L_AppendAnyText("",0)	
			endif
		endfor
	else
		IR2L_AppendAnyText("Single data set used:",2)	
		//only one data set to be returned... the first one
		IR2L_SvNbk_DataSetSave(1)
	endif
	
	setDataFolder OldDf
	
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************



Function IR2L_SvNbk_DataSetSave(WdtSt)
	variable WdtSt

	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	string ListOfVariables, ListOfDataVariables, ListOfPopulationVariables
	string ListOfStrings, ListOfDataStrings, ListOfPopulationsStrings
	string ListOfParameters, ListOfParametersStr
	ListOfParametersStr = ""
	ListOfParameters=""
	variable i, j 
	
	j = WdtSt
	
	//First deal with data itself... Name, background etc. 
	ListOfDataStrings ="FolderName;IntensityDataName;QvecDataName;ErrorDataName;UserDataSetName;"
	for(i=0;i<itemsInList(ListOfDataStrings);i+=1)	
		SVAR testStr = $(StringFromList(i,ListOfDataStrings)+"_set"+num2str(j))
		if(stringmatch(StringFromList(i,ListOfDataStrings),"FolderName"))
			IR2L_AppendAnyText(StringFromList(i,ListOfDataStrings)+"_set"+num2str(j)+"\t=\t"+testStr,2)
		else
			IR2L_AppendAnyText(StringFromList(i,ListOfDataStrings)+"_set"+num2str(j)+"\t=\t"+testStr,0)
		endif
	endfor
		
	ListOfDataVariables="DataScalingFactor;ErrorScalingFactor;Qmin;Qmax;Background;"
	for(i=0;i<itemsInList(ListOfDataVariables);i+=1)	
		NVAR testVar = $(StringFromList(i,ListOfDataVariables)+"_set"+num2str(j))
		IR2L_AppendAnyText(StringFromList(i,ListOfDataVariables)+"_set"+num2str(j)+"\t=\t"+num2str(testVar),0)
	endfor	
	
	//Slit smeared data?
	NVAR SlitSmeared = $("root:Packages:IR2L_NLSQF:SlitSmeared_set"+num2str(j))
	if(SlitSmeared)
		NVAR SlitLength = $("root:Packages:IR2L_NLSQF:SlitLength_set"+num2str(j))
		IR2L_AppendAnyText("Slit smeared data used...",1)
		IR2L_AppendAnyText("SlitLength"+"_set"+num2str(j)+"\t=\t"+num2str(SlitLength),0)
	else
	//	ListOfParameters+="SlitLength"+"_set"+num2str(j)+"=0;"
	endif


end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_AppendAnyText(TextToBeInserted, level)		//this function checks for existance of notebook
	string TextToBeInserted						//and appends text to the end of the notebook
	variable level 								//formating level... 0 for base, 1 and higher define my own
	    
	TextToBeInserted=TextToBeInserted+"\r"
    SVAR/Z nbl=root:Packages:IR2L_NLSQF:NotebookName
	if(SVAR_exists(nbl))
		if (strsearch(WinList("*",";","WIN:16"),nbl,0)!=-1)				//Logs data in Logbook
			Notebook $nbl selection={endOfFile, endOfFile}
			Switch(level)
				case 0:
					Notebook $nbl font="Arial", fsize=10, fStyle=-1, text=TextToBeInserted
					break
				case 1:
					Notebook $nbl font="Arial", fsize=10, fStyle=4, text=TextToBeInserted
					break
				case 2:
					Notebook $nbl font="Arial", fsize=12, fStyle=3, text=TextToBeInserted
					break
				
				default:
					Notebook $nbl text=TextToBeInserted
			endswitch
		endif
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_SvNbk_CreateNbk()
	
	SVAR/Z nbl=root:Packages:IR2L_NLSQF:NotebookName
	if(!SVAR_Exists(nbl))
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:IR2L_NLSQF 
		String/G root:Packages:IR2L_NLSQF:NotebookName=""
		SVAR nbl=root:Packages:IR2L_NLSQF:NotebookName
		nbL="ModelingII_Results"
	endif
	
	string nbLL=nbl
	
	    
	if (strsearch(WinList("*",";","WIN:16"),nbL,0)!=-1) 		///Logbook exists
		DoWindow/F $nbl
	else
		NewNotebook/K=3/N=$nbl/F=1/V=1/W=(235.5,44.75,817.5,592.25) as nbl +": Modeling Output"
		Notebook $nbl defaultTab=144, statusWidth=238, pageMargins={72,72,72,72}
		Notebook $nbl showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nbl newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={2.5*72, 3.5*72 + 8192, 5*72 + 3*8192}, rulerDefaults={"Arial",10,0,(0,0,0)}
		Notebook $nbl ruler=Normal
		Notebook $nbl  justification=1, rulerDefaults={"Arial",14,1,(0,0,0)}
		Notebook $nbl text="This is output of results from Modeling of Irena package.\r"
		Notebook $nbl text="\r"
		Notebook $nbl ruler=Normal
		IR1_InsertDateAndTime(nbl)
	endif

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function  IR2L_FixLimits(scale)
	variable scale
	
	variable i, j, tempValue
	//Input Data parameters... Will have _setX attached, in this method background needs to be here...
	//0.1 - 10x
	string ListOfDataVariables="UseTheData;"
	ListOfDataVariables+="Background;BackgroundFit;BackgroundMin;BackgroundMax;BackgErr;BackgStep;"

	for (i=1;i<=10;i+=1)
		NVAR UseData=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(i))
		if(UseData)
			NVAR Bckg = $("root:Packages:IR2L_NLSQF:Background_set"+num2str(i))
			NVAR BckgFit = $("root:Packages:IR2L_NLSQF:BackgroundFit_set"+num2str(i))
			NVAR BckgMin = $("root:Packages:IR2L_NLSQF:BackgroundMin_set"+num2str(i))
			NVAR BckgMax = $("root:Packages:IR2L_NLSQF:BackgroundMax_set"+num2str(i))
			if(BckgFit)
				BckgMin = scale*0.1 * Bckg
				BckgMax = scale*10 * Bckg
				if(BckgMin>BckgMax)
					tempValue=BckgMin
					BckgMin=BckgMax
					BckgMax=tempValue
				endif
			endif
		endif
	endfor
	string ListOfPopulationVariables=""
	ListOfPopulationVariables+="FormFactor_Param1;FormFactor_Param2;FormFactor_Param3;FormFactor_Param4;"	
	ListOfPopulationVariables+="FormFactor_Param5;FormFactor_Param6;FormFactor_Param7;FormFactor_Param8;FormFactor_Param9;"	

	ListOfPopulationVariables+="Volume;"	
	ListOfPopulationVariables+="LNMinSize;LNMeanSize;LNSdeviation;"	
	ListOfPopulationVariables+="GMeanSize;GWidth;LSWLocation;"	
	ListOfPopulationVariables+="SZMeanSize;SZWidth;"	

	ListOfPopulationVariables+="StructureParam1;StructureParam2;"
	ListOfPopulationVariables+="StructureParam3;StructureParam4;"
	ListOfPopulationVariables+="StructureParam5;StructureParam6;"
		//Unified level parameters
	ListOfPopulationVariables+="UF_G;UF_Rg;UF_B;UF_P;UF_RGCO;"
		//Diffraction peak parameters
	ListOfPopulationVariables+="DiffPeakPar1;DiffPeakPar2;DiffPeakPar3;DiffPeakPar4;DiffPeakPar5;"	
		//Fractals parameters
	ListOfPopulationVariables+="MassFrPhi;MassFrRadius;MassFrDv;MassFrKsi;SurfFrSurf;SurfFrKsi;SurfFrDS;"	

	//G, Rg, RgCO, B 0.1 - 10
	//P 0.2 (min 1) - 2 (max 4)
	//diff peaks, volume, LN, Gauss, SZ, Struct params...   - 0.5 - 2
	//
	//Common Size distribution Model parameters, these need to have _popX attached at the end of name
	string tempStr
	For(j=1;j<=10;j+=1)
		NVAR UseThePop=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(j))
		if(UseThePop)
			for (i=0;i<itemsInList(ListOfPopulationVariables);i+=1)
				tempStr = stringFromList(i,ListOfPopulationVariables)
				NVAR VarVal=$("root:Packages:IR2L_NLSQF:"+tempStr+"_pop"+num2str(j))
				NVAR FitVarVal=$("root:Packages:IR2L_NLSQF:"+tempStr+"Fit_pop"+num2str(j))
				NVAR MinVarVal=$("root:Packages:IR2L_NLSQF:"+tempStr+"Min_pop"+num2str(j))
				NVAR MaxVarVal=$("root:Packages:IR2L_NLSQF:"+tempStr+"Max_pop"+num2str(j))
				if(FitVarVal)
					if(StringMatch(tempStr, "UF_*"))
						MinVarVal= 0.1 * VarVal/scale
						MaxVarVal=scale*10 * VarVal
					elseif(StringMatch(tempStr, "UF_P"))
						MinVarVal= (VarVal/scale*0.2)>1 ? VarVal/scale*0.2 : 1
						MaxVarVal=(VarVal*scale*2)<4.5 ? (VarVal*scale*2) : 4.5
					elseif(StringMatch(tempStr, "DiffPeak*") || StringMatch(tempStr, "Volume")|| StringMatch(tempStr, "LN*")|| StringMatch(tempStr, "G*")|| StringMatch(tempStr, "SZ*")|| StringMatch(tempStr, "Structure*")|| StringMatch(tempStr, "LSW*"))
						MinVarVal= 0.5 * VarVal/scale
						MaxVarVal=scale*2 * VarVal
					elseif(StringMatch(tempStr, "FormF*"))
						MinVarVal= 0.8 * VarVal/scale
						MaxVarVal=scale*1.2 * VarVal
					elseif(StringMatch(tempStr, "MassFrDv*"))
						MinVarVal= 1
						MaxVarVal=3
					elseif(StringMatch(tempStr, "SurfFrDS*"))
						MinVarVal= 2
						MaxVarVal=3
					else
						MinVarVal= 0.5 * VarVal/scale
						MaxVarVal=scale*2 * VarVal
					endif
					if(MaxVarVal<=0)
						MaxVarVal=1
					endif
				if(MinVarVal>MaxVarVal)
					tempValue=MinVarVal
					MinVarVal=MaxVarVal
					MaxVarVal=tempValue
				endif
				endif
			endfor
		endif
	endfor
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function  IR2L_AnalyzeUncertainities()
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	//follow IR1A_ConfidenceEvaluation()
	IR2L_ConfEvResetList()
	DoWindow IR2L_ConfEvaluationPanel
	if(!V_Flag)
		IR2L_ConfEvaluationPanelF()
	else
		DoWindow/F IR2L_ConfEvaluationPanel
	endif
	IR1_CreateResultsNbk()	
	setDataFolder OldDf
end


//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
Function IR2L_ConfEvResetList()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	DoWIndow IR2L_ConfEvaluationPanel
	if(V_Flag)
		ControlInfo /W=IR2L_ConfEvaluationPanel  ListOfParamsToProcess
		if(V_Flag==11)
			KillControl /W=IR2L_ConfEvaluationPanel  ListOfParamsToProcess	
		endif
	endif
	Wave/Z ConEvParamNameWv
	Wave/Z ConEvMethodWv
	Wave/Z ConEvMinValueWv
	Wave/Z ConEvMaxValueWv
	Wave/Z ConEvNumStepsWv
	Wave/Z ConEvListboxWv
	SVAR Method = root:Packages:IR2L_NLSQF:ConEvMethod
	Method = "Sequential, fix param"
	
	Killwaves/Z ConEvParamNameWv, ConEvMethodWv, ConEvMinValueWv, ConEvMaxValueWv, ConEvNumStepsWv, ConEvListboxWv
	setDataFolder oldDf
end


//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

Function IR2L_ConfEvaluationPanelF() 
	PauseUpdate    		// building window...
	NewPanel /K=1/W=(405,136,793,600) as "Modeling uncertainitiy evaluation"
	DoWIndow/C IR2L_ConfEvaluationPanel
	//ShowTools/A
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 3,textrgb= (1,4,52428)
	DrawText 60,29,"Parameter Uncertainity Evaluation "
	SVAR ConEvSelParameter=root:Packages:IR2L_NLSQF:ConEvSelParameter
	PopupMenu SelectParameter,pos={8,59},size={163,20},proc=IR2L_ConfEvPopMenuProc,title="Select parameter  "
	PopupMenu SelectParameter,help={"Select parameter to evaluate, it had to be fitted"}
	PopupMenu SelectParameter,popvalue=ConEvSelParameter,value= #"IR2L_ConfEvalBuildListOfParams(1)"
	SetVariable ParameterMin,pos={15,94},size={149,14},bodyWidth=100,title="Min value"
	SetVariable ParameterMin,value= root:Packages:IR2L_NLSQF:ConfEvMinVal
	SetVariable ParameterMax,pos={13,117},size={151,14},bodyWidth=100,title="Max value"
	SetVariable ParameterMax,value= root:Packages:IR2L_NLSQF:ConfEvMaxVal
	SetVariable ParameterNumSteps,pos={192,103},size={153,14},bodyWidth=100,title="Num Steps"
	SetVariable ParameterNumSteps,value= root:Packages:IR2L_NLSQF:ConfEvNumSteps
	SVAR Method = root:Packages:IR2L_NLSQF:ConEvMethod
	PopupMenu Method,pos={70,150},size={212,20},proc=IR2L_ConfEvPopMenuProc,title="Method   "
	PopupMenu Method,help={"Select method to be used for analysis"}
	PopupMenu Method,mode=1,popvalue=Method,value= #"\"Sequential, fix param;Sequential, reset, fix param;Centered, fix param;Random, fix param;Random, fit param;Vary data, fit params;\""
	checkbox AutoOverwrite pos={20,180}, title="Automatically overwrite prior results?", variable=root:Packages:IR2L_NLSQF:ConfEvAutoOverwrite
	Checkbox AutoOverwrite help={"Check to avoid being asked if you want to overwrite prior results"}
	checkbox ConfEvAutoCalcTarget pos={20,200},title="Calculate ChiSq range?", variable=root:Packages:IR2L_NLSQF:ConfEvAutoCalcTarget
	Checkbox ConfEvAutoCalcTarget help={"Check to calculate the ChiSquae range"}, proc=IR2L_ConfEvalCheckProc
	checkbox ConfEvFixRanges pos={260,180}, title="Fix fit limits?", variable=root:Packages:IR2L_NLSQF:ConfEvFixRanges
	Checkbox ConfEvFixRanges help={"Check to avoid being asked if you want to fix ranges during analysis"}
	NVAR tmpVal=root:Packages:IR2L_NLSQF:ConfEvAutoCalcTarget
	SetVariable ConfEvTargetChiSqRange,pos={200,200}, limits={1,inf,0.003}, format="%1.4g", size={173,14},bodyWidth=80,title="ChiSq range target"
	SetVariable ConfEvTargetChiSqRange,value= root:Packages:IR2L_NLSQF:ConfEvTargetChiSqRange, disable=2*tmpVal
	Button GetHelp,pos={284,37},size={90,20},proc=IR2L_ConfEvButtonProc,title="Get Help"
	Button AnalyzeSelParam,pos={18,225},size={150,20},proc=IR2L_ConfEvButtonProc,title="Analyze selected Parameter"
	Button AddSetToList,pos={187,225},size={150,20},proc=IR2L_ConfEvButtonProc,title="Add  Parameter to List"
	Button AnalyzeListOfParameters,pos={18,250},size={150,20},proc=IR2L_ConfEvButtonProc,title="Analyze list of Parameters"
	Button ResetList,pos={187,250},size={150,20},proc=IR2L_ConfEvButtonProc,title="Reset List"
	Button RecoverFromAbort,pos={18,430},size={150,20},proc=IR2L_ConfEvButtonProc,title="Recover from abort"
EndMacro

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

Function IR2L_ConfEvButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	SVAR SampleFullName=root:Packages:IR2L_NLSQF:FolderName_set1			//cannot analyze more than first data set here, makes little sense to me how to do it...
	variable j
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringMatch(ba.ctrlName,"GetHelp"))
				//Generate help 
				IR1A_ConfEvHelp()
			endif
			if(stringMatch(ba.ctrlName,"AnalyzeSelParam"))
				//analyze this parameter 
				SVAR ParamName = root:Packages:IR2L_NLSQF:ConEvSelParameter
				SVAR Method = root:Packages:IR2L_NLSQF:ConEvMethod
				NVAR MinValue =root:Packages:IR2L_NLSQF:ConfEvMinVal
				NVAR MaxValue =root:Packages:IR2L_NLSQF:ConfEvMaxVal
				NVAR NumSteps =root:Packages:IR2L_NLSQF:ConfEvNumSteps
				IR1_AppendAnyText("Evaluated sample :"+StringFromList(ItemsInList(SampleFullName,":")-1,SampleFullName,":"), 1)	
				IR2L_ConEvEvaluateParameter(ParamName,MinValue,MaxValue,NumSteps,Method)
			endif
			if(stringMatch(ba.ctrlName,"AddSetToList"))
				//add this parameter to list
				IR2L_ConfEvAddToList()
			endif
			if(stringMatch(ba.ctrlName,"ResetList"))
				//add this parameter to list
				IR2L_ConfEvResetList()
			endif
			if(stringMatch(ba.ctrlName,"AnalyzeListOfParameters"))
				//analyze list of parameters
				IR1_AppendAnyText("Evaluated sample :"+StringFromList(ItemsInList(SampleFullName,":")-1,SampleFullName,":"), 1)	
				IR2L_ConfEvAnalyzeList()
			endif
			if(stringMatch(ba.ctrlName,"RecoverFromAbort"))
				//Recover from abort
				SVAR ParamName=root:Packages:IR2L_NLSQF:ConEvSelParameter
				SVAR Method=root:Packages:IR2L_NLSQF:ConEvMethod
				IR2L_ConEvRestoreBackupSettings("root:ConfidenceEvaluation:"+possiblyquoteName(StringFromList(ItemsInList(SampleFullName,":")-1,SampleFullName,":")))
				if(stringMatch(ParamName,"UncertainityEffect"))
					if(stringMatch(Method,"Vary data, fit params"))
						For(j=1;j<=10;j+=1)
							NVAR UseTheSet = $("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(j))		
							if(UseTheSet)
								Wave/Z InWave=$("root:Packages:IR2L_NLSQF:Intensity_set"+num2str(j))
								Wave/Z InWaveBckp = $("root:Packages:IR2L_NLSQF:InWaveBckp_set"+num2str(j))
								if(WaveExists(InWave)&&WaveExists(InWaveBckp))
									InWave = InWaveBckp 
								endif
							endif
						endfor
					endif
				endif
			endif


			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

static Function IR2L_ConEvBackupCurrentSettings(BackupLocation)
	string BackupLocation
	//creates backup waves (names/values) for all parameters used in current folder
	DFref oldDf= GetDataFolderDFR()

	//create folder where we dump this thing...
	setDataFolder $(BackupLocation)
	string ParamNames=IR2L_ConfEvalBuildListOfParams(0)
	ParamNames = RemoveListItem(ItemsInList(ParamNames)-1, ParamNames)
	make/O/N=1/T BackupParamNames
	make/O/N=1 BackupParamValues
	variable i, j
	string tempName
		For(j=0;j<ItemsInList(ParamNames);j+=1)
			tempName=stringFromList(j,ParamNames)
			NVAR CurPar = $("root:Packages:IR2L_NLSQF:"+tempName)
			redimension/N=(numpnts(BackupParamValues)+1) BackupParamValues, BackupParamNames
			BackupParamNames[numpnts(BackupParamNames)-1]=tempName
			BackupParamValues[numpnts(BackupParamNames)-1]=CurPar
		endfor
	setDataFolder oldDf
	
end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

static Function IR2L_ConEvRestoreBackupSettings(BackupLocation)
	string BackupLocation
	//restores backup waves (names/values) for all parameters used in current folder
	DFref oldDf= GetDataFolderDFR()

	setDataFolder $(BackupLocation)
	Wave/T BackupParamNames
	Wave BackupParamValues
	variable i, j
	string tempName
	For(i=0;i<numpnts(BackupParamValues);i+=1)
			tempName=BackupParamNames[i]
			if(strlen(tempName)>1)
				NVAR CurPar = $("root:Packages:IR2L_NLSQF:"+tempName)
				CurPar = BackupParamValues[i]
			endif
	endfor	
	setDataFolder oldDf
	
end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
static Function IR2L_ConfEvAnalyzeList()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	DoWIndow IR2L_ConfEvaluationPanel
	if(!V_Flag)
		abort
	endif
	Wave/T/Z ConEvParamNameWv
	if(!WaveExists(ConEvParamNameWv))
		abort "List of parameters to process does not exist"
	endif
	Wave/T ConEvMethodWv
	Wave ConEvMinValueWv
	Wave ConEvMaxValueWv
	Wave ConEvNumStepsWv
	Wave ConEvListboxWv
	variable i
		
		SVAR ParamName = root:Packages:IR2L_NLSQF:ConEvSelParameter
		SVAR Method = root:Packages:IR2L_NLSQF:ConEvMethod
		NVAR MinValue =root:Packages:IR2L_NLSQF:ConfEvMinVal
		NVAR MaxValue =root:Packages:IR2L_NLSQF:ConfEvMaxVal
		NVAR NumSteps =root:Packages:IR2L_NLSQF:ConfEvNumSteps
	
	For(i=0;i<numpnts(ConEvParamNameWv);i+=1)
		ParamName=ConEvParamNameWv[i]
		PopupMenu SelectParameter,win=IR2L_ConfEvaluationPanel , popvalue=ParamName
		Method=ConEvMethodWv[i]
		PopupMenu Method,win=IR2L_ConfEvaluationPanel , popvalue=Method
		MinValue=ConEvMinValueWv[i]
		MaxValue=ConEvMaxValueWv[i]
		NumSteps=ConEvNumStepsWv[i]
		print "Evaluating stability of "+ParamName
		IR2L_ConEvEvaluateParameter(ParamName,MinValue,MaxValue,NumSteps,Method)
	endfor

	DoWIndow IR2L_ConfEvaluationPanel
	if(V_Flag)
		DoWIndow/F IR2L_ConfEvaluationPanel
	endif
	
	setDataFolder oldDf
end


//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
static Function IR2L_ConfEvAddToList()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	SVAR ParamName = root:Packages:IR2L_NLSQF:ConEvSelParameter
	SVAR Method = root:Packages:IR2L_NLSQF:ConEvMethod
	NVAR MinValue =root:Packages:IR2L_NLSQF:ConfEvMinVal
	NVAR MaxValue =root:Packages:IR2L_NLSQF:ConfEvMaxVal
	NVAR NumSteps =root:Packages:IR2L_NLSQF:ConfEvNumSteps
		
	Wave/Z/T ConEvParamNameWv=root:Packages:IR2L_NLSQF:ConEvParamNameWv
	if(!WaveExists(ConEvParamNameWv))
		make/O/N=1/T ConEvParamNameWv, ConEvMethodWv, ConEvListboxWv
		make/O/N=1 ConEvMinValueWv, ConEvMaxValueWv, ConEvNumStepsWv
	else
		redimension/N=(numpnts(ConEvParamNameWv)+1) ConEvParamNameWv, ConEvMethodWv, ConEvListboxWv
		redimension/N=(numpnts(ConEvParamNameWv)+1)  ConEvMinValueWv, ConEvMaxValueWv, ConEvNumStepsWv
	endif
	ConEvParamNameWv[numpnts(ConEvParamNameWv)-1]=ParamName
	ConEvMethodWv[numpnts(ConEvParamNameWv)-1]=Method
	ConEvMinValueWv[numpnts(ConEvParamNameWv)-1]=MinValue
	ConEvMaxValueWv[numpnts(ConEvParamNameWv)-1]=MaxValue
	ConEvNumStepsWv[numpnts(ConEvParamNameWv)-1]=NumSteps
	ConEvListboxWv[numpnts(ConEvParamNameWv)-1]=ParamName+": "+Method+";Min="+num2str(MinValue)+";Max="+num2str(MaxValue)+"Steps="+num2str(NumSteps)
	
	ControlInfo /W=IR2L_ConfEvaluationPanel  ListOfParamsToProcess
	if(V_Flag!=11)
		ListBox ListOfParamsToProcess win=IR2L_ConfEvaluationPanel, pos={10,280}, size={370,140}, mode=0
		ListBox ListOfParamsToProcess listWave=root:Packages:IR2L_NLSQF:ConEvListboxWv
		ListBox ListOfParamsToProcess help={"This is list of parameters selected to be processed"}	
	endif
	setDataFolder oldDf
end


//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
static function IR2L_ConEvFixParamsIfNeeded()

	NVAR ConfEvFixRanges = root:Packages:IR2L_NLSQF:ConfEvFixRanges
	if(ConfEvFixRanges)
		IR2L_FixLimits(5)
	endif
end 

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
static Function/T IR2L_FIxParamName(ParamName)	
	string ParamName
	string NewName
	NewName=ParamName
	if(StringMatch(NewName, "FormFactor*" ))
		NewName = ReplaceString("FormFactor", NewName, "FF")
	endif
	if(StringMatch(NewName, "Structure*" ))
		NewName = ReplaceString("Structure", NewName, "SF_")
	endif
	if(strlen(NewName)>20)
		NewName=NewName[0,19]
	endif
	return NewName
end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

static Function IR2L_ConEvAnalyzeEvalResults2(ParamName)
	string ParamName
	//print GetDataFOlder(1)
	
	string LParamName=IR2L_FIxParamName(ParamName)
	SVAR SampleFullName=root:Packages:IR2L_NLSQF:DataFolderName
	NVAR ConfEVNumSteps=root:Packages:IR2L_NLSQF:ConfEVNumSteps
	Wave ConfEvStartValues=$("ConfEvStartValues")
	Wave ConfEvEndValues=$("ConfEvEndValues")
	Wave/T ConfEvCoefNames=$("ConfEvCoefNames")
	Wave ChiSquareValues=$(LParamName+"ChiSquare")
	
	variable i
	for(i=0;i<numpnts(ChiSquareValues);i+=1)
		if(ChiSquareValues[i]==0)
			ChiSquareValues[i]=NaN
		endif
	endfor
	
	KillWIndow/Z ChisquaredAnalysis
 	KillWIndow/Z ChisquaredAnalysis2
 	variable levellow, levelhigh

	IR1_CreateResultsNbk()
	//IR1_AppendAnyText("Analyzed sample "+SampleFullName, 1)	
	IR1_AppendAnyText("Effect of data uncertainities on variability of parameters", 2)
	IR1_AppendAnyText(SampleFullName, 2)	
	IR1_AppendAnyText("  ", 0)
	IR1_AppendAnyText("Run "+num2str(ConfEVNumSteps)+" fittings using data modified by random Gauss noise within \"Errors\" ", 0)
	IR1_AppendAnyText("To get following statistical results ", 0)


	wavestats/Q ChiSquareValues
	variable MeanChiSquare=V_avg
	variable StdDevChiSquare=V_sdev
	//IR1_AppendAnyText("Chi-square values : \taverage = "+num2str(MeanChiSquare)+"\tst. dev. = "+num2str(StdDevChiSquare), 0)	
	IR1_AppendAnyText("Chi-square values : \taverage +/- st. dev. = \t"+IN2G_roundToUncertainity(MeanChiSquare,StdDevChiSquare,2), 0)	

	variable j
	string tempStrName
	For(j=0;j<numpnts(ConfEvCoefNames);j+=1)
		tempStrName=ConfEvCoefNames[j]
		Duplicate/Free/O/R=[j][] ConfEvEndValues, tempWv
		wavestats/Q tempWv
		//IR1_AppendAnyText(tempStrName+" : \taverage = "+num2str(V_avg)+"\tst. dev. = "+num2str(V_sdev), 0)	
		IR1_AppendAnyText(tempStrName+" : \taverage +/- st. dev. = \t"+IN2G_roundToUncertainity(V_avg, V_sdev,2), 0)	
		
	endfor
		 

end
//******************************************************************************************************************
//******************************************************************************************************************
static Function IR2L_ConEvEvaluateParameter(ParamName,MinValue,MaxValue,NumSteps,Method)
	Variable MinValue,MaxValue,NumSteps
	String ParamName,Method
	
	string LParamName=IR2L_FIxParamName(ParamName)
	
	KillWIndow/Z ChisquaredAnalysis
 	KillWIndow/Z ChisquaredAnalysis2
 	//create folder where we dump this thing...
	NewDataFolder/O/S root:ConfidenceEvaluation
	SVAR SampleFullName=root:Packages:IR2L_NLSQF:FolderName_set1
	NVAR ConfEvAutoOverwrite = root:Packages:IR2L_NLSQF:ConfEvAutoOverwrite
	string Samplename=StringFromList(ItemsInList(SampleFullName,":")-1,SampleFullName,":")
	SampleName=IN2G_RemoveExtraQuote(Samplename,1,1)
	NewDataFolder /S/O $(Samplename)
	Wave/Z/T BackupParamNames	
	if(checkName(LParamName,11)!=0 && !ConfEvAutoOverwrite)
		DoALert /T="Folder Name Conflict" 1, "Folder with name "+LParamName+" found, do you want to overwrite prior Confidence Evaluation results?"
		if(!V_Flag)
			abort
		endif
	endif
	if(!WaveExists(BackupParamNames))
		IR2L_ConEvBackupCurrentSettings(GetDataFolder(1))
		print "Stored setting in case of abort, this can be reset by button Reset from abort"
	endif
	NewDataFolder /S/O $(LParamName)
	string BackupFilesLocation=GetDataFolder(1)
	IR2L_ConEvBackupCurrentSettings(BackupFilesLocation)
	//calculate chiSquare target if users asks for it..
	IR2L_ConfEvalCalcChiSqTarget()
	NVAR ConfEvAutoCalcTarget=root:Packages:IR2L_NLSQF:ConfEvAutoCalcTarget
	NVAR ConfEvTargetChiSqRange = root:Packages:IR2L_NLSQF:ConfEvTargetChiSqRange
	variable i, currentParValue, tempi
	make/O/N=0  $(LParamName+"ChiSquare")
	Wave ChiSquareValues=$(LParamName+"ChiSquare")
	NVAR AchievedChisq = root:Packages:IR2L_NLSQF:AchievedChisq
	variable SortForAnalysis=0
	variable FittedParameter=0

	variable j
	if(stringMatch(ParamName,"UncertainityEffect"))
		if(stringMatch(Method,"Vary data, fit params"))
			For(j=1;j<=10;j+=1)
				NVAR UseTheSet = $("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(j))		
				if(UseTheSet)
					Wave InWave=$("root:Packages:IR2L_NLSQF:Intensity_set"+num2str(j))
					Wave Ewave=$("root:Packages:IR2L_NLSQF:Error_set"+num2str(j))	
					Duplicate/O InWave, $("root:Packages:IR2L_NLSQF:InWaveBckp_set"+num2str(j))
				endif
			endfor
			For(i=0;i<NumSteps+1;i+=1)
				For(j=1;j<=10;j+=1)
					NVAR UseTheSet = $("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(j))		
					if(UseTheSet)
						Wave InWave=$("root:Packages:IR2L_NLSQF:Intensity_set"+num2str(j))
						Wave Ewave=$("root:Packages:IR2L_NLSQF:Error_set"+num2str(j))	
						Wave InWaveBckp = $("root:Packages:IR2L_NLSQF:InWaveBckp_set"+num2str(j))
						InWave = InWaveBckp + gnoise(Ewave[p])
					endif
				endfor
				IR2L_ConEvFixParamsIfNeeded()
				IR2L_InputPanelButtonProc("FitModelSkipDialogs")
				Wave/T CoefNames=root:Packages:IR2L_NLSQF:CoefNames
				Wave ValuesAfterFit=root:Packages:IR2L_NLSQF:W_coef
				Wave ValuesBeforeFit = root:Packages:IR2L_NLSQF:CoefficientInput
				Duplicate/O CoefNames, ConfEvCoefNames
				Wave/Z ConfEvStartValues
				if(i==0 || !WaveExists(ConfEvStartValues))
					Duplicate/O 	ValuesAfterFit, ConfEvEndValues
					Duplicate/O 	ValuesBeforeFit, ConfEvStartValues
				else
					Wave ConfEvStartValues
					Wave ConfEvEndValues
					redimension/N=(-1,i+1) ConfEvEndValues, ConfEvStartValues
					ConfEvStartValues[][i] = ValuesBeforeFit[p]
					ConfEvEndValues[][i] = ValuesAfterFit[p]
				endif
				redimension/N=(i+1) ChiSquareValues
				ChiSquareValues[i]=AchievedChisq
				DoUpdate
				sleep/s 1	
				IR2L_ConEvRestoreBackupSettings(BackupFilesLocation)		
			endfor	
			For(j=1;j<=10;j+=1)
				NVAR UseTheSet = $("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(j))		
				if(UseTheSet)
					Wave InWave=$("root:Packages:IR2L_NLSQF:Intensity_set"+num2str(j))
					Wave InWaveBckp = $("root:Packages:IR2L_NLSQF:InWaveBckp_set"+num2str(j))
					InWave = InWaveBckp 
				endif
			endfor
			IR2L_ConEvRestoreBackupSettings(BackupFilesLocation)
			IR2L_ConEvAnalyzeEvalResults2(ParamName)
		endif	
	else		//parameter methods
		//Metod = "Sequential, fix param;Sequential, reset, fix param;Random, fix param;Random, fit param;"
		NVAR Param=$("root:Packages:IR2L_NLSQF:"+ParamName)
		if(stringMatch(ParamName,"*_pop*"))
			NVAR ParamFit=$("root:Packages:IR2L_NLSQF:"+ReplaceString("_pop", ParamName, "Fit_pop"))
		else		//set
			NVAR ParamFit=$("root:Packages:IR2L_NLSQF:"+ReplaceString("_set", ParamName, "Fit_set"))
		endif
		make/O/N=0 $(LParamName+"StartValue"), $(LParamName+"EndValue"), $(LParamName+"ChiSquare")
		Wave StartValues=$(LParamName+"StartValue")
		Wave EndValues=$(LParamName+"EndValue")
		variable StartHere=Param
		variable step=(MaxValue-MinValue)/(NumSteps)
		if(stringMatch(Method,"Sequential, fix param"))
			ParamFit=0
			For(i=0;i<NumSteps+1;i+=1)
				redimension/N=(i+1) StartValues, EndValues, ChiSquareValues
				currentParValue = MinValue+ i* step
				StartValues[i]=currentParValue
				Param = currentParValue
				IR2L_ConEvFixParamsIfNeeded()
				IR2L_InputPanelButtonProc("FitModelSkipDialogs")
				EndValues[i]=Param
				ChiSquareValues[i]=AchievedChisq
				DoUpdate
				sleep/s 1
			endfor
			SortForAnalysis=0
			FittedParameter=0
		elseif(stringMatch(Method,"Sequential, reset, fix param"))
			ParamFit=0
			For(i=0;i<NumSteps+1;i+=1)
				redimension/N=(i+1) StartValues, EndValues, ChiSquareValues
				currentParValue = MinValue+ i* step
				StartValues[i]=currentParValue
				Param = currentParValue
				IR2L_ConEvFixParamsIfNeeded()
				IR2L_InputPanelButtonProc("FitModelSkipDialogs")
				EndValues[i]=Param
				ChiSquareValues[i]=AchievedChisq
				DoUpdate
				sleep/s 1	
				IR2L_ConEvRestoreBackupSettings(BackupFilesLocation)		
			endfor
			SortForAnalysis=0
			FittedParameter=0
		elseif(stringMatch(Method,"Centered, fix param"))
			ParamFit=0
			tempi=0
			variable NumSteps2=Ceil(NumSteps/2)
			For(i=0;i<NumSteps2;i+=1)
				tempi+=1
				redimension/N=(tempi) StartValues, EndValues, ChiSquareValues
				currentParValue = StartHere - i* step
				StartValues[tempi-1]=currentParValue
				Param = currentParValue
				IR2L_ConEvFixParamsIfNeeded()
				IR2L_InputPanelButtonProc("FitModelSkipDialogs")
				EndValues[tempi-1]=Param
				ChiSquareValues[tempi-1]=AchievedChisq
				DoUpdate
				sleep/s 1	
			endfor
			IR2L_ConEvRestoreBackupSettings(BackupFilesLocation)		
			For(i=0;i<NumSteps2;i+=1)		//and now 
				tempi+=1
				redimension/N=(tempi) StartValues, EndValues, ChiSquareValues
				currentParValue = StartHere + i* step
				StartValues[tempi-1]=currentParValue
				Param = currentParValue
				IR2L_ConEvFixParamsIfNeeded()
				IR2L_InputPanelButtonProc("FitModelSkipDialogs")
				EndValues[tempi-1]=Param
				ChiSquareValues[tempi-1]=AchievedChisq
				DoUpdate
				sleep/s 1	
			endfor
			IR2L_ConEvRestoreBackupSettings(BackupFilesLocation)		
			SortForAnalysis=1
			FittedParameter=0
		elseif(stringMatch(Method,"Random, fix param"))
			ParamFit=0
			For(i=0;i<NumSteps+1;i+=1)
				redimension/N=(i+1) StartValues, EndValues, ChiSquareValues
				currentParValue = MinValue + (0.5+enoise(0.5))*(MaxValue-MinValue)
				StartValues[i]=currentParValue
				Param = currentParValue
				IR2L_ConEvFixParamsIfNeeded()
				IR2L_InputPanelButtonProc("FitModelSkipDialogs")
				EndValues[i]=Param
				ChiSquareValues[i]=AchievedChisq
				DoUpdate
				sleep/s 1	
				//IR1A_ConEvRestoreBackupSettings(BackupFilesLocation)		
			endfor
			SortForAnalysis=1
			FittedParameter=0
		elseif(stringMatch(Method,"Random, fit param"))
			ParamFit=1
			For(i=0;i<NumSteps+1;i+=1)
				redimension/N=(i+1) StartValues, EndValues, ChiSquareValues
				currentParValue = MinValue + (0.5+enoise(0.5))*(MaxValue-MinValue)
				StartValues[i]=currentParValue
				Param = currentParValue
				IR2L_ConEvFixParamsIfNeeded()
				IR2L_InputPanelButtonProc("FitModelSkipDialogs")
				EndValues[i]=Param
				ChiSquareValues[i]=AchievedChisq
				DoUpdate
				sleep/s 1	
				//IR1A_ConEvRestoreBackupSettings(BackupFilesLocation)		
			endfor	
			SortForAnalysis=1
			FittedParameter=1
		endif
		ParamFit=1
		IR2L_ConEvRestoreBackupSettings(BackupFilesLocation)
		IR2L_InputPanelButtonProc("Recalculate")
	
		IR2L_ConEvAnalyzeEvalResults(ParamName, SortForAnalysis,FittedParameter)
	endif	//end of parameters analysis
	DoWIndow IR1A_ConfEvaluationPanel
	if(V_Flag)
		DoWIndow/F IR1A_ConfEvaluationPanel
	endif

end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

static Function IR2L_ConEvAnalyzeEvalResults(ParamName,SortForAnalysis,FittedParameter)
	string ParamName
	variable SortForAnalysis,FittedParameter
	
	string LParamName=IR2L_FIxParamName(ParamName)
	
	NVAR ConfEvTargetChiSqRange = root:Packages:IR2L_NLSQF:ConfEvTargetChiSqRange
	SVAR SampleFullName=root:Packages:IR2L_NLSQF:FolderName_set1
	Wave StartValues=$(LParamName+"StartValue")
	Wave EndValues=$(LParamName+"EndValue")
	Wave ChiSquareValues=$(LParamName+"ChiSquare")
	SVAR Method = root:Packages:IR2L_NLSQF:ConEvMethod
	if(SortForAnalysis)
		Sort EndValues, EndValues, StartValues, ChiSquareValues
	endif
	
	variable i
	for(i=0;i<numpnts(ChiSquareValues);i+=1)
		if(ChiSquareValues[i]==0)
			ChiSquareValues[i]=NaN
		endif
	endfor
	
	KillWIndow/Z ChisquaredAnalysis
 	KillWIndow/Z ChisquaredAnalysis2
 	variable levellow, levelhigh

	if(FittedParameter)	//fitted parameter, chi-square analysis needs a bit different... 
		wavestats/Q ChiSquareValues
		variable MeanChiSquare=V_avg
		variable StdDevChiSquare=V_sdev
	
		Display/W=(35,44,555,335)/K=1 ChiSquareValues vs EndValues
		DoWindow/C/T ChisquaredAnalysis,ParamName+"Chi-squared analysis of "+SampleFullName
		Label left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Achieved Chi-squared"
		Label bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"End "+ParamName+" value"
		ModifyGraph mirror=1
		ModifyGraph mode=3,marker=19
		SetAxis left (V_avg-1.5*(V_avg-V_min)),(V_avg+1.5*(V_max-V_avg))
		
		wavestats/Q EndValues
		variable MeanEndValue=V_avg
		variable StdDevEndValue=V_sdev
		Display/W=(35,44,555,335)/K=1 EndValues vs StartValues
		DoWindow/C/T ChisquaredAnalysis2,ParamName+" reproducibility analysis of "+SampleFullName
		Label left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"End "+ParamName+" value"
		Label bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Start "+ParamName+" value"
		ModifyGraph mirror=1
		ModifyGraph mode=3,marker=19		
		variable TempDisplayRange=max(V_avg-V_min, V_max-V_avg)
		SetAxis left (V_avg-1.5*(TempDisplayRange)),(V_avg+1.5*(TempDisplayRange))
		duplicate/O ChiSquareValues, EndValuesGraphAvg, EndValuesGraphMin, EndValuesGraphMax
		EndValuesGraphAvg = V_avg
		EndValuesGraphMin = V_avg-V_sdev
		EndValuesGraphMax = V_avg+V_sdev
		AppendToGraph EndValuesGraphMax,EndValuesGraphMin,EndValuesGraphAvg vs Level1RgStartValue	
		ModifyGraph lstyle(EndValuesGraphMax)=1,rgb(EndValuesGraphMax)=(0,0,0)
		ModifyGraph lstyle(EndValuesGraphMin)=1,rgb(EndValuesGraphMin)=(0,0,0)
		ModifyGraph lstyle(EndValuesGraphAvg)=7,lsize(EndValuesGraphAvg)=2
		ModifyGraph rgb(EndValuesGraphAvg)=(0,0,0)
		TextBox/C/N=text0/F=0/A=LT "Average = "+num2str(V_avg)+"\rStandard deviation = "+num2str(V_sdev)+"\rMinimum = "+num2str(V_min)+", maximum = "+num2str(V_min)
	
		AutoPositionWindow/M=0/R=IR1A_ConfEvaluationPanel ChisquaredAnalysis
		AutoPositionWindow/M=0/R=ChisquaredAnalysis ChisquaredAnalysis2

		IR1_CreateResultsNbk()
//		IR1_AppendAnyText("Analyzed sample "+SampleFullName, 1)	
		IR1_AppendAnyText("Modeling uncertainity of parameter "+ParamName, 2)
		IR1_AppendAnyText("  ", 0)
		IR1_AppendAnyText("Method used to evaluate parameter reproducibility: "+Method, 0)	
		IR1_AppendAnyGraph("ChisquaredAnalysis")
		IR1_AppendAnyGraph("ChisquaredAnalysis2")
		IR1_AppendAnyText("  ", 0)
		IR1_CreateResultsNbk()
	
	else	//parameter fixed..		
		wavestats/q ChiSquareValues
		
		Display/W=(35,44,555,335)/K=1 ChiSquareValues vs EndValues
		DoWindow/C/T ChisquaredAnalysis,ParamName+" Chi-squared analysis "
		Label left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Achieved Chi-squared"
		Label bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+ParamName+" value"
		ModifyGraph mirror=1
		ModifyGraph mode=3,marker=19
		Findlevels/Q/N=2 ChiSquareValues, ConfEvTargetChiSqRange*V_min
		if(V_Flag!=0)
			print  "The range of parameters analyzed for "+ParamName +" was not sufficiently large, code did not find large enough values for chi-squared"
			IR1_CreateResultsNbk()
//			IR1_AppendAnyText("Analyzed sample "+SampleFullName, 1)	
			IR1_AppendAnyText("Modeling evaluation of parameter "+ParamName+" failed", 2)
			IR1_AppendAnyText("  ", 0)
			IR1_AppendAnyText("Method used to evaluate parameter stability: "+Method, 0)	
			IR1_AppendAnyText("Minimum chi-squared found = "+num2str(V_min)+" for "+ParamName+"  = "+ num2str(EndValues[V_minLoc]), 0)
			IR1_AppendAnyText("Range of "+ParamName+" in which the chi-squared < "+num2str(ConfEvTargetChiSqRange)+"*"+num2str(V_min)+" was not between "+num2str(EndValues[0])+" to "+ num2str(EndValues[inf]), 0)
			IR1_CreateResultsNbk()		
			IR1_AppendAnyText("  ", 0)
		else   
			Wave W_FindLevels
			levellow=EndValues[W_FindLevels[0]]
			levelhigh=EndValues[W_FindLevels[1]]
			Tag/C/N=MinTagLL/F=0/L=2/TL=0/X=0.00/Y=30.00 $(nameofwave(ChiSquareValues)), W_FindLevels[0],"\\JCLow edge\r\\JC"+num2str(levellow)
			Tag/C/N=MinTagHL/F=0/L=2/TL=0/X=0.00/Y=30.00 $(nameofwave(ChiSquareValues)), W_FindLevels[1],"\\JCHigh edge\r\\JC"+num2str(levelhigh)
			//Tag/C/N=MinTag/F=0/L=2/TL=0/X=0.00/Y=50.00 $(nameofwave(ChiSquareValues)), V_minLoc,"Minimum chi-squared = "+num2str(V_min)+"\rat "+ParamName+" = "+num2str(EndValues[V_minLoc])+"\rRange : "+num2str(levellow)+" to "+num2str(levelhigh)
			Tag/C/N=MinTag/F=0/L=2/TL=0/X=0.00/Y=50.00 $(nameofwave(ChiSquareValues)), V_minLoc,"Minimum chi-squared = "+num2str(V_min)+"\rat "+ParamName+" = "+num2str(EndValues[V_minLoc])//+"\rRange : "+num2str(levellow)+" to "+num2str(levelhigh)
			AutoPositionWindow/M=0/R=LSQF2_MainPanel ChisquaredAnalysis
			IR1_CreateResultsNbk()
			IR1_AppendAnyText("Modeling Evaluation of parameter "+ParamName, 2)
			IR1_AppendAnyText("  ", 0)
			IR1_AppendAnyText("Method used to evaluate parameter stability: "+Method, 0)	
			IR1_AppendAnyText("Minimum chi-squared found = "+num2str(V_min)+" for "+ParamName+"  = "+ num2str(EndValues[V_minLoc]), 0)
			IR1_AppendAnyText("Range of "+ParamName+" in which the chi-squared < "+num2str(ConfEvTargetChiSqRange)+"*"+num2str(V_min)+" is from "+num2str(levellow)+" to "+ num2str(levelhigh), 0)
			IR1_AppendAnyText("           **************************************************     ", 0)
			IR1_AppendAnyText("\"Simplistic presentation\" for publications :    >>>>   "+ParamName+" =  "+IN2G_roundToUncertainity(EndValues[V_minLoc], (levelhigh - levellow)/2,2),0)
			//num2str(IN2G_roundSignificant(EndValues[V_minLoc],2))+" +/- "+num2str(IN2G_roundSignificant((levelhigh - levellow)/2,2)),0)
			IR1_AppendAnyText("           **************************************************     ", 0)
			IR1_AppendAnyGraph("ChisquaredAnalysis")
			IR1_AppendAnyText("  ", 0)
			IR1_CreateResultsNbk()
		endif
	endif
end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

Function IR2L_ConfEvPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(stringMatch(pa.ctrlName,"SelectParameter"))
				if(stringmatch(popStr,"UncertainityEffect"))
					SVAR Method = root:Packages:IR2L_NLSQF:ConEvMethod
					Method = "Vary data, fit params"
					SetVariable ParameterMin, win=IR2L_ConfEvaluationPanel, disable=1
					SetVariable ParameterMax, win=IR2L_ConfEvaluationPanel, disable=1
					PopupMenu Method, win=IR2L_ConfEvaluationPanel, mode=6
					IR2L_ConEvSetValues(popStr)
		 		else
					SetVariable ParameterMin, win=IR2L_ConfEvaluationPanel, disable=0
					SetVariable ParameterMax, win=IR2L_ConfEvaluationPanel, disable=0
					SVAR Method = root:Packages:IR2L_NLSQF:ConEvMethod
					PopupMenu Method, win=IR2L_ConfEvaluationPanel, mode=1
					Method = "Sequential, fix param"
					IR2L_ConEvSetValues(popStr)
				endif
			endif
			if(stringMatch(pa.ctrlname,"Method"))
				//here we do what is needed
				SVAR Method = root:Packages:IR2L_NLSQF:ConEvMethod
				Method = popStr
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
Function IR2L_ConfEvalCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			SetVariable ConfEvTargetChiSqRange,win= IR2L_ConfEvaluationPanel, disable=2*checked
			if(checked)
				IR2L_ConfEvalCalcChiSqTarget()
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
Function IR2L_ConfEvalCalcChiSqTarget()
	NVAR ConfEvAutoCalcTarget=root:Packages:IR2L_NLSQF:ConfEvAutoCalcTarget
	NVAR ConfEvTargetChiSqRange = root:Packages:IR2L_NLSQF:ConfEvTargetChiSqRange
	DoWIndow LSQF_MainGraph
	variable i
	if(V_Flag&&ConfEvAutoCalcTarget)
		variable startRange, endRange, Allpoints
		For(i=1;i<=10;i+=1)
			CheckDisplayed /W=LSQF_MainGraph $("root:Packages:IR2L_NLSQF:Q_set"+num2str(i))
			if(V_Flag)
				NVAR Qmin_set= $("root:Packages:IR2L_NLSQF:Qmin_set"+num2str(i))
				NVAR Qmax_set = $("root:Packages:IR2L_NLSQF:Qmax_set"+num2str(i))
				Wave Qwv=$("root:Packages:IR2L_NLSQF:Q_set"+num2str(i))
				findlevel/P/Q Qwv, Qmin_set
				startRange = V_LevelX
				findlevel/P/Q Qwv, Qmax_set
				endRange = V_LevelX
				Allpoints+= abs(endRange - startRange)
			endif
		endfor
		string ListOfPrameters=IR2L_ConfEvalBuildListOfParams(0)
		variable NumFItVals=ItemsInList(ListOfPrameters)-1
		//print "Found "+num2str(NumFItVals)+" fitted parameters"
		//method I tried...
		//ConfEvTargetChiSqRange = Allpoints/(Allpoints - NumFItVals)
		//ConfEvTargetChiSqRange = (round(1000*ConfEvTargetChiSqRange))/1000
		//method from Mateus
		variable DF = Allpoints - NumFItVals - 1		//DegreesOfFreedom
		variable parY0 = 1.01431
		variable parA1=0.05621
		variable parT1=117.48129
		variable parA2=0.0336
		variable parT2=737.73587
		variable parA3=0.10412
		variable parT3=23.25466
		ConfEvTargetChiSqRange = parY0 + parA1*exp(-DF/parT1) + parA2*exp(-DF/parT2) + parA3*exp(-DF/parT3)
		ConfEvTargetChiSqRange = (round(10000*ConfEvTargetChiSqRange))/10000
		
	endif
	return ConfEvTargetChiSqRange
end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************


Function/S IR2L_ConfEvalBuildListOfParams(SetLimits)
	variable SetLimits
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	variable i,j
	SVAR ConfEvListOfParameters=root:Packages:IR2L_NLSQF:ConfEvListOfParameters
	//Build list of paramters which user was fitting, and therefore we can analyze stability for them
	//Input Data parameters... Will have _setX attached, in this method background needs to be here...
	string ListOfPopulationVariables=""
	string ListOfDataVariables="UseTheData;"
	string ListOfPopulationsStrings="Model;FormFactor;StructureFactor;PopSizeDistShape;"	
	ListOfPopulationVariables+="FormFactor_Param1;FormFactor_Param2;FormFactor_Param3;FormFactor_Param4;"	
	ListOfPopulationVariables+="FormFactor_Param5;FormFactor_Param6;FormFactor_Param7;FormFactor_Param8;FormFactor_Param9;"	

	ListOfPopulationVariables+="Volume;"	

	ListOfPopulationVariables+="StructureParam1;StructureParam2;"
	ListOfPopulationVariables+="StructureParam3;StructureParam4;"
	ListOfPopulationVariables+="StructureParam5;StructureParam6;"
		//Unified level parameters
	ListOfPopulationVariables+="UF_G;UF_Rg;UF_B;UF_P;UF_RGCO;"
		//Diffraction peak parameters
	ListOfPopulationVariables+="DiffPeakPar1;DiffPeakPar2;DiffPeakPar3;DiffPeakPar4;DiffPeakPar5;"	
	ConfEvListOfParameters=""
	string tempName

	//Common Size distribution Model parameters, these need to have _popX attached at the end of name
	string tempStr
	For(j=1;j<=10;j+=1)
		NVAR UseThePop=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(j))
		if(UseThePop)
			//these are common variables
			ListOfPopulationVariables=""	
			SVAR Model=$("root:Packages:IR2L_NLSQF:Model_pop"+num2str(j))		//Size dist, Unified level, Diffraction peak
			SVAR PopSizeDistShape=$("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(j))
			if(stringMatch(Model,"Size dist."))
				ListOfPopulationVariables+="Volume;"	
				if(stringMatch(PopSizeDistShape,"Gauss"))
					ListOfPopulationVariables+="GMeanSize;GWidth;"
				elseif(stringMatch(PopSizeDistShape,"LogNormal"))	
					ListOfPopulationVariables+="LNMinSize;LNMeanSize;LNSdeviation;"	
				elseif(stringMatch(PopSizeDistShape,"LSW"))
					ListOfPopulationVariables+="LSWLocation;"	
				else
					ListOfPopulationVariables+="SZMeanSize;SZWidth;"	
				endif
				ListOfPopulationVariables+="FormFactor_Param1;FormFactor_Param2;FormFactor_Param3;FormFactor_Param4;"	
				ListOfPopulationVariables+="FormFactor_Param5;FormFactor_Param6;FormFactor_Param7;FormFactor_Param8;FormFactor_Param9;"	
			elseif(stringMatch(Model,"Unified level"))
				ListOfPopulationVariables+="Volume;"	
				ListOfPopulationVariables+="UF_G;UF_Rg;UF_B;UF_P;UF_RGCO;"
			elseif(stringMatch(Model,"MassFractal"))
				ListOfPopulationVariables+="MassFrPhi;"	
				ListOfPopulationVariables+="MassFrRadius;MassFrDv;MassFrKsi;"
			elseif(stringMatch(Model,"SurfaceFractal"))
				ListOfPopulationVariables+="SurfFrSurf;"	
				ListOfPopulationVariables+="SurfFrDS;SurfFrKsi;"
			elseif(stringMatch(Model,"DiffractionPeak"))		//diffraction  peak
				ListOfPopulationVariables+="DiffPeakPar1;DiffPeakPar2;DiffPeakPar3;DiffPeakPar4;DiffPeakPar5;"		
			endif
			SVAR StructureFactor=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(j))
			if(!stringMatch(StructureFactor,"Dilute system")&&(stringMatch(Model,"Size dist.")||stringMatch(Model,"Unified level")))
				ListOfPopulationVariables+="StructureParam1;StructureParam2;"
				ListOfPopulationVariables+="StructureParam3;StructureParam4;"
				ListOfPopulationVariables+="StructureParam5;StructureParam6;"
			else

			endif
			for (i=0;i<itemsInList(ListOfPopulationVariables);i+=1)
			//these are common variables - for form factor
				tempStr = stringFromList(i,ListOfPopulationVariables)
				NVAR FitVarVal=$("root:Packages:IR2L_NLSQF:"+tempStr+"Fit_pop"+num2str(j))
				if(FitVarVal)
					ConfEvListOfParameters+=tempStr+"_pop"+num2str(j)+";"
				endif
			endfor
		
		endif
	endfor


	for (i=1;i<=10;i+=1)
		NVAR UseData=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(i))
		NVAR BckgFit = $("root:Packages:IR2L_NLSQF:BackgroundFit_set"+num2str(i))
		if(UseData && BckgFit)
			ConfEvListOfParameters+="Background_set"+num2str(i)+";"
		endif
	endfor

	//print ConfEvListOfParameters
	SVAR Method = root:Packages:IR2L_NLSQF:ConEvMethod
	SVAR ConEvSelParameter=root:Packages:IR2L_NLSQF:ConEvSelParameter
	if(strlen(Method)<5)
		Method = "Sequential, fix param"
	endif
	if(SetLimits)
		ConEvSelParameter = stringFromList(0,ConfEvListOfParameters)
		IR2L_ConEvSetValues(ConEvSelParameter)
	endif
	setDataFolder OldDf
	return ConfEvListOfParameters+"UncertainityEffect;"
end

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
Function IR2L_ConEvSetValues(popStr)
	string popStr
		SVAR ConEvSelParameter=root:Packages:IR2L_NLSQF:ConEvSelParameter
		ConEvSelParameter = popStr
		NVAR/Z CurPar = $("root:Packages:IR2L_NLSQF:"+ConEvSelParameter)
		if(!NVAR_Exists(CurPar))
			//something wrong here, bail out
			return 0
		endif
		IR2L_FixLimits(1)
		if(StringMatch(popStr, "Backg*") )
			NVAR CurparLL =  $("root:Packages:IR2L_NLSQF:"+ReplaceString("_set", ConEvSelParameter, "Min_set" ) )
			NVAR CurparHL =  $("root:Packages:IR2L_NLSQF:"+ReplaceString("_set", ConEvSelParameter, "Max_set" ))
		else
			NVAR CurparLL =  $("root:Packages:IR2L_NLSQF:"+ReplaceString("_pop", ConEvSelParameter, "Min_pop" ) )
			NVAR CurparHL =  $("root:Packages:IR2L_NLSQF:"+ReplaceString("_pop", ConEvSelParameter, "Max_pop" ))
		endif
		NVAR ConfEvMinVal =  root:Packages:IR2L_NLSQF:ConfEvMinVal
		NVAR ConfEvMaxVal =  root:Packages:IR2L_NLSQF:ConfEvMaxVal
		NVAR ConfEvNumSteps =  root:Packages:IR2L_NLSQF:ConfEvNumSteps
		if(ConfEvNumSteps<3)
			ConfEvNumSteps=20
		endif
		if(stringMatch(ConEvSelParameter,"Volume*"))
			ConfEvMinVal = 0.8*CurPar
			ConfEvMaxVal = 1.2 * Curpar
		elseif(stringMatch(ConEvSelParameter,"UF_P*"))
			ConfEvMinVal = 0.95*CurPar
			ConfEvMaxVal = 1.05 * Curpar
		elseif(stringMatch(ConEvSelParameter,"UF_G*"))
			ConfEvMinVal = 0.5*CurPar
			ConfEvMaxVal = 2* Curpar
		elseif(stringMatch(ConEvSelParameter,"UF_B*"))
			ConfEvMinVal = 0.5*CurPar
			ConfEvMaxVal = 2* Curpar
		elseif(stringMatch(ConEvSelParameter,"UF_Rg*"))
			ConfEvMinVal = 0.8*CurPar
			ConfEvMaxVal = 1.2* Curpar
		elseif(stringMatch(ConEvSelParameter,"*Structure*"))
			ConfEvMinVal = 0.9*CurPar
			ConfEvMaxVal = 1.1* Curpar
		elseif(stringMatch(ConEvSelParameter,"Background*"))
			ConfEvMinVal = 0.2*CurPar
			ConfEvMaxVal = 5* Curpar
		else
			ConfEvMinVal = 0.8*CurPar
			ConfEvMaxVal = 1.2* Curpar
		endif
		//check limits...
		if(CurparLL>ConfEvMinVal)
			ConfEvMinVal = 1.01*CurparLL
		endif
		if(CurparHL<ConfEvMaxVal)
			ConfEvMaxVal = 0.99 * CurparHL
		endif
		DoWIndow IR2L_ConfEvaluationPanel
		if(V_Flag)
			SetVariable ParameterMin,win=IR2L_ConfEvaluationPanel, limits={0, (Curpar), (0.05*Curpar)}
			SetVariable ParameterMax,win=IR2L_ConfEvaluationPanel, limits={(Curpar), inf, (0.05*Curpar)}
		endif

end

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************


//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
Function IR2L_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	variable i

	if(stringmatch(ctrlName,"Continue_SDDetails"))
		KillWIndow/Z LSQF2_ModelingII_MoreDetails
	endif
	if(cmpstr(ctrlName,"GetHelp")==0)
		//Open www manual with the right page
		IN2G_OpenWebManual("Irena/Modeling.html")
	endif

	if(cmpstr(ctrlName,"RemovePointWcsrA")==0)
		ControlInfo/W=LSQF2_MainPanel DataTabs
		IR2L_Data_TabPanelControl("",V_Value)
		if(IR2L_RemovePntCsrA(V_Value))
			IR2L_RecalculateIfSelected()
		endif
	endif

	if(cmpstr(ctrlName,"AddDataSet")==0)
		//here we load the data and create default values
		ControlInfo/W=LSQF2_MainPanel DataTabs
		IR2L_LoadDataIntoSet(V_Value+1,0)			//also sets units
		NVAR UseTheData_set=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(V_Value+1))
		UseTheData_set=1
		IR2L_Data_TabPanelControl("",V_Value)
		IR2L_AppendDataIntoGraph(V_Value+1)
		IR2L_AppendOrRemoveLocalPopInts()
		IR2L_FormatInputGraph()
		IR2L_FormatLegend()
		DoWIndow LSQF_MainGraph
		if(V_Flag)
			AutoPositionWindow/R=LSQF2_MainPanel LSQF_MainGraph
		endif
		//next needs to be done to set the controls correctly... 
		NVAR DisplayInputDataControls=root:Packages:IR2L_NLSQF:DisplayInputDataControls
		NVAR DisplayModelControls=root:Packages:IR2L_NLSQF:DisplayModelControls
		DisplayModelControls = 0
		DisplayInputDataControls = 1
		TabControl DataTabs,win=LSQF2_MainPanel, value= V_Value, disable =!DisplayInputDataControls
		TabControl DistTabs,win=LSQF2_MainPanel, disable=!DisplayModelControls
		IR2L_Data_TabPanelControl("",V_Value)
	endif
	if(cmpstr(ctrlName,"AddDataSetSkipRecover")==0)
		//here we load the data and create default values
		ControlInfo/W=LSQF2_MainPanel DataTabs
		IR2L_LoadDataIntoSet(V_Value+1,1)
		NVAR UseTheData_set=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(V_Value+1))
		UseTheData_set=1
		IR2L_Data_TabPanelControl("",V_Value)
		IR2L_AppendDataIntoGraph(V_Value+1)
		IR2L_AppendOrRemoveLocalPopInts()
		IR2L_FormatInputGraph()
		IR2L_FormatLegend()
		DoWIndow LSQF_MainGraph
		if(V_Flag)
			AutoPositionWindow/R=LSQF2_MainPanel LSQF_MainGraph
		endif
	endif

	if(stringmatch(ctrlName,"GetFFHelp"))
//		ControlInfo /W=LSQF2_MainPanel FormFactorPop 
//		//print S_Value
//		DisplayHelpTopic /Z "Form Factors & Structure factors["+S_Value+"]"
//		if(V_Flag)
//			DisplayHelpTopic /Z "Form Factors & Structure factors"
//		endif
//		DoIgorMenu "Control", "Retrieve Window"
		IN2G_OpenWebManual("Irena/FormStructureFactors.html")
	endif
	if(stringmatch(ctrlName,"GetSFHelp"))
//		ControlInfo /W=LSQF2_MainPanel StructureFactorModel 
//		if(Stringmatch(S_Value,"Dilute system"))
//			DisplayHelpTopic /Z "Form Factors & Structure factors"	
//		else
//			//print S_Value
//			DisplayHelpTopic /Z "Form Factors & Structure factors["+S_Value+"]"
//			if(V_Flag)
//				DisplayHelpTopic /Z "Form Factors & Structure factors"
//			endif
//		endif
//		DoIgorMenu "Control", "Retrieve Window"
		IN2G_OpenWebManual("Irena/FormStructureFactors.html")
	endif


	if(stringmatch(ctrlName,"MoreSDParameters"))
		LSQF2_ModelingII_MoreDetailsF()
		PauseForUser LSQF2_ModelingII_MoreDetails
	endif
	
	if(stringmatch(ctrlName,"FitRgandG"))
		ControlInfo/W=LSQF2_MainPanel DistTabs
		IR2L_FitLocalGuinier(V_Value+1)
		IR2L_CalculateIntensity(0,0)
	endif
	if(stringmatch(ctrlName,"FitPandB"))
		ControlInfo/W=LSQF2_MainPanel DistTabs
		IR2L_FitLocalPorod(V_Value+1)
		IR2L_CalculateIntensity(0,0)
	endif

	if(stringmatch(ctrlName,"ScriptingTool"))
		IR2S_ScriptingTool()
		AutoPositionWindow/M=1/R=LSQF2_MainPanel IR2S_ScriptingToolPnl
		NVAR GUseIndra2data=root:Packages:IR2L_NLSQF:UseIndra2Data
		NVAR GUseQRSdata=root:Packages:IR2L_NLSQF:UseQRSdata
		NVAR STUseIndra2Data=root:Packages:Irena:ScriptingTool:UseIndra2Data
		NVAR STUseQRSData = root:Packages:Irena:ScriptingTool:UseQRSdata
		NVAR STUseResults = root:Packages:Irena:ScriptingTool:UseResults
		STUseResults=0
		STUseIndra2Data = GUseIndra2data
		STUseQRSData = GUseQRSdata
		if(STUseIndra2Data+STUseQRSData!=1)
			//Abort "At this time this scripting can be used ONLY for QRS and Indra2 data"
			STUseQRSData=1
			GUseQRSdata=1
			STUseIndra2Data = 0
			GUseIndra2data = 0
			STRUCT WMCheckboxAction CB_Struct
			CB_Struct.eventcode = 2
			CB_Struct.ctrlName = "UseQRSdata"
			CB_Struct.checked = 1
			CB_Struct.win = "LSQF2_MainPanel"
			IR2C_InputPanelCheckboxProc(CB_Struct)		
		endif
		IR2S_UpdateListOfAvailFiles()
		IR2S_SortListOfAvailableFldrs()
	endif
	if(stringmatch(ctrlName,"Recalculate"))
		IR2L_CalculateIntensity(0,0)
	endif
	if(stringmatch(ctrlName,"ReverseFit"))
		IR2L_ResetParamsAfterBadFit()
	endif
	if(stringmatch(ctrlName,"FitModel"))
		IR2L_Fitting(0)
	endif
	if(stringmatch(ctrlName,"FitModelSkipDialogs"))
		IR2L_Fitting(1)
	endif
	if(cmpstr(ctrlName,"RemoveAllDataSets")==0)
		IR2L_RemoveAllDataSets()
	endif
	if(cmpstr(ctrlName,"UnuseAllDataSets")==0)
		IR2L_unUseAllDataSets()
	endif
	if(cmpstr(ctrlName,"SaveInDataFolder")==0)
		IR2L_SaveResultsInDataFolder(0,0)
	endif
	if(cmpstr(ctrlName,"SaveInDataFolderSkipDialog")==0)
		NVAR/Z ExportSeparatePopData=root:Packages:Irena:ScriptingTool:ExportSeparatePopData
		if(NVAR_Exists(ExportSeparatePopData))
				IR2L_SaveResultsInDataFolder(1,ExportSeparatePopData)
		else
				IR2L_SaveResultsInDataFolder(1,0)
		endif
	endif
	if(cmpstr(ctrlName,"SaveInWaves")==0)
		IR2L_SaveResultsInWaves(0)
	endif
	if(cmpstr(ctrlName,"SaveInWavesSkipDialog")==0)
		IR2L_SaveResultsInWaves(1)
	endif
	if(cmpstr(ctrlName,"PasteTagsToGraph")==0)
		IR2L_AddRemoveTagsToGraph(1)
	endif
	if(cmpstr(ctrlName,"RemoveTagsFromGraph")==0)
		IR2L_AddRemoveTagsToGraph(0)
	endif
	if(cmpstr(ctrlName,"FixLimitsTight")==0)
		IR2L_FixLimits(1)
	endif
	if(cmpstr(ctrlName,"FixLimitsLoose")==0)
		IR2L_FixLimits(3)
	endif
	if(cmpstr(ctrlName,"AnalyzeUncertainities")==0)
		IR2L_AnalyzeUncertainities()
	endif
	
	if(cmpstr(ctrlName,"ReadCursors")==0)
		ControlInfo/W=LSQF2_MainPanel DataTabs
		IR2L_SetQminQmaxWCursors(V_Value+1)
	endif
	if(cmpstr(ctrlName,"ConfigureGraph")==0)
		IR2C_ConfigMain()
		//PauseForUser IR2C_MainConfigPanel
		PauseForUser IN2G_MainConfigPanel
		IR2L_FormatInputGraph()
		IR2L_FormatLegend()
	endif
	if(cmpstr(ctrlName,"ReGraph")==0)
		KillWIndow/Z LSQF_MainGraph
 		NVAR MultipleInputData = root:Packages:IR2L_NLSQF:MultipleInputData
		variable MaxDataSets=10
		if(!MultipleInputData)
			MaxDataSets=1
		endif
		For(i=1;i<=MaxDataSets;i+=1)
			NVAR UseTheData_set=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(i))
			if(UseTheData_set)
				IR2L_AppendDataIntoGraph(i)
			endif
		endfor
		IR2L_AppendOrRemoveLocalPopInts()	
		IR2L_FormatInputGraph()
		IR2L_FormatLegend()
		DoWIndow LSQF_MainGraph
		if(V_Flag)
			AutoPositionWindow/R=LSQF2_MainPanel LSQF_MainGraph
		endif
	endif

	if(cmpstr(ctrlName,"SaveInNotebook")==0)
			IR2L_SaveResultsInNotebook()
	endif

		
	DoWindow/F LSQF2_MainPanel
	setDataFolder oldDF
end



Function IR2L_DataTabCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	
	ControlInfo/W=LSQF2_MainPanel DataTabs
	variable WhichDataSet= V_Value+1
	if(V_disable)//disabled, so the model tab is visible
		ControlInfo/W=LSQF2_MainPanel DistTabs
	endif

	if (stringMatch(ctrlName,"BackgroundFit_set"))
//		IR2L_Data_TabPanelControl("",V_Value)
	endif
	if (stringMatch(ctrlName,"NoFittingLimits"))
		ControlInfo/W=LSQF2_MainPanel DistTabs
		IR2L_Model_TabPanelControl("",V_Value)
		DoWIndow FormFactorControlScreen
		NVAR NoFittingLimits = root:Packages:IR2L_NLSQF:NoFittingLimits
		if(V_Flag)
			SetWindow FormFactorControlScreen note="NoFittingLimits="+num2str(NoFittingLimits)+";"
			COntrolInfo/W=FormFactorControlScreen FitP1Value
			if(V_Flag==2 && V_disable==0 && V_Value)
				IR1T_FFCntrlPnlCheckboxProc("FitP1Value",1)
			endif
			COntrolInfo/W=FormFactorControlScreen FitP2Value
			if(V_Flag==2 && V_disable==0 && V_Value)
				IR1T_FFCntrlPnlCheckboxProc("FitP2Value",1)
			endif
			COntrolInfo/W=FormFactorControlScreen FitP3value
			if(V_Flag==2 && V_disable==0 && V_Value)
				IR1T_FFCntrlPnlCheckboxProc("FitP3Value",1)
			endif
			COntrolInfo/W=FormFactorControlScreen FitP4Value
			if(V_Flag==2 && V_disable==0 && V_Value)
				IR1T_FFCntrlPnlCheckboxProc("FitP4Value",1)
			endif
			COntrolInfo/W=FormFactorControlScreen FitP5Value
			if(V_Flag==2 && V_disable==0 && V_Value)
				IR1T_FFCntrlPnlCheckboxProc("FitP5Value",1)
			endif
			COntrolInfo/W=FormFactorControlScreen FitP6Value
			if(V_Flag==2 && V_disable==0 && V_Value)
				IR1T_FFCntrlPnlCheckboxProc("FitP6Value",1)
			endif
			COntrolInfo/W=FormFactorControlScreen FitP7Value
			if(V_Flag==2 && V_disable==0 && V_Value)
				IR1T_FFCntrlPnlCheckboxProc("FitP7Value",1)
			endif
 		endif
		DoWIndow StructureFactorControlScreen
		if(V_Flag)
			SetWindow StructureFactorControlScreen note="NoFittingLimits="+num2str(NoFittingLimits)+";"
			COntrolInfo/W=StructureFactorControlScreen FitP1Value
			if(V_Flag==2 && V_disable==0 && V_Value)
				IR2S_SFCntrlPnlCheckboxProc("FitP1Value",1)
			endif
			COntrolInfo/W=StructureFactorControlScreen FitP2Value
			if(V_Flag==2 && V_disable==0 && V_Value)
				IR2S_SFCntrlPnlCheckboxProc("FitP2Value",1)
			endif
			COntrolInfo/W=StructureFactorControlScreen FitP3value
			if(V_Flag==2 && V_disable==0 && V_Value)
				IR2S_SFCntrlPnlCheckboxProc("FitP3Value",1)
			endif
			COntrolInfo/W=StructureFactorControlScreen FitP4Value
			if(V_Flag==2 && V_disable==0 && V_Value)
				IR2S_SFCntrlPnlCheckboxProc("FitP4Value",1)
			endif
			COntrolInfo/W=StructureFactorControlScreen FitP5Value
			if(V_Flag==2 && V_disable==0 && V_Value)
				IR2S_SFCntrlPnlCheckboxProc("FitP5Value",1)
			endif
			COntrolInfo/W=StructureFactorControlScreen FitP6Value
			if(V_Flag==2 && V_disable==0 && V_Value)
				IR2S_SFCntrlPnlCheckboxProc("FitP6Value",1)
			endif
			COntrolInfo/W=StructureFactorControlScreen FitP7Value
			if(V_Flag==2 && V_disable==0 && V_Value)
				IR2S_SFCntrlPnlCheckboxProc("FitP7Value",1)
			endif
 		endif
 		IR2L_InputPanelButtonProc("FixLimitsTight")
	endif

	if (stringMatch(ctrlName,"UseTheData_set"))
		if(checked)
			IR2L_AppendDataIntoGraph(WhichDataSet)
		else
			IR2L_RemoveDataFromGraph(WhichDataSet)
		endif
		IR2L_AppendOrRemoveLocalPopInts()
		IR2L_FormatInputGraph()
		IR2L_SetTabsNames()
		//IR2L_FormatLegend()		//part of IR2L_AppendOrRemoveLocalPopInts
		IR2L_RecalculateIfSelected()
	endif
	if (stringMatch(ctrlName,"MultipleInputData"))
		if(checked)
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(0)="1.",tabLabel(1)="2."
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(2)="3.",tabLabel(3)="4."
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(4)="5.",tabLabel(5)="6."
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(6)="7.",tabLabel(7)="8."
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(8)="9.",tabLabel(9)="10.", value=0
			CheckBox SameContrastForDataSets,win=LSQF2_MainPanel,disable=0
			Button ScriptingTool,win=LSQF2_MainPanel,disable=1
			IR2L_InputPanelButtonProc("Regraph")
			IR2L_Model_TabPanelControl("",V_Value)	
			IR2L_SetTabsNames()
		else
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(0)="Input Data",tabLabel(1)=""
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(2)="",tabLabel(3)=""
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(4)="",tabLabel(5)=""
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(6)="",tabLabel(7)=""
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(8)="",tabLabel(9)="", value=0
			CheckBox SameContrastForDataSets,win=LSQF2_MainPanel,disable=1
			Button ScriptingTool,win=LSQF2_MainPanel,disable=0
			IR2L_InputPanelButtonProc("Regraph")
			IR2L_Model_TabPanelControl("",V_Value)	
		endif
		IR2L_RecalculateIfSelected()
	endif


	if (stringMatch(ctrlName,"SameContrastForDataSets"))
		NVAR SameContrastForDataSets
		NVAR VaryContrastForDataSets
		VaryContrastForDataSets = !SameContrastForDataSets
		IR2L_Model_TabPanelControl("",V_Value)	
		IR2L_RecalculateIfSelected()
	endif

	if (stringMatch(ctrlName,"DimensionIsDiameter"))
		//DoAlert 0, "Need to change here (IR2L_DataTabCheckboxProc) also graphs..."
		IR2L_RecalculateIfSelected()
		SVAR SizeDist_DimensionType= root:Packages:IR2L_NLSQF:SizeDist_DimensionType
		NVAR SizeDist_DimensionIsDiameter= root:Packages:IR2L_NLSQF:SizeDist_DimensionIsDiameter
		NVAR SizeDistDisplayNumDist = root:Packages:IR2L_NLSQF:SizeDistDisplayNumDist
		NVAR SizeDistDisplayVolDist = root:Packages:IR2L_NLSQF:SizeDistDisplayVolDist
		SizeDist_DimensionType= ""
		if(SizeDistDisplayNumDist)
			SizeDist_DimensionType = "Number distribution of "
		else
			SizeDist_DimensionType = "Volume distribution of "
		endif
		if(SizeDist_DimensionIsDiameter)
			SizeDist_DimensionType += "Diameters"
		else
			SizeDist_DimensionType += "Radia"
		endif
		IR2L_AppendWvsGraphSizeDist()
	endif
	
	NVAR DisplayInputDataControls
	NVAR DisplayModelControls
	if (stringMatch(ctrlName,"DisplayInputDataControls"))
		DisplayModelControls=!DisplayInputDataControls
		TabControl DataTabs, win=LSQF2_MainPanel, disable=!DisplayInputDataControls
		ControlInfo/W=LSQF2_MainPanel DistTabs
		IR2L_Model_TabPanelControl("",V_Value)
		TabControl DistTabs, win=LSQF2_MainPanel, disable=!DisplayModelControls
		IR2L_SetTabsNames()
	endif
	if (stringMatch(ctrlName,"DisplayModelControls"))
		DisplayInputDataControls=!DisplayModelControls
		TabControl DataTabs, win=LSQF2_MainPanel, disable=!DisplayInputDataControls
		ControlInfo/W=LSQF2_MainPanel DistTabs
		IR2L_Model_TabPanelControl("",V_Value)
		TabControl DistTabs, win=LSQF2_MainPanel, disable=!DisplayModelControls
		IR2L_SetTabsNames()
	endif

	NVAR UseUserErrors_set = $("root:Packages:IR2L_NLSQF:UseUserErrors_set"+num2str(WhichDataSet))
	NVAR UseSQRTErrors_set = $("root:Packages:IR2L_NLSQF:UseSQRTErrors_set"+num2str(WhichDataSet))
	NVAR UsePercentErrors_set = $("root:Packages:IR2L_NLSQF:UsePercentErrors_set"+num2str(WhichDataSet))
	if (stringMatch(ctrlName,"UseUserErrors_set"))
		if(UseUserErrors_set)
			UseSQRTErrors_set=0
			UsePercentErrors_set=0
		else
			UseSQRTErrors_set=1
			UsePercentErrors_set=0
		endif	
		IR2L_RecalculateIntAndErrors(WhichDataSet)
	endif
	if (stringMatch(ctrlName,"UseSQRTErrors_set"))
		if(UseSQRTErrors_set)
			UseUserErrors_set=0
			UsePercentErrors_set=0
		else
			UseUserErrors_set=0
			UsePercentErrors_set=1
		endif	
		IR2L_RecalculateIntAndErrors(WhichDataSet)
	endif
	if (stringMatch(ctrlName,"UsePercentErrors_set"))
		if(UsePercentErrors_set)
			UseUserErrors_set=0
			UseSQRTErrors_set=0
		else
			UseUserErrors_set=0
			UseSQRTErrors_set=1
		endif	
		IR2L_RecalculateIntAndErrors(WhichDataSet)
	endif
	if (stringMatch(ctrlName,"RecalculateAutomatically"))
		IR2L_RecalculateIfSelected()
	endif
	if (stringMatch(ctrlName,"UseNumberDistributions"))
		NVAR SizeDistDisplayNumDist = root:Packages:IR2L_NLSQF:SizeDistDisplayNumDist
		NVAR SizeDistDisplayVolDist = root:Packages:IR2L_NLSQF:SizeDistDisplayVolDist
		if(Checked)
			SizeDistDisplayNumDist =1
			SizeDistDisplayVolDist = 0
		else
			SizeDistDisplayNumDist =0
			SizeDistDisplayVolDist = 1
		endif
		IR2L_RecalculateIfSelected()
		SVAR SizeDist_DimensionType= root:Packages:IR2L_NLSQF:SizeDist_DimensionType
		NVAR SizeDist_DimensionIsDiameter= root:Packages:IR2L_NLSQF:SizeDist_DimensionIsDiameter
		SizeDist_DimensionType= ""
		if(SizeDistDisplayNumDist)
			SizeDist_DimensionType = "Number distribution of "
		else
			SizeDist_DimensionType = "Volume distribution of "
		endif
		if(SizeDist_DimensionIsDiameter)
			SizeDist_DimensionType += "Diameters"
		else
			SizeDist_DimensionType += "Radia"
		endif
	endif

	NVAR UseGeneticOptimization=root:Packages:IR2L_NLSQF:UseGeneticOptimization
	NVAR UseLSQF=root:Packages:IR2L_NLSQF:UseLSQF
	if (stringMatch(ctrlName,"UseGeneticOptimization"))
		UseLSQF=!UseGeneticOptimization
		NVAR NoFittingLimits=root:Packages:IR2L_NLSQF:NoFittingLimits
		NoFittingLimits=0
		if(checked)
			Execute/P("IR2L_DataTabCheckboxProc(\"NoFittingLimits\",0)")
		endif
	endif
	if (stringMatch(ctrlName,"UseLSQF"))
		UseGeneticOptimization=!UseLSQF
	endif

	if (stringMatch(ctrlName,"UseSmearing_set*"))
		if(checked)
			ControlInfo/W=LSQF2_MainPanel DataTabs
			IR2L_ResolutionSmearing(V_Value)
			setWindow IR2L_ResSmearingPanel, hook(KillFunction)=IRL2_SmearingHookFunction
			setWindow IR2L_ResSmearingPanel, note="DataSet="+num2str(V_Value+1)+";"
		else
			KillWIndow/Z IR2L_ResSmearingPanel
		endif
	endif



	ControlInfo/W=LSQF2_MainPanel DataTabs
	IR2L_Data_TabPanelControl("",V_Value)
	DoWindow/F LSQF2_MainPanel
	DoWIndow LSQF2_ModelingII_MoreDetails
	if(V_Flag)
		DoWIndow/F LSQF2_ModelingII_MoreDetails
	endif
	setDataFolder OldDf
end

//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************

Function IR2L_ResolutionSmearing(WhichSet) : Panel
	variable WhichSet
	KillWIndow/Z IR2L_ResSmearingPanel
 	variable CurDataTab = WhichSet+1
	PauseUpdate    		// building window...
	NewPanel /K=1/W=(456,270,878,560) as "Resolution Smearing"
	DoWindow/C IR2L_ResSmearingPanel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 3,textrgb= (0,0,65535)
	DrawText 20,25,"Q-resolution smearing for Data set "+num2str(WhichSet+1)
	DrawText 13,200,"Select if slit smeared - only for Bose-Hart USAXS/USANS!"
	DrawText 13,215,"Select if Q resolution smeared - typical for pinhole SAXS/SANS"
	DrawText 13,230,"Select source : Fixed = same value for each Q"
	DrawText 74,245,".... or wave in current data folder (varies per point)"
	DrawText 13,260,"Oversample points - max number of points (per measured Q) added"
	DrawText 13,275,"Ignore dQ/Q... save cpu by not smearing for small dQ/Q"
	//DrawText 13,228,"Recalculates on panel close - or do it manually. "
	SVAR SMType=$("root:Packages:IR2L_NLSQF:SmearingType_set"+num2str(CurDataTab))
	SVAR SMSrc=$("root:Packages:IR2L_NLSQF:SmearingWaveName_set"+num2str(CurDataTab))
	if(stringmatch(SMType,"Slit"))
		SMSrc = "Fixed value"
	endif
	SVAR df = $("root:Packages:IR2L_NLSQF:FolderName_set"+num2str(CurDataTab))
	string ListOfFlders=  "Fixed dQ [1/A];Fixed dQ/Q [%];"+IN2G_CreateListOfItemsInFolder(df,2)
	NVAR SlitSmeared=$("root:Packages:IR2L_NLSQF:SlitSmeared_set"+num2str(CurDataTab))
	variable PixelSmearing= StringMatch(SMType, "None" )
	variable FixedSmearing= StringMatch(SMSrc, "Fixed *")
	variable UsingLogQBinning= stringmatch(SMType,"Log-Q binning (Nika, USAXS)")

	CheckBox SlitSmeared_set,pos={15,35},size={25,16},proc=IR2L_SmearingCheckProc,title="Slit Smeared?"
	CheckBox SlitSmeared_set,variable= $("root:Packages:IR2L_NLSQF:SlitSmeared_set"+num2str(CurDataTab)), help={"Data slit smeared - Bonse-Hart system?"}
	SetVariable SlitLength,pos={140,37},size={250,15},title="Slit length [1/A]  "
	SetVariable SlitLength,help={"Either slit length for USAXS Bonse-Hart systems"}, disable = !SlitSmeared
	SetVariable SlitLength,limits={0,inf,1},value= $("root:Packages:IR2L_NLSQF:SlitLength_set"+num2str(CurDataTab))
	
	PopupMenu SmearingType,pos={12,60},size={117,20},title="Pixel Smearing ?  "
	PopupMenu SmearingType,help={"Smearing method - Bin width, Gauss for pixel smearing"}
	PopupMenu SmearingType,value= #"\"None;Bin Width [1/A];Gauss FWHM [1/A];Gauss Sigma [1/A];Bin Width [%];Gauss FWHM [%];Log-Q binning (Nika, USAXS);\"", mode=(1+WhichListItem(SMType, "None;Bin Width [1/A];Gauss FWHM [1/A];Gauss Sigma [1/A];Bin Width [%];Gauss FWHM [%];Log-Q binning (Nika, USAXS);") )
	PopupMenu SmearingType proc=IRL2_SmearingPopMenuProc

	PopupMenu SmearingSource,pos={12,85},size={171,20},title="Smearing Source"
	PopupMenu SmearingSource,help={"Either single value or wave in current folder"}
	PopupMenu SmearingSource,value=#("\""+ListOfFlders+"\"")
	PopupMenu SmearingSource, mode=(1+WhichListItem(SMSrc,ListOfFlders) )
	PopupMenu SmearingSource proc=IRL2_SmearingPopMenuProc, disable = PixelSmearing
	
	SetVariable SmearingGaussWidth,pos={12,110},size={250,15},title="Fixed dQ [1/A] or dQ/Q [%]", disable = (PixelSmearing||!FixedSmearing||UsingLogQBinning)
	SetVariable SmearingGaussWidth,help={"Pixel smearing value - Bin width or Gauss FWHM if fixed"} //, disable = DisplaySlitLength
	SetVariable SmearingGaussWidth,limits={0,inf,0},value= $("root:Packages:IR2L_NLSQF:SmearingFWHM_set"+num2str(CurDataTab))
	

	SetVariable SmearingIgnoreSmalldQ,pos={12,135},size={250,15},title="Ignore dQ/Q smaller then [%]", disable = PixelSmearing
	SetVariable SmearingIgnoreSmalldQ,help={"Ignores samller dQ/Q than specific fraction to save cpu"}
	SetVariable SmearingIgnoreSmalldQ,limits={0,inf,0},value= $("root:Packages:IR2L_NLSQF:SmearingIgnoreSmalldQ_set"+num2str(CurDataTab))
	
	NVAR SmPnts= $("root:Packages:IR2L_NLSQF:SmearingMaxNumPnts_set"+num2str(CurDataTab))
	PopupMenu SmearingMaxNumPnts,pos={12,160},size={250,15},title="Max num of oversample pnts", proc=IRL2_SmearingPopMenuProc, disable = PixelSmearing
	PopupMenu SmearingMaxNumPnts,help={"Max number of additional points where needed for smearing - per measured point"}
	PopupMenu SmearingMaxNumPnts,value=#"\"5;7;9;11;15;19;\"", mode=(1+WhichListItem(num2str(SmPnts), "5;7;9;11;15;19;"))
	
EndMacro

//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
//need hook function which sets the variable here...
Function IRL2_SmearingHookFunction(s)
		STRUCT WMWinHookStruct &s
		if(stringmatch(s.eventName,"kill"))
			GetWindow IR2L_ResSmearingPanel, note	
			variable whichSet=NumberByKey("DataSet", S_Value, "=" ,";")
			NVAR UseSmearing_set=$("root:Packages:IR2L_NLSQF:UseSmearing_set"+num2str(whichSet))
			NVAR SlitSmeared_set=$("root:Packages:IR2L_NLSQF:SlitSmeared_set"+num2str(whichSet))
			SVAR SmearingType_set=$("root:Packages:IR2L_NLSQF:SmearingType_set"+num2str(whichSet))
			if(SlitSmeared_set || !StringMatch(SmearingType_set, "None" ))
				UseSmearing_set=1
			else
				UseSmearing_set=0
			endif
			DoWIndow LSQF2_MainPanel
			if(V_Flag)
				Checkbox UseSmearing_set win=LSQF2_MainPanel, value=UseSmearing_set
			endif
		endif
end

//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
Function IRL2_SmearingPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	ControlInfo/W=LSQF2_MainPanel DataTabs
	variable CurDataTab = V_Value+1
	if(V_Value<0)
	endif
	SVAR SMType=$("root:Packages:IR2L_NLSQF:SmearingType_set"+num2str(CurDataTab))
	SVAR SMSrc=$("root:Packages:IR2L_NLSQF:SmearingWaveName_set"+num2str(CurDataTab))
	NVAR SmPnts= $("root:Packages:IR2L_NLSQF:SmearingMaxNumPnts_set"+num2str(CurDataTab))
	NVAR SLitSmeared= $("root:Packages:IR2L_NLSQF:SlitSmeared_set"+num2str(CurDataTab))
	NVAR UseSmearing_set=$("root:Packages:IR2L_NLSQF:UseSmearing_set"+num2str(CurDataTab))
	variable PixelSmearing= StringMatch(SMType, "None" )
	variable FixedSmearing= StringMatch(SMSrc, "Fixed Value")
	variable UsingLogQBinning= stringmatch(SMType,"Log-Q binning (Nika, USAXS)")
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(stringmatch(pa.ctrlName,"SmearingType"))
				SMType = popStr
				PixelSmearing= StringMatch(SMType, "None" )
				FixedSmearing= StringMatch(SMSrc, "Fixed *")
				UsingLogQBinning= stringmatch(SMType,"Log-Q binning (Nika, USAXS)")
				PopupMenu SmearingSource,win=IR2L_ResSmearingPanel, disable = PixelSmearing
				PopupMenu SmearingMaxNumPnts,win=IR2L_ResSmearingPanel, disable = PixelSmearing
				SetVariable SmearingGaussWidth,win=IR2L_ResSmearingPanel,disable = (PixelSmearing||!FixedSmearing||UsingLogQBinning)
				SetVariable SmearingIgnoreSmalldQ,win=IR2L_ResSmearingPanel,disable = (PixelSmearing||!FixedSmearing)
				PopupMenu SmearingMaxNumPnts,win=IR2L_ResSmearingPanel, disable = (PixelSmearing||!FixedSmearing)
				if(!PixelSmearing || SLitSmeared)
					UseSmearing_set = 1
				else
					UseSmearing_set = 0
				endif
			endif
			if(stringmatch(pa.ctrlName,"SmearingSource"))
				SMSrc = popStr
				PixelSmearing= StringMatch(SMType, "None" )
				FixedSmearing= StringMatch(SMSrc, "Fixed *")
				UsingLogQBinning= stringmatch(SMType,"Log-Q binning (Nika, USAXS)")
				SetVariable SmearingGaussWidth,win=IR2L_ResSmearingPanel,disable = (PixelSmearing||!FixedSmearing||UsingLogQBinning)
			endif
			if(stringmatch(pa.ctrlName,"SmearingMaxNumPnts"))
				SmPnts = str2num(popStr)
			endif
			 
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
Function IR2L_SmearingCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	ControlInfo/W=LSQF2_MainPanel DataTabs
	variable CurDataTab = V_Value+1
	SVAR SMType=$("root:Packages:IR2L_NLSQF:SmearingType_set"+num2str(CurDataTab))
	NVAR UseSmearing_set=$("root:Packages:IR2L_NLSQF:UseSmearing_set"+num2str(CurDataTab))
	variable PixelSmearing= !StringMatch(SMType, "None" )
	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(StringMatch(cba.ctrlName, "SlitSmeared_set*" ))
				SetVariable SlitLength, disable = !checked
				if(checked)
					//lets try to read the slit length from the wave note, if it is there...
					Wave/Z IntWv=$("root:Packages:IR2L_NLSQF:Intensity_set"+num2str(CurDataTab))
					if(WaveExists(IntWv))
						NVAR SlitLength= $("root:Packages:IR2L_NLSQF:SlitLength_set"+num2str(CurDataTab))
						string wnNote=note(IntWv)
						variable NoteSL=NumberByKey("SlitLength", wnNote, "=", ";")
						if(NoteSL>0)
							SlitLength = NoteSL
						endif
					endif
				endif
			endif
			if(PixelSmearing || checked)
					UseSmearing_set = 1
			else
					UseSmearing_set = 0
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
Function IR2L_FinishSmearingOfData()
	//here we slit smear data, Gauss smear data and trim Q vector and intensities properly... 
	//also, we need to fix the residuals...
	variable i
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	For(i=1;i<11;i+=1)
		NVAR UseTheData=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(i))
		if(UseTheData&&(MultipleInputData||(i==1)))	//these data are used, need to fix the data
			NVAR UseSmearing=$("root:Packages:IR2L_NLSQF:UseSmearing_set"+num2str(i))
			SVAR SmearingType=$("root:Packages:IR2L_NLSQF:SmearingType_set"+num2str(i))						//SmearingType = None;Gauss;
			SVAR SmearingWaveName=$("root:Packages:IR2L_NLSQF:SmearingWaveName_set"+num2str(i))  
			NVAR SmearingFWHM=$("root:Packages:IR2L_NLSQF:SmearingFWHM_set"+num2str(i))
			NVAR SmearingMaxNumPnts=$("root:Packages:IR2L_NLSQF:SmearingMaxNumPnts_set"+num2str(i)) 
			NVAR SlitLength=$("root:Packages:IR2L_NLSQF:SlitLength_set"+num2str(i))
			NVAR isSlitSmeared=$("root:Packages:IR2L_NLSQF:SlitSmeared_set"+num2str(i))
			//here are the waves...
			Wave OrigModelQ = $("root:Packages:IR2L_NLSQF:Qmodel_Orig_set"+num2str(i))
			Wave ModelQ=	$("root:Packages:IR2L_NLSQF:Qmodel_set"+num2str(i))	
			Wave Intensity=$("root:Packages:IR2L_NLSQF:Intensity_set"+num2str(i))
			Wave ModelIntensity=$("root:Packages:IR2L_NLSQF:IntensityModel_set"+num2str(i))
			Wave Error=$("root:Packages:IR2L_NLSQF:Error_set"+num2str(i))
			NVAR SmearingIgnoreSmalldQ= $("root:Packages:IR2L_NLSQF:SmearingIgnoreSmalldQ_set"+num2str(i))
			variable j, Qval, dQval, StartX, EndX, FWHMStartx, FWHMEndx, GaussSdev, GaussCenterX
			if(UseSmearing)		//OK< need to fix the smearing issues... 
				//first we will have to fix the Gauss smearing, if used...
				//ModelIntSumm is model for larger q range - ModelQ - containing points for q smearing and slit smearing
				//OrigModelQ is the original points we actually need... 
				// to do later - fix the Pixel smearing
				if(StringMatch(SmearingType, "None" ))
					//nothing happens here... but how did we get here anyway??? 
					//print "No pixel smearing necessary"
				   Duplicate/O/Free ModelIntensity, ModelIntPixelSmeared
				   Duplicate/O/Free ModelQ, ModelQPixelSmeared
				else		//need to smear these... 
					Wave ResolutionsWave=$("root:Packages:IR2L_NLSQF:ResolutionsWave_set"+num2str(i))
					// With Width we are using rectangular "slit" - 
					//print "finish smearing using Bin Width [1/A]"
					//we will need to get the resolutions - for now handle fixed one
					variable timerRefNum, microSeconds
					timerRefNum = StartMSTimer
				   Duplicate/O/Free OrigModelQ, ModelIntPixelSmeared
				   Duplicate/O/Free OrigModelQ, ModelQPixelSmeared
					//timerRefNum = StartMSTimer
					// this should use multiple cores, should be faster... 
					//multithread ModelIntPixelSmeared = IR2L_SmearByFunction(ModelIntensity,ModelQ, ResolutionsWave, OrigModelQ[p],ResolutionsWave[p], SmearingIgnoreSmalldQ, SmearingType)
					ModelIntPixelSmeared = IR2L_SmearByFunction(ModelIntensity,ModelQ, ResolutionsWave, OrigModelQ[p],ResolutionsWave[p], SmearingIgnoreSmalldQ, SmearingType)
					//microSeconds = StopMSTimer(timerRefNum)
					//Print microSeconds/10000, "microseconds new method"
				endif
		
				//note, we need to end with Int vs Q using original Q points - except may be extended for slit smearing...
				
				if(isSlitSmeared)
						IR2L_SlitSmearLSQFData(ModelIntPixelSmeared,ModelQPixelSmeared,SlitLength)
				endif
				//now need to make this properly moved to use Qmodel_set and delete the original
				//Assume that we have only original q points by now and the extension to higher then slit length...  
				//Ideally, all we need is just delete all points beyond the needed range 
				Duplicate/O ModelIntPixelSmeared, $("root:Packages:IR2L_NLSQF:IntensityModel_set"+num2str(i))
				//ModelIntensity = ModelIntPixelSmeared
				//DeletePoints (numpnts(OrigModelQ)), (numpnts(ModelIntensity) - numpnts(OrigModelQ)), ModelIntensity 
				Duplicate/O OrigModelQ, $("root:Packages:IR2L_NLSQF:Qmodel_set"+num2str(i)) 
				KillWaves OrigModelQ
			else	//just cleanup not to confuse anyone :-)
				KillWaves OrigModelQ		//this one is not needed as it is the same thing as the Qmodel_set 
				//when no smearing is used... 
			endif
		endif
	endfor
end
//**************************************************************************************************************************************************************************************
///
// 
//threadsafe Function IR2L_SmearByFunction(ModelIntensity,ModelQ,ResolutionsWave, Qval,dQval, IgSmalldQ, SmearingType)
Function IR2L_SmearByFunction(ModelIntensity,ModelQ,ResolutionsWave, Qval,dQval, IgSmalldQ, SmearingType)
		Wave ModelIntensity, ModelQ, ResolutionsWave
		variable Qval, dQval, IgSmalldQ
		string SmearingType
		
		Variable SmearedIntValue, GaussSdev
		
		make/Free/N=51/D tmpModelInt, tmpSmFnct
			if(dQval/Qval > (0.01 * IgSmalldQ))
				if(StringMatch(SmearingType, "Bin Width *" ))
					//bin width is average of -dQ/2 to +dQ/2 around Q
					SetScale /I x, Qval-(dQval/2), Qval+(dQval/2), tmpModelInt, tmpSmFnct
					tmpModelInt = ModelIntensity[BinarySearchInterp(ModelQ,x)]
					tmpSmFnct = 1
					SmearedIntValue = area(tmpModelInt)/area(tmpSmFnct)
					//print j, area(tmpModelInt), area(tmpSmFnct)
				elseif(StringMatch(SmearingType, "Gauss FWHM *" ))
					//Gaus is average over -FWHM to +FWHM around Q after weighing by Gauss distribution with FWHM
					SetScale /I x, Qval-(2*dQval), Qval+(2*dQval), tmpModelInt, tmpSmFnct
					tmpModelInt = ModelIntensity[BinarySearchInterp(ModelQ,x)]
					GaussSdev = dQval/2.355	//convert Gauss FWHM to sigma 
					tmpSmFnct = Gauss(x,Qval,GaussSdev)
					tmpModelInt = tmpModelInt * tmpSmFnct
					SmearedIntValue = area(tmpModelInt)/area(tmpSmFnct)
					//print j, area(tmpModelInt), area(tmpSmFnct)
				elseif(StringMatch(SmearingType, "Gauss Sigma *" ))
					//Gaus is average over -FWHM to +FWHM around Q after weighing by Gauss distribution with FWHM
					SetScale /I x, Qval-(3*dQval), Qval+(3*dQval), tmpModelInt, tmpSmFnct
					tmpModelInt = ModelIntensity[BinarySearchInterp(ModelQ,x)]
					GaussSdev = dQval		//this is directly the Gauss sigma needed... 
					tmpSmFnct = Gauss(x,Qval,GaussSdev)
					tmpModelInt = tmpModelInt * tmpSmFnct
					SmearedIntValue = area(tmpModelInt)/area(tmpSmFnct)
					//print j, area(tmpModelInt), area(tmpSmFnct)
				elseif(StringMatch(SmearingType, "Log-Q binning *" ))		//this is Nika log-Q binning of USAXS flyscan log-q binning. Need to transition from Gauss at low q to rectangle at high q
					if(dQval<(ResolutionsWave[0]*ChangeFromGaussToSlit))		//low-q range, dQ is similar to the first one, assume Gauss dist. 
						//Gauss is average over -FWHM to +FWHM around Q after weighing by Gauss distribution with FWHM
						//5-24-2021 changed USAXS to provide resolution as 1/2 FWHM which matches slit length, which is also 1/2 of the Q smearing range (effectively). 
						//then this code should be correct... 
						SetScale /I x, Qval-dQval, Qval+dQval, tmpModelInt, tmpSmFnct
						tmpModelInt = ModelIntensity[BinarySearchInterp(ModelQ,x)]
						GaussSdev = dQval/2.355/2
						tmpSmFnct = Gauss(x,Qval,GaussSdev)
						tmpModelInt = tmpModelInt * tmpSmFnct
						SmearedIntValue = area(tmpModelInt)/area(tmpSmFnct)
					else															//dQ > ChangeFromGaussToSlit * dQ[0], which means we are more in range where rectangular smearing is appropriate. 
						//bin width is average of -dQ/2 to +dQ/2 around Q
						SetScale /I x, Qval-(dQval/2), Qval+(dQval/2), tmpModelInt, tmpSmFnct
						tmpModelInt = ModelIntensity[BinarySearchInterp(ModelQ,x)]
						tmpSmFnct = 1
						SmearedIntValue = area(tmpModelInt)/area(tmpSmFnct)
					endif
				endif
			else
				SmearedIntValue = ModelIntensity[BinarySearchInterp(ModelQ,Qval)]
				//print "Skipped smearing for point number : "+num2str(j)
			endif
	return SmearedIntValue
end
//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************

Function IR2L_CreateResidulas()
	//create residuals
	variable i
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	For(i=1;i<11;i+=1)
		NVAR UseTheData=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(i))
		if(UseTheData&&(MultipleInputData||(i==1)))	//these data are used, need to fix the data
			Wave ModelQ=	$("root:Packages:IR2L_NLSQF:Qmodel_set"+num2str(i))	
			Wave Intensity=$("root:Packages:IR2L_NLSQF:Intensity_set"+num2str(i))
			Wave ModelIntensity=$("root:Packages:IR2L_NLSQF:IntensityModel_set"+num2str(i))
			Wave Error=$("root:Packages:IR2L_NLSQF:Error_set"+num2str(i))
			NVAR QMin=$("root:Packages:IR2L_NLSQF:Qmin_set"+num2str(i))
			NVAR QMax=$("root:Packages:IR2L_NLSQF:Qmax_set"+num2str(i))
			Wave/Z Qwave=$("root:Packages:IR2L_NLSQF:Q_set"+num2str(i))
			variable StartPoint, EndPoint
			StartPoint = BinarySearch(Qwave, QMin)
			EndPoint = BinarySearch(Qwave, QMax)
			if(StartPoint<0)
				StartPoint=0
			endif
			if(EndPoint<0)
				EndPoint = numpnts(Qwave)-1
			endif
			//Duplicate/O/R=[StartPoint,EndPoint] Qwave, $("Qmodel_Orig_set"+num2str(i))
			//create residuals wave and set it to proper values, Nans where not used...
			Duplicate/O Intensity, $("root:Packages:IR2L_NLSQF:Residuals_set"+num2str(i))
			Wave residuals=$("root:Packages:IR2L_NLSQF:Residuals_set"+num2str(i))
			residuals = NaN
			//this is weird, the Intensity and Error have too many points - these are not the ones with mask - these are all points in the ssystem.
			//someone forgot to trim these off!
			residuals[StartPoint,EndPoint] = (Intensity[p] - ModelIntensity[p-StartPoint]) / Error[p]
		endif
	endfor
end

//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************

Function IR2L_PrepareSetsQvectors()		
	//this prepares Q vectors for sets, if used and modifies them for smearing, if needed
	variable i
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	For(i=1;i<11;i+=1)
		NVAR UseTheData=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(i))
		if(UseTheData&&(MultipleInputData||(i==1)))	//these data are used, need to prepare the Q vector
		
			NVAR QMin=$("root:Packages:IR2L_NLSQF:Qmin_set"+num2str(i))
			NVAR QMax=$("root:Packages:IR2L_NLSQF:Qmax_set"+num2str(i))
			Wave/Z Qwave=$("root:Packages:IR2L_NLSQF:Q_set"+num2str(i))
			if (!WaveExists (Qwave))
				Abort "Select original data first"
			endif
			variable StartPoint, EndPoint
			StartPoint = BinarySearch(Qwave, QMin)
			EndPoint = BinarySearch(Qwave, QMax)
			if(StartPoint<0)
				StartPoint=0
			endif
			if(EndPoint<0)
				EndPoint = numpnts(Qwave)-1
			endif
			Duplicate/O/R=[StartPoint,EndPoint] Qwave, $("root:Packages:IR2L_NLSQF:Qmodel_Orig_set"+num2str(i))
			Wave OrigModelQ = $("root:Packages:IR2L_NLSQF:Qmodel_Orig_set"+num2str(i))
			Duplicate/O OrigModelQ, $("root:Packages:IR2L_NLSQF:Qmodel_set"+num2str(i))	
			Wave ModelQ=	$("root:Packages:IR2L_NLSQF:Qmodel_set"+num2str(i))	
			//this is now correct Original Q points Q vector... 
			//next we need to prepare temperary one, which we will call for historical reasons Qmodel_set
			//so we do not have to change rest of the code... This will have to be fixed at the end of the
			//calculations...  
			//	ListOfDataVariables="SlitSmeared;UseSmearing;SlitLength;SmearingFWHM;SmearingGaussWidth;SmearingMaxNumPnts;Qmin;Qmax;"
			// ListOfDataVariables+="SmearingIgnoreSmalldQ;"

			NVAR UseSmearing=$("root:Packages:IR2L_NLSQF:UseSmearing_set"+num2str(i))
			SVAR SmearingType=$("root:Packages:IR2L_NLSQF:SmearingType_set"+num2str(i))						//SmearingType = None;Gauss;
			SVAR SmearingWaveName=$("root:Packages:IR2L_NLSQF:SmearingWaveName_set"+num2str(i))  
			NVAR SmearingFWHM=$("root:Packages:IR2L_NLSQF:SmearingFWHM_set"+num2str(i))
			NVAR SmearingMaxNumPnts=$("root:Packages:IR2L_NLSQF:SmearingMaxNumPnts_set"+num2str(i)) 
			NVAR SlitLength=$("root:Packages:IR2L_NLSQF:SlitLength_set"+num2str(i))
			NVAR isSlitSmeared=$("root:Packages:IR2L_NLSQF:SlitSmeared_set"+num2str(i))
			NVAR SmearingIgnoreSmalldQ= $("root:Packages:IR2L_NLSQF:SmearingIgnoreSmalldQ_set"+num2str(i))
			SVAR DataFolder= $("root:Packages:IR2L_NLSQF:FolderName_set"+num2str(i))
			variable OldNumPnts, QdistanceNeeded, LastQstep, NumNewQPoints
			variable ExtensionQstep, ij, ik, newIDX, j
			variable Qval, dQval, ExistQs, StartP, EndP, Qstep, curQ, QOffset
			if(UseSmearing)
				//now here we need to make q scale which will be also usable for pixel smearing, if needed...
				//again, at the end we will have just the two q vectors - short and user selected Qmodel_Orig_set
				//and extended as needed Qmodel_set
				if(!StringMatch(SmearingType, "None" ))	//these are pixel smeared data			
					//we will need to get the resolutions - for now handle fixed one
					if(stringmatch(SmearingWaveName,"Fixed dQ [1/A]"))		//fixed value for each point, have just one input number from user
						Duplicate/O OrigModelQ, $("root:Packages:IR2L_NLSQF:ResolutionsWave_set"+num2str(i))
						Wave ResolutionsWave = $("root:Packages:IR2L_NLSQF:ResolutionsWave_set"+num2str(i))
						ResolutionsWave = SmearingFWHM											//for this settings, this is in Q units
					elseif(stringmatch(SmearingWaveName,"Fixed dQ/Q [%]"))
						Duplicate/O OrigModelQ, $("root:Packages:IR2L_NLSQF:ResolutionsWave_set"+num2str(i))
						Wave ResolutionsWave = $("root:Packages:IR2L_NLSQF:ResolutionsWave_set"+num2str(i))
						ResolutionsWave = OrigModelQ[p]*0.01*SmearingFWHM				//for this settings, this is in % of Q, need to convert to Q units
					else																				//this is wave. Need to find it and create it here...
						Wave/Z UserSelResWv=$(DataFolder+SmearingWaveName)
						if(!WaveExists(UserSelResWv) || (numpnts(Qwave)!=numpnts(UserSelResWv)))
							Abort "Wrong Resolution wave selected, either does not exist or has wrong number of points"
						endif
						Duplicate/O/R=[StartPoint,EndPoint] UserSelResWv, $("ResolutionsWave_set"+num2str(i))
						Wave ResolutionsWave = $("root:Packages:IR2L_NLSQF:ResolutionsWave_set"+num2str(i))
						if(StringMatch(SmearingType, "* [1/A]" ) || StringMatch(SmearingType, "Log-Q binning (Nika, USAXS)" ))
							//resolutions wave is allready in Q units, nothing to do here... 
						else	// these are in %
							ResolutionsWave = OrigModelQ[p]*0.01*ResolutionsWave[p]
						endif
					endif
				endif
				//at the end, we should have wave called ResolutionsWave with q resolutions in Q units. The ResolutionsWave has same number of points as OrigModelQ
				//Now need to generate new Q scale. ,we will ignore Qwidth values smaller then SmearingIgnoreSmalldQ% of the Q value. 
				variable isStart, isEnd
				isStart = 0
				isEnd = 0
				if(!StringMatch(SmearingType, "None" ))
					//need to add user selected number of points through the width only.
					Make/Free/N=(1.5*SmearingMaxNumPnts*numpnts(OrigModelQ)) tempQwv		
					tempQwv= nan
					newIDX = 0
					for(ik=0;ik<numpnts(OrigModelQ);ik+=1)
							Qval = OrigModelQ[ik]
							dQval = 1.1*ResolutionsWave[ik]					//thsi needs to be larger Q range to prevent numerical failures in lookup later. 
							FindLevel /P/Q OrigModelQ, (Qval-dQval)
							if(V_Flag==0)
								StartP = floor(V_LevelX)
								isStart = 0
							else
								StartP = 0
								isStart = 1
							endif
							FindLevel /P/Q OrigModelQ, (Qval+dQval)
							if(V_Flag==0)
								EndP = ceil(V_LevelX)
								isEnd = 0
							else
								EndP = numpnts(OrigModelQ)-1
								isEnd = 1
							endif
							if(isStart || isEnd)
								ExistQs = 0
							else
								ExistQs = EndP - StartP
							endif
							if((ExistQs<SmearingMaxNumPnts)&&((dQval/Qval)>(0.01*SmearingIgnoreSmalldQ)))		//found in the dQ less points then user wanted, so we need to rebin this
								if(StringMatch(SmearingType, "* Width *" ))
									Qstep = dQval/(SmearingMaxNumPnts-1)					//this is +/- width/2 assumptiton with rectangular shape
									QOffset = dQval/2
								elseif(StringMatch(SmearingType, "Log-Q binning *" ))		//this is Nika log-Q binning of USAXS flyscan log-q binning. Need to transition from Gauss at low q to rectangle at high q
									if(dQval<(ResolutionsWave[0]*ChangeFromGaussToSlit))		//low-q range, dQ is similar to the first one, assume Gauss dist. 
										Qstep = 2*dQval/(SmearingMaxNumPnts-1)				//this is Gauss with FWHM defined, so step could be +/- 0.5*FHWM, but to get the edge ones we will widen the step to twice...  
										QOffset = dQval
									else															//dQ > ChangeFromGaussToSlit * dQ[0], which means we are more in range where rectangular smearing is appropriate. 
										Qstep = dQval/(SmearingMaxNumPnts-1)					//this is +/- width/2 assumtpiton with rectangular shape
										QOffset = dQval/2
									endif
								elseif(StringMatch(SmearingType, "* FWHM *" ))			//Gauss FWHM, we need data to larger range of points - assume that +/- FWHM around Q shoudl be enough
									Qstep = 2*dQval/(SmearingMaxNumPnts-1)					//this is Gauss with FWHM defined, so step could be +/- 0.5*FHWM, but to get the edge ones we will widen the step to twice...  
									QOffset = dQval
								elseif(StringMatch(SmearingType, "* Sigma *" ))			//Gauss FWHM, we need data to larger range of points - assume that +/- FWHM around Q shoudl be enough
									Qstep = 2*2.355*dQval/(SmearingMaxNumPnts-1)					//this is Gauss with sigma defined, so step could be +/- 0.5*FHWM, but to get the edge ones we will widen the step to twice...  
									QOffset = 2.355*dQval
								else
									Abort "Unknown smearing type" 
								endif
								For(j=0;j<=SmearingMaxNumPnts;j+=1)
									curQ = Qval-QOffset+(j*Qstep)
									findlevel/Q tempQwv, curQ							//check if we already added points in this area, if yes, do not add new points. 
									if(V_Flag && curQ>0)									//
										tempQwv[newIDX] = curQ
										newIDX+=1
									endif
								endfor
							 elseif(isEnd)													// need to add at least one mor epoint, Typical case is end 
							 	 tempQwv[newIDX] = Qval
								 newIDX +=1
							 	 tempQwv[newIDX] = Qval+dQval
								 newIDX +=1
				 			 else		//no rebining needed, to next point now...
							 	 tempQwv[newIDX] = Qval
								 newIDX +=1
							 endif
						 endfor	
					//endif
					DeletePoints newIDX, (numpnts(tempQwv)-newIDX), tempQwv 
					Sort tempQwv, tempQwv
					Duplicate/O tempQwv, $("root:Packages:IR2L_NLSQF:Qmodel_set"+num2str(i))				
					Wave ModelQ=	$("root:Packages:IR2L_NLSQF:Qmodel_set"+num2str(i))	
					//OK, Qmodel_setX is now Q set which has been hopefully corrently densified to provide enough Q points for sensible smearing. 
					//next is handling slit smearing. 
					//print "Original Q vector had : "+num2str(numpnts(OrigModelQ))+", oversampled Q vector now has : "+num2str(numpnts(ModelQ))
				else
					Duplicate/O OrigModelQ, $("root:Packages:IR2L_NLSQF:Qmodel_set"+num2str(i))						
					Wave ModelQ=	$("root:Packages:IR2L_NLSQF:Qmodel_set"+num2str(i))	
				endif
				
				if(isSlitSmeared)	//need to make sure the Qvector is long enough, if not, we will add more points to calculation
					//compare Qmax with slit length and see, what to do. 
					if(ModelQ[numpnts(ModelQ)-1]<2*SlitLength)
						//OK, Q vector too short...
						OldNumPnts=numpnts(ModelQ)
						QdistanceNeeded= 2*SlitLength - ModelQ[numpnts(ModelQ)-1]
						LastQstep = ModelQ[numpnts(ModelQ)-1] - ModelQ[numpnts(ModelQ)-2]
						NumNewQPoints= floor(QdistanceNeeded/LastQstep)
						if(NumNewQPoints>(OldNumPnts/5))
							NumNewQPoints = ceil(OldNumPnts/5)
						endif
						if(NumNewQPoints>100)
							NumNewQPoints = 100
						endif
						ExtensionQstep = QdistanceNeeded/NumNewQPoints
						Redimension/N=(OldNumPnts+NumNewQPoints) ModelQ
						For(ij=OldNumPnts;ij<(OldNumPnts+NumNewQPoints);ij+=1)
							ModelQ[ij] = ModelQ[OldNumPnts-1]+ExtensionQstep*(ij-OldNumPnts+1)
						endfor
						//OK, now the ModelQ should be at least 2* slit length longer with some logic... 
					 endif
				 endif

			else	//OK, this is not smeared at all, so just copy and keep as is... 
					//now both of these Q vectors are the same. 
				Duplicate/O OrigModelQ, $("root:Packages:IR2L_NLSQF:Qmodel_set"+num2str(i))			
			endif
		
		endif
	endfor	
	
end

//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************

// content from IR2L_NLSQFCalc.ipf

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IR2L_CalculateIntensity(skipCreateDistWvs, fitting) //Calculate distribution waves and distributions for all used population populations and all data sets...
	variable skipCreateDistWvs, fitting  	//set to 1 if skip changing the Radius/Diameter waves.. Use when using "semiAuto"
	//set fitting = 1 to skip some of the stuff to speed up fitting
	//find which pops and data sets are used
	variable pop, dataSet, i, j 
	//here we calculate intensity for all used populations and used datasets
	IR2L_PrepareSetsQvectors()		//this will handle all needed changes to Q vector to manage smearing...
	//now we have Q vector which is used to calculate 
	for(i=1;i<11;i+=1)
		NVAR Use=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(i))
		SVAR FormFactor=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(i))
		SVAR Model=$("root:Packages:IR2L_NLSQF:Model_pop"+num2str(i))
		if(Use)
			if(stringMatch(Model,"Size dist."))	//old code
				//first create waves for Distributions
				wave/Z Radius=$("root:Packages:IR2L_NLSQF:Radius_Pop"+num2str(i))
				wave/Z Diameter=$("root:Packages:IR2L_NLSQF:Diameter_Pop"+num2str(i))
				wave/Z NumDist=$("root:Packages:IR2L_NLSQF:NumberDist_Pop"+num2str(i))
				wave/Z VolumeDist=$("root:Packages:IR2L_NLSQF:VolumeDist_Pop"+num2str(i))
				if(!skipCreateDistWvs || WaveExists(Radius)  || WaveExists(Diameter) ||  WaveExists(NumDist) || WaveExists(VolumeDist))
					IR2L_CreateDistributionWaves(i)
				endif
				//next we calculate the distributions (Guass, Log-Normal or LSW)
				wave NumDist=$("root:Packages:IR2L_NLSQF:NumberDist_Pop"+num2str(i))
				wave VolumeDist=$("root:Packages:IR2L_NLSQF:VolumeDist_Pop"+num2str(i))
				wave Radius=$("root:Packages:IR2L_NLSQF:Radius_Pop"+num2str(i))
				wave Diameter=$("root:Packages:IR2L_NLSQF:Diameter_Pop"+num2str(i))
				NVAR DimensionIsDiameter = root:Packages:IR2L_NLSQF:SizeDist_DimensionIsDiameter
				if(DimensionIsDiameter) 				//all calculations above are done in radii, if we use Diameters, volume/number distributions needs to be half 
					IR2L_CalculateDistributions(i, Diameter, NumDist,VolumeDist)		
				else
					IR2L_CalculateDistributions(i, Radius, NumDist,VolumeDist)	
				endif		
				// Calculate intensity of the population...
				For(j=1;j<=10;j+=1)	//j is dataset
					IR2L_CalcIntPopXDataSetY(i,j)
				endfor
			elseif(stringMatch(Model,"Diffraction peak")) //diffraction peak
				//calculate diffraction peaks
				For(j=1;j<=10;j+=1)	//j is dataset
					IR2L_CalcDiffIntPopXDataSetY(i,j)
				endfor		
				wave/Z Radius=$("root:Packages:IR2L_NLSQF:Radius_Pop"+num2str(i))
				wave/Z NumDist=$("root:Packages:IR2L_NLSQF:NumberDist_Pop"+num2str(i))
				wave/Z VolumeDist=$("root:Packages:IR2L_NLSQF:VolumeDist_Pop"+num2str(i))
				if(!skipCreateDistWvs || WaveExists(Radius) || WaveExists(NumDist) || WaveExists(VolumeDist))
					IR2L_CreateDistributionWaves(i)
				endif
				//next we calculate the distributions (Guass, Log-Normal or LSW)
				wave NumDist=$("root:Packages:IR2L_NLSQF:NumberDist_Pop"+num2str(i))
				wave VolumeDist=$("root:Packages:IR2L_NLSQF:VolumeDist_Pop"+num2str(i))
				wave Radius=$("root:Packages:IR2L_NLSQF:Radius_Pop"+num2str(i))
				NumDist=0
				VolumeDist=0
				Radius=0
			elseif(stringMatch(Model,"Unified level"))	//unified level
				//calculate Unified model...				
				For(j=1;j<=10;j+=1)	//j is dataset
					IR2L_CalcUnifiedIntPopXDataSetY(i,j)
				endfor		
				wave/Z Radius=$("root:Packages:IR2L_NLSQF:Radius_Pop"+num2str(i))
				wave/Z NumDist=$("root:Packages:IR2L_NLSQF:NumberDist_Pop"+num2str(i))
				wave/Z VolumeDist=$("root:Packages:IR2L_NLSQF:VolumeDist_Pop"+num2str(i))
				if(!skipCreateDistWvs || WaveExists(Radius) || WaveExists(NumDist) || WaveExists(VolumeDist))
					IR2L_CreateDistributionWaves(i)
					//print "created dist waves"
				endif
				//next we calculate the distributions (Guass, Log-Normal or LSW)
				wave/Z NumDist=$("root:Packages:IR2L_NLSQF:NumberDist_Pop"+num2str(i))
				wave/Z VolumeDist=$("root:Packages:IR2L_NLSQF:VolumeDist_Pop"+num2str(i))
				wave/Z Radius=$("root:Packages:IR2L_NLSQF:Radius_Pop"+num2str(i))
				if(WaveExists(NumDist))
					NumDist=0
					VolumeDist=0
					Radius=0
				endif
			elseif(stringMatch(Model,"MassFractal"))	//unified level
				//calculate MassFractal				
				For(j=1;j<=10;j+=1)	//j is dataset
					IR2L_CalcMassFIntPopXDataSetY(i,j)
				endfor		
				wave/Z Radius=$("root:Packages:IR2L_NLSQF:Radius_Pop"+num2str(i))
				wave/Z NumDist=$("root:Packages:IR2L_NLSQF:NumberDist_Pop"+num2str(i))
				wave/Z VolumeDist=$("root:Packages:IR2L_NLSQF:VolumeDist_Pop"+num2str(i))
				if(!skipCreateDistWvs || WaveExists(Radius) || WaveExists(NumDist) || WaveExists(VolumeDist))
					IR2L_CreateDistributionWaves(i)
					//print "created dist waves"
				endif
				//next we calculate the distributions (Guass, Log-Normal or LSW)
				wave NumDist=$("root:Packages:IR2L_NLSQF:NumberDist_Pop"+num2str(i))
				wave VolumeDist=$("root:Packages:IR2L_NLSQF:VolumeDist_Pop"+num2str(i))
				wave Radius=$("root:Packages:IR2L_NLSQF:Radius_Pop"+num2str(i))
				NumDist=0
				VolumeDist=0
				Radius=0
			elseif(stringMatch(Model,"SurfaceFractal"))	//unified level
				//calculate SurfaceFractal				
				For(j=1;j<=10;j+=1)	//j is dataset
					IR2L_CalcSurfFIntPopXDataSetY(i,j)
				endfor		
				wave/Z Radius=$("root:Packages:IR2L_NLSQF:Radius_Pop"+num2str(i))
				wave/Z NumDist=$("root:Packages:IR2L_NLSQF:NumberDist_Pop"+num2str(i))
				wave/Z VolumeDist=$("root:Packages:IR2L_NLSQF:VolumeDist_Pop"+num2str(i))
				if(!skipCreateDistWvs || WaveExists(Radius) || WaveExists(NumDist) || WaveExists(VolumeDist))
					IR2L_CreateDistributionWaves(i)
					//print "created dist waves"
				endif
				//next we calculate the distributions (Guass, Log-Normal or LSW)
				wave NumDist=$("root:Packages:IR2L_NLSQF:NumberDist_Pop"+num2str(i))
				wave VolumeDist=$("root:Packages:IR2L_NLSQF:VolumeDist_Pop"+num2str(i))
				wave Radius=$("root:Packages:IR2L_NLSQF:Radius_Pop"+num2str(i))
				NumDist=0
				VolumeDist=0
				Radius=0
			endif
		endif
	endfor
	if(!fitting)
		//	//lets update the mode median and mean
		IR2L_UpdateModeMedianMean()		
		//	//now lets calculate the whole distribution together
		IR2L_CalcSumOfDistribution()
	endif
		//summ the model intensities
	IR2L_SummModel()		
		//fix smearing issues, fi needed...
	IR2L_FinishSmearingOfData()
	if(!fitting)
		//create residuals
		IR2L_CreateResidulas()
		//append to graph...
		IR2L_AppendModelToGraph()
		//NOw fix legend...
		IR2L_FormatLegend()
		// create the other graphs
		IR2L_CreateOtherGraphs()
	endif	
//	SetAxis /W=LSQF_MainGraph /A

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_CalcMassFIntPopXDataSetY(pop,dataSet)
	variable pop,dataSet
	
//Calculate Intensity for pop X into data set Y

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	NVAR UseTheData=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(DataSet))
	NVAR UseThePop=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(pop))
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	variable LocalContrast
	variable UseDatasw=1
	if(!UseTheData || (!MultipleInputData && DataSet>1))
		UseDatasw=0
	endif
	if(UseThePop && UseDatasw)
		Wave/Z ModelQ = $("Qmodel_set"+num2str(DataSet))
		if (!WaveExists (ModelQ))
			Abort "Select original data first"
		endif
		Duplicate/O ModelQ, $("IntensityModel_set"+num2str(DataSet)+"_pop"+num2str(pop))
		Wave ModelInt=$("IntensityModel_set"+num2str(DataSet)+"_pop"+num2str(pop))
		ModelInt=0

		//find the form factor parameters and name:
		NVAR Contrast=$("root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(pop))
		NVAR SameContrastForDataSets=root:Packages:IR2L_NLSQF:SameContrastForDataSets
		NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
		NVAR Contrast_set=$("root:Packages:IR2L_NLSQF:Contrast_set"+num2str(DataSet)+"_pop"+num2str(pop))
		if(!SameContrastForDataSets || !MultipleInputData)		//weird stuff - if 1 it means that there are different contrasts for each data set... 
			LocalContrast=Contrast
		else
			LocalContrast=Contrast_set
		endif

		NVAR Phi=$("root:Packages:IR2L_NLSQF:MassFrPhi_pop"+num2str(pop))
		NVAR Radius=$("root:Packages:IR2L_NLSQF:MassFrRadius_pop"+num2str(pop))
		NVAR Dv=$("root:Packages:IR2L_NLSQF:MassFrDv_pop"+num2str(pop))
		NVAR Ksi=$("root:Packages:IR2L_NLSQF:MassFrKsi_pop"+num2str(pop))
		NVAR BetaVar=$("root:Packages:IR2L_NLSQF:MassFrBeta_pop"+num2str(pop))
		NVAR Eta=$("root:Packages:IR2L_NLSQF:MassFrEta_pop"+num2str(pop))
		NVAR UseUFFormFactor=$("root:Packages:IR2L_NLSQF:MassFrUseUFFF_pop"+num2str(pop))
		NVAR PDI= $("root:Packages:IR2L_NLSQF:MassFrPDI_pop"+num2str(pop)) 
		
		variable CHiS=IR1V_CaculateChiS(BetaVar)
		variable RC=Radius*sqrt(2)/ChiS * sqrt(1+((2+BetaVar^2)/3)*ChiS^2)
		//and now calculations
		//	tempFractFitIntensity = Phi * Contrast* 1e20								//this is phi * deltaRhoSquared
		//	tempFractFitIntensity *= IR1V_SpheroidVolume(Radius,Beta)* 1e-24		//volume of particle
		variable Bracket
		Bracket = ( Eta * RC^3 / (BetaVar * Radius^3)) * ((Ksi/RC)^Dv )
		if(UseUFFormFactor)								//use Unified fit Form factor for sphere...
			ModelInt = Phi * LocalContrast* 1e-4 * IR1V_SpheroidVolume(Radius,1) * (Bracket * sin((Dv-1)*atan(ModelQ*Ksi)) / ((Dv-1)*ModelQ*Ksi*(1+(ModelQ*Ksi)^2)^((Dv-1)/2)) + (1-Eta)^2 )* IR1V_UnifiedSphereFFSquared(Radius,ModelQ, PDI)
		else
			if(BetaVar!=1)
				ModelInt = Phi * LocalContrast* 1e-4 * IR1V_SpheroidVolume(Radius,BetaVar) * (Bracket * sin((Dv-1)*atan(ModelQ*Ksi)) / ((Dv-1)*ModelQ*Ksi*(1+(ModelQ*Ksi)^2)^((Dv-1)/2)) + (1-Eta)^2 )* IR2L_CalculateFSquared(pop,ModelQ)
			else
				ModelInt = Phi * LocalContrast* 1e-4 * IR1V_SpheroidVolume(Radius,BetaVar) * (Bracket * sin((Dv-1)*atan(ModelQ*Ksi)) / ((Dv-1)*ModelQ*Ksi*(1+(ModelQ*Ksi)^2)^((Dv-1)/2)) + (1-Eta)^2 )* IR2L_CalculateFSquared(pop,ModelQ)
			endif
		endif
		//	tempFractFitIntensity*=1e-48									//this is conversion for Volume of particles from A to cm	
	endif
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2L_CalculateFSquared(which,Qval)
	variable which,Qval

	NVAR Phi=$("root:Packages:IR2L_NLSQF:MassFrPhi_pop"+num2str(which))
	NVAR Radius=$("root:Packages:IR2L_NLSQF:MassFrRadius_pop"+num2str(which))
	NVAR Dv=$("root:Packages:IR2L_NLSQF:MassFrDv_pop"+num2str(which))
	NVAR Ksi=$("root:Packages:IR2L_NLSQF:MassFrKsi_pop"+num2str(which))
	NVAR BetaVar=$("root:Packages:IR2L_NLSQF:MassFrBeta_pop"+num2str(which))
	NVAR Eta=$("root:Packages:IR2L_NLSQF:MassFrEta_pop"+num2str(which))
	NVAR IntgNumPnts=$("root:Packages:IR2L_NLSQF:MassFrIntgNumPnts_pop"+num2str(which))
	
	 variable result 
	 variable TempBessArg
	//now we need the integral
	Make/Free/D/N=(IntgNumPnts) FractF2IntgWave
	SetScale/I x 0,1,"", FractF2IntgWave
	FractF2IntgWave = Besselj(3/2,Qval*Radius*sqrt(1+(BetaVar^2 - 1)*x^2))/(Qval*Radius*sqrt(1+(BetaVar^2 - 1)*x^2))^(3/2)
	//fix end points, if they are wrong:
	if (numtype(FractF2IntgWave[0])!=0)
		FractF2IntgWave[0]=FractF2IntgWave[1]
	endif
	if (numtype(FractF2IntgWave[IntgNumPnts-1])!=0)
		FractF2IntgWave[IntgNumPnts-1]=FractF2IntgWave[IntgNumPnts-2]
	endif
	
	result =  9*pi/2 * (area(FractF2IntgWave, 0, 1 ))^2
	return result 
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2L_CalcSurfFIntPopXDataSetY(pop,dataSet)
	variable pop,dataSet
//Calculate Intensity for pop X into data set Y

	
//Calculate Intensity for pop X into data set Y

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	NVAR UseTheData=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(DataSet))
	NVAR UseThePop=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(pop))
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	variable LocalContrast
	variable UseDatasw=1
	if(!UseTheData || (!MultipleInputData && DataSet>1))
		UseDatasw=0
	endif
	if(UseThePop && UseDatasw)
//	//and now we need to calculate the model Intensity
		//find the form factor parameters and name:
		NVAR Contrast=$("root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(pop))
		NVAR SameContrastForDataSets=root:Packages:IR2L_NLSQF:SameContrastForDataSets
		NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
		NVAR Contrast_set=$("root:Packages:IR2L_NLSQF:Contrast_set"+num2str(DataSet)+"_pop"+num2str(pop))
		if(!SameContrastForDataSets || !MultipleInputData)		//weird stuff - if 1 it means that there are different contrasts for each data set... 
			LocalContrast=Contrast
		else
			LocalContrast=Contrast_set
		endif

//		NVAR QMin=$("root:Packages:IR2L_NLSQF:Qmin_set"+num2str(DataSet))
//		NVAR QMax=$("root:Packages:IR2L_NLSQF:Qmax_set"+num2str(DataSet))
//		Wave/Z Qwave=$("root:Packages:IR2L_NLSQF:Q_set"+num2str(DataSet))
//		if (!WaveExists (Qwave))
//			Abort "Select original data first"
//		endif
//		variable StartPoint, EndPoint
//		StartPoint = BinarySearch(Qwave, QMin)
//		EndPoint = BinarySearch(Qwave, QMax)
//		if(StartPoint<0)
//			StartPoint=0
//		endif
//		if(EndPoint<0)
//			EndPoint = numpnts(Qwave)-1
//		endif
//		Duplicate/O/R=[StartPoint,EndPoint] Qwave, $("Qmodel_set"+num2str(DataSet))
//		Wave ModelQ = $("Qmodel_set"+num2str(DataSet))
		Wave/Z ModelQ = $("Qmodel_set"+num2str(DataSet))
		if (!WaveExists (ModelQ))
			Abort "Select original data first"
		endif
		Duplicate/O ModelQ, $("IntensityModel_set"+num2str(DataSet)+"_pop"+num2str(pop))
		Wave ModelInt=$("IntensityModel_set"+num2str(DataSet)+"_pop"+num2str(pop))
		ModelInt=0

		//find the form factor parameters and name:
		NVAR Contrast=$("root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(pop))
		NVAR SameContrastForDataSets=root:Packages:IR2L_NLSQF:SameContrastForDataSets
		NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
		NVAR Contrast_set=$("root:Packages:IR2L_NLSQF:Contrast_set"+num2str(DataSet)+"_pop"+num2str(pop))
		if(!SameContrastForDataSets || !MultipleInputData)		//weird stuff - if 1 it means that there are different contrasts for each data set... 
			LocalContrast=Contrast
		else
			LocalContrast=Contrast_set
		endif

		NVAR Surface=$("root:Packages:IR2L_NLSQF:SurfFrSurf_pop"+num2str(pop))
		NVAR DS=$("root:Packages:IR2L_NLSQF:SurfFrDS_pop"+num2str(pop))
		NVAR Ksi=$("root:Packages:IR2L_NLSQF:SurfFrKsi_pop"+num2str(pop))
		NVAR Qc=$("root:Packages:IR2L_NLSQF:SurfFrQc_pop"+num2str(pop))
		NVAR QcW=$("root:Packages:IR2L_NLSQF:SurfFrQcWidth_pop"+num2str(pop))


		//	ListOfVariables+="SurfFrSurf;SurfFrKsi;SurfFrDS;"
		//	ListOfVariables+="SurfFrQc;SurfFrQcWidth;"

		ModelInt = pi *LocalContrast* 1e20 * Ksi^4 *1e-32* Surface * exp(gammln(5-DS))	
		ModelInt *= sin((3-DS)* atan(ModelQ*Ksi))/((1+(ModelQ*Ksi)^2)^((5-DS)/2) * ModelQ*Ksi)
		if(Qc>0&& Qc<ModelQ[numpnts(ModelQ)-1])
			//h(Q) = C(xc - x)f(Q) + C(x - xc)g(Q).
			//The transition from one behavior to another is determined by C.  
			//For an infinitely sharp transition, C would be a Heaviside step function.  
			//Our choice for C is a smoothed step function:
			//C(x) = 0.5 * (1 + erfc(x/W)).
			//C(x) = 0.5 * (1 + ERF( (Qc-Q) /SQRT(2*((Qw/2.3548)^2) ) )
			duplicate/Free ModelInt, StepFunction1, StepFunction2, TempFractInt2
			StepFunction1 = 0.5 * (1 + erf((Qc - ModelQ)/SQRT(2*((Qc*QcW/2.3548)^2) ) ))
			StepFunction2 = 0.5 * (1 + erf((ModelQ - Qc)/SQRT(2*((Qc*QcW/2.3548)^2) ) ))
			//So, the total model, which transitions from f(Q) to Porod law behavior AQ^-4 is:
			//h(Q) = C(xc - x)f(Q) + C(x -xc)AQ^-4.
			//The value for A is not a free parameter. It is fixed by a continuity condition:
			//f(Qc) = g(Qc), or A = Qc^4 * f(Qc).
			//Intensity = ASF * 0.5 * (1 + ERF( (Qc-Q) /SQRT(2*((Qw/2.3548)^2) ) )    +
			//+ (  Pf * Q^-4 * 0.5 * (1 + ERF( (Q-Qc) /SQRT(2*((Qw/2.3548)^2) ) ) 
			variable PorodSurface=Qc^4 * ModelInt[BinarySearchInterp(ModelQ, Qc )]
			TempFractInt2 = ModelInt * StepFunction1 + PorodSurface * ModelQ^-4 * StepFunction2
			ModelInt = TempFractInt2
		endif
	endif
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_CalcDiffIntPopXDataSetY(pop,dataSet)
	variable pop,dataSet

//Calculate Intensity for pop X into data set Y

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	NVAR UseTheData=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(DataSet))
	NVAR UseThePop=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(pop))
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	variable LocalContrast
	variable UseDatasw=1
	if(!UseTheData || (!MultipleInputData && DataSet>1))
		UseDatasw=0
	endif
	if(UseThePop && UseDatasw)
//	//and now we need to calculate the model Intensity
//		NVAR QMin=$("root:Packages:IR2L_NLSQF:Qmin_set"+num2str(DataSet))
//		NVAR QMax=$("root:Packages:IR2L_NLSQF:Qmax_set"+num2str(DataSet))
//		Wave/Z Qwave=$("root:Packages:IR2L_NLSQF:Q_set"+num2str(DataSet))
//		if (!WaveExists (Qwave))
//			Abort "Select original data first"
//		endif
//		variable StartPoint, EndPoint
//		StartPoint = BinarySearch(Qwave, QMin)
//		EndPoint = BinarySearch(Qwave, QMax)
//		if(StartPoint<0)
//			StartPoint=0
//		endif
//		if(EndPoint<0)
//			EndPoint = numpnts(Qwave)-1
//		endif
//		Duplicate/O/R=[StartPoint,EndPoint] Qwave, $("Qmodel_set"+num2str(DataSet))
		Wave/Z ModelQ = $("Qmodel_set"+num2str(DataSet))
		if (!WaveExists (ModelQ))
			Abort "Select original data first"
		endif
		Duplicate/O ModelQ, $("IntensityModel_set"+num2str(DataSet)+"_pop"+num2str(pop))
		Wave ModelInt=$("IntensityModel_set"+num2str(DataSet)+"_pop"+num2str(pop))
		ModelInt=0
		Duplicate/FREE ModelInt, tempInt

		//find the form factor parameters and name:
		SVAR DiffPeakProfile=$("root:Packages:IR2L_NLSQF:DiffPeakProfile_pop"+num2str(pop))	
		NVAR Par1=$("root:Packages:IR2L_NLSQF:DiffPeakPar1_pop"+num2str(pop))		
		NVAR Par2=$("root:Packages:IR2L_NLSQF:DiffPeakPar2_pop"+num2str(pop))		
		NVAR Par3=$("root:Packages:IR2L_NLSQF:DiffPeakPar3_pop"+num2str(pop))		
		NVAR Par4=$("root:Packages:IR2L_NLSQF:DiffPeakPar4_pop"+num2str(pop))		
		NVAR Par5=$("root:Packages:IR2L_NLSQF:DiffPeakPar5_pop"+num2str(pop))		
		NVAR Contrast=$("root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(pop))
		NVAR SameContrastForDataSets=root:Packages:IR2L_NLSQF:SameContrastForDataSets
		NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
		NVAR Contrast_set=$("root:Packages:IR2L_NLSQF:Contrast_set"+num2str(DataSet)+"_pop"+num2str(pop))
		if(!SameContrastForDataSets || !MultipleInputData)		//weird stuff - if 1 it means that there are different contrasts for each data set... 
			LocalContrast=Contrast
		else
			LocalContrast=Contrast_set
		endif

		if(stringmatch(DiffPeakProfile, "Gauss" ))
//			tempInt =Par1*exp(-((qwv-Par2)^2/Par3))
			tempInt = IR2D_Gauss(ModelQ,Par1,Par2,Par3) 
			//Par1 * IR1_GaussProbability(qwv,Par2,Par3, 0)
		endif
		if(stringmatch(DiffPeakProfile, "Lorenz" ))
			tempInt = IR2D_Lorenz(ModelQ,Par1,Par2,Par3)
			//tempInt =(1/pi) *  Par1 * Par3/((qwv-Par2)^2+Par3^2) 	//from formula 10 at
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
		if(stringmatch(DiffPeakProfile, "LorenzSquared" ))
			tempInt = IR2D_Lorenz2(ModelQ,Par1,Par2,Par3)
			//tempInt =(1/pi) *  Par1 * Par3/((qwv-Par2)^2+Par3^2) 	//from formula 10 at
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif

		if(stringmatch(DiffPeakProfile, "Pseudo-Voigt" ))
			tempInt = Par4*(IR2D_Lorenz(ModelQ,Par1,Par2,Par3)) + (1-Par4) *IR2D_Gauss(ModelQ,Par1,Par2,Par3)
			//tempInt =(1/pi) *  Par1 * Par3/((qwv-Par2)^2+Par3^2) 	//from formula 10 at
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
		if(stringmatch(DiffPeakProfile, "Gumbel" ))
			tempInt = IR2D_Gumbel(ModelQ,Par1,Par2,Par3,Par4)
			//NIST handbook on statistics
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
		if(stringmatch(DiffPeakProfile, "Pearson_VII" ))
			tempInt = IR2D_PearsonVII(ModelQ,Par1,Par2,Par3,Par4)
			//NIST handbook on statistics
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
		if(stringmatch(DiffPeakProfile, "Modif_Gauss" ))
			tempInt = IR2D_ModifGauss(ModelQ,Par1,Par2,Par3,Par4)
			//NIST handbook on statistics
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
		if(stringmatch(DiffPeakProfile, "LogNormal" ))
			tempInt = IR2D_LogNormal(ModelQ,Par1,Par2,Par3)
			//NIST handbook on statistics
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
		if(stringmatch(DiffPeakProfile, "Percus-Yevick-Sq" ))
			tempInt = IR2D_PercusYevickSqNIST(ModelQ,Par1,Par2,Par3)
			//IR2D_PercusYevick(Q,Par1,Diameter,Fraction)
		endif
		if(stringmatch(DiffPeakProfile, "Percus-Yevick-SqFq" ))
			tempInt = IR2D_PercusYevickSqFqNIST(ModelQ,Par1,Par2,Par3)
			//IR2D_PercusYevick(Q,Par1,Diameter,Fraction)
		endif
		if(stringmatch(DiffPeakProfile, "SkewedNormal" ))
			tempInt = IR2D_SkewedNormal(ModelQ,Par1,Par2,Par3,Par4)
			//IR2D_PercusYevick(Q,Par1,Diameter,Fraction)
		endif

			NVAR PeakQPosition=$("DiffPeakQPos_pop"+num2str(pop))
			NVAR DiffPeakDPos=$("DiffPeakDPos_pop"+num2str(pop))
			NVAR PeakFWHM=$("DiffPeakQFWHM_pop"+num2str(pop))
			NVAR PeakIntgInt=$("DiffPeakIntgInt_pop"+num2str(pop))

			PeakIntgInt = areaXY(ModelQ, tempInt )
			SetScale/P x, 0, 1 , tempInt
			wavestats/Q tempInt
			PeakQPosition = ModelQ[V_maxloc]
			DiffPeakDPos = 2*pi/PeakQPosition
			FindLevels/Q/N=2  tempInt, V_max/2 
			if(V_flag==0)
				Wave W_FindLevels
				PeakFWHM = abs(ModelQ[W_FindLevels[1]] - ModelQ[W_FindLevels[0]])
			else
				PeakFWHM=nan
			endif

		ModelInt=LocalContrast*tempInt
	endif

	KillWaves/Z tempInt
	setDataFolder OldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_CalcUnifiedIntPopXDataSetY(pop,dataSet)
	variable pop,dataSet

//Calculate Intensity for pop X into data set Y

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	NVAR UseTheData=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(DataSet))
	NVAR UseThePop=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(pop))
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	variable LocalContrast
	variable UseDatasw=1
	if(!UseTheData || (!MultipleInputData && DataSet>1))
		UseDatasw=0
	endif
	if(UseThePop && UseDatasw)
//	//and now we need to calculate the model Intensity
//		NVAR QMin=$("root:Packages:IR2L_NLSQF:Qmin_set"+num2str(DataSet))
//		NVAR QMax=$("root:Packages:IR2L_NLSQF:Qmax_set"+num2str(DataSet))
//		Wave/Z Qwave=$("root:Packages:IR2L_NLSQF:Q_set"+num2str(DataSet))
//		if (!WaveExists (Qwave))
//			Abort "Select original data first"
//		endif
//		variable StartPoint, EndPoint
//		StartPoint = BinarySearch(Qwave, QMin)
//		EndPoint = BinarySearch(Qwave, QMax)
//		if(StartPoint<0)
//			StartPoint=0
//		endif
//		if(EndPoint<0)
//			EndPoint = numpnts(Qwave)-1
//		endif
//		Duplicate/O/R=[StartPoint,EndPoint] Qwave, $("Qmodel_set"+num2str(DataSet))
//		Wave ModelQ = $("Qmodel_set"+num2str(DataSet))
		Wave/Z ModelQ = $("Qmodel_set"+num2str(DataSet))
		if (!WaveExists (ModelQ))
			Abort "Select original data first"
		endif

		Duplicate/O ModelQ, $("IntensityModel_set"+num2str(DataSet)+"_pop"+num2str(pop))
		Wave ModelInt=$("IntensityModel_set"+num2str(DataSet)+"_pop"+num2str(pop))
		ModelInt=0

		//find the form factor parameters and name:
		SVAR FormFactor=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(pop))	
		SVAR FFUserFFformula=$("root:Packages:IR2L_NLSQF:FFUserFFformula_pop"+num2str(pop))	
		SVAR FFUserVolumeFormula=$("root:Packages:IR2L_NLSQF:FFUserVolumeFormula_pop"+num2str(pop))	
		NVAR FF_Param1=$("root:Packages:IR2L_NLSQF:FormFactor_Param1_pop"+num2str(pop))		
		NVAR FF_Param2=$("root:Packages:IR2L_NLSQF:FormFactor_Param2_pop"+num2str(pop))		
		NVAR FF_Param3=$("root:Packages:IR2L_NLSQF:FormFactor_Param3_pop"+num2str(pop))		
		NVAR FF_Param4=$("root:Packages:IR2L_NLSQF:FormFactor_Param4_pop"+num2str(pop))		
		NVAR FF_Param5=$("root:Packages:IR2L_NLSQF:FormFactor_Param5_pop"+num2str(pop))		
		NVAR FF_Param6=$("root:Packages:IR2L_NLSQF:FormFactor_Param6_pop"+num2str(pop))		
		NVAR Contrast=$("root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(pop))
		NVAR SameContrastForDataSets=root:Packages:IR2L_NLSQF:SameContrastForDataSets
		NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
		NVAR Contrast_set=$("root:Packages:IR2L_NLSQF:Contrast_set"+num2str(DataSet)+"_pop"+num2str(pop))
		if(!SameContrastForDataSets || !MultipleInputData)		//weird stuff - if 1 it means that there are different contrasts for each data set... 
			LocalContrast=Contrast
		else
			LocalContrast=Contrast_set
		endif

		NVAR G=$("root:Packages:IR2L_NLSQF:UF_G_pop"+num2str(pop))
		NVAR Rg=$("root:Packages:IR2L_NLSQF:UF_Rg_pop"+num2str(pop))
		NVAR B=$("root:Packages:IR2L_NLSQF:UF_B_pop"+num2str(pop))
		NVAR P=$("root:Packages:IR2L_NLSQF:UF_P_pop"+num2str(pop))
		NVAR RGCO=$("root:Packages:IR2L_NLSQF:UF_RGCO_pop"+num2str(pop))
		NVAR Kval=$("root:Packages:IR2L_NLSQF:UF_K_pop"+num2str(pop))
		NVAR/Z LinkB=$("root:Packages:IR2L_NLSQF:UF_LinkB_pop"+num2str(pop))
		variable LLinkB=0
		if(NVAR_Exists(LinkB))
			LLinkB=LinkB
		endif
		//now the distribution waves...
		//calculate Unified fit....
		if(LLinkB)
			B = G * exp(-1*P/2)*(3*P/2)^(P/2)*(1/Rg^P) 
		endif
		//2.36 - 8-23-2021 
		//if P is more than 3 then k=1 and if P is less than 3 k = 1.06  
		Kval = (P>3) ? 1 : 1.06
		//done... 
		
		Duplicate /O ModelQ, QstarVector
		QstarVector=ModelQ/(erf(Kval*ModelQ*Rg/sqrt(6)))^3
		ModelInt=LocalContrast*G*exp(-ModelQ^2*Rg^2/3)+(LocalContrast*B/QstarVector^P) * exp(-RGCO^2 * ModelQ^2/3)
	
		//Interference, if needed
			NVAR Phi = $("root:Packages:IR2L_NLSQF:StructureParam2_pop"+num2str(pop))
			NVAR Eta = $("root:Packages:IR2L_NLSQF:StructureParam1_pop"+num2str(pop))
			NVAR WellDepthPert = $("root:Packages:IR2L_NLSQF:StructureParam3_pop"+num2str(pop))
			NVAR WellWidthStick = $("root:Packages:IR2L_NLSQF:StructureParam4_pop"+num2str(pop))
			NVAR Par5 = $("root:Packages:IR2L_NLSQF:StructureParam5_pop"+num2str(pop))
			NVAR Par6 = $("root:Packages:IR2L_NLSQF:StructureParam6_pop"+num2str(pop))
			SVAR StrFac=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(pop))
			SVAR SFUserSFformula = $("root:Packages:IR2L_NLSQF:SFUserSQFormula_pop"+num2str(pop))
			ModelInt *=  IR2S_CalcStructureFactor(StrFac,ModelQ,Eta,Phi,WellDepthPert,WellWidthStick,Par5,Par6,UserStrFacFormula=SFUserSFformula)		//this returns 1 in case of dilute system
		endif
//	endif


//	endif
//
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2L_CalcSumOfDistribution() //Sums the existing populations and creates distribution to plot...

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	
	variable i, tempLength=0
	Make/O/N=0/D DistRadia, DistDiameters
	
	For(i=1;i<11;i+=1)
		NVAR UseThePop=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(i))
		SVAR FormFactor=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(i))
		SVAR Model=$("root:Packages:IR2L_NLSQF:Model_pop"+num2str(i))
		Wave/Z NumDist=$("root:Packages:IR2L_NLSQF:NumberDist_Pop"+num2str(i))
		Wave/Z RDist=$("root:Packages:IR2L_NLSQF:Radius_Pop"+num2str(i))
		Wave/Z VolDist=$("root:Packages:IR2L_NLSQF:VolumeDist_Pop"+num2str(i))
		if(UseThePop&&!(stringMatch(Model,"Unified level")||stringMatch(Model,"Diffraction peak")))
			tempLength=numpnts(DistRadia)
			redimension /N=(tempLength+numpnts(RDist)) DistRadia
		//	DistRadia[tempLength,numpnts(RDist)-1]=RDist[p-tempLength]
			DistRadia[tempLength,inf]=RDist[p-tempLength]
		endif
	endfor

	Sort DistRadia, DistRadia
	//check if some of the point are the same, that causes trobles later. remove the points
	variable imax=numpnts(DistRadia)
	For(i=imax;i>0;i-=1)
		if(DistRadia(i)==DistRadia(i-1))
			DeletePoints i,1, DistRadia
		endif
	endfor

	Duplicate/O DistRadia, DistDiameters
	DistDiameters = 2 * DistRadia

	Duplicate/O DistRadia, TempVolDist, TempNumDist, TotalVolumeDist, TotalNumberDist
	Redimension/D TempVolDist, TempNumDist, TotalVolumeDist, TotalNumberDist	
	TotalVolumeDist=0
	TotalNumberDist=0
	
	For(i=1;i<11;i+=1)	
		NVAR UseThePop=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(i))
		SVAR FormFactor=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(i))
		SVAR Model=$("root:Packages:IR2L_NLSQF:Model_pop"+num2str(i))
		if(UseThePop&&!(stringMatch(Model,"Unified level")||stringMatch(Model,"Diffraction peak")))
			NVAR DimensionIsDiameter = root:Packages:IR2L_NLSQF:SizeDist_DimensionIsDiameter
			if(DimensionIsDiameter) 				//all calculations above are done in radii, if we use Diameters, volume/number distributions needs to be half 
				IR2L_CalculateDistributions(i, DistDiameters, TempNumDist,TempVolDist)		
			else
				IR2L_CalculateDistributions(i, DistRadia, TempNumDist,TempVolDist)		
			endif		
			TotalVolumeDist+=TempVolDist
			TotalNumberDist+=TempNumDist
		endif
	endfor
	KillWaves/Z TempVolDist, TempNumDist	
	setDataFolder OldDf	
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_GraphSizeDistributions() : Graph

	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:IR2L_NLSQF:
	NVAR DisplaySizeDistPlot=root:Packages:IR2L_NLSQF:DisplaySizeDistPlot
	variable SizeDistExisted
	SizeDistExisted = 0

	DoWindow GraphSizeDistributions
	SizeDistExisted=V_Flag
	if(DisplaySizeDistPlot)
		if(V_Flag)
			DoWindow/F GraphSizeDistributions
		else
			Display/K=1 /W=(312.75,392.75,857.25,607.25)  as "Size distributions"
			DoWindow/C GraphSizeDistributions
			//Add command bar
			ControlBar /T/W=GraphSizeDistributions 40
			Checkbox SizeDistLogX, pos={5,3}, size={20,25}, variable= root:Packages:IR2L_NLSQF:SizeDistLogX, help={"X axis (Radius) -log scale?"}, title="Log X axis? ", proc=IR2L_SizeDistGraphChkbxProc, win=GraphSizeDistributions

			SetVariable Rg, limits={0,inf,0}, NoProc, noedit=1, win=GraphSizeDistributions
			SetVariable Rg, pos={5,23}, size={120,25}, variable= root:Packages:IR2L_NLSQF:Rg_pop1, help={"Rg of current population"}, title="Pop 1 Rg = "

			Checkbox SizeDistDisplayVolDist, pos={140,3}, size={50,25}, variable= root:Packages:IR2L_NLSQF:SizeDistDisplayVolDist, help={"Disp Volume Dist?"}, title="Display Vol Dist? ", proc=IR2L_SizeDistGraphChkbxProc, win=GraphSizeDistributions
			Checkbox SizeDistDisplayNumDist, pos={140,23}, size={50,25}, variable= root:Packages:IR2L_NLSQF:SizeDistDisplayNumDist, help={"Disp Number Dist ?"}, title="Display Num Dist? ", proc=IR2L_SizeDistGraphChkbxProc, win=GraphSizeDistributions
			Checkbox SizeDistLogVolDist, pos={220,3}, size={50,25}, variable= root:Packages:IR2L_NLSQF:SizeDistLogVolDist, help={"Volume distribution axis log scale?"}, title="Log Vol Dist? ", proc=IR2L_SizeDistGraphChkbxProc, win=GraphSizeDistributions
			Checkbox SizeDistLogNumDist, pos={220,23}, size={50,25}, variable= root:Packages:IR2L_NLSQF:SizeDistLogNumDist, help={"Number distribution axis log scale?"}, title="Log Num Dist? ", proc=IR2L_SizeDistGraphChkbxProc, win=GraphSizeDistributions
			SetVariable MeanVal, limits={0,inf,0}, NoProc, noedit=1, win=GraphSizeDistributions
			SetVariable MeanVal, pos={320,3}, size={180,25}, variable= root:Packages:IR2L_NLSQF:Mean_pop1, help={"Mean of current population"}, title="Pop 1 Mean = "
			SetVariable ModeVal, limits={0,inf,0}, NoProc, noedit=1, win=GraphSizeDistributions
			SetVariable ModeVal, pos={320,23}, size={180,25}, variable= root:Packages:IR2L_NLSQF:Mode_pop1, help={"Mode of current population"}, title="Pop 1 Mode = "
	
			SetVariable MedianVal, limits={0,inf,0}, NoProc, noedit=1, win=GraphSizeDistributions
			SetVariable MedianVal, pos={520,3}, size={180,25}, variable= root:Packages:IR2L_NLSQF:Median_pop1, help={"Median of current population"}, title="Pop 1 Median = "
			SetVariable FWHMVal, limits={0,inf,0}, NoProc, noedit=1, win=GraphSizeDistributions
			SetVariable FWHMVal, pos={520,23}, size={180,25}, variable= root:Packages:IR2L_NLSQF:FWHM_pop1, help={"FWHM of current population"}, title="Pop 1 FWHM = "
		endif
	else
		if(V_Flag)
			KillWIndow GraphSizeDistributions
		endif
		return 0
	endif

	IR2L_GraphSizeDistUpdate()	
	
	IR2L_AppendWvsGraphSizeDist()
	
	IR2L_FormatGraphSizeDist()

	IR2M_ColorCurves()
	SetDataFolder fldrSav0	
	return SizeDistExisted
End

//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_GraphSizeDistUpdate()

	DoWindow GraphSizeDistributions
	if(V_Flag)
		ControlInfo/W=LSQF2_MainPanel DistTabs
		DoWindow/F GraphSizeDistributions
		variable curPopulation=V_Value+1
		SetVariable Rg, win=GraphSizeDistributions,  variable= root:Packages:IR2L_NLSQF:$("Rg_pop"+num2str(curPopulation)), title="Pop "+num2str(curPopulation)+" Rg = "
		SetVariable MeanVal, win=GraphSizeDistributions, variable=root:Packages:IR2L_NLSQF:$("Mean_pop"+num2str(curPopulation)), title="Pop "+num2str(curPopulation)+" Mean = "
		SetVariable ModeVal, win=GraphSizeDistributions,  variable= root:Packages:IR2L_NLSQF:$("Mode_pop"+num2str(curPopulation)), title="Pop "+num2str(curPopulation)+" Mode = "
		SetVariable MedianVal, win=GraphSizeDistributions,  variable= root:Packages:IR2L_NLSQF:$("Median_pop"+num2str(curPopulation)), title="Pop "+num2str(curPopulation)+" Median = "
		SetVariable FWHMVal, win=GraphSizeDistributions,  variable= root:Packages:IR2L_NLSQF:$("FWHM_pop"+num2str(curPopulation)), title="Pop "+num2str(curPopulation)+" FWHM = "
	else
		return 1
	endif


end 
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2L_SizeDistGraphChkbxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

//	ListOfVariables+="SizeDistLogX;SizeDistDisplayNumDist;SizeDistDisplayVolDist;"
//	ListOfVariables+="SizeDistLogVolDist;SizeDistLogNumDist;"
	NVAR SizeDistDisplayNumDist = root:Packages:IR2L_NLSQF:SizeDistDisplayNumDist
	NVAR SizeDistDisplayVolDist = root:Packages:IR2L_NLSQF:SizeDistDisplayVolDist
	if(stringmatch(ctrlName,"SizeDistDisplayVolDist"))
		if(SizeDistDisplayVolDist==0)
			SizeDistDisplayNumDist=1
		endif
	endif
	if(stringmatch(ctrlName,"SizeDistDisplayNumDist"))
		if(SizeDistDisplayNumDist==0)
			SizeDistDisplayVolDist=1
		endif
	endif
	IR2L_AppendWvsGraphSizeDist()
	IR2L_FormatGraphSizeDist()
	IR2M_ColorCurves()
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2L_AppendWvsGraphSizeDist()

	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:IR2L_NLSQF:
	NVAR SizeDistLogX = root:Packages:IR2L_NLSQF:SizeDistLogX
	NVAR SizeDistDisplayNumDist = root:Packages:IR2L_NLSQF:SizeDistDisplayNumDist
	NVAR SizeDistDisplayVolDist = root:Packages:IR2L_NLSQF:SizeDistDisplayVolDist
	NVAR SizeDistLogVolDist = root:Packages:IR2L_NLSQF:SizeDistLogVolDist
	NVAR SizeDistLogNumDist = root:Packages:IR2L_NLSQF:SizeDistLogNumDist
	SVAR SizeDist_DimensionType=root:Packages:IR2L_NLSQF:SizeDist_DimensionType
	
	NVAR DimensionIsDiameter = root:Packages:IR2L_NLSQF:SizeDist_DimensionIsDiameter
	
	variable i

	Wave/Z DistRadii=root:Packages:IR2L_NLSQF:DistRadia
	Wave/Z DistDiameters = root:Packages:IR2L_NLSQF:DistDiameters
	Wave/Z TotalNumberDist=root:Packages:IR2L_NLSQF:TotalNumberDist
	Wave/Z TotalVolumeDist=root:Packages:IR2L_NLSQF:TotalVolumeDist	
	if(!WaveExists(DistRadii)||!(WaveExists(DistDiameters)))
		return 0		//data do not exist... 
	endif
	DoWIndow GraphSizeDistributions
	if(V_FLag)
		RemoveFromGraph/Z/W=GraphSizeDistributions TotalNumberDist
		RemoveFromGraph/Z/W=GraphSizeDistributions TotalVolumeDist
		if(SizeDistDisplayNumDist)
			if(DimensionIsDiameter)
				AppendToGraph /R/W=GraphSizeDistributions TotalNumberDist vs DistDiameters
			else
				AppendToGraph /R/W=GraphSizeDistributions TotalNumberDist vs DistRadii
			endif
		endif
		if(SizeDistDisplayVolDist)
			if(DimensionIsDiameter)
				AppendToGraph /W=GraphSizeDistributions TotalVolumeDist vs DistDiameters
			else
				AppendToGraph /W=GraphSizeDistributions TotalVolumeDist vs DistRadii
			endif
		endif
	endif
		
	For(i=1;i<11;i+=1)
		NVAR UseThePop=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(i))
		Wave/Z NumDist=$("root:Packages:IR2L_NLSQF:NumberDist_Pop"+num2str(i))
		Wave/Z RDist=$("root:Packages:IR2L_NLSQF:Radius_Pop"+num2str(i))
		Wave/Z DDist=$("root:Packages:IR2L_NLSQF:Diameter_Pop"+num2str(i))
		Wave/Z VolDist=$("root:Packages:IR2L_NLSQF:VolumeDist_Pop"+num2str(i))
		DOWindow GraphSizeDistributions
		if(V_Flag)
			RemoveFromGraph/Z /W=GraphSizeDistributions $("VolumeDist_Pop"+num2str(i))
			RemoveFromGraph/Z /W=GraphSizeDistributions $("NumberDist_Pop"+num2str(i))
			if(SizeDistDisplayNumDist && UseThePop)
				if(DimensionIsDiameter)
					AppendToGraph/R/W=GraphSizeDistributions NumDist vs DDist
				else
					AppendToGraph/R/W=GraphSizeDistributions NumDist vs RDist
				endif
			endif

			if(SizeDistDisplayVolDist && UseThePop)
				if(DimensionIsDiameter)
					AppendToGraph/W=GraphSizeDistributions VolDist vs DDist
				else
					AppendToGraph/W=GraphSizeDistributions VolDist vs RDist
				endif
				
			endif
		endif
	endfor

	DOWindow GraphSizeDistributions
	if(V_Flag)
		Label/Z /W=GraphSizeDistributions bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+SizeDist_DimensionType+" [A]"
		if(SizeDistDisplayNumDist)
			Label /Z/W=GraphSizeDistributions right "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Number distribution [1/(A*cm\\S3\\M)]"
		endif
		if(!SizeDistDisplayNumDist)
			ModifyGraph /Z/W=GraphSizeDistributions mirror(left)=1
		endif
		if(SizeDistDisplayVolDist)
			if(DimensionIsDiameter)
				Label/Z /W=GraphSizeDistributions left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Volume distribution f(D) [1/A]"
			else
				Label/Z /W=GraphSizeDistributions left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Volume distribution f(R) [1/A]"
			endif
		endif	
		if(!SizeDistDisplayVolDist)
			ModifyGraph/Z /W=GraphSizeDistributions mirror(right)=1
	endif
	endif
	SetDataFolder fldrSav0	
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2L_FormatGraphSizeDist()

	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:IR2L_NLSQF:

//	ListOfVariables+="SizeDistLogX;SizeDistDisplayNumDist;SizeDistDisplayVolDist;"
//	ListOfVariables+="SizeDistLogVolDist;SizeDistLogNumDist;"
	NVAR SizeDistLogX = root:Packages:IR2L_NLSQF:SizeDistLogX
	NVAR SizeDistDisplayNumDist = root:Packages:IR2L_NLSQF:SizeDistDisplayNumDist
	NVAR SizeDistDisplayVolDist = root:Packages:IR2L_NLSQF:SizeDistDisplayVolDist
	NVAR SizeDistLogVolDist = root:Packages:IR2L_NLSQF:SizeDistLogVolDist
	NVAR SizeDistLogNumDist = root:Packages:IR2L_NLSQF:SizeDistLogNumDist
	if(SizeDistLogX)
			ModifyGraph/Z /W=GraphSizeDistributions log(bottom)=1
	else
			ModifyGraph/Z /W=GraphSizeDistributions log(bottom)=0
	endif
	if(SizeDistLogVolDist && SizeDistDisplayVolDist)
		ModifyGraph/Z /W=GraphSizeDistributions log(left)=1
	elseif(!SizeDistLogVolDist && SizeDistDisplayVolDist)
		ModifyGraph/Z /W=GraphSizeDistributions log(left)=0
	endif
	if(SizeDistLogNumDist && SizeDistDisplayNumDist)
		ModifyGraph/Z /W=GraphSizeDistributions log(right)=1
	elseif(!SizeDistLogNumDist && SizeDistDisplayNumDist)
		ModifyGraph/Z /W=GraphSizeDistributions log(right)=0
	endif
	ModifyGraph/Z /W=GraphSizeDistributions mirror(bottom)=1
///	ModifyGraph /W=GraphSizeDistributions lblMargin(left)=3,lblMargin(right)=15

	Legend/C/N=text0/S=3/A=RT
	setAxis/A

	SetDataFolder fldrSav0	
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_CalcIntPopXDataSetY(pop,dataSet)
	variable pop,dataSet

//Calculate Intensity for pop X into data set Y

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	NVAR UseTheData=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(DataSet))
	NVAR UseThePop=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(pop))
	NVAR UseNumberDistributions=root:Packages:IR2L_NLSQF:UseNumberDistributions
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	variable LocalContrast
	variable UseDatasw=1
	if(!UseTheData || (!MultipleInputData && DataSet>1))
		UseDatasw=0
	endif
	if(UseThePop && UseDatasw)
//	//and now we need to calculate the model Intensity
//	here we need to get the G matrix for each population and DataSet separately... 	
// 	then calculate 
//	IR1_CalculateModelIntensity()		<<< old example...
//		NVAR QMin=$("root:Packages:IR2L_NLSQF:Qmin_set"+num2str(DataSet))
//		NVAR QMax=$("root:Packages:IR2L_NLSQF:Qmax_set"+num2str(DataSet))
//		Wave/Z Qwave=$("root:Packages:IR2L_NLSQF:Q_set"+num2str(DataSet))
//		if (!WaveExists (Qwave))
//			Abort "Select original data first"
//		endif
//		variable StartPoint, EndPoint
//		StartPoint = BinarySearch(Qwave, QMin)
//		EndPoint = BinarySearch(Qwave, QMax)
//		if(StartPoint<0)
//			StartPoint=0
//		endif
//		if(EndPoint<0)
//			EndPoint = numpnts(Qwave)-1
//		endif
//		Duplicate/O/R=[StartPoint,EndPoint] Qwave, $("Qmodel_set"+num2str(DataSet))
		Wave/Z ModelQ = $("Qmodel_set"+num2str(DataSet))
		if (!WaveExists (ModelQ))
			Abort "Select original data first"
		endif
		Duplicate/O ModelQ, $("IntensityModel_set"+num2str(DataSet)+"_pop"+num2str(pop))
		Wave ModelInt=$("IntensityModel_set"+num2str(DataSet)+"_pop"+num2str(pop))
		ModelInt=0

		//find the form factor parameters and name:
		SVAR FormFactor=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(pop))	
		SVAR FFUserFFformula=$("root:Packages:IR2L_NLSQF:FFUserFFformula_pop"+num2str(pop))	
		SVAR FFUserVolumeFormula=$("root:Packages:IR2L_NLSQF:FFUserVolumeFormula_pop"+num2str(pop))	
		NVAR FF_Param1=$("root:Packages:IR2L_NLSQF:FormFactor_Param1_pop"+num2str(pop))		
		NVAR FF_Param2=$("root:Packages:IR2L_NLSQF:FormFactor_Param2_pop"+num2str(pop))		
		NVAR FF_Param3=$("root:Packages:IR2L_NLSQF:FormFactor_Param3_pop"+num2str(pop))		
		NVAR FF_Param4=$("root:Packages:IR2L_NLSQF:FormFactor_Param4_pop"+num2str(pop))		
		NVAR FF_Param5=$("root:Packages:IR2L_NLSQF:FormFactor_Param5_pop"+num2str(pop))		
		NVAR FF_Param6=$("root:Packages:IR2L_NLSQF:FormFactor_Param6_pop"+num2str(pop))		
		NVAR Contrast=$("root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(pop))
		NVAR SameContrastForDataSets=root:Packages:IR2L_NLSQF:SameContrastForDataSets
		NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
		NVAR Contrast_set=$("root:Packages:IR2L_NLSQF:Contrast_set"+num2str(DataSet)+"_pop"+num2str(pop))
		if(!SameContrastForDataSets || !MultipleInputData)		//weird stuff - if 1 it means that there are different contrasts for each data set... 
			LocalContrast=Contrast
		else
			LocalContrast=Contrast_set
		endif
		//now the distribution waves...
		Wave Radius=$("root:Packages:IR2L_NLSQF:Radius_Pop"+num2str(pop))
		Wave NumDist=$("root:Packages:IR2L_NLSQF:NumberDist_Pop"+num2str(pop))
		Wave VolDist= $("root:Packages:IR2L_NLSQF:VolumeDist_Pop"+num2str(pop))
		//now lets look for the existing Gmatrix_setX_popY
		Wave/Z Gmatrix=$("root:Packages:IR2L_NLSQF:Gmatrix_set"+num2str(DataSet)+"_pop"+num2str(pop))
		variable M=numpnts(ModelQ)
		variable N=numpnts(Radius)
		if(!WaveExists(Gmatrix))
			Make/D/O/N=(M,N) $("Gmatrix_set"+num2str(DataSet)+"_pop"+num2str(pop))
			Wave Gmatrix=$("root:Packages:IR2L_NLSQF:Gmatrix_set"+num2str(DataSet)+"_pop"+num2str(pop))
		endif	
		//calculate G matrix...
		
		if(UseNumberDistributions)
			IR1T_GenerateGMatrix(Gmatrix, ModelQ,Radius,2,FormFactor,FF_Param1,FF_Param2,FF_Param3,FF_Param4,FF_Param5,FFUserFFformula,FFUserVolumeFormula, ParticlePar6=FF_Param6)
		else
			IR1T_GenerateGMatrix(Gmatrix, ModelQ,Radius,1,FormFactor,FF_Param1,FF_Param2,FF_Param3,FF_Param4,FF_Param5,FFUserFFformula,FFUserVolumeFormula, ParticlePar6=FF_Param6)
		endif
		//Duplicate/O G_matrixFF, $("G_matrix_"+num2str(DistNum))				//G_matrixFF (root:Packages:Sizes:G_matrixFF)  contains form factor without contrast, except for Tube and Core shell...  
		//Wave G_matrix=$("G_matrix_"+num2str(DistNum))
		//here need to use copy of the G matrix, so we do not include contrast in it...
		if(cmpstr(FormFactor,"CoreShell")==0 || cmpstr(FormFactor,"CoreShellCylinder")==0 || cmpstr(FormFactor,"CoreShellShell")==0|| stringmatch(FormFactor,"Janus CoreShell Micelle*"))
			MatrixOP/O GmatrixTemp = Gmatrix * 1e20			//this shape contains contrast already in...
		else
			MatrixOP/O GmatrixTemp = Gmatrix * LocalContrast*1e20		//this multiplies by scattering contrast
		endif

		if(UseNumberDistributions)
			duplicate/O NumDist, TepNumbDist
			TepNumbDist=NumDist[p]* IR1_BinWidthInDiameters(Radius,p)
			MatrixOp/O ModelInt =GmatrixTemp x TepNumbDist 
		else
			duplicate/O VolDist, TepVolumeDist
			TepVolumeDist=VolDist[p]* IR1_BinWidthInDiameters(Radius,p)
			MatrixOp/O ModelInt =GmatrixTemp x TepVolumeDist 
			Killwaves/Z GmatrixTemp
		endif

		//special cases, we need to update some parameters here...
		if(stringmatch(FormFactor,"CoreShellPrecipitate"))
			wavestats/Q Radius
			FF_Param1 = IR1T_FixCoreShellPrecipitate(V_avg,0,FF_Param2,FF_Param3,FF_Param4,2)
		endif
		
		NVAR Phi = $("root:Packages:IR2L_NLSQF:StructureParam2_pop"+num2str(pop))
		NVAR Eta = $("root:Packages:IR2L_NLSQF:StructureParam1_pop"+num2str(pop))
		NVAR WellDepthPert = $("root:Packages:IR2L_NLSQF:StructureParam3_pop"+num2str(pop))
		NVAR WellWidthStick = $("root:Packages:IR2L_NLSQF:StructureParam4_pop"+num2str(pop))
		NVAR Par5 = $("root:Packages:IR2L_NLSQF:StructureParam5_pop"+num2str(pop))
		NVAR Par6 = $("root:Packages:IR2L_NLSQF:StructureParam6_pop"+num2str(pop))
		//OK, new method... 
		SVAR StrFac=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(pop))
		SVAR SFUserSFformula = $("root:Packages:IR2L_NLSQF:SFUserSQFormula_pop"+num2str(pop))
		ModelInt *=  IR2S_CalcStructureFactor(StrFac,ModelQ,Eta,Phi,WellDepthPert,WellWidthStick,Par5,Par6, UserStrFacFormula=SFUserSFformula)		//this returns 1 in case of dilute system
	endif

	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR1_StartOfBinInDiameters(D_distribution,i)			//calculates the start of the bin in radii by taking half distance to point before and after
	variable i								//returns number in A
	Wave D_distribution
	
	variable start
	variable Imax=numpnts(D_Distribution)
	
	if (i==0)
		start=D_Distribution[0]-(D_Distribution[1]-D_Distribution[0])/2
		if (start<0)
			start=1		//we will enforce minimum size of the scatterer as 1 A
		endif
	elseif (i==Imax-1)
		start=D_Distribution[i]-(D_Distribution[i]-D_Distribution[i-1])/2
	else
		start=D_Distribution[i]-((D_Distribution[i]-D_Distribution[i-1])/2)
	endif
	return start
end


//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR1_BinWidthInDiameters(D_distribution,i)			//calculates the width in diameters by taking half distance to point before and after
	variable i								//returns number in A
	Wave D_distribution
	
	variable width
	variable Imax=numpnts(D_distribution)
	
	if (i==0)
		width=D_distribution[1]-D_distribution[0]
		if ((D_distribution[0]-(D_distribution[1]-D_distribution[0])/2)<0)
			width=D_distribution[0]+(D_distribution[1]-D_distribution[0])/2
		endif
	elseif (i==Imax-1)
		width=D_distribution[i]-D_distribution[i-1]
	else
		width=((D_distribution[i]-D_distribution[i-1])/2)+((D_distribution[i+1]-D_distribution[i])/2)
	endif
	return abs(width)		//9/17/2010, fix for user models when bins are sorted from large to small
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_EndOfBinInDiameters(D_distribution,i)			//calculates the start of the bin in radii by taking half distance to point before and after
	variable i								//returns number in A
	Wave D_distribution
	
	variable endL
	variable Imax=numpnts(D_distribution)
	
	if (i==0)
		endL=D_distribution[0]+(D_distribution[1]-D_distribution[0])/2
	elseif (i==Imax-1)
		endL=D_distribution[i]+((D_distribution[i]-D_distribution[i-1])/2)//fix 2011-9-25
	else
		endL=D_distribution[i]+((D_distribution[i+1]-D_distribution[i])/2)
	endif
	return endL
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_SummModel()

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	variable i, j
	//i is 1 - 6 populations
	//j is 1 - 10 data sets
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	variable UseDatasw=1
	
	For(j=1;j<11;j+=1)
		NVAR UseTheData=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(j))
		NVAR Background=$("root:Packages:IR2L_NLSQF:Background_set"+num2str(j))
		UseDatasw=1
		if(!UseTheData || (!MultipleInputData && j>1))
			UseDatasw=0
		endif
		if(UseDatasw)
			Wave/Z ModelQ = $("Qmodel_set"+num2str(j))
			if(!WaveExists(ModelQ))
				return 1
			endif
			Duplicate/O ModelQ, $("IntensityModel_set"+num2str(j))
			Wave ModelIntSumm=$("IntensityModel_set"+num2str(j))
			Wave Intensity=$("Intensity_set"+num2str(j))
			Wave Error=$("Error_set"+num2str(j))
			ModelIntSumm=0
			For(i=1;i<=10;i+=1)
				NVAR UseThePop=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(i))
				if(UseThePop)
					Wave ModelInt=$("IntensityModel_set"+num2str(j)+"_pop"+num2str(i))
					ModelIntSumm+=ModelInt
				endif
			endfor
			ModelIntSumm+=Background			//add background... Only once for each data set...
		endif
		
	endfor


	setDataFolder OldDf	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_SlitSmearLSQFData(IntWave,Qwave,SlitLength)
	wave IntWave,Qwave
	variable SlitLength
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	Duplicate/Free IntWave, SmearedIntWave
	IR1B_SmearData(IntWave,Qwave, slitLength, SmearedIntWave)
	IntWave=SmearedIntWave
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_AppendModelToGraph()

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	variable i, j
	//i is 1 - 6 populations
	//j is 1 - 10 data sets
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	variable UseDatasw=1
	
	For(j=1;j<11;j+=1)
		NVAR UseTheData=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(j))
		UseDatasw=1
		if(!UseTheData || (!MultipleInputData && j>1))
			UseDatasw=0
		endif
		Wave/Z ModelQ = $("Qmodel_set"+num2str(j))
		Wave/Z ModelIntSumm=$("IntensityModel_set"+num2str(j))
		DoWIndow LSQF_MainGraph
		if(!V_Flag)
			return  0 //no widnow open, do not bomb on user...
		endif
		CheckDisplayed/W=LSQF_MainGraph $("IntensityModel_set"+num2str(j))
		if(UseDatasw && V_Flag)
			//use the data and displayed, nothing to do
		elseif(UseDatasw && !V_Flag)
			//use the data and NOT displayed, append
			if(WaveExists(ModelIntSumm) && WaveExists(ModelQ))
				AppendToGraph/W=LSQF_MainGraph ModelIntSumm vs ModelQ
			endif
		elseif(!UseDataSw)
			//do nto use these data
			RemoveFromGraph/Z/W=LSQF_MainGraph $("IntensityModel_set"+num2str(j))
		endif
	endfor

	IR2L_FormatInputGraph()
	setDataFolder OldDf	
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_CreateOtherGraphs()
		//	//create graphs, if needed...
		variable SizeDistExisted, ResidualsExisted, IQ4Existed
		SizeDistExisted = IR2L_GraphSizeDistributions()		

		//create graph and data for residual plot.
		ResidualsExisted = IR2L_GraphResiduals()
		
		//create graph and data for IQ4 vs Q plot.
		IQ4Existed = IR2L_GraphIQ4vsQ()
			
		//recolor as needed
		IR2L_SyncClrsAndSymbInGraphs()
		
		//and now we need to align them for user...
//		variable GraphSDExists, GraphResExists,GraphIQ4Exists
//		DoWIndow GraphSizeDistributions
//		GraphSDExists=V_Flag
//		if(V_Flag && !SizeDistExisted)
//			AutoPositionWindow/M=1 /R=LSQF_MainGraph GraphSizeDistributions
//		endif
//		
//		Dowindow LSQF_ResidualsGraph
//		GraphResExists=V_Flag
//		if(V_Flag && !ResidualsExisted)
//			if(GraphSDExists&& !SizeDistExisted)
//				AutoPositionWindow/M=1 /R=GraphSizeDistributions LSQF_ResidualsGraph
//			else
//				AutoPositionWindow/M=1 /R=LSQF_MainGraph LSQF_ResidualsGraph
//			endif
//		endif
//		
//		Dowindow LSQF_IQ4vsQGraph
//		GraphIQ4Exists=V_Flag
//		if(V_Flag && !IQ4Existed)
//				AutoPositionWindow/M=1 LSQF_IQ4vsQGraph
////			if(GraphResExists)
////				AutoPositionWindow/M=1 /R=LSQF_ResidualsGraph LSQF_IQ4vsQGraph
////			elseif(GraphSDExists)
////				AutoPositionWindow/M=1 /R=GraphSizeDistributions LSQF_IQ4vsQGraph
////			else
////				AutoPositionWindow/M=1 /R=LSQF_MainGraph LSQF_IQ4vsQGraph
////			endif
//		endif		
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_SyncClrsAndSymbInGraphs()
	//syncs colors in graphs as much as possible

    String tnl = TraceNameList( "LSQF_MainGraph", ";", 1 )
    String info, tnlIQ4, tnlRes, tempName, tempNameIQ4, cmd, tempNameRes
    variable  k = ItemsInList(tnl)
    variable i, kIQ4, kRes
	DoWindow LSQF_MainGraph
	if(!V_Flag)		//no main graph, bail out
		return 0
	endif
	DoWIndow 	LSQF_IQ4vsQGraph
	if(V_Flag)
		tnlIQ4 = TraceNameList( "LSQF_IQ4vsQGraph", ";", 1 )
		kIQ4 = ItemsInList(tnlIQ4)
	endif
	DoWIndow 	LSQF_ResidualsGraph
	if(V_Flag)
		tnlRes = TraceNameList( "LSQF_ResidualsGraph", ";", 1 )
		kRes = ItemsInList(tnlRes)
	endif

      tnl = TraceNameList( "LSQF_MainGraph", ";", 1 )
      k = ItemsInList(tnl)
	
    if (k <= 1)
        return -1
    endif
    For(i=0;i<k;i+=1)
	    	tempName =  StringFromList(i, tnl , ";")
		info=TraceInfo("LSQF_MainGraph",tempName,0)
		if(StringMatch(tempName, "Intensity_set*" ))
			if(kIQ4>0)
				tempNameIQ4 = ReplaceString("Intensity_set" , tempName, "IntensityQ4_set")
				if(StringMatch(tnlIQ4, "*"+tempNameIQ4+";*" ))
					cmd = "ModifyGraph/W=LSQF_IQ4vsQGraph /Z rgb("+tempNameIQ4+")="+StringByKey("rgb(x)", info , "="  , ";")
					Execute(cmd)
					cmd = "ModifyGraph/W=LSQF_IQ4vsQGraph /Z marker("+tempNameIQ4+")="+StringByKey("marker(x)", info , "="  , ";")
					Execute(cmd)
				endif
			endif
			if(kRes>0)
				tempNameRes = ReplaceString("Intensity_set" , tempName, "Residuals_set")
				if(StringMatch(tnlRes, "*"+tempNameRes+";*" ))
					cmd = "ModifyGraph/W=LSQF_ResidualsGraph /Z rgb("+tempNameRes+")="+StringByKey("rgb(x)", info , "="  , ";")
					Execute(cmd)
					cmd = "ModifyGraph/W=LSQF_ResidualsGraph /Z marker("+tempNameRes+")="+StringByKey("marker(x)", info , "="  , ";")
					Execute(cmd)
				endif
			endif
		elseif(StringMatch(tempName, "IntensityModel_set*" ))
			if(kIQ4>0)
				tempNameIQ4 = ReplaceString("IntensityModel_set" , tempName, "IQ4Model_set")
				if(StringMatch(tnlIQ4, "*"+tempNameIQ4+";*" ))
					cmd = "ModifyGraph/W=LSQF_IQ4vsQGraph /Z rgb("+tempNameIQ4+")="+StringByKey("rgb(x)", info , "="  , ";")
					Execute(cmd)
					cmd = "ModifyGraph/W=LSQF_IQ4vsQGraph /Z marker("+tempNameIQ4+")="+StringByKey("marker(x)", info , "="  , ";")
					Execute(cmd)
				endif
			endif
	 	endif
    endfor
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_GraphIQ4vsQ()

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	variable i, j, IQ4Existed
	//i is 1 - 6 populations
	//j is 1 - 10 data sets
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	NVAR DisplayIQ4vsQplot=root:Packages:IR2L_NLSQF:DisplayIQ4vsQplot
	variable UseDatasw=1
	variable ModelExists=0
	IQ4Existed = 0

	if(!DisplayIQ4vsQplot)	
		//kill the plot and ignore the data
		DoWindow LSQF_IQ4vsQGraph
		if(V_Flag)
			KillWindow LSQF_IQ4vsQGraph
		endif
	else
		//need to create the data and plot them... 
		DoWindow LSQF_IQ4vsQGraph
		if(V_Flag)
			DoWindow/F LSQF_IQ4vsQGraph
			IQ4Existed = 1
		else
			Display /K=1/W=(313.5,424,858,624) as "LSQF2 IQ^4 vs Q graph"
			Dowindow/C LSQF_IQ4vsQGraph
		endif
	
		For(j=1;j<11;j+=1)
			NVAR UseTheData=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(j))
			UseDatasw=1
			if(!UseTheData || (!MultipleInputData && j>1))
				UseDatasw=0
			else	//create data
				Wave/Z DataQ = $("Q_set"+num2str(j))
				Wave/Z DataI=$("Intensity_set"+num2str(j))
				if(WaveExists(DataI) && WaveExists(DataQ))
					Duplicate/O DataI, $("IntensityQ4_set"+num2str(j))
					Wave/Z DataIQ4=$("IntensityQ4_set"+num2str(j))
					DataIQ4 = DataI * DataQ^4
				else
					Abort "Data are missing, report bug"
				endif
				Wave/Z ModelQ = $("Qmodel_set"+num2str(j))
				Wave/Z ModelI=$("IntensityModel_set"+num2str(j))
				if(WaveExists(ModelI) && WaveExists(ModelQ))
					ModelExists= 1
					Duplicate/O ModelI, $("IQ4Model_set"+num2str(j))
					Wave/Z ModelIQ4=$("IQ4Model_set"+num2str(j))
					ModelIQ4 = ModelI * ModelQ^4
				else
					ModelExists=0
				endif
			endif
			DoWIndow LSQF_IQ4vsQGraph
			if(!V_Flag)
				return  0 //no widnow open, do not bomb on user...
			endif
			//append data if needed
			CheckDisplayed/W=LSQF_IQ4vsQGraph $("IntensityQ4_set"+num2str(j))
			if(UseDatasw && V_Flag)
				//use the data and displayed, nothing to do
			elseif(UseDatasw && !V_Flag)
				//use the data and NOT displayed, append
				if(WaveExists(DataIQ4) && WaveExists(DataQ))
					AppendToGraph/W=LSQF_IQ4vsQGraph DataIQ4 vs DataQ
					ModifyGraph mode($("IntensityQ4_set"+num2str(j)))=3
					ModifyGraph zmrkSize($("IntensityQ4_set"+num2str(j)))={$("root:Packages:IR2L_NLSQF:IntensityMask_set"+num2str(j)),0,5,0.5,3}
					ModifyGraph marker($("IntensityQ4_set"+num2str(j)))=19
				endif
			elseif(!UseDataSw)
				//do not use these data
				RemoveFromGraph/Z/W=LSQF_IQ4vsQGraph $("IntensityQ4_set"+num2str(j))
			endif
			//append model if needed
			CheckDisplayed/W=LSQF_IQ4vsQGraph $("IQ4Model_set"+num2str(j))
			if(UseDatasw && V_Flag)
				//use the data and displayed, nothing to do
			elseif(UseDatasw && !V_Flag && ModelExists)
				//use the data and NOT displayed, append
				if(WaveExists(ModelIQ4) && WaveExists(ModelQ))
					AppendToGraph/W=LSQF_IQ4vsQGraph ModelIQ4 vs ModelQ
					ModifyGraph mode($("IQ4Model_set"+num2str(j)))=0
					ModifyGraph rgb($("IQ4Model_set"+num2str(j)))=(30583,30583,30583)
					ModifyGraph lsize($("IQ4Model_set"+num2str(j)))=2
				endif
			elseif(!UseDataSw)
				//do not use these data
				RemoveFromGraph/Z/W=LSQF_IQ4vsQGraph $("IQ4Model_set"+num2str(j))
			endif
		endfor
		GetAxis /W=LSQF_IQ4vsQGraph /Q bottom
		if(!V_Flag)
			//ModifyGraph/Z/W=LSQF_IQ4vsQGraph mode=3,marker=19,rgb=(0,0,0)
			ModifyGraph/Z/W=LSQF_IQ4vsQGraph log(bottom)=1
			ModifyGraph/Z/W=LSQF_IQ4vsQGraph grid=1,mirror=1
			Label/Z/W=LSQF_IQ4vsQGraph left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity * Q^4"
			Label/Z/W=LSQF_IQ4vsQGraph bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M]"
			ModifyGraph log=1
		endif
	endif
	setDataFolder OldDf	
	return IQ4Existed
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_GraphResiduals()

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	variable i, j, ResidualsExisted
	//i is 1 - 6 populations
	//j is 1 - 10 data sets
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	NVAR DisplayResidualsPlot=root:Packages:IR2L_NLSQF:DisplayResidualsPlot
	variable UseDatasw=1
	ResidualsExisted = 0

	if(!DisplayResidualsPlot)
		DoWindow LSQF_ResidualsGraph
		if(V_Flag)
			KillWIndow LSQF_ResidualsGraph
		endif
		return 0
	endif


	DoWindow LSQF_ResidualsGraph
	if(V_Flag)
		DoWindow/F LSQF_ResidualsGraph
		ResidualsExisted = 1
	else
		Display /K=1/W=(313.5,304,858,504) as "LSQF2 residuals"
		Dowindow/C LSQF_ResidualsGraph
	endif

	For(j=1;j<11;j+=1)
		NVAR UseTheData=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(j))
		UseDatasw=1
		if(!UseTheData || (!MultipleInputData && j>1))
			UseDatasw=0
		endif
		//Wave/Z ModelQ = $("Qmodel_set"+num2str(j))
		Wave/Z ModelQ = $("Q_set"+num2str(j))
		Wave/Z Residuals=$("Residuals_set"+num2str(j))
		DoWIndow LSQF_ResidualsGraph
		if(!V_Flag)
			return  0 //no widnow open, do not bomb on user...
		endif
		CheckDisplayed/W=LSQF_ResidualsGraph $("Residuals_set"+num2str(j))
		if(UseDatasw && V_Flag)
			//use the data and displayed, nothing to do
		elseif(UseDatasw && !V_Flag)
			//use the data and NOT displayed, append
			if(WaveExists(Residuals) && WaveExists(ModelQ))
				AppendToGraph/W=LSQF_ResidualsGraph Residuals vs ModelQ
			endif
		elseif(!UseDataSw)
			//do not use these data
			RemoveFromGraph/Z/W=LSQF_ResidualsGraph $("Residuals_set"+num2str(j))
		endif
	endfor
	GetAxis /W=LSQF_ResidualsGraph /Q bottom
	if(!V_Flag)
		ModifyGraph/Z/W=LSQF_ResidualsGraph mode=3,marker=19,rgb=(0,0,0)
		ModifyGraph/Z/W=LSQF_ResidualsGraph log(bottom)=1
		ModifyGraph/Z/W=LSQF_ResidualsGraph grid=1,mirror=1
		Label/Z/W=LSQF_ResidualsGraph left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Normalized residual\r(Data - Model / Error)"
		Label/Z/W=LSQF_ResidualsGraph bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M]"
	endif
	setDataFolder OldDf	
	return ResidualsExisted
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//Calculate the distribution waves - depending on user selections

Function IR2L_CalculateDistributions(pop,Radius,NumDist,VolumeDist) //calculates both volume and number distributions and scales by volume
	variable pop
	wave Radius,NumDist,VolumeDist

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	NVAR UseNumberDistributions=root:Packages:IR2L_NLSQF:UseNumberDistributions
	
	SVAR DistShape=$("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(pop))
	NVAR Volume=$("root:Packages:IR2L_NLSQF:Volume_Pop"+num2str(pop))
	//IR1_GaussProbability(x,location,scale, shape)
	NVAR LNMinSize=$("root:Packages:IR2L_NLSQF:LNMinSize_pop"+num2str(pop))
	NVAR LNMeanSize=$("root:Packages:IR2L_NLSQF:LNMeanSize_pop"+num2str(pop))
	NVAR LNSDeviation=$("root:Packages:IR2L_NLSQF:LNSdeviation_pop"+num2str(pop))
	NVAR GMeanSize=$("root:Packages:IR2L_NLSQF:GMeanSize_pop"+num2str(pop))
	NVAR GWidth=$("root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(pop))
	NVAR SZMeanSize=$("root:Packages:IR2L_NLSQF:SZMeanSize_pop"+num2str(pop))
	NVAR SZWidth=$("root:Packages:IR2L_NLSQF:SZWidth_pop"+num2str(pop))
	NVAR LSWLocation=$("root:Packages:IR2L_NLSQF:LSWLocation_pop"+num2str(pop))
	NVAR ArdLocation=$("root:Packages:IR2L_NLSQF:ArdLocation_pop"+num2str(pop))
	NVAR ArdParameter=$("root:Packages:IR2L_NLSQF:ArdParameter_pop"+num2str(pop))
	Duplicate/Free VolumeDist, tempDist, TempVolDistL
	Redimension/D tempDist, TempVolDistL
	if(stringmatch(DistShape,"LogNormal"))
		tempDist = IR1_LogNormProbability(Radius[p],LNMinSize,LNMeanSize, LNSDeviation)
	elseif(stringmatch(DistShape,"Gauss"))
		tempDist = IR1_GaussProbability(Radius[p],GMeanSize,GWidth, 0)
	elseif(stringmatch(DistShape,"Schulz-Zimm"))
		tempDist = IR1_SchulzZimmProbability(Radius[p],SZMeanSize,SZWidth, 0)
	elseif(stringmatch(DistShape,"Ardell"))
		multithread tempDist = IR1_ArdellProbNormalized(Radius[p],ArdLocation,ArdParameter, 0)
	else
		tempDist = IR1_LSWProbability(Radius[p],LSWLocation,0, 0)
	endif
	NVAR DimensionIsDiameter = root:Packages:IR2L_NLSQF:SizeDist_DimensionIsDiameter
	if(DimensionIsDiameter) 				//all calculations above are done in radii, if we use Diameters, volume/number distributions needs to be half 
		Duplicate/Free Radius, tmpRadius
		tmpRadius = Radius/2
		IR2L_CalculateAveVolWave(TempVolDistL,tmpRadius,pop)
	else
		IR2L_CalculateAveVolWave(TempVolDistL,Radius,pop)
	endif		
	//calibrate - set volumes... 
	//This is for  number distributions
			//this is to calculate the number distribution, so the volume is right
			//the way we do this: integrate P(r)*V(r), get Ntotal as Vol/the integral calculated... 
			//and next multiply the number distribution by the total number of scatterers Ntotaql
//			Duplicate/O TempNumDist, temp_Calc_Wv
//			temp_Calc_Wv=TempNumDist*AveVolumeWave
//			variable Nt=DistVolFraction/areaXY(Distdiameters,temp_Calc_Wv,-inf,inf)	
//			TempNumDist*=Nt
	
	variable ScaleVol	
	if(UseNumberDistributions)
		NumDist=tempDist
		VolumeDist = TempVolDistL * NumDist
	else
		VolumeDist = tempDist
  		NumDist = VolumeDist /TempVolDistL	
	endif

	NVAR DimensionIsDiameter = root:Packages:IR2L_NLSQF:SizeDist_DimensionIsDiameter
	if(DimensionIsDiameter) 				//all calculations above are done in radii, if we use Diameters, volume/number distributions needs to be half 
		Duplicate/Free Radius, tmpRadius
		tmpRadius = Radius/2
		ScaleVol = Volume/areaXY(tmpRadius,VolumeDist,-inf,inf)
		VolumeDist = VolumeDist * ScaleVol
		NumDist = NumDist * ScaleVol
	else
		ScaleVol = Volume/areaXY(Radius,VolumeDist,-inf,inf)
		VolumeDist = VolumeDist * ScaleVol
		NumDist = NumDist * ScaleVol
	endif		

//	ScaleVol = Volume/areaXY(Radius,VolumeDist,-inf,inf)
//	VolumeDist = VolumeDist * ScaleVol
//	NumDist = NumDist * ScaleVol
	//KillWaves/Z TempVolDistL, tempDist
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_CalculateAveVolWave(ResultsWave,Radius,pop) //calculates average volume wave for each bin
	variable pop
	wave ResultsWave, Radius

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	NVAR UseNumberDistributions=root:Packages:IR2L_NLSQF:UseNumberDistributions
	
	SVAR FormFactor=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(pop))
	//IR1_GaussProbability(x,location,scale, shape)
	NVAR Param1=$("root:Packages:IR2L_NLSQF:FormFactor_Param1_pop"+num2str(pop))
	NVAR Param2=$("root:Packages:IR2L_NLSQF:FormFactor_Param2_pop"+num2str(pop))
	NVAR Param3=$("root:Packages:IR2L_NLSQF:FormFactor_Param3_pop"+num2str(pop))
	NVAR Param4=$("root:Packages:IR2L_NLSQF:FormFactor_Param4_pop"+num2str(pop))
	NVAR Param5=$("root:Packages:IR2L_NLSQF:FormFactor_Param5_pop"+num2str(pop))
	SVAR UserVolFnctFormula=$("root:Packages:IR2L_NLSQF:FFUserVolumeFormula_pop"+num2str(pop))
	//wave Radius=$("root:Packages:IR2L_NLSQF:Radius_Pop"+num2str(pop))
	Duplicate/O Radius, tempDiameters
	redimension/D tempDiameters, Radius
	tempDiameters = 2 * Radius
 	IR1T_CreateAveVolumeWave(ResultsWave,tempDiameters,FormFactor,Param1,Param2,Param3,0,0,UserVolFnctFormula,Param1,Param2,Param3,Param4,Param5)	
	KillWaves/Z tempDiameters
	setDataFolder OldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//Calculate the distribution waves - depending on user selections
Function IR2L_CreateDistributionWaves(pop)
	variable pop
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	SVAR FormFactor=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(pop))
	SVAR Model=$("root:Packages:IR2L_NLSQF:Model_pop"+num2str(pop))	

//	string ThisDataFldrNm="NLSQF_Data"+num2str(pop)+"_Set"+num2str(dataSet)
//	NewDataFolder/O/S $(ThisDataFldrNm)
	NVAR RdistAuto=$("root:Packages:IR2L_NLSQF:RdistAuto_pop"+num2str(pop))
	NVAR RdistrSemiAuto=$("root:Packages:IR2L_NLSQF:RdistrSemiAuto_pop"+num2str(pop))
	NVAR RdistMan=$("root:Packages:IR2L_NLSQF:RdistMan_pop"+num2str(pop))
	NVAR RdistManMin=$("root:Packages:IR2L_NLSQF:RdistManMin_pop"+num2str(pop))
	NVAR RdistManMax=$("root:Packages:IR2L_NLSQF:RdistManMax_pop"+num2str(pop))
	NVAR RdistLog=$("root:Packages:IR2L_NLSQF:RdistLog_pop"+num2str(pop))
	NVAR RdistNumPnts=$("root:Packages:IR2L_NLSQF:RdistNumPnts_pop"+num2str(pop))
	NVAR RdistNeglectTails=$("root:Packages:IR2L_NLSQF:RdistNeglectTails_pop"+num2str(pop))
	SVAR PopSizeDistShape=$("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(pop))
	NVAR DimensionIsDiameter = root:Packages:IR2L_NLSQF:SizeDist_DimensionIsDiameter

	if(stringmatch(PopSizeDistShape,"LogNormal"))
		NVAR location = $("root:Packages:IR2L_NLSQF:LNMinSize_pop"+num2str(pop))
		NVAR scale = $("root:Packages:IR2L_NLSQF:LNMeanSize_pop"+num2str(pop))
		NVAR shape = $("root:Packages:IR2L_NLSQF:LNSdeviation_pop"+num2str(pop))
	elseif(stringmatch(PopSizeDistShape,"Gauss"))
		NVAR location = $("root:Packages:IR2L_NLSQF:GMeanSize_pop"+num2str(pop))
		NVAR scale = $("root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(pop))
		NVAR shape = $("root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(pop))
	elseif(stringmatch(PopSizeDistShape,"Schulz-Zimm"))
		NVAR location = $("root:Packages:IR2L_NLSQF:SZMeanSize_pop"+num2str(pop))
		NVAR scale = $("root:Packages:IR2L_NLSQF:SZWidth_pop"+num2str(pop))
		NVAR shape = $("root:Packages:IR2L_NLSQF:SZWidth_pop"+num2str(pop))
	elseif(stringmatch(PopSizeDistShape,"Ardell"))
		NVAR location = $("root:Packages:IR2L_NLSQF:ArdLocation_pop"+num2str(pop))
		NVAR scale = $("root:Packages:IR2L_NLSQF:ArdParameter_pop"+num2str(pop))
		NVAR shape = $("root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(pop))
	elseif(stringmatch(PopSizeDistShape,"LSW"))
		NVAR location = $("root:Packages:IR2L_NLSQF:LSWLocation_pop"+num2str(pop))
		NVAR scale = $("root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(pop))
		NVAR shape = $("root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(pop))
	endif

	if(stringMatch(Model,"Size Dist."))	 
		make/O/N=(RdistNumPnts) $("Radius_Pop"+num2str(pop)),$("Diameter_Pop"+num2str(pop)), $("VolumeDist_Pop"+num2str(pop)), $("NumberDist_Pop"+num2str(pop))
		Wave Radius=$("Radius_Pop"+num2str(pop))
		Wave Diameter=$("Diameter_Pop"+num2str(pop))
		if(DimensionIsDiameter)
			if(RdistMan)
				if(RdistLog)
					Diameter=10^(log(RdistManMin)+p*((log(RdistManMax)-log(RdistManMin))/(RdistNumPnts-1)))
				else
					Diameter=RdistManMin+p*(RdistManMax-RdistManMin)/(RdistNumPnts-1)
				endif
			elseif(RdistrSemiAuto)			//thsi is auto, but stopped when fitting... Needs to somehow pass to here that we are fitting... 
				IR2L_GenerateRadiiDist(PopSizeDistShape, Diameter, RdistNumPnts, RdistNeglectTails, location,scale, shape)
			else		//auto is default
				IR2L_GenerateRadiiDist(PopSizeDistShape, Diameter, RdistNumPnts, RdistNeglectTails, location,scale, shape)
			endif
			Radius = Diameter/2
		else			//use Radiii	
			if(RdistMan)
				if(RdistLog)
					Radius=10^(log(RdistManMin)+p*((log(RdistManMax)-log(RdistManMin))/(RdistNumPnts-1)))
				else
					Radius=RdistManMin+p*(RdistManMax-RdistManMin)/(RdistNumPnts-1)
				endif
			elseif(RdistrSemiAuto)			//thsi is auto, but stopped when fitting... Needs to somehow pass to here that we are fitting... 
				IR2L_GenerateRadiiDist(PopSizeDistShape, Radius, RdistNumPnts, RdistNeglectTails, location,scale, shape)
			else		//auto is default
				IR2L_GenerateRadiiDist(PopSizeDistShape, Radius, RdistNumPnts, RdistNeglectTails, location,scale, shape)
			endif
			Diameter = 2*Radius
		endif
	else
		make/O/N=(100) $("Radius_Pop"+num2str(pop)), $("VolumeDist_Pop"+num2str(pop)), $("NumberDist_Pop"+num2str(pop))
		Wave Radius=$("Radius_Pop"+num2str(pop))
		Radius=10+p*(990)/(99)
	endif

	setDataFolder OldDf	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


//****************   This calculates distribution of diameters and needed for the probability distribution   ***********************************************************

Function IR2L_GenerateRadiiDist(MyFunction, OutputWave, numberOfPoints, myprecision, location,scale, shape)
	string MyFunction
	wave OutputWave
	variable numberOfPoints, myprecision, location,scale, shape
	//
	//  Important : this wave will be produced in current folder
	//
	//this function generates non-regular distribution of diameters for distributions
	//Myfunction can now be Gauss, LogNormal, LSW, or LogNormal
	//OutputWaveName is string with wave name. The wave is created with numberOfPoints number of points and existing one, if exists, is overwritten
	// my precision is value (~0.001 for example) which denotes how low probability we want to neglect (P<precision and P>(1-precision) are neglected
	//location, scale, shape are values for the probability distributions
	
	//logic: we start in the median and walk towards low (high) values. When cumulative value is smaller (larger) than precision (1-precision)
	//we end. If we walk out of reasonable values (10A and 10^15A), we stop.
	
	//first we need to find step, which we will use to step from median
	DFref oldDf= GetDataFolderDFR()

	SetDataFolder root:Packages:IR2L_NLSQF


	variable startx, endx, guess, Step, mode, tempVal, tempResult
	
	if (cmpstr("Gauss",MyFunction)==0)
		Step=scale*0.02					//standard deviation
	endif
	if (cmpstr("Schulz-Zimm",MyFunction)==0)
		Step=scale*0.02					//standard deviation
	endif
	if (cmpstr("Ardell",MyFunction)==0)
		Step=location*0.02					//step from main peak location
	endif
	if (cmpstr("LSW",MyFunction)==0)
		Step=location*0.3				//just some step for this distribution
	endif
	if (cmpstr("LogNormal",MyFunction)==0)
		Step=4*sqrt(exp(shape^2)*(exp(shape^2)-1))	//standard deviation
	endif
	if (cmpstr("PowerLaw",MyFunction)==0)
		Step=500	//a number here
	endif
	
	//now we need to find the median

	if (cmpstr("Gauss",MyFunction)==0)
		mode=location	//=median
	endif
	if (cmpstr("Schulz-Zimm",MyFunction)==0)
		mode=location	//=median
	endif
	if (cmpstr("Ardell",MyFunction)==0)
		mode=location	//=median
	endif
	if (cmpstr("LSW",MyFunction)==0)
		mode=location	//close to median, who really cares where we start as long as it is close...
	endif
	if (cmpstr("LogNormal",MyFunction)==0)
		mode=location+scale/(exp(shape^2))	//=median
	endif
	if (cmpstr("PowerLaw",MyFunction)==0)
		mode=500  				// a number
	endif
	// look for minimum
	//now we can start at median and go step by step and end when the 
	//cumulative function is smaller than the myprecision
	
	variable minimumXPossible=1   //if it should be smaller than 2A, it is nonsence...
	
	tempVal=mode
	
	do
		tempVal=tempVal-Step			//OK, this way we should make always one more step over the limit...

		if (tempVal<minimumXPossible)
			tempVal=minimumXPossible
		endif

		if (cmpstr("Gauss",MyFunction)==0)
			tempResult=IR1_GaussCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("Schulz-Zimm",MyFunction)==0)
			tempResult=IR1_SZCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("LSW",MyFunction)==0)
			tempResult=IR2L_LSWCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("Ardell",MyFunction)==0)
			tempResult=IR1_ArdellCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("LogNormal",MyFunction)==0)
			tempResult=IR1_LogNormCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("PowerLaw",MyFunction)==0)		//this funny function exists over whole size range possible....
			tempResult=0
			tempVal=minimumXPossible
		endif
		
	while ((tempResult>myprecision)&&(tempVal>minimumXPossible))			

	startx = tempVal
	//and this will be needed lower, in case when we have distributions attempting to get into negative diameters...
	variable startCumTrgts=myprecision
	if (startx==minimumXPossible)	//in this case we run into negative values and overwrote the startX values
			if (cmpstr("Gauss",MyFunction)==0)
				startCumTrgts=IR1_GaussCumulative(minimumXPossible,location,scale, shape)
			endif
			if (cmpstr("Schulz-Zimm",MyFunction)==0)		
				startCumTrgts=IR1_SZCumulative(minimumXPossible,location,scale, shape)
			endif
			if (cmpstr("LSW",MyFunction)==0)
				startCumTrgts=IR2L_LSWCumulative(minimumXPossible,location,scale, shape)
			endif
			if (cmpstr("Ardell",MyFunction)==0)
				startCumTrgts=IR1_ArdellCumulative(minimumXPossible,location,scale, shape)
			endif
			if (cmpstr("LogNormal",MyFunction)==0)
				startCumTrgts=IR1_LogNormCumulative(minimumXPossible,location,scale, shape)
			endif
			if (cmpstr("PowerLaw",MyFunction)==0)
				startCumTrgts=myprecision
			endif
	endif

	//now we need to calculate the endx

	variable maximumXPossible=1e15	//maximum, fixed for giant number due to use of the code for light scattering
				
	tempVal=mode
	
	do
		tempVal=tempVal+Step		//again, whould be one step larger than needed...
		if (tempVal>maximumXPossible)
			tempVal=maximumXPossible
		endif

		if (cmpstr("Gauss",MyFunction)==0)
			tempResult=IR1_GaussCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("Schulz-Zimm",MyFunction)==0)
			tempResult=IR1_SZCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("Ardell",MyFunction)==0)
			tempResult=IR1_ArdellCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("LSW",MyFunction)==0)
			tempResult = 1
			tempVal = 1.5 * location //this distribution does not exist over this value...
		endif
		if (cmpstr("LogNormal",MyFunction)==0)
			tempResult=IR1_LogNormCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("PowerLaw",MyFunction)==0)
			maximumXPossible=1e7
			tempResult=1
			tempVal=maximumXPossible
		endif
	while ((tempResult<(1-myprecision))&&(tempVal<maximumXPossible))			
	//Ardell is weird, ends too soon...
		if (cmpstr("Ardell",MyFunction)==0)
			tempVal+=0.5*Step
		endif
	
	
	endx = tempVal

	//and now we can start making the the data. 
	// First we will create a wave with equally distributed values between myprecision and 1-myprecision : Temp_CumulTargets
	//We will also create waves with 3*as many points with diameters between startx and endx (Temp_diameters) and with appropriate cumulative distribution (Temp_CumulativeWave)
	//then we will look for which diameters we get the cumulative numbers in Temp_CumulTargets and put these in output wave
	
	Make/D /N=(numberOfPoints) /Free Temp_CumulTargets
	Make/D /N=(3*numberOfPoints) /Free Temp_CumulativeWave,Temp_diameters
	
	
	Temp_diameters=startx+p*(endx-startx)/(3*numberOfPoints-1)			//this puts the proper diameters distribution in the temp diameters wave
	
	//Ardell is weird, ends too soon...
		if (cmpstr("Ardell",MyFunction)==0)
			Temp_CumulTargets=startCumTrgts+p*(1-startCumTrgts)/(numberOfPoints-1) //this puts equally spaced values between myprecision and (1-myprecision) in this wave
		else
			Temp_CumulTargets=startCumTrgts+p*(1-myprecision-startCumTrgts)/(numberOfPoints-1) //this puts equally spaced values between myprecision and (1-myprecision) in this wave
		endif
	//calculate the cumulative waves
	if (cmpstr("Gauss",MyFunction)==0)
		Temp_CumulativeWave=IR1_GaussCumulative(Temp_diameters,location,scale, shape)
	endif
	if (cmpstr("Schulz-Zimm",MyFunction)==0)
		Temp_CumulativeWave=IR1_SZCumulative(Temp_diameters,location,scale, shape)
	endif
	if (cmpstr("Ardell",MyFunction)==0)
		multithread Temp_CumulativeWave=IR1_ArdellCumulative(Temp_diameters,location,scale, shape)
	endif
	if (cmpstr("LSW",MyFunction)==0)
		Temp_CumulativeWave=IR2L_LSWCumulative(Temp_diameters,location,scale, shape)
		Temp_CumulativeWave[numpnts(Temp_CumulativeWave)-1]=1	//last point is NaN, we need to make it 1
	endif
	if (cmpstr("LogNormal",MyFunction)==0)
		Temp_CumulativeWave=IR1_LogNormCumulative(Temp_diameters,location,scale, shape)
	endif
	if (cmpstr("PowerLaw",MyFunction)==0)
		Temp_CumulativeWave=IR1_PowerLawCumulative(Temp_diameters,shape,startx,endx)
	endif
	
		//and now the difficult part - get the diameterss, which are unequally spaced, but whose probability for the distribution are equally spaced...
		OutputWave=interp(Temp_CumulTargets, Temp_CumulativeWave, Temp_diameters )
	variable temp
	if (cmpstr("PowerLaw",MyFunction)==0) //the code above fails for this distribution type, we need to create new diameters...
		//DistributionDiametersWave=startx+log(p)*(endx-startx)/log(numberOfPoints)
		//temp=log(startx)+p*((log(endx)-log(startx))/(numberOfPoints-1))
		OutputWave=10^(log(startx)+p*((log(endx)-log(startx))/(numberOfPoints-1)))
	endif

	setDataFolder OldDf
	
end



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_LSWCumulative(xx,location,scale, shape)
		variable xx, location,scale, shape
	//this function calculates probability for LSW distribution
	//I do not have cumulative probability function, so it is done numerically... More complex and much more annoying...
	DFref oldDf= GetDataFolderDFR()

	SetDataFolder root:Packages:IR2L_NLSQF
			
	variable result, pointsNeeded=ceil(xx/30+30)
	//points neede is at least 30 and max out around 370 for 10000 A location
	make/D /O/N=(PointsNeeded)/Free temp_LSWwav 
	
	SetScale/P x 10,(xx/(numpnts(temp_LSWwav)-3)),"", temp_LSWwav	
	//this sets scale so the model wave x scale covers area from 10 A over the needed point...
	
	temp_LSWwav=IR1_LSWProbability(pnt2x(temp_LSWwav, p ),location,scale, shape)
	
	integrate /T temp_LSWwav
	//and at this point the temp_LSWwav has integral values in it... 
	result = temp_LSWwav(xx) //here we get the value interpolated (linearly) for the needed point...
	setDataFolder OldDf
	return result
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_UpdateModeMedianMean()

	NVAR UseNumberDistributions=root:Packages:IR2L_NLSQF:UseNumberDistributions
	
	variable i
	For (i=1;i<11;i+=1)
		NVAR UsePop=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(i))
		if(UsePop)
			IR2L_UpdtSeparateMMM(i)
		endif	
	endfor
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2L_UpdtSeparateMMM(distNum)
	Variable distNum

	DFref oldDf= GetDataFolderDFR()

	SetDataFolder root:Packages:IR2L_NLSQF
	SVAR FormFactor=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(distNum))
	SVAR Model=	$("root:Packages:IR2L_NLSQF:Model_pop"+num2str(distNum))

	NVAR DistMean=$("root:Packages:IR2L_NLSQF:Mean_pop"+num2str(distNum))
	NVAR DistMedian=$("root:Packages:IR2L_NLSQF:Median_pop"+num2str(distNum))
	NVAR DistMode=$("root:Packages:IR2L_NLSQF:Mode_pop"+num2str(distNum))
	NVAR DistFWHM=$("root:Packages:IR2L_NLSQF:FWHM_pop"+num2str(distNum))
	NVAR DistInputNumberDist=root:Packages:IR2L_NLSQF:UseNumberDistributions

	NVAR DimensionIsDiameter = root:Packages:IR2L_NLSQF:SizeDist_DimensionIsDiameter

	if(stringMatch(Model,"Unified Level"))
		DistMean=NaN
		DistMedian=NaN
		DistMode=NaN
		DistFWHM=NaN
	elseif(stringMatch(Model,"Size dist."))
		Wave DistRadius=$("root:Packages:IR2L_NLSQF:Radius_Pop"+num2str(distNum))
		Wave DistDiameter=$("root:Packages:IR2L_NLSQF:Diameter_Pop"+num2str(distNum))
		Wave DistVolumeDist=$("root:Packages:IR2L_NLSQF:VolumeDist_Pop"+num2str(distNum))
		Wave DistNumberDist=$("root:Packages:IR2L_NLSQF:NumberDist_Pop"+num2str(distNum))
		NVAR Rg=$("root:Packages:IR2L_NLSQF:Rg_Pop"+num2str(distNum))
							
		if(DimensionIsDiameter)
			Duplicate/Free DistDiameter, DistDimension
			Rg = IR2L_CalculateRg(DistDiameter,DistVolumeDist,DimensionIsDiameter)	
		else
			Duplicate/Free DistRadius, DistDimension
			Rg = IR2L_CalculateRg(DistRadius,DistVolumeDist,DimensionIsDiameter)	
		endif
		if (DistInputNumberDist)		//use number distribution...
			Duplicate/Free DistNumberDist, Temp_Probability, Another_temp, Temp_Cumulative
			Redimension/D  Temp_Probability, Another_temp, Temp_Cumulative
			Temp_Cumulative=areaXY(DistDimension, Temp_Probability, DistDimension[0], DistDimension[p] )
		else							//use volume distribution
			Duplicate/Free DistVolumeDist, Temp_Probability, Another_temp, Temp_Cumulative
			Redimension/D  Temp_Probability, Another_temp, Temp_Cumulative
			Temp_Cumulative=areaXY(DistDimension, Temp_Probability, DistDimension[0], DistDimension[p] )
		endif	
	
		
			Another_temp=DistDimension*Temp_Probability
			DistMean=areaXY(DistDimension, Another_temp,0,inf)	/ areaXY(DistDimension, Temp_Probability,0,inf)				//Sum P(D)*D*deltaD/P(D)*deltaD
			DistMedian=DistDimension[BinarySearchInterp(Temp_Cumulative, 0.5*Temp_Cumulative[numpnts(Temp_Cumulative)-1] )]		//R for which cumulative probability=0.5
			FindPeak/P/Q Temp_Probability
			DistMode=DistDimension[V_PeakLoc]								//location of maximum on the P(R)
			
			DistFWHM=IR1_FindFWHM(Temp_Probability,DistDimension)				//Ok, this is monkey approach
	endif	
	
//	KillWaves/Z Temp_Probability, Temp_Cumulative, Another_Temp

	setDataFolder OldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_CalculateRg(Dimension,VolumeDistribution,DimensionIsDiameter)
 	wave Dimension,VolumeDistribution
 	variable DimensionIsDiameter
 	
 	variable Rg
 	if(DimensionIsDiameter)	//diameter, need to divide by 2 first
 		Duplicate/Free Dimension, LocDimension, Integrant
 		LocDimension = Dimension/2
 	else	//radius directly
  		Duplicate/Free Dimension, LocDimension, Integrant
 	endif
	Integrant=LocDimension^2*VolumeDistribution
	//print Areaxy(LocDimension,Integrant)
	//print Areaxy(LocDimension,VolumeDistribution)
	Rg=sqrt(Areaxy(LocDimension,Integrant)/Areaxy(LocDimension,VolumeDistribution))
	return Rg
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
