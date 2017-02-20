#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.05

//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.05 added optional fitting constraints throught string and user input
//2.04 changes to provide user with fit parameters review panel before fitting
//2.03 added NoLimits option
//2.02 user found bug int eh code which caused fitting of RgCo parameters from not used levels. 
//2.01 added license for ANL


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_ConstructTheFittingCommand(skipreset)
	variable skipreset
	//here we need to construct the fitting command and prepare the data for fit...

	string OldDF=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
	

	NVAR UseNoLimits=root:Packages:Irena_UnifFit:UseNoLimits
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR FitSASBackground=root:Packages:Irena_UnifFit:FitSASBackground

//Level1 part	
	NVAR  Level1Rg=root:Packages:Irena_UnifFit:Level1Rg
	NVAR  Level1FitRg=root:Packages:Irena_UnifFit:Level1FitRg
	NVAR  Level1RgLowLimit=root:Packages:Irena_UnifFit:Level1RgLowLimit
	NVAR  Level1RgHighLimit =root:Packages:Irena_UnifFit:Level1RgHighLimit
	NVAR  Level1G=root:Packages:Irena_UnifFit:Level1G
	NVAR  Level1FitG=root:Packages:Irena_UnifFit:Level1FitG
	NVAR  Level1GLowLimit=root:Packages:Irena_UnifFit:Level1GLowLimit
	NVAR  Level1GHighLimit =root:Packages:Irena_UnifFit:Level1GHighLimit
	NVAR  Level1P=root:Packages:Irena_UnifFit:Level1P
	NVAR  Level1FitP=root:Packages:Irena_UnifFit:Level1FitP
	NVAR  Level1PLowLimit=root:Packages:Irena_UnifFit:Level1PLowLimit
	NVAR  Level1PHighLimit=root:Packages:Irena_UnifFit:Level1PHighLimit
	NVAR  Level1B=root:Packages:Irena_UnifFit:Level1B
	NVAR  Level1FitB=root:Packages:Irena_UnifFit:Level1FitB
	NVAR  Level1BLowLimit=root:Packages:Irena_UnifFit:Level1BLowLimit
	NVAR  Level1BHighLimit=root:Packages:Irena_UnifFit:Level1BHighLimit
	NVAR  Level1ETA=root:Packages:Irena_UnifFit:Level1ETA
	NVAR  Level1FitETA=root:Packages:Irena_UnifFit:Level1FitETA
	NVAR  Level1ETALowLimit =root:Packages:Irena_UnifFit:Level1ETALowLimit
	NVAR  Level1ETAHighLimit=root:Packages:Irena_UnifFit:Level1ETAHighLimit
	NVAR  Level1PACK=root:Packages:Irena_UnifFit:Level1PACK
	NVAR  Level1FitPACK=root:Packages:Irena_UnifFit:Level1FitPACK
	NVAR  Level1PACKLowLimit=root:Packages:Irena_UnifFit:Level1PACKLowLimit
	NVAR  Level1PACKHighLimit=root:Packages:Irena_UnifFit:Level1PACKHighLimit
	NVAR  Level1RgCO=root:Packages:Irena_UnifFit:Level1RgCO
	NVAR  Level1FitRgCO=root:Packages:Irena_UnifFit:Level1FitRgCO
	NVAR  Level1RgCOLowLimit=root:Packages:Irena_UnifFit:Level1RgCOLowLimit
	NVAR  Level1RgCOHighLimit=root:Packages:Irena_UnifFit:Level1RgCOHighLimit
	NVAR  Level1K=root:Packages:Irena_UnifFit:Level1K
	NVAR  Level1Corelations=root:Packages:Irena_UnifFit:Level1Corelations
	NVAR  Level1MassFractal=root:Packages:Irena_UnifFit:Level1MassFractal
	NVAR  Level1LinkRGCO=root:Packages:Irena_UnifFit:Level1LinkRGCO
	
//Level2 part	
	NVAR  Level2Rg=root:Packages:Irena_UnifFit:Level2Rg
	NVAR  Level2FitRg=root:Packages:Irena_UnifFit:Level2FitRg
	NVAR  Level2RgLowLimit=root:Packages:Irena_UnifFit:Level2RgLowLimit
	NVAR  Level2RgHighLimit =root:Packages:Irena_UnifFit:Level2RgHighLimit
	NVAR  Level2G=root:Packages:Irena_UnifFit:Level2G
	NVAR  Level2FitG=root:Packages:Irena_UnifFit:Level2FitG
	NVAR  Level2GLowLimit=root:Packages:Irena_UnifFit:Level2GLowLimit
	NVAR  Level2GHighLimit =root:Packages:Irena_UnifFit:Level2GHighLimit
	NVAR  Level2P=root:Packages:Irena_UnifFit:Level2P
	NVAR  Level2FitP=root:Packages:Irena_UnifFit:Level2FitP
	NVAR  Level2PLowLimit=root:Packages:Irena_UnifFit:Level2PLowLimit
	NVAR  Level2PHighLimit=root:Packages:Irena_UnifFit:Level2PHighLimit
	NVAR  Level2B=root:Packages:Irena_UnifFit:Level2B
	NVAR  Level2FitB=root:Packages:Irena_UnifFit:Level2FitB
	NVAR  Level2BLowLimit=root:Packages:Irena_UnifFit:Level2BLowLimit
	NVAR  Level2BHighLimit=root:Packages:Irena_UnifFit:Level2BHighLimit
	NVAR  Level2ETA=root:Packages:Irena_UnifFit:Level2ETA
	NVAR  Level2FitETA=root:Packages:Irena_UnifFit:Level2FitETA
	NVAR  Level2ETALowLimit =root:Packages:Irena_UnifFit:Level2ETALowLimit
	NVAR  Level2ETAHighLimit=root:Packages:Irena_UnifFit:Level2ETAHighLimit
	NVAR  Level2PACK=root:Packages:Irena_UnifFit:Level2PACK
	NVAR  Level2FitPACK=root:Packages:Irena_UnifFit:Level2FitPACK
	NVAR  Level2PACKLowLimit=root:Packages:Irena_UnifFit:Level2PACKLowLimit
	NVAR  Level2PACKHighLimit=root:Packages:Irena_UnifFit:Level2PACKHighLimit
	NVAR  Level2RgCO=root:Packages:Irena_UnifFit:Level2RgCO
	NVAR  Level2FitRgCO=root:Packages:Irena_UnifFit:Level2FitRgCO
	NVAR  Level2RgCOLowLimit=root:Packages:Irena_UnifFit:Level2RgCOLowLimit
	NVAR  Level2RgCOHighLimit=root:Packages:Irena_UnifFit:Level2RgCOHighLimit
	NVAR  Level2K=root:Packages:Irena_UnifFit:Level2K
	NVAR  Level2Corelations=root:Packages:Irena_UnifFit:Level2Corelations
	NVAR  Level2MassFractal=root:Packages:Irena_UnifFit:Level2MassFractal
	NVAR  Level2LinkRGCO=root:Packages:Irena_UnifFit:Level2LinkRGCO
//Level3 part	
	NVAR  Level3Rg=root:Packages:Irena_UnifFit:Level3Rg
	NVAR  Level3FitRg=root:Packages:Irena_UnifFit:Level3FitRg
	NVAR  Level3RgLowLimit=root:Packages:Irena_UnifFit:Level3RgLowLimit
	NVAR  Level3RgHighLimit =root:Packages:Irena_UnifFit:Level3RgHighLimit
	NVAR  Level3G=root:Packages:Irena_UnifFit:Level3G
	NVAR  Level3FitG=root:Packages:Irena_UnifFit:Level3FitG
	NVAR  Level3GLowLimit=root:Packages:Irena_UnifFit:Level3GLowLimit
	NVAR  Level3GHighLimit =root:Packages:Irena_UnifFit:Level3GHighLimit
	NVAR  Level3P=root:Packages:Irena_UnifFit:Level3P
	NVAR  Level3FitP=root:Packages:Irena_UnifFit:Level3FitP
	NVAR  Level3PLowLimit=root:Packages:Irena_UnifFit:Level3PLowLimit
	NVAR  Level3PHighLimit=root:Packages:Irena_UnifFit:Level3PHighLimit
	NVAR  Level3B=root:Packages:Irena_UnifFit:Level3B
	NVAR  Level3FitB=root:Packages:Irena_UnifFit:Level3FitB
	NVAR  Level3BLowLimit=root:Packages:Irena_UnifFit:Level3BLowLimit
	NVAR  Level3BHighLimit=root:Packages:Irena_UnifFit:Level3BHighLimit
	NVAR  Level3ETA=root:Packages:Irena_UnifFit:Level3ETA
	NVAR  Level3FitETA=root:Packages:Irena_UnifFit:Level3FitETA
	NVAR  Level3ETALowLimit =root:Packages:Irena_UnifFit:Level3ETALowLimit
	NVAR  Level3ETAHighLimit=root:Packages:Irena_UnifFit:Level3ETAHighLimit
	NVAR  Level3PACK=root:Packages:Irena_UnifFit:Level3PACK
	NVAR  Level3FitPACK=root:Packages:Irena_UnifFit:Level3FitPACK
	NVAR  Level3PACKLowLimit=root:Packages:Irena_UnifFit:Level3PACKLowLimit
	NVAR  Level3PACKHighLimit=root:Packages:Irena_UnifFit:Level3PACKHighLimit
	NVAR  Level3RgCO=root:Packages:Irena_UnifFit:Level3RgCO
	NVAR  Level3FitRgCO=root:Packages:Irena_UnifFit:Level3FitRgCO
	NVAR  Level3RgCOLowLimit=root:Packages:Irena_UnifFit:Level3RgCOLowLimit
	NVAR  Level3RgCOHighLimit=root:Packages:Irena_UnifFit:Level3RgCOHighLimit
	NVAR  Level3K=root:Packages:Irena_UnifFit:Level3K
	NVAR  Level3Corelations=root:Packages:Irena_UnifFit:Level3Corelations
	NVAR  Level3MassFractal=root:Packages:Irena_UnifFit:Level3MassFractal
	NVAR  Level3LinkRGCO=root:Packages:Irena_UnifFit:Level3LinkRGCO
//Level4 part	
	NVAR  Level4Rg=root:Packages:Irena_UnifFit:Level4Rg
	NVAR  Level4FitRg=root:Packages:Irena_UnifFit:Level4FitRg
	NVAR  Level4RgLowLimit=root:Packages:Irena_UnifFit:Level4RgLowLimit
	NVAR  Level4RgHighLimit =root:Packages:Irena_UnifFit:Level4RgHighLimit
	NVAR  Level4G=root:Packages:Irena_UnifFit:Level4G
	NVAR  Level4FitG=root:Packages:Irena_UnifFit:Level4FitG
	NVAR  Level4GLowLimit=root:Packages:Irena_UnifFit:Level4GLowLimit
	NVAR  Level4GHighLimit =root:Packages:Irena_UnifFit:Level4GHighLimit
	NVAR  Level4P=root:Packages:Irena_UnifFit:Level4P
	NVAR  Level4FitP=root:Packages:Irena_UnifFit:Level4FitP
	NVAR  Level4PLowLimit=root:Packages:Irena_UnifFit:Level4PLowLimit
	NVAR  Level4PHighLimit=root:Packages:Irena_UnifFit:Level4PHighLimit
	NVAR  Level4B=root:Packages:Irena_UnifFit:Level4B
	NVAR  Level4FitB=root:Packages:Irena_UnifFit:Level4FitB
	NVAR  Level4BLowLimit=root:Packages:Irena_UnifFit:Level4BLowLimit
	NVAR  Level4BHighLimit=root:Packages:Irena_UnifFit:Level4BHighLimit
	NVAR  Level4ETA=root:Packages:Irena_UnifFit:Level4ETA
	NVAR  Level4FitETA=root:Packages:Irena_UnifFit:Level4FitETA
	NVAR  Level4ETALowLimit =root:Packages:Irena_UnifFit:Level4ETALowLimit
	NVAR  Level4ETAHighLimit=root:Packages:Irena_UnifFit:Level4ETAHighLimit
	NVAR  Level4PACK=root:Packages:Irena_UnifFit:Level4PACK
	NVAR  Level4FitPACK=root:Packages:Irena_UnifFit:Level4FitPACK
	NVAR  Level4PACKLowLimit=root:Packages:Irena_UnifFit:Level4PACKLowLimit
	NVAR  Level4PACKHighLimit=root:Packages:Irena_UnifFit:Level4PACKHighLimit
	NVAR  Level4RgCO=root:Packages:Irena_UnifFit:Level4RgCO
	NVAR  Level4FitRgCO=root:Packages:Irena_UnifFit:Level4FitRgCO
	NVAR  Level4RgCOLowLimit=root:Packages:Irena_UnifFit:Level4RgCOLowLimit
	NVAR  Level4RgCOHighLimit=root:Packages:Irena_UnifFit:Level4RgCOHighLimit
	NVAR  Level4K=root:Packages:Irena_UnifFit:Level4K
	NVAR  Level4Corelations=root:Packages:Irena_UnifFit:Level4Corelations
	NVAR  Level4MassFractal=root:Packages:Irena_UnifFit:Level4MassFractal
	NVAR  Level4LinkRGCO=root:Packages:Irena_UnifFit:Level4LinkRGCO
