#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.01

//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.01 added license for ANL


//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from www.uni.aps.anl.gov/~ilavsky
//this package contains 
// Igor functions for modeling of SAS from various distributions of scatterers...

//Jan Ilavsky, March 2002

//please, read Readme in the distribution zip file with more details on the program
//report any problems to: ilavsky@aps.anl.gov


//main functions for modeling with user input of distributions...

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_LSQF_UserModelsMain()
	
	IN2G_CheckScreenSize("height",670)

	DoWindow IR1_LogLogPlotLSQF
	if (V_Flag)
		DoWindow/K IR1_LogLogPlotLSQF	
	endif
	DoWindow IR1_IQ4_Q_PlotLSQF
	if (V_Flag)
		DoWindow/K IR1_IQ4_Q_PlotLSQF	
	endif
	DoWindow IR1_Model_Distributions
	if (V_Flag)
		DoWindow/K IR1_Model_Distributions	
	endif
	DoWindow IR1U_ControlPanel
	if (V_Flag)
		DoWindow/K IR1U_ControlPanel	
	endif
	IR1T_InitFormFactors()
	IR1U_Initialize()					//this may be OK now... 
//	IR1_KillGraphsAndPanels()
	Execute ("IR1U_ControlPanel()")
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1U_Initialize()
	//function, which creates the folder for SAS modeling and creates the strings and variables
	
	string oldDf=GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewdataFolder/O/S root:Packages:SAS_Modeling
	
	string ListOfVariables
	string ListOfStrings
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="UseIndra2Data;UseQRSData;NumberOfDistributions;DisplayVD;DisplayND;CurrentTab;"
	ListOfVariables+="SASBackground;SASBackgroundStep;FitSASBackground;UseNumberDistribution;UseVolumeDistribution;UpdateAutomatically;"

	ListOfVariables+="Dist1Contrast;Dist1DiamMultiplier;Dist1DiamAddition;Dist1Mean;Dist1Median;Dist1Mode;Dist1FWHM;Dist1DMHighLimit;Dist1DMLowLimit;Dist1VolFractUserInput;"
	ListOfVariables+="Dist1DAHighLimit;Dist1DALowLimit;Dist1DMStep;Dist1DAStep;Dist1FitDM;Dist1FitDA;Dist1VolFraction;Dist1InputRadii;Dist1InputNumberDist;"
	ListOfVariables+="Dist1VolHighLimit;Dist1VolLowLimit;Dist1FitVol;Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3;Dist1VolStep;"
	ListOfVariables+="Dist2Contrast;Dist2DiamMultiplier;Dist2DiamAddition;Dist2Mean;Dist2Median;Dist2Mode;Dist2FWHM;Dist2DMHighLimit;Dist2DMLowLimit;Dist2VolFractUserInput;"
	ListOfVariables+="Dist2DAHighLimit;Dist2DALowLimit;Dist2DMStep;Dist2DAStep;Dist2FitDM;Dist2FitDA;Dist2VolFraction;Dist2InputRadii;Dist2InputNumberDist;"
	ListOfVariables+="Dist2VolHighLimit;Dist2VolLowLimit;Dist2FitVol;Dist2ScatShapeParam1;Dist2ScatShapeParam2;Dist2ScatShapeParam3;Dist2VolStep;"
	ListOfVariables+="Dist3Contrast;Dist3DiamMultiplier;Dist3DiamAddition;Dist3Mean;Dist3Median;Dist3Mode;Dist3FWHM;Dist3DMHighLimit;Dist3DMLowLimit;Dist3VolFractUserInput;"
	ListOfVariables+="Dist3DAHighLimit;Dist3DALowLimit;Dist3DMStep;Dist3DAStep;Dist3FitDM;Dist3FitDA;Dist3VolFraction;Dist3InputRadii;Dist3InputNumberDist;"
	ListOfVariables+="Dist3VolHighLimit;Dist3VolLowLimit;Dist3FitVol;Dist3ScatShapeParam1;Dist3ScatShapeParam2;Dist3ScatShapeParam3;Dist3VolStep;"
	ListOfVariables+="Dist4Contrast;Dist4DiamMultiplier;Dist4DiamAddition;Dist4Mean;Dist4Median;Dist4Mode;Dist4FWHM;Dist4DMHighLimit;Dist4DMLowLimit;Dist4VolFractUserInput;"
	ListOfVariables+="Dist4DAHighLimit;Dist4DALowLimit;Dist4DMStep;Dist4DAStep;Dist4FitDM;Dist4FitDA;Dist4VolFraction;Dist4InputRadii;Dist4InputNumberDist;"
	ListOfVariables+="Dist4VolHighLimit;Dist4VolLowLimit;Dist4FitVol;Dist4ScatShapeParam1;Dist4ScatShapeParam2;Dist4ScatShapeParam3;Dist4VolStep;"
	ListOfVariables+="Dist5Contrast;Dist5DiamMultiplier;Dist5DiamAddition;Dist5Mean;Dist5Median;Dist5Mode;Dist5FWHM;Dist5DMHighLimit;Dist5DMLowLimit;Dist5VolFractUserInput;"
	ListOfVariables+="Dist5DAHighLimit;Dist5DALowLimit;Dist5DMStep;Dist5DAStep;Dist5FitDM;Dist5FitDA;Dist5VolFraction;Dist5InputRadii;Dist5InputNumberDist;"
	ListOfVariables+="Dist5VolHighLimit;Dist5VolLowLimit;Dist5FitVol;Dist5ScatShapeParam1;Dist5ScatShapeParam2;Dist5ScatShapeParam3;Dist5VolStep;"
	ListOfVariables+="Dist1FitScatShapeParam1;Dist1ScatShapeParam1LowLimit;Dist1ScatShapeParam1HighLimit;Dist1FitScatShapeParam2;Dist1ScatShapeParam2LowLimit;Dist1ScatShapeParam2HighLimit;Dist1FitScatShapeParam3;Dist1ScatShapeParam3LowLimit;Dist1ScatShapeParam3HighLimit;"
	ListOfVariables+="Dist2FitScatShapeParam1;Dist2ScatShapeParam1LowLimit;Dist2ScatShapeParam1HighLimit;Dist2FitScatShapeParam2;Dist2ScatShapeParam2LowLimit;Dist2ScatShapeParam2HighLimit;Dist2FitScatShapeParam3;Dist2ScatShapeParam3LowLimit;Dist2ScatShapeParam3HighLimit;"
	ListOfVariables+="Dist3FitScatShapeParam1;Dist3ScatShapeParam1LowLimit;Dist3ScatShapeParam1HighLimit;Dist3FitScatShapeParam2;Dist3ScatShapeParam2LowLimit;Dist3ScatShapeParam2HighLimit;Dist3FitScatShapeParam3;Dist3ScatShapeParam3LowLimit;Dist3ScatShapeParam3HighLimit;"
	ListOfVariables+="Dist4FitScatShapeParam1;Dist4ScatShapeParam1LowLimit;Dist4ScatShapeParam1HighLimit;Dist4FitScatShapeParam2;Dist4ScatShapeParam2LowLimit;Dist4ScatShapeParam2HighLimit;Dist4FitScatShapeParam3;Dist4ScatShapeParam3LowLimit;Dist4ScatShapeParam3HighLimit;"
	ListOfVariables+="Dist5FitScatShapeParam1;Dist5ScatShapeParam1LowLimit;Dist5ScatShapeParam1HighLimit;Dist5FitScatShapeParam2;Dist5ScatShapeParam2LowLimit;Dist5ScatShapeParam2HighLimit;Dist5FitScatShapeParam3;Dist5ScatShapeParam3LowLimit;Dist5ScatShapeParam3HighLimit;"
	ListOfVariables+="Dist1ScatShapeParam4;Dist1ScatShapeParam5;"
	ListOfVariables+="Dist2ScatShapeParam4;Dist2ScatShapeParam5;"
	ListOfVariables+="Dist3ScatShapeParam4;Dist3ScatShapeParam5;"
	ListOfVariables+="Dist4ScatShapeParam4;Dist4ScatShapeParam5;"
	ListOfVariables+="Dist5ScatShapeParam4;Dist5ScatShapeParam5;"
	ListOfVariables+="Dist1ScatShapeParam1Error;Dist1ScatShapeParam2Error;Dist1ScatShapeParam3Error;"
	ListOfVariables+="Dist2ScatShapeParam1Error;Dist2ScatShapeParam2Error;Dist2ScatShapeParam3Error;"
	ListOfVariables+="Dist3ScatShapeParam1Error;Dist3ScatShapeParam2Error;Dist3ScatShapeParam3Error;"
	ListOfVariables+="Dist4ScatShapeParam1Error;Dist4ScatShapeParam2Error;Dist4ScatShapeParam3Error;"
	ListOfVariables+="Dist5ScatShapeParam1Error;Dist5ScatShapeParam2Error;Dist5ScatShapeParam3Error;WallThicknessSpreadInFract;"
	ListOfVariables+="Dist1UserFFParam1;Dist1UserFFParam2;Dist1UserFFParam3;Dist1UserFFParam4;Dist1UserFFParam5;"
	ListOfVariables+="Dist2UserFFParam1;Dist2UserFFParam2;Dist2UserFFParam3;Dist2UserFFParam4;Dist2UserFFParam5;"
	ListOfVariables+="Dist3UserFFParam1;Dist3UserFFParam2;Dist3UserFFParam3;Dist3UserFFParam4;Dist3UserFFParam5;"
	ListOfVariables+="Dist4UserFFParam1;Dist4UserFFParam2;Dist4UserFFParam3;Dist4UserFFParam4;Dist4UserFFParam5;"
	ListOfVariables+="Dist5UserFFParam1;Dist5UserFFParam2;Dist5UserFFParam3;Dist5UserFFParam4;Dist5UserFFParam5;"


	//comment
	//Dist1InputRadii 			== 0 if Diameters, 1 if radii
	//Dist1InputNumberDist		== 0 if volume distribution, 1 if number distribution

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	ListOfStrings+="Dist1ShapeModel;Dist1FolderName;Dist1DiameterWvNm;Dist1ProbabilityWvNm;"
	ListOfStrings+="Dist2ShapeModel;Dist2FolderName;Dist2DiameterWvNm;Dist2ProbabilityWvNm;"
	ListOfStrings+="Dist3ShapeModel;Dist3FolderName;Dist3DiameterWvNm;Dist3ProbabilityWvNm;"
	ListOfStrings+="Dist4ShapeModel;Dist4FolderName;Dist4DiameterWvNm;Dist4ProbabilityWvNm;"
	ListOfStrings+="Dist5ShapeModel;Dist5FolderName;Dist5DiameterWvNm;Dist5ProbabilityWvNm;"
	ListOfStrings+="Dist1UserVolumeFnct;Dist2UserVolumeFnct;Dist3UserVolumeFnct;Dist4UserVolumeFnct;Dist5UserVolumeFnct;"
	ListOfStrings+="Dist1UserFormFactorFnct;Dist2UserFormFactorFnct;Dist3UserFormFactorFnct;Dist4UserFormFactorFnct;Dist5UserFormFactorFnct;"
	
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	//cleanup after possible previous fitting stages...
	Wave/Z CoefNames=root:Packages:SAS_Modeling:CoefNames
	Wave/Z CoefficientInput=root:Packages:SAS_Modeling:CoefficientInput
	KillWaves/Z CoefNames, CoefficientInput
	
	Execute ("IR1U_SetInitialValues()")										
