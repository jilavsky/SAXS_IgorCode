#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.88
//DO NOT renumber Main files every time, these are main release numbers...

//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/
//1.88 panel scaling. need to be fixed. 
//1.87 removed Wavename string from selection tool. Unnecessary and confusing users. 
//1.87 remove dropout option
//1.86 added save to Load & Process button, renamed 
//1.85 Flyscan improvements for 9ID March 2015
//1.84 updated Flyscan for August 2014 and added overwrite for UPD range 5 dark current
//1.83 updated Flyscan support for April 2014 version, minor improvements
//1.82 FlyScan support, preliminary version
//1.81 adds panel check for version and FlyScan data reduction, added check version control on Main panel and Fly Import panel. 
//1.80 Added few more items on Tab0 
//1.79 4/2013 JIL, added pin diode transmission
//1.78, 2/2013, JIL: Added option to calibrate by weight. Needed for USAXS users.

Constant IN3_ReduceDataMainVersionNumber=1.87

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//****************************************************************************************


Function IN3_Main()

	string OldDf=GetDataFolder(1)

	IN3_Initialize()
	
	DoWindow USAXSDataReduction
	if(V_Flag)
		DoWindow/F USAXSDataReduction
	else
		IN3_MainPanel()
	   ING2_AddScrollControl()
		IN3_UpdatePanelVersionNumber("USAXSDataReduction", IN3_ReduceDataMainVersionNumber)
	endif

	setDataFolder OldDf
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IN3_USAXSDataRedCheckVersion()	
	DoWindow USAXSDataReduction
	if(V_Flag)
		if(!IN3_CheckPanelVersionNumber("USAXSDataReduction", IN3_ReduceDataMainVersionNumber))
			DoAlert /T="The USAXS Data Reduction  panel was created by old version of Indra " 1, "USAXS Data Reduction needs to be restarted to work properly. Restart now?"
			if(V_flag==1)
				DoWindow/K USAXSDataReduction
				Execute/P("IN3_Main()")
			else		//at least reinitialize the variables so we avoid major crashes...
				IN3_Initialize()
			endif
		endif
	endif
end
//************************************************************************************************************
//************************************************************************************************************
///////////////////////////////////////////
//****************************************************************************************
//		Default variables and strings
//
//	these are known at this time:
//		Variables=LegendSize;TagSize;AxisLabelSize;
//		Strings=FontType;
//
//	how to use:
// 	When needed insert font size through lookup function - e.g., IR2C_LkUpDfltVar("LegendSize")
//	or for font type IR2C_LkUpDfltStr("FontType")
//	NOTE: Both return string values, because that is what is generally needed!!!!
// further variables and strings can be added, but need to be added to control panel too...
//	see example in : IR1_LogLogPlotU()  in this procedure file... 
//***********************************************************
//***********************************************************
Function IN3_ConfigureGUIfonts()
#if(Exists("IR2C_ConfigMain")==6)
	IR2C_ConfigMain()
#else
	DoAlert /T="How to configreu GUI fonts" 1, "This needs to load Irena package where thee function  is, do you have it install and want to continue?"
	if(V_Flag==2)		//cancel
		abort
	endif 
	Execute/P("LoadIrenaSASMacros()")
	Execute/P("IR2C_ConfigMain()")
#endif
end

Function/S IN3_LkUpDfltStr(StrName)
	string StrName

	string result
	string OldDf=getDataFolder(1)
	SetDataFolder root:
	if(!DataFolderExists("root:Packages:IrenaConfigFolder"))
		IN3_InitConfigMain()
	endif
	SetDataFolder root:Packages
	setDataFolder root:Packages:IrenaConfigFolder
	SVAR /Z curString = $(StrName)
	if(!SVAR_exists(curString))
		IN3_InitConfigMain()
		SVAR curString = $(StrName)
	endif	
	result = 	"'"+curString+"'"
	setDataFolder OldDf
	return result
end
//***********************************************************
//***********************************************************

Function/S IN3_LkUpDfltVar(VarName)
	string VarName

	string result
	string OldDf=getDataFolder(1)
	SetDataFolder root:
	if(!DataFolderExists("root:Packages:IrenaConfigFolder"))
		IN3_InitConfigMain()
	endif
	SetDataFolder root:Packages
	setDataFolder root:Packages:IrenaConfigFolder
	NVAR /Z curVariable = $(VarName)
	if(!NVAR_exists(curVariable))
		IN3_InitConfigMain()
		NVAR curVariable = $(VarName)
	endif	
	if(curVariable>=10)
		result = num2str(curVariable)
	else
		result = "0"+num2str(curVariable)
	endif
	setDataFolder OldDf
	return result
end
//***********************************************************
//***********************************************************

