#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method.
#pragma version=1.12    	//this is Irena package Guinier-Porod model based on Hammouda's paper
Constant IR3GPversionNumber=1.08

//*************************************************************************\
//* Copyright (c) 2005 - 2022, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/
//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from usaxs.xray.aps.anl.gov/
//Jan Ilavsky, February 2013
//please, read Readme distributed with the package
//report any problems to: ilavsky@aps.anl.gov 

// J. Appl. Cryst. (2010). 43, 716–719, Boualem Hammouda, A new Guinier–Porod model


//version history
//1.12 Fixed fitting issue where fitting data in small Q range (at low-Q) failed. It was working for large Q range. FIxed by always calculating full data Q range and using subset for fitting. 
//1.11 Added ability to export Level fits (Int-Q) which was missing before.  Adds Level0 which is simply flat background wave. 
//1.10 2019-05 Testing, fixes for Correlation fitting parameters (were not fitted at all) and some fixes to Uncertainty evaluation, was misbehaving. 
//		fixed some error messages and GUI. 
//1.09 modified graph size scaling for screen size using IN2G_GetGraphWidthHeight 
//1.08 modified fitting to include Igor display with iterations /N=0/W=0
//1.07 added getHelp button calling to www manual
//1.06 GUI controls move change
//1.05 changes for panel scaling. 
//1.04 Igor 7 changes
//1.03 removed Executes as preparation for Igor 7
//1.02 added check for qmax when fitting slit smeared data and fixed minor slitlength setvariable bug (it was trying to set limits...)
//1.01 	added check that Scripting tool does not have "UseResults" selected. This caused bug with two different types of data selected in ST.
//1.00 first release, July 2013
//0.94 fixed bug which caused major problems fitting SMR data. Improvemnts of starting values for local fits. 
//0.93 Fixed bug which caused Scripting tool to get out of sync with main panel. 
//0.92 More code developemnt, added Uncertainity evaluation and scripting tool. 
//0.91 GUI improvements, local fits improvements. 
//0.9 - original release, unfinished, barely functional, no manual support. 

//Menu "SAS"
//	"Guinier Porod Fit", IR3GP_Main()
//	help = {"Modeling of SAS as Guinier and Power law dependecies, based on Guinier-Porod model by Bualem Hammouda"}
//end
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************


// G1 - scaling factor G (~volume)
// Rg1 - radius of gyration
// Rg2 - radius of gyration larger dimension, Rg2>Rg1
// d - Porod exponent
// s1 - low-q shape slope ( = 0 for sphere, rod =1, platelet = 2)
// s2 - lower-q shape slope ( = 0 for sphere, rod =1, platelet = 2)

// for spherical objects (s=0)...
// for Q<Q1		: 	I(Q) = G*exp(-Q^2 * Rg^2 / 3)
// for Q>=Q1 	: 	I(Q) = D / Q^d
// Q1 = sqrt(3*d/2) / Rg
// D = G * exp(-Q1^2 * Rg^2/3)*Q1^d = G*exp(-d/2)*(3*d/2)^(d/2) /Rg^d
//
//for non spherical (infinitely large) objects (s!=0)
// for Q<Q1		: 	I(Q) = G/Q^s * exp(-Q^2 * Rg^2 / (3-s))
// for Q>=Q1 	: 	I(Q) = D / Q^d
// Q1 = sqrt((d - s)*(3 - s)/2) / Rg
// D = G * exp(-Q1^2 * Rg^2/(3-s))*Q1^(d-s) = G*exp(-(d-s)/2)*((3-s)*(d-s)/2)^((d-s)/2) /Rg^(d-s)
//
//for non spherical (infinitely large) objects with two Guinier areas - (s1!=0, s1!=0)
// for Q<Q2		: 	I(Q) = G2/Q2^s2 * exp(-Q^2 * Rg2^2 / (3-s2))
// for Q<Q1		: 	I(Q) = G1/Q^s1 * exp(-Q^2 * Rg1^2 / (3-s1))
// for Q>=Q1 	: 	I(Q) = D / Q^d
// Q2 = sqrt((1 - s2)/((2/(3-s2)*Rg2^2) - (2/(3-s1))*Rg1^2) )
// G2 = G1* exp(-Q2^2*((Rg1^2/(3-s1))-(Rg2^2/(3-s2)))) * Q2^(s2-s1)
// Q1 = sqrt((d - s)*(3 - s)/2) / Rg
// D = G * exp(-Q1^2 * Rg^2/(3-s))*Q1^(d-s) = G*exp(-(d-s)/2)*((3-s)*(d-s)/2)^((d-s)/2) /Rg^(d-s)
//
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************

structure GuinierPorodLevel
	variable  G
	int16  GFit
	variable  GLowLimit
	variable  GHighLimit
	variable  GError
	variable  Rg1
	int16  Rg1Fit
	variable  Rg1LowLimit
	variable  Rg1HighLimit
	variable  Rg1Error
	variable  Rg2
	int16  Rg2Fit
	variable  Rg2LowLimit
	variable  Rg2HighLimit
	variable  Rg2Error
	variable  P
	int16  PFit
	variable  PLowLimit
	variable  PHighLimit
	variable  PError
	variable  s1
	int16  s1Fit
	variable  s1LowLimit
	variable  s1HighLimit
	variable  s1Error
	variable  s2
	int16  s2Fit
	variable  s2LowLimit
	variable  s2HighLimit
	variable  s2Error
	variable  RgCutOff
	int16  UseCorrelations
	variable  ETA
	int16  ETAfit
	variable  ETALowLimit
	variable  ETAHighLimit
	variable  ETAError
	variable  PACK
	int16  PACKfit
	variable  PACKLowLimit
	variable  PACKHighLimit
	variable  PACKError

	variable  Invariant
	
EndStructure
//******************************************************************************************
//******************************************************************************************
Function IR3GP_MoveStrToGlobals(Par)
	STRUCT GuinierPorodLevel &Par

	string OldDf = GetDataFolder(1)
	setDataFolder root:Packages:Irena:GuinierPorod
	NVAR Level_G
	Level_G = Par.G
	NVAR Level_GFit
	Level_GFit = Par.GFit
	NVAR Level_GLowLimit
	Level_GLowLimit = Par.GLowLimit
	NVAR Level_GHighLimit
	Level_GHighLimit = Par.GHighLimit
	NVAR Level_GError
	Level_GError = Par.GError

	NVAR Level_Rg1
	Level_Rg1 = Par.Rg1
	NVAR Level_Rg1Fit
	Level_Rg1Fit = Par.Rg1Fit
	NVAR Level_Rg1LowLimit
	Level_Rg1LowLimit = Par.Rg1LowLimit
	NVAR Level_Rg1HighLimit
	Level_Rg1HighLimit = Par.Rg1HighLimit
	NVAR Level_Rg1Error
	Level_Rg1Error = Par.Rg1Error

	NVAR Level_Rg2
	Level_Rg2 = Par.Rg2
	NVAR Level_Rg2Fit
	Level_Rg2Fit = Par.Rg2Fit
	NVAR Level_Rg2LowLimit
	Level_Rg2LowLimit = Par.Rg2LowLimit
	NVAR Level_Rg2HighLimit
	Level_Rg2HighLimit = Par.Rg2HighLimit
	NVAR Level_Rg2Error
	Level_Rg2Error = Par.Rg2Error

	NVAR Level_P
	Level_P = Par.P
	NVAR Level_PFit
	Level_PFit = Par.PFit
	NVAR Level_PLowLimit
	Level_PLowLimit = Par.PLowLimit
	NVAR Level_PHighLimit
	Level_PHighLimit = Par.PHighLimit
	NVAR Level_PError
	Level_PError = Par.PError

	NVAR Level_S1
	Level_S1 = Par.S1
	NVAR Level_S1Fit
	Level_S1Fit = Par.S1Fit
	NVAR Level_S1LowLimit
	Level_S1LowLimit = Par.S1LowLimit
	NVAR Level_S1HighLimit
	Level_S1HighLimit = Par.S1HighLimit
	NVAR Level_S1Error
	Level_S1Error = Par.S1Error
	
	NVAR Level_S2
	Level_S2 = Par.S2
	NVAR Level_S2Fit
	Level_S2Fit = Par.S2Fit
	NVAR Level_S2LowLimit
	Level_S2LowLimit = Par.S2LowLimit
	NVAR Level_S2HighLimit
	Level_S2HighLimit = Par.S2HighLimit
	NVAR Level_S2Error
	Level_S2Error = Par.S2Error
	
	NVAR Level_RgCutOff
	Level_RgCutOff = Par.RgCutOff

	NVAR Level_UseCorrelations
	Level_UseCorrelations = Par.UseCorrelations

	NVAR Level_PACK
	Level_PACK = Par.PACK
	NVAR Level_PACKFit
	Level_PACKFit = Par.PACKFit
	NVAR Level_PACKLowLimit
	Level_PACKLowLimit = Par.PACKLowLimit
	NVAR Level_PACKHighLimit
	Level_PACKHighLimit = Par.PACKHighLimit
	NVAR Level_PACKError
	Level_PACKError = Par.PACKError

	NVAR Level_ETA
	Level_ETA = Par.ETA
	NVAR Level_ETAFit
	Level_ETAFit = Par.ETAFit
	NVAR Level_ETALowLimit
	Level_ETALowLimit = Par.ETALowLimit
	NVAR Level_ETAHighLimit
	Level_ETAHighLimit = Par.ETAHighLimit
	NVAR Level_ETAError
	Level_ETAError = Par.ETAError
	NVAR Invariant
	Invariant = Par.Invariant
	setDataFolder oldDF
end
//******************************************************************************************
//******************************************************************************************
Function IR3GP_MoveGlobalsToStr(Par)
	STRUCT GuinierPorodLevel &Par

	string OldDf = GetDataFolder(1)
	setDataFolder root:Packages:Irena:GuinierPorod
	NVAR Level_G
	 Par.G = Level_G
	NVAR Level_GFit
	 Par.GFit = Level_GFit
	NVAR Level_GLowLimit
	 Par.GLowLimit = Level_GLowLimit
	NVAR Level_GHighLimit
	 Par.GHighLimit = Level_GHighLimit
	NVAR Level_GError
	 Par.GError = Level_GError

	NVAR Level_Rg1
	 Par.Rg1  = Level_Rg1
	NVAR Level_Rg1Fit
	 Par.Rg1Fit = Level_Rg1Fit
	NVAR Level_Rg1LowLimit
	 Par.Rg1LowLimit = Level_Rg1LowLimit
	NVAR Level_Rg1HighLimit
	 Par.Rg1HighLimit = Level_Rg1HighLimit
	NVAR Level_Rg1Error
	 Par.Rg1Error = Level_Rg1Error

	NVAR Level_Rg2
	 Par.Rg2 = Level_Rg2
	NVAR Level_Rg2Fit
	 Par.Rg2Fit = Level_Rg2Fit
	NVAR Level_Rg2LowLimit
	 Par.Rg2LowLimit = Level_Rg2LowLimit
	NVAR Level_Rg2HighLimit
	 Par.Rg2HighLimit = Level_Rg2HighLimit
	NVAR Level_Rg2Error
	 Par.Rg2Error = Level_Rg2Error

	NVAR Level_P
	 Par.P = Level_P
	NVAR Level_PFit
	 Par.PFit = Level_PFit
	NVAR Level_PLowLimit
	 Par.PLowLimit = Level_PLowLimit
	NVAR Level_PHighLimit
	 Par.PHighLimit = Level_PHighLimit
	NVAR Level_PError
	 Par.PError = Level_PError

	NVAR Level_S1
	 Par.S1 = Level_S1
	NVAR Level_S1Fit
	 Par.S1Fit = Level_S1Fit
	NVAR Level_S1LowLimit
	 Par.S1LowLimit = Level_S1LowLimit
	NVAR Level_S1HighLimit
	 Par.S1HighLimit = Level_S1HighLimit
	NVAR Level_S1Error
	 Par.S1Error = Level_S1Error
	
	NVAR Level_S2
	 Par.S2 = Level_S2
	NVAR Level_S2Fit
	 Par.S2Fit = Level_S2Fit
	NVAR Level_S2LowLimit
	 Par.S2LowLimit = Level_S2LowLimit
	NVAR Level_S2HighLimit
	 Par.S2HighLimit = Level_S2HighLimit
	NVAR Level_S2Error
	 Par.S2Error = Level_S2Error
	
	NVAR Level_RgCutOff
	 Par.RgCutOff = Level_RgCutOff

	NVAR Level_UseCorrelations
	 Par.UseCorrelations = Level_UseCorrelations
	
	NVAR Level_ETA
	 Par.ETA = Level_ETA
	NVAR Level_ETAFit
	 Par.ETAFit = Level_ETAFit
	NVAR Level_ETALowLimit
	 Par.ETALowLimit = Level_ETALowLimit
	NVAR Level_ETAHighLimit
	 Par.ETAHighLimit = Level_ETAHighLimit
	NVAR Level_ETAError
	 Par.ETAError = Level_ETAError
	
	NVAR Level_PACK
	 Par.PACK = Level_PACK
	NVAR Level_PACKFit
	 Par.PACKFit = Level_PACKFit
	NVAR Level_PACKLowLimit
	 Par.PACKLowLimit = Level_PACKLowLimit
	NVAR Level_PACKHighLimit
	 Par.PACKHighLimit = Level_PACKHighLimit
	NVAR Level_PACKError
	 Par.PACKError = Level_PACKError	
	NVAR Invariant
	 Par.Invariant = Invariant
	setDataFolder oldDF
	
end
//******************************************************************************************
//******************************************************************************************
Function IR3GP_MoveLevelToWave(level)
	variable level
	
	STRUCT GuinierPorodLevel Par
	IR3GP_MoveGlobalsToStr(Par)
	Wave LevelStructure = $("root:Packages:Irena:GuinierPorod:Level"+num2str(level)+"Structure")
	StructPut Par, LevelStructure
end
//******************************************************************************************
//******************************************************************************************
Function IR3GP_LoadLevelFromWave(level)
	variable level
	
	STRUCT GuinierPorodLevel Par
	Wave LevelStructure = $("root:Packages:Irena:GuinierPorod:Level"+num2str(level)+"Structure")
	StructGet Par, LevelStructure
	IR3GP_MoveStrToGlobals(Par)
end
//******************************************************************************************
//******************************************************************************************
Function IR3GP_SaveStructureToWave(Par, level)
	STRUCT GuinierPorodLevel &Par
	variable level
	if(level>0)	
		Wave LevelStructure = $("root:Packages:Irena:GuinierPorod:Level"+num2str(level)+"Structure")
		StructPut Par, LevelStructure
	endif
end
//******************************************************************************************
//******************************************************************************************
Function IR3GP_LoadStructureFromWave(Par, level)
	STRUCT GuinierPorodLevel &Par
	variable level
	if(level>0)
		Wave LevelStructure = $("root:Packages:Irena:GuinierPorod:Level"+num2str(level)+"Structure")
		StructGet Par, LevelStructure
	endif
end
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************

Function IR2GP_CalculateGPlevel(Qvector,Intensity,Par )
	wave Qvector, Intensity
	STRUCT GuinierPorodLevel &Par

//for non spherical (infinitely large) objects with two Guinier areas - (s1!=0, s2=0)
// for Q<Q2		: 	I(Q) = G2/Q2^s2 * exp(-Q^2 * Rg2^2 / (3-s2))
// for Q<Q1		: 	I(Q) = G1/Q^s1 * exp(-Q^2 * Rg1^2 / (3-s1))
// for Q>=Q1 	: 	I(Q) = D / Q^d
// Q2 = sqrt((1 - s2)/((2/(3-s2)*Rg2^2) - (2/(3-s1))*Rg1^2) )
// G2 = G1* exp(-Q2^2*((Rg1^2/(3-s1))-(Rg2^2/(3-s2)))) * Q2^(s2-s1)
// Q1 = sqrt((d - s1)*(3 - s1)/2) / Rg1
// D = G * exp(-Q1^2 * Rg^2/(3-s))*Q1^(d-s) = G*exp(-(d-s)/2)*((3-s)*(d-s)/2)^((d-s)/2) /Rg^(d-s)
	variable Q1val = sqrt((Par.P - Par.s1)*(3 - Par.s1)/2) / Par.Rg1
	variable Dval=Par.G*exp(-(Par.P-Par.s1)/2)*((3-Par.s1)*(Par.P-Par.s1)/2)^((Par.P-Par.s1)/2) /Par.Rg1^(Par.P-Par.s1)
	variable Q2val = sqrt((1 - Par.s2)/((2/(3-Par.s2)*Par.Rg2^2) - (2/(3-Par.s1))*Par.Rg1^2) )
	Q2val = numtype(Q2val)==0 ? Q2val : 0
	variable G2val = Par.G * exp(-Q2val^2*((Par.Rg1^2/(3-Par.s1))-(Par.Rg2^2/(3-Par.s2)))) * Q2val^(Par.s2-Par.s1)
	variable LowQRangePntMax, MidQRangePntMax
	LowQRangePntMax = BinarySearch(Qvector, Q2val )
	MidQRangePntMax = BinarySearch(Qvector, Q1val )
	Intensity = 0
	if(LowQRangePntMax>0)
		Intensity[0,LowQRangePntMax] = G2val/(Qvector[p]^Par.s2) * exp(-1 * Qvector[p]^2 * Par.Rg2^2 / (3-Par.s2))
	endif
	if(MidQRangePntMax>0)
		Intensity[LowQRangePntMax+1,MidQRangePntMax] = Par.G/(Qvector[p]^Par.s1) * exp(-1 * Qvector[p]^2 * Par.Rg1^2 / (3-Par.s1))
		Intensity[MidQRangePntMax+1,] = Dval / (Qvector[p]^Par.P)
	else			//if(MidQRangePntMax<0)	// 2021-12-06 this elseif causes issues in rare cases when Q2val=0. 
		Intensity = Dval / (Qvector[p]^Par.P)
	endif

	if(Par.RgCutOff>0)
		Intensity*= exp(-1 * Par.RgCutOff^2 * Qvector^2/3)
	endif
	if (Par.UseCorrelations)
		Intensity/=(1+Par.pack*IR1A_SphereAmplitude(Qvector,Par.ETA))
	endif
	
end
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************

Function IR2GP_CalculateGPValue(Qval,Pval,Rg1,Gval,S1,Rg2,S2,Background)
	variable Qval,Pval,Rg1,Gval,S1,Rg2,S2,Background
//for non spherical (infinitely large) objects with two Guinier areas - (s1!=0, s2=0)
// for Q<Q2		: 	I(Q) = G2/Q2^s2 * exp(-Q^2 * Rg2^2 / (3-s2))
// for Q<Q1		: 	I(Q) = G1/Q^s1 * exp(-Q^2 * Rg1^2 / (3-s1))
// for Q>=Q1 	: 	I(Q) = D / Q^d
// Q2 = sqrt((1 - s2)/((2/(3-s2)*Rg2^2) - (2/(3-s1))*Rg1^2) )
// G2 = G1* exp(-Q2^2*((Rg1^2/(3-s1))-(Rg2^2/(3-s2)))) * Q2^(s2-s1)
// Q1 = sqrt((d - s1)*(3 - s1)/2) / Rg1
// D = G * exp(-Q1^2 * Rg^2/(3-s))*Q1^(d-s) = G*exp(-(d-s)/2)*((3-s)*(d-s)/2)^((d-s)/2) /Rg^(d-s)
	variable Q1val = sqrt((Pval - S1)*(3 - S1)/2) / Rg1
	variable Dval=Gval*exp(-(Pval-S1)/2)*((3-S1)*(Pval-S1)/2)^((Pval-S1)/2) /Rg1^(Pval-S1)
	variable Q2val = sqrt((1 - S2)/((2/(3-S2)*Rg2^2) - (2/(3-S1))*Rg1^2) )
	variable G2val = Gval * exp(-Q2val^2*((Rg1^2/(3-S1))-(Rg2^2/(3-S2)))) * Q2val^(S2-S1)
// for Q<Q2		: 	I(Q) = G2/Q2^s2 * exp(-Q^2 * Rg2^2 / (3-s2))
// for Q<Q1		: 	I(Q) = G1/Q^s1 * exp(-Q^2 * Rg1^2 / (3-s1))
// for Q>=Q1 	: 	I(Q) = D / Q^d
	wave Qvec=root:Packages:Irena:GuinierPorod:OriginalQvector
	Duplicate/FREE Qvec, TempInt
	STRUCT GuinierPorodLevel Par
	par.G=Gval
	par.Rg1=Rg1
	par.Rg2=Rg2
	par.P=Pval
	par.s1=S1
	par.s2=S2
	par.RgCutOff=0
	par.UseCorrelations=0
	par.ETA=0
	par.PACK=0
	IR2GP_CalculateGPlevel(Qvec,TempInt,Par )

	NVAR UseSMRData=root:Packages:Irena:GuinierPorod:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena:GuinierPorod:SlitLengthUnif
	if(UseSMRData)
		duplicate/Free  TempInt, TempIntSMR
		IR1B_SmearData(TempInt, Qvec, SlitLengthUnif, TempIntSMR)
		TempInt=TempIntSMR
	endif

	return tempInt[BinarySearch(Qvec, Qval)]
//	if(Qval>=Q1val)
//		return Dval/Qval^Pval
//	elseif(Qval>Q2val || numtype(Q2val)!=0)
//		return Gval/Qval^S1 * exp(-Qval^2 * Rg1^2 / (3-S1))
//	else
//		return G2val/Q2val^s2 * exp(-Qval^2 * Rg2^2 / (3-s2))
//	endif

//	if(Par.RgCutOff>0)
//		Intensity*= exp(-1 * Par.RgCutOff^2 * Qvector^2/3)
//	endif
//	if (Par.UseCorrelations)
//		Intensity/=(1+Par.pack*IR1A_SphereAmplitude(Qvector,Par.ETA))
//	endif
	
