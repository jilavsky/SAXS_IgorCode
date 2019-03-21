#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3			// Use modern global access method.
//#pragma rtGlobals=1		// Use modern global access method.
#pragma version =1.13


//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.13 minor fix for MSAXS correction graphing. 
//1.12 fixed problem when PD_range used to create MyCOlorWave was getting out of sync with data as points were being removed. Flyscan only, added PD_RangeModified to fix this... 
//1.11 modfiied IN3_RecalcSubtractSaAndBlank to avoid negative data.
//1.10  removed unused functions
//1.09 change in code, do not remove negative values for R_Int, causes problems in some cases. 
//1.08 fixed typo with DSM data dq. 
//1.07 fixed problems with blank interpolation when intensities are really low and get negative. 
//1.06 added SMR_dQ types waves  
//1.05 modfied IN3_RecalcSubtractSaAndBlank to handle 2dFlyscans... 
//1.04 modified to use rebinning routine from General procedures (requires General procedures version 1.71 and higher
//1.03 fixed error calculations to include transmission, needed for highly scattering but highly absorbing samples, for which errors were unrealistically large. 
//1.01 modified for weight calibration
//1.02 added pinDiode tranmsission

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//Function IN3_Template()
//	string oldDf=GetDataFolder(1)
//	setDataFolder root:Packages:Indra3
//
//	setDataFolder OldDf	
//end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN3_ColorMainGraph(PdRanges)
	variable PdRanges

	DoWIndow RcurvePlotGraph
	if(V_Flag)		//exists, other studff shoudl exist also...
		SVAR DataFolderName=root:Packages:Indra3:DataFolderName
		Wave/Z PD_range=$(DataFolderName+"PD_RangeModified")
		if(!WaveExists(PD_range))
			Wave/Z PD_range=$(DataFolderName+"PD_Range")
		endif
		//set PdRanges to 1 to have colored main data in correct colors., 0 to uncolor
		if(WaveExists(PD_range)&&V_Flag)
			if(PdRanges)
				Duplicate/O PD_range, root:Packages:Indra3:MyColorWave							//creates new color wave
				IN2G_MakeMyColors(PD_range,root:Packages:Indra3:MyColorWave)						//creates colors in it
		 		ModifyGraph /W=RcurvePlotGraph/Z mode=0, zColor(R_Int)={root:Packages:Indra3:MyColorWave,0,10,Rainbow}
			else
		 		ModifyGraph /W=RcurvePlotGraph/Z  mode=0, zColor(R_Int)=0
			endif
		endif
	endif
end 
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//Function IN3_CorrectQandTransmission()
//	string oldDf=GetDataFolder(1)
//	setDataFolder root:Packages:Indra3
//
//	Wave R_Int
//	Wave R_Qvec
//	NVAR IsBlank=root:Packages:Indra3:IsBlank
//
//	Duplicate/O R_Int, R_Int_corr
//	Duplicate/O R_Qvec, R_Qvec_shifted
//		IN2G_AppendorReplaceWaveNote("R_Int_Corr","Wname","R_Int_corr") 
//		IN2G_AppendorReplaceWaveNote("R_Qvec_shifted","Wname","R_Qvec_shifted") 
//	NVAR SampleQOffset 
//	NVAR SampleTransmissionPeakToPeak
//
//  	R_Int_corr =R_Int
////  	R_Int_corr =R_Int/SampleTransmissionPeakToPeak
//  	R_Qvec_shifted=R_Qvec//-SampleQOffset
//
//	setDataFolder OldDf	
//end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN3_CalculateTransmission(SkipEstimate)
	variable SkipEstimate
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	NVAR IsBlank = root:Packages:Indra3:IsBlank

	NVAR SampleTransmissionPeakToPeak = root:Packages:Indra3:SampleTransmissionPeakToPeak
	NVAR BlankMaximum=root:Packages:Indra3:BlankMaximum
	NVAR MaximumIntensity=root:Packages:Indra3:MaximumIntensity
	NVAR SampleTransmission=root:Packages:Indra3:SampleTransmission
	NVAR MSAXSCorrection=root:Packages:Indra3:MSAXSCorrection
	NVAR UseMSAXSCorrection=root:Packages:Indra3:UseMSAXSCorrection
	NVAR UsePinTransmission=root:Packages:Indra3:UsePinTransmission
	SVAR FolderName = root:Packages:Indra3:DataFolderName
	if (!DataFolderExists(FolderName ))
		return 0
	endif
	if(isBlank)
		SampleTransmissionPeakToPeak=1
	else
		if(!SkipEstimate)
			SampleTransmissionPeakToPeak = MaximumIntensity/BlankMaximum
		endif
		SampleTransmission = SampleTransmissionPeakToPeak
		if(UseMSAXSCorrection||UsePinTransmission)
			SampleTransmission*=MSAXSCorrection
		endif
	endif	
	setDataFolder FolderName
	variable/g Transmission 
	Transmission = SampleTransmission
	setDataFolder OldDf	
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//
//Function IN3_ReCalculateTransmission()
//	string oldDf=GetDataFolder(1)
//	setDataFolder root:Packages:Indra3
//
//	NVAR SampleTransmissionPeakToPeak = root:Packages:Indra3:SampleTransmissionPeakToPeak
//	NVAR BlankMaximum=root:Packages:Indra3:BlankMaximum
//	NVAR MaximumIntensity=root:Packages:Indra3:MaximumIntensity
//	NVAR SampleTransmission=root:Packages:Indra3:SampleTransmission
//	NVAR MSAXSCorrection=root:Packages:Indra3:MSAXSCorrection
//	NVAR UseMSAXSCorrection=root:Packages:Indra3:UseMSAXSCorrection
//	//SampleTransmissionPeakToPeak = MaximumIntensity/BlankMaximum
//	SampleTransmission = SampleTransmissionPeakToPeak
//	if(UseMSAXSCorrection)
//		SampleTransmission*=MSAXSCorrection
//	endif
//	
//	setDataFolder OldDf	
//end
//
//
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IN3_CalculateRdata()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	NVAR SampleTransmissionPeakToPeak = root:Packages:Indra3:SampleTransmissionPeakToPeak
	Wave PD_Intensity
	Wave PD_Error
	Wave Qvec

	Duplicate/O PD_Intensity, R_Int
	Duplicate/O PD_Error, R_Error
	Duplicate/O Qvec, R_Qvec
	
	if(SampleTransmissionPeakToPeak<=0)
		SampleTransmissionPeakToPeak=1
	endif
	R_Int = PD_Intensity /SampleTransmissionPeakToPeak
	R_Error = PD_Error /SampleTransmissionPeakToPeak

	IN3_SmoothRData()

	setDataFolder OldDf	
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN3_CalculateCalibration()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	SVAR ASBParameters=ListOfASBParameters
	SVAR UPDParameters=UPDParameters

	NVAR CalibrateToWeight 	=	root:Packages:Indra3:CalibrateToWeight
	NVAR CalibrateToVolume 	=	root:Packages:Indra3:CalibrateToVolume
	NVAR CalibrateArbitrary 	=	root:Packages:Indra3:CalibrateArbitrary
	NVAR SampleWeightInBeam 	=	root:Packages:Indra3:SampleWeightInBeam
	NVAR SampleDensity 		=	root:Packages:Indra3:SampleDensity
	NVAR SampleWeightInBeam 	=	root:Packages:Indra3:SampleWeightInBeam
	NVAR BeamExposureArea		=	root:Packages:Indra3:BeamExposureArea
	NVAR SamplePeakWidth 		=	root:Packages:Indra3:PeakWidth
	NVAR BLPeakWidth			=	root:Packages:Indra3:BlankFWHM
	NVAR BLPeakMax				=	root:Packages:Indra3:BlankMaximum
	NVAR SampleThickness		=	root:Packages:Indra3:SampleThickness
	NVAR CalibrateUseSampleFWHM = root:Packages:Indra3:CalibrateUseSampleFWHM
	string Calibrated			=	StringByKey("Calibrate", ASBParameters,"=",";")
	NVAR PhotoDiodeSize		=	root:Packages:Indra3:PhotoDiodeSize															//Default PD size to 5.5mm at this time....
	SVAR/Z MeasurementParameters
	if(!SVAR_Exists(MeasurementParameters))
		abort
	endif
	variable SampleToDetectorDistance=numberByKey("SDDistance",MeasurementParameters,"=")		//need to get it
	Variable OmegaFactor,ASStageWidthAtHalfMax
	NVAR Kfactor
	variable BLPeakWidthL
	//Decide if to use sample peak witdth or Blank peak width - added JIL 2018-11-08 to fix variability of the Blank FWHM... 
	//this is NOT fix, its workaround... 
	if(CalibrateUseSampleFWHM) 			//user wants to use that... 
		if(SamplePeakWidth/BLPeakWidth < CalMaxRatioUseSamFWHM)			//assume CalMaxRatioUseSamFWHM describes when MSAXS needs to be accounted for...
			print "Using Sample FWHM for absolute instensity calibration. Can be changed in \"Calibration\" tab"
			BLPeakWidthL = SamplePeakWidth
		else
			BLPeakWidthL = BLPeakWidth
			print "Using Blank FWHM for absolute instensity calibration; While SampleFWHM was requested in \"Calibration\" tab, the width of sample is too high, suggesting MSAXS."
		endif
	else
		BLPeakWidthL = BLPeakWidth
	endif
	BLPeakWidthL=BLPeakWidthL*3600													//W_coef[3]*3600*2
	
	PhotoDiodeSize=NumberByKey("UPDsize", UPDParameters,"=")																//Default PD size to 5.5mm at this time....
	if(numtype(PhotoDiodeSize)!=0|| PhotoDiodeSize<=1)
		PhotoDiodeSize = 5.5
	endif

	if (cmpstr(StringByKey("Calibrate", ASBParameters,"=",";"),"USAXS")==0)		//USAXS callibration, width given by SDD and PD size
		OmegaFactor= (PhotoDiodeSize/SampleToDetectorDistance)*(BLPeakWidthL/3600)*(pi/180)
		Kfactor=BLPeakMax*OmegaFactor 				// *SampleThickness*0.1  ; 0.1 converts the thickness of sample from mm to cm
	endif

	if (cmpstr(StringByKey("Calibrate", ASBParameters,"=",";"),"SBUSAXS")==0)	//SBUSAXS callibration, width given by rocking curve width
		ASStageWidthAtHalfMax=BLPeakWidthL
		OmegaFactor=(ASStageWidthAtHalfMax/3600)*(pi/180)*(BLPeakWidthL/3600)*(pi/180)	//Is this correct callibration for SBUSAXS?????
		Kfactor=BLPeakMax*OmegaFactor				//*SampleThickness*0.1   ; 0.1 converts the thickness of sample from mm to cm
		IN2G_AppendAnyText("AS stage width :\t"+num2str(ASStageWidthAtHalfMax))
	endif
	//scale by thickness or weight here...
	if(CalibrateToVolume)		//old system, use thickness, area of beam cancels from the blank and Kfactor is as usually known...
		Kfactor = Kfactor*SampleThickness*0.1
		ASBParameters=ReplaceStringByKey("CalibrationUnit",ASBParameters,"cm2/cm3","=")
	elseif(CalibrateArbitrary)		//arbitrary, use thickness 1mm, data are on relative scale anyway.
		Kfactor = Kfactor*1*0.1
		ASBParameters=ReplaceStringByKey("CalibrationUnit",ASBParameters,"Arbitrary","=")
	elseif(CalibrateToWeight)			//use weight. Assume the weight in the beam is already scaled per beam area?
		//first calculate the amount of sample in the beam...
		//Kfactor = Kfactor*SampleThickness*0.1 * SampleDensity		//SampleWeightInBeam should be in g and be weight of sample [g/in 1 cm2 of beam area]
		Kfactor = Kfactor*SampleWeightInBeam							//SampleWeightInBeam should be in g and be weight of sample in [g/cm2 of beam area]
		ASBParameters=ReplaceStringByKey("CalibrationUnit",ASBParameters,"cm2/g","=")
	else						//prior system, nothing selected.
		Kfactor = Kfactor*SampleThickness*0.1
		ASBParameters=ReplaceStringByKey("CalibrationUnit",ASBParameters,"cm2/cm3","=")
	endif	
	ASBParameters=ReplaceNumberByKey("Kfactor",ASBParameters,Kfactor,"=")
	ASBParameters=ReplaceNumberByKey("OmegaFactor",ASBParameters,OmegaFactor,"=")
	setDataFolder OldDf	

