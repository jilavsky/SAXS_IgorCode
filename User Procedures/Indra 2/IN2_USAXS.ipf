#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3			// Use modern global access method.
#pragma IgorVersion=8.03   //requires Igor version 8.03 or higher
#pragma version = 1.985

constant CurrentIndraVersionNumber = 1.985
//*************************************************************************\
//* Copyright (c) 2005 - 2021, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.985   beta 
//			Removed lots of old code for USAXS, its not working anyway. 	
//1.98		require Igor 8.03, no testing for Igor 7 anymore. 
//			step scanning from BS still not fully supported, needs more developement. 
//1.976 	Beta version after February2020 release
//1.97 	Add print in history which version has compiled, Useful info later when debugging.
//			attempt to set automatically Qmin for the data. Increase default number of points to 500
//1.96   December 2018 release. Updates 64 bit OSX xops.
//1.95 	Igor 8 release, ongoing fixes for USAXS software changes. Modified behavior of Automatic blank selection in GUI. 
//1.94	Converted all procedure files to UTF8 to prevent text encoding issues. 
//			Fixed Case spelling of USAXS Error data to SMR_Error and DSM_Error.
//			Added ability to smooth R_Int data - suitable mostly for Blank where it removes noise from the blank. Should reduce noise of the USAXS data. 
//			Added masking options into FLyscan panel Listbox. 
//			Checked that - with reduced functionality - code will work without Github distributed xops. 
//			Tested and fixed for Igor 8 beta version. 
//			
//1.93 Promoted requriements to 7.05 due to bug in HDF5 support at lower versions
// 	 added resize after recreating of the panels to prior user size. 
//1.92 is Igor 7 only release 5/1/2017
//1.91 is minor patch for Igor 6 on May 2017
//1.90 use Indra release numbers here, #pragma IgorVersion=7.00
//1.39 release 1.88, added panel scaling to some panels and remove from name string to flyscans. 
//1.38 relase 1.86, added dropouts removal for Flyscan data. 
//1.37 added ability to remove points on PD_Intensity for peak center fitting with marquee. 
//1.36 added Remove RAW folder to shrink size of Experiments
//1.35 yet another change in Menu items to make it more obvious
//1.34 changed RemovePointswith marquee to be dynamic menuitem.
//1.33 added Remove points with marquee
//1.32 added FlyScan and panel check for Indra version
//1.31 added ability to use pinDiode transmission measured first time 4/2013
//1.30 added weight calibration
//1.29 modified not to fail to compile when XML xop is not present. 
//1.28 release to update error calculation for I0 autoranging. 
//1.27 release from 4/30/2012, updates for autoranging I0
//1.26 release 1.74 of Indra package, 2/16/2012. Some minor fixes.
//1.25 release 1.73 of Indra package, 2/19/2012. Added new Xtal calculator.

Menu "GraphMarquee", dynamic
      IN2G_MenuItemForGraph("Remove Points With Marquee","RcurvePlotGraph"),/Q, RemovePointsWithMarquee()

	//"Remove Points with Marquee", RemovePointsWithMarquee()
End


Menu "USAXS"
	"Import and Reduce USAXS Flyscan data",IN3_NewMain()
	help={"GUI to import and process Flyscan data (reccomended for Flyscans)"}
	Submenu "Other input methods"
		"Import USAXS Step scan Data [SPEC]", In2_ImportData()
		help={"Import USAXS data from APS USAXS instrument - from Spec file"}
		"Import Desktop data [Osmic-Rigaku]",  IN2U_LoadDesktopData()
		help={"Import USAXS data set from desktop instrument - Osmic/Rigaku"}
		//"Import USAXS FlyScan data [hdf5]", IN3_FlyScanMain()
		//help={"Import USAXS data from USAXS using FlyScan - HDF5 data"}
		"---"
		"Reduce USAXS data (old, spec)",IN3_Main()
		help={"This willl reduce USAXS data stored in this experiment"}
	end
	"Setup Sample Plates",IN3S_SampleSetupMain()
	help={"Tool to help users setup sample plates, survey and generate command files"}

	"Calculate Scattering from model", IN3M_CalculateDataFromModel()
	help={"Use model and sample parameters to calculate scattering"}

	//	"Desmear Fast", IN2D_DesmearFastMain()  //removed since no one used it, but code stays...
	"--"
	//"Export data",IN2B_ExportAllData() 
	//help={"Export all data from weithin Igor for use in different packages. Not necessary for Irena 1 package."}

	"Xtal position calc", IN2Y_GapCalculations()
	help={"Crystal position callculator for beamline staff."}
	
	//	"Import X23 Data", IN2I_ImportX23Data()		//code commented out since no one was using it... 
	//	"---"
	//	"GA USAXS correction", Correct_GA_USAXS()		//also not needed as far as I can find out
	"--"
	Submenu "Old stuff"
	//	"Create R wave", IN2A_CreateRWave()
	// help={"Correct measured data for dark currents and find beam center"}
	//	"Subtract Blank from Sample", IN2B_AlignSampleAndBlank()
	//	help={"Subtract blank data from sample and correct"}
	//	"MSAXS Correction", IN2A_MSAXScorrection()
	//	help={"Correction for transmission if multiple scattering is present. Corrects callibration only."}
	//	"Ave MSAXS corr - SBUSAXS", IN2A_MSAXSAverageCorr()
	//	help={"MSAXS correction for SBUSAXS measurements when anisotropy in broadening is observed."}
		"Anisotropic MSAXS", IN2A_AnisotropicMSAXS()
		help={"Part of SBUSAXS MSAXS correction"}
		"Correct AnisoScans", IN2B_CorrectAnisoData("","",1,1)
		help={"Correct ANiso Scans done during SBUSAXS measurements"}
	//	"Merge two DataSets", IN2M_MergeTwoDataSets()
	//	help={"Can sum two data sets of R-data, SMR-data, or DSM_data"}
	
	//	"--"
	//	"Desmear data", IN2D_DesmearSlowMainRedir()
	//	help={"Desmear data from slit smeared aka regular) USAXS."}
	//	"Subtract background", IN2Q_SubtractBackground()
	//	help={"Tool to subtract background from DSM data before export. Not necessary for Irena 1 package."}
	end
	SubMenu "Spec"
		"Read Comments from SPEC file", IN2_ExtractComments()
	//		"---"
	//		"Fix SPEC-to-USAXS waves", IN2_RAWtoUSAXSParametersSetup(0) 
	//		"Fix SPEC-to-USAXS UPD", IN2_PhotodiodeConvPanel() 
	//		"---"
	//		"Raw to USAXS one-by-one",IN2_ConvertRAW_To_USAXSFnct() 
	//		"Raw to USAXS quick", IN2_CovertRaw_To_USAXSAutoF(0)
		"Raw to Non-USAXS", IN2_ConvertRawToOthersFnct()
	end
	SubMenu "Utilities"
		"Shrink Igor experiment size",IN3_ShrinkIgorFileSize() 
		help={"Export all data from within Igor for use in different packages. Not necessary for Irena 1 package."}
		"Config fonts, uncertainties, names", IN3_ConfigureGUIfonts()
		help={"Crystal position callculator for beamline staff."}
		"Check Igor display size", IN2G_CheckForGraphicsSetting(1)
		help={"Check if current display area is suitable for the code"}


	end
//	SubMenu "Logging Notebook"
//		"Show Logbook", IN2N_CreateShowNtbkForLogging(1)
//		"Copy Graph In LogBk BW", IN2N_CopyGraphInNotebook(0)	
//		"Copy Graph In LogBk CLR", IN2N_CopyGraphInNotebook(1)
//		"Insert Date, Time in LogBk", IN2N_InsertDateAndTime()
//		"Notebook Control Panel", IN2N_LogBookControlPanel()
//		"--"
//		"Create Summary Notebook", IN2N_CreateSummaryNotebook(0)
//	End
//	SubMenu "USAXS Plotting tools"
//		"Standard USAXS Plots with math", IN2S_StandardUSAXSPlots()
//		help={"This is advanced plotting tools which with math functions"}
//		"Basic USAXS Plots", IN2P_CommonUSAXSPlots()
//		help={"This is basic plotting tools which without math functions"}
//	//	"Common non-USAXS Plots", IN2P_CommonNonUSAXSPlots()
//		"Generic plotting tool for power users", IN2P_GenericUSAXSPlots()
//		help={"This is  plotting tools which can plot any wave against any other wave, unlikely useful to regular users..."}
//		"--"
//		"Draw Line Of Any Slope", IN2P_DrawLineOfAnySlope()
//		"Draw Line Of -4 Slope",  IN2P_DrawLineOf4Slope()
//		"Draw Line Of -3 Slope",  IN2P_DrawLineOf3Slope()
//		"Draw Line Of -2 Slope",  IN2P_DrawLineOf2Slope()
//		"Make log-log graph decade limits", IN2P_MakeLogLogGraphDecLim()
//		"--"
//		"Fit Line With Cursors", IN2P_FitLineWithCursors()
//		"Fit Power Law with Cursors", IN2P_FitPowerLawWithCursors()
//	End

	"Remove USAXS Macros", IN2_RemoveUSAXSMacros()
	help={"Removes USAXS macros from current experiment"}

	"Open Indra web page", IN2A_OpenIndraPage()
	help={"Open Indra homepage in  web browser"}


	"Open Readme", IN2_OpenReadme()
	help={"Open notes about recent changes in the code. "}
	"About", IN2_AboutPanel()
	help={"Information about the version"}
end


//****************************************************************************************
//****************************************************************************************
////****************************************************************************************
//
//Function/S IN2_MenuItemForGraph(menuItem, onlyForThisGraph)
//	String menuItem, onlyForThisGraph
//	String topGraph=WinName(0,1,1)
//	if( CmpStr(topGraph,onlyForThisGraph) == 0 )
//		return menuItem
//	endif
//	return "" 	// disappearing menu item
//End
//

//****************************************************************************************
//****************************************************************************************
//****************************************************************************************

static Function AfterCompiledHook( )			//check if all windows are up to date to match their code

	NVAR/Z LastCheckIndra=root:Packages:LastCheckIndra
	if(!NVAR_Exists(LastCheckIndra))
		variable/g root:Packages:LastCheckIndra 
		NVAR LastCheckIndra=root:Packages:LastCheckIndra
	endif	
	string WindowProcNames="IN3_FlyScanImportPanel=IN3_FlyScanCheckVersion;USAXSDataReduction=IN3_USAXSDataRedCheckVersion;"
	WindowProcNames+="SamplePlateSetup=IN3S_SaPlateCheckVersion;"
	IN3_CheckWIndowsProcVersions(WindowProcNames)
	IN2G_CheckPlatformGUIFonts()
	IN2G_ResetSizesForAllPanels(WindowProcNames)
	IN2G_AddButtonsToBrowser()		//adds button to DataBrowser. 
	if((DateTime - LastCheckIndra)>60*60*12)		//run this only once per 12 hours. 
		print "*** >>>  Indra version: "+num2str(CurrentIndraVersionNumber)+", compiled on "+date()+"  "+time()
		LastCheckIndra = DateTime
	endif

end
//****************************************************************************************
//****************************************************************************************
//****************************************************************************************

Function IN3_CheckWIndowsProcVersions(WindowProcNames)
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

//***********************************************************
//***********************************************************
//***********************************************************
Function IN3_ShrinkIgorFileSize()
	if(DataFolderExists("root:raw"))
		variable DeleteSize= IN2G_EstimateFolderSize("root:raw:")
		DoAlert /T="Confirm you want to do this" 1, "Do you want to delete folder with raw data to shrink the Igor experiment size? You should save approximately "+num2str(1.1*DeleteSize/1000000)+" MB. Most users never need it so this should be safe to do."
		if(V_flag)
			//IgorInfo
			KillDataFolder/Z root:raw
			if(V_Flag!=0)
				DoAlert/T="Error message" 0, "Raw data folder could not be deleted. Likely data from it are used in some graph or table. Close those graphs and tables and try again." 
			else
				print "Deleted raw data folder from this experiment to shrink it down"
			endif
		endif
	else
		print "Raw data folder does not exist, it therefore cannot be deleted. Likely you already deleted the raw data folder."
	endif
end
//***********************************************************
//***********************************************************
//***********************************************************
Function IN3_UpdatePanelVersionNumber(panelName, CurentProcVersion)
	string panelName
	variable CurentProcVersion
	DoWIndow $panelName
	if(V_Flag)
		GetWindow $(panelName), note
		SetWindow $(panelName), note=S_value+";"+"IndraProcVersion:"+num2str(CurentProcVersion)+";"
		IN2G_AddResizeInformationToPanel(panelName)
//		IN2G_PanelAppendSizeRecordNote(panelName)
//		SetWindow $panelName,hook(ResizePanelControls)=IN2G_PanelResizePanelSize
//		IN2G_ResetPanelSize(panelName,1)		
//		STRUCT WMWinHookStruct s
//		s.eventcode=6
//		s.winName=panelName
//		IN2G_PanelResizePanelSize(s)
	endif
end
//***********************************************************
////***********************************************************

Function IN2_OpenReadme()
	DoWIndow IndraReadme
	if(V_Flag)
		DoWIndow/F IndraReadme
	else
		string PathToReadMe= RemoveListItem(ItemsInList(FunctionPath("IN2_OpenReadme"),":")-1, FunctionPath("IN2_OpenReadme"), ":")
		PathToReadMe = PathToReadMe+"Readme.txt"
		OpenNotebook /K=1 /R /N=IndraReadme /ENCG=3 /W=(20,20,720,600) /Z PathToReadMe
	endif
end


//Function IN3_PanelAppendSizeRecordNote(panelName)
//	string panelName
//	string PanelRecord=""
//	//find size of the panel
//	GetWindow $panelName wsizeDC 
//	PanelRecord+="PanelLeft:"+num2str(V_left)+";PanelWidth:"+num2str(V_right-V_left)+";PanelTop:"+num2str(V_top)+";PanelHeight:"+num2str(V_bottom-V_top)+";"	
//	//GetDefaultFont($panelName )
//	//PanelRecord+="PanelLeft:"+num2str(V_left)+";PanelWidth:"+num2str(V_right-V_left)+";PanelTop:"+num2str(V_top)+";PanelHeight:"+num2str(V_bottom-V_top)+";"	
//	Button ResizeButton title=" \\W532",size={18,18}, win=$panelName, pos={(V_right-V_left-18),(V_bottom-V_top-18)}, disable=2
//	GetWindow $panelName, note
//	string ExistingNote=S_Value
//	string controlslist = ControlNameList("", ";")
//	variable i
//	string ControlsRecords=""
//	string TmpNm=""
//	For(i=0;i<ItemsInList(controlslist, ";");i+=1)
//		TmpNm = StringFromList(i, controlslist, ";")
//		ControlInfo $(TmpNm)
//		//V_Height, V_Width, V_top, V_left
//		ControlsRecords+=TmpNm+"Left:"+num2str(V_left)+";"+TmpNm+"Width:"+num2str(V_width)+";"+TmpNm+"Top:"+num2str(V_top)+";"+TmpNm+"Height:"+num2str(V_Height)+";"
//		//special cases...
//		if(abs(V_Flag)==5||abs(V_Flag)==3)		//SetVariable
//			ControlsRecords+=TmpNm+"bodyWidth:"+StringByKey("bodyWidth", S_recreation, "=",",")+";"
//		endif
//	endfor
//	SetWindow $panelName, note=ExistingNote+";"+PanelRecord+ControlsRecords
//	//print ExistingNote+";"+PanelRecord+ControlsRecords
//end
////***********************************************************
//***********************************************************

//Function IN3_PanelResizePanelSize(s)
//	STRUCT WMWinHookStruct &s
//		//add to the end of panel forming macro these two lines:
//		//	IR1_PanelAppendSizeRecordNote()
//		//	SetWindow kwTopWin,hook(ResizePanelControls)=IR1_PanelResizeFontSize
//		//for font scaling in Titlebox use "\ZrnnnText is here" - scales font by nnn%. Do nto use fixed font then. 
//	if ( s.eventCode == 6 && !(WinType(s.winName)==5))	// resized
//		GetWindow $(s.winName), note
//		//string OrigInfo=StringByKey("PanelSize", S_Value, "=", ";")
//		string OrigInfo=S_Value
//		GetWindow $s.winName wsizeDC
//		Variable left = V_left
//		Variable right = V_right
//		Variable top = V_top
//		Variable bottom = V_bottom
//		variable horScale, verScale, OriginalWidth, OriginalHeight, CurHeight, CurWidth
//		OriginalWidth = NumberByKey("PanelWidth", OrigInfo, ":", ";")
//		OriginalHeight = NumberByKey("PanelHeight", OrigInfo, ":", ";")
//		CurWidth=(right-left) 
//		CurHeight = (bottom-top)
//		if(CurWidth<OriginalWidth && CurHeight<OriginalHeight)
//			MoveWindow left, top, left+OriginalWidth, top+OriginalHeight
//			horScale = 1
//			verScale = 1
//		elseif(CurWidth<OriginalWidth && CurHeight>OriginalHeight)		
//			MoveWindow left, top, left+OriginalWidth, bottom
//			horScale = 1
//			verScale = CurHeight / (OriginalHeight)	
//		elseif(CurWidth>OriginalWidth && CurHeight<OriginalHeight)
//			MoveWindow left, top, right, top+OriginalHeight
//			verScale = 1 
//			horScale = curWidth/OriginalWidth
//		else
//			verScale = CurHeight /OriginalHeight
//			horScale = curWidth/OriginalWidth
//		endif
//		variable scale= min(horScale, verScale )
//		string FontName = IN2G_LkUpDfltStr("DefaultFontType")  //returns font with ' in the beggining and end as needed for Graph formating
//		FontName = ReplaceString("'", FontName, "") 				//remove the thing....
//		FontName = StringFromList(0,GrepList(FontList(";"), FontName))		//check that similar font exists, if more found use the first one. 
//		if(strlen(FontName)<3)											//if we did tno find the font, use default. 
//			FontName="_IgorSmall"
//		endif
//		//this needs to be fixed and will be more difficult. 
//		DefaultGUIFont /W=$(s.winName) button= {FontName, ceil(scale*str2num(IN2G_LkUpDfltVar("defaultFontSize"))), 0 }
//		DefaultGUIFont /W=$(s.winName) checkbox= {FontName, ceil(scale*str2num(IN2G_LkUpDfltVar("defaultFontSize"))), 0 }
//		DefaultGUIFont /W=$(s.winName) tabcontrol= {FontName, ceil(scale*str2num(IN2G_LkUpDfltVar("defaultFontSize"))), 0 }
//		DefaultGUIFont /W=$(s.winName) popup= {FontName, ceil(scale*str2num(IN2G_LkUpDfltVar("defaultFontSize"))), 0 }
//		DefaultGUIFont /W=$(s.winName) all= {FontName, ceil(scale*str2num(IN2G_LkUpDfltVar("defaultFontSize"))), 0 }
//		string controlslist = ControlNameList(s.winName, ";")
//		variable i, OrigCntrlV_left, OrigCntrlV_top, NewCntrolV_left, NewCntrlV_top
//		variable OrigWidth, OrigHeight, NewWidth, NewHeight, OrigBodyWidth
//		string ControlsRecords=""
//		string TmpNm=""
//		For(i=0;i<ItemsInList(controlslist, ";");i+=1)
//			TmpNm = StringFromList(i, controlslist, ";")			
//			OrigCntrlV_left=NumberByKey(TmpNm+"Left", OrigInfo, ":", ";")
//			OrigCntrlV_top=NumberByKey(TmpNm+"Top", OrigInfo, ":", ";")
//			OrigWidth=NumberByKey(TmpNm+"Width", OrigInfo, ":", ";")
//			OrigHeight=NumberByKey(TmpNm+"Height", OrigInfo, ":", ";")
//			NewCntrolV_left=OrigCntrlV_left* horScale 
//			NewCntrlV_top = OrigCntrlV_top * verScale
//			NewWidth = OrigWidth * horScale
//			NewHeight = OrigHeight * verScale
//			ModifyControl $(TmpNm)  pos = {NewCntrolV_left,NewCntrlV_top}, size={NewWidth,NewHeight}
//			//special cases...
//			ControlInfo $(TmpNm)
//			if(abs(V_Flag)==5 ||abs(V_Flag)==3)		//SetVariable
//				OrigBodyWidth=NumberByKey(TmpNm+"bodyWidth", OrigInfo, ":", ";")
//				if(numtype(OrigBodyWidth)==0)
//					ModifyControl $(TmpNm)  bodywidth =horScale*OrigBodyWidth
//				endif
//			endif
//		endfor
//
//	endif
//end
//***********************************************************
//***********************************************************
//***********************************************************

Function IN3_CheckPanelVersionNumber(panelName, CurentProcVersion)
	string panelName
	variable CurentProcVersion

	DoWIndow $panelName
	if(V_Flag)	
		GetWindow $(panelName), note
		if(stringmatch(stringbyKey("IndraProcVersion",S_value),num2str(CurentProcVersion))) //matches
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
//**********************************************************************************************************
//this is added into selection in Marquee.
//if run, sets limits to marquee selection and switches into manual mode for axis range

Function RemovePointsWithMarquee()
	//this will zoom graph and set limits to the appropriate numbers
	GetMarquee left, bottom
	if(!(stringmatch(S_MarqueeWin"RcurvePlotGraph") || stringmatch(S_MarqueeWin"RcurvePlotGraph#PeakCenter")) )
		return 0	
	endif
	variable StartPntX, EndPntX
	variable isBlank = 1
	variable StartPnt, EndPnt
	variable i

	if(stringmatch(S_MarqueeWin"RcurvePlotGraph"))
		CheckDisplayed /W=RcurvePlotGraph root:Packages:Indra3:SMR_Int
		if(V_Flag>0)
			isBlank = 0
			Wave IntWv=root:Packages:Indra3:SMR_Int
			Wave QWv  =root:Packages:Indra3:SMR_Qvec
		endif
		CheckDisplayed /W=RcurvePlotGraph root:Packages:Indra3:DSM_Int
		if(V_Flag>0)
			isBlank = 0
			Wave IntWv=root:Packages:Indra3:DSM_Int
			Wave QWv  =root:Packages:Indra3:DSM_Qvec
		endif
		if(isBlank)
			Wave IntWv=root:Packages:Indra3:R_Int
			Wave QWv  =root:Packages:Indra3:R_Qvec
		endif 
		if(isBlank) 
			getmarquee/W=RcurvePlotGraph left, bottom
		else
			getmarquee/W=RcurvePlotGraph right, bottom
		endif
		FindLevel/Q QWv, V_left 
		if(!V_Flag)
			StartPntX = floor(V_levelX)
		else
			StartPntX = 0
		endif
		FindLevel/Q QWv, V_right 
		if(!V_Flag)
			EndPntX = ceil(V_levelX)
		else
			EndPntX = numpnts(QWv)-1
		endif
		For(i=StartPntX;i<=EndPntX;i+=1)
			if(IntWv[i]<V_top && IntWv[i]>V_bottom)
				IntWv[i]=NaN
			endif
		endfor
	elseif(stringmatch(S_MarqueeWin"RcurvePlotGraph#PeakCenter"))
		CheckDisplayed /W=RcurvePlotGraph#PeakCenter root:Packages:Indra3:PD_Intensity
		if(V_Flag)
			Wave USAXS_PD = root:Packages:Indra3:USAXS_PD
			Wave PD_Intensity = root:Packages:Indra3:PD_Intensity
			Wave ARencoder = root:Packages:Indra3:AR_encoder
			getmarquee/W=RcurvePlotGraph#PeakCenter left, bottom
			FindLevel/Q ARencoder, V_left 
			StartPntX = floor(V_levelX)
			FindLevel/Q ARencoder, V_right 
			EndPntX = ceil(V_levelX)
			For(i=StartPntX;i<=EndPntX;i+=1)
				if(PD_Intensity[i]<V_top && PD_Intensity[i]>V_bottom)
					USAXS_PD[i]=NaN
				endif
			endfor
		endif
		IN3_RecalculateData(0)
		IN3_DesmearData()
		IN3_DisplayRightSubwindow()
	endif
	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//Function IN2D_DesmearSlowMainRedir()
//
//	//Lets be little bit more proactive. 
//	//if Irena is loaded and desmearing exists, just start the Irena desmearing.
//	
//	if(strlen(FunctionInfo("IR1B_DesmearingMain"))>10)
//		//exists, we can call it...
//		Execute("IR1B_DesmearingMain()")
//	elseif(strlen(MacroList("LoadIR1Modeling", ";", "kind:1" ))>5)			
//			//desmearing not present, but let's see if we can load Irena macros. May be it is present on this computer...
//			//present, so we can load the macros and then load desmearing
//		Execute("LoadIR1Modeling()")
//		Execute/P("IR1B_DesmearingMain()")
//	else
//		DoAlert 0, "Desmearing routine is now part of Irena package (menu SAS). Download from www.uni.aps.anl.gov/~ilavsky/irena.html. Load from Macros menu." 
//	endif
//end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IN2A_OpenIndraPage()
	DoAlert 1,"Your web browser will Indra home page. OK?"
	if(V_flag==1)
		BrowseURL "https://usaxs.xray.aps.anl.gov/software/indra"
	endif
End

//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN2_AboutPanel()
	PauseUpdate    		// building window...
	NewPanel/K=1 /W=(173.25,101.75,500,302) as "About_Indra_2_Macros"
	DoWindow/C About_Indra_2_Macros
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 1,textrgb= (16384,28160,65280)
	DrawText 10,37,"Indra 2 macros for Igor Pro 8.03+"
	SetDrawEnv fsize= 16,textrgb= (16384,28160,65280)
	DrawText 52,64,"@ Jan Ilavsky, 2021"
	DrawText 49,103,"release "+num2str(CurrentIndraVersionNumber)
	DrawText 11,136,"To get help please contact: ilavsky@aps.anl.gov"
	DrawText 11,156,"https://usaxs.xray.aps.anl.gov/"
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN2A_CleanupAllWIndows()
	//this routine kills all open windows of this package at the start of any routine...
	KillWIndow/Z LinLinBeamCenterPlot					//cleanup old windows of Create R wave routine...
 	KillWIndow/Z IN2A_UPDControlPanel
 	KillWIndow/Z LogLogRPlot
 	KillWIndow/Z ASBLinLinPlot
 	KillWIndow/Z MSAXSCorrection
 	KillWIndow/Z IN2A_MSAXSPanel
 	KillWIndow/Z TrimGraph
 	KillWIndow/Z SmearingProcess
 	KillWIndow/Z SmearingProcess
 	KillWIndow/Z FinalDesmeared
 end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
