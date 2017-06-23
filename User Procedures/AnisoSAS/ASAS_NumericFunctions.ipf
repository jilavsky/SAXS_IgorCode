#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.2		

//1.2  Speedup 6/2017

//here go numeric calculations of ASAS


Function ASAS_CalcIntOf1Scatterer(Qval, PopNum, AlphaQ, OmegaQ)
		variable Qval, PopNum, AlphaQ, OmegaQ
		//DirNum
		//this function solves Andrews formula 3 for - dSigma/dOmega for one scatterer at 
		//particular Q with orientation AlphaQ and OmeagQ
		//we need to do the double summation 
		//over alpha from 0 to pi/2 
		//over omega from 0 to 2pi
		//using the probabilities p(alpha) and b(omega)
		// X=cos(nee)=f(alpha, omega, alphaQ, omegaQ)
		
		//string OldDf=GetDataFolder(1)
		//setDataFolder root:Packages:AnisoSAS:
		
		//now the parameters which we can get from the global variables, waves, strings
		NVAR Lambda=root:Packages:AnisoSAS:Wavelength

		Wave Pweight=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_AlphaDist")
		Wave Bweight=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_OmegaDist")
		NVAR R0=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_Radius")
		NVAR DeltaRho=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_DeltaRho")
		NVAR betaP=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_beta")
	
		NVAR UseTriangularDist=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_UseTriangularDist")
		NVAR UseGaussSizeDist=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_UseGaussSizeDist")
		if(abs(UseTriangularDist+UseGaussSizeDist-1)>0.01)
			UseTriangularDist=1
			UseGaussSizeDist=0
		endif
	
		//these waves contain the probability p(alpha) and b(omega), they have X scaling from 0 to pi/2 or 2pi
		//and they are normalized (area(p(alpha)*sin(alpha))=1 and area(b(omega))=1)
		variable k=ASAS_Calc_k()
		variable Nu0=ASAS_Calc_Nu0(R0, DeltaRho,Lambda )	
		variable XX
		//the result is result of double summation
		variable alphai, omegai
		variable omegapoint=0
		variable alphapoint=0
		variable result=0, tempResult=0
//		variable numOfTicks, startTicks		
//		startTicks=ticks
		NVAR IntegrationStepsInAlpha=root:Packages:AnisoSAS:IntegrationStepsInAlpha
		NVAR IntegrationStepsInOmega=root:Packages:AnisoSAS:IntegrationStepsInOmega
		variable OmegaStep=2*pi/IntegrationStepsInOmega	//user selected number of steps in omega, 200 default
		variable AlphaStep=(pi/2)/IntegrationStepsInAlpha		//user selected number of steps in omega, 90 steps default
		variable OmegaMax=2*pi			//omega goes to 2*pi
		variable AlphaMax=pi/2			//alpha goes to pi/2 
		
		//OK, let's try now do it through lookup table...
		//comment on local lookup table
		//the number of peaks in the range of X from 0 to 1 is:
		// numpeaks= 1 + abs(Q*R*(beta-1))/pi  for beta larger or smaller than 1 (same formula....)
		//  
		variable NumberOfPeaks=1 + abs(Qval*R0*(betaP-1))/pi		//calculate number of points needed to map our the dependence
		variable NumberOfPoints=floor(16*NumberOfPeaks)			//at least 20 points, 20 points per period
		if (NumberOfPoints>400)
			NumberOfPoints=300								//max 400 point, this is when there are more than 20 peaks 
		endif
		Make/D/FREE/N=(NumberOfPoints) LocalLookupTable			//make free, faster...
		SetScale/I x -1,1,"", LocalLookupTable
	//	SetScale/I x 0,1,"", LocalLookupTable	//set ot -1 to 1 to chek csome troubles with omega definitions...
