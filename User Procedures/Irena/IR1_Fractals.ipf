#pragma TextEncoding = "UTF-8"
#pragma rtGlobals = 3	// Use strict wave reference mode and runtime bounds checking
#pragma version=2.11
Constant IRVversionNumber=2.11


//*************************************************************************\
//* Copyright (c) 2005 - 2021, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.11 add option to use Unified Spere form factor instead of Spheroid
//2.10 comibed with IR1_FractalsFiting.ipf, IR1_FractalsInit.ipf, and IR1_FractalsCntrlPanel.ipf
//2.06 added getHelp button calling to www manual 
//2.05 fixed BessJ into Besselj, newer function. 
//2.04 added controls for Qc width
//2.03 added Qc (transitional Q when Surface fractal changes to Porod's slope)
//2.02 added version control and scrolable controls. 
//2.01 added license for ANL
// Original Panel notes:
//2.08 modified graph size control to use IN2G_GetGraphWidthHeight and associated settings. Should work on various display sizes. 
//2.07  removed unused functions
//2.06 added getHelp button calling to www manual
//2.05 fixes for panel scaling
//2.04 added controls for Qc width
//2.03 Added Qc as transition from Surface fractal to Porods termainal (Q^-4) slope. 
//2.02  Modified all controls not to define font and font size to enable proper control by user 

//Fractals model using Andrew ALlens theory of combining together mass and surface fractal
//systems. 
//Jan Ilavsky, December 2003



///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR1V_FractalsModel()
	
	IN2G_CheckScreenSize("height",670)
	IR1V_InitializeFractals()
	
	KillWIndow/Z IR1V_ControlPanel
	KillWIndow/Z IR1V_LogLogPlotV
	KillWindow/Z IR1V_IQ4_Q_PlotV
	IR1V_ControlPanelFnct()
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("IR1V_ControlPanel", IRVversionNumber,1)

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_MainCheckVersion()	
	DoWindow IR1V_ControlPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR1V_ControlPanel", IRVversionNumber))
			DoAlert /T="The Fractals panel was created by incorrect version of Irena " 1, "Fractals tool may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				IR1V_FractalsModel()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR1V_InitializeFractals()					//this may be OK now... 
			endif
		endif
	endif
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_ControlPanelFnct() 
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(2.25,43.25,390,690) as "Fractals model"
	DoWindow/C IR1V_ControlPanel
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("FractalsModel","IR1V_ControlPanel","DSM_Int;M_DSM_Int;","",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1)
	TitleBox MainTitle title="\Zr200Fractals model input panel",pos={20,0},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={350,24},anchor=MC,fColor=(0,0,52224)
	CheckBox UseIndra2Data help={"This tool requires Desmeared USAXS data"}
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,181},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info1 title="\Zr140Data input",pos={8,30},frame=0,fstyle=1, fixedSize=1,size={80,20},fColor=(0,0,52224)
	TitleBox Info2 title="\Zr140Fractals model input",pos={10,185},frame=0,fstyle=2, fixedSize=1,size={150,20},fstyle=3,fColor=(0,0,65535)
	TitleBox Info31 title="\Zr130Fit?",pos={200,275},frame=0,fstyle=2, fixedSize=0,size={20,15}
	TitleBox Info32 title="\Zr130Low limit:",pos={230,275},frame=0,fstyle=2, fixedSize=0,size={20,15}
	TitleBox Info33 title="\Zr130High Limit:",pos={300,275},frame=0,fstyle=2, fixedSize=0,size={20,15}
	TitleBox Info5 title="\Zr130Fit using least square fitting ?",pos={2,588},frame=0,fstyle=3, fixedSize=0,size={140,15},fColor=(0,0,52224)
	TitleBox FakeLine2 title=" ",fixedSize=1,size={330,3},pos={16,612},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info6 title="\Zr140Results",pos={2,620},frame=0,fstyle=3, fixedSize=0,size={40,15},fColor=(0,0,52224)

	Button DrawGraphs,pos={56,158},size={100,20}, proc=IR1V_InputPanelButtonProc,title="Graph", help={"Create a graph (log-log) of your experiment data"}
	SetVariable SubtractBackground,limits={-inf,Inf,0.1},value= root:Packages:FractalsModel:SubtractBackground
	SetVariable SubtractBackground,pos={170,162},size={180,16},title="Subtract background",proc=IR1V_PanelSetVarProc, help={"Subtract flat background from input data"}
	Button GetHelp,pos={305,105},size={80,15},fColor=(65535,32768,32768), proc=IR1V_InputPanelButtonProc,title="Get Help", help={"Open www manual page for this tool"}

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


	Button DoFitting,pos={195,588},size={70,20}, proc=IR1V_InputPanelButtonProc,title="Fit", help={"Do least sqaures fitting of the whole model, find good starting conditions and proper limits before fitting"}
	Button RevertFitting,pos={275,588},size={100,20}, proc=IR1V_InputPanelButtonProc,title="Revert back",help={"Return back befoire last fitting attempt"}
	Button CopyToFolder,pos={60,620},size={100,20}, proc=IR1V_InputPanelButtonProc,title="Store in Data Folder", help={"Copy results of the modeling into original data folder"}
	Button ExportData,pos={170,620},size={100,20}, proc=IR1V_InputPanelButtonProc,title="Export ASCII", help={"Export ASCII data out of Igor"}
	Button MarkGraphs,pos={280,620},size={100,20}, proc=IR1V_InputPanelButtonProc,title="Results to graphs", help={"Insert text boxes with results into the graphs for printing"}
	SetVariable SASBackground,pos={10,569},size={190,16},proc=IR1V_PanelSetVarProc,title="SAS Background", help={"SAS background"}
	NVAR SASBackgroundStep = root:Packages:FractalsModel:SASBackgroundStep
	SetVariable SASBackground,limits={-inf,Inf,SASBackgroundStep},value= root:Packages:FractalsModel:SASBackground
	SetVariable SASBackgroundStep,pos={205,569},size={70,16},title="step",proc=IR1V_PanelSetVarProc, help={"Step for increments in SAS background"}
	SetVariable SASBackgroundStep,limits={0,Inf,0},value= root:Packages:FractalsModel:SASBackgroundStep
	CheckBox FitBackground,pos={285,569},size={63,14},proc=IR1V_InputPanelCheckboxProc,title="Fit Bckg?"
	CheckBox FitBackground,variable= root:Packages:FractalsModel:FitSASBackground, help={"Check if you want the background to be fitting parameter"}

	//Dist Tabs definition
	TabControl DistTabs,pos={10,250},size={370,310},proc=IR1V_TabPanelControl
	TabControl DistTabs,fSize=10,tabLabel(0)="Mass Fract. 1",tabLabel(1)="Surf. Fract. 1"
	TabControl DistTabs,tabLabel(2)="Mass Fract. 2",tabLabel(3)="Surf. Fract. 2",value= 0

	//Mass fractal 1 controls
	
	TitleBox MassFract1_Title, title="   Mass fractal 1 controls    ", frame=1, labelBack=(64000,0,0), pos={13,272},size={150,21}, fixedSize=1

	SetVariable MassFr1_Phi,pos={14,295},size={160,16},proc=IR1V_PanelSetVarProc,title="Particle volume   "
	NVAR MassFr1_PhiStep = root:Packages:FractalsModel:MassFr1_PhiStep
	SetVariable MassFr1_Phi,limits={0,inf,MassFr1_PhiStep},value= root:Packages:FractalsModel:MassFr1_Phi, help={"Fractional volume of particles in the system"}
	CheckBox MassFr1_FitPhi,pos={200,296},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox MassFr1_FitPhi,variable= root:Packages:FractalsModel:MassFr1_FitPhi, help={"Fit particle volume?, find god starting conditions and select fitting limits..."}
	SetVariable MassFr1_PhiMin,pos={230,295},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr1_PhiMin,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr1_PhiMin, help={"Low limit for Particle volume fitting"}
	SetVariable MassFr1_PhiMax,pos={300,295},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr1_PhiMax,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr1_PhiMax, help={"High limit for Particle volume fitting"}

	SetVariable MassFr1_Radius,pos={14,320},size={160,16},proc=IR1V_PanelSetVarProc,title="Radius              ", help={"Mean particle Radius"}
	NVAR MassFr1_RadiusStep = root:Packages:FractalsModel:MassFr1_RadiusStep
	SetVariable MassFr1_Radius,limits={0,inf,MassFr1_RadiusStep},value= root:Packages:FractalsModel:MassFr1_Radius
	CheckBox MassFr1_FitRadius,pos={200,321},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox MassFr1_FitRadius,variable= root:Packages:FractalsModel:MassFr1_FitRadius, help={"Fit Radius? Select properly starting conditions and limits"}
	SetVariable MassFr1_RadiusMin,pos={230,320},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr1_RadiusMin,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr1_RadiusMin, help={"Low limit for Radius fitting..."}
	SetVariable MassFr1_RadiusMax,pos={300,320},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr1_RadiusMax,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr1_RadiusMax, help={"High limit for Radius fitting"}

	SetVariable MassFr1_Dv,pos={14,345},size={160,16},proc=IR1V_PanelSetVarProc,title="Dv (fractal dim.)  ", help={"Fractal dimension - for mass fractal between 1 and 3, chanegs slope..."}
	NVAR MassFr1_DvStep = root:Packages:FractalsModel:MassFr1_DvStep
	SetVariable MassFr1_Dv,limits={1,3,MassFr1_DvStep},value= root:Packages:FractalsModel:MassFr1_Dv
	CheckBox MassFr1_FitDv,pos={200,346},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox MassFr1_FitDv,variable= root:Packages:FractalsModel:MassFr1_FitDv, help={"Fit the Dv?, select properly the starting conditions and limits before fitting"}
	SetVariable MassFr1_DvMin,pos={230,345},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr1_DvMin,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr1_DvMin, help={"Dv low limit"}
	SetVariable MassFr1_DvMax,pos={300,345},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr1_DvMax,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr1_DvMax, help={"Dv high limit"}

	SetVariable MassFr1_Ksi,pos={14,370},size={160,16},proc=IR1V_PanelSetVarProc,title="Correlation length ", help={"Correlation length of mass fractal, Ksi in the formula"}
	NVAR MassFr1_KsiStep = root:Packages:FractalsModel:MassFr1_KsiStep
	SetVariable MassFr1_Ksi,limits={0,inf,MassFr1_KsiStep},value= root:Packages:FractalsModel:MassFr1_Ksi
	CheckBox MassFr1_FitKsi,pos={200,371},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox MassFr1_FitKsi,variable= root:Packages:FractalsModel:MassFr1_FitKsi, help={"Fit the Correlation length, select good starting conditions and appropriate limits"}
	SetVariable MassFr1_KsiMin,pos={230,370},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr1_KsiMin,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr1_KsiMin, help={"Correlation length low limit"}
	SetVariable MassFr1_KsiMax,pos={300,370},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr1_KsiMax,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr1_KsiMax, help={"Correlation length high limit"}

	CheckBox MassFr1_UseUFFormFactor,pos={20,400},size={200,16},proc=IR1V_InputPanelCheckboxProc,title="Use UF Particle Form factor? "
	CheckBox MassFr1_UseUFFormFactor,variable= root:Packages:FractalsModel:MassFr1_UseUFFormFactor, help={"Check to use Unified Fit Form Factor. Beta=1 = Primary particle is sphere."}

	SetVariable MassFr1_UFPDIIndex,pos={14,420},size={320,16},proc=IR1V_PanelSetVarProc,title="Polydispersity index                         "
	SetVariable MassFr1_UFPDIIndex,limits={1,10,0.5},value=root:Packages:FractalsModel:MassFr1_UFPDIIndex, help={"Polydispersity index for Unified fit size distribution 1 to 10"}

	SetVariable MassFr1_Beta,pos={14,420},size={320,16},proc=IR1V_PanelSetVarProc,title="Particle aspect ratio                           "
	SetVariable MassFr1_Beta,limits={0.01,100,0.1},value= root:Packages:FractalsModel:MassFr1_Beta, help={"Beta, aspect ratio of particles, should be about 0.5 and 2"}
	SetVariable MassFr1_Contrast,pos={14,440},size={320,16},proc=IR1V_PanelSetVarProc,title="Contrast [x 10^20]                           "
	SetVariable MassFr1_Contrast,limits={0,inf,1},value= root:Packages:FractalsModel:MassFr1_Contrast, help={"Scattering contrast"}
	SetVariable MassFr1_Eta,pos={14,460},size={320,16},proc=IR1V_PanelSetVarProc,title="Volume filling                                    "
	SetVariable MassFr1_Eta,limits={0.3,0.8,0.05},value= root:Packages:FractalsModel:MassFr1_Eta, help={"Eta (filling of the volume) about 0.4 to 0.6 "}
	SetVariable MassFr1_IntgNumPnts,pos={14,480},size={320,16},proc=IR1V_PanelSetVarProc,title="Internal Integration Num pnts             "
	SetVariable MassFr1_IntgNumPnts,limits={50,500,50},value= root:Packages:FractalsModel:MassFr1_IntgNumPnts, help={"Number of points for internal integration. About 500 is usual, increase if there are artefacts. "}

	TitleBox MassFract2_Title, title="   Mass fractal 2 controls    ", frame=1, labelBack=(0,0,64000), pos={13,272},size={150,21}, fixedSize=1

	SetVariable MassFr2_Phi,pos={14,295},size={160,16},proc=IR1V_PanelSetVarProc,title="Particle volume   "
	NVAR MassFr2_PhiStep = root:Packages:FractalsModel:MassFr2_PhiStep
	SetVariable MassFr2_Phi,limits={0,inf,MassFr2_PhiStep},value= root:Packages:FractalsModel:MassFr2_Phi, help={"Volme of particles in the system"}
	CheckBox MassFr2_FitPhi,pos={200,296},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox MassFr2_FitPhi,variable= root:Packages:FractalsModel:MassFr2_FitPhi, help={"Fit particle volume?, find god starting conditions and select fitting limits..."}
	SetVariable MassFr2_PhiMin,pos={230,295},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr2_PhiMin,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr2_PhiMin, help={"Low limit for Particle volume fitting"}
	SetVariable MassFr2_PhiMax,pos={300,295},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr2_PhiMax,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr2_PhiMax, help={"High limit for Particle volume fitting"}

	SetVariable MassFr2_Radius,pos={14,320},size={160,16},proc=IR1V_PanelSetVarProc,title="Mean Radius         ", help={"Mean particle Radius"}
	NVAR MassFr2_RadiusStep = root:Packages:FractalsModel:MassFr2_RadiusStep
	SetVariable MassFr2_Radius,limits={0,inf,MassFr2_RadiusStep},value= root:Packages:FractalsModel:MassFr2_Radius
	CheckBox MassFr2_FitRadius,pos={200,321},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox MassFr2_FitRadius,variable= root:Packages:FractalsModel:MassFr2_FitRadius, help={"Fit Radius? Select properly starting conditions and limits"}
	SetVariable MassFr2_RadiusMin,pos={230,320},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr2_RadiusMin,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr2_RadiusMin, help={"Low limit for Radius fitting..."}
	SetVariable MassFr2_RadiusMax,pos={300,320},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr2_RadiusMax,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr2_RadiusMax, help={"High limit for Radius fitting"}

	SetVariable MassFr2_Dv,pos={14,345},size={160,16},proc=IR1V_PanelSetVarProc,title="Dv (fractal dim.)  ", help={"Fractal dimension for mass fractal between 1 and 3"}
	NVAR MassFr2_DvStep = root:Packages:FractalsModel:MassFr2_DvStep
	SetVariable MassFr2_Dv,limits={1,3,MassFr2_DvStep},value= root:Packages:FractalsModel:MassFr2_Dv
	CheckBox MassFr2_FitDv,pos={200,346},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox MassFr2_FitDv,variable= root:Packages:FractalsModel:MassFr2_FitDv, help={"Fit the Dv?, select properly the starting conditions and limits before fitting"}
	SetVariable MassFr2_DvMin,pos={230,345},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr2_DvMin,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr2_DvMin, help={"Dv low limit"}
	SetVariable MassFr2_DvMax,pos={300,345},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr2_DvMax,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr2_DvMax, help={"Dv high limit"}

	SetVariable MassFr2_Ksi,pos={14,370},size={160,16},proc=IR1V_PanelSetVarProc,title="Correlation length ", help={"Correlation length of mass fractal, Ksi in the formula"}
	NVAR MassFr2_KsiStep = root:Packages:FractalsModel:MassFr2_KsiStep
	SetVariable MassFr2_Ksi,limits={0,inf,MassFr2_KsiStep},value= root:Packages:FractalsModel:MassFr2_Ksi
	CheckBox MassFr2_FitKsi,pos={200,371},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox MassFr2_FitKsi,variable= root:Packages:FractalsModel:MassFr2_FitKsi, help={"Fit the correlation length, select good starting conditions and appropriate limits"}
	SetVariable MassFr2_KsiMin,pos={230,370},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr2_KsiMin,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr2_KsiMin, help={"Correlation length low limit"}
	SetVariable MassFr2_KsiMax,pos={300,370},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable MassFr2_KsiMax,limits={0,inf,0},value= root:Packages:FractalsModel:MassFr2_KsiMax, help={"Correlation length high limit"}

	CheckBox MassFr2_UseUFFormFactor,pos={20,400},size={200,16},proc=IR1V_InputPanelCheckboxProc,title="Use UF Particle Form factor? "
	CheckBox MassFr2_UseUFFormFactor,variable= root:Packages:FractalsModel:MassFr2_UseUFFormFactor, help={"Check to use Unified Fit Form Factor. Beta=1 = Primary particle is sphere."}

	SetVariable MassFr2_UFPDIIndex,pos={14,420},size={320,16},proc=IR1V_PanelSetVarProc,title="Polydispersity index                         "
	SetVariable MassFr2_UFPDIIndex,limits={1,10,0.5},value=root:Packages:FractalsModel:MassFr2_UFPDIIndex, help={"Polydispersity index for Unified fit size distribution 1 to 10"}
	SetVariable MassFr2_Beta,pos={14,420},size={320,16},proc=IR1V_PanelSetVarProc,title="Particle aspect ratio                           "
	SetVariable MassFr2_Beta,limits={0.01,100,0.1},value= root:Packages:FractalsModel:MassFr2_Beta, help={"Beta, aspect ratio of particles, should be about 0.5 and 2"}
	SetVariable MassFr2_Contrast,pos={14,440},size={320,16},proc=IR1V_PanelSetVarProc,title="Contrast [x 10^20]                           "
	SetVariable MassFr2_Contrast,limits={0,inf,1},value= root:Packages:FractalsModel:MassFr2_Contrast, help={"Scattering contrast"}
	SetVariable MassFr2_Eta,pos={14,460},size={320,16},proc=IR1V_PanelSetVarProc,title="Volume filling                                    "
	SetVariable MassFr2_Eta,limits={0.3,0.8,0.05},value= root:Packages:FractalsModel:MassFr2_Eta, help={"Eta (filling of the volume) about 0.4 to 0.6 "}
	SetVariable MassFr2_IntgNumPnts,pos={14,480},size={320,16},proc=IR1V_PanelSetVarProc,title="Internal Integration Num pnts             "
	SetVariable MassFr2_IntgNumPnts,limits={50,500,50},value= root:Packages:FractalsModel:MassFr2_IntgNumPnts, help={"Number of points for internal integration. About 500 is usual, increase if there are artefacts. "}

