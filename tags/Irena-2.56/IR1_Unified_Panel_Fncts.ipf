#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.19

//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.19 catch for slit smeared data if the Qmax is too small. It must be at least 3*slit length
//2.18 modified to use rebinning routine from General procedures
//2.17 added check that Scripting tool does not have "UseResults" selected. This caused bug with two different types of data selected in ST.
//2.16 added some Dale's modifications
//2.15 added Extended option for warnings to avoid history area poluting. Fixes provided by DWS
//2.14 added IR2S_SortListOfAvailableFldrs() to scripting tool call. Added option to rebin data on import. 
//2.13 added option to link B to Rg/G/P values using Hammouda calculations
//2.12 Removed FitRgCO option
//2.11 changes to provide user with fit parameters review panel befroe fitting
//2.10 fixed bug when Scripting tool panel could get out of sync with main UF panel. 
//2.09 added NoLimits option
//2.08 fixed checking of level validity not to fail on levels with only power law part. 
//2.07 adds confidence evaluation tool 
//2.06 modified GUI, removed steps and added dynamical changing (5%) of the step. 
//2.05 added button function to call scriting tool. 
//2.04 changed to modify limits automatically when new value for parameter is set. 
//2.03 modified CheckProc to try to speed up the process
//2.02 added license for ANL

//version 2.01 has changes to accomodate the Analyze results


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_PanelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
	
	NVAR AutoUpdate=root:Packages:Irena_UnifFit:UpdateAutomatically
	
	if (cmpstr(ctrlName,"SASBackground")==0)
		//here goes what happens when user changes the SASBackground in distribution
		SetVariable SASBackground,win=IR1A_ControlPanel, limits={0,Inf,varNum/20}
		IR1A_AutoUpdateIfSelected()
	endif
