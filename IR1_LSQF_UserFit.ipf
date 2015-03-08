#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.01

//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.01 added license for ANL


//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from www.uni.aps.anl.gov/~ilavsky
//this package contains 
// Igor functions for modeling of SAS from various distributions of scatterers...

//Jan Ilavsky, March 2002

//please, read Readme in the distribution zip file with more details on the program
//report any problems to: ilavsky@aps.anl.gov


//main functions for modeling with user input of distributions...





//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1U_ConstructTheFittingCommand()
	//here we need to construct the fitting command and prepare the data for fit...

	string OldDF=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling
	
	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions

	NVAR SASBackground=root:Packages:SAS_Modeling:SASBackground
	NVAR FitSASBackground=root:Packages:SAS_Modeling:FitSASBackground
//dist 1 part	
	NVAR Dist1VolFraction=root:Packages:SAS_Modeling:Dist1VolFraction
	NVAR Dist1VolHighLimit=root:Packages:SAS_Modeling:Dist1VolHighLimit
	NVAR Dist1VolLowLimit=root:Packages:SAS_Modeling:Dist1VolLowLimit
	NVAR Dist1DiamMultiplier=root:Packages:SAS_Modeling:Dist1DiamMultiplier
	NVAR Dist1DMHighLimit=root:Packages:SAS_Modeling:Dist1DMHighLimit
	NVAR Dist1DmLowLimit=root:Packages:SAS_Modeling:Dist1DMLowLimit
	NVAR Dist1DiamAddition=root:Packages:SAS_Modeling:Dist1DiamAddition
	NVAR Dist1DAHighLimit=root:Packages:SAS_Modeling:Dist1DAHighLimit
	NVAR Dist1DALowLimit=root:Packages:SAS_Modeling:Dist1DALowLimit
	
	NVAR Dist1FitDA=root:Packages:SAS_Modeling:Dist1FitDA
	NVAR Dist1FitDM=root:Packages:SAS_Modeling:Dist1FitDM
	NVAR Dist1FitVol=root:Packages:SAS_Modeling:Dist1FitVol

//dist 2 part
	NVAR Dist2VolFraction=root:Packages:SAS_Modeling:Dist2VolFraction
	NVAR Dist2VolHighLimit=root:Packages:SAS_Modeling:Dist2VolHighLimit
	NVAR Dist2VolLowLimit=root:Packages:SAS_Modeling:Dist2VolLowLimit
	NVAR Dist2DiamMultiplier=root:Packages:SAS_Modeling:Dist2DiamMultiplier
	NVAR Dist2DMHighLimit=root:Packages:SAS_Modeling:Dist2DMHighLimit
	NVAR Dist2DmLowLimit=root:Packages:SAS_Modeling:Dist2DMLowLimit
	NVAR Dist2DiamAddition=root:Packages:SAS_Modeling:Dist2DiamAddition
	NVAR Dist2DAHighLimit=root:Packages:SAS_Modeling:Dist2DAHighLimit
	NVAR Dist2DALowLimit=root:Packages:SAS_Modeling:Dist2DALowLimit
	
	NVAR Dist2FitDA=root:Packages:SAS_Modeling:Dist2FitDA
	NVAR Dist2FitDM=root:Packages:SAS_Modeling:Dist2FitDM
	NVAR Dist2FitVol=root:Packages:SAS_Modeling:Dist2FitVol

//dist3 part
	NVAR Dist3VolFraction=root:Packages:SAS_Modeling:Dist3VolFraction
	NVAR Dist3VolHighLimit=root:Packages:SAS_Modeling:Dist3VolHighLimit
	NVAR Dist3VolLowLimit=root:Packages:SAS_Modeling:Dist3VolLowLimit
	NVAR Dist3DiamMultiplier=root:Packages:SAS_Modeling:Dist3DiamMultiplier
	NVAR Dist3DMHighLimit=root:Packages:SAS_Modeling:Dist3DMHighLimit
	NVAR Dist3DmLowLimit=root:Packages:SAS_Modeling:Dist3DMLowLimit
	NVAR Dist3DiamAddition=root:Packages:SAS_Modeling:Dist3DiamAddition
	NVAR Dist3DAHighLimit=root:Packages:SAS_Modeling:Dist3DAHighLimit
	NVAR Dist3DALowLimit=root:Packages:SAS_Modeling:Dist3DALowLimit
	
	NVAR Dist3FitDA=root:Packages:SAS_Modeling:Dist3FitDA
	NVAR Dist3FitDM=root:Packages:SAS_Modeling:Dist3FitDM
	NVAR Dist3FitVol=root:Packages:SAS_Modeling:Dist3FitVol

