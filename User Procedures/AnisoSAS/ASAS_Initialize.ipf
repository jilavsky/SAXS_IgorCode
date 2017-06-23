#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.1		//modified 5 29 2005 to accept 5 populations JIL

//Herer goes initialization of ASAS macros...

Menu "Aniso SAS"
	"AnisoSAS", ASAS_GetBasicPanel()
	"AnisoSAS control pnl", ASAS_GetControlPanel()

end




Function  ASAS_GetControlPanel()
	
	if(!DataFolderExists("root:packages:AnisoSAS"))
		ASAS_Initialize()
	endif
	DoWindow ASAS_ControlPanel
	if (V_Flag)
		DoWindow/K ASAS_ControlPanel
	endif
	Execute("ASAS_ControlPanel()")
end
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

Function ASAS_GetBasicPanel()

		ASAS_Initialize()

		DoWindow ASAS_InputPanel
		if (V_Flag)
			DoWindow/K ASAS_InputPanel
		endif
		DoWindow ASAS_InputGraph
		if (V_Flag)
			DoWindow/K ASAS_InputGraph
		endif
		DoWindow ASASProbabilityGraph
		if (V_Flag)
			DoWindow/K ASASProbabilityGraph
		endif
		
		Execute("ASAS_InputPanel()")
		
		ASAS_FixControlsInPanel()

		ASAS_TabPanelControl("bla",0)	//fix the tabs...

		Execute("ASAS_ProbabilityGraph()")

end

//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

