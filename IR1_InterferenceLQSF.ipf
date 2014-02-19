#pragma rtGlobals=1		// Use modern global access method.
#pragma version =2.01

//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.01 added license for ANL

//interference				DistModelIntensity /= (1+phi*IR1A_SphereAmplitude(OriginalQvector[p],Eta))




Function IR1S_CallInterferencePanel()
	DoWindow IR1S_InterferencePanel
	NVAR UseInterference=root:Packages:SAS_Modeling:UseInterference
	if(UseInterference)
		if (V_Flag)
			DoWindow/F IR1S_InterferencePanel
		else
			Execute("IR1S_InterferencePanel()")
			IR1S_SetAppropriateInterfLimits()
			IR1S_TabPanelControlInterf("name",0)
		endif
	else
		if(V_Flag)
			DoWindow/K IR1S_InterferencePanel
		endif
	endif

end

Function IR1S_SetAppropriateInterfLimits()
	
	variable i, imax
	imax=5
	For(i=1;i<imax;i+=1)
		NVAR ETA = $("root:Packages:SAS_Modeling:Dist"+num2str(i)+"InterferenceETA")
		NVAR ETALL = $("root:Packages:SAS_Modeling:Dist"+num2str(i)+"InterferenceETALL")
		NVAR Median = $("root:Packages:SAS_Modeling:Dist"+num2str(i)+"Median")
		if (ETA<0.5*Median)
			ETA = 0.5*floor(Median*1.1)
		endif
		if (ETALL<0.5*Median)
			ETALL = 0.5*floor(Median)
		endif
	endfor
end


