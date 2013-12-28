#pragma rtGlobals=1		// Use modern global access method.
#pragma version =1.02

//1.01 modified for weight calibration
//1.02 added pinDiode tranmsission

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IN3_Template()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	setDataFolder OldDf	
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN3_MakeMyColors(PDrange,NewColors)		//makes color wave for 
 	Wave PDrange, NewColors
 	
 	variable i=0
 	
 	Do
 		if (PDrange[i]==1)		//range 1 color
 			NewColors[i]=0
		endif 	
 		if (PDrange[i]==2)		//range 2 color
 			NewColors[i]=4.5
		endif 	
 		if (PDrange[i]==3)		//range 3 color
 			NewColors[i]=7.7
		endif 	
 		if (PDrange[i]==4)		//range 4 color
 			NewColors[i]=1.3
		endif 	
 		if (PDrange[i]==5)		//range 5 color
 			NewColors[i]=10
		endif 	
 	
 	i+=1
 	while(i<numpnts(PDrange)) 	
 end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN3_ColorMainGraph(PdRanges)
	variable PdRanges

	SVAR DataFolderName=root:Packages:Indra3:DataFolderName
	Wave/Z PD_range=$(DataFolderName+"PD_Range")
	//set PdRanges to 1 to have colored main data in correct colors., 0 to uncolor
	DoWIndow RcurvePlotGraph
	if(WaveExists(PD_range)&&V_Flag)
		if(PdRanges)
			Duplicate/O PD_range, root:Packages:USAXS:MyColorWave							//creates new color wave
			IN3_MakeMyColors(PD_range,root:Packages:USAXS:MyColorWave)						//creates colors in it
	 		ModifyGraph /W=RcurvePlotGraph/Z mode=4, zColor(R_Int)={root:Packages:USAXS:MyColorWave,0,10,Rainbow}
		else
	 		ModifyGraph /W=RcurvePlotGraph/Z  mode=4, zColor(R_Int)=0
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

Function IN3_ReCalculateTransmission()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	NVAR SampleTransmissionPeakToPeak = root:Packages:Indra3:SampleTransmissionPeakToPeak
	NVAR BlankMaximum=root:Packages:Indra3:BlankMaximum
	NVAR MaximumIntensity=root:Packages:Indra3:MaximumIntensity
	NVAR SampleTransmission=root:Packages:Indra3:SampleTransmission
	NVAR MSAXSCorrection=root:Packages:Indra3:MSAXSCorrection
	NVAR UseMSAXSCorrection=root:Packages:Indra3:UseMSAXSCorrection
	//SampleTransmissionPeakToPeak = MaximumIntensity/BlankMaximum
	SampleTransmission = SampleTransmissionPeakToPeak
	if(UseMSAXSCorrection)
		SampleTransmission*=MSAXSCorrection
	endif
	
	setDataFolder OldDf	
end


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
	IN2G_RemoveNaNsFrom3Waves(R_Int,R_Qvec,R_Error)
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

	NVAR CalibrateToWeight 	=	root:Packages:Indra3:CalibrateToWeight
	NVAR CalibrateToVolume 	=	root:Packages:Indra3:CalibrateToVolume
	NVAR CalibrateArbitrary 	=	root:Packages:Indra3:CalibrateArbitrary
	NVAR SampleWeightInBeam 	=	root:Packages:Indra3:SampleWeightInBeam
	NVAR SampleDensity 		=	root:Packages:Indra3:SampleDensity
	NVAR SampleWeightInBeam 	=	root:Packages:Indra3:SampleWeightInBeam
	NVAR BeamExposureArea	=	root:Packages:Indra3:BeamExposureArea
	NVAR BLPeakWidth			=	root:Packages:Indra3:BlankFWHM
	NVAR BLPeakMax			=	root:Packages:Indra3:BlankMaximum
	NVAR SampleThickness		=	root:Packages:Indra3:SampleThickness
	string Calibrated			=	StringByKey("Calibrate", ASBParameters,"=",";")
	NVAR PhotoDiodeSize		=	root:Packages:Indra3:PhotoDiodeSize															//Default PD size to 5.5mm at this time....
	SVAR/Z MeasurementParameters
	if(!SVAR_Exists(MeasurementParameters))
		abort
	endif
	variable SampleToDetectorDistance=numberByKey("SDDistance",MeasurementParameters,"=")		//need to get it
