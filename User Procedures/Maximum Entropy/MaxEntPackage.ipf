#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.0

//Maximum Entropy for 1D data. Jan Ilavsky, June 1, 2008
//This code is implementation of Bryan Skilling code in conversion by Pete Jemian to Fortran and then C. I do not claim 
//ownership of this code!!!n                                              *********   Yet, if you need help, try e-mailing me: ilavsky@aps.anl.gov   *********
//This code is in public domain and was published at least as part of PhD Thesis of Pete Jemian (long tim ago :-)), but it has been in public domain even before that. 
//No copyright on this code is allowed in any way... This implementation is free for any use and has to be distributed with at least the comments section from original code.
//No warranties of any time are provided and will be assumed by me or my employer. Use at your own risk.  

//use:
//	NumberIterations=MEM_MaximumEntropy(MeasuredData,MeasuredDataErrorrs,SkyBackground,MaxsasNumIter,ModelDistribution,MaxEntStabilityParam,Opus,Tropus,MaxEntUpdateDataForGrph)
//  MeasuredData   - measured data (wave N points)
//  MeasuredDataErrorrs - data for the errors (Wave N points)
//  Sky background - non zero level with which all bins are started. Usually the smallest assumed level in each bin assumed. Note, bins are reset to this value when smlaler value would be needed
//                                Therefore - you cannot achieve smaller value then this... Variable, larger than 0. !!!! Very sensitive !!!! This is likely source of failure of fitting!
//  MaxsasNumIter - maximum number of iterations allowed. After this number of iterations this routine will end. Variable
//  ModelDistribution - the results. This is the distribution sought. Wave M points.
//  MaxEntStabilityParam - controls how fast the MEM converges. generally OK in default value.  Variable
//   Opus - function which converts distribution to data. See example. Follow the example, it is important... 
//   Tropus - function inverted. See below for example. Follow the example, it is important...
//  MaxEntUpdateDataForGrph  - rutine used to update graphs after each iteration. Can be empty, but then you have no idea what is happening... 

//  Examples of functions:
// Note, in the case of this example the (Opus) : ModelIntensity =  Gmatrix x ModelDistribution
// Tropus is then ModelDistribution = Gmatrix^h x ModelIntensity
// Note the parameters in these functions are in different orders...
//
//Examples of functions:
// Function Opus(ModelDistribution, ModelIntensity)			//ModelDistribution to ModelIntensity
//		wave ModelIntensity,ModelDistribution
//		string OldDf=GetDataFolder(1)
//		setDataFolder root:Packages:Sizes
//		Wave G_matrix=root:Packages:Sizes:G_matrix
//		MatrixOp/O ModelIntensity =G_matrix x ModelDistribution 
//		setDataFolder OldDf
//end
// Function TrOpus(ModelIntensity, ModelDistribution)			// ModelIntensity to ModelDistribution
//		wave ModelIntensity,ModelDistribution
//		string OldDf=GetDataFolder(1)
//		setDataFolder root:Packages:Sizes
//		Wave G_matrix=root:Packages:Sizes:G_matrix
//		MatrixOp/O  ModelDistribution =G_matrix^h  x  ModelIntensity   //note, this is Hermitian transpose
//		setDataFolder OldDf
//end
//Function UpdateGraph(CurrentModel, iteration)
//		wave CurrentModel
//		variable iteration  
//		//This function is run to update data for graphing purposes
//		//do whatever you need here to update your graph after each iteration
//		// typically one needs to updae graph, calculate chisquare and display it and may be calculate and display residuals.
//		//if you need to change parameters, you have to modify the FuncRef function MEM_UpdateDataForGrph to reflect the changes
//		use Opus to create data as needed. Yourt current data are in the ModelDistribution, use that to create current model values and create chi square etc. 
//end


