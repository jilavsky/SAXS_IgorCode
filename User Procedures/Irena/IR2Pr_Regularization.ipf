#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.03

//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.03 Igor 7 required change - remobed use of MatrixLUBkSub and changed to MatrixLinearSolve, MatrixLUBkSub is deprecated. 
//1.02 added license for ANL


//version 1.02 contains GNOM-type output

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2Pr_DoInternalRegularization()

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

	//Now we need to create new waves with data scaled by Int^N to provide fitting in more ballanced space...
	Wave Q_vec=root:Packages:Irena_PDDF:Q_vec
	Wave Intensity=root:Packages:Irena_PDDF:Intensity
	Wave Errors=root:Packages:Irena_PDDF:Errors
	Wave G_matrix=root:Packages:Irena_PDDF:G_matrix

		IR2Pr_MakeHmatrix()				//creates H matrix
		
		IR2Pr_CalculateBVector()			//creates B vector
	
		IR2Pr_CalculateDMatrix()			//creates D matrix
	
//		IR2Pr_SetupDiagnostics()			//setup diagnostics graphs if needed
	
		NVAR Evalue=root:Packages:Irena_PDDF:Evalue
		NVAR NumberIterations=root:Packages:Irena_PDDF:NumberIterations

		NumberIterations=IR2Pr_FindOptimumAvalue(Evalue)	//does the  fitting for given e value, for now set here to a value 0.1

		Wave CurrentResultPdf = root:Packages:Irena_PDDF:CurrentResultPdf
		Wave PDFFitIntensity=root:Packages:Irena_PDDF:PDFFitIntensity
		Wave NormalizedResidual=root:Packages:Irena_PDDF:NormalizedResidual

		NVAR Chisquare=root:Packages:Irena_PDDF:Chisquare
	
		if ((numtype(NumberIterations)!=0)||(numberIterations>numpnts(PDFFitIntensity)))	//no solution found
			PDFFitIntensity=0
			CurrentResultPdf = 0
			NormalizedResidual = 0
			Chisquare = 0			//new Chisquared
		endif
		setDataFolder OldDf
	
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

static Function IR2Pr_FindOptimumAvalue(Evalue)						//does the fitting itself, call with precision (e~0.1 or so)
	variable Evalue	

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

	Wave Intensity=root:Packages:Irena_PDDF:Intensity
	Wave Errors=root:Packages:Irena_PDDF:Errors
	Wave R_distribution=root:Packages:Irena_PDDF:R_distribution
	NVAR NumberIterations=root:Packages:Irena_PDDF:NumberIterations

	variable LogAmax=100, LogAmin=-100, M=numpnts(Intensity)
	variable tolerance=Evalue*sqrt(2*M)
	variable Chisquared, MidPoint, Avalue, i=0, logAval, LogChisquarerdDivN, Smoothness, priorChisquared=1e10
	NumberIterations=0
	do
		MidPoint=(LogAmax+LogAmin)/2
		Avalue=10^MidPoint								//calculate A
		IR2Pr_CalculateAmatrix(Avalue)
		Wave A_matrix
//		MatrixLUD A_matrix								//decompose A_matrix 
//		Wave M_Lower									//results in these matrices for next step:
//		Wave M_Upper
//		Wave W_LUPermutation
		Wave B_vector
//		MatrixLUBkSub M_Lower, M_Upper, W_LUPermutation, B_vector				//Backsubstitute B to get x[]=inverse(A[][]) B[]	
 		MatrixLinearSolve/M=1 A_matrix  B_vector
		Wave M_B
		Duplicate/O M_B, M_x
		//Wave M_x=M_B										//this is created by MatrixMultiply

		Redimension/D/N=(-1,0) M_x							//create from M_x[..][0] only M_x[..] so it is simple wave
		Duplicate/O M_x CurrentResultPdf					//put the data into the wave 
		Note/K CurrentResultPdf
		Note CurrentResultPdf, note(intensity)
		
		//Need to fix binning effect, if it was not accounted for in G matrix we need to take bin width out now...
		variable iv
		Wave CurrentResultPdf = root:Packages:Irena_PDDF:CurrentResultPdf
		For(iv=0;iv<numpnts(ModelDistribution);iv+=1)
			CurrentResultPdf[iv] = CurrentResultPdf[iv] / IR2Pr_BinWidthInRadia(iv)
		endfor
		Chisquared=IR2Pr_CalculateChisquared()				//Calculate C 	C=|| I - G M_x ||
		
		Wave PDFFitIntensity=root:Packages:Irena_PDDF:PDFFitIntensity		//produced by IR1R_CalculateChisquared
		Duplicate/O CurrentResultPdf, diffWave
		Duplicate/O R_distribution, diffWaveX
		Differentiate diffWave
		Differentiate diffWaveX
		diffWave=abs(diffWave)/abs(diffWaveX)		//this is suppose to create derivative of the CurrentSizeDistribution
		Smoothness=sum(diffWave,-inf,inf)