////*******************Main body*********************
//Function IN2A_CreateRWave()							//create R wave 
//
//	IN2G_UniversalFolderScan("root:USAXS:", 5, "IN2G_CheckTheFolderName()")  //here we fix the folder names/sample names in wave notes if necessary
//		
//	if (!DataFolderExists("root:USAXS:"))
//		Abort "No USAXS data folder, create USAXS data first"
//	endif
//	string FldrName=IN2A_SelectDtaForRWave()		//here we select the folder where we want to work
//
//	IN2A_CleanupAllWIndows()						//cleanup all open windows from Indra 2
//	
//	IN2A_initializePDParameters(FldrName)				//create global strrings if needed
//	
//	IN2A_SetPDParameters(FldrName)					//here we setup PD parameters
//	
//	IN2A_CleanWavesForSPECtroubles()				//clean the waves with USAXS data for Spec timing troubles, if needed
//
//	IN2A_GetMeasParam()							//this gets and sets the parameters (SDD, PD size)
//	
//	Execute("IN2A_UPDControlPanel()")				//create the control panel for PD control
//	
//	IN2A_CalculateRWave(FldrName,1)					//this calculates the R wave, and save function is called from the panel when dark current are changed
//		
//	IN2A_PlotToGetBeamCenter()						//creates the plot lin-lin to generate 
//
//	//the log log plot is called from above function, could not be done otherwise... Sorry...
//	
//end
//
//
////*********************Create R wave functions *********************************************
//Function/T IN2A_SelectDtaForRWave()					//selects the USAXS data folder in which we want to create R wave
//	string FldrName
//	Prompt FldrName, "Select Folder to work in", popup, IN2A_NextRDataToEvaluate()+";---;"+IN2_FindFolderWithScanTypes("root:USAXS:", 5, "*uascan", 1)
//	//the *uasczn should catch both uascans and sbuascans...
//	DoPrompt "Select Folder to create R wave in", FldrName		//get the folder 
//		if (V_Flag)
//			Abort 
//		endif	
//	if (cmpstr("---",FldrName)==0)
//		Abort  "Wrong folder selected (\"---\")"
//	endif
//	setDataFolder $FldrName							//go there
//
//	IN2G_AppendAnyText("\r*********************************************************************\r")
//	IN2G_AppendAnyText("R wave evaluation procedure started for :"+FldrName)
//
//	SVAR/Z WhereIam=root:Packages:Indra3:CurrentRFolder	//global string for current folder info
//	if (!SVAR_Exists(WhereIam))
//		string/g root:Packages:Indra3:CurrentRFolder		//create if nexessary
//		SVAR WhereIam=root:Packages:Indra3:CurrentRFolder
//	endif
//
//	WhereIam=GetDataFolder(1)							//put the ino there
//	return WhereIam
//end
//
//Function/T IN2A_NextRDataToEvaluate()					//this returns next USAXS sample in order to evaluate 
//
//	string ListOfData=IN2_FindFolderWithScanTypes("root:USAXS:", 5, "*uascan", 1)
//	SVAR/Z LastR=root:Packages:Indra3:CurrentRFolder	//global string for current folder info
//	if (!SVAR_Exists(LastR))
//		NewDataFolder/O root:Packages
//		NewDataFolder/O root:Packages:Indra3
//		string/g root:Packages:Indra3:CurrentRFolder		//create if nexessary
//		SVAR LastR=root:Packages:Indra3:CurrentRFolder
//		LastR=""
//	endif
//	variable start=FindListItem(lastR, ListOfData)
//	if (start==-1)
//		return StringFromList(0,ListOfdata)
//	else
//		ListOfdata=ListOfData[start,inf]
//		return StringFromList(1,ListOfdata)
//	endif
//end
//
//Function IN2A_SetPDParameters(FldrName)	 			//setup PD parameters and get control panel
//	string FldrName
//	
//	setDataFolder $FldrName							//just make sure we are where we should be
//	
//	SVAR UPD=UPDParameters						//define the global holding places
//	NVAR UPD_DK1=root:Packages:Indra3:UPD_DK1
//	NVAR UPD_DK2=root:Packages:Indra3:UPD_DK2
//	NVAR UPD_DK3=root:Packages:Indra3:UPD_DK3
//	NVAR UPD_DK4=root:Packages:Indra3:UPD_DK4
//	NVAR UPD_DK5=root:Packages:Indra3:UPD_DK5
//	NVAR UPD_G1=root:Packages:Indra3:UPD_G1
//	NVAR UPD_G2=root:Packages:Indra3:UPD_G2
//	NVAR UPD_G3=root:Packages:Indra3:UPD_G3
//	NVAR UPD_G4=root:Packages:Indra3:UPD_G4
//	NVAR UPD_G5=root:Packages:Indra3:UPD_G5
//	NVAR UPD_Vfc=root:Packages:Indra3:UPD_Vfc
//	NVAR UPD_DK1Err=root:Packages:Indra3:UPD_DK1Err
//	NVAR UPD_DK2Err=root:Packages:Indra3:UPD_DK2Err
//	NVAR UPD_DK3Err=root:Packages:Indra3:UPD_DK3Err
//	NVAR UPD_DK4Err=root:Packages:Indra3:UPD_DK4Err
//	NVAR UPD_DK5Err=root:Packages:Indra3:UPD_DK5Err
//
//	UPD_Vfc =  NumberByKey("Vfc", UPD,"=")						//put the numbers in there
//	UPD_DK1=NumberByKey("Bkg1", UPD,"=")
//	UPD_G1=NumberByKey("Gain1", UPD,"=")
//	UPD_DK2=NumberByKey("Bkg2", UPD,"=")
//	UPD_G2=NumberByKey("Gain2", UPD,"=")
//	UPD_DK3=NumberByKey("Bkg3", UPD,"=")
//	UPD_G3=NumberByKey("Gain3", UPD,"=")
//	UPD_DK4=NumberByKey("Bkg4", UPD,"=")
//	UPD_G4=NumberByKey("Gain4", UPD,"=")
//	UPD_DK5=NumberByKey("Bkg5", UPD,"=")
//	UPD_G5=NumberByKey("Gain5", UPD,"=")
//	UPD_DK1Err=NumberByKey("Bkg1Err", UPD,"=")
//	UPD_DK2Err=NumberByKey("Bkg2Err", UPD,"=")
//	UPD_DK3Err=NumberByKey("Bkg3Err", UPD,"=")
//	UPD_DK4Err=NumberByKey("Bkg4Err", UPD,"=")
//	UPD_DK5Err=NumberByKey("Bkg5Err", UPD,"=")
//	if (UPD_DK1Err<=0)
//		UPD_DK1Err=1
//	endif
//	if (UPD_DK2Err<=0)
//		UPD_DK2Err=1
//	endif
//	if (UPD_DK3Err<=0)
//		UPD_DK3Err=1
//	endif
//	if (UPD_DK4Err<=0)
//		UPD_DK4Err=1
//	endif
//	if (UPD_DK5Err<=0)
//		UPD_DK5Err=1
//	endif
//
//end
//
//Function IN2A_initializePDParameters(FldrName)	 			//setup PD parameters and get control panel
//	string FldrName
//	
//	setDataFolder $FldrName							//just make sure we are where we should be
//	
//	SVAR UPD=UPDParameters						//define the global holding places
//	NVAR/Z UPD_DK1=root:Packages:Indra3:UPD_DK1
//	if (!NVAR_Exists(UPD_DK1))
//		variable/g root:Packages:Indra3:UPD_DK1
//	endif
//	NVAR/Z UPD_DK2=root:Packages:Indra3:UPD_DK2
//	if (!NVAR_Exists(UPD_DK2))
//		variable/g root:Packages:Indra3:UPD_DK2
//	endif
//	NVAR/Z UPD_DK3=root:Packages:Indra3:UPD_DK3
//	if (!NVAR_Exists(UPD_DK3))
//		variable/g root:Packages:Indra3:UPD_DK3
//	endif
//	NVAR/Z UPD_DK4=root:Packages:Indra3:UPD_DK4
//	if (!NVAR_Exists(UPD_DK4))
//		variable/g root:Packages:Indra3:UPD_DK4
//	endif
//	NVAR/Z UPD_DK5=root:Packages:Indra3:UPD_DK5
//	if (!NVAR_Exists(UPD_DK5))
//		variable/g root:Packages:Indra3:UPD_DK5
//	endif
//	NVAR/Z UPD_DK1Err=root:Packages:Indra3:UPD_DK1Err
//	if (!NVAR_Exists(UPD_DK1Err))
//		variable/g root:Packages:Indra3:UPD_DK1Err
//	endif
//	NVAR/Z UPD_DK2Err=root:Packages:Indra3:UPD_DK2Err
//	if (!NVAR_Exists(UPD_DK2Err))
//		variable/g root:Packages:Indra3:UPD_DK2Err
//	endif
//	NVAR/Z UPD_DK3Err=root:Packages:Indra3:UPD_DK3Err
//	if (!NVAR_Exists(UPD_DK3Err))
//		variable/g root:Packages:Indra3:UPD_DK3Err
//	endif
//	NVAR/Z UPD_DK4Err=root:Packages:Indra3:UPD_DK4Err
//	if (!NVAR_Exists(UPD_DK4Err))
//		variable/g root:Packages:Indra3:UPD_DK4Err
//	endif
//	NVAR/Z UPD_DK5Err=root:Packages:Indra3:UPD_DK5Err
//	if (!NVAR_Exists(UPD_DK5Err))
//		variable/g root:Packages:Indra3:UPD_DK5Err
//	endif
//	
//	NVAR/Z UPD_G1=root:Packages:Indra3:UPD_G1
//	if (!NVAR_Exists(UPD_G1))
//		variable/g root:Packages:Indra3:UPD_G1
//	endif
//	NVAR/Z UPD_G2=root:Packages:Indra3:UPD_G2
//	if (!NVAR_Exists(UPD_G2))
//		variable/g root:Packages:Indra3:UPD_G2
//	endif
//	NVAR/Z UPD_G3=root:Packages:Indra3:UPD_G3
//	if (!NVAR_Exists(UPD_G3))
//		variable/g root:Packages:Indra3:UPD_G3
//	endif
//	NVAR/Z UPD_G4=root:Packages:Indra3:UPD_G4
//	if (!NVAR_Exists(UPD_G4))
//		variable/g root:Packages:Indra3:UPD_G4
//	endif
//	NVAR/Z UPD_G5=root:Packages:Indra3:UPD_G5
//	if (!NVAR_Exists(UPD_G5))
//		variable/g root:Packages:Indra3:UPD_G5
//	endif
//
//	NVAR/Z UPD_Vfc=root:Packages:Indra3:UPD_Vfc
//	if (!NVAR_Exists(UPD_Vfc))
//		variable/g root:Packages:Indra3:UPD_Vfc
//	endif
//end
//
//
//Window IN2A_UPDControlPanel() : Panel						//UPD control panel
//	PauseUpdate    		// building window...
//	NewPanel /K=1/W=(558,50,880,427.25) as "UPD control"
//	SetDrawLayer UserBack
//	SetDrawEnv fsize= 16,fstyle= 5,textrgb= (65280,0,0)
//	DrawText 41,20,"UPD control panel for:"
//	SetVariable VtoF,pos={29,59},size={200,22},proc=IN2A_PopupUPDFnct,title="UPD V to f factor :"
//	SetVariable VtoF,font="Times New Roman",fSize=14,format="%3.1e"
//	SetVariable VtoF,limits={0,Inf,0},value= root:Packages:Indra3:UPD_Vfc
//	SetVariable Gain1,pos={29,85},size={200,22},proc=IN2A_PopupUPDFnct,title="Gain 1 :"
//	SetVariable Gain1,font="Times New Roman",fSize=14,format="%3.1e",labelBack=(65280,0,0) 
//	SetVariable Gain1,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G1
//	SetVariable Gain2,pos={29,113},size={200,22},proc=IN2A_PopupUPDFnct,title="Gain 2 :"
//	SetVariable Gain2,font="Times New Roman",fSize=14,format="%3.1e",labelBack=(0,52224,0)
//	SetVariable Gain2,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G2
//	SetVariable Gain3,pos={29,140},size={200,22},proc=IN2A_PopupUPDFnct,title="Gain 3 :"
//	SetVariable Gain3,font="Times New Roman",fSize=14,format="%3.1e",labelBack=(0,0,65280)
//	SetVariable Gain3,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G3
//	SetVariable Gain4,pos={29,164},size={200,22},proc=IN2A_PopupUPDFnct,title="Gain 4 :"
//	SetVariable Gain4,font="Times New Roman",fSize=14,format="%3.1e",labelBack=(65280,35512,15384)
//	SetVariable Gain4,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G4
//	SetVariable Gain5,pos={29,190},size={200,22},proc=IN2A_PopupUPDFnct,title="Gain 5 :"
//	SetVariable Gain5,font="Times New Roman",fSize=14,format="%3.1e",labelBack=(29696,4096,44800)
//	SetVariable Gain5,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G5
//	SetVariable Bkg1,pos={20,230},size={200,22},proc=IN2A_PopupUPDFnct,title="Background 1"
//	SetVariable Bkg1,font="Times New Roman",fSize=14,format="%g", labelBack=(65280,0,0)
//	SetVariable Bkg1,limits={0,Inf,root:Packages:Indra3:UPD_DK1Err},value= root:Packages:Indra3:UPD_DK1
//	SetVariable Bkg2,pos={20,259},size={200,22},proc=IN2A_PopupUPDFnct,title="Background 2"
//	SetVariable Bkg2,font="Times New Roman",fSize=14,format="%g",labelBack=(0,52224,0)
//	SetVariable Bkg2,limits={0,Inf,root:Packages:Indra3:UPD_DK2Err},value= root:Packages:Indra3:UPD_DK2
//	SetVariable Bkg3,pos={20,288},size={200,22},proc=IN2A_PopupUPDFnct,title="Background 3"
//	SetVariable Bkg3,font="Times New Roman",fSize=14,format="%g",labelBack=(0,0,65280)
//	SetVariable Bkg3,limits={0,Inf,root:Packages:Indra3:UPD_DK3Err},value= root:Packages:Indra3:UPD_DK3
//	SetVariable Bkg4,pos={20,316},size={200,22},proc=IN2A_PopupUPDFnct,title="Background 4"
//	SetVariable Bkg4,font="Times New Roman",fSize=14,format="%g",labelBack=(65280,35512,15384)
//	SetVariable Bkg4,limits={0,Inf,root:Packages:Indra3:UPD_DK4Err},value= root:Packages:Indra3:UPD_DK4
//	SetVariable Bkg5,pos={20,344},size={200,22},proc=IN2A_PopupUPDFnct,title="Background 5"
//	SetVariable Bkg5,font="Times New Roman",fSize=14,format="%g",labelBack=(29696,4096,44800)
//	SetVariable Bkg5,limits={0,Inf,root:Packages:Indra3:UPD_DK5Err},value= root:Packages:Indra3:UPD_DK5
//	SetVariable RFolder,pos={12,27},size={250,18},title=" ",font="Times New Roman"
//	SetVariable RFolder,limits={-Inf,Inf,0},value= root:Packages:Indra3:CurrentRFolder,noedit=1
//	SetVariable Bkg1Err,pos={225,230},size={90,22},title="Err"
//	SetVariable Bkg1Err,font="Times New Roman",fSize=14,format="%2.2g", labelBack=(65280,0,0)
//	SetVariable Bkg1Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK1Err,noedit=1
//	SetVariable Bkg2Err,pos={225,259},size={90,22},title="Err"
//	SetVariable Bkg2Err,font="Times New Roman",fSize=14,format="%2.2g", labelBack=(0,52224,0)
//	SetVariable Bkg2Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK2Err,noedit=1
//	SetVariable Bkg3Err,pos={225,288},size={90,22},title="Err"
//	SetVariable Bkg3Err,font="Times New Roman",fSize=14,format="%2.2g", labelBack=(0,0,65280)
//	SetVariable Bkg3Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK3Err,noedit=1
//	SetVariable Bkg4Err,pos={225,316},size={90,22},title="Err"
//	SetVariable Bkg4Err,font="Times New Roman",fSize=14,format="%2.2g", labelBack=(65280,35512,15384)
//	SetVariable Bkg4Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK4Err,noedit=1
//	SetVariable Bkg5Err,pos={225,344},size={90,22},title="Err"
//	SetVariable Bkg5Err,font="Times New Roman",fSize=14,format="%2.2g", labelBack=(29696,4096,44800)
//	SetVariable Bkg5Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK5Err,noedit=1
//
//EndMacro
//
//
//Function IN2A_PopupUPDFnct(ctrlName,varNum,varStr,varName) : SetVariableControl
//	String ctrlName
//	Variable varNum
//	String varStr
//	String varName
//
//	SVAR PathToSample=root:Packages:Indra3:CurrentRFolder
//	string PathToUPDPar=PathToSample+"UPDParameters"
//	SVAR UPDList=$PathToUPDPar
//	
//	if (!cmpstr(ctrlName,"VtoF"))						//Changing V to F
//		UPDList=ReplaceNumberByKey("Vtof",UPDList, varNum,"=")
//		UPDList=ReplaceNumberByKey("Vfc",UPDList, varNum,"=")
//	endif
//	if (!cmpstr(ctrlName,"Gain1"))						//Changing Gain1
//		UPDList=ReplaceNumberByKey("Gain1",UPDList, varNum,"=")
//	endif
//	if (!cmpstr(ctrlName,"Gain2"))						//Changing Gain2
//		UPDList=ReplaceNumberByKey("Gain2",UPDList, varNum,"=")
//	endif
//	if (!cmpstr(ctrlName,"Gain3"))						//Changing gain3
//		UPDList=ReplaceNumberByKey("Gain3",UPDList, varNum,"=")
//	endif
//	if (!cmpstr(ctrlName,"Gain4"))						//Changing Gain4
//		UPDList=ReplaceNumberByKey("Gain4",UPDList, varNum,"=")
//	endif
//	if (!cmpstr(ctrlName,"Gain5"))						//Changing Gain5
//		UPDList=ReplaceNumberByKey("Gain5",UPDList, varNum,"=")
//	endif
//	if (!cmpstr(ctrlName,"Bkg1"))						//Changing Bkg 1
//		UPDList=ReplaceNumberByKey("Bkg1",UPDList, varNum,"=")
//	endif
//	if (!cmpstr(ctrlName,"Bkg2"))						//Changing Bkg 2
//		UPDList=ReplaceNumberByKey("Bkg2",UPDList, varNum,"=")
//	endif
//	if (!cmpstr(ctrlName,"Bkg3"))						//Changing Bkg 3
//		UPDList=ReplaceNumberByKey("Bkg3",UPDList, varNum,"=")
//	endif
//	if (!cmpstr(ctrlName,"Bkg4"))						//Changing Bkg 4
//		UPDList=ReplaceNumberByKey("Bkg4",UPDList, varNum,"=")
//	endif
//	if (!cmpstr(ctrlName,"Bkg5"))						//Changing Bkg 5
//		UPDList=ReplaceNumberByKey("Bkg5",UPDList, varNum,"=")
//	endif
//
//
//	IN2A_CalculateRWave(PathToSample,0)			//and here we recalcualte the R wave
//End
//
//
//Function IN2A_CleanWavesForSPECtroubles()		//this function cleans USAXS waves for Spec timing proublems, if needed
//
//		Wave USAXS_PD
//		Wave monitor
//		Wave AR_encoder
//		Wave MeasTime
//		Wave Pd_range
//				
//		IN2A_SetZerosInWaveNan(USAXS_PD)
//		IN2A_SetZerosInWaveNan(Monitor)
//		IN2A_SetZerosInWaveNan(AR_encoder)
//		IN2A_SetZerosInWaveNan(MeasTime)
//		IN2A_SetZerosInWaveNan(Pd_range)
//		
//		//IN2G_RemoveNaNsFrom5Waves(USAXS_PD,Monitor,AR_encoder,MeasTime,Pd_range)
//end
//
//Function IN2A_SetZerosInWaveNan(wv)				//this will set all zeros in a wave to NaN, fix for Spec timeout
//	wave wv
//	
//	variable i=0,imax=numpnts(wv)
//	For(i=0;i<imax;i+=1)
//		if (wv[i]==0)
//			wv[i]=NaN
//		endif
//	endfor
//end	
//
//
//
//Function IN2A_CalculateRWave(df, askForFactor)				//Recalculate the R wave in folder df
//	string df
//	variable askForFactor
//	SetDataFolder $df						//make sure we are there
//	
//	Wave PD_Range							//these waves should be here
//	Wave USAXS_PD
//	Wave Monitor
//	Wave MeasTime
//		
//	Wave/Z PD_Intensity						//these waves may be new
//	Wave/Z PD_Error
//	if (!WaveExists(PD_Intensity))	
//		Duplicate/O PD_range, PD_Intensity, PD_Error
//		IN2G_AppendorReplaceWaveNote("PD_range","Wname","PD_range") 
//		IN2G_AppendorReplaceWaveNote("PD_Intensity","Wname","PD_Intensity") 
//		IN2G_AppendorReplaceWaveNote("PD_Error","Wname","PD_Error") 
//	endif
//	Redimension/D PD_Intensity				//intensity should be double precision
//	
//	SVAR UPDparameters					//now we need to get the dark currents and gains here
//	Make/O LocalParameters = {{1e5,1e7,1e9,99e9,1e11},{3000,3000,3000,3000,3000}}
//	
//	LocalParameters[0][0]=numberbykey ("Gain1", UPDparameters,"=")
//	LocalParameters[1][0]=numberbykey ("Gain2", UPDparameters,"=")
//	LocalParameters[2][0]=numberbykey ("Gain3", UPDparameters,"=")
//	LocalParameters[3][0]=numberbykey ("Gain4", UPDparameters,"=")
//	LocalParameters[4][0]=numberbykey ("Gain5", UPDparameters,"=")
//	LocalParameters[0][1]=numberbykey ("Bkg1", UPDparameters,"=")
//	LocalParameters[1][1]=numberbykey ("Bkg2", UPDparameters,"=")
//	LocalParameters[2][1]=numberbykey ("Bkg3", UPDparameters,"=")
//	LocalParameters[3][1]=numberbykey ("Bkg4", UPDparameters,"=")
//	LocalParameters[4][1]=numberbykey ("Bkg5", UPDparameters,"=")
//	
//	variable VtoFfactor=numberbykey ("Vfc", UPDparameters,"=")
//
//	Make/O ErrorParameters={1,1,1,1,1}			//background measured error
//	ErrorParameters[0]=numberbykey ("Bkg1Err", UPDparameters,"=")
//	ErrorParameters[1]=numberbykey ("Bkg2Err", UPDparameters,"=")
//	ErrorParameters[2]=numberbykey ("Bkg3Err", UPDparameters,"=")
//	ErrorParameters[3]=numberbykey ("Bkg4Err", UPDparameters,"=")
//	ErrorParameters[4]=numberbykey ("Bkg5Err", UPDparameters,"=")
//	variable ii
//	For(ii=0;ii<5;ii+=1)
//		if (numtype(ErrorParameters[ii])!=0)		//if the background error does not exist, we will replace it with 0...
//			ErrorParameters[ii]=0
//		endif
//	endfor
//	variable I0AmpDark=numberbykey ("I0AmpDark", UPDparameters,"=")
//	variable I0AmpGain=numberbykey ("I0AmpGain", UPDparameters,"=")
//	if(NumType(I0AmpGain)!=0 || I0AmpGain<0)
//		I0AmpGain=1
//	endif 
//	if(NumType(I0AmpDark)!=0 || I0AmpDark<0)
//		I0AmpDark=0
//	endif 
//	
////	PD_Intensity=(USAXS_PD - MeasTime*LocalParameters[pd_range-1][1])*(1/(VToFFactor*LocalParameters[pd_range-1][0])) /((Monitor-I0AmpDark*MeasTime)/I0AmpGain)
//	//old
//	Wave/Z I0_gain	
//	if(!WaveExists(I0_gain))		//old code, no changes...
//		PD_Intensity=(USAXS_PD - MeasTime*LocalParameters[pd_range-1][1])*(1/(VToFFactor*LocalParameters[pd_range-1][0])) /((Monitor-I0AmpDark*MeasTime)/I0AmpGain)
//	else
//		PD_Intensity=(USAXS_PD - MeasTime*LocalParameters[pd_range-1][1])*(1/(VToFFactor*LocalParameters[pd_range-1][0])) /((Monitor-I0AmpDark*MeasTime)/I0_gain)
//	endif	
//	//OK, another incarnation of the error calculations...
//	Duplicate/O PD_Error,  A
//	Duplicate/O/Free PD_Error, SigmaUSAXSPD, SigmaPDwDC, SigmaRwave, SigmaMonitor, ScaledMonitor
//	SigmaUSAXSPD=sqrt(USAXS_PD*(1+0.0001*USAXS_PD))		//this is our USAXS_PD error estimate, Poisson error + 1% of value
//	SigmaPDwDC=sqrt(SigmaUSAXSPD^2+(MeasTime*ErrorParameters[pd_range-1])^2)		//This should be measured error for background
//	SigmaPDwDC=SigmaPDwDC/(VToFFactor*LocalParameters[pd_range-1][0])
//	A=(USAXS_PD)/(VToFFactor*LocalParameters[pd_range-1][0])				//without dark current subtraction
//	SigmaMonitor=sqrt(Monitor)
//	ScaledMonitor = Monitor
//	SigmaRwave=sqrt((A^2*SigmaMonitor^4)+(SigmaPDwDC^2*ScaledMonitor^4)+((A^2+SigmaPDwDC^2)*ScaledMonitor^2*SigmaMonitor^2))
//	SigmaRwave=SigmaRwave/(ScaledMonitor*(ScaledMonitor^2-SigmaMonitor^2))
////	SigmaRwave*=I0AmpGain			//fix for use of I0 gain here, the numbers were too low due to scaling of PD by I0AmpGain
//	if(!WaveExists(I0_gain))		//old code, no changes...
//		SigmaRwave*=I0AmpGain			//fix for use of I0 gain here, the numbers were too low due to scaling of PD by I0AmpGain
//	else
//		SigmaRwave*=I0_gain
//	endif
//	
//	PD_error=SigmaRwave
//	KillWaves/Z LocalParameters , ErrorParameters
////	KillWaves TempPD_Int
////	KillWaves/Z SigmaUSAXSPD, SigmaPDwDC, SigmaMonitor, SigmaRwave, A
//end
//
//Function IN2A_PlotToGetBeamCenter()		//here we get the plot to get beam center
//
//	Wave Ar_encoder
//	Wave PD_Intensity
//	Wave PD_Error
//	SVAR SpecComment	
//	SVAR FolderName
//	//find range of points to display...
//	variable DisplayStartPoint, DisplayEndPoint
//	WaveStats/Q PD_Intensity															//statistics on Y wave
//	FindLevels/Q/P PD_Intensity, (0.1*V_max)			//find points for which the intensity drops to 10% of maximum...
//	Wave/Z W_FindLevels						//waves with results
//	if (!WaveExists(W_FindLevels))				//something went wrong and did not find crossings
//		DisplayStartPoint=V_maxloc-7
//		DisplayEndPoint=V_maxloc+7
//	else										//results exist, we can use them
////		NVAR V_LevelsFound					//number of results
//		if (V_LevelsFound==0)					//0 crossings found
//			DisplayStartPoint=V_maxloc-7
//			DisplayEndPoint=V_maxloc+7	//nothing found, strange, but let's display something...
//		endif
//		if (V_LevelsFound==1)					//1 crossings found
//			if (W_FindLevels[0]>V_maxloc)		//found only point above center
//				DisplayStartPoint=0
//				DisplayEndPoint=W_FindLevels[0]+1		//in that case, this should be the right ones...
//			else								//tis is hypothetical case, that found only point below center...
//				DisplayStartPoint=W_FindLevels[0]
//				DisplayEndPoint=V_maxloc+7		//in that case, this should be the right ones...
//			endif		
//		endif
//		if (V_LevelsFound>=2)					//at least 2 crossings found
//			DisplayStartPoint=W_FindLevels[0]
//			DisplayEndPoint=W_FindLevels[1]		//in that case, these should bethe right ones...
//		endif
//	endif
//	DisplayStartPoint=floor(DisplayStartPoint)-3
//	if(DisplayStartPoint<0)
//		DisplayStartPoint=0
//	endif 
//	DisplayEndPoint=ceil(DisplayEndPoint)+3
//	
//	    
//	PauseUpdate //*************************Graph section**********************************
//	//Display/k=1 /W=(0.3*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("height"),60*IN2G_ScreenWidthHeight("width"),70*IN2G_ScreenWidthHeight("height")) PD_Intensity vs ar_encoder as "Lin-lin plot of Int vs Ar encoder"
//	Display/k=1 /W=(0,0,IN2G_GetGraphWidthHeight("width"),IN2G_GetGraphWidthHeight("height")) PD_Intensity vs ar_encoder as "Lin-lin plot of Int vs Ar encoder"
//	DoWindow/C LinLinBeamCenterPlot
//		SetAxis bottom, ar_encoder[DisplayStartPoint], ar_encoder[DisplayEndPoint]
//		ErrorBars PD_Intensity Y,wave=(PD_Error,PD_Error)
//		Execute ("IN2G_BasicGraphStyle()")
////		Button AutoFitGaussOnPeak pos={130,10}, size={100,20}, title="1a. Auto Fit Gauss ", proc=IN2A_AutoFitGaussTop
//		Button FitGaussianOnPeak pos={130,10}, size={100,20}, title="1a. Fit Gaussian ", proc=IN2A_FitGaussTop
//		Button FitLorentzianOnPeak pos={130,35}, size={100,20}, title="1b. Fit Lorenzian ", proc=IN2A_FitLorenzianTop
//		Button ManualInput pos={130,60}, size={100,20}, title="1c. Manual Inpt.", proc=IN2A_GrazingAngleParam
//		Button ContinueThisSample pos={250,40}, size={100,25}, title="2. Continue", proc=IN2A_ContinueRWave
//		Button RemovePointR pos={10,100}, size={100,20}, title="Remove pnt w/csrA", proc=IN2G_RemovePointWithCursorA
//		Textbox/N=text0/S=3/F=0/X=10/Y=-8.00 "\Z10"+FolderName 	//specComment
//	ResumeUpdate   //*************************Graph section**********************************
//
//	ModifyGraph width=0, height=0
//	IN2G_AutoAlignGraphAndPanel()
//	FindLevels/Q PD_Intensity, 0.4*V_max						//finds fitting interval
//	if (V_LevelsFound==2)
//		Wave W_FindLevels
//		//check that we have at least 5 points...
//		if((W_FindLevels[1]-W_FindLevels[0])<6)
//			W_FindLevels[0]=W_FindLevels[0]-3
//			if(W_FindLevels[0]<0)
//				W_FindLevels[0]=0
//			endif
//			W_FindLevels[1]=W_FindLevels[1]+3
//		endif
//		cursor/P A, PD_Intensity, floor(W_FindLevels[0])
//		cursor/P B, PD_Intensity, ceil(W_FindLevels[1])
//	else
//		DoAlert 0, "Weird position for cursors found automatically, set cursors for fitting range manually, please"
//	endif
//	KillWaves/Z W_FindLevels
//	//let's now create wave which would show the full fit over the whole screen
//	Make/O/N=200 PeakFitWave
//	Duplicate/O  PD_Intensity, FitResiduals
//	SetScale/I x ar_encoder[DisplayStartPoint], ar_encoder[DisplayEndPoint],"", PeakFitWave
//	PeakFitWave=0 
//	FitResiduals=0
//	AppendToGraph /W=LinLinBeamCenterPlot PeakFitWave
////	AppendToGraph /R/W=LinLinBeamCenterPlot FitResiduals vs Ar_encoder
////	ModifyGraph marker(FitResiduals)=6,msize(FitResiduals)=4
////	ModifyGraph mode(FitResiduals)=3
////	ModifyGraph rgb(FitResiduals)=(52224,0,41728)
////	SetAxis/A/E=2 right
////	Label right "Residuals"
//	ModifyGraph lstyle(PeakFitWave)=3,rgb(PeakFitWave)=(0,0,65280)
//	
////	IN2A_AutoFitGaussTop("")		//this does not work, unluckily.... 
//	IN2A_FitGaussTop("")
//End
//
////******************** FitLorenzianOnTopMacro **************************************
//Function IN2A_FitLorenzianTop(ctrlname) : Buttoncontrol			// calls the Lorenzian fit
//	string ctrlname
// 
// 	Wave PD_Intensity
// 	Wave Ar_encoder
// 	Wave PD_error
//	GetWindow kwTopWin, wavelist							//creates wavelist
//	K0=0
//	CurveFit/Q/H="1000"  lor $WaveName("",0,1)(xcsr(A),xcsr(B))  /X=$WaveName("",0,2) /D /W=PD_error /I=1	//Lorenzian
//	print "Fitted Lorenzian between points  "+num2str(pcsr(A))+"   and    "+num2str(pcsr(B))+"    reached Chi-squared/numpoints     " +num2str(V_chisq/(pcsr(B)-pcsr(A)))
//	string ModifyWave
//	ModifyWave="fit_"+WaveName("",0,1)						//new wave with the lorenzian fit
//	Variable/G BeamCenter, MaximumIntensity, PeakWidth		//creates variables with results
//	Variable BeamCenterError, MaximumIntensityError, PeakWidthError
//	Wave W_coef
//	Wave W_sigma
//	Wave PeakFitWave
//	Wave FitResiduals
//	FitResiduals= ((W_coef[0]+W_coef[1]/((Ar_encoder[p]-W_coef[2])^2+W_coef[3]))-PD_Intensity[p])/PD_error[p]
//	FitResiduals[0,xcsr(A)-1]=NaN
//	FitResiduals[xcsr(B)+1,inf]=NaN
//	PeakFitWave= W_coef[0]+W_coef[1]/((x-W_coef[2])^2+W_coef[3])
//	BeamCenterError=W_sigma[2]
//	BeamCenter=W_coef[2]
//	MaximumIntensity=W_coef[1]/W_coef[3]
//	MaximumIntensityError=IN2G_ErrorsForDivision(W_coef[1],W_sigma[1],W_coef[3],W_sigma[3])
//	PeakWidth = 2*sqrt(W_coef[3])
//	//according to Andrew, the error here needs to be propagated through fractional error
//	//that is, error of sqrt(x), sigma(sx)=X*(sigma(X)/2*X)
//	PeakWidthError=PeakWidth*(W_sigma[3]/(2*W_coef[3]))
//	string BmCenterStr, BmCenterErrStr
//	Sprintf BmCenterStr, "%8.5f", BeamCenter
//	Sprintf BmCenterErrStr, "%8.5f", BeamCenterError
//	String Width="\Z12FWHM   "+num2str(PeakWidth*3600)+ " +/- "+num2str(PeakWidthError*3600)+"  arc-sec"
//	Width+="\rMax     "+num2str(MaximumIntensity)+" +/-  "+num2str(MaximumIntensityError)
//	Width+="\rBm Cntr   : "+BmCenterStr+" +/- "+ num2str(BeamCenterError)+"  deg."
//	Textbox/K/N=text1
//	Textbox/N=text1/S=0/B=2/F=0/A=RT/X=0.37/Y=-21.86 Width
//	ModifyGraph rgb($ModifyWave)=(0,15872,65280)
//	KillWaves/Z W_WaveList
//	IN2G_AppendNoteToAllWaves("PeakFitFunction","Lorenzian")
//	IN2G_AppendNoteToAllWaves("BeamCenter",num2str(BeamCenter))
//	IN2G_AppendNoteToAllWaves("MaximumIntensity",num2str(MaximumIntensity))
//	IN2G_AppendNoteToAllWaves("FWHM",num2str(sqrt(W_coef[3])*3600*2))
//	IN2G_AppendNoteToAllWaves("BeamCenterError",num2str(BeamCenterError))
//	IN2G_AppendNoteToAllWaves("MaximumIntensityError",num2str(MaximumIntensityError))
//	IN2G_AppendNoteToAllWaves("FWHM_Error",num2str(sqrt(W_sigma[3])*3600*2))
//End
//Function IN2A_AutoFitGaussTop(ctrlName) : Buttoncontrol			// calls the Gaussien fit
//	string ctrlname
//	
//	Wave PD_error
//	Wave Ar_encoder
//	Wave PD_Intensity
//	
//	Duplicate/O PD_Intensity, PD_Intensity_Loc
//	Duplicate/O Ar_encoder, Ar_encoder_Loc
//	IN2G_RemoveNaNsFrom2Waves(PD_Intensity_Loc,Ar_encoder_Loc)
//	//First find range fo data to use, let's try range of intensities above 10% of maximum.
//	variable startPoint, EndPoint
//	//first fined place with maximum and the maximum
//	wavestats/Q PD_intensity
//	variable PD_Max=V_max
//	variable PD_MaxPos = V_maxLoc
////	Duplicate/O/R=[0,PD_MaxPos] PD_Intensity, temWv
////	startPoint = binarySearch(temWv,PD_max/10)
//	Duplicate/O/R=[PD_MaxPos,inf] PD_Intensity_Loc, temWv
//	variable EndPointFraction = 25
//	EndPoint = binarySearch(temWv,PD_max/EndPointFraction)
//	killWaves/Z temWv
////	if(startPoint<1)
////		startPoint=1
////	endif
//	if(endPoint<1)
//		abort
//	endif
//	EndPoint= EndPoint + PD_MaxPos
//	if((EndPoint-PD_MaxPos)>PD_MaxPos)
//		EndPoint = 2 * PD_MaxPos
//	endif
//	
//	StartPoint =  PD_MaxPos - (EndPoint - PD_MaxPos) 
//	Duplicate/O PD_Intensity_Loc, AR_PD_Intensity
//	AR_PD_Intensity = Ar_encoder_Loc * PD_Intensity_Loc
//	Variable/G BeamCenter, MaximumIntensity, PeakWidth		//creates variables with results
//	BeamCenter = sum(AR_PD_Intensity, startPoint,EndPoint )/ sum(PD_Intensity_Loc, startPoint, EndPoint )	
//	AR_PD_Intensity = Ar_encoder_Loc^2 * PD_Intensity_Loc
//	variable sigma2 = (sum(AR_PD_Intensity, startPoint, EndPoint ) / sum(PD_Intensity_Loc, startPoint, EndPoint)) - BeamCenter^2
////	sigma2 = sigma2/(0.61)^2
////	variable sigma2 = (sum(AR_PD_Intensity, -inf, inf ) / sum(PD_Intensity, -inf, inf)) - BeamCenter^2
//	variable sigma = sqrt(sigma2)
////	PeakWidth = 2.35482 * sqrt(sigma2)		//gaussien distribution theory...
//	PeakWidth = 2.35482 * sqrt(sigma2)		//gaussien distribution theory...
//	variable startAR=Ar_encoder_Loc[endPoint]
//	variable endAR = Ar_encoder_Loc[startPoint]
//	MaximumIntensity = abs(areaXY(Ar_encoder_Loc, PD_Intensity_Loc,startAR, endAR)) /(sqrt(sigma2) * sqrt(2*pi))
//	Wave PeakFitWave
//	Make/O/N=100 fit_PD_intensity
//	SetScale/I x Ar_encoder_Loc[startPoint],Ar_encoder_Loc[EndPoint],"", fit_PD_intensity
//	fit_PD_intensity =  (MaximumIntensity) *exp(-0.5*( (x-BeamCenter) / sigma )^2)
//	CheckDisplayed /W=LinLinBeamCenterPlot  fit_PD_intensity
//	if(!V_Flag)
//		AppendToGraph /W=LinLinBeamCenterPlot  fit_PD_intensity
//	endif
//		ModifyGraph rgb(fit_PD_intensity)=(0,15872,65280)
//		ModifyGraph lsize(fit_PD_intensity)=3
//
//	PeakFitWave= (MaximumIntensity) *exp(-0.5*( (x-BeamCenter) / sigma )^2)
//	string BmCnterStr
//	Sprintf BmCnterStr, "%8.5f", BeamCenter
//	String Width="\Z12FWHM   "+num2str(3600*PeakWidth)+"  arc-sec"//+" +/- "+num2str(3600*GaussPeakWidthError)
//	Width+="\rMax       "+num2str(MaximumIntensity)//+"   +/-  "+num2str(MaximumIntensityError)
//	Width+="\rBm Cntr  "+BmCnterStr//+"  +/-  "+num2str(BeamCenterError)+"  deg."
//	Textbox/K/N=text1
//	Textbox/N=text1/S=0/B=2/F=0/A=RT/X=0.37/Y=-21.86 Width
////	KillWaves W_WaveList
//	IN2G_AppendNoteToAllWaves("PeakFitFunction","GaussAutomatic")
//	IN2G_AppendNoteToAllWaves("BeamCenter",num2str(BeamCenter))
//	IN2G_AppendNoteToAllWaves("MaximumIntensity",num2str(MaximumIntensity))
//	IN2G_AppendNoteToAllWaves("FWHM",num2str(PeakWidth*3600))
//
//	Killwaves/Z PD_Intensity_Loc, Ar_encoder_Loc
//End
//
//
//
//Function IN2A_FitGaussTop(ctrlname) : Buttoncontrol			// calls the Gaussien fit
//	string ctrlname
//	
//	Wave PD_error
//	Wave Ar_encoder
//	Wave PD_Intensity
//	GetWindow kwTopWin, wavelist						//creates wavelist
//	K0=0
//	if(strlen(CsrInfo(A, "LinLinBeamCenterPlot")) <1  || strlen(CsrInfo(B, "LinLinBeamCenterPlot"))<1)
//		return 0
//	endif
//	CurveFit/Q/H="1000"  gauss $WaveName("",0,1)(xcsr(A),xcsr(B))  /X=$WaveName("",0,2) /D /W=PD_error /I=1	//Gauss
//	print "Fitted Gaussian between points  "+num2str(pcsr(A))+"   and    "+num2str(pcsr(B))+"    reached Chi-squared/numpoints    " +num2str(V_chisq/(pcsr(B)-pcsr(A)))
//	string ModifyWave
//	ModifyWave="fit_"+WaveName("",0,1)						//new wave with the lorenzian fit
//	ModifyGraph /W=LinLinBeamCenterPlot lsize(fit_PD_Intensity)=3, rgb(fit_PD_intensity)=(0,15872,65280)
//	Variable/G BeamCenter, MaximumIntensity, PeakWidth		//creates variables with results
//	Variable BeamCenterError, MaximumIntensityError, PeakWidthError
//	Wave W_coef
//	Wave W_sigma
//	Wave PeakFitWave
//	Wave FitResiduals
//	FitResiduals= ((W_coef[0]+W_coef[1]*exp(-((Ar_encoder[p]-W_coef[2])/W_coef[3])^2)) - PD_Intensity[p])/PD_error[p]
//	FitResiduals[0,xcsr(A)-1]=NaN
//	FitResiduals[xcsr(B)+1,inf]=NaN
//	PeakFitWave= W_coef[0]+W_coef[1]*exp(-((x-W_coef[2])/W_coef[3])^2)
//	BeamCenter=W_coef[2]
//	BeamCenterError=W_sigma[2]
//	MaximumIntensity=W_coef[1]
//	MaximumIntensityError=W_sigma[1]
//	PeakWidth = 2*(sqrt(ln(2)))*abs(W_coef[3])
//	PeakWidthError=2*(sqrt(ln(2)))*abs(W_sigma[3])
//	Variable GaussPeakWidth=2*(sqrt(ln(2)))*abs(W_coef[3])			// properly fixed by now. 
//	Variable GaussPeakWidthError=2*(sqrt(ln(2)))*abs(W_sigma[3])
//	string BmCnterStr
//	Sprintf BmCnterStr, "%8.5f", BeamCenter
//	String Width="\Z12FWHM   "+num2str(3600*GaussPeakWidth)+" +/- "+num2str(3600*GaussPeakWidthError)+"  arc-sec"
//	Width+="\rMax       "+num2str(MaximumIntensity)+"   +/-  "+num2str(MaximumIntensityError)
//	Width+="\rBm Cntr  "+BmCnterStr+"  +/-  "+num2str(BeamCenterError)+"  deg."
//	Textbox/K/N=text1
//	Textbox/N=text1/S=0/B=2/F=0/A=RT/X=0.37/Y=-21.86 Width
//	ModifyGraph rgb($ModifyWave)=(0,15872,65280)
//	KillWaves/Z W_WaveList
//	IN2G_AppendNoteToAllWaves("PeakFitFunction","Gauss")
//	IN2G_AppendNoteToAllWaves("BeamCenter",num2str(BeamCenter))
//	IN2G_AppendNoteToAllWaves("MaximumIntensity",num2str(MaximumIntensity))
//	IN2G_AppendNoteToAllWaves("FWHM",num2str(PeakWidth*3600))
//	IN2G_AppendNoteToAllWaves("BeamCenterError",num2str(BeamCenterError))
//	IN2G_AppendNoteToAllWaves("MaximumIntensityError",num2str(MaximumIntensityError))
//	IN2G_AppendNoteToAllWaves("FWHM_Error",num2str(PeakWidthError*3600))
//End
//
////******************** name **************************************
//
//
//Function IN2A_ContinueRWave(ctrlname) :Buttoncontrol
//	string ctrlname
//	
//	NVAR/Z BeamCenter
//	NVAR/Z PeakWidth
//	NVAR/Z MaximumIntensity
//	if(!NVAR_Exists(BeamCenter) || !NVAR_Exists(PeakWidth) || !NVAR_Exists(MaximumIntensity))
//		abort "Did not get beam center parameters"
//	endif
//       String wName=WinName(0, 1)              // 1=graphs, 2=tables,4=layouts
//       dowindow /K $wName
//	KillWaves/Z PeakFitWave
//	
//	variable/G UserDidNotSaveRData
//	UserDidNotSaveRData=0
//	
////	IN2G_AppendAnyText("Beam center :  " + num2str(BeamCenter))
////	IN2G_AppendAnyText("Maximum Intensity :  " + num2str(MaximumIntensity))
////	IN2G_AppendAnyText("Peak Width :  " + num2str(PeakWidth))
//	//fix to provide appropriate numbers in the logbook - need righ number of decimal places...
//        String myStr
//        sprintf myStr, "%s :  %.5f", "Beam center", BeamCenter
//                IN2G_AppendAnyText(myStr)
//        sprintf myStr, "%s :  %g", "Maximum Intensity", MaximumIntensity
//                IN2G_AppendAnyText(myStr)
//        sprintf myStr, "%s :  %.5f", "Peak Width", PeakWidth
//                IN2G_AppendAnyText(myStr)
//	
//	IN2A_CreateLogLogPlot()							//creates log log plot for R wave
//End
//
//Function IN2A_CreateLogLogPlot()	//this creates log log plot for check of dark currents
//	
//	Wave ar_encoder	
//	SVAR MeasurementParameters
//	SVAR specComment
//	SVAR FolderName
//	NVAR BeamCenter
//	Duplicate/O ar_encoder, Qvec
//		IN2G_AppendorReplaceWaveNote("Qvec","Wname","Qvec") 
//		IN2G_AppendorReplaceWaveNote("Qvec","Units","A-1")
//	Redimension/D Qvec
//	variable/G wavelength=12.398424437/NumberByKey("DCM_energy", MeasurementParameters,"=")
//
//	Qvec=((4*pi)/wavelength)*sin((pi/360)*(BeamCenter-ar_encoder))
//	
//	Wave PD_Intensity
//	    
//	PauseUpdate    //*************************Graph section**********************************
//		//Display /k=1 /W=(0.3*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("height"),60*IN2G_ScreenWidthHeight("width"),70*IN2G_ScreenWidthHeight("height")) PD_Intensity vs Qvec as "Log-log R for sample/blank"		//plots selected data, axis lin-lin
//		Display /k=1 /W=(0,0,IN2G_GetGraphWidthHeight("width"),IN2G_GetGraphWidthHeight("height")) PD_Intensity vs Qvec as "Log-log R for sample/blank"		//plots selected data, axis lin-lin
//		DoWindow/C LogLogRPlot
//		Execute ("IN2G_BasicGraphStyle()")		
//		ModifyGraph log=1, mirror=1
//		Label left "Intensity"										//labels left axis
//		Label bottom "Q vector [A-1]"									//labels bottom axis
// 		Button SaveRWave pos={150,10}, size={150,25}, title="1. Save the R data", proc=IN2A_SaveRWave
//		Button ExportRdata pos={150,40}, size={150,25}, title="(2.) Export R data", proc=IN2A_SaveRWaveButton
//		Button ContinueNextSample pos={150,70}, size={150,25}, title="3. Evaluate another sample", proc=IN2A_RepeatMacroButton	
//		Button RemovePointR pos={0,100}, size={140,20}, title="Remove pnt w/csrA", proc=IN2G_RemovePointWithCursorA
//		Textbox/N=text0/S=3/A=RT FolderName		//specComment
//		ResumeUpdate   //*************************Graph section**********************************
//		ModifyGraph width=0, height=0
//	IN2G_AutoAlignGraphAndPanel()				//align the windows
//	IN2G_CleanupFolderOfWaves()					//cleanup waves starting with W_ and fit_
//End
//
//Function IN2A_RepeatMacroButton(ctrlname) : Buttoncontrol			// calls the repeat function fit
//	string ctrlname
//		
//	NVAR UserDidNotSaveRData
//	if (!UserDidNotSaveRData)
//		DoAlert 2, "R data were not saved. Save R wave before continuing?"
//		if (V_Flag==3) //cancel
//			abort
//		elseif(V_Flag==1) //save data
//			IN2A_SaveRWave("")
//		endif
//	endif	
//	if (strlen(WinList("IN2A_UPDControlPanel",";","WIN:64"))>0)					//Kills the controls when not needed anymore
//			KillWIndow/Z IN2A_UPDControlPanel
//	endif
//	IN2G_KillGraphsAndTables("yes")
//	IN2A_CreateRWave()
//End
//
//
//Function IN2A_SaveRWave(ctrlname) : Buttoncontrol						//Save the PD_current wave into R_Int
//	string ctrlname
//
//	    
//	Wave PD_Intensity
//	Wave Qvec
//	Wave PD_error
//	
//	Duplicate/O PD_Intensity, R_Int								//we can duplicate since do not use the dependencies anymore
//	Duplicate/O Qvec, R_Qvec
//	Duplicate/O PD_error, R_error
//		IN2G_AppendorReplaceWaveNote("R_Int","Wname","R_Int") 
//		IN2G_AppendorReplaceWaveNote("R_Qvec","Wname","R_Qvec") 
//		IN2G_AppendorReplaceWaveNote("R_Qvec","Units","A-1")
//		IN2G_AppendorReplaceWaveNote("R_error","Wname","R_error") 
//
//	SVAR UPDParameters
//	IN2G_AppendAnyText("\rR wave created for :"+GetDataFolder(1))
//	SVAR/Z PathToRawData
//	if(SVAR_Exists (PathToRawData))
//		IN2G_AppendAnyText("These data came from  :  " + PathToRawData)
//	endif
//	IN2G_AppendAnyText("UPD parameters selected  :  " + UPDParameters)
//	
//	NVAR UserDidNotSaveRData
//	UserDidNotSaveRData=1
//
//
//	if (strlen(WinList("IN2A_UPDControlPanel",";","WIN:64"))>0)		//Kills the UPD controls when not needed anymore
//			KillWIndow/Z IN2A_UPDControlPanel
//	endif
//
//end
//
//
//Proc IN2A_SaveRWaveButton(ctrlname) : Buttoncontrol			//repeats macro
//		string ctrlname
//	IN2G_WriteSetOfData("R")	
//End
//
////Proc IN2A_ExportRWaves()
////
////	string filename=IN2G_FixTheFileName()
////	filename = filename+".R"
////	if (exists("R_Int")==1)
////		Save/I/G/M="\r\n" R_Qvec,R_Int,R_error as filename			///P=Datapath
////	else
////		DoAlert 0, "The R data do not exist, please create them and then run the macro again"		//here goes message
////	endif
////end
//
Function IN2A_GetMeasParam()		//sets various spray parameters
	SVAR SpecCommand
	
	string specCommandSeparated= ReduceSpaceRunsInString(SpecCommand,1)
	if (!cmpstr(SpecCommandSeparated[0,0]," "))
		SpecCommandSeparated = SpecCommandSeparated[1,inf]						// remove any leading space
	endif
	SpecCommandSeparated = ChangePartsOfString(SpecCommandSeparated," ",";")		// one space is name separator

	//	Following macro calls are know  to me
	//	11 items: uascan motor start center finish minstep dy0 SDD_mm exponent intervals time		.... old slit smeared macro before AY movement
	// 	13 items: uascan motor start center finish minstep dy0 SDD_mm ay0 SAD_mm exponent intervals time.... new slit smeared macro with AY movement
	//	12 items: sbuascan motor start center finish minstep dy0 asrp SDD_mm exponent intervals time		.... old SBUSAXS smeared macro before AY movement
	//	14 items: sbuascan motor start center finish minstep dy0 asrp SDD_mm ay0 SAD_mm exponent intervals time.... old slit smeared macro before AY movement
	
	Variable SDDistance
	if (ItemsInList(SpecCommandSeparated)==11)
		SDDistance=str2num(StringFromList(7,SpecCommandSeparated))
	endif
	if (ItemsInList(SpecCommandSeparated)==13)
		SDDistance=str2num(StringFromList(7,SpecCommandSeparated))
	endif
	if (ItemsInList(SpecCommandSeparated)==12)
		SDDistance=str2num(StringFromList(8,SpecCommandSeparated))
	endif
	if (ItemsInList(SpecCommandSeparated)==14)
		SDDistance=str2num(StringFromList(8,SpecCommandSeparated))
	endif
	Variable ScanSteps=str2num(StringFromList(ItemsInList(SpecCommandSeparated)-2,SpecCommandSeparated))
	
	Prompt SDDistance, "This looks like messup with Sample to Detector distance - overide:"
	
	if (SDDistance<50)
		DoPrompt "Check Parameters", SDDistance
		if (V_Flag)
			Abort 
		endif	
	endif
	//lets check on SDD length
	
	if (cmpstr(StringFromList(7,SpecCommandSeparated),"SBUASCAN")==0)		//regular USAXS
		if (SDDistance>450)
			DoPrompt "Check Parameters", SDDistance
			if (V_Flag)
				Abort 
			endif	
		endif
	else									//SBUSAXS, longer SDD usual
		if (SDDistance>700)
			DoPrompt "Check Parameters", SDDistance
			if (V_Flag)
				Abort 
			endif	
		endif
	endif
	
	SVAR MeasurementParameters
	SVAR UPDParameters
	
	NVAR/Z PhotoDiodeSize=root:Packages:Indra3:PhotoDiodeSize
	if (!NVAR_Exists(PhotoDiodeSize))								//avoid next lines if already exists....
		Variable/G root:Packages:Indra3:PhotoDiodeSize=5.5
		NVAR PhotoDiodeSize=root:Packages:Indra3:PhotoDiodeSize
		Variable PhotoDiodeSizeL=PhotoDiodeSize
		Prompt PhotoDiodeSizeL, "Check PD size:"
		DoPrompt "Check PD size", PhotoDiodeSizeL
			if (V_Flag)
				Abort 
			endif	
		PhotoDiodeSize=PhotoDiodeSizeL
	endif

	variable wavelength=12.398424437/NumberByKey("DCM_energy",MeasurementParameters,"=")
	variable SlitLength=0.5*((4*pi)/wavelength)*sin(PhotoDiodeSize/(2*SDDistance))

	MeasurementParameters=ReplaceStringByKey("Wavelength",MeasurementParameters,num2str(wavelength),"=")
	MeasurementParameters=ReplaceStringByKey("SlitLength",MeasurementParameters,num2str(SlitLength),"=")
	MeasurementParameters=ReplaceStringByKey("NumberOfSteps",MeasurementParameters,num2str(ScanSteps),"=")
	MeasurementParameters=ReplaceStringByKey("SDDistance",MeasurementParameters,num2str(SDDistance),"=")
	
	IN2G_AppendNoteToAllWaves("Wavelength",num2str(wavelength))
	IN2G_AppendNoteToAllWaves("SlitLength",num2str(SlitLength))
	IN2G_AppendNoteToAllWaves("NumberOfSteps",num2str(ScanSteps))
	IN2G_AppendNoteToAllWaves("SDDistance",num2str(SDDistance))