//SUrface fractal 1 controls
	TitleBox SurfFract1_Title, title="   Surface fractal 1 controls    ", frame=1, labelBack=(0,64000,0), pos={13,272},size={150,21},fixedSize=1

	NVAR SurfFr1_SurfaceStep = root:Packages:FractalsModel:SurfFr1_SurfaceStep

	SetVariable SurfFr1_Surface,pos={14,295},size={160,16},proc=IR1V_PanelSetVarProc,title="Smooth surface   "
	SetVariable SurfFr1_Surface,limits={0,inf,SurfFr1_SurfaceStep},value= root:Packages:FractalsModel:SurfFr1_Surface, help={"Smooth surface in this surface fractal"}
	CheckBox SurfFr1_FitSurface,pos={200,296},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox SurfFr1_FitSurface,variable= root:Packages:FractalsModel:SurfFr1_FitSurface, help={"Fit smooth surface?, find god starting conditions and select fitting limits..."}
	SetVariable SurfFr1_SurfaceMin,pos={230,295},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr1_SurfaceMin,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr1_SurfaceMin, help={"Low limit for Particle volume fitting"}
	SetVariable SurfFr1_SurfaceMax,pos={300,295},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr1_SurfaceMax,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr1_SurfaceMax, help={"High limit for Particle volume fitting"}

	SetVariable SurfFr1_DS,pos={14,345},size={160,16},proc=IR1V_PanelSetVarProc,title="Ds (fractal dim.)  ", help={"Fractal dimension, 2 to 3 for surface fractals, gives -(6-DS) slope (-3 to -4)"}
	NVAR SurfFr1_DSStep = root:Packages:FractalsModel:SurfFr1_DSStep
	SetVariable SurfFr1_DS,limits={2,3,SurfFr1_DSStep},value= root:Packages:FractalsModel:SurfFr1_DS
	CheckBox SurfFr1_fitDS,pos={200,346},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox SurfFr1_fitDS,variable= root:Packages:FractalsModel:SurfFr1_FitDS, help={"Fit the DS?, select properly the starting conditions and limits before fitting"}
	SetVariable SurfFr1_DSMin,pos={230,345},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr1_DSMin,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr1_DSMin, help={"DS low limit"}
	SetVariable SurfFr1_DSMax,pos={300,345},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr1_DSMax,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr1_DSMax, help={"DS high limit"}

	SetVariable SurfFr1_Ksi,pos={14,370},size={160,16},proc=IR1V_PanelSetVarProc,title="Correlation length  ", help={"Correlation length of surface fractal, Ksi in the formula"}
	NVAR SurfFr1_KsiStep = root:Packages:FractalsModel:SurfFr1_KsiStep
	SetVariable SurfFr1_Ksi,limits={0,inf,SurfFr1_KsiStep},value= root:Packages:FractalsModel:SurfFr1_Ksi
	CheckBox SurfFr1_FitKsi,pos={200,371},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox SurfFr1_FitKsi,variable= root:Packages:FractalsModel:SurfFr1_FitKsi, help={"Fit the Correlation legth, select good starting conditions and appropriate limits"}
	SetVariable SurfFr1_KsiMin,pos={230,370},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr1_KsiMin,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr1_KsiMin, help={"Correlation legth low limit"}
	SetVariable SurfFr1_KsiMax,pos={300,370},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr1_KsiMax,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr1_KsiMax, help={"Correlation legth high limit"}

	SetVariable SurfFr1_Qc,pos={14,395},size={160,16},proc=IR1V_PanelSetVarProc,title="Qc (Terminal Q)  ", help={"Q max when scattering changes to Porod's law"}
	NVAR SurfFr1_QcStep = root:Packages:FractalsModel:SurfFr1_QcStep
	SetVariable SurfFr1_Qc,limits={0,inf,SurfFr1_QcStep},value= root:Packages:FractalsModel:SurfFr1_Qc

	PopupMenu SurfFr1_QcW,pos={14,415},size={180,16},title="Qc width [% of Qc] ", help={"Transition width at Q max when scattering changes to Porod's law"}
	NVAR SurfFr1_QcWidth = root:Packages:FractalsModel:SurfFr1_QcWidth
	PopupMenu SurfFr1_QcW,proc=IR1V_PopMenuProc,value="5;10;15;20;25;", mode=1+whichListItem(num2str(100*SurfFr1_QcWidth), "5;10;15;20;25;")

	SetVariable SurfFr1_Contrast,pos={14,450},size={220,16},proc=IR1V_PanelSetVarProc,title="Contrast [x 10^20]              "
	SetVariable SurfFr1_Contrast,limits={0,inf,1},value= root:Packages:FractalsModel:SurfFr1_Contrast, help={"Scattering contrast"}

