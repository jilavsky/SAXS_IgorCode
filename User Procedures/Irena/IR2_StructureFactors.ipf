#pragma rtGlobals=2		// Use modern global access method.
#pragma version=1.07


//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.07 removed most Executes in preparation fro Igor 7
//1.06 added support for "No fitting limits" option i n GUI
//1.05 changed back to rtGlobals=2, need to check code much more to make it 3
//1.04 added User as structure factor. Requested feature. 
//1.03 changed limits on Radius paraeter so it is not reset when larger than 0.1, got in my way when fitting some weird stuff... 
//1.02 added license for ANL
//1.01 Added InterPrecipitate SF based on formula  6 from APPLIED PHYSICS LETTERS 93, 161904 (2008) "Study of nanoprecipitates in a nickel-based superalloy using small-angle 
//        neutron scattering and transmission electron microscopy" E-Wen Huang,1 Peter K. Liaw,1 Lionel Porcar,2 Yun Liu,2 Yee-Lang Liu,3, Ji-Jung Kai,3 and Wei-Ren Chen4,a
//        Formula 6, refers to paper by R. Giordano, A. Grasso, and J. Teixeira, Phys. Rev. A 43, 6894 (1991). 
 


// This is form factor package for Irena tools. The Structure factors here are mostly from NIST SANS package. Direct copy...
// to use:

//1. initialize by calling: IR2S_InitStructureFactors()
// 	this is where the list of known structure factors is:
//				SVAR ListOfStructureFactors=root:Packages:StructureFactorCalc:ListOfStructureFactors
//2. use by calling: IR2S_CalcStructureFactor(SFname,Qvalue,Param1,Param2,Param3,Param4,Param5,Param6,[UserStrFacFormula="UserSFformula"])
//		correct use I(Q) = I(Q, dilute limit) * IR2S_CalcStructureFactor(SFname,Qvalue,Param1,Param2,Param3,Param4,Param5,Param6,[UserStrFacFormula="UserFormula"])
//				//Dilute system;Interferences;HardSpheres;SquareWell;StickyHardSpheres;HayterPenfoldMSA;User;
//3. Get panel by calling: 
//		IR2S_MakeSFParamPanel(TitleStr,SFStr,P1Str,FitP1Str,LowP1Str,HighP1Str,P2Str,FitP2Str,LowP2Str,HighP2Str,P3Str,FitP3Str,LowP3Str,HighP3Str,P4Str,FitP4Str,LowP4Str,HighP4Str,P5Str,FitP5Str,LowP5Str,HighP5Str,P6Str,FitP6Str,LowP6Str,HighP6Str,SFUserSFformula)
//		to disallow fitting of paramters, simply set FitP1Str="" etc. 
//   		then do not have to set low and high limits ...

// Structure factors package...
//    IR2_OldInterferences			this is roughly hard spheres (close to Percus-Yevick model, not exactly), the ETA = 2* radius and Phi = 8 * vol. fraction for PC model. 
//	IR2_HardSphereStruct			this is Percus-Yevick model
//	IR2_StickyHS_Struct			this is sticky hard spheres
//	IR2_SquareWellStruct			this is Square well
//	IR2_HayterPenfoldMSA			this is HayterPenfoldMSA model
//   "User" is anything user defines with up to 6 parameters. 
//		Example:
			//Function UseSQExample(w,x)
			//	Wave w		//contains parameters: {Par1,Par2,Par3,Par4,Par5,Par6}
			//	Variable x	//this is Q for which to calculate S(Q)
			//
			//	Variable eta, pack, temp		//declare meaningful parameters names
			//	eta = w[0]					//assigne them values
			//	pack = w[1]
			//
			//	temp = (3*(sin(x*eta)-x*eta*cos(x*eta))/(x*eta)^3)		//calcualte S(Q)
			//	temp = (1/(1+pack*temp))
			//	return 	temp				//return the value
			//
			//end


//First find appropriate structur factors from NIST package and how many parameters they need to have...

// HardSphereStruct 	 2 parameters, parameters_hss = {"Radius (A)","vol fraction"}
//		HardSphereStruct(coef_hss,xwave_hss)
//     REFS:  PERCUS,YEVICK PHYS. REV. 110 1 (1958)
//            THIELE J. CHEM PHYS. 39 474 (1968)
//            WERTHEIM  PHYS. REV. LETT. 47 1462 (1981)
//	IR2_HardSphereStruct(coef_hss,Q)
//	r = w[0]
//	phi = w[1]
/////////////////////////////////////////////////////////
// Sticky Hard Spheres   4 parameters, "Radius","volume fraction","perturbation parameter (0.1)","stickiness, tau"
//		StickyHS_Struct(coef_shsSQ, xwave_shsSQ)
//			no reference in NIST macros, commens about some problems?
//	IR2_StickyHS_Struct(w,Q)
//	perturbation parameter guess to 0.05 (max 0.1)
//	stickiness guess 0.2
/////////////////////////////////////////////////////////
// Square Well Structure factor, 4 parameters, "Radius (A)","vol fraction","well depth (kT)","well width (diameters)"
//     REFS:  SHARMA,SHARMA, PHYSICA 89A,(1977),212
// 		SquareWellStruct(coef_sws,xwave_sws)
// 		this function calculates the interparticle structure factor for spherical particles interacting
// 		through a square well potential.
// 			NOTE - depths >1.5kT and volume fractions > 0.08 give UNPHYSICAL RESULTS
// 			when compared to Monte Carlo simulations
// Input variables are:
	//[0] radius
	//[1] volume fraction
	//[2] well depth e/kT, dimensionless, +ve depths are attractive
	//[3] well width, multiples of diameter
// 	IR2_SquareWellStruct(w,Q)
////////////////////////////////////////////////////////
// standard form used previously, from Ryong-Joon
//  Uses 2 parameters, "Radius (ETA)", and "fraction(pack)", where radius is in A and pack is up to 8 or so. 
//		S(Q)=1/(1+pack*IR1A_SphereAmplitude(Q,ETA))
//		Function IR1A_SphereAmplitude(qval, eta)
//			variable qval, eta
//			return (3*(sin(qval*eta)-qval*eta*cos(qval*eta))/(qval*eta)^3)
//		end
/////////////////////////////////////////////////////////
// Hard sphere		1. Radius
//					2. Volume fraction
// Interferences		1. radius (ETA)
//					2. Volume fraction (phi)
// Sticky hard sphere	1. Radius
//					2. Volume fraction
//					3. Perturbation parameter
//					4. Stickiness
//Square Well		1. Radius
//					2. volume fraction
//					3. well depth (kT)
//					4. well width (diameter)

//    Hayter Penfold MSA routines:
//		SETS UP THE PARAMETERS FOR THE
//		CALCULATION OF THE STRUCTURE FACTOR ,S(Q)
//		GIVEN THE THREE REQUIRED PARAMETERS VALK, GAMMA, ETA.
//
//      *** NOTE ****  THIS CALCULATION REQUIRES THAT THE NUMBER OF 
//                     Q-VALUES AT WHICH THE S(Q) IS CALCULATED BE
//                     A POWER OF 2
//		!!!!! this is at this time NOT enforced here... I am not sure if this is really problem or not.
//    How do I find out? Users need to test this for me and if necessary, I need to try it out. 
// in my testing there was NO problem with the results when the number of q pointds was arbitrary number of points... 

//Function to identify the parameter for given SF: IR1T_IdentifySFParamName(SFactorName,ParameterOrder) (returns text)

//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************

Function IR2S_CalcStructureFactor(SFname,Qvalue,Param1,Param2,Param3,Param4,Param5,Param6,[UserStrFacFormula])
		String SFname, UserStrFacFormula
		Variable Qvalue,Param1,Param2,Param3,Param4,Param5,Param6
		//Dilute system;Interferences;HardSpheres;SquareWell;StickyHardSpheres,HayerPenfoldMSA
		
		variable result
		string OldDf=GetDataFolder(1)
		SetDataFolder root:Packages:StructureFactorCalc
		make/O/N=6 parWv
		parWv={Param1,Param2,Param3,Param4,Param5,Param6}
		if(cmpstr(SFname,"Interferences")==0)
			result = IR2S_OldInterferences(parWv,Qvalue)
		elseif(cmpstr(SFname,"HardSpheres")==0)
			result = IR2S_HardSphereStruct(parWv,Qvalue)
		elseif(cmpstr(SFname,"SquareWell")==0)
			result = IR2S_SquareWellStruct(parWv,Qvalue)
		elseif(cmpstr(SFname,"StickyHardSpheres")==0)
			result = IR2S_StickyHS_Struct(parWv,Qvalue)
		elseif(cmpstr(SFname,"HayerPenfoldMSA")==0)
			result = IR2_HayterPenfoldMSA(parWv,Qvalue)
		elseif(cmpstr(SFname,"InterPrecipitate")==0)
			result = IR2S_InterprecipitateSF(parWv,Qvalue)
		elseif(cmpstr(SFname,"User")==0)
			String infostr = FunctionInfo(UserStrFacFormula)
			if (strlen(infostr) == 0)
				Abort "Structure factor user function does not exist"
			endif
			if(NumberByKey("N_PARAMS", infostr)!=2 || NumberByKey("RETURNTYPE", infostr)!=4 )
				Abort "Structure factor function does not have the right number of parameters or does not return variable"
			endif
			string cmd1
			variable/g resultg
			cmd1="resultg = "+UserStrFacFormula+"("+GetWavesDataFolder(parWv,2)+","+num2str(Qvalue)+")"
			Execute(cmd1)
			result = resultg
		else
			result = 1
		endif
		setDataFolder OldDf
		return result
end

//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************


Function IR2S_InitStructureFactors()
	//here we initialize the form factor calculations
	
	string OldDf=GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:StructureFactorCalc
	
	string/g ListOfStructureFactors="Dilute system;Interferences;HardSpheres;SquareWell;StickyHardSpheres;HayerPenfoldMSA;InterPrecipitate;User;"
//	unfinished="Fractal Aggregate;"
	SVAR ListOfStructureFactors=root:Packages:StructureFactorCalc:ListOfStructureFactors
	setDataFolder OldDf
end




//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************

Function IR2S_CheckFitParameter(StructureFactor,FitP1Str,FitP2Str,FitP3Str,FitP4Str,FitP5Str,FitP6Str)
	string StructureFactor, FitP1Str,FitP2Str,FitP3Str,FitP4Str,FitP5Str,FitP6Str
	 
	string OldDf=GetDataFolder(1)
	if(!DataFolderExists("root:Packages:StructureFactorCalc"))
		IR2S_InitStructureFactors()
	endif

	NVAR/Z FitP1=$(FitP1Str)
	NVAR/Z FitP2=$(FitP2Str)
	NVAR/Z FitP3=$(FitP3Str)
	NVAR/Z FitP4=$(FitP4Str)
	NVAR/Z FitP5=$(FitP5Str)
	NVAR/Z FitP6=$(FitP6Str)

	//need to disable usused fitting parameters so the code which is using this package does not have to contain list of form factors... 