end

//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************

Function IR3GP_Main()	
	//initialize, as usually
	IR3GP_Initialize(0)
	IR1_CreateLoggbook()
	//IR2L_SetInitialValues(1)
	//we need the following also inited
	IN2G_InitConfigMain()
	//check for panel if exists - pull up, if not create
	DoWindow IR3DP_MainPanel
	if(V_Flag)
		DoWindow/F IR3DP_MainPanel
	else
		IR3DP_MainPanelFunction()
		ING2_AddScrollControl()
		IR1_UpdatePanelVersionNumber("IR3DP_MainPanel", IR3GPversionNumber,1)
	endif
	//IR2L_RecalculateIfSelected()
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR3GP_MainCheckVersion()	
	DoWindow IR3DP_MainPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR3DP_MainPanel", IR3GPversionNumber))
			DoAlert /T="The Guinier-Porod panel was created by incorrect version of Irena " 1, "Guinier Porod tool may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				KillWIndow/Z IR3DP_MainPanel
				IR3GP_Main()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR3GP_Initialize(0)					//this may be OK now... 
			endif
		endif
	endif
end
 
//*****************************************************************************************************************
//*****************************************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************

Function IR3DP_MainPanelFunction()
	//PauseUpdate    		// building window...
	NewPanel /K=1 /W=(3,42,410,730) as "Guinier-Porod main panel"
	DoWindow/C IR3DP_MainPanel
	DefaultGUIControls /W=IR3DP_MainPanel ///Mac os9
	
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("Irena:GuinierPorod","IR3DP_MainPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 1,1)
	TitleBox MainTitle title="\Zr240Guinier Porod",pos={100,0},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={200,24},anchor=MC,fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,176},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info1 title="\Zr160Data input",pos={10,30},frame=0,fstyle=1, fixedSize=1,size={80,20},fColor=(0,0,52224)
	TitleBox Info2 title="\Zr160Guinier-Porod model input",pos={10,185},frame=0,fstyle=2, fixedSize=1,size={200,20}
	TitleBox Info3 title="\Zr120Fit?  Low limit:    High Limit:",pos={200,262},frame=0,fstyle=2, fixedSize=0,size={20,15},fstyle=3,fColor=(0,0,65535)
	TitleBox Info4 title="\Zr120Fit using least square fitting ?",pos={3,584},frame=0,fstyle=2, fixedSize=0,size={120,15},fstyle=3,fColor=(0,0,65535)
	TitleBox FakeLine2 title=" ",fixedSize=1,size={20,3},pos={330,610},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info5 title="\Zr140Results:",pos={3,625},frame=0,fstyle=2, fixedSize=0,size={120,15},fstyle=3,fColor=(0,0,65535)
//	TitleBox Info6 title="For local fits, set S2=0, Rg2=1e10, S1=0",pos={10,443},frame=0,fstyle=2, fixedSize=0,size={120,15},fSize=10
//	TitleBox Info7 title="And follow order of the buttons --->",pos={10,459},frame=0,fstyle=2, fixedSize=0,size={120,15},fSize=10
	TitleBox Info6 title="\Zr120For local fits follow order of the buttons --->",pos={10,443},frame=0,fstyle=2, fixedSize=0,size={120,15}
//	TitleBox Info7 title="And follow order of the buttons --->",pos={10,459},frame=0,fstyle=2, fixedSize=0,size={120,15},fSize=10
	NVAR Level_G = root:Packages:Irena:GuinierPorod:Level_G
	NVAR Level_S2 = root:Packages:Irena:GuinierPorod:Level_S2
	NVAR Level_Rg2 = root:Packages:Irena:GuinierPorod:Level_Rg2
	NVAR Level_S1 = root:Packages:Irena:GuinierPorod:Level_S1
	NVAR Level_Rg1 = root:Packages:Irena:GuinierPorod:Level_Rg1
	NVAR Level_P = root:Packages:Irena:GuinierPorod:Level_P
	NVAR NumberOfLevels=root:Packages:Irena:GuinierPorod:NumberOfLevels
	NVAR SASBackground = root:Packages:Irena:GuinierPorod:SASBackground
	NVAR UseSMRData=root:Packages:Irena:GuinierPorod:UseSMRData

	//Experimental data input
	CheckBox UseSMRData,pos={170,40},size={141,14},proc=IR3GP_PanelCheckboxProc,title="SMR data"
	CheckBox UseSMRData,variable= root:Packages:Irena:GuinierPorod:UseSMRData, help={"Check, if you are using slit smeared data"}
	SetVariable SlitLength,limits={0,Inf,0},value= root:Packages:Irena:GuinierPorod:SlitLengthUnif, disable=!UseSMRData
	SetVariable SlitLength,pos={260,40},size={100,16},title="SL=",proc=IR3GP_PanelSetVarProc, help={"slit length"}
	Button DrawGraphs,pos={5,150},size={100,20},proc=IR3GP_PanelButtonProc,title="Graph data", help={"Create a graph (log-log) of your experiment data"}
	Button GraphDistribution,pos={5,210},size={90,20},proc=IR3GP_PanelButtonProc,title="Graph Model", help={"Add results of your model in the graph with data"}
	Button ScriptingTool,pos={280,155},size={100,15},proc=IR3GP_PanelButtonProc,title="Scripting tool", help={"Script this tool for multiple data sets processing"}
	Button GetHelp,pos={305,105},size={80,15},fColor=(65535,32768,32768), proc=IR3GP_PanelButtonProc,title="Get Help", help={"Open www manual page for this tool"}
	CheckBox UpdateAutomatically,pos={110,205},size={225,14},proc=IR3GP_PanelCheckboxProc,title="Update automatically?"
	CheckBox UpdateAutomatically,variable= root:Packages:Irena:GuinierPorod:UpdateAutomatically, help={"When checked the graph updates automatically anytime you make change in model parameters"}
	CheckBox UseNoLimits,pos={275,205},size={63,14},proc=IR3GP_PanelCheckboxProc,title="No limits?"
	CheckBox UseNoLimits,variable= root:Packages:Irena:GuinierPorod:UseNoLimits, help={"Check if you want to fit without use of limits"}
	CheckBox DisplayLocalFits,pos={110,220},size={225,14},proc=IR3GP_PanelCheckboxProc,title="Display local (Porod & Guinier) fits?"
	CheckBox DisplayLocalFits,variable= root:Packages:Irena:GuinierPorod:DisplayLocalFits, help={"Check to display in graph local Porod and Guinier fits for selected level, fits change with changes in values of P, B, Rg and G"}

	Button DoFitting,pos={175,584},size={70,20},proc=IR3GP_PanelButtonProc,title="Fit", help={"Do least sqaures fitting of the whole model, find good starting conditions and proper limits before fitting"}
	Button RevertFitting,pos={255,584},size={100,20},proc=IR3GP_PanelButtonProc,title="Revert back",help={"Return back befoire last fitting attempt"}
	Button FixLimits,pos={93,605},size={80,16},proc=IR3GP_PanelButtonProc,title="Fix limits?", help={"Reset variables to default values?"}
	Button MarkGraphs,pos={277,623},size={110,20},proc=IR3GP_PanelButtonProc,title="Results -> graphs", help={"Insert text boxes with results into the graphs for printing"}
	Button CopyToFolder,pos={5,645},size={130,20},proc=IR3GP_PanelButtonProc,title="Store in Data Folder", help={"Copy results of the modeling into original data folder"}
	Button CleanupGraph,pos={277,645},size={110,20},proc=IR3GP_PanelButtonProc,title="Clean graph", help={"Remove text boxes with results into the graphs for printing"}


	Button ConfidenceEvaluation,pos={150,645},size={120,20},proc=IR3GP_PanelButtonProc,title="Uncertainity Eval.", help={"Analyze confidence range for different parameters"}
	SetVariable SASBackground,pos={15,565},size={160,16},proc=IR3GP_PanelSetVarProc,title="SAS Background", help={"SAS background"},bodyWidth=80, format="%0.4g"
	SetVariable SASBackground,limits={-inf,Inf,0.05*SASBackground},value= root:Packages:Irena:GuinierPorod:SASBackground
	CheckBox FitBackground,pos={195,566},size={63,14},proc=IR3GP_PanelCheckboxProc,title="Fit Bckg?"
	CheckBox FitBackground,variable= root:Packages:Irena:GuinierPorod:FitSASBackground, help={"Check if you want the background to be fitting parameter"}
	Button LevelXFitRg1AndG,pos={240,420},size={120,18}, proc=IR3GP_PanelButtonProc,title="1. \\JL     Fit Rg1/G w/csrs", help={"Do local fit of Guinier dependence between the cursors amd put resulting values into the Rg and G fields"}
	Button LevelXFitPAndB,pos={240,439},size={120,18}, proc=IR3GP_PanelButtonProc,title="2. \\JL     Fit P w/csrs", help={"Do Power law fitting between the cursors and put resulting parameters in the P and B fields"}
	Button LevelXFitS1,pos={240,458},size={120,18}, proc=IR3GP_PanelButtonProc,title="3. \\JL     Fit S1 w/csrs", help={"Do Power law fitting between the cursors and put resulting parameters in the P and B fields"}
	Button LevelXFitRg2,pos={240,477},size={120,18}, proc=IR3GP_PanelButtonProc,title="4. \\JL     Fit Rg2 w/csrs", help={"Do local fit of Guinier dependence between the cursors amd put resulting values into the Rg and G fields"}
	Button LevelXFitS2,pos={240,496},size={120,18}, proc=IR3GP_PanelButtonProc,title="5. \\JL     Fit S2 w/csrs", help={"Do Power law fitting between the cursors and put resulting parameters in the P and B fields"}


	//Modeling input, common for all distributions
	PopupMenu NumberOfLevels,pos={250,180},size={170,21},proc=IR3GP_PanelPopupControl,title="Number of levels :", help={"Select number of levels to use, NOTE that the level 1 has to have the smallest Rg"}
	PopupMenu NumberOfLevels,mode=2,popvalue=num2str(NumberOfLevels),value= #"\"0;1;2;3;4;5;\""
	//Dist Tabs definition
	TabControl LevelsTabs,pos={5,235},size={370,320},proc=IR3GP_PanelTabControl
	TabControl LevelsTabs,fSize=10,tabLabel(0)="1. Level ",tabLabel(1)="2. Level "
	TabControl LevelsTabs,tabLabel(2)="3. Level ",tabLabel(3)="4. Level "
	TabControl LevelsTabs,tabLabel(4)="5. Level ",value= 0
	
	TitleBox Level1Title, title="   Level  1 controls    ", frame=1, labelBack=(64000,0,0), pos={14,258}, size={150,8}
	TitleBox Level2Title, title="   Level  2 controls    ", frame=1, labelBack=(0,64000,0), pos={14,258}, size={150,8}
	TitleBox Level3Title, title="   Level  3 controls    ", frame=1, labelBack=(30000,30000,64000), pos={14,258}, size={150,8}
	TitleBox Level4Title, title="   Level  4 controls    ", frame=1, labelBack=(52000,52000,0), pos={14,258}, size={150,8}
	TitleBox Level5Title, title="   Level  5 controls    ", frame=1, labelBack=(0,50000,50000), pos={14,258}, size={150,8}
	variable step
	step = Level_S2>0 ? 0.05*Level_S2 : 1
	SetVariable Level_S2,pos={14,290},size={180,16},proc=IR3GP_PanelSetVarProc,title="S2   ", help={"Radious of Gyration 2"}
	SetVariable Level_S2,limits={0,inf,step},value= root:Packages:Irena:GuinierPorod:Level_S2,bodyWidth=140, format="%0.4g"
	CheckBox Level_S2Fit,pos={200,290+1},size={80,16},proc=IR3GP_PanelCheckboxProc,title=" "
	CheckBox Level_S2Fit,variable= root:Packages:Irena:GuinierPorod:Level_S2Fit, help={"Fit the Radius of Gyration2, select properly the starting conditions and limits before fitting"}
	SetVariable Level_S2LowLimit,pos={230,290},size={60,16},noproc,  title=" ", format="%0.3g"
	SetVariable Level_S2LowLimit,limits={0,inf,0},value= root:Packages:Irena:GuinierPorod:Level_S2LowLimit, help={"Power law prefactor low limit"}
	SetVariable Level_S2HighLimit,pos={300,290},size={60,16},noproc, title=" ", format="%0.3g"
	SetVariable Level_S2HighLimit,limits={0,inf,0},value= root:Packages:Irena:GuinierPorod:Level_S2HighLimit, help={"Power law prefactor high limit"}

	step = Level_Rg2>0 ? 0.05*Level_Rg2 : 1
	SetVariable Level_Rg2,pos={14,310},size={180,16},proc=IR3GP_PanelSetVarProc,title="Rg2   ", help={"Radious of Gyration 2"}
	SetVariable Level_Rg2,limits={0,inf,step},value= root:Packages:Irena:GuinierPorod:Level_Rg2,bodyWidth=140, format="%0.4g"
	CheckBox Level_Rg2Fit,pos={200,310+1},size={80,16},proc=IR3GP_PanelCheckboxProc,title=" "
	CheckBox Level_Rg2Fit,variable= root:Packages:Irena:GuinierPorod:Level_Rg2Fit, help={"Fit the Radius of Gyration2, select properly the starting conditions and limits before fitting"}
	SetVariable Level_Rg2LowLimit,pos={230,310},size={60,16},noproc, title=" ", format="%0.3g"	//proc=IR3GP_PanelSetVarProc,
	SetVariable Level_Rg2LowLimit,limits={0,inf,0},value= root:Packages:Irena:GuinierPorod:Level_Rg2LowLimit, help={"Power law prefactor low limit"}
	SetVariable Level_Rg2HighLimit,pos={300,310},size={60,16},noproc,  title=" ", format="%0.3g"
	SetVariable Level_Rg2HighLimit,limits={0,inf,0},value= root:Packages:Irena:GuinierPorod:Level_Rg2HighLimit, help={"Power law prefactor high limit"}


	step = Level_S1>0 ? 0.05*Level_S1 : 1
	SetVariable Level_S1,pos={14,330},size={180,16},proc=IR3GP_PanelSetVarProc,title="S1   ", help={"Radious of Gyration 2"}
	SetVariable Level_S1,limits={0,inf,step},value= root:Packages:Irena:GuinierPorod:Level_S1,bodyWidth=140, format="%0.4g"
	CheckBox Level_S1Fit,pos={200,330+1},size={80,16},proc=IR3GP_PanelCheckboxProc,title=" "
	CheckBox Level_S1Fit,variable= root:Packages:Irena:GuinierPorod:Level_S1Fit, help={"Fit the Radius of Gyration2, select properly the starting conditions and limits before fitting"}
	SetVariable Level_S1LowLimit,pos={230,330},size={60,16},noproc, title=" ", format="%0.3g"
	SetVariable Level_S1LowLimit,limits={0,inf,0},value= root:Packages:Irena:GuinierPorod:Level_S1LowLimit, help={"Power law prefactor low limit"}
	SetVariable Level_S1HighLimit,pos={300,330},size={60,16},noproc,  title=" ", format="%0.3g"
	SetVariable Level_S1HighLimit,limits={0,inf,0},value= root:Packages:Irena:GuinierPorod:Level_S1HighLimit, help={"Power law prefactor high limit"}

	step = Level_G>0 ? 0.05*Level_G : 1
	SetVariable Level_G,pos={14,350},size={180,16},proc=IR3GP_PanelSetVarProc,title="G   ",bodyWidth=140, format="%0.4g"
	SetVariable Level_G,limits={0,inf,step},value= root:Packages:Irena:GuinierPorod:Level_G, help={"Guinier prefactor"}
	CheckBox Level_GFit,pos={200,350+1},size={80,16},proc=IR3GP_PanelCheckboxProc,title=" "
	CheckBox Level_GFit,variable= root:Packages:Irena:GuinierPorod:Level_GFit, help={"Fit G?, find good starting conditions and select fitting limits..."}
	SetVariable Level_GLowLimit,pos={230,350},size={60,16},noproc,  title=" ", format="%0.3g"
	SetVariable Level_GLowLimit,limits={0,inf,0},value= root:Packages:Irena:GuinierPorod:Level_GLowLimit, help={"Low limit for G fitting"}
	SetVariable Level_GHighLimit,pos={300,350},size={60,16},noproc,  title=" ", format="%0.3g"
	SetVariable Level_GHighLimit,limits={0,inf,0},value= root:Packages:Irena:GuinierPorod:Level_GHighLimit, help={"High limit for G fitting"}


	step = Level_Rg1>0 ? 0.05*Level_Rg1 : 1
	SetVariable Level_Rg1,pos={14,370},size={180,16},proc=IR3GP_PanelSetVarProc,title="Rg1   ", help={"Radius of gyration, e.g., sqrt(5/3)*R for sphere etc..."}
	SetVariable Level_Rg1,limits={0,inf,step},variable= root:Packages:Irena:GuinierPorod:Level_Rg1,bodyWidth=140, format="%0.4g"
	CheckBox Level_Rg1Fit,pos={200,370+1},size={80,16},proc=IR3GP_PanelCheckboxProc,title=" "
	CheckBox Level_Rg1Fit,variable= root:Packages:Irena:GuinierPorod:Level_Rg1Fit, help={"Fit Rg? Select properly starting conditions and limits"}
	SetVariable Level_Rg1LowLimit,pos={230,370},size={60,16},noproc,  title=" ", format="%0.3g"
	SetVariable Level_Rg1LowLimit,limits={0,inf,0},value= root:Packages:Irena:GuinierPorod:Level_Rg1LowLimit, help={"Low limit for Rg fitting..."}
	SetVariable Level_Rg1HighLimit,pos={300,370},size={60,16},noproc,  title=" ", format="%0.3g"
	SetVariable Level_Rg1HighLimit,limits={0,inf,0},value= root:Packages:Irena:GuinierPorod:Level_Rg1HighLimit, help={"High limit for Rg fitting"}


	step = Level_P>0 ? 0.05*Level_P : 1
	SetVariable Level_P,pos={14,390},size={180,16},proc=IR3GP_PanelSetVarProc,title="P   ", help={"Power law slope, e.g., -4 for Porod tails"}
	SetVariable Level_P,limits={0,6,step},value= root:Packages:Irena:GuinierPorod:Level_P,bodyWidth=140, format="%0.4g"
	CheckBox Level_PFit,pos={200,390+1},size={80,16},proc=IR3GP_PanelCheckboxProc,title=" "
	CheckBox Level_PFit,variable= root:Packages:Irena:GuinierPorod:Level_PFit, help={"Fit the Power law slope, select good starting conditions and appropriate limits"}
	SetVariable Level_PLowLimit,pos={230,390},size={60,16},noproc, title=" ", format="%0.3g"
	SetVariable Level_PLowLimit,limits={0,inf,0},value= root:Packages:Irena:GuinierPorod:Level_PLowLimit, help={"Power law low limit for slope"}
	SetVariable Level_PHighLimit,pos={300,390},size={60,16},noproc,  title=" ", format="%0.3g"
	SetVariable Level_PHighLimit,limits={0,inf,0},value= root:Packages:Irena:GuinierPorod:Level_PHighLimit, help={"Power law high limit for slope"}


	SetVariable Level_RgCutOff,pos={14,420},size={180,16},proc=IR3GP_PanelSetVarProc,title="RgCutoff  ",bodyWidth=100
	SetVariable Level_RgCutOff,limits={0,inf,1},value= root:Packages:Irena:GuinierPorod:Level_RgCutOff, help={"Size, where the power law dependence ends, 0 or sometimes Rg of lower level, for level 1 it is 0"}

	//Button Level1SetRGCODefault,pos={20,450},size={100,20}, proc=IR1A_InputPanelButtonProc,title="Rg(level-1)->RGCO", help={"This button sets the RgCutOff to value of Rg from previous level (or 0 for level 1)"}
	//CheckBox Level1LinkRGCO,pos={160,455},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link RGCO"
	//CheckBox Level1LinkRGCO,variable= root:Packages:Irena:GuinierPorod:Level1LinkRgCo, help={"Link the RgCO to lower level and fit at the same time?"}

	CheckBox Level_UseCorrelations,pos={30,480},size={80,16},proc=IR3GP_PanelCheckboxProc,title="Is this correlated system? "
	CheckBox Level_UseCorrelations,variable= root:Packages:Irena:GuinierPorod:Level_UseCorrelations, help={"Is there a peak or do you expect Corelations between particles to have importance"}
	NVAR Level_ETA=root:Packages:Irena:GuinierPorod:Level_ETA
	NVAR Level_PACK=root:Packages:Irena:GuinierPorod:Level_PACK
	step = Level_ETA>0 ? 0.05*Level_ETA : 1
	SetVariable Level_ETA pos={14,520},size={180,16},proc=IR3GP_PanelSetVarProc,title="ETA    ",bodyWidth=140, format="%0.4g"
	SetVariable Level_ETA limits={0,inf,step},value= root:Packages:Irena:GuinierPorod:Level_ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Guinier for multiple order Corelations"}
	CheckBox Level_ETAFit pos={200,520},size={80,16},proc=IR3GP_PanelCheckboxProc,title=" "
	CheckBox Level_ETAFit variable=root:Packages:Irena:GuinierPorod:Level_ETAFit, help={"Fit correaltion distance? Slect properly the starting conditions and limits."}
	SetVariable Level_ETALowLimit pos={230,520},size={60,16},noproc, title=" ", format="%0.3g"
	SetVariable Level_ETALowLimit limits={0,inf,0},value= root:Packages:Irena:GuinierPorod:Level_ETALowLimit, help={"Correlation distance low limit"}
	SetVariable Level_ETAHighLimit pos={300,520},size={60,16},noproc,  title=" ", format="%0.3g"
	SetVariable Level_ETAHighLimit limits={0,inf,0},value= root:Packages:Irena:GuinierPorod:Level_ETAHighLimit, help={"Correlation distance high limit"}

	step = Level_PACK>0 ? 0.05*Level_PACK : 1
	SetVariable Level_PACK pos={14,538},size={180,16},proc=IR3GP_PanelSetVarProc,title="Pack    ",bodyWidth=140, format="%0.4g"
	SetVariable Level_PACK limits={0,8,step},value= root:Packages:Irena:GuinierPorod:Level_PACK, help={"Packing factor for domains. For dilute objects 0, for FCC packed spheres 8*0.592"}
	CheckBox Level_PACKFit pos={200,538},size={80,16},proc=IR3GP_PanelCheckboxProc,title=" "
	CheckBox Level_PACKFit variable= root:Packages:Irena:GuinierPorod:Level_PACKFit, help={"Fit packing factor? Select properly starting condions and limits"}
	SetVariable Level_PACKLowLimit pos={230,538},size={60,16},noproc, title=" ", format="%0.3g"
	SetVariable Level_PACKLowLimit limits={0,8,0},value= root:Packages:Irena:GuinierPorod:Level_PACKLowLimit, help={"Low limit for packing factor"}
	SetVariable Level_PACKHighLimit pos={300,538},size={60,16},noproc,  title=" ", format="%0.3g"
	SetVariable Level_PACKHighLimit limits={0,8,0},value= root:Packages:Irena:GuinierPorod:Level_PACKHighLimit, help={"High limit for packing factor"}

	IR3GP_PanelTabControl("",0)
