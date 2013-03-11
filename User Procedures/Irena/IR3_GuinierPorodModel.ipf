#pragma rtGlobals=3		// Use modern global access method.
#pragma version=0.91		//this is Irena package Guinier-Porod model based on Hammouda's paper
// J. Appl. Cryst. (2010). 43, 716Ð719, Boualem Hammouda, A new GuinierÐPorod model
Constant IR3GPversionNumber=0.91

//*************************************************************************\
//* Copyright (c) 2005 - 2013, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/
//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from usaxs.xray.aps.anl.gov/
//Jan Ilavsky, February 2013
//please, read Readme distributed with the package
//report any problems to: ilavsky@aps.anl.gov 

//version history
// 0.9 - original release, unfinished, barely functional, no manual support. 
//0.91 GUI improvements, local fits improvements. 

//Menu "SAS"
//	"Gunier Porod Fit", IR3GP_Main()
//	help = {"Modeling of SAS as Guinier and Power law dependecies, based on Gunier-Porod model by Bualem Hammouda"}
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

structure GunierPorodLevel
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
	variable  d
	int16  dFit
	variable  dLowLimit
	variable  dHighLimit
	variable  dError
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
	STRUCT GunierPorodLevel &Par

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
	Level_P = Par.D
	NVAR Level_PFit
	Level_PFit = Par.DFit
	NVAR Level_PLowLimit
	Level_PLowLimit = Par.DLowLimit
	NVAR Level_PHighLimit
	Level_PHighLimit = Par.DHighLimit
	NVAR Level_PError
	Level_PError = Par.DError

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
	STRUCT GunierPorodLevel &Par

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
	 Par.D = Level_P
	NVAR Level_PFit
	 Par.DFit = Level_PFit
	NVAR Level_PLowLimit
	 Par.DLowLimit = Level_PLowLimit
	NVAR Level_PHighLimit
	 Par.DHighLimit = Level_PHighLimit
	NVAR Level_PError
	 Par.DError = Level_PError

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
Function IR3GP_SaveStructureToWave(Par, level)
	STRUCT GunierPorodLevel &Par
	variable level
	
	Wave LevelStructure = $("root:Packages:Irena:GuinierPorod:Level"+num2str(level)+"Structure")
	StructPut Par, LevelStructure
end
//******************************************************************************************
//******************************************************************************************
Function IR3GP_LoadStructureFromWave(Par, level)
	STRUCT GunierPorodLevel &Par
	variable level
	
	Wave LevelStructure = $("root:Packages:Irena:GuinierPorod:Level"+num2str(level)+"Structure")
	StructGet Par, LevelStructure
end
//******************************************************************************************
//******************************************************************************************
//******************************************************************************************

Function IR2GP_CalculateGPlevel(Qvector,Intensity,Par )
	wave Qvector, Intensity
	STRUCT GunierPorodLevel &Par

//for non spherical (infinitely large) objects with two Guinier areas - (s1!=0, s1!=0)
// for Q<Q2		: 	I(Q) = G2/Q2^s2 * exp(-Q^2 * Rg2^2 / (3-s2))
// for Q<Q1		: 	I(Q) = G1/Q^s1 * exp(-Q^2 * Rg1^2 / (3-s1))
// for Q>=Q1 	: 	I(Q) = D / Q^d
// Q2 = sqrt((1 - s2)/((2/(3-s2)*Rg2^2) - (2/(3-s1))*Rg1^2) )
// G2 = G1* exp(-Q2^2*((Rg1^2/(3-s1))-(Rg2^2/(3-s2)))) * Q2^(s2-s1)
// Q1 = sqrt((d - s1)*(3 - s1)/2) / Rg1
// D = G * exp(-Q1^2 * Rg^2/(3-s))*Q1^(d-s) = G*exp(-(d-s)/2)*((3-s)*(d-s)/2)^((d-s)/2) /Rg^(d-s)
	variable Q1val = sqrt((Par.d - Par.s1)*(3 - Par.s1)/2) / Par.Rg1
	//print "Q1 = "+num2str(Q1val)
	variable Dval=Par.G*exp(-(Par.d-Par.s1)/2)*((3-Par.s1)*(Par.d-Par.s1)/2)^((Par.d-Par.s1)/2) /Par.Rg1^(Par.d-Par.s1)
	//print "D = "+num2str(Dval)
	variable Q2val = sqrt((1 - Par.s2)/((2/(3-Par.s2)*Par.Rg2^2) - (2/(3-Par.s1))*Par.Rg1^2) )
	Q2val = numtype(Q2val)==0 ? Q2val : 0
	//print "Q2 = "+num2str(Q2val)
	variable G2val = Par.G * exp(-Q2val^2*((Par.Rg1^2/(3-Par.s1))-(Par.Rg2^2/(3-Par.s2)))) * Q2val^(Par.s2-Par.s1)
	//print "G2 = "+num2str(G2val)
	variable LowQRangePntMax, MidQRangePntMax
	LowQRangePntMax = BinarySearch(Qvector, Q2val )
	MidQRangePntMax = BinarySearch(Qvector, Q1val )
	//print LowQRangePntMax
	//print MidQRangePntMax
	Intensity = 0
	if(LowQRangePntMax>0)
		Intensity[0,LowQRangePntMax] = G2val/(Qvector[p]^Par.s2) * exp(-1 * Qvector[p]^2 * Par.Rg2^2 / (3-Par.s2))
	endif
	if(MidQRangePntMax>0)
		Intensity[LowQRangePntMax+1,MidQRangePntMax] = Par.G/(Qvector[p]^Par.s1) * exp(-1 * Qvector[p]^2 * Par.Rg1^2 / (3-Par.s1))
		Intensity[MidQRangePntMax+1,] = Dval / (Qvector[p]^Par.d)
	elseif(MidQRangePntMax<0)
		Intensity = Dval / (Qvector[p]^Par.d)
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
//for non spherical (infinitely large) objects with two Guinier areas - (s1!=0, s1!=0)
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
	if(Qval>=Q1val)
		return Dval/Qval^Pval
	elseif(Qval>Q2val || numtype(Q2val)!=0)
		return Gval/Qval^S1 * exp(-Qval^2 * Rg1^2 / (3-S1))
	else
		return G2val/Q2val^s2 * exp(-Qval^2 * Rg2^2 / (3-s2))
	endif

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
	IR2C_InitConfigMain()
	//check for panel if exists - pull up, if not create
	DoWindow IR3DP_MainPanel
	if(V_Flag)
		DoWindow/F IR3DP_MainPanel
	else
		IR3DP_MainPanelFunction()
		ING2_AddScrollControl()
		UpdatePanelVersionNumber("IR3DP_MainPanel", IR3GPversionNumber)
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
		if(!CheckPanelVersionNumber("IR3DP_MainPanel", IR3GPversionNumber))
			DoAlert /T="The Gunier-Porod panel was created by old version of Irena " 1, "Guinier Porod tool may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				DoWindow IR3DP_MainPanel
				if(V_Flag)
					DoWIndow/K IR3DP_MainPanel
				endif
				Execute/P("IR3GP_Main()")
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
	//PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(3,42,410,730) as "Gunier-Porod main panel"
	DoWindow/C IR3DP_MainPanel
	DefaultGUIControls /W=IR3DP_MainPanel ///Mac os9
	
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("Irena:GuinierPorod","IR3DP_MainPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 1,1)
//	SetDrawLayer UserBack
//	SetDrawEnv fname= "Times New Roman", save
//	SetDrawEnv fname= "Times New Roman",fsize= 28,fstyle= 3,textrgb= (0,0,52224)
//	DrawText 90,26,"Gunier Porod"
	TitleBox MainTitle title="Gunier Porod",pos={120,0},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={260,24},fSize=22,fColor=(0,0,52224)
//	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
//	DrawLine 16,176,339,176
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,176},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
//	SetDrawEnv fsize= 16,fstyle= 1
//	DrawText 18,49,"Data input"
	TitleBox Info1 title="Data input",pos={10,30},frame=0,fstyle=1, fixedSize=1,size={80,20},fSize=14,fColor=(0,0,52224)