Function IN3_InitConfigMain()

	//initialize lookup parameters for user selected items.
	string OldDf=getDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:IrenaConfigFolder
	
	string ListOfVariables
	string ListOfStrings
	//here define the lists of variables and strings needed, separate names by ;...
	ListOfVariables="LegendSize;TagSize;AxisLabelSize;LegendUseFolderName;LegendUseWaveName;DefaultFontSize;LastUpdateCheck;"
	ListOfStrings="FontType;ListOfKnownFontTypes;DefaultFontType;"
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	//Now set default values
	String VariablesDefaultValues
	String StringsDefaultValues
	if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
		VariablesDefaultValues="LegendSize:8;TagSize:8;AxisLabelSize:8;LegendUseFolderName:0;LegendUseWaveName:0;"
	else
		VariablesDefaultValues="LegendSize:10;TagSize:10;AxisLabelSize:10;LegendUseFolderName:0;LegendUseWaveName:0;"
	endif
	StringsDefaultValues="FontType:"+StringFromList(0, IN3_CreateUsefulFontList() ) +";"

	variable CurVarVal
	string CurVar, CurStr, CurStrVal
	For(i=0;i<ItemsInList(VariablesDefaultValues);i+=1)
		CurVar = StringFromList(0,StringFromList(i, VariablesDefaultValues),":")
		CurVarVal = numberByKey(CurVar, VariablesDefaultValues)
		NVAR temp=$(CurVar)
		if(temp==0)
			temp = CurVarVal
		endif
	endfor
	For(i=0;i<ItemsInList(StringsDefaultValues);i+=1)
		CurStr = StringFromList(0,StringFromList(i, StringsDefaultValues),":")
		CurStrVal = stringByKey(CurStr, StringsDefaultValues)
		SVAR tempS=$(CurStr)
		if(strlen(tempS)<1)
			tempS = CurStrVal
		endif
	endfor
	
	SVAR ListOfKnownFontTypes=ListOfKnownFontTypes
	ListOfKnownFontTypes=IN3_CreateUsefulFontList()
	setDataFolder OldDf
end
//***********************************************************
//***********************************************************

Function IN3_ReadIrenaGUIPackagePrefs()

	struct  IrenaPanelDefaults Defs
	IN3_InitConfigMain()
	SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
	NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize
	NVAR LegendSize=root:Packages:IrenaConfigFolder:LegendSize
	NVAR TagSize=root:Packages:IrenaConfigFolder:TagSize
	NVAR AxisLabelSize=root:Packages:IrenaConfigFolder:AxisLabelSize
	NVAR LegendUseFolderName=root:Packages:IrenaConfigFolder:LegendUseFolderName
	NVAR LegendUseWaveName=root:Packages:IrenaConfigFolder:LegendUseWaveName
	NVAR LastUpdateCheck=root:Packages:IrenaConfigFolder:LastUpdateCheck
	SVAR FontType=root:Packages:IrenaConfigFolder:FontType
	LoadPackagePreferences /MIS=1   "Irena" , "IrenaDefaultPanelControls.bin", 0 , Defs
	if(V_Flag==0)		
		//print Defs
		//print "Read Irena Panels and graphs preferences from local machine and applied them. "
		//print "Note that this may have changed font size and type selection originally saved with the existing experiment."
		//print "To change them please use \"Configure default fonts and names\""
		if(Defs.Version==1 || Defs.Version==2)		//Lets declare the one we know as 1
			DefaultFontType=Defs.PanelFontType
			DefaultFontSize = Defs.defaultFontSize
			LastUpdateCheck = Defs.LastUpdateCheck
			if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
				DefaultGUIFont /Win   all= {DefaultFontType, DefaultFontSize, 0 }
			else
				DefaultGUIFont /Mac   all= {DefaultFontType, DefaultFontSize, 0 }
			endif
			//and now recover the stored other parameters, no action on these...
			 LegendSize=Defs.LegendSize
			 TagSize=Defs.TagSize
			 AxisLabelSize=Defs.AxisLabelSize
			 LegendUseFolderName=Defs.LegendUseFolderName
			 LegendUseWaveName=Defs.LegendUseWaveName
			 FontType=Defs.LegendFontType
		else
			DoAlert 1, "Old version of GUI and Graph Fonts (font size and type preference) found. Do you want to update them now? These are set once on a computer and can be changed in \"Configure default fonts and names\"" 
			if(V_Flag==1)
				Execute("IN3_MainConfigPanel() ")
			else
			//	SavePackagePreferences /Kill   "Irena" , "IrenaDefaultPanelControls.bin", 0 , Defs	//does not work below 6.10
			endif
		endif
	else 		//problem loading package defaults
		Struct WMButtonAction ba
		ba.ctrlName="DefaultValues"
		IN3_KillPrefsButtonProc(ba)
		DoAlert 1, "GUI and Graph defaults (font size and type preferences) not found. They wewre set to defaults. Do you want to set check now? These are set once on a computer and can be changed in \"Configure default fonts and names\" dialog" 
		if(V_Flag==1)
			Execute("IN3_MainConfigPanel() ")
		endif	
	endif
end
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function IN3_KillPrefsButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"OKBUtton"))
				DoWIndow/K IR2C_MainConfigPanel
			elseif(stringmatch(ba.ctrlName,"DefaultValues"))
				string defFnt
				variable defFntSize
				if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
					defFnt=stringFromList(0,IN3_CreateUsefulFontList())
					defFntSize=12
				else
					defFnt="Geneva"
					defFntSize=9
				endif
				SVAR ListOfKnownFontTypes=root:Packages:IrenaConfigFolder:ListOfKnownFontTypes
				SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
				DefaultFontType = defFnt
				NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize
				DefaultFontSize = defFntSize
				IN3_ChangePanelControlsStyle()
				IN3_SaveIrenaGUIPackagePrefs(0)
				PopupMenu DefaultFontType,win=IR2C_MainConfigPanel, mode=(1+WhichListItem(defFnt, ListOfKnownFontTypes))
				PopupMenu DefaultFontSize,win=IR2C_MainConfigPanel, mode=(1+WhichListItem(num2str(defFntSize), "8;9;10;11;12;14;16;18;20;24;26;30;"))
			endif
			break
	endswitch
	return 0
