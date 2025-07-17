#pragma rtFunctionErrors = 1
#pragma TextEncoding     = "UTF-8"
#pragma rtGlobals        = 3          // Use modern global access method and strict wave access
#pragma DefaultTab       = {3, 20, 4} // Set default tab width in Igor Pro 9 and later

// here belongs all the code for new data reduction, basically, what is Matilda doing for reduction.
// it should not depend on any other Indra old reduction code, but may depend on Nika.

//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN4_CalculateRWaveIntensity(string FolderName) //Recalculate the R wave in folder df

	DFREF oldDf = GetDataFolderDFR()
	setDataFolder $(FolderName)
	//contains stuff from: IN3_FSConvertToUSAXS
	//assume we are using DDPCA300 for now.
	//these waves exist:
	WAVE AmpGain     //		WAVE DDPCA300_ampGain    = :entry:flyScan:changes_DDPCA300_ampGain
	WAVE AmpReqGain  //		WAVE DDPCA300_ampReqGain = :entry:flyScan:changes_DDPCA300_ampReqGain
	WAVE Channel     //		WAVE DDPCA300_mcsChan    = :entry:flyScan:changes_DDPCA300_mcsChan
	NVAR vTof        //		mcaFrequency        = :entry:flyScan:mca_clock_frequency, 1 point.
	NVAR FS_scanTime //		total scan timne, 1 point

	WAVE ARangles     // Ar in degrees, used to be caled AR_encoder
	WAVE Monitor      // I0 counts per point.
	WAVE TimePerPoint // this is in frequency, divide by 1e6 to get seconds
	WAVE UPD_array    // for sanity, create also version called what we used always.
	Duplicate/O UPD_array, USAXS_PD

	Duplicate/O TimePerPoint, MeasTime
	MeasTime /= vTof //convert to seconds, MCA frequency is 1e6 which is fixed in import.

	SVAR metadata //contains list below:
	// DDPCA300_gain0=10000;DDPCA300_gain1=1e+06;DDPCA300_gain2=1e+08;DDPCA300_gain3=1e+10;DDPCA300_gain4=1e+12;I0AmpGain=1e+07;
	// UPDsize=5.4;detector_distance=1053;timeStamp=2025-06-12 10:11:52.485267;trans_I0_counts=1.7857e+05
	// upd_amp_change_mask_time0=0.02;upd_amp_change_mask_time1=0.02;upd_amp_change_mask_time2=0.03;upd_amp_change_mask_time3=0.1;
	// upd_amp_change_mask_time4=0.4;upd_bkg0=5;upd_bkg1=5;upd_bkg2=7;upd_bkg3=1940;upd_bkg4=1.9432e+05;upd_bkgErr0=0;upd_bkgErr1=0;
	// upd_bkgErr2=2.4495;upd_bkgErr3=30.822;upd_bkgErr4=5764.2;I0Gain=1e+07
	make/FREE/N=5 TimeRangeAfterUPD
	TimeRangeAfterUPD = {NumberByKey("upd_amp_change_mask_time0", metadata, "=", ";"),                                                               \
	                     NumberByKey("upd_amp_change_mask_time1", metadata, "=", ";"), NumberByKey("upd_amp_change_mask_time2", metadata, "=", ";"), \
	                     NumberByKey("upd_amp_change_mask_time3", metadata, "=", ";"), NumberByKey("upd_amp_change_mask_time4", metadata, "=", ";")}
	TimeRangeAfterUPD = (TimeRangeAfterUPD[p] > 0.01) ? TimeRangeAfterUPD[p] : 0.01

	Duplicate/O TimePerPoint, PD_range
	IN4_FSCreateGainWave(PD_range, AmpReqGain, AmpGain, Channel, TimeRangeAfterUPD, MeasTime)
	//now we have PD_range, MeasTime, Monitor (I0 counts/point)
	//create I0gain wave
	Duplicate/O TimePerPoint, I0gain
	Duplicate/FREE TimePerPoint, UPD_backgrounds, UPD_gains, UPD_backerrs
	variable i
	//this is stupid...
	variable gain0, gain1, gain2, gain3, gain4
	variable updbckg0, updbckg1, updbckg2, updbckg3, updbckg4
	variable updbckgerr0, updbckgerr1, updbckgerr2, updbckgerr3, updbckgerr4
	gain0       = NumberByKey("DDPCA300_gain0", metadata, "=", ";")
	gain1       = NumberByKey("DDPCA300_gain1", metadata, "=", ";")
	gain2       = NumberByKey("DDPCA300_gain2", metadata, "=", ";")
	gain3       = NumberByKey("DDPCA300_gain3", metadata, "=", ";")
	gain4       = NumberByKey("DDPCA300_gain4", metadata, "=", ";")
	updbckg0    = NumberByKey("upd_bkg0", metadata, "=", ";")
	updbckg1    = NumberByKey("upd_bkg1", metadata, "=", ";")
	updbckg2    = NumberByKey("upd_bkg2", metadata, "=", ";")
	updbckg3    = NumberByKey("upd_bkg3", metadata, "=", ";")
	updbckg4    = NumberByKey("upd_bkg4", metadata, "=", ";")
	updbckgerr0 = NumberByKey("upd_bkgErr0", metadata, "=", ";")
	updbckgerr1 = NumberByKey("upd_bkgErr1", metadata, "=", ";")
	updbckgerr2 = NumberByKey("upd_bkgErr2", metadata, "=", ";")
	updbckgerr3 = NumberByKey("upd_bkgErr3", metadata, "=", ";")
	updbckgerr4 = NumberByKey("upd_bkgErr4", metadata, "=", ";")
	//NOTE:PD_range is 1-5, but all other things are 0-4, so we need to offset this by 1 or things will nto work.
	for(i = 0; i < numpnts(UPD_backgrounds); i += 1)
		if(PD_range[i] == 1)
			UPD_backgrounds[i] = updbckg0
			UPD_gains[i]       = gain0
			UPD_backerrs[i]    = updbckgerr0
		elseif(PD_range[i] == 2)
			UPD_backgrounds[i] = updbckg1
			UPD_gains[i]       = gain1
			UPD_backerrs[i]    = updbckgerr1
		elseif(PD_range[i] == 3)
			UPD_backgrounds[i] = updbckg2
			UPD_gains[i]       = gain2
			UPD_backerrs[i]    = updbckgerr2
		elseif(PD_range[i] == 4)
			UPD_backgrounds[i] = updbckg3
			UPD_gains[i]       = gain3
			UPD_backerrs[i]    = updbckgerr3
		elseif(PD_range[i] == 5)
			UPD_backgrounds[i] = updbckg4
			UPD_gains[i]       = gain4
			UPD_backerrs[i]    = updbckgerr4
		else
			UPD_backgrounds[i] = NaN
			UPD_gains[i]       = NaN
			UPD_backerrs[i]    = NaN
		endif
	endfor
	I0gain = NumberByKey("I0AmpGain", metadata, "=", ";")
	// now create PD_Intensity
	Duplicate/O USAXS_PD, PD_Intensity, PD_Error
	variable I0AmpDark = 0 //TODO: record dark current of I0 at different gains. This needs lot mroe work on instrument side.
	//this is UPD counts - Meastime*background, divided by gains, and that divided by same signal for I0.
	PD_Intensity = ((USAXS_PD - MeasTime * UPD_backgrounds) / (vTof * UPD_gains)) / ((Monitor - I0AmpDark * MeasTime) / (I0gain))
	//PD_Intensity=(USAXS_PD - MeasTime*LocalParameters[pd_range-1][1])*(1/(VToFFactor*LocalParameters[pd_range-1][0])) /((Monitor-I0AmpDark*MeasTime)/I0AmpGain)

	//OK, another incarnation of the error calculations...
	Duplicate/FREE PD_Error, Awave
	Duplicate/FREE PD_Error, SigmaUSAXSPD, SigmaPDwDC, SigmaRwave, SigmaMonitor, ScaledMonitor
	SigmaUSAXSPD  = sqrt(USAXS_PD * (1 + 0.0001 * USAXS_PD))           //this is our USAXS_PD error estimate, Poisson error + 1% of value
	SigmaPDwDC    = sqrt(SigmaUSAXSPD^2 + (MeasTime * UPD_backerrs)^2) //This should be measured error for background
	SigmaPDwDC    = SigmaPDwDC / (vTof * UPD_gains)
	Awave         = (USAXS_PD) / (vTof * UPD_gains)                    //without dark current subtraction
	SigmaMonitor  = sqrt(Monitor)                                      //these calculations were done for 10^6
	ScaledMonitor = Monitor
	SigmaRwave    = sqrt((Awave^2 * SigmaMonitor^4) + (SigmaPDwDC^2 * ScaledMonitor^4) + ((Awave^2 + SigmaPDwDC^2) * ScaledMonitor^2 * SigmaMonitor^2))
	SigmaRwave    = SigmaRwave / (ScaledMonitor * (ScaledMonitor^2 - SigmaMonitor^2))
	SigmaRwave   *= I0gain
	PD_error      = SigmaRwave / 5                                     //2025-04 these values are simply too large on new APS-U USAXS instrument

	//fix oversubtraction of PD_Intensity here?
	IN4_FixNegativeIntensities(PD_Intensity)
	IN4_FixZeroUncertainties(PD_error)
	Duplicate/O PD_error, R_error
	Duplicate/O PD_Intensity, R_Int
	//this cannot be done here yet, we need to calculate transmission first.
	//TODO: do this later.
	//	NVAR SampleTransmissionPeakToPeak=root:Packages:Indra3:SampleTransmissionPeakToPeak
	//	if(SampleTransmissionPeakToPeak<=0)
	//		SampleTransmissionPeakToPeak=1
	//	endif
	//
	//
	//	R_Int = PD_Intensity * SampleTransmissionPeakToPeak
	//	R_error = PD_error * SampleTransmissionPeakToPeak
	setDataFolder OldDf