//	SetDrawEnv fsize= 16,fstyle= 1
//	DrawText 10,200,"Gunier-Porod model input"
	TitleBox Info2 title="Gunier-Porod model input",pos={10,185},frame=0,fstyle=2, fixedSize=1,size={150,20},fSize=14
//	SetDrawEnv textrgb= (0,0,65280),fstyle= 1, fsize= 12
//	DrawText 200,275,"Fit?:"
	TitleBox Info3 title="Fit?  Low limit:    High Limit:",pos={200,262},frame=0,fstyle=2, fixedSize=0,size={20,15},fSize=12,fstyle=3,fColor=(0,0,65535)
//	SetDrawEnv textrgb= (0,0,65280),fstyle= 1, fsize= 12
///	DrawText 230,275,"Low limit:    High Limit:"
//	DrawText 10,600,"Fit using least square fitting ?"
	TitleBox Info4 title="Fit using least square fitting ?",pos={3,584},frame=0,fstyle=2, fixedSize=0,size={120,15},fSize=12,fstyle=3,fColor=(0,0,65535)
//	DrawPoly 113,225,1,1,{113,225,113,225}
//	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
//	DrawLine 330,612,350,612
	TitleBox FakeLine2 title=" ",fixedSize=1,size={20,3},pos={330,610},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
//	SetDrawEnv textrgb= (0,0,65280),fstyle= 1
//	DrawText 4,640,"Results:"
	TitleBox Info5 title="Results:",pos={3,625},frame=0,fstyle=2, fixedSize=0,size={120,15},fSize=12,fstyle=3,fColor=(0,0,65535)
//	SetDrawEnv fsize= 10
//	DrawText 50,453,"For local fits, set S2=0, Rg2=1e10, S1=0"
	TitleBox Info6 title="For local fits, set S2=0, Rg2=1e10, S1=0",pos={10,443},frame=0,fstyle=2, fixedSize=0,size={120,15},fSize=10
	//SetDrawEnv fsize= 10
	//DrawText 50,470,"And follow order of the buttons --->"
	TitleBox Info7 title="And follow order of the buttons --->",pos={10,459},frame=0,fstyle=2, fixedSize=0,size={120,15},fSize=10
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
	//SetVariable SubtractBackground,limits={0,Inf,0.1},value= root:Packages:Irena:GuinierPorod:SubtractBackground
	//SetVariable SubtractBackground,pos={110,162},size={150,16},title="Subtract backg.",proc=IR3GP_PanelSetVarProc, help={"Subtract flat background from data"}
	CheckBox UpdateAutomatically,pos={110,205},size={225,14},proc=IR3GP_PanelCheckboxProc,title="Update automatically?"
	CheckBox UpdateAutomatically,variable= root:Packages:Irena:GuinierPorod:UpdateAutomatically, help={"When checked the graph updates automatically anytime you make change in model parameters"}
	CheckBox UseNoLimits,pos={275,205},size={63,14},proc=IR3GP_PanelCheckboxProc,title="No limits?"
	CheckBox UseNoLimits,variable= root:Packages:Irena:GuinierPorod:UseNoLimits, help={"Check if you want to fit without use of limits"}
	CheckBox DisplayLocalFits,pos={110,220},size={225,14},proc=IR3GP_PanelCheckboxProc,title="Display local (Porod & Guinier) fits?"
	CheckBox DisplayLocalFits,variable= root:Packages:Irena:GuinierPorod:DisplayLocalFits, help={"Check to display in graph local Porod and Guinier fits for selected level, fits change with changes in values of P, B, Rg and G"}

