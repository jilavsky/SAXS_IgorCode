#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.02

//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.01 added license for ANL
//2.02 removed all font and font size from panel definitions to enable user control


//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from www.uni.aps.anl.gov/~ilavsky
//this package contains 
// Igor functions for modeling of SAS from various distributions of scatterers...

//Jan Ilavsky, March 2002

//please, read Readme in the distribution zip file with more details on the program
//report any problems to: ilavsky@aps.anl.gov
//main functions for modeling with user input of distributions...

Window IR1U_ControlPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,20,375,670) as "IR1U_ControlPanel"
	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman",fsize= 22,fstyle= 3,textrgb= (0,0,52224)
	DrawText 57,28,"SAS modeling input panel"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,181,339,181
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 8,49,"Experimental data input"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 17,209,"Modeling input"
	SetDrawEnv fstyle= 1
	DrawText 89,478,"Limits for fitting"
	DrawText 16,605,"Fit using least square fitting ?"
	DrawLine 24,455,344,455
	DrawLine 225,390,225,456
	DrawLine 229,390,229,456
	DrawPoly 113,225,1,1,{113,225,113,225}
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,612,339,612
	SetDrawEnv textrgb= (0,0,65280),fstyle= 1
	DrawText 16,635,"Results:"

	//Experimental data input
	CheckBox UseIndra2Data,pos={217,26},size={141,14},proc=IR1U_InputPanelCheckboxProc,title="Use USAXS structure"
	CheckBox UseIndra2Data,value= root:packages:SAS_Modeling:UseIndra2data, help={"Check, if you are using Indra 2 produced data with the orginal names, uncheck if the names of data waves are different"}
	CheckBox UseQRSData,pos={217,40},size={141,14},proc=IR1U_InputPanelCheckboxProc,title="Use QRS data structure"
	CheckBox UseQRSData,value= root:packages:SAS_Modeling:UseQRSdata, help={"Check, if you are using QRS names, uncheck if the names of data waves are different"}
	PopupMenu SelectDataFolder,pos={8,56},size={180,21},proc=IR1U_PanelPopupControl,title="Select folder with data:    ", help={"Select folder with data"}
	PopupMenu SelectDataFolder,mode=1,popvalue="---",value= #"\"---;\"+IR1_GenStringOfFolders(root:Packages:SAS_Modeling:UseIndra2Data, root:Packages:SAS_Modeling:UseQRSData,0,0)"
	PopupMenu QvecDataName,pos={9,80},size={179,21},proc=IR1U_PanelPopupControl,title="Wave with Q data           ", help={"Select wave with Q data"}
	PopupMenu QvecDataName,mode=1,popvalue="---",value= #"\"---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"SAS_Modeling\",0,0)"
	PopupMenu IntensityDataName,pos={8,106},size={180,21},proc=IR1U_PanelPopupControl,title="Wave with Intensity data ", help={"Select wave with Intensity data"}
	PopupMenu IntensityDataName,mode=1,popvalue="---",value= #"\"---;\"+IR1_ListOfWaves(\"DSM_Int\",\"SAS_Modeling\",0,0)"
	PopupMenu ErrorDataName,pos={10,133},size={178,21},proc=IR1U_PanelPopupControl,title="Wave with Error data      ", help={"Select wave with error data"}
	PopupMenu ErrorDataName,mode=1,popvalue="---",value= #"\"---;\"+IR1_ListOfWaves(\"DSM_Error\",\"SAS_Modeling\",0,0)"
	Button DrawGraphs,pos={136,158},size={50,20}, proc=IR1U_InputPanelButtonProc,title="Graph", help={"Click to generate data graphs, necessary step for further evaluation"}

	//Modeling input, common for all distributions
	PopupMenu NumberOfDistributions,pos={169,185},size={170,21},proc=IR1U_PanelPopupControl,title="Number of distributions :"
	PopupMenu NumberOfDistributions,mode=2,popvalue=num2str(root:Packages:SAS_Modeling:NumberOfDistributions),value= #"\"0;1;2;3;4;5;\"", help={"Select number of different distributions you want to model, can be modified anytime"}
	CheckBox DisplayND,pos={122,215},size={223,14},proc=IR1U_InputPanelCheckboxProc,title="Display N(d)? "
	CheckBox DisplayND,value= root:Packages:SAS_Modeling:DisplayND, help={"Display Number distribution in the graph?"}
	CheckBox DisplayVD,pos={230,215},size={223,14},proc=IR1U_InputPanelCheckboxProc,title="Display V(d)? "
	CheckBox DisplayVD,value= root:Packages:SAS_Modeling:DisplayVD, help={"Display Volume distribution in the graph?"}
	Button GraphDistribution,pos={32,217},size={50,20}, proc=IR1U_InputPanelButtonProc,title="Graph", help={"Graph manually. Used if UpdateAutomatically is not selected."}
	CheckBox UpdateAutomatically,pos={44,241},size={225,14},proc=IR1U_InputPanelCheckboxProc,title="Update graphs automatically? (may be slow!!)"
	CheckBox UpdateAutomatically,value= root:Packages:SAS_Modeling:UpdateAutomatically, help={"Graph automatically anytime distribution parameters are changed. May be slow..."}

	Button DoFitting,pos={175,588},size={70,20}, proc=IR1U_InputPanelButtonProc,title="Fit", help={"Click to start least square fitting. Make sure the fitting coefficients are well guessed and limited."}
	Button RevertFitting,pos={255,588},size={100,20}, proc=IR1U_InputPanelButtonProc,title="Revert back", help={"Return values before last fit attempmt. Use to recover from unsuccesfull fit."}
	Button CopyToFolder,pos={90,620},size={110,20}, proc=IR1U_InputPanelButtonProc,title="Store in Data Folder", help={"Copy results back to data folder for future use."}
	Button ExportData,pos={210,620},size={90,20}, proc=IR1U_InputPanelButtonProc,title="Export ASCII", help={"Export ASCII data out from Igor."}
	SetVariable SASBackground,pos={13,569},size={150,16},proc=IR1U_PanelSetVarProc,title="SAS Background", help={"Background of SAS"}
	SetVariable SASBackground,limits={-inf,Inf,root:Packages:SAS_Modeling:SASBackgroundStep},value= root:Packages:SAS_Modeling:SASBackground
	SetVariable SASBackgroundStep,pos={173,569},size={50,16},title="step",proc=IR1_PanelSetVarProc, help={"Step for SAS background. Used to set appropriate steps for clicking background up and down."}
	SetVariable SASBackgroundStep,limits={0,Inf,0},value= root:Packages:SAS_Modeling:SASBackgroundStep
	CheckBox FitBackground,pos={253,566},size={63,14},proc=IR1U_InputPanelCheckboxProc,title="Fit Bckg?"
	CheckBox FitBackground,value= root:Packages:SAS_Modeling:FitSASBackground, help={"Fit the background during least square fitting?"}

	//Dist Tabs definition
	TabControl DistTabs,pos={1,260},size={373,300},proc=IR1U_TabPanelControl
	TabControl DistTabs,fSize=10,tabLabel(0)="First Dist",tabLabel(1)="Second Dist"
	TabControl DistTabs,tabLabel(2)="Third Dist",tabLabel(3)="Fourth Dist"
	TabControl DistTabs,tabLabel(4)="Fifth Dist",value= 0
	
	//Distribution 1 controls
	PopupMenu Dis1_DataFolder,pos={6,285},size={132,21},title="Data in folder      ",proc=IR1U_PanelPopupControl, help={"Select datafolder, which contains distribution data for this population"}
	PopupMenu Dis1_DataFolder,mode=1,popvalue=root:Packages:SAS_Modeling:Dist1FolderName,value= #"\"---;\"+IR1_GenStringOfFolders(0,0,0,0)"
	PopupMenu Dis1_ProbabilityWv,pos={6,310},size={150,21},title="Probability data:  ",proc=IR1U_PanelPopupControl, help={"Select wave with distribution - f(D) or f(R) or V(D) or V(R)"}
	PopupMenu Dis1_ProbabilityWv,mode=1,popvalue=root:Packages:SAS_Modeling:Dist1ProbabilityWvNm,value= #"\"---;\"+IR1_ListOfWavesInIFolder(1,\"Probability\")"
	PopupMenu Dis1_DiameterWv,pos={6,335},size={157,21},title="Dia or Radii data:",proc=IR1U_PanelPopupControl, help={"Select wave with the radii or diameters for the above distribution"}
	PopupMenu Dis1_DiameterWv,mode=1,popvalue=root:Packages:SAS_Modeling:Dist1DiameterWvNm,value= #"\"---;\"+IR1_ListOfWavesInIFolder(1,\"Diameters\")"
	PopupMenu Dis1_ShapePopup,pos={6,360},size={158,21},proc=IR1U_PanelPopupControl,title="Scatterer shape  ", help={"Select shape of this population"}
	PopupMenu Dis1_ShapePopup,mode=1,popvalue=root:Packages:SAS_Modeling:Dist1ShapeModel,value= root:Packages:FormFactorCalc:ListOfFormFactors

	CheckBox Dis1_InputNumberDist,pos={275,315},size={80,14},title="Number dist?"
	CheckBox Dis1_InputNumberDist,value= 0,proc=IR1U_InputPanelCheckboxProc, help={"Check if these data are number distribution f(D) or f(R), uncheck if distribution is volume distribution V(D) or V(R)"}
	CheckBox Dis1_InputRadii,pos={275,337},size={48,14},title="Radii?",value= 0,proc=IR1U_InputPanelCheckboxProc, help={"Check if the data are in radii - V(R) or F(R), uncheck if the data are in diameters"}

	SetVariable Dis1_Volume,pos={6,390},size={158,16},proc=IR1U_PanelSetVarProc,title="Scat. volume [fract] ", help={"Volume fraction of this distribution. Preset to volume fraction of imported distribution."}
	SetVariable Dis1_Volume,limits={0,1,root:Packages:SAS_Modeling:Dist1VolStep},value= root:Packages:SAS_Modeling:Dist1VolFraction
	SetVariable Dis1_Contrast,pos={190,365},size={175,16},proc=IR1U_PanelSetVarProc,title="Contrast [*10^20 cm-4] "
	SetVariable Dis1_Contrast,limits={0,50000,1},value= root:Packages:SAS_Modeling:Dist1Contrast, help={"Contrast of this distribution"}
	SetVariable Dis1_DiamAddition,pos={6,410},size={158,16},proc=IR1U_PanelSetVarProc,title="Diameter shift  [A]    ", help={"Diameter shift DA. Allows the distribution to float in diameters Dnew=DM*(Dold+DA)"}
	SetVariable Dis1_DiamAddition,limits={-inf,inf,root:Packages:SAS_Modeling:Dist1DAstep}, value= root:Packages:SAS_Modeling:Dist1DiamAddition
	SetVariable Dis1_DiamMultiplier,pos={6,430},size={158,16},proc=IR1U_PanelSetVarProc,title="Diameter multiplier   ", help={"Diameter multiplier Dm. Allows the distribution to float in diameters Dnew=DM*(Dold+DA)"}
	SetVariable Dis1_DiamMultiplier,limits={-inf,inf,root:Packages:SAS_Modeling:Dist1DMStep},value= root:Packages:SAS_Modeling:Dist1DiamMultiplier

	SetVariable Dis1_Volstep,pos={165,390},size={60,16},proc=IR1U_PanelSetVarProc,title="step"
	SetVariable Dis1_Volstep,limits={0,1000,0},value= root:Packages:SAS_Modeling:Dist1Volstep, help={"Step for volume. Set to convenient value when manually changing the value of volume."}
	SetVariable Dis1_DAstep,pos={165,410},size={60,16},proc=IR1U_PanelSetVarProc,title="step"
	SetVariable Dis1_DAstep,limits={0,1000,0},value= root:Packages:SAS_Modeling:Dist1DAstep, help={"Step for DA. Set to convenient value when manually changing DA."}
	SetVariable Dis1_DMStep,pos={165,430},size={60,16},proc=IR1U_PanelSetVarProc,title="step"
	SetVariable Dis1_DMStep,limits={0,1000,0},value= root:Packages:SAS_Modeling:Dist1DMStep, help={"Step for DM. Set to convenient value when manually changiong DM."}

	SetVariable DIS1_Mode,pos={234,387},size={120,16},title="Dist. mode    = ", help={"Distribution mode. Calculated numerically."}
	SetVariable DIS1_Mode,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist1Mode, format="%.1f"
	SetVariable DIS1_Median,pos={234,404},size={120,16},title="Dist. median = ", help={"Distribution median. Calculated numerically."}
	SetVariable DIS1_Median,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist1Median, format="%.1f"
	SetVariable DIS1_Mean,pos={234,421},size={120,16},title="Dist. mean    = ", help={"Distribution mean. Calculated numerically. "}
	SetVariable DIS1_Mean,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist1Mean, format="%.1f"
	SetVariable DIS1_FWHM,pos={234,438},size={120,16},title="Dist. FWHM = ", help={"Distribution Full width at half maximum. Calcualted numerically."}
	SetVariable DIS1_FWHM,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist1FWHM, format="%.1f"

	//Distribution 1 fitting limits
	SetVariable Dis1_VolumeLow,pos={32,485},size={50,16},title=" ", help={"Low Volume fitting limit. Set correctly before fitting"}
	SetVariable Dis1_VolumeLow,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist1VolLowLimit
	SetVariable Dis1_VolumeHigh,pos={99,485},size={130,16},title="  < volume <     ", help={"High Volume fitting limit. Set correctly before fitting"}
	SetVariable Dis1_VolumeHigh,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist1VolHighLimit
	SetVariable Dis1_DALow,pos={32,505},size={50,16},title=" ", help={"Low DA fitting limit. Set correctly before fitting"}
	SetVariable Dis1_DALow,limits={-inf,0,0},value= root:Packages:SAS_Modeling:Dist1DALowLimit
	SetVariable Dis1_DAHigh,pos={97,505},size={130,16},title="  <  shift Dia  < ", help={"High DA fitting limit. Set correctly before fitting"}
	SetVariable Dis1_DAHigh,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist1DAHighLimit
	SetVariable Dis1_DMLow,pos={32,525},size={50,16},title=" ", help={"Low DM fitting limit. Set correctly before fitting"}
	SetVariable Dis1_DMLow,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist1DMLowLimit
	SetVariable Dis1_DMHigh,pos={97,525},size={130,16},title="  < multipl Dia <  ", help={"High DA fitting limit. Set correctly before fitting"}
	SetVariable Dis1_DMHigh,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist1DMHighLimit
	CheckBox Dis1_FitVolume,pos={250,485},size={73,14},proc=IR1U_InputPanelCheckboxProc,title="Fit Volume?"
	CheckBox Dis1_FitVolume,value= root:Packages:SAS_Modeling:Dist1FitVol, help={"Fit Volume. Will make limits visible/unvisible. Please select limits and starting conditions properly."}
	CheckBox Dis1_FitDA,pos={250,505},size={79,14},proc=IR1U_InputPanelCheckboxProc,title="Fit shift Dia?"
	CheckBox Dis1_FitDA,value= root:Packages:SAS_Modeling:Dist1FitDA, help={"Fit DA. Will make limits visible/unvisible. Please select limits and starting conditions properly."}
	CheckBox Dis1_FitDM,pos={250,525},size={65,14},proc=IR1U_InputPanelCheckboxProc,title="Fit Dia Multiplier?"
	CheckBox Dis1_FitDM,value= root:Packages:SAS_Modeling:Dist1FitDM, help={"Fit DM. Will make limits visible/unvisible. Please select limits and starting conditions properly."}
	//end of Distribution 1 controls....


	//Distribution 2 controls
	PopupMenu Dis2_DataFolder,pos={6,285},size={132,21},title="Data in folder      ",proc=IR1U_PanelPopupControl, help={"Select datafolder, which contains distribution data for this population"}
	PopupMenu Dis2_DataFolder,mode=1,popvalue=root:Packages:SAS_Modeling:Dist2FolderName,value= #"\"---;\"+IR1_GenStringOfFolders(0,0,0,0)"
	PopupMenu Dis2_ProbabilityWv,pos={6,310},size={150,21},title="Probability data:  ",proc=IR1U_PanelPopupControl, help={"Select wave with distribution - f(D) or f(R) or V(D) or V(R)"}
	PopupMenu Dis2_ProbabilityWv,mode=1,popvalue=root:Packages:SAS_Modeling:Dist2ProbabilityWvNm,value= #"\"---;\"+IR1_ListOfWavesInIFolder(2,\"Probability\")"
	PopupMenu Dis2_DiameterWv,pos={6,335},size={157,21},title="Dia or Radii data:",proc=IR1U_PanelPopupControl, help={"Select wave with the radii or diameters for the above distribution"}
	PopupMenu Dis2_DiameterWv,mode=1,popvalue=root:Packages:SAS_Modeling:Dist2DiameterWvNm,value= #"\"---;\"+IR1_ListOfWavesInIFolder(2,\"Diameters\")"
	PopupMenu Dis2_ShapePopup,pos={6,360},size={158,21},proc=IR1U_PanelPopupControl,title="Scatterer shape  ", help={"Select shape of this population"}
	PopupMenu Dis2_ShapePopup,mode=1,popvalue=root:Packages:SAS_Modeling:Dist2ShapeModel,value= root:Packages:FormFactorCalc:ListOfFormFactors

	CheckBox Dis2_InputNumberDist,pos={275,315},size={80,14},title="Number dist?"
	CheckBox Dis2_InputNumberDist,value= 0,proc=IR1U_InputPanelCheckboxProc, help={"Check if these data are number distribution f(D) or f(R), uncheck if distribution is volume distribution V(D) or V(R)"}
	CheckBox Dis2_InputRadii,pos={275,337},size={48,14},title="Radii?",value= 0,proc=IR1U_InputPanelCheckboxProc, help={"Check if the data are in radii - V(R) or F(R), uncheck if the data are in diameters"}

	SetVariable Dis2_Volume,pos={6,390},size={158,16},proc=IR1U_PanelSetVarProc,title="Scat. volume [fract] ", help={"Volume fraction of this distribution. Preset to volume fraction of imported distribution."}
	SetVariable Dis2_Volume,limits={0,1,root:Packages:SAS_Modeling:Dist2VolStep},value= root:Packages:SAS_Modeling:Dist2VolFraction
	SetVariable Dis2_Contrast,pos={190,365},size={175,16},proc=IR1U_PanelSetVarProc,title="Contrast [*10^20 cm-4] "
	SetVariable Dis2_Contrast,limits={0,50000,1},value= root:Packages:SAS_Modeling:Dist2Contrast, help={"Contrast of this distribution"}
	SetVariable Dis2_DiamAddition,pos={6,410},size={158,16},proc=IR1U_PanelSetVarProc,title="Diameter shift  [A]    ", help={"Diameter shift DA. Allows the distribution to float in diameters Dnew=DM*(Dold+DA)"}
	SetVariable Dis2_DiamAddition,limits={-inf,inf,root:Packages:SAS_Modeling:Dist2DAstep}, value= root:Packages:SAS_Modeling:Dist2DiamAddition
	SetVariable Dis2_DiamMultiplier,pos={6,430},size={158,16},proc=IR1U_PanelSetVarProc,title="Diameter multiplier   ", help={"Diameter multiplier Dm. Allows the distribution to float in diameters Dnew=DM*(Dold+DA)"}
	SetVariable Dis2_DiamMultiplier,limits={-inf,inf,root:Packages:SAS_Modeling:Dist2DMStep},value= root:Packages:SAS_Modeling:Dist2DiamMultiplier

	SetVariable Dis2_Volstep,pos={165,390},size={60,16},proc=IR1U_PanelSetVarProc,title="step"
	SetVariable Dis2_Volstep,limits={0,1000,0},value= root:Packages:SAS_Modeling:Dist2Volstep, help={"Step for volume. Set to convenient value when manually changing the value of volume."}
	SetVariable Dis2_DAstep,pos={165,410},size={60,16},proc=IR1U_PanelSetVarProc,title="step"
	SetVariable Dis2_DAstep,limits={0,1000,0},value= root:Packages:SAS_Modeling:Dist2DAstep, help={"Step for DA. Set to convenient value when manually changing DA."}
	SetVariable Dis2_DMStep,pos={165,430},size={60,16},proc=IR1U_PanelSetVarProc,title="step"
	SetVariable Dis2_DMStep,limits={0,1000,0},value= root:Packages:SAS_Modeling:Dist2DMStep, help={"Step for DM. Set to convenient value when manually changiong DM."}

	SetVariable Dis2_Mode,pos={234,387},size={120,16},title="Dist. mode    = ", help={"Distribution mode. Calculated numerically."}
	SetVariable Dis2_Mode,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist2Mode, format="%.1f"
	SetVariable Dis2_Median,pos={234,404},size={120,16},title="Dist. median = ", help={"Distribution median. Calculated numerically."}
	SetVariable Dis2_Median,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist2Median, format="%.1f"
	SetVariable Dis2_Mean,pos={234,421},size={120,16},title="Dist. mean    = ", help={"Distribution mean. Calculated numerically. "}
	SetVariable Dis2_Mean,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist2Mean, format="%.1f"
	SetVariable Dis2_FWHM,pos={234,438},size={120,16},title="Dist. FWHM = ", help={"Distribution Full width at half maximum. Calcualted numerically."}
	SetVariable Dis2_FWHM,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist2FWHM, format="%.1f"

	//Distribution 2 fitting limits
	SetVariable Dis2_VolumeLow,pos={32,485},size={50,16},title=" ", help={"Low Volume fitting limit. Set correctly before fitting"}
	SetVariable Dis2_VolumeLow,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist2VolLowLimit
	SetVariable Dis2_VolumeHigh,pos={99,485},size={130,16},title="  < volume <     ", help={"High Volume fitting limit. Set correctly before fitting"}
	SetVariable Dis2_VolumeHigh,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist2VolHighLimit
	SetVariable Dis2_DALow,pos={32,505},size={50,16},title=" ", help={"Low DA fitting limit. Set correctly before fitting"}
	SetVariable Dis2_DALow,limits={-inf,0,0},value= root:Packages:SAS_Modeling:Dist2DALowLimit
	SetVariable Dis2_DAHigh,pos={97,505},size={130,16},title="  <  shift Dia  < ", help={"High DA fitting limit. Set correctly before fitting"}
	SetVariable Dis2_DAHigh,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist2DAHighLimit
	SetVariable Dis2_DMLow,pos={32,525},size={50,16},title=" ", help={"Low DM fitting limit. Set correctly before fitting"}
	SetVariable Dis2_DMLow,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist2DMLowLimit
	SetVariable Dis2_DMHigh,pos={97,525},size={130,16},title="  < multipl Dia <  ", help={"High DA fitting limit. Set correctly before fitting"}
	SetVariable Dis2_DMHigh,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist2DMHighLimit
	CheckBox Dis2_FitVolume,pos={250,485},size={73,14},proc=IR1U_InputPanelCheckboxProc,title="Fit Volume?"
	CheckBox Dis2_FitVolume,value= root:Packages:SAS_Modeling:Dist2FitVol, help={"Fit Volume. Will make limits visible/unvisible. Please select limits and starting conditions properly."}
	CheckBox Dis2_FitDA,pos={250,505},size={79,14},proc=IR1U_InputPanelCheckboxProc,title="Fit shift Dia?"
	CheckBox Dis2_FitDA,value= root:Packages:SAS_Modeling:Dist2FitDA, help={"Fit DA. Will make limits visible/unvisible. Please select limits and starting conditions properly."}
	CheckBox Dis2_FitDM,pos={250,525},size={65,14},proc=IR1U_InputPanelCheckboxProc,title="Fit Dia Multiplier?"
	CheckBox Dis2_FitDM,value= root:Packages:SAS_Modeling:Dist2FitDM, help={"Fit DM. Will make limits visible/unvisible. Please select limits and starting conditions properly."}
