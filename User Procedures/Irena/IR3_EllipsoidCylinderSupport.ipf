#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access
#pragma DefaultTab={3, 20, 4} // Set default tab width in Igor Pro 9 and later
#pragma version=0.3

//Constant recalculateGM=0 					//this method does not seem to work properly.
Constant UseNewCSProfileCalculation = 1 //using new method =1 is about 2.2x faster than using 0.
//  Time to calculate = 14.65 seconds, method UseNewCSProfileCalculation = 0
//  Time to calculate = 6.5333 seconds, method UseNewCSProfileCalculation = 1
//number of integration points in internal integrations (points on waves used for integration) --- impacts high-q oscillations
Constant NumPntsAlpha = 121 //121 to 181 changes calculation time by 50% (6.5 sec -> 9.8sec), changes high-q peaks a bit.
Constant NumPntsPsi   = 41  //21 ~ 1.5 sec, 41 ~ 3 sec, 61 ~ 4.5 sec, 91 ~ 6.5 sec, no observable impact on model... weird...
//181/91 seems to give excellent results, 121/41 gives very good values (on test case) and is much faster.

Constant PrintFitProgress = 0 //print steps while fitting
//*************************************************************************\
//* Copyright (c) 2005 - 2026, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution.
//*************************************************************************/

//version info:
//	0.1 initial testing
//  0.2 improve CS El profile calculation, verified code against other notes and papers. Still calibration is weird.
// 	0.3 initial inclusion in Irena

//These are bits and pieces of real math code for modeling and fitting various cylinders.
//	Generally we have cylinder, core shell cylinder and core shell cylinder but defined by radial profile of densities.
//  We also have same, but with cross section being ellipsoid.

// last updated 10-14-2024, JIL

//Control and Graph code is at the top
//*****************************************************************************************************************
Function IR3F_AutoRecalculateModelData(variable Force)
	//next we calculate the model
	KillWIndow/Z CSCylinderProcessRunning
	NVAR UpdateAutomatically = root:Packages:Irena:CylinderModels:UpdateAutomatically
	if(UpdateAutomatically || Force)
		IR3F_CalculateAndGraphModelData()
		IR3F_AttachTags(0)
	endif

End
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IR3F_CalculateAndGraphModelData()
	//next we graph the model

	DFREF oldDf = GetDataFolderDFR()
	setDataFolder root:Packages:Irena:CylinderModels
	WAVE/Z OriginalIntensity = root:Packages:Irena:CylinderModels:OriginalDataIntWave
	if(!WaveExists(OriginalIntensity)) //wave does not exist, user probably did nto ccreate data yet.
		abort
	endif
	DoWIndow IR3F_LogLogDataDisplay
	if(V_Flag)
		CheckDisplayed/W=IR3F_LogLogDataDisplay OriginalIntensity
		if(V_Flag)
			WAVE OriginalQvector = root:Packages:Irena:CylinderModels:OriginalDataQWave
			WAVE OriginalError   = root:Packages:Irena:CylinderModels:OriginalDataErrorWave
			IR3F_CalculateModel(OriginalIntensity, OriginalQvector, 0)
			WAVE ModelIntensity = root:Packages:Irena:CylinderModels:ModelIntensity
			//residuals, see IR2H_CalcAndPlotResiduals(OriginalIntensity,OriginalError, ModelIntensity)
			Duplicate/O OriginalIntensity, Residuals
			Residuals = (OriginalIntensity - ModelIntensity) / OriginalError
			CheckDisplayed/W=IR3F_LogLogDataDisplay ModelIntensity
			if(V_Flag < 1)
				AppendToGraph/W=IR3F_LogLogDataDisplay ModelIntensity vs OriginalQvector
				ModifyGraph/W=IR3F_LogLogDataDisplay lstyle(ModelIntensity)=3, lsize(ModelIntensity)=3, rgb(ModelIntensity)=(1, 12815, 52428)
			endif
			CheckDisplayed/W=IR3F_LogLogDataDisplay Residuals
			if(V_Flag < 1)
				AppendToGraph/W=IR3F_LogLogDataDisplay/R Residuals vs OriginalQvector
				ModifyGraph/W=IR3F_LogLogDataDisplay mode(Residuals)=2, rgb(Residuals)=(0, 0, 0)
				SetAxis/A/E=2/W=IR3F_LogLogDataDisplay right
				Label/W=IR3F_LogLogDataDisplay right, "\\Z" + IN2G_LkUpDfltVar("AxisLabelSize") + "Residuals"
			endif
		endif
		SVAR ModelSelected = root:Packages:Irena:CylinderModels:ModelSelected
		if(stringMatch(ModelSelected, "Profile CS Ellip. Cylinder") || stringMatch(ModelSelected, "Profile CS Ellip. Cylinder 2"))
			WAVE/Z Profile = root:Packages:Irena:CylinderModels:Profile
			if(WaveExists(Profile))
				DoWIndow IR3F_SLDProfile
				if(!V_Flag)
					Display/W=(521, 750, 1383, 1100)/K=1/N=IR3F_SLDProfile
					AppendToGraph/W=IR3F_SLDProfile Profile
					Label left, "Δ SLD [10\\S10 \\Mcm\\S2\\M]"
					Label bottom, "Radial distance [Angstroms]"
					ModifyGraph mirror=1
					SetAxis/A
					AutoPositionWindow/M=1/R=IR3F_LogLogDataDisplay IR3F_SLDProfile
				endif
			endif
		else
			KillWindow/Z IR3F_SLDProfile
		endif
	endif

	SVAR FittingPower = root:Packages:Irena:CylinderModels:FittingPower
	//FittingPower = "Int;I*Q;I*Q^2;I*Q^3;I*Q^4;
	DoWIndow IR3F_FittingDataDisplay
	if(V_Flag)
		if(!StringMatch(FittingPower, "Int"))
			strswitch(FittingPower)
				case "Int":
					break

				case "I*Q":
					Duplicate/O ModelIntensity, ModelWaveQ
					ModelWaveQ = ModelIntensity * OriginalQvector
					CheckDisplayed/W=IR3F_FittingDataDisplay ModelWaveQ
					if(!V_FLag)
						AppendToGraph/W=IR3F_FittingDataDisplay ModelWaveQ vs OriginalQvector
						ModifyGraph/W=IR3F_FittingDataDisplay lstyle(ModelWaveQ)=3, rgb(ModelWaveQ)=(1, 12815, 52428), lsize(ModelWaveQ3)=3
					endif
					break
				case "I*Q^2":
					Duplicate/O ModelIntensity, ModelWaveQ2
					ModelWaveQ2 = ModelIntensity * OriginalQvector^2
					CheckDisplayed/W=IR3F_FittingDataDisplay ModelWaveQ2
					if(!V_FLag)
						AppendToGraph/W=IR3F_FittingDataDisplay ModelWaveQ2 vs OriginalQvector
						ModifyGraph/W=IR3F_FittingDataDisplay lstyle(ModelWaveQ2)=3, rgb(ModelWaveQ2)=(1, 12815, 52428), lsize(ModelWaveQ3)=3
					endif
					break
				case "I*Q^3":
					Duplicate/O ModelIntensity, ModelWaveQ3
					ModelWaveQ3 = ModelIntensity * OriginalQvector^3
					CheckDisplayed/W=IR3F_FittingDataDisplay ModelWaveQ3
					if(!V_FLag)
						AppendToGraph/W=IR3F_FittingDataDisplay ModelWaveQ3 vs OriginalQvector
						ModifyGraph/W=IR3F_FittingDataDisplay lstyle(ModelWaveQ3)=3, rgb(ModelWaveQ3)=(1, 12815, 52428), lsize(ModelWaveQ3)=3
					endif
					break
				case "I*Q^4":
					Duplicate/O ModelIntensity, ModelWaveQ4
					ModelWaveQ4 = ModelIntensity * OriginalQvector^4
					CheckDisplayed/W=IR3F_FittingDataDisplay ModelWaveQ4
					if(!V_FLag)
						AppendToGraph/W=IR3F_FittingDataDisplay ModelWaveQ4 vs OriginalQvector
						ModifyGraph/W=IR3F_FittingDataDisplay lstyle(ModelWaveQ4)=3, rgb(ModelWaveQ4)=(1, 12815, 52428), lsize(ModelWaveQ3)=3
					endif
					break
			endswitch

		endif
	endif
	//	IR2H_AppendModelToMeasuredData()
	//	TextBox/W=IR2H_SI_Q2_PlotGels/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()
	//	TextBox/W=IR2H_IQ4_Q_PlotGels/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()
	TextBox/W=IR3F_LogLogDataDisplay/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07" + date() + ", " + time()
	//	TextBox/W=IR2H_ResidualsPlot/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()
	setDataFolder oldDf
End
//*****************************************************************************************************************

