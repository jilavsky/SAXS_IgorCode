#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.78
#pragma IgorVersion=7.05

//DO NOT renumber Main files every time, these are main release numbers...

constant CurrentNikaVersionNumber = 1.78

//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/
 
 
//1.78	Promoted Igor requirements to 7.05 due to bug in HDF5 support at lower versions
//		FIxed problem with change geometries, when Nexus Import TMP foldr was not deleted and this caused issues. 
//		Added simple recording to my web site about version checking for statistical purposes. Records Nika version, Igor platform and version.  
//		Creating new configuration will now reopen 9ID config screen if it was opened before. 
//		modified Configuration manager to be may be less confusing... 
//1.77 	Updated CheckForUpdate to check on Github for latest release version
//		Add call to ReadTheDocs manuals. Added CheckDisplayArea and modified how Nika checks for available screen size. 
//		#pragma IgorVersion=7.00
//1.76 version 1.75 with on line help and Igor 6 only
//1.75 rewrote Nexus support, added check for desktop resolution
//1.74		added scaling of images on large displays	
//1.73 added functions to scale panels to larger sizes.
//1.72 changed check for update procedure to check http first, then ftp, and the fail. 
//1.71 Added NI1_SetAllPathsInNIka function to set all paths to the same place for users with simple setups.
//1.70 added multiple geometries manager, removed the warning about the uncertainty method, drive me crazy and no one seems to care enough. 
//1.69 added some warnings about uncertainty method changes when read from preferences. 
//1.68 release, fixes for 9ID USAXS and other fixes listed 
//1.67 Release to fix Mask tool broken in 1.66 release. 
//1.66 fixed ListProRoutine which had troubles with links 
//1.65 minor changes, timed with Indra 2 release. 
//1.64 match current release number 
//1.61 added Monthly check for updates and reminder with citations 
//1.60  9IDC support changes
//1.59 Minor updates 
//1.58 Fixed GUI fonts/size controls issues on Widonws 7, modified Configure Nika preferences to include action on double click.
//1.57 New mailing list, SSRL SAXS support, fixes to 15ID SAXS etc. 
//1.56 More pinSAXS support (and not finished yet) and some changes to available color scales. 
//1.55 Fixed 9IDC Nexus support for 2/2012 Nexus files. 
//1.53 Added support for azimuthal angle output (useful when using ellipse for line profile)
//1.52 Added pinSAXS support for 9IDC USAXS instrument
//1.51 added Movie creation and Pilatus 300k
//1.50 minor update, fixed bug in calibration routien when correction for transmission was done before dark frame subtraction. 
//1.49 main fix is tilts. Number of other improvements. 
//1.48 added license for ANL, fixed compatibility problem for Igor 6.21 and TransformAxis1.2 upgrade
//version 1.47 fix for Igor 6.20
//version 1.46 fixed bug in Configuring the GUI parameters
//version 1.45 adds mpa/UC file type 
// version 1.44  fixed bug for adding Q axes in the image
// version 1.43  adds Pilatus loader. Unfinished, need to get test files to check 1M and 2M. 
// version 1.42 adds line profile support - including GISAXS geometry and ellipse.
//date: October 30, 2009 released as final 1.42 version. 
//This is main procedure file for NIKA 1 2-D SAS data conversion package


Menu "SAS 2D"
	"Main panel", NI1A_Convert2Dto1DMainPanel()
	help={"This should call the conversion routines for CCD data"}
	"Beam center and Geometry cor.", NI1_CreateBmCntrFile()
	help={"Tool to create beam center and geometry corrections."}
	"Create mask", NI1M_CreateMask()
	help={"Allows user to create mask based on selected measurement image"}
	"Create flood field", NI1_Create2DSensitivityFile()
	help={"Allows user to create pixel 2 d sensitivity file based on selected measured image"}
	"Image line profile", NI1_CreateImageLineProfileGraph()
	help={"Calls Image line profile (Wavemetrics provided) function"}
	"---"
	"GUI & uncertainty config",NI1_ConfigMain()
	help={"Configure method for uncertainity values for GUI behavior and for panels font sizes and font types"}
	"Configuration manager", NI1_GeometriesManager()
	help={"This enables switching among multiple Nika geometries, such as distances or wavelengths"}
	Submenu "Instrument configurations"
		"9IDC or 15IDD USAXS-SAXS-WAXS", NI1_9IDCConfigureNika()
		help={"Support for data from 9ID or9IDC (USAXS/SAXS) beamline at APS"}
		"RSoXS ALS soft energy instrument", NI1_RSoXSCreateGUI()
		help={"Support for data from ALS soft energy beamline"}
		"DND CAT", NI1_DNDConfigureNika()
		help={"Support for data from DND CAT (5ID) beamline at APS"}
		"SSRL Mat SAXS", NI1_SSRLSetup()
		help={"Support for data from SSRL Materials Scienc e SAXS beamline"}
		"TPA", NI1_TPASetup()
		help={"Support for data TPA  XML (SANS)"}
	end
	Submenu "Helpful tools"
		"Set all paths to the same place", NI1_SetAllPathsInNIka()
		help={"Sets the paths for Sample, Empty, Mask, Calibrant to the same place."}
	end
	"HouseKeeping", NI1_Cleanup2Dto1DFolder()
	help={"Removes large waves from this experiment, makes file much smaller. Resets junk... "}
	"Remove stored images", NI1_RemoveSavedImages()
	help={"Removes stored images - does not remove USED images, makes file much smaller. "}
	"---"
	"Open Nika web manual", IN2G_OpenWebManual("")
	help={"Opens Nika web manual in default web bropwser."}
	"Open Nika pdf manual", NI1_OpenNikaManual()
	help={"Opens Nika pdf manual in Acrobat or other system associated pdf reader."}
	"Remove Nika 1 macros", NI1_RemoveNika1Mac()
	help={"Removes the macros from the current experiment. Macros can be loaded when necessary again"}
	"Nika Mailing list signup and options", NI1_SignUpForMailingList()
	help={"Opens web page in the browser where you can sing up or control options for nika_users mailing list."}
	"Check for updates", NI1_CheckNikaUpdate(1)
	help={"Run Check for update and present citations to use in publications"}	
	"Close all Nika Panels and Windows", NI1_GMCloseAllNikaW()
	help={"Closes all Panels and windows from Nika. "}	
	"Check Igor display size", IN2G_CheckForGraphicsSetting(1)
	help={"Check if current display area is suitable for the code"}
	"About", NI1_AboutPanel()
	help={"Get Panel with info about this release of Nika macros"}
//	"---"
//	"Test Marquee", NI1B_Fitto2DGaussian1()
end


Menu "GraphMarquee"
        "Image Expand", NI1_MarExpandContractImage(1)
        "Image Contract", NI1_MarExpandContractImage(0)
End

Menu "Macros", dynamic
	NI1_MacrosMenuItem()
end

Function/S NI1_MacrosMenuItem()
	if((Exists("ShowResizeControlsPanel")==6)&& (!Exists("IR1_AboutPanel")))
		return "ShowResizeControlsPanel"
	else
		return ""
	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function NI1_OpenNikaManual()
	//this function writes batch file and starts the manual.
	//we need to write following batch file: "C:\Program Files\WaveMetrics\Igor Pro Folder\User Procedures\Irena\Irena manual.pdf"
	//on Mac we just fire up the Finder with Mac type path... 
		DoAlert /T="PDF manuals removed" 0, "pdf manuals are not distributed with the packages anymore. Use web manuals. If needed download pdf file from the web" 

//	//check where we run...
//		string WhereIsManual
//		string WhereAreProcedures=RemoveEnding(FunctionPath(""),"NI1_Main.ipf")
//		String manualPath = ParseFilePath(5,"Nika manual.pdf","*",0,0)
//       	String cmd 
//	
//	if (stringmatch(IgorInfo(2), "*Macintosh*"))
//             //  manualPath = "User Procedures:Irena:Irena manual.pdf"
//               sprintf cmd "tell application \"Finder\" to open \"%s\"",WhereAreProcedures+manualPath
//               ExecuteScriptText cmd
//      		if (strlen(S_value)>2)
////			DoAlert 0, S_value
//		endif
//
//	else 
//		//manualPath = "User Procedures\Irena\Irena manual.pdf"
//		//WhereIsIgor=WhereIsIgor[0,1]+"\\"+IN2G_ChangePartsOfString(WhereIsIgor[2,inf],":","\\")
//		WhereAreProcedures=ParseFilePath(5,WhereAreProcedures,"*",0,0)
//		whereIsManual = "\"" + WhereAreProcedures+manualPath+"\""
//		NewNotebook/F=0 /N=NewBatchFile
//		Notebook NewBatchFile, text=whereIsManual//+"\r"
//		SaveNotebook/O NewBatchFile as SpecialDirPath("Temporary", 0, 1, 0 )+"StartManual.bat"
//		KillWIndow/Z NewBatchFile
//		ExecuteScriptText "\""+SpecialDirPath("Temporary", 0, 1, 0 )+"StartManual.bat\""
//	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function NI1_SetAllPathsInNIka()
		DoWindow NI1A_Convert2Dto1DPanel
		if(!V_Flag)		//does nto exists, quit
			Abort "Main Nika windows does not exist, open it first"
		else
			DoWIndow/F NI1A_Convert2Dto1DPanel
		endif
		PathInfo/S Convert2Dto1DEmptyDarkPath
		NewPath/C/O/M="Select path to your data" Convert2Dto1DDataPath
		PathInfo Convert2Dto1DDataPath
		string pathInforStrL = S_Path
		NewPath/O/Q Convert2Dto1DEmptyDarkPath, pathInforStrL		
		SVAR MainPathInfoStr=root:Packages:Convert2Dto1D:MainPathInfoStr
		MainPathInfoStr = pathInforStrL
		SVAR/Z BCPathInfoStr=root:Packages:Convert2Dto1D:BCPathInfoStr
		if(!SVAR_Exists(BCPathInfoStr))
			NI1BC_InitCreateBmCntrFile()
			SVAR BCPathInfoStr=root:Packages:Convert2Dto1D:BCPathInfoStr
		endif
		NewPath/O/Q Convert2Dto1DBmCntrPath, pathInforStrL
		//PathInfo Convert2Dto1DBmCntrPath
		BCPathInfoStr=S_Path
		NewPath/O/Q Convert2Dto1DMaskPath, pathInforStrL
		//and refresh the listboxes for new paths...
		NI1BC_UpdateBmCntrListBox()	
		NI1A_UpdateDataListBox()	
		NI1A_UpdateEmptyDarkListBox()	
