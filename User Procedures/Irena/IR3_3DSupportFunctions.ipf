#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.



//*************************************************************************\
//* Copyright (c) 2005 - 2021, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//version 1.0 support functions for 3D modeling tools. Original release. 2019-02-27


//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//			3D packages, 2019-02-27
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//this will calculate Two-point correlation function and associated Debye phase correlation function for 3D object:

///******************************************************************************************************************************************
///******************************************************************************************************************************************
///******************************************************************************************************************************************
///******************************************************************************************************************************************

//Function IR3T_Calc3DTwoPntCorrelation()
//
//
//	setDataFOlder root:Packages:TwoPhaseSolidModel:	
//	//this code calculates Two-point autocorelation function on 3D wave. 
//	//1. Checks wave for sensibility. Needs wave with mostly 0 in it and 1 for minority phase, if needed, it will switch between 0 and 1 so it evaluates minority phase. 
//	//2. Calculates autocorelation in p, q, and r directions, at most 100x100 vectors in each direction (3x100*100 calculations).
//	//3. Copies scaling to output wave, so if the 3DWave has correct x scaling, data have correct x dimension
//	//4. creates Debye phase correlation function and its radii wave
//	//these are resulting waves:
//	// 	TwoPntCorrelationsWv				= two points correlatiton function, TwoPntCorrelationsWv[0] is volume fraction, x-scaling set based on voxel size
//	//		TwoPntDebyePhCorrFnct				= Debye phase correlation function (TwoPntCorrelationsWv - TwoPntCorrelationsWv[0]^2, negative values = 0), x-scaling set as above
//	//		TwoPntDebyePhCorrRadii			= Radii wave for TwoPntDebyePhCorrFnct
//	// 3DWave does not have to have same length side, but this has not been tested at all yet. 
//	
//	
//	//result is in the sample folder in TwoPntCorrelationsWv which has x scaling set per scaling of input wave. 
//	Wave/Z My3DWv = root:Packages:TwoPhaseSolidModel:TwoPhaseSolidMatrix
//	
//	if(!WaveExists(My3DWv))
//		abort
//	endif
//	
//	//Check  My3DWv
//	Wavestats/Q My3DWv
//	variable VOlumeFraction
//	//1. Min=0 , max=1
//	if(V_min!=0 || V_max!=1)
//		Abort "Wave must contain 0 and 1 ONLY, 1 being minority phase, 0 being majority phase" 
//	endif
//	variable MatrixPhase=0
//	if(V_avg>0.49)
//		MatrixPhase=1
//		VOlumeFraction = 1-V_avg
//		Print "Two-point corelation function characterized minority phase. Minority phase is expressed by 0 in provided matrix" 
//	else
//		VOlumeFraction = V_avg
//		Print "Two-point corelation function characterized minority phase. Minority phase is expressed by 1 in provided matrix" 
//	endif
////	variable startTicks=ticks
//	variable pDim, qdim, rdim
//	variable pstep, qstep, rstep
//	pDim  = DimSize(My3DWv, 0 )
//	qDim  = DimSize(My3DWv, 1 )
//	rDim  = DimSize(My3DWv, 2 )
//	variable pDelta, qDelta, rDelta	//these should be voxel sides, if scaling is used for dimansions. 
//	string pUnits, qUnits, rUnits
//	pUnits = WaveUnits(My3DWv, 0 )
//	qUnits = WaveUnits(My3DWv, 1 )
//	rUnits = WaveUnits(My3DWv, 2 )
//	pDelta = DimDelta(My3DWv, 0 )
//	qDelta = DimDelta(My3DWv, 1 )
//	rDelta = DimDelta(My3DWv, 2 )
//	if((pDim*qDim*rDim) < (48*48*48))
//		Abort "This 3D object seems too small to evaluate, minimum dimensions are 50^3"
//	endif
//	if(pDelta!=qDelta || qDelta!=rDelta)
//		Abort "This 3D object seems to have different side scaling - voxel sides. You can only analyze object with cubical voxels."
//	endif
//	//OK, now we may be able to caculate something... 
//	pstep = ceil(pDim/100)
//	qstep = ceil(qDim/100)
//	rstep = ceil(rDim/100)
//	variable MaxLength=max(pDim, qDim, rDim)
//	//this is wave for results. 
//	Make/O/N=(MaxLength) TwoPntCorrelationsWv
//	variable i, j
//
//	//row (p index)
//	For(i=0;i<qDim;i+=qstep)
//		For(j=0;j<rDim;j+=rstep)
//			ImageTransform /G=(i)/P=(j) getRow My3DWv
//			Wave W_ExtractedRow
//			if(MatrixPhase)
//				W_ExtractedRow=!W_ExtractedRow[p]
//			endif
//			redimension/S W_ExtractedRow
//			//MatrixOp/Free RowCorrelated = correlate(W_ExtractedRow,W_ExtractedRow,0)
//			//RowCorrelated/=numpnts(RowCorrelated)
//			Correlate /AUTO W_ExtractedRow, W_ExtractedRow
//			Wave/Z RowCorrelations
//			if(!WaveExists(RowCorrelations))
//				Duplicate/O W_ExtractedRow, RowCorrelations
//			else
//				RowCorrelations+=W_ExtractedRow
//			endif
//		endfor
//	endfor
//	//RowCorrelations/=(round(qDim/qstep)*round(rDim/rstep))
//	//circular correlation causes this to be mirrored around center. All we get is half of the distance across this way 
//	//reverse RowCorrelations
//	//redimension/N=(numpnts(RowCorrelations)/2)	 RowCorrelations
//	DeletePoints 0, (numpnts(RowCorrelations)/2),  RowCorrelations
//	
//	//column (q index) 
//	For(i=0;i<pDim;i+=pstep)
//		For(j=0;j<rDim;j+=rstep)
//			ImageTransform /G=(i) /P=(j) getCol My3DWv
//			Wave W_ExtractedCol
//			if(MatrixPhase)
//				W_ExtractedCol=!W_ExtractedCol[p]
//			endif
//			redimension/S W_ExtractedCol
//			//MatrixOp/Free ColCorrelated = correlate(W_ExtractedCol,W_ExtractedCol,0)
//			//ColCorrelated/=numpnts(ColCorrelated) 
//			Correlate /AUTO W_ExtractedCol, W_ExtractedCol
//			//ColumnCorrelations+=W_ExtractedCol
//			Wave/Z ColumnCorrelations
//			if(!WaveExists(ColumnCorrelations))
//				Duplicate/O W_ExtractedCol, ColumnCorrelations
//			else
//				ColumnCorrelations+=W_ExtractedCol
//			endif
//		endfor
//	endfor
//	//ColumnCorrelations/=(round(pDim/pstep)*round(rDim/rstep))
//	//circular correlation causes this to be mirrored around center. ALl we get is half of the distance across this way 
//	//reverse ColumnCorrelations
//	//redimension/N=(numpnts(ColumnCorrelations)/2)	 ColumnCorrelations
//	DeletePoints 0, (numpnts(ColumnCorrelations)/2),  ColumnCorrelations
//
//	//beam (r index)	
//	For(i=0;i<pDim;i+=pstep)
//		For(j=0;j<qDim;j+=qstep)
//			ImageTransform /BEAM={(i),(j)} getBeam My3DWv
//			Wave W_Beam
//			if(MatrixPhase)
//				W_Beam=!W_Beam[p]
//			endif
//			redimension/S W_Beam
//			//MatrixOp/Free BeamCorrelated = correlate(W_Beam,W_Beam,4)
//			Correlate /AUTO W_Beam, W_Beam
//			//BeamCorrelated/=numpnts(BeamCorrelated)
//			//BeamCorrelations+=BeamCorrelated
//			Wave/Z BeamCorrelations
//			if(!WaveExists(BeamCorrelations))
//				Duplicate/O W_Beam, BeamCorrelations
//			else
//				BeamCorrelations+=W_Beam
//			endif
//			//BeamCorrelations+=W_Beam
//		endfor
//	endfor
//	//BeamCorrelations/=(round(pDim/pstep)*round(qDim/qstep))
//	//circular correlation causes this to be mirrored around center. All we get is half of the distance across this way 
//	//reverse BeamCorrelations
//	//redimension/N=(numpnts(BeamCorrelations)/2) BeamCorrelations
//	//average, this handles wave of different lenghts. 	
//	//Correlate/AUTO needs rotation around end point
//	DeletePoints 0, (numpnts(BeamCorrelations)/2),  BeamCorrelations
//
//	IR3T_Average3Waves(RowCorrelations,ColumnCorrelations,BeamCorrelations ,TwoPntCorrelationsWv)
//	KillWaves/Z RowCorrelations,ColumnCorrelations,BeamCorrelations
////	Duplicate/O BeamCorrelations, TwoPntCorrelationsWv
//	//redimension/N=(numpnts(TwoPntCorrelationsWv)/2) TwoPntCorrelationsWv
//	//normalize to volume fratcion as epxected
//	Wavestats/Q TwoPntCorrelationsWv
//	TwoPntCorrelationsWv = VOlumeFraction* TwoPntCorrelationsWv[p]/V_max 
//	
//	Duplicate/O TwoPntCorrelationsWv, TwoPntDebyePhCorrFnct, TwoPntDebyePhCorrRadii
//	//??? TwoPntDebyePhCorrFnct =  TwoPntCorrelationsWv - VolumeFraction^2				//this converts this from TwoPointCor FUnction to Debye Phase Correlation function
//	TwoPntDebyePhCorrFnct =  TwoPntCorrelationsWv + VolumeFraction^2				//this converts this from TwoPointCor FUnction to Debye Phase Correlation function
//	//is the above negative or positive? I think it is positive, since the random chanse should be volumefraction^2 
//	
//	TwoPntDebyePhCorrFnct = TwoPntDebyePhCorrFnct[p]>0 ? TwoPntDebyePhCorrFnct : 0			//this needs to be non-negative... - note it should be bit more complicated, but this is OK for now... 
//
//	SetScale/P x 0,(pDelta),pUnits, TwoPntCorrelationsWv, TwoPntDebyePhCorrFnct				//assign x-scaling in A from 3D model. 
//	//Seems like this is distance distribution, not radius distribution... 
//	//that is why we need the 1/2 there??? 
//
//	TwoPntDebyePhCorrRadii = pnt2x(TwoPntDebyePhCorrFnct, p )
//	
//	
//	//Display/K=1 TwoPntCorrelationsWv
//	//print (ticks-startTicks)/60
//end
///******************************************************************************************************************************************
///******************************************************************************************************************************************
///******************************************************************************************************************************************