//	if (cmpstr(ctrlName,"SASBackgroundStep")==0)
//		//here goes what happens when user changes the SASBackground in distribution
//	endif
	if (cmpstr(ctrlName,"SubtractBackground")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1A_GraphMeasuredData("Unified")
	endif

//Level1

	if (cmpstr(ctrlName,"Level1Rg")==0)
		//here goes what happens when user changes the Rg
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level1Rg")
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1RgLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level1RgHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level1G")==0)
		//here goes what happens when user changes the G
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level1G")
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1GLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level1GHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level1P")==0)
		//here goes what happens when user changes the P
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level1P")
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1PLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level1PHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level1B")==0)
		//here goes what happens when user changes the B
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level1B")
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1BLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level1BHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level1ETA")==0)
		//here goes what happens when user changes the ETA
		IR1A_FixLimitsInPanel("Level1ETA")
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1ETALowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level1ETAHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level1PACK")==0)
		//here goes what happens when user changes the PACK
		IR1A_FixLimitsInPanel("Level1PACK")
		IR1A_CorrectLimitsAndValues()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1PACKLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level1PACKHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level1RGCO")==0)
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1RGCOLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level1RGCOHighLimit")==0)

	endif

//	if (cmpstr(ctrlName,"Level1RgStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level1RgStep=root:Packages:Irena_UnifFit:Level1RgStep
//		Level1RGStep=VarNum
//		SetVariable Level1RgStep,limits={0,inf,(0.1*Level1RgStep)}
//		SetVariable Level1RG,limits={0,inf,Level1RgStep}
//	endif
//	if (cmpstr(ctrlName,"Level1GStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level1GStep=root:Packages:Irena_UnifFit:Level1GStep
//		Level1GStep=VarNum
//		SetVariable Level1GStep,limits={0,inf,(0.1*Level1GStep)}
//		SetVariable Level1G,limits={0,inf,Level1GStep}
//	endif
//	if (cmpstr(ctrlName,"Level1PStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level1PStep=root:Packages:Irena_UnifFit:Level1PStep
//		Level1PStep=VarNum
//		SetVariable Level1PStep,limits={0,inf,(0.1*Level1PStep)}
//		SetVariable Level1P,limits={0,inf,Level1PStep}
//	endif
//	if (cmpstr(ctrlName,"Level1BStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level1BStep=root:Packages:Irena_UnifFit:Level1BStep
//		Level1BStep=VarNum
//		SetVariable Level1BStep,limits={0,inf,(0.1*Level1BStep)}
//		SetVariable Level1B,limits={0,inf,Level1BStep}
//	endif
//	if (cmpstr(ctrlName,"Level1EtaStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level1EtaStep=root:Packages:Irena_UnifFit:Level1EtaStep
//		Level1EtaStep=VarNum
//		SetVariable Level1EtaStep,limits={0,inf,(0.1*Level1EtaStep)}
//		SetVariable Level1Eta,limits={0,inf,Level1EtaStep}
//	endif
//	if (cmpstr(ctrlName,"Level1PackStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level1PackStep=root:Packages:Irena_UnifFit:Level1PackStep
//		Level1PackStep=VarNum
//		SetVariable Level1PackStep,limits={0,inf,(0.1*Level1PackStep)}
//		SetVariable Level1Pack,limits={0,inf,Level1PackStep}
//	endif
//


//Level2

	if (cmpstr(ctrlName,"Level2Rg")==0)
		//here goes what happens when user changes the Rg
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level2Rg")
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level2RgLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level2RgHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level2G")==0)
		//here goes what happens when user changes the G
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level2G")
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level2GLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level2GHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level2P")==0)
		//here goes what happens when user changes the P
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level2P")
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level2PLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level2PHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level2B")==0)
		//here goes what happens when user changes the B
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level2B")
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level2BLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level2BHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level2ETA")==0)
		//here goes what happens when user changes the ETA
		IR1A_FixLimitsInPanel("Level2ETA")
		IR1A_CorrectLimitsAndValues()
		IR1A_AutoUpdateIfSelected()
		IR1A_UpdatePorodSfcandInvariant()
	endif
	if (cmpstr(ctrlName,"Level2ETALowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level2ETAHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level2PACK")==0)
		//here goes what happens when user changes the Pack
		IR1A_FixLimitsInPanel("Level2PACK")
		IR1A_CorrectLimitsAndValues()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level2PACKLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level2PACKHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level2RGCO")==0)
		//here goes what happens when user changes the RgCO
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level2RGCOLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level2RGCOHighLimit")==0)

	endif
//
//	if (cmpstr(ctrlName,"Level2RgStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level2RgStep=root:Packages:Irena_UnifFit:Level2RgStep
//		Level2RGStep=VarNum
//		SetVariable Level2RgStep,limits={0,inf,(0.1*Level2RgStep)}
//		SetVariable Level2RG,limits={0,inf,Level2RgStep}
//	endif
//	if (cmpstr(ctrlName,"Level2GStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level2GStep=root:Packages:Irena_UnifFit:Level2GStep
//		Level2GStep=VarNum
//		SetVariable Level2GStep,limits={0,inf,(0.1*Level2GStep)}
//		SetVariable Level2G,limits={0,inf,Level2GStep}
//	endif
//	if (cmpstr(ctrlName,"Level2PStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level2PStep=root:Packages:Irena_UnifFit:Level2PStep
//		Level2PStep=VarNum
//		SetVariable Level2PStep,limits={0,inf,(0.1*Level2PStep)}
//		SetVariable Level2P,limits={0,inf,Level2PStep}
//	endif
//	if (cmpstr(ctrlName,"Level2BStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level2BStep=root:Packages:Irena_UnifFit:Level2BStep
//		Level2BStep=VarNum
//		SetVariable Level2BStep,limits={0,inf,(0.1*Level2BStep)}
//		SetVariable Level2B,limits={0,inf,Level2BStep}
//	endif
//	if (cmpstr(ctrlName,"Level2EtaStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level2EtaStep=root:Packages:Irena_UnifFit:Level2EtaStep
//		Level2EtaStep=VarNum
//		SetVariable Level2EtaStep,limits={0,inf,(0.1*Level2EtaStep)}
//		SetVariable Level2Eta,limits={0,inf,Level2EtaStep}
//	endif
//	if (cmpstr(ctrlName,"Level2PackStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level2PackStep=root:Packages:Irena_UnifFit:Level2PackStep
//		Level2PackStep=VarNum
//		SetVariable Level2PackStep,limits={0,inf,(0.1*Level2PackStep)}
//		SetVariable Level2Pack,limits={0,inf,Level2PackStep}
//	endif
//
//Level3

	if (cmpstr(ctrlName,"Level3Rg")==0)
		//here goes what happens when user changes the Rg
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level3Rg")
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level3RgLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level3RgHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level3G")==0)
		//here goes what happens when user changes the G
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level3G")
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level3GLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level3GHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level3P")==0)
		//here goes what happens when user changes the P
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level3P")
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level3PLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level3PHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level3B")==0)
		//here goes what happens when user changes the B
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level3B")
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level3BLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level3BHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level3ETA")==0)
		//here goes what happens when user changes the ETA
		IR1A_FixLimitsInPanel("Level3ETA")
		IR1A_CorrectLimitsAndValues()
		IR1A_AutoUpdateIfSelected()
		IR1A_UpdatePorodSfcandInvariant()
	endif
	if (cmpstr(ctrlName,"Level3ETALowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level3ETAHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level3PACK")==0)
		//here goes what happens when user changes the Pack
		IR1A_FixLimitsInPanel("Level3PACK")
		IR1A_CorrectLimitsAndValues()
		IR1A_AutoUpdateIfSelected()
		IR1A_UpdatePorodSfcandInvariant()
	endif
	if (cmpstr(ctrlName,"Level3PACKLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level3PACKHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level3RGCO")==0)
		//here goes what happens when user changes the RgCO
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level3RGCOLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level3RGCOHighLimit")==0)

	endif

//	if (cmpstr(ctrlName,"Level3RgStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level3RgStep=root:Packages:Irena_UnifFit:Level3RgStep
//		Level3RGStep=VarNum
//		SetVariable Level3RgStep,limits={0,inf,(0.1*Level3RgStep)}
//		SetVariable Level3RG,limits={0,inf,Level3RgStep}
//	endif
//	if (cmpstr(ctrlName,"Level3GStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level3GStep=root:Packages:Irena_UnifFit:Level3GStep
//		Level3GStep=VarNum
//		SetVariable Level3GStep,limits={0,inf,(0.1*Level3GStep)}
//		SetVariable Level3G,limits={0,inf,Level3GStep}
//	endif
//	if (cmpstr(ctrlName,"Level3PStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level3PStep=root:Packages:Irena_UnifFit:Level3PStep
//		Level3PStep=VarNum
//		SetVariable Level3PStep,limits={0,inf,(0.1*Level3PStep)}
//		SetVariable Level3P,limits={0,inf,Level3PStep}
//	endif
//	if (cmpstr(ctrlName,"Level3BStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level3BStep=root:Packages:Irena_UnifFit:Level3BStep
//		Level3BStep=VarNum
//		SetVariable Level3BStep,limits={0,inf,(0.1*Level3BStep)}
//		SetVariable Level3B,limits={0,inf,Level3BStep}
//	endif
//	if (cmpstr(ctrlName,"Level3EtaStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level3EtaStep=root:Packages:Irena_UnifFit:Level3EtaStep
//		Level3EtaStep=VarNum
//		SetVariable Level3EtaStep,limits={0,inf,(0.1*Level3EtaStep)}
//		SetVariable Level3Eta,limits={0,inf,Level3EtaStep}
//	endif
//	if (cmpstr(ctrlName,"Level3PackStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level3PackStep=root:Packages:Irena_UnifFit:Level3PackStep
//		Level3PackStep=VarNum
//		SetVariable Level3PackStep,limits={0,inf,(0.1*Level3PackStep)}
//		SetVariable Level3Pack,limits={0,inf,Level3PackStep}
//	endif


//Level4

	if (cmpstr(ctrlName,"Level4Rg")==0)
		//here goes what happens when user changes the Rg
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level4Rg")
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level4RgLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level4RgHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level4G")==0)
		//here goes what happens when user changes the G
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level4G")
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level4GLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level4GHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level4P")==0)
		//here goes what happens when user changes the P
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level4P")
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level4PLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level4PHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level4B")==0)
		//here goes what happens when user changes the B
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level4B")
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level4BLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level4BHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level4ETA")==0)
		//here goes what happens when user changes the ETA
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level4ETA")
		IR1A_AutoUpdateIfSelected()
		IR1A_UpdatePorodSfcandInvariant()
	endif
	if (cmpstr(ctrlName,"Level4ETALowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level4ETAHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level4PACK")==0)
		//here goes what happens when user changes the Pack
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level4PACK")
		IR1A_AutoUpdateIfSelected()
		IR1A_UpdatePorodSfcandInvariant()
	endif
	if (cmpstr(ctrlName,"Level4PACKLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level4PACKHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level4RGCO")==0)
		//here goes what happens when user changes the RgCO
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level4RGCOLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level4RGCOHighLimit")==0)

	endif

//	if (cmpstr(ctrlName,"Level4RgStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level4RgStep=root:Packages:Irena_UnifFit:Level4RgStep
//		Level4RGStep=VarNum
//		SetVariable Level4RgStep,limits={0,inf,(0.1*Level4RgStep)}
//		SetVariable Level4RG,limits={0,inf,Level4RgStep}
//	endif
//	if (cmpstr(ctrlName,"Level4GStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level4GStep=root:Packages:Irena_UnifFit:Level4GStep
//		Level4GStep=VarNum
//		SetVariable Level4GStep,limits={0,inf,(0.1*Level4GStep)}
//		SetVariable Level4G,limits={0,inf,Level4GStep}
//	endif
//	if (cmpstr(ctrlName,"Level4PStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level4PStep=root:Packages:Irena_UnifFit:Level4PStep
//		Level4PStep=VarNum
//		SetVariable Level4PStep,limits={0,inf,(0.1*Level4PStep)}
//		SetVariable Level4P,limits={0,inf,Level4PStep}
//	endif
//	if (cmpstr(ctrlName,"Level4BStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level4BStep=root:Packages:Irena_UnifFit:Level4BStep
//		Level4BStep=VarNum
//		SetVariable Level4BStep,limits={0,inf,(0.1*Level4BStep)}
//		SetVariable Level4B,limits={0,inf,Level4BStep}
//	endif
//	if (cmpstr(ctrlName,"Level4EtaStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level4EtaStep=root:Packages:Irena_UnifFit:Level4EtaStep
//		Level4EtaStep=VarNum
//		SetVariable Level4EtaStep,limits={0,inf,(0.1*Level4EtaStep)}
//		SetVariable Level4Eta,limits={0,inf,Level4EtaStep}
//	endif
//	if (cmpstr(ctrlName,"Level4PackStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level4PackStep=root:Packages:Irena_UnifFit:Level4PackStep
//		Level4PackStep=VarNum
//		SetVariable Level4PackStep,limits={0,inf,(0.1*Level4PackStep)}
//		SetVariable Level4Pack,limits={0,inf,Level4PackStep}
//	endif
//

//Level5

	if (cmpstr(ctrlName,"Level5Rg")==0)
		//here goes what happens when user changes the Rg
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level5Rg")
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level5RgLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level5RgHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level5G")==0)
		//here goes what happens when user changes the G
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level5G")
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level5GLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level5GHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level5P")==0)
		//here goes what happens when user changes the P
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level5P")
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level5PLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level5PHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level5B")==0)
		//here goes what happens when user changes the B
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level5B")
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level5BLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level5BHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level5ETA")==0)
		//here goes what happens when user changes the ETA
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level5ETA")
		IR1A_AutoUpdateIfSelected()
		IR1A_UpdatePorodSfcandInvariant()
	endif
	if (cmpstr(ctrlName,"Level5ETALowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level5ETAHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level5PACK")==0)
		//here goes what happens when user changes the Pack
		IR1A_CorrectLimitsAndValues()
		IR1A_FixLimitsInPanel("Level5PACK")
		IR1A_AutoUpdateIfSelected()
		IR1A_UpdatePorodSfcandInvariant()
	endif
	if (cmpstr(ctrlName,"Level5PACKLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level5PACKHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level5RGCO")==0)
		//here goes what happens when user changes the RgCO
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level5RGCOLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level5RGCOHighLimit")==0)

	endif

//	if (cmpstr(ctrlName,"Level5RgStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level5RgStep=root:Packages:Irena_UnifFit:Level5RgStep
//		Level5RGStep=VarNum
//		SetVariable Level5RgStep,limits={0,inf,(0.1*Level5RgStep)}
//		SetVariable Level5RG,limits={0,inf,Level5RgStep}
//	endif
//	if (cmpstr(ctrlName,"Level5GStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level5GStep=root:Packages:Irena_UnifFit:Level5GStep
//		Level5GStep=VarNum
//		SetVariable Level5GStep,limits={0,inf,(0.1*Level5GStep)}
//		SetVariable Level5G,limits={0,inf,Level5GStep}
//	endif
//	if (cmpstr(ctrlName,"Level5PStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level5PStep=root:Packages:Irena_UnifFit:Level5PStep
//		Level5PStep=VarNum
//		SetVariable Level5PStep,limits={0,inf,(0.1*Level5PStep)}
//		SetVariable Level5P,limits={0,inf,Level5PStep}
//	endif
//	if (cmpstr(ctrlName,"Level5BStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level5BStep=root:Packages:Irena_UnifFit:Level5BStep
//		Level5BStep=VarNum
//		SetVariable Level5BStep,limits={0,inf,(0.1*Level5BStep)}
//		SetVariable Level5B,limits={0,inf,Level5BStep}
//	endif
//	if (cmpstr(ctrlName,"Level5EtaStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level5EtaStep=root:Packages:Irena_UnifFit:Level5EtaStep
//		Level5EtaStep=VarNum
//		SetVariable Level5EtaStep,limits={0,inf,(0.1*Level5EtaStep)}
//		SetVariable Level5Eta,limits={0,inf,Level5EtaStep}
//	endif
//	if (cmpstr(ctrlName,"Level5PackStep")==0)
//		//here goes what happens when user changes the step for shape
//		NVAR Level5PackStep=root:Packages:Irena_UnifFit:Level5PackStep
//		Level5PackStep=VarNum
//		SetVariable Level5PackStep,limits={0,inf,(0.1*Level5PackStep)}
//		SetVariable Level5Pack,limits={0,inf,Level5PackStep}
//	endif

	DoWIndow/F IR1A_ControlPanel

end
//************************************************************************************************************
//************************************************************************************************************

Function IR1A_FixLimits()
	NVAR nmbLevls=root:Packages:Irena_UnifFit:NumberOfLevels
	variable i, j
	string ListOfVars="Rg;G;P;B;ETA;Pack;"
	String TempName
	For(j=0;j<ItemsInList(ListOfVars);j+=1)
		TempName=stringFromList(j,ListOfVars)
		For(i=1;i<=nmbLevls;i+=1)
			IR1A_FixLimitsInPanel("Level"+num2str(i)+TempName)		
		endfor
	endfor
end
//************************************************************************************************************
//************************************************************************************************************
Function IR1A_FixLimitsInPanel(VarName)
	string VarName
	
	NVAR testVariable=$("root:Packages:Irena_UnifFit:"+VarName)
	NVAR testVariableLL=$("root:Packages:Irena_UnifFit:"+VarName+"LowLimit")
	NVAR testVariableHL=$("root:Packages:Irena_UnifFit:"+VarName+"HighLimit")
	if(stringmatch(VarName,"*P"))
		if(abs(testVariable - 4)<0.1)
			testVariable = 4
		endif
		testVariableLL = 0.7 * testVariable
		if(testVariableLL<1)
			testVariableLL = 1
		endif
		testVariableHL = 1.4 * testVariable
		if(testVariableHL>5)
			testVariableHL = 5	
		endif
		Execute("SetVariable "+VarName+",win=IR1A_ControlPanel,limits={0,5,"+num2str(0.05*testVariable)+"}")		
	elseif(stringmatch(VarName,"*Pack"))
		testVariableLL = 0.4*testVariable
		testVariableHL = 2*testVariable
		if(testVariableHL>10)
			testVariableHL =10
		endif
		Execute("SetVariable "+VarName+",win=IR1A_ControlPanel,limits={0,"+num2str(testVariableHL)+","+num2str(0.05*testVariable)+"}")		
	elseif(stringmatch(VarName,"*Rg"))
		testVariableLL = 0.4*testVariable
		testVariableHL = testVariable/0.4
		if(testVariableLL<2)
			testVariableLL=2
		endif
		Execute("SetVariable "+VarName+",win=IR1A_ControlPanel,limits={0,inf,"+num2str(0.05*testVariable)+"}")		
	elseif(stringmatch(VarName,"*G"))
		testVariableLL = 0.1*testVariable
		testVariableHL = testVariable/0.1
		Execute("SetVariable "+VarName+",win=IR1A_ControlPanel,limits={0,inf,"+num2str(0.05*testVariable)+"}")	
	elseif(stringmatch(VarName,"*ETA"))//**DWS
		testVariableLL = 0.5*testVariable
		testVariableHL = 2*testVariable	
		Execute("SetVariable "+VarName+",win=IR1A_ControlPanel,limits={0,inf,"+num2str(0.01*testVariable)+"}")	
	else	
		Execute("SetVariable "+VarName+",win=IR1A_ControlPanel,limits={0,inf,"+num2str(0.05*testVariable)+"}")
		testVariableLL = 0.2*testVariable
		testVariableHL = 5*testVariable	
	endif
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1A_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
	if (cmpstr(ctrlName,"UseSMRData")==0)
		//here we control the data structure checkbox
		NVAR UseIndra2Data=root:Packages:Irena_UnifFit:UseIndra2Data
		NVAR UseQRSData=root:Packages:Irena_UnifFit:UseQRSData
		NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
		SetVariable SlitLength,win=IR1A_ControlPanel, disable=!UseSMRData
		Checkbox UseIndra2Data,win=IR1A_ControlPanel, value=UseIndra2Data
		Checkbox UseQRSData,win=IR1A_ControlPanel, value=UseQRSData
		SVAR Dtf=root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntDf=root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QDf=root:Packages:Irena_UnifFit:QWaveName
		SVAR EDf=root:Packages:Irena_UnifFit:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder,win=IR1A_ControlPanel, mode=1
			PopupMenu IntensityDataName,  mode=1,win=IR1A_ControlPanel, value="---"
			PopupMenu QvecDataName, mode=1,win=IR1A_ControlPanel, value="---"
			PopupMenu ErrorDataName, mode=1,win=IR1A_ControlPanel, value="---"
		//here we control the data structure checkbox
			PopupMenu SelectDataFolder,win=IR1A_ControlPanel, value= #"\"---;\"+IR1_GenStringOfFolders(root:Packages:Irena_UnifFit:UseIndra2Data, root:Packages:Irena_UnifFit:UseQRSData,root:Packages:Irena_UnifFit:UseSMRData,0)"
	endif

	if (cmpstr(ctrlName,"UseIndra2Data")==0)
		//here we control the data structure checkbox
		NVAR UseIndra2Data=root:Packages:Irena_UnifFit:UseIndra2Data
		NVAR UseQRSData=root:Packages:Irena_UnifFit:UseQRSData
		UseIndra2Data=checked
		if (checked)
			UseQRSData=0
		endif
		Checkbox UseIndra2Data,win=IR1A_ControlPanel, value=UseIndra2Data
		Checkbox UseQRSData,win=IR1A_ControlPanel, value=UseQRSData
		SVAR Dtf=root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntDf=root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QDf=root:Packages:Irena_UnifFit:QWaveName
		SVAR EDf=root:Packages:Irena_UnifFit:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder ,win=IR1A_ControlPanel, mode=1
			PopupMenu IntensityDataName  mode=1,win=IR1A_ControlPanel, value="---"
			PopupMenu QvecDataName    mode=1,win=IR1A_ControlPanel, value="---"
			PopupMenu ErrorDataName    mode=1,win=IR1A_ControlPanel, value="---"
	endif
	if (cmpstr(ctrlName,"UseQRSData")==0)
		//here we control the data structure checkbox
		NVAR UseQRSData=root:Packages:Irena_UnifFit:UseQRSData
		NVAR UseIndra2Data=root:Packages:Irena_UnifFit:UseIndra2Data
		UseQRSData=checked
		if (checked)
			UseIndra2Data=0
		endif
		Checkbox UseIndra2Data,win=IR1A_ControlPanel, value=UseIndra2Data
		Checkbox UseQRSData,win=IR1A_ControlPanel, value=UseQRSData
		SVAR Dtf=root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntDf=root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QDf=root:Packages:Irena_UnifFit:QWaveName
		SVAR EDf=root:Packages:Irena_UnifFit:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder,win=IR1A_ControlPanel, mode=1
			PopupMenu IntensityDataName   mode=1,win=IR1A_ControlPanel, value="---"
			PopupMenu QvecDataName    mode=1,win=IR1A_ControlPanel, value="---"
			PopupMenu ErrorDataName    mode=1,win=IR1A_ControlPanel, value="---"
	endif
	if (cmpstr(ctrlName,"FitBackground")==0)
		//here we control the data structure checkbox
	endif
	if (cmpstr(ctrlName,"DisplayLocalFits")==0)
		NVAR ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
		IR1A_DisplayLocalFits(ActiveTab,0)
	endif
	if (cmpstr(ctrlName,"UpdateAutomatically")==0)
		IR1A_AutoUpdateIfSelected()
	endif
	
//Level 1 controls


	if (cmpstr(ctrlName,"UseNoLimits")==0)
		//here we control the data structure checkbox
		IR1A_TabPanelControl("Checkbox",0)
	elseif(cmpstr(ctrlName,"Level1MassFractal")==0)
		//here we control the data structure checkbox
		NVAR Level1MassFractal=root:Packages:Irena_UnifFit:Level1MassFractal
		NVAR Level1LinkB=root:Packages:Irena_UnifFit:Level1LinkB
		NVAR Level1FitB=root:Packages:Irena_UnifFit:Level1FitB
		NVAR Level1PHighLimit=root:Packages:Irena_UnifFit:Level1PHighLimit
		NVAR Level1PLowLimit=root:Packages:Irena_UnifFit:Level1PLowLimit
		NVAR Level1P=root:Packages:Irena_UnifFit:Level1P
		NVAR Level1K=root:Packages:Irena_UnifFit:Level1K
		if (checked==1)
			Level1PHighLimit=3
			Level1PLowLimit=1
			Level1P=2
			Level1K=1.06
			PopupMenu Level1KFactor, mode=2
			Level1LinkB = 0
		else
			Level1PHighLimit=4
			Level1PLowLimit=1
			Level1K=1
			PopupMenu Level1KFactor, mode=1
		endif
		Level1MassFractal=checked
		Level1FitB=0
		Checkbox Level1MassFractal, value=Level1MassFractal
		Checkbox Level1FitB, value=Level1FitB
		Checkbox Level1LinkB, value=Level1LinkB
		IR1A_TabPanelControl("Checkbox",0)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()	
	elseif (cmpstr(ctrlName,"Level1LinkB")==0)
		NVAR Level1LinkB=root:Packages:Irena_UnifFit:Level1LinkB
		NVAR Level1MassFractal=root:Packages:Irena_UnifFit:Level1MassFractal
		NVAR Level1FitB=root:Packages:Irena_UnifFit:Level1FitB
		NVAR Level1PHighLimit=root:Packages:Irena_UnifFit:Level1PHighLimit
		NVAR Level1PLowLimit=root:Packages:Irena_UnifFit:Level1PLowLimit
		NVAR Level1P=root:Packages:Irena_UnifFit:Level1P
		NVAR Level1K=root:Packages:Irena_UnifFit:Level1K
		if (checked==1)
			Level1MassFractal = 0
			Level1FitB = 0
		else
		endif
		Checkbox Level1MassFractal, value=Level1MassFractal
		Checkbox Level1FitB, value=Level1FitB
		Checkbox Level1LinkB, value=Level1LinkB
		IR1A_TabPanelControl("Checkbox",0)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()			
	elseif (cmpstr(ctrlName,"Level1Corelations")==0)
		IR1A_TabPanelControl("Checkbox",0)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_AutoUpdateIfSelected()
	elseif (cmpstr(ctrlName,"Level1FitRg")==0)
		//here we control the data structure checkbox
		IR1A_TabPanelControl("Checkbox",0)
	elseif (cmpstr(ctrlName,"Level1FitG")==0)
		//here we control the data structure checkbox
		IR1A_TabPanelControl("Checkbox",0)
	elseif (cmpstr(ctrlName,"Level1FitP")==0)
		//here we control the data structure checkbox
		IR1A_TabPanelControl("Checkbox",0)
	elseif (cmpstr(ctrlName,"Level1FitB")==0)
		//here we control the data structure checkbox
		IR1A_TabPanelControl("Checkbox",0)
	elseif (cmpstr(ctrlName,"Level1FitEta")==0)
		//here we control the data structure checkbox
		IR1A_TabPanelControl("Checkbox",0)
	elseif (cmpstr(ctrlName,"Level1FitPack")==0)
		//here we control the data structure checkbox
		IR1A_TabPanelControl("Checkbox",0)
	elseif (cmpstr(ctrlName,"Level1FitRGCO")==0)
		//here we control the data structure checkbox
		IR1A_TabPanelControl("Checkbox",0)
	elseif (cmpstr(ctrlName,"Level1LinkRGCO")==0)
		//here we control the data structure checkbox
		NVAR Level1FitRGCO=root:Packages:Irena_UnifFit:Level1FitRGCO
		Level1FitRGCO=0
		IR1A_TabPanelControl("Checkbox",0)
		IR1A_AutoUpdateIfSelected()
//Level2 controls
	elseif (cmpstr(ctrlName,"Level2MassFractal")==0)
		//here we control the data structure checkbox
		NVAR Level2MassFractal=root:Packages:Irena_UnifFit:Level2MassFractal
		NVAR Level2LinkB=root:Packages:Irena_UnifFit:Level2LinkB
		NVAR Level2FitB=root:Packages:Irena_UnifFit:Level2FitB
		NVAR Level2PHighLimit=root:Packages:Irena_UnifFit:Level2PHighLimit
		NVAR Level2PLowLimit=root:Packages:Irena_UnifFit:Level2PLowLimit
		NVAR Level2P=root:Packages:Irena_UnifFit:Level2P
		NVAR Level2K=root:Packages:Irena_UnifFit:Level2K
		if (checked==1)
			Level2PHighLimit=3
			Level2PLowLimit=1
			Level2P=2
			Level2K=1.06
			PopupMenu Level2KFactor, mode=2
			Level2LinkB = 0
		else
			Level2PHighLimit=4
			Level2PLowLimit=1
			Level2K=1
			PopupMenu Level2KFactor, mode=1
		endif
		Level2MassFractal=checked
		Level2FitB=0
		Checkbox Level2FitB, value=0
		Checkbox Level2MassFractal, value=Level2MassFractal
		Checkbox Level2LinkB, value=Level2LinkB
		IR1A_TabPanelControl("Checkbox",1)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	elseif (cmpstr(ctrlName,"Level2LinkB")==0)
		NVAR Level2LinkB=root:Packages:Irena_UnifFit:Level2LinkB
		NVAR Level2MassFractal=root:Packages:Irena_UnifFit:Level2MassFractal
		NVAR Level2FitB=root:Packages:Irena_UnifFit:Level2FitB
		NVAR Level2PHighLimit=root:Packages:Irena_UnifFit:Level2PHighLimit
		NVAR Level2PLowLimit=root:Packages:Irena_UnifFit:Level2PLowLimit
		NVAR Level2P=root:Packages:Irena_UnifFit:Level2P
		NVAR Level2K=root:Packages:Irena_UnifFit:Level2K
		if (checked==1)
			Level2MassFractal = 0
			Level2FitB = 0
		else
		endif
		Checkbox Level2MassFractal, value=Level2MassFractal
		Checkbox Level2FitB, value=Level2FitB
		Checkbox Level2LinkB, value=Level2LinkB
		IR1A_TabPanelControl("Checkbox",1)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()			
	elseif (cmpstr(ctrlName,"Level2Corelations")==0)
		IR1A_TabPanelControl("Checkbox",1)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_AutoUpdateIfSelected()
	elseif (cmpstr(ctrlName,"Level2FitRg")==0)
		IR1A_TabPanelControl("Checkbox",1)
	elseif (cmpstr(ctrlName,"Level2FitG")==0)
		IR1A_TabPanelControl("Checkbox",1)
	elseif (cmpstr(ctrlName,"Level2FitP")==0)
		IR1A_TabPanelControl("Checkbox",1)
	elseif (cmpstr(ctrlName,"Level2FitB")==0)
		IR1A_TabPanelControl("Checkbox",1)
	elseif (cmpstr(ctrlName,"Level2FitEta")==0)
		IR1A_TabPanelControl("Checkbox",1)
	elseif (cmpstr(ctrlName,"Level2FitPack")==0)
		IR1A_TabPanelControl("Checkbox",1)
	elseif (cmpstr(ctrlName,"Level2FitRGCO")==0)
		IR1A_TabPanelControl("Checkbox",1)
	elseif (cmpstr(ctrlName,"Level2LinkRGCO")==0)
		//here we control the data structure checkbox
		NVAR Level2LinkRGCO=root:Packages:Irena_UnifFit:Level2LinkRGCO
		NVAR Level2FitRGCO=root:Packages:Irena_UnifFit:Level2FitRGCO
		NVAR Level1Rg=root:Packages:Irena_UnifFit:Level1Rg
		NVAR Level2RGCO=root:Packages:Irena_UnifFit:Level2RGCO
		Level2RGCO=Level1Rg	
		Level2LinkRGCO=checked
		Level2FitRGCO=0
		//Checkbox Level2FitRGCO, value=Level2FitRGCO
		Checkbox Level2LinkRGCO, value=Level2LinkRGCO
		IR1A_TabPanelControl("Checkbox",1)
		IR1A_AutoUpdateIfSelected()
//Level3 controls
	elseif (cmpstr(ctrlName,"Level3MassFractal")==0)
		//here we control the data structure checkbox
		NVAR Level3MassFractal=root:Packages:Irena_UnifFit:Level3MassFractal
		NVAR Level3LinkB=root:Packages:Irena_UnifFit:Level3LinkB
		NVAR Level3FitB=root:Packages:Irena_UnifFit:Level3FitB
		NVAR Level3PHighLimit=root:Packages:Irena_UnifFit:Level3PHighLimit
		NVAR Level3PLowLimit=root:Packages:Irena_UnifFit:Level3PLowLimit
		NVAR Level3P=root:Packages:Irena_UnifFit:Level3P
		NVAR Level3K=root:Packages:Irena_UnifFit:Level3K
		if (checked==1)
			Level3PHighLimit=3
			Level3PLowLimit=1
			Level3P=2
			Level3K=1.06
			PopupMenu Level3KFactor, mode=2
			Level3LinkB = 0
		else
			Level3PHighLimit=4
			Level3PLowLimit=1
			Level3K=1
			PopupMenu Level3KFactor, mode=1
		endif
		Level3FitB=0
		Level3MassFractal=checked
		Checkbox Level3MassFractal, value=Level3MassFractal
		Checkbox Level3FitB, value=0
		Checkbox Level3LinkB, value=Level3LinkB
		IR1A_TabPanelControl("Checkbox",2)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	elseif (cmpstr(ctrlName,"Level3LinkB")==0)
		NVAR Level3LinkB=root:Packages:Irena_UnifFit:Level3LinkB
		NVAR Level3MassFractal=root:Packages:Irena_UnifFit:Level3MassFractal
		NVAR Level3FitB=root:Packages:Irena_UnifFit:Level3FitB
		NVAR Level3PHighLimit=root:Packages:Irena_UnifFit:Level3PHighLimit
		NVAR Level3PLowLimit=root:Packages:Irena_UnifFit:Level3PLowLimit
		NVAR Level3P=root:Packages:Irena_UnifFit:Level3P
		NVAR Level3K=root:Packages:Irena_UnifFit:Level3K
		if (checked==1)
			Level3MassFractal = 0
			Level3FitB = 0
		else
		endif
		Checkbox Level3MassFractal, value=Level3MassFractal
		Checkbox Level3FitB, value=Level3FitB
		Checkbox Level3LinkB, value=Level3LinkB
		IR1A_TabPanelControl("Checkbox",2)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()			
	elseif (cmpstr(ctrlName,"Level3Corelations")==0)
		IR1A_TabPanelControl("Checkbox",2)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_AutoUpdateIfSelected()
	elseif (cmpstr(ctrlName,"Level3FitRg")==0)
		IR1A_TabPanelControl("Checkbox",2)
	elseif (cmpstr(ctrlName,"Level3FitG")==0)
		IR1A_TabPanelControl("Checkbox",2)
	elseif (cmpstr(ctrlName,"Level3FitP")==0)
		IR1A_TabPanelControl("Checkbox",2)
	elseif (cmpstr(ctrlName,"Level3FitB")==0)
		IR1A_TabPanelControl("Checkbox",2)
	elseif (cmpstr(ctrlName,"Level3FitEta")==0)
		IR1A_TabPanelControl("Checkbox",2)
	elseif (cmpstr(ctrlName,"Level3FitPack")==0)
		IR1A_TabPanelControl("Checkbox",2)
	elseif (cmpstr(ctrlName,"Level3FitRGCO")==0)
		IR1A_TabPanelControl("Checkbox",2)
	elseif (cmpstr(ctrlName,"Level3LinkRGCO")==0)
		//here we control the data structure checkbox
		NVAR Level3LinkRGCO=root:Packages:Irena_UnifFit:Level3LinkRGCO
		NVAR Level3FitRGCO=root:Packages:Irena_UnifFit:Level3FitRGCO
		NVAR Level2Rg=root:Packages:Irena_UnifFit:Level2Rg
		NVAR Level3RGCO=root:Packages:Irena_UnifFit:Level3RGCO
		Level3RGCO=Level2Rg	
		Level3LinkRGCO=checked
		Level3FitRGCO=0
		Checkbox Level3LinkRGCO, value=Level3LinkRGCO
		//Checkbox Level3FitRGCO, value=Level3FitRGCO
		IR1A_TabPanelControl("Checkbox",2)
		IR1A_AutoUpdateIfSelected()
//Level4 controls
	elseif (cmpstr(ctrlName,"Level4MassFractal")==0)
		//here we control the data structure checkbox
		NVAR Level4MassFractal=root:Packages:Irena_UnifFit:Level4MassFractal
		NVAR Level4LinkB=root:Packages:Irena_UnifFit:Level4LinkB
		NVAR Level4FitB=root:Packages:Irena_UnifFit:Level4FitB
		NVAR Level4PHighLimit=root:Packages:Irena_UnifFit:Level4PHighLimit
		NVAR Level4PLowLimit=root:Packages:Irena_UnifFit:Level4PLowLimit
		NVAR Level4P=root:Packages:Irena_UnifFit:Level4P
		NVAR Level4K=root:Packages:Irena_UnifFit:Level4K
		if (checked==1)
			Level4PHighLimit=3
			Level4PLowLimit=1
			Level4P=2
			Level4K=1.06
			PopupMenu Level4KFactor, mode=2
			Level4LinkB = 0
		else
			Level4PHighLimit=4
			Level4PLowLimit=1
			Level4K=1
			PopupMenu Level4KFactor, mode=1
		endif
		Level4MassFractal=checked
		Level4FitB=0
		Checkbox Level4FitB, value=0
		Checkbox Level4MassFractal, value=Level4MassFractal
		Checkbox Level4LinkB, value=Level4LinkB
		IR1A_TabPanelControl("Checkbox",3)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	elseif (cmpstr(ctrlName,"Level4LinkB")==0)
		NVAR Level4LinkB=root:Packages:Irena_UnifFit:Level4LinkB
		NVAR Level4MassFractal=root:Packages:Irena_UnifFit:Level4MassFractal
		NVAR Level4FitB=root:Packages:Irena_UnifFit:Level4FitB
		NVAR Level4PHighLimit=root:Packages:Irena_UnifFit:Level4PHighLimit
		NVAR Level4PLowLimit=root:Packages:Irena_UnifFit:Level4PLowLimit
		NVAR Level4P=root:Packages:Irena_UnifFit:Level4P
		NVAR Level4K=root:Packages:Irena_UnifFit:Level4K
		if (checked==1)
			Level4MassFractal = 0
			Level4FitB = 0
		else
		endif
		Checkbox Level4MassFractal, value=Level4MassFractal
		Checkbox Level4FitB, value=Level4FitB
		Checkbox Level4LinkB, value=Level4LinkB
		IR1A_TabPanelControl("Checkbox",3)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()			
	elseif (cmpstr(ctrlName,"Level4Corelations")==0)
		IR1A_TabPanelControl("Checkbox",3)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_AutoUpdateIfSelected()
	elseif (cmpstr(ctrlName,"Level4FitRg")==0)
		IR1A_TabPanelControl("Checkbox",3)
	elseif (cmpstr(ctrlName,"Level4FitG")==0)
		IR1A_TabPanelControl("Checkbox",3)
	elseif (cmpstr(ctrlName,"Level4FitP")==0)
		IR1A_TabPanelControl("Checkbox",3)
	elseif (cmpstr(ctrlName,"Level4FitB")==0)
		IR1A_TabPanelControl("Checkbox",3)
	elseif (cmpstr(ctrlName,"Level4FitEta")==0)
		IR1A_TabPanelControl("Checkbox",3)
	elseif (cmpstr(ctrlName,"Level4FitPack")==0)
		IR1A_TabPanelControl("Checkbox",3)
	elseif (cmpstr(ctrlName,"Level4FitRGCO")==0)
		IR1A_TabPanelControl("Checkbox",3)
	elseif (cmpstr(ctrlName,"Level4LinkRGCO")==0)
		//here we control the data structure checkbox
		NVAR Level4LinkRGCO=root:Packages:Irena_UnifFit:Level4LinkRGCO
		NVAR Level4FitRGCO=root:Packages:Irena_UnifFit:Level4FitRGCO
		NVAR Level3Rg=root:Packages:Irena_UnifFit:Level3Rg
		NVAR Level4RGCO=root:Packages:Irena_UnifFit:Level4RGCO
		Level4RGCO=Level3Rg	
		Level4LinkRGCO=checked
		Level4FitRGCO=0
		Checkbox Level4LinkRGCO, value=Level4LinkRGCO
		//Checkbox Level4FitRGCO, value=Level4FitRGCO
		IR1A_TabPanelControl("Checkbox",3)
		IR1A_AutoUpdateIfSelected()
//Level5 controls
	elseif (cmpstr(ctrlName,"Level5MassFractal")==0)
		//here we control the data structure checkbox
		NVAR Level5MassFractal=root:Packages:Irena_UnifFit:Level5MassFractal
		NVAR Level5LinkB=root:Packages:Irena_UnifFit:Level5LinkB
		NVAR Level5FitB=root:Packages:Irena_UnifFit:Level5FitB
		NVAR Level5PHighLimit=root:Packages:Irena_UnifFit:Level5PHighLimit
		NVAR Level5PLowLimit=root:Packages:Irena_UnifFit:Level5PLowLimit
		NVAR Level5P=root:Packages:Irena_UnifFit:Level5P
		NVAR Level5K=root:Packages:Irena_UnifFit:Level5K
		if (checked==1)
			Level5PHighLimit=3
			Level5PLowLimit=1
			Level5P=2
			Level5K=1.06
			PopupMenu Level5KFactor, mode=2
			Level5LinkB = 0
		else
			Level5PHighLimit=4
			Level5PLowLimit=1
			Level5K=1
			PopupMenu Level5KFactor, mode=1
		endif
		Level5FitB=0
		Level5MassFractal=checked
		Checkbox Level5MassFractal, value=Level5MassFractal
		Checkbox Level5FitB, value=0
		Checkbox Level5LinkB, value=Level5LinkB
		IR1A_TabPanelControl("Checkbox",4)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()
	elseif (cmpstr(ctrlName,"Level5LinkB")==0)
		NVAR Level5LinkB=root:Packages:Irena_UnifFit:Level5LinkB
		NVAR Level5MassFractal=root:Packages:Irena_UnifFit:Level5MassFractal
		NVAR Level5FitB=root:Packages:Irena_UnifFit:Level5FitB
		NVAR Level5PHighLimit=root:Packages:Irena_UnifFit:Level5PHighLimit
		NVAR Level5PLowLimit=root:Packages:Irena_UnifFit:Level5PLowLimit
		NVAR Level5P=root:Packages:Irena_UnifFit:Level5P
		NVAR Level5K=root:Packages:Irena_UnifFit:Level5K
		if (checked==1)
			Level5MassFractal = 0
			Level5FitB = 0
		else
		endif
		Checkbox Level5MassFractal, value=Level5MassFractal
		Checkbox Level5FitB, value=Level5FitB
		Checkbox Level5LinkB, value=Level5LinkB
		IR1A_TabPanelControl("Checkbox",4)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_AutoUpdateIfSelected()			
	elseif (cmpstr(ctrlName,"Level5Corelations")==0)
		IR1A_TabPanelControl("Checkbox",4)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_AutoUpdateIfSelected()
	elseif (cmpstr(ctrlName,"Level5FitRg")==0)
		IR1A_TabPanelControl("Checkbox",4)
	elseif (cmpstr(ctrlName,"Level5FitG")==0)
		IR1A_TabPanelControl("Checkbox",4)
	elseif (cmpstr(ctrlName,"Level5FitP")==0)
		IR1A_TabPanelControl("Checkbox",4)
	elseif (cmpstr(ctrlName,"Level5FitB")==0)
		IR1A_TabPanelControl("Checkbox",4)
	elseif (cmpstr(ctrlName,"Level5FitEta")==0)
		IR1A_TabPanelControl("Checkbox",4)
	elseif (cmpstr(ctrlName,"Level5FitPack")==0)
		IR1A_TabPanelControl("Checkbox",4)
	elseif (cmpstr(ctrlName,"Level5FitRGCO")==0)
		IR1A_TabPanelControl("Checkbox",4)
	elseif (cmpstr(ctrlName,"Level5LinkRGCO")==0)
		//here we control the data structure checkbox
		NVAR Level5LinkRGCO=root:Packages:Irena_UnifFit:Level5LinkRGCO
		NVAR Level5FitRGCO=root:Packages:Irena_UnifFit:Level5FitRGCO
		NVAR Level4Rg=root:Packages:Irena_UnifFit:Level4Rg
		NVAR Level5RGCO=root:Packages:Irena_UnifFit:Level5RGCO
		Level5RGCO=Level4Rg	
		Level5LinkRGCO=checked
		Level5FitRGCO=0
		Checkbox Level5LinkRGCO, value=Level5LinkRGCO
		//Checkbox Level5FitRGCO, value=Level5FitRGCO
		IR1A_TabPanelControl("Checkbox",4)
		IR1A_AutoUpdateIfSelected()
	endif
	DoUpdate
end

///********************************************************************************************************
///********************************************************************************************************
///********************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_GraphMeasuredData(Package)
	string Package	//tells me, if this is called from Unified or LSQF
	//this function graphs data into the various graphs as needed
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
	SVAR DataFolderName=root:Packages:Irena_UnifFit:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena_UnifFit:IntensityWaveName
	SVAR QWavename=root:Packages:Irena_UnifFit:QWavename
	SVAR ErrorWaveName=root:Packages:Irena_UnifFit:ErrorWaveName
	NVAR RebinDataTo=root:Packages:Irena_UnifFit:RebinDataTo
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
	if(RebinDataTo>0)
		IN2G_RebinLogData(OriginalQvector,OriginalIntensity,RebinDataTo,0,Wsdev=OriginalError)
		//IR1D_rebinData(OriginalIntensity,OriginalQvector,OriginalError,RebinDataTo, 1)
	endif
	
	NVAR/Z SubtractBackground=root:Packages:Irena_UnifFit:SubtractBackground
	if(NVAR_Exists(SubtractBackground) && (cmpstr(Package,"Unified")==0))
		OriginalIntensity =OriginalIntensity - SubtractBackground
	endif
//	NVAR/Z UseSlitSmearedData=root:Packages:Irena_UnifFit:UseSlitSmearedData
//	if(NVAR_Exists(UseSlitSmearedData) && (cmpstr(Package,"LSQF")==0))
//		if(UseSlitSmearedData)
//			NVAR SlitLength=root:Packages:Irena_UnifFit:SlitLength
//			variable tempSL=NumberByKey("SlitLength", note(OriginalIntensity) , "=" , ";")
//			if(numtype(tempSL)==0)
//				SlitLength=tempSL
//			endif
//		endif
//	endif
//	 change September 2007
//	current universal package which loads data in does nto care about local setting for useSMRData, but we need to set it acording to wave passed...
	NVAR/Z UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	if(stringmatch(IntensityWaveName, "*SMR_Int*" ))		// slit smeared data
		UseSMRData=1
		SetVariable SlitLength,win=IR1A_ControlPanel,disable=!UseSMRData
	elseif(stringmatch(IntensityWaveName, "*DSM_Int*" ))	//Indra 2 desmeared data
		UseSMRData=0
		SetVariable SlitLength,win=IR1A_ControlPanel,disable=!UseSMRData
	else
			//we have no clue what user input, leave it to him to deal with slit smearing
	endif

	if(NVAR_Exists(UseSMRData) && (cmpstr(Package,"Unified")==0))
		if(UseSMRData)
			NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
			variable tempSL1=NumberByKey("SlitLength", note(OriginalIntensity) , "=" , ";")
			if(numtype(tempSL1)==0)
				SlitLengthUnif=tempSL1
			endif
		endif
	endif
	
	
	if (cmpstr(Package,"Unified")==0)		//called from unified
		DoWindow IR1_LogLogPlotU
		if (V_flag)
			Dowindow/K IR1_LogLogPlotU
		endif
		Execute ("IR1_LogLogPlotU()")
//	elseif (cmpstr(Package,"LSQF")==0)
//		DoWindow IR1_LogLogPlotLSQF
//		if (V_flag)
//			cursorAposition=pcsr(A,"IR1_LogLogPlotLSQF")
//			cursorBposition=pcsr(B,"IR1_LogLogPlotLSQF")
//			Dowindow/K IR1_LogLogPlotLSQF
//		endif
//		Execute ("IR1_LogLogPlotLSQF()")
//		cursor/P/W=IR1_LogLogPlotLSQF A, OriginalIntensity,cursorAposition
//		cursor/P/W=IR1_LogLogPlotLSQF B, OriginalIntensity,cursorBposition
	endif
	
	Duplicate/O $(DataFolderName+IntensityWaveName), OriginalIntQ4
	Duplicate/O $(DataFolderName+QWavename), OriginalQ4
	Duplicate/O $(DataFolderName+ErrorWaveName), OriginalErrQ4
	Redimension/D OriginalIntQ4, OriginalQ4, OriginalErrQ4
	wavestats /Q OriginalQ4
	if(V_min<0)
		OriginalQ4 = OriginalQ4[p]<=0 ? NaN : OriginalQ4[p] 
	endif
	IN2G_RemoveNaNsFrom3Waves(OriginalQ4,OriginalIntQ4, OriginalErrQ4)

	if(NVAR_Exists(SubtractBackground) && (cmpstr(Package,"Unified")==0))
		OriginalIntQ4 =OriginalIntQ4 - SubtractBackground
	endif
	
	OriginalQ4=OriginalQ4^4
	OriginalIntQ4=OriginalIntQ4*OriginalQ4
	OriginalErrQ4=OriginalErrQ4*OriginalQ4

	if (cmpstr(Package,"Unified")==0)		//called from unified
		DoWindow IR1_IQ4_Q_PlotU
		if (V_flag)
			Dowindow/K IR1_IQ4_Q_PlotU
		endif
		Execute ("IR1_IQ4_Q_PlotU()")
	elseif (cmpstr(Package,"LSQF")==0)
		DoWindow IR1_IQ4_Q_PlotLSQF
		if (V_flag)
			Dowindow/K IR1_IQ4_Q_PlotLSQF
		endif
		Execute ("IR1_IQ4_Q_PlotLSQF()")
	endif
	setDataFolder oldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************

Proc  IR1_IQ4_Q_PlotU() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:Irena_UnifFit:
	Display /W=(283.5,228.5,761.25,383)/K=1  OriginalIntQ4 vs OriginalQvector as "IQ4_Q_Plot"
	DoWindow/C IR1_IQ4_Q_PlotU
	ModifyGraph mode(OriginalIntQ4)=3
	ModifyGraph msize(OriginalIntQ4)=1
	ModifyGraph log=1
	ModifyGraph mirror=1
	Label left "Intensity * Q^4"
	Label bottom "Q [A\\S-1\\M]"
	ErrorBars/Y=1 OriginalIntQ4 Y,wave=(OriginalErrQ4,OriginalErrQ4)
	TextBox/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	//and now some controls
	SetDataFolder fldrSav
EndMacro
//*****************************************************************************************************************
//*****************************************************************************************************************
Proc  IR1_LogLogPlotU() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:Irena_UnifFit:
	Display /W=(282.75,37.25,759.75,208.25)/K=1  OriginalIntensity vs OriginalQvector as "LogLogPlot"
	DoWindow/C IR1_LogLogPlotU
	ModifyGraph mode(OriginalIntensity)=3
	ModifyGraph msize(OriginalIntensity)=0
	ModifyGraph log=1
	ModifyGraph mirror=1
	ShowInfo
	String LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Intensity [cm\\S-1\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"]"
	Label left LabelStr
	LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"]"
	Label bottom LabelStr
	string LegendStr="\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")+"\\s(OriginalIntensity) Experimental intensity"
	Legend/W=IR1_LogLogPlotU/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 LegendStr
	//
	ErrorBars/Y=1 OriginalIntensity Y,wave=(OriginalError,OriginalError)
	//and now some controls
	TextBox/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	SetDataFolder fldrSav
EndMacro
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
///********************************************************************************************************
///********************************************************************************************************

Function IR1A_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
	

	if (cmpstr(ctrlName,"DrawGraphs")==0 || cmpstr(ctrlName,"DrawGraphsSkipDialogs")==0)
		//here goes what is done, when user pushes Graph button
		SVAR DFloc=root:Packages:Irena_UnifFit:DataFolderName
		SVAR DFInt=root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR DFQ=root:Packages:Irena_UnifFit:QWaveName
		SVAR DFE=root:Packages:Irena_UnifFit:ErrorWaveName
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
				variable recovered = IR1A_RecoverOldParameters()	//recovers old parameters and returns 1 if done so...
			endif
			IR1A_FixTabsInPanel()
			IR1A_GraphMeasuredData("Unified")
			NVAR ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
			IR1A_DisplayLocalFits(ActiveTab,0)
			IR1A_AutoUpdateIfSelected()
			variable ScreenHeight, ScreenWidth
			ScreenHeight = IN2G_ScreenWidthHeight("height")*100	
			ScreenWidth = IN2G_ScreenWidthHeight("width")	*100
			MoveWindow /W=IR1_LogLogPlotU 285,37,(285+ScreenWidth/2),(0.6*ScreenHeight - 37)
			MoveWindow /W=IR1_IQ4_Q_PlotU 285,(0.6*ScreenHeight - 37),(285+ScreenWidth/2),(0.9*(ScreenHeight-37))
			AutoPositionWIndow /M=0  /R=IR1A_ControlPanel IR1_LogLogPlotU
			AutoPositionWIndow /M=1/E  /R=IR1_LogLogPlotU IR1_IQ4_Q_PlotU
			if (recovered)
				IR1A_GraphModelData()		//graph the data here, all parameters should be defined
			endif
		else
			Abort "Data not selected properly"
		endif
	endif

	if(cmpstr(ctrlName,"DoFitting")==0 || cmpstr(ctrlName,"DoFittingSkipReset")==0)
		//here we call the fitting routine
		variable skipreset=0
		if(cmpstr(ctrlName,"DoFittingSkipReset")==0)
			skipreset = 1
		endif
		NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
		NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
		Wave OriginalQvector=root:Packages:Irena_UnifFit:OriginalQvector
		IN2G_CheckForSlitSmearedRange(UseSMRData,OriginalQvector [pcsr(B  , "IR1_LogLogPlotU")], SlitLengthUnif)
		IR1A_ConstructTheFittingCommand(skipreset)
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_GraphFitData()
	endif
	if(cmpstr(ctrlName,"RevertFitting")==0)
		//here we call the fitting routine
		IR1A_ResetParamsAfterBadFit()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSfcandInvariant()
		IR1A_GraphModelData()
	endif

	if(cmpstr(ctrlName,"ScriptingTool")==0)
		IR2S_ScriptingTool() 
		Autopositionwindow /M=1/R=IR1A_ControlPanel IR2S_ScriptingToolPnl
		NVAR GUseIndra2data=root:Packages:Irena_UnifFit:UseIndra2Data
		NVAR GUseQRSdata=root:Packages:Irena_UnifFit:UseQRSdata
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
			CB_Struct.win = "IR1A_ControlPanel"
			IR2C_InputPanelCheckboxProc(CB_Struct)		
		endif
		IR2S_UpdateListOfAvailFiles()
		IR2S_SortListOfAvailableFldrs()
	endif

	if(cmpstr(ctrlName,"GraphDistribution")==0)
		//here we graph the distribution
		NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
		NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
		Wave OriginalQvector=root:Packages:Irena_UnifFit:OriginalQvector
		IN2G_CheckForSlitSmearedRange(UseSMRData,OriginalQvector [pcsr(B  , "IR1_LogLogPlotU")], SlitLengthUnif)
		IR1A_GraphModelData()
	endif
	if(cmpstr(ctrlName,"FixLimits")==0)
		//here we graph the distribution
		IR1A_FixLimits()
	endif
	if(cmpstr(ctrlName,"ResetUnified")==0)
		//here we graph the distribution
		IR1A_ResetUnified()
	endif
	if(cmpstr(ctrlName,"ConfidenceEvaluation")==0)
		//here we graph the distribution
		IR1A_ConfidenceEvaluation()
	endif


	if(cmpstr(ctrlName,"EvaluateSpecialCases")==0)
		//here we graph the distribution
		IR2U_EvaluateUnifiedData()
	endif
	
	if(cmpstr(ctrlName,"CopyToFolder")==0 || cmpstr(ctrlName,"CopyTFolderNoQuestions")==0)
		//here we copy final data back to original data folder	
		IR1A_UpdateLocalFitsForOutput()		//create local fits 	I	
		if(cmpstr(ctrlName,"CopyTFolderNoQuestions")==0)
			IR1A_CopyDataBackToFolder("user", SaveMe="yes")
		else
			IR1A_CopyDataBackToFolder("user")
		endif
		IR1A_SaveRecordResults()
	//	DoAlert 0,"Copy"
	endif	
	if(cmpstr(ctrlName,"MarkGraphs")==0)
		//here we copy final data back to original data folder		I	
		IR1A_InsertResultsIntoGraphs()
	//	DoAlert 0,"Copy"
	endif
	
	if(cmpstr(ctrlName,"ExportData")==0)
		//here we export ASCII form of the data
		IR1A_ExportASCIIResults()
	//	DoAlert 0, "Export"
	endif

	if(cmpstr(ctrlName,"LevelXFitRgAndG")==0)
		//here we fit Rg and G area - Guiner fit level 1
		ControlInfo /W=IR1A_ControlPanel DistTabs
		IR1A_FitLocalGuinier(V_Value+1)
		IR1A_GraphModelData()
	endif
	if(cmpstr(ctrlName,"LevelXFitPAndB")==0)
		//here we fit P and B area - Porod fit level 1
		ControlInfo /W=IR1A_ControlPanel DistTabs
		IR1A_FitLocalPorod(V_Value+1)
		IR1A_GraphModelData()
	endif
	if(cmpstr(ctrlName,"Level1SetRGCODefault")==0)
		//set RGCO default
		NVAR Level1RGCO=root:Packages:Irena_UnifFit:Level1RGCO
		//NVAR Level0Rg=root:Packages:Irena_UnifFit:Level0Rg
		Level1RGCO=0
		//Level1RGCO=Level0Rg
	endif
	if(cmpstr(ctrlName,"Level2SetRGCODefault")==0)
		//set RGCO default
		NVAR Level2RGCO=root:Packages:Irena_UnifFit:Level2RGCO
		NVAR Level1Rg=root:Packages:Irena_UnifFit:Level1Rg
		Level2RGCO=Level1Rg
		IR1A_AutoUpdateIfSelected()
	endif
	if(cmpstr(ctrlName,"Level3SetRGCODefault")==0)
		//set RGCO default
		NVAR Level3RGCO=root:Packages:Irena_UnifFit:Level3RGCO
		NVAR Level2Rg=root:Packages:Irena_UnifFit:Level2Rg
		Level3RGCO=Level2Rg
		IR1A_AutoUpdateIfSelected()
	endif
	if(cmpstr(ctrlName,"Level4SetRGCODefault")==0)
		//set RGCO default
		NVAR Level4RGCO=root:Packages:Irena_UnifFit:Level4RGCO
		NVAR Level3Rg=root:Packages:Irena_UnifFit:Level3Rg
		Level4RGCO=Level3Rg
		IR1A_AutoUpdateIfSelected()
	endif
	if(cmpstr(ctrlName,"Level5SetRGCODefault")==0)
		//set RGCO default
		NVAR Level5RGCO=root:Packages:Irena_UnifFit:Level5RGCO
		NVAR Level4Rg=root:Packages:Irena_UnifFit:Level4Rg
		Level5RGCO=Level4Rg
		IR1A_AutoUpdateIfSelected()
	endif

	DoWIndow/F IR1A_ControlPanel
	if(cmpstr(ctrlName,"EvaluateSpecialCases")==0)
		DoWIndow UnifiedEvaluationPanel
		if(V_Flag)
			DoWIndow/F UnifiedEvaluationPanel
			AutoPositionWindow/M=0 /R=IR1A_ControlPanel UnifiedEvaluationPanel
		endif
	endif
	
	if(cmpstr(ctrlName,"ConfidenceEvaluation")==0)
		DoWIndow IR1A_ConfEvaluationPanel
		if(V_Flag)
			DoWindow/F IR1A_ConfEvaluationPanel
			AutoPositionWindow/M=0 /R=IR1A_ControlPanel IR1A_ConfEvaluationPanel
		endif
	endif
	setDataFolder oldDF
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
		NVAR UseIndra2Data=root:Packages:Irena_UnifFit:UseIndra2Data
		NVAR UseQRSData=root:Packages:Irena_UnifFit:UseQRSdata
		NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
		SVAR IntDf=root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QDf=root:Packages:Irena_UnifFit:QWaveName
		SVAR EDf=root:Packages:Irena_UnifFit:ErrorWaveName
		SVAR Dtf=root:Packages:Irena_UnifFit:DataFolderName

	if (cmpstr(ctrlName,"SelectDataFolder")==0)
		//here we do what needs to be done when we select data folder
		Dtf=popStr
		PopupMenu IntensityDataName mode=1
		PopupMenu QvecDataName mode=1
		PopupMenu ErrorDataName mode=1
		if (UseIndra2Data)
			IntDf=stringFromList(0,IR1_ListIndraWavesForPopups("DSM_Int","Irena_UnifFit",(-1)*UseSMRData,1))
			QDf=stringFromList(0,IR1_ListIndraWavesForPopups("DSM_Qvec","Irena_UnifFit",(-1)*UseSMRData,1))
			EDf=stringFromList(0,IR1_ListIndraWavesForPopups("DSM_Error","Irena_UnifFit",(-1)*UseSMRData,1))
			Execute("PopupMenu IntensityDataName value=IR1_ListIndraWavesForPopups(\"DSM_Int\",\"Irena_UnifFit\",(-1)*root:Packages:Irena_UnifFit:UseSMRData,1)")
			Execute("PopupMenu QvecDataName value=IR1_ListIndraWavesForPopups(\"DSM_Qvec\",\"Irena_UnifFit\",(-1)*root:Packages:Irena_UnifFit:UseSMRData,1)")
			Execute("PopupMenu ErrorDataName value=IR1_ListIndraWavesForPopups(\"DSM_Error\",\"Irena_UnifFit\",(-1)*root:Packages:Irena_UnifFit:UseSMRData,1)")
		else
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName value="---"
			PopupMenu QvecDataName  value="---"
			PopupMenu ErrorDataName  value="---"
		endif
		if(UseQRSdata)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---;"+IR1_ListOfWaves("DSM_Int","Irena_UnifFit",0,0)
			PopupMenu QvecDataName  value="---;"+IR1_ListOfWaves("DSM_Qvec","Irena_UnifFit",0,0)
			PopupMenu ErrorDataName  value="---;"+IR1_ListOfWaves("DSM_Error","Irena_UnifFit",0,0)
		endif
		if(!UseQRSdata && !UseIndra2Data)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---;"+IR1_ListOfWaves("DSM_Int","Irena_UnifFit",0,0)
			PopupMenu QvecDataName  value="---;"+IR1_ListOfWaves("DSM_Qvec","Irena_UnifFit",0,0)
			PopupMenu ErrorDataName  value="---;"+IR1_ListOfWaves("DSM_Error","Irena_UnifFit",0,0)
		endif
		if (cmpstr(popStr,"---")==0)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---"
			PopupMenu QvecDataName  value="---"
			PopupMenu ErrorDataName  value="---"
		endif
	endif
	
	if (cmpstr(ctrlName,"IntensityDataName")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			IntDf=popStr
			if (UseQRSData && strlen(QDf)==0 && strlen(EDf)==0)
				QDf="q"+popStr[1,inf]
				EDf="s"+popStr[1,inf]
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:Irena_UnifFit:QWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"Irena_UnifFit\",0,0)")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:Irena_UnifFit:ErrorWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Error\",\"Irena_UnifFit\",0,0)")
			endif
		else
			IntDf=""
		endif
	endif

	if (cmpstr(ctrlName,"QvecDataName")==0)
		//here goes what needs to be done, when we select this popup...	
		if (cmpstr(popStr,"---")!=0)
			QDf=popStr
			if (UseQRSData && strlen(IntDf)==0 && strlen(EDf)==0)
				IntDf="r"+popStr[1,inf]
				EDf="s"+popStr[1,inf]
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:Irena_UnifFit:IntensityWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Int\",\"Irena_UnifFit\",0,0)")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:Irena_UnifFit:ErrorWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Error\",\"Irena_UnifFit\",0,0)")
			endif
		else
			QDf=""
		endif
	endif
	
	if (cmpstr(ctrlName,"ErrorDataName")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			EDf=popStr
			if (UseQRSData && strlen(IntDf)==0 && strlen(QDf)==0)
				IntDf="r"+popStr[1,inf]
				QDf="q"+popStr[1,inf]
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:Irena_UnifFit:IntensityWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Int\",\"Irena_UnifFit\",0,0)")
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:Irena_UnifFit:QWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"Irena_UnifFit\",0,0)")
			endif
		else
			EDf=""
		endif
	endif
	
	if (cmpstr(ctrlName,"NumberOfLevels")==0)
		//here goes what happens when we change number of distributions
		NVAR nmbdist=root:Packages:Irena_UnifFit:NumberOfLevels
		nmbdist=popNum-1
		IR1A_FixTabsInPanel()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1KFactor")==0)
		NVAR Level1K=root:Packages:Irena_UnifFit:Level1K
		Level1K=str2num(popStr)
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level2KFactor")==0)
		NVAR Level2K=root:Packages:Irena_UnifFit:Level2K
		Level2K=str2num(popStr)
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level3KFactor")==0)
		NVAR Level3K=root:Packages:Irena_UnifFit:Level3K
		Level3K=str2num(popStr)
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level4KFactor")==0)
		NVAR Level4K=root:Packages:Irena_UnifFit:Level4K
		Level4K=str2num(popStr)
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level5KFactor")==0)
		NVAR Level5K=root:Packages:Irena_UnifFit:Level5K
		Level5K=str2num(popStr)
		IR1A_AutoUpdateIfSelected()
	endif
	
	
	setDataFolder oldDF

