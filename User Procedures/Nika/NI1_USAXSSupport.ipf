#pragma rtGlobals=3		// Use modern global access method.
//#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.51

//*************************************************************************\
//* Copyright (c) 2005 - 2020, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.51 added passing through NXMetadata, NXSample, NXInstrument, NXUser
//1.50 Added Batch processing
//1.49 add support for calibration factor in USAXS/SAXS/WAXS instrument
//1.48 add solid angle correction to data reduction to match better SAXS and WAXS data. 
		//added Correction factor use, but for now hwardwired. This needs to be part of Nexus file... 
		//the correction factor will change for SAXS and WAXS due to different sensitivity needed, WAXS is 1/0.690699 more sensitive. 
//1.47 minor fix to mask size. 
//1.46 fix problem with WAXS when "WAXS use Blank" is not selected incorrectly set parameters. 
//1.45 minor fixes nd function names replaced. 
//1.44 add better handling of Slit length for SAXS with default value of 0.025 when user has nothing else. Better than 0. 
//1.43 minor fix for configruation. 
//1.42 changed 15IDD to 9IDC and modified for reading parameters from a file dynamically. 
//1.41 modified WAXS mask to have better masking of tile edges. 
//1.40 since Indra now can desmear data as part of last USAXS step, keep _C data always. 
//1.39 changed fake usaxs data from _usx to _u to save on numebr of characters
//1.38 added to Pilatus readout of beamsize for SAXS and WAXS
//1.37 added to SAXS use of thickness, why not - provides even better normalized data. 
//1.36 fixed issues with use of userSampleName
//1.35 fix for bigSAXS failure
//1.34 changed pinSAXS to SAXS
//1.33 MINOR FIX FOR BUG IN READING PILATUS SAXS PIX_Y BEAM CENTER POSITION AND SETUP FOR UES WITH THE NEW NEXUST SUPPORT. 
//1.32 checked fit checkboxes and added check if we are runnign on USAXS computer to set path the USAXS_data
//1.31 fix colorization of the LineuotDisplayPlot_Q graph. 
//1.30 added more calibratnt lines (10 for SAXS/WAXS)
//1.29 WAXS transmission correction and add Mask for Pilatus 200kw
//1.28 Minor fix to configuration
//1.27 trimmed the name used for line profiles to 17 characters only, did tno work with Line Profiles. 
//1.26 fixed error in I0 lookup for Sample exposure which used ungated signal instead of gated one. Not sure when did this happen... 
//1.25 fix WAXS normalization I0 lookup. fixed I0_blank
//1.24 added fix for Q resolution in line profile conversion. Related to adding the Line profile Q resolution ot main code.  
//1.23 added normalization for WAXS and modified GUI + SAXS default mask. Fixed bug error when run second time and help fiel alrerady existed.
//1.22 added more transferred parameters for pixel smearing. 
//1.21 added PE detector Nexus file for WAXS and for all detector read of Beam Size
//1.20 more modifications for 15ID SAXS
//1.19 modifications for 15ID SAXS done April 2015
//1.18 added use of SEM as error estimate for WAXS and SAXS (and old method for big SAXS) . SEM seems best for Pilatus detectors? 
//1.17 fixes for mask use in WAXS settings
//1.16 fixes for 9ID
//1.15 fixes for 9ID data after the move. Only partial fix. 
//1.14 widen the angular range for sector average for SAXS - seems to be OK now with vacuum chamber.  
//1.13 added Mask creation for horizon using vaccum chamber in 2014-08
//1.12 added WAXS controls for 2013-01
//1.11 fixed minor bug related to USAXS blank checking for SAXS caused by version 1.10
//1.10 modified function searching for thickenss of the sample, added use of pin diode for tranmsission measurements
//1.09 modified for beamline_support_version=1.0, May 2012 (for 2012-02). Fixed prior problems.
//1.08 bigSAXS support updated. Bad data in the header are found from 2012-01. Need to get it fixed. 
//1.07 minor fix which was causing problems when SAXS setup was not run but nexus files were used.  
//1.06 updated folder setting, which seemed to fail sicne the ConfigureNika initiates parameters. 
//1.05 added lookup for I0 gain as now we have autoranging I0 gain and therefore the gains may change between measurements. 
//1.04 fixed the issue with sliut length definition. Prior version had slit length of only 0.5 of the needed value due to the length definition we define it in USAXS.
//1.03 minor fix the header was read ONLY from Sample. It still is, but no error is reported... Fixed weird GUI panel checkbox bug. 
//1.02 Modified to be able to find values in new 2/2012 Nexus format (and keep compatibility with prior (2011) version). 
//1.01 fixed to make work with M_SMR_waves also
//1.0 initial release

//this is package for support of 15ID-D SAXS and SAXS instruments. 


Function NI1_9IDCConfigureNika()

	string OldDFf=GetDataFolder(1)

	//first initialize 
	NI1A_Initialize2Dto1DConversion()
	NEXUS_Initialize(0)
	NVAR NX_InputFileIsNexus = root:Packages:Irena_Nexus:NX_InputFileIsNexus
	NX_InputFileIsNexus = 1
	//set some parameters here:
	
	setDataFOlder root:Packages:Convert2Dto1D:
	
	string ListOfVariables="USAXSSlitLength;SAXSGenSmearedPinData;SAXSDeleteTempPinData;USAXSForceTransmissionDialog;"
	ListOfVariables +="USAXSSAXSselector;USAXSWAXSselector;USAXSBigSAXSselector;USAXSCheckForRIghtEmpty;USAXSCheckForRIghtDark;USAXSForceTransRecalculation;"
	ListOfVariables +="USAXSLoadListedEmpDark;USAXSForceUSAXSTransmission;ReadParametersFromEachFile;WAXSSubtractBlank;"
	string ListOfStrings="USAXSSampleName;"

	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	//set some defaults
	SVAR DataFileExtension = root:Packages:Convert2Dto1D:DataFileExtension
	DataFileExtension="Nexus"

	NVAR SAXSGenSmearedPinData=root:Packages:Convert2Dto1D:SAXSGenSmearedPinData
	SAXSGenSmearedPinData=1
	NVAR USAXSSAXSselector = root:Packages:Convert2Dto1D:USAXSSAXSselector
	NVAR USAXSBigSAXSselector = root:Packages:Convert2Dto1D:USAXSBigSAXSselector
	NVAR USAXSWAXSselector = root:Packages:Convert2Dto1D:USAXSWAXSselector
	if((USAXSWAXSselector+USAXSSAXSselector+USAXSBigSAXSselector)!=1)
		USAXSSAXSselector = 1
		USAXSBigSAXSselector = 0
		USAXSWAXSselector = 0
	endif
	
	NVAR ReadParametersFromEachFile
	NVAR NX_ReadParametersOnLoad = root:Packages:Irena_Nexus:NX_ReadParametersOnLoad
	ReadParametersFromEachFile = 1
	NX_ReadParametersOnLoad = 1
	
	NVAR WAXSSubtractBlank = root:Packages:Convert2Dto1D:WAXSSubtractBlank
	WAXSSubtractBlank=1
	
	//update main panel... 
	DoWIndow NI1A_Convert2Dto1DPanel
	if(V_Flag)
		PopupMenu Select2DDataType win=NI1A_Convert2Dto1DPanel, mode=4
		NI1A_UpdateDataListBox()
	endif
	//create config panel
	DoWindow NI1_9IDCConfigPanel
	if(V_Flag)
		DoWindow /F NI1_9IDCConfigPanel
	else
		NI1_9IDCConfigPanelFunction()
	endif
	AutopositionWindow/M=0 NI1_9IDCConfigPanel  
	
	setDataFolder OldDFf
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function NI1_9IDCConfigPanelFunction() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(470,87,1016,439)/N=NI1_9IDCConfigPanel
	DoWindow/C NI1_9IDCConfigPanel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 3,textrgb= (16385,16388,65535)
	DrawText 10,25,"9ID-C (or 15ID-D) Nexus file configuration"
	
	DrawText 10, 43, "SAXS : Pilatus 100k camera in USAXS (use with USAXS)"
	DrawText 10, 60, "WAXS    : Pilatus 100k or 200kw WAXS used in USAXS/SAXS/WAXS configuration"
	DrawText 10, 77, "SAXS     : large SAXS camera in the 15ID-D (only SAXS, no USAXS)"
	Checkbox SAXSSelection,pos={10,90},size={100,20}, variable=root:Packages:Convert2Dto1D:USAXSSAXSselector, proc=NI1_9IDCCheckProc
	Checkbox SAXSSelection, title ="SAXS", help={"Use to configure Nika for SAXS"}
	Checkbox USAXSWAXSselector,pos={150,90},size={100,20}, variable=root:Packages:Convert2Dto1D:USAXSWAXSselector, proc=NI1_9IDCCheckProc
	Checkbox USAXSWAXSselector, title ="WAXS", help={"Use to configure Nika for WAXS"}
//	Checkbox BigSAXSSelection,pos={290,90},size={100,20}, variable=root:Packages:Convert2Dto1D:USAXSBigSAXSselector, proc=NI1_9IDCCheckProc
//	Checkbox BigSAXSSelection, title ="15ID SAXS", help={"Use to configure Nika for SAXS"}

	Button Open9IDCManual,pos={430,5},size={100,20},proc=NI1_9IDCButtonProc,title="Open manual"
	Button Open9IDCManual,help={"Open manual"}
	Button OpenReadme9IDC,pos={430,25},size={100,20},proc=NI1_9IDCButtonProc,title="Open Instructions"
	Button OpenReadme9IDC,help={"Open reademe with instructions"}
	
	NVAR ReadParametersFromEachFile = root:Packages:Convert2Dto1D:ReadParametersFromEachFile
	Checkbox ReadParametersFromEachFile,pos={229,115},size={100,20}, variable=root:Packages:Convert2Dto1D:ReadParametersFromEachFile, proc=NI1_9IDCCheckProc
	Checkbox ReadParametersFromEachFile, title ="Read Parameters from data files", help={"In this case we will read geometry values from each data file"}
	Button ConfigureDefaultMethods,pos={29,115},size={150,20},proc=NI1_9IDCButtonProc,title="Set default settings"
	Button ConfigureDefaultMethods,help={"Sets default methods for the data reduction at 9IDC (or 15IDD)"}
	
	Button CalibrateDistance,pos={29,138},size={150,20},proc=NI1_9IDCButtonProc,title="Calibrate geometry"
	Button CalibrateDistance,help={"COnfigures for geometry calibration"}
	
	Button ConfigureWaveNoteParameters,pos={229,138},size={200,20},proc=NI1_9IDCButtonProc,title="Read geometry from wave note", disable=ReadParametersFromEachFile
	Button ConfigureWaveNoteParameters,help={"Sets default geometry values based on image currently loaded in the Nika package"}
	SetVariable USAXSSlitLength, pos={29,175}, size={150,20}, proc=NI1_9IDCSetVarProc, title="Slit length", variable=root:Packages:Convert2Dto1D:USAXSSlitLength
	SetVariable USAXSSlitLength,help={"USAXS slit length in 1/A"}
	Button SetUSAXSSlitLength,pos={229,170},size={200,20},proc=NI1_9IDCButtonProc,title="Set Slit Legnth"
	Button SetUSAXSSlitLength,help={"Locate USAXS data from which to get the Slit length"}
	Checkbox WAXSUseBlank,pos={229,167},size={100,20}, variable=root:Packages:Convert2Dto1D:WAXSSubtractBlank, proc=NI1_9IDCCheckProc
	Checkbox WAXSUseBlank, title ="WAXS use Blank", help={"COntrols if WAXS will subtacrt Empty/Blank image"}

//	Button WAXSUseBlank,pos={229,160},size={200,20},proc=NI1_9IDCButtonProc,title="WAXS Do NOT use Blank"
//	Button WAXSUseBlank,help={"Push NOT to use blank with 200kw WAXS"}, fColor=(30583,30583,30583)
//	Button CreateBadPIXMASK,pos={229,190},size={200,20},proc=NI1_9IDCButtonProc,title="Create SAXS/WAXS mask"
//	Button CreateBadPIXMASK,help={"Create mask for Pilatus 100 SAXS and 200kw WAXS"}
	Checkbox SAXSGenSmearedPinData,pos={29,220},size={150,20}, variable=root:Packages:Convert2Dto1D:SAXSGenSmearedPinData, proc=NI1_9IDCCheckProc
	Checkbox SAXSGenSmearedPinData, title ="Create Smeared Data", help={"Set to create smeared data for merging with USAXS"}
	Checkbox SAXSDeleteTempPinData,pos={229,220},size={150,20}, variable=root:Packages:Convert2Dto1D:SAXSDeleteTempPinData, noproc
	Checkbox SAXSDeleteTempPinData, title ="Delete temp Data", help={"Delete the sector and line averages"}


	TitleBox MoreUserControls  pos={20,257}, size={400,20}, title="\\Zr150Useful controls from Main Nika panel : "
	TitleBox MoreUserControls frame=0,fColor=(2,39321,1),help={"These are Duplciates of controls fromNIka user may need. "}
	//this is for SAXS
	CheckBox QvectorMaxNumPnts,pos={10,280},size={130,14},title="Max num points?",proc=NI1A_CheckProc
	CheckBox QvectorMaxNumPnts,help={"Use Max possible number of points? Num pnts = num pixels"}
	CheckBox QvectorMaxNumPnts,variable= root:Packages:Convert2Dto1D:QvectorMaxNumPnts
	SetVariable QbinPoints,pos={150,280},size={200,16},title="Number of points   "
	SetVariable QbinPoints,help={"Number of points in Q you want to create"}
	SetVariable QbinPoints,limits={0,Inf,10},value= root:Packages:Convert2Dto1D:QvectorNumberPoints
	


	//This is for WAXS
	CheckBox UseQvector,pos={10,280},size={90,14},title="Q space?", mode=1, proc=NI1A_CheckProc
	CheckBox UseQvector,help={"Select to have output as function of q [inverse nm]"}
	CheckBox UseQvector,variable= root:Packages:Convert2Dto1D:UseQvector
	CheckBox UseDspacing,pos={130,280},size={90,14},title="d ?", mode=1, proc=NI1A_CheckProc
	CheckBox UseDspacing,help={"Select to have output as function of d spacing"}
	CheckBox UseDspacing,variable= root:Packages:Convert2Dto1D:UseDspacing
	CheckBox UseTheta,pos={250,280},size={90,14},title="2 Theta ?", mode=1, proc=NI1A_CheckProc
	CheckBox UseTheta,help={"Select to have output as function of 2 theta"}
	CheckBox UseTheta,variable= root:Packages:Convert2Dto1D:UseTheta
	
	
//	Checkbox USAXSForceUSAXSTransmission,pos={29,255},size={150,20}, variable=root:Packages:Convert2Dto1D:USAXSForceUSAXSTransmission, noproc
//	Checkbox USAXSForceUSAXSTransmission, title ="Force use of USAXS Empty/Transm. ?", help={"Set to force use of same empty as USAXS and USAXS Transmission"}
//	Checkbox USAXSForceTransRecalculation,pos={29,255},size={150,20}, variable=root:Packages:Convert2Dto1D:USAXSForceTransRecalculation, noproc
//	Checkbox USAXSForceTransRecalculation, title ="Recalculate always transmission ?", help={"Set to get Transmission to be racalculated from Empty, Smaple & Dark scaler values"}
//	Checkbox ForceTransmissionDialog,pos={29,280},size={150,20}, variable=root:Packages:Convert2Dto1D:USAXSForceTransmissionDialog, noproc
//	Checkbox ForceTransmissionDialog, title ="Force transmission verification?", help={"Set to get Transmission dialog to check for every sample"}

//	Checkbox USAXSCheckForRIghtEmpty,pos={10,220},size={150,20}, variable=root:Packages:Convert2Dto1D:USAXSCheckForRIghtEmpty, noproc
//	Checkbox USAXSCheckForRIghtEmpty, title ="Check Empty Name", help={"Set to have code force dialog to load right empty"}
//	Checkbox USAXSCheckForRIghtDark,pos={180,220},size={150,20}, variable=root:Packages:Convert2Dto1D:USAXSCheckForRIghtDark, noproc
//	Checkbox USAXSCheckForRIghtDark, title ="Check Dark Name", help={"Set to have code force dialog to load correct Dark"}
//	Checkbox USAXSLoadListedEmpDark,pos={350,220},size={150,20}, variable=root:Packages:Convert2Dto1D:USAXSLoadListedEmpDark, noproc
//	Checkbox USAXSLoadListedEmpDark, title ="Automatically load Emp/Dark", help={"Load NX file listed Empty/Dark if they can be identified"}

	TitleBox LoadBlankWarning  pos={20,320}, size={400,20}, title="\\Zr150>>>>    Push \"Set default settings\" button now     <<<<"
	TitleBox LoadBlankWarning fColor=(52428,1,1),help={"Instructions to follow..."}
	NI1_9IDCDisplayAndHideControls()
EndMacro
//************************************************************************************************************
//************************************************************************************************************
Function NI1_9IDCDisplayAndHideControls()

	NVAR USAXSSAXSselector = root:Packages:Convert2Dto1D:USAXSSAXSselector
	NVAR USAXSWAXSselector = root:Packages:Convert2Dto1D:USAXSWAXSselector
	NVAR USAXSBigSAXSselector = root:Packages:Convert2Dto1D:USAXSBigSAXSselector
	NVAR ReadVals=root:Packages:Convert2Dto1D:ReadParametersFromEachFile
	variable DisplayPinCntrls=USAXSBigSAXSselector || USAXSWAXSselector
	variable DisplayWAXSCntrls=USAXSSAXSselector || USAXSWAXSselector

	Checkbox SAXSGenSmearedPinData, win= NI1_9IDCConfigPanel, disable = DisplayPinCntrls
	Checkbox SAXSDeleteTempPinData,  win= NI1_9IDCConfigPanel, disable = DisplayPinCntrls

	Button ConfigureWaveNoteParameters,  win= NI1_9IDCConfigPanel, disable = ReadVals
	Checkbox WAXSUseBlank,win= NI1_9IDCConfigPanel, disable = !USAXSWAXSselector
//	Button CreateBadPIXMASK,win= NI1_9IDCConfigPanel, disable = USAXSBigSAXSselector
	Button SetUSAXSSlitLength, win= NI1_9IDCConfigPanel, disable = DisplayPinCntrls
	SetVariable USAXSSlitLength, win= NI1_9IDCConfigPanel, disable = DisplayPinCntrls

	NVAR QvectorMaxNumPnts=root:Packages:Convert2Dto1D:QvectorMaxNumPnts
	CheckBox QvectorMaxNumPnts, win= NI1_9IDCConfigPanel, disable = (DisplayPinCntrls)
	SetVariable QbinPoints, win= NI1_9IDCConfigPanel, disable = (DisplayPinCntrls || QvectorMaxNumPnts)
	//This is for WAXS
	CheckBox UseQvector,win= NI1_9IDCConfigPanel, disable = !USAXSWAXSselector
	CheckBox UseDspacing,win= NI1_9IDCConfigPanel, disable = !USAXSWAXSselector
	CheckBox UseTheta,win= NI1_9IDCConfigPanel, disable = !USAXSWAXSselector

//	Checkbox USAXSForceUSAXSTransmission, win= NI1_9IDCConfigPanel, disable = DisplayPinCntrls

//	Checkbox USAXSCheckForRIghtEmpty, win= NI1_9IDCConfigPanel, disable = DisplayWAXSCntrls
//	Checkbox USAXSCheckForRIghtDark, win= NI1_9IDCConfigPanel, disable = DisplayWAXSCntrls
//	Checkbox USAXSForceTransRecalculation, win= NI1_9IDCConfigPanel, disable = DisplayWAXSCntrls
//	Checkbox USAXSLoadListedEmpDark, win= NI1_9IDCConfigPanel, disable = DisplayWAXSCntrls
//	Checkbox ForceTransmissionDialog, win= NI1_9IDCConfigPanel, disable = USAXSWAXSselector
end
//************************************************************************************************************
//************************************************************************************************************

