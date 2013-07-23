#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.02

//*************************************************************************\
//* Copyright (c) 2005 - 2013, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.02  Modified all controls not to define font and font size to enable proper control by user 
//2.01 added license for ANL

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Proc IR1V_ControlPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,390,690) as "Fractals model"
	DoWIndow/C IR1V_ControlPanel

	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("FractalsModel","IR1V_ControlPanel","DSM_Int;M_DSM_Int;","",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1)
//	SetDrawLayer UserBack
//	SetDrawEnv fname= "Times New Roman", save
//	SetDrawEnv fname= "Times New Roman",fsize= 22,fstyle= 3,textrgb= (0,0,52224)
//	DrawText 58,28,"Fractals model input panel"
	TitleBox MainTitle title="Fractals model input panel",pos={20,0},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,24},fSize=22,fColor=(0,0,52224)
//	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
//	DrawLine 16,181,339,181
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,181},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
//	SetDrawEnv fsize= 16,fstyle= 1
//	DrawText 8,49,"Data input"
	TitleBox Info1 title="Data input",pos={8,30},frame=0,fstyle=1, fixedSize=1,size={80,20},fSize=14,fColor=(0,0,52224)
//	SetDrawEnv fsize= 16,fstyle= 1
//	DrawText 20,209,"Fractals model input"
	TitleBox Info2 title="Fractals model input",pos={10,185},frame=0,fstyle=2, fixedSize=1,size={150,20},fSize=14, fstyle=3,fColor=(0,0,65535)
//	SetDrawEnv textrgb= (0,0,65280),fstyle= 1, fsize= 12
//	DrawText 200,285,"Fit?:"
	TitleBox Info3 title="Fit?  Low limit:    High Limit:",pos={200,275},frame=0,fstyle=2, fixedSize=0,size={20,15},fSize=12
//	SetDrawEnv textrgb= (0,0,65280),fstyle= 1, fsize= 12
//	DrawText 230,285,"Low limit:    High Limit:"
	//TitleBox Info4 title="",pos={230,262},frame=0,fstyle=2, fixedSize=0,size={120,15},fSize=12
//	DrawText 10,605,"Fit using least square fitting ?"
	TitleBox Info5 title="Fit using least square fitting ?",pos={2,588},frame=0,fstyle=3, fixedSize=0,size={140,15},fSize=12,fColor=(0,0,52224)
//	DrawPoly 113,225,1,1,{113,225,113,225}
//	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
//	DrawLine 16,612,339,612
	TitleBox FakeLine2 title=" ",fixedSize=1,size={330,3},pos={16,612},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
//	SetDrawEnv textrgb= (0,0,65280),fstyle= 1
//	DrawText 16,635,"Results:"
	TitleBox Info6 title="Results",pos={2,620},frame=0,fstyle=3, fixedSize=0,size={40,15},fSize=14,fColor=(0,0,52224)

	//Experimental data input
