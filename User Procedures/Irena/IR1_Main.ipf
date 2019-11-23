#pragma TextEncoding = "UTF-8"
#pragma rtGlobals = 3	// Use strict wave reference mode and runtime bounds checking
//#pragma rtGlobals=21	// Use modern global access method.
#pragma version=2.69
#pragma IgorVersion=7.05

//DO NOT renumber Main files every time, these are main release numbers...
//define manual date and release verison 
constant CurrentIrenaVersionNumber = 2.69

//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.69 	Removed 14 ipf files to reduce clutter. 
//			Combined with IR1_CreateFldrStrctr.ipf, IR1_Functions.ipf
//			added 3DModels, 4D aggregate and Two Phase ssytems. 
//		 	POV/PDB import and fixes for 3D Models
//			Added Anisotropy analsysis (Hermans orienational parameter)
//			Create QRS folder structure should now handle also QIS data. 
//			Add print in history which version has compiled, Useful info later when debugging.
//2.68   Beta version. New 64-bit xops for OSX. 
//2.67 	heavily modified Size Distribution (added power law background). First official Igor 8 release. 
//			Nexus exporter - changed to use 1/angstrom for Q as sasView below 4.1.2 (probably below 4.3 at least) cannot convert Q units on import. 
//			Unified fit - modified how the limits and steps are handled when user set value to 0. Fixed Uncertainty analysis in Unified fit which seems to have failed on Igor 8. 
//2.66   Converted all procedure files to UTF8 to prevent text encoding issues. 
//			Fixed Case spelling of USAXS Error data to SMR_Error and DSM_Error
//			Plotting tool I - added control which enforces maximum number of items in legend (default=30). If more waves are in graph, legend gets decimated by necessary integer(2, 3, 4,...). First and last are always included. This presents selection of data names when too many data sets are used. 
//			MergeData - added ability to fit-extrapolate data 1 at high q end and added possibility to fit arbitrary combination of merging parameters. Lots of changes. More capable and more complicated. 
//			Unified Fit - added button "Copy/Swap level" which will move content of existing level to another level. 
//			Checked that - with reduced functionality - code will work without Github distributed xops. 
//			Tested and fixed for Igor 8 beta version. 
//2.65   Promoted requriements to 7.05 due to bug in HDF5 support at lower versions
//		 	Added simple recording to my web site about version checking for statistical purposes. Records Irena version, Igor platform and version.  
//			added resizing back to prior size of panel after user closes and opens the panel. 
//			Removed most DoWIndows/K and repalced with KillWIndow and number of smaller changes. 
//2.64 Updated CheckForUpdate to check on Github for latest release version
//			#pragma IgorVersion=7.00
//			removed Modeling I cocde (IR1S_ functions). Moved stuff around. 
//2.63 update to 2.62 with on lin ehelp and Igor 6 only. 
//2.62 Nexus support and other fixes, added check for desktop resolution
//2.61 fox for WIndows resolution in resizing panels
//2.60 added ShowResizeControlsPanel.  
//2.60 modified GUI preferences handling. Was reseting, wrong logic. 
//
//2.59 changed check for update procedure to check http first, tehn ftp, and the fail. 
//2.59 added WAXS tool - first releae to users. Simple fits are not made visible to users yet. 
//2.59 to be done... Added development version of Simple fits - new well structured tool for simplistic fits on SAS data.
//2.58 Added MergeData tool.  
//2.58 Added YouTube movies page. 
//2.57 Many fixes to Modeling II mainly. 
//2.56 fixed ListProRoutine which had troubles with links, 2.55 never released. 
//2.55 changed FIt Power law with cursors - follows now the user font size and does not have units (would depend on calibration). Linear fit now also sues User fonts. 
//2.55 moved Zoom and set limits to GraphMarquee menu, changed the ZoomAndSetLimits to be dynamic menu item
//2.54 version release, January 2014
//2.53  Added check for platform when opening Igor experiment. GUI fonts are really crazy if these are not fixed
//2.52 Summer 2013 release. 
//		modified Manual and Manuscript download routine to use http. ftp was failing, not sure why. 
//		changed all web addresses to new (xray.aps.anl.gov)
//2.51 added check for update to run every 30 days and remind users about proper citations.
//2.51 added Guinier-Porod model (beta version of the tool)
//2.50 major update, added uncertainity estimation to Sizes and Modeling II. Reflectivity changes. 
//2.49 Minor fixes
//2.48 Fixed GUI font/size issues on WIndows 7, Plotting tool I 3D upgrades, moved Modeling I to "Other tools"
//2.47 New mailing list, movie & 3D graphs in Plotting tool I and other many fixes.
//2.46 lots of small fixes, added easy access to scripting tool and few other changes. 
//2.45 Added features to Data manipulation II and Reflectivity. Updated manual. 
//2.44 minor fix Modeling II, Addition of controls of Modeling II to Scripting tool, other fixes. 
//2.43 add functions to handle modified panels between updates. 
//2.41 and 2.42, minor updates
//2.40 added Unified level as Form factor and other fixes and improvements
//2.39 added license for ANL

// notes from IR1_CreateFlderStrctr.ipf
//2.06 changed to use MoveWave and handle also QR data. Needs to be tested for QR data
//2.05 changed back to rtGlobals=2, need to check code much more to make it 3
//2.04 minor fix for liberal names users keep using
//2.03 converted to rtGlobals=3
//2.02 removed all font and font size from panel definitions to enable user control
//2.01 added license for ANL

//notes from IR1_Functions.ipf
//2.08 fixes to PorodsNOtebook logging requested by Dale
//2.07 added Ardell distributions support
//2.06 moved in this file some functions from retired Modeling I support - these are needed by other tools. 
//2.05 added few missing window names which need to be killed when Kill all ..." is invoked. 
//2.04 added IR2R_InsertRemoveLayers in the KillAllPanels
//2.03 changed min size to 1A sicne many users are using really high q data. 
//2.02 modified by adding Shultz-Zimm distribution, JIL, 3/17/2011
//2.01 added license for ANL

//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from usaxs.xray.aps.anl.gov/
//this package contains 
// Igor functions for modeling of SAS from various distributions of scatterers...

//Jan Ilavsky,  2010

//please, read Readme in the distribution zip file with more details on the program
//report any problems to: ilavsky@aps.anl.gov

//this file contains distribution related functions, at this time
// there are three type of distributions: LSW (Pete's request), LogNormal and Gauss (Normal)
//each requires 3 parameters, but LSW uses only the location, Normal uses two - location and scale (=width)
//only Log-normal uses all three - location, scale and shape. But all three require the three parametser - for simplicity
//Each distribution has two forms - probability distribution and cumulative distribution
//finaly, there is function used to generate distribution of diameters for each of the distributions. Lot of parameters, see the function

//Log-Normal and Normal (here called Gauss) distributions defined by NIST Engineering Statistics Handbook (http://www.itl.nist.gov/div898/handbook/index.htm)
//LSW distribution, based on Lifshitz, Slyozov, and Wagner theory as used in paper by Naser, Kuruvilla, and Smith: Compositional Effects
// on Grain Growth During Liquid Phase Sintering in Microgravity, found on web site www.space.gc.ca/science/space_science/paper_reports/spacebound97/materials_science....



// from version 2.26 I skipped numbers to match the current Irena version number (2.38) 

//report any problems to: ilavsky@aps.anl.gov
//Comment for me: Limit yourself to less than 30 items in the menu, Windows are limited to 30 items. Note: "---" counts as one item!
//comment - add these: 		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
//and these 						IN2G_PrintDebugStatement(IrenaDebugLevel, 0..5 ,"Error message")


Menu "GraphMarquee", dynamic
     IR2_MenuItemForGraph("Zoom And Set Limits","GeneralGraph"),/Q, ZoomAndSetLimits()
	//"Zoom and set limits", ZoomAndSetLimits()
End

Menu "SAS"
	help = {"Irena SAS modeling macros, version 2.54 released 1/5/2014 by Jan Ilavsky"}
	Submenu "Data import & export"
		"Import ASCII SAS data", IR1I_ImportSASASCIIDataMain()
		help={"Import Small-angle scattering data from ASCII file into Igor for use with macros"}
		"Import ASCII WAXS or other data", IR1I_ImportOtherASCIIMain()
		help={"Import Other type data from ASCII file into Igor for use with macros"}
		"Import Nexus canSAS data", IR1I_ImportNexusCanSASMain()
		help={"Import data from Nexus CanSAS conforming data sets"}
		"Import canSAS XML data", CS_XMLGUIImportDataMain(defaultType="QRS",defaultQUnits="1/A")
		help={"Import data from XML CanSAS conforming data sets"}
		"---"
		"Export Nexus canSAS or ASCII data", IR2E_UniversalDataExport()
		help = {"This is tool for export of any 2-3 column data sets as ASCII."}
	End
	"---"
	Submenu "Data Manipulation"
		"Data manipulation I [one or two data sets]",  IR1D_DataManipulation()
		help={"Merge data sets, rebin for same Q, etc..."}
		"Data manipulation II [many data sets]", IR3M_DataManipulationII()
		help={"Manipulate - for now only average - many data sets"}
		"Merge two data sets", IR3D_DataMerging()
		help={"Merge two data sets - two segments at different q ranges"}
		"Data mining [extract information]", IR2M_GetDataMiner()
		help={"Data miner to find various data and plot various waves"}
	end
	"---"
	"Plotting I", IR1P_GeneralPlotTool()
	help = {"Plotting tool with wide functionality, hopefully"}
	"Plotting II", IR2D_DWSPlotToolMain()
	help = {"Plotting tool which controls any top graph"}
		SubMenu "Support Tools for plots and tables"
		"Draw Line Of Any Slope", IR2P_DrawLineOfAnySlope()
		"Draw Line Of -4 Slope",  IR2P_DrawLineOf4Slope()
		"Draw Line Of -3 Slope",  IR2P_DrawLineOf3Slope()
		"Draw Line Of -2 Slope",  IR2P_DrawLineOf2Slope()
		"Make log-log graph decade limits", IR2P_MakeLogLogGraphDecLim()
		"--"
		"Fit Line With Cursors", IR2P_FitLineWithCursors()
		"Fit Power Law with Cursors", IR2P_FitPowerLawWithCursors()
		"--"
	       "Clone top window with data", IN2G_CloneWindow()
		End
	"---"
	"Unified Fit", IR1A_UnifiedModel()
	help = {"Modeling of SAS by modeling Guinier and Power law dependecies, based on Unified model by Gregg Beaucage"}
	"Size Distribution", IR1R_Sizes()
	help = {"SAS evaluation by regularization and maximum entropy fitting using spheroids"}
	"Modeling",IR2L_Main()
	help = {"Complicated modeling of SAS with Least square fitting or genetic optimization, allows multiple data input and is much more flexible than LSqF. Much more complicated also!)"}
	"Gunier Porod Fit", IR3GP_Main()
	help = {"Modeling of SAS as Guinier and Power law dependecies, based on Gunier-Porod model by Bualem Hammouda"}
	"Fractals model", IR1V_FractalsModel()
	help = {"Modeling of SAS by combining mass and surface fractal dependecies, based on model by Andrew Allen"}
	"Analytical models", IR2H_GelsMainFnct()
	help={"Debye-Bueche, Teubner-Strey model"}
	"Small-Angle Diffraction", IR2D_MainSmallAngleDiff()
	help={"Modeling of small angle diffraction - up to 6 peaks and Powerlaw background"}
	//"Simple Fits - under developement", IR3L_SimpleFits()
	//help={"Simple fitting of SAS data. Developement for now. Do not use. "}
	"Powder Diffraction fitting = WAXS", IR3W_WAXS()
	help={"Simple tool for analysis of WAXS/Powder diffraction data. Developement version for public."}
	"Pair distance dist. fnct.", IR2Pr_MainPDDF()
	help={"Calculate pair distribution function using various methods"}
	"Reflectivity", IR2R_ReflectivitySimpleToolMain()
	help={"Simple reflectivity model using Parrat's recursive code."}
	SubMenu "3D Models"
		"Mass Fractal Aggregate", IR3A_MassFractalAggregate()
		"Two Phase Solids", IR3T_TwoPhaseSystem()
		"Display 3D data", IR3A_Display3DData()
		"Import POV or PDB", IR3P_ImportPOVPDB()
	end
	SubMenu "Anisotropy"
		"Anisotropy analysis (HOP)", IR3N_AnisotropicSystems()
	end
	"---"
	"Scattering contrast calculator", IR1K_ScattCont2()
	help={"Calculator for scattering contrast. Both X rays and neutrons. Anomalous effects available."}
	"Config fonts, uncertainties, names",IR2C_ConfigMain()
	help={"Configure default values for GUI Panels and Graph common items, such as font sizes and font types"}

	SubMenu "Support tools"
			"Evaluate Size Distributions", IR1G_EvaluateONESample()
			help = {"Not fully finished GUI to evaluate results from methods producing size distributions"}
			"Scripting tool",  IR2S_ScriptingTool()
			help = {"Scripting tool enabes to run some tools on multiple data sets."}
			"Desmearing", IR1B_DesmearingMain()
			help={"Remove slit smearing using Lake method"}
			"Show Results notebook", IR1_CreateResultsNbk()
			help={"Shows notebook in which tools can create record of the results with graphs"}
			"Create QRS folder structure", IR1F_CreateFldrStrctMain()
			help={"Create folder structure for users with QRS data in one folder, so Irena can work well"}
			"Show SAS logbook", IR1_PullUpLoggbook()
			help = {"Some of these macros make ongoing record of what is done, you'll find it here..."}
			"Export To XLS File Panel", ExportToXLSFilePanel()
			help={"This is tool for Unified fit, made by Gragg Beaucage. For help, contact him..."}
		End
		Submenu "Help, About, Manuals, Remove Irena"
			"About", IR1_AboutPanel()
			help={"Get Panel with info about this release of Irena macros"}
			"Check for updates", IR2C_CheckIrenaUpdate(1)
			help={"Run Check for update and present citations to use in publications"}	
			"Check Igor display size", IN2G_CheckForGraphicsSetting(1)
			help={"Check if current display area is suitable for the code"}
			"---"
			"Open Irena Web page ", IR2_OpenIrenaPage()
			help={"Opens Irena web page in the browser "}
			"Open Irena web manual", IN2G_OpenWebManual("")
			help={"Opens Irena web manual in default web bropwser."}
			"Open Form and Structure Factor description", IR2T_LoadFFDescription()
			help={"Opens Description of included form factors and structure factors"}
			"Open Irena manuscript", IR2_GetIrenaManuscript()
			help={"Open or download using ftp and open Irena J. Appl. Cryst manuscript"}
			//"---"
			"Irena Mailing list signup and options", IR2_SignUpForMailingList()
			help={"Opens web page in the browser where you can sing up or control options for Irena_users mailing list."}
			"Open Youtube page with help movies", IR2_OpenYouTubeMoviePage()
			help={"Opens YouTube page in the browser where different movies showing use of Irena are available"}
			//"Open Web page with help movies", IR2_OpenHelpMoviePage()
			//help={"Opens web page in the browser where different movies showing use of Irena can be downloaded"}
			"Submit e-mail with bug or feature request", IR2C_SendEMailBugReport()
			help={"This will open your e-mail browser with some info and address. Use to submit info to me. "}
			"---"
			"Kill all Irena panels and graphs", IR1_KillGraphsAndPanels()
			help = {"If you have just too much mess with many open panels and graphs, this will close them all..."}
			"Remove Irena Package", IR1_RemoveSASMac()
			help={"Removes Irena macros from current Igor experiment"}
		end
end
Menu "Macros", dynamic
	IR2_MacrosMenuItem()
end

Function/S IR2_MacrosMenuItem()
	if((Exists("ShowResizeControlsPanel")==6))
		return "ShowResizeControlsPanel"
	else
		return ""
	endif
end

//****************************************************************************************
//****************************************************************************************
//****************************************************************************************
Function/S IR2_MenuItemForGraph(menuItem, onlyForThisGraph)
	String menuItem, onlyForThisGraph
	String topGraph=WinName(0,1,1)
	if( CmpStr(topGraph,onlyForThisGraph) == 0 )
		return menuItem
	endif
	return "" 	// disappearing menu item
End
//****************************************************************************************
//****************************************************************************************
//****************************************************************************************

static Function AfterCompiledHook( )			//check if all windows are up to date to match their code

	//these are tools which have been upgraded to this functionality 
	string WindowProcNames="LSQF2_MainPanel=IR2L_MainCheckVersion;IR2H_ControlPanel=IR2H_MainCheckVersion;DataMiningTool=IR2M_MainCheckVersion;DataManipulationII=IR3M_MainCheckVersion;"
	WindowProcNames+="IR1I_ImportData=IR1I_MainCheckVersion;IR2S_ScriptingToolPnl=IR2S_MainCheckVersion;IR1R_SizesInputPanel=IR1R_MainCheckVersion;IR1A_ControlPanel=IR1A_MainCheckVersion;"
	WindowProcNames+="IR1P_ControlPanel=IR1P_MainCheckVersion;IR2R_ReflSimpleToolMainPanel=IR2R_MainCheckVersion;IR3DP_MainPanel=IR3GP_MainCheckVersion;"
	WindowProcNames+="IR1V_ControlPanel=IR1V_MainCheckVersion;IR2D_ControlPanel=IR2D_MainCheckVersion;IR2Pr_ControlPanel=IR2Pr_MainCheckVersion;UnivDataExportPanel=IR2E_MainCheckVersion;"
	WindowProcNames+="IR1D_DataManipulationPanel=IR1D_MainCheckVersion;IR3D_DataMergePanel=IR3D_MainCheckVersion;IR3W_WAXSPanel=IR3W_MainCheckVersion;"
	WindowProcNames+="IR2D_DWSGraphPanel=IR2D_DWSMainCheckVersion;IR1I_ImportOtherASCIIData=IR1I_MainCheckVersion2;IR1I_MainCheckVersionNexus=IR1I_ImportNexusCanSASData;"
	WindowProcNames+="UnifiedEvaluationPanel=IR2U_MainCheckVersion;FractalAggregatePanel=IR3A_MainCheckVersion;TwoPhaseSystems=IR3T_MainCheckVersion;"
	WindowProcNames+="POVPDBPanel=IR3P_MainCheckVersion;AnisotropicSystemsPanel=IR3N_MainCheckVersion;"
 
	IR2C_CheckWIndowsProcVersions(WindowProcNames)
	IR2C_CheckIrenaUpdate(0)
	IN2G_CheckPlatformGUIFonts()
	IN2G_CheckForGraphicsSetting(0)
	IN2G_ResetSizesForALlPanels(WindowProcNames) 

	//and print in history which version of codeis being used for future reference.
	string file= StringFromList((ItemsInList(FunctionPath("LoadIrenaSASMacros"), ":")-1), FunctionPath("LoadIrenaSASMacros"), ":")
	String path = RemoveFromList(file, FunctionPath("LoadIrenaSASMacros") , ":")
	NewPath /O/Q TmpPathToIgorProcs  , path
	variable version = IN2G_FindVersionOfSingleFile(file,"TmpPathToIgorProcs")
	print "*** >>>  Irena version: "+num2str(version)+", compiled on "+date()+"  "+time()
	
	