Function NI1_9IDCCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR USAXSWAXSselector = root:Packages:Convert2Dto1D:USAXSWAXSselector
			NVAR USAXSSAXSselector = root:Packages:Convert2Dto1D:USAXSSAXSselector
			NVAR USAXSBigSAXSselector = root:Packages:Convert2Dto1D:USAXSBigSAXSselector
			NVAR readVals=root:Packages:Convert2Dto1D:ReadParametersFromEachFile
			if(stringmatch(cba.ctrlName,"ReadParametersFromEachFile"))
				NVAR NX_ReadParametersOnLoad = root:Packages:Irena_Nexus:NX_ReadParametersOnLoad
				NX_ReadParametersOnLoad = cba.checked
				NI1_9IDCDisplayAndHideControls()
			endif
			if(stringmatch(cba.ctrlName,"USAXSWAXSselector"))
				TitleBox LoadBlankWarning win=NI1_9IDCConfigPanel, title="\\Zr150>>>>    Push \"Set default settings\" button now     <<<<"
				if(checked)
					USAXSBigSAXSselector =0
					USAXSSAXSselector=0
					//USAXSWAXSselector=0
				endif
				NI1_9IDCDisplayAndHideControls()
			endif
			if(stringmatch(cba.ctrlName,"SAXSSelection"))
				TitleBox LoadBlankWarning win=NI1_9IDCConfigPanel, title="\\Zr150>>>>    Push \"Set default settings\" button now     <<<<"
				if(checked)
					USAXSBigSAXSselector =0
					USAXSSAXSselector=1
					//USAXSWAXSselector=0
				endif
				NI1_9IDCDisplayAndHideControls()
			endif
			
			if(stringmatch(cba.ctrlName,"BigSAXSSelection"))
				if(checked)
					//USAXSBigSAXSselector =0
					USAXSSAXSselector=0
					USAXSWAXSselector=0
				endif
				NI1_9IDCDisplayAndHideControls()
			endif
			if(stringmatch(cba.ctrlName,"WAXSUseBlank"))
				NI1_9IDCWAXSBlankSUbtraction(checked)				
			endif
			if(USAXSBigSAXSselector+USAXSSAXSselector+USAXSWAXSselector!=1)
				TitleBox LoadBlankWarning win=NI1_9IDCConfigPanel, title="\\Zr150>>>>    Push \"Set default settings\" button now     <<<<"
				USAXSBigSAXSselector =0
				USAXSSAXSselector=1
				USAXSWAXSselector=0
				NI1_9IDCDisplayAndHideControls()
			endif

			if(stringmatch(cba.CtrlName,"SAXSGenSmearedPinData"))
				NVAR UseLineProfile=root:Packages:Convert2Dto1D:UseLineProfile
				if(Checked)
					NVAR USAXSSlitLength = root:Packages:Convert2Dto1D:USAXSSlitLength
					if(USAXSSlitLength<0.001 || numtype(USAXSSlitLength)!=0)	//slit length not set, force user to find it...
						USAXSSlitLength = NI1_9IDCFIndSlitLength()
					endif
					UseLineProfile=1
				else
					UseLineProfile=0
				endif
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//************************************************************************************************************
//************************************************************************************************************
Function NI1_9IDCSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
				NI1_9IDCSetLineWIdth()			
		case 2: // Enter key
				NI1_9IDCSetLineWIdth()			
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************
//************************************************************************************************************

Function NI1_Open9IDCManual()
	//this function writes batch file and starts the manual.
	//we need to write following batch file: "C:\Program Files\WaveMetrics\Igor Pro Folder\User Procedures\Irena\Irena manual.pdf"
	//on Mac we just fire up the Finder with Mac type path... 
	
	//check where we run...
		string WhereIsManual
		string WhereAreProcedures=RemoveEnding(FunctionPath(""),"NI1_15IDDsupport.ipf")
		String manualPath = ParseFilePath(5,"15IDDpinSAXSAnalysis.pdf","*",0,0)
       	String cmd 
	
	if (stringmatch(IgorInfo(3), "*Macintosh*"))
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
		KillWIndow/Z NewBatchFile
		ExecuteScriptText "\""+SpecialDirPath("Temporary", 0, 1, 0 )+"StartManual.bat\""
	endif
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function NI1_9IDCButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here

			NVAR isSAXS=root:Packages:Convert2Dto1D:USAXSSAXSselector
			NVAR isWAXS=root:Packages:Convert2Dto1D:USAXSWAXSselector
			variable i
			if (stringmatch("Open9IDCManual",ba.CtrlName))
				NI1_Open9IDCManual()
			endif
			if (stringmatch("OpenReadme9IDC",ba.CtrlName))
				NI1_9IDCCreateHelpNbk()
			endif
			if (stringmatch("ConfigureDefaultMethods",ba.CtrlName) || stringmatch("CalibrateDistance",ba.CtrlName))
				//first kill the Nexus loader file in case we are using same name for SAXS and WAXS...
				KillDataFolder/Z root:Packages:NexusImportTMP:
				//now we should be able to read this in without challenges? 
				NI1A_Convert2Dto1DMainPanel()
				SVAR SampleNameMatchStr = root:Packages:Convert2Dto1D:SampleNameMatchStr
				SampleNameMatchStr =""
				string selectedFile
				selectedFile = NI1_9IDCSetDefaultConfiguration()				
				Wave SelectionsofCCDDataInCCDPath = root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers 
				Wave/T ListOfCCDDataInCCDPath = root:Packages:Convert2Dto1D:ListOf2DSampleData
				SelectionsofCCDDataInCCDPath=0
				for(i=0;i<numpnts(SelectionsofCCDDataInCCDPath);i+=1)
					if(stringmatch(selectedFile,ListOfCCDDataInCCDPath[i]))
						SelectionsofCCDDataInCCDPath[i] = 1
					endif
				endfor
				NI1A_DisplayOneDataSet()
				NI1_9IDCConfigNexus()
				NVAR ReadVals=root:Packages:Convert2Dto1D:ReadParametersFromEachFile
				if(ReadVals)
					for(i=0;i<numpnts(SelectionsofCCDDataInCCDPath);i+=1)
						if(stringmatch(selectedFile,ListOfCCDDataInCCDPath[i]))
							SelectionsofCCDDataInCCDPath[i] = 1
						endif
					endfor
					NI1A_DisplayOneDataSet()
				endif
				//and create mask automatically...
				if(isSAXS)
					NI1_9IDCCreateSAXSPixMask()		
					TitleBox LoadBlankWarning  win=NI1_9IDCConfigPanel, title="\\Zr150>>>> Load Empty/Blank and set Slit legth; ... done   <<<<"
					//force user to find Slit length oif needed
					NVAR/Z DesmearData = root:Packages:Indra3:DesmearData
					NVAR SAXSGenSmearedPinData = root:Packages:Convert2Dto1D:SAXSGenSmearedPinData
					if(NVAR_Exists(DesmearData))
						if(DesmearData)
							SAXSGenSmearedPinData =0 			//user is generating desmeared data, likely does not need smeared SAXS data
						else
							NVAR USAXSSlitLength=root:Packages:Convert2Dto1D:USAXSSlitLength
							USAXSSlitLength = NI1_9IDCFIndSlitLength()
							NI1_9IDCSetLineWIdth()							
						endif
					else
							NVAR USAXSSlitLength=root:Packages:Convert2Dto1D:USAXSSlitLength
							USAXSSlitLength = NI1_9IDCFIndSlitLength()
							NI1_9IDCSetLineWIdth()							
					endif
				elseif(isWAXS)	
					NVAR UseLineProfile= root:Packages:Convert2Dto1D:UseLineProfile		//uncheck just in case leftover from SAXS
					UseLineProfile=0
					NVAR WAXSSubtractBlank = root:Packages:Convert2Dto1D:WAXSSubtractBlank
					NI1_9IDCWAXSBlankSUbtraction(WAXSSubtractBlank)
					NI1_9IDCCreateWAXSPixMask()	
					TitleBox LoadBlankWarning  win=NI1_9IDCConfigPanel, title="\\Zr150>>>> Load Empty/Blank; ... done   <<<<"
				endif	
				//end of mask creation
				//set user to Empty?Dasrk tab 
				TabControl Convert2Dto1DTab win=NI1A_Convert2Dto1DPanel, value=3
				NI1A_TabProc("NI1A_Convert2Dto1DPanel",3)
			endif

			if (stringmatch("CalibrateDistance",ba.CtrlName))
				NI1_CreateBmCntrFile()
				SVAR BCMatchNameString = root:Packages:Convert2Dto1D:BCMatchNameString
				if(isSAXS)
					BCMatchNameString = "(?i)AgB"
				else
					BCMatchNameString = "(?i)LaB"
				endif
				NI1BC_UpdateBMCntrListBOx()
				Wave/T ListOfCCDDataInBmCntrPath = root:Packages:Convert2Dto1D:ListOfCCDDataInBmCntrPath
				Wave SelofCCDDataInBmCntrDPath = root:Packages:Convert2Dto1D:SelofCCDDataInBmCntrDPath
				variable found=0
				for(i=0;i<numpnts(SelofCCDDataInBmCntrDPath);i+=1)
					if(stringmatch(selectedFile,ListOfCCDDataInBmCntrPath[i]))
						SelofCCDDataInBmCntrDPath[i] = 1
						found = 1
					endif
				endfor
				if(!found)
					if(numpnts(SelofCCDDataInBmCntrDPath)==1)
						SelofCCDDataInBmCntrDPath[0]=1
						found=1
					endif
				endif
				if(found)
					NI1BC_BmCntrButtonProc("CreateROIWorkImage")
				endif		
			endif


			if (stringmatch("ConfigureWaveNoteParameters",ba.CtrlName))
				NI1_9IDCWaveNoteValuesNx()				
			endif
			if (stringmatch("SetUSAXSSlitLength",ba.CtrlName))
				NVAR USAXSSlitLength=root:Packages:Convert2Dto1D:USAXSSlitLength
				USAXSSlitLength = NI1_9IDCFIndSlitLength()
				NI1_9IDCSetLineWIdth()			
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function NI1_9IDCConfigNexus()


	NEXUS_ResetParamXRef(1)
	NEXUS_GuessParamXRef()
	Wave/T ListOfParamsAndPaths = root:Packages:Irena_Nexus:ListOfParamsAndPaths
	Wave ListOfParamsAndPathsSel = root:Packages:Irena_Nexus:ListOfParamsAndPathsSel

	NVAR useWAXS = root:Packages:Convert2Dto1D:USAXSWAXSselector
	NVAR useSAXS = root:Packages:Convert2Dto1D:USAXSSAXSselector
	NVAR useBigSAXS = root:Packages:Convert2Dto1D:USAXSBigSAXSselector

	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Load one Image file first so the tool can read the wave note information"  
	endif
	string OldNOte=note(w2D)
	SVAR Current2DFileName = root:Packages:Convert2Dto1D:FileNameToLoad
	variable beamline_support_version

	if(stringMatch("9ID", StringByKey("instrument:source:facility_beamline", OldNOte  , "=" , ";")) && stringMatch("Pilatus", StringByKey("data:model", OldNOte  , "=" , ";")))	
//		//9ID data from 2015 onwards... 
//		Wavelength = NumberByKey(NI1_9IDCFindKeyStr("monochromator:wavelength=", OldNote), OldNote  , "=" , ";")
//		XRayEnergy = 12.3984/Wavelength
		if(useSAXS)		//the title in NX files seems to be unusable for now... 
			ListOfParamsAndPaths[0][0]="UserSampleName"
			ListOfParamsAndPaths[0][1]=	""
//			PixelSizeX = NumberByKey(NI1_9IDCFindKeyStr("detector:x_pixel_size=", OldNote), OldNote  , "=" , ";")
//			PixelSizeY = NumberByKey(NI1_9IDCFindKeyStr("detector:y_pixel_size=", OldNote), OldNote  , "=" , ";")
//			HorizontalTilt = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_tilt_x=", OldNote), OldNote  , "=" , ";")
//			VerticalTilt = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_tilt_y=", OldNote), OldNote  , "=" , ";")
//			BeamCenterX = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_center_x_pixel=", OldNote), OldNote  , "=" , ";")
//			BeamCenterY = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_center_y_pixel=", OldNote), OldNote  , "=" , ";")
//			SampleToCCDdistance = NumberByKey(NI1_9IDCFindKeyStr("detector:distance=", OldNote), OldNote  , "=" , ";")
//			BeamSizeX = NumberByKey(NI1_9IDCFindKeyStr("shape:xsize=", OldNote), OldNote  , "=" , ";")
//			BeamSizeY = NumberByKey(NI1_9IDCFindKeyStr("shape:ysize=", OldNote), OldNote  , "=" , ";")
	elseif(useWAXS)
			ListOfParamsAndPaths[0][0]="UserSampleName"
			ListOfParamsAndPaths[0][1]=	""
			//ListOfParamsAndPaths[0][1]=	":entry:title"

			ListOfParamsAndPaths[1][0]="SampleThickness"
			ListOfParamsAndPaths[1][1]=	":entry:sample:thickness"

			ListOfParamsAndPaths[5][0]="SampleToCCDDistance"
			ListOfParamsAndPaths[5][1]=":entry:"+NI1_9IDCFindKeyStr("detector:distance=", OldNote)

			ListOfParamsAndPaths[8][0]="BeamCenterX"
			ListOfParamsAndPaths[8][1]=":entry:"+NI1_9IDCFindKeyStr("waxs_ccd_center_x_pixel=", OldNote)

			ListOfParamsAndPaths[9][0]="BeamCenterY"
			ListOfParamsAndPaths[9][1]=":entry:"+NI1_9IDCFindKeyStr("waxs_ccd_center_y_pixel=", OldNote)

			ListOfParamsAndPaths[10][0]="BeamSizeX"
			ListOfParamsAndPaths[10][1]=	":entry:"+NI1_9IDCFindKeyStr("shape:xsize=", OldNote)	
			ListOfParamsAndPaths[11][0]="BeamSizeY"
			ListOfParamsAndPaths[11][1]=	":entry:"+NI1_9IDCFindKeyStr("shape:ysize=", OldNote)

			ListOfParamsAndPaths[12][0]="PixelSizeX"
			ListOfParamsAndPaths[12][1]=":entry:"+NI1_9IDCFindKeyStr("x_pixel_size=", OldNote)	
			ListOfParamsAndPaths[13][0]="PixelSizeY"
			ListOfParamsAndPaths[13][1]=	":entry:"+NI1_9IDCFindKeyStr("y_pixel_size=", OldNote)


			ListOfParamsAndPaths[14][0]="HorizontalTilt"
			ListOfParamsAndPaths[14][1]=	":entry:"+NI1_9IDCFindKeyStr("waxs_ccd_tilt_x=", OldNote)	
			ListOfParamsAndPaths[15][0]="VerticalTilt"
			ListOfParamsAndPaths[15][1]=	":entry:"+NI1_9IDCFindKeyStr("waxs_ccd_tilt_y=", OldNote)

//			PixelSizeX = NumberByKey(NI1_9IDCFindKeyStr("waxs_detector:x_pixel_size=", OldNote), OldNote  , "=" , ";")
//			PixelSizeY = NumberByKey(NI1_9IDCFindKeyStr("waxs_detector:y_pixel_size=", OldNote), OldNote  , "=" , ";")
//			HorizontalTilt = NumberByKey(NI1_9IDCFindKeyStr("waxs_ccd_tilt_x=", OldNote), OldNote  , "=" , ";")
//			VerticalTilt = NumberByKey(NI1_9IDCFindKeyStr("waxs_ccd_tilt_y=", OldNote), OldNote  , "=" , ";")
 
//			BeamCenterX = NumberByKey(NI1_9IDCFindKeyStr("waxs_ccd_center_x_pixel=", OldNote), OldNote  , "=" , ";")
//			BeamCenterY = NumberByKey(NI1_9IDCFindKeyStr("waxs_ccd_center_y_pixel=", OldNote), OldNote  , "=" , ";")
//			SampleToCCDdistance = NumberByKey(NI1_9IDCFindKeyStr("waxs_detector:distance=", OldNote), OldNote  , "=" , ";")
//			BeamSizeX = NumberByKey(NI1_9IDCFindKeyStr("shape:xsize=", OldNote), OldNote  , "=" , ";")
//			BeamSizeY = NumberByKey(NI1_9IDCFindKeyStr("shape:ysize=", OldNote), OldNote  , "=" , ";")
		endif		
//		print "Set experimental settinsg and geometry from file :"+Current2DFileName
//		print "Wavelength = "+num2str(Wavelength)
//		print "XRayEnergy = "+num2str(12.3984/Wavelength)
//		print "PixelSizeX = "+num2str(PixelSizeX)
//		print "PixelSizeY = "+num2str(PixelSizeY)
//		print "BeamCenterX = "+num2str(BeamCenterX)
//		print "BeamCenterY = "+num2str(BeamCenterY)
//		print "SampleToCCDdistance = "+num2str(SampleToCCDdistance)
//		print "BeamSizeX = "+num2str(BeamSizeX)
//		print "BeamSizeY = "+num2str(BeamSizeY)
	else
			NVAR ReadVals=root:Packages:Convert2Dto1D:ReadParametersFromEachFile
			ReadVals = 0
			DOWINDOW/F NI1_9IDCConfigPanel
			NI1_9IDCDisplayAndHideControls()
			Abort "These data cannot be read from each file, likely too old. Try button \"Read geometry from wave note\", it is smarter"  
	endif
end
//************************************************************************************************************
Function NI1_9IDCCreateSAXSPixMask()			

	string OldDF=GetDataFolder(1)
	SetDataFolder root:Packages:Convert2Dto1D
	Make/O/B/U/N=(195,487) M_ROIMask
	M_ROIMask =1
	M_ROIMask[][0,7]=0
	M_ROIMask[86][17] = 0
	M_ROIMask[58][112] = 0
	
	string notestr="MaskOffLowIntPoints:0;LowIntToMaskOff:0>// ;ITEMNO:0;\r"
	notestr+="	SetDrawEnv xcoord= top,ycoord= left\r"
	notestr+="// ;ITEMNO:1;\r"
	notestr+="// ;ITEMNO:1;,linefgc= (3,52428,1)\r"
	notestr+="// ;ITEMNO:2;\r"
	notestr+="// ;ITEMNO:2;,fillpat= 5,fillfgc= (0,0,0)\r"
	notestr+="// ;ITEMNO:3;\r"
	notestr+="	SetDrawEnv save\r"
	notestr+="// ;ITEMNO:4;\r"
	notestr+="	SetDrawEnv xcoord= top,ycoord= left\r"
	notestr+="// ;ITEMNO:5;\r"
	notestr+="// ;ITEMNO:5;,linefgc= (3,52428,1)\r"
	notestr+="// ;ITEMNO:6;\r"
	notestr+="// ;ITEMNO:6;,fillpat= 5,fillfgc= (0,0,0)\r"
	notestr+="// ;ITEMNO:7;\r"
	notestr+="	SetDrawEnv save\r"
	notestr+="// ;ITEMNO:8;\r"
	notestr+="	DrawRect 85.5,16.5,86.5,17.5\r"
	notestr+="// ;ITEMNO:9;\r"
	notestr+="	DrawRect 57.5,111.5,58.5,112.5\r"

	note M_ROIMask, notestr
	
	SVAR CurrentMaskFileName = root:Packages:Convert2Dto1D:CurrentMaskFileName
	CurrentMaskFileName="9IDC default SAXS mask"
	NVAR UseMask = root:Packages:Convert2Dto1D:UseMask
	UseMask=1
	setDataFOlder OldDf
