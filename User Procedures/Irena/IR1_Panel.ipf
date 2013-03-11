#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.03

//*************************************************************************\
//* Copyright (c) 2005 - 2013, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.01 added license for ANL
//2.02 added change to avoid using CoreShellShell in this package since it is really unsupported. 
//2.03 removed all font and font size from panel definitions to enable user control


//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from www.uni.aps.anl.gov/~ilavsky
//this package contains 
// Igor functions for modeling of SAS from various distributions of scatterers...

//Jan Ilavsky, January 2002

//please, read Readme in the distribution zip file with more details on the program
//report any problems to: ilavsky@aps.anl.gov 


//this file contains fiels related to the panel used to control all parameters.




Window IR1S_ControlPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,20,380,680) as "Standard models and LSQ fitting"

	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("SAS_Modeling","IR1S_ControlPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1)

	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman", save
	SetDrawEnv fname= "Times New Roman",fsize= 22,fstyle= 3,textrgb= (0,0,52224)
	DrawText 57,28,"SAS modeling input panel"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,181,339,181
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 8,49,"Data input"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 17,209,"Modeling input"
	SetDrawEnv fstyle= 1
	DrawText 89,471,"Limits for fitting"
	SetDrawEnv fsize= 12
	//DrawText 10,605,"Fit using least square fitting ?"
	DrawLine 24,455,344,455
	DrawLine 225,390,225,456
	DrawLine 229,390,229,456
	DrawPoly 113,225,1,1,{113,225,113,225}
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,626,339,626
	SetDrawEnv textrgb= (0,0,65280),fstyle= 1
	DrawText 16,655,"Results:"

	//Experimental data input
	CheckBox UseSlitSmearedData,pos={10,160},size={90,14},proc=IR1S_InputPanelCheckboxProc,title="Slit smeared? "
	CheckBox UseSlitSmearedData,variable= root:Packages:SAS_Modeling:UseSlitSmearedData, help={"Input data are slit smeared? Model will be smeared to follow."}
	SetVariable SlitLength,pos={100,160},size={140,16},proc=IR1S_PanelSetVarProc,title="Slit length", help={"Slit length for slit smeared data"}
	SetVariable SlitLength,limits={0,Inf,0.01},variable= root:Packages:SAS_Modeling:SlitLength, disable=!(root:Packages:SAS_Modeling:UseSlitSmearedData)

	Button DrawGraphs,pos={260,158},size={80,20}, proc=IR1S_InputPanelButtonProc,title="Graph", help={"Click to generate data graphs, necessary step for further evaluation"}

	//Modeling input, common for all distributions
	PopupMenu NumberOfDistributions,pos={169,185},size={170,21},proc=IR1S_PanelPopupControl,title="Number of distributions :"
	PopupMenu NumberOfDistributions,mode=2,popvalue="0",value= #"\"0;1;2;3;4;5;\"", help={"Select number of different distributions you want to model, can be modified anytime"}
	CheckBox NumOrVolDist,mode=1,pos={95,210},size={223,14},proc=IR1S_InputPanelCheckboxProc,title="Use Number (N(d)) dist? "
	CheckBox NumOrVolDist,variable= root:Packages:SAS_Modeling:UseNumberDistribution, help={"Will the parameters apply to Number distribution?"}
	CheckBox VolOrNumDist,mode=1,pos={230,210},size={223,14},proc=IR1S_InputPanelCheckboxProc,title="Use Volume (V(d)) dist? "
	CheckBox VolOrNumDist,variable= root:Packages:SAS_Modeling:UseVolumeDistribution, help={"Will the parameters apply to volume distribution?"}
	CheckBox DisplayND,pos={122,225},size={223,14},proc=IR1S_InputPanelCheckboxProc,title="Display N(d)? "
	CheckBox DisplayND,value= root:Packages:SAS_Modeling:DisplayND, help={"Display number distribution in the distribution graph"}
	CheckBox DisplayVD,pos={230,225},size={223,14},proc=IR1S_InputPanelCheckboxProc,title="Display V(d)? "
	CheckBox DisplayVD,value= root:Packages:SAS_Modeling:DisplayVD, help={"Display volume distribution in the distribution graph"}
	Button GraphDistribution,pos={32,217},size={50,20}, proc=IR1S_InputPanelButtonProc,title="Graph", help={"Graph manually. Used if UpdateAutomatically is not selected."}
	CheckBox UpdateAutomatically,pos={44,241},size={225,14},proc=IR1S_InputPanelCheckboxProc,title="Update graphs automatically?"
	CheckBox UpdateAutomatically,variable= root:Packages:SAS_Modeling:UpdateAutomatically, help={"Graph automatically anytime distribution parameters are changed. May be slow..."}
	CheckBox UseInterference,pos={244,241},size={225,14},proc=IR1S_InputPanelCheckboxProc,title="Interference?"
	CheckBox UseInterference,variable= root:Packages:SAS_Modeling:UseInterference, help={"Use interference. This is crude approximation and should be used only when interference is clearly visible"}

	Button DoFitting,pos={180,598},size={70,20}, proc=IR1S_InputPanelButtonProc,title="Fit", help={"Click to start least square fitting. Make sure the fitting coefficients are well guessed and limited."}
	Button RevertFitting,pos={265,598},size={100,20}, proc=IR1S_InputPanelButtonProc,title="Revert fit", help={"Return values before last fit attempmt. Use to recover from unsuccesfull fit."}
	Button CopyToFolder,pos={90,635},size={110,20}, proc=IR1S_InputPanelButtonProc,title="Store in Data Folder", help={"Copy results back to data folder for future use."}
	Button ExportData,pos={210,635},size={90,20}, proc=IR1S_InputPanelButtonProc,title="Export ASCII", help={"Export ASCII data out from Igor."}
	SetVariable SASBackground,pos={13,569},size={150,16},proc=IR1S_PanelSetVarProc,title="SAS Background", help={"Background of SAS"}
	SetVariable SASBackground,limits={-inf,Inf,root:Packages:SAS_Modeling:SASBackgroundStep},value= root:Packages:SAS_Modeling:SASBackground
	SetVariable SASBackgroundStep,pos={173,569},size={80,16},title="step",proc=IR1S_PanelSetVarProc, help={"Step for SAS background. Used to set appropriate steps for clicking background up and down."}
	SetVariable SASBackgroundStep,limits={0,Inf,0},value= root:Packages:SAS_Modeling:SASBackgroundStep
	CheckBox FitBackground,pos={273,566},size={63,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Bckg?"
	CheckBox FitBackground,variable= root:Packages:SAS_Modeling:FitSASBackground, help={"Fit the background during least square fitting?"}

	CheckBox UseGenOpt,pos={4,589},size={25,90},proc=IR1S_InputPanelCheckboxProc,title="Use Genetic Optimization?"
	CheckBox UseGenOpt,variable= root:Packages:SAS_Modeling:UseGenOpt, help={"Use genetic Optimization? SLOW..."}
	CheckBox UseLSQF,pos={4,605},size={25,90},proc=IR1S_InputPanelCheckboxProc,title="Use LSQF?"
	CheckBox UseLSQF,variable= root:Packages:SAS_Modeling:UseLSQF, help={"Use LSQF?"}

	//Dist Tabs definition
	TabControl DistTabs,pos={1,260},size={368,300},proc=IR1S_TabPanelControl
	TabControl DistTabs,fSize=10,tabLabel(0)="1. Dist",tabLabel(1)="2. Dist"
	TabControl DistTabs,tabLabel(2)="3. Dist",tabLabel(3)="4. Dist"
	TabControl DistTabs,tabLabel(4)="5. Dist",value= 0
	
	//Distribution 1 controls
	PopupMenu Dis1_ShapePopup,pos={6,286},size={158,21},proc=IR1S_PanelPopupControl,title="Shape", help={"Select shape for scatterers in this distribution."}
//	PopupMenu Dis1_ShapePopup,mode=1,popvalue="sphere",value= #"\"sphere;spheroid;cylinder;CoreShellCylinder;coreshell;other not coded yet\""
	PopupMenu Dis1_ShapePopup,mode=1,popvalue=root:Packages:SAS_Modeling:Dist1ShapeModel,value= root:Packages:FormFactorCalc:ListOfFormFactors
//	PopupMenu Dis1_ShapePopup,mode=1,popvalue="sphere",value= #"\"sphere;spheroid;cylinder;CoreShellCylinder;coreshell;Fractal Aggregate;other not coded yet\""
	PopupMenu Dis1_DistributionType,pos={6,315},size={149,21},proc=IR1S_PanelPopupControl,title="Dist type :", help={"Select distribution type which will be modeled."}
	PopupMenu Dis1_DistributionType,mode=1,popvalue="LogNormal",value= #"\"LogNormal;Gauss;LSW;PowerLaw;\""
	SetVariable Dis1_Contrast,pos={174,280},size={180,16},proc=IR1S_PanelSetVarProc,title="Contrast   [*10^20 cm-4] "
	SetVariable Dis1_Contrast,limits={0,50000,1},value= root:Packages:SAS_Modeling:Dist1Contrast, help={"Input contrast for the scatterers in this distribution"}
	SetVariable Dis1_Volume,pos={174,300},size={180,16},proc=IR1S_PanelSetVarProc,title="Scaterer volume [fract]:   "
	SetVariable Dis1_Volume,limits={0,inf,0.03},variable= root:Packages:SAS_Modeling:Dist1VolFraction, help={"Input volume of scatterers in this distribution"}
	SetVariable Dis1_NegligibleFraction,pos={173,320},size={180,16},title="Neglect tail dist fractions"
	SetVariable Dis1_NegligibleFraction,limits={1e-05,0.1,0.001},variable= root:Packages:SAS_Modeling:Dist1NegligibleFraction, help={"Input fraction of distribution, which is considered neggligible. default 0.01 (1%). Lower number means wider range of diameters."}
	SetVariable Dis1_NumberOfPointsInDis,pos={173,340},size={180,16},title="Number of bins in distribution"
	SetVariable Dis1_NumberOfPointsInDis,limits={10,1000,1},variable= root:Packages:SAS_Modeling:Dist1NumberOfPoints, help={"Input number of bins in the distribution to be modelled. Large numbers may be slow. Default 40"}

	SetVariable Dis1_Location,pos={27,395},size={120,16},proc=IR1S_PanelSetVarProc,title="Location  ", help={"One of the distribution parameters called location. Check formula for it's meaning."}
	SetVariable Dis1_Location,limits={0,inf,root:Packages:SAS_Modeling:Dist1LocStep}, variable= root:Packages:SAS_Modeling:Dist1Location
	SetVariable Dis1_LocationStep,pos={157,395},size={60,16},proc=IR1S_PanelSetVarProc,title="step", help={"Step with which the location can be changed. Set to convenient number."}
	SetVariable Dis1_LocationStep,limits={0,1000,0},variable= root:Packages:SAS_Modeling:Dist1LocStep

	SetVariable Dis1_scale,pos={27,415},size={120,16},proc=IR1S_PanelSetVarProc,title="Scale       ", help={"One of the distribution parameters, this one called Scale. Check formula for it's meaning."}
	SetVariable Dis1_scale,limits={-inf,inf,root:Packages:SAS_Modeling:Dist1ScaleStep},variable= root:Packages:SAS_Modeling:Dist1Scale
	SetVariable Dis1_ScaleStep,pos={157,415},size={60,16},proc=IR1S_PanelSetVarProc,title="step", help={"Step with which the Scale can be changed. Set to convenient number."}
	SetVariable Dis1_ScaleStep,limits={0,1000,0},variable= root:Packages:SAS_Modeling:Dist1ScaleStep

	SetVariable Dis1_shape,pos={26,435},size={120,16},proc=IR1S_PanelSetVarProc,title="Shape      ", help={"One of the distribution parameters, this one called Shape, Check formula for it's meaning. "}
	SetVariable Dis1_shape,limits={-inf,inf,root:Packages:SAS_Modeling:Dist1ShapeStep},variable= root:Packages:SAS_Modeling:Dist1Shape
	SetVariable Dis1_ShapeStep,pos={157,435},size={60,16},proc=IR1S_PanelSetVarProc,title="step", help={"Step with which the Shape can be changed. Set to convenient number."}
	SetVariable Dis1_ShapeStep,limits={0,1000,0},variable= root:Packages:SAS_Modeling:Dist1ShapeStep

	SetVariable DIS1_Mode,pos={234,387},size={120,16},title="Dist. mode    = ", help={"Mode of this distribution. Calculated numerically."}
	SetVariable DIS1_Mode,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist1Mode, format="%.1f"
	SetVariable DIS1_Median,pos={234,404},size={120,16},title="Dist. median = ", help={"Median of this distribution. Calculated numerically."}
	SetVariable DIS1_Median,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist1Median, format="%.1f"
	SetVariable DIS1_Mean,pos={234,421},size={120,16},title="Dist. mean    = ", help={"Mean of this distribution. Calculated numerically."}
	SetVariable DIS1_Mean,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist1Mean, format="%.1f"
	SetVariable DIS1_FWHM,pos={234,438},size={120,16},title="Dist. FWHM = ", help={"Full width at half maximum of this distribution. Calculated numerically."}
	SetVariable DIS1_FWHM,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist1FWHM, format="%.1f"

	TitleBox Dis1_Gauss,pos={5,365},size={256,21},disable=1
	TitleBox Dis1_Gauss,variable= root:Packages:SAS_Modeling:GaussEquation
	TitleBox Dis1_LogNormal,pos={5,365},size={336,21}
	TitleBox Dis1_LogNormal,variable= root:Packages:SAS_Modeling:LogNormalEquation
	TitleBox Dis1_LSW,pos={5,365},size={311,21},disable=1
	TitleBox Dis1_LSW,variable= root:Packages:SAS_Modeling:LSWEquation
	TitleBox Dis1_PowerLaw,pos={5,365},size={311,21},disable=1
	TitleBox Dis1_PowerLaw,variable= root:Packages:SAS_Modeling:PowerLawEquation
	
	//Distribution 1 fitting limits
	SetVariable Dis1_LocationLow,pos={32,493},size={50,16},title=" ", help={"Low fitting limit for the location."}
	SetVariable Dis1_LocationLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist1LocLowLimit
	SetVariable Dis1_LocationHigh,pos={97,493},size={130,16},title="  < location <     ", help={"High fitting limit for the location"}
	SetVariable Dis1_LocationHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist1LocHighLimit
	SetVariable Dis1_ScaleLow,pos={32,515},size={50,16},title=" ", help={"Low fitting limit for the Scale"}
	SetVariable Dis1_ScaleLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist1ScaleLowLimit
	SetVariable Dis1_ScaleHigh,pos={97,516},size={130,16},title="  < scale <          ", help={"High fitting limit for scale"}
	SetVariable Dis1_ScaleHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist1ScaleHighLimit
	SetVariable Dis1_ShapeLow,pos={32,537},size={50,16},title=" ", help={"Low fitting limit for Shape"}
	SetVariable Dis1_ShapeLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist1ShapeLowLimit
	SetVariable Dis1_ShapeHigh,pos={98,537},size={130,16},title=" < shape <         ", help={"High fitting limit for shape"}
	SetVariable Dis1_ShapeHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist1ShapeHighLimit
	CheckBox Dis1_FitVolume,pos={250,475},size={73,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Volume?"
	CheckBox Dis1_FitVolume,variable= root:Packages:SAS_Modeling:Dist1FitVol, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	CheckBox Dis1_FitLocation,pos={250,495},size={79,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Location?"
	CheckBox Dis1_FitLocation,variable= root:Packages:SAS_Modeling:Dist1FitLocation, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	CheckBox Dis1_FitScale,pos={250,515},size={65,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Scale?"
	CheckBox Dis1_FitScale,variable= root:Packages:SAS_Modeling:Dist1FitScale, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	CheckBox Dis1_FitShape,pos={250,535},size={69,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Shape?"
	CheckBox Dis1_FitShape,variable= root:Packages:SAS_Modeling:Dist1FitShape, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	SetVariable Dis1_VolumeLow,pos={32,471},size={50,16},title=" ", help={"Low fitting limit for volume"}
	SetVariable Dis1_VolumeLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist1VolLowLimit
	SetVariable Dis1_VolumeHigh,pos={99,473},size={130,16},title="  < volume <     ", help={"High fitting limit for volume"}
	SetVariable Dis1_VolumeHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist1VolHighLimit
	//end of Distribution 1 controls....


	//Distribution 2 controls
	PopupMenu Dis2_ShapePopup,pos={6,286},size={158,21},proc=IR1S_PanelPopupControl,title="Shape", help={"Select shape for scatterers in this distribution."}
//	PopupMenu Dis2_ShapePopup,mode=1,popvalue="sphere",value= #"\"sphere;spheroid;cylinder;tube;coreshell;Fractal Aggregate;other not coded yet\""
	PopupMenu Dis2_ShapePopup,mode=1,popvalue=root:Packages:SAS_Modeling:Dist2ShapeModel,value= root:Packages:FormFactorCalc:ListOfFormFactors
//	PopupMenu Dis2_ShapePopup,mode=1,popvalue="sphere",value= #"\"sphere;spheroid;coreshell;other not coded yet\""
	PopupMenu Dis2_DistributionType,pos={6,315},size={149,21},proc=IR1S_PanelPopupControl,title="Dist type :", help={"Select distribution type which will be modelled"}
	PopupMenu Dis2_DistributionType,mode=1,popvalue="LogNormal",value= #"\"LogNormal;Gauss;LSW;PowerLaw;\""
	SetVariable Dis2_Contrast,pos={174,280},size={180,16},proc=IR1S_PanelSetVarProc,title="Contrast   [*10^20 cm-4] "
	SetVariable Dis2_Contrast,limits={0,50000,1},variable= root:Packages:SAS_Modeling:Dist2Contrast, help={"Input contrast for the scatterers in this distribution"}
	SetVariable Dis2_Volume,pos={174,300},size={180,16},proc=IR1S_PanelSetVarProc,title="Scaterer volume [fract]:   "
	SetVariable Dis2_Volume,limits={0,inf,0.03},variable= root:Packages:SAS_Modeling:Dist2VolFraction, help={"Input volume of scatterers in this distribution"}
	SetVariable Dis2_NegligibleFraction,pos={173,320},size={180,16},title="Neglect tail dist fractions"
	SetVariable Dis2_NegligibleFraction,limits={1e-05,0.1,0.001},variable= root:Packages:SAS_Modeling:Dist2NegligibleFraction, help={"Input fraction of distribution, which is considered neggligible. default 0.01 (1%). Lower number means wider range of diameters."}
	SetVariable Dis2_NumberOfPointsInDis,pos={173,340},size={180,16},title="Number of bins in distribution"
	SetVariable Dis2_NumberOfPointsInDis,limits={10,1000,1},variable= root:Packages:SAS_Modeling:Dist2NumberOfPoints, help={"Input number of bins in the distribution to be modelled. Large numbers may be slow. Default 40"}

	SetVariable Dis2_Location,pos={27,395},size={120,16},proc=IR1S_PanelSetVarProc,title="Location  ", help={"One of the distribution parameters called location. Check formula for it's meaning."}
	SetVariable Dis2_Location,limits={0,inf,root:Packages:SAS_Modeling:Dist2LocStep}, variable= root:Packages:SAS_Modeling:Dist2Location
	SetVariable Dis2_LocationStep,pos={157,395},size={60,16},proc=IR1S_PanelSetVarProc,title="step", help={"Step with which the location can be changed. Set to convenient number."}
	SetVariable Dis2_LocationStep,limits={0,1000,0},variable= root:Packages:SAS_Modeling:Dist2LocStep

	SetVariable Dis2_scale,pos={27,415},size={120,16},proc=IR1S_PanelSetVarProc,title="Scale       ", help={"One of the distribution parameters, this one called Scale. Check formula for it's meaning."}
	SetVariable Dis2_scale,limits={-inf,inf,root:Packages:SAS_Modeling:Dist2ScaleStep},variable= root:Packages:SAS_Modeling:Dist2Scale
	SetVariable Dis2_ScaleStep,pos={157,415},size={60,16},proc=IR1S_PanelSetVarProc,title="step", help={"Step with which the Scale can be changed. Set to convenient number."}
	SetVariable Dis2_ScaleStep,limits={0,1000,0},variable= root:Packages:SAS_Modeling:Dist2ScaleStep

	SetVariable Dis2_shape,pos={26,435},size={120,16},proc=IR1S_PanelSetVarProc,title="Shape      ", help={"One of the distribution parameters, this one called Shape, Check formula for it's meaning. "}
	SetVariable Dis2_shape,limits={-inf,inf,root:Packages:SAS_Modeling:Dist2ShapeStep},variable= root:Packages:SAS_Modeling:Dist2Shape
	SetVariable Dis2_ShapeStep,pos={157,435},size={60,16},proc=IR1S_PanelSetVarProc,title="step", help={"Step with which the Shape can be changed. Set to convenient number."}
	SetVariable Dis2_ShapeStep,limits={0,1000,0},variable= root:Packages:SAS_Modeling:Dist2ShapeStep

	SetVariable Dis2_Mode,pos={234,387},size={120,16},title="Dist. mode    = ", help={"Mode of this distribution. Calculated numerically."}
	SetVariable Dis2_Mode,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist2Mode, format="%.1f"
	SetVariable Dis2_Median,pos={234,404},size={120,16},title="Dist. median = ", help={"Median of this distribution. Calculated numerically."}
	SetVariable Dis2_Median,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist2Median, format="%.1f"
	SetVariable Dis2_Mean,pos={234,421},size={120,16},title="Dist. mean    = ", help={"Mean of this distribution. Calculated numerically."}
	SetVariable Dis2_Mean,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist2Mean, format="%.1f"
	SetVariable Dis2_FWHM,pos={234,438},size={120,16},title="Dist. FWHM = ", help={"Full width at half maximum of this distribution. Calculated numerically."}
	SetVariable Dis2_FWHM,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist2FWHM, format="%.1f"

	TitleBox Dis2_Gauss,pos={5,365},size={256,21},disable=1
	TitleBox Dis2_Gauss,variable= root:Packages:SAS_Modeling:GaussEquation
	TitleBox Dis2_LogNormal,pos={5,365},size={336,21}
	TitleBox Dis2_LogNormal,variable= root:Packages:SAS_Modeling:LogNormalEquation
	TitleBox Dis2_LSW,pos={5,365},size={311,21},disable=1
	TitleBox Dis2_LSW,variable= root:Packages:SAS_Modeling:LSWEquation
	TitleBox Dis2_PowerLaw,pos={5,365},size={311,21},disable=1
	TitleBox Dis2_PowerLaw,variable= root:Packages:SAS_Modeling:PowerLawEquation
	
	//Distribution 2 fitting limits
	SetVariable Dis2_LocationLow,pos={32,493},size={50,16},title=" ", help={"Low fitting limit for the location."}
	SetVariable Dis2_LocationLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist2LocLowLimit
	SetVariable Dis2_LocationHigh,pos={97,493},size={130,16},title="  < location <     ", help={"High fitting limit for the location"}
	SetVariable Dis2_LocationHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist2LocHighLimit
	SetVariable Dis2_ScaleLow,pos={32,515},size={50,16},title=" ", help={"Low fitting limit for the Scale"}
	SetVariable Dis2_ScaleLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist2ScaleLowLimit
	SetVariable Dis2_ScaleHigh,pos={97,516},size={130,16},title="  < scale <          ", help={"High fitting limit for scale"}
	SetVariable Dis2_ScaleHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist2ScaleHighLimit
	SetVariable Dis2_ShapeLow,pos={32,537},size={50,16},title=" ", help={"Low fitting limit for Shape"}
	SetVariable Dis2_ShapeLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist2ShapeLowLimit
	SetVariable Dis2_ShapeHigh,pos={98,537},size={130,16},title=" < shape <         ", help={"High fitting limit for shape"}
	SetVariable Dis2_ShapeHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist2ShapeHighLimit
	CheckBox Dis2_FitVolume,pos={250,475},size={73,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Volume?"
	CheckBox Dis2_FitVolume,variable= root:Packages:SAS_Modeling:Dist2FitVol, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	CheckBox Dis2_FitLocation,pos={250,495},size={79,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Location?"
	CheckBox Dis2_FitLocation,variable= root:Packages:SAS_Modeling:Dist2FitLocation, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	CheckBox Dis2_FitScale,pos={250,515},size={65,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Scale?"
	CheckBox Dis2_FitScale,variable= root:Packages:SAS_Modeling:Dist2FitScale, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	CheckBox Dis2_FitShape,pos={250,535},size={69,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Shape?"
	CheckBox Dis2_FitShape,variable= root:Packages:SAS_Modeling:Dist2FitShape, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	SetVariable Dis2_VolumeLow,pos={32,471},size={50,16},title=" ", help={"Low fitting limit for volume"}
	SetVariable Dis2_VolumeLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist2VolLowLimit
	SetVariable Dis2_VolumeHigh,pos={99,473},size={130,16},title="  < volume <     ", help={"High fitting limit for volume"}
	SetVariable Dis2_VolumeHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist2VolHighLimit
	//end of Distribution 2 controls....
	
	
	//Distribution 3 controls
	PopupMenu Dis3_ShapePopup,pos={6,286},size={158,21},proc=IR1S_PanelPopupControl,title="Shape", help={"Select shape for scatterers in this distribution."}
//	PopupMenu Dis3_ShapePopup,mode=1,popvalue="sphere",value= #"\"sphere;spheroid;cylinder;tube;coreshell;Fractal Aggregate;other not coded yet\""
	PopupMenu Dis3_ShapePopup,mode=1,popvalue=root:Packages:SAS_Modeling:Dist3ShapeModel,value= root:Packages:FormFactorCalc:ListOfFormFactors
//	PopupMenu Dis3_ShapePopup,mode=1,popvalue="sphere",value= #"\"sphere;spheroid;coreshell;other not coded yet\""
	PopupMenu Dis3_DistributionType,pos={6,315},size={149,21},proc=IR1S_PanelPopupControl,title="Dist type :", help={"Select distribution type which will be modelled"}
	PopupMenu Dis3_DistributionType,mode=1,popvalue="LogNormal",value= #"\"LogNormal;Gauss;LSW;PowerLaw;\""
	SetVariable Dis3_Contrast,pos={174,280},size={180,16},proc=IR1S_PanelSetVarProc,title="Contrast   [*10^20 cm-4] "
	SetVariable Dis3_Contrast,limits={0,50000,1},variable= root:Packages:SAS_Modeling:Dist3Contrast, help={"Input contrast for the scatterers in this distribution"}
	SetVariable Dis3_Volume,pos={174,300},size={180,16},proc=IR1S_PanelSetVarProc,title="Scaterer volume [fract]:   "
	SetVariable Dis3_Volume,limits={0,inf,0.03},variable= root:Packages:SAS_Modeling:Dist3VolFraction, help={"Input volume of scatterers in this distribution"}
	SetVariable Dis3_NegligibleFraction,pos={173,320},size={180,16},title="Neglect tail dist fractions"
	SetVariable Dis3_NegligibleFraction,limits={1e-05,0.1,0.001},variable= root:Packages:SAS_Modeling:Dist3NegligibleFraction, help={"Input fraction of distribution, which is considered neggligible. default 0.01 (1%). Lower number means wider range of diameters."}
	SetVariable Dis3_NumberOfPointsInDis,pos={173,340},size={180,16},title="Number of bins in distribution"
	SetVariable Dis3_NumberOfPointsInDis,limits={10,1000,1},variable= root:Packages:SAS_Modeling:Dist3NumberOfPoints, help={"Input number of bins in the distribution to be modelled. Large numbers may be slow. Default 40"}

	SetVariable Dis3_Location,pos={27,395},size={120,16},proc=IR1S_PanelSetVarProc,title="Location  ", help={"One of the distribution parameters called location. Check formula for it's meaning."}
	SetVariable Dis3_Location,limits={0,inf,root:Packages:SAS_Modeling:Dist3LocStep}, variable= root:Packages:SAS_Modeling:Dist3Location
	SetVariable Dis3_LocationStep,pos={157,395},size={60,16},proc=IR1S_PanelSetVarProc,title="step", help={"Step with which the location can be changed. Set to convenient number."}
	SetVariable Dis3_LocationStep,limits={0,1000,0},variable= root:Packages:SAS_Modeling:Dist3LocStep

	SetVariable Dis3_scale,pos={27,415},size={120,16},proc=IR1S_PanelSetVarProc,title="Scale       ", help={"One of the distribution parameters, this one called Scale. Check formula for it's meaning."}
	SetVariable Dis3_scale,limits={-inf,inf,root:Packages:SAS_Modeling:Dist3ScaleStep},variable= root:Packages:SAS_Modeling:Dist3Scale
	SetVariable Dis3_ScaleStep,pos={157,415},size={60,16},proc=IR1S_PanelSetVarProc,title="step", help={"Step with which the Scale can be changed. Set to convenient number."}
	SetVariable Dis3_ScaleStep,limits={0,1000,0},variable= root:Packages:SAS_Modeling:Dist3ScaleStep

	SetVariable Dis3_shape,pos={26,435},size={120,16},proc=IR1S_PanelSetVarProc,title="Shape      ", help={"One of the distribution parameters, this one called Shape, Check formula for it's meaning. "}
	SetVariable Dis3_shape,limits={-inf,inf,root:Packages:SAS_Modeling:Dist3ShapeStep},variable= root:Packages:SAS_Modeling:Dist3Shape
	SetVariable Dis3_ShapeStep,pos={157,435},size={60,16},proc=IR1S_PanelSetVarProc,title="step", help={"Step with which the Shape can be changed. Set to convenient number."}
	SetVariable Dis3_ShapeStep,limits={0,1000,0},variable= root:Packages:SAS_Modeling:Dist3ShapeStep

	SetVariable Dis3_Mode,pos={234,387},size={120,16},title="Dist. mode    = ", help={"Mode of this distribution. Calculated numerically."}
	SetVariable Dis3_Mode,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist3Mode, format="%.1f"
	SetVariable Dis3_Median,pos={234,404},size={120,16},title="Dist. median = ", help={"Median of this distribution. Calculated numerically."}
	SetVariable Dis3_Median,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist3Median, format="%.1f"
	SetVariable Dis3_Mean,pos={234,421},size={120,16},title="Dist. mean    = ", help={"Mean of this distribution. Calculated numerically."}
	SetVariable Dis3_Mean,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist3Mean, format="%.1f"
	SetVariable Dis3_FWHM,pos={234,438},size={120,16},title="Dist. FWHM = ", help={"Full width at half maximum of this distribution. Calculated numerically."}
	SetVariable Dis3_FWHM,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist3FWHM, format="%.1f"

	TitleBox Dis3_Gauss,pos={5,365},size={256,21},disable=1
	TitleBox Dis3_Gauss,variable= root:Packages:SAS_Modeling:GaussEquation
	TitleBox Dis3_LogNormal,pos={5,365},size={336,21}
	TitleBox Dis3_LogNormal,variable= root:Packages:SAS_Modeling:LogNormalEquation
	TitleBox Dis3_LSW,pos={5,365},size={311,21},disable=1
	TitleBox Dis3_LSW,variable= root:Packages:SAS_Modeling:LSWEquation
	TitleBox Dis3_PowerLaw,pos={5,365},size={311,21},disable=1
	TitleBox Dis3_PowerLaw,variable= root:Packages:SAS_Modeling:PowerLawEquation
	
	//Distribution 3 fitting limits
	SetVariable Dis3_LocationLow,pos={32,493},size={50,16},title=" ", help={"Low fitting limit for the location."}
	SetVariable Dis3_LocationLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist3LocLowLimit
	SetVariable Dis3_LocationHigh,pos={97,493},size={130,16},title="  < location <     ", help={"High fitting limit for the location"}
	SetVariable Dis3_LocationHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist3LocHighLimit
	SetVariable Dis3_ScaleLow,pos={32,515},size={50,16},title=" ", help={"Low fitting limit for the Scale"}
	SetVariable Dis3_ScaleLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist3ScaleLowLimit
	SetVariable Dis3_ScaleHigh,pos={97,516},size={130,16},title="  < scale <          ", help={"High fitting limit for scale"}
	SetVariable Dis3_ScaleHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist3ScaleHighLimit
	SetVariable Dis3_ShapeLow,pos={32,537},size={50,16},title=" ", help={"Low fitting limit for Shape"}
	SetVariable Dis3_ShapeLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist3ShapeLowLimit
	SetVariable Dis3_ShapeHigh,pos={98,537},size={130,16},title=" < shape <         ", help={"High fitting limit for shape"}
	SetVariable Dis3_ShapeHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist3ShapeHighLimit
	CheckBox Dis3_FitVolume,pos={250,475},size={73,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Volume?"
	CheckBox Dis3_FitVolume,variable= root:Packages:SAS_Modeling:Dist3FitVol, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	CheckBox Dis3_FitLocation,pos={250,495},size={79,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Location?"
	CheckBox Dis3_FitLocation,variable= root:Packages:SAS_Modeling:Dist3FitLocation, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	CheckBox Dis3_FitScale,pos={250,515},size={65,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Scale?"
	CheckBox Dis3_FitScale,variable= root:Packages:SAS_Modeling:Dist3FitScale, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	CheckBox Dis3_FitShape,pos={250,535},size={69,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Shape?"
	CheckBox Dis3_FitShape,variable= root:Packages:SAS_Modeling:Dist3FitShape, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	SetVariable Dis3_VolumeLow,pos={32,471},size={50,16},title=" ", help={"Low fitting limit for volume"}
	SetVariable Dis3_VolumeLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist3VolLowLimit
	SetVariable Dis3_VolumeHigh,pos={99,473},size={130,16},title="  < volume <     ", help={"High fitting limit for volume"}
	SetVariable Dis3_VolumeHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist3VolHighLimit
	//end of Distribution 3 controls....


	//Distribution 4 controls
	PopupMenu Dis4_ShapePopup,pos={6,286},size={158,21},proc=IR1S_PanelPopupControl,title="Shape", help={"Select shape for scatterers in this distribution."}
//	PopupMenu Dis4_ShapePopup,mode=1,popvalue="sphere",value= #"\"sphere;spheroid;cylinder;tube;coreshell;Fractal Aggregate;other not coded yet\""
	PopupMenu Dis4_ShapePopup,mode=1,popvalue=root:Packages:SAS_Modeling:Dist4ShapeModel,value= root:Packages:FormFactorCalc:ListOfFormFactors
//	PopupMenu Dis4_ShapePopup,mode=1,popvalue="sphere",value= #"\"sphere;spheroid;coreshell;other not coded yet\""
	PopupMenu Dis4_DistributionType,pos={6,315},size={149,21},proc=IR1S_PanelPopupControl,title="Dist type :", help={"Select distribution type which will be modelled"}
	PopupMenu Dis4_DistributionType,mode=1,popvalue="LogNormal",value= #"\"LogNormal;Gauss;LSW;PowerLaw;\""
	SetVariable Dis4_Contrast,pos={174,280},size={180,16},proc=IR1S_PanelSetVarProc,title="Contrast   [*10^20 cm-4] "
	SetVariable Dis4_Contrast,limits={0,50000,1},variable= root:Packages:SAS_Modeling:Dist4Contrast, help={"Input contrast for the scatterers in this distribution"}
	SetVariable Dis4_Volume,pos={174,300},size={180,16},proc=IR1S_PanelSetVarProc,title="Scaterer volume [fract]:   "
	SetVariable Dis4_Volume,limits={0,inf,0.03},variable= root:Packages:SAS_Modeling:Dist4VolFraction, help={"Input volume of scatterers in this distribution"}
	SetVariable Dis4_NegligibleFraction,pos={173,320},size={180,16},title="Neglect tail dist fractions"
	SetVariable Dis4_NegligibleFraction,limits={1e-05,0.1,0.001},variable= root:Packages:SAS_Modeling:Dist4NegligibleFraction, help={"Input fraction of distribution, which is considered neggligible. default 0.01 (1%). Lower number means wider range of diameters."}
	SetVariable Dis4_NumberOfPointsInDis,pos={173,340},size={180,16},title="Number of bins in distribution"
	SetVariable Dis4_NumberOfPointsInDis,limits={10,1000,1},variable= root:Packages:SAS_Modeling:Dist4NumberOfPoints, help={"Input number of bins in the distribution to be modelled. Large numbers may be slow. Default 40"}

	SetVariable Dis4_Location,pos={27,395},size={120,16},proc=IR1S_PanelSetVarProc,title="Location  ", help={"One of the distribution parameters called location. Check formula for it's meaning."}
	SetVariable Dis4_Location,limits={0,inf,root:Packages:SAS_Modeling:Dist4LocStep}, variable= root:Packages:SAS_Modeling:Dist4Location
	SetVariable Dis4_LocationStep,pos={157,395},size={60,16},proc=IR1S_PanelSetVarProc,title="step", help={"Step with which the location can be changed. Set to convenient number."}
	SetVariable Dis4_LocationStep,limits={0,1000,0},variable= root:Packages:SAS_Modeling:Dist4LocStep

	SetVariable Dis4_scale,pos={27,415},size={120,16},proc=IR1S_PanelSetVarProc,title="Scale       ", help={"One of the distribution parameters, this one called Scale. Check formula for it's meaning."}
	SetVariable Dis4_scale,limits={-inf,inf,root:Packages:SAS_Modeling:Dist4ScaleStep},variable= root:Packages:SAS_Modeling:Dist4Scale
	SetVariable Dis4_ScaleStep,pos={157,415},size={60,16},proc=IR1S_PanelSetVarProc,title="step", help={"Step with which the Scale can be changed. Set to convenient number."}
	SetVariable Dis4_ScaleStep,limits={0,1000,0},variable= root:Packages:SAS_Modeling:Dist4ScaleStep

	SetVariable Dis4_shape,pos={26,435},size={120,16},proc=IR1S_PanelSetVarProc,title="Shape      ", help={"One of the distribution parameters, this one called Shape, Check formula for it's meaning. "}
	SetVariable Dis4_shape,limits={-inf,inf,root:Packages:SAS_Modeling:Dist4ShapeStep},variable= root:Packages:SAS_Modeling:Dist4Shape
	SetVariable Dis4_ShapeStep,pos={157,435},size={60,16},proc=IR1S_PanelSetVarProc,title="step", help={"Step with which the Shape can be changed. Set to convenient number."}
	SetVariable Dis4_ShapeStep,limits={0,1000,0},variable= root:Packages:SAS_Modeling:Dist4ShapeStep

	SetVariable Dis4_Mode,pos={234,387},size={120,16},title="Dist. mode    = ", help={"Mode of this distribution. Calculated numerically."}
	SetVariable Dis4_Mode,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist4Mode, format="%.1f"
	SetVariable Dis4_Median,pos={234,404},size={120,16},title="Dist. median = ", help={"Median of this distribution. Calculated numerically."}
	SetVariable Dis4_Median,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist4Median, format="%.1f"
	SetVariable Dis4_Mean,pos={234,421},size={120,16},title="Dist. mean    = ", help={"Mean of this distribution. Calculated numerically."}
	SetVariable Dis4_Mean,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist4Mean, format="%.1f"
	SetVariable Dis4_FWHM,pos={234,438},size={120,16},title="Dist. FWHM = ", help={"Full width at half maximum of this distribution. Calculated numerically."}
	SetVariable Dis4_FWHM,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist4FWHM, format="%.1f"

	TitleBox Dis4_Gauss,pos={5,365},size={256,21},disable=1
	TitleBox Dis4_Gauss,variable= root:Packages:SAS_Modeling:GaussEquation
	TitleBox Dis4_LogNormal,pos={5,365},size={336,21}
	TitleBox Dis4_LogNormal,variable= root:Packages:SAS_Modeling:LogNormalEquation
	TitleBox Dis4_LSW,pos={5,365},size={311,21},disable=1
	TitleBox Dis4_LSW,variable= root:Packages:SAS_Modeling:LSWEquation
	TitleBox Dis4_PowerLaw,pos={5,365},size={311,21},disable=1
	TitleBox Dis4_PowerLaw,variable= root:Packages:SAS_Modeling:PowerLawEquation
	
	//Distribution 4 fitting limits
	SetVariable Dis4_LocationLow,pos={32,493},size={50,16},title=" ", help={"Low fitting limit for the location."}
	SetVariable Dis4_LocationLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist4LocLowLimit
	SetVariable Dis4_LocationHigh,pos={97,493},size={130,16},title="  < location <     ", help={"High fitting limit for the location"}
	SetVariable Dis4_LocationHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist4LocHighLimit
	SetVariable Dis4_ScaleLow,pos={32,515},size={50,16},title=" ", help={"Low fitting limit for the Scale"}
	SetVariable Dis4_ScaleLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist4ScaleLowLimit
	SetVariable Dis4_ScaleHigh,pos={97,516},size={130,16},title="  < scale <          ", help={"High fitting limit for scale"}
	SetVariable Dis4_ScaleHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist4ScaleHighLimit
	SetVariable Dis4_ShapeLow,pos={32,537},size={50,16},title=" ", help={"Low fitting limit for Shape"}
	SetVariable Dis4_ShapeLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist4ShapeLowLimit
	SetVariable Dis4_ShapeHigh,pos={98,537},size={130,16},title=" < shape <         ", help={"High fitting limit for shape"}
	SetVariable Dis4_ShapeHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist4ShapeHighLimit
	CheckBox Dis4_FitVolume,pos={250,475},size={73,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Volume?"
	CheckBox Dis4_FitVolume,variable= root:Packages:SAS_Modeling:Dist4FitVol, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	CheckBox Dis4_FitLocation,pos={250,495},size={79,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Location?"
	CheckBox Dis4_FitLocation,variable= root:Packages:SAS_Modeling:Dist4FitLocation, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	CheckBox Dis4_FitScale,pos={250,515},size={65,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Scale?"
	CheckBox Dis4_FitScale,variable= root:Packages:SAS_Modeling:Dist4FitScale, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	CheckBox Dis4_FitShape,pos={250,535},size={69,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Shape?"
	CheckBox Dis4_FitShape,variable= root:Packages:SAS_Modeling:Dist4FitShape, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	SetVariable Dis4_VolumeLow,pos={32,471},size={50,16},title=" ", help={"Low fitting limit for volume"}
	SetVariable Dis4_VolumeLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist4VolLowLimit
	SetVariable Dis4_VolumeHigh,pos={99,473},size={130,16},title="  < volume <     "
	SetVariable Dis4_VolumeHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist4VolHighLimit
	//end of Distribution 4 controls....


	//Distribution 5 controls
	PopupMenu Dis5_ShapePopup,pos={6,286},size={158,21},proc=IR1S_PanelPopupControl,title="Shape", help={"Select shape for scatterers in this distribution."}
//	PopupMenu Dis5_ShapePopup,mode=1,popvalue="sphere",value= #"\"sphere;spheroid;cylinder;tube;coreshell;Fractal Aggregate;other not coded yet\""
	PopupMenu Dis5_ShapePopup,mode=1,popvalue=root:Packages:SAS_Modeling:Dist5ShapeModel,value= root:Packages:FormFactorCalc:ListOfFormFactors
//	PopupMenu Dis5_ShapePopup,mode=1,popvalue="sphere",value= #"\"sphere;spheroid;coreshell;other not coded yet\""
	PopupMenu Dis5_DistributionType,pos={6,315},size={149,21},proc=IR1S_PanelPopupControl,title="Dist type :", help={"Select distribution type which will be modelled"}
	PopupMenu Dis5_DistributionType,mode=1,popvalue="LogNormal",value= #"\"LogNormal;Gauss;LSW;PowerLaw;\""
	SetVariable Dis5_Contrast,pos={174,280},size={180,16},proc=IR1S_PanelSetVarProc,title="Contrast   [*10^20 cm-4] "
	SetVariable Dis5_Contrast,limits={0,50000,1},variable= root:Packages:SAS_Modeling:Dist5Contrast, help={"Input contrast for the scatterers in this distribution"}
	SetVariable Dis5_Volume,pos={174,300},size={180,16},proc=IR1S_PanelSetVarProc,title="Scaterer volume [fract]:   "
	SetVariable Dis5_Volume,limits={0,inf,0.03},variable= root:Packages:SAS_Modeling:Dist5VolFraction, help={"Input volume of scatterers in this distribution"}
	SetVariable Dis5_NegligibleFraction,pos={173,320},size={180,16},title="Neglect tail dist fractions"
	SetVariable Dis5_NegligibleFraction,limits={1e-05,0.1,0.001},variable= root:Packages:SAS_Modeling:Dist5NegligibleFraction, help={"Input fraction of distribution, which is considered neggligible. default 0.01 (1%). Lower number means wider range of diameters."}
	SetVariable Dis5_NumberOfPointsInDis,pos={173,340},size={180,16},title="Number of bins in distribution"
	SetVariable Dis5_NumberOfPointsInDis,limits={10,1000,1},variable= root:Packages:SAS_Modeling:Dist5NumberOfPoints, help={"Input number of bins in the distribution to be modelled. Large numbers may be slow. Default 40"}

	SetVariable Dis5_Location,pos={29,395},size={120,16},proc=IR1S_PanelSetVarProc,title="Location  ", help={"One of the distribution parameters called location. Check formula for it's meaning."}
	SetVariable Dis5_Location,limits={0,inf,root:Packages:SAS_Modeling:Dist5LocStep}, variable= root:Packages:SAS_Modeling:Dist5Location
	SetVariable Dis5_LocationStep,pos={157,395},size={60,16},proc=IR1S_PanelSetVarProc,title="step", help={"Step with which the location can be changed. Set to convenient number."}
	SetVariable Dis5_LocationStep,limits={0,1000,0},variable= root:Packages:SAS_Modeling:Dist5LocStep

	SetVariable Dis5_scale,pos={27,415},size={120,16},proc=IR1S_PanelSetVarProc,title="Scale       ", help={"One of the distribution parameters, this one called Scale. Check formula for it's meaning."}
	SetVariable Dis5_scale,limits={-inf,inf,root:Packages:SAS_Modeling:Dist5ScaleStep},variable= root:Packages:SAS_Modeling:Dist5Scale
	SetVariable Dis5_ScaleStep,pos={157,415},size={60,16},proc=IR1S_PanelSetVarProc,title="step", help={"Step with which the Scale can be changed. Set to convenient number."}
	SetVariable Dis5_ScaleStep,limits={0,1000,0},variable= root:Packages:SAS_Modeling:Dist5ScaleStep

	SetVariable Dis5_shape,pos={26,435},size={120,16},proc=IR1S_PanelSetVarProc,title="Shape      ", help={"One of the distribution parameters, this one called Shape, Check formula for it's meaning. "}
	SetVariable Dis5_shape,limits={-inf,inf,root:Packages:SAS_Modeling:Dist5ShapeStep},variable= root:Packages:SAS_Modeling:Dist5Shape
	SetVariable Dis5_ShapeStep,pos={157,435},size={60,16},proc=IR1S_PanelSetVarProc,title="step", help={"Step with which the Shape can be changed. Set to convenient number."}
	SetVariable Dis5_ShapeStep,limits={0,1000,0},variable= root:Packages:SAS_Modeling:Dist5ShapeStep

	SetVariable Dis5_Mode,pos={234,387},size={120,16},title="Dist. mode    = ", help={"Mode of this distribution. Calculated numerically."}
	SetVariable Dis5_Mode,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist5Mode, format="%.1f"
	SetVariable Dis5_Median,pos={234,404},size={120,16},title="Dist. median = ", help={"Median of this distribution. Calculated numerically."}
	SetVariable Dis5_Median,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist5Median, format="%.1f"
	SetVariable Dis5_Mean,pos={234,421},size={120,16},title="Dist. mean    = ", help={"Mean of this distribution. Calculated numerically."}
	SetVariable Dis5_Mean,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist5Mean, format="%.1f"
	SetVariable Dis5_FWHM,pos={234,438},size={120,16},title="Dist. FWHM = ", help={"Full width at half maximum of this distribution. Calculated numerically."}
	SetVariable Dis5_FWHM,limits={-Inf,Inf,0},variable= root:Packages:SAS_Modeling:Dist5FWHM, format="%.1f"

	TitleBox Dis5_Gauss,pos={5,365},size={256,21},disable=1
	TitleBox Dis5_Gauss,variable= root:Packages:SAS_Modeling:GaussEquation
	TitleBox Dis5_LogNormal,pos={5,365},size={336,21}
	TitleBox Dis5_LogNormal,variable= root:Packages:SAS_Modeling:LogNormalEquation
	TitleBox Dis5_LSW,pos={5,365},size={311,21},disable=1
	TitleBox Dis5_LSW,variable= root:Packages:SAS_Modeling:LSWEquation
	TitleBox Dis5_PowerLaw,pos={5,365},size={311,21},disable=1
	TitleBox Dis5_PowerLaw,variable= root:Packages:SAS_Modeling:PowerLawEquation
	
	//Distribution 5 fitting limits
	SetVariable Dis5_LocationLow,pos={32,493},size={50,16},title=" ", help={"Low fitting limit for the location."}
	SetVariable Dis5_LocationLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist5LocLowLimit
	SetVariable Dis5_LocationHigh,pos={97,493},size={130,16},title="  < location <     ", help={"High fitting limit for the location"}
	SetVariable Dis5_LocationHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist5LocHighLimit
	SetVariable Dis5_ScaleLow,pos={32,515},size={50,16},title=" ", help={"Low fitting limit for the Scale"}
	SetVariable Dis5_ScaleLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist5ScaleLowLimit
	SetVariable Dis5_ScaleHigh,pos={97,516},size={130,16},title="  < scale <          ", help={"High fitting limit for scale"}
	SetVariable Dis5_ScaleHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist5ScaleHighLimit
	SetVariable Dis5_ShapeLow,pos={32,537},size={50,16},title=" ", help={"Low fitting limit for Shape"}
	SetVariable Dis5_ShapeLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist5ShapeLowLimit
	SetVariable Dis5_ShapeHigh,pos={98,537},size={130,16},title=" < shape <         ", help={"High fitting limit for shape"}
	SetVariable Dis5_ShapeHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist5ShapeHighLimit
	CheckBox Dis5_FitVolume,pos={250,475},size={73,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Volume?"
	CheckBox Dis5_FitVolume,variable= root:Packages:SAS_Modeling:Dist5FitVol, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	CheckBox Dis5_FitLocation,pos={250,495},size={79,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Location?"
	CheckBox Dis5_FitLocation,variable= root:Packages:SAS_Modeling:Dist5FitLocation, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	CheckBox Dis5_FitScale,pos={250,515},size={65,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Scale?"
	CheckBox Dis5_FitScale,variable= root:Packages:SAS_Modeling:Dist5FitScale, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	CheckBox Dis5_FitShape,pos={250,535},size={69,14},proc=IR1S_InputPanelCheckboxProc,title="Fit Shape?"
	CheckBox Dis5_FitShape,variable= root:Packages:SAS_Modeling:Dist5FitShape, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	SetVariable Dis5_VolumeLow,pos={32,471},size={50,16},title=" ", help={"Low fitting limit for volume"}
	SetVariable Dis5_VolumeLow,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist5VolLowLimit
	SetVariable Dis5_VolumeHigh,pos={99,473},size={130,16},title="  < volume <     ", help={"High fitting limit for volume"}
	SetVariable Dis5_VolumeHigh,limits={0,Inf,0},variable= root:Packages:SAS_Modeling:Dist5VolHighLimit
	//end of Distribution 5 controls....

	//lets try to update the tabs...
	IR1S_TabPanelControl("test",0)

EndMacro



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1S_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling

	if (cmpstr(ctrlName,"UseIndra2Data")==0)
		//here we control the data structure checkbox
		NVAR UseIndra2Data=root:Packages:SAS_Modeling:UseIndra2Data
		NVAR UseQRSData=root:Packages:SAS_Modeling:UseQRSData
		UseIndra2Data=checked
		if (checked)
			UseQRSData=0
		endif
		Checkbox UseIndra2Data, value=UseIndra2Data
		Checkbox UseQRSData, value=UseQRSData
		SVAR Dtf=root:Packages:SAS_Modeling:DataFolderName
		SVAR IntDf=root:Packages:SAS_Modeling:IntensityWaveName
		SVAR QDf=root:Packages:SAS_Modeling:QWaveName
		SVAR EDf=root:Packages:SAS_Modeling:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder mode=1
			PopupMenu IntensityDataName   mode=1, value="---"
			PopupMenu QvecDataName    mode=1, value="---"
			PopupMenu ErrorDataName    mode=1, value="---"
	endif
	if (cmpstr(ctrlName,"UseQRSData")==0)
		//here we control the data structure checkbox
		NVAR UseQRSData=root:Packages:SAS_Modeling:UseQRSData
		NVAR UseIndra2Data=root:Packages:SAS_Modeling:UseIndra2Data
		UseQRSData=checked
		if (checked)
			UseIndra2Data=0
		endif
		Checkbox UseIndra2Data, value=UseIndra2Data
		Checkbox UseQRSData, value=UseQRSData
		SVAR Dtf=root:Packages:SAS_Modeling:DataFolderName
		SVAR IntDf=root:Packages:SAS_Modeling:IntensityWaveName
		SVAR QDf=root:Packages:SAS_Modeling:QWaveName
		SVAR EDf=root:Packages:SAS_Modeling:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder mode=1
			PopupMenu IntensityDataName   mode=1, value="---"
			PopupMenu QvecDataName    mode=1, value="---"
			PopupMenu ErrorDataName    mode=1, value="---"
	endif
	if (cmpstr(ctrlName,"UseSlitSmearedData")==0)
		//here we control the data structure checkbox
		NVAR UseSlitSmearedData=root:Packages:SAS_Modeling:UseSlitSmearedData
		SetVariable SlitLength disable=!(UseSlitSmearedData), win=IR1S_ControlPanel
		NVAR UseIndra2Data=root:Packages:SAS_Modeling:UseIndra2Data
		NVAR UseQRSData=root:Packages:SAS_Modeling:UseQRSData
		Checkbox UseIndra2Data, value=UseIndra2Data
		Checkbox UseQRSData, value=UseQRSData
		SVAR Dtf=root:Packages:SAS_Modeling:DataFolderName
		SVAR IntDf=root:Packages:SAS_Modeling:IntensityWaveName
		SVAR QDf=root:Packages:SAS_Modeling:QWaveName
		SVAR EDf=root:Packages:SAS_Modeling:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder mode=1
			PopupMenu IntensityDataName   mode=1, value="---"
			PopupMenu QvecDataName    mode=1, value="---"
			PopupMenu ErrorDataName    mode=1, value="---"
		PopupMenu SelectDataFolder,win=IR1S_ControlPanel, value= #"\"---;\"+IR1_GenStringOfFolders(root:Packages:SAS_Modeling:UseIndra2Data, root:Packages:SAS_Modeling:UseQRSData,root:Packages:SAS_Modeling:UseSlitSmearedData,0)"
	
	endif

	NVAR UseGeneticOptimization=root:Packages:SAS_Modeling:UseGenOpt
	NVAR UseLSQF=root:Packages:SAS_Modeling:UseLSQF
	if (stringMatch(ctrlName,"UseGenOpt"))
		UseLSQF=!UseGeneticOptimization
	endif
	if (stringMatch(ctrlName,"UseLSQF"))
		UseGeneticOptimization=!UseLSQF
	endif


	if (cmpstr(ctrlName,"DisplayVD")==0)
		//here we control the data structure checkbox
		NVAR DisplayVD=root:Packages:SAS_Modeling:DisplayVD
		DisplayVD=checked
		Checkbox DisplayVD, value=DisplayVD
		IR1_AppendModelData()
	endif
	if (cmpstr(ctrlName,"DisplayND")==0)
		//here we control the data structure checkbox
		NVAR DisplayND=root:Packages:SAS_Modeling:DisplayND
		DisplayND=checked
		Checkbox DisplayND, value=DisplayND
		IR1_AppendModelData()
	endif
	if (cmpstr(ctrlName,"FitBackground")==0)
		//here we control the data structure checkbox
//		NVAR FitSASBackground=root:Packages:SAS_Modeling:FitSASBackground
//		FitSASBackground=checked
//		Checkbox FitBackground, value=FitSASBackground
	endif
	if (cmpstr(ctrlName,"NumOrVolDist")==0)
		//here we control the data structure checkbox
		NVAR UseNumberDistribution=root:Packages:SAS_Modeling:UseNumberDistribution
		NVAR UseVolumeDistribution=root:Packages:SAS_Modeling:UseVolumeDistribution
		UseNumberDistribution=checked
		UseVolumeDistribution=!checked
	//	Checkbox NumOrVolDist, value=UseNumberDistribution
	//	CheckBox VolOrNumDist,value= (!UseNumberDistribution)
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"VolOrNumDist")==0)
		//here we control the data structure checkbox
		NVAR UseNumberDistribution=root:Packages:SAS_Modeling:UseNumberDistribution
		NVAR UseVolumeDistribution=root:Packages:SAS_Modeling:UseVolumeDistribution
		UseNumberDistribution=(!checked)
		UseVolumeDistribution=checked
		//Checkbox NumOrVolDist, value=UseNumberDistribution
		//CheckBox VolOrNumDist,value= (!UseNumberDistribution)
		IR1S_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"UpdateAutomatically")==0)
		//here we control the data structure checkbox
	//	NVAR UpdateAutomatically=root:Packages:SAS_Modeling:UpdateAutomatically
	//	UpdateAutomatically=checked
	//	Checkbox UpdateAutomatically, value=UpdateAutomatically
		IR1S_AutoUpdateIfSelected()
	endif

	if (cmpstr(ctrlName,"UseInterference")==0)
		//here we control the data structure checkbox
		IR1S_CallInterferencePanel()
		IR1S_AutoUpdateIfSelected()
	endif


//Dist 1 Interference checkboxes
	if (cmpstr(ctrlName,"Dist1_UseInterference")==0)
		//here we control the data structure checkbox
		SetVariable Dist1_InterferencePhi, disable = (!checked)
		SetVariable Dist1_InterferenceETA, disable = (!checked)
		NVAR FitETA=root:Packages:SAS_Modeling:Dist1FitInterferenceETA
		NVAR fitPhi=root:Packages:SAS_Modeling:Dist1FitInterferencePhi
		CheckBox Dist1_FitInterferencePhi, disable = (!checked)
		CheckBox Dist1_FitInterferenceEta, disable = (!checked)
		SetVariable Dist1_InterferenceETALL, disable = (!checked || !FitETA)
		SetVariable Dist1_InterferenceETAHL, disable =(!checked || !FitETA) 
		SetVariable Dist1_InterferencePhiLL, disable = (!checked || !FitPhi)
		SetVariable Dist1_InterferencePhiHL, disable =(!checked || !FitPhi) 
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dist1_FitInterferencePhi")==0)
		//here we control the data structure checkbox
		SetVariable Dist1_InterferencePhiLL, disable = (!checked)
		SetVariable Dist1_InterferencePhiHL, disable =(!checked) 
	endif
	if (cmpstr(ctrlName,"Dist1_FitInterferenceETA")==0)
		//here we control the data structure checkbox
		SetVariable Dist1_InterferenceETALL, disable = (!checked)
		SetVariable Dist1_InterferenceETAHL, disable =(!checked) 
	endif
	

//Dist2 Interference checkboxes
	if (cmpstr(ctrlName,"Dist2_UseInterference")==0)
		//here we control the data structure checkbox
		SetVariable Dist2_InterferencePhi, disable = (!checked)
		SetVariable Dist2_InterferenceETA, disable = (!checked)
		NVAR FitETA=root:Packages:SAS_Modeling:Dist2FitInterferenceETA
		NVAR fitPhi=root:Packages:SAS_Modeling:Dist2FitInterferencePhi
		CheckBox Dist2_FitInterferencePhi, disable = (!checked)
		CheckBox Dist2_FitInterferenceEta, disable = (!checked)
		SetVariable Dist2_InterferenceETALL, disable = (!checked || !FitETA)
		SetVariable Dist2_InterferenceETAHL, disable =(!checked || !FitETA) 
		SetVariable Dist2_InterferencePhiLL, disable = (!checked || !FitPhi)
		SetVariable Dist2_InterferencePhiHL, disable =(!checked || !FitPhi) 
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dist2_FitInterferencePhi")==0)
		//here we control the data structure checkbox
		SetVariable Dist2_InterferencePhiLL, disable = (!checked)
		SetVariable Dist2_InterferencePhiHL, disable =(!checked) 
	endif
	if (cmpstr(ctrlName,"Dist2_FitInterferenceETA")==0)
		//here we control the data structure checkbox
		SetVariable Dist2_InterferenceETALL, disable = (!checked)
		SetVariable Dist2_InterferenceETAHL, disable =(!checked) 
	endif


//Dist3 Interference checkboxes
	if (cmpstr(ctrlName,"Dist3_UseInterference")==0)
		//here we control the data structure checkbox
		SetVariable Dist3_InterferencePhi, disable = (!checked)
		SetVariable Dist3_InterferenceETA, disable = (!checked)
		NVAR FitETA=root:Packages:SAS_Modeling:Dist3FitInterferenceETA
		NVAR fitPhi=root:Packages:SAS_Modeling:Dist3FitInterferencePhi
		CheckBox Dist3_FitInterferencePhi, disable = (!checked)
		CheckBox Dist3_FitInterferenceEta, disable = (!checked)
		SetVariable Dist3_InterferenceETALL, disable = (!checked || !FitETA)
		SetVariable Dist3_InterferenceETAHL, disable =(!checked || !FitETA) 
		SetVariable Dist3_InterferencePhiLL, disable = (!checked || !FitPhi)
		SetVariable Dist3_InterferencePhiHL, disable =(!checked || !FitPhi) 
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dist3_FitInterferencePhi")==0)
		//here we control the data structure checkbox
		SetVariable Dist3_InterferencePhiLL, disable = (!checked)
		SetVariable Dist3_InterferencePhiHL, disable =(!checked) 
	endif
	if (cmpstr(ctrlName,"Dist3_FitInterferenceETA")==0)
		//here we control the data structure checkbox
		SetVariable Dist3_InterferenceETALL, disable = (!checked)
		SetVariable Dist3_InterferenceETAHL, disable =(!checked) 
	endif


//Dist4 Interference checkboxes
	if (cmpstr(ctrlName,"Dist4_UseInterference")==0)
		//here we control the data structure checkbox
		SetVariable Dist4_InterferencePhi, disable = (!checked)
		SetVariable Dist4_InterferenceETA, disable = (!checked)
		NVAR FitETA=root:Packages:SAS_Modeling:Dist4FitInterferenceETA
		NVAR fitPhi=root:Packages:SAS_Modeling:Dist4FitInterferencePhi
		CheckBox Dist4_FitInterferencePhi, disable = (!checked)
		CheckBox Dist4_FitInterferenceEta, disable = (!checked)
		SetVariable Dist4_InterferenceETALL, disable = (!checked || !FitETA)
		SetVariable Dist4_InterferenceETAHL, disable =(!checked || !FitETA) 
		SetVariable Dist4_InterferencePhiLL, disable = (!checked || !FitPhi)
		SetVariable Dist4_InterferencePhiHL, disable =(!checked || !FitPhi) 
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dist4_FitInterferencePhi")==0)
		//here we control the data structure checkbox
		SetVariable Dist4_InterferencePhiLL, disable = (!checked)
		SetVariable Dist4_InterferencePhiHL, disable =(!checked) 
	endif
	if (cmpstr(ctrlName,"Dist4_FitInterferenceETA")==0)
		//here we control the data structure checkbox
		SetVariable Dist4_InterferenceETALL, disable = (!checked)
		SetVariable Dist4_InterferenceETAHL, disable =(!checked) 
	endif


//Dist5 Interference checkboxes
	if (cmpstr(ctrlName,"Dist5_UseInterference")==0)
		//here we control the data structure checkbox
		SetVariable Dist5_InterferencePhi, disable = (!checked)
		SetVariable Dist5_InterferenceETA, disable = (!checked)
		NVAR FitETA=root:Packages:SAS_Modeling:Dist5FitInterferenceETA
		NVAR fitPhi=root:Packages:SAS_Modeling:Dist5FitInterferencePhi
		CheckBox Dist5_FitInterferencePhi, disable = (!checked)
		CheckBox Dist5_FitInterferenceEta, disable = (!checked)
		SetVariable Dist5_InterferenceETALL, disable = (!checked || !FitETA)
		SetVariable Dist5_InterferenceETAHL, disable =(!checked || !FitETA) 
		SetVariable Dist5_InterferencePhiLL, disable = (!checked || !FitPhi)
		SetVariable Dist5_InterferencePhiHL, disable =(!checked || !FitPhi) 
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dist5_FitInterferencePhi")==0)
		//here we control the data structure checkbox
		SetVariable Dist5_InterferencePhiLL, disable = (!checked)
		SetVariable Dist5_InterferencePhiHL, disable =(!checked) 
	endif
	if (cmpstr(ctrlName,"Dist5_FitInterferenceETA")==0)
		//here we control the data structure checkbox
		SetVariable Dist5_InterferenceETALL, disable = (!checked)
		SetVariable Dist5_InterferenceETAHL, disable =(!checked) 
	endif


	//Dist1 part
		if (cmpstr(ctrlName,"Dis1_FitLocation")==0)
		//here we control the data structure checkbox
		NVAR Dist1FitLocation=root:Packages:SAS_Modeling:Dist1FitLocation
		Dist1FitLocation=checked
//		Checkbox Dis1_FitLocation, value=Dist1FitLocation
		IR1S_TabPanelControl("doNotKillShapePanel",0)
	endif
	if (cmpstr(ctrlName,"Dis1_FitScale")==0)
		//here we control the data structure checkbox
		NVAR Dist1FitScale=root:Packages:SAS_Modeling:Dist1FitScale
		Dist1FitScale=checked
//		Checkbox Dis1_FitScale, value=Dist1FitScale
		IR1S_TabPanelControl("doNotKillShapePanel",0)
	endif
	if (cmpstr(ctrlName,"Dis1_FitShape")==0)
		//here we control the data structure checkbox
		NVAR Dist1FitShape=root:Packages:SAS_Modeling:Dist1FitShape
		Dist1FitShape=checked
//		Checkbox Dis1_FitShape, value=Dist1FitShape
		IR1S_TabPanelControl("doNotKillShapePanel",0)
	endif
	if (cmpstr(ctrlName,"Dis1_FitVolume")==0)
		//here we control the data structure checkbox
		NVAR Dist1FitVol=root:Packages:SAS_Modeling:Dist1FitVol
		Dist1FitVol=checked
//		Checkbox Dis1_FitVolume, value=Dist1FitVol
		IR1S_TabPanelControl("doNotKillShapePanel",0)
	endif

	//Dist2 part
		if (cmpstr(ctrlName,"Dis2_FitLocation")==0)
		//here we control the data structure checkbox
		NVAR Dist2FitLocation=root:Packages:SAS_Modeling:Dist2FitLocation
		Dist2FitLocation=checked
//		Checkbox Dis2_FitLocation, value=Dist2FitLocation
		IR1S_TabPanelControl("doNotKillShapePanel",1)
	endif
	if (cmpstr(ctrlName,"Dis2_FitScale")==0)
		//here we control the data structure checkbox
		NVAR Dist2FitScale=root:Packages:SAS_Modeling:Dist2FitScale
		Dist2FitScale=checked
//		Checkbox Dis2_FitScale, value=Dist2FitScale
		IR1S_TabPanelControl("doNotKillShapePanel",1)
	endif
	if (cmpstr(ctrlName,"Dis2_FitShape")==0)
		//here we control the data structure checkbox
		NVAR Dist2FitShape=root:Packages:SAS_Modeling:Dist2FitShape
		Dist2FitShape=checked
//		Checkbox Dis2_FitShape, value=Dist2FitShape
		IR1S_TabPanelControl("doNotKillShapePanel",1)
	endif
	if (cmpstr(ctrlName,"Dis2_FitVolume")==0)
		//here we control the data structure checkbox
		NVAR Dist2FitVol=root:Packages:SAS_Modeling:Dist2FitVol
		Dist2FitVol=checked
//		Checkbox Dis2_FitVolume, value=Dist2FitVol
		IR1S_TabPanelControl("doNotKillShapePanel",1)
	endif

	//Dist3 part
		if (cmpstr(ctrlName,"Dis3_FitLocation")==0)
		//here we control the data structure checkbox
		NVAR Dist3FitLocation=root:Packages:SAS_Modeling:Dist3FitLocation
		Dist3FitLocation=checked
//		Checkbox Dis3_FitLocation, value=Dist3FitLocation
		IR1S_TabPanelControl("doNotKillShapePanel",2)
	endif
	if (cmpstr(ctrlName,"Dis3_FitScale")==0)
		//here we control the data structure checkbox
		NVAR Dist3FitScale=root:Packages:SAS_Modeling:Dist3FitScale
		Dist3FitScale=checked
//		Checkbox Dis3_FitScale, value=Dist3FitScale
		IR1S_TabPanelControl("doNotKillShapePanel",2)
	endif
	if (cmpstr(ctrlName,"Dis3_FitShape")==0)
		//here we control the data structure checkbox
		NVAR Dist3FitShape=root:Packages:SAS_Modeling:Dist3FitShape
		Dist3FitShape=checked
//		Checkbox Dis3_FitShape, value=Dist3FitShape
		IR1S_TabPanelControl("doNotKillShapePanel",2)
	endif
	if (cmpstr(ctrlName,"Dis3_FitVolume")==0)
		//here we control the data structure checkbox
		NVAR Dist3FitVol=root:Packages:SAS_Modeling:Dist3FitVol
		Dist3FitVol=checked
//		Checkbox Dis3_FitVolume, value=Dist3FitVol
		IR1S_TabPanelControl("doNotKillShapePanel",2)
	endif

	//Dist4 part
		if (cmpstr(ctrlName,"Dis4_FitLocation")==0)
		//here we control the data structure checkbox
		NVAR Dist4FitLocation=root:Packages:SAS_Modeling:Dist4FitLocation
		Dist4FitLocation=checked
//		Checkbox Dis4_FitLocation, value=Dist4FitLocation
		IR1S_TabPanelControl("doNotKillShapePanel",3)
	endif
	if (cmpstr(ctrlName,"Dis4_FitScale")==0)
		//here we control the data structure checkbox
		NVAR Dist4FitScale=root:Packages:SAS_Modeling:Dist4FitScale
		Dist4FitScale=checked
//		Checkbox Dis4_FitScale, value=Dist4FitScale
		IR1S_TabPanelControl("doNotKillShapePanel",3)
	endif
	if (cmpstr(ctrlName,"Dis4_FitShape")==0)
		//here we control the data structure checkbox
		NVAR Dist4FitShape=root:Packages:SAS_Modeling:Dist4FitShape
		Dist4FitShape=checked
//		Checkbox Dis4_FitShape, value=Dist4FitShape
		IR1S_TabPanelControl("doNotKillShapePanel",3)
	endif
	if (cmpstr(ctrlName,"Dis4_FitVolume")==0)
		//here we control the data structure checkbox
		NVAR Dist4FitVol=root:Packages:SAS_Modeling:Dist4FitVol
		Dist4FitVol=checked
//		Checkbox Dis4_FitVolume, value=Dist4FitVol
		IR1S_TabPanelControl("doNotKillShapePanel",3)
	endif

	//Dist5 part
		if (cmpstr(ctrlName,"Dis5_FitLocation")==0)
		//here we control the data structure checkbox
		NVAR Dist5FitLocation=root:Packages:SAS_Modeling:Dist5FitLocation
		Dist5FitLocation=checked
//		Checkbox Dis5_FitLocation, value=Dist5FitLocation
		IR1S_TabPanelControl("doNotKillShapePanel",4)
	endif
	if (cmpstr(ctrlName,"Dis5_FitScale")==0)
		//here we control the data structure checkbox
		NVAR Dist5FitScale=root:Packages:SAS_Modeling:Dist5FitScale
		Dist5FitScale=checked
//		Checkbox Dis5_FitScale, value=Dist5FitScale
		IR1S_TabPanelControl("doNotKillShapePanel",4)
	endif
	if (cmpstr(ctrlName,"Dis5_FitShape")==0)
		//here we control the data structure checkbox
		NVAR Dist5FitShape=root:Packages:SAS_Modeling:Dist5FitShape
		Dist5FitShape=checked
//		Checkbox Dis5_FitShape, value=Dist5FitShape
		IR1S_TabPanelControl("doNotKillShapePanel",4)
	endif
	if (cmpstr(ctrlName,"Dis5_FitVolume")==0)
		//here we control the data structure checkbox
		NVAR Dist5FitVol=root:Packages:SAS_Modeling:Dist5FitVol
		Dist5FitVol=checked
//		Checkbox Dis5_FitVolume, value=Dist5FitVol
		IR1S_TabPanelControl("doNotKillShapePanel",4)
	endif

	setDataFolder oldDF
	DoWIndow/F IR1S_ControlPanel
End


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1S_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling
		SVAR Dtf=root:Packages:SAS_Modeling:DataFolderName
		NVAR UseIndra2Data=root:Packages:SAS_Modeling:UseIndra2Data
		NVAR UseQRSData=root:Packages:SAS_Modeling:UseQRSdata
		SVAR IntDf=root:Packages:SAS_Modeling:IntensityWaveName
		SVAR QDf=root:Packages:SAS_Modeling:QWaveName
		SVAR EDf=root:Packages:SAS_Modeling:ErrorWaveName
		NVAR UseSlitSmearedData=root:Packages:SAS_Modeling:UseSlitSmearedData
		string NewPanelCreated=""

	if (cmpstr(ctrlName,"NumberOfDistributions")==0)
		//here goes what happens when we change number of distributions
		NVAR nmbdist=root:Packages:SAS_Modeling:NumberOfDistributions
		nmbdist=popNum-1
		IR1S_FixTabsInPanel()
		IR1S_AutoUpdateIfSelected()
		DoWindow IR1S_InterferencePanel
			if (V_Flag)
				DoWindow/F IR1S_InterferencePanel
				IR1S_TabPanelControlInterf("name",nmbdist-1)
			endif
	endif
	
	if (cmpstr(ctrlName,"Dis1_ShapePopup")==0)
		//here goes what happens when user selects shape in the panel
		//and that means, depending on the shape selected we need to get another panel with parameters
		//we have 5 universal shape parameters available for each shape type:
		//Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3
		//Core shell types have as inpiut the three rhos, so the contrast is useless..
		if (cmpstr(popStr,"CoreShellShell")==0)
			DoALert 0,"Core-Shell-Shell FF can be used only in Modeling II, nto in Modeling I, please select another Form Factor to use here."
			popStr="Spheroid"
			Execute("PopupMenu Dis1_ShapePopup,mode=1,popvalue=\"Spheroid\" ")
		endif

		SetVariable Dis1_Contrast, disable=0 , win=IR1S_ControlPanel
		
		IR1S_ResetScatShapeFitParam(1)		//Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3

				
		//kill spheroid window if exists...
		DoWindow Shape_Model_Input_Panel
		if (V_Flag)
			DoWindow/K Shape_Model_Input_Panel
		endif
		//create new window as needed
		if (cmpstr(popStr,"spheroid")==0 || cmpstr(popStr,"Algebraic_Globules")==0 || cmpstr(popStr,"Integrated_Spheroid")==0 || cmpstr(popStr,"Unified_RodAR")==0 || cmpstr(popStr,"cylinderAR")==0)
			Execute ("Dis_Spheroid_Input_Panel(1)")
		endif
		if (cmpstr(popStr,"cylinder")==0 || cmpstr(popStr,"Algebraic_Rods")==0|| cmpstr(popStr,"Unified_Rod")==0)
			Execute ("Dis_cylinder_Panel(1)")
		endif
		if (cmpstr(popStr,"Unified_Disk")==0 || cmpstr(popStr,"Algebraic_Disks")==0)
			Execute ("Dis_Disc_Panel(1)")
		endif
		if (cmpstr(popStr,"CoreShellCylinder")==0)
			SetVariable Dis1_Contrast, disable=1, win=IR1S_ControlPanel
			Execute ("Dis_tube_Panel(1)")
		endif
		if (cmpstr(popStr,"Unified_tube")==0)
			//SetVariable Dis1_Contrast, disable=1, win=IR1S_ControlPanel
			Execute ("Dis_Unitube_Panel(1)")
		endif
		if (cmpstr(popStr,"CoreShell")==0)
			SetVariable Dis1_Contrast, disable=1 , win=IR1S_ControlPanel
			Execute ("Dis_CoreShell_Input_Panel(1)")
		endif
		if (cmpstr(popStr,"Fractal Aggregate")==0)
			Execute ("Dis_FractalAgg_Input_Panel(1)")
		endif
		if (cmpstr(popStr,"User")==0)
			Execute ("Dis_UserFFInputPanel(1)")
		endif
		NewPanelCreated = WinName(0,64)
		
		SVAR Dist1ShapeModel=root:Packages:SAS_Modeling:Dist1ShapeModel
		Dist1ShapeModel=popstr
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis1_DistributionType")==0)
		//here goes what happens when user selects different dist type
		SVAR Dist1DistributionType=root:Packages:SAS_Modeling:Dist1DistributionType
		Dist1DistributionType=popStr
		NVAR Dist1FitShape=root:Packages:SAS_Modeling:Dist1FitShape
		NVAR Dist1FitLocation=root:Packages:SAS_Modeling:Dist1FitLocation
		NVAR Dist1FitScale=root:Packages:SAS_Modeling:Dist1FitScale
		if (cmpstr(popStr,"Gauss")==0)
			SetVariable Dis1_shape, disable=1, win=IR1S_ControlPanel
			SetVariable Dis1_ShapeStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis1_Scale, disable=0,title="Width        ", win=IR1S_ControlPanel
			SetVariable Dis1_Location, disable=0,title="Mean size", win=IR1S_ControlPanel
			SetVariable Dis1_ScaleStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis1_LocationStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis1_LocationLow,disable= (!Dist1FitLocation), win=IR1S_ControlPanel
			SetVariable Dis1_LocationHigh,disable= (!Dist1FitLocation),title="  < Mean size < ", win=IR1S_ControlPanel
			CheckBox Dis1_FitLocation,disable= 0,title="Fit mean size?", win=IR1S_ControlPanel
			SetVariable Dis1_ScaleLow,disable= (!Dist1FitScale), win=IR1S_ControlPanel
			SetVariable Dis1_ScaleHigh,disable=(!Dist1FitScale),title="  < Width <       ", win=IR1S_ControlPanel
			CheckBox Dis1_FitScale,disable= 0,title="Fit width?", win=IR1S_ControlPanel
			SetVariable Dis1_ShapeLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis1_ShapeHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis1_FitShape,disable= 1, win=IR1S_ControlPanel
			
			TitleBox 	Dis1_Gauss, disable=0
			TitleBox 	Dis1_LogNormal, disable=1
			TitleBox 	Dis1_LSW, disable=1
			TitleBox 	Dis1_PowerLaw, disable=1
			
			//Dist1FitScale = 0
			//Dist1FitLocation = 0
			Dist1FitShape = 0
		endif
		if (cmpstr(popStr,"LogNormal")==0)
			SetVariable Dis1_shape, disable=0,title="Sdeviation  ", win=IR1S_ControlPanel
			SetVariable Dis1_ShapeStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis1_Scale, disable=0,title="Mean size", win=IR1S_ControlPanel
			SetVariable Dis1_Location, disable=0,title="Min size  ", win=IR1S_ControlPanel
			SetVariable Dis1_ScaleStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis1_LocationStep, disable=0, win=IR1S_ControlPanel

			SetVariable Dis1_LocationLow,disable= (!Dist1FitLocation), win=IR1S_ControlPanel
 			SetVariable Dis1_LocationHigh,disable= (!Dist1FitLocation),title="  < Min. size <   ", win=IR1S_ControlPanel
			CheckBox Dis1_FitLocation,disable= 0,title="Fit min. size?", win=IR1S_ControlPanel
			SetVariable Dis1_ScaleLow,disable=(!Dist1FitScale), win=IR1S_ControlPanel
			SetVariable Dis1_ScaleHigh,disable= (!Dist1FitScale),title="  < Mean size < ", win=IR1S_ControlPanel
			CheckBox Dis1_FitScale,disable= 0,title="Fit mean size?", win=IR1S_ControlPanel
			SetVariable Dis1_ShapeLow,disable= (!Dist1FitShape), win=IR1S_ControlPanel
			SetVariable Dis1_ShapeHigh,disable=(!Dist1FitShape),title=" < Sdeviation < ", win=IR1S_ControlPanel
			CheckBox Dis1_FitShape,disable= 0,title="Fit Sdev.?", win=IR1S_ControlPanel

			TitleBox 	Dis1_Gauss, disable=1
			TitleBox 	Dis1_LogNormal, disable=0
			TitleBox 	Dis1_LSW, disable=1
			TitleBox 	Dis1_PowerLaw, disable=1
			//Dist1FitScale = 0
			//Dist1FitLocation = 0
			//Dist1FitShape = 0
		endif
		if (cmpstr(popStr,"LSW")==0)
			SetVariable Dis1_shape, disable=1, win=IR1S_ControlPanel
			SetVariable Dis1_ShapeStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis1_Scale, disable=1, win=IR1S_ControlPanel
			SetVariable Dis1_Location, disable=0,title="Location  ", win=IR1S_ControlPanel
			SetVariable Dis1_ScaleStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis1_LocationStep, disable=0, win=IR1S_ControlPanel
			
			SetVariable Dis1_LocationLow,disable= (!Dist1FitLocation), win=IR1S_ControlPanel
			SetVariable Dis1_LocationHigh,disable= (!Dist1FitLocation),title="  < location <     ", win=IR1S_ControlPanel
			CheckBox Dis1_FitLocation,disable= 0,title="Fit Location?", win=IR1S_ControlPanel
			SetVariable Dis1_ScaleLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis1_ScaleHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis1_FitScale,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis1_ShapeLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis1_ShapeHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis1_FitShape,disable= 1, win=IR1S_ControlPanel

			TitleBox 	Dis1_Gauss, disable=1
			TitleBox 	Dis1_LogNormal, disable=1
			TitleBox 	Dis1_LSW, disable=0
			TitleBox 	Dis1_PowerLaw, disable=1

			Dist1FitScale = 0
			//Dist1FitLocation = 0
			Dist1FitShape = 0
		endif
		if (cmpstr(popStr,"PowerLaw")==0)
			SetVariable Dis1_shape, disable=0,title="Power slope   ", win=IR1S_ControlPanel
			SetVariable Dis1_ShapeStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis1_Scale, disable=0,title="Minimum Dia   ", win=IR1S_ControlPanel
			SetVariable Dis1_Location, disable=0,title="Maximum Dia  ", win=IR1S_ControlPanel
			SetVariable Dis1_ScaleStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis1_LocationStep, disable=1, win=IR1S_ControlPanel
			
			SetVariable Dis1_LocationLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis1_LocationHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis1_FitLocation,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis1_ScaleLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis1_ScaleHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis1_FitScale,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis1_ShapeLow,disable= 0, win=IR1S_ControlPanel
			SetVariable Dis1_ShapeHigh,disable= 0,title=" < slope < ", win=IR1S_ControlPanel
			CheckBox Dis1_FitShape,disable= 0,title="Fit slope?", win=IR1S_ControlPanel

			TitleBox 	Dis1_Gauss, disable=1
			TitleBox 	Dis1_LogNormal, disable=1
			TitleBox 	Dis1_LSW, disable=1
			TitleBox 	Dis1_PowerLaw, disable=0
			Dist1FitScale = 0
			Dist1FitLocation = 0
			//Dist1FitShape = 0
		endif
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif


	if (cmpstr(ctrlName,"Dis2_ShapePopup")==0)
		//here goes what happens when user selects shape in the panel
		//and that means, depending on the shape selected we need to get another panel with parameters
		//we have 3 universal shape parameters available for each shape type:
		//Dist2ScatShapeParam1;Dist2ScatShapeParam2;Dist2ScatShapeParam3
		if (cmpstr(popStr,"CoreShellShell")==0)
			DoALert 0,"Core-Shell-Shell FF can be used only in Modeling II, nto in Modeling I, please select another Form Factor to use here."
			popStr="Spheroid"
			Execute("PopupMenu Dis2_ShapePopup,mode=1,popvalue=\"Spheroid\" ")
		endif
		
		IR1S_ResetScatShapeFitParam(2)		//Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3
		SetVariable Dis2_Contrast, disable=0 , win=IR1S_ControlPanel
		//kill shpheroid window if exists...
		DoWindow Shape_Model_Input_Panel
		if (V_Flag)
			DoWindow/K Shape_Model_Input_Panel
		endif
		//create new window as needed
		if (cmpstr(popStr,"spheroid")==0 || cmpstr(popStr,"Algebraic_Globules")==0 || cmpstr(popStr,"Integrated_Spheroid")==0 || cmpstr(popStr,"Unified_RodAR")==0 || cmpstr(popStr,"cylinderAR")==0)
			Execute ("Dis_Spheroid_Input_Panel(2)")
		endif
		if (cmpstr(popStr,"cylinder")==0 || cmpstr(popStr,"Algebraic_Rods")==0|| cmpstr(popStr,"Unified_Rod")==0)
			Execute ("Dis_cylinder_Panel(2)")
		endif
		if (cmpstr(popStr,"Unified_Disk")==0 || cmpstr(popStr,"Algebraic_Disks")==0)
			Execute ("Dis_Disc_Panel(2)")
		endif
		if (cmpstr(popStr,"CoreShellCylinder")==0)
			SetVariable Dis2_Contrast, disable=1, win=IR1S_ControlPanel
			Execute ("Dis_tube_Panel(2)")
		endif
		if (cmpstr(popStr,"CoreShell")==0)
			SetVariable Dis2_Contrast, disable=1, win=IR1S_ControlPanel
			Execute ("Dis_CoreShell_Input_Panel(2)")
		endif
		if (cmpstr(popStr,"Fractal Aggregate")==0)
			Execute ("Dis_FractalAgg_Input_Panel(2)")
		endif
		if (cmpstr(popStr,"User")==0)
			Execute ("Dis_UserFFInputPanel(2)")
		endif
		NewPanelCreated = WinName(0,64)
		SVAR Dist2ShapeModel=root:Packages:SAS_Modeling:Dist2ShapeModel
		Dist2ShapeModel=popStr
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis2_DistributionType")==0)
		//here goes what happens when user selects different dist type
		SVAR Dist2DistributionType=root:Packages:SAS_Modeling:Dist2DistributionType
		NVAR Dist2FitShape=root:Packages:SAS_Modeling:Dist2FitShape
		NVAR Dist2FitLocation=root:Packages:SAS_Modeling:Dist2FitLocation
		NVAR Dist2FitScale=root:Packages:SAS_Modeling:Dist2FitScale
		Dist2DistributionType=popStr
		if (cmpstr(popStr,"Gauss")==0)
			SetVariable Dis2_shape, disable=1, win=IR1S_ControlPanel
			SetVariable Dis2_ShapeStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis2_Scale, disable=0,title="Width        ", win=IR1S_ControlPanel
			SetVariable Dis2_Location, disable=0,title="Mean size", win=IR1S_ControlPanel
			SetVariable Dis2_ScaleStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis2_LocationStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis2_LocationLow,disable= (!Dist2FitLocation), win=IR1S_ControlPanel
			SetVariable Dis2_LocationHigh,disable= (!Dist2FitLocation),title="  < Mean size < ", win=IR1S_ControlPanel
			CheckBox Dis2_FitLocation,disable= 0,title="Fit mean size?", win=IR1S_ControlPanel
			SetVariable Dis2_ScaleLow,disable= (!Dist2FitScale), win=IR1S_ControlPanel
			SetVariable Dis2_ScaleHigh,disable=(!Dist2FitScale),title="  < Width <       ", win=IR1S_ControlPanel
			CheckBox Dis2_FitScale,disable= 0,title="Fit width?", win=IR1S_ControlPanel
			SetVariable Dis2_ShapeLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis2_ShapeHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis2_FitShape,disable= 1, win=IR1S_ControlPanel
			
			TitleBox 	Dis2_Gauss, disable=0
			TitleBox 	Dis2_LogNormal, disable=1
			TitleBox 	Dis2_LSW, disable=1
			TitleBox 	Dis2_PowerLaw, disable=1
			
			//Dist2FitScale = 0
			//Dist2FitLocation = 0
			Dist2FitShape = 0
		endif
		if (cmpstr(popStr,"LogNormal")==0)
			SetVariable Dis2_shape, disable=0,title="Sdeviation  ", win=IR1S_ControlPanel
			SetVariable Dis2_ShapeStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis2_Scale, disable=0,title="Mean size", win=IR1S_ControlPanel
			SetVariable Dis2_Location, disable=0,title="Min size  ", win=IR1S_ControlPanel
			SetVariable Dis2_ScaleStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis2_LocationStep, disable=0, win=IR1S_ControlPanel

			SetVariable Dis2_LocationLow,disable= (!Dist2FitLocation), win=IR1S_ControlPanel
 			SetVariable Dis2_LocationHigh,disable= (!Dist2FitLocation),title="  < Min. size <   ", win=IR1S_ControlPanel
			CheckBox Dis2_FitLocation,disable= 0,title="Fit min. size?", win=IR1S_ControlPanel
			SetVariable Dis2_ScaleLow,disable=(!Dist2FitScale), win=IR1S_ControlPanel
			SetVariable Dis2_ScaleHigh,disable= (!Dist2FitScale),title="  < Mean size < ", win=IR1S_ControlPanel
			CheckBox Dis2_FitScale,disable= 0,title="Fit mean size?", win=IR1S_ControlPanel
			SetVariable Dis2_ShapeLow,disable= (!Dist2FitShape), win=IR1S_ControlPanel
			SetVariable Dis2_ShapeHigh,disable=(!Dist2FitShape),title=" < Sdeviation < ", win=IR1S_ControlPanel
			CheckBox Dis2_FitShape,disable= 0,title="Fit Sdev.?", win=IR1S_ControlPanel

			TitleBox 	Dis2_Gauss, disable=1
			TitleBox 	Dis2_LogNormal, disable=0
			TitleBox 	Dis2_LSW, disable=1
			TitleBox 	Dis2_PowerLaw, disable=1
			//Dist2FitScale = 0
			//Dist2FitLocation = 0
			//Dist2FitShape = 0
		endif
		if (cmpstr(popStr,"LSW")==0)
			SetVariable Dis2_shape, disable=1, win=IR1S_ControlPanel
			SetVariable Dis2_ShapeStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis2_Scale, disable=1, win=IR1S_ControlPanel
			SetVariable Dis2_Location, disable=0,title="Location  ", win=IR1S_ControlPanel
			SetVariable Dis2_ScaleStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis2_LocationStep, disable=0, win=IR1S_ControlPanel
			
			SetVariable Dis2_LocationLow,disable= (!Dist2FitLocation), win=IR1S_ControlPanel
			SetVariable Dis2_LocationHigh,disable= (!Dist2FitLocation),title="  < location <     ", win=IR1S_ControlPanel
			CheckBox Dis2_FitLocation,disable= 0,title="Fit Location?", win=IR1S_ControlPanel
			SetVariable Dis2_ScaleLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis2_ScaleHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis2_FitScale,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis2_ShapeLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis2_ShapeHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis2_FitShape,disable= 1, win=IR1S_ControlPanel

			TitleBox 	Dis2_Gauss, disable=1
			TitleBox 	Dis2_LogNormal, disable=1
			TitleBox 	Dis2_LSW, disable=0
			TitleBox 	Dis2_PowerLaw, disable=1

			Dist2FitScale = 0
			//Dist2FitLocation = 0
			Dist2FitShape = 0
		endif
		if (cmpstr(popStr,"PowerLaw")==0)
			SetVariable Dis2_shape, disable=0,title="Power slope   ", win=IR1S_ControlPanel
			SetVariable Dis2_ShapeStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis2_Scale, disable=0,title="Minimum Dia   ", win=IR1S_ControlPanel
			SetVariable Dis2_Location, disable=0,title="Maximum Dia  ", win=IR1S_ControlPanel
			SetVariable Dis2_ScaleStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis2_LocationStep, disable=1, win=IR1S_ControlPanel
			
			SetVariable Dis2_LocationLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis2_LocationHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis2_FitLocation,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis2_ScaleLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis2_ScaleHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis2_FitScale,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis2_ShapeLow,disable= 0, win=IR1S_ControlPanel
			SetVariable Dis2_ShapeHigh,disable= 0,title=" < slope < ", win=IR1S_ControlPanel
			CheckBox Dis2_FitShape,disable= 0,title="Fit slope?", win=IR1S_ControlPanel

			TitleBox 	Dis2_Gauss, disable=1
			TitleBox 	Dis2_LogNormal, disable=1
			TitleBox 	Dis2_LSW, disable=1
			TitleBox 	Dis2_PowerLaw, disable=0
			Dist2FitScale = 0
			Dist2FitLocation = 0
			//Dist2FitShape = 0
		endif
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif


	if (cmpstr(ctrlName,"Dis3_ShapePopup")==0)
		//here goes what happens when user selects shape in the panel
		//and that means, depending on the shape selected we need to get another panel with parameters
		//we have 3 universal shape parameters available for each shape type:
		//Dist3ScatShapeParam1;Dist3ScatShapeParam2;Dist3ScatShapeParam3
		if (cmpstr(popStr,"CoreShellShell")==0)
			DoALert 0,"Core-Shell-Shell FF can be used only in Modeling II, nto in Modeling I, please select another Form Factor to use here."
			popStr="Spheroid"
			Execute("PopupMenu Dis3_ShapePopup,mode=1,popvalue=\"Spheroid\" ")
		endif

		IR1S_ResetScatShapeFitParam(3)		//Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3
		SetVariable Dis3_Contrast, disable=0 , win=IR1S_ControlPanel
		//kill shpheroid window if exists...
		DoWindow Shape_Model_Input_Panel
		if (V_Flag)
			DoWindow/K Shape_Model_Input_Panel
		endif
		//create new window as needed
		if (cmpstr(popStr,"spheroid")==0 || cmpstr(popStr,"Algebraic_Globules")==0 || cmpstr(popStr,"Integrated_Spheroid")==0 || cmpstr(popStr,"Unified_RodAR")==0 || cmpstr(popStr,"cylinderAR")==0)
			Execute ("Dis_Spheroid_Input_Panel(3)")
		endif
		if (cmpstr(popStr,"cylinder")==0 || cmpstr(popStr,"Algebraic_Rods")==0|| cmpstr(popStr,"Unified_Rod")==0)
			Execute ("Dis_cylinder_Panel(3)")
		endif
		if (cmpstr(popStr,"Unified_Disk")==0 || cmpstr(popStr,"Algebraic_Disks")==0)
			Execute ("Dis_Disc_Panel(3)")
		endif
		if (cmpstr(popStr,"CoreShellCylinder")==0)
			SetVariable Dis3_Contrast, disable=1 , win=IR1S_ControlPanel
			Execute ("Dis_tube_Panel(3)")
		endif
		if (cmpstr(popStr,"CoreShell")==0)
			SetVariable Dis3_Contrast, disable=1, win=IR1S_ControlPanel
			Execute ("Dis_CoreShell_Input_Panel(3)")
		endif
		if (cmpstr(popStr,"Fractal Aggregate")==0)
			Execute ("Dis_FractalAgg_Input_Panel(3)")
		endif
		if (cmpstr(popStr,"User")==0)
			Execute ("Dis_UserFFInputPanel(3)")
		endif
		NewPanelCreated = WinName(0,64)
		SVAR Dist3ShapeModel=root:Packages:SAS_Modeling:Dist3ShapeModel
		Dist3ShapeModel=popStr
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		IR1S_UpdateModeMedianMean()		//modified for 5

		IR1S_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis3_DistributionType")==0)
		//here goes what happens when user selects different dist type
		SVAR Dist3DistributionType=root:Packages:SAS_Modeling:Dist3DistributionType
		NVAR Dist3FitShape=root:Packages:SAS_Modeling:Dist3FitShape
		NVAR Dist3FitLocation=root:Packages:SAS_Modeling:Dist3FitLocation
		NVAR Dist3FitScale=root:Packages:SAS_Modeling:Dist3FitScale
		Dist3DistributionType=popStr
		if (cmpstr(popStr,"Gauss")==0)
			SetVariable Dis3_shape, disable=1, win=IR1S_ControlPanel
			SetVariable Dis3_ShapeStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis3_Scale, disable=0,title="Width        ", win=IR1S_ControlPanel
			SetVariable Dis3_Location, disable=0,title="Mean size", win=IR1S_ControlPanel
			SetVariable Dis3_ScaleStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis3_LocationStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis3_LocationLow,disable= (!Dist3FitLocation), win=IR1S_ControlPanel
			SetVariable Dis3_LocationHigh,disable= (!Dist3FitLocation),title="  < Mean size < ", win=IR1S_ControlPanel
			CheckBox Dis3_FitLocation,disable= 0,title="Fit mean size?", win=IR1S_ControlPanel
			SetVariable Dis3_ScaleLow,disable= (!Dist3FitScale), win=IR1S_ControlPanel
			SetVariable Dis3_ScaleHigh,disable=(!Dist3FitScale),title="  < Width <       ", win=IR1S_ControlPanel
			CheckBox Dis3_FitScale,disable= 0,title="Fit width?", win=IR1S_ControlPanel
			SetVariable Dis3_ShapeLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis3_ShapeHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis3_FitShape,disable= 1, win=IR1S_ControlPanel
			
			TitleBox 	Dis3_Gauss, disable=0
			TitleBox 	Dis3_LogNormal, disable=1
			TitleBox 	Dis3_LSW, disable=1
			TitleBox 	Dis3_PowerLaw, disable=1
			
			//Dist3FitScale = 0
			//Dist3FitLocation = 0
			Dist3FitShape = 0
		endif
		if (cmpstr(popStr,"LogNormal")==0)
			SetVariable Dis3_shape, disable=0,title="Sdeviation  ", win=IR1S_ControlPanel
			SetVariable Dis3_ShapeStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis3_Scale, disable=0,title="Mean size", win=IR1S_ControlPanel
			SetVariable Dis3_Location, disable=0,title="Min size  ", win=IR1S_ControlPanel
			SetVariable Dis3_ScaleStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis3_LocationStep, disable=0, win=IR1S_ControlPanel

			SetVariable Dis3_LocationLow,disable= (!Dist3FitLocation), win=IR1S_ControlPanel
 			SetVariable Dis3_LocationHigh,disable= (!Dist3FitLocation),title="  < Min. size <   ", win=IR1S_ControlPanel
			CheckBox Dis3_FitLocation,disable= 0,title="Fit min. size?", win=IR1S_ControlPanel
			SetVariable Dis3_ScaleLow,disable=(!Dist3FitScale), win=IR1S_ControlPanel
			SetVariable Dis3_ScaleHigh,disable= (!Dist3FitScale),title="  < Mean size < ", win=IR1S_ControlPanel
			CheckBox Dis3_FitScale,disable= 0,title="Fit mean size?", win=IR1S_ControlPanel
			SetVariable Dis3_ShapeLow,disable= (!Dist3FitShape), win=IR1S_ControlPanel
			SetVariable Dis3_ShapeHigh,disable=(!Dist3FitShape),title=" < Sdeviation < ", win=IR1S_ControlPanel
			CheckBox Dis3_FitShape,disable= 0,title="Fit Sdev.?", win=IR1S_ControlPanel

			TitleBox 	Dis3_Gauss, disable=1
			TitleBox 	Dis3_LogNormal, disable=0
			TitleBox 	Dis3_LSW, disable=1
			TitleBox 	Dis3_PowerLaw, disable=1
			//Dist3FitScale = 0
			//Dist3FitLocation = 0
			//Dist3FitShape = 0
		endif
		if (cmpstr(popStr,"LSW")==0)
			SetVariable Dis3_shape, disable=1, win=IR1S_ControlPanel
			SetVariable Dis3_ShapeStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis3_Scale, disable=1, win=IR1S_ControlPanel
			SetVariable Dis3_Location, disable=0,title="Location  ", win=IR1S_ControlPanel
			SetVariable Dis3_ScaleStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis3_LocationStep, disable=0, win=IR1S_ControlPanel
			
			SetVariable Dis3_LocationLow,disable= (!Dist3FitLocation), win=IR1S_ControlPanel
			SetVariable Dis3_LocationHigh,disable= (!Dist3FitLocation),title="  < location <     ", win=IR1S_ControlPanel
			CheckBox Dis3_FitLocation,disable= 0,title="Fit Location?", win=IR1S_ControlPanel
			SetVariable Dis3_ScaleLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis3_ScaleHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis3_FitScale,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis3_ShapeLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis3_ShapeHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis3_FitShape,disable= 1, win=IR1S_ControlPanel

			TitleBox 	Dis3_Gauss, disable=1
			TitleBox 	Dis3_LogNormal, disable=1
			TitleBox 	Dis3_LSW, disable=0
			TitleBox 	Dis3_PowerLaw, disable=1

			Dist3FitScale = 0
			//Dist3FitLocation = 0
			Dist3FitShape = 0
		endif
		if (cmpstr(popStr,"PowerLaw")==0)
			SetVariable Dis3_shape, disable=0,title="Power slope   ", win=IR1S_ControlPanel
			SetVariable Dis3_ShapeStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis3_Scale, disable=0,title="Minimum Dia   ", win=IR1S_ControlPanel
			SetVariable Dis3_Location, disable=0,title="Maximum Dia  ", win=IR1S_ControlPanel
			SetVariable Dis3_ScaleStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis3_LocationStep, disable=1, win=IR1S_ControlPanel
			
			SetVariable Dis3_LocationLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis3_LocationHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis3_FitLocation,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis3_ScaleLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis3_ScaleHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis3_FitScale,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis3_ShapeLow,disable= 0, win=IR1S_ControlPanel
			SetVariable Dis3_ShapeHigh,disable= 0,title=" < slope < ", win=IR1S_ControlPanel
			CheckBox Dis3_FitShape,disable= 0,title="Fit slope?", win=IR1S_ControlPanel

			TitleBox 	Dis3_Gauss, disable=1
			TitleBox 	Dis3_LogNormal, disable=1
			TitleBox 	Dis3_LSW, disable=1
			TitleBox 	Dis3_PowerLaw, disable=0
			Dist3FitScale = 0
			Dist3FitLocation = 0
			//Dist3FitShape = 0
		endif
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif

	if (cmpstr(ctrlName,"Dis4_ShapePopup")==0)
		//here goes what happens when user selects shape in the panel
		//and that means, depending on the shape selected we need to get another panel with parameters
		//we have 3 universal shape parameters available for each shape type:
		//Dist4ScatShapeParam1;Dist4ScatShapeParam2;Dist4ScatShapeParam3

		if (cmpstr(popStr,"CoreShellShell")==0)
			DoALert 0,"Core-Shell-Shell FF can be used only in Modeling II, nto in Modeling I, please select another Form Factor to use here."
			popStr="Spheroid"
			Execute("PopupMenu Dis4_ShapePopup,mode=1,popvalue=\"Spheroid\" ")
		endif

		IR1S_ResetScatShapeFitParam(4)
		SetVariable Dis4_Contrast, disable=0 , win=IR1S_ControlPanel
		//kill shpheroid window if exists...
		DoWindow Shape_Model_Input_Panel
		if (V_Flag)
			DoWindow/K Shape_Model_Input_Panel
		endif
		//create new window as needed
		if (cmpstr(popStr,"spheroid")==0 || cmpstr(popStr,"Algebraic_Globules")==0 || cmpstr(popStr,"Integrated_Spheroid")==0 || cmpstr(popStr,"Unified_RodAR")==0 || cmpstr(popStr,"cylinderAR")==0)
			Execute ("Dis_Spheroid_Input_Panel(4)")
		endif
		if (cmpstr(popStr,"cylinder")==0 || cmpstr(popStr,"Algebraic_Rods")==0|| cmpstr(popStr,"Unified_Rod")==0)
			Execute ("Dis_cylinder_Panel(4)")
		endif
		if (cmpstr(popStr,"Unified_Disk")==0 || cmpstr(popStr,"Algebraic_Disks")==0)
			Execute ("Dis_Disc_Panel(4)")
		endif
		if (cmpstr(popStr,"CoreShellCylinder")==0)
			SetVariable Dis4_Contrast, disable=1, win=IR1S_ControlPanel
			Execute ("Dis_tube_Panel(4)")
		endif
		if (cmpstr(popStr,"CoreShell")==0)
			SetVariable Dis4_Contrast, disable=1 , win=IR1S_ControlPanel
			Execute ("Dis_CoreShell_Input_Panel(4)")
		endif
		if (cmpstr(popStr,"Fractal Aggregate")==0)
			Execute ("Dis_FractalAgg_Input_Panel(4)")
		endif
		if (cmpstr(popStr,"User")==0)
			Execute ("Dis_UserFFInputPanel(4)")
		endif
		NewPanelCreated = WinName(0,64)
		SVAR Dist4ShapeModel=root:Packages:SAS_Modeling:Dist4ShapeModel
		Dist4ShapeModel=popStr
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis4_DistributionType")==0)
		//here goes what happens when user selects different dist type
		SVAR Dist4DistributionType=root:Packages:SAS_Modeling:Dist4DistributionType
		NVAR Dist4FitShape=root:Packages:SAS_Modeling:Dist4FitShape
		NVAR Dist4FitLocation=root:Packages:SAS_Modeling:Dist4FitLocation
		NVAR Dist4FitScale=root:Packages:SAS_Modeling:Dist4FitScale
		Dist4DistributionType=popStr
		if (cmpstr(popStr,"Gauss")==0)
			SetVariable Dis4_shape, disable=1, win=IR1S_ControlPanel
			SetVariable Dis4_ShapeStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis4_Scale, disable=0,title="Width        ", win=IR1S_ControlPanel
			SetVariable Dis4_Location, disable=0,title="Mean size", win=IR1S_ControlPanel
			SetVariable Dis4_ScaleStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis4_LocationStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis4_LocationLow,disable= (!Dist4FitLocation), win=IR1S_ControlPanel
			SetVariable Dis4_LocationHigh,disable= (!Dist4FitLocation),title="  < Mean size < ", win=IR1S_ControlPanel
			CheckBox Dis4_FitLocation,disable= 0,title="Fit mean size?", win=IR1S_ControlPanel
			SetVariable Dis4_ScaleLow,disable= (!Dist4FitScale), win=IR1S_ControlPanel
			SetVariable Dis4_ScaleHigh,disable=(!Dist4FitScale),title="  < Width <       ", win=IR1S_ControlPanel
			CheckBox Dis4_FitScale,disable= 0,title="Fit width?", win=IR1S_ControlPanel
			SetVariable Dis4_ShapeLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis4_ShapeHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis4_FitShape,disable= 1, win=IR1S_ControlPanel
			
			TitleBox 	Dis4_Gauss, disable=0
			TitleBox 	Dis4_LogNormal, disable=1
			TitleBox 	Dis4_LSW, disable=1
			TitleBox 	Dis4_PowerLaw, disable=1
			
			//Dist4FitScale = 0
			//Dist4FitLocation = 0
			Dist4FitShape = 0
		endif
		if (cmpstr(popStr,"LogNormal")==0)
			SetVariable Dis4_shape, disable=0,title="Sdeviation  ", win=IR1S_ControlPanel
			SetVariable Dis4_ShapeStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis4_Scale, disable=0,title="Mean size", win=IR1S_ControlPanel
			SetVariable Dis4_Location, disable=0,title="Min size  ", win=IR1S_ControlPanel
			SetVariable Dis4_ScaleStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis4_LocationStep, disable=0, win=IR1S_ControlPanel

			SetVariable Dis4_LocationLow,disable= (!Dist4FitLocation), win=IR1S_ControlPanel
 			SetVariable Dis4_LocationHigh,disable= (!Dist4FitLocation),title="  < Min. size <   ", win=IR1S_ControlPanel
			CheckBox Dis4_FitLocation,disable= 0,title="Fit min. size?", win=IR1S_ControlPanel
			SetVariable Dis4_ScaleLow,disable=(!Dist4FitScale), win=IR1S_ControlPanel
			SetVariable Dis4_ScaleHigh,disable= (!Dist4FitScale),title="  < Mean size < ", win=IR1S_ControlPanel
			CheckBox Dis4_FitScale,disable= 0,title="Fit mean size?", win=IR1S_ControlPanel
			SetVariable Dis4_ShapeLow,disable= (!Dist4FitShape), win=IR1S_ControlPanel
			SetVariable Dis4_ShapeHigh,disable=(!Dist4FitShape),title=" < Sdeviation < ", win=IR1S_ControlPanel
			CheckBox Dis4_FitShape,disable= 0,title="Fit Sdev.?", win=IR1S_ControlPanel

			TitleBox 	Dis4_Gauss, disable=1
			TitleBox 	Dis4_LogNormal, disable=0
			TitleBox 	Dis4_LSW, disable=1
			TitleBox 	Dis4_PowerLaw, disable=1
			//Dist4FitScale = 0
			//Dist4FitLocation = 0
			//Dist4FitShape = 0
		endif
		if (cmpstr(popStr,"LSW")==0)
			SetVariable Dis4_shape, disable=1, win=IR1S_ControlPanel
			SetVariable Dis4_ShapeStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis4_Scale, disable=1, win=IR1S_ControlPanel
			SetVariable Dis4_Location, disable=0,title="Location  ", win=IR1S_ControlPanel
			SetVariable Dis4_ScaleStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis4_LocationStep, disable=0, win=IR1S_ControlPanel
			
			SetVariable Dis4_LocationLow,disable= (!Dist4FitLocation), win=IR1S_ControlPanel
			SetVariable Dis4_LocationHigh,disable= (!Dist4FitLocation),title="  < location <     ", win=IR1S_ControlPanel
			CheckBox Dis4_FitLocation,disable= 0,title="Fit Location?", win=IR1S_ControlPanel
			SetVariable Dis4_ScaleLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis4_ScaleHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis4_FitScale,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis4_ShapeLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis4_ShapeHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis4_FitShape,disable= 1, win=IR1S_ControlPanel

			TitleBox 	Dis4_Gauss, disable=1
			TitleBox 	Dis4_LogNormal, disable=1
			TitleBox 	Dis4_LSW, disable=0
			TitleBox 	Dis4_PowerLaw, disable=1

			Dist4FitScale = 0
			//Dist4FitLocation = 0
			Dist4FitShape = 0
		endif
		if (cmpstr(popStr,"PowerLaw")==0)
			SetVariable Dis4_shape, disable=0,title="Power slope   ", win=IR1S_ControlPanel
			SetVariable Dis4_ShapeStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis4_Scale, disable=0,title="Minimum Dia   ", win=IR1S_ControlPanel
			SetVariable Dis4_Location, disable=0,title="Maximum Dia  ", win=IR1S_ControlPanel
			SetVariable Dis4_ScaleStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis4_LocationStep, disable=1, win=IR1S_ControlPanel
			
			SetVariable Dis4_LocationLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis4_LocationHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis4_FitLocation,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis4_ScaleLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis4_ScaleHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis4_FitScale,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis4_ShapeLow,disable= 0, win=IR1S_ControlPanel
			SetVariable Dis4_ShapeHigh,disable= 0,title=" < slope < ", win=IR1S_ControlPanel
			CheckBox Dis4_FitShape,disable= 0,title="Fit slope?", win=IR1S_ControlPanel

			TitleBox 	Dis4_Gauss, disable=1
			TitleBox 	Dis4_LogNormal, disable=1
			TitleBox 	Dis4_LSW, disable=1
			TitleBox 	Dis4_PowerLaw, disable=0
			Dist4FitScale = 0
			Dist4FitLocation = 0
			//Dist4FitShape = 0
		endif
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif


	if (cmpstr(ctrlName,"Dis5_ShapePopup")==0)
		//here goes what happens when user selects shape in the panel
		//and that means, depending on the shape selected we need to get another panel with parameters
		//we have 3 universal shape parameters available for each shape type:
		//Dist5ScatShapeParam1;Dist5ScatShapeParam2;Dist5ScatShapeParam3
		if (cmpstr(popStr,"CoreShellShell")==0)
			DoALert 0,"Core-Shell-Shell FF can be used only in Modeling II, nto in Modeling I, please select another Form Factor to use here."
			popStr="Spheroid"
			Execute("PopupMenu Dis5_ShapePopup,mode=1,popvalue=\"Spheroid\" ")
		endif

		IR1S_ResetScatShapeFitParam(5)
		SetVariable Dis5_Contrast, disable=0 , win=IR1S_ControlPanel
		//kill shpheroid window if exists...
		DoWindow Shape_Model_Input_Panel
		if (V_Flag)
			DoWindow/K Shape_Model_Input_Panel
		endif
		//create new window as needed
		if (cmpstr(popStr,"spheroid")==0 || cmpstr(popStr,"Algebraic_Globules")==0 || cmpstr(popStr,"Integrated_Spheroid")==0 || cmpstr(popStr,"Unified_RodAR")==0 || cmpstr(popStr,"cylinderAR")==0)
			Execute ("Dis_Spheroid_Input_Panel(5)")
		endif
		if (cmpstr(popStr,"cylinder")==0 || cmpstr(popStr,"Algebraic_Rods")==0|| cmpstr(popStr,"Unified_Rod")==0)
			Execute ("Dis_cylinder_Panel(5)")
		endif
		if (cmpstr(popStr,"Unified_Disk")==0 || cmpstr(popStr,"Algebraic_Disks")==0)
			Execute ("Dis_Disc_Panel(5)")
		endif
		if (cmpstr(popStr,"CoreShellCylinder")==0)
			SetVariable Dis5_Contrast, disable=1, win=IR1S_ControlPanel
			Execute ("Dis_tube_Panel(5)")
		endif
		if (cmpstr(popStr,"CoreShell")==0)
			SetVariable Dis5_Contrast, disable=1, win=IR1S_ControlPanel
			Execute ("Dis_CoreShell_Input_Panel(5)")
		endif
		if (cmpstr(popStr,"Fractal Aggregate")==0)
			Execute ("Dis_FractalAgg_Input_Panel(5)")
		endif
		if (cmpstr(popStr,"User")==0)
			Execute ("Dis_UserFFInputPanel(5)")
		endif
		NewPanelCreated = WinName(0,64)
		SVAR Dist5ShapeModel=root:Packages:SAS_Modeling:Dist5ShapeModel
		Dist5ShapeModel=popStr
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		IR1S_UpdateModeMedianMean()		//modified for 5

		IR1S_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis5_DistributionType")==0)
		//here goes what happens when user selects different dist type
		SVAR Dist5DistributionType=root:Packages:SAS_Modeling:Dist5DistributionType
		NVAR Dist5FitShape=root:Packages:SAS_Modeling:Dist5FitShape
		NVAR Dist5FitLocation=root:Packages:SAS_Modeling:Dist5FitLocation
		NVAR Dist5FitScale=root:Packages:SAS_Modeling:Dist5FitScale
		Dist5DistributionType=popStr

		if (cmpstr(popStr,"Gauss")==0)
			SetVariable Dis5_shape, disable=1, win=IR1S_ControlPanel
			SetVariable Dis5_ShapeStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis5_Scale, disable=0,title="Width        ", win=IR1S_ControlPanel
			SetVariable Dis5_Location, disable=0,title="Mean size", win=IR1S_ControlPanel
			SetVariable Dis5_ScaleStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis5_LocationStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis5_LocationLow,disable= (!Dist5FitLocation), win=IR1S_ControlPanel
			SetVariable Dis5_LocationHigh,disable= (!Dist5FitLocation),title="  < Mean size < ", win=IR1S_ControlPanel
			CheckBox Dis5_FitLocation,disable= 0,title="Fit mean size?", win=IR1S_ControlPanel
			SetVariable Dis5_ScaleLow,disable= (!Dist5FitScale), win=IR1S_ControlPanel
			SetVariable Dis5_ScaleHigh,disable=(!Dist5FitScale),title="  < Width <       ", win=IR1S_ControlPanel
			CheckBox Dis5_FitScale,disable= 0,title="Fit width?", win=IR1S_ControlPanel
			SetVariable Dis5_ShapeLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis5_ShapeHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis5_FitShape,disable= 1, win=IR1S_ControlPanel
			
			TitleBox 	Dis5_Gauss, disable=0
			TitleBox 	Dis5_LogNormal, disable=1
			TitleBox 	Dis5_LSW, disable=1
			TitleBox 	Dis5_PowerLaw, disable=1
			
			//Dist5FitScale = 0
			//Dist5FitLocation = 0
			Dist5FitShape = 0
		endif
		if (cmpstr(popStr,"LogNormal")==0)
			SetVariable Dis5_shape, disable=0,title="Sdeviation  ", win=IR1S_ControlPanel
			SetVariable Dis5_ShapeStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis5_Scale, disable=0,title="Mean size", win=IR1S_ControlPanel
			SetVariable Dis5_Location, disable=0,title="Min size  ", win=IR1S_ControlPanel
			SetVariable Dis5_ScaleStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis5_LocationStep, disable=0, win=IR1S_ControlPanel

			SetVariable Dis5_LocationLow,disable= (!Dist5FitLocation), win=IR1S_ControlPanel
 			SetVariable Dis5_LocationHigh,disable= (!Dist5FitLocation),title="  < Min. size <   ", win=IR1S_ControlPanel
			CheckBox Dis5_FitLocation,disable= 0,title="Fit min. size?", win=IR1S_ControlPanel
			SetVariable Dis5_ScaleLow,disable=(!Dist5FitScale), win=IR1S_ControlPanel
			SetVariable Dis5_ScaleHigh,disable= (!Dist5FitScale),title="  < Mean size < ", win=IR1S_ControlPanel
			CheckBox Dis5_FitScale,disable= 0,title="Fit mean size?", win=IR1S_ControlPanel
			SetVariable Dis5_ShapeLow,disable= (!Dist5FitShape), win=IR1S_ControlPanel
			SetVariable Dis5_ShapeHigh,disable=(!Dist5FitShape),title=" < Sdeviation < ", win=IR1S_ControlPanel
			CheckBox Dis5_FitShape,disable= 0,title="Fit Sdev.?", win=IR1S_ControlPanel

			TitleBox 	Dis5_Gauss, disable=1
			TitleBox 	Dis5_LogNormal, disable=0
			TitleBox 	Dis5_LSW, disable=1
			TitleBox 	Dis5_PowerLaw, disable=1
			//Dist5FitScale = 0
			//Dist5FitLocation = 0
			//Dist5FitShape = 0
		endif
		if (cmpstr(popStr,"LSW")==0)
			SetVariable Dis5_shape, disable=1, win=IR1S_ControlPanel
			SetVariable Dis5_ShapeStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis5_Scale, disable=1, win=IR1S_ControlPanel
			SetVariable Dis5_Location, disable=0,title="Location  ", win=IR1S_ControlPanel
			SetVariable Dis5_ScaleStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis5_LocationStep, disable=0, win=IR1S_ControlPanel
			
			SetVariable Dis5_LocationLow,disable= (!Dist5FitLocation), win=IR1S_ControlPanel
			SetVariable Dis5_LocationHigh,disable= (!Dist5FitLocation),title="  < location <     ", win=IR1S_ControlPanel
			CheckBox Dis5_FitLocation,disable= 0,title="Fit Location?", win=IR1S_ControlPanel
			SetVariable Dis5_ScaleLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis5_ScaleHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis5_FitScale,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis5_ShapeLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis5_ShapeHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis5_FitShape,disable= 1, win=IR1S_ControlPanel

			TitleBox 	Dis5_Gauss, disable=1
			TitleBox 	Dis5_LogNormal, disable=1
			TitleBox 	Dis5_LSW, disable=0
			TitleBox 	Dis5_PowerLaw, disable=1

			Dist5FitScale = 0
			//Dist5FitLocation = 0
			Dist5FitShape = 0
		endif
		if (cmpstr(popStr,"PowerLaw")==0)
			SetVariable Dis5_shape, disable=0,title="Power slope   ", win=IR1S_ControlPanel
			SetVariable Dis5_ShapeStep, disable=0, win=IR1S_ControlPanel
			SetVariable Dis5_Scale, disable=0,title="Minimum Dia   ", win=IR1S_ControlPanel
			SetVariable Dis5_Location, disable=0,title="Maximum Dia  ", win=IR1S_ControlPanel
			SetVariable Dis5_ScaleStep, disable=1, win=IR1S_ControlPanel
			SetVariable Dis5_LocationStep, disable=1, win=IR1S_ControlPanel
			
			SetVariable Dis5_LocationLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis5_LocationHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis5_FitLocation,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis5_ScaleLow,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis5_ScaleHigh,disable= 1, win=IR1S_ControlPanel
			CheckBox Dis5_FitScale,disable= 1, win=IR1S_ControlPanel
			SetVariable Dis5_ShapeLow,disable= 0, win=IR1S_ControlPanel
			SetVariable Dis5_ShapeHigh,disable= 0,title=" < slope < ", win=IR1S_ControlPanel
			CheckBox Dis5_FitShape,disable= 0,title="Fit slope?", win=IR1S_ControlPanel

			TitleBox 	Dis5_Gauss, disable=1
			TitleBox 	Dis5_LogNormal, disable=1
			TitleBox 	Dis5_LSW, disable=1
			TitleBox 	Dis5_PowerLaw, disable=0
			Dist5FitScale = 0
			Dist5FitLocation = 0
			//Dist5FitShape = 0
		endif
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	setDataFolder oldDF
	DoWIndow/F IR1S_ControlPanel
	if(strlen(NewPanelCreated)>0)
		DoWindow/F  $NewPanelCreated 
	endif
End



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1S_ResetScatShapeFitParam(which)
		variable which 
		
		NVAR FitShape1=$("root:Packages:SAS_Modeling:Dist"+num2str(which)+"FitScatShapeParam1")
		NVAR FitShape2=$("root:Packages:SAS_Modeling:Dist"+num2str(which)+"FitScatShapeParam3")
		NVAR FitShape3=$("root:Packages:SAS_Modeling:Dist"+num2str(which)+"FitScatShapeParam2")
		
		FitShape1=0
		FitShape2=0
		FitShape3=0
end


//*****************************************************************************************************************
//*****************************************************************************************************************


Window Dis_UserFFInputPanel(which) 
	Variable which
	
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(306,271,666,604) as "Shape_Model_Input_Panel"
	DoWindow/C Shape_Model_Input_Panel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,0,65280)
	DrawText 31,28,"User form factor for population "+num2str(which)
	DrawText 11,55,"These are parameters for user defined form factor"
	DrawText 11,73,"The meaning and need for them depends"
	DrawText 11,92," on user function, set only the used ones"
	Button GetHelp,pos={55,104},size={120,20},proc=IR1S_UserFFButtonProc,title="Get Help"
	SetVariable FormFactorFunction,pos={6,140},size={350,16},title="Form Factor fnct: "
	SetVariable FormFactorFunction,help={"Name (as string), no quotes, no \"()\" of the form factor function"}
	SetVariable FormFactorFunction,value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"UserFormFactorFnct")
	SetVariable VolumeOfFormFactorFnct,pos={6,167},size={350,16},title="Volume fnct:        "
	SetVariable VolumeOfFormFactorFnct,help={"Name (as string), no quotes, no \"()\" of the volume function for form factor"}
	SetVariable VolumeOfFormFactorFnct,value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"UserVolumeFnct")
	SetVariable UserParam1,pos={46,194},size={250,16},title="Param1       "
	SetVariable UserParam1, help={"First parameter (in order) for the form factor and volume USER function"}
	SetVariable UserParam1,value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"UserFFParam1")
	SetVariable UserParam2,pos={46,221},size={250,16},title="Param2       "
	SetVariable UserParam2,value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"UserFFParam2")
	SetVariable UserParam2, help={"Second parameter (in order) for the form factor and volume USER function"}
	SetVariable UserParam3,pos={46,248},size={250,16},title="Param3       "
	SetVariable UserParam3,value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"UserFFParam3")
	SetVariable UserParam3, help={"Third parameter (in order) for the form factor and volume USER function"}
	SetVariable UserParam4,pos={46,275},size={250,16},title="Param4       "
	SetVariable UserParam4,value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"UserFFParam4")
	SetVariable UserParam4, help={"Fourth parameter (in order) for the form factor and volume USER function"}
	SetVariable UserParam5,pos={46,303},size={250,16},title="Param5       "
	SetVariable UserParam5,value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"UserFFParam5")
	SetVariable UserParam5, help={"Fifth parameter (in order) for the form factor and volume USER function"}
EndMacro

Function IR1S_UserFFButtonProc(ctrlName) : ButtonControl
	String ctrlName
	if(cmpstr(ctrlName,"GetHelp")==0)
		//call the help notebook
		IR1T_GenerateHelpForUserFF()
	endif
End



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Window Dis_cylinder_Panel(Which) 
	Variable Which
	
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(189,124.25,417.75,266.75) as "Shape_Model_Input_Panel"
	DoWindow/C Shape_Model_Input_Panel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 4,19,"Parameters for scatterer shape"
	DrawText 10,42,"Distribution "+num2str(Which)+", cylinder or rod"
	DrawText 10,57,"Input length of cylinder/disc [A]"
	DrawText 10,105,"This parameters cannot be fitted"
	SetVariable DisCylinderLength,pos={5,117},size={180,16},title="Cylinder/Rod length"
	SetVariable DisCylinderLength,limits={0.01,Inf,0.1},value= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"ScatShapeParam1")
EndMacro

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Window Dis_Disc_Panel(Which) 
	Variable Which
	
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(189,124.25,417.75,266.75) as "Shape_Model_Input_Panel"
	DoWindow/C Shape_Model_Input_Panel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 4,19,"Parameters for scatterer shape"
	DrawText 10,42,"Distribution "+num2str(Which)+", disc"
	DrawText 10,57,"Thickness of the disc [A]"
	DrawText 10,105,"This parameter cannot be fitted"
	SetVariable DisCylinderLength,pos={23,117},size={180,16},title="Thickness [A]"
	SetVariable DisCylinderLength,limits={0.01,Inf,0.1},value= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"ScatShapeParam1")
EndMacro
//10

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function Dis_tube_Panel(Which) 
	Variable Which
	
	//PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(189,124.25,630,400) as "Shape_Model_Input_Panel"
	DoWindow/C Shape_Model_Input_Panel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 4,19,"Parameters for scatterer shape"
	DrawText 10,42,"Distribution "+num2str(Which)+", Core shell cylinder"
	DrawText 15,57,"Input length of cylinder [A]"
	DrawText 15,72,"Wall thickness of the cylinder [A]"
	DrawText 15,87,"Rho for the materials involved. Air (solvent)~0  [cm-2]"
	SetVariable DisTubeLength,pos={10,120},size={160,16},title="Cylinder length", help={"Input length of the tube/cylinder in A"}
	SetVariable DisTubeLength,limits={0.01,Inf,0.1},value= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"ScatShapeParam1")
	Checkbox FitTubeLength,pos={190,120}, title="Fit?", variable= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"FitScatShapeParam1")
	SetVariable DisTubeLengthLowLimit,pos={230,120},size={80,16},title="Min.", help={"Input low llimit for tube length"}
	SetVariable DisTubeLengthLowLimit,limits={1,Inf,0},value= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"ScatShapeParam1LowLimit")
	SetVariable DisTubeLengthHighLimit,pos={320,120},size={80,16},title="Max.", help={"Input high limit for tube length"}
	SetVariable DisTubeLengthHighLimit,limits={1,Inf,0},value= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"ScatShapeParam1HighLimit")

	SetVariable DisTubeWall,pos={10,145},size={160,16},title="Wall thickness [A]", help={"Wall thickness of the tube in A"}
	SetVariable DisTubeWall,limits={0.01,Inf,0.1},value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"ScatShapeParam2")
	Checkbox FitTubeWall,pos={190,145}, title="Fit?", variable= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"FitScatShapeParam2")
	SetVariable DisTubeWallLowLimit,pos={230,145},size={80,16},title="Min.", help={"Input low limit for tube wall thickness"}
	SetVariable DisTubeWallLowLimit,limits={1,Inf,0},value= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"ScatShapeParam2LowLimit")
	SetVariable DisTubeWallHighLimit,pos={320,145},size={80,16},title="Max.", help={"Input high limit for tube length"}
	SetVariable DisTubeWallHighLimit,limits={1,Inf,0},value= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"ScatShapeParam2HighLimit")
