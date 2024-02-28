#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method.
//#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.23

//*************************************************************************\
//* Copyright (c) 2005 - 2023, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.23 adds support for ALS tilted detector geometry. written by Devin Grabner, Washington State University, modifed by JIL.
//1.22 added all options to mask reading of goldavergae command line, lots of options. 
//1.21 fixes to 12ID support, unexpected stuff in theor configuration file found. 
//version 1.2 adds support for 12ID-C SAXS camera with Gold detector
//version 1.1 adds support for ALS RSoXS data - sfot X-ray energy beamlione at ALS. 
//version 1.0 original release, Instrument support for SSRLMatSAXS
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//RSoXS support


Function NI1_RSoXSCreateGUI()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DoWIndow NI1A_Convert2Dto1DPanel
	if(!V_Flag)
		NI1A_Convert2Dto1DMainPanel()
	endif
	NI1_RSoXSInitialize()
	DoWIndow NI1_RSoXSMainPanel
	if(V_Flag)
		DoWIndow/F NI1_RSoXSMainPanel
	else
		NI1_RSoXSMainPanelFnct()
	endif
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function NI1_RSoXSFindI0File()
	variable refNum, i
	string LineContent
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR ColumnNamesLineNo = root:Packages:Nika_RSoXS:ColumnNamesLineNo
	SVAR I0ColumnLabels = root:Packages:Nika_RSoXS:I0ColumnLabels
	SVAR I0FileNamePath = root:Packages:Nika_RSoXS:I0FileNamePath
	Open /R /T=".txt" refNum 
	I0FileNamePath = S_fileName
	//it is opened for reading, now lets find the stuff we need.
	i=-1
	Do
		i+=1  //line we are reading now
		FReadLine  refNum, LineContent			
	while(!GrepString(LineContent, "TEY signal" ))		//line containing kyeword TEY signal
	close refNum
	ColumnNamesLineNo = i
	I0ColumnLabels = LineContent
	//convert lisyt separated by tabs in list with ;
	I0ColumnLabels = ReplaceString("\t", I0ColumnLabels, ";")
	I0ColumnLabels = ReplaceString(" ", I0ColumnLabels, "_")
	I0ColumnLabels = ReplaceString(")", I0ColumnLabels, "_")
	I0ColumnLabels = ReplaceString("(", I0ColumnLabels, "_")
	NI1_RSoXSSetPanelControls()
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function NI1_RSoXSSetPanelControls()
	DoWIndow RSoXSMainPanel
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if(V_Flag)
		SVAR I0DataToLoad=root:Packages:Nika_RSoXS:I0DataToLoad
		SVAR I0ColumnLabels=root:Packages:Nika_RSoXS:I0ColumnLabels
		SVAR PhotoDiodeDatatoLoad = root:Packages:Nika_RSoXS:PhotoDiodeDatatoLoad		
		PopupMenu I0DataToLoad,win=RSoXSMainPanel, mode=WhichListItem(I0DataToLoad, I0ColumnLabels)+1,value= #"root:Packages:Nika_RSoXS:I0ColumnLabels"
		PopupMenu PhotoDiodeDatatoLoad,win=RSoXSMainPanel, mode=WhichListItem(PhotoDiodeDatatoLoad, I0ColumnLabels)+1,value= #"root:Packages:Nika_RSoXS:I0ColumnLabels"
		
		
	endif

end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function NI1_RSoXSLoadI0()
	//this loads I0 records and deals with them. 
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf=getDataFOlder(1)
	setDataFolder root:Packages:Nika_RSoXS
	SVAR I0FileNamePath = root:Packages:Nika_RSoXS:I0FileNamePath
	SVAR I0DataToLoad=root:Packages:Nika_RSoXS:I0DataToLoad
	SVAR I0ColumnLabels=root:Packages:Nika_RSoXS:I0ColumnLabels
	SVAR PhotoDiodeDatatoLoad = root:Packages:Nika_RSoXS:PhotoDiodeDatatoLoad	
	NVAR ColumnNamesLineNo = root:Packages:Nika_RSoXS:ColumnNamesLineNo	
	NVAR PhotoDiodeOffset = root:Packages:Nika_RSoXS:PhotoDiodeOffset	
	NVAR I0Offset = root:Packages:Nika_RSoXS:I0Offset	

	LoadWave/L={ColumnNamesLineNo, ColumnNamesLineNo+1, 0, 0, 0}/J/W/A/O I0FileNamePath 
	//polarization is in the file... 
	Wave/Z EPU_Polarization = root:Packages:Nika_RSoXS:EPU_Polarization
	variable PolarizationLocal
	NVAR PolarizationValue = root:Packages:Nika_RSoXS:PolarizationValue
	if(!WaveExists(EPU_Polarization))
		abort "Loaded waves seem incorrect"
	else
		if(PolarizationValue<0)
			PolarizationLocal = EPU_Polarization[0]
		else
			PolarizationLocal = PolarizationValue
		endif
	endif
	//Calculate CorrectionFactor and display a graph for users, just in case
	Wave/Z Beamline_Energy=root:Packages:Nika_RSoXS:Beamline_Energy
	Wave/Z Photodiode=$("root:Packages:Nika_RSoXS:"+PhotoDiodeDatatoLoad)
	Wave/Z I0=$("root:Packages:Nika_RSoXS:"+I0DataToLoad)
	if(WaveExists(Beamline_Energy)&&WaveExists(Photodiode)&&WaveExists(I0))
//		KilLWIndow/Z I0andDiodeGraph
//		Display /K=1/W=(468,386,1003,727) I0 vs Beamline_Energy as "I0 and Diode"
//		DoWindow/C/R/T I0andDiodeGraph,"I0 and Diode"
//		AppendToGraph/R Photodiode vs Beamline_Energy
//		ModifyGraph mode=3
//		ModifyGraph marker(Photodiode)=41
//		ModifyGraph rgb(Photodiode)=(0,0,65535)
//		ModifyGraph mirror(bottom)=1
//		Label left "I0"
//		Label bottom "Beamline energy [eV]"
//		Label right "Diode"
		//calcualte correction factor here for now.
		Duplicate/O Photodiode, CorrectionFactor
		CorrectionFactor=(Photodiode-PhotoDiodeOffset) * 2.4e10	/ Beamline_Energy / (I0-I0Offset)			//per instructions  

		//Duplicate these data to proper 	wave
		Wave/Z CorrectionFactor=root:Packages:Nika_RSoXS:CorrectionFactor
		Duplicate/O Beamline_Energy, $("root:Packages:Nika_RSoXS:Beamline_Energy"+"_pol"+num2str(PolarizationLocal))
		Duplicate/O CorrectionFactor, $("root:Packages:Nika_RSoXS:CorrectionFactor"+"_pol"+num2str(PolarizationLocal))
		Wave Beamline_Energy = $("root:Packages:Nika_RSoXS:Beamline_Energy"+"_pol"+num2str(PolarizationLocal))
		Wave CorrectionFactor = $("root:Packages:Nika_RSoXS:CorrectionFactor"+"_pol"+num2str(PolarizationLocal))

		KilLWIndow/Z $("CorrectionGraph_P"+num2str(PolarizationLocal))
		Display /K=1/W=(468,386,1003,727) CorrectionFactor vs Beamline_Energy as "CorrectionFactor Polarization "+num2str(PolarizationLocal)
		DoWindow/C/R $("CorrectionGraph_P"+num2str(PolarizationLocal))
		ModifyGraph mirror=1
		Label left "CorrectionGraph"
		Label bottom "Beamline energy [eV]"
	else
		DoAlert /T="Did not find data" 0, "Please check wave names selections" 
	endif
	
	
	setDataFolder OldDf
end


//************************************************************************************************************
Function NI1_RSoXSFindCorrectionFactor(SampleName)
	string sampleName

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Image file not found "  
	endif
	string OldNOte=note(w2D)
	//Mono Energy

	//root:Packages:Convert2Dto1D:CorrectionFactor
	variable Energy = NumberByKey("Mono Energy", OldNote , "=" , ";")
	variable result = 10/Energy
	print "Set Calibration Constant to 10/energy = "+num2str(result)
	return result
end


//************************************************************************************************************
//************************************************************************************************************
Function NI1_RSoXSFindNormalFactor(SampleName)
	string sampleName

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Wave/Z w2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(w2D))
		Abort "Image file not found "  
	endif
	string OldNOte=note(w2D)
	//Mono Energy
	variable Energy = NumberByKey("Mono Energy", OldNote , "=" , ";")
	variable PolarizationLocal = NumberByKey("EPU Polarization", OldNote , "=" , ";")
	SVAR I0DataToLoad = root:Packages:Nika_RSoXS:I0DataToLoad
	I0DataToLoad = ReplaceString("_", I0DataToLoad, " ")
	variable SampleI0 = NumberByKey(I0DataToLoad, OldNote , "=" , ";")
	variable SampleExposure = NumberByKey("EXPOSURE", OldNote , "=" , ";")
	print "Sample I0 value is = "+num2str(SampleI0)
	Wave/Z CorrectionFactor=$("root:Packages:Nika_RSoXS:CorrectionFactor_pol"+num2str(PolarizationLocal))
	Wave/Z Beamline_Energy=$("root:Packages:Nika_RSoXS:Beamline_Energy_pol"+num2str(PolarizationLocal))
	if(!WaveExists(Beamline_Energy)||!WaveExists(CorrectionFactor))
		abort "Did not find Correction factor values, cannot continue"
	endif
	variable result = SampleExposure*SampleI0*CorrectionFactor[BinarySearchInterp(Beamline_Energy, Energy )]
	print "Read Exposure time and I0 from image and Correction factor from file : CorrectionFactor_pol"+num2str(PolarizationLocal)+"  and got value = "+num2str(result)
	return result
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function NI1_RSoXSInitialize()

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf=GetDataFolder(1)
	newDataFOlder/O root:Packages
	newDataFolder/O/S root:Packages:Nika_RSoXS
	
	string/g ListOfVariables
	string/g ListOfStrings

	ListOfVariables="UseRSoXSCodeModifications;"
	ListOfVariables+="ColumnNamesLineNo;OrderSorterValue;PolarizationValue;PhotoDiodeOffset;I0Offset;"
	ListOfVariables+="ALSRotAxisToSampleDist;"
	ListOfStrings="I0DataToLoad;PhotoDiodeDataToLoad;I0ColumnLabels;I0FileNamePath;"
	
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	
	SVAR I0ColumnLabels
	if(strlen(I0ColumnLabels)<3)
		I0ColumnLabels="---;"
	endif
	SVAR I0DataToLoad
	SVAR PhotoDiodeDataToLoad
	if(strlen(I0DataToLoad)<3)
		I0DataToLoad="AI_3_Izero"
	endif
	if(strlen(PhotoDiodeDataToLoad)<3)
		PhotoDiodeDataToLoad="Photodiode"
	endif
	NVAR PolarizationValue
	if(PolarizationValue==0)
		PolarizationValue=-1
	endif
	
	
	
	setDataFolder OldDf
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function NI1_RSoXSMainPanelFnct() : Panel
	PauseUpdate    		// building window...
	NewPanel /K=1/W=(464,54,908,300) as "RSoXS Data reduction panel"
	DoWIndow/C NI1_RSoXSMainPanel
	SetDrawLayer UserBack
	SetDrawEnv fstyle= 3,textrgb= (0,0,65535)
	DrawText 70,31,"\\Zr125Controls for RSoXS Data reduction"
	CheckBox UseRSoXSCodeModifications,pos={12.00,42.00},size={124.00,16.00},proc=NI1_RSoXSCheckProc,title="Use RSoXS modifications"
	CheckBox UseRSoXSCodeModifications,variable= root:Packages:Nika_RSoXS:UseRSoXSCodeModifications
	Button FindI0DataFile,pos={219.00,35.00},size={182.00,23.00},proc=NI1_RSoXSButtonProc,title="Find I0 Data file"
	Button FindI0DataFile,help={"Locate I0 containing text file and check teh content. "}
	SetVariable PolarizationValue,pos={45.00,129.00},size={151.00,15.00},bodyWidth=70,proc=NI1_RSoXSSetVarProc,title="Polarization Value"
	SetVariable PolarizationValue,help={"Polarization value, -1 reads from the file"}
	SetVariable PolarizationValue,limits={-1,360,1},value= root:Packages:Nika_RSoXS:PolarizationValue
	SetVariable ColumnNamesLineNo,pos={16.00,87.00},size={180.00,15.00},bodyWidth=70,proc=NI1_RSoXSSetVarProc,title="Line with Column Names"
	SetVariable ColumnNamesLineNo,help={"No of column with names"}
	SetVariable ColumnNamesLineNo,limits={0,inf,1},value= root:Packages:Nika_RSoXS:ColumnNamesLineNo
	SetVariable OrderSorterValue,pos={41.00,107.00},size={155.00,15.00},bodyWidth=70,proc=NI1_RSoXSSetVarProc,title="Order Sorter Value"
	SetVariable OrderSorterValue,help={"Order sorter value"}
	SetVariable OrderSorterValue,limits={0,inf,1},value= root:Packages:Nika_RSoXS:OrderSorterValue
	PopupMenu I0DataToLoad,pos={229.00,83.00},size={167.00,23.00},bodyWidth=100,proc=NI1_RSoXSPopMenuProc,title="I0 data to load"
	PopupMenu I0DataToLoad,help={"Which column contains I0 data?"}
	PopupMenu I0DataToLoad,mode=1,popvalue="AI_3_Izero",value= #"root:Packages:Nika_RSoXS:I0ColumnLabels"
	PopupMenu PhotoDiodeDatatoLoad,pos={214.00,110.00},size={183.00,23.00},bodyWidth=100,proc=NI1_RSoXSPopMenuProc,title="Diode data to load"
	PopupMenu PhotoDiodeDatatoLoad,help={"Which Column contains diode data?"}
	PopupMenu PhotoDiodeDatatoLoad,mode=1,popvalue="Photodiode",value= #"root:Packages:Nika_RSoXS:I0ColumnLabels"
	SetVariable PhotoDiodeOffset,pos={44.00,148.00},size={152.00,15.00},bodyWidth=70,proc=NI1_RSoXSSetVarProc,title="Photodiode offset"
	SetVariable PhotoDiodeOffset,help={"Diode offset intensity - dark current"}
	SetVariable PhotoDiodeOffset,limits={0,inf,1},value= root:Packages:Nika_RSoXS:PhotoDiodeOffset
	SetVariable I0Offset,pos={85.00,168.00},size={111.00,15.00},bodyWidth=70,proc=NI1_RSoXSSetVarProc,title="I0 offset"
	SetVariable I0Offset,help={"I0 offset intensity - dark current"}
	SetVariable I0Offset,limits={0,inf,1},value= root:Packages:Nika_RSoXS:I0Offset
	Button LoadI0Data,pos={222.00,153.00},size={174.00,29.00},proc=NI1_RSoXSButtonProc,title="Load and display I0 data"
	Button LoadI0Data,help={"This will read I0 data from the file and display a graph. It overwrtites any prior I0 data. "}
	SetVariable I0FileNamePath,pos={19.00,63.00},size={385.00,15.00},bodyWidth=351,disable=2,proc=NI1_RSoXSSetVarProc,title="I0 file: "
	SetVariable I0FileNamePath,help={"No of column with names"},frame=0
	SetVariable I0FileNamePath,limits={0,inf,1},value= root:Packages:Nika_RSoXS:I0FileNamePath,noedit= 1

	SetVariable RotAxToSaDis,pos={85.00,194},size={111,15.00},bodyWidth=70,proc=NI1_RSoXSSetVarProc,title="Rot axis to Sa dist: "
	SetVariable RotAxToSaDis,help={"ALS geometry - rotation axis to sample distacnce, mm"},frame=1
	SetVariable RotAxToSaDis,limits={0,inf,0.1},value=root:Packages:Nika_RSoXS:ALSRotAxisToSampleDist

EndMacro


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function NI1_RSoXSCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(stringmatch(cba.ctrlName,"UseRSoXSCodeModifications"))
				//do what needs to be done when we are using this code...
				if(checked)
					NI1_RSoXSConfigureNika()
					NI1_RSoXSGenerateHelpNbk()
				else
					KillWIndow/Z RSoXS_Instructions
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
//************************************************************************************************************
//************************************************************************************************************
Function NI1_RSoXSGenerateHelpNbk()

	DoWIndow RSoXS_Instructions
	if(V_Flag)
		DoWIndow/F RSoXS_Instructions
	else
		String nb = "RSoXS_Instructions"
		NewNotebook/N=$nb/F=1/V=1/K=1/ENCG={2,1}/W=(455,300,1300,1000)
		Notebook $nb defaultTab=36
		Notebook $nb showRuler=1, rulerUnits=2, updating={1, 1}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Helvetica",11,0,(0,0,0)}
		Notebook $nb ruler=Normal, fStyle=1, text="Basic user instructions for RSoXS Data reduction panel\r"
		Notebook $nb fStyle=-1, text="\r"
		Notebook $nb text="Setting up 'Main 2D to 1D conversion panel'\r"
		Notebook $nb text="1) Select 'Use RSoXS modifications' on the 'RSoXS Data reduction panel'. This will initialize basic sett"
		Notebook $nb text="ings for RSoXS data reduction. \r"
		Notebook $nb text="\r"
		Notebook $nb text="2) Load I0 reference by selecting 'Find I0 Data file' on the 'RSoXS Data reduction panel'. Navigate to t"
		Notebook $nb text="he desired text file and double click to select. 'Line with Column Names' should automatically fill in t"
		Notebook $nb text="o be 15 and the Polarization Value will be set to -1 (This will read the polarization from the I0 file u"
		Notebook $nb text="nder the 'EPU Polarization' header. Otherwise you can manually set a value here). Select an I0 monitor t"
		Notebook $nb text="o be used under 'I0 data to load' (Ai_3_Izero is the default) and the 'Diode data to load' will be autom"
		Notebook $nb text="atically set as 'Photodiode'. Offsets for Photodiode and I0 energies are available for advanced users.\r"
		Notebook $nb text="\r"
		Notebook $nb text="Select 'Load and display I0 data' to store the correction factor for a given polarization. Repeat with a"
		Notebook $nb text="s many I0s as you require. Correction factors will be overwritten upon importing a new I0 with repeat po"
		Notebook $nb text="larization value.\r"
		Notebook $nb text="\r"
		Notebook $nb text="3) On the 'Main 2D to 1D conversion panel' select Em/Dk and locate appropriate RSoXS data for dark backg"
		Notebook $nb text="round subtraction. For a given data series, select a scan corresponding to each exposure time and click "
		Notebook $nb text="'Load Dark Field.' When loading an image the exposure time will be read in the file header and matched w"
		Notebook $nb text="ith an appropriate dark for subtraction.\r"
		Notebook $nb text="\r"
		Notebook $nb text="4) On the 'Main 2D to 1D conversion panel' click 'Select data path' and navigate to the folder containin"
		Notebook $nb text="g RSoXS data. \r"
		Notebook $nb text="\r"
		Notebook $nb text="Final user options before data reduction\r"
		Notebook $nb text="From here, it is up to the user to decide on an appropriate mask, geometry, and sector averages for the "
		Notebook $nb text="given file to be imported.\r"
		Notebook $nb text="\r"
		Notebook $nb text="Creating a mask: Under the 'SAS 2D' menu select 'Create Mask' and follow instructions from the NIKA user"
		Notebook $nb text=" manual. On the 'Main 2D to 1D conversion panel' be sure to select 'Use Mask' under the 'Mask' tab.\r"
		Notebook $nb text="\r"
		Notebook $nb text="Beam center and geometry refinement: Under the 'SAS 2D' menu select 'Beam centering and geometry cor.' a"
		Notebook $nb text="nd follow instructions from the NIKA user manual.\r"
		Notebook $nb text="\r"
		Notebook $nb text="Sectors: On the 'Main 2D to 1D conversion panel' select 'Sect.' and check the box 'Use?' Basic data redu"
		Notebook $nb text="ction will have the following boxes checked: 'Do Circular Average?', 'Create 1D graph', 'Store data in I"
		Notebook $nb text="gor experiment', 'Overwrite Existing data if exist?', and 'Use input data name for output?'.\r"
		Notebook $nb text="\r"
		Notebook $nb text="Processing data\r"
		Notebook $nb text="Finally, to process data: click 'Process sel, files individually', select one or more images in the list"
		Notebook $nb text="box on the 'Main 2D to 1D conversion panel', and click 'Process image(s)'"
		Notebook $nb selection={startOfFile, startOfFile }, findText={"",1}		
	endif
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function NI1_RSoXSSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			if(stringMatch(sva.ctrlName,"ColumnNamesLineNo"))
					//do something
			endif
			if(stringMatch(sva.ctrlName,"OrderSorterValue"))
					//do something
			endif
			if(stringMatch(sva.ctrlName,"PolarizationValue"))
					//do something
			endif
			if(stringMatch(sva.ctrlName,"PhotoDiodeOffset"))
					//do something
			endif
			if(stringMatch(sva.ctrlName,"I0Offset"))
					//do something
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
//************************************************************************************************************
Function NI1_RSoXSButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(StringMatch(ba.ctrlName,"FindI0DataFile"))
				//FInd the I0 text file. 
				NI1_RSoXSFindI0File()
			endif
			if(StringMatch(ba.ctrlName,"LoadI0Data"))
				//FInd the I0 text file. 
				NI1_RSoXSLoadI0()
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
//************************************************************************************************************
Function NI1_RSoXSPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(Stringmatch(pa.ctrlname,"I0DataToLoad"))
				SVAR I0DataToLoad=root:Packages:Nika_RSoXS:I0DataToLoad
				I0DataToLoad= popStr
			
			endif
			if(Stringmatch(pa.ctrlname,"PhotoDiodeDatatoLoad"))
				SVAR PhotoDiodeDatatoLoad = root:Packages:Nika_RSoXS:PhotoDiodeDatatoLoad
				PhotoDiodeDatatoLoad = popStr
			endif


			break
		case -1: // control being killed
			break
	endswitch

	return 0
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function NI1_RSoXSConfigureNika()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