// I M P O R T A N T - verified for spheres on 5-1-2020, seems to work for:
// 3D voxelgram, 0 is empty space, 1 is particle 
// checked on sphere model with voxel sizes 1, 2, and 4 A and it works. 

Function IR3T_CalcAutoCorelIntensity(My3DWv, IsoValue, Qmin, Qmax, NumQSteps)
	Wave My3DWv
	variable IsoValue, Qmin, Qmax, NumQSteps
	//same as IR3T_CreatePDFIntensity 
	//		old:   does the same thing as Function IR3T_Calc3DTwoPntCorrelation()
	//					but uses 3DAutcorrelation
	
	print "IsoValue value in IR3T_CalcAutoCorelIntensity is for now not used." 
	setDataFOlder GetWavesDataFolder(My3DWv, 1 )
	
	//this code calculates Two-point autocorelation function on 3D wave. 
	//1. Checks wave for sensibility. Needs wave with mostly 0 in it and 1 for minority phase, if needed, it will switch between 0 and 1 so it evaluates minority phase. 
	//2. Calculates autocorelation in p, q, and r directions, at most 100x100 vectors in each direction (3x100*100 calculations).
	//3. Copies scaling to output wave, so if the 3DWave has correct x scaling, data have correct x dimension
	//4. creates Debye phase correlation function and its radii wave
	//these are resulting waves:
	// 	TwoPntCorrelationsWv				= two points correlatiton function, TwoPntCorrelationsWv[0] is volume fraction, x-scaling set based on voxel size
	//		TwoPntDebyePhCorrFnct				= Debye phase correlation function (TwoPntCorrelationsWv - TwoPntCorrelationsWv[0]^2, negative values = 0), x-scaling set as above
	//		TwoPntDebyePhCorrRadii			= Radii wave for TwoPntDebyePhCorrFnct
	// 3DWave does not have to have same length side, but this has not been tested at all yet. 
	//next it calculates Intensity vs Q vector same as IR3T_CreatePDFIntensity
	
	//result is in the sample folder in TwoPntCorrelationsWv which has x scaling set per scaling of input wave. 
	print "Check input wave and get dimension values. this can take a logng time. 512^3 wave takes ~30 seconds on fast computer"
	//variable starttik=ticks
	//Check  My3DWv
	variable VolumeFraction
	Wavestats/Q/M=1 My3DWv
	//Check that Min=0 , max=1
	if(V_min!=0 || V_max!=1)
		Abort "Wave must contain 0 and 1 ONLY, 1 being minority phase, 0 being majority phase" 
	endif
	variable MatrixPhase=0
	if(V_avg>0.49)
		MatrixPhase=1
		VolumeFraction = 1-V_avg
		Print "Two-point corelation function characterized minority phase. Minority phase is expressed by 0 in provided matrix" 
	else
		VolumeFraction = V_avg
		Print "Two-point corelation function characterized minority phase. Minority phase is expressed by 1 in provided matrix" 
	endif
	variable pDim, qdim, rdim
	variable pstep, qstep, rstep
	pDim  = DimSize(My3DWv, 0 )
	qDim  = DimSize(My3DWv, 1 )
	rDim  = DimSize(My3DWv, 2 )
	variable pDelta, qDelta, rDelta						//these should be voxel sides, if scaling is used for dimansions. 
	string pUnits, qUnits, rUnits
	pUnits = WaveUnits(My3DWv, 0 )
	qUnits = WaveUnits(My3DWv, 1 )
	rUnits = WaveUnits(My3DWv, 2 )
	pDelta = DimDelta(My3DWv, 0 )
	qDelta = DimDelta(My3DWv, 1 )
	rDelta = DimDelta(My3DWv, 2 )
	if((pDim*qDim*rDim) < (48*48*48))
		Abort "This 3D object seems too small to evaluate, minimum dimensions are 50^3"
	endif
	if(pDelta!=qDelta || qDelta!=rDelta)
		Abort "This 3D object seems to have different side scaling - voxel sides. You can only analyze object with cubical voxels."
	endif
	Print "Preparation phase done, starting autocorrelation. This may be slow. "
	//calculate autocorelation 
	IR3T_Autocorelate3D(My3DWv)
	wave AutoCorMatrix		//this is resulting autcorrelation wave
	Print "Finished autocorrelation. Calculate Two Point Corelation function now."
	// Extract radial profile... 
	IR3T_CalcRadialAveProfile3D(AutoCorMatrix)	
	KillWaves/Z AutoCorMatrix
	Wave RadialWaveProfile													//radial profile with the x voxel scaling... 
	SetScale /P x, 0, pDelta, "A", RadialWaveProfile					//here we set x scaling to match input scaling of the 3D wave voxel size. 
	Print "Finished Two Point Correlation function calculation. Finish by scaling."
	Duplicate/free  RadialWaveProfile, TwoPntCorrelationsWv, TwoPntDebyePhCorrFnct, TwoPntDebyePhCorrRadii
	KillWaves/Z RadialWaveProfile
	//RadialWaveProfile[0] = 1 and at infinity is = VolumeFraction. 
	
	//scaling to match volume fraction needed, 
	TwoPntCorrelationsWv = VOlumeFraction * (TwoPntCorrelationsWv - VOlumeFraction^2)

	Duplicate/O TwoPntDebyePhCorrFnct, ModelFFTAutoCorelGr
	

	FindLevel/EDGE=2/Q/P TwoPntCorrelationsWv, 0
	if(V_Flag==0)
		//Duplicate/Free TwoPntCorrelationsWv, PDFWave, PrWave
		//PrWave = RadialWaveProfile * x
		//PDFWave = PrWave * x^2
		//variable CalculatedRg=area(PDFWave,0,V_LevelX)/area(PrWave,0,V_LevelX)
		//print "Calculated Rg [A] = "+num2str(CalculatedRg)
		TwoPntCorrelationsWv[V_LevelX+1, ] = 0
	endif

	//the commented part below screwed up the results tremendously. Which is bit weird. In any case, TwoPntDebyePhCorrFnct = TwoPntCorrelationsWv works just fine. 
	TwoPntDebyePhCorrFnct = TwoPntCorrelationsWv				// (VolumeFraction+VolumeFraction^2)*TwoPntCorrelationsWv + VolumeFraction^2				//this converts this from TwoPointCor Function to Debye Phase Correlation function
																			//or is it: TwoPntDebyePhCorrFnct =  TwoPntCorrelationsWv - VolumeFraction^2	???
	TwoPntDebyePhCorrRadii = pnt2x(TwoPntDebyePhCorrFnct, p )
	//print (ticks-starttik)/60
	
	make/O/N=(NumQSteps)/D 	AutoCorIntensityWv, AutoCorQWv
	AutoCorQWv =	Qmin + p*(Qmax-Qmin)/(NumQSteps-1)  
	IN2G_ConvertTologspacing(AutoCorQWv,0)									//creates log-q spacing in the PDFQWv
	//multithread AutoCorIntensityWv =  IR3T_CalcIntensityPDF(PDFQWv[p],PDFWave,RadiiWave)										//this is PDF from IR3T_CreatePDFIntensity
	multithread AutoCorIntensityWv = IR3T_ConvertDACFToInt(TwoPntDebyePhCorrRadii,TwoPntDebyePhCorrFnct,AutoCorQWv)		//and this is equivalent using Autocoreelation function

