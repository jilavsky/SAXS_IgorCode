#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.2

// This is part of package called "Clementine" for modeling of decay kinetics using Maximum Entropy method
// Jan Ilavsky, PhD June 1 2008
// version 1.2  July 7, 2011

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function DecJIL_Opus(Model, Data)			//ModelDist -> Decay
	Wave Model, Data

	Wave Gmatrix=root:Packages:DecayModeling:Gmatrix
	MatrixOp/O Data = Gmatrix x Model
	
end 
//*****************************************************************************************************************
//*****************************************************************************************************************
Function DecJIL_Tropus(Data,Model)	//Measured Data -> model dist
	Wave Data,Model
	Wave Gmatrix=root:Packages:DecayModeling:Gmatrix
	MatrixOp/O Model = Gmatrix^h x Data	
end 

//*****************************************************************************************************************
//*****************************************************************************************************************
Function DecJIL_UpdateGraph(CurrentModel, iteration)
		wave CurrentModel
		variable iteration  

	DoWIndow DecJIL_UserInputGraph
	if(!V_Flag)
		return 1
	endif
	string OldDf
	OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:DecayModeling
		
		Wave Model_Lifetime_Dist=root:Packages:DecayModeling:Model_Lifetime_Dist
		Wave DecayTimes=root:Packages:DecayModeling:DecayTimes
		NVAR CurrentChiSq = root:Packages:DecayModeling:CurrentChiSq
		NVAR NumberIterations = root:Packages:DecayModeling:NumberIterations
		NVAR FitOffset=root:Packages:DecayModeling:FitOffset
		NumberIterations = iteration
		CheckDisplayed /W=DecJIL_UserInputGraph Model_Lifetime_Dist
		if(!V_Flag) 
			AppendToGraph/R/T Model_Lifetime_Dist vs DecayTimes
			ModifyGraph /W=DecJIL_UserInputGraph log(top)=1
			ModifyGraph mode(Model_Lifetime_Dist)=5,hbFill(Model_Lifetime_Dist)=4
			ModifyGraph lsize(Model_Lifetime_Dist)=3
			ModifyGraph rgb(Model_Lifetime_Dist)=(0,65535,0)
		endif
		if(FitOffset && V_Flag)		//last bin is background, need to set axis on right windpendent of this value...
			Wavestats/Q/R=[0,numpnts(Model_Lifetime_Dist)-2] Model_Lifetime_Dist
			SetAxis right V_min,V_max
		endif		
		Duplicate/O Model_Lifetime_Dist, Model_Fit_Function
		Duplicate/O FitRebinnedData, NormalizedResidual
		Wave FitRebinnedData = root:Packages:DecayModeling:FitRebinnedData
		Wave FitRebinnedDataErrors = root:Packages:DecayModeling:FitRebinnedDataErrors
		Wave FitRebinnedDataMeasTimes = root:Packages:DecayModeling:FitRebinnedDataMeasTimes
		Wave Offset = root:Packages:DecayModeling:Offset
		NVAR CurrentChiSqMEM = root:Packages:MaxEntTempFldr:CurrentChiSq
		CurrentChiSq = CurrentChiSqMEM
		DecJIL_Opus(Model_Lifetime_Dist, Model_Fit_Function)
		NVAR Bckg=root:Packages:DecayModeling:Bckg
	 	if(!FitOffset)
 			Model_Fit_Function+=Bckg				//set the last value to user defined background
 		else
 			Offset = Model_Lifetime_Dist[inf]
	 	endif
	 	//creae normizalize residual here
	 	NormalizedResidual = (FitRebinnedData - Model_Fit_Function) / FitRebinnedDataErrors
		
		CheckDisplayed /W=DecJIL_UserInputGraph Model_Fit_Function
		if(!V_Flag) 
			AppendToGraph Model_Fit_Function vs FitRebinnedDataMeasTimes
			ModifyGraph rgb(Model_Fit_Function)=(0,0,65535)		
			ModifyGraph lsize(Model_Fit_Function)=3
		endif
		NVAR FitOffset = root:Packages:DecayModeling:FitOffset
 		NVAR Bckg = root:Packages:DecayModeling:Bckg
 		if(FitOffset)
			Bckg = Model_Lifetime_Dist[numpnts(Model_Lifetime_Dist)-1]				//set the last value to user defined background
		endif
		CheckDisplayed /W=DecJIL_UserInputGraph NormalizedResidual
		if(!V_Flag) 
			AppendToGraph /W=DecJIL_UserInputGraph/L=ChisquaredAxis   NormalizedResidual vs FitRebinnedDataMeasTimes
			ModifyGraph/W=DecJIL_UserInputGraph axisEnab(left)={0.15,1}
			ModifyGraph/W=DecJIL_UserInputGraph axisEnab(right)={0.15,1}
			ModifyGraph/W=DecJIL_UserInputGraph lblMargin(top)=30
			ModifyGraph/W=DecJIL_UserInputGraph axisEnab(ChisquaredAxis)={0,0.15}
			ModifyGraph/W=DecJIL_UserInputGraph freePos(ChisquaredAxis)=0
			Label/W=DecJIL_UserInputGraph ChisquaredAxis "Residuals"
			ModifyGraph/W=DecJIL_UserInputGraph lblPos(ChisquaredAxis)=50,lblLatPos=0
			ModifyGraph/W=DecJIL_UserInputGraph mirror(ChisquaredAxis)=1
			SetAxis/W=DecJIL_UserInputGraph /A/E=2 ChisquaredAxis
			ModifyGraph/W=DecJIL_UserInputGraph nticks(ChisquaredAxis)=3
			ModifyGraph/W=DecJIL_UserInputGraph mode(NormalizedResidual)=3,marker(NormalizedResidual)=19
			ModifyGraph/W=DecJIL_UserInputGraph msize(NormalizedResidual)=1
		endif
			TextBox/W=DecJIL_UserInputGraph/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
		
		//This function is run to update data for graphing purposes
		//do whatever you need here to update your graph after each iteration
		// typically one needs to updae graph, calculate chisquare and display it and may be calculate and display residuals.
		//if you need to change parameters, you have to modify the FuncRef function MEM_UpdateDataForGrph to reflect the changes
	SetDataFolder OldDf

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function DecJIL_RunMEMFittingOnData()

	string OldDf
	OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:DecayModeling
	//First lets copy data between the cursors and create the data set to be fitted... 
	//check for the presence of the curosors on the right wave, if not set, set it yourself...
	DoWIndow DecJIL_UserInputGraph
	if(!V_Flag)
		Abort "No input data window"
	endif
	DoWindow/F DecJIL_UserInputGraph				//pulls the control graph, in case it is not the top...
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
	//copy the data for fitting waves
	Duplicate/O/R=[pcsr(A),pcsr(B)] Rebinned_Decay_Prof, FitRebinnedData
	Duplicate/O/R=[pcsr(A),pcsr(B)] Rebinned_Decay_ProfMeasTimes, FitRebinnedDataMeasTimes
	Duplicate/O/R=[pcsr(A),pcsr(B)] Rebinned_Decay_ProfErrors, FitRebinnedDataErrors
