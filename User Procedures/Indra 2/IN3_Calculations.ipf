#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3			// Use modern global access method.
//#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.40

//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.40 added automatci location of the Qmin where data start due to Int Sa/Bl ratio. 
//1.39 Fixed step scanning GUI issues. 
//1.38 Added ability to overwrite Flyscan amplifier dead times. 
//1.37 fix bug when debugger when no data and Desmearing was checked. 
//1.36 fix manual page called by help button
//1.35 modify the sleep between multiple USAXS data reductions in IN3_InputPanelButtonProc to be more user friendly
//1.34 fixed which resulting waves are plotted to include M_DSM, DSM, M_SMR, and SMR waves in this order. 
//1.33 modified graph size control to use IN2G_GetGraphWidthHeight and associated settings. Should work on various display sizes. 
//1.32 changed main graph name and size is dynamic now. 
//1.31 added Desmearing as data reduction step. 
//1.30 some fixes in Modified Gauss fitting. Modifed to remeber better Qmin for processign in batch. 
//1.29 added live processing
//1.28 added OverRideSampleTransmission
//1.27 Fixes to Mod Gauss fitting to avoid problems when NaNs from range changes are present. 
//1.26 GUI fixes for USAXS graphs and panels
//1.25 added finding Qmin from FWHM of the sample peak
//1.24 enable override of UPDsize, which did not work up to now... 
//1.23 fixed Bkg5 Overwrite which was not correctly read intot he system. 
//1.22 Added support for Import & process new FLyscan processing GUI. 
//1.21 added PUD size to step scan data and some otehr changes. 
//1.20 added read UPD size to handle flyscanned data. Need finish for step scanning!
//1.19 minor fixes for panel scaling
//1.18 Remove Dropout function
//1.17 minor change in MOdified Gauss fit function which fixes sometime observed misfits. Coef wave MUST be double precision. 
//1.16 minor GUI chaneg to keep users advised abotu saving data
//1.15 modified fitting of the peak height for Modified gauss
//1.14 added save data to Load & process next button. Faster and easier. 
//1.13 extended Modified guass fitting range, speed up by avoiding display updates of teh top fittings (major speed increase). 
//1.12 increased Modified Guass fitting range slightly. 
//1.11 adds Overwrite for UPD dark current range 5
//1.10 adds FlyScan support
//1.09 controls for few more items displayed on Tab0 with pek-to-peak transmission and MSAXS/SAXS correction
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
	NVAR ListProcDisplayDelay = root:Packages:Indra3:ListProcDisplayDelay

	if(cmpstr(ctrlName,"GetHelp")==0)
		//Open www manual with the right page
		IN2G_OpenWebManual("Indra/FlyscanDataReduction.html")
	endif
	if(cmpstr(ctrlName,"GetReadme")==0)
		Dowindow USAXSQuickManual
		if (V_flag)
			Dowindow/F USAXSQuickManual
		else
			IN3_GenerateReadMe()	
		endif
	endif

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
	if (cmpstr(ctrlName,"LiveProcessing")==0)
		IN3_OnLineDataProcessing()	
	endif
	if (cmpstr(ctrlName,"ProcessData2")==0 || cmpstr(ctrlName,"SelectNextSampleAndProcess2")==0)
		//import the data
		variable howMany
		if(cmpstr(ctrlName,"ProcessData2")==0)
			howMany=0
		else
			howMany=1
		endif
		string LoadedDataList = IN3_FlyScanLoadHdf5File2(howMany)		//0 is for load 1, 1 is for load all selected. 
		variable Items, i
		if(cmpstr(ctrlName,"ProcessData2")==0)
			Items=1
		else
			Items=ItemsInList(LoadedDataList)
		endif
		//remember where the cursor of Qmin is...  
		variable/g QminDefaultForProcessing
		NVAR QminDefaultForProcessing
		Wave/Z R_qvec
		DoWIndow RcurvePlotGraph
		if(WaveExists(R_qvec) && V_Flag && strlen(CsrInfo(A,"RcurvePlotGraph")))
			QminDefaultForProcessing = R_Qvec[pcsr(A, "RcurvePlotGraph")]
		else
			QminDefaultForProcessing = 0
		endif
		//it should be recoded now. 
		For(i=0;i<Items;i+=1)
			SVAR DataFolderName=	root:Packages:Indra3:DataFolderName
			DataFolderName = stringFromList(i,LoadedDataList)
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
			IN3_ReturnCursorBack(QminDefaultForProcessing)
			IN3_FitDefaultTop()
			IN3_RecalculateData(4)
			IN3_FitDefaultTop()
			IN3_GetDiodeTransmission(0)
			IN3_RecalculateData(1)
			TabControl DataTabs , value= 0, win=USAXSDataReduction
			NI3_TabPanelControl("",0)
			IN3_DesmearData()
			DoWIndow/F USAXSDataReduction
			ResumeUpdate
			DoUpdate /W=RcurvePlotGraph
			//DoUpdate /W=USAXSDataReduction
			if(howMany)
				IN3_SaveData()	
				NVAR UserSavedData=root:Packages:Indra3:UserSavedData
				UserSavedData=2
				IN3_FixSaveData()
				DoWIndow/F USAXSDataReduction
				UserSavedData=1
				IN3_FixSaveData()
				if(i<Items-1)	
					sleep/S/B/Q/C=6/M="Delay "+num2str(ListProcDisplayDelay)+" seconds for user data review" ListProcDisplayDelay
				endif
			endif
		endfor
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
		IN3_ReturnCursorBack(0)
		IN3_FitDefaultTop()
		IN3_RecalculateData(4)
		IN3_FitDefaultTop()
		IN3_GetDiodeTransmission(0)
		IN3_RecalculateData(1)
		IN3_DesmearData()
		TabControl DataTabs , value= 0, win=USAXSDataReduction
		NI3_TabPanelControl("",0)
		DoWIndow/F USAXSDataReduction
		if (cmpstr(ctrlName,"SelectNextSampleAndProcess")==0)
			IN3_SaveData()	
			NVAR UserSavedData=root:Packages:Indra3:UserSavedData
			UserSavedData=1
			IN3_FixSaveData()
			DoWIndow/F USAXSDataReduction
		endif
	endif
	if (cmpstr(ctrlName,"RemovePointsRange")==0)
		RemovePointsWithMarquee()
	endif
	if (cmpstr(ctrlName,"Recalculate")==0)
		IN3_RecalculateData(1)	
		DoWIndow/F USAXSDataReduction
		IN3_FixSaveData()
		IN3_DesmearData()
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
		IN3_DesmearData()
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
		IN3_DesmearData()
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

