#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.13

//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.13 extended Modified guass fitting range, speed up by avoiding display updates of teh top fittings (major speed increase). 
//1.12 increased Modified Guass fitting range slightly. 
//1.11 adds Overwrite for UPD dark current range 5
//1.10 adds FlyScan support
//1.09 controls for few more items displayed on Tab0 with pek-to-peak transmission and MSAXS/pinSAXS correction
//1.08 added pin diode transmission
//1.07 added (beta version now) measurement of transmission by using diode on front of the A stage
//1.06 modified for weight calibration
//1.05 FIxed bump to Compiler when no data selected in Data selection popup. 
//1.04 2/2013, JIL: modified to enable calibration per weight
//1.03 2/2013 fixed Process next sample for changed control procedures. 
//1.02 4/2012 modified q shifts step to be 0.5e-6, 10x less than before. 
//1.01 2/2012 modified function Modified gauss to handle bad points appearing in this cycle in the data. Moved some button adn add option to fix PD range


//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IN3_InputPanelButtonProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct

	String ctrlName
	ctrlName = B_Struct.ctrlName
	string winNm=B_Struct.win

	if(B_Struct.eventcode!=2)
		return 1
	endif
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	if (cmpstr(ctrlName,"SelectNextSampleAndProcess")==0)
		SVAR DataFolderName=root:Packages:Indra3:DataFolderName
		SVAR LastSample=root:Packages:Indra3:LastSample
		String AllFolders=IR2P_GenStringOfFolders(winNm=winNm)
		string ShortOldSaName = StringFromList(ItemsInList(LastSample, ":")-1, LastSample , ":")
		variable CurrentFolder=WhichListItem(ShortOldSaName,AllFolders)
		string ShortNewSaName = StringFromList(CurrentFolder+1, AllFolders , ";")
		if(CurrentFolder>=0)
			DataFolderName = ReplaceString(ShortOldSaName, DataFolderName,ShortNewSaName)
			PopupMenu SelectDataFolder,mode=1,win=USAXSDataReduction, popvalue=ShortNewSaName
		endif
		DoWIndow/F USAXSDataReduction
	endif

	if (cmpstr(ctrlName,"ProcessData")==0 || cmpstr(ctrlName,"SelectNextSampleAndProcess")==0)
		SVAR DataFolderName=	root:Packages:Indra3:DataFolderName
		if(stringMatch(DataFolderName,"---"))
			setDataFolder oldDf
			abort
		endif
		IN3_LoadData()		//load data in the tool. 
		IN3_LoadBlank()
		IN3_SetPDParameters()
			//	hopefully not needed any more IN2A_CleanWavesForSPECtroubles()				//clean the waves with USAXS data for Spec timing troubles, if needed
		IN3_GetMeasParam()	
		IN3_RecalculateData(0)
		IN3_GraphData()		//create graphs
		IN3_ReturnCursorBack()
		IN3_FitDefaultTop()
		IN3_RecalculateData(4)
		IN3_FitDefaultTop()
		IN3_GetDiodeTransmission(0)
		IN3_RecalculateData(1)
		TabControl DataTabs , value= 0, win=USAXSDataReduction
		NI3_TabPanelControl("",0)
		DoWIndow/F USAXSDataReduction
	endif
	if (cmpstr(ctrlName,"RemovePointsRange")==0)
		RemovePointsWithMarquee()
	endif
	if (cmpstr(ctrlName,"Recalculate")==0)
		IN3_RecalculateData(1)	
		DoWIndow/F USAXSDataReduction
	endif

	if (cmpstr(ctrlName,"SaveResults")==0)
		IN3_SaveData()	
		NVAR UserSavedData=root:Packages:Indra3:UserSavedData
		UserSavedData=1
		IN3_FixSaveData()
		DoWIndow/F USAXSDataReduction
	endif
	if (cmpstr(ctrlName,"RecoverDefault")==0)
		NVAR SampleThickness
		NVAR SampleThicknessBckp
		SampleThickness = SampleThicknessBckp
		IN3_RecalculateData(2)
		DoWIndow/F USAXSDataReduction
	endif
	if (cmpstr(ctrlName,"RecoverDefaultBlnkVals")==0)
		NVAR BlankWidthBckp
		NVAR BlankWidth
		BlankWidth = BlankWidthBckp
		NVAR BlankFWHMBckp
		NVAR BlankFWHM
		BlankFWHM = BlankFWHMBckp
		NVAR BlankMaximumBckp
		NVAR BlankMaximum
		BlankMaximum = BlankMaximumBckp
		IN3_RecalculateData(2)
		DoWIndow/F USAXSDataReduction
	endif


	if (cmpstr(ctrlName,"RemovePoint")==0)
		if (strlen(CsrWave(A))==0)
			Abort "cursor A is not in the graph...nothing to do..."
		endif
		variable pointNumberToBeRemoved=xcsr(A)
		if (strlen(CsrWave(B))!=0)
			DoAlert 0, "Remove cursor B [square] before proceeding"
		else
			//this part should be done always
			Wave FixMe=CsrWaveRef(A)
			FixMe[pointNumberToBeRemoved]=NaN
			//if we need to fix more waves, it can be done here
		endif
		cursor/P A, $CsrWave(A), pointNumberToBeRemoved+1		//set the cursor to the right so we do not scare user
		DoWIndow/F USAXSDataReduction
	endif
	
	setDataFolder OldDf
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN3_GetDiodeTransmission(SkipMessage)
	variable SkipMessage

	NVAR isBlank=	root:Packages:Indra3:isBlank
	if(isBlank)
		return 0
	endif


	SVAR MeasurementParameters = root:Packages:Indra3:MeasurementParameters
	SVAR BlankName = root:Packages:Indra3:BlankName
	SVAR/Z BLMeasurementParameters = $(BlankName+"MeasurementParameters")
	NVAR SampleTransmissionPeakToPeak = root:Packages:Indra3:SampleTransmissionPeakToPeak
	NVAR MSAXSCorrection = root:Packages:Indra3:MSAXSCorrection
	NVAR SampleTransmission = root:Packages:Indra3:SampleTransmission
	NVAR UsePinTransmission=	root:Packages:Indra3:UsePinTransmission
	
	
	variable USAXSPinT_Measure 	=NumberByKey("USAXSPinT_Measure", MeasurementParameters, "=", ";")
	variable USAXSPinT_AyPosition	=NumberByKey("USAXSPinT_AyPosition", MeasurementParameters, "=", ";")
	variable USAXSPinT_Time		=NumberByKey("USAXSPinT_Time", MeasurementParameters, "=", ";")
	variable USAXSPinT_pinCounts	=NumberByKey("USAXSPinT_pinCounts", MeasurementParameters, "=", ";")
	variable USAXSPinT_pinGain		=NumberByKey("USAXSPinT_pinGain", MeasurementParameters, "=", ";")
	variable USAXSPinT_I0Counts	=NumberByKey("USAXSPinT_I0Counts", MeasurementParameters, "=", ";")
	variable USAXSPinT_I0Gain		=NumberByKey("USAXSPinT_I0Gain", MeasurementParameters, "=", ";")

	variable BLUSAXSPinT_Measure 		=NumberByKey("USAXSPinT_Measure", BLMeasurementParameters, "=", ";")
	variable BLUSAXSPinT_AyPosition	=NumberByKey("USAXSPinT_AyPosition", BLMeasurementParameters, "=", ";")
	variable BLUSAXSPinT_Time			=NumberByKey("USAXSPinT_Time", BLMeasurementParameters, "=", ";")
	variable BLUSAXSPinT_pinCounts		=NumberByKey("USAXSPinT_pinCounts", BLMeasurementParameters, "=", ";")
	variable BLUSAXSPinT_pinGain		=NumberByKey("USAXSPinT_pinGain", BLMeasurementParameters, "=", ";")
	variable BLUSAXSPinT_I0Counts		=NumberByKey("USAXSPinT_I0Counts", BLMeasurementParameters, "=", ";")
	variable BLUSAXSPinT_I0Gain		=NumberByKey("USAXSPinT_I0Gain", BLMeasurementParameters, "=", ";")

	NVAR/Z USAXSPinTvalue = root:Packages:Indra3:USAXSPinTvalue
	if(!NVAR_Exists(USAXSPinTvalue))
		variable/g root:Packages:Indra3:USAXSPinTvalue
	endif
	USAXSPinTvalue=0
	if(USAXSPinT_Measure && BLUSAXSPinT_Measure)
		USAXSPinTvalue = ((USAXSPinT_pinCounts/USAXSPinT_pinGain)/(USAXSPinT_I0Counts/USAXSPinT_I0Gain))/((BLUSAXSPinT_pinCounts/BLUSAXSPinT_pinGain)/(BLUSAXSPinT_I0Counts/BLUSAXSPinT_I0Gain))
		if(!SkipMessage)
			print "Found pin Diode measured transmission for these measurements = "+num2str(USAXSPinTvalue)
		endif
		if(UsePinTransmission && USAXSPinTvalue>0)
			MSAXSCorrection = USAXSPinTvalue / SampleTransmissionPeakToPeak
		endif
	else
		UsePinTransmission=0
	endif
	
	
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