//	Duplicate/O/R=[pcsr(A),pcsr(B)] Rebinned_Decay_Prof, InitialModelBckg
//	//fix the resolution function here to be compatible with the above selected data... 
//	Duplicate/O/R=[pcsr(A),pcsr(B)] Rebinned_Decay_Prof, FitRebinnedUserResData
//	Wave OriginalFullUserResData = root:Packages:DecayModeling:OriginalFullUserResData
//	FitRebinnedUserResData = OriginalFullUserResData(FitRebinnedDataMeasTimes[p])
	//6 21 2008 JIL - this wave seems not needed for anything and actually seem illogical to me at this time
	//correct for the beckground...
	NVAR Bckg = root:Packages:DecayModeling:Bckg	
	NVAR FitOffset=root:Packages:DecayModeling:FitOffset
	if(!FitOffset)
		FitRebinnedData = FitRebinnedData-Bckg
	endif
	NVAR TargetChiSquared = root:Packages:DecayModeling:TargetChiSquared
	TargetChiSquared = numpnts(FitRebinnedData)
 	//*****
 	//fix the errors to reflect user multiplier
 	NVAR errMultipl = root:Packages:DecayModeling:ErrorsMultiplier
 	FitRebinnedDataErrors = FitRebinnedDataErrors * errMultipl
 	//Now generate the distribution of decay times...
 	NVAR numOfPoints = root:Packages:DecayModeling:TauSteps
 	NVAR TauMin = root:Packages:DecayModeling:TauMin
 	NVAR TauMax = root:Packages:DecayModeling:TauMax
 	DecJIL_GenerateDecayTimesDist(TauMin,TauMax,numOfPoints)
 	Wave DecayTimes=root:Packages:DecayModeling:DecayTimes
 	Duplicate/O DecayTimes, Model_Lifetime_Dist
 	//And now generate the G matrix
 	Make/O/D/N=(numOfPoints,numpnts(FitRebinnedData)) Gmatrix
 	DecJIL_GenerateGMatrix(Gmatrix,FitRebinnedDataMeasTimes,DecayTimes)
 	//And now run MaxEnt
	NVAR MaxEntSkyBckg = root:Packages:DecayModeling:MaxEntSkyBckg