end	
//************************************************************************************************************
//************************************************************************************************************
Function NI1_9IDCCreateWAXSPixMask()			

	string OldDF=GetDataFolder(1)
	SetDataFolder root:Packages:Convert2Dto1D
	Wave/Z OriginalCCD = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(OriginalCCD))
		Abort "Load WAXS image first, then create mask again" 
	endif
	Duplicate/O OriginalCCD, M_ROIMask
	Redimension /B/U M_ROIMask 
	//Make/O/B/U/N=(195,487) M_ROIMask
	M_ROIMask =1
	if(DimSize(M_ROIMask, 1)>500)	//Pilatus 200kW
		M_ROIMask[0,194][486,494]=0
		M_ROIMask[0,1][0,980]=0
		M_ROIMask[193,194][0,980]=0
		M_ROIMask[0,194][0,1]=0
		M_ROIMask[0,194][979,980]=0
	
		string notestr="MaskOffLowIntPoints:0;LowIntToMaskOff:0>// ;ITEMNO:0;\r"
		notestr+="	SetDrawEnv xcoord= top,ycoord= left\r"
		notestr+="// ;ITEMNO:1;\r"
		notestr+="SetDrawEnv linefgc= (3,52428,1)\r"
		notestr+="// ;ITEMNO:2;\r"
		notestr+="SetDrawEnv fillpat= 5,fillfgc= (0,0,0)\r"
		notestr+="// ;ITEMNO:3;\r"
		notestr+="SetDrawEnv save\r"
		notestr+="// ;ITEMNO:4;\r"
		notestr+="DrawRect -1,485,196,495\r"	
		note M_ROIMask, notestr
	endif		
	SVAR CurrentMaskFileName = root:Packages:Convert2Dto1D:CurrentMaskFileName
	CurrentMaskFileName="9IDC default WAXS mask"
	NVAR UseMask = root:Packages:Convert2Dto1D:UseMask
	UseMask=1
	setDataFOlder OldDf
end	


//************************************************************************************************************
//************************************************************************************************************


Function NI1_9IDCSetLineWIdth()
		
		NVAR USAXSSlitLength=root:Packages:Convert2Dto1D:USAXSSlitLength
		//slit length is USAXS is distacne from center line to the end of the slit, so the totla width of this path needs to be 2*slitLength
	
		NVAR LineProf_DistanceFromCenter=root:Packages:Convert2Dto1D:LineProf_DistanceFromCenter
		NVAR LineProf_Width=root:Packages:Convert2Dto1D:LineProf_Width
		NVAR LineProf_DistanceQ=root:Packages:Convert2Dto1D:LineProf_DistanceQ
		NVAR LineProf_WidthQ=root:Packages:Convert2Dto1D:LineProf_WidthQ
		NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance		//in millimeters
		NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength							//in A
		NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY
		NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
		NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
		NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
		NVAR HorizontalTilt=root:Packages:Convert2Dto1D:HorizontalTilt
		NVAR VerticalTilt=root:Packages:Convert2Dto1D:VerticalTilt
		NVAR LineProf_UseBothHalfs=root:Packages:Convert2Dto1D:LineProf_UseBothHalfs

		variable distance, distanceW1, distancew2
		variable tempWIdth=0.1
		variable theta
		variable thetaw1
		variable thetaw2
		variable Qval
		variable Qvalw1
		variable Qvalw2
		Do
			tempWIdth+=0.05
			distancew1=NI1T_TiltedToCorrectedR(  (LineProf_DistanceFromCenter+tempWIdth)*PixelSizeX ,SampleToCCDDistance,HorizontalTilt)		//in mm 
			distancew2=NI1T_TiltedToCorrectedR(  (LineProf_DistanceFromCenter-tempWIdth)*PixelSizeX ,SampleToCCDDistance,HorizontalTilt)		//in mm 
			 thetaw1=atan(distancew1/SampleToCCDDistance)/2
			 thetaw2=atan(distancew2/SampleToCCDDistance)/2
			 Qvalw1= ((4*pi)/Wavelength)*sin(thetaw1)
			 Qvalw2= ((4*pi)/Wavelength)*sin(thetaw2)
			LineProf_WidthQ=abs(Qvalw1-Qvalw2)
		while(LineProf_WidthQ< 2*USAXSSlitLength)
		LineProf_Width = tempWIdth
	
end

//************************************************************************************************************
//************************************************************************************************************
Function NI1_9IDCWAXSBlankSUbtraction(Yes)
			variable Yes
			
				NVAR UseSampleTransmission = root:Packages:Convert2Dto1D:UseSampleTransmission
				NVAR UseEmptyField = root:Packages:Convert2Dto1D:UseEmptyField
				NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate
				NVAR DoGeometryCorrection = root:Packages:Convert2Dto1D:DoGeometryCorrection
				NVAR UseMonitorForEf = root:Packages:Convert2Dto1D:UseMonitorForEf
				NVAR UseSampleTransmFnct = root:Packages:Convert2Dto1D:UseSampleTransmFnct
				NVAR UseSampleMonitorFnct = root:Packages:Convert2Dto1D:UseSampleMonitorFnct
				NVAR UseEmptyMonitorFnct = root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
			if(Yes)	
				UseSampleTransmission = 1
				UseEmptyField = 1
				UseI0ToCalibrate = 1
				DoGeometryCorrection = 1
				UseMonitorForEf = 1
				UseSampleTransmFnct = 1
				UseSampleMonitorFnct = 1
				UseEmptyMonitorFnct = 1

				SVAR SampleTransmFnct = root:Packages:Convert2Dto1D:SampleTransmFnct
				SVAR SampleMonitorFnct = root:Packages:Convert2Dto1D:SampleMonitorFnct
				SVAR EmptyMonitorFnct = root:Packages:Convert2Dto1D:EmptyMonitorFnct
			
				SampleTransmFnct = "NI1_9IDWFindTRANS"
				SampleMonitorFnct = "NI1_9IDWFindI0"
				EmptyMonitorFnct = "NI1_9IDWFindEFI0"
			else //(NO)
				UseSampleTransmission = 0
				UseEmptyField = 0
				UseI0ToCalibrate = 1
				DoGeometryCorrection = 1
				UseMonitorForEf = 0
				UseSampleTransmFnct = 0
				UseSampleMonitorFnct = 1
				UseEmptyMonitorFnct = 0

				SVAR SampleTransmFnct = root:Packages:Convert2Dto1D:SampleTransmFnct
				SVAR SampleMonitorFnct = root:Packages:Convert2Dto1D:SampleMonitorFnct
				SVAR EmptyMonitorFnct = root:Packages:Convert2Dto1D:EmptyMonitorFnct
			
				SampleTransmFnct = "NI1_9IDWFindTRANS"
				SampleMonitorFnct = "NI1_9IDWFindI0"
				EmptyMonitorFnct = "NI1_9IDWFindEFI0"
			endif
			NI1A_SetCalibrationFormula()			

end