end
//Function IR3T_CalcTwoPntsCorFIntensity()
//	//to be run after running IR3T_Calc3D_3DTwoPntCorrelation
//	//calculates intensity vs q vercor for results of that function
//	
//	setDataFOlder root:Packages:TwoPhaseSolidModel:	
//	
//	DoWindow TwoPhaseSystemData
//	if(V_Flag)
//		DoWIndow/F TwoPhaseSystemData
//		//thsi should exist:
//		Wave	TwoPntDebyePhCorrFnct	 = root:Packages:TwoPhaseSolidModel:TwoPntDebyePhCorrFnct			//= Debye phase correlation function (TwoPntCorrelationsWv - TwoPntCorrelationsWv[0]^2, negative values = 0), x-scaling set as above
//		Wave	TwoPntDebyePhCorrRadii = root:Packages:TwoPhaseSolidModel:TwoPntDebyePhCorrRadii			//= Radii wave for TwoPntDebyePhCorrFnct
//		Wave/Z PDFQWv = root:Packages:TwoPhaseSolidModel:PDFQWv
//		Wave/Z PDFIntensityWv = root:Packages:TwoPhaseSolidModel:PDFIntensityWv
//		Wave ExtrapolatedIntensity = root:Packages:TwoPhaseSolidModel:ExtrapolatedIntensity
//		Wave ExtrapolatedQvector = root:Packages:TwoPhaseSolidModel:ExtrapolatedQvector
//		Wave OriginalQvector = root:Packages:TwoPhaseSolidModel:OriginalQvector
//		Wave OriginalIntensity = root:Packages:TwoPhaseSolidModel:OriginalIntensity
//		Wave/Z TheoreticalIntensityDACF = root:Packages:TwoPhaseSolidModel:TheoreticalIntensityDACF
//		Wave/Z QvecTheorIntensityDACF=root:Packages:TwoPhaseSolidModel:QvecTheorIntensityDACF
//		NVAR Qmin = root:Packages:TwoPhaseSolidModel:LowQExtrapolationStart
//		NVAR Qmax = root:Packages:TwoPhaseSolidModel:HighQExtrapolationEnd
//		//calculate intensity:
//		Duplicate/O ExtrapolatedQvector, TwoPntModelIntensity, TwoPntModelQvec
//		TwoPntModelIntensity = IR3T_ConvertDACFToInt(TwoPntDebyePhCorrRadii,TwoPntDebyePhCorrFnct,TwoPntModelQvec)	
//		//to make Guinier here match, we need to do this... WHy?
//	//	TwoPntModelQvec*=pi
//		//end of why??? 
//		variable InvarModel
//		variable InvarData
//		//need to renormalize this together...
//		InvarModel=areaXY(TwoPntModelQvec, TwoPntModelIntensity, Qmin, TwoPntModelQvec[numpnts(TwoPntModelQvec)-2] )
//		InvarData=areaXY(OriginalQvector, OriginalIntensity, Qmin, TwoPntModelQvec[numpnts(TwoPntModelQvec)-2]  )
//			TwoPntModelIntensity*=InvarData/InvarModel
//			CheckDisplayed /W=TwoPhaseSystemData TwoPntModelIntensity
//			if(V_flag==0)
//				AppendToGraph/W=TwoPhaseSystemData  TwoPntModelIntensity vs TwoPntModelQvec
//			endif
//			ModifyGraph lstyle(TwoPntModelIntensity)=9,lsize(TwoPntModelIntensity)=3,rgb(TwoPntModelIntensity)=(2,39321,1)
//			//ModifyGraph mode(TwoPntModelIntensity)=4,marker(TwoPntModelIntensity)=19
//			//ModifyGraph msize(TwoPntModelIntensity)=3
//	endif
//

