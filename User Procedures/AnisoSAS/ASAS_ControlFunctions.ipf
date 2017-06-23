#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.1		//modified 5 29 2005 to accept 5 populations JIL


//here go control functions for ASAS

//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

Function ASAS_SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

//AnisoSelectionFldr	this one cannot be changed, so do not worry about it

	if (cmpstr(ctrlName,"ASASDir1AlphaQ")==0)
		//changed alpha for Direction1
	endif
	if (cmpstr(ctrlName,"ASASDir1OmegaQ")==0)
		//changed Omega for Direction1
	endif
	if (cmpstr(ctrlName,"ASASDir1Background")==0)
		//changed Background for Direction1
		ASAS_CorrectWvsForBckg()
	endif
	if (cmpstr(ctrlName,"ASASDir2AlphaQ")==0)
		//changed alpha for Direction1
	endif
	if (cmpstr(ctrlName,"ASASDir2OmegaQ")==0)
		//changed Omega for Direction1
	endif
	if (cmpstr(ctrlName,"ASASDir2Background")==0)
		//changed Background for Direction1
		ASAS_CorrectWvsForBckg()
	endif
	if (cmpstr(ctrlName,"ASASDir3AlphaQ")==0)
		//changed alpha for Direction1
	endif
	if (cmpstr(ctrlName,"ASASDir3OmegaQ")==0)
		//changed Omega for Direction1
	endif
	if (cmpstr(ctrlName,"ASASDir3Background")==0)
		//changed Background for Direction1
		ASAS_CorrectWvsForBckg()
	endif
	if (cmpstr(ctrlName,"ASASDir4AlphaQ")==0)
		//changed alpha for Direction1
	endif
	if (cmpstr(ctrlName,"ASASDir4OmegaQ")==0)
		//changed Omega for Direction1
	endif
	if (cmpstr(ctrlName,"ASASDir4Background")==0)
		//changed Background for Direction1
		ASAS_CorrectWvsForBckg()
	endif
	if (cmpstr(ctrlName,"ASASDir5AlphaQ")==0)
		//changed alpha for Direction1
	endif
	if (cmpstr(ctrlName,"ASASDir5OmegaQ")==0)
		//changed Omega for Direction1
	endif
	if (cmpstr(ctrlName,"ASASDir5Background")==0)
		//changed Background for Direction1
		ASAS_CorrectWvsForBckg()
	endif
	if (cmpstr(ctrlName,"ASASDir6AlphaQ")==0)
		//changed alpha for Direction1
	endif
	if (cmpstr(ctrlName,"ASASDir6OmegaQ")==0)
		//changed Omega for Direction1
	endif
	if (cmpstr(ctrlName,"ASASDir6Background")==0)
		//changed Background for Direction1
		ASAS_CorrectWvsForBckg()
	endif
	
//Pop1	
	if (cmpstr(ctrlName,"ASASPop1DeltaRho")==0)
		//changed Delta Rho for Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop1Beta")==0)
		//changed Beta for Direction1
		ASAS_CalcAllSurfaces()
	endif
	if (cmpstr(ctrlName,"ASASPop1Radius")==0)
		//changed Radius for Direction1
		ASAS_CalcAllSurfaces()
	endif
	if (cmpstr(ctrlName,"ASASPop1RadiusMin")==0)
		//changed Radius Min for Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop1RadiusMax")==0)
		//changed Radius for Max Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop1VolumeFraction")==0)
		//changed Radius for Direction1
		ASAS_CalcAllSurfaces()
	endif
	if (cmpstr(ctrlName,"ASASPop1VolumeFractionMin")==0)
		//changed Radius Min for Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop1VolumeFractionMax")==0)
		//changed Radius for Max Direction1
	endif

	if (cmpstr(ctrlName,"ASASPop1PAlphaPar1")==0)
		//changed Parameter 1 for Alpha distribution 1
		ASAS_MakeAlphaProbabilityWaves(1)
		ASAS_RecalculateAlpha(1)
		ASAS_NormalizeAlphaProb(1)	
	endif
	if (cmpstr(ctrlName,"ASASPop1PAlphaPar2")==0)
		//changed Paramtere 1 for ALpha distribution 1
		ASAS_MakeAlphaProbabilityWaves(1)
		ASAS_RecalculateAlpha(1)
		ASAS_NormalizeAlphaProb(1)	
	endif
	if (cmpstr(ctrlName,"ASASPop1PAlphaPar3")==0)
		//changed Paramtere 1 for ALpha distribution 1
		ASAS_MakeAlphaProbabilityWaves(1)
		ASAS_RecalculateAlpha(1)
		ASAS_NormalizeAlphaProb(1)	
	endif

	if (cmpstr(ctrlName,"ASASPop1BOmegaPar1")==0)
		//changed Parameter 1 for Omega distribution 1
		ASAS_MakeOmegaProbabilityWaves(1)
		ASAS_RecalculateOmega(1)
		ASAS_NormalizeOmegaProb(1)	
	endif
	if (cmpstr(ctrlName,"ASASPop1BOmegaPar2")==0)
		//changed Paramter 2 for Omega distribution 1
		ASAS_MakeOmegaProbabilityWaves(1)
		ASAS_RecalculateOmega(1)
		ASAS_NormalizeOmegaProb(1)	
	endif
	if (cmpstr(ctrlName,"ASASPop1BOmegaPar3")==0)
		//changed Paramtere 3 for Omega distribution 1
		ASAS_MakeOmegaProbabilityWaves(1)
		ASAS_RecalculateOmega(1)
		ASAS_NormalizeOmegaProb(1)	
	endif


//Pop2
	if (cmpstr(ctrlName,"ASASPop2DeltaRho")==0)
		//changed Delta Rho for Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop2Beta")==0)
		//changed Beta for Direction1
		ASAS_CalcAllSurfaces()
	endif
	if (cmpstr(ctrlName,"ASASPop2Radius")==0)
		//changed Radius for Direction1
		ASAS_CalcAllSurfaces()
	endif
	if (cmpstr(ctrlName,"ASASPop2RadiusMin")==0)
		//changed Radius Min for Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop2RadiusMax")==0)
		//changed Radius for Max Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop2VolumeFraction")==0)
		//changed Radius for Direction1
		ASAS_CalcAllSurfaces()
	endif
	if (cmpstr(ctrlName,"ASASPop2VolumeFractionMin")==0)
		//changed Radius Min for Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop2VolumeFractionMax")==0)
		//changed Radius for Max Direction1
	endif

	if (cmpstr(ctrlName,"ASASPop2PAlphaPar1")==0)
		//changed Paramtere 1 for ALpha distribution 2
		ASAS_MakeAlphaProbabilityWaves(2)
		ASAS_RecalculateAlpha(2)
		ASAS_NormalizeAlphaProb(2)	
	endif
	if (cmpstr(ctrlName,"ASASPop2PAlphaPar2")==0)
		//changed Paramtere 1 for ALpha distribution 2
		ASAS_MakeAlphaProbabilityWaves(2)
		ASAS_RecalculateAlpha(2)
		ASAS_NormalizeAlphaProb(2)	
	endif
	if (cmpstr(ctrlName,"ASASPop2PAlphaPar3")==0)
		//changed Paramtere 1 for ALpha distribution 2
		ASAS_MakeAlphaProbabilityWaves(2)
		ASAS_RecalculateAlpha(2)
		ASAS_NormalizeAlphaProb(2)	
	endif

	if (cmpstr(ctrlName,"ASASPop2BOmegaPar1")==0)
		//changed Parameter 1 for Omega distribution 2
		ASAS_MakeOmegaProbabilityWaves(2)
		ASAS_RecalculateOmega(2)
		ASAS_NormalizeOmegaProb(2)	
	endif
	if (cmpstr(ctrlName,"ASASPop2BOmegaPar2")==0)
		//changed Paramter 2 for Omega distribution 2
		ASAS_MakeOmegaProbabilityWaves(2)
		ASAS_RecalculateOmega(2)
		ASAS_NormalizeOmegaProb(2)	
	endif
	if (cmpstr(ctrlName,"ASASPop2BOmegaPar3")==0)
		//changed Paramtere 3 for Omega distribution 2
		ASAS_MakeOmegaProbabilityWaves(2)
		ASAS_RecalculateOmega(2)
		ASAS_NormalizeOmegaProb(2)	
	endif


//Pop3
	if (cmpstr(ctrlName,"ASASPop3DeltaRho")==0)
		//changed Delta Rho for Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop3Beta")==0)
		//changed Beta for Direction1
		ASAS_CalcAllSurfaces()
	endif
	if (cmpstr(ctrlName,"ASASPop3Radius")==0)
		//changed Radius for Direction1
		ASAS_CalcAllSurfaces()
	endif
	if (cmpstr(ctrlName,"ASASPop3RadiusMin")==0)
		//changed Radius Min for Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop3RadiusMax")==0)
		//changed Radius for Max Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop3VolumeFraction")==0)
		//changed Radius for Direction1
		ASAS_CalcAllSurfaces()
	endif
	if (cmpstr(ctrlName,"ASASPop3VolumeFractionMin")==0)
		//changed Radius Min for Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop3VolumeFractionMax")==0)
		//changed Radius for Max Direction1
	endif

	if (cmpstr(ctrlName,"ASASPop3PAlphaPar1")==0)
		//changed Paramtere 1 for ALpha distribution 3
		ASAS_MakeAlphaProbabilityWaves(3)
		ASAS_RecalculateAlpha(3)
		ASAS_NormalizeAlphaProb(3)	
	endif
	if (cmpstr(ctrlName,"ASASPop3PAlphaPar2")==0)
		//changed Paramtere 1 for ALpha distribution 3
		ASAS_MakeAlphaProbabilityWaves(3)
		ASAS_RecalculateAlpha(3)
		ASAS_NormalizeAlphaProb(3)	
	endif
	if (cmpstr(ctrlName,"ASASPop3PAlphaPar3")==0)
		//changed Paramtere 1 for ALpha distribution 3
		ASAS_MakeAlphaProbabilityWaves(3)
		ASAS_RecalculateAlpha(3)
		ASAS_NormalizeAlphaProb(3)	
	endif
	if (cmpstr(ctrlName,"ASASPop3BOmegaPar1")==0)
		//changed Parameter 1 for Omega distribution 3
		ASAS_MakeOmegaProbabilityWaves(3)
		ASAS_RecalculateOmega(3)
		ASAS_NormalizeOmegaProb(3)	
	endif
	if (cmpstr(ctrlName,"ASASPop3BOmegaPar2")==0)
		//changed Paramter 2 for Omega distribution 3
		ASAS_MakeOmegaProbabilityWaves(3)
		ASAS_RecalculateOmega(3)
		ASAS_NormalizeOmegaProb(3)	
	endif
	if (cmpstr(ctrlName,"ASASPop3BOmegaPar3")==0)
		//changed Paramtere 3 for Omega distribution 3
		ASAS_MakeOmegaProbabilityWaves(3)
		ASAS_RecalculateOmega(3)
		ASAS_NormalizeOmegaProb(3)	
	endif

//Pop4
	if (cmpstr(ctrlName,"ASASPop4DeltaRho")==0)
		//changed Delta Rho for Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop4Beta")==0)
		//changed Beta for Direction1
		ASAS_CalcAllSurfaces()
	endif
	if (cmpstr(ctrlName,"ASASPop4Radius")==0)
		//changed Radius for Direction1
		ASAS_CalcAllSurfaces()
	endif
	if (cmpstr(ctrlName,"ASASPop4RadiusMin")==0)
		//changed Radius Min for Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop4RadiusMax")==0)
		//changed Radius for Max Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop4VolumeFraction")==0)
		//changed Radius for Direction1
		ASAS_CalcAllSurfaces()
	endif
	if (cmpstr(ctrlName,"ASASPop4VolumeFractionMin")==0)
		//changed Radius Min for Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop4VolumeFractionMax")==0)
		//changed Radius for Max Direction1
	endif


	if (cmpstr(ctrlName,"ASASPop4PAlphaPar1")==0)
		//changed Paramtere 1 for ALpha distribution 4
		ASAS_MakeAlphaProbabilityWaves(4)
		ASAS_RecalculateAlpha(4)
		ASAS_NormalizeAlphaProb(4)	
	endif
	if (cmpstr(ctrlName,"ASASPop4PAlphaPar2")==0)
		//changed Paramtere 1 for ALpha distribution 4
		ASAS_MakeAlphaProbabilityWaves(4)
		ASAS_RecalculateAlpha(4)
		ASAS_NormalizeAlphaProb(4)	
	endif
	if (cmpstr(ctrlName,"ASASPop4PAlphaPar3")==0)
		//changed Paramtere 1 for ALpha distribution 4
		ASAS_MakeAlphaProbabilityWaves(4)
		ASAS_RecalculateAlpha(4)
		ASAS_NormalizeAlphaProb(4)	
	endif
	if (cmpstr(ctrlName,"ASASPop4BOmegaPar1")==0)
		//changed Parameter 1 for Omega distribution 4
		ASAS_MakeOmegaProbabilityWaves(4)
		ASAS_RecalculateOmega(4)
		ASAS_NormalizeOmegaProb(4)	
	endif
	if (cmpstr(ctrlName,"ASASPop4BOmegaPar2")==0)
		//changed Paramter 2 for Omega distribution 4
		ASAS_MakeOmegaProbabilityWaves(4)
		ASAS_RecalculateOmega(4)
		ASAS_NormalizeOmegaProb(4)	
	endif
	if (cmpstr(ctrlName,"ASASPop4BOmegaPar3")==0)
		//changed Paramtere 3 for Omega distribution 4
		ASAS_MakeOmegaProbabilityWaves(4)
		ASAS_RecalculateOmega(4)
		ASAS_NormalizeOmegaProb(4)	
	endif