static Function IN3_ReturnCursorBack()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	Wave R_Int
	Wave R_Qvec
	
	NVAR/Z OldStartQValueForEvaluation
	if(NVAR_Exists(OldStartQValueForEvaluation))
		Cursor /P /W=RcurvePlotGraph  A  R_Int  round(BinarySearchInterp(R_Qvec, OldStartQValueForEvaluation ))
		Cursor /P /W=RcurvePlotGraph  B  R_Int  (numpnts(R_Qvec)-1)
	endif

	setDataFolder OldDf

end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
static Function IN3_FixSaveData()

		//fix display in the panel to reflect saved data... 
		NVAR UserSavedData=root:Packages:Indra3:UserSavedData
		if(!UserSavedData)
			Button SaveResults fColor=(65280,0,0), win=USAXSDataReduction
			TitleBox SavedData pos={200,135}, title="  Data   NOT   saved  ", fColor=(0,0,0), frame=1,labelBack=(65280,0,0), win=USAXSDataReduction
		else
			Button SaveResults , win=USAXSDataReduction, fColor=(47872,47872,47872)
			TitleBox SavedData pos={200,135}, title="  Data   are   saved  ", fColor=(0,0,0),labelBack=(47872,47872,47872),  frame=2, win=USAXSDataReduction
		endif
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

static Function IN3_GetMeasParam()		//sets various spray parameters


	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	SVAR SpecCommand
	NVAR PhotoDiodeSize
	NVAR Wavelength
	NVAR SlitLength
	NVAR NumberOfSteps
	NVAR SDDistance
	SVAR MeasurementParameters
	
	string specCommandSeparated= ReduceSpaceRunsInString(SpecCommand,1)
	if (!cmpstr(SpecCommandSeparated[0,0]," "))
		SpecCommandSeparated = SpecCommandSeparated[1,inf]						// remove any leading space
	endif
	SpecCommandSeparated = ChangePartsOfString(SpecCommandSeparated," ",";")		// one space is name separator

	//	Following macro calls are know  to me
	// 	13 items: uascan motor start center finish minstep dy0 SDD_mm ay0 SAD_mm exponent intervals time.... new slit smeared macro with AY movement
	//	14 items: sbuascan motor start center finish minstep dy0 asrp SDD_mm ay0 SAD_mm exponent intervals time.... old slit smeared macro before AY movement
	
	if (ItemsInList(SpecCommandSeparated)==13)
		SDDistance=str2num(StringFromList(7,SpecCommandSeparated))
	endif
	if (ItemsInList(SpecCommandSeparated)==14)
		SDDistance=str2num(StringFromList(8,SpecCommandSeparated))
	endif
	Variable ScanSteps=str2num(StringFromList(ItemsInList(SpecCommandSeparated)-2,SpecCommandSeparated))
//fix for mono communication failure
	if(numtype(NumberByKey("DCM_energy",MeasurementParameters,"="))!=0)
		MeasurementParameters=ReplaceStringByKey("DCM_energy",MeasurementParameters,num2str(12),"=")
		print "Warning>>>>  Nan found as energy for monochromator. Set to default 12keV. Change in IN3_GetMeasParam() in IN3_Calcualtions.ipf is needed"
	endif


	wavelength=12.398424437/NumberByKey("DCM_energy",MeasurementParameters,"=")
	SlitLength=0.5*((4*pi)/wavelength)*sin(PhotoDiodeSize/(2*SDDistance))
	NumberOfSteps=ScanSteps

	MeasurementParameters=ReplaceStringByKey("Wavelength",MeasurementParameters,num2str(wavelength),"=")
	MeasurementParameters=ReplaceStringByKey("SlitLength",MeasurementParameters,num2str(SlitLength),"=")
	MeasurementParameters=ReplaceStringByKey("NumberOfSteps",MeasurementParameters,num2str(ScanSteps),"=")
	MeasurementParameters=ReplaceStringByKey("SDDistance",MeasurementParameters,num2str(SDDistance),"=")
	
	IN2G_AppendNoteToAllWaves("Wavelength",num2str(wavelength))
	IN2G_AppendNoteToAllWaves("SlitLength",num2str(SlitLength))
	IN2G_AppendNoteToAllWaves("NumberOfSteps",num2str(ScanSteps))
	IN2G_AppendNoteToAllWaves("SDDistance",num2str(SDDistance))

	setDataFolder OldDf


end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

static Function IN3_SetPDParameters()	 			//setup PD parameters 
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	
	SVAR UPD=UPDParameters						//define the global holding places
	NVAR UPD_DK1=root:Packages:Indra3:UPD_DK1
	NVAR UPD_DK2=root:Packages:Indra3:UPD_DK2
	NVAR UPD_DK3=root:Packages:Indra3:UPD_DK3
	NVAR UPD_DK4=root:Packages:Indra3:UPD_DK4
	NVAR UPD_DK5=root:Packages:Indra3:UPD_DK5
	NVAR UPD_G1=root:Packages:Indra3:UPD_G1
	NVAR UPD_G2=root:Packages:Indra3:UPD_G2
	NVAR UPD_G3=root:Packages:Indra3:UPD_G3
	NVAR UPD_G4=root:Packages:Indra3:UPD_G4
	NVAR UPD_G5=root:Packages:Indra3:UPD_G5
	NVAR UPD_Vfc=root:Packages:Indra3:UPD_Vfc
	NVAR UPD_DK1Err=root:packages:Indra3:UPD_DK1Err
	NVAR UPD_DK2Err=root:packages:Indra3:UPD_DK2Err
	NVAR UPD_DK3Err=root:packages:Indra3:UPD_DK3Err
	NVAR UPD_DK4Err=root:packages:Indra3:UPD_DK4Err
	NVAR UPD_DK5Err=root:packages:Indra3:UPD_DK5Err

	UPD_Vfc =  NumberByKey("Vfc", UPD,"=")						//put the numbers in there
	UPD_DK1=NumberByKey("Bkg1", UPD,"=")
	UPD_G1=NumberByKey("Gain1", UPD,"=")
	UPD_DK2=NumberByKey("Bkg2", UPD,"=")
	UPD_G2=NumberByKey("Gain2", UPD,"=")
	UPD_DK3=NumberByKey("Bkg3", UPD,"=")
	UPD_G3=NumberByKey("Gain3", UPD,"=")
	UPD_DK4=NumberByKey("Bkg4", UPD,"=")
	UPD_G4=NumberByKey("Gain4", UPD,"=")
	UPD_DK5=NumberByKey("Bkg5", UPD,"=")
	UPD_G5=NumberByKey("Gain5", UPD,"=")
	UPD_DK1Err=NumberByKey("Bkg1Err", UPD,"=")
	UPD_DK2Err=NumberByKey("Bkg2Err", UPD,"=")
	UPD_DK3Err=NumberByKey("Bkg3Err", UPD,"=")
	UPD_DK4Err=NumberByKey("Bkg4Err", UPD,"=")
	UPD_DK5Err=NumberByKey("Bkg5Err", UPD,"=")
	if (UPD_DK1Err<=0)
		UPD_DK1Err=1
	endif
	if (UPD_DK2Err<=0)
		UPD_DK2Err=1
	endif
	if (UPD_DK3Err<=0)
		UPD_DK3Err=1
	endif
	if (UPD_DK4Err<=0)
		UPD_DK4Err=1
	endif
	if (UPD_DK5Err<=0)
		UPD_DK5Err=1
	endif

	setDataFolder OldDf

