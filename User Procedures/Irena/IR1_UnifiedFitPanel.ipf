#pragma rtGlobals = 3	// Use strict wave reference mode and runtime bounds checking
//#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.27

Constant IR1AversionNumber=2.27


//*************************************************************************\
//* Copyright (c) 2005 - 2020, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.27 added button to open wikipedia page. 
//2.26 added info on K value to panel. Need to force reopen now, unluckily. 
//2.25 combined with IR1_Unified_Panel_Fncts.ipf and removed that from code
//2.23 removed Execute for main panel, added button to move around the levels if users needs...
//2.22 Modified Screen Size check to match the needs
//2.21 added  Help button calling www manual page
//2.20 added scaling panel content
//2.19 fixed Tab display of B which got confused under some circumstances... 
//2.18 changed Surf/Volume ratio per Dale Schaefer's description.  
//2.17 fixed Link B to G/Rg/P for Level 2, typo in the code. 
//2.16 changed ETA step to be 1% of the value, Dale said 5% is too much, changed surf/VOl ratio to fi*(1-fi)*Surf/Vol ratio as correct per DWS. 
//2.15 added checkbox to limit warnings in the history area..., Fixes provided by DWS
//2.14 Added option to rebin data to lower number of points on data load. 
//2.13 added option to link B to Rg/G/P using Hammouda Calculations
//2.12 removed FitRgCO for all levels. DO not expect anyone to miss it. But if needed, can be returned easily. 
//2.11 added option providing user with fit parameters review panel before fitting
//2.10 added scroll controls to move panel conent up or down for small displays.
//2.09 added "No limits" checkbox
//2.08 added ability to analyze effects of uncertainities on the results of the fits. 
//2.07 Added check for physical meaningfulness of the levels.  Now have red text box coming up with warning and history area prints... May be too much? 
//    modified buttons for local fits to be only one copy. Changed way the graphs sizes are created to make moire sensibgle sizes (~50% of screen both graphs combined). 
//2.06 added Confidence Evaluation tool
//2.05 removed steps - steps are now changing dynamically to 5% of current value
//		modified GUI on Mac back to Mac native and reduced number of significant digists in various diplays. 
//        removed all font and font size from panel definitions to enable user control
//2.04 added button to scripting tool and added panel version control. 
//2.03 modified TabProc to try to speed up the process, same change in IR1_Unified_Pane_Fncts.ipf version 2.03, set Unified panel to os9 appearance on Mac to speed things up until the issue with 
     // the slow update speed of native controls is sorted out. 
//2.02 added license for ANL
//version 2.01 adds the Analyze Results

//original IR1_Unified_Panel_Fncts.ipf

//2.25 modifed handling of limits and steps in the arrows to avoid loosing the arrows altogether when user inputs 0. 
//2.24 added better Graph size control using IN2G_GetGraphWidthHeight function
//2.23 added getHelp button function. 
//2.22 fixed IR1A_AutoUpdateIfSelected which called local display code twice. 
//2.21 fixed display of warning messages from teh tab when tab was not used. 
//2.20 removed most Execute to speed up fro Igor 7. 
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




//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from usaxs.xray.aps.anl.gov
//this package contains 
// Igor functions for modeling of SAS from various distributions of scatterers...

//Jan Ilavsky, March 2002

//please, read Readme distributed with the package
//report any problems to: ilavsky@aps.anl.gov 
//main functions for modeling with user input of distributions...

//comment :
// the invariant is:
//   2*pi^2*FI(1-FI)*delta-rho-squared
// Need to convert the Unified provided invariant to cm^-4 by multiplying by 10^24 (from cm^-1A^-3 to cm^-4)



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
  

Function IR1A_UnifiedModel()

	IN2G_CheckScreenSize("height",720)
	
	KillWIndow/Z IR1A_ControlPanel
 	KillWIndow/Z IR1_LogLogPlotU
 	KillWIndow/Z IR1_IQ4_Q_PlotU
 
	IR1A_Initialize(0)					//this may be OK now... 

	IR1A_ControlPanelFnct()			//make the main panel,. 
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("IR1A_ControlPanel", IR1AversionNumber,1)

end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
 
Function IR1A_ResetUnified()
	IR1A_Initialize(1)					//this may be OK now... 
	DoWindow IR1A_ControlPanel
	if(V_Flag)
		IR1A_TabPanelControl("",0)
	endif	
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1A_MainCheckVersion()	
	DoWindow IR1A_ControlPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR1A_ControlPanel", IR1AversionNumber))
			DoAlert /T="The Unified fit panel was created by incorrect version of Irena " 1, "Unified fit may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				IR1A_UnifiedModel()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR1A_Initialize(0)					//this may be OK now... 
			endif
		endif
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_Initialize(enforceReset)
	variable enforceReset
	//function, which creates the folder for SAS modeling and creates the strings and variables
	
	DFref oldDf= GetDataFolderDFR()

	
	NewDataFolder/O/S root:Packages
	NewdataFolder/O/S root:Packages:Irena_UnifFit
	
	string ListOfVariables
	string ListOfStrings
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="UseIndra2Data;UseQRSdata;NumberOfLevels;SubtractBackground;UseSMRData;SlitLengthUnif;UseNoLimits;ExtendedWarnings;"
	ListOfVariables+="Level1Rg;Level1FitRg;Level1RgLowLimit;Level1RgHighLimit;Level1G;Level1FitG;Level1GLowLimit;Level1GHighLimit;"
	ListOfVariables+="Level1RgStep;Level1GStep;Level1PStep;Level1BStep;Level1EtaStep;Level1PackStep;"
	ListOfVariables+="Level1P;Level1FitP;Level1PLowLimit;Level1PHighLimit;Level1B;Level1FitB;Level1BLowLimit;Level1BHighLimit;"
	ListOfVariables+="Level1ETA;Level1FitETA;Level1ETALowLimit;Level1ETAHighLimit;Level1PACK;Level1FitPACK;Level1PACKLowLimit;Level1PACKHighLimit;"
	ListOfVariables+="Level1RgCO;Level1LinkRgCO;Level1FitRgCO;Level1RgCOLowLimit;Level1RgCOHighLimit;Level1K;"
	ListOfVariables+="Level1Corelations;Level1MassFractal;Level1DegreeOfAggreg;Level1SurfaceToVolRat;Level1Invariant;"
	ListOfVariables+="Level1RgError;Level1GError;Level1PError;Level1BError;Level1ETAError;Level1PACKError;Level1RGCOError;"
	ListOfVariables+="Level2Rg;Level2FitRg;Level2RgLowLimit;Level2RgHighLimit;Level2G;Level2FitG;Level2GLowLimit;Level2GHighLimit;"
	ListOfVariables+="Level2RgStep;Level2GStep;Level2PStep;Level2BStep;Level2EtaStep;Level2PackStep;"
	ListOfVariables+="Level2P;Level2FitP;Level2PLowLimit;Level2PHighLimit;Level2B;Level2FitB;Level2BLowLimit;Level2BHighLimit;"
	ListOfVariables+="Level2ETA;Level2FitETA;Level2ETALowLimit;Level2ETAHighLimit;Level2PACK;Level2FitPACK;Level2PACKLowLimit;Level2PACKHighLimit;"
	ListOfVariables+="Level2RgCO;Level2LinkRgCO;Level2FitRgCO;Level2RgCOLowLimit;Level2RgCOHighLimit;Level2K;"
	ListOfVariables+="Level2Corelations;Level2MassFractal;Level2DegreeOfAggreg;Level2SurfaceToVolRat;Level2Invariant;"
	ListOfVariables+="Level2RgError;Level2GError;Level2PError;Level2BError;Level2ETAError;Level2PACKError;Level2RGCOError;"
	ListOfVariables+="Level3Rg;Level3FitRg;Level3RgLowLimit;Level3RgHighLimit;Level3G;Level3FitG;Level3GLowLimit;Level3GHighLimit;"
	ListOfVariables+="Level3RgStep;Level3GStep;Level3PStep;Level3BStep;Level3EtaStep;Level3PackStep;"
	ListOfVariables+="Level3P;Level3FitP;Level3PLowLimit;Level3PHighLimit;Level3B;Level3FitB;Level3BLowLimit;Level3BHighLimit;"
	ListOfVariables+="Level3ETA;Level3FitETA;Level3ETALowLimit;Level3ETAHighLimit;Level3PACK;Level3FitPACK;Level3PACKLowLimit;Level3PACKHighLimit;"
	ListOfVariables+="Level3RgCO;Level3LinkRgCO;Level3FitRgCO;Level3RgCOLowLimit;Level3RgCOHighLimit;Level3K;"
	ListOfVariables+="Level3Corelations;Level3MassFractal;Level3DegreeOfAggreg;Level3SurfaceToVolRat;Level3Invariant;"
	ListOfVariables+="Level3RgError;Level3GError;Level3PError;Level3BError;Level3ETAError;Level3PACKError;Level3RGCOError;"
	ListOfVariables+="Level4Rg;Level4FitRg;Level4RgLowLimit;Level4RgHighLimit;Level4G;Level4FitG;Level4GLowLimit;Level4GHighLimit;"
	ListOfVariables+="Level4RgStep;Level4GStep;Level4PStep;Level4BStep;Level4EtaStep;Level4PackStep;"
	ListOfVariables+="Level4P;Level4FitP;Level4PLowLimit;Level4PHighLimit;Level4B;Level4FitB;Level4BLowLimit;Level4BHighLimit;"
	ListOfVariables+="Level4ETA;Level4FitETA;Level4ETALowLimit;Level4ETAHighLimit;Level4PACK;Level4FitPACK;Level4PACKLowLimit;Level4PACKHighLimit;"
	ListOfVariables+="Level4RgCO;Level4LinkRgCO;Level4FitRgCO;Level4RgCOLowLimit;Level4RgCOHighLimit;Level4K;"
	ListOfVariables+="Level4Corelations;Level4MassFractal;Level4DegreeOfAggreg;Level4SurfaceToVolRat;Level4Invariant;"
	ListOfVariables+="Level4RgError;Level4GError;Level4PError;Level4BError;Level4ETAError;Level4PACKError;Level4RGCOError;"
	ListOfVariables+="Level5Rg;Level5FitRg;Level5RgLowLimit;Level5RgHighLimit;Level5G;Level5FitG;Level5GLowLimit;Level5GHighLimit;"
	ListOfVariables+="Level5RgStep;Level5GStep;Level5PStep;Level5BStep;Level5EtaStep;Level5PackStep;"
	ListOfVariables+="Level5P;Level5FitP;Level5PLowLimit;Level5PHighLimit;Level5B;Level5FitB;Level5BLowLimit;Level5BHighLimit;"
	ListOfVariables+="Level5ETA;Level5FitETA;Level5ETALowLimit;Level5ETAHighLimit;Level5PACK;Level5FitPACK;Level5PACKLowLimit;Level5PACKHighLimit;"
	ListOfVariables+="Level5RgCO;Level5LinkRgCO;Level5FitRgCO;Level5RgCOLowLimit;Level5RgCOHighLimit;Level5K;"
	ListOfVariables+="Level5Corelations;Level5MassFractal;Level5DegreeOfAggreg;Level5SurfaceToVolRat;Level5Invariant;"
	ListOfVariables+="Level5RgError;Level5GError;Level5PError;Level5BError;Level5ETAError;Level5PACKError;Level5RGCOError;"
	ListOfVariables+="SASBackground;SASBackgroundError;SASBackgroundStep;FitSASBackground;UpdateAutomatically;DisplayLocalFits;ActiveTab;ExportLocalFIts;"
	ListOfVariables+="SkipFitControlDialog;RebinDataTo;"
	ListOfVariables+="Level1LinkB;Level2LinkB;Level3LinkB;Level4LinkB;Level5LinkB;"

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
	//cleanup after possible previous fitting stages...
	Wave/Z CoefNames=root:Packages:Irena_UnifFit:CoefNames
	Wave/Z CoefficientInput=root:Packages:Irena_UnifFit:CoefficientInput
	KillWaves/Z CoefNames, CoefficientInput
	