///******************************************************************************************************************************************
///******************************************************************************************************************************************

Function IR3T_CalcRadialAveProfile3D(My3DWaveIn)
		wave My3DWaveIn
		//this calculates radial profile of intensity for 3D Wave
		//from the center
		//may not be cube...  
		variable pcen, qcen, rcen
		wavestats/Q My3DWaveIn
		pcen = V_maxRowLoc 
		qcen = V_maxColLoc
		rcen = V_maxLayerLoc
		variable maxDist=DimSize(My3DWaveIn, 0 )
		variable VoxelSize=DimDelta(My3DWaveIn, 0)

		//MatrixOp/Free/NTHR=0 My3DTempWv = My3DWaveIn
		MatrixOp/Free/NTHR=0 My3DDistacneWv = My3DWaveIn
		multithread My3DDistacneWv = sqrt((p-pcen)^2+(r-rcen)^2+(q-qcen)^2)
		//make/Free/N=(numpnts(My3DDistacneWv)) My1DValuesWave, My1DDistanceWv
		//MatrixOp/Free/NTHR=0 My1DValuesWave = My3DWaveIn				//this convert 3D wave in 1D wave.
		//MatrixOp/Free/NTHR=0 My1DDistanceWv = My3DDistacneWv			//this convert 3D wave in 1D wave.
		//Sort My1DDistanceWv, My1DDistanceWv, My1DValuesWave
		make/Free/N=(10*maxDist) HistogramWvIndx, HistogramWv
		Histogram /B={0,1,maxDist}/W=My3DWaveIn/Dest=HistogramWv  My3DDistacneWv
		//Wave W_SqrtN		//this does not work with /W flag  
		Histogram /B={0,1,maxDist}/Dest=HistogramWvIndx  My3DDistacneWv
		HistogramWv /= HistogramWvIndx
		Duplicate/O HistogramWv, RadialWaveProfile
