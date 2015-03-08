#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.17
Constant IR2RversionNumber=1.16

//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.17 removed many Executes (improvement for Igor 7) 
//1.16 fixed annoying bug which caused sliders to be drawn over graph when parameters were recoved.
//1.15 added fixlimits on start to move al sliders into the middle of their range. Attempted to fix problems with some users fitting data with NaNs by cleaning up data before fit. 
//1.14 added option to oversample the data, with this choise selected the model will have 5x as many points. 
//1.13 modifed to remove xop dependence. Now it will compile without xop but complain on run, if xop is not installed. 
//1.12 modified panel to be scrollable
//1.11 added Motofit data types for convenience. 
//1.10 added Remove/Insert layer capability, made minor change which increases speed by about 20% when all imaginary SLDs are set to 0 (neutrons typically).  
//1.09 added ability to link parameters. Major change in GUI. Added saving fitting uncertainities into already existing "Error" variables. Made many functions static.  
//1.08 added sliders to control the parameters. Seems to work very well, need testing.  Added ability to use dq as resolution wave, not only % resolution. 
//1.07 added information about Motofit and using new Andrew Melsons function speeded up by ~ 40x
//1.06 removed all font and font size from panel definitions to enable user control
//1.05 added double precision ParametersIn wave as seems to be needed by new version of Abeles.xop, added to check version for panesl and widened range of thicknesses displayed. 
//1.04 added ability to export Model result to new folder if there are no input data.  
//1.03 fixed minor bug when SLD step change disalowed negative SLDs
//1.02 removed old method of Genetic optimization
//1.01 added license for ANL

Function IR2R_ReflectivitySimpleToolMain()

	IN2G_CheckScreenSize("height",670)
	IR2R_InitializeSimpleTool()
	
	DoWindow IR2R_ReflSimpleToolMainPanel
	if(V_Flag)
		DOWIndow/K IR2R_ReflSimpleToolMainPanel
	endif
	Execute("IR2R_ReflSimpleToolMainPanel()")
	ING2_AddScrollControl()
	UpdatePanelVersionNumber("IR2R_ReflSimpleToolMainPanel", IR2RversionNumber) 
	print "***** Important information *****"
	print "The reflectometry analysis in IRENA is based on functionality from the Motofit package (written by Andrew Nelson, www.sourceforge.net/projects/motofit)."
	print "If you use this functionality please cite the Motofit paper [J. Appl. Cryst. 39, 273-276]"
	print "*****"
	IR2R_FixLimits()
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR2R_MainCheckVersion()	
	DoWindow IR2R_ReflSimpleToolMainPanel
	if(V_Flag)
		if(!CheckPanelVersionNumber("IR2R_ReflSimpleToolMainPanel", IR2RversionNumber))
			DoAlert /T="The Reflectivity panel was created by old version of Irena " 1, "Reflectivity may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				Execute/P("IR2R_ReflectivitySimpleToolMain()")
			else		//at least reinitialize the variables so we avoid major crashes...
				IR2R_InitializeSimpleTool()	
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
Window IR2R_ReflSimpleToolMainPanel()
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,390,720) as "Reflectivity Simple Tool"
	string UserDataTypes="*_R;"
	string UserNameString="Motofit"
	string XUserLookup="*_R:*_q;"
	string EUserLookup="*_R:*_E;"
	IR2C_AddDataControls("Refl_SimpleTool","IR2R_ReflSimpleToolMainPanel","DSM_Int;M_DSM_Int;","",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1)
	PopupMenu SelectDataFolder proc=IR2R_ReplMainPanelPopMenuProc


	SetDrawLayer UserBack
	TitleBox MainTitle title="Simple reflectivity tool",pos={20,0},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,24},fSize=22,fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,191},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info1 title="Data input",pos={10,28},frame=0,fstyle=1, fixedSize=1,size={80,20},fSize=14,fColor=(0,0,52224)
	TitleBox Info2 title="Model input:",pos={10,196},frame=0,fstyle=3, fixedSize=1,size={150,20},fSize=14
	TitleBox Info3 title="Fit? Link?  Low L/LinkTo  High L/Ratio",pos={190,286},frame=0,fstyle=2, fixedSize=0,size={20,15},fSize=10
	TitleBox Info5 title="Top environment",pos={2,237},frame=0,fstyle=3,fSize=14,fColor=(0,0,52224)
	TitleBox Info5 fixedSize=1,size={384,27},anchor=LC,labelBack=(16385,65535,65535)
	TitleBox Info6 title="Substrate",frame=0,fstyle=3, fixedSize=1,fSize=14,fColor=(0,0,52224), pos={2,500},size={385,70}, labelBack=(32768,65280,32768)
	TitleBox Info8 title=" ",frame=0,fstyle=3, fixedSize=1,fSize=14,fColor=(0,0,52224), pos={2,570},size={385,43}, labelBack=(65280,65280,32768)
	TitleBox Info7 title="SLD units - either * 10^-6 [1/A^2] or * 10^10  [1/cm^2]",pos={10,386},frame=0,fstyle=2, fixedSize=0,size={40,15},fSize=10


	//************************
	Button DrawGraphs,pos={270,39},size={100,18}, proc=IR2R_InputPanelButtonProc,title="Graph", help={"Create a graph (log-log) of your experiment data"}, fColor=(65280,65280,48896)

	CheckBox OversampleModel,pos={10,148},size={63,14},proc=IR2R_InputPanelCheckboxProc,title="Oversample model?"
	CheckBox OversampleModel,variable= root:Packages:Refl_SimpleTool:OversampleModel, help={"Check if you want to calculate model for 5x as many points"}

	CheckBox ZeroAtTheSubstrate,pos={10,162},size={63,14},proc=IR2R_InputPanelCheckboxProc,title="0 at the substrate?"
	CheckBox ZeroAtTheSubstrate,variable= root:Packages:Refl_SimpleTool:ZeroAtTheSubstrate, help={"Check if you want to Define SLD profile with 0 at the substrate"}
	CheckBox L1AtTheBottom,pos={10,176},size={63,14},proc=IR2R_InputPanelCheckboxProc,title="L1 at the substrate?"
	CheckBox L1AtTheBottom,variable= root:Packages:Refl_SimpleTool:L1AtTheBottom, help={"Check if you want to Define SLD profile with Layer 1 at the substrate, else Layer 1 is at the top"}


	CheckBox AutoUpdate,pos={130,175},size={63,14},proc=IR2R_InputPanelCheckboxProc,title="Auto update?"
	CheckBox AutoUpdate,variable= root:Packages:Refl_SimpleTool:AutoUpdate, help={"Check if you want to update with every change inthe panel."}

	CheckBox UseErrors,pos={130,160},size={63,14},proc=IR2R_InputPanelCheckboxProc,title="Use errors?"
	CheckBox UseErrors,variable= root:Packages:Refl_SimpleTool:UseErrors, help={"Check if you want to use Intensity errors in fitting (if errors are available)"}

	PopupMenu ErrorDataName, disable=!root:Packages:Refl_SimpleTool:UseErrors

//	CheckBox UseResolutionWave,pos={260,158},size={80,16},proc=IR2R_InputPanelCheckboxProc,title="Resolution wave?"
//	CheckBox UseResolutionWave,variable= root:Packages:Refl_SimpleTool:UseResolutionWave, help={"Use wave for instrument resolution? Must be in the same folder as data... "}
	PopupMenu ResolutionType,pos={215,155},size={80,14},proc=IR2R_PanelPopupControl,title="Resolution?", help={"Select what resolution you want to use. "}
	PopupMenu ResolutionType,mode=1,popvalue=StringFromList(root:Packages:Refl_SimpleTool:UseResolutionWave, "Fixed [%];Wave [%];Wave [dq];Wave [dq^2];"),value= "Fixed [%];Wave [%];Wave [dq];Wave [dq^2];"//, disable=!(root:Packages:Refl_SimpleTool:UseResolutionWave)
	SetVariable Resolution,pos={240,177},size={110,16},proc=IR2R_PanelSetVarProc,title="Instr res.", help={"Instrument resolution in %"}
	SetVariable Resolution,limits={0,Inf,0},variable= root:Packages:Refl_SimpleTool:Resoln, disable = (root:Packages:Refl_SimpleTool:UseResolutionWave)
	//ResolutionWaveName
	PopupMenu ResolutionWaveName,pos={215,176},size={100,14},proc=IR2R_PanelPopupControl,title="Res Wave:", help={"Select wave with resolution data. Must be in % and have same number of points as other data. "}
	PopupMenu ResolutionWaveName,mode=1,popvalue="---",value= #"\"---;Create From Parameters;\"+IR2R_ResWavesList()", disable=!(root:Packages:Refl_SimpleTool:UseResolutionWave)


	PopupMenu NumberOfLevels,pos={120,198},size={140,21},proc=IR2R_PanelPopupControl,title="Number of layers :", help={"Select number of layers to use, NOTE that the layer 1 has to have the top one, layer 8 last one"}
	PopupMenu NumberOfLevels,mode=2,popvalue=num2str(WhichListItem(num2str(root:Packages:Refl_SimpleTool:NumberOfLayers), "0;1;2;3;4;5;6;7;8;")),value= #"\"0;1;2;3;4;5;6;7;8;\""

	PopupMenu FitIQN,pos={270,198},size={100,21},proc=IR2R_PanelPopupControl,title="Fit I*Q^n :", help={"For display & fitting purposes, display & fit I * Q^n (scaling to help least sqaure fitting). n=0 fits Intensity"}
	PopupMenu FitIQN,mode=2,popvalue=num2str(WhichListItem(num2str(root:Packages:Refl_SimpleTool:FitIQN), "0;1;2;3;4;")),value= #"\"0;1;2;3;4;\""


	SetVariable SLD_Real_Top,pos={140,245},size={110,16},proc=IR2R_PanelSetVarProc,title="SLD (real) "
	SetVariable SLD_Real_Top,limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:SLD_Real_Top, help={"SLD (real part) of top material"}
	SetVariable SLD_Imag_Top,pos={270,245},size={110,16},proc=IR2R_PanelSetVarProc,title="SLD (imag) "
	SetVariable SLD_Imag_Top,limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:SLD_Imag_Top, help={"SLD (imag part) of top material"}

	SetVariable ScalingFactor,pos={8,220},size={160,16},proc=IR2R_PanelSetVarProc,title="ScalingFactor", fstyle=1
	SetVariable ScalingFactor,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:ScalingFactor, help={"ScalingFactor - 1 if data corrected correctly"}
	CheckBox FitScalingFactor,pos={200,220},size={80,16},proc=IR2R_InputPanelCheckboxProc,title=""
	CheckBox FitScalingFactor,variable= root:Packages:Refl_SimpleTool:FitScalingFactor, help={"Fit FitScalingFactor?, "}
	SetVariable ScalingFactorLL,pos={230,220},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
	SetVariable ScalingFactorLL,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:ScalingFactorLL, help={"Low limit for ScalingFactor"}
	SetVariable ScalingFactorUL,pos={300,220},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
	SetVariable ScalingFactorUL,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:ScalingFactorUL, help={"High limit for ScalingFactor"}

	SetVariable Roughness_Bot,pos={14,525},size={160,16},proc=IR2R_PanelSetVarProc,title="Roughness "
	SetVariable Roughness_Bot,limits={0,inf,1},variable= root:Packages:Refl_SimpleTool:Roughness_Bot, help={"Roughness of the substrate material"}
	CheckBox FitRoughness_Bot,pos={190,525},size={80,16},proc=IR2R_InputPanelCheckboxProc,title=" "
	CheckBox FitRoughness_Bot,variable= root:Packages:Refl_SimpleTool:FitRoughness_Bot, help={"Fit roughness of substrate?, find god starting conditions and select fitting limits..."}
	SetVariable Roughness_BotLL,pos={230,525},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
	SetVariable Roughness_BotLL,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Roughness_BotLL, help={"Low limit for substrate Roughness"}
	SetVariable Roughness_BotUL,pos={300,525},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
	SetVariable Roughness_BotUL,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Roughness_BotUL, help={"High limit for substrate Roughness"}

	SetVariable SLD_real_Bot,pos={14,550},size={150,16},proc=IR2R_PanelSetVarProc,title="SLD (real) "
	SetVariable SLD_Real_Bot,limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:SLD_Real_Bot, help={"SLD (real part) of substrate material"}
	SetVariable SLD_Imag_Bot,pos={190,550},size={150,16},proc=IR2R_PanelSetVarProc,title="SLD (imag) "
	SetVariable SLD_Imag_Bot,limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:SLD_Imag_Bot, help={"SLD (real part) of substrate material"}


	SetVariable Background,pos={10,575},size={160,16},proc=IR2R_PanelSetVarProc,title="Background", help={"Background"}
	SetVariable Background,limits={0,Inf,root:Packages:Refl_SimpleTool:BackgroundStep},variable= root:Packages:Refl_SimpleTool:Background
	SetVariable BackgroundStep,pos={25,595},size={160,16},title="Background step",proc=IR2R_PanelSetVarProc, help={"Step for increments in background"}
	SetVariable BackgroundStep,limits={0,Inf,0},variable= root:Packages:Refl_SimpleTool:BackgroundStep
	CheckBox FitBackground,pos={190,575},size={63,14},proc=IR2R_InputPanelCheckboxProc,title=" "
	CheckBox FitBackground,variable= root:Packages:Refl_SimpleTool:FitBackground, help={"Check if you want the background to be fitting parameter"}
	SetVariable BackgroundLL,pos={230,575},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
	SetVariable BackgroundLL,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:BackgroundLL, help={"Low limit for Background"}
	SetVariable BackgroundUL,pos={300,575},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
	SetVariable BackgroundUL,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:BackgroundUL, help={"High limit for Background"}

	Button AddRemoveLayers,pos={230,482},size={155,15}, proc=IR2R_InputPanelButtonProc,title="Insert/Remove Layer", help={"Insert or remove layer from the system"}
	Button SaveDataBtn,pos={195,617},size={90,20}, proc=IR2R_InputPanelButtonProc,title="Save data", help={"Save data"}
	Button ExportData,pos={290,617},size={90,20}, proc=IR2R_InputPanelButtonProc,title="Export data", help={"Export data"}
	Button FixLimits,pos={5,617},size={90,20}, proc=IR2R_InputPanelButtonProc,title="Fix Limits", help={"Fix limits for all parameters"}
	Button CalculateModel,pos={5,655},size={90,20}, proc=IR2R_InputPanelButtonProc,title="Graph model", help={"Graph model data and calculate reflectivity"}
	Button Fitmodel,pos={100,655},size={90,20}, proc=IR2R_InputPanelButtonProc,title="Fit model", help={"Fit modto data"}
	Button ReversFit,pos={195,655},size={90,20}, proc=IR2R_InputPanelButtonProc,title="Reverse fit", help={"Fit modto data"}

	CheckBox UseGenOpt,pos={100,618},size={90,10},proc=IR2R_InputPanelCheckboxProc,title="Genetic Opt.?", mode=1
	CheckBox UseGenOpt,variable= root:Packages:Refl_SimpleTool:UseGenOpt, help={"Use genetic Optimization? SLOW..."}
	CheckBox UseLSQF,pos={100,634},size={90,10},proc=IR2R_InputPanelCheckboxProc,title="LSQF?", mode=1
	CheckBox UseLSQF,variable= root:Packages:Refl_SimpleTool:UseLSQF, help={"Use LSQF?"}
	CheckBox UpdateDuringFitting,pos={190,638},size={80,16},noproc,title="Update while fitting?"
	CheckBox UpdateDuringFitting,variable= root:Packages:Refl_SimpleTool:UpdateDuringFitting, help={"Update graph during fitting? Will slow things down!!! "}

	//Dist Tabs definition
	TabControl DistTabs,pos={3,265},size={380,230},proc=IR2R_TabPanelControl
	TabControl DistTabs,fSize=10,tabLabel(0)="L 1",tabLabel(1)="L 2"
	TabControl DistTabs,tabLabel(2)="L 3",tabLabel(3)="L 4",value= 0
	TabControl DistTabs,tabLabel(4)="L 5",tabLabel(5)="L 6"
	TabControl DistTabs,tabLabel(6)="L 7",tabLabel(7)="L 8"
	string Selection="1;2;3;4;5;6;7;"
	string TempSel
	variable i=1
		//Execute("SetVariable ThicknessLayer"+num2str(i)+",pos={8,308},size={160,16},proc=IR2R_PanelSetVarProc,title=\"Thickness [A]   \", fstyle=1")
	Do	
		TempSel = "\""+RemoveFromList(num2str(i), Selection)+"\""
		TitleBox $("LayerTitleBox"+num2str(i)), title="   Layer "+num2str(i)+"  ", frame=1, labelBack=(4000*i,6000*i,4000*(8-i)), pos={14,285}, fstyle=1,size={200,8},fColor=(65535,65535,65535)

		SetVariable $("ThicknessLayer"+num2str(i)),pos={8,308},size={160,16},proc=IR2R_PanelSetVarProc,title="Thickness [A]   ", fstyle=1

		 SetVariable $("ThicknessLayer"+num2str(i)),limits={0,inf,root:Packages:Refl_SimpleTool:$("ThicknessLayerStep"+num2str(i))},variable= root:Packages:Refl_SimpleTool:$("ThicknessLayer"+num2str(i)), help={"Layer Thickness in A"}
		 SetVariable $("ThicknessLayerStep"+num2str(i)),pos={200,325},size={160,16},proc=IR2R_PanelSetVarProc,title="Thickness step   ",bodyWidth=50
		 SetVariable $("ThicknessLayerStep"+num2str(i)),limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:$("ThicknessLayerStep"+num2str(i)), help={"Layer Thickness step to take above"}
		 CheckBox $("FitThicknessLayer"+num2str(i)),pos={190,308},size={80,16},proc=IR2R_InputPanelCheckboxProc,title=" "
		 CheckBox $("FitThicknessLayer"+num2str(i)),variable= root:Packages:Refl_SimpleTool:$("FitThicknessLayer"+num2str(i)), help={"Fit thickness surface?, find god starting conditions and select fitting limits..."}
		 SetVariable $("ThicknessLayerLL"+num2str(i)),pos={238,308},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
		 SetVariable $("ThicknessLayerLL"+num2str(i)),limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:$("ThicknessLayerLL"+num2str(i)), help={"Low limit for thickness"}
		 SetVariable $("ThicknessLayerUL"+num2str(i)),pos={310,308},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
		 SetVariable $("ThicknessLayerUL"+num2str(i)),limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:$("ThicknessLayerUL"+num2str(i)), help={"High limit for thickness"}
		 Slider $("ThicknessLayerSl"+num2str(i)),pos={8,325},size={180,20},vert=0,proc=IR2R_ReflSliderProc,variable=root:Packages:Refl_SimpleTool:$("ThicknessLayer"+num2str(i)),ticks=0
		 Slider $("ThicknessLayerSl"+num2str(i)),help={"Controls Thickness as Slider, uses Fit Low, High limits and step"}
		 Slider $("ThicknessLayerSl"+num2str(i)),limits={root:Packages:Refl_SimpleTool:$("ThicknessLayerLL"+num2str(i)),root:Packages:Refl_SimpleTool:$("ThicknessLayerUL"+num2str(i)),0}
		 CheckBox $("LinkThicknessLayer"+num2str(i)),pos={215,308},size={80,16},proc=IR2R_InputPanelCheckboxProc,title=" "
		 CheckBox $("LinkThicknessLayer"+num2str(i)),variable= root:Packages:Refl_SimpleTool:$("LinkThicknessLayer"+num2str(i)), help={"Link thickness surface?, find god starting conditions and select fitting limits..."}
		 PopupMenu $("LinkToThicknessLayer"+num2str(i)),pos={243,308},size={60,12},proc=IR2R_PanelPopupControl,title="", help={"Select to which layer you want to link this value. "}
		 PopupMenu $("LinkToThicknessLayer"+num2str(i)),mode=1,fsize=8,bodyWidth=50,popvalue=num2str(root:Packages:Refl_SimpleTool:$("LinkToThicknessLayer"+num2str(i))),value=#TempSel	//  value= #"\"0;1;2;3;4;""
		 SetVariable $("LinkFThicknessLayer"+num2str(i)),pos={310,308},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
		 SetVariable $("LinkFThicknessLayer"+num2str(i)),limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:$("LinkFThicknessLayer"+num2str(i)), help={"Ratio to use for linking the thickness"}

		

		 SetVariable $("SLD_Real_Layer"+num2str(i)),pos={8,345},size={160,16},proc=IR2R_PanelSetVarProc,title="SLD (real)  ", fstyle=1
		 SetVariable $("SLD_Real_Layer"+num2str(i)),limits={-inf,inf,root:Packages:Refl_SimpleTool:$("SLD_Real_LayerStep"+num2str(i))},variable= root:Packages:Refl_SimpleTool:$("SLD_Real_Layer"+num2str(i)), help={"Layer SLD (real part)"}
		 SetVariable $("SLD_Real_LayerStep"+num2str(i)),pos={200,362},size={160,16},proc=IR2R_PanelSetVarProc,title="SLD (real) step   ",bodyWidth=50
		 SetVariable $("SLD_Real_LayerStep"+num2str(i)),limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:$("SLD_Real_LayerStep"+num2str(i)), help={"Layer SLD (real) step to take above"}
		 CheckBox $("FitSLD_Real_Layer"+num2str(i)),pos={190,345},size={80,16},proc=IR2R_InputPanelCheckboxProc,title=" "
		 CheckBox $("FitSLD_Real_Layer"+num2str(i)),variable= root:Packages:Refl_SimpleTool:$("FitSLD_Real_Layer"+num2str(i)), help={"Fit SLD?, find good starting conditions and select fitting limits..."}
		 SetVariable $("SLD_Real_LayerLL"+num2str(i)),pos={238,345},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
		 SetVariable $("SLD_Real_LayerLL"+num2str(i)),limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:$("SLD_Real_LayerLL"+num2str(i)), help={"Low limit for SLD"}
		 SetVariable $("SLD_Real_LayerUL"+num2str(i)),pos={310,345},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
		 SetVariable $("SLD_Real_LayerUL"+num2str(i)),limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:$("SLD_Real_LayerUL"+num2str(i)), help={"High limit for SLD"}
		 Slider $("SLD_Real_LayerSl"+num2str(i)),pos={8,362},size={180,20},vert=0,proc=IR2R_ReflSliderProc,variable=root:Packages:Refl_SimpleTool:$("SLD_Real_Layer"+num2str(i)),ticks=0
		 Slider $("SLD_Real_LayerSl"+num2str(i)),help={"Controls SLD Real as Slider, uses Fit Low, High limits and step"}
		 Slider $("SLD_Real_LayerSl"+num2str(i)),limits={root:Packages:Refl_SimpleTool:$("SLD_Real_LayerLL"+num2str(i)),root:Packages:Refl_SimpleTool:$("SLD_Real_LayerUL"+num2str(i)),0}
		 CheckBox $("LinkSLD_Real_Layer"+num2str(i)),pos={215,345},size={80,16},proc=IR2R_InputPanelCheckboxProc,title=" "
		 CheckBox $("LinkSLD_Real_Layer"+num2str(i)),variable= root:Packages:Refl_SimpleTool:$("LinkSLD_Real_Layer"+num2str(i)), help={"Link SLD?, find good starting conditions and select fitting limits..."}

		 PopupMenu $("LinkToSLD_Real_Layer"+num2str(i)),pos={243,345},size={60,12},proc=IR2R_PanelPopupControl,title="", help={"Select to which layer you want to link this value. "}
		 PopupMenu $("LinkToSLD_Real_Layer"+num2str(i)),mode=1,fsize=8,bodyWidth=50,popvalue=num2str(root:Packages:Refl_SimpleTool:$("LinkToSLD_Real_Layer"+num2str(i))),value=#TempSel	//  value= #"\"0;1;2;3;4;""
		 SetVariable $("LinkFSLD_Real_Layer"+num2str(i)),pos={310,345},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
		 SetVariable $("LinkFSLD_Real_Layer"+num2str(i)),limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:$("LinkFSLD_Real_Layer"+num2str(i)), help={"Ratio to use for linking the SLD real value"}


		 SetVariable $("SLD_Imag_Layer"+num2str(i)),pos={8,410},size={160,16},proc=IR2R_PanelSetVarProc,title="SLD (imag)  ", fstyle=1
		 SetVariable $("SLD_Imag_Layer"+num2str(i)),limits={-inf,inf,root:Packages:Refl_SimpleTool:$("SLD_Imag_LayerStep"+num2str(i))},variable= root:Packages:Refl_SimpleTool:$("SLD_Imag_Layer"+num2str(i)), help={"Layer SLD (imag part) in A"}
		 SetVariable $("SLD_Imag_LayerStep"+num2str(i)),pos={200,427},size={160,16},proc=IR2R_PanelSetVarProc,title="SLD (imag) step   ",bodyWidth=50
		 SetVariable $("SLD_Imag_LayerStep"+num2str(i)),limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:$("SLD_Imag_LayerStep"+num2str(i)), help={"Layer SLD (imag) step to take above"}
		 CheckBox $("FitSLD_Imag_Layer"+num2str(i)),pos={190,410},size={80,16},proc=IR2R_InputPanelCheckboxProc,title=" "
		 CheckBox $("FitSLD_Imag_Layer"+num2str(i)),variable= root:Packages:Refl_SimpleTool:$("FitSLD_Imag_Layer"+num2str(i)), help={"Fit SLD?, find good starting conditions and select fitting limits..."}
		 SetVariable $("SLD_Imag_LayerLL"+num2str(i)),pos={238,410},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
		 SetVariable $("SLD_Imag_LayerLL"+num2str(i)),limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:$("SLD_Imag_LayerLL"+num2str(i)), help={"Low limit for SLD"}
		 SetVariable $("SLD_Imag_LayerUL"+num2str(i)),pos={310,410},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
		 SetVariable $("SLD_Imag_LayerUL"+num2str(i)),limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:$("SLD_Imag_LayerUL"+num2str(i)), help={"High limit for SLD"}
		 Slider $("SLD_Imag_LayerSl"+num2str(i)),pos={8,427},size={180,20},vert=0,proc=IR2R_ReflSliderProc,variable=root:Packages:Refl_SimpleTool:$("SLD_Imag_Layer"+num2str(i)),ticks=0
		 Slider $("SLD_Imag_LayerSl"+num2str(i)),help={"Controls SLD Imag  as Slider, uses Fit Low, High limits and step"}
		 Slider $("SLD_Imag_LayerSl"+num2str(i)),limits={root:Packages:Refl_SimpleTool:$("SLD_Imag_LayerLL"+num2str(i)),root:Packages:Refl_SimpleTool:$("SLD_Imag_LayerUL"+num2str(i)),0}
		 CheckBox $("LinkSLD_Imag_Layer"+num2str(i)),pos={215,410},size={80,16},proc=IR2R_InputPanelCheckboxProc,title=" "
		 CheckBox $("LinkSLD_Imag_Layer"+num2str(i)),variable= root:Packages:Refl_SimpleTool:$("LinkSLD_Imag_Layer"+num2str(i)), help={"Fit SLD?, find good starting conditions and select fitting limits..."}

		 PopupMenu $("LinkToSLD_Imag_Layer"+num2str(i)),pos={243,410},size={60,12},proc=IR2R_PanelPopupControl,title="", help={"Select to which layer you want to link this value. "}
		 PopupMenu $("LinkToSLD_Imag_Layer"+num2str(i)),mode=1,fsize=8,bodyWidth=50,popvalue=num2str(root:Packages:Refl_SimpleTool:$("LinkToSLD_Imag_Layer"+num2str(i))),value=#TempSel	//  value= #"\"0;1;2;3;4;""
		 SetVariable $("LinkFSLD_Imag_Layer"+num2str(i)),pos={310,410},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
		 SetVariable $("LinkFSLD_Imag_Layer"+num2str(i)),limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:$("LinkFSLD_Imag_Layer"+num2str(i)), help={"Ratio to use for linking the SLD imag value"}

		 SetVariable $("RoughnessLayer"+num2str(i)),pos={8,450},size={160,16},proc=IR2R_PanelSetVarProc,title="Roughness  ", fstyle=1
		 SetVariable $("RoughnessLayer"+num2str(i)),limits={0,inf,root:Packages:Refl_SimpleTool:$("RoughnessLayerStep"+num2str(i))},variable= root:Packages:Refl_SimpleTool:$("RoughnessLayer"+num2str(i)), help={"Layer roughness "}
		 SetVariable $("RoughnessLayerStep"+num2str(i)),pos={200,467},size={160,16},proc=IR2R_PanelSetVarProc,title="Roughness step   ",bodyWidth=50
		 SetVariable $("RoughnessLayerStep"+num2str(i)),limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:$("RoughnessLayerStep"+num2str(i)), help={"Layer roughness step to take above"}
		 CheckBox $("FitRoughnessLayer"+num2str(i)),pos={190,450},size={80,16},proc=IR2R_InputPanelCheckboxProc,title=" "
		 CheckBox $("FitRoughnessLayer"+num2str(i)),variable= root:Packages:Refl_SimpleTool:$("FitRoughnessLayer"+num2str(i)), help={"Fit roughness?, find good starting conditions and select fitting limits..."}
		 SetVariable $("RoughnessLayerLL"+num2str(i)),pos={238,450},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
		 SetVariable $("RoughnessLayerLL"+num2str(i)),limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:$("RoughnessLayerLL"+num2str(i)), help={"Low limit for roughness"}
		 SetVariable $("RoughnessLayerUL"+num2str(i)),pos={310,450},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
		 SetVariable $("RoughnessLayerUL"+num2str(i)),limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:$("RoughnessLayerUL"+num2str(i)), help={"High limit for roughness"}
		 Slider $("RoughnessLayerSl"+num2str(i)),pos={8,467},size={180,20},vert=0,proc=IR2R_ReflSliderProc,variable=root:Packages:Refl_SimpleTool:$("RoughnessLayer"+num2str(i)),ticks=0
		 Slider $("RoughnessLayerSl"+num2str(i)),help={"Controls Roughness  as Slider, uses Fit Low, High limits and step"}
		 Slider $("RoughnessLayerSl"+num2str(i)),limits={root:Packages:Refl_SimpleTool:$("RoughnessLayerLL"+num2str(i)),root:Packages:Refl_SimpleTool:$("RoughnessLayerUL"+num2str(i)),1}
		 CheckBox $("LinkRoughnessLayer"+num2str(i)),pos={215,450},size={80,16},proc=IR2R_InputPanelCheckboxProc,title=" "
		 CheckBox $("LinkRoughnessLayer"+num2str(i)),variable= root:Packages:Refl_SimpleTool:$("LinkRoughnessLayer"+num2str(i)), help={"Fit roughness?, find good starting conditions and select fitting limits..."}

		 PopupMenu $("LinkToRoughnessLayer"+num2str(i)),pos={243,450},size={60,12},proc=IR2R_PanelPopupControl,title="", help={"Select to which layer you want to link this value. "}
		 PopupMenu $("LinkToRoughnessLayer"+num2str(i)),mode=1,fsize=8,bodyWidth=50,popvalue=num2str(root:Packages:Refl_SimpleTool:$("LinkToRoughnessLayer"+num2str(i))),value=#TempSel	//  value= #"\"0;1;2;3;4;""
		 SetVariable $("LinkFRoughnessLayer"+num2str(i)),pos={310,450},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
		 SetVariable $("LinkFRoughnessLayer"+num2str(i)),limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:$("LinkFRoughnessLayer"+num2str(i)), help={"Ratio to use for linking the roughness value"}
	i+=1
	while(i<=8)	
	//endfor

	IR2R_TabPanelControl("",0)
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_ReplMainPanelPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	if(Pa.eventCode!=2)
		return 0
	endif	
	IR2C_PanelPopupControl(Pa) 
	SVAR ResolutionWaveName=root:Packages:Refl_SimpleTool:ResolutionWaveName
	ResolutionWaveName="---"
	PopupMenu ResolutionWaveName,mode=1,popvalue="---",value= #"\"---;Create From Parameters;\"+IR2R_ResWavesList()"
	
	return 0