//*****************************************************************************************************************************
//*****************************************************************************************************************************
// The code in this procedure file is conversion of Fortran and C source code from Pete Jemian, with other credits listed below.
// The code has been debugged and verified WRT to the compiled source code.
// 
//C       Analysis of small-angle scattering data using the technique of
//C       entropy maximization.
//
//
//C   Adapted from the program MAXE.FOR
//
//
//C       Credits:
//C       G.J. Daniell, Dept. of Physics, Southampton University, UK
//C       J.A. Potton, UKAEA Harwell Laboratory, UK
//C       I.D. Culverwell, UKAEA Harwell Laboratory, UK
//C       G.P. Clarke, UKAEA Harwell Laboratory, UK
//C       A.J. Allen, UKAEA Harwell Laboratory, UK
//C       P.R. Jemian, Northwestern University, USA
//
//
//C       References:
//C       1. J Skilling and RK Bryan; MON NOT R ASTR SOC
//C               211 (1984) 111 - 124.
//C       2. JA Potton, GJ Daniell, and BD Rainford; Proc. Workshop
//C               Neutron Scattering Data Analysis, Rutherford
//C               Appleton Laboratory, UK, 1986; ed. MW Johnson,
//C               IOP Conference Series 81 (1986) 81 - 86, Institute
//C               of Physics, Bristol, UK.
//C       3. ID Culverwell and GP Clarke; Ibid. 87 - 96.
//C       4. JA Potton, GK Daniell, & BD Rainford,
//C               J APPL CRYST 21 (1988) 663 - 668.
//C       5. JA Potton, GJ Daniell, & BD Rainford,
//C               J APPL CRYST 21 (1988) 891 - 897.
//
//
//C       This progam was written in BASIC by GJ Daniell and later
//C         translated into FORTRAN and adapted for SANS analysis.  It
//C         has been further modified by AJ Allen to allow use with a
//C         choice of particle form factors for different shapes.  It
//C         was then modified by PR Jemian to allow portability between
//C         the Digital Equipment Corporation VAX and Apple Macintosh
//C         computers.
//
//
//*****************************************************************************************************************************
//*****************************************************************************************************************************