//SUrface fractal 2
	TitleBox SurfFract2_Title, title="   Surface fractal 2 controls    ", frame=1, labelBack=(52000,52000,0), pos={13,272},size={150,21}, fixedSize=1

	SetVariable SurfFr2_Surface,pos={14,295},size={160,16},proc=IR1V_PanelSetVarProc,title="Smooth surface   "
	NVAR SurfFr2_SurfaceStep = root:Packages:FractalsModel:SurfFr2_SurfaceStep
	SetVariable SurfFr2_Surface,limits={0,inf,SurfFr2_SurfaceStep},value= root:Packages:FractalsModel:SurfFr2_Surface, help={"Smooth surface in this surface fractal"}
	CheckBox SurfFr2_FitSurface,pos={200,296},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox SurfFr2_FitSurface,variable= root:Packages:FractalsModel:SurfFr2_FitSurface, help={"Fit smooth surface?, find god starting conditions and select fitting limits..."}
	SetVariable SurfFr2_SurfaceMin,pos={230,295},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr2_SurfaceMin,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr2_SurfaceMin, help={"Low limit for Particle volume fitting"}
	SetVariable SurfFr2_SurfaceMax,pos={300,295},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr2_SurfaceMax,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr2_SurfaceMax, help={"High limit for Particle volume fitting"}

	SetVariable SurfFr2_DS,pos={14,345},size={160,16},proc=IR1V_PanelSetVarProc,title="Ds (fractal dim.)  ", help={"Fractal dimension, 2 to 3 for surface fractals, gives -(6-DS) slope (-3 to -4)"}
	NVAR SurfFr2_DSStep = root:Packages:FractalsModel:SurfFr2_DSStep
	SetVariable SurfFr2_DS,limits={2,3,SurfFr2_DSStep},value= root:Packages:FractalsModel:SurfFr2_DS
	CheckBox SurfFr2_fitDS,pos={200,346},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox SurfFr2_fitDS,variable= root:Packages:FractalsModel:SurfFr2_FitDS, help={"Fit the DS?, select properly the starting conditions and limits before fitting"}
	SetVariable SurfFr2_DSMin,pos={230,345},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr2_DSMin,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr2_DSMin, help={"DS low limit"}
	SetVariable SurfFr2_DSMax,pos={300,345},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr2_DSMax,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr2_DSMax, help={"DS high limit"}

	SetVariable SurfFr2_Ksi,pos={14,370},size={160,16},proc=IR1V_PanelSetVarProc,title="Correlation length  ", help={"Correlation length of surface fractal, Ksi in the formula"}
	NVAR SurfFr1_KsiStep = root:Packages:FractalsModel:SurfFr1_KsiStep
	SetVariable SurfFr2_Ksi,limits={0,inf,SurfFr1_KsiStep},value= root:Packages:FractalsModel:SurfFr2_Ksi
	CheckBox SurfFr2_FitKsi,pos={200,371},size={80,16},proc=IR1V_InputPanelCheckboxProc,title=" "
	CheckBox SurfFr2_FitKsi,variable= root:Packages:FractalsModel:SurfFr2_FitKsi, help={"Fit the Correlation length, select good starting conditions and appropriate limits"}
	SetVariable SurfFr2_KsiMin,pos={230,370},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr2_KsiMin,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr2_KsiMin, help={"Correlation length low limit"}
	SetVariable SurfFr2_KsiMax,pos={300,370},size={60,16},proc=IR1V_PanelSetVarProc, title=" "
	SetVariable SurfFr2_KsiMax,limits={0,inf,0},value= root:Packages:FractalsModel:SurfFr2_KsiMax, help={"Correlation length high limit"}

	SetVariable SurfFr2_Qc,pos={14,395},size={160,16},proc=IR1V_PanelSetVarProc,title="Qc (Terminal Q)  ", help={"Q max when scattering changes to Porod's law"}
	NVAR SurfFr2_QcStep = root:Packages:FractalsModel:SurfFr2_QcStep
	SetVariable SurfFr2_Qc,limits={0,inf,SurfFr2_QcStep},value= root:Packages:FractalsModel:SurfFr2_Qc

	PopupMenu SurfFr2_QcW,pos={14,415},size={180,16},title="Qc width [% of Qc] ", help={"Transition width at Q max when scattering changes to Porod's law"}
	NVAR SurfFr2_QcWidth = root:Packages:FractalsModel:SurfFr2_QcWidth
	PopupMenu SurfFr2_QcW,proc=IR1V_PopMenuProc,value="5;10;15;20;25;", mode=1+whichListItem(num2str(100*SurfFr2_QcWidth), "5;10;15;20;25;")

	SetVariable SurfFr2_Contrast,pos={14,450},size={220,16},proc=IR1A_PanelSetVarProc,title="Contrast [x 10^20]              "
	SetVariable SurfFr2_Contrast,limits={0,inf,1},value= root:Packages:FractalsModel:SurfFr2_Contrast, help={"Scattering contrast"}




	//lets try to update the tabs...
	IR1V_TabPanelControl("test",0)

EndMacro


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR1V_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			string tmpStr=pa.ctrlName
			NVAR Width=$("root:Packages:FractalsModel:"+tmpStr+"idth")
			Width= 0.01*str2num(popStr)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1V_TabPanelControl(name,tab)
	String name
	Variable tab

	DFref oldDf= GetDataFolderDFR()

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
	NVAR MassFr2_UseUFFormFactor=root:Packages:FractalsModel:MassFr2_UseUFFormFactor
	NVAR MassFr1_UseUFFormFactor=root:Packages:FractalsModel:MassFr1_UseUFFormFactor

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
	SetVariable MassFr1_Beta, disable= (tab!=0 || (!UseMassFract1 || MassFr1_UseUFFormFactor))
	SetVariable MassFr1_Contrast, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_Eta, disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_IntgNumPnts, disable= (tab!=0 || !UseMassFract1)
	CheckBox MassFr1_UseUFFormFactor,  disable= (tab!=0 || !UseMassFract1)
	SetVariable MassFr1_UFPDIIndex,  disable= (tab!=0 || (!UseMassFract1 || !MassFr1_UseUFFormFactor))

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
	SetVariable SurfFr1_Qc, disable= (tab!=1 || !UseSurfFract1)
	PopupMenu SurfFr1_QcW, disable= (tab!=1 || !UseSurfFract1)

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
	SetVariable MassFr2_Beta, disable= (tab!=2 || !UseMassFract2 || MassFr2_UseUFFormFactor)
	SetVariable MassFr2_Contrast, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_Eta, disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_IntgNumPnts, disable= (tab!=2 || !UseMassFract2)
	CheckBox MassFr2_UseUFFormFactor,  disable= (tab!=2 || !UseMassFract2)
	SetVariable MassFr2_UFPDIIndex,  disable= (tab!=2 || (!UseMassFract2 || !MassFr2_UseUFFormFactor))
	
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
	SetVariable SurfFr2_Qc, disable= (tab!=3 || !UseSurfFract2)
	PopupMenu SurfFr2_QcW, disable= (tab!=3 || !UseSurfFract2)
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

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:FractalsModel
	ControlInfo/W=IR1V_ControlPanel DistTabs
	VARIABLE ActiveTab=V_Value

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


	if (cmpstr(ctrlName,"MassFr2_UseUFFormFactor")==0)
		NVAR MassFr2_Beta = root:Packages:FractalsModel:MassFr2_Beta
		MassFr2_Beta = 1
		NVAR MassFr2_UseUFFormFactor=root:Packages:FractalsModel:MassFr2_UseUFFormFactor
		SetVariable MassFr2_Beta, win=IR1V_ControlPanel,  disable=MassFr2_UseUFFormFactor
		SetVariable MassFr1_UFPDIIndex, win=IR1V_ControlPanel,  disable=!MassFr2_UseUFFormFactor
		IR1V_AutoUpdateIfSelected()
	endif

	if (cmpstr(ctrlName,"MassFr1_UseUFFormFactor")==0)
		NVAR MassFr1_Beta = root:Packages:FractalsModel:MassFr1_Beta
		MassFr1_Beta = 1
		NVAR MassFr1_UseUFFormFactor=root:Packages:FractalsModel:MassFr1_UseUFFormFactor
		SetVariable MassFr1_Beta, win=IR1V_ControlPanel, disable=MassFr1_UseUFFormFactor
		SetVariable MassFr1_UFPDIIndex, win=IR1V_ControlPanel, disable=!MassFr1_UseUFFormFactor
		IR1V_AutoUpdateIfSelected()
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
	
	IR1V_TabPanelControl("",ActiveTab)
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
	
	DFref oldDf= GetDataFolderDFR()

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
//
//Function IR1V_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//
//	DFref oldDf= GetDataFolderDFR()