End
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function/T IR2R_ResWavesList()

	string TopPanel=WinName(0,64)
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	SVAR Dtf=$(CntrlLocation+":DataFolderName")
	string tempresult=IN2G_CreateListOfItemsInFolder(Dtf,2)
	return tempresult
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


static Function IR2R_GraphMeasuredData()
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	SVAR DataFolderName
	SVAR IntensityWaveName
	SVAR QWavename
	SVAR ErrorWaveName
	SVAR ResolutionWaveName
	NVAR UseResolutionWave = root:Packages:Refl_SimpleTool:UseResolutionWave
	
	//fix for liberal names
	IntensityWaveName = PossiblyQuoteName(IntensityWaveName)
	QWavename = PossiblyQuoteName(QWavename)
	ErrorWaveName = PossiblyQuoteName(ErrorWaveName)
	
	WAVE/Z test=$(DataFolderName+IntensityWaveName)
	if (!WaveExists(test))
		abort "Error in IntensityWaveName wave selection"
	endif
	Duplicate/O $(DataFolderName+IntensityWaveName), OriginalIntensity
	Wave OriginalIntensity

	WAVE/Z test=$(DataFolderName+QWavename)
	if (!WaveExists(test))
		abort "Error in QWavename wave selection"
	endif
	Duplicate/O $(DataFolderName+QWavename), OriginalQvector
	WAVE/Z test=$(DataFolderName+ErrorWaveName)
	if (!WaveExists(test))
		//no error wave provided - fudge one with 1 in it...
		Duplicate/O $(DataFolderName+IntensityWaveName), OriginalError
		Wave OriginalError
		//OriginalError*=0.03
		IN2G_GenerateSASErrors(OriginalIntensity,OriginalError,4,.06, .01,.001,1)
		print "***********          IMPORTANT NOTE       **********************"
		print "User did not provide data uncertainity (\"error\") so fudged error wave with guessed values was created"
		print "*********************************"
	else
		Duplicate/O $(DataFolderName+ErrorWaveName), OriginalError
	endif
	//read resolution wave if not set by recovery and should be set - and w_ wave exists...
	//ResolutionWaveName
	string tempStr
	if(UseResolutionWave>0 && stringmatch(ResolutionWaveName,"*---*"))
		tempStr= IN2G_ReturnExistingWaveName(DataFolderName,"w"+IntensityWaveName[1,inf])
		if(strlen(tempStr)>0)
			ResolutionWaveName = StringFromList(0,tempStr,";")
			PopupMenu ResolutionWaveName,mode=1,popvalue=ResolutionWaveName,value= #"\"---;Create From Parameters;\"+IR2R_ResWavesList()"
		endif
	endif
	Redimension/D OriginalIntensity, OriginalQvector, OriginalError

	DoWindow IR2R_LogLogPlotRefl
	if (V_flag)
		Dowindow/K IR2R_LogLogPlotRefl
	endif
	Execute ("IR2R_LogLogPlotRefl()")
	
	//create different view on data (may be fitting view?)
	Duplicate/O OriginalIntensity, IntensityQN
	Duplicate/O OriginalQvector, QvectorToN
	Duplicate/O OriginalError, ErrorQN
	NVAR FitIQN=root:Packages:Refl_SimpleTool:FitIQN	
	
	IntensityQN = OriginalIntensity * OriginalQvector^FitIQN
	QvectorToN = OriginalQvector^FitIQN
	ErrorQN = OriginalError  * OriginalQvector^FitIQN
	

		DoWindow IR2R_IQN_Q_PlotV
		if (V_flag)
			Dowindow/K IR2R_IQN_Q_PlotV
		endif
		Execute ("IR2R_IQN_Q_PlotV()")

		IR2R_CalculateSLDProfile()
		DoWindow IR2R_SLDProfile
		if (V_flag)
			Dowindow/K IR2R_SLDProfile
		endif
		Execute ("IR2R_SLDProfile()")
	AutopositionWindow/E/M=0 /R=IR2R_ReflSimpleToolMainPanel  IR2R_LogLogPlotRefl
	AutopositionWindow/E/M=1 /R=IR2R_LogLogPlotRefl IR2R_IQN_Q_PlotV
	AutopositionWindow/E/M=1 /R=IR2R_IQN_Q_PlotV IR2R_SLDProfile
	
	
	setDataFolder oldDf
end

Proc  IR2R_LogLogPlotRefl() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:Refl_SimpleTool
	Display /W=(300,37.25,850,300)/K=1  OriginalIntensity vs OriginalQvector as "LogLogPlot"
	DoWIndow/C IR2R_LogLogPlotRefl
	ModifyGraph mode(OriginalIntensity)=3
	ModifyGraph msize(OriginalIntensity)=1
	ModifyGraph log(left)=1
	ModifyGraph mirror=1
	ShowInfo
	Label left "Reflectivity"
	Label bottom "Q [A\\S-1\\M]"
	TextBox/W=IR2R_LogLogPlotRefl/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR2R_LogLogPlotRefl/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	Legend/W=IR2R_LogLogPlotRefl/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 "\\s(OriginalIntensity) Experimental intensity"
	SetDataFolder fldrSav
	ErrorBars/Y=1 OriginalIntensity Y,wave=(root:Packages:Refl_SimpleTool:OriginalError,root:Packages:Refl_SimpleTool:OriginalError)
EndMacro

Proc  IR2R_IQN_Q_PlotV() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:Refl_SimpleTool:
	Display /W=(300,250,850,430)/K=1  IntensityQN vs OriginalQvector as "IQ^N_Q_Plot"
	DoWIndow/C IR2R_IQN_Q_PlotV
	ModifyGraph mode(IntensityQN)=3
	ModifyGraph msize(IntensityQN)=1
	ModifyGraph log=1
	ModifyGraph mirror=1
	Label left "Reflectivity * Q^n"
	Label bottom "Q [A\\S-1\\M]"
	TextBox/W=IR2R_IQN_Q_PlotV/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR2R_IQN_Q_PlotV/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	SetDataFolder fldrSav
	ErrorBars/Y=1 IntensityQN Y,wave=(root:Packages:Refl_SimpleTool:ErrorQN,root:Packages:Refl_SimpleTool:ErrorQN)
EndMacro

Proc  IR2R_SLDProfile()
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Refl_SimpleTool:
	Display /W=(298.5,390.5,847.5,567.5)/K=1 SLDProfile as "SLD profile (top=left, substrate=right)"
	DoWindow/C IR2R_SLDProfile
	Label left "SLD profile [A\\S-2\\M]"
	if(ZeroAtTheSubstrate)
		Label bottom "<<--Substrate                                               Layer thickness [A]                                         Top -->>"
		DoWindow/T IR2R_SLDProfile,"SLD profile (substrate=left, top=right)"
	else
		Label bottom "<<--TOP                                               Layer thickness [A]                                         Substrate -->>"
		DoWindow/T IR2R_SLDProfile,"SLD profile (top=left, substrate=right) "
	endif
	SetDataFolder fldrSav0
EndMacro


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

static Function IR2R_InitializeSimpleTool()

	string oldDf=GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewdataFolder/O/S root:Packages:Refl_SimpleTool
	
	string ListOfVariables
	string ListOfStrings
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="NumberOfLayers;ActiveTab;AutoUpdate;FitIQN;Resoln;UpdateAutomatically;ActiveTab;UseErrors;UseResolutionWave;UseLSQF;UseGenOpt;"
	ListOfVariables+="SLD_Real_Top;SLD_Imag_Top;SLD_Real_Bot;SLD_Imag_Bot;ZeroAtTheSubstrate;UpdateDuringFitting;"
	ListOfVariables+="Roughness_Bot;FitRoughness_Bot;Roughness_BotLL;Roughness_BotUL;Roughness_BotError;"
	ListOfVariables+="Background;BackgroundStep;FitBackground;BackgroundLL;BackgroundUL;BackgroundError;"
	ListOfVariables+="L1AtTheBottom;OversampleModel;"

	ListOfVariables+="Res_DeltaLambdaOverLambda;Res_DeltaLambda;Res_Lambda;Res_SourceDivergence;Res_DetectorSize;Res_DetectorDistance;"
	ListOfVariables+="Res_DetectorAngularResolution;Res_sampleSize;Res_beamHeight;"
	ListOfVariables+="ScalingFactor;ScalingFactorLL;ScalingFactorUL;FitScalingFactor;ScalingFactorError;"
	
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;ResolutionWaveName;"
	
	variable i, j
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
// create 8 x this following list:
	ListOfVariables="SLD_Real_Layer;SLD_Imag_Layer;ThicknessLayer;RoughnessLayer;"
	ListOfVariables+="SLD_Real_LayerError;SLD_Imag_LayerError;ThicknessLayerError;RoughnessLayerError;"
	ListOfVariables+="SLD_Real_LayerStep;SLD_Imag_LayerStep;ThicknessLayerStep;RoughnessLayerStep;"
	ListOfVariables+="SLD_Real_LayerLL;SLD_Imag_LayerLL;ThicknessLayerLL;RoughnessLayerLL;"
	ListOfVariables+="SLD_Real_LayerUL;SLD_Imag_LayerUL;ThicknessLayerUL;RoughnessLayerUL;"
	ListOfVariables+="FitSLD_Real_Layer;FitSLD_Imag_Layer;FitThicknessLayer;FitRoughnessLayer;"
	ListOfVariables+="LinkSLD_Real_Layer;LinkSLD_Imag_Layer;LinkThicknessLayer;LinkRoughnessLayer;"
	ListOfVariables+="LinkFSLD_Real_Layer;LinkFSLD_Imag_Layer;LinkFThicknessLayer;LinkFRoughnessLayer;"
	ListOfVariables+="LinkToSLD_Real_Layer;LinkToSLD_Imag_Layer;LinkToThicknessLayer;LinkToRoughnessLayer;"
	for(j=1;j<=8;j+=1)	
		for(i=0;i<itemsInList(ListOfVariables);i+=1)	
			IN2G_CreateItem("variable",StringFromList(i,ListOfVariables)+num2str(j))
		endfor		
	endfor
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	//cleanup after possible previous fitting stages...
	Wave/Z CoefNames=root:Packages:FractalsModel:CoefNames
	Wave/Z CoefficientInput=root:Packages:FractalsModel:CoefficientInput
	KillWaves/Z CoefNames, CoefficientInput
	
	IR2R_SetInitialValues()		
	setDataFolder oldDF