//		NVAR CurrentEntropy=root:Packages:Sizes:CurrentEntropy
		NVAR CurrentChiSq=root:Packages:Irena_PDDF:CurrentChiSq
		NVAR CurChiSqMinusAlphaEntropy=root:Packages:Irena_PDDF:CurChiSqMinusAlphaEntropy
		Duplicate/O PDFFitIntensity, zscratch2
		
		zscratch2 = (( Intensity[p] - PDFFitIntensity[p]) / Errors[p])^2	//residuals
		CurrentChiSq = sum(zscratch2)			//new Chisquared
		
		CurChiSqMinusAlphaEntropy=CurrentChiSq - tolerance*Smoothness
		KillWaves/Z diffWave, diffWaveX, zscratch2	
		IR2Pr_FinishGraph()
		DoUpdate

//		print "("+num2str(i+1)+")     Chi squared value:  " + num2str(Chisquarered) + ",    target value:   "+num2str(M)
  
		if (Chisquared>M)
			LogAMax=MidPoint
		else
			LogAmin=MidPoint
		endif
		i+=1
		if (i>M || (Chisquared - PriorChisquared)==0)											//no solution found
			return NaN
		endif
		NumberIterations+=1
		PriorChisquared = Chisquared
	while(abs(Chisquared-M)>tolerance)				//how much can I divide 200 points interval before it is useless?
	
	NVAR Chisquare=root:Packages:Irena_PDDF:Chisquare
	Chisquare=Chisquared
	NVAR Background=root:Packages:Irena_PDDF:Background
	NVAR maximumR=root:Packages:Irena_PDDF:maximumR

	variable/g CurrentRg=IR2Pr_regRg(CurrentResultPdf,R_distribution)
	variable/g CurrentRgError=NaN
	string FitNote="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("TagSize")+"Fit using Regularization "
	Fitnote+="\rMaximum extent "+num2str(maximumR)+"  A"//+" ± "+num2str(MooreParametersS[Moore_NumOfFncts+2])+" ≈"
//	Fitnote+="\r"+num2str(Moore_NumOfFncts)+" basis functions used"
//	fitnote+="\rScale Factor = "+num2str(MooreParametersV[Moore_NumOfFncts+3])+" ± "+num2str(MooreParametersS[Moore_NumOfFncts+3])
	fitnote+="\rRadius of Gyration = "+num2str(CurrentRg)+"  A"
	Fitnote+="\rBackground "+num2str(Background)
//	Fitnote+="\rReduced Chi Squared "+num2str(Chisquared/(numpnts(Intensity)-1))
	print fitnote
	string/g FittingResults
	FittingResults=FitNote
	TextBox/W=IR2Pr_PDFInputGraph/C/N=MooreFitNote/A=MC fitnote 

	return i
	SetDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2Pr_PDDFCalculatePrVariation()

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF
	Wave Intensity=root:Packages:Irena_PDDF:Intensity
	Wave Errors=root:Packages:Irena_PDDF:Errors
	Wave R_distribution=root:Packages:Irena_PDDF:R_distribution
	NVAR Evalue=root:Packages:Irena_PDDF:Evalue

	//Wave M_Lower									//results in these matrices for next step:
	//Wave M_Upper
	//Wave W_LUPermutation
	Wave A_matrix
	Wave G_matrix	=root:Packages:Irena_PDDF:G_matrix
	Duplicate/O R_distribution, BinWidth, PDDFErrors
	BinWidth = IR2Pr_BinWidthInRadia(p)
	//and here we need to do the MonteCarlo method... 
	variable i, MontCarloMax=100		//number of MonteCarlo iterations
	Duplicate/O Intensity, MontIntensity
	Make/O/N=(numpnts(R_distribution), (MontCarloMax)) MontStatWave
	For(i=0;i<MontCarloMax;i+=1)
		MontIntensity = Intensity+gNoise(1)*Errors	//this will create new intensity - original + Gaussian e-noise * Error, practically ideal, if this is proper Sdev error... 
		MatrixOp/O B_vector = G_matrix^t x (MontIntensity /(Errors*Errors))	
		Wave B_vector
		//MatrixLUBkSub M_Lower, M_Upper, W_LUPermutation, B_vector				//Backsubstitute B to get x[]=inverse(A[][]) B[]	
		MatrixLinearSolve/M=1 A_matrix, B_vector
		Wave M_B																		//this is created by MatrixLUBkSub
		Redimension/D/N=(-1,0) M_B													//create from M_x[..][0] only M_x[..] so it is simple wave
		MatrixOp/O CurrentResultMontCarlo = M_B / BinWidth
		MontStatWave[][i]=CurrentResultMontCarlo[p]
	endfor
	
	For(i=0;i<Numpnts(R_distribution);i+=1)
		Duplicate/O/R=[i][] MontStatWave, testWv
		wavestats/Q testWv
		PDDFErrors[i] = V_sdev
	endfor