end
		
		
///******************************************************************************************************************************************
///******************************************************************************************************************************************
	//this works, but I am worried that this is not correct logically... 
	
	//	//pick random row to extend data for correlation
//	p1=trunc(abs(enoise(1))*qDim-1e-6)
//	p2=trunc(abs(enoise(1))*rDim-1e-6)
//	ImageTransform /G=(p1) /P=(p2) getRow My3DWv
//	Wave W_ExtractedRow
//	KillWaves/Z RandRow
//	Rename W_ExtractedRow, RandRow
//	Wave RandRow
//	For(i=0;i<qDim;i+=qstep)
//		For(j=0;j<rDim;j+=rstep)
//			ImageTransform /G=(i) /P=(j) getRow My3DWv
//			Wave W_ExtractedRow
//			Concatenate /NP/O  {W_ExtractedRow, RandRow}, W_ExtractedRowL
//			MatrixOp/Free RowCorrelated = correlate(W_ExtractedRowL,W_ExtractedRowL,0)
//			RowCorrelated/=numpnts(RowCorrelated)/2
//			RowCorrelations+=RowCorrelated
//		endfor
//	endfor
//	Redimension /N=(DimSize(My3DWv, 0 )) RowCorrelations
//	RowCorrelations/=(round(qDim/qstep)*round(rDim/rstep))
///******************************************************************************************************************************************
///******************************************************************************************************************************************

static Function IR3T_Average3Waves(w1,w2,w3,wOut)
	wave w1,w2,w3,wOut
	
	variable L1, L2, L3, i, LM, tmpV
	L1=numpnts(w1)
	L2=numpnts(w2)
	L3=numpnts(w3)
	LM=max(L1, L2, L3)
	make/Free/N=(LM) TempWave
	For(i=0;i<LM;i+=1)
		tmpV=0
		TempWave[i]=0
		if(i<L1)
			TempWave[i]+=w1[i]
			tmpV+=1
		endif
		if(i<L2)
			TempWave[i]+=w2[i]
			tmpV+=1
		endif
		if(i<L3)
			TempWave[i]+=w3[i]
			tmpV+=1
		endif
		TempWave[i]/=tmpV
	endfor
	redimension/N=(LM) wOut
	wOut=TempWave
end


///******************************************************************************************************************************************
///******************************************************************************************************************************************
///******************************************************************************************************************************************
///******************************************************************************************************************************************
///******************************************************************************************************************************************




//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//			Utility functions
//******************************************************************************************************************************************************
//*****************************************************************************************************************
//this function takes as input voxelgram, generated directly or using ConvertToVoxelGram(ListWv, primaryradius)
// VoxelSize here is dimension, which is the size of the voxel... For 3D Solids it is what model assumed.
// If using ConvertToVoxelGram(ListWv, primaryradius) one needs to calculated this from two values:
// Size of the primary particle of the aggregate, close to Rg level 1, may be needs to be slightly modified
// Oversampling used in ConvertToVoxelGram - currently defaulted to 10. 
//   Therefore, if Rg of level 1 is 20 A = assume diameter is 40A, the VoxelSize is actually 4 
//   each original "particle" in the Aggregate was replaced with 10 x 10 x 10 voxels, basically we made assumption that diameter of the primary particle is 10.   
//this function returns PDFIntensityWv and PDFQWv waves with calculated intensity vs Q for the 3D structure. 

