#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.36

//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

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


Function NI1_15IDDConfigureNika()

	string OldDFf=GetDataFolder(1)

	//first initialize 
	NI1A_Initialize2Dto1DConversion()
	NEXUS_Initialize(0)
	NVAR NX_InputFileIsNexus = root:Packages:Irena_Nexus:NX_InputFileIsNexus
	NX_InputFileIsNexus = 1
	NI1_15IDDCreateHelpNbk()
	//set some parameters here:
	
	setDataFOlder root:Packages:Convert2Dto1D:
	
	string ListOfVariables="USAXSSlitLength;SAXSGenSmearedPinData;SAXSDeleteTempPinData;USAXSForceTransmissionDialog;"
	ListOfVariables +="USAXSSAXSselector;USAXSWAXSselector;USAXSBigSAXSselector;USAXSCheckForRIghtEmpty;USAXSCheckForRIghtDark;USAXSForceTransRecalculation;"
	ListOfVariables +="USAXSLoadListedEmpDark;USAXSForceUSAXSTransmission;"
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

	//update main panel... 
	DoWIndow NI1A_Convert2Dto1DPanel
	if(V_Flag)
		PopupMenu Select2DDataType win=NI1A_Convert2Dto1DPanel, mode=4
		NI1A_UpdateDataListBox()
	endif
	//create config panel
	DoWindow NI1_15IDDConfigPanel
	if(V_Flag)
		DoWindow /F NI1_15IDDConfigPanel
	else
		Execute("NI1_15IDDConfigPanel()")
	endif
	AutopositionWindow/M=0 NI1_15IDDConfigPanel  
	AutopositionWindow/M=1/r=NI1_15IDDConfigPanel  Instructions_15IDD
	
	setDataFolder OldDFf
end
//************************************************************************************************************
//************************************************************************************************************
Window NI1_15IDDConfigPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(470,87,1016,439)
	DoWindow/C NI1_15IDDConfigPanel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 3,textrgb= (16385,16388,65535)
	DrawText 10,25,"9ID-C (or 15IDD) Nexus file configuration"
	
	DrawText 10, 43, "SAXS : Pilatus 100k camera in USAXS (use with USAXS)"
	DrawText 10, 60, "WAXS    : Pilatus 100k or 200kw WAXS used in USAXS/SAXS/WAXS configuration"
	DrawText 10, 77, "SAXS     : large SAXS camera in the 15ID-D (only SAXS, no USAXS)"
	Checkbox SAXSSelection,pos={10,90},size={100,20}, variable=root:Packages:Convert2Dto1D:USAXSSAXSselector, proc=NI1_15IDDCheckProc
	Checkbox SAXSSelection, title ="SAXS", help={"Use to configure Nika for SAXS"}
	Checkbox USAXSWAXSselector,pos={150,90},size={100,20}, variable=root:Packages:Convert2Dto1D:USAXSWAXSselector, proc=NI1_15IDDCheckProc
	Checkbox USAXSWAXSselector, title ="WAXS", help={"Use to configure Nika for WAXS"}
	Checkbox BigSAXSSelection,pos={290,90},size={100,20}, variable=root:Packages:Convert2Dto1D:USAXSBigSAXSselector, proc=NI1_15IDDCheckProc
	Checkbox BigSAXSSelection, title ="15ID SAXS", help={"Use to configure Nika for SAXS"}

	Button Open15IDDManual,pos={390,20},size={150,20},proc=NI1_15IDDButtonProc,title="Open manual"
	Button Open15IDDManual,help={"Open manual"}

	Button ConfigureDefaultMethods,pos={29,115},size={150,20},proc=NI1_15IDDButtonProc,title="Set default methods"
	Button ConfigureDefaultMethods,help={"Sets default methods for the data reduction at 9IDC (or 15IDD)"}
	Button ConfigureWaveNoteParameters,pos={229,115},size={150,20},proc=NI1_15IDDButtonProc,title="Set Experiment Settings"
	Button ConfigureWaveNoteParameters,help={"Sets default settings based on image currently loaded in the Nika package"}
	SetVariable USAXSSlitLength, pos={29,150}, size={150,20}, proc=NI1_15IDDSetVarProc, title="Slit length", variable=root:Packages:Convert2Dto1D:USAXSSlitLength
	SetVariable USAXSSlitLength,help={"Sets USAXS slit length"}
	Button SetUSAXSSlitLength,pos={229,150},size={150,20},proc=NI1_15IDDButtonProc,title="Set Slit Legnth"
	Button SetUSAXSSlitLength,help={"Sets Slit length from USAXS data"}
	Button WAXSUseBlank,pos={229,150},size={150,20},proc=NI1_15IDDButtonProc,title="WAXS use Blank"
	Button WAXSUseBlank,help={"Set for use blank with 200kw WAXS"}
	Button CreateBadPIXMASK,pos={229,185},size={150,20},proc=NI1_15IDDButtonProc,title="Create SAXS/WAXS mask"
	Button CreateBadPIXMASK,help={"Create mask for Pilatus 100 SAXS and 200kw WAXS"}
	Checkbox SAXSGenSmearedPinData,pos={29,220},size={150,20}, variable=root:Packages:Convert2Dto1D:SAXSGenSmearedPinData, proc=NI1_15IDDCheckProc
	Checkbox SAXSGenSmearedPinData, title ="Create Smeared Data", help={"Set to create smeared data for merging with USAXS"}
	Checkbox SAXSDeleteTempPinData,pos={229,220},size={150,20}, variable=root:Packages:Convert2Dto1D:SAXSDeleteTempPinData, noproc
	Checkbox SAXSDeleteTempPinData, title ="Delete temp Data", help={"Delete the sector and line averages"}
	
	Checkbox USAXSForceUSAXSTransmission,pos={29,255},size={150,20}, variable=root:Packages:Convert2Dto1D:USAXSForceUSAXSTransmission, noproc
	Checkbox USAXSForceUSAXSTransmission, title ="Force use of USAXS Empty/Transm. ?", help={"Set to force use of same empty as USAXS and USAXS Transmission"}
	Checkbox USAXSForceTransRecalculation,pos={29,255},size={150,20}, variable=root:Packages:Convert2Dto1D:USAXSForceTransRecalculation, noproc
	Checkbox USAXSForceTransRecalculation, title ="Recalculate always transmission ?", help={"Set to get Transmission to be racalculated from Empty, Smaple & Dark scaler values"}
	Checkbox ForceTransmissionDialog,pos={29,280},size={150,20}, variable=root:Packages:Convert2Dto1D:USAXSForceTransmissionDialog, noproc
	Checkbox ForceTransmissionDialog, title ="Force transmission verification?", help={"Set to get Transmission dialog to check for every sample"}

	Checkbox USAXSCheckForRIghtEmpty,pos={10,220},size={150,20}, variable=root:Packages:Convert2Dto1D:USAXSCheckForRIghtEmpty, noproc
	Checkbox USAXSCheckForRIghtEmpty, title ="Check Empty Name", help={"Set to have code force dialog to load right empty"}
	Checkbox USAXSCheckForRIghtDark,pos={180,220},size={150,20}, variable=root:Packages:Convert2Dto1D:USAXSCheckForRIghtDark, noproc
	Checkbox USAXSCheckForRIghtDark, title ="Check Dark Name", help={"Set to have code force dialog to load correct Dark"}
	Checkbox USAXSLoadListedEmpDark,pos={350,220},size={150,20}, variable=root:Packages:Convert2Dto1D:USAXSLoadListedEmpDark, noproc
	Checkbox USAXSLoadListedEmpDark, title ="Automatically load Emp/Dark", help={"Load NX file listed Empty/Dark if they can be identified"}

	NI1_15IDDDisplayAndHideControls()