static Function IN3_ReturnCursorBack(QminDefaultForProcessing)
	variable QminDefaultForProcessing
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	Wave R_Int=root:Packages:Indra3:R_Int
	Wave R_Qvec=root:Packages:Indra3:R_Qvec
	Wave/Z BL_R_Int = root:Packages:Indra3:BL_R_Int
	if(!WaveExists(BL_R_Int))		//reducing Blank, return and do nothing... 
		return 0
	endif
	Wave BL_R_Qvec = root:Packages:Indra3:BL_R_Qvec
	NVAR PeakWidth = root:Packages:Indra3:PeakWidthArcSec
	NVAR BlankWidth = root:Packages:Indra3:BlankWidth
	NVAR Wavelength = root:Packages:Indra3:Wavelength


	variable HaveMSAXSCOrrection=0
	variable QminTheoretical
	variable Qmin 
	NVAR/Z FindMinQForData=root:Packages:Indra3:FindMinQForData		//added 2019-04 as convenience, find min Q when Int > IntBl*2
	NVAR/Z MinQMinFindRatio=root:Packages:Indra3:MinQMinFindRatio
	if(!NVAR_Exists(FindMinQForData))
		variable/g FindMinQForData
		FindMinQForData = 1
		variable/g MinQMinFindRatio
		MinQMinFindRatio = 1.3
	endif
	NVAR/Z OldStartQValueForEvaluation
	if(!NVAR_Exists(OldStartQValueForEvaluation))
		variable/g OldStartQValueForEvaluation
		OldStartQValueForEvaluation = QminDefaultForProcessing
	endif

	//this is real instrument Qmin under any conditions... 
	QminTheoretical = 4 * pi * sin(PeakWidth*4.848e-6 /2) / Wavelength
	Qmin = QminTheoretical
	if (Qmin > OldStartQValueForEvaluation)
		Qmin = OldStartQValueForEvaluation
	endif
	//now calculate Qmin based in intensity difference... 
	variable QminIntDifference=0
	variable QminAUtoFOund=0
	variable QminBl = 1.05 * 4 * pi * sin(BlankWidth*4.848e-6 /2) / Wavelength		//This is Qmin due to multiple scattering... scaled up a bit to make sure this makes sense... 

	if(FindMinQForData)
			Duplicate/Free R_Int, IntRatio
			Duplicate/Free R_Qvec, QCorrection	//this is per point correction, we need bigger difference at low-q than high-q
			//need to find function which is q dependent and varies from Max correction to 1 over our range of Qs. 
			variable MaxCorrection = 2
			variable PowerCorrection=4
			QCorrection =  1 + MaxCorrection*(abs(QminTheoretical/R_Qvec))^PowerCorrection
			QCorrection = (QCorrection<(MaxCorrection+1)) ? QCorrection : (MaxCorrection+1)
			//the above should peak at Q=0 with max correction of "MaxCorrection"+1 and drop off as function of q resolution. 
			Duplicate/Free BL_R_Int, LogBlankInt
			LogBlankInt = log(BL_R_Int)
			IntRatio = interp(R_Qvec, BL_R_Qvec, LogBlankInt)		//this is interpolated log(BlankInt)
			IntRatio = 10^IntRatio											//interpolated BlankInt
			IntRatio = R_Int / IntRatio										//this is R_int/BlankInt (interpolated to R_+Qvec)
			IntRatio = IntRatio / QCorrection
			FindLevel  /Q/EDGE=1 IntRatio, MinQMinFindRatio
			if(V_Flag==0)	//found level
				QminIntDifference = R_Qvec[ceil(V_LevelX)]
				if(QminIntDifference > QminTheoretical)
					Qmin = QminIntDifference									//this overwrites the Qmin selection, based on Intensity difference. User uses checkbox to control this!
					QminAUtoFOund = 1
				ELSE
					Qmin = QminTheoretical
					QminAUtoFOund = 1
				endif
			endif
	endif																	//so now, if user wants, we have qmin when data are 2*Background (first time). 

	//		multiple scattering
	//lets try to set Qmin for user based on FWHM, this is correction for multiple scattering. 
	//this needs to be done later as MSAXS will have plenty of scattering, so intensity differedce makes no sense here... 
	if( QminTheoretical > 1.1 * QminBl)
		Qmin = QminTheoretical
		QminIntDifference = 0				//set to 0, indicates that we should not use autolocated value. 
		//QminTheoretical = Qmin
		HaveMSAXSCOrrection = 1
	else	//single scattering

	endif
	//now the logic what to use and when... 
	TextBox/C/W=RcurvePlotGraph/A=LB/X=0.2/Y=0.20/E=2/N=QminInformation/F=0 "\\Z10\\K(0,12800,52224)Theoretical Qmin of these data is = "+num2str(QminTheoretical)
	//
	if (QminAUtoFOund && !HaveMSAXSCOrrection)		//use autolocated value 
		OldStartQValueForEvaluation = Qmin
		print "Warning - Qmin automatic search was requested. Located Qmin = "+num2str(Qmin)
		TextBox/C/W=RcurvePlotGraph/N=QminReset/F=0/A=LT "\Zr050Located Qmin based on Int Sa/Bl ratio. Set to calculated Qmin = "+num2str(Qmin)
		Cursor /P /W=RcurvePlotGraph  A  R_Int  round(BinarySearchInterp(R_Qvec, OldStartQValueForEvaluation ))
		Cursor /P /W=RcurvePlotGraph  B  R_Int  (numpnts(R_Qvec)-1)
	elseif(HaveMSAXSCOrrection)			//this is in case of multiple scattering... 
		OldStartQValueForEvaluation = Qmin
		print "Warning - too small Qmin detected due to MSAXS. Reset to calculated Qmin = "+num2str(Qmin)
		print "This can be due to multiple scattering in the sample. Note, you may need to return the Qmin back for other samples" 
		TextBox/C/W=RcurvePlotGraph/N=QminReset/F=0/A=LT "\Zr050Warning - small Qmin detected due to MSAXS. Reset to calculated Qmin = "+num2str(Qmin)
		Cursor /P /W=RcurvePlotGraph  A  R_Int  round(BinarySearchInterp(R_Qvec, OldStartQValueForEvaluation ))
		Cursor /P /W=RcurvePlotGraph  B  R_Int  (numpnts(R_Qvec)-1)
	else
		Qmin = OldStartQValueForEvaluation															//any other case... 
		Cursor /P /W=RcurvePlotGraph  A  R_Int  round(BinarySearchInterp(R_Qvec, Qmin ))
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
		if(UserSavedData==0)
			Button SaveResults fColor=(65280,0,0), win=USAXSDataReduction
			TitleBox SavedData  title="  Data   NOT   saved  ", fColor=(0,0,0), frame=1,labelBack=(65280,0,0), win=USAXSDataReduction
		elseif(UserSavedData==1)
			Button SaveResults , win=USAXSDataReduction, fColor=(47872,47872,47872)
			TitleBox SavedData  title="  Data   are   saved  ", fColor=(0,0,0),labelBack=(47872,47872,47872),  frame=2, win=USAXSDataReduction
		elseif(UserSavedData==2)
			Button SaveResults , win=USAXSDataReduction, fColor=(47872,47872,47872)
			TitleBox SavedData  title="Disp. results, will continue", fColor=(0,0,0),labelBack=(3,52428,1),  frame=2, win=USAXSDataReduction
		else
			Button SaveResults , win=USAXSDataReduction, fColor=(47872,47872,47872)
			TitleBox SavedData  title="               ", fColor=(0,0,0),labelBack=(47872,47872,47872),  frame=2, win=USAXSDataReduction		
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
	//read current size of UPD
	NVAR PhotoDiodeSize=root:packages:Indra3:PhotoDiodeSize
	PhotoDiodeSize=NumberByKey("UPDsize", UPD,"=")																//Default PD size to 5.5mm at this time....
	if(numtype(PhotoDiodeSize)!=0|| PhotoDiodeSize<=1)
		PhotoDiodeSize = 5.5
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
	
	//First Kill waves which may cause conflict. 
	KillWIndow/Z RcurvePlotGraph
 	String ListOfWaves  = DataFolderDir (2)[6,inf]
	ListOfWaves = RemoveFromList("ListBoxDataSelWv", ListOfWaves,",")
	ListOfWaves = RemoveFromList("ListBoxDataPositions", ListOfWaves,",")
	ListOfWaves = RemoveFromList("ListBoxData", ListOfWaves,",")
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
		SVAR userFriendlySampleDFName = root:Packages:Indra3:userFriendlySampleDFName
		userFriendlySamplename = OrigSpecComment
		userFriendlySampleDFName = StringFromList(ItemsInList(DFloc, ":")-1, DFloc,":")
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
		//2017-01-18 add override Sample thickness
		NVAR OverRideTh=root:Packages:Indra3:OverideSampleThickness
		if(OverRideTh>0)
			SampleThickness = OverRideTh
		endif
		
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
		SVAR userFriendlyBlankName= root:Packages:Indra3:userFriendlyBlankName
		userFriendlyBlankName = StringFromList(ItemsInList(BlankName,":")-1, BlankName, ":")
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
	KillWIndow/Z RcurvePlotGraph
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
		NVAR SmoothRCurveData=root:Packages:Indra3:SmoothRCurveData
		PopupMenu SelectBlankFolder, disable = IsBlank
		//check if Blank name is correct
		SVAR BlankName = root:Packages:Indra3:BlankName
		if((stringMatch(BlankName,"")||stringMatch(BlankName,"---"))&&!IsBlank)
			BlankName = StringFromList(0,IN3_GenStringOfFolders(1))
			PopupMenu SelectBlankFolder win=USAXSDataReduction, mode=WhichListItem(BlankName, "---;"+IN3_GenStringOfFolders(1))+1, value="---;"+IN3_GenStringOfFolders(1) 
			Print "No Blank was selected, we found Blank "+BlankName+"  , and used this one. Change if necessary."
			TitleBox SelectBlankFolderWarning win=USAXSDataReduction, disable=0
		elseif(!stringMatch(BlankName,"")&&!IsBlank)
			TitleBox SelectBlankFolderWarning win=USAXSDataReduction, disable=1
			PopupMenu SelectBlankFolder win=USAXSDataReduction, mode=WhichListItem(BlankName, "---;"+IN3_GenStringOfFolders(1))+1, value="---;"+IN3_GenStringOfFolders(1) 
		endif
		if(isBlank)
			TitleBox SelectBlankFolderWarning win=USAXSDataReduction, disable=1
			SmoothRCurveData=1
		else
			SmoothRCurveData=0
		endif
	endif
	if (cmpstr("RecalculateAutomatically",ctrlName)==0)

	endif
	if (cmpstr("SmoothRCurveData",ctrlName)==0)
			IN3_RecalculateData(2)
			IN3_DesmearData()
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
		IN3_RecalculateData(3)
		IN3_DesmearData()
	endif
	if (cmpstr("UsePinTransmission",ctrlName)==0)
		IF(checked)
			 UseMSAXSCorrection=0
		endif
		NI3_TabPanelControl("",0)
		IN3_RecalculateData(3)
		IN3_DesmearData()
	endif
	if (cmpstr("RemoveDropouts",ctrlName)==0)
		IN3_RecalculateData(1)
		IN3_DesmearData()
	endif
	
	if (cmpstr("DesmearData",ctrlName)==0)
		NI3_TabPanelControl("",5)
		IN3_RecalculateData(1)
		IN3_DesmearData()
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
	//variable NewWidth = 0.6*(IN2G_ScreenWidthHeight("width")*100) - 300
	//variable NewHeight = 0.6*(IN2G_ScreenWidthHeight("height")*100)
	//variable NewWidth = IN2G_GetGraphWidthHeight("width")
	//variable NewHeight = IN2G_GetGraphWidthHeight("height")
	//Display/K=1 /W=(300,36.5,900,500) R_Int vs R_Qvec as "USAXS data reduction plot"
	Display/K=1 /W=(0,0,IN2G_GetGraphWidthHeight("width"),IN2G_GetGraphWidthHeight("height")) R_Int vs R_Qvec as "USAXS data reduction plot"
	DoWindow/C RcurvePlotGraph
	AutoPositionWindow/M=1/R=USAXSDataReduction  RcurvePlotGraph
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
	SetVariable SampleTransmission,pos={200,5},size={300,22},title="Sample transmission (peak max)"
	SetVariable SampleTransmission,proc=IN3_ParametersChanged
	SetVariable SampleTransmission,limits={0,inf,0.005},variable= root:Packages:Indra3:SampleTransmissionPeakToPeak

	SetVariable SampleAngleOffset,pos={200,25},size={300,22},title="Q offset              "
	SetVariable SampleAngleOffset,proc=IN3_ParametersChanged
	SetVariable SampleAngleOffset,limits={-inf,inf,0.5e-6},variable= root:Packages:Indra3:SampleQOffset

	Button Recalculate,pos={170,25},size={100,20},proc=IN3_InputPanelButtonProc,title="\Zr090Recalculate", help={"Recalculate the data"}
	Button Recalculate fColor=(40969,65535,16385)
	Button RemovePointsRange,pos={280,3},size={100,20},proc=IN3_InputPanelButtonProc,title="\Zr090Rem pnts w/Marquee", help={"Remove point by selecting Range with Marquee"}
	Button RemovePoint,pos={280,25},size={100,20},proc=IN3_InputPanelButtonProc,title="\Zr090Remove pnt w/csr A", help={"Remove point with cursor A"}
	Button FixGain,pos={170,3},size={100,20}, proc=IN3_GraphButtonProc,title="\Zr090Fix Gain w/c A"

	CheckBox UseModifiedGauss title="\Zr090Mod. Gauss",proc=IN3_RplotCheckProc
	CheckBox UseModifiedGauss variable=root:Packages:Indra3:UseModifiedGauss,mode=1,pos={385,1}
	CheckBox UseGauss title="\Zr090Gauss",proc=IN3_RplotCheckProc
	CheckBox UseGauss variable=root:Packages:Indra3:UseGauss,mode=1,pos={385,17}
	CheckBox UseLorenz title="\Zr090Lorenz",proc=IN3_RplotCheckProc
	CheckBox UseLorenz variable=root:Packages:Indra3:UseLorenz,mode=1,pos={385,34}

	Button FitModGauss,pos={465,3},size={80,18}, proc=IN3_GraphButtonProc,title="\Zr090Fit Mod. Gauss"
	Button FitGauss,pos={555,3},size={80,18}, proc=IN3_GraphButtonProc,title="\Zr090Fit Gauss"
	Button FitLorenz,pos={555,25},size={80,18}, proc=IN3_GraphButtonProc,title="\Zr090Fit Lorenz"

	CheckBox DisplayPeakCenter title="Display Peak Fit",proc=IN3_RplotCheckProc
	CheckBox DisplayPeakCenter variable=root:Packages:Indra3:DisplayPeakCenter,mode=1,pos={5,5}
	CheckBox DisplayAlignSaAndBlank title="Display Align Sa and Blank",proc=IN3_RplotCheckProc, disable=IsBlank
	CheckBox DisplayAlignSaAndBlank variable=root:Packages:Indra3:DisplayAlignSaAndBlank,mode=1,pos={5,25}
	//append sample and blank names...
	SVAR userFriendlySamplename = root:Packages:Indra3:userFriendlySamplename
	SVAR userFriendlyBlankName = root:Packages:Indra3:userFriendlyBlankName
	SVAR LastSample = root:Packages:Indra3:LastSample
	string LegendString="\\Zr130\\K(52224,0,0)Sample : "+userFriendlySamplename
	LegendString+="\r\\Zr090\\K(0,0,0)File : "+stringFromList(ItemsInList(LastSample,":")-1, LastSample, ":")
	SetDrawLayer UserFront
	IN3_COlorizeButton()
	NVAR IsBlank=root:Packages:Indra3:IsBlank
	if(!IsBlank)
		Wave/Z BL_R_Int=root:Packages:Indra3:BL_R_Int
		Wave/Z BL_R_error=root:Packages:Indra3:BL_R_error
		Wave/Z BL_R_Qvec= root:Packages:Indra3:BL_R_Qvec
		AppendToGraph BL_R_Int vs BL_R_Qvec
		ModifyGraph rgb(BL_R_Int)=(0,0,0), mode(BL_R_Int)=0
		NVAR TrimDataStart=root:Packages:Indra3:TrimDataStart
		NVAR TrimDataEnd=root:Packages:Indra3:TrimDataEnd
		if(TrimDataStart>0)
			Cursor/P/W=RcurvePlotGraph A R_Int TrimDataStart	
		endif
		if(TrimDataEnd>0)
			Cursor/P/W=RcurvePlotGraph B R_Int TrimDataEnd	
		endif
		LegendString+="\r\\K(0,0,0)Blank : "+userFriendlyBlankName
	endif
	TextBox/C/N=SampleAndBLank/A=LC/F=0/B=1/X=0.00/Y=-25.00 LegendString
	

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
	Wave PD_Intensity
	Wave PD_Error
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
				IN3_DesmearData()
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
		IN3_DesmearData()
	endif
	if(stringMatch(ctrlName,"FitModGauss"))
		//get position of cursors from the right window and run fitting rouitne with gaussien
		PeakCenterFitStartPoint=min(pcsr(A, "RcurvePlotGraph#PeakCenter"),pcsr(B, "RcurvePlotGraph#PeakCenter"))
		PeakCenterFitEndPoint=max(pcsr(A, "RcurvePlotGraph#PeakCenter"),pcsr(B, "RcurvePlotGraph#PeakCenter"))
		IN3_FitModGaussTop("", 1)
		IN3_RecalculateData(1)	
		IN3_DesmearData()
	endif
	if(stringMatch(ctrlName,"FitLorenz"))
		//get position of cursors from the right window and run fitting rouitne with lorenzian
		PeakCenterFitStartPoint=min(pcsr(A, "RcurvePlotGraph#PeakCenter"),pcsr(B, "RcurvePlotGraph#PeakCenter"))
		PeakCenterFitEndPoint=max(pcsr(A, "RcurvePlotGraph#PeakCenter"),pcsr(B, "RcurvePlotGraph#PeakCenter"))
		IN3_FitLorenzianTop("")
		IN3_RecalculateData(1)	
		IN3_DesmearData()
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
	//Duplicate /R=[PeakCenterFitStartPoint,PeakCenterFitEndPoint]/Free PD_Intensity, PDIntFit
	//Duplicate /R=[PeakCenterFitStartPoint,PeakCenterFitEndPoint]/Free Ar_encoder, ArEncFit
	//Duplicate /R=[PeakCenterFitStartPoint,PeakCenterFitEndPoint]/Free PD_error, PDErrFit
	//IN2G_RemoveNaNsFrom3Waves(PDIntFit,ArEncFit,PDErrFit)	
	//CurveFit/Q/N/H="1000" /L=50  gauss PDIntFit  /X=ArEncFit/D /W=PDErrFit /I=1	//Gauss
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
		IN3_FitModGaussTop("",0)	
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