Function ASAS_Initialize()
	//here we create working folder and variables, strings and waves
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:AnisoSAS
	
	//OK, we are here, now we need to create variables
	string ListOfVariables
	ListOfVariables="Wavelength;NumberOfDirections;UseMultiplyCorrDta;UseOfFormula4;IntegrationStepsInAlpha;IntegrationStepsInOmega;DisplayAllProbabilityDist;"
	ListOfVariables+="Dir1_AlphaQ;Dir1_OmegaQ;Dir1_Background;"
	ListOfVariables+="Dir2_AlphaQ;Dir2_OmegaQ;Dir2_Background;"
	ListOfVariables+="Dir3_AlphaQ;Dir3_OmegaQ;Dir3_Background;"
	ListOfVariables+="Dir4_AlphaQ;Dir4_OmegaQ;Dir4_Background;"
	ListOfVariables+="Dir5_AlphaQ;Dir5_OmegaQ;Dir5_Background;"
	ListOfVariables+="Dir6_AlphaQ;Dir6_OmegaQ;Dir6_Background;"
	ListOfVariables+="NumberOfPopulations;Mprecision;UpdateAutomatically;DisplayPopulations;"
	ListOfVariables+="Pop1_Radius;Pop1_DeltaRho;Pop1_Beta;Pop1_VolumeFraction;Pop1_ScattererVolume;Pop1_Nee;Pop1_FWHM;Pop1_SurfaceArea;"
	ListOfVariables+="Pop1_FitRadius;Pop1_RadiusMin;Pop1_RadiusMax;Pop1_FitVolumeFraction;Pop1_VolumeFractionMin;Pop1_VolumeFractionMax;"
	ListOfVariables+="Pop1_PAlphaSteps;Pop1_BOmegaSteps;"
	ListOfVariables+="Pop1_UsePAlphaParam;Pop1_PAlphaPar1;Pop1_PAlphaPar2;Pop1_PAlphaPar3;Pop1_FitPAlphaPar1;Pop1_FitPAlphaPar2;Pop1_FitPAlphaPar3;"
	ListOfVariables+="Pop1_PAlphaPar1Min;Pop1_PAlphaPar1Max;Pop1_PAlphaPar2Min;Pop1_PAlphaPar2Max;Pop1_PAlphaPar3Min;Pop1_PAlphaPar3Max;"
	ListOfVariables+="Pop1_UseBOmegaParam;Pop1_BOmegaPar1;Pop1_BOmegaPar2;Pop1_BOmegaPar3;Pop1_FitBOmegaPar1;Pop1_FitBOmegaPar2;Pop1_FitBOmegaPar3;"
	ListOfVariables+="Pop1_BOmegaPar1Min;Pop1_BOmegaPar1Max;Pop1_BOmegaPar2Min;Pop1_BOmegaPar2Max;Pop1_BOmegaPar3Min;Pop1_BOmegaPar3Max;"
	ListOfVariables+="Pop2_Radius;Pop2_DeltaRho;Pop2_Beta;Pop2_VolumeFraction;Pop2_ScattererVolume;Pop2_Nee;Pop2_FWHM;Pop2_SurfaceArea;"
	ListOfVariables+="Pop2_FitRadius;Pop2_RadiusMin;Pop2_RadiusMax;Pop2_FitVolumeFraction;Pop2_VolumeFractionMin;Pop2_VolumeFractionMax;"
	ListOfVariables+="Pop2_PAlphaSteps;Pop2_BOmegaSteps;"
	ListOfVariables+="Pop2_UsePAlphaParam;Pop2_PAlphaPar1;Pop2_PAlphaPar2;Pop2_PAlphaPar3;Pop2_FitPAlphaPar1;Pop2_FitPAlphaPar2;Pop2_FitPAlphaPar3;"
	ListOfVariables+="Pop2_PAlphaPar1Min;Pop2_PAlphaPar1Max;Pop2_PAlphaPar2Min;Pop2_PAlphaPar2Max;Pop2_PAlphaPar3Min;Pop2_PAlphaPar3Max;"
	ListOfVariables+="Pop2_UseBOmegaParam;Pop2_BOmegaPar1;Pop2_BOmegaPar2;Pop2_BOmegaPar3;Pop2_FitBOmegaPar1;Pop2_FitBOmegaPar2;Pop2_FitBOmegaPar3;"
	ListOfVariables+="Pop2_BOmegaPar1Min;Pop2_BOmegaPar1Max;Pop2_BOmegaPar2Min;Pop2_BOmegaPar2Max;Pop2_BOmegaPar3Min;Pop2_BOmegaPar3Max;"
	ListOfVariables+="Pop3_Radius;Pop3_DeltaRho;Pop3_Beta;Pop3_VolumeFraction;Pop3_ScattererVolume;Pop3_Nee;Pop3_FWHM;Pop3_SurfaceArea;"
	ListOfVariables+="Pop3_FitRadius;Pop3_RadiusMin;Pop3_RadiusMax;Pop3_FitVolumeFraction;Pop3_VolumeFractionMin;Pop3_VolumeFractionMax;"
	ListOfVariables+="Pop3_PAlphaSteps;Pop3_BOmegaSteps;"
	ListOfVariables+="Pop3_UsePAlphaParam;Pop3_PAlphaPar1;Pop3_PAlphaPar2;Pop3_PAlphaPar3;Pop3_FitPAlphaPar1;Pop3_FitPAlphaPar2;Pop3_FitPAlphaPar3;"
	ListOfVariables+="Pop3_PAlphaPar1Min;Pop3_PAlphaPar1Max;Pop3_PAlphaPar2Min;Pop3_PAlphaPar2Max;Pop3_PAlphaPar3Min;Pop3_PAlphaPar3Max;"
	ListOfVariables+="Pop3_UseBOmegaParam;Pop3_BOmegaPar1;Pop3_BOmegaPar2;Pop3_BOmegaPar3;Pop3_FitBOmegaPar1;Pop3_FitBOmegaPar2;Pop3_FitBOmegaPar3;"
	ListOfVariables+="Pop3_BOmegaPar1Min;Pop3_BOmegaPar1Max;Pop3_BOmegaPar2Min;Pop3_BOmegaPar2Max;Pop3_BOmegaPar3Min;Pop3_BOmegaPar3Max;"
	ListOfVariables+="Pop4_Radius;Pop4_DeltaRho;Pop4_Beta;Pop4_VolumeFraction;Pop4_ScattererVolume;Pop4_Nee;Pop4_FWHM;Pop4_SurfaceArea;"
	ListOfVariables+="Pop4_FitRadius;Pop4_RadiusMin;Pop4_RadiusMax;Pop4_FitVolumeFraction;Pop4_VolumeFractionMin;Pop4_VolumeFractionMax;"
	ListOfVariables+="Pop4_PAlphaSteps;Pop4_BOmegaSteps;"
	ListOfVariables+="Pop4_UsePAlphaParam;Pop4_PAlphaPar1;Pop4_PAlphaPar2;Pop4_PAlphaPar3;Pop4_FitPAlphaPar1;Pop4_FitPAlphaPar2;Pop4_FitPAlphaPar3;"
	ListOfVariables+="Pop4_PAlphaPar1Min;Pop4_PAlphaPar1Max;Pop4_PAlphaPar2Min;Pop4_PAlphaPar2Max;Pop4_PAlphaPar3Min;Pop4_PAlphaPar3Max;"
	ListOfVariables+="Pop4_UseBOmegaParam;Pop4_BOmegaPar1;Pop4_BOmegaPar2;Pop4_BOmegaPar3;Pop4_FitBOmegaPar1;Pop4_FitBOmegaPar2;Pop4_FitBOmegaPar3;"
	ListOfVariables+="Pop4_BOmegaPar1Min;Pop4_BOmegaPar1Max;Pop4_BOmegaPar2Min;Pop4_BOmegaPar2Max;Pop4_BOmegaPar3Min;Pop4_BOmegaPar3Max;"
	ListOfVariables+="Pop5_Radius;Pop5_DeltaRho;Pop5_Beta;Pop5_VolumeFraction;Pop5_ScattererVolume;Pop5_Nee;Pop5_FWHM;Pop5_SurfaceArea;"
	ListOfVariables+="Pop5_FitRadius;Pop5_RadiusMin;Pop5_RadiusMax;Pop5_FitVolumeFraction;Pop5_VolumeFractionMin;Pop5_VolumeFractionMax;"
	ListOfVariables+="Pop5_PAlphaSteps;Pop5_BOmegaSteps;"
	ListOfVariables+="Pop5_UsePAlphaParam;Pop5_PAlphaPar1;Pop5_PAlphaPar2;Pop5_PAlphaPar3;Pop5_FitPAlphaPar1;Pop5_FitPAlphaPar2;Pop5_FitPAlphaPar3;"
	ListOfVariables+="Pop5_PAlphaPar1Min;Pop5_PAlphaPar1Max;Pop5_PAlphaPar2Min;Pop5_PAlphaPar2Max;Pop5_PAlphaPar3Min;Pop5_PAlphaPar3Max;"
	ListOfVariables+="Pop5_UseBOmegaParam;Pop5_BOmegaPar1;Pop5_BOmegaPar2;Pop5_BOmegaPar3;Pop5_FitBOmegaPar1;Pop5_FitBOmegaPar2;Pop5_FitBOmegaPar3;"
	ListOfVariables+="Pop5_BOmegaPar1Min;Pop5_BOmegaPar1Max;Pop5_BOmegaPar2Min;Pop5_BOmegaPar2Max;Pop5_BOmegaPar3Min;Pop5_BOmegaPar3Max;"

	ListOfVariables+="Ani_AnisoSelectorQ;Ani_AnisoSelectorDir;TotalSurfaceArea;"

	ListOfVariables+="Ani1_AnisoExpDataNormQ1;Ani1_AnisoExpDataNormQ2;Ani1_AnisoExpDataNormQ3;Ani1_AnisoExpDataNormQ4;Ani1_AnisoExpDataNormQ5;Ani1_AnisoExpDataNormQ6;"
	ListOfVariables+="Ani2_AnisoExpDataNormQ1;Ani2_AnisoExpDataNormQ2;Ani2_AnisoExpDataNormQ3;Ani2_AnisoExpDataNormQ4;Ani2_AnisoExpDataNormQ5;Ani2_AnisoExpDataNormQ6;"
	ListOfVariables+="Ani3_AnisoExpDataNormQ1;Ani3_AnisoExpDataNormQ2;Ani3_AnisoExpDataNormQ3;Ani3_AnisoExpDataNormQ4;Ani3_AnisoExpDataNormQ5;Ani3_AnisoExpDataNormQ6;"

	ListOfVariables+="Ani1_NumberAlphaPoints;Ani1_NumberOmegaPoints;Ani1_NumberOfQVectors;"
	ListOfVariables+="Ani1_Qvector1;Ani1_Qvector2;Ani1_Qvector3;Ani1_Qvector4;Ani1_Qvector5;Ani1_Qvector6;"
	ListOfVariables+="Ani1_AlphaFixed;Ani1_OmegaFixed;"

	ListOfVariables+="Ani2_NumberAlphaPoints;Ani2_NumberOmegaPoints;Ani2_NumberOfQVectors;"
	ListOfVariables+="Ani2_Qvector1;Ani2_Qvector2;Ani2_Qvector3;Ani2_Qvector4;Ani2_Qvector5;Ani2_Qvector6;"
	ListOfVariables+="Ani2_AlphaFixed;Ani2_OmegaFixed;"

	ListOfVariables+="Ani3_NumberAlphaPoints;Ani3_NumberOmegaPoints;Ani3_NumberOfQVectors;"
	ListOfVariables+="Ani3_Qvector1;Ani3_Qvector2;Ani3_Qvector3;Ani3_Qvector4;Ani3_Qvector5;Ani3_Qvector6;"
	ListOfVariables+="Ani3_AlphaFixed;Ani3_OmegaFixed;"

	ListOfVariables+="Pop1_UseInterference;Pop2_UseInterference;Pop3_UseInterference;Pop4_UseInterference;Pop5_UseInterference;UseInterference;"
	ListOfVariables+="Pop1_InterfETA;Pop1_InterfPack;Pop1_FitInterfETA;Pop1_InterfETAMin;Pop1_InterfETAMax;Pop1_FitInterfPack;Pop1_InterfPackMin;Pop1_InterfPackMax;"
	ListOfVariables+="Pop2_InterfETA;Pop2_InterfPack;Pop2_FitInterfETA;Pop2_InterfETAMin;Pop2_InterfETAMax;Pop2_FitInterfPack;Pop2_InterfPackMin;Pop2_InterfPackMax;"
	ListOfVariables+="Pop3_InterfETA;Pop3_InterfPack;Pop3_FitInterfETA;Pop3_InterfETAMin;Pop3_InterfETAMax;Pop3_FitInterfPack;Pop3_InterfPackMin;Pop3_InterfPackMax;"
	ListOfVariables+="Pop4_InterfETA;Pop4_InterfPack;Pop4_FitInterfETA;Pop4_InterfETAMin;Pop4_InterfETAMax;Pop4_FitInterfPack;Pop4_InterfPackMin;Pop4_InterfPackMax;"
	ListOfVariables+="Pop5_InterfETA;Pop5_InterfPack;Pop5_FitInterfETA;Pop5_InterfETAMin;Pop5_InterfETAMax;Pop5_FitInterfPack;Pop5_InterfPackMin;Pop5_InterfPackMax;"
	//size dist controls:
	ListOfVariables+="Pop1_UseTriangularDist;Pop1_UseGaussSizeDist;Pop1_GaussSDNumBins;Pop1_GaussSDFWHM;"
	ListOfVariables+="Pop2_UseTriangularDist;Pop2_UseGaussSizeDist;Pop2_GaussSDNumBins;Pop2_GaussSDFWHM;"
	ListOfVariables+="Pop3_UseTriangularDist;Pop3_UseGaussSizeDist;Pop3_GaussSDNumBins;Pop3_GaussSDFWHM;"
	ListOfVariables+="Pop4_UseTriangularDist;Pop4_UseGaussSizeDist;Pop4_GaussSDNumBins;Pop4_GaussSDFWHM;"
	ListOfVariables+="Pop5_UseTriangularDist;Pop5_UseGaussSizeDist;Pop5_GaussSDNumBins;Pop5_GaussSDFWHM;"
	
	
	variable i
	for(i=0;i<itemsInList(ListOfVariables);i+=1)
		IN2G_CreateItem("variable",StringFromList(i, ListOfVariables))	
	endfor

	string ListOfStrings
	ListOfStrings ="InputWvType;"
	ListOfStrings+="Dir1_IntWvName;Dir1_QvecWvName;Dir1_ErrorWvName;Dir1_DataFolderName;"	
	ListOfStrings+="Dir2_IntWvName;Dir2_QvecWvName;Dir2_ErrorWvName;Dir2_DataFolderName;"	
	ListOfStrings+="Dir3_IntWvName;Dir3_QvecWvName;Dir3_ErrorWvName;Dir3_DataFolderName;"	
	ListOfStrings+="Dir4_IntWvName;Dir4_QvecWvName;Dir4_ErrorWvName;Dir4_DataFolderName;"	
	ListOfStrings+="Dir5_IntWvName;Dir5_QvecWvName;Dir5_ErrorWvName;Dir5_DataFolderName;"	
	ListOfStrings+="Dir6_IntWvName;Dir6_QvecWvName;Dir6_ErrorWvName;Dir6_DataFolderName;"	
	ListOfStrings+="Ani1_AnisoExpDataFldrQ1;Ani1_AnisoExpDataIntQ1;Ani1_AnisoExpDataAngleQ1;"
	ListOfStrings+="Ani1_AnisoExpDataFldrQ2;Ani1_AnisoExpDataIntQ2;Ani1_AnisoExpDataAngleQ2;"
	ListOfStrings+="Ani1_AnisoExpDataFldrQ3;Ani1_AnisoExpDataIntQ3;Ani1_AnisoExpDataAngleQ3;"
	ListOfStrings+="Ani1_AnisoExpDataFldrQ4;Ani1_AnisoExpDataIntQ4;Ani1_AnisoExpDataAngleQ4;"
	ListOfStrings+="Ani1_AnisoExpDataFldrQ5;Ani1_AnisoExpDataIntQ5;Ani1_AnisoExpDataAngleQ5;"
	ListOfStrings+="Ani1_AnisoExpDataFldrQ6;Ani1_AnisoExpDataIntQ6;Ani1_AnisoExpDataAngleQ6;"

	ListOfStrings+="Ani2_AnisoExpDataFldrQ1;Ani2_AnisoExpDataIntQ1;Ani2_AnisoExpDataAngleQ1;"
	ListOfStrings+="Ani2_AnisoExpDataFldrQ2;Ani2_AnisoExpDataIntQ2;Ani2_AnisoExpDataAngleQ2;"
	ListOfStrings+="Ani2_AnisoExpDataFldrQ3;Ani2_AnisoExpDataIntQ3;Ani2_AnisoExpDataAngleQ3;"
	ListOfStrings+="Ani2_AnisoExpDataFldrQ4;Ani2_AnisoExpDataIntQ4;Ani2_AnisoExpDataAngleQ4;"
	ListOfStrings+="Ani2_AnisoExpDataFldrQ5;Ani2_AnisoExpDataIntQ5;Ani2_AnisoExpDataAngleQ5;"
	ListOfStrings+="Ani2_AnisoExpDataFldrQ6;Ani2_AnisoExpDataIntQ6;Ani2_AnisoExpDataAngleQ6;"
	
	ListOfStrings+="Ani3_AnisoExpDataFldrQ1;Ani3_AnisoExpDataIntQ1;Ani3_AnisoExpDataAngleQ1;"
	ListOfStrings+="Ani3_AnisoExpDataFldrQ2;Ani3_AnisoExpDataIntQ2;Ani3_AnisoExpDataAngleQ2;"
	ListOfStrings+="Ani3_AnisoExpDataFldrQ3;Ani3_AnisoExpDataIntQ3;Ani3_AnisoExpDataAngleQ3;"
	ListOfStrings+="Ani3_AnisoExpDataFldrQ4;Ani3_AnisoExpDataIntQ4;Ani3_AnisoExpDataAngleQ4;"
	ListOfStrings+="Ani3_AnisoExpDataFldrQ5;Ani3_AnisoExpDataIntQ5;Ani3_AnisoExpDataAngleQ5;"
	ListOfStrings+="Ani3_AnisoExpDataFldrQ6;Ani3_AnisoExpDataIntQ6;Ani3_AnisoExpDataAngleQ6;"

	for(i=0;i<itemsInList(ListOfStrings);i+=1)
		IN2G_CreateItem("string",StringFromList(i, ListOfStrings))	
	endfor
	
		