//	CheckBox ExportLocalFits,pos={190,606},size={225,14},proc=IR1A_InputPanelCheckboxProc,title="Store local (Porod & Guinier) fits?"
//	CheckBox ExportLocalFits,variable= root:Packages:Irena_UnifFit:ExportLocalFits, help={"Check to store local Porod and Guinier fits for all existing levels together with full Unified fit"}
	Button DoFitting,pos={175,584},size={70,20},proc=IR3GP_PanelButtonProc,title="Fit", help={"Do least sqaures fitting of the whole model, find good starting conditions and proper limits before fitting"}
	Button RevertFitting,pos={255,584},size={100,20},proc=IR3GP_PanelButtonProc,title="Revert back",help={"Return back befoire last fitting attempt"}
//	Button ResetUnified,pos={3,605},size={80,15},proc=IR1A_InputPanelButtonProc,title="reset unif?", help={"Reset variables to default values?"}
	Button FixLimits,pos={93,605},size={80,15},proc=IR3GP_PanelButtonProc,title="Fix limits?", help={"Reset variables to default values?"}
	Button CopyToFolder,pos={55,623},size={120,20},proc=IR3GP_PanelButtonProc,title="Results -> Data Folder", help={"Copy results of the modeling into original data folder"}
//	Button ExportData,pos={180,623},size={90,20},proc=IR1A_InputPanelButtonProc,title="Export ASCII", help={"Export ASCII data out of Igor"}
	Button MarkGraphs,pos={277,623},size={110,20},proc=IR3GP_PanelButtonProc,title="Results -> graphs", help={"Insert text boxes with results into the graphs for printing"}
	Button CleanupGraph,pos={277,645},size={110,20},proc=IR3GP_PanelButtonProc,title="Clean graph", help={"Remove text boxes with results into the graphs for printing"}


//	Button EvaluateSpecialCases,pos={10,645},size={120,20},proc=IR3GP_PanelButtonProc,title="Analyze Results", help={"Analyze special Cases"}
//	Button ConfidenceEvaluation,pos={150,645},size={120,20},proc=IR3GP_PanelButtonProc,title="Uncertainity Evaluation", help={"Analyze confidence range for different parameters"}
	SetVariable SASBackground,pos={15,565},size={160,16},proc=IR3GP_PanelSetVarProc,title="SAS Background", help={"SAS background"},bodyWidth=80, format="%0.4g"
	SetVariable SASBackground,limits={-inf,Inf,0.05*SASBackground},value= root:Packages:Irena:GuinierPorod:SASBackground
	CheckBox FitBackground,pos={195,566},size={63,14},proc=IR3GP_PanelCheckboxProc,title="Fit Bckg?"
	CheckBox FitBackground,variable= root:Packages:Irena:GuinierPorod:FitSASBackground, help={"Check if you want the background to be fitting parameter"}
	Button LevelXFitRg1AndG,pos={240,410},size={120,12}, proc=IR3GP_PanelButtonProc,title="1. \\JL     Fit Rg1/G w/csrs", help={"Do local fit of Gunier dependence between the cursors amd put resulting values into the Rg and G fields"}
	Button LevelXFitPAndB,pos={240,427},size={120,12}, proc=IR3GP_PanelButtonProc,title="2. \\JL     Fit P w/csrs", help={"Do Power law fitting between the cursors and put resulting parameters in the P and B fields"}
	Button LevelXFitS1,pos={240,444},size={120,12}, proc=IR3GP_PanelButtonProc,title="3. \\JL     Fit S1 w/csrs", help={"Do Power law fitting between the cursors and put resulting parameters in the P and B fields"}
	Button LevelXFitRg2,pos={240,461},size={120,12}, proc=IR3GP_PanelButtonProc,title="4. \\JL     Fit Rg2 w/csrs", help={"Do local fit of Gunier dependence between the cursors amd put resulting values into the Rg and G fields"}
	Button LevelXFitS2,pos={240,478},size={120,12}, proc=IR3GP_PanelButtonProc,title="5. \\JL     Fit S2 w/csrs", help={"Do Power law fitting between the cursors and put resulting parameters in the P and B fields"}


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
	SetVariable Level_G,limits={0,inf,step},value= root:Packages:Irena:GuinierPorod:Level_G, help={"Gunier prefactor"}
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
	SetVariable Level_ETA,pos={14,500},size={180,16},proc=IR3GP_PanelSetVarProc,title="ETA    ",bodyWidth=140, format="%0.4g"
	SetVariable Level_ETA,limits={0,inf,step},value= root:Packages:Irena:GuinierPorod:Level_ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Gunier for multiple order Corelations"}
	CheckBox Level_ETAFit,pos={200,500},size={80,16},proc=IR3GP_PanelCheckboxProc,title=" "
	CheckBox Level_ETAFit,variable= root:Packages:Irena:GuinierPorod:LevelETAFit, help={"Fit correaltion distance? Slect properly the starting conditions and limits."}
	SetVariable Level_ETALowLimit,pos={230,500},size={60,16},noproc, title=" ", format="%0.3g"
	SetVariable Level_ETALowLimit,limits={0,inf,0},value= root:Packages:Irena:GuinierPorod:Level_ETALowLimit, help={"Correlation distance low limit"}
	SetVariable Level_ETAHighLimit,pos={300,500},size={60,16},noproc,  title=" ", format="%0.3g"
	SetVariable Level_ETAHighLimit,limits={0,inf,0},value= root:Packages:Irena:GuinierPorod:Level_ETAHighLimit, help={"Correlation distance high limit"}

	step = Level_PACK>0 ? 0.05*Level_PACK : 1
	SetVariable Level_PACK,pos={14,520},size={180,16},proc=IR3GP_PanelSetVarProc,title="Pack    ",bodyWidth=140, format="%0.4g"
	SetVariable Level_PACK,limits={0,8,step},value= root:Packages:Irena:GuinierPorod:Level_PACK, help={"Packing factor for domains. For dilute objects 0, for FCC packed spheres 8*0.592"}
	CheckBox Level_PACKFit,pos={200,520},size={80,16},proc=IR3GP_PanelCheckboxProc,title=" "
	CheckBox Level_PACKFit,variable= root:Packages:Irena:GuinierPorod:LevelPACKFit, help={"Fit packing factor? Select properly starting condions and limits"}
	SetVariable Level_PACKLowLimit,pos={230,520},size={60,16},noproc, title=" ", format="%0.3g"
	SetVariable Level_PACKLowLimit,limits={0,8,0},value= root:Packages:Irena:GuinierPorod:Level_PACKLowLimit, help={"Low limit for packing factor"}
	SetVariable Level_PACKHighLimit,pos={300,520},size={60,16},noproc,  title=" ", format="%0.3g"
	SetVariable Level_PACKHighLimit,limits={0,8,0},value= root:Packages:Irena:GuinierPorod:Level_PACKHighLimit, help={"High limit for packing factor"}

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
	STRUCT GunierPorodLevel Par
	
	string oldDf=GetDataFolder(1)
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

	string oldDf=GetDataFolder(1)
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
		//	IR1A_FixTabsInPanel()
			IR3GP_GraphMeasuredData()