//Pop5
	if (cmpstr(ctrlName,"ASASPop5DeltaRho")==0)
		//changed Delta Rho for Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop5Beta")==0)
		//changed Beta for Direction1
		ASAS_CalcAllSurfaces()
	endif
	if (cmpstr(ctrlName,"ASASPop5Radius")==0)
		//changed Radius for Direction1
		ASAS_CalcAllSurfaces()
	endif
	if (cmpstr(ctrlName,"ASASPop5RadiusMin")==0)
		//changed Radius Min for Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop5RadiusMax")==0)
		//changed Radius for Max Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop5VolumeFraction")==0)
		//changed Radius for Direction1
		ASAS_CalcAllSurfaces()
	endif
	if (cmpstr(ctrlName,"ASASPop5VolumeFractionMin")==0)
		//changed Radius Min for Direction1
	endif
	if (cmpstr(ctrlName,"ASASPop5VolumeFractionMax")==0)
		//changed Radius for Max Direction1
	endif


	if (cmpstr(ctrlName,"ASASPop5PAlphaPar1")==0)
		//changed Paramtere 1 for ALpha distribution 4
		ASAS_MakeAlphaProbabilityWaves(5)
		ASAS_RecalculateAlpha(5)
		ASAS_NormalizeAlphaProb(5)	
	endif
	if (cmpstr(ctrlName,"ASASPop5PAlphaPar2")==0)
		//changed Paramtere 1 for ALpha distribution 4
		ASAS_MakeAlphaProbabilityWaves(5)
		ASAS_RecalculateAlpha(5)
		ASAS_NormalizeAlphaProb(5)	
	endif
	if (cmpstr(ctrlName,"ASASPop5PAlphaPar3")==0)
		//changed Paramtere 1 for ALpha distribution 4
		ASAS_MakeAlphaProbabilityWaves(5)
		ASAS_RecalculateAlpha(5)
		ASAS_NormalizeAlphaProb(5)	
	endif
	if (cmpstr(ctrlName,"ASASPop5BOmegaPar1")==0)
		//changed Parameter 1 for Omega distribution 4
		ASAS_MakeOmegaProbabilityWaves(5)
		ASAS_RecalculateOmega(5)
		ASAS_NormalizeOmegaProb(5)	
	endif
	if (cmpstr(ctrlName,"ASASPop5BOmegaPar2")==0)
		//changed Paramter 2 for Omega distribution 4
		ASAS_MakeOmegaProbabilityWaves(5)
		ASAS_RecalculateOmega(5)
		ASAS_NormalizeOmegaProb(5)	
	endif
	if (cmpstr(ctrlName,"ASASPop5BOmegaPar3")==0)
		//changed Paramtere 3 for Omega distribution 4
		ASAS_MakeOmegaProbabilityWaves(5)
		ASAS_RecalculateOmega(5)
		ASAS_NormalizeOmegaProb(5)	
	endif

End

//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

Function ASAS_RecalculateAlpha(which)
	variable which
	
	NVAR Param1=$("root:Packages:AnisoSAS:Pop"+num2str(which)+"_PAlphaPar1")
	NVAR Param2=$("root:Packages:AnisoSAS:Pop"+num2str(which)+"_PAlphaPar2")
	NVAR Param3=$("root:Packages:AnisoSAS:Pop"+num2str(which)+"_PAlphaPar3")
	
	Wave AlphaDist=$("root:Packages:AnisoSAS:Pop"+num2str(which)+"_AlphaDist")
	
	
	AlphaDist=Param3+abs(cos(x-(pi*Param1/180)))^Param2
	
	
end
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

Function ASAS_RecalculateOmega(which)
	variable which
	
	NVAR Param1=$("root:Packages:AnisoSAS:Pop"+num2str(which)+"_BOmegaPar1")
	NVAR Param2=$("root:Packages:AnisoSAS:Pop"+num2str(which)+"_BOmegaPar2")
	NVAR Param3=$("root:Packages:AnisoSAS:Pop"+num2str(which)+"_BOmegaPar3")
	
	Wave OmegaDist=$("root:Packages:AnisoSAS:Pop"+num2str(which)+"_OmegaDist")
	
	
//	OmegaDist=Param3+sqrt( (sin( (x- (pi*Param1/180) )/2))^2+ (Param2*cos((x-(pi*Param1/180))/2))^2 )
	OmegaDist=Param3+abs(cos((x-(pi*Param1/180))/2))^Param2
	
	
end

//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

Function ASAS_ButtonProc(ctrlName) : ButtonControl
	String ctrlName

	if (cmpstr(ctrlName,"ASASGraphData")==0)
		//here we create log log plot and display the data in it. 
		DoWIndow ASAS_InputGraph
			if(V_Flag)
				DoWindow /K  ASAS_InputGraph
			endif
		ASAS_CopyDataLocaly()
		ASAS_GetWavelength()
		ASAS_CorrectWvsForBckg()
		ASAS_CreateDataGraph()
		ASAS_AppendWvsToGraph()
		ASAS_FixWavesMarkers()
		ASAS_FixGraphVisual()
	endif


	if (cmpstr(ctrlName,"ASASFitAnisotropy")==0)
		//here we need to call fitting routine.... 
		ASAS_FitModelToData()
		ASAS_CalcChiSquare()
		ASAS_CalcAllSurfaces()
	endif
	if (cmpstr(ctrlName,"ASASReverseFit")==0)
		//here we need to call fitting routine.... 
		ASAS_ReverseFitToData()
		ASAS_CalcAllSurfaces()
	endif

	if (cmpstr(ctrlName,"ASASSelectRangeOfData")==0)
		//here we need to select range of data to be used. 
		ASAS_SelectRangeOfData()
	endif

	if (cmpstr(ctrlName,"ASASCalcModelInt")==0)
		//here we need to calculate model intensity. 
		ASAS_CreateWvsForFitting()
		ASAS_CalcAllIntensities()
		ASAS_CalcAppendResultsToGraph()
		ASAS_CalcChiSquare()
		ASAS_CalcAllSurfaces()
	endif

	if (cmpstr(ctrlName,"ASASModelAnisotropyX")==0)
		//here we need to calculate anisotropy of the model intensity. 
		ASAS_ModelAnisotropy(1)
	endif
	if (cmpstr(ctrlName,"ASASModelAnisotropyY")==0)
		//here we need to calculate anisotropy of the model intensity. 
		ASAS_ModelAnisotropy(2)
	endif
	if (cmpstr(ctrlName,"ASASModelAnisotropyZ")==0)
		//here we need to calculate anisotropy of the model intensity. 
		ASAS_ModelAnisotropy(3)
	endif
	
	if (cmpstr(ctrlName,"Ani2CalcAlphaAniso")==0)
		//here we need to calculate anisotropy of the model intensity. 
		ASAS_CalcAlphaAnisotropy(2)
	endif
	if (cmpstr(ctrlName,"Ani3CalcAlphaAniso")==0)
		//here we need to calculate anisotropy of the model intensity. 
		ASAS_CalcAlphaAnisotropy(3)
	endif

	if (cmpstr(ctrlName,"Ani1CalcOmegaAniso")==0)
		//here we need to calculate anisotropy of the model intensity. 
		ASAS_CalcOmegaAnisotropy(1)
	endif


	if (cmpstr(ctrlName,"ASASPop1GetAlphaWave")==0)
		//here we create table of alpha distribution for user to edit. 
		ASAS_MakeAlphaProbabilityWaves(1)	//make the probability waves according to current users setting
		ASAS_AlphaProbTable(1)
		PauseForUser ASAS_AlphaProbTableT
		ASAS_NormalizeAlphaProb(1)			//normalize
	endif
	if (cmpstr(ctrlName,"ASASPop1GetOmegaWave")==0)
		//here we create table of omega distribution for user to edit. 
		ASAS_MakeOmegaProbabilityWaves(1)	//make the probability waves according to current users setting
		ASAS_OmegaProbTable(1)
		PauseForUser ASAS_OmegaProbTableT
		ASAS_NormalizeOmegaProb(1)		//normalize
	endif
	
	if (cmpstr(ctrlName,"ASASPop2GetAlphaWave")==0)
		//here we create table of alpha distribution for user to edit. 
		ASAS_MakeAlphaProbabilityWaves(2)	//make the probability waves according to current users setting
		ASAS_AlphaProbTable(2)
		PauseForUser ASAS_AlphaProbTableT
		ASAS_NormalizeAlphaProb(2)			//normalize
	endif
	if (cmpstr(ctrlName,"ASASPop2GetOmegaWave")==0)
		//here we create table of omega distribution for user to edit. 
		ASAS_MakeOmegaProbabilityWaves(2)	//make the probability waves according to current users setting
		ASAS_OmegaProbTable(2)
		PauseForUser ASAS_OmegaProbTableT
		ASAS_NormalizeOmegaProb(2)		//normalize
	endif

	if (cmpstr(ctrlName,"ASASPop3GetAlphaWave")==0)
		//here we create table of alpha distribution for user to edit. 
		ASAS_MakeAlphaProbabilityWaves(3)	//make the probability waves according to current users setting
		ASAS_AlphaProbTable(3)
		PauseForUser ASAS_AlphaProbTableT
		ASAS_NormalizeAlphaProb(3)			//normalize
	endif
	if (cmpstr(ctrlName,"ASASPop3GetOmegaWave")==0)
		//here we create table of omega distribution for user to edit. 
		ASAS_MakeOmegaProbabilityWaves(3)	//make the probability waves according to current users setting
		ASAS_OmegaProbTable(3)
		PauseForUser ASAS_OmegaProbTableT
		ASAS_NormalizeOmegaProb(3)		//normalize
	endif

	if (cmpstr(ctrlName,"ASASPop4GetAlphaWave")==0)
		//here we create table of alpha distribution for user to edit. 
		ASAS_MakeAlphaProbabilityWaves(4)	//make the probability waves according to current users setting
		ASAS_AlphaProbTable(4)
		PauseForUser ASAS_AlphaProbTableT
		ASAS_NormalizeAlphaProb(4)			//normalize
	endif
	if (cmpstr(ctrlName,"ASASPop4GetOmegaWave")==0)
		//here we create table of omega distribution for user to edit. 
		ASAS_MakeOmegaProbabilityWaves(4)	//make the probability waves according to current users setting
		ASAS_OmegaProbTable(4)
		PauseForUser ASAS_OmegaProbTableT
		ASAS_NormalizeOmegaProb(4)		//normalize
	endif
	
	if (cmpstr(ctrlName,"ASASPop5GetAlphaWave")==0)
		//here we create table of alpha distribution for user to edit. 
		ASAS_MakeAlphaProbabilityWaves(5)	//make the probability waves according to current users setting
		ASAS_AlphaProbTable(5)
		PauseForUser ASAS_AlphaProbTableT
		ASAS_NormalizeAlphaProb(5)			//normalize
	endif
	if (cmpstr(ctrlName,"ASASPop5GetOmegaWave")==0)
		//here we create table of omega distribution for user to edit. 
		ASAS_MakeOmegaProbabilityWaves(5)	//make the probability waves according to current users setting
		ASAS_OmegaProbTable(5)
		PauseForUser ASAS_OmegaProbTableT
		ASAS_NormalizeOmegaProb(5)		//normalize
	endif
	
End

//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 