//	CheckBox UseIndra2Data,pos={217,26},size={141,14},proc=IR1V_InputPanelCheckboxProc,title="Use Indra 2 data structure"
//	CheckBox UseIndra2Data,variable= root:packages:FractalsModel:UseIndra2data, help={"Check, if you are using Indra 2 produced data with the orginal names, uncheck if the names of data waves are different"}
//	CheckBox UseQRSData,pos={217,40},size={141,14},proc=IR1V_InputPanelCheckboxProc,title="Use QRS data structure"
//	CheckBox UseQRSData,variable= root:packages:FractalsModel:UseQRSdata, help={"Check, if you are using QRS names, uncheck if the names of data waves are different"}
//	PopupMenu SelectDataFolder,pos={4,56},size={180,21},proc=IR1V_PanelPopupControl,title="Select folder with data:    ", help={"Select folder containing your SAS data"}
//	PopupMenu SelectDataFolder,mode=1,popvalue="---",value= #"\"---;\"+IR1_GenStringOfFolders(root:Packages:FractalsModel:UseIndra2Data, root:Packages:FractalsModel:UseQRSData,0,0)"
//	PopupMenu QvecDataName,pos={5,80},size={179,21},proc=IR1V_PanelPopupControl,title="Wave with Q data           ", help={"Select wave with Q data from the selection"}
//	PopupMenu QvecDataName,mode=1,popvalue="---",value= #"\"---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"FractalsModel\",0,0)"
//	PopupMenu IntensityDataName,pos={4,106},size={180,21},proc=IR1V_PanelPopupControl,title="Wave with Intensity data ", help={"Select wave with Intensity data from the selection"}
//	PopupMenu IntensityDataName,mode=1,popvalue="---",value= #"\"---;\"+IR1_ListOfWaves(\"DSM_Int\",\"FractalsModel\",0,0)"
//	PopupMenu ErrorDataName,pos={6,133},size={178,21},proc=IR1V_PanelPopupControl,title="Wave with Error data      ", help={"Select wave with error estimate data for your intensity"}
//	PopupMenu ErrorDataName,mode=1,popvalue="---",value= #"\"---;\"+IR1_ListOfWaves(\"DSM_Error\",\"FractalsModel\",0,0)"
	Button DrawGraphs,pos={56,158},size={100,20}, proc=IR1V_InputPanelButtonProc,title="Graph", help={"Create a graph (log-log) of your experiment data"}
	SetVariable SubtractBackground,limits={-inf,Inf,0.1},value= root:Packages:FractalsModel:SubtractBackground
	SetVariable SubtractBackground,pos={170,162},size={180,16},title="Subtract background",proc=IR1V_PanelSetVarProc, help={"Subtract flat background from input data"}

	//Modeling input, common for all distributions
	Button GraphDistribution,pos={12,215},size={90,20}, proc=IR1V_InputPanelButtonProc,title="Update model", help={"Add results of your model in the graph with data"}
	CheckBox UpdateAutomatically,pos={115,212},size={225,14},proc=IR1V_InputPanelCheckboxProc,title="Update automatically?"
	CheckBox UpdateAutomatically,variable= root:Packages:FractalsModel:UpdateAutomatically, help={"When checked the graph updates automatically anytime you make change in model parameters"}
	CheckBox DisplayLocalFits,pos={115,228},size={225,14},proc=IR1V_InputPanelCheckboxProc,title="Display single fits?"
	CheckBox DisplayLocalFits,variable= root:Packages:FractalsModel:DisplayLocalFits, help={"Check to display ALSO in graph single mass/surface fractal fits, the displayed lines change with changes in values of P, B, Rg and G"}
	CheckBox UseMassFract1,pos={250,185},size={225,14},proc=IR1V_InputPanelCheckboxProc,title="Use Mass Fractal 1?"
	CheckBox UseMassFract1,variable= root:Packages:FractalsModel:UseMassFract1, help={"Use Mass fractal 1 to model these data"}
	CheckBox UseMassFract2,pos={250,200},size={225,14},proc=IR1V_InputPanelCheckboxProc,title="Use Mass Fractal 2?"
	CheckBox UseMassFract2,variable= root:Packages:FractalsModel:UseMassFract2, help={"Use Mass fractal 2 to model these data"}
	CheckBox UseSurfFract1,pos={250,215},size={225,14},proc=IR1V_InputPanelCheckboxProc,title="Use Surf Fractal 1?"
	CheckBox UseSurfFract1,variable= root:Packages:FractalsModel:UseSurfFract1, help={"Use Surface fractal 1 to model these data"}
	CheckBox UseSurfFract2,pos={250,230},size={225,14},proc=IR1V_InputPanelCheckboxProc,title="Use Surf Fractal 2?"
	CheckBox UseSurfFract2,variable= root:Packages:FractalsModel:UseSurfFract2, help={"Use Surface fractal 2 to model these data"}


	Button DoFitting,pos={175,588},size={70,20}, proc=IR1V_InputPanelButtonProc,title="Fit", help={"Do least sqaures fitting of the whole model, find good starting conditions and proper limits before fitting"}
	Button RevertFitting,pos={255,588},size={100,20}, proc=IR1V_InputPanelButtonProc,title="Revert back",help={"Return back befoire last fitting attempt"}
	Button CopyToFolder,pos={60,620},size={100,20}, proc=IR1V_InputPanelButtonProc,title="Store in Data Folder", help={"Copy results of the modeling into original data folder"}
	Button ExportData,pos={170,620},size={100,20}, proc=IR1V_InputPanelButtonProc,title="Export ASCII", help={"Export ASCII data out of Igor"}
	Button MarkGraphs,pos={280,620},size={100,20}, proc=IR1V_InputPanelButtonProc,title="Results to graphs", help={"Insert text boxes with results into the graphs for printing"}
	SetVariable SASBackground,pos={10,569},size={190,16},proc=IR1V_PanelSetVarProc,title="SAS Background", help={"SAS background"}
	SetVariable SASBackground,limits={-inf,Inf,root:Packages:FractalsModel:SASBackgroundStep},value= root:Packages:FractalsModel:SASBackground
	SetVariable SASBackgroundStep,pos={205,569},size={70,16},title="step",proc=IR1V_PanelSetVarProc, help={"Step for increments in SAS background"}
	SetVariable SASBackgroundStep,limits={0,Inf,0},value= root:Packages:FractalsModel:SASBackgroundStep
	CheckBox FitBackground,pos={285,569},size={63,14},proc=IR1V_InputPanelCheckboxProc,title="Fit Bckg?"
	CheckBox FitBackground,variable= root:Packages:FractalsModel:FitSASBackground, help={"Check if you want the background to be fitting parameter"}

	//Dist Tabs definition
	TabControl DistTabs,pos={10,250},size={370,310},proc=IR1V_TabPanelControl
	TabControl DistTabs,fSize=10,tabLabel(0)="Mass Fract. 1",tabLabel(1)="Surf. Fract. 1"
	TabControl DistTabs,tabLabel(2)="Mass Fract. 2",tabLabel(3)="Surf. Fract. 2",value= 0

	//Mass fractal 1 controls
	
	TitleBox MassFract1_Title, title="   Mass fractal 1 controls    ", frame=1, labelBack=(64000,0,0), pos={14,268}, size={200,8}

	SetVariable MassFr1_Phi,pos={14,295},size={160,16},proc=IR1V_PanelSetVarProc,title="Particle volume   "
	SetVariable MassFr1_Phi,limits={0,inf,root:Packages:FractalsModel:MassFr1_PhiStep},value= root:Packages:FractalsModel:MassFr1_Phi, help={"Fractional volume of particles in the system"}
	CheckBox MassFr1_FitPhi,pos={200,296},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox MassFr1_FitPhi,variable= root:Packages:FractalsModel:MassFr1_FitPhi, help={"Fit particle volume?, find god starting conditions and select fitting limits..."}
	SetVariable MassFr1_PhiMin,pos={230,295},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr1_PhiMin,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr1_PhiMin, help={"Low limit for Particle volume fitting"}
	SetVariable MassFr1_PhiMax,pos={300,295},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr1_PhiMax,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr1_PhiMax, help={"High limit for Particle volume fitting"}

	SetVariable MassFr1_Radius,pos={14,320},size={160,16},proc=IR1V_PanelSetVarProc,title="Radius                ", help={"Mean particle Radius"}
	SetVariable MassFr1_Radius,limits={0,inf,root:Packages:FractalsModel:MassFr1_RadiusStep},value= root:Packages:FractalsModel:MassFr1_Radius
	CheckBox MassFr1_FitRadius,pos={200,321},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox MassFr1_FitRadius,variable= root:Packages:FractalsModel:MassFr1_FitRadius, help={"Fit Radius? Select properly starting conditions and limits"}
	SetVariable MassFr1_RadiusMin,pos={230,320},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr1_RadiusMin,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr1_RadiusMin, help={"Low limit for Radius fitting..."}
	SetVariable MassFr1_RadiusMax,pos={300,320},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr1_RadiusMax,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr1_RadiusMax, help={"High limit for Radius fitting"}

	SetVariable MassFr1_Dv,pos={14,345},size={160,16},proc=IR1V_PanelSetVarProc,title="Dv (fractal dim.)  ", help={"Fractal dimension - for mass fractal between 1 and 3, chanegs slope..."}
	SetVariable MassFr1_Dv,limits={1,3,root:Packages:FractalsModel:MassFr1_DvStep},value= root:Packages:FractalsModel:MassFr1_Dv
	CheckBox MassFr1_FitDv,pos={200,346},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox MassFr1_FitDv,variable= root:Packages:FractalsModel:MassFr1_FitDv, help={"Fit the Dv?, select properly the starting conditions and limits before fitting"}
	SetVariable MassFr1_DvMin,pos={230,345},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr1_DvMin,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr1_DvMin, help={"Dv low limit"}
	SetVariable MassFr1_DvMax,pos={300,345},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr1_DvMax,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr1_DvMax, help={"Dv high limit"}

	SetVariable MassFr1_Ksi,pos={14,370},size={160,16},proc=IR1V_PanelSetVarProc,title="Correlation length ", help={"Correlation length of mass fractal, Ksi in the formula"}
	SetVariable MassFr1_Ksi,limits={0,inf,root:Packages:FractalsModel:MassFr1_KsiStep},value= root:Packages:FractalsModel:MassFr1_Ksi
	CheckBox MassFr1_FitKsi,pos={200,371},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox MassFr1_FitKsi,variable= root:Packages:FractalsModel:MassFr1_FitKsi, help={"Fit the Correlation length, select good starting conditions and appropriate limits"}
	SetVariable MassFr1_KsiMin,pos={230,370},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr1_KsiMin,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr1_KsiMin, help={"Correlation length low limit"}
	SetVariable MassFr1_KsiMax,pos={300,370},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr1_KsiMax,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr1_KsiMax, help={"Correlation length high limit"}


	SetVariable MassFr1_Beta,pos={14,420},size={220,16},proc=IR1V_PanelSetVarProc,title="Particle aspect ratio                    "
	SetVariable MassFr1_Beta,limits={0.01,100,0.1},value= root:Packages:FractalsModel:MassFr1_Beta, help={"Beta, aspect ratio of particles, should be about 0.5 and 2"}
	SetVariable MassFr1_Contrast,pos={14,440},size={220,16},proc=IR1V_PanelSetVarProc,title="Contrast [x 10^20]                      "
	SetVariable MassFr1_Contrast,limits={0,inf,1},value= root:Packages:FractalsModel:MassFr1_Contrast, help={"Scattering contrast"}
	SetVariable MassFr1_Eta,pos={14,460},size={220,16},proc=IR1V_PanelSetVarProc,title="Volume filling                              "
	SetVariable MassFr1_Eta,limits={0.3,0.8,0.05},value= root:Packages:FractalsModel:MassFr1_Eta, help={"Eta (filling of the volume) about 0.4 to 0.6 "}
	SetVariable MassFr1_IntgNumPnts,pos={14,480},size={220,16},proc=IR1V_PanelSetVarProc,title="Internal Integration Num pnts     "
	SetVariable MassFr1_IntgNumPnts,limits={50,500,50},value= root:Packages:FractalsModel:MassFr1_IntgNumPnts, help={"Number of points for internal integration. About 500 is usual, increase if there are artefacts. "}

	TitleBox MassFract2_Title, title="   Mass fractal 2 controls    ", frame=1, labelBack=(0,0,64000), pos={14,268}, size={200,8}

	SetVariable MassFr2_Phi,pos={14,295},size={160,16},proc=IR1V_PanelSetVarProc,title="Particle volume   "
	SetVariable MassFr2_Phi,limits={0,inf,root:Packages:FractalsModel:MassFr2_PhiStep},value= root:Packages:FractalsModel:MassFr2_Phi, help={"Volme of particles in the system"}
	CheckBox MassFr2_FitPhi,pos={200,296},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox MassFr2_FitPhi,variable= root:Packages:FractalsModel:MassFr2_FitPhi, help={"Fit particle volume?, find god starting conditions and select fitting limits..."}
	SetVariable MassFr2_PhiMin,pos={230,295},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr2_PhiMin,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr2_PhiMin, help={"Low limit for Particle volume fitting"}
	SetVariable MassFr2_PhiMax,pos={300,295},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr2_PhiMax,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr2_PhiMax, help={"High limit for Particle volume fitting"}

	SetVariable MassFr2_Radius,pos={14,320},size={160,16},proc=IR1V_PanelSetVarProc,title="Mean Radius           ", help={"Mean particle Radius"}
	SetVariable MassFr2_Radius,limits={0,inf,root:Packages:FractalsModel:MassFr2_RadiusStep},value= root:Packages:FractalsModel:MassFr2_Radius
	CheckBox MassFr2_FitRadius,pos={200,321},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox MassFr2_FitRadius,variable= root:Packages:FractalsModel:MassFr2_FitRadius, help={"Fit Radius? Select properly starting conditions and limits"}
	SetVariable MassFr2_RadiusMin,pos={230,320},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr2_RadiusMin,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr2_RadiusMin, help={"Low limit for Radius fitting..."}
	SetVariable MassFr2_RadiusMax,pos={300,320},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr2_RadiusMax,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr2_RadiusMax, help={"High limit for Radius fitting"}

	SetVariable MassFr2_Dv,pos={14,345},size={160,16},proc=IR1V_PanelSetVarProc,title="Dv (fractal dim.)  ", help={"Fractal dimension for mass fractal between 1 and 3"}
	SetVariable MassFr2_Dv,limits={1,3,root:Packages:FractalsModel:MassFr2_DvStep},value= root:Packages:FractalsModel:MassFr2_Dv
	CheckBox MassFr2_FitDv,pos={200,346},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox MassFr2_FitDv,variable= root:Packages:FractalsModel:MassFr2_FitDv, help={"Fit the Dv?, select properly the starting conditions and limits before fitting"}
	SetVariable MassFr2_DvMin,pos={230,345},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr2_DvMin,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr2_DvMin, help={"Dv low limit"}
	SetVariable MassFr2_DvMax,pos={300,345},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr2_DvMax,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr2_DvMax, help={"Dv high limit"}

	SetVariable MassFr2_Ksi,pos={14,370},size={160,16},proc=IR1V_PanelSetVarProc,title="Correlation length ", help={"Correlation length of mass fractal, Ksi in the formula"}
	SetVariable MassFr2_Ksi,limits={0,inf,root:Packages:FractalsModel:MassFr2_KsiStep},value= root:Packages:FractalsModel:MassFr2_Ksi
	CheckBox MassFr2_FitKsi,pos={200,371},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox MassFr2_FitKsi,variable= root:Packages:FractalsModel:MassFr2_FitKsi, help={"Fit the correlation length, select good starting conditions and appropriate limits"}
	SetVariable MassFr2_KsiMin,pos={230,370},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr2_KsiMin,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr2_KsiMin, help={"Correlation length low limit"}
	SetVariable MassFr2_KsiMax,pos={300,370},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr2_KsiMax,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr2_KsiMax, help={"Correlation length high limit"}


	SetVariable MassFr2_Beta,pos={14,420},size={220,16},proc=IR1V_PanelSetVarProc,title="Particle aspect ratio                    "
	SetVariable MassFr2_Beta,limits={0.01,100,0.1},value= root:Packages:FractalsModel:MassFr2_Beta, help={"Beta, aspect ratio of particles, should be about 0.5 and 2"}
	SetVariable MassFr2_Contrast,pos={14,440},size={220,16},proc=IR1V_PanelSetVarProc,title="Contrast [x 10^20]                      "
	SetVariable MassFr2_Contrast,limits={0,inf,1},value= root:Packages:FractalsModel:MassFr2_Contrast, help={"Scattering contrast"}
	SetVariable MassFr2_Eta,pos={14,460},size={220,16},proc=IR1V_PanelSetVarProc,title="Volume filling                              "
	SetVariable MassFr2_Eta,limits={0.3,0.8,0.05},value= root:Packages:FractalsModel:MassFr2_Eta, help={"Eta (filling of the volume) about 0.4 to 0.6 "}
	SetVariable MassFr2_IntgNumPnts,pos={14,480},size={220,16},proc=IR1V_PanelSetVarProc,title="Internal Integration Num pnts     "
	SetVariable MassFr2_IntgNumPnts,limits={50,500,50},value= root:Packages:FractalsModel:MassFr2_IntgNumPnts, help={"Number of points for internal integration. About 500 is usual, increase if there are artefacts. "}

