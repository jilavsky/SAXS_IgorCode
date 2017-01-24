#pragma rtGlobals=2		// Use modern global access method.
#pragma version=1.20
Constant IR2LversionNumber = 1.19

//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

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
		IR2L_MainPanel()
		ING2_AddScrollControl()
		IR1_UpdatePanelVersionNumber("LSQF2_MainPanel", IR2LversionNumber,1)
	endif
	IR2L_RecalculateIfSelected()
	DoWindow IR2L_ResSmearingPanel
	if(V_Flag)
		DoWindow/F IR2L_ResSmearingPanel
	endif	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_MainCheckVersion()	
	DoWindow LSQF2_MainPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("LSQF2_MainPanel", IR2LversionNumber))
			DoAlert /T="The Modeling II panel was created by old version of Irena " 1, "Modeling II may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				Execute/P("DoWindow/K LSQF2_MainPanel")
				Execute/P("IR2L_Main()")
			else		//at least reinitialize the variables so we avoid major crashes...
				IR2L_Initialize()
				IR2S_InitStructureFactors()
			endif
		endif
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2L_MainPanel()
	//PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(3,42,410,730) as "Modeling II main panel"
	DoWindow/C LSQF2_MainPanel
	//DefaultGUIControls /W=LSQF2_MainPanel /Mac native
	
	string AllowedIrenaTypes="DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;"
	IR2C_AddDataControls("IR2L_NLSQF","LSQF2_MainPanel",AllowedIrenaTypes,"","","","","", 0,1)
	CheckBox QLogScale pos={100,131}
	TitleBox MainTitle title="\Zr190Modeling II",pos={100,0},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={200,24},anchor=MC,fColor=(0,0,52224)


	SetVariable RebinDataTo,limits={0,1000,0},variable= root:Packages:IR2L_NLSQF:RebinDataTo, noproc
	SetVariable RebinDataTo,pos={290,130},size={110,15},title="Rebin to:", help={"To rebin data on import, set to integer number. 0 means no rebinning. "}

	TitleBox FakeLine1 title=" ",fixedSize=1,size={270,3},pos={16,184},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info1 title="\Zr120Data input",pos={10,30},frame=0,fstyle=1, fixedSize=1,size={80,20},fColor=(0,0,52224)

	Button RemoveAllDataSets, pos={5,148},size={90,18}, proc=IR2L_InputPanelButtonProc,title="Remove all", help={"Remove all data from tool"}
	Button UnuseAllDataSets, pos={100,148},size={90,18}, proc=IR2L_InputPanelButtonProc,title="unUse all", help={"Set all data set to not Use"}
	Button ConfigureGraph, pos={195,148},size={90,18}, proc=IR2L_InputPanelButtonProc,title="Config Graph", help={"Set parameters for graph"}
	Button ReGraph, pos={290,148},size={90,18}, proc=IR2L_InputPanelButtonProc,title="Graph (ReGraph)", help={"Create or Recreate graph"}
	Button ScriptingTool, pos={290,168},size={90,18}, proc=IR2L_InputPanelButtonProc,title="Scripting tool", help={"Open Scripting tool to analyze multipel data sets subsequently"}
	Button MoreSDParameters, pos={5,167},size={140,18}, proc=IR2L_InputPanelButtonProc,title="More parameters", help={"Get panel with more parameters parameters"},valueColor=(65535,0,0)

	CheckBox DisplayInputDataControls,pos={10,188},size={25,16},proc=IR2L_DataTabCheckboxProc,title="Data cntrls", mode=1
	CheckBox DisplayInputDataControls,variable= root:Packages:IR2L_NLSQF:DisplayInputDataControls, help={"Select to get data controls"}
	CheckBox DisplayModelControls,pos={90,188},size={25,16},proc=IR2L_DataTabCheckboxProc,title="Model cntrls", mode=1
	CheckBox DisplayModelControls,variable= root:Packages:IR2L_NLSQF:DisplayModelControls, help={"Select to get model controls"}
	CheckBox RecalculateAutomatically,pos={300,188},size={25,90},proc=IR2L_DataTabCheckboxProc,title="Auto Recalculate?"
	CheckBox RecalculateAutomatically,variable= root:Packages:IR2L_NLSQF:RecalculateAutomatically, help={"Check to have everything recalculate when change is made. SLOW!"}

	CheckBox MultipleInputData,pos={10,203},size={25,90},proc=IR2L_DataTabCheckboxProc,title="Multiple Input Data sets?"
	CheckBox MultipleInputData,variable= root:Packages:IR2L_NLSQF:MultipleInputData, help={"Do you want to use multiple input data sets in this tool?"}
	CheckBox NoFittingLimits,pos={300,203},size={25,90},proc=IR2L_DataTabCheckboxProc,title="No Fitting Limits?"
	CheckBox NoFittingLimits,variable= root:Packages:IR2L_NLSQF:NoFittingLimits, help={"Check to do fitting without fitting limits."}


	CheckBox SameContrastForDataSets,pos={175,188},size={25,16},proc=IR2L_DataTabCheckboxProc,title="Vary contrasts?"
	CheckBox SameContrastForDataSets,variable= root:Packages:IR2L_NLSQF:SameContrastForDataSets, help={"Check if contrast varies between data sets for one population?"}
	SVAR DataCalibrationUnits=root:Packages:IR2L_NLSQF:DataCalibrationUnits
	SetVariable DataCalibrationUnits, variable= root:Packages:IR2L_NLSQF:DataCalibrationUnits, noedit=1,noproc,frame=0, pos={175,204}
	SetVariable DataCalibrationUnits, title="Units:", valueColor=(65535,0,0),labelBack=0, size={120,15}, help={"Units for Intensity, change with \"More parameetrs\" button"}
	NVAR DisplayInputDataControls=root:Packages:IR2L_NLSQF:DisplayInputDataControls
	NVAR DisplayModelControls=root:Packages:IR2L_NLSQF:DisplayModelControls
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData

	//Data Tabs definition
	TabControl DataTabs,pos={1,220},size={405,320},proc=IR2L_Data_TabPanelControl
	TabControl DataTabs,tabLabel(0)="1.",tabLabel(1)="2."
	TabControl DataTabs,tabLabel(2)="3.",tabLabel(3)="4."
	TabControl DataTabs,tabLabel(4)="5.",tabLabel(5)="6."
	TabControl DataTabs,tabLabel(6)="7.",tabLabel(7)="8."
	TabControl DataTabs,tabLabel(8)="9.",tabLabel(9)="10.", value= 0, disable =!DisplayInputDataControls