End

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_AutoUpdateIfSelected()
	
	NVAR UpdateAutomatically=root:Packages:Irena_UnifFit:UpdateAutomatically
	if (UpdateAutomatically)
		IR1A_GraphModelData()
		NVAR ActTab=root:Packages:Irena_UnifFit:ActiveTab
		IR1A_DisplayLocalFits(ActTab, 0)
	endif
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_FixTabsInPanel()
	//here we modify the panel, so it reflects the selected number of distributions
	
	NVAR NumOfDist=root:Packages:Irena_UnifFit:NumberOfLevels
	
	
	//and now return us back to original tab...
	NVAR ActTab=root:Packages:Irena_UnifFit:ActiveTab
	IR1A_TabPanelControl("Checkbox",ActTab-1)
	variable SetToTab
	SetToTab=ActTab-1
	if(SetToTab<0)
		SetToTab=0
	endif
	TabControl DistTabs,value= SetToTab, win=IR1A_ControlPanel
	IR1A_TabPanelControl("bla",SetToTab)
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_GraphModelData()
		IR1A_UnifiedCalculateIntensity()
		//now calculate the normalized error wave
		IR1A_CalculateNormalizedError("graph")
		//append waves to the two top graphs with measured data
		IR1A_AppendModelToMeasuredData()	//modified for 5		
		ControlInfo/W=IR1A_ControlPanel DistTabs
		IR1A_DisplayLocalFits(V_Value+1,0)
		IR1A_CheckAllUnifiedLevels()
		IR1A_CheckTabUnifiedLevel()
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR1A_CheckTabUnifiedLevel()
		ControlInfo/W=IR1A_ControlPanel DistTabs
		variable selectedTab = (V_Value+1)
		//variable DisplayMe=(1-IR1A_CheckOneUnifiedLevel(selectedTab,0))
		TitleBox PhysValidityWarning, win=IR1A_ControlPanel, disable=(IR1A_CheckOneUnifiedLevel(selectedTab,0)!=0)