end

//****************************************************************************************
//****************************************************************************************
//****************************************************************************************

static Function AfterCompiledHook( )			//check if all windows are up to date to match their code

	//these are tools which have been upgraded to this functionality
	//Modeling II = LSQF2_MainPanel
//	string WindowProcNames="LSQF2_MainPanel=IR2L_MainCheckVersion;IR2H_ControlPanel=IR2H_MainCheckVersion;DataMiningTool=IR2M_MainCheckVersion;DataManipulationII=IR3M_MainCheckVersion;"
//	WindowProcNames+="IR1I_ImportData=IR1I_MainCheckVersion;IR2S_ScriptingToolPnl=IR2S_MainCheckVersion;IR1R_SizesInputPanel=IR1R_MainCheckVersion;IR1A_ControlPanel=IR1A_MainCheckVersion;"
//	WindowProcNames+="IR1P_ControlPanel=IR1P_MainCheckVersion;IR2R_ReflSimpleToolMainPanel=IR2R_MainCheckVersion;IR3DP_MainPanel=IR3GP_MainCheckVersion;"
//	WindowProcNames+="IR1V_ControlPanel=IR1V_MainCheckVersion;IR2D_ControlPanel=IR2D_MainCheckVersion;IR2Pr_ControlPanel=IR2Pr_MainCheckVersion;UnivDataExportPanel=IR2E_MainCheckVersion;"
//	WindowProcNames+="IR1D_DataManipulationPanel=IR1D_MainCheckVersion;"
	
//	IR2C_CheckWIndowsProcVersions(WindowProcNames)

	NI1_CheckNikaUpdate(0)
	IN2G_CheckForGraphicsSetting(0)
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function NI1_RemoveNika1Mac()
		Execute/P "DELETEINCLUDE \"NI1_Loader\""
		SVAR strChagne=root:Packages:Nika12DSASItem1Str
		strChagne= "Load Nika 2D SAS Macros"
		BuildMenu "Macros"
		Execute/P "COMPILEPROCEDURES "
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function NI1_SignUpForMailingList()
	DoAlert 1,"Your web browser will open page with the page where you can control your maling list options. OK?"
	if(V_flag==1)
		BrowseURL "http://www.aps.anl.gov/mailman/listinfo/nika_users"
	endif
End

//*****************************************************************************************************************
//*****************************************************************************************************************

Function NI1_AboutPanel()
	KillWIndow/Z About_Nika_1_Macros
 	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(173.25,101.75,490,370) as "About_Nika_1_Macros"
	DoWindow/C About_Nika_1_Macros
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 1,textrgb= (16384,28160,65280)
	DrawText 10,37,"Nika 1 macros Igor Pro 7 "
	SetDrawEnv fsize= 16,textrgb= (16384,28160,65280)
	DrawText 52,64,"@ ANL, 2017"
	DrawText 49,103,"Release "+num2str(CurrentNikaVersionNumber)
	DrawText 11,136,"To get help please contact: ilavsky@aps.anl.gov"
	DrawText 11,156,"http://usaxs.xray.aps.anl.gov/staff/ilavsky/index.html"

	DrawText 11,190,"Set of macros to convert 2D SAS images"
	DrawText 11,210,"into 1 D data"
	DrawText 11,230,"     "
	DrawText 11,250," "
	DrawText 11,265,"Igor 7 compatible"
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function NI1_RemoveSavedImages()
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:
	NewDataFOlder/S/O SavedImages
	string AllWaves=IN2G_CreateListOfItemsInFolder("root:SavedImages", 2)
	variable i
	For(i=0;i<ItemsInList(AllWaves);i+=1)
		Killwaves/Z $(StringFromList(i,AllWaves))
	endfor
	setDataFolder root:
	if(strlen(IN2G_CreateListOfItemsInFolder("root:SavedImages", 2))<2)
		KillDataFolder root:SavedImages
	endif
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//***************************************************************************************************************** 
//*****************************************************************************************************************
Function NI1_Cleanup2Dto1DFolder()

	string OldDf=getDataFolder(1)
	if(!DataFolderExists("root:Packages:Convert2Dto1D" ))
		abort
	endif
	setDataFolder root:Packages:Convert2Dto1D
	
	string ListOfWaves=IN2G_ConvertDataDirToList(DataFolderDir(2 ))
	string CurStr
	variable i, imax=ItemsInList(ListOfWaves)
	String ListOfWavesToKill
	ListOfWavesToKill="Rdistribution1D;Radius2DWave;AnglesWave;Qvector_;LUT;HistogramWv;Dspacing;Qvectorwidth;TwoTheta;Q2DWave;RadiusPix2DWave;"
	variable j

	For(i=0;i<imax;i+=1)
		CurStr = stringFromList(i,ListOFWaves)
		For(j=0;j<ItemsInList(ListOfWavesToKill);j+=1)
			if(stringmatch(CurStr, "*"+stringFromList(j,ListOfWavesToKill)+"*"))
				Wave killme=$(CurStr)
				KillWaves/Z killme
			endif
		endfor
	endfor
	KillWaves/Z CCImageToConvert_dis, DarkFieldData_dis,EmptyData_dis, MaskCCDImage, Calibrated2DDataSet, Pixel2DSensitivity_dis
	KillWaves/Z FloodFieldImg, MaxNumPntsLookupWv, MaxNumPntsLookupWvLBL, PixRadius2DWave, fit_BmCntrCCDImg,fit_BmCntrCCDImgX,fit_BmCntrCCDImgY
	KillWaves/Z BmCntrCCDImg,BmCntrDisplayImage, BmCntrDisplayImage, BmCntrCCDImg, xwave, xwaveT, ywave, ywaveT
	
	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_MarExpandContractImage(isExpand)
        Variable isExpand
        
        String imName= StringFromList(0,ImageNameList("",";"))
        String imInfo= ImageInfo("",imName,0)
        if( strlen(imInfo) == 0 )
                return 0        // no image
        endif
        
        String xa= StringByKey("XAXIS",imInfo)
        String ya= StringByKey("YAXIS",imInfo)
        
        GetMarquee/K $xa,$ya
        Variable x0= V_left, x1= V_right, y0= V_top, y1= V_bottom
        
        GetAxis/Q $xa
        Variable xmin= V_min, xmax= V_max
        GetAxis/Q $ya
        Variable ymin= V_min, ymax= V_max
        
        Variable fract= (x1-x0)/ (xmax-xmin)            // take x expand or contract as the single factor
        
        Variable yc= (y0+y1)/2, xc= (x0+x1)/2
        
        
        if( isExpand )
                x0= xc - fract*(xmax-xmin)/2
                x1= xc + fract*(xmax-xmin)/2
                y0= yc - fract*(ymax-ymin)/2
                y1= yc + fract*(ymax-ymin)/2
        else
                x0= xc -(xmax-xmin)/(2*fract)
                x1= xc +(xmax-xmin)/(2*fract)
                y0= yc -(ymax-ymin)/(2*fract)
                y1= yc +(ymax-ymin)/(2*fract)
                        
        endif
        
        if( xmin > xmax )
                SetAxis/R $xa,x0,x1
        else
                SetAxis $xa,x0,x1
        endif
        if(ymin > ymax )
                SetAxis/R $ya,y0,y1
        else
                SetAxis $ya,y0,y1
        endif
end
//***********************************************************
//***********************************************************
//***********************************************************

Function NI1_ConfigMain()		//call configuration routine
	IN2G_ConfigMain()	
	
	//this is main configuration utility... 
//	IN2G_InitConfigMain()
//	IN2G_ReadIrenaGUIPackagePrefs()	
//	DoWindow NI1_MainConfigPanel
//	if(!V_Flag)
//		Execute ("NI1_MainConfigPanel()")
//	else
//		DoWindow/F NI1_MainConfigPanel
//	endif

end