//			NVAR ActiveLevel=root:Packages:Irena_UnifFit:ActiveLevel
//			IR1A_DisplayLocalFits(ActiveLevel,0)
//			IR1A_AutoUpdateIfSelected()
			variable ScreenHeight, ScreenWidth
			ScreenHeight = IN2G_ScreenWidthHeight("height")*100	
			ScreenWidth = IN2G_ScreenWidthHeight("width")	*100
			MoveWindow /W=GunierPorod_LogLogPlot 285,37,(285+ScreenWidth/2),(0.6*ScreenHeight - 37)
			//MoveWindow /W=IR1_IQ4_Q_PlotU 285,(0.6*ScreenHeight - 37),(285+ScreenWidth/2),(0.9*(ScreenHeight-37))
			AutoPositionWIndow /M=0  /R=IR3DP_MainPanel GunierPorod_LogLogPlot
		//	AutoPositionWIndow /M=1/E  /R=IR1_LogLogPlotU IR1_IQ4_Q_PlotU
			if (recovered)
				IR3GP_GraphModelData()		//graph the data here, all parameters should be defined
			endif
		else
			Abort "Data not selected properly"
		endif
	endif
	if (cmpstr(ctrlName,"GraphDistribution")==0)
		IR3GP_GraphModelData()
	endif
	if (cmpstr(ctrlName,"DoFitting")==0)
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
		IR3GP_CopyDataBackToFolder("")
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
	DoWIndow GunierPorod_LogLogPlot
	if(V_Flag)
		if(!DoNotRaise)
			DoWIndow/F GunierPorod_LogLogPlot
		endif
		Wave/Z ModelIntensity = root:Packages:Irena:GuinierPorod:ModelIntensity
		if(!WaveExists(ModelIntensity))
			Abort
		endif
		Wave OriginalQvector = root:Packages:Irena:GuinierPorod:OriginalQvector
		Wave ModelCurrentLevel = root:Packages:Irena:GuinierPorod:ModelCurrentLevel
		NVAR DisplayLocalFits = root:Packages:Irena:GuinierPorod:DisplayLocalFits
		CheckDisplayed ModelIntensity
		if(!V_Flag)
			AppendToGraph ModelIntensity vs OriginalQvector
		endif
		CheckDisplayed ModelCurrentLevel
		if(!V_Flag && DisplayLocalFits)
			AppendToGraph ModelCurrentLevel vs OriginalQvector
		endif
		if(V_Flag && !DisplayLocalFits)
			RemoveFromGraph ModelCurrentLevel 
		endif
		
		ModifyGraph lsize(ModelIntensity)=2,rgb(ModelIntensity)=(0,0,0)
		NVAR ActiveLevel=root:Packages:Irena:GuinierPorod:ActiveLevel
		CheckDisplayed/W=GunierPorod_LogLogPlot ModelCurrentLevel
		if(V_Flag)
			switch (ActiveLevel)
				case 1 :
					ModifyGraph lsize(ModelCurrentLevel)=2,rgb(ModelCurrentLevel)=(64000,0,0)
					break
				case 2 :
					ModifyGraph lsize(ModelCurrentLevel)=2,rgb(ModelCurrentLevel)=(0,64000,0)
					break
				case 3 :
					ModifyGraph lsize(ModelCurrentLevel)=2,rgb(ModelCurrentLevel)=(30000,30000,64000)
					break
				case 4 :
					ModifyGraph lsize(ModelCurrentLevel)=2,rgb(ModelCurrentLevel)=(52000,52000,0)
					break
				case 5 :
					ModifyGraph lsize(ModelCurrentLevel)=2,rgb(ModelCurrentLevel)=(0,50000,50000)
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
	Execute("SetVariable "+ctrlName+",limits={0,inf,"+num2str(step)+"}")
	if((stringmatch(ctrlName,"Level_Rg1")))
		NVAR Level_Rg1=$("root:Packages:Irena:GuinierPorod:Level_Rg1")
		NVAR Level_Rg1Fit=$("root:Packages:Irena:GuinierPorod:Level_Rg1Fit")
		if(Level_Rg1>1e6)
			Level_Rg1=1e6
			DoAlert 0, "Max value for Rg1 is 1e6, use that to remove the level from calculations"
			Level_Rg1Fit=0
		endif
	endif
	if(!(stringmatch(ctrlName,"SASBackground")||stringmatch(ctrlName,"Level_RgCutOff")))
		NVAR LowLimit=$("root:Packages:Irena:GuinierPorod:"+ctrlName+"LowLimit")
		NVAR HighLimit=$("root:Packages:Irena:GuinierPorod:"+ctrlName+"HighLimit")
		LowLimit = varNum * 0.2
		HighLimit = varNum * 5
	endif
	STRUCT GunierPorodLevel Par
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
	STRUCT GunierPorodLevel Par
	
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
	if(AutoUpdate)
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
	Duplicate/O OriginalIntensity, ModelIntensity, ModelCurrentLevel
	Redimension/D ModelIntensity
	Wave OriginalQvector		
	ModelIntensity=0
	Duplicate/Free ModelIntensity, tempIntensity
	ModelCurrentLevel=nan
	variable i
	
	for(i=1;i<=NumberOfLevels;i+=1)	// initialize variables;continue test
		IR3GP_CalculateOneLevelModelInt(OriginalQvector,TempIntensity, i)
		ModelIntensity+=TempIntensity
	endfor		
	if(ActiveLevel<=NumberOfLevels)	
		IR3GP_CalculateOneLevelModelInt(OriginalQvector,ModelCurrentLevel, ActiveLevel)
	endif
	 
	NVAR SASBackground=root:Packages:Irena:GuinierPorod:SASBackground
	ModelIntensity+=SASBackground	
	//ModelCurrentLevel+=SASBackground
	
	if(UseSMRData)
		duplicate/free ModelIntensity, ModelIntensitySM
		IR1B_SmearData(ModelIntensity, OriginalQvector, SlitLengthUnif, ModelIntensitySM)
		ModelIntensity=ModelIntensitySM
		IR1B_SmearData(ModelCurrentLevel, OriginalQvector, SlitLengthUnif, ModelIntensitySM)
		ModelCurrentLevel=ModelIntensitySM
	endif
	
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3GP_CalculateFitIntensity(Qvector, FitIntensity)
	Wave Qvector, FitIntensity

	setDataFolder root:Packages:Irena:GuinierPorod
	Wave OriginalIntensity=root:Packages:Irena:GuinierPorod:OriginalIntensity
	NVAR NumberOfLevels=root:Packages:Irena:GuinierPorod:NumberOfLevels
	NVAR UseSMRData=root:Packages:Irena:GuinierPorod:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena:GuinierPorod:SlitLengthUnif
	NVAR ActiveLevel=root:Packages:Irena:GuinierPorod:ActiveLevel
	FitIntensity=0
	Duplicate/Free FitIntensity, tempIntensity
	variable i
	
	for(i=1;i<=NumberOfLevels;i+=1)	// initialize variables;continue test
		IR3GP_CalculateOneLevelModelInt(Qvector,TempIntensity, i)
		FitIntensity+=TempIntensity
	endfor			 
	NVAR SASBackground=root:Packages:Irena:GuinierPorod:SASBackground
	FitIntensity+=SASBackground		
	if(UseSMRData)
		duplicate/free FitIntensity, ModelIntensitySM
		IR1B_SmearData(FitIntensity, Qvector, SlitLengthUnif, ModelIntensitySM)
		FitIntensity=ModelIntensitySM
	endif
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