//	Make/O/N=330/D GammaWv  //GammaWv[1] has GammaFnct for 1+1/2, GammaWv[2] for 1+2/2 etc...
	
//	GammaWv=exp(gammln((1+(p)/2) , 1e-15)) 
	
	//NOw set  values
	
	ASAS_SetStringValue(ListOfStrings,"",1)
	SVAR InputWvType
	InputWvType="DSM"
	
	ListOfVariables="Ani1_NumberAlphaPoints;Ani1_NumberOmegaPoints;"
	ListOfVariables+="Ani2_NumberAlphaPoints;Ani2_NumberOmegaPoints;"
	ListOfVariables+="Ani3_NumberAlphaPoints;Ani3_NumberOmegaPoints;"
	ASAS_SetVariableValue(ListOfVariables,32,0)

	ListOfVariables="Ani1_NumberOfQVectors;"
	ListOfVariables+="Ani2_NumberOfQVectors;"
	ListOfVariables+="Ani3_NumberOfQVectors;"
	ASAS_SetVariableValue(ListOfVariables,0,0)
	
	ListOfVariables="Ani1_AlphaFixed;Ani1_OmegaFixed;"	//X dir uses only AlphaFixed anyway
	ASAS_SetVariableValue(ListOfVariables,0,0)		//set to 0 degrees for X direction (is it correct?)

	ListOfVariables="Ani2_AlphaFixed;Ani2_OmegaFixed;"	//Y direction, uses omega fixed
	ASAS_SetVariableValue(ListOfVariables,0,0)			//set to omega=0 deg (correct?)
	
	ListOfVariables="Ani3_AlphaFixed;Ani3_OmegaFixed;"	//Z direction, uses omegaFixed
	ASAS_SetVariableValue(ListOfVariables,90,0)			//set to omegaFixed 90 deg, correct?

	//Ok, these guys need to be 0	
	ListOfVariables="NumberOfDirections;DisplayAllProbabilityDist;"
	ListOfVariables+="NumberOfPopulations;UpdateAutomatically;"
	ListOfVariables+="Pop1_FitRadius;Pop1_FitVolumeFraction;"
	ListOfVariables+="Pop1_UsePAlphaParam;Pop1_FitPAlphaPar1;Pop1_FitPAlphaPar2;Pop1_FitPAlphaPar3;"
	ListOfVariables+="Pop1_UseBOmegaParam;Pop1_FitBOmegaPar1;Pop1_FitBOmegaPar2;Pop1_FitBOmegaPar3;"
	ListOfVariables+="Pop2_FitRadius;Pop2_FitVolumeFraction;"
	ListOfVariables+="Pop2_UsePAlphaParam;Pop2_FitPAlphaPar1;Pop2_FitPAlphaPar2;Pop2_FitPAlphaPar3;"
	ListOfVariables+="Pop2_UseBOmegaParam;Pop2_FitBOmegaPar1;Pop2_FitBOmegaPar2;Pop2_FitBOmegaPar3;"
	ListOfVariables+="Pop3_FitRadius;Pop3_FitVolumeFraction;"
	ListOfVariables+="Pop3_UsePAlphaParam;Pop3_FitPAlphaPar1;Pop3_FitPAlphaPar2;Pop3_FitPAlphaPar3;"
	ListOfVariables+="Pop3_UseBOmegaParam;Pop3_FitBOmegaPar1;Pop3_FitBOmegaPar2;Pop3_FitBOmegaPar3;"
	ListOfVariables+="Pop4_FitRadius;Pop4_FitVolumeFraction;"
	ListOfVariables+="Pop4_UsePAlphaParam;Pop4_FitPAlphaPar1;Pop4_FitPAlphaPar2;Pop4_FitPAlphaPar3;"
	ListOfVariables+="Pop4_UseBOmegaParam;Pop4_FitBOmegaPar1;Pop4_FitBOmegaPar2;Pop4_FitBOmegaPar3;"
	ListOfVariables+="Pop5_FitRadius;Pop5_FitVolumeFraction;"
	ListOfVariables+="Pop5_UsePAlphaParam;Pop5_FitPAlphaPar1;Pop5_FitPAlphaPar2;Pop5_FitPAlphaPar3;"
	ListOfVariables+="Pop5_UseBOmegaParam;Pop5_FitBOmegaPar1;Pop5_FitBOmegaPar2;Pop5_FitBOmegaPar3;"
	ListOfVariables+="Pop1_PAlphaPar3;Pop2_PAlphaPar3;Pop3_PAlphaPar3;Pop4_PAlphaPar3;Pop5_PAlphaPar3;"
	ListOfVariables+="UseInterference;Pop1_UseInterference;Pop2_UseInterference;Pop3_UseInterference;Pop4_UseInterference;Pop5_UseInterference;"
	ListOfVariables+="Pop1_InterfPack;Pop1_FitInterfETA;Pop1_InterfETAMin;Pop1_FitInterfPack;Pop1_InterfPackMin;"
	ListOfVariables+="Pop2_InterfPack;Pop2_FitInterfETA;Pop2_InterfETAMin;Pop2_FitInterfPack;Pop2_InterfPackMin;"
	ListOfVariables+="Pop3_InterfPack;Pop3_FitInterfETA;Pop3_InterfETAMin;Pop3_FitInterfPack;Pop3_InterfPackMin;"
	ListOfVariables+="Pop4_InterfPack;Pop4_FitInterfETA;Pop4_InterfETAMin;Pop4_FitInterfPack;Pop4_InterfPackMin;"
	ListOfVariables+="Pop5_InterfPack;Pop5_FitInterfETA;Pop5_InterfETAMin;Pop5_FitInterfPack;Pop5_InterfPackMin;"
	ListOfVariables+="Pop1_UseGaussSizeDist;Pop3_UseGaussSizeDist;Pop2_UseGaussSizeDist;Pop4_UseGaussSizeDist;Pop5_UseGaussSizeDist;"
	

	ASAS_SetVariableValue(ListOfVariables,0,1)

	ListOfVariables="Dir1_AlphaQ;Dir1_OmegaQ;Dir1_Background;"
	ListOfVariables+="Dir2_AlphaQ;Dir2_OmegaQ;Dir2_Background;"
	ListOfVariables+="Dir3_AlphaQ;Dir3_OmegaQ;Dir3_Background;"
	ListOfVariables+="Dir4_AlphaQ;Dir4_OmegaQ;Dir4_Background;"
	ListOfVariables+="Dir5_AlphaQ;Dir5_OmegaQ;Dir5_Background;"
	ListOfVariables+="Dir6_AlphaQ;Dir6_OmegaQ;Dir6_Background;"
	
	ASAS_SetVariableValue(ListOfVariables,0,0)
	
	//Ok, these guys need to be 0.001
	ListOfVariables="Mprecision;Pop1_VolumeFractionMin;Pop2_VolumeFractionMin;Pop3_VolumeFractionMin;Pop4_VolumeFractionMin;Pop5_VolumeFractionMin;"

	ASAS_SetVariableValue(ListOfVariables,0.001,0)

	//Ok, these guys need to be 0.1
	ListOfVariables="Pop1_VolumeFraction;Pop1_ScattererVolume;"
	ListOfVariables+="Pop2_VolumeFraction;Pop2_ScattererVolume;"
	ListOfVariables+="Pop3_VolumeFraction;Pop3_ScattererVolume;"
	ListOfVariables+="Pop4_VolumeFraction;Pop4_ScattererVolume;"
	ListOfVariables+="Pop5_VolumeFraction;Pop5_ScattererVolume;"

	ASAS_SetVariableValue(ListOfVariables,0.1,0)

	// These need to be 0.40 (40% FWHM default)
	ListOfVariables="Pop1_FWHM;Pop2_FWHM;Pop3_FWHM;Pop4_FWHM;"
	ListOfVariables+="Pop1_GaussSDFWHM;Pop2_GaussSDFWHM;Pop3_GaussSDFWHM;Pop4_GaussSDFWHM;Pop5_GaussSDFWHM;"

	ASAS_SetVariableValue(ListOfVariables,0.4,0)

	//Ok, these guys need to be 1
	ListOfVariables="Wavelength;Pop1_Beta;Pop2_Beta;Pop3_Beta;Pop4_Beta;Pop5_Beta;UseOfFormula4;"
	ListOfVariables+="Pop1_RadiusMin;Pop1_VolumeFractionMax;"
	ListOfVariables+="Pop1_PAlphaPar1;Pop1_PAlphaPar2;"
	ListOfVariables+="Pop1_PAlphaPar1Min;Pop1_PAlphaPar2Min;Pop1_PAlphaPar3Min;"
	ListOfVariables+="Pop1_BOmegaPar1;Pop1_BOmegaPar2;Pop1_BOmegaPar3;"
	ListOfVariables+="Pop1_BOmegaPar1Min;Pop1_BOmegaPar2Min;Pop1_BOmegaPar3Min;"
	ListOfVariables+="Pop2_RadiusMin;Pop2_VolumeFractionMax;"
	ListOfVariables+="Pop2_PAlphaPar1;Pop2_PAlphaPar2;"
	ListOfVariables+="Pop2_PAlphaPar1Min;Pop2_PAlphaPar2Min;Pop2_PAlphaPar3Min;"
	ListOfVariables+="Pop2_BOmegaPar1;Pop2_BOmegaPar2;Pop2_BOmegaPar3;"
	ListOfVariables+="Pop2_BOmegaPar1Min;Pop2_BOmegaPar2Min;Pop2_BOmegaPar3Min;"
	ListOfVariables+="Pop3_RadiusMin;Pop3_VolumeFractionMax;"
	ListOfVariables+="Pop3_PAlphaPar1;Pop3_PAlphaPar2;"
	ListOfVariables+="Pop3_PAlphaPar1Min;Pop3_PAlphaPar2Min;Pop3_PAlphaPar3Min;"
	ListOfVariables+="Pop3_BOmegaPar1;Pop3_BOmegaPar2;Pop3_BOmegaPar3;"
	ListOfVariables+="Pop3_BOmegaPar1Min;Pop3_BOmegaPar2Min;Pop3_BOmegaPar3Min;"
	ListOfVariables+="Pop4_RadiusMin;Pop4_VolumeFractionMax;"
	ListOfVariables+="Pop4_PAlphaPar1;Pop4_PAlphaPar2;"
	ListOfVariables+="Pop4_PAlphaPar1Min;Pop4_PAlphaPar2Min;Pop4_PAlphaPar3Min;"
	ListOfVariables+="Pop4_BOmegaPar1;Pop4_BOmegaPar2;Pop4_BOmegaPar3;"
	ListOfVariables+="Pop4_BOmegaPar1Min;Pop4_BOmegaPar2Min;Pop4_BOmegaPar3Min;"
	ListOfVariables+="Pop5_RadiusMin;Pop5_VolumeFractionMax;"
	ListOfVariables+="Pop5_PAlphaPar1;Pop5_PAlphaPar2;"
	ListOfVariables+="Pop5_PAlphaPar1Min;Pop5_PAlphaPar2Min;Pop5_PAlphaPar3Min;"
	ListOfVariables+="Pop5_BOmegaPar1;Pop5_BOmegaPar2;Pop5_BOmegaPar3;"
	ListOfVariables+="Pop5_BOmegaPar1Min;Pop5_BOmegaPar2Min;Pop5_BOmegaPar3Min;"
	ListOfVariables+="Pop1_UseTriangularDist;Pop2_UseTriangularDist;Pop3_UseTriangularDist;Pop4_UseTriangularDist;Pop5_UseTriangularDist;"

	ASAS_SetVariableValue(ListOfVariables,1,0)

	// These need to be 7 
	ListOfVariables="Pop1_GaussSDNumBins;Pop2_GaussSDNumBins;Pop3_GaussSDNumBins;Pop4_GaussSDNumBins;Pop5_GaussSDNumBins;"

	ASAS_SetVariableValue(ListOfVariables,7,0)
	
	//Ok, these guys need to be 100
	ListOfVariables="Pop1_PAlphaSteps;Pop1_BOmegaSteps;"
	ListOfVariables+="Pop1_PAlphaPar1Max;Pop1_PAlphaPar2Max;Pop1_PAlphaPar3Max;"
	ListOfVariables+="Pop1_BOmegaPar1Max;Pop1_BOmegaPar2Max;Pop1_BOmegaPar3Max;"
	ListOfVariables+="Pop2_PAlphaSteps;Pop2_BOmegaSteps;"
	ListOfVariables+="Pop2_PAlphaPar1Max;Pop2_PAlphaPar2Max;Pop2_PAlphaPar3Max;"
	ListOfVariables+="Pop2_BOmegaPar1Max;Pop2_BOmegaPar2Max;Pop2_BOmegaPar3Max;"
	ListOfVariables+="Pop3_PAlphaSteps;Pop3_BOmegaSteps;"
	ListOfVariables+="Pop3_PAlphaPar1Max;Pop3_PAlphaPar2Max;Pop3_PAlphaPar3Max;"
	ListOfVariables+="Pop3_BOmegaPar1Max;Pop3_BOmegaPar2Max;Pop3_BOmegaPar3Max;"
	ListOfVariables+="Pop4_PAlphaSteps;Pop4_BOmegaSteps;"
	ListOfVariables+="Pop4_PAlphaPar1Max;Pop4_PAlphaPar2Max;Pop4_PAlphaPar3Max;"
	ListOfVariables+="Pop4_BOmegaPar1Max;Pop4_BOmegaPar2Max;Pop4_BOmegaPar3Max;"
	ListOfVariables+="Pop5_PAlphaSteps;Pop5_BOmegaSteps;"
	ListOfVariables+="Pop5_PAlphaPar1Max;Pop5_PAlphaPar2Max;Pop5_PAlphaPar3Max;"
	ListOfVariables+="Pop5_BOmegaPar1Max;Pop5_BOmegaPar2Max;Pop5_BOmegaPar3Max;"
	ListOfVariables+="Pop1_InterfETA;"
	ListOfVariables+="Pop2_InterfETA;"
	ListOfVariables+="Pop3_InterfETA;"
	ListOfVariables+="Pop4_InterfETA;"
	ListOfVariables+="Pop5_InterfETA;"

	ASAS_SetVariableValue(ListOfVariables,100,0)

	//Ok, these guys need to be 90
	ListOfVariables="IntegrationStepsInAlpha;"

	ASAS_SetVariableValue(ListOfVariables,90,0)

	//Ok, these guys need to be 200
	ListOfVariables="IntegrationStepsInOmega;"

	ASAS_SetVariableValue(ListOfVariables,200,0)


	//Ok, these guys need to be 1000
	ListOfVariables="Pop1_Radius;Pop2_Radius;Pop3_Radius;Pop4_Radius;Pop5_Radius;"

	ASAS_SetVariableValue(ListOfVariables,1000,0)

	//Ok, these guys need to be 10000
	ListOfVariables="Pop1_RadiusMax;Pop2_RadiusMax;Pop3_RadiusMax;Pop4_RadiusMax;Pop5_RadiusMax;"

	ASAS_SetVariableValue(ListOfVariables,1000,0)

	//Ok, these guys need to be 10^11
	ListOfVariables="Pop1_DeltaRho;Pop2_DeltaRho;Pop3_DeltaRho;Pop4_DeltaRho;Pop5_DeltaRho;"

	ASAS_SetVariableValue(ListOfVariables,10^11,0)



	for (i=1;i<=5;i+=1)
		ASAS_MakeAlphaProbabilityWaves(i)
		ASAS_MakeOmegaProbabilityWaves(i)
		ASAS_NormalizeAlphaProb(i)			//normalize
		ASAS_NormalizeOmegaProb(i)		//normalize
	endfor

	
