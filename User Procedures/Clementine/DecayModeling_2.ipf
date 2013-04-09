#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.2

//this is part II of code supporting Decay modeling package called "Clementine".
// here are functions needed for LSQF part.
// 1.2 JIL 7/7/2011 

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function DecJIL_CalcModelManually(createWaves)
	variable createWaves		//creates target waves, if set to 0 assumes waves exist (fitting)

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:DecayModeling
	//calculate model resonse from existing parameters...
	//these are waves with data created by the rest of the code... 
	Wave Rebinned_Decay_ProfMeasTimes=root:Packages:DecayModeling:Rebinned_Decay_ProfMeasTimes
	Wave Rebinned_Decay_Prof=root:Packages:DecayModeling:Rebinned_Decay_Prof
	Wave Rebinned_Decay_ProfErrors=root:Packages:DecayModeling:Rebinned_Decay_ProfErrors

	if ( ((strlen(CsrWave(A))==0) || (strlen(CsrWave(B))==0) ) || (pcsr (A)==pcsr (B)) )	//this should make sure, that both cursors are in the graph and not on the same point
		//make sure the cursors are on the right waves..
		if (cmpstr(CsrWave(A, "DecJIL_UserInputGraph"),"Rebinned_Decay_Prof")!=0)
			Cursor/P/W=DecJIL_UserInputGraph A  Rebinned_Decay_Prof  0
		endif
		if (cmpstr(CsrWave(B, "DecJIL_UserInputGraph"),"Rebinned_Decay_Prof")!=0)
			Cursor/P /W=DecJIL_UserInputGraph B  Rebinned_Decay_Prof  (numpnts(Rebinned_Decay_Prof)-1)
		endif
	endif
	//create target waves for data
	if(createWaves)
		Duplicate/O/R=[pcsr(A),pcsr(B)] Rebinned_Decay_Prof, Model_LSQF
		Duplicate/O/R=[pcsr(A),pcsr(B)] Rebinned_Decay_ProfMeasTimes, Model_LSQFMeasTimes
	else
		Wave Model_LSQF
		Wave Model_LSQFMeasTimes
	endif
	//zero, so it is not contaminated...
	Model_LSQF=0
	//calculate values from variables:
	DecJIL_CalcModel(Model_LSQFMeasTimes, Model_LSQF)

	setDataFolder OldDf

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function DecJIL_CalcModel(xwave, ywave)
	wave xwave, ywave
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:DecayModeling
	//calculate model resonse from existing parameters...
	ywave = 0	//just checking  it should be 0
	Redimension/D ywave
	
	NVAR timeOffset=root:Packages:DecayModeling:TimeOffset
	NVAR Backg=root:Packages:DecayModeling:MeasOffset
	ywave += Backg	//this is background of measurement
	variable i
	Wave/Z  CenteredResolutionWv = root:Packages:DecayModeling:CenteredResolutionWv
	NVAR UseInstr_Response_Funct=UseInstr_Response_Funct
	NVAR Use1InputDataWave = root:Packages:DecayModeling:Use1InputDataWave
	NVAR RebinTheData = root:Packages:DecayModeling:RebinTheData
	Wave Full_Emission_Decay_Prof = root:Packages:DecayModeling:Full_Emission_Decay_Prof
	Duplicate/O Full_Emission_Decay_Prof, temp_LSQF_Wv
	Redimension/D temp_LSQF_Wv
	temp_LSQF_Wv = Backg
	variable AreaBefore, AreaAfter,ScaleByFraction, OrgNumPnts


	For(i=1;i<6;i+=1)
		NVAR UseMe=$("root:Packages:DecayModeling:UseDecayTime_"+num2str(i))
		NVAR DecayTime=$("root:Packages:DecayModeling:DecayTime_"+num2str(i))
		NVAR ScaleDecayTime=$("root:Packages:DecayModeling:SFDecayTime_"+num2str(i))
		if(Useme)
			if(Use1InputDataWave && !RebinTheData && !UseInstr_Response_Funct)
				ywave+=(x<=0) ? 0 : ScaleDecayTime*exp(-1*(x+timeOffset) /(DecayTime))
			elseif(UseInstr_Response_Funct)
				temp_LSQF_Wv+= (x<=0) ? 0 : ScaleDecayTime*exp(-1*(x+timeOffset) /(DecayTime))
			else
				ywave+=ScaleDecayTime*exp(-1*(xwave[p]+timeOffset) /(DecayTime))
			endif
		endif
	endfor
	//and now convolution with instrument response function, if necessary
	
	if(UseInstr_Response_Funct)
			AreaBefore = area(temp_LSQF_Wv)
			OrgNumPnts=numPnts(temp_LSQF_Wv)
			if(WaveExists(CenteredResolutionWv))
				Duplicate/O CenteredResolutionWv, TempResWave
			else
				Abort "problem in DECJIL_CalcModel - res. wave does not exist"
			endif
			Convolve/A tempResWave, temp_LSQF_Wv
			redimension/N=(OrgNumPnts) temp_LSQF_Wv
			AreaAfter=area(temp_LSQF_Wv)
			ScaleByFraction = AreaBefore/AreaAfter
			temp_LSQF_Wv *= ScaleByFraction
			ywave = temp_LSQF_Wv(xwave[p])
	endif
	KillWaves temp_LSQF_Wv
	setDataFolder OldDf

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function DecJIL_RecalculateIfRequested()


	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:DecayModeling

	NVAR AutoUpdate = root:Packages:DecayModeling:AutoUpdate
	
	if(Autoupdate)
		DecJIL_CalcModelManually(1)
	endif

	setDataFolder OldDf

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function DecJIL_Fitting()


	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:DecayModeling


	//Create the fitting parameters, these will have _pop added and we need to add them to list of parameters to fit...
	string ListOfFitVariables=""

	Make/O/N=0/T T_Constraints
	T_Constraints=""
	Make/D/N=0/O W_coef
	Make/O/N=(0,2) Gen_Constraints
	Make/T/N=0/O CoefNames
	CoefNames=""

	variable i,j 				//i goes through all items in list, j is 1 to 5 - populations
	//first handle coefficients which are easy - those existing all the time... Volume is the only one at this time...