end
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR3GP_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if (cmpstr(ctrlName,"NumberOfLevels")==0)
		//here goes what happens when we change number of distributions
		NVAR nmbdist=root:Packages:Irena:GuinierPorod:NumberOfLevels
		nmbdist=popNum-1
		TabControl LevelsTabs win=IR3DP_MainPanel, value=nmbdist-1
		ControlInfo/W=IR3DP_MainPanel LevelsTabs
		IR3GP_PanelTabControl("",V_Value)
	endif

end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
//******************************************************************************************
//******************************************************************************************
Function IR3GP_PanelTabControl(name,tab)
	String name
	Variable tab			
	STRUCT GuinierPorodLevel Par
	
	DoWindow IR3DP_MainPanel
	if(V_Flag)
		DoWIndow/F IR3DP_MainPanel
	else
		abort
	endif
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:GuinierPorod
	NVAR NumberOfLevels=root:Packages:Irena:GuinierPorod:NumberOfLevels
	NVAR UseNoLimits=root:Packages:Irena:GuinierPorod:UseNoLimits
	NVAR ActiveLevel=root:Packages:Irena:GuinierPorod:ActiveLevel
	NVAR Level_UseCorrelations=root:Packages:Irena:GuinierPorod:Level_UseCorrelations
	
	ActiveLevel=tab+1
	IR3GP_LoadStructureFromWave(Par, ActiveLevel)
	IR3GP_MoveStrToGlobals(Par)

	TitleBox Level1Title,disable= (tab!=0 || NumberOfLevels<1)
	TitleBox Level2Title,disable= (tab!=1 || NumberOfLevels<2)
	TitleBox Level3Title,disable= (tab!=2 || NumberOfLevels<3)
	TitleBox Level4Title,disable= (tab!=3 || NumberOfLevels<4)
	TitleBox Level5Title,disable= (tab!=4 || NumberOfLevels<5)

	SetVariable Level_G,disable= !(tab<NumberOfLevels)
	CheckBox Level_GFit,disable= !(tab<NumberOfLevels )
	SetVariable Level_GLowLimit,disable= !(tab<NumberOfLevels && !UseNoLimits)
	SetVariable Level_GHighLimit,disable=!(tab<NumberOfLevels && !UseNoLimits)
	SetVariable Level_S2,disable= !(tab<NumberOfLevels)
	CheckBox Level_S2Fit,disable= !(tab<NumberOfLevels)
	SetVariable Level_S2LowLimit,disable= !(tab<NumberOfLevels && !UseNoLimits)
	SetVariable Level_S2HighLimit,disable= !(tab<NumberOfLevels && !UseNoLimits)
	SetVariable Level_Rg2,disable= !(tab<NumberOfLevels)
	CheckBox Level_Rg2Fit,disable= !(tab<NumberOfLevels)
	SetVariable Level_Rg2LowLimit,disable= !(tab<NumberOfLevels && !UseNoLimits)
	SetVariable Level_Rg2HighLimit,disable= !(tab<NumberOfLevels && !UseNoLimits)
	SetVariable Level_S1,disable= !(tab<NumberOfLevels)
	CheckBox Level_S1Fit,disable= !(tab<NumberOfLevels)
	SetVariable Level_S1LowLimit,disable= !(tab<NumberOfLevels && !UseNoLimits)
	SetVariable Level_S1HighLimit,disable= !(tab<NumberOfLevels && !UseNoLimits)
	SetVariable Level_Rg1,disable= !(tab<NumberOfLevels)
	CheckBox Level_Rg1Fit,disable= !(tab<NumberOfLevels)
	SetVariable Level_Rg1LowLimit,disable= !(tab<NumberOfLevels && !UseNoLimits)
	SetVariable Level_Rg1HighLimit,disable= !(tab<NumberOfLevels && !UseNoLimits)
	SetVariable Level_P,disable= !(tab<NumberOfLevels)
	CheckBox Level_PFit,disable= !(tab<NumberOfLevels)
	SetVariable Level_PLowLimit,disable= !(tab<NumberOfLevels && !UseNoLimits)
	SetVariable Level_PHighLimit,disable= !(tab<NumberOfLevels && !UseNoLimits)
	SetVariable Level_RgCutOff,disable= !(tab<NumberOfLevels)

	CheckBox Level_UseCorrelations,disable= !(tab<NumberOfLevels)
	SetVariable Level_ETA,disable= !(tab<NumberOfLevels && Level_UseCorrelations)
	CheckBox Level_ETAFit,disable= !(tab<NumberOfLevels  && Level_UseCorrelations)
	SetVariable Level_ETALowLimit,disable= !(tab<NumberOfLevels && Level_UseCorrelations && !UseNoLimits)
	SetVariable Level_ETAHighLimit,disable= !(tab<NumberOfLevels  && Level_UseCorrelations && !UseNoLimits)

	SetVariable Level_PACK,disable= !(tab<NumberOfLevels  && Level_UseCorrelations)
	CheckBox Level_PACKFit,disable= !(tab<NumberOfLevels  && Level_UseCorrelations)
	SetVariable Level_PACKLowLimit,disable= !(tab<NumberOfLevels  && Level_UseCorrelations && !UseNoLimits)
	SetVariable Level_PACKHighLimit,disable= !(tab<NumberOfLevels  && Level_UseCorrelations && !UseNoLimits)

	IR3GP_UpdateIfSelected()
	IR3GP_AppendModelToGraph(1)
	IR3GP_CleanUpGraph(1,0)
	DoWindow/F IR3DP_MainPanel
end

//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************

Function IR3GP_PanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:GuinierPorod
	variable i

	if(cmpstr(ctrlName,"RemovePointWcsrA")==0)
		//here we load the data and create default values
//		ControlInfo/W=LSQF2_MainPanel DataTabs
		//IR2L_LoadDataIntoSet(V_Value+1,0)
		//NVAR UseTheData_set=$("UseTheData_set"+num2str(V_Value+1))
		//UseTheData_set=1
//		IR2L_Data_TabPanelControl("",V_Value)
//		if(IR2L_RemovePntCsrA(V_Value))
//			IR2L_RecalculateIfSelected()
//		endif
		//IR2L_AppendDataIntoGraph(V_Value+1)
		//IR2L_AppendOrRemoveLocalPopInts()
		//IR2L_FormatInputGraph()
		//IR2L_FormatLegend()
		//DoWIndow LSQF_MainGraph
		//if(V_Flag)
			//AutoPositionWindow/R=LSQF2_MainPanel LSQF_MainGraph
		//endif
	endif
	if(cmpstr(ctrlName,"GetHelp")==0)
		//Open www manual with the right page
		IN2G_OpenWebManual("Irena/GuinierPorod.html")
	endif
	if(cmpstr(ctrlName,"ScriptingTool")==0)
		IR2S_ScriptingTool() 
		Autopositionwindow /M=1/R=IR3DP_MainPanel IR2S_ScriptingToolPnl
		NVAR GUseIndra2data=root:Packages:Irena:GuinierPorod:UseIndra2Data
		NVAR GUseQRSdata=root:Packages:Irena:GuinierPorod:UseQRSdata
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
			CB_Struct.win = "IR3DP_MainPanel"
			IR2C_InputPanelCheckboxProc(CB_Struct)		
		endif
		IR2S_UpdateListOfAvailFiles()
	endif

	if (cmpstr(ctrlName,"DrawGraphs")==0 || cmpstr(ctrlName,"DrawGraphsSkipDialogs")==0)
		//here goes what is done, when user pushes Graph button
		SVAR DFloc=root:Packages:Irena:GuinierPorod:DataFolderName
		SVAR DFInt=root:Packages:Irena:GuinierPorod:IntensityWaveName
		SVAR DFQ=root:Packages:Irena:GuinierPorod:QWaveName
		SVAR DFE=root:Packages:Irena:GuinierPorod:ErrorWaveName
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
				variable recovered = IR3GP_RecoverOldParameters()	//recovers old parameters and returns 1 if done so...
			endif
			IR3GP_GraphMeasuredData()
			variable ScreenHeight, ScreenWidth
			MoveWindow /W=GuinierPorod_LogLogPlot 0,0,(IN2G_GetGraphWidthHeight("width")),(IN2G_GetGraphWidthHeight("height"))
			AutoPositionWIndow /M=0  /R=IR3DP_MainPanel GuinierPorod_LogLogPlot
			if (recovered)
				IR3GP_GraphModelData()		//graph the data here, all parameters should be defined
				//need to fix number of levels, which tab seems to be stale...
				NVAR NumberOfLevels = root:Packages:Irena:GuinierPorod:NumberOfLevels
				PopupMenu NumberOfLevels win=IR3DP_MainPanel, mode=(NumberOfLevels+1)
			endif
		else
			Abort "Data not selected properly"
		endif
	endif
	if (cmpstr(ctrlName,"GraphDistribution")==0)
		IR3GP_GraphModelData()
	endif
	if (cmpstr(ctrlName,"DoFitting")==0 || cmpstr(ctrlName,"DoFittingSkipReset")==0)
		variable skipreset=0
		if(cmpstr(ctrlName,"DoFittingSkipReset")==0)
			skipreset = 1
		endif
		IR3GP_FitData(1)
//		IR1A_UpdatePorodSfcandInvariant()
//		IR1A_GraphFitData()
		//IR3GP_GraphModelData()
	endif
	if (cmpstr(ctrlName,"RevertFitting")==0)
		IR3GP_ResetParamsAfterBadFit()
//		IR1A_UpdateMassFractCalc()
//		IR1A_UpdatePorodSfcandInvariant()
//		IR1A_GraphModelData()
	endif
	if (cmpstr(ctrlName,"MarkGraphs")==0)
		IR3GP_TagsIntoGraphs()
	endif
	if (cmpstr(ctrlName,"FixLimits")==0)
		IR3GP_FixLimits()
	endif
	if (cmpstr(ctrlName,"CopyToFolder")==0)
		IR3GP_CalculateModelIntensity()
		IR3GP_CopyDataBackToFolder("")
	endif
	if (cmpstr(ctrlName,"CopyTFolderNoQuestions")==0)
		IR3GP_CopyDataBackToFolder("", Saveme="Yes")
	endif
	if (cmpstr(ctrlName,"LevelXFitRg1AndG")==0)
		//IR3GP_CopyDataBackToFolder("")
		ControlInfo /W=IR3DP_MainPanel LevelsTabs
		IR3GP_FitLocalGuinier(V_Value+1, 1)
//		IR1A_GraphModelData()
	endif
	if (cmpstr(ctrlName,"LevelXFitRg2")==0)
		//IR3GP_CopyDataBackToFolder("")
		ControlInfo /W=IR3DP_MainPanel LevelsTabs
		IR3GP_FitLocalGuinier(V_Value+1, 2)
	endif
	if (cmpstr(ctrlName,"LevelXFitPAndB")==0)
		//IR3GP_CopyDataBackToFolder("")
		ControlInfo /W=IR3DP_MainPanel LevelsTabs
		IR3GP_FitLocalPorod(V_Value+1,1)
//		IR1A_GraphModelData()
	endif
	if (cmpstr(ctrlName,"LevelXFitS2")==0)
		//IR3GP_CopyDataBackToFolder("")
		ControlInfo /W=IR3DP_MainPanel LevelsTabs
		IR3GP_FitLocalPorod(V_Value+1,3)
//		IR1A_GraphModelData()
	endif
	if (cmpstr(ctrlName,"LevelXFitS1")==0)
		//IR3GP_CopyDataBackToFolder("")
		ControlInfo /W=IR3DP_MainPanel LevelsTabs
		IR3GP_FitLocalPorod(V_Value+1,2)
//		IR1A_GraphModelData()
	endif
	if (cmpstr(ctrlName,"CleanupGraph")==0)
		IR3GP_CleanUpGraph(1,1)
	endif
	if(cmpstr(ctrlName,"ConfidenceEvaluation")==0)
		//here we graph the distribution
		IR3GP_ConfidenceEvaluation()
	endif
	setDataFolder oldDf
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR3GP_GraphModelData()

		IR3GP_CalculateModelIntensity()
		//now calculate the normalized error wave
		IR3GP_AppendModelToGraph(0)
//		//append waves to the two top graphs with measured data
//		IR1A_AppendModelToMeasuredData()	//modified for 5		
//		ControlInfo/W=IR1A_ControlPanel DistTabs
//		IR1A_DisplayLocalFits(V_Value+1,0)
//		IR1A_CheckAllUnifiedLevels()
//		IR1A_CheckTabUnifiedLevel()
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3GP_AppendModelToGraph(DoNotRaise)
	variable DoNotRaise
	DoWIndow GuinierPorod_LogLogPlot
	if(V_Flag)
		if(!DoNotRaise)
			DoWIndow/F GuinierPorod_LogLogPlot
		endif
		Wave/Z ModelIntensity = root:Packages:Irena:GuinierPorod:ModelIntensity
		if(!WaveExists(ModelIntensity))
			Abort
		endif
		Wave OriginalQvector = root:Packages:Irena:GuinierPorod:OriginalQvector
		Wave ModelCurrentLevel = root:Packages:Irena:GuinierPorod:ModelCurrentLevel
		NVAR DisplayLocalFits = root:Packages:Irena:GuinierPorod:DisplayLocalFits
		CheckDisplayed/W=GuinierPorod_LogLogPlot ModelIntensity
		if(!V_Flag)
			AppendToGraph/W=GuinierPorod_LogLogPlot ModelIntensity vs OriginalQvector
		endif
		CheckDisplayed/W=GuinierPorod_LogLogPlot ModelCurrentLevel
		if(!V_Flag && DisplayLocalFits)
			AppendToGraph/W=GuinierPorod_LogLogPlot ModelCurrentLevel vs OriginalQvector
		endif
		if(V_Flag && !DisplayLocalFits)
			RemoveFromGraph/W=GuinierPorod_LogLogPlot ModelCurrentLevel 
		endif
		
		ModifyGraph /W=GuinierPorod_LogLogPlot lsize(ModelIntensity)=2,rgb(ModelIntensity)=(0,0,0)
		NVAR ActiveLevel=root:Packages:Irena:GuinierPorod:ActiveLevel
		CheckDisplayed/W=GuinierPorod_LogLogPlot ModelCurrentLevel
		if(V_Flag)
			switch (ActiveLevel)
				case 1 :
					ModifyGraph /W=GuinierPorod_LogLogPlot lsize(ModelCurrentLevel)=2,rgb(ModelCurrentLevel)=(64000,0,0)
					break
				case 2 :
					ModifyGraph /W=GuinierPorod_LogLogPlot lsize(ModelCurrentLevel)=2,rgb(ModelCurrentLevel)=(0,64000,0)
					break
				case 3 :
					ModifyGraph /W=GuinierPorod_LogLogPlot lsize(ModelCurrentLevel)=2,rgb(ModelCurrentLevel)=(30000,30000,64000)
					break
				case 4 :
					ModifyGraph /W=GuinierPorod_LogLogPlot lsize(ModelCurrentLevel)=2,rgb(ModelCurrentLevel)=(52000,52000,0)
					break
				case 5 :
					ModifyGraph /W=GuinierPorod_LogLogPlot lsize(ModelCurrentLevel)=2,rgb(ModelCurrentLevel)=(0,50000,50000)
					break
			endswitch
		endif
	endif
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3GP_PanelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable step = varNum>0 ? 0.05*varNum : 1
	SetVariable $(ctrlName),limits={0,inf,(step)}
	if((stringmatch(ctrlName,"Level_Rg1")))
		NVAR Level_Rg1=$("root:Packages:Irena:GuinierPorod:Level_Rg1")
		NVAR Level_Rg1Fit=$("root:Packages:Irena:GuinierPorod:Level_Rg1Fit")
		if(Level_Rg1>1e6)
			Level_Rg1=1e6
			DoAlert 0, "Max value for Rg1 is 1e6, use that to remove the level from calculations"
			Level_Rg1Fit=0
		endif
	endif
	if(!(stringmatch(ctrlName,"SASBackground")||stringmatch(ctrlName,"Level_RgCutOff")||stringmatch(ctrlName,"SlitLength")))
		NVAR LowLimit=$("root:Packages:Irena:GuinierPorod:"+ctrlName+"LowLimit")
		NVAR HighLimit=$("root:Packages:Irena:GuinierPorod:"+ctrlName+"HighLimit")
		LowLimit = varNum * 0.2
		HighLimit = varNum * 5
	endif
	if((stringmatch(ctrlName,"Level_P*")||stringmatch(ctrlName,"Level_S*")))
		NVAR LowLimit=$("root:Packages:Irena:GuinierPorod:"+ctrlName+"LowLimit")
		NVAR HighLimit=$("root:Packages:Irena:GuinierPorod:"+ctrlName+"HighLimit")
		LowLimit = 1
		HighLimit = 4.2
	endif
	STRUCT GuinierPorodLevel Par
	NVAR ActiveLevel=root:Packages:Irena:GuinierPorod:ActiveLevel
	ControlInfo /W=IR3DP_MainPanel  LevelsTabs
	ActiveLevel = V_Value+1
	IR3GP_MoveGlobalsToStr(Par)
	IR3GP_SaveStructureToWave(Par, ActiveLevel)
	IR3GP_UpdateIfSelected()
	DowIndow/F IR3DP_MainPanel
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3GP_PanelCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	STRUCT GuinierPorodLevel Par
	
	if(stringmatch(ctrlName, "UseSMRData"))
		SetVariable SlitLength,win=IR3DP_MainPanel, disable=!checked
	else	
		NVAR ActiveLevel=root:Packages:Irena:GuinierPorod:ActiveLevel
		ControlInfo /W=IR3DP_MainPanel  LevelsTabs
		ActiveLevel = V_Value+1
		IR3GP_MoveGlobalsToStr(Par)
		IR3GP_SaveStructureToWave(Par, ActiveLevel)
		IR3GP_UpdateIfSelected()
		IR3GP_PanelTabControl("",ActiveLevel-1)
		DowIndow/F IR3DP_MainPanel
	endif
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3GP_UpdateIfSelected()
	NVAR AutoUpdate=root:Packages:Irena:GuinierPorod:UpdateAutomatically
	DoWindow GuinierPorod_LogLogPlot
	if(AutoUpdate && V_Flag)
		IR3GP_CalculateModelIntensity()
	endif
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3GP_CalculateModelIntensity()

	setDataFolder root:Packages:Irena:GuinierPorod
	Wave OriginalIntensity=root:Packages:Irena:GuinierPorod:OriginalIntensity

	NVAR NumberOfLevels=root:Packages:Irena:GuinierPorod:NumberOfLevels
	NVAR UseSMRData=root:Packages:Irena:GuinierPorod:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena:GuinierPorod:SlitLengthUnif
	NVAR ActiveLevel=root:Packages:Irena:GuinierPorod:ActiveLevel
	//clean old individual levels, so they are not in our way...
	KillWaves/Z ModelIntGPLevel_1, ModelIntGPLevel_2, ModelIntGPLevel_3, ModelIntGPLevel_4, ModelIntGPLevel_5
	Duplicate/O OriginalIntensity, ModelIntensity, ModelCurrentLevel
	Redimension/D ModelIntensity
	Wave OriginalQvector		
	ModelIntensity=0
	Duplicate/Free ModelIntensity, tempIntensity
	ModelCurrentLevel=nan
	variable i
	//create all components we want... 
	for(i=1;i<=NumberOfLevels;i+=1)				
		// iterate over all used levels, claculate components of the model and sum into common level.
		IR3GP_CalculateOneLevelModelInt(OriginalQvector,TempIntensity, i)
		//create individual levels here... Needed for export later. 
		Duplicate/O TempIntensity, $("ModelIntGPLevel_"+num2str(i))
		Wave ModelLevel = $("ModelIntGPLevel_"+num2str(i))
		ModelIntensity+=TempIntensity
	endfor		
	//calculate currently displayed tab level. 
	if(ActiveLevel<=NumberOfLevels)	
		IR3GP_CalculateOneLevelModelInt(OriginalQvector,ModelCurrentLevel, ActiveLevel)
	endif
	 
	NVAR SASBackground=root:Packages:Irena:GuinierPorod:SASBackground
	ModelIntensity+=SASBackground	
	
	if(UseSMRData)
		//smear all data if needed. 
		//this is the full model. 
		duplicate/free ModelIntensity, ModelIntensitySM
		IR1B_SmearData(ModelIntensity, OriginalQvector, SlitLengthUnif, ModelIntensitySM)
		ModelIntensity=ModelIntensitySM
		//this is the active level
		if(ActiveLevel<=NumberOfLevels)	
			IR1B_SmearData(ModelCurrentLevel, OriginalQvector, SlitLengthUnif, ModelIntensitySM)
			ModelCurrentLevel=ModelIntensitySM
		else
			ModelCurrentLevel = 0
		endif
		//and these are the individual levels.
		for(i=1;i<=NumberOfLevels;i+=1)	
			//smear all indvidual levels here... Needed for export later. 
			Wave ModelLevel = $("ModelIntGPLevel_"+num2str(i))
			IR1B_SmearData(ModelLevel, OriginalQvector, SlitLengthUnif, ModelIntensitySM)
			ModelLevel = ModelIntensitySM
		endfor		
	endif
	
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3GP_CalculateFitIntensity(Qvector, FitIntensity)
	Wave Qvector, FitIntensity

	setDataFolder root:Packages:Irena:GuinierPorod
	Wave OriginalIntensity=root:Packages:Irena:GuinierPorod:OriginalIntensity
	Wave OriginalQvector=root:Packages:Irena:GuinierPorod:OriginalQvector	
	NVAR NumberOfLevels=root:Packages:Irena:GuinierPorod:NumberOfLevels
	NVAR UseSMRData=root:Packages:Irena:GuinierPorod:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena:GuinierPorod:SlitLengthUnif
	NVAR ActiveLevel=root:Packages:Irena:GuinierPorod:ActiveLevel
	FitIntensity=0
	//NOTE: These fits fail if we do not use full Q range, missing high-Q breaks everything. 
	//So we need to calculate full Q range and then pick the right subset... 
	Duplicate/Free OriginalIntensity, tempIntensity, FitIntLocal		//Full Q range
	FitIntLocal = 0
	variable i
	for(i=1;i<=NumberOfLevels;i+=1)
		IR3GP_CalculateOneLevelModelInt(OriginalQvector,TempIntensity, i)
		FitIntLocal+=TempIntensity
	endfor			 
	NVAR SASBackground=root:Packages:Irena:GuinierPorod:SASBackground
	FitIntLocal+=SASBackground		
	if(UseSMRData)
		duplicate/free FitIntLocal, ModelIntensitySM
		IR1B_SmearData(FitIntLocal, OriginalQvector, SlitLengthUnif, ModelIntensitySM)
		FitIntLocal=ModelIntensitySM
	endif
	//OK, now we have model over the whole data Q range
	//pick subset over fitted Q range
	variable startP
	startP = BinarySearch(OriginalQvector, Qvector[0])
	FitIntensity = FitIntLocal[p+startP]
	
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