//end of Distribution 2 controls....
//	
//	
//Distribution 3 controls
	PopupMenu Dis3_DataFolder,pos={6,285},size={132,21},title="Data in folder      ",proc=IR1U_PanelPopupControl, help={"Select datafolder, which contains distribution data for this population"}
	PopupMenu Dis3_DataFolder,mode=1,popvalue=root:Packages:SAS_Modeling:Dist3FolderName,value= #"\"---;\"+IR1_GenStringOfFolders(0,0,0,0)"
	PopupMenu Dis3_ProbabilityWv,pos={6,310},size={150,21},title="Probability data:  ",proc=IR1U_PanelPopupControl, help={"Select wave with distribution - f(D) or f(R) or V(D) or V(R)"}
	PopupMenu Dis3_ProbabilityWv,mode=1,popvalue=root:Packages:SAS_Modeling:Dist3ProbabilityWvNm,value= #"\"---;\"+IR1_ListOfWavesInIFolder(3,\"Probability\")"
	PopupMenu Dis3_DiameterWv,pos={6,335},size={157,21},title="Dia or Radii data:",proc=IR1U_PanelPopupControl, help={"Select wave with the radii or diameters for the above distribution"}
	PopupMenu Dis3_DiameterWv,mode=1,popvalue=root:Packages:SAS_Modeling:Dist3DiameterWvNm,value= #"\"---;\"+IR1_ListOfWavesInIFolder(3,\"Diameters\")"
	PopupMenu Dis3_ShapePopup,pos={6,360},size={158,21},proc=IR1U_PanelPopupControl,title="Scatterer shape  ", help={"Select shape of this population"}
	PopupMenu Dis3_ShapePopup,mode=1,popvalue=root:Packages:SAS_Modeling:Dist3ShapeModel,value= root:Packages:FormFactorCalc:ListOfFormFactors

	CheckBox Dis3_InputNumberDist,pos={275,315},size={80,14},title="Number dist?"
	CheckBox Dis3_InputNumberDist,value= 0,proc=IR1U_InputPanelCheckboxProc, help={"Check if these data are number distribution f(D) or f(R), uncheck if distribution is volume distribution V(D) or V(R)"}
	CheckBox Dis3_InputRadii,pos={275,337},size={48,14},title="Radii?",value= 0,proc=IR1U_InputPanelCheckboxProc, help={"Check if the data are in radii - V(R) or F(R), uncheck if the data are in diameters"}

	SetVariable Dis3_Volume,pos={6,390},size={158,16},proc=IR1U_PanelSetVarProc,title="Scat. volume [fract] ", help={"Volume fraction of this distribution. Preset to volume fraction of imported distribution."}
	SetVariable Dis3_Volume,limits={0,1,root:Packages:SAS_Modeling:Dist3VolStep},value= root:Packages:SAS_Modeling:Dist3VolFraction
	SetVariable Dis3_Contrast,pos={190,365},size={175,16},proc=IR1U_PanelSetVarProc,title="Contrast [*10^20 cm-4] "
	SetVariable Dis3_Contrast,limits={0,50000,1},value= root:Packages:SAS_Modeling:Dist3Contrast, help={"Contrast of this distribution"}
	SetVariable Dis3_DiamAddition,pos={6,410},size={158,16},proc=IR1U_PanelSetVarProc,title="Diameter shift  [A]    ", help={"Diameter shift DA. Allows the distribution to float in diameters Dnew=DM*(Dold+DA)"}
	SetVariable Dis3_DiamAddition,limits={-inf,inf,root:Packages:SAS_Modeling:Dist3DAstep}, value= root:Packages:SAS_Modeling:Dist3DiamAddition
	SetVariable Dis3_DiamMultiplier,pos={6,430},size={158,16},proc=IR1U_PanelSetVarProc,title="Diameter multiplier   ", help={"Diameter multiplier Dm. Allows the distribution to float in diameters Dnew=DM*(Dold+DA)"}
	SetVariable Dis3_DiamMultiplier,limits={-inf,inf,root:Packages:SAS_Modeling:Dist3DMStep},value= root:Packages:SAS_Modeling:Dist3DiamMultiplier

	SetVariable Dis3_Volstep,pos={165,390},size={60,16},proc=IR1U_PanelSetVarProc,title="step"
	SetVariable Dis3_Volstep,limits={0,1000,0},value= root:Packages:SAS_Modeling:Dist3Volstep, help={"Step for volume. Set to convenient value when manually changing the value of volume."}
	SetVariable Dis3_DAstep,pos={165,410},size={60,16},proc=IR1U_PanelSetVarProc,title="step"
	SetVariable Dis3_DAstep,limits={0,1000,0},value= root:Packages:SAS_Modeling:Dist3DAstep, help={"Step for DA. Set to convenient value when manually changing DA."}
	SetVariable Dis3_DMStep,pos={165,430},size={60,16},proc=IR1U_PanelSetVarProc,title="step"
	SetVariable Dis3_DMStep,limits={0,1000,0},value= root:Packages:SAS_Modeling:Dist3DMStep, help={"Step for DM. Set to convenient value when manually changiong DM."}

	SetVariable Dis3_Mode,pos={234,387},size={120,16},title="Dist. mode    = ", help={"Distribution mode. Calculated numerically."}
	SetVariable Dis3_Mode,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist3Mode, format="%.1f"
	SetVariable Dis3_Median,pos={234,404},size={120,16},title="Dist. median = ", help={"Distribution median. Calculated numerically."}
	SetVariable Dis3_Median,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist3Median, format="%.1f"
	SetVariable Dis3_Mean,pos={234,421},size={120,16},title="Dist. mean    = ", help={"Distribution mean. Calculated numerically. "}
	SetVariable Dis3_Mean,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist3Mean, format="%.1f"
	SetVariable Dis3_FWHM,pos={234,438},size={120,16},title="Dist. FWHM = ", help={"Distribution Full width at half maximum. Calcualted numerically."}
	SetVariable Dis3_FWHM,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist3FWHM, format="%.1f"

	//Distribution 3 fitting limits
	SetVariable Dis3_VolumeLow,pos={32,485},size={50,16},title=" ", help={"Low Volume fitting limit. Set correctly before fitting"}
	SetVariable Dis3_VolumeLow,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist3VolLowLimit
	SetVariable Dis3_VolumeHigh,pos={99,485},size={130,16},title="  < volume <     ", help={"High Volume fitting limit. Set correctly before fitting"}
	SetVariable Dis3_VolumeHigh,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist3VolHighLimit
	SetVariable Dis3_DALow,pos={32,505},size={50,16},title=" ", help={"Low DA fitting limit. Set correctly before fitting"}
	SetVariable Dis3_DALow,limits={-inf,0,0},value= root:Packages:SAS_Modeling:Dist3DALowLimit
	SetVariable Dis3_DAHigh,pos={97,505},size={130,16},title="  <  shift Dia  < ", help={"High DA fitting limit. Set correctly before fitting"}
	SetVariable Dis3_DAHigh,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist3DAHighLimit
	SetVariable Dis3_DMLow,pos={32,525},size={50,16},title=" ", help={"Low DM fitting limit. Set correctly before fitting"}
	SetVariable Dis3_DMLow,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist3DMLowLimit
	SetVariable Dis3_DMHigh,pos={97,525},size={130,16},title="  < multipl Dia <  ", help={"High DA fitting limit. Set correctly before fitting"}
	SetVariable Dis3_DMHigh,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist3DMHighLimit
	CheckBox Dis3_FitVolume,pos={250,485},size={73,14},proc=IR1U_InputPanelCheckboxProc,title="Fit Volume?"
	CheckBox Dis3_FitVolume,value= root:Packages:SAS_Modeling:Dist3FitVol, help={"Fit Volume. Will make limits visible/unvisible. Please select limits and starting conditions properly."}
	CheckBox Dis3_FitDA,pos={250,505},size={79,14},proc=IR1U_InputPanelCheckboxProc,title="Fit shift Dia?"
	CheckBox Dis3_FitDA,value= root:Packages:SAS_Modeling:Dist3FitDA, help={"Fit DA. Will make limits visible/unvisible. Please select limits and starting conditions properly."}
	CheckBox Dis3_FitDM,pos={250,525},size={65,14},proc=IR1U_InputPanelCheckboxProc,title="Fit Dia Multiplier?"
	CheckBox Dis3_FitDM,value= root:Packages:SAS_Modeling:Dist3FitDM, help={"Fit DM. Will make limits visible/unvisible. Please select limits and starting conditions properly."}

