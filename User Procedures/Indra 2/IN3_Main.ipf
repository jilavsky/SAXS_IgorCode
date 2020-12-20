#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3			// Use modern global access method.
#pragma version = 1.99
#pragma IgorVersion=7.05

//DO NOT renumber Main files every time, these are main release numbers...

//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.99 added ability to load jpg image if user wants to see data collection image (and it exists...). 
//1.98  September2020 release. 
//1.97 February 2020, fix GUI for step scanning
	//1.97 add controls if to remove vibrations or not, seems sometimes is not vibrations which causes less points to be recorded... 
	//1.97 add is2DCollimated and fix sbFLyscan handling. few more fixes. 
//1.96 added use of FWHM from sample to GUI. Added ability to overwrite Flyscan amplifier dead times. 
//1.95 Added button to open Read me. 
//1.94 Added smooth R data option. 
//1.93 added Desmaering as optional data reduction step. 
//1.92  removed unused functions
//1.91 #pragma IgorVersion=7.00
//1.90 added OverRideSampleTransmission, added live processing and added graph with saved subtracted data. 
//		fixes to annoying behaviors (needless user questions), reorganized menu
//		enable negative override for Bkg5 
// 	Added first version of Import & Process panel. For now cannot handel step scanning. 
//1.89 fixes for 2016-02
//1.88 panel scaling.  
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

Constant IN3_ReduceDataMainVersionNumber=2.01		//these two needs to be the same!
Constant IN3_NewReduceDataMainVersionNum=2.01	 	//these two needs to be the same!
constant SmoothBlankForUSAXS = 1
Constant Indra_PDIntBackFixScaleVmin=1.1
Constant Indra_PDIntBackFixScaleVmax=0.3e-10
constant	RwaveSmooth1time = 0.01
constant	RwaveSmooth2time = 0.01
constant	RwaveSmooth3time = 0.03
constant	RwaveSmooth4time = 0.3
constant	RwaveSmooth5time = 0.6
constant CalMaxRatioUseSamFWHM = 1.12

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//****************************************************************************************
 

Function IN3_Main()

	string OldDf=GetDataFolder(1)

	IN3_Initialize()
	KillWIndow/Z RcurvePlotGraph
 	KillWIndow/Z USAXSDataReduction
 	IN3_MainPanel()
  	ING2_AddScrollControl()
	IN3_UpdatePanelVersionNumber("USAXSDataReduction", IN3_ReduceDataMainVersionNumber)
	setDataFolder OldDf
end


//************************************************************************************************************
//************************************************************************************************************

Function IN3_NewMain()

	string OldDf=GetDataFolder(1)
	IN2G_CheckScreenSize("height",790)
	IN3_Initialize()
	IN3_FlyScanInitializeImport()
	KillWIndow/Z RcurvePlotGraph
 	KillWIndow/Z USAXSDataReduction
 	IN3_MainPanelNew()
  	ING2_AddScrollControl()
	IN3_UpdatePanelVersionNumber("USAXSDataReduction", IN3_NewReduceDataMainVersionNum)
	setDataFolder OldDf

end


//************************************************************************************************************
//************************************************************************************************************
Function IN3_DoubleClickFUnction()

	STRUCT WMButtonAction B_Struct
	B_Struct.ctrlName="ProcessData2"
	B_Struct.eventcode=2
	B_Struct.win="USAXSDataReduction"
	IN3_InputPanelButtonProc(B_Struct)
	
end


//************************************************************************************************************
//************************************************************************************************************