Function IR3F_CalculateModel(OriginalIntensity, OriginalQvector, calledFromFitting)
	WAVE OriginalIntensity, OriginalQvector
	variable calledFromFitting

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena:CylinderModels

	Duplicate/O OriginalIntensity, ModelIntensity, ModelIntensityQ4, ModelIntensityQ3, UnsmearedModelIntensity
	ModelIntensity          = 0
	ModelIntensityQ4        = 0
	ModelIntensityQ3        = 0
	UnsmearedModelIntensity = 0

	WAVE/Z ModelIntensityTMP = root:Packages:Irena:CylinderModels:ModelIntensityTMP
	if(!WaveExists(ModelIntensityTMP) || numpnts(OriginalIntensity) != numpnts(ModelIntensityTMP))
		Make/O/N=(numpnts(UnsmearedModelIntensity)) ModelIntensityTMP
	endif
	Duplicate/FREE OriginalIntensity, CylinderModelIntensity, UnifiedFitIntensity
	Duplicate/O OriginalIntensity, CylModelInt, UnifiedModelInt
	Duplicate/O OriginalQvector, CylModelQvector, QstarVector
	CylModelInt             = 0
	UnifiedModelInt         = 0
	UnsmearedModelIntensity = 0

	NVAR UseUnified             = root:Packages:Irena:CylinderModels:UseUnified
	NVAR UseSlitSmearedData     = root:Packages:Irena:CylinderModels:UseSlitSmearedData
	NVAR SlitLength             = root:Packages:Irena:CylinderModels:SlitLength
	NVAR SASBackground          = root:Packages:Irena:CylinderModels:SASBackground
	SVAR ModelSelected          = root:Packages:Irena:CylinderModels:ModelSelected
	NVAR UseGMatrixCalculations = root:Packages:Irena:CylinderModels:UseGMatrixCalculations

	WAVE UnifiedPar = root:Packages:Irena:CylinderModels:UnifiedPar
	//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
	WAVE CylPar = root:Packages:Irena:CylinderModels:CylPar
	//CylParNames = {"Prefactor","Radius","Length","SLD"}
	WAVE CSCylPar = root:Packages:Irena:CylinderModels:CSCylPar
	//CSCylParNames = {"Prefactor","Radius","Length","SLD","ShellThickness"}
	WAVE ElCylPar = root:Packages:Irena:CylinderModels:ElCylPar
	//ElCylParNames = {"Prefactor","Radius","Length","SLD","AspectRatio"}
	WAVE CSElCylPar = root:Packages:Irena:CylinderModels:CSElCylPar
	//CSElCylParNames = 		{"Prefactor","Radius","Length","SLD","ShellThickness","AspectRatio"}
	WAVE ProfCSElCylPar = root:Packages:Irena:CylinderModels:ProfCSElCylPar
	//ProfCSElCylParNames = {"Prefactor","Radius","Length","AspectRatio","Shell1Th","Shell1SLD", "Shell2th", "Shell2SLD"}
	WAVE ProfCSElCylPar2 = root:Packages:Irena:CylinderModels:ProfCSElCylPar2
	//ProfCSElCylParNames = {"Prefactor","Radius","Length","AspectRatio","Shell1Th","Shell1SLD", "Shell2th", "Shell2SLD", "Shell3th", "Shell3SLD"}

	// model calculations are here...
	//	//Unified fit, left in, for now not used
	//	variable UnifRg = UnifiedPar[1][0], UnifG = UnifiedPar[0][0], UnifPwrlawB = UnifiedPar[2][0]
	//	variable UnifPwrlawP = UnifiedPar[3][0]
	//	variable UnifRgCO = UnifiedPar[4][0]
	//	if(UseUnified)			//Unified level
	//		QstarVector=OriginalQvector/(erf(OriginalQvector*UnifRg/sqrt(6)))^3
	//		UnifiedFitIntensity=UnifG*exp(-OriginalQvector^2*UnifRg^2/3)+(UnifPwrlawB/QstarVector^UnifPwrlawP)* exp(-UnifRgCO^2 * OriginalQvector^2/3)
	//		//UnifiedFitIntensity = UnifPwrlawB * OriginalQvector^(-1*UnifPwrlawP)
	//	else
	//		UnifiedFitIntensity = 0
	//	endif

	//Cylinder;Core Shell Cylinder;Ellip. Cylinder;Core Shell Ellip. Cylinder
	//try to avoid recalculation when we change only scale/preFactor, takes too long.
	// ModelIntensityTMP is global wave holding the last calculation of V^2*F^2
	string OldNote  = note(ModelIntensityTMP)
	string oldModel = StringByKey("Model", OldNote, ":")
	string oldPar   = StringByKey("Par", OldNote, ":")
	string newPar
	//Cylinder models
	variable Prefactor, Radius, Length, SLD
	variable ShellThicknes, AspectRatio
	variable Shell1Th, Shell1SLD, Shell2th, Shell2SLD, Shell3Th, Shell3SLD
	if(StringMatch(ModelSelected, "Cylinder"))
		Prefactor = CylPar[0][0]
		Radius    = CylPar[1][0]
		Length    = CylPar[2][0]
		SLD       = CylPar[3][0]
		newPar    = num2str(Radius) + "-" + num2str(Length) + "-" + num2str(SLD)
		if(!StringMatch(oldModel, "Cylinder") || !StringMatch(oldPar, newPar))
			IR3F_CalculateCylinder(CylModelQvector, ModelIntensityTMP, Radius, Length, SLD)
			Note/K ModelIntensityTMP, "Model:" + ModelSelected + ";" + "Par:" + newPar + ";"
			if(PrintFitProgress)
				print "Calculated:" + ModelSelected + ",Rad=" + num2str(radius) + ",SLD=" + num2str(SLD)
			endif
		endif
		CylinderModelIntensity = Prefactor * ModelIntensityTMP
	elseif(StringMatch(ModelSelected, "Core Shell Cylinder"))
		Prefactor     = CSCylPar[0][0]
		Radius        = CSCylPar[1][0]
		Length        = CSCylPar[2][0]
		SLD           = CSCylPar[3][0]
		ShellThicknes = CSCylPar[4][0]
		newPar        = num2str(Radius) + "-" + num2str(Length) + "-" + num2str(SLD) + "-" + num2str(ShellThicknes)
		if(!StringMatch(oldModel, "Core Shell Cylinder") || !StringMatch(oldPar, newPar))
			IR3F_CalculateCSCylinder(CylModelQvector, ModelIntensityTMP, Radius, Length, SLD, ShellThicknes)
			Note/K ModelIntensityTMP, "Model:" + ModelSelected + ";" + "Par:" + newPar + ";"
			if(PrintFitProgress)
				print "Calculated:" + ModelSelected + ",Rad=" + num2str(radius) + ",SLD=" + num2str(SLD) + ",ShellThicknes=" + num2str(ShellThicknes)
			endif
		endif
		CylinderModelIntensity = Prefactor * ModelIntensityTMP
	elseif(StringMatch(ModelSelected, "Ellip. Cylinder"))
		Prefactor   = ElCylPar[0][0]
		Radius      = ElCylPar[1][0]
		Length      = ElCylPar[2][0]
		SLD         = ElCylPar[3][0]
		AspectRatio = ElCylPar[4][0]
		newPar      = num2str(Radius) + "-" + num2str(Length) + "-" + num2str(SLD) + "-" + num2str(AspectRatio)
		if(!StringMatch(oldModel, "Ellip. Cylinder") || !StringMatch(oldPar, newPar))
			IR3F_CalculateEplipCylinder(CylModelQvector, ModelIntensityTMP, Radius, Length, SLD, AspectRatio)
			Note/K ModelIntensityTMP, "Model:" + ModelSelected + ";" + "Par:" + newPar + ";"
			if(PrintFitProgress)
				print "Calculated:" + ModelSelected + ",Rad=" + num2str(radius) + ",SLD=" + num2str(SLD) + ",AR=" + num2str(AspectRatio)
			endif
		endif
		CylinderModelIntensity = Prefactor * ModelIntensityTMP
	elseif(StringMatch(ModelSelected, "Core Shell Ellip. Cylinder"))
		Prefactor     = CSElCylPar[0][0]
		Radius        = CSElCylPar[1][0]
		Length        = CSElCylPar[2][0]
		SLD           = CSElCylPar[3][0]
		ShellThicknes = CSElCylPar[4][0]
		AspectRatio   = CSElCylPar[5][0]
		newPar        = num2str(Radius) + "-" + num2str(Length) + "-" + num2str(SLD) + "-" + num2str(ShellThicknes) + "-" + num2str(AspectRatio)
		if(!StringMatch(oldModel, "Core Shell Ellip. Cylinder") || !StringMatch(oldPar, newPar))
			IR3F_CalcCoreShellEplipCylinder(CylModelQvector, ModelIntensityTMP, Radius, Length, SLD, ShellThicknes, AspectRatio)
			Note/K ModelIntensityTMP, "Model:" + ModelSelected + ";" + "Par:" + newPar + ";"
			if(PrintFitProgress)
				print "Calculated:" + ModelSelected + ",Rad=" + num2str(radius) + ",Shell1SLD=" + num2str(SLD) + ",ShellTh=" + num2str(ShellThicknes) + ",AR=" + num2str(AspectRatio)
			endif
		endif
		CylinderModelIntensity = Prefactor * ModelIntensityTMP

	elseif(StringMatch(ModelSelected, "Profile CS Ellip. Cylinder"))
		//{"Prefactor","Radius","Length","AspectRatio","Shell1Th","Shell1SLD", "Shell2th", "Shell2SLD"}

		Prefactor   = ProfCSElCylPar[0][0]
		Radius      = ProfCSElCylPar[1][0]
		Length      = ProfCSElCylPar[2][0]
		AspectRatio = ProfCSElCylPar[3][0]
		Shell1Th    = ProfCSElCylPar[4][0]
		Shell1SLD   = ProfCSElCylPar[5][0]
		Shell2Th    = ProfCSElCylPar[6][0]
		Shell2SLD   = ProfCSElCylPar[7][0]
		newPar      = num2str(Radius) + "-" + num2str(Length) + "-" + num2str(AspectRatio) + "-" + num2str(Shell1Th) + "-" + num2str(Shell1SLD) + "-" + num2str(Shell2Th) + "-" + num2str(Shell2SLD) + "-" + num2str(UseGMatrixCalculations)
		if(!StringMatch(oldModel, "Profile CS Ellip. Cylinder") || !StringMatch(oldPar, newPar))
			//if(UseGMatrixCalculations)
			//	CalcCSProfileGM(CylModelQvector, ModelIntensityTMP, length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD)
			//else
			IR3F_CalcCSElProfile(CylModelQvector, ModelIntensityTMP, length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD, calledFromFitting)
			//endif
			Note/K ModelIntensityTMP, "Model:" + ModelSelected + ";" + "Par:" + newPar + ";"
			if(PrintFitProgress)
				print "Calculated:" + ModelSelected + ",Rad=" + num2str(radius) + ",AR=" + num2str(AspectRatio) + ",Shell1th=" + num2str(Shell1th) + ",Shell1SLD=" + num2str(Shell1SLD) + ",Shell2th=" + num2str(Shell2th) + ",Shell2SLD=" + num2str(Shell2SLD)
			endif
		endif
		CylinderModelIntensity = Prefactor * ModelIntensityTMP
	elseif(StringMatch(ModelSelected, "Profile CS Ellip. Cylinder 2"))
		//{"Prefactor","Radius","Length","AspectRatio","Shell1Th","Shell1SLD", "Shell2th", "Shell2SLD", "Shell3th", "Shell3SLD"}

		Prefactor   = ProfCSElCylPar2[0][0]
		Radius      = ProfCSElCylPar2[1][0]
		Length      = ProfCSElCylPar2[2][0]
		AspectRatio = ProfCSElCylPar2[3][0]
		Shell1Th    = ProfCSElCylPar2[4][0]
		Shell1SLD   = ProfCSElCylPar2[5][0]
		Shell2Th    = ProfCSElCylPar2[6][0]
		Shell2SLD   = ProfCSElCylPar2[7][0]
		Shell3Th    = ProfCSElCylPar2[8][0]
		Shell3SLD   = ProfCSElCylPar2[9][0]
		newPar      = num2str(Radius) + "-" + num2str(Length) + "-" + num2str(AspectRatio) + "-" + num2str(Shell1Th) + "-" + num2str(Shell1SLD) + "-" + num2str(Shell2Th) + "-" + num2str(Shell2SLD) + "-" + num2str(Shell3Th) + "-" + num2str(Shell3SLD) + "-" + num2str(UseGMatrixCalculations)
		if(!StringMatch(oldModel, "Profile CS Ellip. Cylinder 2") || !StringMatch(oldPar, newPar))
			//if(UseGMatrixCalculations)
			//	CalcCSProfileGM(CylModelQvector, ModelIntensityTMP, length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD)
			//else
			IR3F_CalcCSElProfile2(CylModelQvector, ModelIntensityTMP, length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD, Shell3th, Shell3SLD, calledFromFitting)
			//endif
			Note/K ModelIntensityTMP, "Model:" + ModelSelected + ";" + "Par:" + newPar + ";"
			if(PrintFitProgress)
				print "Calculated:" + ModelSelected + ",Rad=" + num2str(radius) + ",AR=" + num2str(AspectRatio) + ",Shell1th=" + num2str(Shell1th) + ",Shell1SLD=" + num2str(Shell1SLD) + ",Shell2th=" + num2str(Shell2th) + ",Shell2SLD=" + num2str(Shell2SLD)
			endif
		endif
		CylinderModelIntensity = Prefactor * ModelIntensityTMP
	else
		CylinderModelIntensity = 0
		ModelIntensityTMP      = 0
	endif

	UnsmearedModelIntensity = CylinderModelIntensity + SASBackground
	//slit smear with finite slit length...
	if(UseSlitSmearedData && numtype(SlitLength) == 0)
		//print "slit smeared"
		IR1B_SmearData(UnsmearedModelIntensity, OriginalQvector, slitLength, ModelIntensity)
		if(!calledFromFitting)
			if(sum(CylinderModelIntensity) > 0)
				IR1B_SmearData(CylinderModelIntensity, OriginalQvector, slitLength, CylModelInt)
			endif
		endif
		//TODO: add smearing of Unified fit model, if used.
	else
		ModelIntensity = UnsmearedModelIntensity
		CylModelInt    = CylinderModelIntensity
		//UnifiedModelInt = UnifiedFitIntensity
	endif

	//add smearing by number of points here
	NVAR SmearPointsNum = root:Packages:Irena:CylinderModels:SmearPointsNum
	if(SmearPointsNum > 0)
		Smooth/E=3/F SmearPointsNum, ModelIntensity
	endif

	if(calledFromFitting)
		SVAR FittingPower = root:Packages:Irena:CylinderModels:FittingPower
		//FittingPower = "Int;I*Q;I*Q^2;I*Q^3;I*Q^4;
		strswitch(FittingPower)
			case "Int":
				break
			case "I*Q":
				ModelIntensity = ModelIntensity * OriginalQvector
				break
			case "I*Q^2":
				ModelIntensity = ModelIntensity * OriginalQvector^2
				break
			case "I*Q^3":
				ModelIntensity = ModelIntensity * OriginalQvector^3
				break
			case "I*Q^4":
				ModelIntensity = ModelIntensity * OriginalQvector^4
				break
		endswitch
	endif
	NVAR AchievedChiSquare = root:Packages:Irena:CylinderModels:AchievedChiSquare
	//give us chance to see also chi-square if needed
	WAVE/Z FitIntensityWave    = root:Packages:Irena:CylinderModels:FitIntensityWave
	WAVE/Z OriginalDataIntWave = root:Packages:Irena:CylinderModels:OriginalDataIntWave
	if(calledFromFitting && WaveExists(FitIntensityWave))
		WAVE FitQvectorWave = root:Packages:Irena:CylinderModels:FitQvectorWave
		WAVE FitErrorWave   = root:Packages:Irena:CylinderModels:FitErrorWave
		Duplicate/FREE FitIntensityWave, tempChiSqWv
		tempChiSqWv       = (FitIntensityWave - ModelIntensity)^2 / FitErrorWave^2
		tempChiSqWv       = numtype(tempChiSqWv[p]) < 1 ? tempChiSqWv[p] : 0
		AchievedChiSquare = sum(tempChiSqWv)
		if(PrintFitProgress)
			print "Chi-square = " + num2str(AchievedChiSquare)
		endif
	elseif(!calledFromFitting && WaveExists(OriginalDataIntWave))
		WAVE OriginalDataQWave     = root:Packages:Irena:CylinderModels:OriginalDataQWave
		WAVE OriginalDataErrorWave = root:Packages:Irena:CylinderModels:OriginalDataErrorWave
		Duplicate/FREE OriginalDataIntWave, tempChiSqWv
		tempChiSqWv       = (OriginalDataIntWave - ModelIntensity)^2 / OriginalDataErrorWave^2
		tempChiSqWv       = numtype(tempChiSqWv[p]) < 1 ? tempChiSqWv[p] : 0
		AchievedChiSquare = sum(tempChiSqWv)
		if(PrintFitProgress)
			print "Chi-square = " + num2str(AchievedChiSquare)
		endif
	else
		AchievedChiSquare = 0
	endif

	Duplicate/O OriginalQvector, OriginalQvector4, OriginalQvector3
	OriginalQvector4 = OriginalQvector^4
	OriginalQvector3 = OriginalQvector^3
	ModelIntensityQ4 = ModelIntensity * OriginalQvector^4
	ModelIntensityQ3 = ModelIntensity * OriginalQvector^3

	setDataFolder OldDf