//end of Distribution 3 controls....
//
//
//Distribution 4 controls
	PopupMenu Dis4_DataFolder,pos={6,285},size={132,21},title="Data in folder      ",proc=IR1U_PanelPopupControl, help={"Select datafolder, which contains distribution data for this population"}
	PopupMenu Dis4_DataFolder,mode=1,popvalue=root:Packages:SAS_Modeling:Dist4FolderName,value= #"\"---;\"+IR1_GenStringOfFolders(0,0,0,0)"
	PopupMenu Dis4_ProbabilityWv,pos={6,310},size={150,21},title="Probability data:  ",proc=IR1U_PanelPopupControl, help={"Select wave with distribution - f(D) or f(R) or V(D) or V(R)"}
	PopupMenu Dis4_ProbabilityWv,mode=1,popvalue=root:Packages:SAS_Modeling:Dist4ProbabilityWvNm,value= #"\"---;\"+IR1_ListOfWavesInIFolder(4,\"Probability\")"
	PopupMenu Dis4_DiameterWv,pos={6,335},size={157,21},title="Dia or Radii data:",proc=IR1U_PanelPopupControl, help={"Select wave with the radii or diameters for the above distribution"}
	PopupMenu Dis4_DiameterWv,mode=1,popvalue=root:Packages:SAS_Modeling:Dist4DiameterWvNm,value= #"\"---;\"+IR1_ListOfWavesInIFolder(4,\"Diameters\")"
	PopupMenu Dis4_ShapePopup,pos={6,360},size={158,21},proc=IR1U_PanelPopupControl,title="Scatterer shape  ", help={"Select shape of this population"}
	PopupMenu Dis4_ShapePopup,mode=1,popvalue=root:Packages:SAS_Modeling:Dist4ShapeModel,value= root:Packages:FormFactorCalc:ListOfFormFactors

	CheckBox Dis4_InputNumberDist,pos={275,315},size={80,14},title="Number dist?"
	CheckBox Dis4_InputNumberDist,value= 0,proc=IR1U_InputPanelCheckboxProc, help={"Check if these data are number distribution f(D) or f(R), uncheck if distribution is volume distribution V(D) or V(R)"}
	CheckBox Dis4_InputRadii,pos={275,337},size={48,14},title="Radii?",value= 0,proc=IR1U_InputPanelCheckboxProc, help={"Check if the data are in radii - V(R) or F(R), uncheck if the data are in diameters"}

	SetVariable Dis4_Volume,pos={6,390},size={158,16},proc=IR1U_PanelSetVarProc,title="Scat. volume [fract] ", help={"Volume fraction of this distribution. Preset to volume fraction of imported distribution."}
	SetVariable Dis4_Volume,limits={0,1,root:Packages:SAS_Modeling:Dist4VolStep},value= root:Packages:SAS_Modeling:Dist4VolFraction
	SetVariable Dis4_Contrast,pos={190,365},size={175,16},proc=IR1U_PanelSetVarProc,title="Contrast [*10^20 cm-4] "
	SetVariable Dis4_Contrast,limits={0,50000,1},value= root:Packages:SAS_Modeling:Dist4Contrast, help={"Contrast of this distribution"}
	SetVariable Dis4_DiamAddition,pos={6,410},size={158,16},proc=IR1U_PanelSetVarProc,title="Diameter shift  [A]    ", help={"Diameter shift DA. Allows the distribution to float in diameters Dnew=DM*(Dold+DA)"}
	SetVariable Dis4_DiamAddition,limits={-inf,inf,root:Packages:SAS_Modeling:Dist4DAstep}, value= root:Packages:SAS_Modeling:Dist4DiamAddition
	SetVariable Dis4_DiamMultiplier,pos={6,430},size={158,16},proc=IR1U_PanelSetVarProc,title="Diameter multiplier   ", help={"Diameter multiplier Dm. Allows the distribution to float in diameters Dnew=DM*(Dold+DA)"}
	SetVariable Dis4_DiamMultiplier,limits={-inf,inf,root:Packages:SAS_Modeling:Dist4DMStep},value= root:Packages:SAS_Modeling:Dist4DiamMultiplier

	SetVariable Dis4_Volstep,pos={165,390},size={60,16},proc=IR1U_PanelSetVarProc,title="step"
	SetVariable Dis4_Volstep,limits={0,1000,0},value= root:Packages:SAS_Modeling:Dist4Volstep, help={"Step for volume. Set to convenient value when manually changing the value of volume."}
	SetVariable Dis4_DAstep,pos={165,410},size={60,16},proc=IR1U_PanelSetVarProc,title="step"
	SetVariable Dis4_DAstep,limits={0,1000,0},value= root:Packages:SAS_Modeling:Dist4DAstep, help={"Step for DA. Set to convenient value when manually changing DA."}
	SetVariable Dis4_DMStep,pos={165,430},size={60,16},proc=IR1U_PanelSetVarProc,title="step"
	SetVariable Dis4_DMStep,limits={0,1000,0},value= root:Packages:SAS_Modeling:Dist4DMStep, help={"Step for DM. Set to convenient value when manually changiong DM."}

	SetVariable Dis4_Mode,pos={234,387},size={120,16},title="Dist. mode    = ", help={"Distribution mode. Calculated numerically."}
	SetVariable Dis4_Mode,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist4Mode, format="%.1f"
	SetVariable Dis4_Median,pos={234,404},size={120,16},title="Dist. median = ", help={"Distribution median. Calculated numerically."}
	SetVariable Dis4_Median,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist4Median, format="%.1f"
	SetVariable Dis4_Mean,pos={234,421},size={120,16},title="Dist. mean    = ", help={"Distribution mean. Calculated numerically. "}
	SetVariable Dis4_Mean,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist4Mean, format="%.1f"
	SetVariable Dis4_FWHM,pos={234,438},size={120,16},title="Dist. FWHM = ", help={"Distribution Full width at half maximum. Calcualted numerically."}
	SetVariable Dis4_FWHM,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist4FWHM, format="%.1f"

	//Distribution 4 fitting limits
	SetVariable Dis4_VolumeLow,pos={32,485},size={50,16},title=" ", help={"Low Volume fitting limit. Set correctly before fitting"}
	SetVariable Dis4_VolumeLow,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist4VolLowLimit
	SetVariable Dis4_VolumeHigh,pos={99,485},size={130,16},title="  < volume <     ", help={"High Volume fitting limit. Set correctly before fitting"}
	SetVariable Dis4_VolumeHigh,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist4VolHighLimit
	SetVariable Dis4_DALow,pos={32,505},size={50,16},title=" ", help={"Low DA fitting limit. Set correctly before fitting"}
	SetVariable Dis4_DALow,limits={-inf,0,0},value= root:Packages:SAS_Modeling:Dist4DALowLimit
	SetVariable Dis4_DAHigh,pos={97,505},size={130,16},title="  <  shift Dia  < ", help={"High DA fitting limit. Set correctly before fitting"}
	SetVariable Dis4_DAHigh,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist4DAHighLimit
	SetVariable Dis4_DMLow,pos={32,525},size={50,16},title=" ", help={"Low DM fitting limit. Set correctly before fitting"}
	SetVariable Dis4_DMLow,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist4DMLowLimit
	SetVariable Dis4_DMHigh,pos={97,525},size={130,16},title="  < multipl Dia <  ", help={"High DA fitting limit. Set correctly before fitting"}
	SetVariable Dis4_DMHigh,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist4DMHighLimit
	CheckBox Dis4_FitVolume,pos={250,485},size={73,14},proc=IR1U_InputPanelCheckboxProc,title="Fit Volume?"
	CheckBox Dis4_FitVolume,value= root:Packages:SAS_Modeling:Dist4FitVol, help={"Fit Volume. Will make limits visible/unvisible. Please select limits and starting conditions properly."}
	CheckBox Dis4_FitDA,pos={250,505},size={79,14},proc=IR1U_InputPanelCheckboxProc,title="Fit shift Dia?"
	CheckBox Dis4_FitDA,value= root:Packages:SAS_Modeling:Dist4FitDA, help={"Fit DA. Will make limits visible/unvisible. Please select limits and starting conditions properly."}
	CheckBox Dis4_FitDM,pos={250,525},size={65,14},proc=IR1U_InputPanelCheckboxProc,title="Fit Dia Multiplier?"
	CheckBox Dis4_FitDM,value= root:Packages:SAS_Modeling:Dist4FitDM, help={"Fit DM. Will make limits visible/unvisible. Please select limits and starting conditions properly."}
