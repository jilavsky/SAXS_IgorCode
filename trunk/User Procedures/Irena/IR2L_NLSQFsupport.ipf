#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.26

//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.26 changed in Unicertainity analysis length of paramName to 20 characters. 
//1.25 fixed Notebook recording of Shulz-Zimm distribution type
//1.24 minor fix in Uncertainity evaluation. 
//1.23 Propagated through Modeling II Intensity units. Removed option to combine SphereWithLocallyMonodispersedSq with any structrue factor. 
//1.22 fixed bug when Analyze uncertainities would not get number of fitted points due to changed folder. 
//1.21 fixed Background GUI which has step set to 0 after chanigng the tabs.
//1.20 added to Unified level ability to link B to G/Rg/P based on Guinier/Porod theory. Remoeved abuility to fit RgCO at all. 
//1.19 fixed IR2L_FixLimits function to set some high limit when parameter=0, added support for NoFitLimits feature
//		support for changet the tab of used tabs names.. 
//1.18 fixed bug when reinitialization of Unified levels would add G=100 even when Rg=1e10. Fix GUI issue when adding new data set and recovering the stored result. 
//		Fixes for too long ParamNames in Analysis of uncertainities.
//1.17 fixed bug when scripting tool got out of sync with main Modeling II panel. 
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



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_InputGraphButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
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
		print "Modeling II main graph does not exist"
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
	string oldDf=GetDataFolder(1)
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
	string oldDf=GetDataFolder(1)
	
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
	
	string oldDf=GetDataFolder(1)
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
	string oldDf=GetDataFolder(1)
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
	string oldDf=GetDataFolder(1)
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
			print "NOTE: Only one Unified level should be used at once in Modeling II. For more levels use Unified Fit tool"
		else
			DoAlert 0, "NOTE: Only one Unified level should be used at once in Modeling II. For more levels use Unified Fit tool"
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

	string oldDf=GetDataFolder(1)
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

	if (stringmatch(ctrlName,"DataUnits"))
		IR2L_SetDataUnits(popStr)
	endif

	if (stringmatch(ctrlName,"DiffPeakProfile"))
		ControlInfo/W=LSQF2_MainPanel DistTabs
		SVAR DiffPeakProfile = $("root:Packages:IR2L_NLSQF:DiffPeakProfile_pop"+num2str(V_Value+1))
		DiffPeakProfile = popStr
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
			DoWindow StructureFactorControlScreen
			if(V_Flag)
				DoWindow/K StructureFactorControlScreen
			endif
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
	
	string OldDf=GetDataFolder(1)
	
	DoWindow FormFactorControlScreen
	if(V_Flag)
		DoWindow/K FormFactorControlScreen
	endif
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

	PopupMenu KFactor,pos={10,135},size={170,21},proc=IR2L_PanelPopupControl,title="k factor :"
	PopupMenu KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}
	
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_Data_TabPanelControl(name,tab)
	String name
	Variable tab

	string oldDf=GetDataFolder(1)
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
		Execute("CheckBox UseTheData_set ,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(tab+1)+", disable=( !"+num2str(DisplayInputDataControls)+"||!"+num2str(displayUseCheckbox)+")")
		Execute("CheckBox SlitSmeared_set ,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:SlitSmeared_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("SetVariable SlitLength_set ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:SlitLength_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"|| !"+num2str(DisplaySlitSmeared)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("SetVariable FolderName_set ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:FolderName_set"+num2str(tab+1)+", disable=( !"+num2str(DisplayInputDataControls)+"||!"+num2str(displayUseCheckbox)+")")
		Execute("SetVariable UserDataSetName_set ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:UserDataSetName_set"+num2str(tab+1)+", disable=( !"+num2str(DisplayInputDataControls)+"||!"+num2str(displayUseCheckbox)+")")
		Execute("SetVariable Qmin_set ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:Qmin_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("SetVariable Qmax_set ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:Qmax_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		
		NVAR Background = $("root:Packages:IR2L_NLSQF:Background_set"+num2str(tab+1))
		NVAR BckgStep = $("root:Packages:IR2L_NLSQF:BackgStep_set"+num2str(tab+1))
		BckgStep = 0.05 * Background 
		Execute("SetVariable Background ,win=LSQF2_MainPanel ,limits={0,Inf,"+num2str(BckgStep)+"}, variable=root:Packages:IR2L_NLSQF:Background_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
//		Execute("SetVariable BackgStep ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:BackgStep_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("SetVariable BackgroundMin ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:BackgroundMin_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayFitRange)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("SetVariable BackgroundMax ,win=LSQF2_MainPanel ,variable=root:Packages:IR2L_NLSQF:BackgroundMax_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayFitRange)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("CheckBox BackgroundFit_set ,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:BackgroundFit_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")		
		Execute("SetVariable DataScalingFactor_set,win=LSQF2_MainPanel,value= root:Packages:IR2L_NLSQF:DataScalingFactor_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("CheckBox UseUserErrors_set,win=LSQF2_MainPanel, variable= root:Packages:IR2L_NLSQF:UseUserErrors_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("CheckBox UseSQRTErrors_set,win=LSQF2_MainPanel, variable= root:Packages:IR2L_NLSQF:UseSQRTErrors_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("CheckBox UsePercentErrors_set,win=LSQF2_MainPanel, variable= root:Packages:IR2L_NLSQF:UsePercentErrors_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("SetVariable ErrorScalingFactor_set,win=LSQF2_MainPanel,value= root:Packages:IR2L_NLSQF:ErrorScalingFactor_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
	
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

	string oldDf=GetDataFolder(1)
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
	variable S_sw, F_sw,CS_sw, Dif_sw
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
	else
		F_sw=3		//unused yet.
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
	else
		S_sw=3			//we have LSW....
	endif


		Execute("CheckBox UseThePop,win=LSQF2_MainPanel ,variable=root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+")")
		Execute("PopupMenu PopulationType,win=LSQF2_MainPanel, mode=(WhichListItem(root:Packages:IR2L_NLSQF:Model_pop"+num2str(tab+1)+",\"Size dist.;Unified level;Diffraction Peak;\")+1), disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+")")
		
		
		Execute("CheckBox RdistAuto,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:RdistAuto_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("CheckBox RdistrSemiAuto,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:RdistrSemiAuto_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("CheckBox RdistMan,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:RdistMan_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(UsePop)+")")

		Execute("SetVariable RdistNumPnts,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:RdistNumPnts_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable RdistManMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:RdistManMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable RdistManMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:RdistManMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(UsePop)+"|| "+num2str(!RdistManual)+")")

		Execute("SetVariable RdistNeglectTails,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:RdistNeglectTails_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(UsePop)+"|| "+num2str(RdistManual)+")")

		Execute("CheckBox RdistLog,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:RdistLog_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(UsePop)+")")

		Execute("PopupMenu FormFactorPop,win=LSQF2_MainPanel, mode=(WhichListItem(root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(tab+1)+",root:Packages:FormFactorCalc:ListOfFormFactors+\"Unified_Level;\")+1), disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable SizeDist_DimensionType,win=LSQF2_MainPanel,  disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("Button GetFFHelp,win=LSQF2_MainPanel, disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(UsePop)+")")

		Execute("PopupMenu PopSizeDistShape,win=LSQF2_MainPanel, mode=(WhichListItem(root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(tab+1)+",\"LogNormal;Gauss;LSW;Schulz-Zimm;\")+1), disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(UsePop)+")")
		//diffraction stuff
		Execute("PopupMenu DiffPeakProfile,win=LSQF2_MainPanel, mode=(WhichListItem(root:Packages:IR2L_NLSQF:DiffPeakProfile_pop"+num2str(tab+1)+",root:Packages:IR2L_NLSQF:ListOfKnownPeakShapes)+1), disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable DiffPeakPar1,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakPar1_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable DiffPeakPar1,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:DiffPeakPar1_pop"+num2str(tab+1)+"}")
		Execute("Checkbox DiffPeakPar1Fit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakPar1Fit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable DiffPeakPar1Min,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakPar1Min_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable DiffPeakPar1Max,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakPar1Max_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")

		Execute("SetVariable DiffPeakPar2,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakPar2_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable DiffPeakPar2,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:DiffPeakPar2_pop"+num2str(tab+1)+"}")
		Execute("Checkbox DiffPeakPar2Fit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakPar2Fit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable DiffPeakPar2Min,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakPar2Min_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable DiffPeakPar2Max,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakPar2Max_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")

		Execute("SetVariable DiffPeakPar3,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakPar3_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable DiffPeakPar3,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:DiffPeakPar3_pop"+num2str(tab+1)+"}")
		Execute("Checkbox DiffPeakPar3Fit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakPar3Fit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable DiffPeakPar3Min,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakPar3Min_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable DiffPeakPar3Max,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakPar3Max_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")
		
		if(stringmatch(PeakProfile, "Pseudo-Voigt"))
			Execute("SetVariable DiffPeakPar4,win=LSQF2_MainPanel, title=\"Eta           = \"")	
		elseif(stringmatch(PeakProfile, "Pearson_VII")||stringmatch(PeakProfile, "Modif_Gauss"))
			Execute("SetVariable DiffPeakPar4,win=LSQF2_MainPanel, title=\"Tail Param = \"")
		elseif(stringmatch(PeakProfile, "SkewedNormal"))	
			Execute("SetVariable DiffPeakPar4,win=LSQF2_MainPanel, title=\"Skewness = \"")	
		endif
		Execute("SetVariable DiffPeakPar4,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakPar4_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(Dif_sw==1)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable DiffPeakPar4,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:DiffPeakPar4_pop"+num2str(tab+1)+"}")
		Execute("Checkbox DiffPeakPar4Fit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakPar4Fit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(Dif_sw==1)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable DiffPeakPar4Min,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakPar4Min_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(Dif_sw==1)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable DiffPeakPar4Max,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakPar4Max_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(Dif_sw==1)+"|| !"+num2str(F_sw==2)+"|| !"+num2str(UsePop)+")")
		variable tempSw
		if((DisplayModelControls)&&(F_sw==2)&&(UsePop==1))
			tempSw=2
		else
			tempSw=1
		endif
		Execute("SetVariable DiffPeakDPos,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakDPos_pop"+num2str(tab+1)+", disable=("+num2str(tempSw))
		Execute("SetVariable DiffPeakQPos,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakQPos_pop"+num2str(tab+1)+", disable=("+num2str(tempSw))
		Execute("SetVariable DiffPeakQFWHM,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakQFWHM_pop"+num2str(tab+1)+", disable=("+num2str(tempSw))
		Execute("SetVariable DiffPeakIntgInt,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:DiffPeakIntgInt_pop"+num2str(tab+1)+", disable=("+num2str(tempSw))

		//size dist controls

		Execute("SetVariable Volume,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Volume_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable Volume,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:Volume_pop"+num2str(tab+1)+"}")
		Execute("Checkbox FitVolume,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:VolumeFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable VolumeMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:VolumeMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(UsePop)+"|| !"+num2str(DisplayVolumeLims)+")")
		Execute("SetVariable VolumeMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:VolumeMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(UsePop)+"|| !"+num2str(DisplayVolumeLims)+")")

		NVAR DLNM1=$("root:Packages:IR2L_NLSQF:LNMinSizeFit_pop"+num2str(tab+1))
		Execute("SetVariable LNMinSize,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNMinSize_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable LNMinSize,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:LNMinSize_pop"+num2str(tab+1)+"}")
		Execute("Checkbox LNMinSizeFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNMinSizeFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable LNMinSizeMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNMinSizeMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+"|| !"+num2str(DLNM1)+")")
		Execute("SetVariable LNMinSizeMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNMinSizeMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+"|| !"+num2str(DLNM1)+")")

		NVAR DLNM2=$("root:Packages:IR2L_NLSQF:LNMeanSizeFit_pop"+num2str(tab+1))
		Execute("SetVariable LNMeanSize,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNMeanSize_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable LNMeanSize,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:LNMeanSize_pop"+num2str(tab+1)+"}")
		Execute("Checkbox LNMeanSizeFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNMeanSizeFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable LNMeanSizeMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNMeanSizeMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+"|| !"+num2str(DLNM2)+")")
		Execute("SetVariable LNMeanSizeMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNMeanSizeMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+"|| !"+num2str(DLNM2)+")")

		NVAR DLNM3=$("root:Packages:IR2L_NLSQF:LNSdeviationFit_pop"+num2str(tab+1))
		Execute("SetVariable LNSdeviation,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNSdeviation_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable LNSdeviation,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:LNSdeviation_pop"+num2str(tab+1)+"}")
		Execute("Checkbox LNSdeviationFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNSdeviationFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable LNSdeviationMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNSdeviationMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+"|| !"+num2str(DLNM3)+")")
		Execute("SetVariable LNSdeviationMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNSdeviationMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+"|| !"+num2str(DLNM3)+")")

		NVAR DGM1=$("root:Packages:IR2L_NLSQF:GMeanSizeFit_pop"+num2str(tab+1))
		Execute("SetVariable GMeanSize,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:GMeanSize_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable GMeanSize,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:GMeanSize_pop"+num2str(tab+1)+"}")
		Execute("Checkbox GMeanSizeFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:GMeanSizeFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable GMeanSizeMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:GMeanSizeMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==2)+"|| !"+num2str(UsePop)+"|| !"+num2str(DGM1)+")")
		Execute("SetVariable GMeanSizeMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:GMeanSizeMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==2)+"|| !"+num2str(UsePop)+"|| !"+num2str(DGM1)+")")

		NVAR DGM2=$("root:Packages:IR2L_NLSQF:GWidthFit_pop"+num2str(tab+1))
		Execute("SetVariable GWidth,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable GWidth,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(tab+1)+"}")
		Execute("Checkbox GWidthFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:GWidthFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable GWidthMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:GWidthMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==2)+"|| !"+num2str(UsePop)+"|| !"+num2str(DGM2)+")")
		Execute("SetVariable GWidthMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:GWidthMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==2)+"|| !"+num2str(UsePop)+"|| !"+num2str(DGM2)+")")

		NVAR DSZM1=$("root:Packages:IR2L_NLSQF:SZMeanSizeFit_pop"+num2str(tab+1))
		Execute("SetVariable SZMeanSize,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:SZMeanSize_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==4)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable SZMeanSize,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:SZMeanSize_pop"+num2str(tab+1)+"}")
		Execute("Checkbox SZMeanSizeFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:SZMeanSizeFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==4)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable SZMeanSizeMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:SZMeanSizeMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==4)+"|| !"+num2str(UsePop)+"|| !"+num2str(DSZM1)+")")
		Execute("SetVariable SZMeanSizeMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:SZMeanSizeMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==4)+"|| !"+num2str(UsePop)+"|| !"+num2str(DSZM1)+")")

		NVAR DSZM2=$("root:Packages:IR2L_NLSQF:SZWidthFit_pop"+num2str(tab+1))
		Execute("SetVariable SZWidth,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:SZWidth_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==4)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable SZWidth,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:SZWidth_pop"+num2str(tab+1)+"}")
		Execute("Checkbox SZWidthFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:SZWidthFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==4)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable SZWidthMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:SZWidthMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==4)+"|| !"+num2str(UsePop)+"|| !"+num2str(DSZM2)+")")
		Execute("SetVariable SZWidthMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:SZWidthMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==4)+"|| !"+num2str(UsePop)+"|| !"+num2str(DSZM2)+")")


		NVAR DLSW1=$("root:Packages:IR2L_NLSQF:LSWLocationFit_pop"+num2str(tab+1))
		Execute("SetVariable LSWLocation,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LSWLocation_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==3)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable LSWLocation,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:LSWLocation_pop"+num2str(tab+1)+"}")
		Execute("Checkbox LSWLocationFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LSWLocationFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==3)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable LSWLocationMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LSWLocationMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==3)+"|| !"+num2str(UsePop)+"|| !"+num2str(DLSW1)+")")
		Execute("SetVariable LSWLocationMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LSWLocationMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| !"+num2str(F_sw==1)+"|| !"+num2str(S_sw==3)+"|| !"+num2str(UsePop)+"|| !"+num2str(DLSW1)+")")
		//unified fit controls		
		Execute("Button FitRgAndG,win=LSQF2_MainPanel,"+" disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+")")
		Execute("Button FitPandB,win=LSQF2_MainPanel,"+" disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+")")

		NVAR UNF1=$("root:Packages:IR2L_NLSQF:UF_GFit_pop"+num2str(tab+1))
		Execute("SetVariable UF_G,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_G_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable UF_G,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:UF_G_pop"+num2str(tab+1)+"}")
		Execute("Checkbox UF_GFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_GFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable UF_GMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_GMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+"|| !"+num2str(UNF1)+")")
		Execute("SetVariable UF_GMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_GMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+"|| !"+num2str(UNF1)+")")

		NVAR UNF2=$("root:Packages:IR2L_NLSQF:UF_RgFit_pop"+num2str(tab+1))
		Execute("SetVariable UF_Rg,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_Rg_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable UF_Rg,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:UF_Rg_pop"+num2str(tab+1)+"}")
		Execute("Checkbox UF_RgFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_RgFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable UF_RgMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_RgMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+"|| !"+num2str(UNF2)+")")
		Execute("SetVariable UF_RgMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_RgMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+"|| !"+num2str(UNF2)+")")

		NVAR UFLB=$("root:Packages:IR2L_NLSQF:UF_LinkB_pop"+num2str(tab+1))
		NVAR UNF3=$("root:Packages:IR2L_NLSQF:UF_BFit_pop"+num2str(tab+1))
		variable showB = !DisplayModelControls || F_sw || !UsePop
		showB = (!showB) && UFLB  ? 2 : showB
		//Execute("SetVariable UF_B,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_B_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable UF_B,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_B_pop"+num2str(tab+1)+", disable=("+num2str(showB)+")")
		Execute("SetVariable UF_B,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:UF_B_pop"+num2str(tab+1)+"}")
		Execute("Checkbox UF_BFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_BFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(F_sw)+"|| "+num2str(UFLB)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable UF_BMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_BMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| "+num2str(UFLB)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+"|| !"+num2str(UNF3)+")")
		Execute("SetVariable UF_BMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_BMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| "+num2str(UFLB)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+"|| !"+num2str(UNF3)+")")

		Execute("CheckBox UF_LinkB,variable= root:Packages:IR2L_NLSQF:UF_LinkB_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+")")

		NVAR UNF4=$("root:Packages:IR2L_NLSQF:UF_PFit_pop"+num2str(tab+1))
		Execute("SetVariable UF_P,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_P_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable UF_P,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:UF_P_pop"+num2str(tab+1)+"}")
		Execute("Checkbox UF_PFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_PFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable UF_PMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_PMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+"|| !"+num2str(UNF4)+")")
		Execute("SetVariable UF_PMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_PMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+"|| !"+num2str(UNF4)+")")

		NVAR UNF5=$("root:Packages:IR2L_NLSQF:UF_RGCOFit_pop"+num2str(tab+1))
		Execute("SetVariable UF_RGCO,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_RGCO_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable UF_RGCO,win=LSQF2_MainPanel, Limits= {0,inf,0.05*root:Packages:IR2L_NLSQF:UF_RGCO_pop"+num2str(tab+1)+"}")
		//Execute("Checkbox UF_RGCOFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_RGCOFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+")")
		//Execute("SetVariable UF_RGCOMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_RGCOMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+"|| !"+num2str(UNF5)+")")
		//Execute("SetVariable UF_RGCOMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UF_RGCOMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(NoFittingLimits)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+"|| !"+num2str(UNF5)+")")
		
		NVAR UF_K=$("root:Packages:IR2L_NLSQF:UF_K_pop"+num2str(tab+1))
		Execute("PopupMenu KFactor,win=LSQF2_MainPanel, mode=(WhichListItem(\""+num2str(UF_K)+"\",\"1;1.06;\")+1), disable=(!"+num2str(DisplayModelControls)+"|| "+num2str(F_sw)+"|| !"+num2str(UsePop)+")")

		SVAR StrA=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(tab+1))
		SVAR StrB=root:Packages:StructureFactorCalc:ListOfStructureFactors
		Execute("PopupMenu StructureFactorModel win=LSQF2_MainPanel, mode=WhichListItem(\""+StrA+"\",\""+StrB+"\" )+1, disable=(!"+num2str(DisplayModelControls)+"||! "+num2str(F_sw<=1)+"|| !"+num2str(UsePop)+")")
		Execute("Button GetSFHelp win=LSQF2_MainPanel, disable=(!"+num2str(DisplayModelControls)+"||! "+num2str(F_sw<=1)+"|| !"+num2str(UsePop)+")")
		//contrasts
		Execute("SetVariable Contrast,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(CS_sw)+"|| !"+num2str(UsePop)+"|| !"+num2str(!SameContr || !MID)+")")

		Execute("SetVariable Contrast_set1,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set1_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(CS_sw)+"|| !"+num2str(UD1)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set2,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set2_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(CS_sw)+"|| !"+num2str(UD2)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set3,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set3_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(CS_sw)+"|| !"+num2str(UD3)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set4,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set4_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(CS_sw)+"|| !"+num2str(UD4)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set5,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set5_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(CS_sw)+"|| !"+num2str(UD5)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set6,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set6_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(CS_sw)+"|| !"+num2str(UD6)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set7,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set7_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(CS_sw)+"|| !"+num2str(UD7)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set8,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set8_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(CS_sw)+"|| !"+num2str(UD8)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set9,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set9_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(CS_sw)+"|| !"+num2str(UD9)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set10,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set10_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(CS_sw)+"|| !"+num2str(UD10)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		
	setDataFolder OldDf
	
	//update the graph with displayed Mean mode etc...
	IR2L_RemoveLocalGunierPorodFits()
	IR2L_GraphSizeDistUpdate()
	IR2L_AppendOrRemoveLocalPopInts()
	DoWindow/F LSQF2_MainPanel
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_RemoveLocalGunierPorodFits()
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
	string oldDf=GetDataFolder(1)
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
Function IR2L_PopSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	string OldDf=GetDataFolder(1)
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
			Execute("SetVariable UF_G,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")	
		endif
	endif
	if(stringmatch(ctrlName,"UF_Rg"))
		//set volume limits... 
		NVAR UF_RgMin=$("root:Packages:IR2L_NLSQF:UF_RgMin_pop"+num2str(whichDataSet))
		NVAR UF_RgMax=$("root:Packages:IR2L_NLSQF:UF_RgMax_pop"+num2str(whichDataSet))
		UF_RgMin= varNum*0.1
		UF_RgMax=varNum*10
		Execute("SetVariable UF_Rg,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")	
	endif
	if(stringmatch(ctrlName,"UF_RgCO"))
		//set volume limits... 
		NVAR UF_RgCOMin=$("root:Packages:IR2L_NLSQF:UF_RgCOMin_pop"+num2str(whichDataSet))
		NVAR UF_RgCOMax=$("root:Packages:IR2L_NLSQF:UF_RgCOMax_pop"+num2str(whichDataSet))
		UF_RgCOMin= varNum*0.1
		UF_RgCOMax=varNum*10
		Execute("SetVariable UF_RgCO,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")	
	endif
	if(stringmatch(ctrlName,"UF_B"))
		//set volume limits... 
		NVAR UF_BMin=$("root:Packages:IR2L_NLSQF:UF_BMin_pop"+num2str(whichDataSet))
		NVAR UF_BMax=$("root:Packages:IR2L_NLSQF:UF_BMax_pop"+num2str(whichDataSet))
		UF_BMin= varNum*0.1
		UF_BMax=varNum*10
		Execute("SetVariable UF_B,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")	
	endif
	if(stringmatch(ctrlName,"UF_P"))
		//set volume limits... 
		NVAR UF_PMin=$("root:Packages:IR2L_NLSQF:UF_PMin_pop"+num2str(whichDataSet))
		NVAR UF_PMax=$("root:Packages:IR2L_NLSQF:UF_PMax_pop"+num2str(whichDataSet))
		UF_PMin= (varNum*0.2)>1 ? varNum*0.2 : 1
		UF_PMax=(varNum*2)<4.5 ? (varNum*2) : 4.5
		Execute("SetVariable UF_P,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")	
	endif

	if(stringmatch(ctrlName,"DiffPeakPar1"))
		//set volume limits... 
		NVAR VolMin=$("root:Packages:IR2L_NLSQF:DiffPeakPar1Min_pop"+num2str(whichDataSet))
		NVAR VolMax=$("root:Packages:IR2L_NLSQF:DiffPeakPar1Max_pop"+num2str(whichDataSet))
		VolMin= varNum*0.5
		VolMax=varNum*2
		Execute("SetVariable DiffPeakPar1,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")	
	endif
	if(stringmatch(ctrlName,"DiffPeakPar2"))
		//set volume limits... 
		NVAR VolMin=$("root:Packages:IR2L_NLSQF:DiffPeakPar2Min_pop"+num2str(whichDataSet))
		NVAR VolMax=$("root:Packages:IR2L_NLSQF:DiffPeakPar2Max_pop"+num2str(whichDataSet))
		VolMin= varNum*0.5
		VolMax=varNum*2
		Execute("SetVariable DiffPeakPar2,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")	
	endif
	if(stringmatch(ctrlName,"DiffPeakPar3"))
		//set volume limits... 
		NVAR VolMin=$("root:Packages:IR2L_NLSQF:DiffPeakPar3Min_pop"+num2str(whichDataSet))
		NVAR VolMax=$("root:Packages:IR2L_NLSQF:DiffPeakPar3Max_pop"+num2str(whichDataSet))
		VolMin= varNum*0.5
		VolMax=varNum*2
		Execute("SetVariable DiffPeakPar3,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")	
	endif
	if(stringmatch(ctrlName,"DiffPeakPar4"))
		//set volume limits... 
		NVAR VolMin=$("root:Packages:IR2L_NLSQF:DiffPeakPar4Min_pop"+num2str(whichDataSet))
		NVAR VolMax=$("root:Packages:IR2L_NLSQF:DiffPeakPar4Max_pop"+num2str(whichDataSet))
		VolMin= varNum*0.5
		VolMax=varNum*2
		Execute("SetVariable DiffPeakPar4,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")	
	endif



	if(stringmatch(ctrlName,"Volume"))
		//set volume limits... 
		NVAR VolMin=$("root:Packages:IR2L_NLSQF:VolumeMin_pop"+num2str(whichDataSet))
		NVAR VolMax=$("root:Packages:IR2L_NLSQF:VolumeMax_pop"+num2str(whichDataSet))
		VolMin= varNum*0.5
		VolMax=varNum*2
		Execute("SetVariable Volume,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")	
	endif
		//LN controls...
	if(stringmatch(ctrlName,"LNMinSize"))
		//set LNMinSize limits... 
		NVAR LNMinSizeMin=$("root:Packages:IR2L_NLSQF:LNMinSizeMin_pop"+num2str(whichDataSet))
		NVAR LNMinSizeMax=$("root:Packages:IR2L_NLSQF:LNMinSizeMax_pop"+num2str(whichDataSet))
		LNMinSizeMin= varNum*0.5
		LNMinSizeMax=varNum*2
		Execute("SetVariable LNMinSize,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"LNMeanSize"))
		//set LNMeanSize limits... 
		NVAR LNMeanSizeMin=$("root:Packages:IR2L_NLSQF:LNMeanSizeMin_pop"+num2str(whichDataSet))
		NVAR LNMeanSizeMax=$("root:Packages:IR2L_NLSQF:LNMeanSizeMax_pop"+num2str(whichDataSet))
		LNMeanSizeMin= varNum*0.5
		LNMeanSizeMax=varNum*2
		Execute("SetVariable LNMeanSize,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"LNSdeviation"))
		//set LNSdeviation limits... 
		NVAR LNSdeviationMin=$("root:Packages:IR2L_NLSQF:LNSdeviationMin_pop"+num2str(whichDataSet))
		NVAR LNSdeviationMax=$("root:Packages:IR2L_NLSQF:LNSdeviationMax_pop"+num2str(whichDataSet))
		LNSdeviationMin= varNum*0.5
		LNSdeviationMax=varNum*2
		Execute("SetVariable LNSdeviation,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
		//GW controls
	if(stringmatch(ctrlName,"GMeanSize"))
		//set GMeanSize limits... 
		NVAR GMeanSizeMin=$("root:Packages:IR2L_NLSQF:GMeanSizeMin_pop"+num2str(whichDataSet))
		NVAR GMeanSizeMax=$("root:Packages:IR2L_NLSQF:GMeanSizeMax_pop"+num2str(whichDataSet))
		GMeanSizeMin= varNum*0.5
		GMeanSizeMax=varNum*2
		Execute("SetVariable  GMeanSize,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"GWidth"))
		//set GWidth limits... 
		NVAR GWidthMin=$("root:Packages:IR2L_NLSQF:GWidthMin_pop"+num2str(whichDataSet))
		NVAR GWidthMax=$("root:Packages:IR2L_NLSQF:GWidthMax_pop"+num2str(whichDataSet))
		GWidthMin= varNum*0.5
		GWidthMax=varNum*2
		Execute("SetVariable  GWidth,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
		//SZ controls
	if(stringmatch(ctrlName,"SZMeanSize"))
		//set GMeanSize limits... 
		NVAR GMeanSizeMin=$("root:Packages:IR2L_NLSQF:SZMeanSizeMin_pop"+num2str(whichDataSet))
		NVAR GMeanSizeMax=$("root:Packages:IR2L_NLSQF:SZMeanSizeMax_pop"+num2str(whichDataSet))
		GMeanSizeMin= varNum*0.5
		GMeanSizeMax=varNum*2
		Execute("SetVariable  SZMeanSize,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"SZWidth"))
		//set GWidth limits... 
		NVAR GWidthMin=$("root:Packages:IR2L_NLSQF:SZWidthMin_pop"+num2str(whichDataSet))
		NVAR GWidthMax=$("root:Packages:IR2L_NLSQF:SZWidthMax_pop"+num2str(whichDataSet))
		GWidthMin= varNum*0.5
		GWidthMax=varNum*2
		Execute("SetVariable  SZWidth,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
		//LSW params		
	if(stringmatch(ctrlName,"LSWLocation"))
		//set LSWLocation limits... 
		NVAR LSWLocationMin=$("root:Packages:IR2L_NLSQF:LSWLocationMin_pop"+num2str(whichDataSet))
		NVAR LSWLocationMax=$("root:Packages:IR2L_NLSQF:LSWLocationMax_pop"+num2str(whichDataSet))
		LSWLocationMin= varNum*0.5
		LSWLocationMax=varNum*2
		Execute("SetVariable  LSWLocation,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"StructureParam1"))
		//set LSWLocation limits... 
		NVAR StructureParam1Min=$("root:Packages:IR2L_NLSQF:StructureParam1Min_pop"+num2str(whichDataSet))
		NVAR StructureParam1Max=$("root:Packages:IR2L_NLSQF:StructureParam1Max_pop"+num2str(whichDataSet))
		StructureParam1Min= varNum*0.5
		StructureParam1Max=varNum*2
		Execute("SetVariable  StructureParam1,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"StructureParam2"))
		//set LSWLocation limits... 
		NVAR StructureParam2Min=$("root:Packages:IR2L_NLSQF:StructureParam2Min_pop"+num2str(whichDataSet))
		NVAR StructureParam2Max=$("root:Packages:IR2L_NLSQF:StructureParam2Max_pop"+num2str(whichDataSet))
		StructureParam2Min= varNum*0.5
		StructureParam2Max=varNum*2
		Execute("SetVariable  StructureParam2,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
	//contrasts
	
	setDataFolder OldDf
	IR2L_RecalculateIfSelected() 
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

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	variable whichDataSet
	//BackgStep_set
	ControlInfo/W=LSQF2_MainPanel DataTabs
	whichDataSet= V_Value+1
	if(stringmatch(ctrlName, "BackgStep_set"))
		Execute("SetVariable Background_set,limits={0,Inf,root:Packages:IR2L_NLSQF:BackgStep_set"+num2str(whichDataSet)+"},win=LSQF2_MainPanel")
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
		Execute("SetVariable Background,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")	
		IR2L_RecalculateIfSelected() 
	endif
	if(stringmatch(ctrlName, "UserDataSetName_set"))
		IR2L_FormatLegend()
	endif
	if(stringmatch(ctrlName, "ErrorScalingFactor_set"))
		IR2L_RecalculateErrors(WhichDataSet)
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
	string oldDf=GetDataFolder(1)
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
				Execute("TabControl DataTabs, win=LSQF2_MainPanel, tabLabel("+num2str(i-1)+")=\"\\\\Zr125\\\\K(65535,0,0)"+num2str(i)+".\"")
			else
				Execute("TabControl DataTabs, win=LSQF2_MainPanel, tabLabel("+num2str(i-1)+")=\"\\\\Zr100\\\\K(0,0,0)"+num2str(i)+".\"")
			endif
		endfor
	endif
	For(i=1;i<=10;i+=1)
		NVAR UseTheTab=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(i))
		if(UseTheTab)
			Execute("tabControl DistTabs, win=LSQF2_MainPanel, tabLabel("+num2str(i-1)+")=\"\\\\Zr125\\\\K(65535,0,0)"+num2str(i)+"P\"")
		else
			Execute("tabControl DistTabs, win=LSQF2_MainPanel, tabLabel("+num2str(i-1)+")=\"\\\\Zr100\\\\K(0,0,0)"+num2str(i)+" P\"")
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

	string oldDf=GetDataFolder(1)
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
		Execute("SetVariable RdistManMin,win=LSQF2_MainPanel,disable=("+num2str(RdistAuto)+")")
		Execute("SetVariable RdistManMax,win=LSQF2_MainPanel,disable=("+num2str(RdistAuto)+")")
		Execute("SetVariable RdistNeglectTails,win=LSQF2_MainPanel, disable=(!"+num2str(RdistAuto)+")")
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
		Execute("SetVariable RdistManMin,win=LSQF2_MainPanel,disable=("+num2str(RdistAuto)+")")
		Execute("SetVariable RdistManMax,win=LSQF2_MainPanel,disable=("+num2str(RdistAuto)+")")
		Execute("SetVariable RdistNeglectTails,win=LSQF2_MainPanel, disable=(!"+num2str(RdistAuto)+")")
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
		Execute("SetVariable RdistManMin,win=LSQF2_MainPanel,disable=("+num2str(RdistAuto)+")")
		Execute("SetVariable RdistManMax,win=LSQF2_MainPanel,disable=("+num2str(RdistAuto)+")")
		Execute("SetVariable RdistNeglectTails,win=LSQF2_MainPanel, disable=(!"+num2str(RdistAuto)+")")
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
		Execute("SetVariable Volume,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(Vol*0.05)+"}")	
	endif
		//LN controls...
	if(stringmatch(ctrlName,"LNMinSizeFit"))
		//set LNMinSize limits... 
		NVAR LNMinSize=$("root:Packages:IR2L_NLSQF:LNMinSize_pop"+num2str(whichDataSet))
		NVAR LNMinSizeMin=$("root:Packages:IR2L_NLSQF:LNMinSizeMin_pop"+num2str(whichDataSet))
		NVAR LNMinSizeMax=$("root:Packages:IR2L_NLSQF:LNMinSizeMax_pop"+num2str(whichDataSet))
		LNMinSizeMin= LNMinSize*0.1
		LNMinSizeMax=LNMinSize*10
		Execute("SetVariable LNMinSize,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(LNMinSize*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"LNMeanSizeFit"))
		//set LNMeanSize limits... 
		NVAR LNMeanSize=$("root:Packages:IR2L_NLSQF:LNMeanSize_pop"+num2str(whichDataSet))
		NVAR LNMeanSizeMin=$("root:Packages:IR2L_NLSQF:LNMeanSizeMin_pop"+num2str(whichDataSet))
		NVAR LNMeanSizeMax=$("root:Packages:IR2L_NLSQF:LNMeanSizeMax_pop"+num2str(whichDataSet))
		LNMeanSizeMin= LNMeanSize*0.1
		LNMeanSizeMax=LNMeanSize*10
		Execute("SetVariable LNMeanSize,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(LNMeanSize*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"LNSdeviationFit"))
		//set LNSdeviation limits... 
		NVAR LNSdeviation=$("root:Packages:IR2L_NLSQF:LNSdeviation_pop"+num2str(whichDataSet))
		NVAR LNSdeviationMin=$("root:Packages:IR2L_NLSQF:LNSdeviationMin_pop"+num2str(whichDataSet))
		NVAR LNSdeviationMax=$("root:Packages:IR2L_NLSQF:LNSdeviationMax_pop"+num2str(whichDataSet))
		LNSdeviationMin= LNSdeviation*0.1
		LNSdeviationMax=LNSdeviation*10
		Execute("SetVariable LNSdeviation,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(LNSdeviation*0.05)+"}")
	endif
		//GW controls
	if(stringmatch(ctrlName,"GMeanSizeFit"))
		//set GMeanSize limits... 
		NVAR GMeanSize=$("root:Packages:IR2L_NLSQF:GMeanSize_pop"+num2str(whichDataSet))
		NVAR GMeanSizeMin=$("root:Packages:IR2L_NLSQF:GMeanSizeMin_pop"+num2str(whichDataSet))
		NVAR GMeanSizeMax=$("root:Packages:IR2L_NLSQF:GMeanSizeMax_pop"+num2str(whichDataSet))
		GMeanSizeMin= GMeanSize*0.1
		GMeanSizeMax=GMeanSize*10
		Execute("SetVariable  GMeanSize,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(GMeanSize*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"GWidthFit"))
		//set GWidth limits... 
		NVAR GWidth=$("root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(whichDataSet))
		NVAR GWidthMin=$("root:Packages:IR2L_NLSQF:GWidthMin_pop"+num2str(whichDataSet))
		NVAR GWidthMax=$("root:Packages:IR2L_NLSQF:GWidthMax_pop"+num2str(whichDataSet))
		GWidthMin= GWidth*0.1
		GWidthMax=GWidth*10
		Execute("SetVariable  GWidth,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(GWidth*0.05)+"}")
	endif
		//SZ controls
	if(stringmatch(ctrlName,"SZMeanSizeFit"))
		//set GMeanSize limits... 
		NVAR SZMeanSize=$("root:Packages:IR2L_NLSQF:SZMeanSize_pop"+num2str(whichDataSet))
		NVAR SZMeanSizeMin=$("root:Packages:IR2L_NLSQF:SZMeanSizeMin_pop"+num2str(whichDataSet))
		NVAR SZMeanSizeMax=$("root:Packages:IR2L_NLSQF:SZMeanSizeMax_pop"+num2str(whichDataSet))
		SZMeanSizeMin= SZMeanSize*0.1
		SZMeanSizeMax=SZMeanSize*10
		Execute("SetVariable  SZMeanSize,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(SZMeanSize*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"SZWidthFit"))
		//set GWidth limits... 
		NVAR SZWidth=$("root:Packages:IR2L_NLSQF:SZWidth_pop"+num2str(whichDataSet))
		NVAR SZWidthMin=$("root:Packages:IR2L_NLSQF:SZWidthMin_pop"+num2str(whichDataSet))
		NVAR SZWidthMax=$("root:Packages:IR2L_NLSQF:SZWidthMax_pop"+num2str(whichDataSet))
		SZWidthMin= SZWidth*0.1
		SZWidthMax=SZWidth*10
		Execute("SetVariable  SZWidth,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(SZWidth*0.05)+"}")
	endif
		//LSW params		
	if(stringmatch(ctrlName,"LSWLocationFit"))
		//set LSWLocation limits... 
		NVAR LSWLocation=$("root:Packages:IR2L_NLSQF:LSWLocation_pop"+num2str(whichDataSet))
		NVAR LSWLocationMin=$("root:Packages:IR2L_NLSQF:LSWLocationMin_pop"+num2str(whichDataSet))
		NVAR LSWLocationMax=$("root:Packages:IR2L_NLSQF:LSWLocationMax_pop"+num2str(whichDataSet))
		LSWLocationMin= LSWLocation*0.1
		LSWLocationMax=LSWLocation*10
		Execute("SetVariable  LSWLocation,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(LSWLocation*0.05)+"}")
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
				Execute("CheckBox UF_LinkB, win=LSQF2_MainPanel, value =0")
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

Function IR2L_RecalculateErrors(WhichDataSet)
	variable WhichDataSet
	string oldDf=GetDataFolder(1)
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

	setDataFolder OldDf

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_Initialize()

	string OldDf=GetDataFolder(1)
	setdatafolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S IR2L_NLSQF

	string/g ListOfVariables, ListOfDataVariables, ListOfPopulationVariables, ListOfPopulationVariablesSD, ListOfPopulationVariablesDP, ListOfPopulationVariablesUF
	string/g ListOfStrings, ListOfDataStrings, ListOfPopulationsStrings
	variable i, j
	
	ListOfPopulationsStrings=""	
	ListOfDataStrings=""	

	//here define the lists of variables and strings needed, separate names by ;...
	
	//Main parameters
	ListOfVariables="UseIndra2Data;UseQRSdata;UseSMRData;MultipleInputData;UseNumberDistributions;RecalculateAutomatically;DisplaySinglePopInt;NoFittingLimits;RebinDataTo;"
	ListOfVariables+="SameContrastForDataSets;VaryContrastForDataSets;DisplayInputDataControls;DisplayModelControls;UseGeneticOptimization;UseLSQF;"
	ListOfVariables+="SizeDist_DimensionIsDiameter;"
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;ListOfKnownPeakShapes;"
	ListOfStrings+="DataCalibrationUnits;PanelVolumeDesignation;IntCalibrationUnits;VolDistCalibrationUnits;NumDistCalibrationUnits;"	
	ListOfStrings+="ConfEvListOfParameters;ConEvSelParameter;ConEvMethod;SizeDist_DimensionType;"
	//SizeDist_DimensionType = "Radius" or "Diameter"

	ListOfVariables+="GraphXMin;GraphXMax;GraphYMin;GraphYMax;SizeDistDisplayNumDist;SizeDistDisplayVolDist;"
	ListOfVariables+="SizeDistLogVolDist;SizeDistLogNumDist;SizeDistLogX;"
	ListOfVariables+="ConfEvMinVal;ConfEvMaxVal;ConfEvNumSteps;ConfEvVaryParam;ConfEvChiSq;ConfEvAutoOverwrite;ConfEvFixRanges;"
	ListOfVariables+="ConfEvTargetChiSqRange;ConfEvAutoCalcTarget;"

	//Input Data parameters... Will have _setX attached, in this method background needs to be here...
	ListOfDataVariables="UseTheData;SlitSmeared;SlitLength;Qmin;Qmax;"
	ListOfDataVariables+="Background;BackgroundFit;BackgroundMin;BackgroundMax;BackgErr;BackgStep;"
	ListOfDataVariables+="DataScalingFactor;ErrorScalingFactor;UseUserErrors;UseSQRTErrors;UsePercentErrors;"


	ListOfDataStrings ="FolderName;IntensityDataName;QvecDataName;ErrorDataName;UserDataSetName;"
	
	
	//Common Size distribution Model parameters, these need to have _popX attached at the end of name
	ListOfPopulationVariables="UseThePop;"
	ListOfPopulationVariables+="Contrast;Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"	
		//Form factor parameters
	ListOfPopulationsStrings+="Model;FormFactor;FFUserFFformula;FFUserVolumeFormula;StructureFactor;PopSizeDistShape;SFUserSQFormula;"	

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
	ListOfPopulationVariablesSD+="Volume;VolumeFit;VolumeMin;VolumeMax;Mean;Mode;Median;FWHM;"	
	ListOfPopulationVariablesSD+="LNMinSize;LNMinSizeFit;LNMinSizeMin;LNMinSizeMax;LNMeanSize;LNMeanSizeFit;LNMeanSizeMin;LNMeanSizeMax;LNSdeviation;LNSdeviationFit;LNSdeviationMin;LNSdeviationMax;"	
	ListOfPopulationVariablesSD+="GMeanSize;GMeanSizeFit;GMeanSizeMin;GMeanSizeMax;GWidth;GWidthFit;GWidthMin;GWidthMax;LSWLocation;LSWLocationFit;LSWLocationMin;LSWLocationMax;"	
	ListOfPopulationVariablesSD+="SZMeanSize;SZMeanSizeFit;SZMeanSizeMin;SZMeanSizeMax;SZWidth;SZWidthFit;SZWidthMin;SZWidthMax;"	

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

	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	
//	abort "finish me - IE2L_SetInitialValues"
	string ListOfVariables
	variable i, j
	//here we set what needs to be 0
	//Main parameters
//	ListOfVariables="UseIndra2Data;UseQRSdata;UseSMRData;MultipleInputData;"
//	ListOfVariables+="SameContrastForDataSets;VaryContrastForDataSets;DisplayInputDataControls;DisplayModelControls;"
//	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
//
//	ListOfVariables+="GraphXMin;GraphXMax;GraphYMin;GraphYMax;"
//
//
//	//Input Data parameters... Will have _setX attached, in this method background needs to be here...
//	ListOfDataVariables="UseTheData;SlitSmeared;SlitLength;Qmin;Qmax;"
//	ListOfDataVariables+="Background;BackgroundFit;BackgroundMin;BackgroundMax;BackgErr;BackgStep;"
//	ListOfDataVariables+="DataScalingFactor;ErrorScalingFactor;UseUserErrors;UseSQRTErrors;UsePercentErrors;"
//	ListOfDataStrings ="FolderName;IntensityDataName;QvecDataName;ErrorDataName;UserDataSetName;"
//	
//	
//	//Model parameters, these need to have _popX attached at the end of name
//	ListOfPopulationVariables="UseThePop;"
//		//R distribution parameters
//	ListOfPopulationVariables+="RdistAuto;RdistrSemiAuto;RdistMan;RdistManMin;RdistManMax;RdistLog;RdistNumPnts;RdistNeglectTails;"	
//	ListOfPopulationVariables+="Contrast;Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"	
//		//Form factor parameters
//	ListOfPopulationsStrings+="FormFactor;FFUserFFformula;FFUserVolumeFormula;"	
//	ListOfPopulationVariables+="FormFactor_Param1;FormFactor_Param1Fit;FormFactor_Param1Min;FormFactor_Param1Max;"	
//	ListOfPopulationVariables+="FormFactor_Param2;FormFactor_Param2Fit;FormFactor_Param2Min;FormFactor_Param2Max;"	
//	ListOfPopulationVariables+="FormFactor_Param3;FormFactor_Param3Fit;FormFactor_Param3Min;FormFactor_Param3Max;"	
//	ListOfPopulationVariables+="FormFactor_Param4;FormFactor_Param4Fit;FormFactor_Param4Min;FormFactor_Param4Max;"	
//	ListOfPopulationVariables+="FormFactor_Param5;FormFactor_Param5Fit;FormFactor_Param5Min;FormFactor_Param5Max;"	
//		//Distribution parameters
//	ListOfPopulationVariables+="Volume;VolumeFit;VolumeMin;VolumeMax;"	
//	ListOfPopulationVariables+="LNMinSize;LNMinSizeFit;LNMinSizeMin;LNMinSizeMax;LNMeanSize;LNMeanSizeFit;LNMeanSizeMin;LNMeanSizeMax;LNSdeviation;LNSdeviationFit;LNSdeviationMin;LNSdeviationMax;"	
//	ListOfPopulationVariables+="GMeanSize;GMeanSizeFit;GMeanSizeMin;GMeanSizeMax;GWidth;GWidthFit;GWidthMin;GWidthMax;LSWLocation;LSWLocationFit;LSWLocationMin;LSWLocationMax;"	
//
//	ListOfPopulationsStrings+="PopSizeDistShape;"	

//not done in any way, seems impossible to match meaningful numbers to various SFs. 
//	ListOfPopulationVariables+="StructureParam1;StructureParam1Fit;StructureParam1Min;StructureParam1Max;StructureParam2;StructureParam2Fit;StructureParam2Min;StructureParam2Max;"
//	ListOfPopulationVariables+="StructureParam3;StructureParam3Fit;StructureParam3Min;StructureParam3Max;StructureParam4;StructureParam4Fit;StructureParam4Min;StructureParam4Max;"
//	ListOfPopulationVariables+="StructureParam5;StructureParam5Fit;StructureParam5Min;StructureParam5Max;StructureParam6;StructureParam6Fit;StructureParam6Min;StructureParam6Max;"


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
				testVar=4
			endif
		endfor


	endfor
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
	
	string oldDf=GetDataFolder(1)
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
						TagText="\\Z"+IR2C_LkUpDfltVar("TagSize")+"Size distribution "+num2str(i)+"P\r"
						TagText+="Distribution : "+PopSizeDistShape+"  \r"
						TagText+="Mean / Mode / Median / FWHM  \r"
						TagText+=num2str(MeanVal)+" / "+num2str(ModeVal)+" / "+num2str(MedianVal)+" / "+num2str(FWHMVal)+"  \r"
						//TagText+="Median= "+num2str(MedianVal)+"  \r"
						//TagText+="FWHM = "+num2str(FWHMVal)+"  \r"
//						if(stringMatch(PopSizeDistShape, "Gauss") )
//							LocationPnt = BinarySearch(Qvec, 1.8/GMeanSize )
//							TagText+="Mean = "+num2str(GMeanSize)+"  \r"
//							TagText+="Width = "+num2str(GWidth)+"  \r"
//						elseif(stringMatch(PopSizeDistShape, "LogNormal" ))
//							LocationPnt = BinarySearch(Qvec, 1.8/LNMeanSize )
//							TagText+="Mean = "+num2str(LNMeanSize)+"  \r"
//							TagText+="Min = "+num2str(LNMinSize)+"  \r"
//							TagText+="Deviation = "+num2str(LNSdeviation)+"  \r"
//						else //LSW
//							IR2L_AppendAnyText("DistributionShape"+"\t=\tLSW",0)
//							IR2L_AppendAnyText("LSWLocation"+"\t=\t"+num2str(LSWLocation),0)				
//							LocationPnt = BinarySearch(Qvec, 1.8/LSWLocation )
//							TagText+="Location = "+num2str(LSWLocation)+"  \r"
//						endif

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
						TagText =  RemoveEnding(TagText, "\r" )+"set"+num2str(k)
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
							TagText="\\Z"+IR2C_LkUpDfltVar("TagSize")+"Unified level "+num2str(i)+"P\r"
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
							TagText =  RemoveEnding(TagText, "\r" )
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
							TagText="\\Z"+IR2C_LkUpDfltVar("TagSize")+"Diffraction Peak "+num2str(i)+"P\r"
							TagText+="Shape  :   "+PeakProfile+"\r"
							TagText+="Position (d) = "+num2str(DiffPeakDPos)+"  [A]\r"
							TagText+="Position (Q) = "+num2str(DiffPeakQPos)+"  [A^-1]\r"
							TagText+="Integral intensity = "+num2str(DiffPeakIntgInt)+"\r"
							TagText+="FWHM (Q) = "+num2str(DiffPeakQFWHM)+" [A^-1]"
							TagText =  RemoveEnding(TagText, "\r" )
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
	string oldDf=GetDataFolder(1)
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
	Silent 1
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
	
	Silent 1
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
	string oldDf=GetDataFolder(1)
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

	
	string oldDf=GetDataFolder(1)
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
	Silent 1
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
	
	Silent 1
	if (strsearch(WinList("*",";","WIN:16"),nbL,0)!=-1) 		///Logbook exists
		DoWindow/F $nbl
	else
		NewNotebook/K=3/N=$nbl/F=1/V=1/W=(235.5,44.75,817.5,592.25) as nbl +": Modeling II Output"
		Notebook $nbl defaultTab=144, statusWidth=238, pageMargins={72,72,72,72}
		Notebook $nbl showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nbl newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={2.5*72, 3.5*72 + 8192, 5*72 + 3*8192}, rulerDefaults={"Arial",10,0,(0,0,0)}
		Notebook $nbl ruler=Normal
		Notebook $nbl  justification=1, rulerDefaults={"Arial",14,1,(0,0,0)}
		Notebook $nbl text="This is output of results from Modeling II of Irena package.\r"
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
	
	string OldDf=getDataFOlder(1)
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

	string OldDf=getDataFolder(1)
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
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(405,136,793,600) as "Modeling II uncertainitiy evaluation"
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
	string OldDf=GetDataFOlder(1)
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
	string OldDf=GetDataFOlder(1)
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

	string OldDf=getDataFolder(1)
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

	string OldDf=getDataFolder(1)
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
	
	DoWindow ChisquaredAnalysis
	if(V_Flag)
		DoWindow/K ChisquaredAnalysis
	endif
	DoWindow ChisquaredAnalysis2
	if(V_Flag)
		DoWindow/K ChisquaredAnalysis2
	endif
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
	
	DoWindow ChisquaredAnalysis
	if(V_Flag)
		DoWindow/K ChisquaredAnalysis
	endif
	DoWindow ChisquaredAnalysis2
	if(V_Flag)
		DoWindow/K ChisquaredAnalysis2
	endif
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
	
	DoWindow ChisquaredAnalysis
	if(V_Flag)
		DoWindow/K ChisquaredAnalysis
	endif
	DoWindow ChisquaredAnalysis2
	if(V_Flag)
		DoWindow/K ChisquaredAnalysis2
	endif
	variable levellow, levelhigh

	if(FittedParameter)	//fitted parameter, chi-square analysis needs a bit different... 
		wavestats/Q ChiSquareValues
		variable MeanChiSquare=V_avg
		variable StdDevChiSquare=V_sdev
	
		Display/W=(35,44,555,335)/K=1 ChiSquareValues vs EndValues
		DoWindow/C/T ChisquaredAnalysis,ParamName+"Chi-squared analysis of "+SampleFullName
		Label left "Achieved Chi-squared"
		Label bottom "End "+ParamName+" value"
		ModifyGraph mirror=1
		ModifyGraph mode=3,marker=19
		SetAxis left (V_avg-1.5*(V_avg-V_min)),(V_avg+1.5*(V_max-V_avg))
		
		wavestats/Q EndValues
		variable MeanEndValue=V_avg
		variable StdDevEndValue=V_sdev
		Display/W=(35,44,555,335)/K=1 EndValues vs StartValues
		DoWindow/C/T ChisquaredAnalysis2,ParamName+" reproducibility analysis of "+SampleFullName
		Label left "End "+ParamName+" value"
		Label bottom "Start "+ParamName+" value"
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
		IR1_AppendAnyText("Modeling II uncertainity of parameter "+ParamName, 2)
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
		Label left "Achieved Chi-squared"
		Label bottom ParamName+" value"
		ModifyGraph mirror=1
		ModifyGraph mode=3,marker=19
		Findlevels/Q/N=2 ChiSquareValues, ConfEvTargetChiSqRange*V_min
		if(V_Flag!=0)
			print  "The range of parameters analyzed for "+ParamName +" was not sufficiently large, code did not find large enough values for chi-squared"
			IR1_CreateResultsNbk()
//			IR1_AppendAnyText("Analyzed sample "+SampleFullName, 1)	
			IR1_AppendAnyText("Modeling II evaluation of parameter "+ParamName+" failed", 2)
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
			IR1_AppendAnyText("Modeling II Evaluation of parameter "+ParamName, 2)
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
	
	string OldDf=getDataFolder(1)
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
			else		//diffraction  peak
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
			Execute("SetVariable ParameterMin,win=IR2L_ConfEvaluationPanel, limits={0, "+num2str(Curpar)+", "+num2str(0.05*Curpar)+"}")
			Execute("SetVariable ParameterMax,win=IR2L_ConfEvaluationPanel, limits={"+num2str(Curpar)+", inf, "+num2str(0.05*Curpar)+"}")
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

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	variable i

	if(stringmatch(ctrlName,"Continue_SDDetails"))
		DoWindow/K LSQF2_ModelingII_MoreDetails
	endif

	if(cmpstr(ctrlName,"RemovePointWcsrA")==0)
		//here we load the data and create default values
		ControlInfo/W=LSQF2_MainPanel DataTabs
		//IR2L_LoadDataIntoSet(V_Value+1,0)
		//NVAR UseTheData_set=$("UseTheData_set"+num2str(V_Value+1))
		//UseTheData_set=1
		IR2L_Data_TabPanelControl("",V_Value)
		if(IR2L_RemovePntCsrA(V_Value))
			IR2L_RecalculateIfSelected()
		endif
		//IR2L_AppendDataIntoGraph(V_Value+1)
		//IR2L_AppendOrRemoveLocalPopInts()
		//IR2L_FormatInputGraph()
		//IR2L_FormatLegend()
		//DoWIndow LSQF_MainGraph
		//if(V_Flag)
			//AutoPositionWindow/R=LSQF2_MainPanel LSQF_MainGraph
		//endif
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
		//next needs to be done to set teh controls correctly... 
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
		ControlInfo /W=LSQF2_MainPanel FormFactorPop 
		//print S_Value
		DisplayHelpTopic /Z "Form Factors & Structure factors["+S_Value+"]"
		if(V_Flag)
			DisplayHelpTopic /Z "Form Factors & Structure factors"
		endif
	endif
	if(stringmatch(ctrlName,"GetSFHelp"))
		ControlInfo /W=LSQF2_MainPanel StructureFactorModel 
		if(Stringmatch(S_Value,"Dilute system"))
			DisplayHelpTopic /Z "Form Factors & Structure factors"	
		else
			//print S_Value
			DisplayHelpTopic /Z "Form Factors & Structure factors["+S_Value+"]"
			if(V_Flag)
				DisplayHelpTopic /Z "Form Factors & Structure factors"
			endif
		endif
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
		IR2L_SaveResultsInDataFolder(0)
	endif
	if(cmpstr(ctrlName,"SaveInDataFolderSkipDialog")==0)
		IR2L_SaveResultsInDataFolder(1)
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
		PauseForUser IR2C_MainConfigPanel
		IR2L_FormatInputGraph()
		IR2L_FormatLegend()
	endif
	if(cmpstr(ctrlName,"ReGraph")==0)
		DoWindow LSQF_MainGraph
		if(V_Flag)
			DoWindow/K LSQF_MainGraph
		endif
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

	string oldDf=GetDataFolder(1)
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
		IR2L_RecalculateErrors(WhichDataSet)
	endif
	if (stringMatch(ctrlName,"UseSQRTErrors_set"))
		if(UseSQRTErrors_set)
			UseUserErrors_set=0
			UsePercentErrors_set=0
		else
			UseUserErrors_set=0
			UsePercentErrors_set=1
		endif	
		IR2L_RecalculateErrors(WhichDataSet)
	endif
	if (stringMatch(ctrlName,"UsePercentErrors_set"))
		if(UsePercentErrors_set)
			UseUserErrors_set=0
			UseSQRTErrors_set=0
		else
			UseUserErrors_set=0
			UseSQRTErrors_set=1
		endif	
		IR2L_RecalculateErrors(WhichDataSet)
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


	ControlInfo/W=LSQF2_MainPanel DataTabs
	IR2L_Data_TabPanelControl("",V_Value)
	DoWindow/F LSQF2_MainPanel
	DoWIndow LSQF2_ModelingII_MoreDetails
	if(V_Flag)
		DoWIndow/F LSQF2_ModelingII_MoreDetails
	endif
	setDataFolder OldDf
end