Function IN3_MainPanelNew()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(22.25,43.25,445,860) as "USAXS data reduction"
	DoWindow/C USAXSDataReduction
	TitleBox Title title="\Zr170USAXS data reduction panel",pos={5,3},frame=0,fstyle=3,size={300,24},fColor=(1,4,52428), anchor=MC
	TitleBox Info1 title="\Zr100To limit range of data being used for subtraction, set cursor A",pos={10,708},frame=0,fstyle=1,anchor=MC, size={380,20},fColor=(1,4,52428)
	TitleBox Info2 title="\Zr100 on first point and B on last point of either sample of blank data",pos={10,723},frame=0,fstyle=1, anchor=MC,size={380,20},fColor=(1,4,52428)
	//some local controls

	IR3C_AddDataControls("USAXSHDFPath", "USAXS_FlyScanImport", "USAXSDataReduction","h5", "","Sort _XYZ","IN3_DoubleClickFUnction")
	Button SelectDataPath, pos={85,28},size={160,15}
	SetVariable DataPathString, pos={6,48},size={410,18}
	SetVariable NameMatchString, pos={6,69}
	SetVariable DataExtensionString, pos={255,69}
	Button SelectAll, pos={10,91}
	Button DeSelectAll, pos={150,91}
	PopupMenu SortOptionString, pos={285,91}
	TitleBox Info1PanelProc, pos={10,108}
	ListBox ListOfAvailableData,pos={3,123}, size={252,148}

	Button GetHelp,pos={315,10},size={80,15},fColor=(65535,32768,32768), proc=IN3_InputPanelButtonProc,title="Get Help", help={"Open www manual page for this tool"}
	Button GetReadme,pos={315,27},size={80,15}, proc=IN3_InputPanelButtonProc,title="Read me", help={"Open Read me short instructions"}
		
	CheckBox IsBlank,pos={265,113},size={90,14},proc=IN3_MainPanelCheckBox,title="Proces as blank"
	CheckBox IsBlank,variable= root:Packages:Indra3:IsBlank, help={"Check, if you want to process this run as blank"}
	CheckBox SmoothRCurveData,pos={360,113},size={90,14},proc=IN3_MainPanelCheckBox,title="Smooth"
	CheckBox SmoothRCurveData,variable= root:Packages:Indra3:SmoothRCurveData, help={"Check, if you want to smooth these data"}

	Button ProcessData2,pos={265,130},size={130,20},proc=IN3_InputPanelButtonProc,title="Load/process one", help={"Load data and process them"}
	Button SelectNextSampleAndProcess2,pos={265,152},size={130,20},proc=IN3_InputPanelButtonProc,title="Load/Process Many", help={"Select next sample in order - process - and save"}
	Button SaveResults,pos={265,174},size={130,20},proc=IN3_InputPanelButtonProc,title="Save Data", help={"Save results into original folder"}
	Button LiveProcessing,pos={265,196},size={130,16},proc=IN3_InputPanelButtonProc,title="Live processing", help={"Switch on and off live data visualization and processing"}

	NVAR UserSavedData=root:Packages:Indra3:UserSavedData
	if(!UserSavedData)
		Button SaveResults fColor=(65280,0,0)
		TitleBox SavedData pos={261,217}, title="  Data   NOT   saved  ", fColor=(0,0,0), frame=1,labelBack=(65280,0,0), fixedSize=1,size={160,18}
	else
		Button SaveResults 
		TitleBox SavedData pos={261,217}, title="  Data   are   saved  ", fColor=(0,0,0),labelBack=(47872,47872,47872),  frame=2,fixedSize=1,size={160,18}
	endif
	TitleBox RemoveFromNameTbx pos={260,240}, title="Remove From name (str):",size={150,15}
	SetVariable RemoveFromNameString,pos={260,260},size={157,15},noproc,title=" "
	SetVariable RemoveFromNameString,help={"String which will be removed from data name"}
	SetVariable RemoveFromNameString,value= root:Packages:USAXS_FlyScanImport:RemoveFromNameString

	SetVariable userFriendlySamplename title="Sample name:",pos={10,274},size={380,20},noedit=1, labelBack=0
	SetVariable userFriendlySamplename variable=root:Packages:Indra3:userFriendlySamplename,format="",limits={-1,1,1}
	SetVariable userFriendlySamplename frame=0,fstyle=1,help={"Name of current data set loaded"}

	SetVariable OriginalDataFolder title="Folder name:",pos={10,292},size={380,20},noedit=1, labelBack=0
	SetVariable OriginalDataFolder variable=root:Packages:Indra3:userFriendlySampleDFName,format="",limits={-1,1,1}
	SetVariable OriginalDataFolder frame=0,fstyle=1,help={"Folder from which current data set was loaded"}

	//more local controls.
	SVAR BlankName = root:Packages:Indra3:BlankName
	NVAR IsBlank=root:Packages:Indra3:IsBlank
	NVAR SmoothRCurveData = root:Packages:Indra3:SmoothRCurveData
	string temppopStr
	if(strlen(BlankName)>3)
		temppopStr = BlankName
	else
		temppopStr = "---"
		IsBlank = 1
		SmoothRCurveData = 1
	endif
	PopupMenu SelectBlankFolder,pos={15,315},size={330,21},proc=IN3_InputPopMenuProc,title="Blank folder", help={"Select folder with Blank data"}
	PopupMenu SelectBlankFolder,mode=1,popvalue=temppopStr,value= #"\"---;\"+IN3_GenStringOfFolders(1)",fColor=(1,16019,65535)
	PopupMenu SelectBlankFolder, disable = IsBlank
	TitleBox SelectBlankFolderWarning title="\Zr120 Blank auto selected!!",pos={290,292},frame=0,fstyle=1, anchor=MC,size={120,20},fColor=(65535,0,0), disable=1
	CheckBox SmartSelectBlank,pos={290,315},size={90,14},noproc,title="Smart select Blank?"
	CheckBox SmartSelectBlank,variable= root:Packages:Indra3:SmartSelectBlank, help={"Check, if you want to try to select Blank smartly (using order numbers)"}


	//Data Tabs definition
	TabControl DataTabs,pos={4,340},size={410,320},proc=NI3_TabPanelControl
	TabControl DataTabs,tabLabel(0)="Sample",tabLabel(1)="Diode"
	TabControl DataTabs,tabLabel(2)="Geometry",tabLabel(3)="Calibration",tabLabel(4)="MSAXS",tabLabel(5)="Desmear", value= 0
	//tab 0 Sample controls
	NVAR CalculateWeight=root:Packages:Indra3:CalculateWeight
	NVAR CalculateThickness=root:Packages:Indra3:CalculateThickness
	NVAR CalibrateToWeight=root:Packages:Indra3:CalibrateToWeight
	NVAR CalibrateToVolume=root:Packages:Indra3:CalibrateToVolume
	NVAR CalibrateArbitrary=root:Packages:Indra3:CalibrateArbitrary

	CheckBox CalibrateArbitrary,pos={20,365},size={90,14},proc=IN3_MainPanelCheckBox,title="Calibrate Arbitrary"
	CheckBox CalibrateArbitrary,variable= root:Packages:Indra3:CalibrateArbitrary, help={"Check, if you not want to calibrate data"}
	CheckBox CalibrateToVolume,pos={20,380},size={90,14},proc=IN3_MainPanelCheckBox,title="Calibrate [cm2/cm3]"
	CheckBox CalibrateToVolume,variable= root:Packages:Indra3:CalibrateToVolume, help={"Check, if you want to calibrate data to sample volume"}
	CheckBox CalibrateToWeight,pos={20,395},size={90,14},proc=IN3_MainPanelCheckBox,title="Calibrate [cm2/g]"
	CheckBox CalibrateToWeight,variable= root:Packages:Indra3:CalibrateToWeight, help={"Check, if you want to calibrate data to sample weight"}

	CheckBox CalculateThickness,pos={230,370},size={90,14},proc=IN3_MainPanelCheckBox,title="Calculate Thickness"
	CheckBox CalculateThickness,variable= root:Packages:Indra3:CalculateThickness, help={"Check, if you want to calculate sample thickness from transmission"}

	CheckBox CalculateWeight,pos={230,392},size={90,14},proc=IN3_MainPanelCheckBox,title="Calculate Weight", disable=CalibrateToVolume
	CheckBox CalculateWeight,variable= root:Packages:Indra3:CalculateWeight, help={"Check, if you want to calculate sample weight from transmission"}

	SetVariable SampleThickness,pos={20,425},size={300,22},title="\Zr120Sample Thickness [mm] =", bodyWidth= 80
	SetVariable SampleThickness ,proc=IN3_ParametersChanged
	SetVariable SampleThickness,limits={0,Inf,0},variable= root:Packages:Indra3:SampleThickness, noedit=(CalculateThickness||CalculateWeight)//, frame=!(CalculateThickness&&CalculateWeight)

	SetVariable OverideSampleThickness,pos={20,450},size={300,22},title="\Zr120Overide Sample Thickness [mm] =", bodyWidth= 80
	SetVariable OverideSampleThickness ,proc=IN3_ParametersChanged
	SetVariable OverideSampleThickness,limits={0,Inf,0},variable= root:Packages:Indra3:OverideSampleThickness, noedit=(CalculateThickness||CalculateWeight)//, frame=!(CalculateThickness&&CalculateWeight)


	Button RecoverDefault,pos={330,423},size={80,20} ,proc=IN3_InputPanelButtonProc,title="Spec value", help={"Reload original value from spec record"}

	SetVariable SampleTransmission,pos={20,485},size={300,22},title="\Zr120Sample Transmission ="
	SetVariable SampleTransmission ,bodyWidth=100, proc=IN3_ParametersChanged
	SetVariable SampleTransmission,limits={0,Inf,0},variable= root:Packages:Indra3:SampleTransmission, noedit=0, frame=0

	SetVariable SampleLinAbsorption,pos={20,508},size={300,22},title="\Zr120Sample absorp. coef [1/cm] ="
	SetVariable SampleLinAbsorption ,proc=IN3_ParametersChanged, bodyWidth=100
	SetVariable SampleLinAbsorption,limits={0,Inf,0},variable= root:Packages:Indra3:SampleLinAbsorption, noedit=!CalculateThickness, frame=CalculateThickness

	SetVariable SampleDensity,pos={20,528},size={300,22},title="\Zr120Sample density [g/cm3] ="
	SetVariable SampleDensity ,proc=IN3_ParametersChanged, bodyWidth=100
	SetVariable SampleDensity,limits={0,Inf,0},variable= root:Packages:Indra3:SampleDensity, noedit=!CalculateWeight, frame=CalculateWeight

	SetVariable SampleWeightInBeam,pos={20,550},size={300,22},title="\Zr120Sample weight [g/cm2 bm area] ="
	SetVariable SampleWeightInBeam ,proc=IN3_ParametersChanged, bodyWidth=100
	SetVariable SampleWeightInBeam,limits={0,Inf,0},variable= root:Packages:Indra3:SampleWeightInBeam, noedit=CalculateWeight, frame=!CalculateWeight

	SetVariable SampleFilledFraction,pos={20,550},size={300,22},title="\Zr120Sample filled fraction =", help={"amount of sample filled by material, 1 - porosity as fraction"}
	SetVariable SampleFilledFraction ,proc=IN3_ParametersChanged, bodyWidth=100
	SetVariable SampleFilledFraction,limits={0,Inf,0},variable= root:Packages:Indra3:SampleFilledFraction, noedit=!CalculateThickness, frame=CalculateThickness

	SetVariable USAXSPinTvalue,pos={20,575},size={300,22},title="\Zr120pinDiode Transmission  =", help={"If exists, measured transmission by pin diode"}
	SetVariable USAXSPinTvalue , bodyWidth=100
	SetVariable USAXSPinTvalue,limits={0,1,0},variable= root:Packages:Indra3:USAXSPinTvalue, noedit=1, frame=CalculateWeight

	CheckBox UsePinTransmission,pos={320,577},size={90,14},proc=IN3_MainPanelCheckBox,title="Use?"//, disable=CalibrateToVolume
	CheckBox UsePinTransmission,variable= root:Packages:Indra3:UsePinTransmission, help={"Use pin diode trnamission (if exists)"}

	SetVariable PeakToPeakTransmission,pos={20,595},size={300,22},title="\Zr120Peak-to-Peak T =", frame=0, noedit=1
	SetVariable PeakToPeakTransmission, bodyWidth=100
	SetVariable PeakToPeakTransmission,limits={0,Inf,0},variable= root:Packages:Indra3:SampleTransmissionPeakToPeak
	SetVariable MSAXSCorrectionT0, pos={20,615},size={300,22},title="\Zr120MSAXS/SAXS Cor =", frame=0, noedit=1
	SetVariable MSAXSCorrectionT0, bodyWidth=100
	SetVariable MSAXSCorrectionT0,limits={0,Inf,0},variable= root:Packages:Indra3:MSAXSCorrection

	SetVariable FlyScanRebinToPoints,pos={20,635},size={300,22},title="\Zr120FlyScan rebin to ="
	SetVariable FlyScanRebinToPoints ,bodyWidth=100, proc=IN3_ParametersChanged
	SetVariable FlyScanRebinToPoints,limits={0,Inf,0},variable= root:Packages:Indra3:FlyScanRebinToPoints

	//tab 2 - geometry controls

	SetVariable SpecCommand,pos={20,370},size={370,22},disable=2,title="Command:"
	SetVariable SpecCommand , frame=0,fstyle=1
	SetVariable SpecCommand,limits={0,Inf,0},variable= root:Packages:Indra3:SpecCommand

	SetVariable PhotoDiodeSize,pos={20,390},size={250,22},title="PD size [mm] ="
	SetVariable PhotoDiodeSize ,proc=IN3_ParametersChanged
	SetVariable PhotoDiodeSize,limits={0,Inf,0},variable= root:Packages:Indra3:PhotoDiodeSize
	SetVariable Wavelength,pos={20,415},size={250,22},title="Wavelength [A] ="
	SetVariable Wavelength ,proc=IN3_ParametersChanged
	SetVariable Wavelength,limits={0,Inf,0},variable= root:Packages:Indra3:Wavelength
	SetVariable SDDistance,pos={20,440},size={250,22},title="SD distance [mm] ="
	SetVariable SDDistance ,proc=IN3_ParametersChanged
	SetVariable SDDistance,limits={0,Inf,0},variable= root:Packages:Indra3:SDDistance

	SetVariable SlitLength,pos={20,465},size={250,22},title="Slit Length [A^-1] =", frame=0, disable=2
	SetVariable SlitLength ,proc=IN3_ParametersChanged
	SetVariable SlitLength,limits={0,Inf,0},variable= root:Packages:Indra3:SlitLength
	SetVariable NumberOfSteps,pos={20,490},size={250,22},title="Number of steps =", disable=2, frame=0
	SetVariable NumberOfSteps ,proc=IN3_ParametersChanged
	SetVariable NumberOfSteps,limits={0,Inf,0},variable= root:Packages:Indra3:NumberOfSteps


	//tab 1 Diode controls
	SetVariable VtoF,pos={20,370},size={180,22},proc=IN3_UPDParametersChanged,title="UPD V to f factor :"
	SetVariable VtoF ,format="%3.1e"
	SetVariable VtoF,limits={0,Inf,0},value= root:Packages:Indra3:UPD_Vfc
	SetVariable Gain1,pos={20,395},size={150,22},proc=IN3_UPDParametersChanged,title="Gain 1 :"
	SetVariable Gain1 ,format="%3.1e",labelBack=(65280,0,0) 
	SetVariable Gain1,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G1
	SetVariable Gain2,pos={20,420},size={150,22},proc=IN3_UPDParametersChanged,title="Gain 2 :"
	SetVariable Gain2 ,format="%3.1e",labelBack=(0,52224,0)
	SetVariable Gain2,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G2
	SetVariable Gain3,pos={20,445},size={150,22},proc=IN3_UPDParametersChanged,title="Gain 3 :"
	SetVariable Gain3 ,format="%3.1e",labelBack=(0,0,65280)
	SetVariable Gain3,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G3
	SetVariable Gain4,pos={20,470},size={150,22},proc=IN3_UPDParametersChanged,title="Gain 4 :"
	SetVariable Gain4 ,format="%3.1e",labelBack=(65280,35512,15384)
	SetVariable Gain4,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G4
	SetVariable Gain5,pos={20,495},size={150,22},proc=IN3_UPDParametersChanged,title="Gain 5 :"
	SetVariable Gain5 ,format="%3.1e",labelBack=(29696,4096,44800)
	SetVariable Gain5,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G5
	NVAR UPD_DK1Err=root:packages:Indra3:UPD_DK1Err
	NVAR UPD_DK2Err=root:packages:Indra3:UPD_DK2Err
	NVAR UPD_DK3Err=root:packages:Indra3:UPD_DK3Err
	NVAR UPD_DK4Err=root:packages:Indra3:UPD_DK4Err
	NVAR UPD_DK5Err=root:packages:Indra3:UPD_DK5Err
	SetVariable Bkg1,pos={20,520},size={150,18},proc=IN3_UPDParametersChanged,title="Background 1"
	SetVariable Bkg1 ,format="%g", labelBack=(65280,0,0)
	SetVariable Bkg1,limits={-inf,Inf,UPD_DK1Err},value= root:Packages:Indra3:UPD_DK1
	SetVariable Bkg2,pos={20,545},size={150,18},proc=IN3_UPDParametersChanged,title="Background 2"
	SetVariable Bkg2 ,format="%g",labelBack=(0,52224,0)
	SetVariable Bkg2,limits={-inf,Inf,UPD_DK2Err},value= root:Packages:Indra3:UPD_DK2
	SetVariable Bkg3,pos={20,570},size={150,18},proc=IN3_UPDParametersChanged,title="Background 3"
	SetVariable Bkg3 ,format="%g",labelBack=(0,0,65280)
	SetVariable Bkg3,limits={-inf,Inf,UPD_DK3Err},value= root:Packages:Indra3:UPD_DK3
	SetVariable Bkg4,pos={20,595},size={150,18},proc=IN3_UPDParametersChanged,title="Background 4"
	SetVariable Bkg4 ,format="%g",labelBack=(65280,35512,15384)
	SetVariable Bkg4,limits={-inf,Inf,UPD_DK4Err},value= root:Packages:Indra3:UPD_DK4
	SetVariable Bkg5,pos={20,620},size={150,18},proc=IN3_UPDParametersChanged,title="Background 5"
	SetVariable Bkg5 ,format="%g",labelBack=(29696,4096,44800)
	SetVariable Bkg5,limits={-inf,Inf,UPD_DK5Err},value= root:Packages:Indra3:UPD_DK5
	SetVariable Bkg1Err,pos={175,520},size={70,18},title="Err"
	SetVariable Bkg1Err ,format="%2.2g", labelBack=(65280,0,0)
	SetVariable Bkg1Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK1Err,noedit=1
	SetVariable Bkg2Err,pos={175,545},size={70,18},title="Err"
	SetVariable Bkg2Err ,format="%2.2g", labelBack=(0,52224,0)
	SetVariable Bkg2Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK2Err,noedit=1
	SetVariable Bkg3Err,pos={175,570},size={70,18},title="Err"
	SetVariable Bkg3Err ,format="%2.2g", labelBack=(0,0,65280)
	SetVariable Bkg3Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK3Err,noedit=1
	SetVariable Bkg4Err,pos={175,595},size={70,18},title="Err"
	SetVariable Bkg4Err ,format="%2.2g", labelBack=(65280,35512,15384)
	SetVariable Bkg4Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK4Err,noedit=1
	SetVariable Bkg5Err,pos={175,620},size={90,18},title="Err"
	SetVariable Bkg5Err ,format="%2.2g", labelBack=(29696,4096,44800)
	SetVariable Bkg5Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK5Err,noedit=1
	SetVariable Bkg5Overwrite,pos={20,640},size={245,18},proc=IN3_UPDParametersChanged,title="Overwrite Background 5"
	SetVariable Bkg5Overwrite ,format="%g"
	SetVariable Bkg5Overwrite,limits={-inf,Inf,0},value= root:Packages:Indra3:OverwriteUPD_DK5

	TitleBox Info5 title="\Zr100Subtract Flat backg = ",pos={290,610},frame=0,fstyle=1, anchor=LC,size={150,20},fColor=(1,4,52428)
	SetVariable SubtractFlatBackground,pos={300,630},size={100,22},title=" ", frame=1
	SetVariable SubtractFlatBackground ,proc=IN3_ParametersChanged
	SetVariable SubtractFlatBackground,limits={0,Inf,0},variable= root:Packages:Indra3:SubtractFlatBackground

	TitleBox Info3 title="\Zr100 Amplifier dead times [sec]",pos={230,365},frame=0,fstyle=1, anchor=MC,size={200,20},fColor=(1,4,52428)
	TitleBox Info4 title="\Zr100 RAW                Overwrite",pos={230,376},frame=0,fstyle=1, anchor=MC,size={200,20},fColor=(1,4,52428)

	SetVariable FSRage1DeadTime,pos={250,395},size={70,22},noproc,title="R1:"
	SetVariable FSRage1DeadTime ,format="%2.3g",labelBack=(65280,0,0), noedit=1
	SetVariable FSRage1DeadTime,limits={0,Inf,0},value= root:Packages:Indra3:FSRage1DeadTime
	SetVariable FSRage2DeadTime,pos={250,420},size={70,22},noproc,title="R2:"
	SetVariable FSRage2DeadTime ,format="%2.3g",labelBack=(0,52224,0), noedit=1
	SetVariable FSRage2DeadTime,limits={0,Inf,0},value= root:Packages:Indra3:FSRage2DeadTime
	SetVariable FSRage3DeadTime,pos={250,445},size={70,22},noproc,title="R3:"
	SetVariable FSRage3DeadTime ,format="%2.3g",labelBack=(0,0,65280), noedit=1
	SetVariable FSRage3DeadTime,limits={0,Inf,0},value= root:Packages:Indra3:FSRage3DeadTime
	SetVariable FSRage4DeadTime,pos={250,470},size={70,22},noproc,title="R4:"
	SetVariable FSRage4DeadTime ,format="%2.3g",labelBack=(65280,35512,15384), noedit=1
	SetVariable FSRage4DeadTime,limits={0,Inf,0},value= root:Packages:Indra3:FSRage4DeadTime
	SetVariable FSRage5DeadTime,pos={250,495},size={70,22},noproc,title="R5:"
	SetVariable FSRage5DeadTime ,format="%2.3g",labelBack=(29696,4096,44800), noedit=1
	SetVariable FSRage5DeadTime,limits={0,Inf,0},value= root:Packages:Indra3:FSRage5DeadTime

	SetVariable FSOverWriteRage1DeadTime,pos={340,395},size={60,18},noproc,title=" "
	SetVariable FSOverWriteRage1DeadTime ,format="%g", labelBack=(65280,0,0)
	SetVariable FSOverWriteRage1DeadTime,limits={-0,Inf,0},value= root:Packages:Indra3:FSOverWriteRage1DeadTime
	SetVariable FSOverWriteRage2DeadTime,pos={340,420},size={60,18},noproc,title=" "
	SetVariable FSOverWriteRage2DeadTime ,format="%g",labelBack=(0,52224,0)
	SetVariable FSOverWriteRage2DeadTime,limits={-0,Inf,0},value= root:Packages:Indra3:FSOverWriteRage2DeadTime
	SetVariable FSOverWriteRage3DeadTime,pos={340,445},size={60,18},noproc,title=" "
	SetVariable FSOverWriteRage3DeadTime ,format="%g",labelBack=(0,0,65280)
	SetVariable FSOverWriteRage3DeadTime,limits={-0,Inf,0},value= root:Packages:Indra3:FSOverWriteRage3DeadTime
	SetVariable FSOverWriteRage4DeadTime,pos={340,470},size={60,18},noproc,title=" "
	SetVariable FSOverWriteRage4DeadTime ,format="%g",labelBack=(65280,35512,15384)
	SetVariable FSOverWriteRage4DeadTime,limits={-0,Inf,0},value= root:Packages:Indra3:FSOverWriteRage4DeadTime
	SetVariable FSOverWriteRage5DeadTime,pos={340,495},size={60,18},noproc,title=" "
	SetVariable FSOverWriteRage5DeadTime ,format="%g",labelBack=(29696,4096,44800)
	SetVariable FSOverWriteRage5DeadTime,limits={-0,Inf,0},value= root:Packages:Indra3:FSOverWriteRage5DeadTime