//Dist 4 part
	NVAR Dist4VolFraction=root:Packages:SAS_Modeling:Dist4VolFraction
	NVAR Dist4VolHighLimit=root:Packages:SAS_Modeling:Dist4VolHighLimit
	NVAR Dist4VolLowLimit=root:Packages:SAS_Modeling:Dist4VolLowLimit
	NVAR Dist4DiamMultiplier=root:Packages:SAS_Modeling:Dist4DiamMultiplier
	NVAR Dist4DMHighLimit=root:Packages:SAS_Modeling:Dist4DMHighLimit
	NVAR Dist4DmLowLimit=root:Packages:SAS_Modeling:Dist4DMLowLimit
	NVAR Dist4DiamAddition=root:Packages:SAS_Modeling:Dist4DiamAddition
	NVAR Dist4DAHighLimit=root:Packages:SAS_Modeling:Dist4DAHighLimit
	NVAR Dist4DALowLimit=root:Packages:SAS_Modeling:Dist4DALowLimit
	
	NVAR Dist4FitDA=root:Packages:SAS_Modeling:Dist4FitDA
	NVAR Dist4FitDM=root:Packages:SAS_Modeling:Dist4FitDM
	NVAR Dist4FitVol=root:Packages:SAS_Modeling:Dist4FitVol

//dist 5 part
	NVAR Dist5VolFraction=root:Packages:SAS_Modeling:Dist5VolFraction
	NVAR Dist5VolHighLimit=root:Packages:SAS_Modeling:Dist5VolHighLimit
	NVAR Dist5VolLowLimit=root:Packages:SAS_Modeling:Dist5VolLowLimit
	NVAR Dist5DiamMultiplier=root:Packages:SAS_Modeling:Dist5DiamMultiplier
	NVAR Dist5DMHighLimit=root:Packages:SAS_Modeling:Dist5DMHighLimit
	NVAR Dist5DmLowLimit=root:Packages:SAS_Modeling:Dist5DMLowLimit
	NVAR Dist5DiamAddition=root:Packages:SAS_Modeling:Dist5DiamAddition
	NVAR Dist5DAHighLimit=root:Packages:SAS_Modeling:Dist5DAHighLimit
	NVAR Dist5DALowLimit=root:Packages:SAS_Modeling:Dist5DALowLimit
	
	NVAR Dist5FitDA=root:Packages:SAS_Modeling:Dist5FitDA
	NVAR Dist5FitDM=root:Packages:SAS_Modeling:Dist5FitDM
	NVAR Dist5FitVol=root:Packages:SAS_Modeling:Dist5FitVol

//now we can make various parts of the fitting routines...
	//start with W_coef, order of parameters:
	//SAS_Background						K0
	//Dist1Volume, Location, Scale, Shape		K1,K2,K3,K4
	//Dist2Volume, Location, Scale, Shape		K5,K6,K7,K8
	//Dist3Volume, Location, Scale, Shape		K9,K10,K11,K12
	//Dist4Volume, Location, Scale, Shape		K13,K14,K15,K16
	//Dist5Volume, Location, Scale, Shape		K17,K18,K19,K20
	//that is 21 fitting parameters
//	W_coef[0]={SASBackground,Dist1VolFraction,Dist1Location,Dist1Scale,Dist1Shape,Dist2VolFraction,Dist2Location,Dist2Scale,Dist2Shape}
//	W_coef[9]={Dist3VolFraction,Dist3Location,Dist3Scale,Dist3Shape,Dist4VolFraction,Dist4Location,Dist4Scale,Dist4Shape}
//	W_coef[17]={Dist5VolFraction,Dist5Location,Dist5Scale,Dist5Shape}
	

	Make/D/N=0/O W_coef
	Make/T/N=0/O CoefNames
	Make/D/O/T/N=0 T_Constraints
	T_Constraints=""
	CoefNames=""
	
	if (FitSASBackground)		//are we fitting background?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames//, T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SASBackground
		CoefNames[numpnts(CoefNames)-1]="SASBackground"
	//	T_Constraints[0] = {"K"+num2str(numpnts(W_coef)-1)+" > 0"}
	endif
