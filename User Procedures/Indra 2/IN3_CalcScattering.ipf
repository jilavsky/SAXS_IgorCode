#pragma rtFunctionErrors = 1
#pragma TextEncoding     = "UTF-8"
#pragma rtGlobals        = 3 // Use modern global access method.

#pragma version = 1.1

//*************************************************************************\
//* Copyright (c) 2005 - 2026, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution.
//*************************************************************************/

//calculate scattering profile from model

//1.1 10/2025 updated for APS-U USAXS, 21keV, 28keV,24keV_440. Other energies and 2DUSAXS are removed. 
//1.01 updated 18keV values.
//date: 7/9/09 JIL version 1
// 1/12/2010 JIL, fixed intensity calculations to remove points in user data at low and high Q which do not exist (caused troubles for model)
////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************
//notes, how to create binned version of QRS data:
// find location of max Intensity (was 54 on unbinned data). remove from copy of blank data
// delete points before peak:
//wavetsats Blank_R_Int
//DeletePoints 0,54, Blank_R_Qvec_dup
//•DeletePoints 0,54, Blank_R_error_dup
//•DeletePoints 0,54, Blank_R_Int_dup
//rebin area at Q>0
//•IN2G_RebinLogData(Blank_R_Qvec_dup,Blank_R_int_dup,250,0.00001,Wsdev = Blank_R_error_dup)
//duplicate data again, create copies of data to Qmin of instrument
//•DeletePoints 22,249, Blank_R_Qvec_dup
//•DeletePoints 22,249, Blank_R_error_dup
//•DeletePoints 22,249, Blank_R_Int_dup
//flip Q
//•Blank_R_Qvec_dup*=-1
//create new waves, and write data there - e.g.:
//Sort Blank_R_Qvec_dup,Blank_R_Int_dup,Blank_R_error_dup,Blank_R_Qvec_dup
//•Make/N=(22+250) Blank_R_binned, Blank_Q_binned, Blank_E_Binned
//•Blank_R_binned[0,21] = Blank_R_error_dup
//•Blank_R_binned[22,] = Blank_R_error_dup_dup[p-22]
//•Blank_R_binned[0,21] = Blank_R_Int_dup
//•Blank_R_binned[22,] = Blank_R_Int_dup_dup[p-22]
//•Blank_Q_binned[0,21] = Blank_R_Qvec_dup
//•Blank_Q_binned[22,] = Blank_R_Qvec_dup_dup[p-22]
//•Blank_E_binned[0,21] = Blank_R_error_dup
//•Blank_E_binned[22,] = Blank_R_error_dup_dup[p-22]
//print in history, copy to code and assign proper names... 
//


////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************


Function IN3M_CalculateDataFromModel()

	IN3M_InitCalcDataFromModel()

	DoWindow IN3MMainPanel
	if(V_Flag)
		DoWindow/F IN3MMainPanel
	else
		IN3M_MainPanel()
	endif

End

////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************

Function IN3M_MainPanel()

	KillWIndow/Z IN3MMainPanel
	NewPanel/K=1/W=(50, 43.25, 430.75, 570) as "Calculate Scattering From Model"
	DoWindow/C IN3MMainPanel
	SetDrawLayer UserBack
	SetDrawEnv fname="Times New Roman", fsize=18, fstyle=3, textrgb=(0, 0, 52224)
	DrawText 57, 22, "Calculate scattering from model"
	SetDrawEnv linethick=3, linefgc=(0, 0, 52224)
	DrawLine 16, 199, 339, 199
	SetDrawEnv fsize=16, fstyle=1
	DrawText 8, 49, "Data input"

	string UserDataTypes  = ""
	string UserNameString = ""
	string XUserLookup    = "r*:q*;"
	string EUserLookup    = "r*:s*;"
	IR2C_AddDataControls("IN3_CalcDataFromModel", "IN3MMainPanel", "M_DSM_Int;DSM_Int;M_SMR_Int;SMR_Int", "AllCurrentlyAllowedTypes", UserDataTypes, UserNameString, XUserLookup, EUserLookup, 0, 0)

	Button LoadData, pos={90, 165}, size={120, 20}, font="Times New Roman", proc=IN3M_ButtonProc, title="Load model data"

	SVAR SelectedEnergy = root:Packages:IN3_CalcDataFromModel:SelectedEnergy
	SVAR ListOfEnergies = root:Packages:IN3_CalcDataFromModel:ListOfEnergies
	PopupMenu SelectEnergy, pos={30, 220}, size={140, 20}, title="Select energy :", proc=In3M_PopMenuProc
	PopupMenu SelectEnergy, value=#"root:Packages:IN3_CalcDataFromModel:ListOfEnergies"
	PopupMenu SelectEnergy mode=(1+WhichListItem(SelectedEnergy, ListOfEnergies)) 

	Button UpdateMOdel, pos={240, 220}, size={120, 20}, font="Times New Roman", proc=IN3M_ButtonProc, title="Update"

	SetVariable Transmission, pos={30, 250}, size={180, 20}, title="Transmission = ", help={"Estimate sample transmission"}
	Setvariable Transmission, value=root:Packages:IN3_CalcDataFromModel:Transmission, proc=IN3M_SetVarProc, limits={0.0001, 1, 0.02}

	SetVariable SampleThickness, pos={30, 280}, size={220, 20}, title="Sample thickness [mm] = ", help={"Estimate sample thickness"}
	Setvariable SampleThickness, value=root:Packages:IN3_CalcDataFromModel:SampleThickness, proc=IN3M_SetVarProc, limits={0.001, 50, 0.05}

	CheckBox USAXS, pos={43, 319}, size={133, 14}, proc=IN3M_CheckProc, title="Slit smeared (USAXS)?"
	CheckBox USAXS, variable=root:Packages:IN3_CalcDataFromModel:CalculateUSAXS, mode=1
	//CheckBox SBUSAXS, pos={43, 345}, size={155, 14}, proc=IN3M_CheckProc, title="2d-collimated (SBUSAXS)?"
	//CheckBox SBUSAXS, variable=root:Packages:IN3_CalcDataFromModel:CalculateSBUSAXS, mode=1

	CheckBox SmearModelData, pos={43, 370}, size={133, 14}, proc=IN3M_CheckProc, title="Smear the model? (Uncheck is smeared already)"
	CheckBox SmearModelData, variable=root:Packages:IN3_CalcDataFromModel:SmearModelData
	SetVariable SlitLength, pos={30, 400}, size={220, 20}, title="Slit length [1/A] = ", help={"Slit length of the instrument?"}
	Setvariable SlitLength, value=root:Packages:IN3_CalcDataFromModel:SlitLength, proc=IN3M_SetVarProc, limits={0.001, 10, 0.002}
	
	//DrawText 26,500,"This tool has been revised ONLY for 21keV\rand Slit smeared USAXS!\rOther options are obsolete. "

End
////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************

Function IN3M_SetVarProc(STRUCT WMSetVariableAction &sva) : SetVariableControl

	switch(sva.eventCode)
		case 1: // mouse up, FIXME(CodeStyleFallthroughCaseRequireComment)
		case 2: // Enter key
			//case 3: // Live update
			variable dval = sva.dval
			string   sval = sva.sval

			IN3M_UpdateAll()

			break
		default:
			// FIXME(BugproneMissingSwitchDefaultCase)
			break
	endswitch

	return 0
End
////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************

Function IN3M_UpdateAll()

	SVAR SelectedEnergy = root:Packages:IN3_CalcDataFromModel:SelectedEnergy

	IN3M_SelectRightBlank(SelectedEnergy)

	IN3M_CalculateScattering()

	IN3M_CreateAndUpdatePlot()

End

////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************

Function IN3M_CheckProc(STRUCT WMCheckboxAction &cba) : CheckBoxControl

	NVAR IsModelSlitSmeared = root:Packages:IN3_CalcDataFromModel:IsModelSlitSmeared
	//		NVAR UseSlitSmearedModel= root:Packages:IN3_CalcDataFromModel:UseSlitSmearedModel
	NVAR UseSMRData       = root:Packages:IN3_CalcDataFromModel:UseSMRData
	NVAR SmearModelData   = root:Packages:IN3_CalcDataFromModel:SmearModelData
	NVAR CalculateUSAXS   = root:Packages:IN3_CalcDataFromModel:CalculateUSAXS
	NVAR CalculateSBUSAXS = root:Packages:IN3_CalcDataFromModel:CalculateSBUSAXS
	switch(cba.eventCode)
		case 2: // mouse up
			variable checked = cba.checked
			if(stringmatch(cba.ctrlName, "USAXS"))
				CalculateSBUSAXS = !CalculateUSAXS
				if((IsModelSlitSmeared || !UseSMRData) && !CalculateUSAXS)
					SmearModelData = 0
				else

				endif
				IN3M_UpdateAll()
			endif
			if(stringmatch(cba.ctrlName, "SBUSAXS"))
				CalculateUSAXS = !CalculateSBUSAXS
				SmearModelData = 0
				//		UseSlitSmearedModel = 0
				IN3M_UpdateAll()
			endif
			if(stringmatch(cba.ctrlName, "SmearModelData"))
				NVAR CalculateUSAXS   = root:Packages:IN3_CalcDataFromModel:CalculateUSAXS
				NVAR CalculateSBUSAXS = root:Packages:IN3_CalcDataFromModel:CalculateSBUSAXS
				NVAR SmearModelData   = root:Packages:IN3_CalcDataFromModel:SmearModelData
				IN3M_UpdateAll()
			endif

			break
		default:
			// FIXME(BugproneMissingSwitchDefaultCase)
			break
	endswitch

	return 0
End

////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************

Function IN3M_CalculateScattering()

	string oldDf = GetDataFolder(1)
	setDataFolder root:Packages:IN3_CalcDataFromModel

	//here we calculate the expected intensity for USAXS instrument...
	//first how the math works...
	//SMR_Int = (R_Int/T-Blank_Int)/Kfactor
	//where  K factor = BlankPeakMax * Omega * sampleThickness * 0.1 (convert to cm)
	//Omega = PDsize/SDD * BlankPeakWidthArcSec/3600 * pi/180
	//for SBUSAXS the difference is in Omega:
	//Omega = ASStageWidthArcSec/3600 * pi/180 *BlankPeakWidthArcSec/3600*pi/180
	//the rest is the same
	//do not forget the transmission...

	//so to convert back:
	// R_Int = T*((SMR_Int * Kfactor) + Blank)
	//Lets get the K factor...
	NVAR CalculateUSAXS
	variable KfactorLocal, OmegaLocal
	WAVE/Z BlankR
	Wavestats/Q BlankR
	variable BlankMaximum = V_max
	NVAR PeakWidth //note, it is in degrees...
	variable PDsize = 5
	variable SDD    = 1000		//APS-U standard
	NVAR Transmission
	NVAR SampleThickness
	if(CalculateUSAXS)
		OmegaLocal   = PDsize / SDD * PeakWidth * pi / 180
		KfactorLocal = BlankMaximum * OmegaLocal * sampleThickness * 0.1
	else
		OmegaLocal   = PeakWidth * pi / 180 * PeakWidth * pi / 180
		KfactorLocal = BlankMaximum * OmegaLocal * sampleThickness * 0.1
	endif
	WAVE/Z OriginalModelIntensity = root:Packages:IN3_CalcDataFromModel:OriginalModelIntensity
	if(!WaveExists(OriginalModelIntensity))
		abort
	endif
	WAVE OriginalModelQ = root:Packages:IN3_CalcDataFromModel:OriginalModelQ
	Duplicate/O OriginalModelIntensity, tempInt, tempInt1
	Duplicate/O OriginalModelQ, tempQ
	//need to remove negative intensities if present, seems to be in some user data...
	IN2G_ReplaceNegValsByNaNWaves(tempInt, tempQ, tempInt1)

	Duplicate/Free tempInt, tempModelInterpolated
	Duplicate/O BlankR, CalculatedScatteredIntensity
	Duplicate/Free BlankR, tempWv
	WAVE BlankQ = root:Packages:IN3_CalcDataFromModel:BlankQ
	Duplicate/O BlankQ, CalculatedScatteredQ
	//		Duplicate/O EWV, OriginalError
	//	tempModelInterpolated = log(tempInt)

	tempWv = interp(CalculatedScatteredQ, tempQ, tempModelInterpolated)

	//now need to remove data at higher and lower Q values than the original data...
	//original data were only in the areas of Q in tempQ
	variable Qmin        = tempQ[0]
	variable Qmax        = tempQ[numpnts(tempQ) - 1]
	variable pointsStart = binarysearch(CalculatedScatteredQ, Qmin)
	variable pointsEnd   = binarysearch(CalculatedScatteredQ, Qmax) + 1
	tempWv[0, pointsStart] = 0
	if(pointsEnd>0)
		tempWv[pointsEnd, numpnts(tempWv)-1] = NaN
	endif
	//	tempWv = 10^tempWv
	variable FlatInstrBckg = sum(BlankR, numpnts(BlankR) - 7, numpnts(BlankR) - 1) / 6

	NVAR SlitLength
	NVAR SmearModelData
	if(SmearModelData)
		Duplicate/O tempWv, tempWv1
		//IN3M_SmearData(tempWv1, CalculatedScatteredQ, slitLength, tempWv)
		IR1B_SmearData(tempWv1, CalculatedScatteredQ, slitLength, tempWv) //this is faster, but part of Irena
	endif
	CalculatedScatteredIntensity = (tempWv * KfactorLocal) / Transmission + BlankR + FlatInstrBckg / Transmission

	//	KillWaves tempModelInterpolated, tempWv, tempWv1, tempInt,tempQ, tempInt1
	setDataFolder OldDf