//	InitialModelBckg = MaxEntSkyBckg
 	Model_Lifetime_Dist=MaxEntSkyBckg
 	NVAR FitOffset=root:Packages:DecayModeling:FitOffset
 	if(FitOffset)
 		Model_Lifetime_Dist[numpnts(Model_Lifetime_Dist)-1]=Bckg				//set the last value to user defined background
 	endif
	NVAR MaximumNumIter = root:Packages:DecayModeling:MaximumNumIter
	NVAR MaxEntStabilityParam = root:Packages:DecayModeling:MaxEntStabilityParam
	variable iteration
	iteration = MEM_MaximumEntropy(FitRebinnedData,FitRebinnedDataErrors,MaxEntSkyBckg,MaximumNumIter,Model_Lifetime_Dist,MaxEntStabilityParam,DecJIL_Opus,DecJIL_Tropus,DecJIL_UpdateGraph)
	
	//********
	//Sky background should be about 1% of maxium of the result
	Wavestats/Q Model_Lifetime_Dist
		NVAR SuggestedSkyBackground = root:Packages:DecayModeling:SuggestedSkyBackground
		SuggestedSkyBackground = 0.001*V_max
	If((0.01*V_max)<MaxEntSkyBckg || (0.0005* V_max)>MaxEntSkyBckg)
		Button SetMaxEntSkyBckg win=DecJIL_InputPanel, fColor=(65535,0,0)
	endif
	DecJIL_UpdateGraph(Model_Lifetime_Dist, iteration)
	SetDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function DecJIL_GenerateDecayTimesDist(startDecTime,endDecTime,NumofPoints)
	variable startDecTime,endDecTime,NumofPoints
	
	NVAR FitOffset =root:Packages:DecayModeling:FitOffset
	variable tempNumPoints
	tempNumPoints=NumofPoints
	if(FitOffset)
		tempNumPoints+=1
	endif
	make /D/O/N=(tempNumPoints) DecayTimes, temp		//this part creates the distribution of radia, last point is the background
	temp=log(startDecTime)+p*((log(endDecTime)-log(startDecTime))/(numOfPoints-1))
	DecayTimes=10^temp
	killWaves temp
end

//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
Function DecJIL_GenerateGMatrix(Gmatrix,MeasurementTimes,DecayTimes)
		Wave Gmatrix		//result, will be checked if it is needed to recalculate, redimensioned and reculated, if necessary
		Wave MeasurementTimes			//Q vectors, in A-1
		Wave DecayTimes			//radia in A
															//Gmatrix should be M x N points
		variable M=numpnts(MeasurementTimes)
		variable N=numpnts(DecayTimes)

		redimension/D/N=(M,N) Gmatrix				//redimension G matrix to right size	
		variable i, j
		Wave Full_Emission_Decay_Prof = root:Packages:DecayModeling:Full_Emission_Decay_Prof
		Wave/Z  CenteredResolutionWv = root:Packages:DecayModeling:CenteredResolutionWv
		NVAR UseInstr_Response_Funct=UseInstr_Response_Funct
		NVAR Use1InputDataWave = root:Packages:DecayModeling:Use1InputDataWave

		variable AreaBefore, AreaAfter,ScaleByFraction
		if(Use1InputDataWave)
			if(WaveExists(CenteredResolutionWv))
				Duplicate/O CenteredResolutionWv, TempResWave
			endif
			Duplicate/O Full_Emission_Decay_Prof, tempGmatrixVector
			redimension/D tempGmatrixVector
			For(i=0;i<N;i+=1)
				tempGmatrixVector = (x<=0) ? 0 : exp(-1*x/DecayTimes[i])		//this needs to be padded to 0 at negative times... Or causes all sorts of problems. 
				AreaBefore = area(tempGmatrixVector)
	//			MatrixOp/O tempGmatrixVector = Convolve (tempResWave, tempGmatrixVector,4)
				if(UseInstr_Response_Funct)
					//OK, this does nto work due to resolution function in reality tipping the short-time data down. This is due to integration with 0 values at lower times. 