//	Execute ("IR1A_SetInitialValues()")										
	IR1A_SetInitialValues(enforceReset)			
	setDataFolder OldDF							
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_SetInitialValues(enforce)
	variable enforce
	//and here set default values...

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit
	
	string ListOfVariables
	variable i
	//here we set what needs to be 0
	ListOfVariables="NumberOfLevels;Level1FitRg;Level1FitG;Level1FitP;Level1FitB;Level1FitETA;Level1FitPACK;Level1FitRgCO;Level1MassFractal;Level1LinkRgCO;Level1Corelations;"
	ListOfVariables+="Level2FitRg;Level2FitG;Level2FitP;Level2FitB;Level2FitETA;Level2FitPACK;Level2FitRgCO;Level2MassFractal;Level2LinkRgCO;Level2Corelations;"
	ListOfVariables+="Level3FitRg;Level3FitG;Level3FitP;Level3FitB;Level3FitETA;Level3FitPACK;Level3FitRgCO;Level3MassFractal;Level3LinkRgCO;Level3Corelations;"
	ListOfVariables+="Level4FitRg;Level4FitG;Level4FitP;Level4FitB;Level4FitETA;Level4FitPACK;Level4FitRgCO;Level4MassFractal;Level4LinkRgCO;Level4Corelations;"
	ListOfVariables+="Level5FitRg;Level5FitG;Level5FitP;Level5FitB;Level5FitETA;Level5FitPACK;Level5FitRgCO;Level5MassFractal;Level5LinkRgCO;Level5Corelations;"
	ListOfVariables+="FitSASBackground;UpdateAutomatically;DisplayLocalFits;ActiveTab;DisplayLocalFits;UseIndra2Data;UseRQSdata;SubtractBackground;UseSMRData;SlitLengthUnif;"
	ListOfVariables+="Level1LinkB;Level2LinkB;Level3LinkB;Level4LinkB;Level5LinkB;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if(enforce)
			testVar=0
		endif
	endfor

	ListOfVariables="Level1RgCO;Level2RgCO;Level3RgCO;Level4RgCO;Level5RgCO;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (enforce)
			testVar=0
		endif
	endfor
	//version 2.52 change, disable RgCO fitting 
	ListOfVariables="Level1FitRgCO;Level2FitRgCO;Level3FitRgCO;Level4FitRgCO;Level5FitRgCO;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		testVar=0
	endfor
	
	//and here values to 0.000001
	ListOfVariables="Level1RgLowLimit;Level1GLowLimit;Level1PLowLimit;Level1BLowLimit;Level1ETALowLimit;Level1RgCOLowLimit;"
	ListOfVariables+="Level2RgLowLimit;Level2GLowLimit;Level2PLowLimit;Level2BLowLimit;Level2ETALowLimit;Level2RgCOLowLimit;"
	ListOfVariables+="Level3RgLowLimit;Level3GLowLimit;Level3PLowLimit;Level3BLowLimit;Level3ETALowLimit;Level3RgCOLowLimit;"
	ListOfVariables+="Level4RgLowLimit;Level4GLowLimit;Level4PLowLimit;Level4BLowLimit;Level4ETALowLimit;Level4RgCOLowLimit;"
	ListOfVariables+="Level5RgLowLimit;Level5GLowLimit;Level5PLowLimit;Level5BLowLimit;Level5ETALowLimit;Level5RgCOLowLimit;"
	ListOfVariables+="SASBackground;SASBackgroundStep;"

	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=0.000001
		endif
	endfor
	
	//and here to 1 - force to 1
	ListOfVariables="ExtendedWarnings;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (enforce)
			testVar=1
		endif
	endfor
	
	//and here to 1
	ListOfVariables="Level1RgStep;Level1GStep;Level1PStep;Level1BStep;Level1EtaStep;Level1K;"
	ListOfVariables+="Level2RgStep;Level2GStep;Level2PStep;Level2BStep;Level2EtaStep;Level2K;"
	ListOfVariables+="Level3RgStep;Level3GStep;Level3PStep;Level3BStep;Level3EtaStep;Level3K;"
	ListOfVariables+="Level4RgStep;Level4GStep;Level4PStep;Level4BStep;Level4EtaStep;Level4K;"
	ListOfVariables+="Level5RgStep;Level5GStep;Level5PStep;Level5BStep;Level5EtaStep;Level5K;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=1
		endif
	endfor

	//and here to 0.1
	ListOfVariables="Level1PackStep;Level2PackStep;Level3PackStep;Level4PackStep;Level5PackStep;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=0.1
		endif
	endfor
		
	//here top limit, test 10 000	
	ListOfVariables="Level1RgHighLimit;Level1GHighLimit;Level1BHighLimit;Level1ETAHighLimit;Level1RgCOHighLimit;"
	ListOfVariables+="Level2RgHighLimit;Level2GHighLimit;Level2BHighLimit;Level2ETAHighLimit;Level2RgCOHighLimit;"
	ListOfVariables+="Level3RgHighLimit;Level3GHighLimit;Level3BHighLimit;Level3ETAHighLimit;Level3RgCOHighLimit;"
	ListOfVariables+="Level4RgHighLimit;Level4GHighLimit;Level4BHighLimit;Level4ETAHighLimit;Level4RgCOHighLimit;"
	ListOfVariables+="Level5RgHighLimit;Level5GHighLimit;Level5BHighLimit;Level5ETAHighLimit;Level5RgCOHighLimit;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=10000
		endif
	endfor
	//here  top limit
	ListOfVariables="Level1PHighLimit;Level2PHighLimit;Level3PHighLimit;Level4PHighLimit;Level5PHighLimit;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=4.2
		endif
	endfor
	
	//here Pack top limit, test 8	
	ListOfVariables="Level1PACKHighLimit;Level2PACKHighLimit;Level3PACKHighLimit;Level4PACKHighLimit;Level5PACKHighLimit;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=8
		endif
	endfor

	//here limit of 0	
	ListOfVariables="Level1PACKLowLimit;Level2PACKLowLimit;Level3PACKLowLimit;Level4PACKLowLimit;Level5PACKLowLimit;Level1RgCO;"

	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar!=0 || enforce)
			testVar=0
		endif
	endfor

	//here limit of 0.3	
	ListOfVariables="Level1PACK;Level2PACK;Level3PACK;Level4PACK;Level5PACK;"

	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=2.5
		endif
	endfor
	//here limit of 0.01	
	ListOfVariables="Level1B;Level2B;Level3B;Level4B;Level5B;"

	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=0.01
		endif
	endfor
	ListOfVariables="Level1P;Level2P;Level3P;Level4P;Level5P;"

	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=4
		endif
	endfor
	ListOfVariables="ConfEvTargetChiSqRange;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=1.05
		endif
	endfor
	
	
	//here another number as will be needed
	ListOfVariables="Level1Rg;Level1G;Level1ETA;"
	ListOfVariables+="Level2Rg;Level2G;Level2ETA;" //Level2RgCO;"
	ListOfVariables+="Level3Rg;Level3G;Level3ETA;"  //Level3RgCO;"
	ListOfVariables+="Level4Rg;Level4G;Level4ETA;" //Level4RgCO;"
	ListOfVariables+="Level5Rg;Level5G;Level5ETA;" //Level5RgCO;"

	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=100
		endif
	endfor
	IR1A_SetErrorsToZero()
	setDataFOlder OldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_SetErrorsToZero()

	string ListOfVariables="SASBackgroundError;"
	ListOfVariables+="Level1RgError;Level1GError;Level1PError;Level1BError;Level1ETAError;Level1PACKError;Level1RGCOError;"
	ListOfVariables+="Level2RgError;Level2GError;Level2PError;Level2BError;Level2ETAError;Level2PACKError;Level2RGCOError;"
	ListOfVariables+="Level3RgError;Level3GError;Level3PError;Level3BError;Level3ETAError;Level3PACKError;Level3RGCOError;"
	ListOfVariables+="Level4RgError;Level4GError;Level4PError;Level4BError;Level4ETAError;Level4PACKError;Level4RGCOError;"
	ListOfVariables+="Level5RgError;Level5GError;Level5PError;Level5BError;Level5ETAError;Level5PACKError;Level5RGCOError;"
	variable i
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		testVar=0
	endfor


