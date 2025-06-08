#pragma rtGlobals=3 // Use modern global access method.
#pragma version=1.34

Constant IR2LversionNumber = 1.25

//*************************************************************************\
//* Copyright (c) 2005 - 2025, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution.
//*************************************************************************/

//1.34 fix GenCurveFit call, which was failing due to Exists("gencurvefit") returning 4 instead of 3 which was in the code.
//1.33 add Disk as form factor for size distribution.
//1.32 add Unified Fit Form Factor to MassFractals.
//1.31 added ability to save individual pop data when running from Scripting tool. COnverted to rtGlobals=3, which may cause some issues...
//1.30 Combined together with IR2L_NLSQFfunctions
//1.25 mofied min number of Num points to 6, G matrix breask when less...
//1.24 added Rg for Size distributions and this requirtes reinitialization
//1.23 added Ardell distributions support
//1.22 Modified Screen Size check to match the needs
//1.21 added getHelp button calling to www manual
//1.20 GUI controls move change
//1.19 chanegs for panel scaling.
//1.18 bug fixes and modifications to Other graph outputs - colorization etc.
//1.17 added checkboxes for displaying Size distributions, Residuals and IQ4 vs Q graphs and code shupporting it.
//1.16 added Fractals as models.
//1.15 added User Name for each population - when displayed Indiv. Pops. - to dispay in the graph, so user can make it easier to read.
//1.14 added check to chatch for slit smeared data when Qmax is too small, require at least 3* slit length
//1.13 modified to handle Intensity units and propagated through GUI and data export.
//1.12 added to Unified levels ability to link B to G/Rg/P values. Removed ability to fit RgCO.
//		Added option to rebin the data on import.
//1.11 Added change the tab names, noFittingLimits support and changed GUI for SD to gain space.
//1.10 changed back to rtGlobals=2, need to check code much more to make it 3
//        changes terms for storing data back to folder. Previously used Save, which confused users...
//1.09 added form and structure factor description as Igor help file with the buttons from the panel directly.
//1.08 added scroll buttons to move content up down for small displays.
//1.07 removed all font and font size from panel definitions to enable user control
//1.06 added init of FormFactors, why it was not there yet?
//1.05 aqdded Scripting tool button
//1.04 added ability to remove points from data if needed by using RemovePntwCsrA
//1.03 modified to handle Unified fit and Diffraction peak as separate tools, change number of models to 10
//1.02 added Unified level as Form factor
//1.01 added license for ANL

