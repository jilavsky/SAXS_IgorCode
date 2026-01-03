#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3			// Use modern global access method.
  
#pragma version 1.16


//*************************************************************************\
//* Copyright (c) 2005 - 2026, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.16 another attempt to fix problem with negative intensities on some ranges (range 4 and 5) which caused issues with smoothing of blanks... 
//1.15 fixed problem when PD_range used to create MyColorWave was getting out of sync with data as points were being removed. Flyscan only, added PD_RangeModified to fix this... 
//1.14 fixed rare case when fix backgroundoversubtraction from 1.13 caused problems. In some cases early data may be negative. Now looking for negative value only in last 1/2 of the data points.  
//1.13 Modfifed IN3_RemoveDropouts to work only when adropout starts at ranges 1-4. 
//1.13 Tried to fix range 5 background oversubtraction by shifting data by needed Intensity up. Done in IN3_CalculateRWaveIntensity only when Intensity is negative due to Bckg5 subtraction
//1.12 Added smooth R data option. 
//1.11 Modifed way the range for fitting is found to handle NaNs in PD_Intensity
//1.10 added finding Qmin from FWHM of the sample peak, modified handling cases when only 1 crossing for peak fitting found. 
//1.09 removed border points to reange changes in IN3_CalculateRWaveIntensity() to try to fix problems with stickying poitns at low-q values. 
//1.08 Remove Dropout function
//1.07 minor GUI change to keep user advised about saving data
//1.06 small modification for cases when PD_error does nto exist. 
//1.05 increased slightly fitting range for the peak to improve Modified Gauss fitting stability. 
//1.04 added FlyScan code and modified fit to peak center to guess top 40% of intensity only. 
//1.03 added pinDiode tranmission
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

	//fix display in the panel to reflect saved data... 
	NVAR UserSavedData=root:Packages:Indra3:UserSavedData


	if(StepFrom==0)			//very beggining, all needs to be calculated
		IN3_CalculateRWaveIntensity(1)			//using UPD parameters recalculate the R wave intensity, 1 means it will clean up the before peak raneg changes.. 
		IN3_FitPeakCenterEstimate() 			//sets up original fit to peak center using gaussian	
	endif
	if(StepFrom<=1)
		IN3_CalculateTransmission(0)
		IN3_CalculateRWaveIntensity(0)			//fix the R wave 
	endif
	if(StepFrom<=2)
		IN3_calculateRwaveQvec()
		IN3_CalculateRdata()
	endif
	if(StepFrom<=3)
	endif
	if(StepFrom<=4 && !IsBlank)
	// subtract sample and Blank to create SMR data...
		IN3_CalculateMSAXSCorrection()
		IN3_GetDiodeTransmission(1)
		IN3_CalculateTransmission(1)
		IN3_CalcSampleWeightOrThickness()
		IN3_CalculateCalibration()
		IN3_RecalcSubtractSaAndBlank()		
		//and store Q position for starting next time
		DoWIndow RcurvePlotGraph
		if(V_Flag)
			wave R_Int
			wave R_Qvec
			if(strlen(CsrInfo(A  ,  "RcurvePlotGraph"))>0)
				variable/g OldStartQValueForEvaluation=R_Qvec[pcsr(A  , "RcurvePlotGraph")]
			else
				//lets try to set Qmin for user based on FWHM
				NVAR PeakWidth = root:Packages:Indra3:PeakWidthArcSec
				NVAR Wavelength = root:Packages:Indra3:Wavelength
				variable Qmin = 4 * pi * sin(PeakWidth*4.848e-6 /2) / Wavelength
				variable/g OldStartQValueForEvaluation=Qmin			
			endif
		endif
	endif
	UserSavedData = 0
	setDataFolder OldDf	
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IN3_SmoothRData()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	Wave Intensity= root:Packages:Indra3:R_Int
	Wave Qvector= root:Packages:Indra3:Qvec
	Wave PD_range = root:Packages:Indra3:PD_range
	Wave R_Error = root:Packages:Indra3:R_Error
	Wave MeasTime = root:Packages:Indra3:MeasTime
	NVAR SmoothRCurveData = root:Packages:Indra3:SmoothRCurveData
	if(SmoothRCurveData)
		//firs remove NaNs as this is really difficult to deal with...
		Duplicate/Free PD_range, tmpPD_range
		Duplicate/Free MeasTime, tmpMeasTime		
		//IN2G_RemoveNaNsFrom5Waves(Intensity, Qvector,R_Error,tmpPD_range, tmpMeasTime)
		//smooth Blank_R using smoothing times for different ranges. 
		variable tmpTime, StartPoints
		variable EndPoints, QrangeIntg, midPoint, startX, endX
		Duplicate /Free  Intensity, TempIntLog
		TempIntLog = log(Intensity)
		Duplicate/Free TempIntLog, SmoothIntensity
		variable i
		For(i=40;i<numpnts(Intensity);i+=1)
			if(tmpPD_range[i]==1)
				tmpTime = RwaveSmooth1time
			elseif(tmpPD_range[i]==2)
				tmpTime = RwaveSmooth2time
			elseif(tmpPD_range[i]==3)
				tmpTime = RwaveSmooth3time
			elseif(tmpPD_range[i]==4)
				tmpTime = RwaveSmooth4time
			else
				tmpTime = RwaveSmooth5time
			endif	
			if(tmpMeasTime[i]>tmpTime)		//no need to smooth
				SmoothIntensity[i] = TempIntLog[i]
			else //need to smooth
				//somehow we need to stay within one range also... 				
				StartPoints = ceil(tmpTime/tmpMeasTime[i])+1
				EndPoints = StartPoints
				if((i-StartPoints)<1)
					abort "Bad data, cannot fix this. Likely Flyscan parameters were wrong" 
				endif
				if(i+EndPoints > numpnts(Intensity)-1)		//do not run out of end of data set
					EndPoints = numpnts(Intensity)- 1 - i
				endif
				//if (i==118)
				//	debugger
				//endif
				if((tmpPD_range[i-StartPoints]!=tmpPD_range[i])||(tmpPD_range[i+EndPoints]!=tmpPD_range[i]))
					//range change, do not average, use line fitting to get the point... 
					Duplicate/Free/R=[i-StartPoints,i+EndPoints-1] TempIntLog, tempR
					 Duplicate/FREE/R=[i-StartPoints,i+EndPoints-1] Qvector, tempQ

					WaveStats /Q tempR
					if(V_npnts>V_numNans+5)
						CurveFit/Q line tempR /X=tempQ 
						Wave W_coef
						SmoothIntensity[i] = W_coef[0]+W_coef[1]*Qvector[i]
						R_Error[i]=R_Error[i]/3
					else
						SmoothIntensity[i] = TempIntLog[i]
						R_Error[i]=R_Error[i]		//crude approximation
					endif
				else	//R must be symmetric around the i or the method below will not work right. 
					Duplicate/Free/R=[i-StartPoints,i+EndPoints] TempIntLog, tempR
					 Duplicate/FREE/R=[i-StartPoints,i+EndPoints] Qvector, tempQ
					startX =  tempQ[0] 
					endX =  tempQ[numpnts(tempQ)-1]
					SmoothIntensity[i] = areaXY(tempQ, tempR, startX,endX)
					SmoothIntensity[i] /= (endX - startX)
					R_Error[i]=R_Error[i]		//crude approximation
				endif
			endif	
		endfor
		Intensity = 10^SmoothIntensity
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
	variable NumP
	WaveStats/Q PD_Intensity

	FindLevels/Q PD_Intensity, 0.53*V_max						//finds fitting interval
	if (V_LevelsFound==2)
		Wave W_FindLevels
		//check that we have at least 5 points...
		if((W_FindLevels[1]-W_FindLevels[0])<6)
			NumP= (6-(W_FindLevels[1]-W_FindLevels[0]))/2
			W_FindLevels[0]=W_FindLevels[0]-NumP
			if(W_FindLevels[0]<0)
				W_FindLevels[0]=0
			endif
			W_FindLevels[1]=W_FindLevels[1]+NumP
		endif
		PeakCenterFitStartPoint = floor(W_FindLevels[0])
		PeakCenterFitEndPoint =  ceil(W_FindLevels[1])