end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_ControlPanelFnct() 
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(2.25,43.25,396,720)/N=IR1A_ControlPanel as "Unified fit"
	//DefaultGUIControls /W=IR1A_ControlPanel ///Mac os9
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("Irena_UnifFit","IR1A_ControlPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 1,1)

	SetVariable RebinDataTo,limits={0,1000,0},variable= root:Packages:Irena_UnifFit:RebinDataTo, noproc
	SetVariable RebinDataTo,pos={290,140},size={100,15},title="Rebin to:", help={"To rebin data on import, set to integer number. 0 means no rebinning. "}
	TitleBox MainTitle title="\Zr200Unified fit input panel",pos={20,0},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={350,24},anchor=MC,fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,181},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info1 title="\Zr150Data input",pos={10,30},frame=0,fstyle=1, fixedSize=1,size={80,20},fColor=(0,0,52224)
	TitleBox Info2 title="\Zr150Unified model input",pos={10,185},frame=0,fstyle=2, fixedSize=1,size={150,20}
	TitleBox Info3 title="\Zr120Fit?",pos={200,262},frame=0,fstyle=2, fixedSize=0,size={20,15}
	TitleBox Info4 title="Low limit:    High Limit:",pos={230,262},frame=0,fstyle=2, fixedSize=0,size={120,15}
	TitleBox Info5 title="\Zr130Fit using least square fitting ?",pos={2,583},frame=0,fstyle=2, fixedSize=0,size={140,15},fColor=(0,0,52224)
	TitleBox Info6 title="\Zr130Results",pos={2,624},frame=0,fstyle=2, fixedSize=0,size={40,15},fColor=(0,0,52224)
	//Experimental data input
	CheckBox UseSMRData,pos={170,40},size={141,14},proc=IR1A_InputPanelCheckboxProc,title="SMR data"
	CheckBox UseSMRData,variable= root:packages:Irena_UnifFit:UseSMRData, help={"Check, if you are using slit smeared data"}
	NVAR UseSMRData = root:packages:Irena_UnifFit:UseSMRData
	SetVariable SlitLength,limits={0,Inf,0},value= root:Packages:Irena_UnifFit:SlitLengthUnif, disable=!UseSMRData
	SetVariable SlitLength,pos={260,40},size={100,16},title="SL=",proc=IR1A_PanelSetVarProc, help={"slit length"}
	Button DrawGraphs,pos={5,158},size={100,20},proc=IR1A_InputPanelButtonProc,title="Graph data", help={"Create a graph (log-log) of your experiment data"}
	Button ScriptingTool,pos={280,160},size={100,15},proc=IR1A_InputPanelButtonProc,title="Scripting tool", help={"Script this tool for multiple data sets processing"}
	SetVariable SubtractBackground,limits={0,Inf,0.1},value= root:Packages:Irena_UnifFit:SubtractBackground
	SetVariable SubtractBackground,pos={110,162},size={150,16},title="Subtract backg.",proc=IR1A_PanelSetVarProc, help={"Subtract flat background from data"}

	Button GetHelp,pos={305,100},size={80,15},fColor=(65535,32768,32768), proc=IR1A_InputPanelButtonProc,title="Get Help", help={"Open www manual page for this tool"}
	Button GetWiki,pos={305,120},size={80,15},fColor=(65535,32768,32768), proc=IR1A_InputPanelButtonProc,title="Get wiki", help={"Open wikipedia page for this tool"}

	//Modeling input, common for all distributions
	PopupMenu NumberOfLevels,pos={200,190},size={170,21},proc=IR1A_PanelPopupControl,title="Number of levels :", help={"Select number of levels to use, NOTE that the level 1 has to have the smallest Rg"}
	PopupMenu NumberOfLevels,mode=2,popvalue="0",value= #"\"0;1;2;3;4;5;\""
	Button GraphDistribution,pos={5,215},size={90,20},proc=IR1A_InputPanelButtonProc,title="Graph Unified", help={"Add results of your model in the graph with data"}
	CheckBox UpdateAutomatically,pos={110,210},size={225,14},proc=IR1A_InputPanelCheckboxProc,title="Update automatically?"
	CheckBox UpdateAutomatically,variable= root:Packages:Irena_UnifFit:UpdateAutomatically, help={"When checked the graph updates automatically anytime you make change in model parameters"}
	CheckBox UseNoLimits,pos={275,210},size={63,14},proc=IR1A_InputPanelCheckboxProc,title="No limits?"
	CheckBox UseNoLimits,variable= root:Packages:Irena_UnifFit:UseNoLimits, help={"Check if you want to fit without use of limits"}
	CheckBox DisplayLocalFits,pos={110,225},size={225,14},proc=IR1A_InputPanelCheckboxProc,title="Display local (Porod & Guinier) fits?"
	CheckBox DisplayLocalFits,variable= root:Packages:Irena_UnifFit:DisplayLocalFits, help={"Check to display in graph local Porod and Guinier fits for selected level, fits change with changes in values of P, B, Rg and G"}
	Button LevelXFitRgAndG,pos={230,318},size={130,20}, proc=IR1A_InputPanelButtonProc,title="Fit Rg/G bwtn cursors", help={"Do local fit of Guinier dependence between the cursors amd put resulting values into the Rg and G fields"}
	Button LevelXFitPAndB,pos={230,408},size={130,20}, proc=IR1A_InputPanelButtonProc,title="Fit P/B bwtn cursors", help={"Do Power law fitting between the cursors and put resulting parameters in the P and B fields"}
	
	TitleBox PhysValidityWarning title="Level may not be physically feasible", pos={10,410},size={300,16}
	TitleBox PhysValidityWarning fstyle=1,fColor=(64000,1,1), disable=1, frame=5
	TitleBox PhysValidityWarning help={"Parameters may not be physically meaningful. Typically B or Rg/G are wrong."}

	CheckBox ExportLocalFits,pos={190,606},size={225,14},proc=IR1A_InputPanelCheckboxProc,title="Store local (Porod & Guinier) fits?"
	CheckBox ExportLocalFits,variable= root:Packages:Irena_UnifFit:ExportLocalFits, help={"Check to store local Porod and Guinier fits for all existing levels together with full Unified fit"}
	Button DoFitting,pos={175,584},size={70,20},proc=IR1A_InputPanelButtonProc,title="Fit", help={"Do least sqaures fitting of the whole model, find good starting conditions and proper limits before fitting"}
	Button RevertFitting,pos={255,584},size={100,20},proc=IR1A_InputPanelButtonProc,title="Revert back",help={"Return back befoire last fitting attempt"}
	Button ResetUnified,pos={3,605},size={80,15},proc=IR1A_InputPanelButtonProc,title="reset unif?", help={"Reset variables to default values?"}
	Button FixLimits,pos={93,605},size={80,15},proc=IR1A_InputPanelButtonProc,title="Fix limits?", help={"Reset variables to default values?"}
	Button CopyToFolder,pos={55,623},size={120,20},proc=IR1A_InputPanelButtonProc,title="Store in Data Folder", help={"Copy results of the modeling into original data folder"}
	Button ExportData,pos={180,623},size={90,20},proc=IR1A_InputPanelButtonProc,title="Export ASCII", help={"Export ASCII data out of Igor"}
	Button MarkGraphs,pos={277,623},size={110,20},proc=IR1A_InputPanelButtonProc,title="Results to graphs", help={"Insert text boxes with results into the graphs for printing"}
	Button EvaluateSpecialCases,pos={10,645},size={120,20},proc=IR1A_InputPanelButtonProc,title="Analyze Results", help={"Analyze special Cases"}
	Button ConfidenceEvaluation,pos={150,645},size={120,20},proc=IR1A_InputPanelButtonProc,title="Anal. Uncertainity", help={"Analyze confidence range for different parameters"}

	CheckBox ExtendedWarnings,pos={285,650},size={80,16},noproc,title="Ext. warnings?"
	CheckBox ExtendedWarnings,variable= root:Packages:Irena_UnifFit:ExtendedWarnings, help={"Print extended warnings in the history area?"}

	NVAR SASBackground = root:Packages:Irena_UnifFit:SASBackground
	SetVariable SASBackground,pos={15,565},size={160,16},proc=IR1A_PanelSetVarProc,title="SAS Background", help={"SAS background"},bodyWidth=80, format="%0.4g"
	SetVariable SASBackground,limits={-inf,Inf,0.05*SASBackground},value= root:Packages:Irena_UnifFit:SASBackground
	CheckBox FitBackground,pos={195,566},size={63,14},proc=IR1A_InputPanelCheckboxProc,title="Fit Bckg?"
	CheckBox FitBackground,variable= root:Packages:Irena_UnifFit:FitSASBackground, help={"Check if you want the background to be fitting parameter"}
	CheckBox SkipFitControlDialog,pos={270,566},size={63,14},proc=IR1A_InputPanelCheckboxProc,title="Skip Fit Check?"
	CheckBox SkipFitControlDialog,variable= root:Packages:Irena_UnifFit:SkipFitControlDialog, help={"Check if you want to skip the check parameters dialo for fitting"}

	//Dist Tabs definition
	TabControl DistTabs,pos={5,240},size={370,320},proc=IR1A_TabPanelControl
	TabControl DistTabs,tabLabel(0)="1. Level ",tabLabel(1)="2. Level "
	TabControl DistTabs,tabLabel(2)="3. Level ",tabLabel(3)="4. Level "
	TabControl DistTabs,tabLabel(4)="5. Level ",value= 0 //, fsize="Zr100"


	Button CopyMoveLevel,pos={200,540},size={150,15}, proc=IR1A_InputPanelButtonProc,title="Copy/Move/swap level", help={"Copy/move/swap current values to different level"}
	
	NVAR Level1G = root:Packages:Irena_UnifFit:Level1G
	NVAR Level1B = root:Packages:Irena_UnifFit:Level1B
	NVAR Level1P = root:Packages:Irena_UnifFit:Level1P
	NVAR Level1Rg = root:Packages:Irena_UnifFit:Level1Rg
	NVAR Level1Eta=root:Packages:Irena_UnifFit:Level1Eta
	NVAR Level1Pack=root:Packages:Irena_UnifFit:Level1Pack
	
	TitleBox Level1Title, title="   Level  1 controls    ", frame=1, labelBack=(64000,0,0), pos={14,258}, size={150,8}
	SetVariable Level1G,pos={14,280},size={180,16},proc=IR1A_PanelSetVarProc,title="G   ",bodyWidth=140, format="%0.4g"
	SetVariable Level1G,limits={0,inf,0.05*Level1G},value= root:Packages:Irena_UnifFit:Level1G, help={"Guinier prefactor"}
	CheckBox Level1FitG,pos={200,281},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level1FitG,variable= root:Packages:Irena_UnifFit:Level1FitG, help={"Fit G?, find god starting conditions and select fitting limits..."}
	SetVariable Level1GLowLimit,pos={230,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level1GLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1GLowLimit, help={"Low limit for G fitting"}
	SetVariable Level1GHighLimit,pos={300,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level1GHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1GHighLimit, help={"High limit for G fitting"}

	SetVariable Level1Rg,pos={14,300},size={180,16},proc=IR1A_PanelSetVarProc,title="Rg   ", help={"Radius of gyration, e.g., sqrt(5/3)*R for sphere etc..."}
	SetVariable Level1Rg,limits={0,inf,0.05*Level1Rg},variable= root:Packages:Irena_UnifFit:Level1Rg,bodyWidth=140, format="%0.4g"
	CheckBox Level1FitRg,pos={200,301},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level1FitRg,variable= root:Packages:Irena_UnifFit:Level1FitRg, help={"Fit Rg? Select properly starting conditions and limits"}
	SetVariable Level1RgLowLimit,pos={230,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level1RgLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1RgLowLimit, help={"Low limit for Rg fitting..."}
	SetVariable Level1RgHighLimit,pos={300,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level1RgHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1RgHighLimit, help={"High limit for Rg fitting"}

	CheckBox Level1MassFractal,pos={20,330},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this mass fractal from lower level?"
	CheckBox Level1MassFractal,variable= root:Packages:Irena_UnifFit:Level1MassFractal, help={"Is this mass fractal composed of particles from lower level?"}
	CheckBox Level1LinkB,pos={20,350},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link B to G/Rg/P?"
	CheckBox Level1LinkB,variable= root:Packages:Irena_UnifFit:Level1LinkB, help={"If the B should be calculated based on Guinier/Porods law?"}
	SetVariable Level1SurfToVolRat,pos={230,350},size={130,16},proc=IR1A_PanelSetVarProc,title="pi B/Q [m2/cm3]", help={"S/(V*fi(1-fi)) - Surface to volume ratio if P=4 (Porod law) in m2/cm3 if input Q in is A^-1"}
	SetVariable Level1SurfToVolRat,limits={inf,inf,0},value= root:Packages:Irena_UnifFit:Level1SurfaceToVolRat

	SetVariable Level1B,pos={14,370},size={180,16},proc=IR1A_PanelSetVarProc,title="B   ", help={"Power law prefactor"}
	SetVariable Level1B,limits={0,inf,0.05*Level1B},value= root:Packages:Irena_UnifFit:Level1B,bodyWidth=140, format="%0.4g"
	CheckBox Level1FitB,pos={200,371},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level1FitB,variable= root:Packages:Irena_UnifFit:Level1FitB, help={"Fit the Power law prefactor?, select properly the starting conditions and limits before fitting"}
	SetVariable Level1BLowLimit,pos={230,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level1BLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1BLowLimit, help={"Power law prefactor low limit"}
	SetVariable Level1BHighLimit,pos={300,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level1BHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1BHighLimit, help={"Power law prefactor high limit"}

	SetVariable Level1P,pos={14,390},size={180,16},proc=IR1A_PanelSetVarProc,title="P   ", help={"Power law slope, e.g., -4 for Porod tails"}
	SetVariable Level1P,limits={0,6,0.05*Level1P},value= root:Packages:Irena_UnifFit:Level1P,bodyWidth=140, format="%0.4g"
	CheckBox Level1FitP,pos={200,391},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level1FitP,variable= root:Packages:Irena_UnifFit:Level1FitP, help={"Fit the Power law slope, select good starting conditions and appropriate limits"}
	SetVariable Level1PLowLimit,pos={230,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level1PLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1PLowLimit, help={"Power law low limit for slope"}
	SetVariable Level1PHighLimit,pos={300,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level1PHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1PHighLimit, help={"Power law high limit for slope"}

	SetVariable Level1DegreeOfAggreg,pos={14,370},size={140,16},proc=IR1A_PanelSetVarProc,title="Deg. of Aggreg ", help={"Degree of aggregation for mass fractals. = Rg/Rg(level-1) "}
	SetVariable Level1DegreeOfAggreg,limits={-inf,inf,0},value= root:Packages:Irena_UnifFit:Level1DegreeOfAggreg

	SetVariable Level1RgCO,pos={14,430},size={180,16},proc=IR1A_PanelSetVarProc,title="RgCutoff  ",bodyWidth=100
	SetVariable Level1RgCO,limits={0,inf,1},value= root:Packages:Irena_UnifFit:Level1RgCO, help={"Size, where the power law dependence ends, 0 or sometimes Rg of lower level, for level 1 it is 0"}
//	CheckBox Level1FitRGCO,pos={200,431},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
//	CheckBox Level1FitRGCO,variable= root:Packages:Irena_UnifFit:Level1FitRgCo, help={"Fit the RgCutoff ? Select properly starting point and limits."}
//	SetVariable Level1RgCOLowLimit,pos={230,430},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
//	SetVariable Level1RgCOLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1RgCoLowLimit, help={"RgCutOff low limit"}
//	SetVariable Level1RgCOHighLimit,pos={300,430},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
//	SetVariable Level1RgCOHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1RgCOHighLimit, help={"RgCutOff high limit"}

	Button Level1SetRGCODefault,pos={20,450},size={100,20}, proc=IR1A_InputPanelButtonProc,title="Rg(level-1)->RGCO", help={"This button sets the RgCutOff to value of Rg from previous level (or 0 for level 1)"}
	CheckBox Level1LinkRGCO,pos={140,452},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link RGCO"
	CheckBox Level1LinkRGCO,variable= root:Packages:Irena_UnifFit:Level1LinkRgCo, help={"Link the RgCO to lower level and fit at the same time?"}

	PopupMenu Level1KFactor,pos={230,435},size={170,21},proc=IR1A_PanelPopupControl,title="k factor :"
	PopupMenu Level1KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}
	TitleBox Info20 title="\Zr100=1 usually",pos={325,438},frame=0,fstyle=2, fixedSize=0,size={40,15},fColor=(0,0,52224)
	TitleBox Info21 title="\Zr100k=1.06 for Mass Fractals",pos={250,456},frame=0,fstyle=2, fixedSize=0,size={40,15},fColor=(0,0,52224)

	CheckBox Level1Corelations,pos={90,480},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this correlated system? "
	CheckBox Level1Corelations,variable= root:Packages:Irena_UnifFit:Level1Corelations, help={"Is there a peak or do you expect Corelations between particles to have importance"}

	SetVariable Level1ETA,pos={14,500},size={180,16},proc=IR1A_PanelSetVarProc,title="ETA    ",bodyWidth=140, format="%0.4g"
	SetVariable Level1ETA,limits={0,inf,0.01*Level1Eta},value= root:Packages:Irena_UnifFit:Level1ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Guinier for multiple order Corelations"}
	CheckBox Level1FitETA,pos={200,500},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level1FitETA,variable= root:Packages:Irena_UnifFit:Level1FitETA, help={"Fit correaltion distance? Slect properly the starting conditions and limits."}
	SetVariable Level1ETALowLimit,pos={230,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level1ETALowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1ETALowLimit, help={"Correlation distance low limit"}
	SetVariable Level1ETAHighLimit,pos={300,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level1ETAHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1ETAHighLimit, help={"Correlation distance high limit"}

	SetVariable Level1PACK,pos={14,520},size={180,16},proc=IR1A_PanelSetVarProc,title="Pack    ",bodyWidth=140, format="%0.4g"
	SetVariable Level1PACK,limits={0,8,0.05*Level1Pack},value= root:Packages:Irena_UnifFit:Level1PACK, help={"Packing factor for domains. For dilute objects 0, for FCC packed spheres 8*0.592"}
	CheckBox Level1FitPACK,pos={200,520},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level1FitPACK,variable= root:Packages:Irena_UnifFit:Level1FitPACK, help={"Fit packing factor? Select properly starting condions and limits"}
	SetVariable Level1PACKLowLimit,pos={230,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level1PACKLowLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level1PACKLowLimit, help={"Low limit for packing factor"}
	SetVariable Level1PACKHighLimit,pos={300,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level1PACKHighLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level1PACKHighLimit, help={"High limit for packing factor"}

	//end of Level 1 controls....
//
//
	//Level2 controls

	NVAR Level2G = root:Packages:Irena_UnifFit:Level2G
	NVAR Level2B = root:Packages:Irena_UnifFit:Level2B
	NVAR Level2P = root:Packages:Irena_UnifFit:Level2P
	NVAR Level2Rg = root:Packages:Irena_UnifFit:Level2Rg
	NVAR Level2Eta=root:Packages:Irena_UnifFit:Level2Eta
	NVAR Level2Pack=root:Packages:Irena_UnifFit:Level2Pack
	
	TitleBox Level2Title, title="   Level  2 controls    ", frame=1, labelBack=(0,64000,0), pos={14,258}, size={150,8}

	SetVariable Level2G,pos={14,280},size={180,16},proc=IR1A_PanelSetVarProc,title="G   ",bodyWidth=140, format="%0.4g"
	SetVariable Level2G,limits={0,inf,0.05*Level2G},value= root:Packages:Irena_UnifFit:Level2G, help={"Guinier prefactor"}
	CheckBox Level2FitG,pos={200,281},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level2FitG,variable= root:Packages:Irena_UnifFit:Level2FitG, help={"Fit G?, find god starting conditions and select fitting limits..."}
	SetVariable Level2GLowLimit,pos={230,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level2GLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2GLowLimit, help={"Low limit for G fitting"}
	SetVariable Level2GHighLimit,pos={300,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level2GHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2GHighLimit, help={"High limit for G fitting"}

	SetVariable Level2Rg,pos={14,300},size={180,16},proc=IR1A_PanelSetVarProc,title="Rg  ", help={"Radius of gyration, e.g., sqrt(5/3)*R for sphere etc..."}
	SetVariable Level2Rg,limits={0,inf,0.05*Level2Rg},value= root:Packages:Irena_UnifFit:Level2Rg,bodyWidth=140, format="%0.4g"
	CheckBox Level2FitRg,pos={200,301},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level2FitRg,variable= root:Packages:Irena_UnifFit:Level2FitRg, help={"Fit Rg? Select properly starting conditions and limits"}
	SetVariable Level2RgLowLimit,pos={230,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level2RgLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2RgLowLimit, help={"Low limit for Rg fitting..."}
	SetVariable Level2RgHighLimit,pos={300,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level2RgHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2RgHighLimit, help={"High limit for Rg fitting"}

	//Button Level2FitRgAndG,pos={230,318},size={130,20}, proc=IR1A_InputPanelButtonProc,title="Fit Rg/G bwtn cursors", help={"Do locol fit of Guinier dependence between the cursors amd put resulting values into the Rg and G fields"}

	CheckBox Level2MassFractal,pos={20,330},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this mass fractal from lower level?"
	CheckBox Level2MassFractal,variable= root:Packages:Irena_UnifFit:Level2MassFractal, help={"Is this mass fractal composed of particles from lower level?"}
	CheckBox Level2LinkB,pos={20,350},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link B to G/Rg/P?"
	CheckBox Level2LinkB,variable= root:Packages:Irena_UnifFit:Level2LinkB, help={"If the B should be calculated based on Guinier/Porods law?"}
	SetVariable Level2SurfToVolRat,pos={230,350},size={130,16},proc=IR1A_PanelSetVarProc,title="Surf / Vol", help={"Surface to volume ratio if P=4 (Porod law) in m2/cm3 if input Q in is A"}
	SetVariable Level2SurfToVolRat,limits={inf,inf,0},value= root:Packages:Irena_UnifFit:Level2SurfaceToVolRat

	SetVariable Level2B,pos={14,370},size={180,16},proc=IR1A_PanelSetVarProc,title="B   ", help={"Power law prefactor"}
	SetVariable Level2B,limits={0,inf,0.05*Level2B},value= root:Packages:Irena_UnifFit:Level2B,bodyWidth=140, format="%0.4g"
	CheckBox Level2FitB,pos={200,371},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level2FitB,variable= root:Packages:Irena_UnifFit:Level2FitB, help={"Fit the Power law prefactor?, select properly the starting conditions and limits before fitting"}
	SetVariable Level2BLowLimit,pos={230,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level2BLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2BLowLimit, help={"Power law prefactor low limit"}
	SetVariable Level2BHighLimit,pos={300,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level2BHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2BHighLimit, help={"Power law prefactor high limit"}

	SetVariable Level2DegreeOfAggreg,pos={14,370},size={140,16},proc=IR1A_PanelSetVarProc,title="Deg. of Aggreg ", help={"Degree of aggregation for mass fractals. = Rg/Rg(level-1) "}
	SetVariable Level2DegreeOfAggreg,limits={-inf,inf,0},value= root:Packages:Irena_UnifFit:Level2DegreeOfAggreg

	SetVariable Level2P,pos={14,390},size={180,16},proc=IR1A_PanelSetVarProc,title="P   ", help={"Power law slope, e.g., -4 for Porod tails"}
	SetVariable Level2P,limits={0,6,0.05*Level2P},value= root:Packages:Irena_UnifFit:Level2P,bodyWidth=140, format="%0.4g"
	CheckBox Level2FitP,pos={200,390},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level2FitP,variable= root:Packages:Irena_UnifFit:Level2FitP, help={"Fit the Power law slope, select good starting conditions and appropriate limits"}
	SetVariable Level2PLowLimit,pos={230,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level2PLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2PLowLimit, help={"Power law low limit for slope"}
	SetVariable Level2PHighLimit,pos={300,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level2PHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2PHighLimit, help={"Power law high limit for slope"}
//	Button Level2FitPAndB,pos={230,408},size={130,20}, proc=IR1A_InputPanelButtonProc,title="Fit P/B bwtn cursors", help={"Do Power law fitting between the cursors and put resulting parameters in the P and B fields"}


	SetVariable Level2RGCO,pos={14,430},size={180,16},proc=IR1A_PanelSetVarProc,title="RgCutoff  ",bodyWidth=100
	SetVariable Level2RGCO,limits={0,inf,1},value= root:Packages:Irena_UnifFit:Level2RgCO, help={"Size, where the power law dependence ends, usually Rg of lower level, for level 1 it is 0"}
//	CheckBox Level2FitRGCO,pos={200,431},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
//	CheckBox Level2FitRGCO,variable= root:Packages:Irena_UnifFit:Level2FitRgCo, help={"Fit the RgCutoff ? Select properly starting point and limits."}
//	SetVariable Level2RGCOLowLimit,pos={230,430},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
//	SetVariable Level2RGCOLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2RgCoLowLimit, help={"RgCutOff low limit"}
//	SetVariable Level2RGCOHighLimit,pos={300,430},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
//	SetVariable Level2RGCOHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2RgCOHighLimit, help={"RgCutOff high limit"}

	Button Level2SetRGCODefault,pos={20,450},size={100,20}, proc=IR1A_InputPanelButtonProc,title="Rg(level-1)->RGCO", help={"This button sets the RgCutOff to value of Rg from previous level (or 0 for level 1)"}
	CheckBox Level2LinkRGCO,pos={140,452},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link RGCO"
	CheckBox Level2LinkRGCO,variable= root:Packages:Irena_UnifFit:Level2LinkRgCo, help={"Link the RgCO to lower level and fit at the same time?"}

	PopupMenu Level2KFactor,pos={230,435},size={170,21},proc=IR1A_PanelPopupControl,title="k factor :"
	PopupMenu Level2KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}

	CheckBox Level2Corelations,pos={90,480},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this correlated system? "
	CheckBox Level2Corelations,variable= root:Packages:Irena_UnifFit:Level2Corelations, help={"Is there a peak or do you expect Corelations between particles to have importance"}

	SetVariable Level2ETA,pos={14,500},size={180,16},proc=IR1A_PanelSetVarProc,title="ETA    ",bodyWidth=140, format="%0.4g"
	SetVariable Level2ETA,limits={0,inf,0.01*Level2Eta},value= root:Packages:Irena_UnifFit:Level2ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Guinier for multiple order Corelations"}
	CheckBox Level2FitETA,pos={200,500},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level2FitETA,variable= root:Packages:Irena_UnifFit:Level2FitETA, help={"Fit correaltion distance? Slect properly the starting conditions and limits."}
	SetVariable Level2ETALowLimit,pos={230,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level2ETALowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2ETALowLimit, help={"Correlation distance low limit"}
	SetVariable Level2ETAHighLimit,pos={300,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level2ETAHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2ETAHighLimit, help={"Correlation distance high limit"}

	SetVariable Level2PACK,pos={14,520},size={180,16},proc=IR1A_PanelSetVarProc,title="Pack    ",bodyWidth=140, format="%0.4g"
	SetVariable Level2PACK,limits={0,8,0.05*Level2Pack},value= root:Packages:Irena_UnifFit:Level2PACK, help={"Packing factor for domains. For dilute objects 0, for FCC packed spheres 8*0.592"}
	CheckBox Level2FitPACK,pos={200,520},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level2FitPACK,variable= root:Packages:Irena_UnifFit:Level2FitPACK, help={"Fit packing factor? Select properly starting condions and limits"}
	SetVariable Level2PACKLowLimit,pos={230,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level2PACKLowLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level2PACKLowLimit, help={"Low limit for packing factor"}
	SetVariable Level2PACKHighLimit,pos={300,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level2PACKHighLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level2PACKHighLimit, help={"High limit for packing factor"}
//////End of Level2 	
////	
	//Level3 controls
	NVAR Level3G = root:Packages:Irena_UnifFit:Level3G
	NVAR Level3B = root:Packages:Irena_UnifFit:Level3B
	NVAR Level3P = root:Packages:Irena_UnifFit:Level3P
	NVAR Level3Rg = root:Packages:Irena_UnifFit:Level3Rg
	NVAR Level3Eta=root:Packages:Irena_UnifFit:Level3Eta
	NVAR Level3Pack=root:Packages:Irena_UnifFit:Level3Pack
	TitleBox Level3Title, title="   Level  3 controls    ", frame=1, labelBack=(30000,30000,64000), pos={14,258}, size={150,8}

	SetVariable Level3G,pos={14,280},size={180,16},proc=IR1A_PanelSetVarProc,title="G   ",bodyWidth=140, format="%0.4g"
	SetVariable Level3G,limits={0,inf,0.05*Level3G},value= root:Packages:Irena_UnifFit:Level3G, help={"Guinier prefactor"}
	CheckBox Level3FitG,pos={200,281},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level3FitG,variable= root:Packages:Irena_UnifFit:Level3FitG, help={"Fit G?, find god starting conditions and select fitting limits..."}
	SetVariable Level3GLowLimit,pos={230,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level3GLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3GLowLimit, help={"Low limit for G fitting"}
	SetVariable Level3GHighLimit,pos={300,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level3GHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3GHighLimit, help={"High limit for G fitting"}

	SetVariable Level3Rg,pos={14,300},size={180,16},proc=IR1A_PanelSetVarProc,title="Rg   ", help={"Radius of gyration, e.g., sqrt(5/3)*R for sphere etc..."}
	SetVariable Level3Rg,limits={0,inf,0.05*Level3Rg},value= root:Packages:Irena_UnifFit:Level3Rg,bodyWidth=140, format="%0.4g"
	CheckBox Level3FitRg,pos={200,301},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level3FitRg,variable= root:Packages:Irena_UnifFit:Level3FitRg, help={"Fit Rg? Select properly starting conditions and limits"}
	SetVariable Level3RgLowLimit,pos={230,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level3RgLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3RgLowLimit, help={"Low limit for Rg fitting..."}
	SetVariable Level3RgHighLimit,pos={300,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level3RgHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3RgHighLimit, help={"High limit for Rg fitting"}

	//Button Level3FitRgAndG,pos={230,318},size={130,20}, proc=IR1A_InputPanelButtonProc,title="Fit Rg/G bwtn cursors", help={"Do locol fit of Guinier dependence between the cursors amd put resulting values into the Rg and G fields"}

	CheckBox Level3MassFractal,pos={20,330},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this mass fractal from lower level?"
	CheckBox Level3MassFractal,variable= root:Packages:Irena_UnifFit:Level3MassFractal, help={"Is this mass fractal composed of particles from lower level?"}
	CheckBox Level3LinkB,pos={20,350},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link B to G/Rg/P?"
	CheckBox Level3LinkB,variable= root:Packages:Irena_UnifFit:Level3LinkB, help={"If the B should be calculated based on Guinier/Porods law?"}
	SetVariable Level3SurfToVolRat,pos={230,350},size={130,16},proc=IR1A_PanelSetVarProc,title="Surf / Vol", help={"Surface to volume ratio if P=4 (Porod law) in m2/cm3 if input Q in is A"}
	SetVariable Level3SurfToVolRat,limits={inf,inf,0},value= root:Packages:Irena_UnifFit:Level3SurfaceToVolRat

	SetVariable Level3B,pos={14,370},size={180,16},proc=IR1A_PanelSetVarProc,title="B   ", help={"Power law prefactor"}
	SetVariable Level3B,limits={0,inf,0.05*Level3B},value= root:Packages:Irena_UnifFit:Level3B,bodyWidth=140, format="%0.4g"
	CheckBox Level3FitB,pos={200,371},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level3FitB,variable= root:Packages:Irena_UnifFit:Level3FitB, help={"Fit the Power law prefactor?, select properly the starting conditions and limits before fitting"}
	SetVariable Level3BLowLimit,pos={230,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level3BLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3BLowLimit, help={"Power law prefactor low limit"}
	SetVariable Level3BHighLimit,pos={300,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level3BHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3BHighLimit, help={"Power law prefactor high limit"}

	SetVariable Level3DegreeOfAggreg,pos={14,370},size={140,16},proc=IR1A_PanelSetVarProc,title="Deg. of Aggreg ", help={"Degree of aggregation for mass fractals. = Rg/Rg(level-1) "}
	SetVariable Level3DegreeOfAggreg,limits={-inf,inf,0},value= root:Packages:Irena_UnifFit:Level3DegreeOfAggreg

	SetVariable Level3P,pos={14,390},size={180,16},proc=IR1A_PanelSetVarProc,title="P   ", help={"Power law slope, e.g., -4 for Porod tails"}
	SetVariable Level3P,limits={0,6,0.05*Level3P},value= root:Packages:Irena_UnifFit:Level3P,bodyWidth=140, format="%0.4g"
	CheckBox Level3FitP,pos={200,391},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level3FitP,variable= root:Packages:Irena_UnifFit:Level3FitP, help={"Fit the Power law slope, select good starting conditions and appropriate limits"}
	SetVariable Level3PLowLimit,pos={230,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level3PLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3PLowLimit, help={"Power law low limit for slope"}
	SetVariable Level3PHighLimit,pos={300,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level3PHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3PHighLimit, help={"Power law high limit for slope"}

	//Button Level3FitPAndB,pos={230,408},size={130,20}, proc=IR1A_InputPanelButtonProc,title="Fit P/B bwtn cursors", help={"Do Power law fitting between the cursors and put resulting parameters in the P and B fields"}


	SetVariable Level3RGCO,pos={14,430},size={180,16},proc=IR1A_PanelSetVarProc,title="RgCutoff  ",bodyWidth=100
	SetVariable Level3RGCO,limits={0,inf,1},value= root:Packages:Irena_UnifFit:Level3RgCO, help={"Size, where the power law dependence ends, usually Rg of lower level, for level 1 it is 0"}

	Button Level3SetRGCODefault,pos={20,450},size={100,20}, proc=IR1A_InputPanelButtonProc,title="Rg(level-1)->RGCO", help={"This button sets the RgCutOff to value of Rg from previous level (or 0 for level 1)"}
	CheckBox Level3LinkRGCO,pos={140,452},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link RGCO"
	CheckBox Level3LinkRGCO,variable= root:Packages:Irena_UnifFit:Level3LinkRgCo, help={"Link the RgCO to lower level and fit at the same time?"}

	PopupMenu Level3KFactor,pos={230,435},size={170,21},proc=IR1A_PanelPopupControl,title="k factor :"
	PopupMenu Level3KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}

	CheckBox Level3Corelations,pos={90,480},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this correlated system? "
	CheckBox Level3Corelations,variable= root:Packages:Irena_UnifFit:Level3Corelations, help={"Is there a peak or do you expect Corelations between particles to have importance"}

	SetVariable Level3ETA,pos={14,500},size={180,16},proc=IR1A_PanelSetVarProc,title="ETA    ",bodyWidth=140, format="%0.4g"
	SetVariable Level3ETA,limits={0,inf,0.01*Level3Eta},value= root:Packages:Irena_UnifFit:Level3ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Guinier for multiple order Corelations"}
	CheckBox Level3FitETA,pos={200,500},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level3FitETA,variable= root:Packages:Irena_UnifFit:Level3FitETA, help={"Fit correaltion distance? Slect properly the starting conditions and limits."}
	SetVariable Level3ETALowLimit,pos={230,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level3ETALowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3ETALowLimit, help={"Correlation distance low limit"}
	SetVariable Level3ETAHighLimit,pos={300,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level3ETAHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3ETAHighLimit, help={"Correlation distance high limit"}

	SetVariable Level3PACK,pos={14,520},size={180,16},proc=IR1A_PanelSetVarProc,title="Pack    ",bodyWidth=140, format="%0.4g"
	SetVariable Level3PACK,limits={0,8,0.05*Level3Pack},value= root:Packages:Irena_UnifFit:Level3PACK, help={"Packing factor for domains. For dilute objects 0, for FCC packed spheres 8*0.592"}
	CheckBox Level3FitPACK,pos={200,520},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level3FitPACK,variable= root:Packages:Irena_UnifFit:Level3FitPACK, help={"Fit packing factor? Select properly starting condions and limits"}
	SetVariable Level3PACKLowLimit,pos={230,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level3PACKLowLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level3PACKLowLimit, help={"Low limit for packing factor"}
	SetVariable Level3PACKHighLimit,pos={300,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level3PACKHighLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level3PACKHighLimit, help={"High limit for packing factor"}
////Level 3
////
	//Level4 controls
	NVAR Level4G = root:Packages:Irena_UnifFit:Level4G
	NVAR Level4B = root:Packages:Irena_UnifFit:Level4B
	NVAR Level4P = root:Packages:Irena_UnifFit:Level4P
	NVAR Level4Rg = root:Packages:Irena_UnifFit:Level4Rg
	NVAR Level4Eta=root:Packages:Irena_UnifFit:Level4Eta
	NVAR Level4Pack=root:Packages:Irena_UnifFit:Level4Pack
	TitleBox Level4Title, title="   Level  4 controls    ", frame=1, labelBack=(52000,52000,0), pos={14,258}, size={150,8}

	SetVariable Level4G,pos={14,280},size={180,16},proc=IR1A_PanelSetVarProc,title="G   ",bodyWidth=140, format="%0.4g"
	SetVariable Level4G,limits={0,inf,0.05*Level4G},value= root:Packages:Irena_UnifFit:Level4G, help={"Guinier prefactor"}
	CheckBox Level4FitG,pos={200,281},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level4FitG,variable= root:Packages:Irena_UnifFit:Level4FitG, help={"Fit G?, find god starting conditions and select fitting limits..."}
	SetVariable Level4GLowLimit,pos={230,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level4GLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4GLowLimit, help={"Low limit for G fitting"}
	SetVariable Level4GHighLimit,pos={300,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level4GHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4GHighLimit, help={"High limit for G fitting"}

	SetVariable Level4Rg,pos={14,300},size={180,16},proc=IR1A_PanelSetVarProc,title="Rg   ", help={"Radius of gyration, e.g., sqrt(5/3)*R for sphere etc..."}
	SetVariable Level4Rg,limits={0,inf,0.05*Level4Rg},value= root:Packages:Irena_UnifFit:Level4Rg,bodyWidth=140, format="%0.4g"
	CheckBox Level4FitRg,pos={200,301},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level4FitRg,variable= root:Packages:Irena_UnifFit:Level4FitRg, help={"Fit Rg? Select properly starting conditions and limits"}
	SetVariable Level4RgLowLimit,pos={230,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level4RgLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4RgLowLimit, help={"Low limit for Rg fitting..."}
	SetVariable Level4RgHighLimit,pos={300,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level4RgHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4RgHighLimit, help={"High limit for Rg fitting"}

	//Button Level4FitRgAndG,pos={230,318},size={130,20}, proc=IR1A_InputPanelButtonProc,title="Fit Rg/G bwtn cursors", help={"Do local fit of Guinier dependence between the cursors amd put resulting values into the Rg and G fields"}

	CheckBox Level4MassFractal,pos={20,330},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this mass fractal from lower level?"
	CheckBox Level4MassFractal,variable= root:Packages:Irena_UnifFit:Level4MassFractal, help={"Is this mass fractal composed of particles from lower level?"}
	CheckBox Level4LinkB,pos={20,350},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link B to G/Rg/P?"
	CheckBox Level4LinkB,variable= root:Packages:Irena_UnifFit:Level4LinkB, help={"If the B should be calculated based on Guinier/Porods law?"}
	SetVariable Level4SurfToVolRat,pos={230,350},size={130,16},proc=IR1A_PanelSetVarProc,title="Surf / Vol", help={"Surface to volume ratio if P=4 (Porod law) in m2/cm3 if input Q in is A"}
	SetVariable Level4SurfToVolRat,limits={inf,inf,0},value= root:Packages:Irena_UnifFit:Level4SurfaceToVolRat

	SetVariable Level4B,pos={14,370},size={180,16},proc=IR1A_PanelSetVarProc,title="B   ", help={"Power law prefactor"},bodyWidth=140, format="%0.4g"
	SetVariable Level4B,limits={0,inf,0.05*Level4B},value= root:Packages:Irena_UnifFit:Level4B
	CheckBox Level4FitB,pos={200,371},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level4FitB,variable= root:Packages:Irena_UnifFit:Level4FitB, help={"Fit the Power law prefactor?, select properly the starting conditions and limits before fitting"}
	SetVariable Level4BLowLimit,pos={230,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level4BLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4BLowLimit, help={"Power law prefactor low limit"}
	SetVariable Level4BHighLimit,pos={300,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level4BHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4BHighLimit, help={"Power law prefactor high limit"}

	SetVariable Level4DegreeOfAggreg,pos={14,370},size={140,16},proc=IR1A_PanelSetVarProc,title="Deg. of Aggreg ", help={"Degree of aggregation for mass fractals. = Rg/Rg(level-1) "}
	SetVariable Level4DegreeOfAggreg,limits={-inf,inf,0},value= root:Packages:Irena_UnifFit:Level4DegreeOfAggreg

	SetVariable Level4P,pos={14,390},size={180,16},proc=IR1A_PanelSetVarProc,title="P   ", help={"Power law slope, e.g., -4 for Porod tails"}
	SetVariable Level4P,limits={0,6,0.05*Level4P},value= root:Packages:Irena_UnifFit:Level4P,bodyWidth=140, format="%0.4g"
	CheckBox Level4FitP,pos={200,391},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level4FitP,variable= root:Packages:Irena_UnifFit:Level4FitP, help={"Fit the Power law slope, select good starting conditions and appropriate limits"}
	SetVariable Level4PLowLimit,pos={230,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level4PLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4PLowLimit, help={"Power law low limit for slope"}
	SetVariable Level4PHighLimit,pos={300,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level4PHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4PHighLimit, help={"Power law high limit for slope"}

	//Button Level4FitPAndB,pos={230,408},size={130,20}, proc=IR1A_InputPanelButtonProc,title="Fit P/B bwtn cursors", help={"Do Power law fitting between the cursors and put resulting parameters in the P and B fields"}


	SetVariable Level4RGCO,pos={14,430},size={180,16},proc=IR1A_PanelSetVarProc,title="RgCutoff  ",bodyWidth=100
	SetVariable Level4RGCO,limits={0,inf,1},value= root:Packages:Irena_UnifFit:Level4RgCO, help={"Size, where the power law dependence ends, usually Rg of lower level, for level 1 it is 0"}
//
	Button Level4SetRGCODefault,pos={20,450},size={100,20}, proc=IR1A_InputPanelButtonProc,title="Rg(level-1)->RGCO", help={"This button sets the RgCutOff to value of Rg from previous level (or 0 for level 1)"}
	CheckBox Level4LinkRGCO,pos={140,452},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link RGCO"
	CheckBox Level4LinkRGCO,variable= root:Packages:Irena_UnifFit:Level4LinkRgCo, help={"Link the RgCO to lower level and fit at the same time?"}

	PopupMenu Level4KFactor,pos={230,435},size={170,21},proc=IR1A_PanelPopupControl,title="k factor :"
	PopupMenu Level4KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}

	CheckBox Level4Corelations,pos={90,480},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this correlated system? "
	CheckBox Level4Corelations,variable= root:Packages:Irena_UnifFit:Level4Corelations, help={"Is there a peak or do you expect Corelations between particles to have importance"}

	SetVariable Level4ETA,pos={14,500},size={180,16},proc=IR1A_PanelSetVarProc,title="ETA    ",bodyWidth=140, format="%0.4g"
	SetVariable Level4ETA,limits={0,inf,0.05*Level4Eta},value= root:Packages:Irena_UnifFit:Level4ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Guinier for multiple order Corelations"}
	CheckBox Level4FitETA,pos={200,500},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level4FitETA,variable= root:Packages:Irena_UnifFit:Level4FitETA, help={"Fit correaltion distance? Slect properly the starting conditions and limits."}
	SetVariable Level4ETALowLimit,pos={230,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level4ETALowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4ETALowLimit, help={"Correlation distance low limit"}
	SetVariable Level4ETAHighLimit,pos={300,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level4ETAHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4ETAHighLimit, help={"Correlation distance high limit"}

	SetVariable Level4PACK,pos={14,520},size={180,16},proc=IR1A_PanelSetVarProc,title="Pack    ",bodyWidth=140, format="%0.4g"
	SetVariable Level4PACK,limits={0,8,0.05*Level4Pack},value= root:Packages:Irena_UnifFit:Level4PACK, help={"Packing factor for domains. For dilute objects 0, for FCC packed spheres 8*0.592"}
	CheckBox Level4FitPACK,pos={200,520},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level4FitPACK,variable= root:Packages:Irena_UnifFit:Level4FitPACK, help={"Fit packing factor? Select properly starting condions and limits"}
	SetVariable Level4PACKLowLimit,pos={230,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level4PACKLowLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level4PACKLowLimit, help={"Low limit for packing factor"}
	SetVariable Level4PACKHighLimit,pos={300,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level4PACKHighLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level4PACKHighLimit, help={"High limit for packing factor"}

////Level 4
////
	//Level5 controls
	NVAR Level5G = root:Packages:Irena_UnifFit:Level5G
	NVAR Level5B = root:Packages:Irena_UnifFit:Level5B
	NVAR Level5P = root:Packages:Irena_UnifFit:Level5P
	NVAR Level5Rg = root:Packages:Irena_UnifFit:Level5Rg
	NVAR Level5Eta=root:Packages:Irena_UnifFit:Level5Eta
	NVAR Level5Pack=root:Packages:Irena_UnifFit:Level5Pack
	TitleBox Level5Title, title="   Level  5 controls    ", frame=1, labelBack=(0,50000,50000), pos={14,258}, size={150,8}

	SetVariable Level5G,pos={14,280},size={180,16},proc=IR1A_PanelSetVarProc,title="G   ",bodyWidth=140, format="%0.4g"
	SetVariable Level5G,limits={0,inf,0.05*Level5G},value= root:Packages:Irena_UnifFit:Level5G, help={"Guinier prefactor"}
	CheckBox Level5FitG,pos={200,281},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level5FitG,variable= root:Packages:Irena_UnifFit:Level5FitG, help={"Fit G?, find god starting conditions and select fitting limits..."}
	SetVariable Level5GLowLimit,pos={230,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level5GLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5GLowLimit, help={"Low limit for G fitting"}
	SetVariable Level5GHighLimit,pos={300,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level5GHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5GHighLimit, help={"High limit for G fitting"}

	SetVariable Level5Rg,pos={14,300},size={180,16},proc=IR1A_PanelSetVarProc,title="Rg   ", help={"Radius of gyration, e.g., sqrt(5/3)*R for sphere etc..."}
	SetVariable Level5Rg,limits={0,inf,0.05*Level5Rg},value= root:Packages:Irena_UnifFit:Level5Rg,bodyWidth=140, format="%0.4g"
	CheckBox Level5FitRg,pos={200,301},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level5FitRg,variable= root:Packages:Irena_UnifFit:Level5FitRg, help={"Fit Rg? Select properly starting conditions and limits"}
	SetVariable Level5RgLowLimit,pos={230,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level5RgLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5RgLowLimit, help={"Low limit for Rg fitting..."}
	SetVariable Level5RgHighLimit,pos={300,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level5RgHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5RgHighLimit, help={"High limit for Rg fitting"}

	//Button Level5FitRgAndG,pos={230,318},size={130,20}, proc=IR1A_InputPanelButtonProc,title="Fit Rg/G bwtn cursors", help={"Do local fit of Guinier dependence between the cursors amd put resulting values into the Rg and G fields"}

	CheckBox Level5MassFractal,pos={20,330},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this mass fractal from lower level?"
	CheckBox Level5MassFractal,variable= root:Packages:Irena_UnifFit:Level5MassFractal, help={"Is this mass fractal composed of particles from lower level?"}
	CheckBox Level5LinkB,pos={20,350},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link B to G/Rg/P?"
	CheckBox Level5LinkB,variable= root:Packages:Irena_UnifFit:Level5LinkB, help={"If the B should be calculated based on Guinier/Porods law?"}
	SetVariable Level5SurfToVolRat,pos={230,350},size={130,16},proc=IR1A_PanelSetVarProc,title="Surf / Vol", help={"Surface to volume ratio if P=4 (Porod law) in m2/cm3 if input Q in is A"}
	SetVariable Level5SurfToVolRat,limits={inf,inf,0},value= root:Packages:Irena_UnifFit:Level5SurfaceToVolRat

	SetVariable Level5B,pos={14,370},size={180,16},proc=IR1A_PanelSetVarProc,title="B   ", help={"Power law prefactor"},bodyWidth=140, format="%0.4g"
	SetVariable Level5B,limits={0,inf,0.05*Level5B},value= root:Packages:Irena_UnifFit:Level5B
	CheckBox Level5FitB,pos={200,371},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level5FitB,variable= root:Packages:Irena_UnifFit:Level5FitB, help={"Fit the Power law prefactor?, select properly the starting conditions and limits before fitting"}
	SetVariable Level5BLowLimit,pos={230,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level5BLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5BLowLimit, help={"Power law prefactor low limit"}
	SetVariable Level5BHighLimit,pos={300,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level5BHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5BHighLimit, help={"Power law prefactor high limit"}

	SetVariable Level5DegreeOfAggreg,pos={14,370},size={140,16},proc=IR1A_PanelSetVarProc,title="Deg. of Aggreg ", help={"Degree of aggregation for mass fractals. = Rg/Rg(level-1) "}
	SetVariable Level5DegreeOfAggreg,limits={-inf,inf,0},value= root:Packages:Irena_UnifFit:Level5DegreeOfAggreg

	SetVariable Level5P,pos={14,390},size={180,16},proc=IR1A_PanelSetVarProc,title="P   ", help={"Power law slope, e.g., -4 for Porod tails"}
	SetVariable Level5P,limits={0,6,0.05*Level5P},value= root:Packages:Irena_UnifFit:Level5P,bodyWidth=140, format="%0.4g"
	CheckBox Level5FitP,pos={200,391},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level5FitP,variable= root:Packages:Irena_UnifFit:Level5FitP, help={"Fit the Power law slope, select good starting conditions and appropriate limits"}
	SetVariable Level5PLowLimit,pos={230,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level5PLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5PLowLimit, help={"Power law low limit for slope"}
	SetVariable Level5PHighLimit,pos={300,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level5PHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5PHighLimit, help={"Power law high limit for slope"}

	//Button Level5FitPAndB,pos={230,408},size={130,20}, proc=IR1A_InputPanelButtonProc,title="Fit P/B bwtn cursors", help={"Do Power law fitting between the cursors and put resulting parameters in the P and B fields"}


	SetVariable Level5RGCO,pos={14,430},size={180,16},proc=IR1A_PanelSetVarProc,title="RgCutoff  ",bodyWidth=100
	SetVariable Level5RGCO,limits={0,inf,1},value= root:Packages:Irena_UnifFit:Level5RgCO, help={"Size, where the power law dependence ends, usually Rg of lower level, for level 1 it is 0"}

	Button Level5SetRGCODefault,pos={20,450},size={100,20}, proc=IR1A_InputPanelButtonProc,title="Rg(level-1)->RGCO", help={"This button sets the RgCutOff to value of Rg from previous level (or 0 for level 1)"}
	CheckBox Level5LinkRGCO,pos={140,452},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link RGCO"
	CheckBox Level5LinkRGCO,variable= root:Packages:Irena_UnifFit:Level5LinkRgCo, help={"Link the RgCO to lower level and fit at the same time?"}

	PopupMenu Level5KFactor,pos={230,435},size={170,21},proc=IR1A_PanelPopupControl,title="k factor :"
	PopupMenu Level5KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}

	CheckBox Level5Corelations,pos={90,480},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this correlated system? "
	CheckBox Level5Corelations,variable= root:Packages:Irena_UnifFit:Level5Corelations, help={"Is there a peak or do you expect Corelations between particles to have importance"}

	SetVariable Level5ETA,pos={14,500},size={180,16},proc=IR1A_PanelSetVarProc,title="ETA    ",bodyWidth=140, format="%0.4g"
	SetVariable Level5ETA,limits={0,inf,0.05*Level5Eta},value= root:Packages:Irena_UnifFit:Level5ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Guinier for multiple order Corelations"}
	CheckBox Level5FitETA,pos={200,500},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level5FitETA,variable= root:Packages:Irena_UnifFit:Level5FitETA, help={"Fit correaltion distance? Slect properly the starting conditions and limits."}
	SetVariable Level5ETALowLimit,pos={230,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level5ETALowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5ETALowLimit, help={"Correlation distance low limit"}
	SetVariable Level5ETAHighLimit,pos={300,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level5ETAHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5ETAHighLimit, help={"Correlation distance high limit"}

	SetVariable Level5PACK,pos={14,520},size={180,16},proc=IR1A_PanelSetVarProc,title="Pack    ",bodyWidth=140, format="%0.4g"
	SetVariable Level5PACK,limits={0,8,0.05*Level5Pack},value= root:Packages:Irena_UnifFit:Level5PACK, help={"Packing factor for domains. For dilute objects 0, for FCC packed spheres 8*0.592"}
	CheckBox Level5FitPACK,pos={200,520},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level5FitPACK,variable= root:Packages:Irena_UnifFit:Level5FitPACK, help={"Fit packing factor? Select properly starting condions and limits"}
	SetVariable Level5PACKLowLimit,pos={230,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level5PACKLowLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level5PACKLowLimit, help={"Low limit for packing factor"}
	SetVariable Level5PACKHighLimit,pos={300,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" ", format="%0.3g"
	SetVariable Level5PACKHighLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level5PACKHighLimit, help={"High limit for packing factor"}

////Level5 controls

	//lets try to update the tabs...
	IR1A_TabPanelControl("DistTabs",0)

EndMacro


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_TabPanelControl(name,tab)
	String name
	Variable tab

//variable timerRefNum
//timerRefNum = startMSTimer

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit
	
	NVAR/Z ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
	if (!NVAR_Exists(ActiveTab))
		variable/g root:Packages:Irena_UnifFit:ActiveTab
		NVAR ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
	endif
	ActiveTab=tab+1

	NVAR Nmbdist=root:Packages:Irena_UnifFit:NumberOfLevels
	if (NmbDIst==0)
		ActiveTab=0
	endif
	//need to kill any outstanding windows for shapes... ANy... All should have the same name...
	DoWindow/F IR1A_ControlPanel

	PopupMenu NumberOfLevels mode=NmbDist+1

	NVAR UseNoLimits=root:Packages:Irena_UnifFit:UseNoLimits
	NVAR ExtendedWarnings=root:Packages:Irena_UnifFit:ExtendedWarnings

//	Level1 controls
	if((cmpstr(name,"Checkbox")!=0 ) || ((cmpstr(name,"Checkbox")==0)&&(tab==0)))

		NVAR Level1Corelations=root:Packages:Irena_UnifFit:Level1Corelations
		NVAR Level1FitRg=root:Packages:Irena_UnifFit:Level1FitRg
		NVAR Level1FitG=root:Packages:Irena_UnifFit:Level1FitG
		NVAR Level1FitP=root:Packages:Irena_UnifFit:Level1FitP
		NVAR Level1FitB=root:Packages:Irena_UnifFit:Level1FitB
		NVAR Level1FitEta=root:Packages:Irena_UnifFit:Level1FitEta
		NVAR Level1FitPack=root:Packages:Irena_UnifFit:Level1FitPack
		NVAR Level1FitRGCO=root:Packages:Irena_UnifFit:Level1FitRGCO
		NVAR Level1MassFractal=root:Packages:Irena_UnifFit:Level1MassFractal
		NVAR Level1LinkRGCO=root:Packages:Irena_UnifFit:Level1LinkRGCO
		NVAR Level1LinkB=root:Packages:Irena_UnifFit:Level1LinkB

		Button LevelXFitRgAndG,disable= ((tab+1)> Nmbdist)
		Button LevelXFitPAndB,disable= ((tab+1)> Nmbdist)
		Button CopyMoveLevel,disable= ((tab+1)> Nmbdist)
		TitleBox PhysValidityWarning, disable=(IR1A_CheckOneUnifiedLevel(tab+1,ExtendedWarnings)!=0 || Nmbdist<tab+1)
		TitleBox Info20 ,disable= ((tab+1)> Nmbdist)
		TitleBox Info21,disable= ((tab+1)> Nmbdist)
		
		TitleBox Level1Title, disable= (tab!=0 || Nmbdist<1)
		SetVariable Level1Rg,disable= (tab!=0 || Nmbdist<1)
		CheckBox Level1FitRg,disable= (tab!=0 || Nmbdist<1)
		SetVariable Level1RgLowLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitRg!=1 || UseNoLimits)
		SetVariable Level1RgHighLimit,disable= (tab!=0 || Nmbdist<1|| Level1FitRg!=1 || UseNoLimits)
	
		SetVariable Level1G,disable= (tab!=0 || Nmbdist<1)
		CheckBox Level1FitG,disable= (tab!=0 || Nmbdist<1)
		SetVariable Level1GLowLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitG!=1 || UseNoLimits)
		SetVariable Level1GHighLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitG!=1 || UseNoLimits)
	
		CheckBox Level1MassFractal, value=Level1MassFractal
		CheckBox Level1MassFractal,disable= (tab!=0 || Nmbdist<1)
		SetVariable Level1SurfToVolRat,disable= (tab!=0 || Nmbdist<1)
		
		SetVariable Level1P,disable= (tab!=0 || Nmbdist<1)
		CheckBox Level1FitP,disable= (tab!=0 || Nmbdist<1)
		SetVariable Level1PLowLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitP!=1 || UseNoLimits)
		SetVariable Level1PHighLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitP!=1|| UseNoLimits)
	
		variable DisplayMe= (tab!=0 || Nmbdist<1 || Level1MassFractal || Level1LinkB)
		DisplayMe = (Level1LinkB>0 && tab==0 && (Nmbdist>0)) ? 2*DisplayMe : DisplayMe
		SetVariable Level1B,disable= (DisplayMe)
		CheckBox Level1LinkB,disable= (tab!=0 || Nmbdist<1)
		CheckBox Level1FitB,disable= (tab!=0 || Nmbdist<1 ||Level1MassFractal || Level1LinkB)
		SetVariable Level1BLowLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitB!=1 || Level1MassFractal  || Level1LinkB || UseNoLimits)
		SetVariable Level1BHighLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitB!=1 || Level1MassFractal  || Level1LinkB || UseNoLimits)
		
		SetVariable Level1DegreeOfAggreg,disable= (tab!=0 || Nmbdist<1 || !Level1MassFractal || tab==0)	//this control exists only for higher levels...
		CheckBox Level1Corelations, value=Level1Corelations
		CheckBox Level1Corelations,disable= (tab!=0 || Nmbdist<1)
		SetVariable Level1ETA,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1)
		CheckBox Level1FitETA,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1)
		SetVariable Level1ETALowLimit,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1 || Level1FitEta!=1 || UseNoLimits)
		SetVariable Level1ETAHighLimit,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1 || Level1FitEta!=1 || UseNoLimits)
	
		SetVariable Level1PACK,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1)
		CheckBox Level1FitPACK,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1)
		SetVariable Level1PACKLowLimit,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1 || Level1FitPack!=1 || UseNoLimits)
		SetVariable Level1PACKHighLimit,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1 || Level1FitPack!=1 || UseNoLimits)
	
//		SetVariable Level1EtaStep,disable= (tab!=0 || Nmbdist<1  ||  Level1Corelations!=1)
//		SetVariable Level1PackStep,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1)
		SetVariable Level1RgCO,disable= (tab!=0 || Nmbdist<1)
//		CheckBox Level1FitRGCO,disable= (tab!=0 || Nmbdist<1 || Level1LinkRGCO) 
//		SetVariable Level1RgCOLowLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitRGCO!=1|| Level1LinkRGCO)
//		SetVariable Level1RgCOHighLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitRGCO!=1|| Level1LinkRGCO)
		Button Level1SetRGCODefault,disable= (tab!=0 || Nmbdist<1 || tab==0)
		CheckBox Level1LinkRGCO,disable= (tab!=0 || Nmbdist<1 || tab==0)
		PopupMenu Level1KFactor,disable= (tab!=0 || Nmbdist<1)
	endif	
//

	if((cmpstr(name,"Checkbox")!=0 ) || ((cmpstr(name,"Checkbox")==0)&&(tab==1)))
	//	Level2 controls
		NVAR Level2Corelations=root:Packages:Irena_UnifFit:Level2Corelations
		NVAR Level2FitRg=root:Packages:Irena_UnifFit:Level2FitRg
		NVAR Level2FitG=root:Packages:Irena_UnifFit:Level2FitG
		NVAR Level2FitP=root:Packages:Irena_UnifFit:Level2FitP
		NVAR Level2FitB=root:Packages:Irena_UnifFit:Level2FitB
		NVAR Level2FitEta=root:Packages:Irena_UnifFit:Level2FitEta
		NVAR Level2FitPack=root:Packages:Irena_UnifFit:Level2FitPack
		NVAR Level2FitRGCO=root:Packages:Irena_UnifFit:Level2FitRGCO
		NVAR Level2MassFractal=root:Packages:Irena_UnifFit:Level2MassFractal
		NVAR Level2LinkRGCO=root:Packages:Irena_UnifFit:Level2LinkRGCO
		NVAR Level2LinkB=root:Packages:Irena_UnifFit:Level2LinkB
		
		TitleBox Level2Title,disable= (tab!=1 || Nmbdist<2)
		SetVariable Level2Rg,disable= (tab!=1 || Nmbdist<2)
		CheckBox Level2FitRg,disable= (tab!=1 || Nmbdist<2)
		SetVariable Level2RgLowLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitRg!=1 || UseNoLimits)
		SetVariable Level2RgHighLimit,disable= (tab!=1 || Nmbdist<2|| Level2FitRg!=1 || UseNoLimits)
	
		SetVariable Level2G,disable= (tab!=1 || Nmbdist<2)
		CheckBox Level2FitG,disable= (tab!=1 || Nmbdist<2)
		SetVariable Level2GLowLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitG!=1 || UseNoLimits)
		SetVariable Level2GHighLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitG!=1 || UseNoLimits)
	
		CheckBox Level2MassFractal, value=Level2MassFractal
		CheckBox Level2MassFractal,disable= (tab!=1 || Nmbdist<2 ) 
		SetVariable Level2SurfToVolRat,disable= (tab!=1 || Nmbdist<2)
		
		SetVariable Level2P,disable= (tab!=1 || Nmbdist<2)
		CheckBox Level2FitP,disable= (tab!=1 || Nmbdist<2)
		SetVariable Level2PLowLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitP!=1 || UseNoLimits)
		SetVariable Level2PHighLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitP!=1 || UseNoLimits)
	
		DisplayMe= (tab!=1 || Nmbdist<2 || Level2MassFractal || Level2LinkB)
		DisplayMe = (Level2LinkB>0 && tab==1 && (Nmbdist>1)) ? 2*DisplayMe : DisplayMe
		SetVariable Level2B,disable= (DisplayMe)
		CheckBox Level2LinkB,disable= (tab!=1 || Nmbdist<2)
		CheckBox Level2FitB,disable= (tab!=1 || Nmbdist<2 ||Level2MassFractal || Level2LinkB)
		SetVariable Level2BLowLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitB!=1 || Level2MassFractal || Level2LinkB || UseNoLimits)
		SetVariable Level2BHighLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitB!=1 || Level2MassFractal || Level2LinkB || UseNoLimits)
		
		SetVariable Level2DegreeOfAggreg,disable= (tab!=1 || Nmbdist<2 || !Level2MassFractal)
	
//		SetVariable Level2PStep,disable= (tab!=1 || Nmbdist<2)
//		SetVariable Level2BStep,disable= (tab!=1 || Nmbdist<2 || Level2MassFractal)
//		Button Level2FitPAndB,disable= (tab!=1 || Nmbdist<2)
		CheckBox Level2Corelations, value=Level2Corelations
		CheckBox Level2Corelations,disable= (tab!=1 || Nmbdist<2)
		SetVariable Level2ETA,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1)
		CheckBox Level2FitETA,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1)
		SetVariable Level2ETALowLimit,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1 || Level2FitEta!=1 || UseNoLimits)
		SetVariable Level2ETAHighLimit,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1 || Level2FitEta!=1 || UseNoLimits)
	
		SetVariable Level2PACK,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1)
		CheckBox Level2FitPACK,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1)
		SetVariable Level2PACKLowLimit,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1 || Level2FitPack!=1 || UseNoLimits)
		SetVariable Level2PACKHighLimit,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1 || Level2FitPack!=1 || UseNoLimits)
	
//		SetVariable Level2EtaStep,disable= (tab!=1 || Nmbdist<2  ||  Level2Corelations!=1)
//		SetVariable Level2PackStep,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1)
		SetVariable Level2RGCO,disable= (tab!=1 || Nmbdist<2)
//		CheckBox Level2FitRGCO,disable= (tab!=1 || Nmbdist<2 || Level2LinkRGCO)
//		SetVariable Level2RGCOLowLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitRGCO!=1 || Level2LinkRGCO)
//		SetVariable Level2RGCOHighLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitRGCO!=1 || Level2LinkRGCO)
		Button Level2SetRGCODefault,disable= (tab!=1 || Nmbdist<2)
		CheckBox Level2LinkRGCO,disable= (tab!=1 || Nmbdist<2)
		PopupMenu Level2KFactor,disable= (tab!=1 || Nmbdist<2)
	endif
//
//
	if((cmpstr(name,"Checkbox")!=0 ) || ((cmpstr(name,"Checkbox")==0)&&(tab==2)))

	//	Level3 controls
		NVAR Level3Corelations=root:Packages:Irena_UnifFit:Level3Corelations
		NVAR Level3FitRg=root:Packages:Irena_UnifFit:Level3FitRg
		NVAR Level3FitG=root:Packages:Irena_UnifFit:Level3FitG
		NVAR Level3FitP=root:Packages:Irena_UnifFit:Level3FitP
		NVAR Level3FitB=root:Packages:Irena_UnifFit:Level3FitB
		NVAR Level3FitEta=root:Packages:Irena_UnifFit:Level3FitEta
		NVAR Level3FitPack=root:Packages:Irena_UnifFit:Level3FitPack
		NVAR Level3FitRGCO=root:Packages:Irena_UnifFit:Level3FitRGCO
		NVAR Level3MassFractal=root:Packages:Irena_UnifFit:Level3MassFractal
		NVAR Level3LinkRGCO=root:Packages:Irena_UnifFit:Level3LinkRGCO
		NVAR Level3LinkB=root:Packages:Irena_UnifFit:Level3LinkB
		
		TitleBox Level3Title,disable= (tab!=2 || Nmbdist<3)
		SetVariable Level3Rg,disable= (tab!=2 || Nmbdist<3)
		CheckBox Level3FitRg,disable= (tab!=2 || Nmbdist<3)
		SetVariable Level3RgLowLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitRg!=1 || UseNoLimits)
		SetVariable Level3RgHighLimit,disable= (tab!=2 || Nmbdist<3|| Level3FitRg!=1 || UseNoLimits)
	
		SetVariable Level3G,disable= (tab!=2 || Nmbdist<3)
		CheckBox Level3FitG,disable= (tab!=2 || Nmbdist<3)
		SetVariable Level3GLowLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitG!=1 || UseNoLimits)
		SetVariable Level3GHighLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitG!=1 || UseNoLimits)
	
		CheckBox Level3MassFractal, value=Level3MassFractal
		CheckBox Level3MassFractal,disable= (tab!=2 || Nmbdist<3) 
		SetVariable Level3SurfToVolRat,disable= (tab!=2 || Nmbdist<3)
	
//		SetVariable Level3RgStep,disable= (tab!=2 || Nmbdist<3)
//		SetVariable Level3GStep,disable= (tab!=2 || Nmbdist<3)
//		Button Level3FitRgAndG,disable= (tab!=2 || Nmbdist<3)
		
		SetVariable Level3P,disable= (tab!=2 || Nmbdist<3)
		CheckBox Level3FitP,disable= (tab!=2 || Nmbdist<3)
		SetVariable Level3PLowLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitP!=1 || UseNoLimits)
		SetVariable Level3PHighLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitP!=1 || UseNoLimits)
	
		DisplayMe= (tab!=2 || Nmbdist<3 || Level3MassFractal || Level3LinkB)
		DisplayMe = (Level3LinkB>0 && tab==2 && (Nmbdist>2)) ? 2*DisplayMe : DisplayMe
		SetVariable Level3B,disable= (DisplayMe)
		CheckBox Level3LinkB,disable= (tab!=2 || Nmbdist<3)
		CheckBox Level3FitB,disable= (tab!=2 || Nmbdist<3 ||Level3MassFractal || Level3LinkB)
		SetVariable Level3BLowLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitB!=1 || Level3MassFractal || Level3LinkB || UseNoLimits)
		SetVariable Level3BHighLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitB!=1 || Level3MassFractal || Level3LinkB || UseNoLimits)
		
		SetVariable Level3DegreeOfAggreg,disable= (tab!=2 || Nmbdist<3 || !Level3MassFractal)
	
//		SetVariable Level3PStep,disable= (tab!=2 || Nmbdist<3)
//		SetVariable Level3BStep,disable= (tab!=2 || Nmbdist<3 || Level3MassFractal)
//		Button Level3FitPAndB,disable= (tab!=2 || Nmbdist<3)
		CheckBox Level3Corelations, value=Level3Corelations
		CheckBox Level3Corelations,disable= (tab!=2 || Nmbdist<3)
		SetVariable Level3ETA,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1)
		CheckBox Level3FitETA,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1)
		SetVariable Level3ETALowLimit,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1 || Level3FitEta!=1 || UseNoLimits)
		SetVariable Level3ETAHighLimit,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1 || Level3FitEta!=1 || UseNoLimits)
	
		SetVariable Level3PACK,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1)
		CheckBox Level3FitPACK,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1)
		SetVariable Level3PACKLowLimit,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1 || Level3FitPack!=1 || UseNoLimits)
		SetVariable Level3PACKHighLimit,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1 || Level3FitPack!=1 || UseNoLimits)
	
//		SetVariable Level3EtaStep,disable= (tab!=2 || Nmbdist<3  ||  Level3Corelations!=1)
//		SetVariable Level3PackStep,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1)
		SetVariable Level3RGCO,disable= (tab!=2 || Nmbdist<3)
//		CheckBox Level3FitRGCO,disable= (tab!=2 || Nmbdist<3 || Level3LinkRGCO)
//		SetVariable Level3RGCOLowLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitRGCO!=1 || Level3LinkRGCO)
//		SetVariable Level3RGCOHighLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitRGCO!=1 || Level3LinkRGCO)
		Button Level3SetRGCODefault,disable= (tab!=2 || Nmbdist<3)
		CheckBox Level3LinkRGCO,disable= (tab!=2 || Nmbdist<3)
		PopupMenu Level3KFactor,disable= (tab!=2 || Nmbdist<3)
	endif
//
//
	if((cmpstr(name,"Checkbox")!=0 ) || ((cmpstr(name,"Checkbox")==0)&&(tab==3)))

	//	Level4 controls
		NVAR Level4Corelations=root:Packages:Irena_UnifFit:Level4Corelations
		NVAR Level4FitRg=root:Packages:Irena_UnifFit:Level4FitRg
		NVAR Level4FitG=root:Packages:Irena_UnifFit:Level4FitG
		NVAR Level4FitP=root:Packages:Irena_UnifFit:Level4FitP
		NVAR Level4FitB=root:Packages:Irena_UnifFit:Level4FitB
		NVAR Level4FitEta=root:Packages:Irena_UnifFit:Level4FitEta
		NVAR Level4FitPack=root:Packages:Irena_UnifFit:Level4FitPack
		NVAR Level4FitRGCO=root:Packages:Irena_UnifFit:Level4FitRGCO
		NVAR Level4MassFractal=root:Packages:Irena_UnifFit:Level4MassFractal
		NVAR Level4LinkRGCO=root:Packages:Irena_UnifFit:Level4LinkRGCO
		NVAR Level4LinkB=root:Packages:Irena_UnifFit:Level4LinkB
		
		TitleBox Level4Title,disable= (tab!=3 || Nmbdist<4)
		SetVariable Level4Rg,disable= (tab!=3 || Nmbdist<4)
		CheckBox Level4FitRg,disable= (tab!=3 || Nmbdist<4)
		SetVariable Level4RgLowLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitRg!=1 || UseNoLimits)
		SetVariable Level4RgHighLimit,disable= (tab!=3 || Nmbdist<4|| Level4FitRg!=1 || UseNoLimits)
	
		SetVariable Level4G,disable= (tab!=3 || Nmbdist<4)
		CheckBox Level4FitG,disable= (tab!=3 || Nmbdist<4)
		SetVariable Level4GLowLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitG!=1 || UseNoLimits)
		SetVariable Level4GHighLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitG!=1 || UseNoLimits)
	
		CheckBox Level4MassFractal, value=Level4MassFractal
		CheckBox Level4MassFractal,disable= (tab!=3 || Nmbdist<4) 
		SetVariable Level4SurfToVolRat,disable= (tab!=3 || Nmbdist<4)
	
//		SetVariable Level4RgStep,disable= (tab!=3 || Nmbdist<4)
//		SetVariable Level4GStep,disable= (tab!=3 || Nmbdist<4)
//		Button Level4FitRgAndG,disable= (tab!=3 || Nmbdist<4)
		
		SetVariable Level4P,disable= (tab!=3 || Nmbdist<4)
		CheckBox Level4FitP,disable= (tab!=3 || Nmbdist<4)
		SetVariable Level4PLowLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitP!=1 || UseNoLimits)
		SetVariable Level4PHighLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitP!=1 || UseNoLimits)
	
		DisplayMe= (tab!=3 || Nmbdist<4 || Level4MassFractal || Level4LinkB)
		DisplayMe = (Level4LinkB>0 && tab==3 && (Nmbdist>3)) ? 2*DisplayMe : DisplayMe
		SetVariable Level4B,disable= (DisplayMe)
		CheckBox Level4LinkB,disable= (tab!=3 || Nmbdist<4)
		CheckBox Level4FitB,disable= (tab!=3 || Nmbdist<4 ||Level4MassFractal || Level4LinkB)
		SetVariable Level4BLowLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitB!=1 || Level4MassFractal || UseNoLimits || Level4LinkB)
		SetVariable Level4BHighLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitB!=1 || Level4MassFractal || UseNoLimits || Level4LinkB)
		
		SetVariable Level4DegreeOfAggreg,disable= (tab!=3 || Nmbdist<4 || !Level4MassFractal)
	
//		SetVariable Level4PStep,disable= (tab!=3 || Nmbdist<4)
//		SetVariable Level4BStep,disable= (tab!=3 || Nmbdist<4 || Level4MassFractal)
//		Button Level4FitPAndB,disable= (tab!=3 || Nmbdist<4)
		CheckBox Level4Corelations, value=Level4Corelations
		CheckBox Level4Corelations,disable= (tab!=3 || Nmbdist<4)
		SetVariable Level4ETA,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1)
		CheckBox Level4FitETA,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1)
		SetVariable Level4ETALowLimit,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1 || Level4FitEta!=1 || UseNoLimits)
		SetVariable Level4ETAHighLimit,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1 || Level4FitEta!=1 || UseNoLimits)
	
		SetVariable Level4PACK,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1)
		CheckBox Level4FitPACK,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1)
		SetVariable Level4PACKLowLimit,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1 || Level4FitPack!=1 || UseNoLimits)
		SetVariable Level4PACKHighLimit,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1 || Level4FitPack!=1 || UseNoLimits)
	