end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
/////******************************************************************************************
//
static Function IR2R_SetInitialValues()
//	//and here set default values...
//
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
//	
	string ListOfVariables
	variable i, j
	
	//	here we set what needs to be 0
	ListOfVariables="SLD_Real_Top;SLD_Imag_Top;Background;Roughness_Bot;FitIQN;FitBackground;BackgroundLL;BackgroundUL;UpdateAutomatically;FitRoughness_Bot;Roughness_BotLL;Roughness_BotUL;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		testVar=0
	endfor
		
	//and here to 1
	ListOfVariables="NumberOfLayers;Resoln;UseErrors;ScalingFactor;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=1
		endif
	endfor
	ListOfVariables="FitIQN;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=4
		endif
	endfor

	ListOfVariables="ScalingFactorLL;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=0.1
		endif
	endfor

	ListOfVariables="ScalingFactorUL;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=2
		endif
	endfor
	
	
	NVAR SLD_Real_Bot
	if(SLD_Real_Bot==0)
		SLD_Real_Bot = 2.073
	endif

	NVAR SLD_Imag_Bot
	if(SLD_Imag_Bot==0)
		SLD_Imag_Bot = 2.37e-5
	endif
	
	NVAR UseLSQF
	NVAR UseGenOpt
	if((UseLSQF+UseGenOpt)!=1)
		UseLSQF=1
		UseGenOpt=0
	endif

	For(j=1;j<=8;j+=1)
		//set to 0
		ListOfVariables="RoughnessLayer;SolventPenetrationLayer;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=0
			endif
		endfor
		ListOfVariables="RoughnessLayerStep;SolventPenetrationLayerStep;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=0.3
			endif
		endfor
		ListOfVariables="LinkFSLD_Real_Layer;LinkFSLD_Imag_Layer;LinkFThicknessLayer;LinkFRoughnessLayer;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar<=0)
				testVar=1
			endif
		endfor
		ListOfVariables="FitSLD_Real_Layer;FitSLD_Imag_Layer;FitThicknessLayer;FitRoughnessLayer;FitSolventPenetrationLayer;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=0
			endif
		endfor
		//set to 25
		ListOfVariables="ThicknessLayer;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=25
			endif
		endfor
		//set to 25
		ListOfVariables="ThicknessLayerStep;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=5
			endif
		endfor
		//set to 3.47e-6
		ListOfVariables="SLD_Real_Layer;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=3.47
			endif
		endfor
		//set to 3.47e-6
		ListOfVariables="SLD_Real_LayerStep;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=0.1
			endif
		endfor
		//set to 3.47e-6
		ListOfVariables="SLD_Imag_Layer;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=1.05e-5
			endif
		endfor
		//set to 3.47e-6
		ListOfVariables="SLD_Imag_LayerStep;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=1e-6
			endif
		endfor
	
		
	endfor
	IR2R_SetErrorsToZero()
	setDataFolder oldDF
end
//
//
/////******************************************************************************************
/////******************************************************************************************
/////******************************************************************************************
/////******************************************************************************************
/////******************************************************************************************
/////******************************************************************************************
static Function IR2R_SetErrorsToZero()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool

	string ListOfVariables="Roughness_BotError;BackgroundError;"
	variable i,j
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		testVar=0
	endfor

	ListOfVariables="SLD_Real_Layer;SLD_Imag_Layer;ThicknessLayer;RoughnessLayer;SolventPenetrationLayer;"

	For(j=1;j<9;j+=1)
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Error"+num2str(j))
			testVar=0
		endfor
	endfor

	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
static Function IR2R_CalculateSLDProfile()
	//this function calculates model data
//	make/o/t parameters_Cref = {"Numlayers","scale","re_SLDtop","imag_SLDtop","re_SLDbase","imag_SLD base","bkg","sigma_base","thick1","re_SLD1","imag_SLD1","rough1","thick2","re_SLD2","imag_SLD2","rough2"}
//	Edit parameters_Cref,coef_Cref,par_res,resolution
//	ywave_Cref:= Motofit_Imag(coef_Cref,xwave_Cref)

	variable i, j
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool

		//Need to create wave with parameters for Motofit_Imag here
	NVAR NumberOfLayers= root:Packages:Refl_SimpleTool:NumberOfLayers
	variable NumPntsInSLDPlot=NumberOfLayers * 200+50
	make/O/N=(NumPntsInSLDPlot) SLDThicknessWv, SLDProfile
	//need 8 parameters to start with - numLayers, scale, TopSLD_real, TopSLD_Imag, Bot_SLD_real, BotSLD_imag, Background, SubstareRoughness, and then 4 parameters for each layer 
	// thickness, re_SLD, imag_SLD and roughness
	variable NumPointsNeeded= NumberOfLayers * 4 + 8
	
	make/O/N=(NumPointsNeeded) SLDParametersIn
	//now let's fill this in
	SLDParametersIn[0] = NumberOfLayers
	NVAR ScalingFactor=root:Packages:Refl_SimpleTool:ScalingFactor
	NVAR SLD_Real_Top=root:Packages:Refl_SimpleTool:SLD_Real_Top
	NVAR SLD_Imag_Top=root:Packages:Refl_SimpleTool:SLD_Imag_Top
	NVAR SLD_Real_Bot=root:Packages:Refl_SimpleTool:SLD_Real_Bot
	NVAR SLD_Imag_Bot=root:Packages:Refl_SimpleTool:SLD_Imag_Bot
	NVAR Background=root:Packages:Refl_SimpleTool:Background
	NVAR Roughness_Bot=root:Packages:Refl_SimpleTool:Roughness_Bot	
	NVAR L1AtTheBottom=root:Packages:Refl_SimpleTool:L1AtTheBottom
	
	SLDParametersIn[1] = ScalingFactor		
	SLDParametersIn[2] = SLD_Real_Top
	SLDParametersIn[3] = SLD_Imag_Top
	SLDParametersIn[4] = SLD_Real_Bot
	SLDParametersIn[5] = SLD_Imag_Bot
	SLDParametersIn[6] = Background
	SLDParametersIn[7] = Roughness_Bot

	//fix to allow L1 at the bottom
	if(L1AtTheBottom)
		j=0
		for(i=NumberOfLayers;i>=1;i-=1)
			j+=1
			NVAR ThicknessLayer= $("root:Packages:Refl_SimpleTool:ThicknessLayer"+Num2str(i))
			NVAR SLD_real_Layer = $("root:Packages:Refl_SimpleTool:SLD_Real_Layer"+Num2str(i))
			NVAR SLD_imag_Layer = $("root:Packages:Refl_SimpleTool:SLD_Imag_Layer"+Num2str(i))
			NVAR RoughnessLayer = $("root:Packages:Refl_SimpleTool:RoughnessLayer"+Num2str(i))
			SLDParametersIn[7+(j-1)*4+1] =  ThicknessLayer
			SLDParametersIn[7+(j-1)*4+2] =  SLD_real_Layer
			SLDParametersIn[7+(j-1)*4+3] =  SLD_imag_Layer
			SLDParametersIn[7+(j-1)*4+4] =  RoughnessLayer
		endfor
	else
		for(i=1;i<=NumberOfLayers;i+=1)
			NVAR ThicknessLayer= $("root:Packages:Refl_SimpleTool:ThicknessLayer"+Num2str(i))
			NVAR SLD_real_Layer = $("root:Packages:Refl_SimpleTool:SLD_Real_Layer"+Num2str(i))
			NVAR SLD_imag_Layer = $("root:Packages:Refl_SimpleTool:SLD_Imag_Layer"+Num2str(i))
			NVAR RoughnessLayer = $("root:Packages:Refl_SimpleTool:RoughnessLayer"+Num2str(i))
			SLDParametersIn[7+(i-1)*4+1] =  ThicknessLayer
			SLDParametersIn[7+(i-1)*4+2] =  SLD_real_Layer
			SLDParametersIn[7+(i-1)*4+3] =  SLD_imag_Layer
			SLDParametersIn[7+(i-1)*4+4] =  RoughnessLayer
		endfor
	endif


	//setup the thickness scaling... 
	variable zstart
        if (NumberOfLayers==0)
                zstart=-4*abs(Roughness_Bot)	//roughness substrate
        else
 		  NVAR RoughnessLayer = root:Packages:Refl_SimpleTool:RoughnessLayer1
               zstart=-4*abs(RoughnessLayer)	//roughness first layer 
        endif
	  
	variable zend, temp
        
        temp=0
        if (NumberOfLayers==0)
                zend=4*abs(Roughness_Bot)	//roughness substrate
        else    
		for(i=1;i<=NumberOfLayers;i+=1)
			NVAR ThicknessLayer= $("root:Packages:Refl_SimpleTool:ThicknessLayer"+Num2str(i))
			temp+=ThicknessLayer
		endfor            
   		  NVAR RoughnessLayer = root:Packages:Refl_SimpleTool:RoughnessLayer1
           zend=temp+4*abs(RoughnessLayer)
        endif
        variable totalLength = zend - zstart
//        zstart = zstart- floor( 0.04 * totalLength)
//        zend = zend + floor( 0.04 * totalLength)
        zstart = zstart- floor( 0.08 * totalLength)		//seemed too small for Dale
        zend = zend + floor( 0.08 * totalLength)
	SetScale/I x zstart,zend,"", SLDProfile

//	Duplicate/O OriginalQvector, ModelQvector, ModelIntensity
//	ModelIntensity=Calcreflectivity_Imag(ParametersIn,ModelQvector)
//	variable/g plotyp=2
//	ModelIntensity=Motofit_Imag(ParametersIn,ModelQvector)
	SLDProfile = IR2R_SLDplot(SLDParametersIn,x)
	//this has 0 at the top... 
	//Now we may have to flip the top and bottom..
	 NVAR ZeroAtTheSubstrate=root:Packages:Refl_SimpleTool:ZeroAtTheSubstrate
	if(ZeroAtTheSubstrate)
		SetScale/I x zend,zstart,"", SLDProfile
	endif 
	setDataFolder OldDf
	
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


static Function IR2R_SLDplot(w,z)
	Wave w
	Variable z
	
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
//	Wave SLDThicknessWv=root:Packages:Refl_SimpleTool:SLDThicknessWv
//	variable  SLDpts=numpnts(SLDThicknessWv)
	
	variable nlayers,SLD1,SLD2,zstart,zend,ii,temp,zinc,summ,deltarho,zi,dindex,sigma,thick,dist,rhotop


////This function calculates the SLD profile.  
	nlayers=w[0]
	rhotop=w[3]
		dist=0
		summ=w[2]		//SLDTop
		ii=0
		do
			if(ii==0)
				//SLD1=(w[7]/100)*(100-w[8])+(w[8]*rhosolv/100) 	original...
				SLD1=w[9]
				deltarho=-w[2]+SLD1
				thick=0
				if(nlayers==0)
					sigma=abs(w[7])		//substrate roughness
					//deltarho=-w[2]+w[3]	//SLD substrate and top
					deltarho=-w[2]+w[4]	//SLD substrate and top
				else
					//sigma=abs(w[9])
					sigma=abs(w[11])		//roughness first layer
//					deltarho=-w[2]+w[4]	//SLD substrate and first layer
				endif
			elseif(ii==nlayers)
				//SLD1=(w[4*ii+3]/100)*(100-w[4*ii+4])+(w[4*ii+4]*rhosolv/100)
				SLD1=(w[7+(ii-1)*4+2])
				SLD2=w[4]			//substrate
				//deltarho=-SLD1+rhosolv
				deltarho=-SLD1+SLD2
				//thick=abs(w[4*ii+2])
				//sigma=abs(w[5])
				thick=abs(w[7+(ii-1)*4+1])
				sigma=abs(w[7])
			else
				//SLD1=(w[4*ii+3]/100)*(100-w[4*ii+4])+(w[4*ii+4]*rhosolv/100)
				//SLD2=(w[4*(ii+1)+3]/100)*(100-w[4*(ii+1)+4])+(w[4*(ii+1)+4]*rhosolv/100)
				//deltarho=-SLD1+SLD2
				//thick=abs(w[4*(ii)+2])
				//sigma=abs(w[4*(ii+1)+5])
				SLD1=(w[7+(ii-1)*4+2])
				SLD2=(w[7+(ii)*4+2])
				deltarho=-SLD1+SLD2
				thick=abs(w[7+(ii-1)*4+1])
				sigma=abs(w[7+(ii)*4+4])
			endif
			
			
			dist+=thick
			
			
			//if sigma=0 then the computer goes haywire (division by zero), so say it's vanishingly small
			if(sigma==0)
				sigma+=1e-3
			endif
			summ+=(deltarho/2)*(1+erf((z-dist)/(sigma*sqrt(2))))
			
			
			ii+=1
		while(ii<nlayers+1)
		        
		return summ
End


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

static Function IR2R_CalculateReflectivityNewRW(w, RR, qq, dq)
	Wave w, RR, qq, dq
	variable bkg

#if	Exists("Abeles_imagALl")
	
	NVAR UseResolutionWave = root:Packages:Refl_SimpleTool:UseResolutionWave	
	make/free/d/n=(numpnts(qq), 2) xtemp
	xtemp[][0] = qq[p]
	//Abeles expects the resolution wave to be in %
	if(UseResolutionWave==1)		//old % input
		xtemp[][1] = dq[p]*qq[p]/100
	elseif(UseResolutionWave==2)		//dq input
		xtemp[][1] = dq[p]
	elseif(UseResolutionWave==3)		//dq^2 input
		xtemp[][1] = sqrt(dq[p])			
	else
		Abort "Error in IR2R_CalculateReflectivityNewRW, unknown resolution type"
	endif
	
	//let's try to check if we need _imag or not... 
	//imag	-> no imag
	//w[0]	-> w[0]   num layers
	//w[1]	-> w[1]		scale
	//w[2]	-> w[2]		sldtop
	//w[3]	.....			imag sld top
	//w[4]	-> w[3]		sld base
	//w[5]  .....			imag sld base
	//w[6]	-> w[4]		backg.
	//w[7]	-> w[5]		rough base
	//w[8] 	-> w[6]		thick 1
	//w[9]	-> w[7]		sld1
	//w[10]		...		imag sld 1
	//w[11]	-> w[8]		rough 1
	//and repeat 8-11
	variable oldWlength=numpnts(w)
	variable newWlength=6 + (oldWlength-8)/4
	//check if something imag is there...
	variable ImagVals=0
	variable i
	if(w[3]>0 || w[5]>0)
		ImagVals=1
	endif
	For(i=10;i<oldWlength;i+=4)
		if(w[i]>0)
			ImagVals=1
			break
		endif
	endfor	
	if(ImagVals)
//	print "used imag"
		bkg = abs(w[6])
		w[6] = 0
		Abeles_imagALl(w, RR, xtemp)
		w[6] = bkg
		fastop RR = (bkg) + RR
	else //no imag values...
		bkg = abs(w[6])
		w[6] = 0
		Abeles_imagALl(w, RR, xtemp)
		w[6] = bkg
		fastop RR = (bkg) + RR
	endif
#else
		Abort "Reflectivity (Abeles) xop not installed, this feature is not available. Use one of the installers and install the xop support before using this feature."
#endif	
	
End

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

static Function IR2R_CalculateReflectivityNew(w,RR,qq, resolution) 
	Wave w, RR,qq
	variable resolution

#if	Exists("Abeles_imagALl")

	variable mode, bkg
	variable plotyp 
	plotyp = 1
			
	if(numtype(resolution) || resolution < 0.5)
		resolution = 0
	endif
		
	bkg = abs(w[6])
	w[6] = 0
//	markperftesttime 1			
	if(resolution > 0.5)
		//make it an odd number
		resolution/=100
		Variable gaussnum=13

		Make/free/d/n=(gaussnum) gausswave
		Setscale/I x, -resolution, resolution, gausswave
		Gausswave=gauss(x, 0, resolution/(2 * sqrt(2 * ln(2))))
		Variable middle = gausswave[x2pnt(gausswave, 0)]
		 Gausswave /= middle
		Variable gaussgpoint = (gaussnum-1)/2
				
		//find out what the lowest and highest qvalue are
		variable lowQ = wavemin(qq)
		variable highQ = wavemax(qq)
		
		if(lowQ == 0)
			lowQ =1e-6
		endif
		
		Variable start=log(lowQ) - 6 * resolution / 2.35482
		Variable finish=log(highQ * (1 + 6 * resolution / 2.35482))
		Variable interpnum=round(abs(1 * (abs(start - finish)) / (resolution / 2.35482 / gaussgpoint)))
		variable val = (abs(start - finish)) / (interpnum)
		make/free/d/n=(interpnum) ytemp, xtemp
		multithread xtemp=(start) + p * val

		matrixop/o xtemp = powR(10, xtemp)

//		markperftesttime 2

		Abeles_imagALl(w, ytemp, xtemp)
//		markperftesttime 3
		//do the resolution convolution
		setscale/I x, start, log(xtemp[numpnts(xtemp) - 1]), ytemp
		convolve/A gausswave, ytemp

		//delete start and finish nodes.
		variable number2d = round(6 * (resolution / 2.35482) / ((abs(start - finish)) / (interpnum))) - 1 
		variable left = leftx(ytemp), space = deltax(ytemp)
		deletepoints 0, number2d, ytemp
		setscale/P x, left + (number2d * space), space, ytemp
		
		variable gaussum = 1/(sum(gausswave))
		fastop ytemp = (gaussum) * ytemp

//		markperftesttime 4
		matrixop/free xrtemp = log(qq)
		duplicate/free rr, ytemp2
		//interpolate to get the theoretical points at the same spacing of the real dataset
//		markperftesttime 5
		Interpolate2/T=2/E=2/I=3/Y=ytemp2/X=xrtemp ytemp
		multithread RR = ytemp2
//		markperftesttime 6

	else 
		Abeles_imagALl(w, RR, qq)
	endif

	//add in the linear background again
	w[6] = bkg
	fastop RR = (bkg) + RR
#else
		Abort "Reflectivity (Abeles) xop not installed, this feature is not available. Use one of the installers and install the xop support before using this feature."
#endif		

End


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

static Function IR2R_CalculateReflectivity(w,x, res) 
	Wave w
	variable x, res
	Variable dq,reflectivity
	
	duplicate/o w call
	Wave call
	call[6]=0
	dq=x*(res/100)

#if Exists("Abeles_imag")	
	reflectivity=Abeles_imag(call,x)
	if(dq>0)
		reflectivity+=0.135*Abeles_imag(call,x-dq)
		reflectivity+=0.135*Abeles_imag(call,x+dq)
		reflectivity+=0.325*Abeles_imag(call,x-(dq*0.75))
		reflectivity+=0.325*Abeles_imag(call,x+(dq*0.75))
		reflectivity+=0.605*Abeles_imag(call,x-(dq/2))
		reflectivity+=0.605*Abeles_imag(call,x+(dq/2))
		reflectivity+=0.88*Abeles_imag(call,x-(dq/4))
		reflectivity+=0.88*Abeles_imag(call,x+(dq/4))
		reflectivity/=4.89
	endif
#else
	reflectivity=IR2R_CalculateReflectivityInt(call,x)
	if(dq>0)
		reflectivity+=0.135*IR2R_CalculateReflectivityInt(call,x-dq)
		reflectivity+=0.135*IR2R_CalculateReflectivityInt(call,x+dq)
		reflectivity+=0.325*IR2R_CalculateReflectivityInt(call,x-(dq*0.75))
		reflectivity+=0.325*IR2R_CalculateReflectivityInt(call,x+(dq*0.75))
		reflectivity+=0.605*IR2R_CalculateReflectivityInt(call,x-(dq/2))
		reflectivity+=0.605*IR2R_CalculateReflectivityInt(call,x+(dq/2))
		reflectivity+=0.88*IR2R_CalculateReflectivityInt(call,x-(dq/4))
		reflectivity+=0.88*IR2R_CalculateReflectivityInt(call,x+(dq/4))
		reflectivity/=4.89
	endif
#endif


	reflectivity+=abs(w[6])
	
	Killwaves/Z kzn,rn,rrn
	
	return reflectivity
End

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
//static Function IR2R_CalcReflectivitySwitch(w,x)
//	Wave w
//	Variable x
//
////	//if we can use the xop here and skip the rest. This should be basically transparent to user, if we can get the xop function...
////	//
//
//	if(exists("Abeles_imag")==3)
//	   Funcref IR2R_CalculateReflectivityInt f=$"Abeles_imag"
//	else
//	   Funcref IR2R_CalculateReflectivityInt f=IR2R_CalculateReflectivityInt
//	endif
//
//	variable y
//	y=f(w,x)
//
//	return y
//end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