End

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*****************************This function smears data***********************
Function IN3M_SmearData(WAVE Int_to_smear, WAVE Q_vec_sm, variable slitLength, WAVE Smeared_int)

	string OldDf = GetDataFolder(1)
	setDataFolder root:Packages:
	NewDataFolder/O/S Irena_desmearing
	//	setDataFolder root:Packages:Irena_desmearing:

	Make/D/O/N=(2 * numpnts(Q_vec_sm)) Smear_Q, Smear_Int
	//Q's in L spacing and intensitites in the l's will go to Smear_Int (intensity distribution in the slit, changes for each point)

	variable DataLengths = numpnts(Q_vec_sm)

	Smear_Q = 1.1 * slitLength * (Q_vec_sm[2 * p] - Q_vec_sm[0]) / (Q_vec_sm[DataLengths - 1] - Q_vec_sm[0]) //create distribution of points in the l's which mimics the original distribution of points
	//the 1.1* added later, because without it I did not  cover the whole slit length range...
	variable i = 0
	DataLengths = numpnts(Smeared_int)

	for(i = 0; i < DataLengths; i += 1)
		Smear_Int      = interp(sqrt((Q_vec_sm[i])^2 + (Smear_Q[p])^2), Q_vec_sm, Int_to_smear) //put the distribution of intensities in the slit for each point
		Smeared_int[i] = areaXY(Smear_Q, Smear_Int, 0, slitLength)                              //integrate the intensity over the slit
	endfor

	Smeared_int *= 1 / slitLength //normalize

	KillWaves/Z Smear_Int, Smear_Q //cleanup temp waves
	setDataFolder OldDf
End
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*****************************This function smears data***********************
////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************

Function IN3M_PopMenuProc(STRUCT WMPopupAction &pa) : PopupMenuControl

	switch(pa.eventCode)
		case 2: // mouse up
			variable popNum = pa.popNum
			string   popStr = pa.popStr

			string oldDf = GetDataFolder(1)
			setDataFolder root:Packages:IN3_CalcDataFromModel			
			SVAR SelectedEnergy
			SelectedEnergy = popStr

			IN3M_SetSLitLength(popStr)
			
			//here goes my code...
			IN3M_SelectRightBlank(popStr)
			IN3M_CalculateScattering()
			setDataFolder OldDf
			break
		default:
			// FIXME(BugproneMissingSwitchDefaultCase)
			break
	endswitch

	return 0
End
////*************************************************************************
Function IN3M_SetSLitLength(EnergyStr)
	string EnergyStr
	
	NVAR SlitLength = root:Packages:IN3_CalcDataFromModel:SlitLength
	if(stringmatch(EnergyStr,"21keV"))
		SlitLength = 0.0266
	elseif(stringmatch(EnergyStr,"28keV"))
		SlitLength = 0.0355
	elseif(stringmatch(EnergyStr,"24keV_440"))
		SlitLength = 0.0305
	endif				
	

end

////*************************************************************************
////*************************************************************************
////*************************************************************************

Function IN3M_SelectRightBlank(string EnergyString)

	string oldDf = GetDataFolder(1)
	setDataFolder root:Packages:IN3_CalcDataFromModel

	SVAR ListOfPeakWidths
	//	SVAR ListOfKfactors
	NVAR PeakWidth
	NVAR MaximumBlankIntensity
	NVAR MaximumIntensity
	NVAR Transmission
	NVAR Kfactor

	PeakWidth = NumberByKey(EnergyString, ListOfPeakWidths, "=")
	//	Kfactor = NumberByKey(EnergyString, ListOfKfactors,"=")

	SVAR SelectedEnergy
	SelectedEnergy = EnergyString
	NVAR   CalculateUSAXS
	string tmpstr
	if(CalculateUSAXS)
		tmpstr = "SMR"
	else
		tmpstr = "DSM"
	endif

	//	Make/O/N=200 RQ_SMR_18keV, RInt_SMR_18keV, RE_SMR_18keV
	WAVE/Z BL_Int = $("RInt_" + tmpstr + "_" + EnergyString)
	WAVE/Z BL_Q   = $("RQ_" + tmpstr + "_" + EnergyString)
	WAVE/Z BL_Err = $("RE_" + tmpstr + "_" + EnergyString)

	if(WaveExists(BL_Int))
		Duplicate/O BL_Int, BlankR
		Duplicate/O BL_Q, BlankQ
		Duplicate/O BL_Err, BlankE
	else
		Abort "This combination of energy and geometry does not yet exist"
	endif

	IN3M_CreateAndUpdatePlot()

	setDataFolder OldDf

End
////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************

Function IN3M_ButtonProc(STRUCT WMButtonAction &ba) : ButtonControl

	switch(ba.eventCode)
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"LoadData"))
				IN3M_LoadDataInTheTool()
			elseif(stringmatch(ba.ctrlName,"UpdateMOdel"))
				SVAR SelectedEnergy = root:Packages:IN3_CalcDataFromModel:SelectedEnergy
				IN3M_SelectRightBlank(SelectedEnergy)
				IN3M_CalculateScattering()			
			endif
			break
		default:
			// FIXME(BugproneMissingSwitchDefaultCase)
			break
	endswitch




	return 0
End
////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************

Function IN3M_LoadDataInTheTool()

	string oldDf = GetDataFolder(1)
	setDataFolder root:Packages:IN3_CalcDataFromModel

	SVAR DataFolderName    = root:Packages:IN3_CalcDataFromModel:DataFolderName
	SVAR ErrorWaveName     = root:Packages:IN3_CalcDataFromModel:ErrorWaveName
	SVAR IntensityWaveName = root:Packages:IN3_CalcDataFromModel:IntensityWaveName
	SVAR QWavename         = root:Packages:IN3_CalcDataFromModel:QWavename

	WAVE/Z IntWv = $(DataFolderName + IntensityWaveName)
	WAVE/Z QWV   = $(DataFolderName + QWavename)
	WAVE/Z EWV   = $(DataFolderName + ErrorWaveName)

	if(!WaveExists(IntWv) || !WaveExists(QWv))
		Abort "Data not selected properly"
	endif
	Duplicate/O IntWv, OriginalModelIntensity
	WAVE OriginalModelIntensity
	Duplicate/O QWv, OriginalModelQ
	if(WaveExists(EWV))
		Duplicate/O EWV, OriginalError
	endif
	//now check for use of slit smeared data by the model...
	//UseSlitSmearedData should be 1 if the model is slit smeared already.

	NVAR IsModelSlitSmeared = root:Packages:IN3_CalcDataFromModel:IsModelSlitSmeared
	IsModelSlitSmeared = NumberByKey("UseSlitSmearedData", note(OriginalModelIntensity), "=", ";")
	NVAR CalculateSBUSAXS = root:Packages:IN3_CalcDataFromModel:CalculateSBUSAXS
	NVAR CalculateUSAXS   = root:Packages:IN3_CalcDataFromModel:CalculateUSAXS
	NVAR SmearModelData   = root:Packages:IN3_CalcDataFromModel:SmearModelData
	if(IsModelSlitSmeared || CalculateSBUSAXS)
		SmearModelData = 0
	elseif(IsModelSlitSmeared == 0 && CalculateUSAXS)
		SmearModelData = 1
	endif

	IN3M_CreateAndUpdatePlot()

	setDataFolder OldDf
End
////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************

Function IN3M_CreateAndUpdatePlot()

	DoWIndow IN3MMainPlot
	if(V_Flag)
		DoWIndow/F IN3MMainPlot
	else
		Display/K=1/W=(390, 46, 994, 571)
		DoWindow/C IN3MMainPlot
	endif
	WAVE/Z OriginalModelIntensity = root:Packages:IN3_CalcDataFromModel:OriginalModelIntensity
	WAVE/Z OriginalModelQ         = root:Packages:IN3_CalcDataFromModel:OriginalModelQ
	WAVE/Z OriginalError          = root:Packages:IN3_CalcDataFromModel:OriginalError

	if(!WaveExists(OriginalModelIntensity))
		return 1
	endif

	CheckDisplayed/A/W=IN3MMainPlot OriginalModelIntensity
	if(!V_Flag)
		AppendToGraph/R OriginalModelIntensity vs OriginalModelQ
		//and format
		ModifyGraph log=1
		ModifyGraph tick=2
		ModifyGraph/Z mirror=1
		ModifyGraph lstyle(OriginalModelIntensity)=5
		ModifyGraph rgb(OriginalModelIntensity)=(0, 0, 65535)
		Label right, "Model Intensity [cm\\S-1\\M]"
		Label bottom, "Q [A\\S-1\\M]"
		wavestats/Q OriginalModelIntensity
		variable MinVal = V_min
		variable MaxVal = V_max
		if((Maxval / Minval) < 1e7)
			Maxval = 1e7 * MinVal
		endif
		SetAxis right, MinVal, Maxval
		SetAxis bottom, 1e-5, 0.3		//APS-U standard
	endif

	//append Blank if it exists
	WAVE/Z BlankR
	WAVE/Z BlankQ
	WAVE/Z BlankE
	if(WaveExists(BlankR))
		CheckDisplayed/W=IN3MMainPlot BlankR
		if(!V_Flag)
			AppendToGraph/W=IN3MMainPlot BlankR vs BlankQ
			ModifyGraph/W=IN3MMainPlot mode(BlankR)=0, rgb(BlankR)=(0, 0, 0)
			modifygraph/W=IN3MMainPlot log(left)=1
			ErrorBars BlankR, Y, wave=(BlankE, BlankE)
		endif
	endif

	WAVE/Z CalculatedScatteredIntensity
	WAVE/Z CalculatedScatteredQ
	if(WaveExists(CalculatedScatteredQ) && WaveExists(CalculatedScatteredIntensity))
		//apend to graph
		CheckDisplayed/W=IN3MMainPlot CalculatedScatteredIntensity
		if(!V_Flag)
			AppendToGraph/W=IN3MMainPlot CalculatedScatteredIntensity vs CalculatedScatteredQ
			ModifyGraph/W=IN3MMainPlot mode(CalculatedScatteredIntensity)=0
			ModifyGraph/W=IN3MMainPlot rgb(CalculatedScatteredIntensity)=(65535, 0, 0)
		endif
	endif

	Legend/C/N=text0/A=RT

	//align the windows
	AutoPositionWindow/M=0/R=IN3MMainPanel IN3MMainPlot
	//showtools
	DoWindow/F IN3MMainPanel
End

////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************

Function IN3M_InitCalcDataFromModel()

	string oldDf = GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:IN3_CalcDataFromModel

	string   ListOfVariables
	string   ListOfStrings
	variable i

	ListOfVariables  = "CalculateUSAXS;CalculateSBUSAXS;"
	ListOfVariables += "Transmission;PeakWidth;MaximumBlankIntensity;MaximumIntensity;SampleThickness;"
	ListOfVariables += "Kfactor;SmearModelData;SlitLength;IsModelSlitSmeared;"

	ListOfStrings = "ListOfEnergies;SelectedEnergy;ListOfPeakWidths;"

	//and here we create them
	for(i = 0; i < itemsInList(ListOfVariables); i += 1)
		IN2G_CreateItem("variable", StringFromList(i, ListOfVariables))
	endfor

	for(i = 0; i < itemsInList(ListOfStrings); i += 1)
		IN2G_CreateItem("string", StringFromList(i, ListOfStrings))
	endfor

	NVAR CalculateUSAXS
	NVAR CalculateSBUSAXS
	CalculateSBUSAXS = 0
	if((CalculateUSAXS + CalculateSBUSAXS) != 1)
		CalculateUSAXS   = 1
		CalculateSBUSAXS = 0
	endif
	SVAR SelectedEnergy
	if(strlen(SelectedEnergy)<2)
		SelectedEnergy = "21keV"
	endif
	
	NVAR SmearModelData
	SmearModelData=1		//default to smear data 

	
	IN3M_SetSLitLength(SelectedEnergy)