//	string/g ListOfFormFactors="Interferences;HardSpheres;SquareWell;StickySpheres;"
	
	//go through all form factors known and set the ones unsused to zeroes...
	if(NVAR_Exists(FitP1) && NVAR_Exists(FitP2) && NVAR_Exists(FitP3) && NVAR_Exists(FitP4) &&NVAR_Exists(FitP5)&&NVAR_Exists(FitP6))
		if(stringmatch(StructureFactor,"Dilute system"))			//two parameters.
			FitP1=0
			FitP2=0
			FitP3=0
			FitP4=0
			FitP5=0
			FitP6=0
		endif	
		if(stringmatch(StructureFactor,"Interferences"))			//two parameters.
			FitP3=0
			FitP4=0
			FitP5=0
			FitP6=0
		endif	
		if(stringmatch(StructureFactor,"InterPrecipitate"))			//two parameters.
			FitP3=0
			FitP4=0
			FitP5=0
			FitP6=0
		endif	
	 	if(stringmatch(StructureFactor,"HardSpheres"))   			//two parameters 
			FitP3=0
			FitP4=0
			FitP5=0
			FitP6=0
	 	elseif(stringmatch(StructureFactor,"SquareWell")) 		 	 //four parameters
			FitP5=0
			FitP6=0
		elseif(stringmatch(StructureFactor,"StickyHardSpheres"))		  //four parameters
			FitP5=0
			FitP6=0			
		elseif(stringmatch(StructureFactor,"HayerPenfoldMSA"))		  //six parameters

		elseif(stringmatch(StructureFactor,"User"))					  //six parameters

		endif
	endif
	
	setDataFolder oldDf	
end	


//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
Function IR2S_MakeSFParamPanel(TitleStr,SFStr,P1Str,FitP1Str,LowP1Str,HighP1Str,P2Str,FitP2Str,LowP2Str,HighP2Str,P3Str,FitP3Str,LowP3Str,HighP3Str,P4Str,FitP4Str,LowP4Str,HighP4Str,P5Str,FitP5Str,LowP5Str,HighP5Str,P6Str,FitP6Str,LowP6Str,HighP6Str,SFUserSFformula,[NoFittingLimits])
	string TitleStr,SFStr,P1Str,FitP1Str,LowP1Str,HighP1Str,P2Str,FitP2Str,LowP2Str,HighP2Str,P3Str,FitP3Str,LowP3Str,HighP3Str,P4Str,FitP4Str,LowP4Str,HighP4Str,P5Str,FitP5Str,LowP5Str,HighP5Str,SFUserSFformula,P6Str,FitP6Str,LowP6Str,HighP6Str
	variable NoFittingLimits
	//string WinHookFnctStr
	//to use this panel, provide strings with paths to controled variables - or "" if the variable does not exist

	variable NoFittingLimitsL=0
	if(!ParamIsDefault(NoFittingLimits))	
		NoFittingLimitsL=NoFittingLimits
	endif
	string OldDf=GetDataFolder(1)
	if(!DataFolderExists("root:Packages:StructureFactorCalc"))
		IR2S_InitStructureFactors()
	endif
	SetDataFolder root:Packages:StructureFactorCalc
	SVAR ListOfStructureFactors=root:Packages:StructureFactorCalc:ListOfStructureFactors
	
	DoWindow StructureFactorControlScreen
	if(V_Flag)
		DoWindow/K StructureFactorControlScreen
	endif
		
	SVAR/Z CurrentSF=$(SFStr)
	if(!SVAR_Exists(CurrentSF))
		Abort "Error in call to SF control panel. Current SF string does not exist. This is bug!"
	endif
	
	if(stringmatch(CurrentSF, "Dilute system") || !stringmatch(ListOfStructureFactors, "*"+CurrentSF+";*" ))
		setDataFolder OldDf
		return 1
	endif	
	
	SVAR CurSF=$(SFStr)

	NVAR/Z FitP1=$(FitP1Str)
	NVAR/Z FitP2=$(FitP2Str)
	NVAR/Z FitP3=$(FitP3Str)
	NVAR/Z FitP4=$(FitP4Str)
	NVAR/Z FitP5=$(FitP5Str)
	NVAR/Z FitP6=$(FitP6Str)

	//need to disable usused fitting parameters so the code which is using this package does not have to contain list of form factors... 
//	string/g ListOfFormFactors="Interferences;HardSpheres;SquareWell;StickySpheres;"
	
	//go through all form factors known and set the ones unsused to zeroes...
	if(NVAR_Exists(FitP3) && NVAR_Exists(FitP4) &&NVAR_Exists(FitP5) &&NVAR_Exists(FitP6))
		if(stringmatch(CurSF,"Interferences"))			//two parameters.
			FitP3=0
			FitP4=0
			FitP5=0
		endif	
		if(stringmatch(CurSF,"InterPrecipitate"))			//two parameters.
			FitP3=0
			FitP4=0
			FitP5=0
		endif	
	 	if(stringmatch(CurSF,"HardSpheres"))   			//two parameters 
			FitP3=0
			FitP4=0
			FitP5=0
	 	elseif(stringmatch(CurSF,"SquareWell")) 		  //four parameters
			FitP5=0
		elseif(stringmatch(CurSF,"StickyHardSpheres"))		  //four parameters
			FitP5=0
		elseif(stringmatch(CurSF,"HayerPenfoldMSA"))		  //six parameters

		elseif(stringmatch(CurSF,"User"))		  //six parameters

		endif
	endif
	
	//make the new panel 
	NewPanel/K=1 /W=(96,94,530,370) as "Structure Factor Control Screen"
	DoWindow/C StructureFactorControlScreen
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 3,textrgb= (0,12800,52224)
	DrawText 10,34,TitleStr
	SetDrawEnv fstyle= 1
	DrawText 80,93,"Parameter value"
	SetDrawEnv fstyle= 1
	DrawText 201,93,"Fit?"
	SetDrawEnv fstyle= 1
	DrawText 236,93,"Low limit?"
	SetDrawEnv fstyle= 1
	DrawText 326,93,"High Limit"
	SetWindow StructureFactorControlScreen note="NoFittingLimits="+num2str(NoFittingLimits)+";"
	
	SetDrawEnv fstyle= 3, fsize= 10
	DrawText 4,265,"Hit enter twice to auto recalculate (if Auto recalculate is selected)"

	SetVariable FormFactor title="Structure factor: ", pos={5,50}, noedit=1, size={300,16},disable=2,frame=0,fSize=14,fstyle=1
	SetVariable FormFactor variable=CurrentSF
	SetVariable FormFactor help={"Structure factor to be used"}

	//for these we need just one parameter, that is aspect ratio....
	//Hard sphere				Radius = ParticlePar1
	//Interferences				Radius =ParticlePar1
	//Stricky Hard spheres		Radius = ParticlePar1
	//Square well				Radius = ParticlePar1
	//InterPrecipitate			L = ParticlePar1
	//Hayter Penfold MSA		Radius in A = ParticlePar1, note original code used diameter... It is fixed to address this...