//				NVAR UseSampleTransmission = root:Packages:Convert2Dto1D:UseSampleTransmission
//				NVAR UseEmptyField = root:Packages:Convert2Dto1D:UseEmptyField
				NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate
				NVAR DoGeometryCorrection = root:Packages:Convert2Dto1D:DoGeometryCorrection
//				NVAR UseMonitorForEf = root:Packages:Convert2Dto1D:UseMonitorForEf
//				NVAR UseSampleTransmFnct = root:Packages:Convert2Dto1D:UseSampleTransmFnct
				NVAR UseSampleMonitorFnct = root:Packages:Convert2Dto1D:UseSampleMonitorFnct
//				NVAR UseEmptyMonitorFnct = root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
				NVAR UseSampleCorrectFnct = root:Packages:Convert2Dto1D:UseSampleCorrectFnct
				NVAR UseCorrectionFactor = root:Packages:Convert2Dto1D:UseCorrectionFactor
				NVAR UseDarkField = root:Packages:Convert2Dto1D:UseDarkField
				NVAR UseSampleMeasTime = root:Packages:Convert2Dto1D:UseSampleMeasTime
				NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX
				NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY
				
				SVAR DataFileExtension=root:Packages:Convert2Dto1D:DataFileExtension
				SVAR BlankFileExtension=root:Packages:Convert2Dto1D:BlankFileExtension
				DataFileExtension="FITS"
				BlankFileExtension="FITS"
				DoWIndow NI1A_Convert2Dto1DPanel
				if(V_Flag)
					SVAR ListOfKnownExtensions = root:Packages:Convert2Dto1D:ListOfKnownExtensions
					PopupMenu Select2DDataType,win=NI1A_Convert2Dto1DPanel,popvalue=DataFileExtension,value= #"root:Packages:Convert2Dto1D:ListOfKnownExtensions"
					PopupMenu Select2DDataType,win=NI1A_Convert2Dto1DPanel, mode=WhichListItem(DataFileExtension, ListOfKnownExtensions)+1
				endif
				
				PixelSizeX = 0.027
				PixelSizeY = 0.027
				UseSampleCorrectFnct = 1
				UseCorrectionFactor = 1
				UseSampleMeasTime=0
				UseDarkField = 1
//				UseSampleThickness = 1			
//				UseSampleTransmission = 1
//				UseEmptyField = 1
				UseI0ToCalibrate = 1
				DoGeometryCorrection = 1
//				UseMonitorForEf = 1
//				UseSampleTransmFnct = 1
				UseSampleMonitorFnct = 1
//				UseEmptyMonitorFnct = 1
//				UseSampleThicknFnct = 1 

				SVAR SampleCorrectFnct = root:Packages:Convert2Dto1D:SampleCorrectFnct
				SVAR SampleMonitorFnct = root:Packages:Convert2Dto1D:SampleMonitorFnct
				SVAR EmptyMonitorFnct = root:Packages:Convert2Dto1D:EmptyMonitorFnct
				SVAR SampleThicknFnct = root:Packages:Convert2Dto1D:SampleThicknFnct
				
				SampleCorrectFnct = "NI1_RSoXSFindCorrectionFactor"
				SampleMonitorFnct = "NI1_RSoXSFindNormalFactor"
//				EmptyMonitorFnct = "NI1_9IDCSFindEfI0"
//				SampleThicknFnct = "NI1_9IDCSFindThickness"

end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function NI1_RSoXSCopyDarkOnImport()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Wave/Z DarkFieldData=root:Packages:Convert2Dto1D:DarkFieldData
	if(WaveExists(DarkFieldData))
		string oldNote=note(DarkFieldData)
		variable ExposureTime = NumberByKey("EXPOSURE", OldNote , "=" , ";")
		Duplicate/O DarkFieldData, $("DarkFieldData_"+ReplaceString(".", num2str(ExposureTime),"p"))
		print "Imported Dark field and stored as :"+("DarkFieldData_"+ReplaceString(".", num2str(ExposureTime),"p"))
	else
		abort "Dark data to store do not exist"
	endif

end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function NI1_RSoXSRestoreDarkOnImport()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Wave CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	string SampleNote=note(CCDImageToConvert)
	variable SampleTime=NumberByKey("EXPOSURE", SampleNote , "=" , ";")
	string ExpectedDarkname="DarkFieldData_"+ReplaceString(".", num2str(SampleTime),"p")
	Wave/Z DarkFieldData=$("root:Packages:Convert2Dto1D:"+ExpectedDarkname)
	if(WaveExists(DarkFieldData))
		Duplicate/O DarkFieldData, $("DarkFieldData")
		//string oldNote=note(DarkFieldData)
		//variable ExposureTime = NumberByKey("EXPOSURE", OldNote , "=" , ";")
		//Duplicate/O DarkFieldData, $("DarkFieldData_"+ReplaceString(".", num2str(ExposureTime),"p"))
		print "Restored Dark field from file : "+ExpectedDarkname
	else
		abort "Dark data with needed Exposure time : "+num2str(SampleTime)+" do not exist"
	endif

end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function NI1_RSoXSLoadHeaderValues()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Wave CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	string SampleNote=note(CCDImageToConvert)
	variable SampleTime=NumberByKey("EXPOSURE", SampleNote , "=" , ";")
	variable Energy=NumberByKey("Beamline Energy", SampleNote , "=" , ";")
	variable Wavelength=12.3984/(Energy/1000)
	NVAR WV = root:Packages:Convert2Dto1D:Wavelength
	NVAR En = root:Packages:Convert2Dto1D:XrayEnergy
	En= Energy/1000
	Wv= Wavelength
	NVAR SampleMeasurementTime = root:Packages:Convert2Dto1D:SampleMeasurementTime
	SampleMeasurementTime = SampleTime 
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////
//
// Written by Devin Grabner, Washington State University, Nov 2023
//					********* LAST UPDATED: 24 Jan 2024  *************
// Modified by Jan Ilavsky, February 28, 2024
// 
//	If you have any further questions please contact Devin Grabner (devin.grabner@wsu.edu) or 
//		Brian Collins (brian.collins@wsu.edu) for more information.
//
// Function NI1A_Create2DQWave(DataWave) is from NIKA "NI1_ConvProc" 
// Use this to overload the NIKA function for calculating the QMap for the CCD
//		image and applying an appropriate Solid Angle Correction. This function allows for a rotated
//		CCD Geometry where the sample doesn't have to be located at the axis of rotation of the CCD.
//
// The additional parameters needed are not currently in NIKA
//
// d1 = Distance from axis of rotation to sample (mm)
//				A postive number is assuming the sample is in front of the CCD axis of rotation
//				This is ALS specific parameter and is set in "Instrument configurations" -> "RSoXS ALS soft enery instrument" dialog. 
//
// d2 = Sample - Detector distance (mm)
//			This is using Sample Detector Distance in the 2D to 1D Data
//	
////////////////////////////////////////////////////////////////////////////////////////////


Function NI1A_Create2DQWaveALS(DataWave)
	Wave DataWave
	string OldDf=GetDataFolder(1)
	
	//	Wave/Z Param_Values = root:Param_Values
		
	//	if(WaveExists(Param_Values) == 0)
	//		print "Making Needed Paramater Waves with Default Values"
	//		setDataFolder root
	//		Make/T/N=2 Param_Names = {"Distance from axis of rotation to sample (mm)", "Sample - Detector distance (mm)"}
	//		Make/S/N=2 Param_Values = {26, 23}
	//		
	//		Wave/Z Param_Values = root:Param_Values
	//	endif
	//	
	NVAR ALSRotAxisToSampleDist=root:Packages:Nika_RSoXS:ALSRotAxisToSampleDist	
	NVAR SDD=root:Packages:Convert2Dto1D:SampleToCCDDistance
	Variable d1 = ALSRotAxisToSampleDist 		// Distance from axis of rotation to sample (mm)
	Variable d2 = SDD							 	// Sample - Detector distance (mm)

	SVAR header = root:Packages:Nika_RSoXS:NRS_Vars:header
	variable phi = str2num(Stringbykey("CCD Theta",header,"=",";")) // Angle the CCD is rotated to (Input: degrees)
	
	// Because of the tan(x) and arctan(x) function it has a hard time handeling exactly 0 and 90 degrees.
	// so this statment moves it just slightly of so the calculation works.
	if (phi == 0)
		phi = (1e-11)
	elseif (phi == 90)
		phi = 89.9999999
	endif
	
	phi = phi * (pi/180) // Convert to radians
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	setDataFolder root:Packages:Convert2Dto1D
	
	Wave/Z Q2DWave
	string NoteStr
	NoteStr = note(DataWave)
	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength							//in A
	NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX							//in millimeters
	NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY							//in millimeters
	NVAR beamCenterX=root:Packages:Convert2Dto1D:beamCenterX
	NVAR beamCenterY=root:Packages:Convert2Dto1D:beamCenterY
	
	Variable C = BeamCenterY*PixelSizeY	//Distance from the beam center in normal incidence to bottom of the CCD (mm)

	print "Creating 2D Q wave"
	//Create wave for q distribution
	MatrixOp/O/NTHR=0 Q2DWave=DataWave
	Redimension/S Q2DWave

	Duplicate/FREE Q2DWave, a, b
	
	multithread a = (d1+d2)*sec(phi)-d1-(((q+0.5)*PixelSizeY)+(d1+d2)*tan(phi)-C)*sin(phi)		
	multithread b = ((((q+0.5)*PixelSizeY)+(d1+d2)*tan(phi)-C)*cos(phi))^2 + ((p - BeamCenterX + 0.5)*PixelSizeX)^2

	MatrixOP/O Q2DWave = (2*pi*sqrt(2)/Wavelength)*sqrt(1-a/sqrt(sq(a)+b))
	
	NoteStr = ReplaceStringByKey("BeamCenterX", NoteStr, num2str(BeamCenterX), "=", ";")
	NoteStr = ReplaceStringByKey("BeamCenterY", NoteStr, num2str(BeamCenterY), "=", ";")
	NoteStr = ReplaceStringByKey("PixelSizeX", NoteStr, num2str(PixelSizeX), "=", ";")
	NoteStr = ReplaceStringByKey("PixelSizeY", NoteStr, num2str(PixelSizeY), "=", ";")
	NoteStr = ReplaceStringByKey("Wavelength", NoteStr, num2str(Wavelength), "=", ";")
	note/K Q2DWave, NoteStr
	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_CorrectDataPerUserReqA(orientation)
	string orientation
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf = GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D

	SVAR CalibrationFormula=root:Packages:Convert2Dto1D:CalibrationFormula
	NVAR UseSampleThickness= root:Packages:Convert2Dto1D:UseSampleThickness
	NVAR UseSampleTransmission= root:Packages:Convert2Dto1D:UseSampleTransmission
	NVAR UseCorrectionFactor= root:Packages:Convert2Dto1D:UseCorrectionFactor
	NVAR UseSolidAngle=root:Packages:Convert2Dto1D:UseSolidAngle
	NVAR UseMask= root:Packages:Convert2Dto1D:UseMask
	NVAR UseDarkField= root:Packages:Convert2Dto1D:UseDarkField
	NVAR UseEmptyField= root:Packages:Convert2Dto1D:UseEmptyField
	NVAR UseSubtractFixedOffset= root:Packages:Convert2Dto1D:UseSubtractFixedOffset
	NVAR UseSampleMeasTime= root:Packages:Convert2Dto1D:UseSampleMeasTime
	NVAR UseEmptyMeasTime= root:Packages:Convert2Dto1D:UseEmptyMeasTime
	NVAR UseDarkMeasTime= root:Packages:Convert2Dto1D:UseDarkMeasTime
	NVAR UsePixelSensitivity= root:Packages:Convert2Dto1D:UsePixelSensitivity
	NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate
	NVAR UseMonitorForEF = root:Packages:Convert2Dto1D:UseMonitorForEF
	
	NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
	NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance
	
	NVAR CorrectionFactor = root:Packages:Convert2Dto1D:CorrectionFactor
	NVAR SampleI0 = root:Packages:Convert2Dto1D:SampleI0
	NVAR EmptyI0 = root:Packages:Convert2Dto1D:EmptyI0
	NVAR SampleThickness = root:Packages:Convert2Dto1D:SampleThickness
	NVAR SampleTransmission = root:Packages:Convert2Dto1D:SampleTransmission
	NVAR SampleMeasurementTime = root:Packages:Convert2Dto1D:SampleMeasurementTime
	NVAR BackgroundMeasTime = root:Packages:Convert2Dto1D:BackgroundMeasTime
	NVAR EmptyMeasurementTime = root:Packages:Convert2Dto1D:EmptyMeasurementTime
	NVAR SubtractFixedOffset = root:Packages:Convert2Dto1D:SubtractFixedOffset
	NVAR CorrectSelfAbsorption = root:Packages:Convert2Dto1D:CorrectSelfAbsorption
	
	NVAR DoGeometryCorrection=root:Packages:Convert2Dto1D:DoGeometryCorrection

	NVAR Use2DPolarizationCor = root:Packages:Convert2Dto1D:Use2DPolarizationCor
	NVAR DoPolarizationCorrection = root:Packages:Convert2Dto1D:DoPolarizationCorrection

	NVAR UseCalib2DData=root:Packages:Convert2Dto1D:UseCalib2DData
	
	Wave DataWave=root:Packages:Convert2Dto1D:CCDImageToConvert
	Wave/Z EmptyRunWave=root:Packages:Convert2Dto1D:EmptyData
	Wave/Z DarkCurrentWave=root:Packages:Convert2Dto1D:DarkFieldData
	Wave/Z MaskWave=root:Packages:Convert2Dto1D:M_ROIMask
	Wave/Z Pix2DSensitivity=root:Packages:Convert2Dto1D:Pixel2DSensitivity
	//little checking here...
	if(UseMask)
		if(!WaveExists(MaskWave) || DimSize(MaskWave, 0)!=DimSize(DataWave, 0) || DimSize(MaskWave, 1)!=DimSize(DataWave, 1))
			abort "Mask problem - either does not exist or has differnet dimensions that data "
		endif
	endif
	if(UseDarkField&&!UseCalib2DData)
		if(!WaveExists(DarkCurrentWave) || DimSize(DarkCurrentWave, 0)!=DimSize(DataWave, 0) || DimSize(DarkCurrentWave, 1)!=DimSize(DataWave, 1))
			abort "Dark field problem - either does not exist or has differnet dimensions that data "
		endif
	endif

	Duplicate/O DataWave,  Calibrated2DDataSet, CalibrationPrefactor
	
	Wave Calibrated2DDataSet=root:Packages:Convert2Dto1D:Calibrated2DDataSet
	redimension/S Calibrated2DDataSet
	string OldNote=note(Calibrated2DDataSet)

	variable tempVal
	MatrixOP/O CalibrationPrefactor = CalibrationPrefactor * 0
	MatrixOP/O CalibrationPrefactor = CalibrationPrefactor + 1 // Sets the whole matrix equal to 1
	
	if(!UseCalib2DData)
		if(UseCorrectionFactor)
			//MatrixOP/O CalibrationPrefactor = CalibrationPrefactor * CorrectionFactor
		endif
		if(UseSolidAngle)
			Duplicate/O CalibrationPrefactor, SolidAngle
			WAVE SolidAngle = IN2_SolidAngleCorrectionALS(CalibrationPrefactor)
			MatrixOP/O CalibrationPrefactor = CalibrationPrefactor*SolidAngle
		endif
		if(UseI0ToCalibrate)
			MatrixOP/O CalibrationPrefactor = CalibrationPrefactor / SampleI0
		endif
		if(UseSampleThickness)
			MatrixOP/O CalibrationPrefactor = CalibrationPrefactor / (SampleThickness/10)		//NOTE: changed in ver 1.75 (1/2017), previously was not converted to cm.
			//this is potentially breaking calibration of prior experiments. Need User warning! 
		endif
	
		Duplicate/O DataWave, tempDataWv, tempEmptyField
		redimension/S tempDataWv, tempEmptyField
		
		if(UsePixelSensitivity)
			MatrixOP/O  tempDataWv=tempDataWv/Pix2DSensitivity
		endif
		if(UseDarkField)
			if(UseSampleMeasTime && UseDarkMeasTime)
				if(UsePixelSensitivity)
					tempVal = SampleMeasurementTime/BackgroundMeasTime
					MatrixOP/O  tempDataWv = tempDataWv - (tempVal*DarkCurrentWave/Pix2DSensitivity)
				else
					tempVal = SampleMeasurementTime/BackgroundMeasTime
					MatrixOP/O  tempDataWv = tempDataWv - (tempVal*DarkCurrentWave)
				endif
			else
				if(UsePixelSensitivity)
					MatrixOP/O  tempDataWv = tempDataWv - (DarkCurrentWave/Pix2DSensitivity)
				else
					MatrixOP/O  tempDataWv = tempDataWv - DarkCurrentWave
				endif
			endif
		endif
		if(UseSubtractFixedOffset)
			MatrixOP/O  tempDataWv = tempDataWv - SubtractFixedOffset
		endif
		if(UseSampleTransmission)
			//this is normal correcting by one transmission. 
			MatrixOP/O  tempDataWv=tempDataWv/SampleTransmission
			if(CorrectSelfAbsorption && SampleTransmission<1)
				variable MuCalc=-1*ln(SampleTransmission)/SampleThickness
				variable muD = MuCalc*SampleThickness
				Wave Theta2DWave = root:Packages:Convert2Dto1D:Theta2DWave		//this is actually Theta in radians. 
				if(DimSize(Theta2DWave, 0 )!=DimSize(tempDataWv, 0) || DimSize(Theta2DWave, 1)!=DimSize(tempDataWv, 1) )
					NI1A_Create2DQWave(tempDataWv)				//creates 2-D Q wave does not need to be run always...
					NI1A_Create2DAngleWave(tempDataWv)			//creates 2-D Azimuth Angle wave does not need to be run always...
				endif 	
				MatrixOP/free  SelfAbsorption2D=tempDataWv
				//next is formula 29, chapter 3.4.7 Brain Pauw paper
				MatrixOp/Free  MuDdivCos2TH=MuD*rec(cos(2*Theta2DWave))
				MatrixOp/Free  OneOverBottomPart = rec( -1*MuDdivCos2TH + MuD)
				variable expmud=exp(muD)
				variable expNmud=exp(-1*MuD)
				MatrixOP/O  SelfAbsorption2D=expmud * (exp(-MuDdivCos2TH) - expNmud) * OneOverBottomPart
				//replace nans around center... 
				MatrixOP/O  SelfAbsorption2D=replaceNaNs(SelfAbsorption2D,1)
				//and now correct... 
				MatrixOP/O  tempDataWv=tempDataWv / SelfAbsorption2D
				if(IrenaDebugLevel>1)
					variable MaxCorrection
					wavestats SelfAbsorption2D
					MaxCorrection = 1/wavemin(SelfAbsorption2D)
					print "Sample self absorption correction max is : "+num2str(MaxCorrection) 
				endif
			else
				//print "Could not do corection for self absorption, wrong parameters" 
			endif
		endif
		tempEmptyField=0
		variable ScalingConstEF=1
	
		if(UseEmptyField)
			tempEmptyField = EmptyRunWave
			if(UsePixelSensitivity)
				MatrixOP/O  tempEmptyField = tempEmptyField/Pix2DSensitivity
			endif
			if(UseSubtractFixedOffset)
				MatrixOP/O  tempEmptyField = tempEmptyField - SubtractFixedOffset
			endif
		
			if(UseMonitorForEF)
				ScalingConstEF=SampleI0/EmptyI0
			elseif(UseEmptyMeasTime && UseSampleMeasTime)
				ScalingConstEF=SampleMeasurementTime/EmptyMeasurementTime
			endif
	
			if(UseDarkField)
				if(UseSampleMeasTime && UseEmptyMeasTime)
					if(UsePixelSensitivity)
						tempVal = EmptyMeasurementTime/BackgroundMeasTime
						MatrixOP/O  tempEmptyField=tempEmptyField - (tempVal*(DarkCurrentWave/Pix2DSensitivity))
					else
						tempVal = EmptyMeasurementTime/BackgroundMeasTime
						MatrixOP/O  tempEmptyField=tempEmptyField - (tempVal*DarkCurrentWave)
					endif
				else
					if(UsePixelSensitivity)
						MatrixOP/O  tempEmptyField=tempEmptyField - (DarkCurrentWave/Pix2DSensitivity)
					else
						MatrixOP/O  tempEmptyField=tempEmptyField - DarkCurrentWave
					endif
				endif
			endif
	
		endif
	
		MatrixOP/O  Calibrated2DDataSet = CalibrationPrefactor * (tempDataWv - ScalingConstEF * tempEmptyField)
		
		if(DoGeometryCorrection)  		//geometry correction (= cos(angle)^3) for solid angle projection, added 6/24/2006 to do in 2D data, not in 1D as done (incorrectly also) before using Dales routine.
			NI1A_GenerateGeometryCorr2DWave()
			Wave GeometryCorrection
			MatrixOp/O  Calibrated2DDataSet = Calibrated2DDataSet / GeometryCorrection
		endif
		