//end of Distribution 4 controls....
//
//
//Distribution 5 controls
	PopupMenu Dis5_DataFolder,pos={6,285},size={132,21},title="Data in folder      ",proc=IR1U_PanelPopupControl, help={"Select datafolder, which contains distribution data for this population"}
	PopupMenu Dis5_DataFolder,mode=1,popvalue=root:Packages:SAS_Modeling:Dist5FolderName,value= #"\"---;\"+IR1_GenStringOfFolders(0,0,0,0)"
	PopupMenu Dis5_ProbabilityWv,pos={6,310},size={150,21},title="Probability data:  ",proc=IR1U_PanelPopupControl, help={"Select wave with distribution - f(D) or f(R) or V(D) or V(R)"}
	PopupMenu Dis5_ProbabilityWv,mode=1,popvalue=root:Packages:SAS_Modeling:Dist5ProbabilityWvNm,value= #"\"---;\"+IR1_ListOfWavesInIFolder(5,\"Probability\")"
	PopupMenu Dis5_DiameterWv,pos={6,335},size={157,21},title="Dia or Radii data:",proc=IR1U_PanelPopupControl, help={"Select wave with the radii or diameters for the above distribution"}
	PopupMenu Dis5_DiameterWv,mode=1,popvalue=root:Packages:SAS_Modeling:Dist5DiameterWvNm,value= #"\"---;\"+IR1_ListOfWavesInIFolder(5,\"Diameters\")"
	PopupMenu Dis5_ShapePopup,pos={6,360},size={158,21},proc=IR1U_PanelPopupControl,title="Scatterer shape  ", help={"Select shape of this population"}
	PopupMenu Dis5_ShapePopup,mode=1,popvalue=root:Packages:SAS_Modeling:Dist5ShapeModel,value= root:Packages:FormFactorCalc:ListOfFormFactors

	CheckBox Dis5_InputNumberDist,pos={275,315},size={80,14},title="Number dist?"
	CheckBox Dis5_InputNumberDist,value= 0,proc=IR1U_InputPanelCheckboxProc, help={"Check if these data are number distribution f(D) or f(R), uncheck if distribution is volume distribution V(D) or V(R)"}
	CheckBox Dis5_InputRadii,pos={275,337},size={48,14},title="Radii?",value= 0,proc=IR1U_InputPanelCheckboxProc, help={"Check if the data are in radii - V(R) or F(R), uncheck if the data are in diameters"}

	SetVariable Dis5_Volume,pos={6,390},size={158,16},proc=IR1U_PanelSetVarProc,title="Scat. volume [fract] ", help={"Volume fraction of this distribution. Preset to volume fraction of imported distribution."}
	SetVariable Dis5_Volume,limits={0,1,root:Packages:SAS_Modeling:Dist5VolStep},value= root:Packages:SAS_Modeling:Dist5VolFraction
	SetVariable Dis5_Contrast,pos={190,365},size={175,16},proc=IR1U_PanelSetVarProc,title="Contrast [*10^20 cm-4] "
	SetVariable Dis5_Contrast,limits={0,50000,1},value= root:Packages:SAS_Modeling:Dist5Contrast, help={"Contrast of this distribution"}
	SetVariable Dis5_DiamAddition,pos={6,410},size={158,16},proc=IR1U_PanelSetVarProc,title="Diameter shift  [A]    ", help={"Diameter shift DA. Allows the distribution to float in diameters Dnew=DM*(Dold+DA)"}
	SetVariable Dis5_DiamAddition,limits={-inf,inf,root:Packages:SAS_Modeling:Dist5DAstep}, value= root:Packages:SAS_Modeling:Dist5DiamAddition
	SetVariable Dis5_DiamMultiplier,pos={6,430},size={158,16},proc=IR1U_PanelSetVarProc,title="Diameter multiplier   ", help={"Diameter multiplier Dm. Allows the distribution to float in diameters Dnew=DM*(Dold+DA)"}
	SetVariable Dis5_DiamMultiplier,limits={-inf,inf,root:Packages:SAS_Modeling:Dist5DMStep},value= root:Packages:SAS_Modeling:Dist5DiamMultiplier

	SetVariable Dis5_Volstep,pos={165,390},size={60,16},proc=IR1U_PanelSetVarProc,title="step"
	SetVariable Dis5_Volstep,limits={0,1000,0},value= root:Packages:SAS_Modeling:Dist5Volstep, help={"Step for volume. Set to convenient value when manually changing the value of volume."}
	SetVariable Dis5_DAstep,pos={165,410},size={60,16},proc=IR1U_PanelSetVarProc,title="step"
	SetVariable Dis5_DAstep,limits={0,1000,0},value= root:Packages:SAS_Modeling:Dist5DAstep, help={"Step for DA. Set to convenient value when manually changing DA."}
	SetVariable Dis5_DMStep,pos={165,430},size={60,16},proc=IR1U_PanelSetVarProc,title="step"
	SetVariable Dis5_DMStep,limits={0,1000,0},value= root:Packages:SAS_Modeling:Dist5DMStep, help={"Step for DM. Set to convenient value when manually changiong DM."}

	SetVariable Dis5_Mode,pos={234,387},size={120,16},title="Dist. mode    = ", help={"Distribution mode. Calculated numerically."}
	SetVariable Dis5_Mode,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist5Mode, format="%.1f"
	SetVariable Dis5_Median,pos={234,404},size={120,16},title="Dist. median = ", help={"Distribution median. Calculated numerically."}
	SetVariable Dis5_Median,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist5Median, format="%.1f"
	SetVariable Dis5_Mean,pos={234,421},size={120,16},title="Dist. mean    = ", help={"Distribution mean. Calculated numerically. "}
	SetVariable Dis5_Mean,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist5Mean, format="%.1f"
	SetVariable Dis5_FWHM,pos={234,438},size={120,16},title="Dist. FWHM = ", help={"Distribution Full width at half maximum. Calcualted numerically."}
	SetVariable Dis5_FWHM,limits={-Inf,Inf,0},value= root:Packages:SAS_Modeling:Dist5FWHM, format="%.1f"

	//Distribution 5 fitting limits
	SetVariable Dis5_VolumeLow,pos={32,485},size={50,16},title=" ", help={"Low Volume fitting limit. Set correctly before fitting"}
	SetVariable Dis5_VolumeLow,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist5VolLowLimit
	SetVariable Dis5_VolumeHigh,pos={99,485},size={130,16},title="  < volume <     ", help={"High Volume fitting limit. Set correctly before fitting"}
	SetVariable Dis5_VolumeHigh,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist5VolHighLimit
	SetVariable Dis5_DALow,pos={32,505},size={50,16},title=" ", help={"Low DA fitting limit. Set correctly before fitting"}
	SetVariable Dis5_DALow,limits={-inf,0,0},value= root:Packages:SAS_Modeling:Dist5DALowLimit
	SetVariable Dis5_DAHigh,pos={97,505},size={130,16},title="  <  shift Dia  < ", help={"High DA fitting limit. Set correctly before fitting"}
	SetVariable Dis5_DAHigh,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist5DAHighLimit
	SetVariable Dis5_DMLow,pos={32,525},size={50,16},title=" ", help={"Low DM fitting limit. Set correctly before fitting"}
	SetVariable Dis5_DMLow,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist5DMLowLimit
	SetVariable Dis5_DMHigh,pos={97,525},size={130,16},title="  < multipl Dia <  ", help={"High DA fitting limit. Set correctly before fitting"}
	SetVariable Dis5_DMHigh,limits={0,Inf,0},value= root:Packages:SAS_Modeling:Dist5DMHighLimit
	CheckBox Dis5_FitVolume,pos={250,485},size={73,14},proc=IR1U_InputPanelCheckboxProc,title="Fit Volume?"
	CheckBox Dis5_FitVolume,value= root:Packages:SAS_Modeling:Dist5FitVol, help={"Fit Volume. Will make limits visible/unvisible. Please select limits and starting conditions properly."}
	CheckBox Dis5_FitDA,pos={250,505},size={79,14},proc=IR1U_InputPanelCheckboxProc,title="Fit shift Dia?"
	CheckBox Dis5_FitDA,value= root:Packages:SAS_Modeling:Dist5FitDA, help={"Fit DA. Will make limits visible/unvisible. Please select limits and starting conditions properly."}
	CheckBox Dis5_FitDM,pos={250,525},size={65,14},proc=IR1U_InputPanelCheckboxProc,title="Fit Dia Multiplier?"
	CheckBox Dis5_FitDM,value= root:Packages:SAS_Modeling:Dist5FitDM, help={"Fit DM. Will make limits visible/unvisible. Please select limits and starting conditions properly."}
//end of Distribution 5 controls....

	//lets try to update the tabs...
	IR1U_TabPanelControl("test",0)