//	MatrixOP/O RegPDFErrors = varCols(MontStatWave)
//	MatrixOP/O RegPDFErrors = RegPDFErrors^t
	KillWaves/Z  testWv, MontStatWave, BinWidth, CurrentResultMontCarlo
	SetDataFolder OldDf

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
 static Function IR2Pr_BinWidthInRadia(i)			//calculates the width in radia by taking half distance to point before and after
	variable i								//returns number in A

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

	Wave R_distribution=root:Packages:Irena_PDDF:R_distribution
	variable width
	variable Imax=numpnts(R_distribution)
	
	if (i==0)
		width=R_distribution[1]-R_distribution[0]
	elseif (i==Imax-1)
		width=R_distribution[i]-R_distribution[i-1]
	else
		width=((R_distribution[i]-R_distribution[i-1])/2)+((R_distribution[i+1]-R_distribution[i])/2)
	endif
	return width
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR2Pr_CalculateAmatrix(aValue)					//generates A matrix
	variable aValue

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

	Wave D_matrix=root:Packages:Irena_PDDF:D_matrix
	Wave H_matrix=root:Packages:Irena_PDDF:H_matrix
	
	Duplicate/O D_matrix A_matrix
	A_matrix=0
	A_matrix=D_matrix[p][q]+aValue*H_matrix[p][q]
	setDataFolder OldDf
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
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR2Pr_CalculateChisquared()			//calculates Chisquared difference between the data
		//in Intensity and result calculated by G_matrix x x_vector

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

	Wave Intensity=root:Packages:Irena_PDDF:Intensity
	Wave G_matrix=root:Packages:Irena_PDDF:G_matrix
	Wave Errors=root:Packages:Irena_PDDF:Errors
	Wave M_x=root:Packages:Irena_PDDF:M_x

	Duplicate/O Intensity, NormalizedResidual, ChisquaredWave	//waves for data
	IN2G_AppendorReplaceWaveNote("NormalizedResidual","Units"," ")
	
	
	MatrixMultiply  G_matrix, M_x				//generates scattering intesity from current result (M_x - before correction for contrast and diameter)
	Wave M_product	
	Redimension/D/N=(-1,0) M_product			//again make the matrix with one dimension 0 into regular wave

	Duplicate/O M_product PDFFitIntensity
	Note/K PDFFitIntensity
	Note PDFFitIntensity, note(Intensity)

	NormalizedResidual=(Intensity-M_product)/Errors		//we need this for graph
	ChisquaredWave=NormalizedResidual^2			//and this is wave with Chisquared
	setDataFolder OldDf
	return (sum(ChisquaredWave,-inf,inf))				//return sum of Chisquared
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
//*****************************************************************************************************************
//		Diagnostic functions

static  Function IR2Pr_SetupDiagnostics()
	
	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