//	if (numtype(SampleToDetectorDistance)==2)														//this is fix for trouble when Raw-to_USAXS is run out of sequence
//		IN2A_GetMeasParam()
//		SampleToDetectorDistance=numberByKey("SDDistance",MeasurementParameters,"=")
//	endif
	Variable OmegaFactor,ASStageWidthAtHalfMax
	NVAR Kfactor
	variable BLPeakWidthL
//	// first check that the EPICS parameters really have useful number there
//	if (numtype(SampleThickness)!=0)
//		SampleThickness=1
//	endif
//	//and then, if we already set sample thickness before, we will ovewrite it here...
//	if (NumType(NumberByKey("SaThickness", ASBParameters ,"=" ,";"))!=2)			//this carries forward the old sample thickness - the previous 
//		SampleThickness=NumberByKey("SaThickness", ASBParameters ,"=" ,";")		//sample sample thickness is offered
//	endif
//														//lets check if we have old sample thickness in the wave note for R_Int here
//	variable oldthickness=NumberByKey("Thickness", note(R_Int) ,"=",";")
//	if (numtype(oldthickness)==0)			//if it existed in the wave note, we will offer that to user
//		SampleThickness=oldthickness
//	endif
//	Prompt SampleThickness, "Input sample thickness in mm for "+GetDataFolder(1)
//	
	if (cmpstr(StringByKey("Calibrate", ASBParameters,"=",";"),"USAXS")==0)		//USAXS callibration, width given by SDD and PD size
		BLPeakWidthL=BLPeakWidth*3600													//W_coef[3]*3600*2
//		Prompt BLPeakWidthL, "?Overwrite the Blank width at half max (arc-sec)"
//		DoPrompt "USAXS Calibration user input for  "+GetDataFolder(1), BLPeakWidthL, SampleThickness
//			if (V_Flag)
//				Abort 
//			endif	
//		if(SampleThickness<=0)
//			Prompt SampleThickness, "ERROR, sample thickness is <= 0! Please input correct sample thickness"
//			DoPrompt "Fix incorrect sample thickness", SampleThickness
//			if(V_Flag)
//				Abort
//			endif
//			if(SampleThickness<=0)
//				SampleThickness=100
//				DoAlert 1, "Sample thickness set to 100mm, your absolute intensity calibration is probably inccorrect. Do you still want to continue?"
//				if(V_Flag!=1)
//					abort
//				endif
//			endif
//		endif
//		
//		
		OmegaFactor= (PhotoDiodeSize/SampleToDetectorDistance)*(BLPeakWidthL/3600)*(pi/180)
		Kfactor=BLPeakMax*OmegaFactor 				// *SampleThickness*0.1  ; 0.1 converts the thickness of sample from mm to cm
	endif
	if (cmpstr(StringByKey("Calibrate", ASBParameters,"=",";"),"SBUSAXS")==0)	//SBUSAXS callibration, width given by rocking curve width
		BLPeakWidthL=BLPeakWidth*3600												//W_coef[3]*3600*2
		ASStageWidthAtHalfMax=BLPeakWidthL
//		string MyWarnig="Fix for Signlebounce Intensity for this is dividing data by 1.66 (sqrt(1.32^2+1^2)"
//		Prompt BLPeakWidthL, "?Overwrite measured Blank FWHM (arc-sec)"
//		Prompt ASStageWidthAtHalfMax, "?AS stage width FWHM (arc-sec)"
//		Prompt MyWarnig, "Single sidebounces used, the calibration with default peak width is incorrect !!"
//		DoPrompt "SBUSAXS Calibration user input for  "+GetDataFolder(1), BLPeakWidthL, ASStageWidthAtHalfMax, MyWarnig, SampleThickness
//			if (V_Flag)
//				Abort 
//			endif	
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
		Wave R_Int
		Wave R_error
		Wave R_Qvec
		Wave BL_R_Int
		Wave BL_R_error
		Wave BL_R_Qvec
		//Wave R_Int
		//Wave R_Qvec
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
//		variable Kfactor=1
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

	IN2G_RemoveNaNsFrom5Waves(R_Int,R_Int,R_error,R_Qvec,R_Qvec)
	IN2G_RemoveNaNsFrom3Waves(BL_R_Int,BL_R_error,BL_R_Qvec)