End
///*********************************************************************************
///*********************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN4_calculateR_Qvec(string FolderName) //this creates Q vector for R data

	DFREF oldDf = GetDataFolderDFR()
	setDataFolder $(FolderName)

	WAVE/Z ARangles
	WAVE/Z R_Int
	WAVE/Z R_error
	if(!WaveExists(ARangles) || !WaveExists(R_Int) || !WaveExists(R_error))
		abort
	endif
	//we need to get some other stuff
	SVAR metadata
	SVAR instrument
	variable wavelength  = NumberByKey("wavelength", instrument, "=", ";")
	variable ARcenterEst = NumberByKey("AR_center", metadata, "=", ";")
	Duplicate/O ARangles, R_Qvec
	//need to do peak fitting here. That will give us bunch of new numbers we need to store somewhere. Add to metadata?
	variable beamCenter = IN4_FitR_dataTop(folderName)
	// now make some decision when to use beamCenter instead of tabulated values.
	// returns NaN if fit fails, may be we need to stop here
	if(numtype(beamCenter) != 0)
		Abort "Failure in peak center fitting in IN4_calculateR_Qvec for :" + FolderName
	endif
	//check that we are sufficnetly close and nothing else failed too much. Assume we need to be within 0.01 deg from estimate?
	if(abs(beamcenter - ARcenterEst) > 0.02)
		Print "Fitting resulted in large difference between USAXS beam center and measured beam center. Warning"
		print "using planned beam center, not fitted result"
		beamcenter = ARcenterEst
	endif
	//For now, let's use nexus beam center
	R_Qvec = ((4 * pi) / wavelength) * sin((pi / 360) * (beamcenter - ARangles))
	if((ARangles[0] - ARangles[Inf]) < 0) //scanning up, end ar encoder is larger than start value
		R_Qvec *= -1
	endif
	IN2G_AppendorReplaceWaveNote("R_Qvec", "Wname", "R_Qvec")
	IN2G_AppendorReplaceWaveNote("R_Qvec", "Units", "A-1")
	setDataFolder OldDf

End
///**********************************************************************************************************
///**********************************************************************************************************

Function IN4_FitR_dataTop(string folderName)

	//	NVAR UseModifiedGauss
	//	NVAR UseGauss
	//	NVAR UseLorenz
	variable beamCenter

	//
	//	if(UseModifiedGauss)
	beamCenter = IN4_FitModGaussTop(Foldername)
	//	elseif(UseGauss)
	//		IN3_FitGaussTop("")
	//	elseif(UseLorenz)
	//		IN3_FitLorenzianTop("")
	//	else
	//		Abort "No default fiting method selected, please restart the tool"
	//
	//	endif
	return beamCenter
End
//**********************************************************************************************************
//**********************************************************************************************************
///**********************************************************************************************************
///**********************************************************************************************************

Function IN4_FitModGaussTop(string Foldername) // uses Modfied Gaussian

	DFREF oldDf = GetDataFolderDFR()
	setDataFolder $(FolderName)

	variable ARcenter
	WAVE     R_Int
	WAVE     R_Error
	WAVE     ARangles
	SVAR     metadata
	variable ARcenterEst = NumberByKey("AR_center", metadata, "=", ";")

	MAKE/O/D/N=4 W_coef
	//find range of 50% in below and above peak.
	wavestats/Q R_Int
	FindLevels/N=25/P/Q R_Int, V_max / 2
	WAVE W_FindLevels
	variable startPointL, endPointL
	if(Numpnts(W_FindLevels) == 2)
		startPointL = W_FindLevels[0]
		endPointL   = W_FindLevels[1]
	elseif(Numpnts(W_FindLevels) > 2)
		FindLevel/P/Q W_FindLevels, V_maxloc
		startPointL = W_FindLevels[floor(V_LevelX)]
		endPointL   = W_FindLevels[ceil(V_LevelX)]
	elseif(Numpnts(W_FindLevels) < 2) //only one or no crossing found? this happens when NaNs are in the waves
		startPointL = IN4_FindlevelsWithNaNs(R_Int, V_max / 2, V_maxloc, 0)
		endPointL   = IN4_FindlevelsWithNaNs(R_Int, V_max / 2, V_maxloc, 1)
	endif
	variable PeakCenterFitStartPoint = startPointL
	variable PeakCenterFitEndPoint   = endPointL
	//set W_coef wave
	W_Coef[0] = V_max
	//W_coef[1]=ARangles[V_maxloc]
	W_coef[1] = ARcenterEst //lets assume this is better? Should not depend on Multiple scattering
	W_coef[2] = abs(ARangles[startPointL] - ARangles[endPointL]) / (2 * (2 * ln(2))^0.5)
	W_coef[3] = 2
	Make/O/T/N=3 T_Constraints
	T_Constraints[0] = {"K3>1.3"}
	T_Constraints[1] = {"K3<3"}
	T_Constraints[2] = {"K2<0.0006"}
	variable V_FitError = 0
	FuncFit/Q/N IN4_ModifiedGauss, W_coef, R_Int[PeakCenterFitStartPoint, PeakCenterFitEndPoint]/X=ARangles/D/W=R_error/I=1/C=T_Constraints //Gauss
	//FuncFit/Q/L=50  IN3_ModifiedGauss W_coef PD_Intensity [startPointL,endPointL]  /X=Ar_encoder /D /W=PD_error /I=1 /C=T_Constraints 	//Gauss
	if(V_FitError > 0)
		return NaN
		//abort "Peak profile fitting function error. Please select wider range of data or change fitting function (Gauss is good choice)"
	endif
	WAVE W_coef
	WAVE W_sigma
	WAVE fit_R_Int
	Duplicate/O fit_R_Int, PeakFitWave
	//variables to work with
	variable MaximumIntensity
	variable PeakWidth
	variable PeakWidthArcSec
	variable ARCenterError, MaximumIntensityError, PeakWidthError
	//calculate the fit curve for inspection
	//SetScale /I x, ARangles[PeakCenterFitStartPoint], ARangles[PeakCenterFitEndPoint], PeakFitWave		//set scale to range of fitted angles
	//PeakFitWave= IN4_ModifiedGauss(W_coef, x)										//W_coef[0]*exp(-0.5*(abs(x-W_coef[1])/W_coef[2])^W_coef[3])
	//read values to variables for comprehension
	ARcenter              = W_coef[1]
	ARCenterError         = W_sigma[1]
	MaximumIntensity      = W_coef[0]
	MaximumIntensityError = W_sigma[0]
	PeakWidth             = 2 * W_coef[2] * (2 * ln(2))^(1 / W_coef[3])
	PeakWidthArcSec       = PeakWidth * 3600
	PeakWidthError        = 0 //2*W_sigma[2]*(2*ln(2))^(1/W_sigma[3])...........need to calcualte approximate value in the future...

	//append results to metadata for future use...
	metadata = ReplaceStringByKey("PeakFitFunction", metadata, "Modified Gauss", "=", ";")
	metadata = ReplaceStringByKey("ARcenterFit", metadata, num2str(ARcenter, "%.10g"), "=", ";")
	metadata = ReplaceStringByKey("ARcenterFitError", metadata, num2str(ARcenterError, "%.10g"), "=", ";")
	metadata = ReplaceStringByKey("MaximumIntensity", metadata, num2str(MaximumIntensity, "%.10g"), "=", ";")
	metadata = ReplaceStringByKey("MaximumIntensityError", metadata, num2str(MaximumIntensityError, "%.10g"), "=", ";")
	metadata = ReplaceStringByKey("FWHM", metadata, num2str(PeakWidthArcSec, "%.10g"), "=", ";")
	metadata = ReplaceStringByKey("FWHM_Error", metadata, num2str(PeakWidthError, "%.10g"), "=", ";")

	//append to R waves also.
	WAVE/Z R_Qvec
	if(WaveExists(R_Qvec))
		string ListOfWaveNames = "R_Qvec;R_Int;R_Error;"
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames, "PeakFitFunction", "Modified Gauss")
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames, "ARcenterFit", num2str(ARcenter))
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames, "ARcenterFitError", num2str(ARcenterError))
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames, "MaximumIntensity", num2str(MaximumIntensity))
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames, "MaximumIntensityError", num2str(MaximumIntensityError))
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames, "FWHM", num2str(PeakWidth * 3600))
		IN2G_AppendNoteToListOfWaves(ListOfWaveNames, "FWHM_Error", num2str(PeakWidthError * 3600))
	endif
	KillWaves/Z T_Constraints, W_sigma, W_FindLevels, W_coef, fit_R_Int, fitX_R_Int

	setDataFolder OldDf
	return ARcenter