static Function IR2R_CalculateReflectivityInt(w,x) //:fitfunc
	Wave w
	Variable x
	
	Variable reflectivity,ii,nlayers,inter,qq,scale,bkg,subrough
	Variable/C super,sub,arg,cinter,SLD
	
	//number of layers,re_SUPERphaseSLD,imag_SUPER,re_SUBphaseSLD,imag_SUB
	
	//subsequent layers have 4 parameters each: thickness, re_SLD, imag_SLD and roughness
	//if you increase the number of layers you have to put extra parameters in.
	//you should be able to remember the order in which they go.
	
	
	//Layer 1 is always closest to the SUPERPHASE (e.g. air).  increasing layers go down 
	//towards the subphase.  This may be confusing if you switch between air-solid and solid-liquid
	//I will write some functions to create exotic SLD profiles if required.
	
	
	nlayers=w[0]
	scale=w[1]
	super=cmplx(w[2]*1e-6,-abs(w[3]))			// JI 3/306 this fixes some problems - f" is negative and hence the SLD imaginary part should be also...
	sub=cmplx(w[4]*1e-6,-abs(w[5]))			// JI 3/306 this fixes some problems - f" is negative and hence the SLD imaginary part should be also...
	bkg=abs(w[6])
	subrough=w[7]
	qq=x
	
	//for definitions of these see Parratt handbook
	Make/o/d/C/n=(nlayers+2) kzn
	Make/o/d/C/n=(nlayers+2) rn
	Make/o/d/C/n=(nlayers+2) RRN
	
	//workout the wavevector in the incident medium/superphase
	inter=cabs(sqrt((qq/2)^2))
	kzn[0]=cmplx(inter,0)
	
	//workout the wavevector in the subphase
	kzn[nlayers+1]=sqrt(kzn[0]^2-4*Pi*(sub-super))
	
	//workout the wavevector in each of the layers
	ii=1
	if(ii<nlayers+1)
		do
	//	 SLD=cmplx(w[4*ii+5],w[4*ii+6])			//original
		 SLD=cmplx(w[4*ii+5]*1e-6,-abs(w[4*ii+6]))			// JI 3/306 this fixes some problems - f" is negative and hence the SLD imaginary part should be also...
		 
		 cinter=sqrt(kzn[0]^2-4*Pi*(SLD-super))		//this bit is important otherwise the SQRT doesn't work on the complex number
		 kzn[ii]=(cinter)
		 ii+=1
		while(ii<nlayers+1)
	endif
	
	//RRN[subphase]=0,RRN[subphase-1]=fresnel reflectance of n, subphase
	RRN[nlayers+1]=cmplx(0,0)
	RRN[nlayers]=(kzn[nlayers]-kzn[nlayers+1])/(kzn[nlayers]+kzn[nlayers+1])
	arg=-2*kzn[nlayers]*kzn[nlayers+1]*subrough^2
	RRN[nlayers]*=exp(arg)
	
	//work out the fresnel reflectance for the layer then calculate the total reflectivity from each layer
	ii=nlayers-1
	do
		//work out the fresnel reflectance for each layer
		rn[ii]=(kzn[ii]-kzn[ii+1])/(kzn[ii]+kzn[ii+1])
		arg=-2*kzn[ii]*kzn[ii+1]*w[4*(ii+1)+7]^2
		rn[ii]*=exp(arg)
		//now work out the total reflectivity from the layer
		arg=cmplx(0,2*abs(w[4*(ii+1)+4]))
		arg*=(kzn[ii+1])
		RRN[ii]=rn[ii]+RRN[ii+1]*exp(arg)
		RRN[ii]/=1+rn[ii]*RRN[ii+1]*exp(arg)
		
		ii-=1
	while(ii>-1)
	
	//reflectivity=abs(Ro)^2
	reflectivity=magsqr(RRN[0])
	reflectivity*=scale
	reflectivity+=bkg
	
	
//	reflectivity=(reflectivity)
	
	return reflectivity
	
End


//Control procedures for simple tool Mottfit 
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

static Function IR2R_UpdateLinkedVariables()

	string ListOfVariables="SLD_Real_Layer;SLD_Imag_Layer;ThicknessLayer;RoughnessLayer;"
	variable i, j
	string tempVarName
	For(i=1;i<=8;i+=1)
		For(j=0;j<ItemsInList(ListOfVariables);j+=1)
			tempVarName = stringFromList(j, ListOfVariables)
			NVAR ValueVar=$("root:Packages:Refl_SimpleTool:"+tempVarName+num2str(i))
			NVAR LinkVar=$("root:Packages:Refl_SimpleTool:Link"+tempVarName+num2str(i))
			NVAR LinkFractionVar=$("root:Packages:Refl_SimpleTool:LinkF"+tempVarName+num2str(i))
			NVAR LinkToVar=$("root:Packages:Refl_SimpleTool:LinkTo"+tempVarName+num2str(i))
			if(LinkVar && LinkToVar>0 && LinkToVar!=i)
				NVAR LinkedVarVal = $("root:Packages:Refl_SimpleTool:"+tempVarName+num2str(LinkToVar))
				ValueVar = LinkedVarVal * LinkFractionVar
			endif
		endfor
	endfor
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_PanelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	variable currentVar

	if (stringmatch(ctrlName,"LinkF*"))
		IR2R_UpdateLinkedVariables()
	endif
	if (stringmatch(ctrlName,"ThicknessLayer*") && !stringmatch(ctrlName,"*Step*") && !stringmatch(ctrlName,"*LL*") && !stringmatch(ctrlName,"*UL*"))
		currentVar=str2num(ctrlName[14,inf])
		NVAR ThicknessLayer=$("root:Packages:Refl_SimpleTool:ThicknessLayer"+num2str(currentVar))
		NVAR ThicknessLayerLL=$("root:Packages:Refl_SimpleTool:ThicknessLayerLL"+num2str(currentVar))
		NVAR ThicknessLayerUL=$("root:Packages:Refl_SimpleTool:ThicknessLayerUL"+num2str(currentVar))
		ThicknessLayerLL = ThicknessLayer/2
		ThicknessLayerUL = ThicknessLayer*2
		Slider $("ThicknessLayerSl"+num2str(currentVar)), limits={(ThicknessLayerLL),(ThicknessLayerUL),0}
		//and impose limit on roughness...
		NVAR RoughnessLayerUL=$("root:Packages:Refl_SimpleTool:RoughnessLayerUL"+num2str(currentVar))
		if(RoughnessLayerUL>ThicknessLayer/2.38)
			RoughnessLayerUL = ThicknessLayer/2.38
		endif
	endif
	if (stringmatch(ctrlName,"ThicknessLayerLL*") || stringmatch(ctrlName,"ThicknessLayerUL*"))
		currentVar=str2num(ctrlName[16,inf])
		NVAR ThicknessLayerLL=$("root:Packages:Refl_SimpleTool:ThicknessLayerLL"+num2str(currentVar))
		NVAR ThicknessLayerUL=$("root:Packages:Refl_SimpleTool:ThicknessLayerUL"+num2str(currentVar))
		Slider $("ThicknessLayerSl"+num2str(currentVar)), limits={(ThicknessLayerLL),(ThicknessLayerUL),0}
	endif
		
	if (stringmatch(ctrlName,"SLD_Real_Layer*") && !stringmatch(ctrlName,"*Step*") && !stringmatch(ctrlName,"*LL*") && !stringmatch(ctrlName,"*UL*"))
		currentVar=str2num(ctrlName[14,inf])
		NVAR SLD_Real_Layer=$("root:Packages:Refl_SimpleTool:SLD_Real_Layer"+num2str(currentVar))
		NVAR SLD_Real_LayerLL=$("root:Packages:Refl_SimpleTool:SLD_Real_LayerLL"+num2str(currentVar))
		NVAR SLD_Real_LayerUL=$("root:Packages:Refl_SimpleTool:SLD_Real_LayerUL"+num2str(currentVar))
		SLD_Real_LayerLL = SLD_Real_Layer/2
		SLD_Real_LayerUL = SLD_Real_Layer*2
		Slider $("SLD_Real_LayerSl"+num2str(currentVar)), limits={(SLD_Real_LayerLL),(SLD_Real_LayerUL),0}
	endif
	if (stringmatch(ctrlName,"SLD_Real_LayerLL*") || stringmatch(ctrlName,"SLD_Real_LayerUL*"))
		currentVar=str2num(ctrlName[16,inf])
		NVAR SLD_Real_LayerLL=$("root:Packages:Refl_SimpleTool:SLD_Real_LayerLL"+num2str(currentVar))
		NVAR SLD_Real_LayerUL=$("root:Packages:Refl_SimpleTool:SLD_Real_LayerUL"+num2str(currentVar))
		Slider $("SLD_Real_LayerSl"+num2str(currentVar)), limits={(SLD_Real_LayerLL),(SLD_Real_LayerUL),0}
	endif


	if (stringmatch(ctrlName,"SLD_Imag_Layer*")&& !stringmatch(ctrlName,"*Step*") && !stringmatch(ctrlName,"*LL*") && !stringmatch(ctrlName,"*UL*"))
		currentVar=str2num(ctrlName[14,inf])
		NVAR SLD_Imag_Layer=$("root:Packages:Refl_SimpleTool:SLD_Imag_Layer"+num2str(currentVar))
		NVAR SLD_Imag_LayerLL=$("root:Packages:Refl_SimpleTool:SLD_Imag_LayerLL"+num2str(currentVar))
		NVAR SLD_Imag_LayerUL=$("root:Packages:Refl_SimpleTool:SLD_Imag_LayerUL"+num2str(currentVar))
		SLD_Imag_LayerLL = SLD_Imag_Layer/2
		SLD_Imag_LayerUL = SLD_Imag_Layer*2
		Slider $("SLD_Imag_LayerSl"+num2str(currentVar)), limits={(SLD_Imag_LayerLL),(SLD_Imag_LayerUL),0}
	endif
	if (stringmatch(ctrlName,"SLD_Imag_LayerLL*")||stringmatch(ctrlName,"SLD_Imag_LayerUL*"))
		currentVar=str2num(ctrlName[16,inf])
		NVAR SLD_Imag_LayerLL=$("root:Packages:Refl_SimpleTool:SLD_Imag_LayerLL"+num2str(currentVar))
		NVAR SLD_Imag_LayerUL=$("root:Packages:Refl_SimpleTool:SLD_Imag_LayerUL"+num2str(currentVar))
		Slider $("SLD_Imag_LayerSl"+num2str(currentVar)), limits={(SLD_Imag_LayerLL),(SLD_Imag_LayerUL),0}
	endif

	if (stringmatch(ctrlName,"RoughnessLayer*")&& !stringmatch(ctrlName,"*Step*") && !stringmatch(ctrlName,"*LL*") && !stringmatch(ctrlName,"*UL*"))
		currentVar=str2num(ctrlName[14,inf])
		NVAR RoughnessLayer=$("root:Packages:Refl_SimpleTool:RoughnessLayer"+num2str(currentVar))
		NVAR RoughnessLayerLL=$("root:Packages:Refl_SimpleTool:RoughnessLayerLL"+num2str(currentVar))
		NVAR RoughnessLayerUL=$("root:Packages:Refl_SimpleTool:RoughnessLayerUL"+num2str(currentVar))
		NVAR ThicknessLayer=$("root:Packages:Refl_SimpleTool:ThicknessLayer"+num2str(currentVar))
		RoughnessLayerLL = RoughnessLayer/2
		RoughnessLayerUL = RoughnessLayer*2
		Slider $("RoughnessLayerSl"+num2str(currentVar)), limits={(RoughnessLayerLL),(RoughnessLayerUL),0}
	endif
	if (stringmatch(ctrlName,"RoughnessLayerLL*")||stringmatch(ctrlName,"RoughnessLayerUL*") )
		currentVar=str2num(ctrlName[16,inf])
		NVAR RoughnessLayerLL=$("root:Packages:Refl_SimpleTool:RoughnessLayerLL"+num2str(currentVar))
		NVAR RoughnessLayerUL=$("root:Packages:Refl_SimpleTool:RoughnessLayerUL"+num2str(currentVar))
		Slider $("RoughnessLayerSl"+num2str(currentVar)), limits={(RoughnessLayerLL),(RoughnessLayerUL),0}
	endif
	if (stringmatch(ctrlName,"Roughness_Bot")&& !stringmatch(ctrlName,"*Step*") && !stringmatch(ctrlName,"*LL*") && !stringmatch(ctrlName,"*UL*"))
		NVAR Roughness_Bot=root:Packages:Refl_SimpleTool:Roughness_Bot
		NVAR Roughness_BotLL=root:Packages:Refl_SimpleTool:Roughness_BotLL
		NVAR Roughness_BotUL=root:Packages:Refl_SimpleTool:Roughness_BotUL
		Roughness_BotLL = Roughness_Bot/2
		Roughness_BotUL = Roughness_Bot*2
	endif
	if (stringmatch(ctrlName,"Background")&& !stringmatch(ctrlName,"*Step*") && !stringmatch(ctrlName,"*LL*") && !stringmatch(ctrlName,"*UL*"))
		NVAR Background=root:Packages:Refl_SimpleTool:Background
		NVAR BackgroundLL=root:Packages:Refl_SimpleTool:BackgroundLL
		NVAR BackgroundUL=root:Packages:Refl_SimpleTool:BackgroundUL
		BackgroundLL = Background/2
		BackgroundUL = Background*2
	endif
	if (stringmatch(ctrlName,"ScalingFactor")&& !stringmatch(ctrlName,"*Step*") && !stringmatch(ctrlName,"*LL*") && !stringmatch(ctrlName,"*UL*"))
		NVAR ScalingFactor=root:Packages:Refl_SimpleTool:ScalingFactor
		NVAR ScalingFactorLL=root:Packages:Refl_SimpleTool:ScalingFactorLL
		NVAR ScalingFactorUL=root:Packages:Refl_SimpleTool:ScalingFactorUL
		ScalingFactorLL = ScalingFactor/2
		ScalingFactorUL = ScalingFactor*2
	endif

//	ListOfVariables="Background;Roughness_Bot;ScalingFactor;"

	if (stringmatch(ctrlName,"ThicknessLayerStep*"))
		currentVar=str2num(ctrlName[18,inf])
		NVAR TmpVar=$("root:Packages:Refl_SimpleTool:ThicknessLayerStep"+num2str(currentVar))
		SetVariable $("ThicknessLayer"+num2str(currentVar)),limits={0,inf,TmpVar},win=IR2R_ReflSimpleToolMainPanel
	endif
	if (stringmatch(ctrlName,"SLD_Real_LayerStep*"))
		currentVar=str2num(ctrlName[18,inf])
		NVAR TmpVar=$("root:Packages:Refl_SimpleTool:SLD_Real_LayerStep"+num2str(currentVar))
		SetVariable $("SLD_Real_Layer"+num2str(currentVar)),limits={-inf,inf,TmpVar},win=IR2R_ReflSimpleToolMainPanel
	endif
	if (stringmatch(ctrlName,"SLD_Imag_LayerStep*"))
		currentVar=str2num(ctrlName[18,inf])
		NVAR TmpVar=$("root:Packages:Refl_SimpleTool:SLD_Imag_LayerStep"+num2str(currentVar))
		SetVariable $("SLD_Imag_Layer"+num2str(currentVar)),limits={-inf,inf,TmpVar},win=IR2R_ReflSimpleToolMainPanel
	endif
	
	if (stringmatch(ctrlName,"RoughnessLayerStep*"))
		currentVar=str2num(ctrlName[18,inf])
		NVAR TmpVar=$("root:Packages:Refl_SimpleTool:RoughnessLayerStep"+num2str(currentVar))
		SetVariable $("RoughnessLayer"+num2str(currentVar)),limits={0,inf,TmpVar},win=IR2R_ReflSimpleToolMainPanel
	endif

	if (cmpstr(ctrlName,"BackgroundStep")==0)
	//	currentVar=str2num(ctrlName[18,inf])
		NVAR BackgroundStep=$("root:Packages:Refl_SimpleTool:BackgroundStep")
		SetVariable Background,limits={0,inf,BackgroundStep},win=IR2R_ReflSimpleToolMainPanel
	endif

	if (!stringmatch(ctrlName,"*Step*") && !stringmatch(ctrlName,"*LL*") && !stringmatch(ctrlName,"*UL*"))
		NVAR AutoUpdate=root:Packages:Refl_SimpleTool:AutoUpdate
		if (AutoUpdate)
			IR2R_CalculateModelResults()
			IR2R_CalculateSLDProfile()
			IR2R_GraphModelResults()		
		endif
	endif	
	DoWindow /F IR2R_ReflSimpleToolMainPanel
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2R_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	variable tempVal
	string tempStr
	
	if (stringmatch(ctrlName,"Link*"))
		tempVal=str2num(ctrlName[18,inf])
		if(checked)
			NVAR FitVar = $("root:Packages:Refl_SimpleTool:"+ReplaceString("Link", ctrlName, "Fit"))
			NVAR VarValue = $("root:Packages:Refl_SimpleTool:"+ ReplaceString("Link", ctrlName, ""))
			NVAR LinkToVar = $("root:Packages:Refl_SimpleTool:"+ReplaceString("Link", ctrlName, "LinkTo"))
			NVAR LinkFracVar = $("root:Packages:Refl_SimpleTool:"+ReplaceString("Link", ctrlName, "LinkF"))
			FitVar=0
			if(LinkToVar>0 && LinkToVar!=tempVal)
				//tempStr=ReplaceString("Link", ctrlName, "")
				//print tempStr[0,13]
				NVAR LinkedToVarValue = $("root:Packages:Refl_SimpleTool:"+ ReplaceString("Link", ctrlName, "")[0,13]+num2str(LinkToVar))
				LinkFracVar = VarValue/LinkedToVarValue
			endif
		endif
		IR2R_TabPanelControl("",tempVal-1)
		IR2R_UpdateLinkedVariables()
	endif

	NVAR AutoUpdate=root:Packages:Refl_SimpleTool:AutoUpdate
	if ( (stringmatch(ctrlName,"OversampleModel")  || (stringmatch(ctrlName,"Link*") || cmpstr(ctrlName,"AutoUpdate")==0 ||  cmpstr(ctrlName,"L1AtTheBottom")==0 ||  cmpstr(ctrlName,"ZeroAtTheSubstrate")==0 ) && AutoUpdate))
		IR2R_CalculateModelResults()
		IR2R_CalculateSLDProfile()
		IR2R_GraphModelResults()		
	endif
	if (cmpstr(ctrlName,"UseErrors")==0)
		Execute ("PopupMenu ErrorDataName, disable=!root:Packages:Refl_SimpleTool:UseErrors, win=IR2R_ReflSimpleToolMainPanel")
	endif
	if (cmpstr(ctrlName,"UseResolutionWave")==0)
		Execute ("PopupMenu ResolutionWaveName, disable=!root:Packages:Refl_SimpleTool:UseResolutionWave, win=IR2R_ReflSimpleToolMainPanel")
		Execute ("SetVariable Resolution, disable=root:Packages:Refl_SimpleTool:UseResolutionWave, win=IR2R_ReflSimpleToolMainPanel")
	endif
	if (cmpstr(ctrlName,"ZeroAtTheSubstrate")==0)
		DoWindow IR2R_SLDProfile
		if(V_Flag)
			NVAR ZeroAtTheSubstrate=root:Packages:Refl_SimpleTool:ZeroAtTheSubstrate
			DoWindow/F IR2R_SLDProfile
			if(ZeroAtTheSubstrate)
				Label bottom "<<--Substrate                                               Layer thickness [A]                                         Top -->>"
				DoWindow/T IR2R_SLDProfile,"SLD profile (substrate=left,  top=right) "
			else
				Label bottom "<<--TOP                                               Layer thickness [A]                                         Substrate -->>"
				DoWindow/T IR2R_SLDProfile,"SLD profile (top=left, substrate=right) "
			endif
			IR2R_CalculateSLDProfile()
		endif
	endif
	if ((stringmatch(ctrlName,"Fit*"))&& !StringMatch(ctrlName, "*Background*" ) && !StringMatch(ctrlName,"*Roughness_Bot*") && !StringMatch(ctrlName,"*ScalingFactor*"))
		if(checked )
			NVAR LinkVar = $("root:Packages:Refl_SimpleTool:"+ReplaceString("Fit", ctrlName, "Link"))
			LinkVar=0
		endif
		tempVal=str2num(ctrlName[17,inf])
		IR2R_TabPanelControl("",tempVal-1)
	endif


	NVAR UseGeneticOptimization=root:Packages:Refl_SimpleTool:UseGenOpt
	NVAR UseLSQF=root:Packages:Refl_SimpleTool:UseLSQF
	if (stringMatch(ctrlName,"UseGenOpt"))
		UseGeneticOptimization=1
		UseLSQF=0
	endif
	if (stringMatch(ctrlName,"UseLSQF"))
		UseLSQF=1
		UseGeneticOptimization=0
	endif
	DoWindow /F IR2R_ReflSimpleToolMainPanel	
	setDataFolder OldDf
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	
	NVAR ActiveTab=root:Packages:Refl_SimpleTool:ActiveTab
	NVAR NumberOfLayers=root:Packages:Refl_SimpleTool:NumberOfLayers
	ControlInfo /W=IR2R_ReflSimpleToolMainPanel DistTabs
	ActiveTab = V_value

	if (cmpstr(ctrlName,"NumberOfLevels")==0)
		NumberOfLayers=str2num(popStr)
		if (NumberOfLayers<ActiveTab)
			ActiveTab=0
			//IR2R_TabPanelControl("",ActiveTab)
			TabControl DistTabs,value= 0, win=IR2R_ReflSimpleToolMainPanel
		endif
		IR2R_CalculateModelResults()
		IR2R_CalculateSLDProfile()
		IR2R_GraphModelResults()		
		IR2R_TabPanelControl("",ActiveTab)
	endif
	
	if (cmpstr(ctrlName,"FitIQN")==0)
		NVAR FitIQN=root:Packages:Refl_SimpleTool:FitIQN
		FitIQN = str2num(popStr)	
		Wave/Z OInt=root:Packages:Refl_SimpleTool:OriginalIntensity
		Wave/Z OQvec=root:Packages:Refl_SimpleTool:OriginalQvector
		Wave/Z OErr=root:Packages:Refl_SimpleTool:OriginalError
		Wave/Z NInt=root:Packages:Refl_SimpleTool:IntensityQN
		Wave/Z NQvec=root:Packages:Refl_SimpleTool:QvectorToN
		Wave/Z NErr=root:Packages:Refl_SimpleTool:ErrorQN
		if(WaveExists(OInt) &&WaveExists(OQvec) &&WaveExists(NInt) &&WaveExists(NQvec) )
			NInt= OInt * OQvec^FitIQN
		endif
		if(WaveExists(OErr) &&WaveExists(OQvec) &&WaveExists(NErr) &&WaveExists(NQvec) )
			NErr = OErr * OQvec^FitIQN
		endif
		IR2R_CalculateModelResults()
		IR2R_CalculateSLDProfile()
		IR2R_GraphModelResults()		
	endif

	if (cmpstr(ctrlName,"ResolutionType")==0)
		NVAR UseResolutionWave=root:Packages:Refl_SimpleTool:UseResolutionWave
		UseResolutionWave = popNum-1
		Execute ("PopupMenu ResolutionWaveName, disable=!root:Packages:Refl_SimpleTool:UseResolutionWave, win=IR2R_ReflSimpleToolMainPanel")
		Execute ("SetVariable Resolution, disable=root:Packages:Refl_SimpleTool:UseResolutionWave, win=IR2R_ReflSimpleToolMainPanel")
	endif

	if (cmpstr(ctrlName,"ResolutionWaveName")==0)
		SVAR ResolutionWaveName=root:Packages:Refl_SimpleTool:ResolutionWaveName
		if(stringmatch("Create From Parameters",popStr))
			ResolutionWaveName="CreatedFromParamaters"
			IR2R_CreateResolutionWave()
		else
			ResolutionWaveName=possiblyQUoteName(popstr)
		endif
	endif
	if (stringmatch(ctrlName,"LinkToThicknessLayer*"))
		NVAR LinkToThicknessLayer=$("root:Packages:Refl_SimpleTool:"+ctrlName)
		LinkToThicknessLayer = str2num(popStr)
		NVAR VarValue = $("root:Packages:Refl_SimpleTool:"+ ReplaceString("LinkTo", ctrlName, ""))
		NVAR LinkToVar = $("root:Packages:Refl_SimpleTool:"+ctrlName)
		NVAR LinkFracVar = $("root:Packages:Refl_SimpleTool:"+ReplaceString("LinkTo", ctrlName, "LinkF"))
		if(LinkToVar>0)
			NVAR LinkedToVarValue = $("root:Packages:Refl_SimpleTool:"+ ReplaceString("LinkTo", ctrlName, "")[0,13]+num2str(LinkToVar))
			LinkFracVar = VarValue/LinkedToVarValue
		endif
		IR2R_UpdateLinkedVariables()
	endif
	if (stringmatch(ctrlName,"LinkToSLD_Real_Layer*"))
		NVAR LinkToThicknessLayer=$("root:Packages:Refl_SimpleTool:"+ctrlName)
		LinkToThicknessLayer = str2num(popStr)
		NVAR VarValue = $("root:Packages:Refl_SimpleTool:"+ ReplaceString("LinkTo", ctrlName, ""))
		NVAR LinkToVar = $("root:Packages:Refl_SimpleTool:"+ctrlName)
		NVAR LinkFracVar = $("root:Packages:Refl_SimpleTool:"+ReplaceString("LinkTo", ctrlName, "LinkF"))
		if(LinkToVar>0)
			NVAR LinkedToVarValue = $("root:Packages:Refl_SimpleTool:"+ ReplaceString("LinkTo", ctrlName, "")[0,13]+num2str(LinkToVar))
			LinkFracVar = VarValue/LinkedToVarValue
		endif
		IR2R_UpdateLinkedVariables()
	endif
	if (stringmatch(ctrlName,"LinkToSLD_Imag_Layer*"))
		NVAR LinkToThicknessLayer=$("root:Packages:Refl_SimpleTool:"+ctrlName)
		LinkToThicknessLayer = str2num(popStr)
		NVAR VarValue = $("root:Packages:Refl_SimpleTool:"+ ReplaceString("LinkTo", ctrlName, ""))
		NVAR LinkToVar = $("root:Packages:Refl_SimpleTool:"+ctrlName)
		NVAR LinkFracVar = $("root:Packages:Refl_SimpleTool:"+ReplaceString("LinkTo", ctrlName, "LinkF"))
		if(LinkToVar>0)
			NVAR LinkedToVarValue = $("root:Packages:Refl_SimpleTool:"+ ReplaceString("LinkTo", ctrlName, "")[0,13]+num2str(LinkToVar))
			LinkFracVar = VarValue/LinkedToVarValue
		endif
		IR2R_UpdateLinkedVariables()
	endif
	if (stringmatch(ctrlName,"LinkToRoughnessLayer*"))
		NVAR LinkToThicknessLayer=$("root:Packages:Refl_SimpleTool:"+ctrlName)
		LinkToThicknessLayer = str2num(popStr)
		NVAR VarValue = $("root:Packages:Refl_SimpleTool:"+ ReplaceString("LinkTo", ctrlName, ""))
		NVAR LinkToVar = $("root:Packages:Refl_SimpleTool:"+ctrlName)
		NVAR LinkFracVar = $("root:Packages:Refl_SimpleTool:"+ReplaceString("LinkTo", ctrlName, "LinkF"))
		if(LinkToVar>0)
			NVAR LinkedToVarValue = $("root:Packages:Refl_SimpleTool:"+ ReplaceString("LinkTo", ctrlName, "")[0,13]+num2str(LinkToVar))
			LinkFracVar = VarValue/LinkedToVarValue
		endif
		IR2R_UpdateLinkedVariables()
	endif

	DoWindow/F IR2R_ReflSimpleToolMainPanel
	setDataFolder OldDf