end
//
//*********************End of Create R wave functions *********************************************
//*********************Align sample and Blank*******************************************************


//Function IN2B_AlignSampleAndBlank()		//here we align sample and blank
//
//	IN2G_UniversalFolderScan("root:USAXS:", 5, "IN2G_CheckTheFolderName()")  //here we fix the folder names/sample names in wave notes if necessary	
//
//	IN2A_CleanupAllWIndows()						//cleanup all open windows from Indra 2
//
//	string ListOfFolders
//	ListOfFolders=IN2B_SelectSampleForASB()			//select sample and go the that place
//
//	ListOfFolders=IN2B_SelectBlankForASB()			//select blank
//													//the ListOfFolders :"Sample=Folder;Calibrate=USAXS/SBUSAXS/no;Blank=Folder	
//													//OK, now we are in that folder and know the sample path, blank path, and type of calibration
//	ListOfFolders=IN2B_CalculateASBCalibration()		//calculate calibration and put the results into the ASBparameters
//	
//	IN2B_AlignSampleAndBlankLinLin()					//this generates the lin lin plot for beam centers
//	
//	IN2B_AlignSampleAndBlankLogLog()				//and this is the end of the process
//
//end
//

//Function IN2B_CalcCalibrationPrecision(USAXSorSBUSAXS)
//	string USAXSorSBUSAXS
//	//assume we are in the appropriate folder
//	//we need to get the data from the wavenotes'..
//	// USAXSorSBUSAXS = "USAXS" or "SBUSAXS"
//	
//	if (cmpstr(USAXSorSBUSAXS,"USAXS")==0)	//called from USAXS subtract sample and blank
//		Wave CalcInt=SMR_Int
//	else
//		Wave CalcInt=DSM_Int			//called from SBUSAXS subtract sample and blank, SMR_Int does not exist 
//	endif
//	
//	Wave BL_R_Int
//	
//	variable PeakWidthError=NumberByKey("FWHM_Error", note(CalcInt),"=")
//	variable BL_PeakWidth=NumberByKey("FWHM", note(BL_R_Int),"=")
//	variable BL_PeakWidthError=NumberByKey("FWHM_Error", note(BL_R_Int),"=")
//	variable MaximumIntensityError=NumberByKey("MaximumIntensityError", note(CalcInt),"=")
//	variable BL_MaximumIntensityError=NumberByKey("MaximumIntensityError", note(BL_R_Int),"=")
//	variable MaximumIntensity=NumberByKey("MaximumIntensity", note(CalcInt),"=")
//	variable BL_MaximumIntensity=NumberByKey("MaximumIntensity", note(BL_R_Int),"=")
//	variable Kfactor=NumberByKey("Kfactor", note(CalcInt),"=")
//
//	variable TransmissionError=IN2G_ErrorsForDivision(MaximumIntensity,MaximumIntensityError,BL_MaximumIntensity,BL_MaximumIntensityError)
//	
//	variable OmegaFactorError=BL_PeakWidthError*(KFactor/BL_MaximumIntensity)/BL_PeakWidth
//	
//	variable KFactorError=IN2G_ErrorsForMultiplication(BL_MaximumIntensity,BL_MaximumIntensityError,(KFactor/BL_MaximumIntensity),OmegaFactorError)
//	
//	IN2G_AppendAnyText("\r**************************************************************************")
//	IN2G_AppendAnyText("Evaluated estimated errors for calibrations for:\t"+GetDataFolder(1))
//	IN2G_AppendAnyText("TransmissionError :\t\t"+num2str(TransmissionError))
//	IN2G_AppendAnyText("KFactorError :\t\t"+num2str(KFactorError))
//
//	IN2G_AppendNoteToAllWaves("TransmissionError",num2str(TransmissionError))
//	IN2G_AppendNoteToAllWaves("KFactorError",num2str(KFactorError))
// 
//end
//
//Function/T IN2B_SelectSampleForASB()			//here we select sample folder and calibrate value and write it into list in Pacakges/Usaxs folder
//	string FldrName, Calibrate						//and set working folder there
//
//	SVAR/Z Parameters=root:Packages:Indra3:ListOfASBParameters			//global string for ASB parameters
//	if (!SVAR_Exists(Parameters))
//		string/g root:Packages:Indra3:ListOfASBParameters = " "			//create if necessary
//		SVAR Parameters=root:Packages:Indra3:ListOfASBParameters
//	endif
//	
//	Prompt FldrName, "Select Folder with SAMPLE data", popup, IN2B_NextASBDataToEvaluate()+";"+IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, "R_Int", 1)	
//	DoPrompt "Subtract Blank from Sample dialog - select Sample folder", FldrName							//get the folder 
//	
//	if (V_Flag)
//		Abort  
//	endif
//
//	IN2G_AppendAnyText("\r***************************************************\r")
//	IN2G_AppendAnyText("Subtract Blank from Sample started for :"+FldrName)
//
//	setDataFolder $FldrName												//go there
//	
//	Parameters=ReplaceStringByKey("Sample",Parameters,FldrName,"=")		//write results into ASBparameters
//	return Parameters		
//end
//
//
//
//Function/T IN2B_SelectBlankForASB()								//this selects the blank folder
//	string FldrBlank, Calibrate
//
//	SVAR/Z ListOfASBParameters
//	SVAR/Z Parameters=root:Packages:Indra3:ListOfASBParameters				//global string for current folder info
//	if (!SVAR_Exists(Parameters))
//		Abort "Problem, ListOfASBParameters does not exist, this should never happen!!!"
//	endif
//	string LParameters=""
//	if (SVAR_Exists(ListOfASBParameters))
//		LParameters=ListOfASBParameters
//	else
//		string/g ListOfASBParameters
//		SVAR ListOfASBParameters
//		LParameters=Parameters
//	endif
//	Wave R_Int
//	string IsItSBUSAXS=StringByKey("SPECCOMMAND", note(R_Int), "=")[0,7]			//find out if this is SBUSAXS
//	string ListOfCalibrateOptions=""
//	
//	if (cmpstr(IsItSBUSAXS,"sbuascan")==0)				//SBUSAXS, do not let user to select USAXS calibration
//		ListOfCalibrateOptions="SBUSAXS;no;USAXS"
//	else																			
//		ListOfCalibrateOptions="USAXS;no;SBUSAXS"				//and if it is USAXS data, do not let user select SBUSAXS calibration
//	endif
//	string OldBlankData
//	OldBlankData=StringByKey("Blank",LParameters,"=",";")			//this now contains blank which was used previously, we need to make sure these still exist - too creative users...
//	if (!DataFolderExists(OldBlankData) || !WaveExists($(OldBlankData+"R_Int")))
//		OldBlankData="---"
//	endif
//	Prompt FldrBlank, "Select Folder with blank", popup, OldBlankData+";"+ListMatch(IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, "R_Int", 1),"*blank*")+";"+IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, "R_Int", 1)
//	Prompt Calibrate, "Calibrate the data?", popup, ListOfCalibrateOptions		//removed - seems to cause confusion in some cases StringByKey("Calibrate", Parameters, "=",";")
//
//	DoPrompt "Subtract Blank from Sample - select Blank for "+GetDataFolder(0),  FldrBlank, Calibrate		//get the folder 
//	
//	if (V_Flag)
//		Abort 
//	endif
//	if (!WaveExists($(FldrBlank+"R_Int")) || !WaveExists($(FldrBlank+"R_Qvec")) || !WaveExists($(FldrBlank+"R_Error")))
//		Abort "Error!!! R data (R_Int, R_Qvec, R_Error) for Blank do not exist. Likely User messed up names structure. Do NOT DO IT!!!"
//	endif
//
//	IN2G_AppendAnyText("Blank used :\t"+FldrBlank)
//	IN2G_AppendAnyText("Calibration method :\t"+Calibrate)
//
//	Parameters=	ReplaceStringByKey("Calibrate",Parameters,Calibrate,"=")			//put results into ASBParameters
//	Parameters=ReplaceStringByKey("Blank",Parameters,FldrBlank,"=") 			//put the in there
//	ListOfASBParameters=ReplaceStringByKey("Calibrate",ListOfASBParameters,Calibrate,"=")
//	ListOfASBParameters=ReplaceStringByKey("Blank",ListOfASBParameters,FldrBlank,"=")
//	return Parameters
//end
//
//Function/T IN2B_NextASBDataToEvaluate()					//this returns next USAXS sample in order to evaluate 
//
//	string ListOfData=IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, "R_Int", 1)
//	SVAR LastASB=root:Packages:Indra3:ListOfASBParameters		//global string for current folder info
//	variable start=FindListItem(StringByKey("Sample",lastASB,"=",";"), ListOfData)
//	ListOfdata=ListOfData[start,inf]
//	return StringFromList(1,ListOfdata)
//end
//
//Function/T IN2B_CalculateASBCalibration()		//get user input and calculate calibration factors depending on calibration type
//
//	SVAR ASBParameters=ListOfASBParameters					//this is KWlist of parameters, both calibration parameters will be appended 
//	SVAR UPDParameters=UPDParameters					//this is KWlist of parameters, both calibration parameters will be appended 
//	NVAR BLPeakWidth=$(StringByKey("Blank", ASBParameters,"=",";")+"PeakWidth")
//	NVAR BLPeakMax=$(StringByKey("Blank", ASBParameters,"=",";")+"MaximumIntensity")
//	string Calibrated=StringByKey("Calibrate", ASBParameters,"=",";")
//	
//	variable PhotoDiodeSize=NumberByKey("UPDsize", UPDParameters,"=")																//Default PD size to 5.5mm at this time....
//	if(numtype(PhotoDiodeSize)!=0|| PhotoDiodeSize<=1)
//		PhotoDiodeSize = 5.5
//	endif
//	
//	SVAR MeasurementParameters
//	variable SampleToDetectorDistance=numberByKey("SDDistance",MeasurementParameters,"=")		//need to get it
//	if (numtype(SampleToDetectorDistance)==2)														//this is fix for trouble when Raw-to_USAXS is run out of sequence
//		IN2A_GetMeasParam()
//		SampleToDetectorDistance=numberByKey("SDDistance",MeasurementParameters,"=")
//	endif
//	Variable OmegaFactor,ASStageWidthAtHalfMax
//	Variable Kfactor,BLPeakWidthL
//	Variable SampleThickness=NumberByKey("thickness", MeasurementParameters,"=")	//update 12/01 - we added to EPICS parameters the sample thickness
//	// first check that the EPICS parameters really have useful number there
//	if (numtype(SampleThickness)!=0)
//		SampleThickness=1
//	endif
//	//and then, if we already set sample thickness before, we will ovewrite it here...
//	if (NumType(NumberByKey("SaThickness", ASBParameters ,"=" ,";"))!=2)			//this carries forward the old sample thickness - the previous 
//		SampleThickness=NumberByKey("SaThickness", ASBParameters ,"=" ,";")		//sample sample thickness is offered
//	endif
//	Wave R_Int
//														//lets check if we have old sample thickness in the wave note for R_Int here
//	variable oldthickness=NumberByKey("Thickness", note(R_Int) ,"=",";")
//	if (numtype(oldthickness)==0)			//if it existed in the wave note, we will offer that to user
//		SampleThickness=oldthickness
//	endif
//	Prompt SampleThickness, "Input sample thickness in mm for "+GetDataFolder(1)
//	
//	if (cmpstr(StringByKey("Calibrate", ASBParameters,"=",";"),"USAXS")==0)		//USAXS callibration, width given by SDD and PD size
//		BLPeakWidthL=BLPeakWidth*3600													//W_coef[3]*3600*2
//		Prompt BLPeakWidthL, "?Overwrite the Blank width at half max (arc-sec)"
//		DoPrompt "USAXS Calibration user input for  "+GetDataFolder(1), BLPeakWidthL, SampleThickness
//			if (V_Flag)
//				Abort 
//			endif	
//		if(SampleThickness<=0)
//			Prompt SampleThickness, "ERROR, sample thickness is <= 0! Please input correct sample thickness"
//			DoPrompt "Fix incorrect sample thickness", SampleThickness
//			if(V_Flag)
//				Abort
//			endif
//			if(SampleThickness<=0)
//				SampleThickness=100
//				DoAlert 1, "Sample thickness set to 100mm, your absolute intensity calibration is probably inccorrect. Do you still want to continue?"
//				if(V_Flag!=1)
//					abort
//				endif
//			endif
//		endif
//		
//		
//		OmegaFactor= (PhotoDiodeSize/SampleToDetectorDistance)*(BLPeakWidthL/3600)*(pi/180)
//		Kfactor=BLPeakMax*OmegaFactor*SampleThickness*0.1 				//0.1 converts the thickness of sample from mm to cm
//
//	IN2G_AppendAnyText("Blank width :\t"+num2str(BLPeakWidthL))
//	IN2G_AppendAnyText("Sample thickness :\t\t"+num2str(SampleThickness))
//	IN2G_AppendAnyText("K factor :\t\t"+num2str(Kfactor))
//	IN2G_AppendAnyText("Omega Factor :\t"+num2str(Omegafactor))
//
//	endif
//	
//	if (cmpstr(StringByKey("Calibrate", ASBParameters,"=",";"),"SBUSAXS")==0)	//SBUSAXS callibration, width given by rocking curve width
//		BLPeakWidthL=BLPeakWidth*3600												//W_coef[3]*3600*2
//		ASStageWidthAtHalfMax=BLPeakWidthL
//		string MyWarnig="Fix for Signlebounce Intensity for this is dividing data by 1.66 (sqrt(1.32^2+1^2)"
//		Prompt BLPeakWidthL, "?Overwrite measured Blank FWHM (arc-sec)"
//		Prompt ASStageWidthAtHalfMax, "?AS stage width FWHM (arc-sec)"
//		Prompt MyWarnig, "Single sidebounces used, the calibration with default peak width is incorrect !!"
//		DoPrompt "SBUSAXS Calibration user input for  "+GetDataFolder(1), BLPeakWidthL, ASStageWidthAtHalfMax, MyWarnig, SampleThickness
//			if (V_Flag)
//				Abort 
//			endif	
//		OmegaFactor=(ASStageWidthAtHalfMax/3600)*(pi/180)*(BLPeakWidthL/3600)*(pi/180)	//Is this correct callibration for SBUSAXS?????
//		Kfactor=BLPeakMax*OmegaFactor*SampleThickness*0.1 				//0.1 converts the thickness of sample from mm to cm
//
//	IN2G_AppendAnyText("Blank width :\t"+num2str(BLPeakWidthL))
//	IN2G_AppendAnyText("AS stage width :\t"+num2str(ASStageWidthAtHalfMax))
//	IN2G_AppendAnyText("Sample thickness :\t\t"+num2str(SampleThickness))
//	IN2G_AppendAnyText("K factor :\t\t"+num2str(Kfactor))
//	IN2G_AppendAnyText("Omega Factor :\t"+num2str(Omegafactor))
//
//	endif
//
//	if (cmpstr(StringByKey("Calibrate", ASBParameters,"=",";"),"no")==0)			//no callibration, 
//		DoPrompt "No calibration - scale to sample thickness for  "+GetDataFolder(1), SampleThickness
//		if (V_Flag)
//			Abort 
//		endif	
//		Kfactor=SampleThickness*0.1
//		OmegaFactor=1
//	
//	IN2G_AppendAnyText("K factor :\t\t"+num2str(Kfactor))
//	
//	endif
//	
//	IN2G_AppendNoteToAllWaves("Thickness",num2str(SampleThickness))			//attach sample thickness to all waves in the folder
//	
//	ASBParameters=	ReplaceStringByKey("OmegaFactor",ASBParameters,num2str(Omegafactor),"=")
//	ASBParameters=	ReplaceStringByKey("BlankWidthUsed",ASBParameters,num2str(BLPeakWidthL),"=")
//	ASBParameters=	ReplaceStringByKey("ASWidthUsed",ASBParameters,num2str(ASStageWidthAtHalfMax),"=")
//	ASBParameters=	ReplaceStringByKey("SaThickness",ASBParameters,num2str(SampleThickness),"=")
//	ASBParameters=ReplaceStringByKey("Kfactor",ASBParameters,num2str(Kfactor),"=") 			//put the in there
//
//	return ASBParameters
//end
//
//
//
//Function IN2B_AlignSampleAndBlankLinLin()					//This creates the graph for aligning peaks of blank and sample
//
//		SVAR ASBparameters=ListOfASBParameters
//		Wave R_Int
//		Wave R_error
//		Wave R_Qvec
//		Wave BL_R_IntORG=$(StringByKey("Blank", ASBparameters,"=",";")+"R_Int")			//these are original blank waves
//		Wave BL_R_errorORG=$(StringByKey("Blank", ASBparameters,"=",";")+"R_error")
//		Wave BL_R_QvecORG=$(StringByKey("Blank", ASBparameters,"=",";")+"R_Qvec")
//		Duplicate/O BL_R_IntORG, BL_R_Int													//and these are new copies in sample
//		Duplicate/O BL_R_ErrorORG, BL_R_error
//		Duplicate/O BL_R_QvecORG, BL_R_Qvec
//		IN2G_AppendorReplaceWaveNote("BL_R_Int","Wname","BL_R_Int") 
//		IN2G_AppendorReplaceWaveNote("BL_R_Qvec","Wname","BL_R_Qvec") 
//		IN2G_AppendorReplaceWaveNote("BL_R_error","Wname","BL_R_error") 
//		NVAR Sample_MaximumIntensity=MaximumIntensity
//		NVAR Blank_MaximumIntensity=$(StringByKey("Blank", ASBparameters,"=",";")+"MaximumIntensity")
//		SVAR specComment
//		SVAR FolderName
//		
//		Duplicate/O R_Int, R_Int_corr
//		Duplicate/O R_Qvec, R_Qvec_shifted
//			IN2G_AppendorReplaceWaveNote("R_Int_Corr","Wname","R_Int_corr") 
//			IN2G_AppendorReplaceWaveNote("R_Qvec_shifted","Wname","R_Qvec_shifted") 
//		variable/G Transmission=Sample_MaximumIntensity/Blank_MaximumIntensity			
//	  	R_Int_corr =R_Int/Transmission
//		Variable/G Qshift=0
//		R_Qvec_shifted=R_Qvec-Qshift
//
//
//		//Display /K=1/W=(0.3*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("height"),60*IN2G_ScreenWidthHeight("width"),70*IN2G_ScreenWidthHeight("height")) BL_R_Int vs BL_R_Qvec as "Lin-lin plots of R for Sample and Blank"								//I like graphs
//		Display /K=1/W=(0,0,IN2G_GetGraphWidthHeight("width"),IN2G_GetGraphWidthHeight("height")) BL_R_Int vs BL_R_Qvec as "Lin-lin plots of R for Sample and Blank"								//I like graphs
//		Execute ("IN2G_BasicGraphStyle()")
// 		AppendToGraph/C=(0,0,0) R_Int_corr vs R_Qvec_shifted 
// 		DoWindow/C ASBLinLinPlot
// 		ModifyGraph zColor=0
//		Label left "Intensity"												//labels left axis
//		Label bottom "Q vector"											//labels bottom axis
//  		ModifyGraph mode=4,gaps=0,rgb(BL_R_Int)=(16384,16384,65280)
//		ModifyGraph rgb(R_Int_corr)=(65280,0,0)
//
//		WaveStats/Q R_Int
//		FindLevels/P/Q R_Int, (0.05*V_max)
//		Wave W_FindLevels
//		if(numpnts(W_FindLevels)>1)		//found two crossings...
//			if (floor(W_FindLevels[0])<4)
//				W_FindLevels[0]=4
//			endif
//			SetAxis bottom, R_Qvec_shifted[floor(W_FindLevels[0])-3], R_Qvec_shifted[ceil(W_FindLevels[1])+3]
//		else
//			SetAxis bottom, R_Qvec_shifted[0], R_Qvec_shifted[ceil(W_FindLevels[0])+3]	
//		endif
//		KillWaves/Z W_FindLevels
//		SetVariable Qshift,pos={150,35},size={250,25}, proc=IN2B_ASBFixTransmOrShift, value=Qshift, title="Sample shift in Q",limits={-0.1,0.1,0.000001}
//		SetVariable Transmission,pos={150,10},size={250,25}, value=Transmission, proc=IN2B_ASBFixTransmOrShift, title="Sample Transmission",limits={0,2,Transmission/200}
//		Button ContinueWithSubtractingBlank pos={150,55}, size={150,25}, title="Continue", proc=IN2B_ContinueASB2
//		Textbox/N=text0/S=3/A=LB "Sample (red line) : "+StringByKey("UserSampleName", note(R_Int_corr), "=")+"\rBlank is (blue line) : "+StringByKey("UserSampleName", note(BL_R_Int), "=")
//		ResumeUpdate
//		
//		ModifyGraph width=0, height=0
//		
//	PauseForUser ASBLinLinPlot  				//and wait until the panel is killed
//
//end
//
//Function IN2B_AlignSampleAndBlankLogLog()
//
//		SVAR ASBparameters=ListOfASBParameters
//		Wave R_Int
//		Wave R_error
//		Wave R_Qvec
//		Wave BL_R_Int													//and these are new copies in sample
//		Wave BL_R_error
//		Wave BL_R_Qvec
//		NVAR Sample_MaximumIntensity=MaximumIntensity
//		NVAR Blank_MaximumIntensity=$(StringByKey("Blank", ASBparameters,"=",";")+"MaximumIntensity")
//		SVAR specComment
//		SVAR FolderName
//		
//		Wave R_Int_corr
//		Wave R_Qvec_shifted
//		NVAR Transmission			
//		NVAR Qshift
//
//	  PauseUpdate    //*************************Graph section**********************************
// 		//Display /K=1 /W=(0.3*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("height"),60*IN2G_ScreenWidthHeight("width"),70*IN2G_ScreenWidthHeight("height")) BL_R_Int vs BL_R_Qvec as "Log-log plots of R for Sample and Blank"	//I like graphs
// 		Display /K=1 /W=(0,0,IN2G_GetGraphWidthHeight("width"),IN2G_GetGraphWidthHeight("height"))  BL_R_Int vs BL_R_Qvec as "Log-log plots of R for Sample and Blank"	//I like graphs
//		Execute ("IN2G_BasicGraphStyle()")
// 		AppendToGraph/C=(0,0,0) R_Int_corr vs R_Qvec_shifted 
//  		ModifyGraph zColor=0, mirror=1
//  		ModifyGraph rgb(BL_R_Int)=(0,0,65280)
//  		ModifyGraph rgb(R_Int_corr)=(65280,0,0)
//		DoWindow/C ASBLinLinPlot
//	  	ErrorBars R_Int_corr Y,wave=(R_error,R_error)
//   		ErrorBars BL_R_Int Y,wave=(BL_R_error,BL_R_error) 	
//
//		Label left "Intensity"								//labels left axis
//		Label bottom "Q vector"							//labels bottom axis
//		ModifyGraph log=1
//
//		SetVariable Transmission,pos={120,10},size={250,25}, proc=IN2B_ASBFixTransmOrShift, value=Transmission, title="Sample Transmission",limits={0,2,0.0001}
//		Button ContinueNextSample pos={390,90}, size={150,25}, title="3. Evaluate another sample", proc=IN2B_RepeatASBButton
//		Button CalculateSMRdata pos={390,10}, size={180,25}, title="1. Subtract and save", proc=IN2B_CalculateSMRdata
//		Button ExportSMRdata pos={390,50}, size={150,25}, title="(2.) Export data to file", proc=IN2B_SaveSMRWaveButton
//		Button RemovePoint pos={0,100}, size={140,20}, title="Remove pnt w/csrA", proc=IN2G_RemovePointWithCursorA	
//		Textbox/N=text0/A=LB/S=3 "Sample (red line) is : "+StringByKey("UserSampleName", note(R_Int_corr), "=")+"\rBlank (blue line) is :"+StringByKey("UserSampleName", note(BL_R_Int), "=")
//		SetVariable Qshift,pos={120,40},size={250,25}, proc=IN2B_ASBFixTransmOrShift, value=Qshift, title="Sample shift in Q",limits={-0.1,0.1,0.00001}
//ResumeUpdate   //*************************Graph section**********************************
//
//	ModifyGraph width=0, height=0
//end
//
//Function IN2B_RepeatASBButton(ctrlname) : Buttoncontrol			// calls the repeat function fit
//	string ctrlname
//	Wave/Z SMR_Int
//	Wave/Z DSM_Int
//	CheckDisplayed/W=ASBLinLinPlot SMR_Int		//this checks if the SMR (or DSM) wave are in the graph
//	variable testSMR	=V_Flag
//	CheckDisplayed/W=ASBLinLinPlot DSM_Int
//	variable testDSM	=V_Flag
//	if ((testSMR+testDSM)==0)
//		DoAlert 1, "No SMR/DSM data were created, do you want to continue?"
//		if (V_Flag==2)
//			abort
//		endif
//	endif
//	
//		
//	IN2G_KillGraphsAndTables("yes")
//	IN2B_AlignSampleAndBlank()
//End
//
//Function IN2B_CalculateSMRdata(ctrlname) : Buttoncontrol			//=Calculates SMR data
//	string ctrlname
//	    
//		SVAR ASBparameters=ListOfASBParameters
//		Wave R_Int
//		Wave R_error
//		Wave R_Qvec
//		Wave BL_R_Int
//		Wave BL_R_error
//		Wave BL_R_Qvec
//		Wave R_Int_corr
//		Wave R_Qvec_shifted
//		variable Kfactor=NumberByKey("Kfactor", ASBparameters,"=",";")
//		NVAR Transmission
//		string USAXSorSBUSAXS
//
//	string IsItSBUSAXS=StringByKey("SPECCOMMAND", note(R_Int), "=")[0,7]
//	string oldNoteValue
//
//	IN2G_RemoveNaNsFrom5Waves(R_Int,R_Int_corr,R_error,R_Qvec,R_Qvec_shifted)
//	IN2G_RemoveNaNsFrom3Waves(BL_R_Int,BL_R_error,BL_R_Qvec)
//	
//	if (cmpstr(IsItSBUSAXS,"sbuascan")!=0)			//if this is sbuascan, go to other part, otherwise create SMR data
//		Duplicate /O R_Int, SMR_Int, logBlankInterp, BlankInterp
//		Duplicate/O BL_R_Int, logBlankR
//		logBlankR=log(BL_R_Int)
//		LogBlankInterp=interp(R_Qvec_shifted, BL_R_Qvec, logBlankR)
//		BlankInterp=10^LogBlankInterp
//		SMR_Int=(R_Int_corr - BlankInterp)/Kfactor
//		KillWaves/Z logBlankInterp, BlankInterp, logBlankR
//		Duplicate/O R_error, SMR_Error
//		Duplicate/O BL_R_error, log_BL_R_error
//		log_BL_R_error=log(abs(BL_R_error))
//		SMR_Error=sqrt((R_error)^2/Transmission^2 + (10^(interp(R_Qvec, BL_R_Qvec, log_BL_R_error)))^2)/Kfactor
//		KillWaves/Z log_BL_R_error
//		Duplicate/O R_Qvec_shifted, SMR_Qvec
//			IN2G_AppendorReplaceWaveNote("SMR_Int","Wname","SMR_Int") 
//			IN2G_AppendorReplaceWaveNote("SMR_Qvec","Wname","SMR_Qvec") 
//			IN2G_AppendorReplaceWaveNote("SMR_Qvec","Units","A-1")
//			IN2G_AppendorReplaceWaveNote("SMR_Error","Wname","SMR_Error") 
//
//		//append data to new waves
//			oldNoteValue=stringBykey("COMMENT", note(BL_R_Int), "=")
//			IN2G_AppendorReplaceWaveNote("SMR_Int","BlankComment",oldNoteValue) 
//			IN2G_AppendorReplaceWaveNote("SMR_Int","Units","cm-1")
//			IN2G_AppendorReplaceWaveNote("SMR_Error","BlankComment",oldNoteValue) 
//			IN2G_AppendorReplaceWaveNote("SMR_Qvec","BlankComment",oldNoteValue) 
//			oldNoteValue=stringBykey("USAXSDataFolder", note(BL_R_Int), "=")
//			IN2G_AppendorReplaceWaveNote("SMR_Int","BlankFolder",oldNoteValue) 
//			IN2G_AppendorReplaceWaveNote("SMR_Error","BlankFolder",oldNoteValue) 
//			IN2G_AppendorReplaceWaveNote("SMR_Qvec","BlankFolder",oldNoteValue) 
//			IN2G_AppendorReplaceWaveNote("SMR_Int","Kfactor",num2str(Kfactor)) 
//			IN2G_AppendorReplaceWaveNote("SMR_Error","Kfactor",num2str(Kfactor)) 
//			IN2G_AppendorReplaceWaveNote("SMR_Qvec","Kfactor",num2str(Kfactor)) 
//			IN2G_AppendorReplaceWaveNote("SMR_Int","Transmission",num2str(Transmission)) 
//			IN2G_AppendorReplaceWaveNote("SMR_Error","Transmission",num2str(Transmission)) 
//			IN2G_AppendorReplaceWaveNote("SMR_Qvec","Transmission",num2str(Transmission)) 
//		//end append data
//		AppendToGraph/R SMR_Int vs SMR_Qvec
//		Label right "SMR Intensity"
//		ModifyGraph lsize(SMR_Int)=2
//		ErrorBars SMR_Int Y,wave=(SMR_Error,SMR_Error)
//		ModifyGraph rgb(SMR_Int)=(0,0,0)
//		ModifyGraph log=1
//		ModifyGraph gaps=0
//
//		IN2G_AppendAnyText("Transmission :\t\t"+num2str(Transmission))
//		IN2G_AppendAnyText("SMR data created")
//
//		USAXSorSBUSAXS="USAXS"
//		
//	else
//		Duplicate /O R_Int, DSM_Int, logBlankInterp, BlankInterp
//		Duplicate/O BL_R_Int, logBlankR
//		logBlankR=log(BL_R_Int)
//		LogBlankInterp=interp(R_Qvec_shifted, BL_R_Qvec, logBlankR)
//		BlankInterp=10^LogBlankInterp
//		DSM_Int=(R_Int_corr - BlankInterp)/Kfactor
//		KillWaves/Z logBlankInterp, BlankInterp, logBlankR
//		Duplicate/O R_error, DSM_Error
//		Duplicate/O BL_R_error, log_BL_R_error
//		log_BL_R_error=log(abs(BL_R_error))
//		DSM_Error=sqrt((R_error)^2/Transmission^2 + (10^(interp(R_Qvec, BL_R_Qvec, log_BL_R_error)))^2)/Kfactor
//		KillWaves/Z log_BL_R_error
//		
//		Duplicate/O R_Qvec_shifted, DSM_Qvec
//			IN2G_AppendorReplaceWaveNote("DSM_Error","Wname","DSM_Error") 
//			IN2G_AppendorReplaceWaveNote("DSM_Int","Wname","DSM_Int") 
//			IN2G_AppendorReplaceWaveNote("DSM_Int","Units","cm-1")
//			IN2G_AppendorReplaceWaveNote("DSM_Qvec","Wname","DSM_Qvec") 
//			IN2G_AppendorReplaceWaveNote("DSM_Qvec","Units","A-1")
//
//		//append data to new waves
//			oldNoteValue=stringBykey("COMMENT", note(BL_R_Int), "=")
//			IN2G_AppendorReplaceWaveNote("DSM_Int","BlankComment",oldNoteValue) 
//			IN2G_AppendorReplaceWaveNote("DSM_Error","BlankComment",oldNoteValue) 
//			IN2G_AppendorReplaceWaveNote("DSM_Qvec","BlankComment",oldNoteValue) 
//			oldNoteValue=stringBykey("USAXSDataFolder", note(BL_R_Int), "=")
//			IN2G_AppendorReplaceWaveNote("DSM_Int","BlankFolder",oldNoteValue) 
//			IN2G_AppendorReplaceWaveNote("DSM_Error","BlankFolder",oldNoteValue) 
//			IN2G_AppendorReplaceWaveNote("DSM_Qvec","BlankFolder",oldNoteValue) 
//			IN2G_AppendorReplaceWaveNote("DSM_Int","Kfactor",num2str(Kfactor)) 
//			IN2G_AppendorReplaceWaveNote("DSM_Error","Kfactor",num2str(Kfactor)) 
//			IN2G_AppendorReplaceWaveNote("DSM_Qvec","Kfactor",num2str(Kfactor)) 
//			IN2G_AppendorReplaceWaveNote("DSM_Int","Transmission",num2str(Transmission)) 
//			IN2G_AppendorReplaceWaveNote("DSM_Error","Transmission",num2str(Transmission)) 
//			IN2G_AppendorReplaceWaveNote("DSM_Qvec","Transmission",num2str(Transmission)) 
//		//end append data
//		AppendToGraph/R DSM_Int vs DSM_Qvec
//		Label right "DSM Intensity"
//		ModifyGraph log=1
//		ErrorBars DSM_Int Y,wave=(DSM_Error,DSM_Error)
//		ModifyGraph lsize(DSM_Int)=2
//		ModifyGraph rgb(DSM_Int)=(0,0,0)
//		ModifyGraph gaps=0
//
//	IN2G_AppendAnyText("Transmission :\t\t"+num2str(Transmission))
//	IN2G_AppendAnyText("DSM data created, measurement was from SB USAXS setup")
//
//	USAXSorSBUSAXS="SBUSAXS"
//	endif
//	
//	IN2B_CalcCalibrationPrecision(USAXSorSBUSAXS)				//this calculates the calibration precision and puts it into the wavenotes
//
//end
//
//
//Function IN2B_SaveSMRWaveButton(ctrlname) : Buttoncontrol			//repeats macro
//		string ctrlname
//		
//		IN2G_WriteSetOfData("SMR")
//
////	string filename=IN2G_FixTheFileName()
////	WAVE SMR_Qvec
////	WAVE SMR_Int
////	WAVE SMR_Error
////	filename = filename+".smr"
////	if (exists("SMR_Int")==1)
////		Save/I/G/M="\r\n" SMR_Qvec,SMR_Int, SMR_Error as filename				///P=Datapath
////	else
////		DoAlert 0, "The SMR data do not exist, please create them first and then run macro again"		//here goes message
////	endif
//End
//
//Function IN2B_ContinueASB2(ctrlName): Buttoncontrol
//		string ctrlName
//			//kill graph		
//		String wName=WinName(0, 1)              // 1=graphs, 2=tables,4=layouts
//             dowindow /K $wName
//end
//
//Function IN2B_ASBFixTransmOrShift(ctrlName,varNum,varStr,varName) : SetVariableControl
//	String ctrlName
//	Variable varNum
//	String varStr
//	String varName
//
//	NVAR trans=transmission
//	NVAR Qshift
//	
//	WAVE R_Int
//	WAVE R_Int_corr
//	WAVE R_Qvec
//	WAVE R_Qvec_shifted
//	if (cmpstr(ctrlName,"Transmission")==0)
//		trans=varNum
//		R_Int_corr=R_Int/trans
//	endif
//	
//	if (cmpstr(ctrlName,"Qshift")==0)
//		Qshift=varNum
//		R_Qvec_shifted=R_Qvec-Qshift
//	endif
//End