static Function IR3GP_CalculateOneLevelModelInt(OriginalQvector, TempIntensity, Level)
	wave OriginalQvector, TempIntensity
	variable Level

	STRUCT GunierPorodLevel Par
	IR3GP_LoadStructureFromWave(Par, level)	
	IR2GP_CalculateGPlevel(OriginalQvector,TempIntensity,Par )
	IR3GP_CalculateInvariant(level)
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3GP_GraphMeasuredData()
	
	string oldDf=GetDataFolder(1)
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
	
		DoWindow IR1_LogLogPlotU
		if (V_flag)
			Dowindow/K IR3GP_LogLogPlotU
		endif
		IR3GP_LogLogPlotU()
	
//	Duplicate/O $(DataFolderName+IntensityWaveName), OriginalIntQ4
//	Duplicate/O $(DataFolderName+QWavename), OriginalQ4
//	Duplicate/O $(DataFolderName+ErrorWaveName), OriginalErrQ4
//	Redimension/D OriginalIntQ4, OriginalQ4, OriginalErrQ4
//	wavestats /Q OriginalQ4
//	if(V_min<0)
//		OriginalQ4 = OriginalQ4[p]<=0 ? NaN : OriginalQ4[p] 
//	endif
//	IN2G_RemoveNaNsFrom3Waves(OriginalQ4,OriginalIntQ4, OriginalErrQ4)
//
//	if(NVAR_Exists(SubtractBackground) && (cmpstr(Package,"Unified")==0))
//		OriginalIntQ4 =OriginalIntQ4 - SubtractBackground
//	endif
//	
//	OriginalQ4=OriginalQ4^4
//	OriginalIntQ4=OriginalIntQ4*OriginalQ4
//	OriginalErrQ4=OriginalErrQ4*OriginalQ4
//
//	if (cmpstr(Package,"Unified")==0)		//called from unified
//		DoWindow IR1_IQ4_Q_PlotU
//		if (V_flag)
//			Dowindow/K IR1_IQ4_Q_PlotU
//		endif
//		Execute ("IR1_IQ4_Q_PlotU()")
//	elseif (cmpstr(Package,"LSQF")==0)
//		DoWindow IR1_IQ4_Q_PlotLSQF
//		if (V_flag)
//			Dowindow/K IR1_IQ4_Q_PlotLSQF
//		endif
//		Execute ("IR1_IQ4_Q_PlotLSQF()")
//	endif
	setDataFolder oldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function  IR3GP_LogLogPlotU() 
	DoWindow GunierPorod_LogLogPlot
	if(V_Flag)
		DoWIndow/F GunierPorod_LogLogPlot
	else
		PauseUpdate; Silent 1		// building window...
		String fldrSav= GetDataFolder(1)
		SetDataFolder root:Packages:Irena:GuinierPorod:
		Wave OriginalIntensity
		Wave OriginalQvector
		Wave OriginalError
		SVAR DataFolderName
		SVAR IntensityWaveName
		Display /W=(282.75,37.25,759.75,208.25)/K=1  OriginalIntensity vs OriginalQvector as "LogLogPlot"
		DoWindow/C GunierPorod_LogLogPlot
		ModifyGraph mode(OriginalIntensity)=3
		ModifyGraph msize(OriginalIntensity)=1
		ModifyGraph log=1
		ModifyGraph mirror=1
		ShowInfo
		String LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Intensity [cm\\S-1\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"]"
		Label left LabelStr
		LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"]"
		Label bottom LabelStr
		string LegendStr="\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")+"\\s(OriginalIntensity) Experimental intensity"
		Legend/W=GunierPorod_LogLogPlot/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 LegendStr
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
	
	string oldDf=GetDataFolder(1)
	
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
	STRUCT GunierPorodLevel Par
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
	//Level_PFit = Par.DFit
	NVAR Level_PLowLimit
	//Level_PLowLimit = Par.DLowLimit
	NVAR Level_PHighLimit
	//Level_PHighLimit = Par.DHighLimit
	NVAR Level_PError
	//Level_PError = Par.DError

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

	string OldDF=GetDataFolder(1)
	setDataFolder root:Packages:Irena:GuinierPorod
	STRUCT GunierPorodLevel Par
	
	variable i, j
	NVAR UseNoLimits=root:Packages:Irena:GuinierPorod:UseNoLimits
	NVAR NumberOfLevels=root:Packages:Irena:GuinierPorod:NumberOfLevels
	NVAR SASBackground=root:Packages:Irena:GuinierPorod:SASBackground
	NVAR FitSASBackground=root:Packages:Irena:GuinierPorod:FitSASBackground
	String ListOfParameters = "Level_G;Level_Rg1;Level_Rg2;Level_P;Level_S1;Level_S2;"
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
					abort "Level "+num2str(i)+" "+tempStr+" limits set incorrenctly, fix the limits before fitting"
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
	
	DoWindow /F GunierPorod_LogLogPlot
	Wave OriginalQvector
	Wave OriginalIntensity
	Wave OriginalError	
	
	Variable V_chisq, level
	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave=W_coef/100