//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
////***********************************************************
//structure NikaPanelDefaults
//	uint32 version					// Preferences structure version number. 100 means 1.00.
////	uchar LegendFontType[50]		//50 characters for legend font name
//	uchar PanelFontType[50]		//50 characters for panel font name
//	uint32 defaultFontSize			//font size as integer
//	uint32 Uncertainity				//Uncertainity choice - 0 is Old, 1 is Std dev, and 2 is SEM
////	uint32 TagSize					//font size as integer
////	uint32 AxisLabelSize			//font size as integer
////	int16 LegendUseFolderName		//font size as integer
////	int16 LegendUseWaveName		//font size as integer
//	variable LastUpdateCheck
//	uint32 reserved[99]			// Reserved for future use
//	
//endstructure
//
////***********************************************************
////***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************

Function NI1_ReadNikaGUIPackagePrefs()
	IN2G_ReadIrenaGUIPackagePrefs(0)
end
//	//this reads old Nika preferences are recovers themmm
//	struct  NikaPanelDefaults Defs
//	struct  IrenaPanelDefaults DefsIrena
//	IN2G_InitConfigMain()
//	SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
//	NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize
//	NVAR SelectedUncertainity=root:Packages:IrenaConfigFolder:SelectedUncertainity
//	NVAR LastUpdateCheck=root:Packages:IrenaConfigFolder:LastUpdateCheck
////	NVAR LegendSize=root:Packages:IrenaConfigFolder:LegendSize
////	NVAR TagSize=root:Packages:IrenaConfigFolder:TagSize
////	NVAR AxisLabelSize=root:Packages:IrenaConfigFolder:AxisLabelSize
////	NVAR LegendUseFolderName=root:Packages:IrenaConfigFolder:LegendUseFolderName
////	NVAR LegendUseWaveName=root:Packages:IrenaConfigFolder:LegendUseWaveName
////	SVAR FontType=root:Packages:IrenaConfigFolder:FontType
//	variable DoWarning=0, pOld, pStdDev, pSEM
//	variable WhatToUse=0		//1 for new Irena, 2 for old Nika, 0 nothing found
//	string OldDf
//	//and new ones from version 1.74 use irena preferecnes
//	LoadPackagePreferences /MIS=1   "Irena" , "IrenaDefaultPanelControls.bin", 0 , DefsIrena
//	if(V_Flag==0)
//		if(Defs.Version<3)		//old Irena preferences, need to use old Nika preferences
//			LoadPackagePreferences /MIS=1   "Nika" , "NikaDefaultPanelControls.bin", 0 , Defs
//			if(V_flag==0)
//				WhatToUse=2
//			endif
//		else
//			WhatToUse = 1
//		endif
//	else
//		WhatToUse=0
//	endif
//	if(WhatToUse==2)			//Nika preferences... 
//		//print Defs
//		print "Read Nika Panels preferences from local machine and applied them. "
//		print "Note that this may have changed font size and type selection originally saved with the existing experiment."
//		print "IMPORTANT : this may have changed uncertainty calculation mehtod originally saved with the existing experiment."
//		print "To change them please use \"Configure default fonts and names\""
//		if(Defs.Version==1)		//Lets declare the one we know as 1
//			DefaultFontType		=	Defs.PanelFontType
//			DefaultFontSize 		= 	Defs.defaultFontSize
//			if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
//				DefaultGUIFont /Win   all= {DefaultFontType, DefaultFontSize, 0 }
//			else
//				DefaultGUIFont /Mac   all= {DefaultFontType, DefaultFontSize, 0 }
//			endif
//			//and now recover the stored other parameters, no action on these...
//		elseif(Defs.Version==2)		//Lets declare the one we know as 1
//			DefaultFontType		=	Defs.PanelFontType
//			DefaultFontSize 		= 	Defs.defaultFontSize
//			SelectedUncertainity	= 	Defs.Uncertainity
//			LastUpdateCheck 		=	Defs.LastUpdateCheck 
//			if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
//				DefaultGUIFont /Win   all= {DefaultFontType, DefaultFontSize, 0 }
//			else
//				DefaultGUIFont /Mac   all= {DefaultFontType, DefaultFontSize, 0 }
//			endif
//			//and now recover the stored other parameters, no action on these...
//
//			NVAR/z ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
//			NVAR/z ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
//			NVAR/z ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
//			if(!NVAR_Exists(ErrorCalculationsUseOld))
//				OldDf=GetDataFolder(1)
//				setDataFolder root:
//				NewDataFolder/S/O Packages
//				NewDataFolder/S/O Convert2Dto1D
//				variable/g ErrorCalculationsUseOld, ErrorCalculationsUseStdDev, ErrorCalculationsUseSEM
//				NVAR ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
//				NVAR ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
//				NVAR ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
//			endif
//			DoWarning=0
//			pOld = ErrorCalculationsUseOld
//			pStdDev = ErrorCalculationsUseStdDev
//			pSEM = ErrorCalculationsUseSEM
//			if(SelectedUncertainity==0)
//				ErrorCalculationsUseOld=1
//				ErrorCalculationsUseStdDev=0
//				ErrorCalculationsUseSEM=0
//			elseif(SelectedUncertainity==1)
//				ErrorCalculationsUseOld=0
//				ErrorCalculationsUseStdDev=1
//				ErrorCalculationsUseSEM=0
//			elseif(SelectedUncertainity==2)
//				ErrorCalculationsUseOld=0
//				ErrorCalculationsUseStdDev=0
//				ErrorCalculationsUseSEM=1
//			endif
//			if(ErrorCalculationsUseOld)
//				print "Uncertainty calculation method is set to \"Old method (see manual for description)\""
//			elseif(ErrorCalculationsUseStdDev)
//				print "Uncertainty calculation method is set to \"Standard deviation (see manual for description)\""
//			else
//				print "Uncertainty calculation method is set to \"Standard error of mean (see manual for description)\""
//			endif
//			NI1_SaveNikaGUIPackagePrefs(0)
//		elseif(WhatToUse==1)		//New irena preferences...
//			//print Defs
//			if(Defs.Version==3)		//Lets declare the one we know as 3
//				print "Read Irena/Nika Panels preferences from local machine and applied them. "
//				print "Note that this may have changed font size and type selection originally saved with the existing experiment."
//				print "IMPORTANT : this may have changed uncertainty calculation mehtod originally saved with the existing experiment."
//				print "To change them please use \"Configure default fonts and names\""
//				DefaultFontType			=	DefsIrena.PanelFontType
//				DefaultFontSize 		= 	DefsIrena.defaultFontSize
//				SelectedUncertainity	= 	DefsIrena.Uncertainity
//				LastUpdateCheck 		=	DefsIrena.LastUpdateCheckNika 
//				if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
//					DefaultGUIFont /Win   all= {DefaultFontType, DefaultFontSize, 0 }
//				else
//					DefaultGUIFont /Mac   all= {DefaultFontType, DefaultFontSize, 0 }
//				endif
//				//and now recover the stored other parameters, no action on these...
//	
//				NVAR/z ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
//				NVAR/z ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
//				NVAR/z ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
//				if(!NVAR_Exists(ErrorCalculationsUseOld))
//					OldDf=GetDataFolder(1)
//					setDataFolder root:
//					NewDataFolder/S/O Packages
//					NewDataFolder/S/O Convert2Dto1D
//					variable/g ErrorCalculationsUseOld, ErrorCalculationsUseStdDev, ErrorCalculationsUseSEM
//					NVAR ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
//					NVAR ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
//					NVAR ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
//				endif
//				DoWarning=0
//				pOld = ErrorCalculationsUseOld
//				pStdDev = ErrorCalculationsUseStdDev
//				pSEM = ErrorCalculationsUseSEM
//				if(SelectedUncertainity==0)
//					ErrorCalculationsUseOld=1
//					ErrorCalculationsUseStdDev=0
//					ErrorCalculationsUseSEM=0
//				elseif(SelectedUncertainity==1)
//					ErrorCalculationsUseOld=0
//					ErrorCalculationsUseStdDev=1
//					ErrorCalculationsUseSEM=0
//				elseif(SelectedUncertainity==2)
//					ErrorCalculationsUseOld=0
//					ErrorCalculationsUseStdDev=0
//					ErrorCalculationsUseSEM=1
//				endif
//				if(ErrorCalculationsUseOld)
//					print "Uncertainty calculation method is set to \"Old method (see manual for description)\""
//				elseif(ErrorCalculationsUseStdDev)
//					print "Uncertainty calculation method is set to \"Standard deviation (see manual for description)\""
//				else
//					print "Uncertainty calculation method is set to \"Standard error of mean (see manual for description)\""
//				endif
//				NI1_SaveNikaGUIPackagePrefs(0)
//			else
//				Print "unknown GUI controls"
//			endif
//		else
//			DoAlert 1, "Old version of GUI and Graph Fonts (font size and type preference) found. Do you want to update them now? These are set once on a computer and can be changed in \"Configure default fonts and names\"" 
//			if(V_Flag==1)
//				Execute("NI1_MainConfigPanel() ")
//			else
//			//	SavePackagePreferences /Kill   "Irena" , "IrenaDefaultPanelControls.bin", 0 , Defs	//does not work below 6.10
//			endif
//		endif
//	else 		//problem loading package defaults
//		DoAlert 1, "GUI and Graph defaults (font size and type preferences) are not set. Do you want to set them now? These are set once on a computer and can be changed in \"Configure default fonts and names\" dialog" 
//		if(V_Flag==1)
//			Execute("NI1_MainConfigPanel() ")
//		endif	
//	endif
//end
////***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
////***********************************************************
//Function NI1_SaveNikaGUIPackagePrefs(KillThem)
//	variable KillThem
//	
//	struct  IrenaPanelDefaults Defs
//	IN2G_InitConfigMain()
//	SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
//	NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize
//	NVAR SelectedUncertainity=root:Packages:IrenaConfigFolder:SelectedUncertainity
//	NVAR LastUpdateCheck = root:Packages:IrenaConfigFolder:LastUpdateCheck
//	NVAR LegendSize=root:Packages:IrenaConfigFolder:LegendSize
//	NVAR TagSize=root:Packages:IrenaConfigFolder:TagSize
//	NVAR AxisLabelSize=root:Packages:IrenaConfigFolder:AxisLabelSize
//	NVAR LegendUseFolderName=root:Packages:IrenaConfigFolder:LegendUseFolderName
//	NVAR LegendUseWaveName=root:Packages:IrenaConfigFolder:LegendUseWaveName
//	SVAR FontType=root:Packages:IrenaConfigFolder:FontType
//
//	Defs.Version					=		3
//	Defs.PanelFontType	 		= 		DefaultFontType
//	Defs.defaultFontSize 		= 		DefaultFontSize 
//	Defs.Uncertainity			= 		SelectedUncertainity
//	Defs.LastUpdateCheckNika	= 		LastUpdateCheck
//	Defs.AxisLabelSize 		= 		AxisLabelSize
//	Defs.LegendUseFolderName = 		LegendUseFolderName
//	Defs.LegendUseWaveName = 		LegendUseWaveName
//	Defs.LegendFontType	= 			FontType
//		
//
//	
//	if(KillThem)
//		SavePackagePreferences /Kill   "Nika" , "NikaDefaultPanelControls.bin", 0 , Defs		//does nto work below 6.10
//		IN2G_ReadIrenaGUIPackagePrefs()
//	else
//		SavePackagePreferences /FLSH=1   "Nika" , "NikaDefaultPanelControls.bin", 0 , Defs
//	endif
//end
////***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//
//Function NI1_InitConfigMain()
//
//	//initialize lookup parameters for user selected items.
//	string OldDf=getDataFolder(1)
//	SetDataFolder root:
//	NewDataFolder/O/S root:Packages
//	NewDataFolder/O/S root:Packages:IrenaConfigFolder
//	
//	string ListOfVariables
//	string ListOfStrings
//	//here define the lists of variables and strings needed, separate names by ;...
//	ListOfVariables="DefaultFontSize;SelectedUncertainity;LastUpdateCheck;"
//	ListOfStrings="ListOfKnownFontTypes;DefaultFontType;"
//	variable i
//	//and here we create them
//	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
//		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
//	endfor		
//										
//	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
//		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
//	endfor	
//		
//	SVAR ListOfKnownFontTypes=ListOfKnownFontTypes
//	ListOfKnownFontTypes=NI1_CreateUsefulFontList()
//	setDataFolder OldDf
//end
//
////***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//Function NI1_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//	
////	if (cmpstr(ctrlName,"LegendSize")==0)
////		NVAR LegendSize=root:Packages:IrenaConfigFolder:LegendSize
////		LegendSize = str2num(popStr)
////	endif
////	if (cmpstr(ctrlName,"TagSize")==0)
////		NVAR TagSize=root:Packages:IrenaConfigFolder:TagSize
////		TagSize = str2num(popStr)
////	endif
////	if (cmpstr(ctrlName,"AxisLabelSize")==0)
////		NVAR AxisLabelSize=root:Packages:IrenaConfigFolder:AxisLabelSize
////		AxisLabelSize = str2num(popStr)
////	endif
////	if (cmpstr(ctrlName,"FontType")==0)
////		SVAR FontType=root:Packages:IrenaConfigFolder:FontType
////		FontType = popStr
////	endif
//	if (cmpstr(ctrlName,"DefaultFontType")==0)
//		SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
//		DefaultFontType = popStr
//		NI1_ChangePanelCOntrolsStyle()
//	endif
//	if (cmpstr(ctrlName,"DefaultFontSize")==0)
//		NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize
//		DefaultFontSize = str2num(popStr)
//		NI1_ChangePanelCOntrolsStyle()
//	endif
//	IN2G_SaveIrenaGUIPackagePrefs(0)
//End
////***********************************************************
////***********************************************************
//***********************************************************
//***********************************************************
////***********************************************************
//Function NI1_KillPrefsButtonProc(ba) : ButtonControl
//	STRUCT WMButtonAction &ba
//
//	switch( ba.eventCode )
//		case 2: // mouse up
//			// click code here
//			if(stringmatch(ba.ctrlName,"OKBUtton"))
//				IN2G_SaveIrenaGUIPackagePrefs(0)
//				DoWIndow/K NI1_MainConfigPanel
//			elseif(stringmatch(ba.ctrlName,"DefaultValues"))
//				string defFnt
//				variable defFntSize
//				if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
//					defFnt="Tahoma"
//					defFntSize=12
//				else
//					defFnt="Geneva"
//					defFntSize=9
//				endif
//				SVAR ListOfKnownFontTypes=root:Packages:IrenaConfigFolder:ListOfKnownFontTypes
//				SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
//				DefaultFontType = defFnt
//				NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize
//				DefaultFontSize = defFntSize
//				NI1_ChangePanelCOntrolsStyle()
//				IN2G_SaveIrenaGUIPackagePrefs(0)
//				PopupMenu DefaultFontType,win=NI1_MainConfigPanel, mode=(1+WhichListItem(defFnt, ListOfKnownFontTypes))
//				PopupMenu DefaultFontSize,win=NI1_MainConfigPanel, mode=(1+WhichListItem(num2str(defFntSize), "8;9;10;11;12;14;16;18;20;24;26;30;"))
//			endif
//			break
//	endswitch
//	return 0
//End
//
////***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************