Function ASAS_CheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	setDataFOlder root:Packages:AnisoSAS:
	NVAR ActiveTab=root:Packages:AnisoSAS:ActiveTab
	
	
	if (cmpstr(CtrlName,"AnisoSelectionNormalize")==0)
		NVAR WhichQ=root:Packages:AnisoSAS:Ani_AnisoSelectorQ
		NVAR WhichDir=root:Packages:AnisoSAS:Ani_AnisoSelectorDir
		NVAR ChangeVariable=$("root:Packages:AnisoSAS:Ani"+num2str(WhichDir)+"_AnisoExpDataNormQ"+num2str(WhichQ))
		ChangeVariable=checked
		Checkbox AnisoSelectionNormalize value=ChangeVariable
	endif


	if (cmpstr(CtrlName,"ASASDisplayLocals")==0)
		ASAS_CalcAppendResultsToGraph()
	endif
	if (cmpstr(CtrlName,"ASAS_CntrlFormula4a")==0)
		NVAR UseOfFormula4
		UseOfFormula4=2
		Checkbox ASAS_CntrlFormula4a value=1
		Checkbox ASAS_CntrlFormula4b value=0
		Checkbox ASAS_CntrlFormula4c value=0
		SetVariable ASAS_Pop1_FWHM, disable=1
		SetVariable ASAS_Pop2_FWHM, disable=1
		SetVariable ASAS_Pop3_FWHM, disable=1
		SetVariable ASAS_Pop4_FWHM, disable=1
		SetVariable ASAS_Pop5_FWHM, disable=1
	endif
	if (cmpstr(CtrlName,"ASAS_CntrlFormula4b")==0)
		NVAR UseOfFormula4
		UseOfFormula4=3
		Checkbox ASAS_CntrlFormula4a value=0
		Checkbox ASAS_CntrlFormula4b value=1
		Checkbox ASAS_CntrlFormula4c value=0
		SetVariable ASAS_Pop1_FWHM, disable=1
		SetVariable ASAS_Pop2_FWHM, disable=1
		SetVariable ASAS_Pop3_FWHM, disable=1
		SetVariable ASAS_Pop4_FWHM, disable=1
		SetVariable ASAS_Pop5_FWHM, disable=1
	endif
	if (cmpstr(CtrlName,"ASAS_CntrlFormula4c")==0)
		NVAR UseOfFormula4
		UseOfFormula4=1
		Checkbox ASAS_CntrlFormula4a value=0
		Checkbox ASAS_CntrlFormula4b value=0
		Checkbox ASAS_CntrlFormula4c value=1
		SetVariable ASAS_Pop1_FWHM, disable=0
		SetVariable ASAS_Pop2_FWHM, disable=0
		SetVariable ASAS_Pop3_FWHM, disable=0
		SetVariable ASAS_Pop4_FWHM, disable=0
		SetVariable ASAS_Pop5_FWHM, disable=0
	endif

	if (cmpstr(CtrlName,"ASAS_Pop1_UseTrianFnct")==0)
		NVAR UseTriangularDist = root:Packages:AnisoSAS:Pop1_UseTriangularDist
		NVAR UseGaussSizeDist = root:Packages:AnisoSAS:Pop1_UseGaussSizeDist
		UseTriangularDist=checked
		UseGaussSizeDist=!checked
		SetVariable ASAS_Pop1_FWHM, disable=!UseTriangularDist
		SetVariable ASAS_Pop1_GFWHM, disable=!UseGaussSizeDist
		SetVariable ASAS_Pop1_NumPnts, disable=!UseGaussSizeDist
	endif
	if (cmpstr(CtrlName,"ASAS_Pop1_UseGaussFnct")==0)
		NVAR UseTriangularDist = root:Packages:AnisoSAS:Pop1_UseTriangularDist
		NVAR UseGaussSizeDist = root:Packages:AnisoSAS:Pop1_UseGaussSizeDist
		UseTriangularDist=!checked
		UseGaussSizeDist=checked
		SetVariable ASAS_Pop1_FWHM, disable=!UseTriangularDist
		SetVariable ASAS_Pop1_GFWHM, disable=!UseGaussSizeDist
		SetVariable ASAS_Pop1_NumPnts, disable=!UseGaussSizeDist
	endif
	if (cmpstr(CtrlName,"ASAS_Pop2_UseTrianFnct")==0)
		NVAR UseTriangularDist = root:Packages:AnisoSAS:Pop2_UseTriangularDist
		NVAR UseGaussSizeDist = root:Packages:AnisoSAS:Pop2_UseGaussSizeDist
		UseTriangularDist=checked
		UseGaussSizeDist=!checked
		SetVariable ASAS_Pop2_FWHM, disable=!UseTriangularDist
		SetVariable ASAS_Pop2_GFWHM, disable=!UseGaussSizeDist
		SetVariable ASAS_Pop2_NumPnts, disable=!UseGaussSizeDist
	endif
	if (cmpstr(CtrlName,"ASAS_Pop2_UseGaussFnct")==0)
		NVAR UseTriangularDist = root:Packages:AnisoSAS:Pop2_UseTriangularDist
		NVAR UseGaussSizeDist = root:Packages:AnisoSAS:Pop2_UseGaussSizeDist
		UseTriangularDist=!checked
		UseGaussSizeDist=checked
		SetVariable ASAS_Pop2_FWHM, disable=!UseTriangularDist
		SetVariable ASAS_Pop2_GFWHM, disable=!UseGaussSizeDist
		SetVariable ASAS_Pop2_NumPnts, disable=!UseGaussSizeDist
	endif
	if (cmpstr(CtrlName,"ASAS_Pop3_UseTrianFnct")==0)
		NVAR UseTriangularDist = root:Packages:AnisoSAS:Pop3_UseTriangularDist
		NVAR UseGaussSizeDist = root:Packages:AnisoSAS:Pop3_UseGaussSizeDist
		UseTriangularDist=checked
		UseGaussSizeDist=!checked
		SetVariable ASAS_Pop3_FWHM, disable=!UseTriangularDist
		SetVariable ASAS_Pop3_GFWHM, disable=!UseGaussSizeDist
		SetVariable ASAS_Pop3_NumPnts, disable=!UseGaussSizeDist
	endif
	if (cmpstr(CtrlName,"ASAS_Pop3_UseGaussFnct")==0)
		NVAR UseTriangularDist = root:Packages:AnisoSAS:Pop3_UseTriangularDist
		NVAR UseGaussSizeDist = root:Packages:AnisoSAS:Pop3_UseGaussSizeDist
		UseTriangularDist=!checked
		UseGaussSizeDist=checked
		SetVariable ASAS_Pop3_FWHM, disable=!UseTriangularDist
		SetVariable ASAS_Pop3_GFWHM, disable=!UseGaussSizeDist
		SetVariable ASAS_Pop3_NumPnts, disable=!UseGaussSizeDist
	endif
	if (cmpstr(CtrlName,"ASAS_Pop4_UseTrianFnct")==0)
		NVAR UseTriangularDist = root:Packages:AnisoSAS:Pop4_UseTriangularDist
		NVAR UseGaussSizeDist = root:Packages:AnisoSAS:Pop4_UseGaussSizeDist
		UseTriangularDist=checked
		UseGaussSizeDist=!checked
		SetVariable ASAS_Pop4_FWHM, disable=!UseTriangularDist
		SetVariable ASAS_Pop4_GFWHM, disable=!UseGaussSizeDist
		SetVariable ASAS_Pop4_NumPnts, disable=!UseGaussSizeDist
	endif
	if (cmpstr(CtrlName,"ASAS_Pop4_UseGaussFnct")==0)
		NVAR UseTriangularDist = root:Packages:AnisoSAS:Pop4_UseTriangularDist
		NVAR UseGaussSizeDist = root:Packages:AnisoSAS:Pop4_UseGaussSizeDist
		UseTriangularDist=!checked
		UseGaussSizeDist=checked
		SetVariable ASAS_Pop4_FWHM, disable=!UseTriangularDist
		SetVariable ASAS_Pop4_GFWHM, disable=!UseGaussSizeDist
		SetVariable ASAS_Pop4_NumPnts, disable=!UseGaussSizeDist
	endif
	if (cmpstr(CtrlName,"ASAS_Pop5_UseTrianFnct")==0)
		NVAR UseTriangularDist = root:Packages:AnisoSAS:Pop5_UseTriangularDist
		NVAR UseGaussSizeDist = root:Packages:AnisoSAS:Pop5_UseGaussSizeDist
		UseTriangularDist=checked
		UseGaussSizeDist=!checked
		SetVariable ASAS_Pop5_FWHM, disable=!UseTriangularDist
		SetVariable ASAS_Pop5_GFWHM, disable=!UseGaussSizeDist
		SetVariable ASAS_Pop5_NumPnts, disable=!UseGaussSizeDist
	endif
	if (cmpstr(CtrlName,"ASAS_Pop5_UseGaussFnct")==0)
		NVAR UseTriangularDist = root:Packages:AnisoSAS:Pop5_UseTriangularDist
		NVAR UseGaussSizeDist = root:Packages:AnisoSAS:Pop5_UseGaussSizeDist
		UseTriangularDist=!checked
		UseGaussSizeDist=checked
		SetVariable ASAS_Pop5_FWHM, disable=!UseTriangularDist
		SetVariable ASAS_Pop5_GFWHM, disable=!UseGaussSizeDist
		SetVariable ASAS_Pop5_NumPnts, disable=!UseGaussSizeDist
	endif

	
	if (cmpstr(CtrlName,"ASASDataType")==0)
		//here we change the ASASDataType checkbox and variable, which tells us what data (DSM/M_DSM) we want to use
		NVAR UseMultiplyCorrDta
		UseMultiplyCorrDta=checked
		Checkbox ASASDataType value=UseMultiplyCorrDta
		SVAR InputWvType
		if (UseMultiplyCorrDta)
			InputWvType="M_DSM"
		else
			InputWvType="DSM"
		endif
		PopupMenu ASASDir1FolderName,mode=1
		SVAR Dir1_IntWvName
		SVAR Dir1_QvecWvName
		SVAR Dir1_ErrorWvName
		SVAR Dir1_DataFolderName
		Dir1_IntWvName=""
		Dir1_QvecWvName=""
		Dir1_ErrorWvName=""
		Dir1_DataFolderName=""

		PopupMenu ASASDir2FolderName,mode=1
		SVAR Dir2_IntWvName
		SVAR Dir2_QvecWvName
		SVAR Dir2_ErrorWvName
		SVAR Dir2_DataFolderName
		Dir2_IntWvName=""
		Dir2_QvecWvName=""
		Dir2_ErrorWvName=""
		Dir2_DataFolderName=""

		PopupMenu ASASDir3FolderName,mode=1
		SVAR Dir3_IntWvName
		SVAR Dir3_QvecWvName
		SVAR Dir3_ErrorWvName
		SVAR Dir3_DataFolderName
		Dir3_IntWvName=""
		Dir3_QvecWvName=""
		Dir3_ErrorWvName=""
		Dir3_DataFolderName=""

		PopupMenu ASASDir4FolderName,mode=1
		SVAR Dir4_IntWvName
		SVAR Dir4_QvecWvName
		SVAR Dir4_ErrorWvName
		SVAR Dir4_DataFolderName
		Dir4_IntWvName=""
		Dir4_QvecWvName=""
		Dir4_ErrorWvName=""
		Dir4_DataFolderName=""

		PopupMenu ASASDir5FolderName,mode=1
		SVAR Dir5_IntWvName
		SVAR Dir5_QvecWvName
		SVAR Dir5_ErrorWvName
		SVAR Dir5_DataFolderName
		Dir5_IntWvName=""
		Dir5_QvecWvName=""
		Dir5_ErrorWvName=""
		Dir5_DataFolderName=""

		PopupMenu ASASDir6FolderName,mode=1
		SVAR Dir6_IntWvName
		SVAR Dir6_QvecWvName
		SVAR Dir6_ErrorWvName
		SVAR Dir6_DataFolderName
		Dir6_IntWvName=""
		Dir6_QvecWvName=""
		Dir6_ErrorWvName=""
		Dir6_DataFolderName=""
		
	endif

	if (cmpstr(CtrlName,"ASASUpdateImmediately")==0)
		NVAR UpdateAutomatically
		UpdateAutomatically=checked
		Checkbox ASASUpdateImmediately value=UpdateAutomatically
	endif
	if (cmpstr(CtrlName,"ASASDisplayAllPops")==0)
		NVAR DisplayAllProbabilityDist=root:Packages:AnisoSAS:DisplayAllProbabilityDist
		DisplayAllProbabilityDist=checked
		Checkbox ASASDisplayAllPops value=DisplayAllProbabilityDist
		ASAS_UpdateDistGraph(ActiveTab-1)
	endif

	if (cmpstr(CtrlName,"ASASPop1FitRadius")==0)
		NVAR Pop1_FitRadius
		Pop1_FitRadius=checked
		Checkbox ASASPop1FitRadius value=checked
		SetVariable ASASPop1RadiusMin,disable= (!Pop1_FitRadius), win=ASAS_InputPanel
		SetVariable ASASPop1RadiusMax,disable = (!Pop1_FitRadius), win=ASAS_InputPanel
	endif
	if (cmpstr(CtrlName,"ASASPop1FitVolumeFraction")==0)
		NVAR Pop1_FitVolumeFraction
		Pop1_FitVolumeFraction=checked
		Checkbox ASASPop1FitVolumeFraction value=checked
		SetVariable ASASPop1VolumeFractionMin,disable= (!Pop1_FitVolumeFraction), win=ASAS_InputPanel
		SetVariable ASASPop1VolumeFractionMax,disable = (!Pop1_FitVolumeFraction), win=ASAS_InputPanel
	endif
	if (cmpstr(CtrlName,"ASASPop1UsePAlphaParam")==0)
		NVAR Pop1_UsePAlphaParam
		Pop1_UsePAlphaParam=checked
		Checkbox ASASPop1UsePAlphaParam value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
		if (checked==1)
			ASAS_MakeAlphaProbabilityWaves(1)
			ASAS_RecalculateAlpha(1)
			ASAS_NormalizeAlphaProb(1)	
		endif
	endif
	if (cmpstr(CtrlName,"ASASPop1UseBOmegaParam")==0)
		NVAR Pop1_UseBOmegaParam
		Pop1_UseBOmegaParam=checked
		Checkbox ASASPop1UseBOmegaParam value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
		if (checked==1)
			ASAS_MakeOmegaProbabilityWaves(1)
			ASAS_RecalculateOmega(1)
			ASAS_NormalizeOmegaProb(1)	
		endif
	endif
	if (cmpstr(CtrlName,"ASASPop1FitPAlphaPar1")==0)
		NVAR Pop1_FitPAlphaPar1
		Pop1_FitPAlphaPar1=checked
		Checkbox ASASPop1FitPAlphaPar1 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop1FitPAlphaPar2")==0)
		NVAR Pop1_FitPAlphaPar2
		Pop1_FitPAlphaPar2=checked
		Checkbox ASASPop1FitPAlphaPar2 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop1FitPAlphaPar3")==0)
		NVAR Pop1_FitPAlphaPar3
		Pop1_FitPAlphaPar3=checked
		Checkbox ASASPop1FitPAlphaPar3 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif

	if (cmpstr(CtrlName,"ASASPop1FitBOmegaPar1")==0)
		NVAR Pop1_FitBOmegaPar1
		Pop1_FitBOmegaPar1=checked
		Checkbox ASASPop1FitBOmegaPar1 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop1FitBOmegaPar2")==0)
		NVAR Pop1_FitBOmegaPar2
		Pop1_FitBOmegaPar2=checked
		Checkbox ASASPop1FitBOmegaPar2 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop1FitBOmegaPar3")==0)
		NVAR Pop1_FitBOmegaPar3
		Pop1_FitBOmegaPar3=checked
		Checkbox ASASPop1FitBOmegaPar3 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop1UseInterference")==0)
		if(Checked)
			ASAS_InterferencePanel(1)
		else
			DoWindow ASAS_InterferencePanel1
			if(V_Flag)
				DoWIndow/K ASAS_InterferencePanel1
			endif
		endif
	endif