//		SetVariable Level4EtaStep,disable= (tab!=3 || Nmbdist<4  ||  Level4Corelations!=1)
//		SetVariable Level4PackStep,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1)
		SetVariable Level4RGCO,disable= (tab!=3 || Nmbdist<4)
//		CheckBox Level4FitRGCO,disable= (tab!=3 || Nmbdist<4 || Level4LinkRGCO)
//		SetVariable Level4RGCOLowLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitRGCO!=1 || Level4LinkRGCO)
//		SetVariable Level4RGCOHighLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitRGCO!=1 || Level4LinkRGCO)
		Button Level4SetRGCODefault,disable= (tab!=3 || Nmbdist<4)
		CheckBox Level4LinkRGCO,disable= (tab!=3 || Nmbdist<4)
		PopupMenu Level4KFactor,disable= (tab!=3 || Nmbdist<4)
	endif
//
	if((cmpstr(name,"Checkbox")!=0 ) || ((cmpstr(name,"Checkbox")==0)&&(tab==4)))
		
		//	Level5 controls
		NVAR Level5Corelations=root:Packages:Irena_UnifFit:Level5Corelations
		NVAR Level5FitRg=root:Packages:Irena_UnifFit:Level5FitRg
		NVAR Level5FitG=root:Packages:Irena_UnifFit:Level5FitG
		NVAR Level5FitP=root:Packages:Irena_UnifFit:Level5FitP
		NVAR Level5FitB=root:Packages:Irena_UnifFit:Level5FitB
		NVAR Level5FitEta=root:Packages:Irena_UnifFit:Level5FitEta
		NVAR Level5FitPack=root:Packages:Irena_UnifFit:Level5FitPack
		NVAR Level5FitRGCO=root:Packages:Irena_UnifFit:Level5FitRGCO
		NVAR Level5MassFractal=root:Packages:Irena_UnifFit:Level5MassFractal
		NVAR Level5LinkRGCO=root:Packages:Irena_UnifFit:Level5LinkRGCO
		NVAR Level5LinkB=root:Packages:Irena_UnifFit:Level5LinkB
		
		TitleBox Level5Title,disable= (tab!=4 || Nmbdist<5)
		SetVariable Level5Rg,disable= (tab!=4 || Nmbdist<5)
		CheckBox Level5FitRg,disable= (tab!=4 || Nmbdist<5)
		SetVariable Level5RgLowLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitRg!=1 || UseNoLimits)
		SetVariable Level5RgHighLimit,disable= (tab!=4 || Nmbdist<5|| Level5FitRg!=1 || UseNoLimits)
		
		SetVariable Level5G,disable= (tab!=4 || Nmbdist<5)
		CheckBox Level5FitG,disable= (tab!=4 || Nmbdist<5)
		SetVariable Level5GLowLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitG!=1 || UseNoLimits)
		SetVariable Level5GHighLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitG!=1 || UseNoLimits)
		
		CheckBox Level5MassFractal, value=Level5MassFractal
		CheckBox Level5MassFractal,disable= (tab!=4 || Nmbdist<5) 
		SetVariable Level5SurfToVolRat,disable= (tab!=4 || Nmbdist<5)
		