//					Make/O/N=(2*numpnts(tempGmatrixVector)) TempWvGvec
//					TempWvGvec=0
//					TempWvGvec[numpnts(tempGmatrixVector), numpnts(TempWvGvec)-1]=tempGmatrixVector[p-numpnts(tempGmatrixVector)]
//					 Convolve/A tempResWave, TempWvGvec
//					 tempGmatrixVector = TempWvGvec[numpnts(tempGmatrixVector)+p]
			//	  	 MatrixOp/O tempGmatrixVector = Convolve (tempResWave, tempGmatrixVector,4)
					 Convolve/A tempResWave, tempGmatrixVector
					// Convolve tempResWave, tempGmatrixVector
			//		 redimension/N=(numpnts(Full_Emission_Decay_Prof)) tempGmatrixVector
					 AreaAfter=area(tempGmatrixVector)
					 ScaleByFraction = AreaBefore/AreaAfter
					 tempGmatrixVector *= ScaleByFraction
				endif
				Gmatrix[][i]=tempGmatrixVector(MeasurementTimes[p])
//				abort
			endfor
		else			//also have time wave... 
			Duplicate/O MeasurementTimes, tempGmatrixVector
			For(i=0;i<N;i+=1)
				tempGmatrixVector = exp(-1*MeasurementTimes[p]/DecayTimes[i])
	//			MatrixOp/O tempGmatrixVector = Convolve (tempResWave, tempGmatrixVector,4)
	//			if(UseInstr_Response_Funct)
	//				 Convolve/A tempResWave, tempGmatrixVector
	//				 redimension/N=(numpnts(Full_Emission_Decay_Prof)) tempGmatrixVector
	//			endif
				Gmatrix[][i]=tempGmatrixVector[p]
			endfor
		
		endif
		//if FitOffset Last value in Measurement times is background, set to 1 the response function 
		NVAR FitOffset = root:Packages:DecayModeling:FitOffset
		if(FitOffset)
			Duplicate/O Full_Emission_Decay_Prof, tempGmatrixVector
			redimension/D tempGmatrixVector
			tempGmatrixVector= 1
//			if(UseInstr_Response_Funct)
//			 	Convolve/A tempResWave, tempGmatrixVector
//			endif
			//Gmatrix[][N-1] = tempGmatrixVector[p]	
			Gmatrix[][N-1] = 1	
		endif
		Killwaves/Z TempResWave, tempGmatrixVector
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//Function DecJIL_SuggestSkyBackground()
//
//	string OldDf
//	OldDf=GetDataFolder(1)
//	SetDataFolder root:Packages:DecayModeling
//
////	wave DataWv=root:Packages:DecayModeling:Full_Emission_Decay_Prof
////	Wave resol=root:Packages:DecayModeling:CenteredResolutionWv
////	Duplicate/O DataWv, tempDataWv
////	variable someTime = pnt2x(tempDataWv, 5 )
////	tempDataWv = exp(-1*x/(someTime))
////	Convolve/A resol, tempDataWv
//	NVAR MaxEntSkyBckg = root:Packages:DecayModeling:MaxEntSkyBckg
//	Wavestats/Q tempDataWv
//	MaxEntSkyBckg = V_max/1000
////	killwaves tempDataWv
//	setDataFolder OldDf
//end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