end


//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

Function ASAS_SetVariableValue(ListOfVariables,val, force)
	string ListOfVariables
	variable val, force
	
	variable i
	For (i=0;i<ItemsInList(ListOfVariables);i+=1)
		NVAR LocVar=$(StringFromList(i, ListOfVariables))
		if (force)
			LocVar=val
		else
			if(LocVar==0)
				LocVar=Val
			endif
		endif
	endfor
end



//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

Function ASAS_SetStringValue(ListOfStrings,val,force)
	string ListOfStrings, val
	variable force
	
	variable i
	For (i=0;i<ItemsInList(ListOfStrings);i+=1)
		SVAR LocStr=$(StringFromList(i, ListOfStrings))
		if (force)
			LocStr=val
		else
			if(cmpstr(LocStr,"")==0)
				LocStr=val
			endif
		endif
	endfor
end

//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 


Function ASAS_MakeAlphaProbabilityWaves(Population)
	variable Population
	
	setDataFolder root:Packages:AnisoSAS	
	variable didNotExist=0
	
		Wave/Z AlphaWv=$("Pop"+num2str(Population)+"_AlphaDist")
		if (!WaveExists(AlphaWv))
			didNotExist=1
		endif
		NVAR AlphaLength=$("Pop"+num2str(Population)+"_PAlphaSteps")
		Make/O/N=(AlphaLength) $("Pop"+num2str(Population)+"_AlphaDist")
		Wave AlphaWv=$("Pop"+num2str(Population)+"_AlphaDist")
		if (didNotExist || sum(AlphaWv, -inf, inf)==0 || numtype(sum(AlphaWv, -inf, inf))!=0)
			AlphaWv=1
		endif
		Make/O/N=(AlphaLength)/T $("Pop"+num2str(Population)+"_AlphaDistDesc")
		Wave/T AlphaDesc=$("Pop"+num2str(Population)+"_AlphaDistDesc")
		SetScale/I x 0,(pi/2),"", AlphaWv, AlphaDesc		
		AlphaDesc=num2str(  (pnt2x(AlphaDesc, p )-(pnt2x(AlphaDesc, p+1)-pnt2x(AlphaDesc, p ))/2)*(180/pi)) + " > "+num2str((pnt2x(AlphaDesc, p+1)+pnt2x(AlphaDesc, p ))*(90/pi))