//		SetVariable Level5RgStep,disable= (tab!=4 || Nmbdist<5)
//		SetVariable Level5GStep,disable= (tab!=4 || Nmbdist<5)
//		Button Level5FitRgAndG,disable= (tab!=4 || Nmbdist<5)
		
		SetVariable Level5P,disable= (tab!=4 || Nmbdist<5)
		CheckBox Level5FitP,disable= (tab!=4 || Nmbdist<5)
		SetVariable Level5PLowLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitP!=1 || UseNoLimits)
		SetVariable Level5PHighLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitP!=1 || UseNoLimits)
		
		DisplayMe= (tab!=4 || Nmbdist<5 || Level5MassFractal || Level5LinkB)
		DisplayMe = (Level5LinkB>0 && tab==4 && (Nmbdist>4)) ? 2*DisplayMe : DisplayMe
		SetVariable Level5B,disable= (DisplayMe)
		CheckBox Level5LinkB,disable= (tab!=4 || Nmbdist<5)
		CheckBox Level5FitB,disable= (tab!=4 || Nmbdist<5 ||Level5MassFractal || Level5LinkB)
		SetVariable Level5BLowLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitB!=1 || Level5MassFractal || UseNoLimits || Level5LinkB)
		SetVariable Level5BHighLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitB!=1 || Level5MassFractal || UseNoLimits || Level5LinkB)
		
		SetVariable Level5DegreeOfAggreg,disable= (tab!=4 || Nmbdist<5 || !Level5MassFractal)
		