//dist 1 part	
	if (Dist1FitVol && NumberOfDistributions>0)		//are we fitting distribution 1 volume?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Dist1VolFraction
		CoefNames[numpnts(CoefNames)-1]="Dist1VolFraction"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist1VolLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist1VolHighLimit)}		
	endif
	if (Dist1FitDA && NumberOfDistributions>0)		//are we fitting distribution 1 location?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Dist1DiamAddition
		CoefNames[numpnts(CoefNames)-1]="Dist1DiamAddition"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist1DALowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist1DAHighLimit)}		
	endif
	if (Dist1FitDM && NumberOfDistributions>0)		//are we fitting distribution 1 location?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Dist1DiamMultiplier
		CoefNames[numpnts(CoefNames)-1]="Dist1DiamMultiplier"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist1DMLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist1DMHighLimit)}		
	endif
	
//dist 2 part	
	if (Dist2FitVol && NumberOfDistributions>1)		//are we fitting distribution 2 volume?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Dist2VolFraction
		CoefNames[numpnts(CoefNames)-1]="Dist2VolFraction"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist2VolLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist2VolHighLimit)}		
	endif
	if (Dist2FitDA && NumberOfDistributions>1)		//are we fitting distribution 1 location?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Dist2DiamAddition
		CoefNames[numpnts(CoefNames)-1]="Dist2DiamAddition"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist2DALowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist2DAHighLimit)}		
	endif
	if (Dist2FitDM && NumberOfDistributions>1)		//are we fitting distribution 1 location?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Dist2DiamMultiplier
		CoefNames[numpnts(CoefNames)-1]="Dist2DiamMultiplier"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist2DMLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist2DMHighLimit)}		
	endif
	
//dist 3 part	
	if (Dist3FitVol && NumberOfDistributions>2)		//are we fitting distribution 3 volume?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Dist3VolFraction
		CoefNames[numpnts(CoefNames)-1]="Dist3VolFraction"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist3VolLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist3VolHighLimit)}		
	endif
	if (Dist3FitDA && NumberOfDistributions>2)		//are we fitting distribution 1 location?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Dist3DiamAddition
		CoefNames[numpnts(CoefNames)-1]="Dist3DiamAddition"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist3DALowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist3DAHighLimit)}		
	endif
	if (Dist3FitDM && NumberOfDistributions>2)		//are we fitting distribution 1 location?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Dist3DiamMultiplier
		CoefNames[numpnts(CoefNames)-1]="Dist3DiamMultiplier"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist3DMLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist3DMHighLimit)}		
	endif
	
//dist 4 part	
	if (Dist4FitVol && NumberOfDistributions>3)		//are we fitting distribution 4 volume?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Dist4VolFraction
		CoefNames[numpnts(CoefNames)-1]="Dist4VolFraction"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist4VolLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist4VolHighLimit)}		
	endif
	if (Dist4FitDA && NumberOfDistributions>3)		//are we fitting distribution 1 location?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Dist2DiamAddition
		CoefNames[numpnts(CoefNames)-1]="Dist4DiamAddition"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist4DALowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist4DAHighLimit)}		
	endif
	if (Dist4FitDM && NumberOfDistributions>3)		//are we fitting distribution 1 location?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Dist4DiamMultiplier
		CoefNames[numpnts(CoefNames)-1]="Dist4DiamMultiplier"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist4DMLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist4DMHighLimit)}		
	endif