//*****************************************************
//***********MSAXS Corretion
////*****************************************************
//Function IN2A_MSAXScorrection()
//
//	IN2A_CleanupAllWIndows()						//cleanup all open windows from Indra 2
//
//	KillWIndow/Z IN2A_MSAXSPanel
// 	KillWIndow/Z MSAXSCorrection
// 	IN2G_UniversalFolderScan("root:USAXS:", 5, "IN2G_CheckTheFolderName()")  //here we fix the folder names/sample names in wave notes if necessary
//	
//	String DataFolderName 
//	String NextMSAXSData=IN2A_NextMSAXSDataToEvaluate()
//	String NextSMRData=IN2G_FindFolderWithWaveTypes("root:USAXS:", 3, "SMR_Int", 1)
//	String NextDSMData=IN2G_FindFolderWithWaveTypes("root:USAXS:", 3, "DSM_Int", 1)
//	
//	Prompt DataFolderName, "Select data to calculate MSAXS correction for", popup,NextMSAXSData+";"+NextSMRData+";"+NextDSMData
//	
//	DoPrompt "MSAXS correction needs input:", DataFolderName
//
//	if (V_Flag)
//		Abort 
//	endif
//
//	IN2G_AppendAnyText("\rMSAXS data correction procedure started")
//	IN2G_AppendAnyText("Data : "+ DataFolderName)
//
//	if (!DataFolderExists("root:Packages:MSAXSCorrection:"))
//		NewDataFolder root:Packages:MSAXSCorrection		//create MSAXSCorrection folder, if it does not exist
//	endif
//
//	SetDataFolder root:Packages:MSAXSCorrection
//	NVAR/Z ApplyNoMSAXSCorr
//	NVAR/Z ApplyIntegralMSAXSCorr
//	NVAR/Z ApplyFWHMIntgMSAXSCorr
//	if (!NVAR_Exists(ApplyNoMSAXSCorr) || !NVAR_Exists(ApplyIntegralMSAXSCorr) || !NVAR_Exists(ApplyFWHMIntgMSAXSCorr))
//		variable/g ApplyNoMSAXSCorr
//		variable/g ApplyIntegralMSAXSCorr
//		variable/g ApplyFWHMIntgMSAXSCorr
//		ApplyNoMSAXSCorr=0
//		ApplyIntegralMSAXSCorr=0
//		ApplyFWHMIntgMSAXSCorr=0		
//	endif
//	string/G dataFolder=DataFolderName
//	
//	WAVE/Z Transm		//these two waves will contain the folders, which were evaluated and the results, which were obtained
//	WAVE/T/Z Folder		//then we can use these waves and make procedure, which will correct range of folders
//	Wave/Z Weight
//	Wave/Z CorrectWv
//	variable ResultsLength
//	if (!WaveExists(Transm))
//		Make/N=1 Transm
//		WAVE Transm
//		Make/T/N=1 Folder
//		WAVE/T Folder
//		Make/N=1 Weight
//		Wave Weight
////		Make/N=1 FWHMcorrection
////		Wave FWHMcorrection
//		Make/N=1 CorrectWv
//		Wave CorrectWv
//		ResultsLength=0
//	else
//		ResultsLength=numpnts(Transm)
//		Redimension/N=(ResultsLength+1) Transm
//		Redimension/N=(ResultsLength+1) Folder
//		Redimension/N=(ResultsLength+1) Weight
//		Redimension/N=(ResultsLength+1) CorrectWv
//	endif
//	
//	
//	NVAR Transmission1=$(DataFolderName+"Transmission")
//	variable/G Transmission=Transmission1
//	Variable/G M_transmission=0, IntegralIntensitySample=0, IntegralIntensityBlank=0, M_Qmax=0, M_Qmin=0, M_correction, FWHMcorrection
////	SetFormula M_transmission, "IntegralIntensitySample/IntegralIntensityBlank"
/////	SetFormula M_correction, "M_transmission/Transmission"
//
//	Execute ("IN2A_MSAXSPanel()")
//
//	string WaveNm=DataFoldername+"R_Int"
//	Duplicate/O $WaveNm, R_Int
//	WaveNm=DataFoldername+"R_Qvec"
//	Duplicate/O $WaveNm, R_Qvec
//	WaveNm=DataFoldername+"R_error"
//	Duplicate/O $WaveNm, R_error
//	WaveNm=DataFoldername+"BL_R_Int"
//	Duplicate/O $WaveNm, BL_R_Int
//	WaveNm=DataFoldername+"BL_R_Qvec"
//	Duplicate/O $WaveNm, BL_R_Qvec
//	WaveNm=DataFoldername+"BL_R_error"
//	Duplicate/O $WaveNm, BL_R_error
//	
//	variable FWHMsample=NumberByKey("FWHM", note(R_Int)  , "=" , ";")
//	variable FWHMBlank=NumberByKey("FWHM", note(BL_R_Int)  , "=" , ";")
//	
//	FWHMcorrection=FWHMsample/FWHMBlank
//	
//	SVAR EvalParam1=$(DataFolderName+"ListOfASBParameters")
//	string/G EvalParam=EvalParam1
//
//	string Calibrated=stringByKey("Calibrate", EvalParam,"=")
//
//	if (cmpstr(Calibrated[0,4],"USAXS")==0 ||cmpstr(Calibrated[0,1],"no")==0)
//		if ((ApplyNoMSAXSCorr + ApplyIntegralMSAXSCorr + ApplyFWHMIntgMSAXSCorr)!=1)
//			ApplyNoMSAXSCorr=0
//			ApplyIntegralMSAXSCorr=1
//			ApplyFWHMIntgMSAXSCorr=0	
//		endif	
//	else
//		if ((ApplyNoMSAXSCorr + ApplyIntegralMSAXSCorr + ApplyFWHMIntgMSAXSCorr)!=1)
//			ApplyNoMSAXSCorr=0
//			ApplyIntegralMSAXSCorr=0
//			ApplyFWHMIntgMSAXSCorr=1	
//		endif	
//	endif
//	
//	PauseUpdate //*************************Graph section**********************************
//
//	WaveStats/q R_Int
//	FindLevel/Q/R=(0,V_maxloc) R_Int, 0.01*V_max
//	variable StartPlot=0
//	If (V_Flag==0)
//		StartPlot=V_levelX
//	endif
//	FindLevel/R=(V_maxloc) R_Int, 0.01*V_max
//	variable EndPlot=V_levelX
//	
//	    
//
//	//Display/k=1 /W=(0.3*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("height"),60*IN2G_ScreenWidthHeight("width"),70*IN2G_ScreenWidthHeight("height")) R_Int vs R_Qvec as "Sample PD Intensity vs Q vector"						//plots intensity vs ar encoder
//	Display/k=1 /W=(0,0,IN2G_GetGraphWidthHeight("width"),IN2G_GetGraphWidthHeight("height")) R_Int vs R_Qvec as "Sample PD Intensity vs Q vector"						//plots intensity vs ar encoder
//	SetAxis bottom, R_Qvec[StartPlot]*1.2, R_Qvec[EndPlot]*3
//	DoWindow/C MSAXSCorrection
//	AppendToGraph/R BL_R_Int vs BL_R_Qvec
//
//	ModifyGraph mode=4
//	
//	Label left "Intensity sample"								//labels left axis
//	Label bottom "Q vector"									//labels bottom axis
//	Label right "Intensity blank"
//
//	cursor/P A, R_Int, StartPlot+1
//	cursor/P B, R_Int, EndPlot
//	
//	Button IntegrateSample pos={50,10}, size={130,25}, title="1. Integrate Sa.", proc=IN2A_IntegrateThePeak
//	Button IntegrateBlank pos={50,40}, size={130,25}, title="2. Integrate Blank", proc=IN2A_IntegrateThePeakBlank
//
//	CheckBox ApplyNoMSAXSCorr,pos={200,15},size={100,14},proc=IR1A_MSAXSPanelCheckboxProc,title="Apply no MSAXS correction? "
//	CheckBox ApplyNoMSAXSCorr,variable= root:Packages:MSAXSCorrection:ApplyNoMSAXSCorr, help={"Check to use peak height calculated transmission"}
//	CheckBox ApplyIntegralMSAXSCorr,pos={200,40},size={100,14},proc=IR1A_MSAXSPanelCheckboxProc,title="Apply Integral MSAXS corr? "
//	CheckBox ApplyIntegralMSAXSCorr,variable= root:Packages:MSAXSCorrection:ApplyIntegralMSAXSCorr, help={"Check to use transmission from integral intensities. "}
//	CheckBox ApplyFWHMIntgMSAXSCorr,pos={200,65},size={100,14},proc=IR1A_MSAXSPanelCheckboxProc,title="Apply full MSAXS correction?"
//	CheckBox ApplyFWHMIntgMSAXSCorr,variable= root:Packages:MSAXSCorrection:ApplyFWHMIntgMSAXSCorr, help={"Check to use Integral intensities transmission * FWHM correction. "}
//
//	Button CalcMSAXS pos={410,10}, size={130,25}, title="3. Correct Data", proc=IN2A_CorrectData
//	Button ExportMSAXS pos={410,40}, size={130,25}, title="(4.) Export M_xxx Data", proc=IN2A_ExportMSMR
//	Button RestarttMSAXS pos={410,70}, size={130,25}, title="5. Cont. Another sa.", proc=IN2A_RestartMSMR
//
//	ModifyGraph/Z margin(top)=100
//	ModifyGraph/Z mode=4, gaps=0
//	ModifyGraph/Z mirror(bottom)=1
//	ModifyGraph/Z font="Times New Roman"
//	ModifyGraph/Z minor=1
//	ModifyGraph/Z fSize=12
//	
//	IN2G_GenerateLegendForGraph(10,0,1)
//	ResumeUpdate   //*************************Graph section**********************************
//	ModifyGraph width=0, height=0
//
//	IN2G_AutoAlignGraphAndPanel()
//
//	if (cmpstr(Calibrated[0,4],"USAXS")==0 ||cmpstr(Calibrated[0,1],"no")==0)
//		//CheckBox ApplyNoMSAXSCorr,disable=1,win=MSAXSCorrection
//		//CheckBox ApplyIntegralMSAXSCorr,disable=1,win=MSAXSCorrection
//		CheckBox ApplyFWHMIntgMSAXSCorr,disable=1,win=MSAXSCorrection
//	endif
//end
//
//
//Function IR1A_MSAXSRecalcCorrection()
//
//	NVAR ApplyNoMSAXSCorr=root:Packages:MSAXSCorrection:ApplyNoMSAXSCorr
//	NVAR ApplyIntegralMSAXSCorr=root:Packages:MSAXSCorrection:ApplyIntegralMSAXSCorr
//	NVAR ApplyFWHMIntgMSAXSCorr=root:Packages:MSAXSCorrection:ApplyFWHMIntgMSAXSCorr
//
//	NVAR Transmission=root:Packages:MSAXSCorrection:Transmission
//	NVAR M_transmission=root:Packages:MSAXSCorrection:M_transmission
//	NVAR IntegralIntensitySample=root:Packages:MSAXSCorrection:IntegralIntensitySample
//	NVAR IntegralIntensityBlank=root:Packages:MSAXSCorrection:IntegralIntensityBlank
//	 
//	NVAR M_correction=root:Packages:MSAXSCorrection:M_correction
//	NVAR FWHMcorrection=root:Packages:MSAXSCorrection:FWHMcorrection
//	SVAR EvalParam=root:Packages:MSAXSCorrection:EvalParam
//
//	string Calibrated=stringByKey("Calibrate", EvalParam,"=")
//	variable testCorrectness
//
//	if (cmpstr(Calibrated[0,1],"no")==0)
//		Abort "This procedure makes no sense for uncalibrated data"
//	endif
//	if (cmpstr(Calibrated[0,4],"USAXS")==0)
//		if (IntegralIntensitySample>0 && IntegralIntensityBlank>0)
//		//now wait, two options are here...
//			testCorrectness = ApplyNoMSAXSCorr+ApplyIntegralMSAXSCorr
//			if(testCorrectness!=1)
//				Abort "Correcting method weird, this is debug message, contact me, Jan"
//			endif
//			if(ApplyNoMSAXSCorr)
//				M_transmission = Transmission
//				M_correction = M_transmission/Transmission
//			endif
//			if(ApplyIntegralMSAXSCorr)
//				M_transmission = IntegralIntensitySample/IntegralIntensityBlank
//				M_correction = M_transmission/Transmission
//			endif
//		endif
//	endif
//	if (cmpstr(Calibrated[0,6],"SBUSAXS")==0)
//	//now wait, three options are here...
//	testCorrectness = ApplyNoMSAXSCorr+ApplyIntegralMSAXSCorr+ApplyFWHMIntgMSAXSCorr
//		if (IntegralIntensitySample>0 && IntegralIntensityBlank>0)
//			if(testCorrectness!=1)
//				Abort "Correcting method weird, this is debug message, contact me, Jan"
//			endif
//			if(ApplyNoMSAXSCorr)
//				M_transmission = Transmission
//				M_correction = M_transmission/Transmission
//			endif
//			if(ApplyIntegralMSAXSCorr)
//				M_transmission = IntegralIntensitySample/IntegralIntensityBlank
//				M_correction = M_transmission/Transmission
//			endif
//			if(ApplyFWHMIntgMSAXSCorr)
//				M_transmission = IntegralIntensitySample/IntegralIntensityBlank
//				M_transmission = M_transmission * FWHMcorrection
//				M_correction = M_transmission/Transmission
//			endif
//		endif
//	endif
//end
//
//
//
//Function IR1A_MSAXSPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
//	String ctrlName
//	Variable checked
//	
//		NVAR ApplyNoMSAXSCorr=root:Packages:MSAXSCorrection:ApplyNoMSAXSCorr
//		NVAR ApplyIntegralMSAXSCorr=root:Packages:MSAXSCorrection:ApplyIntegralMSAXSCorr
//		NVAR ApplyFWHMIntgMSAXSCorr=root:Packages:MSAXSCorrection:ApplyFWHMIntgMSAXSCorr
//
//	if (cmpstr(ctrlName,"ApplyNoMSAXSCorr")==0)
//		if(checked)
//			//ApplyNoMSAXSCorr=0
//			ApplyIntegralMSAXSCorr=0
//			ApplyFWHMIntgMSAXSCorr=0
//		else
//			if(!ApplyIntegralMSAXSCorr && !ApplyFWHMIntgMSAXSCorr)
//				ApplyIntegralMSAXSCorr=1
//			endif
//		endif
//	endif
//
//	if (cmpstr(ctrlName,"ApplyIntegralMSAXSCorr")==0)
//		if(checked)
//			ApplyNoMSAXSCorr=0
//			//ApplyIntegralMSAXSCorr=0
//			ApplyFWHMIntgMSAXSCorr=0
//		else
//			if(!ApplyNoMSAXSCorr && !ApplyFWHMIntgMSAXSCorr)
//				ApplyNoMSAXSCorr=1
//			endif
//		endif
//	endif
//	if (cmpstr(ctrlName,"ApplyFWHMIntgMSAXSCorr")==0)
//		if(checked)
//			ApplyNoMSAXSCorr=0
//			ApplyIntegralMSAXSCorr=0
//			//ApplyFWHMIntgMSAXSCorr=0
//		else
//			if(!ApplyNoMSAXSCorr && !ApplyIntegralMSAXSCorr)
//				ApplyIntegralMSAXSCorr=1
//			endif
//		endif
//	endif
//	IR1A_MSAXSRecalcCorrection()
//end
//
//Function/T IN2A_NextMSAXSDataToEvaluate()					//this returns next USAXS sample in order to evaluate 
//
//	string oldDf=GetDataFolder(1)
//	
//	if (DataFolderExists("root:Packages:MSAXSCorrection:"))		//the folder exists, we may have already used the procedure
//		setDataFolder root:Packages:MSAXSCorrection:
//		
//		string DSMList=WaveList("*DSM*",";","")
//		string SMRList=WaveList("*SMR*",";","")
//		if ((strlen(DSMList)+strlen(SMRList))==0)
//			return ""			//this was called from Anis MSAXS, nothing done prior
//		endif
//		string ListOfData=""
//		variable start=0
//		
//		if (strlen(DSMList)!=0)					//last tiem we have done DSM waves
//			ListOfData=IN2G_FindFolderWithWaveTypes("root:USAXS:", 3, "DSM_Int", 1)
//			SVAR LastASB=root:Packages:MSAXSCorrection:DataFolder		//global string for current folder info
//			start=FindListItem(LastASB,ListOfData)
//			ListOfdata=ListOfData[start,inf]
//			IN2G_KillWavesFromList(DSMList)
//			setDataFolder $oldDf
//			return StringFromList(1,ListOfdata)
//		else													//last time we have done SMR waves
//			ListOfData=IN2G_FindFolderWithWaveTypes("root:USAXS:", 3, "SMR_Int", 1)
//			SVAR LastASB=root:Packages:MSAXSCorrection:DataFolder		//global string for current folder info
//			start=FindListItem(LastASB,ListOfData)
//			ListOfdata=ListOfData[start,inf]
//			IN2G_KillWavesFromList(SMRList)
//			setDataFolder $oldDf
//			return StringFromList(1,ListOfdata)
//		endif
//	else
//		return " "
//	endif
//end
//
//
//
//Function IN2A_ExportMSMR(ctrlname) : Buttoncontrol	//calls export function
//	string ctrlname
//	SVAR EvalParam	
//	SVAR dataFolder
//	
//	string df=GetDataFolder(1)
//	
//	setDataFolder $dataFolder
//	
//	string Calibrated=stringByKey("Calibrate", EvalParam,"=")	//figure out, what data are we exporting
//
//	if (cmpstr(Calibrated[0,4],"USAXS")==0)		//USAXS data = SMR, actually M_SMR
//		IN2G_WriteSetOfData("M_SMR")
//	endif
//	if (cmpstr(Calibrated[0,6],"SBUSAXS")==0)		//SBUSAXS, data are M_DSM
//		IN2G_WriteSetOfData("M_DSM")
//	endif
//	
//	setDataFolder $df
//end
//
//Function IN2A_RestartMSMR(ctrlname) : Buttoncontrol			// calls the repeat function fit
//	string ctrlname
//
// 	KillWIndow/Z MSAXSCorrection
// 	IN2A_MSAXScorrection()
//End
//
//
//Window IN2A_MSAXSPanel() : Panel
//	setDataFolder root:Packages:MSAXSCorrection
//	 
//	if (strlen(WinList("IN2A_MSAXSPanel",";","WIN:64"))>0)
//			KillWIndow/Z IN2A_MSAXSPanel
//	endif
//	PauseUpdate    		// building window...
//	NewPanel/k=1 /W=(738.75,52.25,1120,311) as "MSAXS corrections"
//	SetVariable SampleIntensity,pos={22,22},size={283,18},title="Int. Intensity sample", help={"Calcualted integral intensity"}
//	SetVariable SampleIntensity,limits={0,Inf,1},value= root:Packages:MSAXSCorrection:IntegralIntensitySample
//	SetVariable BlankIntensity,pos={25,52},size={285,18},title="Int. Intensity Blank", help={"Calcualted integral intensity blank"}
//	SetVariable BlankIntensity,limits={0,Inf,1},value= root:Packages:MSAXSCorrection:IntegralIntensityBlank
//	SetVariable Qmax,pos={27,105},size={241,18},title="Q max  ", help={"Used Q max"}
//	SetVariable Qmax,limits={-Inf,Inf,1},value= root:Packages:MSAXSCorrection:M_Qmax
//	SetVariable Qmin,pos={28,140},size={241,18},title="Q min", help={"Minimum Q provided by user. Integral is caculated using +/- abs(Qmax) anyway..."}
//	SetVariable Qmin,limits={-Inf,Inf,1},value= root:Packages:MSAXSCorrection:M_Qmin
//	SetVariable Mtrans,pos={24,177},size={325,18},proc=IR1A_MSAXSRecalcCorrectionUser, title="Apparent MSAXS transm. coef"
//	SetVariable Mtrans,limits={0,3,0.01},value= root:Packages:MSAXSCorrection:M_transmission, help={"Transmission calculated by the code. You can overwwrite it..."}
//	SetVariable Mcorr,pos={24,200},size={325,18},proc=IR1A_MSAXSRecalcCorrectionUser,title="coef to correct for MSAXS"
//	SetVariable Mcorr,limits={0,1000,1},value= root:Packages:MSAXSCorrection:M_correction, help={"Correction from above transmission. You can ovewrite it and the transmission will be changed..."}
//EndMacro
//
//Function IR1A_MSAXSRecalcCorrectionUser(ctrlName,varNum,varStr,varName) : SetVariableControl
//	String ctrlName
//	Variable varNum
//	String varStr
//	String varName
//
//	NVAR M_transmission=root:Packages:MSAXSCorrection:M_transmission
//	NVAR M_correction=root:Packages:MSAXSCorrection:M_correction
//	NVAR Transmission=root:Packages:MSAXSCorrection:Transmission
//
//	if (cmpstr(ctrlName,"Mtrans")==0)
//		M_correction = M_transmission/Transmission
//	endif
//	if (cmpstr(ctrlName,"Mcorr")==0)
//		M_transmission = Transmission*M_correction
//	endif
//end
//
//
//
//
//Function IN2A_IntegrateThePeak(ctrlname) : Buttoncontrol			// calls the repeat function fit
//	string ctrlname
//		
//	Wave R_Int
//	Wave R_Qvec	
//	NVAR M_Qmin
//	NVAR M_Qmax
//	NVAR IntegralIntensitySample
//	SVAR EvalParam
//
//	string Calibrated=stringByKey("Calibrate", EvalParam,"=")
//
//	if (cmpstr(Calibrated[0,4],"USAXS")==0)
//
//		M_Qmin=WaveRefIndexed("",0,2)[xcsr(A)]
//		M_Qmax=WaveRefIndexed("",0,2)[xcsr(B)]
//		IntegralIntensitySample= areaXY( R_Qvec,R_Int,  -M_Qmin, M_Qmax)
//		IntegralIntensitySample=IntegralIntensitySample+ areaXY( R_Qvec,R_Int,  M_Qmin, M_Qmax)
//	endif
//	
//	if (cmpstr(Calibrated[0,6],"SBUSAXS")==0)
//		M_Qmin=WaveRefIndexed("",0,2)[xcsr(A)]
//		M_Qmax=WaveRefIndexed("",0,2)[xcsr(B)]
//
//	//	duplicate R_Int, QRsample
//	//	QRsample=QRsample*abs(R_Qvec)
//	//	IntegralIntensitySample= areaXY( R_Qvec,QRsample,  -M_Qmin, M_Qmax)
//	//	IntegralIntensitySample= IntegralIntensitySample+areaXY( R_Qvec,QRsample,  M_Qmin, M_Qmax)
//	//modified after discussion with Andrew, for small MSAXS cases this is better approximation
//		IntegralIntensitySample= areaXY( R_Qvec,R_Int,  -M_Qmin, M_Qmax)
//		IntegralIntensitySample= IntegralIntensitySample+areaXY( R_Qvec,R_Int,  M_Qmin, M_Qmax)
//	//	Killwaves QRsample
//	endif
//
//	if (cmpstr(Calibrated[0,1],"no")==0)
//		DoAlert 0, "This function cannot be applied on uncalibrated data"
//	endif
//	
//	SetVariable Mtrans,win=IN2A_MSAXSPanel,value= M_transmission
//	SetVariable Mcorr,win=IN2A_MSAXSPanel,value= M_correction
//
//	//recalculate the transmission, if possible
//	IR1A_MSAXSRecalcCorrection()
//End
//
//Function IN2A_IntegrateThePeakBlank(ctrlname) : Buttoncontrol			// calls the repeat function fit
//	string ctrlname
//	
//	Wave BL_R_Int
//	Wave BL_R_Qvec	
//	NVAR M_Qmin
//	NVAR M_Qmax
//	NVAR IntegralIntensityBlank
//	SVAR EvalParam
//	
//	string Calibrated=stringByKey("Calibrate", EvalParam,"=")
//
//	if (cmpstr(Calibrated[0,4],"USAXS")==0)
//		M_Qmin=WaveRefIndexed("",0,2)[xcsr(A)]
//		M_Qmax=WaveRefIndexed("",0,2)[xcsr(B)]
//		IntegralIntensityBlank= areaXY( BL_R_Qvec,BL_R_Int,  -M_Qmin, M_Qmax)
//		IntegralIntensityBlank= IntegralIntensityBlank+areaXY( BL_R_Qvec,BL_R_Int,  M_Qmin, M_Qmax)
//	endif
//	if (cmpstr(Calibrated[0,6],"SBUSAXS")==0)
//		M_Qmin=WaveRefIndexed("",0,2)[xcsr(A)]
//		M_Qmax=WaveRefIndexed("",0,2)[xcsr(B)]
//
//	//	duplicate BL_R_Int, QRblank
//	//	QRblank=BL_R_Int*abs(BL_R_Qvec)
//	//	IntegralIntensityBlank= areaXY( BL_R_Qvec,QRblank,  -M_Qmin, M_Qmax)
//	//	IntegralIntensityBlank= IntegralIntensityBlank+areaXY( BL_R_Qvec,QRblank,  M_Qmin, M_Qmax)
//	//same as above for IntegrateSample
//		IntegralIntensityBlank= areaXY( BL_R_Qvec,BL_R_Int,  -M_Qmin, M_Qmax)
//		IntegralIntensityBlank= IntegralIntensityBlank+areaXY( BL_R_Qvec,BL_R_Int,  M_Qmin, M_Qmax)
//	//	Killwaves QRBlank
//	endif
//	if (cmpstr(Calibrated[0,1],"no")==0)
//		DoAlert 0, "This function cannot be applied on uncalibrated data"
//	endif
//
//	SetVariable Mtrans,win=IN2A_MSAXSPanel,value= M_transmission
//	SetVariable Mcorr,win=IN2A_MSAXSPanel,value= M_correction
//
//	//recalculate the transmission, if possible
//	IR1A_MSAXSRecalcCorrection()
//
//End
//
//
//
//Function IN2A_CorrectData(ctrlname) : Buttoncontrol			// calls the repeat function fit
//	string ctrlname
//	
//	SVAR dataFolder
//		
//	NVAR M_correction
//	SVAR EvalParam
//	
//	string Calibrated=stringByKey("Calibrate", EvalParam,"=")
//
//	if (cmpstr(Calibrated[0,4],"USAXS")==0)			//OK, the data are suppose to be USAXS, therefore we should be working on SMR data
//		Wave SMR_Int=$(dataFolder+"SMR_Int")
//		Wave SMR_Qvec=$(dataFolder+"SMR_Qvec")
//		Wave SMR_Error	=$(dataFolder+"SMR_Error")
//		Duplicate/O SMR_Int, M_SMR_Int
//		Duplicate/O SMR_Qvec, M_SMR_Qvec
//		Duplicate/O SMR_Error, M_SMR_Error
//			IN2G_AppendorReplaceWaveNote("M_SMR_Error","Wname","M_SMR_Error") 
//			IN2G_AppendorReplaceWaveNote("M_SMR_Int","Wname","M_SMR_Int") 
//			IN2G_AppendorReplaceWaveNote("M_SMR_Qvec","Wname","M_SMR_Qvec") 
//		
//		M_SMR_Int=SMR_Int/M_correction
//		M_SMR_Error=SMR_Error/M_correction
//	
//		//nakonec musime zkorigovat data zpet ve folderu, odkud data pochazi...
//	
//		IN2G_AppendorReplaceWaveNote("M_SMR_Int","MSAXSCorrection",num2str(M_correction))
//		IN2G_AppendorReplaceWaveNote("M_SMR_Qvec","MSAXSCorrection",num2str(M_correction))
//		IN2G_AppendorReplaceWaveNote("M_SMR_Error","MSAXSCorrection",num2str(M_correction))
//		
//		Duplicate/O M_SMR_Int, $(dataFolder+"M_SMR_Int")
//		Duplicate/O M_SMR_Qvec, $(dataFolder+"M_SMR_Qvec")
//		Duplicate/O M_SMR_Error, $(dataFolder+"M_SMR_Error")
//
//	IN2G_AppendAnyText("MSAXS data applied, correction :"+num2str(M_correction))
//	IN2G_AppendAnyText("Note, that the data are now in M_SMR_??? waves")
//
//	endif
//	
//	if (cmpstr(Calibrated[0,6],"SBUSAXS")==0)
//		Wave DSM_Int=$(dataFolder+"DSM_Int")
//		Wave DSM_Qvec=$(dataFolder+"DSM_Qvec")
//		Wave DSM_Error	=$(dataFolder+"DSM_Error")
//		Duplicate/O DSM_Int, M_DSM_Int
//		Duplicate/O DSM_Qvec, M_DSM_Qvec
//		Duplicate/O DSM_Error, M_DSM_Error
//			IN2G_AppendorReplaceWaveNote("M_DSM_Error","Wname","M_DSM_Error") 
//			IN2G_AppendorReplaceWaveNote("M_DSM_Int","Wname","M_DSM_Int") 
//			IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","Wname","M_DSM_Qvec") 
//			
//		M_DSM_Int=DSM_Int/M_correction
//		M_DSM_Error=DSM_Error/M_correction
//	
//		//nakonec musime zkorigovat data zpet ve folderu, odkud data pochazi...
//	
//		IN2G_AppendorReplaceWaveNote("M_DSM_Int","MSAXSCorrection",num2str(M_correction))
//		IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","MSAXSCorrection",num2str(M_correction))
//		IN2G_AppendorReplaceWaveNote("M_DSM_Error","MSAXSCorrection",num2str(M_correction))
//		
//		Duplicate/O M_DSM_Int, $(dataFolder+"M_DSM_Int")
//		Duplicate/O M_DSM_Qvec, $(dataFolder+"M_DSM_Qvec")
//		Duplicate/O M_DSM_Error, $(dataFolder+"M_DSM_Error")
//
//	IN2G_AppendAnyText("MSAXS data applied, correction :"+num2str(M_correction))
//	IN2G_AppendAnyText("Note, that the data are now in M_DSM_??? waves")
//
//	endif
//	//and here we record, what was done
//	
//	WAVE Transm		
//	WAVE/T Folder
//	Wave weight
//	Wave CorrectWv
//	NVAR M_transmission		
//	variable ResultsLength
//	ResultsLength=numpnts(Transm)-1		//set to last point number
//
//	Folder[ResultsLength]=dataFolder		//here we record, which data are being evaluated	
//	Weight[ResultsLength]=1
//	CorrectWv[ResultsLength]=1
//	Transm[ResultsLength]=M_Transmission	//and here is the resultting correction
//	IN2G_AppendorReplaceWaveNote("Transm","MSAXSDataType",stringByKey("Calibrate", EvalParam,"="))
//	
//End
//
//
//
//Function IN2A_MSAXSAverageCorr()
//		//this function uses results from single evaluations of the MSAXS Correction which
//		//puts results into MSAXSResults and MSAXSFolders
//		//here we calculate first average correction and then go in each folder
//		//and in that folder we recalculate the M_xxx data from their orginal by using avearage 
//		//MSAXS correction
//		
//		//the MSAXSResults and MSAXSFolder can be eddited before running this procedure
//		// they are in root:Packages:MSAXSCorrection folder...
//		
//	if (!DataFolderExists("root:Packages:MSAXSCorrection:"))
//		DoAlert 0,"The MSAXS folder does not exist..."
//		Abort
//	endif
//
//	setDataFolder root:Packages:MSAXSCorrection:
//	
//	WAVE Transm
//	WAVE/T Folder
//	variable numOfFolders=numpnts(Transm), i
//	variable AverageMSAXSTransmission=mean(Transm,-inf,+inf)
//	
//	string CurrentFolder=""
//	string DataType=""
//	Variable TempTransmission, AverageMSAXSCorr
//	
//	Prompt AverageMSAXSTransmission, "Correct the data in Folder list to MSAXS transmission (cancel to stop) :"
//	
//	DoPrompt "Choose MSAXS transmission", AverageMSAXSTransmission
//	
//	//DoAlert 1, "Correct data to average MSAXS transmission  "+num2str(AverageMSAXSTransmission) +"   for all folders in the list?" 
//	
//	if (V_flag==1)
//		Abort
//	endif
//	
//	for(i=0;i<numOfFolders;i+=1)	
//	
//		CurrentFolder=Folder[i]
//
//		//************************************************		 
//		 
//		Wave SMR_Int=$(CurrentFolder+"SMR_Int")
//		Wave SMR_Qvec=$(CurrentFolder+"SMR_Qvec")
//		Wave SMR_Error	=$(CurrentFolder+"SMR_Error")
//		Wave DSM_Int=$(CurrentFolder+"DSM_Int")
//		Wave DSM_Qvec=$(CurrentFolder+"DSM_Qvec")
//		Wave DSM_Error	=$(CurrentFolder+"DSM_Error")
//		
//		TempTransmission=NumberByKey("Transmission", note(DSM_Int) ,"=")
//		Wave MSAXSTransmissions
//		if (cmpstr(stringByKey("MSAXSDataType",note(MSAXSTransmissions),"="),"USAXS")==0)			//OK, the data are suppose to be USAXS, therefore we should be working on SMR data
//			DoAlert 0, "These data are from USAXS config., this does not make sense"
//			Abort
//
//					//		Duplicate/O SMR_Int, M_SMR_Int
//					//		Duplicate/O SMR_Qvec, M_SMR_Qvec
//					//		Duplicate/O SMR_Error, M_SMR_Error
//					//			IN2G_AppendorReplaceWaveNote("M_SMR_Error","Wname","M_SMR_Error") 
//					//			IN2G_AppendorReplaceWaveNote("M_SMR_Int","Wname","M_SMR_Int") 
//					//			IN2G_AppendorReplaceWaveNote("M_SMR_Qvec","Wname","M_SMR_Qvec") 
//					//		
//					//		M_SMR_Int=SMR_Int/M_correction
//					//		M_SMR_Error=SMR_Error/M_correction
//					//	
//					//		//nakonec musime zkorigovat data zpet ve folderu, odkud data pochazi...
//					//	
//					//		IN2G_AppendorReplaceWaveNote("M_SMR_Int","MSAXSCorrection",num2str(M_correction))
//					//		IN2G_AppendorReplaceWaveNote("M_SMR_Qvec","MSAXSCorrection",num2str(M_correction))
//					//		IN2G_AppendorReplaceWaveNote("M_SMR_Error","MSAXSCorrection",num2str(M_correction))
//					//		
//					//		Duplicate/O M_SMR_Int, $(dataFolder+"M_SMR_Int")
//					//		Duplicate/O M_SMR_Qvec, $(dataFolder+"M_SMR_Qvec")
//					//		Duplicate/O M_SMR_Error, $(dataFolder+"M_SMR_Error")
//					//
//					//	IN2G_AppendAnyText("MSAXS data applied, correction :"+num2str(M_correction))
//					//	IN2G_AppendAnyText("Note, that the data are now in M_SMR_??? waves")
//
//		endif
//	
//		if (cmpstr(stringByKey("MSAXSDataType",note(MSAXSTransmissions),"="),"SBUSAXS")==0)
//			Duplicate/O DSM_Int, M_DSM_Int
//			Duplicate/O DSM_Qvec, M_DSM_Qvec
//			Duplicate/O DSM_Error, M_DSM_Error
//			IN2G_AppendorReplaceWaveNote("M_DSM_Error","Wname","M_DSM_Error") 
//			IN2G_AppendorReplaceWaveNote("M_DSM_Int","Wname","M_DSM_Int") 
//			IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","Wname","M_DSM_Qvec") 
//	///is this correct?		
//	//M_transm=IntSa/IntBl, it is averaged over whole set of measurements
//	//M_correFactor=M_transm/Transmission
//	//M_DSM_Int=DSM_Int/M_CorreFactor
//	
//			averageMSAXSCorr=AverageMSAXSTransmission/TempTransmission
//			
//			M_DSM_Int=DSM_Int/averageMSAXSCorr
//			M_DSM_Error=DSM_Error/averageMSAXSCorr
//			
//	
//			//nakonec musime zkorigovat data zpet ve folderu, odkud data pochazi...
//	
//			IN2G_AppendorReplaceWaveNote("M_DSM_Int","AverageMSAXSCorrection",num2str(AverageMSAXSCorr))
//			IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","AverageMSAXSCorrection",num2str(AverageMSAXSCorr))
//			IN2G_AppendorReplaceWaveNote("M_DSM_Error","AverageMSAXSCorrection",num2str(AverageMSAXSCorr))
//			IN2G_AppendorReplaceWaveNote("M_DSM_Int","OriginalMSAXSTransmission",num2str(Transm[i]))
//			IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","OriginalMSAXSTransmission",num2str(Transm[i]))
//			IN2G_AppendorReplaceWaveNote("M_DSM_Error","OriginalMSAXSTransmission",num2str(Transm[i]))
//		
//			Duplicate/O M_DSM_Int, $(CurrentFolder+"M_DSM_Int")
//			Duplicate/O M_DSM_Qvec, $(CurrentFolder+"M_DSM_Qvec")
//			Duplicate/O M_DSM_Error, $(CurrentFolder+"M_DSM_Error")
//
//			IN2G_AppendAnyText("  ")
//			IN2G_AppendAnyText("On MSAXS data in folder:  "+CurrentFolder)
//			IN2G_AppendAnyText("Applied, average  correction :"+num2str(AverageMSAXSCorr))
//		endif	 
//	endfor									
//			IN2G_AppendAnyText("Note, that the data are now in M_DSM_??? waves")
//		
//end
//
//
//*************************************************************************
//*************************************************************************
//New Average MSAXS function
//
//Function IN2A_AnisotropicMSAXS()
//	//this is new anisotropic MSAXS procedure to replace the previous IN2_MSAXSAverageCorr()
//	
//	IN2A_AMSAXS_Intitialize()
//	
//	KillWIndow/Z IN2A_AMSAXSTable
// 	Execute ("IN2A_AMSAXSTable()")
//
//	KillWIndow/Z IN2A_AMSAXS_Panel
// 	Execute ("IN2A_AMSAXS_Panel()")
//	
//	
//
//end
//
////**************************************************************************************************
////**************************************************************************************************
////**************************************************************************************************
////**************************************************************************************************
//Function IN2A_AMSAXS_AveTransm(Tran,Wght)
//	wave Tran, Wght
//	
//	//OK, now the question is how do we calculate proper average MSAXS transmission
//	//if weight =0, skip the number and do not count it in...
//	
//	if (numpnts(Tran)!=numpnts(Wght))
//		abort "error in wave lengths"
//	endif
//	
//	variable i=0, numNonZeros=0
//	variable imax=numpnts(Tran)
//	variable resultTW=0, resultW
//	
//	for (i=0;i<imax;i+=1)
//		if (Wght[i]!=0)
//			resultTW+=Tran[i]*Wght[i]
//			resultW+=Wght[i]
//			numNonZeros+=1
//		endif
//	endfor
//	return (resultTW/resultW)
//end
//
//
//Function IN2A_AMSAXSCorrection()
//		
//	setDataFolder root:Packages:MSAXSCorrection:
//	
//	WAVE Transm
//	WAVE/T Folder
//	Wave Weight
////	Wave FWHMcorrection
//	Wave CorrectWv
//	NVAR AverageMSAXSCorr
//	variable numOfFolders=numpnts(Transm), i
//	variable AverageMSAXSTransmission=AverageMSAXSCorr		//IN2A_AMSAXS_AveTransm(Transm,Weight)
//	//this should accept any number through panel...
//	
//	string CurrentFolder=""
//	string DataType=""
//	Variable TempTransmission, AverageMSAXSCorrLoc
//	
//	for(i=0;i<numOfFolders;i+=1)	
//		if (CorrectWv[i]!=0)
//			CurrentFolder=Folder[i]
//	
//			//************************************************		 
//			 
////			Wave SMR_Int=$(CurrentFolder+"SMR_Int")
////			Wave SMR_Qvec=$(CurrentFolder+"SMR_Qvec")
////			Wave SMR_Error	=$(CurrentFolder+"SMR_Error")
//				Wave DSM_Int=$(CurrentFolder+"DSM_Int")
//				Wave DSM_Qvec=$(CurrentFolder+"DSM_Qvec")
//				Wave DSM_Error	=$(CurrentFolder+"DSM_Error")
//		
//			TempTransmission=NumberByKey("Transmission", note(DSM_Int) ,"=")
//		
//			if (cmpstr(stringByKey("MSAXSDataType",note(Transm),"="),"USAXS")==0)			//OK, the data are suppose to be SBUSAXS
//				DoAlert 0, "These data are from USAXS config., this does not make sense"
//				Abort
//			endif
//		
//			if (cmpstr(stringByKey("MSAXSDataType",note(Transm),"="),"SBUSAXS")==0)
//				Duplicate/O DSM_Int, M_DSM_Int
//				Duplicate/O DSM_Qvec, M_DSM_Qvec
//				Duplicate/O DSM_Error, M_DSM_Error
//				IN2G_AppendorReplaceWaveNote("M_DSM_Error","Wname","M_DSM_Error") 
//				IN2G_AppendorReplaceWaveNote("M_DSM_Int","Wname","M_DSM_Int") 
//				IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","Wname","M_DSM_Qvec") 
//		///is this correct?		
//		//M_transm=IntSa/IntBl, it is averaged over whole set of measurements
//		//M_correFactor=M_transm/Transmission
//		//M_DSM_Int=DSM_Int/M_CorreFactor
//		
//				averageMSAXSCorrLoc=AverageMSAXSTransmission/TempTransmission
//				
//				M_DSM_Int=DSM_Int/averageMSAXSCorrLoc
//				M_DSM_Error=DSM_Error/averageMSAXSCorrLoc
//				
//		
//				//nakonec musime zkorigovat data zpet ve folderu, odkud data pochazi...
//		
//				IN2G_AppendorReplaceWaveNote("M_DSM_Int","AverageMSAXSCorrection",num2str(AverageMSAXSCorrLoc))
//				IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","AverageMSAXSCorrection",num2str(AverageMSAXSCorrLoc))
//				IN2G_AppendorReplaceWaveNote("M_DSM_Error","AverageMSAXSCorrection",num2str(AverageMSAXSCorrLoc))
//				IN2G_AppendorReplaceWaveNote("M_DSM_Int","OriginalMSAXSTransmission",num2str(Transm[i]))
//				IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","OriginalMSAXSTransmission",num2str(Transm[i]))
//				IN2G_AppendorReplaceWaveNote("M_DSM_Error","OriginalMSAXSTransmission",num2str(Transm[i]))
//			
//				Duplicate/O M_DSM_Int, $(CurrentFolder+"M_DSM_Int")
//				Duplicate/O M_DSM_Qvec, $(CurrentFolder+"M_DSM_Qvec")
//				Duplicate/O M_DSM_Error, $(CurrentFolder+"M_DSM_Error")
//	
//				IN2G_AppendAnyText("  ")
//				IN2G_AppendAnyText("On MSAXS data in folder:  "+CurrentFolder)
//				IN2G_AppendAnyText("Applied, average  correction :"+num2str(AverageMSAXSCorrLoc))
//			endif	 
//		endif
//	endfor									
//			IN2G_AppendAnyText("Note, that the data are now in M_DSM_??? waves")
//			DoAlert 0, "Correction of the selected FOlders done!"
//		
//end
//
////******************************************************************************************
////******************************************************************************************
////******************************************************************************************
////******************************************************************************************
//
//Function IN2A_AMSAXS_Btn(ctrlName) : ButtonControl
//	String ctrlName
//
//		Wave/T Folder
//		Wave CorrectWv
//		Wave Transm
////		Wave FWHMcorrection
//		Wave Weight
//		NVAR AverageMSAXSCorr
//
//	if (cmpstr(ctrlName,"SortWaves")==0)
//		//sort waves alphabetically
//		sort Folder, Folder, Transm, Weight, CorrectWv
//	endif
//
//
//	if (cmpstr(ctrlName,"CheckTransm")==0)
//		//recalc transmission
//		AverageMSAXSCorr=IN2A_AMSAXS_AveTransm(Transm,Weight)
//		//AverageMSAXSCorr=IN2A_AMSAXS_AveTransm(Transm,Weight, FWHMcorrection)
//	endif
//	
//	if (cmpstr(ctrlName,"SingleSectors")==0)
//		//call single sector procedure here, same as in the menu
//		IN2A_MSAXScorrection()
//	endif
//	if (cmpstr(ctrlName,"Correct")==0)
//		//correct the results
//		IN2A_AMSAXSCorrection()
//	endif
//	if (cmpstr(ctrlName,"Reset")==0)
//		//reset the waves for the results
//		IN2A_ResetAMSAXS()
//	endif
//
//End
//
////**************************************************************************************************
////**************************************************************************************************
////**************************************************************************************************
////**************************************************************************************************
//
//Function IN2A_ResetAMSAXS()
//		
//		Wave Transm
//		Wave/T Folder
//		Wave Weight
////		Wave FWHMcorrection
//		Wave CorrectWv
//		NVAR AverageMSAXSCorr
//		AverageMSAXSCorr=0
//		
//		Redimension/N=(0) Transm
//		Transm=0
//		Redimension/N=(0) Folder
//		Folder=""
//		Redimension/N=(0) Weight
//		Weight=0
////		Redimension/N=(0) FWHMcorrection
////		FWHMcorrection=0
//		Redimension/N=(0) CorrectWv
//		CorrectWv=0
//
//
//end
////**************************************************************************************************
////**************************************************************************************************
////**************************************************************************************************
////**************************************************************************************************
////**************************************************************************************************
//
//Window IN2A_AMSAXS_Panel() : Panel
//	PauseUpdate    		// building window...
//	NewPanel /K=1 /W=(3.75,47,357.75,445.25) as "Anisotropic MSAXS Input Panel"
//	SetDrawLayer UserBack
//	SetDrawEnv fsize= 20,fstyle= 1,textrgb= (0,0,52224)
//	DrawText 28,26,"Aniso MSAXS Control Panel"
//	DrawLine 12,29,335,29
//	SetDrawEnv fsize= 14,fstyle= 1
//	DrawText 12,112,"1. Evaluate all sectors separately"
//	DrawLine 10,166,333,166
//	SetDrawEnv fsize= 14,fstyle= 1
//	DrawText 12,194,"2. Review the table with results"
//	SetDrawEnv fstyle= 1
//	DrawText 16,212,"set the weights and the folders to be corrected"
//	DrawLine 10,292,333,292
//	SetDrawEnv fsize= 14,fstyle= 1
//	DrawText 13,325,"3. Correct the results"
//	SetDrawEnv fsize= 14,fstyle= 1
//	DrawText 12,54,"0. Reset the table (if needed)"
//	SetDrawEnv fstyle= 1
//	DrawText 13,231,"Calculate the (trans * FWHM corr) or input value manually"
//	Button SingleSectors,pos={62,119},size={150,20},proc=IN2A_AMSAXS_Btn,title="Sector MSAXS proc", help={"Click here to do single sectors and fill in the table with data"}
//	Button Correct,pos={63,346},size={150,20},proc=IN2A_AMSAXS_Btn,title="Correct",help={"Do the corrections for selected sectors"}
//	Button Reset,pos={62,67},size={150,20},proc=IN2A_AMSAXS_Btn,title="Reset table ", help={"Reset the tool - clear table to start again"}
//	Button CheckTransm,pos={153,238},size={180,20},proc=IN2A_AMSAXS_Btn,title="Calc Ave ", help={"Calcualte the weighted average of Sector ransmission"}
//	SetVariable AveTransm,pos={34,270},size={250,16},title="Average to be used:", help={"This is effective sample transmission after all corrections"}
//	SetVariable AveTransm,limits={-Inf,Inf,0},value= root:Packages:MSAXSCorrection:AverageMSAXSCorr
//	Button SortWaves,pos={7,238},size={120,20},proc=IN2A_AMSAXS_Btn,title="Sort Waves", help={"Sort table by name so it is easier to navigate through"}
//EndMacro
//
////**************************************************************************************************
////**************************************************************************************************
////**************************************************************************************************
////**************************************************************************************************
//
//
//Window IN2A_AMSAXSTable() : Table
//	PauseUpdate    		// building window...
//	String fldrSav= GetDataFolder(1)
//	SetDataFolder root:Packages:MSAXSCorrection:
//	Edit/K=1/W=(285.75,38.75,687,426.5) Folder,Transm,Weight,CorrectWv as "Anisotropic MSAXS Correction review"
//	//Edit/K=1/W=(285.75,38.75,687,426.5) Folder,Transm,FWHMcorrection,Weight,Correct as "Anisotropic MSAXS Correction review"
//	ModifyTable style(Point)=1,alignment(Point)=1,sigDigits(Point)=3,width(Point)=27
//	ModifyTable size(Folder)=9,alignment(Folder)=0,width(Folder)=207,size(Transm)=9
//	ModifyTable alignment(Transm)=1,width(Transm)=60,size(Weight)=9,alignment(Weight)=1
//	ModifyTable width(Weight)=53,size(CorrectWv)=9,alignment(CorrectWv)=1,width(CorrectWv)=47
//	SetDataFolder fldrSav
//EndMacro
//
////**************************************************************************************************
////**************************************************************************************************
////**************************************************************************************************
////**************************************************************************************************
//
//Function IN2A_AMSAXS_Intitialize()
//
//	//first folder
//	SetDataFolder root:
//	NewDataFolder/O/S Packages
//	NewDataFolder/O/S MSAXSCorrection
//	
//	variable/G AverageMSAXSCorr=0
//	
//	//next waves needed
//	WAVE/Z Transm
//	if (!WaveExists(Transm))
//		Make/N=0 Transm
//	endif
//	WAVE/T/Z Folder
//	if (!WaveExists(Folder))
//		Make/T/N=0 Folder
//	endif
////	WAVE/Z FWHMcorrection
////	if (!WaveExists(FWHMcorrection))
////		Make/N=0 FWHMcorrection
////	endif
//	WAVE/Z Weight
//	if (!WaveExists(Weight))
//		Make/N=0 Weight
//	endif
//	WAVE/Z CorrectWv
//	if (!WaveExists(CorrectWv))
//		Make/N=0 CorrectWv
//	endif
//
//end