//		LocalLookupTable=PRJ_AJA1_SBUSAXS_xsect(Lambda,Qval,R0,beta,Nu0,x)	//calculate the values using Pete's XOP
//		LocalLookupTable=ASAS_Formula4b(beta,Nu0,Qval,x,R0,k,0.001)				//calculate the values using formula 4b
//		LocalLookupTable=ASAS_Formula4a(beta,Nu0,Qval,x,R0,k,DeltaRho)			//the same using formula 4a
	//*********************************************************************************************
	//Now new logic:
	//give user the switch for use of diffraction limit (here, formula 4c)
	// or use of full formula 4a as before, using complex numbers.
	//give user chance to change between them and change width of the distribution for diffraction limit.
	//put in same distribution for full 4a, knowing, that it will take forever...
	//Size dist controls:
	NVAR PopFWHM=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_FWHM")
	NVAR UseTriangularDist=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_UseTriangularDist")
	NVAR UseGaussSizeDist=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_UseGaussSizeDist")
	NVAR GaussSDNumBins=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_GaussSDNumBins")
	NVAR GaussSDFWHM=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_GaussSDFWHM")
	
	//....
		NVAR UseOfFormula4	//Ok, this variable shoould have deafult value 1 (formula 4c, and value 2 for 4a, 3 for 4b
		
		if (UseOfFormula4==1)
			multithread LocalLookupTable=ASAS_Formula4c(betaP,Nu0,Qval,x,R0,k,DeltaRho,PopNum,PopFWHM,UseTriangularDist,UseGaussSizeDist,GaussSDNumBins,GaussSDFWHM )		//the same using formula 4c, refraction limit
		elseif(UseOfFormula4==2)
			multithread LocalLookupTable=ASAS_Formula4a(betaP,Nu0,Qval,x,R0,k,DeltaRho)			//the same using formula 4a
		elseif(UseOfFormula4==3)
			multithread LocalLookupTable=ASAS_Formula4b(betaP,Nu0,Qval,x,R0,k,0.001)				//calculate the values using formula 4b	
		endif
//		if (NumberOfPoints>300)
//			smooth 4, LocalLookupTable						//and if there are many points, smooth this thing to remove oscillations and get average curve
//		endif
		variable smoothNum=floor(numpnts(LocalLookupTable)/10)
		smooth (smoothNum), LocalLookupTable						// smooth this thing to remove oscillations and get average curve
					//this is now set to 10% smooth over XX, which may be needed to change later on by user for various problems. 
		make/Free/N=(1+ceil(OmegaMax/OmegaStep)) OmegaWv, TempR1, tempR2
		OmegaWv = OmegaStep * p
		TempR1 = Bweight(OmegaWv[p])
		make/Free/N=(1+ceil(AlphaMax/AlphaStep)) AlphaWv
		AlphaWv = AlphaStep * p
		tempR2 = Pweight(AlphaWv[p])
		make/Free/N=((1+ceil(AlphaMax/AlphaStep)),(1+ceil(OmegaMax/OmegaStep)))  XXWv, TempResWv
		variable OmegaQRad= pi*OmegaQ/180
		variable AplhaQRad= pi*AlphaQ/180
      variable sinAplhaQRad = sin(AplhaQRad)
      variable cosAplhaQRad = cos(AplhaQRad)
      variable sinOmegaQRad = sin(OmegaQRad)
      variable cosOmegaQRad = cos(OmegaQRad)
      
		multithread XXWv = ASAS_CalcCosEta(sinAplhaQRad,cosAplhaQRad,sinOmegaQRad,cosOmegaQRad,OmegaWv[q],AlphaWv[p])
		multithread TempResWv = TempR1[q] * LocalLookupTable(XXWv)
		multithread TempResWv = TempResWv*tempR2[p]*sin(AlphaWv[p])


		//for(alphai=0;alphai<=AlphaMax;alphai+=AlphaStep)  
			//tempResult=0
			//for(omegai=0;omegai<=OmegaMax;omegai+=OmegaStep)
					//first calculate X(cos(Nu0) for combination of these angles..
			//		XX=ASAS_CalcCosEta((pi*OmegaQ/180),(pi*AlphaQ/180),Omegai,Alphai)
			//	multithread XXWv = ASAS_CalcCosEta((OmegaQRad),(AplhaQRad),OmegaWv[p],Alphai)
					//XX is -1 and 1 to calculate omega anisotropy...
					//now calculate the b(omega) * d(sigma)/d(omega) for this combination of angles XX
			//		tempResult += Bweight(omegai)*LocalLookupTable(XX)
							//this is not faster... 
								//multithread TempR1 = Bweight(OmegaWv[p])
								//multithread TempR2 = LocalLookupTable(XXWv[p])
								//MatrixOp/O TempResWv = TempResWv * TempR2
				// tempResult collected all points on omega
			//endfor
			//now add this integration over omega for this one alpha into result and let's go on another alpha angle
			//result+=tempResult*Pweight(alphai)*sin(alphai)
		//	result+=sum(TempResWv)*Pweight(alphai)*sin(alphai)
		//endfor
 		result = sum(TempResWv)
		//and now multiply by * d(omega) * d(alpha)
		result=result*OmegaStep*AlphaStep
		