//dist 5 part	
//	W_coef[0]={SASBackground,Dist1VolFraction,Dist1Location,Dist1Scale,Dist1Shape,Dist2VolFraction,Dist2Location,Dist2Scale,Dist2Shape}
//	W_coef[9]={Dist3VolFraction,Dist3Location,Dist3Scale,Dist3Shape,Dist4VolFraction,Dist4Location,Dist4Scale,Dist4Shape}
//	W_coef[17]={Dist5VolFraction,Dist5Location,Dist5Scale,Dist5Shape}
	if (Dist5FitVol && NumberOfDistributions>4)		//are we fitting distribution 1 volume?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Dist5VolFraction
		CoefNames[numpnts(CoefNames)-1]="Dist5VolFraction"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist5VolLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist5VolHighLimit)}		
	endif
	if (Dist5FitDA && NumberOfDistributions>4)		//are we fitting distribution 1 location?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Dist5DiamAddition
		CoefNames[numpnts(CoefNames)-1]="Dist5DiamAddition"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist5DALowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist5DAHighLimit)}		
	endif
	if (Dist5FitDM && NumberOfDistributions>4)		//are we fitting distribution 1 location?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Dist5DiamMultiplier
		CoefNames[numpnts(CoefNames)-1]="Dist5DiamMultiplier"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Dist5DMLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Dist5DMHighLimit)}		
	endif
	

	DoWindow /F IR1_LogLogPlotLSQF
	Wave OriginalQvector
	Wave OriginalIntensity
	Wave OriginalError	
	
	Variable V_chisq
	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave=W_coef/20

	IR1U_RecordResults("before")

	Variable V_FitError=0			//This should prevent errors from being generated
	
	//and now the fit...
	if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalIntensity, FitIntensityWave		
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalQvector, FitQvectorWave
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalError, FitErrorWave
		FuncFit /N/Q IR1U_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /D /C=T_Constraints 
	else
		Duplicate/O OriginalIntensity, FitIntensityWave		
		Duplicate/O OriginalQvector, FitQvectorWave
		Duplicate/O OriginalError, FitErrorWave
		FuncFit /N/Q IR1U_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D /C=T_Constraints	
	endif
	if (V_FitError!=0)	//there was error in fitting
		IR1U_ResetParamsAfterBadFit()
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	
	variable/g AchievedChisq=V_chisq
	IR1U_GraphModelData()
	IR1U_RecordResults("after")
	
	DoWIndow/F IR1U_ControlPanel
	IR1U_FixTabsInPanel()
	
	KillWaves T_Constraints, E_wave
	
	setDataFolder OldDF
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_ResetParamsAfterBadFit()
	
	Wave w=root:Packages:SAS_Modeling:CoefficientInput
	Wave/T CoefNames=root:Packages:SAS_Modeling:CoefNames		//text wave with names of parameters

	if ((!WaveExists(w)) || (!WaveExists(CoefNames)))
		abort
	endif

	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions

	NVAR SASBackground=root:Packages:SAS_Modeling:SASBackground
	NVAR FitSASBackground=root:Packages:SAS_Modeling:FitSASBackground
//dist 1 part	
	NVAR Dist1VolFraction=root:Packages:SAS_Modeling:Dist1VolFraction
	NVAR Dist1VolHighLimit=root:Packages:SAS_Modeling:Dist1VolHighLimit
	NVAR Dist1VolLowLimit=root:Packages:SAS_Modeling:Dist1VolLowLimit
	NVAR Dist1DiamMultiplier=root:Packages:SAS_Modeling:Dist1DiamMultiplier
	NVAR Dist1DMHighLimit=root:Packages:SAS_Modeling:Dist1DMHighLimit
	NVAR Dist1DmLowLimit=root:Packages:SAS_Modeling:Dist1DMLowLimit
	NVAR Dist1DiamAddition=root:Packages:SAS_Modeling:Dist1DiamAddition
	NVAR Dist1DAHighLimit=root:Packages:SAS_Modeling:Dist1DAHighLimit
	NVAR Dist1DALowLimit=root:Packages:SAS_Modeling:Dist1DALowLimit
	
	NVAR Dist1DMStep=root:Packages:SAS_Modeling:Dist1DMStep
	NVAR Dist1DAStep=root:Packages:SAS_Modeling:Dist1DAStep
	NVAR Dist1FitVol=root:Packages:SAS_Modeling:Dist1FitVol

//dist 2 part
	NVAR Dist2VolFraction=root:Packages:SAS_Modeling:Dist2VolFraction
	NVAR Dist2VolHighLimit=root:Packages:SAS_Modeling:Dist2VolHighLimit
	NVAR Dist2VolLowLimit=root:Packages:SAS_Modeling:Dist2VolLowLimit
	NVAR Dist2DiamMultiplier=root:Packages:SAS_Modeling:Dist2DiamMultiplier
	NVAR Dist2DMHighLimit=root:Packages:SAS_Modeling:Dist2DMHighLimit
	NVAR Dist2DmLowLimit=root:Packages:SAS_Modeling:Dist2DMLowLimit
	NVAR Dist2DiamAddition=root:Packages:SAS_Modeling:Dist2DiamAddition
	NVAR Dist2DAHighLimit=root:Packages:SAS_Modeling:Dist2DAHighLimit
	NVAR Dist2DALowLimit=root:Packages:SAS_Modeling:Dist2DALowLimit
	
	NVAR Dist2DMStep=root:Packages:SAS_Modeling:Dist2DMStep
	NVAR Dist2DAStep=root:Packages:SAS_Modeling:Dist2DAStep
	NVAR Dist2FitVol=root:Packages:SAS_Modeling:Dist2FitVol