End
//******************** Modified Gauss **************************************

Function IN4_ModifiedGauss(WAVE w, variable xvar) : FitFunc

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

	return w[0] * exp(-0.5 * (abs(xvar - w[1]) / w[2])^w[3])
End

//******************** name **************************************
//******************** name **************************************
//******************** name **************************************
Function IN4_CopyBlankAndCorrectTransm(string SamplefolderName, string BlankFolderName)

	DFREF oldDf = GetDataFolderDFR()
	setDataFolder $(SamplefolderName)
	//we need to get transmisison measurements and apply them to data.
	//here we will first copy Blank R_data as BL_R_data to Sample folder
	//we will calculate peak - peak transmission and correct sample data
	WAVE/Z Blank_R_Int = $(BlankFolderName + ":R_Int")
	if(!WaveExists(Blank_R_Int))
		ABort "Blank Data do not exist"
	endif
	WAVE Blank_R_Qvec  = $(BlankFolderName + ":R_Qvec")
	WAVE Blank_R_Error = $(BlankFolderName + ":R_Error")
	Duplicate/O Blank_R_Int, BL_R_Int
	Duplicate/O Blank_R_Qvec, BL_R_Qvec
	Duplicate/O Blank_R_Error, BL_R_Error
	SVAR blankname
	SVAR BlankOrgName = $(BlankFolderName + ":filename")
	blankname = BlankOrgName
	//now peak to peak transmission
	SVAR BlankMetadata  = $(BlankFolderName + ":metadata")
	SVAR samplemetadata = metadata
	//trans_I0_counts=178274;trans_I0_gain=10000000;trans_pin_counts=453835;trans_pin_gain=100000
	variable BlankTRUPD      = NumberByKey("trans_pin_counts", BlankMetadata, "=", ";")
	variable BlankTRUPDGain  = NumberByKey("trans_pin_gain", BlankMetadata, "=", ";")
	variable BlankTRI0       = NumberByKey("trans_I0_counts", BlankMetadata, "=", ";")
	variable BlankTRI0Gain   = NumberByKey("trans_I0_gain", BlankMetadata, "=", ";")
	variable SampleTRUPD     = NumberByKey("trans_pin_counts", SampleMetadata, "=", ";")
	variable SampleTRUPDGain = NumberByKey("trans_pin_gain", SampleMetadata, "=", ";")
	variable SampleTRI0      = NumberByKey("trans_I0_counts", SampleMetadata, "=", ";")
	variable SampleTRI0Gain  = NumberByKey("trans_I0_gain", SampleMetadata, "=", ";")
	variable Tranmsission    = ((SampleTRUPD / SampleTRUPDGain) / (SampleTRI0 / SampleTRI0Gain)) / ((BlankTRUPD / BlankTRUPDGain) / (BlankTRI0 / BlankTRI0Gain))
	WAVE R_Int
	WAVE R_Error
	R_Int   = R_Int / Tranmsission
	R_Error = R_Error / Tranmsission
	IN2G_AppendorReplaceWaveNote("R_Int", "Transmission", num2str(Tranmsission))
	IN2G_AppendorReplaceWaveNote("R_Error", "Transmission", num2str(Tranmsission))
	variable BlankWidth         = NumberByKey("FWHM", BlankMetadata, "=", ";") //FWHM=1.776734226 (arc sec)
	variable BLMaximumIntensity = NumberByKey("MaximumIntensity", BlankMetadata, "=", ";")
	samplemetadata = ReplaceStringByKey("Transmission", samplemetadata, num2str(Tranmsission, "%.10g"), "=", ";")
	samplemetadata = ReplaceStringByKey("BlankWidth", samplemetadata, num2str(BlankWidth, "%.10g"), "=", ";")
	samplemetadata = ReplaceStringByKey("BlankMaximumIntensity", samplemetadata, num2str(BLMaximumIntensity, "%.10g"), "=", ";")

	setDataFolder OldDf
End

//
//******************** name **************************************
Function IN4_SubtractSampleAndBlank(string Foldername)

	// Subtracts Peak-to-Peak corrected R_data, calibrates to geometry and MSAXS

	DFREF oldDf = GetDataFolderDFR()
	setDataFolder $(FolderName)
	WAVE/Z BL_R_Int
	WAVE/Z R_Int
	if(!WaveExists(R_Int) || !WaveExists(BL_R_Int))
		abort "Subtract Sample and Blank is missing some data"
	endif
	WAVE     R_Qvec
	WAVE     R_Error
	WAVE     BL_R_Qvec
	WAVE     BL_R_Error
	SVAR     metadata
	variable MSAXSCorrection
	variable USAXSPinTvalue = NumberByKey("Transmission", metadata, "=", ";") //this is TR diode calculated value.
	variable SampleTransmissionPeakToPeak
	variable MaximumIntensity      = NumberByKey("MaximumIntensity", metadata, "=", ";")
	variable BlankMaximumIntensity = NumberByKey("BlankMaximumIntensity", metadata, "=", ";")
	variable BlankWidth            = NumberByKey("BlankWidth", metadata, "=", ";")
	SVAR instrument
	variable Wavelength = NumberByKey("Wavelength", instrument, "=", ";")
	SampleTransmissionPeakToPeak = MaximumIntensity / BlankMaximumIntensity
	MSAXSCorrection              = USAXSPinTvalue / SampleTransmissionPeakToPeak //this is really for information only, accounted for by use of Pindiode transmission
	variable InstrumentQresolution = 2 * pi * sin(BlankWidth / 3600 * pi / 180) / Wavelength
	//calculate Kfactor
	//	OmegaFactor= (PhotoDiodeSize/SampleToDetectorDistance)*(BLPeakWidthL/3600)*(pi/180)
	//	Kfactor=BLPeakMax*OmegaFactor 				// *SampleThickness*0.1  ; 0.1 converts the thickness of sample from mm to cm
	variable UPDsize = NumberByKey("UPDsize", metadata, "=", ";")
	SVAR sample
	variable SampleThickness   = NumberByKey("thickness", sample, "=", ";")
	variable detector_distance = NumberByKey("detector_distance", metadata, "=", ";")
	variable OmegaFactor       = (UPDsize / detector_distance) * (BlankWidth / 3600) * (pi / 180)
	variable Kfactor           = BlankMaximumIntensity * OmegaFactor
	//for volume calibration - for now default
	Kfactor = Kfactor * SampleThickness * 0.1
	// and store values in metadata
	metadata = ReplaceStringByKey("Kfactor", metadata, num2str(Kfactor, "%.10g"), "=", ";")
	metadata = ReplaceStringByKey("OmegaFactor", metadata, num2str(OmegaFactor, "%.10g"), "=", ";")
	// now slit length
	variable SlitLength = 0.5 * ((4 * pi) / wavelength) * sin(UPDsize / (2 * detector_distance))
	metadata = ReplaceStringByKey("SlitLength", metadata, num2str(SlitLength, "%.10g"), "=", ";")

	string ScanType = StringByKey("ScanType", metadata, "=", ";") //this will be Flyscan or uascan, set in ImportRawUSAXS
	if(stringMatch(ScanType, "Flyscan"))
		Duplicate/O R_Int, SMR_Int
		Duplicate/FREE R_Int, logBlankInterp, BlankInterp
		IN2G_LogInterpolateIntensity(R_Qvec, BlankInterp, BL_R_Qvec, BL_R_Int)

		//subtract and calibrate here
		SMR_Int = (R_Int - BlankInterp) / Kfactor // * MSAXSCorrection - used to be before use of diode transmission for calibration.
		//SMR_Int -= SubtractFlatBackground
		IN4_FixNegativeIntensities(SMR_Int)
		//Error propagation
		Duplicate/O R_error, SMR_Error
		Duplicate/FREE BL_R_error, log_BL_R_error
		log_BL_R_error = log(abs(BL_R_error))
		SMR_Error      = sqrt((R_error)^2 / SampleTransmissionPeakToPeak^2 + (10^(interp(R_Qvec, BL_R_Qvec, log_BL_R_error)))^2) / Kfactor
		SMR_Error     *= SampleTransmissionPeakToPeak //change 2/2014 to fix cases, when samples have really high absorption, but scatter well...
		//Q vector propagation
		Duplicate/O R_Qvec, SMR_Qvec
		//dQ
		Duplicate/O SMR_Qvec, SMR_dQ
		SMR_dQ[1, numpnts(SMR_dQ) - 2] = (SMR_dQ[p + 1] - SMR_dQ[p - 1]) / 4
		SMR_dQ[0]                      = (SMR_dQ[1] - SMR_dQ[0]) / 2
		SMR_dQ[numpnts(SMR_dQ) - 1]    = (SMR_dQ[numpnts(SMR_dQ) - 1] - SMR_dQ[numpnts(SMR_dQ) - 2]) / 2
		SMR_dQ                         = sqrt((SMR_dQ[p])^2 + (InstrumentQresolution / 2)^2) //convolute with SI220 InstrumentQresolution
		//remove points which are surely not useful
		//TODO: find range of data which is sufficentlty meaningful here.
		//the Qmin is easy:
		variable Qmin          = IN4_FindQminForUSAXS(Foldername)
		variable StartPointCut = BinarySearch(SMR_Qvec, Qmin) + 1
		//DeletePoints EndPointCut, inf, SMR_Int, SMR_Qvec, SMR_Error
		DeletePoints 0, StartPointCut, SMR_Int, SMR_Qvec, SMR_Error
		//end append data
		//add avenotes
		IN2G_AppendorReplaceWaveNote("SMR_Int", "SlitLength", num2str(SlitLength))
		IN2G_AppendorReplaceWaveNote("SMR_Int", "SampleThickness", num2str(SampleThickness))
		IN2G_AppendorReplaceWaveNote("SMR_Int", "Kfactor", num2str(Kfactor))
		IN2G_AppendorReplaceWaveNote("SMR_Int", "OmegaFactor", num2str(OmegaFactor))
		IN2G_AppendorReplaceWaveNote("SMR_Int", "units", "1/cm")
		IN2G_AppendorReplaceWaveNote("SMR_Qvec", "units", "1/A")
	else
		Abort "step scan not done yet"
	endif

	setDataFolder OldDf