EndMacro
//************************************************************************************************************
//************************************************************************************************************
Function NI1_15IDDDisplayAndHideControls()

	NVAR USAXSSAXSselector = root:Packages:Convert2Dto1D:USAXSSAXSselector
	NVAR USAXSWAXSselector = root:Packages:Convert2Dto1D:USAXSWAXSselector
	NVAR USAXSBigSAXSselector = root:Packages:Convert2Dto1D:USAXSBigSAXSselector
	variable DisplayPinCntrls=USAXSBigSAXSselector || USAXSWAXSselector
	variable DisplayWAXSCntrls=USAXSSAXSselector || USAXSWAXSselector

	Checkbox SAXSGenSmearedPinData, win= NI1_15IDDConfigPanel, disable = DisplayPinCntrls
	Checkbox SAXSDeleteTempPinData,  win= NI1_15IDDConfigPanel, disable = DisplayPinCntrls

	Button WAXSUseBlank,win= NI1_15IDDConfigPanel, disable = !USAXSWAXSselector
	Button CreateBadPIXMASK,win= NI1_15IDDConfigPanel, disable = USAXSBigSAXSselector
	Button SetUSAXSSlitLength, win= NI1_15IDDConfigPanel, disable = DisplayPinCntrls
	SetVariable USAXSSlitLength, win= NI1_15IDDConfigPanel, disable = DisplayPinCntrls
	Checkbox USAXSForceUSAXSTransmission, win= NI1_15IDDConfigPanel, disable = DisplayPinCntrls

	Checkbox USAXSCheckForRIghtEmpty, win= NI1_15IDDConfigPanel, disable = DisplayWAXSCntrls
	Checkbox USAXSCheckForRIghtDark, win= NI1_15IDDConfigPanel, disable = DisplayWAXSCntrls
	Checkbox USAXSForceTransRecalculation, win= NI1_15IDDConfigPanel, disable = DisplayWAXSCntrls
	Checkbox USAXSLoadListedEmpDark, win= NI1_15IDDConfigPanel, disable = DisplayWAXSCntrls
	Checkbox ForceTransmissionDialog, win= NI1_15IDDConfigPanel, disable = USAXSWAXSselector
end
//************************************************************************************************************
//************************************************************************************************************

Function NI1_15IDDCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR USAXSWAXSselector = root:Packages:Convert2Dto1D:USAXSWAXSselector
			NVAR USAXSSAXSselector = root:Packages:Convert2Dto1D:USAXSSAXSselector
			NVAR USAXSBigSAXSselector = root:Packages:Convert2Dto1D:USAXSBigSAXSselector
			if(stringmatch(cba.ctrlName,"SAXSSelection"))
				if(checked)
					USAXSBigSAXSselector =0
					// USAXSSAXSselector=0
					USAXSWAXSselector=0
				endif
				NI1_15IDDDisplayAndHideControls()
			endif
			if(stringmatch(cba.ctrlName,"USAXSWAXSselector"))
				if(checked)
					USAXSBigSAXSselector =0
					USAXSSAXSselector=0
					//USAXSWAXSselector=0
				endif
				NI1_15IDDDisplayAndHideControls()
			endif
			if(stringmatch(cba.ctrlName,"BigSAXSSelection"))
				if(checked)
					//USAXSBigSAXSselector =0
					USAXSSAXSselector=0
					USAXSWAXSselector=0
				endif
				NI1_15IDDDisplayAndHideControls()
			endif
	
			if(USAXSBigSAXSselector+USAXSSAXSselector+USAXSWAXSselector!=1)
				USAXSBigSAXSselector =0
				USAXSSAXSselector=1
				USAXSWAXSselector=0
			endif

			if(stringmatch(cba.CtrlName,"SAXSGenSmearedPinData"))
				NVAR UseLineProfile=root:Packages:Convert2Dto1D:UseLineProfile
				if(Checked)
					NVAR USAXSSlitLength = root:Packages:Convert2Dto1D:USAXSSlitLength
					if(USAXSSlitLength<0.001)	//slit length not set, force user to find it...
						USAXSSlitLength = NI1_15IDDFIndSlitLength()
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
Function NI1_15IDDSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
				NI1_15IDDSetLineWIdth()			
		case 2: // Enter key
				NI1_15IDDSetLineWIdth()			
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

Function NI1_Open15IDDManual()
	//this function writes batch file and starts the manual.
	//we need to write following batch file: "C:\Program Files\WaveMetrics\Igor Pro Folder\User Procedures\Irena\Irena manual.pdf"
	//on Mac we just fire up the Finder with Mac type path... 
	
	//check where we run...
		string WhereIsManual
		string WhereAreProcedures=RemoveEnding(FunctionPath(""),"NI1_15IDDsupport.ipf")
		String manualPath = ParseFilePath(5,"15IDDSAXSAnalysis.pdf","*",0,0)
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
		DoWindow/K NewBatchFile
		ExecuteScriptText "\""+SpecialDirPath("Temporary", 0, 1, 0 )+"StartManual.bat\""
	endif
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function NI1_15IDDButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here

			if (stringmatch("WAXSUseBlank",ba.CtrlName))
				NI1_15IDDWAXSBlankSUbtraction()				
			endif
			if (stringmatch("Open15IDDManual",ba.CtrlName))
				NI1_Open15IDDManual()
			endif
			if (stringmatch("ConfigureDefaultMethods",ba.CtrlName))
				NI1_15IDDSetDefaultNx()				
				NI1A_Convert2Dto1DMainPanel()
			endif
			if (stringmatch("ConfigureWaveNoteParameters",ba.CtrlName))
				NI1_15IDDWaveNoteValuesNx()				
			endif
			if (stringmatch("CreateBadPIXMASK",ba.CtrlName))
				NVAR isSAXS=root:Packages:Convert2Dto1D:USAXSSAXSselector
				NVAR isWAXS=root:Packages:Convert2Dto1D:USAXSWAXSselector
				if(isSAXS)
					NI1_15IDDCreateSAXSPixMask()		
				elseif(isWAXS)	
					NI1_15IDDCreateWAXSPixMask()	
				endif	
			endif
			if (stringmatch("SetUSAXSSlitLength",ba.CtrlName))
				NVAR USAXSSlitLength=root:Packages:Convert2Dto1D:USAXSSlitLength
				USAXSSlitLength = NI1_15IDDFIndSlitLength()
				NI1_15IDDSetLineWIdth()			
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************
//************************************************************************************************************
Function NI1_15IDDCreateSAXSPixMask()			

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
Function NI1_15IDDCreateWAXSPixMask()			

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
	
		string notestr="MaskOffLowIntPoints:0;LowIntToMaskOff:0>// ;ITEMNO:0;\r"
		notestr+="	SetDrawEnv xcoord= top,ycoord= left\r"
		notestr+="// ;ITEMNO:1;\r"
		notestr+="SetDrawEnv linefgc= (3,52428,1)\r"
		notestr+="// ;ITEMNO:2;\r"
		notestr+="SetDrawEnv fillpat= 5,fillfgc= (0,0,0)\r"
		notestr+="// ;ITEMNO:3;\r"
		notestr+="SetDrawEnv save\r"
		notestr+="// ;ITEMNO:4;\r"
		notestr+="DrawRect 0,486,195,495\r"	
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


Function NI1_15IDDSetLineWIdth()
		
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
Function NI1_15IDDWAXSBlankSUbtraction()	
				NVAR UseSampleTransmission = root:Packages:Convert2Dto1D:UseSampleTransmission
				NVAR UseEmptyField = root:Packages:Convert2Dto1D:UseEmptyField
				NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate
				NVAR DoGeometryCorrection = root:Packages:Convert2Dto1D:DoGeometryCorrection
				NVAR UseMonitorForEf = root:Packages:Convert2Dto1D:UseMonitorForEf
				NVAR UseSampleTransmFnct = root:Packages:Convert2Dto1D:UseSampleTransmFnct
				NVAR UseSampleMonitorFnct = root:Packages:Convert2Dto1D:UseSampleMonitorFnct
				NVAR UseEmptyMonitorFnct = root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
				
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
			
				SampleTransmFnct = "NI1_15IDWFindTRANS"
				SampleMonitorFnct = "NI1_15IDWFindI0"
				EmptyMonitorFnct = "NI1_15IDWFindEFI0"

				NI1A_SetCalibrationFormula()			