//		if(DoPolarizationCorrection)		//added 8/31/09 to enable 2D corection for polarization
//			NI1A_Generate2DPolCorrWv()
//			Wave polar2DWave
//			MatrixOp/O  Calibrated2DDataSet = Calibrated2DDataSet / polar2DWave 		//changed to "/" on October 12 2009 since due to use MatrixOp in new formula the calculate values are less than 1 and this is now correct. 
//		endif
		
		//Add to note:
		//need to add also geometry parameters
		NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
		NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY
		NVAR BeamSizeX=root:Packages:Convert2Dto1D:BeamSizeX
		NVAR BeamSizeY=root:Packages:Convert2Dto1D:BeamSizeY
		NVAR HorizontalTilt=root:Packages:Convert2Dto1D:HorizontalTilt
		NVAR XrayEnergy=root:Packages:Convert2Dto1D:XrayEnergy
		NVAR VerticalTilt=root:Packages:Convert2Dto1D:VerticalTilt
		NVAR PixelSizeX=	root:Packages:Convert2Dto1D:PixelSizeX
		NVAR PixelSizeY=	root:Packages:Convert2Dto1D:PixelSizeY
		NVAR SampleToCCDDistance=	root:Packages:Convert2Dto1D:SampleToCCDDistance
		NVAR Wavelength=	root:Packages:Convert2Dto1D:Wavelength
		OldNote+= "Nika_SampleToDetectorDistacne="+num2str(SampleToCCDDistance)+";"
		OldNote+= "Nika_Wavelength="+num2str(Wavelength)+";"
		OldNote+= "Nika_XrayEnergy="+num2str(XrayEnergy)+";"
		OldNote+= "Nika_PixelSizeX="+num2str(PixelSizeX)+";"
		OldNote+= "Nika_PixelSizeY="+num2str(PixelSizeY)+";"
		OldNote+= "Nika_HorizontalTilt="+num2str(HorizontalTilt)+";"
		OldNote+= "Nika_VerticalTilt="+num2str(VerticalTilt)+";"
		OldNote+= "Nika_BeamCenterX="+num2str(BeamCenterX)+";"
		OldNote+= "Nika_BeamCenterY="+num2str(BeamCenterY)+";"
		OldNote+= "Nika_BeamSizeX="+num2str(BeamSizeX)+";"
		OldNote+= "Nika_BeamSizeY="+num2str(BeamSizeY)+";"
		OldNote+= "CalibrationFormula="+CalibrationFormula+";"
		if(UseSampleThickness)
			OldNote+= "SampleThickness="+num2str(SampleThickness)+";"
		endif
		if(UseSampleTransmission)
			OldNote+= "SampleTransmission="+num2str(SampleTransmission)+";"
		endif
		if(UseCorrectionFactor)
			OldNote+= "CorrectionFactor="+num2str(CorrectionFactor)+";"
		endif
		if(UseSubtractFixedOffset)
			OldNote+= "SubtractFixedOffset="+num2str(SubtractFixedOffset)+";"
		endif
		if(UseSampleMeasTime)
			OldNote+= "SampleMeasurementTime="+num2str(SampleMeasurementTime)+";"
		endif
		if(UseEmptyMeasTime)
			OldNote+= "EmptyMeasurementTime="+num2str(EmptyMeasurementTime)+";"
		endif
		if(UseI0ToCalibrate)
			OldNote+= "SampleI0="+num2str(SampleI0)+";"
			OldNote+= "EmptyI0="+num2str(EmptyI0)+";"
		endif
		if(UseDarkMeasTime)
			OldNote+= "BackgroundMeasTime="+num2str(BackgroundMeasTime)+";"
		endif
		if(UsePixelSensitivity)
			OldNote+= "UsedPixelsSensitivity="+num2str(UsePixelSensitivity)+";"
		endif
		if(UseMonitorForEF)
			OldNote+= "UseMonitorForEF="+num2str(UseMonitorForEF)+";"
		endif
	
		SVAR CurrentDarkFieldName=root:Packages:Convert2Dto1D:CurrentDarkFieldName
		SVAR CurrentEmptyName=root:Packages:Convert2Dto1D:CurrentEmptyName	
		if(UseDarkField)
			OldNote+= "CurrentDarkFieldName="+(CurrentDarkFieldName)+";"
		endif
		if(UseEmptyField)
			OldNote+= "CurrentEmptyName="+(CurrentEmptyName)+";"
		endif
	else
		OldNote+= "CalibrationFormula="+"1"+";"
	endif
	SVAR CurrentMaskFileName=root:Packages:Convert2Dto1D:CurrentMaskFileName
	if(UseMask)
		OldNote+= "CurrentMaskFileName="+(CurrentMaskFileName)+";"
	endif
	NVAR UseSolidAngle=root:Packages:Convert2Dto1D:UseSolidAngle
	if(UseSolidAngle)
		OldNote+= "SolidAngleCorrection=Done"+";"
	endif
	
	note /K Calibrated2DDataSet
	note Calibrated2DDataSet, OldNote
	KillWaves/Z tempEmptyField, tempDataWv
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function/WAVE IN2_SolidAngleCorrectionALS(DataWave)
	Wave DataWave

//	Wave/Z Param_Values = root:Param_Values
//	if(WaveExists(Param_Values) == 0)
//		print "Making Needed Paramater Waves with Default Values"
//		setDataFolder root:
//		Make/T=2 Param_Names = {"Distance from axis of rotation to sample (mm)", "Sample - Detector distance (mm)"}
//		Make/N=2 Param_Values = {26,23}
//
//		Wave/Z Param_Values = root:Param_Values
//	endif
//	
//	Variable d1 = Param_Values[0] // Distance from axis of rotation to sample (mm)
//	Variable d2 = Param_Values[1] // Sample - Detector distance (mm)

	NVAR ALSRotAxisToSampleDist=root:Packages:Nika_RSoXS:ALSRotAxisToSampleDist	
	NVAR SDD=root:Packages:Convert2Dto1D:SampleToCCDDistance
	Variable d1 = ALSRotAxisToSampleDist 		// Distance from axis of rotation to sample (mm)
	Variable d2 = SDD							 	// Sample - Detector distance (mm)
	
	SVAR header = root:Packages:Nika_RSoXS:NRS_Vars:header
	variable phi = str2num(Stringbykey("CCD Theta",header,"=",";")) // Angle the CCD is rotated to (Input: degrees)
	
	// Because of the tan(x) and arctan(x) function it has a hard time handeling exactly 0 and 90 degrees.
	// so this statment moves it just slightly of so the calculation works.
	if (phi == 0)
		phi = (1e-11)
	elseif (phi == 90)
		phi = 89.9999999
	endif
	
	phi = phi * (pi/180) // Convert to radians
	
	variable ROI_Width = str2num(Stringbykey("Camera ROI Width",header,"=",";"))
	variable ROI_Height = str2num(Stringbykey("Camera ROI Height",header,"=",";"))
	variable ROI_X_Bin = str2num(Stringbykey("Camera ROI X Bin",header,"=",";"))
	variable ROI_Y_Bin = str2num(Stringbykey("Camera ROI Y Bin",header,"=",";"))
	
	variable num_pixels_X = ROI_Width / ROI_X_Bin
	variable num_pixels_Y = ROI_Height / ROI_Y_Bin
	
	NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX							//in millimeters
	NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY							//in millimeters
	NVAR beamCenterX=root:Packages:Convert2Dto1D:beamCenterX
	NVAR beamCenterY=root:Packages:Convert2Dto1D:beamCenterY

	Variable C = BeamCenterY*PixelSizeY	//Distance from the beam center in normal incidence to bottom of the CCD (mm)

	Duplicate/O DataWave, SolidAngleCorrectionMap
	
	Make/Free/N=(num_pixels_Y) a
	Make/Free/N=(num_pixels_X) b
	
	a = (p*PixelSizeY) + (d1 + d2 - (d2 + d1*(1-cos(phi))))*tan(phi) - C //Place Holder variable for y-axis 1D WAVE
	b = (p - beamCenterX ) * PixelSizeX //Place Holder variable for x-axis 1D WAVE

	//Turn Everything into Matrices so elementwise low level matrix operations can be done.
	MatrixOP/FREE y1 = rowRepeat(a,(num_pixels_Y))
	MatrixOP/FREE y2 = y1 + PixelSizeY
	MatrixOP/FREE x1 = colRepeat(b,(num_pixels_X))
	MatrixOP/FREE x2 = x1 + PixelSizeX
	MatrixOP/FREE z1 = const((num_pixels_Y),(num_pixels_X),(d2 + d1*(1-cos(phi))))
			// z is the distance from the source perpendicular to the Cartesian plane the CCD is in.
	
	MatrixOP/FREE omega = atan(x2*y2/(z1*sqrt(sq(x2)+sq(y2)+sq(z1)))) - atan(x2*y1/(z1*sqrt(sq(x2)+sq(y1)+sq(z1)))) - atan(x1*y2/(z1*sqrt(sq(x1)+sq(y2)+sq(z1))))	+ atan(x1*y1/(z1*sqrt(sq(x1)+sq(y1)+sq(z1))))
	// omega is the solid angle of a pixel
	MatrixOP/FREE omega_0 = 4*atan(PixelSizeX*PixelSizeY/(2*z1*sqrt(sq(PixelSizeX)+sq(PixelSizeY)+4*sq(z1))))

	MatrixOP/O SolidAngleCorrectionMap = omega_0 / omega //This is a normalization of the solid angle to virtual pixel residing at the termination of 'z'
	
	return SolidAngleCorrectionMap

end










// TPA/XML  note support is here
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_TPASetup()		//this will setup support for data with TPA/XML file format
	string OldDFf=GetDataFolder(1)

	//first initialize if user selects this without opening main window... 
	doWIndow NI1A_Convert2Dto1DPanel
	if(!V_Flag)
		NI1A_Convert2Dto1DMainPanel()		
	endif
	//set some parameters here:
	NVAR UseSampleTransmission = root:Packages:Convert2Dto1D:UseSampleTransmission
	NVAR UseSampleThickness = root:Packages:Convert2Dto1D:UseSampleThickness
	NVAR UseEmptyField = root:Packages:Convert2Dto1D:UseEmptyField
	NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate
	NVAR DoGeometryCorrection = root:Packages:Convert2Dto1D:DoGeometryCorrection
	NVAR UseMonitorForEf = root:Packages:Convert2Dto1D:UseMonitorForEf
	NVAR UseSampleTransmFnct = root:Packages:Convert2Dto1D:UseSampleTransmFnct
	NVAR UseSampleThicknFnct = root:Packages:Convert2Dto1D:UseSampleThicknFnct
	NVAR UseSampleMonitorFnct = root:Packages:Convert2Dto1D:UseSampleMonitorFnct
	NVAR UseEmptyMonitorFnct = root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
	NVAR XrayEnergy = root:Packages:Convert2Dto1D:XrayEnergy
	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength
	NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY
	NVAR SampleToCCDdistance = root:Packages:Convert2Dto1D:SampleToCCDdistance
	NVAR BeamCenterX = root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY = root:Packages:Convert2Dto1D:BeamCenterY
	
	//XrayEnergy=8.333
	//Wavelength=12.39842/8.333
	//PixelSizeX = 0.08
	//PixelSizeY = 0.08
	
	UseSampleTransmission = 1
	UseSampleThickness = 1
//	UseEmptyField = 1
//	UseI0ToCalibrate = 1
//	DoGeometryCorrection = 1
//	UseMonitorForEf = 1
	UseSampleTransmFnct = 1
	UseSampleThicknFnct =1
//	UseSampleMonitorFnct = 1
//	UseEmptyMonitorFnct = 1
	SVAR SampleTransmFnct = root:Packages:Convert2Dto1D:SampleTransmFnct
	SVAR SampleThicknFnct = root:Packages:Convert2Dto1D:SampleThicknFnct
	SVAR SampleMonitorFnct = root:Packages:Convert2Dto1D:SampleMonitorFnct
	SVAR EmptyMonitorFnct = root:Packages:Convert2Dto1D:EmptyMonitorFnct

	SampleTransmFnct = "NI1_TPAGetTranmsission"
	SampleThicknFnct = "NI1_TPAGetThickness"
	//SampleMonitorFnct = "NI1_SSRLGetSampleI0"
	//EmptyMonitorFnct = "NI1_SSRLGetEmptyI0"
	PopupMenu Select2DDataType win=NI1A_Convert2Dto1DPanel, popmatch="TPA/XML" //mode=22
	PopupMenu SelectBlank2DDataType win=NI1A_Convert2Dto1DPanel, popmatch="TPA/XML" //mode=22
	NI1A_PopMenuProc("Select2DDataType",1,"TPA/XML")
	NI1A_PopMenuProc("SelectBlank2DDataType",1,"TPA/XML")
	
	Wave/Z image=root:Packages:Convert2Dto1D:CCDImageToConvert
	if(WaveExists(image))
			string sampleNote=note(image)
			string ImageType=StringByKey("DataFileType", sampleNote , "=" , ";")
		if(stringmatch(ImageType,"TPA/XML"))	
			DoAlert 1, "Found TPA Image loaded, do you want to read information from the header to Nika?"
			if(V_FLag==1)	//yes...	
					Wavelength =NumberByKey("Lambda", sampleNote , "=" , ";")
					XrayEnergy = 12.39842/Wavelength
					SampleToCCDdistance =NumberByKey("Detector_Distance", sampleNote , "=" , ";")
					BeamCenterX= NumberByKey("X0", sampleNote , "=" , ";")
					BeamCenterY=NumberByKey("Y", sampleNote , "=" , ";") - NumberByKey("Y0", sampleNote , "=" , ";")
					DoALert 0, "Parameters, paths and lookup functions for TPA/XML have been loaded"
			endif
		else
			NI1A_ButtonProc("Select2DDataPath")
			NI1A_ButtonProc("SelectMaskDarkPath")
			DoAlert 0, "Please load TPA type image and rerun the same macro to load instrument parameters from the header" 		
		endif	
	endif
	if(!WaveExists(image))
			NI1A_ButtonProc("Select2DDataPath")
			NI1A_ButtonProc("SelectMaskDarkPath")
			DoAlert 0, "Please load TPA type image and rerun the same macro to load instrument parameters from the header" 
	endif