//SUrface fractal 1 controls
	TitleBox SurfFract1_Title, title="   Surface fractal 1 controls    ", frame=1, labelBack=(0,64000,0), pos={14,268}, size={200,8}

	SetVariable SurfFr1_Surface,pos={14,295},size={160,16},proc=IR1V_PanelSetVarProc,title="Smooth surface   "
	SetVariable SurfFr1_Surface,limits={0,inf,root:Packages:FractalsModel:SurfFr1_SurfaceStep},value= root:Packages:FractalsModel:SurfFr1_Surface, help={"Smooth surface in this surface fractal"}
	CheckBox SurfFr1_FitSurface,pos={200,296},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox SurfFr1_FitSurface,variable= root:Packages:FractalsModel:SurfFr1_FitSurface, help={"Fit smooth surface?, find god starting conditions and select fitting limits..."}
	SetVariable SurfFr1_SurfaceMin,pos={230,295},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr1_SurfaceMin,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr1_SurfaceMin, help={"Low limit for Particle volume fitting"}
	SetVariable SurfFr1_SurfaceMax,pos={300,295},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr1_SurfaceMax,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr1_SurfaceMax, help={"High limit for Particle volume fitting"}

	SetVariable SurfFr1_DS,pos={14,345},size={160,16},proc=IR1V_PanelSetVarProc,title="Ds (fractal dim.)  ", help={"Fractal dimension, 2 to 3 for surface fractals, gives -(6-DS) slope (-3 to -4)"}
	SetVariable SurfFr1_DS,limits={2,3,root:Packages:FractalsModel:SurfFr1_DSStep},value= root:Packages:FractalsModel:SurfFr1_DS
	CheckBox SurfFr1_fitDS,pos={200,346},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox SurfFr1_fitDS,variable= root:Packages:FractalsModel:SurfFr1_FitDS, help={"Fit the DS?, select properly the starting conditions and limits before fitting"}
	SetVariable SurfFr1_DSMin,pos={230,345},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr1_DSMin,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr1_DSMin, help={"DS low limit"}
	SetVariable SurfFr1_DSMax,pos={300,345},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr1_DSMax,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr1_DSMax, help={"DS high limit"}

	SetVariable SurfFr1_Ksi,pos={14,370},size={160,16},proc=IR1V_PanelSetVarProc,title="Correlation length  ", help={"Correlation length of surface fractal, Ksi in the formula"}
	SetVariable SurfFr1_Ksi,limits={0,inf,root:Packages:FractalsModel:MassFr1_KsiStep},value= root:Packages:FractalsModel:SurfFr1_Ksi
	CheckBox SurfFr1_FitKsi,pos={200,371},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox SurfFr1_FitKsi,variable= root:Packages:FractalsModel:SurfFr1_FitKsi, help={"Fit the Correlation legth, select good starting conditions and appropriate limits"}
	SetVariable SurfFr1_KsiMin,pos={230,370},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr1_KsiMin,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr1_KsiMin, help={"Correlation legth low limit"}
	SetVariable SurfFr1_KsiMax,pos={300,370},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr1_KsiMax,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr1_KsiMax, help={"Correlation legth high limit"}


	SetVariable SurfFr1_Contrast,pos={14,440},size={220,16},proc=IR1V_PanelSetVarProc,title="Contrast [x 10^20]              "
	SetVariable SurfFr1_Contrast,limits={0,inf,1},value= root:Packages:FractalsModel:SurfFr1_Contrast, help={"Scattering contrast"}

//SUrface fractal 2
	TitleBox SurfFract2_Title, title="   Surface fractal 2 controls    ", frame=1, labelBack=(52000,52000,0), pos={14,268}, size={200,8}

	SetVariable SurfFr2_Surface,pos={14,295},size={160,16},proc=IR1V_PanelSetVarProc,title="Smooth surface   "
	SetVariable SurfFr2_Surface,limits={0,inf,root:Packages:FractalsModel:SurfFr2_SurfaceStep},value= root:Packages:FractalsModel:SurfFr2_Surface, help={"Smooth surface in this surface fractal"}
	CheckBox SurfFr2_FitSurface,pos={200,296},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox SurfFr2_FitSurface,variable= root:Packages:FractalsModel:SurfFr2_FitSurface, help={"Fit smooth surface?, find god starting conditions and select fitting limits..."}
	SetVariable SurfFr2_SurfaceMin,pos={230,295},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr2_SurfaceMin,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr2_SurfaceMin, help={"Low limit for Particle volume fitting"}
	SetVariable SurfFr2_SurfaceMax,pos={300,295},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr2_SurfaceMax,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr2_SurfaceMax, help={"High limit for Particle volume fitting"}

	SetVariable SurfFr2_DS,pos={14,345},size={160,16},proc=IR1V_PanelSetVarProc,title="Ds (fractal dim.)  ", help={"Fractal dimension, 2 to 3 for surface fractals, gives -(6-DS) slope (-3 to -4)"}
	SetVariable SurfFr2_DS,limits={2,3,root:Packages:FractalsModel:SurfFr2_DSStep},value= root:Packages:FractalsModel:SurfFr2_DS
	CheckBox SurfFr2_fitDS,pos={200,346},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox SurfFr2_fitDS,variable= root:Packages:FractalsModel:SurfFr2_FitDS, help={"Fit the DS?, select properly the starting conditions and limits before fitting"}
	SetVariable SurfFr2_DSMin,pos={230,345},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr2_DSMin,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr2_DSMin, help={"DS low limit"}
	SetVariable SurfFr2_DSMax,pos={300,345},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr2_DSMax,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr2_DSMax, help={"DS high limit"}

	SetVariable SurfFr2_Ksi,pos={14,370},size={160,16},proc=IR1V_PanelSetVarProc,title="Correlation length  ", help={"Correlation length of surface fractal, Ksi in the formula"}
	SetVariable SurfFr2_Ksi,limits={0,inf,root:Packages:FractalsModel:MassFr1_KsiStep},value= root:Packages:FractalsModel:SurfFr2_Ksi
	CheckBox SurfFr2_FitKsi,pos={200,371},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox SurfFr2_FitKsi,variable= root:Packages:FractalsModel:SurfFr2_FitKsi, help={"Fit the Correlation length, select good starting conditions and appropriate limits"}
	SetVariable SurfFr2_KsiMin,pos={230,370},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr2_KsiMin,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr2_KsiMin, help={"Correlation length low limit"}
	SetVariable SurfFr2_KsiMax,pos={300,370},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr2_KsiMax,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr2_KsiMax, help={"Correlation length high limit"}


	SetVariable SurfFr2_Contrast,pos={14,440},size={220,16},proc=IR1A_PanelSetVarProc,title="Contrast [x 10^20]              "
	SetVariable SurfFr2_Contrast,limits={0,inf,1},value= root:Packages:FractalsModel:SurfFr2_Contrast, help={"Scattering contrast"}




	//lets try to update the tabs...
	IR1V_TabPanelControl("test",0)

EndMacro


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1V_TabPanelControl(name,tab)
	String name
	Variable tab

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel
	
	NVAR/Z ActiveTab=root:Packages:FractalsModel:ActiveTab
	if (!NVAR_Exists(ActiveTab))
		variable/g root:Packages:FractalsModel:ActiveTab
		NVAR ActiveTab=root:Packages:FractalsModel:ActiveTab
	endif
	ActiveTab=tab+1

	NVAR Nmbdist=root:Packages:FractalsModel:NumberOfLevels
	if (NmbDIst==0)
		ActiveTab=0
	endif
	//need to kill any outstanding windows for shapes... ANy... All should have the same name...
	DoWindow/F IR1V_ControlPanel

//	PopupMenu NumberOfLevels mode=NmbDist+1

	NVAR UseMassFract1=root:Packages:FractalsModel:UseMassFract1
	NVAR UseSurfFract1=root:Packages:FractalsModel:UseSurfFract1
	NVAR UseMassFract2=root:Packages:FractalsModel:UseMassFract2
	NVAR UseSurfFract2=root:Packages:FractalsModel:UseSurfFract2
