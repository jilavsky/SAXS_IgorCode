#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.60

//*************************************************************************\
//* Copyright (c) 2005 - 2010, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/
  
 //1.59 Minor updates 
//1.58 Fixed GUI fonts/size controls issues on Widonws 7, modified Configure Nika preferences to include action on double click.
//1.57 New mailing list, SSRL SAXS support, fixes to 15ID SAXS etc. 
//1.56 More pinSAXS support (and not finished yet) and some changes to available color scales. 
//1.55 Fixed 15IDD Nexus support for 2/2012 Nexus files. 
//1.53 Added support for azimuthal angle output (useful when using ellipse for line profile)
//1.52 Added pinSAXS support for 15IDD USAXS instrument
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
	"Configure Nika Preferences",NI1_ConfigMain()
	help={"Configure method for uncertainity values for GUI behavior and for panels font sizes and font types"}
	Submenu "Instrument configurations"
		"15ID SAXS", NI1_15IDDConfigureNika()
		help={"Support for data from 15IDD (USAXS/SAXS) beamline at APS"}
		"DND CAT", NI1_DNDConfigureNika()
		help={"Support for data from DND CAT (5ID) beamline at APS"}
		"SSRL Mat SAXS", NI1_SSRLSetup()
		help={"Support for data from SSRL Materials Scienc e SAXS beamline"}
		"TPA", NI1_TPASetup()
		help={"Support for data TPA  XML (SANS)"}
	end
	"HouseKeeping", NI1_Cleanup2Dto1DFolder()
	help={"Removes large waves from this experiment, makes file much smaller. Resets junk... "}
	"Remove stored images", NI1_RemoveSavedImages()
	help={"Removes stored images - does not remove USED images, makes file much smaller. "}
	"---"
	"Open Nika pdf manual", NI1_OpenNikaManual()
	help={"Opens Nika pdf manual in Acrobat or other system associated pdf reader."}
	"Remove Nika 1 macros", NI1_RemoveNika1Mac()
	help={"Removes the macros from the current experiment. Macros can be loaded when necessary again"}
	"Nika Mailing list signup and options", NI1_SignUpForMailingList()
	help={"Opens web page in the browser where you can sing up or control options for nika_users mailing list."}
	"About", NI1_AboutPanel()
	help={"Get Panel with info about this release of Nika macros"}
//	"---"
//	"Test Marquee", NI1B_Fitto2DGaussian1()
end


Menu "GraphMarquee"
        "Image Expand", NI1_MarExpandContractImage(1)
        "Image Contract", NI1_MarExpandContractImage(0)
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function NI1_OpenNikaManual()
	//this function writes batch file and starts the manual.
	//we need to write following batch file: "C:\Program Files\WaveMetrics\Igor Pro Folder\User Procedures\Irena\Irena manual.pdf"
	//on Mac we just fire up the Finder with Mac type path... 
	
	//check where we run...
		string WhereIsManual
		string WhereAreProcedures=RemoveEnding(FunctionPath(""),"NI1_Main.ipf")
		String manualPath = ParseFilePath(5,"Nika manual.pdf","*",0,0)
       	String cmd 
	
	if (stringmatch(IgorInfo(2), "*Macintosh*"))
             //  manualPath = "User Procedures:Irena:Irena manual.pdf"
               sprintf cmd "tell application \"Finder\" to open \"%s\"",WhereAreProcedures+manualPath
               ExecuteScriptText cmd
      		if (strlen(S_value)>2)