EndMacro

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
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

	if (cmpstr(ctrlName,"SelectDataFolder")==0)
		//here we do what needs to be done when we select data folder
		Dtf=popStr
		PopupMenu IntensityDataName mode=1
		PopupMenu QvecDataName mode=1
		PopupMenu ErrorDataName mode=1
		if (UseIndra2Data)
			if(stringmatch(IR1_ListOfWaves("DSM_Int","SAS_Modeling",0,0), "*M_BKG_Int*") &&stringmatch(IR1_ListOfWaves("DSM_Qvec","SAS_Modeling",0,0), "*M_BKG_Qvec*")  &&stringmatch(IR1_ListOfWaves("DSM_Error","SAS_Modeling",0,0), "*M_BKG_Error*") )			
				IntDf="M_BKG_Int"
				QDf="M_BKG_Qvec"
				EDf="M_BKG_Error"
				PopupMenu IntensityDataName value="M_BKG_Int;M_DSM_Int;DSM_Int"
				PopupMenu QvecDataName value="M_BKG_Qvec;M_DSM_Qvec;DSM_Qvec"
				PopupMenu ErrorDataName value="M_BKG_Error;M_DSM_Error;DSM_Error"
			elseif(stringmatch(IR1_ListOfWaves("DSM_Int","SAS_Modeling",0,0), "*BKG_Int*") &&stringmatch(IR1_ListOfWaves("DSM_Qvec","SAS_Modeling",0,0), "*BKG_Qvec*")  &&stringmatch(IR1_ListOfWaves("DSM_Error","SAS_Modeling",0,0), "*BKG_Error*") )			
				IntDf="BKG_Int"
				QDf="BKG_Qvec"
				EDf="BKG_Error"
				PopupMenu IntensityDataName value="BKG_Int;DSM_Int"
				PopupMenu QvecDataName value="BKG_Qvec;DSM_Qvec"
				PopupMenu ErrorDataName value="BKG_Error;DSM_Error"
			elseif(stringmatch(IR1_ListOfWaves("DSM_Int","SAS_Modeling",0,0), "*M_DSM_Int*") &&stringmatch(IR1_ListOfWaves("DSM_Qvec","SAS_Modeling",0,0), "*M_DSM_Qvec*")  &&stringmatch(IR1_ListOfWaves("DSM_Error","SAS_Modeling",0,0), "*M_DSM_Error*") )			
				IntDf="M_DSM_Int"
				QDf="M_DSM_Qvec"
				EDf="M_DSM_Error"
				PopupMenu IntensityDataName value="M_DSM_Int;DSM_Int"
				PopupMenu QvecDataName value="M_DSM_Qvec;DSM_Qvec"
				PopupMenu ErrorDataName value="M_DSM_Error;DSM_Error"
			else
				if(!stringmatch(IR1_ListOfWaves("DSM_Int","SAS_Modeling",0,0), "*M_DSM_Int*") &&!stringmatch(IR1_ListOfWaves("DSM_Qvec","SAS_Modeling",0,0), "*M_DSM_Qvec*")  &&!stringmatch(IR1_ListOfWaves("DSM_Error","SAS_Modeling",0,0), "*M_DSM_Error*") )			
					IntDf="DSM_Int"
					QDf="DSM_Qvec"
					EDf="DSM_Error"
					PopupMenu IntensityDataName value="DSM_Int"
					PopupMenu QvecDataName value="DSM_Qvec"
					PopupMenu ErrorDataName value="DSM_Error"
				endif
			endif
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
			PopupMenu IntensityDataName  value="---;"+IR1_ListOfWaves("DSM_Int","SAS_Modeling",0,0)
			PopupMenu QvecDataName  value="---;"+IR1_ListOfWaves("DSM_Qvec","SAS_Modeling",0,0)
			PopupMenu ErrorDataName  value="---;"+IR1_ListOfWaves("DSM_Error","SAS_Modeling",0,0)
		endif
		if(!UseQRSdata && !UseIndra2Data)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---;"+IR1_ListOfWaves("DSM_Int","SAS_Modeling",0,0)
			PopupMenu QvecDataName  value="---;"+IR1_ListOfWaves("DSM_Qvec","SAS_Modeling",0,0)
			PopupMenu ErrorDataName  value="---;"+IR1_ListOfWaves("DSM_Error","SAS_Modeling",0,0)
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
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:SAS_Modeling:QWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"SAS_Modeling\",0,0)")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:SAS_Modeling:ErrorWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Error\",\"SAS_Modeling\",0,0)")
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
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:SAS_Modeling:IntensityWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Int\",\"SAS_Modeling\",0,0)")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:SAS_Modeling:ErrorWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Error\",\"SAS_Modeling\",0,0)")
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
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:SAS_Modeling:IntensityWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Int\",\"SAS_Modeling\",0,0)")
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:SAS_Modeling:QWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"SAS_Modeling\",0,0)")
			endif
		else
			EDf=""		
		endif
	endif
	
	if (cmpstr(ctrlName,"NumberOfDistributions")==0)
		//here goes what happens when we change number of distributions
		NVAR nmbdist=root:Packages:SAS_Modeling:NumberOfDistributions
		nmbdist=popNum-1
		IR1U_FixTabsInPanel()
		IR1U_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis1_ShapePopup")==0)
		//here goes what happens when user selects shape in the panel
		//and that means, depending on the shape selected we need to get another panel with parameters
		//we have 3 universal shape parameters available for each shape type:
		//Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3		
		IR1S_ResetScatShapeFitParam(1)		//Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3
		SetVariable Dis1_Contrast, disable=0,win=IR1U_ControlPanel
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
		if (cmpstr(popStr,"tube")==0)
			SetVariable Dis1_Contrast, disable=1,win=IR1U_ControlPanel
			Execute ("Dis_tube_Panel(1)")
		endif
		if (cmpstr(popStr,"CoreShell")==0)
			SetVariable Dis1_Contrast, disable=1,win=IR1U_ControlPanel
			Execute ("Dis_CoreShell_Input_Panel(1)")
		endif
		if (cmpstr(popStr,"Fractal Aggregate")==0)
			Execute ("Dis_FractalAgg_Input_Panel(1)")
		endif
		if (cmpstr(popStr,"User")==0)
			Execute ("Dis_UserFFInputPanel(1)")
		endif
		
		SVAR Dist1ShapeModel=root:Packages:SAS_Modeling:Dist1ShapeModel
		Dist1ShapeModel=popstr
		//create and recalculate the distributions
		IR1U_CopyUserWavesToOriginal()
		IR1U_CreateDistributionWaves()
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis2_ShapePopup")==0)
		//here goes what happens when user selects shape in the panel
		//and that means, depending on the shape selected we need to get another panel with parameters
		//we have 3 universal shape parameters available for each shape type:
		IR1S_ResetScatShapeFitParam(2)		//Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3
		//Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3
		SetVariable Dis2_Contrast, disable=0,win=IR1U_ControlPanel
		
		DoWindow Shape_Model_Input_Panel
		if (V_Flag)
			DoWindow/K Shape_Model_Input_Panel
		endif
		//create new window as needed
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
		if (cmpstr(popStr,"tube")==0)
			SetVariable Dis2_Contrast, disable=1,win=IR1U_ControlPanel
			Execute ("Dis_tube_Panel(2)")
		endif
		if (cmpstr(popStr,"CoreShell")==0)
			SetVariable Dis2_Contrast, disable=1,win=IR1U_ControlPanel
			Execute ("Dis_CoreShell_Input_Panel(2)")
		endif
		if (cmpstr(popStr,"Fractal Aggregate")==0)
			Execute ("Dis_FractalAgg_Input_Panel(2)")
		endif
		if (cmpstr(popStr,"User")==0)
			Execute ("Dis_UserFFInputPanel(2)")
		endif
		SVAR Dist2ShapeModel=root:Packages:SAS_Modeling:Dist2ShapeModel
		Dist2ShapeModel=popstr
		//create and recalculate the distributions
		IR1U_CopyUserWavesToOriginal()
		IR1U_CreateDistributionWaves()
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis3_ShapePopup")==0)
		//here goes what happens when user selects shape in the panel
		//and that means, depending on the shape selected we need to get another panel with parameters
		//we have 3 universal shape parameters available for each shape type:
		//Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3
		SetVariable Dis3_Contrast, disable=0,win=IR1U_ControlPanel
		
		IR1S_ResetScatShapeFitParam(3)		//Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3
		
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
		if (cmpstr(popStr,"tube")==0)
			SetVariable Dis3_Contrast, disable=1,win=IR1U_ControlPanel
			Execute ("Dis_tube_Panel(3)")
		endif
		if (cmpstr(popStr,"CoreShell")==0)
			SetVariable Dis3_Contrast, disable=1,win=IR1U_ControlPanel
			Execute ("Dis_CoreShell_Input_Panel(3)")
		endif
		if (cmpstr(popStr,"Fractal Aggregate")==0)
			Execute ("Dis_FractalAgg_Input_Panel(3)")
		endif
		if (cmpstr(popStr,"User")==0)
			Execute ("Dis_UserFFInputPanel(3)")
		endif
		SVAR Dist3ShapeModel=root:Packages:SAS_Modeling:Dist3ShapeModel
		Dist3ShapeModel=popstr
		//create and recalculate the distributions
		IR1U_CopyUserWavesToOriginal()
		IR1U_CreateDistributionWaves()
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis4_ShapePopup")==0)
		//here goes what happens when user selects shape in the panel
		//and that means, depending on the shape selected we need to get another panel with parameters
		//we have 3 universal shape parameters available for each shape type:
		//Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3
		SetVariable Dis4_Contrast, disable=0,win=IR1U_ControlPanel
		IR1S_ResetScatShapeFitParam(4)
		
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
		if (cmpstr(popStr,"tube")==0)
			SetVariable Dis4_Contrast, disable=1,win=IR1U_ControlPanel
			Execute ("Dis_tube_Panel(4)")
		endif
		if (cmpstr(popStr,"CoreShell")==0)
			SetVariable Dis4_Contrast, disable=1,win=IR1U_ControlPanel
			Execute ("Dis_CoreShell_Input_Panel(4)")
		endif
		if (cmpstr(popStr,"Fractal Aggregate")==0)
			Execute ("Dis_FractalAgg_Input_Panel(4)")
		endif
		if (cmpstr(popStr,"User")==0)
			Execute ("Dis_UserFFInputPanel(4)")
		endif
		SVAR Dist4ShapeModel=root:Packages:SAS_Modeling:Dist4ShapeModel
		Dist4ShapeModel=popstr
		//create and recalculate the distributions
		IR1U_CopyUserWavesToOriginal()
		IR1U_CreateDistributionWaves()
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis5_ShapePopup")==0)
		//here goes what happens when user selects shape in the panel
		//and that means, depending on the shape selected we need to get another panel with parameters
		//we have 3 universal shape parameters available for each shape type:
		//Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3
		IR1S_ResetScatShapeFitParam(5)
		SetVariable Dis5_Contrast, disable=1,win=IR1U_ControlPanel
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
		if (cmpstr(popStr,"tube")==0)
			SetVariable Dis5_Contrast, disable=1,win=IR1U_ControlPanel
			Execute ("Dis_tube_Panel(5)")
		endif
		if (cmpstr(popStr,"CoreShell")==0)
			SetVariable Dis5_Contrast, disable=1,win=IR1U_ControlPanel
			Execute ("Dis_CoreShell_Input_Panel(5)")
		endif
		if (cmpstr(popStr,"Fractal Aggregate")==0)
			Execute ("Dis_FractalAgg_Input_Panel(5)")
		endif
		if (cmpstr(popStr,"User")==0)
			Execute ("Dis_UserFFInputPanel(5)")
		endif
		SVAR Dist5ShapeModel=root:Packages:SAS_Modeling:Dist5ShapeModel
		Dist5ShapeModel=popstr
		//create and recalculate the distributions
		IR1U_CopyUserWavesToOriginal()
		IR1U_CreateDistributionWaves()
		IR1U_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis1_DataFolder")==0)
		SVAR Dist1FolderName=root:Packages:SAS_Modeling:Dist1FolderName
		SVAR Dist1DiameterWvNm=root:Packages:SAS_Modeling:Dist1DiameterWvNm
		SVAR Dist1ProbabilityWvNm=root:Packages:SAS_Modeling:Dist1ProbabilityWvNm
		Dist1FolderName=popStr
		Dist1DiameterWvNm=""
		Dist1ProbabilityWvNm=""
		PopupMenu Dis1_ProbabilityWv,mode=1
		PopupMenu Dis1_DiameterWv,mode=1
		//and whatever else will be needed to so here, when I change the data folder name
	endif
	if (cmpstr(ctrlName,"Dis1_ProbabilityWv")==0)
		SVAR Dist1DiameterWvNm=root:Packages:SAS_Modeling:Dist1DiameterWvNm
		SVAR Dist1ProbabilityWvNm=root:Packages:SAS_Modeling:Dist1ProbabilityWvNm
		Dist1DiameterWvNm=""
		Dist1ProbabilityWvNm=popStr
		PopupMenu Dis1_DiameterWv,mode=1
		//and whatever else will be needed to so here, when I change the Probability data name
	endif
	if (cmpstr(ctrlName,"Dis1_DiameterWv")==0)
		SVAR Dist1DiameterWvNm=root:Packages:SAS_Modeling:Dist1DiameterWvNm
		SVAR Dist1ProbabilityWvNm=root:Packages:SAS_Modeling:Dist1ProbabilityWvNm
		Dist1DiameterWvNm=popStr
		//and whatever else will be needed to so here, when I change the Probability data name
		IR1U_CopyUserWavesToOriginal()	//this copies the waves in local folder, if both waves types set
		IR1U_AutoUpdateIfSelected()
	endif
 	if (cmpstr(ctrlName,"Dis2_DataFolder")==0)
		SVAR Dist2FolderName=root:Packages:SAS_Modeling:Dist2FolderName
		SVAR Dist2DiameterWvNm=root:Packages:SAS_Modeling:Dist2DiameterWvNm
		SVAR Dist2ProbabilityWvNm=root:Packages:SAS_Modeling:Dist2ProbabilityWvNm
		Dist2FolderName=popStr
		Dist2DiameterWvNm=""
		Dist2ProbabilityWvNm=""
		PopupMenu Dis2_ProbabilityWv,mode=1
		PopupMenu Dis2_DiameterWv,mode=1
		//and whatever else will be needed to so here, when I change the data folder name
		IR1U_CopyUserWavesToOriginal()	//this copies the waves in local folder, if both waves types set
	endif
	if (cmpstr(ctrlName,"Dis2_ProbabilityWv")==0)
		SVAR Dist2DiameterWvNm=root:Packages:SAS_Modeling:Dist2DiameterWvNm
		SVAR Dist2ProbabilityWvNm=root:Packages:SAS_Modeling:Dist2ProbabilityWvNm
		Dist2DiameterWvNm=""
		Dist2ProbabilityWvNm=popStr
		PopupMenu Dis2_DiameterWv,mode=1
		//and whatever else will be needed to so here, when I change the Probability data name
		IR1U_CopyUserWavesToOriginal()	//this copies the waves in local folder, if both waves types set
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis2_DiameterWv")==0)
		SVAR Dist2DiameterWvNm=root:Packages:SAS_Modeling:Dist2DiameterWvNm
		SVAR Dist2ProbabilityWvNm=root:Packages:SAS_Modeling:Dist2ProbabilityWvNm
		Dist2DiameterWvNm=popStr
		//and whatever else will be needed to so here, when I change the Probability data name
		IR1U_CopyUserWavesToOriginal()	//this copies the waves in local folder, if both waves types set
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis3_DataFolder")==0)
		SVAR Dist3FolderName=root:Packages:SAS_Modeling:Dist3FolderName
		SVAR Dist3DiameterWvNm=root:Packages:SAS_Modeling:Dist3DiameterWvNm
		SVAR Dist3ProbabilityWvNm=root:Packages:SAS_Modeling:Dist3ProbabilityWvNm
		Dist3FolderName=popStr
		Dist3DiameterWvNm=""
		Dist3ProbabilityWvNm=""
		PopupMenu Dis3_ProbabilityWv,mode=1
		PopupMenu Dis3_DiameterWv,mode=1
		//and whatever else will be needed to so here, when I change the data folder name
		IR1U_CopyUserWavesToOriginal()	//this copies the waves in local folder, if both waves types set
	endif
	if (cmpstr(ctrlName,"Dis3_ProbabilityWv")==0)
		SVAR Dist3DiameterWvNm=root:Packages:SAS_Modeling:Dist3DiameterWvNm
		SVAR Dist3ProbabilityWvNm=root:Packages:SAS_Modeling:Dist3ProbabilityWvNm
		Dist3DiameterWvNm=""
		Dist3ProbabilityWvNm=popStr
		PopupMenu Dis3_DiameterWv,mode=1
		//and whatever else will be needed to so here, when I change the Probability data name
		IR1U_CopyUserWavesToOriginal()	//this copies the waves in local folder, if both waves types set
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis3_DiameterWv")==0)
		SVAR Dist3DiameterWvNm=root:Packages:SAS_Modeling:Dist3DiameterWvNm
		SVAR Dist3ProbabilityWvNm=root:Packages:SAS_Modeling:Dist3ProbabilityWvNm
		Dist3DiameterWvNm=popStr
		//and whatever else will be needed to so here, when I change the Probability data name
		IR1U_CopyUserWavesToOriginal()	//this copies the waves in local folder, if both waves types set
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis4_DataFolder")==0)
		SVAR Dist4FolderName=root:Packages:SAS_Modeling:Dist4FolderName
		SVAR Dist4DiameterWvNm=root:Packages:SAS_Modeling:Dist4DiameterWvNm
		SVAR Dist4ProbabilityWvNm=root:Packages:SAS_Modeling:Dist4ProbabilityWvNm
		Dist4FolderName=popStr
		Dist4DiameterWvNm=""
		Dist4ProbabilityWvNm=""
		PopupMenu Dis4_ProbabilityWv,mode=1
		PopupMenu Dis4_DiameterWv,mode=1
		//and whatever else will be needed to so here, when I change the data folder name
		IR1U_CopyUserWavesToOriginal()	//this copies the waves in local folder, if both waves types set
	endif
	if (cmpstr(ctrlName,"Dis4_ProbabilityWv")==0)
		SVAR Dist4DiameterWvNm=root:Packages:SAS_Modeling:Dist4DiameterWvNm
		SVAR Dist4ProbabilityWvNm=root:Packages:SAS_Modeling:Dist4ProbabilityWvNm
		Dist4DiameterWvNm=""
		Dist4ProbabilityWvNm=popStr
		PopupMenu Dis4_DiameterWv,mode=1
		//and whatever else will be needed to so here, when I change the Probability data name
		IR1U_CopyUserWavesToOriginal()	//this copies the waves in local folder, if both waves types set
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis4_DiameterWv")==0)
		SVAR Dist4DiameterWvNm=root:Packages:SAS_Modeling:Dist4DiameterWvNm
		SVAR Dist4ProbabilityWvNm=root:Packages:SAS_Modeling:Dist4ProbabilityWvNm
		Dist4DiameterWvNm=popStr
		//and whatever else will be needed to so here, when I change the Probability data name
		IR1U_CopyUserWavesToOriginal()	//this copies the waves in local folder, if both waves types set
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis5_DataFolder")==0)
		SVAR Dist5FolderName=root:Packages:SAS_Modeling:Dist5FolderName
		SVAR Dist5DiameterWvNm=root:Packages:SAS_Modeling:Dist5DiameterWvNm
		SVAR Dist5ProbabilityWvNm=root:Packages:SAS_Modeling:Dist5ProbabilityWvNm
		Dist5FolderName=popStr
		Dist5DiameterWvNm=""
		Dist5ProbabilityWvNm=""
		PopupMenu Dis5_ProbabilityWv,mode=1
		PopupMenu Dis5_DiameterWv,mode=1
		//and whatever else will be needed to so here, when I change the data folder name
		IR1U_CopyUserWavesToOriginal()	//this copies the waves in local folder, if both waves types set
	endif
	if (cmpstr(ctrlName,"Dis5_ProbabilityWv")==0)
		SVAR Dist5DiameterWvNm=root:Packages:SAS_Modeling:Dist5DiameterWvNm
		SVAR Dist5ProbabilityWvNm=root:Packages:SAS_Modeling:Dist5ProbabilityWvNm
		Dist5DiameterWvNm=""
		Dist5ProbabilityWvNm=popStr
		PopupMenu Dis5_DiameterWv,mode=1
		//and whatever else will be needed to so here, when I change the Probability data name
		IR1U_CopyUserWavesToOriginal()	//this copies the waves in local folder, if both waves types set
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis5_DiameterWv")==0)
		SVAR Dist5DiameterWvNm=root:Packages:SAS_Modeling:Dist5DiameterWvNm
		SVAR Dist5ProbabilityWvNm=root:Packages:SAS_Modeling:Dist5ProbabilityWvNm
		Dist5DiameterWvNm=popStr
		//and whatever else will be needed to so here, when I change the Probability data name
		IR1U_CopyUserWavesToOriginal()	//this copies the waves in local folder, if both waves types set
		IR1U_AutoUpdateIfSelected()
	endif	
	setDataFolder oldDF

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_InputPanelButtonProc(ctrlName) : ButtonControl
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
			IR1_GraphMeasuredData("LSQF")
		else
			Abort "Data not selected properly"
		endif
	endif

	if(cmpstr(ctrlName,"DoFitting")==0)
		//here we call the fitting routine
		IR1U_ConstructTheFittingCommand()
	endif
	if(cmpstr(ctrlName,"RevertFitting")==0)
		//here we call the fitting routine
		IR1U_ResetParamsAfterBadFit()
		IR1U_GraphModelData()
	endif
	if(cmpstr(ctrlName,"GraphDistribution")==0)
		//here we graph the distribution
		IR1U_GraphModelData()
	endif
	if(cmpstr(ctrlName,"CopyToFolder")==0)
		//here we copy final data back to original data folder		I	
		IR1_CopyDataBackToFolder("user")
	//	DoAlert 0,"Copy"
	endif
	
	if(cmpstr(ctrlName,"ExportData")==0)
		//here we export ASCII form of the data
		IR1_ExportASCIIResults("user")
	//	DoAlert 0, "Export"
	endif
	setDataFolder oldDF
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_TabPanelControl(name,tab)
	String name
	Variable tab

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling
	NVAR CurrentTab
	CurrentTab=tab

	NVAR Nmbdist=root:Packages:SAS_Modeling:NumberOfDistributions
	//need to kill any outstanding windows for shapes... ANy... All should have the same name...
	DoWindow Shape_Model_Input_Panel
	if (V_Flag)
		DoWindow/K Shape_Model_Input_Panel
	endif
	DoWindow/F IR1U_ControlPanel

	NVAR Dist1FitVol=root:Packages:SAS_Modeling:Dist1FitVol
	NVAR Dist1FitDA=root:Packages:SAS_Modeling:Dist1FitDA
	NVAR Dist1FitDM=root:Packages:SAS_Modeling:Dist1FitDM

	PopupMenu Dis1_DataFolder,disable= (tab!=0 || Nmbdist<1)
	PopupMenu Dis1_ProbabilityWv,disable= (tab!=0 || Nmbdist<1)
	PopupMenu Dis1_DiameterWv,disable= (tab!=0 || Nmbdist<1)
	PopupMenu Dis1_ShapePopup,disable= (tab!=0 || Nmbdist<1)
	CheckBox Dis1_InputNumberDist,disable= (tab!=0 || Nmbdist<1)
	CheckBox Dis1_InputRadii,disable= (tab!=0 || Nmbdist<1)
	SetVariable Dis1_Volume,disable= (tab!=0 || Nmbdist<1)
	SVAR Dist1ShapeModel=root:Packages:SAS_Modeling:Dist1ShapeModel
	SetVariable Dis1_Contrast,disable= (tab!=0 || Nmbdist<1|| cmpstr(Dist1ShapeModel,"CoreShell")==0 || cmpstr(Dist1ShapeModel,"Tube")==0 ), win=IR1U_ControlPanel
	SetVariable Dis1_DiamAddition,disable= (tab!=0 || Nmbdist<1)
	SetVariable Dis1_DiamMultiplier,disable= (tab!=0 || Nmbdist<1)
	SetVariable Dis1_Volstep,disable= (tab!=0 || Nmbdist<1)
	SetVariable Dis1_DAstep,disable= (tab!=0 || Nmbdist<1)
	SetVariable Dis1_DMStep,disable= (tab!=0 || Nmbdist<1)
	SetVariable DIS1_Mode,disable= (tab!=0 || Nmbdist<1)
	SetVariable DIS1_Median,disable= (tab!=0 || Nmbdist<1)
	SetVariable DIS1_Mean,disable= (tab!=0 || Nmbdist<1)
	SetVariable DIS1_FWHM,disable= (tab!=0 || Nmbdist<1)
	SetVariable Dis1_VolumeLow,disable= (tab!=0 || Nmbdist<1 || !Dist1FitVol)
	SetVariable Dis1_VolumeHigh,disable= (tab!=0 || Nmbdist<1 || !Dist1FitVol)
	SetVariable Dis1_DALow,disable= (tab!=0 || Nmbdist<1 || !Dist1FitDA)
	SetVariable Dis1_DAHigh,disable= (tab!=0 || Nmbdist<1 || !Dist1FitDA)
	SetVariable Dis1_DMLow,disable= (tab!=0 || Nmbdist<1 || !Dist1FitDM)
	SetVariable Dis1_DMHigh,disable= (tab!=0 || Nmbdist<1 || !Dist1FitDM)
	CheckBox Dis1_FitVolume,disable= (tab!=0 || Nmbdist<1)
	CheckBox Dis1_FitDA,disable= (tab!=0 || Nmbdist<1)
	CheckBox Dis1_FitDM,disable= (tab!=0 || Nmbdist<1)