//		SetVariable Level5PStep,disable= (tab!=4 || Nmbdist<5)
//		SetVariable Level5BStep,disable= (tab!=4 || Nmbdist<5 || Level5MassFractal)
//		Button Level5FitPAndB,disable= (tab!=4 || Nmbdist<5)
		CheckBox Level5Corelations, value=Level5Corelations
		CheckBox Level5Corelations,disable= (tab!=4 || Nmbdist<5)
		SetVariable Level5ETA,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1)
		CheckBox Level5FitETA,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1)
		SetVariable Level5ETALowLimit,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1 || Level5FitEta!=1 || UseNoLimits)
		SetVariable Level5ETAHighLimit,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1 || Level5FitEta!=1 || UseNoLimits)
		
		SetVariable Level5PACK,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1)
		CheckBox Level5FitPACK,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1)
		SetVariable Level5PACKLowLimit,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1 || Level5FitPack!=1 || UseNoLimits)
		SetVariable Level5PACKHighLimit,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1 || Level5FitPack!=1 || UseNoLimits)
		
//		SetVariable Level5EtaStep,disable= (tab!=4 || Nmbdist<5  ||  Level5Corelations!=1)
//		SetVariable Level5PackStep,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1)
		SetVariable Level5RGCO,disable= (tab!=4 || Nmbdist<5)