//	SetVariable DisTubeWallSpread,pos={10,165},size={160,16},title="Wall spread fract.", help={"Wall thickness variation fractional (suggest 0.2 - 0.8)"}
//	SetVariable DisTubeWallSpread,limits={0.01,Inf,0.1},value= $("root:Packages:SAS_Modeling:WallThicknessSpreadInFract")
	

	SetVariable DisSpheroidCoreRho,pos={10,175},size={240,16},title="Core rho   [10^10 cm-2]      "
	SetVariable DisSpheroidCoreRho,limits={-inf,Inf,0.1},value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"ScatShapeParam3")
	SetVariable DisSpheroidshellRho,pos={10,195},size={240,16},title="Shell rho    [10^10 cm-2]    "
	SetVariable DisSpheroidShellRho,limits={-inf,Inf,0.1},value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"ScatShapeParam4")
	SetVariable DisSpheroidSolvntRho,pos={10,215},size={240,16},title="Slovent rho   [10^10 cm-2]    "
	SetVariable DisSpheroidSolvntRho,limits={-inf,Inf,0.1},value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"ScatShapeParam5")

	SVAR CoreShellVolumeDefinition=root:Packages:FormFactorCalc:CoreShellVolumeDefinition

	PopupMenu CoreShellVolumeDefinition,pos={20,250},size={180,21},proc=IR1T_FFPanelPopupControl,title="Volume definition:    ", help={"Select what you consider volume of particle"}
	PopupMenu CoreShellVolumeDefinition,mode=1,popvalue=stringFromList(WhichListItem(CoreShellVolumeDefinition, "Whole particle;Core;Shell;" ),"Whole particle;Core;Shell;"),value= "Whole particle;Core;Shell;"