//Level5 part	
	NVAR  Level5Rg=root:Packages:Irena_UnifFit:Level5Rg
	NVAR  Level5FitRg=root:Packages:Irena_UnifFit:Level5FitRg
	NVAR  Level5RgLowLimit=root:Packages:Irena_UnifFit:Level5RgLowLimit
	NVAR  Level5RgHighLimit =root:Packages:Irena_UnifFit:Level5RgHighLimit
	NVAR  Level5G=root:Packages:Irena_UnifFit:Level5G
	NVAR  Level5FitG=root:Packages:Irena_UnifFit:Level5FitG
	NVAR  Level5GLowLimit=root:Packages:Irena_UnifFit:Level5GLowLimit
	NVAR  Level5GHighLimit =root:Packages:Irena_UnifFit:Level5GHighLimit
	NVAR  Level5P=root:Packages:Irena_UnifFit:Level5P
	NVAR  Level5FitP=root:Packages:Irena_UnifFit:Level5FitP
	NVAR  Level5PLowLimit=root:Packages:Irena_UnifFit:Level5PLowLimit
	NVAR  Level5PHighLimit=root:Packages:Irena_UnifFit:Level5PHighLimit
	NVAR  Level5B=root:Packages:Irena_UnifFit:Level5B
	NVAR  Level5FitB=root:Packages:Irena_UnifFit:Level5FitB
	NVAR  Level5BLowLimit=root:Packages:Irena_UnifFit:Level5BLowLimit
	NVAR  Level5BHighLimit=root:Packages:Irena_UnifFit:Level5BHighLimit
	NVAR  Level5ETA=root:Packages:Irena_UnifFit:Level5ETA
	NVAR  Level5FitETA=root:Packages:Irena_UnifFit:Level5FitETA
	NVAR  Level5ETALowLimit =root:Packages:Irena_UnifFit:Level5ETALowLimit
	NVAR  Level5ETAHighLimit=root:Packages:Irena_UnifFit:Level5ETAHighLimit
	NVAR  Level5PACK=root:Packages:Irena_UnifFit:Level5PACK
	NVAR  Level5FitPACK=root:Packages:Irena_UnifFit:Level5FitPACK
	NVAR  Level5PACKLowLimit=root:Packages:Irena_UnifFit:Level5PACKLowLimit
	NVAR  Level5PACKHighLimit=root:Packages:Irena_UnifFit:Level5PACKHighLimit
	NVAR  Level5RgCO=root:Packages:Irena_UnifFit:Level5RgCO
	NVAR  Level5FitRgCO=root:Packages:Irena_UnifFit:Level5FitRgCO
	NVAR  Level5RgCOLowLimit=root:Packages:Irena_UnifFit:Level5RgCOLowLimit
	NVAR  Level5RgCOHighLimit=root:Packages:Irena_UnifFit:Level5RgCOHighLimit
	NVAR  Level5K=root:Packages:Irena_UnifFit:Level5K
	NVAR  Level5Corelations=root:Packages:Irena_UnifFit:Level5Corelations
	NVAR  Level5MassFractal=root:Packages:Irena_UnifFit:Level5MassFractal
	NVAR  Level5LinkRGCO=root:Packages:Irena_UnifFit:Level5LinkRGCO


	NVAR  SkipFitControlDialog=root:Packages:Irena_UnifFit:SkipFitControlDialog
	SVAR/Z AdditionalFittingConstraints
	if(!SVAR_Exists(AdditionalFittingConstraints))
		string/g AdditionalFittingConstraints
	endif


///now we can make various parts of the fitting routines...
//
	//First check the reasonability of all parameters

	IR1A_CorrectLimitsAndValues()
	if(UseNoLimits)			//this also fixes limits so user does not have to worry about them, since they are not being used for fitting anyway. 
		IR1A_FixLimits()
	endif

	//
	Make/D/N=0/O W_coef, LowLimit, HighLimit
	Make/T/N=0/O CoefNames, LowLimCoefName, HighLimCoefNames
	Make/D/O/T/N=0 T_Constraints, ParamNamesK
	T_Constraints=""
	CoefNames=""

	//the following was commnted out for unknown reason before 6/28/09 and rtherefore background could nto be fitted. 
	//fixed by JIL on this date... 
	if (FitSASBackground)		//are we fitting background?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK  //, T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SASBackground
		CoefNames[numpnts(CoefNames)-1]="SASBackground"
		LowLimit[numpnts(W_Coef)-1]=NaN
		HighLimit[numpnts(W_Coef)-1]=NaN
		LowLimCoefName[numpnts(CoefNames)-1]=""
		HighLimCoefNames[numpnts(CoefNames)-1]=""
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
	//	T_Constraints[0] = {"K"+num2str(numpnts(W_coef)-1)+" > 0"}
	endif
//Level1 part	
	if (Level1FitRg && NumberOfLevels>0)		//are we fitting distribution 1 Rg?
		if (Level1RgLowLimit > Level1Rg || Level1RgHighLimit < Level1Rg)
			abort "Level 1 Rg limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level1Rg
		LowLimit[numpnts(W_Coef)-1]=Level1RgLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level1RgHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level1Rg"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level1RgLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level1RgHighLimit)}		
	endif
	if (Level1FitG && NumberOfLevels>0)		//are we fitting distribution 1 location?
		if (Level1GLowLimit > Level1G || Level1GHighLimit < Level1G)
			abort "Level 1 G limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level1G
		LowLimit[numpnts(W_Coef)-1]=Level1GLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level1GHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level1G"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level1GLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level1GHighLimit)}		
	endif
	if (Level1FitP && NumberOfLevels>0)		//are we fitting distribution 1 location?
		if (Level1PLowLimit > Level1P || Level1PHighLimit < Level1P)
			abort "Level 1 P limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level1P
		CoefNames[numpnts(CoefNames)-1]="Level1P"
		LowLimit[numpnts(W_Coef)-1]=Level1PLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level1PHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level1PLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level1PHighLimit)}		
	endif
	if (Level1FitB && NumberOfLevels>0)		//are we fitting distribution 1 location?
		if (Level1BLowLimit > Level1B || Level1BHighLimit < Level1B)
			abort "Level 1 B limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level1B
		LowLimit[numpnts(W_Coef)-1]=Level1BLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level1BHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level1B"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level1BLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level1BHighLimit)}		
	endif
	if (Level1FitETA && Level1Corelations && NumberOfLevels>0)		//are we fitting distribution 1 location?
		if (Level1ETALowLimit > Level1ETA || Level1ETAHighLimit < Level1ETA)
			abort "Level 1 ETA limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level1ETA
		LowLimit[numpnts(W_Coef)-1]=Level1ETALowLimit
		HighLimit[numpnts(W_Coef)-1]=Level1ETAHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level1ETA"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level1ETALowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level1ETAHighLimit)}		
	endif
	if (Level1FitPACK && Level1Corelations && NumberOfLevels>0)		//are we fitting distribution 1 location?
		if (Level1PACKLowLimit > Level1PACK || Level1PACKHighLimit < Level1PACK)
			abort "Level 1 PACK limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level1PACK
		CoefNames[numpnts(CoefNames)-1]="Level1PACK"
		LowLimit[numpnts(W_Coef)-1]=Level1PACKLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level1PACKHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level1PACKLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level1PACKHighLimit)}		
	endif
	if (Level1FitRGCO && NumberOfLevels>0 && !Level1LinkRGCO)		//are we fitting distribution 1 location?
		if (Level1RGCOLowLimit > Level1RGCO || Level1RGCOHighLimit < Level1RGCO)
			abort "Level 1 RGCO limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level1RGCO
		LowLimit[numpnts(W_Coef)-1]=Level1RGCOLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level1RGCOHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level1RGCO"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level1RGCOLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level1RGCOHighLimit)}		
	endif
	
//Level2 part	
	if (Level2FitRg && NumberOfLevels>1)		//are we fitting distribution 1 volume?
		if (Level2RgLowLimit > Level2Rg || Level2RgHighLimit < Level2Rg)
			abort "Level 2 Rg limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level2Rg
		LowLimit[numpnts(W_Coef)-1]=Level2RgLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level2RgHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level2Rg"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level2RgLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level2RgHighLimit)}		
	endif
	if (Level2FitG && NumberOfLevels>1)		//are we fitting distribution 1 location?
		if (Level2GLowLimit > Level2G || Level2GHighLimit < Level2G)
			abort "Level 2 G limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level2G
		CoefNames[numpnts(CoefNames)-1]="Level2G"
		LowLimit[numpnts(W_Coef)-1]=Level2GLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level2GHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level2GLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level2GHighLimit)}		
	endif
	if (Level2FitP && NumberOfLevels>1)		//are we fitting distribution 1 location?
		if (Level2PLowLimit > Level2P || Level2PHighLimit < Level2P)
			abort "Level 2 P limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level2P
		CoefNames[numpnts(CoefNames)-1]="Level2P"
		LowLimit[numpnts(W_Coef)-1]=Level2PLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level2PHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level2PLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level2PHighLimit)}		
	endif
	if (Level2FitB && NumberOfLevels>1)		//are we fitting distribution 1 location?
		if (Level2BLowLimit > Level2B || Level2BHighLimit < Level2B)
			abort "Level 2 B limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level2B
		CoefNames[numpnts(CoefNames)-1]="Level2B"
		LowLimit[numpnts(W_Coef)-1]=Level2BLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level2BHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level2BLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level2BHighLimit)}		
	endif
	if (Level2FitETA && Level2Corelations && NumberOfLevels>1)		//are we fitting distribution 1 location?
		if (Level2ETALowLimit > Level2ETA || Level2ETAHighLimit < Level2ETA)
			abort "Level 2 ETA limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level2ETA
		LowLimit[numpnts(W_Coef)-1]=Level2ETALowLimit
		HighLimit[numpnts(W_Coef)-1]=Level2ETAHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level2ETA"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level2ETALowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level2ETAHighLimit)}		
	endif
	if (Level2FitPACK && Level2Corelations && NumberOfLevels>1)		//are we fitting distribution 1 location?
		if (Level2PACKLowLimit > Level2PACK || Level2PACKHighLimit < Level2PACK)
			abort "Level 2 PACK limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level2PACK
		CoefNames[numpnts(CoefNames)-1]="Level2PACK"
		LowLimit[numpnts(W_Coef)-1]=Level2PACKLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level2PACKHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level2PACKLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level2PACKHighLimit)}		
	endif
	if (Level2FitRGCO && NumberOfLevels>1 && !Level2LinkRGCO)		//are we fitting distribution 1 location?
		if (Level2RGCOLowLimit > Level2RgCO || Level2RgCOHighLimit < Level2RgCO)
			abort "Level 2 RgCO limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level2RGCO
		CoefNames[numpnts(CoefNames)-1]="Level2RGCO"
		LowLimit[numpnts(W_Coef)-1]=Level2RGCOLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level2RGCOHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level2RGCOLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level2RGCOHighLimit)}		
	endif
//Level3 part	
	if (Level3FitRg && NumberOfLevels>2)		//are we fitting distribution 1 volume?
		if (Level3RgLowLimit > Level3Rg || Level3RgHighLimit < Level3Rg)
			abort "Level 3 Rg limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level3Rg
		CoefNames[numpnts(CoefNames)-1]="Level3Rg"
		LowLimit[numpnts(W_Coef)-1]=Level3RgLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level3RgHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level3RgLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level3RgHighLimit)}		
	endif
	if (Level3FitG && NumberOfLevels>2)		//are we fitting distribution 1 location?
		if (Level3GLowLimit > Level3G || Level3GHighLimit < Level3G)
			abort "Level 3 G limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level3G
		LowLimit[numpnts(W_Coef)-1]=Level3GLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level3GHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level3G"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level3GLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level3GHighLimit)}		
	endif
	if (Level3FitP && NumberOfLevels>2)		//are we fitting distribution 1 location?
		if (Level3PLowLimit > Level3P || Level3PHighLimit < Level3P)
			abort "Level 3 P limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level3P
		LowLimit[numpnts(W_Coef)-1]=Level3PLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level3PHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level3P"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level3PLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level3PHighLimit)}		
	endif
	if (Level3FitB && NumberOfLevels>2)		//are we fitting distribution 1 location?
		if (Level3BLowLimit > Level3B || Level3BHighLimit < Level3B)
			abort "Level 3 B limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames , LowLimit, HighLimit, ParamNamesK
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level3B
		CoefNames[numpnts(CoefNames)-1]="Level3B"
		LowLimit[numpnts(W_Coef)-1]=Level3BLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level3BHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level3BLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level3BHighLimit)}		
	endif
	if (Level3FitETA && Level3Corelations && NumberOfLevels>2)		//are we fitting distribution 1 location?
		if (Level3ETALowLimit > Level3ETA || Level3ETAHighLimit < Level3ETA)
			abort "Level 3 ETA limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level3ETA
		CoefNames[numpnts(CoefNames)-1]="Level3ETA"
		LowLimit[numpnts(W_Coef)-1]=Level3ETALowLimit
		HighLimit[numpnts(W_Coef)-1]=Level3ETAHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level3ETALowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level3ETAHighLimit)}		
	endif
	if (Level3FitPACK && Level3Corelations && NumberOfLevels>2)		//are we fitting distribution 1 location?
		if (Level3PACKLowLimit > Level3PACK || Level3PACKHighLimit < Level3PACK)
			abort "Level 3 PACK limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level3PACK
		CoefNames[numpnts(CoefNames)-1]="Level3PACK"
		LowLimit[numpnts(W_Coef)-1]=Level3PACKLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level3PACKHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level3PACKLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level3PACKHighLimit)}		
	endif
	if (Level3FitRGCO && NumberOfLevels>2 && !Level3LinkRGCO)		//are we fitting distribution 1 location?
		if (Level3RGCOLowLimit > Level3RgCO || Level3RgCOHighLimit < Level3RgCO)
			abort "Level 3 RgCO limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level3RGCO
		LowLimit[numpnts(W_Coef)-1]=Level3RGCOLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level3RGCOHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level3RGCO"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level3RGCOLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level3RGCOHighLimit)}		
	endif