//*************************************************************************
//end of MSAXS correction
//start of export of the data 
//*************************************************************************
//Function IN2B_ExportAllData()
//
//	IN2G_UniversalFolderScan("root:USAXS:", 5, "IN2G_CheckTheFolderName()")  //here we fix the folder names/sample names in wave notes if necessary
//	
//	NewPath/C/O/M="Where do you want to put the data?" ExportDatapath
//	if (V_flag!=0)
//		abort
//	endif
//	
//	string IncludeData="yes"
//	string DataTypes="all"
//	string ExportDataType="CanSAS XML"
//	
//	Prompt IncludeData, "Evaluation and Description data include within files or separate?", popup, "within;separate"
//	Prompt DataTypes, "Which data sets you want to export?", popup, "all;dsm;Bkg;smr;M_dsm;M_smr;R;"
//	Prompt ExportDataType, "Export format (SMR/DSM data only)?", popup, "CanSAS XML;ASCII;"
//	DoPrompt "Export Data dialog", IncludeData, DataTypes, ExportDataType
//	if (V_flag)
//		abort
//	endif
//	
//	IN2B_ScanFoldersToExport("root:USAXS", 5, IncludeData,DataTypes, ExportDataType)
//	IN2N_CreateSummaryNotebook(1)
//end
//
//
//
//Function/S IN2B_ScanFoldersToExport(dfStart, levels,IncludeData,DataTypes, ExportDataType)
//        string dfStart, IncludeData,DataTypes, ExportDataType
//        Variable levels
//               
//        dfStart+=":"
//        
//        String dfSave, templist
//             
//        dfSave = GetDataFolder(1)
//        SetDataFolder $dfStart
//       //heregoes what is done
//       		IN2B_WriteAllDifferentData(IncludeData,DataTypes, ExportDataType)
//	//here it ends
//        templist = DataFolderDir(1)
//        levels -= 1
//        if (levels <= 0)
//                return ""
//        endif
//        
//        String subDF
//        Variable index = 0
//        do
//                String temp
//                temp = PossiblyQuoteName(GetIndexedObjName(dfStart, 4, index))     // Name of next data folder.
//
//                if (strlen(temp) == 0)
//                        break                                                                          // No more data folders.
//                endif	     		  
//                subDF = dfStart + temp
//
//                IN2B_ScanFoldersToExport(subDF,levels,IncludeData,DataTypes, ExportDataType)   						  // Recurse.
//                index += 1
//        while(1)
//        
//        SetDataFolder(dfSave)
//        return ""
//End
//
//Function IN2B_WriteAllDifferentData(IncludeData,DataTypes, ExportDataType)
//	String  IncludeData,DataTypes, ExportDataType
//	string filename=IN2B_FixTheFileName()
//	
//	
//	//ExportDataType will be either "CanSAS XML" or "ASCII", odl format is "ASCII" 
//	//here we need to cut the filename short for Mac
//
//	if (cmpstr(IgorInfo(2),"P")>0) 										// for Windows this cmpstr (IgorInfo(2)...)=1
//		filename=filename[0,30]										//30 letter should be more than enough...
//	else									//running on Mac, need shorter name
//		filename=filename[0,20]				//lets see if 20 letters will not cause problems...
//	endif	
//	
//	filename=IN2B_GetUniqueFileName(filename)
//	if (cmpstr(filename,"noname")==0)
//		return 1
//	endif
//	string filename1
//	make/T/O WaveNoteWave
//	
//	
////	Proc ExportRWaves()
//	if (((cmpstr(DataTypes,"R")==0)||(cmpstr(DataTypes,"all")==0))&&(stringmatch(ExportDataType,"ASCII")))
//		filename1 = filename+".R"
//		if (exists("R_Int")==1)
//			IN2G_PasteWnoteToWave("R_Int", WaveNoteWave,"#   ")
//			if (cmpstr(IncludeData,"within")==0)
//				Save/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1
//				Wave Qvec
//				Wave R_Int
//				Wave R_error
//				Save/A/G/M="\r\n"/P=ExportDatapath Qvec,R_Int,R_error as filename1			///P=Datapath
//			else
//				Wave Qvec
//				Wave R_Int
//				Wave R_error
//				Save/G/M="\r\n"/P=ExportDatapath Qvec,R_Int,R_error as filename1			///P=Datapath
//				filename1 = filename+"_R.txt"											//here we include description of the 
//				Save/O/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1		//samples with this name
//			endif			
//		endif	
//	endif
//	
////	Proc ExportSMRWaves()
//	if ((cmpstr(DataTypes,"smr")==0)||(cmpstr(DataTypes,"all")==0))
//		if(stringmatch(ExportDataType,"ASCII"))
//			filename1 = filename+".smr"
//			if (exists("SMR_Int")==1)
//				IN2G_PasteWnoteToWave("SMR_Int", WaveNoteWave,"#   ")
//				Wave SMR_Qvec
//				Wave SMR_Int
//				Wave SMR_Error
//				if (cmpstr(IncludeData,"within")==0)
//					Save/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1
//					Save/A/G/M="\r\n"/P=ExportDatapath SMR_Qvec,SMR_Int, SMR_Error as filename1				///P=Datapath
//				else
//					Save/G/M="\r\n"/P=ExportDatapath SMR_Qvec,SMR_Int, SMR_Error as filename1				///P=Datapath
//					filename1 = filename+"_smr.txt"											//here we include description of the 
//					Save/O/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1		//samples with this name
//				endif
//			endif
//		else			//CanSAS XML
//			filename1 = filename+"_smr.XML"
//			pathInfo ExportDatapath
//			filename1= S_path+filename1
//			if (exists("SMR_Int")==1)
//				IN2B_OneDataXmlWriter(filename1, "smr")
//			endif
//		endif
//	endif
//	
////	Proc ExportDSMWaves()
//	if ((cmpstr(DataTypes,"dsm")==0)||(cmpstr(DataTypes,"all")==0))
//		if(stringmatch(ExportDataType,"ASCII"))
//			filename1 = filename+".dsm"
//			if (exists("DSM_Int")==1)
//				IN2G_PasteWnoteToWave("DSM_Int", WaveNoteWave,"#   ")
//				Wave DSM_Qvec
//				Wave DSM_Int
//				Wave DSM_Error
//				if (cmpstr(IncludeData,"within")==0)
//					Save/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1
//					Save/A/G/M="\r\n"/P=ExportDatapath DSM_Qvec,DSM_Int, DSM_Error as filename1				///P=Datapath
//				else
//					Save/G/M="\r\n"/P=ExportDatapath DSM_Qvec,DSM_Int, DSM_Error as filename1				///P=Datapath
//					filename1 = filename+"_dsm.txt"											//here we include description of the 
//					Save/O/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1		//samples with this name
//				endif		
//			endif	
//		else			//CanSAS XML
//			filename1 = filename+"_dsm.XML"
//			pathInfo ExportDatapath
//			filename1= S_path+filename1
//			if (exists("DSM_Int")==1)
//				IN2B_OneDataXmlWriter(filename1, "dsm")
//			endif
//		endif
//	endif
////	Proc ExportBkgWaves()
//	if (((cmpstr(DataTypes,"Bkg")==0)||(cmpstr(DataTypes,"all")==0))&&(stringmatch(ExportDataType,"ASCII")))
//		filename1 = filename+".Bkg"
//		if (exists("BKG_Int")==1)
//			IN2G_PasteWnoteToWave("BKG_Int", WaveNoteWave,"#   ")
//			Wave BKG_Qvec
//			Wave BKG_Int
//			Wave BKG_Error
//			if (cmpstr(IncludeData,"within")==0)
//				Save/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1
//				Save/A/G/M="\r\n"/P=ExportDatapath BKG_Qvec,BKG_Int, BKG_Error as filename1				///P=Datapath
//			else
//				Save/G/M="\r\n"/P=ExportDatapath BKG_Qvec, BKG_Int, BKG_Error as filename1				///P=Datapath
//				filename1 = filename+"_bkg.txt"											//here we include description of the 
//				Save/O/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1		//samples with this name
//			endif			
//		endif
//	endif
////	Proc ExportM_BkgWaves()
//	if (((cmpstr(DataTypes,"M_Bkg")==0)||(cmpstr(DataTypes,"all")==0))&&(stringmatch(ExportDataType,"ASCII")))
//		filename1 = filename+"_M.Bkg"
//		if (exists("M_BKG_Int")==1)
//			IN2G_PasteWnoteToWave("M_BKG_Int", WaveNoteWave,"#   ")
//			Wave M_BKG_Qvec
//			Wave M_BKG_Int
//			Wave M_BKG_Error
//			if (cmpstr(IncludeData,"within")==0)
//				Save/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1
//				Save/A/G/M="\r\n"/P=ExportDatapath M_BKG_Qvec,M_BKG_Int, M_BKG_Error as filename1				///P=Datapath
//			else
//				Save/G/M="\r\n"/P=ExportDatapath M_BKG_Qvec, M_BKG_Int, M_BKG_Error as filename1				///P=Datapath
//				filename1 = filename+"_bkg.txt"											//here we include description of the 
//				Save/O/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1		//samples with this name
//			endif			
//		endif
//	endif
//	
////	Proc ExportM_SMRWaves()
//	if ((cmpstr(DataTypes,"M_smr")==0)||(cmpstr(DataTypes,"all")==0))
//		if(stringmatch(ExportDataType,"ASCII"))
//			filename1 = filename+"_m.smr"
//			if (exists("M_SMR_Int")==1)
//				IN2G_PasteWnoteToWave("M_SMR_Int", WaveNoteWave,"#   ")
//				Wave SMR_Qvec
//				Wave M_SMR_Int
//				Wave M_SMR_Error
//				if (cmpstr(IncludeData,"within")==0)
//					Save/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1
//					Save/A/G/M="\r\n"/P=ExportDatapath SMR_Qvec,M_SMR_Int, M_SMR_Error as filename1				///P=Datapath		
//				else
//					Save/G/M="\r\n"/P=ExportDatapath SMR_Qvec,M_SMR_Int, M_SMR_Error as filename1				///P=Datapath		
//					filename1 = filename+"_msmr.txt"											//here we include description of the 
//					Save/O/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1		//samples with this name
//				endif
//			endif
//		else			//CanSAS XML
//			filename1 = filename+"_msmr.XML"
//			pathInfo ExportDatapath
//			filename1= S_path+filename1
//			if (exists("M_SMR_Int")==1)
//				IN2B_OneDataXmlWriter(filename1, "M_smr")
//			endif
//		endif
//	endif
//	
////	Proc ExportM_DSMWaves()
//	if ((cmpstr(DataTypes,"M_dsm")==0)||(cmpstr(DataTypes,"all")==0))
//		if(stringmatch(ExportDataType,"ASCII"))
//			filename1 = filename+"_m.dsm"
//			if (exists("M_DSM_Int")==1)
//				IN2G_PasteWnoteToWave("M_DSM_Int", WaveNoteWave,"#   ")
//				Wave M_DSM_Qvec
//				Wave M_DSM_Int
//				Wave M_DSM_Error
//				if (cmpstr(IncludeData,"within")==0)
//					Save/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1
//					Save/A/G/M="\r\n"/P=ExportDatapath M_DSM_Qvec,M_DSM_Int, M_DSM_Error as filename1				///P=Datapath	
//				else
//					Save/G/M="\r\n"/P=ExportDatapath M_DSM_Qvec,M_DSM_Int, M_DSM_Error as filename1				///P=Datapath	
//					filename1 = filename+"_mdsm.txt"											//here we include description of the 
//					Save/O/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1		//samples with this name
//				endif	
//			endif		
//		else			//CanSAS XML
//			filename1 = filename+"_mdsm.XML"
//			pathInfo ExportDatapath
//			filename1= S_path+filename1
//			if (exists("M_DSM_Int")==1)
//				IN2B_OneDataXmlWriter(filename1, "M_dsm")
//			endif
//		endif
//	endif		
//	KillWaves/Z WaveNoteWave
//
//end
//
//
//Function/S IN2B_FixTheFileName()
//	WAVE/Z USAXS_PD
//	if (WaveExists(USAXS_PD))
//		string SourceSPECDataFile=stringByKey("DATAFILE",Note(USAXS_PD),"=")
//		string intermediatename=StringFromList (0, SourceSPECDataFile, ".")+"_"+GetDataFolder(0)
//		return IN2B_ZapControlCodes(intermediatename)
//	else
//		return IN2B_ZapControlCodes(GetDataFolder(0))
//	endif
//end
//
//Function/T IN2B_ZapControlCodes(str)
//	String str
//	Variable i = 0
//	do
//		if (char2num(str[i,i])<32)
//			str[i,i+1] = str[i+1,i+1]
//		endif
//		i += 1
//	while(i<strlen(str))
//	i=0
//	do
//		if (char2num(str[i,i])==39)
//			str[i,i+1] = str[i+1,i+1]
//		endif
//		i += 1
//	while(i<strlen(str))
//      i=0
//       do
//               if (char2num(str[i,i])==char2num("/"))
//                       str[i,i] = "_"
//               endif
//               i += 1
//       while(i<strlen(str))	
//	return str
//End
//
//
//
//Function/S IN2B_GetUniqueFileName(filename)
//	string filename
//	string FileList= IndexedFile(ExportDatapath,-1,"????" )
//	variable i
//	string filename1=filename
//	if (stringmatch(FileList, "*"+filename1+"*"))
//		i=0
//		do
//			filename1= filename+"_"+num2str(i)
//		i+=1
//		while(stringmatch(FileList, "*"+filename1+"*"))
//	endif
//	return filename1
//end
//
////**************************************************************
////end of export of the data
////***************************************************************