//	elseif(V_LevelsFound==1)		//found just one level. 
//		Wave W_FindLevels
//		PeakCenterFitStartPoint = 1
//		PeakCenterFitEndPoint =  ceil(W_FindLevels[0])
//	else
//		Wavestats /Q PD_Intensity
//		PeakCenterFitStartPoint = max(0, V_maxloc - 15)
//		PeakCenterFitEndPoint =  V_maxloc + 15
	elseif(V_LevelsFound<2)		//found just one or no level. 
	 	PeakCenterFitStartPoint =  IN3_FindlevelsWithNaNs(PD_Intensity, 0.53*V_max, V_maxloc, 0)
	 	PeakCenterFitEndPoint = IN3_FindlevelsWithNaNs(PD_Intensity, 0.53*V_max, V_maxloc, 1)
	endif
	KillWaves/Z W_FindLevels
	DoWindow RcurvePlotGraph
	if(V_Flag)		//set the cursors appropriately, if graph already exists
		String ExistingSubWindows=ChildWindowList("RcurvePlotGraph") 
		if(stringmatch(ExistingSubWindows,"*PeakCenter*"))
			Cursor/P/W=RcurvePlotGraph#PeakCenter A, PD_Intensity, PeakCenterFitStartPoint
			Cursor/P/W=RcurvePlotGraph#PeakCenter B, PD_Intensity, PeakCenterFitEndPoint	
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
//******************** name **************************************
//STATIC Function IN3_FindlevelsWithNaNs(waveIn, LevelSearched, MaxLocation, LeftRight)
//	wave waveIn
//	variable LevelSearched, MaxLocation, LeftRight
//	//set LeftRight to 0 for left and 1 for right of the MaxLocation
//	variable LevelPoint = 0
//	variable counter = MaxLocation
//	variable Done=0
//	Do
//		if(LeftRight)
//			counter+=1
//		else
//			counter-=1
//		endif
//		if(numtype(waveIn[counter])==0)
//			LevelPoint = counter
//			if(waveIn[counter]>LevelSearched && counter>0 && Counter<numpnts(WaveIn)) //fix when cannot reach 50% or less value... 
//				LevelPoint = counter
//			else
//				Done=1
//			endif
//		endif	
//	while (Done<1)	
//	return LevelPoint	
//end
//
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************