static Function IR3GP_CalculateOneLevelModelInt(OriginalQvector, TempIntensity, Level)
	wave OriginalQvector, TempIntensity
	variable Level

	STRUCT GuinierPorodLevel Par
	IR3GP_LoadStructureFromWave(Par, level)	
	IR2GP_CalculateGPlevel(OriginalQvector,TempIntensity,Par )
	IR3GP_CalculateInvariant(level)
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3GP_GraphMeasuredData()
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:GuinierPorod
	SVAR DataFolderName
	SVAR IntensityWaveName
	SVAR QWavename
	SVAR ErrorWaveName
	variable cursorAposition, cursorBposition
	
	//fix for liberal names
	IntensityWaveName = PossiblyQuoteName(IntensityWaveName)
	QWavename = PossiblyQuoteName(QWavename)
	ErrorWaveName = PossiblyQuoteName(ErrorWaveName)
	
	WAVE/Z test=$(DataFolderName+IntensityWaveName)
	if (!WaveExists(test))
		abort "Error in IntensityWaveName wave selection"
	endif
	cursorAposition=0
	cursorBposition=numpnts(test)-1
	WAVE/Z test=$(DataFolderName+QWavename)
	if (!WaveExists(test))
		abort "Error in QWavename wave selection"
	endif
	WAVE/Z test=$(DataFolderName+ErrorWaveName)
	if (!WaveExists(test))
		abort "Error in ErrorWaveName wave selection"
	endif
	Duplicate/O $(DataFolderName+IntensityWaveName), OriginalIntensity
	Duplicate/O $(DataFolderName+QWavename), OriginalQvector
	Duplicate/O $(DataFolderName+ErrorWaveName), OriginalError
	Redimension/D OriginalIntensity, OriginalQvector, OriginalError
	wavestats /Q OriginalQvector
	if(V_min<0)
		OriginalQvector = OriginalQvector[p]<=0 ? NaN : OriginalQvector[p] 
	endif
	IN2G_RemoveNaNsFrom3Waves(OriginalQvector,OriginalIntensity, OriginalError)
//	NVAR/Z SubtractBackground=root:Packages:Irena:GuinierPorod:SubtractBackground
//	if(NVAR_Exists(SubtractBackground) && (cmpstr(Package,"Unified")==0))
//		OriginalIntensity =OriginalIntensity - SubtractBackground
//	endif
	NVAR/Z UseSMRData=root:Packages:Irena:GuinierPorod:UseSMRData
	if(stringmatch(IntensityWaveName, "*SMR_Int*" ))		// slit smeared data
		UseSMRData=1
		SetVariable SlitLength,win=IR3DP_MainPanel,disable=!UseSMRData
	elseif(stringmatch(IntensityWaveName, "*DSM_Int*" ))	//Indra 2 desmeared data
		UseSMRData=0
		SetVariable SlitLength,win=IR3DP_MainPanel,disable=!UseSMRData
	else
			//we have no clue what user input, leave it to him to deal with slit smearing
	endif

	if(NVAR_Exists(UseSMRData))
		if(UseSMRData)
			NVAR SlitLengthUnif=root:Packages:Irena:GuinierPorod:SlitLengthUnif
			variable tempSL1=NumberByKey("SlitLength", note(OriginalIntensity) , "=" , ";")
			if(numtype(tempSL1)==0)
				SlitLengthUnif=tempSL1
			endif
		endif
	endif
	
		KillWIndow/Z IR1_LogLogPlotU
		IR3GP_LogLogPlotU()
	
	setDataFolder oldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function  IR3GP_LogLogPlotU() 
	DoWindow GuinierPorod_LogLogPlot
	if(V_Flag)
		DoWIndow/F GuinierPorod_LogLogPlot
	else
		PauseUpdate    		// building window...
		String fldrSav= GetDataFolder(1)
		SetDataFolder root:Packages:Irena:GuinierPorod:
		Wave OriginalIntensity
		Wave OriginalQvector
		Wave OriginalError
		SVAR DataFolderName
		SVAR IntensityWaveName
		Display /W=(282.75,37.25,759.75,208.25)/K=1  OriginalIntensity vs OriginalQvector as "LogLogPlot"
		DoWindow/C GuinierPorod_LogLogPlot
		ModifyGraph mode(OriginalIntensity)=3
		ModifyGraph msize(OriginalIntensity)=1
		ModifyGraph log=1
		ModifyGraph mirror=1
		ShowInfo
		String LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity  ["+IN2G_ReturnUnitsForYAxis(OriginalIntensity)+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
		Label left LabelStr
		LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
		Label bottom LabelStr
		string LegendStr="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"\\s(OriginalIntensity) Experimental intensity"
		Legend/W=GuinierPorod_LogLogPlot/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 LegendStr
		//
		ErrorBars/Y=1 OriginalIntensity Y,wave=(OriginalError,OriginalError)
		//and now some controls
		TextBox/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
		TextBox/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
		SetDataFolder fldrSav
	endif
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3GP_Initialize(enforceReset)
	variable enforceReset
	//function, which creates the folder for SAS modeling and creates the strings and variables
	
	DFref oldDf= GetDataFolderDFR()

	
	NewDataFolder/O/S root:Packages
	NewdataFolder/O/S root:Packages:Irena
	NewdataFolder/O/S root:Packages:Irena:GuinierPorod
	
	string/g ListOfVariables
	string/g ListOfStrings
	
	//here define the lists of variables and strings needed, separate names by ;...	
	ListOfVariables="UseIndra2Data;UseQRSdata;NumberOfLevels;SubtractBackground;UseSMRData;SlitLengthUnif;UseNoLimits;ActiveLevel;Invariant;"
	ListOfVariables+="Level_G;Level_Rg1;Level_Rg2;Level_P;Level_S1;Level_S2;"
	ListOfVariables+="Level_GFit;Level_Rg1Fit;Level_Rg2Fit;Level_PFit;Level_S1Fit;Level_S2Fit;"
	ListOfVariables+="Level_GLowLimit;Level_Rg1LowLimit;Level_Rg2LowLimit;Level_PLowLimit;Level_S1LowLimit;Level_S2LowLimit;"
	ListOfVariables+="Level_GHighLimit;Level_Rg1HighLimit;Level_Rg2HighLimit;Level_PHighLimit;Level_S1HighLimit;Level_S2HighLimit;"
	ListOfVariables+="Level_GError;Level_Rg1Error;Level_Rg2Error;Level_PError;Level_S1Error;Level_S2Error;"
	ListOfVariables+="Level_RgCutOff;Level_UseCorrelations;"
	ListOfVariables+="Level_ETA;Level_ETAError;Level_ETAFit;Level_ETALowLimit;Level_ETAHighLimit;"
	ListOfVariables+="Level_PACK;Level_PACKError;Level_PACKFit;Level_PACKLowLimit;Level_PACKHighLimit;"
	ListOfVariables+="SASBackground;SASBackgroundError;SASBackgroundStep;FitSASBackground;UpdateAutomatically;DisplayLocalFits;ActiveLevel;ExportLocalFIts;"

	ListOfVariables+="ConfEvMinVal;ConfEvMaxVal;ConfEvNumSteps;ConfEvVaryParam;ConfEvChiSq;ConfEvAutoOverwrite;ConfEvFixRanges;"
	ListOfVariables+="ConfEvTargetChiSqRange;ConfEvAutoCalcTarget;"

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	ListOfStrings="ConfEvListOfParameters;ConEvSelParameter;ConEvMethod;"
		
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	Wave/Z Level1Structure
	if(!WaveExists(Level1Structure))
		make/O Level1Structure, Level2Structure, Level3Structure, Level4Structure, Level5Structure
		IR3GP_SetInitialValues(1)									
	endif
	//cleanup after possible previous fitting stages...
	Wave/Z CoefNames=root:Packages:Irena:GuinierPorod:CoefNames
	Wave/Z CoefficientInput=root:Packages:Irena:GuinierPorod:CoefficientInput
	KillWaves/Z CoefNames, CoefficientInput
	
	setDataFolder OldDF							
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3GP_SetInitialValues(enforceReset)
	variable enforceReset
	STRUCT GuinierPorodLevel Par
	variable i
	For(i=1;i<=5;i+=1)
		IR3GP_SetDefaults(i, enforceReset)
		IR3GP_MoveGlobalsToStr(Par)
		IR3GP_SaveStructureToWave(Par, i)
	endfor
end

//*****************************************************************************************************************
//******************************************************************************************
//******************************************************************************************
Function IR3GP_SetDefaults(Level, enforceReset)
	variable Level, enforceReset
	string OldDf = GetDataFolder(1)
	setDataFolder root:Packages:Irena:GuinierPorod
	NVAR Level_G
	Level_G = 10*Level
	NVAR Level_GFit
	//Level_GFit = 0
	NVAR Level_GLowLimit
	//Level_GLowLimit = Par.GLowLimit
	NVAR Level_GHighLimit
	//Level_GHighLimit = Par.GHighLimit
	NVAR Level_GError
	//Level_GError = Par.GError

	NVAR Level_Rg1
	Level_Rg1 = 20*Level
	NVAR Level_Rg1Fit
	//Level_Rg1Fit = Par.Rg1Fit
	NVAR Level_Rg1LowLimit
	//Level_Rg1LowLimit = Par.Rg1LowLimit
	NVAR Level_Rg1HighLimit
	//Level_Rg1HighLimit = Par.Rg1HighLimit
	NVAR Level_Rg1Error
	//Level_Rg1Error = Par.Rg1Error

	NVAR Level_Rg2
	if(Level_Rg2 == 0)
		Level_Rg2 = 1e10
	endif
	NVAR Level_Rg2Fit
	//Level_Rg2Fit = Par.Rg2Fit
	NVAR Level_Rg2LowLimit
	//Level_Rg2LowLimit = Par.Rg2LowLimit
	NVAR Level_Rg2HighLimit
	//Level_Rg2HighLimit = Par.Rg2HighLimit
	NVAR Level_Rg2Error
	//Level_Rg2Error = Par.Rg2Error

	NVAR Level_P
	Level_P = 4
	NVAR Level_PFit
	//Level_PFit = Par.PFit
	NVAR Level_PLowLimit
	//Level_PLowLimit = Par.PLowLimit
	NVAR Level_PHighLimit
	//Level_PHighLimit = Par.PHighLimit
	NVAR Level_PError
	//Level_PError = Par.PError

	NVAR Level_S1
	Level_S1 = 0
	NVAR Level_S1Fit
	///Level_S1Fit = Par.S1Fit
	NVAR Level_S1LowLimit
	//Level_S1LowLimit = Par.S1LowLimit
	NVAR Level_S1HighLimit
	//Level_S1HighLimit = Par.S1HighLimit
	NVAR Level_S1Error
	//Level_S1Error = Par.S1Error
	
	NVAR Level_S2
	Level_S2 = 0
	NVAR Level_S2Fit
	//Level_S2Fit = Par.S2Fit
	NVAR Level_S2LowLimit
	//Level_S2LowLimit = Par.S2LowLimit
	NVAR Level_S2HighLimit
	//Level_S2HighLimit = Par.S2HighLimit
	NVAR Level_S2Error
	//Level_S2Error = Par.S2Error
	
	NVAR Level_RgCutOff
	Level_RgCutOff = 0

	NVAR Level_UseCorrelations
	Level_UseCorrelations = 0

	NVAR Level_PACK
	Level_PACK = 1
	NVAR Level_PACKFit
	//Level_PACKFit = Par.PACKFit
	NVAR Level_PACKLowLimit
	//Level_PACKLowLimit = Par.PACKLowLimit
	NVAR Level_PACKHighLimit
	//Level_PACKHighLimit = Par.PACKHighLimit
	NVAR Level_PACKError
	//Level_PACKError = Par.PACKError

	NVAR Level_ETA
	Level_ETA = 10
	NVAR Level_ETAFit
	//Level_ETAFit = Par.ETAFit
	NVAR Level_ETALowLimit
	//Level_ETALowLimit = Par.ETALowLimit
	NVAR Level_ETAHighLimit
	//Level_ETAHighLimit = Par.ETAHighLimit
	NVAR Level_ETAError
	//Level_ETAError = Par.ETAError
	
end



Function IR3GP_FitData(skipreset)
	variable skipreset
	//here we need to construct the fitting command and prepare the data for fit...

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:GuinierPorod
	STRUCT GuinierPorodLevel Par
	
	variable i, j
	NVAR UseNoLimits=root:Packages:Irena:GuinierPorod:UseNoLimits
	NVAR NumberOfLevels=root:Packages:Irena:GuinierPorod:NumberOfLevels
	NVAR SASBackground=root:Packages:Irena:GuinierPorod:SASBackground
	NVAR FitSASBackground=root:Packages:Irena:GuinierPorod:FitSASBackground
	String ListOfParameters = "Level_G;Level_Rg1;Level_Rg2;Level_P;Level_S1;Level_S2;"
	String ListOfParametersSF = "Level_PACK;Level_ETA;"
	//Level_GFit,Level_GLowLimit,Level_Rg1HighLimit,Level_PError
		//First check the reasonability of all parameters

//	IR1A_CorrectLimitsAndValues()
//	if(UseNoLimits)			//this also fixes limits so user does not have to worry about them, since they are not being used for fitting anyway. 
//		IR1A_FixLimits()
//	endif

	//
	Make/D/N=0/O W_coef
	Make/T/N=0/O CoefNames, LowLimCoefName, HighLimCoefNames
	Make/D/O/T/N=0 T_Constraints
	T_Constraints=""
	CoefNames=""
	string tempStr

	if (FitSASBackground)		//are we fitting background?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames //, T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SASBackground
		CoefNames[numpnts(CoefNames)-1]="SASBackground"
		LowLimCoefName[numpnts(CoefNames)-1]=""
		HighLimCoefNames[numpnts(CoefNames)-1]=""
	endif

	For(i=1;i<=NumberOfLevels;i+=1)		//iterates through levels...
		IR3GP_LoadStructureFromWave(Par,i)
		IR3GP_MoveStrToGlobals(Par)
		For(j=0;j<ItemsInList(ListOfParameters);j+=1)	
			tempStr= stringfromlist(j,ListOfParameters)
			NVAR FitMe=$("root:Packages:Irena:GuinierPorod:"+tempStr+"Fit")
			if (FitMe)		//are we this parameter?
				NVAR Param=$("root:Packages:Irena:GuinierPorod:"+tempStr)
				NVAR LowLimit=$("root:Packages:Irena:GuinierPorod:"+tempStr+"LowLimit")
				NVAR HighLimit=$("root:Packages:Irena:GuinierPorod:"+tempStr+"HighLimit")
		
				if ((LowLimit > Param || HighLimit < Param)&&!UseNoLimits)
					abort "Level "+num2str(i)+" "+tempStr+" limits set incorrectly, fix the limits before fitting"
				endif
				Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames 
				Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
				W_Coef[numpnts(W_Coef)-1]=Param
				CoefNames[numpnts(CoefNames)-1]=num2str(i)+":"+tempStr
				LowLimCoefName[numpnts(CoefNames)-1]=num2str(i)+":"+tempStr+"LowLimit"
				HighLimCoefNames[numpnts(CoefNames)-1]=num2str(i)+":"+tempStr+"HighLimit"
				T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(LowLimit)}
				T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(HighLimit)}		
			endif
		endfor
		For(j=0;j<ItemsInList(ListOfParametersSF);j+=1)			//Structure Factor, if needed... 
			tempStr= stringfromlist(j,ListOfParametersSF)
			NVAR FitMe=$("root:Packages:Irena:GuinierPorod:"+tempStr+"Fit")
			NVAR UseSF=$("root:Packages:Irena:GuinierPorod:Level_UseCorrelations")
			if (UseSF && FitMe)		//are we this parameter?
				NVAR Param=$("root:Packages:Irena:GuinierPorod:"+tempStr)
				NVAR LowLimit=$("root:Packages:Irena:GuinierPorod:"+tempStr+"LowLimit")
				NVAR HighLimit=$("root:Packages:Irena:GuinierPorod:"+tempStr+"HighLimit")
		
				if ((LowLimit > Param || HighLimit < Param)&&!UseNoLimits)
					abort "Level "+num2str(i)+" "+tempStr+" limits set incorrectly, fix the limits before fitting"
				endif
				Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames 
				Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
				W_Coef[numpnts(W_Coef)-1]=Param
				CoefNames[numpnts(CoefNames)-1]=num2str(i)+":"+tempStr
				LowLimCoefName[numpnts(CoefNames)-1]=num2str(i)+":"+tempStr+"LowLimit"
				HighLimCoefNames[numpnts(CoefNames)-1]=num2str(i)+":"+tempStr+"HighLimit"
				T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(LowLimit)}
				T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(HighLimit)}		
			endif
		endfor
	endfor
	//Now let's check if we have what to fit at all...
	variable NumOfParam=numpnts(CoefNames)
	if (NumOfParam==0)
		beep
		Abort "Select parameters to fit and set their fitting limits"
	endif
	IR3GP_SetErrorsToZero()
	
	DoWindow /F GuinierPorod_LogLogPlot
	Wave OriginalQvector
	Wave OriginalIntensity
	Wave OriginalError	

	NVAR UseSMRData=root:Packages:Irena:GuinierPorod:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena:GuinierPorod:SlitLengthUnif
	IN2G_CheckForSlitSmearedRange(UseSMRData,OriginalQvector [pcsr(B  , "GuinierPorod_LogLogPlot")], SlitLengthUnif)
	
	Variable V_chisq, level
	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave=W_coef/1000

	Variable V_FitError=0			//This should prevent errors from being generated
		variable NumParams=numpnts(CoefNames)
		string ParamName, ParamName1, ListOfLimitsReachedParams
		ListOfLimitsReachedParams=""
		variable LimitsReached
	
	//and now the fit...
	if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalIntensity, FitIntensityWave		
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalQvector, FitQvectorWave
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalError, FitErrorWave
		if(UseNoLimits)	
			FuncFit /N=0/W=0/Q IR3GP_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /D 
		else
			FuncFit /N=0/W=0/Q IR3GP_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /D /C=T_Constraints 
		endif
	else
		Duplicate/O OriginalIntensity, FitIntensityWave		
		Duplicate/O OriginalQvector, FitQvectorWave
		Duplicate/O OriginalError, FitErrorWave
		if(UseNoLimits)	
			FuncFit /N=0/W=0/Q IR3GP_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D	
		else	
			FuncFit /N=0/W=0/Q IR3GP_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D /C=T_Constraints	
		endif
	endif
	if (V_FitError!=0)	//there was error in fitting
		NVAR/Z FitFailed = root:Packages:Irena_UnifFit:FitFailed
		if (NVAR_Exists(FitFailed))
			FitFailed=1
		endif
		IR3GP_ResetParamsAfterBadFit()
		IR3GP_SetErrorsToZero()
		if(skipreset==0)
			beep
			Abort "Fitting error, check starting parameters and fitting limits" 
		endif
	else		//results OK, make sure the resulting values are set 
		Wave W_sigma = root:Packages:Irena:GuinierPorod:W_sigma
		for (i=0;i<NumOfParam;i+=1)
			if(stringMatch(CoefNames[i],"SASBackground"))
				NVAR SASBackground = root:Packages:Irena:GuinierPorod:SASBackground
				NVAR SASBackgroundError=root:Packages:Irena:GuinierPorod:SASBackgroundError
				SASBackground = W_Coef[i]
				SASBackgroundError=W_sigma[i]
			else
				level=str2num(StringFromList(0,CoefNames[i],":"))
				ParamName=StringFromList(1,CoefNames[i],":")
				IR3GP_LoadStructureFromWave(Par, level)
				IR3GP_MoveStrToGlobals(Par)
				NVAR tempVal=$("root:Packages:Irena:GuinierPorod:"+ParamName)
				NVAR tempValLowLimit=$("root:Packages:Irena:GuinierPorod:"+ParamName+"LowLImit")
				NVAR tempValHighLimit=$("root:Packages:Irena:GuinierPorod:"+ParamName+"HighLimit")
				NVAR tempValError=$("root:Packages:Irena:GuinierPorod:"+ParamName+"Error")
				tempVal = W_Coef[i]
				tempValError=W_sigma[i]
				if(abs(tempValLowLimit-tempVal)/tempVal <0.02)
					LimitsReached = 1
					ListOfLimitsReachedParams+=ParamName+";"
				endif
				if(abs(tempValHighLimit-tempVal)/tempVal <0.02)
					LimitsReached = 1
					ListOfLimitsReachedParams+=ParamName+";"
				endif
				IR3GP_MoveGlobalsToStr(Par)
				IR3GP_SaveStructureToWave(Par, level)
			endif
		endfor
		if(LimitsReached && !UseNoLimits)
			print "Following parameters may have reached their Min/Max limits during fitting:"
			print  ListOfLimitsReachedParams
			//print GetRTStackInfo(0)
			if(!stringmatch(GetRTStackInfo(0),"*IR3GP_ConfEvButtonProc*") )		//skip when calling from either Confidence evaluation or scripting tool 
				DoAlert /T="Warning about possible fitting limits violation" 0, "One or more limits may have been reached, check history for the list of parameters" 
			endif
		endif

	endif