Function NI1_ChangePanelControlsStyle()

	SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
	NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize

	if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
		DefaultGUIFont /Win   all= {DefaultFontType, DefaultFontSize, 0 }
	else
		DefaultGUIFont /Mac   all= {DefaultFontType, DefaultFontSize, 0 }
	endif

end
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************

//Proc NI1_MainConfigPanel() 
//	PauseUpdate; Silent 1		// building window...
//	NewPanel /K=1/W=(282,48,707,270) as "Configure Nika Preferecnes"
//	DoWindow /C NI1_MainConfigPanel
//	TitleBox Info1 title="\Zr150Nika panels default fonts and names",pos={10,10},frame=0,fstyle=1, fixedSize=1,size={300,20},fColor=(1,4,52428)
//	TitleBox Info2 title="\Zr150Error type selection and GUI behavior",pos={10,110},frame=0,fstyle=1, fixedSize=1,size={300,20},fColor=(1,4,52428)
//	NI1A_Initialize2Dto1DConversion()
//	PopupMenu DefaultFontType,pos={15,40},size={113,21},proc=NI1_PopMenuProc,title="Panel Controls Font"
//	PopupMenu DefaultFontType,mode=(1+WhichListItem(root:Packages:IrenaConfigFolder:DefaultFontType, root:Packages:IrenaConfigFolder:ListOfKnownFontTypes))
//	PopupMenu DefaultFontType, popvalue=root:Packages:IrenaConfigFolder:DefaultFontType,value= #"IN2G_CreateUsefulFontList()"
//	PopupMenu DefaultFontSize,pos={15,70},size={113,21},proc=NI1_PopMenuProc,title="Panel Controls Font Size"
//	PopupMenu DefaultFontSize,mode=(1+WhichListItem(num2str(root:Packages:IrenaConfigFolder:DefaultFontSize), "8;9;10;11;12;14;16;18;20;24;26;30;"))
//	PopupMenu DefaultFontSize popvalue=num2str(root:Packages:IrenaConfigFolder:DefaultFontSize),value= #"\"8;9;10;11;12;14;16;18;20;24;26;30;\""
//	Button DefaultValues title="Default",pos={290,40},size={120,20}
//	Button DefaultValues proc=NI1_KillPrefsButtonProc
//	CheckBox DoubleClickConverts,pos={230,140},size={80,16},noproc,title="Double click converts ?", mode=0
//	CheckBox DoubleClickConverts,variable= root:Packages:Convert2Dto1D:DoubleClickConverts, help={"Check to convert files on double click in Files selection"}
//	CheckBox ErrorCalculationsUseOld,pos={10,140},size={80,16},proc=NI1_ConfigErrorsCheckProc,title="Use Old Uncertainity ?", mode=1
//	CheckBox ErrorCalculationsUseOld,variable= root:Packages:Convert2Dto1D:ErrorCalculationsUseOld, help={"Check to use Error estimates for before version 1.42?"}
//	CheckBox ErrorCalculationsUseStdDev,pos={10,160},size={80,16},proc=NI1_ConfigErrorsCheckProc,title="Use Std Devfor Uncertainity?", mode=1
//	CheckBox ErrorCalculationsUseStdDev,variable= root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev, help={"Check to use Standard deviation for Error estimates "}
//	CheckBox ErrorCalculationsUseSEM,pos={10,180},size={80,16},proc=NI1_ConfigErrorsCheckProc,title="Use SEM for Uncertainity?", mode=1
//	CheckBox ErrorCalculationsUseSEM,variable= root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM, help={"Check to use Standard error of mean for Error estimates"}
//
//	Button OKButton title="OK",pos={290,190},size={120,20}
//	Button OKButton proc=NI1_KillPrefsButtonProc
//EndMacro
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//Function NI1_ConfigErrorsCheckProc(cba) : CheckBoxControl
//	STRUCT WMCheckboxAction &cba
//
//	NVAR ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
//	NVAR ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
//	NVAR ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
//	NVAR SelectedUncertainity=root:Packages:IrenaConfigFolder:SelectedUncertainity
//
//	switch( cba.eventCode )
//		case 2: // mouse up
//			Variable checked = cba.checked
//			if(stringmatch(cba.ctrlName,"ErrorCalculationsUseOld"))
//				ErrorCalculationsUseOld = checked
//				ErrorCalculationsUseStdDev=!checked
//				ErrorCalculationsUseSEM=!checked
//				SelectedUncertainity=0
//			endif
//			if(stringmatch(cba.ctrlName,"ErrorCalculationsUseStdDev"))
//				ErrorCalculationsUseOld = !checked
//				ErrorCalculationsUseStdDev=checked
//				ErrorCalculationsUseSEM=!checked
//				SelectedUncertainity=1
//			endif
//			if(stringmatch(cba.ctrlName,"ErrorCalculationsUseSEM"))
//				ErrorCalculationsUseOld = !checked
//				ErrorCalculationsUseStdDev=!checked
//				ErrorCalculationsUseSEM=checked
//				SelectedUncertainity=2
//			endif
//			break
//	endswitch
//
//	return 0
//End
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//
//Function/S NI1_CreateUsefulFontList()
//
//	string SystemFontList=FontList(";")
//	string PreferredFontList="Times;Arial;Geneva;Palatino;Times New Roman;TImes Roman;Book Antiqua;"
//	PreferredFontList+="Courier;Lucida;Vardana;Monaco;Courier CE;Courier;"
//	
//	variable i
//	string UsefulList="", tempList=""
//	For(i=0;i<ItemsInList(PreferredFontList);i+=1)
//		tempList=stringFromList(i,PreferredFontList)
//		if(stringmatch(SystemFOntList, "*"+tempList+";*" ))
//			UsefulList+=tempList+";"
//		endif
//	endfor
//	return UsefulList
//end
//
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//**************************************************************** 
//**************************************************************** 
//***********************************
//***********************************

