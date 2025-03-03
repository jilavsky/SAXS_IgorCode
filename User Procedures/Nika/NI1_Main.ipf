#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method.
#pragma version=1.85
#pragma IgorVersion=8.04

//DO NOT renumber Main files every time, these are main release numbers...

constant CurrentNikaVersionNumber = 1.86
constant FixBackgroundOversubScale=1.05			//this is used to fix oversubtracted background. Adds FixBackgroundOversubScale*abs(V_min) to all intensity value. 
constant NikaNumberOfQCirclesDisp=15
constant NikaLengthOfPathForPanelDisplay=100
//*************************************************************************\
	//* Copyright (c) 2005 - 2025, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.86		Beta release, Nika modification for 12IDE USAXS/SAXS/WAXS instrument.  
//1.85 	July2023 release, Fix NI1_SetAllPathsInNika which failed to setup properly very long paths. 
//			1.843 Fix IP9.02 issue with AxisTransform1.2 change. April2023Beta 
//			1.842 February2023 Beta
//1.84 	October2021 version
//			Fixes for some loaders where users found failures.  
//1.83		require Igor 8.03 now. Not testing Igor 7 anymore. 
//			Improve NXcanSAS 2D calibrated data import for NSLS-SMI beamline. 
//1.826 	Beta version after February2020 release
//1.82 	rtGlobal=3 forced for all
//			Added support for 12ID-C data. 
//			Add print in history which version has compiled, Useful info later when debugging.
//1.81   December 2018 release. Updated 64bit xops, mainly for OSX. 
//			Added 12ID-C support, first release. 
//1.80		Official Igor 8 release, Fixed NEXUS exporter to save data which are easily compatible with sasView. sasView has serious limitations on what it can accept as input NXcanSAS nexus data. 
//			Removed range selection controls and moved Save data options to its own tab "Save"
//			Added ImageStatistics and control for user for delay between series of images. 
//			Added font type and size control from configuration to be used for CCD image label. 
//			Added ability to fix negative intensities oversubtraction. Checkbox on Empty tab and if checked, ~1.5*abs(V_min) is added to ALL points intensities. 
//1.79		Converted all procedure files to UTF8 to prevent text encoding issues. 
//			Modified main interface to have radio buttons and only one button for action. This makes cleaner interface as some controls can be hidden. Unluckily, panel is now higher by 20 points. 
//			Added support for ALS SRoXS soft energy beamline. 
//			Improved 9IDC USAXS support. 
//			Added more masking options into main panel listbox right click. 
//			Checked that - with reduced functionality - code will work without Github distributed xops. 
//			Bug fix - changed ki/kout single precision waves to double precision. This caused issues under very small angles when data were unintentionally binned to less points what should have been produced. This is very old bug causing issues at very small Q vectors with short wavelengths and no beamstops.  
//			Tested and fixed for Igor 8 beta version. 
//			 
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
	"Config fonts, uncertainties, names",NI1_ConfigMain()
	help={"Configure method for uncertainity values for GUI behavior and for panels font sizes and font types"}
	"Configuration manager", NI1_GeometriesManager()
	help={"This enables switching among multiple Nika geometries, such as distances or wavelengths"}
	Submenu "Instrument configurations"
		"APS USAXS-SAXS-WAXS", NI1_APSConfigureNika()
		help={"Support for data from 9ID or9IDC (USAXS/SAXS) beamline at APS"}
		"RSoXS ALS soft energy instrument", NI1_RSoXSCreateGUI()
		help={"Support for data from ALS soft energy beamline"}
		"APS 12ID-C SAXS with Gold Detector", NI1_12IDCLoadAndSetup()
		help={"Support for data from APS 12ID-C camera"}
		"APS 12ID-B SAXS-WAXS (Nexus or tiff)", NI1_12IDBLoadAndSetup()
		help={"Support for data from APS 12ID-B camera"}		
		"DND CAT", NI1_DNDConfigureNika()
		help={"Support for data from DND CAT (5ID) beamline at APS"}
		"SSRL Mat SAXS", NI1_SSRLSetup()
		help={"Support for data from SSRL Materials Scienc e SAXS beamline"}
		"TPA", NI1_TPASetup()
		help={"Support for data TPA  XML (SANS)"}
	end
	Submenu "Helpful tools"
		"Set same paths and Image types", NI1_SetAllPathsInNIka()
		help={"Sets the paths for Sample, Empty, Mask, Calibrant to the same place."}
	end
	"HouseKeeping", NI1_Cleanup2Dto1DFolder()
	help={"Removes large waves from this experiment, makes file much smaller. Resets junk... "}
	"Remove stored images", NI1_RemoveSavedImages()
	help={"Removes stored images - does not remove USED images, makes file much smaller. "}
	"---"
	"Open Nika web page", NI1_OpenNikaWebPage()
	help={"Opens Nika web page."}
	"Open Nika web manual", IN2G_OpenWebManual("")
	help={"Opens Nika web manual in default web bropwser."}
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
	"Open Readme", NI1_OpenReadme()
	help={"Open notes about recent changes in the code. "}
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
//**************************************************************** 
//*****************************************************************************************************************
//*****************************************************************************************************************