End
//***********************************************************
//***********************************************************
//***********************************************************
Function IN3_SaveIrenaGUIPackagePrefs(KillThem)
	variable KillThem
	
	struct  IrenaPanelDefaults Defs
	IN3_InitConfigMain()
	SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
	NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize
	NVAR LegendSize=root:Packages:IrenaConfigFolder:LegendSize
	NVAR TagSize=root:Packages:IrenaConfigFolder:TagSize
	NVAR AxisLabelSize=root:Packages:IrenaConfigFolder:AxisLabelSize
	NVAR LegendUseFolderName=root:Packages:IrenaConfigFolder:LegendUseFolderName
	NVAR LegendUseWaveName=root:Packages:IrenaConfigFolder:LegendUseWaveName
	NVAR LastUpdateCheck=root:Packages:IrenaConfigFolder:LastUpdateCheck
	SVAR FontType=root:Packages:IrenaConfigFolder:FontType

	Defs.Version			=		2
	Defs.PanelFontType	 	= 		DefaultFontType
	Defs.defaultFontSize 	= 		DefaultFontSize 
	Defs.LegendSize 		= 		LegendSize
	Defs.TagSize 			= 		TagSize
	Defs.AxisLabelSize 		= 		AxisLabelSize
	Defs.LegendUseFolderName = 	LegendUseFolderName
	Defs.LegendUseWaveName = 	LegendUseWaveName
	Defs.LegendFontType	= 		FontType
	Defs.LastUpdateCheck	=		LastUpdateCheck
	
	if(KillThem)
		SavePackagePreferences /Kill   "Irena" , "IrenaDefaultPanelControls.bin", 0 , Defs		//does not work below 6.10
	//	IR2C_ReadIrenaGUIPackagePrefs()
	else
		SavePackagePreferences /FLSH=1   "Irena" , "IrenaDefaultPanelControls.bin", 0 , Defs
	endif
end
//***********************************************************
//***********************************************************

Function IN3_ChangePanelControlsStyle()

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
//***********************************************************
//***********************************************************

Function/S IN3_CreateUsefulFontList()

	string SystemFontList=FontList(";")
	string PreferredFontList="Tahoma;Times;Arial$;Geneva;Palatino;Book Antiqua;"
	PreferredFontList+="Courier;Vardana;Monaco;Courier CE;System;Verdana;"
	
	variable i
	string UsefulList="", tempList=""
	For(i=0;i<ItemsInList(PreferredFontList);i+=1)
		tempList=GrepList(SystemFontList, stringFromList(i,PreferredFontList)) 
		if(strlen(tempList)>0)
			UsefulList+=tempList+";"
		endif
	endfor
	return UsefulList
end