//	
//	IR1A_UpdateMassFractCalc()
//	
	variable/g AchievedChisq=V_chisq
//	IR1A_RecordErrorsAfterFit()
	IR3GP_CalculateModelIntensity()
//	IR1A_GraphModelData()
//	IR1A_RecordResults("after")
//	
//	DoWIndow/F IR1A_ControlPanel
//	IR1A_FixTabsInPanel()
//	
	KillWaves/Z T_Constraints, E_wave
	NVAR ActiveLevel=root:Packages:Irena:GuinierPorod:ActiveLevel
	IR3GP_LoadStructureFromWave(Par, ActiveLevel)
	IR3GP_MoveStrToGlobals(Par)	
	
	setDataFolder OldDF
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3GP_FitFunction(w,yw,xw) : FitFunc
	Wave w,yw,xw

	Wave/T CoefNames=root:Packages:Irena:GuinierPorod:CoefNames		//text wave with names of parameters
	STRUCT GuinierPorodLevel Par
	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	string ParamName=""
	variable level
	for (i=0;i<NumOfParam;i+=1)
		if(stringMatch(CoefNames[i],"SASBackground"))
			NVAR SASBackground = root:Packages:Irena:GuinierPorod:SASBackground
			SASBackground = w[i]
		else
			level=str2num(StringFromList(0,CoefNames[i],":"))
			ParamName=StringFromList(1,CoefNames[i],":")
			IR3GP_LoadStructureFromWave(Par, level)
			IR3GP_MoveStrToGlobals(Par)
			NVAR tempVal=$("root:Packages:Irena:GuinierPorod:"+ParamName)
			tempVal = w[i]
			IR3GP_MoveGlobalsToStr(Par)
			IR3GP_SaveStructureToWave(Par, level)
		endif
	endfor
	//and now we need to calculate the model Intensity
	IR3GP_CalculateFitIntensity(xw, yw)	
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3GP_ResetParamsAfterBadFit()
	
	Wave w=root:Packages:Irena:GuinierPorod:CoefficientInput
	Wave/T CoefNames=root:Packages:Irena:GuinierPorod:CoefNames		//text wave with names of parameters
	STRUCT GuinierPorodLevel Par

	if ((!WaveExists(w)) || (!WaveExists(CoefNames)))
		Beep
		abort "Record of old parameters does not exist, this is BUG, please report it..."
	endif

	NVAR NumberOfLevels=root:Packages:Irena:GuinierPorod:NumberOfLevels

	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	if(NumOfParam<1)
		beep
		abort "Record of old parameters is bad." 
	endif
	string ParamName=""
	variable level

	for (i=0;i<NumOfParam;i+=1)
		if(stringMatch(CoefNames[i],"SASBackground"))
			NVAR SASBackground = root:Packages:Irena:GuinierPorod:SASBackground
			SASBackground = w[i]
		else
			level=str2num(StringFromList(0,CoefNames[i],":"))
			ParamName=StringFromList(1,CoefNames[i],":")
			IR3GP_LoadStructureFromWave(Par, level)
			IR3GP_MoveStrToGlobals(Par)
			NVAR tempVal=$("root:Packages:Irena:GuinierPorod:"+ParamName)
			tempVal = w[i]
			IR3GP_MoveGlobalsToStr(Par)
			IR3GP_SaveStructureToWave(Par, level)
		endif
	endfor
	IR3GP_CalculateModelIntensity()

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3GP_SetErrorsToZero()

	string ListOfVariables="SASBackgroundError;"
	variable i
	NVAR ActiveLevel=root:Packages:Irena:GuinierPorod:ActiveLevel
	STRUCT GuinierPorodLevel Par
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		testVar=0
	endfor
	for (i=1;i<=5;i+=1)
			IR3GP_LoadStructureFromWave(Par, i)
			Par.GError=0
			Par.Rg1Error=0
			Par.Rg2Error=0
			Par.PError=0
			Par.s1Error=0
			Par.s2Error=0
			IR3GP_SaveStructureToWave(Par, i)
	endfor
	IR3GP_LoadStructureFromWave(Par, ActiveLevel)
	IR3GP_MoveStrToGlobals(Par)	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3GP_FixLimits()

	DFref oldDf= GetDataFolderDFR()

	variable i
	NVAR ActiveLevel=root:Packages:Irena:GuinierPorod:ActiveLevel
	STRUCT GuinierPorodLevel Par	
	for (i=1;i<=5;i+=1)
			IR3GP_LoadStructureFromWave(Par, i)
			Par.GLowLimit=0.1 * Par.G
			Par.GHighLimit=10 * Par.G
			Par.Rg1LowLimit=0.2 * Par.Rg1
			Par.Rg1HighLimit=5 * Par.Rg1
			Par.Rg2LowLimit=0.2 * Par.Rg2
			Par.Rg2HighLimit=5 * Par.Rg2
			Par.PLowLimit=1
			Par.PHighLimit=4.2
			Par.s1LowLimit=1
			Par.s1HighLimit=4
			Par.s2LowLimit=1 
			Par.s2HighLimit=4
			Par.ETALowLimit=0.1 * Par.ETA
			Par.ETAHighLimit=10 * Par.ETA
			Par.PACKLowLimit=0.1 * Par.PACK
			Par.PACKHighLimit=10 * Par.PACK
			IR3GP_SaveStructureToWave(Par, i)
	endfor
	IR3GP_LoadStructureFromWave(Par, ActiveLevel)
	IR3GP_MoveStrToGlobals(Par)	
	setDataFolder oldDf
	
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR3GP_TagsIntoGraphs()
	
	NVAR NumberOfLevels=root:Packages:Irena:GuinierPorod:NumberOfLevels
	variable i
	for(i=1;i<=NumberOfLevels;i+=1)	
		IR3GP_InsertOneLevelTagInGrph(i)
	endfor											
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR3GP_InsertOneLevelTagInGrph(Lnmb)
	variable Lnmb
	
	setDataFolder root:Packages:Irena:GuinierPorod
	STRUCT GuinierPorodLevel Par
	IR3GP_LoadStructureFromWave(Par, Lnmb)
	//IR3GP_MoveStrToGlobals(Par)

	NVAR SASBackgroundError=$("SASBackgroundError")
	NVAR SASBackground=$("SASBackground")
	string LogLogTag, IQ4Tag, tagname
	tagname="Level"+num2str(Lnmb)+"Tag"
	Wave OriginalQvector=root:Packages:Irena:GuinierPorod:OriginalQvector
		
	variable QtoAttach=2/Par.Rg1
	variable AttachPointNum=binarysearch(OriginalQvector,QtoAttach)
	
	LogLogTag="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"Guinier-Porod Fit for level "+num2str(Lnmb)+"\r"
	if (Par.GError>0)
		LogLogTag+="G \t= "+num2str(Par.G)+"  \t +/-"+num2str(Par.GError)+"\r"
	else
		LogLogTag+="G \t= "+num2str(Par.G)+"  \t  "+"\r"	
	endif
	if (Par.S2>0)
		if (Par.S2Error>0)
			LogLogTag+="S 2\t = "+num2str(Par.S2)+"  \t +/-"+num2str(Par.S2Error)+"\r"
		else
			LogLogTag+="S 2 \t= "+num2str(Par.S2)+"  \t   "	+"\r"
		endif
	endif
	if (Par.Rg2>0 && Par.Rg2<1e9)
		if (Par.Rg2Error>0)
			LogLogTag+="Rg 2 \t= "+num2str(Par.Rg2)+"  \t +/-"+num2str(Par.Rg2Error)+"\r"
		else
			LogLogTag+="Rg 2 \t= "+num2str(Par.Rg2)+"  \t  "+"\r"
		endif
	endif
	if (Par.S1>0)
		if (Par.S1Error>0)
			LogLogTag+="S 1 \t= "+num2str(Par.S1)+"  \t +/-"+num2str(Par.S1Error)+"\r"
		else
			LogLogTag+="S 1 \t= "+num2str(Par.S1)+"  \t   "	+"\r"
		endif
	endif
	if (Par.Rg1>0 && Par.Rg1<1e6)
		if (Par.Rg1Error>0)
			LogLogTag+="Rg 1\t= "+num2str(Par.Rg1)+"[A]  \t +/-"+num2str(Par.Rg1Error)+"\r"
		else
			LogLogTag+="Rg 1 \t= "+num2str(Par.Rg1)+"[A]   \t  "+"\r"
		endif	
	endif
	if (Par.PError>0)
		LogLogTag+="P \t= "+num2str(Par.P)+"  \t +/-"+num2str(Par.PError)+"\r"
	else
		LogLogTag+="P \t= "+num2str(Par.P)+"  \t   "	+"\r"
	endif
	if (Par.RgCutOff>0)
		LogLogTag+="Assumed RgCutOff  = "+num2str(Par.RgCutOff)+"\r"
	endif
		LogLogTag+="Invariant  = "+num2str(Par.Invariant)
//	if (MassFractal)
//		LogLogTag+="Mass fractal assumed"+"\r"
//	endif
//	if (LinkRGCO)
//		LogLogTag+="RgCO linked to Rg of level"+num2str(Lnmb-1)
//	else
//		if (RGCOError>0)
//			LogLogTag+="RgCO = "+num2str(RGCO)+"[A]   \t "+num2str(RGCOError)+", K = "+num2str(K)
//		else
//			LogLogTag+="RgCO = "+num2str(RGCO)+"[A]   \t 0 , K = "+num2str(K)
//		endif
//	endif
	if (Par.UseCorrelations)
		LogLogTag+="\rAssumed correlations:\r"
		if (Par.ETAError>0)
			LogLogTag+= "ETA = "+num2str(Par.ETA)+"[A]   \t+/-"+num2str(Par.ETAError)
		else
			LogLogTag+= "ETA = "+num2str(Par.ETA)+"[A]   \t"
		endif
		if (Par.PackError>0)
			LogLogTag+= ", Pack = "+num2str(Par.PACK)+"  \t+/-"+num2str(Par.PackError)
		else
			LogLogTag+= ", Pack = "+num2str(Par.PACK)+"  \t "
		endif
	endif
	if (Lnmb==1)
		if (SASBackgroundError>0)
			LogLogTag+="\rSAS Background = "+num2str(SASBackground)+"     +/-   "+num2str(SASBackgroundError)
		else
			LogLogTag+="\rSAS Background = "+num2str(SASBackground)+"     (fixed)   "
		endif
	endif
//	if (numtype(Invariant)==0)
//		LogLogTag+="\rInvariant [cm^(-4)] = "+num2str(Invariant)
//	endif
//	if (numtype(SurfaceToVolume)==0)
//		LogLogTag+="      Surface to Volume ratio = "+num2str(SurfaceToVolume)+"  m^2/cm^3"
//	endif
	
	Tag/W=GuinierPorod_LogLogPlot/C/N=$(tagname)/F=2/L=2/M OriginalIntensity, AttachPointNum, LogLogTag
	//Tag/W=IR1_IQ4_Q_PlotU/C/N=$(tagname)/F=2/L=2/M OriginalIntQ4, AttachPointNum, IQ4Tag
	
	
end
//****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3GP_CopyDataBackToFolder(StandardOrUser, [Saveme])
	string StandardOrUser, SaveMe
	//here we need to copy the final data back to folder
	//before that we need to also attach note to teh waves with the results
	if(ParamIsDefault(SaveMe))
		SaveMe="NO"
	ENDIF
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:GuinierPorod
	
	string UsersComment="Guinier-Porod Fit results from "+date()+"  "+time()
	string ExportIndividualLevels = "No"
	
	Prompt UsersComment, "Modify comment to be included with these results"
	Prompt ExportIndividualLevels, "Export separately Level data", popup, "No;Yes;"
	if(!stringmatch(SaveMe,"Yes"))
		DoPrompt "Copy data back to folder options", UsersComment, ExportIndividualLevels
		if (V_Flag)
			abort
		endif
	endif
	Wave FitIntensityWave=root:Packages:Irena:GuinierPorod:ModelIntensity
	Wave FitQvectorWave=root:Packages:Irena:GuinierPorod:OriginalQvector
	
	NVAR NumberOfLevels=root:Packages:Irena:GuinierPorod:NumberOfLevels
	SVAR DataFolderName=root:Packages:Irena:GuinierPorod:DataFolderName
	//NVAR ExportLocalFits=root:Packages:Irena:GuinierPorod:ExportLocalFits
	variable LastSavedOutput
	
	Duplicate/O FitIntensityWave, tempFitIntensityWave
	Duplicate/O FitQvectorWave, tempFitQvectorWave
	string ListOfWavesForNotes="tempFitIntensityWave;tempFitQvectorWave;"
	
	IR3GP_AppendWaveNote(ListOfWavesForNotes)
	
	setDataFolder $DataFolderName
	string tempname 
	variable ii=0, i
	For(ii=0;ii<1000;ii+=1)
		tempname="GuinierPorodFitIntensity_"+num2str(ii)
		if (checkname(tempname,1)==0)
			break
		endif
	endfor
	LastSavedOutput=ii
	Duplicate /O tempFitIntensityWave, $tempname
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm")
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)

	tempname="GuinierPorodFitQvector_"+num2str(ii)
	Duplicate /O tempFitQvectorWave, $tempname
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	
	//and now local fits also
	if(stringmatch(ExportIndividualLevels,"Yes"))
		//export background as flat wave...
		if(NumberOfLevels>0)	//at least Level 1 must exist!
			Wave/Z ModelLevelInt =$("root:Packages:Irena:GuinierPorod:ModelIntGPLevel_1")
				tempname="GuinierPorodIntLevel0_"+num2str(ii)
				IR3GP_AppendWaveNote(tempname+";")
				Duplicate /O ModelLevelInt, $tempname
				Wave ModelLevelInt = $tempname
				NVAR SASBackground = root:Packages:Irena:GuinierPorod:SASBackground
				ModelLevelInt = SASBackground
				IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
				IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm")
				IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
				tempname="GuinierPorodQvecLevel0_"+num2str(ii)
				Duplicate /O tempFitQvectorWave, $tempname
				IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
				IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
				IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
		endif		
		//and now all used levels. 
		For(i=1;i<=NumberOfLevels;i+=1)
			Wave/Z ModelLevelInt =$("root:Packages:Irena:GuinierPorod:ModelIntGPLevel_"+num2str(i))
			if(WaveExists(ModelLevelInt))
				tempname="GuinierPorodIntLevel"+num2str(i)+"_"+num2str(ii)
				IR3GP_AppendWaveNote(tempname+";")
				Duplicate /O ModelLevelInt, $tempname
				IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
				IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm")
				IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
				tempname="GuinierPorodQvecLevel"+num2str(i)+"_"+num2str(ii)
				Duplicate /O tempFitQvectorWave, $tempname
				IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
				IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
				IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
			endif
		endfor
	endif
	setDataFolder root:Packages:Irena:GuinierPorod

	Killwaves/Z tempFitIntensityWave,tempFitQvectorWave
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR3GP_AppendWaveNote(ListOfWavesForNotes)
	string ListOfWavesForNotes
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:GuinierPorod

	NVAR NumberOfLevels=root:Packages:Irena:GuinierPorod:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena:GuinierPorod:SASBackground
	NVAR SASBackgroundError=root:Packages:Irena:GuinierPorod:SASBackgroundError
	SVAR DataFolderName=root:Packages:Irena:GuinierPorod:DataFolderName
	string ExperimentName=IgorInfo(1)
	variable i
	For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)

		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"IgorExperimentName",ExperimentName)
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"DataFolderinIgor",DataFolderName)
		
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"DistributionTypeModelled", "Guinier-Porod Fit")	
		
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"NumberOfModelledLevels",num2str(NumberOfLevels))

		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"SASBackground",num2str(SASBackground))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"SASBackgroundError",num2str(SASBackgroundError))
	endfor

	For(i=1;i<=NumberOfLevels;i+=1)
		IR3GP_AppendWNOfDist(i,ListOfWavesForNotes)
	endfor

	setDataFolder oldDF

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR3GP_AppendWNOfDist(level,ListOfWavesForNotes)
	variable level
	string ListOfWavesForNotes
	
	STRUCT GuinierPorodLevel Par
	
	IR3GP_LoadStructureFromWave(Par, level)

	variable i
	For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_S2",num2str(Par.S2))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_S2Fit",num2str(Par.S2Fit))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_S2Error",num2str(Par.S2Error))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_Rg2",num2str(Par.Rg2))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_Rg2Fit",num2str(Par.Rg2Fit))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_Rg2Error",num2str(Par.Rg2Error))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_S1",num2str(Par.S1))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_S1Fit",num2str(Par.S1Fit))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_S1Error",num2str(Par.S1Error))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_G",num2str(Par.G))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_GFit",num2str(Par.GFit))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_GError",num2str(Par.GError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_Rg1",num2str(Par.Rg1))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_Rg1Fit",num2str(Par.Rg1Fit))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_RgError",num2str(Par.Rg1Error))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_P",num2str(Par.P))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_PFit",num2str(Par.PFit))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_PError",num2str(Par.PError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_UseCorrelations",num2str(Par.UseCorrelations))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_ETA",num2str(Par.ETA))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_ETAFit",num2str(Par.ETAFit))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_ETAError",num2str(Par.ETAError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_PACK",num2str(Par.PACK))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_PACKFit",num2str(Par.PACKFit))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_PACKError",num2str(Par.PACKError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_RgCutOff",num2str(Par.RgCutOff))
//		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"Invariant",num2str(Invariant))
//		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"SurfaceToVolumeRatio",num2str(SurfaceToVolumeRatio))