end
//****************************************************************************************
//****************************************************************************************
//****************************************************************************************
 
Function IR2C_CheckWIndowsProcVersions(WindowProcNames)
	string WindowProcNames
	
	variable i  
	string PanelName
	String ProcedureName
	For(i=0;i<ItemsInList(WindowProcNames);i+=1)
		PanelName = StringFromList(0, StringFromList(i, WindowProcNames, ";")  , "=")
		ProcedureName = StringFromList(1, StringFromList(i, WindowProcNames, ";")  , "=")
		DoWIndow $(PanelName)
		if(V_Flag)
			Execute (ProcedureName+"()") 
		endif
	endfor
	
end
///////////////////////////////////////////
//****************************************************************************************
//		Default variables and strings
//
//	these are known at this time:
//		Variables=LegendSize;TagSize;AxisLabelSize;
//		Strings=FontType;
//
//	how to use:
// 	When needed insert font size through lookup function - e.g., IN2G_LkUpDfltVar("LegendSize")
//	or for font type IN2G_LkUpDfltStr("FontType")
//	NOTE: Both return string values, because that is what is generally needed!!!!
// further variables and strings can be added, but need to be added to control panel too...
//	see example in : IR1_LogLogPlotU()  in this procedure file... 


//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function IR1_UpdatePanelVersionNumber(panelName, CurentProcVersion, AddResizeHookFunction)
	string panelName
	variable CurentProcVersion
	variable AddResizeHookFunction  		//set to 0 for no, 1 for simple Irena one and 2 for Wavemetrics one
	DoWIndow $panelName
	if(V_Flag)
		GetWindow $(panelName), note
		SetWindow $(panelName), note=S_value+";"+"IrenaProcVersion:"+num2str(CurentProcVersion)+";"
		if(AddResizeHookFunction==1)
			IN2G_PanelAppendSizeRecordNote(panelName)
			SetWindow $panelName,hook(ResizePanelControls)=IN2G_PanelResizePanelSize
			IN2G_ResetPanelSize(panelName,1)
			STRUCT WMWinHookStruct s
			s.eventcode=6
			s.winName=panelName
			IN2G_PanelResizePanelSize(s)
		endif
	endif
end
//***********************************************************
//***********************************************************
Function IR1_CheckPanelVersionNumber(panelName, CurentProcVersion)
	string panelName
	variable CurentProcVersion

	DoWIndow $panelName
	if(V_Flag)	
		GetWindow $(panelName), note
		if(stringmatch(stringbyKey("IrenaProcVersion",S_value),num2str(CurentProcVersion))) //matches
			return 1
		else
			return 0
		endif
	else
		return 1
	endif
end

//**********************************************************************************************************
//**********************************************************************************************************
//this is added into selection in Marquee.
//if run, sets limits to marquee selection and switches into manual mode for axis range
Function ZoomAndSetLimits()
	//this will zoom graph and set limits to the appropriate numbers
	GetMarquee/K left, bottom
	if(!stringmatch(S_MarqueeWin"GeneralGraph"))
		return 0	
	endif
	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	ListOfGraphFormating=ReplaceStringByKey("Axis left auto",ListOfGraphFormating,"0","=" )
	ListOfGraphFormating=ReplaceStringByKey("Axis bottom auto",ListOfGraphFormating,"0","=" )
	ListOfGraphFormating=ReplaceStringByKey("Axis left min",ListOfGraphFormating,num2str(V_bottom),"=" )
	ListOfGraphFormating=ReplaceStringByKey("Axis left max",ListOfGraphFormating,num2str(V_top),"=" )
	ListOfGraphFormating=ReplaceStringByKey("Axis bottom min",ListOfGraphFormating,num2str(V_left),"=" )
	ListOfGraphFormating=ReplaceStringByKey("Axis bottom max",ListOfGraphFormating,num2str(V_right),"=" )
	IR1P_SynchronizeListAndVars()
	IR1P_UpdateGenGraph()
end
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************

Function IR2C_ConfigMain()		//call configuration routine
	IN2G_ConfigMain()
end


//***********************************************************
//***********************************************************
//***********************************************************

////***********************************************************
//***********************************************************
//***********************************************************

Function IR2C_SendEMailBugReport()

	string url, separator
	if(stringmatch(StringByKey("OS", IgorInfo(3) , ":" , ";"), "*Macintosh*" ))
		separator="\n"
	else
		separator="%0A"
	endif
	url="mailto:ilavsky@aps.anl.gov?subject=Irena ver "+num2str(CurrentIrenaVersionNumber)+" bug or user comment"
	url+="&body=The problem or bug occurred on "+separator
	url+="IgorInfo(0) = "+IgorInfo(0)+separator
	url+="IgorInfo(3) = "+IgorInfo(3)+separator+separator
	url+="Please attach notes about the bug or request for new features. If necessary attach your Igor experiment. Thank You J.I."+separator
	BrowseURL url
end

//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
///////////////////////////////////////////

Proc IR2P_FitLineWithCursors()

	string destwavename="fit_"+CsrWave(A)
	CurveFit line CsrWaveRef(A)(xcsr(A),xcsr(B)) /X=CsrXWaveRef(A) /D
	Tag/C/N=Curvefitres/F=0/A=MC $destwavename, 0.5*numpnts($destwavename), "\Z"+IN2G_LkUpDfltVar("LegendSize")+"Linear fit parameters are: \ry="+num2str(W_coef[0])+"+ x *"+num2str(W_coef[1])
end
//*****************************************
//*****************************************
//*****************************************

Proc IR2P_FitPowerLawWithCursors()

	string olddf=GetDataFolder(1)
	NewDataFolder/O/S root:Packages:FittingData
	
	string name="MyFitWave"
	string LegendName="Curvefitres"
	
	variable freeDestNum=IR2P_FindFreeDestWaveNumber(name)
	name=name +num2istr(freeDestNum)
	LegendName=LegendName+num2istr(freeDestNum)
	Make/D/O/N=(numpnts($(getWavesDataFolder(CsrWaveRef(A),2)))) LogYFitData, $name
	$name=NaN
	Make/D/O/N=(numpnts($(getWavesDataFolder(CsrXWaveRef(A),2)))) LogXFitData
	LogXFitData=log($(getWavesDataFolder(CsrXWaveRef(A),2)))
	LogYFitData=log($(getWavesDataFolder(CsrWaveRef(A),2)))
	CurveFit line LogYFitData(xcsr(A),xcsr(B)) /X=LogXFitData /D=$name
		
	IR2P_LogPowerWithNaNsRetained($name)
	
	//here we will try to figure out, if the data are plotted wrt to left or right axis...
	string YwvName=CsrWave(A)
	string AxType=StringByKey("AXISFLAGS", TraceInfo("",YwvName,0) )//this checks only for first occurence of the wave with this name
	//this needs to be made more clever, other axis and other occurences of the wave with the name...
	if (cmpstr(AxType,"/R")==0)
		Append/R $name vs CsrXWaveRef(A)
	else
		Append $name vs CsrXWaveRef(A)
	endif
	Modify lsize($name)=2
	String pw=num2str(K1),pr=num2str(10^K0),DIN=num2str((V_siga*10^K0)/2.3026),ca=num2str(pcsr(A)),cb=num2str(pcsr(B)),gf=num2str(V_Pr),DP=num2str(V_sigb)
	string LSs=IN2G_LkUpDfltVar("LegendSize")
	Tag/C/N=$LegendName/F=0/A=MC  $name, (pcsr(A)+pcsr(B))/2, "\Z"+LSs+"Power Law Slope= "+pw+"\Z"+LSs+" ± "+DP+"\Z"+LSs+"\rPrefactor= "+pr+"\Z"+LSs+" ± "+DIN+"\Z"+LSs+"\rx Cursor A::B= "+ca+"\Z"+LSs+" :: "+cb+"\Z"+LSs+"\rGoodness of fit= "+gf

	KillWaves/Z LogYFitData, LogXFitData

	SetDataFolder $olddf
end
//*****************************************
//*****************************************
//*****************************************

Function IR2P_FindFreeDestWaveNumber(name)
	string name
	
	variable i=0
	Do
		if (exists(name+num2istr(i))==0)
			return i
		endif
	i+=1
	while (i<50)
end
//*****************************************
//*****************************************
//*****************************************

Function IR2P_LogPowerWithNaNsRetained(MyFitWave)
	wave MyFitWave
	
	variable PointsNumber=numpnts(MyFitWave)
	variable i=0
	Do
		if (numtype(MyFitWave[i])==0)
			MyFitWave[i]=10^(MyFitWave[i])
		endif
	i+=1
	while (i<PointsNumber)
end
//*****************************************
//*****************************************
//*****************************************

Function IR2P_DrawLineOf3Slope()
	IR2P_DrawLineOfRequiredSlope(3,3,1,"-3")
End

//*****************************************
//*****************************************
//*****************************************

Function IR2P_DrawLineOf2Slope()
	IR2P_DrawLineOfRequiredSlope(2,2,1,"-2")
End
//*****************************************

Function IR2P_DrawLineOf4Slope()
	IR2P_DrawLineOfRequiredSlope(4,4,1,"-4")
End
//*****************************************
Function IR2P_DrawLineOfAnySlope()

	Variable lineslope,YourNumber,qlabel
	string label1
	Prompt lineslope, "Enter slope of line, or select Your number",Popup,"M1;M2;M3;M4;M5;M3.5;M4.5;M2.5;M1.5;Your Number;Vertical;Horizontal;5/3"
	Prompt YourNumber,"If Your number above selected, enter here a number for the slope:"
	Prompt qlabel,"Add a Label?",popup,"Power From Above;My own;No"
	Prompt label1,"If Yes, then here type your label?"

	DoPrompt "Draw line of any slope, select parameters", lineslope, Yournumber, qlabel, label1
	if (V_Flag)
			Abort
	endif
	Silent 1
	do
		if(lineslope==12)
			lineslope=0
			break
		endif
		if(lineslope==10)
			lineslope=YourNumber
			break
		endif
		if(lineslope==6)
			lineslope=3.5
			break
		endif
		if(lineslope==7)
			lineslope=4.5
			break
		endif
		if(lineslope==8)
			lineslope=2.5
			break
		endif
		if(lineslope==9)
			lineslope=1.5
			break
		endif
		if(lineslope==13)
			lineslope=5/3
			break
		endif
		break
	while(1)

	IR2P_DrawLineOfRequiredSlope(LineSlope,YourNumber,qLabel,label1)
end


Function IR2P_DrawLineOfRequiredSlope(LineSlope,YourNumber,qLabel,label1)
	Variable lineslope,YourNumber,qlabel
	string label1
	
	if(wintype("")!=1)
		Abort "Top window is not graph, make sure the top window is graph before use of this function"
	endif
	
	SetDrawEnv xcoord= bottom,ycoord= left,save
	variable X_start, Y_start
	getAxis bottom
	X_start=ceil((floor(log(V_max))+floor(log(V_min)))/2)
	getAxis left
	Y_start=ceil((ceil(log(V_max))+ceil(log(V_min)))/2)
	if(lineslope==11)														//Vertical
		drawline 10^(X_start),10^(Y_start),10^(X_start+1),10^(Y_start)
	else
		drawline 10^(X_start),10^(Y_start),10^(X_start+1),10^(Y_start-lineslope)
	endif
	if(qlabel==2)
		SetDrawEnv fname= "Times",fstyle= 1;DelayUpdate
		DrawText 10^(X_start),10^(Y_start-1),Label1
	else
		if(qlabel==1)//use power from above
			SetDrawEnv fname= "Times",fstyle= 1;DelayUpdate
			DrawText 10^(X_start),10^(Y_start-1),("-"+num2str(lineslope))
		endif
	endif
EndMacro



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2_GetIrenaManuscript()

		string WhereIsManuscript
		string WhereAreProcedures=RemoveEnding(FunctionPath(""),"IR1_Main.ipf")
		String ManuscriptPath = ParseFilePath(5,"IrenaManuscript.pdf","*",0,0)
       	String cmd 
	print "Irena manuscript reference: "
	print "Jan Ilavsky and Pete R. Jemian, Irena: tool suite for modeling and analysis of small-angle scattering"
	print "Journal of Applied Crystallography (2009), 42, 347-353"
	variable refnum
	GetFileFolderInfo/Z=1/Q WhereAreProcedures+ManuscriptPath
	variable foundIt=V_Flag
	if(foundIt!=0)
       	NewPath/O/Q tempPath, WhereAreProcedures
		DoAlert 1,  "Local copy of manuscript not found. Should Igor try to download from APS public web site?"
		if(V_Flag==1)
//			string url="ftp://ftp.xray.aps.anl.gov/pub/usaxs/IrenaManuscript.pdf"
//			FTPDownload /O/V=7/P=tempPath/Z url, "IrenaManuscript.pdf"	
//			if(V_flag!=0)	//ftp failed...
//				Abort "ftp of manuscript failed, please send e-mail to author to get your copy"
//			endif
			//string url="ftp://ftp.xray.aps.anl.gov/pub/usaxs/Irena Manual.pdf"		
			string httpPath =  ReplaceString(" ", "http://ftp.xray.aps.anl.gov/usaxs/IrenaManuscript.pdf", "%20")		//handle just spaces here... 
			String fileBytes, tempPathStr
			Variable error = GetRTError(1)
			 fileBytes = FetchURL(httpPath)
			 error = GetRTError(1)
			 sleep/S 0.2
			 if(error!=0)
				 print "Manuscript download FAILED, please download from directly from Irena web page "
			else
				Open/P=tempPath  refNum as "IrenaManuscript.pdf"
				FBinWrite refNum, fileBytes
				Close refNum
				SetFileFolderInfo/P=tempPath/RO=0  "IrenaManuscript.pdf"		
			endif
		else
			abort
		endif
		killPath tempPath
	endif
	
	
	if (stringmatch(IgorInfo(2), "*Macintosh*"))
               sprintf cmd "tell application \"Finder\" to open \"%s\"",WhereAreProcedures+ManuscriptPath
               ExecuteScriptText cmd
      		if (strlen(S_value)>2)
//			DoAlert 0, S_value
		endif

	else 
		WhereAreProcedures=ParseFilePath(5,WhereAreProcedures,"*",0,0)
		WhereIsManuscript = "\"" + WhereAreProcedures+ManuscriptPath+"\""
		NewNotebook/F=0 /N=NewBatchFile
		Notebook NewBatchFile, text=WhereIsManuscript//+"\r"
		SaveNotebook/O NewBatchFile as SpecialDirPath("Temporary", 0, 1, 0 )+"StartManual.bat"
		KillWIndow/Z NewBatchFile
		ExecuteScriptText "\""+SpecialDirPath("Temporary", 0, 1, 0 )+"StartManual.bat\""
	endif


end

//*****************************************************************************************************************
//*****************************************************************************************************************
//Function IR2_OpenIrenaManual()
//	//this function writes batch file and starts the manual.
//	//we need to write following batch file: "C:\Program Files\WaveMetrics\Igor Pro Folder\User Procedures\Irena\Irena manual.pdf"
//	//on Mac we just fire up the Finder with Mac type path... 
//	DoAlert /T="PDF manuals removed" 0, "pdf manuals are not distributed with the packages anymore. Use web manuals. If needed download pdf file from the web" 
//	//check where we run...
//		//string WhereIsIgor
//		//pathInfo Igor
////		string WhereIsManual
////		string WhereAreProcedures=RemoveEnding(FunctionPath(""),"IR1_Main.ipf")
////		String manualPath = ParseFilePath(5,"Irena Manual.pdf","*",0,0)
////       	String cmd 
////	
////	variable refnum
////	GetFileFolderInfo/Z=1/Q WhereAreProcedures+manualPath
////	variable foundIt=V_Flag
////	variable ManualModDate=V_modificationDate
////	printf "The current manual date is: %+015.4f\r", V_modificationDate
////	if(ManualModDate>0)
////		//print  V_modificationDate
////		print "Found version of Manual is from : " + secs2Date(ManualModDate,1)
////	endif
////	if(foundIt!=0 || ManualModDate<CurrentManualDateInSecs)
////       	NewPath/O/Q tempPath, WhereAreProcedures
////		DoAlert 1,  "Local copy of manual not found or is obsolete. Should Igor try to download from APS public web site?"
////		if(V_Flag==1)
////			//string url="ftp://ftp.xray.aps.anl.gov/pub/usaxs/Irena Manual.pdf"		
////			string httpPath =  ReplaceString(" ", "http://ftp.xray.aps.anl.gov/usaxs/Irena Manual.pdf", "%20")		//handle just spaces here... 
////			String fileBytes, tempPathStr
////			Variable error = GetRTError(1)
////			 fileBytes = FetchURL(httpPath)
////			 error = GetRTError(1)
////			 sleep/S 0.2
////			 if(error!=0)
////				 print "Manual download FAILED, please download from directly from Irena web page "
////			else
////				Open/P=tempPath  refNum as "Irena Manual.pdf"
////				FBinWrite refNum, fileBytes
////				Close refNum
////				SetFileFolderInfo/P=tempPath/RO=0  "Irena Manual.pdf"		
////			endif
////		else
////			abort
////		endif
////		killPath tempPath	
////	endif
////	
////	if (stringmatch(IgorInfo(2), "*Macintosh*"))
////             //  manualPath = "User Procedures:Irena:Irena manual.pdf"
////               sprintf cmd "tell application \"Finder\" to open \"%s\"",WhereAreProcedures+manualPath
////               ExecuteScriptText cmd
////      		if (strlen(S_value)>2)
//////			DoAlert 0, S_value
////		endif
////
////	else 
////		//manualPath = "User Procedures\Irena\Irena manual.pdf"
////		//WhereIsIgor=WhereIsIgor[0,1]+"\\"+IN2G_ChangePartsOfString(WhereIsIgor[2,inf],":","\\")
////		WhereAreProcedures=ParseFilePath(5,WhereAreProcedures,"*",0,0)
////		whereIsManual = "\"" + WhereAreProcedures+manualPath+"\""
////		NewNotebook/F=0 /N=NewBatchFile
////		Notebook NewBatchFile, text=whereIsManual//+"\r"
////		SaveNotebook/O NewBatchFile as SpecialDirPath("Temporary", 0, 1, 0 )+"StartManual.bat"
////		KillWIndow/Z NewBatchFile
////		ExecuteScriptText "\""+SpecialDirPath("Temporary", 0, 1, 0 )+"StartManual.bat\""
////	endif
//end
////*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2_OpenHelpMoviePage()
	DoAlert 1,"Your web browser will open page with help movies. OK? (You must have QuickTime installed)"
	if(V_flag==1)
		//BrowseURL "http://usaxs.xray.aps.anl.gov/staff/ilavsky/IrenaHelpMovies.html"
		BrowseURL "https://www.youtube.com/channel/UCDTzjGr3mAbRi3O4DJG7xHA/feed"
	endif