Function IN3_FitModGaussTop(ctrlname, DoNOtChangeLimits) : Buttoncontrol			// calls the Gaussien fit
	string ctrlname
	variable DoNOtChangeLimits			//added 6-2017 to prevent some crashes in fitting...   
	
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
	MAKE/O/D/N=4 W_coef		//fix 2015-06 Coefficient wave MUST be double precision or weird things happen with fits. 
	wavestats/Q PD_Intensity
	//workaround problems 2012/01, one large point appears ...
	Duplicate/Free PD_Intensity, tempPDInt
	//this tempPDInt needs nan's removed. need to interpolate values?
	wavestats/Q tempPDInt
	tempPDInt[V_maxloc]=Nan
	W_Coef[0]=V_max
	W_coef[1]=Ar_encoder[V_maxloc]
	FindLevels /N=5/P/Q  tempPDInt, V_max/2
	wave W_FindLevels
	variable startPointL, endPointL
	if(DoNOtChangeLimits)
		startPointL=PeakCenterFitStartPoint
		endPointL=PeakCenterFitEndPoint	
	else
		if(Numpnts(W_FindLevels)==2)
			startPointL=W_FindLevels[0]
			endPointL=W_FindLevels[1]
		elseif(Numpnts(W_FindLevels)>2)
			FindLevel /P/Q W_FindLevels, V_maxloc
			startPointL = W_FindLevels[floor(V_LevelX)]
			endPointL = W_FindLevels[ceil(V_LevelX)]
		elseif(Numpnts(W_FindLevels)<2)		//only one or no crossing found? this happens when NaNs are in the waves
		 	startPointL =  IN3_FindlevelsWithNaNs(tempPDInt, V_max/2, V_maxloc, 0)
		 	endPointL = IN3_FindlevelsWithNaNs(tempPDInt, V_max/2, V_maxloc, 1)
		endif
	endif