//	setDataFolder root:Packages:FractalsModel
//		NVAR UseIndra2Data=root:Packages:FractalsModel:UseIndra2Data
//		NVAR UseQRSData=root:Packages:FractalsModel:UseQRSdata
//		SVAR IntDf=root:Packages:FractalsModel:IntensityWaveName
//		SVAR QDf=root:Packages:FractalsModel:QWaveName
//		SVAR EDf=root:Packages:FractalsModel:ErrorWaveName
//		SVAR Dtf=root:Packages:FractalsModel:DataFolderName
//
//	if (cmpstr(ctrlName,"SelectDataFolder")==0)
//		//here we do what needs to be done when we select data folder
//		Dtf=popStr
//		PopupMenu IntensityDataName mode=1
//		PopupMenu QvecDataName mode=1
//		PopupMenu ErrorDataName mode=1
//		if (UseIndra2Data)
//			if(stringmatch(IR1_ListOfWaves("DSM_Int","FractalsModel",0,0), "*M_BKG_Int*") &&stringmatch(IR1_ListOfWaves("DSM_Qvec","FractalsModel",0,0), "*M_BKG_Qvec*")  &&stringmatch(IR1_ListOfWaves("DSM_Error","FractalsModel",0,0), "*M_BKG_Error*") )			
//				IntDf="M_BKG_Int"
//				QDf="M_BKG_Qvec"
//				EDf="M_BKG_Error"
//				PopupMenu IntensityDataName value="M_BKG_Int;M_DSM_Int;DSM_Int"
//				PopupMenu QvecDataName value="M_BKG_Qvec;M_DSM_Qvec;DSM_Qvec"
//				PopupMenu ErrorDataName value="M_BKG_Error;M_DSM_Error;DSM_Error"
//			elseif(stringmatch(IR1_ListOfWaves("DSM_Int","FractalsModel",0,0), "*BKG_Int*") &&stringmatch(IR1_ListOfWaves("DSM_Qvec","FractalsModel",0,0), "*BKG_Qvec*")  &&stringmatch(IR1_ListOfWaves("DSM_Error","FractalsModel",0,0), "*BKG_Error*") )			
//				IntDf="BKG_Int"
//				QDf="BKG_Qvec"
//				EDf="BKG_Error"
//				PopupMenu IntensityDataName value="BKG_Int;DSM_Int"
//				PopupMenu QvecDataName value="BKG_Qvec;DSM_Qvec"
//				PopupMenu ErrorDataName value="BKG_Error;DSM_Error"
//			elseif(stringmatch(IR1_ListOfWaves("DSM_Int","FractalsModel",0,0), "*M_DSM_Int*") &&stringmatch(IR1_ListOfWaves("DSM_Qvec","FractalsModel",0,0), "*M_DSM_Qvec*")  &&stringmatch(IR1_ListOfWaves("DSM_Error","FractalsModel",0,0), "*M_DSM_Error*") )			
//				IntDf="M_DSM_Int"
//				QDf="M_DSM_Qvec"
//				EDf="M_DSM_Error"
//				PopupMenu IntensityDataName value="M_DSM_Int;DSM_Int"
//				PopupMenu QvecDataName value="M_DSM_Qvec;DSM_Qvec"
//				PopupMenu ErrorDataName value="M_DSM_Error;DSM_Error"
//			else
//				if(!stringmatch(IR1_ListOfWaves("DSM_Int","FractalsModel",0,0), "*M_DSM_Int*") &&!stringmatch(IR1_ListOfWaves("DSM_Qvec","FractalsModel",0,0), "*M_DSM_Qvec*")  &&!stringmatch(IR1_ListOfWaves("DSM_Error","FractalsModel",0,0), "*M_DSM_Error*") )			
//					IntDf="DSM_Int"
//					QDf="DSM_Qvec"
//					EDf="DSM_Error"
//					PopupMenu IntensityDataName value="DSM_Int"
//					PopupMenu QvecDataName value="DSM_Qvec"
//					PopupMenu ErrorDataName value="DSM_Error"
//				endif
//			endif
//		else
//			IntDf=""
//			QDf=""
//			EDf=""
//			PopupMenu IntensityDataName value="---"
//			PopupMenu QvecDataName  value="---"
//			PopupMenu ErrorDataName  value="---"
//		endif
//		if(UseQRSdata)
//			IntDf=""
//			QDf=""
//			EDf=""
//			PopupMenu IntensityDataName  value="---;"+IR1_ListOfWaves("DSM_Int","FractalsModel",0,0)
//			PopupMenu QvecDataName  value="---;"+IR1_ListOfWaves("DSM_Qvec","FractalsModel",0,0)
//			PopupMenu ErrorDataName  value="---;"+IR1_ListOfWaves("DSM_Error","FractalsModel",0,0)
//		endif
//		if(!UseQRSdata && !UseIndra2Data)
//			IntDf=""
//			QDf=""
//			EDf=""
//			PopupMenu IntensityDataName  value="---;"+IR1_ListOfWaves("DSM_Int","FractalsModel",0,0)
//			PopupMenu QvecDataName  value="---;"+IR1_ListOfWaves("DSM_Qvec","FractalsModel",0,0)
//			PopupMenu ErrorDataName  value="---;"+IR1_ListOfWaves("DSM_Error","FractalsModel",0,0)
//		endif
//		if (cmpstr(popStr,"---")==0)
//			IntDf=""
//			QDf=""
//			EDf=""
//			PopupMenu IntensityDataName  value="---"
//			PopupMenu QvecDataName  value="---"
//			PopupMenu ErrorDataName  value="---"
//		endif
//	endif
//	
//	if (cmpstr(ctrlName,"IntensityDataName")==0)
//		//here goes what needs to be done, when we select this popup...
//		if (cmpstr(popStr,"---")!=0)
//			IntDf=popStr
//			if (UseQRSData && strlen(QDf)==0 && strlen(EDf)==0)
//				QDf="q"+popStr[1,inf]
//				EDf="s"+popStr[1,inf]
//				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:FractalsModel:QWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"FractalsModel\",0,0)")
//				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:FractalsModel:ErrorWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Error\",\"FractalsModel\",0,0)")
//			endif
//		else
//			IntDf=""
//		endif
//	endif
//
//	if (cmpstr(ctrlName,"QvecDataName")==0)
//		//here goes what needs to be done, when we select this popup...	
//		if (cmpstr(popStr,"---")!=0)
//			QDf=popStr
//			if (UseQRSData && strlen(IntDf)==0 && strlen(EDf)==0)
//				IntDf="r"+popStr[1,inf]
//				EDf="s"+popStr[1,inf]
//				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:FractalsModel:IntensityWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Int\",\"FractalsModel\",0,0)")
//				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:FractalsModel:ErrorWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Error\",\"FractalsModel\",0,0)")
//			endif
//		else
//			QDf=""
//		endif
//	endif
//	
//	if (cmpstr(ctrlName,"ErrorDataName")==0)
//		//here goes what needs to be done, when we select this popup...
//		if (cmpstr(popStr,"---")!=0)
//			EDf=popStr
//			if (UseQRSData && strlen(IntDf)==0 && strlen(QDf)==0)
//				IntDf="r"+popStr[1,inf]
//				QDf="q"+popStr[1,inf]
//				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:FractalsModel:IntensityWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Int\",\"FractalsModel\",0,0)")
//				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:FractalsModel:QWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"FractalsModel\",0,0)")
//			endif
//		else
//			EDf=""
//		endif
//	endif
//	setDataFolder oldDF
//end
//
//


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:FractalsModel
	

	if(cmpstr(ctrlName,"GetHelp")==0)
		//Open www manual with the right page
		IN2G_OpenWebManual("Irena/Fractals.html")
	endif
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
//			MoveWindow /W=IR1V_LogLogPlotV 285,37,760,337
//			MoveWindow /W=IR1V_IQ4_Q_PlotV 285,360,760,600
			MoveWindow /W=IR1V_LogLogPlotV 0,0,IN2G_GetGraphWidthHeight("width"),0.6*IN2G_GetGraphWidthHeight("height")
			MoveWindow /W=IR1V_IQ4_Q_PlotV 0,300,IN2G_GetGraphWidthHeight("width"),300+0.4*IN2G_GetGraphWidthHeight("height")
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
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:FractalsModel
	
	Wave OriginalQvector=root:Packages:FractalsModel:OriginalQvector
	Wave OriginalIntensity=root:Packages:FractalsModel:OriginalIntensity
	Wave OriginalError=root:Packages:FractalsModel:OriginalError
	wave FractFitIntensity=root:Packages:FractalsModel:FractFitIntensity
	
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
	
	DFref oldDf= GetDataFolderDFR()

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

	DFref oldDf= GetDataFolderDFR()

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

	DFref oldDf= GetDataFolderDFR()

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
	
	DFref oldDf= GetDataFolderDFR()

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
	
	DFref oldDf= GetDataFolderDFR()

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
	
	DFref oldDf= GetDataFolderDFR()

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
	
	DFref oldDf= GetDataFolderDFR()

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

	DFref oldDf= GetDataFolderDFR()

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

	DFref oldDf= GetDataFolderDFR()

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
		//MoveWindow /W=IR1V_LogLogPlotV 285,37,760,337
		//MoveWindow /W=IR1V_IQ4_Q_PlotV 285,360,760,600
		MoveWindow /W=IR1V_LogLogPlotV 0,0,IN2G_GetGraphWidthHeight("width"),0.6*IN2G_GetGraphWidthHeight("height")
		MoveWindow /W=IR1V_IQ4_Q_PlotV 0,300,IN2G_GetGraphWidthHeight("width"),300+0.4*IN2G_GetGraphWidthHeight("height")
		AutoPositionWindow/M=0/R=IR1V_ControlPanel  IR1V_LogLogPlotV	
		AutoPositionWindow/M=1/R=IR1V_ControlPanel  IR1V_IQ4_Q_PlotV	
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
	if (cmpstr(ctrlName,"MassFr1_UFPDIIndex")==0 || cmpstr(ctrlName,"MassFr2_UFPDIIndex")==0)
		//here goes what happens when user changes the MassFr1_UFPDIIndex in distribution
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
	
	DFref oldDf= GetDataFolderDFR()

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
	
	KillWIndow/Z IR1V_LogLogPlotV
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

	KillWIndow/Z IR1V_IQ4_Q_PlotV
	Execute ("IR1V_IQ4_Q_PlotV()")
	setDataFolder oldDf
end