//		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"LinkRgCO",num2str(LinkRgCO))
//		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"DegreeOfAggreg",num2str(DegreeOfAggreg))
	endfor
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3GP_RecoverOldParameters()
	
	NVAR NumberOfLevels=root:Packages:Irena:GuinierPorod:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena:GuinierPorod:SASBackground
	NVAR SASBackgroundError=root:Packages:Irena:GuinierPorod:SASBackgroundError
	SVAR DataFolderName=root:Packages:Irena:GuinierPorod:DataFolderName
	

	variable DataExists=0,i
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(DataFolderName, 2)
	string tempString
	if (stringmatch(ListOfWaves, "*GuinierPorodFitIntensity*" ))
		string ListOfSolutions=""
		For(i=0;i<itemsInList(ListOfWaves);i+=1)
			if (stringmatch(stringFromList(i,ListOfWaves),"*GuinierPorodFitIntensity*"))
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

	if (DataExists==1 && cmpstr("Start fresh", ReturnSolution)!=0)
		ReturnSolution=ReturnSolution[0,strsearch(ReturnSolution, "*", 0 )-1]
		Wave/Z OldDistribution=$(DataFolderName+ReturnSolution)

		string OldNote=note(OldDistribution)
		NumberOfLevels=NumberByKey("NumberOfModelledLevels", OldNote,"=")
		//here I need to set appropriately the Number of levels on the panel...
		//
		PopupMenu NumberOfLevels,mode=NumberOfLevels,value= #"\"0;1;2;3;4;5;\"", win = IR3DP_MainPanel
		//	
		SASBackground =NumberByKey("SASBackground", OldNote,"=")
		SASBackgroundError =NumberByKey("SASBackgroundError", OldNote,"=")
		For(i=1;i<=NumberOfLevels;i+=1)		
			IR3GP_RecoverOneLevelParam(i,OldNote)	
		endfor
		return 1
	else
		return 0
	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3GP_RecoverOneLevelParam(level,OldNote)	
	variable level
	string OldNote	
	STRUCT GuinierPorodLevel Par
	Par.S2=NumberByKey("Level"+num2str(level)+"_S2", OldNote,"=")
	Par.S2Error=NumberByKey("Level"+num2str(level)+"_S2Error", OldNote,"=")
	Par.Rg2=NumberByKey("Level"+num2str(level)+"_Rg2", OldNote,"=")
	Par.Rg2Error=NumberByKey("Level"+num2str(level)+"_Rg2Error", OldNote,"=")
	Par.S1=NumberByKey("Level"+num2str(level)+"_S1", OldNote,"=")
	Par.S1Error=NumberByKey("Level"+num2str(level)+"_S1Error", OldNote,"=")
	Par.G=NumberByKey("Level"+num2str(level)+"_G", OldNote,"=")
	Par.GError=NumberByKey("Level"+num2str(level)+"_GError", OldNote,"=")
	Par.Rg1=NumberByKey("Level"+num2str(level)+"_Rg1", OldNote,"=")
	Par.Rg1Error=NumberByKey("Level"+num2str(level)+"_Rg1Error", OldNote,"=")
	Par.P=NumberByKey("Level"+num2str(level)+"_P", OldNote,"=")
	Par.PError=NumberByKey("Level"+num2str(level)+"_PError", OldNote,"=")
	Par.ETA=NumberByKey("Level"+num2str(level)+"_ETA", OldNote,"=")
	Par.ETAError=NumberByKey("Level"+num2str(level)+"_ETAError", OldNote,"=")
	Par.PACK=NumberByKey("Level"+num2str(level)+"_PACK", OldNote,"=")
	Par.PACKError=NumberByKey("Level"+num2str(level)+"_PACKError", OldNote,"=")
	Par.UseCorrelations=NumberByKey("Level"+num2str(level)+"_UseCorrelations", OldNote,"=")
	Par.RgCutOff=NumberByKey("Level"+num2str(level)+"_RgCutOff", OldNote,"=")

	Par.S2Fit	=NumberByKey("Level"+num2str(level)+"_S2Fit", OldNote,"=")
	Par.Rg2Fit	=NumberByKey("Level"+num2str(level)+"_Rg2Fit", OldNote,"=")
	Par.S1Fit	=NumberByKey("Level"+num2str(level)+"_S1Fit", OldNote,"=")
	Par.GFit		=NumberByKey("Level"+num2str(level)+"_GFit", OldNote,"=")
	Par.Rg1Fit	=NumberByKey("Level"+num2str(level)+"_Rg1Fit", OldNote,"=")
	Par.PFit		=NumberByKey("Level"+num2str(level)+"_PFit", OldNote,"=")
	Par.ETAFit	=NumberByKey("Level"+num2str(level)+"_ETAFit", OldNote,"=")
	Par.PACKFit	=NumberByKey("Level"+num2str(level)+"_PACKFit", OldNote,"=")

	IR3GP_SaveStructureToWave(Par, level)
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR3GP_FitLocalGuinier(Level, WhichOne)
	variable level
	variable WhichOne		//1 for Rg1, 2 for Rg2
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:GuinierPorod
	STRUCT GuinierPorodLevel Par

	//first set to display local fits
		NVAR DisplayLocalFits=root:Packages:Irena:GuinierPorod:DisplayLocalFits
		DisplayLocalFits=1
		Checkbox DisplayLocalFits, value=DisplayLocalFits
	
	Wave OriginalIntensity
	Wave OriginalQvector
	Wave OriginalError
	Duplicate/O OriginalIntensity, $("FitLevel"+num2str(Level)+"Guinier")

	Wave FitInt=$("FitLevel"+num2str(Level)+"Guinier")
	string FitIntName="FitLevel"+num2str(Level)+"Guinier"
		NVAR Rg=$("root:Packages:Irena:GuinierPorod:Level_Rg"+num2str(WhichOne))
		NVAR RgLowLimit=$("root:Packages:Irena:GuinierPorod:Level_Rg"+num2str(WhichOne)+"LowLimit")
		NVAR RgHighLimit=$("root:Packages:Irena:GuinierPorod:Level_Rg"+num2str(WhichOne)+"HighLimit")
		NVAR G=$("root:Packages:Irena:GuinierPorod:Level_G")
		NVAR GLowLimit=$("root:Packages:Irena:GuinierPorod:Level_GLowLimit")
		NVAR GHighLimit=$("root:Packages:Irena:GuinierPorod:Level_GHighLimit")
		NVAR Rg1=$("root:Packages:Irena:GuinierPorod:Level_Rg1")
		NVAR Rg2=$("root:Packages:Irena:GuinierPorod:Level_Rg2")
		NVAR S1=$("root:Packages:Irena:GuinierPorod:Level_S1")
		NVAR S2=$("root:Packages:Irena:GuinierPorod:Level_S2")
	Variable LocalRg, LocalG
	
	DoWIndow/F GuinierPorod_LogLogPlot
	if (strlen(CsrWave(A))==0 || strlen(CsrWave(B))==0)
		beep
		abort "Both Cursors Need to be set in Log-log graph on wave OriginalIntensity"
	endif

	if(WhichOne==1)		//Rg1
		LocalRg = 2*pi/((OriginalQvector[pcsr(A)]+OriginalQvector[pcsr(B)])/2)
		LocalG = (OriginalIntensity[pcsr(A)]+OriginalIntensity[pcsr(B)])/2
		RG2=0
		S1=0
		S2=0
	elseif(WhichOne==2)			//Rg2
		LocalRg = Rg
		LocalG = (OriginalIntensity[pcsr(A)]+OriginalIntensity[pcsr(B)])/2
		S2=0
	else
		return 0
	endif
	Make/D/O/N=2 New_FitCoefficients, CoefficientInput, LocalEwave
	Make/O/T/N=2 CoefNames
	New_FitCoefficients[0] = LocalG
	New_FitCoefficients[1] = LocalRg
	LocalEwave[0]=(G/20)
	LocalEwave[1]=(Rg/20)
	CoefficientInput[0]={LocalG,LocalRg}
	CoefNames={"Level"+num2str(level)+"G","Level"+num2str(level)+"Rg"}
	variable tempLength
	DoWIndow/F GuinierPorod_LogLogPlot
	if(strlen(CsrWave(A))<1 || strlen(CsrWave(B))<1)
		beep
		SetDataFolder oldDf
		abort "Set both cursors before fitting"
	endif
	Variable V_FitError=0			//This should prevent errors from being generated
	FuncFit/Q/N IR3GP_GuinierFitAllAtOnce New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave 
	if (V_FitError!=0)	//there was error in fitting
		beep
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	
	Rg=abs(New_FitCoefficients[1])
	RgLowLImit=Rg/5
	RgHighLimit=Rg*5
	if(WhichOne==1)
		G=abs(New_FitCoefficients[0])
		GLowLimit=G/5
		GhighLimit=G*5
	endif
	//update fit wave...
	FitInt=New_FitCoefficients[0]*exp(-OriginalQvector^2*New_FitCoefficients[1]^2/3)
	NVAR UseSMRData=root:Packages:Irena:GuinierPorod:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena:GuinierPorod:SlitLengthUnif
	if(UseSMRData)
		duplicate/Free  FitInt, UnifiedFitIntensitySM
		IR1B_SmearData(FitInt, OriginalQvector, SlitLengthUnif, UnifiedFitIntensitySM)
		FitInt=UnifiedFitIntensitySM
	endif
	
	IR3GP_MoveGlobalsToStr(Par)	
	IR3GP_SaveStructureToWave(Par, Level)
	IR3GP_UpdateIfSelected()
	IR3GP_AppendGuinierFit(level, 0, FitIntName)
	//IR1A_RecordErrorsAfterFit()
	SetDataFolder oldDf
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
Function IR3GP_CleanUpGraph(RemoveGunPorLocalFits,RemoveTags)
	variable RemoveGunPorLocalFits,RemoveTags

	DoWIndow  GuinierPorod_LogLogPlot
	if(!V_Flag)
		return 0
	endif
	if(RemoveGunPorLocalFits)
	RemoveFromGraph /W=GuinierPorod_LogLogPlot /Z FitLevel1Porod,FitLevel2Porod,FitLevel3Porod,FitLevel4Porod,FitLevel5Porod
	RemoveFromGraph /W=GuinierPorod_LogLogPlot /Z FitLevel1Guinier,FitLevel2Guinier,FitLevel3Guinier,FitLevel4Guinier,FitLevel5Guinier
	endif
	if(RemoveTags)
		Tag/K/N=Level1Tag
		Tag/K/N=Level2Tag
	endif
	return 1
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR3GP_AppendGuinierFit(level, overwride, FitWaveName)
	variable level, overwride
	string FitWaveName
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:GuinierPorod

	RemoveFromGraph /W=GuinierPorod_LogLogPlot /Z FitLevel1Guinier,FitLevel2Guinier,FitLevel3Guinier,FitLevel4Guinier,FitLevel5Guinier
	Wave FitWv=$("root:Packages:Irena:GuinierPorod:"+FitWaveName)	
	Wave OriginalQvector
	NVAR DisplayLocalFits
	
	if (DisplayLocalFits || overwride)				
		GetAxis /W=GuinierPorod_LogLogPlot /Q left
		AppendToGraph /W=GuinierPorod_LogLogPlot $(FitWaveName) vs OriginalQvector
		ModifyGraph /W=GuinierPorod_LogLogPlot lsize($(FitWaveName))=1,rgb($(FitWaveName))=(0,0,65280),lstyle($(FitWaveName))=3
		SetAxis /W=GuinierPorod_LogLogPlot left V_min, V_max
	endif	
	SetDataFolder oldDf
end
//****************************************************************************************************************
//****************************************************************************************************************

Function IR3GP_AppendPorodFit(level, overwride, FitWaveName)
	variable level, overwride
	string FitWaveName
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:GuinierPorod

	RemoveFromGraph /W=GuinierPorod_LogLogPlot /Z FitLevel1Porod,FitLevel2Porod,FitLevel3Porod,FitLevel4Porod,FitLevel5Porod
	Wave FitWv=$("root:Packages:Irena:GuinierPorod:"+FitWaveName)	
	Wave OriginalQvector
	NVAR DisplayLocalFits
	
	if (DisplayLocalFits || overwride)				
		GetAxis /W=GuinierPorod_LogLogPlot /Q left
		AppendToGraph /W=GuinierPorod_LogLogPlot $(FitWaveName) vs OriginalQvector
		ModifyGraph /W=GuinierPorod_LogLogPlot lsize($(FitWaveName))=1,rgb($(FitWaveName))=(0,0,65280),lstyle($(FitWaveName))=3
		SetAxis /W=GuinierPorod_LogLogPlot left V_min, V_max
	endif	
	SetDataFolder oldDf
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR3GP_FitLocalPorod(Level, whichOne)
	variable level, WhichOne	//1 for d, 2 for S1 and 3 for S2
	DFref oldDf= GetDataFolderDFR()

	STRUCT GuinierPorodLevel Par
	
	setDataFolder root:Packages:Irena:GuinierPorod
	
	Wave OriginalIntensity
	Wave OriginalQvector
	Wave OriginalError
	Duplicate/O OriginalIntensity, $("FitLevel"+num2str(Level)+"Porod")

	Wave FitInt=$("FitLevel"+num2str(Level)+"Porod")
	string FitIntName="FitLevel"+num2str(Level)+"Porod"
	
	if(whichOne==1)
		NVAR Pp = $("Level_P")
		NVAR PpLowLimit = $("Level_PLowLimit")
		NVAR PpHighLimit = $("Level_PHighLimit")
	elseif(whichOne==2)
		NVAR Pp = $("Level_S1")
		NVAR PpLowLimit = $("Level_S1LowLimit")
		NVAR PpHighLimit = $("Level_S1HighLimit")
	elseif(whichOne==3)
		NVAR Pp = $("Level_S2")
		NVAR PpLowLimit = $("Level_S2LowLimit")
		NVAR PpHighLimit = $("Level_S2HighLimit")
	else
		abort "Nothing to do"
	endif
	NVAR Gvalue=$("Level_G")
	NVAR Rg1=$("Level_Rg1")
	NVAR Pval=$("Level_P")
	NVAR S1=$("Level_S1")
	NVAR S2=$("Level_S2")
	NVAR Rg2=$("Level_Rg2")
	NVAR UseSMRData=root:Packages:Irena:GuinierPorod:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena:GuinierPorod:SlitLengthUnif


	if(whichOne==1)		//this is D
		S1=0
		S2=0
		Rg2=0
	elseif(whichOne==2)
		S2=0
		Rg2=0
	endif

	DoWindow GuinierPorod_LogLogPlot
	if(V_Flag)
		DoWindow/F GuinierPorod_LogLogPlot
	else
		abort
	endif
	if(strlen(CsrWave(A))<1 || strlen(CsrWave(B))<1)
		beep
		SetDataFolder oldDf
		abort "Set both cursors before fitting"
	endif
	variable CalibrationValue, CalibrationQ, OldG
	oldG=Gvalue
	//now handle calibration - G value needs to be modified if this is S1 or S2
	if(whichOne==2)		//this is S1
//		if(S1>0)	//this is wrong, If this is S1, the S1 before fitting must be 0 or the whole thing goes haywire...
//			Abort "To do local fit for S1 you need to have reasonably good fit for Rg1, G, and P done WITH S1=0"
//		endif
		if(Rg1>=1e6)	//this is wrong, Rg1 cannot be 1e6 (that is used to remove the Guinier from model and leave only last Powerlaw slope. 
			Abort "wrong Rg1 value found, this level makes no sense at this moment"
		endif
		CalibrationQ= 0.5*pi/Rg1
		CalibrationValue = IR2GP_CalculateGPValue(CalibrationQ,Pval,Rg1,Gvalue,S1,Rg2,S2,0)
	endif

	Make/D/O/N=2 CoefficientInput, New_FitCoefficients, LocalEwave
	Make/O/T/N=2 CoefNames
	//CoefficientInput[1]= Pp >=1 ? Pp : 2
	Pp = abs((log(OriginalIntensity[pcsr(A)])-log(OriginalIntensity[pcsr(B)]))/(log(OriginalQvector[pcsr(B)])-log(OriginalQvector[pcsr(A)])))
	if(UseSMRData)
		Pp+=1
	endif
	CoefficientInput[1] = Pp
	//print (OriginalIntensity[pcsr(A)]+OriginalIntensity[pcsr(B)])/2
	//print ((OriginalQvector[pcsr(A)]+OriginalQvector[pcsr(B)])/2)
	CoefficientInput[0]=((OriginalIntensity[pcsr(A)]+OriginalIntensity[pcsr(B)])/2)/(((OriginalQvector[pcsr(A)]+OriginalQvector[pcsr(B)])/2)^Pp)
	LocalEwave[0]=CoefficientInput[0]/30
	LocalEwave[1]=CoefficientInput[1]/50
	CoefNames={"Level"+num2str(level)+"B","Level"+num2str(level)+"P"}	
	Make/D/O/N=2 New_FitCoefficients
	New_FitCoefficients[0] = {CoefficientInput[0],Pp}
	Make/O/T/N=2 T_Constraints
	T_Constraints = {"K1 > 1","K1 < 4.2"}
	Variable V_FitError=0			//This should prevent errors from being generated	
	FuncFit/Q/N IR3GP_PowerLawFitAllATOnce New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave  /C=T_Constraints 
	if (V_FitError!=0)	//there was error in fitting
		beep
		//IR1A_UpdatePorodFit(level,0)
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	
	Pp=abs(New_FitCoefficients[1])
	FitInt=New_FitCoefficients[0]*OriginalQvector^(-Pp)
	if(UseSMRData)
		duplicate/Free  FitInt, UnifiedFitIntensitySM
		IR1B_SmearData(FitInt, OriginalQvector, SlitLengthUnif, UnifiedFitIntensitySM)
		FitInt=UnifiedFitIntensitySM
	endif
	variable scalingFactor
	if(whichOne==2)		//this is S1
		scalingFactor = CalibrationValue/IR2GP_CalculateGPValue(CalibrationQ,Pval,Rg1,Gvalue,Pp,Rg2,S2,0)
		Gvalue = Gvalue*scalingFactor
		//Gvalue =IR2GP_CalculateGPValue(CalibrationQ,Pval,Rg1,Gvalue,Pp,Rg2,S2,0)
	endif
	//now handle calibration - G value needs to be modified if this is P but Rg = 1e6 (no Guinier area for even first slope)
	if(whichOne==1&&Rg1>5.999e5)		//this is P
		CalibrationQ = OriginalQvector[pcsr(A)]
		variable FitIntValue = New_FitCoefficients[0]*CalibrationQ^(-Pp)
		Gvalue = (FitIntValue  * CalibrationQ^Pval * Rg1^(Pval) ) / (exp(-Pval/2)*(3*Pval/2)^(Pval/2))
		NVAR GLowLimit = $("Level_GLowLimit")
		NVAR GHighLimit = $("Level_GHighLimit")
		GLowLimit = Gvalue/10
		GHighLimit = Gvalue*10
	endif
	//set fitting limits
	if(PpLowLimit>Pp)
		PpLowLimit = 1
	endif
	if(PpHighLimit<Pp)
		PpHighLimit =4
	endif
	
	IR3GP_MoveGlobalsToStr(Par)	
	IR3GP_SaveStructureToWave(Par, Level)
	IR3GP_UpdateIfSelected()
	IR3GP_AppendPorodFit(level, 0, FitIntName)	
	//IR1A_UpdateUnifiedLevels(level, 0)
	SetDataFolder oldDf
end
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR3GP_PowerLawFitAllATOnce(parwave,ywave,xwave) : FitFunc
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
	

	NVAR UseSMRData=root:Packages:Irena:GuinierPorod:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena:GuinierPorod:SlitLengthUnif
	Wave OriginalQvector =root:Packages:Irena:GuinierPorod:OriginalQvector
	Duplicate/FREE OriginalQvector, tempPowerLawInt
	tempPowerLawInt = Prefactor * OriginalQvector^(-slope)
	if(UseSMRData)
		duplicate/FREE  tempPowerLawInt, tempPowerLawIntSM
		IR1B_SmearData(tempPowerLawInt, OriginalQvector, SlitLengthUnif, tempPowerLawIntSM)
		tempPowerLawInt=tempPowerLawIntSM
	endif
	doUpdate
	ywave = tempPowerLawInt[binarysearch(OriginalQvector,xwave[0])+p]
End

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


//****************************************************************************************************************
//****************************************************************************************************************


Function IR3GP_GuinierFitAllAtOnce(parwave,ywave,xwave) : FitFunc
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

	NVAR UseSMRData=root:Packages:Irena:GuinierPorod:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena:GuinierPorod:SlitLengthUnif
	Wave OriginalQvector =root:Packages:Irena:GuinierPorod:OriginalQvector
	Duplicate/Free OriginalQvector, tempGunInt
	//w[0]*exp(-q^2*w[1]^2/3)
	tempGunInt = Prefactor * exp(-OriginalQvector^2 * Rg^2/3)
	if(UseSMRData)
		duplicate/Free  tempGunInt, tempGunIntSM
		IR1B_SmearData(tempGunInt, OriginalQvector, SlitLengthUnif, tempGunIntSM)
		tempGunInt=tempGunIntSM
	endif
	
	ywave = tempGunInt[binarysearch(OriginalQvector,xwave[0])+p]	
	return 1
End
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//***********************************************************
//***********************************************************
//***********************************************************

function IR3GP_CalculateInvariant(level)
		variable level
	STRUCT GuinierPorodLevel Par
	//Par.Invariant

	IR3GP_LoadStructureFromWave(Par, level)
	variable Newnumpnts=2000, tempB, Qv
	make/Free/N=(Newnumpnts) qUnifiedfit,rUnifiedfit, rUnifiedfitq2
	variable maxQ=2*pi/(Par.Rg1/10)
	qUnifiedfit=(maxQ/Newnumpnts)*p	
	IR2GP_CalculateGPlevel(qUnifiedfit,rUnifiedfit,Par )
	runifiedfit[0]=runifiedfit[1]	
	rUnifiedfitq2=rUnifiedfit*qunifiedfit^2				// Int * Q^2 wave
	Qv=areaXY(qUnifiedfit, rUnifiedfitq2, 0, MaxQ)		//invariant, need to add "Porod tail"
	tempB=rUnifiedfit[newnumpnts-1]*maxQ^(Par.P)			//makes -4 extension match last point of fit
	//Qv+=abs((tempB*maxQ^(3-Par.P))/(Par.P-2))				//extends with -4 exponent
	Qv+=abs((-tempB*maxQ^(3-Par.P))/(3-Par.P))				//extends with -4 exponent - dws 12/2/2013
	//invariant+=abs(tempB*maxQ^(3-abs(tempPorod))/(abs(tempPorod)-2))//This one extrapolates with original P.. Wrong, DWS	
	 Par.Invariant = Qv* 1e24
	 IR3GP_SaveStructureToWave(Par, level)
	return Qv* 1e24  // cm-1A-3  mult by 1e24 for cm-4
end
//***********************************************************
//***********************************************************
//***********************************************************		

///          Confidence evaluation code
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

Function IR3GP_ConfidenceEvaluation()
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:GuinierPorod

	IR3GP_ConfEvResetList()
	DoWindow IR3GP_ConfEvaluationPanel
	if(!V_Flag)
		IR3GP_ConfEvaluationPanelF()
	else
		DoWindow/F IR3GP_ConfEvaluationPanel
	endif
	IR1_CreateResultsNbk()
	setDataFolder OldDf
end

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