//************************************************************************************************************
//************************************************************************************************************
Function/S NI1_9IDCSetDefaultConfiguration()
	
	NI1A_Initialize2Dto1DConversion()
	NI1BC_InitCreateBmCntrFile()
	
	NVAR  Displ=root:Packages:Convert2Dto1D:Process_DisplayAve
	NVAR 	Proc1= root:Packages:Convert2Dto1D:Process_Individually
	NVAR 	Proc2= root:Packages:Convert2Dto1D:Process_Average
	NVAR 	Proc3 = root:Packages:Convert2Dto1D:Process_AveNFiles
	Displ = 0
	Proc1 = 1
	Proc2 = 0
	Proc3 = 0

	NVAR SAXSSelected=root:Packages:Convert2Dto1D:USAXSSAXSselector
	NVAR bigSAXSSelected=root:Packages:Convert2Dto1D:USAXSBigSAXSselector
	NVAR WAXSSelected = root:Packages:Convert2Dto1D:USAXSWAXSselector
		if(WAXSSelected)
				NVAR UseSectors = root:Packages:Convert2Dto1D:UseSectors
				UseSectors = 1
				NVAR QvectormaxNumPnts = root:Packages:Convert2Dto1D:QvectormaxNumPnts
				NVAR QBinningLogarithmic = root:Packages:Convert2Dto1D:QBinningLogarithmic
				NVAR DoCircularAverage = root:Packages:Convert2Dto1D:DoCircularAverage
				NVAR DoSectorAverages = root:Packages:Convert2Dto1D:DoSectorAverages
				NVAR NumberOfSectors = root:Packages:Convert2Dto1D:NumberOfSectors
				NVAR SectorsStartAngle = root:Packages:Convert2Dto1D:SectorsStartAngle
				NVAR SectorsHalfWidth = root:Packages:Convert2Dto1D:SectorsHalfWidth
				NVAR DisplayDataAfterProcessing = root:Packages:Convert2Dto1D:DisplayDataAfterProcessing
				NVAR StoreDataInIgor = root:Packages:Convert2Dto1D:StoreDataInIgor
				NVAR OverwriteDataIfExists = root:Packages:Convert2Dto1D:OverwriteDataIfExists
				NVAR Use2Ddataname = root:Packages:Convert2Dto1D:Use2Ddataname
				NVAR QvectorNumberPoints = root:Packages:Convert2Dto1D:QvectorNumberPoints
				NVAR FIlesSortOrder=root:Packages:Convert2Dto1D:FIlesSortOrder
				NVAR UseSolidAngle= root:Packages:Convert2Dto1D:UseSolidAngle
				NVAR UseCorrectionFactor = root:Packages:Convert2Dto1D:UseCorrectionFactor
				NVAR CorrFactor=root:Packages:Convert2Dto1D:CorrectionFactor				
				UseCorrectionFactor = 1
				//this nees to be part of calibration!!!
				//note, the 0.690699 seems correction for better sensitivity of WAXZS detector at 21keV. This will be part of calibbration formula. 
				//CorrFactor = 7.02455e-14 * 0.690699
				
				UseSolidAngle = 1
				FIlesSortOrder = 3
				QvectorNumberPoints=2*487
				QBinningLogarithmic=0
				QvectormaxNumPnts = 1
				DoSectorAverages = 0
				DoCircularAverage = 1
				NumberOfSectors = 1
				SectorsStartAngle = 270
				SectorsHalfWidth = 30
				DisplayDataAfterProcessing = 1
				StoreDataInIgor = 1
				OverwriteDataIfExists = 1
				Use2Ddataname = 1
				QvectorMaxNumPnts = 1
			
				NVAR UseLineProfile = root:Packages:Convert2Dto1D:UseLineProfile
				NVAR LineProfileUseRAW = root:Packages:Convert2Dto1D:LineProfileUseRAW
				NVAR LineProfileUseCorrData = root:Packages:Convert2Dto1D:LineProfileUseCorrData
				SVAR LineProf_CurveType=root:Packages:Convert2Dto1D:LineProf_CurveType
					
				//LineProf_CurveType="Vertical Line" 
				UseLineProfile=0
				//LineProfileUseCorrData=1
				//LineProfileUseRAW =0
			
				NVAR UseSampleTransmission = root:Packages:Convert2Dto1D:UseSampleTransmission
				NVAR UseEmptyField = root:Packages:Convert2Dto1D:UseEmptyField
				NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate
				NVAR DoGeometryCorrection = root:Packages:Convert2Dto1D:DoGeometryCorrection
				NVAR UseMonitorForEf = root:Packages:Convert2Dto1D:UseMonitorForEf
				NVAR UseSampleTransmFnct = root:Packages:Convert2Dto1D:UseSampleTransmFnct
				NVAR UseSampleMonitorFnct = root:Packages:Convert2Dto1D:UseSampleMonitorFnct
				NVAR UseEmptyMonitorFnct = root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
				NVAR UseSampleThickness = root:Packages:Convert2Dto1D:UseSampleThickness
				NVAR UseSampleThicknFnct = root:Packages:Convert2Dto1D:UseSampleThicknFnct
			
				UseSampleThickness = 1			
				UseSampleTransmission = 1
				UseEmptyField = 1
				UseI0ToCalibrate = 1
				DoGeometryCorrection = 1
				UseMonitorForEf = 1
				UseSampleTransmFnct = 1
				UseSampleMonitorFnct = 1
				UseEmptyMonitorFnct = 1
				UseSampleThicknFnct = 1 

				NVAR ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
				NVAR ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
				NVAR ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
				ErrorCalculationsUseOld=0
				ErrorCalculationsUseStdDev=0
				ErrorCalculationsUseSEM=1
				if(ErrorCalculationsUseOld)
					print "Uncertainty calculation method is set to \"Old method (see manual for description)\""
				elseif(ErrorCalculationsUseStdDev)
					print "Uncertainty calculation method is set to \"Standard deviation (see manual for description)\""
				else
					print "Uncertainty calculation method is set to \"Standard error of mean (see manual for description)\""
				endif

				SVAR SampleTransmFnct = root:Packages:Convert2Dto1D:SampleTransmFnct
				SVAR SampleMonitorFnct = root:Packages:Convert2Dto1D:SampleMonitorFnct
				SVAR EmptyMonitorFnct = root:Packages:Convert2Dto1D:EmptyMonitorFnct
				SVAR SampleThicknFnct = root:Packages:Convert2Dto1D:SampleThicknFnct
				
				SampleTransmFnct = "NI1_9IDCSFIndTransmission"
				SampleMonitorFnct = "NI1_9IDCSFindI0"
				EmptyMonitorFnct = "NI1_9IDCSFindEfI0"
				SampleThicknFnct = "NI1_9IDCSFindThickness"
			
				NVAR WAXSSubtractBlank = root:Packages:Convert2Dto1D:WAXSSubtractBlank
				NI1_9IDCWAXSBlankSUbtraction(WAXSSubtractBlank)
			
				NI1A_SetCalibrationFormula()			
				
				NVAR BMCalibrantD1LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD1LineWidth
				NVAR BMCalibrantD2LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD2LineWidth
				NVAR BMCalibrantD3LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD3LineWidth
				NVAR BMCalibrantD4LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD4LineWidth
				NVAR BMCalibrantD5LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD5LineWidth
				NVAR BMCalibrantD6LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD6LineWidth
				NVAR BMCalibrantD7LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD7LineWidth
				NVAR BMCalibrantD8LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD8LineWidth
				NVAR BMCalibrantD9LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD9LineWidth
				NVAR BMCalibrantD10LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD10LineWidth
				BMCalibrantD1LineWidth = 7
				BMCalibrantD2LineWidth = 7
				BMCalibrantD3LineWidth = 7
				BMCalibrantD4LineWidth = 7
				BMCalibrantD5LineWidth = 7
				BMCalibrantD6LineWidth = 7
				BMCalibrantD7LineWidth = 7
				BMCalibrantD8LineWidth = 7
				BMCalibrantD9LineWidth = 7
				BMCalibrantD10LineWidth = 7
			
				NVAR BMCalibrantD1=root:Packages:Convert2Dto1D:BMCalibrantD1
				NVAR BMCalibrantD2=root:Packages:Convert2Dto1D:BMCalibrantD2
				NVAR BMCalibrantD3=root:Packages:Convert2Dto1D:BMCalibrantD3
				NVAR BMCalibrantD4=root:Packages:Convert2Dto1D:BMCalibrantD4
				NVAR BMCalibrantD5=root:Packages:Convert2Dto1D:BMCalibrantD5
				NVAR BMCalibrantD6=root:Packages:Convert2Dto1D:BMCalibrantD6
				NVAR BMCalibrantD7=root:Packages:Convert2Dto1D:BMCalibrantD7
				NVAR BMCalibrantD8=root:Packages:Convert2Dto1D:BMCalibrantD8
				NVAR BMCalibrantD9=root:Packages:Convert2Dto1D:BMCalibrantD9
				NVAR BMCalibrantD10=root:Packages:Convert2Dto1D:BMCalibrantD10
				NVAR BMUseCalibrantD1=root:Packages:Convert2Dto1D:BMUseCalibrantD1
				NVAR BMUseCalibrantD2=root:Packages:Convert2Dto1D:BMUseCalibrantD2
				NVAR BMUseCalibrantD3=root:Packages:Convert2Dto1D:BMUseCalibrantD3
				NVAR BMUseCalibrantD4=root:Packages:Convert2Dto1D:BMUseCalibrantD4
				NVAR BMUseCalibrantD5=root:Packages:Convert2Dto1D:BMUseCalibrantD5
				NVAR BMUseCalibrantD6=root:Packages:Convert2Dto1D:BMUseCalibrantD6
				NVAR BMUseCalibrantD7=root:Packages:Convert2Dto1D:BMUseCalibrantD7
				NVAR BMUseCalibrantD8=root:Packages:Convert2Dto1D:BMUseCalibrantD8
				NVAR BMUseCalibrantD9=root:Packages:Convert2Dto1D:BMUseCalibrantD9
				NVAR BMUseCalibrantD10=root:Packages:Convert2Dto1D:BMUseCalibrantD10
				//this is Lab6
					BMCalibrantD1=4.15690	//[100]/rel int 60
					BMCalibrantD2=2.93937	//110 /100
					BMCalibrantD3=2.39999	//111/45
					BMCalibrantD4=2.07845	//200/23.6
					BMCalibrantD5=1.85902	//210/55
					BMCalibrantD6=1.6970539	
					BMCalibrantD7=1.4696918	
					BMCalibrantD8=1.3856387	
					BMCalibrantD9=1.3145323	
					BMCalibrantD10=1.2533574	
					BMUseCalibrantD1=1
					BMUseCalibrantD2=1
					BMUseCalibrantD3=1
					BMUseCalibrantD4=1
					BMUseCalibrantD5=1
					BMUseCalibrantD6=1
					BMUseCalibrantD7=1
					BMUseCalibrantD8=1
					BMUseCalibrantD9=1
					BMUseCalibrantD10=1
				SVAR BmCalibrantName = root:Packages:Convert2Dto1D:BmCalibrantName
				BmCalibrantName="LaB6"
				NVAR BMFitBeamCenter = root:Packages:Convert2Dto1D:BMFitBeamCenter
				NVAR BMFitSDD = root:Packages:Convert2Dto1D:BMFitSDD
				NVAR BMFitTilts = root:Packages:Convert2Dto1D:BMFitTilts
				NVAR BMCntrDisplayLogImage = root:Packages:Convert2Dto1D:BMCntrDisplayLogImage
				BMCntrDisplayLogImage = 1
				BMFitTilts=1
				BMFitSDD = 1
				BMFitBeamCenter = 1
				NVAR BMRefNumberOfSectors = root:Packages:Convert2Dto1D:BMRefNumberOfSectors
				BMRefNumberOfSectors = 360
	elseif(SAXSSelected)
				NVAR UseSectors = root:Packages:Convert2Dto1D:UseSectors
				UseSectors = 1
				NVAR QvectormaxNumPnts = root:Packages:Convert2Dto1D:QvectormaxNumPnts
				NVAR QBinningLogarithmic = root:Packages:Convert2Dto1D:QBinningLogarithmic
				NVAR DoSectorAverages = root:Packages:Convert2Dto1D:DoSectorAverages
				NVAR DoCircularAverage = root:Packages:Convert2Dto1D:DoCircularAverage
				NVAR NumberOfSectors = root:Packages:Convert2Dto1D:NumberOfSectors
				NVAR SectorsStartAngle = root:Packages:Convert2Dto1D:SectorsStartAngle
				NVAR SectorsHalfWidth = root:Packages:Convert2Dto1D:SectorsHalfWidth
				NVAR DisplayDataAfterProcessing = root:Packages:Convert2Dto1D:DisplayDataAfterProcessing
				NVAR StoreDataInIgor = root:Packages:Convert2Dto1D:StoreDataInIgor
				NVAR OverwriteDataIfExists = root:Packages:Convert2Dto1D:OverwriteDataIfExists
				NVAR Use2Ddataname = root:Packages:Convert2Dto1D:Use2Ddataname
				NVAR QvectorNumberPoints = root:Packages:Convert2Dto1D:QvectorNumberPoints
				NVAR FIlesSortOrder=root:Packages:Convert2Dto1D:FIlesSortOrder
				NVAR UseSolidAngle= root:Packages:Convert2Dto1D:UseSolidAngle
				NVAR UseCorrectionFactor = root:Packages:Convert2Dto1D:UseCorrectionFactor
				NVAR CorrFactor=root:Packages:Convert2Dto1D:CorrectionFactor				
				UseCorrectionFactor = 1
				//this nees to be part of calibration!!!
				//CorrFactor = 7.02455e-14
				
				UseSolidAngle = 1
				FIlesSortOrder = 3				
				QvectorNumberPoints=120
				QBinningLogarithmic=1
				QvectormaxNumPnts = 0
				DoSectorAverages = 1
				DoCircularAverage = 0
				NumberOfSectors = 1
				SectorsStartAngle = 270
				SectorsHalfWidth = 30
				DisplayDataAfterProcessing = 1
				StoreDataInIgor = 1
				OverwriteDataIfExists = 1
				Use2Ddataname = 1
				
				NVAR UseQvector = root:Packages:Convert2Dto1D:UseQvector
				NVAR UseDspacing = root:Packages:Convert2Dto1D:UseDspacing
				NVAR UseTheta = root:Packages:Convert2Dto1D:UseTheta
				
				UseQvector = 1
				UseDspacing = 0
				UseTheta = 0
				
				NVAR ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
				NVAR ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
				NVAR ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
				ErrorCalculationsUseOld=0
				ErrorCalculationsUseStdDev=0
				ErrorCalculationsUseSEM=1
				if(ErrorCalculationsUseOld)
					print "Uncertainty calculation method is set to \"Old method (see manual for description)\""
				elseif(ErrorCalculationsUseStdDev)
					print "Uncertainty calculation method is set to \"Standard deviation (see manual for description)\""
				else
					print "Uncertainty calculation method is set to \"Standard error of mean (see manual for description)\""
				endif
		
				NVAR UseLineProfile = root:Packages:Convert2Dto1D:UseLineProfile
				NVAR LineProfileUseRAW = root:Packages:Convert2Dto1D:LineProfileUseRAW
				NVAR LineProfileUseCorrData = root:Packages:Convert2Dto1D:LineProfileUseCorrData
				SVAR LineProf_CurveType=root:Packages:Convert2Dto1D:LineProf_CurveType
				NVAR SAXSGenSmearedPinData= root:Packages:Convert2Dto1D:SAXSGenSmearedPinData
				NVAR/Z DesmearData = root:Packages:Indra3:DesmearData
				if(NVAR_Exists(DesmearData))
					if(DesmearData)
						SAXSGenSmearedPinData =0 			//user is generating desmeared data, likely does not need smeared SAXS data
					endif
				endif
				
				if(SAXSGenSmearedPinData)
					LineProf_CurveType="Vertical Line" 
					UseLineProfile=1
					LineProfileUseCorrData=1
					LineProfileUseRAW =0
				else
					//LineProf_CurveType="Vertical Line" 
					UseLineProfile=0
					//LineProfileUseCorrData=1
					//LineProfileUseRAW =0
				endif
			
				NVAR UseSampleTransmission = root:Packages:Convert2Dto1D:UseSampleTransmission
				NVAR UseEmptyField = root:Packages:Convert2Dto1D:UseEmptyField
				NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate
				NVAR DoGeometryCorrection = root:Packages:Convert2Dto1D:DoGeometryCorrection
				NVAR UseMonitorForEf = root:Packages:Convert2Dto1D:UseMonitorForEf
				NVAR UseSampleTransmFnct = root:Packages:Convert2Dto1D:UseSampleTransmFnct
				NVAR UseSampleMonitorFnct = root:Packages:Convert2Dto1D:UseSampleMonitorFnct
				NVAR UseEmptyMonitorFnct = root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
				NVAR UseSampleThickness = root:Packages:Convert2Dto1D:UseSampleThickness
				NVAR UseSampleThicknFnct = root:Packages:Convert2Dto1D:UseSampleThicknFnct
				
	
				UseSampleThickness = 1			
				UseSampleTransmission = 1
				UseEmptyField = 1
				UseI0ToCalibrate = 1
				DoGeometryCorrection = 1
				UseMonitorForEf = 1
				UseSampleTransmFnct = 1
				UseSampleMonitorFnct = 1
				UseEmptyMonitorFnct = 1  
				UseSampleThicknFnct = 1 
				
				SVAR SampleTransmFnct = root:Packages:Convert2Dto1D:SampleTransmFnct
				SVAR SampleMonitorFnct = root:Packages:Convert2Dto1D:SampleMonitorFnct
				SVAR EmptyMonitorFnct = root:Packages:Convert2Dto1D:EmptyMonitorFnct
				SVAR SampleThicknFnct = root:Packages:Convert2Dto1D:SampleThicknFnct
				
				SampleTransmFnct = "NI1_9IDCFIndTransmission"
				SampleMonitorFnct = "NI1_9IDCFindI0"
				EmptyMonitorFnct = "NI1_9IDCFindEfI0"
				SampleThicknFnct = "NI1_9IDCFIndThickness"
			
				NI1A_SetCalibrationFormula()			
				
				NVAR BMCalibrantD1LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD1LineWidth
				NVAR BMCalibrantD2LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD2LineWidth
				NVAR BMCalibrantD3LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD3LineWidth
				NVAR BMCalibrantD4LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD4LineWidth
				NVAR BMCalibrantD5LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD5LineWidth
				NVAR BMCalibrantD6LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD6LineWidth
				NVAR BMCalibrantD7LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD7LineWidth
				NVAR BMCalibrantD8LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD8LineWidth
				NVAR BMCalibrantD9LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD9LineWidth
				NVAR BMCalibrantD10LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD10LineWidth
				BMCalibrantD1LineWidth = 7
				BMCalibrantD2LineWidth = 7
				BMCalibrantD3LineWidth = 7
				BMCalibrantD4LineWidth = 7
				BMCalibrantD5LineWidth = 7
				BMCalibrantD6LineWidth = 7
				BMCalibrantD7LineWidth = 7
				BMCalibrantD8LineWidth = 7
				BMCalibrantD9LineWidth = 7
				BMCalibrantD10LineWidth = 7
			
				NVAR BMCalibrantD1=root:Packages:Convert2Dto1D:BMCalibrantD1
				NVAR BMCalibrantD2=root:Packages:Convert2Dto1D:BMCalibrantD2
				NVAR BMCalibrantD3=root:Packages:Convert2Dto1D:BMCalibrantD3
				NVAR BMCalibrantD4=root:Packages:Convert2Dto1D:BMCalibrantD4
				NVAR BMCalibrantD5=root:Packages:Convert2Dto1D:BMCalibrantD5
				NVAR BMCalibrantD6=root:Packages:Convert2Dto1D:BMCalibrantD6
				NVAR BMCalibrantD7=root:Packages:Convert2Dto1D:BMCalibrantD7
				NVAR BMCalibrantD8=root:Packages:Convert2Dto1D:BMCalibrantD8
				NVAR BMCalibrantD9=root:Packages:Convert2Dto1D:BMCalibrantD9
				NVAR BMCalibrantD10=root:Packages:Convert2Dto1D:BMCalibrantD10
				NVAR BMUseCalibrantD1=root:Packages:Convert2Dto1D:BMUseCalibrantD1
				NVAR BMUseCalibrantD2=root:Packages:Convert2Dto1D:BMUseCalibrantD2
				NVAR BMUseCalibrantD3=root:Packages:Convert2Dto1D:BMUseCalibrantD3
				NVAR BMUseCalibrantD4=root:Packages:Convert2Dto1D:BMUseCalibrantD4
				NVAR BMUseCalibrantD5=root:Packages:Convert2Dto1D:BMUseCalibrantD5
				NVAR BMUseCalibrantD6=root:Packages:Convert2Dto1D:BMUseCalibrantD6
				NVAR BMUseCalibrantD7=root:Packages:Convert2Dto1D:BMUseCalibrantD7
				NVAR BMUseCalibrantD8=root:Packages:Convert2Dto1D:BMUseCalibrantD8
				NVAR BMUseCalibrantD9=root:Packages:Convert2Dto1D:BMUseCalibrantD9
				NVAR BMUseCalibrantD10=root:Packages:Convert2Dto1D:BMUseCalibrantD10
					//The number I use is q = 0.1076 (1/Angstrom), d = 58.380 Angstroms.  The
					//reference is T.C. Huang et al, J. Appl. Cryst. (1993), 26, 180-184.
					BMCalibrantD1=58.380
					BMCalibrantD2=29.185
					BMCalibrantD3=19.46
					BMCalibrantD4=14.595
					BMCalibrantD5=11.676	//fixed form 11.767 on 2-12-2015, typo
					BMCalibrantD6=9.73
					BMCalibrantD7=8.34
					BMCalibrantD8=7.2975
					BMCalibrantD9=6.48667
					BMCalibrantD10=5.838
					BMUseCalibrantD1=1
					BMUseCalibrantD2=1
					BMUseCalibrantD3=1
					BMUseCalibrantD4=1
					BMUseCalibrantD5=1
					BMUseCalibrantD6=1
					BMUseCalibrantD7=1
					BMUseCalibrantD8=1
					BMUseCalibrantD9=1
					BMUseCalibrantD10=1
				NVAR BMRefNumberOfSectors = root:Packages:Convert2Dto1D:BMRefNumberOfSectors
				BMRefNumberOfSectors = 360
				SVAR BmCalibrantName = root:Packages:Convert2Dto1D:BmCalibrantName
				BmCalibrantName="Ag behenate"
				NVAR BMFitBeamCenter = root:Packages:Convert2Dto1D:BMFitBeamCenter
				NVAR BMFitSDD = root:Packages:Convert2Dto1D:BMFitSDD
				NVAR BMFitTilts = root:Packages:Convert2Dto1D:BMFitTilts
				NVAR BMCntrDisplayLogImage = root:Packages:Convert2Dto1D:BMCntrDisplayLogImage
				BMFitTilts=1
				BMFitSDD = 1
				BMFitBeamCenter = 1
				BMCntrDisplayLogImage = 1
				NVAR SAXSDeleteTempPinData= root:Packages:Convert2Dto1D:SAXSDeleteTempPinData
				SAXSDeleteTempPinData = 1
	else		//end of SAXS selection, bellow starts bigSAXS specifics...
				NVAR UseSectors = root:Packages:Convert2Dto1D:UseSectors
				UseSectors = 1
				NVAR QvectormaxNumPnts = root:Packages:Convert2Dto1D:QvectormaxNumPnts
				NVAR QBinningLogarithmic = root:Packages:Convert2Dto1D:QBinningLogarithmic
				NVAR DoSectorAverages = root:Packages:Convert2Dto1D:DoSectorAverages
				NVAR NumberOfSectors = root:Packages:Convert2Dto1D:NumberOfSectors
				NVAR SectorsStartAngle = root:Packages:Convert2Dto1D:SectorsStartAngle
				NVAR SectorsHalfWidth = root:Packages:Convert2Dto1D:SectorsHalfWidth
				NVAR DisplayDataAfterProcessing = root:Packages:Convert2Dto1D:DisplayDataAfterProcessing
				NVAR StoreDataInIgor = root:Packages:Convert2Dto1D:StoreDataInIgor
				NVAR OverwriteDataIfExists = root:Packages:Convert2Dto1D:OverwriteDataIfExists
				NVAR Use2Ddataname = root:Packages:Convert2Dto1D:Use2Ddataname
				NVAR QvectorNumberPoints = root:Packages:Convert2Dto1D:QvectorNumberPoints
				NVAR DoCircularAverage = root:Packages:Convert2Dto1D:DoCircularAverage
				DoCircularAverage = 1
				QvectorNumberPoints=220
				QBinningLogarithmic=1
				QvectormaxNumPnts = 0
				DisplayDataAfterProcessing = 1
				StoreDataInIgor = 1
				OverwriteDataIfExists = 1
				Use2Ddataname = 1
			
				NVAR UseLineProfile = root:Packages:Convert2Dto1D:UseLineProfile
				NVAR LineProfileUseRAW = root:Packages:Convert2Dto1D:LineProfileUseRAW
				NVAR LineProfileUseCorrData = root:Packages:Convert2Dto1D:LineProfileUseCorrData
				SVAR LineProf_CurveType=root:Packages:Convert2Dto1D:LineProf_CurveType
					
				UseLineProfile=0
				LineProfileUseCorrData=1
				LineProfileUseRAW =0
			
				NVAR UseSampleTransmission = root:Packages:Convert2Dto1D:UseSampleTransmission
				NVAR UseEmptyField = root:Packages:Convert2Dto1D:UseEmptyField
				NVAR UseDarkField = root:Packages:Convert2Dto1D:UseDarkField
				NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate
				NVAR DoGeometryCorrection = root:Packages:Convert2Dto1D:DoGeometryCorrection
				NVAR UseMonitorForEf = root:Packages:Convert2Dto1D:UseMonitorForEf
				NVAR UseSampleTransmFnct = root:Packages:Convert2Dto1D:UseSampleTransmFnct
				NVAR UseSampleMonitorFnct = root:Packages:Convert2Dto1D:UseSampleMonitorFnct
				NVAR UseEmptyMonitorFnct = root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
				NVAR UseSampleThicknFnct = root:Packages:Convert2Dto1D:UseSampleThicknFnct
				UseSampleTransmission = 1
				UseEmptyField = 1
				UseDarkField = 1
				UseI0ToCalibrate = 1
				DoGeometryCorrection = 1
				UseMonitorForEf = 1
				UseSampleTransmFnct = 1
				UseSampleMonitorFnct = 1
				UseEmptyMonitorFnct = 1
				UseSampleThicknFnct = 1
				
				NVAR ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
				NVAR ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
				NVAR ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
				ErrorCalculationsUseOld=1
				ErrorCalculationsUseStdDev=0
				ErrorCalculationsUseSEM=0			//which one is correct here???
				if(ErrorCalculationsUseOld)
					print "Uncertainty calculation method is set to \"Old method (see manual for description)\""
				elseif(ErrorCalculationsUseStdDev)
					print "Uncertainty calculation method is set to \"Standard deviation (see manual for description)\""
				else
					print "Uncertainty calculation method is set to \"Standard error of mean (see manual for description)\""
				endif
				
				SVAR SampleTransmFnct = root:Packages:Convert2Dto1D:SampleTransmFnct
				SVAR SampleMonitorFnct = root:Packages:Convert2Dto1D:SampleMonitorFnct
				SVAR EmptyMonitorFnct = root:Packages:Convert2Dto1D:EmptyMonitorFnct
				SVAR SampleThicknFnct = root:Packages:Convert2Dto1D:SampleThicknFnct
				
				SampleTransmFnct = "NI1_9IDCSFIndTransmission"
				SampleMonitorFnct = "NI1_9IDCSFindI0"
				EmptyMonitorFnct = "NI1_9IDCSFindEfI0"
				SampleThicknFnct = "NI1_9IDCSFindThickness"
			
				NI1A_SetCalibrationFormula()
				
				NVAR BMCalibrantD1LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD1LineWidth
				NVAR BMCalibrantD2LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD2LineWidth
				NVAR BMCalibrantD3LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD3LineWidth
				NVAR BMCalibrantD4LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD4LineWidth
				NVAR BMCalibrantD5LineWidth = root:Packages:Convert2Dto1D:BMCalibrantD5LineWidth
				BMCalibrantD1LineWidth = 25
				BMCalibrantD2LineWidth = 25
				BMCalibrantD3LineWidth = 25
				BMCalibrantD4LineWidth = 25
				BMCalibrantD5LineWidth = 25
			
				NVAR BMCalibrantD1=root:Packages:Convert2Dto1D:BMCalibrantD1
				NVAR BMCalibrantD2=root:Packages:Convert2Dto1D:BMCalibrantD2
				NVAR BMCalibrantD3=root:Packages:Convert2Dto1D:BMCalibrantD3
				NVAR BMCalibrantD4=root:Packages:Convert2Dto1D:BMCalibrantD4
				NVAR BMCalibrantD5=root:Packages:Convert2Dto1D:BMCalibrantD5
				NVAR BMUseCalibrantD1=root:Packages:Convert2Dto1D:BMUseCalibrantD1
				NVAR BMUseCalibrantD2=root:Packages:Convert2Dto1D:BMUseCalibrantD2
				NVAR BMUseCalibrantD3=root:Packages:Convert2Dto1D:BMUseCalibrantD3
				NVAR BMUseCalibrantD4=root:Packages:Convert2Dto1D:BMUseCalibrantD4
				NVAR BMUseCalibrantD5=root:Packages:Convert2Dto1D:BMUseCalibrantD5
					//The number I use is q = 0.1076 (1/Angstrom), d = 58.380 Angstroms.  The
					//reference is T.C. Huang et al, J. Appl. Cryst. (1993), 26, 180-184.
					BMCalibrantD1=58.380
					BMCalibrantD2=29.185
					BMCalibrantD3=19.46
					BMCalibrantD4=14.595
					BMCalibrantD5=11.767
					BMUseCalibrantD1=1
					BMUseCalibrantD2=1
					BMUseCalibrantD3=1
					BMUseCalibrantD4=0
					BMUseCalibrantD5=0
				NVAR BMRefNumberOfSectors = root:Packages:Convert2Dto1D:BMRefNumberOfSectors
				BMRefNumberOfSectors = 120
				SVAR BmCalibrantName = root:Packages:Convert2Dto1D:BmCalibrantName
				BmCalibrantName="Ag behenate"
	endif
	//common
				SVAR BlankFileExtension=root:Packages:Convert2Dto1D:BlankFileExtension
				BlankFileExtension = "Nexus"
				//check if we are running on USAXS computers
				GetFileFOlderInfo/Q/Z "Z:USAXS_data:"
				if(V_isFolder)
					//OK, this computer has Z:USAXS_data 
					PathInfo Convert2Dto1DDataPath
					if(V_flag==0)
						NewPath/Q  Convert2Dto1DDataPath, "Z:USAXS_data:"
						pathinfo/S Convert2Dto1DDataPath
					endif
				endif
				//PathInfo/S Convert2Dto1DDataPath
				//PathInfo/S Convert2Dto1DEmptyDarkPath
				variable refnum
				Open /D/R/T=".hdf" refnum 
				if(strlen(S_FileName)<1)
					abort
				endif
				string FileName=StringFromList(ItemsInList(S_FileName,":")-1, S_FileName  , ":")
				string pathInforStrL = RemoveListItem(ItemsInList(S_FileName,":")-1, S_FileName  , ":") 
				
				//NewPath/C/O/M="Select path to your data" Convert2Dto1DDataPath
				NewPath/O Convert2Dto1DDataPath, pathInforStrL
				NewPath/O Convert2Dto1DEmptyDarkPath, pathInforStrL		
				PathInfo Convert2Dto1DEmptyDarkPath
				SVAR MainPathInfoStr=root:Packages:Convert2Dto1D:MainPathInfoStr
				MainPathInfoStr = pathInforStrL

				SVAR BmCntrFileType=root:Packages:Convert2Dto1D:BmCntrFileType
				BmCntrFileType = "Nexus"
				NewPath/O Convert2Dto1DBmCntrPath, pathInforStrL
				SVAR BCPathInfoStr=root:Packages:Convert2Dto1D:BCPathInfoStr
				PathInfo Convert2Dto1DBmCntrPath
				BCPathInfoStr=S_Path
				//mask settings
				SVAR CCDFileExtension=root:Packages:Convert2Dto1D:CCDFileExtension
				CCDFileExtension = "Nexus"
				NewPath/O Convert2Dto1DMaskPath, pathInforStrL
				if(!WAXSSelected)
					NI1M_UpdateMaskListBox()
					NVAR Usemask= root:Packages:Convert2Dto1D:Usemask
					Usemask =1 
					SVAR CurrentMaskFileName=root:Packages:Convert2Dto1D:CurrentMaskFileName
					if(strlen(CurrentMaskFileName)<1)
						print "Do NOT forget to create or load Mask"
					else	
						Print "  *********  IMPORTANT:  ********* \rFound Mask named :  >>>  "+CurrentMaskFileName+" <<<   Data reduction will use this mask. Make sure this is the correct mask to use. "
					endif
				else
					NVAR Usemask= root:Packages:Convert2Dto1D:Usemask
					Usemask =0 
				endif

	DoWIndow NI1A_Convert2Dto1DPanel
	if(!V_Flag)
		NI1A_Convert2Dto1DPanelFnct()
		NI1A_TabProc("nothing",0)
	endif
	PopupMenu SelectBlank2DDataType win=NI1A_Convert2Dto1DPanel, mode=4
	
	//these windows are stale anyway, kill them, even if they exist... 
	KilLWIndow/Z CCDImageForBmCntr
	KilLWIndow/Z NI1_CreateBmCntrFieldPanel
	