////*****************************************************************************************************************
//
////to test, select data (measured counts witrh x axis set) and run the command:
////   JIL_RebinData(400,"path:to:data", 1 )
//// RemovePeak = 0 will leave data before peak in the data
//// if set to 1 the data before peak will be removed. 
//Function DecJIL_RebinData(ToPoints,MeasData, removePeak)
//	variable ToPoints, removePeak
//	wave MeasData
//	
//	string OldDf=GetDataFolder(1)
//	SetDataFolder root:Packages:DecayModeling
//	Duplicate/O MeasData, TempMeasData
//	if(RemovePeak)
//		WaveStats/Q TempMeasData
//		variable tmpStart, tmpdelta
//		tmpStart = V_maxloc
//		tmpDelta = deltaX(TempMeasData)
//		DeletePoints 0,x2pnt(TempMeasData, V_maxloc ), TempMeasData
//		SetScale/P x tmpStart,tmpDelta,"s", TempMeasData
//	endif
//	
//	variable startTime, endTime, TotalTime, peakTime, keepPointsBeforePeak
//	wavestats/Q TempMeasData
//	
//	startTime=(leftx(TempMeasData))
//	peakTime=V_maxloc
//	keepPointsBeforePeak = x2pnt(TempMeasData, peakTime)
//	endTime=rightx(TempMeasData)
//	variable NumPointsToReduce = numpnts(TempMeasData)	- keepPointsBeforePeak			//num points to reduce
//	variable AveRatioToReduce = floor( NumPointsToReduce / ToPoints)	   					//average number of points reduction, max be twice as much... 
//	variable binNewPoints = round(ToPoints / AveRatioToReduce)							//this is how many points will be binned 1x, 2x, 3x, etc...
//	variable neededNewPoints =round( NumPointsToReduce /  AveRatioToReduce)
//	make/O/D/N=(neededNewPoints+keepPointsBeforePeak) Rebinned_Decay_ProfMeasTimes, Rebinned_Decay_Prof, Rebinned_Decay_ProfErrors
//	Rebinned_Decay_ProfMeasTimes=0
//	Rebinned_Decay_Prof=0
//	Rebinned_Decay_ProfErrors=0
//	if(keepPointsBeforePeak>0)
//		Rebinned_Decay_ProfMeasTimes[0,keepPointsBeforePeak-1]=pnt2x(TempMeasData, p)
//		Rebinned_Decay_Prof [0,keepPointsBeforePeak-1]= TempMeasData[p]
//		Rebinned_Decay_ProfErrors[0,keepPointsBeforePeak-1] = sqrt(TempMeasData[p])
//	endif
//	variable i, j
//
//	variable curOldPoint=0, curNewPoint=0, NumOfData=0, FinishedPoints=0
//		
//	variable binByPnts=1
//	curOldPoint = keepPointsBeforePeak	
//	For(i=keepPointsBeforePeak;i<(keepPointsBeforePeak+neededNewPoints);i+=1)				//goes through left points on new wave to fill in.
//			if(FinishedPoints>binNewPoints)
//				binByPnts+=1
//				FinishedPoints=0
//			endif
//			NumOfData=0
//			For(j=0;j<binByPnts;j+=1)			//this this is num of old points to summ
//				Rebinned_Decay_ProfMeasTimes[i]+= pnt2x(TempMeasData, curOldPoint )
//				Rebinned_Decay_Prof[i]+=TempMeasData[curOldPoint]
//				Rebinned_Decay_ProfErrors[i]+=(TempMeasData[curOldPoint])^2
//				NumOfData+=1
//				curOldPoint+=1
//				FinishedPoints+=1
//			endfor			
//			Rebinned_Decay_ProfMeasTimes[i]/=NumOfData
//			Rebinned_Decay_Prof[i]/=NumOfData
//			if(NumOfData>1)
//				Rebinned_Decay_ProfErrors[i] = sqrt(abs(Rebinned_Decay_ProfErrors[i]/ NumOfData - (Rebinned_Decay_Prof[i])^2))
//			else
//				Rebinned_Decay_ProfErrors[i] = sqrt(Rebinned_Decay_Prof[i])
//			endif
//	endfor
//	variable newend=BinarySearch(Rebinned_Decay_ProfMeasTimes, endTime )	
//	if(Newend>0)
//		DeletePoints newend,numpnts(Rebinned_Decay_ProfMeasTimes), Rebinned_Decay_ProfMeasTimes, Rebinned_Decay_Prof, Rebinned_Decay_ProfErrors
//	endif
//	Duplicate/O Rebinned_Decay_ProfMeasTimes, OrgRebinned_Decay_ProfMeasTimes
//	Duplicate /O Rebinned_Decay_Prof, OrgRebinned_Decay_Prof
//	Duplicate/O Rebinned_Decay_ProfErrors, OrgRebinned_Decay_ProfErrors
//	NVAR ErrMultiplier = root:Packages:DecayModeling:ErrorsMultiplier
//	Rebinned_Decay_ProfErrors = ErrMultiplier * OrgRebinned_Decay_ProfErrors
//
//	KillWaves TempMeasData
//	
//	setDataFolder OldDf
//end
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//Function DecJIL_RebinData1(ToPoints,MeasData, removePeak, RebinTheData)
//	variable ToPoints, removePeak, RebinTheData
//	wave MeasData