End
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3F_AttachTags(Attach)
	variable Attach 
	//=1 when attach, 0 when only remeove.

	NVAR HideTagsAlways = root:Packages:Irena:CylinderModels:HideTagsAlways
	Tag/W=IR3F_LogLogDataDisplay/K/N=CylTag
	Tag/W=IR3F_LogLogDataDisplay/K/N=CSCyltag
	Tag/W=IR3F_LogLogDataDisplay/K/N=ECtag
	Tag/W=IR3F_LogLogDataDisplay/K/N=CSECtag
	Tag/W=IR3F_LogLogDataDisplay/K/N=PCSECtag

	if(attach && !HideTagsAlways)
		SVAR DataFolderName    = root:Packages:Irena:CylinderModels:DataFolderName
		SVAR IntensityWaveName = root:Packages:Irena:CylinderModels:IntensityWaveName
		WAVE OriginalQvector   = root:Packages:Irena:CylinderModels:OriginalDataQWave
		SVAR ModelSelected     = root:Packages:Irena:CylinderModels:ModelSelected
		WAVE ModelIntensity    = root:Packages:Irena:CylinderModels:ModelIntensity
		string LowQText, CylText, CSCylTxt, ECText, CSECText, PCSECText
		variable attachPoint
		variable Prefactor, Length, Radius, SLD, ShellTh, AspectRatio, Shell1Th, Shell1SLD, Shell2th, Shell2SLD
		variable PrefactorErr, LengthErr, RadiusErr, SLDErr, ShellThErr, AspectRatioErr, Shell1ThErr, Shell1SLDErr, Shell2thErr, Shell2SLDErr

		strswitch(ModelSelected) // string switch
			case "Cylinder": // execute if case matches expression
				WAVE CylPar = root:Packages:Irena:CylinderModels:CylPar
				//CylParNames = {"Prefactor","Radius","Length","SLD"}
				Prefactor = CylPar[0][0]
				Radius    = CylPar[1][0]
				Length    = CylPar[2][0]
				SLD       = CylPar[3][0]
				RadiusErr = CylPar[1][4]
				LengthErr = CylPar[2][4]
				SLDErr    = CylPar[3][4]
				findlevel/Q/P OriginalQvector, (pi / (2 * Radius))
				attachPoint = numtype(V_levelX) == 0 ? V_levelX : numpnts(OriginalQvector) / 2
				CylText     = "\Z" + IN2G_LkUpDfltVar("LegendSize") + "Cylinder model results\r"
				CylText    += "Sample name: " + DataFolderName + IntensityWaveName + "\r"
				CylText    += "Radius \t\t= \t" + num2str(Radius) + " +/- " + num2str(RadiusErr) + "\r"
				CylText    += "SLD = \t" + num2str(SLD) + " A" + " +/- " + num2str(SLDErr)
				Tag/W=IR3F_LogLogDataDisplay/C/N=CylTag ModelIntensity, attachPoint, CylText
				break
			case "Core Shell Cylinder": // execute if case matches expression
				//Core Shell Cylinder Model
				WAVE CSCylPar = root:Packages:Irena:CylinderModels:CSCylPar
				//CylParNames = {"Prefactor","Radius","Length","SLD","ShellThickness"}
				Prefactor    = CSCylPar[0][0]
				Radius       = CSCylPar[1][0]
				Length       = CSCylPar[2][0]
				SLD          = CSCylPar[3][0]
				ShellTh      = CSCylPar[4][0]
				PrefactorErr = CSCylPar[0][4]
				RadiusErr    = CSCylPar[1][4]
				LengthErr    = CSCylPar[2][4]
				SLDErr       = CSCylPar[3][4]
				ShellThErr   = CSCylPar[4][4]
				findlevel/Q/P OriginalQvector, (pi / (2 * (Radius + ShellTh)))
				attachPoint = numtype(V_levelX) == 0 ? V_levelX : numpnts(OriginalQvector) / 2
				CSCylTxt    = "\Z" + IN2G_LkUpDfltVar("LegendSize") + "Core Shell Cylinder results\r"
				CSCylTxt   += "Sample name: " + DataFolderName + IntensityWaveName + "\r"
				CSCylTxt   += "Radius = " + num2str(Radius) + "A" + " +/- " + num2str(RadiusErr) + "\r"
				CSCylTxt   += "Shell Thick = " + num2str(ShellTh) + "A" + " +/- " + num2str(ShellThErr) + "\r"
				CSCylTxt   += "SLD = " + num2str(SLD) + " +/- " + num2str(SLDErr)
				Tag/W=IR3F_LogLogDataDisplay/C/N=CSCyltag ModelIntensity, attachPoint, CSCylTxt
				break
			case "Ellip. Cylinder": // execute if case matches expression
				//Ellip. Cylinder Model
				//ElCylParNames = {"Prefactor","Radius","Length","SLD","AspectRatio"}
				WAVE ElCylPar = root:Packages:Irena:CylinderModels:ElCylPar
				Prefactor      = ElCylPar[0][0]
				Radius         = ElCylPar[1][0]
				Length         = ElCylPar[2][0]
				SLD            = ElCylPar[3][0]
				AspectRatio    = ElCylPar[4][0]
				PrefactorErr   = ElCylPar[0][4]
				RadiusErr      = ElCylPar[1][4]
				LengthErr      = ElCylPar[2][4]
				SLDErr         = ElCylPar[3][4]
				AspectRatioErr = ElCylPar[4][4]
				findlevel/Q/P OriginalQvector, (pi / (2 * (Radius)))
				attachPoint = numtype(V_levelX) == 0 ? V_levelX : numpnts(OriginalQvector) / 2
				ECText      = "\Z" + IN2G_LkUpDfltVar("LegendSize") + "Ellip. Cylinder results\r"
				ECText     += "Sample name: " + DataFolderName + IntensityWaveName + "\r"
				ECText     += "Radius = " + num2str(Radius) + "A" + " +/- " + num2str(RadiusErr) + "\r"
				ECText     += "AspectRatio = " + num2str(ShellTh) + " +/- " + num2str(AspectRatioErr) + "\r"
				ECText     += "SLD = " + num2str(SLD) + " +/- " + num2str(SLDErr)
				Tag/W=IR3F_LogLogDataDisplay/C/N=ECtag ModelIntensity, attachPoint, ECText
				break
			case "Core Shell Ellip. Cylinder": // execute if case matches expression
				//Core Shell Ellip. Cylinder Model
				WAVE CSElCylPar = root:Packages:Irena:CylinderModels:CSElCylPar
				//CSElCylParNames = 		{"Prefactor","Radius","Length","SLD","ShellThickness","AspectRatio"}
				Prefactor      = CSElCylPar[0][0]
				Radius         = CSElCylPar[1][0]
				Length         = CSElCylPar[2][0]
				SLD            = CSElCylPar[3][0]
				ShellTh        = CSElCylPar[4][0]
				AspectRatio    = CSElCylPar[5][0]
				PrefactorErr   = CSElCylPar[0][4]
				RadiusErr      = CSElCylPar[1][4]
				LengthErr      = CSElCylPar[2][4]
				SLDErr         = CSElCylPar[3][4]
				ShellThErr     = CSElCylPar[4][4]
				AspectRatioErr = CSElCylPar[5][4]
				findlevel/Q/P OriginalQvector, (pi / (2 * (Radius)))
				attachPoint = numtype(V_levelX) == 0 ? V_levelX : numpnts(OriginalQvector) / 2
				CSECText    = "\Z" + IN2G_LkUpDfltVar("LegendSize") + "Core Shell Ellip. Cylinder results\r"
				CSECText   += "Sample name: " + DataFolderName + IntensityWaveName + "\r"
				CSECText   += "Radius = " + num2str(Radius) + "A" + " +/- " + num2str(RadiusErr) + "\r"
				CSECText   += "Shell Thickness = " + num2str(ShellTh) + "A" + " +/- " + num2str(ShellThErr) + "\r"
				CSECText   += "AspectRatio = " + num2str(ShellTh) + " +/- " + num2str(AspectRatioErr) + "\r"
				CSECText   += "SLD = " + num2str(SLD) + " +/- " + num2str(SLDErr)
				Tag/W=IR3F_LogLogDataDisplay/C/N=CSECtag ModelIntensity, attachPoint, CSECText
				break
			case "Profile CS Ellip. Cylinder": // execute if case matches expression
				//Profile CS Ellip. Cylinder Model
				WAVE ProfCSElCylPar = root:Packages:Irena:CylinderModels:ProfCSElCylPar
				//ProfCSElCylParNames = {"Prefactor","Radius","Length","AspectRatio","Shell1Th","Shell1SLD", "Shell2th", "Shell2SLD"}
				Prefactor      = ProfCSElCylPar[0][0]
				Radius         = ProfCSElCylPar[1][0]
				Length         = ProfCSElCylPar[2][0]
				AspectRatio    = ProfCSElCylPar[3][0]
				Shell1Th       = ProfCSElCylPar[4][0]
				Shell1SLD      = ProfCSElCylPar[5][0]
				Shell2th       = ProfCSElCylPar[6][0]
				Shell2SLD      = ProfCSElCylPar[7][0]
				PrefactorErr   = ProfCSElCylPar[0][4]
				RadiusErr      = ProfCSElCylPar[1][4]
				LengthErr      = ProfCSElCylPar[2][4]
				AspectRatioErr = ProfCSElCylPar[3][4]
				Shell1ThErr    = ProfCSElCylPar[4][4]
				Shell1SLDErr   = ProfCSElCylPar[5][4]
				Shell2ThErr    = ProfCSElCylPar[6][4]
				Shell2SLDErr   = ProfCSElCylPar[7][4]
				findlevel/Q/P OriginalQvector, (pi / (2 * (Radius)))
				attachPoint = numtype(V_levelX) == 0 ? V_levelX : numpnts(OriginalQvector) / 2
				PCSECText   = "\Z" + IN2G_LkUpDfltVar("LegendSize") + "Profile CS Ellip. Cylinder results\r"
				PCSECText  += "Sample name: " + DataFolderName + IntensityWaveName + "\r"
				PCSECText  += "Radius = " + num2str(Radius) + "A" + " +/- " + num2str(RadiusErr) + "\r"
				PCSECText  += "AspectRatio = " + num2str(AspectRatio) + " +/- " + num2str(AspectRatioErr) + "\r"
				PCSECText  += "Shell 1 and 3 Thickness = " + num2str(Shell1Th) + "A" + " +/- " + num2str(Shell1ThErr) + "\r"
				PCSECText  += "Shell 1 and 3 SLD = " + num2str(Shell1SLD) + " +/- " + num2str(Shell1SLDErr) + "\r"
				PCSECText  += "Shell 2 Thickness = " + num2str(Shell2Th) + "A" + " +/- " + num2str(Shell2ThErr) + "\r"
				PCSECText  += "Shell 2 SLD = " + num2str(Shell2SLD) + " +/- " + num2str(Shell2SLDErr) + "\r"
				Tag/W=IR3F_LogLogDataDisplay/C/N=PCSECtag ModelIntensity, attachPoint, PCSECText
				break

		endswitch
		//
		//		NVAR UseUnified			= root:Packages:Irena:CylinderModels:UseUnified
		//		if(UseUnified)
		//			Wave UnifiedPar = root:Packages:Irena:CylinderModels:UnifiedPar
		//			//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
		//			variable UnifRg			= UnifiedPar[1][0]
		//			variable UnifG			= UnifiedPar[0][0]
		//			variable UnifGError		= UnifiedPar[0][4]
		//			variable UnifRgError	= UnifiedPar[1][4]
		//			variable UnifPwrlawP	= UnifiedPar[3][0]
		//			variable UnifPwrlawB	= UnifiedPar[2][0]
		//			variable UnifPwrlawPError	= UnifiedPar[3][4]
		//			variable UnifPwrlawBError	= UnifiedPar[2][4]
		//			if((pi/ UnifRg)^2 > OriginalQvector[0])
		//				findlevel /Q /P OriginalQvector, (pi/(2*UnifRg))
		//				attachPoint=V_levelX
		//			else
		//				attachPoint = 0
		//			endif
		//			LowQText = "\Z"+IN2G_LkUpDfltVar("LegendSize")+"Low Q Unified model"+"\r"
		//			if(UnifRg<1e9 && UnifG>0)
		//				 LowQText +="Rg = "+num2str(UnifRg)+" +/- "+num2str(UnifRgError)+"\r"
		//				 LowQText +="Rg prefactor (G) = "+num2str(UnifG)+" +/- "+num2str(UnifGError)+"\r"
		//			endif
		//			 LowQText +="Power law Slope (P) = "+num2str(UnifPwrlawP)+" +/- "+num2str(UnifPwrlawPError)+"\r"
		//			 LowQText +="P Prefactor (B) = "+num2str(UnifPwrlawB)+" +/- "+num2str(UnifPwrlawBError)
		//
		//			Tag/W=IR3F_LogLogDataDisplay /C/N=UFTag/A=LT ModelIntensity, attachPoint/2,LowQText
		//		else
		//			Tag/W=IR3F_LogLogDataDisplay /K/N=UFTag/A=LT
		//		endif
	endif