//	DoWIndow NI1_CreateBmCntrFieldPanel
//	if(V_Flag)
//		DoWindow/F NI1_CreateBmCntrFieldPanel
//		if(SAXSSelected)
//			//set to Ag Behenate
//			NI1BC_BmCntrPopMenuProc("BmCalibrantName",2,"Ag behenate")
//		elseif(WAXSSelected)
//			//set to LaB6
//			NI1BC_BmCntrPopMenuProc("BmCalibrantName",3,"LaB6")
//		endif
//		PopupMenu BmCntrFileType win=NI1_CreateBmCntrFieldPanel, mode=4
//		TabControl BmCntrTab win=NI1_CreateBmCntrFieldPanel, value=0
//		NI1BC_TabProc("BmCntrTab",0)
//	endif
	NI1BC_UpdateBmCntrListBox()	
	NI1A_UpdateDataListBox()	
	NI1A_UpdateEmptyDarkListBox()	
	print "Default methods were set"
	return FileName
end
//************************************************************************************************************
//************************************************************************************************************

Function/S NI1_9IDCFindWaveNoteValue(StringKeyName)
	string StringKeyName
	
	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Load one Image file first so the tool can read the wave note information"  
	endif
	string OldNOte=note(w2D)
	return StringByKey(NI1_9IDCFindKeyStr(StringKeyName+"=", OldNote), OldNote  , "=" , ";")
end


Function/S NI1_9IDCFindEmptyNoteValue(StringKeyName)
	string StringKeyName
	
	Wave/Z w2D = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(w2D))
		Abort "Load Empty Image file first so the tool can read the wave note information"  
	endif
	string OldNOte=note(w2D)
	return StringByKey(NI1_9IDCFindKeyStr(StringKeyName+"=", OldNote), OldNote  , "=" , ";")
end


Function/S NI1_9IDCFindDarkNoteValue(StringKeyName)
	string StringKeyName
	
	Wave/Z w2D = root:Packages:Convert2Dto1D:DarkFieldData
	if(!WaveExists(w2D))
		Abort "Load one Image file first so the tool can read the wave note information"  
	endif
	string OldNOte=note(w2D)
	return StringByKey(NI1_9IDCFindKeyStr(StringKeyName+"=", OldNote), OldNote  , "=" , ";")
end

//************************************************************************************************************
//************************************************************************************************************
Function NI1_9IDCWaveNoteValuesNx()
	
	//check for 2D wave presence, if not present throw user error with instructions
	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Load one Image file first so the tool can read the wave note information"  
	endif
	string OldNOte=note(w2D)
	SVAR Current2DFileName = root:Packages:Convert2Dto1D:FileNameToLoad
	variable beamline_support_version
	NVAR useWAXS = root:Packages:Convert2Dto1D:USAXSWAXSselector
	NVAR useSAXS = root:Packages:Convert2Dto1D:USAXSSAXSselector
	NVAR useBigSAXS = root:Packages:Convert2Dto1D:USAXSBigSAXSselector
	NVAR Wavelength= root:Packages:Convert2Dto1D:Wavelength
	NVAR XRayEnergy= root:Packages:Convert2Dto1D:XRayEnergy
	NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY
	NVAR HorizontalTilt = root:Packages:Convert2Dto1D:HorizontalTilt
	NVAR VerticalTilt = root:Packages:Convert2Dto1D:VerticalTilt
	NVAR BeamCenterX = root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY = root:Packages:Convert2Dto1D:BeamCenterY
	NVAR SampleToCCDdistance = root:Packages:Convert2Dto1D:SampleToCCDdistance
	NVAR BeamSizeX = root:Packages:Convert2Dto1D:BeamSizeX
	NVAR BeamSizeY = root:Packages:Convert2Dto1D:BeamSizeY
		
	if((stringMatch("15ID", StringByKey(NI1_9IDCFindKeyStr("facility_beamline=", OldNote), OldNOte  , "=" , ";"))||stringMatch("9ID", StringByKey(NI1_9IDCFindKeyStr("facility_beamline=", OldNote), OldNOte  , "=" , ";"))) && stringMatch("Pilatus", StringByKey(NI1_9IDCFindKeyStr("model=", OldNote), OldNOte  , "=" , ";")))	
		Wavelength = NumberByKey(NI1_9IDCFindKeyStr("monochromator:wavelength=", OldNote), OldNote  , "=" , ";")
		XRayEnergy = 12.3984/Wavelength
		if(useSAXS)
			PixelSizeX = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_pixel_size_x=", OldNote), OldNote  , "=" , ";")
			PixelSizeY = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_pixel_size_y=", OldNote), OldNote  , "=" , ";")
			if(numtype(PixelSizeX)!=0)		//old data from 15ID
				PixelSizeX = NumberByKey(NI1_9IDCFindKeyStr("x_pixel_size=", OldNote), OldNote  , "=" , ";")
				PixelSizeY = NumberByKey(NI1_9IDCFindKeyStr("y_pixel_size=", OldNote), OldNote  , "=" , ";")
			endif
			HorizontalTilt = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_tilt_x=", OldNote), OldNote  , "=" , ";")
			VerticalTilt = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_tilt_y=", OldNote), OldNote  , "=" , ";")
			BeamCenterX = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_center_x_pixel=", OldNote), OldNote  , "=" , ";")
			BeamCenterY = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_center_y_pixel=", OldNote), OldNote  , "=" , ";")
			SampleToCCDdistance = NumberByKey(NI1_9IDCFindKeyStr("distance=", OldNote), OldNote  , "=" , ";")
	 		BeamSizeX = NumberByKey(NI1_9IDCFindKeyStr("aperture:hsize=", OldNote), OldNote  , "=" , ";")
	 		BeamSizeY = NumberByKey(NI1_9IDCFindKeyStr("aperture:vsize=", OldNote), OldNote  , "=" , ";")
		elseif(useWAXS)
			PixelSizeX = NumberByKey(NI1_9IDCFindKeyStr("x_pixel_size=", OldNote), OldNote  , "=" , ";")
			PixelSizeY = NumberByKey(NI1_9IDCFindKeyStr("y_pixel_size=", OldNote), OldNote  , "=" , ";")
			HorizontalTilt = NumberByKey(NI1_9IDCFindKeyStr("waxs_ccd_tilt_x=", OldNote), OldNote  , "=" , ";")
			VerticalTilt = NumberByKey(NI1_9IDCFindKeyStr("waxs_ccd_tilt_y=", OldNote), OldNote  , "=" , ";")
			BeamCenterX = NumberByKey(NI1_9IDCFindKeyStr("waxs_ccd_center_x_pixel=", OldNote), OldNote  , "=" , ";")
			BeamCenterY = NumberByKey(NI1_9IDCFindKeyStr("waxs_ccd_center_y_pixel=", OldNote), OldNote  , "=" , ";")
			SampleToCCDdistance = NumberByKey(NI1_9IDCFindKeyStr("distance=", OldNote), OldNote  , "=" , ";")
	 		BeamSizeX = NumberByKey(NI1_9IDCFindKeyStr("aperture:hsize=", OldNote), OldNote  , "=" , ";")
	 		BeamSizeY = NumberByKey(NI1_9IDCFindKeyStr("aperture:vsize=", OldNote), OldNote  , "=" , ";")
		endif		
		print "Set experimental settinsg and geometry from file :"+Current2DFileName
		print "Wavelength = "+num2str(Wavelength)
		print "XRayEnergy = "+num2str(12.3984/Wavelength)
		print "PixelSizeX = "+num2str(PixelSizeX)
		print "PixelSizeY = "+num2str(PixelSizeY)
		print "BeamCenterX = "+num2str(BeamCenterX)
		print "BeamCenterY = "+num2str(BeamCenterY)
		print "BeamSizeX = "+num2str(BeamSizeX)
		print "BeamSizeY = "+num2str(BeamSizeY)
		print "SampleToCCDdistance = "+num2str(SampleToCCDdistance)
	elseif((stringMatch("9ID", StringByKey(NI1_9IDCFindKeyStr("facility_beamline=", OldNote), OldNOte  , "=" , ";"))) && stringMatch("XRD0820", StringByKey(NI1_9IDCFindKeyStr("model=", OldNote), OldNOte  , "=" , ";")))	
		Wavelength = NumberByKey(NI1_9IDCFindKeyStr("monochromator:wavelength=", OldNote), OldNote  , "=" , ";")
		XRayEnergy = 12.3984/Wavelength
		if(useSAXS)
			PixelSizeX = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_pixel_size_x=", OldNote), OldNote  , "=" , ";")
			PixelSizeY = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_pixel_size_y=", OldNote), OldNote  , "=" , ";")
			if(numtype(PixelSizeX)!=0)		//old data from 15ID
				PixelSizeX = NumberByKey(NI1_9IDCFindKeyStr("x_pixel_size=", OldNote), OldNote  , "=" , ";")
				PixelSizeY = NumberByKey(NI1_9IDCFindKeyStr("y_pixel_size=", OldNote), OldNote  , "=" , ";")
			endif
			HorizontalTilt = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_tilt_x=", OldNote), OldNote  , "=" , ";")
			VerticalTilt = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_tilt_y=", OldNote), OldNote  , "=" , ";")
			BeamCenterX = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_center_x_pixel=", OldNote), OldNote  , "=" , ";")
			BeamCenterY = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_center_y_pixel=", OldNote),  OldNote  , "=" , ";")
			SampleToCCDdistance = NumberByKey(NI1_9IDCFindKeyStr("distance=", OldNote), OldNote  , "=" , ";")
	 		BeamSizeX = NumberByKey(NI1_9IDCFindKeyStr("aperture:hsize=", OldNote), OldNote  , "=" , ";")
	 		BeamSizeY = NumberByKey(NI1_9IDCFindKeyStr("aperture:vsize=", OldNote), OldNote  , "=" , ";")
		elseif(useWAXS)
			PixelSizeX = NumberByKey(NI1_9IDCFindKeyStr("x_pixel_size=", OldNote), OldNote  , "=" , ";")
			PixelSizeY = NumberByKey(NI1_9IDCFindKeyStr("y_pixel_size=", OldNote), OldNote  , "=" , ";")
			HorizontalTilt = NumberByKey(NI1_9IDCFindKeyStr("waxs_ccd_tilt_x=", OldNote), OldNote  , "=" , ";")
			VerticalTilt = NumberByKey(NI1_9IDCFindKeyStr("waxs_ccd_tilt_y=", OldNote), OldNote  , "=" , ";")
			BeamCenterX = NumberByKey(NI1_9IDCFindKeyStr("waxs_ccd_center_x_pixel=", OldNote), OldNote  , "=" , ";")
			BeamCenterY = NumberByKey(NI1_9IDCFindKeyStr("waxs_ccd_center_y_pixel=", OldNote), OldNote  , "=" , ";")
			SampleToCCDdistance = NumberByKey(NI1_9IDCFindKeyStr("distance=", OldNote), OldNote  , "=" , ";")
	 		BeamSizeX = NumberByKey(NI1_9IDCFindKeyStr("aperture:hsize=", OldNote), OldNote  , "=" , ";")
	 		BeamSizeY = NumberByKey(NI1_9IDCFindKeyStr("aperture:vsize=", OldNote), OldNote  , "=" , ";")
		endif		
		print "Set experimental settinsg and geometry from file :"+Current2DFileName
		print "Wavelength = "+num2str(Wavelength)
		print "XRayEnergy = "+num2str(12.3984/Wavelength)
		print "PixelSizeX = "+num2str(PixelSizeX)
		print "PixelSizeY = "+num2str(PixelSizeY)
		print "BeamCenterX = "+num2str(BeamCenterX)
		print "BeamCenterY = "+num2str(BeamCenterY)
		print "BeamSizeX = "+num2str(BeamSizeX)
		print "BeamSizeY = "+num2str(BeamSizeY)
		print "SampleToCCDdistance = "+num2str(SampleToCCDdistance)
	elseif(stringMatch("9ID", StringByKey("instrument:source:facility_beamline", OldNOte  , "=" , ";")) && stringMatch("Pilatus", StringByKey("data:model", OldNOte  , "=" , ";")))	
		//9ID data from2015 onwards... 
		Wavelength = NumberByKey(NI1_9IDCFindKeyStr("monochromator:wavelength=", OldNote), OldNote  , "=" , ";")
		XRayEnergy = 12.3984/Wavelength
		if(useSAXS)
			PixelSizeX = NumberByKey(NI1_9IDCFindKeyStr("detector:x_pixel_size=", OldNote), OldNote  , "=" , ";")
			PixelSizeY = NumberByKey(NI1_9IDCFindKeyStr("detector:y_pixel_size=", OldNote), OldNote  , "=" , ";")
			HorizontalTilt = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_tilt_x=", OldNote), OldNote  , "=" , ";")
			VerticalTilt = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_tilt_y=", OldNote), OldNote  , "=" , ";")
			BeamCenterX = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_center_x_pixel=", OldNote), OldNote  , "=" , ";")
			BeamCenterY = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_center_y_pixel=", OldNote), OldNote  , "=" , ";")
			SampleToCCDdistance = NumberByKey(NI1_9IDCFindKeyStr("detector:distance=", OldNote), OldNote  , "=" , ";")
			BeamSizeX = NumberByKey(NI1_9IDCFindKeyStr("shape:xsize=", OldNote), OldNote  , "=" , ";")
			BeamSizeY = NumberByKey(NI1_9IDCFindKeyStr("shape:ysize=", OldNote), OldNote  , "=" , ";")
		elseif(useWAXS)
			PixelSizeX = NumberByKey(NI1_9IDCFindKeyStr("waxs_detector:x_pixel_size=", OldNote), OldNote  , "=" , ";")
			PixelSizeY = NumberByKey(NI1_9IDCFindKeyStr("waxs_detector:y_pixel_size=", OldNote), OldNote  , "=" , ";")
			HorizontalTilt = NumberByKey(NI1_9IDCFindKeyStr("waxs_ccd_tilt_x=", OldNote), OldNote  , "=" , ";")
			VerticalTilt = NumberByKey(NI1_9IDCFindKeyStr("waxs_ccd_tilt_y=", OldNote), OldNote  , "=" , ";")
			BeamCenterX = NumberByKey(NI1_9IDCFindKeyStr("waxs_ccd_center_x_pixel=", OldNote), OldNote  , "=" , ";")
			BeamCenterY = NumberByKey(NI1_9IDCFindKeyStr("waxs_ccd_center_y_pixel=", OldNote), OldNote  , "=" , ";")
			SampleToCCDdistance = NumberByKey(NI1_9IDCFindKeyStr("waxs_detector:distance=", OldNote), OldNote  , "=" , ";")
			BeamSizeX = NumberByKey(NI1_9IDCFindKeyStr("shape:xsize=", OldNote), OldNote  , "=" , ";")
			BeamSizeY = NumberByKey(NI1_9IDCFindKeyStr("shape:ysize=", OldNote), OldNote  , "=" , ";")
		endif		
		print "Set experimental settinsg and geometry from file :"+Current2DFileName
		print "Wavelength = "+num2str(Wavelength)
		print "XRayEnergy = "+num2str(12.3984/Wavelength)
		print "PixelSizeX = "+num2str(PixelSizeX)
		print "PixelSizeY = "+num2str(PixelSizeY)
		print "BeamCenterX = "+num2str(BeamCenterX)
		print "BeamCenterY = "+num2str(BeamCenterY)
		print "SampleToCCDdistance = "+num2str(SampleToCCDdistance)
		print "BeamSizeX = "+num2str(BeamSizeX)
		print "BeamSizeY = "+num2str(BeamSizeY)

	elseif(stringMatch("15ID", StringByKey("instrument:source:facility_beamline", OldNOte  , "=" , ";")) && stringMatch("CCD", StringByKey("data:model", OldNOte  , "=" , ";")))	
		//should be for useBigSAXS=1
		beamline_support_version = NumberByKey(NI1_9IDCFindKeyStr("beamline_support_version=", OldNote), OldNote  , "=" , ";")
		if(numtype(beamline_support_version)!=0)			//this applies for MarCCD support
			beamline_support_version=0
		endif
		if(beamline_support_version==0)
			Wavelength = NumberByKey(NI1_9IDCFindKeyStr("monochromator:wavelength=", OldNote), OldNote  , "=" , ";")
			XRayEnergy = 12.3984/Wavelength
			PixelSizeX = NumberByKey(NI1_9IDCFindKeyStr("detector:x_pixel_size=", OldNote), OldNote  , "=" , ";")
			PixelSizeY = NumberByKey(NI1_9IDCFindKeyStr("detector:y_pixel_size=", OldNote), OldNote  , "=" , ";")
			BeamCenterX = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_center_x_pixel=", OldNote), OldNote  , "=" , ";")
			BeamCenterY = NumberByKey(NI1_9IDCFindKeyStr("pin_ccd_center_y_pixel=", OldNote), OldNote  , "=" , ";")
			if(PixelSizeX<=0 || PixelSizeY<=0 || BeamCenterX<=0 || BeamCenterY<=0)
				DoALert 0, "Pixel sizes or beam center positions are 0, header information is bad. Please check and find correct values"
			endif
			SampleToCCDdistance = NumberByKey(NI1_9IDCFindKeyStr("detector:distance=", OldNote), OldNote  , "=" , ";")
		elseif(beamline_support_version>=1)		//latest version for now. Written when beamline_support_version=1 May 2012
			Wavelength = NumberByKey(NI1_9IDCFindKeyStr("wavelength=", OldNote), OldNote  , "=" , ";")
			XRayEnergy = 12.3984/Wavelength
			PixelSizeX = NumberByKey(NI1_9IDCFindKeyStr("instrument:detector:x_pixel_size=", OldNote), OldNote  , "=" , ";")
			PixelSizeY = NumberByKey(NI1_9IDCFindKeyStr("instrument:detector:y_pixel_size=", OldNote), OldNote  , "=" , ";")
			BeamCenterX = NumberByKey(NI1_9IDCFindKeyStr("instrument:detector:beam_center_x=", OldNote), OldNote  , "=" , ";")
			BeamCenterY = NumberByKey(NI1_9IDCFindKeyStr("instrument:detector:beam_center_y=", OldNote), OldNote  , "=" , ";")
			SampleToCCDdistance = NumberByKey(NI1_9IDCFindKeyStr("instrument:detector:distance=", OldNote), OldNote  , "=" , ";")
		endif
		print "Set experimental settinsg and geometry from file :"+Current2DFileName
		print "Wavelength = "+num2str(Wavelength)
		print "XRayEnergy = "+num2str(12.3984/Wavelength)
		print "PixelSizeX = "+num2str(PixelSizeX)
		print "PixelSizeY = "+num2str(PixelSizeY)
		print "BeamCenterX = "+num2str(BeamCenterX)
		print "BeamCenterY = "+num2str(BeamCenterY)
		print "SampleToCCDdistance = "+num2str(SampleToCCDdistance)
	else
		Abort "this is not supported data set"
	endif
	
//	print ReplaceString(";", OldNote, "\r") 

end
//************************************************************************************************************
//************************************************************************************************************