end

///******************************************************************************************
///******************************************************************************************
Function IR1A_CheckAllUnifiedLevels()
	variable i
	NVAR ExtendedWarnings=root:Packages:Irena_UnifFit:ExtendedWarnings
	if(ExtendedWarnings)
		print "             *************          "
		print "Check for physicall feasibility of Unified levels used : "
	endif
		For(i=1;i<=5;i+=1)
			IR1A_CheckOneUnifiedLevel(i,ExtendedWarnings)
		endfor
	if(ExtendedWarnings)
		print " ***   Note: these checks are only approximate   **********          "
	endif
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1A_CheckOneUnifiedLevel(LevelNumber,printResult)
	variable LevelNumber, printResult
	
//NVAR printResult=root:Packages:Irena_UnifFit:ExtendedWarnings
	NVAR RgVal = $("root:Packages:Irena_UnifFit:Level"+num2str(LevelNumber)+"Rg")
	NVAR GVal = $("root:Packages:Irena_UnifFit:Level"+num2str(LevelNumber)+"G")
	NVAR PVal = $("root:Packages:Irena_UnifFit:Level"+num2str(LevelNumber)+"P")
	NVAR BVal = $("root:Packages:Irena_UnifFit:Level"+num2str(LevelNumber)+"B")
	NVAR NumberOfLevels = root:Packages:Irena_UnifFit:NumberOfLevels
	if(NumberOfLevels>=LevelNumber)
		if(IR1A_CheckUnifiedFitvalidity(RgVal, GVal, BVal, PVal))
			if(printResult)
				Print "Level "+num2str(LevelNumber)+" is physically feasible"
			endif
			return 1
		else
			if(printResult)
				Print "Level "+num2str(LevelNumber)+" -  Warning, this level may not be physically feasible based on Rg/G and P/B values"
			endif
			return 0
		endif
	else
		return 0
	endif
	
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1A_CheckUnifiedFitvalidity(RgVal, GVal, BVal, PVal)
	variable RgVal, GVal, BVal, PVal

	if(GVal<=0 && RgVal>1e9)	//this is default for removing this at last level
		return 1
	endif
	//rollover Q value (Hammouda) should be 
	//  Q1 = 1/Rg * sqrt( (PVal)/2)
	variable Q1 = 2 * 1/RgVal * sqrt( (PVal)/2)
	variable GuinierValue = GVal * exp((-Q1^2 * RgVal^2)/3)
	variable PowerLawValue = BVal / (Q1^PVal)
	//print Q1
	variable  Difference = ((PowerLawValue - GuinierValue )/(GuinierValue))
	//print "Difference is : "+num2str(Difference)
	//variable PredictedBValue=GVal * exp(-Q1^2 * RgVal^2/3)*(Q1^PVal)
	//print "Q merge point " + num2str(Q1)
	//print "Guinier value is " + num2str(GuinierValue)
	//print "Power Law value is " + num2str(PowerLawValue)
	//print "Hammouda Predicted B value   "+ num2str(PredictedBValue)
	//this number indicates when level is physically meaningful 
	variable IR1APhysValidityLLimit=-0.633		// low limit of difference - it is difference between Guinier and Porod at match Q as fraction
	variable IR1APhysValidityHLimit=2.25		// high limit of difference - it is difference between Guinier and Porod at match Q as fraction

	if(Difference<(IR1APhysValidityLLimit) || Difference>(IR1APhysValidityHLimit))
		return 0		//level invalid
	else		
		return 1		//level valid
	endif
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_GraphFitData()

		IR1A_UnifiedCalculateIntensity()
		//now calculate the normalized error wave
		IR1A_CalculateNormalizedError("fit")
		//append waves to the two top graphs with measured data
		IR1A_AppendModelToMeasuredData()	//modified for 5		