Proc  IR1V_LogLogPlotV()
	PauseUpdate    		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:FractalsModel:
	//Display /W=(282.75,37.25,759.75,208.25)/K=1  OriginalIntensity vs OriginalQvector as "LogLogPlot"
	Display /W=(0,0,IN2G_GetGraphWidthHeight("width"),0.6*IN2G_GetGraphWidthHeight("height"))/K=1  OriginalIntensity vs OriginalQvector as "LogLogPlot"
	DOWIndow/C IR1V_LogLogPlotV
	AutoPositionWindow/M=0/R=IR1V_ControlPanel  IR1V_LogLogPlotV		
	ModifyGraph mode(OriginalIntensity)=3
	ModifyGraph msize(OriginalIntensity)=1
	ModifyGraph log=1
	ModifyGraph mirror=1
	ShowInfo
	String LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity [cm\\S-1\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
	Label left LabelStr
	LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
	Label bottom LabelStr
//	Label left "Intensity [cm\\S-1\\M]"
//	Label bottom "Q [A\\S-1\\M]"
	TextBox/W=IR1V_LogLogPlotV/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR1V_LogLogPlotV/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	string LegendStr="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"\\s(OriginalIntensity) Experimental intensity"
	Legend/W=IR1V_LogLogPlotV/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 LegendStr
	SetDataFolder fldrSav
	ErrorBars/Y=1 OriginalIntensity Y,wave=(root:Packages:FractalsModel:OriginalError,root:Packages:FractalsModel:OriginalError)
EndMacro

Proc  IR1V_IQ4_Q_PlotV() 
	PauseUpdate    		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:FractalsModel:
	//Display /W=(283.5,228.5,761.25,383)/K=1  OriginalIntQ4 vs OriginalQvector as "IQ4_Q_Plot"
	Display /W=(0,0,IN2G_GetGraphWidthHeight("width"),0.4*IN2G_GetGraphWidthHeight("height"))/K=1  OriginalIntQ4 vs OriginalQvector as "IQ4_Q_Plot"
	DoWIndow/C IR1V_IQ4_Q_PlotV
	AutoPositionWindow/M=0/E/R=IR1V_ControlPanel  IR1V_IQ4_Q_PlotV		
	ModifyGraph mode(OriginalIntQ4)=3
	ModifyGraph msize(OriginalIntQ4)=1
	ModifyGraph log=1
	ModifyGraph mirror=1
	String LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity * Q\\S4\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"[cm\\S-1\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+" A\\S-4\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
	Label left LabelStr
	LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
	Label bottom LabelStr

//	Label left "Intensity * Q^4"
//	Label bottom "Q [A\\S-1\\M]"
	TextBox/W=IR1V_IQ4_Q_PlotV/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR1V_IQ4_Q_PlotV/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	SetDataFolder fldrSav
	ErrorBars/Y=1 OriginalIntQ4 Y,wave=(root:Packages:FractalsModel:OriginalErrQ4,root:Packages:FractalsModel:OriginalErrQ4)
EndMacro
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_CalculateSfcFractal(which)
	variable which

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:FractalsModel

	NVAR Surface=$("SurfFr"+num2str(which)+"_Surface")
	NVAR DS=$("SurfFr"+num2str(which)+"_DS")
	NVAR Ksi=$("SurfFr"+num2str(which)+"_Ksi")
	NVAR Contrast=$("SurfFr"+num2str(which)+"_Contrast")

	NVAR Qc=$("SurfFr"+num2str(which)+"_Qc")
	NVAR QcW=$("SurfFr"+num2str(which)+"_QcWidth")
	
	Wave Qvec=root:Packages:FractalsModel:FractFitQvector
	Wave FractFitIntensity=root:Packages:FractalsModel:FractFitIntensity
	Duplicate/O FractFitIntensity, $("Surf"+num2str(which)+"FractFitIntensity")
	Wave tempFractFitIntensity=$("Surf"+num2str(which)+"FractFitIntensity")
	
	//and now calculations
	tempFractFitIntensity=0
	tempFractFitIntensity = pi * Contrast* 1e20 * Ksi^4 *1e-32* Surface * exp(gammln(5-DS))	
	tempFractFitIntensity *= sin((3-DS)* atan(Qvec*Ksi))/((1+(Qvec*Ksi)^2)^((5-DS)/2) * Qvec*Ksi)
	if(Qc>0)
			//h(Q) = C(xc - x)f(Q) + C(x - xc)g(Q).
			//The transition from one behavior to another is determined by C.  
			//For an infinitely sharp transition, C would be a Heaviside step function.  
			//Our choice for C is a smoothed step function:
			//C(x) = 0.5 * (1 + erfc(x/W)).
			//C(x) = 0.5 * (1 + ERF( (Qc-Q) /SQRT(2*((Qw/2.3548)^2) ) )
			duplicate/Free tempFractFitIntensity, StepFunction1, StepFunction2, TempFractInt2
			StepFunction1 = 0.5 * (1 + erf((Qc - Qvec)/SQRT(2*((Qc*QcW/2.3548)^2) ) ))
			StepFunction2 = 0.5 * (1 + erf((Qvec-Qc)/SQRT(2*((Qc*QcW/2.3548)^2) ) ))
			//So, the total model, which transitions from f(Q) to Porod law behavior AQ^-4 is:
			//h(Q) = C(xc - x)f(Q) + C(x -xc)AQ^-4.
			//The value for A is not a free parameter. It is fixed by a continuity condition:
			//f(Qc) = g(Qc), or A = Qc^4 * f(Qc).
			//Intensity = ASF * 0.5 * (1 + ERF( (Qc-Q) /SQRT(2*((Qw/2.3548)^2) ) )    +
			//+ (  Pf * Q^-4 * 0.5 * (1 + ERF( (Q-Qc) /SQRT(2*((Qw/2.3548)^2) ) ) 
			variable PorodSurface=Qc^4 * tempFractFitIntensity[BinarySearchInterp(Qvec, Qc )]
			TempFractInt2 = tempFractFitIntensity * StepFunction1 + PorodSurface * Qvec^-4 * StepFunction2
			tempFractFitIntensity = TempFractInt2
	endif
	
//	tempFractFitIntensity*=1e-48									//this is conversion for Volume of particles from A to cm
	FractFitIntensity+=tempFractFitIntensity
	
	setDataFolder OldDf
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_CalculateMassFractal(which)
	variable which

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:FractalsModel

	NVAR Phi=$("root:Packages:FractalsModel:MassFr"+num2str(which)+"_Phi")
	NVAR Radius=$("root:Packages:FractalsModel:MassFr"+num2str(which)+"_Radius")
	NVAR Dv=$("root:Packages:FractalsModel:MassFr"+num2str(which)+"_Dv")
	NVAR Ksi=$("root:Packages:FractalsModel:MassFr"+num2str(which)+"_Ksi")
	NVAR BetaVar=$("root:Packages:FractalsModel:MassFr"+num2str(which)+"_Beta")
	NVAR Contrast=$("root:Packages:FractalsModel:MassFr"+num2str(which)+"_Contrast")
	NVAR Eta=$("root:Packages:FractalsModel:MassFr"+num2str(which)+"_Eta")
	NVAR UseUFFormFactor=$("root:Packages:FractalsModel:MassFr"+num2str(which)+"_UseUFFormFactor")
	NVAR PDI= $("root:Packages:FractalsModel:MassFr"+num2str(which)+"_UFPDIIndex") 
	

	Wave Qvec=root:Packages:FractalsModel:FractFitQvector
	Wave FractFitIntensity=root:Packages:FractalsModel:FractFitIntensity
	Duplicate/O FractFitIntensity, $("Mass"+num2str(which)+"FractFitIntensity")
	Wave tempFractFitIntensity=$("Mass"+num2str(which)+"FractFitIntensity")
	
	variable CHiS=IR1V_CaculateChiS(BetaVar)
	variable RC=Radius*sqrt(2)/ChiS * sqrt(1+((2+BetaVar^2)/3)*ChiS^2)
	variable Bracket
	//and now calculations
	tempFractFitIntensity=0
	Bracket = ( Eta * RC^3 / (BetaVar * Radius^3)) * ((Ksi/RC)^Dv )
	if(UseUFFormFactor)								//use Unified fit Form factor for sphere...
		tempFractFitIntensity = Phi * Contrast* 1e-4 * IR1V_SpheroidVolume(Radius,1) * (Bracket * sin((Dv-1)*atan(Qvec*Ksi)) / ((Dv-1)*Qvec*Ksi*(1+(Qvec*Ksi)^2)^((Dv-1)/2)) + (1-Eta)^2 )* IR1V_UnifiedSphereFFSquared(Radius,Qvec, PDI)
	else
		if(BetaVar>1.01 || BetaVar<0.99)
			tempFractFitIntensity = Phi * Contrast* 1e-4 * IR1V_SpheroidVolume(Radius,BetaVar) * (Bracket * sin((Dv-1)*atan(Qvec*Ksi)) / ((Dv-1)*Qvec*Ksi*(1+(Qvec*Ksi)^2)^((Dv-1)/2)) + (1-Eta)^2 )* IR1V_CalculateFSquared(which,Qvec)
		else
			tempFractFitIntensity = Phi * Contrast* 1e-4 * IR1V_SpheroidVolume(Radius,BetaVar) * (Bracket * sin((Dv-1)*atan(Qvec*Ksi)) / ((Dv-1)*Qvec*Ksi*(1+(Qvec*Ksi)^2)^((Dv-1)/2)) + (1-Eta)^2 )* IR1V_SphereFFSquared(which,Qvec)
		endif
	endif
	//	tempFractFitIntensity*=1e-48									//this is conversion for Volume of particles from A to cm
	FractFitIntensity+=tempFractFitIntensity
	
	setDataFolder OldDf
end

//*****************************************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_SphereFFSquared(which, Qvalue)
	variable Qvalue, which										//does the math for Sphere Form factor function

	NVAR Radius=$("MassFr"+num2str(which)+"_Radius")
	variable QR=Qvalue*radius

	return  ((3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR))))^2
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_UnifiedSphereFFSquared(Radius, Qvalue, PDI)
	variable Qvalue, Radius, PDI										//does the math for Unified fit Sphere Form factor function

	//NVAR Radius=$("MassFr"+num2str(which)+"_Radius")
   Variable G1=1, P1=4, Rg1=sqrt(3/5)*radius
   variable B1=PDI*1.62*G1/Rg1^4
   variable QstarVector=qvalue/(erf(qvalue*Rg1/sqrt(6)))^3
   variable result =G1*exp(-qvalue^2*Rg1^2/3)+(B1/QstarVector^P1)
   return (result)			//normalized to one
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_SpheroidVolume(Radius,AspectRatio)							//returns the spheroid volume...
	variable Radius, AspectRatio
	return ((4/3)*pi*radius*radius*radius*AspectRatio)				//what is the volume of spheroid?
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_CalculateFSquared(which,Qval)
	variable which,Qval

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:FractalsModel

	NVAR Phi=$("MassFr"+num2str(which)+"_Phi")
	NVAR Radius=$("MassFr"+num2str(which)+"_Radius")
	NVAR Dv=$("MassFr"+num2str(which)+"_Dv")
	NVAR Ksi=$("MassFr"+num2str(which)+"_Ksi")
	NVAR BetaVar=$("MassFr"+num2str(which)+"_Beta")
	NVAR Contrast=$("MassFr"+num2str(which)+"_Contrast")
	NVAR Eta=$("MassFr"+num2str(which)+"_Eta")
	NVAR IntgNumPnts=$("MassFr"+num2str(which)+"_IntgNumPnts")
	
	 variable result 
	 variable TempBessArg
	//now we need the integral
	Make/O/D/N=(IntgNumPnts) FractF2IntgWave
	SetScale/I x 0,1,"", FractF2IntgWave
	//FractF2IntgWave = BessJ(3/2,Qval*Radius*sqrt(1+(BetaVar^2 - 1)*x^2),1)/(Qval*Radius*sqrt(1+(BetaVar^2 - 1)*x^2))^(3/2)
	FractF2IntgWave = Besselj(3/2,Qval*Radius*sqrt(1+(BetaVar^2 - 1)*x^2))/(Qval*Radius*sqrt(1+(BetaVar^2 - 1)*x^2))^(3/2)
	//fix end points, if they are wrong:
	if (numtype(FractF2IntgWave[0])!=0)
		FractF2IntgWave[0]=FractF2IntgWave[1]
	endif
	if (numtype(FractF2IntgWave[IntgNumPnts-1])!=0)
		FractF2IntgWave[IntgNumPnts-1]=FractF2IntgWave[IntgNumPnts-2]
	endif
	
	result =  9*pi/2 * (area(FractF2IntgWave, 0, 1 ))^2
	killwaves FractF2IntgWave
	setDataFolder oldDF
	return result 
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_CaculateChiS(BetaVar)
	variable BetaVar
	
	variable result
	
	if (BetaVar<1)
		result = (1/(2*BetaVar)) * (1+(BetaVar^2/sqrt(1-BetaVar^2))*ln((1+sqrt(1-BetaVar^2))/BetaVar))
	elseif(BetaVar>1)
		result = (1/(2*BetaVar)) * (1+(BetaVar^2/sqrt(BetaVar^2 -1))*asin(sqrt(BetaVar^2 - 1)/BetaVar))
	else
		result = 1
	endif
	return result
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_FractalCalculateIntensity()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:FractalsModel

	Wave/Z OriginalIntensity
	Wave/Z OriginalQvector
	if(!WaveExists(OriginalIntensity) || !WaveExists(OriginalQvector))
		abort
	endif
	Duplicate/O OriginalIntensity, FractFitIntensity, FractIQ4
	Redimension/D FractFitIntensity, FractIQ4
	Duplicate/O OriginalQvector, FractFitQvector, FractQ4
	Redimension/D FractFitQvector, FractQ4
	FractQ4=FractFitQvector^4
	
	FractFitIntensity=0
	
	NVAR UseMassFract1
	NVAR UseMassFract2
	NVAR UseSurfFract1
	NVAR UseSurfFract2

	if(UseMassFract1)	
		IR1V_CalculateMassFractal(1)
	endif
	if(UseMassFract2)	
		IR1V_CalculateMassFractal(2)
	endif
	if(UseSurfFract1)	
		IR1V_CalculateSfcFractal(1)
	endif
	if(UseSurfFract2)	
		IR1V_CalculateSfcFractal(2)
	endif
	
	NVAR SASBackground=root:Packages:FractalsModel:SASBackground
	FractFitIntensity+=SASBackground	
	
	FractIQ4=FractFitIntensity*FractQ4
	RemoveFromGraph /Z/W=IR1V_LogLogPlotV FractFitIntensity
	AppendToGraph /W=IR1V_LogLogPlotV/C=(0,0,0) FractFitIntensity vs FractFitQvector
	RemoveFromGraph /Z/W=IR1V_IQ4_Q_PlotV FractIQ4
	AppendToGraph /W=IR1V_IQ4_Q_PlotV/C=(0,0,0) FractIQ4 vs FractFitQvector
	setDataFolder oldDF
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function	IR1V_CalculateNormalizedError(CalledWhere)
		string CalledWhere	// "fit" or "graph"

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel
		if (cmpstr(CalledWhere,"graph")==0)
			Wave ExpInt=root:Packages:FractalsModel:OriginalIntensity
			Wave ExpError=root:Packages:FractalsModel:OriginalError
			Wave FitInt=root:Packages:FractalsModel:FractFitIntensity
			Wave OrgQvec=root:Packages:FractalsModel:OriginalQvector
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