//	ListOfFitVariables="DecayTime_;SFDecayTime_"	
	For(j=1;j<6;j+=1)
		NVAR UseThePop = $("root:Packages:DecayModeling:UseDecayTime_"+num2str(j))
		if(UseThePop)
				//Parameter 1
				NVAR CurVarTested = $("root:Packages:DecayModeling:DecayTime_"+num2str(j))
				NVAR FitCurVar=$("root:Packages:DecayModeling:FitDecayTime_"+num2str(j))
				NVAR CuVarMin=$("root:Packages:DecayModeling:LLDecayTime_"+num2str(j))
				NVAR CuVarMax=$("root:Packages:DecayModeling:ULDecayTime_"+num2str(j))
				if (FitCurVar)		//are we fitting this variable?
					Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
					Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
					W_Coef[numpnts(W_Coef)-1]=CurVarTested
					CoefNames[numpnts(CoefNames)-1]="DecayTime_"+num2str(j)
					T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(CuVarMax)}	
					Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames)-1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames)-1][1] = CuVarMax
				endif
				//Parameter 2
				NVAR CurVarTested = $("root:Packages:DecayModeling:SFDecayTime_"+num2str(j))
				NVAR FitCurVar=$("root:Packages:DecayModeling:FitSFDecayTime_"+num2str(j))
				NVAR CuVarMin=$("root:Packages:DecayModeling:LLSFDecayTime_"+num2str(j))
				NVAR CuVarMax=$("root:Packages:DecayModeling:ULSFDecayTime_"+num2str(j))
				if (FitCurVar)		//are we fitting this variable?
					Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
					Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
					W_Coef[numpnts(W_Coef)-1]=CurVarTested
					CoefNames[numpnts(CoefNames)-1]="SFDecayTime_"+num2str(j)
					T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(CuVarMax)}	
					Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames)-1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames)-1][1] = CuVarMax
				endif
			endif
	endfor
	
	//Now background... 
	string ListOfDataVariables="MeasOffset;TimeOffset;"
			For(i=0;i<ItemsInList(ListOfDataVariables);i+=1)
				NVAR CurVarTested = $("root:Packages:DecayModeling:"+stringfromList(i,ListOfDataVariables))
				NVAR FitCurVar=$("root:Packages:DecayModeling:Fit"+stringfromList(i,ListOfDataVariables))
				NVAR CuVarMin=$("root:Packages:DecayModeling:LL"+stringfromList(i,ListOfDataVariables))
				NVAR CuVarMax=$("root:Packages:DecayModeling:UL"+stringfromList(i,ListOfDataVariables))
				if (FitCurVar)		//are we fitting this variable?
					Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
					Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
					W_Coef[numpnts(W_Coef)-1]=CurVarTested
					CoefNames[numpnts(CoefNames)-1]=stringfromList(i,ListOfDataVariables)
					T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(CuVarMax)}		
					Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames)-1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames)-1][1] = CuVarMax
				endif
			endfor

	//Ok, all parameters should be dealt with, now the fitting... 

	//calculate model resonse from existing parameters...
	//these are waves with data created by the rest of the code... 
	Wave/Z Rebinned_Decay_ProfMeasTimes=root:Packages:DecayModeling:Rebinned_Decay_ProfMeasTimes
	Wave/Z Rebinned_Decay_Prof=root:Packages:DecayModeling:Rebinned_Decay_Prof
	Wave/Z Rebinned_Decay_ProfErrors=root:Packages:DecayModeling:Rebinned_Decay_ProfErrors
	if(!WaveExists(Rebinned_Decay_ProfMeasTimes) || !WaveExists(Rebinned_Decay_Prof)|| !WaveExists(Rebinned_Decay_ProfErrors))
		abort  "Waves for LSQF do not exist"
	endif

	if ( ((strlen(CsrWave(A))==0) || (strlen(CsrWave(B))==0) ) || (pcsr (A)==pcsr (B)) )	//this should make sure, that both cursors are in the graph and not on the same point
		//make sure the cursors are on the right waves..
		if (cmpstr(CsrWave(A, "DecJIL_UserInputGraph"),"Rebinned_Decay_Prof")!=0)
			wavestats /q Rebinned_Decay_Prof
			Cursor/P/W=DecJIL_UserInputGraph A  Rebinned_Decay_Prof  x2pnt(Rebinned_Decay_Prof, V_maxLoc )
		endif
		if (cmpstr(CsrWave(B, "DecJIL_UserInputGraph"),"Rebinned_Decay_Prof")!=0)
			Cursor/P /W=DecJIL_UserInputGraph B  Rebinned_Decay_Prof  (numpnts(Rebinned_Decay_Prof)-1)
		endif
	endif
	//copy the data for fitting waves
	Duplicate/O/R=[pcsr(A),pcsr(B)] Rebinned_Decay_Prof, LSQFFitRebinnedData
	Duplicate/O/R=[pcsr(A),pcsr(B)] Rebinned_Decay_ProfMeasTimes, LSQFFitRebinnedDataMeasTimes
	Duplicate/O/R=[pcsr(A),pcsr(B)] Rebinned_Decay_ProfErrors, LSQFFitRebinnedDataErrors
	Duplicate/O/R=[pcsr(A),pcsr(B)] Rebinned_Decay_Prof, Model_LSQF
	Duplicate/O/R=[pcsr(A),pcsr(B)] Rebinned_Decay_ProfMeasTimes, Model_LSQFMeasTimes