//	NVAR SlitLength
//	if(SlitLength <= 0)
//		SlitLength = 0.0266		//21keV APS-U standard, 28keV = 0.0355, 
//	endif

	SVAR ListOfEnergies
	ListOfEnergies = "21keV;28keV;24keV_440;"

	SVAR ListOfPeakWidths
	ListOfPeakWidths = "28keV=0.0003702;24keV_440=0.0001015;21keV=0.0004675;18keV=0.000603181;12keV=0.000875727;"	//in degrees, = arcsec/3600

	NVAR Transmission
	if(Transmission <= 0 || Transmission > 1)
		Transmission = 1
	endif

	NVAR SampleThickness
	if(SampleThickness <= 0)
		SampleThickness = 1
	endif

	//Create some instrument Curves
	Wave/Z RQ_SMR_21keV
	if(!waveExists(RQ_SMR_21keV))
		
		Make/O/N=272 RQ_SMR_21keV, RInt_SMR_21keV, RE_SMR_21keV
		
		  RQ_SMR_21keV[0] = {-0.000293431,-0.000285633,-0.000257281,-0.000239423,-0.00022424,-0.000209172,-0.000194221,-0.000179388,-0.000164678,-0.000150092,-0.000135635,-0.000123686,-0.000114197}
		  RQ_SMR_21keV[13] = {-0.000107119,-8.61093e-05,-7.45869e-05,-6.31683e-05,-5.18748e-05,-4.06983e-05,-2.96668e-05,-1.87762e-05,-4.72899e-06,4.72899e-06,1.87762e-05,2.96668e-05,4.06983e-05}
		  RQ_SMR_21keV[26] = {5.18748e-05,6.31683e-05,7.45869e-05,8.61093e-05,0.000107119,0.000114197,0.000123686,0.000135635,0.000150092,0.000164678,0.000179388,0.000194221,0.000209172,0.00022424}
		  RQ_SMR_21keV[40] = {0.000239423,0.000257281,0.000285633,0.000293431,0.000309111,0.000327525,0.000346087,0.000367466,0.000386316,0.000405307,0.000427169,0.000449204,0.000471407,0.000493778}
		  RQ_SMR_21keV[54] = {0.000516315,0.000539015,0.000564751,0.000590682,0.000616822,0.000643154,0.00066969,0.000699401,0.000729351,0.000759538,0.000789961,0.000820617,0.000851505,0.000882623}
		  RQ_SMR_21keV[68] = {0.000917121,0.000951886,0.000986931,0.00102547,0.00106432,0.0011035,0.00114298,0.00118279,0.0012229,0.00126672,0.0013143,0.00135885,0.00140378,0.00145255,0.00150173}
		  RQ_SMR_21keV[83] = {0.00155132,0.00160491,0.00165896,0.00171348,0.00177214,0.0018276,0.00188728,0.00195123,0.00201197,0.00207707,0.0021493,0.00222856,0.00227975,0.00235116,0.00242321}
		  RQ_SMR_21keV[98] = {0.00249996,0.00258151,0.0026597,0.0027386,0.00282662,0.00291549,0.00300092,0.00309146,0.00318721,0.00328389,0.0033815,0.00348453,0.00358856,0.00369361,0.00380429}
		  RQ_SMR_21keV[113] = {0.00392075,0.00403837,0.00415719,0.004282,0.00440808,0.00453543,0.00466902,0.00480397,0.00494029,0.00508823,0.00523771,0.00538878,0.0055467,0.00570629,0.00587297}
		  RQ_SMR_21keV[128] = {0.00604141,0.00621165,0.00638924,0.00657438,0.00676722,0.00696221,0.00715933,0.0073645,0.00757191,0.00778763,0.00801182,0.00823855,0.00847404,0.00871219,0.0089594}
		  RQ_SMR_21keV[143] = {0.00921585,0.00947527,0.00973764,0.0100097,0.0102915,0.0105835,0.0108858,0.0111917,0.0115012,0.0118214,0.0121526,0.0124952,0.0128492,0.0132075,0.0135701,0.0139448}
		  RQ_SMR_21keV[159] = {0.0143394,0.014739,0.0151434,0.0155688,0.0160077,0.0164521,0.0169103,0.0173828,0.0178611,0.0183541,0.0188621,0.0193854,0.0199243,0.0204701,0.021032,0.0216199,0.0222248}
		  RQ_SMR_21keV[176] = {0.0228376,0.023468,0.0241164,0.0247733,0.0254487,0.0260305,0.0271697,0.0276222,0.0283871,0.0291622,0.0299585,0.0307874,0.0316387,0.0325015,0.0333872,0.0343082,0.0352534}
		  RQ_SMR_21keV[193] = {0.0362236,0.037219,0.0382403,0.039288,0.0403627,0.0414778,0.0426213,0.0437806,0.0449826,0.0462147,0.0474777,0.0487861,0.0501128,0.0514866,0.052894,0.054336,0.055828}
		  RQ_SMR_21keV[210] = {0.0573563,0.0589214,0.0605242,0.0621812,0.0638938,0.0656472,0.0674421,0.0692793,0.0711597,0.0731013,0.0751056,0.0771565,0.0792548,0.0814198,0.0836531,0.0859375,0.088274}
		  RQ_SMR_21keV[227] = {0.090683,0.0931662,0.0957055,0.0983222,0.101018,0.103753,0.106571,0.109494,0.112481,0.115535,0.118678,0.121912,0.12524,0.128665,0.132188,0.135787,0.139488,0.143294}
		  RQ_SMR_21keV[245] = {0.147182,0.151178,0.155312,0.15956,0.163899,0.168357,0.172936,0.17764,0.182472,0.187462,0.192586,0.197817,0.203187,0.20873,0.214418,0.220256,0.226246,0.232391,0.238729}
		  RQ_SMR_21keV[264] = {0.24523,0.251897,0.258735,0.265782,0.273044,0.280488,0.28812,0.29583}

		  RInt_SMR_21keV[0] = {1.71453e-06,1.83784e-06,2.36946e-06,2.89239e-06,3.47577e-06,4.27315e-06,5.29802e-06,6.70507e-06,8.75007e-06,1.18459e-05,1.67439e-05,2.32786e-05,3.23869e-05,4.35035e-05}
		  RInt_SMR_21keV[14] = {0.000427667,0.00190428,0.0046429,0.00763133,0.0106608,0.0136047,0.0165626,0.0192541,0.0192541,0.0165626,0.0136047,0.0106608,0.00763133,0.0046429,0.00190428,0.000427667}
		  RInt_SMR_21keV[30] = {4.35035e-05,3.23869e-05,2.32786e-05,1.67439e-05,1.18459e-05,8.75007e-06,6.70507e-06,5.29802e-06,4.27315e-06,3.47577e-06,2.89239e-06,2.36946e-06,1.83784e-06,1.71453e-06}
		  RInt_SMR_21keV[44] = {1.49524e-06,1.28651e-06,1.11715e-06,9.75259e-07,8.71049e-07,7.7854e-07,6.92806e-07,6.22657e-07,5.61458e-07,5.07579e-07,4.63051e-07,4.22125e-07,3.84751e-07,3.49503e-07}
		  RInt_SMR_21keV[58] = {3.20404e-07,2.93136e-07,2.7058e-07,2.46995e-07,2.24541e-07,2.06477e-07,1.89963e-07,1.73355e-07,1.59692e-07,1.47193e-07,1.35595e-07,1.25011e-07,1.16156e-07,1.0709e-07}
		  RInt_SMR_21keV[72] = {9.85455e-08,9.13493e-08,8.41214e-08,7.79651e-08,7.25819e-08,6.71169e-08,6.19699e-08,5.70421e-08,5.28847e-08,4.94015e-08,4.62314e-08,4.29846e-08,3.99805e-08,3.7399e-08}
		  RInt_SMR_21keV[86] = {3.48648e-08,3.23877e-08,3.03287e-08,2.80317e-08,2.61824e-08,2.46658e-08,2.30157e-08,2.12785e-08,1.96904e-08,1.88156e-08,1.76525e-08,1.65317e-08,1.54527e-08,1.44532e-08}
		  RInt_SMR_21keV[100] = {1.35832e-08,1.27735e-08,1.19755e-08,1.12407e-08,1.05651e-08,9.98386e-09,9.41437e-09,8.84948e-09,8.33815e-09,7.82135e-09,7.39807e-09,6.95924e-09,6.62485e-09,6.19975e-09}
		  RInt_SMR_21keV[114] = {5.87105e-09,5.54207e-09,5.24331e-09,5.00233e-09,4.73114e-09,4.46223e-09,4.1501e-09,4.03213e-09,3.75602e-09,3.55062e-09,3.35591e-09,3.16872e-09,3.00943e-09,2.83902e-09}
		  RInt_SMR_21keV[128] = {2.69218e-09,2.50609e-09,2.41791e-09,2.28511e-09,2.14412e-09,2.03395e-09,1.92155e-09,1.839e-09,1.72072e-09,1.65454e-09,1.52695e-09,1.47034e-09,1.40597e-09,1.33338e-09}
		  RInt_SMR_21keV[142] = {1.23676e-09,1.17883e-09,1.11696e-09,1.09541e-09,1.02741e-09,9.79998e-10,9.36151e-10,9.03558e-10,8.4872e-10,7.86117e-10,7.6202e-10,7.35643e-10,6.84092e-10,6.43671e-10}
		  RInt_SMR_21keV[156] = {6.12554e-10,5.77516e-10,5.53303e-10,5.18237e-10,4.96201e-10,4.6212e-10,4.38318e-10,4.12963e-10,3.83468e-10,3.54351e-10,3.47441e-10,3.11648e-10,3.07255e-10,2.87132e-10}
		  RInt_SMR_21keV[170] = {2.64586e-10,2.39306e-10,2.28703e-10,2.15413e-10,2.11306e-10,1.89538e-10,1.71601e-10,1.66524e-10,1.6072e-10,1.44772e-10,1.40036e-10,1.32609e-10,1.17046e-10,1.15562e-10}
		  RInt_SMR_21keV[184] = {1.11948e-10,1.03452e-10,1.01427e-10,9.44059e-11,8.76468e-11,8.71194e-11,8.31261e-11,7.89268e-11,7.77943e-11,7.34281e-11,7.14808e-11,6.47145e-11,6.28301e-11,6.12447e-11}
		  RInt_SMR_21keV[198] = {6.02779e-11,5.88754e-11,5.75901e-11,5.28191e-11,5.08423e-11,5.01208e-11,5.05028e-11,5.03236e-11,4.77144e-11,4.83587e-11,4.64129e-11,4.53592e-11,4.49184e-11,4.34755e-11}
		  RInt_SMR_21keV[212] = {4.52949e-11,4.21444e-11,4.25971e-11,4.31645e-11,3.88883e-11,3.93192e-11,3.75786e-11,3.81052e-11,4.01188e-11,3.56308e-11,3.4561e-11,3.48269e-11,3.55137e-11,3.30775e-11}
		  RInt_SMR_21keV[226] = {3.4255e-11,3.20691e-11,3.19331e-11,3.26572e-11,3.17232e-11,3.09599e-11,3.34882e-11,3.03482e-11,3.08978e-11,2.89986e-11,2.8503e-11,2.85459e-11,2.94896e-11,3.07045e-11}
		  RInt_SMR_21keV[240] = {2.95184e-11,2.86925e-11,3.00999e-11,2.88279e-11,3.06364e-11,2.88596e-11,2.73465e-11,2.65796e-11,2.57195e-11,2.43812e-11,2.53434e-11,2.3879e-11,2.36128e-11,2.26431e-11}
		  RInt_SMR_21keV[254] = {2.05182e-11,2.11175e-11,2.18103e-11,1.96999e-11,2.26476e-11,2.16125e-11,2.16726e-11,2.10196e-11,1.90508e-11,1.88895e-11,2.06618e-11,1.82041e-11,1.71043e-11,1.8547e-11}
		  RInt_SMR_21keV[268] = {1.86831e-11,1.92179e-11,1.87605e-11,1.82822e-11}			

		  RE_SMR_21keV[0] = {5.43504e-09,5.78158e-09,3.02857e-08,3.30449e-08,3.59361e-08,3.9524e-08,4.38511e-08,4.90123e-08,5.63785e-08,6.56025e-08,8.05579e-08,9.83117e-08,1.24155e-07,1.49622e-07}
		  RE_SMR_21keV[14] = {3.26154e-06,7.75861e-06,1.4778e-05,2.15891e-05,2.86495e-05,3.43217e-05,3.9948e-05,4.38013e-05,4.38013e-05,3.9948e-05,3.43217e-05,2.86495e-05,2.15891e-05,1.4778e-05}
		  RE_SMR_21keV[28] = {7.75861e-06,3.26154e-06,1.49622e-07,1.24155e-07,9.83117e-08,8.05579e-08,6.56025e-08,5.63785e-08,4.90123e-08,4.38511e-08,3.9524e-08,3.59361e-08,3.30449e-08,3.02857e-08}
		  RE_SMR_21keV[42] = {5.78158e-09,5.43504e-09,4.87543e-09,4.33135e-09,3.86607e-09,3.50978e-09,3.21454e-09,2.95296e-09,2.7133e-09,2.53608e-09,2.34205e-09,2.19342e-09,2.06773e-09,1.94996e-09}
		  RE_SMR_21keV[56] = {1.82905e-09,1.73347e-09,1.64242e-09,1.56232e-09,1.48329e-09,1.41058e-09,1.33858e-09,1.27189e-09,1.2155e-09,1.16008e-09,1.11403e-09,1.07225e-09,1.02289e-09,9.8322e-10}
		  RE_SMR_21keV[70] = {9.48404e-10,9.07163e-10,8.7812e-10,8.42531e-10,8.11125e-10,7.77972e-10,7.56316e-10,7.25389e-10,7.01125e-10,6.70227e-10,6.50443e-10,6.37102e-10,6.1494e-10,5.92422e-10}
		  RE_SMR_21keV[84] = {5.74928e-10,5.56559e-10,5.38221e-10,5.21978e-10,5.07015e-10,4.84518e-10,4.77684e-10,4.63354e-10,4.47889e-10,3.02247e-10,5.43011e-11,7.86362e-11,7.44619e-11,7.06701e-11}
		  RE_SMR_21keV[98] = {6.74295e-11,6.40315e-11,6.07265e-11,5.79948e-11,5.50706e-11,5.2639e-11,5.02363e-11,4.83147e-11,4.62391e-11,4.40786e-11,4.23684e-11,4.02928e-11,3.91763e-11,3.74788e-11}
		  RE_SMR_21keV[112] = {3.61056e-11,3.45156e-11,3.33256e-11,3.22124e-11,3.10778e-11,3.00471e-11,2.89838e-11,2.80924e-11,2.67848e-11,2.62657e-11,2.52077e-11,2.43809e-11,2.35114e-11,2.27627e-11}
		  RE_SMR_21keV[126] = {2.21235e-11,2.13616e-11,2.07382e-11,1.99503e-11,1.95698e-11,1.89004e-11,1.83084e-11,1.77994e-11,1.72339e-11,1.68855e-11,1.63179e-11,1.59798e-11,1.53592e-11,1.50082e-11}
		  RE_SMR_21keV[140] = {1.4723e-11,1.43065e-11,1.38444e-11,1.34635e-11,1.3132e-11,1.30655e-11,1.26615e-11,1.23734e-11,1.21052e-11,1.1946e-11,1.16084e-11,1.117e-11,1.1045e-11,1.08842e-11}
		  RE_SMR_21keV[154] = {1.0519e-11,1.02413e-11,9.9945e-12,9.78927e-12,9.63823e-12,9.35382e-12,9.2088e-12,8.89604e-12,8.73381e-12,8.52358e-12,8.28197e-12,8.02887e-12,7.98432e-12,7.61465e-12}
		  RE_SMR_21keV[168] = {7.62917e-12,7.42285e-12,7.20131e-12,6.95313e-12,6.84647e-12,6.72604e-12,6.67958e-12,6.46596e-12,6.20775e-12,6.19761e-12,6.14729e-12,5.91457e-12,5.88071e-12,4.68038e-12}
		  RE_SMR_21keV[182] = {6.40389e-13,1.48076e-12,1.47043e-12,1.44863e-12,1.44358e-12,1.42081e-12,1.40493e-12,1.40176e-12,1.39254e-12,1.38422e-12,1.38135e-12,1.37012e-12,1.36346e-12,1.3462e-12}
		  RE_SMR_21keV[196] = {1.33752e-12,1.33558e-12,1.33419e-12,1.32809e-12,1.32688e-12,1.31056e-12,1.30782e-12,1.30689e-12,1.30947e-12,1.31019e-12,1.30097e-12,1.30821e-12,1.30161e-12,1.29841e-12}
		  RE_SMR_21keV[210] = {1.29996e-12,1.29394e-12,1.29922e-12,1.28975e-12,1.29014e-12,1.29658e-12,1.28539e-12,1.28672e-12,1.27927e-12,1.28301e-12,1.28672e-12,1.27856e-12,1.27458e-12,1.27621e-12}
		  RE_SMR_21keV[224] = {1.27761e-12,1.27058e-12,1.27628e-12,1.26927e-12,1.27058e-12,1.27285e-12,1.26956e-12,1.2672e-12,1.27706e-12,1.26119e-12,1.26296e-12,1.25758e-12,1.25964e-12,1.25776e-12}
		  RE_SMR_21keV[238] = {1.26169e-12,1.26591e-12,1.25994e-12,1.26341e-12,1.26868e-12,1.26368e-12,1.26895e-12,1.26703e-12,1.25964e-12,1.25691e-12,1.25635e-12,1.25143e-12,1.25633e-12,1.25241e-12}
		  RE_SMR_21keV[252] = {1.2519e-12,1.24738e-12,1.24389e-12,1.245e-12,1.24598e-12,1.24065e-12,1.24988e-12,1.24796e-12,1.24786e-12,1.2449e-12,1.24157e-12,1.24025e-12,1.24742e-12,1.23942e-12}
		  RE_SMR_21keV[266] = {1.23641e-12,1.23983e-12,1.24136e-12,1.24235e-12,1.24006e-12,1.24368e-12}
	
	endif


	Wave/Z RQ_SMR_28keV
	if(!waveExists(RQ_SMR_28keV))
		
		Make/O/N=272 RQ_SMR_28keV, RInt_SMR_28keV, RE_SMR_28keV
		
		  RQ_SMR_28keV[0] = {-0.00029541,-0.000279217,-0.000259897,-0.000243893,-0.000227985,-0.000212164,-0.000199578,-0.000183936,-0.000168387,-0.000156024,-0.000143729,-0.000131502,-0.000122376}
		  RQ_SMR_28keV[13] = {-0.000116316,-8.92838e-05,-7.73978e-05,-6.5597e-05,-5.38865e-05,-4.2273e-05,-3.36281e-05,-2.50544e-05,-8.85812e-06,8.85812e-06,2.50544e-05,3.36281e-05,4.2273e-05,5.38865e-05}
		  RQ_SMR_28keV[27] = {6.5597e-05,7.73978e-05,8.92838e-05,0.000116316,0.000122376,0.000131502,0.000143729,0.000156024,0.000168387,0.000183936,0.000199578,0.000212164,0.000227985,0.000243893}
		  RQ_SMR_28keV[41] = {0.000259897,0.000279217,0.00029541,0.000324837,0.000351109,0.000357724,0.000370999,0.000391001,0.000411116,0.000431344,0.000451682,0.000475551,0.00049956,0.000520257}
		  RQ_SMR_28keV[55] = {0.00054454,0.000568957,0.000593521,0.000621759,0.000646609,0.000671602,0.000700324,0.000729219,0.000758286,0.000791191,0.000824301,0.000853912,0.000887425,0.000921136}
		  RQ_SMR_28keV[69] = {0.000955059,0.000992985,0.00103116,0.00106958,0.00110824,0.00114715,0.0011863,0.00122964,0.00127325,0.00131717,0.00136135,0.00140582,0.00145465,0.00150381,0.00155744}
		  RQ_SMR_28keV[84] = {0.00161144,0.00166163,0.00171636,0.00177572,0.00183122,0.0018871,0.00195204,0.00201745,0.00207894,0.00214529,0.00221659,0.00228392,0.00235173,0.00242916,0.00250717,0.00261102}
		  RQ_SMR_28keV[100] = {0.00283946,0.00284897,0.00286325,0.0029158,0.0030071,0.00309911,0.00319187,0.00329028,0.00338949,0.0034895,0.00359029,0.00369699,0.00380969,0.00392334,0.00403793,0.00415874}
		  RQ_SMR_28keV[116] = {0.0042859,0.0044088,0.00453815,0.00467404,0.00481115,0.00494943,0.00508893,0.00524092,0.00539427,0.00554902,0.00571095,0.00587435,0.00604515,0.0062175,0.00639145,0.00657913}
		  RQ_SMR_28keV[132] = {0.00676859,0.00695985,0.00715913,0.00736665,0.00757616,0.00778769,0.00801425,0.00824304,0.0084741,0.00871409,0.00896325,0.00921488,0.00946905,0.00973966,0.0100201,0.0103034}
		  RQ_SMR_28keV[148] = {0.0105897,0.0108861,0.011193,0.011503,0.0118238,0.0121555,0.0124984,0.0128526,0.0132108,0.0135806,0.0139625,0.0143486,0.014747,0.015158,0.0155736,0.0160021,0.0164525}
		  RQ_SMR_28keV[165] = {0.0169165,0.0173859,0.0178606,0.0183495,0.018862,0.0193895,0.0199231,0.0204723,0.0210372,0.0216183,0.0222158,0.0228302,0.0234618,0.0241109,0.0247778,0.0254631,0.026167}
		  RQ_SMR_28keV[182] = {0.0268899,0.0276323,0.0283836,0.0291659,0.0299688,0.0307928,0.0316382,0.0325055,0.0334068,0.0343194,0.0352553,0.036227,0.0372231,0.0382442,0.0392908,0.0403633,0.0414751}
		  RQ_SMR_28keV[199] = {0.0426143,0.0437813,0.0449766,0.0462144,0.047482,0.04878,0.050123,0.051498,0.0529054,0.054346,0.0558352,0.0573591,0.0589184,0.0605292,0.0621927,0.0638945,0.0656351,0.0674317}
		  RQ_SMR_28keV[217] = {0.0692856,0.0711813,0.0731198,0.0751188,0.0771626,0.0792695,0.081441,0.0836606,0.0859474,0.0882845,0.0906916,0.0931703,0.095703,0.0983102,0.100994,0.103755,0.106597,0.109499}
		  RQ_SMR_28keV[235] = {0.112484,0.115554,0.11869,0.121936,0.125272,0.128679,0.13218,0.135778,0.139474,0.143272,0.147172,0.151178,0.155317,0.159566,0.163903,0.168355,0.17295,0.177667,0.182506}
		  RQ_SMR_28keV[254] = {0.187472,0.192566,0.19782,0.203209,0.208736,0.214404,0.220245,0.226264,0.232404,0.238729,0.245243,0.25192,0.258761,0.265804,0.273054,0.280481,0.288124,0.295845}
		
		  RInt_SMR_28keV[0] = {3.66594e-06,4.20009e-06,5.08188e-06,5.99163e-06,7.2212e-06,8.6049e-06,1.02048e-05,1.27013e-05,1.60133e-05,1.99304e-05,2.56522e-05,3.38445e-05,4.46751e-05,5.72262e-05,0.00096445}
		  RInt_SMR_28keV[15] = {0.00355247,0.00880239,0.0142312,0.0197166,0.0239853,0.0280166,0.0343773,0.0343773,0.0280166,0.0239853,0.0197166,0.0142312,0.00880239,0.00355247,0.00096445,5.72262e-05}
		  RInt_SMR_28keV[31] = {4.46751e-05,3.38445e-05,2.56522e-05,1.99304e-05,1.60133e-05,1.27013e-05,1.02048e-05,8.6049e-06,7.2212e-06,5.99163e-06,5.08188e-06,4.20009e-06,3.66594e-06,2.87515e-06}
		  RInt_SMR_28keV[45] = {2.29345e-06,2.20161e-06,2.02844e-06,1.7393e-06,1.53696e-06,1.35147e-06,1.19567e-06,1.05893e-06,9.29112e-07,8.35098e-07,7.51103e-07,6.76741e-07,6.05939e-07,5.57197e-07}
		  RInt_SMR_28keV[59] = {5.09207e-07,4.66247e-07,4.17798e-07,3.86056e-07,3.61979e-07,3.19202e-07,2.89674e-07,2.66913e-07,2.47216e-07,2.25283e-07,2.08374e-07,1.92755e-07,1.75346e-07,1.61369e-07}
		  RInt_SMR_28keV[73] = {1.50516e-07,1.39631e-07,1.29316e-07,1.18864e-07,1.10752e-07,1.03966e-07,9.72355e-08,8.85637e-08,8.51727e-08,7.87305e-08,7.04279e-08,6.38201e-08,6.09268e-08,5.78965e-08}
		  RInt_SMR_28keV[87] = {5.16661e-08,4.90932e-08,4.72377e-08,3.95934e-08,3.77442e-08,3.7391e-08,3.57136e-08,3.08265e-08,2.89356e-08,2.8953e-08,2.63754e-08,2.52237e-08,2.26464e-08,1.85417e-08}
		  RInt_SMR_28keV[101] = {1.83537e-08,1.82787e-08,1.81447e-08,1.73324e-08,1.68142e-08,1.69271e-08,1.59401e-08,1.43486e-08,1.33081e-08,1.29711e-08,1.24346e-08,1.12078e-08,1.07215e-08,1.1033e-08}
		  RInt_SMR_28keV[115] = {1.05728e-08,1.00427e-08,9.77265e-09,8.9071e-09,8.11424e-09,7.91529e-09,7.22087e-09,6.87402e-09,6.78765e-09,6.48207e-09,6.43484e-09,5.98626e-09,5.7914e-09,5.87373e-09}
		  RInt_SMR_28keV[129] = {5.69871e-09,4.74146e-09,4.5944e-09,4.20002e-09,4.01141e-09,3.59315e-09,3.75037e-09,3.45246e-09,2.97288e-09,2.70833e-09,2.88369e-09,3.00281e-09,2.87993e-09,2.5665e-09}
		  RInt_SMR_28keV[143] = {2.77623e-09,2.78566e-09,2.84804e-09,2.63313e-09,2.67638e-09,2.46264e-09,2.14792e-09,2.18417e-09,2.24647e-09,2.23834e-09,2.28007e-09,2.03916e-09,1.90011e-09,1.91007e-09}
		  RInt_SMR_28keV[157] = {2.08065e-09,1.75074e-09,1.84184e-09,1.64722e-09,1.53622e-09,1.7342e-09,1.55457e-09,1.37617e-09,1.2407e-09,1.30717e-09,1.45067e-09,1.75663e-09,1.62328e-09,1.37536e-09}
		  RInt_SMR_28keV[171] = {1.40151e-09,1.33685e-09,1.24182e-09,1.549e-09,1.4678e-09,1.34028e-09,1.35219e-09,1.13031e-09,9.88829e-10,1.31024e-09,1.21839e-09,1.24041e-09,1.39424e-09,1.47143e-09}
		  RInt_SMR_28keV[185] = {1.38218e-09,1.44823e-09,1.50606e-09,1.35903e-09,1.43053e-09,1.39211e-09,1.04469e-09,1.0563e-09,8.90035e-10,7.60753e-10,9.63438e-10,8.97383e-10,9.57434e-10,1.01031e-09}
		  RInt_SMR_28keV[199] = {7.77208e-10,4.8018e-10,5.22412e-10,6.02141e-10,9.82714e-10,6.86574e-10,6.20277e-10,5.76554e-10,8.58368e-10,8.71661e-10,6.72469e-10,5.96359e-10,7.23763e-10,6.81136e-10}
		  RInt_SMR_28keV[213] = {1.00753e-09,8.15205e-10,9.27074e-10,7.45296e-10,7.59172e-10,8.69176e-10,9.48372e-10,8.99227e-10,6.66977e-10,7.59774e-10,6.3083e-10,6.12809e-10,8.35292e-10,8.27896e-10}
		  RInt_SMR_28keV[227] = {8.19581e-10,8.88108e-10,9.76672e-10,9.92957e-10,8.39058e-10,5.58206e-10,5.41224e-10,7.32982e-10,6.64447e-10,6.24288e-10,5.01162e-10,3.78885e-10,7.04157e-10,7.85617e-10}
		  RInt_SMR_28keV[241] = {4.7602e-10,5.30266e-10,3.87961e-10,5.10765e-10,4.97053e-10,5.34851e-10,3.83537e-10,3.91255e-10,4.89959e-10,7.12541e-10,8.75404e-10,7.51542e-10,6.71084e-10,4.1664e-10}
		  RInt_SMR_28keV[255] = {3.76919e-10,5.87253e-10,6.45923e-10,5.7163e-10,7.71664e-10,6.42969e-10,6.77681e-10,5.72416e-10,6.54988e-10,6.67311e-10,6.29917e-10,6.90825e-10,5.37672e-10,6.95196e-10}
		  RInt_SMR_28keV[269] = {5.27853e-10,6.77709e-10,5.76307e-10}
	
		
		  RE_SMR_28keV[0] = {4.37103e-08,4.6942e-08,5.10419e-08,5.36776e-08,5.90505e-08,6.51062e-08,7.15934e-08,7.90408e-08,8.85184e-08,9.96554e-08,1.18554e-07,1.43185e-07,1.63334e-07,2.01608e-07,5.8754e-06}
		  RE_SMR_28keV[15] = {1.33541e-05,2.76183e-05,3.9383e-05,5.20527e-05,6.0835e-05,6.98624e-05,7.95734e-05,7.95734e-05,6.98624e-05,6.0835e-05,5.20527e-05,3.9383e-05,2.76183e-05,1.33541e-05,5.8754e-06}
		  RE_SMR_28keV[30] = {2.01608e-07,1.63334e-07,1.43185e-07,1.18554e-07,9.96554e-08,8.85184e-08,7.90408e-08,7.15934e-08,6.51062e-08,5.90505e-08,5.36776e-08,5.10419e-08,4.6942e-08,4.37103e-08}
		  RE_SMR_28keV[44] = {3.1349e-08,8.01091e-09,7.39112e-09,7.17246e-09,6.16536e-09,5.73724e-09,5.1408e-09,4.63874e-09,4.27738e-09,3.82578e-09,3.55307e-09,3.38627e-09,3.05044e-09,2.87073e-09}
		  RE_SMR_28keV[58] = {2.70897e-09,2.59082e-09,2.4967e-09,2.28691e-09,2.13682e-09,2.14202e-09,1.9366e-09,1.85377e-09,1.75989e-09,1.71699e-09,1.59891e-09,1.57053e-09,1.50715e-09,1.44329e-09}
		  RE_SMR_28keV[72] = {1.38775e-09,1.34854e-09,1.31711e-09,1.24372e-09,1.20815e-09,1.17179e-09,1.13816e-09,1.09709e-09,1.07077e-09,1.05533e-09,1.03007e-09,9.76151e-10,9.30971e-10,9.11666e-10}
		  RE_SMR_28keV[86] = {9.09099e-10,8.7141e-10,8.61201e-10,8.55103e-10,7.91351e-10,7.87756e-10,7.89364e-10,7.7403e-10,7.58978e-10,7.21705e-10,7.33776e-10,7.17904e-10,6.91204e-10,4.38384e-10}
		  RE_SMR_28keV[100] = {5.06908e-11,4.65572e-11,5.01591e-11,1.49423e-10,1.45677e-10,1.45342e-10,1.47599e-10,1.42366e-10,1.35955e-10,1.31882e-10,1.31934e-10,1.29952e-10,1.2679e-10,1.24095e-10}
		  RE_SMR_28keV[114] = {1.26626e-10,1.23724e-10,1.22444e-10,1.2464e-10,1.19677e-10,1.14737e-10,1.15422e-10,1.10846e-10,1.12219e-10,1.14298e-10,1.12683e-10,1.13121e-10,1.10734e-10,1.10946e-10}
		  RE_SMR_28keV[128] = {1.11532e-10,1.11905e-10,1.07238e-10,1.06169e-10,1.06754e-10,1.05242e-10,1.02599e-10,1.04757e-10,1.0412e-10,1.01779e-10,1.00613e-10,1.02592e-10,1.02019e-10,1.0119e-10}
		  RE_SMR_28keV[142] = {1.00347e-10,1.01336e-10,1.01855e-10,1.03235e-10,1.02696e-10,1.03677e-10,1.02773e-10,1.02164e-10,1.01324e-10,1.01843e-10,1.01455e-10,1.03735e-10,1.00815e-10,1.00149e-10}
		  RE_SMR_28keV[156] = {1.0098e-10,1.02216e-10,9.96076e-11,1.00571e-10,1.00807e-10,1.00846e-10,1.00213e-10,1.00223e-10,1.01229e-10,1.00381e-10,9.99035e-11,1.02258e-10,1.04559e-10,1.02767e-10}
		  RE_SMR_28keV[170] = {1.022e-10,1.01942e-10,1.01886e-10,1.01422e-10,1.02808e-10,1.0398e-10,1.03189e-10,1.03263e-10,1.01878e-10,1.01319e-10,1.03213e-10,1.02849e-10,1.03426e-10,1.03985e-10}
		  RE_SMR_28keV[184] = {1.05405e-10,1.0439e-10,1.04718e-10,1.048e-10,1.04111e-10,1.04608e-10,1.05125e-10,1.02402e-10,1.0309e-10,1.02558e-10,1.02509e-10,1.04132e-10,1.03123e-10,1.03554e-10}
		  RE_SMR_28keV[198] = {1.03129e-10,1.02942e-10,1.01114e-10,1.00592e-10,1.01363e-10,1.03857e-10,1.02444e-10,1.02018e-10,1.02026e-10,1.03457e-10,1.03541e-10,1.03086e-10,1.03089e-10,1.03456e-10}
		  RE_SMR_28keV[212] = {1.0273e-10,1.0449e-10,1.04601e-10,1.07144e-10,1.05311e-10,1.05431e-10,1.06016e-10,1.0641e-10,1.06379e-10,1.04536e-10,1.05062e-10,1.03558e-10,1.04182e-10,1.04815e-10}
		  RE_SMR_28keV[226] = {1.05087e-10,1.05188e-10,1.04935e-10,1.05881e-10,1.04225e-10,1.03567e-10,1.02991e-10,1.03011e-10,1.04232e-10,1.01901e-10,1.0193e-10,1.01289e-10,9.94083e-11,1.0088e-10}
		  RE_SMR_28keV[240] = {1.00702e-10,9.941e-11,1.00009e-10,9.86689e-11,9.92658e-11,9.84972e-11,9.97935e-11,9.99615e-11,1.00787e-10,9.94162e-11,1.00498e-10,9.89166e-11,9.71366e-11,9.5387e-11}
		  RE_SMR_28keV[254] = {9.34105e-11,9.17721e-11,9.22045e-11,9.29414e-11,9.31481e-11,9.41805e-11,9.45974e-11,9.396e-11,9.20657e-11,9.36367e-11,9.07716e-11,8.78587e-11,8.65713e-11,8.60599e-11}
		  RE_SMR_28keV[268] = {8.46177e-11,8.3001e-11,8.28452e-11,8.3658e-11}
	
	endif


	//Create some instrument Curves
	Wave/Z RQ_SMR_24keV_440
	if(!waveExists(RQ_SMR_24keV_440))
		
		Make/O/N=300 RQ_SMR_24keV_440, RInt_SMR_24keV_440, RE_SMR_24keV_440
		
		  RQ_SMR_24keV_440[0] = {-0.000291945,-0.000283455,-0.00027461,-0.000265824,-0.000257451,-0.000250553,-0.000243241,-0.000234809,-0.000227085,-0.000221306,-0.000214585,-0.000207922,-0.000201141}
		  RQ_SMR_24keV_440[13] = {-0.000194773,-0.000188405,-0.000182685,-0.000177201,-0.000170951,-0.000166234,-0.000160927,-0.000155385,-0.000150432,-0.000146009,-0.000140938,-0.000136457,-0.000131799}
		  RQ_SMR_24keV_440[26] = {-0.000127377,-0.000123957,-0.000119652,-0.000115407,-0.000111869,-0.000108213,-0.000103791,-9.97226e-05,-9.65975e-05,-9.30007e-05,-9.02883e-05,-8.65146e-05,-8.35075e-05}
		  RQ_SMR_24keV_440[39] = {-8.01465e-05,-7.66676e-05,-7.4368e-05,-7.08891e-05,-6.91792e-05,-6.55234e-05,-6.32828e-05,-6.03346e-05,-5.8035e-05,-5.51457e-05,-5.3082e-05,-5.01928e-05,-4.82469e-05}
		  RQ_SMR_24keV_440[52] = {-4.58884e-05,-4.35888e-05,-4.17609e-05,-3.85768e-05,-3.73976e-05,-3.5098e-05,-3.22677e-05,-3.06167e-05,-2.87888e-05,-2.71968e-05,-2.50741e-05,-2.26565e-05,-2.13593e-05}
		  RQ_SMR_24keV_440[65] = {-1.91187e-05,-1.81163e-05,-1.64063e-05,-1.44016e-05,-1.28095e-05,-1.16303e-05,-9.68444e-06,-8.03345e-06,-6.44142e-06,-5.02628e-06,-3.72907e-06,-1.48844e-06,-9.57763e-07}
		  RQ_SMR_24keV_440[78] = {9.88051e-07,2.46215e-06,3.64143e-06,5.8231e-06,7.59203e-06,8.65338e-06,1.05992e-05,1.22502e-05,1.36064e-05,1.46087e-05,1.69083e-05,1.88542e-05,2.11538e-05,2.18613e-05}
		  RQ_SMR_24keV_440[92] = {2.43968e-05,2.68143e-05,2.79346e-05,2.99984e-05,3.17673e-05,3.46565e-05,3.61896e-05,3.81354e-05,4.10247e-05,4.30884e-05,4.50932e-05,4.698e-05,5.01051e-05,5.34071e-05}
		  RQ_SMR_24keV_440[106] = {5.51171e-05,5.74756e-05,5.99521e-05,6.31951e-05,6.56127e-05,6.80302e-05,7.10374e-05,7.44573e-05,7.66979e-05,7.97051e-05,8.28302e-05,8.61322e-05,8.967e-05,9.32668e-05}
		  RQ_SMR_24keV_440[120] = {9.64509e-05,9.9458e-05,0.000103468,0.000107005,0.000111133,0.000114317,0.000119152,0.000122808,0.000126758,0.000131947,0.000135898,0.000139672,0.000144919,0.000149636}
		  RQ_SMR_24keV_440[134] = {0.000154707,0.000160132,0.000164908,0.000169979,0.000175522,0.000180769,0.000186725,0.000193034,0.000198871,0.000205711,0.000211726,0.000218035,0.000225287,0.000232717}
		  RQ_SMR_24keV_440[148] = {0.000239793,0.00024675,0.000254534,0.000262081,0.000270985,0.000279004,0.000287907,0.000296575,0.00030595,0.00031509,0.000325821,0.000335314,0.000346223,0.000356482}
		  RQ_SMR_24keV_440[162] = {0.000367273,0.000379007,0.000390741,0.000402946,0.000415859,0.000428654,0.00044198,0.000455719,0.00047046,0.000485555,0.000500355,0.000516924,0.000533257,0.000549531}
		  RQ_SMR_24keV_440[176] = {0.000568281,0.000585794,0.000604957,0.000624828,0.000644463,0.000665218,0.000687271,0.00071009,0.000733204,0.000757143,0.000782852,0.000809032,0.000836096,0.000863632}
		  RQ_SMR_24keV_440[190] = {0.000892702,0.000923127,0.000955145,0.000988105,0.00102207,0.00105762,0.00109424,0.00113227,0.00117213,0.00121264,0.0012561,0.0013015,0.0013482,0.0013972,0.00144696,0.00150033}
		  RQ_SMR_24keV_440[206] = {0.00155552,0.00161289,0.00167315,0.00173606,0.00180098,0.00186873,0.00194061,0.00201514,0.00209292,0.00217458,0.00225978,0.00234917,0.00244222,0.00254039,0.00264217,0.00274889}
		  RQ_SMR_24keV_440[222] = {0.00286192,0.00297985,0.00310403,0.00323334,0.00337014,0.00351336,0.00366319,0.00382127,0.00398784,0.00416173,0.00434581,0.00454004,0.00474317,0.00495804,0.00518446,0.00542527}
		  RQ_SMR_24keV_440[238] = {0.00567705,0.00594238,0.00622288,0.00651852,0.00683522,0.00716618,0.0075182,0.00789174,0.00828426,0.00870314,0.00914602,0.00961667,0.0101177,0.0106496,0.0112137,0.0118124}
		  RQ_SMR_24keV_440[254] = {0.0124524,0.0131325,0.0138588,0.0146325,0.0154598,0.0163405,0.0172835,0.0182922,0.0193714,0.0205274,0.0217657,0.0230961,0.0245218,0.0260549,0.0277049,0.0294812,0.0313914}
		  RQ_SMR_24keV_440[271] = {0.0334532,0.03568,0.0380848,0.0406838,0.0434965,0.0465452,0.0498515,0.0534421,0.0573445,0.0615909,0.066218,0.0712651,0.0767761,0.0828032,0.0894022,0.0966371,0.104579,0.113312}
		  RQ_SMR_24keV_440[289] = {0.122928,0.133528,0.145235,0.158184,0.172531,0.188453,0.206156,0.225869,0.247866,0.272459,0.299997}
		  

		  RInt_SMR_24keV_440[0] = {1.90426e-08,1.90377e-08,2.91683e-07,3.05267e-07,3.32695e-07,3.54932e-07,3.8639e-07,4.17259e-07,4.52934e-07,4.97899e-07,5.35854e-07,5.72409e-07,6.22885e-07,6.82434e-07,7.36669e-07}
		  RInt_SMR_24keV_440[15] = {8.08213e-07,8.62406e-07,9.38064e-07,1.0087e-06,1.10534e-06,1.19697e-06,1.2768e-06,1.40948e-06,1.52756e-06,1.66962e-06,1.80998e-06,1.97616e-06,2.15664e-06,2.36055e-06,2.57523e-06}
		  RInt_SMR_24keV_440[30] = {2.78167e-06,3.00885e-06,3.27412e-06,3.55497e-06,3.87481e-06,4.23796e-06,4.60548e-06,5.02085e-06,5.44671e-06,5.91057e-06,6.38484e-06,6.96343e-06,7.65657e-06,8.45713e-06}
		  RInt_SMR_24keV_440[44] = {9.30249e-06,1.04018e-05,1.16068e-05,1.29954e-05,1.46625e-05,1.65224e-05,1.85511e-05,2.11442e-05,2.41579e-05,2.72895e-05,3.06458e-05,3.47552e-05,4.01403e-05,4.59536e-05}
		  RInt_SMR_24keV_440[58] = {5.3195e-05,6.23889e-05,7.84433e-05,0.000107156,0.000162459,0.000255094,0.00042831,0.000776721,0.00146574,0.0028708,0.00486452,0.00787422,0.0112995,0.0147485,0.018218,0.020619}
		  RInt_SMR_24keV_440[74] = {0.0224356,0.0237668,0.0247762,0.0253202,0.0257372,0.0254981,0.024212,0.022103,0.0191742,0.0158821,0.0128019,0.00990694,0.00754641,0.00557645,0.00428403,0.00314333,0.00226237}
		  RInt_SMR_24keV_440[91] = {0.00166481,0.00124295,0.000886452,0.000623979,0.000437915,0.000314638,0.000237326,0.000168148,0.000125087,9.44213e-05,7.28567e-05,5.88126e-05,4.7094e-05,3.82494e-05,3.16098e-05}
		  RInt_SMR_24keV_440[106] = {2.64937e-05,2.24794e-05,1.92658e-05,1.65274e-05,1.42081e-05,1.23491e-05,1.07714e-05,9.49943e-06,8.45653e-06,7.51136e-06,6.72377e-06,5.98732e-06,5.3394e-06,4.76078e-06}
		  RInt_SMR_24keV_440[120] = {4.24362e-06,3.81417e-06,3.43638e-06,3.09706e-06,2.76272e-06,2.47879e-06,2.21919e-06,2.00358e-06,1.80946e-06,1.63922e-06,1.49883e-06,1.37775e-06,1.26902e-06,1.16612e-06}
		  RInt_SMR_24keV_440[134] = {1.0816e-06,9.98188e-07,9.21373e-07,8.43222e-07,7.76299e-07,7.24246e-07,6.58726e-07,6.11055e-07,5.62059e-07,5.21915e-07,4.84885e-07,4.51186e-07,4.17685e-07,3.85894e-07}
		  RInt_SMR_24keV_440[148] = {3.59147e-07,3.33456e-07,3.10748e-07,2.88109e-07,2.68294e-07,2.50185e-07,2.31591e-07,2.14887e-07,1.99793e-07,1.85438e-07,1.71475e-07,1.59106e-07,1.47128e-07,1.39697e-07}
		  RInt_SMR_24keV_440[162] = {1.29857e-07,1.20771e-07,1.14015e-07,1.05772e-07,9.96427e-08,9.29804e-08,8.62375e-08,8.06248e-08,7.57648e-08,6.99189e-08,6.42707e-08,6.06411e-08,5.67127e-08,5.2623e-08}
		  RInt_SMR_24keV_440[176] = {4.88636e-08,4.56262e-08,4.19389e-08,4.06626e-08,3.84733e-08,3.54661e-08,3.31472e-08,3.19069e-08,2.95407e-08,2.81877e-08,2.60258e-08,2.45817e-08,2.30705e-08,2.20593e-08}
		  RInt_SMR_24keV_440[190] = {2.02337e-08,1.85635e-08,1.77309e-08,1.65513e-08,1.58123e-08,1.42565e-08,1.41031e-08,1.22736e-08,1.16064e-08,1.08896e-08,1.03419e-08,9.69127e-09,8.9379e-09,8.32896e-09}
		  RInt_SMR_24keV_440[204] = {7.97071e-09,7.29268e-09,6.59336e-09,6.52902e-09,6.07684e-09,5.36892e-09,5.31275e-09,4.78665e-09,4.65504e-09,4.31098e-09,4.00137e-09,3.71274e-09,3.35973e-09,3.35421e-09}
		  RInt_SMR_24keV_440[218] = {3.04545e-09,2.74034e-09,2.28633e-09,2.52153e-09,2.40155e-09,2.15732e-09,2.04456e-09,1.84691e-09,1.8304e-09,1.64736e-09,1.52439e-09,1.37816e-09,1.34111e-09,1.17982e-09}
		  RInt_SMR_24keV_440[232] = {1.27035e-09,1.20724e-09,1.05974e-09,1.03565e-09,9.78462e-10,8.49836e-10,8.446e-10,7.29782e-10,7.33737e-10,6.43871e-10,7.16907e-10,6.84514e-10,6.34919e-10,6.58593e-10}
		  RInt_SMR_24keV_440[246] = {5.79453e-10,5.31374e-10,4.92166e-10,4.05927e-10,4.57296e-10,3.75705e-10,3.10621e-10,2.64257e-10,1.80226e-10,2.74907e-10,2.80242e-10,2.36606e-10,1.97982e-10,2.25634e-10}
		  RInt_SMR_24keV_440[260] = {2.01649e-10,2.05635e-10,2.38884e-10,1.56973e-10,2.19549e-10,2.31714e-10,1.53872e-10,2.19502e-10,1.34264e-10,1.47932e-10,1.43595e-10,1.26533e-10,1.87617e-10,1.48246e-10}
		  RInt_SMR_24keV_440[274] = {1.84093e-10,1.56816e-10,1.71313e-10,1.53982e-10,8.93707e-11,1.32192e-10,1.14438e-10,1.90221e-10,1.53141e-10,7.45908e-11,2.75435e-11,4.9047e-11,4.0632e-11,5.32964e-11}
		  RInt_SMR_24keV_440[288] = {1.61188e-11,9.2927e-11,1.04972e-10,9.16112e-11,1.41647e-10,1.63819e-10,5.28849e-11,1.22053e-10,5.21719e-11,7.87788e-11,8.16896e-11,1.28598e-11}
		  
		  RE_SMR_24keV_440[0] = {2.26923e-08,2.26864e-08,3.70601e-09,7.54195e-10,8.12537e-10,8.60325e-10,9.26613e-10,9.92309e-10,1.06829e-09,1.16315e-09,1.24419e-09,1.32108e-09,1.42799e-09,1.5541e-09,1.66914e-09}
		  RE_SMR_24keV_440[15] = {1.81991e-09,1.93492e-09,2.09478e-09,2.24366e-09,2.44845e-09,2.64169e-09,2.8102e-09,8.5449e-09,8.94009e-09,9.40261e-09,9.8566e-09,1.03618e-08,1.09084e-08,1.15061e-08,1.2119e-08}
		  RE_SMR_24keV_440[30] = {1.26993e-08,1.33194e-08,1.4025e-08,1.47693e-08,1.56028e-08,1.65083e-08,1.74141e-08,1.84399e-08,1.9488e-08,2.05931e-08,2.17046e-08,2.30837e-08,2.46794e-08,2.65061e-08}
		  RE_SMR_24keV_440[44] = {2.84322e-08,3.08783e-08,3.35904e-08,3.66245e-08,4.02612e-08,4.43456e-08,4.87166e-08,5.43098e-08,6.07798e-08,6.74967e-08,7.46358e-08,8.34197e-08,9.48605e-08,1.07186e-07}
		  RE_SMR_24keV_440[58] = {1.22543e-07,1.41974e-07,1.75985e-07,2.36648e-07,3.53418e-07,1.20346e-06,1.66086e-06,2.49184e-06,4.02523e-06,7.0518e-06,1.12892e-05,1.76572e-05,2.49007e-05,3.21855e-05}
		  RE_SMR_24keV_440[72] = {9.88212e-05,0.000106031,0.000111475,0.000115423,0.000118294,0.000119817,0.000121145,0.000120292,0.000116641,0.000110466,0.000101708,9.13845e-05,8.09094e-05,7.03494e-05}
		  RE_SMR_24keV_440[86] = {6.0733e-05,1.2801e-05,1.00592e-05,7.63478e-06,5.75032e-06,4.46544e-06,3.53658e-06,2.73966e-06,2.13559e-06,1.68412e-06,1.36424e-06,1.15095e-06,9.4289e-07,5.04118e-07}
		  RE_SMR_24keV_440[100] = {4.24012e-07,3.63777e-07,1.23474e-07,9.95864e-08,8.15557e-08,6.80103e-08,5.75659e-08,4.9368e-08,4.28042e-08,3.71985e-08,3.2445e-08,2.86336e-08,2.53858e-08,2.27659e-08}
		  RE_SMR_24keV_440[114] = {2.0609e-08,1.86509e-08,1.70105e-08,1.54695e-08,1.41114e-08,1.28881e-08,1.179e-08,1.08697e-08,1.00528e-08,9.31189e-09,8.5765e-09,7.94049e-09,7.35417e-09,6.85464e-09}
		  RE_SMR_24keV_440[128] = {6.40279e-09,6.00271e-09,5.66155e-09,5.36296e-09,5.09432e-09,4.83131e-09,4.61133e-09,4.39199e-09,4.18285e-09,3.96987e-09,3.77651e-09,3.62573e-09,1.38807e-09,1.2909e-09}
		  RE_SMR_24keV_440[142] = {1.19106e-09,1.10917e-09,1.03371e-09,9.65097e-10,8.96759e-10,8.32073e-10,7.7747e-10,7.25036e-10,6.78857e-10,6.32505e-10,5.92127e-10,5.55277e-10,5.17268e-10,4.8318e-10}
		  RE_SMR_24keV_440[156] = {4.52398e-10,4.22983e-10,3.94505e-10,3.69206e-10,3.44774e-10,3.29549e-10,3.09329e-10,2.90762e-10,2.76996e-10,2.60104e-10,2.47268e-10,2.33544e-10,2.19758e-10,2.08173e-10}
		  RE_SMR_24keV_440[170] = {1.982e-10,1.86085e-10,1.74462e-10,1.66989e-10,1.5879e-10,1.50303e-10,1.4243e-10,1.35654e-10,1.2792e-10,1.25278e-10,1.20677e-10,1.14336e-10,1.09426e-10,1.06786e-10,1.01813e-10}
		  RE_SMR_24keV_440[185] = {9.88434e-11,9.41927e-11,9.11402e-11,8.78624e-11,8.56981e-11,8.17507e-11,7.8055e-11,7.62434e-11,7.36266e-11,7.19805e-11,6.84974e-11,6.81674e-11,6.40926e-11,5.1656e-11}
		  RE_SMR_24keV_440[199] = {5.02117e-11,4.91142e-11,4.78022e-11,4.62879e-11,4.50592e-11,4.42817e-11,4.29039e-11,4.15026e-11,4.13725e-11,4.05042e-11,3.90857e-11,3.89757e-11,3.79141e-11,3.76298e-11}
		  RE_SMR_24keV_440[213] = {3.6948e-11,3.63123e-11,3.57631e-11,3.50886e-11,3.50789e-11,3.44526e-11,3.383e-11,1.48306e-11,1.52679e-11,1.50531e-11,1.4581e-11,1.4373e-11,1.39921e-11,1.3963e-11,1.36089e-11}
		  RE_SMR_24keV_440[228] = {1.33881e-11,1.31121e-11,1.30404e-11,1.27307e-11,1.29496e-11,1.28054e-11,1.25271e-11,1.24901e-11,1.23923e-11,1.21336e-11,1.21283e-11,1.19184e-11,1.19232e-11,1.17621e-11}
		  RE_SMR_24keV_440[242] = {1.1911e-11,1.1839e-11,1.17569e-11,1.17729e-11,1.16336e-11,1.15386e-11,1.14768e-11,1.13219e-11,1.14158e-11,1.12629e-11,1.11346e-11,1.10589e-11,1.09074e-11,1.1071e-11}
		  RE_SMR_24keV_440[256] = {1.10894e-11,1.10189e-11,1.09487e-11,1.10001e-11,1.09474e-11,1.09273e-11,1.09855e-11,1.08435e-11,1.09735e-11,1.09739e-11,1.08399e-11,1.09436e-11,1.08084e-11,1.08339e-11}
		  RE_SMR_24keV_440[270] = {1.08183e-11,1.07861e-11,1.09057e-11,1.08304e-11,1.09026e-11,1.0849e-11,1.08705e-11,1.08486e-11,1.07311e-11,1.0815e-11,1.07745e-11,1.09007e-11,1.08403e-11,1.07039e-11}
		  RE_SMR_24keV_440[284] = {1.05912e-11,1.06254e-11,1.06151e-11,1.06525e-11,1.05798e-11,1.07232e-11,1.07346e-11,1.07255e-11,1.08014e-11,1.08483e-11,1.06413e-11,1.07808e-11,1.06725e-11,1.06913e-11}
		  RE_SMR_24keV_440[298] = {1.06697e-11,1.05476e-11}
			
	endif

	

	WAVE/Z RQ_DSM_12keV
	if(!WaveExists(RQ_DSM_12keV))

		Make/O/N=150 RQ_DSM_12keV, RInt_DSM_12keV, RE_DSM_12keV

		RInt_DSM_12keV[0]   = {1.50893e-14, 2.2575e-14, 3.24536e-14, 5.18101e-14, 1.03041e-13, 2.89978e-13, 2.42025e-12, 6.13852e-12, 2.47493e-11, 3.69889e-11, 5.62025e-11, 7.08025e-11, 8.40702e-11, 9.79318e-11, 1.03697e-10, 1.17464e-10}
		RInt_DSM_12keV[16]  = {1.29073e-10, 1.28846e-10, 1.42287e-10, 1.5557e-10, 1.54884e-10, 1.67286e-10, 1.66777e-10, 1.75392e-10, 1.75132e-10, 1.77768e-10, 1.77372e-10, 1.75329e-10, 1.74886e-10, 1.68271e-10, 1.67605e-10, 1.67124e-10}
		RInt_DSM_12keV[32]  = {1.56331e-10, 1.49161e-10, 1.37869e-10, 1.39457e-10, 1.26889e-10, 1.25667e-10, 1.03455e-10, 8.81e-11, 8.70238e-11, 6.59543e-11, 5.50316e-11, 4.39494e-11, 2.59856e-11, 1.49173e-11, 6.92115e-12, 1.04369e-12}
		RInt_DSM_12keV[48]  = {2.30955e-13, 1.03844e-13, 6.1548e-14, 3.69798e-14, 2.35784e-14, 1.75745e-14, 1.34446e-14, 1.01413e-14, 8.11995e-15, 6.56702e-15, 5.33438e-15, 4.3601e-15, 3.5337e-15, 2.98859e-15, 2.54672e-15, 2.12866e-15}
		RInt_DSM_12keV[64]  = {1.83398e-15, 1.62187e-15, 1.43033e-15, 1.22898e-15, 1.04453e-15, 9.23781e-16, 7.9394e-16, 6.96159e-16, 6.19297e-16, 5.41633e-16, 4.8202e-16, 4.26875e-16, 3.81121e-16, 3.36339e-16, 2.92931e-16, 2.57316e-16}
		RInt_DSM_12keV[80]  = {2.21617e-16, 1.95924e-16, 1.71465e-16, 1.51885e-16, 1.33672e-16, 1.16198e-16, 1.00967e-16, 8.83993e-17, 7.69955e-17, 6.79866e-17, 6.03185e-17, 5.34694e-17, 4.6781e-17, 4.14275e-17, 3.56554e-17, 3.09206e-17}
		RInt_DSM_12keV[96]  = {2.62556e-17, 2.23354e-17, 1.98075e-17, 1.72305e-17, 1.51142e-17, 1.29525e-17, 1.10527e-17, 9.81509e-18, 8.59635e-18, 7.26849e-18, 6.51717e-18, 5.76804e-18, 5.33092e-18, 4.30377e-18, 3.94226e-18, 3.53041e-18}
		RInt_DSM_12keV[112] = {3.05551e-18, 2.97805e-18, 2.4152e-18, 1.97413e-18, 1.9738e-18, 1.81151e-18, 1.61568e-18, 1.4453e-18, 1.408e-18, 1.43477e-18, 1.23356e-18, 1.10925e-18, 1.15156e-18, 1.07912e-18, 1.10517e-18, 1.02869e-18}
		RInt_DSM_12keV[128] = {1.01163e-18, 1.02297e-18, 8.82708e-19, 9.22718e-19, 8.43775e-19, 7.26586e-19, 8.34552e-19, 6.74692e-19, 6.97695e-19, 7.13235e-19, 5.28917e-19, 4.22705e-19, 3.53887e-19, 3.04784e-19, 2.61698e-19, 3.4387e-19}
		RInt_DSM_12keV[144] = {3.40644e-19, 4.14617e-19, 3.32082e-19, 3.57083e-19, 2.65324e-19, 3.34564e-19}

		RQ_DSM_12keV[0]   = {-0.000156891, -0.000144644, -0.000133402, -0.000120955, -0.000110416, -0.000101281, -9.28495e-05, -8.28117e-05, -7.438e-05, -6.88592e-05, -5.93233e-05, -5.38025e-05, -4.86832e-05, -4.24598e-05, -4.00508e-05}
		RQ_DSM_12keV[15]  = {-3.36266e-05, -2.74031e-05, -2.74031e-05, -2.19827e-05, -1.60605e-05, -1.60605e-05, -9.83703e-06, -9.83703e-06, -4.11549e-06, -4.11549e-06, -1.40529e-06, -1.40529e-06, 3.91474e-06, 3.91474e-06, 1.1945e-05}
		RQ_DSM_12keV[30]  = {1.1945e-05, 1.1945e-05, 1.49563e-05, 1.90718e-05, 2.51948e-05, 2.51948e-05, 3.17194e-05, 3.17194e-05, 3.83443e-05, 4.57723e-05, 4.57723e-05, 5.33006e-05, 6.05278e-05, 6.55467e-05, 7.46811e-05, 8.02019e-05}
		RQ_DSM_12keV[46]  = {8.56223e-05, 9.56601e-05, 0.000103891, 0.000111419, 0.000122361, 0.000133101, 0.000143942, 0.00015669, 0.000167029, 0.000182286, 0.000196138, 0.000211195, 0.000226252, 0.000244018, 0.000263893, 0.000286077}
		RQ_DSM_12keV[62]  = {0.000304647, 0.000329741, 0.000352025, 0.000379328, 0.000404021, 0.000434134, 0.000466958, 0.000497372, 0.000536319, 0.000574362, 0.000615416, 0.000657575, 0.000704753, 0.000755042, 0.00080764, 0.000864052}
		RQ_DSM_12keV[78]  = {0.000925283, 0.000990328, 0.00105959, 0.00113357, 0.00121226, 0.00129648, 0.00138381, 0.00147967, 0.00158336, 0.00168966, 0.0018073, 0.00193448, 0.00206688, 0.00220942, 0.00236229, 0.00252199, 0.00269334}
		RQ_DSM_12keV[95]  = {0.00287663, 0.00307748, 0.00328476, 0.00350921, 0.00375082, 0.00400859, 0.00427901, 0.00457, 0.00488368, 0.00521453, 0.00557217, 0.0059513, 0.00635472, 0.00678705, 0.00725049, 0.00774204, 0.00826672}
		RQ_DSM_12keV[112] = {0.00883164, 0.0094306, 0.010072, 0.0107544, 0.011483, 0.0122637, 0.013097, 0.0139855, 0.0149331, 0.0159478, 0.0170295, 0.0181838, 0.0194183, 0.0207346, 0.0221393, 0.0236406, 0.0252447, 0.026956, 0.0287818}
		RQ_DSM_12keV[131] = {0.0307331, 0.0328168, 0.0350402, 0.0374141, 0.0399515, 0.0426562, 0.0455482, 0.0486359, 0.0519288, 0.055447, 0.0592044, 0.0632176, 0.0674956, 0.0720681, 0.0769514, 0.0821626, 0.0877282, 0.0936685, 0.100016}

		RE_DSM_12keV[0]   = {3.69508e-16, 2.35703e-16, 3.37502e-16, 7.8645e-16, 1.33347e-15, 3.27647e-15, 2.52354e-14, 6.35417e-14, 2.83683e-13, 4.10176e-13, 6.08458e-13, 7.58991e-13, 8.9583e-13, 1.03874e-12, 1.09819e-12, 1.24004e-12}
		RE_DSM_12keV[16]  = {1.35974e-12, 1.35742e-12, 1.49597e-12, 1.63281e-12, 1.62574e-12, 1.75348e-12, 1.74823e-12, 1.83703e-12, 1.83444e-12, 1.86164e-12, 1.85759e-12, 1.83654e-12, 1.83196e-12, 1.76376e-12, 1.75691e-12, 1.75196e-12}
		RE_DSM_12keV[32]  = {1.64077e-12, 1.56697e-12, 1.45062e-12, 1.46698e-12, 1.33744e-12, 1.32487e-12, 1.0959e-12, 9.37695e-13, 9.26637e-13, 7.09387e-13, 5.96714e-13, 4.82326e-13, 2.96691e-13, 1.81828e-13, 9.76674e-14, 3.01741e-14}
		RE_DSM_12keV[48]  = {2.66766e-15, 1.34311e-15, 8.93134e-16, 6.22619e-16, 4.66844e-16, 3.92657e-16, 1.41657e-16, 1.076e-16, 8.67614e-17, 7.07485e-17, 5.80335e-17, 4.79757e-17, 3.9453e-17, 3.38116e-17, 2.9243e-17, 2.49092e-17}
		RE_DSM_12keV[64]  = {2.18454e-17, 1.96381e-17, 1.76419e-17, 1.55341e-17, 1.35952e-17, 1.23154e-17, 1.09367e-17, 9.88606e-18, 9.05379e-18, 8.20536e-18, 7.55011e-18, 6.93431e-18, 6.41856e-18, 5.90464e-18, 5.39832e-18, 4.96842e-18}
		RE_DSM_12keV[80]  = {4.53224e-18, 4.20978e-18, 3.89459e-18, 3.63806e-18, 1.51145e-18, 1.33194e-18, 1.17546e-18, 1.04637e-18, 9.29589e-19, 8.371e-19, 7.58488e-19, 6.88351e-19, 6.20326e-19, 5.65752e-19, 5.06968e-19, 4.58905e-19}
		RE_DSM_12keV[96]  = {4.11879e-19, 3.72347e-19, 3.47052e-19, 3.21522e-19, 3.00359e-19, 2.79237e-19, 2.60747e-19, 2.4876e-19, 2.37025e-19, 2.2429e-19, 2.17261e-19, 2.09916e-19, 2.0584e-19, 1.96271e-19, 1.93117e-19, 1.89289e-19}
		RE_DSM_12keV[112] = {1.85049e-19, 1.84366e-19, 1.79231e-19, 1.75361e-19, 1.75482e-19, 1.74171e-19, 1.72399e-19, 1.70862e-19, 1.7058e-19, 1.70905e-19, 1.69124e-19, 1.68135e-19, 1.68534e-19, 1.67903e-19, 1.68047e-19, 1.67422e-19}
		RE_DSM_12keV[128] = {1.67316e-19, 1.67349e-19, 1.66176e-19, 1.66589e-19, 1.65971e-19, 1.64809e-19, 1.65786e-19, 1.64389e-19, 1.64465e-19, 1.64337e-19, 1.6288e-19, 1.61798e-19, 1.61103e-19, 1.60839e-19, 1.60583e-19, 1.61241e-19}
		RE_DSM_12keV[144] = {1.6086e-19, 1.61707e-19, 1.60823e-19, 1.60902e-19, 1.6019e-19, 1.60851e-19}
	endif

	WAVE/Z RQ_DSM_18keV
	if(!WaveExists(RQ_DSM_18keV))

		Make/O/N=150 RQ_DSM_18keV, RInt_DSM_18keV, RE_DSM_18keV
		RInt_DSM_18keV[0]   = {5.24009e-14, 6.1124e-14, 7.61136e-14, 1.00655e-13, 1.38849e-13, 1.89272e-13, 2.52439e-13, 3.63818e-13, 7.765e-13, 2.41918e-12, 3.32596e-11, 7.6516e-11, 1.14988e-10, 1.41083e-10, 1.64477e-10, 1.84605e-10}
		RInt_DSM_18keV[16]  = {2.06679e-10, 2.24735e-10, 2.39437e-10, 2.54394e-10, 2.72836e-10, 2.91756e-10, 3.07932e-10, 3.14864e-10, 3.16117e-10, 3.15646e-10, 3.14759e-10, 3.03015e-10, 2.94444e-10, 2.80371e-10, 2.64536e-10, 2.50365e-10}
		RInt_DSM_18keV[32]  = {2.34827e-10, 2.14293e-10, 1.90568e-10, 1.64749e-10, 1.28247e-10, 9.37316e-11, 4.63574e-11, 1.86323e-11, 4.73741e-12, 1.21607e-12, 5.54255e-13, 3.23686e-13, 2.32775e-13, 1.59872e-13, 1.2009e-13, 9.27613e-14}
		RInt_DSM_18keV[48]  = {7.52157e-14, 5.59153e-14, 3.84074e-14, 3.0141e-14, 2.45524e-14, 1.85698e-14, 1.47472e-14, 1.16084e-14, 8.32342e-15, 6.72086e-15, 5.36353e-15, 4.36681e-15, 3.41309e-15, 2.75105e-15, 2.19682e-15, 1.76791e-15}
		RInt_DSM_18keV[64]  = {1.3992e-15, 1.1057e-15, 8.50715e-16, 6.85318e-16, 5.40793e-16, 4.44946e-16, 3.58747e-16, 2.95063e-16, 2.38242e-16, 1.90692e-16, 1.5955e-16, 1.30057e-16, 1.07116e-16, 8.99213e-17, 7.54791e-17, 6.21945e-17}
		RInt_DSM_18keV[80]  = {5.18755e-17, 4.33622e-17, 3.62383e-17, 3.11283e-17, 2.60883e-17, 2.23326e-17, 1.93082e-17, 1.67493e-17, 1.49736e-17, 1.30657e-17, 1.12443e-17, 1.00897e-17, 8.86493e-18, 8.22192e-18, 7.14027e-18, 6.38603e-18}
		RInt_DSM_18keV[96]  = {5.53245e-18, 5.11939e-18, 4.55373e-18, 4.31109e-18, 3.87659e-18, 3.48325e-18, 3.27192e-18, 2.99842e-18, 2.88518e-18, 2.61306e-18, 2.34518e-18, 2.21957e-18, 2.2343e-18, 2.05637e-18, 1.97079e-18, 1.68582e-18}
		RInt_DSM_18keV[112] = {1.75656e-18, 1.60955e-18, 1.48353e-18, 1.57541e-18, 1.41709e-18, 1.40601e-18, 1.41146e-18, 1.36665e-18, 1.18582e-18, 1.20043e-18, 1.13347e-18, 1.1221e-18, 1.00137e-18, 8.8001e-19, 7.85363e-19, 5.76393e-19}
		RInt_DSM_18keV[128] = {4.26071e-19, 2.85174e-19, 2.72478e-19, 3.09004e-19, 2.44614e-19, 3.07052e-19, 2.38978e-19, 2.76265e-19, 2.69063e-19, 1.86035e-19, 2.85718e-19, 3.13553e-19, 2.42807e-19, 3.00865e-19, 3.41737e-19, 2.8299e-19}
		RInt_DSM_18keV[144] = {2.62143e-19, 1.96346e-19, 3.2708e-19, 2.98975e-19, 2.18596e-19, 1.92465e-19}

		RQ_DSM_18keV[0]   = {-0.000217758, -0.000198298, -0.000183525, -0.000166764, -0.000150144, -0.000135513, -0.00012486, -0.000115058, -0.000104547, -9.28989e-05, -7.86942e-05, -6.71884e-05, -5.80973e-05, -5.07109e-05, -4.60233e-05}
		RQ_DSM_18keV[15]  = {-3.99153e-05, -3.46595e-05, -2.92617e-05, -2.52844e-05, -2.1023e-05, -1.61934e-05, -1.13638e-05, -6.39213e-06, -1.56252e-06, 1.42047e-07, 3.40913e-06, 6.25008e-06, 1.03695e-05, 1.29263e-05, 1.69036e-05}
		RQ_DSM_18keV[30]  = {2.08809e-05, 2.4148e-05, 2.78413e-05, 3.32391e-05, 3.80687e-05, 4.38926e-05, 5.21314e-05, 6.0228e-05, 7.28703e-05, 8.1251e-05, 8.97739e-05, 9.82967e-05, 0.000106393, 0.000116905, 0.000126422, 0.000139917}
		RQ_DSM_18keV[46]  = {0.000151849, 0.000164633, 0.00017557, 0.0001929, 0.000217332, 0.000235514, 0.000252276, 0.000276708, 0.000298867, 0.000323158, 0.000363215, 0.000392619, 0.000427278, 0.00046208, 0.000507251, 0.000547876}
		RQ_DSM_18keV[62]  = {0.000596599, 0.000645037, 0.000699157, 0.000755265, 0.000820323, 0.00088254, 0.000959529, 0.0010324, 0.00111791, 0.00120144, 0.00130414, 0.00141536, 0.0015226, 0.00164491, 0.00176707, 0.00190599, 0.00206011}
		RQ_DSM_18keV[79]  = {0.00222744, 0.00239691, 0.00258682, 0.00280075, 0.00301495, 0.00324621, 0.00349678, 0.00375275, 0.00404053, 0.00435986, 0.00470205, 0.00507009, 0.0054549, 0.00589027, 0.00634341, 0.00683148, 0.00736615}
		RQ_DSM_18keV[96]  = {0.00792127, 0.00853065, 0.00919586, 0.00992186, 0.0106889, 0.0115173, 0.0123953, 0.0133637, 0.0143816, 0.0154955, 0.0166754, 0.0179633, 0.0193656, 0.020843, 0.0224342, 0.0241621, 0.0260172, 0.0280184}
		RQ_DSM_18keV[114] = {0.0301357, 0.0324758, 0.0349675, 0.0376338, 0.0405539, 0.0436865, 0.0470368, 0.0506592, 0.0545446, 0.0587437, 0.0632451, 0.0681058, 0.0733305, 0.0789645, 0.0850073, 0.0914749, 0.0984384, 0.105932, 0.114002}
		RQ_DSM_18keV[133] = {0.122676, 0.132031, 0.142115, 0.152961, 0.16467, 0.177284, 0.190841, 0.205484, 0.221225, 0.238221, 0.256527, 0.276291, 0.297574, 0.320494, 0.345181, 0.371742, 0.400157}

		RE_DSM_18keV[0]   = {6.64309e-16, 7.51529e-16, 9.05559e-16, 1.15637e-15, 1.54741e-15, 2.05812e-15, 2.70018e-15, 3.83097e-15, 8.01771e-15, 2.46798e-14, 3.51372e-13, 7.90264e-13, 1.18055e-12, 1.44527e-12, 2.75805e-12, 2.98455e-12}
		RE_DSM_18keV[16]  = {3.23359e-12, 3.43302e-12, 3.59394e-12, 3.75629e-12, 3.9572e-12, 4.16105e-12, 4.33375e-12, 4.40644e-12, 4.41943e-12, 4.41568e-12, 4.40705e-12, 4.28206e-12, 4.18837e-12, 4.03608e-12, 3.86595e-12, 3.71169e-12}
		RE_DSM_18keV[32]  = {3.54295e-12, 3.31663e-12, 3.05504e-12, 2.76326e-12, 2.33859e-12, 1.91788e-12, 1.26783e-12, 2.02958e-13, 6.09763e-14, 2.30756e-14, 1.4787e-14, 3.42448e-15, 2.50116e-15, 1.76059e-15, 1.35513e-15, 1.0759e-15}
		RE_DSM_18keV[48]  = {8.9627e-16, 6.97682e-16, 5.15649e-16, 4.28461e-16, 3.68403e-16, 3.0275e-16, 2.5966e-16, 2.22957e-16, 1.82569e-16, 6.96552e-17, 5.58829e-17, 4.57716e-17, 3.60912e-17, 2.93709e-17, 2.37399e-17, 1.93793e-17}
		RE_DSM_18keV[64]  = {1.56282e-17, 1.26347e-17, 1.00267e-17, 8.32868e-18, 6.83495e-18, 5.83494e-18, 4.92937e-18, 4.25391e-18, 3.64076e-18, 3.11795e-18, 2.76599e-18, 2.424e-18, 2.14984e-18, 1.93699e-18, 1.75069e-18, 6.88349e-19}
		RE_DSM_18keV[80]  = {5.84037e-19, 4.9801e-19, 4.2613e-19, 3.74623e-19, 3.23941e-19, 2.86364e-19, 2.5621e-19, 2.30884e-19, 2.13298e-19, 1.95315e-19, 1.76587e-19, 1.6545e-19, 1.53536e-19, 1.47329e-19, 1.37179e-19, 1.30004e-19}
		RE_DSM_18keV[96]  = {1.22126e-19, 1.18272e-19, 1.13165e-19, 1.10968e-19, 1.07084e-19, 1.03634e-19, 1.01766e-19, 9.93407e-20, 9.82996e-20, 9.59502e-20, 9.37039e-20, 9.27446e-20, 9.28072e-20, 9.13206e-20, 9.06569e-20, 8.84767e-20}
		RE_DSM_18keV[112] = {8.90274e-20, 8.77917e-20, 8.6866e-20, 8.76932e-20, 8.63199e-20, 8.62784e-20, 8.63014e-20, 8.59013e-20, 8.44128e-20, 8.46217e-20, 8.39328e-20, 8.37449e-20, 8.27866e-20, 8.2006e-20, 8.13906e-20, 7.98176e-20}
		RE_DSM_18keV[128] = {7.86614e-20, 7.7533e-20, 7.75802e-20, 7.80158e-20, 7.73938e-20, 7.78826e-20, 7.74303e-20, 7.78418e-20, 7.78364e-20, 7.6704e-20, 7.75258e-20, 7.78674e-20, 7.7367e-20, 7.78337e-20, 7.82692e-20, 7.78765e-20}
		RE_DSM_18keV[144] = {7.79181e-20, 7.78303e-20, 7.87979e-20, 7.85418e-20, 7.79793e-20, 7.75587e-20}
	endif

	setDataFolder oldDf
End

////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************