end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
static Function IN3_LoadData()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	
	//First Kill all ecistsing waves
	DoWindow RcurvePlotGraph
	if(V_Flag)
		DoWindow/K RcurvePlotGraph
	endif
	String ListOfWaves  = DataFolderDir (2)[6,inf]
	variable i
	For(i=0;i<ItemsInList(ListOfWaves,",");i+=1)
		Wave/Z tempWv=$(StringFromList(i, ListOfWaves,","))
		KillWaves/Z tempWv
	endfor
	
		SVAR LastSample=root:Packages:Indra3:LastSample	
		SVAR DFloc=root:Packages:Indra3:DataFolderName
		if (cmpstr(DFloc,"---")==0 ||strlen(DFloc)<1)
			abort
		endif
		LastSample = DFloc
		Wave/Z OrigAR_encoder=$(DFloc+"AR_encoder")
		if(!WaveExists(OrigAR_encoder))
			return 0
		endif
		Duplicate/O OrigAR_encoder, AR_encoder
		Wave OrigPD_range=$(DFloc+"PD_range")
		Duplicate/O OrigPD_range, PD_range
		Wave OrigUSAXS_PD=$(DFloc+"USAXS_PD")
		Duplicate/O OrigUSAXS_PD, USAXS_PD
		Wave OrigMeasTime=$(DFloc+"MeasTime")
		Duplicate/O OrigMeasTime, MeasTime
		Wave OrigMonitor=$(DFloc+"Monitor")
		Duplicate/O OrigMonitor, Monitor
		Wave/Z OringI0_gain=$(DFloc+"I0_gain")
		if(WaveExists(OringI0_gain))
			Duplicate/O OringI0_gain, I0_gain
		endif

		SVAR OrigSpecCommand =$(DFloc+"SpecCommand") 
		SVAR/Z OrigSpecMotors =$(DFloc+"SpecMotors") 
		SVAR OrigSpecSourceFileName =$(DFloc+"SpecSourceFileName") 
		SVAR OrigSpecComment =$(DFloc+"SpecComment") 
		SVAR OrigMeasurementParameters =$(DFloc+"MeasurementParameters") 
		SVAR OrigUPDParameters =$(DFloc+"UPDParameters") 
		SVAR OrigPathToRawData =$(DFloc+"PathToRawData") 
		string/g SpecCommand = OrigSpecCommand
		string/g SpecSourceFileName = OrigSpecSourceFileName
		string/g SpecComment = OrigSpecComment
		string/g MeasurementParameters = OrigMeasurementParameters
		string/g UPDParameters = OrigUPDParameters
		string/g PathToRawData = OrigPathToRawData
		SVAR userFriendlySamplename = root:Packages:Indra3:userFriendlySamplename
		userFriendlySamplename = OrigSpecComment
		//fix BK5 is user specified its change...
		NVAR OverwriteUPD_DK5 = root:Packages:Indra3:OverwriteUPD_DK5
		if(OverwriteUPD_DK5>0)
			UPDParameters=ReplaceNumberByKey("Bkg5",UPDParameters, OverwriteUPD_DK5,"=")
		endif

		
		SVAR Parameters=root:Packages:Indra3:ListOfASBParameters
		Parameters=ReplaceStringByKey("Sample",Parameters,DFloc,"=")		//write results into ASBparameters

		string IsItSBUSAXS=StringByKey("SPECCOMMAND", note(OrigAR_encoder), "=")[0,7]			//find out if this is SBUSAXS
		string Calibrate
		if (stringmatch(IsItSBUSAXS,"sbuascan")||stringmatch(IsItSBUSAXS,"sbflysca"))				//SBUSAXS, do not let user to select USAXS calibration
			Calibrate="SBUSAXS;"
		else																			
			Calibrate="USAXS;"				//and if it is USAXS data, do not let user select SBUSAXS calibration
		endif
		Parameters=ReplaceStringByKey("Calibrate",Parameters,Calibrate,"=")
		NVAR SampleThickness
		SampleThickness=NumberByKey("thickness", OrigMeasurementParameters,"=")	
		if(SVAR_Exists(OrigSpecMotors))
			string/g SpecMotors = OrigSpecMotors
			NVAR BeamExposureArea
			BeamExposureArea=NumberByKey("uslitverap", SpecMotors,":")* NumberByKey("uslithorap", SpecMotors,":")
		endif
		NVAR SampleThicknessBckp
		SampleThicknessBckp = SampleThickness
		//rezero some old stuff here...
		NVAR SampleQOffset= root:Packages:Indra3:SampleQOffset
		SampleQOffset=0
		NVAR DisplayPeakCenter=root:Packages:Indra3:DisplayPeakCenter
		DisplayPeakCenter=1
		NVAR DisplayAlignSaAndBlank=root:Packages:Indra3:DisplayAlignSaAndBlank
		DisplayAlignSaAndBlank=0
		NVAR Qmin = root:Packages:Indra3:MSAXSStartPoint
		NVAR Qmax=root:Packages:Indra3:MSAXSEndPoint
//		Qmin=0
//		Qmax=0
		NVAR UserSavedData
		UserSavedData=0
		IN3_FixSaveData()
	setDataFolder OldDf
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
static Function IN3_LoadBlank()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	
	NVAR IsBlank  = root:Packages:Indra3:IsBlank

	if(!IsBlank)
		SVAR BlankName = root:Packages:Indra3:BlankName
		if(strlen(BlankName)<4)
			abort "Error, select first the Blank name - if none available, create one first"
		endif
		Wave BL_R_IntL = $(BlankName+"Blank_R_Int")
		Wave BL_R_errorL = $(BlankName+"Blank_R_error")
		Wave BL_R_QvecL = $(BlankName+"Blank_R_Qvec")
		Duplicate/O BL_R_IntL, BL_R_Int
		Duplicate/O BL_R_errorL, BL_R_error
		Duplicate/O BL_R_QvecL, BL_R_Qvec
		SVAR Parameters=ListOfASBParameters
		Parameters=ReplaceStringByKey("Blank",Parameters,BlankName,"=")
		NVAR BlankFWHM
		NVAR BlankMaximum
		NVAR BlankWidth
		NVAR BlankWidthBckp
		NVAR BlankFWHMBckp
		NVAR BlankMaximumBckp
		NVAR OrigBlankFWHM = $(BlankName+"PeakWidth")
		NVAR OrigBlankMaximum = $(BlankName+"MaximumIntensity")
		BlankFWHM= OrigBlankFWHM
		BlankMaximum=OrigBlankMaximum
		BlankWidth=OrigBlankFWHM*3600  	//in arc seconds
		BlankWidthBckp = BlankWidth
		BlankFWHMBckp = BlankFWHM
		BlankMaximumBckp = BlankMaximum
	endif

	setDataFolder OldDf	
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************



static Function IN3_GraphData()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	DoWindow RcurvePlotGraph
	if(V_Flag)
		DoWindow/K RcurvePlotGraph
	endif
	IN3_RcurvePlot() 
	IN3_DisplayRightSubwindow()
	IN3_FixDispControlsInRcurvePlot()

	

	setDataFolder OldDf

end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IN3_DisplayRightSubwindow()

	NVAR DisplayPeakCenter =root:Packages:Indra3:DisplayPeakCenter
	NVAR DisplayAlignSaAndBlank=root:Packages:Indra3:DisplayAlignSaAndBlank

	String ExistingSubWindows=ChildWindowList("RcurvePlotGraph") 
	if(stringmatch(ExistingSubWindows,"*PeakCenter*"))
		KillWindow RcurvePlotGraph#PeakCenter
	endif
	if(stringmatch(ExistingSubWindows,"*AlignSampleAndBlank*"))
		KillWindow RcurvePlotGraph#AlignSampleAndBlank
	endif
	
	if(DisplayPeakCenter)
		IN3_PeakCenter()
	elseif(DisplayAlignSaAndBlank)
		IN3_AlignSampleAndBlank() 
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