//Level4 part	
	if (Level4FitRg && NumberOfLevels>3)		//are we fitting distribution 1 volume?
		if (Level4RgLowLimit > Level4Rg || Level4RgHighLimit < Level4Rg)
			abort "Level 4Rg limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level4Rg
		CoefNames[numpnts(CoefNames)-1]="Level4Rg"
		LowLimit[numpnts(W_Coef)-1]=Level4RgLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level4RgHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level4RgLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level4RgHighLimit)}		
	endif
	if (Level4FitG && NumberOfLevels>3)		//are we fitting distribution 1 location?
		if (Level4GLowLimit > Level4G || Level4GHighLimit < Level4G)
			abort "Level 4 G limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level4G
		CoefNames[numpnts(CoefNames)-1]="Level4G"
		LowLimit[numpnts(W_Coef)-1]=Level4GLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level4GHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level4GLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level4GHighLimit)}		
	endif
	if (Level4FitP && NumberOfLevels>3)		//are we fitting distribution 1 location?
		if (Level4PLowLimit > Level4P || Level4PHighLimit < Level4P)
			abort "Level 4 P limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level4P
		LowLimit[numpnts(W_Coef)-1]=Level4PLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level4PHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level4P"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level4PLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level4PHighLimit)}		
	endif
	if (Level4FitB && NumberOfLevels>3)		//are we fitting distribution 1 location?
		if (Level4BLowLimit > Level4B || Level4BHighLimit < Level4B)
			abort "Level 4 B limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level4B
		LowLimit[numpnts(W_Coef)-1]=Level4BLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level4BHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level4B"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level4BLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level4BHighLimit)}		
	endif
	if (Level4FitETA && Level4Corelations && NumberOfLevels>3)		//are we fitting distribution 1 location?
		if (Level4ETALowLimit > Level4ETA || Level4ETAHighLimit < Level4ETA)
			abort "Level 4 ETA limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level4ETA
		LowLimit[numpnts(W_Coef)-1]=Level4ETALowLimit
		HighLimit[numpnts(W_Coef)-1]=Level4ETAHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level4ETA"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level4ETALowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level4ETAHighLimit)}		
	endif
	if (Level4FitPACK && Level4Corelations && NumberOfLevels>3)		//are we fitting distribution 1 location?
		if (Level4PACKLowLimit > Level4PACK || Level4PACKHighLimit < Level4PACK)
			abort "Level 4 PACK limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level4PACK
		LowLimit[numpnts(W_Coef)-1]=Level4PACKLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level4PACKHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level4PACK"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level4PACKLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level4PACKHighLimit)}		
	endif
	if (Level4FitRGCO && NumberOfLevels>3 && !Level4LinkRGCO)		//are we fitting distribution 1 location?
		if (Level4RGCOLowLimit > Level4RgCO || Level4RgCOHighLimit < Level4RgCO)
			abort "Level 4 RgCO limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames , LowLimit, HighLimit, ParamNamesK
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level4RGCO
		LowLimit[numpnts(W_Coef)-1]=Level4RGCOLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level4RGCOHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level4RGCO"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level4RGCOLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level4RGCOHighLimit)}		
	endif
//Level5 part	
	if (Level5FitRg && NumberOfLevels>4)		//are we fitting distribution 1 volume?
		if (Level5RgLowLimit > Level5Rg || Level5RgHighLimit < Level5Rg)
			abort "Level 5 Rg limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level5Rg
		LowLimit[numpnts(W_Coef)-1]=Level5RgLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level5RgHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level5Rg"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level5RgLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level5RgHighLimit)}		
	endif
	if (Level5FitG && NumberOfLevels>4)		//are we fitting distribution 1 location?
		if (Level5GLowLimit > Level5G || Level5GHighLimit < Level5G)
			abort "Level 5 G limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level5G
		CoefNames[numpnts(CoefNames)-1]="Level5G"
		LowLimit[numpnts(W_Coef)-1]=Level5GLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level5GHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level5GLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level5GHighLimit)}		
	endif
	if (Level5FitP && NumberOfLevels>4)		//are we fitting distribution 1 location?
		if (Level5PLowLimit > Level5P || Level5PHighLimit < Level5P)
			abort "Level 5 P limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level5P
		LowLimit[numpnts(W_Coef)-1]=Level5PLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level5PHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level5P"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level5PLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level5PHighLimit)}		
	endif
	if (Level5FitB && NumberOfLevels>4)		//are we fitting distribution 1 location?
		if (Level5BLowLimit > Level5B || Level5BHighLimit < Level5B)
			abort "Level 5 B limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level5B
		LowLimit[numpnts(W_Coef)-1]=Level5BLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level5BHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level5B"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level5BLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level5BHighLimit)}		
	endif
	if (Level5FitETA && Level5Corelations && NumberOfLevels>4)		//are we fitting distribution 1 location?
		if (Level5ETALowLimit > Level5ETA || Level5ETAHighLimit < Level5ETA)
			abort "Level 5 ETA limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level5ETA
		LowLimit[numpnts(W_Coef)-1]=Level5ETALowLimit
		HighLimit[numpnts(W_Coef)-1]=Level5ETAHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level5ETA"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level5ETALowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level5ETAHighLimit)}		
	endif
	if (Level5FitPACK && Level5Corelations && NumberOfLevels>4)		//are we fitting distribution 1 location?
		if (Level5PACKLowLimit > Level5PACK || Level5PACKHighLimit < Level5PACK)
			abort "Level 5 PACK limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames , LowLimit, HighLimit, ParamNamesK
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level5PACK
		CoefNames[numpnts(CoefNames)-1]="Level5PACK"
		LowLimit[numpnts(W_Coef)-1]=Level5PACKLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level5PACKHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level5PACKLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level5PACKHighLimit)}		
	endif
	if (Level5FitRGCO && NumberOfLevels>4 && !Level5LinkRGCO)		//are we fitting distribution 1 location?
		if (Level5RGCOLowLimit > Level5RgCO || Level5RgCOHighLimit < Level5RgCO)
			abort "Level 5 RgCO limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level5RGCO
		CoefNames[numpnts(CoefNames)-1]="Level5RGCO"
		LowLimit[numpnts(W_Coef)-1]=Level5RGCOLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level5RGCOHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level5RGCOLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level5RGCOHighLimit)}		
	endif
				

	//Now let's check if we have what to fit at all...
	if (numpnts(CoefNames)==0)
		beep
		Abort "Select parameters to fit and set their fitting limits"
	endif
	IR1A_SetErrorsToZero()
	
	DoWindow /F IR1_LogLogPlotU
	Wave OriginalQvector
	Wave OriginalIntensity
	Wave OriginalError	

	if(!SkipFitControlDialog)
		IR1A_CheckFittingParamsFnct()
		PauseForUser IR1A_CheckFittingParams

		NVAR UserCanceled=root:Packages:Irena_UnifFit:UserCanceled
		if (UserCanceled)
			setDataFolder OldDf
			abort
		endif
	endif

	//add more constraints, is user added them or if thy already are in AdditionalFittingConstraints
	if(strlen(AdditionalFittingConstraints)>3)
		AdditionalFittingConstraints = RemoveEnding(AdditionalFittingConstraints , ";")+";"
	else
		AdditionalFittingConstraints=""
	endif
	variable NumOfAddOnConstr=ItemsInList(AdditionalFittingConstraints,";")
	if(NumOfAddOnConstr>0)		//there are some
		print "Added following fitting constraints : "+AdditionalFittingConstraints
		variable oldConstNum=numpnts(T_Constraints)
		redimension/N=(oldConstNum+NumOfAddOnConstr) T_Constraints
		variable ij
		for (ij=0;ij<NumOfAddOnConstr;ij+=1)
			T_Constraints[oldConstNum+ij] = StringFromList(ij, AdditionalFittingConstraints, ";")
		endfor	
	endif


	
	Variable V_chisq
	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave=W_coef/100

	IR1A_RecordResults("before")

	Variable V_FitError=0			//This should prevent errors from being generated
		variable NumParams=numpnts(CoefNames)
		string ParamName, ParamName1, ListOfLimitsReachedParams
		ListOfLimitsReachedParams=""
		variable i, LimitsReached
	
	//and now the fit...
	if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalIntensity, FitIntensityWave		
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalQvector, FitQvectorWave
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalError, FitErrorWave
		if(UseNoLimits)	
			FuncFit /N/Q IR1A_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /D 
		else
			FuncFit /N/Q IR1A_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /D /C=T_Constraints 
		endif
	else
		Duplicate/O OriginalIntensity, FitIntensityWave		
		Duplicate/O OriginalQvector, FitQvectorWave
		Duplicate/O OriginalError, FitErrorWave
		if(UseNoLimits)	
			FuncFit /N/Q IR1A_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D	
		else	
			FuncFit /N/Q IR1A_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D /C=T_Constraints	
		endif
	endif
	if (V_FitError!=0)	//there was error in fitting
		NVAR/Z FitFailed = root:Packages:Irena_UnifFit:FitFailed
		if (NVAR_Exists(FitFailed))
			FitFailed=1
		endif
		IR1A_ResetParamsAfterBadFit()
		if(skipreset==0)
			beep
			Abort "Fitting error, check starting parameters and fitting limits" 
		endif
	else		//results OK, make sure the resulting values are set 
		For(i=0;i<NumParams;i+=1)
			ParamName = CoefNames[i]
			NVAR TempVar = $(ParamName)
			ParamName1 = LowLimCoefName[i]
			NVAR/Z TempVarLL=$(ParamName1)
			ParamName1 = HighLimCoefNames[i]
			NVAR/Z TempVarHL=$(ParamName1)
			TempVar=W_Coef[i]
			if(NVAR_Exists(TempVarLL) && NVAR_Exists(TempVarHL))
				if(abs(TempVarLL-TempVar)/TempVar <0.02)
					LimitsReached = 1
					ListOfLimitsReachedParams+=ParamName+";"
				endif
				if(abs(TempVarHL-TempVar)/TempVar <0.02)
					LimitsReached = 1
					ListOfLimitsReachedParams+=ParamName+";"
				endif
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
	
	IR1A_UpdateMassFractCalc()
	
	variable/g AchievedChisq=V_chisq
	IR1A_RecordErrorsAfterFit()
	IR1A_GraphModelData()
	IR1A_RecordResults("after")
	
	DoWIndow/F IR1A_ControlPanel
	IR1A_FixTabsInPanel()
	
	KillWaves/Z T_Constraints, E_wave
	
	setDataFolder OldDF
end

//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************

Function IR1A_RecordErrorsAfterFit()

	setDataFolder root:Packages:Irena_UnifFit
	
	Wave W_sigma=root:Packages:Irena_UnifFit:W_sigma
	Wave/T CoefNames=root:Packages:Irena_UnifFit:CoefNames
	
	variable i
	For(i=0;i<numpnts(CoefNames);i+=1)
		NVAR InsertErrorHere=$(CoefNames[i]+"Error")
		InsertErrorHere=W_sigma[i]
	endfor
	
end

//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************

Function IR1A_ResetParamsAfterBadFit()
	
	Wave w=root:Packages:Irena_UnifFit:CoefficientInput
	Wave/T CoefNames=root:Packages:Irena_UnifFit:CoefNames		//text wave with names of parameters

	if ((!WaveExists(w)) || (!WaveExists(CoefNames)))
		Beep
		abort "Record of old parameters does not exist, this is BUG, please report it..."
	endif

	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR FitSASBackground=root:Packages:Irena_UnifFit:FitSASBackground