End

Function IR2_OpenYouTubeMoviePage()
	DoAlert 1,"Your web browser will open Youtube page with help movies. OK?"
	if(V_flag==1)
		BrowseURL "https://www.youtube.com/channel/UCDTzjGr3mAbRi3O4DJG7xHA/feed"
	endif
End



Function IR2_OpenIrenaPage()
	DoAlert 1,"Your web browser will Irena home page. OK?"
	if(V_flag==1)
		BrowseURL "https://usaxs.xray.aps.anl.gov/software/irena"
	endif
End

Function IR2_SignUpForMailingList()
	DoAlert 1,"Your web browser will open page with the page where you can control your maling list options. OK?"
	if(V_flag==1)
		BrowseURL "https://mailman.aps.anl.gov/mailman/listinfo/irena_users"
	endif
End



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1_AboutPanel()
	KillWIndow/Z About_Irena_1_Macros
//	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(173.25,50,580,460)/N=About_Irena_1_Macros as "About Irena Macros"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 1,textrgb= (16384,28160,65280)
	DrawText 23,30,"Irena macros for Igor Pro 7 & 8"
	SetDrawEnv fsize= 16,textrgb= (16384,28160,65280)
	DrawText 100,60,"@ ANL, 2018"
	DrawText 10,80,"release "+num2str(CurrentIrenaVersionNumber)
	DrawText 11,100,"To get help please contact: ilavsky@aps.anl.gov"
	SetDrawEnv textrgb= (0,0,65535)
	DrawText 11,120,"http://usaxs.xray.aps.anl.gov/staff/ilavsky/irena.htm"
	SetDrawEnv fsize= 14, fstyle=1
	DrawText 11,148,"Reference: Jan Ilavsky and Pete R. Jemian"
	SetDrawEnv fsize= 14, fstyle=1
	DrawText 11,168,"J Appl Crystallogr (2009), 42, 347-353"

	DrawText 11,195,"Size distribution by Pete Jemian: jemian@anl.gov"
	DrawText 11,215,"Unified model by Gregg Beaucage: gbeaucag@uceng.uc.edu"
	DrawText 11,230," Beaucage, G. (1995). J Appl Crystallogr 28, 717-728."
	DrawText 11,250," Fractals model by Andrew Allen: Andrew.Allen@nist.gov"
	DrawText 11,265," Allen, A. J. (2005). J Am Ceram Soc 88, 1367-1381. "
	DrawText 11,285," Reflectivity & Genetic Optimization by Andrew Nelson "
	DrawText 11,300," (Australian Nuclear Science and Technology Organisation) "
	DrawText 11,315,"             Nelson, A. (2006). J Appl Crystallogr 39, 273-276."
	DrawText 11,330,"             andyfaff@gmail.com"
	DrawText 11,350,"Selected Structure & Form Factors refs: "
	DrawText 11,365,"       Kline, S. R. (2006). J Appl Crystallogr 39, 895-900"
	DrawText 11,380,"http://www.ncnr.nist.gov/programs/sans/data/data_red.html"
// ().	
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1_RemoveSASMac()
		Execute/P "IR1_KillGraphsAndPanels()"
		Execute/P "DELETEINCLUDE \"IR1_Loader\""
		SVAR strChagne=root:Packages:SASItem1Str
		strChagne= "Load Irena SAS Macros"
		BuildMenu "SAS"
		Execute/P "COMPILEPROCEDURES "
end



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1S_Initialize()
//	//function, which creates the folder for SAS modeling and creates the strings and variables
//	
//	string oldDf=GetDataFolder(1)
//	
//	NewDataFolder/O/S root:Packages
//	NewdataFolder/O/S root:Packages:SAS_Modeling
//	
//	string ListOfVariables
//	string ListOfStrings
//	
//	//here define the lists of variables and strings needed, separate names by ;...
//	
//	ListOfVariables="UseIndra2Data;UseQRSdata;NumberOfDistributions;DisplayVD;DisplayND;CurrentTab;UseInterference;UseLSQF;UseGenOpt;"
//	ListOfVariables+="Dist1NumberOfPoints;Dist1Contrast;Dist1Location;Dist1Scale;Dist1Shape;Dist1Mean;Dist1Median;Dist1Mode;Dist1LocHighLimit;Dist1LocLowLimit;Dist1ScaleHighLimit;Dist1ScaleLowLimit;"
//	ListOfVariables+="Dist1ShapeHighLimit;Dist1ShapeLowLimit;Dist1LocStep;Dist1ShapeStep;Dist1ScaleStep;Dist1FitShape;Dist1FitLocation;Dist1FitScale;Dist1VolFraction;"
//	ListOfVariables+="Dist1VolHighLimit;Dist1VolLowLimit;Dist1FitVol;Dist1NegligibleFraction;Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3;Dist1FWHM;"
//	ListOfVariables+="Dist2NumberOfPoints;Dist2Contrast;Dist2Location;Dist2Scale;Dist2Shape;Dist2Mean;Dist2Median;Dist2Mode;Dist2LocHighLimit;Dist2LocLowLimit;Dist2ScaleHighLimit;Dist2ScaleLowLimit;"
//	ListOfVariables+="Dist2ShapeHighLimit;Dist2ShapeLowLimit;Dist2LocStep;Dist2ShapeStep;Dist2ScaleStep;Dist2FitShape;Dist2FitLocation;Dist2FitScale;Dist2VolFraction;"
//	ListOfVariables+="Dist2VolHighLimit;Dist2VolLowLimit;Dist2FitVol;Dist2NegligibleFraction;Dist2ScatShapeParam1;Dist2ScatShapeParam2;Dist2ScatShapeParam3;Dist2FWHM;"
//	ListOfVariables+="Dist3NumberOfPoints;Dist3Contrast;Dist3Location;Dist3Scale;Dist3Shape;Dist3Mean;Dist3Median;Dist3Mode;Dist3LocHighLimit;Dist3LocLowLimit;Dist3ScaleHighLimit;Dist3ScaleLowLimit;"
//	ListOfVariables+="Dist3ShapeHighLimit;Dist3ShapeLowLimit;Dist3LocStep;Dist3ShapeStep;Dist3ScaleStep;Dist3FitShape;Dist3FitLocation;Dist3FitScale;Dist3VolFraction;"
//	ListOfVariables+="Dist3VolHighLimit;Dist3VolLowLimit;Dist3FitVol;Dist3NegligibleFraction;Dist3ScatShapeParam1;Dist3ScatShapeParam2;Dist3ScatShapeParam3;Dist3FWHM;"
//	ListOfVariables+="Dist4NumberOfPoints;Dist4Contrast;Dist4Location;Dist4Scale;Dist4Shape;Dist4Mean;Dist4Median;Dist4Mode;Dist4LocHighLimit;Dist4LocLowLimit;Dist4ScaleHighLimit;Dist4ScaleLowLimit;"
//	ListOfVariables+="Dist4ShapeHighLimit;Dist4ShapeLowLimit;Dist4LocStep;Dist4ShapeStep;Dist4ScaleStep;Dist4FitShape;Dist4FitLocation;Dist4FitScale;Dist4VolFraction;"
//	ListOfVariables+="Dist4VolHighLimit;Dist4VolLowLimit;Dist4FitVol;Dist4NegligibleFraction;Dist4ScatShapeParam1;Dist4ScatShapeParam2;Dist4ScatShapeParam3;Dist4FWHM;"
//	ListOfVariables+="Dist5NumberOfPoints;Dist5Contrast;Dist5Location;Dist5Scale;Dist5Shape;Dist5Mean;Dist5Median;Dist5Mode;Dist5LocHighLimit;Dist5LocLowLimit;Dist5ScaleHighLimit;Dist5ScaleLowLimit;"
//	ListOfVariables+="Dist5ShapeHighLimit;Dist5ShapeLowLimit;Dist5LocStep;Dist5ShapeStep;Dist5ScaleStep;Dist5FitShape;Dist5FitLocation;Dist5FitScale;Dist5VolFraction;"
//	ListOfVariables+="Dist5VolHighLimit;Dist5VolLowLimit;Dist5FitVol;Dist5NegligibleFraction;Dist5ScatShapeParam1;Dist5ScatShapeParam2;Dist5ScatShapeParam3;Dist5FWHM;"
//	ListOfVariables+="SASBackground;SASBackgroundStep;FitSASBackground;UseNumberDistribution;UseVolumeDistribution;UpdateAutomatically;"
//	ListOfVariables+="SASBackgroundError;Dist1LocationError;Dist1ScaleError;Dist1ShapeError;Dist1VolFractionError;"
//	ListOfVariables+="Dist1LocationError;Dist1ScaleError;Dist1ShapeError;Dist1VolFractionError;"
//	ListOfVariables+="Dist2LocationError;Dist2ScaleError;Dist2ShapeError;Dist2VolFractionError;"
//	ListOfVariables+="Dist3LocationError;Dist3ScaleError;Dist3ShapeError;Dist3VolFractionError;"
//	ListOfVariables+="Dist4LocationError;Dist4ScaleError;Dist4ShapeError;Dist4VolFractionError;"
//	ListOfVariables+="Dist5LocationError;Dist5ScaleError;Dist5ShapeError;Dist5VolFractionError;"
//	ListOfVariables+="Dist1UseInterference;Dist1InterferencePhi;Dist1InterferenceEta;Dist1InterferencePhiLL;Dist1InterferencePhiHL;Dist1InterferenceEtaLL;Dist1InterferenceEtaHL;"
//	ListOfVariables+="Dist2UseInterference;Dist2InterferencePhi;Dist2InterferenceEta;Dist2InterferencePhiLL;Dist2InterferencePhiHL;Dist2InterferenceEtaLL;Dist2InterferenceEtaHL;"
//	ListOfVariables+="Dist3UseInterference;Dist3InterferencePhi;Dist3InterferenceEta;Dist3InterferencePhiLL;Dist3InterferencePhiHL;Dist3InterferenceEtaLL;Dist3InterferenceEtaHL;"
//	ListOfVariables+="Dist4UseInterference;Dist4InterferencePhi;Dist4InterferenceEta;Dist4InterferencePhiLL;Dist4InterferencePhiHL;Dist4InterferenceEtaLL;Dist4InterferenceEtaHL;"
//	ListOfVariables+="Dist5UseInterference;Dist5InterferencePhi;Dist5InterferenceEta;Dist5InterferencePhiLL;Dist5InterferencePhiHL;Dist5InterferenceEtaLL;Dist5InterferenceEtaHL;"
//	ListOfVariables+="Dist1FitInterferencePhi;Dist2FitInterferencePhi;Dist3FitInterferencePhi;Dist4FitInterferencePhi;Dist5FitInterferencePhi;"
//	ListOfVariables+="Dist1FitInterferenceETA;Dist2FitInterferenceETA;Dist3FitInterferenceETA;Dist4FitInterferenceETA;Dist5FitInterferenceETA;"
//	ListOfVariables+="Dist1InterferencePhiError;Dist1InterferenceEtaError;Dist2InterferencePhiError;Dist2InterferenceEtaError;"
//	ListOfVariables+="Dist3InterferencePhiError;Dist3InterferenceEtaError;Dist4InterferencePhiError;Dist4InterferenceEtaError;"
//	ListOfVariables+="Dist5InterferencePhiError;Dist5InterferenceEtaError;"	
//	ListOfVariables+="UseSlitSmearedData;SlitLength;"	
//	//Ok add chance to fit the shape parameters
//	ListOfVariables+="Dist1FitScatShapeParam1;Dist1ScatShapeParam1LowLimit;Dist1ScatShapeParam1HighLimit;Dist1FitScatShapeParam2;Dist1ScatShapeParam2LowLimit;Dist1ScatShapeParam2HighLimit;Dist1FitScatShapeParam3;Dist1ScatShapeParam3LowLimit;Dist1ScatShapeParam3HighLimit;"
//	ListOfVariables+="Dist2FitScatShapeParam1;Dist2ScatShapeParam1LowLimit;Dist2ScatShapeParam1HighLimit;Dist2FitScatShapeParam2;Dist2ScatShapeParam2LowLimit;Dist2ScatShapeParam2HighLimit;Dist2FitScatShapeParam3;Dist2ScatShapeParam3LowLimit;Dist2ScatShapeParam3HighLimit;"
//	ListOfVariables+="Dist3FitScatShapeParam1;Dist3ScatShapeParam1LowLimit;Dist3ScatShapeParam1HighLimit;Dist3FitScatShapeParam2;Dist3ScatShapeParam2LowLimit;Dist3ScatShapeParam2HighLimit;Dist3FitScatShapeParam3;Dist3ScatShapeParam3LowLimit;Dist3ScatShapeParam3HighLimit;"
//	ListOfVariables+="Dist4FitScatShapeParam1;Dist4ScatShapeParam1LowLimit;Dist4ScatShapeParam1HighLimit;Dist4FitScatShapeParam2;Dist4ScatShapeParam2LowLimit;Dist4ScatShapeParam2HighLimit;Dist4FitScatShapeParam3;Dist4ScatShapeParam3LowLimit;Dist4ScatShapeParam3HighLimit;"
//	ListOfVariables+="Dist5FitScatShapeParam1;Dist5ScatShapeParam1LowLimit;Dist5ScatShapeParam1HighLimit;Dist5FitScatShapeParam2;Dist5ScatShapeParam2LowLimit;Dist5ScatShapeParam2HighLimit;Dist5FitScatShapeParam3;Dist5ScatShapeParam3LowLimit;Dist5ScatShapeParam3HighLimit;"
//	ListOfVariables+="Dist1ScatShapeParam4;Dist1ScatShapeParam5;"
//	ListOfVariables+="Dist2ScatShapeParam4;Dist2ScatShapeParam5;"
//	ListOfVariables+="Dist3ScatShapeParam4;Dist3ScatShapeParam5;"
//	ListOfVariables+="Dist4ScatShapeParam4;Dist4ScatShapeParam5;"
//	ListOfVariables+="Dist5ScatShapeParam4;Dist5ScatShapeParam5;"
//	ListOfVariables+="Dist1ScatShapeParam1Error;Dist1ScatShapeParam2Error;Dist1ScatShapeParam3Error;"
//	ListOfVariables+="Dist2ScatShapeParam1Error;Dist2ScatShapeParam2Error;Dist2ScatShapeParam3Error;"
//	ListOfVariables+="Dist3ScatShapeParam1Error;Dist3ScatShapeParam2Error;Dist3ScatShapeParam3Error;"
//	ListOfVariables+="Dist4ScatShapeParam1Error;Dist4ScatShapeParam2Error;Dist4ScatShapeParam3Error;"
//	ListOfVariables+="Dist5ScatShapeParam1Error;Dist5ScatShapeParam2Error;Dist5ScatShapeParam3Error;WallThicknessSpreadInFract;"
//	ListOfVariables+="Dist1UserFFParam1;Dist1UserFFParam2;Dist1UserFFParam3;Dist1UserFFParam4;Dist1UserFFParam5;"
//	ListOfVariables+="Dist2UserFFParam1;Dist2UserFFParam2;Dist2UserFFParam3;Dist2UserFFParam4;Dist2UserFFParam5;"
//	ListOfVariables+="Dist3UserFFParam1;Dist3UserFFParam2;Dist3UserFFParam3;Dist3UserFFParam4;Dist3UserFFParam5;"
//	ListOfVariables+="Dist4UserFFParam1;Dist4UserFFParam2;Dist4UserFFParam3;Dist4UserFFParam4;Dist4UserFFParam5;"
//	ListOfVariables+="Dist5UserFFParam1;Dist5UserFFParam2;Dist5UserFFParam3;Dist5UserFFParam4;Dist5UserFFParam5;"
//
//	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
//	ListOfStrings+="Dist1ShapeModel;Dist1DistributionType;Dist1UserFormFactorFnct;Dist1UserVolumeFnct;"
//	ListOfStrings+="Dist2ShapeModel;Dist2DistributionType;Dist2UserFormFactorFnct;Dist2UserVolumeFnct;"
//	ListOfStrings+="Dist3ShapeModel;Dist3DistributionType;Dist3UserFormFactorFnct;Dist3UserVolumeFnct;"
//	ListOfStrings+="Dist4ShapeModel;Dist4DistributionType;Dist4UserFormFactorFnct;Dist4UserVolumeFnct;"
//	ListOfStrings+="Dist5ShapeModel;Dist5DistributionType;Dist5UserFormFactorFnct;Dist5UserVolumeFnct;"
//	
//	String/g GaussEquation="P(x)=(1/(Width*sqrt(2*pi)) * exp(-(x-Mean)^2/(2*Width^2))"
//	String/g LogNormalEquation="P(x)=(1/((x-Min)*Mean*sqrt(2*pi)) * exp(-ln((x-Mean)/sdev)^2/(2*sdev^2))"
//	String/g LSWEquation="P(x)=A*(loc^2*exp(-loc/(1.5-loc)))/((1.5-loc)^(11/3)*(3+loc)^(7/3))"
//	String/g PowerLawEquation="P(x)= x ^ -(1+(6-slope))"
//	
//	variable i
//	//and here we create them
//	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
//		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
//	endfor		
//				
//	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
//		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
//	endfor	
//	//cleanup after possible previous fitting stages...
//	Wave/Z CoefNames=root:Packages:SAS_Modeling:CoefNames
//	Wave/Z CoefficientInput=root:Packages:SAS_Modeling:CoefficientInput
//	KillWaves/Z CoefNames, CoefficientInput
//	
//	IR1S_SetInitialValues()
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1S_SetInitialValues()
//	//and here set default values...
//
//	string OldDf=getDataFolder(1)
//	setDataFolder root:Packages:SAS_Modeling
//	NVAR UseQRSData=root:Packages:SAS_Modeling:UseQRSData
//	NVAR UseIndra2data=root:Packages:SAS_Modeling:UseIndra2data
//	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
//	NVAR DisplayND=root:Packages:SAS_Modeling:DisplayND
//	NVAR DisplayVD=root:Packages:SAS_Modeling:DisplayVD
//	NVAR FitSASBackground=root:Packages:SAS_Modeling:FitSASBackground
//	NVAR UseNumberDistribution=root:Packages:SAS_Modeling:UseNumberDistribution
//	NVAR UseVolumeDistribution=root:Packages:SAS_Modeling:UseVolumeDistribution						
//	NVAR UpdateAutomatically=root:Packages:SAS_Modeling:UpdateAutomatically
//	
//	if (UseQRSData)
//		UseIndra2data=0
//	endif
//	NumberOfDistributions=0
//	DisplayND=0
//	DisplayVD=1
//	
//	if (FitSASBackground==0)
//		FitSASBackground=1
//	endif
//	
//	if (UseNumberDistribution==0 && UseVolumeDistribution==0)
//		 UseVolumeDistribution=1
//		 UseNumberDistribution=0
//	endif
//		
//	NVAR UseLSQF
//	NVAR UseGenOpt
//	if(UseLSQF+UseGenOpt!=1)
//		UseLSQF=1
//		UseGenOpt=0
//	endif
//	
//	UpdateAutomatically=0
//
//	//and here we set distribution specific parameters....
//	
//	IR1S_SetInitialValuesForAdist(1)	//dist 1
//	IR1S_SetInitialValuesForAdist(2)	//dist 2
//	IR1S_SetInitialValuesForAdist(3)	//dist 3
//	IR1S_SetInitialValuesForAdist(4)	//dist 4
//	IR1S_SetInitialValuesForAdist(5)	//dist 5
//
//	setDataFolder oldDF
//	
//end	
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1S_SetInitialValuesForAdist(distNum)
//	variable distNum
//	//default values for distribution 1
//	string OldDf=GetDataFolder(1)
//	
//	setDataFOlder root:Packages:SAS_Modeling
//	
//	SVAR testStr =$("Dist"+num2str(distNum)+"UserFormFactorFnct")
//	if(strlen(testStr)<1)
//		testStr = "IR1T_ExampleSphereFFPoints"
//	endif
//	SVAR testStr =$("Dist"+num2str(distNum)+"UserVolumeFnct")
//	if(strlen(testStr)<1)
//		testStr = "IR1T_ExampleSphereVolume"
//	endif
//	
//	NVAR testVar=$("Dist"+num2str(distNum)+"NumberOfPoints")
//	if (testVar==0)
//		 testVar=50
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"ScatShapeParam1")
//	if(testVar==0)
//		 testVar=1
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"ScatShapeParam2")
//	if (testVar==0)
//		 testVar=1
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"ScatShapeParam3")
//	if (testVar==0)
//		 testVar=1
//	endif
//	
//	NVAR testVar=$("Dist"+num2str(distNum)+"NegligibleFraction")
//	if (testVar==0)
//		 testVar=0.01
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"VolHighLimit")
//	if (testVar==0)
//		 testVar=0.99
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"VolLowLimit")
//	if (testVar==0)
//		 testVar=0.00001
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"VolFraction")
//	if (testVar==0)
//		 testVar=0.05
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"FitVol")
//	if (testVar==0)
//		 testVar=1
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"FitShape")
//	if (testVar==0)
//		 testVar=1
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"FitLocation")
//	if (testVar==0)
//		 testVar=0
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"FitScale")
//	if (testVar==0)
//		 testVar=1
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"Contrast")
//	if (testVar==0)
//		 testVar=100
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"Scale")
//	if (testVar==0)
//		if (distNum==1)
//				 testVar=100
//		endif
//		if (distNum==2)
//				 testVar=400
//		endif
//		if (distNum==3)
//				 testVar=800
//		endif
//		if (distNum==4)
//				 testVar=1600
//		endif
//		if (distNum==5)
//				 testVar=3200
//		endif
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"Location")
//	if (testVar==0)
//		 testVar=0
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"Shape")
//	if (testVar==0)
//		 testVar=0.5
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"LocHighLimit")
//	if (testVar==0)
//		 testVar=1000000
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"LocLowLimit")
//	if (testVar==0)
//		 testVar=10
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"ScaleHighLimit")
//	if (testVar==0)
//		 testVar=100000
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"ScaleLowLimit")
//	if (testVar==0)
//		 testVar=5
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"ShapeHighLimit")
//	if (testVar==0)
//		 testVar=0.9
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"ShapeLowLimit")
//	if (testVar==0)
//		 testVar=0.1
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"LocStep")
//	if (testVar==0)
//		 testVar=50
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"ShapeStep")
//	if (testVar==0)
//		 testVar=0.1
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"ScaleStep")
//	if (testVar==0)
//		 testVar=10
//	endif
//	SVAR testStr=$("Dist"+num2str(distNum)+"ShapeModel")
//	if(strlen(testStr)==0)
//		testStr="spheroid"
//	endif
//	SVAR testStr=$("Dist"+num2str(distNum)+"DistributionType")
//	if(strlen(testStr)==0)
//		testStr="LogNormal"
//	endif
//	
//	NVAR testVar=$("Dist"+num2str(distNum)+"FitScatShapeParam1")
//	if (testVar==0)
//		 testVar=0
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"FitScatShapeParam2")
//	if (testVar==0)
//		 testVar=0
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"FitScatShapeParam3")
//	if (testVar==0)
//		 testVar=0
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"UseInterference")
//	if (testVar==0)
//		 testVar=0
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"InterferencePhi")
//	if (testVar==0)
//		 testVar=1
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"InterferencePhiHL")
//	if (testVar==0)
//		 testVar=8
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"InterferenceEta")
//	if (testVar==0)
//		 testVar=200
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"InterferenceEtaLL")
//	if (testVar==0)
//		 testVar=0
//	endif
//	NVAR testVar=$("Dist"+num2str(distNum)+"InterferenceEtaHL")
//	if (testVar==0)
//		 testVar=10000
//	endif
//
//	setDataFolder oldDf
//end
//

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_GraphMeasuredData(Package)
	string Package	//tells me, if this is called from Unified or LSQF
	//this function graphs data into the various graphs as needed
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling
	SVAR DataFolderName
	SVAR IntensityWaveName
	SVAR QWavename
	SVAR ErrorWaveName
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
	NVAR/Z SubtractBackground=root:Packages:SAS_Modeling:SubtractBackground
	if(NVAR_Exists(SubtractBackground) && (cmpstr(Package,"Unified")==0))
		OriginalIntensity =OriginalIntensity - SubtractBackground
	endif
	NVAR/Z UseSlitSmearedData=root:Packages:SAS_Modeling:UseSlitSmearedData
	if(NVAR_Exists(UseSlitSmearedData) && (cmpstr(Package,"LSQF")==0))
		if(UseSlitSmearedData)
			NVAR SlitLength=root:Packages:SAS_Modeling:SlitLength
			variable tempSL=NumberByKey("SlitLength", note(OriginalIntensity) , "=" , ";")
			if(numtype(tempSL)==0)
				SlitLength=tempSL
			endif
		endif
	endif
	NVAR/Z UseSMRData=root:Packages:SAS_Modeling:UseSMRData
	if(NVAR_Exists(UseSMRData) && (cmpstr(Package,"Unified")==0))
		if(UseSMRData)
			NVAR SlitLengthUnif=root:Packages:SAS_Modeling:SlitLengthUnif
			variable tempSL1=NumberByKey("SlitLength", note(OriginalIntensity) , "=" , ";")
			if(numtype(tempSL1)==0)
				SlitLengthUnif=tempSL1
			endif
		endif
	endif
	
	
	if (cmpstr(Package,"Unified")==0)		//called from unified
		KillWIndow/Z IR1_LogLogPlotU
		Execute ("IR1_LogLogPlotU()")
	elseif (cmpstr(Package,"LSQF")==0)
		DoWindow IR1_LogLogPlotLSQF
		if (V_flag)
			cursorAposition=pcsr(A,"IR1_LogLogPlotLSQF")
			cursorBposition=pcsr(B,"IR1_LogLogPlotLSQF")
			KillWIndow/Z IR1_LogLogPlotLSQF
		endif
		Execute ("IR1_LogLogPlotLSQF()")
		cursor/P/W=IR1_LogLogPlotLSQF A, OriginalIntensity,cursorAposition
		cursor/P/W=IR1_LogLogPlotLSQF B, OriginalIntensity,cursorBposition
	endif
	
	Duplicate/O $(DataFolderName+IntensityWaveName), OriginalIntQ4
	Duplicate/O $(DataFolderName+QWavename), OriginalQ4
	Duplicate/O $(DataFolderName+ErrorWaveName), OriginalErrQ4
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
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Proc  IR1_IQ4_Q_PlotLSQF() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:SAS_Modeling:
	Display /W=(283.5,228.5,761.25,383)/K=1  OriginalIntQ4 vs OriginalQvector as "IQ4_Q_Plot"
	DoWIndow/C IR1_IQ4_Q_PlotLSQF
	ModifyGraph mode(OriginalIntQ4)=3
	ModifyGraph msize(OriginalIntQ4)=1
	ModifyGraph log=1
	ModifyGraph mirror=1
	Label left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity * Q^4"
	Label bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M]"
	ErrorBars/Y=1 OriginalIntQ4 Y,wave=(OriginalErrQ4,OriginalErrQ4)
	TextBox/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	//and now some controls