Function/T NI1_9IDCFindKeyStr(StringName, OldNote)
	string StringName, OldNote
	
	string NewKeyName=""
	NewKeyName=GrepList(OldNote, StringName,0,";")	//this will contain all terms with StringName
	//Maybe there are mroe than one...
	NewKeyName = StringFromList(0,NewKeyName,";")
	NewKeyName = StringFromList(0,NewKeyName,"=")	//and this should be key needed... 
	
	return NewKeyName
end

//************************************************************************************************************
//************************************************************************************************************
Function NI1_9IDCFIndSlitLength()
	
	string SlitLengthIsHere=IN2G_FindFolderWithWvTpsList("root:USAXS:", 10, "SMR_Int", 1)+IN2G_FindFolderWithWvTpsList("root:USAXS:", 10, "M_SMR_Int", 1)
	string SlitLengthIsHereL
	SVAR USAXSSampleName = root:Packages:Convert2Dto1D:USAXSSampleName
	USAXSSampleName = ""
	variable i
	if(ItemsInList(SlitLengthIsHere,";")>0)
		Prompt SlitLengthIsHereL, "USAXS Folders available ", popup,  SlitLengthIsHere
		DoPrompt "Pick USAXS folder where to read slit length", SlitLengthIsHereL
	else
		print "Slit smeared USAXS data NOT found, input slit length value was set to default value of 0.025. While this is common number, you shoudl reduce USAXS data and use the correct one."
		NVAR SAXSGenSmearedPinData=root:Packages:Convert2Dto1D:SAXSGenSmearedPinData
		SAXSGenSmearedPinData = 1
		return 0.025
	endif

	Wave/Z SMR_int=$(SlitLengthIsHereL+"SMR_Int")
	if(!WaveExists(SMR_int))
		Wave/Z SMR_int=$(SlitLengthIsHereL+"M_SMR_Int")
	endif
	variable SlitLengthUser=0.03
	if(WaveExists(SMR_int))
		variable SlitLength = NumberByKey("SlitLength",note(SMR_Int),"=",";")
		Print "Found SlitLength = "+num2str(SlitLength)+"      in folder : "+ SlitLengthIsHereL
		return SlitLength
	else
		NVAR SAXSGenSmearedPinData=root:Packages:Convert2Dto1D:SAXSGenSmearedPinData
		SAXSGenSmearedPinData = 1
		DoALert 0, "Slit length not found, input slit length value was set to default value of 0.025. While this is common number, you shoudl reduce USAXS data and use correct one. "
		return 0.025
	endif
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function NI1_9IDCSFIndTransmission(SampleName)
	string sampleName
	
	variable transmissionUser
	NVAR USAXSForceTransmissionDialog = root:Packages:Convert2Dto1D:USAXSForceTransmissionDialog
	NVAR USAXSForceTransRecalculation = root:Packages:Convert2Dto1D:USAXSForceTransRecalculation
	
	NVAR USAXSCheckForRIghtEmpty=root:Packages:Convert2Dto1D:USAXSCheckForRIghtEmpty
	NVAR USAXSCheckForRIghtDark=root:Packages:Convert2Dto1D:USAXSCheckForRIghtDark
	NVAR USAXSLoadListedEmpDark=root:Packages:Convert2Dto1D:USAXSLoadListedEmpDark
	NVAR useEMptyField=root:Packages:Convert2Dto1D:useEMptyField
	NVAR usedarkField=root:Packages:Convert2Dto1D:usedarkField
	
	//ideally, this is the right transmission... 
	//but we need to check that the Empty and dark are correct...
	string NoteEmptyName=NI1_9IDCFindWaveNoteValue("Empty_Filename")
	string NoteDarkName=NI1_9IDCFindWaveNoteValue("Dark_Filename")
	SVAR LoadedEmptyName = root:Packages:Convert2Dto1D:CurrentEmptyName
	SVAR LoadedDarkName=root:Packages:Convert2Dto1D:CurrentDarkFieldName
	SVAR EmptyDarknameMatchString=root:Packages:Convert2Dto1D:EmptyDarknameMatchStr
	string tempStrlSavematch
	tempStrlSavematch = EmptyDarknameMatchString
	EmptyDarknameMatchString = ""
	variable i, ii=0
	string ListOfOptions=""
	string UserEmptyFileSelection


	if(useEMptyField && USAXSCheckForRIghtEmpty && !(stringmatch(LoadedEmptyName, NoteEmptyName+"*" )))
		//dialog to load Empty...
		if(!USAXSLoadListedEmpDark)
			DoAlert /T="Wrong Empty image found" 2, "Current Empty : "+LoadedEmptyName+" does NOT match \r Blank in the image file: "+NoteEmptyName+", do you want to: \r [Yes] = select Matching image\r [No] = use current : "+LoadedEmptyName+"\r [Cancel] = cancel?"
		endif
		if(V_Flag==1 || USAXSLoadListedEmpDark)
			//here we need to load new Empty for user
			NI1A_UpdateEmptyDarkListBox()
			Wave/T ListOf2DEmptyData=root:Packages:Convert2Dto1D:ListOf2DEmptyData
			Make/T/FREE/N=0 TempStrWv
			//this build list of only matching 
			For(i=NumPnts(ListOf2DEmptyData)-1;i>=0;i-=1)
				if(stringmatch(ListOf2DEmptyData[i], "*"+NoteEmptyName+"*" ))
					redimension/N=(Numpnts(TempStrWv)+1) TempStrWv
					ii+=1
					TempStrWv[ii]= ListOf2DEmptyData[i]
				endif
			endfor  
			ListOfOptions=""
			For(i=0;i<(ii);i+=1)
				ListOfOptions+=TempStrWv[i]+";"
			endfor
			ListOfOptions+="----All files---"+";"
			For(i=0;i<NumPnts(ListOf2DEmptyData);i+=1)
				ListOfOptions+=ListOf2DEmptyData[i]+";"
			endfor
			UserEmptyFileSelection = stringFromList(0,ListOfOptions)
			if(!USAXSLoadListedEmpDark ||stringmatch(UserEmptyFileSelection,"*All files*"))
				Prompt UserEmptyFileSelection, "Select Empty file for "+SampleName, popup, ListOfOptions
				DoPrompt "SAXS select empty file (Stored name is "+NoteEmptyName+") : ", UserEmptyFileSelection
				if(V_Flag)
					abort
				endif
				print "User selected to load New Empty : "+UserEmptyFileSelection
			else
				print "Due to user settings, New Empty listed in the NX file was automatically selected : "+UserEmptyFileSelection
			endif
			For(i=0;i<numpnts(ListOf2DEmptyData);i+=1)
				if(stringmatch(ListOf2DEmptyData[i],UserEmptyFileSelection))
					Listbox  Select2DMaskDarkWave win=NI1A_Convert2Dto1DPanel, selRow=i
					break
				endif
			endfor
			NI1A_LoadEmptyOrDark("Empty")		 
		endif

	endif
	if(usedarkField && USAXSCheckForRIghtDark && !(stringmatch(LoadedDarkName, NoteDarkName+"*" )))
		//dialog to load Dark....
		if(!USAXSLoadListedEmpDark)
			DoAlert /T="Wrong Dark image found" 2, "Current Dark : "+LoadedDarkName+" does NOT match \r Dark in the image file: "+NoteDarkName+", do you want to: \r [Yes] = select Matching image\r [No] = use current : "+LoadedDarkName+"\r [Cancel] = cancel?"
		endif
		if(V_Flag==1 || USAXSLoadListedEmpDark)
			//here we need to load new Empty for user
			NI1A_UpdateEmptyDarkListBox()
			Wave/T ListOf2DEmptyData=root:Packages:Convert2Dto1D:ListOf2DEmptyData
			Make/T/FREE/N=0 TempStrWvD
			//this build list of only matching 
			For(i=NumPnts(ListOf2DEmptyData)-1;i>=0;i-=1)
				if(stringmatch(ListOf2DEmptyData[i], "*"+NoteDarkName+"*" ))
					redimension/N=(Numpnts(TempStrWvD)+1) TempStrWvD
					ii+=1
					TempStrWvD[ii]= ListOf2DEmptyData[i]
				endif
			endfor  
			ListOfOptions=""
			For(i=0;i<(numpnts(TempStrWvD));i+=1)
				ListOfOptions+=TempStrWvD[i]+";"
			endfor
			ListOfOptions+="----All files---"+";"
			For(i=0;i<NumPnts(ListOf2DEmptyData);i+=1)
				ListOfOptions+=ListOf2DEmptyData[i]+";"
			endfor
			UserEmptyFileSelection = stringFromList(0,ListOfOptions)
			if(!USAXSLoadListedEmpDark  || stringmatch(UserEmptyFileSelection,"*All files*"))
				Prompt UserEmptyFileSelection, "Select Dark file for "+SampleName, popup, ListOfOptions
				DoPrompt "SAXS select dark file (Stored name is "+NoteDarkName+") : ", UserEmptyFileSelection
				if(V_Flag)
					abort
				endif
				print "User selected to load New Dark : "+UserEmptyFileSelection
			else
				print "Due to user settings, New Dark listed in the NX file was automatically selected : "+UserEmptyFileSelection
			endif
			For(i=0;i<numpnts(ListOf2DEmptyData);i+=1)
				if(stringmatch(ListOf2DEmptyData[i],UserEmptyFileSelection))
					Listbox  Select2DMaskDarkWave win=NI1A_Convert2Dto1DPanel, selRow=i
					break
				endif
			endfor
			NI1A_LoadEmptyOrDark("Dark")		 
		endif
	endif
	
	 EmptyDarknameMatchString = tempStrlSavematch
	variable ExistingTransmissionInFile=str2num(NI1_9IDCFindWaveNoteValue("transmission"))
	variable IsTransValid=0
	if((ExistingTransmissionInFile>0)&&(ExistingTransmissionInFile<=1))
		IsTransValid = 1
	endif

	if(stringmatch(LoadedEmptyName, NoteEmptyName+"*" ) && !USAXSForceTransRecalculation && IsTransValid)
		transmissionUser=ExistingTransmissionInFile
		print "Empty name matches name in NX file, using transmission written in the NX file"
		print "Found and  using transmission = "+num2str(transmissionUser)
	else		//emty does not match
		print "Empty name DOES NOT match name in NX file OR user requested recalculating the transmission; new values calculated from Sample, Empty, and Dark data..."
		variable SampleI0
		variable SamplePD
		variable EmptyI0
		variable EmptyPD
		variable DarkI0
		variable DarkPD
		if(str2num(NI1_9IDCFindWaveNoteValue("transI0_Spl"))<1)
			 SampleI0=str2num(NI1_9IDCFindWaveNoteValue("transI0_Spl"))
			 SamplePD=str2num(NI1_9IDCFindWaveNoteValue("transNosePD_Value_Spl"))
			 EmptyI0=str2num(NI1_9IDCFindEmptyNoteValue("transI0_Empty"))
			 EmptyPD=str2num(NI1_9IDCFindEmptyNoteValue("transNosePD_Value_Empty"))
			 DarkI0=str2num(NI1_9IDCFindDarkNoteValue("transI0_Dark"))
			 DarkPD=str2num(NI1_9IDCFindDarkNoteValue("transNosePD_Value_Dark"))
		else
			 SampleI0=str2num(NI1_9IDCFindWaveNoteValue("transI0_Sample"))
			 if(SampleI0<1000)	//something wrong, old system???
				 SampleI0=str2num(NI1_9IDCFindWaveNoteValue("transBPM_B_Sample"))
				 SampleI0+=str2num(NI1_9IDCFindWaveNoteValue("transBPM_L_Sample"))
				 SampleI0+=str2num(NI1_9IDCFindWaveNoteValue("transBPM_T_Sample"))
				 SampleI0+=str2num(NI1_9IDCFindWaveNoteValue("transBPM_R_Sample"))
			 endif
			 SamplePD=str2num(NI1_9IDCFindWaveNoteValue("transPD_Sample"))
//

			 EmptyI0=str2num(NI1_9IDCFindEmptyNoteValue("transI0_Empty"))
			 if(EmptyI0<1000)	//something wrong, old system???
				 EmptyI0=str2num(NI1_9IDCFindEmptyNoteValue("transBPM_B_Empty"))
				 EmptyI0+=str2num(NI1_9IDCFindEmptyNoteValue("transBPM_L_Empty"))
				 EmptyI0+=str2num(NI1_9IDCFindEmptyNoteValue("transBPM_T_Empty"))
				 EmptyI0+=str2num(NI1_9IDCFindEmptyNoteValue("transBPM_R_Empty"))
			 endif
			 EmptyPD=str2num(NI1_9IDCFindEmptyNoteValue("transPD_Empty"))
			 DarkI0=0
			 DarkPD = 0
//			 DarkI0=str2num(NI1_9IDCFindDarkNoteValue("transI0_Sample"))
//			 if(DarkI0<10)	//something wrong, old system???
//				 DarkI0=str2num(NI1_9IDCFindDarkNoteValue("transBPM_B_Sample"))
//				 DarkI0+=str2num(NI1_9IDCFindDarkNoteValue("transBPM_L_Sample"))
//				 DarkI0+=str2num(NI1_9IDCFindDarkNoteValue("transBPM_T_Sample"))
//				 DarkI0+=str2num(NI1_9IDCFindDarkNoteValue("transBPM_R_Sample"))
//			endif
//			 DarkPD=str2num(NI1_9IDCFindDarkNoteValue("transPD_Sample"))
		endif
		transmissionUser = ((SamplePD - DarkPD)/(SampleI0-DarkI0))/((EmptyPD-DarkPD)/(EmptyI0-DarkI0))
		print "The NX file lists transmission = "+num2str(ExistingTransmissionInFile)
		print "Calculated transmission from Sam/Em/Dk NX values = "+num2str(transmissionUser)
	endif

		if(USAXSForceTransmissionDialog)
			Prompt transmissionUser, "Found transmission value of  ="
			DoPrompt "Confirm/modify SAXS transmission, need value between 0 and 1", transmissionUser
			if(V_Flag)
				abort 
			endif
		//	Print "For sample :    "+sampleName+"    user has modified transmission to be = "+num2str(transmissionUser)
		endif
		return transmissionUser
end

//************************************************************************************************************
//************************************************************************************************************

Function NI1_9IDCNXTransmission()

	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Data Image file not found "  
	endif
	string OldNOte=note(w2D)
	variable SampleI0 = NumberByKey(NI1_9IDCFindKeyStr("Pin_TrI0=", OldNote), OldNote  , "=" , ";")
	variable SampleI0gain = NumberByKey(NI1_9IDCFindKeyStr("Pin_TrI0gain=", OldNote), OldNote  , "=" , ";")
	variable SamplePinPD = NumberByKey(NI1_9IDCFindKeyStr("Pin_TrPD=", OldNote), OldNote  , "=" , ";")
	variable SampleIPinPdGain = NumberByKey(NI1_9IDCFindKeyStr("Pin_TrPDgain=", OldNote), OldNote  , "=" , ";")


	Wave/Z w2D = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(w2D))
		Abort "Empty Image file not found "  
	endif
	OldNOte=note(w2D)
	variable EmptyI0 = NumberByKey(NI1_9IDCFindKeyStr("Pin_TrI0=", OldNote), OldNote  , "=" , ";")
	variable EmptyI0gain = NumberByKey(NI1_9IDCFindKeyStr("Pin_TrI0gain=", OldNote), OldNote  , "=" , ";")
	variable EmptypinPD = NumberByKey(NI1_9IDCFindKeyStr("Pin_TrPD=", OldNote), OldNote  , "=" , ";")
	variable EmptyPinPDGain = NumberByKey(NI1_9IDCFindKeyStr("Pin_TrPDgain=", OldNote), OldNote  , "=" , ";")

	variable  Trans

	Trans = ((SamplePinPD / SampleIPinPdGain)/ (SampleI0 / SampleI0gain)) / ((EmptypinPD / EmptyPinPDGain)/(EmptyI0/ EmptyI0gain))
	if(numtype(Trans)!=0)
		Print "Transmission value was impossible to calculate from NX values from Sampe and Empty, setting to 0"
		Trans=0
	endif
	return Trans
end
//************************************************************************************************************
//************************************************************************************************************
Function NI1_9IDCFindThickness(SampleName)
	string sampleName

	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Image file not found "  
	endif
	string OldNOte=note(w2D)
	variable thickness1 = NumberByKey(NI1_9IDCFindKeyStr("sample:thickness=", OldNote), OldNote  , "=" , ";")
	variable thickness2 = NumberByKey(NI1_9IDCFindKeyStr("sample_thickness=", OldNote), OldNote  , "=" , ";")
	NVAR UseBatchProcessing=root:Packages:Convert2Dto1D:UseBatchProcessing
	if(numtype(thickness1)==0)
		if(!UseBatchProcessing)
			Print "Found thickness value in the wave note of the sample file, the value is [mm] = "+num2str(thickness1)
		endif
		return thickness1
	else
		if(numtype(thickness2)==0)
			if(!UseBatchProcessing)
				Print "Found thickness value in the wave note of the sample file, the value is [mm] = "+num2str(thickness2)
			endif
			return thickness2
		else
			if(!UseBatchProcessing)
				Print "Thickness value not found in the wave note of the sample file, setting to 1 [mm]"
			endif
			return 1
		endif
	endif
	return 0
end
//************************************************************************************************************

//************************************************************************************************************
//************************************************************************************************************
Function NI1_9IDCFindTransmission(SampleName)
	string sampleName
	
	string TransmissionIsHere=NI1_9IDCFindLikelyUSAXSName(SampleName)
	string TransmissionIsHereL
	string/g root:Packages:Convert2Dto1D:USAXSSampleName
	SVAR USAXSSampleName = root:Packages:Convert2Dto1D:USAXSSampleName
	NVAR USAXSForceTransmissionDialog = root:Packages:Convert2Dto1D:USAXSForceTransmissionDialog
	NVAR USAXSForceUSAXSTransmission = root:Packages:Convert2Dto1D:USAXSForceUSAXSTransmission

	//try to calculate the transmission using the 2012-03 pinPD placed on teh front of teh snout...
	
	variable CalcTrans = NI1_9IDCNXTransmission()
	
	if(USAXSForceUSAXSTransmission || CalcTrans==0)		//force old method and use of ONLY USAXS transmission or if CalcTrans is impossible to calculate
		USAXSSampleName = ""
		variable i
		if(ItemsInList(TransmissionIsHere,";")>1)
			Prompt TransmissionIsHereL, "Folders with similar name to "+SampleName, popup,  TransmissionIsHere
			DoPrompt "USAXS folder name not unique, please select correct one", TransmissionIsHereL
		else
			TransmissionIsHereL = stringfromlist(0,TransmissionIsHere,";")
		endif
	
		USAXSSampleName = TransmissionIsHereL
		NVAR/Z Transmission=$(TransmissionIsHereL+"Transmission")
		variable transmissionUser=1
		if(NVAR_Exists(Transmission))
			transmissionUser = Transmission
			Print "For sample :    "+sampleName+"    has been found USAXS transmission = "+num2str(Transmission)+"      in folder : "+ TransmissionIsHereL
			if(USAXSForceTransmissionDialog)
				Prompt transmissionUser, "Found transmission value of  ="
				DoPrompt "Confirm/modify USAXS transmission, need value between 0 and 1", transmissionUser
				if(V_Flag)
					abort 
				endif
				Print "For sample :    "+sampleName+"    user has modified transmission to be = "+num2str(transmissionUser)
			endif
			return transmissionUser
		else
			Prompt transmissionUser, "Transmission not found, plese input value"
			DoPrompt "USAXS transmission NOT FOUND, input value between 0 and 1", transmissionUser
				if(V_Flag)
					abort 
				endif
			Print "For sample :    "+sampleName+"    has been used manually input transmission = "+num2str(Transmission)
			return transmissionUser
		endif
	else
					//Print "For sample :   "+sampleName+" transmission = "+num2str(CalcTrans)
		return CalcTrans
	endif
end