end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IN3_RecalcSubtractSaAndBlank()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	NVAR SampleTransmission = root:Packages:Indra3:SampleTransmission
	SVAR ASBparameters=ListOfASBParameters
	NVAR BlankWidth = root:Packages:Indra3:BlankWidth			//blank width in arc seconds
	NVAR Wavelength = root:Packages:Indra3:Wavelength
	variable InstrumentQresolution = 2*pi*sin(BlankWidth/3600*pi/180)/Wavelength
	Wave R_Int
	Wave R_error
	Wave R_Qvec
	Wave PD_Range
	Wave BL_R_Int
	Wave BL_R_error
	Wave BL_R_Qvec
	variable Kfactor=NumberByKey("Kfactor", ASBparameters,"=",";")
	variable StartPointCut = BinarySearch(R_Qvec, 7e-5 )
	variable EndPointCut = numpnts(R_Qvec)
	DoWindow RcurvePlotGraph
	NVAR TrimDataStart=root:Packages:Indra3:TrimDataStart
	NVAR TrimDataEnd=root:Packages:Indra3:TrimDataEnd
	if(V_Flag)
		if(strlen(CsrInfo(A, "RcurvePlotGraph"))>0)
			StartPointCut = pcsr(A , "RcurvePlotGraph")
			TrimDataStart = StartPointCut
		endif 
		if(strlen(CsrInfo(B, "RcurvePlotGraph"))>0)
			EndPointCut = pcsr(B , "RcurvePlotGraph")
			TrimDataEnd = EndPointCut
		endif
	endif		
	NVAR SampleTransmission
	NVAR MSAXSCorrection = root:Packages:Indra3:MSAXSCorrection
	NVAR UseMSAXSCorrection = root:Packages:Indra3:UseMSAXSCorrection
	NVAR UsePinTransmission = root:Packages:Indra3:UsePinTransmission
	NVAR USAXSPinTvalue = root:Packages:Indra3:USAXSPinTvalue
	string USAXSorSBUSAXS
	variable MSAXSCorLocal=1
	if(UseMSAXSCorrection || UsePinTransmission)
		MSAXSCorLocal = MSAXSCorrection
	endif
	NVAR SubtractFlatBackground=root:Packages:Indra3:SubtractFlatBackground

	string IsItSBUSAXS
	IsItSBUSAXS=StringByKey("SPECCOMMAND", note(R_Int), "=")[0,7]
	string oldNoteValue			
	variable tempMinStep

	//need fix for PD_range used for coloring... 
	Duplicate/O PD_Range, PD_RangeModified
	IN2G_RemoveNaNsFrom4Waves(R_Int,R_error,R_Qvec, PD_RangeModified)
	IN2G_RemoveNaNsFrom3Waves(BL_R_Int,BL_R_error,BL_R_Qvec)

	if (stringmatch(IsItSBUSAXS,"uascan*"))			//if this is sbuascan, go to other part, otherwise create SMR data
		Duplicate /O R_Int, SMR_Int, logBlankInterp, BlankInterp
		Duplicate/O BL_R_Int, logBlankR
		logBlankR=log(BL_R_Int)
		LogBlankInterp=interp(R_Qvec, BL_R_Qvec, logBlankR)
		BlankInterp=10^LogBlankInterp
		SMR_Int= (R_Int - BlankInterp)/(Kfactor*MSAXSCorLocal)
		SMR_Int -= SubtractFlatBackground
		IN3_FixNegativeIntensities(SMR_Int)
		KillWaves/Z logBlankInterp, BlankInterp, logBlankR
		Duplicate/O R_error, SMR_Error
		Duplicate/O BL_R_error, log_BL_R_error
		log_BL_R_error=log(abs(BL_R_error))
		SMR_Error=sqrt((R_error)^2/SampleTransmission^2 + (10^(interp(R_Qvec, BL_R_Qvec, log_BL_R_error)))^2)/Kfactor
		SMR_Error/=3		//change 12/2013 seems our error estimates are simply too large... 
		SMR_Error*=SampleTransmission		//change 2/2014 to fix cases, when samples have really high absorption, but scatter well... 

		KillWaves/Z log_BL_R_error
		Duplicate/O R_Qvec, SMR_Qvec
		
		//remove points which are surely not useful
		DeletePoints EndPointCut, inf, SMR_Int, SMR_Qvec, SMR_Error 
		DeletePoints 0, StartPointCut, SMR_Int, SMR_Qvec, SMR_Error 
		Duplicate/O SMR_Qvec, SMR_dQ		
		SMR_dQ = InstrumentQresolution			//this same q resolution, given by instrument resolution, about 0.00008 for Si220. 
		//end append data
		DoWindow RcurvePlotGraph
		if(V_Flag)
			checkdisplayed /W=RcurvePlotGraph SMR_Int
			if(!V_Flag)
				AppendToGraph/R/W=RcurvePlotGraph SMR_Int vs SMR_Qvec
				Label right "SMR Intensity"
				ModifyGraph lsize(SMR_Int)=2
				ErrorBars SMR_Int Y,wave=(SMR_Error,SMR_Error)
				ModifyGraph rgb(SMR_Int)=(1,16019,65535)
				ModifyGraph log=1
				ModifyGraph gaps=0
			endif
		endif
		USAXSorSBUSAXS="USAXS"	
	elseif (stringmatch(IsItSBUSAXS,"flyScan*"))			//if this is slit smeared flyscan create SMR data
		Duplicate /O R_Int, SMR_Int
		Duplicate /Free R_Int, logBlankInterp, BlankInterp
		//Duplicate/Free BL_R_Int, logBlankR
		IN2G_LogInterpolateIntensity(R_Qvec, BlankInterp, BL_R_Qvec,BL_R_Int)	
		//logBlankR=log(BL_R_Int)
		//LogBlankInterp=interp(R_Qvec, BL_R_Qvec, logBlankR)
		//BlankInterp=10^LogBlankInterp
		SMR_Int= (R_Int - BlankInterp)/(Kfactor*MSAXSCorLocal)
		SMR_Int -= SubtractFlatBackground
		IN3_FixNegativeIntensities(SMR_Int)
		Duplicate/O R_error, SMR_Error
		Duplicate/Free BL_R_error, log_BL_R_error
		log_BL_R_error=log(abs(BL_R_error))
		SMR_Error=sqrt((R_error)^2/SampleTransmission^2 + (10^(interp(R_Qvec, BL_R_Qvec, log_BL_R_error)))^2)/Kfactor
		SMR_Error*=SampleTransmission		//change 2/2014 to fix cases, when samples have really high absorption, but scatter well... 
		Duplicate/O R_Qvec, SMR_Qvec		
		//remove points which are surely not useful
		DeletePoints EndPointCut, inf, SMR_Int, SMR_Qvec, SMR_Error 
		DeletePoints 0, StartPointCut, SMR_Int, SMR_Qvec, SMR_Error 
		//end append data
		DoWindow RcurvePlotGraph
		if(V_Flag)
			checkdisplayed /W=RcurvePlotGraph SMR_Int
			if(!V_Flag)
				AppendToGraph/R/W=RcurvePlotGraph SMR_Int vs SMR_Qvec
				Label/W=RcurvePlotGraph right "SMR Intensity"
				ModifyGraph/W=RcurvePlotGraph lsize(SMR_Int)=2
				ErrorBars/W=RcurvePlotGraph SMR_Int Y,wave=(SMR_Error,SMR_Error)
				ModifyGraph/W=RcurvePlotGraph rgb(SMR_Int)=(1,16019,65535)
				ModifyGraph/W=RcurvePlotGraph log=1
				ModifyGraph/W=RcurvePlotGraph gaps=0
			endif
		endif
		USAXSorSBUSAXS="FlyUSAXS"	
		NVAR FlyScanRebinToPoints=root:Packages:Indra3:FlyScanRebinToPoints
		//create width for each bin pixel...
		Duplicate/O SMR_Qvec, SMR_dQ
		if(FlyScanRebinToPoints>0)
			tempMinStep=SMR_Qvec[1]-SMR_Qvec[0]
			IN2G_RebinLogData(SMR_Qvec,SMR_Int,FlyScanRebinToPoints,tempMinStep,Wsdev=SMR_Error,Wxwidth=SMR_dQ)
		else
			SMR_dQ[1,numpnts(SMR_dQ)-2] = SMR_dQ[p+1]-SMR_dQ[p-1]
			SMR_dQ[0]=2*(SMR_dQ[1]-SMR_dQ[0])
			SMR_dQ[numpnts(SMR_dQ)-1] = 2*(SMR_dQ[numpnts(SMR_dQ)-1]-SMR_dQ[numpnts(SMR_dQ)-2])
		endif
		SMR_dQ = sqrt((SMR_dQ[p])^2 + InstrumentQresolution^2)		//convolute with SI220 InstrumentQresolution
	elseif (stringmatch(IsItSBUSAXS,"sbflySca"))			//if this is sbflyscan, creade DSM data
		Duplicate /O R_Int, DSM_Int, logBlankInterp, BlankInterp
		//Duplicate/O BL_R_Int, logBlankR
		IN2G_LogInterpolateIntensity(R_Qvec, BlankInterp, BL_R_Qvec,BL_R_Int)	
		//logBlankR=log(BL_R_Int)
		//LogBlankInterp=interp(R_Qvec, BL_R_Qvec, logBlankR)
		//BlankInterp=10^LogBlankInterp
		DSM_Int=  (R_Int - BlankInterp)/(MSAXSCorLocal*Kfactor)
		DSM_Int -=SubtractFlatBackground
		IN3_FixNegativeIntensities(DSM_Int)
		KillWaves/Z logBlankInterp, BlankInterp, logBlankR
		Duplicate/O R_error, DSM_Error
		Duplicate/O BL_R_error, log_BL_R_error
		log_BL_R_error=log(abs(BL_R_error))
		DSM_Error=sqrt((R_error)^2/SampleTransmission^2 + (10^(interp(R_Qvec, BL_R_Qvec, log_BL_R_error)))^2)/Kfactor
		DSM_Error*=SampleTransmission		//change 2/2014 to fix cases, when samples have really high absorption, but scatter well... 
		KillWaves/Z log_BL_R_error
		Duplicate/O R_Qvec, DSM_Qvec
		DeletePoints EndPointCut, inf, DSM_Int, DSM_Qvec, DSM_Error 
		DeletePoints 0, StartPointCut, DSM_Int, DSM_Qvec, DSM_Error 	//end append data
		DoWindow RcurvePlotGraph
		if(V_Flag)
			checkdisplayed /W=RcurvePlotGraph DSM_Int
			if(!V_Flag)
				AppendToGraph/R/W=RcurvePlotGraph DSM_Int vs DSM_Qvec
				Label right "DSM Intensity"
				ModifyGraph lsize(DSM_Int)=2
				ErrorBars DSM_Int Y,wave=(DSM_Error,DSM_Error)
				ModifyGraph rgb(DSM_Int)=(1,16019,65535)
				ModifyGraph log=1
				ModifyGraph gaps=0
			endif
		endif
		USAXSorSBUSAXS="FlyUSAXS"	
		NVAR FlyScanRebinToPoints=root:Packages:Indra3:FlyScanRebinToPoints
		Duplicate/O DSM_Qvec, DSM_dQ
		if(FlyScanRebinToPoints>0)
			tempMinStep=DSM_Qvec[1]-DSM_Qvec[0]
			IN2G_RebinLogData(DSM_Qvec,DSM_Int,FlyScanRebinToPoints,tempMinStep,Wsdev=DSM_Error,Wxwidth=DSM_dQ)
		else
			DSM_dQ[1,numpnts(DSM_dQ)-2] = DSM_dQ[p+1]-DSM_dQ[p-1]
			DSM_dQ[0]=2*(DSM_dQ[1]-DSM_dQ[0])
			DSM_dQ[numpnts(DSM_dQ)-1] = 2*(DSM_dQ[numpnts(DSM_dQ)-1]-DSM_dQ[numpnts(DSM_dQ)-2])
		endif
		DSM_dQ = sqrt((DSM_dQ[p])^2 + InstrumentQresolution^2)			//convolute with SI220 InstrumentQresolution
	elseif (stringmatch(IsItSBUSAXS,"sbuascan"))			//if this is sbuascan, go to other part, otherwise create SMR data
		Duplicate /O R_Int, DSM_Int, logBlankInterp, BlankInterp
		Duplicate/O BL_R_Int, logBlankR
		logBlankR=log(BL_R_Int)
		LogBlankInterp=interp(R_Qvec, BL_R_Qvec, logBlankR)
		BlankInterp=10^LogBlankInterp
		DSM_Int=  (R_Int - BlankInterp)/(MSAXSCorLocal*Kfactor)
		DSM_Int -=SubtractFlatBackground
		IN3_FixNegativeIntensities(DSM_Int)
		KillWaves/Z logBlankInterp, BlankInterp, logBlankR
		Duplicate/O R_error, DSM_Error
		Duplicate/O BL_R_error, log_BL_R_error
		log_BL_R_error=log(abs(BL_R_error))
		DSM_Error=sqrt((R_error)^2/SampleTransmission^2 + (10^(interp(R_Qvec, BL_R_Qvec, log_BL_R_error)))^2)/Kfactor
		DSM_Error*=SampleTransmission		//change 2/2014 to fix cases, when samples have really high absorption, but scatter well... 
		KillWaves/Z log_BL_R_error
		Duplicate/O R_Qvec, DSM_Qvec
		DeletePoints EndPointCut, inf, DSM_Int, DSM_Qvec, DSM_Error 
		DeletePoints 0, StartPointCut, DSM_Int, DSM_Qvec, DSM_Error 	//end append data
		Duplicate/O DSM_Qvec, DSM_dQ		
		DSM_dQ = InstrumentQresolution			//set to FWHM of the AR stage rocking curve... 
		DoWindow RcurvePlotGraph
		if(V_Flag)
			checkdisplayed /W=RcurvePlotGraph DSM_Int
			if(!V_Flag)
				AppendToGraph/R/W=RcurvePlotGraph DSM_Int vs DSM_Qvec
				Label right "DSM Intensity"
				ModifyGraph lsize(DSM_Int)=2
				ErrorBars DSM_Int Y,wave=(DSM_Error,DSM_Error)
				ModifyGraph rgb(DSM_Int)=(1,16019,65535)
				ModifyGraph log=1
				ModifyGraph gaps=0
			endif
		endif
	else
		Abort "Bad type of scan selected in IN3_RecalcSubtractSaAndBlank()"
	endif

	setDataFolder OldDf	
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

		

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IN3_SaveData()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	
	//here we save data as appropriate
	NVAR IsBlank = root:Packages:Indra3:IsBlank
	SVAR DataFolderName = root:Packages:Indra3:DataFolderName
	SVAR BlankName = root:Packages:Indra3:BlankName
	Wave/Z BL_R_Int = root:Packages:Indra3:BL_R_Int
	Wave/Z BL_R_Qvec = root:Packages:Indra3:BL_R_Qvec
	Wave/Z BL_R_Error = root:Packages:Indra3:BL_R_Error
	Wave/Z R_Int = root:Packages:Indra3:R_Int
	if(!WaveExists(R_Int))
		abort
	endif
	Wave R_Qvec = root:Packages:Indra3:R_Qvec
	Wave R_Error = root:Packages:Indra3:R_Error
	NVAR BeamCenterL = root:Packages:Indra3:BeamCenter
	NVAR MaximumIntensityL = root:Packages:Indra3:MaximumIntensity
	NVAR PeakWidthL = root:Packages:Indra3:PeakWidth
	NVAR WavelengthL = root:Packages:Indra3:Wavelength
	NVAR SlitLength=root:Packages:Indra3:SlitLength
	NVAR NumberOfSteps=root:Packages:Indra3:NumberOfSteps
	NVAR SDDistance=root:Packages:Indra3:SDDistance
	NVAR Kfactor=root:Packages:Indra3:Kfactor
	NVAR BlankWidth = root:Packages:Indra3:BlankWidth
	NVAR BlankFWHM = root:Packages:Indra3:BlankFWHM
	NVAR BlankMaximum= root:Packages:Indra3:BlankMaximum
	
	NVAR CalculateThickness=root:Packages:Indra3:CalculateThickness
	NVAR SampleFilledFraction=root:Packages:Indra3:SampleFilledFraction
	NVAR SampleThickness=root:Packages:Indra3:SampleThickness
	NVAR SampleTransmission=root:Packages:Indra3:SampleTransmission
	NVAR SampleLinAbsorption=root:Packages:Indra3:SampleLinAbsorption
	NVAR SampleTransmissionPeakToPeak=root:Packages:Indra3:SampleTransmissionPeakToPeak
	NVAR MSAXSCorrection=root:Packages:Indra3:MSAXSCorrection
	NVAR UseMSAXSCorrection=root:Packages:Indra3:UseMSAXSCorrection
	NVAR UsePinTransmission=root:Packages:Indra3:UsePinTransmission
	NVAR USAXSPinTvalue=root:Packages:Indra3:USAXSPinTvalue


	SVAR ListOfASBParametersL=root:Packages:Indra3:ListOfASBParameters

	NVAR CalibrateArbitrary=root:Packages:Indra3:CalibrateArbitrary
	NVAR CalibrateToWeight=root:Packages:Indra3:CalibrateToWeight
	NVAR CalibrateToVolume=root:Packages:Indra3:CalibrateToVolume
	NVAR SampleWeightInBeam=root:Packages:Indra3:SampleWeightInBeam
	NVAR CalculateWeight=root:Packages:Indra3:CalculateWeight
	NVAR BeamExposureArea=root:Packages:Indra3:BeamExposureArea
	NVAR SampleDensity=root:Packages:Indra3:SampleDensity
	
	///////////
	Wave/Z SMR_Int=root:Packages:Indra3:SMR_Int
	Wave/Z SMR_Error=root:Packages:Indra3:SMR_Error
	Wave/Z SMR_Qvec = root:Packages:Indra3:SMR_Qvec
	Wave/Z SMR_dQ = root:Packages:Indra3:SMR_dQ

	Wave/Z DSM_Int=root:Packages:Indra3:DSM_Int
	Wave/Z DSM_Error=root:Packages:Indra3:DSM_Error
	Wave/Z DSM_Qvec = root:Packages:Indra3:DSM_Qvec
	Wave/Z DSM_dQ = root:Packages:Indra3:DSM_dQ
	
	NVAR UseMSAXSCorrection= root:Packages:Indra3:UseMSAXSCorrection
	
	
	setDataFolder DataFolderName
	variable/g BeamCenter = BeamCenterL
	variable/g MaximumIntensity = MaximumIntensityL
	variable/g PeakWidth = PeakWidthL
	variable/g Wavelength = WavelengthL
	string/g ListOfASBParameters=ListOfASBParametersL

	
	if(IsBlank)	//is Blank, so save only Blank data...
		IN2G_AppendorReplaceWaveNote("R_Int","Wname","Blank_R_Int") 
		IN2G_AppendorReplaceWaveNote("R_error","Wname","Blank_R_error") 
		IN2G_AppendorReplaceWaveNote("R_Qvec","Wname","Blank_R_Qvec") 
		IN2G_AppendorReplaceWaveNote("R_Qvec","Units","A-1")
		IN2G_AppendorReplaceWaveNote("R_Int","Units","cm-1")

		Duplicate/O R_Int, $(DataFolderName+"Blank_R_Int")
		Duplicate/O R_Error, $(DataFolderName+"Blank_R_error")
		Duplicate/O R_Qvec, $(DataFolderName+"Blank_R_Qvec")

		IN2G_AppendAnyText("\r*******************************************************************************")
		IN2G_AppendAnyText("Processed Blank data for sample : " + DataFolderName)
		IN2G_AppendAnyText("Wavelength [A]:\t\t\t"+num2str(WavelengthL))

		IN2G_AppendAnyText("Maximum Intensity :\t\t"+num2str(MaximumIntensityL))
		IN2G_AppendAnyText("Peak Width [arc sec] :\t\t"+StringByKey("FWHM", note(R_Int), "=",";"))
		IN2G_AppendAnyText("Beam center [deg ARenc]:\t"+StringByKey("BeamCenter", note(R_Int),"=",";"))
		IN2G_AppendAnyText("Maximum Intensity :\t\t"+StringByKey("MaximumIntensity", note(R_Int), "=",";"))
		IN2G_AppendAnyText("Beam Center Error :\t\t"+StringByKey("BeamCenterError", note(R_Int), "=",";"))
		IN2G_AppendAnyText("Maximum Intensity Error :\t"+StringByKey("MaximumIntensityError", note(R_Int), "=",";"))
		IN2G_AppendAnyText("Peak Width error :\t\t"+StringByKey("FWHM_Error", note(R_Int), "=",";"))
	else
		string oldNoteValue=stringBykey("COMMENT", note(BL_R_Int), "=")
		string oldNoteValue2=stringBykey("USAXSDataFolder", note(BL_R_Int), "=")
		IN2G_AppendorReplaceWaveNote("R_Int","Wname","R_Int") 
		IN2G_AppendorReplaceWaveNote("R_error","Wname","R_error") 
		IN2G_AppendorReplaceWaveNote("R_Qvec","Wname","R_Qvec") 
		IN2G_AppendorReplaceWaveNote("R_Qvec","Units","A-1")
		IN2G_AppendorReplaceWaveNote("R_Int","BlankComment",oldNoteValue) 
		IN2G_AppendorReplaceWaveNote("R_error","BlankComment",oldNoteValue) 
		IN2G_AppendorReplaceWaveNote("R_Qvec","BlankComment",oldNoteValue) 
		IN2G_AppendorReplaceWaveNote("R_Int","BlankFolder",oldNoteValue2) 
		IN2G_AppendorReplaceWaveNote("R_error","BlankFolder",oldNoteValue2) 
		IN2G_AppendorReplaceWaveNote("R_Qvec","BlankFolder",oldNoteValue2) 
		IN2G_AppendorReplaceWaveNote("R_Int","Kfactor",num2str(Kfactor)) 
		IN2G_AppendorReplaceWaveNote("R_error","Kfactor",num2str(Kfactor)) 
		IN2G_AppendorReplaceWaveNote("R_Qvec","Kfactor",num2str(Kfactor)) 

		Duplicate/O R_Int, $(DataFolderName+"R_Int")
		Duplicate/O R_Error, $(DataFolderName+"R_error")
		Duplicate/O R_Qvec, $(DataFolderName+"R_Qvec")

		Duplicate/O BL_R_Int, $(DataFolderName+"BL_R_Int")
		Duplicate/O BL_R_Error, $(DataFolderName+"BL_R_error")
		Duplicate/O BL_R_Qvec, $(DataFolderName+"BL_R_Qvec")


		IN2G_AppendAnyText("\r*******************************************************************************")
		IN2G_AppendAnyText("Processed data for sample : " + DataFolderName)
		IN2G_AppendAnyText("used blank data  : " + BlankName)
		IN2G_AppendAnyText("Wavelength :\t\t"+num2str(WavelengthL))

		IN2G_AppendAnyText("Maximum Intensity :\t\t"+num2str(MaximumIntensityL))
		IN2G_AppendAnyText("Peak Width [arc sec] :\t\t"+StringByKey("FWHM", note(R_Int), "=",";"))
		IN2G_AppendAnyText("Beam center [deg ARenc]:\t"+StringByKey("BeamCenter", note(R_Int),"=",";"))
		IN2G_AppendAnyText("Maximum Intensity :\t\t"+StringByKey("MaximumIntensity", note(R_Int), "=",";"))
		IN2G_AppendAnyText("Beam Center Error :\t\t"+StringByKey("BeamCenterError", note(R_Int), "=",";"))
		IN2G_AppendAnyText("Maximum Intensity Error :\t"+StringByKey("MaximumIntensityError", note(R_Int), "=",";"))
		IN2G_AppendAnyText("Peak Width error :\t\t"+StringByKey("FWHM_Error", note(R_Int), "=",";"))

		IN2G_AppendAnyText("Blank Maximum Intensity :\t\t"+num2str(BlankMaximum))
		IN2G_AppendAnyText("Blank Peak Width :\t\t"+num2str(BlankWidth))
		IN2G_AppendAnyText("Wavelength :\t\t"+num2str(WavelengthL))
		IN2G_AppendAnyText("Kfactor :\t\t"+num2str(Kfactor))
		IN2G_AppendAnyText("SDDistance :\t\t"+num2str(SDDistance))
		IN2G_AppendAnyText("SlitLength :\t\t"+num2str(SlitLength))
		IN2G_AppendAnyText("NumberOfSteps :\t\t"+num2str(NumberOfSteps))
		
		if(CalibrateToWeight)
			if(CalculateWeight)
				IN2G_AppendAnyText("Calculated weight :\t\t")
				IN2G_AppendAnyText("SampleDensity :\t\t"+num2str(SampleDensity))
				IN2G_AppendAnyText("SampleTransmission :\t\t"+num2str(SampleTransmission))
				IN2G_AppendAnyText("SampleTransmissionPeakToPeak :\t\t"+num2str(SampleTransmissionPeakToPeak))
				IN2G_AppendAnyText("User defined or calculate weigth of Sample :\t\t"+num2str(SampleWeightInBeam))
			else
				IN2G_AppendAnyText("Sample weight :\t\t"+num2str(SampleWeightInBeam))
				IN2G_AppendAnyText("SampleTransmission :\t\t"+num2str(SampleTransmission))
				IN2G_AppendAnyText("SampleTransmissionPeakToPeak :\t\t"+num2str(SampleTransmissionPeakToPeak))
			endif
		elseif(CalibrateArbitrary) //calibrate arbitrary...
				IN2G_AppendAnyText("SampleTransmission :\t\t"+num2str(SampleTransmission))
				IN2G_AppendAnyText("SampleTransmissionPeakToPeak :\t\t"+num2str(SampleTransmissionPeakToPeak))		
		else		//(CalibrateToVolume, default)
			if(CalculateThickness)
				IN2G_AppendAnyText("Calculated thickness :\t\t")
				IN2G_AppendAnyText("SampleLinAbsorption :\t\t"+num2str(SampleLinAbsorption))
				IN2G_AppendAnyText("SampleTransmission :\t\t"+num2str(SampleTransmission))
				IN2G_AppendAnyText("SampleTransmissionPeakToPeak :\t\t"+num2str(SampleTransmissionPeakToPeak))
				IN2G_AppendAnyText("User defined Sample Thickness :\t\t"+num2str(SampleThickness))
				IN2G_AppendAnyText("SampleFilledFraction :\t\t"+num2str(SampleFilledFraction))
			else
				IN2G_AppendAnyText("Sample Thickness :\t\t"+num2str(SampleThickness))
				IN2G_AppendAnyText("SampleTransmission :\t\t"+num2str(SampleTransmission))
				IN2G_AppendAnyText("SampleTransmissionPeakToPeak :\t\t"+num2str(SampleTransmissionPeakToPeak))
			endif
		endif
		
		if(UseMSAXSCorrection || UsePinTransmission)
			IN2G_AppendAnyText("MSAXSCorrection :\t\t"+num2str(MSAXSCorrection))
		endif

		if(WaveExists(SMR_Int) && WaveExists(SMR_Error)&&WaveExists(SMR_Qvec))
			if(UseMSAXSCorrection)
				Duplicate/O SMR_Int, $(DataFolderName+"M_SMR_Int")
				Duplicate/O SMR_Error, $(DataFolderName+"M_SMR_Error")
				Duplicate/O SMR_Qvec, $(DataFolderName+"M_SMR_Qvec")
				Duplicate/O SMR_dQ, $(DataFolderName+"M_SMR_dQ")
				IN2G_AppendorReplaceWaveNote("M_SMR_Int","Wname","M_SMR_Int") 
				IN2G_AppendorReplaceWaveNote("M_SMR_Error","Wname","M_SMR_Error") 
				IN2G_AppendorReplaceWaveNote("M_SMR_Qvec","Wname","M_SMR_Qvec") 
				IN2G_AppendorReplaceWaveNote("M_SMR_Qvec","Units","A-1")
				IN2G_AppendorReplaceWaveNote("M_SMR_dQ","Wname","M_SMR_dQ") 
				IN2G_AppendorReplaceWaveNote("M_SMR_dQ","Units","A-1")
				if(CalibrateToWeight)
					IN2G_AppendorReplaceWaveNote("M_SMR_Int","Units","cm2/g")
				elseif(CalibrateArbitrary)
					IN2G_AppendorReplaceWaveNote("M_SMR_Int","Units","Arbitrary")
				else
					IN2G_AppendorReplaceWaveNote("M_SMR_Int","Units","cm2/cm3")
				endif
				IN2G_AppendorReplaceWaveNote("M_SMR_Int","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("M_SMR_Error","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("M_SMR_Qvec","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("M_SMR_Int","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("M_SMR_Error","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("M_SMR_Qvec","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("M_SMR_Int","Kfactor",num2str(Kfactor)) 
				IN2G_AppendorReplaceWaveNote("M_SMR_Error","Kfactor",num2str(Kfactor)) 
				IN2G_AppendorReplaceWaveNote("M_SMR_Qvec","Kfactor",num2str(Kfactor)) 
			else
				Duplicate/O SMR_Int, $(DataFolderName+"SMR_Int")
				Duplicate/O SMR_Error, $(DataFolderName+"SMR_Error")
				Duplicate/O SMR_Qvec, $(DataFolderName+"SMR_Qvec")
				Duplicate/O SMR_dQ, $(DataFolderName+"SMR_dQ")
				IN2G_AppendorReplaceWaveNote("SMR_Int","Wname","SMR_Int") 
				IN2G_AppendorReplaceWaveNote("SMR_Error","Wname","SMR_Error") 
				IN2G_AppendorReplaceWaveNote("SMR_Qvec","Wname","SMR_Qvec") 
				IN2G_AppendorReplaceWaveNote("SMR_Qvec","Units","A-1")
				IN2G_AppendorReplaceWaveNote("SMR_dQ","Wname","SMR_dQ") 
				IN2G_AppendorReplaceWaveNote("SMR_dQ","Units","A-1")
				if(CalibrateToWeight)
					IN2G_AppendorReplaceWaveNote("SMR_Int","Units","cm2/g")
				elseif(CalibrateArbitrary)
					IN2G_AppendorReplaceWaveNote("SMR_Int","Units","Arbitrary")
				else
					IN2G_AppendorReplaceWaveNote("SMR_Int","Units","cm2/cm3")
				endif
				IN2G_AppendorReplaceWaveNote("SMR_Int","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("SMR_Error","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("SMR_Qvec","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("SMR_Int","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("SMR_Error","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("SMR_Qvec","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("SMR_Int","Kfactor",num2str(Kfactor)) 
				IN2G_AppendorReplaceWaveNote("SMR_Error","Kfactor",num2str(Kfactor)) 
				IN2G_AppendorReplaceWaveNote("SMR_Qvec","Kfactor",num2str(Kfactor)) 
			endif
		endif
		if(WaveExists(DSM_Int) && WaveExists(DSM_Error)&&WaveExists(DSM_Qvec))
			if(UseMSAXSCorrection)
				Duplicate/O DSM_Int, $(DataFolderName+"M_DSM_Int")
				Duplicate/O DSM_Error, $(DataFolderName+"M_DSM_Error")
				Duplicate/O DSM_Qvec, $(DataFolderName+"M_DSM_Qvec")
				Duplicate/O DSM_dQ, $(DataFolderName+"M_DSM_dQ")
				IN2G_AppendorReplaceWaveNote("M_DSM_Int","Wname","M_DSM_Int") 
				IN2G_AppendorReplaceWaveNote("M_DSM_Error","Wname","M_DSM_Error") 
				IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","Wname","M_DSM_Qvec") 
				IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","Units","A-1")
				IN2G_AppendorReplaceWaveNote("M_DSM_dQ","Wname","M_DSM_dQ") 
				IN2G_AppendorReplaceWaveNote("M_DSM_dQ","Units","A-1")
				if(CalibrateToWeight)
					IN2G_AppendorReplaceWaveNote("M_DSM_Int","Units","cm2/g")
				elseif(CalibrateArbitrary)
					IN2G_AppendorReplaceWaveNote("M_DSM_Int","Units","Arbitrary")
				else
					IN2G_AppendorReplaceWaveNote("M_DSM_Int","Units","cm2/cm3")
				endif
				IN2G_AppendorReplaceWaveNote("M_DSM_Int","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("M_DSM_Error","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("M_DSM_Int","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("M_DSM_Error","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("M_DSM_Int","Kfactor",num2str(Kfactor)) 
				IN2G_AppendorReplaceWaveNote("M_DSM_Error","Kfactor",num2str(Kfactor)) 
				IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","Kfactor",num2str(Kfactor)) 
			else
				Duplicate/O DSM_Int, $(DataFolderName+"DSM_Int")
				Duplicate/O DSM_Error, $(DataFolderName+"DSM_Error")
				Duplicate/O DSM_Qvec, $(DataFolderName+"DSM_Qvec")
				Duplicate/O DSM_dQ, $(DataFolderName+"DSM_dQ")
				IN2G_AppendorReplaceWaveNote("DSM_Int","Wname","DSM_Int") 
				IN2G_AppendorReplaceWaveNote("DSM_Error","Wname","DSM_Error") 
				IN2G_AppendorReplaceWaveNote("DSM_Qvec","Wname","DSM_Qvec") 
				IN2G_AppendorReplaceWaveNote("DSM_Qvec","Units","A-1")
				IN2G_AppendorReplaceWaveNote("DSM_dQ","Wname","DSM_dQ") 
				IN2G_AppendorReplaceWaveNote("DSM_dQ","Units","A-1")
				if(CalibrateToWeight)
					IN2G_AppendorReplaceWaveNote("DSM_Int","Units","cm2/g")
				elseif(CalibrateArbitrary)
					IN2G_AppendorReplaceWaveNote("DSM_Int","Units","Arbitrary")
				else
					IN2G_AppendorReplaceWaveNote("DSM_Int","Units","cm2/cm3")
				endif
				IN2G_AppendorReplaceWaveNote("DSM_Int","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("DSM_Error","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("DSM_Qvec","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("DSM_Int","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("DSM_Error","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("DSM_Qvec","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("DSM_Int","Kfactor",num2str(Kfactor)) 
				IN2G_AppendorReplaceWaveNote("DSM_Error","Kfactor",num2str(Kfactor)) 
				IN2G_AppendorReplaceWaveNote("DSM_Qvec","Kfactor",num2str(Kfactor)) 
			endif
		endif
	endif



	
	//record stuff in wave notes...
	
	IN2G_AppendNoteToAllWaves("Wavelength",num2str(wavelength))
	IN2G_AppendNoteToAllWaves("SlitLength",num2str(SlitLength))
	IN2G_AppendNoteToAllWaves("NumberOfSteps",num2str(NumberOfSteps))
	IN2G_AppendNoteToAllWaves("SDDistance",num2str(SDDistance))
	if(!IsBlank)
		IN2G_AppendNoteToAllWaves("SampleTransmission",num2str(SampleTransmission))
		IN2G_AppendNoteToAllWaves("SampleTransmissionPeakToPeak",num2str(SampleTransmissionPeakToPeak))
		IN2G_AppendNoteToAllWaves("UseMSAXSCorrection",num2str(UseMSAXSCorrection))
		IN2G_AppendNoteToAllWaves("UsePinTransmission",num2str(UsePinTransmission))
		if(USAXSPinTvalue>0)
			IN2G_AppendNoteToAllWaves("pinDiodeTransmission",num2str(USAXSPinTvalue))
		endif
		if(UseMSAXSCorrection||UsePinTransmission)
			IN2G_AppendNoteToAllWaves("MSAXSCorrection",num2str(MSAXSCorrection))
		else
			IN2G_AppendNoteToAllWaves("MSAXSCorrection",num2str(1))
		endif
		if(CalibrateToWeight)
			if(CalculateWeight)
				IN2G_AppendNoteToAllWaves("CalculateWeight",num2str(CalculateWeight))
				IN2G_AppendNoteToAllWaves("SampleDensity",num2str(SampleDensity))
				IN2G_AppendNoteToAllWaves("SampleWeight",num2str(SampleWeightInBeam))
			else
				IN2G_AppendNoteToAllWaves("SampleWeight",num2str(SampleWeightInBeam))	
			endif
		else
			if(CalculateThickness)
				IN2G_AppendNoteToAllWaves("CalculateThickness",num2str(CalculateThickness))
				IN2G_AppendNoteToAllWaves("SampleFilledFraction",num2str(SampleFilledFraction))
				IN2G_AppendNoteToAllWaves("SampleLinAbsorption",num2str(SampleLinAbsorption))
			else
				IN2G_AppendNoteToAllWaves("SampleThickness",num2str(SampleThickness))	
			endif
		endif
	endif		
	
	IN3_PlotProcessedData()
	
	setDataFolder OldDf	
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************



	

Function IN3_InputPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if(stringmatch(ctrlName,"SelectBlankFolder"))
		//user wants to load blank data into this tool...
		SVAR BlankName = root:Packages:Indra3:BlankName
		BlankName = popStr
		PopupMenu SelectBlankFolder win=USAXSDataReduction, mode=popNum
		TitleBox SelectBlankFolderWarning win=USAXSDataReduction, disable=1
	endif
	if(stringmatch(ctrlName,"BackgroundFnct"))
		SVAR BackgroundFunction    = root:Packages:Indra3:DsmBackgroundFunction
		BackgroundFunction = popStr
		IN3_DesmearData()
	endif
	
	

End

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IN3_RplotCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
//	root:Packages:Indra3:DisplayPeakCenter,root:Packages:Indra3:DisplayAlignSaAndBlank
	NVAR DisplayPeakCenter =root:Packages:Indra3:DisplayPeakCenter
	NVAR DisplayAlignSaAndBlank=root:Packages:Indra3:DisplayAlignSaAndBlank
	If(stringmatch("DisplayPeakCenter",ctrlName))
		DisplayPeakCenter = 1
		DisplayAlignSaAndBlank = 0
		IN3_DisplayRightSubwindow()
		IN3_FixDispControlsInRcurvePlot()
	endif
	If(stringmatch("DisplayAlignSaAndBlank",ctrlName))
		DisplayPeakCenter = 0
		DisplayAlignSaAndBlank = 1
		IN3_DisplayRightSubwindow()
		IN3_FixDispControlsInRcurvePlot()
	endif

		NVAR UseLorenz = root:Packages:Indra3:UseLorenz
		NVAR UseModifiedGauss = root:Packages:Indra3:UseModifiedGauss
		NVAR UseGauss = root:Packages:Indra3:UseGauss
	If(stringmatch("UseLorenz",ctrlName))
		if(checked)
			UseLorenz=1
			UseModifiedGauss=0
			UseGauss=0
			IN3_COlorizeButton()
		endif
	endif
	If(stringmatch("UseModifiedGauss",ctrlName))
		if(checked)
			UseLorenz=0
			UseModifiedGauss=1
			UseGauss=0
			IN3_COlorizeButton()
		endif
	endif
	If(stringmatch("UseGauss",ctrlName))
		if(checked)
			UseLorenz=0
			UseModifiedGauss=0
			UseGauss=1
			IN3_COlorizeButton()
		endif
	endif

End
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IN3_CalculateMSAXSCorrection()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	
	NVAR UseMSAXSCorrection =root:Packages:Indra3:UseMSAXSCorrection
		//first need to find the positions for start end end points...
		NVAR BlankFWHM=root:Packages:Indra3:BlankFWHM
		NVAR PeakWidth=root:Packages:Indra3:PeakWidth
		//define Qlim as 5 times PeakWidth
		NVAR Qmin = root:Packages:Indra3:MSAXSStartPoint
		NVAR Qmax=root:Packages:Indra3:MSAXSEndPoint
		NVAR Wavelength=root:Packages:Indra3:Wavelength
		NVAR MSAXSCorrection=root:Packages:Indra3:MSAXSCorrection
		NVAR SampleTransmissionPeakToPeak=root:Packages:Indra3:SampleTransmissionPeakToPeak
		Wave/Z R_Int
		Wave/Z BL_R_Int
		if(!WaveExists(R_Int) || !WaveExists(BL_R_Int))
			abort
		endif
		Wave R_Qvec=root:Packages:Indra3:R_Qvec
		Wave BL_R_Qvec = root:Packages:Indra3:BL_R_Qvec
	

	if(UseMSAXSCorrection)
		if(stringmatch(ChildWindowList("USAXSDataReduction"),"*MSAXSGraph*"))
				IN3_ShowMSAXSGraph()
		endif
		variable start = round(BinarySearchInterp(R_Qvec, Qmin ))
		variable end1 = round(BinarySearchInterp(R_Qvec, Qmax ))

		if(Qmin==0 || Qmax==0 || abs(start-end1)<10)
			Qmin = -1*(4*pi/Wavelength) * sin(2*(pi/360)*PeakWidth) 
			Qmax = (4*pi/Wavelength) * sin(2*(pi/360)*PeakWidth) 
			start = BinarySearch(R_Qvec, Qmin )
			if(start<2)
				start=2
				Qmin=R_Qvec[2]
			endif	
			end1 = BinarySearch(R_Qvec, Qmax )
		endif
		if(start<2)
			start=2
		endif

		if(stringmatch(ChildWindowList("USAXSDataReduction"),"*MSAXSGraph*"))
 			SetAxis/W=USAXSDataReduction#MSAXSGraph bottom R_Qvec[start-8],R_Qvec[end1+8]
			Cursor/P/W=USAXSDataReduction#MSAXSGraph  A  R_Int  start
			Cursor/P/W=USAXSDataReduction#MSAXSGraph  B  R_Int  end1
		endif
		variable IntegralIntensitySample
		IntegralIntensitySample= (areaXY( R_Qvec,R_Int,  -Qmin, Qmax))
		IntegralIntensitySample=IntegralIntensitySample+ (areaXY( R_Qvec,R_Int,  Qmin, Qmax))
		variable IntegralIntensityBlank
		IntegralIntensityBlank= (areaXY( BL_R_Qvec,BL_R_Int,  -Qmin, Qmax))
		IntegralIntensityBlank= IntegralIntensityBlank+(areaXY( BL_R_Qvec,BL_R_Int,  Qmin, Qmax))
		
		variable M_transmission = (IntegralIntensitySample*SampleTransmissionPeakToPeak)/IntegralIntensityBlank
		//variable M_transmission = (IntegralIntensitySample)/IntegralIntensityBlank
		
		MSAXSCorrection = M_transmission/SampleTransmissionPeakToPeak
	else
		if(stringmatch(ChildWindowList("USAXSDataReduction"),"*MSAXSGraph*"))
			//SetWindow USAXSDataReduction#MSAXSGraph , hide =1
			IN3_HideMSAXSGraph()
			//DoWindow/K USAXSDataReduction#MSAXSGraph
		endif
		MSAXSCorrection=1
		//Qmin=0
		//Qmax=0
	endif
		
		IN3_FormatMSAXSGraph()
	
	setDataFolder oldDf
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IN3_HideMSAXSGraph()
		String ExistingSubWindows=ChildWindowList("USAXSDataReduction") 
		if(stringmatch(ExistingSubWindows,"*MSAXSGraph*") )
			KillWindow USAXSDataReduction#MSAXSGraph
		endif
		//setWindow USAXSDataReduction#MSAXSGraph, hide =1
end

Function IN3_ShowMSAXSGraph()
		//SetWindow USAXSDataReduction#MSAXSGraph , hide =0
		//MoveWindow /W=USAXSDataReduction#MSAXSGraph 0.023,0.50,0.966,0.792
		//Dowindow USAXSDataReduction#MSAXSGraph , hide =0
	//	setWindow USAXSDataReduction#MSAXSGraph, hide =1	
		if(!stringmatch(ChildWindowList("USAXSDataReduction"),"*MSAXSGraph*"))
				IN3_DisplayMSAXSGraph()
		endif
end

Function IN3_DisplayMSAXSGraph()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	Wave/Z R_Int
	if(!WaveExists(R_Int))
		abort
	endif	
	Wave R_Qvec
	Wave R_Error
	Wave R_error
	Wave AR_encoder
	Wave PeakFitWave
	Wave/Z BL_R_Int
	Wave/Z BL_R_Qvec
	NVAR IsBlank=root:Packages:Indra3:IsBlank
	
	if(IsBlank)
		return 0
	endif
	//create main plot with R curve data
	//create the other graph
	Display/W=(0.023,0.50,0.966,0.792)/HOST=USAXSDataReduction  R_Int vs R_Qvec
	AppendToGraph BL_R_Int vs BL_R_Qvec
	//modify displayed waves 
	ModifyGraph mode(R_Int)=3
	ModifyGraph rgb(BL_R_Int)=(0,0,65280)
	ModifyGraph nticks(bottom)=2
	ModifyGraph lblMargin(left)=26,lblMargin(bottom)=1
	ModifyGraph lblLatPos=-1
	Label left "Intensity"
	Label bottom "Q [A\S-1\M]"
	RenameWindow #,MSAXSGraph
	SetActiveSubwindow ##

	IN3_FormatMSAXSGraph()
	setDataFolder oldDf
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN3_FormatMSAXSGraph()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	String ExistingSubWindows=ChildWindowList("USAXSDataReduction") 
	if(stringmatch(ExistingSubWindows,"*MSAXSGraph*"))
	//			Cursor/P/W=RcurvePlotGraph#PeakCenter A PD_Intensity PeakCenterFitStartPoint
	//			Cursor/P/W=RcurvePlotGraph#PeakCenter B PD_Intensity PeakCenterFitEndPoint	
	//		endif
		SetWindow USAXSDataReduction, hook(named)=$""
	 
		Wave R_Int
		Wave R_Qvec
		Wave R_Error
		Wave R_error
		Wave AR_encoder
		Wave PeakFitWave
		Wave BL_R_Int
		Wave BL_R_Qvec
		NVAR Qmin = root:Packages:Indra3:MSAXSStartPoint
		NVAR Qmax=root:Packages:Indra3:MSAXSEndPoint
		
		//create main plot with R curve data
		//create the other graph
	//	Display/W=(0.023,0.50,0.966,0.792)/HOST=USAXSDataReduction  R_Int vs R_Qvec
	//	AppendToGraph BL_R_Int vs BL_R_Qvec
		//modify displayed waves 
		ModifyGraph /W=USAXSDataReduction#MSAXSGraph mode(R_Int)=3
		ModifyGraph /W=USAXSDataReduction#MSAXSGraph rgb(BL_R_Int)=(0,0,65280)
		ModifyGraph /W=USAXSDataReduction#MSAXSGraph nticks(bottom)=2
		ModifyGraph /W=USAXSDataReduction#MSAXSGraph lblMargin(left)=26,lblMargin(bottom)=1
		ModifyGraph /W=USAXSDataReduction#MSAXSGraph lblLatPos=-1
		Label/W=USAXSDataReduction#MSAXSGraph  left "Intensity"
		Label/W=USAXSDataReduction#MSAXSGraph  bottom "Q [A\S-1\M]"
//		variable start = BinarySearch(R_Qvec, Qmin )+(gnoise(1) <1 ? 0 : 1)
//		variable end1 = BinarySearch(R_Qvec, Qmax )+(gnoise(1) <1 ? 0 : 1)
		variable start = round(BinarySearchInterp(R_Qvec, Qmin ))
		start = start-8
		start = start>1 ? start : 1
		variable end1 = ROUND(BinarySearchInterp(R_Qvec, Qmax ))
//		PRINT START, "   ", end1
		SetAxis/W=USAXSDataReduction#MSAXSGraph bottom R_Qvec[start],R_Qvec[end1+8]
		Cursor/P/W=USAXSDataReduction#MSAXSGraph  A  R_Int  start
		Cursor/P/W=USAXSDataReduction#MSAXSGraph  B  R_Int  end1
		SetWindow USAXSDataReduction, hook(named)=IN3_MSAXSHookFunction

	endif

	setDataFolder oldDf

end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN3_MSAXSHookFunction(H_Struct)
    STRUCT WMWinHookStruct &H_Struct
    
    if (h_struct.eventCode==7 && stringMatch(h_struct.winName,"USAXSDataReduction#MSAXSGraph"))
	//    print h_struct.eventCode, h_struct.winName
		string oldDf=GetDataFolder(1)
		setDataFolder root:Packages:Indra3
		NVAR Qmin = root:Packages:Indra3:MSAXSStartPoint
		NVAR Qmax=root:Packages:Indra3:MSAXSEndPoint
		Wave R_Qvec=root:Packages:Indra3:R_Qvec
		variable start = BinarySearch(R_Qvec, Qmin )
		variable end1 = BinarySearch(R_Qvec, Qmax )
		String ExistingSubWindows=ChildWindowList("USAXSDataReduction") 
		if(stringmatch(ExistingSubWindows,"*MSAXSGraph*"))
			if(strlen(csrinfo(A,"USAXSDataReduction#MSAXSGraph"))<1)
				Cursor/P/W=USAXSDataReduction#MSAXSGraph A PD_Intensity start
			endif
			if(strlen(csrinfo(B,"USAXSDataReduction#MSAXSGraph"))<1)
				Cursor/P/W=USAXSDataReduction#MSAXSGraph B PD_Intensity end1
			endif
		endif
		Qmin = min(R_Qvec[pcsr(A, "USAXSDataReduction#MSAXSGraph")], R_Qvec[pcsr(B, "USAXSDataReduction#MSAXSGraph")])
		Qmax = max(R_Qvec[pcsr(A, "USAXSDataReduction#MSAXSGraph")], R_Qvec[pcsr(B, "USAXSDataReduction#MSAXSGraph")])
	 	IN3_CalculateMSAXSCorrection()
	 	NVAR SampleTransmissionPeakToPeak= root:Packages:Indra3:SampleTransmissionPeakToPeak
	 	NVAR SampleTransmission= root:Packages:Indra3:SampleTransmission
	 	NVAR MSAXSCorrection=root:Packages:Indra3:MSAXSCorrection
		SampleTransmission = SampleTransmissionPeakToPeak * MSAXSCorrection
			//recalculate what needs to be done...
		IN3_RecalculateData(2)
		IN3_DesmearData()
		setDataFolder oldDf
	endif
    return 0        // 0 if nothing done, else 1
end


//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN3_CalcSampleWeightOrThickness()

	NVAR CalibrateToWeight = root:Packages:Indra3:CalibrateToWeight
	NVAR CalculateThickness = root:Packages:Indra3:CalculateThickness
	NVAR SampleThickness = root:Packages:Indra3:SampleThickness
	NVAR SampleTransmission = root:Packages:Indra3:SampleTransmission
	NVAR SampleLinAbsorption = root:Packages:Indra3:SampleLinAbsorption
	NVAR SampleFilledFraction = root:Packages:Indra3:SampleFilledFraction
	NVAR CalculateWeight= root:Packages:Indra3:CalculateWeight
	NVAR SampleDensity= root:Packages:Indra3:SampleDensity
 	NVAR SampleWeightInBeam= root:Packages:Indra3:SampleWeightInBeam
 	NVAR SampleFilledFraction= root:Packages:Indra3:SampleFilledFraction
	NVAR BeamExposureArea= root:Packages:Indra3:BeamExposureArea	
	//transm =  exp(-mu * T)
	// T =  (1/SampleFilledFraction) *(- ln(transm)/mu )
	//mu = (1/SampleFilledFraction) *(- ln(transm)/T )
	if(CalibrateToWeight)
		if(CalculateWeight)
			if(CalculateThickness)
				SampleThickness = -10 *( ln(SampleTransmission)/SampleLinAbsorption )
			endif
			//SampleWeightInBeam = BeamExposureArea * SampleThickness * SampleDensity	
			// this should be normalized to 1mm2 of beam area as the empty normalizes everything to mm2
			SampleWeightInBeam = SampleThickness*0.1 * SampleDensity	//this is g/cm * thickness converted to cm  	
		else
			SampleDensity = SampleWeightInBeam /  (SampleThickness /10)
		endif
	else	
		if(CalculateThickness)
			SampleThickness = -10*(1/SampleFilledFraction) *( ln(SampleTransmission)/SampleLinAbsorption )
		else
			SampleLinAbsorption =  -ln(SampleTransmission) / (SampleThickness/(10*(1/SampleFilledFraction)))
		endif
	endif	
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