//distribution 2 part...
	NVAR Dist2FitVol=root:Packages:SAS_Modeling:Dist2FitVol
	NVAR Dist2FitDA=root:Packages:SAS_Modeling:Dist2FitDA
	NVAR Dist2FitDM=root:Packages:SAS_Modeling:Dist2FitDM

	PopupMenu Dis2_DataFolder,disable= (tab!=1 || Nmbdist<2)
	PopupMenu Dis2_ProbabilityWv,disable= (tab!=1 || Nmbdist<2)
	PopupMenu Dis2_DiameterWv,disable= (tab!=1 || Nmbdist<2)
	PopupMenu Dis2_ShapePopup,disable= (tab!=1 || Nmbdist<2)
	CheckBox Dis2_InputNumberDist,disable= (tab!=1 || Nmbdist<2)
	CheckBox Dis2_InputRadii,disable= (tab!=1 || Nmbdist<2)
	SetVariable Dis2_Volume,disable= (tab!=1 || Nmbdist<2)
	SVAR Dist2ShapeModel=root:Packages:SAS_Modeling:Dist2ShapeModel
	SetVariable Dis2_Contrast,disable= (tab!=1 || Nmbdist<2 || cmpstr(Dist2ShapeModel,"CoreShell")==0 || cmpstr(Dist2ShapeModel,"Tube")==0 ), win=IR1U_ControlPanel
	SetVariable Dis2_DiamAddition,disable= (tab!=1 || Nmbdist<2)
	SetVariable Dis2_DiamMultiplier,disable= (tab!=1 || Nmbdist<2)
	SetVariable Dis2_Volstep,disable= (tab!=1 || Nmbdist<2)
	SetVariable Dis2_DAstep,disable= (tab!=1 || Nmbdist<2)
	SetVariable Dis2_DMStep,disable= (tab!=1 || Nmbdist<2)
	SetVariable Dis2_Mode,disable= (tab!=1 || Nmbdist<2)
	SetVariable Dis2_Median,disable= (tab!=1 || Nmbdist<2)
	SetVariable Dis2_Mean,disable= (tab!=1 || Nmbdist<2)
	SetVariable Dis2_FWHM,disable= (tab!=1 || Nmbdist<2)
	SetVariable Dis2_VolumeLow,disable= (tab!=1 || Nmbdist<2 ||  !Dist2FitVol)
	SetVariable Dis2_VolumeHigh,disable= (tab!=1 || Nmbdist<2 || !Dist2FitVol)
	SetVariable Dis2_DALow,disable= (tab!=1 || Nmbdist<2 || !Dist2FitDA)
	SetVariable Dis2_DAHigh,disable= (tab!=1 || Nmbdist<2 || !Dist2FitDA)
	SetVariable Dis2_DMLow,disable= (tab!=1 || Nmbdist<2 || !Dist2FitDM)
	SetVariable Dis2_DMHigh,disable= (tab!=1 || Nmbdist<2 || !Dist2FitDM)
	CheckBox Dis2_FitVolume,disable= (tab!=1 || Nmbdist<2)
	CheckBox Dis2_FitDA,disable= (tab!=1 || Nmbdist<2)
	CheckBox Dis2_FitDM,disable= (tab!=1 || Nmbdist<2)