EndMacro
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function Dis_Unitube_Panel(Which) 
	Variable Which
	
//	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(189,124.25,630,380) as "Shape_Model_Input_Panel"
	DoWindow/C Shape_Model_Input_Panel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 4,19,"Parameters for scatterer shape"
	DrawText 10,42,"Distribution "+num2str(Which)+", Unified tube (Core shell cylinder)"
	DrawText 15,57,"Input length of tube [A]"
	DrawText 15,72,"Wall thickness of the tube [A]"
	SetVariable DisTubeLength,pos={10,120},size={160,16},title="Tube length", help={"Input length of the tube/cylinder in A"}
	SetVariable DisTubeLength,limits={0.01,Inf,0.1},value= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"ScatShapeParam1")
	Checkbox FitTubeLength,pos={190,120}, title="Fit?", variable= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"FitScatShapeParam1")
	SetVariable DisTubeLengthLowLimit,pos={230,120},size={80,16},title="Min.", help={"Input low llimit for tube length"}
	SetVariable DisTubeLengthLowLimit,limits={1,Inf,0},value= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"ScatShapeParam1LowLimit")
	SetVariable DisTubeLengthHighLimit,pos={320,120},size={80,16},title="Max.", help={"Input high limit for tube length"}
	SetVariable DisTubeLengthHighLimit,limits={1,Inf,0},value= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"ScatShapeParam1HighLimit")

	SetVariable DisTubeWall,pos={10,145},size={160,16},title="Wall thickness [A]", help={"Wall thickness of the tube in A"}
	SetVariable DisTubeWall,limits={0.01,Inf,0.1},value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"ScatShapeParam2")
	Checkbox FitTubeWall,pos={190,145}, title="Fit?", variable= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"FitScatShapeParam2")
	SetVariable DisTubeWallLowLimit,pos={230,145},size={80,16},title="Min.", help={"Input low limit for tube wall thickness"}
	SetVariable DisTubeWallLowLimit,limits={1,Inf,0},value= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"ScatShapeParam2LowLimit")
	SetVariable DisTubeWallHighLimit,pos={320,145},size={80,16},title="Max.", help={"Input high limit for tube length"}
	SetVariable DisTubeWallHighLimit,limits={1,Inf,0},value= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"ScatShapeParam2HighLimit")