//	IR1A_RecordResults("before")

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
			FuncFit /N/Q IR3GP_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /D 
		else
			FuncFit /N/Q IR3GP_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /D /C=T_Constraints 
		endif
	else
		Duplicate/O OriginalIntensity, FitIntensityWave		
		Duplicate/O OriginalQvector, FitQvectorWave
		Duplicate/O OriginalError, FitErrorWave
		if(UseNoLimits)	
			FuncFit /N/Q IR3GP_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D	
		else	
			FuncFit /N/Q IR3GP_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D /C=T_Constraints	
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
			if(!stringmatch(GetRTStackInfo(0),"*IR1A_ConEvEvaluateParameter*") && !stringmatch(GetRTStackInfo(0),"*IR2S_ButtonProc*") )		//skip when calling from either Confidence evaluation or scripting tool 
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
	STRUCT GunierPorodLevel Par
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
	STRUCT GunierPorodLevel Par

	if ((!WaveExists(w)) || (!WaveExists(CoefNames)))
		Beep
		abort "Record of old parameters does not exist, this is BUG, please report it..."
	endif

	NVAR NumberOfLevels=root:Packages:Irena:GuinierPorod:NumberOfLevels

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
	STRUCT GunierPorodLevel Par
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		testVar=0
	endfor
	for (i=1;i<=5;i+=1)
			IR3GP_LoadStructureFromWave(Par, i)
			Par.GError=0
			Par.Rg1Error=0
			Par.Rg2Error=0
			Par.dError=0
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

	variable i
	NVAR ActiveLevel=root:Packages:Irena:GuinierPorod:ActiveLevel
	STRUCT GunierPorodLevel Par	
	for (i=1;i<=5;i+=1)
			IR3GP_LoadStructureFromWave(Par, i)
			Par.GLowLimit=0.1 * Par.G
			Par.GHighLimit=10 * Par.G
			Par.Rg1LowLimit=0.2 * Par.Rg1
			Par.Rg1HighLimit=5 * Par.Rg1
			Par.Rg2LowLimit=0.2 * Par.Rg2
			Par.Rg2HighLimit=5 * Par.Rg2
			Par.dLowLimit=1
			Par.dHighLimit=4.2
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
	STRUCT GunierPorodLevel Par
	IR3GP_LoadStructureFromWave(Par, Lnmb)
	//IR3GP_MoveStrToGlobals(Par)

	NVAR SASBackgroundError=$("SASBackgroundError")
	NVAR SASBackground=$("SASBackground")
	string LogLogTag, IQ4Tag, tagname
	tagname="Level"+num2str(Lnmb)+"Tag"
	Wave OriginalQvector=root:Packages:Irena:GuinierPorod:OriginalQvector
		
	variable QtoAttach=2/Par.Rg1
	variable AttachPointNum=binarysearch(OriginalQvector,QtoAttach)
	
	LogLogTag="\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")+"Gunier-Porod Fit for level "+num2str(Lnmb)+"\r"
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
	if (Par.DError>0)
		LogLogTag+="P \t= "+num2str(Par.D)+"  \t +/-"+num2str(Par.DError)+"\r"
	else
		LogLogTag+="P \t= "+num2str(Par.D)+"  \t   "	+"\r"
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
	
	Tag/W=GunierPorod_LogLogPlot/C/N=$(tagname)/F=2/L=2/M OriginalIntensity, AttachPointNum, LogLogTag
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
	if(ParamIsDefault(SaveMe ))
		SaveMe="NO"
	ENDIF
	string OldDf=getDataFOlder(1)
	setDataFolder root:Packages:Irena:GuinierPorod
	
	string UsersComment="Guinier-Porod Fit results from "+date()+"  "+time()
	
	Prompt UsersComment, "Modify comment to be included with these results"
	if(!stringmatch(SaveMe,"Yes"))
		DoPrompt "Copy data back to folder comment", UsersComment
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
	