//original IR2L_NLSQFfunctions.ipf comments:
//1.29 added check for errors = 0
//1.28 fix bug with Ardell Parameters which were incorrectly named in one place which resulted in runtime error.
//1.27 modified graph size control to use IN2G_GetGraphWidthHeight and associated settings. Should work on various display sizes.
//1.26 added Ardell distributions support
//1.25 modified fitting to include Igor display with iterations /N=0/W=0
//1.24 fix save single Contrast even when user left SameContrastForDataSets=1 but is using just one data set
//1.23 fix error message when using model as data
//1.22 catch if user is loading negative, 0 , Nan, or inf value uncertainities and force use of % errors in that case.
//1.21 added catch for change of LNmin which will be chaned to 3A diameter (1.5A radius) with user warning, when restoring old number (0).
//1.20 minor bug fix for parameter6 of form factor

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_Main()
	//initialize, as usually
	IR2L_Initialize()
	IR1T_InitFormFactors()
	IR1_CreateLoggbook()
	IR2S_InitStructureFactors()
	IR2L_SetInitialValues(1)
	//we need the following also inited
	IN2G_InitConfigMain()
	IR1T_InitFormFactors()
	//check for panel if exists - pull up, if not create
	DoWindow LSQF2_MainPanel
	if(V_Flag)
		DoWindow/F LSQF2_MainPanel
	else
		IN2G_CheckScreenSize("height", 690)
		IR2L_MainPanel()
		ING2_AddScrollControl()
		IR1_UpdatePanelVersionNumber("LSQF2_MainPanel", IR2LversionNumber, 1)
	endif
	IR2L_RecalculateIfSelected()
	DoWindow IR2L_ResSmearingPanel
	if(V_Flag)
		DoWindow/F IR2L_ResSmearingPanel
	endif
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_MainCheckVersion()
	DoWindow LSQF2_MainPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("LSQF2_MainPanel", IR2LversionNumber))
			DoAlert/T="The Modeling panel was created by incorrect version of Irena " 1, "Modeling may need to be restarted to work properly. Restart now?"
			if(V_flag == 1)
				KillWIndow/Z LSQF2_MainPanel
				IR2L_Main()
			else //at least reinitialize the variables so we avoid major crashes...
				IR2L_Initialize()
				IR2S_InitStructureFactors()
			endif
		endif
	endif
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_MainPanel()
	//PauseUpdate    		// building window...
	NewPanel/K=1/W=(3, 42, 410, 730) as "Modeling main panel"
	DoWindow/C LSQF2_MainPanel
	//DefaultGUIControls /W=LSQF2_MainPanel /Mac native

	string AllowedIrenaTypes = "DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;"
	IR2C_AddDataControls("IR2L_NLSQF", "LSQF2_MainPanel", AllowedIrenaTypes, "", "", "", "", "", 0, 1)
	CheckBox QLogScale, pos={100, 131}
	TitleBox MainTitle, title="\Zr190Modeling", pos={100, 0}, frame=0, fstyle=3, fixedSize=1, font="Times New Roman", size={200, 24}, anchor=MC, fColor=(0, 0, 52224)

	SetVariable RebinDataTo, limits={0, 1000, 0}, variable=root:Packages:IR2L_NLSQF:RebinDataTo, noproc
	SetVariable RebinDataTo, pos={290, 130}, size={110, 15}, title="Rebin to:", help={"To rebin data on import, set to integer number. 0 means no rebinning. "}

	TitleBox FakeLine1, title=" ", fixedSize=1, size={270, 3}, pos={16, 184}, frame=0, fColor=(0, 0, 52224), labelBack=(0, 0, 52224)
	TitleBox Info1, title="\Zr120Data input", pos={10, 30}, frame=0, fstyle=1, fixedSize=1, size={80, 20}, fColor=(0, 0, 52224)

	Button RemoveAllDataSets, pos={5, 148}, size={90, 18}, proc=IR2L_InputPanelButtonProc, title="Remove all", help={"Remove all data from tool"}
	Button UnuseAllDataSets, pos={100, 148}, size={90, 18}, proc=IR2L_InputPanelButtonProc, title="unUse all", help={"Set all data set to not Use"}
	Button ConfigureGraph, pos={195, 148}, size={90, 18}, proc=IR2L_InputPanelButtonProc, title="Config Graph", help={"Set parameters for graph"}
	Button ReGraph, pos={290, 148}, size={90, 18}, proc=IR2L_InputPanelButtonProc, title="Graph (ReGraph)", help={"Create or Recreate graph"}
	Button ScriptingTool, pos={290, 168}, size={90, 18}, proc=IR2L_InputPanelButtonProc, title="Scripting tool", help={"Open Scripting tool to analyze multipel data sets subsequently"}
	Button MoreSDParameters, pos={5, 167}, size={140, 18}, proc=IR2L_InputPanelButtonProc, title="More parameters", help={"Get panel with more parameters parameters"}, valueColor=(65535, 0, 0)
	Button GetHelp, pos={305, 105}, size={80, 15}, fColor=(65535, 32768, 32768), proc=IR2L_InputPanelButtonProc, title="Get Help", help={"Open www manual page for this tool"}

	CheckBox DisplayInputDataControls, pos={10, 188}, size={25, 16}, proc=IR2L_DataTabCheckboxProc, title="Data cntrls", mode=1
	CheckBox DisplayInputDataControls, variable=root:Packages:IR2L_NLSQF:DisplayInputDataControls, help={"Select to get data controls"}
	CheckBox DisplayModelControls, pos={90, 188}, size={25, 16}, proc=IR2L_DataTabCheckboxProc, title="Model cntrls", mode=1
	CheckBox DisplayModelControls, variable=root:Packages:IR2L_NLSQF:DisplayModelControls, help={"Select to get model controls"}
	CheckBox RecalculateAutomatically, pos={300, 188}, size={25, 90}, proc=IR2L_DataTabCheckboxProc, title="Auto Recalculate?"
	CheckBox RecalculateAutomatically, variable=root:Packages:IR2L_NLSQF:RecalculateAutomatically, help={"Check to have everything recalculate when change is made. SLOW!"}

	CheckBox MultipleInputData, pos={10, 203}, size={25, 90}, proc=IR2L_DataTabCheckboxProc, title="Multiple Input Data sets?"
	CheckBox MultipleInputData, variable=root:Packages:IR2L_NLSQF:MultipleInputData, help={"Do you want to use multiple input data sets in this tool?"}
	CheckBox NoFittingLimits, pos={300, 203}, size={25, 90}, proc=IR2L_DataTabCheckboxProc, title="No Fitting Limits?"
	CheckBox NoFittingLimits, variable=root:Packages:IR2L_NLSQF:NoFittingLimits, help={"Check to do fitting without fitting limits."}

	CheckBox SameContrastForDataSets, pos={175, 188}, size={25, 16}, proc=IR2L_DataTabCheckboxProc, title="Vary contrasts?"
	CheckBox SameContrastForDataSets, variable=root:Packages:IR2L_NLSQF:SameContrastForDataSets, help={"Check if contrast varies between data sets for one population?"}
	SVAR DataCalibrationUnits = root:Packages:IR2L_NLSQF:DataCalibrationUnits
	SetVariable DataCalibrationUnits, variable=root:Packages:IR2L_NLSQF:DataCalibrationUnits, noedit=1, noproc, frame=0, pos={175, 204}
	SetVariable DataCalibrationUnits, title="Units:", valueColor=(65535, 0, 0), labelBack=0, size={120, 15}, help={"Units for Intensity, change with \"More parameetrs\" button"}
	NVAR DisplayInputDataControls = root:Packages:IR2L_NLSQF:DisplayInputDataControls
	NVAR DisplayModelControls     = root:Packages:IR2L_NLSQF:DisplayModelControls
	NVAR MultipleInputData        = root:Packages:IR2L_NLSQF:MultipleInputData

	//Data Tabs definition
	TabControl DataTabs, pos={1, 220}, size={405, 320}, proc=IR2L_Data_TabPanelControl
	TabControl DataTabs, tabLabel(0)="1.", tabLabel(1)="2."
	TabControl DataTabs, tabLabel(2)="3.", tabLabel(3)="4."
	TabControl DataTabs, tabLabel(4)="5.", tabLabel(5)="6."
	TabControl DataTabs, tabLabel(6)="7.", tabLabel(7)="8."
	TabControl DataTabs, tabLabel(8)="9.", tabLabel(9)="10.", value=0, disable=!DisplayInputDataControls

	//	variable i
	Button AddDataSet, pos={5, 245}, size={80, 16}, proc=IR2L_InputPanelButtonProc, title="Add data", help={"Load data into the tool"}

	CheckBox UseTheData_set, pos={95, 245}, size={25, 16}, proc=IR2L_DataTabCheckboxProc, title="Use?"
	CheckBox UseTheData_set, variable=root:Packages:IR2L_NLSQF:UseTheData_set1, help={"Use the data in the tool?"}
	CheckBox UseSmearing_set, pos={175, 245}, size={25, 16}, proc=IR2L_DataTabCheckboxProc, title="Slit/Q resolution smeared?"
	CheckBox UseSmearing_set, variable=root:Packages:IR2L_NLSQF:UseSmearing_set1, help={"Data smeared by Q resolution (slit/pixel)?"}
	//		SetVariable SlitLength_set,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:SlitLength_set1, proc=IR2L_DataTabSetVarProc
	//		SetVariable SlitLength_set,pos={260,245},size={140,15},title="Slit length [1/A]:", help={"This is slit length of the set currently loaded."}

	SetVariable FolderName_set, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:FolderName_set1, noedit=1, noproc, frame=0, labelBack=(0, 52224, 0)
	SetVariable FolderName_set, pos={5, 265}, size={395, 15}, title="Data:", help={"This is data set currently loaded in this data set."}
	SetVariable UserDataSetName_set, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:UserDataSetName_set1, proc=IR2L_DataTabSetVarProc
	SetVariable UserDataSetName_set, pos={5, 285}, size={395, 15}, title="User Name:", help={"This is data set currently loaded in this data set."}

	//	ListOfDataVariables+="DataScalingFactor;ErrorScalingFactor;UseUserErrors;UseSQRTErrors;UsePercentErrors;PercentErrors
	SetVariable DataScalingFactor_set, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:DataScalingFactor_set1, proc=IR2L_DataTabSetVarProc
	SetVariable DataScalingFactor_set, pos={10, 305}, size={150, 15}, title="Scale data by:", help={"Value to scale data set"}
	CheckBox UseUserErrors_set, pos={10, 325}, size={25, 16}, proc=IR2L_DataTabCheckboxProc, title="User errors?", mode=1
	CheckBox UseUserErrors_set, variable=root:Packages:IR2L_NLSQF:UseUserErrors_set1, help={"Use user errors (if input)?"}
	CheckBox UseSQRTErrors_set, pos={100, 325}, size={25, 16}, proc=IR2L_DataTabCheckboxProc, title="SQRT errors?", mode=1
	CheckBox UseSQRTErrors_set, variable=root:Packages:IR2L_NLSQF:UseSQRTErrors_set1, help={"Use square root of intensity errors?"}
	CheckBox UsePercentErrors_set, pos={200, 325}, size={25, 16}, proc=IR2L_DataTabCheckboxProc, title="User % errors?", mode=1
	CheckBox UsePercentErrors_set, variable=root:Packages:IR2L_NLSQF:UsePercentErrors_set1, help={"Use errors equal to % of intensity?"}
	SetVariable ErrorScalingFactor_set, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:ErrorScalingFactor_set1, proc=IR2L_DataTabSetVarProc
	SetVariable ErrorScalingFactor_set, pos={10, 345}, size={150, 15}, title="Scale errors by:", help={"Value to scale errors by"}

	SetVariable Qmin_set, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:Qmin_set1, proc=IR2L_DataTabSetVarProc
	SetVariable Qmin_set, pos={10, 370}, size={100, 15}, title="Q min:", help={"This is Q min selected for this data set for fitting."}
	SetVariable Qmax_set, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:Qmax_set1, proc=IR2L_DataTabSetVarProc
	SetVariable Qmax_set, pos={140, 370}, size={100, 15}, title="Q max:", help={"This is Q max selected for this data set for fitting."}
	Button ReadCursors, pos={285, 369}, size={80, 16}, proc=IR2L_InputPanelButtonProc, title="Q from cursors", help={"Read cursors positon into the Q range for fitting"}

	SetVariable Background, limits={-Inf, Inf, 1}, variable=root:Packages:IR2L_NLSQF:Background_set1, proc=IR2L_DataTabSetVarProc
	SetVariable Background, pos={5, 420}, size={120, 15}, title="Bckg:", help={"Flat background for this data set"}
	CheckBox BackgroundFit_set, pos={150, 420}, size={25, 14}, proc=IR2L_DataTabCheckboxProc, title="Fit?"
	CheckBox BackgroundFit_set, variable=root:Packages:IR2L_NLSQF:BackgroundFit_set1, help={"Fit the background?"}
	SetVariable BackgroundMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:BackgroundMin_set1, noproc
	SetVariable BackgroundMin, pos={220, 420}, size={80, 15}, title="Min:", help={"Fitting range for background, minimum"}
	SetVariable BackgroundMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:BackgroundMax_set1, noproc
	SetVariable BackgroundMax, pos={310, 420}, size={80, 15}, title="Max:", help={"Fitting range for background, maxcimum set"}

	Button RemovePointWcsrA, pos={5, 450}, size={150, 16}, proc=IR2L_InputPanelButtonProc, title="Remove pnt w/csrA", help={"Set cursor A and use this to remove points"}

	//		SetVariable BackgStep_set,limits={0,Inf,1},variable= root:Packages:IR2L_NLSQF:BackgStep_set1, proc=IR2L_DataTabSetVarProc
	//		SetVariable BackgStep_set,pos={15,440},size={120,15},title="Step:", help={"Flat background for this data set"}
	IR2L_Data_TabPanelControl("", 0)
	//Confing ASAXS or SAXS part here

	SVAR PanelVolumeDesignation = root:Packages:IR2L_NLSQF:PanelVolumeDesignation
	//Dist Tabs definition
	TabControl DistTabs, pos={1, 220}, size={405, 380}, proc=IR2L_Model_TabPanelControl
	TabControl DistTabs, tabLabel(0)="1 P", tabLabel(1)="2 P"
	TabControl DistTabs, tabLabel(2)="3 P", tabLabel(3)="4 P"
	TabControl DistTabs, tabLabel(4)="5 P", tabLabel(5)="6 P"
	TabControl DistTabs, tabLabel(6)="7 P", tabLabel(7)="8 P"
	TabControl DistTabs, tabLabel(8)="9 P", tabLabel(9)="10 P", value=0, disable=!DisplayModelControls

	CheckBox UseThePop, pos={4, 241}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Use?", fstyle=1
	CheckBox UseThePop, variable=root:Packages:IR2L_NLSQF:UseThePop_pop1, help={"Use the population in calculations?"}

	SetVariable UserName, variable=root:Packages:IR2L_NLSQF:UserName_pop1, proc=IR2L_PopSetVarProc
	SetVariable UserName, pos={170, 241}, size={230, 10}, title="What is this?:", help={"User name for this population. What is this?"}

	PopupMenu PopulationType, title="Model : ", proc=IR2L_PanelPopupControl, pos={5, 254}
	PopupMenu PopulationType, mode=1, value="Size dist.;Unified level;Diffraction Peak;MassFractal;SurfaceFractal;"
	PopupMenu PopulationType, help={"Select Model to be used for this population"}

	CheckBox RdistAuto, pos={180, 257}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="R dist auto?", mode=1
	CheckBox RdistAuto, variable=root:Packages:IR2L_NLSQF:RdistAuto_pop1, help={"Use automatic method to determin Rmin and Rmax?"}
	CheckBox RdistrSemiAuto, pos={260, 257}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Semi-auto?", mode=1
	CheckBox RdistrSemiAuto, variable=root:Packages:IR2L_NLSQF:RdistrSemiAuto_pop1, help={"Use automatic method for Rmin R max except in fitting?"}
	CheckBox RdistMan, pos={340, 257}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Manual?", mode=1
	CheckBox RdistMan, variable=root:Packages:IR2L_NLSQF:RdistMan_pop1, help={"Manually set Rmin R max?"}

	SetVariable RdistNumPnts, limits={6, Inf, 0}, variable=root:Packages:IR2L_NLSQF:RdistNumPnts_pop1, proc=IR2L_PopSetVarProc
	SetVariable RdistNumPnts, pos={5, 275}, size={110, 15}, title="Num pnts:", help={"Number of points in the population"}
	SetVariable RdistManMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:RdistManMin_pop1, noproc
	SetVariable RdistManMin, pos={140, 275}, size={100, 15}, title="R min:", help={"This is R min selected for this population"}
	SetVariable RdistManMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:RdistManMax_pop1, noproc
	SetVariable RdistManMax, pos={260, 275}, size={100, 15}, title="R max:", help={"This is R max selected for this population"}

	SetVariable RdistNeglectTails, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:RdistNeglectTails_pop1, proc=IR2L_PopSetVarProc
	SetVariable RdistNeglectTails, pos={140, 275}, size={180, 15}, title="R dist neglect tails:", help={"What fraction of population to neglect, see manual, 0.01 is good"}

	CheckBox RdistLog, pos={10, 295}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Log R dist?"
	CheckBox RdistLog, variable=root:Packages:IR2L_NLSQF:RdistLog_pop1, help={"Use Log binning for R distribution?"}
	//	SVAR ListOfFormFactors=root:Packages:FormFactorCalc:ListOfFormFactors
	PopupMenu FormFactorPop, title="Form Factor : ", proc=IR2L_PanelPopupControl, pos={10, 315}
	PopupMenu FormFactorPop, mode=1, value=#"(root:Packages:FormFactorCalc:ListOfFormFactors)"
	PopupMenu FormFactorPop, help={"Select form factor to be used for this population of scatterers"}

	SetVariable SizeDist_DimensionType, variable=root:Packages:IR2L_NLSQF:SizeDist_DimensionType, noproc, disable=0, frame=0, valueColor=(39321, 1, 1), noedit=1
	SetVariable SizeDist_DimensionType, pos={100, 335}, size={300, 15}, title="Size Dist.  is : ", help={"Is SD using Number/Volume distribution and diameters or radia? "}
	SetVariable SizeDist_DimensionType, fstyle=3, fColor=(52428, 1, 1)

	PopupMenu PopSizeDistShape, title="Distribution type : ", proc=IR2L_PanelPopupControl, pos={190, 295}
	PopupMenu PopSizeDistShape, mode=1, value="LogNormal;Gauss;LSW;Schulz-Zimm;Ardell;"
	PopupMenu PopSizeDistShape, help={"Select Distribution type for this population"}

	Button GetFFHelp, pos={320, 320}, size={80, 15}, proc=IR2L_InputPanelButtonProc, title="F.F. Help", help={"Get help for Form factors"}
	Button GetSFHelp, pos={320, 468}, size={80, 15}, proc=IR2L_InputPanelButtonProc, title="S.F. Help", help={"Get Help for Structure factor"}

	// Unified controls
	Button FitRgAndG, pos={200, 320}, size={100, 15}, proc=IR2L_InputPanelButtonProc, title="Fit Rg/G bwtn csrs", help={"Do local fit of Guinier dependence between the cursors amd put resulting values into the Rg and G fields"}
	Button FitPandB, pos={301, 320}, size={100, 15}, proc=IR2L_InputPanelButtonProc, title="Fit P/B bwtn csrs", help={"Do local fit of Powerlaw dependence between the cursors amd put resulting values into the Rg and G fields"}

	CheckBox UF_LinkB, pos={20, 328}, size={20, 16}, proc=IR2L_ModelTabCheckboxProc, title="Estimate B from G/Rg/P?"
	CheckBox UF_LinkB, variable=root:Packages:IR2L_NLSQF:UF_LinkB_pop1, help={"Estimate B from G/Rg/B based on Guinier/Porod model?"}

	SetVariable UF_G, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:UF_G_pop1, proc=IR2L_PopSetVarProc
	SetVariable UF_G, pos={8, 355}, size={140, 15}, title="G = ", help={"G for Unified level"}
	CheckBox UF_GFit, pos={155, 355}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox UF_GFit, variable=root:Packages:IR2L_NLSQF:UF_GFit_pop1, help={"Fit the G?"}
	SetVariable UF_GMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:UF_GMin_pop1, noproc
	SetVariable UF_GMin, pos={200, 355}, size={80, 15}, title="Min ", help={"Low limit for G"}
	SetVariable UF_GMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:UF_GMax_pop1, noproc
	SetVariable UF_GMax, pos={290, 355}, size={80, 15}, title="Max ", help={"High limit for G"}

	SetVariable UF_Rg, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:UF_Rg_pop1, proc=IR2L_PopSetVarProc
	SetVariable UF_Rg, pos={8, 375}, size={140, 15}, title="Rg [A]= ", help={"Rg (size)"}
	CheckBox UF_RgFit, pos={155, 375}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox UF_RgFit, variable=root:Packages:IR2L_NLSQF:UF_RgFit_pop1, help={"Fit the Rg?"}
	SetVariable UF_RgMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:UF_RgMin_pop1, noproc
	SetVariable UF_RgMin, pos={200, 375}, size={80, 15}, title="Min ", help={"Low Rg"}
	SetVariable UF_RgMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:UF_RgMax_pop1, noproc
	SetVariable UF_RgMax, pos={290, 375}, size={80, 15}, title="Max ", help={"High Rg"}

	SetVariable UF_B, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:UF_B_pop1, proc=IR2L_PopSetVarProc
	SetVariable UF_B, pos={8, 395}, size={140, 15}, title="B = ", help={"B for UF"}
	CheckBox UF_BFit, pos={155, 395}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox UF_BFit, variable=root:Packages:IR2L_NLSQF:UF_BFit_pop1, help={"Fit the B?"}
	SetVariable UF_BMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:UF_BMin_pop1, noproc
	SetVariable UF_BMin, pos={200, 395}, size={80, 15}, title="Min ", help={"Low limit for B"}
	SetVariable UF_BMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:UF_BMax_pop1, noproc
	SetVariable UF_BMax, pos={290, 395}, size={80, 15}, title="Max ", help={"High limit for B"}

	SetVariable UF_P, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:UF_P_pop1, proc=IR2L_PopSetVarProc
	SetVariable UF_P, pos={8, 415}, size={140, 15}, title="P   = ", help={"P (power law slope)"}
	CheckBox UF_PFit, pos={155, 415}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox UF_PFit, variable=root:Packages:IR2L_NLSQF:UF_PFit_pop1, help={"Fit the P?"}
	SetVariable UF_PMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:UF_PMin_pop1, noproc
	SetVariable UF_PMin, pos={200, 415}, size={80, 15}, title="Min ", help={"Low limit for P"}
	SetVariable UF_PMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:UF_PMax_pop1, noproc
	SetVariable UF_PMax, pos={290, 415}, size={80, 15}, title="Max ", help={"High limit for P"}

	SetVariable UF_RGCO, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:UF_RGCO_pop1, proc=IR2L_PopSetVarProc
	SetVariable UF_RGCO, pos={8, 435}, size={140, 15}, title="Rg cut off = ", help={"Rg cut off for higher Unified levels, see reference or manual for meaning"}
	//		PopupMenu KFactor,pos={220,452},size={170,15},proc=IR2L_PanelPopupControl,title="k factor :"
	//		PopupMenu KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}

	//particulate controls
	SetVariable Volume, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:Volume_pop1, proc=IR2L_PopSetVarProc
	SetVariable Volume, pos={8, 355}, size={140, 15}, title=PanelVolumeDesignation, help={"Volume of this population (fractional, should be between 0 and 1 if contrast and calibrated data)"}
	CheckBox FitVolume, pos={155, 355}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox FitVolume, variable=root:Packages:IR2L_NLSQF:VolumeFit_pop1, help={"Fit the volume?"}
	SetVariable VolumeMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:VolumeMin_pop1, noproc
	SetVariable VolumeMin, pos={200, 355}, size={80, 15}, title="Min ", help={"Low limit for volume"}
	SetVariable VolumeMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:VolumeMax_pop1, noproc
	SetVariable VolumeMax, pos={290, 355}, size={80, 15}, title="Max ", help={"High limit for volume"}

	//	ListOfPopulationVariables+="LNMinSize;LNMinSizeFit;LNMinSizeMin;LNMinSizeMax;LNMeanSize;LNMeanSizeFit;LNMeanSizeMin;LNMeanSizeMax;LNSdeviation;LNSdeviationFit;LNSdeviationMin;LNSdeviationMax;"
	//Log-Normal parameters....
	SetVariable LNMinSize, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:LNMinSize_pop1, proc=IR2L_PopSetVarProc
	SetVariable LNMinSize, pos={8, 375}, size={140, 15}, title="Min size [A]= ", help={"Log-normal distribution min size [A]"}
	CheckBox LNMinSizeFit, pos={155, 375}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox LNMinSizeFit, variable=root:Packages:IR2L_NLSQF:LNMinSizeFit_pop1, help={"Fit the Min size for Log-Normal distribution?"}
	SetVariable LNMinSizeMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:LNMinSizeMin_pop1, noproc
	SetVariable LNMinSizeMin, pos={200, 375}, size={80, 15}, title="Min ", help={"Low limit for min size for Log-normal distribution"}
	SetVariable LNMinSizeMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:LNMinSizeMax_pop1, noproc
	SetVariable LNMinSizeMax, pos={290, 375}, size={80, 15}, title="Max ", help={"High limit for min size for Log-normal distribution"}

	SetVariable LNMeanSize, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:LNMeanSize_pop1, proc=IR2L_PopSetVarProc
	SetVariable LNMeanSize, pos={8, 395}, size={140, 15}, title="Mean [A]= ", help={"Log-normal distribution mean size [A]"}
	CheckBox LNMeanSizeFit, pos={155, 395}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox LNMeanSizeFit, variable=root:Packages:IR2L_NLSQF:LNMeanSizeFit_pop1, help={"Fit the mean size for Log-Normal distribution?"}
	SetVariable LNMeanSizeMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:LNMeanSizeMin_pop1, noproc
	SetVariable LNMeanSizeMin, pos={200, 395}, size={80, 15}, title="Min ", help={"Low limit for mean size for Log-normal distribution"}
	SetVariable LNMeanSizeMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:LNMeanSizeMax_pop1, noproc
	SetVariable LNMeanSizeMax, pos={290, 395}, size={80, 15}, title="Max ", help={"High limit for mean size for Log-normal distribution"}

	SetVariable LNSdeviation, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:LNSdeviation_pop1, proc=IR2L_PopSetVarProc
	SetVariable LNSdeviation, pos={8, 415}, size={140, 15}, title="Std. dev.    = ", help={"Log-normal distribution standard deviation [A]"}
	CheckBox LNSdeviationFit, pos={155, 415}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox LNSdeviationFit, variable=root:Packages:IR2L_NLSQF:LNSdeviationFit_pop1, help={"Fit the standard deviation for Log-Normal distribution?"}
	SetVariable LNSdeviationMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:LNSdeviationMin_pop1, noproc
	SetVariable LNSdeviationMin, pos={200, 415}, size={80, 15}, title="Min ", help={"Low limit for standard deviation for Log-normal distribution"}
	SetVariable LNSdeviationMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:LNSdeviationMax_pop1, noproc
	SetVariable LNSdeviationMax, pos={290, 415}, size={80, 15}, title="Max ", help={"High limit for standard deviation for Log-normal distribution"}
	//	ListOfPopulationVariables+="GMeanSize;GMeanSizeFit;GMeanSizeMin;GMeanSizeMax;GWidth;GWidthFit;GWidthMin;GWidthMax;LSWLocation;LSWLocationFit;LSWLocationMin;LSWLocationMax;"
	//Gauss parameters...
	SetVariable GMeanSize, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:GMeanSize_pop1, proc=IR2L_PopSetVarProc
	SetVariable GMeanSize, pos={8, 375}, size={140, 15}, title="Mean size [A]= ", help={"Gauss mean size [A]"}
	CheckBox GMeanSizeFit, pos={155, 375}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox GMeanSizeFit, variable=root:Packages:IR2L_NLSQF:GMeanSizeFit_pop1, help={"Fit the mean size for gaussian distribution?"}
	SetVariable GMeanSizeMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:GMeanSizeMin_pop1, noproc
	SetVariable GMeanSizeMin, pos={200, 375}, size={80, 15}, title="Min ", help={"Low limit for mean size for Gaussian distribution"}
	SetVariable GMeanSizeMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:GMeanSizeMax_pop1, noproc
	SetVariable GMeanSizeMax, pos={290, 375}, size={80, 15}, title="Max ", help={"High limit for mean size for Gaussian distribution"}

	SetVariable GWidth, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:GWidth_pop1, proc=IR2L_PopSetVarProc
	SetVariable GWidth, pos={8, 395}, size={140, 15}, title="Std. dev. [A]= ", help={"Gaussian Std. dev. of size [A]"}
	CheckBox GWidthFit, pos={155, 395}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox GWidthFit, variable=root:Packages:IR2L_NLSQF:GWidthFit_pop1, help={"Fit the width for Gaussian distribution?"}
	SetVariable GWidthMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:GWidthMin_pop1, noproc
	SetVariable GWidthMin, pos={200, 395}, size={80, 15}, title="Min ", help={"Low limit for width for Gaussian distribution"}
	SetVariable GWidthMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:GWidthMax_pop1, noproc
	SetVariable GWidthMax, pos={290, 395}, size={80, 15}, title="Max ", help={"High limit for width for Gaussian distribution"}
	//SZ parameters...
	SetVariable SZMeanSize, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:SZMeanSize_pop1, proc=IR2L_PopSetVarProc
	SetVariable SZMeanSize, pos={8, 375}, size={140, 15}, title="Mean size [A]= ", help={"Schulz-Zimm mean size [A]"}
	CheckBox SZMeanSizeFit, pos={155, 375}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox SZMeanSizeFit, variable=root:Packages:IR2L_NLSQF:SZMeanSizeFit_pop1, help={"Fit the mean size for Schulz-Zimm distribution?"}
	SetVariable SZMeanSizeMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:SZMeanSizeMin_pop1, noproc
	SetVariable SZMeanSizeMin, pos={200, 375}, size={80, 15}, title="Min ", help={"Low limit for mean size for Schulz-Zimm distribution"}
	SetVariable SZMeanSizeMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:SZMeanSizeMax_pop1, noproc
	SetVariable SZMeanSizeMax, pos={290, 375}, size={80, 15}, title="Max ", help={"High limit for mean size for Schulz-Zimm distribution"}

	SetVariable SZWidth, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:SZWidth_pop1, proc=IR2L_PopSetVarProc
	SetVariable SZWidth, pos={8, 395}, size={140, 15}, title="Width [A]= ", help={"Schulz-Zimm width size [A]"}
	CheckBox SZWidthFit, pos={155, 395}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox SZWidthFit, variable=root:Packages:IR2L_NLSQF:GWidthFit_pop1, help={"Fit the width for Schulz-Zimm distribution?"}
	SetVariable SZWidthMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:SZWidthMin_pop1, noproc
	SetVariable SZWidthMin, pos={200, 395}, size={80, 15}, title="Min ", help={"Low limit for width for Schulz-Zimm distribution"}
	SetVariable SZWidthMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:SZWidthMax_pop1, noproc
	SetVariable SZWidthMax, pos={290, 395}, size={80, 15}, title="Max ", help={"High limit for width for Schulz-Zimm distribution"}
	//Ardell parameters...
	SetVariable ArdLocation, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:ArdLocation_pop1, proc=IR2L_PopSetVarProc
	SetVariable ArdLocation, pos={8, 375}, size={140, 15}, title="Mean size [A]= ", help={"Ardell max value size [A]"}
	CheckBox ArdLocationFit, pos={155, 375}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox ArdLocationFit, variable=root:Packages:IR2L_NLSQF:ArdLocationFit_pop1, help={"Fit the mean size for Ardell distribution?"}
	SetVariable ArdLocationMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:ArdLocationMin_pop1, noproc
	SetVariable ArdLocationMin, pos={200, 375}, size={80, 15}, title="Min ", help={"Low limit for mean size for Ardell distribution"}
	SetVariable ArdLocationMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:ArdLocationMax_pop1, noproc
	SetVariable ArdLocationMax, pos={290, 375}, size={80, 15}, title="Max ", help={"High limit for mean size for Ardelldistribution"}

	SetVariable ArdParameter, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:ArdParameterh_pop1, proc=IR2L_PopSetVarProc
	SetVariable ArdParameter, pos={8, 395}, size={140, 15}, title="Width parameter  = ", help={"Ardell width parameter [A]"}
	CheckBox ArdParameterFit, pos={155, 395}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox ArdParameterFit, variable=root:Packages:IR2L_NLSQF:ArdParameterFit_pop1, help={"Fit the width for Ardell distribution?"}
	SetVariable ArdParameterMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:ArdParameterMin_pop1, noproc
	SetVariable ArdParameterMin, pos={200, 395}, size={80, 15}, title="Min ", help={"Low limit for width for Ardell distribution"}
	SetVariable ArdParameterMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:ArdParameterMax_pop1, noproc
	SetVariable ArdParameterMax, pos={290, 395}, size={80, 15}, title="Max ", help={"High limit for width for Ardell distribution"}
	//LSW parameters
	SetVariable LSWLocation, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:LSWLocation_pop1, proc=IR2L_PopSetVarProc
	SetVariable LSWLocation, pos={8, 375}, size={140, 15}, title="Position [A]= ", help={"LSW size [A]"}
	CheckBox LSWLocationFit, pos={155, 375}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox LSWLocationFit, variable=root:Packages:IR2L_NLSQF:LSWLocationFit_pop1, help={"Fit the LSW position?"}
	SetVariable LSWLocationMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:LSWLocationMin_pop1, noproc
	SetVariable LSWLocationMin, pos={200, 375}, size={80, 15}, title="Min ", help={"Low limit for LSW position"}
	SetVariable LSWLocationMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:LSWLocationMax_pop1, noproc
	SetVariable LSWLocationMax, pos={290, 375}, size={80, 15}, title="Max ", help={"High limit for LSW position"}
	//diffraction controls

	PopupMenu DiffPeakProfile, title="Peak shape : ", proc=IR2L_PanelPopupControl, pos={10, 280}
	PopupMenu DiffPeakProfile, value=#"(root:packages:IR2L_NLSQF:ListOfKnownPeakShapes)", mode=1 //whichListItem(root:Packages:IR2L_NLSQF:DiffPeakProfile_pop1, root:Packages:IR2L_NLSQF:ListOfKnownPeakShapes)+1
	//#"(root:Packages:FormFactorCalc:ListOfFormFactors)"
	PopupMenu DiffPeakProfile, help={"Select peak profile for this population"}

	SetVariable DiffPeakPar1, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:DiffPeakPar1_pop1, proc=IR2L_PopSetVarProc
	SetVariable DiffPeakPar1, pos={8, 330}, size={140, 15}, title="Prefactor = ", help={"Scaling for this peak"}
	CheckBox DiffPeakPar1Fit, pos={155, 330}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox DiffPeakPar1Fit, variable=root:Packages:IR2L_NLSQF:DiffPeakPar1Fit_pop1, help={"Fit the prefactor?"}
	SetVariable DiffPeakPar1Min, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:DiffPeakPar1Min_pop1, noproc
	SetVariable DiffPeakPar1Min, pos={200, 330}, size={80, 15}, title="Min ", help={"Low limit for Prefactor"}
	SetVariable DiffPeakPar1Max, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:DiffPeakPar1Max_pop1, noproc
	SetVariable DiffPeakPar1Max, pos={290, 330}, size={80, 15}, title="Max ", help={"High limit for Prefactor"}

	SetVariable DiffPeakPar2, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:DiffPeakPar2_pop1, proc=IR2L_PopSetVarProc
	SetVariable DiffPeakPar2, pos={8, 350}, size={140, 15}, title="Position   = ", help={"Q position for this peak"}
	CheckBox DiffPeakPar2Fit, pos={155, 350}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox DiffPeakPar2Fit, variable=root:Packages:IR2L_NLSQF:DiffPeakPar2Fit_pop1, help={"Fit the Q position?"}
	SetVariable DiffPeakPar2Min, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:DiffPeakPar2Min_pop1, noproc
	SetVariable DiffPeakPar2Min, pos={200, 350}, size={80, 15}, title="Min ", help={"Low limit for Q position"}
	SetVariable DiffPeakPar2Max, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:DiffPeakPar2Max_pop1, noproc
	SetVariable DiffPeakPar2Max, pos={290, 350}, size={80, 15}, title="Max ", help={"High limit for Q position"}

	SetVariable DiffPeakPar3, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:DiffPeakPar3_pop1, proc=IR2L_PopSetVarProc
	SetVariable DiffPeakPar3, pos={8, 370}, size={140, 15}, title="Width      = ", help={"Q width position for this peak"}
	CheckBox DiffPeakPar3Fit, pos={155, 370}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox DiffPeakPar3Fit, variable=root:Packages:IR2L_NLSQF:DiffPeakPar3Fit_pop1, help={"Fit the Q width position?"}
	SetVariable DiffPeakPar3Min, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:DiffPeakPar3Min_pop1, noproc
	SetVariable DiffPeakPar3Min, pos={200, 370}, size={80, 15}, title="Min ", help={"Low limit for Q width position"}
	SetVariable DiffPeakPar3Max, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:DiffPeakPar3Max_pop1, noproc
	SetVariable DiffPeakPar3Max, pos={290, 370}, size={80, 15}, title="Max ", help={"High limit for Q width position"}

	SetVariable DiffPeakPar4, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:DiffPeakPar4_pop1, proc=IR2L_PopSetVarProc
	SetVariable DiffPeakPar4, pos={8, 390}, size={140, 15}, title="Eta(Pseudo-Voigt)= ", help={"Parameter 4 for this peak"}
	CheckBox DiffPeakPar4Fit, pos={155, 390}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox DiffPeakPar4Fit, variable=root:Packages:IR2L_NLSQF:DiffPeakPar4Fit_pop1, help={"Fit the Parameter 4?"}
	SetVariable DiffPeakPar4Min, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:DiffPeakPar4Min_pop1, noproc
	SetVariable DiffPeakPar4Min, pos={200, 390}, size={80, 15}, title="Min ", help={"Low limit for Parameter 4"}
	SetVariable DiffPeakPar4Max, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:DiffPeakPar4Max_pop1, noproc
	SetVariable DiffPeakPar4Max, pos={290, 390}, size={80, 15}, title="Max ", help={"High limit for Parameter 4"}

	SetVariable DiffPeakDPos, limits={0, 1, 0}, variable=root:Packages:IR2L_NLSQF:DiffPeakDPos_pop1, noproc, disable=2, format="%.6g"
	SetVariable DiffPeakDPos, pos={5, 410}, size={280, 16}, title="Peak position -spacing [A]:", help={"peak position in D units"}
	SetVariable DiffPeakQPos, limits={0, 1, 0}, variable=root:Packages:IR2L_NLSQF:DiffPeakQPos_pop1, noproc, disable=2, format="%.4g"
	SetVariable DiffPeakQPos, pos={5, 430}, size={280, 16}, title="Peak position - Q   [A^-1]:", help={"peak position in Q units"}
	SetVariable DiffPeakQFWHM, limits={0, 1, 0}, variable=root:Packages:IR2L_NLSQF:DiffPeakQFWHM_pop1, noproc, disable=2, format="%.4g"
	SetVariable DiffPeakQFWHM, pos={5, 450}, size={280, 16}, title="Peak FWHM [A^-1]:", help={"peak FWHM in Q units"}
	SetVariable DiffPeakIntgInt, limits={0, 1, 0}, variable=root:Packages:IR2L_NLSQF:DiffPeakIntgInt_pop1, noproc, disable=2, format="%.4g"
	SetVariable DiffPeakIntgInt, pos={5, 470}, size={280, 16}, title="Peak Integral Intensity:", help={"peak integral inetnsity"}

	//Mass Fractal
	CheckBox MassFrUseUFFF, pos={30, 300}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Use Unified Fit Form Factor?"
	CheckBox MassFrUseUFFF, variable=root:Packages:IR2L_NLSQF:MassFrUseUFFF_pop1, help={"Mass Fractal Use Uniofied Fit Form Factor?"}

	SetVariable MassFrPhi, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:MassFrPhi_pop1, proc=IR2L_PopSetVarProc
	SetVariable MassFrPhi, pos={8, 330}, size={140, 15}, title="Part Vol   = ", help={"Volume of particle (see manual)"}
	CheckBox MassFrPhiFit, pos={155, 330}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox MassFrPhiFit, variable=root:Packages:IR2L_NLSQF:MassFrPhiFit_pop1, help={"Fit the MassFrPhi?"}
	SetVariable MassFrPhiMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:MassFrPhiMin_pop1, noproc
	SetVariable MassFrPhiMin, pos={200, 330}, size={80, 15}, title="Min ", help={"Low limit for MassFrPhi"}
	SetVariable MassFrPhiMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:MassFrPhiMax_pop1, noproc
	SetVariable MassFrPhiMax, pos={290, 330}, size={80, 15}, title="Max ", help={"High limit for MassFrPhi"}

	SetVariable MassFrRadius, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:MassFrRadius_pop1, proc=IR2L_PopSetVarProc
	SetVariable MassFrRadius, pos={8, 350}, size={140, 15}, title="Radius      = ", help={"Q position for this peak"}
	CheckBox MassFrRadiusFit, pos={155, 350}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox MassFrRadiusFit, variable=root:Packages:IR2L_NLSQF:MassFrRadiusFit_pop1, help={"Fit the Radius position?"}
	SetVariable MassFrRadiusMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:MassFrRadiusMin_pop1, noproc
	SetVariable MassFrRadiusMin, pos={200, 350}, size={80, 15}, title="Min ", help={"Low limit for Radius position"}
	SetVariable MassFrRadiusMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:MassFrRadiusMax_pop1, noproc
	SetVariable MassFrRadiusMax, pos={290, 350}, size={80, 15}, title="Max ", help={"High limit for Radius position"}

	SetVariable MassFrDv, limits={1, 2.999, 0.1}, variable=root:Packages:IR2L_NLSQF:MassFrDv_pop1, proc=IR2L_PopSetVarProc
	SetVariable MassFrDv, pos={8, 370}, size={140, 15}, title="Dv (Frac D)= ", help={"Dv for this fractal"}
	CheckBox MassFrDvFit, pos={155, 370}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox MassFrDvFit, variable=root:Packages:IR2L_NLSQF:MassFrDvFit_pop1, help={"Fit the Dv width position?"}
	SetVariable MassFrDvMin, limits={1, 3, 0}, variable=root:Packages:IR2L_NLSQF:MassFrDvMin_pop1, noproc
	SetVariable MassFrDvMin, pos={200, 370}, size={80, 15}, title="Min ", help={"Low limit for Dv width position"}
	SetVariable MassFrDvMax, limits={1, 3, 0}, variable=root:Packages:IR2L_NLSQF:MassFrDvMax_pop1, noproc
	SetVariable MassFrDvMax, pos={290, 370}, size={80, 15}, title="Max ", help={"High limit for Dv width position"}

	SetVariable MassFrKsi, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:MassFrKsi_pop1, proc=IR2L_PopSetVarProc
	SetVariable MassFrKsi, pos={8, 390}, size={140, 15}, title="Correl. len = ", help={"Correlation lenght [A]"}
	CheckBox MassFrKsiFit, pos={155, 390}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox MassFrKsiFit, variable=root:Packages:IR2L_NLSQF:MassFrKsiFit_pop1, help={"Fit the Correlation lenght?"}
	SetVariable MassFrKsiMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:MassFrKsiMin_pop1, noproc
	SetVariable MassFrKsiMin, pos={200, 390}, size={80, 15}, title="Min ", help={"Low limit for Correlation lenght"}
	SetVariable MassFrKsiMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:MassFrKsiMax_pop1, noproc
	SetVariable MassFrKsiMax, pos={290, 390}, size={80, 15}, title="Max ", help={"High limit for Correlation lenght"}

	SetVariable MassFrBeta, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:MassFrBeta_pop1, proc=IR2L_PopSetVarProc
	SetVariable MassFrBeta, pos={5, 410}, size={230, 16}, title="Particle aspect ratio        =    ", help={"Aspect ratio, 1 for sphere"}
	SetVariable MassFrEta, limits={0, 1, 0}, variable=root:Packages:IR2L_NLSQF:MassFrEta_pop1, proc=IR2L_PopSetVarProc
	SetVariable MassFrEta, pos={5, 430}, size={230, 16}, title="Volume filling                 =     ", help={"Volume filling, between 0 and 1"}
	SetVariable MassFrIntgNumPnts, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:MassFrIntgNumPnts_pop1, proc=IR2L_PopSetVarProc
	SetVariable MassFrIntgNumPnts, pos={5, 450}, size={230, 16}, title="Intg. Num. pnts.             =     ", help={"Internal integration pnts, typically 500"}
	SetVariable MassFrPDI, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:MassFrPDI_pop1, proc=IR2L_PopSetVarProc
	SetVariable MassFrPDI, pos={5, 470}, size={230, 16}, title="Unified Fit Form F. PDI     =    ", help={"PDI for Unified Fit Form factor"}

	//Surface Fractal
	SetVariable SurfFrSurf, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:SurfFrSurf_pop1, proc=IR2L_PopSetVarProc
	SetVariable SurfFrSurf, pos={8, 330}, size={140, 15}, title="Smooth surface = ", help={"Smooth surface (see manual)"}
	CheckBox SurfFrSurfFit, pos={155, 330}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox SurfFrSurfFit, variable=root:Packages:IR2L_NLSQF:SurfFrSurfFit_pop1, help={"Fit the SurfFrSurf?"}
	SetVariable SurfFrSurfMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:SurfFrSurfMin_pop1, noproc
	SetVariable SurfFrSurfMin, pos={200, 330}, size={80, 15}, title="Min ", help={"Low limit for SurfFrSurf"}
	SetVariable SurfFrSurfMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:SurfFrSurfMax_pop1, noproc
	SetVariable SurfFrSurfMax, pos={290, 330}, size={80, 15}, title="Max ", help={"High limit for SurfFrSurf"}

	SetVariable SurfFrDS, limits={2.001, 2.999, 0.1}, variable=root:Packages:IR2L_NLSQF:SurfFrDS_pop1, proc=IR2L_PopSetVarProc
	SetVariable SurfFrDS, pos={8, 350}, size={140, 15}, title="Fractal dim.     = ", help={"Fractal dimension, between 2 and 3"}
	CheckBox SurfFrDSFit, pos={155, 350}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox SurfFrDSFit, variable=root:Packages:IR2L_NLSQF:SurfFrDSFit_pop1, help={"Fit the Fract dim.?"}
	SetVariable SurfFrDSMin, limits={1.999, 3, 0}, variable=root:Packages:IR2L_NLSQF:SurfFrDSMin_pop1, noproc
	SetVariable SurfFrDSMin, pos={200, 350}, size={80, 15}, title="Min ", help={"Low limit for Fract. dim.  position"}
	SetVariable SurfFrDSMax, limits={1.999, 3, 0}, variable=root:Packages:IR2L_NLSQF:SurfFrDSMax_pop1, noproc
	SetVariable SurfFrDSMax, pos={290, 350}, size={80, 15}, title="Max ", help={"High limit for Fract. dim. position"}

	SetVariable SurfFrKsi, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:SurfFrKsi_pop1, proc=IR2L_PopSetVarProc
	SetVariable SurfFrKsi, pos={8, 370}, size={140, 15}, title="Corr. Length  = ", help={"Corr. Length for this fractal"}
	CheckBox SurfFrKsiFit, pos={155, 370}, size={25, 16}, proc=IR2L_ModelTabCheckboxProc, title="Fit?"
	CheckBox SurfFrKsiFit, variable=root:Packages:IR2L_NLSQF:SurfFrKsiFit_pop1, help={"Fit the Corr. Length width position?"}
	SetVariable SurfFrKsiMin, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:SurfFrKsiMin_pop1, noproc
	SetVariable SurfFrKsiMin, pos={200, 370}, size={80, 15}, title="Min ", help={"Low limit for Corr. Length width position"}
	SetVariable SurfFrKsiMax, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:SurfFrKsiMax_pop1, noproc
	SetVariable SurfFrKsiMax, pos={290, 370}, size={80, 15}, title="Max ", help={"High limit for Corr. Length width position"}

	SetVariable SurfFrQc, limits={0, 1, 0}, variable=root:Packages:IR2L_NLSQF:SurfFrQc_pop1, proc=IR2L_PopSetVarProc
	SetVariable SurfFrQc, pos={5, 410}, size={200, 16}, title="Qc (terminal Q)      =    ", help={"Q when converts to Porod scatterer."}
	NVAR SurfFrQcWidth_pop1 = root:Packages:IR2L_NLSQF:SurfFrQcWidth_pop1
	PopupMenu SurfFrQcWidth, pos={5, 435}, size={250, 16}, title="Qc width [% of Qc] ", help={"Transition width at Q max when scattering changes to Porod's law"}
	PopupMenu SurfFrQcWidth, proc=IR2L_PanelPopupControl, value="5;10;15;20;25;", mode=1 + whichListItem(num2str(100 * SurfFrQcWidth_pop1), "5;10;15;20;25;")

	//interferences
	//		CheckBox UseInterference,pos={40,435},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Use Structure factor?"
	//		CheckBox UseInterference,variable= root:Packages:IR2L_NLSQF:UseInterference_pop1, help={"Check to use structure factor"}
	PopupMenu StructureFactorModel, title="Structure Factor : ", proc=IR2L_PanelPopupControl, pos={10, 468}
	PopupMenu StructureFactorModel, value=#"(root:Packages:StructureFactorCalc:ListOfStructureFactors)"
	SVAR StrA = root:Packages:IR2L_NLSQF:StructureFactor_pop1
	SVAR StrB = root:Packages:StructureFactorCalc:ListOfStructureFactors
	PopupMenu StructureFactorModel, mode=WhichListItem(StrA, StrB) + 1
	PopupMenu StructureFactorModel, help={"Select Dilute system or Structure factor to be used for this population of scatterers"}

	SetVariable Contrast, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:Contrast_pop1, proc=IR2L_PopSetVarProc
	SetVariable Contrast, pos={8, 495}, size={250, 15}, title="Contrast [*10^20] = ", help={"Contrast [*10^20]  of this population"}
	SetVariable Contrast_set1, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:Contrast_set1_pop1, proc=IR2L_PopSetVarProc
	SetVariable Contrast_set1, pos={8, 490}, size={150, 15}, title="Contrast data 1 = ", help={"Contrast [*10^20]  of this population for data set 1"}
	SetVariable Contrast_set2, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:Contrast_set2_pop1, proc=IR2L_PopSetVarProc
	SetVariable Contrast_set2, pos={8, 510}, size={150, 15}, title="Contrast data 2 = ", help={"Contrast [*10^20]  of this population for data set 2"}
	SetVariable Contrast_set3, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:Contrast_set3_pop1, proc=IR2L_PopSetVarProc
	SetVariable Contrast_set3, pos={8, 530}, size={150, 15}, title="Contrast data 3 = ", help={"Contrast [*10^20]  of this population for data set 3"}
	SetVariable Contrast_set4, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:Contrast_set4_pop1, proc=IR2L_PopSetVarProc
	SetVariable Contrast_set4, pos={8, 550}, size={150, 15}, title="Contrast data 4 = ", help={"Contrast [*10^20]  of this population for data set 4"}
	SetVariable Contrast_set5, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:Contrast_set5_pop1, proc=IR2L_PopSetVarProc
	SetVariable Contrast_set5, pos={8, 570}, size={150, 15}, title="Contrast data 5 = ", help={"Contrast [*10^20]  of this population for data set 5"}

	SetVariable Contrast_set6, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:Contrast_set6_pop1, proc=IR2L_PopSetVarProc
	SetVariable Contrast_set6, pos={178, 490}, size={150, 15}, title="Contrast data 6 = ", help={"Contrastv of this population for data set 1"}
	SetVariable Contrast_set7, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:Contrast_set7_pop1, proc=IR2L_PopSetVarProc
	SetVariable Contrast_set7, pos={178, 510}, size={150, 15}, title="Contrast data 7 = ", help={"Contrast [*10^20]  of this population for data set 2"}
	SetVariable Contrast_set8, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:Contrast_set8_pop1, proc=IR2L_PopSetVarProc
	SetVariable Contrast_set8, pos={178, 530}, size={150, 15}, title="Contrast data 8 = ", help={"Contrast [*10^20]  of this population for data set 3"}
	SetVariable Contrast_set9, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:Contrast_set9_pop1, proc=IR2L_PopSetVarProc
	SetVariable Contrast_set9, pos={178, 550}, size={150, 15}, title="Contrast data 9 = ", help={"Contrast [*10^20]  of this population for data set 4"}
	SetVariable Contrast_set10, limits={0, Inf, 0}, variable=root:Packages:IR2L_NLSQF:Contrast_set10_pop1, proc=IR2L_PopSetVarProc
	SetVariable Contrast_set10, pos={178, 570}, size={150, 15}, title="Contrast set 10 = ", help={"Contrast [*10^20]  of this population for data set 5"}

	//few more buttons
	CheckBox UseGeneticOptimization, pos={5, 610}, size={25, 90}, proc=IR2L_DataTabCheckboxProc, title="Genetic Optimiz.?"
	CheckBox UseGeneticOptimization, variable=root:Packages:IR2L_NLSQF:UseGeneticOptimization, help={"Use genetic Optimization? SLOW..."}
	CheckBox UseLSQF, pos={120, 610}, size={25, 90}, proc=IR2L_DataTabCheckboxProc, title="Use LSQF?"
	CheckBox UseLSQF, variable=root:Packages:IR2L_NLSQF:UseLSQF, help={"Use LSQF?"}

	Button Recalculate, pos={10, 630}, size={90, 20}, proc=IR2L_InputPanelButtonProc, title="Calculate Model", help={"Recalculate model"}
	Button AnalyzeUncertainities, pos={10, 655}, size={90, 20}, proc=IR2L_InputPanelButtonProc, title="Anal. Uncertainity", help={"Run procedures to analyze uncertaitnities for parameters"}
	Button FitModel, pos={110, 630}, size={90, 20}, proc=IR2L_InputPanelButtonProc, title="Fit Model", help={"Fit the model"}
	Button ReverseFit, pos={110, 655}, size={90, 20}, proc=IR2L_InputPanelButtonProc, title="Reverse Fit", help={"Reverse fit"}

	Button FixLimitsTight, pos={200, 605}, size={45, 20}, proc=IR2L_InputPanelButtonProc, title="Fix L1", help={"Reset fitting limits acording to built in rules"}
	Button FixLimitsLoose, pos={255, 605}, size={45, 20}, proc=IR2L_InputPanelButtonProc, title="Fix L3", help={"Reset fitting limits acording to built in rules"}
	Button PasteTagsToGraph, pos={210, 630}, size={90, 20}, proc=IR2L_InputPanelButtonProc, title="Tags to graph", help={"Add tags to graph"}
	Button RemoveTagsFromGraph, pos={210, 655}, size={90, 20}, proc=IR2L_InputPanelButtonProc, title="Remove Tags", help={"Remove tags from graph"}

	Button SaveInDataFolder, pos={310, 605}, size={90, 20}, proc=IR2L_InputPanelButtonProc, title="Store in Folder", help={"Copy result in the data folder"}
	Button SaveInNotebook, pos={310, 630}, size={90, 20}, proc=IR2L_InputPanelButtonProc, title="Store in Notebook", help={"Store result in output notebook"}
	Button SaveInWaves, pos={310, 655}, size={90, 20}, proc=IR2L_InputPanelButtonProc, title="Store in Waves", help={"Store result in the separate folder in waves"}

	IR2L_Model_TabPanelControl("", 0)
	IR2L_DataTabCheckboxProc("MultipleInputData", MultipleInputData) //carefull this will make graph to be top window!!!
	IR2L_SetTabsNames()
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function LSQF2_ModelingII_MoreDetailsF() : Panel
	PauseUpdate // building window...
	NewPanel/K=1/W=(188, 240, 613, 383) as "Modeling more parameters"
	DoWindow/C LSQF2_ModelingII_MoreDetails
	SetDrawLayer UserBack
	SetDrawEnv fsize=16, fstyle=3, textrgb=(0, 0, 65535)
	DrawText 108, 24, "Set Size distribution parameters"
	CheckBox DimensionIsDiameter, pos={13, 35}, size={203, 14}, proc=IR2L_DataTabCheckboxProc, title="Size dist. use Diameters? (default is radia)"
	CheckBox DimensionIsDiameter, help={"Check if Size Distribution dimension is diameter?"}
	CheckBox DimensionIsDiameter, variable=root:Packages:IR2L_NLSQF:SizeDist_DimensionIsDiameter
	CheckBox UseNumberDistributions, pos={13, 60}, size={278, 14}, proc=IR2L_DataTabCheckboxProc, title="Size Dist. use Number distribution? (default is volume dist.)"
	CheckBox UseNumberDistributions, help={"Use number distributions? Default is volume distributions."}
	CheckBox UseNumberDistributions, variable=root:Packages:IR2L_NLSQF:UseNumberDistributions
	SVAR     DataCalibrationUnits = root:Packages:IR2L_NLSQF:DataCalibrationUnits
	variable modeVal              = 1 + WhichListItem(DataCalibrationUnits, "Arbitrary;cm2/cm3;cm2/g;")
	if(modeVal < 1 || modeVal > 3)
		modeVal = 1
	endif
	PopupMenu DataUnits, title="Units : ", proc=IR2L_PanelPopupControl, pos={13, 90}
	PopupMenu DataUnits, mode=modeVal, value="Arbitrary;cm2/cm3;cm2/g;"
	PopupMenu DataUnits, help={"Units for data"}

	Button Continue_SDDetails, pos={220, 109}, size={114, 24}, proc=IR2L_InputPanelButtonProc, title="Continue"
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