//dist3 part
	NVAR Dist3VolFraction=root:Packages:SAS_Modeling:Dist3VolFraction
	NVAR Dist3VolHighLimit=root:Packages:SAS_Modeling:Dist3VolHighLimit
	NVAR Dist3VolLowLimit=root:Packages:SAS_Modeling:Dist3VolLowLimit
	NVAR Dist3DiamMultiplier=root:Packages:SAS_Modeling:Dist3DiamMultiplier
	NVAR Dist3DMHighLimit=root:Packages:SAS_Modeling:Dist3DMHighLimit
	NVAR Dist3DmLowLimit=root:Packages:SAS_Modeling:Dist3DMLowLimit
	NVAR Dist3DiamAddition=root:Packages:SAS_Modeling:Dist3DiamAddition
	NVAR Dist3DAHighLimit=root:Packages:SAS_Modeling:Dist3DAHighLimit
	NVAR Dist3DALowLimit=root:Packages:SAS_Modeling:Dist3DALowLimit
	
	NVAR Dist3DMStep=root:Packages:SAS_Modeling:Dist3DMStep
	NVAR Dist3DAStep=root:Packages:SAS_Modeling:Dist3DAStep
	NVAR Dist3FitVol=root:Packages:SAS_Modeling:Dist3FitVol

//Dist 4 part
	NVAR Dist4VolFraction=root:Packages:SAS_Modeling:Dist4VolFraction
	NVAR Dist4VolHighLimit=root:Packages:SAS_Modeling:Dist4VolHighLimit
	NVAR Dist4VolLowLimit=root:Packages:SAS_Modeling:Dist4VolLowLimit
	NVAR Dist4DiamMultiplier=root:Packages:SAS_Modeling:Dist4DiamMultiplier
	NVAR Dist4DMHighLimit=root:Packages:SAS_Modeling:Dist4DMHighLimit
	NVAR Dist4DmLowLimit=root:Packages:SAS_Modeling:Dist4DMLowLimit
	NVAR Dist4DiamAddition=root:Packages:SAS_Modeling:Dist4DiamAddition
	NVAR Dist4DAHighLimit=root:Packages:SAS_Modeling:Dist4DAHighLimit
	NVAR Dist4DALowLimit=root:Packages:SAS_Modeling:Dist4DALowLimit
	
	NVAR Dist4DMStep=root:Packages:SAS_Modeling:Dist4DMStep
	NVAR Dist4DAStep=root:Packages:SAS_Modeling:Dist4DAStep
	NVAR Dist4FitVol=root:Packages:SAS_Modeling:Dist4FitVol