end

Function ASAS_MakeOmegaProbabilityWaves(Population)
	variable Population
	setDataFolder root:Packages:AnisoSAS	
	variable didNotExist=0
		Wave/Z OmegaWv=$("Pop"+num2str(Population)+"_OmegaDist")
		if (!WaveExists(OmegaWv))
			didNotExist=1
		endif
		NVAR OmegaLength=$("Pop"+num2str(Population)+"_BOmegaSteps")
		Make/O/N=(OmegaLength) $("Pop"+num2str(Population)+"_OmegaDist")
		Wave OmegaWv=$("Pop"+num2str(Population)+"_OmegaDist")
		if (didNotExist)
			OmegaWv=1
		endif
		if (sum(OmegaWv, -inf, inf)==0 || numtype(sum(OmegaWv, -inf, inf))!=0)
			OmegaWv=1
		endif
		Make/O/N=(OmegaLength)/T $("Pop"+num2str(Population)+"_OmegaDistDesc")	
		Wave/T OmegaDesc=$("Pop"+num2str(Population)+"_OmegaDistDesc")	
		SetScale/I x 0,(2*pi),"", OmegaWv, OmegaDesc
		OmegaDesc=num2str(  (pnt2x(OmegaDesc, p )-(pnt2x(OmegaDesc, p+1)-pnt2x(OmegaDesc, p ))/2)*(180/pi)) + " > "+num2str((pnt2x(OmegaDesc, p+1)+pnt2x(OmegaDesc, p ))*(90/pi))