//	NVAR UseGeneticOptimization=root:Packages:Irena_SAD:UseGeneticOptimization
	
	
	if(numpnts(W_Coef)<1)
		DoAlert 0, "Nothing to fit, select at least 1 parameter to fit"
		return 1
	endif

	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave=W_coef/20
	Variable V_chisq
	string HoldStr=""
	For(i=0;i<numpnts(CoefficientInput);i+=1)
		HoldStr+="0"
	endfor
//	Duplicate/O IntensityForFit, MaskWaveGenOpt
//	MaskWaveGenOpt=1
//	
//	if(UseGeneticOptimization)
//		IR2D_CheckFittingParamsFnct()
//		PauseForUser IR2D_CheckFittingParams
//	endif
//	NVAR UserCanceled=root:Packages:Irena_SAD:UserCanceled
//	if (UserCanceled)
//		setDataFolder OldDf
//		abort
//	endif
//
//
//	IR2D_RecordResults("before")
	Variable V_FitError=0			//This should prevent errors from being generated
	Variable V_FitNumIters=0
//	//and now the fit...
//	if(UseGeneticOptimization)
//#if Exists("gencurvefit")
//	  	gencurvefit  /I=1 /W=ErrorForFit /M=MaskWaveGenOpt /N /TOL=0.002 /K={50,20,0.7,0.5} /X=QvectorForFit IR2D_FitFunction, IntensityForFit  , W_Coef, HoldStr, Gen_Constraints  	
//#else
//	  	GEN_curvefit("IR2D_FitFunction",W_Coef,IntensityForFit,HoldStr,x=QvectorForFit,w=ErrorForFit,c=Gen_Constraints, mask=MaskWaveGenOpt, popsize=20,k_m=0.7,recomb=0.5,iters=50,tol=0.002)	
//#endif
//	else
		FuncFit /N/Q DecJIL_FitFunction W_coef LSQFFitRebinnedData /X=LSQFFitRebinnedDataMeasTimes /W=LSQFFitRebinnedDataErrors /I=1/E=E_wave /D /C=T_Constraints 