Function IN3_calculateRwaveQvec()	//this creates log log plot for check of dark currents
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	Wave/Z ar_encoder	
	if(!WaveExists(ar_encoder))
		abort
	endif
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

Function IN3_CalculateRWaveIntensity(CleanUpRangeCHange)				//Recalculate the R wave in folder df
	variable CleanUpRangeCHange
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	Wave/Z PD_Range							//these waves should be here
	if(!WaveExists(PD_Range))
		abort 
	endif
	Wave USAXS_PD
	Wave Monitor
	Wave MeasTime
	Wave Ar_encoder
	
//	if (!WaveExists(PD_Intensity) || !WaveExists(PD_Error))	
	Duplicate/O PD_range, PD_Intensity, PD_Error
	IN2G_AppendorReplaceWaveNote("PD_range","Wname","PD_range") 
	IN2G_AppendorReplaceWaveNote("PD_Intensity","Wname","PD_Intensity") 
	IN2G_AppendorReplaceWaveNote("PD_Error","Wname","PD_Error") 
//	endif
	Wave PD_Intensity						//these waves may be new
	Wave PD_Error
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

	//need to remove bad points caused by range changes at low qs here... 
	if(CleanUpRangeCHange)	//to be done ONLY in the beggining step, not later... 
		PD_Intensity [1,numpnts(pd_range)-2] = ((pd_range[p+1]-pd_range[p])<-0.5 || (pd_range[p]-pd_range[p-1])<-0.5) ? nan : PD_Intensity
	endif
	//this will simply set border points to range changes nan and they should get later removed. 
	//this is not set to remove points ONLY if we cahnge from higher gain to lower gain, not in the other direction
	//OK, another incarnation of the error calculations...
	Duplicate/Free PD_Error,  A
	Duplicate/Free PD_Error, SigmaUSAXSPD, SigmaPDwDC, SigmaRwave, SigmaMonitor, ScaledMonitor
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
	PD_error=SigmaRwave/5		//2025-04 these values are simply too large on new APS-U USAXS instrument
	KillWaves/Z LocalParameters , ErrorParameters

	//fix oversubtraction of PD_Intensity here?
	IN3_FixNegativeIntensities(PD_Intensity)
	IN3_FixZeroUncertainties(PD_error)
	KillWaves/Z R_error,R_Int
	Duplicate/O PD_error, R_error
	Duplicate/O PD_Intensity, R_Int
	NVAR SampleTransmissionPeakToPeak=root:Packages:Indra3:SampleTransmissionPeakToPeak
	if(SampleTransmissionPeakToPeak<=0)
		SampleTransmissionPeakToPeak=1
	endif
	IN3_RemoveDropouts(Ar_encoder,MeasTime,Monitor,PD_range,USAXS_PD, PD_Intensity,PD_error)
	
	
	R_Int = PD_Intensity * SampleTransmissionPeakToPeak
	R_error = PD_error * SampleTransmissionPeakToPeak
	//now remove dropouts if needed...
	setDataFolder OldDf	