Function IR3GP_ConfEvaluationPanelF() 
	PauseUpdate    		// building window...
	NewPanel /K=1/W=(405,136,793,600) as "Guinier-Porod Uncertainity Evaluation"
	DoWIndow/C IR3GP_ConfEvaluationPanel
	//ShowTools/A
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 3,textrgb= (1,4,52428)
	DrawText 60,29,"Parameter Uncertainity Evaluation "
	SVAR ConEvSelParameter=root:Packages:Irena:GuinierPorod:ConEvSelParameter
	PopupMenu SelectParameter,pos={8,59},size={163,20},proc=IR3GP_ConfEvPopMenuProc,title="Select parameter  "
	PopupMenu SelectParameter,help={"Select parameter to evaluate, it had to be fitted"}
	PopupMenu SelectParameter,popvalue=ConEvSelParameter,value= #"IR3GP_ConfEvalBuildListOfParams()"
	SetVariable ParameterMin,pos={15,94},size={149,14},bodyWidth=100,title="Min value"
	SetVariable ParameterMin,value= root:Packages:Irena:GuinierPorod:ConfEvMinVal
	SetVariable ParameterMax,pos={13,117},size={151,14},bodyWidth=100,title="Max value"
	SetVariable ParameterMax,value= root:Packages:Irena:GuinierPorod:ConfEvMaxVal
	SetVariable ParameterNumSteps,pos={192,103},size={153,14},bodyWidth=100,title="Num Steps"
	SetVariable ParameterNumSteps,value= root:Packages:Irena:GuinierPorod:ConfEvNumSteps
	SVAR Method = root:Packages:Irena:GuinierPorod:ConEvMethod
	PopupMenu Method,pos={70,150},size={212,20},proc=IR3GP_ConfEvPopMenuProc,title="Method   "
	PopupMenu Method,help={"Select method to be used for analysis"}
	PopupMenu Method,mode=1,popvalue=Method,value= #"\"Sequential, fix param;Sequential, reset, fix param;Centered, fix param;Random, fix param;Random, fit param;Vary data, fit params;\""
	checkbox AutoOverwrite pos={20,180}, title="Automatically overwrite prior results?", variable=root:Packages:Irena:GuinierPorod:ConfEvAutoOverwrite
	Checkbox AutoOverwrite help={"Check to avoid being asked if you want to overwrite prior results"}
	checkbox ConfEvAutoCalcTarget pos={20,200},title="Calculate ChiSq range?", variable=root:Packages:Irena:GuinierPorod:ConfEvAutoCalcTarget
	Checkbox ConfEvAutoCalcTarget help={"Check to calculate the ChiSquae range"}, proc=IR3GP_ConfEvalCheckProc
	checkbox ConfEvFixRanges pos={260,180}, title="Fix fit limits?", variable=root:Packages:Irena:GuinierPorod:ConfEvFixRanges
	Checkbox ConfEvFixRanges help={"Check to avoid being asked if you want to fix ranges during analysis"}
	NVAR tmpVal=root:Packages:Irena:GuinierPorod:ConfEvAutoCalcTarget
	SetVariable ConfEvTargetChiSqRange,pos={200,200}, limits={1,inf,0.003}, format="%1.4g", size={173,14},bodyWidth=80,title="ChiSq range target"
	SetVariable ConfEvTargetChiSqRange,value= root:Packages:Irena:GuinierPorod:ConfEvTargetChiSqRange, disable=2*tmpVal
	Button GetHelp,pos={284,37},size={90,20},proc=IR3GP_ConfEvButtonProc,title="Get Help"
	Button AnalyzeSelParam,pos={18,225},size={150,20},proc=IR3GP_ConfEvButtonProc,title="Analyze selected Parameter"
	Button AddSetToList,pos={187,225},size={150,20},proc=IR3GP_ConfEvButtonProc,title="Add  Parameter to List"
	Button AnalyzeListOfParameters,pos={18,250},size={150,20},proc=IR3GP_ConfEvButtonProc,title="Analyze list of Parameters"
	Button ResetList,pos={187,250},size={150,20},proc=IR3GP_ConfEvButtonProc,title="Reset List"
	Button RecoverFromAbort,pos={18,430},size={150,20},proc=IR3GP_ConfEvButtonProc,title="Recover from abort"
EndMacro

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
Function IR3GP_ConfEvalCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			SetVariable ConfEvTargetChiSqRange,win= GuinierPorod_LogLogPlot, disable=2*checked
			if(checked)
				IR3GP_ConfEvalCalcChiSqTarget()
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
Function IR3GP_ConfEvalCalcChiSqTarget()

		string oldDf=GetDataFolder (1)

	NVAR ConfEvAutoCalcTarget=root:Packages:Irena:GuinierPorod:ConfEvAutoCalcTarget
	NVAR ConfEvTargetChiSqRange = root:Packages:Irena:GuinierPorod:ConfEvTargetChiSqRange
	DoWIndow GuinierPorod_LogLogPlot
	if(V_Flag&&ConfEvAutoCalcTarget)
		variable startRange, endRange, Allpoints
		startRange=pcsr(A,"GuinierPorod_LogLogPlot")
		endRange=pcsr(B,"GuinierPorod_LogLogPlot")
		Allpoints = abs(endRange - startRange)
	//	ConfEvTargetChiSqRange = Allpoints
		
		NVAR NumberOfLevels= root:Packages:Irena:GuinierPorod:NumberOfLevels	
		string ParamNames="Rg1;G;P;Rg2;S1;S2;ETA;Pack;"
		variable i, j, NumFItVals
		string tempName, varName
		NumFItVals=0
		STRUCT GuinierPorodLevel Par
		NVAR FitSASBackground=root:Packages:Irena:GuinierPorod:FitSASBackground
		if(FitSASBackground)
			NumFItVals+=1
		endif
		For(i=1;i<=NumberOfLevels;i+=1)
			IR3GP_LoadLevelFromWave(i)	
			For(j=0;j<ItemsInList(ParamNames);j+=1)
				tempName="Level"+num2str(i)+"_"+stringFromList(j,ParamNames)
				varName="Level"+"_"+stringFromList(j,ParamNames)
				NVAR fitMe=$("root:Packages:Irena:GuinierPorod:"+varName+"Fit")
				if(fitMe)
					NumFItVals+=1
				endif
			endfor
		endfor
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
	setDataFolder oldDf
	return ConfEvTargetChiSqRange
end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************


Function/S IR3GP_ConfEvalBuildListOfParams()
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:GuinierPorod
	variable i,j
	SVAR ConfEvListOfParameters=root:Packages:Irena:GuinierPorod:ConfEvListOfParameters
	NVAR NumberOfLevels= root:Packages:Irena:GuinierPorod:NumberOfLevels
	//Build list of paramters which user was fitting, and therefore we can analyze stability for them
	
	string ParamNames="Rg1;G;P;Rg2;S1;S2;ETA;Pack;"
	ConfEvListOfParameters=""
	string tempName
	STRUCT GuinierPorodLevel Par
	For(i=1;i<=NumberOfLevels;i+=1)
		IR3GP_LoadStructureFromWave(Par, i)	
		IR3GP_MoveStrToGlobals(Par)
		For(j=0;j<ItemsInList(ParamNames);j+=1)
			tempName="Level"+num2str(i)+"_"+stringFromList(j,ParamNames)
			NVAR fitMe=$"Level_"+stringFromList(j,ParamNames)+"Fit"
			if(fitMe)
				ConfEvListOfParameters+=tempName+";"
			endif
		endfor
	endfor	
	//print ConfEvListOfParameters
	SVAR Method = root:Packages:Irena:GuinierPorod:ConEvMethod
	SVAR ConEvSelParameter=root:Packages:Irena:GuinierPorod:ConEvSelParameter
	if(strlen(Method)<5)
		Method = "Sequential, fix param"
	endif
	ConEvSelParameter = stringFromList(0,ConfEvListOfParameters)
	IR3GP_ConEvSetValues(ConEvSelParameter)
	setDataFolder OldDf
	return ConfEvListOfParameters+"UncertainityEffect;"
end

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
Function IR3GP_ConEvSetValues(popStr)
	string popStr
		SVAR ConEvSelParameter=root:Packages:Irena:GuinierPorod:ConEvSelParameter
		ConEvSelParameter = "Level_"+popStr[7,inf]
		variable SelLevel= str2num(popStr[5,5])
		STRUCT GuinierPorodLevel Par
		IR3GP_LoadStructureFromWave(Par, SelLevel)	
		IR3GP_MoveStrToGlobals(Par)
		NVAR/Z CurPar = $("root:Packages:Irena:GuinierPorod:"+ConEvSelParameter)
		if(!NVAR_Exists(CurPar))
			//something wrong here, bail out
			return 0
		endif
		NVAR CurparLL =  $("root:Packages:Irena:GuinierPorod:"+ConEvSelParameter+"LowLimit")
		NVAR CurparHL =  $("root:Packages:Irena:GuinierPorod:"+ConEvSelParameter+"HighLimit")
		NVAR ConfEvMinVal =  root:Packages:Irena:GuinierPorod:ConfEvMinVal
		NVAR ConfEvMaxVal =  root:Packages:Irena:GuinierPorod:ConfEvMaxVal
		NVAR ConfEvNumSteps =  root:Packages:Irena:GuinierPorod:ConfEvNumSteps
		if(ConfEvNumSteps<3)
			ConfEvNumSteps=20
		endif
		if(stringMatch(ConEvSelParameter,"*Rg*"))
			ConfEvMinVal = 0.8*CurPar
			ConfEvMaxVal = 1.2 * Curpar
		elseif(stringMatch(ConEvSelParameter,"*P"))
			ConfEvMinVal = 0.9*CurPar
			ConfEvMaxVal = 1.1 * Curpar
		elseif(stringMatch(ConEvSelParameter,"*G"))
			ConfEvMinVal = 0.5*CurPar
			ConfEvMaxVal = 2* Curpar
		elseif(stringMatch(ConEvSelParameter,"*S*"))
			ConfEvMinVal = 0.9*CurPar
			ConfEvMaxVal = 1.1* Curpar
		elseif(stringMatch(ConEvSelParameter,"*Eta"))
			ConfEvMinVal = 0.9*CurPar
			ConfEvMaxVal = 1.1* Curpar
		elseif(stringMatch(ConEvSelParameter,"*Pack"))
			ConfEvMinVal = 0.9*CurPar
			ConfEvMaxVal = 1.1* Curpar
		endif
		//check limits...
		if(CurparLL>ConfEvMinVal)
			ConfEvMinVal = 1.01*CurparLL
		endif
		if(CurparHL<ConfEvMaxVal)
			ConfEvMaxVal = 0.99 * CurparHL
		endif

end

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

Function IR3GP_ConfEvPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(stringMatch(pa.ctrlName,"SelectParameter"))
				if(stringmatch(popStr,"UncertainityEffect"))
					SVAR Method = root:Packages:Irena:GuinierPorod:ConEvMethod
					Method = "Vary data, fit params"
					SetVariable ParameterMin, win=IR3GP_ConfEvaluationPanel, disable=1
					SetVariable ParameterMax, win=IR3GP_ConfEvaluationPanel, disable=1
					PopupMenu Method, win=IR3GP_ConfEvaluationPanel, mode=6
					//IR3GP_ConEvSetValues(popStr)
		 		else
					SetVariable ParameterMin, win=IR3GP_ConfEvaluationPanel, disable=0
					SetVariable ParameterMax, win=IR3GP_ConfEvaluationPanel, disable=0
					SVAR Method = root:Packages:Irena:GuinierPorod:ConEvMethod
					PopupMenu Method, win=IR3GP_ConfEvaluationPanel, mode=1
					Method = "Sequential, fix param"
					IR3GP_ConEvSetValues(popStr)
				endif
			endif
			if(stringMatch(pa.ctrlname,"Method"))
				//here we do what is needed
				SVAR Method = root:Packages:Irena:GuinierPorod:ConEvMethod
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

Function IR3GP_ConfEvButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	SVAR SampleFullName=root:Packages:Irena:GuinierPorod:DataFolderName
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringMatch(ba.ctrlName,"GetHelp"))
				//Generate help 
				IR3GP_ConfEvHelp()
			endif
			if(stringMatch(ba.ctrlName,"AnalyzeSelParam"))
				//analyze this parameter 
				//SVAR ParamName = root:Packages:Irena:GuinierPorod:ConEvSelParameter
				ControlInfo /W=IR3GP_ConfEvaluationPanel  SelectParameter
				SVAR Method = root:Packages:Irena:GuinierPorod:ConEvMethod
				NVAR MinValue =root:Packages:Irena:GuinierPorod:ConfEvMinVal
				NVAR MaxValue =root:Packages:Irena:GuinierPorod:ConfEvMaxVal
				NVAR NumSteps =root:Packages:Irena:GuinierPorod:ConfEvNumSteps
				IR1_AppendAnyText("Evaluated sample :"+StringFromList(ItemsInList(SampleFullName,":")-1,SampleFullName,":"), 1)	
				IR3GP_ConEvEvaluateParameter(S_Value,MinValue,MaxValue,NumSteps,Method)
			endif
			if(stringMatch(ba.ctrlName,"AddSetToList"))
				//add this parameter to list
				IR3GP_ConfEvAddToList()
			endif
			if(stringMatch(ba.ctrlName,"ResetList"))
				//add this parameter to list
				IR3GP_ConfEvResetList()
			endif
			if(stringMatch(ba.ctrlName,"AnalyzeListOfParameters"))
				//analyze list of parameters
				IR1_AppendAnyText("Evaluated sample :"+StringFromList(ItemsInList(SampleFullName,":")-1,SampleFullName,":"), 1)	
				IR3GP_ConfEvAnalyzeList()
			endif
			if(stringMatch(ba.ctrlName,"RecoverFromAbort"))
				//Recover from abort
				//print ("root:ConfidenceEvaluation:"+possiblyquoteName(StringFromList(ItemsInList(SampleFullName,":")-1,SampleFullName,":")))
				IR3GP_ConEvRestoreBackupSet("root:ConfidenceEvaluation:"+possiblyquoteName(StringFromList(ItemsInList(SampleFullName,":")-1,SampleFullName,":")))
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
Function IR3GP_ConfEvResetList()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:GuinierPorod
	DoWIndow IR3GP_ConfEvaluationPanel
	if(V_Flag)
		ControlInfo /W=IR3GP_ConfEvaluationPanel  ListOfParamsToProcess
		if(V_Flag==11)
			KillControl /W=IR3GP_ConfEvaluationPanel  ListOfParamsToProcess	
		endif
	endif
	Wave/Z ConEvParamNameWv
	Wave/Z ConEvMethodWv
	Wave/Z ConEvMinValueWv
	Wave/Z ConEvMaxValueWv
	Wave/Z ConEvNumStepsWv
	Wave/Z ConEvListboxWv
	SVAR Method = root:Packages:Irena:GuinierPorod:ConEvMethod
	Method = "Sequential, fix param"
	
	Killwaves/Z ConEvParamNameWv, ConEvMethodWv, ConEvMinValueWv, ConEvMaxValueWv, ConEvNumStepsWv, ConEvListboxWv
	setDataFolder oldDf
end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
static Function IR3GP_ConfEvAnalyzeList()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:GuinierPorod
	DoWIndow IR3GP_ConfEvaluationPanel
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
		
		SVAR ParamName = root:Packages:Irena:GuinierPorod:ConEvSelParameter
		SVAR Method = root:Packages:Irena:GuinierPorod:ConEvMethod
		NVAR MinValue =root:Packages:Irena:GuinierPorod:ConfEvMinVal
		NVAR MaxValue =root:Packages:Irena:GuinierPorod:ConfEvMaxVal
		NVAR NumSteps =root:Packages:Irena:GuinierPorod:ConfEvNumSteps
	
	For(i=0;i<numpnts(ConEvParamNameWv);i+=1)
		ParamName=ConEvParamNameWv[i]
		//print "Evaluating stability of "+ParamName
		//PopupMenu SelectParameter, win=IR3GP_ConfEvaluationPanel, popmatch = ParamName
		//DoUpdate /W=IR3GP_ConfEvaluationPanel
		Method=ConEvMethodWv[i]
		MinValue=ConEvMinValueWv[i]
		MaxValue=ConEvMaxValueWv[i]
		NumSteps=ConEvNumStepsWv[i]
		print "Evaluating stability of "+ParamName
		IR3GP_ConEvEvaluateParameter(ParamName,MinValue,MaxValue,NumSteps,Method)
	endfor

	DoWIndow IR3GP_ConfEvaluationPanel
	if(V_Flag)
		DoWIndow/F IR3GP_ConfEvaluationPanel
	endif
	
	setDataFolder oldDf
end



//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
static Function IR3GP_ConfEvAddToList()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:GuinierPorod
	//SVAR ParamName = root:Packages:Irena:GuinierPorod:ConEvSelParameter
	string ParamName
	ControlInfo /W=IR3GP_ConfEvaluationPanel  SelectParameter 
	ParamName = S_Value
	SVAR Method = root:Packages:Irena:GuinierPorod:ConEvMethod
	NVAR MinValue =root:Packages:Irena:GuinierPorod:ConfEvMinVal
	NVAR MaxValue =root:Packages:Irena:GuinierPorod:ConfEvMaxVal
	NVAR NumSteps =root:Packages:Irena:GuinierPorod:ConfEvNumSteps
		
	Wave/Z/T ConEvParamNameWv=root:Packages:Irena:GuinierPorod:ConEvParamNameWv
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
	
	ControlInfo /W=IR3GP_ConfEvaluationPanel  ListOfParamsToProcess
	if(V_Flag!=11)
		ListBox ListOfParamsToProcess win=IR3GP_ConfEvaluationPanel, pos={10,280}, size={370,140}, mode=0
		ListBox ListOfParamsToProcess listWave=root:Packages:Irena:GuinierPorod:ConEvListboxWv
		ListBox ListOfParamsToProcess help={"This is list of parameters selected to be processed"}	
	endif
	setDataFolder oldDf
end


//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
static function IR3GP_ConEvFixParamsIfNeeded()
	
	DFref oldDf= GetDataFolderDFR()

	NVAR ConfEvFixRanges = root:Packages:Irena:GuinierPorod:ConfEvFixRanges
	if(ConfEvFixRanges)
		IR3GP_FixLimits()
	endif
	setDataFolder oldDf