End
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3F_SaveResultsToNotebook()

	NVAR SaveToNotebook = root:Packages:Irena:CylinderModels:SaveToNotebook
	if(SaveToNotebook < 1)
		return 0
	endif

	IR1_CreateResultsNbk()
	//MoveWindow /W=IR3F_LogLogDataDisplay 400, 30, 980, 530
	IR3F_AttachTags(1)
	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena:CylinderModels
	SVAR DataFolderName    = root:Packages:Irena:CylinderModels:DataFolderName
	SVAR IntensityWaveName = root:Packages:Irena:CylinderModels:IntensityWaveName
	SVAR QWavename         = root:Packages:Irena:CylinderModels:QWavename
	SVAR ErrorWaveName     = root:Packages:Irena:CylinderModels:ErrorWaveName
	SVAR ModelSelected     = root:Packages:Irena:CylinderModels:ModelSelected
	IR1_AppendAnyText("\r Results of System Specific Modeling \r", 1)
	IR1_AppendAnyText("Date & time: \t" + Date() + "   " + time(), 0)
	IR1_AppendAnyText("Data from folder: \t" + DataFolderName, 0)
	IR1_AppendAnyText("Intensity: \t" + IntensityWaveName, 0)
	IR1_AppendAnyText("Q: \t" + QWavename, 0)
	IR1_AppendAnyText("Error: \t" + ErrorWaveName, 0)
	IR1_AppendAnyText("Model used: \t" + ModelSelected, 0)
	string FittingResults = "\r\r"

	string LowQText, CylText, CSCylTxt, ECText, CSECText, PCSECText
	variable attachPoint
	variable Prefactor, Length, Radius, SLD, ShellTh, AspectRatio, Shell1Th, Shell1SLD, Shell2th, Shell2SLD
	variable PrefactorErr, LengthErr, RadiusErr, SLDErr, ShellThErr, AspectRatioErr, Shell1ThErr, Shell1SLDErr, Shell2thErr, Shell2SLDErr

	strswitch(ModelSelected) // string switch
		case "Cylinder": // execute if case matches expression
			WAVE CylPar = root:Packages:Irena:CylinderModels:CylPar
			//CylParNames = {"Prefactor","Radius","Length","SLD"}
			Prefactor       = CylPar[0][0]
			Radius          = CylPar[1][0]
			Length          = CylPar[2][0]
			SLD             = CylPar[3][0]
			RadiusErr       = CylPar[1][4]
			LengthErr       = CylPar[2][4]
			SLDErr          = CylPar[3][4]
			FittingResults  = "Radius \t\t= \t" + num2str(Radius) + " +/- " + num2str(RadiusErr) + "\r"
			FittingResults += "SLD = \t" + num2str(SLD) + " A" + " +/- " + num2str(SLDErr) + "\r"
			FittingResults += "Length = \t" + num2str(SLD) + " A" + "\r"
			break
		case "Core Shell Cylinder": // execute if case matches expression
			//Core Shell Cylinder Model
			WAVE CSCylPar = root:Packages:Irena:CylinderModels:CSCylPar
			//CylParNames = {"Prefactor","Radius","Length","SLD","ShellThickness"}
			Prefactor       = CSCylPar[0][0]
			Radius          = CSCylPar[1][0]
			Length          = CSCylPar[2][0]
			SLD             = CSCylPar[3][0]
			ShellTh         = CSCylPar[4][0]
			PrefactorErr    = CSCylPar[0][4]
			RadiusErr       = CSCylPar[1][4]
			LengthErr       = CSCylPar[2][4]
			SLDErr          = CSCylPar[3][4]
			ShellThErr      = CSCylPar[4][4]
			FittingResults  = "Radius \t\t= \t" + num2str(Radius) + " +/- " + num2str(RadiusErr) + "\r"
			FittingResults += "Shell Thick = " + num2str(ShellTh) + "A" + " +/- " + num2str(ShellThErr) + "\r"
			FittingResults += "SLD = \t" + num2str(SLD) + " A" + " +/- " + num2str(SLDErr) + "\r"
			FittingResults += "Length = \t" + num2str(SLD) + " A" + "\r"
			break
		case "Ellip. Cylinder": // execute if case matches expression
			//Ellip. Cylinder Model
			//ElCylParNames = {"Prefactor","Radius","Length","SLD","AspectRatio"}
			WAVE ElCylPar = root:Packages:Irena:CylinderModels:ElCylPar
			Prefactor      = ElCylPar[0][0]
			Radius         = ElCylPar[1][0]
			Length         = ElCylPar[2][0]
			SLD            = ElCylPar[3][0]
			AspectRatio    = ElCylPar[4][0]
			PrefactorErr   = ElCylPar[0][4]
			RadiusErr      = ElCylPar[1][4]
			LengthErr      = ElCylPar[2][4]
			SLDErr         = ElCylPar[3][4]
			AspectRatioErr = ElCylPar[4][4]
			FittingResults = "Radius \t\t= \t" + num2str(Radius) + " +/- " + num2str(RadiusErr) + "\r"
			//FittingResults += "Shell Thick = "+num2str(ShellTh)+"A"+" +/- "+num2str(ShellThErr)+"\r"
			FittingResults += "AspectRatio = " + num2str(ShellTh) + " +/- " + num2str(AspectRatioErr) + "\r"
			FittingResults += "SLD = \t" + num2str(SLD) + " A" + " +/- " + num2str(SLDErr)
			FittingResults += "Length = \t" + num2str(SLD) + " A"
			break
		case "Core Shell Ellip. Cylinder": // execute if case matches expression
			//Core Shell Ellip. Cylinder Model
			WAVE CSElCylPar = root:Packages:Irena:CylinderModels:CSElCylPar
			//CSElCylParNames = 		{"Prefactor","Radius","Length","SLD","ShellThickness","AspectRatio"}
			Prefactor       = CSElCylPar[0][0]
			Radius          = CSElCylPar[1][0]
			Length          = CSElCylPar[2][0]
			SLD             = CSElCylPar[3][0]
			ShellTh         = CSElCylPar[4][0]
			AspectRatio     = CSElCylPar[5][0]
			PrefactorErr    = CSElCylPar[0][4]
			RadiusErr       = CSElCylPar[1][4]
			LengthErr       = CSElCylPar[2][4]
			SLDErr          = CSElCylPar[3][4]
			ShellThErr      = CSElCylPar[4][4]
			AspectRatioErr  = CSElCylPar[5][4]
			FittingResults  = "Radius \t\t= \t" + num2str(Radius) + " +/- " + num2str(RadiusErr) + "\r"
			FittingResults += "Shell Thick = " + num2str(ShellTh) + "A" + " +/- " + num2str(ShellThErr) + "\r"
			FittingResults += "AspectRatio = " + num2str(ShellTh) + " +/- " + num2str(AspectRatioErr) + "\r"
			FittingResults += "SLD = \t" + num2str(SLD) + " A" + " +/- " + num2str(SLDErr) + "\r"
			FittingResults += "Length = \t" + num2str(SLD) + " A" + "\r"
			break
		case "Profile CS Ellip. Cylinder": // execute if case matches expression
			//Profile CS Ellip. Cylinder Model
			WAVE ProfCSElCylPar = root:Packages:Irena:CylinderModels:ProfCSElCylPar
			//ProfCSElCylParNames = {"Prefactor","Radius","Length","AspectRatio","Shell1Th","Shell1SLD", "Shell2th", "Shell2SLD"}
			Prefactor       = ProfCSElCylPar[0][0]
			Radius          = ProfCSElCylPar[1][0]
			Length          = ProfCSElCylPar[2][0]
			AspectRatio     = ProfCSElCylPar[3][0]
			Shell1Th        = ProfCSElCylPar[4][0]
			Shell1SLD       = ProfCSElCylPar[5][0]
			Shell2th        = ProfCSElCylPar[6][0]
			Shell2SLD       = ProfCSElCylPar[7][0]
			PrefactorErr    = ProfCSElCylPar[0][4]
			RadiusErr       = ProfCSElCylPar[1][4]
			LengthErr       = ProfCSElCylPar[2][4]
			AspectRatioErr  = ProfCSElCylPar[3][4]
			Shell1ThErr     = ProfCSElCylPar[4][4]
			Shell1SLDErr    = ProfCSElCylPar[5][4]
			Shell2ThErr     = ProfCSElCylPar[6][4]
			Shell2SLDErr    = ProfCSElCylPar[7][4]
			FittingResults  = "Radius \t\t= \t" + num2str(Radius) + " +/- " + num2str(RadiusErr) + "\r"
			FittingResults += "AspectRatio = " + num2str(ShellTh) + " +/- " + num2str(AspectRatioErr) + "\r"
			FittingResults += "Shell 1 and 3 Thickness = " + num2str(Shell1Th) + "A" + " +/- " + num2str(Shell1ThErr) + "\r"
			FittingResults += "Shell 1 and 3 SLD = " + num2str(Shell1SLD) + " +/- " + num2str(Shell1SLDErr) + "\r"
			FittingResults += "Shell 2 Thickness = " + num2str(Shell2Th) + "A" + " +/- " + num2str(Shell2ThErr) + "\r"
			FittingResults += "Shell 2 SLD = " + num2str(Shell2SLD) + " +/- " + num2str(Shell2SLDErr) + "\r"
			FittingResults += "Length = \t" + num2str(SLD) + " A" + "\r"
			break

	endswitch
	//	NVAR UseUnified = root:Packages:Irena:CylinderModels:UseUnified
	//	if(UseUnified)
	//		FittingResults+="\rModeling also included low-q power-law slope\r"
	//		Wave UnifiedPar = root:Packages:Irena:CylinderModels:UnifiedPar
	//		//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
	//		variable UnifRg			= UnifiedPar[1][0]
	//		variable UnifG			= UnifiedPar[0][0]
	//		variable UnifGError		= UnifiedPar[0][4]
	//		variable UnifRgError	= UnifiedPar[1][4]
	//		variable UnifPwrlawP	= UnifiedPar[3][0]
	//		variable UnifPwrlawB	= UnifiedPar[2][0]
	//		variable UnifPwrlawPError	= UnifiedPar[3][4]
	//		variable UnifPwrlawBError	= UnifiedPar[2][4]
	//		FittingResults+="Low-Q G = "+num2str(UnifG)+" +/- "+num2str(UnifGError)+"\r"
	//		FittingResults+="Low-Q Rg = "+num2str(UnifRg)+" +/- "+num2str(UnifRgError)+"\r"
	//		FittingResults+="Low-Q B = "+num2str(UnifPwrlawB)+" +/- "+num2str(UnifPwrlawBError)+"\r"
	//		FittingResults+="Low-Q P = "+num2str(UnifPwrlawP)+" +/- "+num2str(UnifPwrlawPError)+"\r"
	//	endif
	NVAR SASBackground = root:Packages:Irena:CylinderModels:SASBackground
	FittingResults += "SAS background included = " + num2str(SASBackground) + "\r"
	DoWIndow IR3F_LogLogDataDisplay
	if(V_Flag)
		IR1_AppendAnyGraph("IR3F_LogLogDataDisplay")
	endif
	DoWIndow IR3F_FittingDataDisplay
	if(V_Flag)
		IR1_AppendAnyGraph("IR3F_FittingDataDisplay")
	endif
	IR1_AppendAnyText(FittingResults, 0)
	IR1_AppendAnyText("******************************************\r", 0)
	SetDataFolder OldDf
	SVAR/Z nbl = root:Packages:Irena:ResultsNotebookName
	DoWindow/F $nbl
	//MoveWindow /W=IR3F_LogLogDataDisplay 400, 30, 980, 530
	//MoveWindow /W=IR3F_LogLogDataDisplay 521,10,1383,750
	//AutoPositionWindow/M=1 /R=IR3F_CylinderModelsPanel	IR3F_LogLogDataDisplay
