#pragma rtGlobals=1		// Use modern global access method.
#pragma version 1.02

//1.02 updated to use 	I0AmpGain			
//1.01 updated IN3_calculateRwaveQvec to enable analysis of scans down (as usually) or up (as needed for GIUSAXS)


Function IN3_RecalculateData(StepFrom)   //recalculate R wave from user specified point
	variable StepFrom
		// 0 - start and estimate the center (for beggining)
		// 1 - recalculate R wave without estimating center, just when the PD parameters are changed...
		// 2 - changed Q parameters, recalcualte just the Q vales... 
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	NVAR IsBlank = root:Packages:Indra3:IsBlank

	if(StepFrom==0)			//very beggining, all needs to be calculated
		IN3_CalculateRWaveIntensity()			//using UPD parameters recalculate the R wave intensity
		IN3_FitPeakCenterEstimate() 			//sets up original fit to peak center using gaussian	
	endif
	if(StepFrom<=1)
		IN3_CalculateTransmission(0)
		IN3_CalculateRWaveIntensity()			//fix the R wave 
	endif
	if(StepFrom<=2)
		IN3_calculateRwaveQvec()
		IN3_CalculateRdata()
	endif
	if(StepFrom<=3 && !IsBlank)
			// calculate transmission (can be done, we have the data now) and scale the data to it... 
		//IN3_CorrectQandTransmission()
		IN3_CalculateSampleThickness()
	endif
	if(StepFrom<=4 && !IsBlank)
	// subtract sample and Blank to create SMR data...
		IN3_CalculateCalibration()
		IN3_CalculateMSAXSCorrection()
		IN3_CalculateTransmission(1)
		IN3_RecalcSubtractSaAndBlank()
		//and store Q position for starting next time
		DoWIndow RcurvePlotGraph
		if(V_Flag)
			wave R_Int
			wave R_Qvec
			if(strlen(CsrInfo(A  ,  "RcurvePlotGraph"))>0)
				variable/g OldStartQValueForEvaluation=R_Qvec[pcsr(A  , "RcurvePlotGraph")]
			else
				variable/g OldStartQValueForEvaluation=1e-4
			endif
		endif
	endif
	setDataFolder OldDf	
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IN3_FitPeakCenterEstimate()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	
	
	NVAR PeakCenterFitStartPoint
	NVAR PeakCenterFitEndPoint
	Wave PD_Intensity
	WaveStats/Q PD_Intensity

	FindLevels/Q PD_Intensity, 0.5*V_max						//finds fitting interval
	if (V_LevelsFound==2)
		Wave W_FindLevels
		//check that we have at least 5 points...
		if((W_FindLevels[1]-W_FindLevels[0])<6)
			W_FindLevels[0]=W_FindLevels[0]-3
			if(W_FindLevels[0]<0)
				W_FindLevels[0]=0
			endif
			W_FindLevels[1]=W_FindLevels[1]+3
		endif
		PeakCenterFitStartPoint = floor(W_FindLevels[0])
		PeakCenterFitEndPoint =  ceil(W_FindLevels[1])
	else
		Wavestats /Q PD_Intensity
		PeakCenterFitStartPoint = max(0, V_maxloc - 15)
		PeakCenterFitEndPoint =  V_maxloc + 15
	endif
	KillWaves/Z W_FindLevels
	DoWindow RcurvePlotGraph
	if(V_Flag)		//set the cursors appropriately, if graph already exists
		String ExistingSubWindows=ChildWindowList("RcurvePlotGraph") 
		if(stringmatch(ExistingSubWindows,"*PeakCenter*"))
			Cursor/P/W=RcurvePlotGraph#PeakCenter A PD_Intensity PeakCenterFitStartPoint
			Cursor/P/W=RcurvePlotGraph#PeakCenter B PD_Intensity PeakCenterFitEndPoint	
		endif
	endif
	IN3_FitGaussTop("")
	
	//estimate also sample transmission, if it is sample and not Blank
	NVAR IsBlank
	if(!IsBlank)
		NVAR SampleTransmission
		NVAR SampleTransmissionPeakToPeak
		NVAR MaximumIntensity = root:Packages:Indra3:MaximumIntensity
		Wave BL_R_Int  = root:Packages:Indra3:BL_R_Int
		variable BlankMaxInt = NumberByKey("MaximumIntensity", note(BL_R_Int), "=" , ";")
		SampleTransmissionPeakToPeak = MaximumIntensity / BlankMaxInt
		SampleTransmission = MaximumIntensity / BlankMaxInt
	endif

	setDataFolder OldDf	
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************


