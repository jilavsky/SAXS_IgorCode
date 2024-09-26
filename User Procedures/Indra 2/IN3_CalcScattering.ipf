#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3			// Use modern global access method.
//#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.01



//*************************************************************************\
//* Copyright (c) 2005 - 2025, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//calculate scattering profile from model

//1.01 updated 18keV values. 
//date: 7/9/09 JIL version 1
// 1/12/2010 JIL, fixed intensity calcualtions to remove points in user data at low and high Q which do not exist (caused troubles for model) 




Function IN3M_CalculateDataFromModel()


	IN3M_InitCalcDataFromModel()
	
	DoWindow IN3MMainPanel
	if(V_Flag)
		DoWindow/F IN3MMainPanel
	else
		IN3M_MainPanel()
	endif


end

////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************


Function IN3M_MainPanel()
	KillWIndow/Z IN3MMainPanel
	NewPanel /K=1/W=(50,43.25,430.75,570) as "Calculate Scattering From Model"
	DoWindow/C IN3MMainPanel 
	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman",fsize= 18,fstyle= 3,textrgb= (0,0,52224)
	DrawText 57,22,"Calculate scattering from model"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,199,339,199
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 8,49,"Data input"
	
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("IN3_CalcDataFromModel","IN3MMainPanel","M_DSM_Int;DSM_Int;M_SMR_Int;SMR_Int","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,0)

	Button LoadData,pos={90,165},size={120,20},font="Times New Roman",proc=IN3M_ButtonProc,title="Load model data"

	PopupMenu SelectEnery pos={30,220},size={140,20},title="Select energy :",proc=In3M_PopMenuProc
	PopupMenu SelectEnery value=#"root:Packages:IN3_CalcDataFromModel:ListOfEnergies"
	
	SetVariable Transmission pos ={30,250}, size={180,20}, title="Transmission = ", help={"Estimate sample transmission"}
	Setvariable Transmission value=root:Packages:IN3_CalcDataFromModel:Transmission, proc=IN3M_SetVarProc, limits={0.0001,1,0.02}

	SetVariable SampleThickness pos ={30,280}, size={220,20}, title="Sample thickness [mm] = ", help={"Estimate sample thickness"}
	Setvariable SampleThickness value=root:Packages:IN3_CalcDataFromModel:SampleThickness, proc=IN3M_SetVarProc, limits={0.001,50,0.05}

	CheckBox USAXS,pos={43,319},size={133,14},proc=IN3M_CheckProc,title="Slit smeared (USAXS)?"
	CheckBox USAXS,variable= root:Packages:IN3_CalcDataFromModel:CalculateUSAXS,mode=1
	CheckBox SBUSAXS,pos={43,345},size={155,14},proc=IN3M_CheckProc,title="2d-collimated (SBUSAXS)?"
	CheckBox SBUSAXS,variable= root:Packages:IN3_CalcDataFromModel:CalculateSBUSAXS,mode=1
	
	CheckBox SmearModelData,pos={43,370},size={133,14},proc=IN3M_CheckProc,title="Smear the model Data?"
	CheckBox SmearModelData,variable= root:Packages:IN3_CalcDataFromModel:SmearModelData
	SetVariable SlitLength pos ={30,390}, size={220,20}, title="Slit length [1/A] = ", help={"Slit length of the instrument?"}
	Setvariable SlitLength value=root:Packages:IN3_CalcDataFromModel:SlitLength, proc=IN3M_SetVarProc, limits={0.001,10,0.002}
	

end
////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************

Function IN3M_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		//case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			IN3M_UpdateAll()
			
			
			break
	endswitch

	return 0
End
////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************


Function IN3M_UpdateAll()

	SVAR SelectedEnergy=root:Packages:IN3_CalcDataFromModel:SelectedEnergy

	IN3M_SelectRightBlank(SelectedEnergy)
	
	IN3M_CalculateScattering()
	
	IN3M_CreateAndUpdatePlot()
	

end

////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************


Function IN3M_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

				NVAR IsModelSlitSmeared=root:Packages:IN3_CalcDataFromModel:IsModelSlitSmeared
		//		NVAR UseSlitSmearedModel= root:Packages:IN3_CalcDataFromModel:UseSlitSmearedModel
				NVAR UseSMRData= root:Packages:IN3_CalcDataFromModel:UseSMRData
				NVAR SmearModelData= root:Packages:IN3_CalcDataFromModel:SmearModelData
				NVAR CalculateUSAXS=root:Packages:IN3_CalcDataFromModel:CalculateUSAXS
				NVAR CalculateSBUSAXS=root:Packages:IN3_CalcDataFromModel:CalculateSBUSAXS
	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(stringmatch(cba.ctrlName,"USAXS"))
				CalculateSBUSAXS=!CalculateUSAXS
				if((IsModelSlitSmeared || !UseSMRData)&&!CalculateUSAXS)
					SmearModelData = 0
				else

				endif
				IN3M_UpdateAll()
			endif
			if(stringmatch(cba.ctrlName,"SBUSAXS"))
				CalculateUSAXS=!CalculateSBUSAXS
				SmearModelData=0
		//		UseSlitSmearedModel = 0
				IN3M_UpdateAll()
			endif
			if(stringmatch(cba.ctrlName,"SmearModelData"))
				NVAR CalculateUSAXS=root:Packages:IN3_CalcDataFromModel:CalculateUSAXS
				NVAR CalculateSBUSAXS=root:Packages:IN3_CalcDataFromModel:CalculateSBUSAXS
				NVAR SmearModelData=root:Packages:IN3_CalcDataFromModel:SmearModelData
				IN3M_UpdateAll()
			endif
			
			break
	endswitch

	return 0
End

////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************

Function IN3M_CalculateScattering()
	string oldDf=GetDataFolder(1)
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
	wave/Z BlankR
	Wavestats/Q BlankR
	variable BlankMaximum=V_max
	NVAR PeakWidth	//note, it is in degrees...
	variable PDsize=5.5
	variable SDD = 400
	NVAR Transmission
	NVAR SampleThickness
	if(CalculateUSAXS)
		OmegaLocal = PDsize/SDD * PeakWidth*pi/180
		KfactorLocal=  BlankMaximum * OmegaLocal * sampleThickness * 0.1
	else
		OmegaLocal = PeakWidth*pi/180 * PeakWidth*pi/180
		KfactorLocal=BlankMaximum * OmegaLocal * sampleThickness * 0.1
	endif
	Wave/Z OriginalModelIntensity=root:Packages:IN3_CalcDataFromModel:OriginalModelIntensity
	if(!WaveExists(OriginalModelIntensity))
		abort
	endif
	Wave OriginalModelQ=root:Packages:IN3_CalcDataFromModel:OriginalModelQ
	Duplicate/O OriginalModelIntensity, tempInt, tempInt1
	Duplicate/O OriginalModelQ, tempQ
	//need to remove negative intensities if present, seems to be in some user data...
	IN2G_ReplaceNegValsByNaNWaves(tempInt,tempQ, tempInt1)

	Duplicate/O tempInt, tempModelInterpolated
	Duplicate/O BlankR, CalculatedScatteredIntensity, tempWv
	Wave BlankQ=root:Packages:IN3_CalcDataFromModel:BlankQ
	Duplicate/O BlankQ, CalculatedScatteredQ
//		Duplicate/O EWV, OriginalError
//	tempModelInterpolated = log(tempInt)

	tempWv = interp(CalculatedScatteredQ, tempQ, tempModelInterpolated)

	//now need to remove data at higher and lower Q values than the original data... 
	//original data were only in the areas of Q in tempQ
	variable Qmin=tempQ[0]
	variable Qmax=tempQ[numpnts(tempQ)-1]
	variable pointsStart=binarysearch(CalculatedScatteredQ,Qmin)
	variable pointsEnd=binarysearch(CalculatedScatteredQ,Qmax)+1
	tempWv[0,pointsStart]=0
	tempWv[pointsEnd,inf]=0
//	tempWv = 10^tempWv	
	variable FlatInstrBckg= sum(BlankR  , numpnts(BlankR)-7, numpnts(BlankR)-1 )/6

	NVAR SlitLength
	NVAR SmearModelData
	if(SmearModelData)
		Duplicate/O tempWv, tempWv1
		IN3M_SmearData(tempWv1, CalculatedScatteredQ, slitLength, tempWv) 
		//IR1B_SmearData(tempWv1, CalculatedScatteredQ, slitLength, tempWv) //this is faster, but part of Irena
	endif
	 CalculatedScatteredIntensity =  (tempWv * KfactorLocal)/Transmission+BlankR+FlatInstrBckg/Transmission 

//	KillWaves tempModelInterpolated, tempWv, tempWv1, tempInt,tempQ, tempInt1
	setDataFolder OldDf
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*****************************This function smears data***********************
Function IN3M_SmearData(Int_to_smear, Q_vec_sm, slitLength, Smeared_int)
	wave Int_to_smear, Q_vec_sm, Smeared_int
	variable slitLength
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:
	NewDataFolder/O/S Irena_desmearing
//	setDataFolder root:Packages:Irena_desmearing:

	Make/D/O/N=(2*numpnts(Q_vec_sm)) Smear_Q, Smear_Int							
		//Q's in L spacing and intensitites in the l's will go to Smear_Int (intensity distribution in the slit, changes for each point)

	variable DataLengths=numpnts(Q_vec_sm)
	
	
	Smear_Q=1.1*slitLength*(Q_vec_sm[2*p]-Q_vec_sm[0])/(Q_vec_sm[DataLengths-1]-Q_vec_sm[0])		//create distribution of points in the l's which mimics the original distribution of points
	//the 1.1* added later, because without it I did not  cover the whole slit length range... 
	variable i=0
	DataLengths=numpnts(Smeared_int)
	
	For(i=0;i<DataLengths;i+=1) 
		Smear_Int=interp(sqrt((Q_vec_sm[i])^2+(Smear_Q[p])^2), Q_vec_sm, Int_to_smear)		//put the distribution of intensities in the slit for each point 
		Smeared_int[i]=areaXY(Smear_Q, Smear_Int, 0, slitLength) 							//integrate the intensity over the slit 
	endfor

	Smeared_int*= 1 / slitLength															//normalize
	
	KillWaves/Z Smear_Int, Smear_Q														//cleanup temp waves
	setDataFolder OldDf
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*****************************This function smears data***********************
////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************


Function IN3M_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			
			//here goes my code...
			IN3M_SelectRightBlank(popStr)
			IN3M_CalculateScattering()
			break
	endswitch

	return 0
End
////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************

Function IN3M_SelectRightBlank(EnergyString)
	string EnergyString

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IN3_CalcDataFromModel
	
	
	SVAR ListOfPeakWidths
//	SVAR ListOfKfactors
	NVAR PeakWidth
	NVAR MaximumBlankIntensity
	NVAR MaximumIntensity
	NVAR Transmission
	NVAR Kfactor
	
	PeakWidth = NumberByKey(EnergyString, ListOfPeakWidths,"=")
//	Kfactor = NumberByKey(EnergyString, ListOfKfactors,"=")
	
	SVAR SelectedEnergy
	SelectedEnergy=EnergyString
	NVAR CalculateUSAXS
	string tmpstr
	if(CalculateUSAXS)
		tmpstr="SMR"
	else
		tmpstr="DSM"
	endif
		
//	Make/O/N=200 RQ_SMR_18keV, RInt_SMR_18keV, RE_SMR_18keV
	Wave/Z BL_Int=$("RInt_"+tmpstr+"_"+EnergyString)
	Wave/Z BL_Q=$("RQ_"+tmpstr+"_"+EnergyString)
	Wave/Z BL_Err=$("RE_"+tmpstr+"_"+EnergyString)
	
	if(WaveExists(BL_Int))
		Duplicate/O BL_Int, BlankR
		Duplicate/O BL_Q, BlankQ
		Duplicate/O BL_Err, BlankE		
	else
		Abort "This combination of energy and geometry does not yet exist"
	endif
	
	IN3M_CreateAndUpdatePlot()
	
	setDataFolder OldDf
	
end
////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************


Function IN3M_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			IN3M_LoadDataInTheTool()
			break
	endswitch

	return 0
End
////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************

Function IN3M_LoadDataInTheTool()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IN3_CalcDataFromModel
	
	SVAR DataFolderName=root:Packages:IN3_CalcDataFromModel:DataFolderName
	SVAR ErrorWaveName=root:Packages:IN3_CalcDataFromModel:ErrorWaveName
	SVAR IntensityWaveName=root:Packages:IN3_CalcDataFromModel:IntensityWaveName
	SVAR QWavename=root:Packages:IN3_CalcDataFromModel:QWavename
	
	Wave/Z IntWv=$(DataFolderName+IntensityWaveName)
	Wave/Z QWV=$(DataFolderName+QWavename)
	Wave/Z EWV=$(DataFolderName+ErrorWaveName)
	
	If(!WaveExists(IntWv)||!WaveExists(QWv))
		Abort "Data not selected properly"
	endif
	Duplicate/O IntWv, OriginalModelIntensity
	Wave OriginalModelIntensity
	Duplicate/O QWv, OriginalModelQ
	if(WaveExists(EWV))
		Duplicate/O EWV, OriginalError
	endif
	//now check for use of slit smeared data by the model...
	//UseSlitSmearedData should be 1 if the model is slit smeared already. 
	
	NVAR IsModelSlitSmeared=root:Packages:IN3_CalcDataFromModel:IsModelSlitSmeared
	IsModelSlitSmeared=NumberByKey("UseSlitSmearedData", note(OriginalModelIntensity)  , "=", ";")
	NVAR CalculateSBUSAXS = root:Packages:IN3_CalcDataFromModel:CalculateSBUSAXS
	NVAR CalculateUSAXS = root:Packages:IN3_CalcDataFromModel:CalculateUSAXS
	NVAR SmearModelData = root:Packages:IN3_CalcDataFromModel:SmearModelData
	if(IsModelSlitSmeared || CalculateSBUSAXS)
		SmearModelData = 0
	elseif(IsModelSlitSmeared==0 && CalculateUSAXS)
		SmearModelData = 1
	endif
	
	
	IN3M_CreateAndUpdatePlot()
	
	setDataFolder OldDf
end
////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************


Function IN3M_CreateAndUpdatePlot()

	DoWIndow IN3MMainPlot
	if(V_Flag)
		DoWIndow/F IN3MMainPlot
	else
		Display/K=1  /W=(390,46,994,571)
		DoWindow/C IN3MMainPlot
	endif
	Wave/Z OriginalModelIntensity=root:Packages:IN3_CalcDataFromModel:OriginalModelIntensity
	Wave/Z OriginalModelQ=root:Packages:IN3_CalcDataFromModel:OriginalModelQ
	Wave/Z OriginalError=root:Packages:IN3_CalcDataFromModel:OriginalError
	
	if(!WaveExists(OriginalModelIntensity))
		return 1
	endif
	
	CheckDisplayed /A/W=IN3MMainPlot  OriginalModelIntensity
	if(!V_Flag)
		AppendToGraph/R OriginalModelIntensity vs OriginalModelQ
		//and format 
		ModifyGraph log=1
		ModifyGraph tick=2
		ModifyGraph/Z mirror=1
		ModifyGraph lstyle(OriginalModelIntensity)=5
		ModifyGraph rgb(OriginalModelIntensity)=(0,0,65535)
		Label right "Model Intensity [cm\\S-1\\M]"
		Label bottom "Q [A\\S-1\\M]"
		wavestats/Q OriginalModelIntensity
		variable MinVal=V_min
		variable MaxVal=V_max
		if(Maxval/Minval<1e7)
			Maxval = 1e7* MinVal
		endif
		SetAxis right MinVal,Maxval
		SetAxis bottom 1e-6,1
	endif



	//append Blank if it exists
	Wave/Z BlankR
	Wave/Z BlankQ
	Wave/Z BlankE
	if(WaveExists(BlankR))
		CheckDisplayed /W=IN3MMainPlot  BlankR 	
		if(!V_Flag)
			AppendToGraph/W=IN3MMainPlot   BlankR vs BlankQ
			ModifyGraph/W=IN3MMainPlot   mode(BlankR)=0,rgb(BlankR)=(0,0,0)
			modifygraph/W=IN3MMainPlot   log(left)=1
			ErrorBars BlankR Y,wave=(BlankE,BlankE)
		endif
	endif

	Wave/Z CalculatedScatteredIntensity
	Wave/Z CalculatedScatteredQ
	if(WaveExists(CalculatedScatteredQ) && WaveExists(CalculatedScatteredIntensity))
		//apend to graph
		CheckDisplayed /W=IN3MMainPlot  CalculatedScatteredIntensity 	
		if(!V_Flag)
			AppendToGraph/W=IN3MMainPlot   CalculatedScatteredIntensity vs CalculatedScatteredQ
			ModifyGraph/W=IN3MMainPlot   mode(CalculatedScatteredIntensity)=0
			ModifyGraph/W=IN3MMainPlot   rgb(CalculatedScatteredIntensity)=(65535,0,0)
		endif
	endif
	
	Legend/C/N=text0/A=RT

	//align the windows
	AutoPositionWindow/M=0 /R=IN3MMainPanel IN3MMainPlot
	//showtools
	DoWindow/F IN3MMainPanel
end

////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************


Function IN3M_InitCalcDataFromModel()

	string oldDf=GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:IN3_CalcDataFromModel
	
	string ListOfVariables
	string ListOfStrings
	variable i

	ListOfVariables="CalculateUSAXS;CalculateSBUSAXS;"
	ListOfVariables+="Transmission;PeakWidth;MaximumBlankIntensity;MaximumIntensity;SampleThickness;"
	ListOfVariables+="Kfactor;SmearModelData;SlitLength;IsModelSlitSmeared;"
	
	ListOfStrings="ListOfEnergies;SelectedEnergy;ListOfPeakWidths;"

	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	
	NVAR CalculateUSAXS
	NVAR CalculateSBUSAXS
	if(CalculateUSAXS+CalculateSBUSAXS!=1)
		CalculateUSAXS=1
		CalculateSBUSAXS=0
	endif
	
	NVAR SlitLength
	if (SlitLength<=0)
		SlitLength=0.04
	endif
	
	SVAR ListOfEnergies
	ListOfEnergies="12keV;18keV;"
	
	SVAR ListOfPeakWidths
	ListOfPeakWidths="18keV=0.000603181;12keV=0.000875727;"

	NVAR Transmission
	if(Transmission<=0 || Transmission>1)
		Transmission=1
	endif

	NVAR SampleThickness
	if(SampleThickness<=0)
		SampleThickness=1
	endif


	//Create some instrument Curves
	Wave/Z RQ_SMR_18keV
	if(!WaveExists(RQ_SMR_18keV))
	
			Make/O/N=300 RQ_SMR_18keV, RInt_SMR_18keV, RE_SMR_18keV
			
			  RQ_SMR_18keV[0]= {-9.67937e-05,-9.03788e-05,-8.4249e-05,-7.82618e-05,-7.24171e-05,-6.68575e-05,-6.1298e-05,-5.63086e-05,-5.11767e-05,-4.63298e-05,-4.16256e-05,-3.72064e-05,-3.27873e-05,-2.85107e-05,-2.43766e-05}
			  RQ_SMR_18keV[15]= {-2.05277e-05,-1.66787e-05,-1.31149e-05,-9.55108e-06,-6.1298e-06,-2.70851e-06,4.2766e-07,3.56383e-06,6.55746e-06,9.69363e-06,1.28298e-05,1.62511e-05,1.96724e-05,2.30936e-05,2.68e-05,3.05064e-05}
			  RQ_SMR_18keV[31]= {3.46405e-05,3.8632e-05,4.2766e-05,4.71852e-05,5.16043e-05,5.63086e-05,6.10128e-05,6.61448e-05,7.12767e-05,7.65512e-05,8.21107e-05,8.78129e-05,9.36576e-05,9.97874e-05,0.00010606,0.000112617}
			  RQ_SMR_18keV[47]= {0.000119317,0.000126445,0.000133573,0.000140985,0.000148683,0.000156666,0.000164934,0.000173487,0.000182326,0.000191449,0.000200858,0.000210694,0.000220673,0.000231222,0.000242056,0.000253317}
			  RQ_SMR_18keV[63]= {0.000264864,0.000276696,0.000289098,0.000301928,0.000315186,0.000328871,0.000342983,0.000357666,0.00037292,0.000388601,0.000404709,0.000421388,0.000438779,0.000456741,0.000475273,0.000494518}
			  RQ_SMR_18keV[79]= {0.000514333,0.00053486,0.000556101,0.000578054,0.000600863,0.000624241,0.000648475,0.000673707,0.000699795,0.000726595,0.000754393,0.000783188,0.000812982,0.000843773,0.000875563,0.000908493}
			  RQ_SMR_18keV[95]= {0.000942563,0.000977631,0.00101412,0.00105176,0.00109082,0.00113116,0.00117279,0.00121598,0.00126046,0.00130664,0.0013544,0.00140372,0.00145476,0.0015075,0.0015621,0.00161855,0.001677}
			  RQ_SMR_18keV[112]= {0.00173744,0.00179988,0.0018646,0.00193146,0.00200074,0.00207216,0.00214614,0.00222269,0.00230195,0.00238364,0.00246845,0.00255598,0.00264665,0.00274016,0.0028371,0.00293731,0.00304109}
			  RQ_SMR_18keV[129]= {0.00314829,0.0032592,0.00337381,0.00349242,0.00361515,0.00374217,0.00387346,0.00400917,0.00414973,0.00429485,0.00444524,0.00460063,0.00476143,0.00492764,0.00509956,0.00527733,0.00546136}
			  RQ_SMR_18keV[146]= {0.00565167,0.00584839,0.00605196,0.00626266,0.00648019,0.00670557,0.0069385,0.00717956,0.00742874,0.00768648,0.00795305,0.00822889,0.00851414,0.00880909,0.00911429,0.00942991,0.00975635}
			  RQ_SMR_18keV[163]= {0.0100941,0.0104432,0.0108045,0.011178,0.0115646,0.0119641,0.0123776,0.0128053,0.0132473,0.0137049,0.0141781,0.0146675,0.0151735,0.0156971,0.0162387,0.0167988,0.017378,0.0179773,0.0185969}
			  RQ_SMR_18keV[182]= {0.0192379,0.0199009,0.0205867,0.0212959,0.0220295,0.0227883,0.023573,0.0243849,0.0252245,0.0260928,0.026991,0.0279201,0.028881,0.0298748,0.0309028,0.0319662,0.0330658,0.0342032,0.0353797}
			  RQ_SMR_18keV[201]= {0.0365966,0.0378552,0.039157,0.0405035,0.0418963,0.0433366,0.0448266,0.0463676,0.0479615,0.0496099,0.051315,0.0530788,0.0549029,0.0567896,0.0587413,0.0607597,0.0628474,0.0650068,0.0672403}
			  RQ_SMR_18keV[220]= {0.0695502,0.0719396,0.0744109,0.0769672,0.0796109,0.0823454,0.0851739,0.0880993,0.0911251,0.0942548,0.0974917,0.10084,0.104303,0.107885,0.111589,0.115421,0.119384,0.123484,0.127723,0.132109}
			  RQ_SMR_18keV[240]= {0.136645,0.141336,0.146189,0.151207,0.156399,0.161768,0.167321,0.173065,0.179006,0.185151,0.191507,0.198081,0.20488,0.211913,0.219187,0.22671,0.234491,0.24254,0.250864,0.259475,0.26838}
			  RQ_SMR_18keV[261]= {0.277591,0.287118,0.296972,0.307164,0.317705,0.328608,0.339885,0.351549,0.363613,0.37609,0.388996,0.402344,0.41615,0.430429,0.445198,0.460473,0.476273,0.492613,0.509514,0.526995,0.545075}
			  RQ_SMR_18keV[282]= {0.563774,0.583114,0.603118,0.623806,0.645204,0.667335,0.690224,0.713897,0.738381,0.763703,0.789893,0.816979,0.844992,0.873965,0.903929,0.934918,0.966967,1.00011}

		
			  RInt_SMR_18keV[0]= {6.73287e-05,0.000210474,0.000545728,0.000992962,0.00144017,0.00188299,0.00230968,0.00270555,0.00312421,0.00348848,0.00386505,0.00423317,0.00459063,0.00492782,0.00525929,0.00560638,0.00592919}
			  RInt_SMR_18keV[17]= {0.00620919,0.00655243,0.00680426,0.00695232,0.00697897,0.00699835,0.00690104,0.00663725,0.00638788,0.00606951,0.00574685,0.00544305,0.00508751,0.00477995,0.00443449,0.00409408,0.00368549}
			  RInt_SMR_18keV[34]= {0.00331814,0.00292806,0.00251085,0.00207585,0.00159839,0.00113652,0.000665228,0.000280643,9.21703e-05,2.91761e-05,9.23946e-06,4.921e-06,3.02154e-06,2.06839e-06,1.48777e-06,1.12535e-06}
			  RInt_SMR_18keV[50]= {8.8936e-07,7.10202e-07,5.72894e-07,4.72349e-07,3.96799e-07,3.39413e-07,2.92023e-07,2.55738e-07,2.25724e-07,2.00223e-07,1.79062e-07,1.62998e-07,1.47359e-07,1.33979e-07,1.22007e-07,1.11595e-07}
			  RInt_SMR_18keV[66]= {1.02015e-07,9.40396e-08,8.67371e-08,8.05384e-08,7.5327e-08,6.95672e-08,6.66285e-08,6.28551e-08,5.98675e-08,5.7021e-08,5.43979e-08,5.19944e-08,4.8995e-08,4.72054e-08,4.54299e-08,4.3592e-08}
			  RInt_SMR_18keV[82]= {4.19599e-08,4.00459e-08,3.82328e-08,3.66629e-08,3.52088e-08,3.36363e-08,3.25394e-08,3.13104e-08,3.01347e-08,2.90497e-08,2.80323e-08,2.70827e-08,2.59193e-08,2.48699e-08,2.38232e-08,2.28907e-08}
			  RInt_SMR_18keV[98]= {2.21867e-08,2.12763e-08,2.0573e-08,1.97359e-08,1.89172e-08,1.79847e-08,1.72731e-08,1.66504e-08,1.59143e-08,1.52763e-08,1.45529e-08,1.38647e-08,1.32257e-08,1.26819e-08,1.20315e-08,1.15766e-08}
			  RInt_SMR_18keV[114]= {1.09963e-08,1.05017e-08,1.00328e-08,9.58927e-09,9.1048e-09,8.67501e-09,8.20049e-09,7.86043e-09,7.42455e-09,7.04901e-09,6.69369e-09,6.29929e-09,5.98097e-09,5.66007e-09,5.29083e-09,5.00722e-09}
			  RInt_SMR_18keV[130]= {4.67829e-09,4.36572e-09,4.06458e-09,3.80157e-09,3.52978e-09,3.30314e-09,3.05045e-09,2.83808e-09,2.64023e-09,2.45708e-09,2.27071e-09,2.11473e-09,1.95956e-09,1.81046e-09,1.67661e-09,1.54391e-09}
			  RInt_SMR_18keV[146]= {1.42475e-09,1.32394e-09,1.21523e-09,1.12877e-09,1.03948e-09,9.61328e-10,8.74549e-10,8.12405e-10,7.47164e-10,6.88385e-10,6.30459e-10,5.85002e-10,5.37127e-10,4.94067e-10,4.55957e-10,4.20395e-10}
			  RInt_SMR_18keV[162]= {3.89488e-10,3.59297e-10,3.31639e-10,3.04732e-10,2.83327e-10,2.60275e-10,2.36299e-10,2.21047e-10,2.01947e-10,1.88069e-10,1.70019e-10,1.59379e-10,1.4665e-10,1.34496e-10,1.24102e-10,1.13288e-10}
			  RInt_SMR_18keV[178]= {1.05958e-10,9.76703e-11,8.92561e-11,8.20009e-11,7.49187e-11,7.1529e-11,6.59301e-11,6.29479e-11,5.59166e-11,5.25598e-11,4.98246e-11,4.60261e-11,4.15271e-11,3.91856e-11,3.60885e-11,3.31531e-11}
			  RInt_SMR_18keV[194]= {3.15702e-11,2.95613e-11,2.74387e-11,2.58877e-11,2.44736e-11,2.24072e-11,2.16962e-11,2.04725e-11,1.94113e-11,1.8427e-11,1.72615e-11,1.68989e-11,1.60489e-11,1.51291e-11,1.53834e-11,1.4246e-11}
			  RInt_SMR_18keV[210]= {1.37006e-11,1.35416e-11,1.32599e-11,1.27419e-11,1.25577e-11,1.22054e-11,1.20377e-11,1.21499e-11,1.09567e-11,1.12768e-11,1.09412e-11,1.06494e-11,1.04531e-11,1.05684e-11,1.03432e-11,1.01196e-11}
			  RInt_SMR_18keV[226]= {1.00828e-11,9.86383e-12,9.639e-12,9.51846e-12,9.48422e-12,9.32738e-12,9.0916e-12,9.00026e-12,8.84942e-12,8.78761e-12,8.83951e-12,8.71341e-12,8.40008e-12,7.91883e-12,8.04154e-12,7.92022e-12}
			  RInt_SMR_18keV[242]= {7.83159e-12,8.02112e-12,7.38781e-12,7.56768e-12,7.36783e-12,7.11605e-12,7.13962e-12,6.92713e-12,6.86319e-12,7.21754e-12,7.11969e-12,6.86988e-12,6.91775e-12,6.79254e-12,6.76759e-12,6.8474e-12}
			  RInt_SMR_18keV[258]= {6.91961e-12,6.69247e-12,6.73289e-12,6.78357e-12,6.14276e-12,5.18828e-12,4.98126e-12,4.52701e-12,4.45059e-12,4.31307e-12,4.45316e-12,4.53707e-12,4.40085e-12,4.46671e-12,4.13974e-12,4.35926e-12}
			  RInt_SMR_18keV[274]= {4.14368e-12,4.15432e-12,4.10731e-12,3.87333e-12,3.99238e-12,3.99832e-12,4.14231e-12,3.70786e-12,3.77103e-12,3.78895e-12,3.8812e-12,3.59851e-12,3.74183e-12,3.73386e-12,3.53658e-12,3.37147e-12}
			  RInt_SMR_18keV[290]= {3.20953e-12,3.40388e-12,3.10944e-12,3.3734e-12,3.10604e-12,2.8919e-12,3.13278e-12,2.7037e-12,2.84148e-12,3.14517e-12}

			  RE_SMR_18keV[0]= {1.68561e-06,3.1728e-06,6.95899e-06,1.19336e-05,1.68877e-05,2.17888e-05,2.65028e-05,3.0878e-05,3.55057e-05,3.95283e-05,4.36818e-05,4.77518e-05,5.17004e-05,5.54288e-05,5.9102e-05,6.29395e-05}
			  RE_SMR_18keV[16]= {6.64906e-05,6.95902e-05,7.33789e-05,7.6166e-05,7.77945e-05,7.80845e-05,7.83058e-05,7.72292e-05,7.43131e-05,7.1562e-05,6.80455e-05,6.44809e-05,6.11132e-05,5.71898e-05,5.37924e-05,4.99732e-05}
			  RE_SMR_18keV[32]= {4.62171e-05,4.17044e-05,3.76446e-05,3.33377e-05,2.87227e-05,2.39093e-05,1.86256e-05,1.35134e-05,8.28627e-06,3.97413e-06,1.75242e-06,8.65167e-07,1.116e-07,6.35808e-08,4.2232e-08,3.13015e-08}
			  RE_SMR_18keV[48]= {2.44678e-08,2.00867e-08,1.71185e-08,1.47805e-08,1.29147e-08,1.14774e-08,1.0345e-08,9.43871e-09,3.32518e-09,2.92412e-09,2.59213e-09,2.31046e-09,2.07645e-09,1.89886e-09,1.72611e-09,1.5779e-09}
			  RE_SMR_18keV[64]= {1.44518e-09,1.32985e-09,1.22382e-09,1.1342e-09,1.05332e-09,9.84273e-10,9.26712e-10,8.62546e-10,8.29862e-10,7.87974e-10,7.54466e-10,7.22172e-10,6.92803e-10,6.66037e-10,6.32416e-10,6.12194e-10}
			  RE_SMR_18keV[80]= {5.92317e-10,5.71774e-10,5.53384e-10,5.31899e-10,5.11392e-10,4.93716e-10,4.77515e-10,4.59784e-10,4.47291e-10,4.33532e-10,4.20217e-10,4.07982e-10,3.96344e-10,3.85608e-10,3.72236e-10,3.6026e-10}
			  RE_SMR_18keV[96]= {3.48247e-10,3.37554e-10,3.29651e-10,3.1909e-10,3.10864e-10,3.01202e-10,2.45813e-10,2.35692e-10,2.28052e-10,2.21355e-10,2.13446e-10,2.06542e-10,1.98665e-10,1.91209e-10,1.8424e-10,1.7829e-10}
			  RE_SMR_18keV[112]= {1.71111e-10,1.66106e-10,1.59735e-10,1.54279e-10,1.4903e-10,1.44082e-10,1.38633e-10,1.33775e-10,1.28375e-10,1.24487e-10,1.1944e-10,1.15204e-10,1.11151e-10,1.06486e-10,1.02741e-10,9.89551e-11}
			  RE_SMR_18keV[128]= {9.45781e-11,9.11601e-11,8.71096e-11,8.33005e-11,7.95283e-11,7.61438e-11,3.77313e-11,3.53456e-11,3.26841e-11,3.04465e-11,2.83617e-11,2.64322e-11,2.4467e-11,2.28245e-11,2.11855e-11,1.96151e-11}
			  RE_SMR_18keV[144]= {1.82022e-11,1.6805e-11,1.55481e-11,1.44844e-11,1.33379e-11,1.24268e-11,1.14851e-11,1.06596e-11,9.73923e-12,9.08411e-12,8.39501e-12,7.77469e-12,7.16389e-12,6.6833e-12,6.17656e-12,5.72117e-12}
			  RE_SMR_18keV[160]= {5.31843e-12,4.94099e-12,4.61538e-12,4.29599e-12,4.00153e-12,3.71611e-12,3.48819e-12,3.24293e-12,2.98714e-12,2.82402e-12,2.62024e-12,2.4705e-12,2.2766e-12,2.16127e-12,2.02385e-12,1.89129e-12}
			  RE_SMR_18keV[176]= {1.77833e-12,1.65965e-12,1.57907e-12,1.48755e-12,1.39367e-12,1.31277e-12,1.23248e-12,1.19408e-12,1.13011e-12,1.09531e-12,1.01334e-12,9.73867e-13,9.41608e-13,8.96337e-13,8.4227e-13,8.13756e-13}
			  RE_SMR_18keV[192]= {7.75568e-13,3.89483e-13,3.7347e-13,3.53144e-13,3.31891e-13,3.16366e-13,3.02292e-13,2.81876e-13,2.74861e-13,2.6291e-13,2.45337e-13,2.36304e-13,2.25599e-13,2.22332e-13,2.14592e-13,2.0619e-13}
			  RE_SMR_18keV[208]= {2.08433e-13,1.9839e-13,1.93563e-13,1.92177e-13,1.89691e-13,1.85302e-13,1.83783e-13,1.80959e-13,1.78889e-13,1.79942e-13,1.69729e-13,1.72353e-13,1.69649e-13,1.67256e-13,1.65696e-13,1.66575e-13}
			  RE_SMR_18keV[224]= {1.64773e-13,1.6316e-13,1.62849e-13,1.61137e-13,1.59255e-13,1.58365e-13,1.58155e-13,1.56863e-13,1.55006e-13,1.54333e-13,1.53198e-13,1.52783e-13,1.53291e-13,1.52365e-13,1.49961e-13,1.4621e-13}
			  RE_SMR_18keV[240]= {1.471e-13,1.46231e-13,1.45478e-13,1.4693e-13,1.42477e-13,1.43774e-13,1.42423e-13,1.40552e-13,1.40757e-13,1.3923e-13,1.38937e-13,1.41313e-13,1.40571e-13,1.38855e-13,1.39281e-13,1.38574e-13}
			  RE_SMR_18keV[256]= {1.38417e-13,1.38961e-13,1.39881e-13,1.37693e-13,1.38181e-13,1.3848e-13,1.34197e-13,1.28079e-13,1.26828e-13,1.24368e-13,1.24004e-13,1.23142e-13,1.2415e-13,1.24639e-13,1.23729e-13,1.24039e-13}
			  RE_SMR_18keV[272]= {1.22211e-13,1.23518e-13,1.222e-13,1.22239e-13,1.21973e-13,1.20679e-13,1.21429e-13,1.214e-13,1.22102e-13,1.19692e-13,1.19858e-13,1.19867e-13,1.20285e-13,1.18786e-13,1.19525e-13,1.19599e-13}
			  RE_SMR_18keV[288]= {1.18516e-13,1.17834e-13,1.17144e-13,1.18198e-13,1.16594e-13,1.18004e-13,1.1675e-13,1.15671e-13,1.16879e-13,1.15259e-13,1.15064e-13,1.16467e-13}
			
	
	endif

	Wave/Z RQ_SMR_12keV
	if(!WaveExists(RQ_SMR_12keV))
	
			Make/O/N=150 RQ_SMR_12keV, RInt_SMR_12keV, RE_SMR_12keV
			
			  RInt_SMR_12keV[0]= {1.53408e-13,2.16551e-13,3.56204e-13,1.11266e-12,1.64874e-11,1.26613e-10,3.07014e-10,5.30095e-10,7.69051e-10,1.02043e-09,1.18058e-09,1.37454e-09,1.53497e-09,1.67721e-09,1.85942e-09,1.93781e-09}
			  RInt_SMR_12keV[16]= {2.07482e-09,2.11756e-09,2.11551e-09,2.07721e-09,2.02494e-09,1.96736e-09,1.96981e-09,1.847e-09,1.84752e-09,1.84975e-09,1.71589e-09,1.71898e-09,1.58822e-09,1.52132e-09,1.3778e-09,1.31617e-09}
			  RInt_SMR_12keV[32]= {1.16922e-09,1.0931e-09,9.39375e-10,7.90094e-10,6.37506e-10,4.90378e-10,2.85231e-10,1.02834e-10,1.37082e-11,1.40128e-12,4.7799e-13,2.30053e-13,1.61585e-13,1.20508e-13,9.7536e-14,8.15307e-14}
			  RInt_SMR_12keV[48]= {6.75206e-14,5.7634e-14,4.96321e-14,4.25644e-14,3.70982e-14,3.32192e-14,2.93119e-14,2.59676e-14,2.26156e-14,2.01471e-14,1.80634e-14,1.6293e-14,1.46079e-14,1.30941e-14,1.17333e-14,1.06521e-14}
			  RInt_SMR_12keV[64]= {9.63268e-15,8.68982e-15,7.78349e-15,6.94205e-15,6.24697e-15,5.56335e-15,4.89564e-15,4.34804e-15,3.84382e-15,3.38235e-15,2.95652e-15,2.55428e-15,2.16494e-15,1.81479e-15,1.51431e-15,1.24335e-15}
			  RInt_SMR_12keV[80]= {1.00034e-15,7.89053e-16,6.27906e-16,5.02987e-16,4.05491e-16,3.29945e-16,2.72522e-16,2.23119e-16,1.85535e-16,1.54033e-16,1.27349e-16,1.05656e-16,8.75965e-17,7.14237e-17,5.85428e-17,4.87905e-17}
			  RInt_SMR_12keV[96]= {3.97993e-17,3.2576e-17,2.6852e-17,2.17903e-17,1.7717e-17,1.46216e-17,1.204e-17,1.03605e-17,8.7048e-18,7.9201e-18,7.35002e-18,6.75393e-18,6.29101e-18,5.76304e-18,5.35028e-18,4.92401e-18}
			  RInt_SMR_12keV[112]= {4.69533e-18,4.36766e-18,4.19763e-18,3.93171e-18,3.67733e-18,3.53314e-18,3.38781e-18,3.26743e-18,3.10352e-18,3.09166e-18,2.8963e-18,2.84476e-18,2.86653e-18,2.75255e-18,2.59033e-18,2.61557e-18}
			  RInt_SMR_12keV[128]= {2.4202e-18,2.42341e-18,2.46176e-18,2.30598e-18,2.41887e-18,2.15964e-18,2.19801e-18,2.15289e-18,1.75209e-18,1.68873e-18,1.59677e-18,1.44512e-18,1.39539e-18,1.44063e-18,1.35715e-18,1.342e-18}
			RInt_SMR_12keV[144]= {1.48464e-18,1.55446e-18,1.45338e-18,1.04114e-18,1.04193e-18,1.01003e-18}
					
			  RQ_SMR_12keV[0]= {-0.000147555,-0.000133101,-0.000118145,-0.000103991,-9.26487e-05,-8.06034e-05,-7.16698e-05,-6.29369e-05,-5.44048e-05,-4.47685e-05,-3.99504e-05,-3.41285e-05,-2.78047e-05,-2.23843e-05,-1.68635e-05}
			  RQ_SMR_12keV[15]= {-1.24469e-05,-7.62871e-06,-5.01889e-06,-1.8068e-06,1.20453e-06,3.01133e-06,7.2272e-06,7.2272e-06,1.3551e-05,1.3551e-05,1.3551e-05,1.94733e-05,1.94733e-05,2.49941e-05,2.77043e-05,3.31247e-05}
			  RQ_SMR_12keV[31]= {3.6939e-05,4.22591e-05,4.47685e-05,5.11927e-05,5.6312e-05,6.27361e-05,6.87588e-05,7.77928e-05,8.60238e-05,9.44555e-05,0.000103791,0.000112724,0.000124067,0.00013551,0.00015147,0.000164921}
			  RQ_SMR_12keV[47]= {0.000179576,0.000197644,0.000214106,0.000234382,0.000258674,0.00028156,0.000304747,0.000334559,0.00036397,0.0003985,0.000434234,0.000475189,0.000516946,0.00056332,0.000611803,0.000668817}
			  RQ_SMR_12keV[63]= {0.000726334,0.000792684,0.000863751,0.000939637,0.00102205,0.0011149,0.00121246,0.00131947,0.00143721,0.00156288,0.0017005,0.00185117,0.00201328,0.00219175,0.00238407,0.00259437,0.00282313}
			  RQ_SMR_12keV[80]= {0.00306755,0.00334017,0.00363328,0.00395218,0.00429918,0.0046767,0.00508584,0.00553082,0.00601574,0.00654152,0.00711518,0.00774114,0.00841688,0.00915245,0.00995658,0.010829,0.0117758}
			  RQ_SMR_12keV[97]= {0.012804,0.013927,0.0151435,0.0164715,0.017913,0.0194801,0.0211826,0.0230345,0.0250504,0.0272423,0.0296261,0.032215,0.035034,0.0380986,0.0414285,0.0450502,0.0489916,0.0532741,0.0579313}
			  RQ_SMR_12keV[116]= {0.0629988,0.0685071,0.0744978,0.0810117,0.088096,0.0957966,0.104172,0.113283,0.123184,0.133955,0.145667,0.158402,0.17225,0.187308,0.203682,0.221487,0.240847,0.261902,0.284795,0.309689}
			RQ_SMR_12keV[136]= {0.336755,0.366187,0.398189,0.432987,0.470822,0.51196,0.556687,0.605317,0.658184,0.715658,0.77814,0.846061,0.919887,1.00013}
						
						
			  RE_SMR_12keV[0]= {1.67935e-15,2.31169e-15,3.72632e-15,1.13846e-14,1.78784e-13,1.2938e-12,4.1602e-12,6.47867e-12,8.92805e-12,1.1494e-11,1.31205e-11,1.50901e-11,1.67197e-11,1.8163e-11,2.00099e-11,2.08086e-11}
			  RE_SMR_12keV[16]= {2.21938e-11,2.26274e-11,2.26068e-11,2.22186e-11,2.16897e-11,2.11056e-11,2.11304e-11,1.98852e-11,1.98905e-11,1.99121e-11,1.85551e-11,1.85876e-11,1.72598e-11,1.6582e-11,1.51256e-11,1.44983e-11}
			  RE_SMR_12keV[32]= {1.30058e-11,1.22314e-11,1.06677e-11,9.14435e-12,7.58288e-12,6.07083e-12,3.93037e-12,1.9145e-12,6.21094e-13,2.39187e-14,1.28613e-14,2.44869e-15,1.7544e-15,1.33751e-15,1.10385e-15,9.40825e-16}
			  RE_SMR_12keV[48]= {7.9767e-16,6.96484e-16,6.14191e-16,5.41184e-16,4.84526e-16,4.44448e-16,4.03157e-16,3.67698e-16,3.32007e-16,3.05435e-16,2.82832e-16,2.63444e-16,2.4467e-16,2.27592e-16,2.12043e-16,1.99461e-16}
			  RE_SMR_12keV[64]= {1.87427e-16,1.76325e-16,1.65174e-16,1.5466e-16,6.44943e-17,5.75699e-17,5.08067e-17,4.52656e-17,4.01587e-17,3.54871e-17,3.11731e-17,2.70987e-17,2.31523e-17,1.96027e-17,1.65539e-17,1.38028e-17}
			  RE_SMR_12keV[80]= {1.13325e-17,9.17755e-18,7.52794e-18,6.24372e-18,5.23448e-18,4.44527e-18,3.8405e-18,3.31097e-18,2.90344e-18,2.55377e-18,2.25152e-18,1.99805e-18,1.78139e-18,1.57831e-18,1.40993e-18,5.40989e-19}
			  RE_SMR_12keV[96]= {4.50124e-19,3.77172e-19,3.19405e-19,2.68486e-19,2.2749e-19,1.96456e-19,1.7064e-19,1.5405e-19,1.37507e-19,1.29722e-19,1.24089e-19,1.18201e-19,1.13688e-19,1.08514e-19,1.04488e-19,1.00389e-19}
			  RE_SMR_12keV[112]= {9.81171e-20,9.49364e-20,9.32653e-20,9.07141e-20,8.83143e-20,8.69192e-20,8.5481e-20,8.43495e-20,8.27911e-20,8.26476e-20,8.08588e-20,8.05436e-20,8.07269e-20,7.96371e-20,7.81021e-20,7.83309e-20}
			  RE_SMR_12keV[128]= {7.65021e-20,7.65321e-20,7.69159e-20,7.54328e-20,7.64873e-20,7.39909e-20,7.44939e-20,7.40568e-20,7.03697e-20,6.97336e-20,6.89672e-20,6.77128e-20,6.70188e-20,6.76331e-20,6.67689e-20,6.66583e-20}
			RE_SMR_12keV[144]= {6.80245e-20,6.86907e-20,6.76795e-20,6.39706e-20,6.39931e-20,6.36532e-20}
	
	endif
		Wave/Z RQ_DSM_12keV
	if(!WaveExists(RQ_DSM_12keV))
	
			Make/O/N=150 RQ_DSM_12keV, RInt_DSM_12keV, RE_DSM_12keV
			
			  RInt_DSM_12keV[0]= {1.50893e-14,2.2575e-14,3.24536e-14,5.18101e-14,1.03041e-13,2.89978e-13,2.42025e-12,6.13852e-12,2.47493e-11,3.69889e-11,5.62025e-11,7.08025e-11,8.40702e-11,9.79318e-11,1.03697e-10,1.17464e-10}
			  RInt_DSM_12keV[16]= {1.29073e-10,1.28846e-10,1.42287e-10,1.5557e-10,1.54884e-10,1.67286e-10,1.66777e-10,1.75392e-10,1.75132e-10,1.77768e-10,1.77372e-10,1.75329e-10,1.74886e-10,1.68271e-10,1.67605e-10,1.67124e-10}
			  RInt_DSM_12keV[32]= {1.56331e-10,1.49161e-10,1.37869e-10,1.39457e-10,1.26889e-10,1.25667e-10,1.03455e-10,8.81e-11,8.70238e-11,6.59543e-11,5.50316e-11,4.39494e-11,2.59856e-11,1.49173e-11,6.92115e-12,1.04369e-12}
			  RInt_DSM_12keV[48]= {2.30955e-13,1.03844e-13,6.1548e-14,3.69798e-14,2.35784e-14,1.75745e-14,1.34446e-14,1.01413e-14,8.11995e-15,6.56702e-15,5.33438e-15,4.3601e-15,3.5337e-15,2.98859e-15,2.54672e-15,2.12866e-15}
			  RInt_DSM_12keV[64]= {1.83398e-15,1.62187e-15,1.43033e-15,1.22898e-15,1.04453e-15,9.23781e-16,7.9394e-16,6.96159e-16,6.19297e-16,5.41633e-16,4.8202e-16,4.26875e-16,3.81121e-16,3.36339e-16,2.92931e-16,2.57316e-16}
			  RInt_DSM_12keV[80]= {2.21617e-16,1.95924e-16,1.71465e-16,1.51885e-16,1.33672e-16,1.16198e-16,1.00967e-16,8.83993e-17,7.69955e-17,6.79866e-17,6.03185e-17,5.34694e-17,4.6781e-17,4.14275e-17,3.56554e-17,3.09206e-17}
			  RInt_DSM_12keV[96]= {2.62556e-17,2.23354e-17,1.98075e-17,1.72305e-17,1.51142e-17,1.29525e-17,1.10527e-17,9.81509e-18,8.59635e-18,7.26849e-18,6.51717e-18,5.76804e-18,5.33092e-18,4.30377e-18,3.94226e-18,3.53041e-18}
			  RInt_DSM_12keV[112]= {3.05551e-18,2.97805e-18,2.4152e-18,1.97413e-18,1.9738e-18,1.81151e-18,1.61568e-18,1.4453e-18,1.408e-18,1.43477e-18,1.23356e-18,1.10925e-18,1.15156e-18,1.07912e-18,1.10517e-18,1.02869e-18}
			  RInt_DSM_12keV[128]= {1.01163e-18,1.02297e-18,8.82708e-19,9.22718e-19,8.43775e-19,7.26586e-19,8.34552e-19,6.74692e-19,6.97695e-19,7.13235e-19,5.28917e-19,4.22705e-19,3.53887e-19,3.04784e-19,2.61698e-19,3.4387e-19}
			RInt_DSM_12keV[144]= {3.40644e-19,4.14617e-19,3.32082e-19,3.57083e-19,2.65324e-19,3.34564e-19}
								
			  RQ_DSM_12keV[0]= {-0.000156891,-0.000144644,-0.000133402,-0.000120955,-0.000110416,-0.000101281,-9.28495e-05,-8.28117e-05,-7.438e-05,-6.88592e-05,-5.93233e-05,-5.38025e-05,-4.86832e-05,-4.24598e-05,-4.00508e-05}
			  RQ_DSM_12keV[15]= {-3.36266e-05,-2.74031e-05,-2.74031e-05,-2.19827e-05,-1.60605e-05,-1.60605e-05,-9.83703e-06,-9.83703e-06,-4.11549e-06,-4.11549e-06,-1.40529e-06,-1.40529e-06,3.91474e-06,3.91474e-06,1.1945e-05}
			  RQ_DSM_12keV[30]= {1.1945e-05,1.1945e-05,1.49563e-05,1.90718e-05,2.51948e-05,2.51948e-05,3.17194e-05,3.17194e-05,3.83443e-05,4.57723e-05,4.57723e-05,5.33006e-05,6.05278e-05,6.55467e-05,7.46811e-05,8.02019e-05}
			  RQ_DSM_12keV[46]= {8.56223e-05,9.56601e-05,0.000103891,0.000111419,0.000122361,0.000133101,0.000143942,0.00015669,0.000167029,0.000182286,0.000196138,0.000211195,0.000226252,0.000244018,0.000263893,0.000286077}
			  RQ_DSM_12keV[62]= {0.000304647,0.000329741,0.000352025,0.000379328,0.000404021,0.000434134,0.000466958,0.000497372,0.000536319,0.000574362,0.000615416,0.000657575,0.000704753,0.000755042,0.00080764,0.000864052}
			  RQ_DSM_12keV[78]= {0.000925283,0.000990328,0.00105959,0.00113357,0.00121226,0.00129648,0.00138381,0.00147967,0.00158336,0.00168966,0.0018073,0.00193448,0.00206688,0.00220942,0.00236229,0.00252199,0.00269334}
			  RQ_DSM_12keV[95]= {0.00287663,0.00307748,0.00328476,0.00350921,0.00375082,0.00400859,0.00427901,0.00457,0.00488368,0.00521453,0.00557217,0.0059513,0.00635472,0.00678705,0.00725049,0.00774204,0.00826672}
			  RQ_DSM_12keV[112]= {0.00883164,0.0094306,0.010072,0.0107544,0.011483,0.0122637,0.013097,0.0139855,0.0149331,0.0159478,0.0170295,0.0181838,0.0194183,0.0207346,0.0221393,0.0236406,0.0252447,0.026956,0.0287818}
			  RQ_DSM_12keV[131]= {0.0307331,0.0328168,0.0350402,0.0374141,0.0399515,0.0426562,0.0455482,0.0486359,0.0519288,0.055447,0.0592044,0.0632176,0.0674956,0.0720681,0.0769514,0.0821626,0.0877282,0.0936685,0.100016}
									
									
			  RE_DSM_12keV[0]= {3.69508e-16,2.35703e-16,3.37502e-16,7.8645e-16,1.33347e-15,3.27647e-15,2.52354e-14,6.35417e-14,2.83683e-13,4.10176e-13,6.08458e-13,7.58991e-13,8.9583e-13,1.03874e-12,1.09819e-12,1.24004e-12}
			  RE_DSM_12keV[16]= {1.35974e-12,1.35742e-12,1.49597e-12,1.63281e-12,1.62574e-12,1.75348e-12,1.74823e-12,1.83703e-12,1.83444e-12,1.86164e-12,1.85759e-12,1.83654e-12,1.83196e-12,1.76376e-12,1.75691e-12,1.75196e-12}
			  RE_DSM_12keV[32]= {1.64077e-12,1.56697e-12,1.45062e-12,1.46698e-12,1.33744e-12,1.32487e-12,1.0959e-12,9.37695e-13,9.26637e-13,7.09387e-13,5.96714e-13,4.82326e-13,2.96691e-13,1.81828e-13,9.76674e-14,3.01741e-14}
			  RE_DSM_12keV[48]= {2.66766e-15,1.34311e-15,8.93134e-16,6.22619e-16,4.66844e-16,3.92657e-16,1.41657e-16,1.076e-16,8.67614e-17,7.07485e-17,5.80335e-17,4.79757e-17,3.9453e-17,3.38116e-17,2.9243e-17,2.49092e-17}
			  RE_DSM_12keV[64]= {2.18454e-17,1.96381e-17,1.76419e-17,1.55341e-17,1.35952e-17,1.23154e-17,1.09367e-17,9.88606e-18,9.05379e-18,8.20536e-18,7.55011e-18,6.93431e-18,6.41856e-18,5.90464e-18,5.39832e-18,4.96842e-18}
			  RE_DSM_12keV[80]= {4.53224e-18,4.20978e-18,3.89459e-18,3.63806e-18,1.51145e-18,1.33194e-18,1.17546e-18,1.04637e-18,9.29589e-19,8.371e-19,7.58488e-19,6.88351e-19,6.20326e-19,5.65752e-19,5.06968e-19,4.58905e-19}
			  RE_DSM_12keV[96]= {4.11879e-19,3.72347e-19,3.47052e-19,3.21522e-19,3.00359e-19,2.79237e-19,2.60747e-19,2.4876e-19,2.37025e-19,2.2429e-19,2.17261e-19,2.09916e-19,2.0584e-19,1.96271e-19,1.93117e-19,1.89289e-19}
			  RE_DSM_12keV[112]= {1.85049e-19,1.84366e-19,1.79231e-19,1.75361e-19,1.75482e-19,1.74171e-19,1.72399e-19,1.70862e-19,1.7058e-19,1.70905e-19,1.69124e-19,1.68135e-19,1.68534e-19,1.67903e-19,1.68047e-19,1.67422e-19}
			  RE_DSM_12keV[128]= {1.67316e-19,1.67349e-19,1.66176e-19,1.66589e-19,1.65971e-19,1.64809e-19,1.65786e-19,1.64389e-19,1.64465e-19,1.64337e-19,1.6288e-19,1.61798e-19,1.61103e-19,1.60839e-19,1.60583e-19,1.61241e-19}
			RE_DSM_12keV[144]= {1.6086e-19,1.61707e-19,1.60823e-19,1.60902e-19,1.6019e-19,1.60851e-19}
	endif

		Wave/Z RQ_DSM_18keV
	if(!WaveExists(RQ_DSM_18keV))
	
			Make/O/N=150 RQ_DSM_18keV, RInt_DSM_18keV, RE_DSM_18keV
 			RInt_DSM_18keV[0]= {5.24009e-14,6.1124e-14,7.61136e-14,1.00655e-13,1.38849e-13,1.89272e-13,2.52439e-13,3.63818e-13,7.765e-13,2.41918e-12,3.32596e-11,7.6516e-11,1.14988e-10,1.41083e-10,1.64477e-10,1.84605e-10}
			  RInt_DSM_18keV[16]= {2.06679e-10,2.24735e-10,2.39437e-10,2.54394e-10,2.72836e-10,2.91756e-10,3.07932e-10,3.14864e-10,3.16117e-10,3.15646e-10,3.14759e-10,3.03015e-10,2.94444e-10,2.80371e-10,2.64536e-10,2.50365e-10}
			  RInt_DSM_18keV[32]= {2.34827e-10,2.14293e-10,1.90568e-10,1.64749e-10,1.28247e-10,9.37316e-11,4.63574e-11,1.86323e-11,4.73741e-12,1.21607e-12,5.54255e-13,3.23686e-13,2.32775e-13,1.59872e-13,1.2009e-13,9.27613e-14}
			  RInt_DSM_18keV[48]= {7.52157e-14,5.59153e-14,3.84074e-14,3.0141e-14,2.45524e-14,1.85698e-14,1.47472e-14,1.16084e-14,8.32342e-15,6.72086e-15,5.36353e-15,4.36681e-15,3.41309e-15,2.75105e-15,2.19682e-15,1.76791e-15}
			  RInt_DSM_18keV[64]= {1.3992e-15,1.1057e-15,8.50715e-16,6.85318e-16,5.40793e-16,4.44946e-16,3.58747e-16,2.95063e-16,2.38242e-16,1.90692e-16,1.5955e-16,1.30057e-16,1.07116e-16,8.99213e-17,7.54791e-17,6.21945e-17}
			  RInt_DSM_18keV[80]= {5.18755e-17,4.33622e-17,3.62383e-17,3.11283e-17,2.60883e-17,2.23326e-17,1.93082e-17,1.67493e-17,1.49736e-17,1.30657e-17,1.12443e-17,1.00897e-17,8.86493e-18,8.22192e-18,7.14027e-18,6.38603e-18}
			  RInt_DSM_18keV[96]= {5.53245e-18,5.11939e-18,4.55373e-18,4.31109e-18,3.87659e-18,3.48325e-18,3.27192e-18,2.99842e-18,2.88518e-18,2.61306e-18,2.34518e-18,2.21957e-18,2.2343e-18,2.05637e-18,1.97079e-18,1.68582e-18}
			  RInt_DSM_18keV[112]= {1.75656e-18,1.60955e-18,1.48353e-18,1.57541e-18,1.41709e-18,1.40601e-18,1.41146e-18,1.36665e-18,1.18582e-18,1.20043e-18,1.13347e-18,1.1221e-18,1.00137e-18,8.8001e-19,7.85363e-19,5.76393e-19}
			  RInt_DSM_18keV[128]= {4.26071e-19,2.85174e-19,2.72478e-19,3.09004e-19,2.44614e-19,3.07052e-19,2.38978e-19,2.76265e-19,2.69063e-19,1.86035e-19,2.85718e-19,3.13553e-19,2.42807e-19,3.00865e-19,3.41737e-19,2.8299e-19}
			RInt_DSM_18keV[144]= {2.62143e-19,1.96346e-19,3.2708e-19,2.98975e-19,2.18596e-19,1.92465e-19}
								
			  RQ_DSM_18keV[0]= {-0.000217758,-0.000198298,-0.000183525,-0.000166764,-0.000150144,-0.000135513,-0.00012486,-0.000115058,-0.000104547,-9.28989e-05,-7.86942e-05,-6.71884e-05,-5.80973e-05,-5.07109e-05,-4.60233e-05}
			  RQ_DSM_18keV[15]= {-3.99153e-05,-3.46595e-05,-2.92617e-05,-2.52844e-05,-2.1023e-05,-1.61934e-05,-1.13638e-05,-6.39213e-06,-1.56252e-06,1.42047e-07,3.40913e-06,6.25008e-06,1.03695e-05,1.29263e-05,1.69036e-05}
			  RQ_DSM_18keV[30]= {2.08809e-05,2.4148e-05,2.78413e-05,3.32391e-05,3.80687e-05,4.38926e-05,5.21314e-05,6.0228e-05,7.28703e-05,8.1251e-05,8.97739e-05,9.82967e-05,0.000106393,0.000116905,0.000126422,0.000139917}
			  RQ_DSM_18keV[46]= {0.000151849,0.000164633,0.00017557,0.0001929,0.000217332,0.000235514,0.000252276,0.000276708,0.000298867,0.000323158,0.000363215,0.000392619,0.000427278,0.00046208,0.000507251,0.000547876}
			  RQ_DSM_18keV[62]= {0.000596599,0.000645037,0.000699157,0.000755265,0.000820323,0.00088254,0.000959529,0.0010324,0.00111791,0.00120144,0.00130414,0.00141536,0.0015226,0.00164491,0.00176707,0.00190599,0.00206011}
			  RQ_DSM_18keV[79]= {0.00222744,0.00239691,0.00258682,0.00280075,0.00301495,0.00324621,0.00349678,0.00375275,0.00404053,0.00435986,0.00470205,0.00507009,0.0054549,0.00589027,0.00634341,0.00683148,0.00736615}
			  RQ_DSM_18keV[96]= {0.00792127,0.00853065,0.00919586,0.00992186,0.0106889,0.0115173,0.0123953,0.0133637,0.0143816,0.0154955,0.0166754,0.0179633,0.0193656,0.020843,0.0224342,0.0241621,0.0260172,0.0280184}
			  RQ_DSM_18keV[114]= {0.0301357,0.0324758,0.0349675,0.0376338,0.0405539,0.0436865,0.0470368,0.0506592,0.0545446,0.0587437,0.0632451,0.0681058,0.0733305,0.0789645,0.0850073,0.0914749,0.0984384,0.105932,0.114002}
			RQ_DSM_18keV[133]= {0.122676,0.132031,0.142115,0.152961,0.16467,0.177284,0.190841,0.205484,0.221225,0.238221,0.256527,0.276291,0.297574,0.320494,0.345181,0.371742,0.400157}
									
			  RE_DSM_18keV[0]= {6.64309e-16,7.51529e-16,9.05559e-16,1.15637e-15,1.54741e-15,2.05812e-15,2.70018e-15,3.83097e-15,8.01771e-15,2.46798e-14,3.51372e-13,7.90264e-13,1.18055e-12,1.44527e-12,2.75805e-12,2.98455e-12}
			  RE_DSM_18keV[16]= {3.23359e-12,3.43302e-12,3.59394e-12,3.75629e-12,3.9572e-12,4.16105e-12,4.33375e-12,4.40644e-12,4.41943e-12,4.41568e-12,4.40705e-12,4.28206e-12,4.18837e-12,4.03608e-12,3.86595e-12,3.71169e-12}
			  RE_DSM_18keV[32]= {3.54295e-12,3.31663e-12,3.05504e-12,2.76326e-12,2.33859e-12,1.91788e-12,1.26783e-12,2.02958e-13,6.09763e-14,2.30756e-14,1.4787e-14,3.42448e-15,2.50116e-15,1.76059e-15,1.35513e-15,1.0759e-15}
			  RE_DSM_18keV[48]= {8.9627e-16,6.97682e-16,5.15649e-16,4.28461e-16,3.68403e-16,3.0275e-16,2.5966e-16,2.22957e-16,1.82569e-16,6.96552e-17,5.58829e-17,4.57716e-17,3.60912e-17,2.93709e-17,2.37399e-17,1.93793e-17}
			  RE_DSM_18keV[64]= {1.56282e-17,1.26347e-17,1.00267e-17,8.32868e-18,6.83495e-18,5.83494e-18,4.92937e-18,4.25391e-18,3.64076e-18,3.11795e-18,2.76599e-18,2.424e-18,2.14984e-18,1.93699e-18,1.75069e-18,6.88349e-19}
			  RE_DSM_18keV[80]= {5.84037e-19,4.9801e-19,4.2613e-19,3.74623e-19,3.23941e-19,2.86364e-19,2.5621e-19,2.30884e-19,2.13298e-19,1.95315e-19,1.76587e-19,1.6545e-19,1.53536e-19,1.47329e-19,1.37179e-19,1.30004e-19}
			  RE_DSM_18keV[96]= {1.22126e-19,1.18272e-19,1.13165e-19,1.10968e-19,1.07084e-19,1.03634e-19,1.01766e-19,9.93407e-20,9.82996e-20,9.59502e-20,9.37039e-20,9.27446e-20,9.28072e-20,9.13206e-20,9.06569e-20,8.84767e-20}
			  RE_DSM_18keV[112]= {8.90274e-20,8.77917e-20,8.6866e-20,8.76932e-20,8.63199e-20,8.62784e-20,8.63014e-20,8.59013e-20,8.44128e-20,8.46217e-20,8.39328e-20,8.37449e-20,8.27866e-20,8.2006e-20,8.13906e-20,7.98176e-20}
			  RE_DSM_18keV[128]= {7.86614e-20,7.7533e-20,7.75802e-20,7.80158e-20,7.73938e-20,7.78826e-20,7.74303e-20,7.78418e-20,7.78364e-20,7.6704e-20,7.75258e-20,7.78674e-20,7.7367e-20,7.78337e-20,7.82692e-20,7.78765e-20}
			RE_DSM_18keV[144]= {7.79181e-20,7.78303e-20,7.87979e-20,7.85418e-20,7.79793e-20,7.75587e-20}
	endif
	
	setDataFolder oldDf
end

////*************************************************************************
////*************************************************************************
////*************************************************************************
////*************************************************************************