//	endif
//
	if (V_FitError!=0)	//there was error in fitting
		DecJIL_ResetParamsAfterBadFit()
		Abort "Fitting error, check starting parameters and fitting limits" 
	else		//results OK, make sure the resulting values are set 
		variable NumParams=numpnts(CoefNames)
		string ParamName
		For(i=0;i<NumParams;i+=1)
			ParamName = CoefNames[i]
			NVAR TempVar = $(ParamName)
			TempVar=W_Coef[i]
		endfor
		NVAR CurrentChiSq = root:Packages:DecayModeling:CurrentChiSq
		NVAR NumberIterations = root:Packages:DecayModeling:NumberIterations
		print "Achieved chi-square = "+num2str(V_chisq)
		CurrentChiSq = V_chisq
		NumberIterations = V_FitNumIters
	endif
	
	variable/g AchievedChisq=V_chisq
//	IR2D_RecordResults("after")
	KillWaves T_Constraints, E_wave
	
	DecJIL_CalcModelManually(0)


	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function DecJIL_FitFunction(w,yw,xw) : FitFunc
	Wave w,yw,xw
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DecayModeling
	variable i

	Wave/T CoefNames
	variable NumParams=numpnts(CoefNames)
	string ParamName
	
	For(i=0;i<NumParams;i+=1)
		ParamName = CoefNames[i]
		NVAR TempVar = $(ParamName)
		TempVar=w[i]
	endfor
	DecJIL_CalcModelManually(0)
	Wave Model_LSQF
	yw = Model_LSQF
	
	setDataFolder oldDF
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function DecJIL_PLotLSQFData()
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DecayModeling

		NVAR Use1InputDataWave = root:Packages:DecayModeling:Use1InputDataWave
		NVAR RebinTheData = root:Packages:DecayModeling:RebinTheData
		Wave/Z Model_LSQF
		if(!WaveExists(Model_LSQF))
			return 0
		endif
		Wave/Z Model_LSQFMeasTimes
		DoWindow/F DecJIL_UserInputGraph
		NVAR CurrentChiSq = root:Packages:DecayModeling:CurrentChiSq
		NVAR NumberIterations = root:Packages:DecayModeling:NumberIterations
		NVAR FitOffset=root:Packages:DecayModeling:FitOffset
		CheckDisplayed/W=DecJIL_UserInputGraph Model_LSQF
		if(!V_Flag) 
			if(Use1InputDataWave && !RebinTheData)
				if(WaveExists(Model_LSQF))
					if(!V_Flag)
						AppendToGraph Model_LSQF
						ModifyGraph lsize(Model_LSQF)=3,rgb(Model_LSQF)=(52428,1,41942)
					endif
				endif
			else
				if(WaveExists(Model_LSQF) && WaveExists(Model_LSQFMeasTimes))
					CheckDisplayed Model_LSQF
					if(!V_Flag)
						AppendToGraph Model_LSQF vs Model_LSQFMeasTimes
						ModifyGraph lsize(Model_LSQF)=3,rgb(Model_LSQF)=(52428,1,41942)
					endif
				endif
			endif
		endif
		Duplicate/O Model_LSQF, NormalizedResidual
		Wave/Z FitRebinnedData = root:Packages:DecayModeling:LSQFFitRebinnedData
		Wave/Z FitRebinnedDataErrors = root:Packages:DecayModeling:LSQFFitRebinnedDataErrors
		Wave/Z FitRebinnedDataMeasTimes = root:Packages:DecayModeling:LSQFFitRebinnedDataMeasTimes
		if(!WaveExists(FitRebinnedData))
			Wave/Z Rebinned_Decay_ProfMeasTimes=root:Packages:DecayModeling:Rebinned_Decay_ProfMeasTimes
			Wave/Z Rebinned_Decay_Prof=root:Packages:DecayModeling:Rebinned_Decay_Prof
			Wave/Z Rebinned_Decay_ProfErrors=root:Packages:DecayModeling:Rebinned_Decay_ProfErrors
			if(!WaveExists(Rebinned_Decay_ProfMeasTimes) || !WaveExists(Rebinned_Decay_Prof)|| !WaveExists(Rebinned_Decay_ProfErrors))
				abort  "Waves for LSQF do not exist"
			endif
			Duplicate/O/R=[pcsr(A),pcsr(B)] Rebinned_Decay_Prof, LSQFFitRebinnedData
			Duplicate/O/R=[pcsr(A),pcsr(B)] Rebinned_Decay_ProfMeasTimes, LSQFFitRebinnedDataMeasTimes
			Duplicate/O/R=[pcsr(A),pcsr(B)] Rebinned_Decay_ProfErrors, LSQFFitRebinnedDataErrors
			Wave/Z FitRebinnedData = root:Packages:DecayModeling:LSQFFitRebinnedData
			Wave/Z FitRebinnedDataErrors = root:Packages:DecayModeling:LSQFFitRebinnedDataErrors
			Wave/Z FitRebinnedDataMeasTimes = root:Packages:DecayModeling:LSQFFitRebinnedDataMeasTimes		
		endif
		