End

///*********************************************************************************
//*********************************************************************************
//******************** name **************************************
Function IN4_FindQminForUSAXS(string Foldername)

	DFREF oldDf = GetDataFolderDFR()
	setDataFolder $(FolderName)

	WAVE BL_R_Qvec
	WAVE BL_R_Int
	WAVE R_Int
	WAVE R_Qvec
	SVAR metadata

	variable PeakWidth    = NumberByKey("FWHM", metadata, "=", ";")
	variable BlankWidth   = NumberByKey("BlankWidth", metadata, "=", ";")
	variable Transmission = NumberByKey("Transmission", metadata, "=", ";")
	SVAR instrument
	variable Wavelength = NumberByKey("Wavelength", instrument, "=", ";")

	variable HaveMSAXSCOrrection = 0
	variable QminTheoreticalSample
	variable QminTheoreticalBlank
	variable Qmin
	variable MinQMinFindRatio = 1.3
	variable FindMinQForData  = 1
	//	NVAR/Z FindMinQForData=root:Packages:Indra3:FindMinQForData		//added 2019-04 as convenience, find min Q when Int > IntBl*2
	//	NVAR/Z MinQMinFindRatio=root:Packages:Indra3:MinQMinFindRatio
	//	if(!NVAR_Exists(FindMinQForData))
	//		variable/g FindMinQForData
	//		FindMinQForData = 1
	//		variable/g MinQMinFindRatio
	//		MinQMinFindRatio = 1.3
	//	endif

	variable BlankFudgefactor  = 1.05 //this is fudge factor for Blank.
	variable SampleFudgefactor = 0.95 //this is for MSAXS dominated Sample width.
	//this is real instrument Qmin under any conditions... Blank FWHM, 1.05 is fudge factor here...
	QminTheoreticalBlank = BlankFudgefactor * 4 * pi * sin(BlankWidth * 4.848e-6 / 2) / Wavelength
	//this is instrument resolution due to sample width, if we have MSAXS, this dominates.
	//0.7 is fudge factor here... Seems to work for MSAXS calculations
	QminTheoreticalSample = 4 * pi * sin(SampleFudgefactor * PeakWidth * 4.848e-6 / 2) / Wavelength
	//now calculate Qmin based in intensity difference...
	variable QminIntDifference = 0
	variable QminAUtoFOund     = 0
	variable QminDifferenceInIntensities
	//variable QminTheoreticalBlank = 1.05 * 4 * pi * sin(0.57 *BlankWidth*4.848e-6 /2) / Wavelength		//This is Qmin due to multiple scattering... scaled up a bit to make sure this makes sense...
	//and of course, we have Qmin old which user used last time
	//	NVAR/Z OldStartQValueForEvaluation
	//	if(!NVAR_Exists(OldStartQValueForEvaluation))
	//		variable/g OldStartQValueForEvaluation
	//		OldStartQValueForEvaluation = QminDefaultForProcessing
	//	endif

	if(FindMinQForData)
		Duplicate/FREE R_Int, IntRatio
		Duplicate/FREE R_Qvec, QCorrection //this is per point correction, we need bigger difference at low-q than high-q
		//need to find function which is q dependent and varies from Max correction to 1 over our range of Qs.
		//02-10-2021 changed values (was 2 and 4) below to tweak the behavior.
		variable MaxCorrection   = 0.5
		variable PowerCorrection = 3
		QCorrection = 1 + MaxCorrection * (abs(QminTheoreticalBlank / R_Qvec))^PowerCorrection
		QCorrection = (QCorrection < (MaxCorrection + 1)) ? QCorrection : (MaxCorrection + 1)
		//the above should peak at Q=0 with max correction of "MaxCorrection"+1 and drop off as function of q resolution.
		Duplicate/FREE BL_R_Int, LogBlankInt
		LogBlankInt = log(BL_R_Int)
		IntRatio    = interp(R_Qvec, BL_R_Qvec, LogBlankInt) //this is interpolated log(BlankInt)
		IntRatio    = 10^IntRatio                            //interpolated BlankInt
		IntRatio    = R_Int / IntRatio                       //this is R_int/BlankInt (interpolated to R_Qvec) without transmission CORRECTION!
		//IntRatio = IntRatio/Transmission					 		//this is R_int/BlankInt (interpolated to R_Qvec) with transmission CORRECTION!

		IntRatio = IntRatio / QCorrection
		wavestats/Q/R=[10, numpnts(IntRatio) / 10] IntRatio
		FindLevel/Q/EDGE=1/R=[V_minloc, numpnts(IntRatio) - 1] IntRatio, MinQMinFindRatio
		if(V_Flag == 0) //found level
			QminDifferenceInIntensities = R_Qvec[ceil(V_LevelX)]
			QminAUtoFOund               = 1
		else
			QminDifferenceInIntensities = 0
			QminAUtoFOund               = 0
		endif
	endif //so now, if user wants, we have qmin when data are 2*Background (first time).

	//now, pick the right Qmin and set some variable to know what message to post for user.
	////	if(FindMinQForData)
	//ignore old QMin
	Qmin = max(QminTheoreticalBlank, QminTheoreticalSample, QminDifferenceInIntensities)
	if(QminTheoreticalSample > QminTheoreticalBlank)
		HaveMSAXSCOrrection = 1
	endif
	//	else
	//		//include old Qmin, but move right if needed.
	//		Qmin = max(QminTheoreticalBlank, QminTheoreticalSample, OldStartQValueForEvaluation)
	//		if(QminTheoreticalSample>QminTheoreticalBlank)
	//			HaveMSAXSCOrrection = 1
	//		endif
	//	endif

	setDataFolder OldDf
	return Qmin
End

//*************************************************************************************************
//*************************************************************************************************

Function IN4_DesmearData(string Foldername)

	DFREF oldDf = GetDataFolderDFR()
	setDataFolder $(FolderName)

	//NVAR DesmearData = root:Packages:Indra3:DesmearData
	//NVAR IsBlank = root:Packages:Indra3:IsBlank						//cannot desmear Blank
	//NVAR is2DCollimated=root:Packages:Indra3:is2DCollimated		//cannot desmear pinhole data
	//if(IsBlank)
	//	return 0
	//endif
	//if(DesmearData && !is2DCollimated)
	SVAR metadata
	variable SlitLength = NumberByKey("SlitLength", metadata, "=", ";")
	//	NVAR DesmearNumberOfInterations=root:Packages:Indra3:DesmearNumberOfInterations
	WAVE/Z SMR_Int = SMR_Int
	if(!WaveExists(SMR_Int)) //wave does n to exist, stop here...
		setDataFolder oldDf
		return 0
	endif
	WAVE SMR_Error
	WAVE SMR_Qvec
	WAVE SMR_dQ
	IN2G_RemoveNaNsFrom4Waves(SMR_Int, SMR_Qvec, SMR_Error, SMR_dQ) //desmearing chokes on NaNs
	Killwaves/Z DSM_Int, DSM_Qvec, DSM_Error, DSM_dQ
	Duplicate/FREE SMR_Int, tmpWork_Int
	Duplicate/FREE SMR_Error, tmpWork_Error
	Duplicate/FREE SMR_Qvec, tmpWork_Qvec
	Duplicate/FREE SMR_dQ, tmpWork_dQ

	Duplicate/O SMR_Int, DesmNormalizedError
	Duplicate/FREE SMR_Int, absNormalizedError
	variable numOfPoints = numpnts(SMR_Int)
	variable DesmearAutoTargChisq, difff
	variable endme    = 0
	variable oldendme = 0
	DesmearAutoTargChisq = 0.5
	variable ExtensionFailed
	variable NumIterations = 0
	do
		ExtensionFailed = IN4_OneDesmearIteration(Foldername, tmpWork_Int, tmpWork_Qvec, tmpWork_Error, SMR_Int, SMR_Error, DesmNormalizedError)
		if(ExtensionFailed)
			setDataFolder oldDf
			return 0
		endif
		absNormalizedError = abs(DesmNormalizedError)
		Duplicate/FREE/O absNormalizedError, tmpabsNormalizedError
		IN2G_RemNaNsFromAWave(tmpabsNormalizedError)
		endme          = sum(tmpabsNormalizedError) / numpnts(absNormalizedError)
		difff          = 1 - oldendme / endme
		oldendme       = endme
		NumIterations += 1
	while(endme > DesmearAutoTargChisq && abs(difff) > 0.01 && NumIterations < 20)

	Duplicate/O tmpWork_Int, DSM_Int
	Duplicate/O tmpWork_Qvec, DSM_Qvec
	Duplicate/O tmpWork_Error, DSM_Error
	Duplicate/O tmpWork_dQ, DSM_dQ
	DSM_Error = abs(DSM_Error) //remove negative values this gets in extreme cases.

	setDataFolder oldDf