end

//************************************************************************************************************
//************************************************************************************************************
Function NI1_15IDDSetDefaultNx()
	
	NI1A_Initialize2Dto1DConversion()
	NI1BC_InitCreateBmCntrFile()

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
				QvectorNumberPoints=487
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
				
				UseSampleTransmission = 0
				UseEmptyField = 0
				UseI0ToCalibrate = 1
				DoGeometryCorrection = 0
				UseMonitorForEf = 0
				UseSampleTransmFnct = 0
				UseSampleMonitorFnct = 1
				UseEmptyMonitorFnct = 1
				

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
			
				SampleTransmFnct = ""
				SampleMonitorFnct = "NI1_15IDWFindI0"
				EmptyMonitorFnct = "NI1_15IDWFindEFI0"
			
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
				NVAR NumberOfSectors = root:Packages:Convert2Dto1D:NumberOfSectors
				NVAR SectorsStartAngle = root:Packages:Convert2Dto1D:SectorsStartAngle
				NVAR SectorsHalfWidth = root:Packages:Convert2Dto1D:SectorsHalfWidth
				NVAR DisplayDataAfterProcessing = root:Packages:Convert2Dto1D:DisplayDataAfterProcessing
				NVAR StoreDataInIgor = root:Packages:Convert2Dto1D:StoreDataInIgor
				NVAR OverwriteDataIfExists = root:Packages:Convert2Dto1D:OverwriteDataIfExists
				NVAR Use2Ddataname = root:Packages:Convert2Dto1D:Use2Ddataname
				NVAR QvectorNumberPoints = root:Packages:Convert2Dto1D:QvectorNumberPoints
				QvectorNumberPoints=120
				QBinningLogarithmic=1
				QvectormaxNumPnts = 0
				DoSectorAverages = 1
				NumberOfSectors = 1
				SectorsStartAngle = 270
				SectorsHalfWidth = 30
				DisplayDataAfterProcessing = 1
				StoreDataInIgor = 1
				OverwriteDataIfExists = 1
				Use2Ddataname = 1
			
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
					
				LineProf_CurveType="Vertical Line" 
				UseLineProfile=1
				LineProfileUseCorrData=1
				LineProfileUseRAW =0
			
				NVAR UseSampleTransmission = root:Packages:Convert2Dto1D:UseSampleTransmission
				NVAR UseEmptyField = root:Packages:Convert2Dto1D:UseEmptyField
				NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate
				NVAR DoGeometryCorrection = root:Packages:Convert2Dto1D:DoGeometryCorrection
				NVAR UseMonitorForEf = root:Packages:Convert2Dto1D:UseMonitorForEf
				NVAR UseSampleTransmFnct = root:Packages:Convert2Dto1D:UseSampleTransmFnct
				NVAR UseSampleMonitorFnct = root:Packages:Convert2Dto1D:UseSampleMonitorFnct
				NVAR UseEmptyMonitorFnct = root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
				
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
			//	SVAR SampleNameMatchStr = root:Packages:Convert2Dto1D:SampleNameMatchStr
				
				SampleTransmFnct = "NI1_15IDDFIndTransmission"
				SampleMonitorFnct = "NI1_15IDDFindI0"
				EmptyMonitorFnct = "NI1_15IDDFindEfI0"
			//	SampleNameMatchStr="*.hdf5"
			
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
	else		//end of SAXS selectetin, bellow starts bigSAXS specifics...
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
				
				SampleTransmFnct = "NI1_15IDDSFIndTransmission"
				SampleMonitorFnct = "NI1_15IDDSFindI0"
				EmptyMonitorFnct = "NI1_15IDDSFindEfI0"
				SampleThicknFnct = "NI1_15IDDSFindThickness"
			
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
				NewPath/C/O/M="Select path to your data" Convert2Dto1DDataPath
				PathInfo Convert2Dto1DDataPath
				string pathInforStrL = S_Path
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
	


	DoWIndow NI1_CreateBmCntrFieldPanel
	if(V_Flag)
		DoWindow/F NI1_CreateBmCntrFieldPanel
		//set to Ag Behenate
		NI1BC_BmCntrPopMenuProc("BmCalibrantName",2,"Ag behenate")
		PopupMenu BmCntrFileType win=NI1_CreateBmCntrFieldPanel, mode=4
		TabControl BmCntrTab win=NI1_CreateBmCntrFieldPanel, value=0
		NI1BC_TabProc("BmCntrTab",0)
	endif
	NI1BC_UpdateBmCntrListBox()	
	NI1A_UpdateDataListBox()	
	NI1A_UpdateEmptyDarkListBox()	
	print "Deafult methods were set"
end
//************************************************************************************************************
//************************************************************************************************************

Function/S NI1_15IDDFindWaveNoteValue(StringKeyName)
	string StringKeyName
	
	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Load one Image file first so the tool can read the wave note information"  
	endif
	string OldNOte=note(w2D)
	return StringByKey(NI1_15IDDFindKeyStr(StringKeyName+"=", OldNote), OldNote  , "=" , ";")
end


Function/S NI1_15IDDFindEmptyNoteValue(StringKeyName)
	string StringKeyName
	
	Wave/Z w2D = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(w2D))
		Abort "Load Empty Image file first so the tool can read the wave note information"  
	endif
	string OldNOte=note(w2D)
	return StringByKey(NI1_15IDDFindKeyStr(StringKeyName+"=", OldNote), OldNote  , "=" , ";")
end


Function/S NI1_15IDDFindDarkNoteValue(StringKeyName)
	string StringKeyName
	
	Wave/Z w2D = root:Packages:Convert2Dto1D:DarkFieldData
	if(!WaveExists(w2D))
		Abort "Load one Image file first so the tool can read the wave note information"  
	endif
	string OldNOte=note(w2D)
	return StringByKey(NI1_15IDDFindKeyStr(StringKeyName+"=", OldNote), OldNote  , "=" , ";")
end