//dist 5 part
	NVAR Dist5VolFraction=root:Packages:SAS_Modeling:Dist5VolFraction
	NVAR Dist5VolHighLimit=root:Packages:SAS_Modeling:Dist5VolHighLimit
	NVAR Dist5VolLowLimit=root:Packages:SAS_Modeling:Dist5VolLowLimit
	NVAR Dist5DiamMultiplier=root:Packages:SAS_Modeling:Dist5DiamMultiplier
	NVAR Dist5DMHighLimit=root:Packages:SAS_Modeling:Dist5DMHighLimit
	NVAR Dist5DmLowLimit=root:Packages:SAS_Modeling:Dist5DMLowLimit
	NVAR Dist5DiamAddition=root:Packages:SAS_Modeling:Dist5DiamAddition
	NVAR Dist5DAHighLimit=root:Packages:SAS_Modeling:Dist5DAHighLimit
	NVAR Dist5DALowLimit=root:Packages:SAS_Modeling:Dist5DALowLimit
	
	NVAR Dist5DMStep=root:Packages:SAS_Modeling:Dist5DMStep
	NVAR Dist5DAStep=root:Packages:SAS_Modeling:Dist5DAStep

	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	string ParamName=""
	
	for (i=0;i<NumOfParam;i+=1)
		ParamName=CoefNames[i]
	
		if(cmpstr(ParamName,"SASBackground")==0)
			SASBackground=w[i]
		endif

		if(cmpstr(ParamName,"Dist1VolFraction")==0)
			Dist1VolFraction=w[i]
		endif
		if(cmpstr(ParamName,"Dist1DiamAddition")==0)
			Dist1DiamAddition=w[i]
		endif
		if(cmpstr(ParamName,"Dist1DiamMultiplier")==0)
			Dist1DiamMultiplier=w[i]
		endif
	
		if(cmpstr(ParamName,"Dist2VolFraction")==0)
			Dist2VolFraction=w[i]
		endif
		if(cmpstr(ParamName,"Dist2DiamAddition")==0)
			Dist2DiamAddition=w[i]
		endif
		if(cmpstr(ParamName,"Dist2DiamMultiplier")==0)
			Dist2DiamMultiplier=w[i]
		endif

		if(cmpstr(ParamName,"Dist3VolFraction")==0)
			Dist3VolFraction=w[i]
		endif
		if(cmpstr(ParamName,"Dist3DiamAddition")==0)
			Dist3DiamAddition=w[i]
		endif
		if(cmpstr(ParamName,"Dist3DiamMultiplier")==0)
			Dist3DiamMultiplier=w[i]
		endif
	
		if(cmpstr(ParamName,"Dist4VolFraction")==0)
			Dist4VolFraction=w[i]
		endif
		if(cmpstr(ParamName,"Dist4DiamAddition")==0)
			Dist4DiamAddition=w[i]
		endif
		if(cmpstr(ParamName,"Dist4DiamMultiplier")==0)
			Dist4DiamMultiplier=w[i]
		endif
	
		if(cmpstr(ParamName,"Dist5VolFraction")==0)
			Dist5VolFraction=w[i]
		endif
		if(cmpstr(ParamName,"Dist5DiamAddition")==0)
			Dist5DiamAddition=w[i]
		endif
		if(cmpstr(ParamName,"Dist5DiamMultiplier")==0)
			Dist5DiamMultiplier=w[i]
		endif
	
	endfor
	DoWIndow/F IR1U_ControlPanel
	IR1U_FixTabsInPanel()

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_FitFunction(w,yw,xw) : FitFunc
	Wave w,yw,xw
	
	//here the w contains the parameters, yw will be the result and xw is the input
	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(q) = very complex calculations, forget about formula
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1 - the q vector...
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 21 - up to, but never used
	//CurveFitDialog/ w[0] = SAS_Background
	//CurveFitDialog/ w[1] = Dist1Volume
	//CurveFitDialog/ w[2] = Dist1Location
	//CurveFitDialog/ w[3] = Dist1Scale
	//CurveFitDialog/ w[4] = Dist1Shape
	//CurveFitDialog/ w[5] = Dist2Volume
	//CurveFitDialog/ w[6] = Dist2Location
	//CurveFitDialog/ w[7] = Dist2Scale
	//CurveFitDialog/ w[8] = Dist2Shape
	//CurveFitDialog/ w[9] = Dist3Volume
	//CurveFitDialog/ w[10] = Dist3Location
	//CurveFitDialog/ w[11] = Dist3Scale
	//CurveFitDialog/ w[12] = Dist3Shape
	//CurveFitDialog/ w[13] = Dist4Volume
	//CurveFitDialog/ w[14] = Dist4Location
	//CurveFitDialog/ w[15] = Dist4Scale
	//CurveFitDialog/ w[16] = Dist4Shape
	//CurveFitDialog/ w[17] = Dist5Volume
	//CurveFitDialog/ w[18] = Dist5Location
	//CurveFitDialog/ w[19] = Dist5Scale
	//CurveFitDialog/ w[20] = Dist5Shape


	//SAS_Background						K0
	//Dist1Volume, Location, Scale, Shape		K1,K2,K3,K4
	//Dist2Volume, Location, Scale, Shape		K5,K6,K7,K8
	//Dist3Volume, Location, Scale, Shape		K9,K10,K11,K12
	//Dist4Volume, Location, Scale, Shape		K13,K14,K15,K16
	//Dist5Volume, Location, Scale, Shape		K17,K18,K19,K20
	//that is 21 fitting parameters

	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions

	NVAR SASBackground=root:Packages:SAS_Modeling:SASBackground
	NVAR FitSASBackground=root:Packages:SAS_Modeling:FitSASBackground