Function IR1V_AppendModelToMeasuredData()
	//here we need to append waves with calculated intensities to the measured data

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:FractalsModel
	
	Wave Intensity=root:Packages:FractalsModel:FractFitIntensity
	Wave QVec=root:Packages:FractalsModel:FractFitQvector
	Wave IQ4=root:Packages:FractalsModel:FractIQ4
	Wave/Z NormalizedError=root:Packages:FractalsModel:NormalizedError
	Wave/Z NormErrorQvec=root:Packages:FractalsModel:NormErrorQvec
	
	DoWindow/F IR1V_LogLogPlotV
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
	
	DoWIndow IR1V_LogLogPlotV
	if (!V_Flag)
		abort
	endif
	DoWIndow IR1V_IQ4_Q_PlotV
	if (!V_Flag)
		abort
	endif
	
	RemoveFromGraph /Z/W=IR1V_LogLogPlotV FractFitIntensity 
	RemoveFromGraph /Z/W=IR1V_LogLogPlotV NormalizedError 
	RemoveFromGraph /Z/W=IR1V_IQ4_Q_PlotV UnifiedIQ4 

	AppendToGraph/W=IR1V_LogLogPlotV Intensity vs Qvec
	cursor/P/W=IR1V_LogLogPlotV A, OriginalIntensity, CsrAPos	
	cursor/P/W=IR1V_LogLogPlotV B, OriginalIntensity, CsrBPos	
	ModifyGraph/W=IR1V_LogLogPlotV rgb(FractFitIntensity)=(0,0,0)
	ModifyGraph/W=IR1V_LogLogPlotV mode(OriginalIntensity)=3
	ModifyGraph/W=IR1V_LogLogPlotV msize(OriginalIntensity)=1
	TextBox/W=IR1V_LogLogPlotV/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	ShowInfo/W=IR1V_LogLogPlotV
	if (WaveExists(NormalizedError))
		AppendToGraph/R/W=IR1V_LogLogPlotV NormalizedError vs NormErrorQvec
		ModifyGraph/W=IR1V_LogLogPlotV  mode(NormalizedError)=3,marker(NormalizedError)=8
		ModifyGraph/W=IR1V_LogLogPlotV zero(right)=4
		ModifyGraph/W=IR1V_LogLogPlotV msize(NormalizedError)=1,rgb(NormalizedError)=(0,0,0)
		SetAxis/W=IR1V_LogLogPlotV /A/E=2 right
		ModifyGraph/W=IR1V_LogLogPlotV log(right)=0
		Label/W=IR1V_LogLogPlotV right "Standardized residual"
	else
		ModifyGraph/W=IR1V_LogLogPlotV mirror(left)=1
	endif
	ModifyGraph/W=IR1V_LogLogPlotV log(left)=1
	ModifyGraph/W=IR1V_LogLogPlotV log(bottom)=1
	ModifyGraph/W=IR1V_LogLogPlotV mirror(bottom)=1
	Label/W=IR1V_LogLogPlotV left "Intensity [cm\\S-1\\M]"
	Label/W=IR1V_LogLogPlotV bottom "Q [A\\S-1\\M]"
	ErrorBars/Y=1/W=IR1V_LogLogPlotV OriginalIntensity Y,wave=(root:Packages:FractalsModel:OriginalError,root:Packages:FractalsModel:OriginalError)
	Legend/W=IR1V_LogLogPlotV/N=text0/K
	Legend/W=IR1V_LogLogPlotV/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 "\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"\\s(OriginalIntensity) Experimental intensity"
	AppendText/W=IR1V_LogLogPlotV "\\s(FractFitIntensity) Fractal model calculated Intensity"
	if (WaveExists(NormalizedError))
		AppendText/W=IR1V_LogLogPlotV "\\s(NormalizedError) Standardized residual"
	endif
	ModifyGraph/W=IR1V_LogLogPlotV rgb(OriginalIntensity)=(0,0,0),lstyle(FractFitIntensity)=0
	ModifyGraph/W=IR1V_LogLogPlotV rgb(FractFitIntensity)=(65280,0,0)

	AppendToGraph/W=IR1V_IQ4_Q_PlotV IQ4 vs Qvec
	ModifyGraph/W=IR1V_IQ4_Q_PlotV rgb(FractIQ4)=(65280,0,0)
	ModifyGraph/W=IR1V_IQ4_Q_PlotV mode=3
	ModifyGraph/W=IR1V_IQ4_Q_PlotV msize=1
	ModifyGraph/W=IR1V_IQ4_Q_PlotV log=1
	ModifyGraph/W=IR1V_IQ4_Q_PlotV mirror=1
	ModifyGraph/W=IR1V_IQ4_Q_PlotV mode(FractIQ4)=0
	TextBox/W=IR1V_IQ4_Q_PlotV/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	Label/W=IR1V_IQ4_Q_PlotV left "Intensity * Q^4"
	Label/W=IR1V_IQ4_Q_PlotV bottom "Q [A\\S-1\\M]"
	ErrorBars/Y=1/W=IR1V_IQ4_Q_PlotV OriginalIntQ4 Y,wave=(root:Packages:FractalsModel:OriginalErrQ4,root:Packages:FractalsModel:OriginalErrQ4)
	Legend/W=IR1V_IQ4_Q_PlotV/N=text0/K
	Legend/W=IR1V_IQ4_Q_PlotV/N=text0/J/F=0/A=MC/X=-29.74/Y=37.76 "\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"\\s(OriginalIntQ4) Experimental intensity * Q^4"
	AppendText/W=IR1V_IQ4_Q_PlotV "\\s(FractIQ4) Fractal model Calculated intensity * Q^4"
	ModifyGraph/W=IR1V_IQ4_Q_PlotV rgb(OriginalIntq4)=(0,0,0)
	setDataFolder oldDF

end




//****************************************************************************************************************
//****************************************************************************************************************
//	original IR1_FractalsInit.ipf
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_InitializeFractals()

	DFref oldDf= GetDataFolderDFR()

	
	NewDataFolder/O/S root:Packages
	NewdataFolder/O/S root:Packages:FractalsModel
	
	string ListOfVariables
	string ListOfStrings
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="UseIndra2Data;UseQRSdata;NumberOfLevels;SubtractBackground;"
	ListOfVariables+="UseMassFract1;UseMassFract2;UseSurfFract1;UseSurfFract2;DisplayLocalFits;"
	ListOfVariables+="MassFr1_Phi;MassFr1_Radius;MassFr1_Dv;MassFr1_Ksi;MassFr1_Beta;MassFr1_Contrast;MassFr1_Eta;MassFr1_IntgNumPnts;"
	ListOfVariables+="MassFr1_FitPhi;MassFr1_FitRadius;MassFr1_FitDv;MassFr1_FitKsi;"
	ListOfVariables+="MassFr1_PhiError;MassFr1_RadiusError;MassFr1_DvError;MassFr1_KsiError;"
	ListOfVariables+="MassFr1_PhiMin;MassFr1_PhiMax;MassFr1_PhiStep;MassFr1_RadiusMin;MassFr1_RadiusMax;MassFr1_RadiusStep;"
	ListOfVariables+="MassFr1_DvMin;MassFr1_DvMax;MassFr1_DvStep;MassFr1_KsiMin;MassFr1_KsiMax;MassFr1_KsiStep;MassFr1_FitMin;MassFr1_FitMax;"
	
	ListOfVariables+="MassFr2_Phi;MassFr2_Radius;MassFr2_Dv;MassFr2_Ksi;MassFr2_Beta;MassFr2_Contrast;MassFr2_Eta;MassFr2_IntgNumPnts;"
	ListOfVariables+="MassFr2_FitPhi;MassFr2_FitRadius;MassFr2_FitDv;MassFr2_FitKsi;"
	ListOfVariables+="MassFr2_PhiError;MassFr2_RadiusError;MassFr2_DvError;MassFr2_KsiError;MassFr2_FitError;"
	ListOfVariables+="MassFr2_PhiMin;MassFr2_PhiMax;MassFr2_PhiStep;MassFr2_RadiusMin;MassFr2_RadiusMax;MassFr2_RadiusStep;"
	ListOfVariables+="MassFr2_DvMin;MassFr2_DvMax;MassFr2_DvStep;MassFr2_KsiMin;MassFr2_KsiMax;MassFr2_KsiStep;MassFr2_FitMin;MassFr2_FitMax;"

	ListOfVariables+="MassFr1_UseUFFormFactor;MassFr2_UseUFFormFactor;MassFr1_UFPDIIndex;MassFr2_UFPDIIndex;"
	
	ListOfVariables+="SurfFr1_Surface;SurfFr1_Ksi;SurfFr1_DS;SurfFr1_Contrast;"
	ListOfVariables+="SurfFr1_FitSurface;SurfFr1_FitKsi;SurfFr1_FitDS;"
	ListOfVariables+="SurfFr1_SurfaceError;SurfFr1_KsiError;SurfFr1_DSError;"
	ListOfVariables+="SurfFr1_SurfaceMin;SurfFr1_SurfaceMax;SurfFr1_SurfaceStep;SurfFr1_KsiMin;SurfFr1_KsiMax;SurfFr1_KsiStep;"
	ListOfVariables+="SurfFr1_DSMin;SurfFr1_DSMax;SurfFr1_DSStep;"
	ListOfVariables+="SurfFr1_Qc;SurfFr1_QcWidth;SurfFr1_QcStep;"
		
	ListOfVariables+="SurfFr2_Surface;SurfFr2_Ksi;SurfFr2_DS;SurfFr2_Contrast;"
	ListOfVariables+="SurfFr2_FitSurface;SurfFr2_FitKsi;SurfFr2_FitDS;"
	ListOfVariables+="SurfFr2_SurfaceError;SurfFr2_KsiError;SurfFr2_DSError;"
	ListOfVariables+="SurfFr2_SurfaceMin;SurfFr2_SurfaceMax;SurfFr2_SurfaceStep;SurfFr2_KsiMin;SurfFr2_KsiMax;SurfFr2_KsiStep;"
	ListOfVariables+="SurfFr2_DSMin;SurfFr2_DSMax;SurfFr2_DSStep;"
	ListOfVariables+="SurfFr2_Qc;SurfFr2_QcWidth;SurfFr2_QcStep;"
		
	ListOfVariables+="SASBackground;SASBackgroundError;SASBackgroundStep;FitSASBackground;UpdateAutomatically;DisplayLocalFits;ActiveTab;"

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	//cleanup after possible previous fitting stages...
	Wave/Z CoefNames=root:Packages:FractalsModel:CoefNames
	Wave/Z CoefficientInput=root:Packages:FractalsModel:CoefficientInput
	KillWaves/Z CoefNames, CoefficientInput
	
	IR1V_SetInitialValues()		
	setDataFolder oldDF

end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_SetInitialValues()
	//and here set default values...

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:FractalsModel
	
	string ListOfVariables
	variable i
	//here we set what needs to be 0
	ListOfVariables="MassFr1_FitPhi;MassFr1_FitRadius;MassFr1_FitDv;MassFr1_FitKsi;"
	ListOfVariables+="MassFr2_FitPhi;MassFr2_FitRadius;MassFr2_FitDv;MassFr2_FitKsi;"
	ListOfVariables+="SurfFr1_FitSurface;SurfFr1_FitKsi;SurfFr1_FitDS;"
	ListOfVariables+="SurfFr2_FitSurface;SurfFr2_FitKsi;SurfFr2_FitDS;"
	ListOfVariables+="FitSASBackground;UpdateAutomatically;DisplayLocalFits;ActiveTab;DisplayLocalFits;UseIndra2Data;UseRQSdata;SubtractBackground;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		testVar=0
	endfor
	
	//and here values to 0.000001
	ListOfVariables="MassFr1_PhiMin;"
	ListOfVariables+="MassFr2_PhiMin;"
	ListOfVariables+="SurfFr1_SurfaceMin;"
	ListOfVariables+="SurfFr2_SurfaceMin;"
	ListOfVariables+="SASBackground;SASBackgroundStep;"

	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=0.01
		endif
	endfor
	
	
	//and here to 1
	ListOfVariables="SurfFr1_SurfaceStep;SurfFr1_KsiStep;SurfFr2_SurfaceStep;SurfFr2_KsiStep;MassFr1_DvMin;MassFr2_DvMin;"
	ListOfVariables+="MassFr1_PhiStep;MassFr1_RadiusStep;MassFr2_PhiStep;MassFr2_RadiusStep;MassFr1_DvStep;MassFr1_KsiStep;"
	ListOfVariables+="SurfFr1_DSStep;SurfFr2_DSStep;MassFr2_KsiStep;MassFr2_DvStep;MassFr1_PhiMax;MassFr2_PhiMax;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=1
		endif
	endfor