Function IR2L_LoadDataIntoSet(whichDataSet, skipRecover)
	variable whichDataSet, skipRecover

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	SVAR InputFoldrName  = root:Packages:IR2L_NLSQF:DataFolderName
	SVAR InputIntName    = root:Packages:IR2L_NLSQF:IntensityWaveName
	SVAR InputQName      = root:Packages:IR2L_NLSQF:QWavename
	SVAR InputErrorName  = root:Packages:IR2L_NLSQF:ErrorWaveName
	SVAR NewFldrName     = $("root:Packages:IR2L_NLSQF:FolderName_set" + num2str(whichDataSet))
	SVAR NewIntName      = $("root:Packages:IR2L_NLSQF:IntensityDataName_set" + num2str(whichDataSet))
	SVAR NewQName        = $("root:Packages:IR2L_NLSQF:QvecDataName_set" + num2str(whichDataSet))
	SVAR NewErrorName    = $("root:Packages:IR2L_NLSQF:ErrorDataName_set" + num2str(whichDataSet))
	NVAR SlitSmeared_set = $("root:Packages:IR2L_NLSQF:SlitSmeared_set" + num2str(whichDataSet))
	NVAR UseSmearing_set = $("root:Packages:IR2L_NLSQF:UseSmearing_set" + num2str(whichDataSet))
	NVAR SlitLength_set  = $("root:Packages:IR2L_NLSQF:SlitLength_set" + num2str(whichDataSet))
	NVAR UseIndra2Data   = root:Packages:IR2L_NLSQF:UseIndra2Data
	NVAR GraphXMin       = root:Packages:IR2L_NLSQF:GraphXMin
	NVAR GraphXMax       = root:Packages:IR2L_NLSQF:GraphXMax
	NVAR GraphYMin       = root:Packages:IR2L_NLSQF:GraphYMin
	NVAR GraphYMax       = root:Packages:IR2L_NLSQF:GraphYMax
	SVAR UserDataSetName = $("root:Packages:IR2L_NLSQF:UserDataSetName_set" + num2str(whichDataSet))
	NVAR RebinDataTo     = root:Packages:IR2L_NLSQF:RebinDataTo
	string WvNote

	if(strlen(InputFoldrName) < 4)
		abort
	endif
	if(!DataFolderExists(InputFoldrName))
		Abort "Bad input folder name"
	endif
	setDataFolder InputFoldrName
	WAVE/Z inputI = $(InputIntName)
	WAVE/Z inputQ = $(InputQName)
	WAVE/Z inputE = $(InputErrorName)

	if(UseIndra2Data)
		if(stringmatch(InputIntName, "*SMR*") && stringmatch(InputQName, "*SMR*") && stringmatch(InputErrorName, "*SMR*"))
			SlitSmeared_set = 1
			UseSmearing_set = 1
			WvNote          = note(inputI)
			SlitLength_set  = NumberByKey("SlitLength", WvNote, "=", ";")
			DoWindow IR2L_ResSmearingPanel
			if(V_Flag)
				SetVariable SlitLength, win=IR2L_ResSmearingPanel, disable=0
			endif
		else
			SlitSmeared_set = 0
			SlitLength_set  = 0
			UseSmearing_set = 0
		endif
	endif
	if(whichDataSet == 1)
		WvNote = note(inputI)
		IR2L_SetDataUnits(StringByKey("Units", WvNote, "=", ";"))
	endif

	if(!WaveExists(InputI) || !WaveExists(InputQ))
		abort "Input waves (at least one of them) do not exists)"
	endif
	if(numpnts(inputI) != numpnts(InputQ))
		abort "Number of point of input waves is different, cannot continue"
	endif
	if(WaveExists(inputE) && (numpnts(InputI) != numpnts(InputE)))
		abort "Number of point of input waves is different, cannot continue"
	endif

	NVAR UseUserErrors         = $("root:Packages:IR2L_NLSQF:UseUserErrors_set" + num2str(whichDataSet))
	NVAR UseSQRTErrors         = $("root:Packages:IR2L_NLSQF:UseSQRTErrors_set" + num2str(whichDataSet))
	NVAR UsePercentErrors      = $("root:Packages:IR2L_NLSQF:UsePercentErrors_set" + num2str(whichDataSet))
	NVAR DataScalingFactor_set = $("root:Packages:IR2L_NLSQF:DataScalingFactor_set" + num2str(whichDataSet))
	if(!WaveExists(inputE))
		UseUserErrors = 0
		if(UseSQRTErrors + UsePercentErrors != 1)
			UseSQRTErrors    = 1
			UsePercentErrors = 0
		endif
	else
		UseUserErrors    = 1
		UseSQRTErrors    = 0
		UsePercentErrors = 0
	endif

	// set for user the name so it is meaningfull... Just guess...
	if(UseIndra2Data) //FOLDERIS THE NAME
		UserDataSetName = GetDataFolder(0)
	else //hope the name of wave is the right thing there...
		UserDataSetName = InputIntName
	endif
	if(!skipRecover)
		//recover old parameters, if user wants...
		IR2L_RecoverOldParameters()
		//end load
	endif
	setDataFolder root:Packages:IR2L_NLSQF

	NewFldrName  = InputFoldrName
	NewIntName   = InputIntName
	NewQName     = InputQName
	NewErrorName = InputErrorName

	Duplicate/O inputI, $("Intensity_set" + num2str(whichDataSet))
	WAVE IntWv = $("Intensity_set" + num2str(whichDataSet))
	IntWv = DataScalingFactor_set * IntWv //scale by user factor, if requested.
	Duplicate/O inputQ, $("Q_set" + num2str(whichDataSet))
	WAVE QWv = $("Q_set" + num2str(whichDataSet))
	//check the InputE if it contains meaningful numbers, they need to be larger than 0 - all of them.  And no Infs or Nans
	wavestats/Q inputE
	if(((V_min <= 0) || (V_numINFs > 0) || (V_numNANs > 0)) && UseUserErrors && !(StringMatch(InputIntName, "ModelInt")))
		DoALert 0, "Uncertainties data contain either zeroes, negative values, NANs, or infinite numbers. This is not acceptable to this tool. Switching to use of % errors. "
		UsePercentErrors = 1
		UseUserErrors    = 0
		UseSQRTErrors    = 0
	endif
	if(UseUserErrors) //handle special cases of errors not loaded in Igor
		Duplicate/O inputE, $("Error_set" + num2str(whichDataSet))
		WAVE ErrorWv = $("Error_set" + num2str(whichDataSet))
	elseif(UseSQRTErrors)
		Duplicate/O inputI, $("Error_set" + num2str(whichDataSet))
		WAVE ErrorWv = $("Error_set" + num2str(whichDataSet))
		ErrorWv = sqrt(IntWv)
	else
		Duplicate/O inputI, $("Error_set" + num2str(whichDataSet))
		WAVE ErrorWv = $("Error_set" + num2str(whichDataSet))
		ErrorWv = 0.01 * (IntWv)
	endif
	//need to make sure all waves are double precision due to some users using weird scaling...
	redimension/D IntWv, QWv, ErrorWv

	if(RebinDataTo > 0)
		//IR1D_rebinData(IntWv,QWv,ErrorWv,RebinDataTo, 1)
		IN2G_RebinLogData(QWv, IntWv, RebinDataTo, 0, Wsdev = ErrorWv)
	endif

	Duplicate/O IntWv, $("IntensityMask_set" + num2str(whichDataSet))
	WAVE Mask = $("IntensityMask_set" + num2str(whichDataSet))
	Mask = 5

	NVAR Qmax_set = $("Qmax_set" + num2str(whichDataSet))
	Qmax_set = inputQ[numpnts(inputQ) - 1]
	NVAR Qmin_set = $("Qmin_set" + num2str(whichDataSet))
	Qmin_set = inputQ[0]
	IR2L_setQMinMax(whichDataSet)

	if(UseIndra2Data && stringmatch(InputIntName, "*SMR*"))
		SlitSmeared_set = 1
	endif

	//set limits, if not set otherwise...
	if(GraphXMin == 0 || GraphXMax == 0 || GraphYMin == 0 || GraphYMax == 0)
		wavestats/Q inputI
		if(V_min <= 0)
			DoAlert 0, "Note, minimum value on Intensity axis is less than 0. That will not work for log axis. Default selected. Please, change manually!!!"
			V_min = V_max / 1e6
		endif
		GraphYMin = V_min
		GraphYMax = V_max
		wavestats/Q inputQ
		if(V_min <= 0)
			DoAlert 0, "Note, minimum value on Q axis is less than 0. That will not work for log axis. Default selected. Please, change manually!!!"
			V_min = 1e-4
		endif
		GraphXMin = V_min
		GraphXMax = V_max
	endif

	IR2L_RecalculateIfSelected()

	setDataFolder OldDf

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//
Function IR2L_RecoverOldParameters()

	variable DataExists = 0, i
	string ListOfWaves = IN2G_CreateListOfItemsInFolder(GetDataFolder(1), 2)
	string tempString
	if(stringmatch(ListOfWaves, "*IntensityModelLSQF2*"))
		string ListOfSolutions = ""
		for(i = 0; i < itemsInList(ListOfWaves); i += 1)
			if(stringmatch(stringFromList(i, ListOfWaves), "IntensityModelLSQF2*"))
				tempString = stringFromList(i, ListOfWaves)
				WAVE tempwv = $(GetDataFolder(1) + tempString)
				tempString       = stringByKey("UsersComment", note(tempwv), "=")
				ListOfSolutions += stringFromList(i, ListOfWaves) + "*  " + tempString + ";"
			endif
		endfor
		DataExists = 1
		string ReturnSolution = ""
		Prompt ReturnSolution, "Select solution to recover", popup, ListOfSolutions + ";Start fresh"
		DoPrompt "Previous solutions found, select one to recover", ReturnSolution
		if(V_Flag)
			abort
		endif
	endif

	if(DataExists == 1 && cmpstr("Start fresh", ReturnSolution) != 0)
		ReturnSolution = ReturnSolution[0, strsearch(ReturnSolution, "*", 0) - 1]
		WAVE/Z OldDistribution = $(GetDataFolder(1) + ReturnSolution)

		string OldNote = note(OldDistribution)
		string TempStr, ErrorMessage
		ErrorMessage = ""
		variable j
		for(j = 0; j < ItemsInList(OldNote); j += 1)
			TempStr = StringFromList(j, OldNote, ";")
			NVAR/Z TestVar = $("root:Packages:IR2L_NLSQF:" + StringFromList(0, StringFromList(j, OldNote, ";"), "="))
			if(NVAR_Exists(testVar))
				TestVar = str2num(StringFromList(1, TempStr, "="))
				if(StringMatch(TempStr, "*LNMinSizeMin_pop*") && TestVar < 1.5)
					TestVar       = 3
					ErrorMessage += TempStr + ";"
				endif
			endif
			SVAR/Z TestStr = $("root:Packages:IR2L_NLSQF:" + StringFromList(0, StringFromList(j, OldNote, ";"), "="))
			if(SVAR_Exists(testStr))
				TestStr = StringFromList(1, TempStr, "=")
			endif
		endfor
		if(strlen(ErrorMessage) > 0)
			DoAlert/T="Some parameters have changed due to change in code" 0, "Warning! Restore changed following parameters from the stored ones: " + ErrorMessage
		endif
		return 1
		DoAlert 1, "unfinished, need to set the Panel controls - popups are likely stale"
	else
		return 0
	endif
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_AutosetGraphAxis(autoset)
	variable autoset
	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	NVAR GraphXMin = root:Packages:IR2L_NLSQF:GraphXMin
	NVAR GraphXMax = root:Packages:IR2L_NLSQF:GraphXMax
	NVAR GraphYMin = root:Packages:IR2L_NLSQF:GraphYMin
	NVAR GraphYMax = root:Packages:IR2L_NLSQF:GraphYMax

	//		DoAlert 1, "Fifnish IR2L_AutosetGraphAxis() proc..."
	if(autoset)
		setAxis/W=LSQF_MainGraph/A
		Doupdate
	endif
	GetAxis/W=LSQF_MainGraph/Q left
	GraphYMin = V_min
	GraphYMax = V_max
	GetAxis/W=LSQF_MainGraph/Q bottom
	GraphXMin = V_min
	GraphXMax = V_max
	setDataFolder OldDf

End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_AppendDataIntoGraph(whichDataSet) //Adds user data into the graph for selected data set
	variable whichDataSet

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	DoWindow LSQF_MainGraph
	if(V_Flag)
		DoWindow/F LSQF_MainGraph
	else
		//Display /K=1/W=(313.5,38.75,900,400) as "LSQF2 main data window"
		Display/K=1/W=(0, 0, IN2G_GetGraphWidthHeight("width"), IN2G_GetGraphWidthHeight("height")) as "LSQF2 main data window"
		Dowindow/C LSQF_MainGraph
		AutoPositionWindow/M=0/R=LSQF2_MainPanel LSQF_MainGraph

		//Add command bar
		ControlBar/T/W=LSQF_MainGraph 65
		SetVariable GraphXMin, pos={20, 3}, size={140, 25}, variable=root:Packages:IR2L_NLSQF:GraphXMin, help={"Set minimum value for q axis"}, title="Min q = "
		SetVariable GraphXMin, limits={0, Inf, 0}, proc=IR2L_DataTabSetVarProc
		SetVariable GraphXMax, pos={20, 25}, size={140, 25}, variable=root:Packages:IR2L_NLSQF:GraphXMax, help={"Set maximum value for q axis"}, title="Max q = "
		SetVariable GraphXMax, limits={0, Inf, 0}, proc=IR2L_DataTabSetVarProc
		SetVariable GraphYMin, pos={180, 3}, size={140, 25}, variable=root:Packages:IR2L_NLSQF:GraphYMin, help={"Set minimum value for intensity axis"}, title="Min Int = "
		SetVariable GraphYMin, limits={0, Inf, 0}, proc=IR2L_DataTabSetVarProc
		SetVariable GraphYMax, pos={180, 25}, size={140, 25}, variable=root:Packages:IR2L_NLSQF:GraphYMax, help={"Set maximum value for intensity axis"}, title="Max Int = "
		SetVariable GraphYMax, limits={0, Inf, 0}, proc=IR2L_DataTabSetVarProc
		Button SetAxis, pos={350, 5}, size={80, 16}, proc=IR2L_InputGraphButtonProc, title="Read Axis", help={"Read current axis range on to variables controlling the range"}
		Button AutoSetAxis, pos={350, 25}, size={80, 16}, proc=IR2L_InputGraphButtonProc, title="Autoset Axis", help={"Set range on axis to display all data"}
		Checkbox DisplaySinglePopInt, proc=IR2L_GraphsCheckboxProc, variable=root:Packages:IR2L_NLSQF:DisplaySinglePopInt, pos={450, 3}, title="Display Ind. Pop. Ints.?", help={"Display in the graph intensitiesfor separate populations?"}
		Button SelectQRangeofData, pos={450, 25}, size={120, 16}, proc=IR2L_InputGraphButtonProc, title="Select Fitting Q range", help={"Set Qmin and Qmax for fitting using cursors"}

		Checkbox DisplaySizeDistPlot, proc=IR2L_GraphsCheckboxProc, variable=root:Packages:IR2L_NLSQF:DisplaySizeDistPlot, pos={20, 44}, title="Display Size Dist. Plot?", help={"Display Size distribution plot?"}
		Checkbox DisplayResidualsPlot, proc=IR2L_GraphsCheckboxProc, variable=root:Packages:IR2L_NLSQF:DisplayResidualsPlot, pos={200, 44}, title="Display Residuals Plot?", help={"Display Residulas plot?"}
		Checkbox DisplayIQ4vsQplot, proc=IR2L_GraphsCheckboxProc, variable=root:Packages:IR2L_NLSQF:DisplayIQ4vsQplot, pos={390, 44}, title="Display IQ4 vs Q Plot?", help={"Display IQ^4 vs Q plot?"}

	endif

	WAVE/Z InputIntensity = $("Intensity_set" + num2str(whichDataSet))
	WAVE/Z InputQ         = $("Q_set" + num2str(whichDataSet))
	WAVE/Z InputError     = $("Error_set" + num2str(whichDataSet))
	NVAR   UseTheData_set = $("UseTheData_set" + num2str(whichDataSet))
	if(!WaveExists(InputIntensity) || !WaveExists(InputQ) || !WaveExists(InputError))
		UseTheData_set = 0
		DoAlert 0, "This data do not exists, add data first in to the tool"
	else
		Checkdisplayed/W=LSQF_MainGraph $("Intensity_set" + num2str(whichDataSet))
		if(V_Flag == 0)
			AppendToGraph/W=LSQF_MainGraph InputIntensity vs InputQ
			ErrorBars $("Intensity_set" + num2str(whichDataSet)), Y, wave=(InputError, InputError)
			ModifyGraph/Z/W=LSQF_MainGraph zmrkSize($("Intensity_set" + num2str(whichDataSet)))={$("IntensityMask_set" + num2str(whichDataSet)), 0, 5, 0.5, 3}
		endif
	endif

	setDataFolder OldDf
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//Function  IR2L_AppendDatatoResiduals(whichDataSet) //Adds user data into the graph for selected data set
//	variable whichDataSet
//
//
//	DFref oldDf= GetDataFolderDFR()