end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2R_TabPanelControl(name,tab)
	String name
	Variable tab

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	
	NVAR ActiveTab=root:Packages:Refl_SimpleTool:ActiveTab
	ActiveTab=tab+1

	NVAR NumberOfLayers=root:Packages:Refl_SimpleTool:NumberOfLayers
	if (NumberOfLayers==0)
		ActiveTab=0
	endif
	//need to kill any outstanding windows for shapes... Any... All should have the same name...
	DoWindow/F IR2R_ReflSimpleToolMainPanel
	NVAR UseResolutionWave=root:Packages:Refl_SimpleTool:UseResolutionWave
	SetVariable Resolution, disable = UseResolutionWave
	PopupMenu ResolutionWaveName,disable=!UseResolutionWave	

	variable i, test1, test2, test3, test4
	For(i=1;i<=8;i+=1)
		//test1=(tab!=(i-1))
		//test2=((tab+1)>NumberOfLayers)
		NVAR FitTh=$("root:Packages:Refl_SimpleTool:FitThicknessLayer"+num2str(i))
		NVAR LinkTh=$("root:Packages:Refl_SimpleTool:LinkThicknessLayer"+num2str(i))
		NVAR FitRSLD=$("root:Packages:Refl_SimpleTool:FitSLD_Real_Layer"+num2str(i))
		NVAR LinkRSLD=$("root:Packages:Refl_SimpleTool:LinkSLD_Real_Layer"+num2str(i))
		NVAR FitISLD=$("root:Packages:Refl_SimpleTool:FitSLD_Imag_Layer"+num2str(i))
		NVAR LinkISLD=$("root:Packages:Refl_SimpleTool:LinkSLD_Imag_Layer"+num2str(i))
		NVAR FitROUGH=$("root:Packages:Refl_SimpleTool:FitRoughnessLayer"+num2str(i))
		NVAR LinkROUGH=$("root:Packages:Refl_SimpleTool:LinkRoughnessLayer"+num2str(i))
		//fix the parameters here...
		if(FitTh)
			LinkTh=0
		endif
		if(linkTh)
			FitTh=0
		endif
		if(FitRSLD)
			LinkRSLD=0
		endif
		if(linkRSLD)
			FitRSLD=0
		endif
		if(FitISLD)
			LinkISLD=0
		endif
		if(linkISLD)
			FitISLD=0
		endif
		if(FitROUGH)
			LinkROUGH=0
		endif
		if(linkROUGH)
			FitROUGH=0
		endif
		if((tab!=(i-1) || (tab+1)>NumberOfLayers))
			test4 =1
		else
			test4=0
		endif
		if(!test4 && LinkTh)
			test3 =2
		else
			test3 =test4
		endif

		//Execute("TitleBox LayerTitleBox"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		TitleBox 		$("LayerTitleBox"+num2str(i)),disable = (test4)
		SetVariable 		$("ThicknessLayer"+num2str(i)),disable = (test3)
		Slider 			$("ThicknessLayerSL"+num2str(i)),disable = (test3)
		SetVariable 		$("ThicknessLayerStep"+num2str(i)),disable = (test3)
		CheckBox 		$("FitThicknessLayer"+num2str(i)),disable = (test4)
		SetVariable 		$("ThicknessLayerLL"+num2str(i)),disable = (test4 || !FitTh)
		SetVariable 		$("ThicknessLayerUL"+num2str(i)),disable = (test4 || !FitTh)
		CheckBox 		$("LinkThicknessLayer"+num2str(i)),disable = (test4)
		NVAR LinkMeTo= $("root:Packages:Refl_SimpleTool:LinkToThicknessLayer"+num2str(i))
		PopupMenu 		$("LinkToThicknessLayer"+num2str(i)),disable = (test4 || !LinkTh), popmatch =num2str(LinkMeTo)
		SetVariable 		$("LinkFThicknessLayer"+num2str(i)),disable = (test4 || !LinkTh)

		if(!test4 && LinkRSLD)
			test3 =2
		else
			test3 =test4
		endif
		SetVariable 		$("SLD_Real_Layer"+num2str(i)),disable = (test3)
		Slider 			$("SLD_Real_LayerSL"+num2str(i)),disable = (test3)
		SetVariable 		$("SLD_Real_LayerStep"+num2str(i)),disable = (test3)
		CheckBox 		$("FitSLD_Real_Layer"+num2str(i)),disable = (test4)
		SetVariable 		$("SLD_Real_LayerLL"+num2str(i)),disable = (test4 || !FitRSLD)
		SetVariable 		$("SLD_Real_LayerUL"+num2str(i)),disable = (test4 || !FitRSLD)
		CheckBox 		$("LinkSLD_Real_Layer"+num2str(i)),disable = (test4)
		NVAR LinkMeTo= $("root:Packages:Refl_SimpleTool:LinkToSLD_Real_Layer"+num2str(i))
		PopupMenu 		$("LinkToSLD_Real_Layer"+num2str(i)),disable = (test4 || !LinkRSLD), popmatch =num2str(LinkMeTo)
		SetVariable 		$("LinkFSLD_Real_Layer"+num2str(i)),disable = (test4 || !LinkRSLD)

		if(!test4 && LinkISLD)
			test3 =2
		else
			test3 =test4
		endif
		SetVariable 		$("SLD_Imag_Layer"+num2str(i)),disable = (test3)
		Slider 			$("SLD_Imag_LayerSL"+num2str(i)),disable = (test3)
		SetVariable 		$("SLD_Imag_LayerStep"+num2str(i)),disable = (test3)
		CheckBox 		$("FitSLD_Imag_Layer"+num2str(i)),disable = (test4)
		SetVariable 		$("SLD_Imag_LayerLL"+num2str(i)),disable = (test4 || !FitISLD)
		SetVariable 		$("SLD_Imag_LayerUL"+num2str(i)),disable = (test4 || !FitISLD)
		CheckBox 		$("LinkSLD_Imag_Layer"+num2str(i)),disable = (test4)
		NVAR LinkMeTo= $("root:Packages:Refl_SimpleTool:LinkToSLD_Imag_Layer"+num2str(i))
		PopupMenu 		$("LinkToSLD_Imag_Layer"+num2str(i)),disable = (test4 || !LinkISLD), popmatch =num2str(LinkMeTo)
		SetVariable 		$("LinkFSLD_Imag_Layer"+num2str(i)),disable = (test4 || !LinkISLD)

		if(!test4 && LinkROUGH)
			test3 =2
		else
			test3 =test4
		endif
		SetVariable 		$("RoughnessLayer"+num2str(i)),disable = (test3)
		Slider 			$("RoughnessLayerSL"+num2str(i)),disable = (test3)
		SetVariable 		$("RoughnessLayerStep"+num2str(i)),disable = (test3)
		CheckBox 		$("FitRoughnessLayer"+num2str(i)),disable = (test4)
		SetVariable 		$("RoughnessLayerLL"+num2str(i)),disable = (test4 || !FitROUGH)
		SetVariable 		$("RoughnessLayerUL"+num2str(i)),disable = (test4 || !FitROUGH)
		CheckBox 		$("LinkRoughnessLayer"+num2str(i)),disable = (test4)
		NVAR LinkMeTo= $("root:Packages:Refl_SimpleTool:LinkToRoughnessLayer"+num2str(i))
		PopupMenu 		$("LinkToRoughnessLayer"+num2str(i)),disable = (test4 || !linkROUGH), popmatch =num2str(LinkMeTo)
		SetVariable 		$("LinkFRoughnessLayer"+num2str(i)),disable = (test4 || !linkROUGH)


	endfor

end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	

	if (cmpstr(ctrlName,"DrawGraphs")==0)
		//here goes what is done, when user pushes Graph button
		SVAR DFloc=root:Packages:Refl_SimpleTool:DataFolderName
		SVAR DFInt=root:Packages:Refl_SimpleTool:IntensityWaveName
		SVAR DFQ=root:Packages:Refl_SimpleTool:QWaveName
		SVAR DFE=root:Packages:Refl_SimpleTool:ErrorWaveName
		variable IsAllAllRight=1
		if (cmpstr(DFloc,"---")==0 || strlen(DFloc)==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFInt,"---")==0 || strlen(DFInt)==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFQ,"---")==0 || strlen(DFQ)==0)
			IsAllAllRight=0
		endif
//		if (cmpstr(DFE,"---")==0 || strlen(DFE)==0)
//			IsAllAllRight=0
//		endif
		
		if (IsAllAllRight)
			variable recovered = IR2R_RecoverOldParameters()	//recovers old parameters and returns 1 if done so...
			IR2R_GraphMeasuredData()
			if (recovered)
				IR2R_TabPanelControl("",0)
				IR2R_CalculateModelResults()
				IR2R_CalculateSLDProfile()
				IR2R_GraphModelResults()
				IR2R_FixLimits()
			endif
		else
			Abort "Data not selected properly"
		endif
	endif

	if(cmpstr(ctrlName,"ReversFit")==0)
		//here we call the fitting routine
		IR2R_ResetParamsAfterBadFit()
		IR2R_CalculateModelResults()
		IR2R_CalculateSLDProfile()
		IR2R_GraphModelResults()
	endif
	if(cmpstr(ctrlName,"CalculateModel")==0)
		//here we graph the distribution
		IR2R_CalculateModelResults()
		IR2R_CalculateSLDProfile()
		IR2R_GraphModelResults()
	endif
	if(cmpstr(ctrlName,"Fitmodel")==0)
		//here we copy final data back to original data folder	
		IR2R_SimpleToolFit()		//fitting	
		IR2R_CalculateModelResults()
		IR2R_CalculateSLDProfile()
		IR2R_GraphModelResults()
	endif	
	if(cmpstr(ctrlName,"SaveDataBtn")==0)
		//here we copy final data back to original data folder		I	
		IR2R_SaveDataToFolder()
	endif
	if(cmpstr(ctrlName,"FixLimits")==0)
		//here we copy final data back to original data folder		I	
		IR2R_FixLimits()
	endif
	if(cmpstr(ctrlName,"ExportData")==0)
		//here we export ASCII form of the data
		IR2R_SaveASCII()
	endif

	Dowindow /F IR2R_ReflSimpleToolMainPanel

	if(cmpstr(ctrlName,"AddRemoveLayers")==0)
		IR2R_AddRemoveLayersFnct()
		DoWindow/F IR2R_InsertRemoveLayers
	endif

//	DoWindow IR2R_InsertRemoveLayers
//	if(V_Flag)
//		DoWindow/F IR2R_InsertRemoveLayers
//	endif
	setDataFolder oldDF
end
///******************************************************************************************
///******************************************************************************************
static Function IR2R_FixLimits()
	string ListOfVariables="SLD_Real_Layer;SLD_Imag_Layer;ThicknessLayer;RoughnessLayer;"
	variable i, j
	string tempVarName
	For(i=1;i<=8;i+=1)
		For(j=0;j<ItemsInList(ListOfVariables);j+=1)
			tempVarName = stringFromList(j, ListOfVariables)
			NVAR ValueVar=$("root:Packages:Refl_SimpleTool:"+tempVarName+num2str(i))
			NVAR ValueVarLL=$("root:Packages:Refl_SimpleTool:"+tempVarName+"LL"+num2str(i))
			NVAR ValueVarUL=$("root:Packages:Refl_SimpleTool:"+tempVarName+"UL"+num2str(i))
			ValueVarLL = ValueVar/2
			ValueVarUL = ValueVar*1.5
			Slider $(tempVarName+"SL"+num2str(i)),win=IR2R_ReflSimpleToolMainPanel, limits={(ValueVarLL),(ValueVarUL),0}
		endfor
	endfor
	ListOfVariables="Background;Roughness_Bot;ScalingFactor;"
	For(j=0;j<ItemsInList(ListOfVariables);j+=1)
			tempVarName = stringFromList(j, ListOfVariables)
			NVAR ValueVar=$("root:Packages:Refl_SimpleTool:"+tempVarName)
			NVAR ValueVarLL=$("root:Packages:Refl_SimpleTool:"+tempVarName+"LL")
			NVAR ValueVarUL=$("root:Packages:Refl_SimpleTool:"+tempVarName+"UL")
			ValueVarLL = ValueVar/2
			ValueVarUL = ValueVar*1.5
	endfor

end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

static Function IR2R_RecoverOldParameters()
	
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool

//	NVAR SASBackground=root:Packages:FractalsModel:SASBackground
//	NVAR SASBackgroundError=root:Packages:FractalsModel:SASBackgroundError
	SVAR DataFolderName=root:Packages:Refl_SimpleTool:DataFolderName
	

	variable DataExists=0,i
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(DataFolderName, 2)
	string tempString, tmpNote
	if (stringmatch(ListOfWaves, "*ReflModel_*" ))
		string ListOfSolutions=""
		For(i=0;i<itemsInList(ListOfWaves);i+=1)
			if (stringmatch(stringFromList(i,ListOfWaves),"*ReflModel_*"))
				tempString=stringFromList(i,ListOfWaves)
				Wave tempwv=$(DataFolderName+tempString)
				tempString=stringByKey("UsersComment",note(tempwv),"=",";")
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
		string tempStr
		for(i=0;i<ItemsInList(OldNote);i+=1)
			tempStr=StringFromList(0,StringFromList(i,OldNote),"=")
			if(stringMatch(tempStr,"ResolutionWaveName"))
				SVAR/Z testStr=$(tempStr)
				if(SVAR_Exists(testStr))
					testStr=(StringFromList(1,StringFromList(i,OldNote),"="))
				endif
			else
				NVAR/Z testVal=$(tempStr)
				if(NVAR_Exists(testVal))
					testVal=str2num(StringFromList(1,StringFromList(i,OldNote),"="))
				endif
			endif
		endfor
		//Now, fix displayed panel...
		DoWindow/F IR2R_ReflSimpleToolMainPanel
		NVAR UseResolutionWave=root:Packages:Refl_SimpleTool:UseResolutionWave
		SVAR ResolutionWaveName = root:Packages:Refl_SimpleTool:ResolutionWaveName
		SetVariable Resolution, disable = UseResolutionWave
		popupMenu ResolutionType, disable=0, mode=UseResolutionWave+1
		PopupMenu ResolutionWaveName,value= #"\"---;Create From Parameters;\"+IR2R_ResWavesList()"
		PopupMenu ResolutionWaveName,disable=!UseResolutionWave, popmatch=IN2G_RemoveExtraQuote(ResolutionWaveName,1,1)
		NVAR NumberOfLayers=root:Packages:Refl_SimpleTool:NumberOfLayers
		PopupMenu NumberOfLevels mode=NumberOfLayers+1
		TabControl DistTabs value=0
		IR2R_TabPanelControl("",0)
		DoWindow/F IR2R_ReflSimpleToolMainPanel
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

static Function IR2R_SaveASCII()
	
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool

	string UsersComment="Reflectivity results from : "+date()+" "+time()
	Prompt  UsersComment, "Input comments to be included with exported data"
	string DataRecordStr="UsersComment="+UsersComment+";"
	
	string ListOfVariables
	string ListOfStrings
	variable i, j

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;ResolutionWaveName;"

	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR testStr= $(stringFromList(i,ListOfStrings))
		DataRecordStr+=stringFromList(i,ListOfStrings)+"="+testStr+";"
	endfor		
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="NumberOfLayers;ActiveTab;AutoUpdate;FitIQN;Resoln;UpdateAutomatically;ActiveTab;UseErrors;UseResolutionWave;"
	ListOfVariables+="SLD_Real_Top;SLD_Imag_Top;SLD_Real_Bot;SLD_Imag_Bot;"
	ListOfVariables+="Roughness_Bot;FitRoughness_Bot;Roughness_BotLL;Roughness_BotUL;Roughness_BotError;"
	ListOfVariables+="Background;BackgroundStep;FitBackground;BackgroundLL;BackgroundUL;BackgroundError;"
	ListOfVariables+="ScalingFactor;FitScalingFactor;ScalingFactorLL;ScalingFactorUL;ScalingFactorError;"

	
	//and here we read them to the list
	
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test= $(stringFromList(i,ListOfVariables))
		DataRecordStr+=stringFromList(i,ListOfVariables)+"="+num2str(test)+";"
	endfor		