end

Function ASAS_NormalizeOmegaProb(Population)
	variable Population

	Wave OmegaWv=$("Pop"+num2str(Population)+"_OmegaDist")
	variable normFactor=area(OmegaWv,-inf,inf)
	OmegaWv/=normFactor
	
end


Function ASAS_NormalizeAlphaProb(Population)
	variable Population
	
	Wave AlphaWv=$("Pop"+num2str(Population)+"_AlphaDist")
//	Duplicate/O AlphaWv, tempAlphaWv
	//this does not work for x=0, where the sin(x)=0, causes singularity...
//	tempAlphaWv=AlphaWv*sin(x)
	//lets do something else here. We will increase the number of points 500x
	//and integrate this wave to get the normalization factor...
	Make/O/D/N=(500*numpnts(AlphaWv)) tempAlphaWv
	SetScale/I x 0,(pi/2),"", tempAlphaWv
	tempAlphaWv=AlphaWv(x)*sin(x)
	variable normFactor=area(tempAlphaWv,0,pi/2)
	KillWaves tempAlphaWv
	AlphaWv/=normFactor
	
end

Function ASAS_AlphaProbTable(DistNum) : Table
	variable DistNum
	SetDataFolder root:Packages:AnisoSAS:
	Edit/K=1/W=(281.25,71,536.25,533.75) $("Pop"+num2str(DistNum)+"_AlphaDistDesc"),$("Pop"+num2str(DistNum)+"_AlphaDist") as "Alpha Probability Input Table"
	DoWindow/C ASAS_AlphaProbTableT
	string LocalName1="Pop"+num2str(DistNum)+"_AlphaDistDesc"
	string LocalName2="Pop"+num2str(DistNum)+"_AlphaDist"
	Execute("ModifyTable width(Point)=24,alignment("+LocalName1+")=1,width("+LocalName1+")=104")
	Execute("ModifyTable title("+LocalName1+")=\"Angular range\",width("+LocalName2+")=99,title("+LocalName2+")=\"Fractional probability\"")
End

Function ASAS_OmegaProbTable(DistNum) : Table
	variable DistNum
	SetDataFolder root:Packages:AnisoSAS:
	string LocalName1="Pop"+num2str(DistNum)+"_OmegaDistDesc"
	string LocalName2="Pop"+num2str(DistNum)+"_OmegaDist"

	Edit/K=1/W=(281.25,71,536.25,533.75) $(LocalName1),$(LocalName2) as "Omega Probability Input Table"
	DoWindow/C ASAS_OmegaProbTableT
//	Execute("ModifyTable width(Point)=24,alignment(Pop1_OmegaDistDesc)=1,width(Pop1_OmegaDistDesc)=104")
//	Execute("ModifyTable title(Pop1_OmegaDistDesc)=\"Angular range\",width(Pop1_OmegaDist)=99,title(Pop1_OmegaDist)=\"Fractional probability\"")
	Execute("ModifyTable width(Point)=24,alignment("+LocalName1+")=1,width("+LocalName1+")=104")
	Execute("ModifyTable title("+LocalName1+")=\"Angular range\",width("+LocalName2+")=99,title("+LocalName2+")=\"Fractional probability\"")
End

//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