//		CheckBox Level5FitRGCO,disable= (tab!=4 || Nmbdist<5 || Level5LinkRGCO)
//		SetVariable Level5RGCOLowLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitRGCO!=1 || Level5LinkRGCO)
//		SetVariable Level5RGCOHighLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitRGCO!=1 || Level5LinkRGCO)
		Button Level5SetRGCODefault,disable= (tab!=4 || Nmbdist<5)
		CheckBox Level5LinkRGCO,disable= (tab!=4 || Nmbdist<5)
		PopupMenu Level5KFactor,disable= (tab!=4 || Nmbdist<5)
	endif
//
	//update the displayed local fits in graph
	//do not upcate if called from CheckboxProcedure
	if(cmpstr(name,"Checkbox")!=0)
		IR1A_DisplayLocalFits(tab+1,0)
	endif
	setDataFolder oldDF
//print "Internal loop"
//print timerRefNum, stopMSTimer(timerRefNum)

End



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

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

	DFref oldDf= GetDataFolderDFR()

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
		if(testVariableHL>5.5)
			testVariableHL = 5.5	
		endif
		SetVariable $(VarName),win=IR1A_ControlPanel,limits={0,5,0.05*IR1A_FixZeroesForLimits(testVariable)}		
	elseif(stringmatch(VarName,"*Pack"))
		testVariableLL = 0.4*testVariable
		testVariableHL = 2*testVariable
		if(testVariableHL>10)
			testVariableHL =10
		endif
		if(testVariableHL<0.1)
			testVariableHL = 0.1
		endif
		SetVariable $(VarName),win=IR1A_ControlPanel,limits={0,(testVariableHL),(0.05*IR1A_FixZeroesForLimits(testVariable))}		
	elseif(stringmatch(VarName,"*Rg"))
		testVariableLL = 0.4*testVariable
		testVariableHL = testVariable/0.4
		if(testVariableLL<2)
			testVariableLL=2
		endif
		if(testVariableHL<10)
			testVariableHL = 10
		endif
		SetVariable $(VarName),win=IR1A_ControlPanel,limits={0,inf,(0.05*IR1A_FixZeroesForLimits(testVariable))}		
	elseif(stringmatch(VarName,"*G"))
		testVariableLL = 0.1*testVariable
		testVariableHL = testVariable/0.1
		if(testVariableHL<1e-20)
			testVariableHL = 1e-20
		endif
		SetVariable $(VarName),win=IR1A_ControlPanel,limits={0,inf,(0.1*IR1A_FixZeroesForLimits(testVariable))}	
	elseif(stringmatch(VarName,"*ETA"))//**DWS
		testVariableLL = 0.5*testVariable
		testVariableHL = 2*testVariable	
		if(testVariableHL<10)
			testVariableHL = 10
		endif
		SetVariable $(VarName),win=IR1A_ControlPanel,limits={0,inf,(0.01*IR1A_FixZeroesForLimits(testVariable))}
	else	
		SetVariable $(VarName),win=IR1A_ControlPanel,limits={0,inf,(0.05*IR1A_FixZeroesForLimits(testVariable))}
		testVariableLL = 0.2*testVariable
		testVariableHL = 5*testVariable	
	endif