//************************************************************************************************************
//************************************************************************************************************
Function NI1_15IDDWaveNoteValuesNx()
	
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
		
	if((stringMatch("15ID", StringByKey(NI1_15IDDFindKeyStr("facility_beamline=", OldNote), OldNOte  , "=" , ";"))||stringMatch("9ID", StringByKey(NI1_15IDDFindKeyStr("facility_beamline=", OldNote), OldNOte  , "=" , ";"))) && stringMatch("Pilatus", StringByKey(NI1_15IDDFindKeyStr("model=", OldNote), OldNOte  , "=" , ";")))	
		Wavelength = NumberByKey(NI1_15IDDFindKeyStr("monochromator:wavelength=", OldNote), OldNote  , "=" , ";")
		XRayEnergy = 12.3984/Wavelength
		if(useSAXS)
			PixelSizeX = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_pixel_size_x=", OldNote), OldNote  , "=" , ";")
			PixelSizeY = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_pixel_size_y=", OldNote), OldNote  , "=" , ";")
			if(numtype(PixelSizeX)!=0)		//old data from 15ID
				PixelSizeX = NumberByKey(NI1_15IDDFindKeyStr("x_pixel_size=", OldNote), OldNote  , "=" , ";")
				PixelSizeY = NumberByKey(NI1_15IDDFindKeyStr("y_pixel_size=", OldNote), OldNote  , "=" , ";")
			endif
			HorizontalTilt = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_tilt_x=", OldNote), OldNote  , "=" , ";")
			VerticalTilt = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_tilt_y=", OldNote), OldNote  , "=" , ";")
			BeamCenterX = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_center_x_pixel=", OldNote), OldNote  , "=" , ";")
			BeamCenterY = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_center_y_pixel=", OldNote), OldNote  , "=" , ";")
			SampleToCCDdistance = NumberByKey(NI1_15IDDFindKeyStr("distance=", OldNote), OldNote  , "=" , ";")
	 		BeamSizeX = NumberByKey(NI1_15IDDFindKeyStr("aperture:hsize=", OldNote), OldNote  , "=" , ";")
	 		BeamSizeY = NumberByKey(NI1_15IDDFindKeyStr("aperture:vsize=", OldNote), OldNote  , "=" , ";")
		elseif(useWAXS)
			PixelSizeX = NumberByKey(NI1_15IDDFindKeyStr("x_pixel_size=", OldNote), OldNote  , "=" , ";")
			PixelSizeY = NumberByKey(NI1_15IDDFindKeyStr("y_pixel_size=", OldNote), OldNote  , "=" , ";")
			HorizontalTilt = NumberByKey(NI1_15IDDFindKeyStr("waxs_ccd_tilt_x=", OldNote), OldNote  , "=" , ";")
			VerticalTilt = NumberByKey(NI1_15IDDFindKeyStr("waxs_ccd_tilt_y=", OldNote), OldNote  , "=" , ";")
			BeamCenterX = NumberByKey(NI1_15IDDFindKeyStr("waxs_ccd_center_x_pixel=", OldNote), OldNote  , "=" , ";")
			BeamCenterY = NumberByKey(NI1_15IDDFindKeyStr("waxs_ccd_center_y_pixel=", OldNote), OldNote  , "=" , ";")
			SampleToCCDdistance = NumberByKey(NI1_15IDDFindKeyStr("distance=", OldNote), OldNote  , "=" , ";")
	 		BeamSizeX = NumberByKey(NI1_15IDDFindKeyStr("aperture:hsize=", OldNote), OldNote  , "=" , ";")
	 		BeamSizeY = NumberByKey(NI1_15IDDFindKeyStr("aperture:vsize=", OldNote), OldNote  , "=" , ";")
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
	elseif((stringMatch("9ID", StringByKey(NI1_15IDDFindKeyStr("facility_beamline=", OldNote), OldNOte  , "=" , ";"))) && stringMatch("XRD0820", StringByKey(NI1_15IDDFindKeyStr("model=", OldNote), OldNOte  , "=" , ";")))	
		Wavelength = NumberByKey(NI1_15IDDFindKeyStr("monochromator:wavelength=", OldNote), OldNote  , "=" , ";")
		XRayEnergy = 12.3984/Wavelength
		if(useSAXS)
			PixelSizeX = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_pixel_size_x=", OldNote), OldNote  , "=" , ";")
			PixelSizeY = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_pixel_size_y=", OldNote), OldNote  , "=" , ";")
			if(numtype(PixelSizeX)!=0)		//old data from 15ID
				PixelSizeX = NumberByKey(NI1_15IDDFindKeyStr("x_pixel_size=", OldNote), OldNote  , "=" , ";")
				PixelSizeY = NumberByKey(NI1_15IDDFindKeyStr("y_pixel_size=", OldNote), OldNote  , "=" , ";")
			endif
			HorizontalTilt = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_tilt_x=", OldNote), OldNote  , "=" , ";")
			VerticalTilt = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_tilt_y=", OldNote), OldNote  , "=" , ";")
			BeamCenterX = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_center_x_pixel=", OldNote), OldNote  , "=" , ";")
			BeamCenterY = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_center_y_pixel=", OldNote),  OldNote  , "=" , ";")
			SampleToCCDdistance = NumberByKey(NI1_15IDDFindKeyStr("distance=", OldNote), OldNote  , "=" , ";")
	 		BeamSizeX = NumberByKey(NI1_15IDDFindKeyStr("aperture:hsize=", OldNote), OldNote  , "=" , ";")
	 		BeamSizeY = NumberByKey(NI1_15IDDFindKeyStr("aperture:vsize=", OldNote), OldNote  , "=" , ";")
		elseif(useWAXS)
			PixelSizeX = NumberByKey(NI1_15IDDFindKeyStr("x_pixel_size=", OldNote), OldNote  , "=" , ";")
			PixelSizeY = NumberByKey(NI1_15IDDFindKeyStr("y_pixel_size=", OldNote), OldNote  , "=" , ";")
			HorizontalTilt = NumberByKey(NI1_15IDDFindKeyStr("waxs_ccd_tilt_x=", OldNote), OldNote  , "=" , ";")
			VerticalTilt = NumberByKey(NI1_15IDDFindKeyStr("waxs_ccd_tilt_y=", OldNote), OldNote  , "=" , ";")
			BeamCenterX = NumberByKey(NI1_15IDDFindKeyStr("waxs_ccd_center_x_pixel=", OldNote), OldNote  , "=" , ";")
			BeamCenterY = NumberByKey(NI1_15IDDFindKeyStr("waxs_ccd_center_y_pixel=", OldNote), OldNote  , "=" , ";")
			SampleToCCDdistance = NumberByKey(NI1_15IDDFindKeyStr("distance=", OldNote), OldNote  , "=" , ";")
	 		BeamSizeX = NumberByKey(NI1_15IDDFindKeyStr("aperture:hsize=", OldNote), OldNote  , "=" , ";")
	 		BeamSizeY = NumberByKey(NI1_15IDDFindKeyStr("aperture:vsize=", OldNote), OldNote  , "=" , ";")
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
		Wavelength = NumberByKey(NI1_15IDDFindKeyStr("monochromator:wavelength=", OldNote), OldNote  , "=" , ";")
		XRayEnergy = 12.3984/Wavelength
		if(useSAXS)
			PixelSizeX = NumberByKey(NI1_15IDDFindKeyStr("detector:x_pixel_size=", OldNote), OldNote  , "=" , ";")
			PixelSizeY = NumberByKey(NI1_15IDDFindKeyStr("detector:y_pixel_size=", OldNote), OldNote  , "=" , ";")
			HorizontalTilt = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_tilt_x=", OldNote), OldNote  , "=" , ";")
			VerticalTilt = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_tilt_y=", OldNote), OldNote  , "=" , ";")
			BeamCenterX = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_center_x_pixel=", OldNote), OldNote  , "=" , ";")
			BeamCenterY = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_center_y_pixel=", OldNote), OldNote  , "=" , ";")
			SampleToCCDdistance = NumberByKey(NI1_15IDDFindKeyStr("detector:distance=", OldNote), OldNote  , "=" , ";")
		elseif(useWAXS)
			PixelSizeX = NumberByKey(NI1_15IDDFindKeyStr("waxs_detector:x_pixel_size=", OldNote), OldNote  , "=" , ";")
			PixelSizeY = NumberByKey(NI1_15IDDFindKeyStr("waxs_detector:y_pixel_size=", OldNote), OldNote  , "=" , ";")
			HorizontalTilt = NumberByKey(NI1_15IDDFindKeyStr("EPICS_PV_metadata:waxs_ccd_tilt_x=", OldNote), OldNote  , "=" , ";")
			VerticalTilt = NumberByKey(NI1_15IDDFindKeyStr("EPICS_PV_metadata:waxs_ccd_tilt_y=", OldNote), OldNote  , "=" , ";")
			BeamCenterX = NumberByKey(NI1_15IDDFindKeyStr("waxs_ccd_center_x_pixel=", OldNote), OldNote  , "=" , ";")
			BeamCenterY = NumberByKey(NI1_15IDDFindKeyStr("waxs_ccd_center_y_pixel=", OldNote), OldNote  , "=" , ";")
			SampleToCCDdistance = NumberByKey(NI1_15IDDFindKeyStr("waxs_detector:distance=", OldNote), OldNote  , "=" , ";")
		endif		
		print "Set experimental settinsg and geometry from file :"+Current2DFileName
		print "Wavelength = "+num2str(Wavelength)
		print "XRayEnergy = "+num2str(12.3984/Wavelength)
		print "PixelSizeX = "+num2str(PixelSizeX)
		print "PixelSizeY = "+num2str(PixelSizeY)
		print "BeamCenterX = "+num2str(BeamCenterX)
		print "BeamCenterY = "+num2str(BeamCenterY)
		print "SampleToCCDdistance = "+num2str(SampleToCCDdistance)

	elseif(stringMatch("15ID", StringByKey("instrument:source:facility_beamline", OldNOte  , "=" , ";")) && stringMatch("CCD", StringByKey("data:model", OldNOte  , "=" , ";")))	
		//should be for useBigSAXS=1
		beamline_support_version = NumberByKey(NI1_15IDDFindKeyStr("beamline_support_version=", OldNote), OldNote  , "=" , ";")
		if(numtype(beamline_support_version)!=0)			//this applies for MarCCD support
			beamline_support_version=0
		endif
		if(beamline_support_version==0)
			Wavelength = NumberByKey(NI1_15IDDFindKeyStr("monochromator:wavelength=", OldNote), OldNote  , "=" , ";")
			XRayEnergy = 12.3984/Wavelength
			PixelSizeX = NumberByKey(NI1_15IDDFindKeyStr("detector:x_pixel_size=", OldNote), OldNote  , "=" , ";")
			PixelSizeY = NumberByKey(NI1_15IDDFindKeyStr("detector:y_pixel_size=", OldNote), OldNote  , "=" , ";")
			BeamCenterX = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_center_x_pixel=", OldNote), OldNote  , "=" , ";")
			BeamCenterY = NumberByKey(NI1_15IDDFindKeyStr("pin_ccd_center_y_pixel=", OldNote), OldNote  , "=" , ";")
			if(PixelSizeX<=0 || PixelSizeY<=0 || BeamCenterX<=0 || BeamCenterY<=0)
				DoALert 0, "Pixel sizes or beam center positions are 0, header information is bad. Please check and find correct values"
			endif
			SampleToCCDdistance = NumberByKey(NI1_15IDDFindKeyStr("detector:distance=", OldNote), OldNote  , "=" , ";")
		elseif(beamline_support_version>=1)		//latest version for now. Written when beamline_support_version=1 May 2012
			Wavelength = NumberByKey(NI1_15IDDFindKeyStr("EPICS_PV_metadata:wavelength=", OldNote), OldNote  , "=" , ";")
			XRayEnergy = 12.3984/Wavelength
			PixelSizeX = NumberByKey(NI1_15IDDFindKeyStr("instrument:detector:x_pixel_size=", OldNote), OldNote  , "=" , ";")
			PixelSizeY = NumberByKey(NI1_15IDDFindKeyStr("instrument:detector:y_pixel_size=", OldNote), OldNote  , "=" , ";")
			BeamCenterX = NumberByKey(NI1_15IDDFindKeyStr("instrument:detector:beam_center_x=", OldNote), OldNote  , "=" , ";")
			BeamCenterY = NumberByKey(NI1_15IDDFindKeyStr("instrument:detector:beam_center_y=", OldNote), OldNote  , "=" , ";")
			SampleToCCDdistance = NumberByKey(NI1_15IDDFindKeyStr("instrument:detector:distance=", OldNote), OldNote  , "=" , ";")
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