//	Cursor/P /W=RcurvePlotGraph#PeakCenter A  PD_Intensity  startPointL 
//	Cursor/P /W=RcurvePlotGraph#PeakCenter B  PD_Intensity  endPointL 
	W_coef[2] = abs(Ar_encoder[startPointL] - Ar_encoder[endPointL])/(2*(2*ln(2))^0.5)
	W_coef[3]=2
	//W[3]>1		//modified 7/6/2010 per request from Fan. K3 coefficient needs to be large enough to avoid weird Peak shapes.
	//more cahnges 6-2017 to fix failures in fitting. 
	Make/O/T/N=3 T_Constraints
	T_Constraints[0] = {"K3>1.3"}
	T_Constraints[1] = {"K3<3"}
	T_Constraints[2] = {"K2<0.0006"}
	variable V_FitError=0
	FuncFit/NTHR=0/Q/N  IN3_ModifiedGauss W_coef PD_Intensity [PeakCenterFitStartPoint,PeakCenterFitEndPoint]  /X=Ar_encoder /D /W=PD_error /I=1 /C=T_Constraints 	//Gauss
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
Function IN3_FindlevelsWithNaNs(waveIn, LevelSearched, MaxLocation, LeftRight)
	wave waveIn
	variable LevelSearched, MaxLocation, LeftRight
	//set LeftRight to 0 for left and 1 for right of the MaxLocation
	variable LevelPoint = 0
	variable counter = MaxLocation
	variable Done=0
	Do
		if(LeftRight)
			counter+=1
		else
			counter-=1
		endif
		if(numtype(waveIn[counter])==0)
			LevelPoint = counter
			if(waveIn[counter]>LevelSearched && counter>0 && Counter<numpnts(WaveIn)) //fix when cannot reach 50% or less value... 
				LevelPoint = counter
			else
			   if(abs(MaxLocation-LevelPoint)>3)
					Done=1
				endif
			endif
		endif	
	while (Done<1)	
	return LevelPoint	
end
	
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
	DoWIndow RcurvePlotGraph				//only of the graph exists, or we get error... 
	if(V_Flag)
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
		if(stringmatch(ctrlName,"PhotoDiodeSize"))
			SVAR UPDParameters= root:Packages:Indra3:UPDParameters
			UPDParameters =  ReplaceNumberByKey("UPDsize", UPDParameters, varNum, "=")
		endif
		if(stringmatch(ctrlName,"OverideSampleThickness"))
			NVAR OverideSampleThickness=root:Packages:Indra3:OverideSampleThickness
			NVAR SampleThickness=root:Packages:Indra3:SampleThickness
			NVAR SampleThicknessBckp=root:Packages:Indra3:SampleThicknessBckp
			if(OverideSampleThickness>0)
				SampleThickness = OverideSampleThickness
			else
				SampleThickness = SampleThicknessBckp
			endif
			IN3_RecalculateData(2)
			IN3_DesmearData()
			DoWIndow/F USAXSDataReduction
			//SVAR UPDParameters= root:Packages:Indra3:UPDParameters
			//UPDParameters =  ReplaceNumberByKey("UPDsize", UPDParameters, varNum, "=")
		endif
	
		if(stringmatch(ctrlName,"BckgStartQ"))
			IN3_DesmearData()
		endif
		NVAR RemoveDropouts = root:Packages:Indra3:RemoveDropouts
		//recalculate what needs to be done...
		if((stringmatch(ctrlName,"RemoveDropoutsTime")) || (stringmatch(ctrlName,"RemoveDropoutsFraction")) || (stringmatch(ctrlName,"RemoveDropoutsAvePnts")))
			if(RemoveDropouts)
				IN3_RecalculateData(1)
				IN3_DesmearData()
			endif
		else
			IN3_RecalculateData(2)
			IN3_DesmearData()
		endif
	endif
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
		if(varNum!=0)
			UPD_DK5 = varNum
			UPDList=ReplaceNumberByKey("Bkg5",UPDList, UPD_DK5,"=")
		else
			SVAR MeasurementParameters = root:Packages:Indra3:MeasurementParameters
			UPD_DK5 = NumberByKey("Bkg5", MeasurementParameters, "=", ";")
			UPDList=ReplaceNumberByKey("Bkg5",UPDList, UPD_DK5,"=")
		endif
	endif


	IN3_RecalculateData(1)			//and here we recalcualte the R wave
	IN3_DesmearData()
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
	NVAR DesmearData = root:Packages:Indra3:DesmearData

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
	SetVariable OverideSampleThickness,win=USAXSDataReduction, disable=(tab!=0 || IsBlank || CalibrateArbitrary), noedit=(CalculateThickness), frame=!CalculateThickness
	SetVariable SampleWeightInBeam,win=USAXSDataReduction, disable=(tab!=0 || IsBlank || !CalibrateToWeight || CalibrateArbitrary), noedit=CalculateWeight, frame=!CalculateWeight
	SetVariable SampleTransmission,win=USAXSDataReduction, disable=(tab!=0 || IsBlank)
	SetVariable SampleLinAbsorption,win=USAXSDataReduction, disable=(tab!=0 || IsBlank || CalibrateArbitrary), noedit=!CalculateThickness, frame=CalculateThickness
	SetVariable SampleDensity,win=USAXSDataReduction, disable=(tab!=0 || IsBlank || !CalibrateToWeight || CalibrateArbitrary), frame=CalculateWeight, noedit=!CalculateWeight
	SetVariable SampleFilledFraction,win=USAXSDataReduction, disable=(tab!=0 || IsBlank || !CalibrateToVolume || CalibrateArbitrary),noedit=!CalculateThickness, frame=CalculateThickness
	SetVariable FlyScanRebinToPoints,win=USAXSDataReduction, disable=(tab!=0 || IsBlank)
	//SetVariable BeamExposureArea, win=USAXSDataReduction, disable=(tab!=0 || IsBlank || CalibrateArbitrary), noedit=!(CalculateWeight&&CalibrateToWeight), frame=!CalculateWeight


	TitleBox Info3,win=USAXSDataReduction, disable=(tab!=1)
	TitleBox Info4,win=USAXSDataReduction, disable=(tab!=1) 
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
	
	ControlInfo/W=USAXSDataReduction FSOverWriteRage1DeadTime
	if(V_Flag!=0)
		SetVariable FSOverWriteRage1DeadTime,win=USAXSDataReduction, disable=(tab!=1)
		SetVariable FSOverWriteRage2DeadTime,win=USAXSDataReduction, disable=(tab!=1)
		SetVariable FSOverWriteRage3DeadTime,win=USAXSDataReduction, disable=(tab!=1)
		SetVariable FSOverWriteRage4DeadTime,win=USAXSDataReduction, disable=(tab!=1)
		SetVariable FSOverWriteRage5DeadTime,win=USAXSDataReduction, disable=(tab!=1)
		SetVariable FSRage1DeadTime,win=USAXSDataReduction, disable=(tab!=1)
		SetVariable FSRage2DeadTime,win=USAXSDataReduction, disable=(tab!=1)
		SetVariable FSRage3DeadTime,win=USAXSDataReduction, disable=(tab!=1)
		SetVariable FSRage4DeadTime,win=USAXSDataReduction, disable=(tab!=1)
		SetVariable FSRage5DeadTime,win=USAXSDataReduction, disable=(tab!=1)
		TitleBox Info5,win=USAXSDataReduction, disable=(tab!=1 || IsBlank)
	endif

	SetVariable SubtractFlatBackground,win=USAXSDataReduction, disable=(tab!=1 || IsBlank)
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
	CheckBox CalibrateUseSampleFWHM,win=USAXSDataReduction, disable=(tab!=3 || IsBlank)
	Button RecoverDefaultBlnkVals,win=USAXSDataReduction, disable=(tab!=3 || IsBlank)

	CheckBox DesmearData, win=USAXSDataReduction, disable=(tab!=5)
	SetVariable BckgStartQ, win=USAXSDataReduction, disable=(tab!=5 || !DesmearData)
	PopupMenu BackgroundFnct, win=USAXSDataReduction, disable=(tab!=5 || !DesmearData)

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
	endif
	//color wave in main graph as appropriate
	if(tab==1)
		IN3_ColorMainGraph(1)
	else
		IN3_ColorMainGraph(0)
	endif
	IN3_DisplayDesExtAndError()
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

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
//*********     Live data collection part
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function IN3_OnLineDataProcessing()	
	//create global variables 
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String OldDf=GetDataFolder(1)
	SetDataFOlder root:Packages:Indra3
	NewDataFolder/O/S BckgMonitorParams
	String ListOfVariables, ListOfStrings
	ListOfVariables = "BckgUpdateInterval;BckgDisplayOnly;BckgConvertData;"
	ListOfStrings = "BckgStatus;"
	variable i
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor		
	NVAR BckgUpdateInterval
	if(BckgUpdateInterval<5)
		BckgUpdateInterval=30
	endif

	NVAR BckgDisplayOnly
	NVAR BckgConvertData
	if(BckgConvertData+BckgDisplayOnly!=1)
		BckgDisplayOnly=1
		BckgConvertData=0
	endif
	SVAR BckgStatus
	setDataFolder OldDf
	DoWindow IN3_LiveDataProcessing
	if(V_Flag==0)
		NewPanel /FLT/K=1/W=(573,44,1000,210) as "USAXS Background processing"
		DoWindow/C IN3_LiveDataProcessing
		SetDrawLayer UserBack
		SetDrawEnv fsize= 14,fstyle= 3,textrgb= (0,0,65535)
		DrawText 6,25,"USAXS \"Live\" data proc."
		SetDrawEnv fsize= 10
		DrawText 178,18,"This tool controls background process which"
		SetDrawEnv fsize= 10
		DrawText 178,33,"watches current data folder and when new files(s)"
		SetDrawEnv fsize= 10
		DrawText 178,48,"is found, Converts the data set"
		SetDrawEnv fsize= 10
		DrawText 178,63,"Use sort and Match options to control behavior"
		SetDrawEnv fsize= 10
		DrawText 178,78,"When multiple files are found, arbitrary is selected "
		TitleBox Status pos={5,35},variable=root:Packages:Indra3:BckgMonitorParams:BckgStatus,fColor=(65535,0,0),labelBack=(32792,65535,1)
		TitleBox Status fColor=(0,0,0),labelBack=(65535,65535,65535)
		Button StartBackgrTask,pos={200,100},size={140,23},proc=IN3_BackgrTaskButtonProc,title="Start folder watch"
		Button StartBackgrTask,help={"Start Background task here"}
		Button StopBackgrTask,pos={200,130},size={140,23},proc=IN3_BackgrTaskButtonProc,title="Stop folder watch"
		Button StopBackgrTask,help={"Start Background task here"}
		PopupMenu UpdateTimeSelection pos={10, 74}, title="Update Time [sec] :"
		PopupMenu UpdateTimeSelection proc=IN3_BacgroundUpdatesPopMenuProc
		PopupMenu UpdateTimeSelection value="5;10;15;30;45;60;120;360;600;", mode=WhichListItem(num2str(BckgUpdateInterval),"5;10;15;30;45;60;120;360;600;")+1
		CheckBox BackgroundDisplayOnly pos={10,110},title="Convert and Display only"
		CheckBox BackgroundDisplayOnly proc=IN3_BakcgroundCheckProc
		CheckBox BackgroundDisplayOnly variable=root:Packages:Indra3:BckgMonitorParams:BckgDisplayOnly
		CheckBox BackgroundConvert pos={10,130},title="Convert and Save"
		CheckBox BackgroundConvert proc=IN3_BakcgroundCheckProc
		CheckBox BackgroundConvert variable=root:Packages:Indra3:BckgMonitorParams:BckgConvertData
		SetActiveSubwindow _endfloat_
	endif
	CtrlNamedBackground IN3_MonitorDataFolder, status
	if(NumberByKey("RUN", S_Info))		//running, restart witrh new parameters
		BckgStatus = "   Running background job   "
		TitleBox Status win=IN3_LiveDataProcessing,fColor=(65535,0,0),labelBack=(32792,65535,1)
	else
		BckgStatus = "   Background job not running   "
		TitleBox Status win=IN3_LiveDataProcessing,fColor=(0,0,0),labelBack=(65535,65535,65535)
	endif