end

Proc IR1U_SetInitialValues()
	//and here set default values...

	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling
	
//	UseIndra2Data=1		//by default, asume we have Indra 2 data structure and so we can use our waves naming convention
	if (UseQRSData)
		UseIndra2Data=0
	endif

	NumberOfDistributions=0
	DisplayND=0
	DisplayVD=1
	
	if (FitSASBackground==0)
		FitSASBackground=1
	endif
	if (SASBackgroundStep==0)
		SASBackgroundStep=0.1
	endif
	
	
	if (UseNumberDistribution+UseVolumeDistribution!=1)
		 UseNumberDistribution=1
		 UseVolumeDistribution=0
	endif
	
	UpdateAutomatically=0

	//and here we set distribution specific parameters....
	
	IR1U_SetInitialValuesForAdist(1)	//dist 1
	IR1U_SetInitialValuesForAdist(2)	//dist 2
	IR1U_SetInitialValuesForAdist(3)	//dist 3
	IR1U_SetInitialValuesForAdist(4)	//dist 4
	IR1U_SetInitialValuesForAdist(5)	//dist 5
end	

Proc IR1U_SetInitialValuesForAdist(distNum)
	variable distNum
	//default values for distribution 1
	string OldDf=GetDataFolder(1)
	
	setDataFOlder root:Packages:SAS_Modeling


	if ($("Dist"+num2str(distNum)+"ScatShapeParam1")==0)
		 $("Dist"+num2str(distNum)+"ScatShapeParam1")=1
	endif
	if ($("Dist"+num2str(distNum)+"ScatShapeParam2")==0)
		 $("Dist"+num2str(distNum)+"ScatShapeParam2")=1
	endif
	if ($("Dist"+num2str(distNum)+"ScatShapeParam3")==0)
		 $("Dist"+num2str(distNum)+"ScatShapeParam3")=1
	endif
	
	if ($("Dist"+num2str(distNum)+"VolHighLimit")==0)
		 $("Dist"+num2str(distNum)+"VolHighLimit")=0.99
	endif
	if ($("Dist"+num2str(distNum)+"VolFraction")==0)
		 $("Dist"+num2str(distNum)+"VolFraction")=0.01
	endif
	if ($("Dist"+num2str(distNum)+"VolLowLimit")==0)
		 $("Dist"+num2str(distNum)+"VolLowLimit")=0.01
	endif
	if ($("Dist"+num2str(distNum)+"VolStep")==0)
		 $("Dist"+num2str(distNum)+"VolStep")=0.01
	endif
	if ($("Dist"+num2str(distNum)+"FitVol")==0)
		 $("Dist"+num2str(distNum)+"FitVol")=1
	endif
	
	if ($("Dist"+num2str(distNum)+"FitDM")==0)
		 $("Dist"+num2str(distNum)+"FitDM")=1
	endif
	if ($("Dist"+num2str(distNum)+"FitDA")==0)
		 $("Dist"+num2str(distNum)+"FitDA")=1
	endif
	if ($("Dist"+num2str(distNum)+"Contrast")==0)
		 $("Dist"+num2str(distNum)+"Contrast")=100
	endif
	
	if ($("Dist"+num2str(distNum)+"DiamMultiplier")==0)
		$("Dist"+num2str(distNum)+"DiamMultiplier")=1
	endif
	if ($("Dist"+num2str(distNum)+"DiamAddition")==0)
		$("Dist"+num2str(distNum)+"DiamAddition")=0
	endif

	if ($("Dist"+num2str(distNum)+"DAHighLimit")==0)
		$("Dist"+num2str(distNum)+"DAHighLimit")=100
	endif
	if ($("Dist"+num2str(distNum)+"DALowLimit")==0)
		$("Dist"+num2str(distNum)+"DALowLimit")=-100
	endif
	if ($("Dist"+num2str(distNum)+"DMHighLimit")==0)
		$("Dist"+num2str(distNum)+"DMHighLimit")=10
	endif
	if ($("Dist"+num2str(distNum)+"DMLowLimit")==0)
		$("Dist"+num2str(distNum)+"DMLowLimit")=0.1
	endif
	if ($("Dist"+num2str(distNum)+"DMStep")==0)
		$("Dist"+num2str(distNum)+"DMStep")=0.1
	endif
	if ($("Dist"+num2str(distNum)+"DAStep")==0)
		$("Dist"+num2str(distNum)+"DAStep")=1
	endif
	$("Dist"+num2str(distNum)+"ShapeModel")="spheroid"
	$("Dist"+num2str(distNum)+"FolderName")=""
	$("Dist"+num2str(distNum)+"DiameterWvNm")=""
	$("Dist"+num2str(distNum)+"ProbabilityWvNm")=""
	
	setDataFolder oldDf
end