end

//************************************************************************************************************
static Function IR1A_FixZeroesForLimits(ValueIn)
	variable ValueIn
	if(ValueIn<1e-30)
		return 1
	else	
		return ValueIn
	endif
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1A_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked


	DFref oldDf= GetDataFolderDFR()

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
			execute("PopupMenu SelectDataFolder,mode=1,popvalue=\"---\",value= \"---;\"+IR2P_GenStringOfFolders(winNm=\""+"IR1A_ControlPanel"+"\")")
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
	
	DFref oldDf= GetDataFolderDFR()

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
		KillWIndow/Z IR1_LogLogPlotU
 		Execute ("IR1_LogLogPlotU()")
	endif
	
	Duplicate/O OriginalIntensity, OriginalIntQ4
	Duplicate/O OriginalQvector, OriginalQ4
	Duplicate/O OriginalError, OriginalErrQ4
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
		KillWIndow/Z IR1_IQ4_Q_PlotU
		Execute ("IR1_IQ4_Q_PlotU()")
	elseif (cmpstr(Package,"LSQF")==0)
		KillWIndow/Z IR1_IQ4_Q_PlotLSQF
 		Execute ("IR1_IQ4_Q_PlotLSQF()")
	endif
	setDataFolder oldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************

Proc  IR1_IQ4_Q_PlotU() 
	PauseUpdate    		// building window...
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
	PauseUpdate    		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:Irena_UnifFit:
	Display /W=(282.75,37.25,759.75,208.25)/K=1  OriginalIntensity vs OriginalQvector as "LogLogPlot"
	DoWindow/C IR1_LogLogPlotU
	ModifyGraph mode(OriginalIntensity)=3
	ModifyGraph msize(OriginalIntensity)=0
	ModifyGraph log=1
	ModifyGraph mirror=1
	ShowInfo
	String LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity ["+IN2G_ReturnUnitsForYAxis(OriginalIntensity)+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
	Label left LabelStr
	LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
	Label bottom LabelStr
	string LegendStr="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"\\s(OriginalIntensity) Experimental intensity"
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

	DFref oldDf= GetDataFolderDFR()

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
			MoveWindow /W=IR1_LogLogPlotU 0,0,(IN2G_GetGraphWidthHeight("width")),(0.6*IN2G_GetGraphWidthHeight("height"))
			MoveWindow /W=IR1_IQ4_Q_PlotU 0,(0.6*IN2G_GetGraphWidthHeight("height")),(IN2G_GetGraphWidthHeight("width")),(IN2G_GetGraphWidthHeight("height"))
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
		//IN2G_CheckForSlitSmearedRange(UseSMRData,OriginalQvector [pcsr(B  , "IR1_LogLogPlotU")], SlitLengthUnif)
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
	if(cmpstr(ctrlName,"GetHelp")==0)
		//Open www manual with the right page
		IN2G_OpenWebManual("Irena/UnifiedFit.html")
	endif
	if(cmpstr(ctrlName,"GetWiki")==0)
		//Open wikipedia with the right page
		BrowseURL "https://en.wikipedia.org/wiki/Unified_scattering_function"
	endif

	if(cmpstr(ctrlName,"CopyMoveLevel")==0)
		 IR1A_CopySwapUnifiedLevel()
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

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit
		NVAR UseIndra2Data=root:Packages:Irena_UnifFit:UseIndra2Data
		NVAR UseQRSData=root:Packages:Irena_UnifFit:UseQRSdata
		NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
		SVAR IntDf=root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QDf=root:Packages:Irena_UnifFit:QWaveName
		SVAR EDf=root:Packages:Irena_UnifFit:ErrorWaveName
		SVAR Dtf=root:Packages:Irena_UnifFit:DataFolderName
	
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
Function IR1A_CopySwapUnifiedLevel()
	//this function swaps current Unified level to another level. 
	//figrue out which level user has at the top...
	
	ControlInfo /W=IR1A_ControlPanel  DistTabs
	variable CurrentLevel=V_Value+1
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	string MoveToLevel=""
	string SwapLevels=""
	string ListOfLevels="1;2;3;4;5"
	ListOfLevels=RemoveFromList(num2str(CurrentLevel), ListOfLevels)
	string YesNoList="No;Yes"
	Prompt MoveToLevel, "Target level", popup, ListOfLevels
	Prompt SwapLevels, "Swap?", popup, YesNoList
	DoPrompt "Select where to; move or swap", MoveToLevel, SwapLevels
	if (V_Flag)
		return 0									// user canceled
	endif
	variable MoveToLevelNum=str2num(MoveToLevel)
	if(NumberOfLevels<MoveToLevelNum)
		NumberOfLevels = MoveToLevelNum
	endif
	//print MoveToLevel, SwapLevels
	//find all values we will be changing...
	NVAR LevelOldCorelations=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"Corelations")
	NVAR LevelOldFitRg			=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"FitRg")
	NVAR LevelOldFitG			=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"FitG")
	NVAR LevelOldFitP			=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"FitP")
	NVAR LevelOldFitB			=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"FitB")
	NVAR LevelOldFitEta		=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"FitEta")
	NVAR LevelOldFitPack		=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"FitPack")
	NVAR LevelOldMassFractal	=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"MassFractal")
	NVAR LevelOldLinkRGCO		=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"LinkRGCO")
	NVAR LevelOldLinkB			=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"LinkB")

	NVAR LevelOldRg			=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"Rg")
	NVAR LevelOldG			=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"G")
	NVAR LevelOldP			=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"P")
	NVAR LevelOldB			=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"B")
	NVAR LevelOldEta		=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"Eta")
	NVAR LevelOldPack		=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"Pack")
	NVAR LevelOldRGCO		=$("root:Packages:Irena_UnifFit:Level"+num2str(CurrentLevel)+"RGCO")

	NVAR LevelNewCorelations=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"Corelations")
	NVAR LevelNewFitRg			=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"FitRg")
	NVAR LevelNewFitG			=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"FitG")
	NVAR LevelNewFitP			=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"FitP")
	NVAR LevelNewFitB			=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"FitB")
	NVAR LevelNewFitEta		=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"FitEta")
	NVAR LevelNewFitPack		=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"FitPack")
	NVAR LevelNewMassFractal	=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"MassFractal")
	NVAR LevelNewLinkRGCO		=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"LinkRGCO")
	NVAR LevelNewLinkB			=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"LinkB")

	NVAR LevelNewRg			=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"Rg")
	NVAR LevelNewG			=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"G")
	NVAR LevelNewP			=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"P")
	NVAR LevelNewB			=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"B")
	NVAR LevelNewEta		=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"Eta")
	NVAR LevelNewPack		=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"Pack")
	NVAR LevelNewRGCO		=$("root:Packages:Irena_UnifFit:Level"+num2str(MoveToLevelNum)+"RGCO")
	
	variable tmpCorel, tmpFitRg, tmpFitG, tmpFitP, tmpFitB, tmpFitETA, tmpFitPack, tmpLinkB
	variable tmpMassFrac, tmpLinkRGCO, tmpRg, tmpG, tmpP, tmpB, tmpEta, tmpPack, tmpRGCO
	if(stringmatch(SwapLevels,"Yes"))			//user wants to swap the levels, needto store old values to return them later...
		tmpCorel			=		LevelNewCorelations
		tmpFitRg			=		LevelNewFitRg
		tmpFitG			=		LevelNewFitG
		tmpFitP			=		LevelNewFitP
		tmpFitB			=		LevelNewFitB
		tmpFitETA			=		LevelNewFitEta
		tmpFitPack		=		LevelNewFitPack
		tmpMassFrac		=		LevelNewMassFractal
		tmpLinkRGCO		=		LevelNewLinkRGCO
		tmpLinkB			=		LevelNewLinkB
		tmpRg				=		LevelNewRg
		tmpG				=		LevelNewG
		tmpP				=		LevelNewP
		tmpB				=		LevelNewB
		tmpEta			=		LevelNewEta
		tmpPack			=		LevelNewPack
		tmpRGCO			=		LevelNewRGCO
	endif
	 LevelNewCorelations = 	LevelOldCorelations
	 LevelNewFitRg			=	LevelOldFitRg
	 LevelNewFitG			=	LevelOldFitG
	 LevelNewFitP			=	LevelOldFitP
	 LevelNewFitB			=	LevelOldFitB
	 LevelNewFitEta			=	LevelOldFitEta
	 LevelNewFitPack		=	LevelOldFitPack
	 LevelNewMassFractal	=	LevelOldMassFractal
	 LevelNewLinkRGCO		=	LevelOldLinkRGCO
	 LevelNewLinkB			=	LevelOldLinkB
	 LevelNewRg				=	LevelOldRg
	 LevelNewG				=	LevelOldG
	 LevelNewP				=	LevelOldP
	 LevelNewB				=	LevelOldB
	 LevelNewEta				=	LevelOldEta
	 LevelNewPack			=	LevelOldPack
	 LevelNewRGCO			=	LevelOldRGCO
	
	if(stringmatch(SwapLevels,"Yes"))			//user wants to swap the levels, needto store old values to return them later...
		LevelOldCorelations = tmpCorel					
		LevelOldFitRg = tmpFitRg					
		LevelOldFitG = tmpFitG				
		LevelOldFitP = tmpFitP					
		LevelOldFitB = tmpFitB					
		LevelOldFitEta = tmpFitETA					
		LevelOldFitPack = tmpFitPack			
		LevelOldMassFractal = tmpMassFrac			
		LevelOldLinkRGCO = tmpLinkRGCO				
		LevelOldLinkB = tmpLinkB					
		LevelOldRg = tmpRg						
		LevelOldG = tmpG					
		LevelOldP = tmpP					
		LevelOldB = tmpB					
		LevelOldEta= tmpEta				
		LevelOldPack = tmpPack				
		LevelOldRGCO = tmpRGCO		
	else		//reset the level to default state
		LevelOldCorelations = 0					
		LevelOldFitRg = 0					
		LevelOldFitG = 0				
		LevelOldFitP = 0					
		LevelOldFitB = 0					
		LevelOldFitEta = 0					
		LevelOldFitPack = 0			
		LevelOldMassFractal = 0			
		LevelOldLinkRGCO = 0				
		LevelOldLinkB = 0					
		LevelOldRg = 100						
		LevelOldG = 100					
		LevelOldP = 0.01					
		LevelOldB = 4					
		LevelOldEta= 100				
		LevelOldPack = 2.5				
		LevelOldRGCO = 0		
	endif
	
	IR1A_CorrectLimitsAndValues()
	IR1A_FixLimits()
	IR1A_TabPanelControl("DistTabs",MoveToLevelNum-1)
	PopupMenu NumberOfLevels win=IR1A_ControlPanel, mode=(MoveToLevelNum-1)
	IR1A_FixTabsInPanel()
	IR1A_AutoUpdateIfSelected()
	
	
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_AutoUpdateIfSelected()
	
	NVAR UpdateAutomatically=root:Packages:Irena_UnifFit:UpdateAutomatically
	if (UpdateAutomatically)
		IR1A_GraphModelData()
//		NVAR ActTab=root:Packages:Irena_UnifFit:ActiveTab
//		IR1A_DisplayLocalFits(ActTab, 0)
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
	if(numtype(ActTab)!=0)
		ActTab = 1
	endif
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
		NVAR Nmbdist=root:Packages:Irena_UnifFit:NumberOfLevels
		ControlInfo/W=IR1A_ControlPanel DistTabs
		if(V_Value<Nmbdist)		//tab with active level)
			variable selectedTab = (V_Value+1)
			//variable DisplayMe=(1-IR1A_CheckOneUnifiedLevel(selectedTab,0))
			TitleBox PhysValidityWarning, win=IR1A_ControlPanel, disable=(IR1A_CheckOneUnifiedLevel(selectedTab,0)!=0)
		else
			TitleBox PhysValidityWarning, win=IR1A_ControlPanel, disable=1		//just hide this, no info needed. 
		endif
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
	//print "Difference is : (Difference)
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

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit
	
	Wave Intensity=root:Packages:Irena_UnifFit:UnifiedFitIntensity
	Wave QVec=root:Packages:Irena_UnifFit:UnifiedFitQvector
	Wave IQ4=root:Packages:Irena_UnifFit:UnifiedIQ4
	Wave/Z NormalizedError=root:Packages:Irena_UnifFit:NormalizedError
	Wave/Z NormErrorQvec=root:Packages:Irena_UnifFit:NormErrorQvec
	
//	DoWindow/F IR1_LogLogPlotU
	variable CsrAPos
	if (strlen(CsrWave(A,"IR1_LogLogPlotU"))!=0)
		CsrAPos=pcsr(A,"IR1_LogLogPlotU")
	else
		CsrAPos=0
	endif
	variable CsrBPos
	if (strlen(CsrWave(B,"IR1_LogLogPlotU"))!=0)
		CsrBPos=pcsr(B,"IR1_LogLogPlotU")
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
	Wave OriginalIntensity
	
	Label/W=IR1_LogLogPlotU left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity ["+IN2G_ReturnUnitsForYAxis(OriginalIntensity)+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
	Label/W=IR1_LogLogPlotU bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
	ErrorBars/Y=1/W=IR1_LogLogPlotU OriginalIntensity Y,wave=(root:Packages:Irena_UnifFit:OriginalError,root:Packages:Irena_UnifFit:OriginalError)
	Legend/W=IR1_LogLogPlotU/N=text0/K
	Legend/W=IR1_LogLogPlotU/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 "\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+Folder+WvName+"\r"+"\\s(OriginalIntensity) Experimental intensity"
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
	Legend/W=IR1_IQ4_Q_PlotU/N=text0/J/F=0/A=MC/X=-29.74/Y=37.76 "\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+Folder+WvName+"\r"+"\\s(OriginalIntQ4) Experimental intensity * Q^4"
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
	
	LogLogTag="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"Unified Fit for level "+num2str(Lnmb)+"\r"
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
	DoWIndow IR1_LogLogPlotU
	if(V_Flag)
		Tag/W=IR1_LogLogPlotU/C/N=$(tagname)/F=2/L=2/M OriginalIntensity, AttachPointNum, LogLogTag
	endif
	
	DoWIndow IR1_IQ4_Q_PlotU
	if(V_Flag)
		Tag/W=IR1_IQ4_Q_PlotU/C/N=$(tagname)/F=2/L=2/M OriginalIntQ4, AttachPointNum, IQ4Tag
	endif
	
	
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