Function NI1_CheckNikaUpdate(CalledFromMenu)
	variable CalledFromMenu
	//CalledFromMenu=1 run always...
	IN2G_ReadIrenaGUIPackagePrefs(0)
	NVAR LastUpdateCheckNika=root:Packages:IrenaConfigFolder:LastUpdateCheckNika	
	if(datetime - LastUpdateCheckNika >30 * 24 * 60 * 60 || CalledFromMenu)
			//call check version procedure and advise user on citations
			NI1_CheckVersions()
			IN2G_SubmitCheckRecordToWeb("Nika "+num2str(CurrentNikaVersionNumber))
			LastUpdateCheckNika = datetime
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
static Function NI1_CheckVersions()
	string PackageString	
	//create list of Igor procedure files on this machine
	IN2G_ListIgorProcFiles()
	DoWIndow CheckForNikaUpdatePanel
	if(V_Flag)
		DoWIndow/F CheckForNikaUpdatePanel								
	else
		Execute("CheckForNikaUpdatePanel()")			
	endif
	//Nika code
	string OldDf=GetDataFolder(1)
	//create location for the results waves...
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:UseProcedureFiles
	variable/g InstalledNikaVersion
	variable/g WebNikaVersion		
	InstalledNikaVersion = IN2G_FindFileVersion("Boot Nika.ipf")	
	//now get the web based version.
	//NewPath  /O/Q TempPath  (SpecialDirPath("temporary", 0, 0, 0 ))
	//download the file
	//variable InstallHadFatalError
	//InstallHadFatalError = IN2G_DownloadFile("IgorCode/Igor Procedures/Boot Nika.ipf","TempPath", "Boot Nika.ipf")
	//sleep/s 1
	WebNikaVersion = IN2G_CheckForNewVersion("Nika")
	if(numtype(WebNikaVersion)!=0)
		Print "Check for latest Nika version failed. Check your Internet connection. Try later again..."
	endif
	//DeleteFile /Z /P=tempPath "Boot Nika.ipf"	
	SetDataFOlder OldDf
end	