Function/T NI1_15IDDFindKeyStr(StringName, OldNote)
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
Function NI1_15IDDFIndSlitLength()
	
	string SlitLengthIsHere=IN2G_FindFolderWithWvTpsList("root:USAXS:", 10, "SMR_Int", 1)+IN2G_FindFolderWithWvTpsList("root:USAXS:", 10, "M_SMR_Int", 1)
	string SlitLengthIsHereL
	SVAR USAXSSampleName = root:Packages:Convert2Dto1D:USAXSSampleName
	USAXSSampleName = ""
	variable i
	if(ItemsInList(SlitLengthIsHere,";")>0)
		Prompt SlitLengthIsHereL, "USAXS Folders available ", popup,  SlitLengthIsHere
		DoPrompt "Pick USAXS folder where to read slit length", SlitLengthIsHereL
	else
		Abort "No USAXS data found, input manually"
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
		Abort "Slit length not found, input manually"
//		Prompt transmissionUser, "Transmission not found, plese input value"
//		DoPrompt "USAXS transmission NOT FOUND, input value between 0 and 1", transmissionUser
//		Print "For sample :    "+sampleName+"    has been used manually input transmission = "+num2str(Transmission)
//		return transmissionUser
	endif
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function NI1_15IDDSFIndTransmission(SampleName)
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
	string NoteEmptyName=NI1_15IDDFindWaveNoteValue("EPICS_PV_metadata:Empty_Filename")
	string NoteDarkName=NI1_15IDDFindWaveNoteValue("EPICS_PV_metadata:Dark_Filename")
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
	variable ExistingTransmissionInFile=str2num(NI1_15IDDFindWaveNoteValue("EPICS_PV_metadata:transmission"))
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
		if(str2num(NI1_15IDDFindWaveNoteValue("EPICS_PV_metadata:transI0_Spl"))<1)
			 SampleI0=str2num(NI1_15IDDFindWaveNoteValue("EPICS_PV_metadata:transI0_Spl"))
			 SamplePD=str2num(NI1_15IDDFindWaveNoteValue("EPICS_PV_metadata:transNosePD_Value_Spl"))
			 EmptyI0=str2num(NI1_15IDDFindEmptyNoteValue("EPICS_PV_metadata:transI0_Empty"))
			 EmptyPD=str2num(NI1_15IDDFindEmptyNoteValue("EPICS_PV_metadata:transNosePD_Value_Empty"))
			 DarkI0=str2num(NI1_15IDDFindDarkNoteValue("EPICS_PV_metadata:transI0_Dark"))
			 DarkPD=str2num(NI1_15IDDFindDarkNoteValue("EPICS_PV_metadata:transNosePD_Value_Dark"))
		else
			 SampleI0=str2num(NI1_15IDDFindWaveNoteValue("EPICS_PV_metadata:transI0_Sample"))
			 if(SampleI0<1000)	//something wrong, old system???
				 SampleI0=str2num(NI1_15IDDFindWaveNoteValue("EPICS_PV_metadata:transBPM_B_Sample"))
				 SampleI0+=str2num(NI1_15IDDFindWaveNoteValue("EPICS_PV_metadata:transBPM_L_Sample"))
				 SampleI0+=str2num(NI1_15IDDFindWaveNoteValue("EPICS_PV_metadata:transBPM_T_Sample"))
				 SampleI0+=str2num(NI1_15IDDFindWaveNoteValue("EPICS_PV_metadata:transBPM_R_Sample"))
			 endif
			 SamplePD=str2num(NI1_15IDDFindWaveNoteValue("EPICS_PV_metadata:transPD_Sample"))
//

			 EmptyI0=str2num(NI1_15IDDFindEmptyNoteValue("EPICS_PV_metadata:transI0_Empty"))
			 if(EmptyI0<1000)	//something wrong, old system???
				 EmptyI0=str2num(NI1_15IDDFindEmptyNoteValue("EPICS_PV_metadata:transBPM_B_Empty"))
				 EmptyI0+=str2num(NI1_15IDDFindEmptyNoteValue("EPICS_PV_metadata:transBPM_L_Empty"))
				 EmptyI0+=str2num(NI1_15IDDFindEmptyNoteValue("EPICS_PV_metadata:transBPM_T_Empty"))
				 EmptyI0+=str2num(NI1_15IDDFindEmptyNoteValue("EPICS_PV_metadata:transBPM_R_Empty"))
			 endif
			 EmptyPD=str2num(NI1_15IDDFindEmptyNoteValue("EPICS_PV_metadata:transPD_Empty"))
			 DarkI0=0
			 DarkPD = 0