Function MEM_MaximumEntropy(MeasuredData,Errors,InitialModelBckg,MaxIterations,Model,MaxEntStabilityParam,OpusFnct,TropusFnct,UpdateGraph)
	wave MeasuredData,Errors,Model
	variable MaxIterations,MaxEntStabilityParam, InitialModelBckg
	FuncRef MEM_ModelOpus OpusFnct		//converts the Model to MeasuredData
	FuncRef MEM_ModelTrOpus TropusFnct	//converts the MeasuredData into Model
	FuncRef MEM_UpdateDataForGrph UpdateGraph	//converts the MeasuredData into Model

	//set starting model to sky background...
	Model = InitialModelBckg
	
	//create working folder...
	string OldDf=GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:MaxEntTempFldr
	variable npnts=numpnts(MeasuredData)			//number of measure points
	variable nbins=numpnts(Model)					//number of bins in model
	
	make/D/O/N=(3,3) flWv
	make/D/O/N=3 blWv
	WAVE flWv=root:Packages:MaxEntTempFldr:flWv
	WAVE blWv=root:Packages:MaxEntTempFldr:blWv
	flWv=0
	blWv=0

	variable/g chitarg//=root:Packages:MaxEntTempFldr:chitarg
	variable/g chizer//=root:Packages:MaxEntTempFldr:chizer
	variable/g fSum//=root:Packages:MaxEntTempFldr:fSum
	variable/g blank//=root:Packages:MaxEntTempFldr:blank
	variable/g CurrentEntropy//=root:Packages:MaxEntTempFldr:CurrentEntropy
	variable/g CurrentChiSq//=root:Packages:MaxEntTempFldr:CurrentChiSq
	variable/g CurChiSqMinusAlphaEntropy//=root:Packages:MaxEntTempFldr:CurChiSqMinusAlphaEntropy
	fSum=0
	variable tolerance=MaxEntStabilityParam*sqrt(2*npnts) //for convergnence in Chisquare
	variable tstLim=0.05		//for convergence for entropy terms

	variable/g Chisquare//=root:Packages:MaxEntTempFldr:Chisquare
	Chisquare=0
	chizer = npnts		//setup some starting conditions
	chitarg = chizer 
	variable iter=0, snorm=0, cnorm=0,tnorm=0, a=0, b=0 , test=0, i=0, j=0, l=0, fchange=0, df=0, sEntropy=0, k=0
	duplicate/O MeasuredData, ox, ascratch, bscratch, etaScratch	, zscratch, zscratch2		//create work waves with measured Points length
	duplicate/O Model, cgrad,sgrad, ModelScratch, ModelScratch2, xiScratch		//create work waves with bins length
	make/O/D/N=(numpnts(Model),3) xi
	make/O/D/N=(numpnts(MeasuredData),3) eta
	Make/O/D/N=3  c1,s1, betaMX
	Make/O/D/N=(3,3) c2, s2
	
	
	For(iter=0;iter<MaxIterations;iter+=1)		//this is the main loop which does the searching for solution
	
		OpusFnct(Model,ox)						//calculate ox model result from Model
		DoUpdate
		Chisquare=0
		ascratch = (ox - MeasuredData) / Errors
		ox = 2 * ascratch / Errors
		ascratch=ascratch^2
		Chisquare = sum(ascratch)
		TropusFnct(ox,cgrad)
		snorm=0
		cnorm=0
		tnorm=0
		test=0
		fSum=sum(Model)
		sgrad = -ln(Model/InitialModelBckg) / (InitialModelBckg * e)
		ModelScratch = Model * sgrad^2
		snorm = sum(ModelScratch)
		ModelScratch = Model * cgrad^2
		cnorm = sum(ModelScratch)
		ModelScratch = Model * sgrad * cgrad
		tnorm = sum(ModelScratch)
		
		snorm = sqrt(snorm)
		cnorm = sqrt(cnorm)
		a = 1
		b = 1/cnorm
		if (iter>0)
			test = sqrt(0.5*(1-tnorm/(snorm*cnorm)))
			a = 0.5 / (snorm * test)
			b = 0.5 * b / test
		endif
		xi[][0] = Model[p] * cgrad[p] / cnorm
		xi[][1] = Model[p] * (a * sgrad[p] - b * cgrad[p])

		xiscratch=xi[p][0]
		OpusFnct(xiscratch, etaScratch)
		eta[][0] = etaScratch[p]
		
		xiscratch=xi[p][1]
		OpusFnct(xiscratch, etaScratch)
		eta[][1] = etaScratch[p]
		
		ox = eta[p][1] / (Errors[p])^2
		
		TropusFnct(ox,xiscratch)
		xi[][2] = xiScratch[p]
		
		ModelScratch=Model[p] * xi[p][2]
		ModelScratch2=ModelScratch[p] * xi[p][2]
		a = sum(ModelScratch2)
		xi[][2] = ModelScratch[p]
		
		a= 1/sqrt(a)
		xi[][2] = a * xi[p][2]
		xiscratch=xi[p][2]
		OpusFnct(xiscratch,etascratch)
		eta[][2]=etascratch[p]
		
		For(i=0;i<3;i+=1)
			xiScratch=xi[p][i] * sgrad[p]
			s1[i]=sum(xiScratch)
			xiScratch=xi[p][i] * cgrad[p]
			c1[i]=sum(xiScratch)
		endfor
		c1=c1/Chisquare
		
		s2=0
		c2=0
		For(k=0;k<3;k+=1)
			For(l=0;l<=k;l+=1)
				For(i=0;i<nBins;i+=1)
					s2[k][l] = s2[k][l] - xi[i][k] * xi[i][l] / Model[i]
				endfor	
				For(j=0;j<nPnts;j+=1)
					c2[k][l] = c2[k][l] + eta[j][k] * eta[j][l] / ((Errors[j])^2)
				endfor	
			endfor
		endfor	
		s2 = s2 / InitialModelBckg
		c2 = 2 * c2 /Chisquare
		
        	c2[0][1] = c2[1][0]
        	c2[0][2] = c2[2][0]
        	c2[1][2] = c2[2][1]
        	s2[0][1] = s2[1][0]
        	s2[0][2] = s2[2][0]
        	s2[1][2] = s2[2][1]
        	betaMX[0] = -0.5 * c1[0] / c2[0][0]
        	betaMX[1] = 0
		betaMX[2] = 0
		if(iter>0)
			MEM_Move(3)
		endif
		//  Modify the current distribution (f-vector)
        	fSum = 0              // find the sum of the f-vector
        	fChange = 0          // and how much did it change?
        	For(i = 0;i<nBins;i+=1)
	          	df = betaMX[0]*xi[i][0]+betaMX[1]*xi[i][1]+betaMX[2]*xi[i][2]
      	    		IF (df < (-Model[i])) 
      	    			df = 0.001 * InitialModelBckg - Model[i]       // a patch
          		endif
          		Model[i] = Model[i] + df              // adjust the f-vector
          		fSum = fSum + Model[i]
          		fChange = fChange + df
        	endfor
			
		ModelScratch= Model/fSum		//fraction of Model(i) in this bin
		ModelScratch=ModelScratch * ln(ModelScratch)		
		sEntropy=-sum(ModelScratch)		// from Skilling and Brian eq. 1
		
		OpusFnct(Model,zscratch)
		zscratch = ( MeasuredData[p] - zscratch[p]) / Errors[p]	//residuals
		zscratch2 = zscratch^2
		Chisquare = sum(zscratch2)			//new Chisquared
		
		CurrentEntropy=sEntropy
		CurrentChiSq=Chisquare
		CurChiSqMinusAlphaEntropy=Chisquare - MaxEntStabilityParam*sEntropy