//		Wave Offset = root:Packages:DecayModeling:Offset
//		NVAR CurrentChiSqMEM = root:Packages:MaxEntTempFldr:CurrentChiSq
//		CurrentChiSq = CurrentChiSqMEM
		NVAR Bckg=root:Packages:DecayModeling:Bckg
	 	//creae normizalize residual here
	 	NormalizedResidual = (FitRebinnedData - Model_LSQF) / FitRebinnedDataErrors
	 	Duplicate/O NormalizedResidual, tmpWv
	 	tmpWv=tmpWv^2
	 	CurrentChiSq = sum(tmpWv)
	 	KillWaves TmpWv
		
		CheckDisplayed /W=DecJIL_UserInputGraph NormalizedResidual
		ModifyGraph/W=DecJIL_UserInputGraph mirror=1
		if(!V_Flag) 
			AppendToGraph /W=DecJIL_UserInputGraph/L=ChisquaredAxis   NormalizedResidual vs FitRebinnedDataMeasTimes
			ModifyGraph/W=DecJIL_UserInputGraph /Z  axisEnab(left)={0.15,1}
			ModifyGraph/W=DecJIL_UserInputGraph /Z axisEnab(right)={0.15,1}
			ModifyGraph/W=DecJIL_UserInputGraph /Z  lblMargin(top)=30
			ModifyGraph/W=DecJIL_UserInputGraph /Z  axisEnab(ChisquaredAxis)={0,0.15}
			ModifyGraph/W=DecJIL_UserInputGraph /Z  freePos(ChisquaredAxis)=0
			Label/W=DecJIL_UserInputGraph /Z  ChisquaredAxis "Residuals"
			ModifyGraph/W=DecJIL_UserInputGraph /Z  lblPos(ChisquaredAxis)=50,lblLatPos=0
			ModifyGraph/W=DecJIL_UserInputGraph /Z  mirror(ChisquaredAxis)=1
			SetAxis/W=DecJIL_UserInputGraph /Z  /A/E=2 ChisquaredAxis
			ModifyGraph/W=DecJIL_UserInputGraph /Z  nticks(ChisquaredAxis)=3
			ModifyGraph/W=DecJIL_UserInputGraph /Z  mode(NormalizedResidual)=3,marker(NormalizedResidual)=19
			ModifyGraph/W=DecJIL_UserInputGraph /Z  msize(NormalizedResidual)=1
		endif
			TextBox/W=DecJIL_UserInputGraph/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	
	setDataFolder oldDF
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function DecJIL_FormatGraphTabChange(Curtab)
	variable Curtab
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DecayModeling
	DoWindow DecJIL_UserInputGraph
	if(!V_Flag)
		return 1
	endif
	if(Curtab==1)			//LSQF, remove MaxEnt
		RemoveFromGraph/W=DecJIL_UserInputGraph /Z Model_Lifetime_Dist, Model_Fit_Function
		DecJIL_PLotLSQFData()
	elseif(Curtab==0)		//MaxEnt, remove LSQF
		RemoveFromGraph/W=DecJIL_UserInputGraph /Z Model_LSQF
		NVAR NumberIterations = root:Packages:DecayModeling:NumberIterations
		Wave/Z Model_Lifetime_Dist=root:Packages:DecayModeling:Model_Lifetime_Dist
		if(!WaveExists(Model_Lifetime_Dist))
			return 0
		endif
		DecJIL_UpdateGraph(Model_Lifetime_Dist, NumberIterations)
	
	endif
	

	setDataFolder oldDF


end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function DecJIL_ResetParamsAfterBadFit()
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DecayModeling
	variable i
	Wave/Z w=root:Packages:DecayModeling:CoefficientInput
	Wave/T/Z CoefNames=root:Packages:DecayModeling:CoefNames		//text wave with names of parameters

	if(!WaveExists(w) || !WaveExists(CoefNames))
		abort
	endif
	
	variable NumParams=numpnts(CoefNames)
	string ParamName
	
	For(i=0;i<NumParams;i+=1)
		ParamName = CoefNames[i]
		NVAR TempVar = $(ParamName)
		TempVar=w[i]
	endfor

	DecJIL_CalcModelManually(0)

	setDataFolder oldDF
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