Window IR1S_InterferencePanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(375.75,425,750,689) as "IR1S_InterferencePanel"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 3,textrgb= (0,0,65280)
	DrawText 27,33,"SAS modeling interference input "

	//Dist Tabs definition
	TabControl InterferenceTabs,pos={10,50},size={360,200},proc=IR1S_TabPanelControlInterf
	TabControl InterferenceTabs,fSize=10,tabLabel(0)="First Dist",tabLabel(1)="Second Dist"
	TabControl InterferenceTabs,tabLabel(2)="Third Dist",tabLabel(3)="Fourth Dist"
	TabControl InterferenceTabs,tabLabel(4)="Fifth Dist",value= 0
	
	//Distribution 1 controls
	CheckBox Dist1_UseInterference,pos={20,80},size={63,14},proc=IR1S_InputPanelCheckboxProc,title="Interference for this distribution?"
	CheckBox Dist1_UseInterference,variable=root:Packages:SAS_Modeling:Dist1UseInterference, help={"Use interference for this distribution?"}

	CheckBox Dist1_FitInterferencePhi,pos={140,110},size={63,14},proc=IR1S_InputPanelCheckboxProc,title="Fit?"
	CheckBox Dist1_FitInterferencePhi,variable=root:Packages:SAS_Modeling:Dist1FitInterferencePhi, help={"Fit PACK for this distribution?"}
	SetVariable Dist1_InterferencePhi,pos={20,110},size={100,16},proc=IR1S_PanelSetVarProc,title="PACK "
	SetVariable Dist1_InterferencePhi,limits={0,24,0.1},value= root:Packages:SAS_Modeling:Dist1InterferencePhi, help={"Packing ratio for this distribution. 0 for no interference, 8 for closed packed structure."}
	SetVariable Dist1_InterferencePhiLL,pos={185,110},size={55,16},proc=IR1S_PanelSetVarProc,title=" "
	SetVariable Dist1_InterferencePhiLL,limits={0,24,0.1},value= root:Packages:SAS_Modeling:Dist1InterferencePhiLL, help={"Low Fitting limit for packing ratio"}
	SetVariable Dist1_InterferencePhiHL,pos={245,110},size={110,16},proc=IR1S_PanelSetVarProc,title=" < PACK < " 
	SetVariable Dist1_InterferencePhiHL,limits={0,24,0.1},value= root:Packages:SAS_Modeling:Dist1InterferencePhiHL, help={"High fitting limit for packing ratio"}

	CheckBox Dist1_FitInterferenceETA,pos={140,130},size={63,14},proc=IR1S_InputPanelCheckboxProc,title="Fit?"
	CheckBox Dist1_FitInterferenceETA,variable=root:Packages:SAS_Modeling:Dist1FitInterferenceETA, help={"Fit ETA for this distribution?"}
	SetVariable Dist1_InterferenceETA,pos={20,130},size={100,16},proc=IR1S_PanelSetVarProc,title="ETA  "
	SetVariable Dist1_InterferenceETA,limits={0,inf,1},value= root:Packages:SAS_Modeling:Dist1InterferenceETA, help={"ETA - distance between nearest neigbours for this distribution. 0 for no interference, 8 for closed packed structure."}
	SetVariable Dist1_InterferenceETALL,pos={185,130},size={55,16},proc=IR1S_PanelSetVarProc,title=" "
	SetVariable Dist1_InterferenceETALL,limits={0,inf,1},value= root:Packages:SAS_Modeling:Dist1InterferenceETALL, help={"Low Fitting limit for ETA"}
	SetVariable Dist1_InterferenceETAHL,pos={245,130},size={110,16},proc=IR1S_PanelSetVarProc,title=" <  ETA  < " 
	SetVariable Dist1_InterferenceETAHL,limits={0,inf,1},value= root:Packages:SAS_Modeling:Dist1InterferenceETAHL, help={"High fitting limit for ETA"}

	//Distribution 2 controls
	CheckBox Dist2_UseInterference,pos={20,80},size={63,14},proc=IR1S_InputPanelCheckboxProc,title="Interference for this distribution?"
	CheckBox Dist2_UseInterference,variable=root:Packages:SAS_Modeling:Dist2UseInterference, help={"Use interference for this distribution?"}

	CheckBox Dist2_FitInterferencePhi,pos={140,110},size={63,14},proc=IR1S_InputPanelCheckboxProc,title="Fit?"
	CheckBox Dist2_FitInterferencePhi,variable=root:Packages:SAS_Modeling:Dist2FitInterferencePhi, help={"Fit PACK for this distribution?"}
	SetVariable Dist2_InterferencePhi,pos={20,110},size={100,16},proc=IR1S_PanelSetVarProc,title="PACK "
	SetVariable Dist2_InterferencePhi,limits={0,8,0.1},value= root:Packages:SAS_Modeling:Dist2InterferencePhi, help={"Packing ratio for this distribution. 0 for no interference, 8 for closed packed structure."}
	SetVariable Dist2_InterferencePhiLL,pos={185,110},size={55,16},proc=IR1S_PanelSetVarProc,title=" "
	SetVariable Dist2_InterferencePhiLL,limits={0,8,0.1},value= root:Packages:SAS_Modeling:Dist2InterferencePhiLL, help={"Low Fitting limit for packing ratio"}
	SetVariable Dist2_InterferencePhiHL,pos={245,110},size={110,16},proc=IR1S_PanelSetVarProc,title=" < PACK < " 
	SetVariable Dist2_InterferencePhiHL,limits={0,8,0.1},value= root:Packages:SAS_Modeling:Dist2InterferencePhiHL, help={"High fitting limit for packing ratio"}

	CheckBox Dist2_FitInterferenceETA,pos={140,130},size={63,14},proc=IR1S_InputPanelCheckboxProc,title="Fit?"
	CheckBox Dist2_FitInterferenceETA,variable=root:Packages:SAS_Modeling:Dist2FitInterferenceETA, help={"Fit ETA for this distribution?"}
	SetVariable Dist2_InterferenceETA,pos={20,130},size={100,16},proc=IR1S_PanelSetVarProc,title="ETA  "
	SetVariable Dist2_InterferenceETA,limits={0,inf,1},value= root:Packages:SAS_Modeling:Dist2InterferenceETA, help={"ETA - distance between nearest neigbours for this distribution. 0 for no interference, 8 for closed packed structure."}
	SetVariable Dist2_InterferenceETALL,pos={185,130},size={55,16},proc=IR1S_PanelSetVarProc,title=" "
	SetVariable Dist2_InterferenceETALL,limits={0,inf,1},value= root:Packages:SAS_Modeling:Dist2InterferenceETALL, help={"Low Fitting limit for ETA"}
	SetVariable Dist2_InterferenceETAHL,pos={245,130},size={110,16},proc=IR1S_PanelSetVarProc,title=" <  ETA  < " 
	SetVariable Dist2_InterferenceETAHL,limits={0,inf,1},value= root:Packages:SAS_Modeling:Dist2InterferenceETAHL, help={"High fitting limit for ETA"}

	//Distribution 3 controls
	CheckBox Dist3_UseInterference,pos={20,80},size={63,14},proc=IR1S_InputPanelCheckboxProc,title="Interference for this distribution?"
	CheckBox Dist3_UseInterference,variable=root:Packages:SAS_Modeling:Dist3UseInterference, help={"Use interference for this distribution?"}

	CheckBox Dist3_FitInterferencePhi,pos={140,110},size={63,14},proc=IR1S_InputPanelCheckboxProc,title="Fit?"
	CheckBox Dist3_FitInterferencePhi,variable=root:Packages:SAS_Modeling:Dist3FitInterferencePhi, help={"Fit PACK for this distribution?"}
	SetVariable Dist3_InterferencePhi,pos={20,110},size={100,16},proc=IR1S_PanelSetVarProc,title="PACK "
	SetVariable Dist3_InterferencePhi,limits={0,8,0.1},value= root:Packages:SAS_Modeling:Dist3InterferencePhi, help={"Packing ratio for this distribution. 0 for no interference, 8 for closed packed structure."}
	SetVariable Dist3_InterferencePhiLL,pos={185,110},size={55,16},proc=IR1S_PanelSetVarProc,title=" "
	SetVariable Dist3_InterferencePhiLL,limits={0,8,0.1},value= root:Packages:SAS_Modeling:Dist3InterferencePhiLL, help={"Low Fitting limit for packing ratio"}
	SetVariable Dist3_InterferencePhiHL,pos={245,110},size={110,16},proc=IR1S_PanelSetVarProc,title=" < PACK < " 
	SetVariable Dist3_InterferencePhiHL,limits={0,8,0.1},value= root:Packages:SAS_Modeling:Dist3InterferencePhiHL, help={"High fitting limit for packing ratio"}

	CheckBox Dist3_FitInterferenceETA,pos={140,130},size={63,14},proc=IR1S_InputPanelCheckboxProc,title="Fit?"
	CheckBox Dist3_FitInterferenceETA,variable=root:Packages:SAS_Modeling:Dist3FitInterferenceETA, help={"Fit ETA for this distribution?"}
	SetVariable Dist3_InterferenceETA,pos={20,130},size={100,16},proc=IR1S_PanelSetVarProc,title="ETA  "
	SetVariable Dist3_InterferenceETA,limits={0,inf,1},value= root:Packages:SAS_Modeling:Dist3InterferenceETA, help={"ETA - distance between nearest neigbours for this distribution. 0 for no interference, 8 for closed packed structure."}
	SetVariable Dist3_InterferenceETALL,pos={185,130},size={55,16},proc=IR1S_PanelSetVarProc,title=" "
	SetVariable Dist3_InterferenceETALL,limits={0,inf,1},value= root:Packages:SAS_Modeling:Dist3InterferenceETALL, help={"Low Fitting limit for ETA"}
	SetVariable Dist3_InterferenceETAHL,pos={245,130},size={110,16},proc=IR1S_PanelSetVarProc,title=" <  ETA  < " 
	SetVariable Dist3_InterferenceETAHL,limits={0,inf,1},value= root:Packages:SAS_Modeling:Dist3InterferenceETAHL, help={"High fitting limit for ETA"}

	//Distribution 4 controls
	CheckBox Dist4_UseInterference,pos={20,80},size={63,14},proc=IR1S_InputPanelCheckboxProc,title="Interference for this distribution?"
	CheckBox Dist4_UseInterference,variable=root:Packages:SAS_Modeling:Dist4UseInterference, help={"Use interference for this distribution?"}

	CheckBox Dist4_FitInterferencePhi,pos={140,110},size={63,14},proc=IR1S_InputPanelCheckboxProc,title="Fit?"
	CheckBox Dist4_FitInterferencePhi,variable=root:Packages:SAS_Modeling:Dist4FitInterferencePhi, help={"Fit PACK for this distribution?"}
	SetVariable Dist4_InterferencePhi,pos={20,110},size={100,16},proc=IR1S_PanelSetVarProc,title="PACK "
	SetVariable Dist4_InterferencePhi,limits={0,8,0.1},value= root:Packages:SAS_Modeling:Dist4InterferencePhi, help={"Packing ratio for this distribution. 0 for no interference, 8 for closed packed structure."}
	SetVariable Dist4_InterferencePhiLL,pos={185,110},size={55,16},proc=IR1S_PanelSetVarProc,title=" "
	SetVariable Dist4_InterferencePhiLL,limits={0,8,0.1},value= root:Packages:SAS_Modeling:Dist4InterferencePhiLL, help={"Low Fitting limit for packing ratio"}
	SetVariable Dist4_InterferencePhiHL,pos={245,110},size={110,16},proc=IR1S_PanelSetVarProc,title=" < PACK < " 
	SetVariable Dist4_InterferencePhiHL,limits={0,8,0.1},value= root:Packages:SAS_Modeling:Dist4InterferencePhiHL, help={"High fitting limit for packing ratio"}

	CheckBox Dist4_FitInterferenceETA,pos={140,130},size={63,14},proc=IR1S_InputPanelCheckboxProc,title="Fit?"
	CheckBox Dist4_FitInterferenceETA,variable=root:Packages:SAS_Modeling:Dist4FitInterferenceETA, help={"Fit ETA for this distribution?"}
	SetVariable Dist4_InterferenceETA,pos={20,130},size={100,16},proc=IR1S_PanelSetVarProc,title="ETA  "
	SetVariable Dist4_InterferenceETA,limits={0,inf,1},value= root:Packages:SAS_Modeling:Dist4InterferenceETA, help={"ETA - distance between nearest neigbours for this distribution. 0 for no interference, 8 for closed packed structure."}
	SetVariable Dist4_InterferenceETALL,pos={185,130},size={55,16},proc=IR1S_PanelSetVarProc,title=" "
	SetVariable Dist4_InterferenceETALL,limits={0,inf,1},value= root:Packages:SAS_Modeling:Dist4InterferenceETALL, help={"Low Fitting limit for ETA"}
	SetVariable Dist4_InterferenceETAHL,pos={245,130},size={110,16},proc=IR1S_PanelSetVarProc,title=" <  ETA  < " 
	SetVariable Dist4_InterferenceETAHL,limits={0,inf,1},value= root:Packages:SAS_Modeling:Dist4InterferenceETAHL, help={"High fitting limit for ETA"}

	//Distribution 5 controls
	CheckBox Dist5_UseInterference,pos={20,80},size={63,14},proc=IR1S_InputPanelCheckboxProc,title="Interference for this distribution?"
	CheckBox Dist5_UseInterference,variable=root:Packages:SAS_Modeling:Dist5UseInterference, help={"Use interference for this distribution?"}

	CheckBox Dist5_FitInterferencePhi,pos={140,110},size={63,14},proc=IR1S_InputPanelCheckboxProc,title="Fit?"
	CheckBox Dist5_FitInterferencePhi,variable=root:Packages:SAS_Modeling:Dist5FitInterferencePhi, help={"Fit PACK for this distribution?"}
	SetVariable Dist5_InterferencePhi,pos={20,110},size={100,16},proc=IR1S_PanelSetVarProc,title="PACK "
	SetVariable Dist5_InterferencePhi,limits={0,8,0.1},value= root:Packages:SAS_Modeling:Dist5InterferencePhi, help={"Packing ratio for this distribution. 0 for no interference, 8 for closed packed structure."}
	SetVariable Dist5_InterferencePhiLL,pos={185,110},size={55,16},proc=IR1S_PanelSetVarProc,title=" "
	SetVariable Dist5_InterferencePhiLL,limits={0,8,0.1},value= root:Packages:SAS_Modeling:Dist5InterferencePhiLL, help={"Low Fitting limit for packing ratio"}
	SetVariable Dist5_InterferencePhiHL,pos={245,110},size={110,16},proc=IR1S_PanelSetVarProc,title=" < PACK < " 
	SetVariable Dist5_InterferencePhiHL,limits={0,8,0.1},value= root:Packages:SAS_Modeling:Dist5InterferencePhiHL, help={"High fitting limit for packing ratio"}

	CheckBox Dist5_FitInterferenceETA,pos={140,130},size={63,14},proc=IR1S_InputPanelCheckboxProc,title="Fit?"
	CheckBox Dist5_FitInterferenceETA,variable=root:Packages:SAS_Modeling:Dist5FitInterferenceETA, help={"Fit ETA for this distribution?"}
	SetVariable Dist5_InterferenceETA,pos={20,130},size={100,16},proc=IR1S_PanelSetVarProc,title="ETA  "
	SetVariable Dist5_InterferenceETA,limits={0,inf,1},value= root:Packages:SAS_Modeling:Dist5InterferenceETA, help={"ETA - distance between nearest neigbours for this distribution. 0 for no interference, 8 for closed packed structure."}
	SetVariable Dist5_InterferenceETALL,pos={185,130},size={55,16},proc=IR1S_PanelSetVarProc,title=" "
	SetVariable Dist5_InterferenceETALL,limits={0,inf,1},value= root:Packages:SAS_Modeling:Dist5InterferenceETALL, help={"Low Fitting limit for ETA"}
	SetVariable Dist5_InterferenceETAHL,pos={245,130},size={110,16},proc=IR1S_PanelSetVarProc,title=" <  ETA  < " 
	SetVariable Dist5_InterferenceETAHL,limits={0,inf,1},value= root:Packages:SAS_Modeling:Dist5InterferenceETAHL, help={"High fitting limit for ETA"}