//dist 1 part	
	NVAR Dist1VolFraction=root:Packages:SAS_Modeling:Dist1VolFraction
	NVAR Dist1VolHighLimit=root:Packages:SAS_Modeling:Dist1VolHighLimit
	NVAR Dist1VolLowLimit=root:Packages:SAS_Modeling:Dist1VolLowLimit
	NVAR Dist1DiamMultiplier=root:Packages:SAS_Modeling:Dist1DiamMultiplier
	NVAR Dist1DMHighLimit=root:Packages:SAS_Modeling:Dist1DMHighLimit
	NVAR Dist1DmLowLimit=root:Packages:SAS_Modeling:Dist1DMLowLimit
	NVAR Dist1DiamAddition=root:Packages:SAS_Modeling:Dist1DiamAddition
	NVAR Dist1DAHighLimit=root:Packages:SAS_Modeling:Dist1DAHighLimit
	NVAR Dist1DALowLimit=root:Packages:SAS_Modeling:Dist1DALowLimit
	
	NVAR Dist1DMStep=root:Packages:SAS_Modeling:Dist1DMStep
	NVAR Dist1DAStep=root:Packages:SAS_Modeling:Dist1DAStep
	NVAR Dist1FitVol=root:Packages:SAS_Modeling:Dist1FitVol

//dist 2 part
	NVAR Dist2VolFraction=root:Packages:SAS_Modeling:Dist2VolFraction
	NVAR Dist2VolHighLimit=root:Packages:SAS_Modeling:Dist2VolHighLimit
	NVAR Dist2VolLowLimit=root:Packages:SAS_Modeling:Dist2VolLowLimit
	NVAR Dist2DiamMultiplier=root:Packages:SAS_Modeling:Dist2DiamMultiplier
	NVAR Dist2DMHighLimit=root:Packages:SAS_Modeling:Dist2DMHighLimit
	NVAR Dist2DmLowLimit=root:Packages:SAS_Modeling:Dist2DMLowLimit
	NVAR Dist2DiamAddition=root:Packages:SAS_Modeling:Dist2DiamAddition
	NVAR Dist2DAHighLimit=root:Packages:SAS_Modeling:Dist2DAHighLimit
	NVAR Dist2DALowLimit=root:Packages:SAS_Modeling:Dist2DALowLimit
	
	NVAR Dist2DMStep=root:Packages:SAS_Modeling:Dist2DMStep
	NVAR Dist2DAStep=root:Packages:SAS_Modeling:Dist2DAStep
	NVAR Dist2FitVol=root:Packages:SAS_Modeling:Dist2FitVol

//dist3 part
	NVAR Dist3VolFraction=root:Packages:SAS_Modeling:Dist3VolFraction
	NVAR Dist3VolHighLimit=root:Packages:SAS_Modeling:Dist3VolHighLimit
	NVAR Dist3VolLowLimit=root:Packages:SAS_Modeling:Dist3VolLowLimit
	NVAR Dist3DiamMultiplier=root:Packages:SAS_Modeling:Dist3DiamMultiplier
	NVAR Dist3DMHighLimit=root:Packages:SAS_Modeling:Dist3DMHighLimit
	NVAR Dist3DmLowLimit=root:Packages:SAS_Modeling:Dist3DMLowLimit
	NVAR Dist3DiamAddition=root:Packages:SAS_Modeling:Dist3DiamAddition
	NVAR Dist3DAHighLimit=root:Packages:SAS_Modeling:Dist3DAHighLimit
	NVAR Dist3DALowLimit=root:Packages:SAS_Modeling:Dist3DALowLimit
	
	NVAR Dist3DMStep=root:Packages:SAS_Modeling:Dist3DMStep
	NVAR Dist3DAStep=root:Packages:SAS_Modeling:Dist3DAStep
	NVAR Dist3FitVol=root:Packages:SAS_Modeling:Dist3FitVol

//Dist 4 part
	NVAR Dist4VolFraction=root:Packages:SAS_Modeling:Dist4VolFraction
	NVAR Dist4VolHighLimit=root:Packages:SAS_Modeling:Dist4VolHighLimit
	NVAR Dist4VolLowLimit=root:Packages:SAS_Modeling:Dist4VolLowLimit
	NVAR Dist4DiamMultiplier=root:Packages:SAS_Modeling:Dist4DiamMultiplier
	NVAR Dist4DMHighLimit=root:Packages:SAS_Modeling:Dist4DMHighLimit
	NVAR Dist4DmLowLimit=root:Packages:SAS_Modeling:Dist4DMLowLimit
	NVAR Dist4DiamAddition=root:Packages:SAS_Modeling:Dist4DiamAddition
	NVAR Dist4DAHighLimit=root:Packages:SAS_Modeling:Dist4DAHighLimit
	NVAR Dist4DALowLimit=root:Packages:SAS_Modeling:Dist4DALowLimit
	
	NVAR Dist4DMStep=root:Packages:SAS_Modeling:Dist4DMStep
	NVAR Dist4DAStep=root:Packages:SAS_Modeling:Dist4DAStep
	NVAR Dist4FitVol=root:Packages:SAS_Modeling:Dist4FitVol

