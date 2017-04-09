#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.02

//thsi should be all commented out and later removed. 3/31/2017

//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.01 added license for ANL
//2.02 removed old method of genetic optimization

//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from usaxs.xray.aps.anl.gov/
//this package contains 
// Igor functions for modeling of SAS from various distributions of scatterers...

//Jan Ilavsky, January 2010

//please, read Readme in the distribution zip file with more details on the program
//report any problems to: ilavsky@aps.anl.gov


//These are fitting function and function creating the call function...
//this is real fun - the number of fittign parameters changes, so this is major complicated system...



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//
//Function IR1_FitFunction(w,yw,xw) : FitFunc
//	Wave w,yw,xw
//	
//	//here the w contains the parameters, yw will be the result and xw is the input
//	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
//	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
//	//CurveFitDialog/ Equation:
//	//CurveFitDialog/ f(q) = very complex calculations, forget about formula
//	//CurveFitDialog/ End of Equation
//	//CurveFitDialog/ Independent Variables 1 - the q vector...
//	//CurveFitDialog/ q
//	//CurveFitDialog/ Coefficients 21 - up to, but never used
//	//CurveFitDialog/ w[0] = SAS_Background
//	//CurveFitDialog/ w[1] = Dist1Volume
//	//CurveFitDialog/ w[2] = Dist1Location
//	//CurveFitDialog/ w[3] = Dist1Scale
//	//CurveFitDialog/ w[4] = Dist1Shape
//	//CurveFitDialog/ w[5] = Dist2Volume
//	//CurveFitDialog/ w[6] = Dist2Location
//	//CurveFitDialog/ w[7] = Dist2Scale
//	//CurveFitDialog/ w[8] = Dist2Shape
//	//CurveFitDialog/ w[9] = Dist3Volume
//	//CurveFitDialog/ w[10] = Dist3Location
//	//CurveFitDialog/ w[11] = Dist3Scale
//	//CurveFitDialog/ w[12] = Dist3Shape
//	//CurveFitDialog/ w[13] = Dist4Volume
//	//CurveFitDialog/ w[14] = Dist4Location
//	//CurveFitDialog/ w[15] = Dist4Scale
//	//CurveFitDialog/ w[16] = Dist4Shape
//	//CurveFitDialog/ w[17] = Dist5Volume
//	//CurveFitDialog/ w[18] = Dist5Location
//	//CurveFitDialog/ w[19] = Dist5Scale
//	//CurveFitDialog/ w[20] = Dist5Shape
//
//
//	//SAS_Background						K0
//	//Dist1Volume, Location, Scale, Shape		K1,K2,K3,K4
//	//Dist2Volume, Location, Scale, Shape		K5,K6,K7,K8
//	//Dist3Volume, Location, Scale, Shape		K9,K10,K11,K12
//	//Dist4Volume, Location, Scale, Shape		K13,K14,K15,K16
//	//Dist5Volume, Location, Scale, Shape		K17,K18,K19,K20
//	//that is 21 fitting parameters
//
//
//	Wave/T CoefNames=root:Packages:SAS_Modeling:CoefNames		//text wave with names of parameters
//
//	variable i, NumOfParam
//	NumOfParam=numpnts(CoefNames)
//	string ParamName=""
//	
//	string OdlDf=GetDataFolder(1)
//	setDataFOlder root:packages:SAS_Modeling
//	
//	for (i=0;i<NumOfParam;i+=1)
//		ParamName=CoefNames[i]
//
//		Nvar TempParam=$(ParamName)
//		TempParam=w[i]	
//	endfor
//	
//	Wave QvectorWave=root:Packages:SAS_Modeling:FitQvectorWave
//
//	IR1_CreateDistributionWaves()
//	//next we calculate the distributions
//	IR1_CalculateDistributions()
//	//and now we need to calculate the model Intensity
//	IR1_FitCalculateModelIntensity(QvectorWave)
//	IR1_FitSmearLSQFData()
//
//	
//	Wave resultWv=root:Packages:SAS_Modeling:FitDistModelIntensity
//	
//	SetDataFolder OdlDf
//	yw=resultWv
//	
//End
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//
//Function IR1S_ResetErrors()
//
//	string ListOfVars="SASBackgroundError;Dist1LocationError;Dist1ScaleError;Dist1ShapeError;Dist1VolFractionError;"
//	ListOfVars+="Dist2LocationError;Dist2ScaleError;Dist2ShapeError;Dist2VolFractionError;"
//	ListOfVars+="Dist3LocationError;Dist3ScaleError;Dist3ShapeError;Dist3VolFractionError;"
//	ListOfVars+="Dist4LocationError;Dist4ScaleError;Dist4ShapeError;Dist4VolFractionError;"
//	ListOfVars+="Dist5LocationError;Dist5ScaleError;Dist5ShapeError;Dist5VolFractionError;"
//	
//	variable i
//	For(i=0;i<ItemsInList(ListOfVars);i+=1)
//		NVAR testNum=$("root:Packages:SAS_Modeling:"+StringFromList(i,ListOfVars))
//		testNum=0
//	endfor	
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////
////Function IR1S_ConstructTheFittingCommand()
////	//here we need to construct the fitting command and prepare the data for fit...
////
////	string OldDF=GetDataFolder(1)
////	setDataFolder root:Packages:SAS_Modeling
////	
////	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
////
////	NVAR SASBackground=root:Packages:SAS_Modeling:SASBackground
////	NVAR FitSASBackground=root:Packages:SAS_Modeling:FitSASBackground
////	NVAR UseInterference = root:Packages:SAS_Modeling:UseInterference
////	
//////dist 1 part	
////	NVAR Dist1VolFraction=root:Packages:SAS_Modeling:Dist1VolFraction
////	NVAR Dist1VolHighLimit=root:Packages:SAS_Modeling:Dist1VolHighLimit
////	NVAR Dist1VolLowLimit=root:Packages:SAS_Modeling:Dist1VolLowLimit
////	NVAR Dist1Location=root:Packages:SAS_Modeling:Dist1Location
////	NVAR Dist1LocHighLimit=root:Packages:SAS_Modeling:Dist1LocHighLimit
////	NVAR Dist1LocLowLimit=root:Packages:SAS_Modeling:Dist1LocLowLimit
////	NVAR Dist1Scale=root:Packages:SAS_Modeling:Dist1Scale
////	NVAR Dist1ShapeHighLimit=root:Packages:SAS_Modeling:Dist1ShapeHighLimit
////	NVAR Dist1ShapeLowLimit=root:Packages:SAS_Modeling:Dist1ShapeLowLimit
////	NVAR Dist1Shape=root:Packages:SAS_Modeling:Dist1Shape
////	NVAR Dist1ScaleHighLimit=root:Packages:SAS_Modeling:Dist1ScaleHighLimit
////	NVAR Dist1ScaleLowLimit=root:Packages:SAS_Modeling:Dist1ScaleLowLimit
////	
////	NVAR Dist1FitShape=root:Packages:SAS_Modeling:Dist1FitShape
////	NVAR Dist1FitLocation=root:Packages:SAS_Modeling:Dist1FitLocation
////	NVAR Dist1FitScale=root:Packages:SAS_Modeling:Dist1FitScale
////	NVAR Dist1FitVol=root:Packages:SAS_Modeling:Dist1FitVol
////
////	NVAR Dist1ScatShapeParam1=root:Packages:SAS_Modeling:Dist1ScatShapeParam1
////	NVAR Dist1FitScatShapeParam1=root:Packages:SAS_Modeling:Dist1FitScatShapeParam1
////	NVAR Dist1ScatShapeParam1LowLimit=root:Packages:SAS_Modeling:Dist1ScatShapeParam1LowLimit
////	NVAR Dist1ScatShapeParam1HighLimit=root:Packages:SAS_Modeling:Dist1ScatShapeParam1HighLimit
////
////	NVAR Dist1ScatShapeParam2=root:Packages:SAS_Modeling:Dist1ScatShapeParam2
////	NVAR Dist1FitScatShapeParam2=root:Packages:SAS_Modeling:Dist1FitScatShapeParam2
////	NVAR Dist1ScatShapeParam2LowLimit=root:Packages:SAS_Modeling:Dist1ScatShapeParam2LowLimit
////	NVAR Dist1ScatShapeParam2HighLimit=root:Packages:SAS_Modeling:Dist1ScatShapeParam2HighLimit
////
////	NVAR Dist1ScatShapeParam3=root:Packages:SAS_Modeling:Dist1ScatShapeParam3
////	NVAR Dist1FitScatShapeParam3=root:Packages:SAS_Modeling:Dist1FitScatShapeParam3
////	NVAR Dist1ScatShapeParam3LowLimit=root:Packages:SAS_Modeling:Dist1ScatShapeParam3LowLimit
////	NVAR Dist1ScatShapeParam3HighLimit=root:Packages:SAS_Modeling:Dist1ScatShapeParam3HighLimit
////
////	NVAR Dist1UseInterference=root:Packages:SAS_Modeling:Dist1UseInterference
////	NVAR Dist1InterferencePhi = root:Packages:SAS_Modeling:Dist1InterferencePhi
////	NVAR Dist1InterferencePhiLL = root:Packages:SAS_Modeling:Dist1InterferencePhiLL
////	NVAR Dist1InterferencePhiHL = root:Packages:SAS_Modeling:Dist1InterferencePhiHL
////	NVAR Dist1InterferenceEta = root:Packages:SAS_Modeling:Dist1InterferenceEta
////	NVAR Dist1InterferenceEtaLL = root:Packages:SAS_Modeling:Dist1InterferenceEtaLL
////	NVAR Dist1InterferenceEtaHL = root:Packages:SAS_Modeling:Dist1InterferenceEtaHL
////
////	NVAR Dist1FitInterferencePhi = root:Packages:SAS_Modeling:Dist1FitInterferencePhi
////	NVAR Dist1FitInterferenceEta = root:Packages:SAS_Modeling:Dist1FitInterferenceEta
////
//////dist 2 part
////	NVAR Dist2VolFraction=root:Packages:SAS_Modeling:Dist2VolFraction
////	NVAR Dist2VolHighLimit=root:Packages:SAS_Modeling:Dist2VolHighLimit
////	NVAR Dist2VolLowLimit=root:Packages:SAS_Modeling:Dist2VolLowLimit
////	NVAR Dist2Location=root:Packages:SAS_Modeling:Dist2Location
////	NVAR Dist2LocHighLimit=root:Packages:SAS_Modeling:Dist2LocHighLimit
////	NVAR Dist2LocLowLimit=root:Packages:SAS_Modeling:Dist2LocLowLimit
////	NVAR Dist2Scale=root:Packages:SAS_Modeling:Dist2Scale
////	NVAR Dist2ShapeHighLimit=root:Packages:SAS_Modeling:Dist2ShapeHighLimit
////	NVAR Dist2ShapeLowLimit=root:Packages:SAS_Modeling:Dist2ShapeLowLimit
////	NVAR Dist2Shape=root:Packages:SAS_Modeling:Dist2Shape
////	NVAR Dist2ScaleHighLimit=root:Packages:SAS_Modeling:Dist2ScaleHighLimit
////	NVAR Dist2ScaleLowLimit=root:Packages:SAS_Modeling:Dist2ScaleLowLimit
////	
////	NVAR Dist2FitShape=root:Packages:SAS_Modeling:Dist2FitShape
////	NVAR Dist2FitLocation=root:Packages:SAS_Modeling:Dist2FitLocation
////	NVAR Dist2FitScale=root:Packages:SAS_Modeling:Dist2FitScale
////	NVAR Dist2FitVol=root:Packages:SAS_Modeling:Dist2FitVol
////
////	NVAR Dist2ScatShapeParam1=root:Packages:SAS_Modeling:Dist2ScatShapeParam1
////	NVAR Dist2FitScatShapeParam1=root:Packages:SAS_Modeling:Dist2FitScatShapeParam1
////	NVAR Dist2ScatShapeParam1LowLimit=root:Packages:SAS_Modeling:Dist2ScatShapeParam1LowLimit
////	NVAR Dist2ScatShapeParam1HighLimit=root:Packages:SAS_Modeling:Dist2ScatShapeParam1HighLimit
////
////	NVAR Dist2ScatShapeParam2=root:Packages:SAS_Modeling:Dist2ScatShapeParam2
////	NVAR Dist2FitScatShapeParam2=root:Packages:SAS_Modeling:Dist2FitScatShapeParam2
////	NVAR Dist2ScatShapeParam2LowLimit=root:Packages:SAS_Modeling:Dist2ScatShapeParam2LowLimit
////	NVAR Dist2ScatShapeParam2HighLimit=root:Packages:SAS_Modeling:Dist2ScatShapeParam2HighLimit
////
////	NVAR Dist2ScatShapeParam3=root:Packages:SAS_Modeling:Dist2ScatShapeParam3
////	NVAR Dist2FitScatShapeParam3=root:Packages:SAS_Modeling:Dist2FitScatShapeParam3
////	NVAR Dist2ScatShapeParam3LowLimit=root:Packages:SAS_Modeling:Dist2ScatShapeParam3LowLimit
////	NVAR Dist2ScatShapeParam3HighLimit=root:Packages:SAS_Modeling:Dist2ScatShapeParam3HighLimit
////
////	NVAR Dist2UseInterference=root:Packages:SAS_Modeling:Dist2UseInterference
////	NVAR Dist2InterferencePhi = root:Packages:SAS_Modeling:Dist2InterferencePhi
////	NVAR Dist2InterferencePhiLL = root:Packages:SAS_Modeling:Dist2InterferencePhiLL
////	NVAR Dist2InterferencePhiHL = root:Packages:SAS_Modeling:Dist2InterferencePhiHL
////	NVAR Dist2InterferenceEta = root:Packages:SAS_Modeling:Dist2InterferenceEta
////	NVAR Dist2InterferenceEtaLL = root:Packages:SAS_Modeling:Dist2InterferenceEtaLL
////	NVAR Dist2InterferenceEtaHL = root:Packages:SAS_Modeling:Dist2InterferenceEtaHL
////
////	NVAR Dist2FitInterferencePhi = root:Packages:SAS_Modeling:Dist2FitInterferencePhi
////	NVAR Dist2FitInterferenceEta = root:Packages:SAS_Modeling:Dist2FitInterferenceEta
////
//////dist3 part
////	NVAR Dist3VolFraction=root:Packages:SAS_Modeling:Dist3VolFraction
////	NVAR Dist3VolHighLimit=root:Packages:SAS_Modeling:Dist3VolHighLimit
////	NVAR Dist3VolLowLimit=root:Packages:SAS_Modeling:Dist3VolLowLimit
////	NVAR Dist3Location=root:Packages:SAS_Modeling:Dist3Location
////	NVAR Dist3LocHighLimit=root:Packages:SAS_Modeling:Dist3LocHighLimit
////	NVAR Dist3LocLowLimit=root:Packages:SAS_Modeling:Dist3LocLowLimit
////	NVAR Dist3Scale=root:Packages:SAS_Modeling:Dist3Scale
////	NVAR Dist3ShapeHighLimit=root:Packages:SAS_Modeling:Dist3ShapeHighLimit
////	NVAR Dist3ShapeLowLimit=root:Packages:SAS_Modeling:Dist3ShapeLowLimit
////	NVAR Dist3Shape=root:Packages:SAS_Modeling:Dist3Shape
////	NVAR Dist3ScaleHighLimit=root:Packages:SAS_Modeling:Dist3ScaleHighLimit
////	NVAR Dist3ScaleLowLimit=root:Packages:SAS_Modeling:Dist3ScaleLowLimit
////	
////	NVAR Dist3FitShape=root:Packages:SAS_Modeling:Dist3FitShape
////	NVAR Dist3FitLocation=root:Packages:SAS_Modeling:Dist3FitLocation
////	NVAR Dist3FitScale=root:Packages:SAS_Modeling:Dist3FitScale
////	NVAR Dist3FitVol=root:Packages:SAS_Modeling:Dist3FitVol
////
////
////	NVAR Dist3ScatShapeParam1=root:Packages:SAS_Modeling:Dist3ScatShapeParam1
////	NVAR Dist3FitScatShapeParam1=root:Packages:SAS_Modeling:Dist3FitScatShapeParam1
////	NVAR Dist3ScatShapeParam1LowLimit=root:Packages:SAS_Modeling:Dist3ScatShapeParam1LowLimit
////	NVAR Dist3ScatShapeParam1HighLimit=root:Packages:SAS_Modeling:Dist3ScatShapeParam1HighLimit
////
////	NVAR Dist3ScatShapeParam2=root:Packages:SAS_Modeling:Dist3ScatShapeParam2
////	NVAR Dist3FitScatShapeParam2=root:Packages:SAS_Modeling:Dist3FitScatShapeParam2
////	NVAR Dist3ScatShapeParam2LowLimit=root:Packages:SAS_Modeling:Dist3ScatShapeParam2LowLimit
////	NVAR Dist3ScatShapeParam2HighLimit=root:Packages:SAS_Modeling:Dist3ScatShapeParam2HighLimit
////
////	NVAR Dist3ScatShapeParam3=root:Packages:SAS_Modeling:Dist3ScatShapeParam3
////	NVAR Dist3FitScatShapeParam3=root:Packages:SAS_Modeling:Dist3FitScatShapeParam3
////	NVAR Dist3ScatShapeParam3LowLimit=root:Packages:SAS_Modeling:Dist3ScatShapeParam3LowLimit
////	NVAR Dist3ScatShapeParam3HighLimit=root:Packages:SAS_Modeling:Dist3ScatShapeParam3HighLimit
////
////	NVAR Dist3UseInterference=root:Packages:SAS_Modeling:Dist3UseInterference
////	NVAR Dist3InterferencePhi = root:Packages:SAS_Modeling:Dist3InterferencePhi
////	NVAR Dist3InterferencePhiLL = root:Packages:SAS_Modeling:Dist3InterferencePhiLL
////	NVAR Dist3InterferencePhiHL = root:Packages:SAS_Modeling:Dist3InterferencePhiHL
////	NVAR Dist3InterferenceEta = root:Packages:SAS_Modeling:Dist3InterferenceEta
////	NVAR Dist3InterferenceEtaLL = root:Packages:SAS_Modeling:Dist3InterferenceEtaLL
////	NVAR Dist3InterferenceEtaHL = root:Packages:SAS_Modeling:Dist3InterferenceEtaHL
////
////	NVAR Dist3FitInterferencePhi = root:Packages:SAS_Modeling:Dist3FitInterferencePhi
////	NVAR Dist3FitInterferenceEta = root:Packages:SAS_Modeling:Dist3FitInterferenceEta
////
//////Dist 4 part
////	NVAR Dist4VolFraction=root:Packages:SAS_Modeling:Dist4VolFraction
////	NVAR Dist4VolHighLimit=root:Packages:SAS_Modeling:Dist4VolHighLimit
////	NVAR Dist4VolLowLimit=root:Packages:SAS_Modeling:Dist4VolLowLimit
////	NVAR Dist4Location=root:Packages:SAS_Modeling:Dist4Location
////	NVAR Dist4LocHighLimit=root:Packages:SAS_Modeling:Dist4LocHighLimit
////	NVAR Dist4LocLowLimit=root:Packages:SAS_Modeling:Dist4LocLowLimit
////	NVAR Dist4Scale=root:Packages:SAS_Modeling:Dist4Scale
////	NVAR Dist4ShapeHighLimit=root:Packages:SAS_Modeling:Dist4ShapeHighLimit
////	NVAR Dist4ShapeLowLimit=root:Packages:SAS_Modeling:Dist4ShapeLowLimit
////	NVAR Dist4Shape=root:Packages:SAS_Modeling:Dist4Shape
////	NVAR Dist4ScaleHighLimit=root:Packages:SAS_Modeling:Dist4ScaleHighLimit
////	NVAR Dist4ScaleLowLimit=root:Packages:SAS_Modeling:Dist4ScaleLowLimit
////	
////	NVAR Dist4FitShape=root:Packages:SAS_Modeling:Dist4FitShape
////	NVAR Dist4FitLocation=root:Packages:SAS_Modeling:Dist4FitLocation
////	NVAR Dist4FitScale=root:Packages:SAS_Modeling:Dist4FitScale
////	NVAR Dist4FitVol=root:Packages:SAS_Modeling:Dist4FitVol
////
////
////	NVAR Dist4ScatShapeParam1=root:Packages:SAS_Modeling:Dist4ScatShapeParam1
////	NVAR Dist4FitScatShapeParam1=root:Packages:SAS_Modeling:Dist4FitScatShapeParam1
////	NVAR Dist4ScatShapeParam1LowLimit=root:Packages:SAS_Modeling:Dist4ScatShapeParam1LowLimit
////	NVAR Dist4ScatShapeParam1HighLimit=root:Packages:SAS_Modeling:Dist4ScatShapeParam1HighLimit
////
////	NVAR Dist4ScatShapeParam2=root:Packages:SAS_Modeling:Dist4ScatShapeParam2
////	NVAR Dist4FitScatShapeParam2=root:Packages:SAS_Modeling:Dist4FitScatShapeParam2
////	NVAR Dist4ScatShapeParam2LowLimit=root:Packages:SAS_Modeling:Dist4ScatShapeParam2LowLimit
////	NVAR Dist4ScatShapeParam2HighLimit=root:Packages:SAS_Modeling:Dist4ScatShapeParam2HighLimit
////
////	NVAR Dist4ScatShapeParam3=root:Packages:SAS_Modeling:Dist4ScatShapeParam3
////	NVAR Dist4FitScatShapeParam3=root:Packages:SAS_Modeling:Dist4FitScatShapeParam3
////	NVAR Dist4ScatShapeParam3LowLimit=root:Packages:SAS_Modeling:Dist4ScatShapeParam3LowLimit
////	NVAR Dist4ScatShapeParam3HighLimit=root:Packages:SAS_Modeling:Dist4ScatShapeParam3HighLimit
////
////	NVAR Dist4UseInterference=root:Packages:SAS_Modeling:Dist4UseInterference
////	NVAR Dist4InterferencePhi = root:Packages:SAS_Modeling:Dist4InterferencePhi
////	NVAR Dist4InterferencePhiLL = root:Packages:SAS_Modeling:Dist4InterferencePhiLL
////	NVAR Dist4InterferencePhiHL = root:Packages:SAS_Modeling:Dist4InterferencePhiHL
////	NVAR Dist4InterferenceEta = root:Packages:SAS_Modeling:Dist4InterferenceEta
////	NVAR Dist4InterferenceEtaLL = root:Packages:SAS_Modeling:Dist4InterferenceEtaLL
////	NVAR Dist4InterferenceEtaHL = root:Packages:SAS_Modeling:Dist4InterferenceEtaHL
////
////	NVAR Dist4FitInterferencePhi = root:Packages:SAS_Modeling:Dist4FitInterferencePhi
////	NVAR Dist4FitInterferenceEta = root:Packages:SAS_Modeling:Dist4FitInterferenceEta
////
//////dist 5 part
////	NVAR Dist5VolFraction=root:Packages:SAS_Modeling:Dist5VolFraction
////	NVAR Dist5VolHighLimit=root:Packages:SAS_Modeling:Dist5VolHighLimit
////	NVAR Dist5VolLowLimit=root:Packages:SAS_Modeling:Dist5VolLowLimit
////	NVAR Dist5Location=root:Packages:SAS_Modeling:Dist5Location
////	NVAR Dist5LocHighLimit=root:Packages:SAS_Modeling:Dist5LocHighLimit
////	NVAR Dist5LocLowLimit=root:Packages:SAS_Modeling:Dist5LocLowLimit
////	NVAR Dist5Scale=root:Packages:SAS_Modeling:Dist5Scale
////	NVAR Dist5ShapeHighLimit=root:Packages:SAS_Modeling:Dist5ShapeHighLimit
////	NVAR Dist5ShapeLowLimit=root:Packages:SAS_Modeling:Dist5ShapeLowLimit
////	NVAR Dist5Shape=root:Packages:SAS_Modeling:Dist5Shape
////	NVAR Dist5ScaleHighLimit=root:Packages:SAS_Modeling:Dist5ScaleHighLimit
////	NVAR Dist5ScaleLowLimit=root:Packages:SAS_Modeling:Dist5ScaleLowLimit
////	
////	NVAR Dist5FitShape=root:Packages:SAS_Modeling:Dist5FitShape
////	NVAR Dist5FitLocation=root:Packages:SAS_Modeling:Dist5FitLocation
////	NVAR Dist5FitScale=root:Packages:SAS_Modeling:Dist5FitScale
////	NVAR Dist5FitVol=root:Packages:SAS_Modeling:Dist5FitVol
////
////
////	NVAR Dist5ScatShapeParam1=root:Packages:SAS_Modeling:Dist5ScatShapeParam1
////	NVAR Dist5FitScatShapeParam1=root:Packages:SAS_Modeling:Dist5FitScatShapeParam1
////	NVAR Dist5ScatShapeParam1LowLimit=root:Packages:SAS_Modeling:Dist5ScatShapeParam1LowLimit
////	NVAR Dist5ScatShapeParam1HighLimit=root:Packages:SAS_Modeling:Dist5ScatShapeParam1HighLimit
////
////	NVAR Dist5ScatShapeParam2=root:Packages:SAS_Modeling:Dist5ScatShapeParam2
////	NVAR Dist5FitScatShapeParam2=root:Packages:SAS_Modeling:Dist5FitScatShapeParam2
////	NVAR Dist5ScatShapeParam2LowLimit=root:Packages:SAS_Modeling:Dist5ScatShapeParam2LowLimit
////	NVAR Dist5ScatShapeParam2HighLimit=root:Packages:SAS_Modeling:Dist5ScatShapeParam2HighLimit
////
////	NVAR Dist5ScatShapeParam3=root:Packages:SAS_Modeling:Dist5ScatShapeParam3
////	NVAR Dist5FitScatShapeParam3=root:Packages:SAS_Modeling:Dist5FitScatShapeParam3
////	NVAR Dist5ScatShapeParam3LowLimit=root:Packages:SAS_Modeling:Dist5ScatShapeParam3LowLimit
////	NVAR Dist5ScatShapeParam3HighLimit=root:Packages:SAS_Modeling:Dist5ScatShapeParam3HighLimit
////
////	NVAR Dist5UseInterference=root:Packages:SAS_Modeling:Dist5UseInterference
////	NVAR Dist5InterferencePhi = root:Packages:SAS_Modeling:Dist5InterferencePhi
////	NVAR Dist5InterferencePhiLL = root:Packages:SAS_Modeling:Dist5InterferencePhiLL
////	NVAR Dist5InterferencePhiHL = root:Packages:SAS_Modeling:Dist5InterferencePhiHL
////	NVAR Dist5InterferenceEta = root:Packages:SAS_Modeling:Dist5InterferenceEta
////	NVAR Dist5InterferenceEtaLL = root:Packages:SAS_Modeling:Dist5InterferenceEtaLL
////	NVAR Dist5InterferenceEtaHL = root:Packages:SAS_Modeling:Dist5InterferenceEtaHL
////
////	NVAR Dist5FitInterferencePhi = root:Packages:SAS_Modeling:Dist5FitInterferencePhi
////	NVAR Dist5FitInterferenceEta = root:Packages:SAS_Modeling:Dist5FitInterferenceEta
////
////
////	SVAR Dist1DistributionType=root:Packages:SAS_Modeling:Dist1DistributionType
////	SVAR Dist2DistributionType=root:Packages:SAS_Modeling:Dist2DistributionType
////	SVAR Dist3DistributionType=root:Packages:SAS_Modeling:Dist3DistributionType
////	SVAR Dist4DistributionType=root:Packages:SAS_Modeling:Dist4DistributionType
////	SVAR Dist5DistributionType=root:Packages:SAS_Modeling:Dist5DistributionType
////
////	Make/D/N=0/O W_coef
////	Make/T/N=0/O CoefNames
////	Make/O/N=(0,2) Gen_Constraints
////	Make/D/O/T/N=0 T_Constraints
////	T_Constraints=""
////	CoefNames=""
////	
////	if (FitSASBackground)		//are we fitting background?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames//, T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=SASBackground
////		CoefNames[numpnts(CoefNames)-1]="SASBackground"
////	//	T_Constraints[0] = {"K"+num2str(numpnts(W_coef)-1)+" > 0"}
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = -1* SASBackground*10
////		Gen_Constraints[numpnts(CoefNames)-1][1] = SASBackground*10
////	endif
//////dist 1 part	
////	if (Dist1FitVol && NumberOfDistributions>0)		//are we fitting distribution 1 volume?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist1VolFraction
////		CoefNames[numpnts(CoefNames)-1]="Dist1VolFraction"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist1VolLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist1VolHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist1VolLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist1VolHighLimit
////	endif
////	if (Dist1FitLocation && NumberOfDistributions>0 && (cmpstr(Dist1DistributionType,"PowerLaw")!=0))		//are we fitting distribution 1 location?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist1Location
////		CoefNames[numpnts(CoefNames)-1]="Dist1Location"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist1LocLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist1LocHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist1LocLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist1LocHighLimit
////	endif
////	if (Dist1FitScale && NumberOfDistributions>0 && (cmpstr(Dist1DistributionType,"LogNormal")==0 || cmpstr(Dist1DistributionType,"Gauss")==0))
////			//are we fitting distribution 1 scale?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist1Scale
////		CoefNames[numpnts(CoefNames)-1]="Dist1Scale"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist1ScaleLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist1ScaleHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist1ScaleLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist1ScaleHighLimit
////	endif
////	if (Dist1FitShape && NumberOfDistributions>0 && ((cmpstr(Dist1DistributionType,"LogNormal")==0) || (cmpstr(Dist1DistributionType,"PowerLaw")==0)))
////			//are we fitting distribution 1 shape?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist1Shape
////		CoefNames[numpnts(CoefNames)-1]="Dist1Shape"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist1ShapeLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist1ShapeHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist1ShapeLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist1ShapeHighLimit
////	endif
////
////	if (Dist1FitScatShapeParam1 && NumberOfDistributions>0)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist1ScatShapeParam1
////		CoefNames[numpnts(CoefNames)-1]="Dist1ScatShapeParam1"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist1ScatShapeParam1LowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist1ScatShapeParam1HighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist1ScatShapeParam1LowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist1ScatShapeParam1HighLimit
////	endif
////	
////	if (Dist1FitScatShapeParam2 && NumberOfDistributions>0)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist1ScatShapeParam2
////		CoefNames[numpnts(CoefNames)-1]="Dist1ScatShapeParam2"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist1ScatShapeParam2LowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist1ScatShapeParam2HighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist1ScatShapeParam2LowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist1ScatShapeParam2HighLimit
////	endif
////	
////	if (Dist1FitScatShapeParam3 && NumberOfDistributions>0)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist1ScatShapeParam3
////		CoefNames[numpnts(CoefNames)-1]="Dist1ScatShapeParam3"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist1ScatShapeParam3LowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist1ScatShapeParam3HighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist1ScatShapeParam3LowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist1ScatShapeParam3HighLimit
////	endif
////	if (Dist1FitInterferencePhi && Dist1UseInterference && UseInterference && NumberOfDistributions>0)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist1InterferencePhi
////		CoefNames[numpnts(CoefNames)-1]="Dist1InterferencePhi"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist1InterferencePhiLL)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist1InterferencePhiHL)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist1InterferencePhiLL
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist1InterferencePhiHL
////	endif
////	if (Dist1FitInterferenceETA && Dist1UseInterference && UseInterference && NumberOfDistributions>0)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist1InterferenceEta
////		CoefNames[numpnts(CoefNames)-1]="Dist1InterferenceEta"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist1InterferenceEtaLL)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist1InterferenceEtaHL)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist1InterferenceEtaLL
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist1InterferenceEtaHL
////	endif
////	
//////dist 2 part	
////	if (Dist2FitVol && NumberOfDistributions>1)		//are we fitting distribution 2 volume?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist2VolFraction
////		CoefNames[numpnts(CoefNames)-1]="Dist2VolFraction"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist2VolLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist2VolHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist2VolLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist2VolHighLimit
////	endif
////	if (Dist2FitLocation && NumberOfDistributions>1 && (cmpstr(Dist2DistributionType,"PowerLaw")!=0))		//are we fitting distribution 2 location?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist2Location
////		CoefNames[numpnts(CoefNames)-1]="Dist2Location"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist2LocLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist2LocHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist2LocLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist2LocHighLimit
////	endif
////	if (Dist2FitScale && NumberOfDistributions>1 && (cmpstr(Dist2DistributionType,"LogNormal")==0 || cmpstr(Dist2DistributionType,"Gauss")==0))
////			//are we fitting distribution 2 scale?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist2Scale
////		CoefNames[numpnts(CoefNames)-1]="Dist2Scale"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist2ScaleLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist2ScaleHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist2ScaleLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist2ScaleHighLimit
////	endif
////	if (Dist2FitShape && NumberOfDistributions>1 && ((cmpstr(Dist2DistributionType,"LogNormal")==0) || (cmpstr(Dist2DistributionType,"PowerLaw")==0)))
////			//are we fitting distribution 2 shape?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist2Shape
////		CoefNames[numpnts(CoefNames)-1]="Dist2Shape"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist2ShapeLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist2ShapeHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist2ShapeLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist2ShapeHighLimit
////	endif
////	
////
////	if (Dist2FitScatShapeParam1 && NumberOfDistributions>1)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist2ScatShapeParam1
////		CoefNames[numpnts(CoefNames)-1]="Dist2ScatShapeParam1"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist2ScatShapeParam1LowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist2ScatShapeParam1HighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist2ScatShapeParam1LowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist2ScatShapeParam1HighLimit
////	endif
////	
////	if (Dist2FitScatShapeParam2 && NumberOfDistributions>1)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist2ScatShapeParam2
////		CoefNames[numpnts(CoefNames)-1]="Dist2ScatShapeParam2"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist2ScatShapeParam2LowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist2ScatShapeParam2HighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist2ScatShapeParam2LowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist2ScatShapeParam2HighLimit
////	endif
////	
////	if (Dist2FitScatShapeParam3 && NumberOfDistributions>1)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist2ScatShapeParam3
////		CoefNames[numpnts(CoefNames)-1]="Dist2ScatShapeParam3"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist2ScatShapeParam3LowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist2ScatShapeParam3HighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist2ScatShapeParam3LowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist2ScatShapeParam3HighLimit
////	endif
////	if (Dist2FitInterferencePhi && Dist2UseInterference && UseInterference && NumberOfDistributions>1)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist2InterferencePhi
////		CoefNames[numpnts(CoefNames)-1]="Dist2InterferencePhi"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist2InterferencePhiLL)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist2InterferencePhiHL)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist2InterferencePhiLL
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist2InterferencePhiHL
////	endif
////	if (Dist2FitInterferenceETA && Dist2UseInterference && UseInterference && NumberOfDistributions>1)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist2InterferenceEta
////		CoefNames[numpnts(CoefNames)-1]="Dist2InterferenceEta"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist2InterferenceEtaLL)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist2InterferenceEtaHL)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist2InterferenceEtaLL
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist2InterferenceEtaHL
////	endif
////
//////dist 3 part	
////	if (Dist3FitVol && NumberOfDistributions>2)		//are we fitting distribution 3 volume?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist3VolFraction
////		CoefNames[numpnts(CoefNames)-1]="Dist3VolFraction"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist3VolLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist3VolHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist3VolLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist3VolHighLimit
////	endif
////	if (Dist3FitLocation && NumberOfDistributions>2 && (cmpstr(Dist3DistributionType,"PowerLaw")!=0))		//are we fitting distribution 3 location?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist3Location
////		CoefNames[numpnts(CoefNames)-1]="Dist3Location"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist3LocLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist3LocHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist3LocLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist3LocHighLimit
////	endif
////	if (Dist3FitScale && NumberOfDistributions>2 && (cmpstr(Dist3DistributionType,"LogNormal")==0 || cmpstr(Dist3DistributionType,"Gauss")==0))
////			//are we fitting distribution 3 scale?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist3Scale
////		CoefNames[numpnts(CoefNames)-1]="Dist3Scale"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist3ScaleLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist3ScaleHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist3ScaleLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist3ScaleHighLimit
////	endif
////	if (Dist3FitShape && NumberOfDistributions>2 && ((cmpstr(Dist3DistributionType,"LogNormal")==0) || (cmpstr(Dist3DistributionType,"PowerLaw")==0)))
////			//are we fitting distribution 3 shape?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist3Shape
////		CoefNames[numpnts(CoefNames)-1]="Dist3Shape"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist3ShapeLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist3ShapeHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist3ShapeLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist3ShapeHighLimit
////	endif
////
////	if (Dist3FitScatShapeParam1 && NumberOfDistributions>2)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist3ScatShapeParam1
////		CoefNames[numpnts(CoefNames)-1]="Dist3ScatShapeParam1"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist3ScatShapeParam1LowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist3ScatShapeParam1HighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist3ScatShapeParam1LowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist3ScatShapeParam1HighLimit
////	endif
////	
////	if (Dist3FitScatShapeParam2 && NumberOfDistributions>2)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist3ScatShapeParam2
////		CoefNames[numpnts(CoefNames)-1]="Dist3ScatShapeParam2"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist3ScatShapeParam2LowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist3ScatShapeParam2HighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist3ScatShapeParam2LowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist3ScatShapeParam2HighLimit
////	endif
////	
////	if (Dist3FitScatShapeParam3 && NumberOfDistributions>2)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist3ScatShapeParam3
////		CoefNames[numpnts(CoefNames)-1]="Dist3ScatShapeParam3"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist3ScatShapeParam3LowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist3ScatShapeParam3HighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist3ScatShapeParam3LowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist3ScatShapeParam3HighLimit
////	endif
////	if (Dist3FitInterferencePhi && Dist3UseInterference && UseInterference && NumberOfDistributions>2)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist3InterferencePhi
////		CoefNames[numpnts(CoefNames)-1]="Dist3InterferencePhi"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist3InterferencePhiLL)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist3InterferencePhiHL)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist3InterferencePhiLL
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist3InterferencePhiHL
////	endif
////	if (Dist3FitInterferenceETA && Dist3UseInterference && UseInterference && NumberOfDistributions>2)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist3InterferenceEta
////		CoefNames[numpnts(CoefNames)-1]="Dist3InterferenceEta"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist3InterferenceEtaLL)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist3InterferenceEtaHL)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist3InterferenceEtaLL
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist3InterferenceEtaHL
////	endif
////	
////	
//////dist 4 part	
////	if (Dist4FitVol && NumberOfDistributions>3)		//are we fitting distribution 4 volume?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist4VolFraction
////		CoefNames[numpnts(CoefNames)-1]="Dist4VolFraction"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist4VolLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist4VolHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist4VolLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist4VolHighLimit
////	endif
////	if (Dist4FitLocation && NumberOfDistributions>3 && (cmpstr(Dist4DistributionType,"PowerLaw")!=0))		//are we fitting distribution 4 location?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist4Location
////		CoefNames[numpnts(CoefNames)-1]="Dist4Location"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist4LocLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist4LocHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist4LocLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist4LocHighLimit
////	endif
////	if (Dist4FitScale && NumberOfDistributions>3 && (cmpstr(Dist4DistributionType,"LogNormal")==0 || cmpstr(Dist4DistributionType,"Gauss")==0))
////			//are we fitting distribution 4 scale?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist4Scale
////		CoefNames[numpnts(CoefNames)-1]="Dist4Scale"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist4ScaleLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist4ScaleHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist4ScaleLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist4ScaleHighLimit
////	endif
////	if (Dist4FitShape && NumberOfDistributions>3 && ((cmpstr(Dist4DistributionType,"LogNormal")==0) || (cmpstr(Dist4DistributionType,"PowerLaw")==0)))
////			//are we fitting distribution 4 shape?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist4Shape
////		CoefNames[numpnts(CoefNames)-1]="Dist4Shape"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist4ShapeLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist4ShapeHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist4ShapeLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist4ShapeHighLimit
////	endif
////
////	if (Dist4FitScatShapeParam1 && NumberOfDistributions>3)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist4ScatShapeParam1
////		CoefNames[numpnts(CoefNames)-1]="Dist4ScatShapeParam1"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist4ScatShapeParam1LowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist4ScatShapeParam1HighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist4ScatShapeParam1LowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist4ScatShapeParam1HighLimit
////	endif
////	
////	if (Dist4FitScatShapeParam2 && NumberOfDistributions>3)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist4ScatShapeParam2
////		CoefNames[numpnts(CoefNames)-1]="Dist4ScatShapeParam2"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist4ScatShapeParam2LowLimit)} 
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist4ScatShapeParam2HighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist4ScatShapeParam2LowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist4ScatShapeParam2HighLimit
////	endif
////	
////	if (Dist4FitScatShapeParam3 && NumberOfDistributions>3)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist4ScatShapeParam3
////		CoefNames[numpnts(CoefNames)-1]="Dist4ScatShapeParam3"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist4ScatShapeParam3LowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist4ScatShapeParam3HighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist4ScatShapeParam3LowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist4ScatShapeParam3HighLimit
////	endif
////	if (Dist4FitInterferencePhi && Dist4UseInterference && UseInterference && NumberOfDistributions>3)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist4InterferencePhi
////		CoefNames[numpnts(CoefNames)-1]="Dist4InterferencePhi"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist4InterferencePhiLL)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist4InterferencePhiHL)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist4InterferencePhiLL
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist4InterferencePhiHL
////	endif
////	if (Dist4FitInterferenceETA && Dist4UseInterference && UseInterference && NumberOfDistributions>3)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist4InterferenceEta
////		CoefNames[numpnts(CoefNames)-1]="Dist4InterferenceEta"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist4InterferenceEtaLL)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist4InterferenceEtaHL)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist4InterferenceEtaLL
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist4InterferenceEtaHL
////	endif
////	
////
//////dist 5 part	
////	if (Dist5FitVol && NumberOfDistributions>4)		//are we fitting distribution 1 volume?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist5VolFraction
////		CoefNames[numpnts(CoefNames)-1]="Dist5VolFraction"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist5VolLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist5VolHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist5VolLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist5VolHighLimit
////	endif
////	if (Dist5FitLocation && NumberOfDistributions>4 && (cmpstr(Dist5DistributionType,"PowerLaw")!=0))		//are we fitting distribution 1 location?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist5Location
////		CoefNames[numpnts(CoefNames)-1]="Dist5Location"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist5LocLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist5LocHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist5LocLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist5LocHighLimit
////	endif
////	if (Dist5FitScale && NumberOfDistributions>4 && (cmpstr(Dist5DistributionType,"LogNormal")==0 || cmpstr(Dist5DistributionType,"Gauss")==0))
////			//are we fitting distribution 1 scale?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist5Scale
////		CoefNames[numpnts(CoefNames)-1]="Dist5Scale"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist5ScaleLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist5ScaleHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist5ScaleLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist5ScaleHighLimit
////	endif
////	if (Dist5FitShape && NumberOfDistributions>4 && ((cmpstr(Dist5DistributionType,"LogNormal")==0) || (cmpstr(Dist5DistributionType,"PowerLaw")==0)))
////			//are we fitting distribution 1 shape?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist5Shape
////		CoefNames[numpnts(CoefNames)-1]="Dist5Shape"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist5ShapeLowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist5ShapeHighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist5ShapeLowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist5ShapeHighLimit
////	endif
////
////	if (Dist5FitScatShapeParam1 && NumberOfDistributions>4)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist5ScatShapeParam1
////		CoefNames[numpnts(CoefNames)-1]="Dist5ScatShapeParam1"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist5ScatShapeParam1LowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist5ScatShapeParam1HighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist5ScatShapeParam1LowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist5ScatShapeParam1HighLimit
////	endif
////	
////	if (Dist5FitScatShapeParam2 && NumberOfDistributions>4)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist5ScatShapeParam2
////		CoefNames[numpnts(CoefNames)-1]="Dist5ScatShapeParam2"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist5ScatShapeParam2LowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist5ScatShapeParam2HighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist5ScatShapeParam2LowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist5ScatShapeParam2HighLimit
////	endif
////	
////	if (Dist5FitScatShapeParam3 && NumberOfDistributions>4)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist5ScatShapeParam3
////		CoefNames[numpnts(CoefNames)-1]="Dist5ScatShapeParam3"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist5ScatShapeParam3LowLimit)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist5ScatShapeParam3HighLimit)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist5ScatShapeParam3LowLimit
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist5ScatShapeParam3HighLimit
////	endif
////	if (Dist5FitInterferencePhi && Dist5UseInterference && UseInterference && NumberOfDistributions>4)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist5InterferencePhi
////		CoefNames[numpnts(CoefNames)-1]="Dist5InterferencePhi"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist5InterferencePhiLL)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist5InterferencePhiHL)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist5InterferencePhiLL
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist5InterferencePhiHL
////	endif
////	if (Dist5FitInterferenceETA && Dist5UseInterference && UseInterference && NumberOfDistributions>4)
////			//are we fitting distribution 1 scatterer shape parameter?
////		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
////		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
////		W_Coef[numpnts(W_Coef)-1]=Dist5InterferenceEta
////		CoefNames[numpnts(CoefNames)-1]="Dist5InterferenceEta"
////		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist5InterferenceEtaLL)}
////		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist5InterferenceEtaHL)}		
////		Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
////		Gen_Constraints[numpnts(CoefNames)-1][0] = Dist5InterferenceEtaLL
////		Gen_Constraints[numpnts(CoefNames)-1][1] = Dist5InterferenceEtaHL
////	endif
////	
////
////
////	
////	IR1S_ResetErrors()
////	DoWindow /F IR1_LogLogPlot
////	Wave OriginalQvector
////	Wave OriginalIntensity
////	Wave OriginalError	
////	
////	Variable V_chisq
////	Duplicate/O W_Coef, E_wave, CoefficientInput
////	E_wave=W_coef/20
////
////	IR1S_RecordResults("before")
////	
////		NVAR/Z UseLSQF = root:Packages:SAS_Modeling:UseLSQF 
////		NVAR/Z UseGenOpt = root:Packages:SAS_Modeling:UseGenOpt 
////		if(!NVAR_Exists(UseGenOpt))
////			variable/g UseGenOpt
////			variable/g UseLSQF
////			UseLSQF=1
////			UseGenOpt=0
////		endif
////		variable i
////		string HoldStr=""
////		For(i=0;i<numpnts(W_Coef);i+=1)
////			HoldStr+="0"
////		endfor
////	if(UseGenOpt)	//check the limits, for GenOpt the ratio between min and max should not be too high
//////		string Warning
//////		For(i=0;i<DimSize(Gen_Constraints, 0);i+=1)
//////			if(Gen_Constraints[i][1]/Gen_Constraints[i][0] >5)
//////				Warning="For Genetic Optimization the range of limits should be as small as possible. For "+  CoefNames[i]
//////				Warning+=" the range of limits is more than 5, that is likely too high. Continue?"
//////				DoAlert 1, Warning
//////				if (V_Flag==2)
//////					abort
//////				else
//////					break
//////				endif
//////			endif
//////		
//////		endfor
////		IR1S_CheckFittingParamsFnct()
////		PauseForUser IR1S_CheckFittingParams
////		NVAR UserCanceled=root:Packages:SAS_Modeling:UserCanceled
////		if (UserCanceled)
////			setDataFolder OldDf
////			abort
////		endif
////	endif
////
////	Variable V_FitError=0			//This should prevent errors from being generated
////	//and now the fit...
////	if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
////		//check that cursors are actually on hte right wave...
//////		if (cmpstr(CsrWave(A, "IR1_LogLogPlotLSQF"),"OriginalIntensity")!=0)
//////			Cursor /W=IR1_LogLogPlotLSQF A  OriginalIntensity  xcsr(A, "IR1_LogLogPlotLSQF")
//////		endif
//////		if (cmpstr(CsrWave(B, "IR1_LogLogPlotLSQF"),"OriginalIntensity")!=0)
//////			Cursor /W=IR1_LogLogPlotLSQF B  OriginalIntensity  xcsr(B, "IR1_LogLogPlotLSQF")
//////		endif
////		//make sure the cursors are on the right waves..
////		if (cmpstr(CsrWave(A, "IR1_LogLogPlotLSQF"),"OriginalIntensity")!=0)
////			Cursor/P/W=IR1_LogLogPlotLSQF A  OriginalIntensity  binarysearch(OriginalQvector, CsrXWaveRef(A) [pcsr(A, "IR1_LogLogPlotLSQF")])
////		endif
////		if (cmpstr(CsrWave(B, "IR1_LogLogPlotLSQF"),"IntensityOriginal")!=0)
////			Cursor/P /W=IR1_LogLogPlotLSQF B  OriginalIntensity  binarysearch(OriginalQvector,CsrXWaveRef(B) [pcsr(B, "IR1_LogLogPlotLSQF")])
////		endif
////		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalIntensity, FitIntensityWave		
////		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalQvector, FitQvectorWave
////		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalError, FitErrorWave
////		if(UseLSQF)
////			FuncFit /N/Q IR1_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /D /C=T_Constraints 
////		else
////			Duplicate/O FitIntensityWave, GenMaskWv
////			GenMaskWv=1 	
////#if Exists("gencurvefit")
////	  	gencurvefit  /I=1 /W=FitErrorWave /M=GenMaskWv /N /TOL=0.002 /K={50,20,0.7,0.5} /X=FitQvectorWave IR1_FitFunction, FitIntensityWave  , W_Coef, HoldStr, Gen_Constraints  	
//////		print "xop code"
////#else
//////	  	GEN_curvefit("IR1_FitFunction",W_Coef,FitIntensityWave,HoldStr,x=FitQvectorWave,w=FitErrorWave,c=Gen_Constraints,mask=GenMaskWv, popsize=20,k_m=0.7,recomb=0.5,iters=50,tol=0.002)	
//////		print "Old code"
////		Abort  "Genetic Optimization xop NOT installed. Install xop support and then try again"
////#endif
////		endif
////	else
////		Duplicate/O OriginalIntensity, FitIntensityWave		
////		Duplicate/O OriginalQvector, FitQvectorWave
////		Duplicate/O OriginalError, FitErrorWave
////		if(UseLSQF)
////			FuncFit /N/Q IR1_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D /C=T_Constraints	
////		else
////			Duplicate/O FitIntensityWave, GenMaskWv
////			GenMaskWv=1	
////#if Exists("gencurvefit")
////	  	gencurvefit  /I=1 /W=FitErrorWave /M=GenMaskWv /N /TOL=0.002 /K={50,20,0.7,0.5} /X=FitQvectorWave IR1_FitFunction, FitIntensityWave  , W_Coef, HoldStr, Gen_Constraints  	
//////		print "xop code"
////#else
//////	  	GEN_curvefit("IR1_FitFunction",W_Coef,FitIntensityWave,HoldStr,x=FitQvectorWave,w=FitErrorWave,c=Gen_Constraints,mask=GenMaskWv, popsize=20,k_m=0.7,recomb=0.5,iters=50,tol=0.002)	
//////		print "Old code"
////		Abort "Genetic Optimization xop NOT installed. Install xop support and then try again"
////#endif
////		endif
////	endif
////	if (V_FitError!=0)	//there was error in fitting
////		IR1S_ResetParamsAfterBadFit()
////		Abort "Fitting error, check starting parameters and fitting limits" 
////	endif
////	//this now records the errors for fitted parameters into the appropriate variables
////	Wave/Z W_sigma=root:Packages:SAS_Modeling:W_sigma
////	
////	string OneErrorName
////	For(i=0;i<(numpnts(CoefNames));i+=1)
////		OneErrorName="root:Packages:SAS_Modeling:"+CoefNames[i]+"Error"
////		NVAR Error=$(OneErrorName)
////		if(WaveExists(W_sigma))
////			Error=W_sigma[i]
////		else
////			Error=0
////		endif
////	endfor
////	
////	variable/g AchievedChisq=V_chisq
////	IR1_GraphModelData()
////	IR1S_RecordResults("after")
////	DoWIndow/F IR1S_ControlPanel
////	IR1S_FixTabsInPanel()
////		
////	KillWaves/Z T_Constraints, E_wave
////	
////	setDataFolder OldDF
////end
//////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1S_CheckFittingParamsFnct() 
////	PauseUpdate; Silent 1		// building window...
//	NewPanel /K=1/W=(400,140,870,600) as "Check fitting parameters"
//	Dowindow/C IR1S_CheckFittingParams
//	SetDrawLayer UserBack
//	SetDrawEnv fsize= 20,fstyle= 3,textrgb= (0,0,65280)
//	DrawText 39,28,"Modeling I Fit Params & Limits"
//		SetDrawEnv fstyle= 1,fsize= 14
//		DrawText 10,50,"For Gen Opt. verify fitted parameters. Make sure"
//		SetDrawEnv fstyle= 1,fsize= 14
//		DrawText 10,70,"the parameter range is appropriate."
//		SetDrawEnv fstyle= 1,fsize= 14
//		DrawText 10,90,"The whole range must be valid! It will be tested!"
//		SetDrawEnv fstyle= 1,fsize= 14
//		DrawText 10,110,"       Then continue....."
//	Button CancelBtn,pos={27,420},size={150,20},proc=IR1S_CheckFitPrmsButtonProc,title="Cancel fitting"
//	Button ContinueBtn,pos={187,420},size={150,20},proc=IR1S_CheckFitPrmsButtonProc,title="Continue fitting"
//	String fldrSav0= GetDataFolder(1)
//	SetDataFolder root:Packages:SAS_Modeling:
//	Wave Gen_Constraints,W_coef
//	Wave/T CoefNames
//	SetDimLabel 1,0,Min,Gen_Constraints
//	SetDimLabel 1,1,Max,Gen_Constraints
//	variable i
//	For(i=0;i<numpnts(CoefNames);i+=1)
//		SetDimLabel 0,i,$(CoefNames[i]),Gen_Constraints
//	endfor
//		Edit/W=(0.05,0.25,0.95,0.865)/HOST=#  Gen_Constraints.ld,W_coef
////		ModifyTable format(Point)=1,width(Point)=0, width(Gen_Constraints)=110
////		ModifyTable alignment(W_coef)=1,sigDigits(W_coef)=4,title(W_coef)="Curent value"
////		ModifyTable alignment(Gen_Constraints)=1,sigDigits(Gen_Constraints)=4,title(Gen_Constraints)="Limits"
////		ModifyTable statsArea=85
//		ModifyTable format(Point)=1,width(Point)=0,alignment(W_coef.y)=1,sigDigits(W_coef.y)=4
//		ModifyTable width(W_coef.y)=90,title(W_coef.y)="Start value",width(Gen_Constraints.l)=172
////		ModifyTable title[1]="Min"
////		ModifyTable title[2]="Max"
//		ModifyTable alignment(Gen_Constraints.d)=1,sigDigits(Gen_Constraints.d)=4,width(Gen_Constraints.d)=72
//		ModifyTable title(Gen_Constraints.d)="Limits"
////		ModifyTable statsArea=85
////		ModifyTable statsArea=20
//	SetDataFolder fldrSav0
//	RenameWindow #,T0
//	SetActiveSubwindow ##
//End
//
//// Function Test()
////> Make /o /n=(5,2) myWave
////> SetDimLabel 1,0,min,myWave
////> SetDimLabel 1,1,max,myWave
////> Edit myWave.ld
////> End
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//Function IR1S_CheckFitPrmsButtonProc(ctrlName) : ButtonControl
//	String ctrlName
//	
//	if(stringmatch(ctrlName,"*CancelBtn*"))
//		variable/g root:Packages:SAS_Modeling:UserCanceled=1
//		DoWindow/K IR1S_CheckFittingParams
//	endif
//
//	if(stringmatch(ctrlName,"*ContinueBtn*"))
//		variable/g root:Packages:SAS_Modeling:UserCanceled=0
//		DoWindow/K IR1S_CheckFittingParams
//	endif
//
//End
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//Function IR1_FitSmearLSQFData()
//
//	string OldDf=GetDataFolder(1)
//	setDataFolder root:Packages:SAS_Modeling
//	Wave FitModelQvector
//	Wave FitDistModelIntensity
//	Wave FitDistModelIQ4
//	Duplicate/O FitDistModelIntensity, SmearedDistModelIntensity
//
//	NVAR UseSlitSmearedData=root:Packages:SAS_Modeling:UseSlitSmearedData
//	if(UseSlitSmearedData)
//		NVAR SLitLength=root:Packages:SAS_Modeling:SlitLength
//		IR1B_SmearData(FitDistModelIntensity, FitModelQvector, slitLength, SmearedDistModelIntensity)
//	endif
//	FitDistModelIntensity=SmearedDistModelIntensity
//	KillWaves/Z SmearedDistModelIntensity
//	
//	FitDistModelIQ4=FitDistModelIntensity*FitModelQvector^4
//
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//
//Function IR1S_ResetParamsAfterBadFit()
//
//	Wave/Z w=root:Packages:SAS_Modeling:CoefficientInput		//thsi should have the original parameters...
//	Wave/T/Z CoefNames=root:Packages:SAS_Modeling:CoefNames		//text wave with names of parameters
//
//	if ((!WaveExists(w)) || (!WaveExists(CoefNames)))
//		abort
//	endif
//
//	NVAR SASBackground=root:Packages:SAS_Modeling:SASBackground
//	NVAR FitSASBackground=root:Packages:SAS_Modeling:FitSASBackground
//	variable i, NumOfParam
//	NumOfParam=numpnts(CoefNames)
//	string ParamName=""
//	
//	for (i=0;i<NumOfParam;i+=1)
//		ParamName=CoefNames[i]
//		NVAR TempParam=$(ParamName)
//		TempParam=w[i]
//	endfor
//	DoWIndow/F IR1S_ControlPanel
//	IR1S_FixTabsInPanel()
//
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
////this is specialized version of Calculate model intensity
//Function IR1_FitCalculateModelIntensity(MyQvectorWave)
//	Wave MyQvectorWave
//	
//	string OldDf=GetDataFolder(1)
//	setDataFolder root:Packages:SAS_Modeling
//	
//	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
//	
//	Duplicate/O MyQvectorWave, FitModelQvector, FitDistModelIntensity, FitDistModelIQ4
//	Redimension/D  FitModelQvector, FitDistModelIntensity, FitDistModelIQ4
//	FitDistModelIntensity=0	
//
//	variable i
//	
//	For(i=1;i<=NumberOfDistributions;i+=1)
////		IR1_FitCalcIntFromOneDist(i, FitModelQvector)
//		IR1_CalcIntFromOneDist(i, FitModelQvector)
//	endfor
//	//OK, now we have calculated intensities, lets sum them together
//
//	For(i=1;i<=NumberOfDistributions;i+=1)
//		Wave IntToAdd=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ModelIntensity")
//		FitDistModelIntensity+=IntToAdd
//	endfor
//	
//	//add background here:
//	NVAR SASBackground=root:Packages:SAS_Modeling:SASBackground
//	FitDistModelIntensity+=SASBackground
//	
//	FitDistModelIQ4=FitDistModelIntensity*FitModelQvector^4
//	
//	setDataFolder OldDF
//end
//
////*************************************************************************************************
////*************************************************************************************************
////*************************************************************************************************
////*************************************************************************************************
//
////Function IR1_FitCalcIntFromOneDist(DistNum, FitModelQvector)
////	variable DistNum
////	Wave FitModelQvector
////	
////	string OldDf
////	OldDf=getDataFolder(1)
////	setDataFolder root:Packages:SAS_Modeling
////	
////	Wave Distdiameters=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Diameters")
////	Wave DistNumberDist=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NumberDist")
////	SVAR ShapeType=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ShapeModel")
////	NVAR Param1=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam1")
////	NVAR Param2=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam2")
////	NVAR Param3=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam3")
////	NVAR DistContrast=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Contrast")
////	
////	string tempName="Dist"+num2str(DistNum)+"ModelIntensity"
////	Duplicate/O OriginalQvector, $tempName
////	Wave DistModelIntensity=$tempName
////	Redimension/D DistModelIntensity
////	IR1_CalcIntensityInterStep(DistModelIntensity, DistDiameters, OriginalQvector, DistNumberDist,ShapeType, Param1, Param2, Param3 )
////	
////	DistModelIntensity*=DistContrast*1e20		//this multiplies by scattering contrast
////	
////	//Interference, if needed
////	NVAR UseInterference = root:Packages:SAS_Modeling:UseInterference
////	NVAR DistUseInterference=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UseInterference")
////	if (UseInterference && DistUseInterference)
////		NVAR Phi = $("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"InterferencePhi")
////		NVAR Eta = $("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"InterferenceEta")
//////interference		 Int(q, with interference) =Int(q)*(1-8*phi*spherefactor(q,eta))
////		DistModelIntensity /= (1+phi*IR1A_SphereAmplitude(FitModelQvector[p],Eta))
////	endif
////
////	setDataFolder OldDf
////
////end
////
////
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