//	setDataFolder root:Packages:IR2L_NLSQF
//
//	DoWindow LSQF_ResidualsGraph
//	if(V_Flag)
//		DoWindow/F LSQF_ResidualsGraph
//	else
//		Display /K=1/W=(313.5,38.75,858,374) as "LSQF2 residuals"
//		Dowindow/C LSQF_ResidualsGraph
//	endif
//
//	Wave/Z Residuals= $("Residuals_set"+num2str(whichDataSet))
//	Wave/Z InputQ=$("Q_set"+num2str(whichDataSet))
//	NVAR UseTheData_set = $("UseTheData_set"+num2str(whichDataSet))
//	if(!WaveExists(Residuals) || !WaveExists(InputQ))
//		UseTheData_set=0
//		DoAlert 0, "This data do not exists, add data first in to the tool"
//	else
//		Checkdisplayed/W=LSQF_ResidualsGraph $("Residuals_set"+num2str(whichDataSet))
//		if(V_Flag==0)
//			AppendToGraph/W=LSQF_MainGraph Residuals vs InputQ
//			ModifyGraph/Z/W=LSQF_MainGraph zmrkSize( $("Residuals_set"+num2str(whichDataSet)))={$("IntensityMask_set"+num2str(whichDataSet)),0,5,0.5,3}
//		endif
//	endif
//
//	setDataFolder OldDf
//End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_AppendOrRemoveLocalPopInts()

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	DoWindow LSQF_MainGraph
	if(!V_Flag)
		return 1
	endif
	ControlInfo/W=LSQF2_MainPanel DistTabs
	variable WhichPopSet = V_Value + 1

	NVAR     MultipleInputData = root:Packages:IR2L_NLSQF:MultipleInputData
	variable WhichDataSet      = 1
	if(MultipleInputData)
		ControlInfo/W=LSQF2_MainPanel DataTabs
		WhichDataSet = V_Value + 1
	endif
	NVAR UseTheDataSet = $("root:Packages:IR2L_NLSQF:UseTheData_Set" + num2str(WhichDataSet))
	NVAR UseThePop     = $("root:Packages:IR2L_NLSQF:UseThePop_pop" + num2str(WhichPopSet))

	NVAR DisplaySinglePopInt = root:Packages:IR2L_NLSQF:DisplaySinglePopInt
	variable i, j
	for(i = 0; i <= 10; i += 1)
		for(j = 0; j <= 10; j += 1)
			RemoveFromGraph/Z/W=LSQF_MainGraph $("IntensityModel_set" + num2str(i) + "_pop" + num2str(j))
		endfor
	endfor

	if(UseTheDataSet && DisplaySinglePopInt && UseThePop)
		WAVE/Z Int  = $("root:Packages:IR2L_NLSQF:IntensityModel_set" + num2str(whichDataSet) + "_pop" + num2str(whichPopSet))
		WAVE/Z Qvec = $("root:Packages:IR2L_NLSQF:Qmodel_set" + num2str(whichDataSet))
		if(!WaveExists(Int) || !WaveExists(Qvec))
			return 1
		endif
		Checkdisplayed/W=LSQF_MainGraph $("IntensityModel_set" + num2str(whichDataSet) + "_pop" + num2str(whichPopSet))
		if(V_Flag == 0)
			AppendToGraph/W=LSQF_MainGraph Int vs Qvec
			ModifyGraph/W=LSQF_MainGraph lstyle($("IntensityModel_set" + num2str(whichDataSet) + "_pop" + num2str(whichPopSet)))=8
			ModifyGraph/W=LSQF_MainGraph rgb($("IntensityModel_set" + num2str(whichDataSet) + "_pop" + num2str(whichPopSet)))=(0, 0, 0)
		endif
	endif

	IR2L_FormatLegend()
	setDataFolder OldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_GraphsCheckboxProc(ctrlName, checked) : CheckBoxControl
	string   ctrlName
	variable checked

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	ControlInfo/W=LSQF2_MainPanel PopTabs
	variable WhichPopSet = V_Value + 1

	if(stringMatch(ctrlName, "DisplaySinglePopInt"))
		NVAR DisplaySinglePopInt = root:Packages:IR2L_NLSQF:DisplaySinglePopInt
		IR2L_AppendOrRemoveLocalPopInts()
	endif

	if(stringMatch(ctrlName, "DisplaySizeDistPlot") || stringMatch(ctrlName, "DisplayResidualsPlot") || stringMatch(ctrlName, "DisplayIQ4vsQplot"))
		IR2L_CreateOtherGraphs()
	endif

	setDataFolder oldDf
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_RemoveDataFromGraph(whichDataSet)
	variable whichDataSet
	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	DoWindow LSQF_MainGraph
	if(V_Flag)
		DoWindow/F LSQF_MainGraph
		checkdisplayed/W=LSQF_MainGraph $("Intensity_set" + num2str(whichDataSet))
		if(V_Flag)
			RemoveFromGraph/W=LSQF_MainGraph/Z $("Intensity_set" + num2str(whichDataSet))
		endif
	endif
	setDataFolder OldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_FormatInputGraph()

	NVAR GraphXMin           = root:Packages:IR2L_NLSQF:GraphXMin
	NVAR GraphXMax           = root:Packages:IR2L_NLSQF:GraphXMax
	NVAR GraphYMin           = root:Packages:IR2L_NLSQF:GraphYMin
	NVAR GraphYMax           = root:Packages:IR2L_NLSQF:GraphYMax
	SVAR IntCalibrationUnits = root:Packages:IR2L_NLSQF:IntCalibrationUnits
	DoWindow LSQF_MainGraph
	if(V_Flag)
		DoWindow/F LSQF_MainGraph
		ModifyGraph/Z/W=LSQF_MainGraph mode=3
		ModifyGraph/Z/W=LSQF_MainGraph marker=19
		ModifyGraph/Z/W=LSQF_MainGraph msize=2
		ModifyGraph/Z/W=LSQF_MainGraph grid=1
		ModifyGraph/Z/W=LSQF_MainGraph log=1
		ShowInfo/W=LSQF_MainGraph
		ModifyGraph/Z/W=LSQF_MainGraph mirror=1
		Label/Z/W=LSQF_MainGraph left, "Intensity [" + IntCalibrationUnits + "]"
		Label/Z/W=LSQF_MainGraph bottom, "Q [A\\S-1\\M]"
		SetAxis/Z left, GraphYMin, GraphYMax
		SetAxis/Z bottom, GraphXMin, GraphXMax

		SVAR rgbIntensity_set1  = root:Packages:IR2L_NLSQF:rgbIntensity_set1
		SVAR rgbIntensity_set2  = root:Packages:IR2L_NLSQF:rgbIntensity_set2
		SVAR rgbIntensity_set3  = root:Packages:IR2L_NLSQF:rgbIntensity_set3
		SVAR rgbIntensity_set4  = root:Packages:IR2L_NLSQF:rgbIntensity_set4
		SVAR rgbIntensity_set5  = root:Packages:IR2L_NLSQF:rgbIntensity_set5
		SVAR rgbIntensity_set6  = root:Packages:IR2L_NLSQF:rgbIntensity_set6
		SVAR rgbIntensity_set7  = root:Packages:IR2L_NLSQF:rgbIntensity_set7
		SVAR rgbIntensity_set8  = root:Packages:IR2L_NLSQF:rgbIntensity_set8
		SVAR rgbIntensity_set9  = root:Packages:IR2L_NLSQF:rgbIntensity_set9
		SVAR rgbIntensity_set10 = root:Packages:IR2L_NLSQF:rgbIntensity_set10

		SVAR rgbIntensityLine_set1  = root:Packages:IR2L_NLSQF:rgbIntensityLine_set1
		SVAR rgbIntensityLine_set2  = root:Packages:IR2L_NLSQF:rgbIntensityLine_set2
		SVAR rgbIntensityLine_set3  = root:Packages:IR2L_NLSQF:rgbIntensityLine_set3
		SVAR rgbIntensityLine_set4  = root:Packages:IR2L_NLSQF:rgbIntensityLine_set4
		SVAR rgbIntensityLine_set5  = root:Packages:IR2L_NLSQF:rgbIntensityLine_set5
		SVAR rgbIntensityLine_set6  = root:Packages:IR2L_NLSQF:rgbIntensityLine_set6
		SVAR rgbIntensityLine_set7  = root:Packages:IR2L_NLSQF:rgbIntensityLine_set7
		SVAR rgbIntensityLine_set8  = root:Packages:IR2L_NLSQF:rgbIntensityLine_set8
		SVAR rgbIntensityLine_set9  = root:Packages:IR2L_NLSQF:rgbIntensityLine_set9
		SVAR rgbIntensityLine_set10 = root:Packages:IR2L_NLSQF:rgbIntensityLine_set10

		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set1)=" + rgbIntensity_set1)
		Execute("ModifyGraph/Z /W=LSQF_MainGraph rgb(Intensity_set2)=" + rgbIntensity_set2)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set3)=" + rgbIntensity_set3)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set4)=" + rgbIntensity_set4)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set5)=" + rgbIntensity_set5)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set6)=" + rgbIntensity_set6)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set7)=" + rgbIntensity_set7)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set8)=" + rgbIntensity_set8)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set9)=" + rgbIntensity_set9)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set10)=" + rgbIntensity_set10)

		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set1)=0,lsize(IntensityModel_set1)=2, rgb(IntensityModel_set1)=" + rgbIntensityLine_set1)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set2)=0,lsize(IntensityModel_set2)=2, rgb(IntensityModel_set2)=" + rgbIntensityLine_set2)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set3)=0,lsize(IntensityModel_set3)=2, rgb(IntensityModel_set3)=" + rgbIntensityLine_set3)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set4)=0,lsize(IntensityModel_set4)=2, rgb(IntensityModel_set4)=" + rgbIntensityLine_set4)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set5)=0,lsize(IntensityModel_set5)=2, rgb(IntensityModel_set5)=" + rgbIntensityLine_set5)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set6)=0,lsize(IntensityModel_set6)=2, rgb(IntensityModel_set6)=" + rgbIntensityLine_set6)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set7)=0,lsize(IntensityModel_set7)=2, rgb(IntensityModel_set7)=" + rgbIntensityLine_set7)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set8)=0,lsize(IntensityModel_set8)=2, rgb(IntensityModel_set8)=" + rgbIntensityLine_set8)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set9)=0,lsize(IntensityModel_set9)=2, rgb(IntensityModel_set9)=" + rgbIntensityLine_set9)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set10)=0,lsize(IntensityModel_set10)=2, rgb(IntensityModel_set10)=" + rgbIntensityLine_set10)
	endif
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_FormatLegend()

	DoWindow LSQF_MainGraph
	if(V_Flag)
		string Ltext = "", curFldrName
		string AllWaves = TraceNameList("LSQF_MainGraph", ";", 1)
		variable i, curset, curpop
		NVAR   LegendUseWaveName   = root:Packages:IrenaConfigFolder:LegendUseWaveName
		NVAR   LegendUseFolderName = root:Packages:IrenaConfigFolder:LegendUseFolderName
		NVAR   LegendSize          = root:Packages:IrenaConfigFolder:LegendSize
		string LegSizeStr          = ""
		if(LegendSize < 10)
			legSizeStr = "0" + num2str(LegendSize)
		else
			LegSizeStr = num2str(LegendSize)
		endif
		string UserDataSetNameL
		string curIntNameL
		string IsModel = ""
		for(i = 0; i < ItemsInList(AllWaves); i += 1)
			//Need to decide if this is "Intensity_setX" or IntensityModel_setX of IntensityModel_setX_popY
			if(strlen(stringFromList(i, AllWaves)) < 16)
				curset = str2num(stringFromList(i, AllWaves)[13, Inf])
				if(numtype(curset) != 0)
					return 1
				endif
				SVAR curSource       = $("root:Packages:IR2L_NLSQF:FolderName_set" + num2str(curset))
				SVAR UserDataSetName = $("root:Packages:IR2L_NLSQF:UserDataSetName_set" + num2str(curset))
				UserDataSetNameL = UserDataSetName
				curFldrName      = stringFromList(ItemsInList(curSource, ":") - 1, curSource, ":")
				SVAR curIntName = $("root:Packages:IR2L_NLSQF:IntensityDataName_set" + num2str(curset))
				curIntNameL = curIntName
				isModel     = ""
			elseif(strlen(stringFromList(i, AllWaves)) < 21) //should be the IntensityModel_setX
				curset = str2num(stringFromList(i, AllWaves)[18, Inf])
				if(numtype(curset) != 0)
					return 1
				endif
				SVAR curSource       = $("root:Packages:IR2L_NLSQF:FolderName_set" + num2str(curset))
				SVAR UserDataSetName = $("root:Packages:IR2L_NLSQF:UserDataSetName_set" + num2str(curset))
				UserDataSetNameL = "Model for " + UserDataSetName
				curFldrName      = stringFromList(ItemsInList(curSource, ":") - 1, curSource, ":")
				SVAR curIntName = $("root:Packages:IR2L_NLSQF:IntensityDataName_set" + num2str(curset))
				curIntNameL = "Model for " + curIntName
				IsModel     = "Model for "
			else //should be the IntensityModel_setX_popY
				curset = str2num(stringFromList(i, AllWaves)[18, 19])
				if(numtype(curset) != 0)
					return 1
				endif
				if(curset < 10)
					curpop = str2num(stringFromList(i, AllWaves)[23, Inf])
				else
					curpop = str2num(stringFromList(i, AllWaves)[24, Inf])
				endif
				SVAR UserName        = $("root:Packages:IR2L_NLSQF:UserName_pop" + num2str(curpop))
				SVAR curSource       = $("root:Packages:IR2L_NLSQF:FolderName_set" + num2str(curset))
				SVAR UserDataSetName = $("root:Packages:IR2L_NLSQF:UserDataSetName_set" + num2str(curset))
				if(strlen(UserName) < 1) //user did tno set name, use Pop X as name...
					UserDataSetNameL = "Pop " + num2str(curpop) + " model for " + UserDataSetName
				else
					UserDataSetNameL = UserName + " for " + UserDataSetName
				endif
				curFldrName = stringFromList(ItemsInList(curSource, ":") - 1, curSource, ":")
				SVAR curIntName = $("root:Packages:IR2L_NLSQF:IntensityDataName_set" + num2str(curset))
				curIntNameL = "Pop " + num2str(curpop) + " Model for " + curIntName
				IsModel     = "Pop " + num2str(curpop) + " Model for "
			endif
			Ltext += "\\Z" + legSizeStr + "\\s(" + stringFromList(i, AllWaves) + ") "
			if(strlen(UserDataSetName) > 0)
				Ltext += " " + UserDataSetNameL
			else
				if(!LegendUseFolderName && !LegendUseWaveName)
					Ltext += " " + IsModel + StringFromList(1, stringFromList(i, AllWaves), "_")
				endif
				if(LegendUseFolderName)
					Ltext += " " + IsModel + curFldrName
				endif
				if(LegendUseWaveName)
					Ltext += " " + curIntNameL
				endif
			endif
			Ltext += "\r"
		endfor
		Ltext = Ltext[0, (strlen(Ltext) - 2)]
		Legend/C/W=LSQF_MainGraph/N=Ltext/J/F=0/A=LB Ltext
	endif
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