//	Mass fractal 1 controls
	
	TitleBox MassFract1_Title, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_Phi, disable= (tab!=0 || !UseMassFract1)
	CheckBox MassFr1_FitPhi, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_PhiMin, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_PhiMax, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_Radius, disable= (tab!=0 || !UseMassFract1)
	CheckBox MassFr1_FitRadius, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_RadiusMin, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_RadiusMax, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_Dv, disable= (tab!=0 || !UseMassFract1)
	CheckBox MassFr1_FitDv, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_DvMin, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_DvMax, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_Ksi, disable= (tab!=0 || !UseMassFract1)
	CheckBox MassFr1_FitKsi, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_KsiMin, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_KsiMax, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_Beta, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_Contrast, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_Eta, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_IntgNumPnts, disable= (tab!=0 || !UseMassFract1)
	
	TitleBox SurfFract1_Title, disable= (tab!=1 || !UseSurfFract1)

	SetVariable SurfFr1_Surface, disable= (tab!=1 || !UseSurfFract1)
	CheckBox SurfFr1_FitSurface, disable= (tab!=1 || !UseSurfFract1)
	SetVariable SurfFr1_SurfaceMin, disable= (tab!=1 || !UseSurfFract1)
	SetVariable SurfFr1_SurfaceMax, disable= (tab!=1 || !UseSurfFract1)
	SetVariable SurfFr1_DS, disable= (tab!=1 || !UseSurfFract1)
	CheckBox SurfFr1_fitDS, disable= (tab!=1 || !UseSurfFract1)
	SetVariable SurfFr1_DSMin, disable= (tab!=1 || !UseSurfFract1)
	SetVariable SurfFr1_DSMax, disable= (tab!=1 || !UseSurfFract1)
	SetVariable SurfFr1_Ksi, disable= (tab!=1 || !UseSurfFract1)
	CheckBox SurfFr1_FitKsi, disable= (tab!=1 || !UseSurfFract1)
	SetVariable SurfFr1_KsiMin, disable= (tab!=1 || !UseSurfFract1)
	SetVariable SurfFr1_KsiMax, disable= (tab!=1 || !UseSurfFract1)
	SetVariable SurfFr1_Contrast, disable= (tab!=1 || !UseSurfFract1)

	TitleBox MassFract2_Title, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_Phi, disable= (tab!=2 || !UseMassFract2)
	CheckBox MassFr2_FitPhi, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_PhiMin, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_PhiMax, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_Radius, disable= (tab!=2 || !UseMassFract2)
	CheckBox MassFr2_FitRadius, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_RadiusMin, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_RadiusMax, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_Dv, disable= (tab!=2 || !UseMassFract2)
	CheckBox MassFr2_FitDv, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_DvMin, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_DvMax, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_Ksi, disable= (tab!=2 || !UseMassFract2)
	CheckBox MassFr2_FitKsi, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_KsiMin, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_KsiMax, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_Beta, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_Contrast, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_Eta, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_IntgNumPnts, disable= (tab!=2 || !UseMassFract2)
	
	TitleBox SurfFract2_Title, disable= (tab!=3 || !UseSurfFract2)

	SetVariable SurfFr2_Surface, disable= (tab!=3 || !UseSurfFract2)
	CheckBox SurfFr2_FitSurface, disable= (tab!=3 || !UseSurfFract2)
	SetVariable SurfFr2_SurfaceMin, disable= (tab!=3 || !UseSurfFract2)
	SetVariable SurfFr2_SurfaceMax, disable= (tab!=3 || !UseSurfFract2)
	SetVariable SurfFr2_DS, disable= (tab!=3 || !UseSurfFract2)
	CheckBox SurfFr2_fitDS, disable= (tab!=3 || !UseSurfFract2)
	SetVariable SurfFr2_DSMin, disable= (tab!=3 || !UseSurfFract2)
	SetVariable SurfFr2_DSMax, disable= (tab!=3 || !UseSurfFract2)
	SetVariable SurfFr2_Ksi, disable= (tab!=3 || !UseSurfFract2)
	CheckBox SurfFr2_FitKsi, disable= (tab!=3 || !UseSurfFract2)
	SetVariable SurfFr2_KsiMin, disable= (tab!=3 || !UseSurfFract2)
	SetVariable SurfFr2_KsiMax, disable= (tab!=3 || !UseSurfFract2)
	SetVariable SurfFr2_Contrast, disable= (tab!=3 || !UseSurfFract2)
	//update the displayed local fits in graph
	IR1V_DisplayLocalFits(tab)
	setDataFolder oldDF
	DoWIndow/F IR1V_ControlPanel
End



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1V_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel

	if (cmpstr(ctrlName,"UseIndra2Data")==0)
		//here we control the data structure checkbox
		NVAR UseIndra2Data=root:Packages:FractalsModel:UseIndra2Data
		NVAR UseQRSData=root:Packages:FractalsModel:UseQRSData
		UseIndra2Data=checked
		if (checked)
			UseQRSData=0
		endif
		Checkbox UseIndra2Data, value=UseIndra2Data
		Checkbox UseQRSData, value=UseQRSData
		SVAR Dtf=root:Packages:FractalsModel:DataFolderName
		SVAR IntDf=root:Packages:FractalsModel:IntensityWaveName
		SVAR QDf=root:Packages:FractalsModel:QWaveName
		SVAR EDf=root:Packages:FractalsModel:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder mode=1
			PopupMenu IntensityDataName  mode=1, value="---"
			PopupMenu QvecDataName    mode=1, value="---"
			PopupMenu ErrorDataName    mode=1, value="---"
	endif
	if (cmpstr(ctrlName,"UseQRSData")==0)
		//here we control the data structure checkbox
		NVAR UseQRSData=root:Packages:FractalsModel:UseQRSData
		NVAR UseIndra2Data=root:Packages:FractalsModel:UseIndra2Data
		UseQRSData=checked
		if (checked)
			UseIndra2Data=0
		endif
		Checkbox UseIndra2Data, value=UseIndra2Data
		Checkbox UseQRSData, value=UseQRSData
		SVAR Dtf=root:Packages:FractalsModel:DataFolderName
		SVAR IntDf=root:Packages:FractalsModel:IntensityWaveName
		SVAR QDf=root:Packages:FractalsModel:QWaveName
		SVAR EDf=root:Packages:FractalsModel:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder mode=1
			PopupMenu IntensityDataName   mode=1, value="---"
			PopupMenu QvecDataName    mode=1, value="---"
			PopupMenu ErrorDataName    mode=1, value="---"
	endif
	if (cmpstr(ctrlName,"FitBackground")==0)
		//here we control the data structure checkbox
	endif

	if (cmpstr(ctrlName,"DisplayLocalFits")==0)
//		//here we control the data structure checkbox
		IR1V_AutoUpdateIfSelected()
		ControlInfo DistTabs
		IR1V_DisplayLocalFits(V_Value)
	endif
	if (cmpstr(ctrlName,"UpdateAutomatically")==0)
		//here we control the data structure checkbox
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"UseMassFract1")==0)
		//here we control the data structure checkbox
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"UseMassFract2")==0)
		//here we control the data structure checkbox
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"UseSurfFract1")==0)
		//here we control the data structure checkbox
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"UseSurfFract2")==0)
		//here we control the data structure checkbox
		IR1V_AutoUpdateIfSelected()
	endif
	
	ControlInfo DistTabs
	IR1V_TabPanelControl("",V_Value)
	DoWIndow/F IR1V_ControlPanel
	setDataFolder oldDF
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_AutoUpdateIfSelected()
	
	NVAR UpdateAutomatically=root:Packages:FractalsModel:UpdateAutomatically
	if (UpdateAutomatically)
		IR1V_GraphModelData()
	endif
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_DisplayLocalFits(level)
	variable level
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel

	DoWindow IR1V_LogLogPlotV
	if (V_Flag)
		RemoveFromGraph /W=IR1V_LogLogPlotV /Z Mass1FractFitIntensity,Mass2FractFitIntensity
		RemoveFromGraph /W=IR1V_LogLogPlotV /Z Surf1FractFitIntensity,Surf2FractFitIntensity
		
		NVAR DisplayLocalFits=root:Packages:FractalsModel:DisplayLocalFits
		Wave/Z Qvec = root:Packages:FractalsModel:FractFitQvector
		NVAR UseMassFract1=root:Packages:FractalsModel:UseMassFract1
		NVAR UseSurfFract1=root:Packages:FractalsModel:UseSurfFract1
		NVAR UseMassFract2=root:Packages:FractalsModel:UseMassFract2
		NVAR UseSurfFract2=root:Packages:FractalsModel:UseSurfFract2
		if (DisplayLocalFits)
			Wave/Z Mass1FractFitIntensity=root:Packages:FractalsModel:Mass1FractFitIntensity
			Wave/Z Mass2FractFitIntensity=root:Packages:FractalsModel:Mass2FractFitIntensity
			Wave/Z Surf1FractFitIntensity=root:Packages:FractalsModel:Surf1FractFitIntensity
			Wave/Z Surf2FractFitIntensity=root:Packages:FractalsModel:Surf2FractFitIntensity
			if((level==0) && WaveExists(Mass1FractFitIntensity) && UseMassFract1)
				AppendToGraph /W=IR1V_LogLogPlotV /C=(65000,0,0) Mass1FractFitIntensity vs Qvec
				ModifyGraph/W=IR1V_LogLogPlotV  lstyle(Mass1FractFitIntensity)=3
			endif
			if((level==2) && WaveExists(Mass2FractFitIntensity) && UseMassFract2)
				AppendToGraph /W=IR1V_LogLogPlotV /C=(0,0,65000) Mass2FractFitIntensity vs Qvec
				ModifyGraph/W=IR1V_LogLogPlotV  lstyle(Mass2FractFitIntensity)=3
			endif
			if((level==1) && WaveExists(Surf1FractFitIntensity) && UseSurfFract1)
				AppendToGraph /W=IR1V_LogLogPlotV /C=(0,52000,0) Surf1FractFitIntensity vs Qvec
				ModifyGraph/W=IR1V_LogLogPlotV  lstyle(Surf1FractFitIntensity)=3
			endif
			if((level==3) && WaveExists(Surf2FractFitIntensity) && UseSurfFract2)
				AppendToGraph /W=IR1V_LogLogPlotV /C=(52000,52000,0) Surf2FractFitIntensity vs Qvec
				ModifyGraph/W=IR1V_LogLogPlotV  lstyle(Surf2FractFitIntensity)=3
			endif
		
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