//		numOfTicks=ticks- startTicks
//		print numOfTicks/60
		
		return result
//		KillWaves/Z LocalLookupTable
end

//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

threadsafe Function ASAS_Calc_k()	//works fine

	NVAR Lambda=root:Packages:AnisoSAS:Wavelength
	return 2*pi/lambda
end

//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

threadsafe Function ASAS_Calc_Nu0(Radius, DeltaRho,Lambda )		//works fine
	variable Radius, DeltaRho,Lambda

	variable Nu0
	Nu0=2*radius*DeltaRho*lambda/10^16		// /10^16 is conversion of delat rho cm^-2 to A^-2		
	return Nu0
end

//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//
//threadsafe Function ASAS_CalcCosEta(OmegaQ,AlphaQ,Omega,Alpha)
//	variable OmegaQ,AlphaQ,Omega,Alpha
//	
//	variable result1, result2, result3
//	
//	result1=cos(OmegaQ)*cos(Omega)*sin(Alpha)*sin(AlphaQ)
//	result2=sin(omegaQ)*sin(Omega)*sin(AlphaQ)*sin(Alpha)
//	result3=cos(AlphaQ)*cos(Alpha)
//	
//	return result1+result2+result3
//
//end

threadsafe Function ASAS_CalcCosEta(sinAplhaQRad,cosAplhaQRad,sinOmegaQRad,cosOmegaQRad,Omega,Alpha)
	variable sinAplhaQRad,cosAplhaQRad,sinOmegaQRad,cosOmegaQRad,Omega, Alpha 
	
	//variable result1, result2, result3
	
	//result1=(cosOmegaQRad*cos(Omega) + sinOmegaQRad*sin(Omega))*sin(Alpha)*sinAplhaQRad + cosAplhaQRad*cos(Alpha)
	//result2=sin(omegaQ)*sin(Omega)*sin(AlphaQ)*sin(Alpha)
	//result3=

//	result1=(cos(OmegaQ)*cos(Omega) + sin(omegaQ)*sin(Omega))*sin(Alpha)*sin(AlphaQ)
//	//result2=sin(omegaQ)*sin(Omega)*sin(AlphaQ)*sin(Alpha)
//	result3=cos(AlphaQ)*cos(Alpha)
	
	return (cosOmegaQRad*cos(Omega) + sinOmegaQRad*sin(Omega))*sin(Alpha)*sinAplhaQRad + cosAplhaQRad*cos(Alpha)

end


//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

threadsafe Function ASAS_CalcK_beta_X(betaP,X)	//works fine
	variable betaP, X

	return sqrt(1+(betaP^2-1)*X^2)

end

//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

threadsafe Function ASAS_Formula4b(betaP,Nu0,Qval,X, R0, k,precision)
		variable betaP,Nu0,Qval,X, R0, k,precision
		
		variable commonfactor
		variable mMax=328
		variable PreviousResultToCompare
		variable currentFractDiff
		variable KBetaX=ASAS_CalcK_beta_X(betaP,X)		
		commonfactor=k*k*R0*R0*R0*R0*KBetaX*KBetaX
		variable/C result=cmplx(0,0)
		variable i, resultReal
		For (i=1;i<=mMax;i+=1)				//calculated for m=1 and 2
			result+=ASAS_CalcOneMterm(betaP,Nu0,Qval,X, R0, i, KBetaX)		
			resultReal=(cabs(result))^2
			if (mod(i,4)==0)
				currentFractDiff=abs((resultReal-PreviousResultToCompare)/PreviousResultToCompare)
				if (currentFractDiff<precision)
					break
				endif
				PreviousResultToCompare=resultReal
			endif
		endfor
		resultReal*=commonfactor
		return resultReal
end