//checbox control procedure
Function IN3_MainPanelCheckBox(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	NVAR CalculateWeight=root:Packages:Indra3:CalculateWeight
	NVAR CalculateThickness=root:Packages:Indra3:CalculateThickness
	NVAR CalibrateToWeight=root:Packages:Indra3:CalibrateToWeight
	NVAR CalibrateToVolume=root:Packages:Indra3:CalibrateToVolume
	NVAR CalibrateArbitrary=root:Packages:Indra3:CalibrateArbitrary
	NVAR UsePinTransmission=root:Packages:Indra3:UsePinTransmission
	NVAR UseMSAXSCorrection=root:Packages:Indra3:UseMSAXSCorrection

	
	if (cmpstr("IsBlank",ctrlName)==0)
		NVAR IsBlank=root:Packages:Indra3:IsBlank
		PopupMenu SelectBlankFolder, disable = IsBlank
		
	endif
	if (cmpstr("RecalculateAutomatically",ctrlName)==0)

	endif
	NVAR CalculateWeight=root:Packages:Indra3:CalculateWeight
	NVAR CalculateThickness=root:Packages:Indra3:CalculateThickness
	if (cmpstr("CalculateThickness",ctrlName)==0)
		NI3_TabPanelControl("",0)
		IN3_CalcSampleWeightOrThickness()
	endif
	if (cmpstr("CalculateWeight",ctrlName)==0)
		NI3_TabPanelControl("",0)
		IN3_CalcSampleWeightOrThickness()
	endif

	if (stringmatch("CalibrateToVolume",ctrlName))
		if(checked)
			CalibrateToWeight = 0
			CalibrateArbitrary = 0
		else
			if((CalibrateToWeight+CalibrateArbitrary)!=1)
				CalibrateArbitrary = 1
				CalibrateToWeight = 0
			endif
		endif
		NI3_TabPanelControl("",0)
	endif
	
	if(stringmatch("CalibrateToWeight",ctrlName) )
		if(checked)
			CalibrateToVolume = 0
			CalibrateArbitrary = 0
		else
			if((CalibrateToVolume+CalibrateArbitrary)!=1)
				CalibrateArbitrary = 0
				CalibrateToVolume = 1
			endif
		endif
		NI3_TabPanelControl("",0)
	endif

	if(stringmatch("CalibrateArbitrary",ctrlName) )
		if(checked)
			CalibrateToVolume = 0
			CalibrateToWeight = 0
		else
			if((CalibrateToVolume+CalibrateToWeight)!=1)
				CalibrateToWeight = 0
				CalibrateToVolume = 1
			endif
		endif
		NI3_TabPanelControl("",0)
	endif
	
	if (cmpstr("UseMSAXSCorrection",ctrlName)==0)
		IF(checked)
			 UsePinTransmission=0
		endif
		NI3_TabPanelControl("",4)
		//IN3_CalculateMSAXSCorrection()
		//IN3_CalculateTransmission(1)
		//IN3_CalculateSampleThickness()
		IN3_RecalculateData(3)
	endif
	if (cmpstr("UsePinTransmission",ctrlName)==0)
		IF(checked)
			 UseMSAXSCorrection=0
		endif
		NI3_TabPanelControl("",0)
		//IN3_CalculateMSAXSCorrection()
		//IN3_CalculateTransmission(1)
		//IN3_CalculateSampleThickness()
		IN3_RecalculateData(3)
	endif
	

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IN3_COlorizeButton()
	DOWINDOW RcurvePlotGraph
	IF(V_FLag)
		NVAR UseLorenz = root:Packages:Indra3:UseLorenz
		NVAR UseModifiedGauss = root:Packages:Indra3:UseModifiedGauss
		NVAR UseGauss = root:Packages:Indra3:UseGauss
		if(UseModifiedGauss)
			Button FitModGauss,win=RcurvePlotGraph ,fColor=(16386,65535,16385)
		else
			Button FitModGauss,win=RcurvePlotGraph ,fColor=(0,0,0)
		endif
		if(UseGauss)
			Button FitGauss,win=RcurvePlotGraph ,fColor=(16386,65535,16385)
		else
			Button FitGauss,win=RcurvePlotGraph ,fColor=(0,0,0)
		endif
		if(UseLorenz)
			Button FitLorenz,win=RcurvePlotGraph ,fColor=(16386,65535,16385)
		else
			Button FitLorenz,win=RcurvePlotGraph ,fColor=(0,0,0)
		endif
	endif
end


//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IN3_RcurvePlot() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Indra3:
	Wave R_Int
	Wave R_Qvec
	NVAR IsBlank = root:Packages:Indra3:IsBlank

//	Wave fit_PD_Intensity
//	Wave fitX_PD_Intensity
//	Wave R_error
//	Wave AR_encoder
	Wave/Z PeakFitWave
	NVAR PeakCenterFitStartPoint=root:Packages:Indra3:PeakCenterFitStartPoint
	NVAR PeakCenterFitEndPoint=root:Packages:Indra3:PeakCenterFitEndPoint
	
	//create main plot with R curve data
	Display/K=1 /W=(300,36.5,900,500) R_Int vs R_Qvec as "Rocking curve plot"
	DoWindow/C RcurvePlotGraph
	AutoPositionWindow/M=0/R=USAXSDataReduction  RcurvePlotGraph
//	AppendToGraph fit_PD_Intensity vs fitX_PD_Intensity
	//modify the displayed waves
	ModifyGraph mode(R_Int)=4
	ModifyGraph rgb(R_Int)=(65280,0,0)
	ModifyGraph msize(R_Int)=2
	ModifyGraph log=1
	ModifyGraph axOffset(bottom)=0.888889
	ModifyGraph lblPos(left)=60,lblPos(bottom)=51
	ModifyGraph lblLatPos(left)=-4,lblLatPos(bottom)=-2
	Label left "Intensity"
	Label bottom "Q [A\\S-1\\M]"
	SetAxis bottom 1e-05, R_Qvec[numpnts(R_Qvec)-1]
	ShowInfo
	ControlBar 50
	SetVariable SampleTransmission,pos={180,5},size={300,22},title="Sample transmission (peak max)"
	SetVariable SampleTransmission,font="Times New Roman",fSize=14,proc=IN3_ParametersChanged
	SetVariable SampleTransmission,limits={0,inf,0.005},variable= root:Packages:Indra3:SampleTransmissionPeakToPeak

	SetVariable SampleAngleOffset,pos={180,25},size={300,22},title="Q offset           "
	SetVariable SampleAngleOffset,font="Times New Roman",fSize=14,proc=IN3_ParametersChanged
	SetVariable SampleAngleOffset,limits={-inf,inf,0.5e-6},variable= root:Packages:Indra3:SampleQOffset

	Button Recalculate,pos={150,25},size={90,20},font="Times New Roman",fSize=10,proc=IN3_InputPanelButtonProc,title="Recalculate", help={"Recalculate the data"}
	Button Recalculate fColor=(40969,65535,16385)
	Button RemovePointsRange,pos={250,3},size={90,20},font="Times New Roman",fSize=10,proc=IN3_InputPanelButtonProc,title="Rem pnts w/Marquee", help={"Remove point by selecting Range with Marquee"}
	Button RemovePoint,pos={250,25},size={90,20},font="Times New Roman",fSize=10,proc=IN3_InputPanelButtonProc,title="Remove pnt w/csr A", help={"Remove point with cursor A"}
	Button FixGain,pos={150,6},size={90,15},font="Times New Roman",fSize=10, proc=IN3_GraphButtonProc,title="Fix Gain w/c A"

	CheckBox UseModifiedGauss title="Mod. Gauss",proc=IN3_RplotCheckProc
	CheckBox UseModifiedGauss variable=root:Packages:Indra3:UseModifiedGauss,mode=1,pos={345,1}
	CheckBox UseGauss title="Gauss",proc=IN3_RplotCheckProc
	CheckBox UseGauss variable=root:Packages:Indra3:UseGauss,mode=1,pos={345,17}
	CheckBox UseLorenz title="Lorenz",proc=IN3_RplotCheckProc
	CheckBox UseLorenz variable=root:Packages:Indra3:UseLorenz,mode=1,pos={345,34}

	Button FitModGauss,pos={425,3},size={80,18},font="Times New Roman",fSize=10, proc=IN3_GraphButtonProc,title="Fit Mod. Gauss"
	Button FitGauss,pos={515,3},size={80,18},font="Times New Roman",fSize=10, proc=IN3_GraphButtonProc,title="Fit Gauss"
	Button FitLorenz,pos={515,25},size={80,18},font="Times New Roman",fSize=10, proc=IN3_GraphButtonProc,title="Fit Lorenz"

	CheckBox DisplayPeakCenter title="Display Peak Fit",proc=IN3_RplotCheckProc
	CheckBox DisplayPeakCenter variable=root:Packages:Indra3:DisplayPeakCenter,mode=1,pos={5,5}
	CheckBox DisplayAlignSaAndBlank title="Display Align Sa and Blank",proc=IN3_RplotCheckProc, disable=IsBlank
	CheckBox DisplayAlignSaAndBlank variable=root:Packages:Indra3:DisplayAlignSaAndBlank,mode=1,pos={5,25}
//DisplayPeakCenter;DisplayAlignSaAndBlank
	SetDrawLayer UserFront
	IN3_COlorizeButton()
	NVAR IsBlank=root:Packages:Indra3:IsBlank
	if(!IsBlank)
		Wave/Z BL_R_Int=root:Packages:Indra3:BL_R_Int
		Wave/Z BL_R_error=root:Packages:Indra3:BL_R_error
		Wave/Z BL_R_Qvec= root:Packages:Indra3:BL_R_Qvec
		AppendToGraph BL_R_Int vs BL_R_Qvec
		ModifyGraph rgb(BL_R_Int)=(0,0,0)
		NVAR TrimDataStart=root:Packages:Indra3:TrimDataStart
		NVAR TrimDataEnd=root:Packages:Indra3:TrimDataEnd
		if(TrimDataStart>0)
			Cursor/P/W=RcurvePlotGraph A R_Int TrimDataStart	
		endif
		if(TrimDataEnd>0)
			Cursor/P/W=RcurvePlotGraph B R_Int TrimDataEnd	
		endif
	endif
	

	SetDataFolder fldrSav0
End
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IN3_FixDispControlsInRcurvePlot()


	NVAR DisplayPeakCenter = root:Packages:Indra3:DisplayPeakCenter
	NVAR DisplayAlignSaAndBlank = root:Packages:Indra3:DisplayAlignSaAndBlank
	
	SetVariable SampleTransmission,win=RcurvePlotGraph, disable =DisplayPeakCenter
	SetVariable SampleAngleOffset,win=RcurvePlotGraph, disable =DisplayPeakCenter

	Button FitGauss,win=RcurvePlotGraph, disable =DisplayAlignSaAndBlank
	Button FitModGauss,win=RcurvePlotGraph, disable =DisplayAlignSaAndBlank
	Button FitLorenz,win=RcurvePlotGraph, disable =DisplayAlignSaAndBlank

	Button Recalculate,win=RcurvePlotGraph, disable =DisplayAlignSaAndBlank
	Button RemovePoint,win=RcurvePlotGraph, disable =DisplayAlignSaAndBlank
	Button RemovePointsRange,win=RcurvePlotGraph, disable =DisplayAlignSaAndBlank
	Button FixGain,win=RcurvePlotGraph, disable =DisplayAlignSaAndBlank

	Checkbox UseModifiedGauss,win=RcurvePlotGraph, disable =DisplayAlignSaAndBlank
	Checkbox UseGauss,win=RcurvePlotGraph, disable =DisplayAlignSaAndBlank
	Checkbox UseLorenz,win=RcurvePlotGraph, disable =DisplayAlignSaAndBlank

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IN3_PeakCenter() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Indra3:
	Wave R_Int
	Wave R_Qvec
	Wave fit_PD_Intensity
//	Wave fitX_PD_Intensity
//	Wave R_error
	Wave AR_encoder
	Wave/Z PeakFitWave
	NVAR PeakCenterFitStartPoint=root:Packages:Indra3:PeakCenterFitStartPoint
	NVAR PeakCenterFitEndPoint=root:Packages:Indra3:PeakCenterFitEndPoint
	
	//create main plot with R curve data
	//create the other graph
	Display/K=1/W=(0.431,0.03,0.8,0.399)/FG=(,GT,FR,)/PG=(,,PR,)/HOST=RcurvePlotGraph  PD_Intensity vs AR_encoder
	AppendToGraph fit_PD_Intensity,PeakFitWave
	//modify displayed waves 
	ModifyGraph mode(PD_Intensity)=3
	ModifyGraph lSize(fit_PD_Intensity)=2
	ModifyGraph lStyle(PeakFitWave)=3
	ModifyGraph rgb(fit_PD_Intensity)=(0,0,52224),rgb(PeakFitWave)=(0,0,65280)
	ModifyGraph nticks(bottom)=2
	ModifyGraph lblMargin(left)=26,lblMargin(bottom)=1
	ModifyGraph lblLatPos=-1
	Label left "Intensity"
	Label bottom "AR angle [deg]"
	ErrorBars PD_Intensity Y,wave=(PD_Error,PD_Error)
	variable center = (PeakCenterFitEndPoint + PeakCenterFitStartPoint)/2
	variable start = max(center - 1.5 * (center - PeakCenterFitStartPoint),0)
	variable end1 = min(center + 1.8 * (PeakCenterFitEndPoint-center),numpnts(AR_encoder))
	SetAxis bottom AR_encoder[start],AR_encoder[end1]
	Cursor/P A PD_Intensity PeakCenterFitStartPoint
	Cursor/P B PD_Intensity PeakCenterFitEndPoint
	RenameWindow #,PeakCenter
	SetActiveSubwindow ##

	SetDataFolder fldrSav0
End
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IN3_AlignSampleAndBlank() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Indra3:
	
	NVAR IsBlank = root:Packages:Indra3:IsBlank
	if(IsBlank)
		return 0
	endif
	Wave R_Int
	Wave R_Qvec
	Wave R_Error
//	Wave fit_PD_Intensity
//	Wave fitX_PD_Intensity
	Wave R_error
	Wave AR_encoder
	Wave PeakFitWave
	NVAR PeakCenterFitStartPoint=root:Packages:Indra3:PeakCenterFitStartPoint
	NVAR PeakCenterFitEndPoint=root:Packages:Indra3:PeakCenterFitEndPoint
	Wave BL_R_Int
	Wave BL_R_Qvec
	
	//create main plot with R curve data
	//create the other graph
	Display/K=1/W=(0.431,0.03,0.8,0.399)/FG=(,GT,FR,)/PG=(,,PR,)/HOST=RcurvePlotGraph  R_Int vs R_Qvec
	AppendToGraph BL_R_Int vs BL_R_Qvec
	//modify displayed waves 
	ModifyGraph mode(R_Int)=3
	ModifyGraph rgb(BL_R_Int)=(0,0,0)
	ModifyGraph lstyle(BL_R_Int)=3,lsize(BL_R_Int)=2
	ModifyGraph nticks(bottom)=2
	ModifyGraph lblMargin(left)=26,lblMargin(bottom)=1
	ModifyGraph lblLatPos=-1
	Label left "Intensity"
	Label bottom "Q [A\S-1\M]"
	ErrorBars R_Int Y,wave=(R_Error,R_Error)
	variable center = (PeakCenterFitEndPoint + PeakCenterFitStartPoint)/2
	variable start = max(center - 1.5 * abs(center - PeakCenterFitStartPoint),0)
	variable end1 = min(center + 2.1 * abs(center - PeakCenterFitEndPoint),numpnts(AR_encoder))
	SetAxis bottom R_Qvec[start],R_Qvec[end1]
//	Cursor/P A R_Int PeakCenterFitStartPoint
//	Cursor/P B R_Int PeakCenterFitEndPoint
	RenameWindow #,AlignSampleAndBlank
	SetActiveSubwindow ##

	SetDataFolder fldrSav0
End
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
static Function IN3_AppendBlankToRPlot()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	
	NVAR IsBlank
	if(!IsBlank)
		Wave BL_R_Int
		Wave BL_R_Qvec
//		Wave BL_AR_encoder
		
		AppendToGraph/W=RcurvePlotGraph BL_R_Int vs BL_R_Qvec
		ModifyGraph/W=RcurvePlotGraph rgb(BL_R_Int)=(0,0,0)

//		AppendToGraph/W=RcurvePlotGraph#PeakCenter BL_R_Int vs BL_AR_encoder
//		ModifyGraph/W=RcurvePlotGraph#PeakCenter rgb(BL_R_Int)=(0,0,0)
		
	
	endif


	setDataFolder OldDf	
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************

Function IN3_GraphButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	NVAR PeakCenterFitStartPoint=root:Packages:Indra3:PeakCenterFitStartPoint
	NVAR PeakCenterFitEndPoint=root:Packages:Indra3:PeakCenterFitEndPoint
	Wave AR_encoder=root:Packages:Indra3:AR_encoder
	String AcsrWaveName = StringByKey("TNAME", CsrInfo(A , "RcurvePlotGraph#PeakCenter")  , ":" , ";")
	String BcsrWaveName = StringByKey("TNAME", CsrInfo(B , "RcurvePlotGraph#PeakCenter")  , ":" , ";")
	variable curX
	if (!stringMatch(AcsrWaveName,"PD_Intensity"))
		curX = xcsr(A , "RcurvePlotGraph#PeakCenter")
		Cursor /W=RcurvePlotGraph#PeakCenter A, PD_Intensity, (BinarySearch(AR_encoder, curX ))
	endif
	if (!stringMatch(BcsrWaveName,"PD_Intensity"))
		curX = xcsr(B, "RcurvePlotGraph#PeakCenter")
		Cursor /W=RcurvePlotGraph#PeakCenter B, PD_Intensity, (BinarySearch(AR_encoder, curX )+1)
	endif

	if(stringMatch(ctrlName,"FixGain"))
		if((strlen(csrInfo(A,"RcurvePlotGraph"))<1)||(!stringMatch(stringByKey("TNAME",csrinfo(A,"RcurvePlotGraph")),"R_Int")))
			DoAlert 0, "Cursor A not set or set on incorrect wave, should be on R_Int"
		else
			Wave PD_range = root:Packages:Indra3:PD_range
			variable CurPDRange, curPntNum
			curPntNum=pcsr(A,"RcurvePlotGraph")
			CurPDRange=PD_range[curPntNum]
			Prompt CurPDRange, "Change the PD range for selected point"
			DoPrompt "Fix the PD range here", CurPDRange
			if(V_Flag)
				abort
			endif
			CurPDRange = round(CurPDRange)
			if(CurPDRange<1||CurPDRange>5)
				DoAlert 0, "PD range input is wrong, 1-5 and intergers possible only)"
			else
				PD_range[curPntNum]=CurPDRange
				IN3_RecalculateData(1)	
				DoWIndow/F USAXSDataReduction
 			endif			
		endif
		
		
	endif
	if(stringMatch(ctrlName,"FitGauss"))
		//get position of cursors from the right window and run fitting rouitne with gaussien
		PeakCenterFitStartPoint=min(pcsr(A, "RcurvePlotGraph#PeakCenter"),pcsr(B, "RcurvePlotGraph#PeakCenter"))
		PeakCenterFitEndPoint=max(pcsr(A, "RcurvePlotGraph#PeakCenter"),pcsr(B, "RcurvePlotGraph#PeakCenter"))
		IN3_FitGaussTop("")
		IN3_RecalculateData(1)	
	endif
	if(stringMatch(ctrlName,"FitModGauss"))
		//get position of cursors from the right window and run fitting rouitne with gaussien
		PeakCenterFitStartPoint=min(pcsr(A, "RcurvePlotGraph#PeakCenter"),pcsr(B, "RcurvePlotGraph#PeakCenter"))
		PeakCenterFitEndPoint=max(pcsr(A, "RcurvePlotGraph#PeakCenter"),pcsr(B, "RcurvePlotGraph#PeakCenter"))
		IN3_FitModGaussTop("")
		IN3_RecalculateData(1)	
	endif
	if(stringMatch(ctrlName,"FitLorenz"))
		//get position of cursors from the right window and run fitting rouitne with lorenzian
		PeakCenterFitStartPoint=min(pcsr(A, "RcurvePlotGraph#PeakCenter"),pcsr(B, "RcurvePlotGraph#PeakCenter"))
		PeakCenterFitEndPoint=max(pcsr(A, "RcurvePlotGraph#PeakCenter"),pcsr(B, "RcurvePlotGraph#PeakCenter"))
		IN3_FitLorenzianTop("")
		IN3_RecalculateData(1)	
	endif
End

///**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IN3_FitGaussTop(ctrlname) : Buttoncontrol			// calls the Gaussien fit
	string ctrlname
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	NVAR PeakCenterFitStartPoint
	NVAR PeakCenterFitEndPoint

	Wave PD_error
	Wave Ar_encoder
	Wave PD_Intensity
	Make/O/N=200 PeakFitWave
	DoWIndow RcurvePlotGraph
	String ExistingSubWindows
	if(V_Flag)
		ExistingSubWindows=ChildWindowList("RcurvePlotGraph") 
	else
		ExistingSubWindows=""
	endif
	if(stringmatch(ExistingSubWindows,"*PeakCenter*"))
		getAxis/W=RcurvePlotGraph#PeakCenter /Q bottom
		SetScale/I x V_min, V_max,"", PeakFitWave
	else
		variable center = (PeakCenterFitStartPoint + PeakCenterFitEndPoint)/2
		variable start = max(0,center - (center -PeakCenterFitStartPoint) *3 )
		variable end1 = min(center + (PeakCenterFitEndPoint-center) *3, numpnts(Ar_encoder) )
		SetScale/I x Ar_encoder[start], Ar_encoder[end1],"", PeakFitWave
	endif
	K0=0
//	if(strlen(CsrInfo(A, "RcurvePlot")) <1  || strlen(CsrInfo(B, "RcurvePlot"))<1)
//		return 0
//	endif
	CurveFit/Q/N/H="1000" /L=50  gauss PD_Intensity [PeakCenterFitStartPoint,PeakCenterFitEndPoint]  /X=Ar_encoder/D /W=PD_error /I=1	//Gauss
//	print "Fitted Gaussian between points  "+num2str(PeakCenterFitStartPoint)+"   and    "+num2str(PeakCenterFitEndPoint)+"    reached Chi-squared/numpoints    " +num2str(V_chisq/(PeakCenterFitEndPoint-PeakCenterFitStartPoint))
//	string ModifyWave
//	ModifyWave="fit_"+WaveName("",0,1)						//new wave with the lorenzian fit
//	ModifyGraph /W=RcurvePlot lsize(fit_PD_Intensity)=3, rgb(fit_PD_intensity)=(0,15872,65280)
	NVAR BeamCenter
	NVAR MaximumIntensity
	NVAR PeakWidth		
	NVAR PeakWidthArcSec		
	Variable BeamCenterError, MaximumIntensityError, PeakWidthError
	Wave W_coef
	Wave W_sigma
//	Wave FitResiduals
//	FitResiduals= ((W_coef[0]+W_coef[1]*exp(-((Ar_encoder[p]-W_coef[2])/W_coef[3])^2)) - PD_Intensity[p])/PD_error[p]
//	FitResiduals[0,PeakCenterFitStartPoint-1]=NaN
//	FitResiduals[PeakCenterFitEndPoint+1,inf]=NaN
	PeakFitWave= W_coef[0]+W_coef[1]*exp(-((x-W_coef[2])/W_coef[3])^2)
	BeamCenter=W_coef[2]
	BeamCenterError=W_sigma[2]
	MaximumIntensity=W_coef[1]
	MaximumIntensityError=W_sigma[1]
	PeakWidth = 2*(sqrt(ln(2)))*abs(W_coef[3])
	PeakWidthArcSec = PeakWidth*3600
	PeakWidthError=2*(sqrt(ln(2)))*abs(W_sigma[3])
	Variable GaussPeakWidth=2*(sqrt(ln(2)))*abs(W_coef[3])			// properly fixed by now. 
	Variable GaussPeakWidthError=2*(sqrt(ln(2)))*abs(W_sigma[3])
	string BmCnterStr
	Sprintf BmCnterStr, "%8.5f", BeamCenter
	String Width="\Z12FWHM   "+num2str(3600*GaussPeakWidth)+" +/- "+num2str(3600*GaussPeakWidthError)+"  arc-sec"
	Width+="\rMax       "+num2str(MaximumIntensity)+"   +/-  "+num2str(MaximumIntensityError)
	Width+="\rBm Cntr  "+BmCnterStr+"  +/-  "+num2str(BeamCenterError)+"  deg."
	DoWindow RcurvePlotGraph
	if(V_Flag)
		Textbox/W=RcurvePlotGraph/K/N=text1
		TextBox/W=RcurvePlotGraph/N=text1/F=0/B=2/X=63.96/Y=89.45 Width
	endif
//	ModifyGraph rgb($ModifyWave)=(0,15872,65280)
//	KillWaves W_WaveList
	Wave/Z R_Qvec
	if(WaveExists(R_Qvec))
		string ListOfWaveNames = "R_Qvec;R_Int;R_Error;Qvec;"
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"PeakFitFunction","Gauss")
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"BeamCenter",num2str(BeamCenter))
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"MaximumIntensity",num2str(MaximumIntensity))
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"FWHM",num2str(PeakWidth*3600))
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"BeamCenterError",num2str(BeamCenterError))
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"MaximumIntensityError",num2str(MaximumIntensityError))
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"FWHM_Error",num2str(PeakWidthError*3600))
	endif
	setDataFolder OldDf