//

	ListOfVariables="MassFr1_RadiusMin;MassFr2_RadiusMin;MassFr1_KsiMin;MassFr2_KsiMin;SurfFr1_KsiMin;SurfFr2_KsiMin;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=10
		endif
	endfor
	
	ListOfVariables="SurfFr1_DSMin;SurfFr2_DSMin;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=2
		endif
	endfor
	ListOfVariables="MassFr1_DvMax;MassFr2_DvMax;SurfFr2_DSMax;SurfFr1_DSMax;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=3
		endif
	endfor

	ListOfVariables="MassFr1_RadiusMax;MassFr1_KsiMax;"
	ListOfVariables+="MassFr2_RadiusMax;MassFr2_KsiMax;"
	ListOfVariables+="SurfFr1_SurfaceMax;SurfFr1_KsiMax;"
	ListOfVariables+="SurfFr2_SurfaceMax;SurfFr2_KsiMax;"

	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=10000
		endif
	endfor

	ListOfVariables="SurfFr1_Surface;"
	ListOfVariables+="SurfFr2_Surface;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=1000
		endif
	endfor
	
	ListOfVariables="MassFr1_Radius;MassFr1_Ksi;"
	ListOfVariables+="MassFr2_Radius;MassFr2_Ksi;"
	ListOfVariables+="SurfFr1_Ksi;"
	ListOfVariables+="SurfFr2_Ksi;"	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=500
		endif
	endfor

	ListOfVariables="MassFr1_Phi;"
	ListOfVariables+="MassFr2_Phi;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=0.1000
		endif
	endfor

	ListOfVariables="MassFr1_Contrast;MassFr2_Contrast;"
	ListOfVariables+="SurfFr1_Contrast;SurfFr2_Contrast;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=100
		endif
	endfor

	ListOfVariables="MassFr1_Beta;MassFr2_Beta;"	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=2
		endif
	endfor

	ListOfVariables="MassFr1_Eta;MassFr2_Eta;"	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=0.5
		endif
	endfor

	ListOfVariables="MassFr1_Dv;MassFr2_Dv;SurfFr1_DS;SurfFr2_DS;"	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=2
		endif
	endfor
	
	ListOfVariables="MassFr1_IntgNumPnts;MassFr2_IntgNumPnts;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=500
		endif
	endfor

	ListOfVariables="MassFr1_UFPDIIndex;MassFr2_UFPDIIndex;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=3
		endif
	endfor
	
	ListOfVariables="SurfFr1_QcWidth;SurfFr2_QcWidth;"
	//this sets width of Qc transition to 10%, may need to be oiptimized later.
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=0.1
		endif
	endfor
	
	IR1V_SetErrorsToZero()
	setDataFolder oldDF
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_SetErrorsToZero()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:FractalsModel

	string ListOfVariables="SASBackgroundError;"
	ListOfVariables+="MassFr1_PhiError;MassFr1_RadiusError;MassFr1_DvError;MassFr1_KsiError;"
	ListOfVariables+="MassFr2_PhiError;MassFr2_RadiusError;MassFr2_DvError;MassFr2_KsiError;"
	ListOfVariables+="SurfFr1_SurfaceError;SurfFr1_KsiError;SurfFr1_DSError;"
	ListOfVariables+="SurfFr2_SurfaceError;SurfFr2_KsiError;SurfFr2_DSError;"
	variable i
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		testVar=0
	endfor

	setDataFolder oldDF

end






//****************************************************************************************************************
//****************************************************************************************************************
//	original IR1_FractalsFiting.ipf
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************



///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR1V_ConstructTheFittingCommand()
	//here we need to construct the fitting command and prepare the data for fit...

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:FractalsModel
	
	NVAR UseMassFract1=root:Packages:FractalsModel:UseMassFract1
	NVAR UseMassFract2=root:Packages:FractalsModel:UseMassFract2
	NVAR UseSurfFract1=root:Packages:FractalsModel:UseSurfFract1
	NVAR UseSurfFract2=root:Packages:FractalsModel:UseSurfFract2
	NVAR SASBackground=root:Packages:FractalsModel:SASBackground
	NVAR FitSASBackground=root:Packages:FractalsModel:FitSASBackground

//Mass fractal1 part	
	NVAR  MassFr1_Phi=root:Packages:FractalsModel:MassFr1_Phi
	NVAR  MassFr1_FitPhi=root:Packages:FractalsModel:MassFr1_FitPhi
	NVAR  MassFr1_PhiError=root:Packages:FractalsModel:MassFr1_PhiError
	NVAR  MassFr1_PhiMin=root:Packages:FractalsModel:MassFr1_PhiMin
	NVAR  MassFr1_PhiMax=root:Packages:FractalsModel:MassFr1_PhiMax

	NVAR  MassFr1_Radius=root:Packages:FractalsModel:MassFr1_Radius
	NVAR  MassFr1_FitRadius=root:Packages:FractalsModel:MassFr1_FitRadius
	NVAR  MassFr1_RadiusError=root:Packages:FractalsModel:MassFr1_RadiusError
	NVAR  MassFr1_RadiusMin=root:Packages:FractalsModel:MassFr1_RadiusMin
	NVAR  MassFr1_RadiusMax=root:Packages:FractalsModel:MassFr1_RadiusMax

	NVAR  MassFr1_Dv=root:Packages:FractalsModel:MassFr1_Dv
	NVAR  MassFr1_FitDv=root:Packages:FractalsModel:MassFr1_FitDv
	NVAR  MassFr1_DvError= root:Packages:FractalsModel:MassFr1_DvError
	NVAR  MassFr1_DvMin=root:Packages:FractalsModel:MassFr1_DvMin
	NVAR  MassFr1_DvMax=root:Packages:FractalsModel:MassFr1_DvMax

	NVAR  MassFr1_Ksi=root:Packages:FractalsModel:MassFr1_Ksi
	NVAR  MassFr1_FitKsi=root:Packages:FractalsModel:MassFr1_FitKsi
	NVAR  MassFr1_KsiError=root:Packages:FractalsModel:MassFr1_KsiError
	NVAR  MassFr1_KsiMin= root:Packages:FractalsModel:MassFr1_KsiMin
	NVAR  MassFr1_KsiMax=root:Packages:FractalsModel:MassFr1_KsiMax

	NVAR  MassFr1_Beta=root:Packages:FractalsModel:MassFr1_Beta
	NVAR  MassFr1_Contrast=root:Packages:FractalsModel:MassFr1_Contrast
	NVAR  MassFr1_Eta=root:Packages:FractalsModel:MassFr1_Eta
	
//Mass fractal 2 part	
	NVAR  MassFr2_Phi=root:Packages:FractalsModel:MassFr2_Phi
	NVAR  MassFr2_FitPhi=root:Packages:FractalsModel:MassFr2_FitPhi
	NVAR  MassFr2_PhiError=root:Packages:FractalsModel:MassFr2_PhiError
	NVAR  MassFr2_PhiMin=root:Packages:FractalsModel:MassFr2_PhiMin
	NVAR  MassFr2_PhiMax=root:Packages:FractalsModel:MassFr2_PhiMax

	NVAR  MassFr2_Radius=root:Packages:FractalsModel:MassFr2_Radius
	NVAR  MassFr2_FitRadius=root:Packages:FractalsModel:MassFr2_FitRadius
	NVAR  MassFr2_RadiusError=root:Packages:FractalsModel:MassFr2_RadiusError
	NVAR  MassFr2_RadiusMin=root:Packages:FractalsModel:MassFr2_RadiusMin
	NVAR  MassFr2_RadiusMax=root:Packages:FractalsModel:MassFr2_RadiusMax

	NVAR  MassFr2_Dv=root:Packages:FractalsModel:MassFr2_Dv
	NVAR  MassFr2_FitDv=root:Packages:FractalsModel:MassFr2_FitDv
	NVAR  MassFr2_DvError= root:Packages:FractalsModel:MassFr2_DvError
	NVAR  MassFr2_DvMin=root:Packages:FractalsModel:MassFr2_DvMin
	NVAR  MassFr2_DvMax=root:Packages:FractalsModel:MassFr2_DvMax

	NVAR  MassFr2_Ksi=root:Packages:FractalsModel:MassFr2_Ksi
	NVAR  MassFr2_FitKsi=root:Packages:FractalsModel:MassFr2_FitKsi
	NVAR  MassFr2_KsiError=root:Packages:FractalsModel:MassFr2_KsiError
	NVAR  MassFr2_KsiMin= root:Packages:FractalsModel:MassFr2_KsiMin
	NVAR  MassFr2_KsiMax=root:Packages:FractalsModel:MassFr2_KsiMax

	NVAR  MassFr2_Beta=root:Packages:FractalsModel:MassFr2_Beta
	NVAR  MassFr2_Contrast=root:Packages:FractalsModel:MassFr2_Contrast
	NVAR  MassFr2_Eta=root:Packages:FractalsModel:MassFr2_Eta

//Surface fractal 1
	NVAR  SurfFr1_Surface=root:Packages:FractalsModel:SurfFr1_Surface
	NVAR SurfFr1_FitSurface =root:Packages:FractalsModel:SurfFr1_FitSurface
	NVAR SurfFr1_SurfaceMin =root:Packages:FractalsModel:SurfFr1_SurfaceMin
	NVAR  SurfFr1_SurfaceMax=root:Packages:FractalsModel:SurfFr1_SurfaceMax
	NVAR  SurfFr1_SurfaceError=root:Packages:FractalsModel:SurfFr1_SurfaceError

	NVAR  SurfFr1_Ksi=root:Packages:FractalsModel:SurfFr1_Ksi
	NVAR  SurfFr1_FitKsi=root:Packages:FractalsModel:SurfFr1_FitKsi
	NVAR  SurfFr1_KsiMin=root:Packages:FractalsModel:SurfFr1_KsiMin
	NVAR  SurfFr1_KsiMax=root:Packages:FractalsModel:SurfFr1_KsiMax
	NVAR  SurfFr1_KsiError=root:Packages:FractalsModel:SurfFr1_KsiError

	NVAR  SurfFr1_DS=root:Packages:FractalsModel:SurfFr1_DS
	NVAR  SurfFr1_FitDS=root:Packages:FractalsModel:SurfFr1_FitDS
	NVAR  SurfFr1_DSMin=root:Packages:FractalsModel:SurfFr1_DSMin
	NVAR  SurfFr1_DSMax=root:Packages:FractalsModel:SurfFr1_DSMax
	NVAR  SurfFr1_DSError=root:Packages:FractalsModel:SurfFr1_DSError

	NVAR  SurfFr1_Contrast=root:Packages:FractalsModel:SurfFr1_Contrast

	NVAR SurfFr1_SurfaceStep =root:Packages:FractalsModel:SurfFr1_SurfaceStep

	NVAR  SurfFr2_Surface=root:Packages:FractalsModel:SurfFr2_Surface
	NVAR SurfFr2_FitSurface =root:Packages:FractalsModel:SurfFr2_FitSurface
	NVAR SurfFr2_SurfaceMin =root:Packages:FractalsModel:SurfFr2_SurfaceMin
	NVAR  SurfFr2_SurfaceMax=root:Packages:FractalsModel:SurfFr2_SurfaceMax
	NVAR  SurfFr2_SurfaceError=root:Packages:FractalsModel:SurfFr2_SurfaceError

	NVAR  SurfFr2_Ksi=root:Packages:FractalsModel:SurfFr2_Ksi
	NVAR  SurfFr2_FitKsi=root:Packages:FractalsModel:SurfFr2_FitKsi
	NVAR  SurfFr2_KsiMin=root:Packages:FractalsModel:SurfFr2_KsiMin
	NVAR  SurfFr2_KsiMax=root:Packages:FractalsModel:SurfFr2_KsiMax
	NVAR  SurfFr2_KsiError=root:Packages:FractalsModel:SurfFr2_KsiError

	NVAR  SurfFr2_DS=root:Packages:FractalsModel:SurfFr2_DS
	NVAR  SurfFr2_FitDS=root:Packages:FractalsModel:SurfFr2_FitDS
	NVAR  SurfFr2_DSMin=root:Packages:FractalsModel:SurfFr2_DSMin
	NVAR  SurfFr2_DSMax=root:Packages:FractalsModel:SurfFr2_DSMax
	NVAR  SurfFr2_DSError=root:Packages:FractalsModel:SurfFr2_DSError

	NVAR  SurfFr2_Contrast=root:Packages:FractalsModel:SurfFr2_Contrast

	NVAR SurfFr2_SurfaceStep =root:Packages:FractalsModel:SurfFr2_SurfaceStep
///now we can make various parts of the fitting routines...
//
	//First check the reasonability of all parameters

//	IR1A_CorrectLimitsAndValues()

	//
	Make/D/N=0/O W_coef
	Make/T/N=0/O CoefNames
	Make/D/O/T/N=0 T_Constraints
	T_Constraints=""
	CoefNames=""
	
	if (FitSASBackground)		//are we fitting background?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames//, T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SASBackground
		CoefNames[numpnts(CoefNames)-1]="SASBackground"
	//	T_Constraints[0] = {"K"+num2str(numpnts(W_coef)-1)+" > 0"}
	endif