Function DECJIL_RebinDataIfAppropriate()

	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:DecayModeling
	
	NVAR RebinTheData= root:Packages:DecayModeling:RebinTheData
	NVAR ToPoints=root:Packages:DecayModeling:numOfPoints
	NVAR RemovePeak=root:Packages:DecayModeling:RemovePrePeakArea
	NVAR Use1InputDataWave = root:Packages:DecayModeling:Use1InputDataWave
	NVAR UseErrorInputDataWave = root:Packages:DecayModeling:UseErrorInputDataWave
	NVAR ResetTime0=root:Packages:DecayModeling:ResetTime0
	
	Wave/Z MeasData=root:Packages:DecayModeling:Full_Emission_Decay_Prof
	if(!WaveExists(MeasData))
		abort
	endif
	Wave/Z MeasDataTimes=root:Packages:DecayModeling:OriginalFullUserTimeData
	Wave/Z MeasDataErrors = root:Packages:DecayModeling:OriginalFullUserErrorsData
//	Wave root:Packages:DecayModeling:OriginalFullUserResData

	//first let's remove the pre-peak area, if necessary... 	
	Duplicate/O MeasData, TempMeasData
	variable tmpStartPnt, tmpStart, tmpdelta
	WaveStats/Q TempMeasData		//keep some data before the peak to make sure we can model them if necessary...
	variable maxPos=V_maxloc
	variable maxPosPoint=x2pnt(TempMeasData, maxPos )
	findlevel/Q TempMeasData, (V_max/2)
	if(V_levelX<maxPos)
		tmpStartPnt =  x2pnt(TempMeasData, V_levelX ) 
		maxPosPoint -=tmpStartPnt
		tmpStart = V_levelX
	else
		tmpStartPnt=0
		maxPosPoint=0
	endif
	tmpDelta = deltaX(TempMeasData)
	variable tempStartNegTime=-1*(maxPosPoint-1)*tmpDelta
	if(RemovePeak && tmpStartPnt>0)
		DeletePoints 0,tmpStartPnt, TempMeasData
		if(ResetTime0)
			SetScale/P x tempStartNegTime,tmpDelta,"s", TempMeasData			//changed to fix problem when time does nto start correctly... Is this correct?	
			// JIL 7/7/2011
		else
			SetScale/P x tmpStart,tmpDelta,"s", TempMeasData
		endif
		if(!Use1InputDataWave)		//we have time wave...
			Duplicate/O MeasDataTimes, TempMeasDataTimes
			DeletePoints 0,tmpStartPnt, TempMeasDataTimes		//do not worry about x-scaling, it is meaningless....
		endif
		if(UseErrorInputDataWave)		//we have error wave also...
			Duplicate/O MeasDataErrors, TempMeasDataErrors
			DeletePoints 0,tmpStartPnt, TempMeasDataErrors
			if(ResetTime0)
				SetScale/P x tempStartNegTime,tmpDelta,"s", TempMeasDataErrors		//move x-scaling, in case it was being used..
			else
				SetScale/P x tmpStart,tmpDelta,"s", TempMeasDataErrors		//move x-scaling, in case it was being used..
			endif		
		endif
	else	//do not remove peak, but still need to have the data..
		//DeletePoints 0,tmpStart, TempMeasData
		if(!Use1InputDataWave)		//we have time wave...
			Duplicate/O MeasDataTimes, TempMeasDataTimes
		endif
		if(UseErrorInputDataWave)		//we have error wave also...
			Duplicate/O MeasDataErrors, TempMeasDataErrors
			if(ResetTime0)
				SetScale/P x tempStartNegTime,tmpDelta,"s", TempMeasDataErrors		//move x-scaling, in case it was being used..
			else
				SetScale/P x tmpStart,tmpDelta,"s", TempMeasDataErrors		//move x-scaling, in case it was being used..
			endif		
			
		endif
	endif
	//OK, now we have TempMeasDataxxxx waves, may be. 
	
	//and here we have new time bins, on log scale over the range of data user provided.... 
	if(RebinTheData)
		//Log rebinning, if requested.... 
		//create log distribution of points...
		make/O/D/N=(ToPoints) tempNewLogDist, tempNewLogDistBinWidth
		NVAR LogBinParameter=root:Packages:DecayModeling:LogBinParameter
		tempNewLogDist = exp((0.8*LogBinParameter/100) * p)		//this is log distribution, but over wrong range... 
		variable tempLogDistRange = tempNewLogDist[numpnts(tempNewLogDist)-1] - tempNewLogDist[0]
		tempNewLogDist =((tempNewLogDist-1)/tempLogDistRange)
		variable startTime, endTime, BinHighEdge
		if(Use1InputDataWave)		//we have time wave...
			startTime=(leftx(TempMeasData))
			endTime=rightx(TempMeasData)
		else		//have time wave
			
			startTime=TempMeasDataTimes[0]
			endTime=TempMeasDataTimes[numpnts(TempMeasDataTimes)-1]
		endif
		tempNewLogDist = startTime + (tempNewLogDist[p])*((endTime-startTime))
		tempNewLogDistBinWidth = tempNewLogDist[p+1] - tempNewLogDist[p]
		
		make/O/D/N=(ToPoints) Rebinned_Decay_ProfMeasTimes, Rebinned_Decay_Prof, Rebinned_Decay_ProfErrors
		
		variable i, j, startIntg
		FindLevel /P/Q tempNewLogDist, tmpDelta
		