end
///*********************************************************************************
///*********************************************************************************
Function IN3_FixNegativeIntensities(waveIn)
	wave WaveIn
	//fix oversubtraction of WaveIn here?
	wavestats/Q WaveIn
	variable MaxValue = V_max
	wavestats/Q/R=[numpnts(WaveIn)/2,numpnts(WaveIn)-1 ] WaveIn
	if(V_min<0)
		WaveIn+=Indra_PDIntBackFixScaleVmin*abs(V_min)+MaxValue*Indra_PDIntBackFixScaleVmax
		//print "Fixed USAXS Range 5 background subtraction by Intensity = Intensity + "+num2str(1.05*abs(V_min)+V_max*1e-10)
	endif
end
//*********************************************************************************
///*********************************************************************************

Function IN3_FixZeroUncertainties(PD_error)
	wave PD_error
	//fix zero values of uncertaitnies here... 
	Duplicate/Free PD_error, tempWv
	tempWv = (tempWv>0) ? tempWv : nan
	wavestats/Q tempWv
	variable minErr=V_min
	PD_error = (PD_error>0) ? PD_error : minErr

end

//*********************************************************************************
///*********************************************************************************
Function IN3_RemoveDropouts(Ar_encoder,MeasTime,Monitor,PD_range,USAXS_PD, R_Int,R_error)
	WAVE Ar_encoder,MeasTime,Monitor,PD_range, USAXS_PD, R_Int,R_error
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Indra3

	NVAR RemoveDropouts =root:Packages:Indra3:RemoveDropouts
	NVAR RemoveDropoutsTime =root:Packages:Indra3:RemoveDropoutsTime
	NVAR RemoveDropoutsFraction =root:Packages:Indra3:RemoveDropoutsFraction
	NVAR RemoveDropoutsAvePnts =root:Packages:Indra3:RemoveDropoutsAvePnts
	variable i, DropoutIndex, j, tmpTime, totPnts
	NVAR Wavelength = root:Packages:Indra3:Wavelength
	if(RemoveDropouts>0)
		//this method will work only above Q~0.0002, q = 4pi sin(theta)/Wavelength, AR=(q*Wavelength/4*pi)/2
		wavestats/Q R_Int
		variable Ar_Start=	 BinarySearch(Ar_encoder, Ar_encoder[V_maxloc]-2*asin(0.008*Wavelength/(4*pi)))
		Duplicate/Free 	R_Int, tmpR_Int, R_Int_smth, R_Int_div
		Smooth/M=0 RemoveDropoutsAvePnts, R_Int_smth
		R_Int_div = tmpR_Int/ R_Int_smth
		KillWaves/Z W_FindLevels
		FindLevels /B=1 /EDGE=2 /M=0 /P/Q/R=[Ar_Start,numpnts(R_Int_div)-1] R_Int_div, RemoveDropoutsFraction
		Wave/Z W_FindLevels 
		if(WaveExists(W_FindLevels))
			For(i=0;i<numpnts(W_FindLevels);i+=1)
				DropoutIndex = round(W_FindLevels[i])
			//	print "Found dropout at point number "+num2str(DropoutIndex)
			//only modify if this is at gain hignher than 5
				if(PD_range[DropoutIndex-10]<5)
					tmpTime=RemoveDropoutsTime/2
					j=DropoutIndex
					totPnts=0
					do
						R_Int[j]=nan
						tmpTime-=MeasTime[j]
						j-=1
						totPnts+=1
					while(tmpTime>0 && j>0)
					tmpTime=RemoveDropoutsTime/2
					j=DropoutIndex
					do
						R_Int[j]=nan
						tmpTime-=MeasTime[j]
						j+=1
						totPnts+=1
					while(tmpTime>0 && j<(numpnts(R_Int)-1))
				endif
			//	print "Removed "+Num2str(totPnts)+" around the found point at "+num2str(DropoutIndex)
			endfor
		endif
	endif
	//IN2G_RemoveNaNsFrom7Waves(Ar_encoder,MeasTime,Monitor,PD_range, USAXS_PD, R_Int,R_error)			//is this correct???
	
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