// I M P O R T A N T - verified for spheres on 5-1-2020, seems to work for:
// 3D voxelgram, 0 is empty space, 1 is particle 
// checked on sphere model with voxel sizes 1, 2, and 4 A and it works. 
// now for 3D solid where we have many particles this does not work. We get again scattering from teh box size and not from particle shapes... 
// this is probably useful most for Fractal Aggregate and not for 3D solid...  

Function IR3T_CreatePDFIntensity(ThreeDVoxelGram, IsoValue, Qmin, Qmax, NumQSteps)
	wave ThreeDVoxelGram
	variable IsoValue, Qmin, Qmax, NumQSteps
	//oversample can be 1 or larger integer (2-4 is sensible). Makes evaluated voxelgram oversample * larger to improve data at high-qs. 
	//VoxelSize in [A] per voxel
	//IsoValue typically 0.5, if solid is 1 and void is 0 density
	//Qmin, Qmax, NumQSteps 		what q range for intensity calculation
	variable StartTicks=ticks
	
	variable VoxelSize = dimdelta(ThreeDVoxelGram,0)		//this is voxelsize from x scaling of 3D wave
	variable NumRSteps
	variable oversample
	//if the 3DVocelgram is sufficiently small, oversample to get better data...
	if(dimsize(ThreeDVoxelGram,0)*dimsize(ThreeDVoxelGram,1)*dimsize(ThreeDVoxelGram,2)< 120^3)
		oversample = 4
	elseif(dimsize(ThreeDVoxelGram,0)*dimsize(ThreeDVoxelGram,1)*dimsize(ThreeDVoxelGram,2)< 220^3)
		oversample = 2
	else
		oversample = 1
	endif
	if(oversample>1)		//this helps a lot, takes time, but improves high-q fitting... 
		Print "oversampling Data by factor of "+num2str(oversample)
		StartTicks=ticks
		DUPLICATE/free ThreeDVoxelGram, ThreeDVoxelGramTemp
		SetScale/P x 0,1,"", ThreeDVoxelGramTemp		//Interp3D uses wave scaling, so we need to match wave scaling to point numbers... 
		SetScale/P y 0,1,"", ThreeDVoxelGramTemp
		SetScale/P z 0,1,"", ThreeDVoxelGramTemp
		make/Free/S/N=(oversample*dimsize(ThreeDVoxelGramTemp,0),oversample*dimsize(ThreeDVoxelGramTemp,1),oversample*dimsize(ThreeDVoxelGramTemp,2)) OversampledThreeDVoxelGram
		//multithread Use3DWave = ThreeDVoxelGram[floor(p/oversample)][floor(q/oversample)][floor(r/oversample)]
		multithread OversampledThreeDVoxelGram = Interp3D(ThreeDVoxelGramTemp, ((p/oversample)), ((q/oversample)),((r/oversample)) )	
		MatrixOp/Free/NTHR=0 Use3DWaveThresh = greater(OversampledThreeDVoxelGram,0.55)		//this tresholds the wave so it is smoother than what simple assignment above does... 
		wave Use3DWave = Use3DWaveThresh
		print "Done oversampling after "+num2str((ticks-StartTicks)/60)
	else
		Print "NO oversampling selected "
		wave Use3DWave = ThreeDVoxelGram
	endif
	
	variable RadMin,RadMax	//for now, these are simply steps in voxels, we are now working with integer of pixel positions... 
	RadMin = 0.5
	RadMax = ceil(sqrt(3)*max(DimSize(Use3DWave, 0 ), DimSize(Use3DWave, 1),DimSize(Use3DWave, 2 ) ))
	NumRSteps = RadMax
	Make/free/N=(NumRSteps)/D VoxDistanceWave								//this makes steps in R = 1 A
	VoxDistanceWave = p + RadMin 											//linear distance space... 
	//testing shows, that linear radius binning is better. We get better behavior at high q values. 
	//IN2G_ConvertTologspacing(VoxDistanceWave, 0.5)							//sets k scaling on log-scale...	
	Make/FREE/N=0 Distances, Distances1
	Make/Free/N=	(1e5) Distancestmp
	Print "Calculating distances "
	StartTicks=ticks	
	variable endDo, startPoint
	do						
		// this uses at least 1e5 points - and up to 1e7 points.
		// but also always limits the run to 20 seconds. Should adjust dynamically quality fo calculations for cpu and complexity of the problem. 
		multithread  Distancestmp =  IR3T_FindNextDistance(Use3DWave, IsoValue)
		startPoint = numpnts(Distances)
		Redimension /N=(numpnts(Distances)+numpnts(Distancestmp)) Distances
		Distances[startPoint,numpnts(Distances)-1 ] = Distancestmp[p-startPoint]
		endDo = ((ticks-StartTicks)/60 > 20 ) || (numpnts(Distances)>1e7)
	while(!endDo)
	print "Done calculating distacnes after "+num2str((ticks-StartTicks)/60)
	Histogram /NLIN=VoxDistanceWave/Dest=PDFWave Distances
	Wave PDFWave
	//Smooth/B/E=3 3, PDFWave	 //this is to smooth out the noise on the PDF due to poor sampling... Seems to do more harm than good... 
	//now we need to create radius wave... 
	//VoxDistanceWave are bin edges, returned is 1 less point in PDFWave and bin centers need to be calculated by avergaing...
	Duplicate/O PDFWave, RadiiWave
	RadiiWave = (VoxDistanceWave[p]+VoxDistanceWave[p+1])/2
	//also, add distance 0 , value 0. 
	InsertPoints 0, 1, RadiiWave, PDFWave
	PDFWave[0]=0
	RadiiWave[0]=0

	//remove tailing 0 values from calculations. Note: leaves last 0 point in there... 
	IR3T_RemoveTailZeroes(PDFwave,RadiiWave)						//remove end 0 values, just waste to drag around and plot. 
	//Duplicate/O RadiiWave, GammaWave
	//convert from voxel units to Angstroms
	RadiiWave*=VoxelSize/oversample									//convert to real Angstrom distances
	//normalize the PDF
	variable areaPDF= areaXY(RadiiWave, PDFWave)		
	PDFWave/=areaPDF
	//this is not needed and for now not useful. 
	//Duplicate/O PDFWave, GammaWave
	//GammaWave = PDFWave/(4*pi*RadiiWave^2)
	//GammaWave[0] = GammaWave[1]
	//variable areaGamma= areaXY(RadiiWave, GammaWave)
	//GammaWave = GammaWave/areaGamma 
	//and calculate intensity
	make/O/N=(NumQSteps)/D 	PDFIntensityWv, PDFQWv
	PDFQWv =	Qmin + p*(Qmax-Qmin)/(NumQSteps-1)  
	IN2G_ConvertTologspacing(PDFQWv,0)									//creates log-q spacing in the PDFQWv
	multithread PDFIntensityWv =  IR3T_CalcIntensityPDF(PDFQWv[p],PDFWave,RadiiWave)	
	//KillWaves/Z PDFWave,RadiiWave
	Duplicate/O PDFWave, PDFGrCalculatedWave
	PDFGrCalculatedWave = PDFWave / RadiiWave^2
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