//	variable i
		Button AddDataSet, pos={5,245},size={80,16}, proc=IR2L_InputPanelButtonProc,title="Add data", help={"Load data into the tool"}

		CheckBox UseTheData_set,pos={95,245},size={25,16},proc=IR2L_DataTabCheckboxProc,title="Use?"
		CheckBox UseTheData_set,variable= root:Packages:IR2L_NLSQF:UseTheData_set1, help={"Use the data in the tool?"}
		CheckBox UseSmearing_set,pos={175,245},size={25,16},proc=IR2L_DataTabCheckboxProc,title="Slit/Q resolution smeared?"
		CheckBox UseSmearing_set,variable= root:Packages:IR2L_NLSQF:UseSmearing_set1, help={"Data smeared by Q resolution (slit/pixel)?"}
//		SetVariable SlitLength_set,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:SlitLength_set1, proc=IR2L_DataTabSetVarProc
//		SetVariable SlitLength_set,pos={260,245},size={140,15},title="Slit length [1/A]:", help={"This is slit length of the set currently loaded."}
 
 		SetVariable FolderName_set,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:FolderName_set1, noedit=1,noproc,frame=0,labelBack=(0,52224,0)
		SetVariable FolderName_set,pos={5,265},size={395,15},title="Data:", help={"This is data set currently loaded in this data set."}
 		SetVariable UserDataSetName_set,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:UserDataSetName_set1, proc=IR2L_DataTabSetVarProc
		SetVariable UserDataSetName_set,pos={5,285},size={395,15},title="User Name:", help={"This is data set currently loaded in this data set."}


//	ListOfDataVariables+="DataScalingFactor;ErrorScalingFactor;UseUserErrors;UseSQRTErrors;UsePercentErrors;PercentErrors
		SetVariable DataScalingFactor_set,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:DataScalingFactor_set1, proc=IR2L_DataTabSetVarProc
		SetVariable DataScalingFactor_set,pos={10,305},size={150,15},title="Scale data by:", help={"Value to scale data set"} 
		CheckBox UseUserErrors_set,pos={10,325},size={25,16},proc=IR2L_DataTabCheckboxProc,title="User errors?", mode=1
		CheckBox UseUserErrors_set,variable= root:Packages:IR2L_NLSQF:UseUserErrors_set1, help={"Use user errors (if input)?"}
		CheckBox UseSQRTErrors_set,pos={100,325},size={25,16},proc=IR2L_DataTabCheckboxProc,title="SQRT errors?", mode=1
		CheckBox UseSQRTErrors_set,variable= root:Packages:IR2L_NLSQF:UseSQRTErrors_set1, help={"Use square root of intensity errors?"}
		CheckBox UsePercentErrors_set,pos={200,325},size={25,16},proc=IR2L_DataTabCheckboxProc,title="User % errors?", mode=1
		CheckBox UsePercentErrors_set,variable= root:Packages:IR2L_NLSQF:UsePercentErrors_set1, help={"Use errors equal to % of intensity?"}
		SetVariable ErrorScalingFactor_set,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:ErrorScalingFactor_set1, proc=IR2L_DataTabSetVarProc
		SetVariable ErrorScalingFactor_set,pos={10,345},size={150,15},title="Scale errors by:", help={"Value to scale errors by"} 


		SetVariable Qmin_set,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Qmin_set1, proc=IR2L_DataTabSetVarProc
		SetVariable Qmin_set,pos={10,370},size={100,15},title="Q min:", help={"This is Q min selected for this data set for fitting."} 
		SetVariable Qmax_set,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Qmax_set1, proc=IR2L_DataTabSetVarProc
		SetVariable Qmax_set,pos={140,370},size={100,15},title="Q max:", help={"This is Q max selected for this data set for fitting."} 
		Button ReadCursors, pos={285,369},size={80,16}, proc=IR2L_InputPanelButtonProc,title="Q from cursors", help={"Read cursors positon into the Q range for fitting"}
	
		SetVariable Background,limits={-inf,Inf,1},variable= root:Packages:IR2L_NLSQF:Background_set1, proc=IR2L_DataTabSetVarProc
		SetVariable Background,pos={5,420},size={120,15},title="Bckg:", help={"Flat background for this data set"} 
		CheckBox BackgroundFit_set,pos={150,420},size={25,14},proc=IR2L_DataTabCheckboxProc,title="Fit?"
		CheckBox BackgroundFit_set,variable= root:Packages:IR2L_NLSQF:BackgroundFit_set1, help={"Fit the background?"}
		SetVariable BackgroundMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:BackgroundMin_set1, noproc
	 	SetVariable BackgroundMin,pos={220,420},size={80,15},title="Min:", help={"Fitting range for background, minimum"} 
		SetVariable BackgroundMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:BackgroundMax_set1, noproc
		SetVariable BackgroundMax,pos={310,420},size={80,15},title="Max:", help={"Fitting range for background, maxcimum set"} 

		Button RemovePointWcsrA, pos={5,450},size={150,16}, proc=IR2L_InputPanelButtonProc,title="Remove pnt w/csrA", help={"Set cursor A and use this to remove points"}