//************************************************************************************************************
//************************************************************************************************************

Function/S NI1_9IDCFindLikelyUSAXSName(SampleName)
	string sampleName
	//12umCu_1min_1s_289.hdf5
	string LikelyUSAXSName=RemoveEnding(SampleName  , ".hdf5")
	//12umCu_1min_1s_289
	LikelyUSAXSName = RemoveListItem(ItemsInList(LikelyUSAXSName,"_")-1, LikelyUSAXSName  , "_")
	LikelyUSAXSName = LikelyUSAXSName[0,strlen(LikelyUSAXSName)-2]
	//12umCu_1min_1s
	if(stringmatch(LikelyUSAXSName[strlen(LikelyUSAXSName)-1,strlen(LikelyUSAXSName)-1],"s"))
		string tempEnding=StringFromList(ItemsInList(LikelyUSAXSName,"_")-1, LikelyUSAXSName , "_")
		if(numtype(str2num(removeEnding(tempEnding)))==0)
			LikelyUSAXSName = RemoveListItem(ItemsInList(LikelyUSAXSName,"_")-1, LikelyUSAXSName  , "_")
			LikelyUSAXSName = LikelyUSAXSName[0,strlen(LikelyUSAXSName)-2]
		endif
	endif
//	LikelyUSAXSName = RemoveListItem(ItemsInList(LikelyUSAXSName,"_")-1, LikelyUSAXSName  , "_")
//	LikelyUSAXSName = LikelyUSAXSName[0,strlen(LikelyUSAXSName)-2]
	string ListOfUFoldersWithTransmissions=IN2G_FindFolderWithWvTpsList("root:USAXS:", 10, "*SMR_Int", 1)
	//ListOfUFoldersWithTransmissions = ReplaceString(" ", ListOfUFoldersWithTransmissions, "_" )
	//	print ListOfUFoldersWithTransmissions
	string LikelyUSAXSNameMod=ReplaceString("_", LikelyUSAXSName, "." )
	string ListOfLikelyFolders=GrepList(ListOfUFoldersWithTransmissions, LikelyUSAXSNameMod,0  , ";" )

	return ListOfLikelyFolders
end
//************************************************************************************************************
//************************************************************************************************************
Function NI1_15IDWFindI0(SampleName)
	string sampleName
	abort "Please, rerun configuration to update function names"
end

Function NI1_9IDWFindI0(SampleName)
	string sampleName

	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Image file not found "  
	endif
	string OldNOte=note(w2D)
	variable I000
	I000 = NumberByKey(NI1_9IDCFindKeyStr("I0_cts_gated=", OldNote), OldNote  , "=" , ";")		//try gated signal first...
	if(numtype(I000)!=0)
		I000 = NumberByKey(NI1_9IDCFindKeyStr("I0_cts=", OldNote), OldNote  , "=" , ";")
	endif
	variable I0gain = NumberByKey(NI1_9IDCFindKeyStr("I0_gain=", OldNote), OldNote  , "=" , ";")
	I000 = I000 / I0gain
	if(numtype(I000)!=0)
		Print "I0 value not found in the wave note of the sample file, setting to 1"
		I000=1 
	endif
	return I000
end

//************************************************************************************************************
//************************************************************************************************************
Function NI1_15IDWFindTRANS(SampleName)
	string sampleName
	abort "Please, rerun configuration to update function names"
end

Function NI1_9IDWFindTRANS(SampleName)
	string sampleName

	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Image file not found "  
	endif
	Wave/Z w2DE = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(w2DE))
		Abort "Empty Image file not found "  
	endif
	string OldNOteSample=note(w2D)
	string OldNOteEmpty=note(w2DE)
	variable I000S
	I000S = NumberByKey(NI1_9IDCFindKeyStr("I0_cts_gated=", OldNOteSample), OldNOteSample  , "=" , ";")		//try gated signal first...
	if(numtype(I000S)!=0)
		I000S = NumberByKey(NI1_9IDCFindKeyStr("I0_cts=", OldNOteSample), OldNOteSample  , "=" , ";")
	endif
	variable I0gainS = NumberByKey(NI1_9IDCFindKeyStr("I0_gain=", OldNOteSample), OldNOteSample  , "=" , ";")
	I000S = I000S / I0gainS
	if(numtype(I000S)!=0)
		Print "I0 value not found in the wave note of the sample file, setting to 1"
		I000S=1 
	endif
	variable I000E
	I000E = NumberByKey(NI1_9IDCFindKeyStr("I0_cts_gated=", OldNOteEmpty), OldNOteEmpty  , "=" , ";")		//try gated signal first...
	if(numtype(I000E)!=0)
		I000E = NumberByKey(NI1_9IDCFindKeyStr("I0_cts=", OldNOteEmpty), OldNOteEmpty  , "=" , ";")
	endif
	variable I0gainE = NumberByKey(NI1_9IDCFindKeyStr("I0_gain=", OldNOteEmpty), OldNOteEmpty  , "=" , ";")
	I000E = I000E / I0gainE
	if(numtype(I000E)!=0)
		Print "I0 value not found in the wave note of the sample file, setting to 1"
		I000E=1 
	endif

	variable TRDS
	TRDS = NumberByKey(NI1_9IDCFindKeyStr("TR_cts_gated=", OldNOteSample), OldNOteSample  , "=" , ";")		//try gated signal first...
	if(numtype(TRDS)!=0)
		TRDS = NumberByKey(NI1_9IDCFindKeyStr("TR_cts=", OldNOteSample), OldNOteSample  , "=" , ";")
	endif
	variable TRDgainS = NumberByKey(NI1_9IDCFindKeyStr("TR_gain=", OldNOteSample), OldNOteSample  , "=" , ";")
	TRDS = TRDS / TRDgainS
	if(numtype(TRDS)!=0)
		Print "TR diode value not found in the wave note of the sample file, setting to 1"
		TRDS=1 
	endif
	variable TRDE
	TRDE = NumberByKey(NI1_9IDCFindKeyStr("TR_cts_gated=", OldNOteEmpty), OldNOteEmpty  , "=" , ";")		//try gated signal first...
	if(numtype(TRDE)!=0)
		TRDE = NumberByKey(NI1_9IDCFindKeyStr("TR_cts=", OldNOteEmpty), OldNOteEmpty  , "=" , ";")
	endif
	variable TRDgainE = NumberByKey(NI1_9IDCFindKeyStr("TR_gain=", OldNOteEmpty), OldNOteEmpty  , "=" , ";")
	TRDE = TRDE / TRDgainE
	if(numtype(TRDE)!=0)
		Print "I0 value not found in the wave note of the sample file, setting to 1"
		TRDE=1 
	endif


	return (TRDS/I000S)/(TRDE/I000E)
end

//************************************************************************************************************
//************************************************************************************************************
Function NI1_15IDWFindEFI0(SampleName)
	string sampleName
	abort "Please, rerun configuration to update function names"
end

Function NI1_9IDWFindEFI0(SampleName)
	string sampleName

	Wave/Z w2D = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(w2D))
		Abort "Image file not found "  
	endif
	string OldNOte=note(w2D)
	variable I000
	I000 = NumberByKey(NI1_9IDCFindKeyStr("I0_cts_gated=", OldNote), OldNote  , "=" , ";")		//try gated signal first...
	if(numtype(I000)!=0)
		I000 = NumberByKey(NI1_9IDCFindKeyStr("I0_cts=", OldNote), OldNote  , "=" , ";")
	endif
	variable I0gain = NumberByKey(NI1_9IDCFindKeyStr("I0_gain=", OldNote), OldNote  , "=" , ";")
	I000 = I000 / I0gain
	if(numtype(I000)!=0)
		Print "I0 value not found in the wave note of the sample file, setting to 1"
		I000=1 
	endif
	return I000
end
//************************************************************************************************************
//************************************************************************************************************
Function NI1_9IDCFindI0(SampleName)
	string sampleName

	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Image file not found "  
	endif
	string OldNOte=note(w2D)
	variable I000 = NumberByKey(NI1_9IDCFindKeyStr("I0_cts_gated=", OldNote), OldNote  , "=" , ";")
	variable I0gain = NumberByKey(NI1_9IDCFindKeyStr("I0_gain=", OldNote), OldNote  , "=" , ";")
	//print SampleName+"   normalized I0 = "+num2str(I000 / I0gain)
	I000 = I000 / I0gain
	if(numtype(I000)!=0)
		Print "I0 value not found in the wave note of the sample file, setting to 1"
		I000=1 
	endif
	return I000
end
//************************************************************************************************************
//************************************************************************************************************
Function NI1_9IDCSFindI0(SampleName)
	string sampleName

	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Image file not found "  
	endif
	string OldNOte=note(w2D)
	variable I000 = NumberByKey(NI1_9IDCFindKeyStr("I0_Sample=", OldNote), OldNote  , "=" , ";")
	if(numtype(I000)!=0 || I000<1)
		I000 = NumberByKey(NI1_9IDCFindKeyStr("BPM_B_Sample=", OldNote), OldNote  , "=" , ";")
		I000 += NumberByKey(NI1_9IDCFindKeyStr("BPM_T_Sample=", OldNote), OldNote  , "=" , ";")
		I000 += NumberByKey(NI1_9IDCFindKeyStr("BPM_L_Sample=", OldNote), OldNote  , "=" , ";")
		I000 += NumberByKey(NI1_9IDCFindKeyStr("BPM_R_Sample=", OldNote), OldNote  , "=" , ";")
	endif
	if(numtype(I000)!=0)
		Print "I0 value not found in the wave note of the sample file, setting to 1"
		I000=1 
	endif
	return I000
end
//************************************************************************************************************
//************************************************************************************************************
Function NI1_9IDCSFindThickness(SampleName)
	string sampleName

	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Image file not found "  
	endif
	string OldNOte=note(w2D)
	variable thickness1 = NumberByKey(NI1_9IDCFindKeyStr("sample:thickness=", OldNote), OldNote  , "=" , ";")
	variable thickness2 = NumberByKey(NI1_9IDCFindKeyStr("sample_thickness=", OldNote), OldNote  , "=" , ";")
	NVAR UseBatchProcessing=root:Packages:Convert2Dto1D:UseBatchProcessing
	if(numtype(thickness1)==0)
		if(!UseBatchProcessing)
			Print "Found thickness value in the wave note of the sample file, the value is [mm] = "+num2str(thickness1)
		endif
		return thickness1
	else
		if(numtype(thickness2)==0)
			if(!UseBatchProcessing)
				Print "Found thickness value in the wave note of the sample file, the value is [mm] = "+num2str(thickness2)
			endif
			return thickness2
		else
			if(!UseBatchProcessing)
				Print "Thickness value not found in the wave note of the sample file, setting to 1 [mm]"
			endif
			return 1
		endif
	endif
	return 0
end
//************************************************************************************************************
//************************************************************************************************************
Function NI1_9IDCSFindEfI0(SampleName)
	string sampleName

	Wave/Z w2D = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(w2D))
		Abort "Image file not found "  
	endif
	string OldNOte=note(w2D)
	variable I000 = NumberByKey(NI1_9IDCFindKeyStr("I0_Sample=", OldNote), OldNote  , "=" , ";")
	if(numtype(I000)!=0 || I000<1)
		I000 = NumberByKey(NI1_9IDCFindKeyStr("BPM_B_Sample=", OldNote), OldNote  , "=" , ";")
		I000 += NumberByKey(NI1_9IDCFindKeyStr("BPM_T_Sample=", OldNote), OldNote  , "=" , ";")
		I000 += NumberByKey(NI1_9IDCFindKeyStr("BPM_L_Sample=", OldNote), OldNote  , "=" , ";")
		I000 += NumberByKey(NI1_9IDCFindKeyStr("BPM_R_Sample=", OldNote), OldNote  , "=" , ";")
	endif
	if(numtype(I000)!=0)
		Print "I0 value not found in the wave note of the sample file, setting to 1"
		I000=1 
	endif
	return I000
end

//************************************************************************************************************
//************************************************************************************************************
Function NI1_9IDCFindEfI0(SampleName)
	string sampleName
	
	//check the empty file name...
	//this is 2D empty file name
	string LikelyUSAXSName=NI1_9IDCFindLikelyUSAXSName(SampleName)
	SVAR USAXSSampleName = root:Packages:Convert2Dto1D:USAXSSampleName
	NVAR USAXSForceUSAXSTransmission = root:Packages:Convert2Dto1D:USAXSForceUSAXSTransmission
	string SampleLocationL=""
	if(USAXSForceUSAXSTransmission)
		if(ItemsInList(LikelyUSAXSName,";")>1 &&strlen(USAXSSampleName)>1 )
			LikelyUSAXSName = USAXSSampleName
		elseif(ItemsInList(LikelyUSAXSName,";")>1 &&strlen(USAXSSampleName)<1)
			Prompt SampleLocationL, "Folders with similar name to "+SampleName, popup,  LikelyUSAXSName
			DoPrompt "USAXS folder name not unique, select correct one", SampleLocationL
			if(V_Flag)
				abort
			endif
			LikelyUSAXSName = SampleLocationL
		endif
		Wave/Z SMR_Int=$(removeending(LikelyUSAXSName,";")+"SMR_Int")
		if(!WaveExists(SMR_Int))
				Wave/Z SMR_Int=$(removeending(LikelyUSAXSName,";")+"M_SMR_Int")
		endif
		string USAXSUsedBlankName
		if(WaveExists(SMR_Int))
			USAXSUsedBlankName=StringByKey("BlankComment", note(SMR_Int) , "="  , ";")
			USAXSUsedBlankName=ReplaceString(" ", USAXSUsedBlankName, "_")
		else
			USAXSUsedBlankName=""
		endif
		SVAR CurrentEmptyName = root:Packages:Convert2Dto1D:CurrentEmptyName
		string tempStr=RemoveEnding(CurrentEmptyName , ".hdf5")
		tempStr =  tempStr[0,strsearch(tempStr, "_", inf ,1)-1]
		if((strlen(CurrentEmptyName)<1)||((USAXSForceUSAXSTransmission==1) && (stringmatch(USAXSUsedBlankName, "*"+tempStr+"*" ))!=1))
			DoAlert /T="Wrong Empty data set found" 2, "SAXS Empty : "+CurrentEmptyName+" does NOT match \rUSAXS Blank : "+USAXSUsedBlankName+", do you want to: \r [Yes] = select USAXS Matching image\r [No] = use current : "+CurrentEmptyName+"\r [Cancel] = cancel?"
			if(V_Flag==1)
				//here we need to load new Empty for user
				//existing data files, need to match them for the CurrentEmptyName
				string tempStr2=ReplaceString(" ", CurrentEmptyName, "_")
				NI1A_UpdateEmptyDarkListBox()
				Wave/T ListOf2DEmptyData=root:Packages:Convert2Dto1D:ListOf2DEmptyData
				Make/T/FREE/N=0 TempStrWv
				variable i, ii=0
				//this build list of only matching 
				For(i=NumPnts(ListOf2DEmptyData)-1;i>=0;i-=1)
					if(stringmatch(ListOf2DEmptyData[i], "*"+USAXSUsedBlankName+"*" ))
						redimension/N=(Numpnts(TempStrWv)+1) TempStrWv
						ii+=1
						TempStrWv[ii]= ListOf2DEmptyData[i]
					endif
				endfor  
				string ListOfOptions=""
				For(i=0;i<(ii);i+=1)
					ListOfOptions+=TempStrWv[i]+";"
				endfor
				ListOfOptions+="----All files---"+";"
				For(i=0;i<NumPnts(ListOf2DEmptyData);i+=1)
					ListOfOptions+=ListOf2DEmptyData[i]+";"
				endfor
				string UserEmptyFileSelection
				UserEmptyFileSelection = stringFromList(0,ListOfOptions)
				Prompt UserEmptyFileSelection, "Select Empty file for "+SampleName, popup, ListOfOptions
				DoPrompt "SAXS select empty file (USAXS name is "+USAXSUsedBlankName+") : ", UserEmptyFileSelection
				if(V_Flag)
					abort
				endif
				print "User selected to load New Empty : "+UserEmptyFileSelection
				For(i=0;i<numpnts(ListOf2DEmptyData);i+=1)
					if(stringmatch(ListOf2DEmptyData[i],UserEmptyFileSelection))
						Listbox  Select2DMaskDarkWave win=NI1A_Convert2Dto1DPanel, selRow=i
						break
						//controlInfo /W=NI1A_Convert2Dto1DPanel Select2DMaskDarkWave
					endif
				endfor
				NI1A_LoadEmptyOrDark("Empty")		 
			elseif(V_Flag==3)
				abort 
			else
				Print "User selected to use different Empty 2D data set than Blank measurement used for USAXS. "
			endif 
		endif
	endif
	Wave/Z w2D = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(w2D))
		Abort "Load one Image file first so the tool can read the wave note information"  
	endif
	string OldNOte=note(w2D)
	variable I000 = NumberByKey(NI1_9IDCFindKeyStr("I0_cts_gated=", OldNote), OldNote  , "=" , ";")
	variable I0gain = NumberByKey(NI1_9IDCFindKeyStr("I0_gain=", OldNote), OldNote  , "=" , ";")
	I000 = I000 / I0gain
	//print SampleName+" EMPTY  normalized I0 = "+num2str(I000)
	if(numtype(I000)!=0)
		Print "I0 value not found in the wave note of the empty file, setting to 1"
		I000=1 
	endif
	return I000
end

//************************************************************************************************************
//************************************************************************************************************


Function NI1_9IDCCreateHelpNbk()
	String nb = "Instructions_9IDC"
	DoWIndow Instructions_9IDC
	if(V_Flag)
		DoWindow/F Instructions_9IDC
	else
		NewNotebook/N=$nb/F=1/V=1/K=1/ENCG={2,1}/W=(260,162,1291,937)
		Notebook $nb defaultTab=36
		Notebook $nb showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
		Notebook $nb newRuler=Title, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",12,3,(0,0,0)}
		Notebook $nb ruler=Title, text="Instructions for use of 9IDC (9IDC) special configurations\r"
		Notebook $nb ruler=Normal, text="\r"
		Notebook $nb text="Decide which data you need to reduce. Instructions are geometry specific:\r"
		Notebook $nb text="\r"
		Notebook $nb ruler=Title, text="SAXS \r"
		Notebook $nb ruler=Normal
		Notebook $nb text="You may be helped by first reducing your USAXS data, but it is not totally"
		Notebook $nb text=" necessary.\r"
		Notebook $nb text="1.\tSelect \"SAXS\" checkbox. Check or keep checked checkbox \"Read Parameters from files\" \r"
		Notebook $nb text="\r"
		Notebook $nb text="2.\tPush \"Set default settings\" button to locate one representative 2D image (.hdf) file inside the data "
		Notebook $nb text="folder you want to process. This will also configure Nika settings common to all SAXS data processing. I"
		Notebook $nb text="mage will open and geometry/calibration parameters - e.g., distance/wavelength/center... will be loaded"
		Notebook $nb text=". \r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="3. default: \t", fStyle=-1
		Notebook $nb text="Check or keep checked the checkbox \"Read Parameters from files\" and this will re-read geometry/calibrati"
		Notebook $nb text="on parameters when each image file is loaded. Continue to step 4. \r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=2, text="3. alternative: \t", fStyle=-1
		Notebook $nb text="If for some reason you do NOT want to re-read geometry/calibration parameters for each file, uncheck the"
		Notebook $nb text=" checkbox \"Read Parameters from files\" and use button \"Read geometry from wave note\" button to read"
		Notebook $nb text="values from the wavenote of the loaded file. Verify the parameters (Beam center & calibration) using Ag Behe"
		Notebook $nb text="nate measurements collected with your data & your notes (some NX file info could be stale). Modify if ne"
		Notebook $nb text="eded, these will be retained until YOU change them. This alternative procedure is also necessary "
		Notebook $nb text="for data from before ~2015 as they are not suported by default code. \r"
		Notebook $nb text="\r"
		Notebook $nb text="4. \tUse button \"Set Slit length\" to locate appropriate USAXS data and read the slit length from them. Or"
		Notebook $nb text=" set manually - needed ONLY if you did not desmear the USAXS data (and you therefore have slit smeared USAXS data) "
		Notebook $nb text=" and if checkbox \"Create Smeared Data\" IS checked.  Then use SAXS data with _u at the end of folder name to mer"
		Notebook $nb text="ge later with USAXS SMR data. \r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=2, text="4. alternative ", fStyle=-1
		Notebook $nb text="\tIf you desmeared USAXS data uncheck the checkboxs \"Create Smeared Data\" and ignore the Slit length controls."
		Notebook $nb text=" Use SAXS data with _270_30 in the end of folder name and merge these with DSM USAXS data. \r"
		Notebook $nb text="\r"