//print "DeltaX = "+ num2str(V_levelX)		
		if(V_levelX>0)
			//steps in log dist are smaller than measured times. Need to interpolate... 
			if(Use1InputDataWave)		// time is wave scaling...
				For(i=0;i<V_levelX;i+=1)
					Rebinned_Decay_ProfMeasTimes[i] = tempNewLogDist[i]
					Rebinned_Decay_Prof[i]=TempMeasData(Rebinned_Decay_ProfMeasTimes[i] )
//print "point " + num2str(i)+" inserted value for time " + 	num2str(Rebinned_Decay_ProfMeasTimes[i])				
					if(!UseErrorInputDataWave)		//no error wave....
						Rebinned_Decay_ProfErrors[i] = sqrt(Rebinned_Decay_Prof[i])
					else	//error wave...
						Rebinned_Decay_ProfErrors[i] = TempMeasDataErrors(Rebinned_Decay_ProfMeasTimes[i])		//assume Error has same x-scaling
					endif
				endfor
				startIntg = ceil(V_levelX)
			else		//this is case when we have both smaller min stepping than available and have time wave...
				For(i=0;i<V_levelX;i+=1)
					Rebinned_Decay_ProfMeasTimes[i] = tempNewLogDist[i]
					Rebinned_Decay_Prof[i]= interp(Rebinned_Decay_ProfMeasTimes[i], TempMeasDataTimes, TempMeasData )
					if(!UseErrorInputDataWave)		//no error wave....
						Rebinned_Decay_ProfErrors[i] = sqrt(Rebinned_Decay_Prof[i])
					else	//error wave...
						Rebinned_Decay_ProfErrors[i] = interp(Rebinned_Decay_ProfMeasTimes[i], TempMeasDataTimes, TempMeasDataErrors )
					endif
				endfor
				startIntg = ceil(V_levelX)
			endif
		else 
			startIntg = 0
		endif
		variable cntPoints, tempMeasVal,TempMeasTime,tempMeasVal2, tempMeasError, BinLowEdge
		
		//first case when user uses input as scaling...
			if(Use1InputDataWave)		// time is wave scaling...
					cntPoints=0
					tempMeasVal=0
					TempMeasTime=0
					tempMeasVal2=0
					tempMeasError=0
					j=0			//counter for points in measured DATA
					//find first j to use 
					if(startIntg>0)
						BinLowEdge = (tempNewLogDist[startIntg]+tempNewLogDist[startIntg-1])/2	
						j = ceil(x2pnt(TempMeasData, BinLowEdge ))
					endif