//Mass fractal 1 part	
	if (MassFr1_FitPhi && UseMassFract1)		
		if (MassFr1_PhiMin > MassFr1_Phi || MassFr1_PhiMax < MassFr1_Phi)
			abort "Maas fractal 1 Phi limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=MassFr1_Phi
		CoefNames[numpnts(CoefNames)-1]="MassFr1_Phi"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(MassFr1_PhiMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(MassFr1_PhiMax)}		
	endif
	if (MassFr1_FitRadius && UseMassFract1)	
		if (MassFr1_RadiusMin > MassFr1_Radius || MassFr1_RadiusMax < MassFr1_Radius)
			abort "Mass fractal 1 Radius limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=MassFr1_Radius
		CoefNames[numpnts(CoefNames)-1]="MassFr1_Radius"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(MassFr1_RadiusMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(MassFr1_RadiusMax)}		
	endif
	if (MassFr1_FitDv && UseMassFract1)		
		if (MassFr1_DvMin > MassFr1_Dv || MassFr1_DvMax < MassFr1_Dv)
			abort "Level 1 P limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=MassFr1_Dv
		CoefNames[numpnts(CoefNames)-1]="MassFr1_Dv"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(MassFr1_DvMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(MassFr1_DvMax)}		
	endif
	if (MassFr1_FitKsi && UseMassFract1)	
		if (MassFr1_KsiMin > MassFr1_Ksi || MassFr1_KsiMax < MassFr1_Ksi)
			abort "Mass fractal 1 Ksi limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=MassFr1_Ksi
		CoefNames[numpnts(CoefNames)-1]="MassFr1_Ksi"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(MassFr1_KsiMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(MassFr1_KsiMax)}		
	endif

	
//Mass fractal 2 part	

	if (MassFr2_FitPhi && UseMassFract2)		
		if (MassFr2_PhiMin > MassFr2_Phi || MassFr2_PhiMax < MassFr2_Phi)
			abort "Mass fractal 1 Phi limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=MassFr2_Phi
		CoefNames[numpnts(CoefNames)-1]="MassFr2_Phi"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(MassFr2_PhiMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(MassFr2_PhiMax)}		
	endif
	if (MassFr2_FitRadius && UseMassFract2)	
		if (MassFr2_RadiusMin > MassFr2_Radius || MassFr2_RadiusMax < MassFr2_Radius)
			abort "Mass fractal 1 Radius limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=MassFr2_Radius
		CoefNames[numpnts(CoefNames)-1]="MassFr2_Radius"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(MassFr2_RadiusMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(MassFr2_RadiusMax)}		
	endif
	if (MassFr2_FitDv && UseMassFract2)		
		if (MassFr2_DvMin > MassFr2_Dv || MassFr2_DvMax < MassFr2_Dv)
			abort "Level 1 P limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=MassFr2_Dv
		CoefNames[numpnts(CoefNames)-1]="MassFr2_Dv"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(MassFr2_DvMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(MassFr2_DvMax)}		
	endif
	if (MassFr2_FitKsi && UseMassFract2)	
		if (MassFr2_KsiMin > MassFr2_Ksi || MassFr2_KsiMax < MassFr2_Ksi)
			abort "Mass fractal 1 Ksi limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=MassFr2_Ksi
		CoefNames[numpnts(CoefNames)-1]="MassFr2_Ksi"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(MassFr2_KsiMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(MassFr2_KsiMax)}		
	endif




//Surface fractal 1 part	
	if (SurfFr1_FitSurface && UseSurfFract1)		//are we fitting distribution 1 volume?
		if (SurfFr1_SurfaceMin > SurfFr1_Surface || SurfFr1_SurfaceMax < SurfFr1_Surface)
			abort "Surface Fractal 1 Surface limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SurfFr1_Surface
		CoefNames[numpnts(CoefNames)-1]="SurfFr1_Surface"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(SurfFr1_SurfaceMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(SurfFr1_SurfaceMax)}		
	endif
	if (SurfFr1_FitKsi && UseSurfFract1)		//are we fitting distribution 1 location?
		if (SurfFr1_KsiMin > SurfFr1_Ksi || SurfFr1_KsiMax < SurfFr1_Ksi)
			abort "Surface fractal 1 Ksi limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SurfFr1_Ksi
		CoefNames[numpnts(CoefNames)-1]="SurfFr1_Ksi"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(SurfFr1_KsiMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(SurfFr1_KsiMax)}		
	endif
	if (SurfFr1_FitDS && UseSurfFract1)		//are we fitting distribution 1 location?
		if (SurfFr1_DSMin > SurfFr1_DS || SurfFr1_DSMax < SurfFr1_DS)
			abort "Surface fractal 1 DS limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SurfFr1_DS
		CoefNames[numpnts(CoefNames)-1]="SurfFr1_DS"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(SurfFr1_DSMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(SurfFr1_DSMax)}		
	endif
//Surface fractal 2 part	
	if (SurfFr2_FitSurface && UseSurfFract2)		//are we fitting distribution 1 volume?
		if (SurfFr2_SurfaceMin > SurfFr2_Surface || SurfFr2_SurfaceMax < SurfFr2_Surface)
			abort "Surface Fractal 1 Surface limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SurfFr2_Surface
		CoefNames[numpnts(CoefNames)-1]="SurfFr2_Surface"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(SurfFr2_SurfaceMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(SurfFr2_SurfaceMax)}		
	endif
	if (SurfFr2_FitKsi && UseSurfFract2)		//are we fitting distribution 1 location?
		if (SurfFr2_KsiMin > SurfFr2_Ksi || SurfFr2_KsiMax < SurfFr2_Ksi)
			abort "Surface fractal 1 Ksi limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SurfFr2_Ksi
		CoefNames[numpnts(CoefNames)-1]="SurfFr2_Ksi"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(SurfFr2_KsiMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(SurfFr2_KsiMax)}		
	endif
	if (SurfFr2_FitDS && UseSurfFract2)		//are we fitting distribution 1 location?
		if (SurfFr2_DSMin > SurfFr2_DS || SurfFr2_DSMax < SurfFr2_DS)
			abort "Surface fractal 1 DS limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SurfFr2_DS
		CoefNames[numpnts(CoefNames)-1]="SurfFr2_DS"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(SurfFr2_DSMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(SurfFr2_DSMax)}		
	endif
				

	//Now let's check if we have what to fit at all...
	if (numpnts(CoefNames)==0)
		beep
		Abort "Select parameters to fit and set their fitting limits"
	endif
	IR1V_SetErrorsToZero()
	
	DoWindow /F IR1V_LogLogPlotV
	Wave OriginalQvector
	Wave OriginalIntensity
	Wave OriginalError	
	
	Variable V_chisq
	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave=W_coef/100

//	IR1A_RecordResults("before")

	Variable V_FitError=0			//This should prevent errors from being generated
	
	//and now the fit...
	if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalIntensity, FitIntensityWave		
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalQvector, FitQvectorWave
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalError, FitErrorWave
		//***Catch error issues
		wavestats/Q FitErrorWave
		if(V_Min<1e-20)
			Print "Warning: Looks like you have some very small uncertainties (ERRORS). Any point with uncertaitny (error) < = 0 is masked off and not fitted. "
			Print "Make sure your uncertainties are all LARGER than 0 for ALL points." 
		endif
		if(V_avg<=0)
			Print "Note: these are uncertainties after scaling/processing. Did you accidentally scale uncertainties by 0 ? " 
			Abort "Uncertainties (ERRORS) make NO sense. Points with uncertainty (error) <= 0 are not fitted and this causes troubles. Fix uncertainties and try again. See history area for more details."
		endif
		//***End of Catch error issues
		FuncFit /N=0/W=0/Q IR1V_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /D /C=T_Constraints 
	else
		Duplicate/O OriginalIntensity, FitIntensityWave		
		Duplicate/O OriginalQvector, FitQvectorWave
		Duplicate/O OriginalError, FitErrorWave
		//***Catch error issues
		wavestats/Q FitErrorWave
		if(V_Min<1e-20)
			Print "Warning: Looks like you have some very small uncertainties (ERRORS). Any point with uncertaitny (error) < = 0 is masked off and not fitted. "
			Print "Make sure your uncertainties are all LARGER than 0 for ALL points." 
		endif
		if(V_avg<=0)
			Print "Note: these are uncertainties after scaling/processing. Did you accidentally scale uncertainties by 0 ? " 
			Abort "Uncertainties (ERRORS) make NO sense. Points with uncertainty (error) <= 0 are not fitted and this causes troubles. Fix uncertainties and try again. See history area for more details."
		endif
		//***End of Catch error issues
		FuncFit /N=0/W=0/Q IR1V_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D /C=T_Constraints	
	endif
	if (V_FitError!=0)	//there was error in fitting
		IR1V_ResetParamsAfterBadFit()
		beep
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	
	variable/g AchievedChisq=V_chisq
	IR1V_RecordErrorsAfterFit()
	IR1V_GraphModelData()
//	IR1A_RecordResults("after")
//	
	DoWIndow/F IR1V_ControlPanel
//	IR1A_FixTabsInPanel()
	
	KillWaves T_Constraints, E_wave
	
	setDataFolder OldDF
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_ResetParamsAfterBadFit()
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:FractalsModel

	Wave w=root:Packages:FractalsModel:CoefficientInput
	Wave/T CoefNames=root:Packages:FractalsModel:CoefNames		//text wave with names of parameters

	if ((!WaveExists(w)) || (!WaveExists(CoefNames)))
		Beep
		abort "Record of old parameters does not exist, this is BUG, please report it..."
	endif

	variable i
	For(i=0;i<numpnts(w);i+=1)
		NVAR testVal=$(CoefNames[i])
		testVal=w[i]
	endfor
	setDataFolder oldDF
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_RecordErrorsAfterFit()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:FractalsModel
	
	Wave W_sigma=root:Packages:FractalsModel:W_sigma
	Wave/T CoefNames=root:Packages:FractalsModel:CoefNames
	
	variable i
	For(i=0;i<numpnts(CoefNames);i+=1)
		NVAR InsertErrorHere=$(CoefNames[i]+"Error")
		InsertErrorHere=W_sigma[i]
	endfor
	setDataFolder oldDF

end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_FitFunction(w,yw,xw) : FitFunc
	Wave w,yw,xw
	
	//here the w contains the parameters, yw will be the result and xw is the input
	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(q) = very complex calculations, forget about formula
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1 - the q vector...
	//CurveFitDialog/ q
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:FractalsModel
	
	NVAR SASBackground=root:Packages:FractalsModel:SASBackground
	NVAR FitSASBackground=root:Packages:FractalsModel:FitSASBackground
	NVAR UseMassFract1=root:Packages:FractalsModel:UseMassFract1
	NVAR UseMassFract2=root:Packages:FractalsModel:UseMassFract2
	NVAR UseSurfFract1=root:Packages:FractalsModel:UseSurfFract1
	NVAR UseSurfFract2=root:Packages:FractalsModel:UseSurfFract2
	NVAR SASBackground=root:Packages:FractalsModel:SASBackground
	NVAR FitSASBackground=root:Packages:FractalsModel:FitSASBackground


	Wave/T CoefNames=root:Packages:FractalsModel:CoefNames		//text wave with names of parameters

	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	string ParamName=""
	
	for (i=0;i<NumOfParam;i+=1)
		ParamName=CoefNames[i]
		NVAR tempVar=$(ParamName)
		tempVar = w[i]
	endfor

	Wave QvectorWave=root:Packages:FractalsModel:FitQvectorWave
	Duplicate/O QvectorWave, FractFitIntensity
	//and now we need to calculate the model Intensity
	IR1V_FitFractalCalcIntensity(QvectorWave)		
	
	Wave resultWv=root:Packages:FractalsModel:FractFitIntensity
	
	yw=resultWv
	setDataFolder oldDF
End


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_FitFractalCalcIntensity(OriginalQvector)
	wave OriginalQvector

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:FractalsModel

//	Wave OriginalQvector
	Duplicate/O OriginalQvector, FractFitIntensity
	Redimension/D FractFitIntensity
	Duplicate/O OriginalQvector, FractFitQvector
	Redimension/D FractFitQvector
	
	FractFitIntensity=0
	
	NVAR UseMassFract1
	NVAR UseMassFract2
	NVAR UseSurfFract1
	NVAR UseSurfFract2

	if(UseMassFract1)	
		IR1V_CalculateMassFractal(1)
	endif
	if(UseMassFract2)	
		IR1V_CalculateMassFractal(2)
	endif
	if(UseSurfFract1)	
		IR1V_CalculateSfcFractal(1)
	endif
	if(UseSurfFract2)	
		IR1V_CalculateSfcFractal(2)
	endif
	
	NVAR SASBackground=root:Packages:FractalsModel:SASBackground
	FractFitIntensity+=SASBackground	
	setDataFolder oldDF
	
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