//		SetVariable BackgStep_set,limits={0,Inf,1},variable= root:Packages:IR2L_NLSQF:BackgStep_set1, proc=IR2L_DataTabSetVarProc
//		SetVariable BackgStep_set,pos={15,440},size={120,15},title="Step:", help={"Flat background for this data set"} 
		IR2L_Data_TabPanelControl("",0)
	//Confing ASAXS or SAXS part here

	SVAR PanelVolumeDesignation=root:Packages:IR2L_NLSQF:PanelVolumeDesignation
	//Dist Tabs definition
	TabControl DistTabs,pos={1,220},size={405,380},proc=IR2L_Model_TabPanelControl
	TabControl DistTabs,tabLabel(0)="1 P",tabLabel(1)="2 P"
	TabControl DistTabs,tabLabel(2)="3 P",tabLabel(3)="4 P"
	TabControl DistTabs,tabLabel(4)="5 P",tabLabel(5)="6 P"
	TabControl DistTabs,tabLabel(6)="7 P",tabLabel(7)="8 P"
	TabControl DistTabs,tabLabel(8)="9 P",tabLabel(9)="10 P", value= 0, disable=!DisplayModelControls

		CheckBox UseThePop,pos={4,241},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Use?",  fstyle=1
		CheckBox UseThePop,variable= root:Packages:IR2L_NLSQF:UseThePop_pop1, help={"Use the population in calculations?"}

		SetVariable UserName,variable= root:Packages:IR2L_NLSQF:UserName_pop1, proc=IR2L_PopSetVarProc
		SetVariable UserName,pos={170,241},size={230,10},title="What is this?:", help={"User name for this population. What is this?"} 

		PopupMenu PopulationType title="Model : ",proc=IR2L_PanelPopupControl, pos={5,254}
		PopupMenu PopulationType mode=1, value="Size dist.;Unified level;Diffraction Peak;MassFractal;SurfaceFractal;"
		PopupMenu PopulationType help={"Select Model to be used for this population"}

		CheckBox RdistAuto,pos={180,257},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="R dist auto?", mode=1
		CheckBox RdistAuto,variable= root:Packages:IR2L_NLSQF:RdistAuto_pop1, help={"Use automatic method to determin Rmin and Rmax?"}
		CheckBox RdistrSemiAuto,pos={260,257},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Semi-auto?", mode=1
		CheckBox RdistrSemiAuto,variable= root:Packages:IR2L_NLSQF:RdistrSemiAuto_pop1, help={"Use automatic method for Rmin R max except in fitting?"}
		CheckBox RdistMan,pos={340,257},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Manual?", mode=1
		CheckBox RdistMan,variable= root:Packages:IR2L_NLSQF:RdistMan_pop1, help={"Manually set Rmin R max?"}

		SetVariable RdistNumPnts,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:RdistNumPnts_pop1, proc=IR2L_PopSetVarProc
		SetVariable RdistNumPnts,pos={5,275},size={110,15},title="Num pnts:", help={"Number of points in the population"} 
		SetVariable RdistManMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:RdistManMin_pop1, noproc
		SetVariable RdistManMin,pos={140,275},size={100,15},title="R min:", help={"This is R min selected for this population"} 
		SetVariable RdistManMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:RdistManMax_pop1, noproc
		SetVariable RdistManMax,pos={260,275},size={100,15},title="R max:", help={"This is R max selected for this population"} 

		SetVariable RdistNeglectTails,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:RdistNeglectTails_pop1, proc=IR2L_PopSetVarProc
		SetVariable RdistNeglectTails,pos={140,275},size={180,15},title="R dist neglect tails:", help={"What fraction of population to neglect, see manual, 0.01 is good"} 

		CheckBox RdistLog,pos={10,295},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Log R dist?"
		CheckBox RdistLog,variable= root:Packages:IR2L_NLSQF:RdistLog_pop1, help={"Use Log binning for R distribution?"}
//	SVAR ListOfFormFactors=root:Packages:FormFactorCalc:ListOfFormFactors
		PopupMenu FormFactorPop title="Form Factor : ",proc=IR2L_PanelPopupControl, pos={10,315}
		PopupMenu FormFactorPop mode=1, value=#"(root:Packages:FormFactorCalc:ListOfFormFactors)"
		PopupMenu FormFactorPop help={"Select form factor to be used for this population of scatterers"}
		
		SetVariable SizeDist_DimensionType,variable= root:Packages:IR2L_NLSQF:SizeDist_DimensionType, noproc, disable=0,frame=0,valueColor=(39321,1,1), noedit=1
		SetVariable SizeDist_DimensionType,pos={100,335},size={300,15},title="Size Dist.  is : ", help={"Is SD using Number/Volume distribution and diameters or radia? "} 
		SetVariable SizeDist_DimensionType fstyle=3,fColor=(52428,1,1)
		
		PopupMenu PopSizeDistShape title="Distribution type : ",proc=IR2L_PanelPopupControl, pos={190,295}
		PopupMenu PopSizeDistShape mode=1, value="LogNormal;Gauss;LSW;Schulz-Zimm;"
		PopupMenu PopSizeDistShape help={"Select Distribution type for this population"}

		Button GetFFHelp,pos={320,320},size={80,15}, proc=IR2L_InputPanelButtonProc,title="F.F. Help", help={"Get help for Form factors"}
		Button GetSFHelp,pos={320,468},size={80,15}, proc=IR2L_InputPanelButtonProc,title="S.F. Help", help={"Get Help for Structure factor"}

// Unified controls
		Button FitRgAndG,pos={200,320},size={100,15}, proc=IR2L_InputPanelButtonProc,title="Fit Rg/G bwtn csrs", help={"Do local fit of Gunier dependence between the cursors amd put resulting values into the Rg and G fields"}
		Button FitPandB,pos={301,320},size={100,15}, proc=IR2L_InputPanelButtonProc,title="Fit P/B bwtn csrs", help={"Do local fit of Powerlaw dependence between the cursors amd put resulting values into the Rg and G fields"}

		CheckBox UF_LinkB,pos={20,328},size={20,16},proc=IR2L_ModelTabCheckboxProc,title="Link B to G/Rg/P?"
		CheckBox UF_LinkB,variable= root:Packages:IR2L_NLSQF:UF_LinkB_pop1, help={"Link B to G/Rg/B based on Guinier/Porod model?"}

		SetVariable UF_G,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:UF_G_pop1,proc=IR2L_PopSetVarProc
		SetVariable UF_G,pos={8,355},size={140,15},title="G = ", help={"G for Unified level"} 
		CheckBox UF_GFit,pos={155,355},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox UF_GFit,variable= root:Packages:IR2L_NLSQF:UF_GFit_pop1, help={"Fit the G?"}
		SetVariable UF_GMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:UF_GMin_pop1,noproc
		SetVariable UF_GMin,pos={200,355},size={80,15},title="Min ", help={"Low limit for G"} 
		SetVariable UF_GMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:UF_GMax_pop1,noproc
		SetVariable UF_GMax,pos={290,355},size={80,15},title="Max ", help={"High limit for G"} 

		SetVariable UF_Rg,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:UF_Rg_pop1,proc=IR2L_PopSetVarProc
		SetVariable UF_Rg,pos={8,375},size={140,15},title="Rg [A]= ", help={"Rg (size)"} 
		CheckBox UF_RgFit,pos={155,375},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox UF_RgFit,variable= root:Packages:IR2L_NLSQF:UF_RgFit_pop1, help={"Fit the Rg?"}
		SetVariable UF_RgMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:UF_RgMin_pop1,noproc
		SetVariable UF_RgMin,pos={200,375},size={80,15},title="Min ", help={"Low Rg"} 
		SetVariable UF_RgMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:UF_RgMax_pop1,noproc
		SetVariable UF_RgMax,pos={290,375},size={80,15},title="Max ", help={"High Rg"} 

		SetVariable UF_B,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:UF_B_pop1,proc=IR2L_PopSetVarProc
		SetVariable UF_B,pos={8,395},size={140,15},title="B = ", help={"B for UF"} 
		CheckBox UF_BFit,pos={155,395},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox UF_BFit,variable= root:Packages:IR2L_NLSQF:UF_BFit_pop1, help={"Fit the B?"}
		SetVariable UF_BMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:UF_BMin_pop1,noproc
		SetVariable UF_BMin,pos={200,395},size={80,15},title="Min ", help={"Low limit for B"} 
		SetVariable UF_BMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:UF_BMax_pop1,noproc
		SetVariable UF_BMax,pos={290,395},size={80,15},title="Max ", help={"High limit for B"} 

		SetVariable UF_P,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:UF_P_pop1,proc=IR2L_PopSetVarProc
		SetVariable UF_P,pos={8,415},size={140,15},title="P   = ", help={"P (power law slope)"} 
		CheckBox UF_PFit,pos={155,415},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox UF_PFit,variable= root:Packages:IR2L_NLSQF:UF_PFit_pop1, help={"Fit the P?"}
		SetVariable UF_PMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:UF_PMin_pop1,noproc
		SetVariable UF_PMin,pos={200,415},size={80,15},title="Min ", help={"Low limit for P"} 
		SetVariable UF_PMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:UF_PMax_pop1, noproc
		SetVariable UF_PMax,pos={290,415},size={80,15},title="Max ", help={"High limit for P"} 

		SetVariable UF_RGCO,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:UF_RGCO_pop1,proc=IR2L_PopSetVarProc
		SetVariable UF_RGCO,pos={8,435},size={140,15},title="Rg cut off = ", help={"Rg cut off for higher Unified levels, see reference or manual for meaning"} 
		PopupMenu KFactor,pos={220,452},size={170,15},proc=IR2L_PanelPopupControl,title="k factor :"
		PopupMenu KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}