//calibration stuff...
	SetVariable MaximumIntensity,pos={20,370},size={300,22},title="Sample Maximum Intensity =", frame=0, disable=2
	SetVariable MaximumIntensity,limits={0,Inf,0},variable= root:Packages:Indra3:MaximumIntensity
	SetVariable PeakWidth,pos={20,390},size={300,22},title="Sample Peak Width [deg]=", frame=0, disable=2
	SetVariable PeakWidth,limits={0,Inf,0},variable= root:Packages:Indra3:PeakWidth
	SetVariable PeakWidthArcSec,pos={20,410},size={300,22},title="Sample Peak Width [arc sec]=", frame=0, disable=2
	SetVariable PeakWidthArcSec,limits={0,Inf,0},variable= root:Packages:Indra3:PeakWidthArcSec

	SetVariable BlankMaximum,pos={20,440},size={300,22},title="Blank Maximum Intensity =  ", frame=1
	SetVariable BlankMaximum ,proc=IN3_ParametersChanged
	SetVariable BlankMaximum,limits={0,Inf,0},variable= root:Packages:Indra3:BlankMaximum
	SetVariable BlankWidth,pos={20,460},size={300,22},title="Blank Peak Width [deg] =    ", frame=1
	SetVariable BlankWidth ,proc=IN3_ParametersChanged
	SetVariable BlankWidth,limits={0,Inf,0},variable= root:Packages:Indra3:BlankFWHM
	SetVariable BlankWidthArcSec,pos={20,480},size={300,22},title="Blank Peak Width [arc sec]=", frame=1
	SetVariable BlankWidthArcSec ,proc=IN3_ParametersChanged
	SetVariable BlankWidthArcSec,limits={0,Inf,0},variable= root:Packages:Indra3:BlankWidth

	Button RecoverDefaultBlnkVals,pos={240,510},size={100,20} ,proc=IN3_InputPanelButtonProc,title="Spec values", help={"Reload original value from spec record"}

	CheckBox CalibrateUseSampleFWHM,pos={18,590},size={300,14},proc=IN3_MainPanelCheckBox,title="Use Sample FWHM for calibration?"
	CheckBox CalibrateUseSampleFWHM,variable= root:Packages:Indra3:CalibrateUseSampleFWHM, help={"Check, if you want to use FWHM for absolute intensity calibration"}
	