end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_TPAGetTranmsission(fileName)
	string fileName
	//T = (ICpstsamp(sample) * ICpresamp(0))/(ICpresamp(sample) * ICpstsamp(0))
	wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	//wave/Z EmptyData = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(CCDImageToConvert))// || !WaveExists(EmptyData))
		abort "Needed area data do not exist. Load Sample data before going further"
	endif
	string sampleNote=note(CCDImageToConvert)
	//string emptyNote=note(EmptyData)
	variable transmission=NumberByKey("Transmission", sampleNote , "=" , ";")
	print "Found transmission = "+num2str(transmission)
	return transmission
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_TPAGetThickness(fileName)
	string fileName
	//T = (ICpstsamp(sample) * ICpresamp(0))/(ICpresamp(sample) * ICpstsamp(0))
	wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	//wave/Z EmptyData = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(CCDImageToConvert))// || !WaveExists(EmptyData))
		abort "Needed area data do not exist. Load Sample data before going further"
	endif
	string sampleNote=note(CCDImageToConvert)
	//string emptyNote=note(EmptyData)
	variable Thickness=NumberByKey("Thickness", sampleNote , "=" , ";")
	print "Found Thickness = "+num2str(Thickness)
	return Thickness
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
// SSRLMatSAXS support is here
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_SSRLSetup()		//this will setup support for SSRLMatSAXS
	string OldDFf=GetDataFolder(1)

	//first initialize if user selects this without opening main window... 
	doWIndow NI1A_Convert2Dto1DPanel
	if(!V_Flag)
		NI1A_Convert2Dto1DMainPanel()		
	endif
	//set some parameters here:
	NVAR UseSampleTransmission = root:Packages:Convert2Dto1D:UseSampleTransmission
	NVAR UseEmptyField = root:Packages:Convert2Dto1D:UseEmptyField
	NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate
	NVAR DoGeometryCorrection = root:Packages:Convert2Dto1D:DoGeometryCorrection
	NVAR UseMonitorForEf = root:Packages:Convert2Dto1D:UseMonitorForEf
	NVAR UseSampleTransmFnct = root:Packages:Convert2Dto1D:UseSampleTransmFnct
	NVAR UseSampleMonitorFnct = root:Packages:Convert2Dto1D:UseSampleMonitorFnct
	NVAR UseEmptyMonitorFnct = root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
	NVAR XrayEnergy = root:Packages:Convert2Dto1D:XrayEnergy
	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength
	NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY
	
	XrayEnergy=8.333
	Wavelength=12.39842/8.333
	PixelSizeX = 0.08
	PixelSizeY = 0.08
	
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

	SampleTransmFnct = "NI1_SSRLGetTranmsission"
	SampleMonitorFnct = "NI1_SSRLGetSampleI0"
	EmptyMonitorFnct = "NI1_SSRLGetEmptyI0"
	PopupMenu Select2DDataType win=NI1A_Convert2Dto1DPanel, popmatch="SSRLMatSAXS" //mode=22
	PopupMenu SelectBlank2DDataType win=NI1A_Convert2Dto1DPanel, popmatch="SSRLMatSAXS" //mode=22
	NI1A_PopMenuProc("Select2DDataType",1,"SSRLMatSAXS")
	NI1A_PopMenuProc("SelectBlank2DDataType",1,"SSRLMatSAXS")
	NI1A_ButtonProc("Select2DDataPath")
	NI1A_ButtonProc("SelectMaskDarkPath")


	DoALert 0, "Parameters, paths and lookup functions for SSRL Mat SAXS have been loaded"
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_SSRLGetTranmsission(fileName)
	string fileName
	//T = (ICpstsamp(sample) * ICpresamp(0))/(ICpresamp(sample) * ICpstsamp(0))
	wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	wave/Z EmptyData = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(CCDImageToConvert) || !WaveExists(EmptyData))
		abort "Needed area data do not exist. Load Sample2D and Empty2D before going further"
	endif
	string sampleNote=note(CCDImageToConvert)
	string emptyNote=note(EmptyData)
	variable ICpstsampSa=NumberByKey("ICpstsamp", sampleNote , "=" , ";")
	variable ICpresampEm=NumberByKey("ICpresamp", emptyNote , "=" , ";")
	variable ICpresampSa=NumberByKey("ICpresamp", sampleNote , "=" , ";")
	variable ICpstsampEm=NumberByKey("ICpstsamp", emptyNote , "=" , ";")
	variable transmission  
	transmission = ICpstsampSa * ICpresampEm / (ICpresampSa *ICpstsampEm)
	print "Found transmission = "+num2str(transmission)
	return transmission
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1_SSRLGetSampleI0(fileName)
	string fileName
	wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(CCDImageToConvert))
		abort "Needed area data do not exist. Load Sample2D before going further"
	endif
	string sampleNote=note(CCDImageToConvert)
	variable ICpresampSa=NumberByKey("ICpresamp", sampleNote , "=" , ";")
	//variable secSa=NumberByKey("sec", sampleNote , "=" , ";")
	print "Found I0 value for sample = "+num2str(ICpresampSa)	//*secSa)
	return ICpresampSa	//*secSa

end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_SSRLGetEmptyI0(fileName)
	string fileName
	wave/Z EmptyData = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(EmptyData))
		abort "Needed area data do not exist. Load Empty2D before going further"
	endif
	string sampleNote=note(EmptyData)
	variable ICpresampEm=NumberByKey("ICpresamp", sampleNote , "=" , ";")
	//variable secEm=NumberByKey("sec", sampleNote , "=" , ";")
	print "Found I0 value for empty = "+num2str(ICpresampEm)//*secEm)
	return ICpresampEm	//*secEm

end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//		APS 12ID-C camera with Gold detector

Function NI1_12IDCLoadAndSetup()
	//this is function to setup data reduction for APS 12ID-C station using Gold detector
	
	string OldDFf=GetDataFolder(1)
	//first initialize 
	NI1A_Convert2Dto1DMainPanel()
	NI1BC_InitCreateBmCntrFile()
	NI1_12IDCHowTo()
	setDataFOlder root:Packages:Convert2Dto1D:
	//save the Spec file for #Z lines nad store the values for calibration... 
	string/g specCalibDataName=""
	SVAR DataFileExtension=root:Packages:Convert2Dto1D:DataFileExtension
	DataFileExtension = ".tif"
	//Now we need to load lookup table witgh calibration numbers
	NI1_12IDCReadSpecFile(100)		//assume 100 images is normal. 
	//set some usable energy, assume one of the first ones is useful
	Wave MonoEnenergy = root:Packages:Nika_12IDCLookups:MonoEnenergy
	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength
	NVAR XrayEnergy = root:Packages:Convert2Dto1D:XrayEnergy
	XrayEnergy = MonoEnenergy[ceil(1*numpnts(MonoEnenergy)/10)]
	Wavelength = 12.39841857/XrayEnergy
	NI1_12IDCReadScriptFile()
	//these are setting so user is processing files... 	
	NVAR  Displ=root:Packages:Convert2Dto1D:Process_DisplayAve
	NVAR 	Proc1= root:Packages:Convert2Dto1D:Process_Individually
	NVAR 	Proc2= root:Packages:Convert2Dto1D:Process_Average
	NVAR 	Proc3 = root:Packages:Convert2Dto1D:Process_AveNFiles
	Displ = 0
	Proc1 = 1
	Proc2 = 0
	Proc3 = 0
	//default settings, change as needed
	NVAR UseSubtractFixedOffset = root:Packages:Convert2Dto1D:UseSubtractFixedOffset
	NVAR SubtractFixedOffset = root:Packages:Convert2Dto1D:SubtractFixedOffset
	NVAR UseSectors = root:Packages:Convert2Dto1D:UseSectors
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
	
	SubtractFixedOffset = 200
	UseSubtractFixedOffset=1
	UseSectors = 1
	FIlesSortOrder = 3	
	QvectorNumberPoints=300
	QBinningLogarithmic=1
	QvectormaxNumPnts = 0
	DoSectorAverages = 0
	DoCircularAverage = 1
	NumberOfSectors = 12
	SectorsStartAngle = 0
	SectorsHalfWidth = 10
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
	//
		
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

	UseSampleThickness = 0			
	UseSampleTransmission = 1
	UseEmptyField = 1
	UseI0ToCalibrate = 1
	DoGeometryCorrection = 1
	UseMonitorForEf = 1
	UseSampleTransmFnct = 1
	UseSampleMonitorFnct = 1
	UseEmptyMonitorFnct = 1
	UseSampleThicknFnct = 0 
	
	SVAR SampleTransmFnct = root:Packages:Convert2Dto1D:SampleTransmFnct
	SVAR SampleMonitorFnct = root:Packages:Convert2Dto1D:SampleMonitorFnct
	SVAR EmptyMonitorFnct = root:Packages:Convert2Dto1D:EmptyMonitorFnct
	SVAR SampleThicknFnct = root:Packages:Convert2Dto1D:SampleThicknFnct
	
	SampleTransmFnct = "NI1_12IDCFindTrans"
	SampleMonitorFnct = "NI1_12IDCFindI0"
	EmptyMonitorFnct = "NI1_12IDCFindEmptyI0"
	SampleThicknFnct = ""
	

	NI1A_SetCalibrationFormula()			
	NI1BC_UpdateBmCntrListBox()	
	NI1A_UpdateDataListBox()	
	NI1A_UpdateEmptyDarkListBox()	
	//send user to Empty/Dark tab
	TabControl Convert2Dto1DTab win=NI1A_Convert2Dto1DPanel, value=3
	NI1A_TabProc("NI1A_Convert2Dto1DPanel",3)	
	setDataFolder OldDFf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_12IDCReadScriptFile()

	Variable refNum,err=0, ReadParams=0, CreateMask=0
	String YesNoStrParams="No"
	String YesNoStrMask="No"
	OPEN/R/Z/P=Convert2Dto1DDataPath refNum as "goldnormengavg"
	if(V_Flag==0)
		String lineStr
		Variable count=0
		do
			FreadLine refNum,lineStr
			if(strlen(lineStr)<=0)
				break
			endif
			if(strsearch(lineStr,"goldaverage",0)>=0 && !StringMatch(lineStr[0], "#"))
				Prompt YesNoStrParams, "Load beamline parameters in Nika? (overwrites any existing params!)", popup, "No;Yes;"
				Prompt YesNoStrMask, "NOT SUGGESTED: Create beamline defined mask? (overwrites any existing mask!)", popup, "No;Yes;"
				DoPrompt "Beamline params & mask found, load in Nika?", YesNoStrParams, YesNoStrMask
				if(V_Flag)
					abort
				endif
				if(stringMatch(YesNoStrParams,"Yes"))
					ReadParams=1
				endif
				if(stringMatch(YesNoStrMask,"Yes"))
					CreateMask=1
				endif
				NI1_12IDC_Parsegoldnormengavg(lineStr, ReadParams)
				NI1_12IDC_ParsegoldMask(lineStr, CreateMask)
			endif
		while(err==0)
	else
		print "goldnormengavg file not found, parameters not set..."
	endif		
	close refnum
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_12IDC_ParsegoldMask(CommandLine, MakeMask)
	string CommandLine
	variable MakeMask

//	CommandLine="goldaverage -o Averaged_norm -y -p 0.1465 -d 3775 -Z 10 -k $normval -e $energyval -r 0,0,2048,2048 -C      1090@1024,1000 -r    753,300,766,232 -r748,0,775,232 -r0,303,2048,318 -r1520,310,1545,440 -r90,1120,170,1177 -c14@774,309 774 311 $filename"
//	CommandLine="goldaverage -o Averaged_norm -y -p 0.1465 -d 3775 -Z 10 -k $normval -e $energyval -rect 120x80@20,30  -a10-1000@300,300 -R753,300,766,232 -A 100-200@500,500 774 311 $filename"
	Variable tempStart, tempEnd, NumLines, i
	String TempStr, TempStr2
	tempStart = 0

	if(MakeMask)
		string OldDf=GetDataFOlder(1)
		//go to the right data folder... Create Mask image to work on... 
		SetDataFolder	root:Packages:Convert2Dto1D:
		Wave/Z CCDImage=root:Packages:Convert2Dto1D:CCDImageToConvert
		if(!WaveExists(CCDImage))
			DoAlert/T="CCD image not found, we need one to create mask", 0, "In next dialog select any one from tiff files you will be reducing. All we need is correct image size." 
			//print "Mask was not created, first load image and then try again"
			ImageLoad/P=Convert2Dto1DDataPath/T=tiff/Q/O/N=M_ROIMask 
			//Make/O/B/U/N=(1024,1024) root:Packages:Convert2Dto1D:M_ROIMask
			if(V_flag==0)		//return 0 if not succesuful.
				print "Mask was not created, first load image and then try again"
				SetDataFolder	OldDf
				return 0
			endif
			wave M_ROIMask
			Redimension/N=(-1,-1,0) 	M_ROIMask			//this is fix for 3 layer tiff files...
		else
			Duplicate/O CCDImage, root:Packages:Convert2Dto1D:M_ROIMask		
		endif
		Wave Mask = root:Packages:Convert2Dto1D:M_ROIMask
		Mask = (Mask > 10) ? 1 : 0
		Redimension/B/U Mask
		//this is all enable mask... 
		//now reduce spaces in CommandLine to max of one space. 
		Do
			CommandLine = ReplaceString("  ", CommandLine, " ")
		while (StringMatch(CommandLine, "*  *" ))
		//OK, now we shoudl have at most one space between commands and parameters. 
		Do
			tempStart=strsearch(CommandLine, "-", tempStart+1)
			if(tempStart<0)
				break
			endif
			TempStr = CommandLine[tempStart+1,tempStart+30]
			if(GrepString(TempStr, "^rect"))					//rectangle, full word
				TempStr =TempStr[4,inf]
				tempEnd = strsearch(TempStr, " ", 6)
				TempStr = TempStr[0,tempEnd]
				print "Added Masked rect  :  "+TempStr
				NI1_12IDC_AddRectangleMask(Mask,TempStr,1)
			elseif(GrepString(TempStr, "^r"))					//rectangle, short
				TempStr =TempStr[1,inf]
				tempEnd = strsearch(TempStr, " ", 3)
				TempStr = TempStr[0,tempEnd]
				print "Added Masked rect  :  "+TempStr
				NI1_12IDC_AddRectangleMask(Mask,TempStr,1)
			elseif(GrepString(TempStr, "^negrect"))			//negative rectangle, full negrect
				TempStr =TempStr[7,inf]
				tempEnd = strsearch(TempStr, " ", 9)
				TempStr = TempStr[0,tempEnd]
				print "Added unmasked rect  : "+TempStr
				NI1_12IDC_AddRectangleMask(Mask,TempStr,0)
			elseif(GrepString(TempStr, "^R"))					//negative rectangle, short negrect
				TempStr =TempStr[1,inf]
				tempEnd = strsearch(TempStr, " ", 3)
				TempStr = TempStr[0,tempEnd]
				print "Added unmasked rect  : "+TempStr
				NI1_12IDC_AddRectangleMask(Mask,TempStr,0)
			elseif(GrepString(TempStr, "^circle"))			//circle, full word
				TempStr =TempStr[6,inf]
				tempEnd = strsearch(TempStr, " ", 8)
				TempStr = TempStr[0,tempEnd]
				print "Added Masked circle  : "+TempStr
				NI1_12IDC_AddCircleMask(Mask,TempStr,1)
			elseif(GrepString(TempStr, "^c"))					//circle, short
				TempStr =TempStr[1,inf]
				tempEnd = strsearch(TempStr, " ", 3)
				TempStr = TempStr[0,tempEnd]
				print "Added Masked circle  : "+TempStr
				NI1_12IDC_AddCircleMask(Mask,TempStr,1)
			elseif(GrepString(TempStr, "^negcircle"))		//negcircle, full word	
				TempStr =TempStr[9,inf]
				tempEnd = strsearch(TempStr, " ", 11)
				TempStr = TempStr[0,tempEnd]
				print "Added unmasked circle  : "+TempStr
				NI1_12IDC_AddCircleMask(Mask,TempStr,0)
			elseif(GrepString(TempStr, "^C"))							//negcircle, short	
				TempStr =TempStr[1,inf]
				tempEnd = strsearch(TempStr, " ", 3)
				TempStr = TempStr[0,tempEnd]
				print "Added unMasked Circle  : "+TempStr
				NI1_12IDC_AddCircleMask(Mask,TempStr,0)
			elseif(GrepString(TempStr, "^annulus"))					//annulus
				TempStr =TempStr[7,inf]
				tempEnd = strsearch(TempStr, " ", 10)
				TempStr = TempStr[0,tempEnd]
				print "Added Masked annulus  : "+TempStr
				NI1_12IDC_AddAnnulusMask(Mask,TempStr,1)
			elseif(GrepString(TempStr, "^a"))							//annulus
				TempStr =TempStr[1,inf]
				tempEnd = strsearch(TempStr, " ", 3)
				TempStr = TempStr[0,tempEnd]
				print "Added Masked a  : "+TempStr
				NI1_12IDC_AddAnnulusMask(Mask,TempStr,1)
			elseif(GrepString(TempStr, "^negannulus"))				//negannulus
				TempStr =TempStr[10,inf]
				tempEnd = strsearch(TempStr, " ", 13)
				TempStr = TempStr[0,tempEnd]
				print "Added unMasked annulus  : "+TempStr
				NI1_12IDC_AddAnnulusMask(Mask,TempStr,0)
			elseif(GrepString(TempStr, "^A"))							//negannulus
				TempStr =TempStr[1,inf]
				tempEnd = strsearch(TempStr, " ", 3)
				TempStr = TempStr[0,tempEnd]
				print "Added unMasked Annulus  : "+TempStr
				NI1_12IDC_AddAnnulusMask(Mask,TempStr,0)
			else
				//print "Unknown command to creat emask : "+TempStr
			endif
		while(tempStart>0)
		
		NVAR UseMask = root:Packages:Convert2Dto1D:UseMask
		UseMask=1
		SVAR CurrentMaskFileName = root:Packages:Convert2Dto1D:CurrentMaskFileName
		CurrentMaskFileName = "12ID-C beamline mask"

		SetDataFolder	OldDf
	
endif	
	


	
//	string OldDf=getDataFolder(1)
//	SetDataFolder root:Packages:Nika_12IDCLookups
//
//	Variable tempStart, tempEnd, NumLines, i
//	String TempStr, TempStr2
//	
//	// goldaverage -o Averaged_norm -y -p 0.175 -d 2345 -Z 200 -k $normval -e $energyval -r146,915,158,980 -r143,980,164,1024 -r 0,908,1024,914 -c6@166,907 -c12@154,911 154 911 $filename
//	//need to create list of items, first rectangles
//	Make/O/N=(0,4) Rectangles
//	tempStart = 0
//	NumLines = 0
//	Do
//		tempStart=strsearch(CommandLine, "-r", tempStart+1)
//		tempEnd = strsearch(CommandLine, " ", tempStart+3)
//		if(tempEnd<0 || tempStart<0)
//			BREAk
//		endif	
//		TempStr = CommandLine[tempStart,tempEnd]
//		TempStr = ReplaceString("-r",TempStr,"")+","
//		redimension/N=(NumLines+1, 4) Rectangles
//		Rectangles[NumLines][0]=str2num(stringFromList(0,TempStr,","))
//		Rectangles[NumLines][1]=str2num(stringFromList(1,TempStr,","))
//		Rectangles[NumLines][2]=str2num(stringFromList(2,TempStr,","))
//		Rectangles[NumLines][3]=str2num(stringFromList(3,TempStr,","))
//		print "Found Rectangular mask with corners of: "+num2str(Rectangles[NumLines][0])+" ; "+num2str(Rectangles[NumLines][1])+" ; "+num2str(Rectangles[NumLines][2])+" ; "+num2str(Rectangles[NumLines][3])
//		NumLines+=1
//	while(tempEnd>0 && strlen(TempStr)>1 )
//
//	//need to create list of items, second circles
//	Make/O/N=(0,3) Circles
//	tempStart = 0
//	NumLines = 0
//	Do
//		tempStart=strsearch(CommandLine, "-c", tempStart+1)
//		tempEnd = strsearch(CommandLine, " ", tempStart+3)
//		if(tempEnd<0 || tempStart<0)
//			BREAk
//		endif	
//		TempStr = CommandLine[tempStart,tempEnd]
//		TempStr = ReplaceString("-c",TempStr,"")+","
//		TempStr2 = stringFromList(1,TempStr,"@")
//		redimension/N=(NumLines+1, 3) Circles
//		Circles[NumLines][0]=str2num(stringFromList(0,TempStr,"@"))
//		Circles[NumLines][1]=str2num(stringFromList(0,TempStr2,","))
//		Circles[NumLines][2]=str2num(stringFromList(1,TempStr2,","))
//		print "Found Circular mask with radius of: "+num2str(Circles[NumLines][0])+" ; and centers "+num2str(Circles[NumLines][1])+" ; "+num2str(Circles[NumLines][2])
//		NumLines+=1
//	while(tempEnd>0 && strlen(TempStr)>1 )
//	SetDataFolder	OldDf
//	if(MakeMask)
//		//here we will make mask... We need image to make copy of. 
//		SetDataFolder	root:Packages:Convert2Dto1D:
//		Wave/Z CCDImage=root:Packages:Convert2Dto1D:CCDImageToConvert
//		if(!WaveExists(CCDImage))
//			DoAlert/T="CCD image not found, we need one to create mask", 0, "In next dialog select any one from tiff files you will be reducing. All we need is correct image size." 
//			//print "Mask was not created, first load image and then try again"
//			ImageLoad/P=Convert2Dto1DDataPath/T=tiff/Q/O/N=M_ROIMask 
//			//Make/O/B/U/N=(1024,1024) root:Packages:Convert2Dto1D:M_ROIMask
//			if(V_flag==0)		//return 0 if not succesuful.
//				print "Mask was not created, first load image and then try again"
//				SetDataFolder	OldDf
//				return 0
//			endif
//			wave M_ROIMask
//			Redimension/N=(-1,-1,0) 	M_ROIMask			//this is fix for 3 layer tiff files...
//		else
//			Duplicate/O CCDImage, root:Packages:Convert2Dto1D:M_ROIMask		
//		endif
//		Wave Mask = root:Packages:Convert2Dto1D:M_ROIMask
//		Mask = (Mask > 10) ? 1 : 0
//		Redimension/B/U Mask
//		//this is all enable mask... 
//		//Now we need to add masked off areas... 
//		print "Created new Mask based on beamline command file"
//		Rectangles = Rectangles[p][q]<dimsize(Mask,0) ? Rectangles[p][q] : Rectangles[p][q]-1			//Staff uses 2048 index for mask, even though image is 0 to 2047 only. And now, they do NOT use 1 based pixel counting, they use 0 for first pixel... 
//		For(i=0;i<dimSize(Rectangles,0);i+=1)
//			Mask[Rectangles[i][0],Rectangles[i][2]][Rectangles[i][1],Rectangles[i][3]] = 0
//			print "Added Rectangular mask with corners of: "+num2str(Rectangles[i][0])+" ; "+num2str(Rectangles[i][1])+" ; "+num2str(Rectangles[i][2])+" ; "+num2str(Rectangles[i][3])
//		endfor
//		For(i=0;i<dimSize(Circles,0);i+=1)
//			Mask = sqrt((p-Circles[i][1])^2+(q-Circles[i][2])^2)>Circles[i][0] ? Mask[p][q] : 0
//			print "Added Circular mask with radius of: "+num2str(Circles[i][0])+" ; and centers "+num2str(Circles[i][1])+" ; "+num2str(Circles[i][2])
//		endfor
//		NVAR UseMask = root:Packages:Convert2Dto1D:UseMask
//		UseMask=1
//		SVAR CurrentMaskFileName = root:Packages:Convert2Dto1D:CurrentMaskFileName
//		CurrentMaskFileName = "12ID-C beamline mask"
//		SetDataFolder	OldDf
//		
//	endif
end