//	ControlBar 30
//	Button SaveStyle size={80,20}, pos={50,5},proc=IR1U_StyleButtonCotrol,title="Save Style"
//	Button ApplyStyle size={80,20}, pos={150,5},proc=IR1U_StyleButtonCotrol,title="Apply Style"
	SetDataFolder fldrSav
	Execute/P("AutoPositionWindow/M=1 /R=IR1_LogLogPlotLSQF IR1_IQ4_Q_PlotLSQF")
	Execute/P("Dowindow/F IR1_LogLogPlotLSQF")
EndMacro


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//Window IR1_IQ4_Q_PlotLSQF() : Graph
//	PauseUpdate; Silent 1		// building window...
//	String fldrSav= GetDataFolder(1)
//	SetDataFolder root:Packages:SAS_Modeling:
//	Display /W=(295.5,237.5,753.75,421.25)/K=1  OriginalIntQ4 vs OriginalQvector as "IQ4_Q_Plot"
//	SetDataFolder fldrSav
//	ModifyGraph mode=3
//	ModifyGraph msize=1
//	ModifyGraph log=1
//	ModifyGraph mirror=1
//	Label left "Intensity * Q^4"
//	Label bottom "Q [A\\S-1\\M]"
//	Legend/W=IR1_IQ4_Q_Plot/N=text0/J/F=0/A=MC/X=-29.74/Y=37.76 "\\s(OriginalIntQ4) Experimental intensity * Q^4"
//	ErrorBars/Y=1 OriginalIntQ4 Y,wave=(:Packages:SAS_Modeling:OriginalErrQ4,:Packages:SAS_Modeling:OriginalErrQ4)
//	//and now some controls
//	ControlBar 30
//	Button SaveStyle size={80,20}, pos={50,5},proc=IR1U_StyleButtonCotrol,title="Save Style"
//	Button ApplyStyle size={80,20}, pos={150,5},proc=IR1U_StyleButtonCotrol,title="Apply Style"
//EndMacro


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Proc  IR1_LogLogPlotLSQF() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:SAS_Modeling:
	Display /W=(282.75,37.25,759.75,208.25)/K=1  OriginalIntensity vs OriginalQvector as "LogLogPlot"
	DoWIndow/C IR1_LogLogPlotLSQF
	ModifyGraph mode(OriginalIntensity)=3
	ModifyGraph msize(OriginalIntensity)=1
	ModifyGraph log=1
	ModifyGraph mirror=1
	ShowInfo
	Label left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity [cm\\S-1\\M]"
	Label bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M]"
	Legend/W=IR1_LogLogPlotLSQF/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 "\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"\\s(OriginalIntensity) Experimental intensity"
	ErrorBars/Y=1 OriginalIntensity Y,wave=(OriginalError,OriginalError)
	//and now some controls
	TextBox/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
//	ControlBar 30
//	Button SaveStyle size={80,20}, pos={50,5},proc=IR1U_StyleButtonCotrol,title="Save Style"
//	Button ApplyStyle size={80,20}, pos={150,5},proc=IR1U_StyleButtonCotrol,title="Apply Style"
	SetDataFolder fldrSav
	Execute /P("AutoPositionWindow/M=0 /R=IR1R_ControlPanel IR1_LogLogPlotLSQF")