//***********************************************************
//***********************************************************
//***********************************************************
//************************************************************************************************************
//************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IN3_Initialize()


	string OldDf=GetDataFolder(1)
	setdatafolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S Indra3


	string ListOfVariables
	string ListOfStrings
	variable i, j
	
	
	//Main parameters
	ListOfVariables="IsBlank;CalculateThickness;Wavelength;RecalculateAutomatically;SampleFilledFraction;Kfactor;"
	ListOfVariables+="SampleThickness;SampleTransmission;SampleLinAbsorption;SampleTransmissionPeakToPeak;"
	ListOfVariables+="SampleThicknessBckp;BlankWidthBckp;BlankFWHMBckp;BlankMaximumBckp;"
	ListOfVariables+="UPD_G1;UPD_G2;UPD_G3;UPD_G4;UPD_G5;UPD_Vfc;"
	ListOfVariables+="UPD_DK1;UPD_DK2;UPD_DK3;UPD_DK4;UPD_DK5;"
	ListOfVariables+="UPD_DK1Err;UPD_DK2Err;UPD_DK3Err;UPD_DK4Err;UPD_DK5Err;"
	ListOfVariables+="PhotoDiodeSize;SlitLength;NumberOfSteps;SDDistance;"
	ListOfVariables+="PeakCenterFitStartPoint;PeakCenterFitEndPoint;"
	ListOfVariables+="BeamCenter;MaximumIntensity;PeakWidth;PeakWidthArcSec;"
	ListOfVariables+="SampleQOffset;DisplayPeakCenter;DisplayAlignSaAndBlank;SampleAngleOffset;"
	ListOfVariables+="RemoveDropouts;RemoveDropoutsTime;RemoveDropoutsFraction;RemoveDropoutsAvePnts;"

	ListOfVariables+="CalibrateToWeight;CalibrateToVolume;CalibrateArbitrary;SampleWeightInBeam;CalculateWeight;BeamExposureArea;SampleDensity;"

	ListOfVariables+="BlankWidth;MSAXSCorrection;UseMSAXSCorrection;UsePinTransmission;USAXSPinTvalue;"
	ListOfVariables+="MSAXSStartPoint;MSAXSEndPoint;BlankFWHM;BlankMaximum;"

	ListOfVariables+="SubtractFlatBackground;UserSavedData;"
	ListOfVariables+="TrimDataStart;TrimDataEnd;OverwriteUPD_DK5;"

	ListOfVariables+="UseModifiedGauss;UseGauss;UseLorenz;"


	ListOfVariables+="FlyScanRebinToPoints;"

	// these are created automatically... "DataFoldername;IntensityWavename;QWavename;ErrorWaveName;"
	ListOfStrings="SampleName;BlankName;userFriendlySamplename;userFriendlyBlankName;"
	ListOfStrings+="ListOfASBParameters;LastSample;"
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	NVAR UsePinTransmission
	UsePinTransmission = 1

	NVAR/Z PhotoDiodeSize
	if (PhotoDiodeSize<=0)								//avoid next lines if already exists....
		PhotoDiodeSize=5.5
	endif
	NVAR SampleFilledFraction
	if(SampleFilledFraction<=0)
		SampleFilledFraction=1
	endif
	NVAR DisplayPeakCenter
	NVAR FlyScanRebinToPoints
	if(FlyScanRebinToPoints<100)
		FlyScanRebinToPoints=300
	endif
	NVAR DisplayAlignSaAndBlank
	if(DisplayPeakCenter+DisplayAlignSaAndBlank!=1)
		DisplayPeakCenter=1
		DisplayAlignSaAndBlank=0
	endif
	NVAR UseModifiedGauss
	NVAR UseGauss
	NVAR UseLorenz
	if(UseModifiedGauss+UseGauss+UseLorenz!=1)
		UseModifiedGauss=1
		UseGauss=0
		UseLorenz=0
	endif
	NVAR CalibrateToWeight
	NVAR CalibrateToVolume
	NVAR CalibrateArbitrary
	//add check so Volume is default and only 1 is selected. 
	if(CalibrateArbitrary+CalibrateToVolume+CalibrateToWeight!=1)
		 CalibrateToWeight=0
		 CalibrateToVolume=1
		 CalibrateArbitrary=0
	endif
	NVAR RemoveDropoutsTime
	NVAR RemoveDropoutsFraction
	if(RemoveDropoutsTime<0.01)
		RemoveDropoutsTime=0.1
	endif
	if(RemoveDropoutsFraction<0.01)
		RemoveDropoutsFraction=0.5
	endif
	NVAR RemoveDropoutsAvePnts
	if(RemoveDropoutsAvePnts<10)
		RemoveDropoutsAvePnts=50
	endif
	
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IN3_MainPanel()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,390,690) as "USAXS data reduction"
	DoWindow/C USAXSDataReduction
	//text and dividers
//	SetDrawLayer UserBack
//	SetDrawEnv fname= "Times New Roman", save
//	SetDrawEnv fname= "Times New Roman",fsize= 22,fstyle= 3,textrgb= (0,0,52224)
//	DrawText 50,23,"USAXS data reduction panel"
	TitleBox Title title="\Zr210USAXS data reduction panel",pos={40,3},frame=0,fstyle=3,size={300,24},fColor=(1,4,52428)

	//SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	//TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,181},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	//DrawText 5,580,"To limit range of data being used for subtraction, set cursor A"
	//DrawText 5,600," on first point and B on last point of either sample of blank data"

	TitleBox Info1 title="\Zr120To limit range of data being used for subtraction, set cursor A",pos={5,565},frame=0,fstyle=1,anchor=MC, size={380,20},fColor=(1,4,52428)
	TitleBox Info2 title="\Zr120 on first point and B on last point of either sample of blank data",pos={5,580},frame=0,fstyle=1, anchor=MC,size={380,20},fColor=(1,4,52428)
	//some local controls
	CheckBox IsBlank,pos={20,35},size={90,14},proc=IN3_MainPanelCheckBox,title="Proces as blank"
	CheckBox IsBlank,variable= root:Packages:Indra3:IsBlank, help={"Check, if you want to process this run as blank"}