//GOLDAVERAGE (Version 1.4.4)
//
//Perform azimuthal averaging of gold data
//Each input file is averaged to produce a separate output file
//usage: goldaverage [OPTION]... CX CY GOLDFILE...
//
//-d DISTANCE
//-distance DISTANCE   specify sample-detector distance in mm (default 3050mm)
//-y
//-overwrite           force overwriting of duplicate output files
//-o OUTDIR
//-output OUTDIR       put output files in this directory (default 'Averaged')
//-Z OFFSET
//-offset OFFSET       specify an alternative image intensity offset (default=10)
//-help                Print extended help information & extra options
//-b BINSIZE
//-binsize BINSIZE   specify output bin size in camera pixels (default 1)
//-l
//-log               specify logarithmic bin sizes (default linear)
//-d DISTANCE
//-detector DISTANCE specify sample-detector distance in mm (default 3050mm)
//-p PIXELSIZE
//-pixelsize PIXELSIZE specify camera pixel size (default = 0.098mm, i.e. gold detector)
//-e ENERGY
//-energy ENERGY     specify photon energy in keV, overriding value stored in file header
//-q QBINSIZE
//-qpix QBINSIZE     specify q bin size (default is calculated from above parameters)
//-h
//-header            propagate the 'gold' header into the output file
//-approxq           use the 'old' style linear approximation for q
//-rmin MINVAL       specify a minimum bin number to be output (default = 0)
//-rmax MAXVAL       specify a maximum bin number of be output
//-labels            output column header labels in the output file
//-g PLOTCMDFILE
//-gnuplot PLOTCMDFILE output gnuplot commands to plot the averaged data into 'PLOTCMDFILE'
//-k NORMVAL
//-fixedscale NORMVAL override intensity normalization to use a constant 'NORMVAL'
//-K NORMKEY
//-headerscale NORMKEY intens norm uses header value (default 'ID12_SCLC1_COUNTS_03')
//Masking options:
//
//The program contains a mask array which governs which pixels are used
//in calculations.  The mask array is initialised to allow all pixels to
//be used, and various options can be specified to add and remove regions
//of pixels from the mask.  Options may be repeated and their cumulative effect
//is governed by the order in which they are given.
//
//-m maskfile
//-mask maskfile                 specify the name of a mask file and mask out those pixels
//                               masked in the maskfile.  The mask file can either be another
//                               gold image file or an RGB TIFF file
//                               If a TIFF file is used, any pixel whose RGB value is not a
//                               shade of gray will be considered masked.  This allows you to
//                               use goldconvert to convert a gold image file into a TIFF file
//                               which can then be edited with an image editor (such as the GIMP)
//                               where you can 'paint' the pixels that you want to exclude in some
//                               color (say red) while leaving the original gold image visible as
//                               a grayscale image in the unmasked pixel positions
//
//-M maskfile
//-negmask maskfile              specify the name of a mask file and unmask those pixels
//                               masked in the maskfile.  The format and interpretation of the
//                               mask file is described above
//
//-n
//-invert                        invert the current mask.  masked pixels become unmasked, and vice
//                               versa
//
//-r rectspec
//-rect rectspec                 Add a rectangle of masked pixels to the mask.  The rectangle can
//                               be given in two different forms e.g. '10,15,80,250' specifies a
//                               rectangle with 10 >= x > 80 and 15 >= y > 250 and
//                               e.g. '120x80@20,30' specifies a rectangle of width 120 pixels and
//                               height 80 pixels centered at x=20, y=30
//                               All coordinates must be integers
//
//-R rectspec
//-negrect rectspec              Remove a rectangle of masked pixels from the mask.  The rectangle
//                               coordinates are as given above
//
//-c radius@xcenter,ycenter
//-circle radius@xcenter,ycenter Add a circle of masked pixels to the mask.  The circle is specified
//                               by its radius and its center, which may be floating point
//                               values
//
//-C radius@xcenter,ycenter
//-negcircle radius@xcenter,ycenter   remove a circle of masked pixels from the mask.
//
//-a r1-r2@xcenter,ycenter
//-annulus r1-r2@xcenter,ycenter Add an annular region of pixels to the mask.  The annulus is
//                               specified by its inner and outer radii and its center, which
//                               may be floating point values.
//-A r1-r2@xcenter,ycenter
//-negannulus r1-r2@xcenter,ycenter   remove an annular region of masked pixels from the mask

static Function NI1_12IDC_AddAnnulusMask(MaskWave,MaskSpecs,MaskIt)
		wave MaskWave		//thsi is Mask file
		string MaskSpecs		//thsi specifying mask location	
		variable MaskIt			//1 to mask off pixels, 0 to unmask pixels. 
		//-a r1-r2@xcenter,ycenter
		//-annulus r1-r2@xcenter,ycenter Add an annular region of pixels to the mask.  The annulus is
		//                               specified by its inner and outer radii and its center, which
		//                               may be floating point values.
		//-A r1-r2@xcenter,ycenter
		//-negannulus r1-r2@xcenter,ycenter   remove an annular region of masked pixels from the mask
	variable Dim1Center, Dim2Center, RadiusS, RadiusL
	string RadiusSpecs = StringFromList(0, MaskSpecs+"@", "@")
	RadiusS = str2num(StringFromList(0, RadiusSpecs+"-", "-"))
	RadiusL = str2num(StringFromList(1, RadiusSpecs+"-", "-"))
	string CenterSpecs=StringFromList(1, MaskSpecs+"@", "@")
	Dim1Center = str2num(StringFromList(0, CenterSpecs+",", ","))
	Dim2Center = str2num(StringFromList(1, CenterSpecs+",", ","))
	if(RadiusS>RadiusL)
		variable tmp1=RadiusS
		RadiusS = RadiusL
		RadiusL = tmp1
	endif

	Dim1Center = Dim1Center>0 ? Dim1Center : 0
	Dim2Center = Dim2Center>0 ? Dim2Center : 0
	Dim1Center = Dim1Center<DimSize(MaskWave,0) ? Dim1Center : DimSize(MaskWave,0)-1
	Dim2Center = Dim2Center<DimSize(MaskWave,1) ? Dim2Center : DimSize(MaskWave,1)-1
	if(MaskIt)
		Multithread MaskWave = (sqrt((p-Dim1Center)^2+(q-Dim2Center)^2)>RadiusS && sqrt((p-Dim1Center)^2+(q-Dim2Center)^2)>RadiusL) ? MaskWave[p][q] : 0
	else
		Multithread MaskWave = (sqrt((p-Dim1Center)^2+(q-Dim2Center)^2)>RadiusS && sqrt((p-Dim1Center)^2+(q-Dim2Center)^2)>RadiusL) ? MaskWave[p][q] : 1
	endif
end


static Function NI1_12IDC_AddCircleMask(MaskWave,MaskSpecs,MaskIt)
		wave MaskWave		//thsi is Mask file
		string MaskSpecs		//thsi specifying mask location	
		variable MaskIt			//1 to mask off pixels, 0 to unmask pixels. 
//-circle radius@xcenter,ycenter Add a circle of masked pixels to the mask.  The circle is specified
//                               by its radius and its center, which may be floating point
//                               values  e.g.,  -circle 14@774,309
	variable Dim1Center, Dim2Center, Radius
	Radius = str2num(StringFromList(0, MaskSpecs+"@", "@"))
	string CenterSpecs=StringFromList(1, MaskSpecs+"@", "@")
	Dim1Center = str2num(StringFromList(0, CenterSpecs+",", ","))
	Dim2Center = str2num(StringFromList(1, CenterSpecs+",", ","))

	Dim1Center = Dim1Center>0 ? Dim1Center : 0
	Dim2Center = Dim2Center>0 ? Dim2Center : 0
	Dim1Center = Dim1Center<DimSize(MaskWave,0) ? Dim1Center : DimSize(MaskWave,0)-1
	Dim2Center = Dim2Center<DimSize(MaskWave,1) ? Dim2Center : DimSize(MaskWave,1)-1
	if(MaskIt)
		Multithread MaskWave = sqrt((p-Dim1Center)^2+(q-Dim2Center)^2)>Radius ? MaskWave[p][q] : 0
	else
		Multithread MaskWave = sqrt((p-Dim1Center)^2+(q-Dim2Center)^2)>Radius ? MaskWave[p][q] : 1
	endif
end

static Function NI1_12IDC_AddRectangleMask(MaskWave,MaskSpecs,MaskIt)
		wave MaskWave		//thsi is Mask file
		string MaskSpecs		//thsi specifying mask location	
		variable MaskIt			//1 to mask off pixels, 0 to unmask pixels. 
//-r rectspec
//-rect rectspec                 Add a rectangle of masked pixels to the mask.  The rectangle can
//                               be given in two different forms e.g. '10,15,80,250' specifies a
//                               rectangle with 10 >= x > 80 and 15 >= y > 250 and
//                               e.g. '120x80@20,30' specifies a rectangle of width 120 pixels and
//                               height 80 pixels centered at x=20, y=30
//                               All coordinates must be integers
	variable Dim1Left, Dim2Left, Dim1Right, Dim2Right
	if(GrepString(MaskSpecs, "x"))		//this is e.g. '120x80@20,30' specifies a rectangle of width 120 pixels and
		string SizeSpecs=StringFromList(0, MaskSpecs+"@", "@")
		string CenterSpecs=StringFromList(1, MaskSpecs+"@", "@")
		variable width=str2num(StringFromList(0, SizeSpecs+"x", "x"))
		variable height=str2num(StringFromList(1, SizeSpecs+"x", "x"))
		variable dim1Center=str2num(StringFromList(0, CenterSpecs+",", ","))
		variable dim2Center=str2num(StringFromList(1, CenterSpecs+",", ","))
		Dim1Left = dim1Center - ceil(width/2)
		Dim2Left = dim2Center - ceil(height/2)
		Dim1Right = dim1Center + ceil(width/2)
		Dim2Right = dim2Center + ceil(height/2)
	else			//assume '10,15,80,250' specifies a
		MaskSpecs = MaskSpecs+","
		Dim1Left = str2num(StringFromList(0, MaskSpecs, ","))
		Dim2Left = str2num(StringFromList(1, MaskSpecs, ","))
		Dim1Right = str2num(StringFromList(2, MaskSpecs, ","))
		Dim2Right = str2num(StringFromList(3, MaskSpecs, ","))
	endif
	if(Dim1Left>Dim1Right)
		variable tmp1=Dim1Left
		Dim1Left = Dim1Right
		Dim1Right = tmp1
	endif
	if(Dim2Left>Dim2Right)
		variable tmp2=Dim2Left
		Dim2Left = Dim2Right
		Dim2Right = tmp2
	endif
	Dim1Left = Dim1Left>0 ? Dim1Left : 0
	Dim2Left = Dim2Left>0 ? Dim2Left : 0
	Dim1Right = Dim1Right<DimSize(MaskWave,0) ? Dim1Right : DimSize(MaskWave,0)-1
	Dim2Right = Dim2Right<DimSize(MaskWave,1) ? Dim2Right : DimSize(MaskWave,1)-1
	if(MaskIt)
		MaskWave[Dim1Left,Dim1Right][Dim2Left,Dim2Right] = 0
	else
		MaskWave[Dim1Left,Dim1Right][Dim2Left,Dim2Right] = 1
	endif
end