//			DoAlert 0, S_value
		endif

	else 
		//manualPath = "User Procedures\Irena\Irena manual.pdf"
		//WhereIsIgor=WhereIsIgor[0,1]+"\\"+IN2G_ChangePartsOfString(WhereIsIgor[2,inf],":","\\")
		WhereAreProcedures=ParseFilePath(5,WhereAreProcedures,"*",0,0)
		whereIsManual = "\"" + WhereAreProcedures+manualPath+"\""
		NewNotebook/F=0 /N=NewBatchFile
		Notebook NewBatchFile, text=whereIsManual//+"\r"
		SaveNotebook/O NewBatchFile as SpecialDirPath("Temporary", 0, 1, 0 )+"StartManual.bat"
		DoWindow/K NewBatchFile
		ExecuteScriptText "\""+SpecialDirPath("Temporary", 0, 1, 0 )+"StartManual.bat\""
	endif
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

Function NI1_RemoveNika1Mac()
		Execute/P "DELETEINCLUDE \"NI1_Loader\""
		SVAR strChagne=root:Packages:Nika12DSASItem1Str
		strChagne= "Load Nika 1 2D SAS Macros"
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
	DoWindow About_Nika_1_Macros
	if(V_Flag)
		DoWindow/K About_Nika_1_Macros
	endif

	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(173.25,101.75,490,370) as "About_Nika_1_Macros"
	DoWindow/C About_Nika_1_Macros
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 1,textrgb= (16384,28160,65280)
	DrawText 10,37,"Nika 1 macros Igor Pro (>=6.22a)"
	SetDrawEnv fsize= 16,textrgb= (16384,28160,65280)
	DrawText 52,64,"@ ANL, 2013"
	DrawText 49,103,"Release 1.60 from 1/4/2013"
	DrawText 11,136,"To get help please contact: ilavsky@aps.anl.gov"
	DrawText 11,156,"http://usaxs.xor.aps.anl.gov/staff/ilavsky/index.html"

	DrawText 11,190,"Set of macros to convert 2D SAS images"
	DrawText 11,210,"into 1 D data"
	DrawText 11,230,"     "
	DrawText 11,250," "
	DrawText 11,265,"Igor 6.22 compatible"
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
//***********************************************************
//***********************************************************

//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************

Function NI1_ConfigMain()		//call configuration routine

	//this is main configuration utility... 
	NI1_InitConfigMain()
	DoWindow NI1_MainConfigPanel
	if(!V_Flag)
		Execute ("NI1_MainConfigPanel()")
	else
		DoWindow/F NI1_MainConfigPanel
	endif

end

//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
structure NikaPanelDefaults
	uint32 version					// Preferences structure version number. 100 means 1.00.
//	uchar LegendFontType[50]		//50 characters for legend font name
	uchar PanelFontType[50]		//50 characters for panel font name
	uint32 defaultFontSize			//font size as integer
	uint32 Uncertainity				//Uncertainity choice - 0 is Old, 1 is Std dev, and 2 is SEM
//	uint32 TagSize					//font size as integer
//	uint32 AxisLabelSize			//font size as integer
//	int16 LegendUseFolderName		//font size as integer
//	int16 LegendUseWaveName		//font size as integer
	uint32 reserved[99]			// Reserved for future use
	
endstructure

//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************

Function NI1_ReadIrenaGUIPackagePrefs()

	struct  NikaPanelDefaults Defs
	NI1_InitConfigMain()
	SVAR DefaultFontType=root:Packages:NikaConfigFolder:DefaultFontType
	NVAR DefaultFontSize=root:Packages:NikaConfigFolder:DefaultFontSize
	NVAR SelectedUncertainity=root:Packages:NikaConfigFolder:SelectedUncertainity