//	
	if (stringmatch(IsItSBUSAXS,"uascan*"))			//if this is sbuascan, go to other part, otherwise create SMR data
		Duplicate /O R_Int, SMR_Int, logBlankInterp, BlankInterp
		Duplicate/O BL_R_Int, logBlankR
		logBlankR=log(BL_R_Int)
		LogBlankInterp=interp(R_Qvec, BL_R_Qvec, logBlankR)
		BlankInterp=10^LogBlankInterp
		SMR_Int= (R_Int - BlankInterp)/(Kfactor*MSAXSCorLocal)
		SMR_Int -= SubtractFlatBackground
		KillWaves/Z logBlankInterp, BlankInterp, logBlankR
		Duplicate/O R_error, SMR_Error
		Duplicate/O BL_R_error, log_BL_R_error
		log_BL_R_error=log(abs(BL_R_error))
		SMR_Error=sqrt((R_error)^2/SampleTransmission^2 + (10^(interp(R_Qvec, BL_R_Qvec, log_BL_R_error)))^2)/Kfactor
		SMR_Error/=3		//change 12/2013 seems our error estimates are simply too large... 
		KillWaves/Z log_BL_R_error
		Duplicate/O R_Qvec, SMR_Qvec
		
		//remove points which are surely not useful
		DeletePoints EndPointCut, inf, SMR_Int, SMR_Qvec, SMR_error 
		DeletePoints 0, StartPointCut, SMR_Int, SMR_Qvec, SMR_error 
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
	elseif (stringmatch(IsItSBUSAXS,"flyScan*"))			//if this is sbuascan, go to other part, otherwise create SMR data
		Duplicate /O R_Int, SMR_Int
		Duplicate /Free R_Int, logBlankInterp, BlankInterp
		Duplicate/Free BL_R_Int, logBlankR
		logBlankR=log(BL_R_Int)
		LogBlankInterp=interp(R_Qvec, BL_R_Qvec, logBlankR)
		BlankInterp=10^LogBlankInterp
		SMR_Int= (R_Int - BlankInterp)/(Kfactor*MSAXSCorLocal)
		SMR_Int -= SubtractFlatBackground
		Duplicate/O R_error, SMR_Error
		Duplicate/Free BL_R_error, log_BL_R_error
		log_BL_R_error=log(abs(BL_R_error))
		SMR_Error=sqrt((R_error)^2/SampleTransmission^2 + (10^(interp(R_Qvec, BL_R_Qvec, log_BL_R_error)))^2)/Kfactor
		SMR_Error/=3		//errors seemed just too large, this is arbitrary correction... 
		Duplicate/O R_Qvec, SMR_Qvec		
		//remove points which are surely not useful
		DeletePoints EndPointCut, inf, SMR_Int, SMR_Qvec, SMR_error 
		DeletePoints 0, StartPointCut, SMR_Int, SMR_Qvec, SMR_error 
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
		USAXSorSBUSAXS="FlyUSAXS"	
#if(exists("IN3_FlyScanRebinData2")==6)
			NVAR FlyScanRebinToPoints=root:Packages:Indra3:FlyScanRebinToPoints
			if(FlyScanRebinToPoints>0)
				IN3_FlyScanRebinData2(SMR_Qvec, SMR_Int, SMR_error,FlyScanRebinToPoints)
			endif