Function IR2L_Fitting(SkipDialogs)
	variable SkipDialogs //if set to 0 we present dialogs for user, if 1 we skip them. Called from scripting tool

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	SVAR/Z AdditionalFittingConstraints = root:Packages:IR2L_NLSQF:AdditionalFittingConstraints
	NVAR   UseGeneticOptimization       = root:Packages:IR2L_NLSQF:UseGeneticOptimization
	if(!SVAR_Exists(AdditionalFittingConstraints))
		string/G AdditionalFittingConstraints
	endif
	if(UseGeneticOptimization) //not availabel for GenOpt for now...
		AdditionalFittingConstraints = ""
	endif
	NVAR NoFittingLimits = root:Packages:IR2L_NLSQF:NoFittingLimits

	if(NoFittingLimits)
		IR2L_FixLimits(1) //let's avoid dialog bombing on limits...
	endif
	//Create the fitting parameters, these will have _pop added and we need to add them to list of parameters to fit...
	string ListOfPopulationVariables = ""
	string tempStrN                  = ""

	Make/O/N=0/T T_Constraints, ParamNamesK, ParamNames
	T_Constraints = ""
	ParamNamesK   = ""
	ParamNames    = ""
	Make/D/N=0/O W_coef
	Make/O/N=(0, 2) Gen_Constraints
	Make/T/N=0/O CoefNames
	Make/T/FREE/N=0 LowLimCoefName, HighLimCoefNames
	CoefNames = ""

	variable i, j //i goes through all items in list, j is 1 to 6 - populations
	//first handle coefficients which are easy - those existing all the time... Volume is the only one at this time...
	//added Unified level, so now Volume may not exist either...
	ListOfPopulationVariables = "Volume;"
	for(j = 1; j < 11; j += 1)
		NVAR UseThePop  = $("root:Packages:IR2L_NLSQF:UseThePop_pop" + num2str(j))
		SVAR FormFactor = $("root:Packages:IR2L_NLSQF:FormFactor_pop" + num2str(j))
		SVAR Model      = $("root:Packages:IR2L_NLSQF:Model_pop" + num2str(j))
		if(UseThePop && stringmatch(Model, "Size dist."))
			for(i = 0; i < ItemsInList(ListOfPopulationVariables); i += 1)
				NVAR CurVarTested = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j))
				NVAR FitCurVar    = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Fit_pop" + num2str(j))
				NVAR CuVarMin     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j))
				NVAR CuVarMax     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Max_pop" + num2str(j))
				if(FitCurVar) //are we fitting this variable?
					if((CurVarTested < CuVarMin || CurVarTested > CuVarMax) && !NoFittingLimits)
						DoAlert/T="Limits major problem" 1, "Limits for ; " + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j) + " are wrong, fix (yes) or abort (NO)?"
						if(V_Flag == 1) //fix limits
							CuVarMin = 0.5 * CurVarTested
							CuVarMax = 2 * CurVarTested
						else
							Print "Fix limits for : " + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j)
							Print "Current value is : " + num2str(CurVarTested)
							Print "Low limit is : " + num2str(CuVarMin)
							Print "High limit is : " + num2str(CuVarMax)
							setDataFolder oldDf
							abort
						endif
					endif
					Redimension/N=(numpnts(W_coef) + 1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, ParamNamesK
					Redimension/N=(numpnts(T_Constraints) + 2) T_Constraints
					W_Coef[numpnts(W_Coef) - 1]               = CurVarTested
					CoefNames[numpnts(CoefNames) - 1]         = stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j)
					LowLimCoefName[numpnts(CoefNames) - 1]    = stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j)
					HighLimCoefNames[numpnts(CoefNames) - 1]  = stringfromList(i, ListOfPopulationVariables) + "Max_pop" + num2str(j)
					ParamNamesK[numpnts(CoefNames) - 1]       = {"K" + num2str(numpnts(W_coef) - 1)}
					ParamNames[numpnts(CoefNames) - 1]        = {"Volume"}
					T_Constraints[numpnts(T_Constraints) - 2] = {"K" + num2str(numpnts(W_coef) - 1) + " > " + num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints) - 1] = {"K" + num2str(numpnts(W_coef) - 1) + " < " + num2str(CuVarMax)}
					Redimension/N=((numpnts(W_coef)), 2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames) - 1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames) - 1][1] = CuVarMax
				endif
			endfor
		endif
	endfor

	//second handle coefficients which are dependen on distribution shape....
	//Distribution parameters, done only when Size dist..
	for(j = 1; j < 11; j += 1)
		NVAR UseThePop        = $("root:Packages:IR2L_NLSQF:UseThePop_pop" + num2str(j))
		SVAR PopSizeDistShape = $("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop" + num2str(j))
		SVAR FormFactor       = $("root:Packages:IR2L_NLSQF:FormFactor_pop" + num2str(j))
		SVAR Model            = $("root:Packages:IR2L_NLSQF:Model_pop" + num2str(j))
		if(UseThePop && stringmatch(Model, "Size dist."))
			if(stringmatch(PopSizeDistShape, "Gauss"))
				ListOfPopulationVariables = "GMeanSize;GWidth;"
			elseif(stringmatch(PopSizeDistShape, "LSW"))
				ListOfPopulationVariables = "LSWLocation;"
			elseif(stringmatch(PopSizeDistShape, "Schulz-Zimm"))
				ListOfPopulationVariables = "SZMeanSize;SZWidth;"
			elseif(stringmatch(PopSizeDistShape, "Ardell"))
				ListOfPopulationVariables = "ArdLocation;ArdParameter;"
			else
				ListOfPopulationVariables = "LNMinSize;LNMeanSize;LNSdeviation;"
			endif
			if(UseThePop)
				for(i = 0; i < ItemsInList(ListOfPopulationVariables); i += 1)
					NVAR CurVarTested = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j))
					NVAR FitCurVar    = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Fit_pop" + num2str(j))
					NVAR CuVarMin     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j))
					NVAR CuVarMax     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Max_pop" + num2str(j))
					if(FitCurVar) //are we fitting this variable?
						if((CurVarTested < CuVarMin || CurVarTested > CuVarMax) && !NoFittingLimits)
							DoAlert/T="Limits major problem" 1, "Limits for ; " + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j) + " are wrong, fix (yes) or abort (NO)?"
							if(V_Flag == 1) //fix limits
								CuVarMin = 0.5 * CurVarTested
								CuVarMax = 2 * CurVarTested
							else
								Print "Fix limits for : " + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j)
								Print "Current value is : " + num2str(CurVarTested)
								Print "Low limit is : " + num2str(CuVarMin)
								Print "High limit is : " + num2str(CuVarMax)
								setDataFolder oldDf
								abort
							endif
						endif
						Redimension/N=(numpnts(W_coef) + 1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, ParamNamesK
						Redimension/N=(numpnts(T_Constraints) + 2) T_Constraints
						W_Coef[numpnts(W_Coef) - 1]               = CurVarTested
						CoefNames[numpnts(CoefNames) - 1]         = stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j)
						LowLimCoefName[numpnts(CoefNames) - 1]    = stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j)
						HighLimCoefNames[numpnts(CoefNames) - 1]  = stringfromList(i, ListOfPopulationVariables) + "Max_pop" + num2str(j)
						ParamNamesK[numpnts(CoefNames) - 1]       = {"K" + num2str(numpnts(W_coef) - 1)}
						ParamNames[numpnts(CoefNames) - 1]        = {stringfromList(i, ListOfPopulationVariables)}
						T_Constraints[numpnts(T_Constraints) - 2] = {"K" + num2str(numpnts(W_coef) - 1) + " > " + num2str(CuVarMin)}
						T_Constraints[numpnts(T_Constraints) - 1] = {"K" + num2str(numpnts(W_coef) - 1) + " < " + num2str(CuVarMax)}
						Redimension/N=((numpnts(W_coef)), 2) Gen_Constraints
						Gen_Constraints[numpnts(CoefNames) - 1][0] = CuVarMin
						Gen_Constraints[numpnts(CoefNames) - 1][1] = CuVarMax
					endif
				endfor
			endif
		endif
	endfor

	//next structure factor coefficients , valid also for Unified levels...
	ListOfPopulationVariables = "StructureParam1;StructureParam2;StructureParam3;StructureParam4;StructureParam5;StructureParam6;"
	for(j = 1; j < 11; j += 1)
		NVAR UseThePop  = $("root:Packages:IR2L_NLSQF:UseThePop_pop" + num2str(j))
		SVAR FormFactor = $("root:Packages:IR2L_NLSQF:FormFactor_pop" + num2str(j))
		SVAR Model      = $("root:Packages:IR2L_NLSQF:Model_pop" + num2str(j))
		if(UseThePop && (stringmatch(Model, "Size dist.") || stringmatch(Model, "Unified level")))
			//this checks in the checkboxes for fitting are nto set incorrectly...
			SVAR   StrFac   = $("root:Packages:IR2L_NLSQF:StructureFactor_pop" + num2str(j))
			string FitP1Str = "root:Packages:IR2L_NLSQF:StructureParam1Fit_pop" + num2str(j)
			string FitP2Str = "root:Packages:IR2L_NLSQF:StructureParam2Fit_pop" + num2str(j)
			string FitP3Str = "root:Packages:IR2L_NLSQF:StructureParam3Fit_pop" + num2str(j)
			string FitP4Str = "root:Packages:IR2L_NLSQF:StructureParam4Fit_pop" + num2str(j)
			string FitP5Str = "root:Packages:IR2L_NLSQF:StructureParam5Fit_pop" + num2str(j)
			string FitP6Str = "root:Packages:IR2L_NLSQF:StructureParam6Fit_pop" + num2str(j)
			IR2S_CheckFitParameter(StrFac, FitP1Str, FitP2Str, FitP3Str, FitP4Str, FitP5Str, FitP6Str)
			for(i = 0; i < ItemsInList(ListOfPopulationVariables); i += 1)
				NVAR CurVarTested = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j))
				NVAR FitCurVar    = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Fit_pop" + num2str(j))
				NVAR CuVarMin     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j))
				NVAR CuVarMax     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Max_pop" + num2str(j))
				if(FitCurVar) //are we fitting this variable?
					if((CurVarTested < CuVarMin || CurVarTested > CuVarMax) && !NoFittingLimits)
						DoAlert/T="Limits major problem" 1, "Limits for ; " + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j) + " are wrong, fix (yes) or abort (NO)?"
						if(V_Flag == 1) //fix limits
							CuVarMin = 0.5 * CurVarTested
							CuVarMax = 2 * CurVarTested
						else
							Print "Fix limits for : " + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j)
							Print "Current value is : " + num2str(CurVarTested)
							Print "Low limit is : " + num2str(CuVarMin)
							Print "High limit is : " + num2str(CuVarMax)
							setDataFolder oldDf
							abort
						endif
					endif
					Redimension/N=(numpnts(W_coef) + 1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, ParamNamesK
					Redimension/N=(numpnts(T_Constraints) + 2) T_Constraints
					W_Coef[numpnts(W_Coef) - 1]               = CurVarTested
					CoefNames[numpnts(CoefNames) - 1]         = stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j)
					LowLimCoefName[numpnts(CoefNames) - 1]    = stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j)
					HighLimCoefNames[numpnts(CoefNames) - 1]  = stringfromList(i, ListOfPopulationVariables) + "Max_pop" + num2str(j)
					ParamNamesK[numpnts(CoefNames) - 1]       = {"K" + num2str(numpnts(W_coef) - 1)}
					ParamNames[numpnts(CoefNames) - 1]        = {IR1T_IdentifySFParamName(StrFac, i + 1)}
					T_Constraints[numpnts(T_Constraints) - 2] = {"K" + num2str(numpnts(W_coef) - 1) + " > " + num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints) - 1] = {"K" + num2str(numpnts(W_coef) - 1) + " < " + num2str(CuVarMax)}
					Redimension/N=((numpnts(W_coef)), 2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames) - 1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames) - 1][1] = CuVarMax
				endif
			endfor
		endif
	endfor

	//next the most complicated one - form factor parameters... Need to set the checkboxes right accoring to selected for factor so we do not have to bother here
	ListOfPopulationVariables  = "FormFactor_Param1;"
	ListOfPopulationVariables += "FormFactor_Param2;"
	ListOfPopulationVariables += "FormFactor_Param3;"
	ListOfPopulationVariables += "FormFactor_Param4;"
	ListOfPopulationVariables += "FormFactor_Param5;"
	ListOfPopulationVariables += "FormFactor_Param6;"
	for(j = 1; j < 11; j += 1)
		NVAR UseThePop  = $("root:Packages:IR2L_NLSQF:UseThePop_pop" + num2str(j))
		SVAR FormFactor = $("root:Packages:IR2L_NLSQF:FormFactor_pop" + num2str(j))
		SVAR Model      = $("root:Packages:IR2L_NLSQF:Model_pop" + num2str(j))
		if(UseThePop && stringmatch(Model, "Size dist."))
			for(i = 0; i < ItemsInList(ListOfPopulationVariables); i += 1)
				NVAR CurVarTested = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j))
				NVAR FitCurVar    = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Fit_pop" + num2str(j))
				NVAR CuVarMin     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j))
				NVAR CuVarMax     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Max_pop" + num2str(j))
				if(FitCurVar) //are we fitting this variable?
					if((CurVarTested < CuVarMin || CurVarTested > CuVarMax) && !NoFittingLimits)
						DoAlert/T="Limits major problem" 1, "Limits for ; " + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j) + " are wrong, fix (yes) or abort (NO)?"
						if(V_Flag == 1) //fix limits
							CuVarMin = 0.5 * CurVarTested
							CuVarMax = 2 * CurVarTested
						else
							Print "Fix limits for : " + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j)
							Print "Current value is : " + num2str(CurVarTested)
							Print "Low limit is : " + num2str(CuVarMin)
							Print "High limit is : " + num2str(CuVarMax)
							setDataFolder oldDf
							abort
						endif
					endif
					Redimension/N=(numpnts(W_coef) + 1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, ParamNamesK
					Redimension/N=(numpnts(T_Constraints) + 2) T_Constraints
					W_Coef[numpnts(W_Coef) - 1]               = CurVarTested
					CoefNames[numpnts(CoefNames) - 1]         = stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j)
					LowLimCoefName[numpnts(CoefNames) - 1]    = stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j)
					HighLimCoefNames[numpnts(CoefNames) - 1]  = stringfromList(i, ListOfPopulationVariables) + "Max_pop" + num2str(j)
					ParamNamesK[numpnts(CoefNames) - 1]       = {"K" + num2str(numpnts(W_coef) - 1)}
					ParamNames[numpnts(CoefNames) - 1]        = {IR1T_IdentifyFFParamName(FormFactor, i + 1)}
					T_Constraints[numpnts(T_Constraints) - 2] = {"K" + num2str(numpnts(W_coef) - 1) + " > " + num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints) - 1] = {"K" + num2str(numpnts(W_coef) - 1) + " < " + num2str(CuVarMax)}
					Redimension/N=((numpnts(W_coef)), 2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames) - 1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames) - 1][1] = CuVarMax
				endif
			endfor
		endif
	endfor

	ListOfPopulationVariables = "UF_G;UF_Rg;UF_P;UF_B;UF_RGCO;"
	for(j = 1; j < 11; j += 1)
		NVAR UseThePop  = $("root:Packages:IR2L_NLSQF:UseThePop_pop" + num2str(j))
		SVAR FormFactor = $("root:Packages:IR2L_NLSQF:FormFactor_pop" + num2str(j))
		SVAR Model      = $("root:Packages:IR2L_NLSQF:Model_pop" + num2str(j))
		if(UseThePop && stringmatch(Model, "Unified level"))
			for(i = 0; i < ItemsInList(ListOfPopulationVariables); i += 1)
				NVAR CurVarTested = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j))
				NVAR FitCurVar    = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Fit_pop" + num2str(j))
				NVAR CuVarMin     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j))
				NVAR CuVarMax     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Max_pop" + num2str(j))
				if(FitCurVar) //are we fitting this variable?
					if((CurVarTested < CuVarMin || CurVarTested > CuVarMax) && !NoFittingLimits)
						DoAlert/T="Limits major problem" 1, "Limits for ; " + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j) + " are wrong, fix (yes) or abort (NO)?"
						if(V_Flag == 1) //fix limits
							CuVarMin = 0.5 * CurVarTested
							CuVarMax = 2 * CurVarTested
						else
							Print "Fix limits for : " + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j)
							Print "Current value is : " + num2str(CurVarTested)
							Print "Low limit is : " + num2str(CuVarMin)
							Print "High limit is : " + num2str(CuVarMax)
							setDataFolder oldDf
							abort
						endif
					endif
					Redimension/N=(numpnts(W_coef) + 1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, ParamNamesK
					Redimension/N=(numpnts(T_Constraints) + 2) T_Constraints
					W_Coef[numpnts(W_Coef) - 1]               = CurVarTested
					CoefNames[numpnts(CoefNames) - 1]         = stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j)
					LowLimCoefName[numpnts(CoefNames) - 1]    = stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j)
					HighLimCoefNames[numpnts(CoefNames) - 1]  = stringfromList(i, ListOfPopulationVariables) + "Max_pop" + num2str(j)
					ParamNamesK[numpnts(CoefNames) - 1]       = {"K" + num2str(numpnts(W_coef) - 1)}
					ParamNames[numpnts(CoefNames) - 1]        = {stringfromList(i, ListOfPopulationVariables)[3, 8]}
					T_Constraints[numpnts(T_Constraints) - 2] = {"K" + num2str(numpnts(W_coef) - 1) + " > " + num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints) - 1] = {"K" + num2str(numpnts(W_coef) - 1) + " < " + num2str(CuVarMax)}
					Redimension/N=((numpnts(W_coef)), 2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames) - 1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames) - 1][1] = CuVarMax
				endif
			endfor
		endif
	endfor

	ListOfPopulationVariables = "DiffPeakPar1;DiffPeakPar2;DiffPeakPar3;DiffPeakPar4;"
	for(j = 1; j < 11; j += 1)
		NVAR UseThePop   = $("root:Packages:IR2L_NLSQF:UseThePop_pop" + num2str(j))
		SVAR PeakProfile = $("root:Packages:IR2L_NLSQF:DiffPeakProfile_pop" + num2str(j))
		SVAR Model       = $("root:Packages:IR2L_NLSQF:Model_pop" + num2str(j))
		if(UseThePop && stringmatch(Model, "Diffraction Peak"))
			if(stringmatch(PeakProfile, "Pseudo-Voigt") || stringmatch(PeakProfile, "Pearson_VII") || stringmatch(PeakProfile, "Modif_Gauss") || stringmatch(PeakProfile, "SkewedNormal"))
				ListOfPopulationVariables = "DiffPeakPar1;DiffPeakPar2;DiffPeakPar3;DiffPeakPar4;" //has 4 parameters
			else
				ListOfPopulationVariables = "DiffPeakPar1;DiffPeakPar2;DiffPeakPar3;"
			endif
			for(i = 0; i < ItemsInList(ListOfPopulationVariables); i += 1)
				NVAR CurVarTested = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j))
				NVAR FitCurVar    = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Fit_pop" + num2str(j))
				NVAR CuVarMin     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j))
				NVAR CuVarMax     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Max_pop" + num2str(j))
				if(FitCurVar) //are we fitting this variable?
					if((CurVarTested < CuVarMin || CurVarTested > CuVarMax) && !NoFittingLimits)
						DoAlert/T="Limits major problem" 1, "Limits for ; " + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j) + " are wrong, fix (yes) or abort (NO)?"
						if(V_Flag == 1) //fix limits
							CuVarMin = 0.5 * CurVarTested
							CuVarMax = 2 * CurVarTested
						else
							Print "Fix limits for : " + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j)
							Print "Current value is : " + num2str(CurVarTested)
							Print "Low limit is : " + num2str(CuVarMin)
							Print "High limit is : " + num2str(CuVarMax)
							setDataFolder oldDf
							abort
						endif
					endif
					Redimension/N=(numpnts(W_coef) + 1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, ParamNamesK
					Redimension/N=(numpnts(T_Constraints) + 2) T_Constraints
					W_Coef[numpnts(W_Coef) - 1]               = CurVarTested
					CoefNames[numpnts(CoefNames) - 1]         = stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j)
					LowLimCoefName[numpnts(CoefNames) - 1]    = stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j)
					HighLimCoefNames[numpnts(CoefNames) - 1]  = stringfromList(i, ListOfPopulationVariables) + "Max_pop" + num2str(j)
					ParamNamesK[numpnts(CoefNames) - 1]       = {"K" + num2str(numpnts(W_coef) - 1)}
					T_Constraints[numpnts(T_Constraints) - 2] = {"K" + num2str(numpnts(W_coef) - 1) + " > " + num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints) - 1] = {"K" + num2str(numpnts(W_coef) - 1) + " < " + num2str(CuVarMax)}
					Redimension/N=((numpnts(W_coef)), 2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames) - 1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames) - 1][1] = CuVarMax
					//meaningful names...
					switch(i) // numeric switch
						case 0: // execute if case matches expression
							tempStrN = "Scaling"
							break // exit from switch
						case 1: // execute if case matches expression
							tempStrN = "Position"
							break
						case 2: // execute if case matches expression
							tempStrN = "Width"
							break
						case 3: // execute if case matches expression
							tempStrN = "Eta"
							break
					endswitch
					ParamNames[numpnts(CoefNames) - 1] = {tempStrN}
				endif
			endfor
		endif
	endfor
	//Mass fractal
	ListOfPopulationVariables = "MassFrPhi;MassFrRadius;MassFrDv;MassFrKsi;"
	for(j = 1; j < 11; j += 1)
		NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop" + num2str(j))
		SVAR Model     = $("root:Packages:IR2L_NLSQF:Model_pop" + num2str(j))
		if(UseThePop && stringmatch(Model, "MassFractal"))
			for(i = 0; i < ItemsInList(ListOfPopulationVariables); i += 1)
				NVAR CurVarTested = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j))
				NVAR FitCurVar    = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Fit_pop" + num2str(j))
				NVAR CuVarMin     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j))
				NVAR CuVarMax     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Max_pop" + num2str(j))
				if(FitCurVar) //are we fitting this variable?
					if((CurVarTested < CuVarMin || CurVarTested > CuVarMax) && !NoFittingLimits)
						DoAlert/T="Limits major problem" 1, "Limits for ; " + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j) + " are wrong, fix (yes) or abort (NO)?"
						if(V_Flag == 1) //fix limits
							CuVarMin = 0.5 * CurVarTested
							CuVarMax = 2 * CurVarTested
						else
							Print "Fix limits for : " + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j)
							Print "Current value is : " + num2str(CurVarTested)
							Print "Low limit is : " + num2str(CuVarMin)
							Print "High limit is : " + num2str(CuVarMax)
							setDataFolder oldDf
							abort
						endif
					endif
					Redimension/N=(numpnts(W_coef) + 1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, ParamNamesK
					Redimension/N=(numpnts(T_Constraints) + 2) T_Constraints
					W_Coef[numpnts(W_Coef) - 1]               = CurVarTested
					CoefNames[numpnts(CoefNames) - 1]         = stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j)
					LowLimCoefName[numpnts(CoefNames) - 1]    = stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j)
					HighLimCoefNames[numpnts(CoefNames) - 1]  = stringfromList(i, ListOfPopulationVariables) + "Max_pop" + num2str(j)
					ParamNamesK[numpnts(CoefNames) - 1]       = {"K" + num2str(numpnts(W_coef) - 1)}
					T_Constraints[numpnts(T_Constraints) - 2] = {"K" + num2str(numpnts(W_coef) - 1) + " > " + num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints) - 1] = {"K" + num2str(numpnts(W_coef) - 1) + " < " + num2str(CuVarMax)}
					Redimension/N=((numpnts(W_coef)), 2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames) - 1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames) - 1][1] = CuVarMax
					//meaningful names...
					switch(i) // numeric switch
						case 0: // execute if case matches expression
							tempStrN = "Particle Volume"
							break // exit from switch
						case 1: // execute if case matches expression
							tempStrN = "Radius"
							break
						case 2: // execute if case matches expression
							tempStrN = "Dv (Fractal dim)"
							break
						case 3: // execute if case matches expression
							tempStrN = "Corr. Length"
							break
					endswitch
					ParamNames[numpnts(CoefNames) - 1] = {tempStrN}
				endif
			endfor
		endif
	endfor
	//Surface fractal
	//  ListOfPopulationVariablesFR = "SurfFrSurf;SurfFrKsi;SurfFrDS;SurfFrSurfFit;SurfFrKsiFit;SurfFrDSFit;SurfFrSurfMin;SurfFrKsiMin"

	ListOfPopulationVariables = "SurfFrSurf;SurfFrDS;SurfFrKsi;"
	for(j = 1; j < 11; j += 1)
		NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop" + num2str(j))
		SVAR Model     = $("root:Packages:IR2L_NLSQF:Model_pop" + num2str(j))
		if(UseThePop && stringmatch(Model, "SurfaceFractal"))
			for(i = 0; i < ItemsInList(ListOfPopulationVariables); i += 1)
				NVAR CurVarTested = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j))
				NVAR FitCurVar    = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Fit_pop" + num2str(j))
				NVAR CuVarMin     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j))
				NVAR CuVarMax     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfPopulationVariables) + "Max_pop" + num2str(j))
				if(FitCurVar) //are we fitting this variable?
					if((CurVarTested < CuVarMin || CurVarTested > CuVarMax) && !NoFittingLimits)
						DoAlert/T="Limits major problem" 1, "Limits for ; " + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j) + " are wrong, fix (yes) or abort (NO)?"
						if(V_Flag == 1) //fix limits
							CuVarMin = 0.5 * CurVarTested
							CuVarMax = 2 * CurVarTested
						else
							Print "Fix limits for : " + stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j)
							Print "Current value is : " + num2str(CurVarTested)
							Print "Low limit is : " + num2str(CuVarMin)
							Print "High limit is : " + num2str(CuVarMax)
							setDataFolder oldDf
							abort
						endif
					endif
					Redimension/N=(numpnts(W_coef) + 1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, ParamNamesK
					Redimension/N=(numpnts(T_Constraints) + 2) T_Constraints
					W_Coef[numpnts(W_Coef) - 1]               = CurVarTested
					CoefNames[numpnts(CoefNames) - 1]         = stringfromList(i, ListOfPopulationVariables) + "_pop" + num2str(j)
					LowLimCoefName[numpnts(CoefNames) - 1]    = stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j)
					HighLimCoefNames[numpnts(CoefNames) - 1]  = stringfromList(i, ListOfPopulationVariables) + "Max_pop" + num2str(j)
					ParamNamesK[numpnts(CoefNames) - 1]       = {"K" + num2str(numpnts(W_coef) - 1)}
					T_Constraints[numpnts(T_Constraints) - 2] = {"K" + num2str(numpnts(W_coef) - 1) + " > " + num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints) - 1] = {"K" + num2str(numpnts(W_coef) - 1) + " < " + num2str(CuVarMax)}
					Redimension/N=((numpnts(W_coef)), 2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames) - 1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames) - 1][1] = CuVarMax
					//meaningful names...
					switch(i) // numeric switch
						case 0: // execute if case matches expression
							tempStrN = "Smooth surface"
							break // exit from switch
						case 1: // execute if case matches expression
							tempStrN = "Fractal Dimension"
							break
						case 2: // execute if case matches expression
							tempStrN = "Corr. Length"
							break
						case 3: // execute if case matches expression
							tempStrN = "Corr. Length"
							break
					endswitch
					ParamNames[numpnts(CoefNames) - 1] = {tempStrN}
				endif
			endfor
		endif
	endfor

	//Now background...
	string ListOfDataVariables = "Background;"
	NVAR   MultipleInputData   = root:Packages:IR2L_NLSQF:MultipleInputData
	variable LastDataSet
	LastDataSet = (MultipleInputData) ? 10 : 1
	for(j = 1; j <= LastDataSet; j += 1)
		NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseTheData_set" + num2str(j))
		if(UseThePop || !MultipleInputData)
			for(i = 0; i < ItemsInList(ListOfDataVariables); i += 1)
				NVAR CurVarTested = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfDataVariables) + "_set" + num2str(j))
				NVAR FitCurVar    = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfDataVariables) + "Fit_set" + num2str(j))
				NVAR CuVarMin     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfDataVariables) + "Min_set" + num2str(j))
				NVAR CuVarMax     = $("root:Packages:IR2L_NLSQF:" + stringfromList(i, ListOfDataVariables) + "Max_set" + num2str(j))
				if(FitCurVar) //are we fitting this variable?
					if((CurVarTested < CuVarMin || CurVarTested > CuVarMax) && !NoFittingLimits)
						DoAlert/T="Limits major problem" 1, "Limits for ; " + stringfromList(i, ListOfDataVariables) + "_set" + num2str(j) + " are wrong, fix (yes) or abort (NO)?"
						if(V_Flag == 1) //fix limits
							CuVarMin = 0.2 * CurVarTested
							CuVarMax = 5 * CurVarTested
						else
							Print "Fix limits for : " + stringfromList(i, ListOfDataVariables) + "_set" + num2str(j)
							Print "Current value is : " + num2str(CurVarTested)
							Print "Low limit is : " + num2str(CuVarMin)
							Print "High limit is : " + num2str(CuVarMax)
							setDataFolder oldDf
							abort
						endif
					endif
					Redimension/N=(numpnts(W_coef) + 1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, ParamNamesK
					Redimension/N=(numpnts(T_Constraints) + 2) T_Constraints
					W_Coef[numpnts(W_Coef) - 1]               = CurVarTested
					CoefNames[numpnts(CoefNames) - 1]         = stringfromList(i, ListOfDataVariables) + "_set" + num2str(j)
					LowLimCoefName[numpnts(CoefNames) - 1]    = stringfromList(i, ListOfDataVariables) + "Min_set" + num2str(j)
					HighLimCoefNames[numpnts(CoefNames) - 1]  = stringfromList(i, ListOfDataVariables) + "Max_set" + num2str(j)
					ParamNamesK[numpnts(CoefNames) - 1]       = {"K" + num2str(numpnts(W_coef) - 1)}
					ParamNames[numpnts(CoefNames) - 1]        = {"Background"}
					T_Constraints[numpnts(T_Constraints) - 2] = {"K" + num2str(numpnts(W_coef) - 1) + " > " + num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints) - 1] = {"K" + num2str(numpnts(W_coef) - 1) + " < " + num2str(CuVarMax)}
					Redimension/N=((numpnts(W_coef)), 2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames) - 1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames) - 1][1] = CuVarMax
				endif
			endfor
		endif
	endfor

	//Ok, all parameters should be dealt with, now the fitting...
	DoWindow/F LSQF_MainGraph
	variable QstartPoint, QendPoint
	Make/O/N=0 QWvForFit, IntWvForFit, EWvForFit
	for(j = 1; j <= LastDataSet; j += 1)
		NVAR UseTheSet = $("root:Packages:IR2L_NLSQF:UseTheData_set" + num2str(j))
		if(UseTheSet)
			WAVE Qwave  = $("root:Packages:IR2L_NLSQF:Q_set" + num2str(j))
			WAVE InWave = $("root:Packages:IR2L_NLSQF:Intensity_set" + num2str(j))
			WAVE Ewave  = $("root:Packages:IR2L_NLSQF:Error_set" + num2str(j))
			NVAR Qmin   = $("root:Packages:IR2L_NLSQF:Qmin_set" + num2str(j))
			NVAR Qmax   = $("root:Packages:IR2L_NLSQF:Qmax_set" + num2str(j))
			QstartPoint = BinarySearch(Qwave, Qmin)
			QendPoint   = BinarySearch(Qwave, Qmax)
			Duplicate/O/R=[QstartPoint, QendPoint] Qwave, QTemp
			Duplicate/O/R=[QstartPoint, QendPoint] InWave, IntTemp
			Duplicate/O/R=[QstartPoint, QendPoint] Ewave, ETemp
			Concatenate/NP/O {QWvForFit, QTemp}, TempWv
			Duplicate/O TempWv, QWvForFit
			Concatenate/NP/O {IntWvForFit, IntTemp}, TempWv
			Duplicate/O TempWv, IntWvForFit
			Concatenate/NP/O {EWvForFit, ETemp}, TempWv
			Duplicate/O TempWv, EWvForFit
		endif
	endfor
	if(numpnts(W_Coef) < 1)
		DoAlert 0, "Nothing to fit, select at least 1 parameter to fit"
		return 1
	endif
	wavestats/Q EWvForFit
	if(V_Min < 1e-20)
		Print "Warning: Looks like you have some very small uncertainties (ERRORS). Any point with uncertaitny (error) < = 0 is masked off and not fitted. "
		Print "Make sure your uncertainties are all LARGER than 0 for ALL points."
	endif
	if(V_avg <= 0)
		Print "Note: these are uncertainties after scaling/processing. Did you accidentally scale uncertainties by 0 ? "
		Abort "Uncertainties (ERRORS) make NO sense. Points with uncertainty (error) <= 0 are not fitted and this causes troubles. Fix uncertainties and try again. See history area for more details."
	endif

	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave = W_coef / 20
	variable V_chisq
	string HoldStr = ""
	for(i = 0; i < numpnts(CoefficientInput); i += 1)
		HoldStr += "0"
	endfor
	Duplicate/O IntWvForFit, MaskWaveGenOpt
	MaskWaveGenOpt = 1
	variable/G UserCanceled
	NVAR UserCanceled = root:Packages:IR2L_NLSQF:UserCanceled
	UserCanceled = 0

	if(NoFittingLimits && UseGeneticOptimization)
		Abort "Genetic optimization cannot be used without fitting limits!"
	endif

	if(!SkipDialogs)
		IR2L_CheckFittingParamsFnct()
		PauseForUser IR2L_CheckFittingParams
		if(UserCanceled)
			setDataFolder OldDf
			abort
		endif
	endif

	//add more constraints, is user added them or if thy already are in AdditionalFittingConstraints
	if(strlen(AdditionalFittingConstraints) > 3)
		AdditionalFittingConstraints = RemoveEnding(AdditionalFittingConstraints, ";") + ";"
	else
		AdditionalFittingConstraints = ""
	endif
	variable NumOfAddOnConstr = ItemsInList(AdditionalFittingConstraints, ";")
	if(NumOfAddOnConstr > 0) //there are some
		print "Added following fitting constraints : " + AdditionalFittingConstraints
		variable oldConstNum = numpnts(T_Constraints)
		redimension/N=(oldConstNum + NumOfAddOnConstr) T_Constraints
		variable ij
		for(ij = 0; ij < NumOfAddOnConstr; ij += 1)
			T_Constraints[oldConstNum + ij] = StringFromList(ij, AdditionalFittingConstraints, ";")
		endfor
	endif
	IR2L_RecordResults("before")
	Duplicate/O IntWvForFit, tempDestWave
	variable V_FitError = 0 //This should prevent errors from being generated
	//and now the fit...
	if(NoFittingLimits)
		if(UseGeneticOptimization)
#if Exists("gencurvefit") == 4
			Abort "Genetic optiomization cannot be used without fitting limits!"
			//gencurvefit  /I=1 /W=EWvForFit /M=MaskWaveGenOpt /N /TOL=0.002 /K={50,20,0.7,0.5} /X=QWvForFit IR2L_FitFunction, IntWvForFit  , W_Coef, HoldStr, Gen_Constraints
#else
			Abort "Genetic Optimization xop NOT installed. Install xop support and then try again"
#endif
		else
			FuncFit/N=0/W=0/Q/L=(numpnts(IntWvForFit)) IR2L_FitFunction, W_coef, IntWvForFit/X=QWvForFit/W=EWvForFit/I=1/E=E_wave/D
		endif
	else //old code, use fitting limits
		if(UseGeneticOptimization)
#if Exists("gencurvefit") == 4
			gencurvefit/I=1/W=EWvForFit/M=MaskWaveGenOpt/N/TOL=0.002/K={50, 20, 0.7, 0.5}/X=QWvForFit IR2L_FitFunction, IntWvForFit, W_Coef, HoldStr, Gen_Constraints
#else
			Abort "Genetic Optimization xop NOT installed. Install xop support and then try again"
#endif
		else
			FuncFit/N=0/W=0/Q/L=(numpnts(IntWvForFit)) IR2L_FitFunction, W_coef, IntWvForFit/X=QWvForFit/W=EWvForFit/I=1/E=E_wave/D/C=T_Constraints
		endif
	endif
	variable LimitsReached
	string   ListOfLimitsReachedParams
	LimitsReached             = 0
	ListOfLimitsReachedParams = ""
	if(V_FitError != 0) //there was error in fitting
		IR2L_ResetParamsAfterBadFit()
		Abort "Fitting error, check starting parameters and fitting limits"
	else //results OK, make sure the resulting values are set
		variable NumParams = numpnts(CoefNames)
		string ParamName
		for(i = 0; i < NumParams; i += 1)
			ParamName = CoefNames[i]
			NVAR TempVar = $(ParamName)
			ParamName = LowLimCoefName[i]
			NVAR TempVarLL = $(ParamName)
			ParamName = HighLimCoefNames[i]
			NVAR TempVarHL = $(ParamName)
			TempVar = W_Coef[i]
			if(abs(TempVarLL - TempVar) / TempVar < 0.02)
				LimitsReached              = 1
				ListOfLimitsReachedParams += ParamName + ";"
			endif
			if(abs(TempVarHL - TempVar) / TempVar < 0.02)
				LimitsReached              = 1
				ListOfLimitsReachedParams += ParamName + ";"
			endif
		endfor
		if(LimitsReached && !NoFittingLimits)
			print "Following parameters may have reached their Min/Max limits during fitting:"
			print ListOfLimitsReachedParams
			if(!SkipDialogs)
				DoAlert/T="Warning about possible fitting limits violation" 0, "One or more limits may have been reached, check history for the list of parameters"
			endif
		endif
	endif
	NVAR/Z FitFailed = root:Packages:IR2L_NLSQF:FitFailed
	if(NVAR_Exists(FitFailed))
		FitFailed = V_FitError
	endif

	variable/G AchievedChisq = V_chisq
	//	IR1U_GraphModelData()
	IR2L_RecordResults("after")
	//
	//	DoWIndow/F IR1U_ControlPanel
	//	IR1U_FixTabsInPanel()
	//
	KillWaves/Z T_Constraints, E_wave

	IR2L_CalculateIntensity(1, 0)

	setDataFolder OldDf
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