end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************



Function IN3_BackgrTaskButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
			// click code here
			if(stringmatch("StartBackgrTask",ba.ctrlName))
				IN3_StartFolderWatchTask()
			endif
			if(stringmatch("StopBackgrTask",ba.ctrlName))
				IN3_StopFolderWatchTask()
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************


Function IN3_StartFolderWatchTask()
	//Variable numTicks = 5 * 60 // Run every two seconds (120 ticks) 
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR BckgUpdateInterval= root:Packages:Indra3:BckgMonitorParams:BckgUpdateInterval
		CtrlNamedBackground IN3_MonitorDataFolder, period=BckgUpdateInterval*60, proc=IN3_MonitorFldrBackground 
		CtrlNamedBackground IN3_MonitorDataFolder, start
		Printf "USAXS FolderWatch background task (\"IN3_MonitorDataFolder\") started with %d [s] update interval\r", BckgUpdateInterval
		SVAR BckgStatus = root:Packages:Indra3:BckgMonitorParams:BckgStatus
		BckgStatus = "   Running background job   "
		TitleBox Status win=IN3_LiveDataProcessing,fColor=(65535,0,0),labelBack=(32792,65535,1)
		Button LiveProcessing win=USAXSDataReduction, fColor=(65535,0,0)
End
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function IN3_StopFolderWatchTask()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
   CtrlNamedBackground IN3_MonitorDataFolder, stop
	Printf "FolderWatch background task (\"IN3_MonitorDataFolder\") stopped\r"
		SVAR BckgStatus = root:Packages:Indra3:BckgMonitorParams:BckgStatus
		BckgStatus = "   Background job not running   "
		TitleBox Status win=IN3_LiveDataProcessing,fColor=(0,0,0),labelBack=(65535,65535,65535)
		Button LiveProcessing win=USAXSDataReduction, fColor=(65535,65535,65535)
End
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************


Function IN3_BacgroundUpdatesPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(stringMatch("UpdateTimeSelection",pa.ctrlName))
				NVAR BckgUpdateInterval= root:Packages:Indra3:BckgMonitorParams:BckgUpdateInterval
				BckgUpdateInterval = str2num(pa.popStr)
				CtrlNamedBackground IN3_MonitorDataFolder, status
				if(NumberByKey("RUN", S_Info))		//running, restart with new parameters
					IN3_StopFolderWatchTask()
					IN3_StartFolderWatchTask()
				endif
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
Function IN3_BakcgroundCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR BckgConvertData=root:Packages:Indra3:BckgMonitorParams:BckgConvertData
			NVAR BckgDisplayOnly=root:Packages:Indra3:BckgMonitorParams:BckgDisplayOnly
			if(stringMatch(cba.CtrlName,"BackgroundDisplayOnly"))
				if(cba.checked)
					BckgDisplayOnly=1
					BckgConvertData=0
				endif
			endif
			if(stringMatch(cba.CtrlName,"BackgroundConvert"))
				if(cba.checked)
					BckgDisplayOnly=0
					BckgConvertData=1
				endif
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function IN3_MonitorFldrBackground(s) // This is the function that will be called periodically 
	STRUCT WMBackgroundStruct &s
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//this should monitor result of Refresh on the folder and grab the new data set and process it.
	Wave/T ListOf2DSampleData=root:Packages:USAXS_FlyScanImport:WaveOfFiles
	Wave ListOf2DSampleDataNumbers=root:Packages:USAXS_FlyScanImport:WaveOfSelections
	NVAR BckgConvertData=root:Packages:Indra3:BckgMonitorParams:BckgConvertData
	NVAR BckgDisplayOnly=root:Packages:Indra3:BckgMonitorParams:BckgDisplayOnly
	//problem, USAXS writes part of the file before end of scan, sop we actually need to display file before last.
	SVAR/Z LiveProcPriorSampleName=root:Packages:Indra3:BckgMonitorParams:LiveProcPriorSampleName
	if(!Svar_Exists(LiveProcPriorSampleName))
		string/g root:Packages:Indra3:BckgMonitorParams:LiveProcPriorSampleName
		SVAR LiveProcPriorSampleName=root:Packages:Indra3:BckgMonitorParams:LiveProcPriorSampleName
		LiveProcPriorSampleName=""
	endif
	string LiveProcPriorSampleNameLoc=LiveProcPriorSampleName
	Duplicate/Free/T ListOf2DSampleData, ListOf2DSampleDataOld 
	//update the lists
	IR3C_UpdateListOfFilesInWvs("USAXSDataReduction")
	IR3C_SortListOfFilesInWvs("USAXSDataReduction")	
	variable NumberOfNewImages

	Printf "%s : task %s called, found %d data images in current folder\r", time(), s.name, numpnts(ListOf2DSampleData)

	if(numpnts(ListOf2DSampleData)>numpnts(ListOf2DSampleDataOld))	//new data set appeared
		NumberOfNewImages=numpnts(ListOf2DSampleData)-numpnts(ListOf2DSampleDataOld)
		//here we need to select the new file. Only when files are not ordered, or it should be clear. 
		Printf "%s : found %g new data image(s), will pick one to display \r", time(), NumberOfNewImages
		Make/Free/T ResWave
		IN2G_FindNewTextElements(ListOf2DSampleData,ListOf2DSampleDataOld,reswave)
		Printf "%s : Found new file %s, but this is likely now being collected \r", time(), reswave[0]
		LiveProcPriorSampleName = reswave[0]
		if(strlen(LiveProcPriorSampleNameLoc)>1)
			Printf "%s : Selected prior existing file %s, calling user routine using this file name \r", time(), LiveProcPriorSampleNameLoc
			//need to find it in the original wave and select it in the control 
			variable i
			For(i=0;i<numpnts(ListOf2DSampleData);i+=1)
				if(stringmatch(ListOf2DSampleData[i],LiveProcPriorSampleNameLoc))
					ListOf2DSampleDataNumbers[i]=1
					break
				endif
			endfor 
			//Printf "%s : found %g new data image(s), since sorting is selected, using the last one \r", time(), NumberOfNewImages
				STRUCT WMButtonAction B_Struct
				B_Struct.ctrlName = "ProcessData2"
				B_Struct.win = "USAXSDataReduction"
				B_Struct.eventcode=2
			if(BckgDisplayOnly || BckgConvertData)
				Print "Calling \"Load/process one\" routine \r"
				IN3_InputPanelButtonProc(B_Struct)
			endif
			if(BckgConvertData)
				Print "Calling \"Save data\" routine \r"
				B_Struct.ctrlName = "SaveResults"
				B_Struct.win = "USAXSDataReduction"
				B_Struct.eventcode=2
				IN3_InputPanelButtonProc(B_Struct)
			endif
			//IN3_PlotProcessedData()		//this is now done automatically by saving the data. 
		endif
	endif
	
   return 0             // Continue background task