//			 DarkI0=str2num(NI1_15IDDFindDarkNoteValue("EPICS_PV_metadata:transI0_Sample"))
//			 if(DarkI0<10)	//something wrong, old system???
//				 DarkI0=str2num(NI1_15IDDFindDarkNoteValue("EPICS_PV_metadata:transBPM_B_Sample"))
//				 DarkI0+=str2num(NI1_15IDDFindDarkNoteValue("EPICS_PV_metadata:transBPM_L_Sample"))
//				 DarkI0+=str2num(NI1_15IDDFindDarkNoteValue("EPICS_PV_metadata:transBPM_T_Sample"))
//				 DarkI0+=str2num(NI1_15IDDFindDarkNoteValue("EPICS_PV_metadata:transBPM_R_Sample"))
//			endif
//			 DarkPD=str2num(NI1_15IDDFindDarkNoteValue("EPICS_PV_metadata:transPD_Sample"))
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

Function NI1_15IDDNXTransmission()

	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Data Image file not found "  
	endif
	string OldNOte=note(w2D)
	variable SampleI0 = NumberByKey(NI1_15IDDFindKeyStr("Pin_TrI0=", OldNote), OldNote  , "=" , ";")
	variable SampleI0gain = NumberByKey(NI1_15IDDFindKeyStr("Pin_TrI0gain=", OldNote), OldNote  , "=" , ";")
	variable SamplePinPD = NumberByKey(NI1_15IDDFindKeyStr("Pin_TrPD=", OldNote), OldNote  , "=" , ";")
	variable SampleIPinPdGain = NumberByKey(NI1_15IDDFindKeyStr("Pin_TrPDgain=", OldNote), OldNote  , "=" , ";")


	Wave/Z w2D = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(w2D))
		Abort "Empty Image file not found "  
	endif
	OldNOte=note(w2D)
	variable EmptyI0 = NumberByKey(NI1_15IDDFindKeyStr("Pin_TrI0=", OldNote), OldNote  , "=" , ";")
	variable EmptyI0gain = NumberByKey(NI1_15IDDFindKeyStr("Pin_TrI0gain=", OldNote), OldNote  , "=" , ";")
	variable EmptypinPD = NumberByKey(NI1_15IDDFindKeyStr("Pin_TrPD=", OldNote), OldNote  , "=" , ";")
	variable EmptyPinPDGain = NumberByKey(NI1_15IDDFindKeyStr("Pin_TrPDgain=", OldNote), OldNote  , "=" , ";")

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
Function NI1_15IDDFIndTransmission(SampleName)
	string sampleName
	
	string TransmissionIsHere=NI1_15IDDFindLikelyUSAXSName(SampleName)
	string TransmissionIsHereL
	string/g root:Packages:Convert2Dto1D:USAXSSampleName
	SVAR USAXSSampleName = root:Packages:Convert2Dto1D:USAXSSampleName
	NVAR USAXSForceTransmissionDialog = root:Packages:Convert2Dto1D:USAXSForceTransmissionDialog
	NVAR USAXSForceUSAXSTransmission = root:Packages:Convert2Dto1D:USAXSForceUSAXSTransmission

	//try to calculate the transmission using the 2012-03 pinPD placed on teh front of teh snout...
	
	variable CalcTrans = NI1_15IDDNXTransmission()
	
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

Function/S NI1_15IDDFindLikelyUSAXSName(SampleName)
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

	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Image file not found "  
	endif
	string OldNOte=note(w2D)
	variable I000
	I000 = NumberByKey(NI1_15IDDFindKeyStr("I0_cts_gated=", OldNote), OldNote  , "=" , ";")		//try gated signal first...
	if(numtype(I000)!=0)
		I000 = NumberByKey(NI1_15IDDFindKeyStr("I0_cts=", OldNote), OldNote  , "=" , ";")
	endif
	variable I0gain = NumberByKey(NI1_15IDDFindKeyStr("I0_gain=", OldNote), OldNote  , "=" , ";")
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
	I000S = NumberByKey(NI1_15IDDFindKeyStr("I0_cts_gated=", OldNOteSample), OldNOteSample  , "=" , ";")		//try gated signal first...
	if(numtype(I000S)!=0)
		I000S = NumberByKey(NI1_15IDDFindKeyStr("I0_cts=", OldNOteSample), OldNOteSample  , "=" , ";")
	endif
	variable I0gainS = NumberByKey(NI1_15IDDFindKeyStr("I0_gain=", OldNOteSample), OldNOteSample  , "=" , ";")
	I000S = I000S / I0gainS
	if(numtype(I000S)!=0)
		Print "I0 value not found in the wave note of the sample file, setting to 1"
		I000S=1 
	endif
	variable I000E
	I000E = NumberByKey(NI1_15IDDFindKeyStr("I0_cts_gated=", OldNOteEmpty), OldNOteEmpty  , "=" , ";")		//try gated signal first...
	if(numtype(I000E)!=0)
		I000E = NumberByKey(NI1_15IDDFindKeyStr("I0_cts=", OldNOteEmpty), OldNOteEmpty  , "=" , ";")
	endif
	variable I0gainE = NumberByKey(NI1_15IDDFindKeyStr("I0_gain=", OldNOteEmpty), OldNOteEmpty  , "=" , ";")
	I000E = I000E / I0gainE
	if(numtype(I000E)!=0)
		Print "I0 value not found in the wave note of the sample file, setting to 1"
		I000E=1 
	endif

	variable TRDS
	TRDS = NumberByKey(NI1_15IDDFindKeyStr("TR_cts_gated=", OldNOteSample), OldNOteSample  , "=" , ";")		//try gated signal first...
	if(numtype(TRDS)!=0)
		TRDS = NumberByKey(NI1_15IDDFindKeyStr("TR_cts=", OldNOteSample), OldNOteSample  , "=" , ";")
	endif
	variable TRDgainS = NumberByKey(NI1_15IDDFindKeyStr("TR_gain=", OldNOteSample), OldNOteSample  , "=" , ";")
	TRDS = TRDS / TRDgainS
	if(numtype(TRDS)!=0)
		Print "TR diode value not found in the wave note of the sample file, setting to 1"
		TRDS=1 
	endif
	variable TRDE
	TRDE = NumberByKey(NI1_15IDDFindKeyStr("TR_cts_gated=", OldNOteEmpty), OldNOteEmpty  , "=" , ";")		//try gated signal first...
	if(numtype(TRDE)!=0)
		TRDE = NumberByKey(NI1_15IDDFindKeyStr("TR_cts=", OldNOteEmpty), OldNOteEmpty  , "=" , ";")
	endif
	variable TRDgainE = NumberByKey(NI1_15IDDFindKeyStr("TR_gain=", OldNOteEmpty), OldNOteEmpty  , "=" , ";")
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

	Wave/Z w2D = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(w2D))
		Abort "Image file not found "  
	endif
	string OldNOte=note(w2D)
	variable I000
	I000 = NumberByKey(NI1_15IDDFindKeyStr("I0_cts_gated=", OldNote), OldNote  , "=" , ";")		//try gated signal first...
	if(numtype(I000)!=0)
		I000 = NumberByKey(NI1_15IDDFindKeyStr("I0_cts=", OldNote), OldNote  , "=" , ";")
	endif
	variable I0gain = NumberByKey(NI1_15IDDFindKeyStr("I0_gain=", OldNote), OldNote  , "=" , ";")
	I000 = I000 / I0gain
	if(numtype(I000)!=0)
		Print "I0 value not found in the wave note of the sample file, setting to 1"
		I000=1 
	endif
	return I000