//		Notebook $nb text="5. \tCreate mask to mask off the top few lines on detector using button: \"Create SAXS/WAXS mask\"\r"
		Notebook $nb text="5. \tLocate the appropriate \"Empty\" (aka: Blank) image file you want to use and load it in Nika in \"Emp/D"
		Notebook $nb text="k\" tab. ", fStyle=6
		Notebook $nb text="Keep in mind that for each data set you may need different Empty/Blank image - and it is your job to kno"
		Notebook $nb text="w which empty/dark belongs to which data image.  \r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=-1, text="6. \tTo process data select one or more image data in the Listbox in the Nika main panel and push button \""
		Notebook $nb fStyle=3, text="Convert sel. files 1 at time", fStyle=-1, text="\"\r"
		Notebook $nb text="\r"
		Notebook $nb text="\r"
		Notebook $nb text="\r"
		Notebook $nb ruler=Title, text="WAXS\r"
		Notebook $nb ruler=Normal, text="1.\tSelect \"WAXS\" checkbox. Check or keep checked the checkbox \"Read Parameters from files\".\r"
		Notebook $nb text="\r"
		Notebook $nb text="2.\tPush \"Set default settings\" button to locate one representative 2D image (.hdf) file inside the data "
		Notebook $nb text="folder you want to process. This will also configure Nika settings common to all WAXS data processing. I"
		Notebook $nb text="mage will open and geometry/calibration parameters - e.g., distance/.wavelength/center... will be loaded"
		Notebook $nb text=".  \r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="3. default: \t", fStyle=-1
		Notebook $nb text="Check or keep checked the checkbox \"Read Parameters from files\" and this will re-read geometry/calibrati"
		Notebook $nb text="on parameters when each image file is loaded. Continue to step 4. \r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=2, text="3. alternative: \t", fStyle=-1
		Notebook $nb text="If for some reason you do NOT want to re-read geometry/calibration parameters for each file, uncheck the"
		Notebook $nb text=" checkbox \"Read Parameters from files\" and use button \"Read geometry from wave note\" button to read"
		Notebook $nb text=" values from the wavenote of this file. Verify the parameters (Beam center & calibration) using LaB6 me"
		Notebook $nb text="asurements collected with your data & your notes (some NX file info could be stale). Modify if needed, t"
		Notebook $nb text="hese will be retained now until YOU change them. This is also necessary step for data from before ~2015"
		Notebook $nb text=" as these are not suported by new code. \r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=2, text="4. rare alternative \t", fStyle=-1
		Notebook $nb text="If you do NOT have Empty (aka: blank) measurement - it is standard at the instrument to collect them you can disbale blank subtraction."
		Notebook $nb text="In that case push \"WAXS Do NOT use Blank\". In this case you do NOT have to load Blank in the \"Empty/Dk\" tab and air scattering will NOT be subtracted with proper normalization.\r"
		Notebook $nb text="\r"
		Notebook $nb text="5. \tTo process data select one or more image data in the main panel and push button \"", fStyle=3
		Notebook $nb text="Convert sel. files 1 at time", fStyle=-1, text="\"\r"
		Notebook $nb text="\r"
		Notebook $nb text="\r"
		Notebook $nb ruler=Title, text="SAXS\r"
		Notebook $nb ruler=Normal, text="1.\tSelect \"15ID SAXS\" checkbox.\r"
		Notebook $nb text="2.\tPush \"Set default methods\" button to locate data folder and configure Nika settings common to all SAX"
		Notebook $nb text="S experiments.\r"
		Notebook $nb text="3.\tSelect one of the images from your SAXS measurements in the main 2D panel and double click it (or use"
		Notebook $nb text=" button \"Ave & Display sel. file(s)\") to load \r"
		Notebook $nb text="3. \tUse \"Set Experiment Settings\"  button to read & set values from the wavenote of this file (These are"
		Notebook $nb text=" the most likely values for your experiment)\r"
		Notebook $nb text="4. \tConfigure Empty and Dark images, generate Mask as needed. Likely you will need first to reduce the G"
		Notebook $nb text="lassy Carbon sample, compare it with the standard data and create calibration constant. There is movie o"
		Notebook $nb text="n this on the YouTube channel or USAXS web site.   "
		Notebook $nb selection={startOfFile, startOfFile }, findText={"I",1}
	endif
	AutopositionWindow/M=1/r=NI1_9IDCConfigPanel  Instructions_9IDC
end

//************************************************************************************************************
//************************************************************************************************************

//Function NI1_9IDCCreateWvNtNbk(SampleName)
//	String SampleName
//	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
//	if(!WaveExists(w2D))		//hm, are we laoding the empty?
//		Wave/Z w2D = root:Packages:Convert2Dto1D:EmptyData
//	endif
//	if(WaveExists(w2d))
//		string OldNOte=note(w2D)
//		
//		string Instrument = StringByKey(NI1_9IDCFindKeyStr("instrument:name=", OldNote), OldNOte  , "=" , ";")		//USAXS
//		string Facility = StringByKey(NI1_9IDCFindKeyStr("facility_beamline=", OldNote), OldNOte  , "=" , ";")
//		variable i
//		String nb 	
//	//	if((stringMatch("15ID", )||stringMatch("9ID", StringByKey(NI1_9IDCFindKeyStr("facility_beamline=", OldNote), OldNOte  , "=" , ";"))) && stringMatch("Pilatus", StringByKey(NI1_9IDCFindKeyStr("model=", OldNote), OldNOte  , "=" , ";")))	
//		if((stringMatch("15ID",Facility )||stringMatch("9ID",Facility )) && (stringMatch("USAXS", Instrument) || stringMatch("15ID SAXS", Instrument)))	
//				 nb = "Sample_Information"
//				DoWindow Sample_Information
//				if(V_Flag)
//					DoWindow /K Sample_Information
//				endif
//				NewNotebook/N=$nb/F=1/V=1/K=1/W=(700,10,1100,700)
//				Notebook $nb defaultTab=36, statusWidth=252
//				Notebook $nb showRuler=1, rulerUnits=1, updating={1, 60}
//				Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
//				Notebook $nb newRuler=Title, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",12,3,(0,0,0)}
//				Notebook $nb ruler=Title, text="Header information for "+SampleName+"\r"
//				Notebook $nb ruler=Normal, text="\r"
//				For(i=0;i<ItemsInList(OldNOte,";");i+=1)
//						Notebook $nb text=stringFromList(i,OldNOte,";")+ " \r"
//				endfor
//				Notebook $nb selection={startOfFile,startOfFile}
//				Notebook $nb text=""
//		endif
//	else
//				 nb = "Sample_Information"
//				DoWindow Sample_Information
//				if(V_Flag)
//					DoWindow /K Sample_Information
//				endif
//				NewNotebook/N=$nb/F=1/V=1/K=1/W=(700,10,1100,700)
//				Notebook $nb defaultTab=36, statusWidth=252
//				Notebook $nb showRuler=1, rulerUnits=1, updating={1, 60}
//				Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
//				Notebook $nb newRuler=Title, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",12,3,(0,0,0)}
//				Notebook $nb ruler=Title, text="No information found for this file \r"	
//	endif	
//	
////	AutopositionWindow/M=0/R=CCDImageToConvertFig Sample_Information
////	print ReplaceString(";", OldNote, "\r") 
//
//
//end
//

//************************************************************************************************************
//************************************************************************************************************


Function NI1_9IDCCreateSMRSAXSdata(listOfOrientations)	
		string listOfOrientations
	
		//print listOfOrientations
		//continue ONLY if these were created:
		 //270_10;VLp_0;
		string OldDf=getDataFOlder(1)
		//see what these do: NI1A_SaveDataPerUserReq(tempStr1+tempStr)
		NVAR/Z SAXSSelected=root:Packages:Convert2Dto1D:USAXSSAXSselector
		if(!NVAR_Exists(SAXSSelected) || !SAXSSelected)
			return 0
		endif
		
		NVAR/Z USAXSSlitLength = root:Packages:Convert2Dto1D:USAXSSlitLength
		NVAR/Z SAXSGenSmearedPinData= root:Packages:Convert2Dto1D:SAXSGenSmearedPinData
		NVAR/Z  SAXSDeleteTempPinData= root:Packages:Convert2Dto1D:SAXSDeleteTempPinData
		if(!NVAR_Exists(USAXSSlitLength)||!NVAR_Exists(SAXSGenSmearedPinData)||!NVAR_Exists(SAXSDeleteTempPinData))
			return 0
		endif
		if(!SAXSGenSmearedPinData)
			return 0
		endif
		if(SAXSGenSmearedPinData && (!(GrepString(listOfOrientations,"270_30")||GrepString(listOfOrientations,"270_10"))||!GrepString(listOfOrientations,"VLp_0")))
			Print "Could not create requested slit smeared SAXS data since the right sector and line profiles are not available"
			return 0
		endif 
		if(USAXSSlitLength<0.001)	//slit length not set, force user to find it...
			NI1_9IDCFIndSlitLength()
		endif
	
	NVAR Use2DdataName=root:Packages:Convert2Dto1D:Use2DdataName
	SVAR LoadedFile=root:Packages:Convert2Dto1D:FileNameToLoad
	SVAR UserFileName=root:Packages:Convert2Dto1D:OutputDataName
	SVAR TempOutputDataname=root:Packages:Convert2Dto1D:TempOutputDataname
	SVAR TempOutputDatanameUserFor=root:Packages:Convert2Dto1D:TempOutputDatanameUserFor
	SVAR UserSampleNameGlobal=root:Packages:Convert2Dto1D:UserSampleName
	string useName, LocalUserFileName
	string CurOrient
	//our secotr...
	if(GrepString(listOfOrientations,"270_30"))
		CurOrient="270_30"
	else
		CurOrient="270_10"				//old setting
	endif
	if (Use2DdataName)
		//variable tempEnd=26-strlen(CurOrient)
		//UseName=LoadedFile[0,tempEnd]+"_"+CurOrient
		UseName=NI1A_TrimCleanDataName(UserSampleNameGlobal, CurOrient)+"_"+CurOrient
		
	elseif(strlen(UserFileName)<1)	//user did not set the file name
		if(cmpstr(TempOutputDatanameUserFor,UserSampleNameGlobal)==0 && strlen(TempOutputDataname)>0)		//this file output was already asked for user
				LocalUserFileName = TempOutputDataname
		else
				abort "could not figure out the names"	
		endif
		UseName=NI1A_TrimCleanDataName(LocalUserFileName, CurOrient)+"_"+CurOrient
	else
		UseName=NI1A_TrimCleanDataName(UserFileName, CurOrient)+"_"+CurOrient
	endif
	//UseName=cleanupName(UseName, 1 )
	String PinFolder="root:SAXS:"+possiblyQuoteName(UseName)
	String PinWaveNames=(UseName)

	CurOrient="VLp_0"
	if (Use2DdataName)
		//tempEnd=26-strlen(CurOrient)
		//UseName=LoadedFile[0,tempEnd]+"_"+CurOrient
		UseName=NI1A_TrimCleanDataName(UserSampleNameGlobal, CurOrient)+"_"+CurOrient
	elseif(strlen(UserFileName)<1)	//user did not set the file name
		if(cmpstr(TempOutputDatanameUserFor,LoadedFile)==0 && strlen(TempOutputDataname)>0)		//this file output was already asked for user
				LocalUserFileName = TempOutputDataname
		else
				abort  "could not figure out the names"	
		endif
		//UseName=LocalUserFileName[0,18]+"_"+CurOrient
		UseName=NI1A_TrimCleanDataName(LocalUserFileName, CurOrient)+"_"+CurOrient
	else
		//UseName=UserFileName[0,18]+"_"+CurOrient
		UseName=NI1A_TrimCleanDataName(UserFileName, CurOrient)+"_"+CurOrient
	endif
	//UseName=cleanupName(UseName, 1 )
	String LIneProfFolder="root:SAXS:"+possiblyQuoteName(UseName)
	String LineProfWaveNames=(UseName)

	CurOrient="u"
	if (Use2DdataName)
		//tempEnd=26-strlen(CurOrient)
		//UseName=LoadedFile[0,tempEnd]+"_"+CurOrient
		UseName=NI1A_TrimCleanDataName(UserSampleNameGlobal, CurOrient)+"_"+CurOrient
	elseif(strlen(UserFileName)<1)	//user did nto set the file name
		if(cmpstr(TempOutputDatanameUserFor,LoadedFile)==0 && strlen(TempOutputDataname)>0)		//this file output was already asked for user
				LocalUserFileName = TempOutputDataname
		else
				abort  "could not figure out the names"	
		endif
		//UseName=LocalUserFileName[0,18]+"_"+CurOrient
		UseName=NI1A_TrimCleanDataName(LocalUserFileName, CurOrient)+"_"+CurOrient
	else
		//UseName=UserFileName[0,18]+"_"+CurOrient
		UseName=NI1A_TrimCleanDataName(UserFileName, CurOrient)+"_"+CurOrient
	endif
	UseName=cleanupName(UseName, 1 )
	String SmearedFolder="root:SAXS:"+possiblyQuoteName(UseName)
	String SmWaveNames=(UseName)


	//print PinFolder+":"+possiblyQuoteName("q_"+PinWaveNames)
	//print LineProfFolder+":"+possiblyQuoteName("q_"+LineProfWaveNames)
	//print SmearedFolder+":"+possiblyQuoteName("q_"+SmWaveNames)
	//link to existing waves now...
	Wave LineProfQ= $(LineProfFolder+":"+possiblyQuoteName("q_"+LineProfWaveNames))
	Wave LineProfr= $(LineProfFolder+":"+possiblyQuoteName("r_"+LineProfWaveNames))
	Wave LineProfs= $(LineProfFolder+":"+possiblyQuoteName("s_"+LineProfWaveNames))
	Wave/Z LineProfw= $(LineProfFolder+":"+possiblyQuoteName("w_"+LineProfWaveNames))
	if(!WaveExists(LineProfw))
		Duplicate/Free LineProfQ, LineProfw
		LineProfw[p]=(LineProfQ[p+1]-LineProfQ[p-1])/2
		LineProfw[0]=LineProfQ[1]-LineProfQ[0]
	endif

	Wave/Z PinProfq= $(PinFolder+":"+possiblyQuoteName("q_"+PinWaveNames))
	if(!WaveExists(PinProfq))	//something is worng here...
		print "Cannot create smeared data" 
		return 0
	endif
	Wave PinProfr= $(PinFolder+":"+possiblyQuoteName("r_"+PinWaveNames))
	Wave PinProfs= $(PinFolder+":"+possiblyQuoteName("s_"+PinWaveNames))
	Wave PinProfw= $(PinFolder+":"+possiblyQuoteName("w_"+PinWaveNames))

	//make new data folder
	NewDataFolder/O/S $(SmearedFolder)	
	variable LineProfLen, PinProfLen
	
	 findlevel/P/Q LineProfQ, (6*USAXSSlitLength)
	 LineProflen =round(V_LevelX)
	 findlevel/P/Q PinProfq, (6*USAXSSlitLength)
	 PinProfLen = round(V_LevelX)
	
	Make/O/N=(1) $("q_"+SmWaveNames),$("r_"+SmWaveNames),$("s_"+SmWaveNames),$("w_"+SmWaveNames)
	
	Duplicate/Free/R=[0,LineProflen-1] LineProfQ, tempLineProfQ
	Duplicate/Free/R=[PinProfLen,inf] PinProfq, tempPinProfq
	Duplicate/Free/R=[0,LineProflen-1] LineProfr, tempLineProfr
	Duplicate/Free/R=[PinProfLen,inf] PinProfr, tempPinProfr
	Duplicate/Free/R=[0,LineProflen-1] LineProfs, tempLineProfs
	Duplicate/Free/R=[PinProfLen,inf] PinProfs, tempPinProfs
	Duplicate/Free/R=[0,LineProflen-1] LineProfw, tempLineProfw
	Duplicate/Free/R=[PinProfLen,inf] PinProfw, tempPinProfw

	//rebin the high q region
//	IR1D_rebinData(tempPinProfr,tempPinProfq,tempPinProfs,100, 1)

	//concatenate
	Concatenate/O/NP {tempLineProfr, tempPinProfr}, $("r_"+SmWaveNames)
	Concatenate/O/NP {tempLineProfQ,tempPinProfq }, $("q_"+SmWaveNames)
	Concatenate/O/NP {tempLineProfs, tempPinProfs}, $("s_"+SmWaveNames)
	Concatenate/O/NP {tempLineProfw, tempPinProfw}, $("w_"+SmWaveNames)
	
	Wave NewQ=$("q_"+SmWaveNames)
	Wave NewR=$("r_"+SmWaveNames)
	Wave NewS=$("s_"+SmWaveNames)
	Wave NewW=$("w_"+SmWaveNames)
	SVAR DataType = root:Packages:Convert2Dto1D:DataFileExtension
	if(stringMatch(DataType,"Nexus"))
		//	//add recording of metatdata from Nexus file, if they exist... 
		SVAR/Z NXMetadataOld = root:Packages:Convert2Dto1D:NXMetadata
		SVAR/Z NXSampleOld = root:Packages:Convert2Dto1D:NXSample
		SVAR/Z NXInstrumentOld = root:Packages:Convert2Dto1D:NXInstrument
		SVAR/Z NXUserOld = root:Packages:Convert2Dto1D:NXUser
		if(SVAR_Exists(NXMetadataOld ))
			string/g NXMetadata 
			NXMetadata 	= 	NXMetadataOld
		endif
		if(SVAR_Exists(NXSampleOld ))
			string/g NXSample 
			NXSample 	= 	NXSampleOld
		endif
		if(SVAR_Exists(NXUserOld ))
			string/g NXUser 
			NXUser 	= 	NXUserOld
		endif
		if(SVAR_Exists(NXInstrumentOld ))
			string/g NXInstrument 
			NXInstrument 	= 	NXInstrumentOld
		endif		
	endif
	//make UserSampleName
	string/g UserSampleName= UserSampleNameGlobal+"_u"
	

	DoWIndow LineuotDisplayPlot_Q
	if(V_Flag)
		DoWindow/F LineuotDisplayPlot_Q
		CheckDisplayed /W=LineuotDisplayPlot_Q  $(NameOfWave(NewR))
		if(!V_Flag) 
			AppendToGraph /W=LineuotDisplayPlot_Q NewR vs NewQ 
		endif
	endif	
	//now delete the data which user did not want...
	
	if(SAXSDeleteTempPinData)
		DoWIndow LineuotDisplayPlot_Q
		if(V_Flag)
			CheckDisplayed /W=LineuotDisplayPlot_Q  LineProfr
			if(V_Flag)
				removeFromGraph /W=LineuotDisplayPlot_Q $nameofWave(LineProfr)
			endif
		endif
		KillDataFolder/Z $LIneProfFolder
	endif
	DoWIndow LineuotDisplayPlot_Q
	if(V_Flag)
		DoWindow/F LineuotDisplayPlot_Q
		IN2G_LegendTopGrphFldr(str2num(IN2G_LkUpDfltVar("LegendSize")),15,1,0)
		IN2G_ColorTopGrphRainbow()
	endif	
	
	SETDATAFOLDER OldDf
end