End
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN4_OneDesmearIteration(string Foldername, WAVE DesmearIntWave, WAVE DesmearQWave, WAVE DesmearEWave, WAVE origSmearedInt, WAVE origSmearedErr, WAVE NormalizedError)

	string OldDf = GetDataFolder(1)
	setDataFolder $(Foldername)

	SVAR metadata
	variable SlitLength = NumberByKey("SlitLength", metadata, "=", ";")

	string BackgroundFunction = "PowerLaw w flat" // root:Packages:Indra3:DsmBackgroundFunction

	variable NumberOfIterations //	=	root:Packages:Indra3:DesmearNumberOfInterations
	variable numOfPoints = numpnts(DesmearIntWave) //	 = root:Packages:Indra3:DesmearNumPoints
	variable BckgStartQ  = 0.1                     //  = root:Packages:Indra3:DesmearBckgStart
	if(BckgStartQ > (DesmearQWave[numOfPoints - 1] / 1.5))
		BckgStartQ = DesmearQWave[numOfPoints - 1] / 1.5
	endif
	Duplicate/FREE DesmearIntWave, SmFitIntensity
	Duplicate/FREE origSmearedInt, OrigIntToSmear
	Duplicate/FREE origSmearedErr, SmErrors
	variable ExtensionFailed = 0

	ExtensionFailed = IN4_ExtendData(DesmearIntWave, DesmearQWave, SmErrors, slitLength, BckgStartQ, BackgroundFunction) //extend data to 2xnumOfPoints to Qmax+2.1xSlitLength
	if(ExtensionFailed)
		return 1
	endif
	if(slitlength > 0)
		IN4_SmearData(DesmearIntWave, DesmearQWave, slitLength, SmFitIntensity) //smear the data, output is SmFitIntensity
	endif
	Redimension/N=(numOfPoints) SmFitIntensity, DesmearIntWave, DesmearQWave, NormalizedError //cut the data back to original length (Qmax, numOfPoints)

	NormalizedError = (origSmearedInt - SmFitIntensity) / SmErrors //NormalizedError (input-my Smeared data)/input errors
	duplicate/O/FREE DesmearIntWave, FastFitIntensity, SlowFitIntensity
	//fast convergence
	FastFitIntensity = DesmearIntWave * (OrigIntToSmear / SmFitIntensity)
	//slow convergence
	SlowFitIntensity = DesmearIntWave + (OrigIntToSmear - SmFitIntensity)

	variable i
	//	if(DesmearFastOnly)
	//		DesmearedIntWave = FastFitIntensity
	//	elseif(DesmearSlowOnly)
	//		DesmearedIntWave = SlowFitIntensity
	//	elseif(DesmearDampen)
	for(i = 0; i < (numpnts(DesmearIntWave)); i += 1)
		if(abs(NormalizedError[i]) > 0.5)
			DesmearIntWave[i] = FastFitIntensity[i]
		else
			DesmearIntWave[i] = DesmearIntWave[i]
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
	NumberOfIterations += 1
	//remove the normalized error extremes
	wavestats/Q NormalizedError
	NormalizedError[x2pnt(NormalizedError, V_minLoc)] = NaN
	NormalizedError[x2pnt(NormalizedError, V_maxLoc)] = NaN
	//Duplicate/O DesmearIntWave, DesmearEWave
	DesmearEWave = 0
	IN4_GetErrors(origSmearedErr, origSmearedInt, DesmearIntWave, DesmearEWave, DesmearQWave) //this routine gets the errors
	setDataFolder OldDf
	return 0
End

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*************************************Extends the data using user specified parameters***************
Function IN4_ExtendData(Int_wave, Q_vct, Err_wave, slitLength, Qstart, SelectedFunction)

	WAVE Int_wave, Q_vct, Err_wave
	variable slitLength, Qstart //RecordFitParam=1 when we should record fit parameters in logbook
	string SelectedFunction

	if(numtype(slitLength) != 0)
		abort "Slit length error"
	endif
	if(slitLength < 0.0001 || slitLength > 1)
		DoALert 0, "Weird value for Slit length, please check"
	endif

	string oldDf = GetDataFolder(1)
	setDataFolder root:Packages:Indra4

	WAVE/Z W_coef = W_coef
	if(WaveExists(W_coef) != 1)
		make/N=2 W_coef
	endif
	W_coef = 0 //reset for recording purposes...
	//check if this makes any sense, sometimes we have issues with data and need to break here.
	Wavestats/Q Int_wave
	if(V_numNans > 0 || V_numINFs > 0)
		abort
	endif

	string   ProblemsWithQ   = ""
	string   ProblemWithFit  = ""
	string   ProblemsWithInt = ""
	variable DataLengths     = numpnts(Q_vct) - 1 //get number of original data points
	variable Qstep           = ((Q_vct(DataLengths) / Q_vct(DataLengths - 1)) - 1) * Q_vct(DataLengths)
	variable ExtendByQ       = sqrt(Q_vct(DataLengths)^2 + (1.5 * slitLength)^2) - Q_vct(DataLengths)
	if(ExtendByQ < (2.1 * Qstep))
		ExtendByQ = 2.1 * Qstep
	endif
	variable NumNewPoints = floor(ExtendByQ / Qstep)
	if(NumNewPoints < 1)
		NumNewPoints = 1
	endif
	variable OriginalNumPnts = numpnts(Int_wave)
	if(NumNewPoints > OriginalNumPnts)
		NumNewPoints = OriginalNumPnts
	endif
	variable newLength = numpnts(Q_vct) + NumNewPoints //New length of waves
	variable FitFrom   = binarySearch(Q_vct, Qstart)   //get at which point of Q start fitting for extension
	if(FitFrom <= 0) //error in selection of Q fitting range
		FitFrom       = DataLengths - 10
		ProblemsWithQ = "I did reset Fitting Q range for you..."
	endif
	//There seems to be bug, which prevents me from using /D in FuncFit and cursor control
	//therefore we will have to now handle this ourselves...
	//FIrst check if the wave exists
	WAVE/Z fit_ExtrapIntwave
	if(!WaveExists(fit_ExtrapIntwave))
		Make/O/N=300 fit_ExtrapIntwave
	endif
	//Now we need to set it's x scaling to the range of Q values we need to study
	SetScale/I x, Q_vct[FitFrom], Q_vct[DataLengths - 1], "", fit_ExtrapIntwave
	//reset the fit wave to constant value
	fit_ExtrapIntwave = Int_wave[DataLengths - 1]

	Redimension/N=(newLength) Int_wave, Q_vct, Err_wave //increase length of the two waves

	variable   i            = 0
	variable   ii           = 0
	variable/G V_FitError   = 0 //this is way to avoid bombing due to numerical problems
	variable/G V_FitOptions = 4 //this should suppress the window showing progress (4) & force robust fitting (6)
	//using robust fitting caused problems, do not use...
	variable/G V_FitMaxIters = 50
	//***********here start different ways to extend the data

	if(cmpstr(SelectedFunction, "flat") == 0) //flat background, for some reason only way this works is
		//lets setup parameters for FuncFit
		if(exists("W_coef") != 1) //using my own function to fit. Crazy!!
			make/N=2 W_coef
		endif
		Redimension/D/N=1 W_coef
		Make/O/N=1 E_wave
		E_wave[0]  = 1e-6
		W_coef[0]  = Int_wave[((FitFrom + DataLengths) / 2)] //here is starting guesses
		K0         = W_coef[0]                               //another way to get starting guess in
		V_FitError = 0                                       //this is way to avoid bombing due to numerical problems
		//now lets do the fitting
		FuncFit/N/Q IN4_FlatFnct, W_coef, Int_wave[FitFrom, DataLengths - 1]/I=1/W=Err_Wave/E=E_Wave/X=Q_vct //Here we get the fit to the Int_wave in
		//now check for the convergence
		if(V_FitError != 0)
			//we had error during fitting
			ProblemWithFit = "Linear fit function did not converge properly,\r change function or Q range"
		else //the fit converged properly
			for(i = 1; i <= NumNewPoints; i += 1)
				Q_vct[DataLengths + i]    = Q_vct[DataLengths] + (ExtendByQ) * (i / NumNewPoints) //extend Q
				Int_wave[DataLengths + i] = W_coef[0]                                             //extend Int
			endfor
			fit_ExtrapIntwave = W_coef[0]
		endif
	endif

	if(cmpstr(SelectedFunction, "power law") == 0) //power law background
		V_FitError = 0 //this is way to avoid bombing due to numerical problems
		//now lets do the fitting
		K0 = 0
		CurveFit/N/Q/H="100" Power, Int_wave[FitFrom, DataLengths - 1]/X=Q_vct/W=Err_Wave/I=1
		if(V_FitError != 0)
			//we had error during fitting
			ProblemWithFit = "Power law fit function did not converge properly,\r change function or Q range"
		else //the fit converged properly
			for(i = 1; i <= NumNewPoints; i += 1)
				Q_vct[DataLengths + i]    = Q_vct[DataLengths] + (ExtendByQ) * (i / NumNewPoints)      //extend Q
				Int_wave[DataLengths + i] = W_coef[0] + W_coef[1] * (Q_vct[DataLengths + i])^W_coef[2] //extend Int
			endfor
			fit_ExtrapIntwave = W_coef[0] + W_coef[1] * (x)^W_coef[2]
		endif
	endif

	if(cmpstr(SelectedFunction, "Porod") == 0) //Porod background
		if(exists("W_coef") != 1)
			make/N=2 W_coef
		endif
		Redimension/D/N=2 W_coef
		variable estimate1_w0 = Int_wave[(DataLengths - 1)]
		variable estimate1_w1 = Q_vct[(FitFrom)]^4 * Int_wave[(FitFrom)]
		W_coef     = {estimate1_w0, estimate1_w1} //here are starting guesses, may need to be fixed.
		K0         = estimate1_w0
		K1         = estimate1_w1
		V_FitError = 0                            //this is way to avoid bombing due to numerical problems
		//now lets do the fitting
		Make/O/T CTextWave = {"K0 > " + num2str(estimate1_w0 / 100)}
		FuncFit/N/Q IN4_Porod, W_coef, Int_wave[FitFrom, DataLengths - 1]/I=1/C=CTextWave/W=Err_Wave/X=Q_vct //Porod function here
		if(V_FitError != 0)
			//we had error during fitting
			ProblemWithFit = "Porod fit function did not converge properly,\r change function or Q range"
		else //the fit converged properly
			for(i = 1; i <= NumNewPoints; i += 1)
				Q_vct[DataLengths + i]    = Q_vct[DataLengths] + (ExtendByQ) * (i / NumNewPoints) //extend Q
				Int_wave[DataLengths + i] = W_coef[0] + W_coef[1] / (Q_vct[DataLengths + i])^4    //extend Int
			endfor
			fit_ExtrapIntwave = W_coef[0] + W_coef[1] / (x)^4
		endif
	endif

	if(cmpstr(SelectedFunction, "PowerLaw w flat") == 0) //fit polynom 3rd degree
		if(exists("W_coef") != 1)
			make/N=3 W_coef
		endif
		K0     = Int_wave[(DataLengths - 1)]
		K1     = (Int_wave[(FitFrom)] - K0) * (Q_vct[(FitFrom)]^3)
		K2     = -3
		W_coef = {K0, K1, K2} //here are starting guesses, may need to be fixed.

		Make/O/T CTextWave = {"K1 > 0", "K2 < 0", "K0 > 0", "K2 > -6"}
		Redimension/D/N=3 W_coef
		V_FitError = 0 //this is way to avoid bombing due to numerical problems
		Curvefit/N/G/Q power, Int_wave[FitFrom, DataLengths - 1]/I=1/C=CTextWave/X=Q_vct/W=Err_Wave
		if(V_FitError != 0)
			//we had error during fitting
			ProblemWithFit = "Power Law with flat fit function did not converge properly,\r change function or Q range"
		else //the fit converged properly
			for(i = 1; i <= NumNewPoints; i += 1)
				Q_vct[DataLengths + i]    = Q_vct[DataLengths] + (ExtendByQ) * (i / NumNewPoints) //extend Q
				Int_wave[DataLengths + i] = W_coef[0] + W_coef[1] * (Q_vct[DataLengths + i]^W_coef[2])
			endfor
			fit_ExtrapIntwave = W_coef[0] + W_coef[1] * (x^W_coef[2])
		endif
	endif

	//		wavestats/Q/R=[DataLengths+1,] Int_wave
	//	//	print DataLengths
	//		if (V_min<0)
	//			ProblemsWithInt="Extrapolated Intensity <0, select different function"
	//		endif
	variable ExtensionFailed = 0
	string   ErrorMessages   = ""
	if(strlen(ProblemsWithQ) != 0)
		ErrorMessages = ProblemsWithQ + "\r"
	endif
	if(strlen(ProblemsWithInt) != 0)
		ErrorMessages = ProblemsWithInt + "\r"
	endif
	if(strlen(ProblemWithFit) != 0)
		ErrorMessages += ProblemWithFit
	endif
	if(strlen(ErrorMessages) != 0)
		ExtensionFailed = 1
		//DoAlert /T="Desmearing failed" 0, ErrorMessages
		//SVAR userFriendlySampleDFName = root:Packages:Indra3:userFriendlySampleDFName
		//print "For "+userFriendlySampleDFName+" sample "+ErrorMessages
		print "Desmearing extension failed, Extending data by average intensity (aka:flat)"
		variable AveInt = sum(Int_wave, FitFrom, DataLengths - 1) / (DataLengths - 1 - FitFrom)
		for(i = 1; i <= NumNewPoints; i += 1)
			Q_vct[DataLengths + i]    = Q_vct[DataLengths] + (ExtendByQ) * (i / NumNewPoints) //extend Q
			Int_wave[DataLengths + i] = AveInt
		endfor
		fit_ExtrapIntwave = AveInt
		ExtensionFailed   = 0
	endif
	setDataFolder OldDf
	return ExtensionFailed