Function IR2L_CheckFittingParamsFnct()

	//KillWIndow/Z IR2L_CheckFittingParams
	//PauseUpdate    		// building window...
	NewPanel/K=1/W=(400, 140, 1000, 600) as "Check fitting parameters"
	Dowindow/C IR2L_CheckFittingParams
	SetDrawLayer UserBack
	SetDrawEnv fsize=20, fstyle=3, textrgb=(0, 0, 65280)
	DrawText 39, 28, "Modeling Params & Limits"
	NVAR UseGeneticOptimization = root:Packages:IR2L_NLSQF:UseGeneticOptimization
	if(UseGeneticOptimization)
		SetDrawEnv fstyle=1, fsize=14
		DrawText 10, 50, "For Gen Opt. verify fitted parameters. Make sure"
		SetDrawEnv fstyle=1, fsize=14
		DrawText 10, 70, "the parameter range is appropriate."
		SetDrawEnv fstyle=1, fsize=14
		DrawText 10, 90, "The whole range must be valid! It will be tested!"
		SetDrawEnv fstyle=1, fsize=14
		DrawText 10, 110, "       Then continue....."
	else
		SetDrawEnv fstyle=1, fsize=14
		DrawText 17, 55, "Verify the list of fitted parameters."
		SetDrawEnv fstyle=1, fsize=14
		DrawText 17, 75, "        Then continue......"
	endif
	Button CancelBtn, pos={27, 420}, size={150, 20}, proc=IR2L_CheckFitPrmsButtonProc, title="Cancel fitting"
	Button ContinueBtn, pos={187, 420}, size={150, 20}, proc=IR2L_CheckFitPrmsButtonProc, title="Continue fitting"
	if(!UseGeneticOptimization)
		SetVariable AdditionalFittingConstraints, size={500, 20}, pos={25, 400}, variable=AdditionalFittingConstraints, noproc, title="Add Fitting Constraints : "
		SetVariable AdditionalFittingConstraints, help={"Add usual Igor constraints separated by ; - e.g., \"K0<K1;\""}
	endif
	string fldrSav0 = GetDataFolder(1)
	SetDataFolder root:Packages:IR2L_NLSQF:
	WAVE Gen_Constraints, W_coef
	Duplicate/O W_coef, PopNumber
	WAVE/T CoefNames, ParamNamesK, ParamNames
	PopNumber = str2num((CoefNames[p])[strlen(CoefNames[p]) - 1, 40])
	SVAR AdditionalFittingConstraints
	SetDimLabel 1, 0, Min, Gen_Constraints
	SetDimLabel 1, 1, Max, Gen_Constraints
	variable i
	for(i = 0; i < numpnts(CoefNames); i += 1)
		SetDimLabel 0, i, $(CoefNames[i]), Gen_Constraints
	endfor
	if(UseGeneticOptimization)
		Edit/HOST=#/W=(0.05, 0.25, 0.95, 0.865) Gen_Constraints.ld W_coef
		ModifyTable format(Point)=1, width(Point)=0, alignment(W_coef.y)=1, sigDigits(W_coef.y)=4
		ModifyTable width(W_coef.y)=90, title(W_coef.y)="Start value", width(Gen_Constraints.l)=142
		ModifyTable alignment(Gen_Constraints.d)=1, sigDigits(Gen_Constraints.d)=4, width(Gen_Constraints.d)=72
		ModifyTable title(Gen_Constraints.d)="Limits"
	else
		Edit/HOST=#/W=(0.03, 0.18, 0.98, 0.865) ParamNamesK CoefNames, ParamNames, PopNumber, W_coef
		ModifyTable format(Point)=1, width(Point)=0, width(CoefNames)=144, title(CoefNames)="Internal name", title(ParamNamesK)="Constr.", width(ParamNamesK)=40
		ModifyTable width(W_coef.y)=90, title(W_coef.y)="Start value", alignment(ParamNamesK)=1, alignment=1
		ModifyTable width(PopNumber)=25, title(PopNumber)="Pop", alignment(PopNumber)=1
		ModifyTable width(ParamNames)=100, title(ParamNames)="Name"
	endif
	SetDataFolder fldrSav0
	RenameWindow #, T0
	SetActiveSubwindow ##
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_CheckFitPrmsButtonProc(ctrlName) : ButtonControl
	string ctrlName
	NVAR UserCanceled = root:Packages:IR2L_NLSQF:UserCanceled

	if(stringmatch(ctrlName, "*CancelBtn*"))
		UserCanceled = 1
		KillWIndow/Z IR2L_CheckFittingParams
	endif

	if(stringmatch(ctrlName, "*ContinueBtn*"))
		UserCanceled = 0
		KillWIndow/Z IR2L_CheckFittingParams
	endif

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_ResetParamsAfterBadFit()

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	variable i
	WAVE/Z   w         = root:Packages:IR2L_NLSQF:CoefficientInput
	WAVE/Z/T CoefNames = root:Packages:IR2L_NLSQF:CoefNames //text wave with names of parameters

	if(!WaveExists(w) || !WaveExists(CoefNames))
		abort
	endif

	variable NumParams = numpnts(CoefNames)
	string ParamName

	for(i = 0; i < NumParams; i += 1)
		ParamName = CoefNames[i]
		NVAR TempVar = $(ParamName)
		TempVar = w[i]
	endfor

	IR2L_CalculateIntensity(1, 0)

	setDataFolder oldDF
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_FitFunction(w, yw, xw) : FitFunc
	WAVE w, yw, xw

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	variable i

	WAVE/T CoefNames
	variable NumParams = numpnts(CoefNames)
	string ParamName

	for(i = 0; i < NumParams; i += 1)
		ParamName = CoefNames[i]
		NVAR TempVar = $(ParamName)
		TempVar = w[i]
	endfor
	IR2L_CalculateIntensity(1, 1)
	Make/O/N=0 IntWvResult
	NVAR MultipleInputData = root:Packages:IR2L_NLSQF:MultipleInputData
	variable LastDataSet
	LastDataSet = (MultipleInputData) ? 10 : 1
	for(i = 1; i <= LastDataSet; i += 1)
		NVAR UseTheSet = $("root:Packages:IR2L_NLSQF:UseTheData_set" + num2str(i))
		if(UseTheSet)
			WAVE InWave = $("root:Packages:IR2L_NLSQF:IntensityModel_set" + num2str(i))
			Concatenate/NP/O {IntWvResult, InWave}, tempWv
			Duplicate/O tempWv, IntWvResult
		endif
	endfor

	yw = IntWvResult

	KillWaves/Z IntWvResult
	setDataFolder oldDF
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_RecordResults(CalledFromWere)
	string CalledFromWere //before or after - that means fit...

	DFREF oldDf = GetDataFolderDFR()

	setdataFolder root:Packages:IR2L_NLSQF
	variable i
	IR1_CreateLoggbook() //this creates the logbook
	SVAR nbl = root:Packages:SAS_Modeling:NotebookName
	IR1L_AppendAnyText("     ")
	if(cmpstr(CalledFromWere, "before") == 0)
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Parameters before starting Modeling Fitting on the data from: ")
		IR1_InsertDateAndTime(nbl)
	else //after
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Results of the Modeling Fitting on the data from: ")
		IR1_InsertDateAndTime(nbl)
	endif
	NVAR MultipleInputData = root:Packages:IR2L_NLSQF:MultipleInputData
	if(MultipleInputData)
		//multiple data selected, need to return to multiple places....
		IR1L_AppendAnyText("Multiple data sets used, listing of data sets\r")
		for(i = 1; i < 11; i += 1)
			NVAR UseSet = $("root:Packages:IR2L_NLSQF:UseTheData_set" + num2str(i))
			if(UseSet)
				SVAR testStr = $("FolderName_set" + num2str(i))
				IR1L_AppendAnyText("FolderName_set" + num2str(i) + "\t=\t" + testStr)
				IR2L_RecordDataResults(i)
				IR1L_AppendAnyText("  ")
			endif
		endfor
	else
		IR1L_AppendAnyText("Single data set used:")
		//only one data set to be returned... the first one
		SVAR testStr = $("FolderName_set1")
		IR1L_AppendAnyText("FolderName_set1" + "\t=\t" + testStr)
		IR2L_RecordDataResults(1)
	endif
	//now models...
	IR1L_AppendAnyText("\rModel microsctructure parameters\r")
	for(i = 1; i <= 6; i += 1)
		IR2L_RecordModelResults(i)
	endfor

	if(cmpstr(CalledFromWere, "after") == 0)
		IR1L_AppendAnyText("             **********************                   ")
		IR1L_AppendAnyText("Fit has been reached with following parameters")
		SVAR nbl = root:Packages:SAS_Modeling:NotebookName
		IR1_InsertDateAndTime(nbl)
		NVAR AchievedChisq
		IR1L_AppendAnyText("Chi-Squared \t" + num2str(AchievedChisq))
		IR1L_AppendAnyText("             **********************                   ")
	endif //after

	setdataFolder oldDf

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_SaveResultsInDataFolder(SkipDialogs, ExportSeparatePopData)
	variable SkipDialogs, ExportSeparatePopData

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	SVAR/Z ListOfVariables             = root:Packages:IR2L_NLSQF:ListOfVariables
	SVAR/Z ListOfDataVariables         = root:Packages:IR2L_NLSQF:ListOfDataVariables
	SVAR/Z ListOfPopulationVariables   = root:Packages:IR2L_NLSQF:ListOfPopulationVariables
	SVAR/Z ListOfPopulationVariablesSD = root:Packages:IR2L_NLSQF:ListOfPopulationVariablesSD
	SVAR/Z ListOfPopulationVariablesDP = root:Packages:IR2L_NLSQF:ListOfPopulationVariablesDP
	SVAR/Z ListOfPopulationVariablesUF = root:Packages:IR2L_NLSQF:ListOfPopulationVariablesUF
	SVAR/Z ListOfStrings               = root:Packages:IR2L_NLSQF:ListOfStrings
	SVAR/Z ListOfDataStrings           = root:Packages:IR2L_NLSQF:ListOfDataStrings
	SVAR/Z ListOfPopulationsStrings    = root:Packages:IR2L_NLSQF:ListOfPopulationsStrings
	SVAR   DataCalibrationUnits        = root:Packages:IR2L_NLSQF:DataCalibrationUnits
	SVAR   PanelVolumeDesignation      = root:Packages:IR2L_NLSQF:PanelVolumeDesignation
	SVAR   IntCalibrationUnits         = root:Packages:IR2L_NLSQF:IntCalibrationUnits
	SVAR   VolDistCalibrationUnits     = root:Packages:IR2L_NLSQF:VolDistCalibrationUnits
	SVAR   NumDistCalibrationUnits     = root:Packages:IR2L_NLSQF:NumDistCalibrationUnits
	NVAR   UseNumberDistributions      = root:Packages:IR2L_NLSQF:UseNumberDistributions
	NVAR   MultipleInputData           = root:Packages:IR2L_NLSQF:MultipleInputData

	if(!SVAR_Exists(ListOfVariables) || !SVAR_Exists(ListOfDataVariables) || !SVAR_Exists(ListOfPopulationVariables) || !SVAR_Exists(ListOfStrings) || !SVAR_Exists(ListOfDataStrings) || !SVAR_Exists(ListOfPopulationsStrings))
		abort "Error in parameters in SaveResultsInDdataFolder routine. Send the file to author for bug fix, please"
	endif

	string tempList
	variable i, j
	//and here we store them in the List to use in the wave note...
	string ListOfParameters = ""

	//Main parameters
	tempList  = "UseIndra2Data;UseQRSdata;UseSMRData;MultipleInputData;UseNumberDistributions;DisplaySinglePopInt;SizeDist_DimensionIsDiameter;"
	tempList += "SameContrastForDataSets;VaryContrastForDataSets;DisplayInputDataControls;DisplayModelControls;UseGeneticOptimization;UseLSQF;"
	tempList += "GraphXMin;GraphXMax;GraphYMin;GraphYMax;SizeDistDisplayNumDist;SizeDistDisplayVolDist;"
	tempList += "SizeDistLogVolDist;SizeDistLogNumDist;SizeDistLogX;"

	for(i = 0; i < itemsInList(tempList); i += 1)
		NVAR testVar = $(StringFromList(i, tempList))
		ListOfParameters += StringFromList(i, tempList) + "=" + num2str(testVar) + ";"
	endfor

	//Input Data parameters... Will have _setX attached, in this method background needs to be here...
	for(j = 1; j <= 10; j += 1)
		NVAR UseSet = $("root:Packages:IR2L_NLSQF:UseTheData_set" + num2str(j))
		ListOfParameters += "root:Packages:IR2L_NLSQF:UseTheData_set" + num2str(j) + "=" + num2str(UseSet) + ";"
		if(UseSet)
			tempList = "FolderName;IntensityDataName;QvecDataName;ErrorDataName;UserDataSetName;"
			for(i = 0; i < itemsInList(tempList); i += 1)
				SVAR testStr = $(StringFromList(i, tempList) + "_set" + num2str(j))
				ListOfParameters += StringFromList(i, tempList) + "_set" + num2str(j) + "=" + testStr + ";"
			endfor
			tempList  = "SlitSmeared;SlitLength;Qmin;Qmax;"
			tempList += "Background;BackgroundFit;BackgroundMin;BackgroundMax;BackgErr;BackgStep;"
			tempList += "DataScalingFactor;ErrorScalingFactor;UseUserErrors;UseSQRTErrors;UsePercentErrors;"
			for(i = 0; i < itemsInList(tempList); i += 1)
				NVAR testVar = $(StringFromList(i, tempList) + "_set" + num2str(j))
				ListOfParameters += StringFromList(i, tempList) + "_set" + num2str(j) + "=" + num2str(testVar) + ";"
			endfor
		endif
	endfor

	//Model parameters... Will have _popX attached
	for(j = 1; j <= 10; j += 1)
		NVAR UseThePop               = $("root:Packages:IR2L_NLSQF:UseThePop_pop" + num2str(j))
		NVAR SameContrastForDataSets = root:Packages:IR2L_NLSQF:SameContrastForDataSets
		tempList = "UseThePop;"
		for(i = 0; i < itemsInList(tempList); i += 1)
			NVAR testVar = $(StringFromList(i, tempList) + "_pop" + num2str(j))
			ListOfParameters += StringFromList(i, tempList) + "_pop" + num2str(j) + "=" + num2str(testVar) + ";"
		endfor
		if(UseThePop)
			if(!SameContrastForDataSets || !MultipleInputData) //note, illogically the SameContrast=1 when we vary contrast. Weird...
				tempList = "Contrast;" //fix 2016-12-7 to save single Contrast even when user left SameContrastForDataSets=1 but is using just one data set
			else
				tempList = "Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
			endif
			for(i = 0; i < itemsInList(tempList); i += 1)
				NVAR testVar = $(StringFromList(i, tempList) + "_pop" + num2str(j))
				ListOfParameters += StringFromList(i, tempList) + "_pop" + num2str(j) + "=" + num2str(testVar) + ";"
			endfor
			tempList = "Model;"
			for(i = 0; i < itemsInList(tempList); i += 1)
				SVAR testStr = $(StringFromList(i, tempList) + "_pop" + num2str(j))
				ListOfParameters += StringFromList(i, tempList) + "_pop" + num2str(j) + "=" + testStr + ";"
			endfor
			//*** here we split models apart...
			SVAR Model = $("root:Packages:IR2L_NLSQF:Model_pop" + num2str(j))
			if(stringmatch(Model, "Size dist."))
				tempList = "Volume;VolumeFit;VolumeMin;VolumeMax;Mean;Mode;Median;FWHM;RdistAuto;RdistrSemiAuto;RdistMan;RdistManMin;RdistManMax;RdistLog;RdistNumPnts;RdistNeglectTails;"
				for(i = 0; i < itemsInList(tempList); i += 1)
					NVAR testVar = $(StringFromList(i, tempList) + "_pop" + num2str(j))
					ListOfParameters += StringFromList(i, tempList) + "_pop" + num2str(j) + "=" + num2str(testVar) + ";"
				endfor
				tempList = "PopSizeDistShape;"
				for(i = 0; i < itemsInList(tempList); i += 1)
					SVAR testStr = $(StringFromList(i, tempList) + "_pop" + num2str(j))
					ListOfParameters += StringFromList(i, tempList) + "_pop" + num2str(j) + "=" + testStr + ";"
				endfor
				SVAR PopSizeDistShape = $("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop" + num2str(j))
				if(stringMatch(PopSizeDistShape, "LogNormal"))
					tempList = "LNMinSize;LNMinSizeFit;LNMinSizeMin;LNMinSizeMax;LNMeanSize;LNMeanSizeFit;LNMeanSizeMin;LNMeanSizeMax;LNSdeviation;LNSdeviationFit;LNSdeviationMin;LNSdeviationMax;"
				elseif(stringMatch(PopSizeDistShape, "Gauss"))
					tempList = "GMeanSize;GMeanSizeFit;GMeanSizeMin;GMeanSizeMax;GWidth;GWidthFit;GWidthMin;GWidthMax;"
				elseif(stringMatch(PopSizeDistShape, "LSW"))
					tempList = "LSWLocation;LSWLocationFit;LSWLocationMin;LSWLocationMax;"
				elseif(stringMatch(PopSizeDistShape, "Schulz-Zimm"))
					tempList = "SZMeanSize;SZMeanSizeFit;SZMeanSizeMin;SZMeanSizeMax;SZWidth;SZWidthFit;SZWidthMin;SZWidthMax;"
				elseif(stringMatch(PopSizeDistShape, "Ardell"))
					tempList = "ArdLocation;ArdLocationFit;ArdLocationMin;ArdLocationMax;ArdParameter;ArdParameterFit;ArdParameterMin;ArdParameterMax;"
				endif
				for(i = 0; i < itemsInList(tempList); i += 1)
					NVAR testVar = $(StringFromList(i, tempList) + "_pop" + num2str(j))
					ListOfParameters += StringFromList(i, tempList) + "_pop" + num2str(j) + "=" + num2str(testVar) + ";"
				endfor
				SVAR FormFactor = $("root:Packages:IR2L_NLSQF:FormFactor_pop" + num2str(j))
				if(stringMatch(FormFactor, "User"))
					tempList = "FormFactor;FFUserFFformula;FFUserVolumeFormula;"
				else
					tempList = "FormFactor;"
				endif
				for(i = 0; i < itemsInList(tempList); i += 1)
					SVAR testStr = $(StringFromList(i, tempList) + "_pop" + num2str(j))
					ListOfParameters += StringFromList(i, tempList) + "_pop" + num2str(j) + "=" + testStr + ";"
				endfor
				tempList  = "FormFactor_Param1;FormFactor_Param1Fit;FormFactor_Param1Min;FormFactor_Param1Max;"
				tempList += "FormFactor_Param2;FormFactor_Param2Fit;FormFactor_Param2Min;FormFactor_Param2Max;"
				tempList += "FormFactor_Param3;FormFactor_Param3Fit;FormFactor_Param3Min;FormFactor_Param3Max;"
				tempList += "FormFactor_Param4;FormFactor_Param4Fit;FormFactor_Param4Min;FormFactor_Param4Max;"
				tempList += "FormFactor_Param5;FormFactor_Param5Fit;FormFactor_Param5Min;FormFactor_Param5Max;"
				tempList += "FormFactor_Param6;FormFactor_Param6Fit;FormFactor_Param6Min;FormFactor_Param6Max;"
				tempList += "FormFactor_Param7;FormFactor_Param7Fit;FormFactor_Param7Min;FormFactor_Param7Max;"
				tempList += "FormFactor_Param8;FormFactor_Param8Fit;FormFactor_Param8Min;FormFactor_Param8Max;"
				tempList += "FormFactor_Param9;FormFactor_Param9Fit;FormFactor_Param9Min;FormFactor_Param9Max;"
				for(i = 0; i < itemsInList(tempList); i += 1)
					NVAR testVar = $(StringFromList(i, tempList) + "_pop" + num2str(j))
					ListOfParameters += StringFromList(i, tempList) + "_pop" + num2str(j) + "=" + num2str(testVar) + ";"
				endfor
			elseif(stringmatch(Model, "Unified level"))
				tempList  = "UF_G;UF_GFit;UF_GMin;UF_GMax;UF_Rg;UF_RgFit;UF_RgMin;UF_RgMax;UF_B;UF_BFit;UF_BMin;UF_BMax;UF_P;UF_PFit;UF_PMin;UF_PMax;UF_K;UF_LinkRGCO;"
				tempList += "UF_LinkRGCOLevel;UF_RGCO;UF_RGCOFit;UF_RGCOMin;UF_RGCOMax;"
				for(i = 0; i < itemsInList(tempList); i += 1)
					NVAR testVar = $(StringFromList(i, tempList) + "_pop" + num2str(j))
					ListOfParameters += StringFromList(i, tempList) + "_pop" + num2str(j) + "=" + num2str(testVar) + ";"
				endfor
			elseif(stringmatch(Model, "MassFractal"))
				tempList  = "MassFrPhi;MassFrRadius;MassFrDv;MassFrKsi;MassFrBeta;MassFrEta;MassFrIntgNumPnts;"
				tempList += "MassFrPhiFit;MassFrRadiusFit;MassFrDvFit;MassFrKsiFit;"
				tempList += "MassFrPhiMin;MassFrRadiusMin;MassFrDvMin;MassFrKsiMin;"
				tempList += "MassFrPhiMax;MassFrRadiusMax;MassFrDvMax;MassFrKsiMax;"
				for(i = 0; i < itemsInList(tempList); i += 1)
					NVAR testVar = $(StringFromList(i, tempList) + "_pop" + num2str(j))
					ListOfParameters += StringFromList(i, tempList) + "_pop" + num2str(j) + "=" + num2str(testVar) + ";"
				endfor
			elseif(stringmatch(Model, "SurfaceFractal"))
				tempList  = "SurfFrSurf;SurfFrKsi;SurfFrDS;"
				tempList += "SurfFrSurfFit;SurfFrKsiFit;SurfFrDSFit;"
				tempList += "SurfFrSurfMin;SurfFrKsiMin;SurfFrDSMin;"
				tempList += "SurfFrSurfMax;SurfFrKsiMax;SurfFrDSMax;"
				tempList += "SurfFrQc;SurfFrQcWidth;"
				for(i = 0; i < itemsInList(tempList); i += 1)
					NVAR testVar = $(StringFromList(i, tempList) + "_pop" + num2str(j))
					ListOfParameters += StringFromList(i, tempList) + "_pop" + num2str(j) + "=" + num2str(testVar) + ";"
				endfor
			elseif(stringmatch(Model, "Diffraction Peak"))
				tempList = "DiffPeakProfile;"
				for(i = 0; i < itemsInList(tempList); i += 1)
					SVAR testStr = $(StringFromList(i, tempList) + "_pop" + num2str(j))
					ListOfParameters += StringFromList(i, tempList) + "_pop" + num2str(j) + "=" + testStr + ";"
				endfor
				tempList  = "DiffPeakDPos;DiffPeakQPos;DiffPeakDFWHM;DiffPeakQFWHM;DiffPeakIntgInt;"
				tempList += "DiffPeakPar1;DiffPeakPar1Fit;DiffPeakPar1Min;DiffPeakPar1Max;"
				tempList += "DiffPeakPar2;DiffPeakPar2Fit;DiffPeakPar2Min;DiffPeakPar2Max;"
				tempList += "DiffPeakPar3;DiffPeakPar3Fit;DiffPeakPar3Min;DiffPeakPar3Max;"
				tempList += "DiffPeakPar4;DiffPeakPar4Fit;DiffPeakPar4Min;DiffPeakPar4Max;"
				tempList += "DiffPeakPar5;DiffPeakPar5Fit;DiffPeakPar5Min;DiffPeakPar5Max;"
				for(i = 0; i < itemsInList(tempList); i += 1)
					NVAR testVar = $(StringFromList(i, tempList) + "_pop" + num2str(j))
					ListOfParameters += StringFromList(i, tempList) + "_pop" + num2str(j) + "=" + num2str(testVar) + ";"
				endfor
			endif

			if(stringmatch(Model, "Unified level") || stringmatch(Model, "Size dist."))
				tempList = "StructureFactor;"
				for(i = 0; i < itemsInList(tempList); i += 1)
					SVAR testStr = $(StringFromList(i, tempList) + "_pop" + num2str(j))
					ListOfParameters += StringFromList(i, tempList) + "_pop" + num2str(j) + "=" + testStr + ";"
				endfor
				SVAR StructureFactor = $("root:Packages:IR2L_NLSQF:StructureFactor_pop" + num2str(j))
				if(stringMatch(StructureFactor, "Dilute system"))
					tempList = ""
				else
					tempList  = "StructureParam1;StructureParam1Fit;StructureParam1Min;StructureParam1Max;StructureParam2;StructureParam2Fit;StructureParam2Min;StructureParam2Max;"
					tempList += "StructureParam3;StructureParam3Fit;StructureParam3Min;StructureParam3Max;StructureParam4;StructureParam4Fit;StructureParam4Min;StructureParam4Max;"
					tempList += "StructureParam5;StructureParam5Fit;StructureParam5Min;StructureParam5Max;StructureParam6;StructureParam6Fit;StructureParam6Min;StructureParam6Max;"
				endif
				for(i = 0; i < itemsInList(tempList); i += 1)
					NVAR testVar = $(StringFromList(i, tempList) + "_pop" + num2str(j))
					ListOfParameters += StringFromList(i, tempList) + "_pop" + num2str(j) + "=" + num2str(testVar) + ";"
				endfor
			endif

		endif

	endfor

	//	print ListOfParameters
	NVAR MultipleInputData = root:Packages:IR2L_NLSQF:MultipleInputData
	if(MultipleInputData)
		//multiple data selected, need to return to multiple places....
		for(i = 1; i < 11; i += 1)
			NVAR UseSet = $("root:Packages:IR2L_NLSQF:UseTheData_set" + num2str(i))
			if(UseSet)
				IR2L_ReturnOneDataSetToFolder(i, ListOfParameters, SkipDialogs, ExportSeparatePopData)
			endif
		endfor
	else
		//only one data set to be returned... the first one
		IR2L_ReturnOneDataSetToFolder(1, ListOfParameters, SkipDialogs, ExportSeparatePopData)
	endif

	setDataFolder oldDF