//MSAXS stuff
	CheckBox UseMSAXSCorrection,pos={20,370},size={300,14},proc=IN3_MainPanelCheckBox,title="MSAXS correctin on absolute intensity?"
	CheckBox UseMSAXSCorrection,variable= root:Packages:Indra3:UseMSAXSCorrection, help={"Check, if you want to use MSAXS correction"}

	SetVariable MSAXSCorrection,pos={20,390},size={300,22},title="MSAXS Correction =", frame=0, disable=2
	SetVariable MSAXSCorrection,limits={0,Inf,0},variable= root:Packages:Indra3:MSAXSCorrection
	SetVariable MSAXSStartPoint,pos={20,410},size={300,22},title="MSAXS start point =", frame=0, disable=2
	SetVariable MSAXSStartPoint,limits={0,Inf,0},variable= root:Packages:Indra3:MSAXSStartPoint
	SetVariable MSAXSEndPoint,pos={20,430},size={300,22},title="MSAXS end point =", frame=0, disable=2
	SetVariable MSAXSEndPoint,limits={0,Inf,0},variable= root:Packages:Indra3:MSAXSEndPoint


//Desmear tab
	CheckBox DesmearData,pos={20,365},size={90,14},proc=IN3_MainPanelCheckBox,title="Desmear Data?"
	CheckBox DesmearData,variable= root:Packages:Indra3:DesmearData, help={"Check, if you  want to desmear data immediately"}

	SetVariable BckgStartQ,pos={20,390},size={300,22},limits={0.01,0.5,0.01}, title="Background extrapolation start ="
	SetVariable BckgStartQ,variable= root:Packages:Indra3:DesmearBckgStart, proc=IN3_ParametersChanged
	SVAR BackgroundFunction=root:Packages:Indra3:DsmBackgroundFunction
	PopupMenu BackgroundFnct,pos={20,420},size={258,21}, proc=IN3_InputPopMenuProc,title="background function :   "
	PopupMenu BackgroundFnct,mode=1,value= "PowerLaw w flat;flat;power law;Porod;",popvalue=BackgroundFunction

	

	setDataFolder OldDf
	NI3_TabPanelControl("",0)

	CheckBox RemoveDropouts,pos={20,665},size={150,14},title="Remove Flyscan dropouts?", proc=IN3_MainPanelCheckBox
	CheckBox RemoveDropouts,variable= root:Packages:Indra3:RemoveDropouts, help={"Check, if you want to remove flyscan dropouts"}
	SetVariable RemoveDropoutsAvePnts,pos={20,685},size={150,22},title="Intg. pnts (~50) =", frame=1
	SetVariable RemoveDropoutsAvePnts,limits={10,100,10},variable= root:Packages:Indra3:RemoveDropoutsAvePnts, proc=IN3_ParametersChanged

	SetVariable RemoveDropoutsTime,pos={220,665},size={180,22},title="Drpt. Time [s] =", frame=1
	SetVariable RemoveDropoutsTime,limits={0.01,5,0.1},variable= root:Packages:Indra3:RemoveDropoutsTime, proc=IN3_ParametersChanged
	SetVariable RemoveDropoutsFraction,pos={220,685},size={180,22},title="Drp Int. fract. (0.1-0.7) =", frame=1
	SetVariable RemoveDropoutsFraction,limits={0,1,0.1},variable= root:Packages:Indra3:RemoveDropoutsFraction, proc=IN3_ParametersChanged


	CheckBox RemoveOscillations,pos={230,743},size={180,22},title="Remove Oscillations ", noproc
	CheckBox RemoveOscillations,variable= root:Packages:Indra3:RemoveOscillations, help={"Check, if you want to remove vibrations"}
	CheckBox DisplayJPGFile,pos={230,758},size={180,22},title="Display JPG File ", noproc
	CheckBox DisplayJPGFile,variable= root:Packages:Indra3:DisplayJPGFile, help={"Check, if you want to display jpg file (if it exists)"}
//

	SetVariable ListProcDisplayDelay,pos={20,773},size={180,22},title="Display delay ", frame=1
	SetVariable ListProcDisplayDelay,limits={0.1,100,1},variable= root:Packages:Indra3:ListProcDisplayDelay

	CheckBox OverWriteExistingData,pos={20,795},size={150,14},title="Overwrite existing data?", noproc
	CheckBox OverWriteExistingData,variable= root:Packages:Indra3:OverWriteExistingData, help={"Check, if you want to overwrite data which already exist"}

	CheckBox FindMinQForData,pos={230,773},size={150,14},title="Find MinQ automatically?", noproc
	CheckBox FindMinQForData,variable= root:Packages:Indra3:FindMinQForData, help={"Check, if you want to locate min-q for data start"}
	SetVariable MinQMinFindRatio,pos={220,795},size={170,22},title="I_S/I_Bl ratio =  ", frame=1
	SetVariable MinQMinFindRatio,limits={0.1,10,0.1},variable= root:Packages:Indra3:MinQMinFindRatio, noproc



	