//	CheckBox RecalculateAutomatically,pos={220,25},size={90,14},proc=IN3_MainPanelCheckBox,title="Process Automatically"
//	CheckBox RecalculateAutomatically,variable= root:Packages:Indra3:RecalculateAutomatically, help={"Check, if you want to process data automatically"}

	//use general controls package, modify asnecessary
	string AllowedUserTypes="USAXS_PD;"
	string XUserTypeLookup="USAXS_PD:AR_Encoder;"
	IR2C_AddDataControls("Indra3","USAXSDataReduction","","",AllowedUserTypes,"USAXS raw data",XUserTypeLookup,"", 0,0)
	SVAR DataFolderName=	root:Packages:Indra3:DataFolderName
	DataFolderName="---"
	PopupMenu QvecDataName disable=1
	PopupMenu IntensityDataName disable=1
	PopupMenu ErrorDataName disable=1
	CheckBox UseQRSData disable=1
	CheckBox UseUserDefinedData disable=1
	SetVariable WaveMatchStr, disable=1
	NVAR useUserDefinedData=root:Packages:Indra3:UseUserDefinedData
	UseUserDefinedData=1
	//more local controls.
	SVAR BlankName = root:Packages:Indra3:BlankName
	string temppopStr
	if(strlen(BlankName)>3)
		temppopStr = BlankName
	else
		temppopStr = "---"
	endif
	PopupMenu SelectBlankFolder,pos={8,80},size={180,21},proc=IN3_InputPopMenuProc,title="Blank folder", help={"Select folder with Blank data"}
	PopupMenu SelectBlankFolder,mode=1,popvalue=temppopStr,value= #"\"---;\"+IN3_GenStringOfFolders(1)"
	NVAR IsBlank=root:Packages:Indra3:IsBlank
	PopupMenu SelectBlankFolder, disable = IsBlank
	
	Button ProcessData,pos={10,110},size={90,20},proc=IN3_InputPanelButtonProc,title="Load and process", help={"Load data and process them"}
	Button SelectNextSampleAndProcess,pos={110,110},size={120,20},proc=IN3_InputPanelButtonProc,title="Load Process Save next", help={"Select next sample in order - process - and save"}
	Button SaveResults,pos={240,110},size={120,20},proc=IN3_InputPanelButtonProc,title="Save Data", help={"Save results into original folder"}
	NVAR UserSavedData=root:Packages:Indra3:UserSavedData
	if(!UserSavedData)
		Button SaveResults fColor=(65280,0,0)
		TitleBox SavedData pos={200,135}, title="  Data   NOT   saved  ", fColor=(0,0,0), frame=1,labelBack=(65280,0,0)
	else
		Button SaveResults 
		TitleBox SavedData pos={200,135}, title="  Data   are   saved  ", fColor=(0,0,0),labelBack=(47872,47872,47872),  frame=2
	endif
	SetVariable userFriendlySamplename title="Sample name:",pos={5,160},size={380,20},disable=2, labelBack=(65535,65535,65535)
	SetVariable userFriendlySamplename variable=root:Packages:Indra3:userFriendlySamplename,format="",limits={-1,1,1}
	SetVariable userFriendlySamplename frame=0,fstyle=1,help={"Name of current data set loaded"}

	SetVariable OriginalDataFolder title="Folder name:",pos={5,180},size={380,20},disable=2, labelBack=(65535,65535,65535)
	SetVariable OriginalDataFolder variable=root:Packages:Indra3:DataFolderName,format="",limits={-1,1,1}
	SetVariable OriginalDataFolder frame=0,fstyle=1,help={"Folder from which current data set was loaded"}



	//Data Tabs definition
	TabControl DataTabs,pos={2,200},size={380,320},proc=NI3_TabPanelControl
	TabControl DataTabs,tabLabel(0)="Sample",tabLabel(1)="Diode"
	TabControl DataTabs,tabLabel(2)="Geometry",tabLabel(3)="Calibration",tabLabel(4)="MSAXS", value= 0
	//tab 0 Sample controls
	NVAR CalculateWeight=root:Packages:Indra3:CalculateWeight
	NVAR CalculateThickness=root:Packages:Indra3:CalculateThickness
	NVAR CalibrateToWeight=root:Packages:Indra3:CalibrateToWeight
	NVAR CalibrateToVolume=root:Packages:Indra3:CalibrateToVolume
	NVAR CalibrateArbitrary=root:Packages:Indra3:CalibrateArbitrary

	CheckBox CalibrateArbitrary,pos={20,225},size={90,14},proc=IN3_MainPanelCheckBox,title="Calibrate Arbitrary"
	CheckBox CalibrateArbitrary,variable= root:Packages:Indra3:CalibrateArbitrary, help={"Check, if you not want to calibrate data"}
	CheckBox CalibrateToVolume,pos={20,240},size={90,14},proc=IN3_MainPanelCheckBox,title="Calibrate [cm2/cm3]"
	CheckBox CalibrateToVolume,variable= root:Packages:Indra3:CalibrateToVolume, help={"Check, if you want to calibrate data to sample volume"}
	CheckBox CalibrateToWeight,pos={20,255},size={90,14},proc=IN3_MainPanelCheckBox,title="Calibrate [cm2/g]"
	CheckBox CalibrateToWeight,variable= root:Packages:Indra3:CalibrateToWeight, help={"Check, if you want to calibrate data to sample weight"}

	CheckBox CalculateThickness,pos={220,230},size={90,14},proc=IN3_MainPanelCheckBox,title="Calculate Thickness"
	CheckBox CalculateThickness,variable= root:Packages:Indra3:CalculateThickness, help={"Check, if you want to calculate sample thickness from transmission"}

	CheckBox CalculateWeight,pos={220,252},size={90,14},proc=IN3_MainPanelCheckBox,title="Calculate Weight", disable=CalibrateToVolume
	CheckBox CalculateWeight,variable= root:Packages:Indra3:CalculateWeight, help={"Check, if you want to calculate sample weight from transmission"}

	SetVariable SampleThickness,pos={5,285},size={280,22},title="\Zr120Sample Thickness [mm] =", bodyWidth=100
	SetVariable SampleThickness ,proc=IN3_ParametersChanged
	SetVariable SampleThickness,limits={0,Inf,0},variable= root:Packages:Indra3:SampleThickness, noedit=(CalculateThickness||CalculateWeight)//, frame=!(CalculateThickness&&CalculateWeight)

	Button RecoverDefault,pos={290,283},size={80,20} ,proc=IN3_InputPanelButtonProc,title="Spec value", help={"Reload original value from spec record"}

	SetVariable SampleTransmission,pos={5,335},size={280,22},title="\Zr120Sample Transmission ="
	SetVariable SampleTransmission ,bodyWidth=100, proc=IN3_ParametersChanged
	SetVariable SampleTransmission,limits={0,Inf,0},variable= root:Packages:Indra3:SampleTransmission, noedit=0, frame=0

	SetVariable SampleLinAbsorption,pos={5,360},size={280,22},title="\Zr120Sample absorp. coef [1/cm] ="
	SetVariable SampleLinAbsorption ,proc=IN3_ParametersChanged, bodyWidth=100
	SetVariable SampleLinAbsorption,limits={0,Inf,0},variable= root:Packages:Indra3:SampleLinAbsorption, noedit=!CalculateThickness, frame=CalculateThickness

	SetVariable SampleDensity,pos={5,385},size={280,22},title="\Zr120Sample density [g/cm3] ="
	SetVariable SampleDensity ,proc=IN3_ParametersChanged, bodyWidth=100
	SetVariable SampleDensity,limits={0,Inf,0},variable= root:Packages:Indra3:SampleDensity, noedit=!CalculateWeight, frame=CalculateWeight

	SetVariable SampleWeightInBeam,pos={5,410},size={300,22},title="\Zr120Sample weight [g/cm2 bm area] ="
	SetVariable SampleWeightInBeam ,proc=IN3_ParametersChanged, bodyWidth=100
	SetVariable SampleWeightInBeam,limits={0,Inf,0},variable= root:Packages:Indra3:SampleWeightInBeam, noedit=CalculateWeight, frame=!CalculateWeight

	SetVariable SampleFilledFraction,pos={5,410},size={280,22},title="\Zr120Sample filled fraction =", help={"amount of sample filled by material, 1 - porosity as fraction"}
	SetVariable SampleFilledFraction ,proc=IN3_ParametersChanged, bodyWidth=100
	SetVariable SampleFilledFraction,limits={0,Inf,0},variable= root:Packages:Indra3:SampleFilledFraction, noedit=!CalculateThickness, frame=CalculateThickness

	SetVariable USAXSPinTvalue,pos={5,435},size={280,22},title="\Zr120pinDiode Transmission  =", help={"If exists, measured transmission by pin diode"}
	SetVariable USAXSPinTvalue , bodyWidth=100
	SetVariable USAXSPinTvalue,limits={0,1,0},variable= root:Packages:Indra3:USAXSPinTvalue, noedit=1, frame=CalculateWeight

	CheckBox UsePinTransmission,pos={290,437},size={90,14},proc=IN3_MainPanelCheckBox,title="Use?"//, disable=CalibrateToVolume
	CheckBox UsePinTransmission,variable= root:Packages:Indra3:UsePinTransmission, help={"Use pin diode trnamission (if exists)"}

	SetVariable PeakToPeakTransmission,pos={5,455},size={300,22},title="\Zr120Peak-to-Peak T =", frame=0, noedit=1
	SetVariable PeakToPeakTransmission, bodyWidth=100
	SetVariable PeakToPeakTransmission,limits={0,Inf,0},variable= root:Packages:Indra3:SampleTransmissionPeakToPeak
	SetVariable MSAXSCorrectionT0,pos={5,475},size={300,22},title="MSAXS/pinSAXS Cor =", frame=0, noedit=1
	SetVariable MSAXSCorrectionT0 , bodyWidth=100
	SetVariable MSAXSCorrectionT0,limits={0,Inf,0},variable= root:Packages:Indra3:MSAXSCorrection

	SetVariable FlyScanRebinToPoints,pos={5,495},size={300,22},title="\Zr120FlyScan rebin to ="
	SetVariable FlyScanRebinToPoints ,bodyWidth=100, proc=IN3_ParametersChanged
	SetVariable FlyScanRebinToPoints,limits={0,Inf,0},variable= root:Packages:Indra3:FlyScanRebinToPoints

	//tab 2 - geometry controls

	SetVariable SpecCommand,pos={8,230},size={370,22},disable=2,title="Command:"
	SetVariable SpecCommand , frame=0,fstyle=1
	SetVariable SpecCommand,limits={0,Inf,0},variable= root:Packages:Indra3:SpecCommand

	SetVariable PhotoDiodeSize,pos={8,250},size={250,22},title="PD size [mm] ="
	SetVariable PhotoDiodeSize ,proc=IN3_ParametersChanged
	SetVariable PhotoDiodeSize,limits={0,Inf,0},variable= root:Packages:Indra3:PhotoDiodeSize
	SetVariable Wavelength,pos={8,275},size={250,22},title="Wavelength [A] ="
	SetVariable Wavelength ,proc=IN3_ParametersChanged
	SetVariable Wavelength,limits={0,Inf,0},variable= root:Packages:Indra3:Wavelength
	SetVariable SDDistance,pos={8,300},size={250,22},title="SD distance [mm] ="
	SetVariable SDDistance ,proc=IN3_ParametersChanged
	SetVariable SDDistance,limits={0,Inf,0},variable= root:Packages:Indra3:SDDistance

	SetVariable SlitLength,pos={8,325},size={250,22},title="Slit Length [A^-1] =", frame=0, disable=2
	SetVariable SlitLength ,proc=IN3_ParametersChanged
	SetVariable SlitLength,limits={0,Inf,0},variable= root:Packages:Indra3:SlitLength
	SetVariable NumberOfSteps,pos={8,350},size={250,22},title="Number of steps =", disable=2, frame=0
	SetVariable NumberOfSteps ,proc=IN3_ParametersChanged
	SetVariable NumberOfSteps,limits={0,Inf,0},variable= root:Packages:Indra3:NumberOfSteps


	//tab 1 Diode controls
	SetVariable VtoF,pos={29,230},size={200,22},proc=IN3_UPDParametersChanged,title="UPD V to f factor :"
	SetVariable VtoF ,format="%3.1e"
	SetVariable VtoF,limits={0,Inf,0},value= root:Packages:Indra3:UPD_Vfc
	SetVariable Gain1,pos={29,255},size={200,22},proc=IN3_UPDParametersChanged,title="Gain 1 :"
	SetVariable Gain1 ,format="%3.1e",labelBack=(65280,0,0) 
	SetVariable Gain1,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G1
	SetVariable Gain2,pos={29,280},size={200,22},proc=IN3_UPDParametersChanged,title="Gain 2 :"
	SetVariable Gain2 ,format="%3.1e",labelBack=(0,52224,0)
	SetVariable Gain2,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G2
	SetVariable Gain3,pos={29,305},size={200,22},proc=IN3_UPDParametersChanged,title="Gain 3 :"
	SetVariable Gain3 ,format="%3.1e",labelBack=(0,0,65280)
	SetVariable Gain3,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G3
	SetVariable Gain4,pos={29,330},size={200,22},proc=IN3_UPDParametersChanged,title="Gain 4 :"
	SetVariable Gain4 ,format="%3.1e",labelBack=(65280,35512,15384)
	SetVariable Gain4,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G4
	SetVariable Gain5,pos={29,355},size={200,22},proc=IN3_UPDParametersChanged,title="Gain 5 :"
	SetVariable Gain5 ,format="%3.1e",labelBack=(29696,4096,44800)
	SetVariable Gain5,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G5
	NVAR UPD_DK1Err=root:packages:Indra3:UPD_DK1Err
	NVAR UPD_DK2Err=root:packages:Indra3:UPD_DK2Err
	NVAR UPD_DK3Err=root:packages:Indra3:UPD_DK3Err
	NVAR UPD_DK4Err=root:packages:Indra3:UPD_DK4Err
	NVAR UPD_DK5Err=root:packages:Indra3:UPD_DK5Err
	SetVariable Bkg1,pos={20,380},size={200,18},proc=IN3_UPDParametersChanged,title="Background 1"
	SetVariable Bkg1 ,format="%g", labelBack=(65280,0,0)
	SetVariable Bkg1,limits={0,Inf,UPD_DK1Err},value= root:Packages:Indra3:UPD_DK1
	SetVariable Bkg2,pos={20,405},size={200,18},proc=IN3_UPDParametersChanged,title="Background 2"
	SetVariable Bkg2 ,format="%g",labelBack=(0,52224,0)
	SetVariable Bkg2,limits={0,Inf,UPD_DK2Err},value= root:Packages:Indra3:UPD_DK2
	SetVariable Bkg3,pos={20, 430},size={200,18},proc=IN3_UPDParametersChanged,title="Background 3"
	SetVariable Bkg3 ,format="%g",labelBack=(0,0,65280)
	SetVariable Bkg3,limits={0,Inf,UPD_DK3Err},value= root:Packages:Indra3:UPD_DK3
	SetVariable Bkg4,pos={20,455},size={200,18},proc=IN3_UPDParametersChanged,title="Background 4"
	SetVariable Bkg4 ,format="%g",labelBack=(65280,35512,15384)
	SetVariable Bkg4,limits={0,Inf,UPD_DK4Err},value= root:Packages:Indra3:UPD_DK4
	SetVariable Bkg5,pos={20,480},size={200,18},proc=IN3_UPDParametersChanged,title="Background 5"
	SetVariable Bkg5 ,format="%g",labelBack=(29696,4096,44800)
	SetVariable Bkg5,limits={0,Inf,UPD_DK5Err},value= root:Packages:Indra3:UPD_DK5
	SetVariable Bkg1Err,pos={225,380},size={90,18},title="Err"
	SetVariable Bkg1Err ,format="%2.2g", labelBack=(65280,0,0)
	SetVariable Bkg1Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK1Err,noedit=1
	SetVariable Bkg2Err,pos={225,405},size={90,18},title="Err"
	SetVariable Bkg2Err ,format="%2.2g", labelBack=(0,52224,0)
	SetVariable Bkg2Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK2Err,noedit=1
	SetVariable Bkg3Err,pos={225,430},size={90,18},title="Err"
	SetVariable Bkg3Err ,format="%2.2g", labelBack=(0,0,65280)
	SetVariable Bkg3Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK3Err,noedit=1
	SetVariable Bkg4Err,pos={225,455},size={90,18},title="Err"
	SetVariable Bkg4Err ,format="%2.2g", labelBack=(65280,35512,15384)
	SetVariable Bkg4Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK4Err,noedit=1
	SetVariable Bkg5Err,pos={225,480},size={90,18},title="Err"
	SetVariable Bkg5Err ,format="%2.2g", labelBack=(29696,4096,44800)
	SetVariable Bkg5Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK5Err,noedit=1
	SetVariable Bkg5Overwrite,pos={20,500},size={300,18},proc=IN3_UPDParametersChanged,title="Overwrite Background 5"
	SetVariable Bkg5Overwrite ,format="%g"
	SetVariable Bkg5Overwrite,limits={0,Inf,0},value= root:Packages:Indra3:OverwriteUPD_DK5