//	NVAR LegendSize=root:Packages:IrenaConfigFolder:LegendSize
//	NVAR TagSize=root:Packages:IrenaConfigFolder:TagSize
//	NVAR AxisLabelSize=root:Packages:IrenaConfigFolder:AxisLabelSize
//	NVAR LegendUseFolderName=root:Packages:IrenaConfigFolder:LegendUseFolderName
//	NVAR LegendUseWaveName=root:Packages:IrenaConfigFolder:LegendUseWaveName
//	SVAR FontType=root:Packages:IrenaConfigFolder:FontType
	LoadPackagePreferences /MIS=1   "Nika" , "NikaDefaultPanelControls.bin", 0 , Defs
	if(V_Flag==0)		
		//print Defs
		print "Read Nika Panels preferences from local machine and applied them. "
		print "Note that this may have changed font size and type selection originally saved with the existing experiment."
		print "To change them please use \"Configure default fonts and names\""
		if(Defs.Version==1)		//Lets declare the one we know as 1
			DefaultFontType		=	Defs.PanelFontType
			DefaultFontSize 		= 	Defs.defaultFontSize
			if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
				DefaultGUIFont /Win   all= {DefaultFontType, DefaultFontSize, 0 }
			else
				DefaultGUIFont /Mac   all= {DefaultFontType, DefaultFontSize, 0 }
			endif
			//and now recover the stored other parameters, no action on these...
		elseif(Defs.Version==2)		//Lets declare the one we know as 1
			DefaultFontType		=	Defs.PanelFontType
			DefaultFontSize 		= 	Defs.defaultFontSize
			SelectedUncertainity= 	Defs.Uncertainity
			if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
				DefaultGUIFont /Win   all= {DefaultFontType, DefaultFontSize, 0 }
			else
				DefaultGUIFont /Mac   all= {DefaultFontType, DefaultFontSize, 0 }
			endif
			//and now recover the stored other parameters, no action on these...

			NVAR/z ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
			NVAR/z ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
			NVAR/z ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
			if(!NVAR_Exists(ErrorCalculationsUseOld))
				string OldDf=GetDataFolder(1)
				setDataFolder root:
				NewDataFolder/S/O Packages
				NewDataFolder/S/O Convert2Dto1D
				variable/g ErrorCalculationsUseOld, ErrorCalculationsUseStdDev, ErrorCalculationsUseSEM
				NVAR ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
				NVAR ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
				NVAR ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
			endif
			if(SelectedUncertainity==0)
				ErrorCalculationsUseOld=1
				ErrorCalculationsUseStdDev=0
				ErrorCalculationsUseSEM=0
			elseif(SelectedUncertainity==1)
				ErrorCalculationsUseOld=0
				ErrorCalculationsUseStdDev=1
				ErrorCalculationsUseSEM=0
			elseif(SelectedUncertainity==2)
				ErrorCalculationsUseOld=0
				ErrorCalculationsUseStdDev=0
				ErrorCalculationsUseSEM=1
			endif

		else
			DoAlert 1, "Old version of GUI and Graph Fonts (font size and type preference) found. Do you want to update them now? These are set once on a computer and can be changed in \"Configure default fonts and names\"" 
			if(V_Flag==1)
				Execute("NI1_MainConfigPanel() ")
			else
			//	SavePackagePreferences /Kill   "Irena" , "IrenaDefaultPanelControls.bin", 0 , Defs	//does not work below 6.10
			endif
		endif
	else 		//problem loading package defaults
		DoAlert 1, "GUI and Graph defaults (font size and type preferences) are not set. Do you want to set them now? These are set once on a computer and can be changed in \"Configure default fonts and names\" dialog" 
		if(V_Flag==1)
			Execute("NI1_MainConfigPanel() ")
		endif	
	endif
end
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function NI1_SaveIrenaGUIPackagePrefs(KillThem)
	variable KillThem
	
	struct  NikaPanelDefaults Defs
	NI1_InitConfigMain()
	SVAR DefaultFontType=root:Packages:NikaConfigFolder:DefaultFontType
	NVAR DefaultFontSize=root:Packages:NikaConfigFolder:DefaultFontSize
	NVAR SelectedUncertainity=root:Packages:NikaConfigFolder:SelectedUncertainity