Function NI1_SetAllPathsInNIka()
		DoWindow NI1A_Convert2Dto1DPanel
		if(!V_Flag)		//does not exists, quit
			NI1A_Convert2Dto1DMainPanel()
		else
			DoWIndow/F NI1A_Convert2Dto1DPanel
		endif
		PathInfo/S Convert2Dto1DEmptyDarkPath
		NewPath/C/O/M="Select path to your data" Convert2Dto1DDataPath
		PathInfo Convert2Dto1DDataPath
		string pathInforStrL = S_path	//[strlen(S_path)-NikaLengthOfPathForPanelDisplay,strlen(S_path)-1]
		string pathInforStrS = S_path[strlen(S_path)-NikaLengthOfPathForPanelDisplay,strlen(S_path)-1]
		NewPath/O/Q Convert2Dto1DEmptyDarkPath, pathInforStrL		
		SVAR MainPathInfoStr=root:Packages:Convert2Dto1D:MainPathInfoStr
		MainPathInfoStr = pathInforStrS
		SVAR/Z BCPathInfoStr=root:Packages:Convert2Dto1D:BCPathInfoStr
		if(!SVAR_Exists(BCPathInfoStr))
			NI1BC_InitCreateBmCntrFile()
			SVAR BCPathInfoStr=root:Packages:Convert2Dto1D:BCPathInfoStr
		endif
		NewPath/O/Q Convert2Dto1DBmCntrPath, pathInforStrL
		//PathInfo Convert2Dto1DBmCntrPath
		BCPathInfoStr=S_Path
		NewPath/O/Q Convert2Dto1DMaskPath, pathInforStrL
		//now also let users set the correct image type 
		String SelectedImageType=".tif"
		SVAR ListOfKnownExtensions = root:Packages:Convert2Dto1D:ListOfKnownExtensions
		Prompt SelectedImageType, "Image type", popup, ListOfKnownExtensions 
		DoPrompt /HELP="Select proper image type" "Select Image type for all images", SelectedImageType
		if(V_Flag==0)
			//here we need to set all types. 
			print SelectedImageType
			SVAR DataFileExtension=root:Packages:Convert2Dto1D:DataFileExtension
			DataFileExtension = SelectedImageType
			if(cmpstr(DataFileExtension,"GeneralBinary")==0)
				NI1_GBLoaderPanelFnct()
			endif
			if(cmpstr(DataFileExtension,"Pilatus")==0)
				NI1_PilatusLoaderPanelFnct()
			endif
			if(cmpstr(DataFileExtension,"ESRFedf")==0)
				NI1_ESRFEdfLoaderPanelFnct()
			endif	
			if(cmpstr(DataFileExtension,"Nexus")==0)
				NEXUS_NikaCall(1)
				NVAR NX_InputFileIsNexus=root:Packages:Irena_Nexus:NX_InputFileIsNexus
				NX_InputFileIsNexus = 1
			else
				NVAR/Z NX_InputFileIsNexus=root:Packages:Irena_Nexus:NX_InputFileIsNexus
				if(NVAR_Exists(NX_InputFileIsNexus))
					NX_InputFileIsNexus = 0
				endif
			endif	
			NEXUS_NikaCall(0)
			//update main pane
			DoWIndow NI1A_Convert2Dto1DPanel
			if(V_Flag)
				PopupMenu Select2DDataType   win=NI1A_Convert2Dto1DPanel, popmatch=SelectedImageType
			PopupMenu SelectBlank2DDataType  win=NI1A_Convert2Dto1DPanel, popmatch=SelectedImageType
			endif
			
			SVAR BlankFileExtension=root:Packages:Convert2Dto1D:BlankFileExtension
			BlankFileExtension = SelectedImageType
			SVAR BMFunctionName=root:Packages:Convert2Dto1D:BMFunctionName
			BMFunctionName = SelectedImageType
			SVAR BmCntrFileType=root:Packages:Convert2Dto1D:BmCntrFileType
			BmCntrFileType = SelectedImageType
			DoWIndow NI1_CreateBmCntrFieldPanel
			if(V_Flag)
				PopupMenu BmCntrFileType win=NI1_CreateBmCntrFieldPanel, popmatch=SelectedImageType
			endif
			
			
			SVAR CCDFileExtension = root:Packages:Convert2Dto1D:CCDFileExtension
			CCDFileExtension = SelectedImageType
			DoWIndow NI1M_ImageROIPanel
			if(V_Flag)
				PopupMenu CCDFileExtension win=NI1M_ImageROIPanel, popmatch=SelectedImageType
			endif
			
		endif
		NI1BC_UpdateBmCntrListBox()	
		NI1A_UpdateDataListBox()	
		NI1A_UpdateEmptyDarkListBox()	