//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_12IDC_Parsegoldnormengavg(CommandLine, LoadInNIka)
	string CommandLine
	variable LoadInNIka
	
	Variable PixSize,Distance,n3,n4,n5,BCX,BCY
	String s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16
	
	// goldaverage -o Averaged_norm -y -p 0.175 -d 2345 -Z 200 -k $normval -e $energyval -r146,915,158,980 -r143,980,164,1024 -r 0,908,1024,914 -c6@166,907 -c12@154,911 154 911 $filename
						//s1,s2,s3,s4,s5,pixSize,s6,Distance,s6,n3,s7,s8,s9,s10,s11,s12,s13,s14,n4,n5,s16
	sscanf CommandLine,"%s %s %s %s %s %f %s %f %s %f %s %s %s %s %s %s %s %s %f %f %s",s1,s2,s3,s4,s5,pixSize,s6,Distance,s6,n3,s7,s8,s9,s10,s11,s12,s13,s14,n4,n5,s16
	//this shoudl get us Distacne and pix size. 
	string ReadEndStr=ReplaceString(" ", CommandLine, ";")
	BCX=str2num(StringFromList((ItemsInList(ReadEndStr)-3), ReadEndStr))
	BCY=str2num(StringFromList((ItemsInList(ReadEndStr)-2), ReadEndStr))
	if(numType(BCX)==2 || numtype(BCY)==2 || numtype(pixSIze)==2)
		Print "bad format line: "+CommandLine		
	endif
	//the pixel size of the Gold detector is 0.175 micron
	NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY
	NVAR SampleToCCDDistance =root:Packages:Convert2Dto1D:SampleToCCDDistance
	NVAR BcentX = root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BcentY = root:Packages:Convert2Dto1D:BeamCenterY
	if(LoadInNIka)
		PixelSizeX = pixSize
		PixelSizeY = pixSize
		SampleToCCDDistance = Distance
		BcentX = BCX
		BcentY = BCY
		print "Loaded distacne from command file of : "+num2str(SampleToCCDDistance)+" mm"
		print "Loaded Pixel Size from command file of : "+num2str(PixelSizeX)+" mm"
		print "Loaded Beam Center X from command file of : "+num2str(BcentX)+" pix"
		print "Loaded Beam Center Y from command file of : "+num2str(BcentY)+" pix"	
	else
		print "Found distacne in command file  : "+num2str(Distance)+" mm"
		print "Found Pixel Size in command file  : "+num2str(pixSize)+" mm"
		print "Found Beam Center X in command file  : "+num2str(BCX)+" pix"
		print "Found Beam Center Y in command file  : "+num2str(BCY)+" pix"	
	endif
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_12IDCReadSpecFile(NumFilesExpected)
	Variable NumFilesExpected
	
	string OldDFf
	OldDFf = getDataFolder(1)

	Variable refNum,err=0
	string pathInforStrL
	OPEN/R/T="????"/M="Find spec file" refNum
	//abort
	//OPEN/R/F="All Files:.*;"/M="Find spec file" refNum
	//OPEN/R/M="Find spec file" refNum
	if(strlen(S_fileName)>0)
		//init paths to the place where this file is... 
		SVAR specCalibDataName=root:Packages:Convert2Dto1D:specCalibDataName
		specCalibDataName = S_fileName
		pathInforStrL = RemoveListItem((ItemsInList(S_fileName,":")-1),S_fileName,":")
		NI1_12IDCinitSpecFileArrays(NumFilesExpected)			// max number of expected atoms
		Wave ExpTime=root:Packages:Nika_12IDCLookups:ExpTime
		Wave/T tt=root:Packages:Nika_12IDCLookups:Filenames
		String lineStr
		Variable count=0
		do
			FreadLine refNum,lineStr
			if(strlen(lineStr)<=0)
				//break
				err=1
			endif
			if(strsearch(lineStr,"#Z",0)>=0)
				NI1_12IDCprocessSpecLine(lineStr,count)
				count+=1
				if(NumFilesExpected<=count)
					NumFilesExpected+=100
					NI1_12IDCredimSpecFileArrays(NumFilesExpected)
				endif
			endif
		while(err==0)
		Close refNum
		// trim the waves to final sizes:
		NI1_12IDCredimSpecFileArrays(count)
	else
		//Close refNum
		abort
	endif
	NewPath/O/Q Convert2Dto1DDataPath, pathInforStrL		
	NewPath/O/Q Convert2Dto1DEmptyDarkPath, pathInforStrL		
	NewPath/O/Q Convert2Dto1DBmCntrPath, pathInforStrL
	NewPath/O/Q Convert2Dto1DMaskPath, pathInforStrL
	
	setDataFolder OldDFf
	
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1_12IDCinitSpecFileArrays(num)
	Variable num
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S Nika_12IDCLookups
	
	Make/O/D/n=(num) ExpTime=nan
	Make/O/D/n=(num) I0=nan
	Make/O/D/n=(num) ITR=nan
	Make/O/D/n=(num) I01=nan
	Make/O/D/n=(num) MP1=nan
	Make/O/D/n=(num) MP2=nan
	Make/O/D/n=(num) MP3=nan
	Make/O/D/n=(num) MP4=nan
	Make/O/D/n=(num) MP5=nan
	Make/O/D/n=(num) MonoEnenergy=nan
	Make/O/D/n=(num) LakeShoreTemp=nan
	Make/O/T/n=(num) TimeString=""
	Make/O/D/n=(num) UnixTime=nan
	Make/O/T/n=(num) Filenames=""
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_12IDCredimSpecFileArrays(num)
	Variable num
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S Nika_12IDCLookups

	Wave ExpTime=root:Packages:Nika_12IDCLookups:ExpTime
	Wave I0=root:Packages:Nika_12IDCLookups:I0
	Wave ITR=root:Packages:Nika_12IDCLookups:ITR
	Wave I01=root:Packages:Nika_12IDCLookups:I01
	Wave MP1=root:Packages:Nika_12IDCLookups:MP1
	Wave MP2=root:Packages:Nika_12IDCLookups:MP2
	Wave MP3=root:Packages:Nika_12IDCLookups:MP3
	Wave MP4=root:Packages:Nika_12IDCLookups:MP4
	Wave MP5=root:Packages:Nika_12IDCLookups:MP5
	Wave MonoEnenergy=root:Packages:Nika_12IDCLookups:MonoEnenergy
	Wave LakeShoreTemp=root:Packages:Nika_12IDCLookups:LakeShoreTemp
	Wave UnixTime=root:Packages:Nika_12IDCLookups:UnixTime
	Redimension/E=1/N=(num) ExpTime, I0, ITR, I01, MP1, MP2, MP3, MP4, MP5, MonoEnenergy, LakeShoreTemp, UnixTime
	Wave/T Filenames=root:Packages:Nika_12IDCLookups:Filenames
	Wave/T TimeString=root:Packages:Nika_12IDCLookups:TimeString
	Redimension/E=1/N=(num) TimeString, Filenames
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_12IDCprocessSpecLine(lineStr,count)
	String lineStr
	Variable count
	
	Variable n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,untime
	String s1,s2,s3,s4,s5,s6,s7
	
	//sscanf lineStr,"%s %d %s %s %s %d %f %f %f %f %f %s",s1,n1,s2,s3,s4,n2,xx,yy,zz,n4,n5,s5
	sscanf lineStr,"%s %s %f %f %f %f %f %f %f %f %f %f %f %f %s %s %s %s %s %f",s1,s2,n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,s3,s4,s5,s6,s7,untime
	if(numType(n1)==2 || numtype(n2)==2 || numtype(untime)==2)
		Print "bad format line: "+lineStr		
	endif
	Wave ExpTime=root:Packages:Nika_12IDCLookups:ExpTime
	Wave I0=root:Packages:Nika_12IDCLookups:I0
	Wave ITR=root:Packages:Nika_12IDCLookups:ITR
	Wave I01=root:Packages:Nika_12IDCLookups:I01
	Wave MP1=root:Packages:Nika_12IDCLookups:MP1
	Wave MP2=root:Packages:Nika_12IDCLookups:MP2
	Wave MP3=root:Packages:Nika_12IDCLookups:MP3
	Wave MP4=root:Packages:Nika_12IDCLookups:MP4
	Wave MP5=root:Packages:Nika_12IDCLookups:MP5
	Wave MonoEnenergy=root:Packages:Nika_12IDCLookups:MonoEnenergy
	Wave LakeShoreTemp=root:Packages:Nika_12IDCLookups:LakeShoreTemp
	Wave UnixTime=root:Packages:Nika_12IDCLookups:UnixTime
	Wave/T Filenames=root:Packages:Nika_12IDCLookups:Filenames
	Wave/T TimeString=root:Packages:Nika_12IDCLookups:TimeString
	Filenames[count] = s2
	ExpTime[count] = n1-0.5
	I0[count] = n2
	ITR[count] = n3
	I01[count] = n4
	MP1[count] = n6
	MP2[count] = n7
	MP3[count] = n8
	MP4[count] = n9
	MP5[count] = n10
	MonoEnenergy[count] = n11
	LakeShoreTemp[count] = n12
	TimeString[count] = s3+" "+s4+" "+s5+" "+s6+" "+s7
	UnixTime[count] = untime
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_12IDCFindI0(FileNameString)
	string FileNameString
	Wave/T Filenames=root:Packages:Nika_12IDCLookups:Filenames
	Wave I0=root:Packages:Nika_12IDCLookups:I0
	grep/INDX/Q/E=FileNameString Filenames	
	wave W_Index
	//let use this place to also insert energy
	Wave MonoEnenergy = root:Packages:Nika_12IDCLookups:MonoEnenergy
	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength
	NVAR XrayEnergy = root:Packages:Convert2Dto1D:XrayEnergy
	XrayEnergy = MonoEnenergy[W_Index[0]]
	Wavelength = 12.39841857/XrayEnergy
	if(numpnts(W_Index)==1)
		return I0[W_Index[0]]
	else
		return nan
	endif
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_12IDCFindEmptyI0(FileNameString)
	string FileNameString
	SVAR CurrentEmptyName = root:Packages:Convert2Dto1D:CurrentEmptyName
	Wave/T Filenames=root:Packages:Nika_12IDCLookups:Filenames
	Wave I0=root:Packages:Nika_12IDCLookups:I0
	grep/INDX/Q/E=CurrentEmptyName Filenames	
	wave W_Index
	if(numpnts(W_Index)==1)
		return I0[W_Index[0]]
	else
		return nan
	endif
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_12IDCFindTrans(FileNameString)
	string FileNameString
	SVAR CurrentEmptyName = root:Packages:Convert2Dto1D:CurrentEmptyName
	Wave/T Filenames=root:Packages:Nika_12IDCLookups:Filenames
	Wave I0=root:Packages:Nika_12IDCLookups:I0
	Wave ITR =root:Packages:Nika_12IDCLookups:ITR
	grep/INDX/Q/E=CurrentEmptyName Filenames	
	wave W_Index
	variable I0E = I0[W_Index[0]]
	variable ITRE = ITR[W_Index[0]]
	grep/INDX/Q/E=FileNameString Filenames	
	wave W_Index
	variable I0S = I0[W_Index[0]]
	variable ITRS = ITR[W_Index[0]]
	variable Transm = (ITRS/I0S)/(ITRE/I0E)
	
	if(numtype(Transm)==0 && Transm>0)
		return Transm
	else
		return nan
	endif
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_12IDCHowTo()
	
	doWIndow APS12IDC_Instructions
	if(V_Flag)
		DoWIndow/F APS12IDC_Instructions
	else
		String nb = "APS12IDC_Instructions"
		NewNotebook/N=$nb/F=1/V=1/K=1/ENCG={1,1}/W=(20,20,680,620) as "APS12IDC_Instructions"
		Notebook $nb defaultTab=36, magnification=125
		Notebook $nb showRuler=1, rulerUnits=2, updating={1, 1}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Helvetica",11,0,(0,0,0)}
		Notebook $nb newRuler=Title, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",12,3,(0,0,0)}
		Notebook $nb ruler=Title, text="Instructions for use of APS 12IDC special configuration\r"
		Notebook $nb ruler=Normal, text="\r"
		Notebook $nb text="\r"
		Notebook $nb text="1. Find and open your spec file, located in the same folder as your tiff images. Note, data collection records f"
		Notebook $nb text="or all images present in that spec file are loaded, this may take some time if there is lots of images recorded in that spec file."
		Notebook $nb text=" \r"
		Notebook $nb text="\r"
		Notebook $nb text="2. If the code can find  \"goldnormengavg\" file in this location, you will get dialog that \"Beamline para"
		Notebook $nb text="ms & mask was found\". Choices are \"Load beamline parameters\" and  \"Create beamline defined mask?\", default choice is NO.\r"
		Notebook $nb text="* If you select YES for \"Load beamline parameters\" code will load pixel size, distance and beam center.\r"
		Notebook $nb text="* If you select YES for \"Create beamline defined mask?\" code will replace any existing mask with beamline"
		Notebook $nb text=" defined mask.\r"
		Notebook $nb text="Select No if you changed parameters or mask against what beamline defined. \r"
		Notebook $nb text="\r"
		Notebook $nb text=">>>  MASK suggestion: Create new Mask in Nika, DO NOT reuse old beamline mask. Nika has easier to use tools to create the best possible mask. <<<\r"
		Notebook $nb text="\r"
		Notebook $nb text="note: X-ray energy is re-loaded for each image individually, when I0 is looked up by the lookup function"
		Notebook $nb text=". This guarantees, that during ASAXS each image is reduced with correct wavelength. \r"
		Notebook $nb text="\r"
		Notebook $nb text="3. If you choose to create Mask, you will get dialog to load any of the data images from this folder."
		Notebook $nb text="This is needed to identify 0 intensity pixels and mask them. Select any data containing image"
		Notebook $nb text=" in this folder. \r"
		Notebook $nb text="\r"
		Notebook $nb text="4. Next select correct Empty image in the Em/Dark tab. \r"
		Notebook $nb text="\r"
		Notebook $nb text="Nika should be configured - you may want to change method of data reduction (default is circular average with 300 log-spaced Q bins)"
		Notebook $nb text=" and output type (default is save data in Igor)...  \r"
		Notebook $nb text="\r"
		Notebook $nb text="Note: if you are still collecting data, you will need to go through this routine again after you callect new"
		Notebook $nb text=" images from the last time you loaded the spec file. "
		Notebook $nb text="\r"
		Notebook $nb text="\r"
		Notebook $nb text="Jan Ilavsky, 8/27/2018\r"
		Notebook $nb text="\r"
		Notebook $nb defaultTab=36, magnification=125
		Notebook $nb showRuler=1, rulerUnits=2, updating={1, 1}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Helvetica",11,0,(0,0,0)}
		Notebook $nb ruler=Normal, fStyle=2, text="Hint: watch history area for notes on what Nika has found and done. \r"
		Notebook $nb selection={startOfFile,startOfFile}
		
	endif
end

//*******************************************************************************************************************************************
//			end of 12ID-C camera support. 
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//		APS 12ID-B camera SAXS and WAXS (not test for PE yet)

Function NI1_12IDBLoadAndSetup()
	//this is function to setup data reduction for APS 12ID-B station using SAXS and WAXS detectors
	//uses 12IDB_tif file type
	
	string OldDFf=GetDataFolder(1)
	//first initialize 
	KillWindow/Z CCDImageToConvertFig
	NI1A_Convert2Dto1DMainPanel()
	NI1BC_InitCreateBmCntrFile()
	NI1_12IDBHowTo()

	setDataFOlder root:Packages:Convert2Dto1D:
	NI1A_ButtonProc("Select2DDataPath")
	PathInfo Convert2Dto1DDataPath
	string DataFilePath=S_path
	NewPath/Q/O Convert2Dto1DEmptyDarkPath, S_path	
	String DoingWhat= StringFromList(ItemsInList(DataFilePath,":")-1, DataFilePath,":")
	//now we need to get idea, what the user wants to do. 
	//Options: tif/nexus
	//SAXS/WAXS ?
	//Mask - which from selection or none? 
	//Load parameters always or only first time. 
	//now get user input and load parameters and mask...
	NI1_12IDBGetUserInput()	
	NVAR APS12IDBProcMethod				//0 for beamline method (no background), 1 for Nika standard (with background). 
	NVAR APS12IDBReloadPars				//Parameterrs - 0 for not reloading calibration parameters, 1 for reload with each data file. 
	SVAR APS12IDBDataType 				// = "12IDB_tif"		//default for tiff files. May change to Nexus later when that is standard. 
	//SVAR APS12IDBMask 			// = "---"					//default for none. User needs to create one in Nika
	//SVAR APS12IDBGeometry			//SAXS or WAXS? 

	
	SVAR DataFileExtension=root:Packages:Convert2Dto1D:DataFileExtension
	SVAR BlankFileExtension=root:Packages:Convert2Dto1D:BlankFileExtension
	BlankFileExtension = APS12IDBDataType
	//select the right type of data
	DataFileExtension = APS12IDBDataType
	PopupMenu Select2DDataType win=NI1A_Convert2Dto1DPanel, popmatch= APS12IDBDataType
	NVAR UseSampleTransmission = root:Packages:Convert2Dto1D:UseSampleTransmission
	NVAR UseSampleThickness = root:Packages:Convert2Dto1D:UseSampleThickness
	NVAR UseEmptyField = root:Packages:Convert2Dto1D:UseEmptyField
	NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate

	NVAR DoGeometryCorrection = root:Packages:Convert2Dto1D:DoGeometryCorrection
	NVAR UseMonitorForEf = root:Packages:Convert2Dto1D:UseMonitorForEf
	NVAR UseSampleTransmFnct = root:Packages:Convert2Dto1D:UseSampleTransmFnct
	NVAR UseSampleThicknFnct = root:Packages:Convert2Dto1D:UseSampleThicknFnct
	NVAR UseSampleMonitorFnct = root:Packages:Convert2Dto1D:UseSampleMonitorFnct
	NVAR UseEmptyMonitorFnct = root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
	NVAR UseMonitorForEF=root:Packages:Convert2Dto1D:UseMonitorForEF
	NVAR XrayEnergy = root:Packages:Convert2Dto1D:XrayEnergy
	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength
	NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY
	NVAR SampleToCCDdistance = root:Packages:Convert2Dto1D:SampleToCCDdistance
	NVAR BeamCenterX = root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY = root:Packages:Convert2Dto1D:BeamCenterY
	NVAR UseCorrectionFactor = root:Packages:Convert2Dto1D:UseCorrectionFactor
	NVAR CorrectionFactor = root:Packages:Convert2Dto1D:CorrectionFactor
	NVAR UseSolidAngle = root:Packages:Convert2Dto1D:UseSolidAngle
	SVAR SampleTransmFnct = root:Packages:Convert2Dto1D:SampleTransmFnct
	SVAR SampleThicknFnct = root:Packages:Convert2Dto1D:SampleThicknFnct
	SVAR SampleMonitorFnct = root:Packages:Convert2Dto1D:SampleMonitorFnct
	SVAR EmptyMonitorFnct = root:Packages:Convert2Dto1D:EmptyMonitorFnct
	
	NVAR ErrorCalculationsUseSEM = root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
	NVAR ErrorCalculationsUseStdDev = root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
	NVAR ErrorCalculationsUseOld = root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
	
	NVAR NX_ReadParametersOnLoad = root:Packages:Irena_Nexus:NX_ReadParametersOnLoad

	if(StringMatch(APS12IDBDataType, "12IDB_tif" ))	
		//setup configuration how this will be done here:
		
		ErrorCalculationsUseOld = 0
		ErrorCalculationsUseStdDev = 0
		ErrorCalculationsUseSEM = 1
		
		if(APS12IDBProcMethod)
			UseSampleTransmission = 1
			UseSampleThickness = 0
			UseEmptyField = 1
			UseI0ToCalibrate = 1
			DoGeometryCorrection = 1
			UseMonitorForEf = 1
		
			UseSampleThicknFnct  =1
			UseSampleTransmFnct = 1
		//	UseSampleThicknFnct =1
			UseSampleMonitorFnct = 1
			UseEmptyMonitorFnct = 1
			
			UseCorrectionFactor = 0
			CorrectionFactor = 1
			UseSolidAngle = 0
			
			SampleTransmFnct = "NI1_12IDBGetTranmsission"
			SampleMonitorFnct = "NI1_12IDBGetSampleI0" 
			EmptyMonitorFnct = "NI1_12IDBGetEmptyI0"
		else //no background subtraction
			UseSampleTransmission = 0
			UseSampleThickness = 0
			UseEmptyField = 0
			UseI0ToCalibrate = 1
			DoGeometryCorrection = 1
			UseMonitorForEf = 0
		
			UseSampleThicknFnct  = 0
			UseSampleTransmFnct = 0
		//	UseSampleThicknFnct =1
			UseSampleMonitorFnct = 1
			UseEmptyMonitorFnct = 0
	
			UseCorrectionFactor = 1
			CorrectionFactor = 2.4e-06			//this should be fudge factor 12IDB is using to correct data to 0.1-100 intensity range... 
			UseSolidAngle = 1						//thsi is needed for that fudge factor above. 
			
			SampleTransmFnct = ""
			SampleMonitorFnct = "NI1_12IDBGetSampleBS" 
			EmptyMonitorFnct = ""
	
		endif
	
	
	else //NEXUS
			NEXUS_ResetParamXRef(1)
			NEXUS_GuessParamXRef()
			Wave/T ListOfParamsAndPaths = root:Packages:Irena_Nexus:ListOfParamsAndPaths
			Wave ListOfParamsAndPathsSel = root:Packages:Irena_Nexus:ListOfParamsAndPathsSel
			//configrue Nexus to match what they are using...
			ListOfParamsAndPaths[0][0]="UserSampleName"
			ListOfParamsAndPaths[0][1]=	"---"
			ListOfParamsAndPaths[1][0]="SampleThickness"
			ListOfParamsAndPaths[1][1]=	":entry:sample:thickness"
			ListOfParamsAndPaths[2][0]="SampleTransmission"
			ListOfParamsAndPaths[2][1]=	"---"
			ListOfParamsAndPaths[3][0]="SampleI0"
			ListOfParamsAndPaths[3][1]=	":entry:Metadata:It_phd"
			ListOfParamsAndPaths[4][0]="SampleMeasurementTime"
			ListOfParamsAndPaths[4][1]=	"---"
			ListOfParamsAndPaths[5][0]="SampleToCCDDistance"
			ListOfParamsAndPaths[5][1]=	":entry:instrument:detector:distance"
	
			ListOfParamsAndPaths[6][0]="Wavelength"
			ListOfParamsAndPaths[6][1]=	":entry:instrument:monochromator:wavelength"
			ListOfParamsAndPaths[7][0]="XrayEnergy"
			ListOfParamsAndPaths[7][1]=	":entry:instrument:monochromator:energy"
			ListOfParamsAndPaths[8][0]="BeamCenterX"
			ListOfParamsAndPaths[8][1]=	":entry:instrument:detector:beam_center_x"
			ListOfParamsAndPaths[9][0]="BeamCenterY"
			ListOfParamsAndPaths[9][1]=	":entry:instrument:detector:beam_center_y"
			ListOfParamsAndPaths[10][0]="BeamSizeX"
			ListOfParamsAndPaths[10][1]=	"---"
			ListOfParamsAndPaths[11][0]="BeamSizeY"
			ListOfParamsAndPaths[11][1]=	"---"

			ListOfParamsAndPaths[12][0]="PixelSizeX"
			ListOfParamsAndPaths[12][1]=	":entry:instrument:detector:det_pixel_size"
			ListOfParamsAndPaths[13][0]="PixelSizeY"
			ListOfParamsAndPaths[13][1]=	":entry:instrument:detector:det_pixel_size"
			ListOfParamsAndPaths[14][0]="HorizontalTilt"
			ListOfParamsAndPaths[14][1]=	"---"
			ListOfParamsAndPaths[15][0]="VerticalTilt"
			ListOfParamsAndPaths[15][1]=	"---"
			ListOfParamsAndPaths[16][0]="CorrectionFactor"
			ListOfParamsAndPaths[16][1]=	":entry:Metadata:AbsIntCoeff"
	
	
			NX_ReadParametersOnLoad = 1

 			SVAR RotateFLipImageOnLoad=root:Packages:Convert2Dto1D:RotateFLipImageOnLoad
			RotateFLipImageOnLoad = "Tran/FlipH"	
		ErrorCalculationsUseOld = 0
		ErrorCalculationsUseStdDev = 0
		ErrorCalculationsUseSEM = 1
		
		if(APS12IDBProcMethod)
			UseSampleTransmission = 1
			UseSampleThickness = 1
			UseEmptyField = 1
			UseI0ToCalibrate = 1
			DoGeometryCorrection = 1
			UseMonitorForEf = 1
		
			UseSampleThicknFnct  = 0
			UseSampleTransmFnct = 1
		//	UseSampleThicknFnct =1
			UseSampleMonitorFnct = 1
			UseEmptyMonitorFnct = 1
			
			UseCorrectionFactor = 0
			CorrectionFactor = 1
			UseSolidAngle = 0
			
			SampleTransmFnct = "NI1_12IDBNexGetTranmsission"
			SampleMonitorFnct = "NI1_12IDBNexGetSampleI0" 
			EmptyMonitorFnct = "NI1_12IDBNexGetEmptyI0"
		else //no background subtraction
			UseSampleTransmission = 0
			UseSampleThickness = 0
			UseEmptyField = 0
			UseI0ToCalibrate = 1
			DoGeometryCorrection = 1
			UseMonitorForEf = 0
		
			UseSampleThicknFnct  = 0
			UseSampleTransmFnct = 0
			UseSampleThicknFnct =0
			UseSampleMonitorFnct = 0
			UseEmptyMonitorFnct = 0
	
			UseCorrectionFactor = 1
			CorrectionFactor = 2.4e-06			//this should be fudge factor 12IDB is using to correct data to 0.1-100 intensity range... 
			UseSolidAngle = 1						//thsi is needed for that fudge factor above. 
			
			SampleTransmFnct = ""
			SampleMonitorFnct = "NI1_12IDBGetSampleBS" 
			EmptyMonitorFnct = ""
	
		endif
		
	endif
	
	
	//now configure Nika to produce some data...
	NVAR DisplayDataAfterProcessing = root:Packages:Convert2Dto1D:DisplayDataAfterProcessing
	DisplayDataAfterProcessing=1
	NVAR StoreDataInIgor = root:Packages:Convert2Dto1D:StoreDataInIgor
	StoreDataInIgor=1
	NVAR OverwriteDataIfExists = root:Packages:Convert2Dto1D:OverwriteDataIfExists
	OverwriteDataIfExists=1
	NVAR UseSectors=root:Packages:Convert2Dto1D:UseSectors
	UseSectors =1
	NVAR DoCircularAverage = root:Packages:Convert2Dto1D:DoCircularAverage
	DoCircularAverage = 1
	NVAR QvectorMaxNumPnts = root:Packages:Convert2Dto1D:QvectorMaxNumPnts
	NVAR QbinningLogarithmic = root:Packages:Convert2Dto1D:QbinningLogarithmic
	NVAR QvectorNumberPoints = root:Packages:Convert2Dto1D:QvectorNumberPoints
	if(stringmatch(DoingWhat,"SAXS"))
		QbinningLogarithmic=1
		//QvectorMaxNumPnts=0
		//QvectorNumberPoints = 600
		//these are set by configuration file now. 
	else
		//WAXS
		QbinningLogarithmic=0
		QvectorMaxNumPnts=1
	endif
	if(APS12IDBProcMethod)
		//send user to Empty/Dark tab
		TabControl Convert2Dto1DTab win=NI1A_Convert2Dto1DPanel, value=3
		NI1A_TabProc("NI1A_Convert2Dto1DPanel",3)	
	else
		//send user to Empty/Dark tab
		TabControl Convert2Dto1DTab win=NI1A_Convert2Dto1DPanel, value=0
		NI1A_TabProc("NI1A_Convert2Dto1DPanel",0)	
	endif
	setDataFolder OldDFf