//	//and now local fits also
//	if(ExportLocalFits)
//		For(i=1;i<=NumberOfLevels;i+=1)
//			Wave FitIntPowerLaw=$("root:Packages:Irena_UnifFit:FitLevel"+num2str(i)+"Porod")
//			Wave FitIntGuinier=$("root:Packages:Irena_UnifFit:FitLevel"+num2str(i)+"Guinier")
//			Wave LevelUnified=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Unified")
//			tempname="UniLocalLevel"+num2str(i)+"Unified_"+num2str(ii)
//			Duplicate /O LevelUnified, $tempname
//			IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
//			IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
//			IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
//			tempname="UniLocalLevel"+num2str(i)+"Pwrlaw_"+num2str(ii)
//			Duplicate /O FitIntPowerLaw, $tempname
//			IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
//			IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
//			IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
//			tempname="UniLocalLevel"+num2str(i)+"Guinier_"+num2str(ii)
//			Duplicate /O FitIntGuinier, $tempname
//			IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
//			IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
//			IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
//		endfor
//	endif
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
	
	string oldDf=GetDataFolder(1)
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
	
	STRUCT GunierPorodLevel Par
	
	IR3GP_LoadStructureFromWave(Par, level)

	variable i
	For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_S2",num2str(Par.S2))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_S2Error",num2str(Par.S2Error))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_Rg2",num2str(Par.Rg2))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_Rg2Error",num2str(Par.Rg2Error))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_S1",num2str(Par.S1))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_S1Error",num2str(Par.S1Error))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_G",num2str(Par.G))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_GError",num2str(Par.GError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_Rg1",num2str(Par.Rg1))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_RgError",num2str(Par.Rg1Error))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_P",num2str(Par.d))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_PError",num2str(Par.dError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_UseCorrelations",num2str(Par.UseCorrelations))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_ETA",num2str(Par.ETA))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_ETAError",num2str(Par.ETAError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"_PACK",num2str(Par.PACK))
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
	STRUCT GunierPorodLevel Par
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
	Par.d=NumberByKey("Level"+num2str(level)+"_P", OldNote,"=")
	Par.dError=NumberByKey("Level"+num2str(level)+"_PError", OldNote,"=")
	Par.ETA=NumberByKey("Level"+num2str(level)+"_ETA", OldNote,"=")
	Par.ETAError=NumberByKey("Level"+num2str(level)+"_ETAError", OldNote,"=")
	Par.PACK=NumberByKey("Level"+num2str(level)+"_PACK", OldNote,"=")
	Par.PACKError=NumberByKey("Level"+num2str(level)+"_PACKError", OldNote,"=")
	Par.UseCorrelations=NumberByKey("Level"+num2str(level)+"_UseCorrelations", OldNote,"=")
	Par.RgCutOff=NumberByKey("Level"+num2str(level)+"_RgCutOff", OldNote,"=")
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
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena:GuinierPorod
	STRUCT GunierPorodLevel Par

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
	Variable LocalRg, LocalG
	
	DoWIndow/F GunierPorod_LogLogPlot
	if (strlen(CsrWave(A))==0 || strlen(CsrWave(B))==0)
		beep
		abort "Both Cursors Need to be set in Log-log graph on wave OriginalIntensity"
	endif

	if(WhichOne==1)		//Rg1
		LocalRg = Rg
		LocalG = G
	elseif(WhichOne==2)			//Rg2
		LocalRg = Rg
		LocalG = (OriginalIntensity[pcsr(A)]+OriginalIntensity[pcsr(B)])/2
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
	DoWIndow/F GunierPorod_LogLogPlot
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

	DoWIndow  GunierPorod_LogLogPlot
	if(!V_Flag)
		return 0
	endif
	if(RemoveGunPorLocalFits)
	RemoveFromGraph /W=GunierPorod_LogLogPlot /Z FitLevel1Porod,FitLevel2Porod,FitLevel3Porod,FitLevel4Porod,FitLevel5Porod
	RemoveFromGraph /W=GunierPorod_LogLogPlot /Z FitLevel1Guinier,FitLevel2Guinier,FitLevel3Guinier,FitLevel4Guinier,FitLevel5Guinier
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
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena:GuinierPorod

	RemoveFromGraph /W=GunierPorod_LogLogPlot /Z FitLevel1Guinier,FitLevel2Guinier,FitLevel3Guinier,FitLevel4Guinier,FitLevel5Guinier
	Wave FitWv=$("root:Packages:Irena:GuinierPorod:"+FitWaveName)	
	Wave OriginalQvector
	NVAR DisplayLocalFits
	
	if (DisplayLocalFits || overwride)				
		GetAxis /W=GunierPorod_LogLogPlot /Q left
		AppendToGraph /W=GunierPorod_LogLogPlot $(FitWaveName) vs OriginalQvector
		ModifyGraph /W=GunierPorod_LogLogPlot lsize($(FitWaveName))=1,rgb($(FitWaveName))=(0,0,65280),lstyle($(FitWaveName))=3
		SetAxis /W=GunierPorod_LogLogPlot left V_min, V_max
	endif	
	SetDataFolder oldDf