end

//****************************************************************************************
//****************************************************************************************
//****************************************************************************************

static Function AfterCompiledHook( )			//check if all windows are up to date to match their code

	NVAR/Z LastCheckNika=root:Packages:LastCheckNika
	if(!NVAR_Exists(LastCheckNika))
		variable/g root:Packages:LastCheckNika 
		NVAR LastCheckNika=root:Packages:LastCheckNika
	endif	
 	string WindowProcNames="NI1A_Convert2Dto1DPanel=NI1A_MainCheckVersion;NI1_CreateBmCntrFieldPanel=NIBC_MainCheckVersion;NEXUS_ConfigurationPanel=Nexus_MainCheckVersion;"
 	
	NI1A_CheckWIndowsProcVersions(WindowProcNames)
	IN2G_ResetSizesForALlPanels(WindowProcNames)
	IN2G_AddButtonsToBrowser()		//adds button to DataBrowser. 
	if((DateTime - LastCheckNika)>60*60*12)		//run this only once per 12 hours. 
		IN2G_CheckForGraphicsSetting(0)
		NI1_CheckNikaUpdate(0)
		print "*** >>>  Nika version : "+num2str(CurrentNikaVersionNumber)+", compiled on "+date()+"  "+time()
		LastCheckNika = DateTime
	endif
	
end
 

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function NI1_RemoveNika1Mac()
		NI1_Cleanup2Dto1DFolder()
		Execute/P "NI1_KillGraphsAndPanels()"
		Execute/P "DELETEINCLUDE \"NI1_Loader\""
		SVAR strChagne=root:Packages:Nika12DSASItem1Str
		strChagne= "Load Nika 2D SAS Macros"
		BuildMenu "Macros"
		Execute/P "COMPILEPROCEDURES "
end

//*****************************************************************************************************************