End
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//			Spherical calculations, volume calibration is wonky...
//			most calcualtions tested agains MOdeling package simple (AR=1) calculations
//			had to add arbitrary scaling factors which is nto clear whey they come from.
//			therefore I would be worried about volume fractions etc.
//*****************************************************************************************************************
//*****************************************************************************************************************
//	Calculating intensity for cylinder
//*****************************************************************************************************************
//verified working against Modeling cylinder, 2000A long, 50A radius, SLD/contrast = 1, need to scale Intensity by 6000???

Function IR3F_CalculateCylinder(Qvalues, Intensity, Radius, Length, SLD)
	variable Radius, Length, SLD
	WAVE Qvalues
	WAVE Intensity

	//number of integration points impacts high-q oscillations
	//181/91 seem to be reasonbale numbers which guarrantees good enough values
	make/FREE/N=(NumPntsAlpha)/D IntegralWv
	SetScale/I x, 0, (pi / 2), "", IntegralWv
	variable i
	//variable Volume= pi * Radius^2 * Length		//in A^3, *1e-24 in cm^3
	for(i = 0; i < numpnts(Intensity); i += 1)
		multithread IntegralWv = SLD * IR3F_FormFactorCylinder(Qvalues[i], Radius, Length, x) //calculate form factor F*volume, needed for othe calculations
		IntegralWv   = IntegralWv^2                    // F^2
		IntegralWv   = IntegralWv * sin(x)             //multiply by sin alpha which is x from 0 to 90 deg
		Intensity[i] = 4 * area(IntegralWv, 0, pi / 2) //integration
	endfor
	// 1e-24, 1e-48 ---> 1e-24 scales units from A to cm^3 for volume, 1e-48 since it is volume^2
	// SLD is 10^10 cm^-2, we have 10^20 cm^-4
	// 1e-48 * 1e20 = 1e-28
	Intensity = Intensity * 1e-8 //returns SLD^2*F^2*V^2 in cm^-1 SLD^2 10^20 cm-4, V^2 10^-48 cm6, why is this not cm-1???
	Intensity = Intensity / 6000 //scaling to fix to Modeling calculations. Not sure why
End
//*****************************************************************************************************************
// this is Calculating intensity for core shell cylinder assuming outside and inside is solvent, uses SLD as difference between solvent and material
//*****************************************************************************************************************
//verified working against Modeling core shell cylinder, 2000A long, 50A radius, Shell Th=25A,  SLD/contrast = 1, need to scale Intensity by 12000???
Function IR3F_CalculateCSCylinder(Qvalues, Intensity, Radius, Length, SLD, WallThickness)
	variable Radius, Length, SLD, WallThickness
	WAVE Qvalues
	WAVE Intensity

	//number of integration points impacts high-q oscillations
	//181/91 seem to be reasonbale numbers which guarrantees good enough values
	make/FREE/N=(NumPntsAlpha)/D IntegralWv
	SetScale/I x, 0, (pi / 2), "", IntegralWv
	variable i
	for(i = 0; i < numpnts(Intensity); i += 1)
		multithread IntegralWv = (SLD * (IR3F_FormFactorCylinder(Qvalues[i], Radius + WallThickness, Length, x) - IR3F_FormFactorCylinder(Qvalues[i], Radius, Length, x)))^2 //calculate form factor (SLD*F*Vol)^2
		IntegralWv   = IntegralWv * sin(x)  //multiply by sin alpha which is x from 0 to 90 deg
		Intensity[i] = 4 * area(IntegralWv) //integration
	endfor
	Intensity = Intensity * 1e-8  //returns SLD^2*F^2*V^2 in cm^-1 SLD^2 10^20 cm-4, V^2 10^-48 cm6, why is this not cm-1???
	Intensity = Intensity / 12000 //scaling to fix to Modeling calculations. Not sure why