//	print "Start i pont "+ num2str(startIntg)				
					For(i=startIntg;i<numpnts(tempNewLogDist);i+=1)
						BinHighEdge = (tempNewLogDist[i]+tempNewLogDist[i+1])/2		//bin center + 1/2 distance to the next bin center
						Do
							cntPoints+=1
							tempMeasVal+=TempMeasData[j]
							TempMeasTime+=pnt2x(TempMeasData, j)
							tempMeasVal2+=TempMeasData[j]^2		
							if(UseErrorInputDataWave)		//no error wave....
								tempMeasError += TempMeasDataErrors[j]
							endif
							j+=1
						while (pnt2x(TempMeasData, j )<BinHighEdge)
							Rebinned_Decay_ProfMeasTimes[i] = TempMeasTime / cntPoints
							Rebinned_Decay_Prof [i] = tempMeasVal/cntPoints
							if(UseErrorInputDataWave)		//no error wave....
								Rebinned_Decay_ProfErrors[i]  =  tempMeasError / cntPoints
							else
								if(cntPoints>1)
									Rebinned_Decay_ProfErrors[i] = 0.66*sqrt(sqrt(abs(tempMeasVal2 - tempMeasVal^2 )/ (cntPoints-1)^2))
								//	print "cnt larger than 1 for "+num2str(i)
								else
									Rebinned_Decay_ProfErrors[i] =sqrt(tempMeasVal)
								endif							
							endif
//	print "Point number ;   "+num2str(i) + "   summed points  "+num2str(cntPoints)						
							cntPoints=0
							tempMeasVal=0
							TempMeasTime=0
							tempMeasVal2=0
							tempMeasError=0
				endfor
			else		//user uses time wave for input
					cntPoints=0
					tempMeasVal=0
					TempMeasTime=0
					tempMeasVal2=0
					tempMeasError=0
					j=0			//counter for points in measured DATA
					For(i=startIntg;i<numpnts(tempNewLogDist);i+=1)
						BinHighEdge = tempNewLogDist[i]+tempNewLogDistBinWidth[i]/2		//bin center + 1/2 distance to the next bin center
						Do
							cntPoints+=1
							tempMeasVal+=TempMeasData[j]
							TempMeasTime+=TempMeasDataTimes[j]
							tempMeasVal2+=TempMeasData[j]^2		
							if(UseErrorInputDataWave)		//no error wave....
								tempMeasError += TempMeasDataErrors[j]
							endif
							j+=1
						while (TempMeasDataTimes[j]<BinHighEdge)
							Rebinned_Decay_ProfMeasTimes[i] = TempMeasTime / cntPoints
							Rebinned_Decay_Prof [i] = tempMeasVal/cntPoints
							if(UseErrorInputDataWave)		//no error wave....
								Rebinned_Decay_ProfErrors[i]  =  tempMeasError / cntPoints
							else
								if(cntPoints>1)
									Rebinned_Decay_ProfErrors[i] = sqrt(sqrt(abs(tempMeasVal2 - tempMeasVal^2 )/ (cntPoints-1)))
								//	print "cnt larger than 1 for "+num2str(i)
								else
									Rebinned_Decay_ProfErrors[i] =sqrt(tempMeasVal)
								endif							
							endif
							cntPoints=0
							tempMeasVal=0
							TempMeasTime=0
							tempMeasVal2=0
							tempMeasError=0
				endfor
			endif
	else		//this is when no rebinning is requested...  May need to make sure these waves actually exist... In weird case user may create situation
			//when some of these waves may not exist... Leave it for future, if someone actually creates this stiutation
		if(WaveExists(TempMeasDataTimes))
			Duplicate/O TempMeasDataTimes, Rebinned_Decay_ProfMeasTimes
		else
			Duplicate/O TempMeasData, Rebinned_Decay_ProfMeasTimes
			Rebinned_Decay_ProfMeasTimes = pnt2x(TempMeasData,p)
		endif

		if(WaveExists(TempMeasDataErrors))
			Duplicate/O TempMeasDataErrors, Rebinned_Decay_ProfErrors
		else
			Duplicate/O TempMeasData, Rebinned_Decay_ProfErrors
			Rebinned_Decay_ProfErrors = sqrt(TempMeasData)
		endif
		Duplicate/O TempMeasData, Rebinned_Decay_Prof	
	endif
	
	
	Duplicate/O Rebinned_Decay_ProfMeasTimes, OrgRebinned_Decay_ProfMeasTimes
	Duplicate /O Rebinned_Decay_Prof, OrgRebinned_Decay_Prof
	Duplicate/O Rebinned_Decay_ProfErrors, OrgRebinned_Decay_ProfErrors
	
	NVAR ErrMultiplier = root:Packages:DecayModeling:ErrorsMultiplier
	Rebinned_Decay_ProfErrors = ErrMultiplier * OrgRebinned_Decay_ProfErrors
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