threadsafe Function ASAS_Formula4a(betaP,Nu0,Qval,XX,R0,k, DeltaRho)
	variable betaP, Nu0, XX, Qval, R0, k, DeltaRho
	
	setDataFolder root:Packages:AnisoSAS
	//this thng calculates the formula 4a for Andrews anis SAS
	//First we need to calculate the integral, let's get the numbers into waver to be ablet o see them if necessary
	variable KbetaX=ASAS_CalcK_beta_X(betaP,XX)
	variable result=0

	variable MynumPnts=(Qval*R0*KbetaX/6.2)*20+40	//Qval*R0*KbetaX/6.2 is about number of periods, 20 points per period here
	MynumPnts=floor(MynumPnts)
	
//	this is formula which uses only real numbers, but unluckily runs slower than the complex... 
//	Make/O/N=(MynumPnts)/D IntgWave1
//	SetScale/I x 0,1,"", IntgWave1
//	IntgWave1=x*bessJ(0,(Qval*R0*KbetaX*x))*2*sin(0.5*beta*Nu0*sqrt(1-x^2)/KbetaX)
//	Duplicate/O IntgWave1, IntgWave2
//	IntgWave1=IntgWave1*cos(0.5*beta*Nu0*sqrt(1-x^2)/KbetaX)
//	IntgWave2=IntgWave2*sin(0.5*beta*Nu0*sqrt(1-x^2)/KbetaX)
//	result=(k*R0^2*KbetaX)^2*((area(IntgWave1,0,1))^2+(area(IntgWave2,0,1))^2)

//	this is Full basic fomula 4 using coplex numbers, runs faster than real formula....  
	Make/C/FREE/N=(MynumPnts)/D tempIntegralWave
	Make/FREE/N=(MynumPnts)/D RealIntegralWave, ImagIntegralWave
	SetScale/I x 0,1,"", tempIntegralWave, RealIntegralWave, ImagIntegralWave
	variable/C tempResult
	tempResult=0
	//this is without integration per various Rs
	multithread tempIntegralWave=cmplx(x*bessJ(0,(Qval*R0*KbetaX*x)),0)*(1-exp(cmplx(0,(betaP*Nu0*sqrt(1-x^2)/KbetaX))))
	multithread RealIntegralWave=real(tempIntegralWave)
	multithread ImagIntegralWave=Imag(tempIntegralWave)
	tempResult=cmplx(0,k*r0^2*KbetaX)*cmplx(area(RealIntegralWave,0,1),area(ImagIntegralWave,0,1) )
	result=(cabs(tempResult))^2		
	return result
end


threadsafe Function ASAS_Formula4c(betaP,Nu0,Qval,XX,R0,k, DeltaRho,PopulationNumber, PopFWHM, UseTriangularDist,UseGaussSizeDist,GaussSDNumBins,GaussSDFWHM  )
	variable betaP, Nu0, XX, Qval, R0, k, DeltaRho,PopulationNumber, PopFWHM, UseTriangularDist,UseGaussSizeDist,GaussSDNumBins,GaussSDFWHM
	
	//setDataFolder root:Packages:AnisoSAS
	//this thng calculates the formula 4a for Andrews anis SAS
	//First we need to calculate the integral, let's get the numbers into waver to be ablet o see them if necessary
	variable KbetaX=ASAS_CalcK_beta_X(betaP,XX)
	variable result=0

	variable MynumPnts=(Qval*R0*KbetaX/6.2)*20+40	//Qval*R0*KbetaX/6.2 is about number of periods, 20 points per period here
	MynumPnts=floor(MynumPnts)
	