//**************************************************************** 
////**************************************************************** 
////**************************************************************** 
////**************************************************************** 
//static Function NI1_ListIgorProcFiles()
//	GetFileFolderInfo/Q/Z/P=Igor "Igor Procedures"	
//	if(V_Flag==0)
//		NI1_ListProcFiles(S_Path,1 )
//	endif
//	GetFileFolderInfo/Q/Z NI1_GetIgorUserFilesPath()+"Igor Procedures:"
//	if(V_Flag==0)
//		NI1_ListProcFiles(NI1_GetIgorUserFilesPath()+"Igor Procedures:",0)
//	endif
//	KillPath/Z tempPath
//end
// //**************************************************************** 
////**************************************************************** 
////**************************************************************** 
////**************************************************************** 
//static Function NI1_ListProcFiles(PathStr, resetWaves)
//	string PathStr
//	variable resetWaves
//	String abortMessage	//HR Used if we have to abort because of an unexpected error
//	string OldDf=GetDataFolder(1)
//	//create location for the results waves...
//	NewDataFolder/O/S root:Packages
//	NewDataFolder/O/S root:Packages:UseProcedureFiles
//	//if this is top call to the routine we need to wipe out the waves so we remove old junk
//	string CurFncName=GetRTStackInfo(1)
//	string CallingFncName=GetRTStackInfo(2)
//	variable runningTopLevel=0
//	if(!stringmatch(CurFncName,CallingFncName))
//		runningTopLevel=1
//	endif
//	if(resetWaves)
//			Make/O/N=0/T FileNames		
//			Make/O/N=0/T PathToFiles
//			Make/O/N=0 FileVersions
//	endif
//	//if this was first call, now the waves are gone.
//	//and now we need to create the output waves
//	Wave/Z/T FileNames
//	Wave/Z/T PathToFiles
//	Wave/Z FIleVersions
//	If(!WaveExists(FileNames) || !WaveExists(PathToFiles) || !WaveExists(FIleVersions))
//		Make/O/T/N=0 FileNames, PathToFIles
//		Make/O/N=0 FileVersions
//		Wave/T FileNames
//		Wave/T PathToFiles
//		Wave FileVersions
//		//I am not sure if we really need all of those declarations, but, well, it should not hurt...
//	endif 
//	
//	//this is temporary path to the place we are looking into now...  
//	NewPath/Q/O tempPath, PathStr
//	if (V_flag != 0)		//HR Add error checking to prevent infinite loop
//		sprintf abortMessage, "Unexpected error creating a symbolic path pointing to \"%s\"", PathStr
//		Print abortMessage	// To make debugging easier
//		Abort abortMessage
//	endif
//	//list al items in this path
//	string ItemsInTheFolder= IndexedFile(tempPath,-1,"????")+IndexedDir(tempPath, -1, 0 )
//	//HR If there is a shortcut in "Igor Procedures", ItemsInTheFolder will include something like "HDF5 Browser.ipf.lnk". Windows shortcuts are .lnk files.	
//	
//	//remove all . files. 
//	ItemsInTheFolder = GrepList(ItemsInTheFolder, "^\." ,1)
//	//Now we removed all junk files on Macs (starting with .)
//	//now lets check what each of these files are and add to the right lists or follow...
//	variable i, imax=ItemsInList(ItemsInTheFolder)
//	string tempFileName, tempScraptext, tempPathStr
//	variable IamOnMac, isItXOP
//	if(stringmatch(IgorInfo(2),"Windows"))
//		IamOnMac=0
//	else
//		IamOnMac=1
//	endif
//	For(i=0;i<imax;i+=1)
//		tempFileName = stringfromlist(i,ItemsInTheFolder)
//		GetFileFolderInfo/Z/Q/P=tempPath tempFileName
//		isItXOP = IamOnMac * stringmatch(tempFileName, "*xop*" )
//		if(V_isAliasShortcut)
//			//HR If tempFileName is "HDF5 Browser.ipf.lnk", or any other shortcut to a file, S_aliasPath is a path to a file, not a folder.
//			//HR Thus the "NewPath tempPath" command will fail.
//			//HR Thus tempPath will retain its old value, causing you to recurse the same folder as before, resulting in an infinite loop.
//			
//			//is alias, need to follow and look further. Use recursion...
//			if(strlen(S_aliasPath)>3)		//in case user has stale alias, S_aliasPath has 0 length. Need to skip this pathological case. 
//				//HR Recurse only if S_aliasPath points to a folder. I don't really know what I'm doing here but this seems like it will prevent the infinite loop.
//				GetFileFolderInfo/Z/Q/P=tempPath S_aliasPath	
//				isItXOP = IamOnMac * stringmatch(S_aliasPath, "*xop*" )
//				if (V_flag==0 && V_isFolder&&!isItXOP)		//this is folder, so all items in the folder are included... Except XOP is folder too... 
//					NI1_ListProcFiles(S_aliasPath, 0)
//				elseif(V_flag==0 && (!V_isFolder || isItXOP))	//this is link to file. Need to include the info on the file...
//					//*************
//					Redimension/N=(numpnts(FileNames)+1) FileNames, PathToFiles,FileVersions
//					tempFileName =stringFromList(ItemsInList(S_aliasPath,":")-1, S_aliasPath,":")
//					tempPathStr = RemoveFromList(tempFileName, S_aliasPath,":")
//					FileNames[numpnts(FileNames)] = tempFileName
//					PathToFiles[numpnts(FileNames)] = tempPathStr
//					//try to get version from #pragma version = ... This seems to be the most robust way I found...
//					NewPath/Q/O tempPath, tempPathStr
//					if(stringmatch(tempFileName, "*.ipf"))
//						Grep/P=tempPath/E="(?i)^#pragma[ ]*version[ ]*=[ ]*" tempFileName as "Clipboard"
//						sleep/s (0.02)
//						tempScraptext = GetScrapText()
//						if(strlen(tempScraptext)>10)		//found line with #pragma version"
//							tempScraptext = replaceString("#pragma",tempScraptext,"")	//remove #pragma
//							tempScraptext = replaceString("version",tempScraptext,"")		//remove version
//							tempScraptext = replaceString("=",tempScraptext,"")			//remove =
//							tempScraptext = replaceString("\t",tempScraptext,"  ")			//remove optional tabulators, some actually use them. 
//							tempScraptext = removeending(tempScraptext," \r")			//remove optional tabulators, some actually use them. 
//							//forget about the comments behind the text. 
//		                                       //str2num is actually quite clever in this and converts start of the string which makes sense. 
//							FileVersions[numpnts(FileNames)]=str2num(tempScraptext)
//						else             //no version found, set to NaN
//							FileVersions[numpnts(FileNames)]=NaN
//						endif
//					else                    //no version for non-ipf files
//						FileVersions[numpnts(FileNames)]=NaN
//					endif
//				//************
//
//
//				endif
//			endif
//			//and now when we got back, fix the path definition to previous or all will crash...
//			NewPath/Q/O tempPath, PathStr
//			if (V_flag != 0)		//HR Add error checking to prevent infinite loop
//				sprintf abortMessage, "Unexpected error creating a symbolic path pointing to \"%s\"", PathStr
//				Print abortMessage	// To make debugging easier
//				Abort abortMessage
//			endif
//		elseif(V_isFolder&&!isItXOP)	
//			//is folder, need to follow into it. Use recursion.
//			NI1_ListProcFiles(PathStr+tempFileName+":", 0)
//			//and fix the path back or all will fail...
//			NewPath/Q/O tempPath, PathStr
//			if (V_flag != 0)		//HR Add error checking to prevent infinite loop
//				sprintf abortMessage, "Unexpected error creating a symbolic path pointing to \"%s\"", PathStr
//				Print abortMessage	// To make debugging easier
//				Abort abortMessage
//			endif
//		elseif(V_isFile||isItXOP)
//			//this is real file. Store information as needed. 
//			Redimension/N=(numpnts(FileNames)+1) FileNames, PathToFiles,FileVersions
//			FileNames[numpnts(FileNames)-1] = tempFileName
//			PathToFiles[numpnts(FileNames)-1] = PathStr
//			//try to get version from #pragma version = ... This seems to be the most robust way I found...
//			if(stringmatch(tempFileName, "*.ipf"))
//				Grep/P=tempPath/E="(?i)^#pragma[ ]*version[ ]*=[ ]*" tempFileName as "Clipboard"
//				sleep/s(0.02)
//				tempScraptext = GetScrapText()
//				if(strlen(tempScraptext)>10)		//found line with #pragma version"
//					tempScraptext = replaceString("#pragma",tempScraptext,"")	//remove #pragma
//					tempScraptext = replaceString("version",tempScraptext,"")		//remove version
//					tempScraptext = replaceString("=",tempScraptext,"")			//remove =
//					tempScraptext = replaceString("\t",tempScraptext,"  ")			//remove optional tabulators, some actually use them. 
//					//forget about the comments behind the text. 
//                                       //str2num is actually quite clever in this and converts start of the string which makes sense. 
//					FileVersions[numpnts(FileNames)-1]=str2num(tempScraptext)
//				else             //no version found, set to NaN
//					FileVersions[numpnts(FileNames)-1]=NaN
//				endif
//			else                    //no version for non-ipf files
//				FileVersions[numpnts(FileNames)-1]=NaN
//			endif
//		endif
//	endfor
////	if(runningTopLevel)
////		//some output here...
////		print "Found   "+num2str(numpnts(FileNames))+"  files in   "+PathStr+" folder, its subfolders and linked folders and subfolders"
////		KillPath/Z tempPath
////	endif
// 
//	setDataFolder OldDf
//end
//
//
////***********************************
////***********************************
////***********************************
////***********************************
//static Function /S NI1_Windows2IgorPath(pathIn)
//	String pathIn
//	String pathOut = ParseFilePath(5, pathIn, ":", 0, 0)
//	return pathOut
//End
////***********************************
////***********************************
////***********************************
////***********************************
//
//static Function/S NI1_GetIgorUserFilesPath()
//	// This should be a Macintosh path but, because of a bug prior to Igor Pro 6.20B03
//	// it may be a Windows path.
//	String path = SpecialDirPath("Igor Pro User Files", 0, 0, 0)
//	path = NI1_Windows2IgorPath(path)
//	return path
//End
//
////***********************************
//***********************************
////**************************************************************** 
////**************************************************************** 
//
//static Function NI1_DownloadFile(StringWithPathAndname,LocalPath, LocalName)
//	string StringWithPathAndname, LocalPath, LocalName
//
//	variable InstallUsingLocalCopy = 0
//	variable InstallUsinghttp = 1
//	variable i
//	variable APSError=0
//	variable OtherError=0
//	Variable error
//	if(InstallUsingLocalCopy)		 
//		string tempFldrNm
//		tempFldrNm = removeFromList("IgorCode",StringWithPathAndname,"/")
//		PathInfo LocalCopyForInstallation
//		if(V_Flag==0)		//local copy path was not found.
//			//let's try to find in where Igor experiment started from, that path is known as "home"
//			string ItemsInTheFolder= IndexedDir(home, -1, 0 )
//			if(stringmatch(ItemsInTheFolder, "*IgorCode;*" ))
//				PathInfo/S home
//				NewPath /C/O/Q  LocalCopyForInstallation, S_Path+"IgorCode:"
//				Print "Found IgorCode folder in location where this experiment started, using that folder as file source"
//			else		
//				NewPath /C/M="Find Folder called \"IgorCode\""/O/Q  LocalCopyForInstallation
//				if(V_Flag!=0)
//					abort "Local copy of Installation files not found and user cancelled. Visit: http://usaxs.xray.aps.anl.gov/staff/ilavsky/Nika.html if you want to download it" 
//				endif
//			endif
//		endif
//		PathInfo LocalCopyForInstallation
//		GetFileFolderInfo  /P=$(LocalPath) /Q /Z S_Path+ReplaceString("/", tempFldrNm, ":")
//		if(V_Flag!=0)
//			NewPath /C/M="Find Folder called \"IgorCode\""/O/Q  LocalCopyForInstallation
//		endif
//		PathInfo LocalCopyForInstallation
//		CopyFile /O/P=$(LocalPath)/Z S_Path+ReplaceString("/", tempFldrNm, ":")  as LocalName 
//		// Remove ReadOnly property from the file. This is important on WIndows when copying from CD or DVD
//		SetFileFolderInfo/P=$(LocalPath)/RO=0 LocalName
//	else
//		string httpurl="http://ftp.xray.aps.anl.gov/usaxs/"
//		//string url="http://ftp.xray.aps.anl.gov/usaxs/"		//this is http address for future use with URLencode, URLdecode, and FetchURL
//		String httpPath = httpurl+StringWithPathAndname	//HR Use local variable for easier debugging.
//		httpPath =  ReplaceString(" ", httpPath, "%20")		//handle just spaces here... 
//		String fileBytes, tempPathStr
//		fileBytes = FetchURL(httpPath)
//		error = GetRTError(1)
//		if(error!=0)
//			 print "file: "+httpPath+" download FAILED, this was http download attempt No: "+num2str(i)
//			 print "Trying to download same file using ftp"
//			 tempPathStr = ReplaceString("http://ftp.xray.aps.anl.gov/usaxs/", httpPath, "ftp://ftp.xray.aps.anl.gov/pub/usaxs/")
//			 fileBytes = FetchURL(tempPathStr)
//			 error = GetRTError(1)
//			 if(error!=0)
//					print "file: "+tempPathStr+" download FAILED also using ftp "
//					Print "*************         S E R V E R      E R R O R                 ****************"
//					Print "**** Please, report problem to ilavsky@aps.anl.gov  the following:"
//					Print "Failed to get from http/ftp server following file.....   " + StringWithPathAndname
//					Print Date() +"   "+time()
//					print "Igor version :"+IgorInfo(3)
//					print "********************  end of error message  ********************"
//					OtherError=1
//			 else
//				 print "file: "+tempPathStr+" downloaded succesfully by ftp"
//			 endif
//		  endif
//			if(error==0)
//				Variable refNum
//				Open/P=$(LocalPath)  refNum as LocalName
//				FBinWrite refNum, fileBytes
//				Close refNum
//				SetFileFolderInfo/P=$(LocalPath)/RO=0 LocalName		
//			endif
//	endif
//	variable nosuccess
//	if(V_Flag!=0)
//		nosuccess=1
//	endif
//	return OtherError
//	
//end
//
////**************************************************************** 
////**************************************************************** 
//***********************************
//***********************************