//calibration stuff...
	SetVariable MaximumIntensity,pos={8,230},size={300,22},title="Sample Maximum Intensity =", frame=0, disable=2
	SetVariable MaximumIntensity,limits={0,Inf,0},variable= root:Packages:Indra3:MaximumIntensity
	SetVariable PeakWidth,pos={8,250},size={300,22},title="Sample Peak Width [deg]=", frame=0, disable=2
	SetVariable PeakWidth,limits={0,Inf,0},variable= root:Packages:Indra3:PeakWidth
	SetVariable PeakWidthArcSec,pos={8,270},size={300,22},title="Sample Peak Width [arc sec]=", frame=0, disable=2
	SetVariable PeakWidthArcSec,limits={0,Inf,0},variable= root:Packages:Indra3:PeakWidthArcSec

	SetVariable BlankMaximum,pos={8,300},size={300,22},title="Blank Maximum Intensity =  ", frame=1
	SetVariable BlankMaximum ,proc=IN3_ParametersChanged
	SetVariable BlankMaximum,limits={0,Inf,0},variable= root:Packages:Indra3:BlankMaximum
	SetVariable BlankWidth,pos={8,320},size={300,22},title="Blank Peak Width [deg] =    ", frame=1
	SetVariable BlankWidth ,proc=IN3_ParametersChanged
	SetVariable BlankWidth,limits={0,Inf,0},variable= root:Packages:Indra3:BlankFWHM
	SetVariable BlankWidthArcSec,pos={8,340},size={300,22},title="Blank Peak Width [arc sec]=", frame=1
	SetVariable BlankWidthArcSec ,proc=IN3_ParametersChanged
	SetVariable BlankWidthArcSec,limits={0,Inf,0},variable= root:Packages:Indra3:BlankWidth

	Button RecoverDefaultBlnkVals,pos={200,370},size={80,20} ,proc=IN3_InputPanelButtonProc,title="Spec values", help={"Reload original value from spec record"}

	SetVariable SubtractFlatBackground,pos={8,420},size={300,22},title="Subtract Flat background=", frame=1
	SetVariable SubtractFlatBackground ,proc=IN3_ParametersChanged
	SetVariable SubtractFlatBackground,limits={0,Inf,1},variable= root:Packages:Indra3:SubtractFlatBackground
	