EndMacro

Function IR1S_TabPanelControlInterf(name,tab)
	String name
	Variable tab

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling

	NVAR Nmbdist=root:Packages:SAS_Modeling:NumberOfDistributions
	TabControl InterferenceTabs,value= tab,win=IR1S_InterferencePanel 

//dist1
	NVAR Dist1UseInterference=root:Packages:SAS_Modeling:Dist1UseInterference
	NVAR Dist1FitInterferencePhi = root:Packages:SAS_Modeling:Dist1FitInterferencePhi
	NVAR Dist1FitInterferenceEta = root:Packages:SAS_Modeling:Dist1FitInterferenceEta
	CheckBox Dist1_UseInterference, disable = (tab!=0 || Nmbdist<1 ), win=IR1S_InterferencePanel 

	CheckBox Dist1_FitInterferencePhi, disable = (tab!=0 || Nmbdist<1 || Dist1UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist1_InterferencePhi, disable = (tab!=0 || Nmbdist<1 || Dist1UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist1_InterferencePhiLL, disable = (tab!=0 || Nmbdist<1 || Dist1FitInterferencePhi!=1 || Dist1UseInterference!=1), win=IR1S_InterferencePanel
	SetVariable Dist1_InterferencePhiHL, disable = (tab!=0 || Nmbdist<1 || Dist1FitInterferencePhi!=1 || Dist1UseInterference!=1), win=IR1S_InterferencePanel

	CheckBox Dist1_FitInterferenceEta, disable = (tab!=0 || Nmbdist<1 || Dist1UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist1_InterferenceEta, disable = (tab!=0 || Nmbdist<1 || Dist1UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist1_InterferenceEtaLL, disable = (tab!=0 || Nmbdist<1 || Dist1FitInterferenceEta!=1 || Dist1UseInterference!=1), win=IR1S_InterferencePanel
	SetVariable Dist1_InterferenceEtaHL, disable = (tab!=0 || Nmbdist<1 || Dist1FitInterferenceEta!=1 || Dist1UseInterference!=1), win=IR1S_InterferencePanel

//dist2
	NVAR Dist2UseInterference=root:Packages:SAS_Modeling:Dist2UseInterference
	NVAR Dist2FitInterferencePhi = root:Packages:SAS_Modeling:Dist2FitInterferencePhi
	NVAR Dist2FitInterferenceEta = root:Packages:SAS_Modeling:Dist2FitInterferenceEta
	CheckBox Dist2_UseInterference, disable = (tab!=1 || Nmbdist<2 ), win=IR1S_InterferencePanel 

	CheckBox Dist2_FitInterferencePhi, disable = (tab!=1 || Nmbdist<2 || Dist2UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist2_InterferencePhi, disable = (tab!=1 || Nmbdist<2 || Dist2UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist2_InterferencePhiLL, disable = (tab!=1 || Nmbdist<2 || Dist2FitInterferencePhi!=1 || Dist2UseInterference!=1), win=IR1S_InterferencePanel
	SetVariable Dist2_InterferencePhiHL, disable = (tab!=1 || Nmbdist<2 || Dist2FitInterferencePhi!=1 || Dist2UseInterference!=1), win=IR1S_InterferencePanel

	CheckBox Dist2_FitInterferenceEta, disable = (tab!=1 || Nmbdist<2 || Dist2UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist2_InterferenceEta, disable = (tab!=1 || Nmbdist<2 || Dist2UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist2_InterferenceEtaLL, disable = (tab!=1 || Nmbdist<2 || Dist2FitInterferenceEta!=1 || Dist2UseInterference!=1), win=IR1S_InterferencePanel
	SetVariable Dist2_InterferenceEtaHL, disable = (tab!=1 || Nmbdist<2 || Dist2FitInterferenceEta!=1 || Dist2UseInterference!=1), win=IR1S_InterferencePanel

//dist 3
	NVAR Dist3UseInterference=root:Packages:SAS_Modeling:Dist3UseInterference
	NVAR Dist3FitInterferencePhi = root:Packages:SAS_Modeling:Dist3FitInterferencePhi
	NVAR Dist3FitInterferenceEta = root:Packages:SAS_Modeling:Dist3FitInterferenceEta
	CheckBox Dist3_UseInterference, disable = (tab!=2 || Nmbdist<3 ), win=IR1S_InterferencePanel 

	CheckBox Dist3_FitInterferencePhi, disable = (tab!=2 || Nmbdist<3 || Dist3UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist3_InterferencePhi, disable = (tab!=2 || Nmbdist<3 || Dist3UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist3_InterferencePhiLL, disable = (tab!=2 || Nmbdist<3 || Dist3FitInterferencePhi!=1 || Dist3UseInterference!=1), win=IR1S_InterferencePanel
	SetVariable Dist3_InterferencePhiHL, disable = (tab!=2 || Nmbdist<3 || Dist3FitInterferencePhi!=1 || Dist3UseInterference!=1), win=IR1S_InterferencePanel

	CheckBox Dist3_FitInterferenceEta, disable = (tab!=2 || Nmbdist<3 || Dist3UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist3_InterferenceEta, disable = (tab!=2 || Nmbdist<3 || Dist3UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist3_InterferenceEtaLL, disable = (tab!=2 || Nmbdist<3 || Dist3FitInterferenceEta!=1 || Dist3UseInterference!=1), win=IR1S_InterferencePanel
	SetVariable Dist3_InterferenceEtaHL, disable = (tab!=2 || Nmbdist<3 || Dist3FitInterferenceEta!=1 || Dist3UseInterference!=1), win=IR1S_InterferencePanel

//dist 4
	NVAR Dist4UseInterference=root:Packages:SAS_Modeling:Dist4UseInterference
	NVAR Dist4FitInterferencePhi = root:Packages:SAS_Modeling:Dist4FitInterferencePhi
	NVAR Dist4FitInterferenceEta = root:Packages:SAS_Modeling:Dist4FitInterferenceEta
	CheckBox Dist4_UseInterference, disable = (tab!=3 || Nmbdist<4 ), win=IR1S_InterferencePanel 

	CheckBox Dist4_FitInterferencePhi, disable = (tab!=3 || Nmbdist<4 || Dist4UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist4_InterferencePhi, disable = (tab!=3 || Nmbdist<4 || Dist4UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist4_InterferencePhiLL, disable = (tab!=3 || Nmbdist<4 || Dist4FitInterferencePhi!=1 || Dist4UseInterference!=1), win=IR1S_InterferencePanel
	SetVariable Dist4_InterferencePhiHL, disable = (tab!=3 || Nmbdist<4 || Dist4FitInterferencePhi!=1 || Dist4UseInterference!=1), win=IR1S_InterferencePanel

	CheckBox Dist4_FitInterferenceEta, disable = (tab!=3 || Nmbdist<4 || Dist4UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist4_InterferenceEta, disable = (tab!=3 || Nmbdist<4 || Dist4UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist4_InterferenceEtaLL, disable = (tab!=3 || Nmbdist<4 || Dist4FitInterferenceEta!=1 || Dist4UseInterference!=1), win=IR1S_InterferencePanel
	SetVariable Dist4_InterferenceEtaHL, disable = (tab!=3 || Nmbdist<4 || Dist4FitInterferenceEta!=1 || Dist4UseInterference!=1), win=IR1S_InterferencePanel

//dist 5
	NVAR Dist5UseInterference=root:Packages:SAS_Modeling:Dist5UseInterference
	NVAR Dist5FitInterferencePhi = root:Packages:SAS_Modeling:Dist5FitInterferencePhi
	NVAR Dist5FitInterferenceEta = root:Packages:SAS_Modeling:Dist5FitInterferenceEta
	CheckBox Dist5_UseInterference, disable = (tab!=4 || Nmbdist<5 ), win=IR1S_InterferencePanel 

	CheckBox Dist5_FitInterferencePhi, disable = (tab!=4 || Nmbdist<5 || Dist5UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist5_InterferencePhi, disable = (tab!=4 || Nmbdist<5 || Dist5UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist5_InterferencePhiLL, disable = (tab!=4 || Nmbdist<5 || Dist5FitInterferencePhi!=1 || Dist5UseInterference!=1), win=IR1S_InterferencePanel
	SetVariable Dist5_InterferencePhiHL, disable = (tab!=4 || Nmbdist<5 || Dist5FitInterferencePhi!=1 || Dist5UseInterference!=1), win=IR1S_InterferencePanel

	CheckBox Dist5_FitInterferenceEta, disable = (tab!=4 || Nmbdist<5 || Dist5UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist5_InterferenceEta, disable = (tab!=4 || Nmbdist<5 || Dist5UseInterference!=1), win=IR1S_InterferencePanel 
	SetVariable Dist5_InterferenceEtaLL, disable = (tab!=4 || Nmbdist<5 || Dist5FitInterferenceEta!=1 || Dist5UseInterference!=1), win=IR1S_InterferencePanel
	SetVariable Dist5_InterferenceEtaHL, disable = (tab!=4 || Nmbdist<5 || Dist5FitInterferenceEta!=1 || Dist5UseInterference!=1), win=IR1S_InterferencePanel

	setDataFolder OldDf
end
//	"Dist1UseInterference;	Dist1InterferencePhi;Dist1InterferenceEta;Dist1InterferencePhiLL;Dist1InterferencePhiHL;Dist1InterferenceEtaLL;Dist1InterferenceEtaLL;"
//	"Dist2UseInterference;	Dist2InterferencePhi;Dist2InterferenceEta;Dist2InterferencePhiLL;Dist2InterferencePhiHL;Dist2InterferenceEtaLL;Dist2InterferenceEtaLL;"
//	"Dist3UseInterference;	Dist3InterferencePhi;Dist3InterferenceEta;Dist3InterferencePhiLL;Dist3InterferencePhiHL;Dist3InterferenceEtaLL;Dist3InterferenceEtaLL;"
//	"Dist4UseInterference;	Dist4InterferencePhi;Dist4InterferenceEta;Dist4InterferencePhiLL;Dist4InterferencePhiHL;Dist4InterferenceEtaLL;Dist4InterferenceEtaLL;"
//	"Dist5UseInterference;	Dist5InterferencePhi;Dist5InterferenceEta;Dist5InterferencePhiLL;Dist5InterferencePhiHL;Dist5InterferenceEtaLL;Dist5InterferenceEtaLL;"
//
	