//	NVAR LegendSize=root:Packages:IrenaConfigFolder:LegendSize
//	NVAR TagSize=root:Packages:IrenaConfigFolder:TagSize
//	NVAR AxisLabelSize=root:Packages:IrenaConfigFolder:AxisLabelSize
//	NVAR LegendUseFolderName=root:Packages:IrenaConfigFolder:LegendUseFolderName
//	NVAR LegendUseWaveName=root:Packages:IrenaConfigFolder:LegendUseWaveName
//	SVAR FontType=root:Packages:IrenaConfigFolder:FontType

	Defs.Version			=		2
	Defs.PanelFontType	 	= 		DefaultFontType
	Defs.defaultFontSize 	= 		DefaultFontSize 
	Defs.Uncertainity		= 		SelectedUncertainity
//	Defs.TagSize 			= 		TagSize
//	Defs.AxisLabelSize 		= 		AxisLabelSize
//	Defs.LegendUseFolderName = 	LegendUseFolderName
//	Defs.LegendUseWaveName = 		LegendUseWaveName
//	Defs.LegendFontType	= 		FontType


	
	if(KillThem)
	//	SavePackagePreferences /Kill   "Irena" , "IrenaDefaultPanelControls.bin", 0 , Defs		//does nto work below 6.10
	//	IR2C_ReadIrenaGUIPackagePrefs()
	else
		SavePackagePreferences /FLSH=1   "Nika" , "NikaDefaultPanelControls.bin", 0 , Defs
	endif
end
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************

Function NI1_InitConfigMain()

	//initialize lookup parameters for user selected items.
	string OldDf=getDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:NikaConfigFolder
	
	string ListOfVariables
	string ListOfStrings
	//here define the lists of variables and strings needed, separate names by ;...
	ListOfVariables="DefaultFontSize;SelectedUncertainity;"
	ListOfStrings="ListOfKnownFontTypes;DefaultFontType;"
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	//Now set default values
//	String VariablesDefaultValues
//	String StringsDefaultValues
//	if (stringMatch(IgorInfo(3),"*Windows*"))		//Windows
//		VariablesDefaultValues="LegendSize:8;TagSize:8;AxisLabelSize:8;LegendUseFolderName:0;LegendUseWaveName:0;"
//	else
//		VariablesDefaultValues="LegendSize:10;TagSize:10;AxisLabelSize:10;LegendUseFolderName:0;LegendUseWaveName:0;"
//	endif
//	StringsDefaultValues="FontType:"+StringFromList(0, IR2C_CreateUsefulFontList() ) +";"
//
//	variable CurVarVal
//	string CurVar, CurStr, CurStrVal
//	For(i=0;i<ItemsInList(VariablesDefaultValues);i+=1)
//		CurVar = StringFromList(0,StringFromList(i, VariablesDefaultValues),":")
//		CurVarVal = numberByKey(CurVar, VariablesDefaultValues)
//		NVAR temp=$(CurVar)
//		if(temp==0)
//			temp = CurVarVal
//		endif
//	endfor
//	For(i=0;i<ItemsInList(StringsDefaultValues);i+=1)
//		CurStr = StringFromList(0,StringFromList(i, StringsDefaultValues),":")
//		CurStrVal = stringByKey(CurStr, StringsDefaultValues)
//		SVAR tempS=$(CurStr)
//		if(strlen(tempS)<1)
//			tempS = CurStrVal
//		endif
//	endfor
	
	SVAR ListOfKnownFontTypes=ListOfKnownFontTypes
	ListOfKnownFontTypes=NI1_CreateUsefulFontList()
	setDataFolder OldDf
end