//MSAXS stuff
	CheckBox UseMSAXSCorrection,pos={8,230},size={300,14},proc=IN3_MainPanelCheckBox,title="MSAXS correctin on absolute intensity?"
	CheckBox UseMSAXSCorrection,variable= root:Packages:Indra3:UseMSAXSCorrection, help={"Check, if you want to use MSAXS correction"}

	SetVariable MSAXSCorrection,pos={8,250},size={300,22},title="MSAXS Correction =", frame=0, disable=2
	SetVariable MSAXSCorrection,limits={0,Inf,0},variable= root:Packages:Indra3:MSAXSCorrection
	SetVariable MSAXSStartPoint,pos={8,270},size={300,22},title="MSAXS start point =", frame=0, disable=2
	SetVariable MSAXSStartPoint,limits={0,Inf,0},variable= root:Packages:Indra3:MSAXSStartPoint
	SetVariable MSAXSEndPoint,pos={8,290},size={300,22},title="MSAXS end point =", frame=0, disable=2
	SetVariable MSAXSEndPoint,limits={0,Inf,0},variable= root:Packages:Indra3:MSAXSEndPoint
	setDataFolder OldDf
	NI3_TabPanelControl("",0)

	CheckBox RemoveDropouts,pos={8,525},size={150,14},title="Remove Flyscan dropouts?", proc=IN3_MainPanelCheckBox
	CheckBox RemoveDropouts,variable= root:Packages:Indra3:RemoveDropouts, help={"Check, if you want to remove flyscan dropouts"}
	SetVariable RemoveDropoutsAvePnts,pos={8,545},size={150,22},title="Intg. pnts (~50) =", frame=1
	SetVariable RemoveDropoutsAvePnts,limits={10,100,10},variable= root:Packages:Indra3:RemoveDropoutsAvePnts, proc=IN3_ParametersChanged

	SetVariable RemoveDropoutsTime,pos={200,525},size={180,22},title="Drpt. Time [s] =", frame=1
	SetVariable RemoveDropoutsTime,limits={0.01,5,0.1},variable= root:Packages:Indra3:RemoveDropoutsTime, proc=IN3_ParametersChanged
	SetVariable RemoveDropoutsFraction,pos={200,545},size={180,22},title="Drp Int. fract. (0.1-0.7) =", frame=1
	SetVariable RemoveDropoutsFraction,limits={0,1,0.1},variable= root:Packages:Indra3:RemoveDropoutsFraction, proc=IN3_ParametersChanged

	
	Button Recalculate,pos={50,615},size={120,20},proc=IN3_InputPanelButtonProc,title="Recalculate", help={"Recalculate the data"}
	Button RemovePoint,pos={200,615},size={170,20},proc=IN3_InputPanelButtonProc,title="Remove point with csr A", help={"Remove point with cursor A"}
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