End
///**********************************************************************************************************
///**********************************************************************************************************
///**********************************************************************************************************
///**********************************************************************************************************
///**********************************************************************************************************

Function IN3_FitDefaultTop()
	NVAR UseModifiedGauss
	NVAR UseGauss
	NVAR UseLorenz

	if(UseModifiedGauss)
		IN3_FitModGaussTop("")	
	elseif(UseGauss)
		IN3_FitGaussTop("")
	elseif(UseLorenz)
		IN3_FitLorenzianTop("")
	else
		Abort "No default fiting method selected, please restart the tool"
	
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
///**********************************************************************************************************
///**********************************************************************************************************

Function IN3_FitModGaussTop(ctrlname) : Buttoncontrol			// calls the Gaussien fit
	string ctrlname
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	NVAR PeakCenterFitStartPoint
	NVAR PeakCenterFitEndPoint

	Wave PD_error
	Wave Ar_encoder
	Wave PD_Intensity
	Make/O/N=200 PeakFitWave
	DoWIndow RcurvePlotGraph
	String ExistingSubWindows
	if(V_Flag)
		ExistingSubWindows=ChildWindowList("RcurvePlotGraph") 
	else
		ExistingSubWindows=""
	endif
	if(stringmatch(ExistingSubWindows,"*PeakCenter*"))
		getAxis/W=RcurvePlotGraph#PeakCenter /Q bottom
		SetScale/I x V_min, V_max,"", PeakFitWave
	else
		variable center = (PeakCenterFitStartPoint + PeakCenterFitEndPoint)/2
		variable start = max(0,center - (center -PeakCenterFitStartPoint) *3 )
		variable end1 = min(center + (PeakCenterFitEndPoint-center) *3, numpnts(Ar_encoder) )
		SetScale/I x Ar_encoder[start], Ar_encoder[end1],"", PeakFitWave
	endif