End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_ReturnOneDataSetToFolder(whichDataSet, WaveNoteText, SkipDialogs, ExportSeparatePopData)
	variable whichDataSet, SkipDialogs, ExportSeparatePopData
	string WaveNoteText

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	SVAR DataFolderName = $("root:Packages:IR2L_NLSQF:FolderName_set" + num2str(whichDataSet))

	WAVE Intensity               = $("root:Packages:IR2L_NLSQF:IntensityModel_set" + num2str(whichDataSet))
	WAVE Qvector                 = $("root:Packages:IR2L_NLSQF:Qmodel_set" + num2str(whichDataSet))
	WAVE Radii                   = root:Packages:IR2L_NLSQF:DistRadia
	WAVE Diameters               = root:Packages:IR2L_NLSQF:DistDiameters
	WAVE NumberDist              = root:Packages:IR2L_NLSQF:TotalNumberDist
	WAVE VolumeDist              = root:Packages:IR2L_NLSQF:TotalVolumeDist
	NVAR useModelData            = root:Packages:IR2L_NLSQF:useModelData
	NVAR DimensionIsDiameter     = root:Packages:IR2L_NLSQF:SizeDist_DimensionIsDiameter
	SVAR DataCalibrationUnits    = root:Packages:IR2L_NLSQF:DataCalibrationUnits
	SVAR PanelVolumeDesignation  = root:Packages:IR2L_NLSQF:PanelVolumeDesignation
	SVAR IntCalibrationUnits     = root:Packages:IR2L_NLSQF:IntCalibrationUnits
	SVAR VolDistCalibrationUnits = root:Packages:IR2L_NLSQF:VolDistCalibrationUnits
	SVAR NumDistCalibrationUnits = root:Packages:IR2L_NLSQF:NumDistCalibrationUnits
	NVAR UseNumberDistributions  = root:Packages:IR2L_NLSQF:UseNumberDistributions

	string UsersComment, ExportSeparateDistributions
	UsersComment                = "Result from LSQF2 Modeling " + date() + "  " + time()
	ExportSeparateDistributions = "No"
	if(ExportSeparatePopData)
		ExportSeparateDistributions = "Yes"
	endif
	Prompt UsersComment, "Modify comment to be saved with these results"
	Prompt ExportSeparateDistributions, "Export separately populations data", popup, "No;Yes;"
	if(!SkipDialogs)
		DoPrompt "Need input for saving data", UsersComment, ExportSeparateDistributions
		if(V_Flag)
			abort
		endif
	endif
	string DataFolderNameL = "Modeling " + Secs2Date(DateTime, -2) + " " + Secs2Time(DateTime, 3)
	if(useModelData) //these are model data, so the Folder is really "dirty" and not meaningful
		Prompt DataFolderNameL, "Folder to save data to, it will be created if it is needed"
		DoPrompt "Input name for folder to save the model data to, the name will be cleaned up as needed", DataFolderNameL
		if(V_Flag)
			abort
		endif
		DataFolderNameL = possiblyquotename(cleanupname(DataFolderNameL, 1))
		NewDataFolder/O $("root:" + DataFolderNameL)
		Print "Data will be saved in folder :  root:" + DataFolderNameL
		DataFolderName = "root:" + DataFolderNameL + ":"
	endif

	setDataFolder $(DataFolderName)
	string tempname
	variable ii = 0
	for(ii = 0; ii < 1000; ii += 1)
		tempname = "IntensityModelLSQF2_" + num2str(ii)
		if(checkname(tempname, 1) == 0)
			break
		endif
	endfor

	//add print record for user
	Duplicate Intensity, $("IntensityModelLSQF2_" + num2str(ii))
	print "Created results wave : " + DataFolderName + ("IntensityModelLSQF2_" + num2str(ii))
	Duplicate Qvector, $("QvectorModelLSQF2_" + num2str(ii))
	print "Created results wave : " + DataFolderName + ("QvectorModelLSQF2_" + num2str(ii))
	if(DimensionIsDiameter) //all calculations above are done in radii, if we use Diameters, volume/number distributions needs to be half
		Duplicate Diameters, $("DiametersModelLSQF2_" + num2str(ii))
		print "Created results wave : " + DataFolderName + ("DiametersModelLSQF2_" + num2str(ii))
	else
		Duplicate Radii, $("RadiiModelLSQF2_" + num2str(ii))
		print "Created results wave : " + DataFolderName + ("RadiiModelLSQF2_" + num2str(ii))
	endif
	//do we have to scale these here??? Good question, I am not sure.
	Duplicate NumberDist, $("NumberDistModelLSQF2_" + num2str(ii))
	print "Created results wave : " + DataFolderName + ("NumberDistModelLSQF2_" + num2str(ii))
	Duplicate VolumeDist, $("VolumeDistModelLSQF2_" + num2str(ii))
	print "Created results wave : " + DataFolderName + ("VolumeDistModelLSQF2_" + num2str(ii))

	WAVE MytempWave = $("IntensityModelLSQF2_" + num2str(ii))
	tempname = "IntensityModelLSQF2_" + num2str(ii)
	IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
	IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
	IN2G_AppendorReplaceWaveNote(tempname, "Units", IntCalibrationUnits)
	note/NOCR MytempWave, WaveNoteText
	Redimension/D MytempWave

	WAVE MytempWave = $("QvectorModelLSQF2_" + num2str(ii))
	tempname = "QvectorModelLSQF2_" + num2str(ii)
	IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
	IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
	IN2G_AppendorReplaceWaveNote(tempname, "Units", "1/A")
	note/NOCR MytempWave, WaveNoteText
	Redimension/D MytempWave

	if(DimensionIsDiameter) //all calculations above are done in radii, if we use Diameters, volume/number distributions needs to be half
		WAVE MytempWave = $("DiametersModelLSQF2_" + num2str(ii))
		tempname = "DiametersModelLSQF2_" + num2str(ii)
		IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
		IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
		IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
		IN2G_AppendorReplaceWaveNote(tempname, "Units", "A")
		note/NOCR MytempWave, WaveNoteText
		Redimension/D MytempWave
	else
		WAVE MytempWave = $("RadiiModelLSQF2_" + num2str(ii))
		tempname = "RadiiModelLSQF2_" + num2str(ii)
		IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
		IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
		IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
		IN2G_AppendorReplaceWaveNote(tempname, "Units", "A")
		note/NOCR MytempWave, WaveNoteText
		Redimension/D MytempWave
	endif

	WAVE MytempWave = $("NumberDistModelLSQF2_" + num2str(ii))
	tempname = "NumberDistModelLSQF2_" + num2str(ii)
	IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
	IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
	IN2G_AppendorReplaceWaveNote(tempname, "Units", NumDistCalibrationUnits)
	note/NOCR MytempWave, WaveNoteText
	Redimension/D MytempWave
	if(DimensionIsDiameter)
		MytempWave /= 2 //correct for converting SD to diameters
	endif

	WAVE MytempWave = $("VolumeDistModelLSQF2_" + num2str(ii))
	tempname = "VolumeDistModelLSQF2_" + num2str(ii)
	IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
	IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
	IN2G_AppendorReplaceWaveNote(tempname, "Units", VolDistCalibrationUnits)
	note/NOCR MytempWave, WaveNoteText
	Redimension/D MytempWave
	if(DimensionIsDiameter)
		MytempWave /= 2 //correct for converting SD to diameters
	endif

	variable j

	if(stringmatch(ExportSeparateDistributions, "Yes"))
		//create Background population 0
		for(j = 1; j < 11; j += 1)
			NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop" + num2str(j))
			if(UseThePop)
				WAVE Intensity  = $("root:Packages:IR2L_NLSQF:IntensityModel_set" + num2str(whichDataSet) + "_pop" + num2str(j))
				WAVE Qvector    = $("root:Packages:IR2L_NLSQF:Qmodel_set" + num2str(whichDataSet))
				NVAR Background = $("root:Packages:IR2L_NLSQF:Background_set" + num2str(whichDataSet))
				Duplicate/O Intensity, $("IntensityModelLSQF2pop0_" + num2str(ii))
				print "Created results Backgroundf wave : " + DataFolderName + ("IntensityModelLSQF2pop0_" + num2str(ii))
				Duplicate/O Qvector, $("QvectorModelLSQF2pop0_" + num2str(ii))
				print "Created results Background wave : " + DataFolderName + ("QvectorModelLSQF2pop0_" + num2str(ii))
				WAVE TempInt = $("IntensityModelLSQF2pop0_" + num2str(ii))
				TempInt  = Background
				tempname = ("IntensityModelLSQF2pop0_" + num2str(ii))
				IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
				IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
				IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
				IN2G_AppendorReplaceWaveNote(tempname, "Units", IntCalibrationUnits)

				tempname = "QvectorModelLSQF2pop0_" + num2str(ii)
				IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
				IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
				IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
				IN2G_AppendorReplaceWaveNote(tempname, "Units", "1/A")
			endif
		endfor
		//and now the real models with intensity profiles...
		for(j = 1; j < 11; j += 1)
			NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop" + num2str(j))
			if(UseThePop)
				WAVE   Intensity  = $("root:Packages:IR2L_NLSQF:IntensityModel_set" + num2str(whichDataSet) + "_pop" + num2str(j))
				WAVE   Qvector    = $("root:Packages:IR2L_NLSQF:Qmodel_set" + num2str(whichDataSet))
				WAVE/Z Radii      = $("root:Packages:IR2L_NLSQF:Radius" + "_pop" + num2str(j))
				WAVE/Z Diameter   = $("root:Packages:IR2L_NLSQF:Diameter" + "_pop" + num2str(j))
				WAVE   NumberDist = $("root:Packages:IR2L_NLSQF:NumberDist" + "_pop" + num2str(j))
				WAVE   VolumeDist = $("root:Packages:IR2L_NLSQF:VolumeDist" + "_pop" + num2str(j))

				Duplicate Intensity, $("IntensityModelLSQF2pop" + num2str(j) + "_" + num2str(ii))
				print "Created results wave : " + DataFolderName + ("IntensityModelLSQF2pop" + num2str(j) + "_" + num2str(ii))
				Duplicate Qvector, $("QvectorModelLSQF2pop" + num2str(j) + "_" + num2str(ii))
				print "Created results wave : " + DataFolderName + ("QvectorModelLSQF2pop" + num2str(j) + "_" + num2str(ii))
				if(DimensionIsDiameter) //all calculations above are done in radii, if we use Diameters, volume/number distributions needs to be half
					Duplicate Diameter, $("DiameterModelsLSQF2pop" + num2str(j) + "_" + num2str(ii))
					print "Created results wave : " + DataFolderName + ("DiameterModelsLSQF2pop" + num2str(j) + "_" + num2str(ii))
				else
					Duplicate Radii, $("RadiiModelLSQF2pop" + num2str(j) + "_" + num2str(ii))
					print "Created results wave : " + DataFolderName + ("RadiiModelLSQF2pop" + num2str(j) + "_" + num2str(ii))
				endif
				Duplicate NumberDist, $("NumberDistModelLSQF2pop" + num2str(j) + "_" + num2str(ii))
				print "Created results wave : " + DataFolderName + ("NumberDistModelLSQF2pop" + num2str(j) + "_" + num2str(ii))
				Duplicate VolumeDist, $("VolumeDistModelLSQF2pop" + num2str(j) + "_" + num2str(ii))
				print "Created results wave : " + DataFolderName + ("VolumeDistModelLSQF2pop" + num2str(j) + "_" + num2str(ii))

				WAVE MytempWave = $("IntensityModelLSQF2pop" + num2str(j) + "_" + num2str(ii))
				tempname = "IntensityModelLSQF2pop" + num2str(j) + "_" + num2str(ii)
				IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
				IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
				IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
				IN2G_AppendorReplaceWaveNote(tempname, "Units", IntCalibrationUnits)
				note MytempWave, WaveNoteText
				Redimension/D MytempWave

				WAVE MytempWave = $("QvectorModelLSQF2pop" + num2str(j) + "_" + num2str(ii))
				tempname = "QvectorModelLSQF2pop" + num2str(j) + "_" + num2str(ii)
				IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
				IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
				IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
				IN2G_AppendorReplaceWaveNote(tempname, "Units", "1/A")
				note MytempWave, WaveNoteText
				Redimension/D MytempWave

				if(DimensionIsDiameter) //all calculations above are done in radii, if we use Diameters, volume/number distributions needs to be half
					WAVE MytempWave = $("DiameterModelsLSQF2pop" + num2str(j) + "_" + num2str(ii))
					tempname = "DiameterModelsLSQF2pop" + num2str(j) + "_" + num2str(ii)
					IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
					IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
					IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
					IN2G_AppendorReplaceWaveNote(tempname, "Units", "A")
					note MytempWave, WaveNoteText
					Redimension/D MytempWave
				else
					WAVE MytempWave = $("RadiiModelLSQF2pop" + num2str(j) + "_" + num2str(ii))
					tempname = "RadiiModelLSQF2pop" + num2str(j) + "_" + num2str(ii)
					IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
					IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
					IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
					IN2G_AppendorReplaceWaveNote(tempname, "Units", "A")
					note MytempWave, WaveNoteText
					Redimension/D MytempWave
				endif

				WAVE MytempWave = $("NumberDistModelLSQF2pop" + num2str(j) + "_" + num2str(ii))
				tempname = "NumberDistModelLSQF2pop" + num2str(j) + "_" + num2str(ii)
				IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
				IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
				IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
				IN2G_AppendorReplaceWaveNote(tempname, "Units", NumDistCalibrationUnits)
				note MytempWave, WaveNoteText
				Redimension/D MytempWave
				if(DimensionIsDiameter)
					MytempWave /= 2 //correct for converting SD to diameters
				endif

				WAVE MytempWave = $("VolumeDistModelLSQF2pop" + num2str(j) + "_" + num2str(ii))
				tempname = "VolumeDistModelLSQF2pop" + num2str(j) + "_" + num2str(ii)
				IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
				IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
				IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
				IN2G_AppendorReplaceWaveNote(tempname, "Units", VolDistCalibrationUnits)
				note MytempWave, WaveNoteText
				Redimension/D MytempWave
				if(DimensionIsDiameter)
					MytempWave /= 2 //correct for converting SD to diameters
				endif

			endif
		endfor
	endif

	setDataFolder oldDF
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_SaveResultsInWaves(SkipDialog)
	variable SkipDialog

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	//define new folder through dialog... stuff in NewFolderName
	string/G ExportWvsDataFolderName
	string   NewFolderName
	if(strlen(ExportWvsDataFolderName) > 0)
		NewFolderName = ExportWvsDataFolderName
	else
		NewFolderName = "NewLSQF_FitResults"
	endif
	if(!SkipDialog)
		Prompt NewFolderName, "Input folder name for Output waves"
		DoPrompt "Output folder Name", NewFolderName
	endif

	NVAR MultipleInputData = root:Packages:IR2L_NLSQF:MultipleInputData
	variable i
	if(MultipleInputData)
		//multiple data selected, need to return to multiple places....
		for(i = 1; i < 11; i += 1)
			NVAR UseSet = $("root:Packages:IR2L_NLSQF:UseTheData_set" + num2str(i))
			if(UseSet)
				IR2L_SaveResInWavesIndivDtSet(i, NewFolderName)
			endif
		endfor
	else
		//only one data set to be returned... the first one
		IR2L_SaveResInWavesIndivDtSet(1, NewFolderName)
	endif

	setDataFolder OldDf
End

//*****************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_SaveResInWavesIndivDtSet(WdtSt, NewFolderName)
	variable WdtSt
	string   NewFolderName

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	string ListOfVariables, ListOfDataVariables, ListOfPopulationVariables
	string ListOfStrings, ListOfDataStrings, ListOfPopulationsStrings
	string ListOfParameters, ListOfParametersStr
	ListOfParametersStr = ""
	ListOfParameters    = ""
	variable i, j

	j = WdtSt

	//First deal with data itself... Name, background etc.
	ListOfDataStrings = "FolderName;IntensityDataName;QvecDataName;ErrorDataName;UserDataSetName;"
	for(i = 0; i < itemsInList(ListOfDataStrings); i += 1)
		SVAR testStr = $(StringFromList(i, ListOfDataStrings) + "_set" + num2str(j))
		ListOfParametersStr += StringFromList(i, ListOfDataStrings) + "_set" + num2str(j) + "=" + testStr + ";"
	endfor
	ListOfDataVariables = "DataScalingFactor;ErrorScalingFactor;Qmin;Qmax;Background;"
	for(i = 0; i < itemsInList(ListOfDataVariables); i += 1)
		NVAR testVar = $(StringFromList(i, ListOfDataVariables) + "_set" + num2str(j))
		ListOfParameters += StringFromList(i, ListOfDataVariables) + "_set" + num2str(j) + "=" + num2str(testVar) + ";"
	endfor

	//Slit smeared data?
	NVAR SlitSmeared = $("root:Packages:IR2L_NLSQF:SlitSmeared_set" + num2str(j))
	if(SlitSmeared)
		NVAR SlitLength = $("root:Packages:IR2L_NLSQF:SlitLength_set" + num2str(j))
		ListOfParameters += "SlitLength" + "_set" + num2str(j) + "=" + num2str(SlitLength) + ";"
	else
		ListOfParameters += "SlitLength" + "_set" + num2str(j) + "=0;"
	endif

	//Background fit?
	NVAR BackgroundFit = $("root:Packages:IR2L_NLSQF:BackgroundFit_set" + num2str(j))
	if(BackgroundFit)
		NVAR BackgErr = $("root:Packages:IR2L_NLSQF:BackgErr_set" + num2str(j))
		ListOfParameters += "BackgroundError" + "_set" + num2str(j) + "=" + num2str(BackgErr) + ";"
	else
		ListOfParameters += "BackgroundError" + "_set" + num2str(j) + "=0;"
	endif

	variable k
	//And now the populations
	for(i = 1; i <= 10; i += 1)
		NVAR UseThePop  = $("root:Packages:IR2L_NLSQF:UseThePop_pop" + num2str(i))
		SVAR FormFactor = $("root:Packages:IR2L_NLSQF:FormFactor_pop" + num2str(i))
		SVAR Model      = $("root:Packages:IR2L_NLSQF:Model_pop" + num2str(i))

		if(UseThePop)
			if(stringmatch(Model, "Size dist."))
				ListOfPopulationVariables = "Volume;Mean;Mode;Median;FWHM;"
				for(k = 0; k < itemsInList(ListOfPopulationVariables); k += 1)
					NVAR testVar = $(StringFromList(k, ListOfPopulationVariables) + "_pop" + num2str(i))
					ListOfParameters += StringFromList(k, ListOfPopulationVariables) + "_pop" + num2str(i) + "=" + num2str(testVar) + ";"
				endfor

				SVAR PopSizeDistShape = $("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop" + num2str(i))
				if(stringmatch(PopSizeDistShape, "Gauss"))
					ListOfParametersStr += "DistributionShape_pop" + num2str(i) + "=Gauss;"
					NVAR GMeanSize = $("root:Packages:IR2L_NLSQF:GMeanSize_pop" + num2str(i))
					ListOfParameters += "GaussMean_pop" + num2str(i) + "=" + num2str(GMeanSize) + ";"
					NVAR GWidth = $("root:Packages:IR2L_NLSQF:GWidth_pop" + num2str(i))
					ListOfParameters += "GaussWidth_pop" + num2str(i) + "=" + num2str(GWidth) + ";"
					ListOfParameters += "LSWLocation_pop" + num2str(i) + "=0;"
					ListOfParameters += "LogNormalMin_pop" + num2str(i) + "=0;"
					ListOfParameters += "LogNormalMean_pop" + num2str(i) + "=0;"
					ListOfParameters += "LogNormalSdeviation_pop" + num2str(i) + "=0;"
					ListOfParameters += "SZMean_pop" + num2str(i) + "=0;"
					ListOfParameters += "SZWidth_pop" + num2str(i) + "=0;"
					ListOfParameters += "LSWLocation_pop" + num2str(i) + "=0;"
					ListOfParameters += "ArdLocation_pop" + num2str(i) + "=0;"
					ListOfParameters += "ArdParameter_pop" + num2str(i) + "=0;"
				elseif(stringmatch(PopSizeDistShape, "LogNormal"))
					ListOfParametersStr += "DistributionShape_pop" + num2str(i) + "=LogNormal;"
					NVAR LNMinSize = $("root:Packages:IR2L_NLSQF:LNMinSize_pop" + num2str(i))
					ListOfParameters += "LogNormalMin_pop" + num2str(i) + "=" + num2str(LNMinSize) + ";"
					NVAR LNMeanSize = $("root:Packages:IR2L_NLSQF:LNMeanSize_pop" + num2str(i))
					ListOfParameters += "LogNormalMean_pop" + num2str(i) + "=" + num2str(LNMeanSize) + ";"
					NVAR LNSdeviation = $("root:Packages:IR2L_NLSQF:LNSdeviation_pop" + num2str(i))
					ListOfParameters += "LogNormalSdeviation_pop" + num2str(i) + "=" + num2str(LNSdeviation) + ";"
					ListOfParameters += "GaussMean_pop" + num2str(i) + "=0;"
					ListOfParameters += "GaussWidth_pop" + num2str(i) + "=0;"
					ListOfParameters += "SZMean_pop" + num2str(i) + "=0;"
					ListOfParameters += "SZWidth_pop" + num2str(i) + "=0;"
					ListOfParameters += "LSWLocation_pop" + num2str(i) + "=0;"
					ListOfParameters += "ArdLocation_pop" + num2str(i) + "=0;"
					ListOfParameters += "ArdParameter_pop" + num2str(i) + "=0;"
				elseif(stringMatch(PopSizeDistShape, "Schulz-Zimm"))
					ListOfParametersStr += "DistributionShape_pop" + num2str(i) + "=Schulz-Zimm;"
					NVAR SZMeanSize = $("root:Packages:IR2L_NLSQF:SZMeanSize_pop" + num2str(i))
					ListOfParameters += "SZMeanSize_pop" + num2str(i) + "=" + num2str(SZMeanSize) + ";"
					NVAR SZwidth = $("root:Packages:IR2L_NLSQF:SZWidth_pop" + num2str(i))
					ListOfParameters += "SZWidth_pop" + num2str(i) + "=" + num2str(SZwidth) + ";"
					ListOfParameters += "GaussMean_pop" + num2str(i) + "=0;"
					ListOfParameters += "GaussWidth_pop" + num2str(i) + "=0;"
					ListOfParameters += "LogNormalMin_pop" + num2str(i) + "=0;"
					ListOfParameters += "LogNormalMean_pop" + num2str(i) + "=0;"
					ListOfParameters += "LogNormalSdeviation_pop" + num2str(i) + "=0;"
					ListOfParameters += "LSWLocation_pop" + num2str(i) + "=0;"
					ListOfParameters += "ArdLocation_pop" + num2str(i) + "=0;"
					ListOfParameters += "ArdParameter_pop" + num2str(i) + "=0;"
				elseif(stringMatch(PopSizeDistShape, "Ardell"))
					ListOfParametersStr += "DistributionShape_pop" + num2str(i) + "=Ardell;"
					NVAR ArdLocation = $("root:Packages:IR2L_NLSQF:ArdLocation_pop" + num2str(i))
					ListOfParameters += "ArdLocation_pop" + num2str(i) + "=" + num2str(ArdLocation) + ";"
					NVAR ArdParameter = $("root:Packages:IR2L_NLSQF:ArdParameter_pop" + num2str(i))
					ListOfParameters += "ArdParameter_pop" + num2str(i) + "=" + num2str(ArdParameter) + ";"
					ListOfParameters += "GaussMean_pop" + num2str(i) + "=0;"
					ListOfParameters += "GaussWidth_pop" + num2str(i) + "=0;"
					ListOfParameters += "LogNormalMin_pop" + num2str(i) + "=0;"
					ListOfParameters += "LogNormalMean_pop" + num2str(i) + "=0;"
					ListOfParameters += "LogNormalSdeviation_pop" + num2str(i) + "=0;"
					ListOfParameters += "LSWLocation_pop" + num2str(i) + "=0;"
				else //LSW
					ListOfParametersStr += "DistributionShape_pop" + num2str(i) + "=LSW;"
					NVAR LSWLocation = $("root:Packages:IR2L_NLSQF:LSWLocation_pop" + num2str(i))
					ListOfParameters += "LSWLocation_pop" + num2str(i) + "=" + num2str(LSWLocation) + ";"
					ListOfParameters += "GaussMean_pop" + num2str(i) + "=0;"
					ListOfParameters += "GaussWidth_pop" + num2str(i) + "=0;"
					ListOfParameters += "SZMean_pop" + num2str(i) + "=0;"
					ListOfParameters += "SZWidth_pop" + num2str(i) + "=0;"
					ListOfParameters += "LogNormalMin_pop" + num2str(i) + "=0;"
					ListOfParameters += "LogNormalMean_pop" + num2str(i) + "=0;"
					ListOfParameters += "LogNormalSdeviation_pop" + num2str(i) + "=0;"
					ListOfParameters += "ArdLocation_pop" + num2str(i) + "=0;"
					ListOfParameters += "ArdParameter_pop" + num2str(i) + "=0;"
					//ListOfParameters+="LSWLocation_pop"+num2str(i)+"=0;"
				endif
				// For factor parameters.... messy...
				SVAR FormFac = $("root:Packages:IR2L_NLSQF:FormFactor_pop" + num2str(i))
				ListOfParametersStr += "FormFactor_pop" + num2str(i) + "=" + FormFac + ";"
				if(stringmatch(FormFac, "*User*"))
					SVAR U1FormFac = $("root:Packages:IR2L_NLSQF:FFUserFFformula_pop" + num2str(i))
					ListOfParametersStr += "FFUserFFformula_pop" + num2str(i) + "=" + U1FormFac + ";"
					SVAR U2FormFac = $("root:Packages:IR2L_NLSQF:FFUserVolumeFormula_pop" + num2str(i))
					ListOfParametersStr += "FFUserVolumeFormula_pop" + num2str(i) + "=" + U2FormFac + ";"
				else
					ListOfParametersStr += "FFUserFFformula_pop" + num2str(i) + "= none ;"
					ListOfParametersStr += "FFUserVolumeFormula_pop" + num2str(i) + "= none ;"
				endif

				NVAR FFParam1 = $("root:Packages:IR2L_NLSQF:FormFactor_Param1_pop" + num2str(i))
				ListOfParameters += "FormFactor_Param1_pop" + num2str(i) + "=" + num2str(FFParam1) + ";"
				NVAR FFParam2 = $("root:Packages:IR2L_NLSQF:FormFactor_Param2_pop" + num2str(i))
				ListOfParameters += "FormFactor_Param2_pop" + num2str(i) + "=" + num2str(FFParam1) + ";"
				NVAR FFParam3 = $("root:Packages:IR2L_NLSQF:FormFactor_Param3_pop" + num2str(i))
				ListOfParameters += "FormFactor_Param3_pop" + num2str(i) + "=" + num2str(FFParam1) + ";"
				NVAR FFParam4 = $("root:Packages:IR2L_NLSQF:FormFactor_Param4_pop" + num2str(i))
				ListOfParameters += "FormFactor_Param4_pop" + num2str(i) + "=" + num2str(FFParam1) + ";"
				NVAR FFParam5 = $("root:Packages:IR2L_NLSQF:FormFactor_Param5_pop" + num2str(i))
				ListOfParameters += "FormFactor_Param5_pop" + num2str(i) + "=" + num2str(FFParam1) + ";"
				NVAR FFParam6 = $("root:Packages:IR2L_NLSQF:FormFactor_Param6_pop" + num2str(i))
				ListOfParameters += "FormFactor_Param6_pop" + num2str(i) + "=" + num2str(FFParam1) + ";"

			elseif(stringmatch(model, "Unified level"))
				NVAR Rg   = $("root:Packages:IR2L_NLSQF:UF_Rg_pop" + num2str(i))
				NVAR G    = $("root:Packages:IR2L_NLSQF:UF_G_pop" + num2str(i))
				NVAR P    = $("root:Packages:IR2L_NLSQF:UF_P_pop" + num2str(i))
				NVAR B    = $("root:Packages:IR2L_NLSQF:UF_B_pop" + num2str(i))
				NVAR RgCO = $("root:Packages:IR2L_NLSQF:UF_RgCO_pop" + num2str(i))
				NVAR Kval = $("root:Packages:IR2L_NLSQF:UF_K_pop" + num2str(i))
				ListOfParameters += "UF_Rg_pop" + num2str(i) + "=" + num2str(Rg) + ";"
				ListOfParameters += "UF_G_pop" + num2str(i) + "=" + num2str(G) + ";"
				ListOfParameters += "UF_B_pop" + num2str(i) + "=" + num2str(B) + ";"
				ListOfParameters += "UF_P_pop" + num2str(i) + "=" + num2str(P) + ";"
				ListOfParameters += "UF_RGCO_pop" + num2str(i) + "=" + num2str(RGCO) + ";"
				ListOfParameters += "UF_K_pop" + num2str(i) + "=" + num2str(Kval) + ";"

			elseif(stringmatch(model, "SurfaceFractal"))
				NVAR SurfFrSurf    = $("root:Packages:IR2L_NLSQF:SurfFrSurf_pop" + num2str(i))
				NVAR SurfFrKsi     = $("root:Packages:IR2L_NLSQF:SurfFrKsi_pop" + num2str(i))
				NVAR SurfFrDS      = $("root:Packages:IR2L_NLSQF:SurfFrDS_pop" + num2str(i))
				NVAR SurfFrQc      = $("root:Packages:IR2L_NLSQF:SurfFrQc_pop" + num2str(i))
				NVAR SurfFrQcWidth = $("root:Packages:IR2L_NLSQF:SurfFrQcWidth_pop" + num2str(i))
				ListOfParameters += "SurfFrSurf_pop" + num2str(i) + "=" + num2str(SurfFrSurf) + ";"
				ListOfParameters += "SurfFrKsi_pop" + num2str(i) + "=" + num2str(SurfFrKsi) + ";"
				ListOfParameters += "SurfFrDS_pop" + num2str(i) + "=" + num2str(SurfFrDS) + ";"
				ListOfParameters += "SurfFrQc_pop" + num2str(i) + "=" + num2str(SurfFrQc) + ";"
				ListOfParameters += "SurfFrQcWidth_pop" + num2str(i) + "=" + num2str(SurfFrQcWidth) + ";"

			elseif(stringmatch(model, "MassFractal"))
				NVAR MassFrPhi         = $("root:Packages:IR2L_NLSQF:MassFrPhi_pop" + num2str(i))
				NVAR MassFrRadius      = $("root:Packages:IR2L_NLSQF:MassFrRadius_pop" + num2str(i))
				NVAR MassFrDv          = $("root:Packages:IR2L_NLSQF:MassFrDv_pop" + num2str(i))
				NVAR MassFrKsi         = $("root:Packages:IR2L_NLSQF:MassFrKsi_pop" + num2str(i))
				NVAR MassFrBeta        = $("root:Packages:IR2L_NLSQF:MassFrBeta_pop" + num2str(i))
				NVAR MassFrEta         = $("root:Packages:IR2L_NLSQF:MassFrEta_pop" + num2str(i))
				NVAR MassFrIntgNumPnts = $("root:Packages:IR2L_NLSQF:MassFrIntgNumPnts_pop" + num2str(i))
				ListOfParameters += "MassFrPhi_pop" + num2str(i) + "=" + num2str(MassFrPhi) + ";"
				ListOfParameters += "MassFrRadius_pop" + num2str(i) + "=" + num2str(MassFrRadius) + ";"
				ListOfParameters += "MassFrDv_pop" + num2str(i) + "=" + num2str(MassFrDv) + ";"
				ListOfParameters += "MassFrKsi_pop" + num2str(i) + "=" + num2str(MassFrKsi) + ";"
				ListOfParameters += "MassFrBeta_pop" + num2str(i) + "=" + num2str(MassFrBeta) + ";"
				ListOfParameters += "MassFrEta_pop" + num2str(i) + "=" + num2str(MassFrEta) + ";"
				ListOfParameters += "MassFrIntgNumPnts_pop" + num2str(i) + "=" + num2str(MassFrIntgNumPnts) + ";"

			elseif(stringmatch(Model, "Diffraction peak"))
				//diffraction peak data
				SVAR PeakProfile     = $("root:Packages:IR2L_NLSQF:DiffPeakProfile_pop" + num2str(i))
				NVAR DiffPeakDPos    = $("root:Packages:IR2L_NLSQF:DiffPeakDPos_pop" + num2str(i))
				NVAR DiffPeakQPos    = $("root:Packages:IR2L_NLSQF:DiffPeakQPos_pop" + num2str(i))
				NVAR DiffPeakQFWHM   = $("root:Packages:IR2L_NLSQF:DiffPeakQFWHM_pop" + num2str(i))
				NVAR DiffPeakIntgInt = $("root:Packages:IR2L_NLSQF:DiffPeakIntgInt_pop" + num2str(i))
				NVAR DiffPeakPar1    = $("root:Packages:IR2L_NLSQF:DiffPeakPar1_pop" + num2str(i))
				NVAR DiffPeakPar2    = $("root:Packages:IR2L_NLSQF:DiffPeakPar2_pop" + num2str(i))
				NVAR DiffPeakPar3    = $("root:Packages:IR2L_NLSQF:DiffPeakPar3_pop" + num2str(i))
				NVAR DiffPeakPar4    = $("root:Packages:IR2L_NLSQF:DiffPeakPar4_pop" + num2str(i))
				NVAR DiffPeakPar5    = $("root:Packages:IR2L_NLSQF:DiffPeakPar5_pop" + num2str(i))
				ListOfParameters += "DiffPeakProfile_pop" + num2str(i) + "=" + PeakProfile + ";"
				ListOfParameters += "DiffPeakDPos_pop" + num2str(i) + "=" + num2str(DiffPeakDPos) + ";"
				ListOfParameters += "DiffPeakQPos_pop" + num2str(i) + "=" + num2str(DiffPeakQPos) + ";"
				ListOfParameters += "DiffPeakQFWHM_pop" + num2str(i) + "=" + num2str(DiffPeakQFWHM) + ";"
				ListOfParameters += "DiffPeakIntgInt_pop" + num2str(i) + "=" + num2str(DiffPeakIntgInt) + ";"
				ListOfParameters += "DiffPeakPar1_pop" + num2str(i) + "=" + num2str(DiffPeakPar1) + ";"
				ListOfParameters += "DiffPeakPar2_pop" + num2str(i) + "=" + num2str(DiffPeakPar2) + ";"
				ListOfParameters += "DiffPeakPar3_pop" + num2str(i) + "=" + num2str(DiffPeakPar3) + ";"
				ListOfParameters += "DiffPeakPar4_pop" + num2str(i) + "=" + num2str(DiffPeakPar4) + ";"
				ListOfParameters += "DiffPeakPar5_pop" + num2str(i) + "=" + num2str(DiffPeakPar5) + ";"

			endif
			//this is needed always
			NVAR SameContrastForDataSets = root:Packages:IR2L_NLSQF:SameContrastForDataSets
			//				ListOfPopulationVariables+="Contrast;Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
			if(!SameContrastForDataSets)
				//ListOfParameters+="Contrast_pop"+num2str(i)+"=0;"
				ListOfPopulationVariables = "Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
				for(k = 0; k < itemsInList(ListOfPopulationVariables); k += 1)
					NVAR testVar = $(StringFromList(k, ListOfPopulationVariables) + "_pop" + num2str(i))
					ListOfParameters += StringFromList(k, ListOfPopulationVariables) + "_pop" + num2str(i) + "=" + num2str(testVar) + ";"
				endfor
			else //same contrast for all sets...
				NVAR Contrast = $("root:Packages:IR2L_NLSQF:Contrast_pop" + num2str(i))
				ListOfParameters += "Contrast_pop" + num2str(i) + "=" + num2str(Contrast) + ";"
				//ListOfPopulationVariables="Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
				//for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)
				//NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
				//ListOfParameters+=StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i)+"=0;"
				//endfor
			endif

			if(stringmatch(Model, "Unified level") || stringmatch(Model, "Size dist.")) //ad this is needed for Unified and Distribution
				SVAR StrFac = $("root:Packages:IR2L_NLSQF:StructureFactor_pop" + num2str(i))
				ListOfParametersStr += "StructureFactor_pop" + num2str(i) + "=" + StrFac + ";"
				if(!stringmatch(StrFac, "*Dilute system*"))
					NVAR StructureParam1 = $("root:Packages:IR2L_NLSQF:StructureParam1_pop" + num2str(i))
					ListOfParameters += "StructureParam1_pop" + num2str(i) + "=" + num2str(StructureParam1) + ";"
					NVAR StructureParam2 = $("root:Packages:IR2L_NLSQF:StructureParam2_pop" + num2str(i))
					ListOfParameters += "StructureParam2_pop" + num2str(i) + "=" + num2str(StructureParam2) + ";"
					NVAR StructureParam3 = $("root:Packages:IR2L_NLSQF:StructureParam3_pop" + num2str(i))
					ListOfParameters += "StructureParam3_pop" + num2str(i) + "=" + num2str(StructureParam3) + ";"
					NVAR StructureParam4 = $("root:Packages:IR2L_NLSQF:StructureParam4_pop" + num2str(i))
					ListOfParameters += "StructureParam4_pop" + num2str(i) + "=" + num2str(StructureParam4) + ";"
					NVAR StructureParam5 = $("root:Packages:IR2L_NLSQF:StructureParam5_pop" + num2str(i))
					ListOfParameters += "StructureParam5_pop" + num2str(i) + "=" + num2str(StructureParam5) + ";"
					NVAR StructureParam6 = $("root:Packages:IR2L_NLSQF:StructureParam6_pop" + num2str(i))
					ListOfParameters += "StructureParam6_pop" + num2str(i) + "=" + num2str(StructureParam6) + ";"
				else
					ListOfParameters += "StructureParam1_pop" + num2str(i) + "=0;"
					ListOfParameters += "StructureParam2_pop" + num2str(i) + "=0;"
					ListOfParameters += "StructureParam3_pop" + num2str(i) + "=0;"
					ListOfParameters += "StructureParam4_pop" + num2str(i) + "=0;"
					ListOfParameters += "StructureParam5_pop" + num2str(i) + "=0;"
					ListOfParameters += "StructureParam6_pop" + num2str(i) + "=0;"
				endif
			endif

		else //this population does not exist, but we need to set these to 0 to have the line in the waves if needed...
			//
			//				ListOfPopulationVariables="Volume;Mean;Mode;Median;FWHM;"
			//				for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)
			//					NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
			//					ListOfParameters+=StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i)+"=0;"
			//				endfor
			//
			//				ListOfParametersStr+="FormFactor_pop"+num2str(i)+"= none ;"
			//				ListOfParametersStr+="FFUserFFformula_pop"+num2str(i)+"= none ;"
			//				ListOfParametersStr+="FFUserVolumeFormula_pop"+num2str(i)+"= none ;"
			//				ListOfParameters+="FormFactor_Param1_pop"+num2str(i)+"=0;"
			//				ListOfParameters+="FormFactor_Param2_pop"+num2str(i)+"=0;"
			//				ListOfParameters+="FormFactor_Param3_pop"+num2str(i)+"=0;"
			//				ListOfParameters+="FormFactor_Param4_pop"+num2str(i)+"=0;"
			//				ListOfParameters+="FormFactor_Param5_pop"+num2str(i)+"=0;"
			//				ListOfParameters+="FormFactor_Param6_pop"+num2str(i)+"=0;"
			//
			//
			//				SVAR PopSizeDistShape = $("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(i))
			//				ListOfParametersStr+="DistributionShape_pop"+num2str(i)+"=none;"
			//				ListOfParameters+="GaussMean_pop"+num2str(i)+"=0;"
			//				ListOfParameters+="GaussWidth_pop"+num2str(i)+"=0;"
			//				ListOfParameters+="LSWLocation_pop"+num2str(i)+"=0;"
			//				ListOfParameters+="LogNormalMin_pop"+num2str(i)+"=0;"
			//				ListOfParameters+="LogNormalMean_pop"+num2str(i)+"=0;"
			//				ListOfParameters+="LogNormalSdeviation_pop"+num2str(i)+"=0;"
			//				NVAR SameContrastForDataSets=root:Packages:IR2L_NLSQF:SameContrastForDataSets
			//				if(SameContrastForDataSets)
			//					ListOfParameters+="Contrast_pop"+num2str(i)+"=0;"
			//				else
			//					ListOfPopulationVariables="Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
			//					for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)
			//						NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
			//						ListOfParameters+=StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i)+"=0;"
			//					endfor
			//				endif
			//				ListOfParametersStr+="StructureFactor_pop"+num2str(i)+"="+"Dilute system"+";"
			//				ListOfParameters+="StructureParam1_pop"+num2str(i)+"=0;"
			//				ListOfParameters+="StructureParam2_pop"+num2str(i)+"=0;"
			//				ListOfParameters+="StructureParam3_pop"+num2str(i)+"=0;"
			//				ListOfParameters+="StructureParam4_pop"+num2str(i)+"=0;"
			//				ListOfParameters+="StructureParam5_pop"+num2str(i)+"=0;"
			//				ListOfParameters+="StructureParam6_pop"+num2str(i)+"=0;"
			//
			//				ListOfParameters+="UF_Rg_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="UF_G_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="UF_B_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="UF_P_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="UF_RGCO_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="UF_K_pop"+num2str(i)+"="+num2str(0)+";"
			//
			//				ListOfParameters+="SurfFrSurf_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="SurfFrKsi_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="SurfFrDS_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="SurfFrQc_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="SurfFrQcWidth_pop"+num2str(i)+"="+num2str(0)+";"
			//
			//				ListOfParameters+="MassFrPhi_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="MassFrRadius_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="MassFrDv_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="MassFrKsi_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="MassFrBeta_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="MassFrEta_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="MassFrIntgNumPnts_pop"+num2str(i)+"="+num2str(0)+";"
			//
			//				ListOfParameters+="DiffPeakProfile_pop"+num2str(i)+"="+"none"+";"
			//				ListOfParameters+="DiffPeakDPos_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="DiffPeakQPos_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="DiffPeakQFWHM_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="DiffPeakIntgInt_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="DiffPeakPar1_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="DiffPeakPar2_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="DiffPeakPar3_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="DiffPeakPar4_pop"+num2str(i)+"="+num2str(0)+";"
			//				ListOfParameters+="DiffPeakPar5_pop"+num2str(i)+"="+num2str(0)+";"

		endif
	endfor
	IR2L_SaveResInWavesIndivDtSet2(ListOfParameters, ListOfParametersStr, NewFolderName)

	setDataFolder oldDF