End

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function IN3_PlotProcessedData()

	//last data name
	SVAR LastSample = root:Packages:Indra3:LastSample
	NVAR IsBlank = root:Packages:Indra3:IsBlank
	
	//new data should be here:
	if(IsBlank)			//look for 
			Wave/Z Ywave=$(LastSample+"Blank_R_Int")
			Wave/Z Xwave=$(LastSample+"Blank_R_Qvec")
			Wave/Z Ewave=$(LastSample+"Blank_R_error")
	else
			Wave/Z Ywave=$(LastSample+"M_DSM_Int")
			Wave/Z Xwave=$(LastSample+"M_DSM_Qvec")
			Wave/Z Ewave=$(LastSample+"M_DSM_Error")			
			if(!WaveExists(Ywave))
				Wave/Z Ywave=$(LastSample+"DSM_Int")
				Wave/Z Xwave=$(LastSample+"DSM_Qvec")
				Wave/Z Ewave=$(LastSample+"DSM_Error")
				if(!WaveExists(Ywave))
					Wave/Z Ywave=$(LastSample+"M_SMR_Int")
					Wave/Z Xwave=$(LastSample+"M_SMR_Qvec")
					Wave/Z Ewave=$(LastSample+"M_SMR_Error")
					if(!WaveExists(Ywave))
						Wave/Z Ywave=$(LastSample+"SMR_Int")
						Wave/Z Xwave=$(LastSample+"SMR_Qvec")
						Wave/Z Ewave=$(LastSample+"SMR_Error")
					endif
				endif
			endif
	endif
	if(WaveExists(Ywave)&&WaveExists(Xwave)&&(!IsBlank))
		DoWIndow/Z USAXSProcessedDataGraph
		if(V_Flag==0)
			Display /K=1/W=(500,300,500+0.5*IN2G_GetGraphWidthHeight("width"),300+0.5*IN2G_GetGraphWidthHeight("height")) Ywave vs Xwave as "USAXS Processed data"
			DoWindow/C USAXSProcessedDataGraph
			ModifyGraph mode=3
			ModifyGraph log=1
			ModifyGraph mirror=1
			Label left "Intensity"
			Label bottom "Q [A\\S-1\\M]"
			SetAxis bottom 1e-4,*
		elseif(V_Flag>0)
			DoWIndow/F USAXSProcessedDataGraph
			CheckDisplayed /W=USAXSProcessedDataGraph $(NameOfWave(Ywave))
			if(!V_Flag)
				AppendToGraph Ywave vs Xwave
				ModifyGraph mode=3
			endif
		endif
		IN2G_ColorTopGrphRainbow()
		//IN2G_ColorTraces( )
		IN2G_LegendTopGrphFldr(10,12,1,0)
		//	IN2G_GenerateLegendForGraph(10,0,1)
		DoUpdate /W=USAXSProcessedDataGraph
	endif
	
end


//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function IN3_DesmearData()
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Indra3:
	NVAR DesmearData = root:Packages:Indra3:DesmearData
	NVAR IsBlank = root:Packages:Indra3:IsBlank
	if(DesmearData && !IsBlank)
		NVAR SlitLength = root:Packages:Indra3:SlitLength
		NVAR DesmearNumberOfInterations=root:Packages:Indra3:DesmearNumberOfInterations
		WAVE/Z SMR_Int = root:Packages:Indra3:SMR_Int
		if(!WaveExists(SMR_Int))		//wave does n to exist, stop here... 	
			setDataFolder fldrSav0
			return 0
		endif
		WAVE SMR_Error = root:Packages:Indra3:SMR_Error
		WAVE SMR_Qvec = root:Packages:Indra3:SMR_Qvec
		WAVE SMR_dQ = root:Packages:Indra3:SMR_dQ
		Killwaves/Z DSM_Int, DSM_Qvec, DSM_Error, DSM_dQ
		Duplicate/Free SMR_Int, tmpWork_Int
		Duplicate/Free SMR_Error, tmpWork_Error
		Duplicate/Free SMR_Qvec, tmpWork_Qvec
		Duplicate/Free SMR_dQ, tmpWork_dQ

		Duplicate/O SMR_Int, DesmNormalizedError
		Duplicate/Free SMR_Int, absNormalizedError

//		IN2G_ReplaceNegValsByNaNWaves(tmpSMR_Int,tmpSMR_Qvec,tmpSMR_Error)			//here we remove negative values by setting them to NaNs
//		IN2G_RemoveNaNsFrom4Waves(tmpSMR_Int,tmpSMR_Qvec,tmpSMR_Error,tmpSMR_dQ)			//and here we remove NaNs all together
		variable numOfPoints = numpnts(SMR_Int)
		variable endme=0, oldendme = 0, DesmearAutoTargChisq, difff
		DesmearAutoTargChisq = 0.5
		variable ExtensionFailed
		variable NumIterations=0
		Do
			ExtensionFailed = IN3_OneDesmearIteration(tmpWork_Int,tmpWork_Qvec,tmpWork_Error, SMR_Int, SMR_Error, DesmNormalizedError)
			if(ExtensionFailed)
				setDataFolder fldrSav0
				return 0
			endif
			absNormalizedError=abs(DesmNormalizedError) 
			Duplicate/Free/O absNormalizedError, tmpabsNormalizedError
			IN2G_RemNaNsFromAWave(tmpabsNormalizedError)
			endme = sum(tmpabsNormalizedError)/numpnts(absNormalizedError)
			difff=1 - oldendme/endme
			oldendme=endme
			NumIterations+=1
		while (endme>DesmearAutoTargChisq && abs(difff)>0.01 && NumIterations<50)	

		Duplicate/O tmpWork_Int, DSM_Int
		Duplicate/O tmpWork_Qvec, DSM_Qvec
		Duplicate/O tmpWork_Error, DSM_Error
		Duplicate/O tmpWork_dQ, DSM_dQ
		
		
		DoWindow RcurvePlotGraph
		if(V_Flag)
			CheckDisplayed /W=RcurvePlotGraph DSM_Int 
				if(V_Flag<1)
					AppendToGraph/R/W=RcurvePlotGraph DSM_Int vs DSM_Qvec
				endif
			ModifyGraph/W=RcurvePlotGraph mode(DSM_Int)=3,rgb(DSM_Int)=(1,39321,19939)		
			ModifyGraph/W=RcurvePlotGraph mode(DSM_Int)=4
			//Label/W=RcurvePlotGraph right "DSM & SMR Intensity"	
			Label/W=RcurvePlotGraph right "\\K(3,52428,1)DSM & \\K(1,16019,65535)SMR \\K(0,0,0)Intensity"
			DoUpdate /W=RcurvePlotGraph
			IN3_DisplayDesExtAndError()
		endif
	else		//remove desmeared data if present
		DoWindow RcurvePlotGraph
		if(V_Flag)
			CheckDisplayed /W=RcurvePlotGraph  DSM_Int 
			if(V_Flag)
				removefromgraph /W=RcurvePlotGraph/Z DSM_Int 
				removefromgraph /W=RcurvePlotGraph/Z fit_ExtrapIntWave 
				removefromgraph /W=RcurvePlotGraph/Z DesmNormalizedError 
				Label/W=RcurvePlotGraph right "\\K(0,0,0)SMR Intensity"	
				DoUpdate /W=RcurvePlotGraph
			endif	
		endif
		WAVE/Z DSM_Int = root:Packages:Indra3:DSM_Int
		WAVE/Z DSM_Error = root:Packages:Indra3:DSM_Error
		WAVE/Z DSM_Qvec = root:Packages:Indra3:DSM_Qvec
		WAVE/Z DSM_dQ = root:Packages:Indra3:DSM_dQ
		Wave/Z fit_ExtrapIntwave = root:Packages:Indra3:fit_ExtrapIntwave
		Wave/Z DesmNormalizedError = root:Packages:Indra3:DesmNormalizedError
		KillWaves/Z DSM_Int, DSM_Qvec, DSM_Error, DSM_dQ, fit_ExtrapIntwave, DesmNormalizedError
		
	endif
	setDataFolder fldrSav0
	
end


//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN3_OneDesmearIteration(DesmearIntWave,DesmearQWave,DesmearEWave, origSmearedInt, origSmearedErr, NormalizedError)
	Wave DesmearIntWave, DesmearQWave, DesmearEWave, origSmearedInt, origSmearedErr, NormalizedError
		
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3:

	SVAR BackgroundFunction    = root:Packages:Indra3:DsmBackgroundFunction
	NVAR SlitLength 			= 	root:Packages:Indra3:SlitLength
	NVAR NumberOfIterations	=	root:Packages:Indra3:DesmearNumberOfInterations
	NVAR numOfPoints               = root:Packages:Indra3:DesmearNumPoints
	NVAR BckgStartQ                 = root:Packages:Indra3:DesmearBckgStart
	numOfPoints = numpnts(DesmearIntWave)
	if(BckgStartQ>DesmearQWave[numOfPoints-1]/1.5)
		BckgStartQ = DesmearQWave[numOfPoints-1]/1.5
	endif
	Duplicate/Free DesmearIntWave, SmFitIntensity
	Duplicate/Free origSmearedInt, OrigIntToSmear
	Duplicate/Free origSmearedErr, SmErrors
	variable ExtensionFailed=0
	
	ExtensionFailed = IN3_ExtendData(DesmearIntWave, DesmearQWave, SmErrors, slitLength, BckgStartQ, BackgroundFunction) 			//extend data to 2xnumOfPoints to Qmax+2.1xSlitLength
	if(ExtensionFailed)
		return 1
	endif
	if(slitlength>0)
		IN3_SmearData(DesmearIntWave, DesmearQWave, slitLength, SmFitIntensity)						//smear the data, output is SmFitIntensity
	endif
	Redimension/N=(numOfPoints) SmFitIntensity, DesmearIntWave, DesmearQWave, NormalizedError		//cut the data back to original length (Qmax, numOfPoints)
	
	NormalizedError=(origSmearedInt-SmFitIntensity)/SmErrors			//NormalizedError (input-my Smeared data)/input errors
	duplicate/O/Free DesmearIntWave, FastFitIntensity, SlowFitIntensity
	//fast convergence
	FastFitIntensity=DesmearIntWave*(OrigIntToSmear/SmFitIntensity)								
	//slow convergence
	SlowFitIntensity=DesmearIntWave+(OrigIntToSmear-SmFitIntensity)								
	
	variable i