EndMacro


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_CopyDataBackToFolder(StandardOrUser)
	string StandardOrUser
	//here we need to copy the final data back to folder
	//before that we need to also attach note to teh waves with the results
	
	string OldDf=getDataFOlder(1)
	setDataFolder root:Packages:SAS_Modeling
	
	Wave Distdiameters=root:Packages:SAS_Modeling:Distdiameters
	Wave TotalNumberDist=root:Packages:SAS_Modeling:TotalNumberDist
	Wave TotalVolumeDist=root:Packages:SAS_Modeling:TotalVolumeDist
	Wave DistModelIntensity=root:Packages:SAS_Modeling:DistModelIntensity
	Wave ModelQvector=root:Packages:SAS_Modeling:ModelQvector
	
	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
	SVAR DataFolderName=root:Packages:SAS_Modeling:DataFolderName
	
	string UsersComment, ExportSeparateDistributions
	UsersComment="Result from Modeling "+date()+"  "+time()
	ExportSeparateDistributions="No"
	Prompt UsersComment, "Modify comment to be saved with these results"
	Prompt ExportSeparateDistributions, "Export separately populations data", popup, "No;Yes"
	DoPrompt "Need input for saving data", UsersComment, ExportSeparateDistributions
	if (V_Flag)
		abort
	endif

	Duplicate/O Distdiameters, tempDistdiameters
	Duplicate/O TotalNumberDist, tempTotalNumberDist
	Duplicate/O TotalVolumeDist, tempTotalVolumeDist
	Duplicate/O DistModelIntensity, tempDistModelIntensity
	Duplicate/O ModelQvector, tempModelQvector
	string ListOfWavesForNotes="tempDistdiameters;tempTotalNumberDist;tempTotalVolumeDist;tempDistModelIntensity;tempModelQvector;"

	IR1_AppendWaveNote(ListOfWavesForNotes,StandardOrUser)		//append wave notes
	
	variable j,i
	If(cmpstr(ExportSeparateDistributions,"Yes")==0)
		for(j=1;j<=NumberOfDistributions;j+=1)		//copy local populations
			Wave tempDia=$("Dist"+num2str(j)+"diameters")		
			Wave tempNumDis=$("Dist"+num2str(j)+"NumberDist")		
			Wave tempVolDist=$("Dist"+num2str(j)+"VolumeDist")	
			Duplicate/O tempDia, $("tempDist"+num2str(j)+"diameters")		
			Duplicate/O tempNumDis, $("tempDist"+num2str(j)+"NumberDist")		
			Duplicate/O tempVolDist, $("tempDist"+num2str(j)+"VolumeDist")	
			ListOfWavesForNotes="tempDist"+num2str(j)+"diameters;tempDist"+num2str(j)+"NumberDist;tempDist"+num2str(j)+"VolumeDist;"
			IR1_AppendWNOfDist(j,ListOfWavesForNotes, StandardOrUser)
		endfor
	endif

	//need to change direction if user uses modeling here...
	if(stringmatch(DataFolderName,"root:Packages*"))
		string NewDataFolderStr="root:SASModels:"
		string tempNewDatFldrName=""
		Prompt NewDataFolderStr, "Trying to save model to Packages folder, suggest change the folder"
		DoPrompt "Override the data saving target",  NewDataFolderStr
		if(V_Flag)
			abort
		endif
		SetDataFolder root:
		if(!Stringmatch(NewDataFolderStr[Strlen(NewDataFolderStr)-1],":"))
			NewDataFolderStr+=":"
		endif	
		for(i=0;i<ItemsInList(NewDataFolderStr,":");i+=1)
			if(!StringMatch(StringFromList(i,NewDataFolderStr,":"),"root"))
				NewDataFolder/O/S $(StringFromList(i,NewDataFolderStr,":"))
			endif
			tempNewDatFldrName+=possiblyQuoteName(StringFromList(i,NewDataFolderStr,":"))+":"
		endfor
		setDataFolder $tempNewDatFldrName
	else
		setDataFolder $DataFolderName	
	endif
	string tempname 
	variable ii=0
	For(ii=0;ii<1000;ii+=1)
		tempname="ModelingDiameters_"+num2str(ii)
		if (checkname(tempname,1)==0)
			break
		endif
	endfor
	Duplicate /O tempDistdiameters, $tempname
	Wave MytempWave=$tempname
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","A")
	Redimension/D MytempWave
	
	tempname="ModelingNumberDistribution_"+num2str(ii)
	Duplicate /O tempTotalNumberDist, $tempname
	Wave MytempWave=$tempname
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm3")
	Redimension/D MytempWave
	
	tempname="ModelingVolumeDistribution_"+num2str(ii)
	Duplicate /O tempTotalVolumeDist, $tempname
	Wave MytempWave=$tempname
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","fraction")
	Redimension/D MytempWave
	
	tempname="ModelingIntensity_"+num2str(ii)
	Duplicate /O tempDistModelIntensity, $tempname
	Wave MytempWave=$tempname
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","cm-1")
	Redimension/D MytempWave
	
	tempname="ModelingQvector_"+num2str(ii)
	Duplicate /O tempModelQvector, $tempname
	Wave MytempWave=$tempname
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
	Redimension/D MytempWave

	If(cmpstr(ExportSeparateDistributions,"Yes")==0)
		for(j=1;j<=NumberOfDistributions;j+=1)		//copy local populations
			Wave tempDia=$("root:Packages:SAS_Modeling:tempDist"+num2str(j)+"diameters")		
			Wave tempNumDis=$("root:Packages:SAS_Modeling:tempDist"+num2str(j)+"NumberDist")		
			Wave tempVolDist=$("root:Packages:SAS_Modeling:tempDist"+num2str(j)+"VolumeDist")	
	
			tempname="ModelingDia_Pop"+num2str(j)+"_"+num2str(ii)
			Duplicate/O tempDia, $tempname
			Wave MytempWave=$tempname
			IN2G_AppendorReplaceWaveNote(tempname,"DataFolderInIgor",DataFolderName)
			IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
			IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
			IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
			Redimension/D MytempWave
				
			tempname="ModelingNumDist_Pop"+num2str(j)+"_"+num2str(ii)
			Duplicate/O tempNumDis, $tempname
			Wave MytempWave=$tempname
			IN2G_AppendorReplaceWaveNote(tempname,"DataFolderInIgor",DataFolderName)
			IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
			IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
			IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm3")
			Redimension/D MytempWave
	
			tempname="ModelingVolDist_Pop"+num2str(j)+"_"+num2str(ii)
			Duplicate/O tempVolDist, $tempname
			Wave MytempWave=$tempname
			IN2G_AppendorReplaceWaveNote(tempname,"DataFolderInIgor",DataFolderName)
			IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
			IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
			IN2G_AppendorReplaceWaveNote(tempname,"Units","fraction")
			Redimension/D MytempWave
			
			KillWaves/Z tempVolDist, tempNumDis, tempDia
		endfor
	endif
	setDataFolder root:Packages:SAS_Modeling

	Killwaves/Z tempDistdiameters,tempTotalNumberDist,tempTotalVolumeDist, tempDistModelIntensity, tempModelQvector
	setDataFolder OldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_AppendWaveNote(ListOfWavesForNotes, StandardOrUser)
	string ListOfWavesForNotes, StandardOrUser
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling

	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions

	NVAR SASBackground=root:Packages:SAS_Modeling:SASBackground
	NVAR FitSASBackground=root:Packages:SAS_Modeling:FitSASBackground
	NVAR UseNumberDistribution=root:Packages:SAS_Modeling:UseNumberDistribution
	NVAR UseInterference=root:Packages:SAS_Modeling:UseInterference
	NVAR UseSlitSmearedData=root:Packages:SAS_Modeling:UseSlitSmearedData
	NVAR SlitLength=root:Packages:SAS_Modeling:SlitLength
	SVAR DataFolderName=root:Packages:SAS_Modeling:DataFolderName
	string ExperimentName=IgorInfo(1)
	variable i, cursorAposition, cursorBposition
	For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)

		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"IgorExperimentName",ExperimentName)
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"DataFolderinIgor",DataFolderName)
		
		if (cmpstr(StandardOrUser,"standard")==0)
			if (UseNumberDistribution)
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"DistributionTypeModelled", "Number distribution")	
			else
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes), "DistributionTypeModelled", "Volume distribution")	
			endif	
		else
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes), "DistributionTypeModelled","User defined distributions used, modified volume and diameters")			
		endif
		//handle the cursors
		CursorAPosition=pcsr(A, "IR1_LogLogPlotLSQF")
		CursorBPosition=pcsr(B, "IR1_LogLogPlotLSQF")
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"CursorAPosition",num2str(CursorAPosition))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"CursorBPosition",num2str(CursorBPosition))
		
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"NumberOfModelledDistributions",num2str(NumberOfDistributions))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"UseInterference",num2str(UseInterference))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"UseSlitSmearedData",num2str(UseSlitSmearedData))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"SlitLength",num2str(SlitLength))

		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"SASBackground",num2str(SASBackground))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"FitSASBackground",num2str(FitSASBackground))
	endfor

	For(i=1;i<=NumberOfDistributions;i+=1)
		IR1_AppendWNOfDist(i,ListOfWavesForNotes, StandardOrUser)
	endfor

	setDataFolder oldDF

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_AppendWNOfDist(DistNum,ListOfWavesForNotes, StandardOrUser)
	variable DistNum
	string ListOfWavesForNotes, StandardOrUser
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling

	NVAR DistVolFraction=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolFraction")
	NVAR DistVolFractionError=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolFractionError")
	NVAR DistScatShapeParam1=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam1")
	NVAR DistScatShapeParam2=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam2")
	NVAR DistScatShapeParam3=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam3")
	NVAR DistScatShapeParam4=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam4")
	NVAR DistScatShapeParam5=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam5")
	SVAR DistShapeModel=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ShapeModel")

	if (cmpstr(StandardOrUser,"standard")==0)
		NVAR DistNumberOfPoints=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NumberOfPoints")
		NVAR DistContrast=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Contrast")
		NVAR DistLocation=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Location")
		NVAR DistScale=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Scale")
		NVAR DistShape=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Shape")
		NVAR DistLocationError=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"LocationError")
		NVAR DistScaleError=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScaleError")
		NVAR DistShapeError=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ShapeError")
		SVAR DistDistributionType=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"DistributionType")
		NVAR DistNegligibleFraction= $("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NegligibleFraction")
		NVAR DistUseInterference= $("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UseInterference")
		NVAR DistInterferencePhi= $("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"InterferencePhi")
		NVAR DistInterferenceEta= $("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"InterferenceEta")
		NVAR DistInterferencePhiError= $("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"InterferencePhiError")
		NVAR DistInterferenceEtaError= $("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"InterferenceEtaError")
		NVAR DistFitInterferencePhi= $("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"FitInterferencePhi")
		NVAR DistFitInterferenceEta= $("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"FitInterferenceEta")
		NVAR DistFitShape= $("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"FitShape")
		NVAR DistFitLocation= $("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"FitLocation")
		NVAR DistFitScale= $("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"FitScale")
		NVAR DistFitVol= $("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"FitVol")
	else
		NVAR DistDiamAddition=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"DiamAddition")
		NVAR DistDiamMulitplier=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"DiamMulitplier")
	endif		
	
	SVAR GaussEquation=root:Packages:SAS_Modeling:GaussEquation
	SVAR LogNormalEquation=root:Packages:SAS_Modeling:LogNormalEquation
	SVAR LSWEquation=root:Packages:SAS_Modeling:LSWEquation
	SVAR PowerLawEquation=root:Packages:SAS_Modeling:PowerLawEquation
	
	variable i
	For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"ShapeModel",DistShapeModel)
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"ScatShapeParam1",num2str(DistScatShapeParam1))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"ScatShapeParam2",num2str(DistScatShapeParam2))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"ScatShapeParam3",num2str(DistScatShapeParam3))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"ScatShapeParam4",num2str(DistScatShapeParam4))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"ScatShapeParam5",num2str(DistScatShapeParam5))

		if (cmpstr(StandardOrUser,"standard")==0)
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"DistributionType",DistDistributionType)
			if (cmpstr(DistDistributionType,"Gauss")==0)
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"Formula",GaussEquation)		
			endif
			if (cmpstr(DistDistributionType,"LSW")==0)
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"Formula",LSWEquation)		
			endif
			if (cmpstr(DistDistributionType,"LogNormal")==0)
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"Formula",LogNormalEquation)		
			endif
			if (cmpstr(DistDistributionType,"PowerLaw")==0)
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"Formula",PowerLawEquation)		
			endif
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"NegligibleFraction",num2str(DistNegligibleFraction))

			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"FitShape",num2str(DistFitShape))
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"FitLocation",num2str(DistFitLocation))
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"FitScale",num2str(DistFitScale))
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"FitVol",num2str(DistFitVol))
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"VolFraction",num2str(DistVolFraction))
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"Location",num2str(DistLocation))
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"Scale",num2str(DistScale))
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"Shape",num2str(DistShape))
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"VolFractionError",num2str(DistVolFractionError))
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"LocationError",num2str(DistLocationError))
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"ScaleError",num2str(DistScaleError))
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"ShapeError",num2str(DistShapeError))
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"NumberOfPoints",num2str(DistNumberOfPoints))
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"Contrast",num2str(DistContrast))
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"DistributionType",DistDistributionType)
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"UseInterference",num2str(DistUseInterference))
			if (DistUseInterference)
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"InterferencePhi",num2str(DistInterferencePhi))
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"InterferenceEta",num2str(DistInterferenceEta))
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"InterferencePhiError",num2str(DistInterferencePhiError))
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"InterferenceEtaError",num2str(DistInterferenceEtaError))
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"FitInterferencePhi",num2str(DistFitInterferencePhi))
				IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"FitInterferenceEta",num2str(DistFitInterferenceEta))
			endif
		else
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"VolFraction",num2str(DistVolFraction))
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"DiamAddition",num2str(DistDiamAddition))
			IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Dist"+num2str(DistNum)+"DiamMultiplier",num2str(DistDiamMulitplier))
		endif
	endfor

	setDataFolder OldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_ExportASCIIResults(standardOrUser)
	string standardOrUser			//"standard" or "User", depending where called from...

	//here we need to copy the export results out of Igor
	//before that we need to also attach note to teh waves with the results
	
	string OldDf=getDataFOlder(1)
	setDataFolder root:Packages:SAS_Modeling
	
	Wave Distdiameters=root:Packages:SAS_Modeling:Distdiameters
	Wave TotalNumberDist=root:Packages:SAS_Modeling:TotalNumberDist
	Wave TotalVolumeDist=root:Packages:SAS_Modeling:TotalVolumeDist
	
	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
	SVAR DataFolderName=root:Packages:SAS_Modeling:DataFolderName
	
	Duplicate/O Distdiameters, tempDistdiameters
	Duplicate/O TotalNumberDist, tempTotalNumberDist
	Duplicate/O TotalVolumeDist, tempTotalVolumeDist
	string ListOfWavesForNotes="tempDistdiameters;tempTotalNumberDist;tempTotalVolumeDist;"
	
	IR1_AppendWaveNote(ListOfWavesForNotes, standardOrUser)
	
	string Comments="Record of Data evaluation with Irena SAS modeling macros;" +note(tempDistdiameters)+"diameters[A]\t\tNumberDist[1/cm3]\t\tVolumeDist[cm3/cm3]\r"
	variable pos=0
	variable ComLength=strlen(Comments)
	Do 
		pos=strsearch(Comments, ";", pos+5)
		Comments=Comments[0,pos-1]+"\r#\t"+Comments[pos+1,inf]
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
	Notebook $nb text=Comments[1,strlen(Comments)-2]	
	
	
	SaveNotebook $nb as filename1
	DoWindow /K $nb
	Save/A/G/M="\r\n" tempDistdiameters,tempTotalNumberDist,tempTotalVolumeDist as filename1	 
	


	Killwaves/Z tempDistdiameters,tempTotalNumberDist,tempTotalVolumeDist
	setDataFolder OldDf
end
	

//**************************************************************** 
//**************************************************************** 
//***********************************
//***********************************

Function IR2C_CheckIrenaUpdate(CalledFromMenu)
	variable CalledFromMenu

	IN2G_ReadIrenaGUIPackagePrefs(0)
	NVAR LastUpdateCheckIrena=root:Packages:IrenaConfigFolder:LastUpdateCheckIrena	
	if(datetime - LastUpdateCheckIrena >30 * 24 * 60 * 60 || CalledFromMenu)
			//call check version procedure and advise user on citations
			IR2C_CheckVersions()
			IN2G_SubmitCheckRecordToWeb("Irena "+num2str(CurrentIrenaVersionNumber))
			LastUpdateCheckIrena = datetime
			IN2G_SaveIrenaGUIPackagePrefs(0)
			IN2G_GetAndDisplayUpdateMessage()
	endif
	if (str2num(stringByKey("IGORVERS",IgorInfo(0)))<7.05)
			DoAlert /T="Igor update message :"  0, "Igor has been updated to version 7.05 or higher. Please, update your Igor to the latest version."  
			BrowseURL "http://www.wavemetrics.com/support/versions.htm"
	endif
	
end

//**************************************************************** 
//**************************************************************** 
static Function IR2C_CheckVersions()
	string PackageString	
	//create list of Igor procedure files on this machine
	IN2G_ListIgorProcFiles()
	DoWIndow CheckForIrenaUpdatePanel
	if(V_Flag)
		DoWIndow/F CheckForIrenaUpdatePanel								
	else
		Execute("CheckForIrenaUpdatePanel()")			
	endif
	//Irena code
	string OldDf=GetDataFolder(1)
	//create location for the results waves...
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:UseProcedureFiles
	variable/g InstalledIrenaVersion
	variable/g WebIrenaVersion		
	InstalledIrenaVersion = IN2G_FindFileVersion("Boot Irena1 modeling.ipf")	
	WebIrenaVersion = IN2G_CheckForNewVersion("Irena")
	if(numtype(WebIrenaVersion)!=0)
		Print "Check for latest Irena version failed. Check your Internet connection. Try later again..."
	endif
	//DeleteFile /Z /P=tempPath "Boot Irena1 modeling.ipf"	
	SetDataFOlder OldDf
end	

//**************************************************************** 
//**************************************************************** 
//***********************************
//***********************************


//Motofit paper [J. Appl. Cryst. 39, 273-276]
//http://scripts.iucr.org/cgi-bin/paper?S0021889806005073
//J. Appl. Cryst. (2006). 39, 273-276    [ doi:10.1107/S0021889806005073 ]
//A. Nelson, Co-refinement of multiple-contrast neutron/X-ray reflectivity data using MOTOFIT
//



Function IR2C_CheckVersionButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"OpenIrenaWebPage"))
				//open web page with Irena
				BrowseURL "https://usaxs.xray.aps.anl.gov/software/irena"
			endif
			if(stringmatch(ba.ctrlName,"OpenIrenaManuscriptWebPage"))
				//open web page with Irena
				BrowseURL "http://dx.doi.org/10.1107/S0021889809002222"
			endif
			if(stringmatch(ba.ctrlName,"OpenGCManuscriptWebPage"))
				//doi:10.1007/s11661-009-9950-x
				BrowseURL "http://www.jomgateway.net/ArticlePage.aspx?DOI=10.1007/s11661-009-9950-x"
			endif
			if(stringmatch(ba.ctrlName,"OpenMotofitManuscriptWebPage"))
				//doi:10.1007/s11661-009-9950-x
				BrowseURL "http://scripts.iucr.org/cgi-bin/paper?S0021889806005073"
			endif
			if(stringmatch(ba.ctrlName,"OpenUFManuscriptWebPage"))
				BrowseURL "http://scripts.iucr.org/cgi-bin/paper?S0021889895005292"
			endif		
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**************************************************************** 
//**************************************************************** 
//***********************************
//***********************************

Window CheckForIrenaUpdatePanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(116,68,880,550)/K=1 as "Irena check for updates"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 3,textrgb= (0,0,65535)
	DrawText 114,37,"Once-per-month reminder to check for Irena update"
	SetDrawEnv fsize= 14,fstyle= 3,textrgb= (65535,0,0)
	DrawText 27,110,"Reminder: When publishing data analyzed using Irena package, please cite following manuscripts:"
	SetDrawEnv textrgb= (0,0,65535)
	DrawText 27,133,"J. Ilavsky and P. Jemian, Irena: tool suite for modeling and analysis of small- angle scattering "
	SetDrawEnv textrgb= (0,0,65535)
	DrawText 27,158,"J. Appl. Cryst. (2009). 42, 347–353"
	SetDrawEnv textrgb= (0,0,65535)
	DrawText 27,205,"Glassy Carbon Absolute Int. Calibration: F. Zhang, J. Ilavsky, G. G. Long, J. P.G. Quintana, "
	SetDrawEnv textrgb= (0,0,65535)
	DrawText 27,230,"A. J. Allen, and P. Jemian, Glassy Carbon as an Absolute Intensity Calibration Standard"
	SetDrawEnv textrgb= (0,0,65535)
	DrawText 27,255,"for Small-Angle Scattering, MMTA, DOI: 10.1007/s11661-009-9950-x"
	SetDrawEnv textrgb= (0,0,65535)
	DrawText 27,320,"Reflectivity: A. Nelson, Co-refinement of multiple-contrast neutron/X-ray reflectivity"
	SetDrawEnv textrgb= (0,0,65535)
	DrawText 27,345,"data using MOTOFIT, Appl. Cryst. (2006). 39, 273-276"
	SetDrawEnv textrgb= (0,0,65535)
	DrawText 27,390,"Unified Fit: G. Beaucage, Approximations Leading to a Unified Exponential/Power-Law "
	SetDrawEnv textrgb= (0,0,65535)
	DrawText 27,415,"Approach to Small-Angle Scattering, J. Appl. Cryst. (1995). 28, 717-728"

	SetDrawEnv fstyle= 2,fsize= 10,textrgb= (0,0,0)
	DrawText 10,470,"This tool runs automatically every 30 days on each computer. It can be also called from the SAS sub-menu as \"Check for updates\""

	SetVariable InstalledIrenaVersion,pos={48,56},size={199,15},bodyWidth=100,title="Installed Irena Version"
	SetVariable InstalledIrenaVersion,help={"This is the current Irena version installed"}
	SetVariable InstalledIrenaVersion,fStyle=1
	SetVariable InstalledIrenaVersion,limits={0,0,0},value= root:Packages:UseProcedureFiles:InstalledIrenaVersion,noedit= 1
	SetVariable WebIrenaVersion,pos={297,56},size={183,15},bodyWidth=100,title="Web Irena Version"
	SetVariable WebIrenaVersion,help={"This is the current Irena version installed"}
	SetVariable WebIrenaVersion,fStyle=1
	SetVariable WebIrenaVersion,limits={0,0,0},value= root:Packages:UseProcedureFiles:WebIrenaVersion,noedit= 1
	Button OpenIrenaWebPage,pos={551,53},size={150,20},proc=IR2C_CheckVersionButtonProc,title="Open Irena web page"
	Button OpenIrenaManuscriptWebPage,pos={551,143},size={150,20},proc=IR2C_CheckVersionButtonProc,title="Manuscript web page"
	Button OpenGCManuscriptWebPage,pos={551,240},size={150,20},proc=IR2C_CheckVersionButtonProc,title="Manuscript web page"
	Button OpenMotofitManuscriptWebPage,pos={551,325},size={150,20},proc=IR2C_CheckVersionButtonProc,title="Manuscript web page"
	Button OpenUFManuscriptWebPage,pos={551,402},size={150,20},proc=IR2C_CheckVersionButtonProc,title="Manuscript web page"
EndMacro
//**************************************************************** 
//**************************************************************** 
//***********************************
//***********************************
//		IR1F_CreateFldrStrctMain
//**************************************************************** 
//**************************************************************** 




Function IR1F_CreateFldrStrctMain()

	IN2G_CheckScreenSize("height",450)
	IR1F_InitializeCreateFldrStrct()
	KillWIndow/Z IR1F_CreateQRSFldrStructure
 	Execute ("IR1F_CreateQRSFldrStructure()")
	
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Proc IR1F_CreateQRSFldrStructure() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(135,98,551.25,392.75) as "Create QRS Folder Structure"
	DoWIndow/C IR1F_CreateQRSFldrStructure
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 3,textrgb= (0,0,65280)
	DrawText 64,30,"Create folder structure for QRS data"
	PopupMenu SelectFolderWithData,pos={19,49},size={171,21},proc=IR1F_PopMenuProc,title="Select folder with data :"
	PopupMenu SelectFolderWithData,mode=1,popvalue="---",value= #"\"---;\"+IR3D_GenStringOfFolders(\"root:\",0, 1,0,0,\"\")"
	SetVariable NewFolderForData,pos={16,88},size={380,19},proc=IR1F_SetVarProc,title="Where to create new data folders?"
	SetVariable NewFolderForData,value= root:Packages:CreateFldrStructure:NewFldrPath
	Button CreateFolders,pos={124,177},size={150,20}, proc=IR1F_ButtonProc,title="Convert structure"
	SetVariable BackupFolder,pos={45,128},size={350,19},proc=IR1F_SetVarProc,title="Backup old data to"
	SetVariable BackupFolder,value= root:Packages:CreateFldrStructure:NewBackupFldr
EndMacro

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function IR1F_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if (cmpstr(ctrlName,"SelectFolderWithData")==0)
		SVAR FolderWithData=root:Packages:CreateFldrStructure:FolderWithData
		FolderWithData = popStr
	
	endif
End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1F_SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	if(cmpstr("NewFolderForData",ctrlName)==0)
	
	endif
	if(cmpstr("BackupFolder",ctrlName)==0)
	
	endif

	
End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1F_ButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if(cmpstr(ctrlName,"CreateFolders")==0)
		IR1F_CreateFolders()
	endif

End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function  IR1F_InitializeCreateFldrStrct()

	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:CreateFldrStructure
	
	string ListOfStrings
	ListOfStrings = "ListOfDataAvailable;FolderWithData;NewFldrPath;NewBackupFldr;"

	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
		SVAR test = $(StringFromList(i,ListOfStrings))
		test = ""
	endfor		

	//set starting values here
	SVAR NewFldrPath
	NewFldrPath = "root:SAS:"
	SVAR NewBackupFldr
	NewBackupFldr = "root:SAS_Data_Backup:"