//first variable......
	NVAR/Z CurVal= $(P1Str)
	if(!NVAR_Exists(CurVal))
		Abort "at least one parameter must exist for this shape, bug"
	endif
	//this is radius, to work it must be larger than 0
	if(CurVal<0.1)
		CurVal=50
	endif
	SetVariable P1Value,limits={0,Inf,0.05*CurVal},variable= $(P1Str), proc=IR2S_SFCntrlPnlSetVarProc
	SetVariable P1Value,pos={5,100},size={180,15},title="Radius [A] = ", help={"Radius or distance of this Structure factor. units = [A]"}
	if(stringmatch(CurrentSF,"Interferences"))
		SetVariable P1Value,title="Distance (ETA) [A] = ", help={"Distance of this Structure factor. units = [A]"}
	endif
	if(stringmatch(CurrentSF,"InterPrecipitate"))
		SetVariable P1Value,title="Distance L [A] = ", help={"Distance of this Structure factor. units = [A]"}
	endif
	if(stringmatch(CurrentSF,"User"))
		SetVariable P1Value,title="Param 1 = ", help={"Paramter 1 of user defined formula"}
	endif
	NVAR/Z CurVal= $(FitP1Str)
	NVAR/Z CurVal2= $(LowP1Str)
	NVAR/Z CurVal3= $(HighP1Str)
	
	if (strlen(FitP1Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
		CheckBox FitP1Value,pos={200,100},size={25,16},proc=IR2S_SFCntrlPnlCheckboxProc,title=" "
		CheckBox FitP1Value,variable= $(FitP1Str), help={"Fit this parameter?"}
		NVAR disableMe= $(FitP1Str)
		SetVariable P1LowLim,limits={0,Inf,0},variable= $(LowP1Str), disable=(!disableMe||NoFittingLimitsL)
		SetVariable P1LowLim,pos={220,100},size={80,15},title=" ", help={"Low limit for fitting param 1"}
		SetVariable P1HighLim,limits={0,Inf,0},variable= $(HighP1Str), disable=(!disableMe||NoFittingLimitsL)
		SetVariable P1HighLim,pos={320,100},size={80,15},title=" ", help={"High limit for fitting param 1"}
	endif
	
	//for these we need just one parameter, that is aspect ratio....
	//Hard sphere				Radius = Volume Fraction = particleParameter2
	//Interferences				Radius =Volume fraction (phi)
	//Stricky Hard spheres		Radius = Volume fraction
	//Square well				Radius = Volume Fraction
	//InterPrecipitate			sigma = ~ volume fraction
	//Hayter Penfold MSA		Number of charges
//second variable......
	NVAR/Z CurVal= $(FitP2Str)
	NVAR/Z CurVal2= $(LowP2Str)
	NVAR/Z CurVal3= $(HighP2Str)
	SetVariable P2Value,limits={0,Inf,0.05*CurVal},variable= $(P2Str), proc=IR2S_SFCntrlPnlSetVarProc
	SetVariable P2Value,pos={5,120},size={180,15},title="Volume fraction (phi) = ", help={"Volume fraction (or phi for old interferences)"}
	if(stringmatch(CurrentSF,"Interferences"))
		SetVariable P2Value,title="Phi (~ 8 * Vol fract) = ", help={"Phi for old interferences"}
	endif
	if(stringmatch(CurrentSF,"InterPrecipitate"))
		SetVariable P2Value,title="Sigma = ", help={"Sigma (~ volume fraction)"}
	endif
	if(stringmatch(CurrentSF,"User"))
		SetVariable P2Value,title="Param 2 = ", help={"Parameter 2 of user defined formula"}
	endif
	if(stringmatch(CurrentSF,"HayerPenfoldMSA"))
		SetVariable P2Value,title="Charge = ", help={"Number of charges"}
	endif
	if (strlen(FitP2Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
		CheckBox FitP2Value,pos={200,120},size={25,16},proc=IR2S_SFCntrlPnlCheckboxProc,title=" "
		CheckBox FitP2Value,variable= $(FitP2Str), help={"Fit this parameter?"}
		NVAR disableMe= $(FitP2Str)
		SetVariable P2LowLim,limits={0,Inf,0},variable= $(LowP2Str), disable=(!disableMe||NoFittingLimitsL)
		SetVariable P2LowLim,pos={220,120},size={80,15},title=" ", help={"Low limit for fitting param 2"}
		SetVariable P2HighLim,limits={0,Inf,0},variable= $(HighP2Str), disable=(!disableMe||NoFittingLimitsL)
		SetVariable P2HighLim,pos={320,120},size={80,15},title=" ", help={"High limit for fitting param 2"}
	endif



//Square Well		1. Radius
//					2. volume fraction
//					3. well depth (kT)
//					4. well width (diameter)
//SquareWell;StickySpheres

//other parameters
	if(stringmatch(CurrentSF,"SquareWell"))
	
		NVAR/Z CurVal= $(FitP3Str)
		NVAR/Z CurVal2= $(LowP3Str)
		NVAR/Z CurVal3= $(HighP3Str)
		SetVariable P3Value,limits={0,Inf,0.05*CurVal},variable= $(P3Str), proc=IR2S_SFCntrlPnlSetVarProc
		SetVariable P3Value,pos={5,140},size={180,15},title="Well depth [kT] = ", help={"Square Well depth"}
		if (strlen(FitP3Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP3Value,pos={200,140},size={25,16},proc=IR2S_SFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP3Value,variable= $(FitP3Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP3Str)
			SetVariable P3LowLim,limits={0,Inf,0},variable= $(LowP3Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P3LowLim,pos={220,140},size={80,15},title=" ", help={"Low limit for fitting param 3"} 
			SetVariable P3HighLim,limits={0,Inf,0},variable= $(HighP3Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P3HighLim,pos={320,140},size={80,15},title=" ", help={"High limit for fitting param 3"} 
		endif

		NVAR/Z CurVal= $(FitP4Str)
		NVAR/Z CurVal2= $(LowP4Str)
		NVAR/Z CurVal3= $(HighP4Str)
		SetVariable P4Value,limits={0,Inf,0.05*CurVal},variable= $(P4Str), proc=IR2S_SFCntrlPnlSetVarProc
		SetVariable P4Value,pos={5,160},size={180,15},title="Well width (in diameters) = ", help={"Well width (in diameters)"} 
		if (strlen(FitP4Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP4Value,pos={200,160},size={25,16},proc=IR2S_SFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP4Value,variable= $(FitP4Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP4Str)
			SetVariable P4LowLim,limits={0,Inf,0},variable= $(LowP4Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P4LowLim,pos={220,160},size={80,15},title=" ", help={"Low limit for fitting param 4"} 
			SetVariable P4HighLim,limits={0,Inf,0},variable= $(HighP4Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P4HighLim,pos={320,160},size={80,15},title=" ", help={"High limit for fitting param 4"} 
		endif

	endif		
	
// Sticky hard sphere	1. Radius
//					2. Volume fraction
//					3. Perturbation parameter
//					4. Stickiness
	if(stringmatch(CurrentSF,"StickyHardSpheres"))	
		NVAR/Z CurVal= $(FitP3Str)
		NVAR/Z CurVal2= $(LowP3Str)
		NVAR/Z CurVal3= $(HighP3Str)
		SetVariable P3Value,limits={0,Inf,0.05*CurVal},variable= $(P3Str), proc=IR2S_SFCntrlPnlSetVarProc
		SetVariable P3Value,pos={5,140},size={180,15},title="Perturbation parameter = ", help={"Perturbation paramter for this Structure factor"} 
		if (strlen(FitP3Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP3Value,pos={200,140},size={25,16},proc=IR2S_SFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP3Value,variable= $(FitP3Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP3Str)
			SetVariable P3LowLim,limits={0,Inf,0},variable= $(LowP3Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P3LowLim,pos={220,140},size={80,15},title=" ", help={"Low limit for fitting param 3"} 
			SetVariable P3HighLim,limits={0,Inf,0},variable= $(HighP3Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P3HighLim,pos={320,140},size={80,15},title=" ", help={"High limit for fitting param 3"} 
		endif

		NVAR/Z CurVal= $(FitP4Str)
		NVAR/Z CurVal2= $(LowP4Str)
		NVAR/Z CurVal3= $(HighP4Str)
		SetVariable P4Value,limits={0,Inf,0.05*CurVal},variable= $(P4Str), proc=IR2S_SFCntrlPnlSetVarProc
		SetVariable P4Value,pos={5,160},size={180,15},title="Stickiness = ", help={"Stickyness for this structure factor"} 
		if (strlen(FitP4Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP4Value,pos={200,160},size={25,16},proc=IR2S_SFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP4Value,variable= $(FitP4Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP4Str)
			SetVariable P4LowLim,limits={0,Inf,0},variable= $(LowP4Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P4LowLim,pos={220,160},size={80,15},title=" ", help={"Low limit for fitting param 4"} 
			SetVariable P4HighLim,limits={0,Inf,0},variable= $(HighP4Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P4HighLim,pos={320,160},size={80,15},title=" ", help={"High limit for fitting param 4"} 
		endif

	endif		
// HayerPenfoldMSA	1. Radius
//					2. Charges
//					3. Volume fraction
//					4. Temperature
//					5. M (monovalent salt conc)
//					6. Dielectric constant of solvent
	if(stringmatch(CurrentSF,"HayerPenfoldMSA"))	
		NVAR/Z CurVal= $(FitP3Str)
		NVAR/Z CurVal2= $(LowP3Str)
		NVAR/Z CurVal3= $(HighP3Str)
		SetVariable P3Value,limits={0,Inf,0.05*CurVal},variable= $(P3Str), proc=IR2S_SFCntrlPnlSetVarProc
		SetVariable P3Value,pos={5,140},size={180,15},title="Volume fraction = ", help={"Volume fraction for this Structure factor"} 
		if (strlen(FitP3Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP3Value,pos={200,140},size={25,16},proc=IR2S_SFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP3Value,variable= $(FitP3Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP3Str)
			SetVariable P3LowLim,limits={0,Inf,0},variable= $(LowP3Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P3LowLim,pos={220,140},size={80,15},title=" ", help={"Low limit for fitting param 3"} 
			SetVariable P3HighLim,limits={0,Inf,0},variable= $(HighP3Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P3HighLim,pos={320,140},size={80,15},title=" ", help={"High limit for fitting param 3"} 
		endif

		NVAR/Z CurVal= $(FitP4Str)
		NVAR/Z CurVal2= $(LowP4Str)
		NVAR/Z CurVal3= $(HighP4Str)
		SetVariable P4Value,limits={0,Inf,0.05*CurVal},variable= $(P4Str), proc=IR2S_SFCntrlPnlSetVarProc
		SetVariable P4Value,pos={5,160},size={180,15},title="Temperature = ", help={"Temperature in degrees K for this structure factor"} 
		if (strlen(FitP4Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP4Value,pos={200,160},size={25,16},proc=IR2S_SFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP4Value,variable= $(FitP4Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP4Str)
			SetVariable P4LowLim,limits={0,Inf,0},variable= $(LowP4Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P4LowLim,pos={220,160},size={80,15},title=" ", help={"Low limit for fitting param 4"} 
			SetVariable P4HighLim,limits={0,Inf,0},variable= $(HighP4Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P4HighLim,pos={320,160},size={80,15},title=" ", help={"High limit for fitting param 4"} 
		endif

		NVAR/Z CurVal= $(FitP5Str)
		NVAR/Z CurVal2= $(LowP5Str)
		NVAR/Z CurVal3= $(HighP5Str)
		SetVariable P5Value,limits={0,Inf,0.05*CurVal},variable= $(P5Str), proc=IR2S_SFCntrlPnlSetVarProc
		SetVariable P5Value,pos={5,180},size={180,15},title="M = ", help={"M (monovalent salt conc) in molarity for this structure factor"} 
		if (strlen(FitP5Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP5Value,pos={200,180},size={25,16},proc=IR2S_SFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP5Value,variable= $(FitP5Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP5Str)
			SetVariable P5LowLim,limits={0,Inf,0},variable= $(LowP5Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P5LowLim,pos={220,180},size={80,15},title=" ", help={"Low limit for fitting param 5"} 
			SetVariable P5HighLim,limits={0,Inf,0},variable= $(HighP5Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P5HighLim,pos={320,180},size={80,15},title=" ", help={"High limit for fitting param 5"} 
		endif

		NVAR/Z CurVal= $(FitP6Str)
		NVAR/Z CurVal2= $(LowP6Str)
		NVAR/Z CurVal3= $(HighP6Str)
		SetVariable P6Value,limits={0,Inf,0.05*CurVal},variable= $(P6Str), proc=IR2S_SFCntrlPnlSetVarProc
		SetVariable P6Value,pos={5,200},size={180,15},title="Diel const of solv = ", help={"Dielectric constant of solvent (unitless) for this structure factor"} 
		if (strlen(FitP6Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP6Value,pos={200,200},size={25,16},proc=IR2S_SFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP6Value,variable= $(FitP6Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP6Str)
			SetVariable P6LowLim,limits={0,Inf,0},variable= $(LowP6Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P6LowLim,pos={220,200},size={80,15},title=" ", help={"Low limit for fitting param 4"} 
			SetVariable P6HighLim,limits={0,Inf,0},variable= $(HighP6Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P6HighLim,pos={320,200},size={80,15},title=" ", help={"High limit for fitting param 4"} 
		endif

	endif		
// User 			1. Param 1
//					2. Param 2
//					3. Param 3
//					4. Param 4
//					5. Param 5
//					6. Param 6
	if(stringmatch(CurrentSF,"User"))	
		NVAR/Z CurVal= $(FitP3Str)
		NVAR/Z CurVal2= $(LowP3Str)
		NVAR/Z CurVal3= $(HighP3Str)
		SetVariable P3Value,limits={0,Inf,0.05*CurVal},variable= $(P3Str), proc=IR2S_SFCntrlPnlSetVarProc
		SetVariable P3Value,pos={5,140},size={180,15},title="Param 3 = ", help={"Parameter 3 of user defined formula"} 
		if (strlen(FitP3Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP3Value,pos={200,140},size={25,16},proc=IR2S_SFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP3Value,variable= $(FitP3Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP3Str)
			SetVariable P3LowLim,limits={0,Inf,0},variable= $(LowP3Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P3LowLim,pos={220,140},size={80,15},title=" ", help={"Low limit for fitting param 3"} 
			SetVariable P3HighLim,limits={0,Inf,0},variable= $(HighP3Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P3HighLim,pos={320,140},size={80,15},title=" ", help={"High limit for fitting param 3"} 
		endif

		NVAR/Z CurVal= $(FitP4Str)
		NVAR/Z CurVal2= $(LowP4Str)
		NVAR/Z CurVal3= $(HighP4Str)
		SetVariable P4Value,limits={0,Inf,0.05*CurVal},variable= $(P4Str), proc=IR2S_SFCntrlPnlSetVarProc
		SetVariable P4Value,pos={5,160},size={180,15},title="Param 4 = ", help={"Parameter 4 of user defined formula"} 
		if (strlen(FitP4Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP4Value,pos={200,160},size={25,16},proc=IR2S_SFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP4Value,variable= $(FitP4Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP4Str)
			SetVariable P4LowLim,limits={0,Inf,0},variable= $(LowP4Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P4LowLim,pos={220,160},size={80,15},title=" ", help={"Low limit for fitting param 4"} 
			SetVariable P4HighLim,limits={0,Inf,0},variable= $(HighP4Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P4HighLim,pos={320,160},size={80,15},title=" ", help={"High limit for fitting param 4"} 
		endif

		NVAR/Z CurVal= $(FitP5Str)
		NVAR/Z CurVal2= $(LowP5Str)
		NVAR/Z CurVal3= $(HighP5Str)
		SetVariable P5Value,limits={0,Inf,0.05*CurVal},variable= $(P5Str), proc=IR2S_SFCntrlPnlSetVarProc
		SetVariable P5Value,pos={5,180},size={180,15},title="Param 5 = ", help={"Parameter 5 of user defined formula"} 
		if (strlen(FitP5Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP5Value,pos={200,180},size={25,16},proc=IR2S_SFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP5Value,variable= $(FitP5Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP5Str)
			SetVariable P5LowLim,limits={0,Inf,0},variable= $(LowP5Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P5LowLim,pos={220,180},size={80,15},title=" ", help={"Low limit for fitting param 5"} 
			SetVariable P5HighLim,limits={0,Inf,0},variable= $(HighP5Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P5HighLim,pos={320,180},size={80,15},title=" ", help={"High limit for fitting param 5"} 
		endif

		NVAR/Z CurVal= $(FitP6Str)
		NVAR/Z CurVal2= $(LowP6Str)
		NVAR/Z CurVal3= $(HighP6Str)
		SetVariable P6Value,limits={0,Inf,0.05*CurVal},variable= $(P6Str), proc=IR2S_SFCntrlPnlSetVarProc
		SetVariable P6Value,pos={5,200},size={180,15},title="Param 6 = ", help={"Parameter 6 of user defined formula"} 
		if (strlen(FitP6Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP6Value,pos={200,200},size={25,16},proc=IR2S_SFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP6Value,variable= $(FitP6Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP6Str)
			SetVariable P6LowLim,limits={0,Inf,0},variable= $(LowP6Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P6LowLim,pos={220,200},size={80,15},title=" ", help={"Low limit for fitting param 4"} 
			SetVariable P6HighLim,limits={0,Inf,0},variable= $(HighP6Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P6HighLim,pos={320,200},size={80,15},title=" ", help={"High limit for fitting param 4"} 
		endif
		SetVariable SFUserSFformula,pos={5,230},limits={0,0,0},size={350,15},title="User SF formula = ", help={"User formula for S(Q)"} 
		SetVariable SFUserSFformula,variable= $(SFUserSFformula)
		
		IR1T_CallUserSQHelpPanel()
	endif		

	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2S_SFCntrlPnlCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:StructureFactorCalc
	SVAR ListOfStructureFactors=root:Packages:StructureFactorCalc:ListOfStructureFactors
	GetWindow StructureFactorControlScreen note
	variable NoFittingLimits = NumberByKey("NoFittingLimits", S_Value,"=",";")
	if(numtype(NoFittingLimits))
		NoFittingLimits = 0
	endif

	string ListOfParams="TitleStr;FFStr;P1Str;FitP1Str;LowP1Str;HighP1Str;P2Str;FitP2Str;LowP2Str;HighP2Str;P3Str;FitP3Str;LowP3Str;HighP3Str;P4Str;FitP4Str;LowP4Str;HighP4Str;P5Str;FitP5Str;LowP5Str;HighP5Str"

	if(stringMatch(ctrlName,"FitP1Value"))
		SetVariable P1LowLim,disable=(!(checked)||NoFittingLimits), win=StructureFactorControlScreen
		SetVariable P1HighLim,disable=(!(checked)||NoFittingLimits), win=StructureFactorControlScreen
	endif
	if(stringMatch(ctrlName,"FitP2Value"))
		SetVariable P2LowLim,disable=(!(checked)||NoFittingLimits), win=StructureFactorControlScreen
		SetVariable P2HighLim,disable=(!(checked)||NoFittingLimits), win=StructureFactorControlScreen
	endif
	if(stringMatch(ctrlName,"FitP3Value"))
		SetVariable P3LowLim,disable=(!(checked)||NoFittingLimits), win=StructureFactorControlScreen
		SetVariable P3HighLim,disable=(!(checked)||NoFittingLimits), win=StructureFactorControlScreen
	endif
	if(stringMatch(ctrlName,"FitP4Value"))
		SetVariable P4LowLim,disable=(!(checked)||NoFittingLimits), win=StructureFactorControlScreen
		SetVariable P4HighLim,disable=(!(checked)||NoFittingLimits), win=StructureFactorControlScreen
	endif
	if(stringMatch(ctrlName,"FitP5Value"))
		SetVariable P5LowLim,disable=(!(checked)||NoFittingLimits), win=StructureFactorControlScreen
		SetVariable P5HighLim,disable=(!(checked)||NoFittingLimits), win=StructureFactorControlScreen
	endif
	if(stringMatch(ctrlName,"FitP6Value"))
		SetVariable P6LowLim,disable=(!(checked)||NoFittingLimits), win=StructureFactorControlScreen
		SetVariable P6HighLim,disable=(!(checked)||NoFittingLimits), win=StructureFactorControlScreen
	endif

	setDataFolder OldDf

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2S_SFCntrlPnlSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	if(stringmatch("P1Value",ctrlName))
		ControlInfo/W=StructureFactorControlScreen P1value
		NVAR P1Var=$(S_DataFolder+S_value)
		ControlInfo/W=StructureFactorControlScreen P1LowLim
		NVAR P1LowLimVar=$(S_DataFolder+S_value)
		ControlInfo/W=StructureFactorControlScreen P1HighLim
		NVAR P1HighLimVar=$(S_DataFolder+S_value)
		P1LowLimVar=0.8 *  P1Var
		P1HighLimVar= 1.2 * P1Var
		SetVariable P1Value,win=StructureFactorControlScreen,limits={0,Inf,(varNum*0.05)}
	endif

	if(stringmatch("P2Value",ctrlName))
		ControlInfo/W=StructureFactorControlScreen P2value
		NVAR P2Var=$(S_DataFolder+S_value)
		ControlInfo/W=StructureFactorControlScreen P2LowLim
		NVAR P2LowLimVar=$(S_DataFolder+S_value)
		ControlInfo/W=StructureFactorControlScreen P2HighLim
		NVAR P2HighLimVar=$(S_DataFolder+S_value)
		P2LowLimVar=0.8 *  P2Var
		P2HighLimVar= 1.2 * P2Var
		SetVariable P2Value,win=StructureFactorControlScreen,limits={0,Inf,(varNum*0.05)}	
	endif

	if(stringmatch("P3Value",ctrlName))
		ControlInfo/W=StructureFactorControlScreen P3value
		NVAR P3Var=$(S_DataFolder+S_value)
		ControlInfo/W=StructureFactorControlScreen P3LowLim
		NVAR P3LowLimVar=$(S_DataFolder+S_value)
		ControlInfo/W=StructureFactorControlScreen P3HighLim
		NVAR P3HighLimVar=$(S_DataFolder+S_value)
		P3LowLimVar=0.8 *  P3Var
		P3HighLimVar= 1.2 * P3Var
		SetVariable P3Value,win=StructureFactorControlScreen,limits={0,Inf,(varNum*0.05)}	
	endif


	if(stringmatch("P4Value",ctrlName))
		ControlInfo/W=StructureFactorControlScreen P4value
		NVAR P4Var=$(S_DataFolder+S_value)
		ControlInfo/W=StructureFactorControlScreen P4LowLim
		NVAR P4LowLimVar=$(S_DataFolder+S_value)
		ControlInfo/W=StructureFactorControlScreen P4HighLim
		NVAR P4HighLimVar=$(S_DataFolder+S_value)
		P4LowLimVar=0.8 *  P4Var
		P4HighLimVar= 1.2 * P4Var
		SetVariable P4Value,win=StructureFactorControlScreen,limits={0,Inf,(varNum*0.05)}
	endif


	if(stringmatch("P5Value",ctrlName))
		ControlInfo/W=StructureFactorControlScreen P5value
		NVAR P5Var=$(S_DataFolder+S_value)
		ControlInfo/W=StructureFactorControlScreen P5LowLim
		NVAR P5LowLimVar=$(S_DataFolder+S_value)
		ControlInfo/W=StructureFactorControlScreen P5HighLim
		NVAR P5HighLimVar=$(S_DataFolder+S_value)
		P5LowLimVar=0.8 *  P5Var
		P5HighLimVar= 1.2 * P5Var
		SetVariable P5Value,win=StructureFactorControlScreen,limits={0,Inf,(varNum*0.05)}
	endif


	if(stringmatch("P6Value",ctrlName))
		ControlInfo/W=StructureFactorControlScreen P6value
		NVAR P6Var=$(S_DataFolder+S_value)
		ControlInfo/W=StructureFactorControlScreen P6LowLim
		NVAR P6LowLimVar=$(S_DataFolder+S_value)
		ControlInfo/W=StructureFactorControlScreen P6HighLim
		NVAR P6HighLimVar=$(S_DataFolder+S_value)
		P6LowLimVar=0.8 *  P6Var
		P6HighLimVar= 1.2 * P6Var
		SetVariable P6Value,win=StructureFactorControlScreen,limits={0,Inf,(varNum*0.05)}	
	endif

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2S_InterprecipitateSF(w,x) : FitFunc
	Wave w
	Variable x

		//Interprecipitate structure factor is from:
		//
		//APPLIED PHYSICS LETTERS 93, 161904 (2008)
		//
		//Study of nanoprecipitates in a nickel-based superalloy using small-angle 
		//neutron scattering and transmission electron microscopy 
		//
		//E-Wen Huang, Peter K. Liaw, Lionel Porcar, Yun Liu, Yee-Lang Liu, 
		//Ji-Jung Kai, and Wei-Ren Chen
		//
		//Formula 6, refers to paper by R. Giordano, A. Grasso, and J. Teixeira, Phys. Rev. A 43, 6894    1991 
		//
		//Structutre factor has two paraeters - L distance and sigma  - root-mean-square deviation (ordering factor)
		//
	Variable L, sigma, top, bot, Q
	L = w[0]
	sigma = w[1]
	Q = x

	top = 1 - exp(-(Q^2*sigma^2)/4)*cos(Q*L)
	bot = 1-2*exp(-(Q^2 * sigma^2)/4)* cos(Q*L) + exp(-(Q^2*sigma^2)/2)
	//S(Q,L,sig) = 2*(top/bot) - 1

	return 2*(top/bot) - 1

end



//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2S_OldInterferences(w,x) : FitFunc
	Wave w
	Variable x

	Variable eta, pack, temp
	eta = w[0]
	pack = w[1]

	temp = (3*(sin(x*eta)-x*eta*cos(x*eta))/(x*eta)^3)

	return (1/(1+pack*temp))

end

//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
Function IR2S_SquareWellStruct(w,x) : FitFunc
	Wave w
	Variable x

//     SUBROUTINE SQWELL: CALCULATES THE STRUCTURE FACTOR FOR A
//                        DISPERSION OF MONODISPERSE HARD SPHERES
//     IN THE Mean Spherical APPROXIMATION ASSUMING THE SPHERES
//     INTERACT THROUGH A SQUARE WELL POTENTIAL.
//** not the best choice of closure ** see note below
//     REFS:  SHARMA,SHARMA, PHYSICA 89A,(1977),212
//
//     
 
// NOTE - depths >1.5kT and volume fractions > 0.08 give UNPHYSICAL RESULTS
// when compared to Monte Carlo simulations

// Input variables are:
	//[0] radius
	//[1] volume fraction
	//[2] well depth e/kT, dimensionless, +ve depths are attractive
	//[3] well width, multiples of diameter
	
	Variable req,phis,edibkb,lambda,struc
	req = w[0]
	phis = w[1]
	edibkb = w[2]
	lambda = w[3]
	
//  COMPUTE CONSTANTS
//  local variables
	Variable sigma,eta,eta2,eta3,eta4,etam1,etam14,alpha,BetaVar,gammaVar
	Variable qvs,sk,sk2,sk3,sk4,t1,t2,t3,t4,ck
	 
      SIGMA = req*2.
      ETA = phis
      ETA2 = ETA*ETA
      ETA3 = ETA*ETA2
      ETA4 = ETA*ETA3       
      ETAM1 = 1. - ETA 
      ETAM14 = ETAM1*ETAM1*ETAM1*ETAM1
      ALPHA = (  ( (1. + 2.*ETA)^2 ) + ETA3*( ETA-4.0 )  )/ETAM14
      BetaVar = -(ETA/3.0) * ( 18. + 20.*ETA - 12.*ETA2 + ETA4 )/ETAM14
      gammaVar = 0.5*ETA*( (1. + 2.*ETA)^2 + ETA3*(ETA-4.) )/ETAM14
//
//  CALCULATE THE STRUCTURE FACTOR
//
// the loop over q-values used to be here     
//      DO 20 I=1,NPTSM
        QVS = x
        SK = x*SIGMA
        SK2 = SK*SK
        SK3 = SK*SK2
        SK4 = SK3*SK
        T1 = ALPHA * SK3 * ( SIN(SK) - SK * COS(SK) )
        T2 = BetaVar * SK2 * ( 2.*SK*SIN(SK) - (SK2-2.)*COS(SK) - 2.0 )
        T3 =   ( 4.0*SK3 - 24.*SK ) * SIN(SK)  
        T3 = T3 - ( SK4 - 12.0*SK2 + 24.0 )*COS(SK) + 24.0    
        T3 = gammaVar*T3
        T4 = -EDIBKB*SK3*(SIN(LAMBDA*SK) - LAMBDA*SK*COS(LAMBDA*SK)+ SK*COS(SK) - SIN(SK) )
        CK =  -24.0*ETA*( T1 + T2 + T3 + T4 )/SK3/SK3
        STRUC  = 1./(1.-CK)
//   20 CONTINUE
      Return struc
End





//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************

Function IR2S_StickyHS_Struct(w,x) : FitFunc
	Wave w
	Variable x
//	 Input (fitting) variables are:
	//radius = w[0]
	//volume fraction = w[1]
	//epsilon (perurbation param) = w[2]
	//tau (stickiness) = w[3]
	Variable rad,phi,eps,tau,eta
	Variable sig,aa,etam1,qa,qb,qc,radic
	Variable lam,lam2,test,mu,alpha,BetaVar
	Variable qv,kk,k2,k3,ds,dc,aq1,aq2,aq3,aq,bq1,bq2,bq3,bq,sq
	rad = w[0]
	phi = w[1]
	eps = w[2]
	tau = w[3]
	
	eta = phi/(1.0-eps)/(1.0-eps)/(1.0-eps)
	
	sig = 2.0 * rad
	aa = sig/(1.0 - eps)
	etam1 = 1.0 - eta
//C
//C  SOLVE QUADRATIC FOR LAMBDA
//C
	qa = eta/12.0
	qb = -1.0*(tau + eta/(etam1))
	qc = (1.0 + eta/2.0)/(etam1*etam1)
	radic = qb*qb - 4.0*qa*qc
	if(radic<0)
		if(x>0.01 && x<0.015)
	 		Print "Lambda unphysical - both roots imaginary"
	 	endif
	 	return(-1)
	endif
//C   KEEP THE SMALLER ROOT, THE LARGER ONE IS UNPHYSICAL
	lam = (-1.0*qb-sqrt(radic))/(2.0*qa)
	lam2 = (-1.0*qb+sqrt(radic))/(2.0*qa)
	if(lam2<lam)
		lam = lam2
	endif
	test = 1.0 + 2.0*eta
	mu = lam*eta*etam1
	if(mu>test)
		if(x>0.01 && x<0.015)
		 Print "Lambda unphysical mu>test"
		endif
		return(-1)
	endif
	alpha = (1.0 + 2.0*eta - mu)/(etam1*etam1)
	BetaVar = (mu - 3.0*eta)/(2.0*etam1*etam1)
	
//C
//C   CALCULATE THE STRUCTURE FACTOR
//C

	qv = x
	kk = qv*aa
	k2 = kk*kk
	k3 = kk*k2
	ds = sin(kk)
	dc = cos(kk)
	aq1 = ((ds - kk*dc)*alpha)/k3
	aq2 = (BetaVar*(1.0-dc))/k2
	aq3 = (lam*ds)/(12.0*kk)
	aq = 1.0 + 12.0*eta*(aq1+aq2-aq3)
//
	bq1 = alpha*(0.5/kk - ds/k2 + (1.0 - dc)/k3)
	bq2 = BetaVar*(1.0/kk - ds/k2)
	bq3 = (lam/12.0)*((1.0 - dc)/kk)
	bq = 12.0*eta*(bq1+bq2-bq3)
//
	sq = 1.0/(aq*aq +bq*bq)

	Return (sq)
End


//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************

threadsafe Function IR2S_HardSphereStruct(w,x) : FitFunc
	Wave w
	Variable x
	                
//     SUBROUTINE HSSTRCT: CALCULATES THE STRUCTURE FACTOR FOR A
//                         DISPERSION OF MONODISPERSE HARD SPHERES
//                         IN THE PERCUS-YEVICK APPROXIMATION
//
//     REFS:  PERCUS,YEVICK PHYS. REV. 110 1 (1958)
//            THIELE J. CHEM PHYS. 39 474 (1968)
//            WERTHEIM  PHYS. REV. LETT. 47 1462 (1981)
//
// Input variables are:
	//[0] radius
	//[1] volume fraction
	//Variable timer=StartMSTimer
	
	Variable r,phi,struc
	r = w[0]
	phi = w[1]

// Local variables
	Variable denom,dnum,alpha,BetaVar,gamm,q,a,asq,ath,afor,rca,rsa
	Variable calp,cbeta,cgam,prefac,c,vstruc
//  COMPUTE CONSTANTS
//
      DENOM = (1.0-PHI)^4
      DNUM = (1.0 + 2.0*PHI)^2
      ALPHA = DNUM/DENOM
      BetaVar = -6.0*PHI*((1.0 + PHI/2.0)^2)/DENOM
      GAMM = 0.50*PHI*DNUM/DENOM
//
//  CALCULATE THE STRUCTURE FACTOR
//     
// loop over q-values used to be here
//      DO 10 I=1,NPTSM
        Q = x		// q-value for the calculation is passed in as variable x
        A = 2.0*Q*R
//        IF(A.LT.1.0D-10)  A = 1.0D-10
        ASQ = A*A
        ATH = ASQ*A
        AFOR = ATH*A
        RCA = COS(A)
        RSA = SIN(A)
        CALP = ALPHA*(RSA/ASQ - RCA/A)
        CBETA = BetaVar*(2.0*RSA/ASQ - (ASQ - 2.0)*RCA/ATH - 2.0/ATH)
        CGAM = GAMM*(-RCA/A + (4.0/A)*((3.0*ASQ - 6.0)*RCA/AFOR + (ASQ - 6.0)*RSA/ATH + 6.0/AFOR))
        PREFAC = -24.0*PHI/A
        C = PREFAC*(CALP + CBETA + CGAM)
        VSTRUC = 1.0/(1.0-C)
        STRUC = VSTRUC
//   10 CONTINUE
	//Variable elapse=StopMSTimer(timer)
      //Print "HS struct eval time (s) = ",elapse
      RETURN Struc
End
// End of HardSphereStruct


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   Wrapper for Hayter Penfold MSA routines:
//		SETS UP THE PARAMETERS FOR THE
//		CALCULATION OF THE STRUCTURE FACTOR ,S(Q)
//		GIVEN THE THREE REQUIRED PARAMETERS VALK, GAMMA, ETA.
//
//      *** NOTE ****  THIS CALCULATION REQUIRES THAT THE NUMBER OF 
//                     Q-VALUES AT WHICH THE S(Q) IS CALCULATED BE
//                     A POWER OF 2
//

Function IR2_HayterPenfoldMSA(w,x) : FitFunc
	wave w
	variable x
      
//      variable timer=StartMSTimer
      IR2_InitHayterPenfoldMSA()
      
      
	variable Elcharge=1.602189e-19		// electron charge in Coulombs (C)
	variable kB=1.380662e-23				// Boltzman constant in J/K
	variable FrSpPerm=8.85418782E-12	//Permittivity of free space in C^2/(N m^2)

	variable SofQ, QQ, Qdiam, gammaek, Vp, csalt, ss
	variable VolFrac, SIdiam, diam, Kappa, cs, IonSt
	variable dialec, Perm, BetaVar, Temp, zz, charge, ierr

	diam=2*w[0]		//note: Wrapper code uses radius, not diameter as the original NIST code... in   (not SI .. should force people to think in nm!!!)
	zz = w[1]		//# of charges
	VolFrac=w[2]	
	QQ=x			//in ^-1 (not SI .. should force people to think in nm^-1!!!)
	Temp=w[3]		//in degrees Kelvin
	csalt=w[4]		//in molarity
	dialec=w[5]		// unitless

//use wave instead
	WAVE gMSAWave = $"root:HayPenMSA:gMSAWave"
	

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// convert to USEFUL inputs in SI units                                                //
////////////////////////////    NOTE: easiest to do EVERYTHING in SI units                               //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	BetaVar=1/(kB*Temp)		// in Joules^-1
	Perm=dialec*FrSpPerm	//in C^2/(N  m^2)
	charge=zz*Elcharge		//in Coulomb (C)
	SIdiam = diam*1E-10		//in m
	Vp=4*pi/3*(SIdiam/2)^3	//in m^3
	cs=csalt*6.022E23*1E3	//# salt molecules/m^3

//         Compute the derived values of :
//			 Ionic strength IonSt (in C^2/m^3)  
// 			Kappa (Debye-Huckel screening length in m)
//	and		gamma Exp(-k)
	IonSt=0.5 * Elcharge^2*(zz*VolFrac/Vp+2*cs)  
	Kappa=sqrt(2*BetaVar*IonSt/Perm)     //Kappa calc from Ionic strength
//	Kappa=2/SIdiam					// Use to compare with HP paper
	gMSAWave[5]=BetaVar*charge^2/(pi*Perm*SIdiam*(2+Kappa*SIdiam)^2)

//         Finally set up dimensionless parameters 
	Qdiam=QQ*diam
   gMSAWave[6] = Kappa*SIdiam
   gMSAWave[4] = VolFrac


      
//  ***************  now go to John Hayter and Jeff Penfold setup routine************
 
 
//    *** ALL FURTHER PROGRAMS COMMENTS ARE FROM J. HAYTER 
//        EXCEPT WHERE INDICATED  ^*
//
//    
//       ROUTINE TO CALCULATE S(Q*SIG) FOR A SCREENED COULOMB
//       POTENTIAL BETWEEN FINITE PARTICLES OF DIAMETER 'SIG'
//       AT ANY VOLUME FRACTION.  THIS ROUTINE IS MUCH MORE POWER-
//       FUL THAN "SQHP" AND SHOULD BE USED TO REPLACE THE LATTER
//       IN EXISTING PROGRAMS.  NOTE THAT THE COMMON AREA IS 
//       CHANGED;  IN PARTICULAR THE POTENTIAL IS PASSED 
//       DIRECTLY AS 'GEK' = GAMMA*EXP(-K) IN THE PRESENT ROUTINE.
//
//     JOHN B. HAYTER
//         
//  ***** THIS VERSION ENTERED ON 5/30/85 BY JOHN F. BILLMAN
//
//       CALLING SEQUENCE:
//
//            CALL SQHPA(QQ,SQ,NPT,IERR)
//
//      QQ:   ARRAY OF DIMENSION NPT CONTAINING THE VALUES
//            OF Q*SIG AT WHICH S(Q*SIG) WILL BE CALCULATED.
//      SQ:   ARRAY OF DIMENSION NPT INTO WHICH THE VALUES OF
//            S(Q*SIG) WILL BE RETURNED
//      NPT:  NUMBER OF VALUES OF Q*SIG
//
//      IERR  > 0:   NORMAL EXIT; IERR=NUMBER OF ITERATIONS
//             -1:   NEWTON ITERATION NON-CONVERGENT IN "SQCOEF"   
//             -2:   NEWTON ITERATION NON-CONVERGENT IN "SQFUN"
//             -3:   CANNOT RESCALE TO G(1+) > 0.
//
//        ALL OTHER PARAMETERS ARE TRANSMITTED THROUGH A SINGLE
//        NAMED COMMON AREA:
// 
//     REAL*8 a,b,//,f 
//     COMMON /SQHPB/ ETA,GEK,AK,A,B,C,F,U,V,GAMK,SETA,SGEK,SAK,SCAL,G1
//                                                  
//     ON ENTRY:
//
//       ETA:    VOLUME FRACTION
//       GEK:    THE CONTACT POTENTIAL GAMMA*EXP(-K)
//        AK:    THE DIMENSIONLESS SCREENING CONSTANT
//               K=KAPPA*SIG  WHERE KAPPA IS THE INVERSE SCREENING
//               LENGTH AND SIG IS THE PARTICLE DIAMETER
//
//     ON EXIT:
//
//       GAMK IS THE COUPLING:  2*GAMMA*SS*EXP(-K/SS), SS=ETA^(1/3).
//       SETA,SGEK AND SAK ARE THE RESCALED INPUT PARAMETERS.
//       SCAL IS THE RESCALING FACTOR:  (ETA/SETA)^(1/3).
//       G1=G(1+), THE CONTACT VALUE OF G(R/SIG).
//       A.B,C,F,U,V ARE THE CONSTANTS APPEARING IN THE ANALYTIC
//       SOLUTION OF THE MSA [HAYTER-PENFOLD; MOL. PHYS. 42: 109 (1981)  
// 
//     NOTES:
//
//       (A)  AFTER THE FIRST CALL TO SQHPA, S(Q*SIG) MAY BE EVALUATED
//            AT OTHER Q*SIG VALUES BY REDEFINING THE ARRAY QQ AND CALLING
//            "SQHCAL" DIRECTLY FROM THE MAIN PROGRAM.
//
//       (B)  THE RESULTING S(Q*SIG) MAY BE TRANSFORMED TO G(SS/SIG)
//            BY USING THE ROUTINE "TROGS"
//
//       (C)  NO ERROR CHECKING OF INPUT PARAMETERS IS PERFORMED;
//            IT IS THE RESPONSIBILITY OF THE CALLING PROGRAM TO 
//            VERIFY VALIDITY.
//
//      SUBROUTINES CALLED BY SQHPA:
//
//         (1) SQCOEF:    RESCALES THE PROBLEM AND CALCULATES THE
//                        APPROPRIATE COEFFICIENTS FOR "SQHCAL"
//
//         (2) SQFUN:     CALCULATES VARIOUS VALUES FOR "SQCOEF"
//
//         (3) SQHCAL:    CALCULATES H-P  S(Q*SIG)  GIVEN IN A,B,C,F
//




//Function sqhpa(qq)  {this is where Hayter-Penfold program began}
		

//       FIRST CALCULATE COUPLING

      ss=gMSAWave[4]^(1.0/3.0)
       gMSAWave[9] = 2.0*ss*gMSAWave[5]*exp(gMSAWave[6]-gMSAWave[6]/ss)

//        CALCULATE COEFFICIENTS, CHECK ALL IS WELL
//        AND IF SO CALCULATE S(Q*SIG)
                         
      ierr=0
      ierr=sqcoef(ierr)
      if (ierr>=0) 
            SofQ=sqhcal(Qdiam)
       else
       	SofQ=NaN
       	print "Error Level = ",ierr
             print "Please report HPMSA problem with above error code"
      endif
      //KillDataFolder root:HayPenMSA
//      variable elapsed=StopMSTimer(timer)
//      Print "elapsed time = ",elapsed

      return SofQ
end

Function IR2_InitHayterPenfoldMSA()
 	string SaveDF=GetDataFolder(1)
 	if (DataFolderExists("root:HayPenMSA"))
 		SetDataFolder root:HayPenMSA
 	else
 		NewDataFolder/S root:HayPenMSA
	endif
	//variable/G a,b,c,f,eta,gek,ak,u,v,gamk,seta,sgek,sak,scal,g1, fval, evar
	Make/O/D/N=17 gMSAWave
	SetDataFolder SaveDF
	//
//	make/o/d/n=(num) xwave_hpmsa, ywave_hpmsa, xdiamwave_hpmsa	
//	xwave_hpmsa = alog(log(qmin) + x*((log(qmax)-log(qmin))/num))		
//	make/o/d coef_hpmsa = {41.5,19,0.0192,298,0.0,78}                    //**** numerical vals, # of variables
//	make/o/t parameters_hpmsa = {"Diameter (A)","Charge","Volume Fraction","Temperature(K)","monovalent salt conc. (M)","dielectric constant of solvent"}
//	Edit parameters_hpmsa,coef_hpmsa
//	ywave_hpmsa := HayterPenfoldMSA(coef_hpmsa,xwave_hpmsa)
//	xdiamwave_hpmsa:=xwave_hpmsa*coef_hpmsa[0]
//	//Display ywave_hpmsa vs xdiamwave_hpmsa	
//	Display ywave_hpmsa vs xwave_hpmsa	
//	ModifyGraph log=0,marker=29,msize=2,mode=4,grid=1			//**** log=0 if linear scale desired
//	Label bottom "q (\\S-1\\M)"
//	Label left "Structure Factor"	
//	AutoPositionWindow/M=1/R=$(WinName(0,1)) $WinName(0,2)

end

/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
//
//
//      CALCULATES RESCALED VOLUME FRACTION AND CORRESPONDING
//      COEFFICIENTS FOR "SQHPA"
//
//      JOHN B. HAYTER   (I.L.L.)    14-SEP-81
//
//      ON EXIT:
//
//      SETA IS THE RESCALED VOLUME FRACTION
//      SGEK IS THE RESCALED CONTACT POTENTIAL
//      SAK IS THE RESCALED SCREENING CONSTANT
//      A,B,C,F,U,V ARE THE MSA COEFFICIENTS
//      G1= G(1+) IS THE CONTACT VALUE OF G(R/SIG):
//      FOR THE GILLAN CONDITION, THE DIFFERENCE FROM
//      ZERO INDICATES THE COMPUTATIONAL ACCURACY.
//
//      IR > 0:    NORMAL EXIT,  IR IS THE NUMBER OF ITERATIONS.
//         < 0:    FAILED TO CONVERGE
//


static Function sqcoef(ir)
	variable ir
	
      variable itm=40.0, acc=5.0E-6, ix,ig,ii,del,e1,e2,f1,f2
      WAVE gMSAWave = $"root:HayPenMSA:gMSAWave"
      
	           
      ig=1
      if (gMSAWave[6]>=(1.0+8.0*gMSAWave[4]))
		ig=0
		gMSAWave[15]=gMSAWave[14]
		 gMSAWave[16]=gMSAWave[4]
		  ix=1
		ir = sqfun(ix,ir)
		gMSAWave[14]=gMSAWave[15]
		 gMSAWave[4]=gMSAWave[16]
		if((ir<0.0) %| (gMSAWave[14]>=0.0))
		   return ir
		endif
	endif
      gMSAWave[10]=min(gMSAWave[4],0.20)
      if ((ig!=1) %| ( gMSAWave[9]>=0.15))
		ii=0                               
		do
			ii=ii+1
			if(ii>itm)
				ir=-1
				return ir		
			endif
			if (gMSAWave[10]<=0.0)
			    gMSAWave[10]=gMSAWave[4]/ii
			endif
			if(gMSAWave[10]>0.6)
			    gMSAWave[10] = 0.35/ii
			 endif
			e1=gMSAWave[10]
			gMSAWave[15]=f1
			gMSAWave[16]=e1
			ix=2
			ir = sqfun(ix,ir)
			f1=gMSAWave[15]
			 e1=gMSAWave[16]
			e2=gMSAWave[10]*1.01
			gMSAWave[15]=f2
			 gMSAWave[16]=e2
			 ix=2
			ir = sqfun(ix,ir)
			f2=gMSAWave[15]
			 e2=gMSAWave[16]
			e2=e1-(e2-e1)*f1/(f2-f1)
			gMSAWave[10] = e2
			del = abs((e2-e1)/e1)
		while (del>acc)
		gMSAWave[15]=gMSAWave[14]
		 gMSAWave[16]=e2
		 ix=4
		ir = sqfun(ix,ir)
		gMSAWave[14]=gMSAWave[15]
		 e2=gMSAWave[16]
		ir=ii
		if ((ig!=1) %| (gMSAWave[10]>=gMSAWave[4])) 
		    return ir
		endif
	endif
	gMSAWave[15]=gMSAWave[14]
	gMSAWave[16]=gMSAWave[4]
	 ix=3
	ir = sqfun(ix,ir)
	gMSAWave[14]=gMSAWave[15]
	 gMSAWave[4]=gMSAWave[16]
	if ((ir>=0) %& (gMSAWave[14]<0.0))
	      ir=-3
	endif
	return ir
end

///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
//
//        
//       CALCULATES VARIOUS COEFFICIENTS AND FUNCTION
//       VALUES FOR "SQCOEF"  (USED BY "SQHPA").
//
//   **  THIS ROUTINE WORKS LOCALLY IN DOUBLE PRECISION  **
//
//       JOHN B. HAYTER    (I.L.L.)  23-MAR-82
//
//       IX=1:   SOLVE FOR LARGE K, RETURN G(1+).
//          2:   RETURN FUNCTION TO SOLVE FOR ETA(GILLAN).
//          3:   ASSUME NEAR GILLAN, SOLVE, RETURN G(1+).
//          4:   RETURN G(1+) FOR ETA=ETA(GILLAN).
//
//



static Function sqfun(ix,ir)
	variable ix, ir
	
      variable acc=1.0e-6, itm=40.0
      variable reta,eta2,eta21,eta22,eta3,eta32,eta2d,eta2d2,eta3d,eta6d,e12,e24,ibig,rgek
      variable rak,ak1,ak2,dak,dak2,dak4,d,d2,dd2,dd4,dd45,ex1,ex2,sk,ck,ckma,skma
      variable al1,al2,al3,al4,al5,al6,be1,be2,be3,vu1,vu2,vu3,vu4,vu5,ph1,ph2,ta1,ta2,ta3,ta4,ta5
      variable a1,a2,a3,b1,b2,b3,v1,v2,v3,p1,p2,p3,pp,pp1,pp2,p1p2,t1,t2,t3,um1,um2,um3,um4,um5,um6
      variable w0,w1,w2,w3,w4,w12,w13,w14,w15,w16,w24,w25,w26,w32,w34,w3425,w35,w3526,w36,w46,w56
      variable fa,fap,ca,e24g,pwk,qpw,pg,ii,del,fun,fund,g24
      WAVE gMSAWave = $"root:HayPenMSA:gMSAWave"
      
//	NVAR a=root:HayPenMSA:a
//	NVAR b=root:HayPenMSA:b
//	NVAR c=root:HayPenMSA:c
//	NVAR f=root:HayPenMSA:f
//	NVAR eta=root:HayPenMSA:eta
//	NVAR gek=root:HayPenMSA:gek
//	NVAR ak=root:HayPenMSA:ak
//	NVAR u=root:HayPenMSA:u
//	NVAR v=root:HayPenMSA:v
//	NVAR gamk=root:HayPenMSA:gamk
//	NVAR seta=root:HayPenMSA:seta
//	NVAR sgek=root:HayPenMSA:sgek
//	NVAR sak=root:HayPenMSA:sak
//	NVAR scal=root:HayPenMSA:scal
//	NVAR g1=root:HayPenMSA:g1
//	NVAR fval=root:HayPenMSA:fval
//	NVAR evar=root:HayPenMSA:evar
	

//     CALCULATE CONSTANTS; NOTATION IS HAYTER PENFOLD (1981)

      reta = gMSAWave[16]                                                
      eta2 = reta*reta
      eta3 = eta2*reta
      e12 = 12.0*reta
      e24 = e12+e12
      gMSAWave[13] = (gMSAWave[4]/gMSAWave[16])^(1.0/3.0)
       gMSAWave[12]=gMSAWave[6]/gMSAWave[13]
      ibig=0
      if (( gMSAWave[12]>15.0) %& (ix==1))
            ibig=1
      endif
       gMSAWave[11] = gMSAWave[5]*gMSAWave[13]*exp(gMSAWave[6]- gMSAWave[12])
      rgek =  gMSAWave[11]
      rak =  gMSAWave[12]
      ak2 = rak*rak
      ak1 = 1.0+rak
      dak2 = 1.0/ak2
      dak4 = dak2*dak2
      d = 1.0-reta
      d2 = d*d
      dak = d/rak                                                  
      dd2 = 1.0/d2
      dd4 = dd2*dd2
      dd45 = dd4*2.0e-1
      eta3d=3.0*reta
      eta6d = eta3d+eta3d
      eta32 = eta3+ eta3
      eta2d = reta+2.0
      eta2d2 = eta2d*eta2d
      eta21 = 2.0*reta+1.0
      eta22 = eta21*eta21

//     ALPHA(I)

      al1 = -eta21*dak
      al2 = (14.0*eta2-4.0*reta-1.0)*dak2
      al3 = 36.0*eta2*dak4

//      BETA(I)

      be1 = -(eta2+7.0*reta+1.0)*dak
      be2 = 9.0*reta*(eta2+4.0*reta-2.0)*dak2
      be3 = 12.0*reta*(2.0*eta2+8.0*reta-1.0)*dak4

//      NU(I)

      vu1 = -(eta3+3.0*eta2+45.0*reta+5.0)*dak
      vu2 = (eta32+3.0*eta2+42.0*reta-2.0e1)*dak2
      vu3 = (eta32+3.0e1*reta-5.0)*dak4
      vu4 = vu1+e24*rak*vu3
      vu5 = eta6d*(vu2+4.0*vu3)

//      PHI(I)
      
      ph1 = eta6d/rak
      ph2 = d-e12*dak2

//      TAU(I)

      ta1 = (reta+5.0)/(5.0*rak)
      ta2 = eta2d*dak2
      ta3 = -e12*rgek*(ta1+ta2)
      ta4 = eta3d*ak2*(ta1*ta1-ta2*ta2)
      ta5 = eta3d*(reta+8.0)*1.0e-1-2.0*eta22*dak2

//     DOUBLE PRECISION SINH(K), COSH(K)

      ex1 = exp(rak)
      ex2 = 0.0
      if ( gMSAWave[12]<20.0)
           ex2=exp(-rak)
      endif
      sk=0.5*(ex1-ex2)
      ck = 0.5*(ex1+ex2)
      ckma = ck-1.0-rak*sk
      skma = sk-rak*ck

//      a(I)

      a1 = (e24*rgek*(al1+al2+ak1*al3)-eta22)*dd4
      if (ibig==0)
		a2 = e24*(al3*skma+al2*sk-al1*ck)*dd4
		a3 = e24*(eta22*dak2-0.5*d2+al3*ckma-al1*sk+al2*ck)*dd4
	endif

//      b(I)

      b1 = (1.5*reta*eta2d2-e12*rgek*(be1+be2+ak1*be3))*dd4
      if (ibig==0)
		b2 = e12*(-be3*skma-be2*sk+be1*ck)*dd4
		b3 = e12*(0.5*d2*eta2d-eta3d*eta2d2*dak2-be3*ckma+be1*sk-be2*ck)*dd4
	endif

//      V(I)

      v1 = (eta21*(eta2-2.0*reta+1.0e1)*2.5e-1-rgek*(vu4+vu5))*dd45
      if (ibig==0)
		v2 = (vu4*ck-vu5*sk)*dd45
		v3 = ((eta3-6.0*eta2+5.0)*d-eta6d*(2.0*eta3-3.0*eta2+18.0*reta+1.0e1)*dak2+e24*vu3+vu4*sk-vu5*ck)*dd45
	endif


//       P(I)

      pp1 = ph1*ph1
      pp2 = ph2*ph2
      pp = pp1+pp2
      p1p2 = ph1*ph2*2.0
      p1 = (rgek*(pp1+pp2-p1p2)-0.5*eta2d)*dd2
      if (ibig==0)
		p2 = (pp*sk+p1p2*ck)*dd2
		p3 = (pp*ck+p1p2*sk+pp1-pp2)*dd2
	endif

//       T(I)
 
      t1 = ta3+ta4*a1+ta5*b1
      if (ibig!=0)

//		VERY LARGE SCREENING:  ASYMPTOTIC SOLUTION

  		v3 = ((eta3-6.0*eta2+5.0)*d-eta6d*(2.0*eta3-3.0*eta2+18.0*reta+1.0e1)*dak2+e24*vu3)*dd45
		t3 = ta4*a3+ta5*b3+e12*ta2 - 4.0e-1*reta*(reta+1.0e1)-1.0
		p3 = (pp1-pp2)*dd2
		b3 = e12*(0.5*d2*eta2d-eta3d*eta2d2*dak2+be3)*dd4
		a3 = e24*(eta22*dak2-0.5*d2-al3)*dd4
		um6 = t3*a3-e12*v3*v3
		um5 = t1*a3+a1*t3-e24*v1*v3
		um4 = t1*a1-e12*v1*v1
		al6 = e12*p3*p3
		al5 = e24*p1*p3-b3-b3-ak2
		al4 = e12*p1*p1-b1-b1
		w56 = um5*al6-al5*um6
		w46 = um4*al6-al4*um6
		fa = -w46/w56
		ca = -fa
		gMSAWave[3] = fa
		gMSAWave[2] = ca
		gMSAWave[1] = b1+b3*fa
		gMSAWave[0] = a1+a3*fa
		gMSAWave[8] = v1+v3*fa
		gMSAWave[14] = -(p1+p3*fa)
		gMSAWave[15] = gMSAWave[14]
		if (abs(gMSAWave[15])<1.0e-3)
		     gMSAWave[15] = 0.0
		endif
		gMSAWave[10] = gMSAWave[16]
	else
		t2 = ta4*a2+ta5*b2+e12*(ta1*ck-ta2*sk)
		t3 = ta4*a3+ta5*b3+e12*(ta1*sk-ta2*(ck-1.0))-4.0e-1*reta*(reta+1.0e1)-1.0

//		MU(i)

		um1 = t2*a2-e12*v2*v2
		um2 = t1*a2+t2*a1-e24*v1*v2
		um3 = t2*a3+t3*a2-e24*v2*v3
		um4 = t1*a1-e12*v1*v1
		um5 = t1*a3+t3*a1-e24*v1*v3
		um6 = t3*a3-e12*v3*v3

//			GILLAN CONDITION ?
//
//			YES - G(X=1+) = 0
//
//			COEFFICIENTS AND FUNCTION VALUE
//
		IF ((IX==1) %| (IX==3))

//			NO - CALCULATE REMAINING COEFFICIENTS.

//			LAMBDA(I)

			al1 = e12*p2*p2
			al2 = e24*p1*p2-b2-b2
			al3 = e24*p2*p3
			al4 = e12*p1*p1-b1-b1
			al5 = e24*p1*p3-b3-b3-ak2
			al6 = e12*p3*p3

//			OMEGA(I)

			w16 = um1*al6-al1*um6
			w15 = um1*al5-al1*um5
			w14 = um1*al4-al1*um4
			w13 = um1*al3-al1*um3
			w12 = um1*al2-al1*um2

			w26 = um2*al6-al2*um6
			w25 = um2*al5-al2*um5
			w24 = um2*al4-al2*um4

			w36 = um3*al6-al3*um6
			w35 = um3*al5-al3*um5
			w34 = um3*al4-al3*um4
			w32 = um3*al2-al3*um2
//
			w46 = um4*al6-al4*um6
			w56 = um5*al6-al5*um6
			w3526 = w35+w26
			w3425 = w34+w25
       
//			QUARTIC COEFFICIENTS

			w4 = w16*w16-w13*w36
			w3 = 2.0*w16*w15-w13*w3526-w12*w36
			w2 = w15*w15+2.0*w16*w14-w13*w3425-w12*w3526
			w1 = 2.0*w15*w14-w13*w24-w12*w3425
			w0 = w14*w14-w12*w24

//			ESTIMATE THE STARTING VALUE OF f

			if (ix==1)

//				LARGE K

				fap = (w14-w34-w46)/(w12-w15+w35-w26+w56-w32)
			else


//				ASSUME NOT TOO FAR FROM GILLAN CONDITION.
//				IF BOTH RGEK AND RAK ARE SMALL, USE P-W ESTIMATE.

				gMSAWave[14]=0.5*eta2d*dd2*exp(-rgek)
				if (( gMSAWave[11]<=2.0) %& ( gMSAWave[11]>=0.0) %& ( gMSAWave[12]<=1.0))
					e24g = e24*rgek*exp(rak)
					pwk = sqrt(e24g)
					qpw = (1.0-sqrt(1.0+2.0*d2*d*pwk/eta22))*eta21/d
					gMSAWave[14] = -qpw*qpw/e24+0.5*eta2d*dd2
				endif
  				pg = p1+gMSAWave[14]
				ca = ak2*pg+2.0*(b3*pg-b1*p3)+e12*gMSAWave[14]*gMSAWave[14]*p3
				ca = -ca/(ak2*p2+2.0*(b3*p2-b2*p3))
				fap = -(pg+p2*ca)/p3
			endif

//			AND REFINE IT ACCORDING TO NEWTON

			ii=0
			do 
  				ii = ii+1
				if (ii>itm)

//					FAILED TO CONVERGE IN ITM ITERATIONS

  					ir=-2
					return ir
				endif
				fa = fap
				fun = w0+(w1+(w2+(w3+w4*fa)*fa)*fa)*fa
				fund = w1+(2.0*w2+(3.0*w3+4.0*w4*fa)*fa)*fa
				fap = fa-fun/fund
				del=abs((fap-fa)/fa)
			while (del>acc)
			ir = ir+ii
			fa = fap
			ca = -(w16*fa*fa+w15*fa+w14)/(w13*fa+w12)
			gMSAWave[14] = -(p1+p2*ca+p3*fa)
			gMSAWave[15] = gMSAWave[14]
			if (abs(gMSAWave[15])<1.0e-3)
			      gMSAWave[15] = 0.0
			endif
			gMSAWave[10] = gMSAWave[16]
		else
			ca = ak2*p1+2.0*(b3*p1-b1*p3)
			ca = -ca/(ak2*p2+2.0*(b3*p2-b2*p3))
			fa = -(p1+p2*ca)/p3
			if (ix==2)
			        gMSAWave[15] = um1*ca*ca+(um2+um3*fa)*ca+um4+um5*fa+um6*fa*fa
			endif
			if (ix==4)
			       gMSAWave[15] = -(p1+p2*ca+p3*fa)
			endif
		endif
   		gMSAWave[3] = fa
		gMSAWave[2] = ca
		gMSAWave[1] = b1+b2*ca+b3*fa
		gMSAWave[0] = a1+a2*ca+a3*fa
		gMSAWave[8] = (v1+v2*ca+v3*fa)/gMSAWave[0]
	endif
   	g24 = e24*rgek*ex1
	 gMSAWave[7] = (rak*ak2*ca-g24)/(ak2*g24)
      return ir
      end

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//
//      CALCULATES S(Q) FOR "SQHPA"
//
//  **  THIS ROUTINE WORKS LOCALLY IN DOUBLE PRECISION **
//
//    JOHN B. HAYTER  (I.L.L.)    19-AUG-81
//


static Function sqhcal(qq)
      	variable qq
      	
      	variable SofQ,etaz,akz,gekz,e24,x1,x2,ck,sk,ak2,qk,q2k,qk2,qk3,qqk,sink,cosk,asink,qcosk,aqk,inter  		
	WAVE gMSAWave = $"root:HayPenMSA:gMSAWave"
	
	
	//NVAR a=root:HayPenMSA:a
	//NVAR b=root:HayPenMSA:b
	//NVAR c=root:HayPenMSA:c
	//NVAR f=root:HayPenMSA:f
	//NVAR eta=root:HayPenMSA:eta
	//NVAR gek=root:HayPenMSA:gek
	//NVAR ak=root:HayPenMSA:ak
	//NVAR u=root:HayPenMSA:u
	//NVAR v=root:HayPenMSA:v
	//NVAR gamk=root:HayPenMSA:gamk
	//NVAR seta=root:HayPenMSA:seta
	//NVAR sgek=root:HayPenMSA:sgek
	//NVAR sak=root:HayPenMSA:sak
	//NVAR scal=root:HayPenMSA:scal
	//NVAR g1=root:HayPenMSA:g1

      etaz = gMSAWave[10]
      akz =  gMSAWave[12]
      gekz =  gMSAWave[11]
      e24 = 24.0*etaz
      x1 = exp(akz)
      x2 = 0.0
      if ( gMSAWave[12]<20.0)
             x2 = exp(-akz)
      endif
      ck = 0.5*(x1+x2)
      sk = 0.5*(x1-x2)
      ak2 = akz*akz

      if (qq<=0.0) 
		SofQ = -1.0/gMSAWave[0]
	else
		qk = qq/gMSAWave[13]
		q2k = qk*qk
		qk2 = 1.0/q2k
		qk3 = qk2/qk
		qqk = 1.0/(qk*(q2k+ak2))
		sink = sin(qk)
		cosk = cos(qk)
		asink = akz*sink
		qcosk = qk*cosk
		aqk = gMSAWave[0]*(sink-qcosk)
     		aqk=aqk+gMSAWave[1]*((2.0*qk2-1.0)*qcosk+2.0*sink-2.0/qk)
     		inter=24.0*qk3+4.0*(1.0-6.0*qk2)*sink
     		aqk=(aqk+0.5*etaz*gMSAWave[0]*(inter-(1.0-12.0*qk2+24.0*qk2*qk2)*qcosk))*qk3
     		aqk=aqk +gMSAWave[2]*(ck*asink-sk*qcosk)*qqk
     		aqk=aqk +gMSAWave[3]*(sk*asink-qk*(ck*cosk-1.0))*qqk
     		aqk=aqk +gMSAWave[3]*(cosk-1.0)*qk2
     		aqk=aqk -gekz*(asink+qcosk)*qqk
		SofQ = 1.0/(1.0-e24*aqk)
      endif
      return SofQ
end
      
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function/T IR1T_IdentifySFParamName(SFactorName,ParameterOrder)
	string SFactorName
	variable ParameterOrder

	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:StructureFactorCalc
	string SFParamName=""
	
	Make/O/T/N=6 Interferences,HardSpheres,SquareWell,StickyHardSpheres,HayerPenfoldMSA, InterPrecipitate
	
	//Spheroid 				= {"Aspect Ratio","","","",""}
	Interferences		= {"Radius (ETA)","Volume fraction (phi)","","","",""}
	HardSpheres		= {"Radius","Volume fraction","","","",""}
	SquareWell			= {"Radius","Volume fraction","Well depth (kT)","Well width (in diameter)","",""}
	StickyHardSpheres		= {"Radius","Volume fraction","Perturbation parameter","Stickiness","",""}
	HayerPenfoldMSA	= {"Radius","Charge","Volume Fraction","Temperature","M","Diel Const of solvent"}
	InterPrecipitate		= {"Distance L","Sigma ","","","",""}
	
	Wave/T/Z Lookup=$(SFactorName) 
	if(WaveExists(Lookup))
		SFParamName=Lookup[ParameterOrder-1]
	endif
	
	setDataFolder OldDf
	return SFParamName
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR1T_CallUserSQHelpPanel()
	DoWIndow UserDefinedSQ_Help
	if(V_Flag)
		DoWIndow/F UserDefinedSQ_Help
	else
		String nb = "UserDefinedSQ_Help"
		NewNotebook/N=$nb/F=1/V=1/K=1/W=(422,153,950,500)
		Notebook $nb defaultTab=36, statusWidth=252
		Notebook $nb showRuler=1, rulerUnits=1, updating={1, 1}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
		Notebook $nb newRuler=Title, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",12,3,(0,0,0)}
		Notebook $nb ruler=Title, text="To use User defined structure factor\r"
		Notebook $nb ruler=Normal, text="\r"
		Notebook $nb text="You need to define function using two input parameters following example below. The function must return"
		Notebook $nb text=" real value for each Q (note: non negative and reasonable is suggested). \r"
		Notebook $nb text="\r"
		Notebook $nb text="The function must take just two input parameters: wave w={Par1,Par2,Par3,Par4,Par5,Par6} \r"
		Notebook $nb text="with Parameters 1-6 (you do not have to use all parameters) and Q value.\r"
		Notebook $nb text="\r"
		Notebook $nb text="\r"
		Notebook $nb text="Function UseSQExample(w,x)\r"
		Notebook $nb text="\tWave w\t//contains parameters:   {Par1,Par2,Par3,Par4,Par5,Par6}\r"
		Notebook $nb text="\tVariable x\t\t\t\t//this is Q for which to calculate S(Q)\r"
		Notebook $nb text="\tVariable eta, pack, temp\t\t//declare meaningful parameters names\r"
		Notebook $nb text="\teta = w[0]\t\t\t\t//assigne them values\r"
		Notebook $nb text="\tpack = w[1]\r"
		Notebook $nb text="\ttemp = (3*(sin(x*eta)-x*eta*cos(x*eta))/(x*eta)^3)\t//calculate S(Q)\r"
		Notebook $nb text="\ttemp = (1/(1+pack*temp))\r"
		Notebook $nb text="\treturn  temp\t\t\t\t\t\t//return the value\r"
		Notebook $nb text="end\r"
	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