//	K0=0
	MAKE/O/N=4 W_coef
	wavestats/Q PD_Intensity
	//workaround problems 2012/01, one large point appears ...
	Duplicate/Free PD_Intensity, tempPDInt
	tempPDInt[V_maxloc]=Nan
	wavestats/Q tempPDInt
	W_Coef[0]=V_max
	W_coef[1]=Ar_encoder[V_maxloc]
	FindLevels /N=5 /P/Q  tempPDInt, V_max/2.2
	wave W_FindLevels
	variable startPointL, endPointL
	if(Numpnts(W_FindLevels)==2)
		startPointL=W_FindLevels[0]
		endPointL=W_FindLevels[1]
	elseif(Numpnts(W_FindLevels)>2)
		FindLevel /P/Q W_FindLevels, V_maxloc
		startPointL = W_FindLevels[floor(V_LevelX)]
		endPointL = W_FindLevels[ceil(V_LevelX)]
	endif
//	Cursor/P /W=RcurvePlotGraph#PeakCenter A  PD_Intensity  startPointL 
//	Cursor/P /W=RcurvePlotGraph#PeakCenter B  PD_Intensity  endPointL 
	W_coef[2] = abs(Ar_encoder[startPointL] - Ar_encoder[endPointL])/(2*(2*ln(2))^0.5)
	W_coef[3]=2
	//W[3]>1		//modified 7/6/2010 per request from Fan. K3 coefficient needs to be large enough to avoid weird Peak shapes.
	Make/O/T/N=1 T_Constraints
	T_Constraints[0] = {"K3>1.3"}
	variable V_FitError=0
	FuncFit/Q/N/NTHR=0/L=50  IN3_ModifiedGauss W_coef PD_Intensity [PeakCenterFitStartPoint,PeakCenterFitEndPoint]  /X=Ar_encoder /D /W=PD_error /I=1 /C=T_Constraints 	//Gauss
	//FuncFit/Q/NTHR=0/L=50  IN3_ModifiedGauss W_coef PD_Intensity [startPointL,endPointL]  /X=Ar_encoder /D /W=PD_error /I=1 /C=T_Constraints 	//Gauss
	if(V_FitError>0)
		abort "Peak profile fitting function error. Please select wider range of data or change fitting function (Gauss is good choice)"
	endif
	NVAR BeamCenter
	NVAR MaximumIntensity
	NVAR PeakWidth		
	NVAR PeakWidthArcSec		
	Variable BeamCenterError, MaximumIntensityError, PeakWidthError
	Wave W_coef
	Wave W_sigma
	PeakFitWave= W_coef[0]*exp(-0.5*(abs(x-W_coef[1])/W_coef[2])^W_coef[3])
	BeamCenter=W_coef[1]
	BeamCenterError=W_sigma[1]
	MaximumIntensity=W_coef[0]
	MaximumIntensityError=W_sigma[0]
	PeakWidth = 2*W_coef[2]*(2*ln(2))^(1/W_coef[3])
	PeakWidthArcSec = PeakWidth*3600
	PeakWidthError= 0//2*W_sigma[2]*(2*ln(2))^(1/W_sigma[3])...........need to calcualte approximate value in the future... 
	Variable GaussPeakWidth=PeakWidth				//2*(sqrt(ln(2)))*abs(W_coef[3])			// properly fixed by now. 
	Variable GaussPeakWidthError=	PeakWidthError					//2*(sqrt(ln(2)))*abs(W_sigma[3])
	string BmCnterStr
	Sprintf BmCnterStr, "%8.5f", BeamCenter
	String Width="\Z12FWHM   "+num2str(3600*GaussPeakWidth)+" +/- "+num2str(3600*GaussPeakWidthError)+"  arc-sec"
	Width+="\rMax       "+num2str(MaximumIntensity)+"   +/-  "+num2str(MaximumIntensityError)
	Width+="\rBm Cntr  "+BmCnterStr+"  +/-  "+num2str(BeamCenterError)+"  deg."
	DoWindow RcurvePlotGraph
	if(V_Flag)
		Textbox/W=RcurvePlotGraph/K/N=text1
		TextBox/W=RcurvePlotGraph/N=text1/F=0/B=2/X=63.96/Y=89.45 Width
	endif