End

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IN4_GetErrors(WAVE SmErrors, WAVE SmIntensity, WAVE FitIntensity, WAVE DsmErrors, WAVE Qvector) //calculates errors using Petes formulas

	DsmErrors = FitIntensity * (SmErrors / SmIntensity) //error proportional to input data
	variable i    = 2
	variable imax = numpnts(FitIntensity) - 1
	Redimension/N=(numpnts(FitIntensity)) DsmErrors
	do
		if((numtype(FitIntensity[i - 2]) == 0) && (numtype(FitIntensity[i - 1]) == 0) && (numtype(FitIntensity[i]) == 0) && (numtype(FitIntensity[i + 1]) == 0) && (numtype(FitIntensity[i + 2]) == 0))
			DsmErrors[i] += abs(IN4_CalculateLineAverage(FitIntensity, Qvector, i) - FitIntensity[i])
		endif
		i += 1
	while(i < (imax - 1))
	DsmErrors[0]        = 3 * DsmErrors[2]    //some error needed for 1st point, wild guess
	DsmErrors[1]        = 2 * DsmErrors[2]    //some error needed for 2nd point, wild guess
	DsmErrors[imax - 1] = DsmErrors[imax - 3] //and error for last point
	DsmErrors[imax - 2] = DsmErrors[imax - 2] //and error for last point

	//Smooth /E=2 3, DsmErrors
	//abort
End

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//this calculates line average without doing line fit...
Function IN4_CalculateLineAverage(WAVE WaveY, WAVE waveX, variable ivalue)

	variable sumx, sumx2, sumy, sumxy, mval, cval
	//variable x_avg, y_avg, numerator, denominator, slope, intercept
	if(ivalue > 1)
		// Calculate averages
		//checked against Google AI 04-03-2025
		sumx  = WaveX[ivalue - 2] + WaveX[ivalue - 1] + WaveX[ivalue] + WaveX[ivalue + 1] + WaveX[ivalue + 2]
		sumx2 = WaveX[ivalue - 2]^2 + WaveX[ivalue - 1]^2 + WaveX[ivalue]^2 + WaveX[ivalue + 1]^2 + WaveX[ivalue + 2]^2
		sumy  = WaveY[ivalue - 2] + WaveY[ivalue - 1] + WaveY[ivalue] + WaveY[ivalue + 1] + WaveY[ivalue + 2]
		sumxy = WaveX[ivalue - 2] * WaveY[ivalue - 2] + WaveX[ivalue - 1] * WaveY[ivalue - 1] + WaveX[ivalue] * WaveY[ivalue] + WaveX[ivalue + 1] * WaveY[ivalue + 1] + WaveX[ivalue + 2] * WaveY[ivalue + 2]
		mval  = (5 * sumxy - sumx * sumy) / (5 * sumx2 - sumx^2)
		cval  = (sumy - mval * sumx) / 5
		//variable result=mval*WaveX[ivalue] + cval
		return mval * WaveX[ivalue] + cval
	endif
	return 0