End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_SaveResInWavesIndivDtSet2(ListOfParameters, ListOfParametersStr, NewFolderName)
	string ListOfParameters, ListOfParametersStr, NewFolderName

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	string NewFolderNameClean = CleanupName(NewFolderName, 1)
	setDatafolder root:
	NewDataFolder/O/S $(NewFolderNameClean)
	variable i, FoundPnts
	WAVE/Z FolderName = $(StringFromList(0, StringFromList(i, ListOfParametersStr, ";"), "="))
	if(WaveExists(FolderName))
		FoundPnts = numpnts(FolderName)
	else
		FoundPnts = 0
	endif
	string   NewWvName
	string   NewStrVal
	variable NewVarVal
	for(i = 0; i < ItemsInList(ListOfParametersStr); i += 1)
		NewWvName = StringFromList(0, StringFromList(i, ListOfParametersStr, ";"), "=")
		NewStrVal = StringFromList(1, StringFromList(i, ListOfParametersStr, ";"), "=")
		IR2L_SaveResInWavesIndivDtSet3(NewWvName, 0, NewStrVal, FoundPnts + 1)
	endfor
	for(i = 0; i < ItemsInList(ListOfParameters); i += 1)
		NewWvName = StringFromList(0, StringFromList(i, ListOfParameters, ";"), "=")
		NewVarVal = str2num(StringFromList(1, StringFromList(i, ListOfParameters, ";"), "="))
		IR2L_SaveResInWavesIndivDtSet3(NewWvName, NewVarVal, "", FoundPnts + 1)
	endfor
	setDataFolder oldDF

End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_SaveResInWavesIndivDtSet3(WvName, NewPointVal, NewPointStr, NextPointToWrite)
	string WvName, NewPointStr
	variable NewPointVal, NextPointToWrite

	if(strlen(NewPointStr) > 0)
		WAVE/Z/T WvStr = $(WvName)
		if(!WaveExists(WvStr))
			make/O/N=0/T $(WvName)
		endif
		WAVE/T WvStr = $(WvName)
		redimension/N=(NextPointToWrite) WvStr
		WvStr[NextPointToWrite - 1] = NewPointStr
	else
		WAVE/Z WvNum = $(WvName)
		if(!WaveExists(WvNum))
			make/O/N=0 $(WvName)
		endif
		WAVE WvNum = $(WvName)
		redimension/N=(NextPointToWrite) WvNum
		WvNum[NextPointToWrite - 1] = NewPointVal
	endif

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function Ir2L_WriteOneFitVarPop(VarName, which)
	string   VarName
	variable which
	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	NVAR testVar    = $(VarName + "_pop" + num2str(which))
	NVAR FittestVar = $(VarName + "Fit_pop" + num2str(which))
	NVAR MintestVar = $(VarName + "Min_pop" + num2str(which))
	NVAR MaxtestVar = $(VarName + "Max_pop" + num2str(which))
	if(FittestVar)
		IR1L_AppendAnyText(VarName + "_pop" + num2str(which) + "\tFitted\tValue=" + num2str(testVar) + "\tMin=" + num2str(MintestVar) + "\tMax=" + num2str(MaxtestVar))
	else
		IR1L_AppendAnyText(VarName + "_pop" + num2str(which) + "\tFixed\tValue=" + num2str(testVar))
	endif
	setDataFolder OldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_RecordModelResults(which)
	variable which
	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	string ListOfVariables, ListOfDataVariables, ListOfPopulationVariables
	string ListOfStrings, ListOfDataStrings, ListOfPopulationsStrings
	string ListOfParameters, ListOfParametersStr
	ListOfParametersStr = ""
	ListOfParameters    = ""
	variable i = which
	variable k
	NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop" + num2str(which))

	if(UseThePop)
		IR1L_AppendAnyText("Used population " + num2str(i) + ",  listing of parameters:\r")
		SVAR PanelVolumeDesignation = root:Packages:IR2L_NLSQF:PanelVolumeDesignation
		NVAR testVar                = $("Volume" + "_pop" + num2str(i))
		IR1L_AppendAnyText(PanelVolumeDesignation + "_pop" + num2str(i) + "\t=\t" + num2str(testVar))

		ListOfPopulationVariables = "Mean;Mode;Median;FWHM;"
		for(k = 0; k < itemsInList(ListOfPopulationVariables); k += 1)
			NVAR testVar = $(StringFromList(k, ListOfPopulationVariables) + "_pop" + num2str(i))
			IR1L_AppendAnyText(StringFromList(k, ListOfPopulationVariables) + "_pop" + num2str(i) + "\t=\t" + num2str(testVar))
		endfor
		IR1L_AppendAnyText(" ")

		SVAR PopSizeDistShape = $("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop" + num2str(i))
		if(stringmatch(PopSizeDistShape, "Gauss"))
			IR1L_AppendAnyText("DistributionShape_pop" + num2str(i) + "\t=\tGauss;")
			Ir2L_WriteOneFitVarPop("GMeanSize", i)
			Ir2L_WriteOneFitVarPop("GWidth", i)
		elseif(stringmatch(PopSizeDistShape, "LogNormal"))
			IR1L_AppendAnyText("DistributionShape_pop" + num2str(i) + "\t=\tLogNormal;")
			Ir2L_WriteOneFitVarPop("LNMinSize", i)
			Ir2L_WriteOneFitVarPop("LNMeanSize", i)
			Ir2L_WriteOneFitVarPop("LNSdeviation", i)
		else //LSW
			IR1L_AppendAnyText("DistributionShape_pop" + num2str(i) + "=LSW;")
			Ir2L_WriteOneFitVarPop("LSWLocation", i)
		endif

		NVAR VaryContrast    = root:Packages:IR2L_NLSQF:SameContrastForDataSets
		NVAR UseMultipleData = root:Packages:IR2L_NLSQF:MultipleInputData
		if(VaryContrast && UseMultipleData)
			IR1L_AppendAnyText("Contrast varies for different populations")
			ListOfPopulationVariables = "Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
			for(k = 0; k < itemsInList(ListOfPopulationVariables); k += 1)
				NVAR testVar = $(StringFromList(k, ListOfPopulationVariables) + "_pop" + num2str(i))
				IR1L_AppendAnyText(StringFromList(k, ListOfPopulationVariables) + "_pop" + num2str(i) + "\t=\t" + num2str(testVar))
			endfor
		else //same contrast for all sets...
			NVAR Contrast = $("root:Packages:IR2L_NLSQF:Contrast_pop" + num2str(i))
			IR1L_AppendAnyText("Contrast_pop" + num2str(i) + "\t=\t" + num2str(Contrast))
		endif
		IR1L_AppendAnyText(" ")
		// For factor parameters.... messy...
		SVAR FormFac = $("root:Packages:IR2L_NLSQF:FormFactor_pop" + num2str(i))
		IR1L_AppendAnyText("FormFactor_pop" + num2str(i) + "\t=\t" + FormFac)
		IR1L_AppendAnyText("Note, not all FF parameters are applicable, check the FF description")
		if(stringmatch(FormFac, "*User*"))
			SVAR U1FormFac = $("root:Packages:IR2L_NLSQF:FFUserFFformula_pop" + num2str(i))
			IR1L_AppendAnyText("FFUserFFformula_pop" + num2str(i) + "\t=\t" + U1FormFac)
			SVAR U2FormFac = $("root:Packages:IR2L_NLSQF:FFUserVolumeFormula_pop" + num2str(i))
			IR1L_AppendAnyText("FFUserVolumeFormula_pop" + num2str(i) + "\t=\t" + U2FormFac)
		endif
		Ir2L_WriteOneFitVarPop("FormFactor_Param1", i)
		Ir2L_WriteOneFitVarPop("FormFactor_Param2", i)
		Ir2L_WriteOneFitVarPop("FormFactor_Param3", i)
		Ir2L_WriteOneFitVarPop("FormFactor_Param4", i)
		Ir2L_WriteOneFitVarPop("FormFactor_Param5", i)
		Ir2L_WriteOneFitVarPop("FormFactor_Param6", i)

		IR1L_AppendAnyText(" ")

		//				NVAR UseInterference = $("root:Packages:IR2L_NLSQF:UseInterference_pop"+num2str(i))
		SVAR StrFac = $("root:Packages:IR2L_NLSQF:StructureFactor_pop" + num2str(i))
		IR1L_AppendAnyText("StructureFactor_pop" + num2str(i) + "=" + StrFac)
		if(!stringmatch(StrFac, "*Dilute system*"))
			Ir2L_WriteOneFitVarPop("StructureParam1", i)
			Ir2L_WriteOneFitVarPop("StructureParam2", i)
			Ir2L_WriteOneFitVarPop("StructureParam3", i)
			Ir2L_WriteOneFitVarPop("StructureParam4", i)
			Ir2L_WriteOneFitVarPop("StructureParam5", i)
			Ir2L_WriteOneFitVarPop("StructureParam6", i)
		else
			IR1L_AppendAnyText("Dilute system, no Structure factor parameters applicable")
		endif
		IR1L_AppendAnyText("  ")
	endif

	setDataFolder OldDf
End

//*****************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_RecordDataResults(which)
	variable which

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF

	string ListOfVariables, ListOfDataVariables, ListOfPopulationVariables
	string ListOfStrings, ListOfDataStrings, ListOfPopulationsStrings
	string ListOfParameters, ListOfParametersStr
	ListOfParametersStr = ""
	ListOfParameters    = ""
	variable i, j

	ListOfDataStrings = "IntensityDataName;QvecDataName;ErrorDataName;UserDataSetName;"
	for(i = 0; i < itemsInList(ListOfDataStrings); i += 1)
		SVAR testStr = $(StringFromList(i, ListOfDataStrings) + "_set" + num2str(which))
		IR1L_AppendAnyText(StringFromList(i, ListOfDataStrings) + "_set" + num2str(which) + "\t=\t" + testStr)
	endfor
	ListOfDataVariables = "DataScalingFactor;ErrorScalingFactor;Qmin;Qmax;"
	for(i = 0; i < itemsInList(ListOfDataVariables); i += 1)
		NVAR testVar = $(StringFromList(i, ListOfDataVariables) + "_set" + num2str(which))
		IR1L_AppendAnyText(StringFromList(i, ListOfDataVariables) + "_set" + num2str(which) + "\t=\t" + num2str(testVar))
	endfor
	Ir2L_WriteOneFitVar("Background", which)
	setDataFolder OldDf
End
//*****************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_WriteOneFitVar(VarName, which)
	string   VarName
	variable which

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:IR2L_NLSQF
	NVAR testVar    = $(VarName + "_set" + num2str(which))
	NVAR FittestVar = $(VarName + "Fit_set" + num2str(which))
	NVAR MintestVar = $(VarName + "Min_set" + num2str(which))
	NVAR MaxtestVar = $(VarName + "Max_set" + num2str(which))
	if(FittestVar)
		IR1L_AppendAnyText(VarName + "_set" + num2str(which) + "\tFitted\tValue=" + num2str(testVar) + "\tMin=" + num2str(MintestVar) + "\tMax=" + num2str(MaxtestVar))
	else
		IR1L_AppendAnyText(VarName + "_set" + num2str(which) + "\tFixed\tValue=" + num2str(testVar))
	endif
	setDataFolder OldDf
End
//*****************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_SetDataUnits(UnitString)
	string UnitString

	SVAR DataCalibrationUnits    = root:Packages:IR2L_NLSQF:DataCalibrationUnits
	SVAR PanelVolumeDesignation  = root:Packages:IR2L_NLSQF:PanelVolumeDesignation
	SVAR IntCalibrationUnits     = root:Packages:IR2L_NLSQF:IntCalibrationUnits
	SVAR VolDistCalibrationUnits = root:Packages:IR2L_NLSQF:VolDistCalibrationUnits
	SVAR NumDistCalibrationUnits = root:Packages:IR2L_NLSQF:NumDistCalibrationUnits
	NVAR UseNumberDistributions  = root:Packages:IR2L_NLSQF:UseNumberDistributions
	if(strlen(UnitString) < 2 || stringMatch(UnitString, "arbitrary"))
		DataCalibrationUnits    = "Arbitrary"
		PanelVolumeDesignation  = "Scale        "
		IntCalibrationUnits     = "Arbitrary"
		VolDistCalibrationUnits = "Arbitrary"
		NumDistCalibrationUnits = "Arbitrary"
	elseif(strlen(UnitString) < 2 || stringMatch(UnitString, "cm2/cm3"))
		DataCalibrationUnits = "cm2/cm3"
		//PanelVolumeDesignation="Fract. [c*(1-c)]"
		PanelVolumeDesignation  = "Fraction"
		IntCalibrationUnits     = "cm\S2\M/cm\S3\M"
		VolDistCalibrationUnits = "Fraction"
		NumDistCalibrationUnits = "N/cm3"
	elseif(strlen(UnitString) < 2 || stringMatch(UnitString, "cm2/g"))
		DataCalibrationUnits    = "cm2/g"
		PanelVolumeDesignation  = "Vol [cm3/g]"
		IntCalibrationUnits     = "cm\S2\M/g\M"
		VolDistCalibrationUnits = "cm3/g"
		NumDistCalibrationUnits = "N/g"
	else
		DataCalibrationUnits    = "Arbitrary"
		PanelVolumeDesignation  = "Scale"
		IntCalibrationUnits     = "Arbitrary"
		VolDistCalibrationUnits = "Arbitrary"
		NumDistCalibrationUnits = "Arbitrary"
	endif

	//set popup with units....
	SVAR     DataCalibrationUnits = root:Packages:IR2L_NLSQF:DataCalibrationUnits
	variable modeVal              = 1 + WhichListItem(DataCalibrationUnits, "Arbitrary;cm2/cm3;cm2/g;")
	if(modeVal < 1 || modeVal > 3)
		modeVal = 1
	endif
	SetVariable Volume, win=LSQF2_MainPanel, title=PanelVolumeDesignation

	DoWIndow LSQF2_ModelingII_MoreDetails
	if(V_Flag)
		PopupMenu DataUnits, win=LSQF2_ModelingII_MoreDetails, mode=modeVal
	endif
	DoWIndow LSQF_MainGraph
	if(V_Flag)
		IR2L_FormatInputGraph()
	endif
End

//*****************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************
//*****************************************************************************************************************