Function IR1V_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel
		NVAR UseIndra2Data=root:Packages:FractalsModel:UseIndra2Data
		NVAR UseQRSData=root:Packages:FractalsModel:UseQRSdata
		SVAR IntDf=root:Packages:FractalsModel:IntensityWaveName
		SVAR QDf=root:Packages:FractalsModel:QWaveName
		SVAR EDf=root:Packages:FractalsModel:ErrorWaveName
		SVAR Dtf=root:Packages:FractalsModel:DataFolderName

	if (cmpstr(ctrlName,"SelectDataFolder")==0)
		//here we do what needs to be done when we select data folder
		Dtf=popStr
		PopupMenu IntensityDataName mode=1
		PopupMenu QvecDataName mode=1
		PopupMenu ErrorDataName mode=1
		if (UseIndra2Data)
			if(stringmatch(IR1_ListOfWaves("DSM_Int","FractalsModel",0,0), "*M_BKG_Int*") &&stringmatch(IR1_ListOfWaves("DSM_Qvec","FractalsModel",0,0), "*M_BKG_Qvec*")  &&stringmatch(IR1_ListOfWaves("DSM_Error","FractalsModel",0,0), "*M_BKG_Error*") )			
				IntDf="M_BKG_Int"
				QDf="M_BKG_Qvec"
				EDf="M_BKG_Error"
				PopupMenu IntensityDataName value="M_BKG_Int;M_DSM_Int;DSM_Int"
				PopupMenu QvecDataName value="M_BKG_Qvec;M_DSM_Qvec;DSM_Qvec"
				PopupMenu ErrorDataName value="M_BKG_Error;M_DSM_Error;DSM_Error"
			elseif(stringmatch(IR1_ListOfWaves("DSM_Int","FractalsModel",0,0), "*BKG_Int*") &&stringmatch(IR1_ListOfWaves("DSM_Qvec","FractalsModel",0,0), "*BKG_Qvec*")  &&stringmatch(IR1_ListOfWaves("DSM_Error","FractalsModel",0,0), "*BKG_Error*") )			
				IntDf="BKG_Int"
				QDf="BKG_Qvec"
				EDf="BKG_Error"
				PopupMenu IntensityDataName value="BKG_Int;DSM_Int"
				PopupMenu QvecDataName value="BKG_Qvec;DSM_Qvec"
				PopupMenu ErrorDataName value="BKG_Error;DSM_Error"
			elseif(stringmatch(IR1_ListOfWaves("DSM_Int","FractalsModel",0,0), "*M_DSM_Int*") &&stringmatch(IR1_ListOfWaves("DSM_Qvec","FractalsModel",0,0), "*M_DSM_Qvec*")  &&stringmatch(IR1_ListOfWaves("DSM_Error","FractalsModel",0,0), "*M_DSM_Error*") )			
				IntDf="M_DSM_Int"
				QDf="M_DSM_Qvec"
				EDf="M_DSM_Error"
				PopupMenu IntensityDataName value="M_DSM_Int;DSM_Int"
				PopupMenu QvecDataName value="M_DSM_Qvec;DSM_Qvec"
				PopupMenu ErrorDataName value="M_DSM_Error;DSM_Error"
			else
				if(!stringmatch(IR1_ListOfWaves("DSM_Int","FractalsModel",0,0), "*M_DSM_Int*") &&!stringmatch(IR1_ListOfWaves("DSM_Qvec","FractalsModel",0,0), "*M_DSM_Qvec*")  &&!stringmatch(IR1_ListOfWaves("DSM_Error","FractalsModel",0,0), "*M_DSM_Error*") )			
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
			PopupMenu IntensityDataName  value="---;"+IR1_ListOfWaves("DSM_Int","FractalsModel",0,0)
			PopupMenu QvecDataName  value="---;"+IR1_ListOfWaves("DSM_Qvec","FractalsModel",0,0)
			PopupMenu ErrorDataName  value="---;"+IR1_ListOfWaves("DSM_Error","FractalsModel",0,0)
		endif
		if(!UseQRSdata && !UseIndra2Data)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---;"+IR1_ListOfWaves("DSM_Int","FractalsModel",0,0)
			PopupMenu QvecDataName  value="---;"+IR1_ListOfWaves("DSM_Qvec","FractalsModel",0,0)
			PopupMenu ErrorDataName  value="---;"+IR1_ListOfWaves("DSM_Error","FractalsModel",0,0)
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
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:FractalsModel:QWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"FractalsModel\",0,0)")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:FractalsModel:ErrorWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Error\",\"FractalsModel\",0,0)")
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
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:FractalsModel:IntensityWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Int\",\"FractalsModel\",0,0)")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:FractalsModel:ErrorWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Error\",\"FractalsModel\",0,0)")
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
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:FractalsModel:IntensityWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Int\",\"FractalsModel\",0,0)")
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:FractalsModel:QWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"FractalsModel\",0,0)")
			endif
		else
			EDf=""
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

Function IR1V_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel
	

	if (cmpstr(ctrlName,"DrawGraphs")==0)
		//here goes what is done, when user pushes Graph button
		SVAR DFloc=root:Packages:FractalsModel:DataFolderName
		SVAR DFInt=root:Packages:FractalsModel:IntensityWaveName
		SVAR DFQ=root:Packages:FractalsModel:QWaveName
		SVAR DFE=root:Packages:FractalsModel:ErrorWaveName
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
			variable recovered = IR1V_RecoverOldParameters()	//recovers old parameters and returns 1 if done so...
			IR1V_GraphMeasuredData()
			ControlInfo DistTabs
			IR1V_DisplayLocalFits(V_Value)
			IR1V_AutoUpdateIfSelected()
			MoveWindow /W=IR1V_LogLogPlotV 285,37,760,337
			MoveWindow /W=IR1V_IQ4_Q_PlotV 285,360,760,600
			AutoPositionWindow /M=0 /R=IR1V_ControlPanel  IR1V_LogLogPlotV
			AutoPositionWindow /M=1 /R=IR1V_LogLogPlotV  IR1V_IQ4_Q_PlotV