//dist 5 part
	NVAR Dist5VolFraction=root:Packages:SAS_Modeling:Dist5VolFraction
	NVAR Dist5VolHighLimit=root:Packages:SAS_Modeling:Dist5VolHighLimit
	NVAR Dist5VolLowLimit=root:Packages:SAS_Modeling:Dist5VolLowLimit
	NVAR Dist5DiamMultiplier=root:Packages:SAS_Modeling:Dist5DiamMultiplier
	NVAR Dist5DMHighLimit=root:Packages:SAS_Modeling:Dist5DMHighLimit
	NVAR Dist5DmLowLimit=root:Packages:SAS_Modeling:Dist5DMLowLimit
	NVAR Dist5DiamAddition=root:Packages:SAS_Modeling:Dist5DiamAddition
	NVAR Dist5DAHighLimit=root:Packages:SAS_Modeling:Dist5DAHighLimit
	NVAR Dist5DALowLimit=root:Packages:SAS_Modeling:Dist5DALowLimit
	
	NVAR Dist5DMStep=root:Packages:SAS_Modeling:Dist5DMStep
	NVAR Dist5DAStep=root:Packages:SAS_Modeling:Dist5DAStep

	Wave/T CoefNames=root:Packages:SAS_Modeling:CoefNames		//text wave with names of parameters

	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	string ParamName=""
	
	for (i=0;i<NumOfParam;i+=1)
		ParamName=CoefNames[i]
	
		if(cmpstr(ParamName,"SASBackground")==0)
			SASBackground=w[i]
		endif

		if(cmpstr(ParamName,"Dist1VolFraction")==0)
			Dist1VolFraction=w[i]
		endif
		if(cmpstr(ParamName,"Dist1DiamAddition")==0)
			Dist1DiamAddition=w[i]
		endif
		if(cmpstr(ParamName,"Dist1DiamMultiplier")==0)
			Dist1DiamMultiplier=w[i]
		endif
	
		if(cmpstr(ParamName,"Dist2VolFraction")==0)
			Dist2VolFraction=w[i]
		endif
		if(cmpstr(ParamName,"Dist2DiamAddition")==0)
			Dist2DiamAddition=w[i]
		endif
		if(cmpstr(ParamName,"Dist2DiamMultiplier")==0)
			Dist2DiamMultiplier=w[i]
		endif

		if(cmpstr(ParamName,"Dist3VolFraction")==0)
			Dist3VolFraction=w[i]
		endif
		if(cmpstr(ParamName,"Dist3DiamAddition")==0)
			Dist3DiamAddition=w[i]
		endif
		if(cmpstr(ParamName,"Dist3DiamMultiplier")==0)
			Dist3DiamMultiplier=w[i]
		endif
	
		if(cmpstr(ParamName,"Dist4VolFraction")==0)
			Dist4VolFraction=w[i]
		endif
		if(cmpstr(ParamName,"Dist4DiamAddition")==0)
			Dist4DiamAddition=w[i]
		endif
		if(cmpstr(ParamName,"Dist4DiamMultiplier")==0)
			Dist4DiamMultiplier=w[i]
		endif
	
		if(cmpstr(ParamName,"Dist5VolFraction")==0)
			Dist5VolFraction=w[i]
		endif
		if(cmpstr(ParamName,"Dist5DiamAddition")==0)
			Dist5DiamAddition=w[i]
		endif
		if(cmpstr(ParamName,"Dist5DiamMultiplier")==0)
			Dist5DiamMultiplier=w[i]
		endif
	
	endfor
	
	



	Wave QvectorWave=root:Packages:SAS_Modeling:FitQvectorWave

//		IR1U_CreateDistributionWaves()			//create distributon waves...
		//now we will copy original data into local waves
//		IR1U_CopyOrgDataIntoLocWvs()			//next we will copy the data into them
		//now we will modify them with our modifying parameters
		IR1U_ModifyDataWithParams()				//next we will modify the distribution waves with the 2 parameters 
		//and now we need to calculate the model Intensity
		IR1U_FitCalculateModelIntensity(QvectorWave)		//modified for 5
	
	Wave resultWv=root:Packages:SAS_Modeling:FitDistModelIntensity
	
	yw=resultWv
	
End