end
	

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_AppendModelToMeasuredData()
	//here we need to append waves with calculated intensities to the measured data

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
	
	Wave Intensity=root:Packages:Irena_UnifFit:UnifiedFitIntensity
	Wave QVec=root:Packages:Irena_UnifFit:UnifiedFitQvector
	Wave IQ4=root:Packages:Irena_UnifFit:UnifiedIQ4
	Wave/Z NormalizedError=root:Packages:Irena_UnifFit:NormalizedError
	Wave/Z NormErrorQvec=root:Packages:Irena_UnifFit:NormErrorQvec
	
	DoWindow/F IR1_LogLogPlotU
	variable CsrAPos
	if (strlen(CsrWave(A))!=0)
		CsrAPos=pcsr(A)
	else
		CsrAPos=0
	endif
	variable CsrBPos
	if (strlen(CsrWave(B))!=0)
		CsrBPos=pcsr(B)
	else
		CsrBPos=numpnts(Intensity)-1
	endif
	
	DoWIndow IR1_LogLogPlotU
	if (!V_Flag)
		abort
	endif
	DoWIndow IR1_IQ4_Q_PlotU
	if (!V_Flag)
		abort
	endif
	SVAR Folder=root:Packages:Irena_UnifFit:DataFolderName
	SVAR WvName=root:Packages:Irena_UnifFit:IntensityWaveName
	RemoveFromGraph /Z/W=IR1_LogLogPlotU UnifiedFitIntensity 
	RemoveFromGraph /Z/W=IR1_LogLogPlotU NormalizedError 
	RemoveFromGraph /Z/W=IR1_IQ4_Q_PlotU UnifiedIQ4 

	AppendToGraph/W=IR1_LogLogPlotU Intensity vs Qvec
	cursor/P/W=IR1_LogLogPlotU A, OriginalIntensity, CsrAPos	
	cursor/P/W=IR1_LogLogPlotU B, OriginalIntensity, CsrBPos	
	ModifyGraph/W=IR1_LogLogPlotU rgb(UnifiedFitIntensity)=(0,0,0)
	ModifyGraph/W=IR1_LogLogPlotU mode(OriginalIntensity)=3
	ModifyGraph/W=IR1_LogLogPlotU msize(OriginalIntensity)=2//***DWS
	ModifyGraph/W=IR1_LogLogPlotU marker(OriginalIntensity)=8
	ShowInfo/W=IR1_LogLogPlotU
	TextBox/W=IR1_LogLogPlotU/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR1_LogLogPlotU/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+Folder+WvName	
	if (WaveExists(NormalizedError))
		AppendToGraph/R/W=IR1_LogLogPlotU NormalizedError vs NormErrorQvec
		ModifyGraph/W=IR1_LogLogPlotU  mode(NormalizedError)=3,marker(NormalizedError)=8
		ModifyGraph/W=IR1_LogLogPlotU zero(right)=4
		ModifyGraph/W=IR1_LogLogPlotU msize(NormalizedError)=1,rgb(NormalizedError)=(0,0,0)
		SetAxis/W=IR1_LogLogPlotU /A/E=2 right
		ModifyGraph/W=IR1_LogLogPlotU log(right)=0
		Label/W=IR1_LogLogPlotU right "Standardized residual"
	else
		ModifyGraph/W=IR1_LogLogPlotU mirror(left)=1
	endif
	ModifyGraph/W=IR1_LogLogPlotU log(left)=1
	ModifyGraph/W=IR1_LogLogPlotU log(bottom)=1
	ModifyGraph/W=IR1_LogLogPlotU mirror(bottom)=1
	Label/W=IR1_LogLogPlotU left "Intensity [cm\\S-1\\M]"
	Label/W=IR1_LogLogPlotU bottom "Q [A\\S-1\\M]"
	ErrorBars/Y=1/W=IR1_LogLogPlotU OriginalIntensity Y,wave=(root:Packages:Irena_UnifFit:OriginalError,root:Packages:Irena_UnifFit:OriginalError)
	Legend/W=IR1_LogLogPlotU/N=text0/K
	Legend/W=IR1_LogLogPlotU/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 "\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")+Folder+WvName+"\r"+"\\s(OriginalIntensity) Experimental intensity"
	AppendText/W=IR1_LogLogPlotU "\\s(UnifiedFitIntensity) Unified calculated Intensity"
	if (WaveExists(NormalizedError))
		AppendText/W=IR1_LogLogPlotU "\\s(NormalizedError) Standardized residual"
	endif
	ModifyGraph/W=IR1_LogLogPlotU rgb(OriginalIntensity)=(0,0,0),lstyle(UnifiedFitIntensity)=0
	ModifyGraph/W=IR1_LogLogPlotU rgb(UnifiedFitIntensity)=(65280,0,0)

	AppendToGraph/W=IR1_IQ4_Q_PlotU IQ4 vs Qvec
	ModifyGraph/W=IR1_IQ4_Q_PlotU rgb(UnifiedIQ4)=(65280,0,0)
	ModifyGraph/W=IR1_IQ4_Q_PlotU mode=3
	ModifyGraph/W=IR1_IQ4_Q_PlotU msize=1
	ModifyGraph/W=IR1_IQ4_Q_PlotU log=1
	ModifyGraph/W=IR1_IQ4_Q_PlotU mirror=1
	ModifyGraph/W=IR1_IQ4_Q_PlotU mode(UnifiedIQ4)=0
	TextBox/W=IR1_IQ4_Q_PlotU/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR1_IQ4_Q_PlotU/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+Folder+WvName	
	Label/W=IR1_IQ4_Q_PlotU left "Intensity * Q^4"
	Label/W=IR1_IQ4_Q_PlotU bottom "Q [A\\S-1\\M]"
	ErrorBars/Y=1/W=IR1_IQ4_Q_PlotU OriginalIntQ4 Y,wave=(root:Packages:Irena_UnifFit:OriginalErrQ4,root:Packages:Irena_UnifFit:OriginalErrQ4)
	Legend/W=IR1_IQ4_Q_PlotU/N=text0/K
	Legend/W=IR1_IQ4_Q_PlotU/N=text0/J/F=0/A=MC/X=-29.74/Y=37.76 "\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")+Folder+WvName+"\r"+"\\s(OriginalIntQ4) Experimental intensity * Q^4"
	AppendText/W=IR1_IQ4_Q_PlotU "\\s(UnifiedIQ4) Unified Calculated intensity * Q^4"
	ModifyGraph/W=IR1_IQ4_Q_PlotU rgb(OriginalIntq4)=(0,0,0)
	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

	