Function  IR3T_RemoveTailZeroes(PDFwave,RadiusWave)
	wave PDFwave,RadiusWave
	variable i=numpnts(PDFwave)-1
	Do
		DeletePoints i, 1, PDFwave,RadiusWave
		i-=1
	 while(PDFwave[i-1]<1e-15)
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
threadsafe Function IR3T_FindNextDistance(ThreeDVoxelGram, IsoValue)
	wave ThreeDVoxelGram
	variable IsoValue
	
	variable distance
	variable p1, p2, q1, q2, r1, r2
	variable i, imax=10000
	variable BoxSizeP=DimSize(ThreeDVoxelGram, 0 )
	variable BoxSizeQ=DimSize(ThreeDVoxelGram, 1 )
	variable BoxSizeR=DimSize(ThreeDVoxelGram, 2 )
	For(i=0;i<imax;i+=1)
		p1 = trunc(abs(enoise(1))*BoxSizeP - 1e-9)
		p2 = trunc(abs(enoise(1))*BoxSizeP - 1e-9)
		q1 = trunc(abs(enoise(1))*BoxSizeQ - 1e-9)
		q2 = trunc(abs(enoise(1))*BoxSizeQ - 1e-9)
		r1 = trunc(abs(enoise(1))*BoxSizeR - 1e-9)
		r2 = trunc(abs(enoise(1))*BoxSizeR - 1e-9)
		if(ThreeDVoxelGram[p1][q1][r1]>(0.99*IsoValue) && ThreeDVoxelGram[p2][q2][r2]>(0.99*IsoValue))		//both are in phase which is declared by > IsoValue...
			distance = sqrt((p1-p2)^2+(q1-q2)^2+(r1-r2)^2)								//this should be distance in pixels between two ends of this line
			if(distance>0)
				return distance
			endif
		endif
	endfor
	return 0
	
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
////threadsafe
//threadsafe Function IR3T_CalcIntensityGamma(Qvalue,GammaVal,Radius)		//Glatter-Kraky book, page 27, formula 29
//	variable Qvalue
//	wave GammaVal,Radius	
//	Make/Free/N=(numpnts(GammaVal))/D QRWave
//	QRWave=sinc(Qvalue*Radius[p])			//(sin(Qvec[p]*Radius))/(Qvec[p]*Radius)		
//	matrixOP/Nthr=0/Free tempWave = powR(Radius, 2) * GammaVal * QRWave
//	return 4*pi*areaXY(Radius, TempWave)
//end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

//			Below is support for 3D Aggreage conversion to intensity. 
//**************************************************************************************************************************************************************
//**************************************************************************************************************************************************************
//**************************************************************************************************************************************************************
//this function converts list 3d wave (aggregate) into voxelgram.
//Voxelgram is 10x larger than the input space of the aggregate (given by max size of the aggregate). 
//primary radius is size of spehere which is used to fill the "primary particle size". Since the 10x oversamnples
//a good primary radius is 5. In this case nearest neighbor particles are touching. It could be slightly larger, may be 6 or even 7.
//creates denser structure.  
Function IR3T_ConvertToVoxelGram(ListWv, primaryradius)
	wave ListWv
	variable primaryradius
	
	if(primaryradius<2 || primaryradius>12)
		Abort "primaryradius parameter passed to IR3T_ConvertToVoxelGram makes no sense." 
	endif
	//get max size needed... 
	WaveStats/Q ListWv
	variable MaxSize=max(V_max, abs(V_min))
	MaxSize = 2 * (MaxSize+1)*10							//10x larger to oversample, add layer on each side so we do not run out of box...
	variable CenterOffset=MaxSize/2
	Make/Free/N=(MaxSize,MaxSize,MaxSize)/U/B VoxelGram
	//Ok,now fill it up.
	variable i
	For(i=0;i<DimSize(ListWv,0);i+=1)
			//fill centers of each point here with 1
			//ListWv[i][0] is one coordinate, ListWv[i][1] second, ListWv[i][2] third, we need to offset them by half of the box CenterOffset
			VoxelGram[CenterOffset+10*ListWv[i][0]][CenterOffset+10*ListWv[i][1]][CenterOffset+10*ListWv[i][2]] = 1
	endfor
	IR3T_CreateSpheresStructure(VoxelGram,primaryradius, 0.5)
	Wave Wave3DwithPrimary			//this is result produced by above code... 