//Level1 part	
	NVAR  Level1Rg=root:Packages:Irena_UnifFit:Level1Rg
	NVAR  Level1FitRg=root:Packages:Irena_UnifFit:Level1FitRg
	NVAR  Level1RgLowLimit=root:Packages:Irena_UnifFit:Level1RgLowLimit
	NVAR  Level1RgHighLimit =root:Packages:Irena_UnifFit:Level1RgHighLimit
	NVAR  Level1G=root:Packages:Irena_UnifFit:Level1G
	NVAR  Level1FitG=root:Packages:Irena_UnifFit:Level1FitG
	NVAR  Level1GLowLimit=root:Packages:Irena_UnifFit:Level1GLowLimit
	NVAR  Level1GHighLimit =root:Packages:Irena_UnifFit:Level1GHighLimit
	NVAR  Level1P=root:Packages:Irena_UnifFit:Level1P
	NVAR  Level1FitP=root:Packages:Irena_UnifFit:Level1FitP
	NVAR  Level1PLowLimit=root:Packages:Irena_UnifFit:Level1PLowLimit
	NVAR  Level1PHighLimit=root:Packages:Irena_UnifFit:Level1PHighLimit
	NVAR  Level1B=root:Packages:Irena_UnifFit:Level1B
	NVAR  Level1FitB=root:Packages:Irena_UnifFit:Level1FitB
	NVAR  Level1BLowLimit=root:Packages:Irena_UnifFit:Level1BLowLimit
	NVAR  Level1BHighLimit=root:Packages:Irena_UnifFit:Level1BHighLimit
	NVAR  Level1ETA=root:Packages:Irena_UnifFit:Level1ETA
	NVAR  Level1FitETA=root:Packages:Irena_UnifFit:Level1FitETA
	NVAR  Level1ETALowLimit =root:Packages:Irena_UnifFit:Level1ETALowLimit
	NVAR  Level1ETAHighLimit=root:Packages:Irena_UnifFit:Level1ETAHighLimit
	NVAR  Level1PACK=root:Packages:Irena_UnifFit:Level1PACK
	NVAR  Level1FitPACK=root:Packages:Irena_UnifFit:Level1FitPACK
	NVAR  Level1PACKLowLimit=root:Packages:Irena_UnifFit:Level1PACKLowLimit
	NVAR  Level1PACKHighLimit=root:Packages:Irena_UnifFit:Level1PACKHighLimit
	NVAR  Level1RgCO=root:Packages:Irena_UnifFit:Level1RgCO
	NVAR  Level1FitRgCO=root:Packages:Irena_UnifFit:Level1FitRgCO
	NVAR  Level1RgCOLowLimit=root:Packages:Irena_UnifFit:Level1RgCOLowLimit
	NVAR  Level1RgCOHighLimit=root:Packages:Irena_UnifFit:Level1RgCOHighLimit
	NVAR  Level1K=root:Packages:Irena_UnifFit:Level1K
	NVAR  Level1Corelations=root:Packages:Irena_UnifFit:Level1Corelations
	NVAR  Level1MassFractal=root:Packages:Irena_UnifFit:Level1MassFractal
//Level2 part	
	NVAR  Level2Rg=root:Packages:Irena_UnifFit:Level2Rg
	NVAR  Level2FitRg=root:Packages:Irena_UnifFit:Level2FitRg
	NVAR  Level2RgLowLimit=root:Packages:Irena_UnifFit:Level2RgLowLimit
	NVAR  Level2RgHighLimit =root:Packages:Irena_UnifFit:Level2RgHighLimit
	NVAR  Level2G=root:Packages:Irena_UnifFit:Level2G
	NVAR  Level2FitG=root:Packages:Irena_UnifFit:Level2FitG
	NVAR  Level2GLowLimit=root:Packages:Irena_UnifFit:Level2GLowLimit
	NVAR  Level2GHighLimit =root:Packages:Irena_UnifFit:Level2GHighLimit
	NVAR  Level2P=root:Packages:Irena_UnifFit:Level2P
	NVAR  Level2FitP=root:Packages:Irena_UnifFit:Level2FitP
	NVAR  Level2PLowLimit=root:Packages:Irena_UnifFit:Level2PLowLimit
	NVAR  Level2PHighLimit=root:Packages:Irena_UnifFit:Level2PHighLimit
	NVAR  Level2B=root:Packages:Irena_UnifFit:Level2B
	NVAR  Level2FitB=root:Packages:Irena_UnifFit:Level2FitB
	NVAR  Level2BLowLimit=root:Packages:Irena_UnifFit:Level2BLowLimit
	NVAR  Level2BHighLimit=root:Packages:Irena_UnifFit:Level2BHighLimit
	NVAR  Level2ETA=root:Packages:Irena_UnifFit:Level2ETA
	NVAR  Level2FitETA=root:Packages:Irena_UnifFit:Level2FitETA
	NVAR  Level2ETALowLimit =root:Packages:Irena_UnifFit:Level2ETALowLimit
	NVAR  Level2ETAHighLimit=root:Packages:Irena_UnifFit:Level2ETAHighLimit
	NVAR  Level2PACK=root:Packages:Irena_UnifFit:Level2PACK
	NVAR  Level2FitPACK=root:Packages:Irena_UnifFit:Level2FitPACK
	NVAR  Level2PACKLowLimit=root:Packages:Irena_UnifFit:Level2PACKLowLimit
	NVAR  Level2PACKHighLimit=root:Packages:Irena_UnifFit:Level2PACKHighLimit
	NVAR  Level2RgCO=root:Packages:Irena_UnifFit:Level2RgCO
	NVAR  Level2FitRgCO=root:Packages:Irena_UnifFit:Level2FitRgCO
	NVAR  Level2RgCOLowLimit=root:Packages:Irena_UnifFit:Level2RgCOLowLimit
	NVAR  Level2RgCOHighLimit=root:Packages:Irena_UnifFit:Level2RgCOHighLimit
	NVAR  Level2K=root:Packages:Irena_UnifFit:Level2K
	NVAR  Level2Corelations=root:Packages:Irena_UnifFit:Level2Corelations
	NVAR  Level2MassFractal=root:Packages:Irena_UnifFit:Level2MassFractal
//Level3 part	
	NVAR  Level3Rg=root:Packages:Irena_UnifFit:Level3Rg
	NVAR  Level3FitRg=root:Packages:Irena_UnifFit:Level3FitRg
	NVAR  Level3RgLowLimit=root:Packages:Irena_UnifFit:Level3RgLowLimit
	NVAR  Level3RgHighLimit =root:Packages:Irena_UnifFit:Level3RgHighLimit
	NVAR  Level3G=root:Packages:Irena_UnifFit:Level3G
	NVAR  Level3FitG=root:Packages:Irena_UnifFit:Level3FitG
	NVAR  Level3GLowLimit=root:Packages:Irena_UnifFit:Level3GLowLimit
	NVAR  Level3GHighLimit =root:Packages:Irena_UnifFit:Level3GHighLimit
	NVAR  Level3P=root:Packages:Irena_UnifFit:Level3P
	NVAR  Level3FitP=root:Packages:Irena_UnifFit:Level3FitP
	NVAR  Level3PLowLimit=root:Packages:Irena_UnifFit:Level3PLowLimit
	NVAR  Level3PHighLimit=root:Packages:Irena_UnifFit:Level3PHighLimit
	NVAR  Level3B=root:Packages:Irena_UnifFit:Level3B
	NVAR  Level3FitB=root:Packages:Irena_UnifFit:Level3FitB
	NVAR  Level3BLowLimit=root:Packages:Irena_UnifFit:Level3BLowLimit
	NVAR  Level3BHighLimit=root:Packages:Irena_UnifFit:Level3BHighLimit
	NVAR  Level3ETA=root:Packages:Irena_UnifFit:Level3ETA
	NVAR  Level3FitETA=root:Packages:Irena_UnifFit:Level3FitETA
	NVAR  Level3ETALowLimit =root:Packages:Irena_UnifFit:Level3ETALowLimit
	NVAR  Level3ETAHighLimit=root:Packages:Irena_UnifFit:Level3ETAHighLimit
	NVAR  Level3PACK=root:Packages:Irena_UnifFit:Level3PACK
	NVAR  Level3FitPACK=root:Packages:Irena_UnifFit:Level3FitPACK
	NVAR  Level3PACKLowLimit=root:Packages:Irena_UnifFit:Level3PACKLowLimit
	NVAR  Level3PACKHighLimit=root:Packages:Irena_UnifFit:Level3PACKHighLimit
	NVAR  Level3RgCO=root:Packages:Irena_UnifFit:Level3RgCO
	NVAR  Level3FitRgCO=root:Packages:Irena_UnifFit:Level3FitRgCO
	NVAR  Level3RgCOLowLimit=root:Packages:Irena_UnifFit:Level3RgCOLowLimit
	NVAR  Level3RgCOHighLimit=root:Packages:Irena_UnifFit:Level3RgCOHighLimit
	NVAR  Level3K=root:Packages:Irena_UnifFit:Level3K
	NVAR  Level3Corelations=root:Packages:Irena_UnifFit:Level3Corelations
	NVAR  Level3MassFractal=root:Packages:Irena_UnifFit:Level3MassFractal
//Level4 part	
	NVAR  Level4Rg=root:Packages:Irena_UnifFit:Level4Rg
	NVAR  Level4FitRg=root:Packages:Irena_UnifFit:Level4FitRg
	NVAR  Level4RgLowLimit=root:Packages:Irena_UnifFit:Level4RgLowLimit
	NVAR  Level4RgHighLimit =root:Packages:Irena_UnifFit:Level4RgHighLimit
	NVAR  Level4G=root:Packages:Irena_UnifFit:Level4G
	NVAR  Level4FitG=root:Packages:Irena_UnifFit:Level4FitG
	NVAR  Level4GLowLimit=root:Packages:Irena_UnifFit:Level4GLowLimit
	NVAR  Level4GHighLimit =root:Packages:Irena_UnifFit:Level4GHighLimit
	NVAR  Level4P=root:Packages:Irena_UnifFit:Level4P
	NVAR  Level4FitP=root:Packages:Irena_UnifFit:Level4FitP
	NVAR  Level4PLowLimit=root:Packages:Irena_UnifFit:Level4PLowLimit
	NVAR  Level4PHighLimit=root:Packages:Irena_UnifFit:Level4PHighLimit
	NVAR  Level4B=root:Packages:Irena_UnifFit:Level4B
	NVAR  Level4FitB=root:Packages:Irena_UnifFit:Level4FitB
	NVAR  Level4BLowLimit=root:Packages:Irena_UnifFit:Level4BLowLimit
	NVAR  Level4BHighLimit=root:Packages:Irena_UnifFit:Level4BHighLimit
	NVAR  Level4ETA=root:Packages:Irena_UnifFit:Level4ETA
	NVAR  Level4FitETA=root:Packages:Irena_UnifFit:Level4FitETA
	NVAR  Level4ETALowLimit =root:Packages:Irena_UnifFit:Level4ETALowLimit
	NVAR  Level4ETAHighLimit=root:Packages:Irena_UnifFit:Level4ETAHighLimit
	NVAR  Level4PACK=root:Packages:Irena_UnifFit:Level4PACK
	NVAR  Level4FitPACK=root:Packages:Irena_UnifFit:Level4FitPACK
	NVAR  Level4PACKLowLimit=root:Packages:Irena_UnifFit:Level4PACKLowLimit
	NVAR  Level4PACKHighLimit=root:Packages:Irena_UnifFit:Level4PACKHighLimit
	NVAR  Level4RgCO=root:Packages:Irena_UnifFit:Level4RgCO
	NVAR  Level4FitRgCO=root:Packages:Irena_UnifFit:Level4FitRgCO
	NVAR  Level4RgCOLowLimit=root:Packages:Irena_UnifFit:Level4RgCOLowLimit
	NVAR  Level4RgCOHighLimit=root:Packages:Irena_UnifFit:Level4RgCOHighLimit
	NVAR  Level4K=root:Packages:Irena_UnifFit:Level4K
	NVAR  Level4Corelations=root:Packages:Irena_UnifFit:Level4Corelations
	NVAR  Level4MassFractal=root:Packages:Irena_UnifFit:Level4MassFractal
