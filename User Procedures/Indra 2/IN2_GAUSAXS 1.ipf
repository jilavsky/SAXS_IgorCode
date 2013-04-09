#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.0


Function IN2A_GrazingAngleParam(ctrlname) : Buttoncontrol			// calls the Lorenzina fit
	string ctrlname
 
	Variable/G BeamCenter, MaximumIntensity, PeakWidth		//creates waves with results

	variable BeamCenterL, MaximumIntensityL, PeakWidthL

	BeamCenterL=9
	MaximumIntensityL=1e-9
	PeakWidthL=3

	Prompt BeamCenterL, "Insert beam center AR_encoder"
	Prompt MaximumIntensityL, "Insert max. int. estimate"
	prompt PeakWidthL, "Insert Peak width estimate"
	
	DoPrompt "Grazing Angle SAXS input",BeamCenterL, MaximumIntensityL, PeakWidthL
	
	if (V_Flag)
		abort
	endif
	
	BeamCenter=BeamCenterL
	MaximumIntensity=MaximumIntensityL
	PeakWidth=PeakWidthL
	

	IN2G_AppendNoteToAllWaves("BeamCenter",num2str(BeamCenter))
	IN2G_AppendNoteToAllWaves("MaximumIntensity",num2str(MaximumIntensity))
	IN2G_AppendNoteToAllWaves("FWHM",num2str(PeakWidth))
End


Function Correct_GA_USAXS()
	string DataFldr, BlankDataFldr
	
	Prompt dataFldr, "Select folder with data to correct", popup, "R data:;"+ IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, "R*", 1)	//+"DSM data:;"+ IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, "DSM", 1)
	Prompt BlankDataFldr, "Select Blank folder", popup, "R data:;"+ IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, "R*", 1)	//+"DSM data:;"+ IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, "DSM", 1)
	
	DoPrompt "Data folder selection", dataFldr, BlankDataFldr
	if (V_flag)
		abort
	endif
	
	if (cmpstr("R data:", dataFldr)==0)
		abort
	endif
	if (cmpstr("DSM data:", dataFldr)==0)
		abort
	endif
	
	setDataFolder $dataFldr
	
	SVAR/Z ASBParameters
	if (!SVAR_Exists(ASBParameters))
		string/g ASBParameters
	endif
	
	ASBParameters=	ReplaceStringByKey("Calibrate",ASBParameters,"GA_USAXS","=")			//put results into ASBParameters
	ASBParameters=ReplaceStringByKey("Blank",ASBParameters,BlankDataFldr,"=") 			//put the in there
	
	NVAR BlankMax=$(BlankDataFldr+"MaximumIntensity")
	NVAR BlankWidth=$(BlankDataFldr+"PeakWidth")
	
	
	
	WAVE AR_encoder
	Wave R_Int
	Wave R_Error
	Wave R_Qvec
	Wave BL_R_Int=$(BlankDataFldr+"R_Int")
	Wave BL_R_Error=$(BlankDataFldr+"R_error")
	Wave BL_Qvec=$(BlankDataFldr+"R_Qvec")
	
	
	
	NVAR BeamCenter
	NVAR wavelength

	variable ThetaI, ThetaIdash, ThetaIRad
	variable SampleAzimuthal, SampleAzimuthalRad
	variable CriticalAngle, CriticalAngleRad
	variable Ls, SigmaT, BeamHeight
	variable Aconst, Bin, RefractiveIndex, BeamWidth, AsTerm, OmegaFactor

	Prompt Ls,"Length of footprint on sample [cm]"
	Prompt SigmaT, "Total macroscopic attenuation [1/cm]"
	prompt BeamHeight, "Height of the beam [cm]"
	Prompt BeamWidth, "Width of beam"
	Prompt CriticalAngle, "Critical angle [deg]"
	Prompt SampleAzimuthal, "Sample azimuthal angle [deg]"
	Prompt ThetaI, "Theta Incident for the sample [deg]"
	Prompt OmegaFactor, "Omega Factor for the sample"
		
	DoPrompt "Input corr param", ThetaI, SampleAzimuthal, CriticalAngle, Ls, SigmaT, BeamHeight, BeamWidth, OmegaFactor

	
	Duplicate/O AR_encoder, ScatteringAngle, Theta2, Theta2Dash, C_out, QPerp, QPerpCorr, QTotalCorr
	Duplicate/O R_Int, GA_Int, PenetrationDepthMax, PenetrationDepthMean, GA_Error, GA_Qvec
	

	ScatteringAngle=(pi/180)*(BeamCenter-AR_encoder)

	SampleAzimuthalRad=(pi/180)*SampleAzimuthal

	CriticalAngleRad=(pi/180)*CriticalAngle

	ThetaIRad=(pi/180)*ThetaI
	
	Theta2=asin(sin(ScatteringAngle)*cos(SampleAzimuthalRad))

	Theta2dash=sqrt(Theta2^2-CriticalAngleRad^2)	

	ThetaIdash=sqrt(ThetaIRad^2-CriticalAngleRad^2)
	
	C_out=(1/tan(ThetaIdash) + 1/tan(Theta2Dash))*(sin(Theta2dash)/sin(Theta2))
	
	AsTerm=BeamWidth*BeamHeight
		
	Aconst=AsTerm^2*(SigmaT*Ls)^2/(4*BeamWidth^2*Ls^3*(exp(-SigmaT*Ls)+SigmaT*Ls-1))

	RefractiveIndex=sqrt(1-CriticalAngleRad^2)

	Bin=(sin(ThetaIRad)+RefractiveIndex*sin(ThetaIDash))^2 / ((sin(ThetaIRad))^2 * sin(ThetaIDash))
	
	PenetrationDepthMax=Ls*sin(Theta2Dash)/(sin(Theta2)*C_out)*10000  //this is in micrometers now
	
	PenetrationDepthMean=PenetrationDepthMax*(2+SigmaT*Ls -((SigmaT*Ls)^2/(SigmaT*Ls+exp(-SigmaT*Ls)-1)))/(SigmaT*Ls)
		
	QPerp		=	((2*pi)/wavelength)*(sin(ThetaIRad)+sin(Theta2))

	QPerpCorr 	=	((2*pi)/wavelength)*(sin(ThetaIDash)+sin(Theta2Dash))

	QTotalCorr	= 	sqrt(R_Qvec^2-QPerp^2+QPerpCorr^2)





	GA_Int		=	(1/OmegaFactor)*(R_Int/BlankMax) *Aconst*Bin*C_out

	GA_Error   	=	(1/OmegaFactor)*(R_Error/BlankMax)*Aconst*Bin*C_out

	GA_Qvec	= 	QTotalCorr	
end