End

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*****************************This function smears data***********************
Function IN4_SmearData(WAVE Int_to_smear, WAVE Q_vec_sm, variable slitLength, WAVE Smeared_int)

	string OldDf = GetDataFolder(1)
	setDataFolder root:Packages:Indra4
	variable oldNumPnts = numpnts(Q_vec_sm)
	//modified 2/28/2017 - with Fly scans and merged data having lot more points, this is getting to be slow. Keep max number of new points to 300
	variable newNumPoints
	if(oldNumPnts < 300)
		newNumPoints = 2 * oldNumPnts
	else
		newNumPoints = oldNumPnts + 300
	endif
	Duplicate/O/FREE Int_to_smear, tempInt_to_smear
	Redimension/N=(newNumPoints) tempInt_to_smear //increase the points here.
	Duplicate/O/FREE Q_vec_sm, tempQ_vec_sm
	Redimension/N=(newNumPoints) tempQ_vec_sm
	tempQ_vec_sm[oldNumPnts,]     = tempQ_vec_sm[oldNumPnts - 1] + 20 * tempQ_vec_sm[p - oldNumPnts]                                                            //creates extension of number of points up to 20*original length
	tempInt_to_smear[oldNumPnts,] = tempInt_to_smear[oldNumPnts - 1] * (1 - (tempQ_vec_sm[p] - tempQ_vec_sm[oldNumPnts]) / (20 * tempQ_vec_sm[oldNumPnts - 1])) //extend the data by simple fixed value...

	Make/D/FREE/N=(oldNumPnts) Smear_Q, Smear_Int
	//Q's in L spacing and intensitites in the l's will go to Smear_Int (intensity distribution in the slit, changes for each point)

	variable DataLengths = numpnts(Q_vec_sm)

	Smear_Q = 2 * slitLength * (Q_vec_sm[p] - Q_vec_sm[0]) / (Q_vec_sm[DataLengths - 1] - Q_vec_sm[0]) //create distribution of points in the l's which mimics the original distribution of points
	//the 2* added later, because without it I did not  cover the whole slit length range...
	variable i = 0
	DataLengths = numpnts(Smeared_int)
	MatrixOp/FREE Q_vec_sm2 = powR(Q_vec_sm, 2)
	MatrixOp/FREE Smear_Q2 = powR(Smear_Q, 2)
	MultiThread Smeared_int = IN4_SmearDataFastFunc(Q_vec_sm2[p], Smear_Q, Smear_Q2, tempQ_vec_sm, tempInt_to_smear, SlitLength)

	Smeared_int *= 1 / slitLength //normalize

	setDataFolder OldDf
End

//***********************************************************************************************************************************//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
threadsafe Function IN4_SmearDataFastFunc(variable Q_vec_sm2, WAVE Smear_Q, WAVE Smear_Q2, WAVE tempQ_vec_sm, WAVE tempInt_to_smear, variable SlitLength)

	Duplicate/FREE Smear_Q, Smear_Int
	//Smear_Int=interp(sqrt( Q_vec_sm2 +(Smear_Q2[p])), tempQ_vec_sm, tempInt_to_smear)		//put the distribution of intensities in the slit for each point
	//this is using Interpolate2, seems slightly faster than above line alone...
	Duplicate/FREE Smear_Q, InterSmear_Q
	InterSmear_Q = sqrt(Q_vec_sm2 + (Smear_Q2[p]))
	//surprisingly, below code is tiny bit slower that the two lines above...
	//MatrixOp/FREE InterSmear_Q=sqrt(Smear_Q2 + Q_vec_sm2)
	Interpolate2/I=3/T=1/X=InterSmear_Q/Y=Smear_Int tempQ_vec_sm, tempInt_to_smear
	return areaXY(Smear_Q, Smear_Int, 0, slitLength) //integrate the intensity over the slit
End
//***********************************************************************************************************************************//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN4_FlatFnct(WAVE w, variable x) : FitFunc

	return w[0]
End
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN4_Porod(WAVE w, variable x) : FitFunc

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

	return w[0] + w[1] * (x^(-4))
End
//***********************************************************************************************************************************
//***********************************************************************************************************************************

//***********************************************************************************************************************************
//***********************************************************************************************************************************
///*********************************************************************************
//*********************************************************************************
//******************** name **************************************
Function IN4_RebinDataIfNeeded(string Foldername)

	// rebins the data if FLyscan and may be more chaoices in teh future

	DFREF oldDf = GetDataFolderDFR()
	setDataFolder $(FolderName)

	variable FlyScanRebinToPoints = 500

	SVAR metadata
	string ScanType = StringByKey("ScanType", metadata, "=", ";") //this will be Flyscan or uascan, set in ImportRawUSAXS
	if(stringMatch(ScanType, "Flyscan"))
		variable BlankWidth = NumberByKey("BlankWidth", metadata, "=", ";")
		SVAR instrument
		variable Wavelength            = NumberByKey("Wavelength", instrument, "=", ";")
		variable InstrumentQresolution = 2 * pi * sin(BlankWidth / 3600 * pi / 180) / Wavelength
		WAVE/Z SMR_Int
		if(!WaveExists(SMR_Int))
			abort "Bad data in IN4_RebinDataIfNeeded"
		endif
		WAVE SMR_Qvec
		WAVE SMR_Error
		WAVE SMR_dQ
		variable tempMinStep = SMR_Qvec[1] - SMR_Qvec[0]
		IN2G_RebinLogData(SMR_Qvec, SMR_Int, FlyScanRebinToPoints, tempMinStep, Wsdev = SMR_Error, Wxwidth = SMR_dQ)
		SMR_dQ = sqrt((SMR_dQ[p])^2 + (InstrumentQresolution / 2)^2) //convolute with SI220 InstrumentQresolution

	endif

	setDataFolder OldDf
End

///*********************************************************************************
Function/S IN4_CopyUSAXSToFolder(string Foldername, string addStr)

	// Copy fully processed data to new folder

	DFREF oldDf = GetDataFolderDFR()
	setDataFolder $(FolderName)

	SVAR   filename_old  = filename
	string newFolderName = StringFromList(0, filename_old, ".") + addStr
	print "Saving data to new folder root:USAXS:" + newFolderName
	if(DataFolderExists(newFolderName))
		print "This folder exists, deleting"
	endif
	NewDataFolder/O root:USAXS
	string FullnewFolderName = "root:USAXS:" + newFolderName
	//first we need the existing stuff here.
	WAVE BL_R_Int_old    = BL_R_Int
	WAVE BL_R_Qvec_old   = BL_R_Qvec
	WAVE BL_R_Error_old  = BL_R_Error
	WAVE R_Int_old       = R_Int
	WAVE R_Qvec_old      = R_Qvec
	WAVE R_error_old     = R_error
	WAVE PeakFitWave_old = PeakFitWave
	WAVE SMR_Int_old     = SMR_Int
	WAVE SMR_Qvec_old    = SMR_Qvec
	WAVE SMR_error_old   = SMR_error
	WAVE SMR_dQ_old      = SMR_dQ
	WAVE DSM_Int_old     = DSM_Int
	WAVE DSM_Qvec_old    = DSM_Qvec
	WAVE DSM_Error_old   = DSM_Error
	WAVE DSM_dQ_old      = DSM_dQ
	SVAR metadata_old    = metadata
	SVAR sample_old      = sample
	SVAR instrument_old  = instrument
	SVAR blankname_old   = blankname

	variable Kfactor_old     = NumberByKey("Kfactor", metadata_old, "=", ";")
	variable thickness_old   = NumberByKey("thickness", sample_old, "=", ";")
	variable OmegaFactor_old = NumberByKey("OmegaFactor", metadata_old, "=", ";")
	string   units_old       = StringByKey("units", note(SMR_Int_old), "=", ";")
	//now create the new folder and copy stuff here
	NewDataFolder/O/S $(FullnewFolderName)
	Duplicate/O BL_R_Int_old, BL_R_Int
	Duplicate/O BL_R_Qvec_old, BL_R_Qvec
	Duplicate/O BL_R_Error_old, BL_R_Error
	Duplicate/O R_Int_old, R_Int
	Duplicate/O R_Qvec_old, R_Qvec
	Duplicate/O R_error_old, R_Error
	Duplicate/O PeakFitWave_old, PeakFitWave
	Duplicate/O SMR_Int_old, SMR_Int
	Duplicate/O SMR_Qvec_old, SMR_Qvec
	Duplicate/O SMR_error_old, SMR_error
	Duplicate/O SMR_dQ_old, SMR_dQ
	Duplicate/O DSM_Int_old, DSM_Int
	Duplicate/O DSM_Qvec_old, DSM_Qvec
	Duplicate/O DSM_Error_old, DSM_Error
	Duplicate/O DSM_dQ_old, DSM_dQ
	string/G   metadata    = metadata_old
	string/G   sample      = sample_old
	string/G   instrument  = instrument_old
	string/G   blankname   = blankname_old
	string/G   units       = units_old
	variable/G Kfactor     = Kfactor_old
	variable/G thickness   = thickness_old
	variable/G OmegaFactor = OmegaFactor_old

	setDataFolder OldDf
	return FullnewFolderName
End