//Level5 part	
	NVAR  Level5Rg=root:Packages:Irena_UnifFit:Level5Rg
	NVAR  Level5FitRg=root:Packages:Irena_UnifFit:Level5FitRg
	NVAR  Level5RgLowLimit=root:Packages:Irena_UnifFit:Level5RgLowLimit
	NVAR  Level5RgHighLimit =root:Packages:Irena_UnifFit:Level5RgHighLimit
	NVAR  Level5G=root:Packages:Irena_UnifFit:Level5G
	NVAR  Level5FitG=root:Packages:Irena_UnifFit:Level5FitG
	NVAR  Level5GLowLimit=root:Packages:Irena_UnifFit:Level5GLowLimit
	NVAR  Level5GHighLimit =root:Packages:Irena_UnifFit:Level5GHighLimit
	NVAR  Level5P=root:Packages:Irena_UnifFit:Level5P
	NVAR  Level5FitP=root:Packages:Irena_UnifFit:Level5FitP
	NVAR  Level5PLowLimit=root:Packages:Irena_UnifFit:Level5PLowLimit
	NVAR  Level5PHighLimit=root:Packages:Irena_UnifFit:Level5PHighLimit
	NVAR  Level5B=root:Packages:Irena_UnifFit:Level5B
	NVAR  Level5FitB=root:Packages:Irena_UnifFit:Level5FitB
	NVAR  Level5BLowLimit=root:Packages:Irena_UnifFit:Level5BLowLimit
	NVAR  Level5BHighLimit=root:Packages:Irena_UnifFit:Level5BHighLimit
	NVAR  Level5ETA=root:Packages:Irena_UnifFit:Level5ETA
	NVAR  Level5FitETA=root:Packages:Irena_UnifFit:Level5FitETA
	NVAR  Level5ETALowLimit =root:Packages:Irena_UnifFit:Level5ETALowLimit
	NVAR  Level5ETAHighLimit=root:Packages:Irena_UnifFit:Level5ETAHighLimit
	NVAR  Level5PACK=root:Packages:Irena_UnifFit:Level5PACK
	NVAR  Level5FitPACK=root:Packages:Irena_UnifFit:Level5FitPACK
	NVAR  Level5PACKLowLimit=root:Packages:Irena_UnifFit:Level5PACKLowLimit
	NVAR  Level5PACKHighLimit=root:Packages:Irena_UnifFit:Level5PACKHighLimit
	NVAR  Level5RgCO=root:Packages:Irena_UnifFit:Level5RgCO
	NVAR  Level5FitRgCO=root:Packages:Irena_UnifFit:Level5FitRgCO
	NVAR  Level5RgCOLowLimit=root:Packages:Irena_UnifFit:Level5RgCOLowLimit
	NVAR  Level5RgCOHighLimit=root:Packages:Irena_UnifFit:Level5RgCOHighLimit
	NVAR  Level5K=root:Packages:Irena_UnifFit:Level5K
	NVAR  Level5Corelations=root:Packages:Irena_UnifFit:Level5Corelations
	NVAR  Level5MassFractal=root:Packages:Irena_UnifFit:Level5MassFractal
//
	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	string ParamName=""
	
	for (i=0;i<NumOfParam;i+=1)
		ParamName=CoefNames[i]
	
		if(cmpstr(ParamName,"SASBackground")==0)
			SASBackground=w[i]
		endif

		if(cmpstr(ParamName,"Level1Rg")==0)
			Level1Rg=w[i]
		endif
		if(cmpstr(ParamName,"Level1G")==0)
			Level1G=w[i]
		endif
		if(cmpstr(ParamName,"Level1P")==0)
			Level1P=w[i]
		endif
		if(cmpstr(ParamName,"Level1B")==0)
			Level1B=w[i]
		endif
		if(cmpstr(ParamName,"Level1ETA")==0)
			Level1ETA=w[i]
		endif
		if(cmpstr(ParamName,"Level1PACK")==0)
			Level1PACK=w[i]
		endif
		if(cmpstr(ParamName,"Level1RGCO")==0)
			Level1RGCO=w[i]
		endif
		if(cmpstr(ParamName,"Level1K")==0)
			Level1K=w[i]
		endif
		if(cmpstr(ParamName,"Level2Rg")==0)
			Level2Rg=w[i]
		endif
		if(cmpstr(ParamName,"Level2G")==0)
			Level2G=w[i]
		endif
		if(cmpstr(ParamName,"Level2P")==0)
			Level2P=w[i]
		endif
		if(cmpstr(ParamName,"Level2B")==0)
			Level2B=w[i]
		endif
		if(cmpstr(ParamName,"Level2ETA")==0)
			Level2ETA=w[i]
		endif
		if(cmpstr(ParamName,"Level2PACK")==0)
			Level2PACK=w[i]
		endif
		if(cmpstr(ParamName,"Level2RGCO")==0)
			Level2RGCO=w[i]
		endif
		if(cmpstr(ParamName,"Level2K")==0)
			Level2K=w[i]
		endif
		if(cmpstr(ParamName,"Level3Rg")==0)
			Level3Rg=w[i]
		endif
		if(cmpstr(ParamName,"Level3G")==0)
			Level3G=w[i]
		endif
		if(cmpstr(ParamName,"Level3P")==0)
			Level3P=w[i]
		endif
		if(cmpstr(ParamName,"Level3B")==0)
			Level3B=w[i]
		endif
		if(cmpstr(ParamName,"Level3ETA")==0)
			Level3ETA=w[i]
		endif
		if(cmpstr(ParamName,"Level3PACK")==0)
			Level3PACK=w[i]
		endif
		if(cmpstr(ParamName,"Level3RGCO")==0)
			Level3RGCO=w[i]
		endif
		if(cmpstr(ParamName,"Level3K")==0)
			Level3K=w[i]
		endif
		if(cmpstr(ParamName,"Level4Rg")==0)
			Level4Rg=w[i]
		endif
		if(cmpstr(ParamName,"Level4G")==0)
			Level4G=w[i]
		endif
		if(cmpstr(ParamName,"Level4P")==0)
			Level4P=w[i]
		endif
		if(cmpstr(ParamName,"Level4B")==0)
			Level4B=w[i]
		endif
		if(cmpstr(ParamName,"Level4ETA")==0)
			Level4ETA=w[i]
		endif
		if(cmpstr(ParamName,"Level4PACK")==0)
			Level4PACK=w[i]
		endif
		if(cmpstr(ParamName,"Level4RGCO")==0)
			Level4RGCO=w[i]
		endif
		if(cmpstr(ParamName,"Level4K")==0)
			Level4K=w[i]
		endif
		if(cmpstr(ParamName,"Level5Rg")==0)
			Level5Rg=w[i]
		endif
		if(cmpstr(ParamName,"Level5G")==0)
			Level5G=w[i]
		endif
		if(cmpstr(ParamName,"Level5P")==0)
			Level5P=w[i]
		endif
		if(cmpstr(ParamName,"Level5B")==0)
			Level5B=w[i]
		endif
		if(cmpstr(ParamName,"Level5ETA")==0)
			Level5ETA=w[i]
		endif
		if(cmpstr(ParamName,"Level5PACK")==0)
			Level5PACK=w[i]
		endif
		if(cmpstr(ParamName,"Level5RGCO")==0)
			Level5RGCO=w[i]
		endif
		if(cmpstr(ParamName,"Level5K")==0)
			Level5K=w[i]
		endif
	endfor
	DoWIndow/F IR1A_ControlPanel
	IR1A_FixTabsInPanel()

end

//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************


Function IR1A_FitFunction(w,yw,xw) : FitFunc
	Wave w,yw,xw
	
	//here the w contains the parameters, yw will be the result and xw is the input
	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(q) = very complex calculations, forget about formula
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1 - the q vector...
	//CurveFitDialog/ q

	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR FitSASBackground=root:Packages:Irena_UnifFit:FitSASBackground
//Level1 part	
	NVAR  Level1Rg=root:Packages:Irena_UnifFit:Level1Rg
	NVAR  Level1FitRg=root:Packages:Irena_UnifFit:Level1FitRg
	NVAR  Level1RgLowLimit=root:Packages:Irena_UnifFit:Level1RgLowLimit
	NVAR  Level1RgHighLimit =root:Packages:Irena_UnifFit:Level1RgHighLimit
	NVAR  Level1G=root:Packages:Irena_UnifFit:Level1G
	NVAR  Level1FitG=root:Packages:Irena_UnifFit:Level1FitG
	NVAR  Level1GLowLimit=root:Packages:Irena_UnifFit:Level1GLowLimit
	NVAR  Level1GHighLimit =root:Packages:Irena_UnifFit:Level1GHighLimit
	NVAR  Level1P=root:Packages:Irena_UnifFit:Level1P
	NVAR  Level1FitP=root:Packages:Irena_UnifFit:Level1FitP
	NVAR  Level1PLowLimit=root:Packages:Irena_UnifFit:Level1PLowLimit
	NVAR  Level1PHighLimit=root:Packages:Irena_UnifFit:Level1PHighLimit
	NVAR  Level1B=root:Packages:Irena_UnifFit:Level1B
	NVAR  Level1FitB=root:Packages:Irena_UnifFit:Level1FitB
	NVAR  Level1BLowLimit=root:Packages:Irena_UnifFit:Level1BLowLimit
	NVAR  Level1BHighLimit=root:Packages:Irena_UnifFit:Level1BHighLimit
	NVAR  Level1ETA=root:Packages:Irena_UnifFit:Level1ETA
	NVAR  Level1FitETA=root:Packages:Irena_UnifFit:Level1FitETA
	NVAR  Level1ETALowLimit =root:Packages:Irena_UnifFit:Level1ETALowLimit
	NVAR  Level1ETAHighLimit=root:Packages:Irena_UnifFit:Level1ETAHighLimit
	NVAR  Level1PACK=root:Packages:Irena_UnifFit:Level1PACK
	NVAR  Level1FitPACK=root:Packages:Irena_UnifFit:Level1FitPACK
	NVAR  Level1PACKLowLimit=root:Packages:Irena_UnifFit:Level1PACKLowLimit
	NVAR  Level1PACKHighLimit=root:Packages:Irena_UnifFit:Level1PACKHighLimit
	NVAR  Level1RgCO=root:Packages:Irena_UnifFit:Level1RgCO
	NVAR  Level1FitRgCO=root:Packages:Irena_UnifFit:Level1FitRgCO
	NVAR  Level1RgCOLowLimit=root:Packages:Irena_UnifFit:Level1RgCOLowLimit
	NVAR  Level1RgCOHighLimit=root:Packages:Irena_UnifFit:Level1RgCOHighLimit
	NVAR  Level1K=root:Packages:Irena_UnifFit:Level1K
	NVAR  Level1Corelations=root:Packages:Irena_UnifFit:Level1Corelations
	NVAR  Level1MassFractal=root:Packages:Irena_UnifFit:Level1MassFractal
//Level2 part	
	NVAR  Level2Rg=root:Packages:Irena_UnifFit:Level2Rg
	NVAR  Level2FitRg=root:Packages:Irena_UnifFit:Level2FitRg
	NVAR  Level2RgLowLimit=root:Packages:Irena_UnifFit:Level2RgLowLimit
	NVAR  Level2RgHighLimit =root:Packages:Irena_UnifFit:Level2RgHighLimit
	NVAR  Level2G=root:Packages:Irena_UnifFit:Level2G
	NVAR  Level2FitG=root:Packages:Irena_UnifFit:Level2FitG
	NVAR  Level2GLowLimit=root:Packages:Irena_UnifFit:Level2GLowLimit
	NVAR  Level2GHighLimit =root:Packages:Irena_UnifFit:Level2GHighLimit
	NVAR  Level2P=root:Packages:Irena_UnifFit:Level2P
	NVAR  Level2FitP=root:Packages:Irena_UnifFit:Level2FitP
	NVAR  Level2PLowLimit=root:Packages:Irena_UnifFit:Level2PLowLimit
	NVAR  Level2PHighLimit=root:Packages:Irena_UnifFit:Level2PHighLimit
	NVAR  Level2B=root:Packages:Irena_UnifFit:Level2B
	NVAR  Level2FitB=root:Packages:Irena_UnifFit:Level2FitB
	NVAR  Level2BLowLimit=root:Packages:Irena_UnifFit:Level2BLowLimit
	NVAR  Level2BHighLimit=root:Packages:Irena_UnifFit:Level2BHighLimit
	NVAR  Level2ETA=root:Packages:Irena_UnifFit:Level2ETA
	NVAR  Level2FitETA=root:Packages:Irena_UnifFit:Level2FitETA
	NVAR  Level2ETALowLimit =root:Packages:Irena_UnifFit:Level2ETALowLimit
	NVAR  Level2ETAHighLimit=root:Packages:Irena_UnifFit:Level2ETAHighLimit
	NVAR  Level2PACK=root:Packages:Irena_UnifFit:Level2PACK
	NVAR  Level2FitPACK=root:Packages:Irena_UnifFit:Level2FitPACK
	NVAR  Level2PACKLowLimit=root:Packages:Irena_UnifFit:Level2PACKLowLimit
	NVAR  Level2PACKHighLimit=root:Packages:Irena_UnifFit:Level2PACKHighLimit
	NVAR  Level2RgCO=root:Packages:Irena_UnifFit:Level2RgCO
	NVAR  Level2FitRgCO=root:Packages:Irena_UnifFit:Level2FitRgCO
	NVAR  Level2RgCOLowLimit=root:Packages:Irena_UnifFit:Level2RgCOLowLimit
	NVAR  Level2RgCOHighLimit=root:Packages:Irena_UnifFit:Level2RgCOHighLimit
	NVAR  Level2K=root:Packages:Irena_UnifFit:Level2K
	NVAR  Level2Corelations=root:Packages:Irena_UnifFit:Level2Corelations
	NVAR  Level2MassFractal=root:Packages:Irena_UnifFit:Level2MassFractal