EndMacro



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Window Dis_Spheroid_Input_Panel(Which) 
	Variable Which
	
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(189,124.25,417.75,266.75) as "Shape_Model_Input_Panel"
	DoWindow/C Shape_Model_Input_Panel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 4,19,"Parameters for scatterer shape"
	DrawText 10,42,"Distribution "+num2str(Which)+", spheroid, glob, etc."
	DrawText 10,57,"Input aspect ratio A"
	DrawText 10,73,"A < 1 = oblate shape"
	DrawText 10,89,"A > 1 = prolate shape"
	DrawText 10,105,"This parameter cannot be fitted"
	SetVariable DisSpheroidAR,pos={23,117},size={180,16},title="Aspect ratio"
	SetVariable DisSpheroidAR,limits={0.01,Inf,0.1},value= $("root:Packages:SAS_Modeling:Dist"+num2str(Which)+"ScatShapeParam1")
EndMacro


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Window Dis_CoreShell_Input_Panel(Which) 
	Variable which
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(189,124.25,485.25,360) as "Shape_Model_Input_Panel"
	DoWindow/C Shape_Model_Input_Panel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 10,29,"Parameters for CoreShell shape"
	DrawText 10,51,"Distribution "+num2str(which)+", CoreShell"
	DrawText 10,68,"Input shell thickness in Angstroems"
	DrawText 10,85,"Input Rho for each material. Air(solvent) ~ 0 [cm-2]"
	DrawText 10,103,"These parameters cannot be fitted"
	SetVariable DisSpheroidAR,pos={10,115},size={240,16},title="Shell thicknes [A]       "
	SetVariable DisSpheroidAR,limits={0.01,Inf,0.01},value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"ScatShapeParam1")
	SetVariable DisSpheroidCoreRho,pos={10,135},size={240,16},title="Core rho  [10^10 cm-2]       "
	SetVariable DisSpheroidCoreRho,limits={-inf,Inf,0.1},value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"ScatShapeParam2")
	SetVariable DisSpheroidshellRho,pos={10,155},size={240,16},title="Shell rho   [10^10 cm-2]      "
	SetVariable DisSpheroidShellRho,limits={-inf,Inf,0.1},value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"ScatShapeParam3")
	SetVariable DisSpheroidSolvntRho,pos={10,175},size={240,16},title="Solvent rho   [10^10 cm-2]  "
	SetVariable DisSpheroidSolvntRho,limits={-inf,Inf,0.1},value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"ScatShapeParam4")
	