//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function NI1_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
//	if (cmpstr(ctrlName,"LegendSize")==0)
//		NVAR LegendSize=root:Packages:IrenaConfigFolder:LegendSize
//		LegendSize = str2num(popStr)
//	endif
//	if (cmpstr(ctrlName,"TagSize")==0)
//		NVAR TagSize=root:Packages:IrenaConfigFolder:TagSize
//		TagSize = str2num(popStr)
//	endif
//	if (cmpstr(ctrlName,"AxisLabelSize")==0)
//		NVAR AxisLabelSize=root:Packages:IrenaConfigFolder:AxisLabelSize
//		AxisLabelSize = str2num(popStr)
//	endif
//	if (cmpstr(ctrlName,"FontType")==0)
//		SVAR FontType=root:Packages:IrenaConfigFolder:FontType
//		FontType = popStr
//	endif
	if (cmpstr(ctrlName,"DefaultFontType")==0)
		SVAR DefaultFontType=root:Packages:NikaConfigFolder:DefaultFontType
		DefaultFontType = popStr
		NI1_ChangePanelCOntrolsStyle()
	endif
	if (cmpstr(ctrlName,"DefaultFontSize")==0)
		NVAR DefaultFontSize=root:Packages:NikaConfigFolder:DefaultFontSize
		DefaultFontSize = str2num(popStr)
		NI1_ChangePanelCOntrolsStyle()
	endif
	NI1_SaveIrenaGUIPackagePrefs(0)
End
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function NI1_KillPrefsButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"OKBUtton"))
				NI1_SaveIrenaGUIPackagePrefs(0)
				DoWIndow/K NI1_MainConfigPanel
			elseif(stringmatch(ba.ctrlName,"DefaultValues"))
				string defFnt
				variable defFntSize
				if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
					defFnt="Tahoma"
					defFntSize=12
				else
					defFnt="Geneva"
					defFntSize=9
				endif
				SVAR ListOfKnownFontTypes=root:Packages:NikaConfigFolder:ListOfKnownFontTypes
				SVAR DefaultFontType=root:Packages:NikaConfigFolder:DefaultFontType
				DefaultFontType = defFnt
				NVAR DefaultFontSize=root:Packages:NikaConfigFolder:DefaultFontSize
				DefaultFontSize = defFntSize
				NI1_ChangePanelCOntrolsStyle()
				NI1_SaveIrenaGUIPackagePrefs(0)
				PopupMenu DefaultFontType,win=NI1_MainConfigPanel, mode=(1+WhichListItem(defFnt, ListOfKnownFontTypes))
				PopupMenu DefaultFontSize,win=NI1_MainConfigPanel, mode=(1+WhichListItem(num2str(defFntSize), "8;9;10;11;12;14;16;18;20;24;26;30;"))
			endif
			break
	endswitch
	return 0
End

//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************

Function NI1_ChangePanelControlsStyle()

	SVAR DefaultFontType=root:Packages:NikaConfigFolder:DefaultFontType
	NVAR DefaultFontSize=root:Packages:NikaConfigFolder:DefaultFontSize

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

Proc NI1_MainConfigPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(282,48,707,270) as "Configure Nika Preferecnes"
	DoWindow /C NI1_MainConfigPanel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 3,textrgb= (0,0,52224)
	DrawText 10,25,"Nika panels default fonts and names"
	SetDrawEnv fsize= 14,fstyle= 3, textrgb= (0,0,52224)
	DrawText 10,130,"Error type selection and GUI behavior"