//Level3 part	
	NVAR  Level3Rg=root:Packages:Irena_UnifFit:Level3Rg
	NVAR  Level3FitRg=root:Packages:Irena_UnifFit:Level3FitRg
	NVAR  Level3RgLowLimit=root:Packages:Irena_UnifFit:Level3RgLowLimit
	NVAR  Level3RgHighLimit =root:Packages:Irena_UnifFit:Level3RgHighLimit
	NVAR  Level3G=root:Packages:Irena_UnifFit:Level3G
	NVAR  Level3FitG=root:Packages:Irena_UnifFit:Level3FitG
	NVAR  Level3GLowLimit=root:Packages:Irena_UnifFit:Level3GLowLimit
	NVAR  Level3GHighLimit =root:Packages:Irena_UnifFit:Level3GHighLimit
	NVAR  Level3P=root:Packages:Irena_UnifFit:Level3P
	NVAR  Level3FitP=root:Packages:Irena_UnifFit:Level3FitP
	NVAR  Level3PLowLimit=root:Packages:Irena_UnifFit:Level3PLowLimit
	NVAR  Level3PHighLimit=root:Packages:Irena_UnifFit:Level3PHighLimit
	NVAR  Level3B=root:Packages:Irena_UnifFit:Level3B
	NVAR  Level3FitB=root:Packages:Irena_UnifFit:Level3FitB
	NVAR  Level3BLowLimit=root:Packages:Irena_UnifFit:Level3BLowLimit
	NVAR  Level3BHighLimit=root:Packages:Irena_UnifFit:Level3BHighLimit
	NVAR  Level3ETA=root:Packages:Irena_UnifFit:Level3ETA
	NVAR  Level3FitETA=root:Packages:Irena_UnifFit:Level3FitETA
	NVAR  Level3ETALowLimit =root:Packages:Irena_UnifFit:Level3ETALowLimit
	NVAR  Level3ETAHighLimit=root:Packages:Irena_UnifFit:Level3ETAHighLimit
	NVAR  Level3PACK=root:Packages:Irena_UnifFit:Level3PACK
	NVAR  Level3FitPACK=root:Packages:Irena_UnifFit:Level3FitPACK
	NVAR  Level3PACKLowLimit=root:Packages:Irena_UnifFit:Level3PACKLowLimit
	NVAR  Level3PACKHighLimit=root:Packages:Irena_UnifFit:Level3PACKHighLimit
	NVAR  Level3RgCO=root:Packages:Irena_UnifFit:Level3RgCO
	NVAR  Level3FitRgCO=root:Packages:Irena_UnifFit:Level3FitRgCO
	NVAR  Level3RgCOLowLimit=root:Packages:Irena_UnifFit:Level3RgCOLowLimit
	NVAR  Level3RgCOHighLimit=root:Packages:Irena_UnifFit:Level3RgCOHighLimit
	NVAR  Level3K=root:Packages:Irena_UnifFit:Level3K
	NVAR  Level3Corelations=root:Packages:Irena_UnifFit:Level3Corelations
	NVAR  Level3MassFractal=root:Packages:Irena_UnifFit:Level3MassFractal
//Level4 part	
	NVAR  Level4Rg=root:Packages:Irena_UnifFit:Level4Rg
	NVAR  Level4FitRg=root:Packages:Irena_UnifFit:Level4FitRg
	NVAR  Level4RgLowLimit=root:Packages:Irena_UnifFit:Level4RgLowLimit
	NVAR  Level4RgHighLimit =root:Packages:Irena_UnifFit:Level4RgHighLimit
	NVAR  Level4G=root:Packages:Irena_UnifFit:Level4G
	NVAR  Level4FitG=root:Packages:Irena_UnifFit:Level4FitG
	NVAR  Level4GLowLimit=root:Packages:Irena_UnifFit:Level4GLowLimit
	NVAR  Level4GHighLimit =root:Packages:Irena_UnifFit:Level4GHighLimit
	NVAR  Level4P=root:Packages:Irena_UnifFit:Level4P
	NVAR  Level4FitP=root:Packages:Irena_UnifFit:Level4FitP
	NVAR  Level4PLowLimit=root:Packages:Irena_UnifFit:Level4PLowLimit
	NVAR  Level4PHighLimit=root:Packages:Irena_UnifFit:Level4PHighLimit
	NVAR  Level4B=root:Packages:Irena_UnifFit:Level4B
	NVAR  Level4FitB=root:Packages:Irena_UnifFit:Level4FitB
	NVAR  Level4BLowLimit=root:Packages:Irena_UnifFit:Level4BLowLimit
	NVAR  Level4BHighLimit=root:Packages:Irena_UnifFit:Level4BHighLimit
	NVAR  Level4ETA=root:Packages:Irena_UnifFit:Level4ETA
	NVAR  Level4FitETA=root:Packages:Irena_UnifFit:Level4FitETA
	NVAR  Level4ETALowLimit =root:Packages:Irena_UnifFit:Level4ETALowLimit
	NVAR  Level4ETAHighLimit=root:Packages:Irena_UnifFit:Level4ETAHighLimit
	NVAR  Level4PACK=root:Packages:Irena_UnifFit:Level4PACK
	NVAR  Level4FitPACK=root:Packages:Irena_UnifFit:Level4FitPACK
	NVAR  Level4PACKLowLimit=root:Packages:Irena_UnifFit:Level4PACKLowLimit
	NVAR  Level4PACKHighLimit=root:Packages:Irena_UnifFit:Level4PACKHighLimit
	NVAR  Level4RgCO=root:Packages:Irena_UnifFit:Level4RgCO
	NVAR  Level4FitRgCO=root:Packages:Irena_UnifFit:Level4FitRgCO
	NVAR  Level4RgCOLowLimit=root:Packages:Irena_UnifFit:Level4RgCOLowLimit
	NVAR  Level4RgCOHighLimit=root:Packages:Irena_UnifFit:Level4RgCOHighLimit
	NVAR  Level4K=root:Packages:Irena_UnifFit:Level4K
	NVAR  Level4Corelations=root:Packages:Irena_UnifFit:Level4Corelations
	NVAR  Level4MassFractal=root:Packages:Irena_UnifFit:Level4MassFractal
//Level5 part	
	NVAR  Level5Rg=root:Packages:Irena_UnifFit:Level5Rg
	NVAR  Level5FitRg=root:Packages:Irena_UnifFit:Level5FitRg
	NVAR  Level5RgLowLimit=root:Packages:Irena_UnifFit:Level5RgLowLimit
	NVAR  Level5RgHighLimit =root:Packages:Irena_UnifFit:Level5RgHighLimit
	NVAR  Level5G=root:Packages:Irena_UnifFit:Level5G
	NVAR  Level5FitG=root:Packages:Irena_UnifFit:Level5FitG
	NVAR  Level5GLowLimit=root:Packages:Irena_UnifFit:Level5GLowLimit
	NVAR  Level5GHighLimit =root:Packages:Irena_UnifFit:Level5GHighLimit
	NVAR  Level5P=root:Packages:Irena_UnifFit:Level5P
	NVAR  Level5FitP=root:Packages:Irena_UnifFit:Level5FitP
	NVAR  Level5PLowLimit=root:Packages:Irena_UnifFit:Level5PLowLimit
	NVAR  Level5PHighLimit=root:Packages:Irena_UnifFit:Level5PHighLimit
	NVAR  Level5B=root:Packages:Irena_UnifFit:Level5B
	NVAR  Level5FitB=root:Packages:Irena_UnifFit:Level5FitB
	NVAR  Level5BLowLimit=root:Packages:Irena_UnifFit:Level5BLowLimit
	NVAR  Level5BHighLimit=root:Packages:Irena_UnifFit:Level5BHighLimit
	NVAR  Level5ETA=root:Packages:Irena_UnifFit:Level5ETA
	NVAR  Level5FitETA=root:Packages:Irena_UnifFit:Level5FitETA
	NVAR  Level5ETALowLimit =root:Packages:Irena_UnifFit:Level5ETALowLimit
	NVAR  Level5ETAHighLimit=root:Packages:Irena_UnifFit:Level5ETAHighLimit
	NVAR  Level5PACK=root:Packages:Irena_UnifFit:Level5PACK
	NVAR  Level5FitPACK=root:Packages:Irena_UnifFit:Level5FitPACK
	NVAR  Level5PACKLowLimit=root:Packages:Irena_UnifFit:Level5PACKLowLimit
	NVAR  Level5PACKHighLimit=root:Packages:Irena_UnifFit:Level5PACKHighLimit
	NVAR  Level5RgCO=root:Packages:Irena_UnifFit:Level5RgCO
	NVAR  Level5FitRgCO=root:Packages:Irena_UnifFit:Level5FitRgCO
	NVAR  Level5RgCOLowLimit=root:Packages:Irena_UnifFit:Level5RgCOLowLimit
	NVAR  Level5RgCOHighLimit=root:Packages:Irena_UnifFit:Level5RgCOHighLimit
	NVAR  Level5K=root:Packages:Irena_UnifFit:Level5K
	NVAR  Level5Corelations=root:Packages:Irena_UnifFit:Level5Corelations
	NVAR  Level5MassFractal=root:Packages:Irena_UnifFit:Level5MassFractal

	Wave/T CoefNames=root:Packages:Irena_UnifFit:CoefNames		//text wave with names of parameters

	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	string ParamName=""
	
	for (i=0;i<NumOfParam;i+=1)
		ParamName=CoefNames[i]
	
		if(cmpstr(ParamName,"SASBackground")==0)
			SASBackground=abs(w[i])
		endif

		if(cmpstr(ParamName,"Level1Rg")==0)
			Level1Rg=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level1G")==0)
			Level1G=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level1P")==0)
			Level1P=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level1B")==0)
			Level1B=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level1ETA")==0)
			Level1ETA=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level1PACK")==0)
			Level1PACK=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level1RGCO")==0)
			Level1RGCO=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level1K")==0)
			Level1K=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level2Rg")==0)
			Level2Rg=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level2G")==0)
			Level2G=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level2P")==0)
			Level2P=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level2B")==0)
			Level2B=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level2ETA")==0)
			Level2ETA=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level2PACK")==0)
			Level2PACK=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level2RGCO")==0)
			Level2RGCO=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level2K")==0)
			Level2K=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level3Rg")==0)
			Level3Rg=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level3G")==0)
			Level3G=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level3P")==0)
			Level3P=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level3B")==0)
			Level3B=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level3ETA")==0)
			Level3ETA=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level3PACK")==0)
			Level3PACK=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level3RGCO")==0)
			Level3RGCO=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level3K")==0)
			Level3K=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level4Rg")==0)
			Level4Rg=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level4G")==0)
			Level4G=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level4P")==0)
			Level4P=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level4B")==0)
			Level4B=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level4ETA")==0)
			Level4ETA=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level4PACK")==0)
			Level4PACK=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level4RGCO")==0)
			Level4RGCO=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level4K")==0)
			Level4K=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level5Rg")==0)
			Level5Rg=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level5G")==0)
			Level5G=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level5P")==0)
			Level5P=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level5B")==0)
			Level5B=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level5ETA")==0)
			Level5ETA=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level5PACK")==0)
			Level5PACK=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level5RGCO")==0)
			Level5RGCO=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level5K")==0)
			Level5K=abs(w[i])
		endif

	endfor

	Wave QvectorWave=root:Packages:Irena_UnifFit:FitQvectorWave
	//and now we need to calculate the model Intensity
	IR1A_UnifiedFitCalculateInt(QvectorWave)		
	
	Wave resultWv=root:Packages:Irena_UnifFit:UnifiedFitIntensity
	
	yw=resultWv
End

///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************

Function IR1A_UnifiedFitCalculateInt(QvectorWave)
	Wave QvectorWave


	setDataFolder root:Packages:Irena_UnifFit
	
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
	Duplicate/O QvectorWave, UnifiedFitIntensity
	
	UnifiedFitIntensity=0
	
	variable i
	
	for(i=1;i<=NumberOfLevels;i+=1)	// initialize variables;continue test
		IR1A_UnifiedFitCalcIntOne(QvectorWave,i)
		Wave TempUnifiedIntensity
		UnifiedFitIntensity+=TempUnifiedIntensity
	endfor								
	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	UnifiedFitIntensity+=SASBackground	
	if(UseSMRData)
		duplicate/O  UnifiedFitIntensity, UnifiedFitIntensitySM
		IR1B_SmearData(UnifiedFitIntensity, QvectorWave, SlitLengthUnif, UnifiedFitIntensitySM)
		UnifiedFitIntensity=UnifiedFitIntensitySM
		KillWaves/Z UnifiedFitIntensitySM
	endif

end

///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************