// create 8 x this following list:
	ListOfVariables="SLD_Real_Layer;SLD_Imag_Layer;ThicknessLayer;RoughnessLayer;"
	ListOfVariables+="SLD_Real_LayerError;SLD_Imag_LayerError;ThicknessLayerError;RoughnessLayerError;"
	ListOfVariables+="SLD_Real_LayerStep;SLD_Imag_LayerStep;ThicknessLayerStep;RoughnessLayerStep;"
	ListOfVariables+="SLD_Real_LayerLL;SLD_Imag_LayerLL;ThicknessLayerLL;RoughnessLayerLL;"
	ListOfVariables+="SLD_Real_LayerUL;SLD_Imag_LayerUL;ThicknessLayerUL;RoughnessLayerUL;"
	ListOfVariables+="FitSLD_Real_Layer;FitSLD_Imag_Layer;FitThicknessLayer;FitRoughnessLayer;"
	ListOfVariables+="LinkSLD_Real_Layer;LinkSLD_Imag_Layer;LinkThicknessLayer;LinkRoughnessLayer;"
	ListOfVariables+="LinkFSLD_Real_Layer;LinkFSLD_Imag_Layer;LinkFThicknessLayer;LinkFRoughnessLayer;"
	ListOfVariables+="LinkToSLD_Real_Layer;LinkToSLD_Imag_Layer;LinkToThicknessLayer;LinkToRoughnessLayer;"
	NVAR  NumberOfLayers
	if(NumberOfLayers<1)
	//	abort "Save data errors, Number of Layers <1, nothing to save.."
		DoALert 0, "Note: No layers used, stored only substrate and top layer values"
	endif
	for(j=1;j<=NumberOfLayers;j+=1)	
		for(i=0;i<itemsInList(ListOfVariables);i+=1)	
			NVAR test= $(stringFromList(i,ListOfVariables)+num2str(j))
			DataRecordStr+=stringFromList(i,ListOfVariables)+num2str(j)+"="+num2str(test)+";"
		endfor		
	endfor
	
	wave/Z Reflectivity=root:Packages:Refl_SimpleTool:ModelIntensity
	wave/Z Qvec=root:Packages:Refl_SimpleTool:ModelQvector
	if(!WaveExists(Reflectivity) || !WaveExists(Qvec))
		abort "Save error, Reflectivity and Q wave do not exist"
	endif 
	
	SVAR DataFolderName
	if(strlen(DataFolderName)<1)
		abort "Save data error, DataFolderName is not correct"
	endif
	variable TextWvLength=ItemsInList(DataRecordStr,";")
	make/O/T/N=(TextWvLength) Record_Of_All_Model_Parameters
	for(i=0;i<TextWvLength;i+=1)
		Record_Of_All_Model_Parameters[i]=stringFromList(i,DataRecordStr,";")
	endfor
	
	Duplicate /O Reflectivity, Reflectivity_Model
	Wave Reflectivity_Model
	Duplicate/O Qvec, Q_Reflectivity_Model
	Wave Q_Reflectivity_Model
	Save/G/M="\r\n"/W/I Record_Of_All_Model_Parameters, Q_Reflectivity_Model, Reflectivity_Model
	
	KilLWaves/Z Record_Of_All_Model_Parameters, Q_Reflectivity_Model, Reflectivity_Model

	setDataFOlder OldDf
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

static Function IR2R_SaveDataToFolder()
	
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool

	string UsersComment="Reflectivity results from : "+date()+" "+time()
	Prompt  UsersComment, "Input comments to be included with stored data"
	DoPrompt "Correct comment for saved data", UsersComment
	if(V_Flag)
		abort
	endif
	string DataRecord="UsersComment="+UsersComment+";"
	
	string ListOfVariables
	string ListOfStrings
	variable i, j

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;ResolutionWaveName;"

	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR testStr= $(stringFromList(i,ListOfStrings))
		DataRecord+=stringFromList(i,ListOfStrings)+"="+testStr+";"
	endfor		
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="NumberOfLayers;ActiveTab;AutoUpdate;FitIQN;Resoln;UpdateAutomatically;ActiveTab;UseErrors;UseResolutionWave;"
	ListOfVariables+="SLD_Real_Top;SLD_Imag_Top;SLD_Real_Bot;SLD_Imag_Bot;"
	ListOfVariables+="Roughness_Bot;FitRoughness_Bot;Roughness_BotLL;Roughness_BotUL;Roughness_BotError;"
	ListOfVariables+="Background;BackgroundStep;FitBackground;BackgroundLL;BackgroundUL;BackgroundError;"
	ListOfVariables+="ScalingFactor;FitScalingFactor;ScalingFactorLL;ScalingFactorUL;ScalingFactorError;"

	
	//and here we read them to the list
	
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test= $(stringFromList(i,ListOfVariables))
		DataRecord+=stringFromList(i,ListOfVariables)+"="+num2str(test)+";"
	endfor		
// create 8 x this following list:
	ListOfVariables="SLD_Real_Layer;SLD_Imag_Layer;ThicknessLayer;RoughnessLayer;"
	ListOfVariables+="SLD_Real_LayerError;SLD_Imag_LayerError;ThicknessLayerError;RoughnessLayerError;"
	ListOfVariables+="SLD_Real_LayerStep;SLD_Imag_LayerStep;ThicknessLayerStep;RoughnessLayerStep;"
	ListOfVariables+="SLD_Real_LayerLL;SLD_Imag_LayerLL;ThicknessLayerLL;RoughnessLayerLL;"
	ListOfVariables+="SLD_Real_LayerUL;SLD_Imag_LayerUL;ThicknessLayerUL;RoughnessLayerUL;"
	ListOfVariables+="FitSLD_Real_Layer;FitSLD_Imag_Layer;FitThicknessLayer;FitRoughnessLayer;"
	ListOfVariables+="LinkSLD_Real_Layer;LinkSLD_Imag_Layer;LinkThicknessLayer;LinkRoughnessLayer;"
	ListOfVariables+="LinkFSLD_Real_Layer;LinkFSLD_Imag_Layer;LinkFThicknessLayer;LinkFRoughnessLayer;"
	ListOfVariables+="LinkToSLD_Real_Layer;LinkToSLD_Imag_Layer;LinkToThicknessLayer;LinkToRoughnessLayer;"
	NVAR/Z  NumberOfLayers
	if(NumberOfLayers<1)
	//	abort "Save data error, Number of Layers <1 nothing to save..."
		DoAlert 0, "Note: No layers used, stored only top and substrate values"
	endif
	for(j=1;j<=NumberOfLayers;j+=1)	
		for(i=0;i<itemsInList(ListOfVariables);i+=1)	
			NVAR test= $(stringFromList(i,ListOfVariables)+num2str(j))
			DataRecord+=stringFromList(i,ListOfVariables)+num2str(j)+"="+num2str(test)+";"
		endfor		
	endfor
	
	wave/Z Reflectivity=root:Packages:Refl_SimpleTool:ModelIntensity
	wave/Z Qvec=root:Packages:Refl_SimpleTool:ModelQvector
	if(!WaveExists(Reflectivity) || !WaveExists(Qvec))
		abort "Save error, Reflectivity and Q wave do not exist"
	endif 
	
	wave/Z SLDProfile=root:Packages:Refl_SimpleTool:SLDProfile
	if(!WaveExists(SLDProfile))
		abort "Save error, SLDProfile wave does not exist"
	endif 

	SVAR DataFolderName
	if(strlen(DataFolderName)<1)
		abort "Save data error, DataFolderName is not correct"
	endif
	if(stringmatch(DataFolderName, "*root:Packages:*"))		//using Modeling tool
		string NewFldrName
		NewFldrName="ReflectivityModeling"
		Prompt NewFldrName, "Using model, need to create new folder for the results"
		DoPrompt "Type new Folder name for the results, will be in root: folder", NewFldrName
		if(V_Flag)
			abort
		endif
		setDataFolder root:
		NewDataFOlder/O/S $(UniqueName((PossiblyQuoteName(NewFldrName)), 11, 0  ))
		DataFolderName = GetDataFolder(1)
	endif
	
	setDataFolder root:
	setDataFolder DataFolderName
	string NewIntName=UniqueName("ReflModel_", 1, 0)
	variable FoundIndex=str2num(stringFromList(1,NewIntName,"_"))
	string NewQwave="ReflQ_"+num2str(FoundIndex)
	string NewSLDProfileWave="SLDProfile_"+num2str(FoundIndex)
	string NewSLDProfileXWave="SLDProfileX_"+num2str(FoundIndex)
	
	Duplicate/O Reflectivity, $NewIntName
	Wave NewReflectivity=$(NewIntName)
	Duplicate/O Qvec, $NewQwave
	Wave NewQ=$(NewQwave)
	Duplicate/O SLDProfile, $NewSLDProfileWave
	Duplicate/O SLDProfile, $NewSLDProfileXWave
	Wave NewSLDProfile=$(NewSLDProfileWave)
	Wave NewSLDProfileX=$(NewSLDProfileXWave)
	NewSLDProfileX = leftx(NewSLDProfile )+deltax(NewSLDProfile )*p	
	note/NOCR NewReflectivity, DataRecord
	note/NOCR NewQ, DataRecord
	note/NOCR NewSLDProfile, DataRecord

	setDataFOlder OldDf
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
static Function IR2R_CalculateModelResults()
	//this function calculates model data
//variable startTime=ticks
	variable i, j
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	IR2R_UpdateLinkedVariables()
	
	wave/Z OriginalQvector=root:Packages:Refl_SimpleTool:OriginalQvector
	if(!WaveExists(OriginalQvector))
		abort
	endif

	//Need to create wave with parameters for Motofit_Imag here
	NVAR NumberOfLayers= root:Packages:Refl_SimpleTool:NumberOfLayers
	//need 8 parameters to start with - numLayers, scale, TopSLD_real, TopSLD_Imag, Bot_SLD_real, BotSLD_imag, Background, SubstareRoughness, and then 4 parameters for each layer 
	// thickness, re_SLD, imag_SLD and roughness
	variable NumPointsNeeded= NumberOfLayers * 4 + 8
	
	make/O/D/N=(NumPointsNeeded) ParametersIn
	//now let's fill this in
	ParametersIn[0] = NumberOfLayers
	NVAR ScalingFactor=root:Packages:Refl_SimpleTool:ScalingFactor
	NVAR SLD_Real_Top=root:Packages:Refl_SimpleTool:SLD_Real_Top
	NVAR SLD_Imag_Top=root:Packages:Refl_SimpleTool:SLD_Imag_Top
	NVAR SLD_Real_Bot=root:Packages:Refl_SimpleTool:SLD_Real_Bot
	NVAR SLD_Imag_Bot=root:Packages:Refl_SimpleTool:SLD_Imag_Bot
	NVAR Background=root:Packages:Refl_SimpleTool:Background
	NVAR Roughness_Bot=root:Packages:Refl_SimpleTool:Roughness_Bot	
	NVAR L1AtTheBottom=root:Packages:Refl_SimpleTool:L1AtTheBottom
	
	ParametersIn[1] = ScalingFactor	
	ParametersIn[2] = SLD_Real_Top//*1e-6
	ParametersIn[3] = SLD_Imag_Top*1e-6
	ParametersIn[4] = SLD_Real_Bot//*1e-6
	ParametersIn[5] = SLD_Imag_Bot*1e-6
	ParametersIn[6] = Background
	ParametersIn[7] = Roughness_Bot

	//fix to allow L1 at the bottom...
	if(L1AtTheBottom)
		j=0
		for(i=NumberOfLayers;i>=1;i-=1)
			j+=1
			NVAR ThicknessLayer= $("root:Packages:Refl_SimpleTool:ThicknessLayer"+Num2str(i))
			NVAR SLD_real_Layer = $("root:Packages:Refl_SimpleTool:SLD_Real_Layer"+Num2str(i))
			NVAR SLD_imag_Layer = $("root:Packages:Refl_SimpleTool:SLD_Imag_Layer"+Num2str(i))
			NVAR RoughnessLayer = $("root:Packages:Refl_SimpleTool:RoughnessLayer"+Num2str(i))
			ParametersIn[7+(j-1)*4+1] =  ThicknessLayer
			ParametersIn[7+(j-1)*4+2] =  SLD_real_Layer//*1e-6
			ParametersIn[7+(j-1)*4+3] =  SLD_imag_Layer*1e-6
			ParametersIn[7+(j-1)*4+4] =  RoughnessLayer
		endfor
	else
		for(i=1;i<=NumberOfLayers;i+=1)
			NVAR ThicknessLayer= $("root:Packages:Refl_SimpleTool:ThicknessLayer"+Num2str(i))
			NVAR SLD_real_Layer = $("root:Packages:Refl_SimpleTool:SLD_Real_Layer"+Num2str(i))
			NVAR SLD_imag_Layer = $("root:Packages:Refl_SimpleTool:SLD_Imag_Layer"+Num2str(i))
			NVAR RoughnessLayer = $("root:Packages:Refl_SimpleTool:RoughnessLayer"+Num2str(i))
			ParametersIn[7+(i-1)*4+1] =  ThicknessLayer
			ParametersIn[7+(i-1)*4+2] =  SLD_real_Layer//*1e-6
			ParametersIn[7+(i-1)*4+3] =  SLD_imag_Layer*1e-6
			ParametersIn[7+(i-1)*4+4] =  RoughnessLayer
		endfor
	endif

	NVAR Resoln=root:Packages:Refl_SimpleTool:Resoln
	NVAR OversampleModel=root:Packages:Refl_SimpleTool:OversampleModel
	NVAR UseResolutionWave=root:Packages:Refl_SimpleTool:UseResolutionWave
	SVAR ResolutionWaveName=root:Packages:Refl_SimpleTool:ResolutionWaveName
	SVAR DataFolderName=root:Packages:Refl_SimpleTool:DataFolderName
	Wave/Z ResolutionWave=$(DataFolderName+ResolutionWaveName)
	if(OversampleModel)
		Make/O/N=(5*numpnts(OriginalQvector)) ModelQvector, ModelIntensity
		ModelQvector  = OriginalQvector[p/5]
		
	else
		Duplicate/O OriginalQvector, ModelQvector, ModelIntensity
	endif

	if(UseResolutionWave)	
		if(!WaveExists(ResolutionWave))
			abort "Resolution wave does not exist"
		endif
		//ModelIntensity=IR2R_CalculateReflectivity(ParametersIn,ModelQvector,ResolutionWave)
		//ModelIntensity=Abeles_imagALl(ParametersIn,ModelQvector,ResolutionWave)
		//		Abeles_imagALl(w, RR, xtemp)
		IR2R_CalculateReflectivityNewRW(ParametersIn,ModelIntensity,ModelQvector,ResolutionWave)
	else//use resoln
		//ModelIntensity=IR2R_CalculateReflectivity(ParametersIn,ModelQvector,Resoln)
		IR2R_CalculateReflectivityNew(ParametersIn,ModelIntensity,ModelQvector,Resoln)
	endif
	Wave ModelIntensity=root:Packages:Refl_SimpleTool:ModelIntensity
	Wave ModelQvector=root:Packages:Refl_SimpleTool:ModelQvector
	NVAR FitIQN=root:Packages:Refl_SimpleTool:FitIQN
	Duplicate/O ModelIntensity, ModelIntensityQN
	Duplicate/O ModelQvector, ModelQvectorToN
	ModelIntensityQN = ModelIntensity * ModelQvectorToN^FitIQN

	setDataFolder OldDf
//print (ticks-startTime)/60	
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
static Function IR2R_GraphModelResults()
	//this function graphs model data
	
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	Wave/Z ModelIntensity=root:Packages:Refl_SimpleTool:ModelIntensity
	if(!WaveExists(ModelIntensity))
		abort 	//no data to do anything
	endif
	Wave ModelQvector=root:Packages:Refl_SimpleTool:ModelQvector
	NVAR FitIQN=root:Packages:Refl_SimpleTool:FitIQN
	Duplicate/O ModelIntensity, ModelIntensityQN
	Duplicate/O ModelQvector, ModelQvectorToN
	ModelIntensityQN = ModelIntensity * ModelQvectorToN^FitIQN

	DoWindow IR2R_LogLogPlotRefl
	if(V_Flag)
		DoWindow/F IR2R_LogLogPlotRefl
		CheckDisplayed /W=IR2R_LogLogPlotRefl ModelIntensity
		if(V_Flag!=1)
			AppendToGraph/W=IR2R_LogLogPlotRefl ModelIntensity vs ModelQvector
		endif
		ModifyGraph rgb(ModelIntensity)=(0,0,0)
	endif
	DoWindow IR2R_IQN_Q_PlotV
	if(V_Flag)
		DoWindow/F IR2R_IQN_Q_PlotV
		CheckDisplayed /W=IR2R_IQN_Q_PlotV ModelIntensityQN
		if(V_Flag!=1)
			AppendToGraph/W=IR2R_IQN_Q_PlotV ModelIntensityQN vs ModelQvectorToN
		endif
		ModifyGraph rgb(ModelIntensityQN)=(0,0,0)
	endif
	DoWindow IR2R_SLDProfile
	if(V_Flag)
		DoWindow/F IR2R_SLDProfile
	else
		Execute ("IR2R_SLDProfile()")
	endif

	setDataFolder OldDf
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


static Function IR2R_SimpleToolFit()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	//setup waves for fitting
	string ListOfVariables
	variable i, j, curLen, curLenConst
	//Each variable has Name, FitName, NameLL, NameUL, and for layers the name has index 1 to NumberOfLayers (up to 8)
	NVAR NumberOfLayers=root:Packages:Refl_SimpleTool:NumberOfLayers
	NVAR FitIQN=root:Packages:Refl_SimpleTool:FitIQN
	make/O/N=0/T CoefNames, T_Constraints
	Make/O/N=(0,2) Gen_Constraints
	make/O/D/N=0 W_coef

	ListOfVariables="SLD_Real_LayerError;SLD_Imag_LayerError;ThicknessLayerError;RoughnessLayerError;"
	For(i=0;i<ItemsInList(ListOfVariables);i+=1)
		For(j=1;j<=8;j+=1)
			NVAR Value = $("root:Packages:Refl_SimpleTool:"+StringFromList(i,ListOfVariables)+num2str(j))
			Value=0
		endfor
	endfor


	ListOfVariables="Roughness_Bot;"//FitRoughness_Bot;Roughness_BotLL;Roughness_BotUL;"
	ListOfVariables+="Background;ScalingFactor;"//FitBackground;BackgroundLL;BackgroundUL;"
	T_Constraints=""
	CoefNames=""

	For(i=0;i<ItemsInList(ListOfVariables);i+=1)
		NVAR CurValErr=$("root:Packages:Refl_SimpleTool:"+StringFromList(i,ListOfVariables)+"Error")
		NVAR FitMe=$("root:Packages:Refl_SimpleTool:Fit"+StringFromList(i,ListOfVariables))
		NVAR CurVal=$("root:Packages:Refl_SimpleTool:"+StringFromList(i,ListOfVariables))
		NVAR LLVal=$("root:Packages:Refl_SimpleTool:"+StringFromList(i,ListOfVariables)+"LL")
		NVAR ULVal=$("root:Packages:Refl_SimpleTool:"+StringFromList(i,ListOfVariables)+"UL")
		CurValErr=0
		curLen=numpnts(W_coef)
		curLenConst=numpnts(T_Constraints)
		if(FitMe)
			if(LLVal>CurVal || ULVal<CurVal)
				abort "Limits for "+ StringFromList(i,ListOfVariables)+"  set incorrectly"
			endif
			redimension/N=(curlen+1) CoefNames, W_coef
			Redimension /N=((curlen+1),2) Gen_Constraints
			redimension/N=(curLenConst+2) T_Constraints
			W_coef[curLen] = CurVal
			CoefNames[curLen] = StringFromList(i,ListOfVariables)
			T_Constraints[curLenConst] = {"K"+num2str(curlen)+" > "+num2str(LLVal)}
			T_Constraints[curLenConst+1] = {"K"+num2str(curlen)+" < "+num2str(ULVal)}
			Gen_Constraints[curLen][0] = LLVal
			Gen_Constraints[curLen][1] = ULVal
		endif
	endfor
	