//Motofit paper [J. Appl. Cryst. 39, 273-276]
//http://scripts.iucr.org/cgi-bin/paper?S0021889806005073
//J. Appl. Cryst. (2006). 39, 273-276    [ doi:10.1107/S0021889806005073 ]
//A. Nelson, Co-refinement of multiple-contrast neutron/X-ray reflectivity data using MOTOFIT
//



Function NI1_CheckVersionButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"OpenNikaWebPage"))
				//open web page with Nika
				BrowseURL "http://usaxs.xray.aps.anl.gov/staff/ilavsky/nika.html"
			endif
			if(stringmatch(ba.ctrlName,"OpenNikaManuscriptWebPage"))
				//open web page with Nika
				BrowseURL "http://dx.doi.org/10.1107/S0021889812004037"
			endif
			if(stringmatch(ba.ctrlName,"OpenGCManuscriptWebPage"))
				//doi:10.1007/s11661-009-9950-x
				BrowseURL "http://www.jomgateway.net/ArticlePage.aspx?DOI=10.1007/s11661-009-9950-x"
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

Window CheckForNikaUpdatePanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(116,68,880,400)/K=1 as "Nika check for updates"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 3,textrgb= (0,0,65535)
	DrawText 114,37,"Once-per-month reminder to check for Nika update"
	SetDrawEnv fsize= 14,fstyle= 3,textrgb= (65535,0,0)
	DrawText 27,110,"Reminder: When publishing data reduced using Nika package, please cite following manuscripts:"
	SetDrawEnv textrgb= (0,0,65535)
	DrawText 27,133,"J. Ilavsky Nika: software for two-dimensional data reduction "
	SetDrawEnv textrgb= (0,0,65535)
	DrawText 27,158,"J. Appl. Cryst. (2012). 45, 324–328"
	SetDrawEnv textrgb= (0,0,65535)
	DrawText 27,205,"Glassy Carbon Absolute Int. Calibration: F. Zhang, J. Ilavsky, G. G. Long, J. P.G. Quintana, "
	SetDrawEnv textrgb= (0,0,65535)
	DrawText 27,230,"A. J. Allen, and P. Jemian, Glassy Carbon as an Absolute Intensity Calibration Standard"
	SetDrawEnv textrgb= (0,0,65535)
	DrawText 27,255,"for Small-Angle Scattering, MMTA, DOI: 10.1007/s11661-009-9950-x"

	SetDrawEnv fstyle= 2,fsize= 10,textrgb= (0,0,0)
	DrawText 10,320,"This tool runs automatically every 30 days on each computer. It can be also called from the SAS2D menu as \"Check for updates\""

	SetVariable InstalledNikaVersion,pos={48,56},size={199,15},bodyWidth=100,title="Installed Nika Version"
	SetVariable InstalledNikaVersion,help={"This is the current Nika version installed"}
	SetVariable InstalledNikaVersion,fStyle=1
	SetVariable InstalledNikaVersion,limits={0,0,0},value= root:Packages:UseProcedureFiles:InstalledNikaVersion,noedit= 1
	SetVariable WebNikaVersion,pos={297,56},size={183,15},bodyWidth=100,title="Web Nika Version"
	SetVariable WebNikaVersion,help={"This is the current Nika version installed"}
	SetVariable WebNikaVersion,fStyle=1
	SetVariable WebNikaVersion,limits={0,0,0},value= root:Packages:UseProcedureFiles:WebNikaVersion,noedit= 1
	Button OpenNikaWebPage,pos={551,53},size={150,20},proc=NI1_CheckVersionButtonProc,title="Open Nika web page"
	Button OpenNikaManuscriptWebPage,pos={551,143},size={150,20},proc=NI1_CheckVersionButtonProc,title="Manuscript web page"
	Button OpenGCManuscriptWebPage,pos={551,240},size={150,20},proc=NI1_CheckVersionButtonProc,title="Manuscript web page"
EndMacro
//**************************************************************** 
//**************************************************************** 
//***********************************

//**************************************************************************
Function NI1_GeometriesManager()
	//initialize first...
	string OldDF=GetDataFolder(1)
	setDataFolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:NikaGeometries
	String/G CurrentGeomName, ListOfGeomsSaved
	variable/g CleanupTheFolderPriorSave
	if(strlen(CurrentGeomName)<1)
		CurrentGeomName = "Not saved"
	endif
	ListOfGeomsSaved = IN2G_ConvertDataDirToList(DataFolderDir(1))
	if(strlen(ListOfGeomsSaved)<1)
		ListOfGeomsSaved = "None saved"
	endif
	
	
	DoWIndow NI1_GeometriesManagerPanel
	if(V_Flag)
		DoWindow/F NI1_GeometriesManagerPanel
	else
		Execute ("NI1_GeometriesManagerPanel()")
	endif
	setDataFolder oldDf
end

//**************************************************************************
//**************************************************************************
//**************************************************************************
Function NI1_GMLoadGeometries(LoadThisGeom)
	STRING LoadThisGeom
	
	if(stringMatch(LoadThisGeom,"---")||stringmatch(LoadThisGeom,"None Saved")||stringmatch(LoadThisGeom,"_none_"))
		return 0
	endif
	string OldDF=GetDataFolder(1)
	SetDataFolder root:Packages:NikaGeometries
	SVAR CurrentGeomName = root:Packages:NikaGeometries:CurrentGeomName
	SVAR ListOfGeomsSaved = root:Packages:NikaGeometries:ListOfGeomsSaved

	DoAlert /T="What do we do with current Geometries?" 2, "Current Geometries : "+CurrentGeomName+". Do you want to save it?"
		if(V_Flag==3)
			abort
		elseif(V_Flag==2)
			
		elseif(V_Flag==1)
			NI1_GMSaveGeometries()
		endif		
	NI1_GMCloseAllNikaW() 	
	KillDataFolder root:Packages:Convert2Dto1D
	DuplicateDataFolder $(LoadThisGeom), root:Packages:Convert2Dto1D
	//restore paths . Use strings in the root:Packages:Convert2Dto1D folder
	SVAR/Z Convert2Dto1DDataPathS=root:Packages:Convert2Dto1D:Convert2Dto1DDataPathS
	SVAR/Z Convert2Dto1DEmptyDarkPathS=root:Packages:Convert2Dto1D:Convert2Dto1DEmptyDarkPathS
	SVAR/Z Convert2Dto1DBmCntrPathS=root:Packages:Convert2Dto1D:Convert2Dto1DBmCntrPathS
	SVAR/Z Convert2Dto1DMaskPathS=root:Packages:Convert2Dto1D:Convert2Dto1DMaskPathS
	if(SVAR_Exists(Convert2Dto1DDataPathS))
		NewPath/O/Q Convert2Dto1DDataPath, Convert2Dto1DDataPathS
		NewPath/O/Q Convert2Dto1DEmptyDarkPath, Convert2Dto1DEmptyDarkPathS
		NewPath/O/Q Convert2Dto1DBmCntrPath, Convert2Dto1DBmCntrPathS
		NewPath/O/Q Convert2Dto1DMaskPath, Convert2Dto1DMaskPathS
		print "Restored original paths to data"
	endif
	//Ok, paths are stored... 

	ListOfGeomsSaved = IN2G_ConvertDataDirToList(DataFolderDir(1)) 
	CurrentGeomName = LoadThisGeom
	PopupMenu RestoreGeometries,win=NI1_GeometriesManagerPanel,value= #"root:Packages:NikaGeometries:ListOfGeomsSaved", mode=0
	setDataFolder oldDf
	NI1A_Convert2Dto1DMainPanel()
end

//**************************************************************************
//**************************************************************************
//**************************************************************************
Function NI1_GMDeleteGeom()
	string OldDF=GetDataFolder(1)
	SetDataFolder root:Packages:NikaGeometries
	SVAR CurrentGeomName = root:Packages:NikaGeometries:CurrentGeomName
	SVAR ListOfGeomsSaved = root:Packages:NikaGeometries:ListOfGeomsSaved
	ListOfGeomsSaved = IN2G_ConvertDataDirToList(DataFolderDir(1)) 
	STRING DeleteThisGeom=stringFromList(0,ListOfGeomsSaved)
	Prompt DeleteThisGeom, "Select Geometries to delete", popup, ListOfGeomsSaved
	DoPrompt "Deleting saved Geometries. This cannot be undone!", DeleteThisGeom
	if (V_Flag)
		abort								// User canceled
	endif

	DoAlert /T="Are you sure?" 2, "You are about to delete Geometries : "+DeleteThisGeom+". Are you sure?"
		if(V_Flag==3)
			abort
		elseif(V_Flag==2)
			abort
		elseif(V_Flag==1)
			KillDataFolder $(DeleteThisGeom)
		endif		
	ListOfGeomsSaved = IN2G_ConvertDataDirToList(DataFolderDir(1)) 
	setDataFolder oldDf
end