#endif
	elseif (stringmatch(IsItSBUSAXS,"sbuascan"))			//if this is sbuascan, go to other part, otherwise create SMR data
		Duplicate /O R_Int, DSM_Int, logBlankInterp, BlankInterp
		Duplicate/O BL_R_Int, logBlankR
		logBlankR=log(BL_R_Int)
		LogBlankInterp=interp(R_Qvec, BL_R_Qvec, logBlankR)
		BlankInterp=10^LogBlankInterp
		DSM_Int=  (R_Int - BlankInterp)/(MSAXSCorLocal*Kfactor)
		DSM_Int -=SubtractFlatBackground
		KillWaves/Z logBlankInterp, BlankInterp, logBlankR
		Duplicate/O R_error, DSM_Error
		Duplicate/O BL_R_error, log_BL_R_error
		log_BL_R_error=log(abs(BL_R_error))
		DSM_Error=sqrt((R_error)^2/SampleTransmission^2 + (10^(interp(R_Qvec, BL_R_Qvec, log_BL_R_error)))^2)/Kfactor
		KillWaves/Z log_BL_R_error
		Duplicate/O R_Qvec, DSM_Qvec

		DeletePoints EndPointCut, inf, DSM_Int, DSM_Qvec, DSM_error 
		DeletePoints 0, StartPointCut, DSM_Int, DSM_Qvec, DSM_error 	//end append data
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
	Wave R_Int = root:Packages:Indra3:R_Int
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

	Wave/Z DSM_Int=root:Packages:Indra3:DSM_Int
	Wave/Z DSM_Error=root:Packages:Indra3:DSM_Error
	Wave/Z DSM_Qvec = root:Packages:Indra3:DSM_Qvec
	
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
				Duplicate/O SMR_Error, $(DataFolderName+"M_SMR_error")
				Duplicate/O SMR_Qvec, $(DataFolderName+"M_SMR_Qvec")
				IN2G_AppendorReplaceWaveNote("M_SMR_Int","Wname","M_SMR_Int") 
				IN2G_AppendorReplaceWaveNote("M_SMR_error","Wname","M_SMR_error") 
				IN2G_AppendorReplaceWaveNote("M_SMR_Qvec","Wname","M_SMR_Qvec") 
				IN2G_AppendorReplaceWaveNote("M_SMR_Qvec","Units","A-1")
				if(CalibrateToWeight)
					IN2G_AppendorReplaceWaveNote("M_SMR_Int","Units","cm2/g")
				elseif(CalibrateArbitrary)
					IN2G_AppendorReplaceWaveNote("M_SMR_Int","Units","Arbitrary")
				else
					IN2G_AppendorReplaceWaveNote("M_SMR_Int","Units","cm2/cm3")
				endif
				IN2G_AppendorReplaceWaveNote("M_SMR_Int","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("M_SMR_error","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("M_SMR_Qvec","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("M_SMR_Int","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("M_SMR_error","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("M_SMR_Qvec","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("M_SMR_Int","Kfactor",num2str(Kfactor)) 
				IN2G_AppendorReplaceWaveNote("M_SMR_error","Kfactor",num2str(Kfactor)) 
				IN2G_AppendorReplaceWaveNote("M_SMR_Qvec","Kfactor",num2str(Kfactor)) 
			else
				Duplicate/O SMR_Int, $(DataFolderName+"SMR_Int")
				Duplicate/O SMR_Error, $(DataFolderName+"SMR_error")
				Duplicate/O SMR_Qvec, $(DataFolderName+"SMR_Qvec")
				IN2G_AppendorReplaceWaveNote("SMR_Int","Wname","SMR_Int") 
				IN2G_AppendorReplaceWaveNote("SMR_error","Wname","SMR_error") 
				IN2G_AppendorReplaceWaveNote("SMR_Qvec","Wname","SMR_Qvec") 
				IN2G_AppendorReplaceWaveNote("SMR_Qvec","Units","A-1")
				if(CalibrateToWeight)
					IN2G_AppendorReplaceWaveNote("SMR_Int","Units","cm2/g")
				elseif(CalibrateArbitrary)
					IN2G_AppendorReplaceWaveNote("SMR_Int","Units","Arbitrary")
				else
					IN2G_AppendorReplaceWaveNote("SMR_Int","Units","cm2/cm3")
				endif
				IN2G_AppendorReplaceWaveNote("SMR_Int","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("SMR_error","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("SMR_Qvec","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("SMR_Int","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("SMR_error","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("SMR_Qvec","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("SMR_Int","Kfactor",num2str(Kfactor)) 
				IN2G_AppendorReplaceWaveNote("SMR_error","Kfactor",num2str(Kfactor)) 
				IN2G_AppendorReplaceWaveNote("SMR_Qvec","Kfactor",num2str(Kfactor)) 
			endif
		endif
		if(WaveExists(DSM_Int) && WaveExists(DSM_Error)&&WaveExists(DSM_Qvec))
			if(UseMSAXSCorrection)
				Duplicate/O DSM_Int, $(DataFolderName+"M_DSM_Int")
				Duplicate/O DSM_Error, $(DataFolderName+"M_DSM_error")
				Duplicate/O DSM_Qvec, $(DataFolderName+"M_DSM_Qvec")
				IN2G_AppendorReplaceWaveNote("M_DSM_Int","Wname","M_DSM_Int") 
				IN2G_AppendorReplaceWaveNote("M_DSM_error","Wname","M_DSM_error") 
				IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","Wname","M_DSM_Qvec") 
				IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","Units","A-1")
				if(CalibrateToWeight)
					IN2G_AppendorReplaceWaveNote("M_DSM_Int","Units","cm2/g")
				elseif(CalibrateArbitrary)
					IN2G_AppendorReplaceWaveNote("M_DSM_Int","Units","Arbitrary")
				else
					IN2G_AppendorReplaceWaveNote("M_DSM_Int","Units","cm2/cm3")
				endif
				IN2G_AppendorReplaceWaveNote("M_DSM_Int","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("M_DSM_error","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("M_DSM_Int","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("M_DSM_error","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("M_DSM_Int","Kfactor",num2str(Kfactor)) 
				IN2G_AppendorReplaceWaveNote("M_DSM_error","Kfactor",num2str(Kfactor)) 
				IN2G_AppendorReplaceWaveNote("M_DSM_Qvec","Kfactor",num2str(Kfactor)) 
			else
				Duplicate/O DSM_Int, $(DataFolderName+"DSM_Int")
				Duplicate/O DSM_Error, $(DataFolderName+"DSM_error")
				Duplicate/O DSM_Qvec, $(DataFolderName+"DSM_Qvec")
				IN2G_AppendorReplaceWaveNote("DSM_Int","Wname","DSM_Int") 
				IN2G_AppendorReplaceWaveNote("DSM_error","Wname","DSM_error") 
				IN2G_AppendorReplaceWaveNote("DSM_Qvec","Wname","DSM_Qvec") 
				IN2G_AppendorReplaceWaveNote("DSM_Qvec","Units","A-1")
				if(CalibrateToWeight)
					IN2G_AppendorReplaceWaveNote("DSM_Int","Units","cm2/g")
				elseif(CalibrateArbitrary)
					IN2G_AppendorReplaceWaveNote("DSM_Int","Units","Arbitrary")
				else
					IN2G_AppendorReplaceWaveNote("DSM_Int","Units","cm2/cm3")
				endif
				IN2G_AppendorReplaceWaveNote("DSM_Int","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("DSM_error","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("DSM_Qvec","BlankComment",oldNoteValue) 
				IN2G_AppendorReplaceWaveNote("DSM_Int","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("DSM_error","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("DSM_Qvec","BlankFolder",oldNoteValue2) 
				IN2G_AppendorReplaceWaveNote("DSM_Int","Kfactor",num2str(Kfactor)) 
				IN2G_AppendorReplaceWaveNote("DSM_error","Kfactor",num2str(Kfactor)) 
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
		Wave R_Int
		Wave BL_R_Int
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
		variable end1 = ROUND(BinarySearchInterp(R_Qvec, Qmax ))
//		PRINT START, "   ", end1
		SetAxis/W=USAXSDataReduction#MSAXSGraph bottom R_Qvec[start-8],R_Qvec[end1+8]
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