End
//*****************************************************************************************************************
//	form factor of cylinder, internal function of stuff way above
//*****************************************************************************************************************
//
threadsafe static Function IR3F_FormFactorCylinder(Qvalue, radius, Length, Alpha)
	variable Qvalue, radius, Length, Alpha
	//does the math for cylinder Form factor function, includes volume scaling

	variable volume
	volume = 2 * pi * radius^2 * Length //in A^3
	variable LargeBesArg = 0.5 * Qvalue * length * Cos(Alpha)
	variable LargeBes
	LargeBes = sinc(LargeBesArg)
	variable SmallBesArg = Qvalue * radius * Sin(Alpha)
	variable SmallBessDivided
	if(SmallBesArg < 1e-10)
		SmallBessDivided = 0.5
	else
		SmallBessDivided = Besselj(1, SmallBesArg) / SmallBesArg
	endif
	return volume * LargeBes * SmallBessDivided

End
//*****************************************************************************************************************
//		Calculate intensity of core shell elliptical cylinder
//*****************************************************************************************************************
//verified working against Modeling cylinder, 2000A long, 50A radius, SLD/contrast = 1, need to scale Intensity by 4e4???

Function IR3F_CalculateEplipCylinder(Qvalues, Intensity, radius, Length, SLD, AspectRatio)
	variable Length, radius, AspectRatio, SLD
	WAVE Qvalues
	WAVE Intensity

	//number of integration points impacts high-q oscillations
	//181/91 seem to be reasonbale numbers which guarrantees good enough values
	make/FREE/N=(NumPntsAlpha)/D IntegralAlphaWv
	make/FREE/N=(NumPntsPsi)/D IntegralPsiWv
	SetScale/I x, 0, (pi / 2), "rad", IntegralAlphaWv
	SetScale/I x, 0, (pi), "rad", IntegralPsiWv
	variable i, j
	variable Qval, tempFFIntegral, Psi
	for(i = 0; i < numpnts(Intensity); i += 1) //this is Int/Q point integration loop
		Qval = Qvalues[i]
		for(j = 0; j < numpnts(IntegralPsiWv); j += 1) //thsi is psi integration loop
			Psi = j * dimDelta(IntegralPsiWv, 0)
			multithread IntegralAlphaWv = sin(x) * (IR3F_FormFactorElipCylinder(Qval, radius, AspectRatio, Length, x, Psi))^2 //this is alpha integration
			IntegralPsiWv[j] = 4 * area(IntegralAlphaWv) //this is alpha integration
		endfor
		Intensity[i] = 2 * SLD * area(IntegralPsiWv) //integration over Psi
	endfor
	//Intensity*=approxVol^2		//Contained in FF calculation already.
	Intensity *= 1e-8
	Intensity  = Intensity / 4e4 //scaling to fix to Modeling calculations. Not sure why
End
//*****************************************************************************************************************
//	core shell cylinder WITH elliptical cross section
//*****************************************************************************************************************
//verified working against Modeling core shell cylinder, 2000A long, 50A radius, Shell Th=25A,  SLD/contrast = 1, need to scale Intensity by 8e4???
Function IR3F_CalcCoreShellEplipCylinder(Qvalues, Intensity, radius, Length, SLD, ShellThick, AspectRatio)
	variable Length, radius, AspectRatio, ShellThick, SLD
	WAVE Qvalues
	WAVE Intensity
	//number of integration points impacts high-q oscillations
	//181/91 seem to be reasonbale numbers which guarrantees good enough values
	make/FREE/N=(NumPntsAlpha)/D IntegralAlphaWv
	make/FREE/N=(NumPntsPsi)/D IntegralPsiWv
	SetScale/I x, 0, (pi / 2), "rad", IntegralAlphaWv
	SetScale/I x, 0, (pi), "rad", IntegralPsiWv
	variable i, j
	variable Qval, tempFFIntegral, Psi
	for(i = 0; i < numpnts(Intensity); i += 1) //this is Int/Q point integration loop
		Qval = Qvalues[i]
		for(j = 0; j < numpnts(IntegralPsiWv); j += 1) //thsi is psi integration loop
			Psi = j * dimDelta(IntegralPsiWv, 0)
			multithread IntegralAlphaWv = sin(x) * (IR3F_FormFactorElipCylinder(Qval, (radius + ShellThick), AspectRatio, Length, x, Psi) - IR3F_FormFactorElipCylinder(Qval, radius, AspectRatio, Length, x, Psi))^2 //this is alpha integration
			IntegralPsiWv[j] = 4 * area(IntegralAlphaWv) //this is alpha integration
		endfor
		Intensity[i] = 2 * SLD * area(IntegralPsiWv) //integration over Psi
	endfor
	Intensity *= 1e-8
	Intensity  = Intensity / 4e5 //scaling to fix to Modeling calculations. Not sure why
End
//*****************************************************************************************************************
// 	calculate intensity for core shell cylinder (with any cross section) using Profile wave
//*****************************************************************************************************************
//verified working against Modeling core shell cylinder, 2000A long, 50A radius, Shell Th=25A,  SLD/contrast = 1, need to scale Intensity by 4e6???
Function IR3F_CalcCSElProfile(Qvalues, Intensity, length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD, calledFromFitting)
	variable length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD, calledFromFitting
	WAVE Qvalues
	WAVE Intensity

	IR3F_SetupWarningPanel(calledFromFitting, 0)
	NVAR ProfileNumPoints = root:Packages:Irena:CylinderModels:ProfileNumPoints
	IR3F_CreateParametrizedProfile(ProfileNumPoints, length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD)
	WAVE Profile //this is SLD steps, x scaling gives step, x value is radius
	variable step = dimDelta(Profile, 0)

	variable startT, endT
	startT = ticks

	multithread Intensity = IR3F_CSElProfileInt(Qvalues[p], profile, AspectRatio, Length)

	endT = (ticks - startT) / 60
	print "Time to calculate was = " + num2str(endT) + " seconds"
	IR3F_KillWarningPanel()
	Intensity *= 1e-13 //scaling to fix to Modeling calculations. Not sure why
End
//*******************************************************************************************************************************************
Function IR3F_CalcCSElProfile2(Qvalues, Intensity, length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD, Shell3th, Shell3SLD, calledFromFitting)
	variable length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD, Shell3th, Shell3SLD, calledFromFitting
	WAVE Qvalues
	WAVE Intensity

	IR3F_SetupWarningPanel(calledFromFitting, 0)
	NVAR ProfileNumPoints = root:Packages:Irena:CylinderModels:ProfileNumPoints
	IR3F_CreateParametrizedProfile2(ProfileNumPoints, length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD, Shell3th, Shell3SLD)
	WAVE Profile //this is SLD steps, x scaling gives step, x value is radius
	variable step = dimDelta(Profile, 0)

	variable startT, endT
	startT = ticks

	multithread Intensity = IR3F_CSElProfileInt(Qvalues[p], profile, AspectRatio, Length)

	endT = (ticks - startT) / 60
	print "Time to calculate was = " + num2str(endT) + " seconds"
	IR3F_KillWarningPanel()
	Intensity *= 1e-13 //scaling to fix to Modeling calculations. Not sure why
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function IR3F_SetupWarningPanel(calledFromFitting, FittingMessage)
	variable calledFromFitting, FittingMessage

	KillWIndow/Z CSCylinderProcessRunning

	if(!calledFromFitting)
		if(FittingMessage)
			print "*** Profile CS Ellip. Cylinder model ***********"
			print "This Fitting takes very long, depending on computer"
			print "Igor will look like it is hanging. "

			NewPanel/K=1/W=(395, 325, 750, 444)/N=CSCylinderProcessRunning as "Profile CS El. Cyliner warning"
			ModifyPanel cbRGB=(65535, 43690, 0)
			SetDrawLayer UserBack
			SetDrawEnv fsize=20, textrgb=(52428, 1, 1)
			DrawText 47, 40, "Profile CS El. Cyliner model ..."
			DrawText 47, 65, "is FITTING your data "
			DrawText 47, 90, "eventually, this window WILL disapper"
			DoUpdate/W=CSCylinderProcessRunning
		else
			print "*** Profile CS Ellip. Cylinder model ***********"
			print "This calculation takes 2-60sec, depending on computer"
			print "Igor will look like it is hanging. "

			NewPanel/K=1/W=(395, 325, 750, 444)/N=CSCylinderProcessRunning as "Profile CS El. Cyliner warning"
			ModifyPanel cbRGB=(65535, 43690, 0)
			SetDrawLayer UserBack
			SetDrawEnv fsize=20, textrgb=(52428, 1, 1)
			DrawText 47, 40, "Profile CS El. Cyliner model ..."
			DrawText 47, 65, "is calculating your data "
			DrawText 47, 90, "eventually, this window WILL disapper"
			DoUpdate/W=CSCylinderProcessRunning
		endif
	endif
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function IR3F_KillWarningPanel()
	KillWIndow/Z CSCylinderProcessRunning
	print "Done with Profile CS El. Cyliner Model calculations"
	print "*****************************************************************"
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