//		MEM_DisplayDiagnostics(CurrentEntropy,CurrentChiSq, CurChiSqMinusAlphaEntropy,iter)		//display data in diagnostic graphs, if needed
		//see, if we have reached solution
		OpusFnct(Model,ox)	
		UpdateGraph(Model, iter)
		if(abs(Chisquare - chizer) < tolerance)
			if(test<tstLim)	//same solution limit
			//solution found
				KillWaves/Z ascratch, bscratch, etaScratch	//cleanup
				KillWaves/Z  cgrad,sgrad, ModelScratch, ModelScratch2, xiScratch		//cleanup
				KillWaves/Z  xi, eta, c1,s1, betaMX, c2, s2
				setDataFolder OldDf
				return iter
			endif
		endif
		
	endfor
	KillWaves/Z ascratch, bscratch, etaScratch		//cleanup
	KillWaves/Z  cgrad,sgrad, ModelScratch, ModelScratch2, xiScratch		//cleanup
	KillWaves/Z  xi, eta, c1,s1, betaMX, c2, s2
	setDataFolder OldDf
	return iter
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function MEM_ModelOpus(MeasuredData,Model)
	wave MeasuredData,Model

	Abort "There is nothing here, this is just a model"
	
end

Function MEM_ModelTrOpus(Model, MeasuredData)
	wave MeasuredData,Model

	Abort "There is nothing here, this is just a model"
	
end

Function MEM_UpdateDataForGrph(CurrentModel, iteration)
	wave CurrentModel
	variable iteration
	
	//This function is run to update data for graphing purposes
	Abort "There is nothing here, this is just a model"
	
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static  Function MEM_Move(m)
	variable m

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:MaxEntTempFldr

	variable MxLoop=500				//for no solution	
	variable Passes=0.001			//convergence test
	NVAR Chisquare=root:Packages:MaxEntTempFldr:Chisquare
	NVAR chtarg=root:Packages:MaxEntTempFldr:chitarg
	NVAR chizer=root:Packages:MaxEntTempFldr:chizer
	NVAR fSum=root:Packages:MaxEntTempFldr:fSum
	NVAR blank=root:Packages:MaxEntTempFldr:blank
	Wave betaMX=root:Packages:MaxEntTempFldr:betaMX
	Wave c1=root:Packages:MaxEntTempFldr:c1
	Wave c2=root:Packages:MaxEntTempFldr:c2
	Wave s1=root:Packages:MaxEntTempFldr:s1
	Wave s2=root:Packages:MaxEntTempFldr:s2
 	
 	//debug stuff
		variable a1 = 0                       // lower bracket  "a"
		variable a2 = 1                       // upper bracket of "a"
		variable cmin = MEM_ChiNow (a1, m)		//get current chi
		variable ctarg
		IF ((cmin*Chisquare)>chizer) 
			ctarg = 0.5*(1 + cmin)
		endif
		IF ((cmin*Chisquare) <= chizer) 
			ctarg = chizer/Chisquare
		endif
		variable f1 = cmin - ctarg
		variable f2 = MEM_ChiNow (a2,m) - ctarg
		variable i, anew, fx
		For (i=0;i<MxLoop;i+=1)
			anew = 0.5 * (a1+a2)          //! choose a new "a"
			fx = MEM_ChiNow (anew,m) - ctarg
			//Ok, sometimes apparently the halving method does not work properly, since there is minimum between the 0 and 1
			//let's first check for that
				IF (f1*fx >0) 
					a1 = anew
					f1 = fx
				endif
				IF (f2*fx > 0)
					a2 = anew
					f2 = fx
				endif
//			endif
			IF (abs(fx) < Passes) 
				break
			endif
		endfor
//C  If the preceding loop finishes, then we do not seem to be converging.
//C       Stop gracefully 
		if (i>=MxLoop-1)
			Abort "	No convergence in alpha chop (MOVE). Loop counter = "+num2str(MxLoop)
		endif
		variable w = MEM_Dist (m)
		variable k
		IF (w > 0.1*fSum/blank)
			For(k=0;k<m;k+=1)
				betaMX[k] = betaMX[k] * SQRT(0.1 * fSum/(blank * w))
			endfor
		ENDIF
		chtarg = ctarg * Chisquare
		setDataFolder OldDf
		RETURN 0
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