//	In diffraction limit only.... 
//	Make/O/N=(MynumPnts)/D IntgWave1
//	SetScale/I x 0,1,"", IntgWave1
//	IntgWave1=x*beta*Nu0*sqrt(1-x^2)*bessJ(0,(Qval*R0*KbetaX*x))/KbetaX
//	result=(k*R0^2*KbetaX)^2*(area(IntgWave1,0,1))^2
	
	
	
	//For now let's use only difraction limit, which is simple solution of formula 4c
	// however we can do the size distribution on it
	variable i
	variable localR, localVolume, localVolFraction, localCorrection, volume, summOfCorrections, radiusFractionalStep, HalfOfNumStepsM1
	
	if(UseTriangularDist)
		volume=4*pi*betaP*((R0)^3) / 3
		summOfCorrections=0
		radiusFractionalStep=PopFWHM/4                // = 0.1 for default case
				//we'll take only 4 steps above and 4 steps below the R0
		For (i=-4;i<=4;i+=1)
			localR=R0*(1+i*radiusFractionalStep)
			localVolume=4*pi*betaP*((LocalR)^3) / 3
			localVolFraction=0.2 - abs(i)*0.04
				
			localCorrection=localVolFraction*volume/localVolume
			summOfCorrections+=localCorrection
			result += localCorrection*(localVolume^2*(DeltaRho*1e-16)^2*9*pi/2)*(bessJ(1.5, Qval*LocalR*KbetaX, 1)/(Qval*LocalR*KbetaX)^1.5)^2
			
		endfor
		result=result / summOfCorrections
	else	
		GaussSDNumBins = floor(GaussSDNumBins)	//make sure numBins is not fractional number....
		if(mod(GaussSDNumBins,2)<0.25)   //number of bins is even, need odd
			GaussSDNumBins+=1
		endif
		HalfOfNumStepsM1=floor((GaussSDNumBins-1)/2)
		make/Free/N=(GaussSDNumBins) TempGaussRadiusWv, TempGaussDistribution
		//lets use Gauss distribution here for simplicity
		volume=4*pi*betaP*((R0)^3) / 3
		summOfCorrections=0
		radiusFractionalStep=(1.5*R0*GaussSDFWHM)/GaussSDNumBins                // fraction of step
		if(GaussSDFWHM>1)
			GaussSDFWHM = 0.6
			//abort "Error in Gauss FWHM of Radius - must be smaller than 0.6"
		endif
		TempGaussRadiusWv = R0 - HalfOfNumStepsM1*radiusFractionalStep + p* radiusFractionalStep
		TempGaussDistribution = ASAS_GaussDistProbability(TempGaussRadiusWv,R0,(R0*GaussSDFWHM))
		TempGaussDistribution = TempGaussDistribution * radiusFractionalStep
		variable tempSc=sum(TempGaussDistribution )
		TempGaussDistribution = TempGaussDistribution/tempSc	
		For (i=0;i<GaussSDNumBins;i+=1)		//this steps through the point in distribution
			localR=TempGaussRadiusWv[i]
			localVolume=4*pi*betaP*((LocalR)^3) / 3
			localVolFraction = TempGaussDistribution[i]
			localCorrection=localVolFraction*volume/localVolume
			summOfCorrections+=localCorrection
			result += localCorrection*(localVolume^2*(DeltaRho*1e-16)^2*9*pi/2)*(bessJ(1.5, Qval*LocalR*KbetaX, 1)/(Qval*LocalR*KbetaX)^1.5)^2
		endfor	
		result=result / summOfCorrections
	endif
	return result
end

threadsafe Function ASAS_GaussDistProbability(Xval,CenterVal,FWHM)
	variable Xval,CenterVal,FWHM
	
	return exp(-((Xval-CenterVal)^2/(FWHM^2))) /((sqrt(2*pi)*FWHM/sqrt(2)))

end

//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

threadsafe Function/C ASAS_CalcOneMterm(betaP,Nu0,Qval,XX, R0, m, KBetaX)
	variable betaP,Nu0,Qval,XX, R0, m, KBetaX
	
	//setDataFolder root:Packages:AnisoSAS
	variable/C resultCmplx, result
	variable tempresult
	Wave GammaWv=root:Packages:AnisoSAS:GammWv
	//GammaWv[1] has GammaFnct for 1+1/2, GammaWv[2] for 1+2/2 etc...
	//these arfe now generated for up to 300+0.5
	
	tempresult=2^(m/2) * GammaWv[m] * ASAS_Jfunction(Qval, R0,KBetaX,m)
	resultCmplx=cmplx(0,ASAS_BetaNu0KbetaX(betaP, Nu0, KBetaX))
	
	result=resultCmplx^m * tempresult
	
	return result
end

//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

threadsafe Function ASAS_Jfunction(Qval, R0,KBetaX,m)		//works fine
	variable Qval, R0,KBetaX,m
	
	variable tempTerm=Qval*R0*KBetaX
	variable result
	
	result=(bessJ((1+m/2), tempTerm , 1  , 1e-7)) / (tempTerm^(1+m/2))
	
	return result
end

//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

threadsafe Function ASAS_BetaNu0KbetaX(betaP, Nu0, KBetaX)	//works fine
	variable betaP, Nu0, KBetaX
	
	return betaP*Nu0/KBetaX
end

//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
