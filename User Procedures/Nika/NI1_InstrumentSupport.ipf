#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.00

//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//version 1.1 adds support for ALS RSoXS data - sfot X-ray energy beamlione at ALS. 
//version 1.0 original release, Instrument support for SSRLMatSAXS
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//RSoXS support


Function NI1_RSoXSCreateGUI()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DoWIndow NI1A_Convert2Dto1DPanel
	if(!V_Flag)
		NI1A_Convert2Dto1DMainPanel()
	endif
	NI1_RSoXSInitialize()
	DoWIndow NI1_RSoXSMainPanel
	if(V_Flag)
		DoWIndow/F NI1_RSoXSMainPanel
	else
		Execute("NI1_RSoXSMainPanel()")
	endif
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function NI1_RSoXSFindI0File()
	variable refNum, i
	string LineContent
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	Wave/Z CorrectionFactor=$("root:Packages:Nika_RSoXS:CorrectionFactor_pol"+num2str(PolarizationLocal))
	Wave/Z Beamline_Energy=$("root:Packages:Nika_RSoXS:Beamline_Energy_pol"+num2str(PolarizationLocal))
	if(!WaveExists(Beamline_Energy)||!WaveExists(CorrectionFactor))
		abort "Did not find Correction factor values, cannot continue"
	endif
	variable result = SampleI0*CorrectionFactor[BinarySearchInterp(Beamline_Energy, Energy )]
	print "Read I0 from image and Correction factor from file : CorrectionFactor_pol"+num2str(PolarizationLocal)+"  and got value = "+num2str(result)
	return result
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function NI1_RSoXSInitialize()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf=GetDataFolder(1)
	newDataFOlder/O root:Packages
	newDataFolder/O/S root:Packages:Nika_RSoXS
	
	string/g ListOfVariables
	string/g ListOfStrings

	ListOfVariables="UseRSoXSCodeModifications;"
	ListOfVariables+="ColumnNamesLineNo;OrderSorterValue;PolarizationValue;PhotoDiodeOffset;I0Offset;"
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

Window NI1_RSoXSMainPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(464,54,908,469) as "RSoXS Data reduction panel"
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
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

//				NVAR UseSampleTransmission = root:Packages:Convert2Dto1D:UseSampleTransmission
//				NVAR UseEmptyField = root:Packages:Convert2Dto1D:UseEmptyField
				NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate
//				NVAR DoGeometryCorrection = root:Packages:Convert2Dto1D:DoGeometryCorrection
//				NVAR UseMonitorForEf = root:Packages:Convert2Dto1D:UseMonitorForEf
//				NVAR UseSampleTransmFnct = root:Packages:Convert2Dto1D:UseSampleTransmFnct
				NVAR UseSampleMonitorFnct = root:Packages:Convert2Dto1D:UseSampleMonitorFnct
//				NVAR UseEmptyMonitorFnct = root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
				NVAR UseSampleCorrectFnct = root:Packages:Convert2Dto1D:UseSampleCorrectFnct
				NVAR UseCorrectionFactor = root:Packages:Convert2Dto1D:UseCorrectionFactor
				NVAR UseDarkField = root:Packages:Convert2Dto1D:UseDarkField
				NVAR UseSampleMeasTime = root:Packages:Convert2Dto1D:UseSampleMeasTime
				
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
				
				UseSampleCorrectFnct = 1
				UseCorrectionFactor = 1
				UseSampleMeasTime=0
				UseDarkField = 1
//				UseSampleThickness = 1			
//				UseSampleTransmission = 1
//				UseEmptyField = 1
				UseI0ToCalibrate = 1
//				DoGeometryCorrection = 1
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
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