//	SetDrawEnv fsize= 14,fstyle= 3,textrgb= (63500,4369,4369)
//	DrawText 30,150,"Graph text elements"
//	SVAR ListOfKnownFontTypes=root:Packages:IrenaConfigFolder:ListOfKnownFontTypes

	NI1A_Initialize2Dto1DConversion()

	PopupMenu DefaultFontType,pos={15,40},size={113,21},proc=NI1_PopMenuProc,title="Panel Controls Font"
	PopupMenu DefaultFontType,mode=(1+WhichListItem(root:Packages:NikaConfigFolder:DefaultFontType, root:Packages:NikaConfigFolder:ListOfKnownFontTypes))
	PopupMenu DefaultFontType, popvalue=root:Packages:NikaConfigFolder:DefaultFontType,value= #"NI1_CreateUsefulFontList()"
	PopupMenu DefaultFontSize,pos={15,70},size={113,21},proc=NI1_PopMenuProc,title="Panel Controls Font Size"
	PopupMenu DefaultFontSize,mode=(1+WhichListItem(num2str(root:Packages:NikaConfigFolder:DefaultFontSize), "8;9;10;11;12;14;16;18;20;24;26;30;"))
	PopupMenu DefaultFontSize popvalue=num2str(root:Packages:NikaConfigFolder:DefaultFontSize),value= #"\"8;9;10;11;12;14;16;18;20;24;26;30;\""
	Button DefaultValues title="Default",pos={290,40},size={120,20}
	Button DefaultValues proc=NI1_KillPrefsButtonProc

	CheckBox DoubleClickConverts,pos={230,140},size={80,16},noproc,title="Double click converts ?", mode=0
	CheckBox DoubleClickConverts,variable= root:Packages:Convert2Dto1D:DoubleClickConverts, help={"Check to convert files on double click in Files selection"}
	

	CheckBox ErrorCalculationsUseOld,pos={10,140},size={80,16},proc=NI1_ConfigErrorsCheckProc,title="Use Old Uncertainity ?", mode=1
	CheckBox ErrorCalculationsUseOld,variable= root:Packages:Convert2Dto1D:ErrorCalculationsUseOld, help={"Check to use Error estimates for before version 1.42?"}
	CheckBox ErrorCalculationsUseStdDev,pos={10,160},size={80,16},proc=NI1_ConfigErrorsCheckProc,title="Use Std Devfor Uncertainity?", mode=1
	CheckBox ErrorCalculationsUseStdDev,variable= root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev, help={"Check to use Standard deviation for Error estimates "}
	CheckBox ErrorCalculationsUseSEM,pos={10,180},size={80,16},proc=NI1_ConfigErrorsCheckProc,title="Use SEM for Uncertainity?", mode=1
	CheckBox ErrorCalculationsUseSEM,variable= root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM, help={"Check to use Standard error of mean for Error estimates"}

	Button OKButton title="OK",pos={290,190},size={120,20}
	Button OKButton proc=NI1_KillPrefsButtonProc


EndMacro
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function NI1_ConfigErrorsCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	NVAR ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
	NVAR ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
	NVAR ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
	NVAR SelectedUncertainity=root:Packages:NikaConfigFolder:SelectedUncertainity

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(stringmatch(cba.ctrlName,"ErrorCalculationsUseOld"))
				ErrorCalculationsUseOld = checked
				ErrorCalculationsUseStdDev=!checked
				ErrorCalculationsUseSEM=!checked
				SelectedUncertainity=0
			endif
			if(stringmatch(cba.ctrlName,"ErrorCalculationsUseStdDev"))
				ErrorCalculationsUseOld = !checked
				ErrorCalculationsUseStdDev=checked
				ErrorCalculationsUseSEM=!checked
				SelectedUncertainity=1
			endif
			if(stringmatch(cba.ctrlName,"ErrorCalculationsUseSEM"))
				ErrorCalculationsUseOld = !checked
				ErrorCalculationsUseStdDev=!checked
				ErrorCalculationsUseSEM=checked
				SelectedUncertainity=2
			endif
			break
	endswitch

	return 0
End
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************

Function/S NI1_CreateUsefulFontList()

	string SystemFontList=FontList(";")
	string PreferredFontList="Times;Arial;Geneva;Palatino;Times New Roman;TImes Roman;Book Antiqua;"
	PreferredFontList+="Courier;Lucida;Vardana;Monaco;Courier CE;Courier;"
	
	variable i
	string UsefulList="", tempList=""
	For(i=0;i<ItemsInList(PreferredFontList);i+=1)
		tempList=stringFromList(i,PreferredFontList)
		if(stringmatch(SystemFOntList, "*"+tempList+";*" ))
			UsefulList+=tempList+";"
		endif
	endfor
	return UsefulList
end

//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