//	ModifyGraph rgb($ModifyWave)=(0,15872,65280)
//	KillWaves W_WaveList
	Wave/Z R_Qvec
	if(WaveExists(R_Qvec))
		string ListOfWaveNames = "R_Qvec;R_Int;R_Error;Qvec;"
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"PeakFitFunction","Modified Gauss")
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"BeamCenter",num2str(BeamCenter))
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"MaximumIntensity",num2str(MaximumIntensity))
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"FWHM",num2str(PeakWidth*3600))
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"BeamCenterError",num2str(BeamCenterError))
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"MaximumIntensityError",num2str(MaximumIntensityError))
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"FWHM_Error",num2str(PeakWidthError*3600))
	endif
	doupdate
	setDataFolder OldDf

End

//******************** name **************************************
///**********************************************************************************************************
//******************** FitLorenzianOnTopMacro **************************************

Function IN3_ModifiedGauss(w,xvar) : FitFunc
	Wave w
	Variable xvar

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(xvar) = Amplitude*exp(-0.5*(abs(xvar-center)/cparameter)^dparameter)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ xvar
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = Amplitude
	//CurveFitDialog/ w[1] = center
	//CurveFitDialog/ w[2] = cparameter
	//CurveFitDialog/ w[3] = dparameter

	return w[0]*exp(-0.5*(abs(xvar-w[1])/w[2])^w[3])
End

//******************** name **************************************
///**********************************************************************************************************
//******************** FitLorenzianOnTopMacro **************************************
Function IN3_FitLorenzianTop(ctrlname) : Buttoncontrol			// calls the Lorenzian fit
	string ctrlname
 
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	NVAR PeakCenterFitStartPoint
	NVAR PeakCenterFitEndPoint
 	Wave PD_Intensity
 	Wave Ar_encoder
 	Wave PD_error
	Make/O/N=200 PeakFitWave
	DoWIndow RcurvePlotGraph
	String ExistingSubWindows
	if(V_Flag)
		ExistingSubWindows=ChildWindowList("RcurvePlotGraph") 
	else
		ExistingSubWindows=""
	endif
	if(stringmatch(ExistingSubWindows,"*PeakCenter*"))
		getAxis/W=RcurvePlotGraph#PeakCenter /Q bottom
		SetScale/I x V_min, V_max,"", PeakFitWave
	else
		variable center = (PeakCenterFitStartPoint + PeakCenterFitEndPoint)/2
		variable start = max(0,center - (center -PeakCenterFitStartPoint) *3 )
		variable end1 = min(center + (PeakCenterFitEndPoint-center) *3, numpnts(Ar_encoder) )
		SetScale/I x Ar_encoder[start], Ar_encoder[end1],"", PeakFitWave
	endif

	K0=0
	CurveFit/Q/N/H="1000" /L=50  lor PD_Intensity [PeakCenterFitStartPoint,PeakCenterFitEndPoint]  /X=Ar_encoder/D /W=PD_error /I=1 //Lorenzian
//	print "Fitted Lorenzian between points  "+num2str(PeakCenterFitStartPoint)+"   and    "+num2str(PeakCenterFitEndPoint)+"    reached Chi-squared/numpoints     " +num2str(V_chisq/(PeakCenterFitEndPoint-PeakCenterFitStartPoint))
//	string ModifyWave
//	ModifyWave="fit_"+WaveName("",0,1)						//new wave with the lorenzian fit
	NVAR BeamCenter
	NVAR MaximumIntensity
	NVAR PeakWidth	
	NVAR PeakWidthArcSec	
	Variable BeamCenterError, MaximumIntensityError, PeakWidthError
	Wave W_coef
	Wave W_sigma
	Wave PeakFitWave
//	Wave FitResiduals
//	FitResiduals= ((W_coef[0]+W_coef[1]/((Ar_encoder[p]-W_coef[2])^2+W_coef[3]))-PD_Intensity[p])/PD_error[p]
//	FitResiduals[0,xcsr(A)-1]=NaN
//	FitResiduals[xcsr(B)+1,inf]=NaN
	PeakFitWave= W_coef[0]+W_coef[1]/((x-W_coef[2])^2+W_coef[3])
	BeamCenterError=W_sigma[2]
	BeamCenter=W_coef[2]
	MaximumIntensity=W_coef[1]/W_coef[3]
	MaximumIntensityError=IN2G_ErrorsForDivision(W_coef[1],W_sigma[1],W_coef[3],W_sigma[3])
	PeakWidth = 2*sqrt(W_coef[3])
	PeakWidthArcSec = PeakWidth*3600
	//according to Andrew, the error here needs to be propagated through fractional error
	//that is, error of sqrt(x), sigma(sx)=X*(sigma(X)/2*X)
	PeakWidthError=PeakWidth*(W_sigma[3]/(2*W_coef[3]))
	string BmCenterStr, BmCenterErrStr
	Sprintf BmCenterStr, "%8.5f", BeamCenter
	Sprintf BmCenterErrStr, "%8.5f", BeamCenterError
	String Width="\Z12FWHM   "+num2str(PeakWidth*3600)+ " +/- "+num2str(PeakWidthError*3600)+"  arc-sec"
	Width+="\rMax     "+num2str(MaximumIntensity)+" +/-  "+num2str(MaximumIntensityError)
	Width+="\rBm Cntr   : "+BmCenterStr+" +/- "+ num2str(BeamCenterError)+"  deg."
	DoWindow RcurvePlotGraph
	if(V_Flag)
		Textbox/W=RcurvePlotGraph/K/N=text1
		TextBox/W=RcurvePlotGraph/N=text1/F=0/B=2/X=63.96/Y=89.45 Width
	endif
//	ModifyGraph rgb($ModifyWave)=(0,15872,65280)
//	KillWaves W_WaveList
	string ListOfWaveNames = "R_Qvec;R_Int;R_Error;Qvec;"
//	IN2G_AppendNoteToListOfWaves(ListOfWaveNames, Key,notetext
	IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"PeakFitFunction","Lorenzian")
	IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"BeamCenter",num2str(BeamCenter))
	IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"MaximumIntensity",num2str(MaximumIntensity))
	IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"FWHM",num2str(sqrt(W_coef[3])*3600*2))
	IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"BeamCenterError",num2str(BeamCenterError))
	IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"MaximumIntensityError",num2str(MaximumIntensityError))
	IN2G_AppendNoteToListOfWaves(ListOfWaveNames,"FWHM_Error",num2str(sqrt(W_sigma[3])*3600*2))
End
//**********************************************************************************************************
//**********************************************************************************************************