//distribution 3 part
	NVAR Dist3FitVol=root:Packages:SAS_Modeling:Dist3FitVol
	NVAR Dist3FitDA=root:Packages:SAS_Modeling:Dist3FitDA
	NVAR Dist3FitDM=root:Packages:SAS_Modeling:Dist3FitDM

	PopupMenu Dis3_DataFolder,disable= (tab!=2 || Nmbdist<3)
	PopupMenu Dis3_ProbabilityWv,disable= (tab!=2 || Nmbdist<3)
	PopupMenu Dis3_DiameterWv,disable= (tab!=2 || Nmbdist<3)
	PopupMenu Dis3_ShapePopup,disable= (tab!=2 || Nmbdist<3)
	CheckBox Dis3_InputNumberDist,disable= (tab!=2 || Nmbdist<3)
	CheckBox Dis3_InputRadii,disable= (tab!=2 || Nmbdist<3)
	SetVariable Dis3_Volume,disable= (tab!=2 || Nmbdist<3)
	SVAR Dist3ShapeModel=root:Packages:SAS_Modeling:Dist3ShapeModel
	SetVariable Dis3_Contrast,disable= (tab!=2 || Nmbdist<3 || cmpstr(Dist3ShapeModel,"CoreShell")==0 || cmpstr(Dist3ShapeModel,"Tube")==0 ), win=IR1U_ControlPanel
	SetVariable Dis3_DiamAddition,disable= (tab!=2 || Nmbdist<3)
	SetVariable Dis3_DiamMultiplier,disable= (tab!=2 || Nmbdist<3)
	SetVariable Dis3_Volstep,disable= (tab!=2 || Nmbdist<3)
	SetVariable Dis3_DAstep,disable= (tab!=2 || Nmbdist<3)
	SetVariable Dis3_DMStep,disable= (tab!=2 || Nmbdist<3)
	SetVariable Dis3_Mode,disable= (tab!=2 || Nmbdist<3)
	SetVariable Dis3_Median,disable= (tab!=2 || Nmbdist<3)
	SetVariable Dis3_Mean,disable= (tab!=2 || Nmbdist<3)
	SetVariable Dis3_FWHM,disable= (tab!=2 || Nmbdist<3)
	SetVariable Dis3_VolumeLow,disable= (tab!=2 || Nmbdist<3 || !Dist3FitVol)
	SetVariable Dis3_VolumeHigh,disable= (tab!=2 || Nmbdist<3 || !Dist3FitVol)
	SetVariable Dis3_DALow,disable= (tab!=2 || Nmbdist<3 || !Dist3FitDA)
	SetVariable Dis3_DAHigh,disable= (tab!=2 || Nmbdist<3 || !Dist3FitDA)
	SetVariable Dis3_DMLow,disable= (tab!=2 || Nmbdist<3 || !Dist3FitDM)
	SetVariable Dis3_DMHigh,disable= (tab!=2 || Nmbdist<3 || !Dist3FitDM)
	CheckBox Dis3_FitVolume,disable= (tab!=2 || Nmbdist<3)
	CheckBox Dis3_FitDA,disable= (tab!=2 || Nmbdist<3)
	CheckBox Dis3_FitDM,disable= (tab!=2 || Nmbdist<3)

//distribution 4 part...
	NVAR Dist4FitVol=root:Packages:SAS_Modeling:Dist4FitVol
	NVAR Dist4FitDA=root:Packages:SAS_Modeling:Dist4FitDA
	NVAR Dist4FitDM=root:Packages:SAS_Modeling:Dist4FitDM

	PopupMenu Dis4_DataFolder,disable= (tab!=3 || Nmbdist<4)
	PopupMenu Dis4_ProbabilityWv,disable= (tab!=3 || Nmbdist<4)
	PopupMenu Dis4_DiameterWv,disable= (tab!=3 || Nmbdist<4)
	PopupMenu Dis4_ShapePopup,disable= (tab!=3 || Nmbdist<4)
	CheckBox Dis4_InputNumberDist,disable= (tab!=3 || Nmbdist<4)
	CheckBox Dis4_InputRadii,disable= (tab!=3 || Nmbdist<4)
	SetVariable Dis4_Volume,disable= (tab!=3 || Nmbdist<4)
	SVAR Dist4ShapeModel=root:Packages:SAS_Modeling:Dist4ShapeModel
	SetVariable Dis4_Contrast,disable= (tab!=3 || Nmbdist<4 || cmpstr(Dist4ShapeModel,"CoreShell")==0 || cmpstr(Dist4ShapeModel,"Tube")==0 ), win=IR1U_ControlPanel
	SetVariable Dis4_DiamAddition,disable= (tab!=3 || Nmbdist<4)
	SetVariable Dis4_DiamMultiplier,disable= (tab!=3 || Nmbdist<4)
	SetVariable Dis4_Volstep,disable= (tab!=3 || Nmbdist<4)
	SetVariable Dis4_DAstep,disable= (tab!=3 || Nmbdist<4)
	SetVariable Dis4_DMStep,disable= (tab!=3 || Nmbdist<4)
	SetVariable Dis4_Mode,disable= (tab!=3 || Nmbdist<4)
	SetVariable Dis4_Median,disable= (tab!=3 || Nmbdist<4)
	SetVariable Dis4_Mean,disable= (tab!=3 || Nmbdist<4)
	SetVariable Dis4_FWHM,disable= (tab!=3 || Nmbdist<4)
	SetVariable Dis4_VolumeLow,disable= (tab!=3 || Nmbdist<4 || !Dist4FitVol)
	SetVariable Dis4_VolumeHigh,disable= (tab!=3 || Nmbdist<4 || !Dist4FitVol)
	SetVariable Dis4_DALow,disable= (tab!=3 || Nmbdist<4 ||!Dist4FitDA)
	SetVariable Dis4_DAHigh,disable= (tab!=3 || Nmbdist<4 || !Dist4FitDA)
	SetVariable Dis4_DMLow,disable= (tab!=3 || Nmbdist<4 || !Dist4FitDM)
	SetVariable Dis4_DMHigh,disable= (tab!=3 || Nmbdist<4 || !Dist4FitDM)
	CheckBox Dis4_FitVolume,disable= (tab!=3 || Nmbdist<4)
	CheckBox Dis4_FitDA,disable= (tab!=3 || Nmbdist<4)
	CheckBox Dis4_FitDM,disable= (tab!=3 || Nmbdist<4)

//distribution 5 part
	NVAR Dist5FitVol=root:Packages:SAS_Modeling:Dist5FitVol
	NVAR Dist5FitDA=root:Packages:SAS_Modeling:Dist5FitDA
	NVAR Dist5FitDM=root:Packages:SAS_Modeling:Dist5FitDM

	PopupMenu Dis5_DataFolder,disable= (tab!=4 || Nmbdist<5)
	PopupMenu Dis5_ProbabilityWv,disable= (tab!=4 || Nmbdist<5)
	PopupMenu Dis5_DiameterWv,disable= (tab!=4 || Nmbdist<5)
	PopupMenu Dis5_ShapePopup,disable= (tab!=4 || Nmbdist<5)
	CheckBox Dis5_InputNumberDist,disable= (tab!=4 || Nmbdist<5)
	CheckBox Dis5_InputRadii,disable= (tab!=4 || Nmbdist<5)
	SetVariable Dis5_Volume,disable= (tab!=4 || Nmbdist<5)
	SVAR Dist5ShapeModel=root:Packages:SAS_Modeling:Dist5ShapeModel
	SetVariable Dis5_Contrast,disable= (tab!=4 || Nmbdist<5 || cmpstr(Dist5ShapeModel,"CoreShell")==0 || cmpstr(Dist5ShapeModel,"Tube")==0 ), win=IR1U_ControlPanel
	SetVariable Dis5_DiamAddition,disable= (tab!=4 || Nmbdist<5)
	SetVariable Dis5_DiamMultiplier,disable= (tab!=4 || Nmbdist<5)
	SetVariable Dis5_Volstep,disable= (tab!=4 || Nmbdist<5)
	SetVariable Dis5_DAstep,disable= (tab!=4 || Nmbdist<5)
	SetVariable Dis5_DMStep,disable= (tab!=4 || Nmbdist<5)
	SetVariable Dis5_Mode,disable= (tab!=4 || Nmbdist<5)
	SetVariable Dis5_Median,disable= (tab!=4 || Nmbdist<5)
	SetVariable Dis5_Mean,disable= (tab!=4 || Nmbdist<5)
	SetVariable Dis5_FWHM,disable= (tab!=4 || Nmbdist<5)
	SetVariable Dis5_VolumeLow,disable= (tab!=4 || Nmbdist<5 || !Dist5FitVol)
	SetVariable Dis5_VolumeHigh,disable= (tab!=4 || Nmbdist<5 || !Dist5FitVol)
	SetVariable Dis5_DALow,disable= (tab!=4 || Nmbdist<5 || !Dist5FitDA)
	SetVariable Dis5_DAHigh,disable= (tab!=4 || Nmbdist<5 || !Dist5FitDA)
	SetVariable Dis5_DMLow,disable= (tab!=4 || Nmbdist<5 ||  !Dist5FitDM)
	SetVariable Dis5_DMHigh,disable= (tab!=4 || Nmbdist<5 || !Dist5FitDM)
	CheckBox Dis5_FitVolume,disable= (tab!=4 || Nmbdist<5)
	CheckBox Dis5_FitDA,disable= (tab!=4 || Nmbdist<5)
	CheckBox Dis5_FitDM,disable= (tab!=4 || Nmbdist<5)

	setDataFolder oldDF

End


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_FixTabsInPanel()
	//here we modify the panel, so it reflects the selected number of distributions
	
	NVAR NumOfDist=root:Packages:SAS_Modeling:NumberOfDistributions
	NVAR CurrentTab=root:Packages:SAS_Modeling:CurrentTab
	IR1U_TabPanelControl("DistTabs",CurrentTab)
	variable setToTab
	setToTab=CurrentTab
	if (CurrentTab<0)
		CurrentTab=0
	ENDIF
	TabControl DistTabs,value= CurrentTab, win=IR1U_ControlPanel

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_PanelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling
	
	if (cmpstr(ctrlName,"SASBackground")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"SASBackgroundStep")==0)
		//here goes what happens when user changes the SASBackground in distribution
		SetVariable SASBackground,win=IR1U_ControlPanel, limits={0,Inf,varNum}
	endif

//Distribution 1
	if (cmpstr(ctrlName,"Dis1_Contrast")==0)
		//here goes what happens when user changes the contrast
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis1_Volume")==0)
		//here goes what happens when user changes the volume in distribution
 		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis1_DiamAddition")==0)
		//here goes what happens when user changes the volume in distribution
 		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis1_DiamMultiplier")==0)
		//here goes what happens when user changes the volume in distribution
 		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis1_VolStep")==0)
		//here goes what happens when user changes the step for location
		SetVariable Dis1_Volume,win=IR1U_ControlPanel, limits={0,inf,varNum}
	endif
	if (cmpstr(ctrlName,"Dis1_DAStep")==0)
		//here goes what happens when user changes the step for scale
		SetVariable Dis1_DiamAddition,win=IR1U_ControlPanel, limits={-inf,inf,varNum}
	endif
	if (cmpstr(ctrlName,"Dis1_DMStep")==0)
		//here goes what happens when user changes the step for shape
		SetVariable Dis1_DiamMultiplier,win=IR1U_ControlPanel, limits={-inf,inf,varNum}
	endif

//Distribution 2
	if (cmpstr(ctrlName,"Dis2_Contrast")==0)
		//here goes what happens when user changes the contrast
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis2_Volume")==0)
		//here goes what happens when user changes the volume in distribution
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis2_DiamAddition")==0)
		//here goes what happens when user changes the volume in distribution
 		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis2_DiamMultiplier")==0)
		//here goes what happens when user changes the volume in distribution
 		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis2_VolStep")==0)
		//here goes what happens when user changes the step for location
		SetVariable Dis2_Volume,win=IR1U_ControlPanel, limits={0,inf,varNum}
	endif
	if (cmpstr(ctrlName,"Dis2_DAStep")==0)
		//here goes what happens when user changes the step for scale
		SetVariable Dis2_DiamAddition,win=IR1U_ControlPanel, limits={-inf,inf,varNum}
	endif
	if (cmpstr(ctrlName,"Dis2_DMStep")==0)
		//here goes what happens when user changes the step for shape
		SetVariable Dis2_DiamMultiplier,win=IR1U_ControlPanel, limits={-inf,inf,varNum}
	endif