end	

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function  IR1F_CreateFolders()

	SVAR ListOfDataAvailable=root:Packages:CreateFldrStructure:ListOfDataAvailable
	SVAR FolderWithData=root:Packages:CreateFldrStructure:FolderWithData
	SVAR NewFldrPath=root:Packages:CreateFldrStructure:NewFldrPath
	SVAR NewBackupFldr=root:Packages:CreateFldrStructure:NewBackupFldr

	//first let's see if there are any data available for conversion
	ListOfDataAvailable=IR1F_CreateListQRSOfData(FolderWithData)
	
	if(strlen(NewBackupFldr)>0)
		IR1F_BackupData(ListOfDataAvailable, FolderWithData, NewBackupFldr)
	endif
	
	
	IR1F_MoveData(ListOfDataAvailable, FolderWithData,NewFldrPath )	
	
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function	IR1F_MoveData(ListOfDataAvailable, FolderWithData,NewFldrPath )	
	string ListOfDataAvailable, FolderWithData,NewFldrPath
	
	string OldDf
	OldDf = getDataFOlder(1)
	
	variable i
	string RWvname,QWvName,SWvName, SaFldrName
	if(cmpstr(":",NewFldrPath[strlen(NewFldrPath)-1] )!=0)
		NewFldrPath+=":"
	endif
	variable numberOfFldrLevels=ItemsInList(NewFldrPath,":")
	
	setDataFolder root:
	for(i=0;i<numberOfFldrLevels;i+=1)
		if(cmpstr(StringFromList(i, NewFldrPath ,":"),"root")!=0)
			NewDataFolder /O/S $(StringFromList(i, NewFldrPath ,":"))
		endif
	endfor
	//QRS data
	For(i=0;i<ItemsInList(ListOfDataAvailable);i+=1)
		setDataFolder FolderWithData
		RWvname = StringFromList(i, ListOfDataAvailable)
		QWvName = "Q"+RWvname[1,inf]
		SWvName = "S"+RWvname[1,inf]
		SaFldrName = RWvname[1,inf]
		if(cmpstr(SaFldrName[0],"_")==0)
			SaFldrName=SaFldrName[1,inf]
		endif
		Wave/Z RWave = $RWvname
		Wave/Z QWave = $QWvname
		Wave/Z SWave = $SWvname
		if(WaveExists(RWave) && WaveExists(QWave) &&WaveExists(SWave))
			SetDataFolder NewFldrPath
			if(DataFolderExists(SaFldrName))
				SaFldrName=UniqueName(SaFldrName,11,0)
				SaFldrName=CleanupName(SaFldrName, 0 )
			endif
			NewDataFolder/O/S $(SaFldrName)
			Wave/Z testR= $(RWvname)
			Wave/Z testQ= $(QWvname)
			Wave/Z testS= $(SWvname)
			if((!WaveExists(testR))&&(!WaveExists(testQ))&&(!WaveExists(testS)))		
				MoveWave RWave, $(RWvname)
				MoveWave QWave, $(QWvname)
				MoveWave SWave, $(SWvname)
			else
				Print "Cannot move waves into folder : "+SaFldrName+" since there are already waves with same name"
			endif
			//KillWaves/Z RWave, QWave, SWave
		elseif(WaveExists(RWave) && WaveExists(QWave))
			SetDataFolder NewFldrPath
			if(DataFolderExists(SaFldrName))
				SaFldrName=UniqueName(SaFldrName,11,0)
				SaFldrName=CleanupName(SaFldrName, 0 )
			endif
			NewDataFolder/O/S $(SaFldrName)
			Wave/Z testR= $(RWvname)
			Wave/Z testQ= $(QWvname)
			if((!WaveExists(testR))&&(!WaveExists(testQ)))		
				MoveWave RWave, $(RWvname)
				MoveWave QWave, $(QWvname)
			else
				Print "Cannot move waves into folder : "+SaFldrName+" since there are already waves with same name"
			endif
			//KillWaves/Z RWave, QWave, SWave
		endif
	endfor
	//QIS data
	For(i=0;i<ItemsInList(ListOfDataAvailable);i+=1)
		setDataFolder FolderWithData
		RWvname = StringFromList(i, ListOfDataAvailable)
		QWvName = RWvname[0,strlen(RWvname)-2]+"Q"
		SWvName = RWvname[0,strlen(RWvname)-2]+"S"
		SaFldrName = RWvname[0,strlen(RWvname)-2]
		if(cmpstr(SaFldrName[strlen(RWvname)-2],"_")==0)
			SaFldrName=SaFldrName[0,strlen(RWvname)-3]
		endif
		Wave/Z RWave = $RWvname
		Wave/Z QWave = $QWvname
		Wave/Z SWave = $SWvname
		if(WaveExists(RWave) && WaveExists(QWave) &&WaveExists(SWave))
			SetDataFolder NewFldrPath
			if(DataFolderExists(SaFldrName))
				SaFldrName=UniqueName(SaFldrName,11,0)
				SaFldrName=CleanupName(SaFldrName, 0 )
			endif
			NewDataFolder/O/S $(SaFldrName)
			Wave/Z testR= $(RWvname)
			Wave/Z testQ= $(QWvname)
			Wave/Z testS= $(SWvname)
			if((!WaveExists(testR))&&(!WaveExists(testQ))&&(!WaveExists(testS)))		
				MoveWave RWave, $(RWvname)
				MoveWave QWave, $(QWvname)
				MoveWave SWave, $(SWvname)
			else
				Print "Cannot move waves into folder : "+SaFldrName+" since there are already waves with same name"
			endif
			//KillWaves/Z RWave, QWave, SWave
		elseif(WaveExists(RWave) && WaveExists(QWave))
			SetDataFolder NewFldrPath
			if(DataFolderExists(SaFldrName))
				SaFldrName=UniqueName(SaFldrName,11,0)
				SaFldrName=CleanupName(SaFldrName, 0 )
			endif
			NewDataFolder/O/S $(SaFldrName)
			Wave/Z testR= $(RWvname)
			Wave/Z testQ= $(QWvname)
			if((!WaveExists(testR))&&(!WaveExists(testQ)))		
				MoveWave RWave, $(RWvname)
				MoveWave QWave, $(QWvname)
			else
				Print "Cannot move waves into folder : "+SaFldrName+" since there are already waves with same name"
			endif
			//KillWaves/Z RWave, QWave, SWave
		endif
	endfor

	setDataFolder OldDf

end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1F_BackupData(ListOfDataAvailable, FolderWithData, NewBackupFldr)
	string ListOfDataAvailable, FolderWithData, NewBackupFldr
	
	string OldDf
	OldDf = getDataFOlder(1)
	
	variable i
	string RWvname,QWvName,SWvName
	if(cmpstr(":",NewBackupFldr[strlen(NewBackupFldr)-1] )!=0)
		NewBackupFldr+=":"
	endif
	variable numberOfFldrLevels=ItemsInList(NewBackupFldr,":")
	
	setDataFolder root:
	for(i=0;i<numberOfFldrLevels;i+=1)
		if(cmpstr(StringFromList(i, NewBackupFldr ,":"),"root")!=0)
			NewDataFolder /O/S $(StringFromList(i, NewBackupFldr ,":"))
		endif
	endfor
	
	setDataFolder FolderWithData
	//QRS DATA
	For(i=0;i<ItemsInList(ListOfDataAvailable);i+=1)
		RWvname = StringFromList(i, ListOfDataAvailable)
		QWvName = "Q"+RWvname[1,inf]
		SWvName = "S"+RWvname[1,inf]
		Wave/Z RWave = $RWvname
		Wave/Z QWave = $QWvname
		Wave/Z SWave = $SWvname
		if(WaveExists(RWave) && WaveExists(QWave) &&WaveExists(SWave))
			Duplicate /O RWave, $(NewBackupFldr+possiblyquotename(RWvname))
			Duplicate /O QWave, $(NewBackupFldr+possiblyquotename(QWvname))
			Duplicate /O SWave, $(NewBackupFldr+possiblyquotename(SWvname))
		elseif(WaveExists(RWave) && WaveExists(QWave))
			Duplicate /O RWave, $(NewBackupFldr+possiblyquotename(RWvname))
			Duplicate /O QWave, $(NewBackupFldr+possiblyquotename(QWvname))
		endif
	endfor	
	//QIS data
	For(i=0;i<ItemsInList(ListOfDataAvailable);i+=1)
		RWvname = StringFromList(i, ListOfDataAvailable)
		QWvName = RWvname[0,strlen(RWvname)-2]+"Q"
		SWvName = RWvname[0,strlen(RWvname)-2]+"S"
		Wave/Z RWave = $RWvname
		Wave/Z QWave = $QWvname
		Wave/Z SWave = $SWvname
		if(WaveExists(RWave) && WaveExists(QWave) &&WaveExists(SWave))
			Duplicate /O RWave, $(NewBackupFldr+possiblyquotename(RWvname))
			Duplicate /O QWave, $(NewBackupFldr+possiblyquotename(QWvname))
			Duplicate /O SWave, $(NewBackupFldr+possiblyquotename(SWvname))
		elseif(WaveExists(RWave) && WaveExists(QWave))
			Duplicate /O RWave, $(NewBackupFldr+possiblyquotename(RWvname))
			Duplicate /O QWave, $(NewBackupFldr+possiblyquotename(QWvname))
		endif
	endfor	
	
	setDataFOlder OldDf
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function/T IR1F_CreateListQRSOfData(FolderWithData)
	string FolderWithData
	
	string OldDf=GetDataFOlder(1)
	setDataFolder FolderWithData
	
	variable NumberOfAllWaves=CountObjects(FolderWithData, 1 )
	variable i
	string ListOfQRSWaves, TempRWaveName, TempQWaveName, TempSWaveName
	ListOfQRSWaves = ""
	string AllWaves=IN2G_CreateListOfItemsInFolder(FolderWithData, 2)
	//GetIndexedObjName(FolderWithData, 1, i )
	FOr(i=0;i<=NumberOfAllWaves;i+=1)
		TempRWaveName = StringFromList(i, AllWaves)
		if (cmpstr(TempRWaveName[0],"R")==0)	//the wave starts with R
			TempQWaveName="Q"+TempRWaveName[1,inf]
			TempSWaveName="S"+TempRWaveName[1,inf]
			Wave/Z testQ=$(TempQWaveName)
			Wave/Z testS=$(TempSWaveName)
			if(WaveExists(testQ) && WaveExists(testS))
				ListOfQRSWaves+=TempRWaveName+";"
			elseif(WaveExists(testQ))
				ListOfQRSWaves+=TempRWaveName+";"
			endif		
		endif
	endfor
	//next try to handle QIS data
	FOr(i=0;i<=NumberOfAllWaves;i+=1)
		TempRWaveName = StringFromList(i, AllWaves)
		print TempRWaveName[strlen(TempRWaveName)-2,inf],"I"
		if (cmpstr(TempRWaveName[strlen(TempRWaveName)-1],"I")==0)	//the wave ends with i
			TempQWaveName=TempRWaveName[0,strlen(TempRWaveName)-2]+"Q"
			TempSWaveName=TempRWaveName[0,strlen(TempRWaveName)-2]+"S"
			Wave/Z testQ=$(TempQWaveName)
			Wave/Z testS=$(TempSWaveName)
			if(WaveExists(testQ) && WaveExists(testS))
				ListOfQRSWaves+=TempRWaveName+";"
			elseif(WaveExists(testQ))
				ListOfQRSWaves+=TempRWaveName+";"
			endif		
		endif
	endfor

	setDataFolder OldDf
	return ListOfQRSWaves

end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//****************   LSW   ***********************************************************
Function IR1_LSWProbability(x,location,scale, shape)
		variable x, location,scale, shape
	//this function calculates probability for LSW distribution
	
	variable result, reducedX
	
	reducedX=x/location
	
	result=(81/(2^(5/3))) * (reducedX^2 * exp(-1*(reducedX/(1.5-reducedX) ) ) ) / ( (1.5-reducedX)^(11/3) * (3+reducedX)^(7/3) )
	
	//this funny distribution reaches values (integral under the curve) of location
	//so we need to renormalize...

	if (numtype(result)!=0)
		result=0
	endif
	
	return result/location

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_LSWCumulative(xx,location,scale, shape)
		variable xx, location,scale, shape
	//this function calculates probability for LSW distribution
	//I do not have cumulative probability function, so it is done numerically... More complex and much more annoying...
	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SAS_Modeling
			
	variable result, pointsNeeded=ceil(xx/30+30)
	//points neede is at least 30 and max out around 370 for 10000 A location
	make/D /O/N=(PointsNeeded) temp_LSWwav 
	
	SetScale/P x 10,(xx/(numpnts(temp_LSWwav)-3)),"", temp_LSWwav	
	//this sets scale so the model wave x scale covers area from 10 A over the needed point...
	
	temp_LSWwav=IR1_LSWProbability(pnt2x(temp_LSWwav, p ),location,scale, shape)
	
	integrate /T temp_LSWwav
	//and at this point the temp_LSWwav has integral values in it... 
	result = temp_LSWwav(xx) //here we get the value interpolated (linearly) for the needed point...
	KillWaves temp_LSWwav
	setDataFolder OldDf
	return result
end

 

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//****************   Normal (Gauss) distribution   ***********************************************************

Function IR1_GaussProbability(x,location,scale, shape)
		variable x, location,scale, shape
	//this function calculates probability for Gauss (normal) distribution
	
	variable result
	
	result=(exp(-((x-location)^2)/(2*scale^2)))/(scale*(sqrt(2*pi)))

	if (numtype(result)!=0)
		result=0
	endif
	
	return result
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_SchulzZimmProbability(x,MeanPos,Width, shape)
		variable x, MeanPos,Width, shape
	//this function calculates probability for Schulz-Zimm distribution
	//finished 3/17/2011, seems to work.  
	variable result, a, b
	
	b = 1/(width/(2*MeanPos))^2
	a = b / MeanPos
	
	if(b<70)
		result=( (a^(b+1))/gamma(b+1) * x^b / exp(a*x) )
	else			//do it in logs to avoid large numbers
		result=exp(    (b+1)*ln(a)-  gammln(b+1) + B*ln(x) - (a*x) )
	endif

	if (numtype(result)!=0)
		result=0
	endif
	
	return result
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

threadsafe Function IR1_ArdellProbNormalized(xval,MeanPos,np,NoP)
	variable xval, MeanPos,np, NoP
	//this function calculates probability for A
	variable result
	result = IR1_ArdellProbability(xval,MeanPos,np,NoP)
	Make/Free/N=200 NormWave
	variable start = max(1, MeanPos/20 )
	SetScale/I x  start, MeanPos*3,"", NormWave
	multithread NormWave = IR1_ArdellProbability(x,MeanPos,np,NoP)
	variable Normval = area(NormWave)
	return result / Normval
end	

threadsafe Function IR1_ArdellProbability(x,MeanPos,np,NoP)
		variable x, MeanPos,np, NoP
	//this function calculates probability for Ardell distribution
	variable result, zp
	zp = x/MeanPos
	result = -3*Ardell_F(zp,np)*exp(Ardell_P(zp,np))	
	return result
end



threadsafe static Function Ardell_F(zp,np)
	variable zp, np
	//note np = 2 to 3
	// zp = r/r0 = 0 - 3 max. 
	
	variable result
	result = (zp*(np-1))^(np-1)
	result = result/((np^np * (zp-1))-(zp^np * (np-1)^(np-1)))
	
	return result
end

threadsafe static Function Ardell_P(xp,np)
	variable xp, np
	make/Free tmpAF
	SetScale/I x 0,xp,"", tmpAF
	tmpAF = Ardell_F(x,np)
	return area(tmpAF)
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

threadsafe Function IR1_ArdellCumulative(xpos,location,scale, shape)
	variable xpos, location,scale, shape
	//this function calcualtes cumulative probabliltiy for Ardell distribution
	//only scale is useful parameters here ans is 2-3... 
	variable result
	Make/O/N=200/Free TempPWave, TepNorWave
	variable start = max(1, location/20 )
	start = min(start,xpos)
	SetScale/I x start,xpos,"", TempPWave
	SetScale/I x start,3*location,"", TepNorWave
	multithread TempPWave =  IR1_ArdellProbability(x,location,scale, shape)
	multithread TepNorWave =  IR1_ArdellProbability(x,location,scale, shape)
	result = area(TempPWave)/area(TepNorWave)
	return result
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_SZCumulative(xpos,location,scale, shape)
	variable xpos, location,scale, shape
	//this function calcualtes cumulative probabliltiy for SZ distribution
	//until I find the formula for SZ I will use numberical method, slower but should work... 
	
	variable result
	Make/O/N=500/Free tempSZDistWv
	SetScale/I x 0,xpos,"", tempSZDistWv
	tempSZDistWv =  IR1_SchulzZimmProbability(x,location,scale, shape)
//	doupdate
	result = area(tempSZDistWv  )
	return result
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_GaussCumulative(x,location,scale, shape)
	variable x, location,scale, shape
	//this function calcualtes cumulative probabliltiy for gauss (normal) distribution
	
	variable result, ReducedX
	
	ReducedX=(x-location)/scale
	
	result = (erf(ReducedX/sqrt(2))+1)/2
	
	return result
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_PowerLawCumulative(x, shape,startx,endx)
	variable x, endx,startx, shape
	//this function calculates cumulative probability for log-normal distribution
	
	variable result
	
	Make/O/N=1000 TempCumWv
	SetScale/I x startx, endx, TempCumWv
	TempCumWv = x^(-(7-shape))
	
	result = area(TempCumWv,startx, x)/area(TempCumWv,startx, endx)
	KillWaves TempCumWv

	return result


end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_PowerLawProbability(x, shape,diameterswv)
	variable x,  shape
	wave diameterswv
	
	//this function calculates cumulative probability for log-normal distribution
	duplicate/O diameterswv, tempCalcWvPowerLaw
	
	variable result
	
	tempCalcWvPowerLaw =  diameterswv^(-(7-shape))
	result =  (x^(-(7-shape))) / areaXY(diameterswv, tempCalcWvPowerLaw, 0, inf )
	killwaves/Z tempCalcWvPowerLaw
	
	return result


end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


//****************   Log-Normal distribution   ***********************************************************

Function IR1_LogNormProbability(x,location,scale, shape)
	variable x, location, scale, shape
	//this function calculates probability for log-normal distribution
	
	variable result
	
	result = exp(-1*( ln( (x-location) / scale) )^2 / (2*shape^2) ) / (shape*sqrt(2*pi)*(x-location))
	if (numtype(result)!=0)
		result=0
	endif
	return result	
end	



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_LogNormCumulative(x,location,scale, shape)
	variable x, location, scale, shape
	//this function calculates cumulative probability for log-normal distribution
	
	variable result, ReducedX
	
	ReducedX=(x-location)/scale
	
	result = (erf((ln(ReducedX)/shape)/sqrt(2))+1)/2
	if(numtype(result)!=0)
		result=0
	endif

	return result
end