end
//****************************************************************************************************************
//****************************************************************************************************************

Function IR3GP_AppendPorodFit(level, overwride, FitWaveName)
	variable level, overwride
	string FitWaveName
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena:GuinierPorod

	RemoveFromGraph /W=GunierPorod_LogLogPlot /Z FitLevel1Porod,FitLevel2Porod,FitLevel3Porod,FitLevel4Porod,FitLevel5Porod
	Wave FitWv=$("root:Packages:Irena:GuinierPorod:"+FitWaveName)	
	Wave OriginalQvector
	NVAR DisplayLocalFits
	
	if (DisplayLocalFits || overwride)				
		GetAxis /W=GunierPorod_LogLogPlot /Q left
		AppendToGraph /W=GunierPorod_LogLogPlot $(FitWaveName) vs OriginalQvector
		ModifyGraph /W=GunierPorod_LogLogPlot lsize($(FitWaveName))=1,rgb($(FitWaveName))=(0,0,65280),lstyle($(FitWaveName))=3
		SetAxis /W=GunierPorod_LogLogPlot left V_min, V_max
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
	string oldDf=GetDataFolder(1)
	STRUCT GunierPorodLevel Par
	
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

	DoWindow GunierPorod_LogLogPlot
	if(V_Flag)
		DoWindow/F GunierPorod_LogLogPlot
	else
		abort
	endif
	if(strlen(CsrWave(A))<1 || strlen(CsrWave(B))<1)
		beep
		SetDataFolder oldDf
		abort "Set both cursors before fitting"
	endif
	//now handle calibration - G value needs to be modified if this is S1 or S2
	variable CalibrationValue, CalibrationQ, OldG
	oldG=Gvalue
	if(whichOne==2)		//this is S1
		NVAR Rg1=$("Level_Rg1")
		NVAR Pval=$("Level_P")
		NVAR S1=$("Level_S1")
		NVAR S2=$("Level_S2")
		NVAR Rg2=$("Level_Rg2")
		CalibrationQ= 0.5*pi/Rg1
		CalibrationValue = IR2GP_CalculateGPValue(CalibrationQ,Pval,Rg1,Gvalue,S1,Rg2,S2,0)
	endif

	Make/D/O/N=2 CoefficientInput, New_FitCoefficients, LocalEwave
	Make/O/T/N=2 CoefNames
	CoefficientInput[0]=(OriginalIntensity[pcsr(A)]+OriginalIntensity[pcsr(B)])/2
	CoefficientInput[1]=Pp
	LocalEwave[0]=CoefficientInput[0]/20
	LocalEwave[1]=Pp/20
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
	
	FitInt=New_FitCoefficients[0]*OriginalQvector^(-New_FitCoefficients[1])
	Pp=abs(New_FitCoefficients[1])
	NVAR UseSMRData=root:Packages:Irena:GuinierPorod:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena:GuinierPorod:SlitLengthUnif
	if(UseSMRData)
		duplicate/Free  FitInt, UnifiedFitIntensitySM
		IR1B_SmearData(FitInt, OriginalQvector, SlitLengthUnif, UnifiedFitIntensitySM)
		FitInt=UnifiedFitIntensitySM
	endif
	variable scalingFactor
	if(whichOne==2)		//this is S1
		scalingFactor = CalibrationValue/IR2GP_CalculateGPValue(CalibrationQ,Pval,Rg1,Gvalue,Pp,Rg2,S2,0)
		Gvalue = Gvalue*scalingFactor
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
	Duplicate/free OriginalQvector, tempPowerLawInt
	tempPowerLawInt = Prefactor * OriginalQvector^(-slope)
	if(UseSMRData)
		duplicate/free  tempPowerLawInt, tempPowerLawIntSM
		IR1B_SmearData(tempPowerLawInt, OriginalQvector, SlitLengthUnif, tempPowerLawIntSM)
		tempPowerLawInt=tempPowerLawIntSM
	endif
	
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
	STRUCT GunierPorodLevel Par
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
	tempB=rUnifiedfit[newnumpnts-1]*maxQ^(Par.D)			//makes -4 extension match last point of fit
	Qv+=abs((tempB*maxQ^(3-Par.D))/(Par.D-2))				//extends with -4 exponent
	//invariant+=abs(tempB*maxQ^(3-abs(tempPorod))/(abs(tempPorod)-2))//This one extrapolates with origional P	
	 Par.Invariant = Qv* 1e24
	 IR3GP_SaveStructureToWave(Par, level)
	return Qv* 1e24  // cm-1A-3  mult by 1e24 for cm-4
end
//***********************************************************
//***********************************************************
//***********************************************************		