//	NVAR Diagnostics=root:Packages:Irena_PDDF:ShowDiagnostics
//	
//	DoWindow IR1S_RegDiagnosticsWindow
//	if (V_Flag)
//		DoWindow/K IR1S_RegDiagnosticsWindow
//	endif	
//	
//	if (Diagnostics)
//		//here we need to setup the waves and graphs as needed
//	//	Make/O/N=0 DiagLogAVal, DiagLogChisquareDivN, DiagSmoothness
//		
//		execute ("IR1S_RegDiagnosticsWindow()")
//		
//	endif
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR2Pr_MakeHmatrix()									//makes the H matrix

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF

	Wave R_distribution=root:Packages:Irena_PDDF:R_distribution
	
	variable numOfPoints=numpnts(R_Distribution), i=0, j=0

	Make/D/O/N=(numOfPoints,numOfPoints) H_matrix			//make the matrix
	H_matrix=0												//zero the matrix
	
	For(i=2;i<numOfPoints-2;i+=1)								//this fills with 1 -4 6 -4 1 most of the matrix
		For(j=0;j<numOfPoints;j+=1)
			if(j==i-2)
				H_matrix[i][j]=1
			endif
			if(j==i-1)
				H_matrix[i][j]=-4
			endif
			if(j==i)
				H_matrix[i][j]=6
			endif
			if(j==i+1)
				H_matrix[i][j]=-4
			endif
			if(j==i+2)
				H_matrix[i][j]=1
			endif
		endfor
	endfor
															//now we need to fill in the first and last parts
	H_matrix[0][0]=1											//beginning of the H matrix
	H_matrix[0][1]=-2
	H_matrix[0][2]=1
	H_matrix[1][0]=-2
	H_matrix[1][1]=5
	H_matrix[1][2]=-4
	H_matrix[1][3]=1

	H_matrix[numOfPoints-2][numOfPoints-4]=1					//end of the H matrix
	H_matrix[numOfPoints-2][numOfPoints-3]=-4
	H_matrix[numOfPoints-2][numOfPoints-2]=5
	H_matrix[numOfPoints-2][numOfPoints-1]=-2
	H_matrix[numOfPoints-1][numOfPoints-3]=1
	H_matrix[numOfPoints-1][numOfPoints-2]=-2
	H_matrix[numOfPoints-1][numOfPoints-1]=1

	setDataFolder OldDf
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
//*****************************************************************************************************************

static Function IR2Pr_CalculateBVector()								//makes new B vector and calculates values from G, Int and errors

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF
	
	Wave G_matrix	=root:Packages:Irena_PDDF:G_matrix
	Wave Intensity	=root:Packages:Irena_PDDF:Intensity
	Wave Errors		=root:Packages:Irena_PDDF:Errors
//	variable M=DimSize(G_matrix, 0)							//rows, i.e, measured points number
//	variable N=DimSize(G_matrix, 1)							//columns, i.e., bins in distribution
//	variable i=0, j=0
//	Make/D/O/N=(N) B_vector									//points = bins in size dist.
//	B_vector=0
//	for (i=0;i<N;i+=1)					
//		For (j=0;j<M;j+=1)
//			B_vector[i]+=((G_matrix[j][i]*Intensity[j])/(Errors[j]*Errors[j]))
//		endfor
//	endfor
	MatrixOp/O B_vector = G_matrix^t x (Intensity /(Errors*Errors))

	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR2Pr_CalculateDMatrix()								//makes new D matrix and calculates values from G, Int and errors

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_PDDF
	
	Wave G_matrix=root:Packages:Irena_PDDF:G_matrix
	Wave Errors=root:Packages:Irena_PDDF:Errors
//	Wave G_matrix=root:Packages:Sizes:G_matrixQ2N
//	Wave Errors=root:Packages:Sizes:ErrorsQ2N
	
	variable N=DimSize(G_matrix, 1)							//rows, i.e, measured points number
	variable M=DimSize(G_matrix, 0)							//columns, i.e., bins in distribution
	variable i=0, j=0, k=0
	Make/D/O/N=(N,N) D_matrix	
	Duplicate/O Errors, Errors2
	Errors2=Errors^2

//	variable tiskst=ticks			
	D_matrix=0
	Duplicate/O G_matrix, G_matrix_ErrScaled
	for (i=0;i<N;i+=1)	
		for (j=0;j<M;j+=1)				
			G_matrix_ErrScaled[j][i]=G_matrix[j][i]/(Errors2[j])
		endfor
	endfor	
	MatrixOp/O D_matrix =  G_matrix_ErrScaled^t x G_matrix
//	D_matrix = testM
	KillWaves/Z Errors2, testM, G_matrix_ErrScaled

	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