//particulate controls
		SetVariable Volume,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Volume_pop1,proc=IR2L_PopSetVarProc
		SetVariable Volume,pos={8,355},size={140,15},title=PanelVolumeDesignation, help={"Volume of this population (fractional, should be between 0 and 1 if contrast and calibrated data)"} 
		CheckBox FitVolume,pos={155,355},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox FitVolume,variable= root:Packages:IR2L_NLSQF:VolumeFit_pop1, help={"Fit the volume?"}
		SetVariable VolumeMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:VolumeMin_pop1,noproc
		SetVariable VolumeMin,pos={200,355},size={80,15},title="Min ", help={"Low limit for volume"} 
		SetVariable VolumeMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:VolumeMax_pop1,noproc
		SetVariable VolumeMax,pos={290,355},size={80,15},title="Max ", help={"High limit for volume"} 

//	ListOfPopulationVariables+="LNMinSize;LNMinSizeFit;LNMinSizeMin;LNMinSizeMax;LNMeanSize;LNMeanSizeFit;LNMeanSizeMin;LNMeanSizeMax;LNSdeviation;LNSdeviationFit;LNSdeviationMin;LNSdeviationMax;"	
		//Log-Normal parameters....
		SetVariable LNMinSize,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMinSize_pop1,proc=IR2L_PopSetVarProc
		SetVariable LNMinSize,pos={8,375},size={140,15},title="Min size [A]= ", help={"Log-normal distribution min size [A]"} 
		CheckBox LNMinSizeFit,pos={155,375},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox LNMinSizeFit,variable= root:Packages:IR2L_NLSQF:LNMinSizeFit_pop1, help={"Fit the Min size for Log-Normal distribution?"}
		SetVariable LNMinSizeMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMinSizeMin_pop1,noproc
		SetVariable LNMinSizeMin,pos={200,375},size={80,15},title="Min ", help={"Low limit for min size for Log-normal distribution"} 
		SetVariable LNMinSizeMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMinSizeMax_pop1,noproc
		SetVariable LNMinSizeMax,pos={290,375},size={80,15},title="Max ", help={"High limit for min size for Log-normal distribution"} 

		SetVariable LNMeanSize,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMeanSize_pop1,proc=IR2L_PopSetVarProc
		SetVariable LNMeanSize,pos={8,395},size={140,15},title="Mean [A]= ", help={"Log-normal distribution mean size [A]"} 
		CheckBox LNMeanSizeFit,pos={155,395},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox LNMeanSizeFit,variable= root:Packages:IR2L_NLSQF:LNMeanSizeFit_pop1, help={"Fit the mean size for Log-Normal distribution?"}
		SetVariable LNMeanSizeMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMeanSizeMin_pop1,noproc
		SetVariable LNMeanSizeMin,pos={200,395},size={80,15},title="Min ", help={"Low limit for mean size for Log-normal distribution"} 
		SetVariable LNMeanSizeMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMeanSizeMax_pop1,noproc
		SetVariable LNMeanSizeMax,pos={290,395},size={80,15},title="Max ", help={"High limit for mean size for Log-normal distribution"} 

		SetVariable LNSdeviation,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNSdeviation_pop1,proc=IR2L_PopSetVarProc
		SetVariable LNSdeviation,pos={8,415},size={140,15},title="Std. dev.    = ", help={"Log-normal distribution standard deviation [A]"} 
		CheckBox LNSdeviationFit,pos={155,415},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox LNSdeviationFit,variable= root:Packages:IR2L_NLSQF:LNSdeviationFit_pop1, help={"Fit the standard deviation for Log-Normal distribution?"}
		SetVariable LNSdeviationMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNSdeviationMin_pop1,noproc
		SetVariable LNSdeviationMin,pos={200,415},size={80,15},title="Min ", help={"Low limit for standard deviation for Log-normal distribution"} 
		SetVariable LNSdeviationMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNSdeviationMax_pop1, noproc
		SetVariable LNSdeviationMax,pos={290,415},size={80,15},title="Max ", help={"High limit for standard deviation for Log-normal distribution"} 