//	Button Recalculate,pos={50,755},size={120,20},proc=IN3_InputPanelButtonProc,title="Recalculate", help={"Recalculate the data"}
//	Button RemovePoint,pos={200,755},size={170,20},proc=IN3_InputPanelButtonProc,title="Remove point with csr A", help={"Remove point with cursor A"}
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IN3_FailedLoadMessage(Filename) : Panel
      string FileName
	PauseUpdate    		// building window...
	NewPanel /W=(348,238,695,363)/K=1 as "File Failed to Load Message"
	DoWindow/C FailedLoadmessage
	ModifyPanel cbRGB=(65535,0,0)
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 3
	DrawText 24,30,"\\JC"+ FileName
	SetDrawEnv fsize=14, fstyle=3
	Drawtext 15, 60, "\\JCFile failed to load. Are you still collecting data?"
	SetDrawEnv fsize=14, fstyle=3
	Drawtext 15, 80, "Or the file may corrupted?"
	DrawText 10,100, "This message should disapper in 3 seconds on its own"
	DoUpdate
EndMacro
//************************************************************************************************************
//************************************************************************************************************
Function/T IN3_USAXSScanLoadHdf5File2(LoadManyDataSets)
	variable LoadManyDataSets
	
	string ListOfLoadedDataSets=""
	
	string OldDf=getDataFolder(1)
	setDataFolder root:
	NewDataFolder/O root:raw
	SetDataFolder root:raw
	Wave/T WaveOfFiles 	= root:Packages:USAXS_FlyScanImport:WaveOfFiles
	Wave WaveOfSelections	= root:Packages:USAXS_FlyScanImport:WaveOfSelections
	SVAR DataExtension 	= root:Packages:USAXS_FlyScanImport:DataExtension
	SVAR RemoveFromNameString = root:Packages:USAXS_FlyScanImport:RemoveFromNameString	
	NVAR OverWriteExistingData = root:Packages:Indra3:OverWriteExistingData
	NVAR DisplayJPGFile = root:Packages:Indra3:DisplayJPGFile
	
	variable NumSelFiles=sum(WaveOfSelections)	
	variable NumOpenedFiles=0
	if(NumSelFiles==0)
		return ""
	endif	
	variable i, Overwrite
	string FileName, ListOfExistingFolders, tmpDtaFldr, shortNameBckp, TargetRawFoldername
	String browserName, FileNameNoExtension, HDF5RawFolderWithData, SpecFileName, JPGFileName
	Variable locFileID
	For(i=0;i<numpnts(WaveOfSelections);i+=1)
		if(WaveOfSelections[i]&&(LoadManyDataSets || NumOpenedFiles<1))
			WaveOfSelections[i]=0
			NumOpenedFiles=1
			FileName= WaveOfFiles[i]
			FileNameNoExtension = ReplaceString("."+DataExtension, FileName, "")
			//this will display jpg image if it exists... 
			KillWindow/Z SampleImageDuringMeasurementImg
			if(DisplayJPGFile)
				JPGFileName = FileNameNoExtension+".jpg"
				setDataFOlder root:Packages:Indra3:
				ImageLoad/P=USAXSHDFPath/T=jpeg/Q/O/Z/N=SampleImageDuringMeasurement JPGFileName
				if(V_flag)	//success...
					Wave Img = root:Packages:Indra3:SampleImageDuringMeasurement
					NewImage/K=1/N=SampleImageDuringMeasurementImg Img
					MoveWindow /W=SampleImageDuringMeasurementImg 40,45,910,664
					AutoPositionWindow/R=USAXSDataReduction/M=1 SampleImageDuringMeasurementImg
				endif
				setDataFOlder root:raw
			endif
			//end if display image... 		
								//IN2G_CreateUserName(NameIn,MaxShortLength, MakeUnique, FolderWaveStrNum)
			FileNameNoExtension=IN2G_CreateUserName(ReplaceString(RemoveFromNameString,FileNameNoExtension,""),31,0,11)
								//shortFileName = IN2G_CreateUserName(shortFileName,31,0,11)
			//check if such data exist already...
			ListOfExistingFolders = DataFolderDir(1)
			HDF5OpenFile/R/Z /P=USAXSHDFPath locFileID as FileName
			if(V_flag!=0)	//failed
			   HDF5CLoseFile/Z locFileID 
				IN3_FailedLoadMessage(FileName)
				sleep/s 3
				DoWindow FailedLoadmessage
				if(V_Flag)		//this is for Igor 6 compatibility, KillWIndow /Z is only Igor 7
					KillWindow FailedLoadmessage
				endif
				print "Could not open "+FileName
				abort
				return ""
			else
				// Open OK?
				//Variable timerRefNum
				//timerRefNum = startMSTimer
				HDF5LoadGroup /O /R /T /IMAG=1 :, locFileID, "/"			
				//Variable microSeconds
				//microSeconds = StopMSTimer(timerRefNum)
				//print microSeconds
				if(strlen(S_dataFolderPaths)<5)
					Abort "HDF5 import failed in "+GetDataFolder(1) 
				endif
				HDF5RawFolderWithData=stringFromList(0,S_dataFolderPaths,";")
				//create Config_Version and make sure it has correct content... 
				KillWaves/Z Config_Version
				HDF5LoadData/Z /A="config_version"/Q  /Type=2 locFileID , "/entry/program_name" 
				if(V_Flag!=0)
					Make/T/N=1 Config_Version
					Config_Version[0]="0"
				endif
			   HDF5CloseFile/Z locFileID 		//cLose HDF5 file here... 
				//make sure config version is properly created. 
				Wave/T Config_Version
				variable/g $(HDF5RawFolderWithData+"HdfWriterVersion")
				NVAR HdfWriterVersion = $(HDF5RawFolderWithData+"HdfWriterVersion")
				HdfWriterVersion = str2num(Config_Version[0])
				KillWaves/Z Config_Version					
				//Now, figure out if we have flyscan or step scan.  
				//we are in root:raw here
				Wave/T/Z program_name = $(HDF5RawFolderWithData+"entry:program_name")
				variable isStepScan, isFlyScan
				if(StringMatch(program_name[0], "bluesky"))
					isStepScan = 1
					isFlyScan = 0
				elseif(StringMatch(program_name[0], "saveFlyData.py"))
					isStepScan = 0
					isFlyScan = 1
				else	//default to flyscan. May need to be in the future... 
					isStepScan = 0
					isFlyScan = 1
				endif

				print "Imported HDF5 file : "+FileName
#if(exists("AfterFlyImportHook")==6)  
				AfterFlyImportHook(HDF5RawFolderWithData)
#endif	
				string tempStrProcessedName
				if(isFlyScan)		//flyscan import
					tempStrProcessedName = IN3_FSConvertToUSAXS(HDF5RawFolderWithData, FileNameNoExtension)
				elseif(isStepScan)
					tempStrProcessedName = IN3_StepScanConvertToUSAXS(HDF5RawFolderWithData, FileNameNoExtension)		
				else
					Abort "Unknown scan type. Bug! Report me"		
				endif
				ListOfLoadedDataSets += tempStrProcessedName	+";"
				print "Converted : "+HDF5RawFolderWithData+" into USAXS data : "+ tempStrProcessedName
				KillDataFOlder/Z HDF5RawFolderWithData
			endif

		endif
	endfor
	setDataFolder OldDf
	
	return ListOfLoadedDataSets
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IN3_USAXSDataRedCheckVersion()	
	DoWindow USAXSDataReduction
	if(V_Flag)
		if(!IN3_CheckPanelVersionNumber("USAXSDataReduction", IN3_NewReduceDataMainVersionNum))
			DoAlert /T="The USAXS Data Reduction  panel was created by incorrect version of Indra " 1, "USAXS Data Reduction needs to be restarted to work properly. Restart now?"
			if(V_flag==1)
				DoWindow/K USAXSDataReduction
				//IN3_Main()
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
// 	When needed insert font size through lookup function - e.g., IN2G_LkUpDfltVar("LegendSize")
//	or for font type IN2G_LkUpDfltStr("FontType")
//	NOTE: Both return string values, because that is what is generally needed!!!!
// further variables and strings can be added, but need to be added to control panel too...
//	see example in : IR1_LogLogPlotU()  in this procedure file... 
//***********************************************************
//***********************************************************
Function IN3_ConfigureGUIfonts()
	IN2G_ConfigMain()
end

//Function/S IN2G_LkUpDfltStr(StrName)
//	string StrName
//
//	string result
//	string OldDf=getDataFolder(1)
//	SetDataFolder root:
//	if(!DataFolderExists("root:Packages:IrenaConfigFolder"))
//		IN2G_InitConfigMain()
//	endif
//	SetDataFolder root:Packages
//	setDataFolder root:Packages:IrenaConfigFolder
//	SVAR /Z curString = $(StrName)
//	if(!SVAR_exists(curString))
//		IN2G_InitConfigMain()
//		SVAR curString = $(StrName)
//	endif	
//	result = 	"'"+curString+"'"
//	setDataFolder OldDf
//	return result
//end
////***********************************************************
////***********************************************************
//
//Function/S IN2G_LkUpDfltVar(VarName)
//	string VarName
//
//	string result
//	string OldDf=getDataFolder(1)
//	SetDataFolder root:
//	if(!DataFolderExists("root:Packages:IrenaConfigFolder"))
//		IN2G_InitConfigMain()
//	endif
//	SetDataFolder root:Packages
//	setDataFolder root:Packages:IrenaConfigFolder
//	NVAR /Z curVariable = $(VarName)
//	if(!NVAR_exists(curVariable))
//		IN2G_InitConfigMain()
//		NVAR curVariable = $(VarName)
//	endif	
//	if(curVariable>=10)
//		result = num2str(curVariable)
//	else
//		result = "0"+num2str(curVariable)
//	endif
//	setDataFolder OldDf
//	return result
//end
//***********************************************************
//***********************************************************