//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************
Function IN3_ParametersChanged(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	//need to sync blanks widths, if changed by user...
	NVAR WidthDeg=root:Packages:Indra3:BlankFWHM
	NVAR WidthArcSec=root:Packages:Indra3:BlankWidth
	if(stringmatch(ctrlName,"BlankWidth"))
		WidthArcSec = WidthDeg * 3600
	endif
	if(stringmatch(ctrlName,"BlankWidthArcSec"))
		WidthDeg =  WidthArcSec/3600
	endif
	if(stringmatch(ctrlName,"SubtractFlatBackground"))
		NVAR SubtractFlatBackground= root:Packages:Indra3:SubtractFlatBackground
		SetVariable SubtractFlatBackground,win=USAXSDataReduction,limits={0,Inf,0.05*SubtractFlatBackground}
	endif

	
	//recalculate what needs to be done...
	IN3_RecalculateData(2)

	setDataFolder OldDf
End
///*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IN3_UPDParametersChanged(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	SVAR UPDList=UPDParameters
	
	if (!cmpstr(ctrlName,"VtoF"))						//Changing V to F
		UPDList=ReplaceNumberByKey("Vtof",UPDList, varNum,"=")
		UPDList=ReplaceNumberByKey("Vfc",UPDList, varNum,"=")
	endif
	if (!cmpstr(ctrlName,"Gain1"))						//Changing Gain1
		UPDList=ReplaceNumberByKey("Gain1",UPDList, varNum,"=")
	endif
	if (!cmpstr(ctrlName,"Gain2"))						//Changing Gain2
		UPDList=ReplaceNumberByKey("Gain2",UPDList, varNum,"=")
	endif
	if (!cmpstr(ctrlName,"Gain3"))						//Changing gain3
		UPDList=ReplaceNumberByKey("Gain3",UPDList, varNum,"=")
	endif
	if (!cmpstr(ctrlName,"Gain4"))						//Changing Gain4
		UPDList=ReplaceNumberByKey("Gain4",UPDList, varNum,"=")
	endif
	if (!cmpstr(ctrlName,"Gain5"))						//Changing Gain5
		UPDList=ReplaceNumberByKey("Gain5",UPDList, varNum,"=")
	endif
	if (!cmpstr(ctrlName,"Bkg1"))						//Changing Bkg 1
		UPDList=ReplaceNumberByKey("Bkg1",UPDList, varNum,"=")
	endif
	if (!cmpstr(ctrlName,"Bkg2"))						//Changing Bkg 2
		UPDList=ReplaceNumberByKey("Bkg2",UPDList, varNum,"=")
	endif
	if (!cmpstr(ctrlName,"Bkg3"))						//Changing Bkg 3
		UPDList=ReplaceNumberByKey("Bkg3",UPDList, varNum,"=")
	endif
	if (!cmpstr(ctrlName,"Bkg4"))						//Changing Bkg 4
		UPDList=ReplaceNumberByKey("Bkg4",UPDList, varNum,"=")
	endif
	if (!cmpstr(ctrlName,"Bkg5"))						//Changing Bkg 5
		UPDList=ReplaceNumberByKey("Bkg5",UPDList, varNum,"=")
	endif
	if (!cmpstr(ctrlName,"Bkg5Overwrite"))						//Changing Bkg 5
		NVAR UPD_DK5=root:Packages:Indra3:UPD_DK5
		UPDList=ReplaceNumberByKey("Bkg5",UPDList, varNum,"=")
		if(varNum>0)
			UPD_DK5 = varNum
		else
			SVAR MeasurementParameters = root:Packages:Indra3:MeasurementParameters
			UPD_DK5 = NumberByKey("Bkg5", MeasurementParameters, "=", ";")
		endif
	endif


	IN3_RecalculateData(1)			//and here we recalcualte the R wave
	setDataFolder OldDf
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function NI3_TabPanelControl(name,tab)
	String name
	Variable tab

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	NVAR IsBlank=root:Packages:Indra3:IsBlank



	NVAR CalculateWeight=root:Packages:Indra3:CalculateWeight
	NVAR CalculateThickness=root:Packages:Indra3:CalculateThickness
	NVAR CalibrateToWeight=root:Packages:Indra3:CalibrateToWeight
	NVAR CalibrateToVolume=root:Packages:Indra3:CalibrateToVolume
	NVAR CalibrateArbitrary=root:Packages:Indra3:CalibrateArbitrary
	NVAR UsePinTransmission=root:Packages:Indra3:UsePinTransmission
	NVAR UseMSAXSCorrection=root:Packages:Indra3:UseMSAXSCorrection

	Button RecoverDefault,win=USAXSDataReduction, disable=(tab!=0 || IsBlank)
	CheckBox CalibrateToVolume,win=USAXSDataReduction, disable=(tab!=0 || IsBlank)
	CheckBox CalibrateToWeight,win=USAXSDataReduction, disable=(tab!=0 || IsBlank)
	CheckBox CalibrateArbitrary,win=USAXSDataReduction, disable=(tab!=0 || IsBlank)

	SetVariable USAXSPinTvalue, win=USAXSDataReduction, disable=(tab!=0 || IsBlank)
	CheckBox UsePinTransmission, win=USAXSDataReduction, disable=(tab!=0 || IsBlank)
	SetVariable MSAXSCorrectionT0, win=USAXSDataReduction, disable=(tab!=0 || IsBlank || (!UsePinTransmission && !UseMSAXSCorrection) )
	SetVariable PeakToPeakTransmission, win=USAXSDataReduction, disable=(tab!=0 || IsBlank)
	
	CheckBox CalculateThickness,win=USAXSDataReduction, disable=(tab!=0 || IsBlank)
	CheckBox CalculateWeight,win=USAXSDataReduction, disable=(tab!=0 || IsBlank || !CalibrateToWeight )
	SetVariable SampleThickness,win=USAXSDataReduction, disable=(tab!=0 || IsBlank || CalibrateArbitrary), noedit=(CalculateThickness), frame=!CalculateThickness
	SetVariable SampleWeightInBeam,win=USAXSDataReduction, disable=(tab!=0 || IsBlank || !CalibrateToWeight || CalibrateArbitrary), noedit=CalculateWeight, frame=!CalculateWeight
	SetVariable SampleTransmission,win=USAXSDataReduction, disable=(tab!=0 || IsBlank)
	SetVariable SampleLinAbsorption,win=USAXSDataReduction, disable=(tab!=0 || IsBlank || CalibrateArbitrary), noedit=!CalculateThickness, frame=CalculateThickness
	SetVariable SampleDensity,win=USAXSDataReduction, disable=(tab!=0 || IsBlank || !CalibrateToWeight || CalibrateArbitrary), frame=CalculateWeight, noedit=!CalculateWeight
	SetVariable SampleFilledFraction,win=USAXSDataReduction, disable=(tab!=0 || IsBlank || !CalibrateToVolume || CalibrateArbitrary),noedit=!CalculateThickness, frame=CalculateThickness
	SetVariable FlyScanRebinToPoints,win=USAXSDataReduction, disable=(tab!=0 || IsBlank)
	//SetVariable BeamExposureArea, win=USAXSDataReduction, disable=(tab!=0 || IsBlank || CalibrateArbitrary), noedit=!(CalculateWeight&&CalibrateToWeight), frame=!CalculateWeight



	SetVariable VtoF,win=USAXSDataReduction, disable=(tab!=1)
	SetVariable Gain1,win=USAXSDataReduction, disable=(tab!=1)
	SetVariable Gain2,win=USAXSDataReduction, disable=(tab!=1)
	SetVariable Gain3,win=USAXSDataReduction, disable=(tab!=1)
	SetVariable Gain4,win=USAXSDataReduction, disable=(tab!=1)
	SetVariable Gain5,win=USAXSDataReduction, disable=(tab!=1)
	SetVariable Bkg1,win=USAXSDataReduction, disable=(tab!=1)
	SetVariable Bkg2,win=USAXSDataReduction, disable=(tab!=1)
	SetVariable Bkg3,win=USAXSDataReduction, disable=(tab!=1)
	SetVariable Bkg4,win=USAXSDataReduction, disable=(tab!=1)
	SetVariable Bkg5,win=USAXSDataReduction, disable=(tab!=1)
	SetVariable Bkg1Err,win=USAXSDataReduction, disable=(tab!=1)
	SetVariable Bkg2Err,win=USAXSDataReduction, disable=(tab!=1)
	SetVariable Bkg3Err,win=USAXSDataReduction, disable=(tab!=1)
	SetVariable Bkg4Err,win=USAXSDataReduction, disable=(tab!=1)
	SetVariable Bkg5Err,win=USAXSDataReduction, disable=(tab!=1)
	SetVariable Bkg5Overwrite,win=USAXSDataReduction, disable=(tab!=1)


	SetVariable SpecCommand,win=USAXSDataReduction, disable=(tab!=2)
	SetVariable PhotoDiodeSize,win=USAXSDataReduction, disable=(tab!=2)
	SetVariable Wavelength,win=USAXSDataReduction, disable=(tab!=2)
	SetVariable SDDistance,win=USAXSDataReduction, disable=(tab!=2)
	SetVariable SlitLength,win=USAXSDataReduction, disable=(tab!=2)
	SetVariable NumberOfSteps,win=USAXSDataReduction, disable=(tab!=2)

	SetVariable MaximumIntensity,win=USAXSDataReduction, disable=(tab!=3)
	SetVariable PeakWidth,win=USAXSDataReduction, disable=(tab!=3)
	SetVariable PeakWidthArcSec,win=USAXSDataReduction, disable=(tab!=3)
	SetVariable BlankMaximum,win=USAXSDataReduction, disable=(tab!=3 || IsBlank)
	SetVariable BlankWidth,win=USAXSDataReduction, disable=(tab!=3 || IsBlank)
	SetVariable BlankWidthArcSec,win=USAXSDataReduction, disable=(tab!=3 || IsBlank)
	SetVariable SubtractFlatBackground,win=USAXSDataReduction, disable=(tab!=3 || IsBlank)
	Button RecoverDefaultBlnkVals,win=USAXSDataReduction, disable=(tab!=3 || IsBlank)


	CheckBox UseMSAXSCorrection,win=USAXSDataReduction, disable=(tab!=4 || IsBlank)	
	//UseMSAXSCorrection
	SetVariable MSAXSCorrection,win=USAXSDataReduction, disable=(tab!=4 || !(UseMSAXSCorrection ||UsePinTransmission) || IsBlank)
	SetVariable MSAXSStartPoint,win=USAXSDataReduction, disable=(tab!=4 || !UseMSAXSCorrection || IsBlank)
	SetVariable MSAXSEndPoint,win=USAXSDataReduction, disable=(tab!=4 || !UseMSAXSCorrection || IsBlank)
	String ExistingSubWindows=ChildWindowList("USAXSDataReduction") 
	if(stringmatch(ExistingSubWindows,"*MSAXSGraph*") && IsBlank)
		KillWindow  USAXSDataReduction#MSAXSGraph
		ExistingSubWindows=ChildWindowList("USAXSDataReduction") 
	endif
	if(tab!=4 || !UseMSAXSCorrection)
			IN3_HideMSAXSGraph()
	else
		IN3_ShowMSAXSGraph()
//		if(!stringmatch(ExistingSubWindows,"*MSAXSGraph*"))
//			IN3_ShowMSAXSGraph()
//		else
//			//setWindow USAXSDataReduction#MSAXSGraph, hide =0	
//			IN3_ShowMSAXSGraph()
//		endif
//		if((!UseMSAXSCorrection || IsBlank) &&stringmatch(ExistingSubWindows,"*MSAXSGraph*")  )
//			IN3_ShowMSAXSGraph()
//		endif
	endif
	//color wave in main graph as appropriate
	if(tab==1)
		IN3_ColorMainGraph(1)
	else
		IN3_ColorMainGraph(0)
	endif
	
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function/T IN3_GenStringOfFolders(useBlankData)
	variable useBlankData 
	
	string ListOfQFolders
	string result
	if (useBlankData)
			result=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "Blank_*", 1)
	endif
	
	return result
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