//	if(DesmearFastOnly)
//		DesmearedIntWave = FastFitIntensity
//	elseif(DesmearSlowOnly)
//		DesmearedIntWave = SlowFitIntensity
//	elseif(DesmearDampen)
		For(i=0;i<(numpnts(DesmearIntWave));i+=1)
			if (abs(NormalizedError[i])>0.5)
				DesmearIntWave[i]=FastFitIntensity[i]
			else
				DesmearIntWave[i]=DesmearIntWave[i]
			endif	
		endfor
//	else
//		For(i=0;i<(numpnts(FitIntensity));i+=1)
//			if (abs(NormalizedError[i])>DesmearSwitchOverVal)
//				DesmearedIntWave[i]=FastFitIntensity[i]
//			else
//				DesmearedIntWave[i]=SlowFitIntensity[i]
//			endif	
//		endfor
//	endif	
	NumberOfIterations+=1
	//remove the normalized error extremes
	wavestats/Q NormalizedError
	NormalizedError[x2pnt(NormalizedError,V_minLoc)] = Nan
	NormalizedError[x2pnt(NormalizedError,V_maxLoc)] = Nan
	//Duplicate/O DesmearIntWave, DesmearEWave
	DesmearEWave=0
	IN3_GetErrors(origSmearedErr, origSmearedInt, DesmearIntWave, DesmearEWave, DesmearQWave)			//this routine gets the errors
	setDataFolder OldDf
	return 0
End

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*************************************Extends the data using user specified parameters***************
Function IN3_ExtendData(Int_wave, Q_vct, Err_wave, slitLength, Qstart, SelectedFunction) 
	wave Int_wave, Q_vct, Err_wave
	variable slitLength, Qstart		//RecordFitParam=1 when we should record fit parameters in logbook
	string SelectedFunction
	
	if (numtype(slitLength)!=0)
		abort "Slit length error"
	endif
	if (slitLength<0.0001 || slitLength>1)
		DoALert 0, "Weird value for Slit length, please check"
	endif
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

//	WAVE/Z ColorWave=root:Packages:Irena_desmearing:ColorWave
//	if(!WaveExists(ColorWave))
//		Duplicate/O Int_Wave, ColorWave
//	endif
	WAVE/Z W_coef=W_coef
		if (WaveExists(W_coef)!=1)					
			make/N=2 W_coef
		endif
	W_coef=0		//reset for recording purposes...
	
	string ProblemsWithQ=""
	string ProblemWithFit=""
	string ProblemsWithInt=""
	variable DataLengths=numpnts(Q_vct)-1							//get number of original data points
	variable Qstep=((Q_vct(DataLengths)/Q_vct(DataLengths-1))-1)*Q_vct(DataLengths)
	variable ExtendByQ=sqrt(Q_vct(DataLengths)^2 + (1.5*slitLength)^2) - Q_vct(DataLengths)
	if (ExtendByQ<2.1*Qstep)
		ExtendByQ=2.1*Qstep
	endif
	variable NumNewPoints=floor(ExtendByQ/Qstep)	
	if (NumNewPoints<1)
		NumNewPoints=1
	endif	
	variable OriginalNumPnts=numpnts(Int_wave)
	if (NumNewPoints>OriginalNumPnts)
		NumNewPoints=OriginalNumPnts
	endif	
	variable newLength=numpnts(Q_vct)+NumNewPoints				//New length of waves
	variable FitFrom=binarySearch(Q_vct, Qstart)					//get at which point of Q start fitting for extension
	if (FitFrom<=0)		                 								//error in selection of Q fitting range
		FitFrom=DataLengths-10
		ProblemsWithQ="I did reset Fitting Q range for you..."
	endif
	//There seems to be bug, which prevents me from using /D in FuncFit and cursor control
	//therefore we will have to now handle this ourselves...
	//FIrst check if the wave exists
	Wave/Z fit_ExtrapIntwave
	if (!WaveExists(fit_ExtrapIntwave))
		Make/O/N=300 fit_ExtrapIntwave
	endif
	//Now we need to set it's x scaling to the range of Q values we need to study
	SetScale/I x Q_vct[FitFrom],Q_vct[DataLengths-1],"", fit_ExtrapIntwave
	//reset the fit wave to constant value
	fit_ExtrapIntwave=Int_wave[DataLengths-1]
		
	Redimension /N=(newLength) Int_wave, Q_vct, Err_wave			//increase length of the two waves
	
//	if(exists("ColorWave")==1)
//		Redimension /N=(newLength) ColorWave
//		ColorWave=0
//		ColorWave[FitFrom,DataLengths-1]=1
//		ColorWave[DataLengths+1, ]=2	
//	endif
//	
	variable i=0, ii=0	
	variable/g V_FitError=0					//this is way to avoid bombing due to numerical problems
	variable/g V_FitOptions=4				//this should suppress the window showing progress (4) & force robust fitting (6)
										//using robust fitting caused problems, do not use...
//	variable/g V_FitTol=0.00001				//and this should force better fit
	variable/g V_FitMaxIters=50
//	variable/g V_FitNumIters
	
//	DoWindow CheckTheBackgroundExtns
//	if (V_flag)
//		RemoveFromGraph /W=CheckTheBackgroundExtns /Z Fit_ExtrapIntwave
//	endif
	//***********here start different ways to extend the data

	if (cmpstr(SelectedFunction,"flat")==0)				//flat background, for some reason only way this works is 
	//lets setup parameters for FuncFit
		if (exists("W_coef")!=1)					//using my own function to fit. Crazy!!
			make/N=2 W_coef
		endif
		Redimension/D/N=1 W_coef
		Make/O/N=1 E_wave
		E_wave[0]=1e-6
		W_coef[0]=Int_wave[((FitFrom+DataLengths)/2)]			//here is starting guesses
		K0=W_coef[0]										//another way to get starting guess in
	 	V_FitError=0											//this is way to avoid bombing due to numerical problems
		//now lets do the fitting
		FuncFit/N/Q IN3_FlatFnct W_coef Int_wave [FitFrom, DataLengths-1] /I=1 /W=Err_Wave /E=E_Wave /X=Q_vct	//Here we get the fit to the Int_wave in
		//now check for the convergence
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Linear fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]								//extend Int
			EndFor
			fit_ExtrapIntwave=W_coef[0]
		endif
	endif


	if (cmpstr(SelectedFunction,"power law")==0)			//power law background
	 	V_FitError=0					//this is way to avoid bombing due to numerical problems
		//now lets do the fitting	
		K0 = 0
		CurveFit/N/Q/H="100" Power Int_wave[FitFrom, DataLengths-1] /X=Q_vct /W=Err_Wave /I=1 
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Power law fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]+W_coef[1]*(Q_vct[DataLengths+i])^W_coef[2]			//extend Int
			endfor
			fit_ExtrapIntwave=W_coef[0]+W_coef[1]*(x)^W_coef[2]
		endif
	endif


	if (cmpstr(SelectedFunction,"Porod")==0)				//Porod background
		if (exists("W_coef")!=1)
			make/N=2 W_coef
		endif
		Redimension/D/N=2 W_coef
		variable estimate1_w0=Int_wave[(DataLengths-1)]
		variable estimate1_w1=Q_vct[(FitFrom)]^4*Int_wave[(FitFrom)]
		W_coef={estimate1_w0,estimate1_w1}							//here are starting guesses, may need to be fixed.
		K0=estimate1_w0
		K1=estimate1_w1
	 	V_FitError=0					//this is way to avoid bombing due to numerical problems
		//now lets do the fitting	
		Make/O/T CTextWave={"K0 > "+num2str(estimate1_w0/100)}
		FuncFit/N/Q IN3_Porod W_coef Int_wave [FitFrom, DataLengths-1] /I=1 /C=CTextWave/W=Err_Wave /X=Q_vct			//Porod function here
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Porod fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]=W_coef[0]+W_coef[1]/(Q_vct[DataLengths+i])^4		//extend Int
			endfor
			fit_ExtrapIntwave=W_coef[0]+W_coef[1]/(x)^4
		endif
	endif


	if (cmpstr(SelectedFunction,"PowerLaw w flat")==0)				//fit polynom 3rd degree
		if (exists("W_coef")!=1)
			make/N=3 W_coef
		endif
	//	variable estimate1_w0=Int_wave[(DataLengths-1)]
	//	variable estimate1_w1=Q_vct[(FitFrom)]^4*Int_wave[(FitFrom)]
		K0=Int_wave[(DataLengths-1)]
		K1=(Int_wave[(FitFrom)] - K0) * (Q_vct[(FitFrom)]^3)
		K2=-3
		W_coef={K0,K1, K2}							//here are starting guesses, may need to be fixed.

		Make/O/T CTextWave={"K1 > 0","K2 < 0","K0 > 0", "K2 > -6"}
		Redimension/D/N=3 W_coef
	 	V_FitError=0					//this is way to avoid bombing due to numerical problems
			Curvefit/N/G/Q power Int_wave [FitFrom, DataLengths-1] /I=1 /C=CTextWave/X=Q_vct /W=Err_Wave		
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Power Law with flat fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]+W_coef[1]*(Q_vct[DataLengths+i]^W_coef[2])
			endfor
			fit_ExtrapIntwave=W_coef[0]+W_coef[1]*(x^W_coef[2])
			endif
		endif