static  Function MEM_Dist(m)
		variable m

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:MaxEntTempFldr

	NVAR Chisquare=root:Packages:MaxEntTempFldr:Chisquare
	NVAR chtarg=root:Packages:MaxEntTempFldr:chitarg
	NVAR chizer=root:Packages:MaxEntTempFldr:chizer
	NVAR fSum=root:Packages:MaxEntTempFldr:fSum
	NVAR blank=root:Packages:MaxEntTempFldr:blank
	Wave betaMX=root:Packages:MaxEntTempFldr:betaMX
	Wave c1=root:Packages:MaxEntTempFldr:c1
	Wave c2=root:Packages:MaxEntTempFldr:c2
	Wave s1=root:Packages:MaxEntTempFldr:s1
	Wave s2=root:Packages:MaxEntTempFldr:s2

	variable w = 0
	variable k, l, z
		For(k=0;k<m;k+=1)
			z = 0
			For(l=0;l<m;l+=1)
				z = z - s2[k][l] * betaMX[l]
			endfor
			w = w + betaMX[k] * z
		endfor
		variable Dist = w
	setDataFolder OldDf
	RETURN Dist
END
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************





static  Function MEM_ChiNow(ax,m)
	variable ax,m

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:MaxEntTempFldr

	NVAR Chisquare=root:Packages:MaxEntTempFldr:Chisquare
	NVAR chtarg=root:Packages:MaxEntTempFldr:chitarg
	NVAR chizer=root:Packages:MaxEntTempFldr:chizer
	NVAR fSum=root:Packages:MaxEntTempFldr:fSum
	NVAR blank=root:Packages:MaxEntTempFldr:blank
	Wave betaMX=root:Packages:MaxEntTempFldr:betaMX
	Wave c1=root:Packages:MaxEntTempFldr:c1
	Wave c2=root:Packages:MaxEntTempFldr:c2
	Wave s1=root:Packages:MaxEntTempFldr:s1
	Wave s2=root:Packages:MaxEntTempFldr:s2

	Make/D/O/N=(3,3) aWv
	aWv=0
	Make/D/O/N=3 bWv
	bWv=0
		variable bx = 1 - ax
		variable k, l, w, z
		
	for(k=0;k<m;k+=1)
		For(l=0;l<m;l+=1)
			aWv[k][l] = bx * c2[k][l]  -  ax * s2[k][l]
		endfor
		 bWv[k] = -(bx * c1[k]  -  ax * s1[k])
	endfor
	MEM_ChoSol(aWv,bWv,m,betaMX)
        w = 0
		for(k=0;k<m;k+=1)
			z = 0
			for(l=0;l<m;l+=1)
				z = z + c2[k][l] * betaMX[l]
			endfor
			 w = w + betaMX[k] * (c1[k] + 0.5 * z)
		endfor
		variable ChiNow = 1 +  w
		setDataFolder OldDf
	RETURN ChiNow
END

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static  Function MEM_ChoSol(a, b, m, betaMX)
	wave a, b, betaMX
	variable m

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:MaxEntTempFldr
	WAVE flWv=root:Packages:MaxEntTempFldr:flWv
	WAVE blWv=root:Packages:MaxEntTempFldr:blWv
//	flWv=0
//	blWv=0

		IF (a[0][0] <= 0) 
			Abort  "Fatal error in CHOSOL: a(0,0) = "+num2str(a[0][0])
		ENDIF
		flWv[0][0] = SQRT(a[0][0])
		variable i, j, z, k,i1
		For (i =1;i<m;i+=1)
			flWv[i][0] = a[i][0] / flWv[0][0]
			For (j = 1;j<=i;j+=1)
				z = 0
				For (k = 0;k<=(j-1);k+=1)
					z = z + flWv[i][k] * flWv[j][k]
				endfor
				z = a[i][j] - z
				if (j==i)
					flWv[i][j] = SQRT(z)
				else
					flWv[i][j] = z / flWv[j][j]
				endif
			endfor
		endfor
		blWv[0] = b[0] / flWv[0][0]
		For(i=1;i<m;i+=1)
			z = 0
			For ( k = 0;k<=i-1;k+=1)
				z = z + flWv[i][k] * blWv[k]
			endfor
			blWv[i] = (b[i] - z) / flWv[i][i]
		endfor
		betaMX[m-1] = blWv[m-1] / flWv[m-1][m-1]
		For (i1=0;i1<m-1;i1+=1)
			i = m-2 - i1
			z = 0
				For (k = i+1;k<m;k+=1)
					z = z + flWv[k][i] * betaMX[k]
				endfor
			betaMX[i] = (blWv[i] - z) / flWv[i][i]
		endfor
		setDataFolder OldDf
		RETURN 0
END
//
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
 