end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_12IDBGetUserInput()			//todo: some error handling... 
		//should be able to find mask in current working folder	
	string OldDFf=GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D:
	NVAR UseMask = root:Packages:Convert2Dto1D:UseMask
	//Init needed APS12IDB... Parameters 
	variable/g APS12IDBProcMethod = 0				//0 for beamline method (no background), 1 for Nika standard (with background). 
	variable/g APS12IDBReloadPars = 0				//Parameterrs - 0 for not reloading calibration parameters, 1 for reload with each data file. 
	string/g APS12IDBDataType = "12IDB_tif"			//default for tiff files. May change to Nexus later when that is standard. 
	//string/g APS12IDBMask = "---"					//default for none. User needs to create one in Nika
	string/g APS12IDBGeometry = "SAXS"				//SAXS or WAXS? 
	//Get what we are using here... 
	PathInfo Convert2Dto1DDataPath
	string DataFilePath=S_path
	//here we know what we are processing... Either the last folder is SAXS or WAXS 
	string UsingWhat=StringFromList(ItemsInList(DataFilePath,":")-1, DataFilePath,":")
	if(StringMatch(UsingWhat, "SAXS"))
		APS12IDBGeometry = "SAXS"
	elseif(StringMatch(UsingWhat, "WAXS"))
		APS12IDBGeometry = "WAXS"
	else
		abort "Wrong folder with data selected, this folder is not called SAXS or WAXS"
	endif
	//now what type of files are we using? 
	string ListOfTifFiles=IndexedFile(Convert2Dto1DDataPath, -1, ".tif")
	string ListOfHDF5Files=IndexedFile(Convert2Dto1DDataPath, -1, ".hdf")+IndexedFile(Convert2Dto1DDataPath, -1, ".h5")
	if(itemsInList(ListOfTifFiles)>0)
		APS12IDBDataType = "12IDB_tif"
	elseif(itemsInList(ListOfHDF5Files)>0)
		APS12IDBDataType = "Nexus"
	else
		abort "Unknown image data file type. Can read tif or hdf (Nexus) only."
	endif
	
	string ListOfBMPFiles
	string SelectedMaskFile 
	string LoadCalibration
	string LoadMaskFile
	string AlwaysReloadParameters
	string ProcessingTypeStr
	string MaskPathStr

	//this is ONLY for tiff files... 
	if(StringMatch(APS12IDBDataType,"12IDB_tif"))
				//get calibration files. 
				//get the path to calibration and SAXS_mask2M.bmp or WAXS_mask2M.bpm, it is one level up...
				MaskPathStr= RemoveFromList(UsingWhat, DataFilePath,":")
				NewPath/O/Q TempMaskUserPath, MaskPathStr
				string ListOfCalibrations=GrepList(IndexedFile(TempMaskUserPath, -1, ".txt"), "(?i)calibration_parameters")
				string SelectedCalibrationFile =RemoveEnding(GrepList(ListOfCalibrations,"(?i)"+UsingWhat), ";") 		//this now should be saxs_calibration_parameters or waxs_calibration_parameters
				print SelectedCalibrationFile
				//get the mask files... 
				//mask may or may not exist, we need to get user to pick one or tell us it does not exist...
				ListOfBMPFiles=IndexedFile(TempMaskUserPath, -1, ".bmp")
				SelectedMaskFile = RemoveEnding(GrepList(ListOfBMPFiles,"(?i)"+UsingWhat),";")
				
				//dialog...
				
				Prompt LoadCalibration, "Load calibration from "+SelectedCalibrationFile+"?", popup, "Yes;No;"
				if(strlen(SelectedMaskFile)>0)
					Prompt LoadMaskFile, "Load BMP Mask file "+SelectedMaskFile+"?", popup, "Yes;No;"
				else
					Prompt LoadMaskFile, "No Mask file found", popup, "No;"
				endif
				Prompt ProcessingTypeStr, "Subtract Empty/background ?", popup, "No;Yes;"
				Prompt AlwaysReloadParameters, "Reload geometry for each image ?", popup, "No;Yes;"
				DoPrompt "Setup parameters", ProcessingTypeStr, LoadCalibration, AlwaysReloadParameters, LoadMaskFile
				if(V_Flag)
						abort
				else
						//setup processing method
						if(stringMatch(ProcessingTypeStr,"Yes"))
							APS12IDBProcMethod = 1			//subtract background (materials SAXS common). 
						else
							APS12IDBProcMethod = 0			//do not subtract background (bioSAXS common)
						endif
						//Reload metadata always? 
						if(stringMatch(AlwaysReloadParameters,"Yes"))
							APS12IDBReloadPars = 1			//reload metadata with each image? 
						else
							APS12IDBReloadPars = 0			//do not reload metadata with each image
						endif
						//mask... 
					 	if(stringmatch(LoadMaskFile,"Yes"))
							ImageLoad/T=bmp/Q/N=TMPBMPMask/Z/P=TempMaskUserPath SelectedMaskFile
							if(V_Flag)
								print ":Loaded succesfully mask file from "+MaskPathStr+SelectedMaskFile
							else
								DoALert/T="Could not load Mask file" 0, "Could not load selected file with mask, you need to create mask manually"
								UseMask = 0
							endif
							Wave LoadedmaskImage = TMPBMPMask
							ImageTransform rgb2gray LoadedmaskImage
							Wave M_RGB2Gray
							ImageTransform flipCols M_RGB2Gray			//this is correct flip needed...
							DoWIndow CCDImageToConvertFig
							if(V_Flag)
								RemoveImage/W=CCDImageToConvertFig/Z  M_ROIMask
							endif
							KillWaves/Z M_ROIMask, TMPBMPMask
							wavestats/Q M_RGB2Gray
							M_RGB2Gray/=V_max				//normalize to be 1 or 0, seem to be 255
							Rename M_RGB2Gray, M_ROIMask
							UseMask = 1
						else
							Wave M_ROIMask
							KillWaves/Z M_ROIMask
							UseMask = 0
							print "No Mask Loaded, user needs to setup their own "
						endif
						//parse the parameter file 
					 	if(stringmatch(LoadCalibration,"Yes"))
							NI1_12IDBLoadTXTMetadata(MaskPathStr, SelectedCalibrationFile)	
						else
							print "No calibration file loaded. You are on your own!!!" 
						endif
				endif
	else	//this is for Nexus, different setup
		//get the path to calibration and SAXS_mask2M.bmp or WAXS_mask2M.bpm, it is one level up...
		MaskPathStr= RemoveFromList(UsingWhat, DataFilePath,":")
		NewPath/O/Q TempMaskUserPath, MaskPathStr
		//get the mask files... 
		//mask may or may not exist, we need to get user to pick one or tell us it does not exist...
		ListOfBMPFiles=IndexedFile(TempMaskUserPath, -1, ".bmp")
		SelectedMaskFile = RemoveEnding(GrepList(ListOfBMPFiles,"(?i)"+UsingWhat),";")
		
//		Prompt LoadCalibration, "Load calibration from "+SelectedCalibrationFile+"?", popup, "Yes;No;"
		if(strlen(SelectedMaskFile)>0)
			Prompt LoadMaskFile, "Load BMP Mask file "+SelectedMaskFile+"?", popup, "Yes;No;"
		else
			Prompt LoadMaskFile, "No Mask file found", popup, "No;"
		endif
		Prompt ProcessingTypeStr, "Subtract Empty/background ?", popup, "No;Yes;"
		//Prompt AlwaysReloadParameters, "Reload geometry for each image ?", popup, "No;Yes;"
		DoPrompt "Setup parameters", ProcessingTypeStr, LoadMaskFile
		if(V_Flag)
			abort
		else
			//setup processing method
			if(stringMatch(ProcessingTypeStr,"Yes"))
				APS12IDBProcMethod = 1			//subtract background (materials SAXS common). 
			else
				APS12IDBProcMethod = 0			//do not subtract background (bioSAXS common)
			endif
			//Reload metadata always? 
			//if(stringMatch(AlwaysReloadParameters,"Yes"))
			//	APS12IDBReloadPars = 1			//reload metadata with each image? 
			//else
			//	APS12IDBReloadPars = 0			//do not reload metadata with each image
			//endif
			//mask... 
		 	if(stringmatch(LoadMaskFile,"Yes"))
				ImageLoad/T=bmp/Q/N=TMPBMPMask/Z/P=TempMaskUserPath SelectedMaskFile
				if(V_Flag)
					print ":Loaded succesfully mask file from "+MaskPathStr+SelectedMaskFile
				else
					DoALert/T="Could not load Mask file" 0, "Could not load selected file with mask, you need to create mask manually"
					UseMask = 0
				endif
				Wave LoadedmaskImage = TMPBMPMask
				ImageTransform rgb2gray LoadedmaskImage
				Wave M_RGB2Gray
				ImageTransform flipCols M_RGB2Gray			//this is correct flip needed...
				DoWIndow CCDImageToConvertFig
				if(V_Flag)
					RemoveImage/W=CCDImageToConvertFig/Z  M_ROIMask
				endif
				KillWaves/Z M_ROIMask, TMPBMPMask
				wavestats/Q M_RGB2Gray
				M_RGB2Gray/=V_max				//normalize to be 1 or 0, seem to be 255
				Duplicate/O M_RGB2Gray, M_ROIMask; KillWaves M_RGB2Gray
				//the mask needs to be rotated...
				//this depends on how the image rotation is set in import AND how the beam center is written. For now (7-27-22) we have 
				// wrongly written centers. They use Matlab and write center after rotating image to natural location, so center in Nexus file does not match image in nexis file.
				//this shoudl be fixed, this is incorrect. 
				MatrixOp/O M_ROIMask = reverseRows(M_ROIMask)
				UseMask = 1
			else
				Wave M_ROIMask
				KillWaves/Z M_ROIMask
				UseMask = 0
				print "No Mask Loaded, user needs to setup their own "
			endif
			//parse the parameter file 
			 //	if(stringmatch(LoadCalibration,"Yes"))
			//		NI1_12IDBLoadTXTMetadata(MaskPathStr, SelectedCalibrationFile)	
			//	else
			//		print "No calibration file loaded. You are on your own!!!" 
			//	endif
		endif
	endif

	setDataFolder OldDFf	
	return APS12IDBProcMethod
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function/S NI1_12IDBLoadTXTMetadata(PathStr, FileNameToLoad)		
	string PathStr, FileNameToLoad
	
	NewPath/O/Q/Z LogFilesPath, PathStr
	variable refNum, err
	string OneLineStr, MetadataString="", newWaveNOte=""
	open/R/T="????"/P=LogFilesPath/Z refNum as FileNameToLoad
	if(V_flag!=0)
		close refNum
		Abort "Metadata import failed"
	else		//open succesful
		Do
			FreadLine refNum,OneLineStr
			if(strlen(OneLineStr)<=0)
				//break
				err=1
			endif
			MetadataString+=OneLineStr+";"
		while(err==0)
		Close refNum
	endif 
	MetadataString = ReplaceString("%", MetadataString, "")
	MetadataString = ReplaceString("\n", MetadataString, "")
	MetadataString = ReplaceString("\r", MetadataString, "")
	//MetadataString = ReplaceString(" ", MetadataString, "")
	string currentItemString
	variable i=0
	do
		currentItemString=StringFromList(i, MetadataString, ";")
		i+=1
		NI1_12IDBProcessTXTLine(currentItemString)
	while(strlen(currentItemString)>0)
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_12IDBProcessTXTLine(LineToProcess)
	string LineToProcess
	
	if(StringMatch(LineToProcess, "*[*]*" ))
		LineToProcess[strsearch(LineToProcess, " ", strsearch(LineToProcess, "[", 0))]=";" 
		LineToProcess = ReplaceString("[", LineToProcess, "")
		LineToProcess = ReplaceString("]", LineToProcess, "")
	endif
	
	LineToProcess=ReplaceString(" ", LineToProcess, "")+";"
	if(StringMatch(LineToProcess, "*row*" ))
		variable/g APS12IDBtempRow = NumberByKey("row", LineToProcess, ":", ";")
	endif
	if(StringMatch(LineToProcess, "*col*" ))
		variable/g APS12IDBtempCol = NumberByKey("col", LineToProcess, ":", ";")
	endif
	if(StringMatch(LineToProcess, "*pSize*" ))
		NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX
		NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY
		PixelSizeX = NumberByKey("pSize", LineToProcess, ":", ";")
		PixelSizeY = NumberByKey("pSize", LineToProcess, ":", ";")
	endif
	if(StringMatch(LineToProcess, "*SDD*" )&& !StringMatch(LineToProcess, "*SDDrel*" ))
		NVAR SampleToCCDdistance = root:Packages:Convert2Dto1D:SampleToCCDdistance
		SampleToCCDdistance = NumberByKey("SDD", LineToProcess, ":", ";")
	endif
	if(StringMatch(LineToProcess, "*BeamXY*" ))
		NVAR BeamCenterX = root:Packages:Convert2Dto1D:BeamCenterX
		NVAR BeamCenterY = root:Packages:Convert2Dto1D:BeamCenterY
		NVAR/Z APS12IDBtempRow
		if(!NVAR_Exists(APS12IDBtempRow))
			variable/g APS12IDBtempRow
			APS12IDBtempRow = 0
		endif
		//Again, THIS IS INVERTED...
		string TempStr=StringByKey("BeamXY", LineToProcess+"p", ":", "p")
		variable BCX, BCY
		BCX = str2num(StringFromList(0,TempStr,";"))
		BCY = str2num(StringFromList(1,TempStr,";"))
		BeamCenterY = APS12IDBtempRow - BCY		
		BeamCenterX = BCX
	endif
	if(StringMatch(LineToProcess, "*eng*" )&&!StringMatch(LineToProcess, "*wavelength*" )&&!StringMatch(LineToProcess, "*xeng*" ))
		NVAR XrayEnergy = root:Packages:Convert2Dto1D:XrayEnergy
		NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength
		XrayEnergy = NumberByKey("eng", LineToProcess, ":", ";")
		Wavelength = 12.39842/XrayEnergy
	endif
	if(StringMatch(LineToProcess, "*wavelength*" ))
		NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength
		Wavelength = NumberByKey("wavelength", LineToProcess, ":", ";")
	endif
	if(StringMatch(LineToProcess, "*yaw*" ))
		NVAR VerticalTilt = root:Packages:Convert2Dto1D:VerticalTilt
		//Again, THIS IS INVERTED...
		VerticalTilt = -1* NumberByKey("yaw", LineToProcess, ":", ";")		
	endif
	if(StringMatch(LineToProcess, "*absIntCoeff*" ))
		NVAR CorrectionFactor = root:Packages:Convert2Dto1D:CorrectionFactor
		//Again, THIS IS INVERTED...
		CorrectionFactor = 1e-6 * NumberByKey("absIntCoeff", LineToProcess, ":", ";")		
	endif
	if(StringMatch(LineToProcess, "*qNum*" ))
		NVAR QvectorNumberPoints = root:Packages:Convert2Dto1D:QvectorNumberPoints
		QvectorNumberPoints = NumberByKey("qNum", LineToProcess, ":", ";")		
	endif
	if(StringMatch(LineToProcess, "*qMin*" ))
		NVAR UserQMin = root:Packages:Convert2Dto1D:UserQMin
		UserQMin = NumberByKey("qMin", LineToProcess, ":", ";")		
	endif
	if(StringMatch(LineToProcess, "*qMax*" ))
		NVAR UserQMax = root:Packages:Convert2Dto1D:UserQMax
		UserQMax = NumberByKey("qMax", LineToProcess, ":", ";")		
	endif

	
	
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_12IDBGetTranmsission(fileName)
	string fileName

	wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	wave/Z EmptyData = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(CCDImageToConvert) || !WaveExists(EmptyData))
		abort "Needed Images do not exist. Load Sample and Emty data before going further"
	endif
	string sampleNote=note(CCDImageToConvert)
	sampleNote = ReplaceString(" ", sampleNote, "")
	string emptyNote=note(EmptyData)
	emptyNote = ReplaceString(" ", emptyNote, "")
	variable SampleBeamStopDiode=NumberByKey("Photodiode", sampleNote , ":" , ";")
	variable EmptyBeamStopDiode=NumberByKey("Photodiode", emptyNote , ":" , ";")
	variable SampleBeamStopI0=NumberByKey("I0", sampleNote , ":" , ";")
	variable EmptyBeamStopI0=NumberByKey("I0", emptyNote , ":" , ";")
	variable transmission = (SampleBeamStopDiode/SampleBeamStopI0)/(EmptyBeamStopDiode/EmptyBeamStopI0)
	print "Found transmission = "+num2str(transmission)
	return transmission
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_12IDBNexGetTranmsission(fileName)
	string fileName

	wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	wave/Z EmptyData = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(CCDImageToConvert) || !WaveExists(EmptyData))
		abort "Needed Images do not exist. Load Sample and Emty data before going further"
	endif
	string sampleNote=note(CCDImageToConvert)
	sampleNote = ReplaceString(" ", sampleNote, "")
	string emptyNote=note(EmptyData)
	emptyNote = ReplaceString(" ", emptyNote, "")
	variable SampleBeamStopDiode=NumberByKey("Metadata:It_phd", sampleNote , "=" , ";")
	variable EmptyBeamStopDiode=NumberByKey("Metadata:It_phd", emptyNote , "=" , ";")
	variable SampleBeamStopI0=NumberByKey("Metadata:IC1_phd", sampleNote , "=" , ";")
	variable EmptyBeamStopI0=NumberByKey("Metadata:IC1_phd", emptyNote , "=" , ";")
	variable transmission = (SampleBeamStopDiode/SampleBeamStopI0)/(EmptyBeamStopDiode/EmptyBeamStopI0)
	print "Found transmission = "+num2str(transmission)
	return transmission
end
//*******************************************************************************************************************************************