end
//**************************************************************************************************************************************************************
//**************************************************************************************************************************************************************
Function IR3T_FindNearestPrimeSize(ValueIn)
	variable ValueIn
	
	make/N=12/Free PrimeList,PrimeList3
	PrimeList = 2^p
	//PrimeList3 = 3^p
	//Concatenate /O/NP {PrimeList2,PrimeList3}, PrimeList
	sort PrimeList, PrimeList
	variable index
	index = BinarySearch(PrimeList, ValueIn )
	return PrimeList[index+1]
end
//**************************************************************************************************************************************************************
//**************************************************************************************************************************************************************
//**************************************************************************************************************************************************************

//use this - this is much better:
//this function convolutes sparsely filled 3D space from ConvertToVoxelGram with sphere of size (discussed above).
//this results in voxelgram which looks like filled with touching sheres. Needed to calcualte PDF
//this would be great to make more multicore, but somehow it did not work... 
Function IR3T_CreateSpheresStructure(Wave3DIn,sphereRadius, level)
		wave Wave3DIn
		variable sphereRadius, level
		//level is level above which the material is a phase (solid)
	//in order to make this faster we need to pad this to dimensions which are power of 2 or power of 3, helps fft internally (per AG from WM)
	//hm, this padding does not seem to help for smallish cases... Heps a lot in larger cases, I have seen factor of 3x faster operations... 
	print "Creating Voxelgram, creating spherical structure"
	variable StartTicks=ticks
	Duplicate/Free Wave3DIn, WaveToWorkOn
	variable PadSphere=2*round(0.5 + sphereRadius/2)
	variable newDimP, newDimQ, newDimR
	newDimP = 2*round(0.5+(DimSize(WaveToWorkOn,0)+PadSphere)/2)
	newDimQ = 2*round(0.5+(DimSize(WaveToWorkOn,1)+PadSphere)/2)
	newDimR = 2*round(0.5+(DimSize(WaveToWorkOn,2)+PadSphere)/2)
	if(newDimP>50 || newDimQ>50 || newDimR>50)
		newDimP = IR3T_FindNearestPrimeSize(newDimP)
		newDimQ = IR3T_FindNearestPrimeSize(newDimQ)
		newDimR = IR3T_FindNearestPrimeSize(newDimR)
	endif
	redimension/N=(newDimP, newDimQ,newDimR)/S WaveToWorkOn			//make larger so we do not run out after fft/ifft (which shifts data by size of the sphere...
	make/FREE/N=(dimsize(WaveToWorkOn,0),dimsize(WaveToWorkOn,1),dimsize(WaveToWorkOn,2)) Sphere
	//alternative for sharp sphere is 
	//sphere = Gauss(x,2*sphereRadius+2,sphereRadius/sqrt(2),y,2*sphereRadius+2,sphereRadius/sqrt(2),z,2*sphereRadius+2,sphereRadius/sqrt(2))
	//this is sharp sphere... 
	sphere[0,ceil(2*sphereRadius+2)][0,ceil(2*sphereRadius+2)][0,ceil(2*sphereRadius+2)]=(sqrt((p-sphereRadius)^2+(q-sphereRadius)^2+(r-sphereRadius)^2)<sphereRadius) ? 1 : 0
	fft/DEST=sphereFFT/Free sphere
	fft/DEST=Wave3DInFFT/Free WaveToWorkOn
	//MatrixOp/FREE/NTHR=0 sphereFFT=fft(sphere,0)					//does not work - MatrixOp does 2D ffts, not 3d FFT, so here it works layer-by-layer 
	MatrixOp/FREE/NTHR=0 MultipliedFFT = Wave3DInFFT * sphereFFT
	IFFT/Dest=Wave3DOutIFFT/Free MultipliedFFT
	//this depends on what is used for convolution. If sharp sphere, this is what you need... thresholds are  much smaller for gauss... 
	MatrixOp/O/NTHR=0 Wave3DwithPrimary = greater(Wave3DOutIFFT,level)
	//and now shrink the box as small as possible. Note, it crashes Igor before 8.03 release...
	if(NumberByKey("IGORVERS", IgorInfo(0))>8.02)			//there was bug in Igor 8.02 and before, this would crash Igor... 
		ImageTransform/F=0 shrinkBox Wave3DwithPrimary
		Wave M_shrunkCube
		Duplicate/O M_shrunkCube, Wave3DwithPrimaryShrunk
	endif
	print "Done with creating Voxelgram spherical structure in :"+num2str((ticks-startTicks)/60)
end

//**************************************************************************************************************************************************************
//**************************************************************************************************************************************************************
//**************************************************************************************************************************************************************