////*****************************************************************************************************************
//// 	calculate intensity for core shell cylinder (with any cross section) using Profile wave try using G matrix
////*****************************************************************************************************************
//Function CalcCSProfileGM(Qvalues,Intensity, length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD)
//	variable length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD
//	wave Qvalues
//	wave Intensity
//
//	string OldDf = GetDataFOlder(1)
//	//GMatrix is in root:Packages:Irena:CylinderModels:
//	SetDataFolder root:Packages:Irena:CylinderModels
//
//	CreateParametrizedProfile(length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD)
//	wave Profile		//this is SLD steps, x scaling gives step, x value is radius
//	variable step = dimDelta(Profile,0)
//
//	Wave/Z GMatrix=root:Packages:Irena:CylinderModels:GMatrix
//	if(!WaveExists(Gmatrix))
//		Make/N=(10,10) Gmatrix
//	endif
//	//now verify the GMatrix is usable for current data, check the wave note...
//	string oldNote, newNote
//	oldNote=note(Gmatrix)
//	variable Recalculate=0
//	variable M=numpnts(Qvalues)
//	variable N=numpnts(Profile)
//	variable Q5=Qvalues[5]
//	NVAR ProfileMaxX=root:Packages:Irena:CylinderModels:ProfileMaxX
//	variable i, currentR
//	string reason=""
//	if(dimsize(Gmatrix,0)!=M || dimsize(Gmatrix,1)!=N ||recalculateGM)		//check the dimensions, this needs to be right first
//		Recalculate=1
//		reason += "Matrix dimension"
//	endif
//	if(cmpstr(StringByKey("length", OldNote),num2str(length))!=0 || cmpstr(StringByKey("AspectRatio", OldNote),num2str(AspectRatio))!=0)		//check the Particle shape parameter 1 and 2
//		Recalculate=1
//		reason += "length,AspectRatio "
//	endif
//	if(cmpstr(StringByKey("Q5", OldNote),num2str(Q5))!=0 || cmpstr(StringByKey("ProfileMaxX", OldNote),num2str(ProfileMaxX))!=0)		//check the Particle shape parameter 1 and 2
//		Recalculate=1
//		reason += "ProfileMax,  Q5"
//	endif
//	if(Recalculate)
//		redimension/D/N=(M,N) Gmatrix				//redimension G matrix to right size
//		Make/D/Free/N=(M) TempWave 					//create temp work wave
//		For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
//			currentR=i*step								//this is current radius
//			multithread TempWave = CSElProfileIntGM(Qvalues[p],currentR, step,AspectRatio, Length)		//this works still with F*V, not F2*V2
//			Gmatrix[][i]=TempWave[p]							//and here put into G wave the "intensity" from each radial bin
//		endfor
//		NewNote = "length:"+num2str(length)+";"+"AspectRatio:"+num2str(AspectRatio)+";"+"Q5:"+num2str(Q5)+";"+"ProfileMaxX:"+num2str(ProfileMaxX)+";"
//		note/K Gmatrix
//		note Gmatrix, NewNote
//
//	endif
//	//MatrixOP/O GmatrixTemp = Gmatrix * 1e20		//this multiplies by scattering contrast
//	//MatrixOP/O GmatrixTemp = Gmatrix * 5e-15			//this multiplies by scattering contrast
//	//MatrixOP/O GmatrixTemp = Gmatrix * 5e-6			//this multiplies by scattering contrast
//	//MatrixOp/O Intensity = 	powR(GmatrixTemp x powR(Profile,2),2)
//	MatrixOp/O Intensity = 	Gmatrix x Profile
//	Intensity = Intensity^2
//	Intensity *=1e-13
//
//
//	setDataFolder OldDf
//
//end

//*****************************************************************************************************************
//	this creates density profile with user defined No of steps; profile is parametrized to bunch of parameters
//*****************************************************************************************************************
Function IR3F_CreateParametrizedProfile(ProfileNumPoints, length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD)
	variable ProfileNumPoints, length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD

	setDataFolder root:Packages:Irena:CylinderModels:
	make/O/N=(ProfileNumPoints) Profile
	NVAR ProfileMaxX = root:Packages:Irena:CylinderModels:ProfileMaxX
	SetScale/P x, 0, (ProfileMaxX / 100), "A", Profile
	variable step = dimDelta(Profile, 0)
	//define profile here...
	//Profile is:
	// from 0 to radius SLD=0
	// from radius to radius+Shell1th SLD=Shell1SLD
	// from radius+Shell1th to radius+Shell1th+Shell2th SLD= Shell2SLD
	// from radius+Shell1th+Shell2th to radius+Shell1th+Shell2th+Shell1th SLD=Shell1SLD
	// SLD=0 beyond
	//
	Profile = 0
	variable LastRadius = radius
	Profile[0, LastRadius / step]                                    = 0         //code
	Profile[LastRadius / step + 1, (LastRadius + Shell1th) / step]   = Shell1SLD //shell1
	LastRadius                                                       = LastRadius + Shell1th
	Profile[(LastRadius) / step + 1, (LastRadius + Shell2th) / step] = Shell2SLD //shell2
	LastRadius                                                       = LastRadius + Shell2th
	Profile[(LastRadius) / step + 1, (LastRadius + Shell1th) / step] = Shell1SLD //shell1 again
	LastRadius                                                       = LastRadius + Shell1th

	DoWIndow IR3F_SLDProfile
	if(!V_Flag)
		Display/W=(521, 750, 1383, 1100)/K=1/N=IR3F_SLDProfile
		AppendToGraph/W=IR3F_SLDProfile Profile
		Label left, "Δ SLD [10\\S10 \\Mcm\\S2\\M]"
		Label bottom, "Radial distance [Angstroms]"
		ModifyGraph mirror=1
		SetAxis/A
		AutoPositionWindow/M=1/R=IR3F_LogLogDataDisplay IR3F_SLDProfile
	else
		DoWIndow/F IR3F_SLDProfile
	endif

End
//*****************************************************************************************************************
Function IR3F_CreateParametrizedProfile2(ProfileNumPoints, length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD, Shell3th, Shell3SLD)
	variable ProfileNumPoints, length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD, Shell3th, Shell3SLD

	setDataFolder root:Packages:Irena:CylinderModels:
	make/O/N=(ProfileNumPoints) Profile
	NVAR     ProfileMaxX = root:Packages:Irena:CylinderModels:ProfileMaxX
	variable maxRadval   = radius + 4 * Shell1th + 2 * Shell2th + Shell3th
	if(ProfileMaxX < 1.05 * maxRadval)
		ProfileMaxX = ceil(1.05 * maxRadval)
	endif

	SetScale/P x, 0, (ProfileMaxX / ProfileNumPoints), "A", Profile
	variable step = dimDelta(Profile, 0)
	//define profile here...
	//Profile is:
	// from 0 to radius SLD=0
	// from radius to radius+Shell1th SLD=Shell1SLD
	// from radius+Shell1th to radius+Shell1th+Shell2th SLD= Shell2SLD
	// from radius+Shell1th+Shell2th to radius+Shell1th+Shell2th+Shell1th SLD=Shell1SLD
	// SLD=0 beyond
	//
	//check that we have large enough radius range
	Profile = 0
	variable LastRadius = radius
	Profile[0, LastRadius / step]                                    = 0         //code
	Profile[LastRadius / step + 1, (LastRadius + Shell1th) / step]   = Shell1SLD //shell1
	LastRadius                                                       = LastRadius + Shell1th
	Profile[(LastRadius) / step + 1, (LastRadius + Shell2th) / step] = Shell2SLD //shell2
	LastRadius                                                       = LastRadius + Shell2th
	Profile[(LastRadius) / step + 1, (LastRadius + Shell1th) / step] = Shell1SLD //shell1 again
	LastRadius                                                       = LastRadius + Shell1th
	Profile[(LastRadius) / step + 1, (LastRadius + Shell3th) / step] = Shell3SLD //shell3 = core of shell
	LastRadius                                                       = LastRadius + Shell3th
	Profile[(LastRadius) / step + 1, (LastRadius + Shell1th) / step] = Shell1SLD //shell1 again
	LastRadius                                                       = LastRadius + Shell1th
	Profile[(LastRadius) / step + 1, (LastRadius + Shell2th) / step] = Shell2SLD //shell2
	LastRadius                                                       = LastRadius + Shell2th
	Profile[(LastRadius) / step + 1, (LastRadius + Shell1th) / step] = Shell1SLD //shell1 again

	DoWIndow IR3F_SLDProfile
	if(!V_Flag)
		Display/W=(521, 750, 1383, 1100)/K=1/N=IR3F_SLDProfile
		AppendToGraph/W=IR3F_SLDProfile Profile
		Label left, "Δ SLD [10\\S10 \\Mcm\\S2\\M]"
		Label bottom, "Radial distance [Angstroms]"
		ModifyGraph mirror=1
		SetAxis/A
		AutoPositionWindow/M=1/R=IR3F_LogLogDataDisplay IR3F_SLDProfile
	else
		DoWIndow/F IR3F_SLDProfile
	endif

End
//*****************************************************************************************************************
//	internal function for core shell Profile calculations
//*****************************************************************************************************************
threadsafe Function IR3F_CSElProfileInt(Qval, profile, AspectRatio, Length)
	variable Qval, AspectRatio, Length
	WAVE profile
	//notes: There are two ways to calculate Form factor * Volume for layered profile here.
	//			define A(R) = V(R)*BessJ(R) - ignore q in notation, this is all done for each q point
	//this is explained in my notes, is based on paper on Core-shell-shell-shell sphere and sasView Form factors.
	//method 1 - uses differecnes in SLD edges for each layer.
	//F(q) +=
	//core 	(SLDc-SLD1) * A(R)
	//shell 1	(SLD1-SLD2) * A(R1)
	//shell 2	(SLD2-SLD3) * A(R2)
	//....
	//method 2 - uses differecne in Form factor for each layer edges and uses SLD for the layer.
	//F(q) +=
	//SLDc * A(R)
	//SLD1 * (A(R1) - A(R))
	//SLD2 * (A(R2) - A(R1))
	//
	//Method 2 calculates Form factor 2x for each layer which has non-0 SLD while method 1 calculates Form factor only for layers where there is change in SLD
	//as result, both methods give same Intensity, but method 1 is about 2.2x faster than method 2.
	//  Time to calculate = 14.65 seconds, method UseNewCSProfileCalculation = 0
	//  Time to calculate = 6.5333 seconds, method UseNewCSProfileCalculation = 1

	make/FREE/N=(NumPntsAlpha)/D IntegralAlphaWv
	make/FREE/N=(NumPntsPsi)/D IntegralPsiWv
	SetScale/I x, 0, (pi / 2), "rad", IntegralAlphaWv
	SetScale/I x, 0, (pi), "rad", IntegralPsiWv
	variable tempFFIntegral
	variable SLD, radius, Psi, k, j, i, step
	step            = dimDelta(IntegralPsiWv, 0)
	IntegralAlphaWv = 0

	if(UseNewCSProfileCalculation) //this is using difference in Profile and not difference in Form factors
		//this method is about 2.5x faster than CSCylinderSliceFF2
		//see my notes
		for(j = 0; j < numpnts(IntegralPsiWv); j += 1) //thsi is psi integration loop
			Psi              = j * step
			IntegralAlphaWv  = sin(x) * IR3F_CSCylinderSliceFF2Diff(profile, Qval, AspectRatio, Length, x, Psi) //the CSCylinderSliceFF2 calculates SUM(F2*V2*SLD^2) over all Profile points summed together for one Q.
			IntegralPsiWv[j] = 4 * area(IntegralAlphaWv)                                                        //this is alpha integration
		endfor
		tempFFIntegral = 2 * area(IntegralPsiWv) //integration over Psi
	else //OLD method, uses differecne in Form factors for every radius step
		for(j = 0; j < numpnts(IntegralPsiWv); j += 1) //thsi is psi integration loop
			Psi              = j * step
			IntegralAlphaWv  = sin(x) * IR3F_CSCylinderSliceFF2(profile, Qval, AspectRatio, Length, x, Psi) //the CSCylinderSliceFF2 calculates SUM(F2*V2*SLD^2) over all Profile points summed together for one Q.
			IntegralPsiWv[j] = 4 * area(IntegralAlphaWv)                                                    //this is alpha integration
		endfor
		tempFFIntegral = 2 * area(IntegralPsiWv) //integration over Psi
	endif
	return tempFFIntegral