//			if (recovered)
//				IR1A_GraphModelData()		//graph the data here, all parameters should be defined
//			endif
		else
			Abort "Data not selected properly"
		endif
	endif

	if(cmpstr(ctrlName,"DoFitting")==0)
		//here we call the fitting routine
		IR1V_ConstructTheFittingCommand()
	endif
	if(cmpstr(ctrlName,"RevertFitting")==0)
		//here we call the fitting routine
		IR1V_ResetParamsAfterBadFit()
		IR1V_GraphModelData()
	endif
	if(cmpstr(ctrlName,"GraphDistribution")==0)
		//here we graph the distribution
		IR1V_GraphModelData()
	endif
	if(cmpstr(ctrlName,"CopyToFolder")==0)
		//here we copy final data back to original data folder	
		IR1V_UpdateLocalFitsForOutput()		//create local fits 	I	
		IR1V_CopyDataBackToFolder("user")
	endif	
	if(cmpstr(ctrlName,"MarkGraphs")==0)
		//here we copy final data back to original data folder		I	
		IR1V_InsertResultsIntoGraphs()
	endif
	
	if(cmpstr(ctrlName,"ExportData")==0)
		//here we export ASCII form of the data
		IR1V_ExportASCIIResults()
	endif
	setDataFolder oldDF
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR1V_ExportASCIIResults()

	//here we need to copy the export results out of Igor
	//before that we need to also attach note to teh waves with the results
	
	string OldDf=getDataFOlder(1)
	setDataFolder root:Packages:FractalsModel
	
	Wave OriginalQvector=root:Packages:FractalsModel:OriginalQvector
	Wave OriginalIntensity=root:Packages:FractalsModel:OriginalIntensity
	Wave OriginalError=root:Packages:FractalsModel:OriginalError
	Wave UnifiedFitIntensity=root:Packages:FractalsModel:FractFitIntensity
	
	SVAR DataFolderName=root:Packages:FractalsModel:DataFolderName
	
	Duplicate/O OriginalQvector, tempOriginalQvector
	Duplicate/O OriginalIntensity, tempOriginalIntensity
	Duplicate/O OriginalError, tempOriginalError
	Duplicate/O FractFitIntensity, tempFractFitIntensity
	string ListOfWavesForNotes="tempOriginalQvector;tempOriginalIntensity;tempOriginalError;tempFractFitIntensity;"
	
	IR1V_AppendWaveNote(ListOfWavesForNotes)

	string Comments="Record of Data evaluation with Irena SAS modeling macros using Fractals fit model;"
	Comments+="For details on method ask Andrew J. Allen, NIST\r"
	Comments+=note(tempFractFitIntensity)+"Q[A]\tExperimental intensity[1/cm]\tExperimental error\tFractal Fit model intensity[1/cm]\r"
	variable pos=0
	variable ComLength=strlen(Comments)
	
	Do 
	pos=strsearch(Comments, ";", pos+5)
	Comments=Comments[0,pos-1]+"\r$\t"+Comments[pos+1,inf]
	while (pos>0)

	string filename1
	filename1=StringFromList(ItemsInList(DataFolderName,":")-1, DataFolderName,":")+"_SAS_model.txt"
	variable refnum

	Open/D/T=".txt"/M="Select file to save data to" refnum as filename1
	filename1=S_filename
	if (strlen(filename1)==0)
		abort
	endif
	
	String nb = "Notebook0"
	NewNotebook/N=$nb/F=0/V=0/K=0/W=(5.25,40.25,558,408.5) as "ExportData"
	Notebook $nb defaultTab=20, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nb font="Arial", fSize=10, fStyle=0, textRGB=(0,0,0)
	Notebook $nb text=Comments	
	
	
	SaveNotebook $nb as filename1
	DoWindow /K $nb
	Save/A/G/M="\r\n" tempOriginalQvector,tempOriginalIntensity,tempOriginalError,tempFractFitIntensity as filename1	 
	


	Killwaves tempOriginalQvector,tempOriginalIntensity,tempOriginalError,tempFractFitIntensity
	setDataFolder OldDf
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_InsertResultsIntoGraphs()
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel
	NVAR UseMassFract1=root:Packages:FractalsModel:UseMassFract1
	NVAR UseMassFract2=root:Packages:FractalsModel:UseMassFract2
	NVAR UseSurfFract1=root:Packages:FractalsModel:UseSurfFract1
	NVAR UseSurfFract2=root:Packages:FractalsModel:UseSurfFract2
	
	if (UseMassFract1)
		IR1V_InsertMassFractRes(1)
	endif
	if (UseMassFract2)
		IR1V_InsertMassFractRes(2)
	endif
	if (UseSurfFract1)
		IR1V_InsertSurfaceFractRes(1)
	endif
	if (UseSurfFract2)
		IR1V_InsertSurfaceFractRes(2)
	endif
	setDataFolder oldDF
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_InsertSurfaceFractRes(Lnmb)
	variable Lnmb

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel

		NVAR Surface=$("SurfFr"+num2str(lnmb)+"_Surface")
		NVAR SurfaceError=$("SurfFr"+num2str(lnmb)+"_SurfaceError")
		NVAR Ksi=$("SurfFr"+num2str(lnmb)+"_Ksi")
		NVAR KsiError=$("SurfFr"+num2str(lnmb)+"_KsiError")
		NVAR DS=$("SurfFr"+num2str(lnmb)+"_DS")
		NVAR DSError=$("SurfFr"+num2str(lnmb)+"_DSError")
		NVAR Contrast=$("SurfFr"+num2str(lnmb)+"_Contrast")
	

	string LogLogTag, IQ4Tag, tagname
	tagname="SurfaceFract"+num2str(Lnmb)+"Tag"
	Wave OriginalQvector
		
	variable QtoAttach=2/Ksi
	variable AttachPointNum=binarysearch(OriginalQvector,QtoAttach)
	
	LogLogTag="\F'Times'\Z10Surface fractal fit "+num2str(Lnmb)+"\r"
	if (DSError>0)
		LogLogTag+="Ds = "+num2str(Ds)+"  \t +/-"+num2str(DsError)+"\r"
	else
		LogLogTag+="Ds = "+num2str(Ds)+"  \t 0 "+"\r"
	endif	
	if (SurfaceError>0)
		LogLogTag+="Surface = "+num2str(Surface)+"cm\S2\M/cm\S3\M  \t+/-"+num2str(SurfaceError)+"\r"
	else
		LogLogTag+="Surface = "+num2str(Surface)+"cm\S2\M/cm\S3\M  \t 0 "+"\r"	
	endif
	if (KsiError>0)
		LogLogTag+="Ksi = "+num2str(Ksi)+"  \t +/-"+num2str(KsiError)+"\r"
	else
		LogLogTag+="Ksi = "+num2str(Ksi)+"  \t 0  "	+"\r"
	endif
	LogLogTag+="Contrast = "+num2str(Contrast)+"x 10\S20\M; "

	IQ4Tag=LogLogTag
	Tag/W=IR1V_LogLogPlotV/C/N=$(tagname)/F=2/L=2/M OriginalIntensity, AttachPointNum, LogLogTag
	Tag/W=IR1V_IQ4_Q_PlotV/C/N=$(tagname)/F=2/L=2/M OriginalIntQ4, AttachPointNum, IQ4Tag
	
	setDataFolder oldDF	
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_InsertMassFractRes(Lnmb)
	variable Lnmb

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel
		NVAR Phi=$("MassFr"+num2str(lnmb)+"_Phi")
		NVAR PhiError=$("MassFr"+num2str(lnmb)+"_PhiError")
		NVAR DV=$("MassFr"+num2str(lnmb)+"_DV")
		NVAR DVError=$("MassFr"+num2str(lnmb)+"_DVError")
		NVAR Radius=$("MassFr"+num2str(lnmb)+"_Radius")
		NVAR RadiusError=$("MassFr"+num2str(lnmb)+"_RadiusError")
		NVAR Ksi=$("MassFr"+num2str(lnmb)+"_Ksi")
		NVAR KsiError=$("MassFr"+num2str(lnmb)+"_KsiError")
		NVAR BetaVar=$("MassFr"+num2str(lnmb)+"_Beta")
		NVAR Contrast=$("MassFr"+num2str(lnmb)+"_Contrast")
		NVAR Eta=$("MassFr"+num2str(lnmb)+"_Eta")
		NVAR SASBackgroundError
		NVAR SASBackground

	string LogLogTag, IQ4Tag, tagname
	tagname="MassFract"+num2str(Lnmb)+"Tag"
	Wave OriginalQvector
		
	variable QtoAttach=2/Ksi
	variable AttachPointNum=binarysearch(OriginalQvector,QtoAttach)
	
	LogLogTag="\F'Times'\Z10Mass fractal fit "+num2str(Lnmb)+"\r"
	if (DVError>0)
		LogLogTag+="Dv = "+num2str(Dv)+"  \t +/-"+num2str(DvError)+"\r"
	else
		LogLogTag+="Dv = "+num2str(Dv)+"  \t 0 "+"\r"
	endif	
	if (RadiusError>0)
		LogLogTag+="Radius = "+num2str(Radius)+"[A]  \t+/-"+num2str(RadiusError)+"\r"
	else
		LogLogTag+="Radius = "+num2str(Radius)+"[A]  \t 0 "+"\r"	
	endif
	if (PhiError>0)
		LogLogTag+="Phi = "+num2str(Phi)+"  \t +/-"+num2str(PhiError)+"\r"
	else
		LogLogTag+="Phi = "+num2str(Phi)+"  \t 0 "+"\r"
	endif
	if (KsiError>0)
		LogLogTag+="Ksi = "+num2str(Ksi)+"  \t +/-"+num2str(KsiError)+"\r"
	else
		LogLogTag+="Ksi = "+num2str(Ksi)+"  \t 0  "	+"\r"
	endif
	LogLogTag+="Beta = "+num2str(BetaVar)+"; "
	LogLogTag+="Contrast = "+num2str(Contrast)+"x 10\S20\M; "
	LogLogTag+="Eta = "+num2str(Eta)
	if (Lnmb==1)
		if (SASBackgroundError>0)
			LogLogTag+="\rSAS Background = "+num2str(SASBackground)+"     +/-   "+num2str(SASBackgroundError)
		else
			LogLogTag+="\rSAS Background = "+num2str(SASBackground)+"     (fixed)   "
		endif
	endif
	
	IQ4Tag=LogLogTag
	Tag/W=IR1V_LogLogPlotV/C/N=$(tagname)/F=2/L=2/M OriginalIntensity, AttachPointNum, LogLogTag
	Tag/W=IR1V_IQ4_Q_PlotV/C/N=$(tagname)/F=2/L=2/M OriginalIntQ4, AttachPointNum, IQ4Tag
	
	setDataFolder oldDF
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_RecoverOldParameters()
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel

	NVAR SASBackground=root:Packages:FractalsModel:SASBackground
	NVAR SASBackgroundError=root:Packages:FractalsModel:SASBackgroundError
	SVAR DataFolderName=root:Packages:FractalsModel:DataFolderName
	

	variable DataExists=0,i
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(DataFolderName, 2)
	string tempString
	if (stringmatch(ListOfWaves, "*FractFitIntensity*" ))
		string ListOfSolutions=""
		For(i=0;i<itemsInList(ListOfWaves);i+=1)
			if (stringmatch(stringFromList(i,ListOfWaves),"*FractFitIntensity*"))
				tempString=stringFromList(i,ListOfWaves)
				Wave tempwv=$(DataFolderName+tempString)
				tempString=stringByKey("UsersComment",note(tempwv),"=")
				ListOfSolutions+=stringFromList(i,ListOfWaves)+"*  "+tempString+";"
			endif
		endfor
		DataExists=1
		string ReturnSolution=""
		Prompt ReturnSolution, "Select solution to recover", popup,  ListOfSolutions+";Start fresh"
		DoPrompt "Previous solutions found, select one to recover", ReturnSolution
		if (V_Flag)
			abort
		endif
	endif

	if (DataExists==1 && cmpstr("Start fresh", ReturnSolution)!=0)
		ReturnSolution=ReturnSolution[0,strsearch(ReturnSolution, "*", 0 )-1]
		Wave/Z OldDistribution=$(DataFolderName+ReturnSolution)

		string OldNote=note(OldDistribution)
		for(i=0;i<ItemsInList(OldNote);i+=1)
			NVAR/Z testVal=$(StringFromList(0,StringFromList(i,OldNote),"="))
			if(NVAR_Exists(testVal))
				testVal=str2num(StringFromList(1,StringFromList(i,OldNote),"="))
			endif
		endfor
		return 1
	else
		return 0
	endif
	setDataFolder oldDF
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_GraphModelData()

		IR1V_FractalCalculateIntensity()
		//now calculate the normalized error wave
		IR1V_CalculateNormalizedError("graph")
		//append waves to the two top graphs with measured data
		IR1V_AppendModelToMeasuredData()	
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_CopyDataBackToFolder(StandardOrUser)
	string StandardOrUser
	//here we need to copy the final data back to folder
	//before that we need to also attach note to teh waves with the results
	
	string OldDf=getDataFOlder(1)
	setDataFolder root:Packages:FractalsModel
	
	string UsersComment="Fractals model Fit results from "+date()+"  "+time()
	
	Prompt UsersComment, "Modify comment to be included with these results"
	DoPrompt "Copy data back to folder comment", UsersComment
	if (V_Flag)
		abort
	endif
	
	Wave FractFitIntensity=root:Packages:FractalsModel:FractFitIntensity
	Wave FractFitQvector=root:Packages:FractalsModel:FractFitQvector
	
	NVAR UseMassFract1=root:Packages:FractalsModel:UseMassFract1
	NVAR UseMassFract2=root:Packages:FractalsModel:UseMassFract2
	NVAR UseSurfFract1=root:Packages:FractalsModel:UseSurfFract1
	NVAR UseSurfFract2=root:Packages:FractalsModel:UseSurfFract2
	SVAR DataFolderName=root:Packages:FractalsModel:DataFolderName
	
	Duplicate/O FractFitIntensity, tempFractFitIntensity
	Duplicate/O FractFitQvector, tempFractFitQvector
	string ListOfWavesForNotes="tempFractFitIntensity;tempFractFitQvector;"
	
	IR1V_AppendWaveNote(ListOfWavesForNotes)
	
	setDataFolder $DataFolderName
	string tempname 
	variable ii=0, i
	For(ii=0;ii<1000;ii+=1)
		tempname="FractFitIntensity_"+num2str(ii)
		if (checkname(tempname,1)==0)
			break
		endif
	endfor
	Duplicate /O tempFractFitIntensity, $tempname
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm")
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)

	tempname="FractFitQvector_"+num2str(ii)
	Duplicate /O tempFractFitQvector, $tempname
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	
	//and now local fits also
	if(UseMassFract1)
		Wave Mass1FractFitIntensity=root:Packages:FractalsModel:Mass1FractFitIntensity
		tempname="Mass1FractFitInt_"+num2str(ii)
		Duplicate /O Mass1FractFitIntensity, $tempname
		IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
		IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
		IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
		tempname="Mass1FractFitQvec_"+num2str(ii)
		Duplicate /O FractFitQvector, $tempname
		IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
		IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
		IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	endif
	if(UseMassFract2)
		Wave Mass2FractFitIntensity=root:Packages:FractalsModel:Mass2FractFitIntensity
		tempname="Mass2FractFitInt_"+num2str(ii)
		Duplicate /O Mass2FractFitIntensity, $tempname
		IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
		IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
		IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
		tempname="Mass2FractFitQvec_"+num2str(ii)
		Duplicate /O FractFitQvector, $tempname
		IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
		IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
		IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	endif
	if(UseSurfFract1)
		Wave Surf1FractFitIntensity=root:Packages:FractalsModel:Surf1FractFitIntensity
		tempname="Surf1FractFitInt_"+num2str(ii)
		Duplicate /O Surf1FractFitIntensity, $tempname
		IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
		IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
		IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
		tempname="Surf1FractFitQvec_"+num2str(ii)
		Duplicate /O FractFitQvector, $tempname
		IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
		IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
		IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	endif
	if(UseSurfFract2)
		Wave Surf2FractFitIntensity=root:Packages:FractalsModel:Surf2FractFitIntensity
		tempname="Surf2FractFitInt_"+num2str(ii)
		Duplicate /O Surf2FractFitIntensity, $tempname
		IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
		IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
		IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
		tempname="Surf2FractFitQvec_"+num2str(ii)
		Duplicate /O FractFitQvector, $tempname
		IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
		IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
		IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	endif

	setDataFolder root:Packages:FractalsModel

	Killwaves tempFractFitIntensity,tempFractFitQvector
	setDataFolder OldDf
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_AppendWaveNote(ListOfWavesForNotes)
	string ListOfWavesForNotes
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel

	NVAR SASBackground=root:Packages:FractalsModel:SASBackground
	NVAR SASBackgroundError=root:Packages:FractalsModel:SASBackgroundError
	SVAR DataFolderName=root:Packages:FractalsModel:DataFolderName
	string ExperimentName=IgorInfo(1)
	variable i
	For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"IgorExperimentName",ExperimentName)
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"DataFolderinIgor",DataFolderName)
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"DistributionTypeModelled", "Fractal model")	
	endfor

	IR1V_AppendWNOfDist(i,ListOfWavesForNotes)

	setDataFolder oldDF
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_AppendWNOfDist(level,ListOfWavesForNotes)
	variable level
	string ListOfWavesForNotes
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel

	
	NVAR SASBackground=root:Packages:FractalsModel:SASBackground
	NVAR FitSASBackground=root:Packages:FractalsModel:FitSASBackground
	NVAR UseMassFract1=root:Packages:FractalsModel:UseMassFract1
	NVAR UseMassFract2=root:Packages:FractalsModel:UseMassFract2
	NVAR UseSurfFract1=root:Packages:FractalsModel:UseSurfFract1
	NVAR UseSurfFract2=root:Packages:FractalsModel:UseSurfFract2
	NVAR SASBackground=root:Packages:FractalsModel:SASBackground
	NVAR FitSASBackground=root:Packages:FractalsModel:FitSASBackground

	string ListOfVariables
		
	ListOfVariables="SASBackground;SASBackgroundError;SASBackgroundStep;FitSASBackground;UpdateAutomatically;DisplayLocalFits;"
	ListOfVariables+="UseMassFract1;UseMassFract2;UseSurfFract1;UseSurfFract2;"
	variable i,j
	string CurVariable
	For(j=0;j<ItemsInList(ListOfVariables);j+=1)
		CurVariable=StringFromList(j,ListOfVariables)
		NVAR TempVal=$(CurVariable)
		For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),CurVariable,num2str(TempVal))
		endfor
	endfor
	if(UseMassFract1)
		ListOfVariables="MassFr1_Phi;MassFr1_Radius;MassFr1_Dv;MassFr1_Ksi;MassFr1_Beta;MassFr1_Contrast;MassFr1_Eta;MassFr1_IntgNumPnts;"
		ListOfVariables+="MassFr1_FitPhi;MassFr1_FitRadius;MassFr1_FitDv;MassFr1_FitKsi;"
		ListOfVariables+="MassFr1_PhiError;MassFr1_RadiusError;MassFr1_DvError;MassFr1_KsiError;"
		ListOfVariables+="MassFr1_PhiMin;MassFr1_PhiMax;MassFr1_RadiusMin;MassFr1_RadiusMax;"
		ListOfVariables+="MassFr1_DvMin;MassFr1_DvMax;MassFr1_KsiMin;MassFr1_KsiMax;MassFr1_FitMin;MassFr1_FitMax;"
		For(j=0;j<ItemsInList(ListOfVariables);j+=1)
			CurVariable=StringFromList(j,ListOfVariables)
			NVAR TempVal=$(CurVariable)
			For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),CurVariable,num2str(TempVal))
			endfor
		endfor
	endif
		
	if(UseMassFract2)
		ListOfVariables="MassFr2_Phi;MassFr2_Radius;MassFr2_Dv;MassFr2_Ksi;MassFr2_Beta;MassFr2_Contrast;MassFr2_Eta;MassFr2_IntgNumPnts;"
		ListOfVariables+="MassFr2_FitPhi;MassFr2_FitRadius;MassFr2_FitDv;MassFr2_FitKsi;"
		ListOfVariables+="MassFr2_PhiError;MassFr2_RadiusError;MassFr2_DvError;MassFr2_KsiError;MassFr2_FitError;"
		ListOfVariables+="MassFr2_PhiMin;MassFr2_PhiMax;MassFr2_RadiusMin;MassFr2_RadiusMax;"
		ListOfVariables+="MassFr2_DvMin;MassFr2_DvMax;MassFr2_KsiMin;MassFr2_KsiMax;MassFr2_FitMin;MassFr2_FitMax;"
		For(j=0;j<ItemsInList(ListOfVariables);j+=1)
			CurVariable=StringFromList(j,ListOfVariables)
			NVAR TempVal=$(CurVariable)
			For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),CurVariable,num2str(TempVal))
			endfor
		endfor
	endif

	if(UseSurfFract1)	
		ListOfVariables="SurfFr1_Surface;SurfFr1_Ksi;SurfFr1_DS;SurfFr1_Contrast;"
		ListOfVariables+="SurfFr1_FitSurface;SurfFr1_FitKsi;SurfFr1_FitDS;"
		ListOfVariables+="SurfFr1_SurfaceError;SurfFr1_KsiError;SurfFr1_DSError;"
		ListOfVariables+="SurfFr1_SurfaceMin;SurfFr1_SurfaceMax;SurfFr1_KsiMin;SurfFr1_KsiMax;"
		ListOfVariables+="SurfFr1_DSMin;SurfFr1_DSMax;"
		For(j=0;j<ItemsInList(ListOfVariables);j+=1)
			CurVariable=StringFromList(j,ListOfVariables)
			NVAR TempVal=$(CurVariable)
			For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),CurVariable,num2str(TempVal))
			endfor
		endfor
	endif
		
	if(UseSurfFract2)	
		ListOfVariables="SurfFr2_Surface;SurfFr2_Ksi;SurfFr2_DS;SurfFr2_Contrast;"
		ListOfVariables+="SurfFr2_FitSurface;SurfFr2_FitKsi;SurfFr2_FitDS;"
		ListOfVariables+="SurfFr2_SurfaceError;SurfFr2_KsiError;SurfFr2_DSError;"
		ListOfVariables+="SurfFr2_SurfaceMin;SurfFr2_SurfaceMax;SurfFr2_KsiMin;SurfFr2_KsiMax;"
		ListOfVariables+="SurfFr2_DSMin;SurfFr2_DSMax;"
		For(j=0;j<ItemsInList(ListOfVariables);j+=1)
			CurVariable=StringFromList(j,ListOfVariables)
			NVAR TempVal=$(CurVariable)
			For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),CurVariable,num2str(TempVal))
			endfor
		endfor
	endif
	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_UpdateLocalFitsForOutput()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel

		NVAR UseMassFract1=root:Packages:FractalsModel:UseMassFract1
		NVAR UseMassFract2=root:Packages:FractalsModel:UseMassFract2
		NVAR UseSurfFract1=root:Packages:FractalsModel:UseSurfFract1
		NVAR UseSurfFract2=root:Packages:FractalsModel:UseSurfFract2
		NVAR UpdateAutomatically=root:Packages:FractalsModel:UpdateAutomatically
		NVAR ActiveTab=root:Packages:FractalsModel:ActiveTab
		
		RemoveFromGraph /W=IR1V_LogLogPlotV /Z FitLevel1Porod,FitLevel2Porod,FitLevel3Porod,FitLevel4Porod,FitLevel5Porod
		RemoveFromGraph /W=IR1V_IQ4_Q_PlotV /Z FitLevel1PorodIQ4,FitLevel2PorodIQ4,FitLevel3PorodIQ4,FitLevel4PorodIQ4,FitLevel5PorodIQ4
		
		if(UseMassFract1)
			IR1V_DisplayLocalFits(0)
		endif
		if(UseSurfFract1)
			IR1V_DisplayLocalFits(1)
		endif
		if(UseMassFract2)
			IR1V_DisplayLocalFits(2)
		endif
		if(UseSurfFract2)
			IR1V_DisplayLocalFits(3)
		endif
		
		if (UpdateAutomatically)
			ControlInfo DistTabs
			IR1V_DisplayLocalFits(V_Value)
		endif

	setDataFolder oldDF
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_PanelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel
	
	NVAR AutoUpdate=root:Packages:FractalsModel:UpdateAutomatically
	
	if (cmpstr(ctrlName,"SASBackground")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"SASBackgroundStep")==0)
		//here goes what happens when user changes the SASBackground in distribution
		SetVariable SASBackground,win=IR1V_ControlPanel, limits={0,Inf,varNum}
	endif
	if (cmpstr(ctrlName,"SubtractBackground")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1V_GraphMeasuredData()
		IR1V_AutoUpdateIfSelected()
		MoveWindow /W=IR1V_LogLogPlotV 285,37,760,337
		MoveWindow /W=IR1V_IQ4_Q_PlotV 285,360,760,600
	endif
	if (cmpstr(ctrlName,"MassFr1_Phi")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("MassFr1_Phi",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"MassFr1_Radius")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("MassFr1_Radius",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"MassFr1_Dv")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("MassFr1_Dv",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"MassFr1_Ksi")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("MassFr1_Ksi",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"MassFr1_Beta")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("MassFr1_Beta",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"MassFr1_Contrast")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("MassFr1_Contrast",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"MassFr1_Eta")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("MassFr1_Eta",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"MassFr1_IntgNumPnts")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("MassFr1_IntgNumPnts",0.005)
		IR1V_AutoUpdateIfSelected()
	endif

	if (cmpstr(ctrlName,"SurfFr1_Surface")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("SurfFr1_Surface",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"SurfFr1_DS")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("SurfFr1_DS",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"SurfFr1_Ksi")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("SurfFr1_Ksi",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"SurfFr1_Contrast")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("SurfFr1_Contrast",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"MassFr2_Phi")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("MassFr2_Phi",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"MassFr2_Radius")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("MassFr2_Radius",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"MassFr2_Dv")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("MassFr2_Dv",0.005)
		IR1V_AutoUpdateIfSelected()
	endif


	if (cmpstr(ctrlName,"MassFr2_Ksi")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("MassFr2_Ksi",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"MassFr2_Beta")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("MassFr2_Beta",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"MassFr2_Contrast")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("MassFr2_Contrast",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"MassFr2_Eta")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("MassFr2_Eta",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"MassFr2_IntgNumPnts")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("MassFr2_IntgNumPnts",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"SurfFr2_Surface")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("SurfFr2_Surface",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"SurfFr2_DS")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("SurfFr2_DS",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"SurfFr2_Ksi")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("SurfFr2_Ksi",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"SurfFr2_Contrast")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1G_UpdateSetVarStep("SurfFr2_Contrast",0.005)
		IR1V_AutoUpdateIfSelected()
	endif
	setDataFolder oldDF
	DoWIndow/F IR1V_ControlPanel
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_GraphMeasuredData()
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel
	SVAR DataFolderName
	SVAR IntensityWaveName
	SVAR QWavename
	SVAR ErrorWaveName
	
	//fix for liberal names
	IntensityWaveName = PossiblyQuoteName(IntensityWaveName)
	QWavename = PossiblyQuoteName(QWavename)
	ErrorWaveName = PossiblyQuoteName(ErrorWaveName)
	
	WAVE/Z test=$(DataFolderName+IntensityWaveName)
	if (!WaveExists(test))
		abort "Error in IntensityWaveName wave selection"
	endif
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
	NVAR/Z SubtractBackground=root:Packages:FractalsModel:SubtractBackground
	if(NVAR_Exists(SubtractBackground))
		OriginalIntensity =OriginalIntensity - SubtractBackground
	endif
	
		DoWindow IR1V_LogLogPlotV
		if (V_flag)
			Dowindow/K IR1V_LogLogPlotV
		endif
		Execute ("IR1V_LogLogPlotV()")
	
	Duplicate/O $(DataFolderName+IntensityWaveName), OriginalIntQ4
	Duplicate/O $(DataFolderName+QWavename), OriginalQ4
	Duplicate/O $(DataFolderName+ErrorWaveName), OriginalErrQ4
	Redimension/D OriginalIntQ4, OriginalQ4, OriginalErrQ4

	if(NVAR_Exists(SubtractBackground))
		OriginalIntQ4 =OriginalIntQ4 - SubtractBackground
	endif
	
	OriginalQ4=OriginalQ4^4
	OriginalIntQ4=OriginalIntQ4*OriginalQ4
	OriginalErrQ4=OriginalErrQ4*OriginalQ4

		DoWindow IR1V_IQ4_Q_PlotV
		if (V_flag)
			Dowindow/K IR1V_IQ4_Q_PlotV
		endif
		Execute ("IR1V_IQ4_Q_PlotV()")
	setDataFolder oldDf
end

Proc  IR1V_LogLogPlotV()
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:FractalsModel:
	Display /W=(282.75,37.25,759.75,208.25)/K=1  OriginalIntensity vs OriginalQvector as "LogLogPlot"
	DoWindow/C IR1V_LogLogPlotV
	ModifyGraph mode(OriginalIntensity)=3
	ModifyGraph msize(OriginalIntensity)=1
	ModifyGraph log=1
	ModifyGraph mirror=1
	ShowInfo
	String LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Intensity [cm\\S-1\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"]"
	Label left LabelStr
	LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"]"
	Label bottom LabelStr
//	Label left "Intensity [cm\\S-1\\M]"
//	Label bottom "Q [A\\S-1\\M]"
	TextBox/W=IR1V_LogLogPlotV/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR1V_LogLogPlotV/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	string LegendStr="\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")+"\\s(OriginalIntensity) Experimental intensity"
	Legend/W=IR1V_LogLogPlotV/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 LegendStr
	SetDataFolder fldrSav
	ErrorBars/Y=1 OriginalIntensity Y,wave=(root:Packages:FractalsModel:OriginalError,root:Packages:FractalsModel:OriginalError)
EndMacro

Proc  IR1V_IQ4_Q_PlotV() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:FractalsModel:
	Display /W=(283.5,228.5,761.25,383)/K=1  OriginalIntQ4 vs OriginalQvector as "IQ4_Q_Plot"
	DoWIndow/C IR1V_IQ4_Q_PlotV
	ModifyGraph mode(OriginalIntQ4)=3
	ModifyGraph msize(OriginalIntQ4)=1
	ModifyGraph log=1
	ModifyGraph mirror=1
	String LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Intensity * Q\\S4\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"[cm\\S-1\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+" A\\S-4\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"]"
	Label left LabelStr
	LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"]"
	Label bottom LabelStr

//	Label left "Intensity * Q^4"
//	Label bottom "Q [A\\S-1\\M]"
	TextBox/W=IR1V_IQ4_Q_PlotV/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR1V_IQ4_Q_PlotV/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	SetDataFolder fldrSav
	ErrorBars/Y=1 OriginalIntQ4 Y,wave=(root:Packages:FractalsModel:OriginalErrQ4,root:Packages:FractalsModel:OriginalErrQ4)
EndMacro