//		wavestats/Q/R=[DataLengths+1,] Int_wave
//	//	print DataLengths
//		if (V_min<0)
//			ProblemsWithInt="Extrapolated Intensity <0, select different function" 
//		endif
	variable ExtensionFailed=0
	string ErrorMessages=""
	if (strlen(ProblemsWithQ)!=0)
		ErrorMessages=ProblemsWithQ+"\r"
	endif
	if (strlen(ProblemsWithInt)!=0)
		ErrorMessages=ProblemsWithInt+"\r"
	endif
	if (strlen(ProblemWithFit)!=0)
		ErrorMessages+=ProblemWithFit
	endif
	if (strlen(ErrorMessages)!=0)
		ExtensionFailed=1
		DoAlert /T="Desmearing failed" 0, ErrorMessages 
	endif
	setDataFolder OldDf
	return ExtensionFailed
end 

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*****************************This function smears data***********************
Function IN3_SmearData(Int_to_smear, Q_vec_sm, slitLength, Smeared_int)
	wave Int_to_smear, Q_vec_sm, Smeared_int
	variable slitLength
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	variable oldNumPnts=numpnts(Q_vec_sm)
	//modified 2/28/2017 - with Fly scans and merged data having lot more points, this is getting to be slow. Keep max number of new points to 300
	variable newNumPoints
	if(oldNumPnts<300)
		newNumPoints = 2*oldNumPnts
	else
		newNumPoints = oldNumPnts+300
	endif
	Duplicate/O/Free Int_to_smear, tempInt_to_smear
	Redimension /N=(newNumPoints) tempInt_to_smear		//increase the points here.
	Duplicate/O/Free Q_vec_sm, tempQ_vec_sm
	Redimension/N=(newNumPoints) tempQ_vec_sm
	tempQ_vec_sm[oldNumPnts, ] =tempQ_vec_sm[oldNumPnts-1] +20* tempQ_vec_sm[p-oldNumPnts]			//creates extension of number of points up to 20*original length
	tempInt_to_smear[oldNumPnts, ]  = tempInt_to_smear[oldNumPnts-1] * (1-(tempQ_vec_sm[p]  - tempQ_vec_sm[oldNumPnts])/(20*tempQ_vec_sm[oldNumPnts-1]))//extend the data by simple fixed value... 
	
	Make/D/Free/N=(oldNumPnts) Smear_Q, Smear_Int							
	//Q's in L spacing and intensitites in the l's will go to Smear_Int (intensity distribution in the slit, changes for each point)

	variable DataLengths=numpnts(Q_vec_sm)

	Smear_Q=2*slitLength*(Q_vec_sm[p]-Q_vec_sm[0])/(Q_vec_sm[DataLengths-1]-Q_vec_sm[0])		//create distribution of points in the l's which mimics the original distribution of points
	//the 2* added later, because without it I did not  cover the whole slit length range... 
	variable i=0
	DataLengths=numpnts(Smeared_int)
	MatrixOp/FREE Q_vec_sm2=powR(Q_vec_sm,2)
	MatrixOp/FREE Smear_Q2=powR(Smear_Q,2)
	MultiThread Smeared_int = IN3_SmearDataFastFunc(Q_vec_sm2[p], Smear_Q,Smear_Q2, tempQ_vec_sm, tempInt_to_smear, SlitLength)

	Smeared_int*= 1 / slitLength															//normalize
	
	setDataFolder OldDf
end
//***********************************************************************************************************************************//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN3_FlatFnct(w,x) : FitFunc
	wave w
	variable x
	
	return w[0]
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN3_Porod(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = c1+c2*(x^(-4))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = c1
	//CurveFitDialog/ w[1] = c2

	return w[0]+w[1]*(x^(-4))
End
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Threadsafe function IN3_SmearDataFastFunc(Q_vec_sm2, Smear_Q,Smear_Q2, tempQ_vec_sm, tempInt_to_smear, SlitLength)
			variable Q_vec_sm2, SlitLength
			wave Smear_Q, Smear_Q2, tempQ_vec_sm, tempInt_to_smear	
			Duplicate/Free Smear_Q, Smear_Int
			//Smear_Int=interp(sqrt( Q_vec_sm2 +(Smear_Q2[p])), tempQ_vec_sm, tempInt_to_smear)		//put the distribution of intensities in the slit for each point 
			//this is using Interpolate2, seems slightly faster than above line alone... 
			Duplicate/Free Smear_Q, InterSmear_Q
			InterSmear_Q = sqrt( Q_vec_sm2 +(Smear_Q2[p]))
			//surprisingly, below code is tiny bit slower that the two lines above... 
			//MatrixOp/FREE InterSmear_Q=sqrt(Smear_Q2 + Q_vec_sm2)	
			Interpolate2/I=3/T=1/X=InterSmear_Q /Y=Smear_Int tempQ_vec_sm, tempInt_to_smear
			return areaXY(Smear_Q, Smear_Int, 0, slitLength) 							//integrate the intensity over the slit 
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IN3_GetErrors(SmErrors, SmIntensity, FitIntensity, DsmErrors, Qvector)		//calculates errors using Petes formulas
	wave SmErrors, SmIntensity, FitIntensity, DsmErrors, Qvector
	
	Silent 1	
	
	DsmErrors=FitIntensity*(SmErrors/SmIntensity)						//error proportional to input data
	WAVE W_coef=W_coef
	variable i=1, imax=numpnts(FitIntensity)
	Redimension/N=(numpnts(FitIntensity)) DsmErrors
	Do
		if( (numtype(FitIntensity[i-1])==0) && (numtype(FitIntensity[i])==0) && (numtype(FitIntensity[i+1])==0) )
			CurveFit/Q line, FitIntensity (i-1, i+1) /X=Qvector				//linear function here 
			DsmErrors[i]+=abs(W_coef[0]+W_coef[1]*Qvector[i] - FitIntensity[i])	//error due to scatter of data
		endif
	i+=1
	while (i<imax-1)

	DsmErrors[0]=DsmErrors[1]									//some error needed for 1st point
	DsmErrors[imax-1]=DsmErrors[imax-2]								//and error for last point	

	Smooth /E=2 3, DsmErrors
	
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN3_DisplayDesExtAndError()
		
		DoWindow RcurvePlotGraph
		if(V_Flag)
			ControlInfo /W=USAXSDataReduction DataTabs
			if(V_Value==5)
				Wave/Z fit_ExtrapIntwave = root:Packages:Indra3:fit_ExtrapIntwave
				if(WaveExists(fit_ExtrapIntwave))
					CheckDisplayed /W=RcurvePlotGraph fit_ExtrapIntwave 
					if(V_Flag<1)
						AppendToGraph/R/W=RcurvePlotGraph fit_ExtrapIntwave	
						ModifyGraph /W=RcurvePlotGraph mode(fit_ExtrapIntwave)=0,lstyle(fit_ExtrapIntwave)=3,rgb(fit_ExtrapIntwave)=(65535,0,0)
						ModifyGraph /W=RcurvePlotGraph lsize(fit_ExtrapIntwave)=4
					endif
				endif	
				Wave/Z DesmNormalizedError = root:Packages:Indra3:DesmNormalizedError
				Wave/Z DSM_Qvec=root:Packages:Indra3:DSM_Qvec
				if(WaveExists(DesmNormalizedError)&&WaveExists(DSM_Qvec))
					CheckDisplayed /W=RcurvePlotGraph DesmNormalizedError 
					if(V_Flag<1)
						AppendToGraph/L=VertCrossing/W=RcurvePlotGraph DesmNormalizedError vs DSM_Qvec
						ModifyGraph/W=RcurvePlotGraph mode(DesmNormalizedError)=2,rgb(DesmNormalizedError)=(0,0,0)
						SetAxis/A/E=2/W=RcurvePlotGraph VertCrossing
						ModifyGraph/W=RcurvePlotGraph lblPos(VertCrossing)=45
						Label/W=RcurvePlotGraph VertCrossing "Normalized residual"
					endif
				endif	
			else
				Wave/Z DSM_Int
				CheckDisplayed /W=RcurvePlotGraph DSM_Int 
					if(V_Flag)
						ModifyGraph/W=RcurvePlotGraph mode(DSM_Int)=3,rgb(DSM_Int)=(1,39321,19939)		
						ModifyGraph/W=RcurvePlotGraph mode(DSM_Int)=4
						//Label/W=RcurvePlotGraph right "DSM & SMR Intensity"	
						Label/W=RcurvePlotGraph right "\\K(3,52428,1)DSM & \\K(1,16019,65535)SMR \\K(0,0,0)Intensity"
					else
					
					endif
				RemoveFromGraph /W=RcurvePlotGraph/Z fit_ExtrapIntwave
				RemoveFromGraph /W=RcurvePlotGraph/Z DesmNormalizedError
			endif
		endif
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