// create 8 x this following list:
//	NVAR SLDinCm=root:Packages:Refl_SimpleTool:SLDinCm
//	NVAR SLDinA=root:Packages:Refl_SimpleTool:SLDinA
	variable tempThickKVal, tempRoughKVal
	string tempStr
	ListOfVariables="SLD_Real_Layer;SLD_Imag_Layer;ThicknessLayer;RoughnessLayer;"
	For(j=1;j<=NumberOfLayers;j+=1)
		tempThickKVal=0
		tempRoughKVal=0
		For(i=0;i<ItemsInList(ListOfVariables);i+=1)
			tempStr = StringFromList(i,ListOfVariables)+num2str(j)
			NVAR FitMe=$("root:Packages:Refl_SimpleTool:Fit"+StringFromList(i,ListOfVariables)+num2str(j))
			NVAR CurVal=$("root:Packages:Refl_SimpleTool:"+StringFromList(i,ListOfVariables)+num2str(j))
			NVAR LLVal=$("root:Packages:Refl_SimpleTool:"+StringFromList(i,ListOfVariables)+"LL"+num2str(j))
			NVAR ULVal=$("root:Packages:Refl_SimpleTool:"+StringFromList(i,ListOfVariables)+"UL"+num2str(j))
			curLen=numpnts(W_coef)
			curLenConst=numpnts(T_Constraints)
			if(FitMe)
				if(LLVal>CurVal || ULVal<CurVal)
					abort "Limits for "+ StringFromList(i,ListOfVariables)+num2str(j)+"  set incorrectly"
				endif
				redimension/N=(curlen+1) CoefNames, W_coef
				Redimension /N=((curlen+1),2) Gen_Constraints
				redimension/N=(curLenConst+2) T_Constraints
					W_coef[curLen] = CurVal
					CoefNames[curLen] = StringFromList(i,ListOfVariables)+num2str(j)
					T_Constraints[curLenConst] = {"K"+num2str(curlen)+" > "+num2str(LLVal)}
					T_Constraints[curLenConst+1] = {"K"+num2str(curlen)+" < "+num2str(ULVal)}
					Gen_Constraints[curLen][0] = LLVal
					Gen_Constraints[curLen][1] = ULVal
				if(StringMatch(tempStr, "ThicknessLayer*" ))
					tempThickKVal = curlen
				endif
				if(StringMatch(tempStr, "RoughnessLayer*" ))
					tempRoughKVal = curlen
				endif
			endif
		endfor
		if(tempThickKVal>0 && tempRoughKVal>0)
			curLenConst=numpnts(T_Constraints)
			redimension/N=(curLenConst+1) T_Constraints
			curLenConst=numpnts(T_Constraints)
			//roughness <thickness/2.38
			T_Constraints[curLenConst-1] = {"K"+num2str(tempRoughKVal)+"<K"+num2str(tempThickKVal)+"/2.38"}
		endif
	endfor
	//Now let's check if we have what to fit at all...
	if (numpnts(CoefNames)==0)
		beep
		Abort "Select parameters to fit and set their fitting limits"
	endif
	IR2R_SetErrorsToZero()
	
	DoWindow /F IR2R_LogLogPlotRefl
	Wave OriginalQvector
	Wave OriginalIntensity
	Wave OriginalError	
	NVAR FitIQN=root:Packages:Refl_SimpleTool:FitIQN	
	NVAR UseErrors=root:Packages:Refl_SimpleTool:UseErrors
	
	Variable V_chisq
	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave=W_coef/20

	NVAR/Z UseLSQF = root:Packages:Refl_SimpleTool:UseLSQF 
	NVAR/Z UseGenOpt = root:Packages:Refl_SimpleTool:UseGenOpt 
	if(!NVAR_Exists(UseGenOpt)||!NVAR_Exists(UseLSQF))
		variable/g UseGenOpt
		variable/g UseLSQF
		UseLSQF=1
		UseGenOpt=0
	endif
	string HoldStr=""
	For(i=0;i<numpnts(W_Coef);i+=1)
		HoldStr+="0"
	endfor
	if(UseGenOpt)	//check the limits, for GenOpt the ratio between min and max should not be too high
		IR2R_CheckFittingParamsFnct()
		PauseForUser IR2R_CheckFittingParams
		NVAR UserCanceled=root:Packages:Refl_SimpleTool:UserCanceled
		if (UserCanceled)
			setDataFolder OldDf
			abort
		endif
		
	endif


		////	IR1A_RecordResults("before")

	Variable V_FitError=0			//This should prevent errors from being generated
	variable temp
	
	NVAR Resoln=root:Packages:Refl_SimpleTool:Resoln
	NVAR UseResolutionWave=root:Packages:Refl_SimpleTool:UseResolutionWave
	SVAR ResolutionWaveName=root:Packages:Refl_SimpleTool:ResolutionWaveName
	SVAR DataFolderName=root:Packages:Refl_SimpleTool:DataFolderName
	Wave/Z ResolutionWave=$(DataFolderName+ResolutionWaveName)
		if(!WaveExists(ResolutionWave) && UseResolutionWave)
			abort "Resolution wave does not exist"
		endif
	//remember, to allow user not to have errors, if they are not provided we create them and set them to 0... 
	//and now the fit...

	Print "Reflectivity Optimization fit started at: "+ time()
	DoWIndow UserOptimizationWidnow
	if(V_Flag)
		DoWIndow/F UserOptimizationWidnow
	else
		UserOptimizationWidnowP()
		DoUpdate/W=UserOptimizationWidnow
	endif
	//Print "NOTE: The optimization is running even though there may be no indication in the screen. Be patient... "
	variable startTicks=ticks
	if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
		//check that the cursors are on the right wave or get them set to the right wave
		if(cmpstr(CsrWave(A),"OriginalIntensity")!=0)
			temp = CsrXWaveRef(A)[xcsr(A)]
			cursor A OriginalIntensity binarysearch(OriginalQvector,temp)
		endif
		if(cmpstr(CsrWave(B),"OriginalIntensity")!=0)
			temp = CsrXWaveRef(B)[xcsr(B)]
			cursor B OriginalIntensity binarysearch(OriginalQvector,temp)
		endif
		
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalIntensity, FitIntensityWave		
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalQvector, FitQvectorWave
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalError, FitErrorWave
		if(UseResolutionWave)
			Duplicate/O/R=[pcsr(A),pcsr(B)] ResolutionWave, FitResolutionWave	
		endif
		if(UseResolutionWave)
			IN2G_RemoveNaNsFrom4Waves(FitIntensityWave,FitQvectorWave,FitErrorWave,FitResolutionWave)
		else
			IN2G_RemoveNaNsFrom3Waves(FitIntensityWave,FitQvectorWave,FitErrorWave)
		endif
		Duplicate/O FitIntensityWave, ErrorFractionWave, tempFitWv		
		tempFitWv=NaN

		ErrorFractionWave = FitErrorWave / FitIntensityWave
		FitIntensityWave = FitIntensityWave * FitQvectorWave^FitIQN
		FitErrorWave = FitIntensityWave * ErrorFractionWave 
		if(sum(FitErrorWave)==0 || !UseErrors)	//no errors to use...
			if(UseLSQF)
				FuncFit /N/Q IR2R_ST_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /E=E_wave  /C=T_Constraints 
			else
				Duplicate/O FitIntensityWave, GenMaskWv
				GenMaskWv=1
#if Exists("gencurvefit")
	  	gencurvefit  /M=GenMaskWv/MAT=0/N/D=tempFitWv /TOL=0.05 /K={50,20,0.7,0.5} /X=FitQvectorWave IR2R_ST_FitFunction, FitIntensityWave  , W_Coef, HoldStr, Gen_Constraints  	
#else
		Abort  "Genetic Optimization xop NOT installed. Install xop support and then try again"
#endif
			endif
		else		//have errorrs
			if(UseLSQF)
				FuncFit /N/Q IR2R_ST_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /C=T_Constraints 
			else
				Duplicate/O FitIntensityWave, GenMaskWv
				GenMaskWv=1
#if Exists("gencurvefit")
	  	//gencurvefit  /I=1 /W=FitErrorWave /M=GenMaskWv /N /TOL=0.001 /K={50,20,0.7,0.5} /X=FitQvectorWave IR2R_ST_FitFunction, FitIntensityWave  , W_Coef, HoldStr, Gen_Constraints  	
	  	gencurvefit  /I=1/MAT=0/N /W=FitErrorWave/D=tempFitWv /M=GenMaskWv /TOL=0.05 /K={50,20,0.7,0.5} /X=FitQvectorWave IR2R_ST_FitFunction, FitIntensityWave  , W_Coef, HoldStr, Gen_Constraints  	
#else
		Abort "Genetic Optimization xop NOT installed. Install xop support and then try again"
#endif
			endif
		endif
	else		//no cursors used....
		Duplicate/O OriginalIntensity, FitIntensityWave	
		Duplicate/O OriginalQvector, FitQvectorWave
		Duplicate/O OriginalError, FitErrorWave
		if(UseResolutionWave)
			Duplicate/O ResolutionWave, FitResolutionWave	
		endif
		if(UseResolutionWave)
			IN2G_RemoveNaNsFrom4Waves(FitIntensityWave,FitQvectorWave,FitErrorWave,FitResolutionWave)
		else
			IN2G_RemoveNaNsFrom3Waves(FitIntensityWave,FitQvectorWave,FitErrorWave)
		endif
		Duplicate/O FitIntensityWave, ErrorFractionWave, tempFitWv		
		tempFitWv=NaN
		ErrorFractionWave = FitErrorWave / FitIntensityWave
		FitIntensityWave = FitIntensityWave * FitQvectorWave^FitIQN
		FitErrorWave = FitIntensityWave * ErrorFractionWave
		if(sum(FitErrorWave)==0 || !UseErrors)	//no errors to use...
			if(UseLSQF)
				FuncFit /N/Q IR2R_ST_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /E=E_wave /C=T_Constraints	
			else
				Duplicate/O FitIntensityWave, GenMaskWv
				GenMaskWv=1
#if Exists("gencurvefit")
	  	gencurvefit  /M=GenMaskWv/MAT=0/N/D=tempFitWv /TOL=0.05 /K={50,20,0.7,0.5} /X=FitQvectorWave IR2R_ST_FitFunction, FitIntensityWave  , W_Coef, HoldStr, Gen_Constraints  	
#else
		Abort  "Genetic Optimization xop NOT installed. Install xop support and then try again"
#endif
			endif
		else		//have errors
			if(UseLSQF)
				FuncFit /N/Q IR2R_ST_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave /C=T_Constraints	
			else
				Duplicate/O FitIntensityWave, GenMaskWv
				GenMaskWv=1
#if Exists("gencurvefit")
	  	gencurvefit  /I=1 /W=FitErrorWave/MAT=0/Q/N/D=tempFitWv /M=GenMaskWv /TOL=0.05 /K={50,20,0.7,0.5} /X=FitQvectorWave IR2R_ST_FitFunction, FitIntensityWave  , W_Coef, HoldStr, Gen_Constraints  	
#else
		Abort  "Genetic Optimization xop NOT installed. Install xop support and then try again"
#endif
			endif
		endif
	endif
	Print "Optimization fit ended at: \t"+ time()+"\tafter\t"+num2str((ticks-startTicks)/60)+" [s]"
	DoWIndow UserOptimizationWidnow
	if(V_Flag)
		DoWIndow/K UserOptimizationWidnow
	endif
	if (V_FitError!=0)	//there was error in fitting
		IR2R_ResetParamsAfterBadFit()
		beep
		Abort "Fitting error, check starting parameters and fitting limits" 
	else
		Wave W_sigma = root:Packages:Refl_SimpleTool:W_sigma
		SVAR Dataname=root:Packages:Refl_SimpleTool:DataFolderName
		Print "________________________________"
		Print "Achieved results of optimization"
		Print "   "
		Print "Data fitted : "+Dataname
		Print "   "
		For(i=0;i<numpnts(W_coef);i+=1)
			NVAR testVal=$(CoefNames[i])
			testVal=W_coef[i]
			if(stringMatch("Roughness_Bot;Background;ScalingFactor;", "*"+CoefNames[i]+"*"))
				//print "root:Packages:Refl_SimpleTool:"+CoefNames[i]+"Error"
				NVAR testValError=$("root:Packages:Refl_SimpleTool:"+CoefNames[i]+"Error")
			else
				//print "root:Packages:Refl_SimpleTool:"+(CoefNames[i])[0,strlen(CoefNames[i])-2]+"Error"+(CoefNames[i])[strlen(CoefNames[i])-1,inf]
				NVAR testValError=$("root:Packages:Refl_SimpleTool:"+(CoefNames[i])[0,strlen(CoefNames[i])-2]+"Error"+(CoefNames[i])[strlen(CoefNames[i])-1,inf])
			endif
			testValError = W_sigma[i]
			print CoefNames[i]+"\t=\t"+num2str(W_coef[i])+"\t+/-\t"+ num2str(W_sigma[i])
		endfor	
		Print "________________________________"
		Print "   "
	endif
	variable/g AchievedChisq=V_chisq
	//here we graph the distribution
	IR2R_CalculateModelResults()
	IR2R_CalculateSLDProfile()
	IR2R_GraphModelResults()
	KillWaves/Z ErrorFractionWave	
	setDataFolder OldDf
end
///******************************************************************************************
///******************************************************************************************
Function UserOptimizationWidnowP() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(352,245,806,366) as "Optimization in Progress"
	DoWindow/C UserOptimizationWidnow
	SetDrawLayer UserBack
	SetDrawEnv fillfgc= (65535,0,0)
	DrawRect 17,12,426,107
	SetDrawEnv fsize= 18
	DrawText 83,40,"Reflectivity optimization in progress"
	SetDrawEnv fsize= 18
	DrawText 79,68,"This window will close when finished"
	DrawText 76,93,"If you abort the optimization, close the window manually"
EndMacro
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR2R_CheckFittingParamsFnct() 
	//PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(400,140,870,600) as "Check fitting parameters"
	Dowindow/C IR2R_CheckFittingParams
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 3,textrgb= (0,0,65280)
	DrawText 39,28,"Reflectivity Fit Params & Limits"
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 10,50,"For Gen Opt. verify fitted parameters. Make sure"
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 10,70,"the parameter range is appropriate."
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 10,90,"The whole range must be valid! It will be tested!"
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 10,110,"       Then continue....."
	Button CancelBtn,pos={27,420},size={150,20},proc=IR2R_CheckFitPrmsButtonProc,title="Cancel fitting"
	Button ContinueBtn,pos={187,420},size={150,20},proc=IR2R_CheckFitPrmsButtonProc,title="Continue fitting"
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Refl_SimpleTool:
	Wave Gen_Constraints,W_coef
	Wave/T CoefNames
	SetDimLabel 1,0,Min,Gen_Constraints
	SetDimLabel 1,1,Max,Gen_Constraints
	variable i
	For(i=0;i<numpnts(CoefNames);i+=1)
		SetDimLabel 0,i,$(CoefNames[i]),Gen_Constraints
	endfor
		Edit/W=(0.05,0.25,0.95,0.865)/HOST=#  Gen_Constraints.ld,W_coef
//		ModifyTable format(Point)=1,width(Point)=0, width(Gen_Constraints)=110
//		ModifyTable alignment(W_coef)=1,sigDigits(W_coef)=4,title(W_coef)="Curent value"
//		ModifyTable alignment(Gen_Constraints)=1,sigDigits(Gen_Constraints)=4,title(Gen_Constraints)="Limits"
//		ModifyTable statsArea=85
		ModifyTable format(Point)=1,width(Point)=0,alignment(W_coef.y)=1,sigDigits(W_coef.y)=4
		ModifyTable width(W_coef.y)=90,title(W_coef.y)="Start value",width(Gen_Constraints.l)=172
//		ModifyTable title[1]="Min"
//		ModifyTable title[2]="Max"
		ModifyTable alignment(Gen_Constraints.d)=1,sigDigits(Gen_Constraints.d)=4,width(Gen_Constraints.d)=72
		ModifyTable title(Gen_Constraints.d)="Limits"
//		ModifyTable statsArea=85
//		ModifyTable statsArea=20
	SetDataFolder fldrSav0
	RenameWindow #,T0
	SetActiveSubwindow ##
End

// Function Test()
//> Make /o /n=(5,2) myWave
//> SetDimLabel 1,0,min,myWave
//> SetDimLabel 1,1,max,myWave
//> Edit myWave.ld
//> End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2R_CheckFitPrmsButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if(stringmatch(ctrlName,"*CancelBtn*"))
		variable/g root:Packages:Refl_SimpleTool:UserCanceled=1
		DoWindow/K IR2R_CheckFittingParams
	endif

	if(stringmatch(ctrlName,"*ContinueBtn*"))
		variable/g root:Packages:Refl_SimpleTool:UserCanceled=0
		DoWindow/K IR2R_CheckFittingParams
	endif

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR2R_ResetParamsAfterBadFit()
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool

	Wave w=root:Packages:Refl_SimpleTool:CoefficientInput
	Wave/T CoefNames=root:Packages:Refl_SimpleTool:CoefNames		//text wave with names of parameters

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

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2R_ST_FitFunction(w,yw,xw) : FitFunc
	Wave w,yw,xw
	
	//here the w contains the parameters, yw will be the result and xw is the input
	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(q) = very complex calculations, forget about formula
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1 - the q vector...
	//CurveFitDialog/ q

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool

	Wave/T CoefNames=root:Packages:Refl_SimpleTool:CoefNames		//text wave with names of parameters
	NVAR FitIQN=root:Packages:Refl_SimpleTool:FitIQN	

	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	string ParamName=""
	
	for (i=0;i<NumOfParam;i+=1)
		ParamName=CoefNames[i]
		NVAR tempVar=$(ParamName)
		//let's allow enforcement of positivity of given parameter here...
		if(stringmatch(ParamName, "*roughness*"))
			tempVar = abs( w[i])
		else
			tempVar = w[i]
		endif
	endfor
	//add here fix for linking, if parameter is linked to something, that something needs to be fixed herer also to match it during fitting... 
	IR2R_UpdateLinkedVariables()	
	Wave QvectorWave=root:Packages:Refl_SimpleTool:FitQvectorWave
	//and now we need to calculate the model Intensity
	IR2R_FitCalculateModelResults(QvectorWave)			
	Wave resultWv=root:Packages:Refl_SimpleTool:SimpleToolFitIntensity
	resultWv = resultWv * QvectorWave^FitIQN	
	yw=resultWv

	NVAR UpdateDuringFitting=root:Packages:Refl_SimpleTool:UpdateDuringFitting
	if(UpdateDuringFitting)
		IR2R_CalculateModelResults()
		IR2R_CalculateSLDProfile()
		IR2R_GraphModelResults()
		DoUpdate/W=IR2R_LogLogPlotRefl
		DoUpdate/W=IR2R_IQN_Q_PlotV
	endif
	setDataFolder oldDF
End


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
static Function IR2R_FitCalculateModelResults(FitQvector)
	wave FitQvector
	//this function calculates model data
//	make/o/t parameters_Cref = {"Numlayers","scale","re_SLDtop","imag_SLDtop","re_SLDbase","imag_SLD base","bkg","sigma_base","thick1","re_SLD1","imag_SLD1","rough1","thick2","re_SLD2","imag_SLD2","rough2"}
//	Edit parameters_Cref,coef_Cref,par_res,resolution
//	ywave_Cref:= Motofit_Imag(coef_Cref,xwave_Cref)

	variable i,j
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	//Need to create wave with parameters for Motofit_Imag here
	NVAR NumberOfLayers= root:Packages:Refl_SimpleTool:NumberOfLayers
	//need 8 parameters to start with - numLayers, scale, TopSLD_real, TopSLD_Imag, Bot_SLD_real, BotSLD_imag, Background, SubstareRoughness, and then 4 parameters for each layer 
	// thickness, re_SLD, imag_SLD and roughness
	variable NumPointsNeeded= NumberOfLayers * 4 + 8
	
	make/O/D/N=(NumPointsNeeded) ParametersIn
	//now let's fill this in
	ParametersIn[0] = NumberOfLayers
	NVAR ScalingFactor=root:Packages:Refl_SimpleTool:ScalingFactor
	NVAR SLD_Real_Top=root:Packages:Refl_SimpleTool:SLD_Real_Top
	NVAR SLD_Imag_Top=root:Packages:Refl_SimpleTool:SLD_Imag_Top
	NVAR SLD_Real_Bot=root:Packages:Refl_SimpleTool:SLD_Real_Bot
	NVAR SLD_Imag_Bot=root:Packages:Refl_SimpleTool:SLD_Imag_Bot
	NVAR Background=root:Packages:Refl_SimpleTool:Background
	NVAR Roughness_Bot=root:Packages:Refl_SimpleTool:Roughness_Bot	
	NVAR L1AtTheBottom=root:Packages:Refl_SimpleTool:L1AtTheBottom
	
	
	ParametersIn[1] = ScalingFactor		
	ParametersIn[2] = SLD_Real_Top// * 1e-6
	ParametersIn[3] = SLD_Imag_Top * 1e-6
	ParametersIn[4] = SLD_Real_Bot// * 1e-6
	ParametersIn[5] = SLD_Imag_Bot * 1e-6
	ParametersIn[6] = Background
	ParametersIn[7] = Roughness_Bot

	//fix to allow L1 at the bottom...
	
	if(L1AtTheBottom)
		j=0
		for(i=NumberOfLayers;i>=1;i-=1)
			j+=1
			NVAR ThicknessLayer= $("root:Packages:Refl_SimpleTool:ThicknessLayer"+Num2str(i))
			NVAR SLD_real_Layer = $("root:Packages:Refl_SimpleTool:SLD_Real_Layer"+Num2str(i))
			NVAR SLD_imag_Layer = $("root:Packages:Refl_SimpleTool:SLD_Imag_Layer"+Num2str(i))
			NVAR RoughnessLayer = $("root:Packages:Refl_SimpleTool:RoughnessLayer"+Num2str(i))
			ParametersIn[7+(j-1)*4+1] =  ThicknessLayer
			ParametersIn[7+(j-1)*4+2] =  SLD_real_Layer// * 1e-6
			ParametersIn[7+(j-1)*4+3] =  SLD_imag_Layer * 1e-6
			ParametersIn[7+(j-1)*4+4] =  RoughnessLayer
		endfor

	else
		for(i=1;i<=NumberOfLayers;i+=1)
			NVAR ThicknessLayer= $("root:Packages:Refl_SimpleTool:ThicknessLayer"+Num2str(i))
			NVAR SLD_real_Layer = $("root:Packages:Refl_SimpleTool:SLD_Real_Layer"+Num2str(i))
			NVAR SLD_imag_Layer = $("root:Packages:Refl_SimpleTool:SLD_Imag_Layer"+Num2str(i))
			NVAR RoughnessLayer = $("root:Packages:Refl_SimpleTool:RoughnessLayer"+Num2str(i))
			ParametersIn[7+(i-1)*4+1] =  ThicknessLayer
			ParametersIn[7+(i-1)*4+2] =  SLD_real_Layer// * 1e-6
			ParametersIn[7+(i-1)*4+3] =  SLD_imag_Layer * 1e-6
			ParametersIn[7+(i-1)*4+4] =  RoughnessLayer
		endfor
	endif

	Duplicate/O FitQvector, SimpleToolFitIntensity
	NVAR Resoln=root:Packages:Refl_SimpleTool:Resoln
	NVAR UseResolutionWave=root:Packages:Refl_SimpleTool:UseResolutionWave
	Wave/Z FitResolutionWave=root:Packages:Refl_SimpleTool:FitResolutionWave
	if(UseResolutionWave)	
		//SimpleToolFitIntensity=IR2R_CalculateReflectivity(ParametersIn,FitQvector,FitResolutionWave)
		//IR2R_CalculateReflectivityNewRW(ParametersIn,SimpleToolFitIntensity,ModelQvector,FitResolutionWave)
		IR2R_CalculateReflectivityNewRW(ParametersIn,SimpleToolFitIntensity,FitQvector,FitResolutionWave)
	else//use resoln
		//SimpleToolFitIntensity=IR2R_CalculateReflectivity(ParametersIn,FitQvector,Resoln)
		//ModelIntensity=IR2R_CalculateReflectivity(ParametersIn,ModelQvector,Resoln)
		//R2R_CalculateReflectivityNew(ParametersIn,SimpleToolFitIntensity,ModelQvector,Resoln)
		IR2R_CalculateReflectivityNew(ParametersIn,SimpleToolFitIntensity,FitQvector,Resoln)
	endif

	setDataFolder OldDf
	
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