//*****************************************************************************************************************
//*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//
Function IR1L_AppendAnyText(TextToBeInserted)		//this function checks for existance of notebook
	string TextToBeInserted						//and appends text to the end of the notebook
	Silent 1
	TextToBeInserted=TextToBeInserted+"\r"
    SVAR/Z nbl=root:Packages:SAS_Modeling:NotebookName
	if(SVAR_exists(nbl))
		if (strsearch(WinList("*",";","WIN:16"),nbl,0)!=-1)				//Logs data in Logbook
			Notebook $nbl selection={endOfFile, endOfFile}
			Notebook $nbl text=TextToBeInserted
		endif
	endif
end

Function IR1L_AppendAnyPorodText(TextToBeInserted)		//**DWS
	string TextToBeInserted						//and appends text to the end of the notebook
	Silent 1
	TextToBeInserted=TextToBeInserted+"\r"
   SVAR/Z nbl=root:Packages:Irena_AnalUnifFit:PorodNotebookName
	if(SVAR_exists(nbl))
		if (strsearch(WinList("*",";","WIN:16"),nbl,0)==-1)				//Create PorodAnalysisResults notebook if necessary
			IR1_CreatePorodLogbook()		
		endif
		Notebook $nbl selection={endOfFile, endOfFile}
		Notebook $nbl text=TextToBeInserted		
	endif
end
//
//
//
//
Function IR1_PullUpLoggbook()

	if(!DataFolderExists("root:Packages:SAS_Modeling"))
		abort "Notebook does not exist, folder does not exist,nothing exists... Did not initialize properly"
	endif

	SVAR/Z nbl=root:Packages:SAS_Modeling:NotebookName
	if(!Svar_Exists(nbL))
		abort "Notebook does not exist, folder does not exist,nothing exists... Did not initialize properly"
	endif
	string nbLL=nbl
//	string nbLL="SAS_FitLog"
	Silent 1
	if (strsearch(WinList("*",";","WIN:16"),nbLL,0)!=-1) 		///Logbook exists
		DoWindow/F $nbLL
	endif

end
//
Function IR1_CreatePorodLogbook()//***DWS

	SVAR/Z nb=root:Packages:Irena_AnalUnifFit:PorodNotebookName
	if(!SVAR_Exists(nb))
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena_AnalUnifFit
		String/G root:Packages:Irena_AnalUnifFit:PorodNotebookName=""
		SVAR nb=root:Packages:Irena_AnalUnifFit:PorodNotebookName
		nb="PorodAnalysisResults"
	endif
	Silent 1
	if (strsearch(WinList("*",";","WIN:16"),nb,0)!=-1) 		///Logbook exists
		DoWindow/HIDE=1 $nb
	else
		NewNotebook/N=$nb/F=1/V=0/K=3/W=(83,131,1766,800) as "PorodAnalysisResults"
		Notebook $nb defaultTab=144, statusWidth=238
		Notebook $nb showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={180,252+1*8192,360+3*8192}, rulerDefaults={"Arial",10,0,(0,0,0)}
		Notebook $nb newRuler=logbookRuler, justification=0, margins={0,0,1578}, spacing={0,0,0}, tabs={204+1*8192,258+1*8192,319+1*8192,388+1*8192,432+1*8192,503+1*8192,580+1*8192,665+1*8192,746+1*8192,839+1*8192,912+1*8192,980+1*8192,1035+1*8192,1097+1*8192,1167+1*8192,1268+1*8192,1377+1*8192,1476+1*8192}, rulerDefaults={"Arial",14,1,(0,0,0)}
		Notebook $nb ruler=logbookRuler, fSize=10
		Notebook $nb text="rWave\tMethod\tStart\tEnd\tUseCsrs\tB[cm-1A-4]\tQv[Cm-1A-3 ]\tpiB/Q[m2/cm3]\tMinDens[g/cm3]\tMajDens[g/cm3]\tS"
		Notebook $nb text="amDens[g/cm3]\tphimin\tSv[m2/cm3]\tSm[m2/g]\tMinChord[A]\tMajChord[A]\t10^-10xSLmin[cm/g]\t10^-10xSLmaj[cm/g]\r"
		Notebook $nb fSize=-1
		Notebook $nb text="rWv\tMeth\tStart\tEnd\tCsrs\tB\tQv\tpiBoQ\tMinDen\tMajDen\tSamDen\tphimin\tSv\tSm\tMinCh\tMajCh\tSLmin \tSLmaj\r"
		Notebook $nb text="\r"
		DoWindow/HIDE=0 $nb
	endif
end
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//

Function IR1_InsertDateAndTime(nbl)
	string nbl
	
	Silent 1
	string bucket11
	Variable now=datetime
	bucket11=Secs2Date(now,0)+",  "+Secs2Time(now,0) +"\r"
	//SVAR nbl=root:Packages:SAS_Modeling:NotebookName
	Notebook $nbl selection={endOfFile, endOfFile}
	Notebook $nbl text=bucket11
end
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//
//Function IR1S_UpdateModeMedianMean()
//
//	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
//	
//	variable i
//	For (i=1;i<=NumberOfDistributions;i+=1)
//		IR1S_UpdtSeparateMMM(i)
//	endfor
//end
//
//
Function IR1_CreateLoggbook()

	SVAR/Z nbl=root:Packages:SAS_Modeling:NotebookName
	if(!SVAR_Exists(nbl))
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:SAS_Modeling 
		String/G root:Packages:SAS_Modeling:NotebookName=""
		SVAR nbl=root:Packages:SAS_Modeling:NotebookName
		nbL="SAS_FitLog"
	endif
	
	string nbLL=nbl
	
	Silent 1
	if (strsearch(WinList("*",";","WIN:16"),nbL,0)!=-1) 		///Logbook exists
		DoWindow/B $nbl
	else
		NewNotebook/K=3/V=0/N=$nbl/F=1/V=1/W=(235.5,44.75,817.5,592.25) as nbl+": Irena Log"
		Notebook $nbl defaultTab=144, statusWidth=238, pageMargins={72,72,72,72}
		Notebook $nbl showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nbl newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={2.5*72, 3.5*72 + 8192, 5*72 + 3*8192}, rulerDefaults={"Arial",10,0,(0,0,0)}
		Notebook $nbl ruler=Normal; Notebook $nbl  justification=1, rulerDefaults={"Arial",14,1,(0,0,0)}
		Notebook $nbl text="This is log results of processing SAS data with Irena package.\r"
		Notebook $nbl text="\r"
		Notebook $nbl ruler=Normal
		IR1_InsertDateAndTime(nbl)
	endif

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//
//Function IR1S_UpdtSeparateMMM(distNum)
//	Variable distNum
//
//	string OldDf=GetDataFolder(1)
//	SetDataFolder root:Packages:SAS_Modeling
//
//	NVAR DistMean=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Mean")
//	NVAR DistMedian=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Median")
//	NVAR DistMode=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Mode")
//	NVAR DistLocation=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Location")
//	NVAR DistScale=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Scale")
//	NVAR DistShape=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Shape")
//	NVAR DistFWHM=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"FWHM")
//	SVAR DistDistributionType=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"DistributionType")
//	NVAR UseNumberDistribution=root:Packages:SAS_Modeling:UseNumberDistribution
//
//	Wave Distdiameters=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"diameters")
//	
//	Duplicate/O Distdiameters, Temp_Probability, Temp_Cumulative, Another_temp
//	Redimension/D Temp_Probability, Temp_Cumulative, Another_temp
//		if (cmpstr(DistDistributionType,"LogNormal")==0)
//			Temp_Probability=IR1_LogNormProbability(Distdiameters,DistLocation,DistScale, DistShape)
//			Temp_Cumulative=IR1_LogNormCumulative(Distdiameters,DistLocation,DistScale, DistShape)
//		endif
//		if (cmpstr(DistDistributionType,"Gauss")==0)
//			Temp_Probability=IR1_GaussProbability(Distdiameters,DistLocation,DistScale, DistShape)
//			Temp_Cumulative=IR1_GaussCumulative(Distdiameters,DistLocation,DistScale, DistShape)
//		endif
//		if (cmpstr(DistDistributionType,"LSW")==0)
//			Temp_Probability=IR1_LSWProbability(Distdiameters,DistLocation,DistScale, DistShape)
//			Temp_Cumulative=IR1_LSWCumulative(Distdiameters,DistLocation,DistScale, DistShape)
//		endif
//		if (cmpstr(DistDistributionType,"PowerLaw")==0)
//			Temp_Probability=NaN
//			Temp_Cumulative=NaN
//		endif
//
//	
//		Another_temp=Distdiameters*Temp_Probability
//		DistMean=areaXY(Distdiameters, Another_temp,0,inf)					//Sum P(R)*R*deltaR
//		DistMedian=Distdiameters[BinarySearchInterp(Temp_Cumulative, 0.5 )]		//R for which cumulative probability=0.5
//		FindPeak/P/Q Temp_Probability
//		DistMode=Distdiameters[V_PeakLoc]								//location of maximum on the P(R)
//		
//		DistFWHM=IR1_FindFWHM(Temp_Probability,Distdiameters)				//Ok, this is monkey approach
//
//		if (cmpstr(DistDistributionType,"PowerLaw")==0)
//			DistFWHM=NaN
//			DistMode=NaN
//			DistMedian=NaN
//			DistMean=NaN
//		endif
//	DoWindow IR1S_ControlPanel
//	if (V_Flag)
//		SetVariable $("DIS"+num2str(distNum)+"_Mode"),value= $("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Mode"), format="%.1f", win=IR1S_ControlPanel 
//		SetVariable $("DIS"+num2str(distNum)+"_Median"),value= $("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Median"), format="%.1f", win=IR1S_ControlPanel 
//		SetVariable $("DIS"+num2str(distNum)+"_Mean"),value= $("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Mean"), format="%.1f", win=IR1S_ControlPanel 
//		SetVariable $("DIS"+num2str(distNum)+"_FWHM"),value= $("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"FWHM"), format="%.1f", win=IR1S_ControlPanel 
//	endif
//	DoWindow IR1U_ControlPanel
//	if (V_Flag)
//		SetVariable $("DIS"+num2str(distNum)+"_Mode"),value= $("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Mode"), format="%.1f", win=IR1U_ControlPanel 
//		SetVariable $("DIS"+num2str(distNum)+"_Median"),value= $("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Median"), format="%.1f", win=IR1U_ControlPanel 
//		SetVariable $("DIS"+num2str(distNum)+"_Mean"),value= $("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Mean"), format="%.1f", win=IR1U_ControlPanel 
//		SetVariable $("DIS"+num2str(distNum)+"_FWHM"),value= $("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"FWHM"), format="%.1f", win=IR1U_ControlPanel 
//	endif
//	
//	
//	KillWaves/Z Temp_Probability, Temp_Cumulative, Another_Temp
//
//	setDataFolder OldDf
//end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_FindFWHM(IntProbWave,DiaWave)
	wave IntProbWave,DiaWave

//	string OldDf=GetDataFolder(1)
//	SetDataFolder root:Packages:SAS_Modeling

	wavestats/Q IntProbWave
	
	variable maximum=V_max
	variable maxLoc=V_maxLoc
	Duplicate/O/R=[0,maxLoc] IntProbWave, temp_wv1
	Duplicate/O/R=[0,maxLoc] DiaWave, temp_RWwv1
	
	Duplicate/O/R=[maxLoc, numpnts(IntProbWave)-1] IntProbWave temp_wv2
	Duplicate/O/R=[maxLoc, numpnts(IntProbWave)-1] DiaWave, temp_RWwv2
	
	variable tempMin=BinarySearchInterp(temp_wv1, (maximum/2) )
	variable tmpMax=BinarySearchInterp(temp_wv2, (maximum/2) )
	variable MinD
	variable MaxD
	if(tempMin>0 && tempMin<numpnts(temp_wv1))
		MinD=temp_RWwv1[tempMin]
	else
		MinD=0
	endif
	if(tmpMax>0  && tmpMax<numpnts(temp_wv2))
		MaxD=temp_RWwv2[tmpMax]
	else
		MaxD=0
	endif
	KillWaves/Z temp_wv2, temp_wv1,temp_RWwv1,temp_RWwv2

//	setDataFolder OldDf
	
	return abs(MaxD-MinD)
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//****************   This calculates distribution of diameters and needed for the probability distribution   ***********************************************************

Function IR1_GenerateDiametersDist(MyFunction, OutputWaveName, numberOfPoints, myprecision, location,scale, shape)
	string MyFunction, OutputWaveName
	variable numberOfPoints, myprecision, location,scale, shape
	//
	//  Important : this wave will be produced in current folder
	//
	//this function generates non-regular distribution of diameters for distributions
	//Myfunction can now be Gauss, LSW, or LogNormal
	//OutputWaveName is string with wave name. The wave is created with numberOfPoints number of points and existing one, if exists, is overwritten
	// my precision is value (~0.001 for example) which denotes how low probability we want to neglect (P<precision and P>(1-precision) are neglected
	//location, scale, shape are values for the probability distributions
	
	//logic: we start in the median and walk towards low (high) values. When cumulative value is smaller (larger) than precision (1-precision)
	//we end. If we walk out of reasonable values (10A and 10^15A), we stop.
	
	//first we need to find step, which we will use to step from median
	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SAS_Modeling


	variable startx, endx, guess, Step, mode, tempVal, tempResult
	
	if (cmpstr("Gauss",MyFunction)==0)
		Step=scale*0.02					//standard deviation
	endif
	if (cmpstr("LSW",MyFunction)==0)
		Step=location*0.3				//just some step for this distribution
	endif
	if (cmpstr("LogNormal",MyFunction)==0)
		Step=4*sqrt(exp(shape^2)*(exp(shape^2)-1))	//standard deviation
	endif
	if (cmpstr("PowerLaw",MyFunction)==0)
		Step=500	//a number here
	endif
	
	//now we need to find the median

	if (cmpstr("Gauss",MyFunction)==0)
		mode=location	//=median
	endif
	if (cmpstr("LSW",MyFunction)==0)
		mode=location	//close to median, who really cares where we start as long as it is close...
	endif
	if (cmpstr("LogNormal",MyFunction)==0)
		mode=location+scale/(exp(shape^2))	//=median
	endif
	if (cmpstr("PowerLaw",MyFunction)==0)
		mode=500  				// a number
	endif
	// look for minimum
	//now we can start at median and go step by step and end when the 
	//cumulative function is smaller than the myprecision
	
	variable minimumXPossible=1   //if it should be smaller than 2A, it is nonsence...
	
	tempVal=mode
	
	do
		tempVal=tempVal-Step			//OK, this way we should make always one more step over the limit...

		if (tempVal<minimumXPossible)
			tempVal=minimumXPossible
		endif

		if (cmpstr("Gauss",MyFunction)==0)
			tempResult=IR1_GaussCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("LSW",MyFunction)==0)
			tempResult=IR1_LSWCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("LogNormal",MyFunction)==0)
			tempResult=IR1_LogNormCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("PowerLaw",MyFunction)==0)		//this funny function exists over whole size range possible....
			tempResult=0
			tempVal=minimumXPossible
		endif
		
	while ((tempResult>myprecision)&&(tempVal>minimumXPossible))			

	startx = tempVal
	//and this will be needed lower, in case when we have distributions attempting to get into negative diameters...
	variable startCumTrgts=myprecision
	if (startx==minimumXPossible)	//in this case we run into negative values and overwrote the startX values
			if (cmpstr("Gauss",MyFunction)==0)
				startCumTrgts=IR1_GaussCumulative(minimumXPossible,location,scale, shape)
			endif
			if (cmpstr("LSW",MyFunction)==0)
				startCumTrgts=IR1_LSWCumulative(minimumXPossible,location,scale, shape)
			endif
			if (cmpstr("LogNormal",MyFunction)==0)
				startCumTrgts=IR1_LogNormCumulative(minimumXPossible,location,scale, shape)
			endif
			if (cmpstr("PowerLaw",MyFunction)==0)
				startCumTrgts=myprecision
			endif
	endif

	//now we need to calculate the endx

	variable maximumXPossible=1e15	//maximum, fixed for giant number due to use of the code for light scattering
		
	tempVal=mode
	
	do
		tempVal=tempVal+Step		//again, whould be one step larger than needed...
		if (tempVal>maximumXPossible)
			tempVal=maximumXPossible
		endif

		if (cmpstr("Gauss",MyFunction)==0)
			tempResult=IR1_GaussCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("LSW",MyFunction)==0)
			tempResult = 1
			tempVal = 1.5 * location //this distribution does not exist over this value...
		endif
		if (cmpstr("LogNormal",MyFunction)==0)
			tempResult=IR1_LogNormCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("PowerLaw",MyFunction)==0)
			maximumXPossible=1e7
			tempResult=1
			tempVal=maximumXPossible
		endif

	while ((tempResult<(1-myprecision))&&(tempVal<maximumXPossible))			
	
	endx = tempVal

	//and now we can start making the the data. 
	// First we will create a wave with equally distributed values between myprecision and 1-myprecision : Temp_CumulTargets
	//We will also create waves with 3*as many points with diameters between startx and endx (Temp_diameters) and with appropriate cumulative distribution (Temp_CumulativeWave)
	//then we will look for which diameters we get the cumulative numbers in Temp_CumulTargets and put these in output wave
	
	Make/D /N=(numberOfPoints) /O Temp_CumulTargets, $OutputWaveName
	Make/D /N=(3*numberOfPoints) /O Temp_CumulativeWave,Temp_diameters
	
	Wave DistributiondiametersWave=$OutputWaveName
	
	Temp_diameters=startx+p*(endx-startx)/(3*numberOfPoints-1)			//this puts the proper diameters distribution in the temp diameters wave
	
	Temp_CumulTargets=startCumTrgts+p*(1-myprecision-startCumTrgts)/(numberOfPoints-1) //this puts equally spaced values between myprecision and (1-myprecision) in this wave
	
	//calculate the cumulative waves
	if (cmpstr("Gauss",MyFunction)==0)
		Temp_CumulativeWave=IR1_GaussCumulative(Temp_diameters,location,scale, shape)
	endif
	if (cmpstr("LSW",MyFunction)==0)
		Temp_CumulativeWave=IR1_LSWCumulative(Temp_diameters,location,scale, shape)
		Temp_CumulativeWave[numpnts(Temp_CumulativeWave)-1]=1	//last point is NaN, we need to make it 1
	endif
	if (cmpstr("LogNormal",MyFunction)==0)
		Temp_CumulativeWave=IR1_LogNormCumulative(Temp_diameters,location,scale, shape)
	endif
	if (cmpstr("PowerLaw",MyFunction)==0)
		Temp_CumulativeWave=IR1_PowerLawCumulative(Temp_diameters,shape,startx,endx)
	endif
	
		//and now the difficult part - get the diameterss, which are unequally spaced, but whose probability for the distribution are equally spaced...
		DistributionDiametersWave=interp(Temp_CumulTargets, Temp_CumulativeWave, Temp_diameters )
	variable temp
	if (cmpstr("PowerLaw",MyFunction)==0) //the code above fails for this distribution type, we need to create new diameters...
		//DistributionDiametersWave=startx+log(p)*(endx-startx)/log(numberOfPoints)
		//temp=log(startx)+p*((log(endx)-log(startx))/(numberOfPoints-1))
		DistributionDiametersWave=10^(log(startx)+p*((log(endx)-log(startx))/(numberOfPoints-1)))
	endif

	
	//and now cleanup
	
	KillWaves/Z Temp_CumulTargets //, myTest
	KillWaves/Z Temp_CumulativeWave,Temp_diameters

	setDataFolder OldDf
	