Function	IR1A_CalculateNormalizedError(CalledWhere)
		string CalledWhere	// "fit" or "graph"

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
		if (cmpstr(CalledWhere,"fit")==0)
			Wave/Z ExpInt=root:Packages:Irena_UnifFit:FitIntensityWave
			if (WaveExists(ExpInt))
				Wave ExpError=root:Packages:Irena_UnifFit:FitErrorWave
				Wave FitIntCalc=root:Packages:Irena_UnifFit:UnifiedFitIntensity
				Wave FitIntQvec=root:Packages:Irena_UnifFit:UnifiedFitQvector
				Wave FitQvec=root:Packages:Irena_UnifFit:FitQvectorWave
				variable mystart=binarysearch(FitIntQvec,FitQvec[0])
				variable myend=binarysearch(FitIntQvec,FitQvec[numpnts(FitQvec)-1])
				Duplicate/O/R=[mystart,myend] FitIntCalc, FitInt
				Wave FitInt
				Duplicate /O ExpInt, NormalizedError
				Duplicate/O FitQvec, NormErrorQvec
				NormalizedError=(ExpInt-FitInt)/ExpError
				KillWaves/Z FitInt
			endif
		endif
		if (cmpstr(CalledWhere,"graph")==0)
			Wave ExpInt=root:Packages:Irena_UnifFit:OriginalIntensity
			Wave ExpError=root:Packages:Irena_UnifFit:OriginalError
			Wave FitInt=root:Packages:Irena_UnifFit:UnifiedFitIntensity
			Wave OrgQvec=root:Packages:Irena_UnifFit:OriginalQvector
			Duplicate/O OrgQvec, NormErrorQvec
			Duplicate/O FitInt, NormalizedError
			NormalizedError=(ExpInt-FitInt)/ExpError
		endif	
	setDataFolder oldDf
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_InsertResultsIntoGraphs()
	
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	variable i
	for(i=1;i<=NumberOfLevels;i+=1)	
		IR1A_InsertOneLevelResInGrph(i)
	endfor											
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_InsertOneLevelResInGrph(Lnmb)
	variable Lnmb
	
	setDataFolder root:Packages:Irena_UnifFit

	NVAR SASBackgroundError=$("SASBackgroundError")
	NVAR SASBackground=$("SASBackground")
	NVAR RgError=$("Level"+num2str(Lnmb)+"RgError")
	NVAR GError=$("Level"+num2str(Lnmb)+"GError")
	NVAR PError=$("Level"+num2str(Lnmb)+"PError")
	NVAR BError=$("Level"+num2str(Lnmb)+"BError")
	NVAR ETAError=$("Level"+num2str(Lnmb)+"ETAError")
	NVAR PACKError=$("Level"+num2str(Lnmb)+"PACKError")
	NVAR RGCOError=$("Level"+num2str(Lnmb)+"RGCOError")
	NVAR Rg=$("Level"+num2str(Lnmb)+"Rg")
	NVAR G=$("Level"+num2str(Lnmb)+"G")
	NVAR P=$("Level"+num2str(Lnmb)+"P")
	NVAR B=$("Level"+num2str(Lnmb)+"B")
	NVAR K=$("Level"+num2str(Lnmb)+"K")
	NVAR ETA=$("Level"+num2str(Lnmb)+"ETA")
	NVAR PACK=$("Level"+num2str(Lnmb)+"PACK")
	NVAR RGCO=$("Level"+num2str(Lnmb)+"RGCO")
	NVAR LinkRGCO=$("Level"+num2str(Lnmb)+"LinkRGCO")
	NVAR Corelations=$("Level"+num2str(Lnmb)+"Corelations")
	NVAR MassFractal=$("Level"+num2str(Lnmb)+"MassFractal")
	NVAR SurfaceToVolume=$("Level"+num2str(Lnmb)+"SurfaceToVolRat")
	NVAR Invariant=$("Level"+num2str(Lnmb)+"Invariant")

	string LogLogTag, IQ4Tag, tagname
	tagname="Level"+num2str(Lnmb)+"Tag"
	Wave OriginalQvector
		
	variable QtoAttach=2/Rg
	variable AttachPointNum=binarysearch(OriginalQvector,QtoAttach)
	
	LogLogTag="\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")+"Unified Fit for level "+num2str(Lnmb)+"\r"
	if (GError>0)
		LogLogTag+="G = "+num2str(G)+"  \t"+num2str(GError)+"\r"
	else
		LogLogTag+="G = "+num2str(G)+"  \t 0 "+"\r"	
	endif
	if (RgError>0)
		LogLogTag+="Rg = "+num2str(Rg)+"[A]  \t "+num2str(RgError)+"\r"
	else
		LogLogTag+="Rg = "+num2str(Rg)+"[A]   \t 0 "+"\r"
	endif	
	if (BError>0)
		LogLogTag+="B = "+num2str(B)+"  \t "+num2str(BError)+"\r"
	else
		LogLogTag+="B = "+num2str(B)+"  \t 0 "+"\r"
	endif
	if (PError>0)
		LogLogTag+="P = "+num2str(P)+"  \t "+num2str(PError)+"\r"
	else
		LogLogTag+="P = "+num2str(P)+"  \t 0  "	+"\r"
	endif
	if (MassFractal)
		LogLogTag+="Mass fractal assumed"+"\r"
	endif
	if (LinkRGCO)
		LogLogTag+="RgCO linked to Rg of level"+num2str(Lnmb-1)
	else
		if (RGCOError>0)
			LogLogTag+="RgCO = "+num2str(RGCO)+"[A]   \t "+num2str(RGCOError)+", K = "+num2str(K)
		else
			LogLogTag+="RgCO = "+num2str(RGCO)+"[A]   \t 0 , K = "+num2str(K)
		endif
	endif
	if (Corelations)
		LogLogTag+="\rAssumed corelations:\r"
		if (ETAError>0)
			LogLogTag+= "ETA = "+num2str(ETA)+"[A]   \t "+num2str(ETAError)
		else
			LogLogTag+= "ETA = "+num2str(ETA)+"[A]   \t 0 "
		endif
		if (PackError>0)
			LogLogTag+= ", Pack = "+num2str(PACK)+"  \t "+num2str(PackError)
		else
			LogLogTag+= ", Pack = "+num2str(PACK)+"  \t 0 "
		endif
	endif
	if (Lnmb==1)
		if (SASBackgroundError>0)
			LogLogTag+="\rSAS Background = "+num2str(SASBackground)+"     +/-   "+num2str(SASBackgroundError)
		else
			LogLogTag+="\rSAS Background = "+num2str(SASBackground)+"     (fixed)   "
		endif
	endif
	if (numtype(Invariant)==0)
		LogLogTag+="\rInvariant [cm^(-4)] = "+num2str(Invariant)
	endif
	if (numtype(SurfaceToVolume)==0)
		LogLogTag+="      Surface to Volume ratio = "+num2str(SurfaceToVolume)+"  m^2/cm^3"
	endif
	
	IQ4Tag=LogLogTag
	Tag/W=IR1_LogLogPlotU/C/N=$(tagname)/F=2/L=2/M OriginalIntensity, AttachPointNum, LogLogTag
	Tag/W=IR1_IQ4_Q_PlotU/C/N=$(tagname)/F=2/L=2/M OriginalIntQ4, AttachPointNum, IQ4Tag
	
	
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1A_CorrectLimitsAndValues()
	//this function check the limits, if they make sense for all used levels and sets them according to rules
	
	setDataFolder root:Packages:Irena_UnifFit

	NVAR nmbLevls=root:Packages:Irena_UnifFit:NumberOfLevels

	variable i
	
	For(i=1;i<=nmbLevls;i+=1)
		//Rules to check:
		//Rg should be larger than Rg of previous level, NA for level 1
		if (i>1)
			NVAR PreviousRg=$("Level"+num2str(i-1)+"Rg")
			NVAR CurrentRgLowLimit=$("Level"+num2str(i)+"RgLowLimit")
			if (CurrentRgLowLimit<PreviousRg)
				CurrentRgLowLimit=PreviousRg
			endif
		endif 
		
		//If G=0 the we need to set Rg for that level to high number to remove it from graph
		NVAR CurrentRg=$("Level"+num2str(i)+"Rg")
		NVAR CurrentG=$("Level"+num2str(i)+"G")
		if (CurrentG==0)
			CurrentRg=10^10
		endif
		
		//ETA foe any level must be larger than Rg for that level
		NVAR CurrentETALowLimit=$("Level"+num2str(i)+"EtaLowLimit")
		NVAR CurrentETA=$("Level"+num2str(i)+"Eta")
		if (CurrentETALowLimit<CurrentRg)
			CurrentETALowLimit=CurrentRg
		endif
		if (CurrentETA<CurrentRg)
			CurrentETA=CurrentRg
		endif
	endfor
	
end