end 

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
static Function IR3GP_ConEvEvaluateParameter(ParamName,MinValue,MaxValue,NumSteps,Method)
	Variable MinValue,MaxValue,NumSteps
	String ParamName,Method
	
	KillWIndow/Z ChisquaredAnalysis
 	KillWIndow/Z ChisquaredAnalysis2
 	//create folder where we dump this thing...
	NewDataFolder/O/S root:ConfidenceEvaluation
	SVAR SampleFullName=root:Packages:Irena:GuinierPorod:DataFolderName
	NVAR ConfEvAutoOverwrite = root:Packages:Irena:GuinierPorod:ConfEvAutoOverwrite
	string Samplename=StringFromList(ItemsInList(SampleFullName,":")-1,SampleFullName,":")
	SampleName=IN2G_RemoveExtraQuote(Samplename,1,1)
	NewDataFolder /S/O $(Samplename)
	Wave/Z/T BackupParamNames
	if(checkName(ParamName,11)!=0 && !ConfEvAutoOverwrite)
		DoALert /T="Folder Name Conflict" 1, "Folder with name "+ParamName+" found, do you want to overwrite prior Confidence Evaluation results?"
		if(!V_Flag)
			abort
		endif
	endif
	if(!WaveExists(BackupParamNames))
		IR3GP_ConEvBackupCurrentSet(GetDataFolder(1))
		print "Stored setting in case of abort, this can be reset by button Reset from abort"
	endif
	NewDataFolder /S/O $(ParamName)
	string BackupFilesLocation=GetDataFolder(1)
	IR3GP_ConEvBackupCurrentSet(BackupFilesLocation)
	//calculate chiSquare target if users asks for it..
	IR3GP_ConfEvalCalcChiSqTarget()
	NVAR ConfEvAutoCalcTarget=root:Packages:Irena:GuinierPorod:ConfEvAutoCalcTarget
	NVAR ConfEvTargetChiSqRange = root:Packages:Irena:GuinierPorod:ConfEvTargetChiSqRange
	variable i, currentParValue, tempi
	make/O/N=0  $(ParamName+"ChiSquare")
	Wave ChiSquareValues=$(ParamName+"ChiSquare")
	NVAR AchievedChisq = root:Packages:Irena:GuinierPorod:AchievedChisq
	variable SortForAnalysis=0
	variable FittedParameter=0


	if(stringMatch(ParamName,"UncertainityEffect"))
		if(stringMatch(Method,"Vary data, fit params"))
			Wave OriginalIntensity = root:Packages:Irena:GuinierPorod:OriginalIntensity
			Wave OriginalError = root:Packages:Irena:GuinierPorod:OriginalError
			Duplicate/O OriginalIntensity, ConEvIntensityBackup
			For(i=0;i<NumSteps+1;i+=1)
				OriginalIntensity = ConEvIntensityBackup + gnoise(OriginalError[p])
				IR3GP_ConEvFixParamsIfNeeded()
				IR3GP_PanelButtonProc("DoFittingSkipReset")
				Wave/T CoefNames=root:Packages:Irena:GuinierPorod:CoefNames
				Wave ValuesAfterFit=root:Packages:Irena:GuinierPorod:W_coef
				Wave ValuesBeforeFit = root:Packages:Irena:GuinierPorod:CoefficientInput
				Duplicate/O CoefNames, ConfEvCoefNames
				Wave/Z ConfEvStartValues
				if(!WaveExists(ConfEvStartValues))
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
				IR3GP_ConEvRestoreBackupSet(BackupFilesLocation)		
			endfor	
			OriginalIntensity = ConEvIntensityBackup
			IR3GP_ConEvRestoreBackupSet(BackupFilesLocation)
			SetDataFolder BackupFilesLocation
			IR3GP_ConEvAnalyzeEvalResults2(ParamName)
		endif	
	else		//parameter methods
		//Metod = "Sequential, fix param;Sequential, reset, fix param;Random, fix param;Random, fit param;"
		variable SelLevel= str2num(ParamName[5,5])
		STRUCT GuinierPorodLevel Par		
		make/O/N=0 $(ParamName+"StartValue"), $(ParamName+"EndValue"), $(ParamName+"ChiSquare")
		Wave StartValues=$(ParamName+"StartValue")
		Wave EndValues=$(ParamName+"EndValue")
		TabControl LevelsTabs win=IR3DP_MainPanel, value=SelLevel-1
		IR3GP_PanelTabControl("",SelLevel-1)
		IR3GP_LoadLevelFromWave(SelLevel)		

		NVAR Param=$("root:Packages:Irena:GuinierPorod:"+"Level_"+ParamName[7,inf])
		NVAR ParamFit=$("root:Packages:Irena:GuinierPorod:"+"Level_"+ParamName[7,inf]+"Fit")
		variable StartHere=Param
		variable step=(MaxValue-MinValue)/(NumSteps)
		if(stringMatch(Method,"Sequential, fix param"))
			For(i=0;i<NumSteps+1;i+=1)
				redimension/N=(i+1) StartValues, EndValues, ChiSquareValues
				currentParValue = MinValue+ i* step
				StartValues[i]=currentParValue
				IR3GP_LoadLevelFromWave(SelLevel)		
				ParamFit=0
				Param = currentParValue
				IR3GP_MoveLevelToWave(SelLevel)		
				IR3GP_ConEvFixParamsIfNeeded()
				IR3GP_PanelButtonProc("DoFittingSkipReset")
				EndValues[i]=Param
				ChiSquareValues[i]=AchievedChisq
				DoUpdate
				sleep/s 1
			endfor
			SortForAnalysis=0
			FittedParameter=0
		elseif(stringMatch(Method,"Sequential, reset, fix param"))
			For(i=0;i<NumSteps+1;i+=1)
				redimension/N=(i+1) StartValues, EndValues, ChiSquareValues
				currentParValue = MinValue+ i* step
				StartValues[i]=currentParValue
				IR3GP_LoadLevelFromWave(SelLevel)		
				//NVAR Param=$("root:Packages:Irena:GuinierPorod:"+"Level_"+ParamName[7,inf])
				//NVAR ParamFit=$("root:Packages:Irena:GuinierPorod:"+"Level_"+ParamName[7,inf]+"Fit")
				ParamFit=0
				Param = currentParValue
				IR3GP_MoveLevelToWave(SelLevel)		
				IR3GP_ConEvFixParamsIfNeeded()
				IR3GP_PanelButtonProc("DoFittingSkipReset")
				EndValues[i]=Param
				ChiSquareValues[i]=AchievedChisq
				DoUpdate
				sleep/s 1	
				IR3GP_PanelButtonProc("RevertFitting")		
			endfor
			SortForAnalysis=0
			FittedParameter=0
		elseif(stringMatch(Method,"Centered, fix param"))
			tempi=0
			variable NumSteps2=Ceil(NumSteps/2)
			For(i=0;i<NumSteps2;i+=1)
				tempi+=1
				redimension/N=(tempi) StartValues, EndValues, ChiSquareValues
				currentParValue = StartHere - i* step
				StartValues[tempi-1]=currentParValue
				IR3GP_LoadLevelFromWave(SelLevel)		
				//NVAR Param=$("root:Packages:Irena:GuinierPorod:"+"Level_"+ParamName[7,inf])
				//NVAR ParamFit=$("root:Packages:Irena:GuinierPorod:"+"Level_"+ParamName[7,inf]+"Fit")
				ParamFit=0
				Param = currentParValue
				IR3GP_MoveLevelToWave(SelLevel)		
				IR3GP_ConEvFixParamsIfNeeded()
				IR3GP_PanelButtonProc("DoFittingSkipReset")
				EndValues[tempi-1]=Param
				ChiSquareValues[tempi-1]=AchievedChisq
				DoUpdate
				sleep/s 1	
			endfor
			IR3GP_ConEvRestoreBackupSet(BackupFilesLocation)		
			For(i=0;i<NumSteps2;i+=1)		//and now 
				tempi+=1
				redimension/N=(tempi) StartValues, EndValues, ChiSquareValues
				currentParValue = StartHere + i* step
				StartValues[tempi-1]=currentParValue
				IR3GP_LoadLevelFromWave(SelLevel)		
				//NVAR Param=$("root:Packages:Irena:GuinierPorod:"+"Level_"+ParamName[7,inf])
				//NVAR ParamFit=$("root:Packages:Irena:GuinierPorod:"+"Level_"+ParamName[7,inf]+"Fit")
				ParamFit=0
				Param = currentParValue
				IR3GP_MoveLevelToWave(SelLevel)		
				IR3GP_ConEvFixParamsIfNeeded()
				IR3GP_PanelButtonProc("DoFittingSkipReset")
				EndValues[tempi-1]=Param
				ChiSquareValues[tempi-1]=AchievedChisq
				DoUpdate
				sleep/s 1	
			endfor
			IR3GP_ConEvRestoreBackupSet(BackupFilesLocation)		
			SortForAnalysis=1
			FittedParameter=0
		elseif(stringMatch(Method,"Random, fix param"))
			For(i=0;i<NumSteps+1;i+=1)
				redimension/N=(i+1) StartValues, EndValues, ChiSquareValues
				currentParValue = MinValue + (0.5+enoise(0.5))*(MaxValue-MinValue)
				StartValues[i]=currentParValue
				IR3GP_LoadLevelFromWave(SelLevel)		
				//NVAR Param=$("root:Packages:Irena:GuinierPorod:"+"Level_"+ParamName[7,inf])
				//NVAR ParamFit=$("root:Packages:Irena:GuinierPorod:"+"Level_"+ParamName[7,inf]+"Fit")
				ParamFit=0
				Param = currentParValue
				IR3GP_MoveLevelToWave(SelLevel)		
				IR3GP_ConEvFixParamsIfNeeded()
				IR3GP_PanelButtonProc("DoFittingSkipReset")
				EndValues[i]=Param
				ChiSquareValues[i]=AchievedChisq
				DoUpdate
				sleep/s 1	
				//IR3GP_ConEvRestoreBackupSettings(BackupFilesLocation)		
			endfor
			SortForAnalysis=1
			FittedParameter=0
		elseif(stringMatch(Method,"Random, fit param"))
			For(i=0;i<NumSteps+1;i+=1)
				redimension/N=(i+1) StartValues, EndValues, ChiSquareValues
				currentParValue = MinValue + (0.5+enoise(0.5))*(MaxValue-MinValue)
				StartValues[i]=currentParValue
				IR3GP_LoadLevelFromWave(SelLevel)		
				//NVAR Param=$("root:Packages:Irena:GuinierPorod:"+"Level_"+ParamName[7,inf])
				//NVAR ParamFit=$("root:Packages:Irena:GuinierPorod:"+"Level_"+ParamName[7,inf]+"Fit")
				ParamFit=1
				Param = currentParValue
				IR3GP_MoveLevelToWave(SelLevel)		
				IR3GP_ConEvFixParamsIfNeeded()
				IR3GP_PanelButtonProc("DoFittingSkipReset")
				EndValues[i]=Param
				ChiSquareValues[i]=AchievedChisq
				DoUpdate
				sleep/s 1	
				//IR3GP_ConEvRestoreBackupSettings(BackupFilesLocation)		
			endfor	
			SortForAnalysis=1
			FittedParameter=1
		endif
		IR3GP_LoadLevelFromWave(SelLevel)		
		NVAR ParamFit=$("root:Packages:Irena:GuinierPorod:"+"Level_"+ParamName[7,inf]+"Fit")
		ParamFit=1
		IR3GP_MoveLevelToWave(SelLevel)		
		
		IR3GP_ConEvRestoreBackupSet(BackupFilesLocation)
		IR3GP_PanelButtonProc("GraphDistribution")

		TabControl LevelsTabs win=IR3DP_MainPanel, value=SelLevel-1
		IR3GP_PanelTabControl("",SelLevel-1)
	
		//something changed data folder, set it back for following functions
		SetDataFolder BackupFilesLocation
		IR3GP_ConEvAnalyzeEvalResults(ParamName, SortForAnalysis,FittedParameter)

	endif	//end of parameters analysis
	DoWIndow IR3GP_ConfEvaluationPanel
	if(V_Flag)
		DoWIndow/F IR3GP_ConfEvaluationPanel
	endif

end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

static Function IR3GP_ConEvAnalyzeEvalResults2(ParamName)
	string ParamName
	print GetDataFOlder(1)
	SVAR SampleFullName=root:Packages:Irena:GuinierPorod:DataFolderName
	NVAR ConfEVNumSteps=root:Packages:Irena:GuinierPorod:ConfEVNumSteps
	Wave ConfEvStartValues=$("ConfEvStartValues")
	Wave ConfEvEndValues=$("ConfEvEndValues")
	Wave/T ConfEvCoefNames=$("ConfEvCoefNames")
	Wave ChiSquareValues=$(ParamName+"ChiSquare")
	
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
	IR1_AppendAnyText("Run "+num2str(ConfEVNumSteps)+" fittings using data modified by random Gauss noise within \"Errors\" ", 2)
	IR1_AppendAnyText("To get following statistical results ", 0)
	wavestats/Q ChiSquareValues
	variable MeanChiSquare=V_avg
	variable StdDevChiSquare=V_sdev
	IR1_AppendAnyText("Chi-square values : \taverage = "+num2str(MeanChiSquare)+"\tst. dev. = "+num2str(StdDevChiSquare), 0)	

	variable j
	string tempStrName
	For(j=0;j<numpnts(ConfEvCoefNames);j+=1)
		tempStrName=ConfEvCoefNames[j]
		Duplicate/Free/O/R=[j][] ConfEvEndValues, tempWv
		wavestats/Q tempWv
		IR1_AppendAnyText(tempStrName+" : \taverage = "+num2str(V_avg)+"\tst. dev. = "+num2str(V_sdev), 0)	
		
	endfor
		 

end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

static Function IR3GP_ConEvAnalyzeEvalResults(ParamName,SortForAnalysis,FittedParameter)
	string ParamName
	variable SortForAnalysis,FittedParameter
	
	NVAR ConfEvTargetChiSqRange = root:Packages:Irena:GuinierPorod:ConfEvTargetChiSqRange
	SVAR SampleFullName=root:Packages:Irena:GuinierPorod:DataFolderName
	Wave StartValues=$(ParamName+"StartValue")
	Wave EndValues=$(ParamName+"EndValue")
	Wave ChiSquareValues=$(ParamName+"ChiSquare")
	SVAR Method = root:Packages:Irena:GuinierPorod:ConEvMethod
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
		AppendToGraph EndValuesGraphMax,EndValuesGraphMin,EndValuesGraphAvg vs StartValues	
		ModifyGraph lstyle(EndValuesGraphMax)=1,rgb(EndValuesGraphMax)=(0,0,0)
		ModifyGraph lstyle(EndValuesGraphMin)=1,rgb(EndValuesGraphMin)=(0,0,0)
		ModifyGraph lstyle(EndValuesGraphAvg)=7,lsize(EndValuesGraphAvg)=2
		ModifyGraph rgb(EndValuesGraphAvg)=(0,0,0)
		TextBox/C/N=text0/F=0/A=LT "Average = "+num2str(V_avg)+"\rStandard deviation = "+num2str(V_sdev)+"\rMinimum = "+num2str(V_min)+", maximum = "+num2str(V_min)
	
		AutoPositionWindow/M=0/R=IR3GP_ConfEvaluationPanel ChisquaredAnalysis
		AutoPositionWindow/M=0/R=ChisquaredAnalysis ChisquaredAnalysis2

		IR1_CreateResultsNbk()
//		IR1_AppendAnyText("Analyzed sample "+SampleFullName, 1)	
		IR1_AppendAnyText("Unified fit uncertainity of parameter "+ParamName, 2)
		IR1_AppendAnyText("  ", 0)
		IR1_AppendAnyText("Method used to evaluate parameter reproducibility: "+Method, 0)	
		//IR1_AppendAnyText("Minimum chi-squared found = "+num2str(V_min)+" for "+ParamName+"  = "+ num2str(EndValues[V_minLoc]), 0)
		//IR1_AppendAnyText("Range of "+ParamName+" in which the chi-squared < 1.037*"+num2str(V_min)+" is from "+num2str(levellow)+" to "+ num2str(levelhigh), 0)
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
			IR1_AppendAnyText("Unified fit evaluation of parameter "+ParamName+" failed", 2)
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
			AutoPositionWindow/M=0/R=IR3GP_ConfEvaluationPanel ChisquaredAnalysis
			IR1_CreateResultsNbk()
	//		IR1_AppendAnyText("Analyzed sample "+SampleFullName, 1)	
			IR1_AppendAnyText("Unified fit evaluation of parameter "+ParamName, 2)
			IR1_AppendAnyText("  ", 0)
			IR1_AppendAnyText("Method used to evaluate parameter stability: "+Method, 0)	
			IR1_AppendAnyText("Minimum chi-squared found = "+num2str(V_min)+" for "+ParamName+"  = "+ num2str(EndValues[V_minLoc]), 0)
			IR1_AppendAnyText("Range of "+ParamName+" in which the chi-squared < "+num2str(ConfEvTargetChiSqRange)+"*"+num2str(V_min)+" is from "+num2str(levellow)+" to "+ num2str(levelhigh), 0)
			IR1_AppendAnyText("           **************************************************     ", 0)
			IR1_AppendAnyText("\"Simplistic presentation\" for publications :    >>>>   "+ParamName+" =  "+IN2G_roundToUncertainity(EndValues[V_minLoc], (levelhigh - levellow)/2,2),0)
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

Function IR3GP_ConEvRestoreBackupSet(BackupLocation)
	string BackupLocation
	//restores backup waves (names/values) for all parameters used in current folder
	DFref oldDf= GetDataFolderDFR()

	setDataFolder $(BackupLocation)
	Wave/T BackupParamNames
	Wave BackupParamValues
	variable i, j, curLevel
	string tempName, CurShortName
	For(i=0;i<numpnts(BackupParamValues);i+=1)
			tempName=BackupParamNames[i]
			if(!stringmatch(tempName,"SASBackground"))
				CurShortName = tempName[0,4]+ tempName[6,inf]
				curLevel=str2num(tempName[5,5])
				NVAR CurPar = $("root:Packages:Irena:GuinierPorod:"+CurShortName)
				IR3GP_LoadLevelFromWave(curLevel)
				CurPar = BackupParamValues[i]
				IR3GP_MoveLevelToWave(curLevel)
			else
				NVAR CurPar = $("root:Packages:Irena:GuinierPorod:"+tempName)
				CurPar = BackupParamValues[i]
			endif
	endfor	
	setDataFolder oldDf
	
end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

static Function IR3GP_ConEvBackupCurrentSet(BackupLocation)
	string BackupLocation
	//creates backup waves (names/values) for all parameters used in current folder
	DFref oldDf= GetDataFolderDFR()

	//create folder where we dump this thing...
	setDataFolder $(BackupLocation)
	NVAR NumberOfLevels= root:Packages:Irena:GuinierPorod:NumberOfLevels	
	string ParamNames="Rg1;Rg2;G;P;S1;S2;ETA;Pack;"
	make/O/N=1/T BackupParamNames
	make/O/N=1 BackupParamValues
	variable i, j
	string tempName, VarName
	BackupParamNames[0]="SASBackground"
	NVAR SASBackground=root:Packages:Irena:GuinierPorod:SASBackground
	BackupParamValues=SASBackground
	For(i=1;i<=NumberOfLevels;i+=1)
		IR3GP_LoadLevelFromWave(i)		
		For(j=0;j<ItemsInList(ParamNames);j+=1)
			tempName="Level"+num2str(i)+"_"+stringFromList(j,ParamNames)
			VarName = "Level_"+stringFromList(j,ParamNames)
			NVAR CurPar = $("root:Packages:Irena:GuinierPorod:"+VarName)
			redimension/N=(numpnts(BackupParamValues)+1) BackupParamValues, BackupParamNames
			BackupParamNames[numpnts(BackupParamNames)-1]=tempName
			BackupParamValues[numpnts(BackupParamNames)-1]=CurPar
		endfor
	endfor	
	setDataFolder oldDf	
end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************


Function IR3GP_ConfEvHelp()

	DoWindow ConfidenceEvaluationHelp
	if(V_Flag)
		DoWindow/F ConfidenceEvaluationHelp
	else
		String nb = "ConfidenceEvaluationHelp"
		NewNotebook/N=$nb/F=1/V=1/K=1/W=(444,66,960,820)
		Notebook $nb defaultTab=36, statusWidth=252
		Notebook $nb showRuler=1, rulerUnits=1, updating={1, 3600}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
		Notebook $nb ruler=Normal, fSize=14, fStyle=1, textRGB=(52428,1,1), text="Uncertainity evaluation for Guinier - Porod parameters\r"
		Notebook $nb fSize=-1, fStyle=1, textRGB=(0,1,3), text="\r"
		Notebook $nb text="This tool is used to estimate uncertainities for the fitted parameters. "
		Notebook $nb text="It is likely that the right uncertainity is some combination of the two implemented methods - or the larger one...", fStyle=-1, text="\r"
		Notebook $nb fStyle=1, text="\r"
		Notebook $nb text="1. \"Uncertainity effect\" \r", fStyle=-1
		//Notebook $nb text="1. Sequential, fix param", fStyle=-1
		Notebook $nb text="Evaluates the influence of DATA uncertainities on uncertainity of Guinier - Porod parameter(s). "
		Notebook $nb text="Code varies Intensity data within user provided uncertainities (\"errors\"). All parameters currently selected for fitting are evaluted at once.\r"
		Notebook $nb fStyle=1, text="2. Uncertainity for individual parameters \r", fStyle=-1
		Notebook $nb text="Analysis of quality of fits achievable with tested parameter variation.  "
		Notebook $nb text="The tool will fix tested parameter within the user defined range and fit the other parameters to the data. Plot of achieved chi-squared as function of the fixed value of the tested parameter "
		Notebook $nb text="is used to estimate uncertainity. User needs to pick method of analysis as described below. User can analyze one parameter or create list of parameters and analyze them sequentially. \r"
		Notebook $nb text="\r"
		Notebook $nb text="All parameters which are supposed to be varied during analysis must have \"Fit?\" checkbox checked before the tool si started. Correct fitting limits may be set or use \"Fix fit limits\" checkbox. "
		Notebook $nb text="Range of data for fitting must be selected correctly with cursors (Unified fit) or set for data with controls (Modeling). The code does not mo"
		Notebook $nb text="dify fitting range. \r"
		Notebook $nb text="\r"
		Notebook $nb text="for \"Uncertainity effect\" but for the single parameter tests the results are untested. It may work, but if not - let me know... \r"
		Notebook $nb text="\r"
		Notebook $nb text="For each evaluated parameter the input is its name, range of values (Min/Max) to be stepped through and number "
		Notebook $nb text="of steps (default 20) to take. Depending on the type of parameter, different default Min/Max are generated for thi"
		Notebook $nb text="s analysis when parameter is selected. If the default for any parameters is systematically wrong, let me know and I'll fix it. \r"
		Notebook $nb text="\r"
		Notebook $nb text="You may need to play with fitting limits as it is likely there may be some fitting failures with wrong limits or using too large testing range. No attempt is made \r"
		Notebook $nb text="to gracefully recover from major fitting disasters. The main help is use of button \"Recover from abort\" if you have to abort the fittings.  \r"
		Notebook $nb text="\r"
		Notebook $nb text="After analysis is done, results are recorded in the ResultsNotebook and waves with results for further a"
		Notebook $nb text="nalysis are stored in root:ConfidenceEvaluation:<SampleName>:<Parametername>. Stored are waves names as"
		Notebook $nb text=" follows: <Parameter>ChiSquare, <Parameter>StartValue, <Parameter>EndValue. If the parameter is not fitt"
		Notebook $nb text="ed during evaluation Start and End values are the same. \r"
		Notebook $nb fStyle=1, text="\r"
		Notebook $nb text="Analysis of effect of data uncertainities (\"Uncertainity effect\")", fStyle=-1, text=":\r"
		Notebook $nb fStyle=1, text="Vary data, fit parameters", fStyle=-1
		Notebook $nb text=": Data are varied by adding to input intensity Gaussian noise with standard deviation equal to the unc"
		Notebook $nb text="rtainities provided by user (aka: \"Error data\"). No other scaling is done. "
		Notebook $nb text="All selected parameters are fitted selected number of times and statistics is generated in notebook.     \r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="Methods for analysis for individual parameters", fStyle=-1, text=":\r"
		Notebook $nb fStyle=1, text="1. Sequential, fix param", fStyle=-1
		Notebook $nb text=": Tested parameter is set to Min and all other parameters selected by user for fitting are fit"
		Notebook $nb text="ted. Chi-squared is recorded. Parameter is increased by step (Max-Min/NumberOfSteps) and fitting is done"
		Notebook $nb text=" again - using the result of the prior fit as starting condition.     \r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="2. Sequential, reset, fix param", fStyle=-1
		Notebook $nb text=": Tested parameter is set to Min and all other parameters selected by user for fitting  are fi"
		Notebook $nb text="tted. Chi-squared is recorded. Unified fit is reset to have the parameters which were set byu user before the evaluation"
		Notebook $nb text=" was started. Parameter is increased by step (Max-Min/NumberOfSteps) and fitting is done again - therefore using t"
		Notebook $nb text="he original user settings as the starting condition.  \r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="3. Centered, fix param", fStyle=-1
		Notebook $nb text=": Tested parameter is varied from start value towards Min, using previous fit result as starting condi"
		Notebook $nb text="tion. When Min is reached, the UF is reset to start position and parameter is varied up to Max"
		Notebook $nb text=". Chi-squared is recorded for each parameter value.\r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="4. Random, fix param", fStyle=-1
		Notebook $nb text=": User defined number of random values for the tested parameter are selected in the user defined  range of data"
		Notebook $nb text=" and for each the fit is performed while using the prior setting as starting condition. Chi-squared is r"
		Notebook $nb text="ecorded.\r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="5. Random, fit param", fStyle=-1
		Notebook $nb text=": User defined number of random starting values for the parameter are selected in the user defined range"
		Notebook $nb text=" of data and for each the fit is performed - including fitting this parameter - using prior setting as s"
		Notebook $nb text="tarting condition. Chi-squared is recorded as well as starting and ending parameter values. "
		Notebook $nb selection={startOfFile, startOfFile}, findText={"",1}
	endif

end

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