static Function IR2R_CreateResolutionWave()
	//add on to create resolution wave... 
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	
	NVAR/Z Res_DeltaLambdaOverLambda
	if(!NVAR_EXISTS(Res_DeltaLambdaOverLambda))
		IR2R_InitializeSimpleTool()
	endif	
	NVAR Res_DeltaLambdaOverLambda
	NVAR Res_DeltaLambda
	NVAR Res_Lambda
	NVAR Res_SourceDivergence
	NVAR Res_DetectorSize
	NVAR Res_DetectorDistance
	NVAR Res_DetectorAngularResolution
	NVAR Res_sampleSize
	NVAR Res_beamHeight
	if(Res_Lambda==0)
		Res_Lambda=1
	endif
	if(Res_DetectorDistance==0)
		Res_DetectorDistance=1
	endif
	SVAR DataFolderName
	SVAR QWavename
	SetDataFolder $(DataFolderName)
	Wave Qwave=$(QWavename)
	Duplicate/O Qwave, CreatedFromParamaters
	Wave CreatedFromParamaters=CreatedFromParamaters
	
	setDataFolder root:Packages:Refl_SimpleTool
	DoWIndow ResolutionCalculator
	if(V_Flag)
		DoWindow/F ResolutionCalculator
	else
		//create new panel...
		//PauseUpdate; Silent 1		// building window...
		NewPanel/K=1 /W=(195,94,658,561) as "Resolution calculator"
		DoWindow/C ResolutionCalculator
		SetDrawLayer UserBack
		SetDrawEnv fsize= 22,fstyle= 1,textrgb= (0,0,52224)
		DrawText 95,35,"Create resolution data"
		SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,0,52224)
		DrawText 9,63,"Wavelength resolution"
		SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,0,52224)
		DrawText 9,148,"Source divergence resolution"
		SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,0,52224)
		DrawText 9,233,"Sample footprint resolution"
		SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,0,52224)
		DrawText 9,318,"Detector resolution"
		SetDrawEnv fsize= 14,fstyle= 1
		DrawText 9,454,"Close when finished. Resolution data are always recalculated"
		SetDrawEnv fsize= 14,fstyle= 1
		DrawText 9,434,"Set to 0 unneeded or negligible calculations"

		SetVariable Res_DeltaLambda,pos={14,70},size={180,16},proc=IR2R_ResPanelSetVarProc,title="delta Wavelength [A]"
		SetVariable Res_DeltaLambda,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_DeltaLambda, help={"Uncertaininty of wavelength in wavelength units"}
		SetVariable Res_Lambda,pos={230,70},size={180,16},proc=IR2R_ResPanelSetVarProc,title="Wavelength [A]"
		SetVariable Res_Lambda,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_Lambda, help={"wavelength in wavelength units"}
		SetVariable Res_DeltaLambdaOverLambda,pos={100,100},size={200,16},proc=IR2R_ResPanelSetVarProc,title="Wavelength resolution "
		SetVariable Res_DeltaLambdaOverLambda,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_DeltaLambdaOverLambda, help={"dLambda/Lambda"}

		SetVariable Res_SourceDivergence,pos={14,160},size={300,16},proc=IR2R_ResPanelSetVarProc,title="Source angular divergence [rad]"
		SetVariable Res_SourceDivergence,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_SourceDivergence, help={"Angular divergence of source. 0 for parallel beam."}

		SetVariable Res_sampleSize,pos={14,250},size={180,16},proc=IR2R_ResPanelSetVarProc,title="Sample size [mm] "
		SetVariable Res_sampleSize,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_sampleSize, help={"length of sample in the beam direction in mm"}
		SetVariable Res_beamHeight,pos={230,250},size={180,16},proc=IR2R_ResPanelSetVarProc,title="Beam height in [mm] "
		SetVariable Res_beamHeight,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_beamHeight, help={"Height of beam in mm in the sample position"}

		SetVariable Res_DetectorSize,pos={14,340},size={180,16},proc=IR2R_ResPanelSetVarProc,title="Detector size [mm] "
		SetVariable Res_DetectorSize,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_DetectorSize, help={"Detector slits opening (size) in scanning direction in mm"}
		SetVariable Res_DetectorDistance,pos={230,340},size={180,16},proc=IR2R_ResPanelSetVarProc,title="Detector distance [mm] "
		SetVariable Res_DetectorDistance,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_DetectorDistance, help={"Distance between detector slits and sample in mm"}
		SetVariable Res_DetectorAngularResolution,pos={100,370},size={200,16},proc=IR2R_ResPanelSetVarProc,title="Detector resolution [rad] "
		SetVariable Res_DetectorAngularResolution,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_DetectorAngularResolution, help={"Detector resolution in radians"}
	endif
	
	IR2R_ResRecalculateResolution()
	setDataFolder OldDf
	
end
///******************************************************************************************
///******************************************************************************************
static Function IR2R_ResRecalculateResolution()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	SVAR DataFolderName
	SVAR QWavename
	SetDataFolder $(DataFolderName)
	Wave Qwave=root:Packages:Refl_SimpleTool:OriginalQvector
	Wave ResWv=CreatedFromParamaters
	setDataFolder root:Packages:Refl_SimpleTool

	NVAR Res_DeltaLambdaOverLambda
	NVAR Res_SourceDivergence
	NVAR Res_DetectorAngularResolution
	NVAR Res_sampleSize
	NVAR Res_beamHeight
	NVAR Res_Lambda
	NVAR Res_DetectorDistance
	variable i
	variable curAngRes
	variable curAngle
	variable curFootprint, curDetRes
	
	for(i=0;i<numpnts(Qwave);i+=1)
		curAngle = asin(Qwave[i] * Res_Lambda /(4*pi))
		if(Res_sampleSize>0 && Res_beamHeight>0)
			curFootprint = min(Res_sampleSize,(Res_beamHeight/sin(curAngle)))
			curDetRes = curFootprint * sin(curAngle)/Res_DetectorDistance
		else
			curDetRes=0
		endif
		if(Res_DetectorAngularResolution>0)
			curAngRes = Res_DetectorAngularResolution / curAngle
		else
			curAngRes=0
		endif
		
		ResWv[i] = 100 * sqrt(curDetRes^2 + curAngRes^2 + Res_SourceDivergence^2 +Res_DeltaLambdaOverLambda^2)
	endfor

	setDataFolder OldDf
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_ResPanelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	NVAR Res_DeltaLambdaOverLambda
	NVAR Res_DeltaLambda
	NVAR Res_Lambda
	NVAR Res_SourceDivergence
	NVAR Res_DetectorSize
	NVAR Res_DetectorDistance
	NVAR Res_DetectorAngularResolution
	NVAR Res_sampleSize
	NVAR Res_beamHeight

	if (stringmatch(ctrlName,"Res_DeltaLambda") || stringmatch(ctrlName,"Res_Lambda"))
		Res_DeltaLambdaOverLambda = Res_DeltaLambda/Res_Lambda
	endif
	if (stringmatch(ctrlName,"Res_DeltaLambdaOverLambda"))
		Res_DeltaLambda = Res_DeltaLambdaOverLambda * Res_Lambda
	endif
	if (stringmatch(ctrlName,"Res_DetectorSize") || stringmatch(ctrlName,"Res_DetectorDistance"))
		Res_DetectorAngularResolution = Res_DetectorSize/Res_DetectorDistance
	endif
	if (stringmatch(ctrlName,"Res_DetectorAngularResolution"))
		Res_DetectorSize = Res_DetectorAngularResolution * Res_DetectorDistance
	endif
	
	IR2R_ResRecalculateResolution()
	setDataFolder OldDf
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

static Function IR2R_AddRemoveLayersFnct()

	string OldDf=GetDataFolder(1)
	setDataFolder   root:Packages:Refl_SimpleTool
	NVAR NumberOfLayers=root:Packages:Refl_SimpleTool:NumberOfLayers
	
	DoWindow IR2R_InsertRemoveLayers
	if(V_Flag)
		DoWindow/F IR2R_InsertRemoveLayers
	else
		Execute("IR2R_InsRemoveLayers()")
	endif

	setDataFolder OldDf
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_RemAddLayersButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"RemoveLayer"))
				ControlInfo /W=IR2R_InsertRemoveLayers SelectLayerToChange
				IR2R_RemoveLayer(V_Value)
			endif
			if(stringmatch(ba.ctrlName,"AddLayer"))
				ControlInfo /W=IR2R_InsertRemoveLayers SelectLayerToChange
				IR2R_InsertLayer(V_Value)
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

static Function IR2R_RemoveLayer(WhichLayer)
	variable WhichLayer
	string OldDf=GetDataFolder(1)
	setDataFolder  root:Packages:Refl_SimpleTool
	NVAR NumberOfLayers=root:Packages:Refl_SimpleTool:NumberOfLayers
	if(NumberOfLayers<=1)
		Abort "Cannot remove last layer, makes no sense..." 
	endif
	String ListOfVariables
	ListOfVariables="SLD_Real_Layer;SLD_Imag_Layer;ThicknessLayer;RoughnessLayer;"
	ListOfVariables+="SLD_Real_LayerError;SLD_Imag_LayerError;ThicknessLayerError;RoughnessLayerError;"
	ListOfVariables+="SLD_Real_LayerStep;SLD_Imag_LayerStep;ThicknessLayerStep;RoughnessLayerStep;"
	ListOfVariables+="SLD_Real_LayerLL;SLD_Imag_LayerLL;ThicknessLayerLL;RoughnessLayerLL;"
	ListOfVariables+="SLD_Real_LayerUL;SLD_Imag_LayerUL;ThicknessLayerUL;RoughnessLayerUL;"
	ListOfVariables+="FitSLD_Real_Layer;FitSLD_Imag_Layer;FitThicknessLayer;FitRoughnessLayer;"
	ListOfVariables+="LinkSLD_Real_Layer;LinkSLD_Imag_Layer;LinkThicknessLayer;LinkRoughnessLayer;"
	ListOfVariables+="LinkFSLD_Real_Layer;LinkFSLD_Imag_Layer;LinkFThicknessLayer;LinkFRoughnessLayer;"
	ListOfVariables+="LinkToSLD_Real_Layer;LinkToSLD_Imag_Layer;LinkToThicknessLayer;LinkToRoughnessLayer;"
	String ListOfLinkVariables	
	ListOfLinkVariables="LinkSLD_Real_Layer;LinkSLD_Imag_Layer;LinkThicknessLayer;LinkRoughnessLayer;"
	//OK, we are removing one layer, number WhichLayer
	//nothing happens with layers below, layers above move by 1 lower and we need to fix linking... 
	variable i, j 
	string tempName
	//first need to move around the Fit variables...
	For(i=1;i<=8;i+=1)
		For(j=0;j<ItemsInList(ListOfLinkVariables);j+=1)
			tempName = stringFromList(j,ListOfLinkVariables)+num2str(i)
			NVAR LinkMe = $("root:Packages:Refl_SimpleTool:"+tempName)
			if(LinkMe)
				NVAR LinkMeTo = $("root:Packages:Refl_SimpleTool:"+ReplaceString("Link", tempName, "LinkTo"))
				if(LinkMeTo<WhichLayer)
					//do nothing, this does not change
				else
					LinkMeTo = LinkMeTo-1
					PopupMenu $(ReplaceString("Link", tempName, "LinkTo")), win=IR2R_ReflSimpleToolMainPanel, popmatch = num2str(LinkMeTo)
				endif
			endif
		endfor
	endfor
	//OK, here should be fixed linking. The new links should always exist... 
	For(i=WhichLayer+1;i<8;i+=1)
		For(j=0;j<ItemsInList(ListOfVariables);j+=1)
			tempName = stringFromList(j,ListOfVariables)+num2str(i)
			NVAR HigherValue = $("root:Packages:Refl_SimpleTool:"+tempName)
			tempName = stringFromList(j,ListOfVariables)+num2str(i-1)
			NVAR LowerValue = $("root:Packages:Refl_SimpleTool:"+tempName)
			LowerValue = HigherValue
		endfor
	endfor
//	For(j=0;j<ItemsInList(ListOfVariables);j+=1)
//		tempName = stringFromList(j,ListOfVariables)+num2str(8)
//		NVAR Value = $("root:Packages:Refl_SimpleTool:"+tempName)
//		Value = 0
//	endfor
	NumberOfLayers=NumberOfLayers-1
	IR2R_TabPanelControl("",WhichLayer-1)
	TabControl DistTabs, win= IR2R_ReflSimpleToolMainPanel, value=(WhichLayer-1)
	PopupMenu NumberOfLevels, win=IR2R_ReflSimpleToolMainPanel, popmatch = num2str(NumberOfLayers)
	setDataFolder OldDf	
	DoAlert 0, "Layer "+num2str(WhichLayer)+" was removed, layers were shifted lower as needed. "
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

static Function IR2R_InsertLayer(WhichLayer)
	variable WhichLayer
	string OldDf=GetDataFolder(1)
	setDataFolder  root:Packages:Refl_SimpleTool
	NVAR NumberOfLayers=root:Packages:Refl_SimpleTool:NumberOfLayers
	if(NumberOfLayers>=8)
		Abort "Cannot insert new layer, all layers are already used" 
	endif
	String ListOfVariables
	ListOfVariables="SLD_Real_Layer;SLD_Imag_Layer;ThicknessLayer;RoughnessLayer;"
	ListOfVariables+="SLD_Real_LayerError;SLD_Imag_LayerError;ThicknessLayerError;RoughnessLayerError;"
	ListOfVariables+="SLD_Real_LayerStep;SLD_Imag_LayerStep;ThicknessLayerStep;RoughnessLayerStep;"
	ListOfVariables+="SLD_Real_LayerLL;SLD_Imag_LayerLL;ThicknessLayerLL;RoughnessLayerLL;"
	ListOfVariables+="SLD_Real_LayerUL;SLD_Imag_LayerUL;ThicknessLayerUL;RoughnessLayerUL;"
	ListOfVariables+="FitSLD_Real_Layer;FitSLD_Imag_Layer;FitThicknessLayer;FitRoughnessLayer;"
	ListOfVariables+="LinkSLD_Real_Layer;LinkSLD_Imag_Layer;LinkThicknessLayer;LinkRoughnessLayer;"
	ListOfVariables+="LinkFSLD_Real_Layer;LinkFSLD_Imag_Layer;LinkFThicknessLayer;LinkFRoughnessLayer;"
	ListOfVariables+="LinkToSLD_Real_Layer;LinkToSLD_Imag_Layer;LinkToThicknessLayer;LinkToRoughnessLayer;"
	String ListOfLinkVariables	
	ListOfLinkVariables="LinkSLD_Real_Layer;LinkSLD_Imag_Layer;LinkThicknessLayer;LinkRoughnessLayer;"
	//ListOfLinkVariables+="LinkFSLD_Real_Layer;LinkFSLD_Imag_Layer;LinkFThicknessLayer;LinkFRoughnessLayer;"
	//ListOfLinkVariables+="LinkToSLD_Real_Layer;LinkToSLD_Imag_Layer;LinkToThicknessLayer;LinkToRoughnessLayer;"
	//OK, we are inserting new layer, number WhichLayer
	//nothing happens with layers below, layers above move by 1 higher and we need to fix linking... 
	variable i, j 
	string tempName
	//first need to move around the Fit variables...
	For(i=1;i<=8;i+=1)
		For(j=0;j<ItemsInList(ListOfLinkVariables);j+=1)
			tempName = stringFromList(j,ListOfLinkVariables)+num2str(i)
			NVAR LinkMe = $("root:Packages:Refl_SimpleTool:"+tempName)
			if(LinkMe)
				NVAR LinkMeTo = $("root:Packages:Refl_SimpleTool:"+ReplaceString("Link", tempName, "LinkTo"))
				if(LinkMeTo<WhichLayer)
					//do nothing, this does not change
				else
					LinkMeTo = LinkMeTo+1
					PopupMenu $(ReplaceString("Link", tempName, "LinkTo")), win=IR2R_ReflSimpleToolMainPanel, popmatch = num2str(LinkMeTo)
				endif
			endif
		endfor
	endfor
	//OK, here should be fixed linking. The new links should always exist... 
	For(i=8;i>WhichLayer;i-=1)
		For(j=0;j<ItemsInList(ListOfVariables);j+=1)
			tempName = stringFromList(j,ListOfVariables)+num2str(i)
			NVAR HigherValue = $("root:Packages:Refl_SimpleTool:"+tempName)
			tempName = stringFromList(j,ListOfVariables)+num2str(i-1)
			NVAR LowerValue = $("root:Packages:Refl_SimpleTool:"+tempName)
			HigherValue = LowerValue
		endfor
	endfor
	For(j=0;j<ItemsInList(ListOfVariables);j+=1)
		tempName = stringFromList(j,ListOfVariables)+num2str(WhichLayer)
		NVAR Value = $("root:Packages:Refl_SimpleTool:"+tempName)
		Value = 0
	endfor
	NumberOfLayers=NumberOfLayers+1
	IR2R_TabPanelControl("",WhichLayer-1)
	TabControl DistTabs, win= IR2R_ReflSimpleToolMainPanel, value= (WhichLayer-1)
	PopupMenu NumberOfLevels, win=IR2R_ReflSimpleToolMainPanel, popmatch = num2str(NumberOfLayers)	
	setDataFolder OldDf	
	DoAlert 0, "Layer "+num2str(WhichLayer)+" was inserted, layers were shifted higher as needed. All parameters of inserted layer are set to 0. Fix before continuing"
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_InsRemoveLayers() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(389,217,687,427) as "Insert/ Remove Layers"
	DoWindow/C IR2R_InsertRemoveLayers
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 3,textrgb= (1,4,52428)
	DrawText 35,28,"Reflectivity Insert/Remove layer"
	DrawText 11,44,"Here you can remove or insert layer."
	DrawText 11,62,"Cannot insert layer if current num layers = 8. "
	DrawText 11,81,"Other layers will be moved as needed."
	DrawText 11,100,"Do NOT use to add/remove highest layer."
	string tempStr="\""
	variable i
	NVAR NumberOfLayers = root:Packages:Refl_SimpleTool:NumberOfLayers
	For(i=1;i<=NumberOfLayers;i+=1)
		tempStr+=num2str(i)+";"
	endfor
	tempStr+="\""
	PopupMenu SelectLayerToChange,pos={12,120},size={177,20},title="Select Layer to insert/remove   "
	PopupMenu SelectLayerToChange,help={"Select layer to remove or insert."}
	PopupMenu SelectLayerToChange,mode=1,mode=1,value= #tempStr
	Button RemoveLayer,pos={20,160},size={120,20},proc=IR2R_RemAddLayersButtonProc,title="Remove Layer"
	Button RemoveLayer,help={"Remove selected layer, move higher layers down. "}
	Button AddLayer,pos={153,160},size={120,20},proc=IR2R_RemAddLayersButtonProc,title="Add Layer"
	Button AddLayer,help={"Add layer in this position, move higher layers up."}
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************




Function IR2R_ReflSliderProc(sa) : SliderControl
	STRUCT WMSliderAction &sa

	//print sa.eventCode

	switch( sa.eventCode )
		//Variable curval = sa.curval
		case -1: // control being killed
			break
		case 4 : // mouse up
				string CtrlName=sa.ctrlName
				string LLName=CtrlName[0,13]+"LL"+CtrlName[16,inf]
				string ULName=CtrlName[0,13]+"UL"+CtrlName[16,inf]
				NVAR LLVal=$("root:Packages:Refl_SimpleTool:"+LLName)
				NVAR ULVal=$("root:Packages:Refl_SimpleTool:"+ULName)
				if(sa.curval==0)
					if(stringmatch(CtrlName,"*Thickness*"))
						sa.curval = 10
					elseif(stringmatch(CtrlName,"*_Real_*"))
						sa.curval = 1
					elseif(stringmatch(CtrlName,"*_Imag_*"))
						sa.curval = 1e-5
					elseif(stringmatch(CtrlName,"*Roughness*"))
						sa.curval = 1
					endif
				endif
				LLVal = sa.curval * 0.5
				ULVal = sa.curVal * 1.5
				Slider $(CtrlName), limits={(LLVal),(ULVal),0}
				NVAR AutoUpdate=root:Packages:Refl_SimpleTool:AutoUpdate
				if (AutoUpdate)
					IR2R_UpdateLinkedVariables()
					IR2R_CalculateModelResults()
					IR2R_CalculateSLDProfile()
					IR2R_GraphModelResults()	
					DoWindow IR2R_ReflSimpleToolMainPanel
					if(V_Flag)
						DoWIndow/F IR2R_ReflSimpleToolMainPanel
					endif	
				endif
		default:
			if( sa.eventCode & 1 ) // value set
				NVAR AutoUpdate=root:Packages:Refl_SimpleTool:AutoUpdate
				//print "recalculate"
				if (AutoUpdate)
					IR2R_UpdateLinkedVariables()
					IR2R_CalculateModelResults()
					IR2R_CalculateSLDProfile()
					//IR2R_GraphModelResults()		
					DoWindow IR2R_ReflSimpleToolMainPanel
					if(V_Flag)
						DoWIndow/F IR2R_ReflSimpleToolMainPanel
					endif	
				endif
				
			endif
			break
	endswitch

	return 0
End