//	SVAR CoreShellVolumeDefinition=root:Packages:FormFactorCalc:CoreShellVolumeDefinition

	PopupMenu CoreShellVolumeDefinition,pos={20,200},size={180,21},proc=IR1T_FFPanelPopupControl,title="Volume definition:    ", help={"Select what you consider volume of particle"}
	PopupMenu CoreShellVolumeDefinition,mode=1,popvalue=stringFromList(WhichListItem(root:Packages:FormFactorCalc:CoreShellVolumeDefinition, "Whole particle;Core;Shell;" ),"Whole particle;Core;Shell;"),value= "Whole particle;Core;Shell;"
endMacro


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Window Dis_FractalAgg_Input_Panel(Which) 
	Variable which
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(189,124.25,485.25,299.75) as "Shape_Model_Input_Panel"
	DoWindow/C Shape_Model_Input_Panel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 38,29,"Parameters for Fractal Aggregate"
	DrawText 34,51,"Distribution "+num2str(which)+", Fractal Aggregate"
	DrawText 34,68,"Input primary particle hard radius r0"
	DrawText 34,85,"Input fractal dimension D"
	DrawText 61,103,"These parameters cannot be fitted"
	SetVariable DisHardRadius,pos={38,117},size={200,16},title="Primary particle hard radius"
	SetVariable DisHardRadius,limits={0,Inf,1},value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"ScatShapeParam1")
	SetVariable DisFractalDimension,pos={38,140},size={200,16},title="Fractal dimension"
	SetVariable DisFractalDimension,limits={1,Inf,0.1},value= $("root:Packages:SAS_Modeling:Dist"+num2str(which)+"ScatShapeParam2")