//	ListOfPopulationVariables+="GMeanSize;GMeanSizeFit;GMeanSizeMin;GMeanSizeMax;GWidth;GWidthFit;GWidthMin;GWidthMax;LSWLocation;LSWLocationFit;LSWLocationMin;LSWLocationMax;"	
		//Gauss parameters...
		SetVariable GMeanSize,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GMeanSize_pop1,proc=IR2L_PopSetVarProc
		SetVariable GMeanSize,pos={8,375},size={140,15},title="Mean size [A]= ", help={"Gauss mean size [A]"} 
		CheckBox GMeanSizeFit,pos={155,375},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox GMeanSizeFit,variable= root:Packages:IR2L_NLSQF:GMeanSizeFit_pop1, help={"Fit the mean size for gaussian distribution?"}
		SetVariable GMeanSizeMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GMeanSizeMin_pop1, noproc
		SetVariable GMeanSizeMin,pos={200,375},size={80,15},title="Min ", help={"Low limit for mean size for Gaussian distribution"} 
		SetVariable GMeanSizeMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GMeanSizeMax_pop1, noproc
		SetVariable GMeanSizeMax,pos={290,375},size={80,15},title="Max ", help={"High limit for mean size for Gaussian distribution"} 

		SetVariable GWidth,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GWidth_pop1,proc=IR2L_PopSetVarProc
		SetVariable GWidth,pos={8,395},size={140,15},title="Std. dev. [A]= ", help={"Gaussian Std. dev. of size [A]"} 
		CheckBox GWidthFit,pos={155,395},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox GWidthFit,variable= root:Packages:IR2L_NLSQF:GWidthFit_pop1, help={"Fit the width for Gaussian distribution?"}
		SetVariable GWidthMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GWidthMin_pop1, noproc
		SetVariable GWidthMin,pos={200,395},size={80,15},title="Min ", help={"Low limit for width for Gaussian distribution"} 
		SetVariable GWidthMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GWidthMax_pop1, noproc
		SetVariable GWidthMax,pos={290,395},size={80,15},title="Max ", help={"High limit for width for Gaussian distribution"} 
		//SZ parameters...
		SetVariable SZMeanSize,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:SZMeanSize_pop1,proc=IR2L_PopSetVarProc
		SetVariable SZMeanSize,pos={8,375},size={140,15},title="Mean size [A]= ", help={"Schulz-Zimm mean size [A]"} 
		CheckBox SZMeanSizeFit,pos={155,375},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox SZMeanSizeFit,variable= root:Packages:IR2L_NLSQF:SZMeanSizeFit_pop1, help={"Fit the mean size for Schulz-Zimm distribution?"}
		SetVariable SZMeanSizeMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:SZMeanSizeMin_pop1, noproc
		SetVariable SZMeanSizeMin,pos={200,375},size={80,15},title="Min ", help={"Low limit for mean size for Schulz-Zimm distribution"} 
		SetVariable SZMeanSizeMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:SZMeanSizeMax_pop1, noproc
		SetVariable SZMeanSizeMax,pos={290,375},size={80,15},title="Max ", help={"High limit for mean size for Schulz-Zimm distribution"} 

		SetVariable SZWidth,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:SZWidth_pop1,proc=IR2L_PopSetVarProc
		SetVariable SZWidth,pos={8,395},size={140,15},title="Width [A]= ", help={"Schulz-Zimm width size [A]"} 
		CheckBox SZWidthFit,pos={155,395},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox SZWidthFit,variable= root:Packages:IR2L_NLSQF:GWidthFit_pop1, help={"Fit the width for Schulz-Zimm distribution?"}
		SetVariable SZWidthMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:SZWidthMin_pop1, noproc
		SetVariable SZWidthMin,pos={200,395},size={80,15},title="Min ", help={"Low limit for width for Schulz-Zimm distribution"} 
		SetVariable SZWidthMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:SZWidthMax_pop1, noproc
		SetVariable SZWidthMax,pos={290,395},size={80,15},title="Max ", help={"High limit for width for Schulz-Zimm distribution"} 
		//LSW parameters
		SetVariable LSWLocation,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LSWLocation_pop1,proc=IR2L_PopSetVarProc
		SetVariable LSWLocation,pos={8,375},size={140,15},title="Position [A]= ", help={"LSW size [A]"} 
		CheckBox LSWLocationFit,pos={155,375},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox LSWLocationFit,variable= root:Packages:IR2L_NLSQF:LSWLocationFit_pop1, help={"Fit the LSW position?"}
		SetVariable LSWLocationMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LSWLocationMin_pop1, noproc
		SetVariable LSWLocationMin,pos={200,375},size={80,15},title="Min ", help={"Low limit for LSW position"} 
		SetVariable LSWLocationMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LSWLocationMax_pop1, noproc
		SetVariable LSWLocationMax,pos={290,375},size={80,15},title="Max ", help={"High limit for LSW position"} 
		//diffraction controls
		
		PopupMenu DiffPeakProfile title="Peak shape : ",proc=IR2L_PanelPopupControl, pos={10,280}
		PopupMenu DiffPeakProfile value=#"(root:packages:IR2L_NLSQF:ListOfKnownPeakShapes)", mode=1		//whichListItem(root:Packages:IR2L_NLSQF:DiffPeakProfile_pop1, root:Packages:IR2L_NLSQF:ListOfKnownPeakShapes)+1
		//#"(root:Packages:FormFactorCalc:ListOfFormFactors)"
		PopupMenu DiffPeakProfile help={"Select peak profile for this population"}

		SetVariable DiffPeakPar1,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:DiffPeakPar1_pop1,proc=IR2L_PopSetVarProc
		SetVariable DiffPeakPar1,pos={8,330},size={140,15},title="Prefactor = ", help={"Scaling for this peak"} 
		CheckBox DiffPeakPar1Fit,pos={155,330},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox DiffPeakPar1Fit,variable= root:Packages:IR2L_NLSQF:DiffPeakPar1Fit_pop1, help={"Fit the prefactor?"}
		SetVariable DiffPeakPar1Min,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:DiffPeakPar1Min_pop1,noproc
		SetVariable DiffPeakPar1Min,pos={200,330},size={80,15},title="Min ", help={"Low limit for Prefactor"} 
		SetVariable DiffPeakPar1Max,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:DiffPeakPar1Max_pop1,noproc
		SetVariable DiffPeakPar1Max,pos={290,330},size={80,15},title="Max ", help={"High limit for Prefactor"} 
	
		SetVariable DiffPeakPar2,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:DiffPeakPar2_pop1,proc=IR2L_PopSetVarProc
		SetVariable DiffPeakPar2,pos={8,350},size={140,15},title="Position   = ", help={"Q position for this peak"} 
		CheckBox DiffPeakPar2Fit,pos={155,350},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox DiffPeakPar2Fit,variable= root:Packages:IR2L_NLSQF:DiffPeakPar2Fit_pop1, help={"Fit the Q position?"}
		SetVariable DiffPeakPar2Min,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:DiffPeakPar2Min_pop1,noproc
		SetVariable DiffPeakPar2Min,pos={200,350},size={80,15},title="Min ", help={"Low limit for Q position"} 
		SetVariable DiffPeakPar2Max,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:DiffPeakPar2Max_pop1,noproc
		SetVariable DiffPeakPar2Max,pos={290,350},size={80,15},title="Max ", help={"High limit for Q position"} 

		SetVariable DiffPeakPar3,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:DiffPeakPar3_pop1,proc=IR2L_PopSetVarProc
		SetVariable DiffPeakPar3,pos={8,370},size={140,15},title="Width      = ", help={"Q width position for this peak"} 
		CheckBox DiffPeakPar3Fit,pos={155,370},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox DiffPeakPar3Fit,variable= root:Packages:IR2L_NLSQF:DiffPeakPar3Fit_pop1, help={"Fit the Q width position?"}
		SetVariable DiffPeakPar3Min,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:DiffPeakPar3Min_pop1,noproc
		SetVariable DiffPeakPar3Min,pos={200,370},size={80,15},title="Min ", help={"Low limit for Q width position"} 
		SetVariable DiffPeakPar3Max,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:DiffPeakPar3Max_pop1,noproc
		SetVariable DiffPeakPar3Max,pos={290,370},size={80,15},title="Max ", help={"High limit for Q width position"} 

		SetVariable DiffPeakPar4,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:DiffPeakPar4_pop1,proc=IR2L_PopSetVarProc
		SetVariable DiffPeakPar4,pos={8,390},size={140,15},title="Eta(Pseudo-Voigt)= ", help={"Parameter 4 for this peak"} 
		CheckBox DiffPeakPar4Fit,pos={155,390},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox DiffPeakPar4Fit,variable= root:Packages:IR2L_NLSQF:DiffPeakPar4Fit_pop1, help={"Fit the Parameter 4?"}
		SetVariable DiffPeakPar4Min,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:DiffPeakPar4Min_pop1,noproc
		SetVariable DiffPeakPar4Min,pos={200,390},size={80,15},title="Min ", help={"Low limit for Parameter 4"} 
		SetVariable DiffPeakPar4Max,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:DiffPeakPar4Max_pop1,noproc
		SetVariable DiffPeakPar4Max,pos={290,390},size={80,15},title="Max ", help={"High limit for Parameter 4"} 

		SetVariable DiffPeakDPos,limits={0,1,0},variable= root:Packages:IR2L_NLSQF:DiffPeakDPos_pop1, noproc, disable=2, format="%.6g"
		SetVariable DiffPeakDPos,pos={5,410},size={280,16},title="Peak position -spacing [A]:", help={"peak position in D units"} 
		SetVariable DiffPeakQPos,limits={0,1,0},variable= root:Packages:IR2L_NLSQF:DiffPeakQPos_pop1, noproc, disable=2, format="%.4g"
		SetVariable DiffPeakQPos,pos={5,430},size={280,16},title="Peak position - Q   [A^-1]:", help={"peak position in Q units"} 
		SetVariable DiffPeakQFWHM,limits={0,1,0},variable= root:Packages:IR2L_NLSQF:DiffPeakQFWHM_pop1, noproc, disable=2, format="%.4g"
		SetVariable DiffPeakQFWHM,pos={5,450},size={280,16},title="Peak FWHM [A^-1]:", help={"peak FWHM in Q units"} 
		SetVariable DiffPeakIntgInt,limits={0,1,0},variable= root:Packages:IR2L_NLSQF:DiffPeakIntgInt_pop1, noproc, disable=2, format="%.4g"
		SetVariable DiffPeakIntgInt,pos={5,470},size={280,16},title="Peak Integral Intensity:", help={"peak integral inetnsity"} 

		//Mass Fractal
		SetVariable MassFrPhi,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:MassFrPhi_pop1,proc=IR2L_PopSetVarProc
		SetVariable MassFrPhi,pos={8,330},size={140,15},title="Particle Volume = ", help={"Volume of particle (see manual)"} 
		CheckBox MassFrPhiFit,pos={155,330},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox MassFrPhiFit,variable= root:Packages:IR2L_NLSQF:MassFrPhiFit_pop1, help={"Fit the MassFrPhi?"}
		SetVariable MassFrPhiMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:MassFrPhiMin_pop1,noproc
		SetVariable MassFrPhiMin,pos={200,330},size={80,15},title="Min ", help={"Low limit for MassFrPhi"} 
		SetVariable MassFrPhiMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:MassFrPhiMax_pop1,noproc
		SetVariable MassFrPhiMax,pos={290,330},size={80,15},title="Max ", help={"High limit for MassFrPhi"} 
	
		SetVariable MassFrRadius,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:MassFrRadius_pop1,proc=IR2L_PopSetVarProc
		SetVariable MassFrRadius,pos={8,350},size={140,15},title="Radius           = ", help={"Q position for this peak"} 
		CheckBox MassFrRadiusFit,pos={155,350},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox MassFrRadiusFit,variable= root:Packages:IR2L_NLSQF:MassFrRadiusFit_pop1, help={"Fit the Radius position?"}
		SetVariable MassFrRadiusMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:MassFrRadiusMin_pop1,noproc
		SetVariable MassFrRadiusMin,pos={200,350},size={80,15},title="Min ", help={"Low limit for Radius position"} 
		SetVariable MassFrRadiusMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:MassFrRadiusMax_pop1,noproc
		SetVariable MassFrRadiusMax,pos={290,350},size={80,15},title="Max ", help={"High limit for Radius position"} 

		SetVariable MassFrDv,limits={1,2.999,0.1},variable= root:Packages:IR2L_NLSQF:MassFrDv_pop1,proc=IR2L_PopSetVarProc
		SetVariable MassFrDv,pos={8,370},size={140,15},title="Dv (Fract. dim.)  = ", help={"Dv for this fractal"} 
		CheckBox MassFrDvFit,pos={155,370},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox MassFrDvFit,variable= root:Packages:IR2L_NLSQF:MassFrDvFit_pop1, help={"Fit the Dv width position?"}
		SetVariable MassFrDvMin,limits={1,3,0},variable= root:Packages:IR2L_NLSQF:MassFrDvMin_pop1,noproc
		SetVariable MassFrDvMin,pos={200,370},size={80,15},title="Min ", help={"Low limit for Dv width position"} 
		SetVariable MassFrDvMax,limits={1,3,0},variable= root:Packages:IR2L_NLSQF:MassFrDvMax_pop1,noproc
		SetVariable MassFrDvMax,pos={290,370},size={80,15},title="Max ", help={"High limit for Dv width position"} 

		SetVariable MassFrKsi,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:MassFrKsi_pop1,proc=IR2L_PopSetVarProc
		SetVariable MassFrKsi,pos={8,390},size={140,15},title="Correl. length = ", help={"Correlation lenght [A]"} 
		CheckBox MassFrKsiFit,pos={155,390},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox MassFrKsiFit,variable= root:Packages:IR2L_NLSQF:MassFrKsiFit_pop1, help={"Fit the Correlation lenght?"}
		SetVariable MassFrKsiMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:MassFrKsiMin_pop1,noproc
		SetVariable MassFrKsiMin,pos={200,390},size={80,15},title="Min ", help={"Low limit for Correlation lenght"} 
		SetVariable MassFrKsiMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:MassFrKsiMax_pop1,noproc
		SetVariable MassFrKsiMax,pos={290,390},size={80,15},title="Max ", help={"High limit for Correlation lenght"} 

		SetVariable MassFrBeta,limits={0,inf,0},variable= root:Packages:IR2L_NLSQF:MassFrBeta_pop1, proc=IR2L_PopSetVarProc
		SetVariable MassFrBeta,pos={5,410},size={200,16},title="Particle aspect ratio          =    ", help={"Aspect ratio, 1 for sphere"} 
		SetVariable MassFrEta,limits={0,1,0},variable= root:Packages:IR2L_NLSQF:MassFrEta_pop1, proc=IR2L_PopSetVarProc
		SetVariable MassFrEta,pos={5,430},size={200,16},title="Volume filling                   =      ", help={"Volume filling, between 0 and 1"} 
		SetVariable MassFrIntgNumPnts,limits={0,inf,0},variable= root:Packages:IR2L_NLSQF:MassFrIntgNumPnts_pop1, proc=IR2L_PopSetVarProc
		SetVariable MassFrIntgNumPnts,pos={5,450},size={200,16},title="Intg. Num. pnts.               =       ", help={"Internal integration pnts, typically 500"} 
			


		//Surface Fractal
		SetVariable SurfFrSurf,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:SurfFrSurf_pop1,proc=IR2L_PopSetVarProc
		SetVariable SurfFrSurf,pos={8,330},size={140,15},title="Smooth surface = ", help={"Smooth surface (see manual)"} 
		CheckBox SurfFrSurfFit,pos={155,330},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox SurfFrSurfFit,variable= root:Packages:IR2L_NLSQF:SurfFrSurfFit_pop1, help={"Fit the SurfFrSurf?"}
		SetVariable SurfFrSurfMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:SurfFrSurfMin_pop1,noproc
		SetVariable SurfFrSurfMin,pos={200,330},size={80,15},title="Min ", help={"Low limit for SurfFrSurf"} 
		SetVariable SurfFrSurfMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:SurfFrSurfMax_pop1,noproc
		SetVariable SurfFrSurfMax,pos={290,330},size={80,15},title="Max ", help={"High limit for SurfFrSurf"} 
	
		SetVariable SurfFrDS,limits={2.001,2.999,0.1},variable= root:Packages:IR2L_NLSQF:SurfFrDS_pop1,proc=IR2L_PopSetVarProc
		SetVariable SurfFrDS,pos={8,350},size={140,15},title="Fractal dim.     = ", help={"Fractal dimension, between 2 and 3"} 
		CheckBox SurfFrDSFit,pos={155,350},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox SurfFrDSFit,variable= root:Packages:IR2L_NLSQF:SurfFrDSFit_pop1, help={"Fit the Fract dim.?"}
		SetVariable SurfFrDSMin,limits={1.999,3,0},variable= root:Packages:IR2L_NLSQF:SurfFrDSMin_pop1,noproc
		SetVariable SurfFrDSMin,pos={200,350},size={80,15},title="Min ", help={"Low limit for Fract. dim.  position"} 
		SetVariable SurfFrDSMax,limits={1.999,3,0},variable= root:Packages:IR2L_NLSQF:SurfFrDSMax_pop1,noproc
		SetVariable SurfFrDSMax,pos={290,350},size={80,15},title="Max ", help={"High limit for Fract. dim. position"} 

		SetVariable SurfFrKsi,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:SurfFrKsi_pop1,proc=IR2L_PopSetVarProc
		SetVariable SurfFrKsi,pos={8,370},size={140,15},title="Corr. Length  = ", help={"Corr. Length for this fractal"} 
		CheckBox SurfFrKsiFit,pos={155,370},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox SurfFrKsiFit,variable= root:Packages:IR2L_NLSQF:SurfFrKsiFit_pop1, help={"Fit the Corr. Length width position?"}
		SetVariable SurfFrKsiMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:SurfFrKsiMin_pop1,noproc
		SetVariable SurfFrKsiMin,pos={200,370},size={80,15},title="Min ", help={"Low limit for Corr. Length width position"} 
		SetVariable SurfFrKsiMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:SurfFrKsiMax_pop1,noproc
		SetVariable SurfFrKsiMax,pos={290,370},size={80,15},title="Max ", help={"High limit for Corr. Length width position"} 

		SetVariable SurfFrQc,limits={0,1,0},variable= root:Packages:IR2L_NLSQF:SurfFrQc_pop1, proc=IR2L_PopSetVarProc
		SetVariable SurfFrQc,pos={5,410},size={200,16},title="Qc (terminal Q)      =    ", help={"Q when converts to Porod scatterer."} 
		NVAR SurfFrQcWidth_pop1 = root:Packages:IR2L_NLSQF:SurfFrQcWidth_pop1
		PopupMenu SurfFrQcWidth,pos={5,435},size={250,16},title="Qc width [% of Qc] ", help={"Transition width at Q max when scattering changes to Porod's law"}
		PopupMenu SurfFrQcWidth,proc=IR2L_PanelPopupControl,value="5;10;15;20;25;", mode=1+whichListItem(num2str(100*SurfFrQcWidth_pop1), "5;10;15;20;25;")
			





		
		//interferences
