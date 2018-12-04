#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.23
Constant IR1AversionNumber=2.23


//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

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
	
	string oldDf=GetDataFolder(1)
	
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

	string OldDf=getDataFolder(1)
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
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,396,720)/N=IR1A_ControlPanel as "Unified fit"
	DefaultGUIControls /W=IR1A_ControlPanel ///Mac os9
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("Irena_UnifFit","IR1A_ControlPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 1,1)

	SetVariable RebinDataTo,limits={0,1000,0},variable= root:Packages:Irena_UnifFit:RebinDataTo, noproc
	SetVariable RebinDataTo,pos={290,130},size={100,15},title="Rebin to:", help={"To rebin data on import, set to integer number. 0 means no rebinning. "}
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

	Button GetHelp,pos={305,105},size={80,15},fColor=(65535,32768,32768), proc=IR1A_InputPanelButtonProc,title="Get Help", help={"Open www manual page for this tool"}

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
	Button LevelXFitRgAndG,pos={230,318},size={130,20}, proc=IR1A_InputPanelButtonProc,title="Fit Rg/G bwtn cursors", help={"Do local fit of Gunier dependence between the cursors amd put resulting values into the Rg and G fields"}
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
	SetVariable Level1G,limits={0,inf,0.05*Level1G},value= root:Packages:Irena_UnifFit:Level1G, help={"Gunier prefactor"}
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
	CheckBox Level1LinkRGCO,pos={160,455},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link RGCO"
	CheckBox Level1LinkRGCO,variable= root:Packages:Irena_UnifFit:Level1LinkRgCo, help={"Link the RgCO to lower level and fit at the same time?"}

	PopupMenu Level1KFactor,pos={230,450},size={170,21},proc=IR1A_PanelPopupControl,title="k factor :"
	PopupMenu Level1KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}

	CheckBox Level1Corelations,pos={90,480},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this correlated system? "
	CheckBox Level1Corelations,variable= root:Packages:Irena_UnifFit:Level1Corelations, help={"Is there a peak or do you expect Corelations between particles to have importance"}

	SetVariable Level1ETA,pos={14,500},size={180,16},proc=IR1A_PanelSetVarProc,title="ETA    ",bodyWidth=140, format="%0.4g"
	SetVariable Level1ETA,limits={0,inf,0.01*Level1Eta},value= root:Packages:Irena_UnifFit:Level1ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Gunier for multiple order Corelations"}
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
	SetVariable Level2G,limits={0,inf,0.05*Level2G},value= root:Packages:Irena_UnifFit:Level2G, help={"Gunier prefactor"}
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

	//Button Level2FitRgAndG,pos={230,318},size={130,20}, proc=IR1A_InputPanelButtonProc,title="Fit Rg/G bwtn cursors", help={"Do locol fit of Gunier dependence between the cursors amd put resulting values into the Rg and G fields"}

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
	CheckBox Level2LinkRGCO,pos={160,455},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link RGCO"
	CheckBox Level2LinkRGCO,variable= root:Packages:Irena_UnifFit:Level2LinkRgCo, help={"Link the RgCO to lower level and fit at the same time?"}

	PopupMenu Level2KFactor,pos={230,450},size={170,21},proc=IR1A_PanelPopupControl,title="k factor :"
	PopupMenu Level2KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}

	CheckBox Level2Corelations,pos={90,480},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this correlated system? "
	CheckBox Level2Corelations,variable= root:Packages:Irena_UnifFit:Level2Corelations, help={"Is there a peak or do you expect Corelations between particles to have importance"}

	SetVariable Level2ETA,pos={14,500},size={180,16},proc=IR1A_PanelSetVarProc,title="ETA    ",bodyWidth=140, format="%0.4g"
	SetVariable Level2ETA,limits={0,inf,0.01*Level2Eta},value= root:Packages:Irena_UnifFit:Level2ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Gunier for multiple order Corelations"}
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
	SetVariable Level3G,limits={0,inf,0.05*Level3G},value= root:Packages:Irena_UnifFit:Level3G, help={"Gunier prefactor"}
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

	//Button Level3FitRgAndG,pos={230,318},size={130,20}, proc=IR1A_InputPanelButtonProc,title="Fit Rg/G bwtn cursors", help={"Do locol fit of Gunier dependence between the cursors amd put resulting values into the Rg and G fields"}

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
	CheckBox Level3LinkRGCO,pos={160,455},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link RGCO"
	CheckBox Level3LinkRGCO,variable= root:Packages:Irena_UnifFit:Level3LinkRgCo, help={"Link the RgCO to lower level and fit at the same time?"}

	PopupMenu Level3KFactor,pos={230,450},size={170,21},proc=IR1A_PanelPopupControl,title="k factor :"
	PopupMenu Level3KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}

	CheckBox Level3Corelations,pos={90,480},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this correlated system? "
	CheckBox Level3Corelations,variable= root:Packages:Irena_UnifFit:Level3Corelations, help={"Is there a peak or do you expect Corelations between particles to have importance"}

	SetVariable Level3ETA,pos={14,500},size={180,16},proc=IR1A_PanelSetVarProc,title="ETA    ",bodyWidth=140, format="%0.4g"
	SetVariable Level3ETA,limits={0,inf,0.01*Level3Eta},value= root:Packages:Irena_UnifFit:Level3ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Gunier for multiple order Corelations"}
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
	SetVariable Level4G,limits={0,inf,0.05*Level4G},value= root:Packages:Irena_UnifFit:Level4G, help={"Gunier prefactor"}
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

	//Button Level4FitRgAndG,pos={230,318},size={130,20}, proc=IR1A_InputPanelButtonProc,title="Fit Rg/G bwtn cursors", help={"Do local fit of Gunier dependence between the cursors amd put resulting values into the Rg and G fields"}

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
	CheckBox Level4LinkRGCO,pos={160,455},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link RGCO"
	CheckBox Level4LinkRGCO,variable= root:Packages:Irena_UnifFit:Level4LinkRgCo, help={"Link the RgCO to lower level and fit at the same time?"}

	PopupMenu Level4KFactor,pos={230,450},size={170,21},proc=IR1A_PanelPopupControl,title="k factor :"
	PopupMenu Level4KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}

	CheckBox Level4Corelations,pos={90,480},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this correlated system? "
	CheckBox Level4Corelations,variable= root:Packages:Irena_UnifFit:Level4Corelations, help={"Is there a peak or do you expect Corelations between particles to have importance"}

	SetVariable Level4ETA,pos={14,500},size={180,16},proc=IR1A_PanelSetVarProc,title="ETA    ",bodyWidth=140, format="%0.4g"
	SetVariable Level4ETA,limits={0,inf,0.05*Level4Eta},value= root:Packages:Irena_UnifFit:Level4ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Gunier for multiple order Corelations"}
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
	SetVariable Level5G,limits={0,inf,0.05*Level5G},value= root:Packages:Irena_UnifFit:Level5G, help={"Gunier prefactor"}
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

	//Button Level5FitRgAndG,pos={230,318},size={130,20}, proc=IR1A_InputPanelButtonProc,title="Fit Rg/G bwtn cursors", help={"Do local fit of Gunier dependence between the cursors amd put resulting values into the Rg and G fields"}

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
	CheckBox Level5LinkRGCO,pos={160,455},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link RGCO"
	CheckBox Level5LinkRGCO,variable= root:Packages:Irena_UnifFit:Level5LinkRgCo, help={"Link the RgCO to lower level and fit at the same time?"}

	PopupMenu Level5KFactor,pos={230,450},size={170,21},proc=IR1A_PanelPopupControl,title="k factor :"
	PopupMenu Level5KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}

	CheckBox Level5Corelations,pos={90,480},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this correlated system? "
	CheckBox Level5Corelations,variable= root:Packages:Irena_UnifFit:Level5Corelations, help={"Is there a peak or do you expect Corelations between particles to have importance"}

	SetVariable Level5ETA,pos={14,500},size={180,16},proc=IR1A_PanelSetVarProc,title="ETA    ",bodyWidth=140, format="%0.4g"
	SetVariable Level5ETA,limits={0,inf,0.05*Level5Eta},value= root:Packages:Irena_UnifFit:Level5ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Gunier for multiple order Corelations"}
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

	string oldDf=GetDataFolder(1)
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