Function NI1_12IDBGetSampleBS(fileName)
	string fileName
	wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	//wave/Z EmptyData = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(CCDImageToConvert))// || !WaveExists(EmptyData))
		abort "Needed Image do not exist. Load Sample data before going further"
	endif
	string sampleNote=note(CCDImageToConvert)
	sampleNote = ReplaceString(" ", sampleNote, "")
	//string emptyNote=note(EmptyData)
	//emptyNote = ReplaceString(" ", emptyNote, "")
	//variable SampleBeamStopDiode=NumberByKey("Photodiode", sampleNote , ":" , ";")
	//variable EmptyBeamStopDiode=NumberByKey("Photodiode", emptyNote , ":" , ";")
	variable SampleBeamStopBS=NumberByKey("BS", sampleNote , ":" , ";")
	//variable EmptyBeamStopI0=NumberByKey("I0", emptyNote , ":" , ";")
	//variable I0Normalized = (SampleBeamStopDiode/SampleBeamStopI0)//(EmptyBeamStopDiode/EmptyBeamStopI0)
	print "Found Sample BS = "+num2str(SampleBeamStopBS)
	return SampleBeamStopBS
end
//*******************************************************************************************************************************************

Function NI1_12IDBGetSampleI0(fileName)
	string fileName
	wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	//wave/Z EmptyData = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(CCDImageToConvert))// || !WaveExists(EmptyData))
		abort "Needed Image do not exist. Load Sample data before going further"
	endif
	string sampleNote=note(CCDImageToConvert)
	sampleNote = ReplaceString(" ", sampleNote, "")
	//string emptyNote=note(EmptyData)
	//emptyNote = ReplaceString(" ", emptyNote, "")
	//variable SampleBeamStopDiode=NumberByKey("Photodiode", sampleNote , ":" , ";")
	//variable EmptyBeamStopDiode=NumberByKey("Photodiode", emptyNote , ":" , ";")
	variable SampleBeamStopI0=NumberByKey("I0", sampleNote , ":" , ";")
	//variable EmptyBeamStopI0=NumberByKey("I0", emptyNote , ":" , ";")
	//variable I0Normalized = (SampleBeamStopDiode/SampleBeamStopI0)//(EmptyBeamStopDiode/EmptyBeamStopI0)
	print "Found Sample I0 = "+num2str(SampleBeamStopI0)
	return SampleBeamStopI0
end
//*******************************************************************************************************************************************
Function NI1_12IDBNexGetSampleI0(fileName)
	string fileName
	wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	//wave/Z EmptyData = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(CCDImageToConvert))// || !WaveExists(EmptyData))
		abort "Needed Image do not exist. Load Sample data before going further"
	endif
	string sampleNote=note(CCDImageToConvert)
	sampleNote = ReplaceString(" ", sampleNote, "")
	//string emptyNote=note(EmptyData)
	//emptyNote = ReplaceString(" ", emptyNote, "")
	//variable SampleBeamStopDiode=NumberByKey("Photodiode", sampleNote , ":" , ";")
	//variable EmptyBeamStopDiode=NumberByKey("Photodiode", emptyNote , ":" , ";")
	variable SampleBeamStopI0=NumberByKey("Metadata:It_phd", sampleNote , "=" , ";")
	//variable EmptyBeamStopI0=NumberByKey("I0", emptyNote , ":" , ";")
	//variable I0Normalized = (SampleBeamStopDiode/SampleBeamStopI0)//(EmptyBeamStopDiode/EmptyBeamStopI0)
	print "Found Sample I0 = "+num2str(SampleBeamStopI0)
	return SampleBeamStopI0
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_12IDBGetEmptyI0(fileName)
	string fileName
	//wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	wave/Z EmptyData = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(EmptyData))// || !WaveExists(EmptyData))
		abort "Needed Image do not exist. Load Empty data before going further"
	endif
	//string sampleNote=note(CCDImageToConvert)
	//sampleNote = ReplaceString(" ", sampleNote, "")
	string emptyNote=note(EmptyData)
	emptyNote = ReplaceString(" ", emptyNote, "")
	//variable SampleBeamStopDiode=NumberByKey("Photodiode", sampleNote , ":" , ";")
	//variable EmptyBeamStopDiode=NumberByKey("Photodiode", emptyNote , ":" , ";")
	//variable SampleBeamStopI0=NumberByKey("I0", sampleNote , ":" , ";")
	variable EmptyBeamStopI0=NumberByKey("I0", emptyNote , ":" , ";")
	//variable I0Normalized = (EmptyBeamStopDiode/EmptyBeamStopI0)//(EmptyBeamStopDiode/EmptyBeamStopI0)
	print "Found Empty I0 = "+num2str(EmptyBeamStopI0)
	return EmptyBeamStopI0
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_12IDBNexGetEmptyI0(fileName)
	string fileName
	//wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	wave/Z EmptyData = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(EmptyData))// || !WaveExists(EmptyData))
		abort "Needed Image do not exist. Load Empty data before going further"
	endif
	//string sampleNote=note(CCDImageToConvert)
	//sampleNote = ReplaceString(" ", sampleNote, "")
	string emptyNote=note(EmptyData)
	emptyNote = ReplaceString(" ", emptyNote, "")
	//variable SampleBeamStopDiode=NumberByKey("Photodiode", sampleNote , ":" , ";")
	//variable EmptyBeamStopDiode=NumberByKey("Photodiode", emptyNote , ":" , ";")
	//variable SampleBeamStopI0=NumberByKey("I0", sampleNote , ":" , ";")
	variable EmptyBeamStopI0=NumberByKey("Metadata:It_phd", emptyNote , "=" , ";")
	//variable I0Normalized = (EmptyBeamStopDiode/EmptyBeamStopI0)//(EmptyBeamStopDiode/EmptyBeamStopI0)
	print "Found Empty I0 = "+num2str(EmptyBeamStopI0)
	return EmptyBeamStopI0
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function/S NI1_12IDBLoadMetadata(FileNameToLoad, LoadedWvHere)		
	string FileNameToLoad
	wave LoadedWvHere
	
	//get the path to Slogs now, it is one level up and inside the log folder
	PathInfo Convert2Dto1DDataPath
	string DataFilePath=S_path
	string UsingWhat=StringFromList(ItemsInList(DataFilePath,":")-1, DataFilePath,":")
	string LogPathStr= RemoveFromList(UsingWhat, DataFilePath,":")+"log"
	NewPath/O/Q/Z LogFilesPath, LogPathStr
	string LogFileName="L"+FileNameToLoad[1,inf]
	LogFileName = ReplaceString("tif", LogFileName, "meta")
	if(StringMatch(FileNameToLoad[0], "S" ))
		usingWhat = "SAXS"
	elseif(StringMatch(FileNameToLoad[0], "W" ))
		usingWhat = "WAXS" 
	elseif(StringMatch(FileNameToLoad[0], "P" ))
		usingWhat = "PE" 
		abort "Do not know what to do with PE detectors yet. Fix me"
	else
		abort "Unknown type of data used, fix me first"
	endif
	variable refNum, err
	string OneLineStr, MetadataString="", newWaveNOte=""
	open/R/T="????"/P=LogFilesPath/Z refNum as LogFileName
	if(V_flag!=0)
		close refNum
		Abort "Metadata import failed"
	else		//open succesful
		Do
			FreadLine refNum,OneLineStr
			if(strlen(OneLineStr)<=0)
				//break
				err=1
			endif
			MetadataString+=OneLineStr+";"
		while(err==0)
		Close refNum
	endif 
	MetadataString = ReplaceString("%", MetadataString, "")
	MetadataString = ReplaceString("\n", MetadataString, "")
	MetadataString = ReplaceString("\r", MetadataString, "")
	//MetadataString = ReplaceString(" ", MetadataString, "")
	newWaveNOte = NI1_12IDBProcessMetadata(usingWhat, MetadataString, LoadedWvHere)
	return newWaveNote
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function/S NI1_12IDBProcessMetadata(which, MetadataString, LoadedWvHere)
	string which, MetadataString
	wave LoadedWvHere

	//parse this string and do what is needed...
	string NewWaveNote=""
	string currentItemString
	variable i, maxItems, includeMe
	maxItems=ItemsInList(MetadataString,";")
	includeMe = 1
	i = 0
	//check that needed metadata are actually there or bail out on users...
	if(StringMatch(which, "SAXS"))	//require SAXS data
		if(!stringmatch(MetadataString, "*SAXS Detector*"))
			DoAlert 0, "Metadata do not contain SAXS part"
			return ""
		endif
	endif 
	if(StringMatch(which, "WAXS"))	//require SAXS data
		if(!stringmatch(MetadataString, "*WAXS Detector*"))
			DoAlert 0,  "Metadata do not contain WAXS part"
			return ""
		endif
	endif 
	
	//read first part... 
	do
			currentItemString=StringFromList(i, MetadataString, ";")
			i+=1
			NewWaveNote+=currentItemString+";"
	while(!StringMatch(currentItemString, "SAXS Detector"))
	// now read SAXS part, if needed... 
	do
		currentItemString=StringFromList(i, MetadataString, ";")
		i+=1
		if(StringMatch(which, "SAXS"))
			//process the line as needed
			NI1_12IDBProcessLine(currentItemString, LoadedWvHere)
			NewWaveNote+=currentItemString+";"
		endif
	while(!StringMatch(currentItemString, "WAXS Detector"))
	do
		currentItemString=StringFromList(i, MetadataString, ";")
		i+=1
		if(StringMatch(which, "WAXS"))
			//process the line as needed
			NI1_12IDBProcessLine(currentItemString, LoadedWvHere)
			NewWaveNote+=currentItemString+";"
		endif
	while(!StringMatch(currentItemString, "*Setup information*"))
	do
		currentItemString=StringFromList(i, MetadataString, ";")
		i+=1
		//process the line as needed
		NI1_12IDBProcessLine(currentItemString, LoadedWvHere)
		NewWaveNote+=currentItemString+";"
	while(i<maxItems)	
	print NewWaveNote
	return NewWaveNote
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_12IDBProcessLine(LineToProcess, LoadedWvHere)
	string LineToProcess
	wave LoadedWvHere
	
	LineToProcess=ReplaceString(" ", LineToProcess, "")+";"
	NVAR APS12IDBReloadPars
	if(APS12IDBReloadPars)
		if(StringMatch(LineToProcess, "*PixelSize(mm)*" ))
			NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX
			NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY
			PixelSizeX = NumberByKey("PixelSize(mm)", LineToProcess, ":", ";")
			PixelSizeY = NumberByKey("PixelSize(mm)", LineToProcess, ":", ";")
		endif
		if(StringMatch(LineToProcess, "*Sample-to-detectorDistance(mm)*" ))
			NVAR SampleToCCDdistance = root:Packages:Convert2Dto1D:SampleToCCDdistance
			SampleToCCDdistance = NumberByKey("Sample-to-detectorDistance(mm)", LineToProcess, ":", ";")
		endif
		if(StringMatch(LineToProcess, "*BeamCenterX*" ))
			NVAR BeamCenterX = root:Packages:Convert2Dto1D:BeamCenterX
			BeamCenterX = NumberByKey("BeamCenterX", LineToProcess, ":", ";")
		endif
		if(StringMatch(LineToProcess, "*BeamCenterY*" ))
			NVAR BeamCenterY = root:Packages:Convert2Dto1D:BeamCenterY
			//Again, THIS IS INVERTED...
			variable DimYSize=DimSize(LoadedWvHere, 1 )
			BeamCenterY = DimYSize - NumberByKey("BeamCenterY", LineToProcess, ":", ";")		
		endif
		if(StringMatch(LineToProcess, "*X-rayEnergy(keV)*" ))
			NVAR XrayEnergy = root:Packages:Convert2Dto1D:XrayEnergy
			NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength
			XrayEnergy = NumberByKey("X-rayEnergy(keV)", LineToProcess, ":", ";")
			Wavelength = 12.39842/XrayEnergy
		endif
		if(StringMatch(LineToProcess, "*TiltAnglePitch(degree)*" ))
			NVAR VerticalTilt = root:Packages:Convert2Dto1D:VerticalTilt
			//Again, THIS IS INVERTED...
			VerticalTilt = -1* NumberByKey("TiltAnglePitch(degree)", LineToProcess, ":", ";")		
		endif
	endif
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//Function NI1_12IDBGetUserInput()			//todo: some error handling... 
//		//should be able to find mask in current working folder	
//	string OldDFf=GetDataFolder(1)
//	NVAR UseMask = root:Packages:Convert2Dto1D:UseMask
//	variable ProcessingTypeVal=0		//Processing type is : 0 use beamline processing (just reduction) or 1 subtract empty/background and reduce. 
//	string ProcessingTypeStr="No"
//	setDataFOlder root:Packages:Convert2Dto1D:
//	//get the path to SAXS_mask2M.bmp or WAXS_mask2M.bpm, it is one level up...
//	PathInfo Convert2Dto1DDataPath
//	string DataFilePath=S_path
//	string UsingWhat=StringFromList(ItemsInList(DataFilePath,":")-1, DataFilePath,":")
//	string MaskPathStr= RemoveFromList(UsingWhat, DataFilePath,":")
//	//mask may or may not exist, we need to get user to pick one or tell us it does not exist...
//	NewPath/O/Q TempMaskUserPath, MaskPathStr
//	string ListOfBMPFiles=IndexedFile(TempMaskUserPath, -1, ".bmp")
//	string SelectedMaskFile
//	if(strlen(ListOfBMPFiles)>0)
//		Prompt SelectedMaskFile, "Select BMP Mask file", popup, ListOfBMPFiles+"---;"
//		Prompt ProcessingTypeStr, "Subtract Empty/background", popup, "No;Yes;"
//		DoPrompt "Select Mask/Method", ProcessingTypeStr, SelectedMaskFile
//		if(V_Flag || stringmatch(SelectedMaskFile,"---"))
//			print "User canceled mask file selection, continue without it"
//			UseMask = 0
//			if(stringMatch(ProcessingTypeStr,"Yes"))
//				ProcessingTypeVal = 1
//			endif
//			return ProcessingTypeVal
//		endif
//		if(stringMatch(ProcessingTypeStr,"Yes"))
//			ProcessingTypeVal = 1
//		endif
//		ImageLoad/T=bmp/Q/N=TMPBMPMask/Z/P=TempMaskUserPath SelectedMaskFile
//		if(V_Flag)
//			print ":Loaded succesfully mask file from "+MaskPathStr+SelectedMaskFile
//		else
//			DoALert/T="Could not load Mask file" 0, "Could not load selected file with mask, you need to create mask manually"
//			UseMask = 0
//			return ProcessingTypeVal
//		endif
//		Wave LoadedmaskImage = TMPBMPMask
//		ImageTransform rgb2gray LoadedmaskImage
//		Wave M_RGB2Gray
//		ImageTransform flipCols M_RGB2Gray			//this is correct flip needed...
//		DoWIndow CCDImageToConvertFig
//		if(V_Flag)
//			RemoveImage/W=CCDImageToConvertFig/Z  M_ROIMask
//		endif
//		KillWaves/Z M_ROIMask, TMPBMPMask
//		wavestats/Q M_RGB2Gray
//		M_RGB2Gray/=V_max				//normalize to be 1 or 0, seem to be 255
//		Rename M_RGB2Gray, M_ROIMask
//		UseMask = 1
//	else		//no mask file found
//		print "No BMP mask file found, continue without it"
//		Prompt ProcessingTypeStr, "Subtract Empty/background", popup, "No;Yes;"
//		DoPrompt "Select Method", SelectedMaskFile, ProcessingTypeStr
//		if(stringMatch(ProcessingTypeStr,"Yes"))
//			ProcessingTypeVal = 1
//		endif
//		UseMask = 0
//		return ProcessingTypeVal
//	endif
//
//
//
//
//	setDataFolder OldDFf	
//	return ProcessingTypeVal
//end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_12IDBHowTo()
	
	doWIndow APS12IDB_Instructions
	if(V_Flag)
		DoWIndow/F APS12IDB_Instructions
	else
	String nb = "APS12IDB_Instructions"
	NewNotebook/N=$nb/F=1/V=1/K=1/ENCG={1,1}/W=(114,125,820,855) as "APS12IDB_Instructions"
	Notebook $nb defaultTab=10, magnification=125
	Notebook $nb showRuler=1, rulerUnits=2, updating={1, 1}
	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Helvetica",11,0,(0,0,0)}
	Notebook $nb newRuler=Title, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",12,3,(0,0,0)}
	Notebook $nb ruler=Title, fSize=14, textRGB=(65535,0,0), text="Instructions for use of APS 12IDC special configuration\r"
	Notebook $nb ruler=Normal, fSize=-1, textRGB=(0,0,0), text="\r"
	Notebook $nb text="\r"
	Notebook $nb text="1. Find path to your data images. Pick folder - either \"SAXS\" or \"WAXS\" \r"
	Notebook $nb text="\t- with raw tiff or Nexus(HDF5) files, not other folders (e.g. not the Average folder). \r"
	Notebook $nb text="\r"
	Notebook $nb text="2. Code will find available data, calibrations, masks, and present dialog to choose to :\r"
	Notebook $nb text="\ta. ", fStyle=1, text="Subtract Empty/background?", fStyle=-1
	Notebook $nb text=" - this is basically data reduction method (see below)\r"
	Notebook $nb text="\tb. ", fStyle=1, text="(Tiff only) Load calibration from appropriate calibration file", fStyle=-1
	Notebook $nb text=". If you choose not to, you need to calibrate everything yourself. \r"
	Notebook $nb text="   c. ", fStyle=1, text="(Tiff only) Choose to reload calibration from metadata with each loaded image", fStyle=-1
	Notebook $nb text=". Rarely needed... This is useful when you may have data from different calibrations (e.g., distances, w"
	Notebook $nb text="avelengths,...) in the same folder. Do NOT choose this option if you need to overwrite anything in calib"
	Notebook $nb text="ration.  \r"
	Notebook $nb text="   d. ", fStyle=1, text="Load appropriate mask", fStyle=-1
	Notebook $nb text=", SAXS or WAXS, if found. If you choose not to, you need to design your own mask and switch masking on y"
	Notebook $nb text="ourself. \r"
	Notebook $nb text="\r"
	Notebook $nb text="3. Continue, all should finish without any error messages.  \r"
	Notebook $nb text="\r"
	Notebook $nb fStyle=1, text="With default choices you will", fStyle=-1
	Notebook $nb text=" : \rchoose \"bioSAXS\" data processing, \rload calibration from xxxx_calibration_parameters.txt file, \rnot rel"
	Notebook $nb text="oad calibration with each new loaded image, \rand import appropriate existing mask.\r"
	Notebook $nb text="\r"
	Notebook $nb text="\r"
	Notebook $nb fStyle=5, text="*** Data reduction methods ***\r"
	Notebook $nb fStyle=-1, text="1. ", fStyle=1, text="Subtract Empty/Background = NO     ", fStyle=-1
	Notebook $nb text=": reduces each image separately, normalized by transmitted counts (flux and transmission normalization) "
	Notebook $nb text="and normalization factor, masked. Solvent/background sutraction needs to be done later. This is typical "
	Notebook $nb text="for BioSAXS data when multiple images are collected per sample. Using Irena bioSAXS tools you can then a"
	Notebook $nb text="verage multiple data together, subtracted these averaged data etc. This is default beamline processing a"
	Notebook $nb text="nd typical for bioSAXS data.\r"
	Notebook $nb text="\r"
	Notebook $nb text="2. ", fStyle=1, text="Subtract Empty/Background = YES   :  ", fStyle=-1
	Notebook $nb text="typical Nika processing for materials SAXS - solvent/background image is subtracted in Nika directly fro"
	Notebook $nb text="m each image, with flux normalization for sample and background, transmission calculation etc. In this c"
	Notebook $nb text="ase only ONE background image can be used at time, which may not be suitable if you have multiple images"
	Notebook $nb text=" for background. \r"
	Notebook $nb text="\r"
	Notebook $nb text="Jan Ilavsky, 7/25/2022\r"
	Notebook $nb text="\r"
	Notebook $nb fStyle=2, text="Hint: watch history area for notes on what Nika has found and done. \r"

	endif
end

//*******************************************************************************************************************************************
//			end of 12ID-B camera support. 