endMacro

//Window Dis1_CoreShell_Input_Panel() 
//	PauseUpdate; Silent 1		// building window...
//	NewPanel /K=1 /W=(189,124.25,485.25,299.75) as "Shape_Model_Input_Panel"
//	DoWindow/C Shape_Model_Input_Panel
//	SetDrawLayer UserBack
//	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
//	DrawText 38,29,"Parameters for CoreShell shape"
//	DrawText 82,51,"Distribution 1, CoreShell"
//	DrawText 34,68,"Input ratio of shell thickness to core diameter"
//	DrawText 34,85,"Input ratio of shell contrast to core contrast"
//	DrawText 61,103,"This parameters cannot be fitted"
//	SetVariable Dis1SpheroidAR,pos={38,117},size={200,16},title="Shell thickn -to-Core diameter ratio"
//	SetVariable Dis1SpheroidAR,limits={0.01,Inf,0.01},value= root:Packages:SAS_Modeling:Dist1ScatShapeParam1
//	SetVariable Dis1SpheroidCntr,pos={38,140},size={200,16},title="Shell-to-Core contrast ratio"
//	SetVariable Dis1SpheroidCntr,limits={0.01,Inf,0.1},value= root:Packages:SAS_Modeling:Dist1ScatShapeParam2
//endMacro
//Window Dis2_CoreShell_Input_Panel() 
//	PauseUpdate; Silent 1		// building window...
//	NewPanel /K=1 /W=(189,124.25,485.25,299.75) as "Shape_Model_Input_Panel"
//	DoWindow/C Shape_Model_Input_Panel
//	SetDrawLayer UserBack
//	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
//	DrawText 38,29,"Parameters for CoreShell shape"
//	DrawText 82,51,"Distribution 2, CoreShell"
//	DrawText 34,68,"Input ratio of shell thickness to core diameter"
//	DrawText 34,85,"Input ratio of shell contrast to core contrast"
//	DrawText 61,103,"This parameters cannot be fitted"
//	SetVariable Dis2SpheroidAR,pos={38,117},size={200,16},title="Shell thickn -to-Core diameter ratio"
//	SetVariable Dis2SpheroidAR,limits={0.01,Inf,0.01},value= root:Packages:SAS_Modeling:Dist2ScatShapeParam1
//	SetVariable Dis2SpheroidCntr,pos={38,140},size={200,16},title="Shell-to-Core contrast ratio"
//	SetVariable Dis2SpheroidCntr,limits={0.01,Inf,0.1},value= root:Packages:SAS_Modeling:Dist2ScatShapeParam2
//endMacro
//Window Dis3_CoreShell_Input_Panel() 
//	PauseUpdate; Silent 1		// building window...
//	NewPanel /K=1 /W=(189,124.25,485.25,299.75) as "Shape_Model_Input_Panel"
//	DoWindow/C Shape_Model_Input_Panel
//	SetDrawLayer UserBack
//	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
//	DrawText 38,29,"Parameters for CoreShell shape"
//	DrawText 82,51,"Distribution 3, CoreShell"
//	DrawText 34,68,"Input ratio of shell thickness to core diameter"
//	DrawText 34,85,"Input ratio of shell contrast to core contrast"
//	DrawText 61,103,"This parameters cannot be fitted"
//	SetVariable Dis3SpheroidAR,pos={38,117},size={200,16},title="Shell thickn -to-Core diameter ratio"
//	SetVariable Dis3SpheroidAR,limits={0.01,Inf,0.01},value= root:Packages:SAS_Modeling:Dist3ScatShapeParam1
//	SetVariable Dis3SpheroidCntr,pos={38,140},size={200,16},title="Shell-to-Core contrast ratio"
//	SetVariable Dis3SpheroidCntr,limits={0.01,Inf,0.1},value= root:Packages:SAS_Modeling:Dist3ScatShapeParam2
//endMacro
//Window Dis4_CoreShell_Input_Panel() 
//	PauseUpdate; Silent 1		// building window...
//	NewPanel /K=1 /W=(189,124.25,485.25,299.75) as "Shape_Model_Input_Panel"
//	DoWindow/C Shape_Model_Input_Panel
//	SetDrawLayer UserBack
//	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
//	DrawText 38,29,"Parameters for CoreShell shape"
//	DrawText 82,51,"Distribution 4, CoreShell"
//	DrawText 34,68,"Input ratio of shell thickness to core diameter"
//	DrawText 34,85,"Input ratio of shell contrast to core contrast"
//	DrawText 61,103,"This parameters cannot be fitted"
//	SetVariable Dis4SpheroidAR,pos={38,117},size={200,16},title="Shell thickn -to-Core diameter ratio"
//	SetVariable Dis4SpheroidAR,limits={0.01,Inf,0.01},value= root:Packages:SAS_Modeling:Dist4ScatShapeParam1
//	SetVariable Dis4SpheroidCntr,pos={38,140},size={200,16},title="Shell-to-Core contrast ratio"
//	SetVariable Dis4SpheroidCntr,limits={0.01,Inf,0.1},value= root:Packages:SAS_Modeling:Dist4ScatShapeParam2
//endMacro
//Window Dis5_CoreShell_Input_Panel() 
//	PauseUpdate; Silent 1		// building window...
//	NewPanel /K=1 /W=(189,124.25,485.25,299.75) as "Shape_Model_Input_Panel"
//	DoWindow/C Shape_Model_Input_Panel
//	SetDrawLayer UserBack
//	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
//	DrawText 38,29,"Parameters for CoreShell shape"
//	DrawText 82,51,"Distribution 5, CoreShell"
//	DrawText 34,68,"Input ratio of shell thickness to core diameter"
//	DrawText 34,85,"Input ratio of shell contrast to core contrast"
//	DrawText 61,103,"This parameters cannot be fitted"
//	SetVariable Dis5SpheroidAR,pos={38,117},size={200,16},title="Shell thickn -to-Core diameter ratio"
//	SetVariable Dis5SpheroidAR,limits={0.01,Inf,0.01},value= root:Packages:SAS_Modeling:Dist5ScatShapeParam1
//	SetVariable Dis5SpheroidCntr,pos={38,140},size={200,16},title="Shell-to-Core contrast ratio"
//	SetVariable Dis5SpheroidCntr,limits={0.01,Inf,0.1},value= root:Packages:SAS_Modeling:Dist5ScatShapeParam2
//endMacro




//Window Dis1_Spheroid_Input_Panel() 
//	PauseUpdate; Silent 1		// building window...
//	NewPanel/K=1 /W=(189,124.25,417.75,266.75) as "Shape_Model_Input_Panel"
//	DoWindow/C Shape_Model_Input_Panel
//	SetDrawLayer UserBack
//	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
//	DrawText 4,19,"Parameters for scatterer shape"
//	DrawText 49,42,"Distribution 1, spheroid"
//	DrawText 61,57,"Input aspect ratio A"
//	DrawText 57,73,"A < 1 = oblate shape"
//	DrawText 55,89,"A > 1 = prolate shape"
//	DrawText 25,105,"This parameters cannot be fitted"
//	SetVariable Dis1SpheroidAR,pos={23,117},size={180,16},title="Spheroid aspect ratio"
//	SetVariable Dis1SpheroidAR,limits={0.01,Inf,0.1},value= root:Packages:SAS_Modeling:Dist1ScatShapeParam1
//EndMacro
//Window Dis2_Spheroid_Input_Panel() 
//	PauseUpdate; Silent 1		// building window...
//	NewPanel/K=1 /W=(189,124.25,417.75,266.75) as "Shape_Model_Input_Panel"
//	DoWindow/C Shape_Model_Input_Panel
//	SetDrawLayer UserBack
//	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
//	DrawText 4,19,"Parameters for scatterer shape"
//	DrawText 49,42,"Distribution 2, spheroid"
//	DrawText 61,57,"Input aspect ratio A"
//	DrawText 57,73,"A < 1 = oblate shape"
//	DrawText 55,89,"A > 1 = prolate shape"
//	DrawText 25,105,"This parameters cannot be fitted"
//	SetVariable Dis2SpheroidAR,pos={23,117},size={180,16},title="Spheroid aspect ratio"
//	SetVariable Dis2SpheroidAR,limits={0.01,Inf,0.1},value= root:Packages:SAS_Modeling:Dist2ScatShapeParam1
//EndMacro
//Window Dis3_Spheroid_Input_Panel() 
//	PauseUpdate; Silent 1		// building window...
//	NewPanel/K=1 /W=(189,124.25,417.75,266.75) as "Shape_Model_Input_Panel"
//	DoWindow/C Shape_Model_Input_Panel
//	SetDrawLayer UserBack
//	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
//	DrawText 4,19,"Parameters for scatterer shape"
//	DrawText 49,42,"Distribution 3, spheroid"
//	DrawText 61,57,"Input aspect ratio A"
//	DrawText 57,73,"A < 1 = oblate shape"
//	DrawText 55,89,"A > 1 = prolate shape"
//	DrawText 25,105,"This parameters cannot be fitted"
//	SetVariable Dis3SpheroidAR,pos={23,117},size={180,16},title="Spheroid aspect ratio"
//	SetVariable Dis3SpheroidAR,limits={0.01,Inf,0.1},value= root:Packages:SAS_Modeling:Dist3ScatShapeParam1
//EndMacro
//Window Dis4_Spheroid_Input_Panel() 
//	PauseUpdate; Silent 1		// building window...
//	NewPanel/K=1 /W=(189,124.25,417.75,266.75) as "Shape_Model_Input_Panel"
//	DoWindow/C Shape_Model_Input_Panel
//	SetDrawLayer UserBack
//	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
//	DrawText 4,19,"Parameters for scatterer shape"
//	DrawText 49,42,"Distribution 4, spheroid"
//	DrawText 61,57,"Input aspect ratio A"
//	DrawText 57,73,"A < 1 = oblate shape"
//	DrawText 55,89,"A > 1 = prolate shape"
//	DrawText 25,105,"This parameters cannot be fitted"
//	SetVariable Dis4SpheroidAR,pos={23,117},size={180,16},title="Spheroid aspect ratio"
//	SetVariable Dis4SpheroidAR,limits={0.01,Inf,0.1},value= root:Packages:SAS_Modeling:Dist4ScatShapeParam1
//EndMacro
//Window Dis5_Spheroid_Input_Panel() 
//	PauseUpdate; Silent 1		// building window...
//	NewPanel/K=1 /W=(189,124.25,417.75,266.75) as "Shape_Model_Input_Panel"
//	DoWindow/C Shape_Model_Input_Panel
//	SetDrawLayer UserBack
//	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
//	DrawText 4,19,"Parameters for scatterer shape"
//	DrawText 49,42,"Distribution 5, spheroid"
//	DrawText 61,57,"Input aspect ratio A"
//	DrawText 57,73,"A < 1 = oblate shape"
//	DrawText 55,89,"A > 1 = prolate shape"
//	DrawText 25,105,"This parameters cannot be fitted"
//	SetVariable Dis5SpheroidAR,pos={23,117},size={180,16},title="Spheroid aspect ratio"
//	SetVariable Dis5SpheroidAR,limits={0.01,Inf,0.1},value= root:Packages:SAS_Modeling:Dist5ScatShapeParam1
//EndMacro



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1S_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling
	

	if (cmpstr(ctrlName,"DrawGraphs")==0)
		//here goes what is done, when user pushes Graph button
		SVAR DFloc=root:Packages:SAS_Modeling:DataFolderName
		SVAR DFInt=root:Packages:SAS_Modeling:IntensityWaveName
		SVAR DFQ=root:Packages:SAS_Modeling:QWaveName
		SVAR DFE=root:Packages:SAS_Modeling:ErrorWaveName
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
			//set the slit smeared data in case of Indra2 data set, else leave alone - could be qrs slit smeared 
			NVAR UseIndra2Data=root:Packages:SAS_Modeling:UseIndra2Data
			if(UseIndra2Data)
				NVAR UseSlitSmearedData=root:Packages:SAS_Modeling:UseSlitSmearedData
				if(stringmatch(DFInt, "*SMR_Int"))
					UseSlitSmearedData=1
				else
					UseSlitSmearedData=0
				endif
				SetVariable SlitLength disable=!(UseSlitSmearedData), win=IR1S_ControlPanel
			endif
			
			IR1_GraphMeasuredData("LSQF")
			IR1S_RecoverOldParameters() //mostly done...
			IR1S_FixTabsInPanel()		//not done yet
		//	NVAR ActiveTab=root:Packages:SAS_Modeling:ActiveTab	//do I need this?
			IR1S_AutoUpdateIfSelected()
		else
			Abort "Data not selected properly"
		endif
	endif

	if(cmpstr(ctrlName,"DoFitting")==0)
		//here we call the fitting routine
		IR1S_ConstructTheFittingCommand()
	endif
	if(cmpstr(ctrlName,"RevertFitting")==0)
		//here we call the fitting routine
		IR1S_ResetParamsAfterBadFit()
		IR1_GraphModelData()
	endif
	
	if(cmpstr(ctrlName,"GraphDistribution")==0)
		//here we graph the distribution
		IR1_GraphModelData()
	endif
	if(cmpstr(ctrlName,"CopyToFolder")==0)
		//here we copy final data back to original data folder		I	
		IR1_CopyDataBackToFolder("standard")
	//	DoAlert 0,"Copy"
	endif
	
	if(cmpstr(ctrlName,"ExportData")==0)
		//here we export ASCII form of the data
		IR1_ExportASCIIResults("standard")

	//	DoAlert 0, "Export"
	endif

	setDataFolder oldDf
	DoWIndow/F IR1S_ControlPanel
end


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

Function IR1S_TabPanelControl(name,tab)
	String name
	Variable tab

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling

	NVAR CurrentTab=root:Packages:SAS_Modeling:CurrentTab
	CurrentTab=tab
	NVAR Nmbdist=root:Packages:SAS_Modeling:NumberOfDistributions
	if (cmpstr(name,"doNotKillShapePanel")!=0)
		//need to kill any outstanding windows for shapes... ANy... All should have the same name...
		DoWindow Shape_Model_Input_Panel
		if (V_Flag)
			DoWindow/K Shape_Model_Input_Panel
		endif	
	endif

	variable Dis1_NumOfParam, Dis1_EquationType, Dis1_HideLocation
	SVAR Dist1DistributionType=root:Packages:SAS_Modeling:Dist1DistributionType
	if (cmpstr(Dist1DistributionType,"LSW")==0)
		Dis1_NumOfParam=1
		Dis1_EquationType=3
		Dis1_HideLocation=0
		SetVariable Dis1_Location,title="Location  ", win=IR1S_ControlPanel
		SetVariable Dis1_LocationHigh,title="  < location <     ", win=IR1S_ControlPanel
		CheckBox Dis1_FitLocation,title="Fit Location?", win=IR1S_ControlPanel
	endif
	if (cmpstr(Dist1DistributionType,"Gauss")==0)
		Dis1_NumOfParam=2
		Dis1_EquationType=2
		Dis1_HideLocation=0
		SetVariable Dis1_Location,title="Mean size", win=IR1S_ControlPanel
		SetVariable Dis1_scale,title="Width        ", win=IR1S_ControlPanel
		SetVariable Dis1_LocationHigh,title="  < Mean size < ", win=IR1S_ControlPanel
		SetVariable Dis1_ScaleHigh,title="  < Width <       ", win=IR1S_ControlPanel
		CheckBox Dis1_FitLocation,title="Fit mean size?", win=IR1S_ControlPanel
		CheckBox Dis1_FitScale,title="Fit width?", win=IR1S_ControlPanel
	endif
	if (cmpstr(Dist1DistributionType,"LogNormal")==0)
		Dis1_NumOfParam=3
		Dis1_EquationType=1
		Dis1_HideLocation=0
		SetVariable Dis1_Location,title="Min size  ", win=IR1S_ControlPanel
		SetVariable Dis1_scale,title="Mean size", win=IR1S_ControlPanel
		SetVariable Dis1_shape,title="Sdeviation  ", win=IR1S_ControlPanel
		SetVariable Dis1_LocationHigh,title="  < Min. size <   ", win=IR1S_ControlPanel
		SetVariable Dis1_ScaleHigh,title="  < Mean size < ", win=IR1S_ControlPanel
		SetVariable Dis1_ShapeHigh,title=" < Sdeviation < ", win=IR1S_ControlPanel
		CheckBox Dis1_FitLocation,title="Fit min. size?", win=IR1S_ControlPanel
		CheckBox Dis1_FitScale,title="Fit mean size?", win=IR1S_ControlPanel
		CheckBox Dis1_FitShape,title="Fit Sdev.?", win=IR1S_ControlPanel
	endif
	if (cmpstr(Dist1DistributionType,"PowerLaw")==0)
		Dis1_NumOfParam=3
		Dis1_EquationType=4
		Dis1_HideLocation=1
		SetVariable Dis1_Location,title="Maximum Dia  ", win=IR1S_ControlPanel
		SetVariable Dis1_scale,title="Minimum Dia   ", win=IR1S_ControlPanel
		SetVariable Dis1_shape,title="Power slope   ", win=IR1S_ControlPanel //// , MaxDia =loc, MinDia = scale