Function IR1A_UnifiedFitCalcIntOne(QvectorWave,level)
	variable level
	Wave QvectorWave
	
	setDataFolder root:Packages:Irena_UnifFit
	Wave OriginalIntensity
	
	Duplicate/O QvectorWave, TempUnifiedIntensity
	Duplicate /O QvectorWave, QstarVector
	
	NVAR Rg=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Rg")
	NVAR G=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"G")
	NVAR P=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"P")
	NVAR B=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"B")
	NVAR ETA=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"ETA")
	NVAR PACK=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"PACK")
	NVAR RgCO=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgCO")
	NVAR K=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"K")
	NVAR Corelations=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Corelations")
	NVAR MassFractal=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"MassFractal")
	NVAR LinkRGCO=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"LinkRGCO")
	if (LinkRGCO==1 && level>=2)
		NVAR RgLowerLevel=$("root:Packages:Irena_UnifFit:Level"+num2str(level-1)+"Rg")	
		RGCO=RgLowerLevel
	endif
	QstarVector=QvectorWave/(erf(K*QvectorWave*Rg/sqrt(6)))^3
	if (MassFractal)
		B=(G*P/Rg^P)*exp(gammln(P/2))
	endif
	
	TempUnifiedIntensity=G*exp(-QvectorWave^2*Rg^2/3)+(B/QstarVector^P) * exp(-RGCO^2 * QvectorWave^2/3)
	
	if (Corelations)
		TempUnifiedIntensity/=(1+pack*IR1A_SphereAmplitude(QvectorWave,ETA))
	endif
end


///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************



Function IR1A_RecordResults(CalledFromWere)
	string CalledFromWere	//before or after - that means fit...
	

	string OldDF=GetDataFolder(1)
	setdataFolder root:Packages:Irena_UnifFit

	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR FitSASBackground=root:Packages:Irena_UnifFit:FitSASBackground
	NVAR SubtractBackground=root:Packages:Irena_UnifFit:SubtractBackground
	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif

	SVAR DataAreFrom=root:Packages:Irena_UnifFit:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena_UnifFit:IntensityWaveName
	SVAR QWavename=root:Packages:Irena_UnifFit:QWavename
	SVAR ErrorWaveName=root:Packages:Irena_UnifFit:ErrorWaveName

	IR1_CreateLoggbook()		//this creates the logbook
	SVAR nbl=root:Packages:SAS_Modeling:NotebookName

	IR1L_AppendAnyText("     ")
	if (cmpstr(CalledFromWere,"before")==0)
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Parameters before starting UNIFIED FIT on the data from: \t"+DataAreFrom)
		IR1_InsertDateAndTime(nbl)
		IR1L_AppendAnyText("Name of data waves Int/Q/Error \t"+IntensityWaveName+"\t"+QWavename+"\t"+ErrorWaveName)
		if(UseSMRData)
			IR1L_AppendAnyText("Slit smeared data were used. Slit length = "+num2str(SlitLengthUnif))
		endif
		IR1L_AppendAnyText("UNIFIED FIT")
		IR1L_AppendAnyText("Number of levels: "+num2str(NumberOfLevels))
	else			//after
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Results of the UNIFIED FIT on the data from: \t"+DataAreFrom)	
		IR1L_AppendAnyText("Name of data waves Int/Q/Error \t"+IntensityWaveName+"\t"+QWavename+"\t"+ErrorWaveName)
		if(UseSMRData)
			IR1L_AppendAnyText("Slit smeared data were used. Slit length = "+num2str(SlitLengthUnif))
		endif
		IR1L_AppendAnyText("UNIFIED FIT")
		IR1L_AppendAnyText("Number of fitted levels: "+num2str(NumberOfLevels))
		IR1L_AppendAnyText("Fitting results: ")
	endif
	IR1L_AppendAnyText("SAS background = "+num2str(SASBackground)+", was fitted? = "+num2str(FitSASBackground)+"       (yes=1/no=0)")
	variable i
	For (i=1;i<=NumberOfLevels;i+=1)
		IR1L_AppendAnyText("***********  Level  "+num2str(i))
		NVAR tempVal =$("Level"+num2str(i)+"Rg")
		NVAR tempValError =$("Level"+num2str(i)+"RgError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitRg")
			IR1L_AppendAnyText("Rg      \t\t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
		NVAR tempVal =$("Level"+num2str(i)+"G")
		NVAR tempValError =$("Level"+num2str(i)+"GError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitG")
			IR1L_AppendAnyText("G      \t\t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
		NVAR tempVal =$("Level"+num2str(i)+"P")
		NVAR tempValError =$("Level"+num2str(i)+"PError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitP")
			IR1L_AppendAnyText("P     \t \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
		NVAR tempValMassFractal =$("Level"+num2str(i)+"MassFractal")
			if (tempValMassFractal)
				IR1L_AppendAnyText("\tAssumed Mass Fractal")
				IR1L_AppendAnyText("Parameter B calculated as B=(G*P/Rg^P)*Gamma(P/2)")
			else
				NVAR tempVal =$("Level"+num2str(i)+"B")
				NVAR tempValError =$("Level"+num2str(i)+"BError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitB")
				IR1L_AppendAnyText("B     \t \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
			endif
		NVAR tempVal =$("Level"+num2str(i)+"RGCO")
		NVAR tempValError =$("Level"+num2str(i)+"RgCOError")
		NVAR LinktempVal=$("Level"+num2str(i)+"LinkRgCO")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitRGCO")
				if (fitTempVal)
					IR1L_AppendAnyText("RgCO linked to lower level Rg =\t"+ num2str(tempVal))
				else
					IR1L_AppendAnyText("RgCO      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
				endif
		NVAR tempVal =$("Level"+num2str(i)+"K")
			IR1L_AppendAnyText("K      \t"+ num2str(tempVal))
		NVAR tempValCorrelations =$("Level"+num2str(i)+"Corelations")
			if (tempValCorrelations)
				IR1L_AppendAnyText("Assumed Corelations so following parameters apply")
				NVAR tempVal =$("Level"+num2str(i)+"ETA")
				NVAR tempValError =$("Level"+num2str(i)+"ETAError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitETA")
					IR1L_AppendAnyText("ETA      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
				NVAR tempVal =$("Level"+num2str(i)+"PACK")
				NVAR tempValError =$("Level"+num2str(i)+"PACKError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitPACK")
				IR1L_AppendAnyText("PACK      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
		else
				IR1L_AppendAnyText("Corelations       \tNot assumed")
			endif

		NVAR tempVal =$("Level"+num2str(i)+"Invariant")
				IR1L_AppendAnyText("Invariant  =\t"+num2str(tempVal)+"   cm^(-1) A^(-3)")
		NVAR tempVal =$("Level"+num2str(i)+"SurfaceToVolRat")
			if (Numtype(tempVal)==0)
				IR1L_AppendAnyText("Surface to volume ratio  =\t"+num2str(tempVal)+"   m^(2) / cm^(3)")
			endif
			IR1L_AppendAnyText("  ")
	endfor
	
	if (cmpstr(CalledFromWere,"after")==0)
		IR1L_AppendAnyText("Fit has been reached with following parameters")
		IR1_InsertDateAndTime(nbl)
		NVAR AchievedChisq
		IR1L_AppendAnyText("Chi-Squared \t"+ num2str(AchievedChisq))

		DoWindow /F IR1_LogLogPlotU
		if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
			IR1L_AppendAnyText("Points selected for fitting \t"+ num2str(pcsr(A)) + "   to \t"+num2str(pcsr(B)))
		else
			IR1L_AppendAnyText("Whole range of data selected for fitting")
		endif
		IR1L_AppendAnyText(" ")
	endif			//after

	setdataFolder oldDf
end

Function IR1A_SaveRecordResults()	
	
	string OldDF=GetDataFolder(1)
	setdataFolder root:Packages:Irena_UnifFit

	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR FitSASBackground=root:Packages:Irena_UnifFit:FitSASBackground
	NVAR SubtractBackground=root:Packages:Irena_UnifFit:SubtractBackground
	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
	NVAR LastSavedUnifOutput=root:Packages:Irena_UnifFit:LastSavedUnifOutput
	NVAR ExportLocalFits=root:Packages:Irena_UnifFit:ExportLocalFits

	SVAR DataAreFrom=root:Packages:Irena_UnifFit:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena_UnifFit:IntensityWaveName
	SVAR QWavename=root:Packages:Irena_UnifFit:QWavename
	SVAR ErrorWaveName=root:Packages:Irena_UnifFit:ErrorWaveName

	IR1_CreateLoggbook()		//this creates the logbook
	SVAR nbl=root:Packages:SAS_Modeling:NotebookName

	IR1L_AppendAnyText("     ")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Saved Results of the UNIFIED FIT on the data from: \t"+DataAreFrom)	
		IR1_InsertDateAndTime(nbl)
		IR1L_AppendAnyText("Name of data waves Int/Q/Error \t"+IntensityWaveName+"\t"+QWavename+"\t"+ErrorWaveName)
		if(UseSMRData)
			IR1L_AppendAnyText("Slit smeared data were used. Slit length = "+num2str(SlitLengthUnif))
		endif
		IR1L_AppendAnyText("Output wave names :")
		IR1L_AppendAnyText("Int/Q \t"+"UnifiedFitIntensity_"+num2str(LastSavedUnifOutput)+"\tUnifiedFitQvector_"+num2str(LastSavedUnifOutput))
		if(ExportLocalFits)
			IR1L_AppendAnyText("Loacl fits saved also")
		endif
		
		IR1L_AppendAnyText("Number of fitted levels: "+num2str(NumberOfLevels))
		IR1L_AppendAnyText("Fitting results: ")
	IR1L_AppendAnyText("SAS background = "+num2str(SASBackground)+", was fitted? = "+num2str(FitSASBackground)+"       (yes=1/no=0)")
	variable i
	For (i=1;i<=NumberOfLevels;i+=1)
		IR1L_AppendAnyText("***********  Level  "+num2str(i))
		NVAR tempVal =$("Level"+num2str(i)+"Rg")
		NVAR tempValError =$("Level"+num2str(i)+"RgError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitRg")
			IR1L_AppendAnyText("Rg      \t\t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
		NVAR tempVal =$("Level"+num2str(i)+"G")
		NVAR tempValError =$("Level"+num2str(i)+"GError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitG")
			IR1L_AppendAnyText("G      \t\t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
		NVAR tempVal =$("Level"+num2str(i)+"P")
		NVAR tempValError =$("Level"+num2str(i)+"PError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitP")
			IR1L_AppendAnyText("P     \t \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
		NVAR tempValMassFractal =$("Level"+num2str(i)+"MassFractal")
			if (tempValMassFractal)
				IR1L_AppendAnyText("\tAssumed Mass Fractal")
				IR1L_AppendAnyText("Parameter B calculated as B=(G*P/Rg^P)*Gamma(P/2)")
			else
				NVAR tempVal =$("Level"+num2str(i)+"B")
				NVAR tempValError =$("Level"+num2str(i)+"BError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitB")
				IR1L_AppendAnyText("B     \t \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
			endif
		NVAR tempVal =$("Level"+num2str(i)+"RGCO")
		NVAR tempValError =$("Level"+num2str(i)+"RgCOError")
		NVAR LinktempVal=$("Level"+num2str(i)+"LinkRgCO")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitRGCO")
				if (fitTempVal)
					IR1L_AppendAnyText("RgCO linked to lower level Rg =\t"+ num2str(tempVal))
				else
					IR1L_AppendAnyText("RgCO      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
				endif
		NVAR tempVal =$("Level"+num2str(i)+"K")
			IR1L_AppendAnyText("K      \t"+ num2str(tempVal))
		NVAR tempValCorrelations =$("Level"+num2str(i)+"Corelations")
			if (tempValCorrelations)
				IR1L_AppendAnyText("Assumed Corelations so following parameters apply")
				NVAR tempVal =$("Level"+num2str(i)+"ETA")
				NVAR tempValError =$("Level"+num2str(i)+"ETAError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitETA")
					IR1L_AppendAnyText("ETA      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
				NVAR tempVal =$("Level"+num2str(i)+"PACK")
				NVAR tempValError =$("Level"+num2str(i)+"PACKError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitPACK")
				IR1L_AppendAnyText("PACK      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
		else
				IR1L_AppendAnyText("Corelations       \tNot assumed")
			endif

		NVAR tempVal =$("Level"+num2str(i)+"Invariant")
				IR1L_AppendAnyText("Invariant  =\t"+num2str(tempVal)+"   cm^(-1) A^(-3)")
		NVAR tempVal =$("Level"+num2str(i)+"SurfaceToVolRat")
			if (Numtype(tempVal)==0)
				IR1L_AppendAnyText("Surface to volume ratio  =\t"+num2str(tempVal)+"   m^(2) / cm^(3)")
			endif
			IR1L_AppendAnyText("  ")
	endfor
	
		IR1L_AppendAnyText("Fit has been reached with following parameters")
		IR1_InsertDateAndTime(nbl)
		NVAR/Z AchievedChisq
		if(NVAR_Exists(AchievedChisq))
			IR1L_AppendAnyText("Chi-Squared \t"+ num2str(AchievedChisq))
		endif
		DoWindow /F IR1_LogLogPlotU
		if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
			IR1L_AppendAnyText("Points selected for fitting \t"+ num2str(pcsr(A)) + "   to \t"+num2str(pcsr(B)))
		else
			IR1L_AppendAnyText("Whole range of data selected for fitting")
		endif
		IR1L_AppendAnyText(" ")
		IR1L_AppendAnyText("***********************************************")

	setdataFolder oldDf
end


//****************************************************************************************************************************


Function IR1A_RecoverOldParameters()
	
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR SASBackgroundError=root:Packages:Irena_UnifFit:SASBackgroundError
	SVAR DataFolderName=root:Packages:Irena_UnifFit:DataFolderName
	

	variable DataExists=0,i
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(DataFolderName, 2)
	string tempString
	if (stringmatch(ListOfWaves, "*UnifiedFitIntensity*" ))
		string ListOfSolutions=""
		For(i=0;i<itemsInList(ListOfWaves);i+=1)
			if (stringmatch(stringFromList(i,ListOfWaves),"*UnifiedFitIntensity*"))
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
		PopupMenu NumberOfLevels,mode=NumberOfLevels,value= #"\"0;1;2;3;4;5;\"", win = IR1A_ControlPanel
		//	
		SASBackground =NumberByKey("SASBackground", OldNote,"=")
		SASBackgroundError =NumberByKey("SASBackgroundError", OldNote,"=")
		For(i=1;i<=NumberOfLevels;i+=1)		
			IR1A_RecoverOneLevelParam(i,OldNote)	
		endfor
		return 1
	else
		return 0
	endif
end

Function IR1A_RecoverOneLevelParam(i,OldNote)	
	variable i
	string OldNote

	
	NVAR Rg=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Rg")
	NVAR G=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"G")
	NVAR P=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"P")
	NVAR B=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"B")
	NVAR ETA=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"ETA")
	NVAR PACK=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"PACK")
	NVAR RgCO=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"RgCO")
	NVAR RgError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"RgError")
	NVAR GError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"GError")
	NVAR PError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"PError")
	NVAR BError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"BError")
	NVAR ETAError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"ETAError")
	NVAR PACKError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"PACKError")
	NVAR RgCOError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"RgCOError")
	NVAR K=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"K")
	NVAR Corelations=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Corelations")
	NVAR MassFractal=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"MassFractal")
	NVAR Invariant =$("Level"+num2str(i)+"Invariant")
	NVAR SurfaceToVolumeRatio =$("Level"+num2str(i)+"SurfaceToVolRat")
	NVAR LinkRgCO =$("Level"+num2str(i)+"LinkRgCO")
	NVAR DegreeOfAggreg =$("Level"+num2str(i)+"DegreeOfAggreg")