//**************************************************************
//  Correct processing of ANisao Scans from SBUSAXS
//***************************************************************

Function IN2B_CorrectAnisoData(SampleFolderName,BlankFolderName,SampleTransmission,select)//dws
	//function to correct aniso data for dark currents and blank data 
	//first find the folders which user wants to correct
	//and find blank run from which we can pull the correction parameters
	string SampleFolderName
	string BlankFolderName
	variable SampleTransmission,select
	
	string oldDf=GetDataFolder(1)
	
	//first find the folders which user wants to correct
	//and find blank run from which we can pull the correction parameters
	
	Prompt SampleFolderName, "Select Aniso Folder", popup, IN2G_FindFolderWithWaveTypes("root:Others:", 5, "USAXS_PD", 1)
	Prompt BlankFolderName, "Select Blank run Folder", popup, IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, "USAXS_PD", 1)
	Prompt SampleTransmission, "Input USAXS sample transmission" 
	If (Select==1)
		DoPrompt "Select data to corect", SampleFolderName, BlankFolderName, SampleTransmission
	endif
	
	Wave AnisoUSAXS_PD=$(SampleFolderName+"USAXS_PD")
	Wave AnisoSeconds=$(SampleFolderName+"seconds")
	Wave AnisoAR_enc=$(SampleFolderName+"ar_enc")
	Wave AnisoMonitor=$(SampleFolderName+"I0")
	SVAR AnisoMeasPar=$(SampleFolderName+"MeasurementParameters")

	Wave BlankUSAXS_PD=$(BlankFolderName+"USAXS_PD")
	Wave BlankPD_range=$(BlankFolderName+"pd_range")
	Wave BlankSeconds=$(BlankFolderName+"MeasTime")
	Wave BlankAR_enc=$(BlankFolderName+"ar_encoder")
	Wave BlankMonitor=$(BlankFolderName+"Monitor")
	SVAR BlankMeasPar=$(BlankFolderName+"MeasurementParameters")

	Variable AnisoPD_range=NumberByKey("UPD2range", AnisoMeasPar , ":", ";") +1		//+1 due to UDP2range being zero based UPD range
	variable AnisoPDDarkCurrent=NumberByKey("UPD2bkg"+num2str(AnisoPD_range), AnisoMeasPar , ":", ";")
	variable BlankUPDVal=interp(AnisoAR_enc[0], BlankAR_enc, BlankUSAXS_PD )	//1 based UPD range
	variable BlankPD_rangeVal=floor(interp(AnisoAR_enc[0], BlankAR_enc, BlankPD_range ))	
	variable RangeDifference=BlankPD_rangeVal-AnisoPD_range
	if (RangeDifference<0)
		Abort "Ranges weird - blank range is higher than sample" 
	endif
	variable BlankPDDarkCurrent=NumberByKey("UPD2bkg"+num2str(BlankPD_rangeVal), BlankMeasPar , "=", ";")

	
	
	// BlankFolderName
	// SampleFolderName
	setDataFolder $SampleFolderName
	
	Duplicate/O AnisoUSAXS_PD, AnisoIntensityCorr, TempAnisoBlInt
	Wave AnisoIntensityCorr
	Wave TempAnisoBlInt
	
	


	AnisoIntensityCorr=AnisoUSAXS_PD - (AnisoPDDarkCurrent*AnisoSeconds	)	//this fixes the USAXS PD for dark current
	TempAnisoBlInt= (BlankUPDVal - (BlankSeconds * BlankPDDarkCurrent)) / 10^(2*RangeDifference)
	
	AnisoIntensityCorr= AnisoIntensityCorr - SampleTransmission * (TempAnisoBlInt * AnisoMonitor / BlankMonitor)

	variable  RangeDifferenceFix=AnisoPD_range-1   //Normalize to range 1
	
	AnisoIntensityCorr=10^8*AnisoIntensityCorr/10^(2*RangeDifferenceFix)            //10^8 is arbitrary scale factor

	killWaves/Z TempAnisoBlInt
	
	setDataFolder oldDf