//Function IN3_InitConfigMain()
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
//	ListOfVariables="LegendSize;TagSize;AxisLabelSize;LegendUseFolderName;LegendUseWaveName;DefaultFontSize;LastUpdateCheck;"
//	ListOfStrings="FontType;ListOfKnownFontTypes;DefaultFontType;"
//	variable i
//	//and here we create them
//	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
//		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
//	endfor		
//										
//	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
//		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
//	endfor	
//	//Now set default values
//	String VariablesDefaultValues
//	String StringsDefaultValues
//	if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
//		VariablesDefaultValues="LegendSize:8;TagSize:8;AxisLabelSize:8;LegendUseFolderName:0;LegendUseWaveName:0;"
//	else
//		VariablesDefaultValues="LegendSize:10;TagSize:10;AxisLabelSize:10;LegendUseFolderName:0;LegendUseWaveName:0;"
//	endif
//	StringsDefaultValues="FontType:"+StringFromList(0, IN3_CreateUsefulFontList() ) +";"
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
//	
//	SVAR ListOfKnownFontTypes=ListOfKnownFontTypes
//	ListOfKnownFontTypes=IN3_CreateUsefulFontList()
//	setDataFolder OldDf
//end
////***********************************************************
////***********************************************************
//
//Function IN3_ReadIrenaGUIPackagePrefs()
//
//	struct  IrenaPanelDefaults Defs
//	IN3_InitConfigMain()
//	SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
//	NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize
//	NVAR LegendSize=root:Packages:IrenaConfigFolder:LegendSize
//	NVAR TagSize=root:Packages:IrenaConfigFolder:TagSize
//	NVAR AxisLabelSize=root:Packages:IrenaConfigFolder:AxisLabelSize
//	NVAR LegendUseFolderName=root:Packages:IrenaConfigFolder:LegendUseFolderName
//	NVAR LegendUseWaveName=root:Packages:IrenaConfigFolder:LegendUseWaveName
//	NVAR LastUpdateCheck=root:Packages:IrenaConfigFolder:LastUpdateCheck
//	SVAR FontType=root:Packages:IrenaConfigFolder:FontType
//	LoadPackagePreferences /MIS=1   "Irena" , "IrenaDefaultPanelControls.bin", 0 , Defs
//	if(V_Flag==0)		
//		//print Defs
//		//print "Read Irena Panels and graphs preferences from local machine and applied them. "
//		//print "Note that this may have changed font size and type selection originally saved with the existing experiment."
//		//print "To change them please use \"Configure default fonts and names\""
//		if(Defs.Version==1 || Defs.Version==2)		//Lets declare the one we know as 1
//			DefaultFontType=Defs.PanelFontType
//			DefaultFontSize = Defs.defaultFontSize
//			LastUpdateCheck = Defs.LastUpdateCheck
//			if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
//				DefaultGUIFont /Win   all= {DefaultFontType, DefaultFontSize, 0 }
//			else
//				DefaultGUIFont /Mac   all= {DefaultFontType, DefaultFontSize, 0 }
//			endif
//			//and now recover the stored other parameters, no action on these...
//			 LegendSize=Defs.LegendSize
//			 TagSize=Defs.TagSize
//			 AxisLabelSize=Defs.AxisLabelSize
//			 LegendUseFolderName=Defs.LegendUseFolderName
//			 LegendUseWaveName=Defs.LegendUseWaveName
//			 FontType=Defs.LegendFontType
//		else
//			DoAlert 1, "Old version of GUI and Graph Fonts (font size and type preference) found. Do you want to update them now? These are set once on a computer and can be changed in \"Configure default fonts and names\"" 
//			if(V_Flag==1)
//				Execute("IN3_MainConfigPanel() ")
//			else
//			//	SavePackagePreferences /Kill   "Irena" , "IrenaDefaultPanelControls.bin", 0 , Defs	//does not work below 6.10
//			endif
//		endif
//	else 		//problem loading package defaults
//		Struct WMButtonAction ba
//		ba.ctrlName="DefaultValues"
//		IN3_KillPrefsButtonProc(ba)
//		DoAlert 1, "GUI and Graph defaults (font size and type preferences) not found. They wewre set to defaults. Do you want to set check now? These are set once on a computer and can be changed in \"Configure default fonts and names\" dialog" 
//		if(V_Flag==1)
//			Execute("IN3_MainConfigPanel() ")
//		endif	
//	endif
//end
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
				IN2G_ChangePanelControlsStyle()
				IN2G_SaveIrenaGUIPackagePrefs(0)
				PopupMenu DefaultFontType,win=IR2C_MainConfigPanel, mode=(1+WhichListItem(defFnt, ListOfKnownFontTypes))
				PopupMenu DefaultFontSize,win=IR2C_MainConfigPanel, mode=(1+WhichListItem(num2str(defFntSize), "8;9;10;11;12;14;16;18;20;24;26;30;"))
			endif
			break
	endswitch
	return 0
End
//***********************************************************
//***********************************************************
////***********************************************************
//Function IN3_SaveIrenaGUIPackagePrefs(KillThem)
//	variable KillThem
//	
//	struct  IrenaPanelDefaults Defs
//	IN2G_InitConfigMain()
//	SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
//	NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize
//	NVAR LegendSize=root:Packages:IrenaConfigFolder:LegendSize
//	NVAR TagSize=root:Packages:IrenaConfigFolder:TagSize
//	NVAR AxisLabelSize=root:Packages:IrenaConfigFolder:AxisLabelSize
//	NVAR LegendUseFolderName=root:Packages:IrenaConfigFolder:LegendUseFolderName
//	NVAR LegendUseWaveName=root:Packages:IrenaConfigFolder:LegendUseWaveName
//	NVAR LastUpdateCheck=root:Packages:IrenaConfigFolder:LastUpdateCheck
//	SVAR FontType=root:Packages:IrenaConfigFolder:FontType
//
//	Defs.Version			=		2
//	Defs.PanelFontType	 	= 		DefaultFontType
//	Defs.defaultFontSize 	= 		DefaultFontSize 
//	Defs.LegendSize 		= 		LegendSize
//	Defs.TagSize 			= 		TagSize
//	Defs.AxisLabelSize 		= 		AxisLabelSize
//	Defs.LegendUseFolderName = 	LegendUseFolderName
//	Defs.LegendUseWaveName = 	LegendUseWaveName
//	Defs.LegendFontType	= 		FontType
//	Defs.LastUpdateCheck	=		LastUpdateCheck
//	
//	if(KillThem)
//		SavePackagePreferences /Kill   "Irena" , "IrenaDefaultPanelControls.bin", 0 , Defs		//does not work below 6.10
//	//	IR2C_ReadIrenaGUIPackagePrefs()
//	else
//		SavePackagePreferences /FLSH=1   "Irena" , "IrenaDefaultPanelControls.bin", 0 , Defs
//	endif
//end
////***********************************************************
//***********************************************************