Function NI1_KillGraphsAndPanels()



	String ListOfWindows
	ListOfWindows = "NI1A_Convert2Dto1DPanel;NI1_9IDCConfigPanel;CCDImageToConvertFig;EmptyOrDarkImage;NI1_CreateBmCntrFieldPanel;CCDImageForBmCntr;"
	ListOfWindows += "NI1M_ImageROIPanel;NI1_CreateFloodFieldPanel;NI1_GeometriesManagerPanel;NI1_RSoXSMainPanel;APS12IDC_Instructions;DND_Instructions;"
	
	
	variable i
	string TempNm
	For(i=0;i<ItemsInList(ListOfWindows);i+=1)
		TempNm = stringFromList(i,ListOfWindows)
		KillWIndow/Z $TempNm
	endfor
end

////*****************************************************************************************************************
Function NI1_OpenReadme()
	DoWIndow NikaReadme
	if(V_Flag)
		DoWIndow/F NikaReadme
	else
		string PathToReadMe= RemoveListItem(ItemsInList(FunctionPath("NI1_OpenReadme"),":")-1, FunctionPath("NI1_OpenReadme"), ":")
		PathToReadMe = PathToReadMe+"Modification history.txt"
		OpenNotebook /K=1 /R /N=NikaReadme /ENCG=3 /W=(20,20,720,600) /Z PathToReadMe
	endif
end
////*****************************************************************************************************************
////*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function NI1_SignUpForMailingList()
	DoAlert 1,"Your web browser will open page with the page where you can control your maling list options. OK?"
	if(V_flag==1)
		BrowseURL "https://mailman.aps.anl.gov/mailman/listinfo/nika_users"
	endif
End
//**************************************************************** 
Function NI1_OpenNikaWebPage()
		BrowseURL "https://usaxs.xray.aps.anl.gov/software/nika"
end
//**************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function NI1_AboutPanel()
	KillWIndow/Z About_Nika_1_Macros
 	PauseUpdate    		// building window...
	NewPanel/K=1 /W=(173.25,101.75,550,340) as "About_Nika_1_Macros"
	DoWindow/C About_Nika_1_Macros
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 1,textrgb= (16384,28160,65280)
	DrawText 10,37,"Nika 1 macros for Igor Pro 8.04 & 9.x"
	SetDrawEnv fsize= 16,textrgb= (16384,28160,65280)
	DrawText 52,64,"@ ANL, 2023"
	DrawText 49,103,"Release "+num2str(CurrentNikaVersionNumber)
	DrawText 11,136,"To get help please contact: ilavsky@aps.anl.gov"
	DrawText 11,156,"https://usaxs.xray.aps.anl.gov/software-description"

	DrawText 11,190,"Set of macros to convert 2D SAS images"
	DrawText 11,210,"into 1 D data"
	//DrawText 11,230,"     "
	//DrawText 11,250," "
	//DrawText 11,265,"Igor 8.04 & 9.x compatible"
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
	
end

//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************

Function NI1_ReadNikaGUIPackagePrefs()
	IN2G_ReadIrenaGUIPackagePrefs(0)
end
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
///***********************************************************
//***********************************************************
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
	WebNikaVersion = IN2G_CheckForNewVersion("Nika")
	if(numtype(WebNikaVersion)!=0)
		Print "Check for latest Nika version failed. Check your Internet connection. Try later again..."
	endif
	SetDataFOlder OldDf
end	



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
				BrowseURL "https://usaxs.xray.aps.anl.gov/software/nika"
			endif
			if(stringmatch(ba.ctrlName,"OpenNikaManuscriptWebPage"))
				//open web page with Nika
				BrowseURL "http://dx.doi.org/10.1107/S0021889812004037"
			endif
			if(stringmatch(ba.ctrlName,"OpenGCManuscriptWebPage"))
				//doi:10.1007/s11661-009-9950-x
				BrowseURL "https://link.springer.com/article/10.1007/s11661-009-9950-x"
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
	PauseUpdate    		// building window...
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
		NI1_APSConfigureNika()
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
	ListOfNikaWindows+="EmptyOrDarkImage;NI1_CreateFloodFieldPanel;NI1_MainConfigPanel;NI1_9IDCConfigPanel;Instructions_9IDC;APS12IDC_Instructions;"
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
	PauseUpdate    		// building window...
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