//Population 2
	if (cmpstr(CtrlName,"ASASPop2FitRadius")==0)
		NVAR Pop2_FitRadius
		Pop2_FitRadius=checked
		Checkbox ASASPop2FitRadius value=checked
		SetVariable ASASPop2RadiusMin,disable= (!Pop2_FitRadius), win=ASAS_InputPanel
		SetVariable ASASPop2RadiusMax,disable = (!Pop2_FitRadius), win=ASAS_InputPanel
	endif
	if (cmpstr(CtrlName,"ASASPop2FitVolumeFraction")==0)
		NVAR Pop2_FitVolumeFraction
		Pop2_FitVolumeFraction=checked
		Checkbox ASASPop2FitVolumeFraction value=checked
		SetVariable ASASPop2VolumeFractionMin,disable= (!Pop2_FitVolumeFraction), win=ASAS_InputPanel
		SetVariable ASASPop2VolumeFractionMax,disable = (!Pop2_FitVolumeFraction), win=ASAS_InputPanel
	endif
	if (cmpstr(CtrlName,"ASASPop2UsePAlphaParam")==0)
		NVAR Pop2_UsePAlphaParam
		Pop2_UsePAlphaParam=checked
		Checkbox ASASPop2UsePAlphaParam value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
		if (checked==1)
			ASAS_MakeAlphaProbabilityWaves(2)
			ASAS_RecalculateAlpha(2)
			ASAS_NormalizeAlphaProb(2)	
		endif
	endif
	if (cmpstr(CtrlName,"ASASPop2UseBOmegaParam")==0)
		NVAR Pop2_UseBOmegaParam
		Pop2_UseBOmegaParam=checked
		Checkbox ASASPop2UseBOmegaParam value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
		if (checked==1)
			ASAS_MakeOmegaProbabilityWaves(2)
			ASAS_RecalculateOmega(2)
			ASAS_NormalizeOmegaProb(2)	
		endif
	endif
	if (cmpstr(CtrlName,"ASASPop2FitPAlphaPar1")==0)
		NVAR Pop2_FitPAlphaPar1
		Pop2_FitPAlphaPar1=checked
		Checkbox ASASPop2FitPAlphaPar1 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop2FitPAlphaPar2")==0)
		NVAR Pop2_FitPAlphaPar2
		Pop2_FitPAlphaPar2=checked
		Checkbox ASASPop2FitPAlphaPar2 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop2FitPAlphaPar3")==0)
		NVAR Pop2_FitPAlphaPar3
		Pop2_FitPAlphaPar3=checked
		Checkbox ASASPop2FitPAlphaPar3 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif

	if (cmpstr(CtrlName,"ASASPop2FitBOmegaPar1")==0)
		NVAR Pop2_FitBOmegaPar1
		Pop2_FitBOmegaPar1=checked
		Checkbox ASASPop2FitBOmegaPar1 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop2FitBOmegaPar2")==0)
		NVAR Pop2_FitBOmegaPar2
		Pop2_FitBOmegaPar2=checked
		Checkbox ASASPop2FitBOmegaPar2 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop2FitBOmegaPar3")==0)
		NVAR Pop2_FitBOmegaPar3
		Pop2_FitBOmegaPar3=checked
		Checkbox ASASPop2FitBOmegaPar3 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop2UseInterference")==0)
		if(Checked)
			ASAS_InterferencePanel(2)
		else
			DoWindow ASAS_InterferencePanel2
			if(V_Flag)
				DoWIndow/K ASAS_InterferencePanel2
			endif
		endif
	endif


//Population 3
	if (cmpstr(CtrlName,"ASASPop3FitRadius")==0)
		NVAR Pop3_FitRadius
		Pop3_FitRadius=checked
		Checkbox ASASPop3FitRadius value=checked
		SetVariable ASASPop3RadiusMin,disable= (!Pop3_FitRadius), win=ASAS_InputPanel
		SetVariable ASASPop3RadiusMax,disable = (!Pop3_FitRadius), win=ASAS_InputPanel
	endif
	if (cmpstr(CtrlName,"ASASPop3FitVolumeFraction")==0)
		NVAR Pop3_FitVolumeFraction
		Pop3_FitVolumeFraction=checked
		Checkbox ASASPop3FitVolumeFraction value=checked
		SetVariable ASASPop3VolumeFractionMin,disable= (!Pop3_FitVolumeFraction), win=ASAS_InputPanel
		SetVariable ASASPop3VolumeFractionMax,disable = (!Pop3_FitVolumeFraction), win=ASAS_InputPanel
	endif
	if (cmpstr(CtrlName,"ASASPop3UsePAlphaParam")==0)
		NVAR Pop3_UsePAlphaParam
		Pop3_UsePAlphaParam=checked
		Checkbox ASASPop3UsePAlphaParam value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
		if (checked==1)
			ASAS_MakeAlphaProbabilityWaves(3)
			ASAS_RecalculateAlpha(3)
			ASAS_NormalizeAlphaProb(3)	
		endif
	endif
	if (cmpstr(CtrlName,"ASASPop3UseBOmegaParam")==0)
		NVAR Pop3_UseBOmegaParam
		Pop3_UseBOmegaParam=checked
		Checkbox ASASPop3UseBOmegaParam value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
		if (checked==1)
			ASAS_MakeOmegaProbabilityWaves(3)
			ASAS_RecalculateOmega(3)
			ASAS_NormalizeOmegaProb(3)	
		endif
	endif
	if (cmpstr(CtrlName,"ASASPop3FitPAlphaPar1")==0)
		NVAR Pop3_FitPAlphaPar1
		Pop3_FitPAlphaPar1=checked
		Checkbox ASASPop3FitPAlphaPar1 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop3FitPAlphaPar2")==0)
		NVAR Pop3_FitPAlphaPar2
		Pop3_FitPAlphaPar2=checked
		Checkbox ASASPop3FitPAlphaPar2 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop3FitPAlphaPar3")==0)
		NVAR Pop3_FitPAlphaPar3
		Pop3_FitPAlphaPar3=checked
		Checkbox ASASPop3FitPAlphaPar3 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif

	if (cmpstr(CtrlName,"ASASPop3FitBOmegaPar1")==0)
		NVAR Pop3_FitBOmegaPar1
		Pop3_FitBOmegaPar1=checked
		Checkbox ASASPop3FitBOmegaPar1 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop3FitBOmegaPar2")==0)
		NVAR Pop3_FitBOmegaPar2
		Pop3_FitBOmegaPar2=checked
		Checkbox ASASPop3FitBOmegaPar2 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop3FitBOmegaPar3")==0)
		NVAR Pop3_FitBOmegaPar3
		Pop3_FitBOmegaPar3=checked
		Checkbox ASASPop3FitBOmegaPar3 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop3UseInterference")==0)
		if(Checked)
			ASAS_InterferencePanel(3)
		else
			DoWindow ASAS_InterferencePanel3
			if(V_Flag)
				DoWIndow/K ASAS_InterferencePanel3
			endif
		endif
	endif


//Population 4
	if (cmpstr(CtrlName,"ASASPop4FitRadius")==0)
		NVAR Pop4_FitRadius
		Pop4_FitRadius=checked
		Checkbox ASASPop4FitRadius value=checked
		SetVariable ASASPop4RadiusMin,disable= (!Pop4_FitRadius), win=ASAS_InputPanel
		SetVariable ASASPop4RadiusMax,disable = (!Pop4_FitRadius), win=ASAS_InputPanel
	endif
	if (cmpstr(CtrlName,"ASASPop4FitVolumeFraction")==0)
		NVAR Pop4_FitVolumeFraction
		Pop4_FitVolumeFraction=checked
		Checkbox ASASPop4FitVolumeFraction value=checked
		SetVariable ASASPop4VolumeFractionMin,disable= (!Pop4_FitVolumeFraction), win=ASAS_InputPanel
		SetVariable ASASPop4VolumeFractionMax,disable = (!Pop4_FitVolumeFraction), win=ASAS_InputPanel
	endif
	if (cmpstr(CtrlName,"ASASPop4UsePAlphaParam")==0)
		NVAR Pop4_UsePAlphaParam
		Pop4_UsePAlphaParam=checked
		Checkbox ASASPop4UsePAlphaParam value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
		if (checked==1)
			ASAS_MakeAlphaProbabilityWaves(4)
			ASAS_RecalculateAlpha(4)
			ASAS_NormalizeAlphaProb(4)	
		endif
	endif
	if (cmpstr(CtrlName,"ASASPop4UseBOmegaParam")==0)
		NVAR Pop4_UseBOmegaParam
		Pop4_UseBOmegaParam=checked
		Checkbox ASASPop4UseBOmegaParam value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
		if (checked==1)
			ASAS_MakeOmegaProbabilityWaves(4)
			ASAS_RecalculateOmega(4)
			ASAS_NormalizeOmegaProb(4)	
		endif
	endif
	if (cmpstr(CtrlName,"ASASPop4FitPAlphaPar1")==0)
		NVAR Pop4_FitPAlphaPar1
		Pop4_FitPAlphaPar1=checked
		Checkbox ASASPop4FitPAlphaPar1 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop4FitPAlphaPar2")==0)
		NVAR Pop4_FitPAlphaPar2
		Pop4_FitPAlphaPar2=checked
		Checkbox ASASPop4FitPAlphaPar2 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop4FitPAlphaPar3")==0)
		NVAR Pop4_FitPAlphaPar3
		Pop4_FitPAlphaPar3=checked
		Checkbox ASASPop4FitPAlphaPar3 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif

	if (cmpstr(CtrlName,"ASASPop4FitBOmegaPar1")==0)
		NVAR Pop4_FitBOmegaPar1
		Pop4_FitBOmegaPar1=checked
		Checkbox ASASPop4FitBOmegaPar1 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop4FitBOmegaPar2")==0)
		NVAR Pop4_FitBOmegaPar2
		Pop4_FitBOmegaPar2=checked
		Checkbox ASASPop4FitBOmegaPar2 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop4FitBOmegaPar3")==0)
		NVAR Pop4_FitBOmegaPar3
		Pop4_FitBOmegaPar3=checked
		Checkbox ASASPop4FitBOmegaPar3 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop4UseInterference")==0)
		if(Checked)
			ASAS_InterferencePanel(4)
		else
			DoWindow ASAS_InterferencePanel4
			if(V_Flag)
				DoWIndow/K ASAS_InterferencePanel4
			endif
		endif
	endif

//Population 5
	if (cmpstr(CtrlName,"ASASPop5FitRadius")==0)
		NVAR Pop5_FitRadius
		Pop5_FitRadius=checked
		Checkbox ASASPop5FitRadius value=checked
		SetVariable ASASPop5RadiusMin,disable= (!Pop5_FitRadius), win=ASAS_InputPanel
		SetVariable ASASPop5RadiusMax,disable = (!Pop5_FitRadius), win=ASAS_InputPanel
	endif
	if (cmpstr(CtrlName,"ASASPop5FitVolumeFraction")==0)
		NVAR Pop5_FitVolumeFraction
		Pop5_FitVolumeFraction=checked
		Checkbox ASASPop5FitVolumeFraction value=checked
		SetVariable ASASPop5VolumeFractionMin,disable= (!Pop5_FitVolumeFraction), win=ASAS_InputPanel
		SetVariable ASASPop5VolumeFractionMax,disable = (!Pop5_FitVolumeFraction), win=ASAS_InputPanel
	endif
	if (cmpstr(CtrlName,"ASASPop5UsePAlphaParam")==0)
		NVAR Pop5_UsePAlphaParam
		Pop5_UsePAlphaParam=checked
		Checkbox ASASPop5UsePAlphaParam value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
		if (checked==1)
			ASAS_MakeAlphaProbabilityWaves(5)
			ASAS_RecalculateAlpha(5)
			ASAS_NormalizeAlphaProb(5)	
		endif
	endif
	if (cmpstr(CtrlName,"ASASPop5UseBOmegaParam")==0)
		NVAR Pop5_UseBOmegaParam
		Pop5_UseBOmegaParam=checked
		Checkbox ASASPop5UseBOmegaParam value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
		if (checked==1)
			ASAS_MakeOmegaProbabilityWaves(5)
			ASAS_RecalculateOmega(5)
			ASAS_NormalizeOmegaProb(5)	
		endif
	endif
	if (cmpstr(CtrlName,"ASASPop5FitPAlphaPar1")==0)
		NVAR Pop5_FitPAlphaPar1
		Pop5_FitPAlphaPar1=checked
		Checkbox ASASPop5FitPAlphaPar1 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop5FitPAlphaPar2")==0)
		NVAR Pop5_FitPAlphaPar2
		Pop5_FitPAlphaPar2=checked
		Checkbox ASASPop5FitPAlphaPar2 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop5FitPAlphaPar3")==0)
		NVAR Pop5_FitPAlphaPar3
		Pop5_FitPAlphaPar3=checked
		Checkbox ASASPop5FitPAlphaPar3 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif

	if (cmpstr(CtrlName,"ASASPop5FitBOmegaPar1")==0)
		NVAR Pop5_FitBOmegaPar1
		Pop5_FitBOmegaPar1=checked
		Checkbox ASASPop5FitBOmegaPar1 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop5FitBOmegaPar2")==0)
		NVAR Pop5_FitBOmegaPar2
		Pop5_FitBOmegaPar2=checked
		Checkbox ASASPop5FitBOmegaPar2 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop5FitBOmegaPar3")==0)
		NVAR Pop5_FitBOmegaPar3
		Pop5_FitBOmegaPar3=checked
		Checkbox ASASPop5FitBOmegaPar3 value=checked
		ASAS_TabPanelControl("bla",ActiveTab-1)
	endif
	if (cmpstr(CtrlName,"ASASPop5UseInterference")==0)
		if(Checked)
			ASAS_InterferencePanel(5)
		else
			DoWindow ASAS_InterferencePanel5
			if(V_Flag)
				DoWIndow/K ASAS_InterferencePanel5
			endif
		endif
	endif