End
//*****************************************************************************************************************
//	internal function for function above, for core shell Profile calculations direct
//*****************************************************************************************************************
threadsafe static Function IR3F_CSCylinderSliceFF2(profile, Qval, AspectRatio, Length, xval, Psi)
	WAVE profile
	variable Qval, AspectRatio, Length, xval, Psi

	variable i, TempFFval, SLD, Radius
	variable StoredFF, LargeFF, SmallFF
	variable step = dimDelta(Profile, 0)
	for(i = 0; i < numpnts(Profile); i += 1)
		SLD    = Profile[i] //this is SLD in the Profile wave
		Radius = i * step   //this is x value of Profile wave, assume x starts from 0
		if(abs(SLD) > 1e-28)
			if(abs(StoredFF) > 1e-28)
				SmallFF = StoredFF
			else
				SmallFF = IR3F_FormFactorElipCylinder(Qval, radius, AspectRatio, Length, xval, Psi)
			endif
			LargeFF    = IR3F_FormFactorElipCylinder(Qval, (radius + step), AspectRatio, Length, xval, Psi)
			TempFFval += SLD * (LargeFF - SmallFF)
			StoredFF   = LargeFF
		else
			StoredFF = 0
		endif
	endfor
	return TempFFval^2
End
//*****************************************************************************************************************
//this method is about 2.5x faster than CSCylinderSliceFF2
threadsafe static Function IR3F_CSCylinderSliceFF2Diff(profile, Qval, AspectRatio, Length, xval, Psi)
	WAVE profile
	variable Qval, AspectRatio, Length, xval, Psi

	variable i, TempFFval, Radius
	variable MaxProfPnts = numpnts(profile)
	variable step        = dimDelta(profile, 0)

	Differentiate/P profile/D=DiffProfile //this is 20% faster than brute force code below ...
	//Make/Free/N=(MaxProfPnts) DiffProfile
	//DiffProfile[0,MaxProfPnts-2] = profile[p] - profile [p+1]

	for(i = 0; i < MaxProfPnts; i += 1)
		//SLD 	= Diffprofile[i]		//this is point-to-point delta - SLD in the Profile wave
		//using Diffprofile[i] directly below is marginally faster.
		Radius = i * step //this is Radius value based on x of Profile wave, assume x starts from 0
		if(abs(Diffprofile[i]) > 1e-28)
			TempFFval += Diffprofile[i] * IR3F_FormFactorElipCylinder(Qval, radius, AspectRatio, Length, xval, Psi)
		endif
	endfor
	return TempFFval^2
End
//*****************************************************************************************************************
//	internal function for core shell Profile calculations using GM
//*****************************************************************************************************************
//threadsafe static function IR3F_CSElProfileIntGM(Qval,radius, step,AspectRatio, Length)
//		variable Qval, AspectRatio, Length, radius, step
//		//this still returns F*V averaged for R and Q
//
//		//number of integration points impacts high-q oscillations
//		//181/91 seem to be reasonable numbers which guarrantees good enough values
//		make/free/N=121/D IntegralAlphaWv	//181 takes just too long, this works basically also.
//		make/free/N=121/D IntegralPsiWv
//		SetScale/I x 0,(pi/2),"rad", IntegralAlphaWv
//		SetScale/I x 0,(pi/2),"rad", IntegralPsiWv
//		variable tempFFIntegral
//		variable Psi, k, j, i, PsiStep
//		PsiStep = dimDelta(IntegralPsiWv,0)
//		IntegralAlphaWv = 0
//		For(j=0;j<numpnts(IntegralPsiWv);j+=1)			//thsi is psi integration loop
//				Psi = j*PsiStep
//				IntegralAlphaWv = sin(x) * IR3F_CSCylinderSliceFFGM(radius, step, Qval, AspectRatio, Length, x, Psi)		//the CSCylinderSliceFF2GM calculates F*V for one radius and one Q.
//				IntegralPsiWv[j] = 4*area(IntegralAlphaWv)	//this is alpha/x integration
//		endfor
//		tempFFIntegral=4*area(IntegralPsiWv)					//integration over Psi
//		return tempFFIntegral
//end
////*****************************************************************************************************************
////	internal function for function above, for core shell Profile calculations using GM
////*****************************************************************************************************************
//threadsafe static Function IR3F_CSCylinderSliceFFGM(radius, step, Qval, AspectRatio, Length, x, Psi)
//	variable Qval, AspectRatio, Length, x, Psi, radius, step
//
//	variable TempFFval
//	variable LargeFF, SmallFF
//	LargeFF = IR3F_FormFactorElipCylinder(Qval, (radius+step), AspectRatio, Length, x, Psi)
//	if(radius<1e-3)
//		return LargeFF
//	endif
//	SmallFF = IR3F_FormFactorElipCylinder(Qval, radius, AspectRatio, Length, x, Psi)
//	TempFFval = (LargeFF - SmallFF)
//	return TempFFval
//end
//*****************************************************************************************************************
//	Form factor of core shell elliptical cylinder, internal function of stuff above
//*****************************************************************************************************************
threadsafe static Function IR3F_FormFactorElipCylinder(Qvalue, radius, AxisRatio, Length, Alpha, Psi)
	variable Qvalue, radius, AxisRatio, Length, Alpha, Psi
	//note, radius is the small radius and AxisRatio > 1 - using:
	//https://www.sasview.org/docs/user/models/elliptical_cylinder.html
	if(Alpha < 1e-10)
		return 0
	endif
	variable volume
	volume = pi * radius * radius * AxisRatio * Length
	//This is specific Psi orientation for integration which needs to be done above...
	variable rprime     = (radius / sqrt(2)) * sqrt((1 + AxisRatio^2) + (1 - AxisRatio^2) * cos(Psi))
	variable aval       = Qvalue * rprime * sin(Alpha)
	variable bval       = Qvalue * Length * cos(Alpha) / 2
	variable FormFactor = volume * 2 * Besselj(1, aval) * sinc(bval) / aval

	return FormFactor
End
//*****************************************************************************************************************
//	this fits Core shell (circle profile) fitting function
//*****************************************************************************************************************

//
//Function Fit_ParCSProfile(pw, yw, xw) : FitFunc
//	WAVE pw, yw, xw
//
//	// Duplicate/FREE xw, yw
//	variable length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD,background
//	Length		=pw[0]
//	radius		=pw[1]
//	AspectRatio	=pw[2]
//	Shell1th	=pw[3]
//	Shell1SLD	=pw[4]
//	Shell2th	=pw[5]
//	Shell2SLD	=pw[6]
//	background	=pw[7]
//	NewDataFolder/O/S root:FitCSProfile
//	Duplicate/O yw, Intensity
//	Duplicate/O xw, Qvalues
//	ParametrizedCalcCSProfile(length, radius, AspectRatio, Shell1th, Shell1SLD, Shell2th, Shell2SLD,background)
//	yw = Intensity
//	yw +=background
//End
//

//*****************************************************************************************************************
//	this is Calculating intensity for SLD profile for Core shell (circular cross section)
//*****************************************************************************************************************

//Function CalculateProfile(Qvalues,Intensity, Profile, Length)
//	variable Length
//	wave Qvalues
//	wave Intensity
//	wave Profile		//this is SLD steps, x scaling gives step, x value is radius
//
//	variable step = dimDelta(Profile,0)
//
//	//Duplicate/Free Intensity, TempValues
//	make/free/N=(NumPntsAlpha)/D IntegralWv
//	SetScale/I x 0,(pi/2),"", IntegralWv
//	variable i, j
//	variable SLD
//	variable Radius
//	variable tempFFVale
//
//	For(i=0;i<numpnts(Intensity);i+=1)
//		IntegralWv = 0
//		For(j=0;j<numpnts(Profile);j+=1)
//			SLD 	= Profile[j]		//this is SLD in the Profile wave
//			Radius 	= j*step			//this is x value of Profile wave, assume x starts from 0
//			if(SLD>0)
//				multithread IntegralWv += SLD*(FormFactorCylinder(Qvalues[i],Radius+step,Length,x) - FormFactorCylinder(Qvalues[i],Radius,Length,x))	//calculate form factor F
//			endif
//		endfor
//
//		IntegralWv=IntegralWv*sin(x)			//multiply by sin alpha which is x from 0 to 90 deg
//		IntegralWv = IntegralWv^2				// F^2
//	 	Intensity[i] = area(IntegralWv)			//integration
//	 endfor
//	 Intensity = Intensity*1e-8		//1e-8 scales units from A to cm
//end
//

////*****************************************************************************************************************
////	fit function for core shell elliptical cylinder
////	note that some parameertrs are integers, so we need to define epsilon wave and also limitrs wave
////*****************************************************************************************************************
//
//
//Function Fit_CoreShellEllCylinder(pw, yw, xw) : FitFunc
//	WAVE pw, yw, xw
//
//	// Duplicate/FREE xw, yw
//	variable Length, radius, AspectRatio, ShellThick, SLD, scale, background
//	Length		=pw[0]
//	radius		=pw[1]
//	AspectRatio	=pw[2]
//	ShellThick	=pw[3]
//	SLD			=pw[4]
//	scale		=pw[5]
//	background	=pw[6]
//	make/free/N=90/D IntegralAlphaWv
//	make/free/N=180/D IntegralPsiWv
//	SetScale/I x 0,(pi/2),"rad", IntegralAlphaWv
//	SetScale/I x 0,(pi),"rad", IntegralPsiWv
//	variable i, j
//	variable Qval, tempFFIntegral, Psi
//	//variable approxVol= pi * Radius^2 * AspectRatio * Length
//	//variable approxVolL= pi * (Radius+ShellThick)^2 * AspectRatio * Length
//
//	For (i=0;i<numpnts(yw);i+=1)					//this is Int/Q point integration loop
//		Qval = xw[i]
//		For(j=0;j<numpnts(IntegralPsiWv);j+=1)			//thsi is psi integration loop
//			Psi = j*dimDelta(IntegralPsiWv,0)
//			multithread IntegralAlphaWv = sin(x) * (FormFactorElipCylinder(Qval, (radius+ShellThick), AspectRatio, Length, x, Psi) - FormFactorElipCylinder(Qval, radius, AspectRatio, Length, x, Psi))^2		//this is alpha integration
//			IntegralPsiWv[j] = area(IntegralAlphaWv)	//this is alpha integration
//		endfor
//		yw[i] = area(IntegralPsiWv)			//integration over Psi
//	endfor
//	yw *=scale
//	yw +=background
//End
//
//