end
//************************************************************************************************************
//************************************************************************************************************
Function NI1_15IDDFindI0(SampleName)
	string sampleName

	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Image file not found "  
	endif
	string OldNOte=note(w2D)
	variable I000 = NumberByKey(NI1_15IDDFindKeyStr("I0_cts_gated=", OldNote), OldNote  , "=" , ";")
	variable I0gain = NumberByKey(NI1_15IDDFindKeyStr("I0_gain=", OldNote), OldNote  , "=" , ";")
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
Function NI1_15IDDSFindI0(SampleName)
	string sampleName

	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Image file not found "  
	endif
	string OldNOte=note(w2D)
	variable I000 = NumberByKey(NI1_15IDDFindKeyStr("EPICS_PV_metadata:I0_Sample=", OldNote), OldNote  , "=" , ";")
	if(numtype(I000)!=0 || I000<1)
		I000 = NumberByKey(NI1_15IDDFindKeyStr("EPICS_PV_metadata:BPM_B_Sample=", OldNote), OldNote  , "=" , ";")
		I000 += NumberByKey(NI1_15IDDFindKeyStr("EPICS_PV_metadata:BPM_T_Sample=", OldNote), OldNote  , "=" , ";")
		I000 += NumberByKey(NI1_15IDDFindKeyStr("EPICS_PV_metadata:BPM_L_Sample=", OldNote), OldNote  , "=" , ";")
		I000 += NumberByKey(NI1_15IDDFindKeyStr("EPICS_PV_metadata:BPM_R_Sample=", OldNote), OldNote  , "=" , ";")
	endif
	if(numtype(I000)!=0)
		Print "I0 value not found in the wave note of the sample file, setting to 1"
		I000=1 
	endif
	return I000
end
//************************************************************************************************************
//************************************************************************************************************
Function NI1_15IDDSFindThickness(SampleName)
	string sampleName

	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Image file not found "  
	endif
	string OldNOte=note(w2D)
	variable thickness1 = NumberByKey(NI1_15IDDFindKeyStr("sample:thickness=", OldNote), OldNote  , "=" , ";")
	variable thickness2 = NumberByKey(NI1_15IDDFindKeyStr("EPICS_PV_metadata:sample_thickness=", OldNote), OldNote  , "=" , ";")
	if(numtype(thickness1)==0)
		Print "Found thickness value in the wave note of the sample file, the value is [mm] = "+num2str(thickness1)
		return thickness1
	else
		if(numtype(thickness2)==0)
			Print "Found thickness value in the wave note of the sample file, the value is [mm] = "+num2str(thickness2)
			return thickness2
		else
			Print "Thickness value not found in the wave note of the sample file, setting to 1 [mm]"
			return 1
		endif
	endif
	return 0
end
//************************************************************************************************************
//************************************************************************************************************
Function NI1_15IDDSFindEfI0(SampleName)
	string sampleName

	Wave/Z w2D = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(w2D))
		Abort "Image file not found "  
	endif
	string OldNOte=note(w2D)
	variable I000 = NumberByKey(NI1_15IDDFindKeyStr("EPICS_PV_metadata:I0_Sample=", OldNote), OldNote  , "=" , ";")
	if(numtype(I000)!=0 || I000<1)
		I000 = NumberByKey(NI1_15IDDFindKeyStr("EPICS_PV_metadata:BPM_B_Sample=", OldNote), OldNote  , "=" , ";")
		I000 += NumberByKey(NI1_15IDDFindKeyStr("EPICS_PV_metadata:BPM_T_Sample=", OldNote), OldNote  , "=" , ";")
		I000 += NumberByKey(NI1_15IDDFindKeyStr("EPICS_PV_metadata:BPM_L_Sample=", OldNote), OldNote  , "=" , ";")
		I000 += NumberByKey(NI1_15IDDFindKeyStr("EPICS_PV_metadata:BPM_R_Sample=", OldNote), OldNote  , "=" , ";")
	endif
	if(numtype(I000)!=0)
		Print "I0 value not found in the wave note of the sample file, setting to 1"
		I000=1 
	endif
	return I000
end

//************************************************************************************************************
//************************************************************************************************************
Function NI1_15IDDFindEfI0(SampleName)
	string sampleName
	
	//check the empty file name...
	//this is 2D empty file name
	string LikelyUSAXSName=NI1_15IDDFindLikelyUSAXSName(SampleName)
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
	variable I000 = NumberByKey(NI1_15IDDFindKeyStr("I0_cts_gated=", OldNote), OldNote  , "=" , ";")
	variable I0gain = NumberByKey(NI1_15IDDFindKeyStr("I0_gain=", OldNote), OldNote  , "=" , ";")
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


Function NI1_15IDDCreateHelpNbk()
	String nb = "Instructions_15IDD"
	DoWIndow Instructions_15IDD
	if(V_Flag)
		DoWindow/F Instructions_15IDD
	else
		NewNotebook/N=$nb/F=1/V=1/K=1/W=(461,433,1223,1103)
		Notebook $nb defaultTab=36, statusWidth=252
		Notebook $nb showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
		Notebook $nb newRuler=Title, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",12,3,(0,0,0)}
		Notebook $nb ruler=Title, text="Instructions for use of 9IDC (15IDD) special configurations\r"
		Notebook $nb ruler=Normal, text="\r"
		Notebook $nb text="Decide which data you need to reduce. Instructions are setup specific:\r"
		Notebook $nb text="\r"
		Notebook $nb ruler=Title, text="SAXS \r"
		Notebook $nb ruler=Normal
		Notebook $nb text="You may be heloped by first reducing your USAXS data and process them to SMR waves, but it is not necess"
		Notebook $nb text="ary.\r"
		Notebook $nb text="1.\tSelect \"SAXS\" checkbox.\r"
		Notebook $nb text="2.\tPush \"Set default methods\" button to locate data folder and configure Nika settings common to all pin"
		Notebook $nb text="SAXS experiments.\r"
		Notebook $nb text="3.\tSelect one of the images from your SAXS measurements in the main 2D panel and double click it (or "
		Notebook $nb text="use button \"Ave & Display sel. file(s)\") to load \r"
		Notebook $nb text="3. \tUse \"Set Experiment Settings\"  button to read & set values from the wavenote of this file (These are"
		Notebook $nb text=" the most likely values for your experiment)\r"
		Notebook $nb text="4. \tOptiona;l: Verify the parameters (Beam center & calibration) using Ag Behenate measurements collecte"
		Notebook $nb text="d with your data & your notes (some NX file info could be stale)\r"
		Notebook $nb text="5. \tCreate mask to mask off the top few lines on detector using button: \"Create SAXS/WAXS m"
		Notebook $nb text="ask\"\r"
		Notebook $nb text="6.\tOptional : Either read slit length (button:\"Set Slit Length\") from one of USAXS measurements and sele"
		Notebook $nb text="ct \"Create Smeared Data\" (resulting data will be \"_usx\") - OR - unselect the \"Create Smeared Data\" (resu"
		Notebook $nb text="lting data will be \"_270_30\"). Likely choose \"Delete temp Data\" if you are creating slit smeared data.\r"
		Notebook $nb text="7. \tFind \"Empty\" (aka: Blank) file you want to use and load it in Nika (\"Emp/Dk\" tab). \r"
		Notebook $nb text="To process SAXS select the 2D data in the main panel and push button \"Convert sel. files 1 at time\"\r"
		Notebook $nb text="8. \tSelect data sets and reduce using \"Convert sel. files 1 at time\". This should create reasonable data"
		Notebook $nb text=" for SAXS if you have small-angle scattering. If you have diffraction peaks, select in \"Sectors\" tab "
		Notebook $nb text="checkbox \"Max num points\" and if you need it, select \"d?\" checkbox etc. \r"
		Notebook $nb text="   \r"
		Notebook $nb text="Merge \"_usx\" data using \"Data manipulation I\" tool from Irena package with USAXS slit smeared data or \"_"
		Notebook $nb text="270_30\" data with USAXS desmeared data. \r"
		Notebook $nb text="\r"
		Notebook $nb text="\r"
		Notebook $nb ruler=Title, text="WAXS\r"
		Notebook $nb ruler=Normal, text="1.\tSelect \"WAXS\" checkbox.\r"
		Notebook $nb text="2.\tPush \"Set default methods\" button to locate data folder and configure Nika settings common to all WAX"
		Notebook $nb text="S experiments.\r"
		Notebook $nb text="3.\tSelect one of the images from your WAXS measurements in the main 2D panel and double click it (or use"
		Notebook $nb text=" button \"Ave & Display sel. file(s)\") to load \r"
		Notebook $nb text="3. \tUse \"Set Experiment Settings\"  button to read & set values from the wavenote of this file (These are"
		Notebook $nb text=" the most likely values for your experiment)\r"
		Notebook $nb text="4. \tIf you have Empty (blank measurement) and are using Pilatus 200kw push \"WAXS use Blank\". "
		Notebook $nb text="Load Blank in the \"Empty/Dk\" tab and air scattering will be subtracted with proper normalization.\r"
		Notebook $nb text="5. \tCreate mask to mask off the joint lines on detector using button: \"Create SAXS/WAXS m"
		Notebook $nb text="ask\" This is useful only for Pilatus 200kw detector. \r"
		Notebook $nb text="6. \tSelect data sets and reduce using \"Convert sel. files 1 at time\". This should create reasonable data"
		Notebook $nb text=" for WAXS. It is not critical to correct for empty, but it will reduce air scattering background. You may need to modify the \"Sect"
		Notebook $nb text="ors\" tab settings depending if you want the output in Q or in d (or in Theta).  \r"
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