//	 Level1Rg   
//	 Level1G   
//	 Level1P   
//	 Level1B   
//	 Level1ETA   
//	 Level1PACK   
//	 Level1RgCO   
//	 Level1RgError   
//	 Level1GError   
//	 Level1PError   
//	 Level1BError   
//	 Level1ETAError   
//	 Level1PACKError   
//	 Level1RGCOError
//	 Level1K   
//	 Level1Corelations   
//	 Level1MassFractal   
//	 Level1Invariant   
//	 Level1SurfaceToVolRat   
//	 Level1LinkRgCO   
//	 Level1DegreeOfAggreg   

	DegreeOfAggreg=NumberByKey("Level"+num2str(i)+"DegreeOfAggreg", OldNote,"=")
	LinkRgCO=NumberByKey("Level"+num2str(i)+"LinkRgCO", OldNote,"=")
	Rg=NumberByKey("Level"+num2str(i)+"Rg", OldNote,"=")
	RgError=NumberByKey("Level"+num2str(i)+"RgError", OldNote,"=")
	G=NumberByKey("Level"+num2str(i)+"G", OldNote,"=")
	GError=NumberByKey("Level"+num2str(i)+"GError", OldNote,"=")
	P=NumberByKey("Level"+num2str(i)+"P", OldNote,"=")
	PError=NumberByKey("Level"+num2str(i)+"PError", OldNote,"=")
	B=NumberByKey("Level"+num2str(i)+"B", OldNote,"=")
	BError=NumberByKey("Level"+num2str(i)+"BError", OldNote,"=")
	ETA=NumberByKey("Level"+num2str(i)+"ETA", OldNote,"=")
	ETAError=NumberByKey("Level"+num2str(i)+"ETAError", OldNote,"=")
	PACK=NumberByKey("Level"+num2str(i)+"PACK", OldNote,"=")
	PACKError=NumberByKey("Level"+num2str(i)+"PACKError", OldNote,"=")
	RgCO=NumberByKey("Level"+num2str(i)+"RgCO", OldNote,"=")
	RgCOError=NumberByKey("Level"+num2str(i)+"RgCOError", OldNote,"=")
	K=NumberByKey("Level"+num2str(i)+"K", OldNote,"=")
	Corelations=NumberByKey("Level"+num2str(i)+"Corelations", OldNote,"=")
	MassFractal=NumberByKey("Level"+num2str(i)+"MassFractal", OldNote,"=")
	Invariant=NumberByKey("Level"+num2str(i)+"Invariant", OldNote,"=")
	SurfaceToVolumeRatio=NumberByKey("Level"+num2str(i)+"SurfaceToVolumeRatio", OldNote,"=")


end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_CheckFittingParamsFnct() 
	//PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(400,140,970,620) as "Check fitting parameters"
	Dowindow/C IR1A_CheckFittingParams
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 3,textrgb= (0,0,65280)
	DrawText 39,28,"Unified Fit Params & Limits"
	SetDrawEnv fstyle= 1,fsize= 14
	DrawText 20,55,"Verify the list of fitted parameters. Then continue......"
	variable Qmin, Qmax
	Qmin=Nan
	Qmax=inf
	Wave OriginalQvector = root:Packages:Irena_UnifFit:OriginalQvector
	if(strlen(csrInfo(A))>0)		//cursor set
		Qmin = OriginalQvector(pcsr(A))
	endif
	Qmin = numtype(Qmin) == 0 ? Qmin :  OriginalQvector[0]
	if(strlen(csrInfo(B))>0)	//cursor set
		Qmax = OriginalQvector(pcsr(B))
	endif
	Qmax = numtype(Qmax) == 0 ? Qmax :  OriginalQvector[numpnts(OriginalQvector)-1]
	SetDrawEnv fstyle= 1,fsize= 14
	DrawText 30,80, "Data Selected for Fitting are "+num2str(pcsr(B)-pcsr(A))+" points from point   "+num2str(pcsr(A)) + "   to   "+num2str(pcsr(B)) 
	SetDrawEnv fstyle= 1,fsize= 14
	DrawText 30,105, "This is Q range from Qmin = " + num2str(Qmin) + " A\S-1\M  to  Qmax = "+num2str(Qmax) + "  A\S-1\M"
	
	Button CancelBtn,pos={10,445},size={135,20},proc=IR1A_CheckFitPrmsButtonProc,title="Cancel fitting"
	Button ContinueBtn,pos={160,445},size={135,20},proc=IR1A_CheckFitPrmsButtonProc,title="Continue fitting"
	CheckBox SkipFitControlDialog,pos={315,447},size={63,14},noproc,title="Skip this panel next time?"
	CheckBox SkipFitControlDialog,variable= root:Packages:Irena_UnifFit:SkipFitControlDialog, help={"Check if you want to skip the check parameters dialo for fitting"}
	SetVariable AdditionalFittingConstraints, size={460,20}, pos={20,420}, variable=AdditionalFittingConstraints, noproc, title = "Add Fitting Constraints : "
	SetVariable AdditionalFittingConstraints, help={"Add usual Igor constraints separated by ; - e.g., \"K0<K1;\""}


	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Irena_UnifFit:
	SVAR AdditionalFittingConstraints=root:Packages:Irena_UnifFit:AdditionalFittingConstraints
	Wave W_coef=root:Packages:Irena_UnifFit:W_coef
	Wave/T CoefNames=root:Packages:Irena_UnifFit:CoefNames
	Wave/T ParamNamesK=root:Packages:Irena_UnifFit:ParamNamesK
	Duplicate/T/O CoefNames, ParameterWarnings
	variable i
	string tmpStr
	For(i=0;i<Numpnts(CoefNames);i+=1)
		ParameterWarnings[i]=""
		tmpStr = CoefNames[i]
		if(stringmatch(tmpStr,"Background"))
			ParameterWarnings[i]=""		//no problem ever here
		elseif(stringmatch(tmpStr[6,7], "Rg")&& !stringmatch(tmpStr[6,9], "RGCO"))  //"Level1Rg"
			if(!stringmatch(tmpStr[0,5]+"G",CoefNames[i+1]))
				ParameterWarnings[i]="G is not fitted?"		
			endif
		elseif(stringmatch(tmpStr[6], "G")&& !stringmatch(tmpStr[6,8], "GCO"))  //"Level1Rg"
			if(!stringmatch(tmpStr[0,5]+"Rg",CoefNames[i-1]))
				ParameterWarnings[i]="Rg is not fitted?"		
			endif
		elseif(stringmatch(tmpStr[6], "P")&& !stringmatch(tmpStr[6,8], "PAC"))  //"Level1Rg"
			if(!stringmatch(tmpStr[0,5]+"B",CoefNames[i +1]))
				ParameterWarnings[i]="B is not fitted?"		
			endif
		elseif(stringmatch(tmpStr[6], "B")&& !stringmatch(tmpStr[6,8], "PAC"))  //"Level1Rg"
			if(!stringmatch(tmpStr[0,5]+"P",CoefNames[i -1]))
				ParameterWarnings[i]="P is not fitted?"		
			endif
		elseif(stringmatch(tmpStr[6,9], "PACK"))  //"Level1Rg"
			if(!stringmatch(tmpStr[0,5]+"ETA",CoefNames[i -1]))
				ParameterWarnings[i]="ETA is not fitted?"		
			endif
		elseif(stringmatch(tmpStr[6,8], "ETA"))  //"Level1Rg"
			if(!stringmatch(tmpStr[0,5]+"PACK",CoefNames[i +1]))
				ParameterWarnings[i]="PACK is not fitted?"		
			endif
		elseif(stringmatch(tmpStr[6,9], "RGCO"))  //"Level1Rg"
				ParameterWarnings[i]="Fitting RgCO is BAD idea..."		
		endif

	endfor
	NVAR UseNoLimits = root:Packages:Irena_UnifFit:UseNoLimits
	WAVE HighLimit=root:Packages:Irena_UnifFit:HighLimit
	WAVE LowLimit=root:Packages:Irena_UnifFit:LowLimit
	if(!UseNoLimits)
		Edit/W=(0.02,0.25,0.98,0.85)/HOST=#  ParamNamesK,CoefNames, W_coef, LowLimit, HighLimit, ParameterWarnings
		ModifyTable format(Point)=1,width(Point)=0,width(CoefNames)=100,title(CoefNames)="Fitted Coef Name"
		ModifyTable width(W_coef)=90,title(W_coef.y)="Start value",alignment=1, sigDigits(W_coef)=2
		ModifyTable width(LowLimit)=85,title(LowLimit.y)="Low limit", sigDigits(LowLimit)=2
		ModifyTable width(HighLimit)=85,title(HighLimit.y)="High limit", sigDigits(HighLimit)=2
		ModifyTable width(ParameterWarnings)=125,title(ParameterWarnings.y)="Warnings:"
		ModifyTable showParts=254,title(ParamNamesK)="Constr.",width(ParamNamesK)=40
	else
		Edit/W=(0.02,0.25,0.98,0.85)/HOST=#  ParamNamesK,CoefNames, W_coef, ParameterWarnings
		ModifyTable format(Point)=1,width(Point)=0,alignment=2,width(CoefNames)=150,title(CoefNames)="Fitted Coef Name"
		ModifyTable width(W_coef)=120,title(W_coef.y)="Start value",alignment=1,sigDigits(W_coef)=2
		ModifyTable width(ParameterWarnings)=225,title(ParameterWarnings.y)="Warnings:"
		ModifyTable showParts=254, title(ParamNamesK)="Constr.",width(ParamNamesK)=40
	endif
	SetDataFolder fldrSav0
	RenameWindow #,T0
	SetActiveSubwindow ##
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR1A_CheckFitPrmsButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if(stringmatch(ctrlName,"*CancelBtn*"))
		variable/g root:Packages:Irena_UnifFit:UserCanceled=1
		DoWindow/K IR1A_CheckFittingParams
	endif

	if(stringmatch(ctrlName,"*ContinueBtn*"))
		variable/g root:Packages:Irena_UnifFit:UserCanceled=0
		DoWindow/K IR1A_CheckFittingParams
	endif

End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