end

//*************************************************
//*************************************************
//*************************************************
//*************************************************
//*************************************************
//*************************************************

FUNCTION IN2B_OneDataXmlWriter(xmlFile, IndraDataType)		//take data from current Igor folder, if present and write xmlFile. xmlFile should be with path. 
	STRING xmlFile, IndraDataType
	VARIABLE fileID, i
	STRING myList = "", motorPositions
	NVAR Transmission, BeamCenter, MaximumIntensity, PeakWidth, Wavelength
	SVAR SpecCommand, SpecSourceFileName, SpecComment
	SVAR MeasurementParameters, UPDParameters, ListOfASBParameters, PathToRawData
	
	if(stringmatch(IndraDataType,"smr"))
		WAVE Qvec = SMR_Qvec
		WAVE Int = SMR_Int
		WAVE Error = SMR_Error
	elseif(stringmatch(IndraDataType,"dsm"))
		WAVE Qvec = DSM_Qvec
		WAVE Int = DSM_Int
		WAVE Error = DSM_Error
	elseif(stringmatch(IndraDataType,"M_smr"))
		WAVE Qvec = M_SMR_Qvec
		WAVE Int = M_SMR_Int
		WAVE Error = M_SMR_Error
	elseif(stringmatch(IndraDataType,"M_dsm"))
		WAVE Qvec = M_DSM_Qvec
		WAVE Int = M_DSM_Int
		WAVE Error = M_DSM_Error
	endif

	// this is useful for reporting on some standard parameters
	motorPositions = IN2_specMotors(PathToRawData)

	myList = ReplaceStringByKey("SpecSourceFileName", myList, SpecSourceFileName, "=", ";")
	myList = ReplaceNumberByKey("BeamCenter", myList, BeamCenter, "=", ";")
	myList = ReplaceNumberByKey("MaximumIntensity", myList, MaximumIntensity, "=", ";")
	myList = ReplaceNumberByKey("PeakWidth", myList, PeakWidth, "=", ";")

	// gather and organize the Indra-specific metadata
	KillWaves/Z metadata
	MAKE/T/N=(0,2)/O metadata
	Redimension/N=(0,2) metadata

	Redimension/N=(DimSize(metadata, 0)+1, DimSize(metadata, 1)) metadata
	metadata[Inf][0] = "local variables"
	metadata[Inf][1] = myList

	Redimension/N=(DimSize(metadata, 0)+1, DimSize(metadata, 1)) metadata
	metadata[Inf][0] = "wavenotes"
	metadata[Inf][1] = note(Qvec)

	Redimension/N=(DimSize(metadata, 0)+1, DimSize(metadata, 1)) metadata
	metadata[Inf][0] = "MeasurementParameters"
	metadata[Inf][1] = MeasurementParameters

	Redimension/N=(DimSize(metadata, 0)+1, DimSize(metadata, 1)) metadata
	metadata[Inf][0] = "UPDParameters"
	metadata[Inf][1] = UPDParameters

	Redimension/N=(DimSize(metadata, 0)+1, DimSize(metadata, 1)) metadata
	metadata[Inf][0] = "ListOfASBParameters"
	metadata[Inf][1] = ListOfASBParameters

	IN2_rawMetadata2List(PathToRawData)	//  Look at the  "PathToRawData"  There's lots more metadata there.  Maybe too much.


	// define the namespaces
#if	Exists("XMLcreateFile")
	fileID = XMLcreateFile(xmlFile, "SASroot", "cansas1d/1.0", "")
	XMLsetAttr(fileID,		"/SASroot", 				"", "version", "1.0")
	XMLsetAttr(fileID,		"/SASroot", 				"", "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
	XMLsetAttr(fileID,		"/SASroot", 				"", "xsi:schemaLocation", "cansas1d/1.0    http://svn.smallangles.net/svn/canSAS/1dwg/trunk/cansas1d.xsd")
	XMLaddNode(fileID, 	"/SASroot", 				"", "comment", "created by CS_XML_Indra.ipf", 8)

	XMLaddNode(fileID, 	"/SASroot", 	"", "comment", "exported from IgorPro::Indra", 8)
	XMLaddNode(fileID, 	"/SASroot", 	"", "comment", date()+"  "+time(), 8)

	XMLaddNode(fileID, 	"/SASroot", 				"", "SASentry", "", 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry", 	"", "name", SpecComment)
	XMLaddNode(fileID, 	"/SASroot/SASentry", 	"", "Title", SpecComment, 1)
	
	//need to create here appropriate RunInfo we can use in the future, something like:  "APS_USAXS=32-ID; scan=S81; file=08_21.dat; dataType=slit-smeared; MSAXS=no" 
	string RunInfo = "APS_USAXS=15-ID;"
	RunInfo +="scan="+StringByKey("SCAN_N", note(Qvec), "=")+";"
	RunInfo +="file="+StringByKey("DATAFILE", note(Qvec), "=")+";"
	if(stringmatch(IndraDataType,"*smr"))
		RunInfo +="dataType=slit-smeared;"
	elseif(stringmatch(IndraDataType,"*dsm"))
		if(stringmatch(StringByKey("DataDesmeared",note(Qvec),"="),"yes"))
			RunInfo +="dataType=desmeared;"
		else
			RunInfo +="dataType=2D-collimated;"
		endif
	endif
	if(stringmatch(IndraDataType,"M_*"))
		RunInfo +="MSAXS=yes;"
	else
		RunInfo +="MSAXS=no;"
	endif
	
	XMLsetAttr(fileID,		"/SASroot/SASentry/Run", "", "name", RunInfo)
	XMLaddNode(fileID, 	"/SASroot/SASentry", 	"", "Run", RunInfo , 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry", 	"", "SASdata", "", 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASdata", "", "name", RunInfo)
	STRING xpathstr
	Wave SMR_Qvec
	FOR ( i = 0; i < NumPnts(SMR_Qvec); i += 1 )
		xpathstr = "/SASroot/SASentry/SASdata/Idata["+num2str(i+1)+"]"
		XMLaddNode(fileID, 	"/SASroot/SASentry/SASdata", 	"", "Idata", "", 1)
		XMLaddNode(fileID, 	xpathstr, 			"", "Q", num2str(Qvec[i]), 1)
		XMLsetAttr(fileID,		xpathstr + "/Q", 		"", "unit", "1/A")
		XMLaddNode(fileID, 	xpathstr, 			"", "I", num2str(Int[i]), 1)
		XMLsetAttr(fileID,		xpathstr + "/I", 		"", "unit", "1/cm")
		XMLaddNode(fileID, 	xpathstr, 			"", "Idev", num2str(error[i]), 1)
		XMLsetAttr(fileID,		xpathstr + "/Idev", 	"", "unit", "1/cm")
	ENDFOR

	// it is presumptive to say this is USAXS data, unless the tool only outputs USAXS data from Irena
	// HOWEVER, if we do not assume this is USAXS data, there is not much content available after SASdata
	// Perhaps we can test for a few key items that are specific to USAXS
	// If found, then it verifies the assumption this is USAXS data
	// else: it is I(Q) data imported into the Irena format.
	// DECISION:
	// Expect the calling routine to have determined that the chosen folder contains APS/USAXS data

	XMLaddNode(fileID, 	"/SASroot/SASentry", 	"", "SASsample", "", 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASsample", 	"", "ID", SpecComment, 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASsample", 	"", "thickness", StringByKey("SampleThickness", note(SMR_Qvec), "="), 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASsample/thickness", "", "unit", "mm")
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASsample", 	"", "transmission", num2str(Transmission), 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASsample", 	"", "position", "", 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASsample/position", 	"", "x", StringByKey("sx", motorPositions), 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASsample/position/x", "", "unit", "mm")
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASsample/position", 	"", "y", StringByKey("sy", motorPositions), 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASsample/position/y", "", "unit", "mm")

	XMLaddNode(fileID, 	"/SASroot/SASentry", 	"", "SASinstrument", "", 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument", 	"", "name", "APS 32ID-B USAXS", 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument", 	"", "SASsource", "", 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SASsource", 	"", "radiation", "X-ray synchrotron", 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SASsource", 	"", "beam_size", "", 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SASsource/beam_size", 	"", "x", StringByKey("uslithorap", motorPositions), 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASinstrument/SASsource/beam_size/x", "", "unit", "mm")
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SASsource/beam_size", 	"", "y", StringByKey("uslitverap", motorPositions), 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASinstrument/SASsource/beam_size/y", "", "unit", "mm")
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SASsource", 	"", "beam_shape", "rectangle", 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SASsource", 	"", "wavelength", num2str(Wavelength), 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASinstrument/SASsource/wavelength", "", "unit", "A")

	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument", 	"", "SAScollimation", "", 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SAScollimation", 	"", "aperture", "", 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASinstrument/SAScollimation/aperture", "", "name", "usaxs")
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SAScollimation/aperture", 	"", "size", "", 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SAScollimation/aperture/size", 	"", "x", StringByKey("uslithorap", motorPositions), 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASinstrument/SAScollimation/aperture/size/x", "", "unit", "mm")
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SAScollimation/aperture/size", 	"", "y", StringByKey("uslitverap", motorPositions), 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASinstrument/SAScollimation/aperture/size/y", "", "unit", "mm")
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SAScollimation", 	"", "aperture", "", 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASinstrument/SAScollimation/aperture[2]", "", "name", "s1")
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SAScollimation/aperture[2]", 	"", "size", "", 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SAScollimation/aperture[2]/size", 	"", "x", StringByKey("s1hgap", motorPositions), 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASinstrument/SAScollimation/aperture[2]/size/x", "", "unit", "mm")
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SAScollimation/aperture[2]/size", 	"", "y", StringByKey("s1vgap", motorPositions), 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASinstrument/SAScollimation/aperture[2]/size/y", "", "unit", "mm")

	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument", 	"", "SASdetector", "", 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SASdetector", "", "name", "USAXS photodiode", 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SASdetector", "", "SDD", StringByKey("SDDistance", note(Qvec), "="), 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASinstrument/SASdetector/SDD", "", "unit", "mm")
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SASdetector", "", "pixel_size", "", 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SASdetector/pixel_size", "", "x", "5.50", 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASinstrument/SASdetector/pixel_size/x", "", "unit", "mm")
	//slit length needs to vary depending on slit smeared/desmeared/2D colimated data
	if(stringmatch(IndraDataType,"*smr"))
		XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SASdetector", "", "slit_length", StringByKey("SlitLength", note(Qvec), "="), 1)
	else
		XMLaddNode(fileID, 	"/SASroot/SASentry/SASinstrument/SASdetector", "", "slit_length", "0.9e-4", 1)
	endif
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASinstrument/SASdetector/slit_length", "", "unit", "1/A")

	XMLaddNode(fileID, 	"/SASroot/SASentry", 	"", "SASprocess", "", 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASprocess", "", "name", "Indra")
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASprocess", 	"", "name", "exported from IgorPro::Indra", 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASprocess", 	"", "date", date()+"  "+time(), 1)
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASprocess", 	"", "description", "USAXS data in standard 1-D form", 1)

	XMLaddNode(fileID, 	"/SASroot/SASentry/SASprocess", 	"", "term", StringByKey("en", motorPositions), 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASprocess/term[1]", "", "name", "energy")
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASprocess/term[1]", "", "unit", "keV")
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASprocess", 	"", "term", StringByKey("SAD", MeasurementParameters, "="), 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASprocess/term[2]", "", "name", "SAD")
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASprocess/term[2]", "", "unit", "mm")
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASprocess", 	"", "term", StringByKey("SDD", MeasurementParameters, "="), 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASprocess/term[3]", "", "name", "SDD")
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASprocess/term[3]", "", "unit", "mm")
	XMLaddNode(fileID, 	"/SASroot/SASentry/SASprocess", 	"", "term", StringByKey("DATE", note(SMR_Qvec), "=") + "  " + StringByKey("HOUR", note(SMR_Qvec), "="), 1)
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASprocess/term[4]", "", "name", "experiment date")
	// XMLsetAttr(fileID,		"/SASroot/SASentry/SASprocess/term[4]", "", "unit", "none")	// "unit" is optional

	XMLaddNode(fileID, 	"/SASroot/SASentry/SASprocess", 	"", "SASprocessnote", "", 1)

	// place the metadata in a SASprocessnote named "metadata"
	XMLsetAttr(fileID,		"/SASroot/SASentry/SASprocess/SASprocessnote", "", "name", "metadata")
	FOR ( i = 0; i < DimSize(metadata, 0); i += 1 )
		IN2_metadata2XML(fileID, "/SASroot/SASentry/SASprocess/SASprocessnote", i+1, metadata[i][0], "APS_USAXS", metadata[i][1])	
	ENDFOR

	XMLaddNode(fileID, 	"/SASroot/SASentry", 	"", "SASnote", "", 1)	// required but nothing to say

	XMLsaveFile(fileID)
	XMLcloseFile(fileID,0)
	//fix the bug in XML writer which cannot do stylesheets directives...
	IN2_FixXMLHeader( xmlFile)
	 //prg HD:cccc:yyy:test.xml
	 string XSLFileName
	 XSLFileName = RemoveFromList(StringFromList(ItemsInList(xmlFile,":")-1, xmlFile  , ":"), xmlFile  ,":")
	 XSLFileName +="example.xsl"

	 variable refnum2
	Open/Z/R  refnum2 as XSLFileName
	if(V_Flag!=0)
		//Add Example.XSL file...
		close refnum2
		 IN2_MakeExampleXSL()
		SaveNotebook /O ExampleXSL  as XSLFileName
		KillWIndow/Z ExampleXSL
		print "Created XSL file for you..."
	else
		close refnum2
	endif