//**************************************************************************
//**************************************************************************
//**************************************************************************
Function NI1_GMCreateNewGeom()
	STRING LoadThisGeom
	string OldDF=GetDataFolder(1)
	SetDataFolder root:Packages:NikaGeometries
	SVAR CurrentGeomName = root:Packages:NikaGeometries:CurrentGeomName
	SVAR ListOfGeomsSaved = root:Packages:NikaGeometries:ListOfGeomsSaved

	DoAlert /T="What do we do with current Configuration?" 2, "Last name for this Configuration was : "+CurrentGeomName+". Do you want to save it?"
		if(V_Flag==3)
			abort
		elseif(V_Flag==2)
			
		elseif(V_Flag==1)
			NI1_GMSaveGeometries()
		endif		
	variable WasNI1_9IDCConfigPanel
	DoWIndow NI1_9IDCConfigPanel
	if(V_Flag)
		WasNI1_9IDCConfigPanel=1
	else
		WasNI1_9IDCConfigPanel=0
	endif
	NI1_GMCloseAllNikaW() 	
	KillDataFolder root:Packages:Convert2Dto1D
	KillDataFolder/Z root:Packages:NexusImportTMP:
	ListOfGeomsSaved = IN2G_ConvertDataDirToList(DataFolderDir(1)) 
	CurrentGeomName = "Not saved"
	PopupMenu RestoreGeometries,win=NI1_GeometriesManagerPanel,value= #"root:Packages:NikaGeometries:ListOfGeomsSaved", mode=0
	NI1A_Convert2Dto1DMainPanel()
	if(WasNI1_9IDCConfigPanel)
		NI1_9IDCConfigureNika()
	endif
	setDataFolder oldDf
end

//**************************************************************************
//**************************************************************************
//**************************************************************************
Function NI1_GMSaveGeometries()
	string OldDF=GetDataFolder(1)
	SetDataFolder root:Packages:NikaGeometries
	SVAR CurrentGeomName = root:Packages:NikaGeometries:CurrentGeomName
	String NewSaveName
	if(stringmatch(CurrentGeomName,"Not saved"))
		NewSaveName = "SavedGeom_"+Secs2Date(DateTime,-2)
	else
		NewSaveName = CurrentGeomName
	endif
	Prompt NewSaveName, "Enter short name, will be made in Igor folder name"
	DoPrompt "Input name for the current Geometries", NewSaveName
	if (V_Flag)
		abort								// User canceled
	endif
	NewSaveName = CleanupName(NewSaveName, 1 )
	if(DataFolderExists(NewSaveName ))
		DoAlert /T="New folder name conflict"  2, "The Configuration "+NewSaveName+" already exists, do you want to overwrite (Yes), create unique name (No), or cancel?"
		if(V_Flag==3)
			abort
		elseif(V_Flag==2)
			NewSaveName = UniqueName(NewSaveName, 11, 0 )
		elseif(V_Flag==1)
			KillDataFolder NewSaveName
		endif		
	endif
	NVAR CleanupTheFolderPriorSave = root:Packages:NikaGeometries:CleanupTheFolderPriorSave
	if(CleanupTheFolderPriorSave)
		NI1_Cleanup2Dto1DFolder()				//lets clean up the folder to make it smaller.... 
	endif
	//save paths so we can restore them later. Use strings in the root:Packages:Convert2Dto1D folder
	string/g root:Packages:Convert2Dto1D:Convert2Dto1DDataPathS
	string/g root:Packages:Convert2Dto1D:Convert2Dto1DEmptyDarkPathS
	string/g root:Packages:Convert2Dto1D:Convert2Dto1DBmCntrPathS
	string/g root:Packages:Convert2Dto1D:Convert2Dto1DMaskPathS
	SVAR Convert2Dto1DDataPathS=root:Packages:Convert2Dto1D:Convert2Dto1DDataPathS
	SVAR Convert2Dto1DEmptyDarkPathS=root:Packages:Convert2Dto1D:Convert2Dto1DEmptyDarkPathS
	SVAR Convert2Dto1DBmCntrPathS=root:Packages:Convert2Dto1D:Convert2Dto1DBmCntrPathS
	SVAR Convert2Dto1DMaskPathS=root:Packages:Convert2Dto1D:Convert2Dto1DMaskPathS
	PathInfo Convert2Dto1DDataPath
	Convert2Dto1DDataPathS = S_path
	PathInfo Convert2Dto1DEmptyDarkPath
	Convert2Dto1DEmptyDarkPathS = S_path
	PathInfo Convert2Dto1DBmCntrPath
	Convert2Dto1DBmCntrPathS = S_path
	PathInfo Convert2Dto1DMaskPath
	Convert2Dto1DMaskPathS = S_path
	//Ok, paths are stored... 
	DuplicateDataFolder root:Packages:Convert2Dto1D, $(NewSaveName)
	SVAR ListOfGeomsSaved = root:Packages:NikaGeometries:ListOfGeomsSaved
	SVAR CurrentGeomName = root:Packages:NikaGeometries:CurrentGeomName
	ListOfGeomsSaved = IN2G_ConvertDataDirToList(DataFolderDir(1)) 
	CurrentGeomName = NewSaveName
	
	PopupMenu RestoreGeometries,win=NI1_GeometriesManagerPanel,value=#"root:Packages:NikaGeometries:ListOfGeomsSaved", mode=0

	
	setDataFolder oldDf
end
//**************************************************************************
//**************************************************************************
//**************************************************************************

Function NI1_GMCloseAllNikaW() 		//close all open panels and windows
	string ListOfNikaWindows="NI1A_Convert2Dto1DPanel;CCDImageToConvertFig;LineuotDisplayPlot_Q;LineuotDisplayPlot_D;LineuotDisplayPlot_T;"
	ListOfNikaWindows+="Sample_Information;SquareMapIntvsPixels;NI1_CreateBmCntrFieldPanel;CCDImageForBmCntr;NI1M_ImageROIPanel;CCDImageForMask;"
	ListOfNikaWindows+="EmptyOrDarkImage;NI1_CreateFloodFieldPanel;NI1_MainConfigPanel;NI1_9IDCConfigPanel;Instructions_9IDC;"
	variable i
	string TempNm
	For(i=0;i<ItemsInList(ListOfNikaWindows);i+=1)
		TempNm = stringFromList(i,ListOfNikaWindows)
		KillWIndow/Z $TempNm
 	endfor
	//
end
//**************************************************************************
//**************************************************************************
//**************************************************************************

Function NI1_GMButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"SaveGeometries"))
				NI1_GMSaveGeometries()
			endif
			if(stringmatch(ba.ctrlName,"NewGeometries"))
				NI1_GMCreateNewGeom()
			endif
			if(stringmatch(ba.ctrlName,"DeleteGeometries"))
				NI1_GMDeleteGeom()
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**************************************************************************
//**************************************************************************
//**************************************************************************

Function NI1_GMPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(stringmatch(pa.ctrlName,"RestoreGeometries"))
				NI1_GMLoadGeometries(popStr)
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**************************************************************************
//**************************************************************************
//**************************************************************************

Window NI1_GeometriesManagerPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(600,45,1000,337) as "NIka Configuration manager"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,textrgb= (16385,16388,65535)
	DrawText 76,17,"ika Configuration manager"
	SetDrawEnv fsize= 16,textrgb= (16385,16388,65535)
	DrawText 113,25,"Nika Configuration manager"
	DrawText 15,45,"Save and restore Nika Configurations + switch between them"
	DrawText 15,60,"as needed. Please note, that this is very memory intensive "
	DrawText 15,75,"and creates huge Igor files. Delete Configs when no more needed."
	DrawText 15,90,"When changing Configurations, all Nika windows are closed."
	DrawText 15,105,"You need to reopen them. "
	Button NewGeometries,pos={99,123},size={200,20},proc=NI1_GMButtonProc,title="Create New Configuration"
	Button NewGeometries,help={"This will create a new (empty) Nika. Existing one can be saved and named."}
	Button SaveGeometries,pos={99,150},size={200,20},proc=NI1_GMButtonProc,title="Save Current Configuration"
	Button SaveGeometries,help={"This will save current Nika configuration so it can be restored later."}
	Setvariable CurrentGeomName, pos={5,200}, size={300,25}, title="Last Saved/loaded Config name: ", variable=root:Packages:NikaGeometries:CurrentGeomName, disable=2
	Setvariable CurrentGeomName, help={"Name of last saved - or loaded - geometry. Keep in mind yuou might have changed it since the last save/load operation."}
	checkbox CleanupTheFolderPriorSave, pos={80,175}, size={200,15}, variable=root:Packages:NikaGeometries:CleanupTheFolderPriorSave, noproc, title="Clean up folder before saving? (Housekeeping)"
	checkbox CleanupTheFolderPriorSave,help={"If checked, the geometry being stored will be cleaned up to save space."}
	PopupMenu RestoreGeometries,pos={99,228},size={200,20},proc=NI1_GMPopMenuProc,title="Load Stored Configurations :"
	PopupMenu RestoreGeometries,mode=0,value= root:Packages:NikaGeometries:ListOfGeomsSaved
	PopupMenu RestoreGeometries,help={"This is list of saved geometries available in this Igor experiment."}
	Button DeleteGeometries,pos={99,263},size={200,20},proc=NI1_GMButtonProc,title="Delete Saved Configuration"
	Button DeleteGeometries,help={"Will let you select from existing saved geometries one to delete."}
EndMacro
//**************************************************************************
//**************************************************************************
//**************************************************************************