Function IN3_calculateRwaveQvec()	//this creates log log plot for check of dark currents
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	Wave ar_encoder	
	SVAR MeasurementParameters
	SVAR specComment
	NVAR SampleAngleOffset
	NVAR SampleQOffset
	NVAR BeamCenter
	Duplicate/O ar_encoder, Qvec, R_Qvec
		IN2G_AppendorReplaceWaveNote("Qvec","Wname","Qvec") 
		IN2G_AppendorReplaceWaveNote("Qvec","Units","A-1")
	Redimension/D Qvec, R_Qvec
	NVAR wavelength
	SampleAngleOffset = 360/pi * asin((SampleQOffset*wavelength)/(4*pi))
	Qvec=((4*pi)/wavelength)*sin((pi/360)*(BeamCenter-SampleAngleOffset-ar_encoder))
	//when scanning up, need to change sign here
	if(ar_encoder[0] - ar_encoder[inf]<0)	//scanning up, end ar encoder is larger than start value
		Qvec*=-1
	endif
	R_Qvec = Qvec
	setDataFolder OldDf

End
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN3_CalculateRWaveIntensity()				//Recalculate the R wave in folder df
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	Wave PD_Range							//these waves should be here
	Wave USAXS_PD
	Wave Monitor
	Wave MeasTime
		
	Wave/Z PD_Intensity						//these waves may be new
	Wave/Z PD_Error
	if (!WaveExists(PD_Intensity))	
		Duplicate/O PD_range, PD_Intensity, PD_Error
		IN2G_AppendorReplaceWaveNote("PD_range","Wname","PD_range") 
		IN2G_AppendorReplaceWaveNote("PD_Intensity","Wname","PD_Intensity") 
		IN2G_AppendorReplaceWaveNote("PD_Error","Wname","PD_Error") 
	endif
	Redimension/D PD_Intensity				//intensity should be double precision
	
	SVAR UPDparameters					//now we need to get the dark currents and gains here
	Make/O LocalParameters = {{1e5,1e7,1e9,99e9,1e11},{3000,3000,3000,3000,3000}}
	
	LocalParameters[0][0]=numberbykey ("Gain1", UPDparameters,"=")
	LocalParameters[1][0]=numberbykey ("Gain2", UPDparameters,"=")
	LocalParameters[2][0]=numberbykey ("Gain3", UPDparameters,"=")
	LocalParameters[3][0]=numberbykey ("Gain4", UPDparameters,"=")
	LocalParameters[4][0]=numberbykey ("Gain5", UPDparameters,"=")
	LocalParameters[0][1]=numberbykey ("Bkg1", UPDparameters,"=")
	LocalParameters[1][1]=numberbykey ("Bkg2", UPDparameters,"=")
	LocalParameters[2][1]=numberbykey ("Bkg3", UPDparameters,"=")
	LocalParameters[3][1]=numberbykey ("Bkg4", UPDparameters,"=")
	LocalParameters[4][1]=numberbykey ("Bkg5", UPDparameters,"=")
	
	variable VtoFfactor=numberbykey ("Vfc", UPDparameters,"=")

	Make/O ErrorParameters={1,1,1,1,1}			//background measured error
	ErrorParameters[0]=numberbykey ("Bkg1Err", UPDparameters,"=")
	ErrorParameters[1]=numberbykey ("Bkg2Err", UPDparameters,"=")
	ErrorParameters[2]=numberbykey ("Bkg3Err", UPDparameters,"=")
	ErrorParameters[3]=numberbykey ("Bkg4Err", UPDparameters,"=")
	ErrorParameters[4]=numberbykey ("Bkg5Err", UPDparameters,"=")
	variable ii
	For(ii=0;ii<5;ii+=1)
		if (numtype(ErrorParameters[ii])!=0)		//if the background error does not exist, we will replace it with 0...
			ErrorParameters[ii]=0
		endif
	endfor
	variable I0AmpDark=numberbykey ("I0AmpDark", UPDparameters,"=")
	variable I0AmpGain=numberbykey ("I0AmpGain", UPDparameters,"=")
	if(NumType(I0AmpDark)!=0 || I0AmpDark<0)
		I0AmpDark=0
	endif 
	if(NumType(I0AmpGain)!=0 || I0AmpGain<0)		//thsi is compatible with old data. 
		I0AmpGain=1
	endif 
	Wave/Z I0_gain	
	if(!WaveExists(I0_gain))		//old code, no changes...
		PD_Intensity=(USAXS_PD - MeasTime*LocalParameters[pd_range-1][1])*(1/(VToFFactor*LocalParameters[pd_range-1][0])) /((Monitor-I0AmpDark*MeasTime)/I0AmpGain)
	else
		PD_Intensity=(USAXS_PD - MeasTime*LocalParameters[pd_range-1][1])*(1/(VToFFactor*LocalParameters[pd_range-1][0])) /((Monitor-I0AmpDark*MeasTime)/I0_gain)
	endif
	
	//OK, another incarnation of the error calculations...
	Duplicate/O PD_Error,  A
	Duplicate/O/Free PD_Error, SigmaUSAXSPD, SigmaPDwDC, SigmaRwave, SigmaMonitor, ScaledMonitor
	SigmaUSAXSPD=sqrt(USAXS_PD*(1+0.0001*USAXS_PD))		//this is our USAXS_PD error estimate, Poisson error + 1% of value
	SigmaPDwDC=sqrt(SigmaUSAXSPD^2+(MeasTime*ErrorParameters[pd_range-1])^2)		//This should be measured error for background
	SigmaPDwDC=SigmaPDwDC/(VToFFactor*LocalParameters[pd_range-1][0])
	A=(USAXS_PD)/(VToFFactor*LocalParameters[pd_range-1][0])				//without dark current subtraction
	SigmaMonitor= sqrt(Monitor)		//these calculations were done for 10^6 
	ScaledMonitor = Monitor
	SigmaRwave=sqrt((A^2*SigmaMonitor^4)+(SigmaPDwDC^2*ScaledMonitor^4)+((A^2+SigmaPDwDC^2)*ScaledMonitor^2*SigmaMonitor^2))
	SigmaRwave=SigmaRwave/(ScaledMonitor*(ScaledMonitor^2-SigmaMonitor^2))
	if(!WaveExists(I0_gain))		//old code, no changes...
		SigmaRwave*=I0AmpGain			//fix for use of I0 gain here, the numbers were too low due to scaling of PD by I0AmpGain
	else
		SigmaRwave*=I0_gain
	endif
	PD_error=SigmaRwave
	KillWaves/Z LocalParameters , ErrorParameters
//	KillWaves TempPD_Int
//	KillWaves/Z SigmaUSAXSPD, SigmaPDwDC, SigmaMonitor, SigmaRwave, A
	Duplicate/O PD_error, R_error
	Duplicate/O PD_Intensity, R_Int
	NVAR SampleTransmissionPeakToPeak=root:Packages:Indra3:SampleTransmissionPeakToPeak
	if(SampleTransmissionPeakToPeak<=0)
		SampleTransmissionPeakToPeak=1
	endif
	R_Int = PD_Intensity * SampleTransmissionPeakToPeak
	R_error = PD_error * SampleTransmissionPeakToPeak
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