#else
		Abort "XML xop not installed, this feature is not available. Use one of the installers and install the xop support before using this feature."
#endif
END

Function IN2_FixXMLHeader( XMLFileName)
	string   XMLFileName

	OpenNotebook/V=0 /N=tempFIle  XMLFileName
	Notebook tempFIle selection={(0, 22),(0,22) }
	Notebook tempFIle text="<?xml-stylesheet type=\"text/xsl\" href=\"example.xsl\" ?>\r\n"
	SaveNotebook /O tempFIle  as XMLFileName
	DoWIndow /K tempFIle
end


Function IN2_MakeExampleXSL()
	String nb = "ExampleXSL"
	NewNotebook/N=$nb/F=0/V=1/K=0/W=(311,44,1020,714)
	Notebook $nb defaultTab=20, statusWidth=252
	Notebook $nb text="<?xml version=\"1.0\"?>\r"
	Notebook $nb text="<xsl:stylesheet version=\"1.0\"\r"
	Notebook $nb text="\txmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\"\r"
	Notebook $nb text="\txmlns:cs=\"cansas1d/1.0\"\r"
	Notebook $nb text="\txmlns:fn=\"http://www.w3.org/2005/02/xpath-functions\"\r"
	Notebook $nb text="\t>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<!-- http://www.w3schools.com/xsl/xsl_transformation.asp -->\r"
	Notebook $nb text="\t<!-- http://www.smallangles.net/wgwiki/index.php/cansas1d_documentation -->\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"/\">\r"
	Notebook $nb text="<!-- DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml"
	Notebook $nb text="1-transitional.dtd\" -->\r"
	Notebook $nb text="\t\t<html>\r"
	Notebook $nb text="\t\t\t<head>\r"
	Notebook $nb text="\t\t\t\t<title>SAS data in canSAS 1-D format</title>\r"
	Notebook $nb text="\t\t\t</head>\r"
	Notebook $nb text="\t\t\t<body>\r"
	Notebook $nb text="\t\t\t\t<h1>SAS data in canSAS 1-D format</h1>\r"
	Notebook $nb text="\t\t\t\t<small>generated using <TT>example.xsl</TT> from canSAS</small>\r"
	Notebook $nb text="\t\t\t\t<BR />\r"
	Notebook $nb text="\t\t\t\t<table border=\"2\">\r"
	Notebook $nb text="\t\t\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t\t\t<th bgcolor=\"lavender\">canSAS 1-D XML version:</th>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\"cs:SASroot/@version\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t\t\t<th bgcolor=\"lavender\">number of entries:</th>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\"count(cs:SASroot/cs:SASentry)\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t\t\t<xsl:if test=\"count(/cs:SASroot//cs:SASentry)>1\">\r"
	Notebook $nb text="\t\t\t\t\t\t<!-- if more than one SASentry, make a table of contents -->\r"
	Notebook $nb text="\t\t\t\t\t\t<xsl:for-each select=\"/cs:SASroot//cs:SASentry\">\r"
	Notebook $nb text="\t\t\t\t\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t<th bgcolor=\"lavender\">SASentry-<xsl:value-of select=\"position()\" /></th>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t<td>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t<a href=\"#SASentry-{generate-id(.)}\">\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t<xsl:if test=\"@name!=''\">\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t(<xsl:value-of select=\"@name\" />)\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t</xsl:if>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t<xsl:value-of select=\"cs:Title\" />\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t</a>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t</td>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t<xsl:if test=\"count(cs:SASdata)>1\">\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t<td>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t<!-- if more than one SASdata, make a local table of contents -->\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t<xsl:for-each select=\"cs:SASdata\">\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t<xsl:if test=\"position()>1\">\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t\t<xsl:text> | </xsl:text>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t</xsl:if>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t<a href=\"#SASdata-{generate-id(.)}\">\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t\t<xsl:choose>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t\t\t<xsl:when test=\"cs:name!=''\">\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t\t\t\t<xsl:value-of select=\"cs:name\" />\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t\t\t</xsl:when>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t\t\t<xsl:when test=\"@name!=''\">\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t\t\t\t<xsl:value-of select=\"@name\" />\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t\t\t</xsl:when>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t\t\t<xsl:otherwise>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t\t\t\tSASdata<xsl:value-of select=\"position()\" />\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t\t\t</xsl:otherwise>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t\t</xsl:choose>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t</a>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t</xsl:for-each>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t</td>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t</xsl:if>\r"
	Notebook $nb text="\t\t\t\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t\t\t\t</xsl:for-each>\r"
	Notebook $nb text="\t\t\t\t\t</xsl:if>\r"
	Notebook $nb text="\t\t\t\t</table>\r"
	Notebook $nb text="\t\t\t\t<xsl:apply-templates  />\r"
	Notebook $nb text="\t\t\t\t<hr />\r"
	Notebook $nb text="\t\t\t</body>\r"
	Notebook $nb text="\t\t</html>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:SASroot\">\r"
	Notebook $nb text="\t\t<xsl:for-each select=\"cs:SASentry\">\r"
	Notebook $nb text="\t\t\t<hr />\r"
	Notebook $nb text="\t\t\t<br />\r"
	Notebook $nb text="\t\t\t<a id=\"#SASentry-{generate-id(.)}\"  name=\"#SASentry-{generate-id(.)}\" />\r"
	Notebook $nb text="\t\t\t<h1>\r"
	Notebook $nb text="\t\t\t\t\tSASentry<xsl:value-of select=\"position()\" />:\r"
	Notebook $nb text="\t\t\t\t\t<xsl:if test=\"@name!=''\">\r"
	Notebook $nb text="\t\t\t\t\t\t(<xsl:value-of select=\"@name\" />)\r"
	Notebook $nb text="\t\t\t\t\t</xsl:if>\r"
	Notebook $nb text="\t\t\t\t\t<xsl:value-of select=\"cs:Title\" />\r"
	Notebook $nb text="\t\t\t</h1>\r"
	Notebook $nb text="\t\t\t<xsl:if test=\"count(cs:SASdata)>1\">\r"
	Notebook $nb text="\t\t\t\t<table border=\"2\">\r"
	Notebook $nb text="\t\t\t\t\t<caption>SASdata contents</caption>\r"
	Notebook $nb text="\t\t\t\t\t<xsl:for-each select=\"cs:SASdata\">\r"
	Notebook $nb text="\t\t\t\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t\t\t\t<th>SASdata-<xsl:value-of select=\"position()\" /></th>\r"
	Notebook $nb text="\t\t\t\t\t\t\t<td>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t<a href=\"#SASdata-{generate-id(.)}\">\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t<xsl:choose>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t<xsl:when test=\"@name!=''\">\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\t<xsl:value-of select=\"@name\" />\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t</xsl:when>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t<xsl:otherwise>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t\tSASdata<xsl:value-of select=\"position()\" />\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t\t</xsl:otherwise>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t\t</xsl:choose>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t</a>\r"
	Notebook $nb text="\t\t\t\t\t\t\t</td>\r"
	Notebook $nb text="\t\t\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t\t\t</xsl:for-each>\r"
	Notebook $nb text="\t\t\t\t</table>\r"
	Notebook $nb text="\t\t\t</xsl:if>\r"
	Notebook $nb text="\t\t\t<br />\r"
	Notebook $nb text="\t\t\t<table border=\"2\">\r"
	Notebook $nb text="\t\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t\t<th>SAS data</th>\r"
	Notebook $nb text="\t\t\t\t\t<th>Selected Metadata</th>\r"
	Notebook $nb text="\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t\t<td valign=\"top\"><xsl:apply-templates  select=\"cs:SASdata\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t<td valign=\"top\">\r"
	Notebook $nb text="\t\t\t\t\t\t<table border=\"2\">\r"
	Notebook $nb text="\t\t\t\t\t\t\t<tr bgcolor=\"lavender\">\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t<th>name</th>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t<th>value</th>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t<th>unit</th>\r"
	Notebook $nb text="\t\t\t\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t\t\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t<td>Title</td>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t<td><xsl:value-of select=\"cs:Title\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t<td />\r"
	Notebook $nb text="\t\t\t\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t\t\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t<td>Run</td>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t<td><xsl:value-of select=\"cs:Run\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t\t\t\t<td />\r"
	Notebook $nb text="\t\t\t\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t\t\t\t\t<tr><xsl:apply-templates  select=\"run\" /></tr>\r"
	Notebook $nb text="\t\t\t\t\t\t\t<xsl:apply-templates  select=\"cs:SASsample\" />\r"
	Notebook $nb text="\t\t\t\t\t\t\t<xsl:apply-templates  select=\"cs:SASinstrument\" />\r"
	Notebook $nb text="\t\t\t\t\t\t\t<xsl:apply-templates  select=\"cs:SASprocess\" />\r"
	Notebook $nb text="\t\t\t\t\t\t\t<xsl:apply-templates  select=\"cs:SASnote\" />\r"
	Notebook $nb text="\t\t\t\t\t\t</table>\r"
	Notebook $nb text="\t\t\t\t\t</td>\r"
	Notebook $nb text="\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t</table>\r"
	Notebook $nb text="\t\t</xsl:for-each>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:SASdata\">\r"
	Notebook $nb text="\t\t<a id=\"#SASdata-{generate-id(.)}\"  name=\"#SASdata-{generate-id(.)}\" />\r"
	Notebook $nb text="\t\t<table border=\"2\">\r"
	Notebook $nb text="\t\t\t<caption>\r"
	Notebook $nb text="\t\t\t\t<xsl:if test=\"@name!=''\">\r"
	Notebook $nb text="\t\t\t\t\t<xsl:value-of select=\"@name\" />\r"
	Notebook $nb text="\t\t\t\t</xsl:if>\r"
	Notebook $nb text="\t\t\t\t(<xsl:value-of select=\"count(cs:Idata)\" /> points)\r"
	Notebook $nb text="\t\t\t</caption>\r"
	Notebook $nb text="\t\t\t<tr bgcolor=\"lavender\">\r"
	Notebook $nb text="\t\t\t\t<xsl:for-each select=\"cs:Idata[1]/*\">\r"
	Notebook $nb text="\t\t\t\t\t<th>\r"
	Notebook $nb text="\t\t\t\t\t\t<xsl:value-of select=\"name()\" /> \r"
	Notebook $nb text="\t\t\t\t\t\t<xsl:if test=\"@unit!=''\">\r"
	Notebook $nb text="\t\t\t\t\t\t\t(<xsl:value-of select=\"@unit\" />)\r"
	Notebook $nb text="\t\t\t\t\t\t</xsl:if>\r"
	Notebook $nb text="\t\t\t\t\t</th>\r"
	Notebook $nb text="\t\t\t\t</xsl:for-each>\r"
	Notebook $nb text="\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t<xsl:for-each select=\"cs:Idata\">\r"
	Notebook $nb text="\t\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t\t<xsl:for-each select=\"*\">\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t</xsl:for-each>\r"
	Notebook $nb text="\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t</xsl:for-each>\r"
	Notebook $nb text="\t\t</table>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:SASsample\">\r"
	Notebook $nb text="\t\t<tr>\r"
	Notebook $nb text="\t\t\t<td>SASsample</td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@name\" /></td>\r"
	Notebook $nb text="\t\t\t<td />\r"
	Notebook $nb text="\t\t</tr>\r"
	Notebook $nb text="\t\t<xsl:for-each select=\"*\">\r"
	Notebook $nb text="\t\t\t<xsl:choose>\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='position'\">\r"
	Notebook $nb text="\t\t\t\t\t<xsl:apply-templates select=\".\" />\r"
	Notebook $nb text="\t\t\t\t</xsl:when>\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='orientation'\">\r"
	Notebook $nb text="\t\t\t\t\t<xsl:apply-templates select=\".\" />\r"
	Notebook $nb text="\t\t\t\t</xsl:when>\r"
	Notebook $nb text="\t\t\t\t<xsl:otherwise>\r"
	Notebook $nb text="\t\t\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\"@unit\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t\t</xsl:otherwise>\r"
	Notebook $nb text="\t\t\t</xsl:choose>\r"
	Notebook $nb text="\t\t</xsl:for-each>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:SASinstrument\">\r"
	Notebook $nb text="\t\t<tr>\r"
	Notebook $nb text="\t\t\t<td>SASinstrument</td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"cs:name\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@name\" /></td>\r"
	Notebook $nb text="\t\t</tr>\r"
	Notebook $nb text="\t\t<xsl:for-each select=\"*\">\r"
	Notebook $nb text="\t\t\t<xsl:choose>\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='SASsource'\"><xsl:apply-templates select=\".\" /></xsl:when>\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='SAScollimation'\"><xsl:apply-templates select=\".\" /></xsl:when>\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='SASdetector'\"><xsl:apply-templates select=\".\" /></xsl:when>\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='name'\" />\r"
	Notebook $nb text="\t\t\t\t<xsl:otherwise>\r"
	Notebook $nb text="\t\t\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\"@unit\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t\t</xsl:otherwise>\r"
	Notebook $nb text="\t\t\t</xsl:choose>\r"
	Notebook $nb text="\t\t</xsl:for-each>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:SASsource\">\r"
	Notebook $nb text="\t\t<tr>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@name\" /></td>\r"
	Notebook $nb text="\t\t\t<td />\r"
	Notebook $nb text="\t\t</tr>\r"
	Notebook $nb text="\t\t<xsl:for-each select=\"*\">\r"
	Notebook $nb text="\t\t\t<xsl:choose>\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='beam_size'\"><xsl:apply-templates select=\".\" /></xsl:when>\r"
	Notebook $nb text="\t\t\t\t<xsl:otherwise>\r"
	Notebook $nb text="\t\t\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\"@unit\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t\t</xsl:otherwise>\r"
	Notebook $nb text="\t\t\t</xsl:choose>\r"
	Notebook $nb text="\t\t</xsl:for-each>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:beam_size\">\r"
	Notebook $nb text="\t\t<tr>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@name\" /></td>\r"
	Notebook $nb text="\t\t\t<td />\r"
	Notebook $nb text="\t\t</tr>\r"
	Notebook $nb text="\t\t<xsl:for-each select=\"*\">\r"
	Notebook $nb text="\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\"name(../..)\" />_<xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"n"
	Notebook $nb text="ame()\" /></td>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\"@unit\" /></td>\r"
	Notebook $nb text="\t\t\t</tr>\r"
	Notebook $nb text="\t\t</xsl:for-each>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:SAScollimation\">\r"
	Notebook $nb text="\t\t<xsl:for-each select=\"*\">\r"
	Notebook $nb text="\t\t\t<xsl:choose>\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='aperture'\"><xsl:apply-templates select=\".\" /></xsl:when>\r"
	Notebook $nb text="\t\t\t\t<xsl:otherwise>\r"
	Notebook $nb text="\t\t\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\"@unit\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t\t</xsl:otherwise>\r"
	Notebook $nb text="\t\t\t</xsl:choose>\r"
	Notebook $nb text="\t\t</xsl:for-each>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:aperture\">\r"
	Notebook $nb text="\t\t<tr>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@name\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@type\" /></td>\r"
	Notebook $nb text="\t\t</tr>\r"
	Notebook $nb text="\t\t<xsl:for-each select=\"*\">\r"
	Notebook $nb text="\t\t\t<xsl:choose>\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='size'\"><xsl:apply-templates select=\".\" /></xsl:when>\r"
	Notebook $nb text="\t\t\t\t<xsl:otherwise>\r"
	Notebook $nb text="\t\t\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\"name(../..)\" />_<xsl:value-of select=\"name(..)\" />_<xsl:value-of select="
	Notebook $nb text="\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\"@unit\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t\t</xsl:otherwise>\r"
	Notebook $nb text="\t\t\t</xsl:choose>\r"
	Notebook $nb text="\t\t</xsl:for-each>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:size\">\r"
	Notebook $nb text="\t\t<tr>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"name(../..)\" />_<xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"na"
	Notebook $nb text="me()\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@name\" /></td>\r"
	Notebook $nb text="\t\t\t<td />\r"
	Notebook $nb text="\t\t</tr>\r"
	Notebook $nb text="\t\t<xsl:for-each select=\"*\">\r"
	Notebook $nb text="\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\"name(../../..)\" />_<xsl:value-of select=\"name(../..)\" />_<xsl:value-of sel"
	Notebook $nb text="ect=\"name(..)\" />_<xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\"@unit\" /></td>\r"
	Notebook $nb text="\t\t\t</tr>\r"
	Notebook $nb text="\t\t</xsl:for-each>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:SASdetector\">\r"
	Notebook $nb text="\t\t<tr>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"cs:name\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@name\" /></td>\r"
	Notebook $nb text="\t\t</tr>\r"
	Notebook $nb text="\t\t<xsl:for-each select=\"*\">\r"
	Notebook $nb text="\t\t\t<xsl:choose>\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='name'\" />\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='offset'\"><xsl:apply-templates select=\".\" /></xsl:when>\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='orientation'\"><xsl:apply-templates select=\".\" /></xsl:when>\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='beam_center'\"><xsl:apply-templates select=\".\" /></xsl:when>\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='pixel_size'\"><xsl:apply-templates select=\".\" /></xsl:when>\r"
	Notebook $nb text="\t\t\t\t<xsl:otherwise>\r"
	Notebook $nb text="\t\t\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\"@unit\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t\t</xsl:otherwise>\r"
	Notebook $nb text="\t\t\t</xsl:choose>\r"
	Notebook $nb text="\t\t</xsl:for-each>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:orientation\">\r"
	Notebook $nb text="\t\t<tr>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@name\" /></td>\r"
	Notebook $nb text="\t\t\t<td />\r"
	Notebook $nb text="\t\t</tr>\r"
	Notebook $nb text="\t\t<xsl:for-each select=\"*\">\r"
	Notebook $nb text="\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\"name(../..)\" />_<xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"n"
	Notebook $nb text="ame()\" /></td>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\"@unit\" /></td>\r"
	Notebook $nb text="\t\t\t</tr>\r"
	Notebook $nb text="\t\t</xsl:for-each>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:position\">\r"
	Notebook $nb text="\t\t<tr>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@name\" /></td>\r"
	Notebook $nb text="\t\t\t<td />\r"
	Notebook $nb text="\t\t</tr>\r"
	Notebook $nb text="\t\t<xsl:for-each select=\"*\">\r"
	Notebook $nb text="\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\"name(../..)\" />_<xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"n"
	Notebook $nb text="ame()\" /></td>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\"@unit\" /></td>\r"
	Notebook $nb text="\t\t\t</tr>\r"
	Notebook $nb text="\t\t</xsl:for-each>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:offset\">\r"
	Notebook $nb text="\t\t<tr>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@name\" /></td>\r"
	Notebook $nb text="\t\t\t<td />\r"
	Notebook $nb text="\t\t</tr>\r"
	Notebook $nb text="\t\t<xsl:for-each select=\"*\">\r"
	Notebook $nb text="\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\"name(../..)\" />_<xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"n"
	Notebook $nb text="ame()\" /></td>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\"@unit\" /></td>\r"
	Notebook $nb text="\t\t\t</tr>\r"
	Notebook $nb text="\t\t</xsl:for-each>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:beam_center\">\r"
	Notebook $nb text="\t\t<tr>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@name\" /></td>\r"
	Notebook $nb text="\t\t\t<td />\r"
	Notebook $nb text="\t\t</tr>\r"
	Notebook $nb text="\t\t<xsl:for-each select=\"*\">\r"
	Notebook $nb text="\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\"name(../..)\" />_<xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"n"
	Notebook $nb text="ame()\" /></td>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\"@unit\" /></td>\r"
	Notebook $nb text="\t\t\t</tr>\r"
	Notebook $nb text="\t\t</xsl:for-each>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:pixel_size\">\r"
	Notebook $nb text="\t\t<tr>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@name\" /></td>\r"
	Notebook $nb text="\t\t\t<td />\r"
	Notebook $nb text="\t\t</tr>\r"
	Notebook $nb text="\t\t<xsl:for-each select=\"*\">\r"
	Notebook $nb text="\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\"name(../..)\" />_<xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"n"
	Notebook $nb text="ame()\" /></td>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\"@unit\" /></td>\r"
	Notebook $nb text="\t\t\t</tr>\r"
	Notebook $nb text="\t\t</xsl:for-each>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:term\">\r"
	Notebook $nb text="\t\t<tr>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@name\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@unit\" /></td>\r"
	Notebook $nb text="\t\t</tr>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:SASprocessnote\">\r"
	Notebook $nb text="\t\t<tr>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@name\" /></td>\r"
	Notebook $nb text="\t\t</tr>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:SASprocess\">\r"
	Notebook $nb text="\t\t<tr>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"cs:name\" /></td>\r"
	Notebook $nb text="\t\t\t<td><xsl:value-of select=\"@name\" /></td>\r"
	Notebook $nb text="\t\t</tr>\r"
	Notebook $nb text="\t\t<xsl:for-each select=\"*\">\r"
	Notebook $nb text="\t\t\t<xsl:choose>\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='name'\" />\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='term'\"><xsl:apply-templates select=\".\" /></xsl:when>\r"
	Notebook $nb text="\t\t\t\t<xsl:when test=\"name()='SASprocessnote'\"><xsl:apply-templates select=\".\" /></xsl:when>\r"
	Notebook $nb text="\t\t\t\t<xsl:otherwise>\r"
	Notebook $nb text="\t\t\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\"name(..)\" />_<xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t\t\t\t<td />\r"
	Notebook $nb text="\t\t\t\t\t</tr>\r"
	Notebook $nb text="\t\t\t\t</xsl:otherwise>\r"
	Notebook $nb text="\t\t\t</xsl:choose>\r"
	Notebook $nb text="\t\t</xsl:for-each>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="\t<xsl:template match=\"cs:SASnote\">\r"
	Notebook $nb text="\t\t<xsl:if test=\"@name!=''\">\r"
	Notebook $nb text="\t\t\t<tr>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\"name()\" /></td>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\".\" /></td>\r"
	Notebook $nb text="\t\t\t\t<td><xsl:value-of select=\"@name\" /></td>\r"
	Notebook $nb text="\t\t\t</tr>\r"
	Notebook $nb text="\t\t</xsl:if>\r"
	Notebook $nb text="\t</xsl:template>\r"
	Notebook $nb text="\r"
	Notebook $nb text="</xsl:stylesheet>\r"
end
FUNCTION/s IN2_specMotors(rawPath)
	STRING rawPath
	STRING result = "", value
	STRING pwd = GetDataFolder(1)

	SetDataFolder rawPath
	SVAR specMotors
	result = specMotors
	SetDataFolder pwd
	RETURN (result)
END

FUNCTION IN2_rawMetadata2List(rawPath)
	STRING rawPath
	STRING result = ""
	STRING pwd = GetDataFolder(1)
	WAVE/T metadata

	SetDataFolder rawPath
	SVAR specCommand, timeWritten, specComment, specValues, specMotors, EPICS_PVs
	SVAR xAxisName, yAxisName, SpecSourceFileName, DataTransferredto
	result = ReplaceStringByKey("specCommand", result, specCommand, "=", ";")
	result = ReplaceStringByKey("timeWritten", result, timeWritten, "=", ";")
	result = ReplaceStringByKey("specComment", result, specComment, "=", ";")
	result = ReplaceStringByKey("xAxisName", result, xAxisName, "=", ";")
	result = ReplaceStringByKey("yAxisName", result, yAxisName, "=", ";")
	result = ReplaceStringByKey("SpecSourceFileName", result, SpecSourceFileName, "=", ";")
	result = ReplaceStringByKey("DataTransferredto", result, DataTransferredto, "=", ";")

	Redimension/N=(DimSize(metadata, 0)+1, DimSize(metadata, 1)) metadata
	metadata[Inf][0] = "raw"
	metadata[Inf][1] = result

	Redimension/N=(DimSize(metadata, 0)+1, DimSize(metadata, 1)) metadata
	metadata[Inf][0] = "specValues"
	metadata[Inf][1] = In2_listConvert(specValues)

	Redimension/N=(DimSize(metadata, 0)+1, DimSize(metadata, 1)) metadata
	metadata[Inf][0] = "specMotors"
	metadata[Inf][1] = In2_listConvert(specMotors)

	Redimension/N=(DimSize(metadata, 0)+1, DimSize(metadata, 1)) metadata
	metadata[Inf][0] = "EPICS_PVs"
	metadata[Inf][1] = In2_listConvert(EPICS_PVs)

	SetDataFolder pwd
END

FUNCTION IN2_metadata2XML(fileID, parent, index, section, node, theList)
	VARIABLE fileID, index
	STRING parent, section, node, theList
	STRING theItem, theKey, theValue
	VARIABLE i, pos

#if Exists("XMLaddNode")==3
	XMLaddNode(fileID, parent, "", node, "", 1)
	parent += "/"+node+"[" + num2str(index) + "]"
	XMLsetAttr(fileID,	parent, "", "name", section)

	FOR ( i = 0; i < ItemsInList(theList) ; i += 1 )
		theItem = StringFromList(i, theList)					// walk through all items
		pos = strsearch(theItem, "=", 0)
		theKey = theItem[0,pos-1]
		theValue = theItem[pos+1,Inf]
		IF (strlen(theValue))
			XMLaddNode(fileID, parent, "", theKey, theValue, 1)
		ENDIF
	ENDFOR
#else
		Abort "XML xop not installed, this feature is not available. Use one of the installers and install the xop support before using this feature."
#endif
END

static FUNCTION/S IN2_listConvert(rawList)
	STRING rawList
	VARIABLE i, pos
	STRING result = "", item, key, value
	FOR ( i = 0; i < ItemsInList(rawList) ; i += 1 )		// walk through all items
		item = StringFromList(i, rawList)					// walk through all items
		pos = strsearch(item, ":", 0)
		key = item[0,pos-1]
		value = item[pos+1,Inf]
		result = ReplaceStringByKey(key, result, value, "=", ";")
	ENDFOR
	RETURN (result)
END