//		SetVariable Dis1_LocationHigh,title="  < Max. dia <   ", win=IR1S_ControlPanel
//		SetVariable Dis1_ScaleHigh,title="  < Min dia < ", win=IR1S_ControlPanel
		SetVariable Dis1_ShapeHigh,title=" < slope < ", win=IR1S_ControlPanel
//		CheckBox Dis1_FitLocation,title="Fit max. dia.?", win=IR1S_ControlPanel
//		CheckBox Dis1_FitScale,title="Fit min. dia.?", win=IR1S_ControlPanel
		CheckBox Dis1_FitShape,title="Fit slope?", win=IR1S_ControlPanel
	endif
	NVAR Dist1FitVol=root:Packages:SAS_Modeling:Dist1FitVol
	NVAR Dist1FitShape=root:Packages:SAS_Modeling:Dist1FitShape
	NVAR Dist1FitLocation=root:Packages:SAS_Modeling:Dist1FitLocation
	NVAR Dist1FitScale=root:Packages:SAS_Modeling:Dist1FitScale
	
	SetVariable Dis1_VolumeLow, disable= (tab!=0 || Nmbdist<1 || !Dist1FitVol), win=IR1S_ControlPanel
	SetVariable Dis1_VolumeHigh, disable= (tab!=0 || Nmbdist<1 || !Dist1FitVol), win=IR1S_ControlPanel
	SetVariable Dis1_NegligibleFraction, disable= (tab!=0 || Nmbdist<1), win=IR1S_ControlPanel
	SetVariable Dis1_NumberOfPointsInDis, disable= (tab!=0 || Nmbdist<1), win=IR1S_ControlPanel
	SetVariable Dis1_FWHM, disable= (tab!=0 || Nmbdist<1), win=IR1S_ControlPanel
	CheckBox Dis1_FitVolume, disable= (tab!=0 || Nmbdist<1), win=IR1S_ControlPanel

	SetVariable Dis1_Volume, disable= (tab!=0 || Nmbdist<1), win=IR1S_ControlPanel
	PopupMenu Dis1_ShapePopup,disable= (tab!=0 || Nmbdist<1), win=IR1S_ControlPanel
	SVAR Dist1ShapeModel=root:Packages:SAS_Modeling:Dist1ShapeModel
	SetVariable Dis1_Contrast,disable= (tab!=0 || Nmbdist<1 || cmpstr(Dist1ShapeModel,"CoreShell")==0 || cmpstr(Dist1ShapeModel,"Tube")==0 ), win=IR1S_ControlPanel
	PopupMenu Dis1_DistributionType,disable= (tab!=0 || Nmbdist<1), win=IR1S_ControlPanel

	SetVariable Dis1_Location,disable= (tab!=0 || Nmbdist<1), win=IR1S_ControlPanel
	SetVariable Dis1_LocationStep,disable= (tab!=0 || Nmbdist<1), win=IR1S_ControlPanel

	SetVariable Dis1_scale,disable= (tab!=0 || Dis1_NumOfParam==1 || Nmbdist<1 ), win=IR1S_ControlPanel
	SetVariable Dis1_ScaleStep,disable= (tab!=0 || Dis1_NumOfParam==1 || Nmbdist<1 ), win=IR1S_ControlPanel

	SetVariable Dis1_shape,disable= (tab!=0 || Dis1_NumOfParam<=2 || Nmbdist<1), win=IR1S_ControlPanel
	SetVariable Dis1_ShapeStep,disable= (tab!=0 || Dis1_NumOfParam<=2 || Nmbdist<1), win=IR1S_ControlPanel

	SetVariable Dis1_LocationLow,disable= (tab!=0 || Nmbdist<1 || !Dist1FitLocation || Dis1_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis1_LocationHigh,disable= (tab!=0 || Nmbdist<1 || !Dist1FitLocation || Dis1_HideLocation), win=IR1S_ControlPanel
	CheckBox Dis1_FitLocation,disable= (tab!=0 || Nmbdist<1 || Dis1_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis1_ScaleLow,disable= (tab!=0 || Dis1_NumOfParam==1 || Nmbdist<1 || !Dist1FitScale || Dis1_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis1_ScaleHigh,disable= (tab!=0 || Dis1_NumOfParam==1 || Nmbdist<1 || !Dist1FitScale || Dis1_HideLocation), win=IR1S_ControlPanel
	CheckBox Dis1_FitScale,disable= (tab!=0 || Dis1_NumOfParam==1 || Nmbdist<1 || Dis1_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis1_ShapeLow,disable= (tab!=0 || Dis1_NumOfParam<=2 || Nmbdist<1 || !Dist1FitShape), win=IR1S_ControlPanel
	SetVariable Dis1_ShapeHigh,disable= (tab!=0 || Dis1_NumOfParam<=2 || Nmbdist<1 || !Dist1FitShape), win=IR1S_ControlPanel
	CheckBox Dis1_FitShape,disable= (tab!=0 || Dis1_NumOfParam<=2 || Nmbdist<1), win=IR1S_ControlPanel
	
	SetVariable DIS1_Mode,disable= (tab!=0 || Nmbdist<1), win=IR1S_ControlPanel
	SetVariable DIS1_Median,disable= (tab!=0 || Nmbdist<1), win=IR1S_ControlPanel
	SetVariable DIS1_Mean,disable= (tab!=0|| Nmbdist<1), win=IR1S_ControlPanel
		
	TitleBox 	Dis1_Gauss, disable= (tab!=0 || Dis1_EquationType!=2 || Nmbdist<1), win=IR1S_ControlPanel
	TitleBox 	Dis1_LogNormal, disable= (tab!=0 || Dis1_EquationType!=1|| Nmbdist<1), win=IR1S_ControlPanel
	TitleBox 	Dis1_LSW, disable=(tab!=0 ||Dis1_EquationType!=3 || Nmbdist<1), win=IR1S_ControlPanel
	TitleBox 	Dis1_PowerLaw, disable=(tab!=0 ||Dis1_EquationType!=4 || Nmbdist<1), win=IR1S_ControlPanel

//distribution 2 part...

	variable Dis2_NumOfParam, Dis2_EquationType,  Dis2_HideLocation
	SVAR Dist2DistributionType=root:Packages:SAS_Modeling:Dist2DistributionType
	if (cmpstr(Dist2DistributionType,"LSW")==0)
		Dis2_NumOfParam=1
		Dis2_EquationType=3
		Dis2_HideLocation=0
		SetVariable Dis2_Location,title="Location  ", win=IR1S_ControlPanel
		SetVariable Dis2_LocationHigh,title="  < location <     ", win=IR1S_ControlPanel
		CheckBox Dis2_FitLocation,title="Fit Location?", win=IR1S_ControlPanel
	endif
	if (cmpstr(Dist2DistributionType,"Gauss")==0)
		Dis2_NumOfParam=2
		Dis2_EquationType=2
		Dis2_HideLocation=0
		SetVariable Dis2_Location,title="Mean size", win=IR1S_ControlPanel
		SetVariable Dis2_scale,title="Width        ", win=IR1S_ControlPanel
		SetVariable Dis2_LocationHigh,title="  < Mean size < ", win=IR1S_ControlPanel
		SetVariable Dis2_ScaleHigh,title="  < Width <       ", win=IR1S_ControlPanel
		CheckBox Dis2_FitLocation,title="Fit mean size?", win=IR1S_ControlPanel
		CheckBox Dis2_FitScale,title="Fit width?", win=IR1S_ControlPanel
	endif
	if (cmpstr(Dist2DistributionType,"LogNormal")==0)
		Dis2_NumOfParam=3
		Dis2_EquationType=1
		Dis2_HideLocation=0
		SetVariable Dis2_Location,title="Min size  ", win=IR1S_ControlPanel
		SetVariable Dis2_scale,title="Mean size", win=IR1S_ControlPanel
		SetVariable Dis2_shape,title="Sdeviation  ", win=IR1S_ControlPanel
		SetVariable Dis2_LocationHigh,title="  < Min. size <   ", win=IR1S_ControlPanel
		SetVariable Dis2_ScaleHigh,title="  < Mean size < ", win=IR1S_ControlPanel
		SetVariable Dis2_ShapeHigh,title=" < Sdeviation < ", win=IR1S_ControlPanel
		CheckBox Dis2_FitLocation,title="Fit min. size?", win=IR1S_ControlPanel
		CheckBox Dis2_FitScale,title="Fit mean size?", win=IR1S_ControlPanel
		CheckBox Dis2_FitShape,title="Fit Sdev.?", win=IR1S_ControlPanel
	endif
	if (cmpstr(Dist2DistributionType,"PowerLaw")==0)
		Dis2_NumOfParam=3
		Dis2_EquationType=4
		Dis2_HideLocation=1
		SetVariable Dis2_Location,title="Maximum Dia  ", win=IR1S_ControlPanel
		SetVariable Dis2_scale,title="Minimum Dia   ", win=IR1S_ControlPanel
		SetVariable Dis2_shape,title="Power slope   ", win=IR1S_ControlPanel //// , MaxDia =loc, MinDia = scale
//		SetVariable Dis2_LocationHigh,title="  < Max. dia <   ", win=IR1S_ControlPanel
//		SetVariable Dis2_ScaleHigh,title="  < Min dia < ", win=IR1S_ControlPanel
		SetVariable Dis2_ShapeHigh,title=" < slope < ", win=IR1S_ControlPanel
//		CheckBox Dis2_FitLocation,title="Fit max. dia.?", win=IR1S_ControlPanel
//		CheckBox Dis2_FitScale,title="Fit min. dia.?", win=IR1S_ControlPanel
		CheckBox Dis2_FitShape,title="Fit slope?", win=IR1S_ControlPanel
	endif
	NVAR Dist2FitVol=root:Packages:SAS_Modeling:Dist2FitVol
	NVAR Dist2FitShape=root:Packages:SAS_Modeling:Dist2FitShape
	NVAR Dist2FitLocation=root:Packages:SAS_Modeling:Dist2FitLocation
	NVAR Dist2FitScale=root:Packages:SAS_Modeling:Dist2FitScale
	
	SetVariable Dis2_VolumeLow, disable= (tab!=1 || Nmbdist<2 || !Dist2FitVol), win=IR1S_ControlPanel
	SetVariable Dis2_VolumeHigh, disable= (tab!=1 || Nmbdist<2 || !Dist2FitVol), win=IR1S_ControlPanel
	SetVariable Dis2_NegligibleFraction, disable= (tab!=1 || Nmbdist<2), win=IR1S_ControlPanel
	SetVariable Dis2_NumberOfPointsInDis, disable= (tab!=1 || Nmbdist<2), win=IR1S_ControlPanel
	SetVariable Dis2_FWHM, disable= (tab!=1 || Nmbdist<2), win=IR1S_ControlPanel
	CheckBox Dis2_FitVolume, disable= (tab!=1 || Nmbdist<2), win=IR1S_ControlPanel

	SetVariable Dis2_Volume, disable= (tab!=1 || Nmbdist<2), win=IR1S_ControlPanel
	PopupMenu Dis2_ShapePopup,disable= (tab!=1 || Nmbdist<2), win=IR1S_ControlPanel
	SVAR Dist2ShapeModel=root:Packages:SAS_Modeling:Dist2ShapeModel
	SetVariable Dis2_Contrast,disable= (tab!=1 || Nmbdist<2|| cmpstr(Dist2ShapeModel,"CoreShell")==0 || cmpstr(Dist2ShapeModel,"Tube")==0 ), win=IR1S_ControlPanel
	PopupMenu Dis2_DistributionType,disable= (tab!=1 || Nmbdist<2), win=IR1S_ControlPanel

	SetVariable Dis2_Location,disable= (tab!=1 || Nmbdist<2 || Dis2_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis2_LocationStep,disable= (tab!=1 || Nmbdist<2 || Dis2_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis2_scale,disable= (tab!=1 || Dis2_NumOfParam==1 || Nmbdist<2 || Dis2_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis2_ScaleStep,disable= (tab!=1 || Dis2_NumOfParam==1 || Nmbdist<2 || Dis2_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis2_shape,disable= (tab!=1 || Dis2_NumOfParam<=2 || Nmbdist<2), win=IR1S_ControlPanel
	SetVariable Dis2_ShapeStep,disable= (tab!=1 || Dis2_NumOfParam<=2 || Nmbdist<2), win=IR1S_ControlPanel

	SetVariable Dis2_LocationLow,disable= (tab!=1 || Nmbdist<2 || !Dist2FitLocation || Dis2_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis2_LocationHigh,disable= (tab!=1 || Nmbdist<2 || !Dist2FitLocation || Dis2_HideLocation), win=IR1S_ControlPanel
	CheckBox Dis2_FitLocation,disable= (tab!=1 || Nmbdist<2 || Dis2_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis2_ScaleLow,disable= (tab!=1 || Dis2_NumOfParam==1 || Nmbdist<2 || !Dist2FitScale || Dis2_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis2_ScaleHigh,disable= (tab!=1 || Dis2_NumOfParam==1 || Nmbdist<2 || !Dist2FitScale || Dis2_HideLocation), win=IR1S_ControlPanel
	CheckBox Dis2_FitScale,disable= (tab!=1 || Dis2_NumOfParam==1 || Nmbdist<2 || Dis2_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis2_ShapeLow,disable= (tab!=1 || Dis2_NumOfParam<=2 || Nmbdist<2 || !Dist2FitShape), win=IR1S_ControlPanel
	SetVariable Dis2_ShapeHigh,disable= (tab!=1 || Dis2_NumOfParam<=2 || Nmbdist<2 || !Dist2FitShape), win=IR1S_ControlPanel
	CheckBox Dis2_FitShape,disable= (tab!=1 || Dis2_NumOfParam<=2 || Nmbdist<2), win=IR1S_ControlPanel
	
	SetVariable Dis2_Mode,disable= (tab!=1 || Nmbdist<2), win=IR1S_ControlPanel
	SetVariable Dis2_Median,disable= (tab!=1 || Nmbdist<2), win=IR1S_ControlPanel
	SetVariable Dis2_Mean,disable= (tab!=1|| Nmbdist<2), win=IR1S_ControlPanel
		
	TitleBox 	Dis2_Gauss, disable= (tab!=1 || Dis2_EquationType!=2 || Nmbdist<2), win=IR1S_ControlPanel
	TitleBox 	Dis2_LogNormal, disable= (tab!=1 || Dis2_EquationType!=1|| Nmbdist<2), win=IR1S_ControlPanel
	TitleBox 	Dis2_LSW, disable=(tab!=1 ||Dis2_EquationType!=3 || Nmbdist<2), win=IR1S_ControlPanel
	TitleBox 	Dis2_PowerLaw, disable=(tab!=1 ||Dis2_EquationType!=4 || Nmbdist<2), win=IR1S_ControlPanel

//distribution 3 part


	variable Dis3_NumOfParam, Dis3_EquationType, Dis3_HideLocation
	SVAR Dist3DistributionType=root:Packages:SAS_Modeling:Dist3DistributionType

	if (cmpstr(Dist3DistributionType,"LSW")==0)
		Dis3_NumOfParam=1
		Dis3_EquationType=3
		Dis3_HideLocation=0
		SetVariable Dis3_Location,title="Location  ", win=IR1S_ControlPanel
		SetVariable Dis3_LocationHigh,title="  < location <     ", win=IR1S_ControlPanel
		CheckBox Dis3_FitLocation,title="Fit Location?", win=IR1S_ControlPanel
	endif
	if (cmpstr(Dist3DistributionType,"Gauss")==0)
		Dis3_NumOfParam=2
		Dis3_EquationType=2
		Dis3_HideLocation=0
		SetVariable Dis3_Location,title="Mean size", win=IR1S_ControlPanel
		SetVariable Dis3_scale,title="Width        ", win=IR1S_ControlPanel
		SetVariable Dis3_LocationHigh,title="  < Mean size < ", win=IR1S_ControlPanel
		SetVariable Dis3_ScaleHigh,title="  < Width <       ", win=IR1S_ControlPanel
		CheckBox Dis3_FitLocation,title="Fit mean size?", win=IR1S_ControlPanel
		CheckBox Dis3_FitScale,title="Fit width?", win=IR1S_ControlPanel
	endif
	if (cmpstr(Dist3DistributionType,"LogNormal")==0)
		Dis3_NumOfParam=3
		Dis3_EquationType=1
		Dis3_HideLocation=0
		SetVariable Dis3_Location,title="Min size  ", win=IR1S_ControlPanel
		SetVariable Dis3_scale,title="Mean size", win=IR1S_ControlPanel
		SetVariable Dis3_shape,title="Sdeviation  ", win=IR1S_ControlPanel
		SetVariable Dis3_LocationHigh,title="  < Min. size <   ", win=IR1S_ControlPanel
		SetVariable Dis3_ScaleHigh,title="  < Mean size < ", win=IR1S_ControlPanel
		SetVariable Dis3_ShapeHigh,title=" < Sdeviation < ", win=IR1S_ControlPanel
		CheckBox Dis3_FitLocation,title="Fit min. size?", win=IR1S_ControlPanel
		CheckBox Dis3_FitScale,title="Fit mean size?", win=IR1S_ControlPanel
		CheckBox Dis3_FitShape,title="Fit Sdev.?", win=IR1S_ControlPanel
	endif
	if (cmpstr(Dist3DistributionType,"PowerLaw")==0)
		Dis3_NumOfParam=3
		Dis3_EquationType=4
		Dis3_HideLocation=1
		SetVariable Dis3_Location,title="Maximum Dia  ", win=IR1S_ControlPanel
		SetVariable Dis3_scale,title="Minimum Dia   ", win=IR1S_ControlPanel
		SetVariable Dis3_shape,title="Power slope   ", win=IR1S_ControlPanel //// , MaxDia =loc, MinDia = scale
//		SetVariable Dis3_LocationHigh,title="  < Max. dia <   ", win=IR1S_ControlPanel
//		SetVariable Dis3_ScaleHigh,title="  < Min dia < ", win=IR1S_ControlPanel
		SetVariable Dis3_ShapeHigh,title=" < slope < ", win=IR1S_ControlPanel
//		CheckBox Dis3_FitLocation,title="Fit max. dia.?", win=IR1S_ControlPanel
//		CheckBox Dis3_FitScale,title="Fit min. dia.?", win=IR1S_ControlPanel
		CheckBox Dis3_FitShape,title="Fit slope?", win=IR1S_ControlPanel
	endif

	NVAR Dist3FitVol=root:Packages:SAS_Modeling:Dist3FitVol
	NVAR Dist3FitShape=root:Packages:SAS_Modeling:Dist3FitShape
	NVAR Dist3FitLocation=root:Packages:SAS_Modeling:Dist3FitLocation
	NVAR Dist3FitScale=root:Packages:SAS_Modeling:Dist3FitScale
	
	SetVariable Dis3_VolumeLow, disable= (tab!=2 || Nmbdist<3 || !Dist3FitVol), win=IR1S_ControlPanel
	SetVariable Dis3_VolumeHigh, disable= (tab!=2 || Nmbdist<3 || !Dist3FitVol), win=IR1S_ControlPanel
	SetVariable Dis3_NegligibleFraction, disable= (tab!=2 || Nmbdist<3), win=IR1S_ControlPanel
	SetVariable Dis3_NumberOfPointsInDis, disable= (tab!=2 || Nmbdist<3), win=IR1S_ControlPanel
	SetVariable Dis3_FWHM, disable= (tab!=2 || Nmbdist<3), win=IR1S_ControlPanel
	CheckBox Dis3_FitVolume, disable= (tab!=2 || Nmbdist<3), win=IR1S_ControlPanel

	SetVariable Dis3_Volume, disable= (tab!=2 || Nmbdist<3), win=IR1S_ControlPanel
	PopupMenu Dis3_ShapePopup,disable= (tab!=2 || Nmbdist<3), win=IR1S_ControlPanel
	SVAR Dist3ShapeModel=root:Packages:SAS_Modeling:Dist3ShapeModel
	SetVariable Dis3_Contrast,disable= (tab!=2 || Nmbdist<3|| cmpstr(Dist3ShapeModel,"CoreShell")==0 || cmpstr(Dist3ShapeModel,"Tube")==0 ), win=IR1S_ControlPanel
	PopupMenu Dis3_DistributionType,disable= (tab!=2 || Nmbdist<3), win=IR1S_ControlPanel

	SetVariable Dis3_Location,disable= (tab!=2 || Nmbdist<3 || Dis3_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis3_LocationStep,disable= (tab!=2 || Nmbdist<3 || Dis3_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis3_scale,disable= (tab!=2 || Dis3_NumOfParam==1 || Nmbdist<3 || Dis3_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis3_ScaleStep,disable= (tab!=2 || Dis3_NumOfParam==1 || Nmbdist<3 || Dis3_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis3_shape,disable= (tab!=2 || Dis3_NumOfParam<=2 || Nmbdist<3), win=IR1S_ControlPanel
	SetVariable Dis3_ShapeStep,disable= (tab!=2 || Dis3_NumOfParam<=2 || Nmbdist<3), win=IR1S_ControlPanel

	SetVariable Dis3_LocationLow,disable= (tab!=2 || Nmbdist<3 || !Dist3FitLocation || Dis3_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis3_LocationHigh,disable= (tab!=2 || Nmbdist<3 || !Dist3FitLocation || Dis3_HideLocation), win=IR1S_ControlPanel
	CheckBox Dis3_FitLocation,disable= (tab!=2 || Nmbdist<3 || Dis3_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis3_ScaleLow,disable= (tab!=2 || Dis3_NumOfParam==1 || Nmbdist<3 || !Dist3FitScale || Dis3_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis3_ScaleHigh,disable= (tab!=2 || Dis3_NumOfParam==1 || Nmbdist<3 || !Dist3FitScale || Dis3_HideLocation), win=IR1S_ControlPanel
	CheckBox Dis3_FitScale,disable= (tab!=2 || Dis3_NumOfParam==1 || Nmbdist<3 || Dis3_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis3_ShapeLow,disable= (tab!=2 || Dis3_NumOfParam<=2 || Nmbdist<3 || !Dist3FitShape), win=IR1S_ControlPanel
	SetVariable Dis3_ShapeHigh,disable= (tab!=2 || Dis3_NumOfParam<=2 || Nmbdist<3 || !Dist3FitShape), win=IR1S_ControlPanel
	CheckBox Dis3_FitShape,disable= (tab!=2 || Dis3_NumOfParam<=2 || Nmbdist<3), win=IR1S_ControlPanel
	
	SetVariable Dis3_Mode,disable= (tab!=2 || Nmbdist<3), win=IR1S_ControlPanel
	SetVariable Dis3_Median,disable= (tab!=2 || Nmbdist<3), win=IR1S_ControlPanel
	SetVariable Dis3_Mean,disable= (tab!=2|| Nmbdist<3), win=IR1S_ControlPanel
		
	TitleBox 	Dis3_Gauss, disable= (tab!=2 || Dis3_EquationType!=2 || Nmbdist<3), win=IR1S_ControlPanel
	TitleBox 	Dis3_LogNormal, disable= (tab!=2 || Dis3_EquationType!=1|| Nmbdist<3), win=IR1S_ControlPanel
	TitleBox 	Dis3_LSW, disable=(tab!=2 ||Dis3_EquationType!=3 || Nmbdist<3), win=IR1S_ControlPanel
	TitleBox 	Dis3_PowerLaw, disable=(tab!=2 ||Dis3_EquationType!=4 || Nmbdist<3), win=IR1S_ControlPanel

//distribution 4 part...


	variable Dis4_NumOfParam, Dis4_EquationType, Dis4_HideLocation
	SVAR Dist4DistributionType=root:Packages:SAS_Modeling:Dist4DistributionType
	if (cmpstr(Dist4DistributionType,"LSW")==0)
		Dis4_NumOfParam=1
		Dis4_EquationType=3
		Dis4_HideLocation=0
		SetVariable Dis4_Location,title="Location  ", win=IR1S_ControlPanel
		SetVariable Dis4_LocationHigh,title="  < location <     ", win=IR1S_ControlPanel
		CheckBox Dis4_FitLocation,title="Fit Location?", win=IR1S_ControlPanel
	endif
	if (cmpstr(Dist4DistributionType,"Gauss")==0)
		Dis4_NumOfParam=2
		Dis4_EquationType=2
		Dis4_HideLocation=0
		SetVariable Dis4_Location,title="Mean size", win=IR1S_ControlPanel
		SetVariable Dis4_scale,title="Width        ", win=IR1S_ControlPanel
		SetVariable Dis4_LocationHigh,title="  < Mean size < ", win=IR1S_ControlPanel
		SetVariable Dis4_ScaleHigh,title="  < Width <       ", win=IR1S_ControlPanel
		CheckBox Dis4_FitLocation,title="Fit mean size?", win=IR1S_ControlPanel
		CheckBox Dis4_FitScale,title="Fit width?", win=IR1S_ControlPanel
	endif
	if (cmpstr(Dist4DistributionType,"LogNormal")==0)
		Dis4_NumOfParam=3
		Dis4_EquationType=1
		Dis4_HideLocation=0
		SetVariable Dis4_Location,title="Min size  ", win=IR1S_ControlPanel
		SetVariable Dis4_scale,title="Mean size", win=IR1S_ControlPanel
		SetVariable Dis4_shape,title="Sdeviation  ", win=IR1S_ControlPanel
		SetVariable Dis4_LocationHigh,title="  < Min. size <   ", win=IR1S_ControlPanel
		SetVariable Dis4_ScaleHigh,title="  < Mean size < ", win=IR1S_ControlPanel
		SetVariable Dis4_ShapeHigh,title=" < Sdeviation < ", win=IR1S_ControlPanel
		CheckBox Dis4_FitLocation,title="Fit min. size?", win=IR1S_ControlPanel
		CheckBox Dis4_FitScale,title="Fit mean size?", win=IR1S_ControlPanel
		CheckBox Dis4_FitShape,title="Fit Sdev.?", win=IR1S_ControlPanel
	endif
	if (cmpstr(Dist4DistributionType,"PowerLaw")==0)
		Dis4_NumOfParam=3
		Dis4_EquationType=4
		Dis4_HideLocation=1
		SetVariable Dis4_Location,title="Maximum Dia  ", win=IR1S_ControlPanel
		SetVariable Dis4_scale,title="Minimum Dia   ", win=IR1S_ControlPanel
		SetVariable Dis4_shape,title="Power slope   ", win=IR1S_ControlPanel //// , MaxDia =loc, MinDia = scale
//		SetVariable Dis4_LocationHigh,title="  < Max. dia <   ", win=IR1S_ControlPanel
//		SetVariable Dis4_ScaleHigh,title="  < Min dia < ", win=IR1S_ControlPanel
		SetVariable Dis4_ShapeHigh,title=" < slope < ", win=IR1S_ControlPanel
//		CheckBox Dis4_FitLocation,title="Fit max. dia.?", win=IR1S_ControlPanel
//		CheckBox Dis4_FitScale,title="Fit min. dia.?", win=IR1S_ControlPanel
		CheckBox Dis4_FitShape,title="Fit slope?", win=IR1S_ControlPanel
	endif

	NVAR Dist4FitVol=root:Packages:SAS_Modeling:Dist4FitVol
	NVAR Dist4FitShape=root:Packages:SAS_Modeling:Dist4FitShape
	NVAR Dist4FitLocation=root:Packages:SAS_Modeling:Dist4FitLocation
	NVAR Dist4FitScale=root:Packages:SAS_Modeling:Dist4FitScale
	
	SetVariable Dis4_VolumeLow, disable= (tab!=3 || Nmbdist<4 || !Dist4FitVol) , win=IR1S_ControlPanel
	SetVariable Dis4_VolumeHigh, disable= (tab!=3 || Nmbdist<4 || !Dist4FitVol), win=IR1S_ControlPanel
	SetVariable Dis4_NegligibleFraction, disable= (tab!=3 || Nmbdist<4), win=IR1S_ControlPanel
	SetVariable Dis4_NumberOfPointsInDis, disable= (tab!=3 || Nmbdist<4), win=IR1S_ControlPanel
	SetVariable Dis4_FWHM, disable= (tab!=3 || Nmbdist<4), win=IR1S_ControlPanel
	CheckBox Dis4_FitVolume, disable= (tab!=3 || Nmbdist<4), win=IR1S_ControlPanel

	SetVariable Dis4_Volume, disable= (tab!=3 || Nmbdist<4), win=IR1S_ControlPanel
	PopupMenu Dis4_ShapePopup,disable= (tab!=3 || Nmbdist<4), win=IR1S_ControlPanel
	SVAR Dist4ShapeModel=root:Packages:SAS_Modeling:Dist4ShapeModel
	SetVariable Dis4_Contrast,disable= (tab!=3 || Nmbdist<4|| cmpstr(Dist4ShapeModel,"CoreShell")==0 || cmpstr(Dist4ShapeModel,"Tube")==0 ), win=IR1S_ControlPanel
	PopupMenu Dis4_DistributionType,disable= (tab!=3 || Nmbdist<4), win=IR1S_ControlPanel

	SetVariable Dis4_Location,disable= (tab!=3 || Nmbdist<4 || Dis4_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis4_LocationStep,disable= (tab!=3 || Nmbdist<4 || Dis4_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis4_scale,disable= (tab!=3 || Dis4_NumOfParam==1 || Nmbdist<4 || Dis4_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis4_ScaleStep,disable= (tab!=3 || Dis4_NumOfParam==1 || Nmbdist<4 || Dis4_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis4_shape,disable= (tab!=3 || Dis4_NumOfParam<=2 || Nmbdist<4), win=IR1S_ControlPanel
	SetVariable Dis4_ShapeStep,disable= (tab!=3 || Dis4_NumOfParam<=2 || Nmbdist<4), win=IR1S_ControlPanel

	SetVariable Dis4_LocationLow,disable= (tab!=3 || Nmbdist<4 || !Dist4FitLocation || Dis4_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis4_LocationHigh,disable= (tab!=3 || Nmbdist<4 || !Dist4FitLocation || Dis4_HideLocation), win=IR1S_ControlPanel
	CheckBox Dis4_FitLocation,disable= (tab!=3 || Nmbdist<4 || Dis4_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis4_ScaleLow,disable= (tab!=3 || Dis4_NumOfParam==1 || Nmbdist<4 || !Dist4FitScale || Dis4_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis4_ScaleHigh,disable= (tab!=3 || Dis4_NumOfParam==1 || Nmbdist<4 || !Dist4FitScale || Dis4_HideLocation), win=IR1S_ControlPanel
	CheckBox Dis4_FitScale,disable= (tab!=3 || Dis4_NumOfParam==1 || Nmbdist<4 || Dis4_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis4_ShapeLow,disable= (tab!=3 || Dis4_NumOfParam<=2 || Nmbdist<4 || !Dist4FitShape), win=IR1S_ControlPanel
	SetVariable Dis4_ShapeHigh,disable= (tab!=3 || Dis4_NumOfParam<=2 || Nmbdist<4 || !Dist4FitShape) , win=IR1S_ControlPanel
	CheckBox Dis4_FitShape,disable= (tab!=3 || Dis4_NumOfParam<=2 || Nmbdist<4), win=IR1S_ControlPanel
	
	SetVariable Dis4_Mode,disable= (tab!=3 || Nmbdist<4), win=IR1S_ControlPanel
	SetVariable Dis4_Median,disable= (tab!=3 || Nmbdist<4), win=IR1S_ControlPanel
	SetVariable Dis4_Mean,disable= (tab!=3|| Nmbdist<4), win=IR1S_ControlPanel
		
	TitleBox 	Dis4_Gauss, disable= (tab!=3 || Dis4_EquationType!=2 || Nmbdist<4), win=IR1S_ControlPanel
	TitleBox 	Dis4_LogNormal, disable= (tab!=3 || Dis4_EquationType!=1|| Nmbdist<4), win=IR1S_ControlPanel
	TitleBox 	Dis4_LSW, disable=(tab!=3 ||Dis4_EquationType!=3 || Nmbdist<4), win=IR1S_ControlPanel
	TitleBox 	Dis4_PowerLaw, disable=(tab!=3 ||Dis4_EquationType!=4 || Nmbdist<4), win=IR1S_ControlPanel

//distribution 5 part


	variable Dis5_NumOfParam, Dis5_EquationType, Dis5_HideLocation
	SVAR Dist5DistributionType=root:Packages:SAS_Modeling:Dist5DistributionType

	if (cmpstr(Dist5DistributionType,"LSW")==0)
		Dis5_NumOfParam=1
		Dis5_EquationType=3
		Dis5_HideLocation=0
		SetVariable Dis5_Location,title="Location  ", win=IR1S_ControlPanel
		SetVariable Dis5_LocationHigh,title="  < location <     ", win=IR1S_ControlPanel
		CheckBox Dis5_FitLocation,title="Fit Location?", win=IR1S_ControlPanel
	endif
	if (cmpstr(Dist5DistributionType,"Gauss")==0)
		Dis5_NumOfParam=2
		Dis5_EquationType=2
		Dis5_HideLocation=0
		SetVariable Dis5_Location,title="Mean size", win=IR1S_ControlPanel
		SetVariable Dis5_scale,title="Width        ", win=IR1S_ControlPanel
		SetVariable Dis5_LocationHigh,title="  < Mean size < ", win=IR1S_ControlPanel
		SetVariable Dis5_ScaleHigh,title="  < Width <       ", win=IR1S_ControlPanel
		CheckBox Dis5_FitLocation,title="Fit mean size?", win=IR1S_ControlPanel
		CheckBox Dis5_FitScale,title="Fit width?", win=IR1S_ControlPanel
	endif
	if (cmpstr(Dist5DistributionType,"LogNormal")==0)
		Dis5_NumOfParam=3
		Dis5_EquationType=1
		Dis5_HideLocation=0
		SetVariable Dis5_Location,title="Min size  ", win=IR1S_ControlPanel
		SetVariable Dis5_scale,title="Mean size", win=IR1S_ControlPanel
		SetVariable Dis5_shape,title="Sdeviation  ", win=IR1S_ControlPanel
		SetVariable Dis5_LocationHigh,title="  < Min. size <   ", win=IR1S_ControlPanel
		SetVariable Dis5_ScaleHigh,title="  < Mean size < ", win=IR1S_ControlPanel
		SetVariable Dis5_ShapeHigh,title=" < Sdeviation < ", win=IR1S_ControlPanel
		CheckBox Dis5_FitLocation,title="Fit min. size?", win=IR1S_ControlPanel
		CheckBox Dis5_FitScale,title="Fit mean size?", win=IR1S_ControlPanel
		CheckBox Dis5_FitShape,title="Fit Sdev.?", win=IR1S_ControlPanel
	endif
	if (cmpstr(Dist5DistributionType,"PowerLaw")==0)
		Dis5_NumOfParam=3
		Dis5_EquationType=4
		Dis5_HideLocation=1
		SetVariable Dis5_Location,title="Maximum Dia  ", win=IR1S_ControlPanel
		SetVariable Dis5_scale,title="Minimum Dia   ", win=IR1S_ControlPanel
		SetVariable Dis5_shape,title="Power slope   ", win=IR1S_ControlPanel //// , MaxDia =loc, MinDia = scale
//		SetVariable Dis5_LocationHigh,title="  < Max. dia <   ", win=IR1S_ControlPanel
//		SetVariable Dis5_ScaleHigh,title="  < Min dia < ", win=IR1S_ControlPanel
		SetVariable Dis5_ShapeHigh,title=" < slope < ", win=IR1S_ControlPanel
//		CheckBox Dis5_FitLocation,title="Fit max. dia.?", win=IR1S_ControlPanel
//		CheckBox Dis5_FitScale,title="Fit min. dia.?", win=IR1S_ControlPanel
		CheckBox Dis5_FitShape,title="Fit slope?", win=IR1S_ControlPanel
	endif

	NVAR Dist5FitVol=root:Packages:SAS_Modeling:Dist5FitVol
	NVAR Dist5FitShape=root:Packages:SAS_Modeling:Dist5FitShape
	NVAR Dist5FitLocation=root:Packages:SAS_Modeling:Dist5FitLocation
	NVAR Dist5FitScale=root:Packages:SAS_Modeling:Dist5FitScale
	
	SetVariable Dis5_VolumeLow, disable= (tab!=4 || Nmbdist<5 || !Dist5FitVol), win=IR1S_ControlPanel
	SetVariable Dis5_VolumeHigh, disable= (tab!=4 || Nmbdist<5 || !Dist5FitVol), win=IR1S_ControlPanel
	SetVariable Dis5_NegligibleFraction, disable= (tab!=4 || Nmbdist<5), win=IR1S_ControlPanel
	SetVariable Dis5_NumberOfPointsInDis, disable= (tab!=4 || Nmbdist<5), win=IR1S_ControlPanel
	SetVariable Dis5_FWHM, disable= (tab!=4 || Nmbdist<5), win=IR1S_ControlPanel
	CheckBox Dis5_FitVolume, disable= (tab!=4 || Nmbdist<5), win=IR1S_ControlPanel

	SetVariable Dis5_Volume, disable= (tab!=4 || Nmbdist<5), win=IR1S_ControlPanel
	PopupMenu Dis5_ShapePopup,disable= (tab!=4 || Nmbdist<5), win=IR1S_ControlPanel
	SVAR Dist5ShapeModel=root:Packages:SAS_Modeling:Dist5ShapeModel
	SetVariable Dis5_Contrast,disable= (tab!=4 || Nmbdist<5|| cmpstr(Dist5ShapeModel,"CoreShell")==0 || cmpstr(Dist5ShapeModel,"Tube")==0 ), win=IR1S_ControlPanel
	PopupMenu Dis5_DistributionType,disable= (tab!=4 || Nmbdist<5), win=IR1S_ControlPanel

	SetVariable Dis5_Location,disable= (tab!=4 || Nmbdist<5 || Dis5_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis5_LocationStep,disable= (tab!=4 || Nmbdist<5 || Dis5_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis5_scale,disable= (tab!=4 || Dis5_NumOfParam==1 || Nmbdist<5 || Dis5_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis5_ScaleStep,disable= (tab!=4 || Dis5_NumOfParam==1 || Nmbdist<5 || Dis5_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis5_shape,disable= (tab!=4 || Dis5_NumOfParam<=2 || Nmbdist<5), win=IR1S_ControlPanel
	SetVariable Dis5_ShapeStep,disable= (tab!=4 || Dis5_NumOfParam<=2 || Nmbdist<5), win=IR1S_ControlPanel

	SetVariable Dis5_LocationLow,disable= (tab!=4 || Nmbdist<5 || !Dist5FitLocation || Dis5_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis5_LocationHigh,disable= (tab!=4 || Nmbdist<5 || !Dist5FitLocation || Dis5_HideLocation), win=IR1S_ControlPanel
	CheckBox Dis5_FitLocation,disable= (tab!=4 || Nmbdist<5 || Dis5_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis5_ScaleLow,disable= (tab!=4 || Dis5_NumOfParam==1 || Nmbdist<5 || !Dist5FitScale || Dis5_HideLocation), win=IR1S_ControlPanel
	SetVariable Dis5_ScaleHigh,disable= (tab!=4 || Dis5_NumOfParam==1 || Nmbdist<5 || !Dist5FitScale || Dis5_HideLocation), win=IR1S_ControlPanel
	CheckBox Dis5_FitScale,disable= (tab!=4 || Dis5_NumOfParam==1 || Nmbdist<5 || Dis5_HideLocation), win=IR1S_ControlPanel

	SetVariable Dis5_ShapeLow,disable= (tab!=4 || Dis5_NumOfParam<=2 || Nmbdist<5 || !Dist5FitShape), win=IR1S_ControlPanel
	SetVariable Dis5_ShapeHigh,disable= (tab!=4 || Dis5_NumOfParam<=2 || Nmbdist<5 || !Dist5FitShape), win=IR1S_ControlPanel
	CheckBox Dis5_FitShape,disable= (tab!=4 || Dis5_NumOfParam<=2 || Nmbdist<5), win=IR1S_ControlPanel
	
	SetVariable Dis5_Mode,disable= (tab!=4 || Nmbdist<5), win=IR1S_ControlPanel
	SetVariable Dis5_Median,disable= (tab!=4 || Nmbdist<5), win=IR1S_ControlPanel
	SetVariable Dis5_Mean,disable= (tab!=4|| Nmbdist<5), win=IR1S_ControlPanel
		
	TitleBox 	Dis5_Gauss, disable= (tab!=4 || Dis5_EquationType!=2 || Nmbdist<5), win=IR1S_ControlPanel
	TitleBox 	Dis5_LogNormal, disable= (tab!=4 || Dis5_EquationType!=1|| Nmbdist<5), win=IR1S_ControlPanel
	TitleBox 	Dis5_LSW, disable=(tab!=4 ||Dis5_EquationType!=3 || Nmbdist<5), win=IR1S_ControlPanel
	TitleBox 	Dis5_PowerLaw, disable=(tab!=4 ||Dis5_EquationType!=4 || Nmbdist<5), win=IR1S_ControlPanel
	setDataFolder oldDF
	DoWIndow/F IR1S_ControlPanel
End



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1S_FixTabsInPanel()
	//here we modify the panel, so it reflects the selected number of distributions
	
	NVAR NumOfDist=root:Packages:SAS_Modeling:NumberOfDistributions
	NVAR CurrentTab=root:Packages:SAS_Modeling:CurrentTab
	IR1S_TabPanelControl("DistTabs",CurrentTab)
	variable SetToTab
	SetToTab=CurrentTab
	if(SetToTab<0)
		SetToTab=0
	endif
	TabControl DistTabs,value= SetToTab, win=IR1S_ControlPanel
	DoWIndow/F IR1S_ControlPanel
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1S_PanelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling
	
	if (cmpstr(ctrlName,"SASBackground")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"SASBackgroundStep")==0)
		//here goes what happens when user changes the SASBackground in distribution
		SetVariable SASBackground,win=IR1S_ControlPanel, limits={0,Inf,varNum}
	endif

//Distribution 1
	if (cmpstr(ctrlName,"Dis1_LocationStep")==0)
		//here goes what happens when user changes the step for location
		SetVariable Dis1_Location,win=IR1S_ControlPanel, limits={0,inf,varNum}
		
	endif
	if (cmpstr(ctrlName,"Dis1_ScaleStep")==0)
		//here goes what happens when user changes the step for scale
		SetVariable Dis1_scale,win=IR1S_ControlPanel, limits={-inf,inf,varNum}
		
	endif
	if (cmpstr(ctrlName,"Dis1_ShapeStep")==0)
		//here goes what happens when user changes the step for shape
		SetVariable Dis1_shape,win=IR1S_ControlPanel, limits={-inf,inf,varNum}
		
	endif
	
	if (cmpstr(ctrlName,"Dis1_Contrast")==0)
		//here goes what happens when user changes the contrast
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis1_Location")==0)
		//here goes what happens when user changes the location
		//recalculate the distributions
		//IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		//IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis1_scale")==0)
		//here goes what happens when user changes the scale
		//recalculate the distributions
		//IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		//IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis1_shape")==0)
		//here goes what happens when user changes the shape
		//recalculate the distributions
		//IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		//IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis1_Volume")==0)
		//here goes what happens when user changes the volume in distribution
		SetVariable Dis1_Volume,limits={0,inf,0.03*varNum}, win=IR1S_ControlPanel
		IR1S_AutoUpdateIfSelected()
	endif

//Distribbution 2
	if (cmpstr(ctrlName,"Dis2_LocationStep")==0)
		//here goes what happens when user changes the step for location
		SetVariable Dis2_Location,win=IR1S_ControlPanel, limits={0,inf,varNum}
		
	endif
	if (cmpstr(ctrlName,"Dis2_ScaleStep")==0)
		//here goes what happens when user changes the step for scale
		SetVariable Dis2_scale,win=IR1S_ControlPanel, limits={-inf,inf,varNum}
		
	endif
	if (cmpstr(ctrlName,"Dis2_ShapeStep")==0)
		//here goes what happens when user changes the step for shape
		SetVariable Dis2_shape,win=IR1S_ControlPanel, limits={-inf,inf,varNum}
		
	endif
	
	if (cmpstr(ctrlName,"Dis2_Contrast")==0)
		//here goes what happens when user changes the contrast
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis2_Location")==0)
		//here goes what happens when user changes the location
		//recalculate the distributions
		//IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		//IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis2_scale")==0)
		//here goes what happens when user changes the scale
		//recalculate the distributions
		//IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		///IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis2_shape")==0)
		//here goes what happens when user changes the shape
		//recalculate the distributions
		//IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		//IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis2_Volume")==0)
		//here goes what happens when user changes the volume in distribution
		SetVariable Dis2_Volume,limits={0,inf,0.03*varNum}, win=IR1S_ControlPanel
		IR1S_AutoUpdateIfSelected()
	endif

//Distribution 3

	if (cmpstr(ctrlName,"Dis3_LocationStep")==0)
		//here goes what happens when user changes the step for location
		SetVariable Dis3_Location,win=IR1S_ControlPanel, limits={0,inf,varNum}
		
	endif
	if (cmpstr(ctrlName,"Dis3_ScaleStep")==0)
		//here goes what happens when user changes the step for scale
		SetVariable Dis3_scale,win=IR1S_ControlPanel, limits={-inf,inf,varNum}
		
	endif
	if (cmpstr(ctrlName,"Dis3_ShapeStep")==0)
		//here goes what happens when user changes the step for shape
		SetVariable Dis3_shape,win=IR1S_ControlPanel, limits={-inf,inf,varNum}
		
	endif
	
	if (cmpstr(ctrlName,"Dis3_Contrast")==0)
		//here goes what happens when user changes the contrast
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis3_Location")==0)
		//here goes what happens when user changes the location
		//recalculate the distributions
		//IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		//IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis3_scale")==0)
		//here goes what happens when user changes the scale
		//recalculate the distributions
		//IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		//IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis3_shape")==0)
		//here goes what happens when user changes the shape
		//recalculate the distributions
		//IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		//IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis3_Volume")==0)
		//here goes what happens when user changes the volume in distribution
		SetVariable Dis3_Volume,limits={0,inf,0.03*varNum}, win=IR1S_ControlPanel
		IR1S_AutoUpdateIfSelected()
	endif

//Distribution 4

	if (cmpstr(ctrlName,"Dis4_LocationStep")==0)
		//here goes what happens when user changes the step for location
		SetVariable Dis4_Location,win=IR1S_ControlPanel, limits={0,inf,varNum}
		
	endif
	if (cmpstr(ctrlName,"Dis4_ScaleStep")==0)
		//here goes what happens when user changes the step for scale
		SetVariable Dis4_scale,win=IR1S_ControlPanel, limits={-inf,inf,varNum}
		
	endif
	if (cmpstr(ctrlName,"Dis4_ShapeStep")==0)
		//here goes what happens when user changes the step for shape
		SetVariable Dis4_shape,win=IR1S_ControlPanel, limits={-inf,inf,varNum}
		
	endif
	
	if (cmpstr(ctrlName,"Dis4_Contrast")==0)
		//here goes what happens when user changes the contrast
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis4_Location")==0)
		//here goes what happens when user changes the location
		//recalculate the distributions
		//IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		//IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis4_scale")==0)
		//here goes what happens when user changes the scale
		//recalculate the distributions
		//IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		//IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis4_shape")==0)
		//here goes what happens when user changes the shape
		//recalculate the distributions
		//IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		//IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis4_Volume")==0)
		//here goes what happens when user changes the volume in distribution
		SetVariable Dis4_Volume,limits={0,inf,0.03*varNum}, win=IR1S_ControlPanel
		IR1S_AutoUpdateIfSelected()
	endif

//Distribution 5

	if (cmpstr(ctrlName,"Dis5_LocationStep")==0)
		//here goes what happens when user changes the step for location
		SetVariable Dis5_Location,win=IR1S_ControlPanel, limits={0,inf,varNum}
		
	endif
	if (cmpstr(ctrlName,"Dis5_ScaleStep")==0)
		//here goes what happens when user changes the step for scale
		SetVariable Dis5_scale,win=IR1S_ControlPanel, limits={-inf,inf,varNum}
		
	endif
	if (cmpstr(ctrlName,"Dis5_ShapeStep")==0)
		//here goes what happens when user changes the step for shape
		SetVariable Dis5_shape,win=IR1S_ControlPanel, limits={-inf,inf,varNum}
		
	endif
	
	if (cmpstr(ctrlName,"Dis5_Contrast")==0)
		//here goes what happens when user changes the contrast
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis5_Location")==0)
		//here goes what happens when user changes the location
		//recalculate the distributions
		//IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		//IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis5_scale")==0)
		//here goes what happens when user changes the scale
		//recalculate the distributions
		//IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		//IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis5_shape")==0)
		//here goes what happens when user changes the shape
		//recalculate the distributions
		//IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		//IR1S_UpdateModeMedianMean()		//modified for 5
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis5_Volume")==0)
		//here goes what happens when user changes the volume in distribution
		//recalculate the distributions
		//IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
		//IR1S_UpdateModeMedianMean()		//modified for 5
		SetVariable Dis5_Volume,limits={0,inf,0.03*varNum}, win=IR1S_ControlPanel
		IR1S_AutoUpdateIfSelected()
	endif

	if (cmpstr(ctrlName,"Dist1_InterferencePhi")==0)
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dist1_InterferenceEta")==0)
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dist2_InterferencePhi")==0)
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dist2_InterferenceEta")==0)
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dist3_InterferencePhi")==0)
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dist3_InterferenceEta")==0)
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dist4_InterferencePhi")==0)
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dist4_InterferenceEta")==0)
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dist5_InterferencePhi")==0)
		IR1S_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dist5_InterferenceEta")==0)
		IR1S_AutoUpdateIfSelected()
	endif
	setDataFolder oldDF
	DoWIndow/F IR1S_ControlPanel
End


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1S_AutoUpdateIfSelected()
	
	NVAR UpdateAutomatically=root:Packages:SAS_Modeling:UpdateAutomatically
	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
	variable i
	string infostr
	if (UpdateAutomatically)
		For(i=1;i<=NumberOfDistributions;i+=1)
			SVAR DistShapeModel=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ShapeModel")
			if(cmpstr("user",DistShapeModel)==0)
					SVAR UserFormFactorFnct=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"UserFormFactorFnct")
					SVAR UserVolumeFnct=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"UserVolumeFnct")	
					infostr = FunctionInfo(UserFormFactorFnct)
					if (strlen(infostr) == 0)
						Abort
					endif
					infostr = FunctionInfo(UserVolumeFnct)
					if (strlen(infostr) == 0)
						Abort
					endif
			endif
		endfor		
		IR1_GraphModelData()
	endif
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//
//	NVAR UpdateAutomatically=root:Packages:SAS_Modeling:UpdateAutomatically
//	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
//	variable i
//	if (UpdateAutomatically)
//			//for user model needs to be cheked here...
//			For(i=0;i<NumberOfDistributions;
//			SVAR DistShapeModel=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ShapeModel")
//			if(
//			string inforstr
//			infostr = FunctionInfo(User_FormFactorVol)
//					if (strlen(infostr) == 0)
//						Abort "Volume function for user form factor does not exist"
//					endif
//					if(NumberByKey("N_PARAMS", infostr)!=6 || NumberByKey("RETURNTYPE", infostr)!=4)
//						Abort "Volume for user form factor does not have the righ number of parameters or does not return variable"
//					endif
//