end

//************************************************************************************************************
//************************************************************************************************************

//Function NI1_15IDDCreateWvNtNbk(SampleName)
//	String SampleName
//	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
//	if(!WaveExists(w2D))		//hm, are we laoding the empty?
//		Wave/Z w2D = root:Packages:Convert2Dto1D:EmptyData
//	endif
//	if(WaveExists(w2d))
//		string OldNOte=note(w2D)
//		
//		string Instrument = StringByKey(NI1_15IDDFindKeyStr("instrument:name=", OldNote), OldNOte  , "=" , ";")		//USAXS
//		string Facility = StringByKey(NI1_15IDDFindKeyStr("facility_beamline=", OldNote), OldNOte  , "=" , ";")
//		variable i
//		String nb 	
//	//	if((stringMatch("15ID", )||stringMatch("9ID", StringByKey(NI1_15IDDFindKeyStr("facility_beamline=", OldNote), OldNOte  , "=" , ";"))) && stringMatch("Pilatus", StringByKey(NI1_15IDDFindKeyStr("model=", OldNote), OldNOte  , "=" , ";")))	
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


Function NI1_15IDDCreateSMRSAXSdata(listOfOrientations)	
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
			NI1_15IDDFIndSlitLength()
		endif
	
	NVAR Use2DdataName=root:Packages:Convert2Dto1D:Use2DdataName
	SVAR LoadedFile=root:Packages:Convert2Dto1D:FileNameToLoad
	SVAR UserFileName=root:Packages:Convert2Dto1D:OutputDataName
	SVAR TempOutputDataname=root:Packages:Convert2Dto1D:TempOutputDataname
	SVAR TempOutputDatanameUserFor=root:Packages:Convert2Dto1D:TempOutputDatanameUserFor
	SVAR UserSampleName=root:Packages:Convert2Dto1D:UserSampleName
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
		UseName=NI1A_TrimCleanDataName(UserSampleName)+"_"+CurOrient
		
	elseif(strlen(UserFileName)<1)	//user did not set the file name
		if(cmpstr(TempOutputDatanameUserFor,UserSampleName)==0 && strlen(TempOutputDataname)>0)		//this file output was already asked for user
				LocalUserFileName = TempOutputDataname
		else
				abort "could not figure out the names"	
		endif
		UseName=NI1A_TrimCleanDataName(LocalUserFileName)+"_"+CurOrient
	else
		UseName=NI1A_TrimCleanDataName(UserFileName)+"_"+CurOrient
	endif
	//UseName=cleanupName(UseName, 1 )
	String PinFolder="root:SAXS:"+possiblyQuoteName(UseName)
	String PinWaveNames=(UseName)

	CurOrient="VLp_0"
	if (Use2DdataName)
		//tempEnd=26-strlen(CurOrient)
		//UseName=LoadedFile[0,tempEnd]+"_"+CurOrient
		UseName=NI1A_TrimCleanDataName(UserSampleName)+"_"+CurOrient
	elseif(strlen(UserFileName)<1)	//user did not set the file name
		if(cmpstr(TempOutputDatanameUserFor,LoadedFile)==0 && strlen(TempOutputDataname)>0)		//this file output was already asked for user
				LocalUserFileName = TempOutputDataname
		else
				abort  "could not figure out the names"	
		endif
		//UseName=LocalUserFileName[0,18]+"_"+CurOrient
		UseName=NI1A_TrimCleanDataName(LocalUserFileName)+"_"+CurOrient
	else
		//UseName=UserFileName[0,18]+"_"+CurOrient
		UseName=NI1A_TrimCleanDataName(UserFileName)+"_"+CurOrient
	endif
	//UseName=cleanupName(UseName, 1 )
	String LIneProfFolder="root:SAXS:"+possiblyQuoteName(UseName)
	String LineProfWaveNames=(UseName)

	CurOrient="usx"
	if (Use2DdataName)
		//tempEnd=26-strlen(CurOrient)
		//UseName=LoadedFile[0,tempEnd]+"_"+CurOrient
		UseName=NI1A_TrimCleanDataName(UserSampleName)+"_"+CurOrient
	elseif(strlen(UserFileName)<1)	//user did nto set the file name
		if(cmpstr(TempOutputDatanameUserFor,LoadedFile)==0 && strlen(TempOutputDataname)>0)		//this file output was already asked for user
				LocalUserFileName = TempOutputDataname
		else
				abort  "could not figure out the names"	
		endif
		//UseName=LocalUserFileName[0,18]+"_"+CurOrient
		UseName=NI1A_TrimCleanDataName(LocalUserFileName)+"_"+CurOrient
	else
		//UseName=UserFileName[0,18]+"_"+CurOrient
		UseName=NI1A_TrimCleanDataName(UserFileName)+"_"+CurOrient
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

	Wave PinProfq= $(PinFolder+":"+possiblyQuoteName("q_"+PinWaveNames))
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

	DoWIndow LineuotDisplayPlot_Q
	if(V_Flag)
		DoWindow/F LineuotDisplayPlot_Q
		AppendToGraph /W=LineuotDisplayPlot_Q NewR vs NewQ
	endif	
	//now delete the data which user did not want...
	
	if(SAXSDeleteTempPinData)
		CheckDisplayed /W=LineuotDisplayPlot_Q  LineProfr
		if(V_Flag)
			removeFromGraph /W=LineuotDisplayPlot_Q $nameofWave(LineProfr)
		endif
		CheckDisplayed /W=LineuotDisplayPlot_Q  PinProfr
		if(V_Flag)
			removeFromGraph /W=LineuotDisplayPlot_Q $nameofWave(PinProfr)
		endif
		DoWIndow LineuotDisplayPlot_Q
		if(V_Flag)
			DoWindow/F LineuotDisplayPlot_Q
			IN2G_ColorTopGrphRainbow()
		endif	
		//removed, now delete folders...
		KillDataFolder/Z $PinFolder
		KillDataFolder/Z $LIneProfFolder
	endif
	SETDATAFOLDER OldDf
end