End

//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 


Function ASAS_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	setDataFolder root:Packages:AnisoSAS
	
	//first display only input direction controls
	NVAR NoD=NumberOfDirections
	NVAR MSAS=root:Packages:AnisoSAS:UseMultiplyCorrDta
	NVAR Ani_AnisoSelectorQ=root:Packages:AnisoSAS:Ani_AnisoSelectorQ
	NVAR Ani_AnisoSelectorDir=root:Packages:AnisoSAS:Ani_AnisoSelectorDir




	if (cmpstr(ctrlName,"Ani1Qval1FolderName")==0)
		//set the folder with data for aniso 1 measured direction and call on panel to insert data
		SVAR Ani1_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ1		//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=1
			Ani_AnisoSelectorDir=1
			SVAR tempIntName=root:Packages:AnisoSAS:Ani1_AnisoExpDataIntQ1
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani1_AnisoExpDataAngleQ1
			if (cmpstr(Ani1_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani1_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani1_AnisoExpDataFldr=popStr		
		endif
	endif
	if (cmpstr(ctrlName,"Ani1Qval2FolderName")==0)
		//set the folder with data for aniso 2 measured direction and call on panel to insert data
		SVAR Ani1_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ2				//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=2
			Ani_AnisoSelectorDir=1
			SVAR tempIntName=root:Packages:AnisoSAS:Ani1_AnisoExpDataIntQ2
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani1_AnisoExpDataAngleQ2
			if (cmpstr(Ani1_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani1_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani1_AnisoExpDataFldr=popStr		
		endif
	endif
	if (cmpstr(ctrlName,"Ani1Qval3FolderName")==0)
		//set the folder with data for aniso 3 measured direction and call on panel to insert data
		SVAR Ani1_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ3		//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=3
			Ani_AnisoSelectorDir=1
			SVAR tempIntName=root:Packages:AnisoSAS:Ani1_AnisoExpDataIntQ3
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani1_AnisoExpDataAngleQ3
			if (cmpstr(Ani1_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani1_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani1_AnisoExpDataFldr=popStr		
		endif
	endif
	if (cmpstr(ctrlName,"Ani1Qval4FolderName")==0)
		//set the folder with data for aniso 4 measured direction and call on panel to insert data
		SVAR Ani1_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ4		//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=4
			Ani_AnisoSelectorDir=1
			SVAR tempIntName=root:Packages:AnisoSAS:Ani1_AnisoExpDataIntQ4
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani1_AnisoExpDataAngleQ4
			if (cmpstr(Ani1_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani1_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani1_AnisoExpDataFldr=popStr		
		endif
	endif
	if (cmpstr(ctrlName,"Ani1Qval5FolderName")==0)
		//set the folder with data for aniso 5 measured direction and call on panel to insert data
		SVAR Ani1_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ5	//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=5
			Ani_AnisoSelectorDir=1
			SVAR tempIntName=root:Packages:AnisoSAS:Ani1_AnisoExpDataIntQ5
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani1_AnisoExpDataAngleQ5
			if (cmpstr(Ani1_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani1_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani1_AnisoExpDataFldr=popStr		
		endif
	endif
	if (cmpstr(ctrlName,"Ani1Qval6FolderName")==0)
		//set the folder with data for aniso 6 measured direction and call on panel to insert data
		SVAR Ani1_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ6		//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=6
			Ani_AnisoSelectorDir=1
			SVAR tempIntName=root:Packages:AnisoSAS:Ani1_AnisoExpDataIntQ6
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani1_AnisoExpDataAngleQ6
			if (cmpstr(Ani1_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani1_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani1_AnisoExpDataFldr=popStr		
		endif
	endif



	if (cmpstr(ctrlName,"Ani2Qval1FolderName")==0)
		//set the folder with data for aniso 1 measured direction and call on panel to insert data
		SVAR Ani2_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ1		//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=1
			Ani_AnisoSelectorDir=2
			SVAR tempIntName=root:Packages:AnisoSAS:Ani2_AnisoExpDataIntQ1
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani2_AnisoExpDataAngleQ1
			if (cmpstr(Ani2_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani2_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani2_AnisoExpDataFldr=popStr		
		endif
	endif
	if (cmpstr(ctrlName,"Ani2Qval2FolderName")==0)
		//set the folder with data for aniso 2 measured direction and call on panel to insert data
		SVAR Ani2_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ2				//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=2
			Ani_AnisoSelectorDir=2
			SVAR tempIntName=root:Packages:AnisoSAS:Ani2_AnisoExpDataIntQ2
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani2_AnisoExpDataAngleQ2
			if (cmpstr(Ani2_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani2_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani2_AnisoExpDataFldr=popStr		
		endif
	endif
	if (cmpstr(ctrlName,"Ani2Qval3FolderName")==0)
		//set the folder with data for aniso 3 measured direction and call on panel to insert data
		SVAR Ani2_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ3		//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=3
			Ani_AnisoSelectorDir=2
			SVAR tempIntName=root:Packages:AnisoSAS:Ani2_AnisoExpDataIntQ3
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani2_AnisoExpDataAngleQ3
			if (cmpstr(Ani2_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani2_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani2_AnisoExpDataFldr=popStr		
		endif
	endif
	if (cmpstr(ctrlName,"Ani2Qval4FolderName")==0)
		//set the folder with data for aniso 4 measured direction and call on panel to insert data
		SVAR Ani2_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ4		//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=4
			Ani_AnisoSelectorDir=2
			SVAR tempIntName=root:Packages:AnisoSAS:Ani2_AnisoExpDataIntQ4
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani2_AnisoExpDataAngleQ4
			if (cmpstr(Ani2_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani2_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani2_AnisoExpDataFldr=popStr		
		endif
	endif
	if (cmpstr(ctrlName,"Ani2Qval5FolderName")==0)
		//set the folder with data for aniso 5 measured direction and call on panel to insert data
		SVAR Ani2_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ5	//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=5
			Ani_AnisoSelectorDir=2
			SVAR tempIntName=root:Packages:AnisoSAS:Ani2_AnisoExpDataIntQ5
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani2_AnisoExpDataAngleQ5
			if (cmpstr(Ani2_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani2_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani2_AnisoExpDataFldr=popStr		
		endif
	endif
	if (cmpstr(ctrlName,"Ani2Qval6FolderName")==0)
		//set the folder with data for aniso 6 measured direction and call on panel to insert data
		SVAR Ani2_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ6		//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=6
			Ani_AnisoSelectorDir=2
			SVAR tempIntName=root:Packages:AnisoSAS:Ani2_AnisoExpDataIntQ6
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani2_AnisoExpDataAngleQ6
			if (cmpstr(Ani2_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani2_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani2_AnisoExpDataFldr=popStr		
		endif
	endif




	if (cmpstr(ctrlName,"Ani3Qval1FolderName")==0)
		//set the folder with data for aniso 1 measured direction and call on panel to insert data
		SVAR Ani3_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ1		//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=1
			Ani_AnisoSelectorDir=3
			SVAR tempIntName=root:Packages:AnisoSAS:Ani3_AnisoExpDataIntQ1
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani3_AnisoExpDataAngleQ1
			if (cmpstr(Ani3_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani3_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani3_AnisoExpDataFldr=popStr		
		endif
	endif
	if (cmpstr(ctrlName,"Ani3Qval2FolderName")==0)
		//set the folder with data for aniso 2 measured direction and call on panel to insert data
		SVAR Ani3_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ2				//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=2
			Ani_AnisoSelectorDir=3
			SVAR tempIntName=root:Packages:AnisoSAS:Ani3_AnisoExpDataIntQ2
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani3_AnisoExpDataAngleQ2
			if (cmpstr(Ani3_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani3_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani3_AnisoExpDataFldr=popStr		
		endif
	endif
	if (cmpstr(ctrlName,"Ani3Qval3FolderName")==0)
		//set the folder with data for aniso 3 measured direction and call on panel to insert data
		SVAR Ani3_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ3		//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=3
			Ani_AnisoSelectorDir=3
			SVAR tempIntName=root:Packages:AnisoSAS:Ani3_AnisoExpDataIntQ3
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani3_AnisoExpDataAngleQ3
			if (cmpstr(Ani3_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani3_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani3_AnisoExpDataFldr=popStr		
		endif
	endif
	if (cmpstr(ctrlName,"Ani3Qval4FolderName")==0)
		//set the folder with data for aniso 4 measured direction and call on panel to insert data
		SVAR Ani3_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ4		//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=4
			Ani_AnisoSelectorDir=3
			SVAR tempIntName=root:Packages:AnisoSAS:Ani3_AnisoExpDataIntQ4
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani3_AnisoExpDataAngleQ4
			if (cmpstr(Ani3_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani3_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani3_AnisoExpDataFldr=popStr		
		endif
	endif
	if (cmpstr(ctrlName,"Ani3Qval5FolderName")==0)
		//set the folder with data for aniso 5 measured direction and call on panel to insert data
		SVAR Ani3_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ5	//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=5
			Ani_AnisoSelectorDir=3
			SVAR tempIntName=root:Packages:AnisoSAS:Ani3_AnisoExpDataIntQ5
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani3_AnisoExpDataAngleQ5
			if (cmpstr(Ani3_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani3_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani3_AnisoExpDataFldr=popStr		
		endif
	endif
	if (cmpstr(ctrlName,"Ani3Qval6FolderName")==0)
		//set the folder with data for aniso 6 measured direction and call on panel to insert data
		SVAR Ani3_AnisoExpDataFldr=root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ6		//this is where I need to put the folder name
		if (cmpstr(popstr,"---")!=0)
			Ani_AnisoSelectorQ=6
			Ani_AnisoSelectorDir=3
			SVAR tempIntName=root:Packages:AnisoSAS:Ani3_AnisoExpDataIntQ6
			SVAR tempAngleName=root:Packages:AnisoSAS:Ani3_AnisoExpDataAngleQ6
			if (cmpstr(Ani3_AnisoExpDataFldr,popstr)!=0)
				tempIntName="---"
				tempAngleName="---"
			endif
			Ani3_AnisoExpDataFldr=popStr
			DoWIndow ASAS_AnisoDataSelection
				if (V_Flag)
					DoWindow/K ASAS_AnisoDataSelection
				endif
			Execute("ASAS_AnisoDataSelection()")
		else
			Ani3_AnisoExpDataFldr=popStr		
		endif
	endif



	if (cmpstr(ctrlName,"AnisoSelectionInt")==0)
		//set the name for wave with intensity data 
		SVAR tempName=$("Ani"+num2str(Ani_AnisoSelectorDir)+"_AnisoExpDataIntQ"+num2str(Ani_AnisoSelectorQ))		//this is where I need to put the wave name
		if (cmpstr(popstr,"---")!=0)
			tempName=popStr
		endif
	endif
	if (cmpstr(ctrlName,"AnisoSelectionAngle")==0)
		//set the name for wave with intensity data 
		SVAR tempName=$("Ani"+num2str(Ani_AnisoSelectorDir)+"_AnisoExpDataAngleQ"+num2str(Ani_AnisoSelectorQ))		//this is where I need to put the wave name
		if (cmpstr(popstr,"---")!=0)
			tempName=popStr
		endif
	endif
	
	if (cmpstr(ctrlName,"ASASNumberOfDirections")==0)
		//set the Number of directions to fit and fix panel as appropriate to appropriate values
		NoD=str2num(popStr)
		ASAS_FixControlsInPanel()
	endif

	if (cmpstr(ctrlName,"ASASDir1FolderName")==0)
		//set the SVARS to appropriate values
		SVAR Dir1_IntWvName
		SVAR Dir1_QvecWvName
		SVAR Dir1_ErrorWvName
		SVAR Dir1_DataFolderName
		Dir1_DataFolderName=popStr
			if(MSAS)
				 Dir1_IntWvName="M_DSM_Int"
				 Dir1_QvecWvName="M_DSM_Qvec"
				 Dir1_ErrorWvName="M_DSM_Error"
			else
				 Dir1_IntWvName="DSM_Int"
				 Dir1_QvecWvName="DSM_Qvec"
				 Dir1_ErrorWvName="DSM_Error"
			endif	
	endif
	if (cmpstr(ctrlName,"ASASDir2FolderName")==0)
		//set the SVARS to appropriate values
		SVAR Dir2_IntWvName
		SVAR Dir2_QvecWvName
		SVAR Dir2_ErrorWvName
		SVAR Dir2_DataFolderName
		Dir2_DataFolderName=popStr
			if(MSAS)
				 Dir2_IntWvName="M_DSM_Int"
				 Dir2_QvecWvName="M_DSM_Qvec"
				 Dir2_ErrorWvName="M_DSM_Error"
			else
				 Dir2_IntWvName="DSM_Int"
				 Dir2_QvecWvName="DSM_Qvec"
				 Dir2_ErrorWvName="DSM_Error"
			endif	
	endif
	if (cmpstr(ctrlName,"ASASDir3FolderName")==0)
		//set the SVARS to appropriate values
		SVAR Dir3_IntWvName
		SVAR Dir3_QvecWvName
		SVAR Dir3_ErrorWvName
		SVAR Dir3_DataFolderName
		Dir3_DataFolderName=popStr
			if(MSAS)
				 Dir3_IntWvName="M_DSM_Int"
				 Dir3_QvecWvName="M_DSM_Qvec"
				 Dir3_ErrorWvName="M_DSM_Error"
			else
				 Dir3_IntWvName="DSM_Int"
				 Dir3_QvecWvName="DSM_Qvec"
				 Dir3_ErrorWvName="DSM_Error"
			endif	
	endif
	if (cmpstr(ctrlName,"ASASDir4FolderName")==0)
		//set the SVARS to appropriate values
		SVAR Dir4_IntWvName
		SVAR Dir4_QvecWvName
		SVAR Dir4_ErrorWvName
		SVAR Dir4_DataFolderName
		Dir4_DataFolderName=popStr
			if(MSAS)
				 Dir4_IntWvName="M_DSM_Int"
				 Dir4_QvecWvName="M_DSM_Qvec"
				 Dir4_ErrorWvName="M_DSM_Error"
			else
				 Dir4_IntWvName="DSM_Int"
				 Dir4_QvecWvName="DSM_Qvec"
				 Dir4_ErrorWvName="DSM_Error"
			endif	
	endif
	if (cmpstr(ctrlName,"ASASDir5FolderName")==0)
		//set the SVARS to appropriate values
		SVAR Dir5_IntWvName
		SVAR Dir5_QvecWvName
		SVAR Dir5_ErrorWvName
		SVAR Dir5_DataFolderName
		Dir5_DataFolderName=popStr
			if(MSAS)
				 Dir5_IntWvName="M_DSM_Int"
				 Dir5_QvecWvName="M_DSM_Qvec"
				 Dir5_ErrorWvName="M_DSM_Error"
			else
				 Dir5_IntWvName="DSM_Int"
				 Dir5_QvecWvName="DSM_Qvec"
				 Dir5_ErrorWvName="DSM_Error"
			endif	
	endif
	if (cmpstr(ctrlName,"ASASDir6FolderName")==0)
		//set the SVARS to appropriate values
		SVAR Dir6_IntWvName
		SVAR Dir6_QvecWvName
		SVAR Dir6_ErrorWvName
		SVAR Dir6_DataFolderName
		Dir6_DataFolderName=popStr
			if(MSAS)
				 Dir6_IntWvName="M_DSM_Int"
				 Dir6_QvecWvName="M_DSM_Qvec"
				 Dir6_ErrorWvName="M_DSM_Error"
			else
				 Dir6_IntWvName="DSM_Int"
				 Dir6_QvecWvName="DSM_Qvec"
				 Dir6_ErrorWvName="DSM_Error"
			endif	
	endif
	

	if (cmpstr(ctrlName,"ASASNumberOfPopulations")==0)
		//set the SVARS to appropriate values
		NVAR NmbPop=root:Packages:AnisoSAS:NumberOfPopulations
		NmbPop = str2num(popStr)
		NVAR ActiveTab=root:Packages:AnisoSAS:ActiveTab
		ASAS_TabPanelControl("bla",ActiveTab)
		ASAS_FixControlsInPanel()
		doUpdate
	endif

	if (cmpstr(ctrlName,"Ani1NumberOfQs")==0)
		//set the panel properly
		NVAR NmbQs=root:Packages:AnisoSAS:Ani1_NumberOfQVectors
		NmbQs = str2num(popStr)
		ASAS_AniFixPanel1()
	endif

	if (cmpstr(ctrlName,"Ani2NumberOfQs")==0)
		//set the panel properly
		NVAR NmbQs=root:Packages:AnisoSAS:Ani2_NumberOfQVectors
		NmbQs = str2num(popStr)
		ASAS_AniFixPanel2()
	endif

	if (cmpstr(ctrlName,"Ani3NumberOfQs")==0)
		//set the panel properly
		NVAR NmbQs=root:Packages:AnisoSAS:Ani3_NumberOfQVectors
		NmbQs = str2num(popStr)
		ASAS_AniFixPanel3()
	endif
	
	
End


//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

Function ASAS_TabPanelControl(name,tab)
	String name
	Variable tab

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:AnisoSAS
	
	NVAR/Z ActiveTab=root:Packages:AnisoSAS:ActiveTab
	if (!NVAR_Exists(ActiveTab))
		variable/g root:Packages:AnisoSAS:ActiveTab
		NVAR ActiveTab=root:Packages:AnisoSAS:ActiveTab
	endif
	ActiveTab=tab+1

	NVAR NmbPop=root:Packages:AnisoSAS:NumberOfPopulations
	if (NmbPop==0)
		ActiveTab=0
	endif
	
	if ((tab<=NmbPop-1)&&(tab>=0))
		ASAS_UpdateDistGraph(tab)
	endif
	ASAS_CalcAppendResultsToGraph()
	DoWindow/F ASAS_InputPanel
	PopupMenu ASASNumberOfPopulations mode=NmbPop+1

	//Population 1 controls
	NVAR Pop1_FitRadius=root:Packages:AnisoSAS:Pop1_FitRadius
	NVAR Pop1_FitVolume=root:Packages:AnisoSAS:Pop1_FitVolumeFraction
	NVAR Pop1_FitPAlphaPar1
	NVAR Pop1_FitPAlphaPar2
	NVAR Pop1_FitPAlphaPar3
	NVAR Pop1_FitBOmegaPar1
	NVAR Pop1_FitBOmegaPar2
	NVAR Pop1_FitBOmegaPar3
	NVAR Pop1_UseBOmegaParam
	NVAR Pop1_UsePAlphaParam
	
	SetVariable ASASPop1DeltaRho,disable= (tab!=0 || NmbPop<1), win=ASAS_InputPanel
	SetVariable ASASPop1Beta,disable= (tab!=0 || NmbPop<1), win=ASAS_InputPanel
	SetVariable ASASPop1Radius,disable= (tab!=0 || NmbPop<1), win=ASAS_InputPanel
	CheckBox ASASPop1FitRadius,disable= (tab!=0 || NmbPop<1), win=ASAS_InputPanel
	SetVariable ASASPop1RadiusMin,disable= (tab!=0 || NmbPop<1 || !Pop1_FitRadius), win=ASAS_InputPanel
	SetVariable ASASPop1RadiusMax,disable = (tab!=0 || NmbPop<1 || !Pop1_FitRadius), win=ASAS_InputPanel
	SetVariable ASASPop1VolumeFraction,disable= (tab!=0 || NmbPop<1), win=ASAS_InputPanel
	CheckBox ASASPop1FitVolumeFraction,disable= (tab!=0 || NmbPop<1), win=ASAS_InputPanel
	SetVariable ASASPop1VolumeFractionMin,disable= (tab!=0 || NmbPop<1 || !Pop1_FitVolume), win=ASAS_InputPanel
	SetVariable ASASPop1VolumeFractionMax,disable = (tab!=0 || NmbPop<1 || !Pop1_FitVolume), win=ASAS_InputPanel

	SetVariable ASASPop1PAlphaSteps,disable= (tab!=0 || NmbPop<1), win=ASAS_InputPanel 
	CheckBox ASASPop1UsePAlphaParam,disable= (tab!=0 || NmbPop<1), win=ASAS_InputPanel
	Button ASASPop1GetAlphaWave, disable= (tab!=0 || NmbPop<1 || Pop1_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop1PAlphaPar1,disable= (tab!=0 || NmbPop<1 || !Pop1_UsePAlphaParam), win=ASAS_InputPanel
	CheckBox ASASPop1FitPAlphaPar1,disable= (tab!=0 || NmbPop<1 || !Pop1_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop1PAlphaPar1Min,disable= (tab!=0 || NmbPop<1 || !Pop1_FitPAlphaPar1 || !Pop1_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop1PAlphaPar1Max,disable= (tab!=0 || NmbPop<1 || !Pop1_FitPAlphaPar1 || !Pop1_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop1PAlphaPar2,disable= (tab!=0 || NmbPop<1 || !Pop1_UsePAlphaParam), win=ASAS_InputPanel
	CheckBox  ASASPop1FitPAlphaPar2,disable= (tab!=0 || NmbPop<1 || !Pop1_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop1PAlphaPar2Min,disable= (tab!=0 || NmbPop<1|| !Pop1_FitPAlphaPar2 || !Pop1_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop1PAlphaPar2Max,disable= (tab!=0 || NmbPop<1|| !Pop1_FitPAlphaPar2 || !Pop1_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop1PAlphaPar3,disable= (tab!=0 || NmbPop<1 || !Pop1_UsePAlphaParam), win=ASAS_InputPanel
	CheckBox ASASPop1FitPAlphaPar3,disable= (tab!=0 || NmbPop<1 || !Pop1_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop1PAlphaPar3Min,disable= (tab!=0 || NmbPop<1 || !Pop1_FitPAlphaPar3 || !Pop1_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop1PAlphaPar3Max,disable= (tab!=0 || NmbPop<1 || !Pop1_FitPAlphaPar3 || !Pop1_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop1BOmegaSteps,disable= (tab!=0 || NmbPop<1), win=ASAS_InputPanel
	CheckBox ASASPop1UseBOmegaParam,disable= (tab!=0 || NmbPop<1), win=ASAS_InputPanel
	Button ASASPop1GetOmegaWave, disable= (tab!=0 || NmbPop<1 || Pop1_UseBOmegaParam), win=ASAS_InputPanel

	SetVariable ASASPop1BOmegaPar1,disable= (tab!=0 || NmbPop<1 || !Pop1_UseBOmegaParam), win=ASAS_InputPanel
	CheckBox ASASPop1FitBOmegaPar1,disable= (tab!=0 || NmbPop<1 || !Pop1_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop1BOmegaPar1Min,disable= (tab!=0 || NmbPop<1 || !Pop1_FitBOmegaPar1 || !Pop1_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop1BOmegaPar1Max,disable= (tab!=0 || NmbPop<1 || !Pop1_FitBOmegaPar1 || !Pop1_UseBOmegaParam), win=ASAS_InputPanel

	SetVariable ASASPop1BOmegaPar2,disable= (tab!=0 || NmbPop<1 || !Pop1_UseBOmegaParam), win=ASAS_InputPanel
	CheckBox ASASPop1FitBOmegaPar2,disable= (tab!=0 || NmbPop<1 || !Pop1_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop1BOmegaPar2Min,disable= (tab!=0 || NmbPop<1  || !Pop1_FitBOmegaPar2 || !Pop1_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop1BOmegaPar2Max,disable= (tab!=0 || NmbPop<1 || !Pop1_FitBOmegaPar2 || !Pop1_UseBOmegaParam), win=ASAS_InputPanel

	SetVariable ASASPop1BOmegaPar3,disable= (tab!=0 || NmbPop<1 || !Pop1_UseBOmegaParam), win=ASAS_InputPanel
	CheckBox ASASPop1FitBOmegaPar3,disable= (tab!=0 || NmbPop<1 || !Pop1_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop1BOmegaPar3Min,disable= (tab!=0 || NmbPop<1 || !Pop1_FitBOmegaPar3 || !Pop1_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop1BOmegaPar3Max,disable= (tab!=0 || NmbPop<1 || !Pop1_FitBOmegaPar3 || !Pop1_UseBOmegaParam), win=ASAS_InputPanel
	
	SetVariable ASASPop1SurfaceArea,disable= (tab!=0 || NmbPop<1), win=ASAS_InputPanel
	CheckBox ASASPop1UseInterference,disable= (tab!=0 || NmbPop<1), win=ASAS_InputPanel
	//Population 2 controls
	NVAR Pop2_FitRadius=root:Packages:AnisoSAS:Pop2_FitRadius
	NVAR Pop2_FitVolume=root:Packages:AnisoSAS:Pop2_FitVolumeFraction
	NVAR Pop2_FitPAlphaPar1
	NVAR Pop2_FitPAlphaPar2
	NVAR Pop2_FitPAlphaPar3
	NVAR Pop2_FitBOmegaPar1
	NVAR Pop2_FitBOmegaPar2
	NVAR Pop2_FitBOmegaPar3
	NVAR Pop2_UseBOmegaParam
	NVAR Pop2_UsePAlphaParam
	
	SetVariable ASASPop2DeltaRho,disable= (tab!=1 || NmbPop<2), win=ASAS_InputPanel
	SetVariable ASASPop2Beta,disable= (tab!=1 || NmbPop<2), win=ASAS_InputPanel
	SetVariable ASASPop2Radius,disable= (tab!=1 || NmbPop<2), win=ASAS_InputPanel
	CheckBox ASASPop2FitRadius,disable= (tab!=1 || NmbPop<2), win=ASAS_InputPanel
	SetVariable ASASPop2RadiusMin,disable= (tab!=1 || NmbPop<2 || !Pop2_FitRadius), win=ASAS_InputPanel
	SetVariable ASASPop2RadiusMax,disable = (tab!=1 || NmbPop<2 || !Pop2_FitRadius), win=ASAS_InputPanel
	SetVariable ASASPop2VolumeFraction,disable= (tab!=1 || NmbPop<2), win=ASAS_InputPanel
	CheckBox ASASPop2FitVolumeFraction,disable= (tab!=1 || NmbPop<2), win=ASAS_InputPanel
	SetVariable ASASPop2VolumeFractionMin,disable= (tab!=1 || NmbPop<2 || !Pop2_FitVolume), win=ASAS_InputPanel
	SetVariable ASASPop2VolumeFractionMax,disable = (tab!=1 || NmbPop<2 || !Pop2_FitVolume), win=ASAS_InputPanel

	SetVariable ASASPop2PAlphaSteps,disable= (tab!=1 || NmbPop<2), win=ASAS_InputPanel 
	CheckBox ASASPop2UsePAlphaParam,disable= (tab!=1 || NmbPop<2), win=ASAS_InputPanel
	Button ASASPop2GetAlphaWave, disable= (tab!=1 || NmbPop<2 || Pop2_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop2PAlphaPar1,disable= (tab!=1 || NmbPop<2 || !Pop2_UsePAlphaParam), win=ASAS_InputPanel
	CheckBox ASASPop2FitPAlphaPar1,disable= (tab!=1 || NmbPop<2 || !Pop2_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop2PAlphaPar1Min,disable= (tab!=1 || NmbPop<2 || !Pop2_FitPAlphaPar1 || !Pop2_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop2PAlphaPar1Max,disable= (tab!=1 || NmbPop<2 || !Pop2_FitPAlphaPar1 || !Pop2_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop2PAlphaPar2,disable= (tab!=1 || NmbPop<2 || !Pop2_UsePAlphaParam), win=ASAS_InputPanel
	CheckBox  ASASPop2FitPAlphaPar2,disable= (tab!=1 || NmbPop<2 || !Pop2_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop2PAlphaPar2Min,disable= (tab!=1 || NmbPop<2|| !Pop2_FitPAlphaPar2 || !Pop2_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop2PAlphaPar2Max,disable= (tab!=1 || NmbPop<2|| !Pop2_FitPAlphaPar2 || !Pop2_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop2PAlphaPar3,disable= (tab!=1 || NmbPop<2 || !Pop2_UsePAlphaParam), win=ASAS_InputPanel
	CheckBox ASASPop2FitPAlphaPar3,disable= (tab!=1 || NmbPop<2 || !Pop2_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop2PAlphaPar3Min,disable= (tab!=1 || NmbPop<2 || !Pop2_FitPAlphaPar3 || !Pop2_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop2PAlphaPar3Max,disable= (tab!=1 || NmbPop<2 || !Pop2_FitPAlphaPar3 || !Pop2_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop2BOmegaSteps,disable= (tab!=1 || NmbPop<2), win=ASAS_InputPanel
	CheckBox ASASPop2UseBOmegaParam,disable= (tab!=1 || NmbPop<2), win=ASAS_InputPanel
	Button ASASPop2GetOmegaWave, disable= (tab!=1 || NmbPop<2 || Pop2_UseBOmegaParam), win=ASAS_InputPanel

	SetVariable ASASPop2BOmegaPar1,disable= (tab!=1 || NmbPop<2 || !Pop2_UseBOmegaParam), win=ASAS_InputPanel
	CheckBox ASASPop2FitBOmegaPar1,disable= (tab!=1 || NmbPop<2 || !Pop2_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop2BOmegaPar1Min,disable= (tab!=1 || NmbPop<2 || !Pop2_FitBOmegaPar1 || !Pop2_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop2BOmegaPar1Max,disable= (tab!=1 || NmbPop<2 || !Pop2_FitBOmegaPar1 || !Pop2_UseBOmegaParam), win=ASAS_InputPanel

	SetVariable ASASPop2BOmegaPar2,disable= (tab!=1 || NmbPop<2 || !Pop2_UseBOmegaParam), win=ASAS_InputPanel
	CheckBox ASASPop2FitBOmegaPar2,disable= (tab!=1 || NmbPop<2 || !Pop2_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop2BOmegaPar2Min,disable= (tab!=1 || NmbPop<2  || !Pop2_FitBOmegaPar2 || !Pop2_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop2BOmegaPar2Max,disable= (tab!=1 || NmbPop<2 || !Pop2_FitBOmegaPar2 || !Pop2_UseBOmegaParam), win=ASAS_InputPanel

	SetVariable ASASPop2BOmegaPar3,disable= (tab!=1 || NmbPop<2 || !Pop2_UseBOmegaParam), win=ASAS_InputPanel
	CheckBox ASASPop2FitBOmegaPar3,disable= (tab!=1 || NmbPop<2 || !Pop2_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop2BOmegaPar3Min,disable= (tab!=1 || NmbPop<2 || !Pop2_FitBOmegaPar3 || !Pop2_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop2BOmegaPar3Max,disable= (tab!=1 || NmbPop<2 || !Pop2_FitBOmegaPar3 || !Pop2_UseBOmegaParam), win=ASAS_InputPanel

	SetVariable ASASPop2SurfaceArea,disable= (tab!=1 || NmbPop<2), win=ASAS_InputPanel
	CheckBox ASASPop2UseInterference,disable= (tab!=1 || NmbPop<2), win=ASAS_InputPanel
	
	//Population 3 controls
	NVAR Pop3_FitRadius=root:Packages:AnisoSAS:Pop3_FitRadius
	NVAR Pop3_FitVolume=root:Packages:AnisoSAS:Pop3_FitVolumeFraction
	NVAR Pop3_FitPAlphaPar1
	NVAR Pop3_FitPAlphaPar2
	NVAR Pop3_FitPAlphaPar3
	NVAR Pop3_FitBOmegaPar1
	NVAR Pop3_FitBOmegaPar2
	NVAR Pop3_FitBOmegaPar3
	NVAR Pop3_UseBOmegaParam
	NVAR Pop3_UsePAlphaParam
	
	SetVariable ASASPop3DeltaRho,disable= (tab!=2 || NmbPop<3), win=ASAS_InputPanel
	SetVariable ASASPop3Beta,disable= (tab!=2 || NmbPop<3), win=ASAS_InputPanel
	SetVariable ASASPop3Radius,disable= (tab!=2 || NmbPop<3), win=ASAS_InputPanel
	CheckBox ASASPop3FitRadius,disable= (tab!=2 || NmbPop<3), win=ASAS_InputPanel
	SetVariable ASASPop3RadiusMin,disable= (tab!=2 || NmbPop<3 || !Pop3_FitRadius), win=ASAS_InputPanel
	SetVariable ASASPop3RadiusMax,disable = (tab!=2 || NmbPop<3 || !Pop3_FitRadius), win=ASAS_InputPanel
	SetVariable ASASPop3VolumeFraction,disable= (tab!=2 || NmbPop<3), win=ASAS_InputPanel
	CheckBox ASASPop3FitVolumeFraction,disable= (tab!=2 || NmbPop<3), win=ASAS_InputPanel
	SetVariable ASASPop3VolumeFractionMin,disable= (tab!=2 || NmbPop<3 || !Pop3_FitVolume), win=ASAS_InputPanel
	SetVariable ASASPop3VolumeFractionMax,disable = (tab!=2 || NmbPop<3 || !Pop3_FitVolume), win=ASAS_InputPanel

	SetVariable ASASPop3PAlphaSteps,disable= (tab!=2 || NmbPop<3), win=ASAS_InputPanel 
	CheckBox ASASPop3UsePAlphaParam,disable= (tab!=2 || NmbPop<3), win=ASAS_InputPanel
	Button ASASPop3GetAlphaWave, disable= (tab!=2 || NmbPop<3 || Pop3_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop3PAlphaPar1,disable= (tab!=2 || NmbPop<3 || !Pop3_UsePAlphaParam), win=ASAS_InputPanel
	CheckBox ASASPop3FitPAlphaPar1,disable= (tab!=2 || NmbPop<3 || !Pop3_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop3PAlphaPar1Min,disable= (tab!=2 || NmbPop<3 || !Pop3_FitPAlphaPar1 || !Pop3_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop3PAlphaPar1Max,disable= (tab!=2 || NmbPop<3 || !Pop3_FitPAlphaPar1 || !Pop3_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop3PAlphaPar2,disable= (tab!=2 || NmbPop<3 || !Pop3_UsePAlphaParam), win=ASAS_InputPanel
	CheckBox  ASASPop3FitPAlphaPar2,disable= (tab!=2 || NmbPop<3 || !Pop3_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop3PAlphaPar2Min,disable= (tab!=2 || NmbPop<3|| !Pop3_FitPAlphaPar2 || !Pop3_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop3PAlphaPar2Max,disable= (tab!=2 || NmbPop<3|| !Pop3_FitPAlphaPar2 || !Pop3_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop3PAlphaPar3,disable= (tab!=2 || NmbPop<3 || !Pop3_UsePAlphaParam), win=ASAS_InputPanel
	CheckBox ASASPop3FitPAlphaPar3,disable= (tab!=2 || NmbPop<3 || !Pop3_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop3PAlphaPar3Min,disable= (tab!=2 || NmbPop<3 || !Pop3_FitPAlphaPar3 || !Pop3_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop3PAlphaPar3Max,disable= (tab!=2 || NmbPop<3 || !Pop3_FitPAlphaPar3 || !Pop3_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop3BOmegaSteps,disable= (tab!=2 || NmbPop<3), win=ASAS_InputPanel
	CheckBox ASASPop3UseBOmegaParam,disable= (tab!=2 || NmbPop<3), win=ASAS_InputPanel
	Button ASASPop3GetOmegaWave, disable= (tab!=2 || NmbPop<3 || Pop3_UseBOmegaParam), win=ASAS_InputPanel

	SetVariable ASASPop3BOmegaPar1,disable= (tab!=2 || NmbPop<3 || !Pop3_UseBOmegaParam), win=ASAS_InputPanel
	CheckBox ASASPop3FitBOmegaPar1,disable= (tab!=2 || NmbPop<3 || !Pop3_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop3BOmegaPar1Min,disable= (tab!=2 || NmbPop<3 || !Pop3_FitBOmegaPar1 || !Pop3_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop3BOmegaPar1Max,disable= (tab!=2 || NmbPop<3 || !Pop3_FitBOmegaPar1 || !Pop3_UseBOmegaParam), win=ASAS_InputPanel

	SetVariable ASASPop3BOmegaPar2,disable= (tab!=2 || NmbPop<3 || !Pop3_UseBOmegaParam), win=ASAS_InputPanel
	CheckBox ASASPop3FitBOmegaPar2,disable= (tab!=2 || NmbPop<3 || !Pop3_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop3BOmegaPar2Min,disable= (tab!=2 || NmbPop<3  || !Pop3_FitBOmegaPar2 || !Pop3_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop3BOmegaPar2Max,disable= (tab!=2 || NmbPop<3 || !Pop3_FitBOmegaPar2 || !Pop3_UseBOmegaParam), win=ASAS_InputPanel

	SetVariable ASASPop3BOmegaPar3,disable= (tab!=2 || NmbPop<3 || !Pop3_UseBOmegaParam), win=ASAS_InputPanel
	CheckBox ASASPop3FitBOmegaPar3,disable= (tab!=2 || NmbPop<3 || !Pop3_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop3BOmegaPar3Min,disable= (tab!=2 || NmbPop<3 || !Pop3_FitBOmegaPar3 || !Pop3_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop3BOmegaPar3Max,disable= (tab!=2 || NmbPop<3 || !Pop3_FitBOmegaPar3 || !Pop3_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop3SurfaceArea,disable= (tab!=2 || NmbPop<3), win=ASAS_InputPanel
	CheckBox ASASPop3UseInterference,disable= (tab!=2 || NmbPop<3), win=ASAS_InputPanel

	//Population 4 controls
	NVAR Pop4_FitRadius=root:Packages:AnisoSAS:Pop4_FitRadius
	NVAR Pop4_FitVolume=root:Packages:AnisoSAS:Pop4_FitVolumeFraction
	NVAR Pop4_FitPAlphaPar1
	NVAR Pop4_FitPAlphaPar2
	NVAR Pop4_FitPAlphaPar3
	NVAR Pop4_FitBOmegaPar1
	NVAR Pop4_FitBOmegaPar2
	NVAR Pop4_FitBOmegaPar3
	NVAR Pop4_UseBOmegaParam
	NVAR Pop4_UsePAlphaParam
	
	SetVariable ASASPop4DeltaRho,disable= (tab!=3 || NmbPop<4), win=ASAS_InputPanel
	SetVariable ASASPop4Beta,disable= (tab!=3 || NmbPop<4), win=ASAS_InputPanel
	SetVariable ASASPop4Radius,disable= (tab!=3 || NmbPop<4), win=ASAS_InputPanel
	CheckBox ASASPop4FitRadius,disable= (tab!=3 || NmbPop<4), win=ASAS_InputPanel
	SetVariable ASASPop4RadiusMin,disable= (tab!=3 || NmbPop<4 || !Pop4_FitRadius), win=ASAS_InputPanel
	SetVariable ASASPop4RadiusMax,disable = (tab!=3 || NmbPop<4 || !Pop4_FitRadius), win=ASAS_InputPanel
	SetVariable ASASPop4VolumeFraction,disable= (tab!=3 || NmbPop<4), win=ASAS_InputPanel
	CheckBox ASASPop4FitVolumeFraction,disable= (tab!=3 || NmbPop<4), win=ASAS_InputPanel
	SetVariable ASASPop4VolumeFractionMin,disable= (tab!=3 || NmbPop<4 || !Pop4_FitVolume), win=ASAS_InputPanel
	SetVariable ASASPop4VolumeFractionMax,disable = (tab!=3 || NmbPop<4 || !Pop4_FitVolume), win=ASAS_InputPanel

	SetVariable ASASPop4PAlphaSteps,disable= (tab!=3 || NmbPop<4), win=ASAS_InputPanel 
	CheckBox ASASPop4UsePAlphaParam,disable= (tab!=3 || NmbPop<4), win=ASAS_InputPanel
	Button ASASPop4GetAlphaWave, disable= (tab!=3 || NmbPop<4 || Pop4_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop4PAlphaPar1,disable= (tab!=3 || NmbPop<4 || !Pop4_UsePAlphaParam), win=ASAS_InputPanel
	CheckBox ASASPop4FitPAlphaPar1,disable= (tab!=3 || NmbPop<4 || !Pop4_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop4PAlphaPar1Min,disable= (tab!=3 || NmbPop<4 || !Pop4_FitPAlphaPar1 || !Pop4_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop4PAlphaPar1Max,disable= (tab!=3 || NmbPop<4 || !Pop4_FitPAlphaPar1 || !Pop4_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop4PAlphaPar2,disable= (tab!=3 || NmbPop<4 || !Pop4_UsePAlphaParam), win=ASAS_InputPanel
	CheckBox  ASASPop4FitPAlphaPar2,disable= (tab!=3 || NmbPop<4 || !Pop4_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop4PAlphaPar2Min,disable= (tab!=3 || NmbPop<4|| !Pop4_FitPAlphaPar2 || !Pop4_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop4PAlphaPar2Max,disable= (tab!=3 || NmbPop<4|| !Pop4_FitPAlphaPar2 || !Pop4_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop4PAlphaPar3,disable= (tab!=3 || NmbPop<4 || !Pop4_UsePAlphaParam), win=ASAS_InputPanel
	CheckBox ASASPop4FitPAlphaPar3,disable= (tab!=3 || NmbPop<4 || !Pop4_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop4PAlphaPar3Min,disable= (tab!=3 || NmbPop<4 || !Pop4_FitPAlphaPar3 || !Pop4_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop4PAlphaPar3Max,disable= (tab!=3 || NmbPop<4 || !Pop4_FitPAlphaPar3 || !Pop4_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop4BOmegaSteps,disable= (tab!=3 || NmbPop<4), win=ASAS_InputPanel
	CheckBox ASASPop4UseBOmegaParam,disable= (tab!=3 || NmbPop<4), win=ASAS_InputPanel
	Button ASASPop4GetOmegaWave, disable= (tab!=3 || NmbPop<4 || Pop4_UseBOmegaParam), win=ASAS_InputPanel

	SetVariable ASASPop4BOmegaPar1,disable= (tab!=3 || NmbPop<4 || !Pop4_UseBOmegaParam), win=ASAS_InputPanel
	CheckBox ASASPop4FitBOmegaPar1,disable= (tab!=3 || NmbPop<4 || !Pop4_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop4BOmegaPar1Min,disable= (tab!=3 || NmbPop<4 || !Pop4_FitBOmegaPar1 || !Pop4_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop4BOmegaPar1Max,disable= (tab!=3 || NmbPop<4 || !Pop4_FitBOmegaPar1 || !Pop4_UseBOmegaParam), win=ASAS_InputPanel

	SetVariable ASASPop4BOmegaPar2,disable= (tab!=3 || NmbPop<4 || !Pop4_UseBOmegaParam), win=ASAS_InputPanel
	CheckBox ASASPop4FitBOmegaPar2,disable= (tab!=3 || NmbPop<4 || !Pop4_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop4BOmegaPar2Min,disable= (tab!=3 || NmbPop<4  || !Pop4_FitBOmegaPar2 || !Pop4_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop4BOmegaPar2Max,disable= (tab!=3 || NmbPop<4 || !Pop4_FitBOmegaPar2 || !Pop4_UseBOmegaParam), win=ASAS_InputPanel

	SetVariable ASASPop4BOmegaPar3,disable= (tab!=3 || NmbPop<4 || !Pop4_UseBOmegaParam), win=ASAS_InputPanel
	CheckBox ASASPop4FitBOmegaPar3,disable= (tab!=3 || NmbPop<4 || !Pop4_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop4BOmegaPar3Min,disable= (tab!=3 || NmbPop<4 || !Pop4_FitBOmegaPar3 || !Pop4_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop4BOmegaPar3Max,disable= (tab!=3 || NmbPop<4 || !Pop4_FitBOmegaPar3 || !Pop4_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop4SurfaceArea,disable= (tab!=3 || NmbPop<4), win=ASAS_InputPanel
	CheckBox ASASPop4UseInterference,disable= (tab!=3 || NmbPop<4), win=ASAS_InputPanel
//	TabControl DistTabs, win=ASAS_InputPanel, value=ActiveTab-1
	//Population 5 controls
	NVAR Pop5_FitRadius=root:Packages:AnisoSAS:Pop5_FitRadius
	NVAR Pop5_FitVolume=root:Packages:AnisoSAS:Pop5_FitVolumeFraction
	NVAR Pop5_FitPAlphaPar1
	NVAR Pop5_FitPAlphaPar2
	NVAR Pop5_FitPAlphaPar3
	NVAR Pop5_FitBOmegaPar1
	NVAR Pop5_FitBOmegaPar2
	NVAR Pop5_FitBOmegaPar3
	NVAR Pop5_UseBOmegaParam
	NVAR Pop5_UsePAlphaParam
	
	SetVariable ASASPop5DeltaRho,disable= (tab!=4 || NmbPop<5), win=ASAS_InputPanel
	SetVariable ASASPop5Beta,disable= (tab!=4 || NmbPop<5), win=ASAS_InputPanel
	SetVariable ASASPop5Radius,disable= (tab!=4 || NmbPop<5), win=ASAS_InputPanel
	CheckBox ASASPop5FitRadius,disable= (tab!=4 || NmbPop<5), win=ASAS_InputPanel
	SetVariable ASASPop5RadiusMin,disable= (tab!=4 || NmbPop<5 || !Pop5_FitRadius), win=ASAS_InputPanel
	SetVariable ASASPop5RadiusMax,disable = (tab!=4 || NmbPop<5 || !Pop5_FitRadius), win=ASAS_InputPanel
	SetVariable ASASPop5VolumeFraction,disable= (tab!=4 || NmbPop<5), win=ASAS_InputPanel
	CheckBox ASASPop5FitVolumeFraction,disable= (tab!=4 || NmbPop<5), win=ASAS_InputPanel
	SetVariable ASASPop5VolumeFractionMin,disable= (tab!=4 || NmbPop<5 || !Pop5_FitVolume), win=ASAS_InputPanel
	SetVariable ASASPop5VolumeFractionMax,disable = (tab!=4 || NmbPop<5 || !Pop5_FitVolume), win=ASAS_InputPanel

	SetVariable ASASPop5PAlphaSteps,disable= (tab!=4 || NmbPop<5), win=ASAS_InputPanel 
	CheckBox ASASPop5UsePAlphaParam,disable= (tab!=4 || NmbPop<5), win=ASAS_InputPanel
	Button ASASPop5GetAlphaWave, disable= (tab!=4 || NmbPop<5 || Pop5_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop5PAlphaPar1,disable= (tab!=4 || NmbPop<5 || !Pop5_UsePAlphaParam), win=ASAS_InputPanel
	CheckBox ASASPop5FitPAlphaPar1,disable= (tab!=4 || NmbPop<5 || !Pop5_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop5PAlphaPar1Min,disable= (tab!=4 || NmbPop<5 || !Pop5_FitPAlphaPar1 || !Pop5_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop5PAlphaPar1Max,disable= (tab!=4 || NmbPop<5 || !Pop5_FitPAlphaPar1 || !Pop5_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop5PAlphaPar2,disable= (tab!=4 || NmbPop<5 || !Pop5_UsePAlphaParam), win=ASAS_InputPanel
	CheckBox  ASASPop5FitPAlphaPar2,disable= (tab!=4 || NmbPop<5 || !Pop5_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop5PAlphaPar2Min,disable= (tab!=4 || NmbPop<5|| !Pop5_FitPAlphaPar2 || !Pop5_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop5PAlphaPar2Max,disable= (tab!=4 || NmbPop<5|| !Pop5_FitPAlphaPar2 || !Pop5_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop5PAlphaPar3,disable= (tab!=4 || NmbPop<5 || !Pop5_UsePAlphaParam), win=ASAS_InputPanel
	CheckBox ASASPop5FitPAlphaPar3,disable= (tab!=4 || NmbPop<5 || !Pop5_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop5PAlphaPar3Min,disable= (tab!=4 || NmbPop<5 || !Pop5_FitPAlphaPar3 || !Pop5_UsePAlphaParam), win=ASAS_InputPanel
	SetVariable ASASPop5PAlphaPar3Max,disable= (tab!=4 || NmbPop<5 || !Pop5_FitPAlphaPar3 || !Pop5_UsePAlphaParam), win=ASAS_InputPanel

	SetVariable ASASPop5BOmegaSteps,disable= (tab!=4 || NmbPop<5), win=ASAS_InputPanel
	CheckBox ASASPop5UseBOmegaParam,disable= (tab!=4 || NmbPop<5), win=ASAS_InputPanel
	Button ASASPop5GetOmegaWave, disable= (tab!=4 || NmbPop<5 || Pop5_UseBOmegaParam), win=ASAS_InputPanel

	SetVariable ASASPop5BOmegaPar1,disable= (tab!=4 || NmbPop<5 || !Pop5_UseBOmegaParam), win=ASAS_InputPanel
	CheckBox ASASPop5FitBOmegaPar1,disable= (tab!=4 || NmbPop<5 || !Pop5_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop5BOmegaPar1Min,disable= (tab!=4 || NmbPop<5 || !Pop5_FitBOmegaPar1 || !Pop5_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop5BOmegaPar1Max,disable= (tab!=4 || NmbPop<5 || !Pop5_FitBOmegaPar1 || !Pop5_UseBOmegaParam), win=ASAS_InputPanel

	SetVariable ASASPop5BOmegaPar2,disable= (tab!=4 || NmbPop<5 || !Pop5_UseBOmegaParam), win=ASAS_InputPanel
	CheckBox ASASPop5FitBOmegaPar2,disable= (tab!=4 || NmbPop<5 || !Pop5_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop5BOmegaPar2Min,disable= (tab!=4 || NmbPop<5  || !Pop5_FitBOmegaPar2 || !Pop5_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop5BOmegaPar2Max,disable= (tab!=4 || NmbPop<5 || !Pop5_FitBOmegaPar2 || !Pop5_UseBOmegaParam), win=ASAS_InputPanel

	SetVariable ASASPop5BOmegaPar3,disable= (tab!=4 || NmbPop<5 || !Pop5_UseBOmegaParam), win=ASAS_InputPanel
	CheckBox ASASPop5FitBOmegaPar3,disable= (tab!=4 || NmbPop<5 || !Pop5_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop5BOmegaPar3Min,disable= (tab!=4 || NmbPop<5 || !Pop5_FitBOmegaPar3 || !Pop5_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop5BOmegaPar3Max,disable= (tab!=4 || NmbPop<5 || !Pop5_FitBOmegaPar3 || !Pop5_UseBOmegaParam), win=ASAS_InputPanel
	SetVariable ASASPop5SurfaceArea,disable= (tab!=4 || NmbPop<5), win=ASAS_InputPanel
	CheckBox ASASPop5UseInterference,disable= (tab!=4 || NmbPop<5), win=ASAS_InputPanel
			
end


//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 


Function ASAS_FixControlsInPanel()

	setDataFolder root:Packages:AnisoSAS
	DoWindow /F ASAS_InputPanel
	//first display only input direction controls
	NVAR NoD=NumberOfDirections
	
	PopupMenu ASASNumberOfDirections, mode=NoD+1
	
	PopupMenu ASASDir1FolderName disable = (NoD<1), win=ASAS_InputPanel
	SetVariable ASASDir1AlphaQ disable = (NoD<1), win=ASAS_InputPanel
	SetVariable ASASDir1OmegaQ disable = (NoD<1), win=ASAS_InputPanel
	SetVariable ASASDir1Background disable = (NoD<1), win=ASAS_InputPanel

	PopupMenu ASASDir2FolderName disable = (NoD<2), win=ASAS_InputPanel
	SetVariable ASASDir2AlphaQ disable = (NoD<2), win=ASAS_InputPanel
	SetVariable ASASDir2OmegaQ disable = (NoD<2), win=ASAS_InputPanel
	SetVariable ASASDir2Background disable = (NoD<2), win=ASAS_InputPanel

	PopupMenu ASASDir3FolderName disable = (NoD<3), win=ASAS_InputPanel
	SetVariable ASASDir3AlphaQ disable = (NoD<3), win=ASAS_InputPanel
	SetVariable ASASDir3OmegaQ disable = (NoD<3), win=ASAS_InputPanel
	SetVariable ASASDir3Background disable = (NoD<3), win=ASAS_InputPanel

	PopupMenu ASASDir4FolderName disable = (NoD<4), win=ASAS_InputPanel
	SetVariable ASASDir4AlphaQ disable = (NoD<4), win=ASAS_InputPanel
	SetVariable ASASDir4OmegaQ disable = (NoD<4), win=ASAS_InputPanel
	SetVariable ASASDir4Background disable = (NoD<4), win=ASAS_InputPanel

	PopupMenu ASASDir5FolderName disable = (NoD<5), win=ASAS_InputPanel
	SetVariable ASASDir5AlphaQ disable = (NoD<5), win=ASAS_InputPanel
	SetVariable ASASDir5OmegaQ disable = (NoD<5), win=ASAS_InputPanel
	SetVariable ASASDir5Background disable = (NoD<5), win=ASAS_InputPanel

	PopupMenu ASASDir6FolderName disable = (NoD<6), win=ASAS_InputPanel
	SetVariable ASASDir6AlphaQ disable = (NoD<6), win=ASAS_InputPanel
	SetVariable ASASDir6OmegaQ disable = (NoD<6), win=ASAS_InputPanel
	SetVariable ASASDir6Background disable = (NoD<6), win=ASAS_InputPanel

end