//*********************************************************************************
///*********************************************************************************
//Function IN4_ReplaceNaNs(folderName)
//	string folderName
//
//	DFref oldDf= GetDataFolderDFR()
//	setDataFolder $(FolderName)
//	//fake using log-interpolations values for NaNs.
//	Wave Intensity= R_Int
//	Wave Qvector= R_Qvec
//	Wave Error = R_Error
//	Duplicate/Free Intensity, LogIntensity
//	LogIntensity = log(Intensity)
//	variable pointBefore, PointAfter
//	variable i
//	Duplicate/Free Intensity, NanMaskWave
//	NanMaskWave = numtype(Intensity) ? 0 : 1
//	FindLevels /N=25/P/Q  NanMaskWave, 0.5
//	wave W_FindLevels
//	//print W_FindLevels
//	//  W_FindLevels[0] = {1.5,5.5,9.5,45.5,48.5,91.5,94.5,134.5,137.5,474.5,485.5,2200.5,2246.5}
//
////	For(i=1;i<numpnts(LogIntensity);i+=1)
////
////
////	endfor
////
//	KillWaves/Z  W_FindLevels
//	setDataFolder OldDf
//end
//
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IN4_SmoothRData(string folderName)

	DFREF oldDf = GetDataFolderDFR()
	setDataFolder $(FolderName)

	WAVE Intensity = R_Int
	WAVE Qvector   = R_Qvec
	WAVE PD_range  = PD_range
	WAVE R_Error   = R_Error
	WAVE MeasTime  = MeasTime
	//NVAR SmoothRCurveData = root:Packages:Indra3:SmoothRCurveData
	variable SmoothRCurveData = 1
	if(SmoothRCurveData)
		//first remove NaNs as this is really difficult to deal with...
		Duplicate/FREE PD_range, tmpPD_range
		Duplicate/FREE MeasTime, tmpMeasTime
		//IN2G_RemoveNaNsFrom5Waves(Intensity, Qvector,R_Error,tmpPD_range, tmpMeasTime)
		//smooth Blank_R using smoothing times for different ranges.
		variable tmpTime, StartPoints
		variable EndPoints, QrangeIntg, midPoint, startX, endX
		Duplicate/FREE Intensity, TempIntLog
		TempIntLog = log(Intensity)
		Duplicate/FREE TempIntLog, SmoothIntensity
		variable i
		for(i = 40; i < numpnts(Intensity); i += 1)
			if(tmpPD_range[i] == 1)
				tmpTime = RwaveSmooth1time
			elseif(tmpPD_range[i] == 2)
				tmpTime = RwaveSmooth2time
			elseif(tmpPD_range[i] == 3)
				tmpTime = RwaveSmooth3time
			elseif(tmpPD_range[i] == 4)
				tmpTime = RwaveSmooth4time
			else
				tmpTime = RwaveSmooth5time
			endif
			if(tmpMeasTime[i] > tmpTime) //no need to smooth
				SmoothIntensity[i] = TempIntLog[i]
			else //need to smooth
				//somehow we need to stay within one range also...
				StartPoints = ceil(tmpTime / tmpMeasTime[i]) + 1
				EndPoints   = StartPoints
				if((i - StartPoints) < 1)
					abort "Bad data, cannot fix this. Likely Flyscan parameters were wrong"
				endif
				if((i + EndPoints) > (numpnts(Intensity) - 1)) //do not run out of end of data set
					EndPoints = numpnts(Intensity) - 1 - i
				endif
				//if (i==118)
				//	debugger
				//endif
				if((tmpPD_range[i - StartPoints] != tmpPD_range[i]) || (tmpPD_range[i + EndPoints] != tmpPD_range[i]))
					//range change, do not average, use line fitting to get the point...
					Duplicate/FREE/O/R=[i - StartPoints, i + EndPoints - 1] TempIntLog, tempR
					Duplicate/O/FREE/R=[i - StartPoints, i + EndPoints - 1] Qvector, tempQ

					WaveStats/Q tempR
					if(V_npnts > (V_numNans + 5))
						CurveFit/Q line, tempR/X=tempQ
						WAVE W_coef
						SmoothIntensity[i] = W_coef[0] + W_coef[1] * Qvector[i]
						R_Error[i]         = R_Error[i] / 3
					else
						SmoothIntensity[i] = TempIntLog[i]
						R_Error[i]         = R_Error[i] //crude approximation
					endif
				else //R must be symmetric around the i or the method below will not work right.
					Duplicate/FREE/O/R=[i - StartPoints, i + EndPoints] TempIntLog, tempR
					Duplicate/O/FREE/R=[i - StartPoints, i + EndPoints] Qvector, tempQ
					startX              = tempQ[0]
					endX                = tempQ[numpnts(tempQ) - 1]
					SmoothIntensity[i]  = areaXY(tempQ, tempR, startX, endX)
					SmoothIntensity[i] /= (endX - startX)
					R_Error[i]          = R_Error[i] //crude approximation
				endif
			endif
		endfor
		Intensity = 10^SmoothIntensity
	endif
	KillWaves/Z T_Constraints, W_sigma, W_FindLevels, W_coef, W_FindLevels, fit_R_Int, fitX_R_Int

	setDataFolder OldDf
End

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//******************** name **************************************
Function IN4_FindlevelsWithNaNs(WAVE waveIn, variable LevelSearched, variable MaxLocation, variable LeftRight)

	//set LeftRight to 0 for left and 1 for right of the MaxLocation
	variable LevelPoint = 0
	variable counter    = MaxLocation
	variable Done       = 0
	do
		if(LeftRight)
			counter += 1
		else
			counter -= 1
		endif
		if(counter < (numpnts(waveIn) - 1) && numtype(waveIn[counter]) == 0)
			LevelPoint = counter
			if(waveIn[counter] > LevelSearched && counter > 0 && Counter < numpnts(WaveIn)) //fix when cannot reach 50% or less value...
				LevelPoint = counter
			else
				if(abs(MaxLocation - LevelPoint) > 3)
					Done = 1
				endif
			endif
		endif
	while(Done < 1 && counter > 0 && counter < (numpnts(waveIn) - 1))
	return LevelPoint
End

//******************** name **************************************

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN4_FSCreateGainWave(WAVE GainWv, WAVE ampGainReq, WAVE ampGain, WAVE mcsChangePnts, WAVE TimeRangeAfter, WAVE MeasTime)

	//creates amplfier gains for upd or I0/I00 from mcs channel records
	Duplicate/FREE mcsChangePnts, tmpmcsChangePnts
	Duplicate/FREE ampGainReq, tmpampGainReq
	Duplicate/FREE ampGain, tmpampGain
	variable i
	i = numpnts(tmpmcsChangePnts) - 1
	if(i > 1)
		do //this simply removes any trailing change points in the records, which screw up the working code
			if(tmpmcsChangePnts[i] == 0)
				tmpmcsChangePnts[i] = NaN
			else
				break
			endif
			i -= 1
		while(i > 0 && tmpmcsChangePnts[i] < 1)
	endif
	//this blasts on these 3 waves any lines, which contain NaN in any of the three waves.
	IN2G_RemoveNaNsFrom3Waves(tmpmcsChangePnts, tmpampGainReq, tmpampGain)
	//set Gains to first point on record
	GainWv = tmpampGain[0]
	variable iii
	variable iiimax = numpnts(tmpmcsChangePnts) - 1
	variable StartRc, EndRc
	if(iiimax < 1) //Fix for scanning when no range changes happen...
		GainWv = tmpampGain[0] //this seem unnecessary... hm, it was here before.
	else
		StartRc = 0
		EndRc   = 0
		for(iii = 0; iii < (iiimax + 1); iii += 1) //find points when we requested ranege change and when we got it, record and deal with it
			if(tmpampGain[iii] != tmpampGainReq[iii]) //requested gain change
				StartRc = tmpmcsChangePnts[iii]
			elseif(tmpampGain[iii] == tmpampGainReq[iii]) //got the requested range change, from here we should have the gains set
				EndRc = tmpmcsChangePnts[iii]
				if((EndRc < (numpnts(GainWv) - 1)) && (numtype(StartRc) == 0))
					if(IN4_RemoveRangeChangeEffects) //remove transitional effects
						GainWv[StartRc, EndRc] = NaN //while we were changing, set points to NaNs
					endif
					GainWv[EndRc + 1,] = ampGain[iii] + 1 //set rest of the measured points to the gain we set
					if(IN4_RemoveRangeChangeEffects) //remove transitional effects
						IN4_MaskPointsForGivenTime(GainWv, MeasTime, EndRc + 1, TimeRangeAfter[ampGain[iii]]) //mask for time, if needed.
					endif
				endif
			endif
		endfor
	endif

End
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IN4_MaskPointsForGivenTime(WAVE MaskedWave, WAVE TimeWv, variable PointNum, variable MaskTimeDown)

	variable NumPntsW
	NumPntsW = numpnts(MaskedWave)
	variable i, maskTime
	i = 0
	if(MaskTimeDown > 0)
		do
			MaskedWave[PointNum + i] = NaN
			maskTimeDown            -= TimeWv[PointNum + i]
			i                       += 1
		while((maskTimeDown > 0) && ((PointNum + i) < NumPntsW))
	endif
End

//**********************************************************************************************************
//**********************************************************************************************************///*********************************************************************************
///*********************************************************************************
Function IN4_FixNegativeIntensities(WAVE waveIn)

	//fix oversubtraction of WaveIn here?
	wavestats/Q WaveIn
	variable MaxValue = V_max
	wavestats/Q/R=[numpnts(WaveIn) / 2, numpnts(WaveIn) - 1] WaveIn
	if(V_min < 0)
		WaveIn += Indra_PDIntBackFixScaleVmin * abs(V_min) + MaxValue * Indra_PDIntBackFixScaleVmax
		//print "Fixed USAXS Range 5 background subtraction by Intensity = Intensity + "+num2str(1.05*abs(V_min)+V_max*1e-10)
	endif
End
//*********************************************************************************
///*********************************************************************************

Function IN4_FixZeroUncertainties(WAVE PD_error)

	//fix zero values of uncertaitnies here...
	Duplicate/FREE PD_error, tempWv
	tempWv = (tempWv > 0) ? tempWv : NaN
	wavestats/Q tempWv
	variable minErr = V_min
	PD_error = (PD_error > 0) ? PD_error : minErr

End

//*********************************************************************************
///*********************************************************************************