//Distribution 3
	if (cmpstr(ctrlName,"Dis3_Contrast")==0)
		//here goes what happens when user changes the contrast
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis3_Volume")==0)
		//here goes what happens when user changes the volume in distribution
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis3_DiamAddition")==0)
		//here goes what happens when user changes the volume in distribution
 		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis3_DiamMultiplier")==0)
		//here goes what happens when user changes the volume in distribution
 		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis3_VolStep")==0)
		//here goes what happens when user changes the step for location
		SetVariable Dis3_Volume,win=IR1U_ControlPanel, limits={0,inf,varNum}
	endif
	if (cmpstr(ctrlName,"Dis3_DAStep")==0)
		//here goes what happens when user changes the step for scale
		SetVariable Dis3_DiamAddition,win=IR1U_ControlPanel, limits={-inf,inf,varNum}
	endif
	if (cmpstr(ctrlName,"Dis3_DMStep")==0)
		//here goes what happens when user changes the step for shape
		SetVariable Dis3_DiamMultiplier,win=IR1U_ControlPanel, limits={-inf,inf,varNum}
	endif

//Distribution 4

	if (cmpstr(ctrlName,"Dis4_Contrast")==0)
		//here goes what happens when user changes the contrast
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis4_Volume")==0)
		//here goes what happens when user changes the volume in distribution
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis4_DiamAddition")==0)
		//here goes what happens when user changes the volume in distribution
 		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis4_DiamMultiplier")==0)
		//here goes what happens when user changes the volume in distribution
 		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis4_VolStep")==0)
		//here goes what happens when user changes the step for location
		SetVariable Dis4_Volume,win=IR1U_ControlPanel, limits={0,inf,varNum}
	endif
	if (cmpstr(ctrlName,"Dis4_DAStep")==0)
		//here goes what happens when user changes the step for scale
		SetVariable Dis4_DiamAddition,win=IR1U_ControlPanel, limits={-inf,inf,varNum}
	endif
	if (cmpstr(ctrlName,"Dis4_DMStep")==0)
		//here goes what happens when user changes the step for shape
		SetVariable Dis4_DiamMultiplier,win=IR1U_ControlPanel, limits={-inf,inf,varNum}
	endif


//Distribution 5
	if (cmpstr(ctrlName,"Dis5_Contrast")==0)
		//here goes what happens when user changes the contrast
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis5_Volume")==0)
		//here goes what happens when user changes the volume in distribution
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis5_DiamAddition")==0)
		//here goes what happens when user changes the volume in distribution
 		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis5_DiamMultiplier")==0)
		//here goes what happens when user changes the volume in distribution
 		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis5_VolStep")==0)
		//here goes what happens when user changes the step for location
		SetVariable Dis5_Volume,win=IR1U_ControlPanel, limits={0,inf,varNum}
	endif
	if (cmpstr(ctrlName,"Dis5_DAStep")==0)
		//here goes what happens when user changes the step for scale
		SetVariable Dis5_DiamAddition,win=IR1U_ControlPanel, limits={-inf,inf,varNum}
	endif
	if (cmpstr(ctrlName,"Dis5_DMStep")==0)
		//here goes what happens when user changes the step for shape
		SetVariable Dis5_DiamMultiplier,win=IR1U_ControlPanel, limits={-inf,inf,varNum}
	endif
	setDataFolder oldDF

End


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
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
			PopupMenu IntensityDataName mode=1,value="---"
			PopupMenu QvecDataName mode=1, value="---"
			PopupMenu ErrorDataName  mode=1,value="---"
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
			PopupMenu IntensityDataName mode=1,value="---"
			PopupMenu QvecDataName  mode=1,value="---"
			PopupMenu ErrorDataName  mode=1,value="---"
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
	
	if (cmpstr(ctrlName,"UpdateAutomatically")==0)
		//here we control the data structure checkbox
		NVAR UpdateAutomatically=root:Packages:SAS_Modeling:UpdateAutomatically
		UpdateAutomatically=checked
		Checkbox UpdateAutomatically, value=UpdateAutomatically
		IR1U_AutoUpdateIfSelected()
	endif
	
	
	//Dist1 part
	if (cmpstr(ctrlName,"Dis1_InputRadii")==0)
		//here we control the data structure checkbox
		NVAR Dist1InputRadii=root:Packages:SAS_Modeling:Dist1InputRadii
		Dist1InputRadii=checked
		Checkbox Dis1_InputRadii, value=Dist1InputRadii
		IR1U_CopyUserWavesToOriginal()
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis1_InputNumberDist")==0)
		//here we control the data structure checkbox
		NVAR Dist1InputNumberDist=root:Packages:SAS_Modeling:Dist1InputNumberDist
		Dist1InputNumberDist=checked
		Checkbox Dis1_InputNumberDist, value=Dist1InputNumberDist
		IR1U_CopyUserWavesToOriginal()
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis1_FitDA")==0)
		//here we control the data structure checkbox
		NVAR Dist1FitDA=root:Packages:SAS_Modeling:Dist1FitDA
		Dist1FitDA=checked
		Checkbox Dis1_FitDA, value=Dist1FitDA
		IR1U_TabPanelControl("cehcboxctrl",0)
	endif
	if (cmpstr(ctrlName,"Dis1_FitDM")==0)
		//here we control the data structure checkbox
		NVAR Dist1FitDM=root:Packages:SAS_Modeling:Dist1FitDM
		Dist1FitDM=checked
		Checkbox Dis1_FitDM, value=Dist1FitDM
		IR1U_TabPanelControl("cehcboxctrl",0)
	endif
	if (cmpstr(ctrlName,"Dis1_FitVolume")==0)
		//here we control the data structure checkbox
		NVAR Dist1FitVol=root:Packages:SAS_Modeling:Dist1FitVol
		Dist1FitVol=checked
		Checkbox Dis1_FitVolume, value=Dist1FitVol
		IR1U_TabPanelControl("cehcboxctrl",0)
	endif

	//Dist2 part
	if (cmpstr(ctrlName,"Dis2_InputRadii")==0)
		//here we control the data structure checkbox
		NVAR Dist2InputRadii=root:Packages:SAS_Modeling:Dist2InputRadii
		Dist2InputRadii=checked
		Checkbox Dis2_InputRadii, value=Dist2InputRadii
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis2_InputNumberDist")==0)
		//here we control the data structure checkbox
		NVAR Dist2InputNumberDist=root:Packages:SAS_Modeling:Dist2InputNumberDist
		Dist2InputNumberDist=checked
		Checkbox Dis2_InputNumberDist, value=Dist2InputNumberDist
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis2_FitDA")==0)
		//here we control the data structure checkbox
		NVAR Dist2FitDA=root:Packages:SAS_Modeling:Dist2FitDA
		Dist2FitDA=checked
		Checkbox Dis2_FitDA, value=Dist2FitDA
		IR1U_TabPanelControl("cehcboxctrl",1)
	endif
	if (cmpstr(ctrlName,"Dis2_FitDM")==0)
		//here we control the data structure checkbox
		NVAR Dist2FitDM=root:Packages:SAS_Modeling:Dist2FitDM
		Dist2FitDM=checked
		Checkbox Dis2_FitDM, value=Dist2FitDM
		IR1U_TabPanelControl("cehcboxctrl",1)
	endif
	if (cmpstr(ctrlName,"Dis2_FitVolume")==0)
		//here we control the data structure checkbox
		NVAR Dist2FitVol=root:Packages:SAS_Modeling:Dist2FitVol
		Dist2FitVol=checked
		Checkbox Dis2_FitVolume, value=Dist2FitVol
		IR1U_TabPanelControl("cehcboxctrl",1)
	endif

	//Dist3 part
	if (cmpstr(ctrlName,"Dis3_InputRadii")==0)
		//here we control the data structure checkbox
		NVAR Dist3InputRadii=root:Packages:SAS_Modeling:Dist3InputRadii
		Dist3InputRadii=checked
		Checkbox Dis3_InputRadii, value=Dist3InputRadii
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis3_InputNumberDist")==0)
		//here we control the data structure checkbox
		NVAR Dist3InputNumberDist=root:Packages:SAS_Modeling:Dist3InputNumberDist
		Dist3InputNumberDist=checked
		Checkbox Dis3_InputNumberDist, value=Dist3InputNumberDist
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis3_FitDA")==0)
		//here we control the data structure checkbox
		NVAR Dist3FitDA=root:Packages:SAS_Modeling:Dist3FitDA
		Dist3FitDA=checked
		Checkbox Dis3_FitDA, value=Dist3FitDA
		IR1U_TabPanelControl("cehcboxctrl",2)
	endif
	if (cmpstr(ctrlName,"Dis3_FitDM")==0)
		//here we control the data structure checkbox
		NVAR Dist3FitDM=root:Packages:SAS_Modeling:Dist3FitDM
		Dist3FitDM=checked
		Checkbox Dis3_FitDM, value=Dist3FitDM
		IR1U_TabPanelControl("cehcboxctrl",2)
	endif
	if (cmpstr(ctrlName,"Dis3_FitVolume")==0)
		//here we control the data structure checkbox
		NVAR Dist3FitVol=root:Packages:SAS_Modeling:Dist3FitVol
		Dist3FitVol=checked
		Checkbox Dis3_FitVolume, value=Dist3FitVol
		IR1U_TabPanelControl("cehcboxctrl",2)
	endif

	//Dist4 part
	if (cmpstr(ctrlName,"Dis4_InputRadii")==0)
		//here we control the data structure checkbox
		NVAR Dist4InputRadii=root:Packages:SAS_Modeling:Dist4InputRadii
		Dist4InputRadii=checked
		Checkbox Dis4_InputRadii, value=Dist4InputRadii
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis4_InputNumberDist")==0)
		//here we control the data structure checkbox
		NVAR Dist4InputNumberDist=root:Packages:SAS_Modeling:Dist4InputNumberDist
		Dist4InputNumberDist=checked
		Checkbox Dis4_InputNumberDist, value=Dist4InputNumberDist
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis4_FitDA")==0)
		//here we control the data structure checkbox
		NVAR Dist4FitDA=root:Packages:SAS_Modeling:Dist4FitDA
		Dist4FitDA=checked
		Checkbox Dis4_FitDA, value=Dist4FitDA
		IR1U_TabPanelControl("cehcboxctrl",3)
	endif
	if (cmpstr(ctrlName,"Dis4_FitDM")==0)
		//here we control the data structure checkbox
		NVAR Dist4FitDM=root:Packages:SAS_Modeling:Dist4FitDM
		Dist4FitDM=checked
		Checkbox Dis4_FitDM, value=Dist4FitDM
		IR1U_TabPanelControl("cehcboxctrl",3)
	endif
	if (cmpstr(ctrlName,"Dis4_FitVolume")==0)
		//here we control the data structure checkbox
		NVAR Dist4FitVol=root:Packages:SAS_Modeling:Dist4FitVol
		Dist4FitVol=checked
		Checkbox Dis4_FitVolume, value=Dist4FitVol
		IR1U_TabPanelControl("cehcboxctrl",3)
	endif

	//Dist5 part
	
	if (cmpstr(ctrlName,"Dis5_InputRadii")==0)
		//here we control the data structure checkbox
		NVAR Dist5InputRadii=root:Packages:SAS_Modeling:Dist5InputRadii
		Dist5InputRadii=checked
		Checkbox Dis5_InputRadii, value=Dist5InputRadii
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis5_InputNumberDist")==0)
		//here we control the data structure checkbox
		NVAR Dist5InputNumberDist=root:Packages:SAS_Modeling:Dist5InputNumberDist
		Dist5InputNumberDist=checked
		Checkbox Dis5_InputNumberDist, value=Dist5InputNumberDist
		IR1U_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Dis5_FitDA")==0)
		//here we control the data structure checkbox
		NVAR Dist5FitDA=root:Packages:SAS_Modeling:Dist5FitDA
		Dist5FitDA=checked
		Checkbox Dis5_FitDA, value=Dist5FitDA
		IR1U_TabPanelControl("cehcboxctrl",4)
	endif
	if (cmpstr(ctrlName,"Dis5_FitDM")==0)
		//here we control the data structure checkbox
		NVAR Dist5FitDM=root:Packages:SAS_Modeling:Dist5FitDM
		Dist5FitDM=checked
		Checkbox Dis5_FitDM, value=Dist5FitDM
		IR1U_TabPanelControl("cehcboxctrl",4)
	endif
	if (cmpstr(ctrlName,"Dis5_FitVolume")==0)
		//here we control the data structure checkbox
		NVAR Dist5FitVol=root:Packages:SAS_Modeling:Dist5FitVol
		Dist5FitVol=checked
		Checkbox Dis5_FitVolume, value=Dist5FitVol
		IR1U_TabPanelControl("cehcboxctrl",4)
	endif
	setDataFolder oldDF
	
End