//Function IN3_ChangePanelControlsStyle()
//
//	SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
//	NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize
//
//	if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
//		DefaultGUIFont /Win   all= {DefaultFontType, DefaultFontSize, 0 }
//	else
//		DefaultGUIFont /Mac   all= {DefaultFontType, DefaultFontSize, 0 }
//	endif
//
//end
//
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
	NewDataFolder/O USAXS
	NewDataFolder/O/S Indra3


	string ListOfVariables
	string ListOfStrings
	variable i, j
	
	
	//Main parameters
	ListOfVariables="IsBlank;is2DCollimated;CalculateThickness;Wavelength;RecalculateAutomatically;SampleFilledFraction;Kfactor;"
	ListOfVariables+="SampleThickness;OverideSampleThickness;SampleTransmission;SampleLinAbsorption;SampleTransmissionPeakToPeak;"
	ListOfVariables+="SampleThicknessBckp;BlankWidthBckp;BlankFWHMBckp;BlankMaximumBckp;"
	ListOfVariables+="UPD_G1;UPD_G2;UPD_G3;UPD_G4;UPD_G5;UPD_Vfc;"
	ListOfVariables+="UPD_DK1;UPD_DK2;UPD_DK3;UPD_DK4;UPD_DK5;"
	ListOfVariables+="UPD_DK1Err;UPD_DK2Err;UPD_DK3Err;UPD_DK4Err;UPD_DK5Err;"
	ListOfVariables+="PhotoDiodeSize;SlitLength;NumberOfSteps;SDDistance;"
	ListOfVariables+="PeakCenterFitStartPoint;PeakCenterFitEndPoint;"
	ListOfVariables+="BeamCenter;MaximumIntensity;PeakWidth;PeakWidthArcSec;"
	ListOfVariables+="SampleQOffset;DisplayPeakCenter;DisplayAlignSaAndBlank;SampleAngleOffset;SmoothRCurveData;"
	ListOfVariables+="RemoveDropouts;RemoveDropoutsTime;RemoveDropoutsFraction;RemoveDropoutsAvePnts;"
	ListOfVariables+="FSOverWriteRage1DeadTime;FSOverWriteRage2DeadTime;FSOverWriteRage3DeadTime;FSOverWriteRage4DeadTime;FSOverWriteRage5DeadTime;"
	ListOfVariables+="FSRage1DeadTime;FSRage2DeadTime;FSRage3DeadTime;FSRage4DeadTime;FSRage5DeadTime;"

	ListOfVariables+="CalibrateToWeight;CalibrateToVolume;CalibrateArbitrary;SampleWeightInBeam;CalculateWeight;BeamExposureArea;SampleDensity;"
	ListOfVariables+="CalibrateUseSampleFWHM;"

	ListOfVariables+="BlankWidth;MSAXSCorrection;UseMSAXSCorrection;UsePinTransmission;USAXSPinTvalue;"
	ListOfVariables+="MSAXSStartPoint;MSAXSEndPoint;BlankFWHM;BlankMaximum;"

	ListOfVariables+="SubtractFlatBackground;UserSavedData;OverWriteExistingData;"
	ListOfVariables+="TrimDataStart;TrimDataEnd;OverwriteUPD_DK5;RemoveOscillations;"

	ListOfVariables+="UseModifiedGauss;UseGauss;UseLorenz;"
	ListOfVariables+="FlyScanRebinToPoints;ListProcDisplayDelay;"
	
	ListOfVariables+="FindMinQForData;MinQMinFindRatio;"

	ListOfVariables+="DesmearData;DesmearNumberOfInterations;DesmearNumPoints;DesmearBckgStart;"

	ListOfVariables+="SmartSelectBlank;DisplayJPGFile;"

	// these are created automatically... "DataFoldername;IntensityWavename;QWavename;ErrorWaveName;"
	ListOfStrings="SampleName;BlankName;userFriendlySamplename;userFriendlyBlankName;userFriendlySampleDFName;"
	ListOfStrings+="ListOfASBParameters;LastSample;DataFolderName;DsmBackgroundFunction;"
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
	NVAR ListProcDisplayDelay
	if(ListProcDisplayDelay<=0)
		ListProcDisplayDelay=2
	endif
	
	NVAR IsBlank
	NVAR SmoothRCurveData
	if(isBlank)
		SmoothRCurveData=1
	endif
	
	NVAR MinQMinFindRatio
	if(MinQMinFindRatio<1.03)
		MinQMinFindRatio=1.05
	endif
	NVAR FindMinQForData
	FindMinQForData = 1
	NVAR OverWriteExistingData
	OverWriteExistingData = 1
	NVAR RemoveOscillations
	RemoveOscillations = 1
	
	NVAR DisplayPeakCenter
	NVAR FlyScanRebinToPoints
	if(FlyScanRebinToPoints<100)
		FlyScanRebinToPoints=500			//2020-2-3 changed to 500, cpu seems to be good by now. 
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
	NVAR RemoveDropouts
	RemoveDropouts=1
	NVAR RemoveDropoutsTime
	NVAR RemoveDropoutsFraction
	if(RemoveDropoutsTime<0.01)
		RemoveDropoutsTime=0.25
	endif
	if(RemoveDropoutsFraction<0.01)
		RemoveDropoutsFraction=0.7
	endif
	NVAR RemoveDropoutsAvePnts
	if(RemoveDropoutsAvePnts<10)
		RemoveDropoutsAvePnts=50
	endif
	SVAR DsmBackgroundFunction
	if(strlen(DsmBackgroundFunction)<3)
		DsmBackgroundFunction = "PowerLaw w flat"
	endif
	NVAR DesmearBckgStart
	if(DesmearBckgStart<0.01)
		DesmearBckgStart=0.1
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

	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(2.25,43.25,390,710) as "USAXS data reduction"
	DoWindow/C USAXSDataReduction
	TitleBox Title title="\Zr210USAXS data reduction panel",pos={40,3},frame=0,fstyle=3,size={300,24},fColor=(1,4,52428), anchor=MC
	TitleBox Info1 title="\Zr100To limit range of data being used for subtraction, set cursor A",pos={5,565},frame=0,fstyle=1,anchor=MC, size={380,20},fColor=(1,4,52428)
	TitleBox Info2 title="\Zr100 on first point and B on last point of either sample of blank data",pos={5,580},frame=0,fstyle=1, anchor=MC,size={380,20},fColor=(1,4,52428)
	//some local controls
	CheckBox IsBlank,pos={20,35},size={90,14},proc=IN3_MainPanelCheckBox,title="Proces as blank"
	CheckBox IsBlank,variable= root:Packages:Indra3:IsBlank, help={"Check, if you want to process this run as blank"}
	Button GetHelp,pos={290,25},size={80,15},fColor=(65535,32768,32768), proc=IN3_InputPanelButtonProc,title="Get Help", help={"Open www manual page for this tool"}
	Button GetReadme,pos={290,40},size={80,15}, proc=IN3_InputPanelButtonProc,title="Read me", help={"Open Read me short instructions"}

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
	
	Button ProcessData,pos={5,110},size={110,20},proc=IN3_InputPanelButtonProc,title="Load and process", help={"Load data and process them"}
	Button SelectNextSampleAndProcess,pos={120,110},size={145,20},proc=IN3_InputPanelButtonProc,title="Load Process Save next", help={"Select next sample in order - process - and save"}
	Button SaveResults,pos={270,110},size={110,20},proc=IN3_InputPanelButtonProc,title="Save Data", help={"Save results into original folder"}
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
	SetVariable OriginalDataFolder variable=root:Packages:Indra3:userFriendlySampleDFName,format="",limits={-1,1,1}
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
	SetVariable OverideSampleThickness ,pos={555,285}

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
	SetVariable MSAXSCorrectionT0,pos={5,475},size={300,22},title="MSAXS/SAXS Cor =", frame=0, noedit=1
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
	SetVariable Gain2,pos={29,277},size={200,22},proc=IN3_UPDParametersChanged,title="Gain 2 :"
	SetVariable Gain2 ,format="%3.1e",labelBack=(0,52224,0)
	SetVariable Gain2,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G2
	SetVariable Gain3,pos={29,299},size={200,22},proc=IN3_UPDParametersChanged,title="Gain 3 :"
	SetVariable Gain3 ,format="%3.1e",labelBack=(0,0,65280)
	SetVariable Gain3,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G3
	SetVariable Gain4,pos={29,321},size={200,22},proc=IN3_UPDParametersChanged,title="Gain 4 :"
	SetVariable Gain4 ,format="%3.1e",labelBack=(65280,35512,15384)
	SetVariable Gain4,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G4
	SetVariable Gain5,pos={29,343},size={200,22},proc=IN3_UPDParametersChanged,title="Gain 5 :"
	SetVariable Gain5 ,format="%3.1e",labelBack=(29696,4096,44800)
	SetVariable Gain5,limits={0,Inf,0},value= root:Packages:Indra3:UPD_G5
	NVAR UPD_DK1Err=root:packages:Indra3:UPD_DK1Err
	NVAR UPD_DK2Err=root:packages:Indra3:UPD_DK2Err
	NVAR UPD_DK3Err=root:packages:Indra3:UPD_DK3Err
	NVAR UPD_DK4Err=root:packages:Indra3:UPD_DK4Err
	NVAR UPD_DK5Err=root:packages:Indra3:UPD_DK5Err
	SetVariable Bkg1,pos={20,365},size={200,18},proc=IN3_UPDParametersChanged,title="Background 1"
	SetVariable Bkg1 ,format="%g", labelBack=(65280,0,0)
	SetVariable Bkg1,limits={-inf,Inf,UPD_DK1Err},value= root:Packages:Indra3:UPD_DK1
	SetVariable Bkg2,pos={20,387},size={200,18},proc=IN3_UPDParametersChanged,title="Background 2"
	SetVariable Bkg2 ,format="%g",labelBack=(0,52224,0)
	SetVariable Bkg2,limits={-inf,Inf,UPD_DK2Err},value= root:Packages:Indra3:UPD_DK2
	SetVariable Bkg3,pos={20, 409},size={200,18},proc=IN3_UPDParametersChanged,title="Background 3"
	SetVariable Bkg3 ,format="%g",labelBack=(0,0,65280)
	SetVariable Bkg3,limits={-inf,Inf,UPD_DK3Err},value= root:Packages:Indra3:UPD_DK3
	SetVariable Bkg4,pos={20,431},size={200,18},proc=IN3_UPDParametersChanged,title="Background 4"
	SetVariable Bkg4 ,format="%g",labelBack=(65280,35512,15384)
	SetVariable Bkg4,limits={-inf,Inf,UPD_DK4Err},value= root:Packages:Indra3:UPD_DK4
	SetVariable Bkg5,pos={20,453},size={200,18},proc=IN3_UPDParametersChanged,title="Background 5"
	SetVariable Bkg5 ,format="%g",labelBack=(29696,4096,44800)
	SetVariable Bkg5,limits={-inf,Inf,UPD_DK5Err},value= root:Packages:Indra3:UPD_DK5
	SetVariable Bkg1Err,pos={225,365},size={90,18},title="Err"
	SetVariable Bkg1Err ,format="%2.2g", labelBack=(65280,0,0)
	SetVariable Bkg1Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK1Err,noedit=1
	SetVariable Bkg2Err,pos={225,387},size={90,18},title="Err"
	SetVariable Bkg2Err ,format="%2.2g", labelBack=(0,52224,0)
	SetVariable Bkg2Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK2Err,noedit=1
	SetVariable Bkg3Err,pos={225,409},size={90,18},title="Err"
	SetVariable Bkg3Err ,format="%2.2g", labelBack=(0,0,65280)
	SetVariable Bkg3Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK3Err,noedit=1
	SetVariable Bkg4Err,pos={225,431},size={90,18},title="Err"
	SetVariable Bkg4Err ,format="%2.2g", labelBack=(65280,35512,15384)
	SetVariable Bkg4Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK4Err,noedit=1
	SetVariable Bkg5Err,pos={225,453},size={90,18},title="Err"
	SetVariable Bkg5Err ,format="%2.2g", labelBack=(29696,4096,44800)
	SetVariable Bkg5Err,limits={-inf,Inf,0},value= root:Packages:Indra3:UPD_DK5Err,noedit=1
	SetVariable Bkg5Overwrite,pos={20,475},size={300,18},proc=IN3_UPDParametersChanged,title="Overwrite Background 5"
	SetVariable Bkg5Overwrite ,format="%g"
	SetVariable Bkg5Overwrite,limits={0,Inf,0},value= root:Packages:Indra3:OverwriteUPD_DK5
	SetVariable SubtractFlatBackground,pos={8,497},size={300,22},title="Subtract Flat background=", frame=1
	SetVariable SubtractFlatBackground ,proc=IN3_ParametersChanged
	SetVariable SubtractFlatBackground,limits={0,Inf,1},variable= root:Packages:Indra3:SubtractFlatBackground


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

	CheckBox CalibrateUseSampleFWHM,pos={8,440},size={300,14},proc=IN3_MainPanelCheckBox,title="Use Sample FWHM for calibration?"
	CheckBox CalibrateUseSampleFWHM,variable= root:Packages:Indra3:CalibrateUseSampleFWHM, help={"Check, if you want to use FWHM for absolute intensity calibration"}
	