//		CheckBox UseInterference,pos={40,435},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Use Structure factor?"
//		CheckBox UseInterference,variable= root:Packages:IR2L_NLSQF:UseInterference_pop1, help={"Check to use structure factor"}
		PopupMenu StructureFactorModel title="Structure Factor : ",proc=IR2L_PanelPopupControl, pos={10,468}
		PopupMenu StructureFactorModel value=#"(root:Packages:StructureFactorCalc:ListOfStructureFactors)"
		SVAR StrA=root:Packages:IR2L_NLSQF:StructureFactor_pop1
		SVAR StrB=root:Packages:StructureFactorCalc:ListOfStructureFactors
		PopupMenu StructureFactorModel mode=WhichListItem(StrA,StrB )+1
		PopupMenu StructureFactorModel help={"Select Dilute system or Structure factor to be used for this population of scatterers"}

		SetVariable Contrast,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast,pos={8,495},size={150,15},title="Contrast [*10^20] = ", help={"Contrast [*10^20]  of this population"} 
		SetVariable Contrast_set1,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set1_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set1,pos={8,490},size={150,15},title="Contrast data 1 = ", help={"Contrast [*10^20]  of this population for data set 1"} 
		SetVariable Contrast_set2,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set2_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set2,pos={8,510},size={150,15},title="Contrast data 2 = ", help={"Contrast [*10^20]  of this population for data set 2"} 
		SetVariable Contrast_set3,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set3_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set3,pos={8,530},size={150,15},title="Contrast data 3 = ", help={"Contrast [*10^20]  of this population for data set 3"} 
		SetVariable Contrast_set4,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set4_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set4,pos={8,550},size={150,15},title="Contrast data 4 = ", help={"Contrast [*10^20]  of this population for data set 4"} 
		SetVariable Contrast_set5,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set5_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set5,pos={8,570},size={150,15},title="Contrast data 5 = ", help={"Contrast [*10^20]  of this population for data set 5"} 

		SetVariable Contrast_set6,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set6_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set6,pos={178,490},size={150,15},title="Contrast data 6 = ", help={"Contrastv of this population for data set 1"} 
		SetVariable Contrast_set7,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set7_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set7,pos={178,510},size={150,15},title="Contrast data 7 = ", help={"Contrast [*10^20]  of this population for data set 2"} 
		SetVariable Contrast_set8,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set8_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set8,pos={178,530},size={150,15},title="Contrast data 8 = ", help={"Contrast [*10^20]  of this population for data set 3"} 
		SetVariable Contrast_set9,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set9_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set9,pos={178,550},size={150,15},title="Contrast data 9 = ", help={"Contrast [*10^20]  of this population for data set 4"} 
		SetVariable Contrast_set10,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set10_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set10,pos={178,570},size={150,15},title="Contrast set 10 = ", help={"Contrast [*10^20]  of this population for data set 5"} 

		//few more buttons
		CheckBox UseGeneticOptimization,pos={5,610},size={25,90},proc=IR2L_DataTabCheckboxProc,title="Genetic Optimiz.?"
		CheckBox UseGeneticOptimization,variable= root:Packages:IR2L_NLSQF:UseGeneticOptimization, help={"Use genetic Optimization? SLOW..."}
		CheckBox UseLSQF,pos={120,610},size={25,90},proc=IR2L_DataTabCheckboxProc,title="Use LSQF?"
		CheckBox UseLSQF,variable= root:Packages:IR2L_NLSQF:UseLSQF, help={"Use LSQF?"}


		Button Recalculate, pos={10,630},size={90,20}, proc=IR2L_InputPanelButtonProc,title="Calculate Model", help={"Recalculate model"}
		Button AnalyzeUncertainities, pos={10,655},size={90,20}, proc=IR2L_InputPanelButtonProc,title="Anal. Uncertainity", help={"Run procedures to analyze uncertaitnities for parameters"}
		Button FitModel, pos={110,630},size={90,20}, proc=IR2L_InputPanelButtonProc,title="Fit Model", help={"Fit the model"}
		Button ReverseFit, pos={110,655},size={90,20}, proc=IR2L_InputPanelButtonProc,title="Reverese Fit", help={"Reverse fit"}

		Button FixLimitsTight, pos={200,605},size={45,20}, proc=IR2L_InputPanelButtonProc,title="Fix L1", help={"Reset fitting limits acording to built in rules"}
		Button FixLimitsLoose, pos={255,605},size={45,20}, proc=IR2L_InputPanelButtonProc,title="Fix L3", help={"Reset fitting limits acording to built in rules"}
		Button PasteTagsToGraph, pos={210,630},size={90,20}, proc=IR2L_InputPanelButtonProc,title="Tags to graph", help={"Add tags to graph"}
		Button RemoveTagsFromGraph, pos={210,655},size={90,20}, proc=IR2L_InputPanelButtonProc,title="Remove Tags", help={"Remove tags from graph"}

		Button SaveInDataFolder, pos={310,605},size={90,20}, proc=IR2L_InputPanelButtonProc,title="Store in Folder", help={"Copy result in the data folder"}
		Button SaveInNotebook, pos={310,630},size={90,20}, proc=IR2L_InputPanelButtonProc,title="Store in Notebook", help={"Store result in output notebook"}	
		Button SaveInWaves, pos={310,655},size={90,20}, proc=IR2L_InputPanelButtonProc,title="Store in Waves", help={"Store result in the separate folder in waves"}



	IR2L_Model_TabPanelControl("",0)
	IR2L_DataTabCheckboxProc("MultipleInputData",MultipleInputData)		//carefull this will make graph to be top window!!!
	IR2L_SetTabsNames()
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function LSQF2_ModelingII_MoreDetailsF() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(188,240,613,383) as "Modeling II more parameters"
	DoWindow/C LSQF2_ModelingII_MoreDetails
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 3,textrgb= (0,0,65535)
	DrawText 108,24,"Set Size distribution parameters"
	CheckBox DimensionIsDiameter,pos={13,35},size={203,14},proc=IR2L_DataTabCheckboxProc,title="Size dist. use Diameters? (default is radia)"
	CheckBox DimensionIsDiameter,help={"Check if Size Distribution dimension is diameter?"}
	CheckBox DimensionIsDiameter,variable= root:Packages:IR2L_NLSQF:SizeDist_DimensionIsDiameter
	CheckBox UseNumberDistributions,pos={13,60},size={278,14},proc=IR2L_DataTabCheckboxProc,title="Size Dist. use Number distribution? (default is volume dist.)"
	CheckBox UseNumberDistributions,help={"Use number distributions? Default is volume distributions."}
	CheckBox UseNumberDistributions,variable= root:Packages:IR2L_NLSQF:UseNumberDistributions
	SVAR DataCalibrationUnits=root:Packages:IR2L_NLSQF:DataCalibrationUnits
	variable modeVal = 1 + WhichListItem(DataCalibrationUnits, "Arbitrary;cm2/cm3;cm2/g;")
	if(modeVal<1||modeVal>3)
		modeVal=1
	endif
	PopupMenu DataUnits title="Units : ",proc=IR2L_PanelPopupControl, pos={13,90}
	PopupMenu DataUnits mode=modeVal, value="Arbitrary;cm2/cm3;cm2/g;"
	PopupMenu DataUnits help={"Units for data"}

	Button Continue_SDDetails,pos={220,109},size={114,24},proc=IR2L_InputPanelButtonProc,title="Continue"
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