end



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//**********************************************************************************************************

Function IR1_KillGraphsAndPanels()



	String ListOfWindows
	ListOfWindows = "UnivDataExportPanel;TempExportGraph;ExportNoteDisplay;IR1G_OneSampleEvaluationGraph;MIPDataGraph;IR2D_LogLogPlotSAD;"
	ListOfWindows += "IR2D_ControlPanel;IR2H_SI_Q2_PlotGels;IR2H_IQ4_Q_PlotGels;IR2H_LogLogPlotGels;IR2H_ControlPanel;Shape_Model_Input_Panel;"
	ListOfWindows += "IR1S_InterferencePanel;IR1K_AnomCalcPnl;IR1G_OneSampleEvaluationGraph;IR1K_ScatteringContCalc;IR1F_CreateQRSFldrStructure;"
	ListOfWindows += "IR1B_DesmearingControlPanel;TrimGraph;SmoothGraph;CheckTheBackgroundExtns;DesmearingProcess;SmoothGraphDSM;"
	ListOfWindows += "IR1Y_ScatteringContrastPanel;About_Irena_1_Macros;IR1R_SizesInputPanel;IR1_LogLogPlotU;IR1_LogLogPlotLSQF;IR1P_ChangeGraphDetailsPanel;"
	ListOfWindows += "IR1_IQ4_Q_PlotU;IR1_IQ4_Q_PlotLSQF;IR1_Model_Distributions;IR1S_ControlPanel;IR1P_ControlPanel;IR1U_ControlPanel;"
	ListOfWindows += "IR1A_ControlPanel;IR1R_SizesInputGraph;IR1P_PlottingTool;GeneralGraph;IR1P_ControlPanel;IR1P_RemoveDataPanel;"
	ListOfWindows += "IR1P_ModifyDataPanel;IR1P_RemoveDataPanel;IR1P_StoreGraphsCtrlPnl;IR1D_DataManipulationPanel;IR1D_DataManipulationGraph;"
	ListOfWindows += "IR1I_ImportData;IR1V_ControlPanel;IR1V_LogLogPlotV;IR1V_IQ4_Q_PlotV;IR2S_ScriptingToolPnl;IR2Pr_PDFInputGraph;IR2Pr_ControlPanel;"
	ListOfWindows += "PlotingToolWaterfallGrph;LSQF2_MainPanel;LSQF_MainGraph;GraphSizeDistributions;LSQF_ResidualsGraph;Irena_Gizmo;GizmoControlPanel;"
	ListOfWindows += "DataMiningTool;ItemsInFolderPanel;ItemsInFolderPanel_DMII;DataManipulationII;IR2R_InsertRemoveLayers;PlotingToolContourGrph;"
	ListOfWindows += "FormFactorControlScreen;StructureFactorControlScreen;UnifiedEvaluationPanel;IR2H_ResidualsPlot;IR1P_StylesManagementPanel;"
	ListOfWindows += "ModelingII_Results;LSQF_IQ4vsQGraph;IR2L_ResSmearingPanel;IR1P_MoreToolsPanel;IR1R_SizeDistImportFitPanel;"
	ListOfWindows += "TwoPhaseSystemData;TwoPhaseSolidGizmo;TwoPhaseSystems;FractalAggregatePanel;MassFractalAggregateView;TwoPhaseSolid2DImage;"
	
	
	variable i
	string TempNm
	For(i=0;i<ItemsInList(ListOfWindows);i+=1)
		TempNm = stringFromList(i,ListOfWindows)
		KillWIndow/Z $TempNm
	endfor
end

////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
Function/T IR1_ReturnListQRSFolders(ListOfQFolders, AllowQROnly)
	string ListOfQFolders
	variable AllowQROnly
	
	string result, tempStringQ, tempStringR, tempStringS, nowFolder,oldDf
	oldDf=GetDataFolder(1)
	variable i, j
	string tempStr
	result=""
	For(i=0;i<ItemsInList(ListOfQFolders);i+=1)
		NowFolder= stringFromList(i,ListOfQFolders)
		setDataFolder NowFolder
		tempStr=IN2G_ConvertDataDirToList(DataFolderDir(2))
		tempStringQ=IR2P_ListOfWavesOfType("q*",tempStr)+IR2P_ListOfWavesOfType("d*",tempStr)+IR2P_ListOfWavesOfType("t*",tempStr)+IR2P_ListOfWavesOfType("m*",tempStr)
		tempStringR=IR2P_ListOfWavesOfType("r*",tempStr)
		tempStringS=IR2P_ListOfWavesOfType("s*",tempStr)
		For (j=0;j<ItemsInList(tempStringQ);j+=1)
			if(AllowQROnly)
				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringQ)[1,inf]+";*"))
					result+=NowFolder+";"
					break
				endif
			else
				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringQ)[1,inf]+";*") && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringQ)[1,inf]+";*"))
					result+=NowFolder+";"
					break
				endif
			endif
		endfor
				
	endfor
	setDataFOlder oldDf
	return result

end


////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////
////Function/T IR1_ListOfWavesOfType(type,ListOfWaves)
////		string type, ListOfWaves
////		
////		variable i
////		string tempresult=""
////		for (i=0;i<ItemsInList(ListOfWaves);i+=1)
////			if (stringMatch(StringFromList(i,ListOfWaves),type+"*"))
////				tempresult+=StringFromList(i,ListOfWaves)+";"
////			endif
////		endfor
////
////	return tempresult
////end
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************

Function/T IR1_ListIndraWavesForPopups(WhichWave,WhereAreControls,IncludeSMR,OneOrTwo)
	string WhichWave,WhereAreControls
	variable IncludeSMR, OneOrtwo		//if IncludeSMR=-1 then ONLY SMR data!

	string AllWavesInt
	string AllWavesQ 	
	string AllWavesE 	
	if(OneOrTwo==1)
		 AllWavesInt = IR1_ListOfWaves("DSM_Int",WhereAreControls,abs(IncludeSMR),0)	
		 AllWavesQ = IR1_ListOfWaves("DSM_Qvec",WhereAreControls,abs(IncludeSMR),0)	
		 AllWavesE = IR1_ListOfWaves("DSM_Error",WhereAreControls,abs(IncludeSMR),0)	
	else
		 AllWavesInt = IR1_ListOfWaves2("DSM_Int",WhereAreControls,abs(IncludeSMR),0)	
		 AllWavesQ = IR1_ListOfWaves2("DSM_Qvec",WhereAreControls,abs(IncludeSMR),0)	
		 AllWavesE = IR1_ListOfWaves2("DSM_Error",WhereAreControls,abs(IncludeSMR),0)	
	endif
	
	string SelectedInt=""
	string SelectedQ=""
	string SelectedE=""
	string result
	//M_BKG_Int
	if(stringmatch(AllWavesInt, "*M_BKG_Int*") && stringmatch(AllWavesQ, "*M_BKG_Qvec*")  && stringmatch(AllWavesE, "*M_BKG_Error*") )		
		SelectedInt+="M_BKG_Int;"
		SelectedQ+="M_BKG_Qvec;"
		SelectedE+="M_BKG_Error;"
	endif
	if(stringmatch(AllWavesInt, "*BKG_Int*") && stringmatch(AllWavesQ, "*BKG_Qvec*")  && stringmatch(AllWavesE, "*BKG_Error*") )		
		SelectedInt+="BKG_Int;"
		SelectedQ+="BKG_Qvec;"
		SelectedE+="BKG_Error;"	
	endif
	if(stringmatch(AllWavesInt, "*M_DSM_Int*") && stringmatch(AllWavesQ, "*M_DSM_Qvec*")  && stringmatch(AllWavesE, "*M_DSM_Error*") )		
		SelectedInt+="M_DSM_Int;"
		SelectedQ+="M_DSM_Qvec;"
		SelectedE+="M_DSM_Error;"	
	endif
	if(stringmatch(AllWavesInt, "*DSM_Int*") &&stringmatch( AllWavesQ, "*DSM_Qvec*")  && stringmatch(AllWavesE, "*DSM_Error*") )		
		SelectedInt+="DSM_Int;"
		SelectedQ+="DSM_Qvec;"
		SelectedE+="DSM_Error;"	
	endif
	if(IncludeSMR && stringmatch(AllWavesInt, "*M_SMR_Int*") &&stringmatch( AllWavesQ, "*M_SMR_Qvec*")  &&stringmatch( AllWavesE, "*M_SMR_Error*") )		
		SelectedInt+="M_SMR_Int;"
		SelectedQ+="M_SMR_Qvec;"
		SelectedE+="M_SMR_Error;"	
	endif
	if(IncludeSMR && stringmatch(AllWavesInt, "*SMR_Int*") && stringmatch(AllWavesQ, "*SMR_Qvec*")  && stringmatch(AllWavesE, "*SMR_Error*") )		
		SelectedInt+="SMR_Int;"
		SelectedQ+="SMR_Qvec;"
		SelectedE+="SMR_Error;"	
	endif	
	if((IncludeSMR==-1))
		SelectedInt=""
		SelectedQ=""
		SelectedE=""	
	endif
	if((IncludeSMR==-1) && stringmatch(AllWavesInt, "*SMR_Int*") && stringmatch(AllWavesQ, "*SMR_Qvec*")  && stringmatch(AllWavesE, "*SMR_Error*") )		
		SelectedInt+="SMR_Int;"
		SelectedQ+="SMR_Qvec;"
		SelectedE+="SMR_Error;"	
	endif	
	if((IncludeSMR==-1) && stringmatch(AllWavesInt, "*M_SMR_Int*") &&stringmatch( AllWavesQ, "*M_SMR_Qvec*")  &&stringmatch( AllWavesE, "*M_SMR_Error*") )		
		SelectedInt+="M_SMR_Int;"
		SelectedQ+="M_SMR_Qvec;"
		SelectedE+="M_SMR_Error;"	
	endif

	SelectedE+="---;"
	if(cmpstr(whichWave,"DSM_Int")==0)
		result = SelectedInt
	elseif(cmpstr(whichWave,"DSM_Qvec")==0)
		result = SelectedQ
	else
		result = SelectedE	
	endif
	if (strlen(result)<1)
		result="---;"
	endif
	return result
end

////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
Function/T IR1_ListOfWaves(WaveTp,WhereAreControls, IncludeSMRData, AllowQRDataOnly)
	string WaveTp, WhereAreControls
	variable  IncludeSMRData, AllowQRDataOnly
	
	//	if UseIndra2Structure = 1 we are using Indra2 data, else return all waves 
	
	string result="", tempresult="", dataType="", tempStringQ="", tempStringR="", tempStringS=""
	SVAR FldrNm=$("root:Packages:"+WhereAreControls+":DataFolderName")
	NVAR Indra2Dta=$("root:Packages:"+WhereAreControls+":UseIndra2Data")
	NVAR QRSdata=$("root:Packages:"+WhereAreControls+":UseQRSData")
	variable i,j
		
	if (Indra2Dta)
		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
		if(stringMatch(result,"*"+WaveTp+"*"))
			tempresult=""
			for (i=0;i<ItemsInList(result);i+=1)
				if (stringMatch(StringFromList(i,result),"*"+WaveTp+"*"))
					tempresult+=StringFromList(i,result)+";"
				endif
			endfor
		endif
		if (cmpstr(WaveTp,"DSM_Int")==0)
			For (j=0;j<ItemsInList(result);j+=1)
				if (stringMatch(StringFromList(j,result),"*BKG_Int*"))
					tempresult+=StringFromList(j,result)+";"
				endif
				if(IncludeSMRData)
					if (stringMatch(StringFromList(j,result),"*SMR_Int*"))
						tempresult+=StringFromList(j,result)+";"
					endif				
				endif
			endfor
		elseif(cmpstr(WaveTp,"DSM_Qvec")==0)
			For (j=0;j<ItemsInList(result);j+=1)
				if (stringMatch(StringFromList(j,result),"*BKG_Qvec*"))
					tempresult+=StringFromList(j,result)+";"
				endif
				if(IncludeSMRData)
					if (stringMatch(StringFromList(j,result),"*SMR_Qvec*"))
						tempresult+=StringFromList(j,result)+";"
					endif				
				endif
			endfor
		else
			For (j=0;j<ItemsInList(result);j+=1)
				if (stringMatch(StringFromList(j,result),"*BKG_Error*"))
					tempresult+=StringFromList(j,result)+";"
				endif
				if(IncludeSMRData)
					if (stringMatch(StringFromList(j,result),"*SMR_Error*"))
						tempresult+=StringFromList(j,result)+";"
					endif				
				endif
			endfor
	endif
			result=tempresult
	elseif(QRSData) 
		result=""			//IN2G_CreateListOfItemsInFolder(FldrNm,2)
		tempStringQ=IR2P_ListOfWavesOfType("q",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		tempStringR=IR2P_ListOfWavesOfType("r",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		tempStringS=IR2P_ListOfWavesOfType("s",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		
		if (cmpstr(WaveTp,"DSM_Int")==0)
//			dataType="r"
			For (j=0;j<ItemsInList(tempStringR);j+=1)
				if(AllowQRDataOnly)
					if (stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringR)[1,inf]+";*"))
						result+=StringFromList(j,tempStringR)+";"
					endif
				else
					if (stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringR)[1,inf]+";*") && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringR)[1,inf]+";*"))
						result+=StringFromList(j,tempStringR)+";"
					endif
				endif
			endfor
		elseif(cmpstr(WaveTp,"DSM_Qvec")==0)
//			dataType="q"
			For (j=0;j<ItemsInList(tempStringQ);j+=1)
				if(AllowQRDataOnly)
					if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringQ)[1,inf]+";*"))
						result+=StringFromList(j,tempStringQ)+";"
					endif
				else
					if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringQ)[1,inf]+";*") && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringQ)[1,inf]+";*"))
						result+=StringFromList(j,tempStringQ)+";"
					endif
				endif	
			endfor
		else
//			dataType="s"			
			For (j=0;j<ItemsInList(tempStringS);j+=1)
				if(AllowQRDataOnly)
					//nonsense...
				else
					if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringS)[1,inf]+";*") && stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringS)[1,inf]+";*"))
						result+=StringFromList(j,tempStringS)+";"
					endif
				endif
			endfor
		endif
	else
		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
	endif
	
	return result
end

Function/T IR1_ListOfWaves2(WaveTp,WhereAreControls, IncludeSMRData,AllowQRDataOnly)
	string WaveTp, WhereAreControls
	variable IncludeSMRData, AllowQRDataOnly
	
	//	if UseIndra2Structure = 1 we are using Indra2 data, else return all waves 
	
	string result, tempresult, dataType, tempStringQ, tempStringR, tempStringS
	SVAR FldrNm=$("root:Packages:"+WhereAreControls+":DataFolderName2")
	NVAR Indra2Dta=$("root:Packages:"+WhereAreControls+":UseIndra2Data2")
	NVAR QRSdata=$("root:Packages:"+WhereAreControls+":UseQRSData2")
	variable i,j
	tempresult=""
		
	if (Indra2Dta)
		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
		if(stringMatch(result,"*"+WaveTp+"*"))
			for (i=0;i<ItemsInList(result);i+=1)
				if (stringMatch(StringFromList(i,result),"*"+WaveTp+"*"))
					tempresult+=StringFromList(i,result)+";"
				endif
			endfor
		endif
		if (cmpstr(WaveTp,"DSM_Int")==0)
			For (j=0;j<ItemsInList(result);j+=1)
				if (stringMatch(StringFromList(j,result),"*BKG_Int*"))
					tempresult+=StringFromList(j,result)+";"
				endif
				if(IncludeSMRData)
					if (stringMatch(StringFromList(j,result),"*SMR_Int*"))
						tempresult+=StringFromList(j,result)+";"
					endif				
				endif
			endfor
		elseif(cmpstr(WaveTp,"DSM_Qvec")==0)
			For (j=0;j<ItemsInList(result);j+=1)
				if (stringMatch(StringFromList(j,result),"*BKG_Qvec*"))
					tempresult+=StringFromList(j,result)+";"
				endif
				if(IncludeSMRData)
					if (stringMatch(StringFromList(j,result),"*SMR_Qvec*"))
						tempresult+=StringFromList(j,result)+";"
					endif				
				endif
			endfor
		else
			For (j=0;j<ItemsInList(result);j+=1)
				if (stringMatch(StringFromList(j,result),"*BKG_Error*"))
					tempresult+=StringFromList(j,result)+";"
				endif
				if(IncludeSMRData)
					if (stringMatch(StringFromList(j,result),"*SMR_Error*"))
						tempresult+=StringFromList(j,result)+";"
					endif				
				endif
			endfor
			result=tempresult
		endif
	elseif(QRSData) 
		result=""			//IN2G_CreateListOfItemsInFolder(FldrNm,2)
		tempStringQ=IR2P_ListOfWavesOfType("q",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		tempStringR=IR2P_ListOfWavesOfType("r",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		tempStringS=IR2P_ListOfWavesOfType("s",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		
		if (cmpstr(WaveTp,"DSM_Int")==0)
//			dataType="r"
			For (j=0;j<ItemsInList(tempStringR);j+=1)
				if(AllowQRDataOnly)
					if (stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringR)[1,inf]+";*"))
						result+=StringFromList(j,tempStringR)+";"
					endif
				else
					if (stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringR)[1,inf]+";*") && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringR)[1,inf]+";*"))
						result+=StringFromList(j,tempStringR)+";"
					endif
				endif
			endfor
		elseif(cmpstr(WaveTp,"DSM_Qvec")==0)
//			dataType="q"
			For (j=0;j<ItemsInList(tempStringQ);j+=1)
				if(AllowQRDataOnly)
					if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringQ)[1,inf]+";*"))
						result+=StringFromList(j,tempStringQ)+";"
					endif
				else
					if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringQ)[1,inf]+";*") && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringQ)[1,inf]+";*"))
						result+=StringFromList(j,tempStringQ)+";"
					endif
				endif	
			endfor
		else
//			dataType="s"			
			For (j=0;j<ItemsInList(tempStringS);j+=1)
				if(AllowQRDataOnly)
					//nonsense...
				else
					if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringS)[1,inf]+";*") && stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringS)[1,inf]+";*"))
						result+=StringFromList(j,tempStringS)+";"
					endif
				endif
			endfor
		endif
	else
		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
	endif
	
	return result
end