//MSAXS stuff
	CheckBox UseMSAXSCorrection,pos={8,230},size={300,14},proc=IN3_MainPanelCheckBox,title="MSAXS correctinon absolute intensity?"
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

	CheckBox FindMinQForData,pos={10,610},size={150,14},title="Find MinQ automatically?", noproc
	CheckBox FindMinQForData,variable= root:Packages:Indra3:FindMinQForData, help={"Check, if you want to locate min-q for data start"}
	SetVariable MinQMinFindRatio,pos={200,610},size={150,22},title="I_S/I_Bl ratio =", frame=1
	SetVariable MinQMinFindRatio,limits={1,10,0.1},variable= root:Packages:Indra3:MinQMinFindRatio, noproc

	
	Button Recalculate,pos={50,635},size={120,20},proc=IN3_InputPanelButtonProc,title="Recalculate", help={"Recalculate the data"}
	Button RemovePoint,pos={200,635},size={170,20},proc=IN3_InputPanelButtonProc,title="Remove point with csr A", help={"Remove point with cursor A"}
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

Function IN3_GenerateReadMe()
	Dowindow USAXSQuickManual
	if (V_flag)
		Dowindow/F USAXSQuickManual
		abort
	endif
	String nb = "USAXSQuickManual"
	NewNotebook/N=$nb/F=1/V=1/K=3/W=(464,45,1152,768) as "Read Me"
	Notebook $nb defaultTab=36, magnification=150
	Notebook $nb showRuler=1, rulerUnits=2, updating={1, 3600}
	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",9,0,(0,0,0)}
	Notebook $nb newRuler=Header, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",14,0,(0,0,0)}
	Notebook $nb ruler=Header, text="Quick Manual for Indra 2 version of USAXS macros\r"
	Notebook $nb ruler=Normal, text="This is version 1.90 of Indra macros, date: 2/20/2017\r"
	Notebook $nb text="\r"
	Notebook $nb text="Data reduction summary:\r"
	Notebook $nb ruler=Normal; Notebook $nb  margins={0,35,468}
	Notebook $nb text="1.\tImport data: menu \"USAXS\" - \"Import and Reduce USAXS data\". ", fStyle=1
	Notebook $nb text="ONLY if you have Flyscan Nexus files as input", fStyle=-1, text=". ", fStyle=4, text="Most common"
	Notebook $nb fStyle=-1
	Notebook $nb text=". Opens GUI which can import data and process them at the same time. Follow procedure in step 3. \r"
	Notebook $nb text="2.\tAlternative: \r"
	Notebook $nb text="\ta.\tmenu \"USAXS\" - \"Other input methods\" - \"Import USAXS .... data\" - imports either Flyscan Nexus data,"
	Notebook $nb text=" Step scan data from spec file or Osmic-Rigaku data. Opens separate GUI to import appropriate data type."
	Notebook $nb text=" \r"
	Notebook $nb text="\tb. \tmenu \"USAXS\" - \"Other input methods\" - \"Reduce data \"    This will open GUI panel which is used to "
	Notebook $nb text="reduce data imported in step 2a. Follow procedure in step 3. \r"
	Notebook $nb text="3.\tProcess data - FIRST you need instrumental curve  (\"Process as Blank\"). Save processed instrumental c"
	Notebook $nb text="urve (Blank). With ", fStyle=1, text="correct", fStyle=-1, text=" Blank you can process samples. \r"
	Notebook $nb text="\tIf you want absolute intensities, you will need to know the sample thickness at this time.  If you don'"
	Notebook $nb text="t have that \tnow, you will need to repeat this procedure from this step. [NOTE: not exactly true, you ca"
	Notebook $nb text="n calculate it, if you \tknow linear absorption coefficient]\r"
	Notebook $nb text="\tIf we measured USAXS transmission (most likely) using pinDiode, it will be used automatically ("
	Notebook $nb fStyle=4, text="MSAXS correction is not needed", fStyle=-1
	Notebook $nb text=") If we did not measure pinDIode, may be you need to use MSAXS correction - but only if data are contami"
	Notebook $nb text="nated by mulitple scattering in the main tool. Check with staff. \r"
	Notebook $nb text="\tIf you use FlyScan, you may need to select FlyScan rebin to number of points...\r"
	Notebook $nb text="\tFor regular samples - 200 - 300 points\r"
	Notebook $nb text="\tFor Samples with monodispersed systems/diff peaks: more (up to 1000-2000) may be necessary\r"
	Notebook $nb text="\tDo NOT produce needlesly too many points - data will take much more time to analyze.  \r"
	Notebook $nb ruler=Normal, text="4.\tOther possible useful tools:\r"
	Notebook $nb text="\tTo Desmear data you will need Irena package which contains the desmearing routine in \"Other tools\"\r"
	Notebook $nb text="\t\"USAXS->USAXS Plotting tools\" - preferably use Irena \"Plotting tool I\"\r"
	Notebook $nb text="\t\t\"Standard ....\"\t standard USAXS type plots (Int-Q, Porod plot, Guinier plot)\r"
	Notebook $nb text="\t\t\"Basic ....\"\toffers wave variables most likely to be used in USAXS plots\r"
	Notebook $nb text="\t\t\"Generic ....\"\tallows user to plot any available wave variables (only one for non-USAXS data)\r"
	Notebook $nb ruler=Normal; Notebook $nb  margins={0,34,468}
	Notebook $nb text="5.\tTo export data use Irena, data export tool. But if you need to export ASCII data, they should be desm"
	Notebook $nb text="eared first, very likely... Keep that in mind. \r"
	Notebook $nb ruler=Normal, text="\t\r"
	Notebook $nb text="Suggestions: \r"
	Notebook $nb text="a.\tSave Igor experiment once in a while.\r"
	Notebook $nb text="b.\tDo not work with Igor files over an NFS network connection, first copy those files to a local disk.\r"
	Notebook $nb text="c.\tUse automatic logging functions -  \r"
	Notebook $nb text="\tmenu \"USAXS\" - \"Log in Notebook\" - \"Create logbook\" and \"Create Summary Notebook\". \r"
	Notebook $nb text="\r"
	Notebook $nb text="Make notes of any bugs and forward them to me. Make notes of any suggestions on changes in the wording o"
	Notebook $nb text="f dialogs - I am opened to any reasonable changes....\r"
end

