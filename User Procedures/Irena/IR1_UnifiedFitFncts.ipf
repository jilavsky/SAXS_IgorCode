#pragma TextEncoding = "UTF-8"
#pragma rtGlobals = 3// Use strict wave reference mode and runtime bounds checking
#pragma version=2.36


constant IR2UversionNumber=2.23 			//Evaluation panel version number. 
//*************************************************************************\
//* Copyright (c) 2005 - 2026, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.36 remove k factor and set automatically per Greg's suggestion. 
//2.35 removed IR1A_UnifiedFitCalcIntOne which had bug anyway when LinkB was selected. Not needed, using IR1A_UnifiedCalcIntOne instead also for fitting. 
//2.34 fixed cursor calls to target graph "IR1_LogLogPlotU"
//2.34 Added Level0 Local level which conatins flat background and fixed minor issues with loacl fits export. Fixed control procs to handle them correctly.  
//2.33 fixes to how messages for CheckFitting parameters are defined. 
//2.32 prevent invariant from being negative. Happens when P<3 for level which is extending to infinity at which point invariant makes little sense anyway. 
//2.31 fixed IR1A_UnifiedCalcIntOne for when extension of data for SMR data requires extension, failed for rtGlobals=3
//2.30 combined with smaller ipf files: IR1_Unified_SaveExport.ipf
//		IR1_UnifiedSaveToXLS.ipf, and IR1_Unified_Fit_Fncts2.ipf
//2.26 fixes to IR2U_CalculateBranchedMassFr() per Greg's updated instructions. 
//2.25 Fixes to Dale's fixes - initial state for Invariant failed with debugger. 
//2.24 Dale's fixes... Needs checking. 
//2.23 Modifications requetsed by Dale to make possible to calculate range of levels for each Two phase system. 
//2.22 Fixed stale graph in Analyze results calculations. 
//2.21 modified TwoPhaseSys1-4 output per Dale's request. 
//2.20 fixed bug in IR2U_CalculateInvariantbutton
//2.19 modified to speed up, removed DoUpdate. Fixed error when plot widnow did not exist. 
//2.18 modified IR1A_UnifiedCalculateIntensity() to handle data which have Qmax less than 3*slit length
//2.17 Dale fixed function IR2U_CalculateInvariantbutton() to Warn the user that one can’t use "invariant btwn csrs" on SMR data and Automatically use the level-1 for B value when “All” is picked as the level in the two phase calculator (Analyze Results button on unified panel).
//2.16 minor fix pre Dale's request. 
//2.15 fixes to Graph display of local levels. 
//2.14 corrected Invariant analysis to do correctly phi*(1-phi) calculation to get phi. 
//2.13 more DWS changes, Uncerttainity analysis - modfied to change the tab to currently analyzed level tab. 
//2.12 many changes by Dale, corrections etc. Accepted all assumed working. 
//2.11 added DWS changes to two phase model and made fixes to invariant calculations
//2.10 fixed bug which caused in local fits held parameters to change in fitting routine to their starting guesses. 
//2.09 changed local fits to guess needed starting parameters from the values selected by cursors. 
//2.08 changes to provide optional panel with review of fitting parameters before fitting   
//2.07 fix to invariant calculations for levels which are using RgCuttOff. The invariant was incorrectly calculated for these levels before. 
//2.06 minor fix for Igor 6.30 
//2.05 adds COnfidence evaluation tool
//2.04 fixed tabulated contrasts for the Analyze results which included e10 even though panel showed that is should nto be included... This caused many orders of magnitude wrong results. 
//2.03 adds Two phase analysis code to Analyze results
//2.02 added license for ANL
//version 2.01 adds evaluation of special cases for Unified. 
	
//			from IR1_Unified_Fit_Fncts2.ipf
 //2.08 added check for errors = 0 
//2.07 modified fitting to include Igor display with iterations /N=0/W=0
//2.06 modified IR1A_UnifiedFitCalculateInt to handle data which are fitted to less than 3*slitlength
//2.05 added optional fitting constraints throught string and user input
//2.04 changes to provide user with fit parameters review panel before fitting
//2.03 added NoLimits option
//2.02 user found bug int eh code which caused fitting of RgCo parameters from not used levels. 
//2.01 added license for ANL



//This fit uses the function described in 
//  http://www.eng.uc.edu/~gbeaucag/PDFPapers/Beaucage2.pdf
//http://www.eng.uc.edu/~gbeaucag/PDFPapers/Beaucage1.pdf
//http://www.eng.uc.edu/~gbeaucag/PDFPapers/ma970373t.pdf
//
//The basic function is composed of a series of structural levels, each with the possibility to be 
//a) associated with the previous smaller size level (Rcutoff2 = Rg1 in
//	I2highq=B2q^(-p2)exp(-q^2Rg1^2/3) for the power-law region of 2)
//b) to follow mass fractal restrictions (calculate B for the mass fractal power law
//		I = B q^(-p)
//c) to display spherical Corelations as described by I(q) = I(q)/(1+p f(q etai)) where
//		p is a packing factor 8*vH/vO for vH = hard sphere volume and vO is occupied volume
//		and f(q eta) is the sphere amplitude function for spherical Corelations
//
//The intensity from each level is summed and the intensity from one level, i, is given by:
//Ii(q) = Gi exp(-q^2Rgi^2/3) + exp(-q^2Rg(i-1)^2/3)Bi {[erf(q Rgi/sqrt(6))]^3/q}^Pi
//
//This equation includes a) above if Rg(i-1) is the previous smaller Rg e.g. the primary
//		particles from a mass fractal level.
//		If there is no such dependence Rg(i-1) is set to 0 or it could be set to an independent 
//		size under unsual circumstances
//
//This equation can include b) if Bi is calculated using Bi = (G df/Rg^df) GammaFun(df/2) 
//		and the erf argument includes kqRgi/sqrt(6) where k is 1.06.  The latter can be included or
//		 ignored for high dimension mass fractals but becomes more important for dimensions less
//		than 2.
//		
//The equation can include c) by multiplying the entire level Ii(q) by a function that follows the 
//		the Born-Green approximation for Corelations (multiple particle Corelations) and this
//		works well for weak Corelations of any type but becomes more restricted to spherical 
//		Corelations as the Corelations become stronger.  The measure of the strength of the Corelations
//		is the packing factor p = 8 vH/vO as described above and for spherical particles this value
//		 can be 0 (no Corelations) to about 5.6 (calculate for FCC or HCP packing).  If assymetric 
//		particles (rods or sheets) are packing the number can be much higher and the spherical function
//		becomes less appropriate although it can be used in a pinch for weak Corelations.  The 
//		interpretation of p and eta become complicated in these cases.  As a general rule etai has to be
//		larger than Rgi as common sense would dictate.  The correlation function follows closely the
//		development of Fournet in Guinier and Fournet and in Fournet's PhD dissertation where it is 
//		better described but is in French...

//So the Unified needs to accomodate multiple levels each of which can potentially have 8 parameters
//		(including spherical Corelations): Rgi, Gi, Pi, Bi, etai, packi, RgCOi,k
//		where RCOi is usually Rg(i-1), as shown above, for hierarchical structures
//		(k is 1.06 for mass fractals and 1 for others)
//		Each level must also have the answer to at least three questions:
//		Are there Corelations:  qCori
//		Is this a Mass Fractal:  qMFi
//		Does this level terminate at high-q in the next lower level Rg:  qPL (PowerLimit)
//			That is, is this a hierarchical structure build from the previous smaller level.
//			a third option is to let the power law limit float as a free parameter although this is
//			rarely appropriate.
//
//Then we have several options for coding the unified function.
//		a) Write a dedicated code for a specific morphological model where all of the parameters are 
//			defined in terms of the model.  We have done this for corellated lamellae, rods, mass-fractals,
//			spheres, correlated spheres, RPA based polymer blends of arbitrary fractal dimension, polymer
//			gels among others.
//		b)  Write a generic unified code that allows a high degree of flexibility but which is naturally complex.
//
//For cases where you deal with a fairly complex and limited structural model option a) is most appropriate
//		and is easiest to understand.  We can't however write such code for each and every case.  Several of our
//		publications indicate how to go about calculating the unified parameters, for instance for a sheet structure 
//		8 parameters in the unified equation (for 2 levels) reduce to 3 free parameters, the contrast, 
//		thickness and diameter of the sheets.   Similarly rods can be described by 3 parameters the length, diameter 
//		and contrast.  Corelations in both systems add 2 other parameters although the spherical correlation function
//		can not be rigorously used except at extremely weak levels of correlation.
//
//This code deals with approach b) where only spherical correlatoins are dealt with but including an optional
//		mass fractal limitation (strictly limited to linear chains but useful for branched structures in application).
//
//The code begins with a panel to obtain fit parameters for 4 levels (28) and 12 questions.  We have fit wide q-range data
//		with up to 4 levels by combining USALS, SALS, USAXS, SAXS and XRD data.  The function could be extended to an
//		unlimited number of levels theoretically.
//
//List of parameters for each level:

//	 Level1Rg   
//	 Level1FitRg   
//	 Level1RgLowLimit   
//	 Level1RgHighLimit   
//	 Level1G   
//	 Level1FitG   
//	 Level1GLowLimit   
//	 Level1GHighLimit   
//	 Level1RgStep   
//	 Level1GStep   
//	 Level1PStep   
//	 Level1BStep   
//	 Level1EtaStep   
//	 Level1PackStep   
//	 Level1P   
//	 Level1FitP   
//	 Level1PLowLimit   
//	 Level1PHighLimit   
//	 Level1B   
//	 Level1FitB   
//	 Level1BLowLimit   
//	 Level1BHighLimit   
//	 Level1ETA   
//	 Level1FitETA   
//	 Level1ETALowLimit   
//	 Level1ETAHighLimit   
//	 Level1PACK   
//	 Level1FitPACK   
//	 Level1PACKLowLimit   
//	 Level1PACKHighLimit   
//	 Level1RgCO   
//	 Level1LinkRgCO   
//	 Level1FitRgCO   
//	 Level1RgCOLowLimit   
//	 Level1RgCOHighLimit   
//	 Level1K   
//	 Level1Corelations   
//	 Level1MassFractal   
//	 Level1DegreeOfAggreg   
//	 Level1SurfaceToVolRat   
//	 Level1Invariant   
//	 Level1RgError   
//	 Level1GError   
//	 Level1PError   
//	 Level1BError   
//	 Level1ETAError   
//	 Level1PACKError   
//	 Level1RGCOError

//2.36 - 8-23-2021 - per greg suggestion LevelXK if P is more than 3 then k=1 and if P is less than 3 k = 1.06  



Function IR1A_UnifiedCalculateIntensity()

	setDataFolder root:Packages:Irena_UnifFit

	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
	Wave/Z OriginalIntensity
	if(!WaveExists(OriginalIntensity))
		abort 
	endif
	Duplicate/O OriginalIntensity, UnifiedFitIntensity, UnifiedIQ4
	Redimension/D UnifiedFitIntensity, UnifiedIQ4
	Wave OriginalQvector
	//for slit smeared data may need to extend the Q range... 
	variable OriginalPointLength
	variable ExtendedTheData=0
	OriginalPointLength = numpnts(OriginalQvector)
	if(UseSMRData )
		if(OriginalQvector[numpnts(OriginalQvector)-1]<(3*SlitLengthUnif))
			ExtendedTheData = 1
			variable QlengthNeeded = 3*SlitLengthUnif - OriginalQvector[numpnts(OriginalQvector)-1]
			variable LastQstep = 2*(OriginalQvector[numpnts(OriginalQvector)-1] - OriginalQvector[numpnts(OriginalQvector)-2])
			variable NumNewPoints = ceil(QlengthNeeded / LastQstep)
			Duplicate/Free OriginalQvector, tmpQvec
			redimension/N=(OriginalPointLength+NumNewPoints) tmpQvec
			redimension/N=(OriginalPointLength+NumNewPoints) UnifiedFitIntensity, UnifiedIQ4
			tmpQvec[OriginalPointLength, numpnts(tmpQvec)-1] = OriginalQvector[OriginalPointLength-1] + LastQstep * (p-OriginalPointLength+1)
			Duplicate/O tmpQvec, UnifiedFitQvector, UnifiedQ4
		else
			Duplicate/O OriginalQvector, UnifiedFitQvector, UnifiedQ4	
		endif
	else
		Duplicate/O OriginalQvector, UnifiedFitQvector, UnifiedQ4
	endif
	//now the new model wabves are longer... 
	Redimension/D UnifiedFitQvector, UnifiedQ4
	UnifiedQ4=UnifiedFitQvector^4
	
	
	UnifiedFitIntensity=0
	
	variable i
	
	for(i=1;i<=NumberOfLevels;i+=1)	// initialize variables;continue test
		//IR1A_UnifiedCalcIntOne(i, UnifiedFitIntensity, UnifiedFitQvector)
		IR1A_UnifiedCalcIntOne(i,UnifiedFitQvector)
		Wave TempUnifiedIntensity
		UnifiedFitIntensity+=TempUnifiedIntensity
	endfor								
	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	UnifiedFitIntensity+=SASBackground	
	
	if(UseSMRData)
		duplicate/O  UnifiedFitIntensity, UnifiedFitIntensitySM
		IR1B_SmearData(UnifiedFitIntensity, UnifiedFitQvector, SlitLengthUnif, UnifiedFitIntensitySM)
		UnifiedFitIntensity=UnifiedFitIntensitySM
		KillWaves/Z UnifiedFitIntensitySM
	endif
	if(ExtendedTheData)
		//need to undo the extending of data
		redimension/N=(OriginalPointLength) UnifiedFitIntensity, UnifiedIQ4, UnifiedFitQvector, UnifiedQ4
	endif	
	UnifiedIQ4=UnifiedFitIntensity*UnifiedQ4
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1A_UnifiedCalcIntOne(level, OriginalQvector)
	variable level
	//Wave OriginalIntensity
	Wave OriginalQvector
	
	setDataFolder root:Packages:Irena_UnifFit
	
	Duplicate/O OriginalQvector, TempUnifiedIntensity
	Duplicate /O OriginalQvector, QstarVector
	Redimension/D TempUnifiedIntensity, QstarVector
	
	NVAR Rg=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Rg")
	NVAR G=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"G")
	NVAR P=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"P")
	NVAR B=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"B")
	NVAR ETA=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"ETA")
	NVAR PACK=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"PACK")
	NVAR RgCO=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgCO")
	NVAR K=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"K")
	NVAR Corelations=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Corelations")
	NVAR MassFractal=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"MassFractal")
	NVAR LinkRGCO=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"LinkRGCO")
	NVAR/Z LevelLinkB = $("root:Packages:Irena_UnifFit:Level"+num2str(level)+"LinkB")
	variable LocalLinkB=0
	if(NVAR_Exists(LevelLinkB))
		LocalLinkB = LevelLinkB
	endif
	if(LocalLinkB)
		B = G * exp(-1*P/2)*(3*P/2)^(P/2)*(1/Rg^P) 
	endif
	//2.36 - 8-23-2021 
	//if P is more than 3 then k=1 and if P is less than 3 k = 1.06  
	k = (P>3) ? 1 : 1.06
	//done... 
	
	if (LinkRGCO==1 && level>=2)
		NVAR RgLowerLevel=$("root:Packages:Irena_UnifFit:Level"+num2str(level-1)+"Rg")	
		RGCO=RgLowerLevel
	endif
	QstarVector=OriginalQvector/(erf(K*OriginalQvector*Rg/sqrt(6)))^3
	if (MassFractal)
		B=(G*P/Rg^P)*exp(gammln(P/2))
	endif
	
	TempUnifiedIntensity=G*exp(-OriginalQvector^2*Rg^2/3)+(B/QstarVector^P) * exp(-RGCO^2 * OriginalQvector^2/3)
	
	if (Corelations)
		TempUnifiedIntensity/=(1+pack*IR1A_SphereAmplitude(OriginalQvector,ETA))
	//	TempUnifiedIntensity*=(1-pack*IR1A_SphereAmplitude(OriginalQvector,ETA)) 	//changed 6/24/2006 to agree with Standard formula from Ryong-Joon
	endif
end


//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR1A_SphereAmplitude(qval, eta)
		variable qval, eta
		
		return (3*(sin(qval*eta)-qval*eta*cos(qval*eta))/(qval*eta)^3)
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR1A_FitLocalPorod(Level)
	variable level
	DFref oldDf= GetDataFolderDFR()

	
	setDataFolder root:Packages:Irena_UnifFit
	
	Wave OriginalIntensity
	Wave OriginalQvector
	DoWindow IR1_LogLogPlotU
	if(V_Flag==0)
		abort
	endif

	Duplicate/O OriginalIntensity, $("FitLevel"+num2str(Level)+"Porod")

	Wave FitInt=$("FitLevel"+num2str(Level)+"Porod")
	string FitIntName="FitLevel"+num2str(Level)+"Porod"
	
	NVAR Pp=$("Level"+num2str(level)+"P")
	NVAR B=$("Level"+num2str(level)+"B")
	NVAR G=$("Level"+num2str(level)+"G")
	NVAR Rg=$("Level"+num2str(level)+"Rg")
	NVAR MassFractal=$("Level"+num2str(level)+"MassFractal")
	
	NVAR FitP=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"FitP")
	NVAR PLowLimit=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"PLowLimit")
	NVAR PHighLimit=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"PHighLimit")
	NVAR FitB=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"FitB")
	NVAR BLowLimit=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"BLowLimit")
	NVAR BHighLimit=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"BHighLimit")

	if(FitP)	//fitting P, let's give it some good starting value... 
		Pp = abs((log(OriginalIntensity[pcsr(A,"IR1_LogLogPlotU")])-log(OriginalIntensity[pcsr(B,"IR1_LogLogPlotU")]))/(log(OriginalQvector[pcsr(B,"IR1_LogLogPlotU")])-log(OriginalQvector[pcsr(A,"IR1_LogLogPlotU")])))
	else
		//ntohing to do, we will not be changing P
	endif
	variable LocalB
	if (MassFractal)
		LocalB=(G*Pp/Rg^Pp)*exp(gammln(Pp/2))
	else
		LocalB=OriginalIntensity[pcsr(A,"IR1_LogLogPlotU")]*(OriginalQvector[pcsr(A,"IR1_LogLogPlotU")])^Pp
	endif
	
	if (!FitB && !FitP)
		beep
		abort "No fitting parameter allowed to vary, select parameters to vary and set fitting limits"
	endif

	if(!FitB) 	//B should be fitted always.... 
		FitB = 1
		print "Changed settings to fit B, this parameters needs to be fitted always."
	endif

	IR1A_SetErrorsToZero()
	Make/D/O/N=2 CoefficientInput, New_FitCoefficients, LocalEwave
	Make/O/T/N=2 CoefNames
	CoefficientInput[0]=LocalB
	CoefficientInput[1]=Pp
	LocalEwave[0]=LocalB/20
	LocalEwave[1]=Pp/20
	CoefNames={"Level"+num2str(level)+"B","Level"+num2str(level)+"P"}
	
	Make/D/O/N=2 New_FitCoefficients
	New_FitCoefficients[0] = {LocalB,Pp}
	Make/O/T/N=2 T_Constraints
	T_Constraints = {"K1 > 1","K1 < 4.2"}

	Variable V_FitError=0			//This should prevent errors from being generated
	//FuncFit fails if constraints are applied to parameter, which is held....
	//therefore we need to make sure, that if user helds the Porod constant, he/she does not run FuncFit with Constraints..
	//modifed 12 20 2004 to use fit at once function to allow use on smeared data
	if(strlen(CsrWave(A,"IR1_LogLogPlotU"))<1 || strlen(CsrWave(B,"IR1_LogLogPlotU"))<1)
		beep
		SetDataFolder oldDf
		abort "Set both cursors before fitting"
	endif
	Wave OriginalError
	DoUpdate /W=IR1_LogLogPlotU
	if (FitP)
		FuncFit/Q/H=(num2str(abs(FitB-1))+num2str(abs(FitP-1)))/N IR1_PowerLawFitAllATOnce New_FitCoefficients OriginalIntensity[pcsr(A,"IR1_LogLogPlotU"),pcsr(B,"IR1_LogLogPlotU")] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave  /C=T_Constraints 
	else
		FuncFit/Q/H=(num2str(abs(FitB-1))+num2str(abs(FitP-1)))/N IR1_PowerLawFitAllATOnce New_FitCoefficients OriginalIntensity[pcsr(A,"IR1_LogLogPlotU"),pcsr(B,"IR1_LogLogPlotU")] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave 
	endif
	if (V_FitError!=0)	//there was error in fitting
		beep
		IR1A_UpdatePorodFit(level,0)
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	
	B=abs(New_FitCoefficients[0])
	Pp=abs(New_FitCoefficients[1])
	PlowLimit=1
	if (MassFractal)
		PHighLimit=3
	else
		PHighLimit=4
	endif
	BLowLimit=B/5
	BHighLimit=B*5
	
	IR1A_RecordErrorsAfterFit()
	IR1A_UpdatePorodFit(level,0)
	IR1A_UpdateUnifiedLevels(level, 0)
	SetDataFolder oldDf
end


//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR1A_FitLocalGuinier(Level)
	variable level
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit

	//first set to display local fits
	NVAR DisplayLocalFits=root:Packages:Irena_UnifFit:DisplayLocalFits
	DisplayLocalFits=1
	Checkbox DisplayLocalFits, value=DisplayLocalFits
	
	Wave OriginalIntensity
	Wave OriginalQvector

	Duplicate/O OriginalIntensity, $("FitLevel"+num2str(Level)+"Guinier")

	Wave FitInt=$("FitLevel"+num2str(Level)+"Guinier")
	string FitIntName="FitLevel"+num2str(Level)+"Guinier"
	
	NVAR Rg=$("Level"+num2str(level)+"Rg")
	NVAR G=$("Level"+num2str(level)+"G")
	
	NVAR FitRg=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"FitRg")
	NVAR RgLowLimit=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgLowLimit")
	NVAR RgHighLimit=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgHighLimit")
	NVAR FitG=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"FitG")
	NVAR GLowLimit=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"GLowLimit")
	NVAR GHighLimit=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"GHighLimit")

	if (!FitG && !FitRg)
		beep
		abort "No fitting parameter allowed to vary, select parameters to vary and set fitting limits"
	endif
//	if ((FitRg && (RgLowLimit > Rg || RgHighLimit < Rg)) || (FitG && (GLowLimit > G || GHighLimit < G)))
//			abort "Fitting limits set incorrectly, fix the limits before fitting"
//	endif
	DoWIndow/F IR1_LogLogPlotU
	if (strlen(CsrWave(A,"IR1_LogLogPlotU"))==0 || strlen(CsrWave(B,"IR1_LogLogPlotU"))==0)
		beep
		abort "Both Cursors Need to be set in Log-log graph on wave OriginalIntensity"
	endif
	IR1A_SetErrorsToZero()
//	Wave w=root:Packages:Irena_UnifFit:CoefficientInput
//	Wave/T CoefNames=root:Packages:Irena_UnifFit:CoefNames		//text wave with names of parameters
	variable LocalRg = 2*pi/((OriginalQvector[pcsr(A,"IR1_LogLogPlotU")]+OriginalQvector[pcsr(B,"IR1_LogLogPlotU")])/2)
	variable LocalG = (OriginalIntensity[pcsr(A,"IR1_LogLogPlotU")]+OriginalIntensity[pcsr(B,"IR1_LogLogPlotU")])/2
	if(!FitG)
		localG=G		//not fitting G, needs to be set to current GUI value
	endif
	if(!FitRg)
		localRg=Rg		//not fitting Rg, needs to be set to current GUI value. 
	endif

	Make/D/O/N=2 New_FitCoefficients, CoefficientInput, LocalEwave
	Make/O/T/N=2 CoefNames
	New_FitCoefficients[0] = LocalG
	New_FitCoefficients[1] = LocalRg
	LocalEwave[0]=(LocalG/20)
	LocalEwave[1]=(LocalRg/20)
	CoefficientInput[0]={LocalG,LocalRg}
	CoefNames={"Level"+num2str(level)+"G","Level"+num2str(level)+"Rg"}
//	Make/O/T/N=0 T_Constraints
//	T_Constraints=""
	variable tempLength
	if(strlen(CsrWave(A,"IR1_LogLogPlotU"))<1 || strlen(CsrWave(B,"IR1_LogLogPlotU"))<1)
		beep
		SetDataFolder oldDf
		abort "Set both cursors before fitting"
	endif
	Variable V_FitError=0			//This should prevent errors from being generated
	//modifed 12 20 2004 to use fit at once function to allow use on smeared data
	Wave OriginalError
	DoUpdate /W=IR1_LogLogPlotU
	FuncFit/Q/H=(num2str(abs(FitG-1))+num2str(abs(FitRg-1)))/N IR1_GuinierFitAllAtOnce New_FitCoefficients OriginalIntensity[pcsr(A,"IR1_LogLogPlotU"),pcsr(B,"IR1_LogLogPlotU")] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave 
	if (V_FitError!=0)	//there was error in fitting
		beep
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	
	G=abs(New_FitCoefficients[0])
	Rg=abs(New_FitCoefficients[1])
	RgLowLImit=Rg/5
	RgHighLimit=Rg*5
	GLowLimit=G/5
	GhighLimit=G*5
	
	IR1A_RecordErrorsAfterFit()
	IR1A_UpdateGuinierFit(level,0)
	IR1A_UpdateUnifiedLevels(level, 0)
		SetDataFolder oldDf
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR1A_DisplayLocalFits(level, overwrite)
	variable level, overwrite
	
	DoWindow IR1_LogLogPlotU
	if (V_Flag)
//		RemoveFromGraph /W=IR1_LogLogPlotU /Z FitLevel1Porod,FitLevel2Porod,FitLevel3Porod,FitLevel4Porod,FitLevel5Porod
//		RemoveFromGraph /W=IR1_LogLogPlotU /Z FitLevel1Guinier,FitLevel2Guinier,FitLevel3Guinier,FitLevel4Guinier,FitLevel5Guinier
//		RemoveFromGraph /W=IR1_LogLogPlotU /Z Level1Unified,Level2Unified,Level3Unified,Level4Unified,Level5Unified
		
		NVAR NmbLevels=root:Packages:Irena_UnifFit:NumberOfLevels
		
		if(level>0&&level<=NmbLevels)
			IR1A_UpdateGuinierFit(level, overwrite)
			IR1A_UpdateUnifiedLevels(level, overwrite)
			IR1A_UpdatePorodFit(level, overwrite)
		endif
	endif
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR1A_UpdateLocalFitsIfSelected()

		NVAR UpdateAutomatically=root:Packages:Irena_UnifFit:UpdateAutomatically
		NVAR ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
		
		DoWIndow IR1_LogLogPlotU
		if(V_Flag)
			RemoveFromGraph /W=IR1_LogLogPlotU /Z FitLevel1Porod,FitLevel2Porod,FitLevel3Porod,FitLevel4Porod,FitLevel5Porod
			RemoveFromGraph /W=IR1_LogLogPlotU /Z Level1Unified,Level2Unified,Level3Unified,Level4Unified,Level5Unified
			RemoveFromGraph /W=IR1_LogLogPlotU /Z FitLevel1Guinier,FitLevel2Guinier,FitLevel3Guinier,FitLevel4Guinier,FitLevel5Guinier
		endif

		DoWIndow IR1_IQ4_Q_PlotU
		if(V_Flag)
			RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z FitLevel1GuinierIQ4,FitLevel2GuinierIQ4,FitLevel3GuinierIQ4,FitLevel4GuinierIQ4,FitLevel5GuinierIQ4
			RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z Level1UnifiedIQ4,Level2UnifiedIQ4,Level3UnifiedIQ4,Level4UnifiedIQ4,Level5UnifiedIQ4
			RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z FitLevel1PorodIQ4,FitLevel2PorodIQ4,FitLevel3PorodIQ4,FitLevel4PorodIQ4,FitLevel5PorodIQ4
		endif
		if (UpdateAutomatically)
			IR1A_DisplayLocalFits(ActiveTab,0)
		endif

end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR1A_UpdateLocalFitsForOutput()

		NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
		NVAR UpdateAutomatically=root:Packages:Irena_UnifFit:UpdateAutomatically
		NVAR ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
		NVAR ExportLocalFits=root:Packages:Irena_UnifFit:ExportLocalFits
		
		variable i
		if(ExportLocalFits)
			For(i=1;i<=5;i+=1)
				IR1A_DisplayLocalFits(i,1)
			endfor
	
			RemoveFromGraph /W=IR1_LogLogPlotU /Z FitLevel1Porod,FitLevel2Porod,FitLevel3Porod,FitLevel4Porod,FitLevel5Porod
			RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z FitLevel1PorodIQ4,FitLevel2PorodIQ4,FitLevel3PorodIQ4,FitLevel4PorodIQ4,FitLevel5PorodIQ4
			RemoveFromGraph /W=IR1_LogLogPlotU /Z Level1Unified,Level2Unified,Level3Unified,Level4Unified,Level5Unified
			RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z Level1UnifiedIQ4,Level2UnifiedIQ4,Level3UnifiedIQ4,Level4UnifiedIQ4,Level5UnifiedIQ4
			RemoveFromGraph /W=IR1_LogLogPlotU /Z FitLevel1Guinier,FitLevel2Guinier,FitLevel3Guinier,FitLevel4Guinier,FitLevel5Guinier
			RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z FitLevel1GuinierIQ4,FitLevel2GuinierIQ4,FitLevel3GuinierIQ4,FitLevel4GuinierIQ4,FitLevel5GuinierIQ4
				
			if (UpdateAutomatically)
				IR1A_DisplayLocalFits(ActiveTab,0)
			endif
		endif
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1A_UpdatePorodFit(level, overwride)
	variable level, overwride
	
	setDataFolder root:Packages:Irena_UnifFit
	string WvList
	DoWIndow IR1_LogLogPlotU
	if(V_Flag)
		WvList=TraceNameList("IR1_LogLogPlotU", ",", 1 )
		WvList = GrepList(WvList, "FitLevel.Porod" , 0, ","  )
		Execute("RemoveFromGraph /W=IR1_LogLogPlotU /Z "+ WvList[0,strlen(WvList)-2])
	endif
	DoWIndow IR1_IQ4_Q_PlotU
	if(V_Flag)
	 	WvList=TraceNameList("IR1_IQ4_Q_PlotU", ",", 1 )
		WvList = GrepList(WvList, "FitLevel.PorodIQ4" , 0, ","  )
		Execute("RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z "+ WvList[0,strlen(WvList)-2])
	endif
	NVAR DisplayLocalFits
	
	if (DisplayLocalFits || overwride)	
		Wave OriginalIntensity
		Wave OriginalQvector
	
		Duplicate/O OriginalIntensity, $("FitLevel"+num2str(Level)+"Porod"), $("FitLevel"+num2str(Level)+"PorodIQ4")
	
		Wave FitInt=$("FitLevel"+num2str(Level)+"Porod")
		string FitIntName="FitLevel"+num2str(Level)+"Porod"
		Wave FitIntIQ4=$("FitLevel"+num2str(Level)+"PorodIQ4")
		string FitIntNameIQ4="FitLevel"+num2str(Level)+"PorodIQ4"
		
		NVAR P=$("Level"+num2str(level)+"P")
		NVAR B=$("Level"+num2str(level)+"B")
		NVAR G=$("Level"+num2str(level)+"G")
		NVAR Rg=$("Level"+num2str(level)+"Rg")
		NVAR MassFractal=$("Level"+num2str(level)+"MassFractal")
		
		variable LocalB
		if (MassFractal)
			LocalB=(G*P/Rg^P)*exp(gammln(P/2))
		else
			LocalB=B
		endif
		
		FitInt=LocalB*OriginalQvector^(-P)
		NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
		NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
		if(UseSMRData)
			duplicate/O  FitInt, UnifiedFitIntensitySM
			IR1B_SmearData(FitInt, OriginalQvector, SlitLengthUnif, UnifiedFitIntensitySM)
			FitInt=UnifiedFitIntensitySM
			KillWaves/Z UnifiedFitIntensitySM
		endif
		FitIntIQ4=FitInt*OriginalQvector^4
			
		DoWIndow IR1_LogLogPlotU
		if(V_Flag)
			GetAxis /W=IR1_LogLogPlotU /Q left
			AppendToGraph /W=IR1_LogLogPlotU FitInt vs OriginalQvector
			ModifyGraph /W=IR1_LogLogPlotU lsize($(FitIntName))=1,rgb($(FitIntName))=(0,65280,0)
			SetAxis /W=IR1_LogLogPlotU left V_min, V_max
		endif
		DoWIndow IR1_IQ4_Q_PlotU
		if(V_Flag)
			GetAxis /W=IR1_IQ4_Q_PlotU /Q left
			AppendToGraph /W=IR1_IQ4_Q_PlotU FitIntIQ4 vs OriginalQvector
			ModifyGraph /W=IR1_IQ4_Q_PlotU lsize($(FitIntNameIQ4))=1,rgb($(FitIntNameIQ4))=(0,65280,0)
			SetAxis /W=IR1_IQ4_Q_PlotU left V_min, V_max
		endif
	endif	
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1A_UpdateGuinierFit(level, overwride)
	variable level, overwride
	
	setDataFolder root:Packages:Irena_UnifFit
	string WvList
	DoWindow IR1_LogLogPlotU
	if(V_Flag)
		WvList=TraceNameList("IR1_LogLogPlotU", ",", 1 )
		WvList = GrepList(WvList, "FitLevel.Guinier" , 0, ","  )
		Execute("RemoveFromGraph /W=IR1_LogLogPlotU /Z "+ WvList[0,strlen(WvList)-2])
	endif
	
	DoWindow IR1_IQ4_Q_PlotU
	if(V_Flag)
		WvList=TraceNameList("IR1_IQ4_Q_PlotU", ",", 1 )
		WvList = GrepList(WvList, "FitLevel.GuinierIQ4" , 0, ","  )
		Execute("RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z "+ WvList[0,strlen(WvList)-2])
	endif
	NVAR DisplayLocalFits
	
	if (DisplayLocalFits || overwride)	
	
		Wave OriginalIntensity
		Wave OriginalQvector
	
		Duplicate/O OriginalIntensity, $("FitLevel"+num2str(Level)+"Guinier"),$("FitLevel"+num2str(Level)+"GuinierIQ4") 
	
		Wave FitInt=$("FitLevel"+num2str(Level)+"Guinier")
		string FitIntName="FitLevel"+num2str(Level)+"Guinier"
		Wave FitIntIQ4=$("FitLevel"+num2str(Level)+"GuinierIQ4")
		string FitIntNameIQ4="FitLevel"+num2str(Level)+"GuinierIQ4"
		
		NVAR G=$("Level"+num2str(level)+"G")
		NVAR Rg=$("Level"+num2str(level)+"Rg")
	
		
		FitInt=G*exp(-OriginalQvector^2*Rg^2/3)

		NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
		NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
		if(UseSMRData)
			duplicate/O  FitInt, UnifiedFitIntensitySM
			IR1B_SmearData(FitInt, OriginalQvector, SlitLengthUnif, UnifiedFitIntensitySM)
			FitInt=UnifiedFitIntensitySM
			KillWaves/Z UnifiedFitIntensitySM
		endif

		FitIntIQ4=FitInt*OriginalQvector^4
			
		//DoUpdate
		DoWIndow IR1_LogLogPlotU
		if(V_Flag)
			GetAxis /W=IR1_LogLogPlotU /Q left
			AppendToGraph /W=IR1_LogLogPlotU FitInt vs OriginalQvector
			ModifyGraph /W=IR1_LogLogPlotU lsize($(FitIntName))=1,rgb($(FitIntName))=(0,0,65280),lstyle($(FitIntName))=3
			SetAxis /W=IR1_LogLogPlotU left V_min, V_max
		endif
		
		DoWIndow IR1_IQ4_Q_PlotU
		if(V_Flag)
			GetAxis /W=IR1_IQ4_Q_PlotU /Q left
			AppendToGraph /W=IR1_IQ4_Q_PlotU FitIntIQ4 vs OriginalQvector
			ModifyGraph /W=IR1_IQ4_Q_PlotU lsize($(FitIntNameIQ4))=1,rgb($(FitIntNameIQ4))=(0,0,65280),lstyle($(FitIntNameIQ4))=3
			SetAxis /W=IR1_IQ4_Q_PlotU left V_min, V_max
		endif
	endif	
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1A_UpdateUnifiedLevels(level, overwride)
	variable level, overwride
	
	setDataFolder root:Packages:Irena_UnifFit
	string WvList
	DoWIndow IR1_LogLogPlotU
	if(V_Flag)
		WvList=TraceNameList("IR1_LogLogPlotU", ",", 1 )
		WvList = GrepList(WvList, "Level.Unified" , 0, ","  )
		Execute("RemoveFromGraph /W=IR1_LogLogPlotU /Z "+ WvList[0,strlen(WvList)-2])
	endif
	
	DoWIndow IR1_IQ4_Q_PlotU
	if(V_Flag)
	 	WvList=TraceNameList("IR1_IQ4_Q_PlotU", ",", 1 )
		WvList = GrepList(WvList, "Level.UnifiedIQ4" , 0, ","  )
		Execute("RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z "+ WvList[0,strlen(WvList)-2])
	endif
	NVAR DisplayLocalFits
	
	if (DisplayLocalFits || overwride)	
	
		Wave OriginalIntensity
		Wave OriginalQvector
	
		Duplicate/O OriginalIntensity, $("Level"+num2str(Level)+"Unified"),$("Level"+num2str(Level)+"UnifiedIQ4") 
	
		Wave FitInt=$("Level"+num2str(Level)+"Unified")
		string FitIntName="Level"+num2str(Level)+"Unified"
		Wave FitIntIQ4=$("Level"+num2str(Level)+"UnifiedIQ4")
		string FitIntNameIQ4="Level"+num2str(Level)+"UnifiedIQ4"
		//IR1A_UnifiedCalcIntOne(level, OriginalIntensity, OriginalQvector)
		IR1A_UnifiedCalcIntOne(level, OriginalQvector)
		Wave TempUnifiedIntensity=root:Packages:Irena_UnifFit:TempUnifiedIntensity
		NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
		NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
		if(UseSMRData)
			duplicate/free  TempUnifiedIntensity, UnifiedFitIntensitySM
			IR1B_SmearData(TempUnifiedIntensity, OriginalQvector, SlitLengthUnif, UnifiedFitIntensitySM)
			TempUnifiedIntensity=UnifiedFitIntensitySM
			//KillWaves/Z UnifiedFitIntensitySM
		endif
		FitInt=TempUnifiedIntensity
		FitIntIQ4=FitInt*OriginalQvector^4
		
		DoWIndow IR1_LogLogPlotU
		if(V_Flag)
			GetAxis /W=IR1_LogLogPlotU /Q left        
			AppendToGraph /W=IR1_LogLogPlotU FitInt vs OriginalQvector  
			ModifyGraph /W=IR1_LogLogPlotU lsize($(FitIntName))=1,rgb($(FitIntName))=(52224,0,41728),lstyle($(FitIntName))=13
			ModifyGraph /W=IR1_LogLogPlotU mode($(FitIntName))=4,marker($(FitIntName))=23,msize($(FitIntName))=1
			SetAxis /W=IR1_LogLogPlotU left V_min, V_max
			//DoUpdate /W=IR1_LogLogPlotU
		endif
		
		DoWIndow IR1_IQ4_Q_PlotU
		if(V_Flag)
			GetAxis /W=IR1_IQ4_Q_PlotU /Q left
			AppendToGraph /W=IR1_IQ4_Q_PlotU FitIntIQ4 vs OriginalQvector
			ModifyGraph /W=IR1_IQ4_Q_PlotU lsize($(FitIntNameIQ4))=1,rgb($(FitIntNameIQ4))=(52224,0,41728),lstyle($(FitIntNameIQ4))=13
			ModifyGraph /W=IR1_IQ4_Q_PlotU mode($(FitIntNameIQ4))=4,marker($(FitIntNameIQ4))=23,msize($(FitIntNameIQ4))=1
			SetAxis /W=IR1_IQ4_Q_PlotU left V_min, V_max
			//DoUpdate /W=IR1_IQ4_Q_PlotU
		endif
	endif	
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR1_GuinierFit(w,q) : FitFunc
	Wave w
	Variable q

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ Prefactor=abs(Prefactor)
	//CurveFitDialog/ Rg=abs(Rg)
	//CurveFitDialog/ f(q) = Prefactor*exp(-q^2*Rg^2/3))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Prefactor
	//CurveFitDialog/ w[1] = Rg

	w[0]=abs(w[0])
	w[1]=abs(w[1])
	return w[0]*exp(-q^2*w[1]^2/3)
End
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR1_GuinierFitAllAtOnce(parwave,ywave,xwave) : FitFunc
	Wave parwave,xwave,ywave

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ Prefactor=abs(Prefactor)
	//CurveFitDialog/ Rg=abs(Rg)
	//CurveFitDialog/ f(q) = Prefactor*exp(-q^2*Rg^2/3))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Prefactor
	//CurveFitDialog/ w[1] = Rg

	variable Prefactor=abs(parwave[0])
	variable Rg=abs(parwave[1])

	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
	Wave OriginalQvector =root:Packages:Irena_UnifFit:OriginalQvector
	Duplicate/O OriginalQvector, tempGunInt
	//w[0]*exp(-q^2*w[1]^2/3)
	tempGunInt = Prefactor * exp(-OriginalQvector^2 * Rg^2/3)
	if(UseSMRData)
		duplicate/O  tempGunInt, tempGunIntSM
		IR1B_SmearData(tempGunInt, OriginalQvector, SlitLengthUnif, tempGunIntSM)
		tempGunInt=tempGunIntSM
	endif
	
	ywave = tempGunInt[binarysearch(OriginalQvector,xwave[0])+p]
	KillWaves/Z tempGunIntSM, tempGunInt
	
	return 1
End

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1_PowerLawFitAllATOnce(parwave,ywave,xwave) : FitFunc
	Wave parwave,xwave,ywave

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ Prefactor=abs(Prefactor)
	//CurveFitDialog/ Slope=abs(slope)
	//CurveFitDialog/ f(q) = Prefactor*q^(-Slope)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Prefactor
	//CurveFitDialog/ w[1] = Slope

	variable Prefactor=abs(parwave[0])
	variable slope=abs(parwave[1])
	

	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
	Wave OriginalQvector =root:Packages:Irena_UnifFit:OriginalQvector
	Duplicate/O OriginalQvector, tempPowerLawInt
	// w[0]*q^(-w[1])
	tempPowerLawInt = Prefactor * OriginalQvector^(-slope)
	if(UseSMRData)
		duplicate/O  tempPowerLawInt, tempPowerLawIntSM
		IR1B_SmearData(tempPowerLawInt, OriginalQvector, SlitLengthUnif, tempPowerLawIntSM)
		tempPowerLawInt=tempPowerLawIntSM
	endif
	
	ywave = tempPowerLawInt[binarysearch(OriginalQvector,xwave[0])+p]
	KillWaves/Z tempGunIntSM, tempGunInt
End

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1_PowerLawFit(w,q) : FitFunc
	Wave w
	Variable q

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ Prefactor=abs(Prefactor)
	//CurveFitDialog/ Slope=abs(slope)
	//CurveFitDialog/ f(q) = Prefactor*q^(-Slope)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Prefactor
	//CurveFitDialog/ w[1] = Slope

	w[0]=abs(w[0])
	w[1]=abs(w[1])
	return w[0]*q^(-w[1])
End

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1A_UpdateMassFractCalc()
	//here I update mass fractal calculations

	variable i
	
	For (i=2;i<=5;i+=1)
		NVAR IsMassFract=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"MassFractal")
		NVAR PrevRg=$("root:Packages:Irena_UnifFit:Level"+num2str(i-1)+"Rg")
		NVAR CurrentRg=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Rg")
		NVAR DegreeOfAggreg=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"DegreeOfAggreg")
		if (IsMassFract)
			DegreeOfAggreg=CurrentRg/PrevRg
		else
			DegreeOfAggreg=0
		endif
	endfor

end


//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1A_UpdatePorodSfcandInvariant()
	//here I update Porod surface calculations

	variable i
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	
	For (i=1;i<=NumberOfLevels;i+=1)
		NVAR Porod=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"P")
		NVAR B=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"B")
		NVAR Rg=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Rg")
		NVAR SurfaceToVolRat=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"SurfaceToVolRat")
		NVAR Invariant=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Invariant")
		NVAR RgCO=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"RgCO")

		Wave OriginalQvector=root:Packages:Irena_UnifFit:OriginalQvector
		variable maxQ=2*pi/(Rg/10)
		variable Newnumpnts=2000
		Make/free/N=(Newnumpnts) SurfToVolQvec, SurfToVolInt, SurfToVolInvariant
		SurfToVolQvec=(maxQ/Newnumpnts)*p
		IR1A_SurfToVolCalcInvarVec(i, SurfToVolQvec, SurfToVolInt)
		SurfToVolInt[0]=SurfToVolInt[1]
		SurfToVolInvariant=SurfToVolInt*SurfToVolQvec^2		// Int * Q^2 wave
		
		Invariant=areaXY(SurfToVolQvec, SurfToVolInvariant, 0, maxQ )		//invariant, need to add "Porod tail"
		//but not when we use RgCo, as that really has no Porod tail...
		if(RgCO<0.1)
			//Invariant+=abs(B*maxQ^(3-abs(Porod))/2)		//Ok, this should be Porod tail < 12/2/2013 DWS not correct ...
			Invariant+=-B*maxQ^(3-abs(Porod))/(3-abs(Porod))			// 12/2/2013 modified by dws					
		endif
		//Invariant is at this time in cm^-1 * A^-3  (Gregg Beaucage)
		//Invariant calculations fails if P<3 since the integration to infinity is negative. 
		//set Invariant to NaN in that case...
		if(Invariant<0)		//bad extrapolation
			Invariant = NaN
		endif
		
		if (Porod>=3.95 && Porod<=4.05)
			SurfaceToVolRat=1e4*pi*B/Invariant//***DWS  This is not the suface to volume ratio.  S/V = piB/Q * (phi*(1-phi))
		else
			SurfaceToVolRat=NaN
		endif
		Invariant = Invariant * 10^24		//and now it is in cm-4
//		print Invariant
	endfor
	
	//KillWaves/Z SurfToVolQvec, SurfToVolInt, SurfToVolInvariant
end
//***********************************************************
//***********************************************************
//***********************************************************

Function IR1A_SurfToVolCalcInvarVec(level, Qvector, IntensityVector)
	variable level
	Wave Qvector, IntensityVector
	
	setDataFolder root:Packages:Irena_UnifFit

	Duplicate /O Qvector, QstarVector
	
	NVAR Rg=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Rg")
	NVAR G=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"G")
	NVAR P=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"P")
	NVAR B=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"B")
	NVAR ETA=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"ETA")
	NVAR PACK=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"PACK")
	NVAR RgCO=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgCO")
	NVAR K=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"K")
	NVAR Corelations=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Corelations")
	NVAR MassFractal=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"MassFractal")
	NVAR LinkRGCO=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"LinkRGCO")
	if (LinkRGCO==1 && level>=2)
		NVAR RgLowerLevel=$("root:Packages:Irena_UnifFit:Level"+num2str(level-1)+"Rg")	
		RGCO=RgLowerLevel
	endif
	QstarVector=Qvector/(erf(K*Qvector*Rg/sqrt(6)))^3
	if (MassFractal)
		B=(G*P/Rg^P)*exp(gammln(P/2))
	endif
	
	IntensityVector=G*exp(-Qvector^2*Rg^2/3)+(B/QstarVector^P) * exp(-RGCO^2 * Qvector^2/3)
	
	if (Corelations)
		IntensityVector/=(1+pack*IR1A_SphereAmplitude(Qvector,ETA))
	endif
	
	KillWaves/Z QstarVector
End

//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_EvaluateUnifiedData()

	DoWindow UnifiedEvaluationPanel
	
	if(V_Flag)
		DoWIndow/F UnifiedEvaluationPanel
	else
		IR2U_InitUnifAnalysis()
		IR2U_UnifiedEvaPanelFnct() 
		IR1_UpdatePanelVersionNumber("UnifiedEvaluationPanel", IR2UversionNumber,1)
	endif
	KillWIndow/Z IR2U_UnifLogNormalSizeDist 
end

//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_MainCheckVersion()	
	DoWindow UnifiedEvaluationPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("UnifiedEvaluationPanel", IR2UversionNumber))
			DoAlert /T="The Unified fit data evaluation panel was created by incorrect version of Irena " 1, "The code needs to be restarted to work properly. Restart now?"
			if(V_flag==1)
				KillWIndow/Z UnifiedEvaluationPanel
				IR2U_EvaluateUnifiedData()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR2U_InitUnifAnalysis()					//this may be OK now... 
			endif
		endif
	endif
end


//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_UnifiedEvaPanelFnct() : Panel
	//PauseUpdate    		// building window...
	NewPanel /K=1/W=(311,63,700,600) as "Unified fit data evaluation"
	DoWindow/C UnifiedEvaluationPanel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 3,textrgb= (1,4,52428)
	DrawText 26,30,"Unified Fit Data Analysis"
//	SetDrawEnv fsize= 18,fstyle= 3,textrgb= (1,4,52428)
//	DrawText 117,54,"using Unified Fit results"

	Checkbox  CurrentResults, pos={10,63}, size={50,15}, variable =root:packages:Irena_AnalUnifFit:CurrentResults
	Checkbox  CurrentResults, title="Current Unified Fit",mode=1,proc=IR2U_CheckProc
	Checkbox  CurrentResults, help={"Select of you want to analyze current results in Unified Fit tool"}
	Checkbox StoredResults, pos={150,63}, size={50,15}, variable =root:packages:Irena_AnalUnifFit:StoredResults
	Checkbox  StoredResults, title="Stored Unified Fit results",mode=1, proc=IR2U_CheckProc
	Checkbox  StoredResults, help={"Select of you want to analyze Stored Unified fit data"}
	checkbox UseCsrInv pos={255,475},size={30,20},title="Calc inv btwn csrs",proc=IR2U_DWSCheckboxProc//***DWS
	checkbox UseCsrInv variable=root:Packages:Irena_AnalUnifFit:UseCsrInv,value=1//***DWS
	checkbox UnifiedForInv pos={255,490},size={30,20},title="Use unified inv",proc=IR2U_DWSCheckboxProc//***DWS
	checkbox UnifiedForInv variable=root:Packages:Irena_AnalUnifFit:UseUnifiedInv,value=0
	CheckBox PrintExcel title="Excel Compatible",size={100,14}, pos={180,505};DelayUpdate//***DWS
	CheckBox PrintExcel proc=IR2U_DWSCheckboxProc,variable=root:Packages:Irena_AnalUnifFit:printexcel,value=1//***DWS
	CheckBox includelogbook title="Print to logbook",size={100,14}, pos={180,520};DelayUpdate//***DWS
	CheckBox includelogbook proc=IR2U_DWSCheckboxProc,variable =root:Packages:Irena_AnalUnifFit:printlogbook,value=0//***DWS
	
	checkbox UseCsrInv disable=1//***DWS
	
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena_AnalUnifFit","UnifiedEvaluationPanel","","UnifiedFitIntensity",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 1,1)
	NVAR UseResults = root:Packages:Irena_AnalUnifFit:UseResults
	UseResults=1
	STRUCT WMCheckboxAction CB_Struct
	CB_Struct.ctrlName="UseResults"
	CB_Struct.checked=1
	CB_Struct.win="UnifiedEvaluationPanel"
	CB_Struct.eventcode=2
	
	IR2C_InputPanelCheckboxProc(CB_Struct)
	Checkbox  UseResults, disable=1
	KillControl UseModelData
	KillCOntrol UseQRSData
	PopupMenu ErrorDataName, disable=1
	PopupMenu QvecDataName, disable=1
	PopupMenu SelectDataFolder,pos={25,87}
	PopupMenu SelectDataFolder proc=IR2U_PopMenuProc
	PopupMenu IntensityDataName,pos={25,114}
	PopupMenu IntensityDataName proc=IR2U_PopMenuProc	
	Setvariable FolderMatchStr, pos={270,87}
	KillControl Qmin
	KillControl Qmax
	KillControl QNumPoints

	PopupMenu Model,pos={10,140},size={109,20},proc=IR2U_PopMenuProc,title="Model:"
	PopupMenu Model,help={"Select model to use for data analysis"}
	PopupMenu Model,mode=1,popvalue="---",value= #"root:Packages:Irena_AnalUnifFit:KnownModels"
	PopupMenu AvailableLevels,pos={210,140},size={109,20},proc=IR2U_PopMenuProc,title="Level:"
	PopupMenu AvailableLevels,help={"Select level to use for data analysis"}
	PopupMenu AvailableLevels,mode=1,popvalue="---", value=#"root:Packages:Irena_AnalUnifFit:AvailableLevels"

	PopupMenu SelectedBlevel,pos={313,140},size={90,20},proc=IR2U_PopMenuProc,title="Low :"
	PopupMenu SelectedBlevel,help={"Select end level to use for data analysis"}
	PopupMenu SelectedBlevel,mode=1,popvalue="---", value=#"root:Packages:Irena_AnalUnifFit:SelectedBlevel"

	PopupMenu SelectedQlevel,pos={315,115},size={90,20},proc=IR2U_PopMenuProc,title="High:"
	PopupMenu SelectedQlevel,help={"Select stat level to use for data analysis"}
	PopupMenu SelectedQlevel,mode=1,popvalue="---", value=#"root:Packages:Irena_AnalUnifFit:SelectedQlevel"


	PopupMenu MinorityPhaseVals,pos={320,213},size={80,15},proc=IR2U_PopMenuProc,title=""
	PopupMenu MinorityPhaseVals,help={"Select predefined materials values for data analysis"}
	PopupMenu MinorityPhaseVals,mode=1,popvalue="User", value=#"root:Packages:Irena_AnalUnifFit:TwoPhaseSysAvailableNames"
	PopupMenu MajorityPhaseVals,pos={320,236},size={80,15},proc=IR2U_PopMenuProc,title=""
	PopupMenu MajorityPhaseVals,help={"Select predefined materials values for data analysis"}
	PopupMenu MajorityPhaseVals,mode=1,popvalue="User", value=#"root:Packages:Irena_AnalUnifFit:TwoPhaseSysAvailableNames"

	//Invariant controls:
	SetVariable InvariantValue, pos={20,350}, size={250,20}, title="Invariant value [cm^-4]       ", help={"Invariant calcualted by the Unified fit."}
	SetVariable InvariantValue, variable=root:Packages:Irena_AnalUnifFit:InvariantValue, noedit=1,limits={-inf,inf,0}

	SetVariable InvariantUserContrast, pos={20,250}, size={250,20}, title="Contrast [10^20 cm^-4]       "
	SetVariable InvariantUserContrast, variable=root:Packages:Irena_AnalUnifFit:InvariantUserContrast, format="%.4g"
	SetVariable InvariantUserContrast,proc=IR2U_SetVarProc, help={"Contrast - user input. "}

	SetVariable InvariantPhaseVolume, pos={20,375}, size={250,20}, title="Volume of the phase [fract] "
	SetVariable InvariantPhaseVolume, variable=root:Packages:Irena_AnalUnifFit:InvariantPhaseVolume, format="%.4g"
	SetVariable InvariantPhaseVolume, disable=0,noedit=1,limits={-inf,inf,0}, help={"Fractional volume of the phase calculated from invariant and contrast"}
	//MassFactal stuff
	SetVariable BrFract_G2, pos={10,170}, size={120,20}, title="G2 = ", help={"Radius of gyration prefactor"}
	SetVariable BrFract_G2, variable=root:Packages:Irena_AnalUnifFit:BrFract_G2, noedit=1,limits={-inf,inf,0}, format="%.4g"
	SetVariable BrFract_Rg2, pos={170,170}, size={120,20}, title="Rg2 [A] = ", help={"Radius of gyration"}
	SetVariable BrFract_Rg2, variable=root:Packages:Irena_AnalUnifFit:BrFract_Rg2, noedit=1,limits={-inf,inf,0}, format="%.4g"
	SetVariable BrFract_B2, pos={10,195}, size={120,20}, title="B2 = ", help={"Power law slope prefactor"}
	SetVariable BrFract_B2, variable=root:Packages:Irena_AnalUnifFit:BrFract_B2, noedit=1,limits={-inf,inf,0}, format="%.4g"
	SetVariable BrFract_P2, pos={170,195}, size={120,20}, title="P2   = ", help={"Power law slope value"}
	SetVariable BrFract_P2, variable=root:Packages:Irena_AnalUnifFit:BrFract_P2, noedit=1,limits={-inf,inf,0}, format="%.4g"
	
	SetVariable BrFract_ErrorMessage, title=" ",value=root:Packages:Irena_AnalUnifFit:BrFract_ErrorMessage, noedit=1
	SetVariable BrFract_ErrorMessage, pos={5,215}, size={365,20}, frame=0, help={"Error message, if any"}	

	SetVariable BrFract_dmin, pos={10,240}, size={150,20}, title="Min. dim. dmin =   ", help={"Minimum dimension of the aggregate"}, format="%.4g"
	SetVariable BrFract_dmin, variable=root:Packages:Irena_AnalUnifFit:BrFract_dmin, noedit=1,limits={-inf,inf,0}
	SetVariable BrFract_c, pos={170,240}, size={150,20}, title="Connectivity dim. c = ", help={"Connectivity dimension of the aggregate"}, format="%.4g"
	SetVariable BrFract_c, variable=root:Packages:Irena_AnalUnifFit:BrFract_c, noedit=1,limits={-inf,inf,0}
	SetVariable BrFract_z, pos={10,260}, size={150,20}, title="Degree of agg. z =", help={"Degree of aggregation, 1+G2/G1"}, format="%.4g"
	SetVariable BrFract_z, variable=root:Packages:Irena_AnalUnifFit:BrFract_z, noedit=1,limits={-inf,inf,0}
	SetVariable BrFract_fBr, pos={170,260}, size={150,20}, title="Brach fract. Fi (Br) = ", help={"Brach Fraction Phys Rev E, formula 9 "}, format="%.4g"
	SetVariable BrFract_fBr, variable=root:Packages:Irena_AnalUnifFit:BrFract_fBr, noedit=1,limits={-inf,inf,0}
	SetVariable BrFract_fM, pos={10,280}, size={150,20}, title="Fi (M) =              ", help={"Parameter as defined in the references"}, format="%.4g"
	SetVariable BrFract_fM, variable=root:Packages:Irena_AnalUnifFit:BrFract_fM, noedit=1,limits={-inf,inf,0}

	SetVariable BrFract_Reference1, title="Ref: ",value=root:Packages:Irena_AnalUnifFit:BrFract_Reference1, noedit=1
	SetVariable BrFract_Reference1, pos={5,305}, size={365,20}, frame=0, help={"reference, please read"}	
	SetVariable BrFract_Reference2, title="Ref: ",value=root:Packages:Irena_AnalUnifFit:BrFract_Reference2, noedit=1
	SetVariable BrFract_Reference2, pos={5,325}, size={365,20}, frame=0, help={"Referecne, please read"}	

	//Size dist controls
	SetVariable SizeDist_G1, pos={10,170}, size={120,20}, title="G = ", help={"Rg prefactor"}
	SetVariable SizeDist_G1, variable=root:Packages:Irena_AnalUnifFit:SizeDist_G1, noedit=1,limits={-inf,inf,0}, format="%.4g"
	SetVariable SizeDist_Rg1, pos={170,170}, size={120,20}, title="Rg [A] = ", help={"Radius of gyration"}
	SetVariable SizeDist_Rg1, variable=root:Packages:Irena_AnalUnifFit:SizeDist_Rg1, noedit=1,limits={-inf,inf,0}, format="%.4g"
	SetVariable SizeDist_B1, pos={10,195}, size={120,20}, title="B = ", help={"Power law prefactor, also known as Porod constant when P=-4"}
	SetVariable SizeDist_B1, variable=root:Packages:Irena_AnalUnifFit:SizeDist_B1, noedit=1,limits={-inf,inf,0}, format="%.4g"
	SetVariable SizeDist_P1, pos={170,195}, size={120,20}, title="P   = ", help={"Power law slope value, should be 4 for this to work"}
	SetVariable SizeDist_P1, variable=root:Packages:Irena_AnalUnifFit:SizeDist_P1, noedit=1,limits={-inf,inf,0}, format="%.4g"

	SetVariable SizeDist_ErrorMessage, title=" ",value=root:Packages:Irena_AnalUnifFit:SizeDist_ErrorMessage, noedit=1
	SetVariable SizeDist_ErrorMessage, pos={5,215}, size={365,20}, frame=0, help={"Error message, if any"}	

	SetVariable SizeDist_sigmag, pos={10,240}, size={140,20}, title="Geom Sigma =", help={"Width of distributioon as defined int he reference"}
	SetVariable SizeDist_sigmag, variable=root:Packages:Irena_AnalUnifFit:SizeDist_sigmag, noedit=1,limits={-inf,inf,0}, format="%.4g"
	SetVariable SizeDist_GeomMean, pos={190,240}, size={140,20}, title="Geom mean =", help={"Mean radius as defined in the referecne"}
	SetVariable SizeDist_GeomMean, variable=root:Packages:Irena_AnalUnifFit:SizeDist_GeomMean, noedit=1,limits={-inf,inf,0}, format="%.4g"
	SetVariable SizeDist_PDI, pos={10,260}, size={140,20}, title="Polydisp indx =", help={"Polydispersity index as defined in the reference"}
	SetVariable SizeDist_PDI, variable=root:Packages:Irena_AnalUnifFit:SizeDist_PDI, noedit=1,limits={-inf,inf,0}, format="%.4g"
	SetVariable SizeDist_SuterMeanDiadp, pos={190,260}, size={140,20}, title="Sauter Mean Dia =", help={"Mean radius as defined in the reference"}
	SetVariable SizeDist_SuterMeanDiadp, variable=root:Packages:Irena_AnalUnifFit:SizeDist_SuterMeanDiadp, noedit=1,limits={-inf,inf,0}, format="%.4g"

	SetVariable SizeDist_Reference, title="Ref: ",value=root:Packages:Irena_AnalUnifFit:SizeDist_Reference, noedit=1
	SetVariable SizeDist_Reference, pos={5,305}, size={365,20}, frame=0, help={"Referecne for the model"}	
	
	//Porods law
//	Porod_Contrast;Porod_SpecificSfcArea, Porod_Constant
	SetVariable Porod_Constant, pos={20,170}, size={250,20}, title="Porod constant [cm^-1 A^-4]       ", help={"Porod constant calculated by the Unified fit."}
	SetVariable Porod_Constant, variable=root:Packages:Irena_AnalUnifFit:Porod_Constant, noedit=1,limits={-inf,inf,0}, format="%.4g"
	SetVariable Porod_PowerLawSlope, pos={20,195}, size={250,20}, title="Power law (Porods) slope    ", help={"Power law slope (should be -4)"}
	SetVariable Porod_PowerLawSlope, variable=root:Packages:Irena_AnalUnifFit:Porod_PowerLawSlope, noedit=1,limits={-inf,inf,0}, format="%.4g"

	SetVariable Porod_Contrast, pos={20,250}, size={250,20}, title="Contrast [10^20 cm^-4]          "
	SetVariable Porod_Contrast, variable=root:Packages:Irena_AnalUnifFit:Porod_Contrast, format="%.4g"
	SetVariable Porod_Contrast,proc=IR2U_SetVarProc, help={"Contrast - user input. "}


	SetVariable Porod_ErrorMessage, title=" ",value=root:Packages:Irena_AnalUnifFit:Porod_ErrorMessage, noedit=1
	SetVariable Porod_ErrorMessage, pos={5,300}, size={365,20}, frame=0, help={"Error message, if any"}	

	SetVariable Porod_SpecificSfcArea, pos={20,350}, size={250,20}, title="Specific surface area [cm^2/cm^3] "
	SetVariable Porod_SpecificSfcArea, variable=root:Packages:Irena_AnalUnifFit:Porod_SpecificSfcArea, format="%.4g"
	SetVariable Porod_SpecificSfcArea, disable=0,noedit=1,limits={-inf,inf,0}, help={"Specific surface area calculated from Porod constant and contrast"}


// Two phase systems... 
// Model 1 knows the sample buld density and both other densities, need input for these values here... 
//	NVAR SampleBulkDensity=root:Packages:Irena_AnalUnifFit:SampleBulkDensity //need user input here... 
	SetVariable SampleBulkDensity, pos={20,170}, size={300,20}, title="Sample bulk density [g/cm3]       ", help={"Sample bulk density in g/cm3"}, format="%.4g"
	SetVariable SampleBulkDensity, variable=root:Packages:Irena_AnalUnifFit:SampleBulkDensity,limits={0,inf,0}, proc=IR2U_SetVarProc, bodyWidth=120
	SetVariable DensitiesLegend, title=" ",value=root:Packages:Irena_AnalUnifFit:DensitiesLegend, noedit=1
	SetVariable DensitiesLegend, pos={85,195}, size={365,20}, frame=0, help={""}	
	SetVariable DensityMinorityPhase, pos={10,215}, size={160,20}, title="Minority phase :", help={"Skeleton phase (solid) density, should be minority phase"}
	SetVariable DensityMinorityPhase, variable=root:Packages:Irena_AnalUnifFit:DensityMinorityPhase,limits={0,inf,0}, proc=IR2U_SetVarProc, bodyWidth=80, format="%.4g"
	SetVariable SLDDensityMinorityPhase, pos={200,215}, size={100,20}, title="  ", help={"Skeleton phase (solid) SLD density, should be minority phase"}
	SetVariable SLDDensityMinorityPhase, variable=root:Packages:Irena_AnalUnifFit:SLDDensityMinorityPhase,limits={0,inf,0}, proc=IR2U_SetVarProc, bodyWidth=90, format="%.4g"

	SetVariable DensityMajorityPhase, pos={10,235}, size={160,20}, title="Majority phase  : "
	SetVariable DensityMajorityPhase, variable=root:Packages:Irena_AnalUnifFit:DensityMajorityPhase, bodyWidth=80, format="%.4g"
	SetVariable DensityMajorityPhase,proc=IR2U_SetVarProc, help={"Void phase (majority assumed) "}, limits={0,inf,0}//, fColor=(13107,13107,13107), valueColor=(13107,13107,13107)
	SetVariable SLDDensityMajorityPhase, pos={200,235}, size={100,20}, title="  "
	SetVariable SLDDensityMajorityPhase, variable=root:Packages:Irena_AnalUnifFit:SLDDensityMajorityPhase, bodyWidth=90, format="%.4g"
	SetVariable SLDDensityMajorityPhase,proc=IR2U_SetVarProc, help={"Void phase (majority assumed) "}, limits={0,inf,0}//, fColor=(13107,13107,13107), valueColor=(13107,13107,13107)

	SetVariable TwoPhaseSys_MinName, title="Min Phase Nm:",value=root:Packages:Irena_AnalUnifFit:TwoPhaseSys_MinName, bodywidth=100
	SetVariable TwoPhaseSys_MinName, pos={10,255}, size={180,20}, frame=1, help={"Name for output tags"}	
	SetVariable TwoPhaseSys_MajName, title="Maj Phase Nm:",value=root:Packages:Irena_AnalUnifFit:TwoPhaseSys_MajName, bodywidth=100
	SetVariable TwoPhaseSys_MajName, pos={200,255}, size={180,20}, frame=1, help={"Name for the output tags"}	

	SetVariable TwoPhaseSystem_reference, title=" ",value=root:Packages:Irena_AnalUnifFit:TwoPhaseSystem_reference, noedit=1
	SetVariable TwoPhaseSystem_reference, pos={5,310}, size={365,20}, frame=0, help={"Reference"}	
	SetVariable TwoPhaseSystem_comment1, title=" ",value=root:Packages:Irena_AnalUnifFit:TwoPhaseSystem_comment1, noedit=1
	SetVariable TwoPhaseSystem_comment1, pos={5,330}, size={365,20}, frame=0, help={"Comments"}	

	SetVariable PiBoverQ, pos={20,370}, size={300,20}, title="pi*B/Invariant [m^2/cm^2]    =     ", format="%.4g"
	SetVariable PiBoverQ, variable=root:Packages:Irena_AnalUnifFit:PiBoverQ, noedit=1, bodyWidth=80, disable=2, noedit=1
	SetVariable PiBoverQ,proc=IR2U_SetVarProc, help={"Calculated pi * B / invariant from Unif fit"}, limits={0,inf,0}//, fColor=(13107,13107,13107), valueColor=(13107,13107,13107)


	SetVariable SurfacePerVolume, pos={20,390}, size={300,20}, title="Surface per Volume  [m^2/cm^3]    =     ", format="%.4g"
	SetVariable SurfacePerVolume, variable=root:Packages:Irena_AnalUnifFit:SurfacePerVolume, noedit=1, bodyWidth=80, disable=2, noedit=1
	SetVariable SurfacePerVolume,proc=IR2U_SetVarProc, help={"Surface areea per volume in m2 per cm3"}, limits={0,inf,0}//, fColor=(13107,13107,13107), valueColor=(13107,13107,13107)

	SetVariable SurfacePerMass, pos={20,410}, size={300,20}, title="Surface per mass  [m^2/g]    =     ", format="%g"
	SetVariable SurfacePerMass, variable=root:Packages:Irena_AnalUnifFit:SurfacePerMass, noedit=1, bodyWidth=80, disable=2, noedit=1
	SetVariable SurfacePerMass,proc=IR2U_SetVarProc, help={"Surface areea per 1g of sample"}, limits={0,inf,0}//, fColor=(13107,13107,13107), valueColor=(13107,13107,13107)


	SetVariable MinorityPhasePhi, pos={15,430}, size={180,20}, title="Volume Fraction  :    Minority = ", format="%.4g"
	SetVariable MinorityPhasePhi, variable=root:Packages:Irena_AnalUnifFit:MinorityPhasePhi, noedit=1, bodyWidth=80, disable=2, noedit=1
	SetVariable MinorityPhasePhi,proc=IR2U_SetVarProc, help={"Fractional volume of the minority phase "}, limits={0,inf,0}//, fColor=(13107,13107,13107), valueColor=(13107,13107,13107)

	SetVariable MajorityPhasePhi, pos={260,430}, size={110,20}, title="Majority = ", format="%.4g"
	SetVariable MajorityPhasePhi, variable=root:Packages:Irena_AnalUnifFit:MajorityPhasePhi, noedit=1, bodyWidth=80, disable=2, noedit=1
	SetVariable MajorityPhasePhi,proc=IR2U_SetVarProc, help={"fractional volume of the majority phase "}, limits={0,inf,0}//, fColor=(13107,13107,13107), valueColor=(13107,13107,13107)


	SetVariable MinorityCordLength, pos={15,450}, size={180,20}, title="Cord Length  [A] : Minority = ", format="%.4g"
	SetVariable MinorityCordLength, variable=root:Packages:Irena_AnalUnifFit:MinorityCordLength, noedit=1, bodyWidth=80, disable=2, noedit=1
	SetVariable MinorityCordLength,proc=IR2U_SetVarProc, help={"Minority phase cord length in A"}, limits={0,inf,0}//, fColor=(13107,13107,13107), valueColor=(13107,13107,13107)

	SetVariable MajorityCordLength, pos={260,450}, size={110,20}, title="Majority = ", format="%.4g"
	SetVariable MajorityCordLength, variable=root:Packages:Irena_AnalUnifFit:MajorityCordLength, noedit=1, bodyWidth=80, disable=2, noedit=1
	SetVariable MajorityCordLength,proc=IR2U_SetVarProc, help={"Majority phase cord length in A"}, limits={0,inf,0}//, fColor=(13107,13107,13107), valueColor=(13107,13107,13107)

	//Model 2...
	SetVariable TwoPhaseSystem_comment2, title=" ",value=root:Packages:Irena_AnalUnifFit:TwoPhaseSystem_comment2, noedit=1
	SetVariable TwoPhaseSystem_comment2, pos={5,330}, size={365,20}, frame=0, help={"Comments"}	

	SetVariable TwoPhaseMediaContrast, pos={20,350}, size={300,20}, title="Scattering contrast [10^20 cm-4]    =     ", help={"Scattering contrast calculated for the two materials"}
	SetVariable TwoPhaseMediaContrast, variable=root:Packages:Irena_AnalUnifFit:TwoPhaseMediaContrast,limits={0,inf,0}, noedit=1, bodyWidth=80, format="%.4g"

	SetVariable BforTwoPhMat, pos={20,370}, size={300,20}, title="Porod Constant [A\S-4\Mcm\S-1\M]    =     ", format="%.4g"
	SetVariable BforTwoPhMat, variable=root:Packages:Irena_AnalUnifFit:BforTwoPhMat, noedit=1, bodyWidth=80, disable=2, noedit=1
	SetVariable BforTwoPhMat,proc=IR2U_SetVarProc, help={"B from Unified fit, Porod constant "}, limits={0,inf,0}//, fColor=(13107,13107,13107), valueColor=(13107,13107,13107)
	//model 3
	SetVariable TwoPhaseSystem_comment3, title=" ",value=root:Packages:Irena_AnalUnifFit:TwoPhaseSystem_comment3, noedit=1
	SetVariable TwoPhaseSystem_comment3, pos={5,290}, size={365,20}, frame=0, help={"Comments"}	

	SetVariable DensityMinorityPhase2, pos={20,325}, size={300,20}, title="Minority phase density[g/cm3]  =     ", help={"Skeleton phase (solid) density, should be minority phase"}
	SetVariable DensityMinorityPhase2, variable=root:Packages:Irena_AnalUnifFit:DensityMinorityPhase,limits={0,inf,0}, proc=IR2U_SetVarProc, bodyWidth=80, format="%.4g"
	//model 4
	SetVariable TwoPhaseSystem_comment4, title=" ",value=root:Packages:Irena_AnalUnifFit:TwoPhaseSystem_comment4, noedit=1
	SetVariable TwoPhaseSystem_comment4, pos={5,330}, size={365,20}, frame=0, help={"Comments"}	

	SetVariable SampleBulkDensity2, pos={20,350}, size={300,20}, title="Sample bulk density [g/cm3]    =     ", help={"Sample bulk density"}
	SetVariable SampleBulkDensity2, variable=root:Packages:Irena_AnalUnifFit:SampleBulkDensity,limits={0,inf,0}, proc=IR2U_SetVarProc, bodyWidth=80, format="%.4g"
	//model 5

	SetVariable TwoPhaseSystem_comment5, title=" ",value=root:Packages:Irena_AnalUnifFit:TwoPhaseSystem_comment5, noedit=1
	SetVariable TwoPhaseSystem_comment5, pos={5,290}, size={365,20}, frame=0, help={"Comments"}	

	SetVariable PartAnalVolumeOfParticle, pos={20,340}, size={300,20}, title="Particle volume [cm3]    =     ", help={"Single particle volume from I(Q=0) and invariant"}, noedit=1
	SetVariable PartAnalVolumeOfParticle, variable=root:Packages:Irena_AnalUnifFit:PartAnalVolumeOfParticle,limits={0,inf,0}, proc=IR2U_SetVarProc, bodyWidth=80, format="%.4g"
	SetVariable PartAnalRgFromVp, pos={20,355}, size={300,20}, title="Rg from Vp [A]    =     ", help={"Rg calculated from single particle volume"}, noedit=1
	SetVariable PartAnalRgFromVp, variable=root:Packages:Irena_AnalUnifFit:PartAnalRgFromVp,limits={0,inf,0}, proc=IR2U_SetVarProc, bodyWidth=80, format="%.4g"
	SetVariable PartAnalParticleDensity, pos={20,375}, size={300,20}, title="Particle density  [1/cm3]    =     ", help={"Single particle volume from I(Q=0) and invariant"}, noedit=1
	SetVariable PartAnalParticleDensity, variable=root:Packages:Irena_AnalUnifFit:PartAnalParticleDensity,limits={0,inf,0}, proc=IR2U_SetVarProc, bodyWidth=80, format="%.4g"
	//model 6
	SetVariable TwoPhaseSystem_comment6, title=" ",value=root:Packages:Irena_AnalUnifFit:TwoPhaseSystem_comment6, noedit=1
	SetVariable TwoPhaseSystem_comment6, pos={5,290}, size={365,20}, frame=0, help={"Comments"}	
	
	SetVariable PartANalRHard, pos={20,325}, size={300,20}, title="Particle R from Rg [A]    =     ", help={"Particle rsadius from Rg in cm"}, noedit=1
	SetVariable PartANalRHard, variable=root:Packages:Irena_AnalUnifFit:PartANalRHard,limits={0,inf,0}, proc=IR2U_SetVarProc, bodyWidth=80, format="%.4g"

	//other buttons...	
	Button PrintToGraph, pos={5,482}, size={150,20}, title="Print to Graph"
	Button PrintToGraph proc=IR2U_ButtonProc, help={"Create tag with results in the graph"}
	Button Invariantbutt pos={180,482} ,size={60,20},proc=IR2U_ButtonProc, help={"Calculate invariant"}
	Button Invariantbutt title="Calculate"

	NVAR CurrentResults=root:packages:Irena_AnalUnifFit:CurrentResults
	if(CurrentResults)
		Button PrintToGraph, title="Print to Unified Fit Graph"
		Button Invariantbutt, disable=0
	else
		Button PrintToGraph, title="Print to top Graph"
		Button Invariantbutt, disable=1
	endif
	
	Button OpenScattContrCalc, pos={5,275}, size={200,20}, title="Open Scatt. Contr. Calc"
	Button OpenScattContrCalc proc=IR2U_ButtonProc, help={"Create tag with results in the graph"}
	Button GetHelp, pos={210,277}, size={90,20}, title="Get Help"
	Button GetHelp proc=IR2U_ButtonProc, help={"Open notebook with some help"}
	Button CalcLogNormalDist, pos={180,482}, size={160,20}, title="Calc. & Display Dist."
	Button CalcLogNormalDist proc=IR2U_ButtonProc, help={"Calculate & display Log-normal distribution for these parameters"}	
	Button SaveToHistory, pos={5,510}, size={150,20}, title="Print to history or LogBook"
	Button SaveToHistory proc=IR2U_ButtonProc, help={"Create printout in the history area and  SAS logbook"}//***DWS
	//Button SaveToLogbook, pos={205,510}, size={150,20}, title="Print to LogBook"
	//Button SaveToLogbook proc=IR2U_ButtonProc, help={"Create printrout of result into SAS logbook"}

	IR2U_SetControlsInPanel()
End
//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_InitUnifAnalysis()
	
	DFref oldDf= GetDataFolderDFR()

	
	NewDataFolder/O/S root:Packages
	NewdataFolder/O/S root:Packages:Irena_AnalUnifFit
	
	string/g ListOfVariables
	string/g ListOfStrings
	IR1_CreatePorodLogbook()//**DWS

	ListOfVariables="CurrentResults;StoredResults;"
	ListOfVariables+="SelectedLevel;InvariantValue;InvariantUserContrast;InvariantPhaseVolume;"
	ListOfVariables+="BrFract_G2;BrFract_Rg2;BrFract_B2;BrFract_P2;BrFract_G1;BrFract_Rg1;BrFract_B1;BrFract_P1;"
	ListOfVariables+="BrFract_dmin;BrFract_c;BrFract_z;BrFract_fBr;BrFract_fM;"

	ListOfVariables+="SizeDist_Rg1;SizeDist_G1;SizeDist_B1;SizeDist_P1;SizeDist_PDI;"
	ListOfVariables+="SizeDist_sigmag;SizeDist_GeomMean;SizeDist_SuterMeanDiadp;"
	
	ListOfVariables+="Porod_Contrast;Porod_SpecificSfcArea;Porod_Constant;Porod_PowerLawSlope;"
	ListOfVariables+="SizeDist_NumPoints;SizeDist_MinSize;SizeDist_MaxSize;SizeDist_UserVolume;"

//	ListOfVariables+="SampleBulkDensity;mtl;solv;anal;Composition;GenericParameter;"//needed for invariant
	ListOfVariables+="SampleBulkDensity;InvariantValue;DensityMinorityPhase;DensityMajorityPhase;"//needed for invariant
	ListOfVariables+="SLDDensityMinorityPhase;SLDDensityMajorityPhase;TwoPhaseMediaContrast;TwoPhaseInvariant;"//needed for invariant
	ListOfVariables+="MajorityPhasePhi;MinorityPhasePhi;PiBoverQ;MinorityCordLength;MajorityCordLength;SurfacePerVolume;SurfacePerMass;"//
	ListOfVariables+="BforTwoPhMat;PartAnalVolumeOfParticle;PartAnalRgFromVp;PartAnalParticleDensity;PartANalRHard;"//
	ListOfVariables+="TwoPhaseInvariantBetweenCursors;InvariantUsed;printexcel;printlogbook;UseCsrInv;SelectedQlevel;SelectedBlevel;UseUnifiedInv;"
	ListOfVariables+="SelectedQlevel;SelectedBlevel;"

	//PDI is polydispersity index 
	//
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"	
	ListOfStrings="Model;KnownModels;StoredResultsFolder;StoredResultsIntWvName;"
	ListOfStrings+="AvailableLevels;SlectedBranchedLevels;"
	ListOfStrings+="BrFract_Reference1;BrFract_Reference2;BrFract_ErrorMessage;"
	ListOfStrings+="SizeDist_Reference;SizeDist_ErrorMessage;Porod_ErrorMessage;"

	ListOfStrings+="TwoPhaseSystem_reference;TwoPhaseSystem_comment1;TwoPhaseSystem_comment2;TwoPhaseSystem_comment3;"
	ListOfStrings+="TwoPhaseSystem_comment4;TwoPhaseSystem_comment5;TwoPhaseSystem_comment6;DensitiesLegend;"
	ListOfStrings+="TwoPhaseSys_MinName;TwoPhaseSys_MajName;TwoPhaseSysAvailableNames;PorodNotebookName;"
	
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	SVAR  TwoPhaseSys_MinName
	SVAR TwoPhaseSys_MajName
	SVAR TwoPhaseSysAvailableNames
	TwoPhaseSysAvailableNames="User; MCE; Nylon; Si.9_B.2_O2.1;SiO2;PVDF;Cellulose Acetate;air;methanol;SBR;PDMS;LDPE;Pd;H20;PVPD;HDPE,;Al2O3"
	TwoPhaseSys_MinName = "User"
	TwoPhaseSys_MinName = "User"
	make/o/n=20 TwoPhasescattlength,TwoPhasedensities  //MCE, Nylon, Si.9_B.2_O2.1,SiO2,PVDF, CA,air, ipropOH, SBR,PDMS, LDPE,Pd,H2O,PVPD,HDPE, Al2O3
	//scattering lengths cm/g
	TwoPhaseScattlength[0,16]={0,8.66, 9.24, 8.48817,  8.467,  8.43,8.8717,0,9.25, 9.2868,9.169,9.562, 12.2,9.44,  9.1721, 9.562, 8.27}//cm/g
	TwoPhaseDensities[0,16]={0,1.54, 1.15, 2.2,2.05, 1.79, 1.3, 0,.786,.93,.97,.85,12,.997044,1.25,.92,3.95}  	


	SVAR Model
	Model="---"
	SVAR KnownModels
	KnownModels = "Invariant;Porods Law;Branched mass fractal;Size distribution;TwoPhaseSys1;TwoPhaseSys2;TwoPhaseSys3;TwoPhaseSys4;TwoPhaseSys5;TwoPhaseSys6;"
	SVAR AvailableLevels
	AvailableLevels="---;"
	SVAR SlectedBranchedLevels
	SlectedBranchedLevels="---;"
	SVAR BrFract_Reference1
	BrFract_Reference1="Beaucage Phys.Rev.E(2004) 70(3) p10"
	SVAR BrFract_Reference2
	BrFract_Reference2="Beaucage Biophys.J.(2008) 95(2) p503"
	SVAR BrFract_ErrorMessage
	BrFract_ErrorMessage=""
	SVAR SizeDist_Reference
	SizeDist_Reference="Beaucage, Kammler and Pratsinis, J.Appl.Crystal. (2004) 37 p523"
	SVAR SizeDist_ErrorMessage
	SizeDist_ErrorMessage=""
	SVAR Porod_ErrorMessage
	Porod_ErrorMessage=""
	SVAR DensitiesLegend
	DensitiesLegend = "Density [g/cm3]              SL/g  10^10 [cm/ g)]"
	
	SVAR TwoPhaseSystem_reference
	TwoPhaseSystem_reference = "Ref: N. Hu, et al. J. Membrane Sci., V. 379, Is. 1–2, 2011, p. 138–145." 
	SVAR TwoPhaseSystem_comment1
	TwoPhaseSystem_comment1 = "Valid for P=4, known all densities, defined invariant, abs. calibration not needed."
	SVAR TwoPhaseSystem_comment2
	TwoPhaseSystem_comment2 = "Valid for P=4, known contrast, absolute intensity, not defined invariant."
	SVAR  TwoPhaseSystem_comment3
	TwoPhaseSystem_comment3 = "Valid for P=4, known sample density & contrast, defined invariant, abs. calibration needed."
	SVAR  TwoPhaseSystem_comment4
	TwoPhaseSystem_comment4 ="Known SLDs, calibrated data, defined invariant"
	SVAR  TwoPhaseSystem_comment5
	TwoPhaseSystem_comment5 ="Particulate analysis - valid for small phi only, valid G and Invariant"
	SVAR   TwoPhaseSystem_comment6
	TwoPhaseSystem_comment6="Calibrated data, valid Rg and Invariant"
	
	NVAR Porod_Contrast
	if(Porod_Contrast<=0)
		Porod_Contrast=100
	endif
	NVAR InvariantUserContrast
	if(InvariantUserContrast<=0)
		InvariantUserContrast=100
	endif
	NVAR CurrentResults
	NVAR StoredResults
	if(CurrentResults+StoredResults!=1)
		CurrentResults=1
		StoredResults=0
	endif
	NVAR InvariantValue
	InvariantValue =0 
	NVAR InvariantPhaseVolume
	InvariantPhaseVolume = 0

	NVAR SizeDist_NumPoints=root:Packages:Irena_AnalUnifFit:SizeDist_NumPoints
	NVAR SizeDist_UserVolume
	NVAR SizeDist_MinSize=root:Packages:Irena_AnalUnifFit:SizeDist_MinSize
	NVAR SizeDist_MaxSize=root:Packages:Irena_AnalUnifFit:SizeDist_MaxSize
	
	if(SizeDist_UserVolume<=0)
		SizeDist_UserVolume=0.1
	endif
	if(SizeDist_MinSize<5)	//5A is smallest size possible
		SizeDist_MinSize=5
	endif
	if(SizeDist_MaxSize<100)
		SizeDist_MaxSize=100
	endif
	if(SizeDist_NumPoints<20)
		SizeDist_NumPoints=400
	endif

	setDataFolder OldDf
end 
//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	NVAR SelectedLevel=root:Packages:Irena_AnalUnifFit:SelectedLevel
	SVAR SlectedBranchedLevels=root:Packages:Irena_AnalUnifFit:SlectedBranchedLevels
	SetVariable BrFract_ErrorMessage, win=UnifiedEvaluationPanel,  labelBack=0
	SetVariable SizeDist_ErrorMessage, win=UnifiedEvaluationPanel,  labelBack=0
	NVAR SelectedQlevel=root:Packages:Irena_AnalUnifFit:SelectedQlevel
	NVAR SelectedBlevel=root:Packages:Irena_AnalUnifFit:SelectedBlevel
	IR2U_ZeroStaleValues()

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			string CtrlName=pa.ctrlName
			If (popnum==6)
				checkbox UseCsrInv disable=1
				NVAR UsecsrInv=root:Packages:Irena_AnalUnifFit:UseCsrInv
				UseCsrInv=0
			elseif ((popnum==5)||(popnum==7))
				checkbox UseCsrInv disable=0
			endif
			if(stringMatch(CtrlName,"Model"))
				KillWIndow/Z InvariantGraph
				SVAR Model=root:Packages:Irena_AnalUnifFit:Model
				Model = popStr
				SelectedLevel =0
				IR2U_SetControlsInPanel()	
				IR2U_FindAvailableLevels()
				IR2U_ClearVariables()
			endif
			if(stringMatch(CtrlName,"AvailableLevels"))
				SelectedLevel = str2num(popStr[0,0])
				SlectedBranchedLevels=popStr
				IR2U_SetControlsInPanel()
				IR2U_RecalculateAppropriateVals()
			endif
			if(stringMatch(CtrlName,"SelectedQlevel"))
				SelectedQlevel = str2num(popStr[0,0])
				//SelectedQlevel=popStr
				if(SelectedQlevel<SelectedBlevel  && numtype(SelectedBlevel)==0)
					Print "End level is low-q level and must be higher number than Start"
					abort "End level is low-q level and must be higher number than Start"
				endif
				//IR2U_SetControlsInPanel()
				IR2U_RecalculateAppropriateVals()
			endif
			if(stringMatch(CtrlName,"SelectedBlevel"))
				SelectedBlevel = str2num(popStr[0,0])
				//SelectedBlevel=popStr
				if(SelectedQlevel<SelectedBlevel && numtype(SelectedQlevel)==0)
					Print "Start level is high-q level and must be smaller number than End"
					Abort "Start level is high-q level and must be smaller number than End"
				endif
				//IR2U_SetControlsInPanel()
				IR2U_RecalculateAppropriateVals()
			endif
			
			if(stringMatch(CtrlName,"IntensityDataName")||stringMatch(CtrlName,"SelectDataFolder"))
				IR2C_PanelPopupControl(pa)		
				SVAR Model=root:Packages:Irena_AnalUnifFit:Model
				Model = "---"
				Execute("PopupMenu Model,win=UnifiedEvaluationPanel, mode=1,popvalue=\"---\",value= root:Packages:Irena_AnalUnifFit:KnownModels")
				IR2U_SetControlsInPanel()	
				IR2U_FindAvailableLevels()
				IR2U_ClearVariables()
			endif	
			if(stringMatch(CtrlName,"MinorityPhaseVals"))
				SVAR TwoPhaseSys_MinName= root:Packages:Irena_AnalUnifFit:TwoPhaseSys_MinName
				NVAR SLDDensityMinorityPhase = root:Packages:Irena_AnalUnifFit:SLDDensityMinorityPhase
				NVAR DensityMinorityPhase = root:Packages:Irena_AnalUnifFit:DensityMinorityPhase
				Wave TwoPhaseScattlength = root:Packages:Irena_AnalUnifFit:TwoPhaseScattlength
				Wave TwoPhaseDensities = root:Packages:Irena_AnalUnifFit:TwoPhaseDensities
				SLDDensityMinorityPhase = TwoPhaseScattlength[popNum-1]
				DensityMinorityPhase = TwoPhaseDensities[popNum-1]
				TwoPhaseSys_MinName = popStr
				IR2U_TwoPhaseModelCalc()
			endif
			if(stringMatch(CtrlName,"MajorityPhaseVals"))
				SVAR TwoPhaseSys_MajName= root:Packages:Irena_AnalUnifFit:TwoPhaseSys_MajName
				NVAR SLDDensityMajorityPhase = root:Packages:Irena_AnalUnifFit:SLDDensityMajorityPhase
				NVAR DensityMajorityPhase = root:Packages:Irena_AnalUnifFit:DensityMajorityPhase
				Wave TwoPhaseScattlength = root:Packages:Irena_AnalUnifFit:TwoPhaseScattlength
				Wave TwoPhaseDensities = root:Packages:Irena_AnalUnifFit:TwoPhaseDensities
				SLDDensityMajorityPhase = TwoPhaseScattlength[popNum-1]
				DensityMajorityPhase = TwoPhaseDensities[popNum-1]
				TwoPhaseSys_MajName = popStr
				IR2U_TwoPhaseModelCalc()
			endif

			break
	endswitch

	return 0
End
//***********************************************************
Function IR2U_ZeroStaleValues()		//zeroes stale results when user makes any change in controls

	NVAR MinorityPhasePhi=root:Packages:Irena_AnalUnifFit:MinorityPhasePhi //calculate here. 
	NVAR MajorityPhasePhi=root:Packages:Irena_AnalUnifFit:MajorityPhasePhi //calculate here. 
	NVAR PiBoverQ=root:Packages:Irena_AnalUnifFit:PiBoverQ //calculate here... 
	NVAR MinorityCordLength=root:Packages:Irena_AnalUnifFit:MinorityCordLength //calcualte here... 
	NVAR MajorityCordLength=root:Packages:Irena_AnalUnifFit:MajorityCordLength //calcualte here... 
	NVAR SurfacePerVolume=root:Packages:Irena_AnalUnifFit:SurfacePerVolume //calcualte here... 
	NVAR SurfacePerMass = root:Packages:Irena_AnalUnifFit:SurfacePerMass

		MinorityPhasePhi =0
		MajorityPhasePhi  = 0
		SurfacePerVolume=0
		SurfacePerMass = 0
		MinorityCordLength = 0
		MajorityCordLength = 0
		PiBoverQ = 0
	KillWIndow/Z InvariantGraph
end
//***********************************************************
//***********************************************************

Function IR2U_SetControlsInPanel()

		SVAR Model=root:Packages:Irena_AnalUnifFit:Model
		NVAR CurrentResults = root:packages:Irena_AnalUnifFit:CurrentResults
		SVAR SlectedBranchedLevels=root:Packages:Irena_AnalUnifFit:SlectedBranchedLevels
		NVAR SelectedQlevel = root:packages:Irena_AnalUnifFit:SelectedQlevel
		NVAR SelectedBlevel = root:packages:Irena_AnalUnifFit:SelectedBlevel
	
		DoWIndow UnifiedEvaluationPanel
		if(V_Flag)
			DoWIndow/F UnifiedEvaluationPanel
			if(CurrentResults)
				PopupMenu SelectDataFolder,disable=1
				PopupMenu IntensityDataName,disable=1	
				Setvariable FolderMatchStr, disable=1
			else
				PopupMenu SelectDataFolder,disable=0
				PopupMenu IntensityDataName,disable=0	
				Setvariable FolderMatchStr, disable=0
			endif

			PopupMenu SelectedQlevel,disable=1
			PopupMenu SelectedBlevel,disable=1

			SetVariable InvariantValue, disable=1
			SetVariable InvariantUserContrast, disable=1
			SetVariable InvariantPhaseVolume, disable=1

			SetVariable BrFract_G2, disable=1
			SetVariable BrFract_Rg2, disable=1
			SetVariable BrFract_B2, disable=1
			SetVariable BrFract_P2, disable=1
			SetVariable BrFract_ErrorMessage, disable=1
			SetVariable BrFract_dmin, disable=1
			SetVariable BrFract_c, disable=1
			SetVariable BrFract_z, disable=1
			SetVariable BrFract_fBr, disable=1
			SetVariable BrFract_fM, disable=1
			SetVariable BrFract_Reference1, disable=1
			SetVariable BrFract_Reference2, disable=1

			SetVariable SizeDist_G1, disable=1
			SetVariable SizeDist_Rg1, disable=1
			SetVariable SizeDist_B1, disable=1
			SetVariable SizeDist_P1, disable=1
			SetVariable SizeDist_ErrorMessage, disable=1	
			SetVariable SizeDist_sigmag, disable=1
			SetVariable SizeDist_GeomMean, disable=1
			SetVariable SizeDist_PDI, disable=1
			SetVariable SizeDist_SuterMeanDiadp, disable=1
			SetVariable SizeDist_Reference, disable=1	


			SetVariable Porod_Constant, disable=1	
			SetVariable Porod_Contrast, disable=1	
			SetVariable Porod_SpecificSfcArea, disable=1	
			SetVariable Porod_PowerLawSlope, disable=1
			SetVariable Porod_ErrorMessage, disable=1
			Button CalcLogNormalDist, disable=1
			Button Invariantbutt, disable=0//dws 2017
			Checkbox UseCsrInv, disable=1

			SetVariable DensitiesLegend, disable=1
			SetVariable SLDDensityMinorityPhase, disable=1
			SetVariable SLDDensityMajorityPhase, disable=1
			SetVariable SampleBulkDensity, disable=1
			SetVariable DensityMinorityPhase, disable=1, pos={10,215}
			SetVariable DensityMajorityPhase, disable=1
			SetVariable MinorityPhasePhi, disable=1
			SetVariable PiBoverQ, disable=1
			SetVariable MinorityCordLength, disable=1
			SetVariable MajorityCordLength, disable=1
			SetVariable SurfacePerVolume, disable=1
			SetVariable SurfacePerMass, disable=1
			SetVariable MajorityPhasePhi, disable=1
			SetVariable DensityMinorityPhase2, disable=1

		//	SetVariable TwoPhaseMediaContrast, disable=1
			Button OpenScattContrCalc, disable=1
			SetVariable BforTwoPhMat, disable=1
			SetVariable TwoPhaseSystem_reference, disable=1
			SetVariable TwoPhaseSystem_comment1, disable=1
			SetVariable TwoPhaseSystem_comment2, disable=1
			SetVariable TwoPhaseMediaContrast, disable=1

			SetVariable TwoPhaseSystem_comment6, disable=1
			SetVariable TwoPhaseSystem_comment4, disable=1
			SetVariable TwoPhaseSystem_comment3, disable=1
			SetVariable SampleBulkDensity2, disable=1

			SetVariable PartAnalVolumeOfParticle, disable=1
			SetVariable PartAnalRgFromVp, disable=1
			SetVariable PartAnalParticleDensity, disable=1
			SetVariable TwoPhaseSystem_comment5, disable=1
			SetVariable PartANalRHard, disable=1
			PopupMenu MinorityPhaseVals, disable=1
			PopupMenu MajorityPhaseVals, disable=1

			SetVariable TwoPhaseSys_MinName, disable=1
			SetVariable TwoPhaseSys_MajName, disable=1
			//PopupMenu AvailableLevels, value=#SlectedBranchedLevels
			//PopupMenu AvailableLevels,win=UnifiedEvaluationPanel,mode=1,popvalue=SlectedBranchedLevels
			if(stringmatch(Model,"Branched mass fractal"))
				SetVariable BrFract_G2, disable=0
				SetVariable BrFract_Rg2, disable=0
				SetVariable BrFract_B2, disable=0
				SetVariable BrFract_P2, disable=0
				SetVariable BrFract_ErrorMessage, disable=0
				SetVariable BrFract_dmin, disable=0
				SetVariable BrFract_c, disable=0
				SetVariable BrFract_z, disable=0
				SetVariable BrFract_fBr, disable=0
				SetVariable BrFract_fM, disable=0
				SetVariable BrFract_Reference1, disable=0
				SetVariable BrFract_Reference2, disable=0
			elseif(stringmatch(Model,"Invariant"))
				SetVariable InvariantValue, disable=0
				SetVariable InvariantUserContrast, disable=0
				Button OpenScattContrCalc, disable=0
				SetVariable InvariantPhaseVolume, disable=0
				if(stringMatch(SlectedBranchedLevels,"Range"))
					PopupMenu SelectedQlevel,disable=0//, value=num2str(SelectedQlevel)
					PopupMenu SelectedBlevel,disable=0//, value=num2str(SelectedBlevel)
				endif
			elseif(stringmatch(Model,"Porods law"))
				SetVariable Porod_Constant, disable=0	
				SetVariable Porod_Contrast, disable=0	
				Button OpenScattContrCalc, disable=0
				SetVariable Porod_SpecificSfcArea, disable=0	
				SetVariable Porod_PowerLawSlope, disable=0
				SetVariable Porod_ErrorMessage, disable=0
			elseif(stringmatch(Model,"Size distribution"))
				SetVariable SizeDist_G1, disable=0
				SetVariable SizeDist_Rg1, disable=0
				SetVariable SizeDist_B1, disable=0
				SetVariable SizeDist_P1, disable=0
				SetVariable SizeDist_ErrorMessage, disable=0	
				SetVariable SizeDist_sigmag, disable=0
				SetVariable SizeDist_GeomMean, disable=0
				SetVariable SizeDist_PDI, disable=0
				SetVariable SizeDist_SuterMeanDiadp, disable=0
				SetVariable SizeDist_Reference, disable=0	
				Button CalcLogNormalDist, disable=0
			elseif(stringmatch(Model,"TwoPhaseSys1"))
				SetVariable TwoPhaseSys_MinName, disable=0
				SetVariable TwoPhaseSys_MajName, disable=0
				SetVariable SampleBulkDensity, disable=0
				SetVariable DensitiesLegend, disable=0
				SetVariable DensityMinorityPhase, disable=0
				SetVariable DensityMajorityPhase, disable=0
				SetVariable PiBoverQ, disable=0
				SetVariable MinorityCordLength, disable=0
				SetVariable MajorityCordLength, disable=0
				SetVariable SurfacePerVolume, disable=0
				SetVariable SurfacePerMass, disable=0
				SetVariable MinorityPhasePhi, disable=0
				SetVariable MajorityPhasePhi, disable=0
				SetVariable TwoPhaseSystem_reference, disable=0
				SetVariable TwoPhaseSystem_comment1, disable=0
				PopupMenu MinorityPhaseVals, disable=0
				PopupMenu MajorityPhaseVals, disable=0
				Button Invariantbutt, disable=0
				Checkbox UseCsrInv, disable=0
				if(stringMatch(SlectedBranchedLevels,"Range"))
					PopupMenu SelectedQlevel,disable=0
					PopupMenu SelectedBlevel,disable=0
				endif
			elseif(stringmatch(Model,"TwoPhaseSys2"))
				SetVariable TwoPhaseSys_MinName, disable=0
				SetVariable TwoPhaseSys_MajName, disable=0
				SetVariable TwoPhaseMediaContrast, disable=0
				SetVariable SampleBulkDensity, disable=0
				SetVariable DensitiesLegend, disable=0
				SetVariable SLDDensityMinorityPhase, disable=0
				SetVariable SLDDensityMajorityPhase, disable=0
				SetVariable DensityMinorityPhase, disable=0
				SetVariable DensityMajorityPhase, disable=0
				SetVariable MinorityPhasePhi, disable=0
				SetVariable MajorityPhasePhi, disable=0
				SetVariable MinorityCordLength, disable=0
				SetVariable MajorityCordLength, disable=0
				SetVariable SurfacePerVolume, disable=0
				SetVariable SurfacePerMass, disable=0
			//	SetVariable InvariantUserContrast2, disable=0
				Button OpenScattContrCalc, disable=0
				SetVariable BforTwoPhMat, disable=0
				SetVariable TwoPhaseSystem_reference, disable=0
				SetVariable TwoPhaseSystem_comment2, disable=0
				PopupMenu MinorityPhaseVals, disable=0
				PopupMenu MajorityPhaseVals, disable=0
				if(stringMatch(SlectedBranchedLevels,"Range"))
					PopupMenu SelectedQlevel,disable=0
					PopupMenu SelectedBlevel,disable=0
				endif
			elseif(stringmatch(Model,"TwoPhaseSys3"))
				SetVariable TwoPhaseSys_MinName, disable=0
				SetVariable TwoPhaseSys_MajName, disable=0
				SetVariable SurfacePerVolume, disable=0
				SetVariable SurfacePerMass, disable=0
				SetVariable TwoPhaseMediaContrast, disable=0
				SetVariable SampleBulkDensity, disable=0
			//	SetVariable InvariantUserContrast2, disable=0
			//	Button OpenScattContrCalc, disable=0
				SetVariable DensitiesLegend, disable=0
				SetVariable SLDDensityMinorityPhase, disable=0
				SetVariable SLDDensityMajorityPhase, disable=0
				SetVariable DensityMajorityPhase, disable=0
				SetVariable BforTwoPhMat, disable=0
				SetVariable TwoPhaseSystem_reference, disable=0
				SetVariable TwoPhaseSystem_comment3, disable=0
				SetVariable DensityMinorityPhase2, disable=0
				SetVariable MinorityPhasePhi, disable=0
				SetVariable MajorityPhasePhi, disable=0
				SetVariable MinorityCordLength, disable=0
				SetVariable MajorityCordLength, disable=0
				SetVariable TwoPhaseSystem_reference, disable=0
				SetVariable TwoPhaseSystem_comment3, disable=0
				PopupMenu MinorityPhaseVals, disable=0
				PopupMenu MajorityPhaseVals, disable=0
				Button Invariantbutt, disable=0
				Checkbox UseCsrInv, disable=0
				if(stringMatch(SlectedBranchedLevels,"Range"))
					PopupMenu SelectedQlevel,disable=0
					PopupMenu SelectedBlevel,disable=0
				endif
			elseif(stringmatch(Model,"TwoPhaseSys4"))
				SetVariable TwoPhaseSys_MinName, disable=0
				SetVariable TwoPhaseSys_MajName, disable=0
				SetVariable TwoPhaseSystem_reference, disable=0
				SetVariable TwoPhaseSystem_comment4, disable=0
				Button OpenScattContrCalc, disable=0
				SetVariable BforTwoPhMat, disable=0
				SetVariable DensitiesLegend, disable=0
				SetVariable SLDDensityMinorityPhase, disable=0
				SetVariable SLDDensityMajorityPhase, disable=0
				SetVariable DensityMinorityPhase, disable=0
				SetVariable DensityMajorityPhase, disable=0
				SetVariable MinorityCordLength, disable=0
				SetVariable MajorityCordLength, disable=0
				SetVariable MinorityPhasePhi, disable=0
				SetVariable MajorityPhasePhi, disable=0
				SetVariable SurfacePerVolume, disable=0
				SetVariable SurfacePerMass, disable=0
				SetVariable SampleBulkDensity2, disable=0
				PopupMenu MinorityPhaseVals, disable=0
				PopupMenu MajorityPhaseVals, disable=0
				Button Invariantbutt, disable=0
				Checkbox UseCsrInv, disable=0
				if(stringMatch(SlectedBranchedLevels,"Range"))
					PopupMenu SelectedQlevel,disable=0
					PopupMenu SelectedBlevel,disable=0
				endif
			elseif(stringmatch(Model,"TwoPhaseSys5"))
				SetVariable TwoPhaseSys_MinName, disable=0
				SetVariable TwoPhaseSys_MajName, disable=0
				SetVariable DensityMinorityPhase, disable=0
				SetVariable DensityMajorityPhase, disable=0
				SetVariable SampleBulkDensity, disable=0
				SetVariable DensitiesLegend, disable=0
				SetVariable TwoPhaseSystem_reference, disable=0
				SetVariable TwoPhaseSystem_comment5, disable=0
				SetVariable PartAnalVolumeOfParticle, disable=0
				SetVariable PartAnalRgFromVp, disable=0
				SetVariable PartAnalParticleDensity, disable=0
				PopupMenu MinorityPhaseVals, disable=0
				PopupMenu MajorityPhaseVals, disable=0
				Button Invariantbutt, disable=0
				Checkbox UseCsrInv, disable=0
				if(stringMatch(SlectedBranchedLevels,"Range"))
					PopupMenu SelectedQlevel,disable=0
					PopupMenu SelectedBlevel,disable=0
				endif
			elseif(stringmatch(Model,"TwoPhaseSys6"))
				SetVariable TwoPhaseSys_MinName, disable=0
				SetVariable TwoPhaseSys_MajName, disable=0
				SetVariable DensityMinorityPhase, disable=0
				SetVariable DensityMajorityPhase, disable=0
				SetVariable SLDDensityMinorityPhase, disable=0
				SetVariable SLDDensityMajorityPhase, disable=0
				//SetVariable SampleBulkDensity, disable=0
				SetVariable DensitiesLegend, disable=0
				SetVariable TwoPhaseSystem_reference, disable=0
				SetVariable TwoPhaseSystem_comment6, disable=0
				SetVariable PartAnalVolumeOfParticle, disable=0
				//SetVariable PartAnalRgFromVp, disable=0
				SetVariable PartAnalParticleDensity, disable=0
				SetVariable SurfacePerVolume, disable=0
				SetVariable MinorityPhasePhi, disable=0
				SetVariable MajorityPhasePhi, disable=0
				SetVariable PartANalRHard, disable=0
				PopupMenu MinorityPhaseVals, disable=0
				PopupMenu MajorityPhaseVals, disable=0
				Button Invariantbutt, disable=0
				Checkbox UseCsrInv, disable=0
				if(stringMatch(SlectedBranchedLevels,"Range"))
					PopupMenu SelectedQlevel,disable=0
					PopupMenu SelectedBlevel,disable=0
				endif
			endif
		else
			return 0
		endif
end
//***********************************************************
//***********************************************************
//***********************************************************


Function IR2U_DWSCheckboxProc(ctrlName,checked) : CheckBoxControl//**DWS
	String ctrlName
	Variable checked
	
	if(stringmatch(ctrlName, "UseCsrInv"))
		NVAR value=root:packages:Irena_AnalUnifFit:UseCsrInv
		value=checked
		If(!checked)//kill the invariant graph 
			string DF=getdatafolder(1)
				
				setdatafolder root:Packages:Irena_UnifFit:
				KillWIndow/Z invariantGraph
				killwaves/z rwaveq2,qq2,rq2,backqq2,backrq2,frontqq2,frontrq2,rlevel1,qlevel1,DummyRwave,DummyQwave
				setdatafolder DF
			endif
	endif
	
	if(stringmatch(ctrlName, "UnifiedForInv"))//DWS 2017
		NVAR value=root:packages:Irena_AnalUnifFit:UseUnifiedInv
		value=checked
	endif
	
	if(stringmatch(ctrlName, "PrentExcel"))
		NVAR value=root:packages:Irena_AnalUnifFit:printlogbook
		value=checked
	endif
	
	if(stringmatch(ctrlName, "includelogbook"))
		NVAR value=root:packages:Irena_AnalUnifFit:printlogbook
		value=checked
  		SVAR nbl=root:Packages:Irena_AnalUnifFit:PorodNotebookName
		if (strsearch(WinList("*",";","WIN:16"),nbl,0)!=-1) 		///Logbook exists
			if(checked)
				DoWindow/HIDE=0 $nbl
			else
				DoWindow/HIDE=1 $nbl
			endif
		endif
	endif
	
end

Function IR2U_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR CurrentResults=root:packages:Irena_AnalUnifFit:CurrentResults
			NVAR StoredResults=root:packages:Irena_AnalUnifFit:StoredResults
			SVAR Model=root:Packages:Irena_AnalUnifFit:Model
			if(stringMatch(cba.ctrlName,"CurrentResults"))
				StoredResults=!CurrentResults
				Button PrintToGraph, win=UnifiedEvaluationPanel, title="Print to Unified Fit Graph"
				Button Invariantbutt, win=UnifiedEvaluationPanel, disable=0
			endif
			if(stringMatch(cba.ctrlName,"StoredResults"))
				CurrentResults=!StoredResults
				Button PrintToGraph, win=UnifiedEvaluationPanel, title="Print to top Graph"
				Button Invariantbutt, win=UnifiedEvaluationPanel, disable=1
			endif
			Model = "---"
			PopupMenu Model,win=UnifiedEvaluationPanel, mode=1,popvalue="---",value= #"root:Packages:Irena_AnalUnifFit:KnownModels"
			IR2U_SetControlsInPanel()	
			IR2U_FindAvailableLevels()
			IR2U_ClearVariables()
			break
	endswitch

	return 0
End
//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_FindAvailableLevels()
	
	NVAR/Z UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	DoWIndow UnifiedEvaluationPanel
	if(!NVAR_Exists(UseCurrentresults) || !V_Flag)
		return 0
	endif
	
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults
	String quote = "\""

	SVAR Model=root:Packages:Irena_AnalUnifFit:Model
	variable LNumOfLevels, i
	
	if(UseCurrentResults)
		NVAR NumberOfLevels = root:Packages:Irena_UnifFit:NumberOfLevels
		LNumOfLevels = NumberOfLevels
	else
		LNumOfLevels =IR2U_ReturnNoteNumValue("NumberOfModelledLevels")
	endif
	string AvailableLevels=""
	if(stringmatch(Model,"Branched mass fractal"))	
		if(LNumOfLevels>=1)
			AvailableLevels+=num2str(1)+";"
		endif
		For(i=2;i<=LNumOfLevels;i+=1)
			AvailableLevels+=num2str(i)+"/"+num2str(i-1)+";"+num2str(i)+";"
		endfor
	else
		For(i=1;i<=LNumOfLevels;i+=1)
			AvailableLevels+=num2str(i)+";"
		endfor
	endif
	string OnlyNumLevels=AvailableLevels
	if(stringmatch(Model,"TwoPhase*"))	
		AvailableLevels+="Range;All;"
	endif	
	if(stringmatch(Model,"Invariant*"))	
		AvailableLevels+="Range;"
	endif	
	AvailableLevels = quote + AvailableLevels + quote
	OnlyNumLevels = quote + OnlyNumLevels + quote
	NVAR SelectedQlevel=root:Packages:Irena_AnalUnifFit:SelectedQlevel
	NVAR SelectedBlevel=root:Packages:Irena_AnalUnifFit:SelectedBlevel
	SVAR SlectedBranchedLevels=root:Packages:Irena_AnalUnifFit:SlectedBranchedLevels
	string loQStr="---"
	if(SelectedQlevel>0)
		loQStr=num2str(SelectedQlevel)
	endif
	string hiQStr="---"
	if(SelectedBlevel>0)
		hiQStr=num2str(SelectedBlevel)
	endif
	string AvLevStr="---"
	if(stringmatch(AvailableLevels,"*"+SlectedBranchedLevels+"*"))
		AvLevStr=SlectedBranchedLevels
	endif
	PopupMenu AvailableLevels,win=UnifiedEvaluationPanel,mode=1,popvalue= AvLevStr, value=#AvailableLevels
	PopupMenu SelectedQlevel,win=UnifiedEvaluationPanel,mode=1,popvalue=loQStr, value=#OnlyNumLevels
	PopupMenu SelectedBlevel,win=UnifiedEvaluationPanel,mode=1,popvalue=hiQStr, value=#OnlyNumLevels
end
//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_CalculateInvariantVals()

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel
	SVAR SlectedBranchedLevels=root:Packages:Irena_AnalUnifFit:SlectedBranchedLevels
	NVAR InvariantValue = root:Packages:Irena_AnalUnifFit:InvariantValue
	NVAR InvariantUserContrast = root:Packages:Irena_AnalUnifFit:InvariantUserContrast
	NVAR InvariantPhaseVolume = root:Packages:Irena_AnalUnifFit:InvariantPhaseVolume

	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults
	NVAR SelectedQlevel=root:Packages:Irena_AnalUnifFit:SelectedQlevel
	NVAR SelectedBlevel=root:Packages:Irena_AnalUnifFit:SelectedBlevel
	variable i

	if(SelectedLevel>=1)
		if(UseCurrentResults)
			NVAR Invariant=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"Invariant")
			InvariantValue = Invariant
		else
			//look up from wave note...
			InvariantValue = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"Invariant")
		endif
	elseif(stringMatch(SlectedBranchedLevels,"Range"))
		InvariantValue=0
		if(numtype(SelectedQlevel)==0 && numtype(SelectedBlevel)==0 && SelectedBlevel<SelectedQlevel && SelectedBlevel>0 && SelectedQlevel>0)
			For(i=SelectedBlevel;i<=SelectedQlevel;i+=1)
				if(UseCurrentResults)
					NVAR Invariant=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Invariant")
					InvariantValue+= Invariant
				else
					//look up from wave note...
					InvariantValue+= IR2U_ReturnNoteNumValue("Level"+num2str(i)+"Invariant")
				endif
			endfor
		endif
	else
		InvariantValue=0
		InvariantPhaseVolume=0
	endif
	InvariantPhaseVolume = (InvariantValue / InvariantUserContrast)*1e-20/(2*pi^2)		//4/14/2014, JIL, this is really phi*(1-phi). 
	if(InvariantPhaseVolume>0.249)
		DoALert 0, "Calculated volume is too large when we do phi*(1-phi). Seems like there is problem with calibration of contrast"
	endif
	
	InvariantPhaseVolume = (1-sqrt(1-4*InvariantPhaseVolume))/2					//this is quadratic equation solver
end
//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_CalculatePorodsLaw()

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel
	NVAR Porod_Constant = root:Packages:Irena_AnalUnifFit:Porod_Constant
	NVAR Porod_SpecificSfcArea = root:Packages:Irena_AnalUnifFit:Porod_SpecificSfcArea
	NVAR Porod_Contrast = root:Packages:Irena_AnalUnifFit:Porod_Contrast
	SVAR Porod_ErrorMessage=root:Packages:Irena_AnalUnifFit:Porod_ErrorMessage
	NVAR Porod_PowerLawSlope=root:Packages:Irena_AnalUnifFit:Porod_PowerLawSlope
	
	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults

	if(SelectedLevel>=1)
		if(UseCurrentResults)
			NVAR Bval=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"B")
			NVAR Pval=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"P")
			Porod_Constant = Bval
			Porod_PowerLawSlope = Pval
		else
			//look up from wave note...
			Porod_Constant = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"B")
			Porod_PowerLawSlope =  IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"P")
		endif
	else
		Porod_Constant=0
		Porod_SpecificSfcArea=0
		Porod_PowerLawSlope=0
	endif
	
	if(Porod_PowerLawSlope>3.95 && Porod_PowerLawSlope<4.05)
		Porod_SpecificSfcArea =Porod_Constant *1e32 / (2*pi*Porod_Contrast*1e20)
		Porod_ErrorMessage=""
	else
		Porod_ErrorMessage="Error, P should be ~ 4"
		Porod_SpecificSfcArea = 0
	endif
		
	if(strlen(Porod_ErrorMessage)>0)
		SetVariable Porod_ErrorMessage, win=UnifiedEvaluationPanel,  labelBack=(65535,49151,49151)
	else
		SetVariable Porod_ErrorMessage, win=UnifiedEvaluationPanel,  labelBack=0
	endif
	
end



//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_CalculateSizeDist()

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel
	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults

	NVAR SizeDist_G1=root:Packages:Irena_AnalUnifFit:SizeDist_G1
	NVAR SizeDist_Rg1=root:Packages:Irena_AnalUnifFit:SizeDist_Rg1
	NVAR SizeDist_B1=root:Packages:Irena_AnalUnifFit:SizeDist_B1
	NVAR SizeDist_P1=root:Packages:Irena_AnalUnifFit:SizeDist_P1
	SVAR SizeDist_ErrorMessage=root:Packages:Irena_AnalUnifFit:SizeDist_ErrorMessage
	NVAR SizeDist_sigmag=root:Packages:Irena_AnalUnifFit:SizeDist_sigmag
	NVAR SizeDist_GeomMean=root:Packages:Irena_AnalUnifFit:SizeDist_GeomMean
	NVAR SizeDist_PDI=root:Packages:Irena_AnalUnifFit:SizeDist_PDI
	NVAR SizeDist_SuterMeanDiadp=root:Packages:Irena_AnalUnifFit:SizeDist_SuterMeanDiadp
	variable LevelSurfaceToVolRat

	if(SelectedLevel>=1)
		if(UseCurrentResults)
			NVAR gG=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"G")
			SizeDist_G1 = gG
			NVAR gRG=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"Rg")
			SizeDist_Rg1 = gRg
			NVAR gB=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"B")
			SizeDist_B1 = gB
			NVAR gP=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"P")
			SizeDist_P1 = gP
			NVAR gSvR=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"SurfaceToVolRat")
			LevelSurfaceToVolRat = gSvR
			
		else
			//look up from wave note...
			SizeDist_G1 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"G")
			SizeDist_Rg1 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"Rg")
			SizeDist_B1 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"B")
			SizeDist_P1 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"P")
			LevelSurfaceToVolRat = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"SurfaceToVolRat")
		endif
	
		if(SizeDist_P1<3.96 || SizeDist_P1>4.04)
			SizeDist_ErrorMessage =  "ERROR!   P needs to be   ~  4"
			SizeDist_sigmag = 0
			SizeDist_GeomMean = 0
			SizeDist_PDI = 0
			SizeDist_SuterMeanDiadp = 0
		else
			SizeDist_PDI=SizeDist_Rg1^4*SizeDist_B1/1.62/SizeDist_G1
			SizeDist_sigmag=(ln(SizeDist_PDI)/12)^(1/2)
			SizeDist_GeomMean=(5*SizeDist_Rg1^2/3/exp(14*SizeDist_sigmag^2))^(1/2)
			SizeDist_SuterMeanDiadp=6000/LevelSurfaceToVolRat // s/v is in m2/cm3 and dp is in nm
			SizeDist_ErrorMessage =  "  "
			if(SizeDist_PDI<1)
				SizeDist_ErrorMessage =  "Error, see detailed info in history area"
				print "There is a problem with the fit.  The power law prefactor is smaller than for the lowest surface area particle, a sphere so this is not physically possible.  Refit with different starting parameters please."
			endif
			if(SizeDist_PDI>9)//9 is an experimentally observed number for something like a 2.5 aspect ratio rod which is the limit of what you can obeserve as a dimensional object according to Guinier and Fournet.
				SizeDist_ErrorMessage =  "Error, see detailed info in history area"
				print "There is a problem with the fit.  The power law prefactor is larger than any meaningful polydisperse or asymmetric particle with a single Rg."
				print   "Refit with a different model such as using asymmetric particles such as rods or disk models please."
			endif
		endif
	else
			SizeDist_ErrorMessage =  " "
			SizeDist_sigmag = 0
			SizeDist_GeomMean = 0
			SizeDist_PDI = 0
			SizeDist_SuterMeanDiadp = 0

	endif
	if(strlen(SizeDist_ErrorMessage)>3)
		SetVariable SizeDist_ErrorMessage, win=UnifiedEvaluationPanel,  labelBack=(65535,49151,49151)
		beep
	else
		SetVariable SizeDist_ErrorMessage, win=UnifiedEvaluationPanel,  labelBack=0
	endif

end

//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_CalcLogNormalDistribution()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_AnalUnifFit
	NVAR SizeDist_sigmag=root:Packages:Irena_AnalUnifFit:SizeDist_sigmag
	NVAR SizeDist_GeomMean=root:Packages:Irena_AnalUnifFit:SizeDist_GeomMean
	NVAR SizeDist_NumPoints=root:Packages:Irena_AnalUnifFit:SizeDist_NumPoints
	NVAR SizeDist_MinSize=root:Packages:Irena_AnalUnifFit:SizeDist_MinSize
	NVAR SizeDist_MaxSize=root:Packages:Irena_AnalUnifFit:SizeDist_MaxSize
	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel
	NVAR SizeDist_PDI = root:Packages:Irena_AnalUnifFit:SizeDist_PDI
	
	//find reasonable min and max sizes...
	SizeDist_MinSize = SizeDist_GeomMean - (3)*(SizeDist_sigmag+SizeDist_GeomMean)
	SizeDist_MaxSize = SizeDist_GeomMean + (7)*(SizeDist_sigmag+SizeDist_GeomMean)
	IR2U_ReCalculateLogNormalSD()
	Wave RadiusWave
	Wave SizeNumDistribution
	Wave SizeVolDistribution

	DoWIndow IR2U_UnifLogNormalSizeDist
	if(V_Flag)
		DoWIndow/F IR2U_UnifLogNormalSizeDist
	else
		Display /K=1/W=(446,54,1008,510) SizeNumDistribution vs RadiusWave
		AppendToGraph/R SizeVolDistribution vs RadiusWave
		DoWindow/C IR2U_UnifLogNormalSizeDist
		DoWindow/T IR2U_UnifLogNormalSizeDist,"Unifed Log Normal Size distribution"
		//
		ControlBar 60
			SetVariable SizeDist_MinSize,pos={20,10},size={180,16},title="Radius min [A]:  ", format="%3.1f", help={"Minimum size for calculating size distribution"}
			SetVariable SizeDist_MinSize,limits={5,Inf,0},variable=root:Packages:Irena_AnalUnifFit:SizeDist_MinSize, proc=IR2U_SetVarProc
			SetVariable SizeDist_MaxSize,pos={20,35},size={180,16},title="Radius max [A]:  ", format="%3.1f",  help={"Maximum size for calculating size distribution"}
			SetVariable SizeDist_MaxSize,limits={5,Inf,0},variable=root:Packages:Irena_AnalUnifFit:SizeDist_MaxSize, proc=IR2U_SetVarProc

			SetVariable SelectedLevel,pos={220,10},size={100,16},title="Level:  ", format="%3.0f", help={"Selected level for this size distribution"}
			SetVariable SelectedLevel,limits={5,Inf,0},variable=root:Packages:Irena_AnalUnifFit:SelectedLevel, disable=2

			SetVariable SizeDist_UserVolume,pos={350,10},size={150,16},title="Volume fraction:  ", format="%3.3f", help={"Input volume for calibration (if you need it)"}
			SetVariable SizeDist_UserVolume,limits={0,Inf,0},variable=root:Packages:Irena_AnalUnifFit:SizeDist_UserVolume, proc=IR2U_setVarProc
			
			

			Button SaveDataSD,pos={350,35},size={150,20},proc=IR2U_ButtonProc,title="Save SD "
			Button SaveDataSD help={"Select data on the left and push to add data in the graph"}

		//
		ModifyGraph rgb(SizeNumDistribution)=(24576,24576,65535)
		ModifyGraph mirror(bottom)=1
		String LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Number distribution [1/cm\\S3\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"A\\S1\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
		Label left LabelStr
		//Label left "Number distribution [1/cm\\S3\\M A\\S1\\M]"
		LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Radius [A]"
		Label bottom LabelStr
		LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Volume distribution [cm\\S3\\M/cm\\S3\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"A\\S1\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
		Label right LabelStr
		//Label right "Volume distribution [cm\\S3\\M/cm\\S3\\M A\\S1\\M]"
		Legend/C/N=text0/J/A=MC/X=32.48/Y=45.38 "\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"\\s(SizeNumDistribution) Number Distribution\r\\s(SizeVolDistribution) Volume Distribution"
	endif
				
	setDataFolder OldDf
End
//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_ReCalculateLogNormalSD()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_AnalUnifFit
	NVAR SizeDist_sigmag=root:Packages:Irena_AnalUnifFit:SizeDist_sigmag
	NVAR SizeDist_GeomMean=root:Packages:Irena_AnalUnifFit:SizeDist_GeomMean
	NVAR SizeDist_NumPoints=root:Packages:Irena_AnalUnifFit:SizeDist_NumPoints
	NVAR SizeDist_MinSize=root:Packages:Irena_AnalUnifFit:SizeDist_MinSize
	NVAR SizeDist_MaxSize=root:Packages:Irena_AnalUnifFit:SizeDist_MaxSize
	NVAR SizeDist_UserVolume = root:Packages:Irena_AnalUnifFit:SizeDist_UserVolume
	
	//find reasonable min and max sizes...
	if(SizeDist_MinSize<5)	//5A is smallest size possible
		SizeDist_MinSize=5
	endif
	Make/O/N=(SizeDist_NumPoints) RadiusWave, SizeNumDistribution, SizeVolDistribution
	
	RadiusWave = SizeDist_MinSize + p* (SizeDist_MaxSize-SizeDist_MinSize)/SizeDist_NumPoints
	
	SizeNumDistribution=(2/((2*RadiusWave)*SizeDist_sigmag*sqrt(2*pi)))*exp(-(ln((2*RadiusWave)/(2*SizeDist_GeomMean)))^2/(2*SizeDist_sigmag^2))
	SizeVolDistribution = SizeNumDistribution * (4/3*pi*(RadiusWave)^3) 
	
	variable IntegralVol=areaXY(RadiusWave, SizeVolDistribution )
	
	SizeVolDistribution *=SizeDist_UserVolume / IntegralVol
	SizeNumDistribution = SizeVolDistribution / (4/3*pi*(RadiusWave)^3)
	//SizeDist_UserVolume

	setDataFolder OldDf
end


//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_CalculateBranchedMassFr()

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel
	SVAR SlectedBranchedLevels=root:Packages:Irena_AnalUnifFit:SlectedBranchedLevels
	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults

	NVAR BrFract_G2=root:Packages:Irena_AnalUnifFit:BrFract_G2
	NVAR BrFract_Rg2=root:Packages:Irena_AnalUnifFit:BrFract_Rg2
	NVAR BrFract_B2=root:Packages:Irena_AnalUnifFit:BrFract_B2
	NVAR BrFract_P2=root:Packages:Irena_AnalUnifFit:BrFract_P2
	NVAR BrFract_G1=root:Packages:Irena_AnalUnifFit:BrFract_G1
	NVAR BrFract_Rg1=root:Packages:Irena_AnalUnifFit:BrFract_Rg1
	NVAR BrFract_B1=root:Packages:Irena_AnalUnifFit:BrFract_B1
	NVAR BrFract_P1=root:Packages:Irena_AnalUnifFit:BrFract_P1
	SVAR BrFract_ErrorMessage=root:Packages:Irena_AnalUnifFit:BrFract_ErrorMessage
	NVAR BrFract_dmin=root:Packages:Irena_AnalUnifFit:BrFract_dmin
	NVAR BrFract_c=root:Packages:Irena_AnalUnifFit:BrFract_c
	NVAR BrFract_z=root:Packages:Irena_AnalUnifFit:BrFract_z
	NVAR BrFract_fBr=root:Packages:Irena_AnalUnifFit:BrFract_fBr
	NVAR BrFract_fM=root:Packages:Irena_AnalUnifFit:BrFract_fM

	if(SelectedLevel>=2)
		if(UseCurrentResults)
			NVAR gG2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"G")
			BrFract_G2 = gG2
			NVAR gRg2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"Rg")
			BrFract_Rg2 = gRg2
			NVAR gB2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"B")
			BrFract_B2 = gB2
			NVAR gP2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"P")
			BrFract_P2 = gP2
			NVAR gG1=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel-1)+"G")
			BrFract_G1 = gG1
			NVAR gRg1=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel-1)+"Rg")
			BrFract_Rg1 = gRg1
			NVAR gB1=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel-1)+"B")
			BrFract_B1 = gB1
			NVAR gP1=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel-1)+"P")
			BrFract_P1 = gP1
		else
			//look up from wave note...
			BrFract_G2 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"G")
			BrFract_Rg2 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"Rg")
			BrFract_B2 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"B")
			BrFract_P2 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"P")
			BrFract_G1 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel-1)+"G")
			BrFract_Rg1 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel-1)+"Rg")
			BrFract_B1 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel-1)+"B")
			BrFract_P1 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel-1)+"P")
		endif
	elseif(SelectedLevel==1)
		if(UseCurrentResults)
			NVAR gG2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"G")
			BrFract_G2 = gG2
			NVAR gRg2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"Rg")
			BrFract_Rg2 = gRg2
			NVAR gB2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"B")
			BrFract_B2 = gB2
			NVAR gP2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"P")
			BrFract_P2 = gP2
			BrFract_G1 =0
			BrFract_Rg1 = 0
			BrFract_B1 =0
			BrFract_P1 = 0
		else
			//look up from wave note...
			BrFract_G2 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"G")
			BrFract_Rg2 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"Rg")
			BrFract_B2 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"B")
			BrFract_P2 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"P")
			BrFract_G1 = 0
			BrFract_Rg1 = 0
			BrFract_B1 = 0
			BrFract_P1 = 0
		endif
	else
			BrFract_G2 = 0
			BrFract_Rg2 = 0
			BrFract_B2 = 0
			BrFract_P2 = 0
			BrFract_G1 = 0
			BrFract_Rg1 = 0
			BrFract_B1 = 0
			BrFract_P1 = 0
	endif
	if(strlen(SlectedBranchedLevels)>1)
		BrFract_dmin  = BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2)
		BrFract_c  =BrFract_P2/(BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2))
		BrFract_z  =BrFract_G2/BrFract_G1 + 1 			//Greg, 11-24-2018: It should be G2/G1 +1  Karsten figured that out.  If G2 is 0 you still have one primary particle. 
		BrFract_fBr =(1-(BrFract_G2/BrFract_G1)^(1/(BrFract_P2/(BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2)))-1))
		//BrFract_fBr =(1-(BrFract_G2/BrFract_G1)^(1/(BrFract_P2/BrFract_c-1))
		BrFract_fM  = (1-(BrFract_G2/BrFract_G1)^(1/(   (BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2)  ))-1))
		//BrFract_fM  = (1-(BrFract_G2/BrFract_G1)^(1/BrFract_dmin - 1))
	else
		BrFract_dmin  =BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2)
		BrFract_c  =BrFract_P2/(BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2))
		BrFract_z  =Nan
		BrFract_fBr =NaN
		BrFract_fM  = NaN
	endif
	
	if(BrFract_c<0.96)
		BrFract_ErrorMessage =  "The mass fractal is too polydisperse to analyse, c < 1"
	else
		if(BrFract_c>=0.96 && BrFract_c<=1.04)//this should be in the range of 1 say +- .02
			BrFract_ErrorMessage = "THIS IS A LINEAR CHAIN WITH NO BRANCHES!"
		endif
		if(BrFract_c>=3)
			BrFract_ErrorMessage =  "There is a problem with the fit, c must be less than 3"
		endif
		if(BrFract_dmin>=3)
			BrFract_ErrorMessage = "There is a problem with the fit since dmin must be less than 3"
		endif
		if(BrFract_dmin>=0.96 && BrFract_dmin<=1.04 )//this should be in the range of 1 say +- .02
			BrFract_ErrorMessage = "This is a regular object, i.e.  c=1 rod, c=2 disk, c=3 sphere, etc."
		endif
	endif
	
	if(strlen(BrFract_ErrorMessage)>0)
		SetVariable BrFract_ErrorMessage, win=UnifiedEvaluationPanel,  labelBack=(65535,49151,49151)
		beep
	else
		SetVariable BrFract_ErrorMessage, win=UnifiedEvaluationPanel,  labelBack=0
	endif

end


//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_RecalculateAppropriateVals()

	SVAR Model=root:Packages:Irena_AnalUnifFit:Model
	if(stringmatch(Model,"Invariant"))	
		IR2U_CalculateInvariantVals()
	elseif(stringmatch(Model,"Size Distribution"))	
		IR2U_CalculateSizeDist()
	elseif(stringmatch(Model,"Porods law"))	
		IR2U_CalculatePorodsLaw()
	elseif(stringmatch(Model,"Branched mass fractal"))	
		IR2U_CalculateBranchedMassFr()
	elseif(stringmatch(Model,"TwoPhaseSys*"))	
		//IR2U_TwoPhaseModelCalc()				//this needs lot more controls to be set to be useful. 
	ENDIF
	
end

//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
			sva.blockReentry = 1
			if(stringMatch(sva.CtrlName,"InvariantUserContrast"))
				IR2U_CalculateInvariantVals()
			endif
			if(stringMatch(sva.CtrlName,"Porod_Contrast"))
				IR2U_CalculatePorodsLaw()
			endif
			if(stringMatch(sva.CtrlName,"SizeDist_MinSize"))
				IR2U_ReCalculateLogNormalSD()
			endif
			if(stringMatch(sva.CtrlName,"SizeDist_MaxSize"))
				IR2U_ReCalculateLogNormalSD()
			endif
			if(stringMatch(sva.CtrlName,"SizeDist_UserVolume"))
				IR2U_ReCalculateLogNormalSD()
			endif
			if(stringMatch(sva.CtrlName,"*Density*"))
				IR2U_TwoPhaseModelCalc()
			endif
		
			break
		case 2: // Enter key
			sva.blockReentry = 1
			if(stringMatch(sva.CtrlName,"InvariantUserContrast"))
				IR2U_CalculateInvariantVals()
			endif
			if(stringMatch(sva.CtrlName,"Porod_Contrast"))
				IR2U_CalculatePorodsLaw()
			endif
			if(stringMatch(sva.CtrlName,"SizeDist_MinSize"))
				IR2U_ReCalculateLogNormalSD()
			endif
			if(stringMatch(sva.CtrlName,"SizeDist_MaxSize"))
				IR2U_ReCalculateLogNormalSD()
			endif
			if(stringMatch(sva.CtrlName,"SizeDist_UserVolume"))
				IR2U_ReCalculateLogNormalSD()
			endif
			if(stringMatch(sva.CtrlName,"*Density*"))
				IR2U_TwoPhaseModelCalc()
			endif
		
			break
		case 3: // Live update
			sva.blockReentry = 1
			Variable dval = sva.dval
			String sval = sva.sval
			break
	endswitch

	return 0
End
//***********************************************************
//***********************************************************
//***********************************************************
 Function IR2U_ReturnNoteNumValue(KeyWord)
 	string KeyWord
 	
 	variable LUKVal
 	SVAR DataFolderName= root:Packages:Irena_AnalUnifFit:DataFolderName
 	SVAR IntensityWaveName = root:Packages:Irena_AnalUnifFit:IntensityWaveName
 	
 	Wave/Z LkpWv=$(DataFolderName+IntensityWaveName)
 	if(!WaveExists(LkpWv))
 		return NaN
 	endif
 	
 	LUKVal = NumberByKey(KeyWord, note(LkpWv)  , "=",";")
 	return LUKVal
 	
 end
 //***********************************************************
//***********************************************************
//***********************************************************
 Function/S IR2U_ReturnNoteStrValue(KeyWord)
 	string KeyWord
 	
 	string LUKVal
 	SVAR DataFolderName= root:Packages:Irena_AnalUnifFit:DataFolderName
 	SVAR IntensityWaveName = root:Packages:Irena_AnalUnifFit:IntensityWaveName
 	
 	Wave/Z LkpWv=$(DataFolderName+IntensityWaveName)
 	if(!WaveExists(LkpWv))
 		return ""
 	endif
 	
 	LUKVal = StringByKey(KeyWord, note(LkpWv)  , "=",";")
 	return LUKVal
 	
 end
  //***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_ClearVariables()


	NVAR BrFract_G2=root:Packages:Irena_AnalUnifFit:BrFract_G2
	NVAR BrFract_Rg2=root:Packages:Irena_AnalUnifFit:BrFract_Rg2
	NVAR BrFract_B2=root:Packages:Irena_AnalUnifFit:BrFract_B2
	NVAR BrFract_P2=root:Packages:Irena_AnalUnifFit:BrFract_P2
	NVAR BrFract_G1=root:Packages:Irena_AnalUnifFit:BrFract_G1
	NVAR BrFract_Rg1=root:Packages:Irena_AnalUnifFit:BrFract_Rg1
	NVAR BrFract_B1=root:Packages:Irena_AnalUnifFit:BrFract_B1
	NVAR BrFract_P1=root:Packages:Irena_AnalUnifFit:BrFract_P1
	SVAR BrFract_ErrorMessage=root:Packages:Irena_AnalUnifFit:BrFract_ErrorMessage
	NVAR BrFract_dmin=root:Packages:Irena_AnalUnifFit:BrFract_dmin
	NVAR BrFract_c=root:Packages:Irena_AnalUnifFit:BrFract_c
	NVAR BrFract_z=root:Packages:Irena_AnalUnifFit:BrFract_z
	NVAR BrFract_fBr=root:Packages:Irena_AnalUnifFit:BrFract_fBr
	NVAR BrFract_fM=root:Packages:Irena_AnalUnifFit:BrFract_fM
		BrFract_G2 = 0
		BrFract_Rg2 = 0
		BrFract_B2 = 0
		BrFract_P2 = 0
		BrFract_G1 = 0
		BrFract_Rg1 = 0
		BrFract_B1 = 0
		BrFract_P1 = 0
		BrFract_ErrorMessage=""
		BrFract_dmin=0
		BrFract_c=0
		BrFract_z=0
		BrFract_fBr=0
		BrFract_fM=0

	NVAR Porod_Constant = root:Packages:Irena_AnalUnifFit:Porod_Constant
	NVAR Porod_SpecificSfcArea = root:Packages:Irena_AnalUnifFit:Porod_SpecificSfcArea
	SVAR Porod_ErrorMessage=root:Packages:Irena_AnalUnifFit:Porod_ErrorMessage
	NVAR Porod_PowerLawSlope=root:Packages:Irena_AnalUnifFit:Porod_PowerLawSlope
		Porod_Constant=0
		Porod_SpecificSfcArea =0
		Porod_ErrorMessage=""
		Porod_PowerLawSlope=0
		
	NVAR SizeDist_G1=root:Packages:Irena_AnalUnifFit:SizeDist_G1
	NVAR SizeDist_Rg1=root:Packages:Irena_AnalUnifFit:SizeDist_Rg1
	NVAR SizeDist_B1=root:Packages:Irena_AnalUnifFit:SizeDist_B1
	NVAR SizeDist_P1=root:Packages:Irena_AnalUnifFit:SizeDist_P1
	SVAR SizeDist_ErrorMessage=root:Packages:Irena_AnalUnifFit:SizeDist_ErrorMessage
	NVAR SizeDist_sigmag=root:Packages:Irena_AnalUnifFit:SizeDist_sigmag
	NVAR SizeDist_GeomMean=root:Packages:Irena_AnalUnifFit:SizeDist_GeomMean
	NVAR SizeDist_PDI=root:Packages:Irena_AnalUnifFit:SizeDist_PDI
	NVAR SizeDist_SuterMeanDiadp=root:Packages:Irena_AnalUnifFit:SizeDist_SuterMeanDiadp
			
			SizeDist_G1=0
			SizeDist_Rg1=0
			SizeDist_B1=0
			SizeDist_P1=0
			SizeDist_ErrorMessage =  " "
			SizeDist_sigmag = 0
			SizeDist_GeomMean = 0
			SizeDist_PDI = 0
			SizeDist_SuterMeanDiadp = 0
		
	NVAR InvariantValue = root:Packages:Irena_AnalUnifFit:InvariantValue
	NVAR InvariantUserContrast = root:Packages:Irena_AnalUnifFit:InvariantUserContrast
	NVAR InvariantPhaseVolume = root:Packages:Irena_AnalUnifFit:InvariantPhaseVolume
			InvariantValue=0
			InvariantPhaseVolume=0


	NVAR MinorityPhasePhi=root:Packages:Irena_AnalUnifFit:MinorityPhasePhi //calculate here. 
	NVAR MajorityPhasePhi=root:Packages:Irena_AnalUnifFit:MajorityPhasePhi //calculate here. 
	NVAR PiBoverQ=root:Packages:Irena_AnalUnifFit:PiBoverQ //calculate here... 
	NVAR MinorityCordLength=root:Packages:Irena_AnalUnifFit:MinorityCordLength //calcualte here... 
	NVAR MajorityCordLength=root:Packages:Irena_AnalUnifFit:MajorityCordLength //calcualte here... 
	NVAR SurfacePerVolume=root:Packages:Irena_AnalUnifFit:SurfacePerVolume //calcualte here... 
	NVAR PartANalRHard=root:Packages:Irena_AnalUnifFit:PartANalRHard //calcualte here... 
	MinorityPhasePhi=0
	PiBoverQ=0
	MajorityPhasePhi=0
	MinorityCordLength=0
	MajorityCordLength=0
	SurfacePerVolume=0
	PartANalRHard=0
	NVAR Contrast=root:Packages:Irena_AnalUnifFit:TwoPhaseMediaContrast	
	NVAR BforTwoPhMat=root:Packages:Irena_AnalUnifFit:BforTwoPhMat //calcualte here... 
	BforTwoPhMat=0
	Contrast=0
	NVAR PartAnalVolumeOfParticle=root:Packages:Irena_AnalUnifFit:PartAnalVolumeOfParticle //calcualte here... 
	NVAR PartAnalRgFromVp=root:Packages:Irena_AnalUnifFit:PartAnalRgFromVp //calcualte here... 
	NVAR PartAnalParticleDensity=root:Packages:Irena_AnalUnifFit:PartAnalParticleDensity //calcualte here... 
	PartAnalVolumeOfParticle=0
	PartAnalRgFromVp=0
	PartAnalParticleDensity=0

	NVAR MinorityPhasePhi=root:Packages:Irena_AnalUnifFit:MinorityPhasePhi 
	NVAR MajorityPhasePhi=root:Packages:Irena_AnalUnifFit:MajorityPhasePhi 
	NVAR PiBoverQ=root:Packages:Irena_AnalUnifFit:PiBoverQ 
	NVAR MinorityCordLength=root:Packages:Irena_AnalUnifFit:MinorityCordLength
	NVAR MajorityCordLength=root:Packages:Irena_AnalUnifFit:MajorityCordLength 
	NVAR SurfacePerVolume=root:Packages:Irena_AnalUnifFit:SurfacePerVolume  
	NVAR PartANalRHard=root:Packages:Irena_AnalUnifFit:PartANalRHard 
	NVAR BforTwoPhMat=root:Packages:Irena_AnalUnifFit:BforTwoPhMat
	NVAR PartAnalVolumeOfParticle=root:Packages:Irena_AnalUnifFit:PartAnalVolumeOfParticle 
	NVAR PartAnalRgFromVp=root:Packages:Irena_AnalUnifFit:PartAnalRgFromVp 
	NVAR PartAnalParticleDensity=root:Packages:Irena_AnalUnifFit:PartAnalParticleDensity 
	MinorityPhasePhi=0
	MajorityPhasePhi=0
	PiBoverQ=0
	MinorityCordLength=0
	MajorityCordLength=0
	SurfacePerVolume=0
	PartANalRHard=0
	BforTwoPhMat=0
	PartAnalVolumeOfParticle=0
	PartAnalRgFromVp=0
	PartAnalParticleDensity=0

	SVAR TwoPhaseSys_MinName=root:Packages:Irena_AnalUnifFit:TwoPhaseSys_MinName
	TwoPhaseSys_MinName="User"
	SVAR TwoPhaseSys_MajName=root:Packages:Irena_AnalUnifFit:TwoPhaseSys_MajName
	TwoPhaseSys_MajName="User"
	
end

//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			If (cmpstr(ba.ctrlName,"KillInvWindow")==0 || cmpstr(ba.ctrlName,"Invariantbutt")==0)				//Kill invariant window and waves  DWS
				DoWindow InvariantGraph
				if(V_Flag)	// Invariant Graph exists//DWS 2017 eliminate offending code here
					string DF=getdatafolder(1)
					DoWindow/F InvariantGraph
					setdatafolder root:Packages:Irena_UnifFit:
					KillWIndow/Z InvariantGraph//need kill in order dump temp waves
					killwaves/Z rwaveq2,qq2,rq2,backqq2,backrq2,frontqq2,frontrq2,rlevel1,qlevel1,frontrwave,DummyRwave, DummyQwave
					setdatafolder DF
				endif
			endif
			//note, the above code clears up Graph, which will become stale if not killed for InvariantButton calculation. 
			//DO not change order of the above and below blocks or things will break. 
			If (cmpstr(ba.ctrlName,"Invariantbutt")==0)		
				IR2U_TwoPhaseModelCalc()		
			endif
			if(stringMatch(ba.ctrlName,"SaveToHistory"))//***DWS
				//here code to print results to history area
				NVAR  printlogbook=root:Packages:Irena_AnalUnifFit:printlogbook
				If (printlogbook==1)
					DoWIndow PorodAnalysisResults
					if(V_Flag)
						DoWIndow/F PorodAnalysisResults
					endif
					IR2U_SaveResultsperUsrReq("Logbook")
				else
					IR2U_SaveResultsperUsrReq("History")
				endif
			endif
			//if(stringMatch(ba.ctrlName,"SaveToLogbook"))
				//here code to print results to history area
				//IR2U_SaveResultsperUsrReq("Logbook")
			//endif
			if(stringMatch(ba.ctrlName,"PrintToGraph"))
				//here code to print results to history area
				IR2U_SaveResultsperUsrReq("Graph")
			endif
			if(stringMatch(ba.ctrlName,"CalcLogNormalDist"))
				//here code to print results to history area
				IR2U_CalcLogNormalDistribution()
			endif
			if(stringMatch(ba.ctrlName,"SaveDataSD"))
				//here code to print results to history area
				IR2U_SaveLogNormalDistData()
			endif
			if(stringMatch(ba.ctrlName,"OpenScattContrCalc"))
				//here code to print results to history area
				IR1K_ScattCont2()
			endif
			if(stringMatch(ba.ctrlName,"GetHelp"))
				//here code to print results to history area
				IR2U_UnifAnalysisHelp()
			endif

			break
	endswitch

	return 0
End

//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_CalculateInvariantbutton()				//Removed plotting capabilities JIL 2017
	DFref oldDf= GetDataFolderDFR()
	
	variable extrapts=600 //number of points in extrapolation waves	
	Variable overlap=1//number of overlaped points for Porod extrapolation	
	SVAR rwavename=root:Packages:Irena_UnifFit:IntensityWaveName
	SVAR qwavename=root:Packages:Irena_UnifFit:QWavename
	SVAR swavename=root:Packages:Irena_UnifFit:IntensityWaveName
	SVAR datafoldername=root:Packages:Irena_UnifFit:DataFolderName
	NVAR majorityphi=root:Packages:Irena_AnalUnifFit:MajorityPhasePhi//phi is picked up from unified fit data evaluation panel
	NVAR dens=root:Packages:Irena_AnalUnifFit:SampleBulkDensity
	NVAR inv=root:Packages:Irena_AnalUnifFit:TwoPhaseInvariantBetweenCursors//***DWS
	NVAR UseUnifiedInv=root:Packages:Irena_AnalUnifFit:UseUnifiedInv
	NVAR UseCsrInv=root:Packages:Irena_AnalUnifFit:UseCsrInv
	If (StringMatch(rwavename, "*SMR_Int" ))
		Doalert 0, "Invariant Using Cursors\rdoes not work on slit-smeared data"//***DWS 2016 09 29
		Abort
	endif
	setdatafolder datafoldername
	rwavename = ReplaceString("'", rwavename, "")
	qwavename = ReplaceString("'", qwavename, "")
	swavename = ReplaceString("'", swavename, "")
	wave rwave =$rwavename
	wave qwave=$qwavename
	wave swave=$swavename
	setdatafolder root:Packages:Irena_AnalUnifFit:		//do not contaminate users data folder, just store it in Unified Fit folder... 
	Duplicate/o rwave,$"root:Packages:Irena_AnalUnifFit:rwaveq2"
	wave rwaveq2=$"root:Packages:Irena_AnalUnifFit:rwaveq2"
	rwaveq2=rwave*qwave^2
	DoWindow/F IR1_LogLogPlotU
	If (0==WinType("IR1_LogLogPlotU" ))
	  	Doalert 0, "Load a unified fit in the Unified modeling input panel"
	  	abort
	endif
	if ((strlen(CsrInfo(A,"IR1_LogLogPlotU")) == 0)||(strlen(CsrInfo(B,"IR1_LogLogPlotU")) == 0))
	 	Doalert 0, "Cursors not on graph"
	 	abort
	 endif
	//bring graph to top
	variable npts=pcsr(b,"IR1_LogLogPlotU")-pcsr(a,"IR1_LogLogPlotU")+1
	make /o/n=(extrapts)  frontrwave,frontrq2,frontqq2,backrq2,backqq2
	duplicate/o rwave,rq2
	rq2=rwave*qwave^2	
	//DWS 2016  Heavily modified rest of code to end of function
	NVAR SelectedLevel=root:Packages:Irena_AnalUnifFit:SelectedLevel//level number selected for analysis generic to other models.
	SVAR SlectedBranchedLevels = root:Packages:Irena_AnalUnifFit:SlectedBranchedLevels
	NVAR OriginalLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	//variable InitialselectedLevel=SelectedLevel//used to reset the panel at the end.  Just in case there is some interference.
	NVAR SelectedQlevel=root:Packages:Irena_AnalUnifFit:SelectedQlevel//Unique to two phase model
	NVAR SelectedBLevel=root:Packages:Irena_AnalUnifFit:SelectedBLevel//Unique to two phase model
	variable LocSelBLevel, LocSelQLevel
	if(stringmatch(SlectedBranchedLevels,"---")||numtype(SelectedQlevel)!=0||numtype(SelectedBLevel)!=0)
		print "Levels not selected correctly. Check controls"
		abort
	elseif(stringmatch(SlectedBranchedLevels,"All"))	//we use values from level 1 but summ all invariants...
		LocSelQLevel=OriginalLevels
		LocSelBLevel=1
	elseif(stringmatch(SlectedBranchedLevels,"Range"))	//we use values from level 1 but summ all invariants...
		LocSelQLevel=SelectedQlevel
		LocSelBLevel=SelectedBLevel
	else
		LocSelQLevel=SelectedLevel
		LocSelBLevel=SelectedLevel
	endif
	//OK, now we have selected range of levels approprioately for controls... 
	
	NVAR B=$("root:Packages:irena_UnifFit:Level"+num2istr(LocSelBLevel)+"B")
	NVAR PorodSlope=$("root:Packages:irena_UnifFit:Level"+num2istr(LocSelBLevel)+"P")
	NVAR RgselectedQLevel=$("root:Packages:irena_UnifFit:Level"+num2istr(LocSelQLevel)+"Rg")//Rg is only used for caculating the invariant.
	NVAR G=$("root:Packages:irena_UnifFit:Level"+num2istr(LocSelQLevel)+"G")
	SVAR Model=root:Packages:Irena_AnalUnifFit:Model
	variable pcsra=pcsr(a,"IR1_LogLogPlotU")
	variable lowQ=qwave[pcsra]/10
	frontqq2=lowQ+(P+1)*qwave[pcsra]/(extrapts)//first element can't be zero	 Sets limit of lowest q as qwave[pcsr(a)]/extrapts up to about qwave[pcsr(a)]
	IR2U_UnifiedBtwnLevls_DWS(frontqq2,frontrwave, LocSelBLevel,LocSelQLevel)//calculates unified   IR2U_UnifiedBtwnLevls_DWS(qwave,rwave, uptolevel)
		//There is a problem problem if there is a cutoff on Blevel
	frontrq2=frontrwave*frontqq2^2
	variable maxqback=10*hcsr(B)//max q for porod extrapolation
	backqq2=qwave[pcsr(b,"IR1_LogLogPlotU")-overlap]+P*(maxqback-qwave[pcsr(b,"IR1_LogLogPlotU")-overlap])/extrapts	
	backrq2=B/backqq2^2
	variable invariant, PlotDummy=0,plotextensions=1
	make/N=1000/O DummyRwave,DummyQwave
	
If(UseCsrInv&&UseUnifiedInv)//use the Unified between cursors suplemented by analytical extensions
		Plotdummy=1//cursors are used to determine  the limits of extensions.  tests importance of extensions.
		extrapts=1000
		dummyQwave=lowq+maxqback*p/extrapts
		IN2G_ConvertTologspacing(DummyQwave,0)
		IR2U_UnifiedBtwnLevls_DWS(DummyQwave,dummyRwave, SelectedBLevel,SelectedQLevel)
		DummyRwave*=DummyQwave^2
		invariant=areaXY(DummyQwave, DummyRwave)
		Print "Csrs used, Unified invariant.  Cusers determine the hi and lo extensions. Unified fit is used rather than the data."
	elseif((!UseCsrInv)&&UseUnifiedInv)//use unified over the full rage of the data
		Plotdummy=1
		DummyQwave=qwave
		IR2U_UnifiedBtwnLevls_DWS(DummyQwave,dummyRwave, SelectedBLevel,SelectedQLevel)
		DummyRwave*=DummyQwave^2
		invariant=areaXY(DummyQwave, DummyRwave)
		Print "Csr not used, Unified invariant.  Inv from unified fit over full q-range of data."
	elseif(!UseCsrInv&&!UseUnifiedInv)//Use data only, no extensions
		invariant=areaXY(qwave, rq2)
		plotextensions=0
		print "Csr not used, Data invariant.  Inv from data over full q-range of data."
	else//(UseCsrInv&&!UseUnifiedInv)
		//use the Data between cursors and use unified to analytically extend
		Plotdummy=0
		invariant=areaXY(qwave, rq2,hcsr(a,"IR1_LogLogPlotU"), hcsr(b,"IR1_LogLogPlotU"))+areaxy(frontqq2,frontrq2)+abs((B*hcsr(B,"IR1_LogLogPlotU")^-1))//extends with -4 exponent
		Print "Use Csrs, Data invariant.  Inv from data extended by unified fit.  Default method"
	Endif
	IF(StringMatch(model, "TwoPhaseSys1"))
		Print "model = "+model
	endif
	inv=invariant				//***DWS  Store the result so it can be used by   IR2U_TwoPhaseModelCalc()

	NVAR TwoPhaseInvariantBetweenCursors=root:Packages:Irena_AnalUnifFit:TwoPhaseInvariantBetweenCursors
	TwoPhaseInvariantBetweenCursors=invariant*1e24//must be used somewhere else

//	variable Sv=(1e4*pi*B/invariant)*majorityphi*(1-majorityphi)
//	variable majchord=4*majorityphi/Sv
//	variable minchord=4* (1-majorityphi)/Sv
//	//string outtext="Qv = "+num2str(invariant)+" cm^-4\rB = "+num2str(B)+ " cm-1Å-4"
//	string outtext="Qv = "+num2str(invariant)+" cm^-1 Å^-3\rB = "+num2str(B)+ " cm-1Å-4"
//	outtext=outtext+"\rpiB/Q = "+num2str(1e4*pi*B/invariant)+" m2/cm3\rSv = "+num2str(Sv)+" m2/cm3\rSm = "+num2str(Sv/dens)+" m2/g\rlmin = "+num2str(minchord*1e4)+" Å\rlmaj = "+num2str(majchord*1e4)+" Å"		
//	dowindow/R/k InvariantGraph
//	//dowindow/R/k DummyGraph
//			display/K=2  rq2 vs qwave as "q2 I(q) vs q"
//			dowindow/c InvariantGraph
//			IF(plotextensions==1)//dws 2017 b
//				appendtograph frontrq2 vs frontqq2
//				appendtograph backrq2 vs backqq2
//				ModifyGraph rgb(frontrq2)=(8738,8738,8738)
//				ModifyGraph rgb(backrq2)=(8738,8738,8738)
//				Cursor /A=1  A  rq2  0
//				Tag/C/N=text1/F=0/A=LC frontrq2,100,"Level Used = "+Num2str(SelectedQlevel)
//			endif	
//
//		
//		Button KillInvWindow,pos={2,1},size={70,20},proc=IR2U_ButtonProc,title="Kill Window"	
//		ModifyGraph grid=2,tick=2,mirror=1,fStyle=1,fSize=15,font="Times"
//		SetAxis bottom 1e-5,maxqback
//		if(!UseCsrInv)//&&!UseUnifiedInv)
//			SetAxis/A
//		endif
//		print "lmin = "+num2str(minchord*1e4)+" Å"
//		ModifyGraph log=1
//		Label left "\\F'arial'\\Z18I(q)·(q \\S2\\M)"
//		Label bottom "\\F'arial'\\Z18q (A\\S-1\\M)"
//		textbox/C/N=text1df/F=0/X=46.00/Y=30.00  outtext
//		HideTools/A
//	//SelectedLevel=InitialselectedLevel
	setDataFolder OldDf
	
	If ((numtype(invariant)==2))
		doAlert 0, "Pick a level";abort
	endif
End

//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_PlotCalcInvariantFnct()			//JIL 2017 - created to create the funny graph Dale wants
	DFref oldDf= GetDataFolderDFR()
	
	NVAR majorityphi=root:Packages:Irena_AnalUnifFit:MajorityPhasePhi//phi is picked up from unified fit data evaluation panel
	NVAR inv=root:Packages:Irena_AnalUnifFit:TwoPhaseInvariantBetweenCursors//***DWS
	NVAR dens=root:Packages:Irena_AnalUnifFit:SampleBulkDensity
	NVAR TwoPhaseInvariantBetweenCursors=root:Packages:Irena_AnalUnifFit:TwoPhaseInvariantBetweenCursors
	WAVE rq2=root:Packages:Irena_AnalUnifFit:rq2
	WAVE frontrq2=root:Packages:Irena_AnalUnifFit:frontrq2
	WAVE frontqq2=root:Packages:Irena_AnalUnifFit:frontqq2
	WAVE backrq2=root:Packages:Irena_AnalUnifFit:backrq2
	WAVE backqq2=root:Packages:Irena_AnalUnifFit:backqq2
	NVAR SelectedLevel=root:Packages:Irena_AnalUnifFit:SelectedLevel//level number selected for analysis generic to other models.
	SVAR SlectedBranchedLevels = root:Packages:Irena_AnalUnifFit:SlectedBranchedLevels
	NVAR UseUnifiedInv=root:Packages:Irena_AnalUnifFit:UseUnifiedInv
	NVAR UseCsrInv=root:Packages:Irena_AnalUnifFit:UseCsrInv

	NVAR OriginalLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	SVAR rwavename=root:Packages:Irena_UnifFit:IntensityWaveName
	SVAR qwavename=root:Packages:Irena_UnifFit:QWavename
	SVAR swavename=root:Packages:Irena_UnifFit:IntensityWaveName
	SVAR datafoldername=root:Packages:Irena_UnifFit:DataFolderName

	variable plotextensions=1
	variable invariant = inv*1e-24

	setdatafolder datafoldername
	rwavename = ReplaceString("'", rwavename, "")
	qwavename = ReplaceString("'", qwavename, "")
	swavename = ReplaceString("'", swavename, "")
	wave rwave =$rwavename
	wave qwave=$qwavename
	wave swave=$swavename
	setdatafolder root:Packages:Irena_AnalUnifFit:		//do not contaminate users data folder, just store it in Unified Fit folder... 

	//variable InitialselectedLevel=SelectedLevel//used to reset the panel at the end.  Just in case there is some interference.
	NVAR SelectedQlevel=root:Packages:Irena_AnalUnifFit:SelectedQlevel//Unique to two phase model
	NVAR SelectedBLevel=root:Packages:Irena_AnalUnifFit:SelectedBLevel//Unique to two phase model
	variable LocSelBLevel, LocSelQLevel
	if(stringmatch(SlectedBranchedLevels,"---")||numtype(SelectedQlevel)!=0||numtype(SelectedBLevel)!=0)
		print "Levels not selected correctly. Check controls"
		abort
	elseif(stringmatch(SlectedBranchedLevels,"All"))	//we use values from level 1 but summ all invariants...
		LocSelQLevel=OriginalLevels
		LocSelBLevel=1
	elseif(stringmatch(SlectedBranchedLevels,"Range"))	//we use values from level 1 but summ all invariants...
		LocSelQLevel=SelectedQlevel
		LocSelBLevel=SelectedBLevel
	else
		LocSelQLevel=SelectedLevel
		LocSelBLevel=SelectedLevel
	endif
	//OK, now we have selected range of levels approprioately for controls... 
	NVAR B=$("root:Packages:irena_UnifFit:Level"+num2istr(LocSelBLevel)+"B")
	NVAR PorodSlope=$("root:Packages:irena_UnifFit:Level"+num2istr(LocSelBLevel)+"P")
	NVAR RgselectedQLevel=$("root:Packages:irena_UnifFit:Level"+num2istr(LocSelQLevel)+"Rg")//Rg is only used for caculating the invariant.
	NVAR G=$("root:Packages:irena_UnifFit:Level"+num2istr(LocSelQLevel)+"G")
	SVAR Model=root:Packages:Irena_AnalUnifFit:Model

	TwoPhaseInvariantBetweenCursors=invariant*1e24						//must be used somewhere else
	variable Sv=(1e4*pi*B/invariant)*majorityphi*(1-majorityphi)
	variable majchord=4*majorityphi/Sv
	variable minchord=4* (1-majorityphi)/Sv
	//string outtext="Qv = "+num2str(invariant)+" cm^-4\rB = "+num2str(B)+ " cm-1Å-4"
	string outtext="Qv = "+num2str(invariant)+" cm^-1 Å^-3\rB = "+num2str(B)+ " cm-1Å-4"
	outtext=outtext+"\rpiB/Q = "+num2str(1e4*pi*B/invariant)+" m2/cm3\rSv = "+num2str(Sv)+" m2/cm3\rSm = "+num2str(Sv/dens)+" m2/g\rlmin = "+num2str(minchord*1e4)+" Å\rlmaj = "+num2str(majchord*1e4)+" Å"		
	dowindow/R/k InvariantGraph
	//dowindow/R/k DummyGraph
			display/K=2  rq2 vs qwave as "q2 I(q) vs q"
			dowindow/c InvariantGraph
			IF(plotextensions==1)//dws 2017 b
				appendtograph frontrq2 vs frontqq2
				appendtograph backrq2 vs backqq2
				ModifyGraph rgb(frontrq2)=(8738,8738,8738)
				ModifyGraph rgb(backrq2)=(8738,8738,8738)
				Cursor /A=1  A , rq2 , 0
				Tag/C/N=text1/F=0/A=LC frontrq2,100,"Level Used = "+Num2str(SelectedQlevel)
			endif	

		
		Button KillInvWindow,pos={2,1},size={70,20},proc=IR2U_ButtonProc,title="Kill Window"	
		ModifyGraph grid=2,tick=2,mirror=1,fStyle=1,fSize=15,font="Times"
		//SetAxis bottom 1e-5,maxqback
		if(!UseCsrInv)//&&!UseUnifiedInv)
			SetAxis/A
		endif
		//print "lmin = "+num2str(minchord*1e4)+" Å"
		ModifyGraph log=1
		Label left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"I(q)·(q \\S2\\M)"
		Label bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"q (A\\S-1\\M)"
		textbox/C/N=text1df/F=0/X=46.00/Y=30.00  outtext
		HideTools/A
	//SelectedLevel=InitialselectedLevel
	setDataFolder OldDf
	
	If ((numtype(invariant)==2))
		doAlert 0, "Pick a level";abort
	endif
End

//***********************************************************
//***********************************************************
//***********************************************************


//***********************************************************
//***********************************************************
//***********************************************************

Function  IR2U_SaveLogNormalDistData()

//	DoAlert 0, "IR2U_SaveLogNormalDistData is not yet finished"
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_AnalUnifFit
	Wave RadiusWave=root:Packages:Irena_AnalUnifFit:RadiusWave
	Wave SizeVolDistribution=root:Packages:Irena_AnalUnifFit:SizeVolDistribution
	Wave SizeNumDistribution=root:Packages:Irena_AnalUnifFit:SizeNumDistribution
	
	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults

	if(UseStoredResults)
		SVAR DataFolderName = root:Packages:Irena_AnalUnifFit:DataFolderName
		SVAR IntensityWaveName = root:Packages:Irena_AnalUnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_AnalUnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_AnalUnifFit:ErrorWaveName	
	else
		SVAR DataFolderName = root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntensityWaveName = root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_UnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_UnifFit:ErrorWaveName	
	endif

	SVAR ListOfVariables = root:Packages:Irena_AnalUnifFit:ListOfVariables
	SVAR ListOfStrings = root:Packages:Irena_AnalUnifFit:ListOfStrings
	string OldWvNote=note($(DataFolderName+IntensityWaveName))
	String NewNote=""
	string ListOfSVars=ListOfStrings
	ListOfSVars=GrepList(ListOfSVars,"Porod_*" ,1, ";")
	ListOfSVars=GrepList(ListOfSVars,"BrFract_*" ,1, ";")
	ListOfSVars=GrepList(ListOfSVars,"Invariant*" ,1, ";")	
	variable i
	For(i=0;i<ItemsInList(ListOfSVars);i+=1)
		SVAR tempstr=$(stringFromList(i,ListOfSVars))
		NewNote+=stringFromList(i,ListOfSVars)+"="+tempstr+";"
	endfor
	ListOfSVars=ListOfVariables
	ListOfSVars=GrepList(ListOfSVars,"Porod_*" ,1, ";")
	ListOfSVars=GrepList(ListOfSVars,"BrFract_*" ,1, ";")
	ListOfSVars=GrepList(ListOfSVars,"Invariant*" ,1, ";")	
	For(i=0;i<ItemsInList(ListOfSVars);i+=1)
		NVAR tempvar=$(stringFromList(i,ListOfSVars))
		NewNote+=stringFromList(i,ListOfSVars)+"="+num2str(tempvar)+";"
	endfor
	string FinalNote=OldWvNote+NewNote


	string UsersComment
	UsersComment="Result from Unified Size Distribution Eval. "+date()+"  "+time()

	Prompt UsersComment, "Modify comment to be saved with these results"
	DoPrompt "Need input for saving data", UsersComment
	if (V_Flag)
		abort
	endif

	setDataFolder $(DataFolderName)
	string tempname 
	variable ii=0
	For(ii=0;ii<1000;ii+=1)
		tempname="UnifSizeDistRadius_"+num2str(ii)
		if (checkname(tempname,1)==0)
			break
		endif
	endfor

	Wave RadiusWave=root:Packages:Irena_AnalUnifFit:RadiusWave
	Wave SizeVolDistribution=root:Packages:Irena_AnalUnifFit:SizeVolDistribution
	Wave SizeNumDistribution=root:Packages:Irena_AnalUnifFit:SizeNumDistribution


	Duplicate RadiusWave, $("UnifSizeDistRadius_"+num2str(ii))
	Duplicate SizeVolDistribution, $("UnifSizeDistVolumeDist_"+num2str(ii))
	Duplicate SizeNumDistribution, $("UnifSizeDistNumberDist_"+num2str(ii))
	
	Wave tempWv=$("UnifSizeDistRadius_"+num2str(ii))
	note tempWv, FinalNote
	Wave tempWv=$("UnifSizeDistVolumeDist_"+num2str(ii))
	note tempWv, FinalNote
	Wave tempWv=$("UnifSizeDistNumberDist_"+num2str(ii))
	note tempWv, FinalNote

	print "\r******\rSaved Unified size analysis data to : "+DataFolderName +" \r  waves : \r"+"UnifSizeDistRadius_"+num2str(ii) +"\r"+"UnifSizeDistVolumeDist_"+num2str(ii)+"\r"+"UnifSizeDistNumberDist_"+num2str(ii)
	setDataFolder oldDF

end

//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_SaveResultsperUsrReq(where)
	string where

	
	SVAR Model=root:Packages:Irena_AnalUnifFit:Model
	if(stringmatch(Model,"Invariant"))	
		IR2U_SaveInvariantResults(where)
	elseif(stringmatch(Model,"Size Distribution"))	
		IR2U_SaveSizeDistResults(where)
	elseif(stringmatch(Model,"Porods Law"))	
		IR2U_SavePorodsLawResults(where)
	elseif(stringmatch(Model,"Branched mass fractal"))	
		IR2U_SaveMassFractalResults(where)
	elseif(stringmatch(Model,"TwoPhaseSys*"))	
		IR2U_SaveTwoPhaseSysResults(where)
	ENDIF


end


//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_SavePorodsLawResults(where)
	string where

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel

	NVAR Porod_Constant = root:Packages:Irena_AnalUnifFit:Porod_Constant
	NVAR Porod_SpecificSfcArea = root:Packages:Irena_AnalUnifFit:Porod_SpecificSfcArea
	NVAR Porod_Contrast = root:Packages:Irena_AnalUnifFit:Porod_Contrast
	SVAR Porod_ErrorMessage=root:Packages:Irena_AnalUnifFit:Porod_ErrorMessage
	NVAR Porod_PowerLawSlope=root:Packages:Irena_AnalUnifFit:Porod_PowerLawSlope

	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults
	
	//avoid printinga garbage, bail out if no sensible data selected...
	if(SelectedLevel<1)
		abort
	endif

	string DataFName="", DataIName="",DataQname="",DataEName="", UserName="", AnalysisComentsAndTime=""
	if(UseCurrentResults)
		SVAR DataFolderName = root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntensityWaveName = root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_UnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_UnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		Wave IntWv=root:Packages:Irena_UnifFit:OriginalIntensity
		UserName=stringBykey("UserSampleName",note(IntWv),"=",";")
		AnalysisComentsAndTime = "Using data in Unified fit tool, analyzed on "+date()+" at "+time()
	else
	 	SVAR DataFolderName= root:Packages:Irena_AnalUnifFit:DataFolderName
	 	SVAR IntensityWaveName = root:Packages:Irena_AnalUnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_AnalUnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_AnalUnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		UserName=IR2U_ReturnNoteStrValue("UserSampleName")
		AnalysisComentsAndTime ="Analyzed using "+IR2U_ReturnNoteStrValue("UsersComment")
	endif
	
	if(stringMatch(where,"History"))
		Print " "
		Print "******************   Results for Porods law analysis from Unified fit ***************************"
		Print "     User Data Name : "+UserName
		Print "     Date/time : "+AnalysisComentsAndTime
		Print "     Folder name : "+DataFName
		Print "     Intensity name : "+DataIName
		Print "     Q vector name : "+DataQname
		Print "     Error name : "+DataEName
		Print "  "
		Print "     Selected level : "+num2str(SelectedLevel)
		if(strLen(Porod_ErrorMessage)>3)
			Print "     Error: "+Porod_ErrorMessage
		else
			Print "     Porods Constant [cm^-1 A^-4]: "+num2str(Porod_Constant)
			Print "     Contrast [10^20 cm^-4]: "+num2str(Porod_Contrast)
			Print "     Power law slope (~ 4) : " + num2str(Porod_PowerLawSlope)
			Print "     Specific surface area [cm^2/cm^3] : " + num2str(Porod_SpecificSfcArea)
		endif
		print "******************************************************************************************************"
		print " "


	elseif(stringMatch(where,"Logbook"))
		IR1_CreateLoggbook()
		IR1_PullUpLoggbook()
		IR1L_AppendAnyText( " ")
		IR1L_AppendAnyText( "******************   Results for Porods law analysis from Unified fit ***************************")
		IR1L_AppendAnyText("     User Data Name : "+UserName)
		IR1L_AppendAnyText("     Date/time : "+AnalysisComentsAndTime)
		IR1L_AppendAnyText("     Folder name : "+DataFName)
		IR1L_AppendAnyText("     Intensity name : "+DataIName)
		IR1L_AppendAnyText( "     Q vector name : "+DataQname)
		IR1L_AppendAnyText("     Error name : "+DataEName)
		IR1L_AppendAnyText("  ")
		IR1L_AppendAnyText( "     Selected level : \t"+num2str(SelectedLevel))
		if(strLen(Porod_ErrorMessage)>3)
			IR1L_AppendAnyText( "     Error: "+Porod_ErrorMessage)
		else
			IR1L_AppendAnyText( "     Porods Constant [cm^-1 A^-4]: \t"+num2str(Porod_Constant))
			IR1L_AppendAnyText( "     Contrast [10^20 cm^-4]: \t"+num2str(Porod_Contrast))
			IR1L_AppendAnyText( "     Power law slope (~ 4) : \t" + num2str(Porod_PowerLawSlope))
			IR1L_AppendAnyText( "     Specific surface area [cm^2/cm^3] : \t" + num2str(Porod_SpecificSfcArea))
		endif
		IR1L_AppendAnyText("******************************************************************************************************")
		IR1L_AppendAnyText("  ")
	elseif(stringmatch(where,"Graph"))
		string GraphName=""
		if(UseCurrentResults)
			GraphName="IR1_LogLogPlotU"
		else
			GraphName=WinName(0,1)
		endif
		string NewTextBoxStr="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")
		NewTextBoxStr+= "Porods law analysis using Unified fit results\r"
		if(strlen(UserName)>0)
			NewTextBoxStr+= "User Data Name : "+UserName+" \r"
		else
			NewTextBoxStr+= "Folder name : "+DataFName+" \r"
		endif
		NewTextBoxStr+= "Selected level : "+num2str(SelectedLevel)+" \r"

		if(strLen(Porod_ErrorMessage)>3)
			NewTextBoxStr+=  "     Error: "+Porod_ErrorMessage+" \r"
		else
			NewTextBoxStr+=  "     Porods Constant [cm^-1 A^-4]: "+num2str(Porod_Constant)+" \r"
			NewTextBoxStr+=  "     Contrast [10^20 cm^-4]: "+num2str(Porod_Contrast)+" \r"
			NewTextBoxStr+=  "     Power law slope (~ 4) : " + num2str(Porod_PowerLawSlope)+" \r"
			NewTextBoxStr+=  "     Specific surface area [cm^2/cm^3] : " + num2str(Porod_SpecificSfcArea)+" \r"
		endif
		string AnotList=AnnotationList(GraphName)
		variable i
		For(i=0;i<100;i+=1)
			if(!stringMatch(AnotList,"*UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i)+"*"))
				break
			endif
		endfor
		TextBox/C/W=$(GraphName)/N=$("UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i))/F=0/A=MC NewTextBoxStr
		
	endif
	
end

//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_SaveSizeDistResults(where)
	string where

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel

	NVAR SizeDist_G1=root:Packages:Irena_AnalUnifFit:SizeDist_G1
	NVAR SizeDist_Rg1=root:Packages:Irena_AnalUnifFit:SizeDist_Rg1
	NVAR SizeDist_B1=root:Packages:Irena_AnalUnifFit:SizeDist_B1
	NVAR SizeDist_P1=root:Packages:Irena_AnalUnifFit:SizeDist_P1
	SVAR SizeDist_ErrorMessage=root:Packages:Irena_AnalUnifFit:SizeDist_ErrorMessage
	SVAR SizeDist_Reference=root:Packages:Irena_AnalUnifFit:SizeDist_Reference
	NVAR SizeDist_sigmag=root:Packages:Irena_AnalUnifFit:SizeDist_sigmag
	NVAR SizeDist_GeomMean=root:Packages:Irena_AnalUnifFit:SizeDist_GeomMean
	NVAR SizeDist_PDI=root:Packages:Irena_AnalUnifFit:SizeDist_PDI
	NVAR SizeDist_SuterMeanDiadp=root:Packages:Irena_AnalUnifFit:SizeDist_SuterMeanDiadp

	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults
	
	//avoid printinga garbage, bail out if no sensible data selected...
	if(SelectedLevel<1)
		abort
	endif

	string DataFName="", DataIName="",DataQname="",DataEName="", UserName="", AnalysisComentsAndTime=""
	if(UseCurrentResults)
		SVAR DataFolderName = root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntensityWaveName = root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_UnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_UnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		Wave IntWv=root:Packages:Irena_UnifFit:OriginalIntensity
		UserName=stringBykey("UserSampleName",note(IntWv),"=",";")
		AnalysisComentsAndTime = "Using data in Unified fit tool, analyzed on "+date()+" at "+time()
	else
	 	SVAR DataFolderName= root:Packages:Irena_AnalUnifFit:DataFolderName
	 	SVAR IntensityWaveName = root:Packages:Irena_AnalUnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_AnalUnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_AnalUnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		UserName=IR2U_ReturnNoteStrValue("UserSampleName")
		AnalysisComentsAndTime ="Analyzed using "+IR2U_ReturnNoteStrValue("UsersComment")
	endif
	
	if(stringMatch(where,"History"))
		Print " "
		Print "******************   Results for Size dsitribution analysis from Unified fit ***************************"
		Print "     User Data Name : "+UserName
		Print "     Date/time : "+AnalysisComentsAndTime
		Print "     Folder name : "+DataFName
		Print "     Intensity name : "+DataIName
		Print "     Q vector name : "+DataQname
		Print "     Error name : "+DataEName
		Print "  "
		Print "     Selected level : "+num2str(SelectedLevel)
		if(strLen(SizeDist_ErrorMessage)>3)
			Print "     Error: "+SizeDist_ErrorMessage
		else
			Print "     G/Rg/B/P    "+num2str(SizeDist_G1)+"\t"+num2str(SizeDist_Rg1)+"\t"+num2str(SizeDist_B1)+"\t"+num2str(SizeDist_P1)
			Print "     Geom. sigma : "+num2str(SizeDist_sigmag)
			Print "     Geom mean : "+num2str(SizeDist_GeomMean)
			Print "     Polydispersity index : " + num2str(SizeDist_PDI)
			Print "     Sauter mean diameter : " + num2str(SizeDist_SuterMeanDiadp)
			Print "     Reference : " + SizeDist_Reference		
		endif
		print "******************************************************************************************************"
		print " "


	elseif(stringMatch(where,"Logbook"))
		IR1_CreateLoggbook()
		IR1_PullUpLoggbook()
		IR1L_AppendAnyText( " ")
		IR1L_AppendAnyText( "******************   Results for Size dsitribution analysis from Unified fit ***************************")
		IR1L_AppendAnyText("     User Data Name : "+UserName)
		IR1L_AppendAnyText("     Date/time : "+AnalysisComentsAndTime)
		IR1L_AppendAnyText("     Folder name : "+DataFName)
		IR1L_AppendAnyText("     Intensity name : "+DataIName)
		IR1L_AppendAnyText( "     Q vector name : "+DataQname)
		IR1L_AppendAnyText("     Error name : "+DataEName)
		IR1L_AppendAnyText("  ")
		IR1L_AppendAnyText( "     Selected level : "+num2str(SelectedLevel))
		if(strLen(SizeDist_ErrorMessage)>3)
			IR1L_AppendAnyText( "     Error: "+SizeDist_ErrorMessage)
		else
			IR1L_AppendAnyText( "     G/Rg/B/P    "+num2str(SizeDist_G1)+"\t"+num2str(SizeDist_Rg1)+"\t"+num2str(SizeDist_B1)+"\t"+num2str(SizeDist_P1))
			IR1L_AppendAnyText( "     Geom. sigma : "+num2str(SizeDist_sigmag))
			IR1L_AppendAnyText( "     Geom mean : "+num2str(SizeDist_GeomMean))
			IR1L_AppendAnyText( "     Polydispersity index : " + num2str(SizeDist_PDI))
			IR1L_AppendAnyText( "     Sauter mean diameter : " + num2str(SizeDist_SuterMeanDiadp))
			IR1L_AppendAnyText( "     Reference : " + SizeDist_Reference		)
		endif
		IR1L_AppendAnyText("******************************************************************************************************")
		IR1L_AppendAnyText("  ")
	elseif(stringmatch(where,"Graph"))
		string GraphName=""
		if(UseCurrentResults)
			GraphName="IR1_LogLogPlotU"
		else
			GraphName=WinName(0,1)
		endif
		string NewTextBoxStr="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")
		NewTextBoxStr+= "Size distribution analysis using Unified fit results\r"
		if(strlen(UserName)>0)
			NewTextBoxStr+= "User Data Name : "+UserName+" \r"
		else
			NewTextBoxStr+= "Folder name : "+DataFName+" \r"
		endif
		NewTextBoxStr+= "Selected level : "+num2str(SelectedLevel)+" \r"
		if(strLen(SizeDist_ErrorMessage)>3)
			NewTextBoxStr+= "Error: "+SizeDist_ErrorMessage+" \r"
		else
			NewTextBoxStr+= "G/Rg/B/P    "+num2str(SizeDist_G1)+"\t"+num2str(SizeDist_Rg1)+"\t"+num2str(SizeDist_B1)+"\t"+num2str(SizeDist_P1)+" \r"
			NewTextBoxStr+= "Geom. sigma : "+num2str(SizeDist_sigmag)+" \r"
			NewTextBoxStr+= "Geom mean : "+num2str(SizeDist_GeomMean)+" \r"
			NewTextBoxStr+= "Polydispersity index : " + num2str(SizeDist_PDI)+" \r"
			NewTextBoxStr+= "Sauter mean diameter : " + num2str(SizeDist_SuterMeanDiadp)+" \r"
			NewTextBoxStr+= "Reference : " + SizeDist_Reference
		endif

		string AnotList=AnnotationList(GraphName)
		variable i
		For(i=0;i<100;i+=1)
			if(!stringMatch(AnotList,"*UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i)+"*"))
				break
			endif
		endfor
		TextBox/C/W=$(GraphName)/N=$("UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i))/F=0/A=MC NewTextBoxStr
		
	endif
	
end
//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_SaveInvariantResults(where)
	string where

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel
	NVAR InvariantValue = root:Packages:Irena_AnalUnifFit:InvariantValue
	NVAR InvariantUserContrast = root:Packages:Irena_AnalUnifFit:InvariantUserContrast
	NVAR InvariantPhaseVolume = root:Packages:Irena_AnalUnifFit:InvariantPhaseVolume

	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults
	
	//avoid printinga garbage, bail out if no sensible data selected...
	if(SelectedLevel<1)
		abort
	endif

	string DataFName="", DataIName="",DataQname="",DataEName="", UserName="", AnalysisComentsAndTime=""
	if(UseCurrentResults)
		SVAR DataFolderName = root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntensityWaveName = root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_UnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_UnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		Wave IntWv=root:Packages:Irena_UnifFit:OriginalIntensity
		UserName=stringBykey("UserSampleName",note(IntWv),"=",";")
		AnalysisComentsAndTime = "Using data in Unified fit tool, analyzed on "+date()+" at "+time()
	else
	 	SVAR DataFolderName= root:Packages:Irena_AnalUnifFit:DataFolderName
	 	SVAR IntensityWaveName = root:Packages:Irena_AnalUnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_AnalUnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_AnalUnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		UserName=IR2U_ReturnNoteStrValue("UserSampleName")
		AnalysisComentsAndTime ="Analyzed using "+IR2U_ReturnNoteStrValue("UsersComment")
	endif
	
	if(stringMatch(where,"History"))
		Print " "
		Print "******************   Results for analysis of Invariant from Unified fit ***************************"
		Print "     User Data Name : "+UserName
		Print "     Date/time : "+AnalysisComentsAndTime
		Print "     Folder name : "+DataFName
		Print "     Intensity name : "+DataIName
		Print "     Q vector name : "+DataQname
		Print "     Error name : "+DataEName
		Print "  "
		Print "     Selected level : "+num2str(SelectedLevel)
		Print "     Phase Contrast [10^20 cm^-4] : "+num2str(InvariantUserContrast)
		Print "     Invariant [cm^-4] : "+num2str(InvariantValue)
		Print "     Phase volume [fraction] : " + num2str(InvariantPhaseVolume)
		print "******************************************************************************************************"
		print " "
	elseif(stringMatch(where,"Logbook"))
		IR1_CreateLoggbook()
		IR1_PullUpLoggbook()
		IR1L_AppendAnyText( " ")
		IR1L_AppendAnyText( "******************   Results for analysis of Invariant from Unified fit ***************************")
		IR1L_AppendAnyText("     User Data Name : "+UserName)
		IR1L_AppendAnyText("     Date/time : "+AnalysisComentsAndTime)
		IR1L_AppendAnyText("     Folder name : "+DataFName)
		IR1L_AppendAnyText("     Intensity name : "+DataIName)
		IR1L_AppendAnyText( "     Q vector name : "+DataQname)
		IR1L_AppendAnyText("     Error name : "+DataEName)
		IR1L_AppendAnyText("  ")
		IR1L_AppendAnyText( "     Selected level : "+num2str(SelectedLevel))
		IR1L_AppendAnyText("     Phase Contrast [10^20 cm^-4] : "+num2str(InvariantUserContrast))
		IR1L_AppendAnyText("     Invariant [cm^-4] : "+num2str(InvariantValue))
		IR1L_AppendAnyText("     Phase volume [fraction] : " + num2str(InvariantPhaseVolume))
		IR1L_AppendAnyText("******************************************************************************************************")
		IR1L_AppendAnyText("  ")
	elseif(stringmatch(where,"Graph"))
		string GraphName=""
		if(UseCurrentResults)
			GraphName="IR1_LogLogPlotU"
		else
			GraphName=WinName(0,1)
		endif
		string NewTextBoxStr="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")
		NewTextBoxStr+= "Invariant analysis using Unified fit results\r"
		if(strlen(UserName)>0)
			NewTextBoxStr+= "User Data Name : "+UserName+" \r"
		else
			NewTextBoxStr+= "Folder name : "+DataFName+" \r"
		endif
		NewTextBoxStr+= "Selected level : "+num2str(SelectedLevel)+" \r"
		NewTextBoxStr+= "Phase Contrast [10^20 cm^-4] : "+num2str(InvariantUserContrast)+" \r"
		NewTextBoxStr+= "Invariant [cm^-4] : "+num2str(InvariantValue)+" \r"
		NewTextBoxStr+= "Phase volume [fraction] : " + num2str(InvariantPhaseVolume)+" \r"
		string AnotList=AnnotationList(GraphName)
		variable i
		For(i=0;i<100;i+=1)
			if(!stringMatch(AnotList,"*UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i)+"*"))
				break
			endif
		endfor
		TextBox/C/W=$(GraphName)/N=$("UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i))/F=0/A=MC NewTextBoxStr
		
	endif
	
end
//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_SaveMassFractalResults(where)
	string where

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel
	NVAR InvariantValue = root:Packages:Irena_AnalUnifFit:InvariantValue

	NVAR BrFract_G2=root:Packages:Irena_AnalUnifFit:BrFract_G2
	NVAR BrFract_Rg2=root:Packages:Irena_AnalUnifFit:BrFract_Rg2
	NVAR BrFract_B2=root:Packages:Irena_AnalUnifFit:BrFract_B2
	NVAR BrFract_P2=root:Packages:Irena_AnalUnifFit:BrFract_P2
	NVAR BrFract_G1=root:Packages:Irena_AnalUnifFit:BrFract_G1
	NVAR BrFract_Rg1=root:Packages:Irena_AnalUnifFit:BrFract_Rg1
	NVAR BrFract_B1=root:Packages:Irena_AnalUnifFit:BrFract_B1
	NVAR BrFract_P1=root:Packages:Irena_AnalUnifFit:BrFract_P1
	SVAR BrFract_ErrorMessage=root:Packages:Irena_AnalUnifFit:BrFract_ErrorMessage
	SVAR BrFract_Reference1 = root:Packages:Irena_AnalUnifFit:BrFract_Reference1
	SVAR BrFract_Reference2 = root:Packages:Irena_AnalUnifFit:BrFract_Reference2
	NVAR BrFract_dmin=root:Packages:Irena_AnalUnifFit:BrFract_dmin
	NVAR BrFract_c=root:Packages:Irena_AnalUnifFit:BrFract_c
	NVAR BrFract_z=root:Packages:Irena_AnalUnifFit:BrFract_z
	NVAR BrFract_fBr=root:Packages:Irena_AnalUnifFit:BrFract_fBr
	NVAR BrFract_fM=root:Packages:Irena_AnalUnifFit:BrFract_fM


	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults
	
	//avoid printinga garbage, bail out if no sensible data selected...
	if(SelectedLevel<2)
		abort
	endif

	string DataFName="", DataIName="",DataQname="",DataEName="", UserName="", AnalysisComentsAndTime=""
	if(UseCurrentResults)
		SVAR DataFolderName = root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntensityWaveName = root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_UnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_UnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		Wave IntWv=root:Packages:Irena_UnifFit:OriginalIntensity
		UserName=stringBykey("UserSampleName",note(IntWv),"=",";")
		AnalysisComentsAndTime = "Using data in Unified fit tool, analyzed on "+date()+" at "+time()
	else
	 	SVAR DataFolderName= root:Packages:Irena_AnalUnifFit:DataFolderName
	 	SVAR IntensityWaveName = root:Packages:Irena_AnalUnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_AnalUnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_AnalUnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		UserName=IR2U_ReturnNoteStrValue("UserSampleName")
		AnalysisComentsAndTime ="Analyzed using "+IR2U_ReturnNoteStrValue("UsersComment")
	endif
	
	if(stringMatch(where,"History"))
		Print " "
		Print "***********   Results for analysis of Branched Mass Fractal from Unified fit ****************"
		Print "     User Data Name : "+UserName
		Print "     Date/time : "+AnalysisComentsAndTime
		Print "     Folder name : "+DataFName
		Print "     Intensity name : "+DataIName
		Print "     Q vector name : "+DataQname
		Print "     Error name : "+DataEName
		Print "  "
		Print "     Selected levels : "+num2str(SelectedLevel)+"/"+num2str(SelectedLevel-1)
		Print "     Level 2 : G/Rg/B/P    "+num2str(BrFract_G2)+"\t"+num2str(BrFract_Rg2)+"\t"+num2str(BrFract_B2)+"\t"+num2str(BrFract_P2)
		Print "     Level 1 : G/Rg/B/P    "+num2str(BrFract_G1)+"\t"+num2str(BrFract_Rg1)+"\t"+num2str(BrFract_B1)+"\t"+num2str(BrFract_P1)
		if(strlen(BrFract_ErrorMessage)>3)
			Print "     Error message : "+BrFract_ErrorMessage
		else
			Print "     Results : " 
			Print "     dmin = \t" + num2str(BrFract_dmin)
			Print "     c      = \t" + num2str(BrFract_c)
			Print "     z      = \t" + num2str(BrFract_z)
			Print "     fBr    = \t" + num2str(BrFract_fBr)
			Print "     fM     = \t" + num2str(BrFract_fM)
			Print "     References : "+BrFract_Reference1+"\r"+BrFract_Reference2
		
		endif
		print "******************************************************************************************************"
		print " "


	elseif(stringMatch(where,"Logbook"))
		IR1_CreateLoggbook()
		IR1_PullUpLoggbook()
		IR1L_AppendAnyText( " ")
		IR1L_AppendAnyText( "***********   Results for analysis of Branched Mass Fractal from Unified fit ****************")
		IR1L_AppendAnyText("     User Data Name : "+UserName)
		IR1L_AppendAnyText("     Date/time : "+AnalysisComentsAndTime)
		IR1L_AppendAnyText("     Folder name : "+DataFName)
		IR1L_AppendAnyText("     Intensity name : "+DataIName)
		IR1L_AppendAnyText( "     Q vector name : "+DataQname)
		IR1L_AppendAnyText("     Error name : "+DataEName)
		IR1L_AppendAnyText("  ")
		IR1L_AppendAnyText( "     Selected levels : "+num2str(SelectedLevel)+"/"+num2str(SelectedLevel-1))
		IR1L_AppendAnyText( "     Level 2 : G/Rg/B/P    "+num2str(BrFract_G2)+"\t"+num2str(BrFract_Rg2)+"\t"+num2str(BrFract_B2)+"\t"+num2str(BrFract_P2))
		IR1L_AppendAnyText( "     Level 1 : G/Rg/B/P    "+num2str(BrFract_G1)+"\t"+num2str(BrFract_Rg1)+"\t"+num2str(BrFract_B1)+"\t"+num2str(BrFract_P1))
		if(strlen(BrFract_ErrorMessage)>3)
			IR1L_AppendAnyText( "     Error message : "+BrFract_ErrorMessage)
		else
			IR1L_AppendAnyText( "     Results : " )
			IR1L_AppendAnyText( "     dmin = \t" + num2str(BrFract_dmin))
			IR1L_AppendAnyText( "     c      = \t" + num2str(BrFract_c))
			IR1L_AppendAnyText( "     z      = \t" + num2str(BrFract_z))
			IR1L_AppendAnyText( "     fBr    = \t" + num2str(BrFract_fBr))
			IR1L_AppendAnyText( "     fM     = \t" + num2str(BrFract_fM))
			IR1L_AppendAnyText( "     References : "+BrFract_Reference1+"\r"+BrFract_Reference2)
		
		endif
		IR1L_AppendAnyText("******************************************************************************************************")
		IR1L_AppendAnyText("  ")
	elseif(stringmatch(where,"Graph"))
		string GraphName=""
		if(UseCurrentResults)
			GraphName="IR1_LogLogPlotU"
		else
			GraphName=WinName(0,1)
		endif
		string NewTextBoxStr="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")
		NewTextBoxStr+= "Branched Mass Fractal analysis using Unified fit results\r"
		if(strlen(UserName)>0)
			NewTextBoxStr+= "User Data Name : "+UserName+" \r"
		else
			NewTextBoxStr+= "Folder name : "+DataFName+" \r"
		endif
		NewTextBoxStr+= "Selected levels : "+num2str(SelectedLevel)+"/"+num2str(SelectedLevel-1)+" \r"
		NewTextBoxStr+= "Level 2 : G/Rg/B/P    "+num2str(BrFract_G2)+"\t"+num2str(BrFract_Rg2)+"\t"+num2str(BrFract_B2)+"\t"+num2str(BrFract_P2)+" \r"
		NewTextBoxStr+= "Level 1 : G/Rg/B/P    "+num2str(BrFract_G1)+"\t"+num2str(BrFract_Rg1)+"\t"+num2str(BrFract_B1)+"\t"+num2str(BrFract_P1)+" \r"
		if(strlen(BrFract_ErrorMessage)>3)
			NewTextBoxStr+= "     Error message : "+BrFract_ErrorMessage
		else
			NewTextBoxStr+= "     Results : " +" \r"
			NewTextBoxStr+= "     dmin = \t" + num2str(BrFract_dmin)+" \r"
			NewTextBoxStr+= "     c      = \t" + num2str(BrFract_c)+" \r"
			NewTextBoxStr+= "     z      = \t" + num2str(BrFract_z)+" \r"
			NewTextBoxStr+= "     fBr    = \t" + num2str(BrFract_fBr)+" \r"
			NewTextBoxStr+= "     fM     = \t" + num2str(BrFract_fM)+" \r"
			NewTextBoxStr+= "     References : "+BrFract_Reference1+"\r"+BrFract_Reference2	
		endif

		string AnotList=AnnotationList(GraphName)
		variable i
		For(i=0;i<100;i+=1)
			if(!stringMatch(AnotList,"*UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i)+"*"))
				break
			endif
		endfor
		TextBox/C/W=$(GraphName)/N=$("UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i))/F=0/A=MC NewTextBoxStr
		
	endif
	
end
//***********************************************************
//***********************************************************
//***********************************************************


Function IR2U_TwoPhaseModelCalc()

	DFref oldDf= GetDataFolderDFR()

	SetDataFolder root:Packages:Irena_AnalUnifFit
	
	SVAR DF=root:Packages:Irena_UnifFit:DataFolderName
	NVAR Contrast=root:Packages:Irena_AnalUnifFit:TwoPhaseMediaContrast		//Let's use the Scattering contrast calcualterif needed to ge this instead of this complciated mess...
	SVAR Model=root:Packages:Irena_AnalUnifFit:Model
	SVAR IntensityWaveName=root:Packages:Irena_UnifFit:IntensityWaveName
	NVAR OriginalLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	SVAR SlectedBranchedLevels = root:Packages:Irena_AnalUnifFit:SlectedBranchedLevels
	NVAR SelectedQlevel=root:Packages:Irena_AnalUnifFit:SelectedQlevel//DWS 2017
	NVAR SelectedBLevel=root:Packages:Irena_AnalUnifFit:SelectedBlevel
	NVAR DensityMinorityPhase=root:Packages:Irena_AnalUnifFit:DensityMinorityPhase //need user input here... 
	NVAR DensityMajorityPhase=root:Packages:Irena_AnalUnifFit:DensityMajorityPhase //need user input here... 
	NVAR SampleBulkDensity=root:Packages:Irena_AnalUnifFit:SampleBulkDensity //need user input here... 
	//print SampleBulkDensity
	NVAR SLDDensityMinorityPhase=root:Packages:Irena_AnalUnifFit:SLDDensityMinorityPhase //need user input here... 
	NVAR SLDDensityMajorityPhase=root:Packages:Irena_AnalUnifFit:SLDDensityMajorityPhase //need user input here... 
	NVAR MinorityPhasePhi=root:Packages:Irena_AnalUnifFit:MinorityPhasePhi //calculate here. 
	NVAR MajorityPhasePhi=root:Packages:Irena_AnalUnifFit:MajorityPhasePhi //calculate here. 
	NVAR PiBoverQ=root:Packages:Irena_AnalUnifFit:PiBoverQ //calculate here... 
	NVAR MinorityCordLength=root:Packages:Irena_AnalUnifFit:MinorityCordLength //calcualte here... 
	NVAR MajorityCordLength=root:Packages:Irena_AnalUnifFit:MajorityCordLength //calcualte here... 
	NVAR SurfacePerVolume=root:Packages:Irena_AnalUnifFit:SurfacePerVolume //calcualte here... 
	NVAR SurfacePerMass = root:Packages:Irena_AnalUnifFit:SurfacePerMass
	NVAR PartANalRHard=root:Packages:Irena_AnalUnifFit:PartANalRHard //calcualte here... 
	NVAR BforTwoPhMat=root:Packages:Irena_AnalUnifFit:BforTwoPhMat //calcualte here... 
	NVAR PartAnalVolumeOfParticle=root:Packages:Irena_AnalUnifFit:PartAnalVolumeOfParticle //calcualte here... 
	NVAR PartAnalRgFromVp=root:Packages:Irena_AnalUnifFit:PartAnalRgFromVp //calcualte here... 
	NVAR PartAnalParticleDensity=root:Packages:Irena_AnalUnifFit:PartAnalParticleDensity //calcualte here... 
	NVAR TwoPhaseInvariantbtnCursors= root:Packages:Irena_AnalUnifFit:TwoPhaseInvariantBetweenCursors//***DWS
	NVAR TwoPhaseInvariant=root:Packages:Irena_AnalUnifFit:TwoPhaseInvariant
	NVAR UseCsrInv=root:Packages:Irena_AnalUnifFit:UseCsrInv
	NVAR UseUnifiedInv=root:Packages:Irena_AnalUnifFit:UseUnifiedInv
	NVAR SelectedLevel=root:Packages:Irena_AnalUnifFit:SelectedLevel//level number selected for analysis.  can be NaN for "all"
	NVAR InvariantUsed= root:Packages:Irena_AnalUnifFit:InvariantUsed//***DWS
	variable level, UsesAll
	if(stringmatch(SlectedBranchedLevels,"---"))
		abort
	elseif(stringmatch(SlectedBranchedLevels,"All"))	//we use values from level 1 but summ all invariants...
		level=1
		UsesAll=1
	elseif(stringmatch(SlectedBranchedLevels,"Range"))	//we use values from range of levels...
		if(SelectedQlevel>0 && SelectedBLevel>0 && SelectedBLevel<=SelectedQlevel)
			level=SelectedBlevel
			UsesAll=0
		else
			Print "Incorrectly seelcted range of levels. Fix the range first."
			abort
		endif
	else
		level=str2num(SlectedBranchedLevels)
		if(numtype(level)!=0)
			abort //wrogn selection in the controls
		endif
		UsesAll=0
	endif
	variable Gloc, RgLoc,Buniloc,Ploc
	if(UseCurrentResults)
		NVAR Buni=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"B")//cm-1A-4
		NVAR G=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"G")// note this one depend on problem
		NVAR P=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"P")
		NVAR Rg=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Rg")//use to limit plot q range
		NVAR Qvunified=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Invariant")// already in cm-4, Jan changed his code	
		Gloc=G
		RgLoc=Rg
		Buniloc=Buni
		Ploc=P			
	else
		//look up from wave note...
		 Gloc= IR2U_ReturnNoteNumValue("Level"+num2str(level)+"G")
		 Rgloc= IR2U_ReturnNoteNumValue("Level"+num2str(level)+"Rg")
		 Buniloc = IR2U_ReturnNoteNumValue("Level"+num2str(level)+"B")
		 Ploc= IR2U_ReturnNoteNumValue("Level"+num2str(level)+"P")
		 Qvunified= IR2U_ReturnNoteNumValue("Level"+num2str(level)+"Invariant")
	endif
	
	variable Bloc=Buniloc*1e32//convert cm-1 A-4 to  cm-5 
//	variable Qv

//	If (UseCsrInv)//***DWS
//		IR2U_CalculateInvariantbutton(0)//***DWS
//		Qv=TwoPhaseInvariantbtnCursors//***DWS
//	elseif (UsesAll==1)		//use full invariant for all levels used in unified fit. Generates TempUnifiedIntensity wave used below
//			Qv=1e24*IR2U_InvariantForMultipleLevels(OriginalLevels)//units cm-1 A-3 changed to cm-4
//			TwoPhaseInvariantbtnCursors=Qv
//	else
//			Qv=Qvunified
//			Twophaseinvariant=Qv//cm-4
//	endif
	//print "invariant used = "+num2str(Qv)
//	InvariantUsed=Qv//in cm-1A-3
			
	variable deltaSLD
	deltaSLD = (SLDDensityMajorityPhase*DensityMajorityPhase - SLDDensityMinorityPhase*DensityMinorityPhase)*10^10
	Contrast = (deltaSLD)^2
	
	variable Qv	
	Variable densold, phi
	
	if(stringmatch(Model,"TwoPhaseSys1"))	
		if ((P<=3.95 ||P>=4.05))
			 setDataFolder OldDf
			Abort "This method can be applied ONLY for P = 4 for high-q level"
		endif
		IR2U_CalculateInvariantbutton()			//JIL removed plotting capabilities and moved to later in the code.
		Qv=TwoPhaseInvariantbtnCursors//DWS 2017  Code eliminated here. 
		InvariantUsed=Qv
		//method 1 analysis, not calibrated data, valid low-q data (relative invariant valid)
		MinorityPhasePhi =(SampleBulkDensity-DensityMajorityPhase)/(DensityMinorityPhase-DensityMajorityPhase)//Phi referes to minority phase phi(solid)
		MajorityPhasePhi  = 1-MinorityPhasePhi
		SurfacePerVolume=(1e-4*Pi*Bloc/Qv)*MajorityPhasePhi*MinorityPhasePhi   //m^2/cm^3 calculate from densities and Qp 
		SurfacePerMass = SurfacePerVolume/SamplebulkDensity
		MinorityCordLength = (4/SurfacePerVolume)*(MinorityPhasePhi)*10000
		MajorityCordLength = (4/SurfacePerVolume)*(1-MinorityPhasePhi)*10000
		PiBoverQ = SurfacePerVolume / (MajorityPhasePhi*MinorityPhasePhi)
		IR2U_PlotCalcInvariantFnct()				//create the plot
		//end of method 1 analysis...
	elseif(stringmatch(Model,"TwoPhaseSys2"))	
		if ((P<=3.95 ||P>=4.05))
			 setDataFolder OldDf
			Abort "This method can be applied ONLY for P = 4 for high-q level"
		endif
		//method 2 analysis, calibrated data, not valid  data (relative invariant invalid), need contrast to get anything... 
		MinorityPhasePhi =(SampleBulkDensity-DensityMajorityPhase)/(DensityMinorityPhase-DensityMajorityPhase)//Phi referes to minority phase phi(solid)
		MajorityPhasePhi  = 1-MinorityPhasePhi
		BforTwoPhMat = Bloc*1e-32
		SurfacePerVolume=(1e-4*Bloc/(2*pi*Contrast))   //m^2/cm^3 calculate from densities and Qp 
		SurfacePerMass = SurfacePerVolume/SamplebulkDensity
		MinorityCordLength = (4/SurfacePerVolume)*(MinorityPhasePhi)*10000
		MajorityCordLength = (4/SurfacePerVolume)*(1-MinorityPhasePhi)*10000
		//end of method 2
	elseif(stringmatch(Model,"TwoPhaseSys3"))	
		if ((P<=3.95 ||P>=4.05))
			 setDataFolder OldDf
			 Abort "This method can be applied ONLY for P = 4 for high-q level"
		endif
		IR2U_CalculateInvariantbutton()//DWS 2017 eliminated argument (makegraph).  Always want plot.
		Qv=TwoPhaseInvariantbtnCursors//DWS 2017  Code eliminated here. 

		BforTwoPhMat = Bloc*1e-32
		//Sample density, contrast known. Skeletal density from B and Q
		if (DensityMajorityPhase*SLDDensityMajorityPhase==0)//matrix is air			
			DensityMinorityPhase=SampleBulkDensity+Qv/(2*(pi^2)*(SLDDensityMinorityPhase*10^10)^2*SampleBulkDensity)	
			MinorityPhasePhi=SampleBulkDensity/DensityMinorityPhase
			MajorityPhasePhi  = 1-MinorityPhasePhi
			contrast = (DensityMinorityPhase * SLDDensityMinorityPhase)^2
		else //matrix is not air, calculate denskel from Q and phi self consistently (requires absolute intensity)
			phi=0.5
			DensityMinorityPhase = 3*SampleBulkDensity
			do
					deltaSLD=((Qv/(2*pi^2*phi*(1-phi)))^.5 ) / 10^10
					densold=DensityMinorityPhase
					DensityMinorityPhase=(deltaSLD+DensityMajorityPhase*SLDDensityMajorityPhase)/(SLDDensityMinorityPhase)
					DensityMinorityPhase=densold+.1*(DensityMinorityPhase-densold)
					phi =(SampleBulkDensity-DensityMajorityPhase)/(DensityMinorityPhase-DensityMajorityPhase)//phi is vol. Fraction of the dense phase.
			while ((abs((DensityMinorityPhase-densold)/DensityMinorityPhase))>.00001)
			MinorityPhasePhi= phi
			MajorityPhasePhi=(1-phi)  
			contrast = (DensityMinorityPhase * SLDDensityMinorityPhase-DensityMinorityPhase*SLDDensityMinorityPhase)^2	//DWS Corrected 11/25/2013
		endif
		SurfacePerVolume=(1e-4*Pi*Bloc/Qv)*MajorityPhasePhi*MinorityPhasePhi   //m^2/cm^3 calculate from densities and Qp 
		SurfacePerMass = SurfacePerVolume/SamplebulkDensity
		MinorityCordLength = (4/SurfacePerVolume)*(MinorityPhasePhi)*10000
		MajorityCordLength = (4/SurfacePerVolume)*(1-MinorityPhasePhi)*10000
		PiBoverQ = SurfacePerVolume / (MajorityPhasePhi*MinorityPhasePhi)
		IR2U_PlotCalcInvariantFnct()				//create the plot
	elseif(stringmatch(Model,"TwoPhaseSys4"))	
		IR2U_CalculateInvariantbutton()//DWS 2017 eliminated argument (makegraph).  Always want plot.
		Qv=TwoPhaseInvariantbtnCursors//DWS 2017  Code eliminated here. 
		variable phi1=(1+sqrt(abs(1-4*(Qv/deltaSLD^2/(2*pi^2)))))/2  
		variable phi2=(1-sqrt(abs(1-4*(Qv/deltaSLD^2/(2*pi^2)))))/2  
		BforTwoPhMat = Bloc*1e-32		
		if (phi1>phi2)
			phi = phi1
		else
			phi = phi2
		endif
		MinorityPhasePhi = phi2
		MajorityPhasePhi = phi1
		SampleBulkDensity=DensityMinorityPhase-phi*(DensityMinorityPhase-DensityMajorityPhase)
		SurfacePerVolume=(1e-4*Bloc/(2*pi*Contrast))   //m^2/cm^3 calculate from densities and Qp 
		SurfacePerMass = SurfacePerVolume/SamplebulkDensity
		MinorityCordLength = (4/SurfacePerVolume)*(MinorityPhasePhi)*10000
		MajorityCordLength = (4/SurfacePerVolume)*(1-MinorityPhasePhi)*10000
		PiBoverQ = SurfacePerVolume / (MajorityPhasePhi*MinorityPhasePhi)
		IR2U_PlotCalcInvariantFnct()				//create the plot
	elseif(stringmatch(Model,"TwoPhaseSys5"))//particulate analysis	, calculate Vp from I(0) and Qinv
		IR2U_CalculateInvariantbutton()//DWS 2017 eliminated argument (makegraph).  Always want plot.
		Qv=TwoPhaseInvariantbtnCursors//DWS 2017  Code eliminated here. 
		MinorityPhasePhi =(SampleBulkDensity-DensityMajorityPhase)/(DensityMinorityPhase-DensityMajorityPhase)
		PartAnalVolumeOfParticle = (2 *Gloc*(pi^2))*(1-MinorityPhasePhi)/(Qv)
		PartAnalParticleDensity = MinorityPhasePhi/PartAnalVolumeOfParticle
		PartAnalRgFromVp = 1e8*sqrt(3/5)*(3*PartAnalVolumeOfParticle/(4*pi))^(1/3)
		IR2U_PlotCalcInvariantFnct()				//create the plot
	elseif(stringmatch(Model,"TwoPhaseSys6"))//particulate analysis, calcualate Vp from Rg and get numdens from I(0)/(Contrast*Vp^2)	
		IR2U_CalculateInvariantbutton()//DWS 2017 eliminated argument (makegraph).  Always want plot.
		Qv=TwoPhaseInvariantbtnCursors//DWS 2017  Code eliminated here. 
		PartANalRHard = (Rgloc*sqrt(5/3))	//in A
		PartAnalVolumeOfParticle=((PartANalRHard*1e-8)^3)*4*pi/3	//calculated from RG, converted to cm
		Qv=2*(pi^2)*Gloc/PartAnalVolumeOfParticle  	//calculate Q from Rg and I(0)
		PartAnalParticleDensity = Gloc/(PartAnalVolumeOfParticle^2*Contrast)
		SurfacePerVolume = 1e-4*Bloc/((Contrast)*2*pi)
		MinorityPhasePhi =PartAnalParticleDensity*PartAnalVolumeOfParticle
		MajorityPhasePhi = 1 - MinorityPhasePhi
		IR2U_PlotCalcInvariantFnct()				//create the plot

	ENDIF	
	
	setDataFolder OldDf

end

//***********************************************************
//***********************************************************
//***********************************************************


Function IR2U_SaveTwoPhaseSysResults(where)
	string where
	
	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel

	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults
	
	//avoid printinga garbage, bail out if no sensible data selected...
	if(SelectedLevel<1)
		abort
	endif

	string DataFName="", DataIName="",DataQname="",DataEName="", UserName="", AnalysisComentsAndTime=""
	if(UseCurrentResults)
		SVAR DataFolderName = root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntensityWaveName = root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_UnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_UnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		Wave IntWv=root:Packages:Irena_UnifFit:OriginalIntensity
		UserName=stringBykey("UserSampleName",note(IntWv),"=",";")
		AnalysisComentsAndTime = "Using data in Unified fit tool, analyzed on "+date()+" at "+time()
	else
	 	SVAR DataFolderName= root:Packages:Irena_AnalUnifFit:DataFolderName
	 	SVAR IntensityWaveName = root:Packages:Irena_AnalUnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_AnalUnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_AnalUnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		UserName=IR2U_ReturnNoteStrValue("UserSampleName")
		AnalysisComentsAndTime ="Analyzed using "+IR2U_ReturnNoteStrValue("UsersComment")
	endif

	NVAR SelectedLevel=root:Packages:Irena_AnalUnifFit:SelectedLevel//level number selected for analysis generic to other models.
	SVAR SlectedBranchedLevels = root:Packages:Irena_AnalUnifFit:SlectedBranchedLevels
	NVAR OriginalLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	//variable InitialselectedLevel=SelectedLevel//used to reset the panel at the end.  Just in case there is some interference.
	NVAR SelectedQlevel=root:Packages:Irena_AnalUnifFit:SelectedQlevel//Unique to two phase model
	NVAR SelectedBLevel=root:Packages:Irena_AnalUnifFit:SelectedBLevel//Unique to two phase model
	variable LocSelBLevel, LocSelQLevel
	if(stringmatch(SlectedBranchedLevels,"---")||numtype(SelectedQlevel)!=0||numtype(SelectedBLevel)!=0)
		print "Levels not selected correctly. Check controls"
		abort
	elseif(stringmatch(SlectedBranchedLevels,"All"))	//we use values from level 1 but summ all invariants...
		LocSelQLevel=OriginalLevels
		LocSelBLevel=1
	elseif(stringmatch(SlectedBranchedLevels,"Range"))	//we use values from level 1 but summ all invariants...
		LocSelQLevel=SelectedQlevel
		LocSelBLevel=SelectedBLevel
	else
		LocSelQLevel=SelectedLevel
		LocSelBLevel=SelectedLevel
	endif
	//OK, now we have selected range of levels approprioately for controls... 


	NVAR DensityMinorityPhase=root:Packages:Irena_AnalUnifFit:DensityMinorityPhase //need user input here... 
	NVAR DensityMajorityPhase=root:Packages:Irena_AnalUnifFit:DensityMajorityPhase //need user input here... 
	NVAR SampleBulkDensity=root:Packages:Irena_AnalUnifFit:SampleBulkDensity //need user input here... 
	NVAR SLDDensityMinorityPhase=root:Packages:Irena_AnalUnifFit:SLDDensityMinorityPhase //need user input here... 
	NVAR SLDDensityMajorityPhase=root:Packages:Irena_AnalUnifFit:SLDDensityMajorityPhase //need user input here... 
	NVAR MinorityPhasePhi=root:Packages:Irena_AnalUnifFit:MinorityPhasePhi //calculate here. 
	NVAR MajorityPhasePhi=root:Packages:Irena_AnalUnifFit:MajorityPhasePhi //calculate here. 
	NVAR PiBoverQ=root:Packages:Irena_AnalUnifFit:PiBoverQ //calculate here... 
	NVAR MinorityCordLength=root:Packages:Irena_AnalUnifFit:MinorityCordLength //calcualte here... 
	NVAR MajorityCordLength=root:Packages:Irena_AnalUnifFit:MajorityCordLength //calcualte here... 
	NVAR SurfacePerVolume=root:Packages:Irena_AnalUnifFit:SurfacePerVolume //calcualte here... 
	NVAR PartANalRHard=root:Packages:Irena_AnalUnifFit:PartANalRHard //calcualte here... 
	NVAR BforTwoPhMat=root:Packages:Irena_AnalUnifFit:BforTwoPhMat //calcualte here... 
	NVAR PartAnalVolumeOfParticle=root:Packages:Irena_AnalUnifFit:PartAnalVolumeOfParticle //calcualte here... 
	NVAR PartAnalRgFromVp=root:Packages:Irena_AnalUnifFit:PartAnalRgFromVp //calcualte here... 
	NVAR PartAnalParticleDensity=root:Packages:Irena_AnalUnifFit:PartAnalParticleDensity //calcualte here... 
	NVAR Contrast=root:Packages:Irena_AnalUnifFit:TwoPhaseMediaContrast		//Let's use the Scattering contrast calcualterif needed to ge this instead of this complciated mess...
	SVAR Model=root:Packages:Irena_AnalUnifFit:Model//string
	SVAR TwoPhaseSys_MinName=root:Packages:Irena_AnalUnifFit:TwoPhaseSys_MinName
	SVAR TwoPhaseSys_MajName=root:Packages:Irena_AnalUnifFit:TwoPhaseSys_MajName
	NVAR TwoPhaseInvariant=root:Packages:Irena_AnalUnifFit:TwoPhaseInvariant//***DWS
	NVAR UseCsrs=root:Packages:Irena_AnalUnifFit:UseCsrInv//***DWS
	NVAR TwoPhaseInvariantBetweenCursors=root:Packages:Irena_AnalUnifFit:TwoPhaseInvariantBetweenCursors//***DWS
	NVAR InvariantUsed=root:Packages:Irena_AnalUnifFit:InvariantUsed//***DWS
	NVAR excel=root:Packages:Irena_AnalUnifFit:printexcel//***DWS
	NVAR LNumOfLevels =root:Packages:Irena_UnifFit:NumberOfLevels//number of levels in unified fit//***dws
	
	variable Qv=InvariantUsed//***DWS
	variable B=PiBoverQ*Qv/pi//***DWS
	string Text//***DWS
	if((excel==0)||(!StringMatch(where, "graph" )==0)) //***DWS  If excel==1 Igor prints a spreadsheet compatible list in history or logbook
	if(stringMatch(where,"History"))
		Print " "
		Print "******************   Results for two phase analysis of Unified fit results ***************************"
		Print "     User Data Name : "+UserName
		Print "     Date/time : "+AnalysisComentsAndTime
		Print "     Folder name : "+DataFName
		Print "     Intensity name : "+DataIName
		Print "     Q vector name : "+DataQname
		Print "     Error name : "+DataEName
		Print "  "
		Print "     Selected level : "+num2str(SelectedLevel)

		if(stringmatch(Model,"TwoPhaseSys1"))	

			Print "    Method 1: B/Q, skeletal density, and sample density known"
			Print "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName
			Print "    Known: pi B/Q = "+num2str(SurfacePerVolume/(MinorityPhasePhi*(MajorityPhasePhi)))+" [m^2/cm^3]"
			Print "    Skeletal density = "+num2str(DensityMinorityPhase)+" [g/cm^3]"+", Pore density = "+num2str(DensityMajorityPhase)+" [g/cm^3]"
			Print "    Sample density= "+num2str(SampleBulkDensity)+" [g/cm^3]"
			Print "    Calculated: Phi=" + num2str(MinorityPhasePhi)
			Print "    Calculated: S/V = "+num2str(SurfacePerVolume)+" [m^2/cm^3] Per sample volume"
			Print "    Calculated: S/m = "+num2str(SurfacePerVolume/SamplebulkDensity)+" [m^2/g] "
			Print "    Minority chord ="+num2str(MinorityCordLength)+" [A]  MajorityChord = "+num2str(MajorityCordLength)+" [A] "
		elseif(stringmatch(Model,"TwoPhaseSys2"))
			Print "    Method 2:Contrast known;  B absolute."
			Print "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName
			Print "    Known: B= "+num2str(BforTwoPhMat)+"   [1/(A^4 cm^1)]"
			Print "    Skeletal density = "+num2str(DensityMinorityPhase)+" [g/cm^3], Pore density = "+num2str(MajorityPhasePhi)+" [g/cm^3]"
			Print "    Sample density = "+num2str(SampleBulkDensity)+" [g/cm^3]"
	 		Print "    Contrast = "+num2str(Contrast)+"   [1/cm^4]"
	 		Print "    Calculated: S/V = "+num2str(SurfacePerVolume)+" [m^2/cm^3] Per sample volume"
			Print "    Calculated: S/m = "+num2str(SurfacePerVolume/SamplebulkDensity)+" [m^2/g] "
			Print "    Calculated: Minority chord ="+num2str(MinorityCordLength)+" [A]  MajorityChord = "+num2str(MajorityCordLength)+" [A] "
		elseif(stringmatch(Model,"TwoPhaseSys3"))
			Print "    Method 3: Sample density, contrast known"
			Print "    Skeletal density calculated from B and Q"
			Print "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName
			Print "    Known: Q = "+num2str(TwoPhaseInvariant*1e-24)+" [1/(A^3 cm)]"
			Print "    B= "+num2str(BforTwoPhMat)+"   [1/(A^4 cm)]"
			Print "    Pore density = "+num2str(DensityMajorityPhase)
			Print "    Sample density = "+num2str(SampleBulkDensity)+" [g/cm^3]"
			Print "    Calculated: Skeletal density = "+num2str(DensityMinorityPhase)+"  Phi = "+num2str(MinorityPhasePhi)
	   	Print "    Calculated: S/V = "+num2str(SurfacePerVolume)+" m^2/cm^3 Per sample volume"
			Print "    Calculated: S/m = "+num2str(SurfacePerVolume/SamplebulkDensity)+" [m^2/g] "
			Print "    Calculated: Minority chord ="+num2str(MinorityCordLength)+" [A]  MajorityChord = "+num2str(MajorityCordLength)+" [A] "
		elseif(stringmatch(Model,"TwoPhaseSys4"))
			Print "    Method 4: using B and Q and contrast"
			Print "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName
			Print "    Known: Q = "+num2str(TwoPhaseInvariant*1e-24)+" [1/(A^3 cm)]"
			Print "    B= "+num2str(BforTwoPhMat)+"   [1/(A^4 cm)]"
			Print "    Skeletal density = "+num2str(DensityMinorityPhase)+" [g/cm^3], Pore density = "+num2str(DensityMajorityPhase)+" [g/cm^3]"
	 		Print "    Contrast = "+num2str(Contrast)+"   [1/cm^4]"
			Print "    Calculated: phi = "+num2str(MinorityPhasePhi)+"       or       "+num2str(MajorityPhasePhi)
			Print "    Calculated: Sample density= "+num2str(SampleBulkDensity)+" [g/cm^3]"
			Print "    Calculated: S/V = "+num2str(SurfacePerVolume)+" [m^2/cm^3] per sample volume for phi = "+num2str(MinorityPhasePhi)
			Print "    Calculated: S/m = "+num2str(SurfacePerVolume/SamplebulkDensity)+" [m^2/g] "
			Print "    Calculated: Minority chord ="+num2str(MinorityCordLength)+" [A]  MajorityChord = "+num2str(MajorityCordLength)+" [A] "
		elseif(stringmatch(Model,"TwoPhaseSys5"))
			Print "    Method 5: Particulate analysis"
			Print "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName
			Print "    For density minority phase = "+num2str(DensityMinorityPhase)+" [g/cm^3], Sample Bulk Density = "+num2str(SampleBulkDensity)+" [g/cm^3], density majority phase = "+num2str(DensityMajorityPhase)+" [g/cm^3]"
			Print "    Phi=" + num2str(MinorityPhasePhi)
			Print "    Calculated: Vp = "+num2str(PartAnalVolumeOfParticle)+" [cm^3]"
			Print "    Calculated: Rg(from Vp) = "+num2str(PartAnalRgFromVp)+" A"//Vp = "+num2str(Vp) +", phi = "+num2str(phi)+"
			Print "    Calculated: Particle Density  = "+num2str(PartAnalParticleDensity)+" [1/cm^3] " 	
		elseif(stringmatch(Model,"TwoPhaseSys6"))
			Print "    Method 6: Particulate, Vp from measured Rg"
			Print "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName
			Print "    For density minority phase = "+num2str(DensityMinorityPhase)+" [g/cm^3], Sample Bulk Density = "+num2str(SampleBulkDensity)+" [g/cm^3], density majority phase = "+num2str(DensityMajorityPhase)+" [g/cm^3]"
			Print "    Calculated: Vp (from Rg) = "+num2str(PartAnalVolumeOfParticle)+" [cm^3]"
			Print "    Calculated: phi = "+num2str(MinorityPhasePhi)
			Print "    Calculated: Rhard (from Rg)= "+num2str(PartANalRHard)+" [A] "
			Print "    Calculated: Particle Density (particles in cm^3) = "+num2str(PartAnalParticleDensity)+" [1/cm^3] (from I(0)/(Vp^2 * contrast)) " 
		endif
		print "******************************************************************************************************"
		print " "
		
	elseif(stringMatch(where,"Logbook"))

			IR1_CreateLoggbook()
			IR1_PullUpLoggbook()
			IR1L_AppendAnyText( " ")
			IR1L_AppendAnyText( "******************   Results for two phase analysis of Unified fit results ***************************")
			IR1L_AppendAnyText("     User Data Name : "+UserName)
			IR1L_AppendAnyText("     Date/time : "+AnalysisComentsAndTime)
			IR1L_AppendAnyText("     Folder name : "+DataFName)
			IR1L_AppendAnyText("     Intensity name : "+DataIName)
			IR1L_AppendAnyText( "     Q vector name : "+DataQname)
			IR1L_AppendAnyText("     Error name : "+DataEName)
			IR1L_AppendAnyText("  ")
			IR1L_AppendAnyText( "     Selected level : "+num2str(SelectedLevel))
	
		if(stringmatch(Model,"TwoPhaseSys1"))
		
			IR1L_AppendAnyText( "    Method 1: B/Q, skeletal density, and sample density known")
			IR1L_AppendAnyText( "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName)
			IR1L_AppendAnyText( "    Known: pi B/Q = "+num2str(SurfacePerVolume/(MinorityPhasePhi*(MajorityPhasePhi)))+" [m^2/cm^3]")
			IR1L_AppendAnyText( "    Skeletal density = "+num2str(DensityMinorityPhase)+" [g/cm^3]"+", Pore density = "+num2str(DensityMajorityPhase)+" [g/cm^3]")
			IR1L_AppendAnyText( "    Sample density= "+num2str(SampleBulkDensity)+" [g/cm^3]")
			IR1L_AppendAnyText( "    Calculated: Phi=" + num2str(MinorityPhasePhi))
			IR1L_AppendAnyText( "    Calculated: S/V = "+num2str(SurfacePerVolume)+" [m^2/cm^3] Per sample volume")
			IR1L_AppendAnyText( "    Calculated: S/m = "+num2str(SurfacePerVolume/SamplebulkDensity)+" [m^2/g]")
			IR1L_AppendAnyText( "    Results: minority chord ="+num2str(MinorityCordLength)+" [A]  MajorityChord = "+num2str(MajorityCordLength)+" [A] ")

		elseif(stringmatch(Model,"TwoPhaseSys2"))
			IR1L_AppendAnyText( "    Method 2:Contrast known;  B absolute.")
			IR1L_AppendAnyText( "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName)
			IR1L_AppendAnyText( "    Known: B= "+num2str(BforTwoPhMat)+"   [1/(A^4 cm^1)]")
			IR1L_AppendAnyText( "    Skeletal density = "+num2str(DensityMinorityPhase)+" [g/cm^3], Pore density = "+num2str(MajorityPhasePhi)+" [g/cm^3]")
			IR1L_AppendAnyText( "    Sample density = "+num2str(SampleBulkDensity)+" [g/cm^3]")
	 		IR1L_AppendAnyText( "    Contrast = "+num2str(Contrast)+"  [1/cm^4]")
	 		IR1L_AppendAnyText( "    Calculated: S/V = "+num2str(SurfacePerVolume)+" [m^2/cm^3] Per sample volume")
			IR1L_AppendAnyText( "    Calculated: S/m = "+num2str(SurfacePerVolume/SamplebulkDensity)+" [m^2/g]")
			IR1L_AppendAnyText( "    Calculated: minority chord ="+num2str(MinorityCordLength)+" [A]  MajorityChord = "+num2str(MajorityCordLength)+" [A] ")
		elseif(stringmatch(Model,"TwoPhaseSys3"))
			IR1L_AppendAnyText( "    Method 3: Sample density, contrast known")
			IR1L_AppendAnyText( "    Skeletal density calculated from B and Q")
			IR1L_AppendAnyText( "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName)
			IR1L_AppendAnyText( "    Known: Q = "+num2str(TwoPhaseInvariant*1e-24)+" [1/(A^3 cm)]")
			IR1L_AppendAnyText( "    B= "+num2str(BforTwoPhMat)+"   [1/(A^4 cm)]")
			IR1L_AppendAnyText( "    Pore density = "+num2str(DensityMajorityPhase))
			IR1L_AppendAnyText( "    Sample density = "+num2str(SampleBulkDensity)+" [g/cm^3]")
			IR1L_AppendAnyText( "    Calculated: Skeletal density = "+num2str(DensityMinorityPhase)+"  Phi = "+num2str(MinorityPhasePhi))
	   	IR1L_AppendAnyText( "    Calculated: S/V = "+num2str(SurfacePerVolume)+" m^2/cm^3 Per sample volume")
			IR1L_AppendAnyText( "    Calculated: S/m = "+num2str(SurfacePerVolume/SamplebulkDensity)+" [m^2/g]")
			IR1L_AppendAnyText( "    Calculated: minority chord ="+num2str(MinorityCordLength)+" [A]  MajorityChord = "+num2str(MajorityCordLength)+" [A] ")
		elseif(stringmatch(Model,"TwoPhaseSys4"))
			IR1L_AppendAnyText( "    Method 4: using B and Q and contrast")
			IR1L_AppendAnyText( "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName)
			IR1L_AppendAnyText( "    Known: Q = "+num2str(TwoPhaseInvariant*1e-24)+" [1/(A^3 cm)]")
			IR1L_AppendAnyText( "    B= "+num2str(BforTwoPhMat)+"   [1/(A^4 cm)]")
			IR1L_AppendAnyText( "    Skeletal density = "+num2str(DensityMinorityPhase)+" [g/cm^3], Pore density = "+num2str(DensityMajorityPhase)+" [g/cm^3]")
	 		IR1L_AppendAnyText( "    Contrast = "+num2str(Contrast)+"  [1/cm^4]")
			IR1L_AppendAnyText( "    Calculated: phi = "+num2str(MinorityPhasePhi)+"       or       "+num2str(MajorityPhasePhi))
			IR1L_AppendAnyText( "    Calculated: Sample density= "+num2str(SampleBulkDensity)+" [g/cm^3]")
			IR1L_AppendAnyText( "    Calculated: S/V = "+num2str(SurfacePerVolume)+" [m^2/cm^3] per sample volume for phi = "+num2str(MinorityPhasePhi))
			IR1L_AppendAnyText( "    Calculated: S/m = "+num2str(SurfacePerVolume/SamplebulkDensity)+" [m^2/g]")
			IR1L_AppendAnyText( "    Calculated: minority chord ="+num2str(MinorityCordLength)+" [A]  MajorityChord = "+num2str(MajorityCordLength)+" [A] ")
		elseif(stringmatch(Model,"TwoPhaseSys5"))
			IR1L_AppendAnyText( "    Method 5: Particulate analysis")
			IR1L_AppendAnyText( "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName)
			IR1L_AppendAnyText( "    For density minority phase = "+num2str(DensityMinorityPhase)+" [g/cm^3], Sample Bulk Density = "+num2str(SampleBulkDensity)+" [g/cm^3], density majority phase = "+num2str(DensityMajorityPhase)+" [g/cm^3]")
			IR1L_AppendAnyText( "    Phi=" + num2str(MinorityPhasePhi))
			IR1L_AppendAnyText( "    Calculated: Vp = "+num2str(PartAnalVolumeOfParticle)+" [cm^3]")
			IR1L_AppendAnyText( "    Calculated: Rg (from Vp) = "+num2str(PartAnalRgFromVp)+" A")//Vp = "+num2str(Vp) +", phi = "+num2str(phi)+")
			IR1L_AppendAnyText( "    Calculated: Particle Density  = "+num2str(PartAnalParticleDensity)+" [1/cm^3]  " )	
		elseif(stringmatch(Model,"TwoPhaseSys6"))
			IR1L_AppendAnyText( "    Method 6: Particulate, Vp from measured Rg")
			IR1L_AppendAnyText( "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName)
			IR1L_AppendAnyText( "    For density minority phase = "+num2str(DensityMinorityPhase)+" [g/cm^3], Sample Bulk Density = "+num2str(SampleBulkDensity)+" [g/cm^3], density majority phase = "+num2str(DensityMajorityPhase)+" [g/cm^3]")
			IR1L_AppendAnyText( "    Calculated: Vp (from Rg) = "+num2str(PartAnalVolumeOfParticle)+" [cm^3]")
			IR1L_AppendAnyText( "    Calculated: phi = "+num2str(MinorityPhasePhi))
			IR1L_AppendAnyText( "    Calculated: Rhard (from Rg)= "+num2str(PartANalRHard)+" [A] ")
			IR1L_AppendAnyText( "    Calculated: Particle Density (particles in cm^3) = "+num2str(PartAnalParticleDensity)+" [1/cm^3] (from I(0)/(Vp^2 * contrast)) " )
		endif
		


		//IR1L_AppendAnyText("******************************************************************************************************")
		//IR1L_AppendAnyText("  ")
	elseif(stringmatch(where,"Graph"))
		string GraphName=""
		if(UseCurrentResults)
			GraphName="IR1_LogLogPlotU"
		else
			GraphName=WinName(0,1)
		endif
		string NewTextBoxStr="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")
		string m2percm3=" [m\S2\M\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"/cm\S3\M\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"]"
		string gpercm3=" [g/cm\S3\M\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"]"
		string Amin1cmmin1=" [A\S-1\M\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"cm\S-1\M\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"]"
		string cmmin4= " [cm\S-4\M\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"]"
		string TentoTen= " 10\S10\M\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")
		string Amin3cmmin1= " [A\S-3\M\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+" cm\S-1\M\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"]"
		string Amin4= " [A\S-4\M\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"]"
		string Amin4cmmin1= " [A\S-4\M\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+" cm\S-1\M\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"]"
		string Onepercm3=" [cm\S-3\M\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"]"
		string cm3=" [cm\S3\M\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"]"

		NewTextBoxStr+= "Unified fit analysis using Two Phase assumptions\r"
		if(strlen(UserName)>0)
			NewTextBoxStr+= "User Data Name : "+UserName+" \r"
		else
			NewTextBoxStr+= "Folder name : "+DataFName+" \r"
		endif
		NewTextBoxStr+= "Selected level : "+num2str(SelectedLevel)
		if(stringmatch(Model,"TwoPhaseSys1"))	
			NewTextBoxStr+= "\r"+  "    Method 1: B/Q, skeletal density, and sample density known"
			NewTextBoxStr+= "\r"+  "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName
			NewTextBoxStr+= "\r"+  "    Known: pi B/Q = "+num2str(SurfacePerVolume/(MinorityPhasePhi*(MajorityPhasePhi)))+m2percm3//" [m^2/cm^3]"
			NewTextBoxStr+= "\r"+  "    Skeletal density = "+num2str(DensityMinorityPhase)+gpercm3+", Pore density = "+num2str(DensityMajorityPhase)+gpercm3
			NewTextBoxStr+= "\r"+  "    Sample density= "+num2str(SampleBulkDensity)+gpercm3
			NewTextBoxStr+= "\r"+  "    Calculated: Phi=" + num2str(MinorityPhasePhi)
			NewTextBoxStr+= "\r"+  "    Calculated: S/V = "+num2str(SurfacePerVolume)+m2percm3+" per sample volume"
			NewTextBoxStr+= "\r"+  "    Results: minority chord ="+num2str(MinorityCordLength)+" [A]  MajorityChord = "+num2str(MajorityCordLength)+" [A] "
		elseif(stringmatch(Model,"TwoPhaseSys2"))
			NewTextBoxStr+= "\r"+  "    Method 2:Contrast known;  B absolute."
			NewTextBoxStr+= "\r"+  "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName
			NewTextBoxStr+= "\r"+  "    Known: B= "+num2str(BforTwoPhMat)+Amin4cmmin1//"   [1/(A^4 cm^1)]"
			NewTextBoxStr+= "\r"+  "    Skeletal density = "+num2str(DensityMinorityPhase)+gpercm3+", Pore density = "+num2str(MajorityPhasePhi)+gpercm3
			NewTextBoxStr+= "\r"+  "    Sample density = "+num2str(SampleBulkDensity)+gpercm3
	 		NewTextBoxStr+= "\r"+  "    Contrast = "+num2str(Contrast)+cmmin4
	 		NewTextBoxStr+= "\r"+  "    Calculated: S/V = "+num2str(SurfacePerVolume)+m2percm3+" per sample volume"
			NewTextBoxStr+= "\r"+  "    Calculated: minority chord ="+num2str(MinorityCordLength)+" [A]  MajorityChord = "+num2str(MajorityCordLength)+" [A] "
		elseif(stringmatch(Model,"TwoPhaseSys3"))
			NewTextBoxStr+= "\r"+  "    Method 3: Sample density, contrast known"
			NewTextBoxStr+= "\r"+  "    Skeletal density calculated from B and Q"
			NewTextBoxStr+= "\r"+  "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName
			NewTextBoxStr+= "\r"+  "    Known: Q = "+num2str(TwoPhaseInvariant*1e-24)+Amin3cmmin1
			NewTextBoxStr+= "\r"+  "    B= "+num2str(BforTwoPhMat)+Amin4cmmin1
			NewTextBoxStr+= "\r"+  "    Pore density = "+num2str(DensityMajorityPhase)
			NewTextBoxStr+= "\r"+  "    Sample density = "+num2str(SampleBulkDensity)+gpercm3
			NewTextBoxStr+= "\r"+  "    Calculated: Skeletal density = "+num2str(DensityMinorityPhase)+gpercm3+", Phi = "+num2str(MinorityPhasePhi)
	   		NewTextBoxStr+= "\r"+  "    Calculated: S/V = "+num2str(SurfacePerVolume)+m2percm3+" per sample volume"
			NewTextBoxStr+= "\r"+  "    Calculated: minority chord ="+num2str(MinorityCordLength)+" [A]  MajorityChord = "+num2str(MajorityCordLength)+" [A] "
		elseif(stringmatch(Model,"TwoPhaseSys4"))
			NewTextBoxStr+= "\r"+  "    Method 4: using B and Q and contrast"
			NewTextBoxStr+= "\r"+  "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName
			NewTextBoxStr+= "\r"+  "    Known: Q = "+num2str(TwoPhaseInvariant*1e-24)+Amin3cmmin1
			NewTextBoxStr+= "\r"+  "    B= "+num2str(BforTwoPhMat)+Amin4cmmin1
			NewTextBoxStr+= "\r"+  "    Skeletal density = "+num2str(DensityMinorityPhase)+gpercm3+", Pore density = "+num2str(DensityMajorityPhase)+gpercm3
	 		NewTextBoxStr+= "\r"+  "    Contrast = "+num2str(Contrast)+cmmin4
			NewTextBoxStr+= "\r"+  "    Calculated: phi = "+num2str(MinorityPhasePhi)+"       or       "+num2str(MajorityPhasePhi)
			NewTextBoxStr+= "\r"+  "    Sample density= "+num2str(SampleBulkDensity)+gpercm3
			NewTextBoxStr+= "\r"+  "    Calculated: S/V = "+num2str(SurfacePerVolume)+m2percm3+" per sample volume for phi = "+num2str(MinorityPhasePhi)
			NewTextBoxStr+= "\r"+  "    Calculated: minority chord ="+num2str(MinorityCordLength)+" [A]  MajorityChord = "+num2str(MajorityCordLength)+" [A] "
		elseif(stringmatch(Model,"TwoPhaseSys5"))
			NewTextBoxStr+= "\r"+  "    Method 5: Particulate analysis"
			NewTextBoxStr+= "\r"+  "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName
			NewTextBoxStr+= "\r"+  "    For density minority phase = "+num2str(DensityMinorityPhase)+gpercm3+", Sample Bulk Density = "+num2str(SampleBulkDensity)+gpercm3+", density majority phase = "+num2str(DensityMajorityPhase)+gpercm3
			NewTextBoxStr+= "\r"+  "    Calculated: Phi=" + num2str(MinorityPhasePhi)
			NewTextBoxStr+= "\r"+  "    Calculated: Vp = "+num2str(PartAnalVolumeOfParticle)+cm3
			NewTextBoxStr+= "\r"+  "    Calculated: Rg(from Vp) = "+num2str(PartAnalRgFromVp)+" [A]"
			NewTextBoxStr+= "\r"+  "    Calculated: Particle Density  = "+num2str(PartAnalParticleDensity)+Onepercm3
		elseif(stringmatch(Model,"TwoPhaseSys6"))
			NewTextBoxStr+= "\r"+  "    Method 6: Particulate, Vp from measured Rg"
			NewTextBoxStr+= "\r"+  "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName
			NewTextBoxStr+= "\r"+  "    For density minority phase = "+num2str(DensityMinorityPhase)+gpercm3+", Sample Bulk Density = "+num2str(SampleBulkDensity)+gpercm3+", density majority phase = "+num2str(DensityMajorityPhase)+gpercm3
			NewTextBoxStr+= "\r"+  "    Calculated: Vp (from Rg) = "+num2str(PartAnalVolumeOfParticle)+cm3
			NewTextBoxStr+= "\r"+  "    Calculated: phi = "+num2str(MinorityPhasePhi)
			NewTextBoxStr+= "\r"+  "    Calculated: Rhard (from Rg)= "+num2str(PartANalRHard)+" [A] "
			NewTextBoxStr+= "\r"+  "    Calculated: Particle Density (particles "+Onepercm3+") = "+num2str(PartAnalParticleDensity)+Onepercm3+" (from I(0)/(Vp^2 * contrast)) " 
		endif
		string list=WinList(Graphname, ";", "" )//**DWS  skips if graph does not exist		
		IF  (!stringmatch(list,""))
			string AnotList=AnnotationList(GraphName)
			variable i
			For(i=0;i<100;i+=1)
				if(!stringMatch(AnotList,"*UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i)+"*"))
					break
				endif
			endfor
			TextBox/C/W=$(GraphName)/N=$("UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i))/F=0/B=1/A=MC NewTextBoxStr
		else
			Doalert 0, "Graph does not exist"
		endif
	endif
	
		LocSelQLevel=SelectedQlevel
		LocSelBLevel=SelectedBLevel
	
	elseif((excel==1)&&(StringMatch(where, "graph" )==0))//***DWS
		variable N=strlen(model)-1
		string mdl=model[N]
		variable SL=SelectedLevel
		If (numtype(SL)==2)//User chose all
			SL = 10//code for all levels	
		endif		
		SVAR IntensityWaveName=root:Packages:Irena_UnifFit:IntensityWaveName
		NVAR printlogbook=root:Packages:Irena_AnalUnifFit:printlogbook
		TEXT="rWave\tModel\tStart\tEnd\tUseCsrs\tB[cm-1A-4]\tQ[Cm-1A-3]\tpiB/Q[m2/cm3]\tMinDens[g/cm3]\tMajDens[g/cm3]\tSamDens[g/cm3]\tphimin\tSv[m2/cm3]\tSm[m2/g]\tMinChord[A]\tMajChord[A]"
		TEXT+="\t10^-10xSLmin[cm/g]\t10^-10xSLmaj[cm/g]"
		string TEXT2=IntensityWaveName+"\t"+Mdl+"\t"+num2str(LocSelBLevel)+"\t"+num2str( LocSelQLevel) +"\t"+num2str(usecsrs)+"\t" +num2str(B*1e-28)+"\t"+num2str(Qv*1e-24)+"\t"+num2str(piBoverQ)
			TEXT2+="\t"+num2str(DensityMinorityPhase) +"\t"+   num2str(DensityMajorityPhase)+"\t"+num2str(SampleBulkDensity)+"\t"+num2str(MinorityPhasePhi)+"\t"+num2str(SurfacePerVolume)
			TEXT2+="\t"+num2str(SurfacePerVolume/SamplebulkDensity)+"\t"+num2str(MinorityCordLength)+"\t"+num2str(MajorityCordLength)
			TEXT2+="\t"+   num2str(SLDDensityMinorityPhase)   +"\t "+  num2str(SLDDensityMajorityPhase)
		
		If(!printlogbook)// ie print to history ***DWS
			Print TEXT	
			print TEXT2
		else
			IR1L_AppendAnyPorodText(text2)// print to log book excel compatible***DWS
		endif
	Endif
end

//***********************************************************
//***********************************************************
//***********************************************************

function IR2U_InvariantForMultipleLevels(uptolevel)
		variable uptolevel
		//SVAR DF=root:Packages:Irena_UnifFit:DataFolderName
		//setdatafolder root:Packages:SAS_Modeling
	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	variable RgLoc, Bloc
	if(UseCurrentResults)
		NVAR Rg=$("root:Packages:irena_UnifFit:Level"+num2str(1)+"Rg")
		NVAR B=$("root:Packages:irena_UnifFit:Level"+num2istr(1)+"B")	
		RgLoc=Rg
		Bloc=B
	else
		RgLoc= IR2U_ReturnNoteNumValue("Level"+num2str(1)+"Rg")
		Bloc = IR2U_ReturnNoteNumValue("Level"+num2str(1)+"B")
	endif
		variable tempB=Bloc
		variable maxQ=2*pi/(Rgloc/10)
		variable Newnumpnts=2000, extrapnts=500,Qv
		Make/O/D/N=(Newnumpnts) qUnifiedfit,rUnifiedfit,rUnifiedfitq2,tempunifiedIntensity
		qUnifiedfit=(maxQ/(Newnumpnts-1))*p	
		runifiedfit=0
		variable i
		for(i=1;i<=uptolevel;i+=1)	// initialize variables;continue test
				IR2U_UnifiedCalcIntOneX(qUnifiedfit,i,1)//qcutoff is zero for no cutoff//could cause a problem
				 runifiedfit=runifiedfit+tempunifiedIntensity
		endfor	
		runifiedfit[0]=runifiedfit[1]	
			tempunifiedintensity=runifiedfit//used by SurfaceArea function
		rUnifiedfitq2=rUnifiedfit*qunifiedfit^2
		//print maxq
		//appendtograph/W=IR1_LogLogPlotU runifiedfit vs qunifiedfit
		Qv=areaXY(qUnifiedfit, rUnifiedfitq2, 0, MaxQ)
		tempB=rUnifiedfit[newnumpnts-1]*maxQ^4//makes -4 extension match last point of fit
	
		Qv+=tempB/maxQ//extends with -4 exponent  DWS
		killwaves/Z rUnifiedfitq2,runifiedfit
		return Qv// cm-1A-3  mult by 1e24 for cm-4
end
//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_UnifiedBtwnLevls_DWS(qwave,rwave, Bottomlevel, uptolevel)// DWS 2017
	wave rwave,qwave
	Variable Bottomlevel,uptolevel
	string DF=getdatafolder(1)	
	
	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	variable RgLoc, Bloc//don't seem to be used except for testing
	if(UseCurrentResults)
		NVAR Rg=$("root:Packages:irena_UnifFit:Level"+num2str(1)+"Rg")
		NVAR B=$("root:Packages:irena_UnifFit:Level"+num2istr(1)+"B")	
		NVAR Rg=$("root:Packages:irena_UnifFit:Level"+num2str(uptolevel)+"Rg")
		NVAR B=$("root:Packages:irena_UnifFit:Level"+num2istr(Bottomlevel)+"B")	
	endif
		variable Newnumpnts=numpnts(qwave)
		Make/O/D/N=(Newnumpnts) qUnifiedfit,rUnifiedfit,tempunifiedIntensity
		qUnifiedfit=qwave
		runifiedfit=0
		variable i
		for(i=Bottomlevel;i<=uptolevel;i+=1)	
			if(i==Bottomlevel)
				IR2U_UnifiedCalcIntOneX(qUnifiedfit,i,0)//DWS 2017
				//Cant cut off the analytical extension of B level when calculating invariant
			else
				IR2U_UnifiedCalcIntOneX(qUnifiedfit,i,1)
			endif
				 runifiedfit=runifiedfit+tempunifiedIntensity
		endfor	
		runifiedfit[0]=runifiedfit[1]
	rwave=runifiedfit
	killwaves/Z rUnifiedfitq2,runifiedfit,runifiedfit,tempunifiedIntensity,qunifiedfit
	setdatafolder DF
end


Function IR2U_UnifiedCalcIntOneX(qvec,level,qcutoff)//qcutoff is zero for no cutoff
	variable level,qcutoff
	wave qvec	
	//setDataFolder Root:Packages:SAS_Modeling
	Duplicate/O qvec, TempUnifiedIntensity, QstarVector
	Redimension/D TempUnifiedIntensity, QstarVector
	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	variable Rgloc, Gloc, Ploc,Bloc,ETAloc, PACKloc,RgCOloc,Kloc,CorelationsLoc,MassFractalLoc,linkRGCOloc 
	if(UseCurrentResults)
		NVAR Rg=$("Root:Packages:Irena_UnifFit:Level"+num2str(level)+"Rg")
		NVAR G=$("Root:Packages:Irena_UnifFit:Level"+num2str(level)+"G")
		NVAR P=$("Root:Packages:Irena_UnifFit:Level"+num2str(level)+"P")
		NVAR B=$("Root:Packages:Irena_UnifFit:Level"+num2str(level)+"B")
		NVAR ETA=$("Root:Packages:Irena_UnifFit:Level"+num2str(level)+"ETA")
		NVAR PACK=$("Root:Packages:Irena_UnifFit:Level"+num2str(level)+"PACK")
		NVAR RgCO=$("Root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgCO")
		NVAR K=$("Root:Packages:Irena_UnifFit:Level"+num2str(level)+"K")
		NVAR Corelations=$("Root:Packages:Irena_UnifFit:Level"+num2str(level)+"Corelations")
		NVAR MassFractal=$("Root:Packages:Irena_UnifFit:Level"+num2str(level)+"MassFractal")
		NVAR LinkRGCO=$("Root:Packages:Irena_UnifFit:Level"+num2str(level)+"LinkRGCO")
		Rgloc=Rg
		 Gloc=G
		 Ploc=P
		 Bloc=B
		 ETAloc=ETA
		 PACKloc=PACK
		 RgCOloc=RGCO
		 Kloc=K
		 CorelationsLoc=Corelations
		 MassFractalLoc=MassFractal
		 linkRGCOloc=linkRGCO
	else
		//look up from wave note...
		 Gloc= IR2U_ReturnNoteNumValue("Level"+num2str(level)+"G")
		 Rgloc=  IR2U_ReturnNoteNumValue("Level"+num2str(level)+"Rg")
		 Bloc = IR2U_ReturnNoteNumValue("Level"+num2str(level)+"B")
		 Ploc= IR2U_ReturnNoteNumValue("Level"+num2str(level)+"P")
		 ETAloc=IR2U_ReturnNoteNumValue("Level"+num2str(level)+"ETA")
		 PACKloc=IR2U_ReturnNoteNumValue("Level"+num2str(level)+"PACK")
		 RgCOloc=IR2U_ReturnNoteNumValue("Level"+num2str(level)+"RgCO")
		 Kloc=IR2U_ReturnNoteNumValue("Level"+num2str(level)+"K")
		 Corelationsloc=IR2U_ReturnNoteNumValue("Level"+num2str(level)+"Corelations")
		 MassFractalloc=IR2U_ReturnNoteNumValue("Level"+num2str(level)+"MassFractal")
		 LinkRGCOloc=IR2U_ReturnNoteNumValue("Level"+num2str(level)+"LinkRGCO")
	endif

	variable RgCOold=RgCOloc
	if(qcutoff==0)//added by dws  zero means no cuttoff
		RgCOloc=0
		LinkRgCOloc =0
	endif
	
	QstarVector=qvec/(erf(Kloc*qvec*Rgloc/sqrt(6)))^3
	if (MassFractalloc)
		Bloc=(Gloc*Ploc/Rgloc^Ploc)*exp(gammln(Ploc/2))
	endif
	
	TempUnifiedIntensity=Gloc*exp(-qvec^2*Rgloc^2/3)+(Bloc/QstarVector^Ploc) * exp(-RGCOloc^2 * qvec^2/3)
	
	if (Corelationsloc)
		TempUnifiedIntensity/=(1+packloc*IR1A_SphereAmplitude(qvec,ETAloc))
	endif
	RgCOloc=RgCOold
	killwaves/Z  Qstarvector
end

//*********************************************************************************
//*********************************************************************************
//*********************************************************************************
//*********************************************************************************
//*********************************************************************************

Function IR2U_UnifAnalysisHelp()

	DoWindow UnifiedAnalysisHelp
	if(V_Flag)
		DoWindow/F UnifiedAnalysisHelp
	else

		String nb = "UnifiedAnalysisHelp"
		NewNotebook/N=$nb/F=1/V=1/K=1/W=(844,66,1360,786)
		Notebook $nb defaultTab=36, statusWidth=252
		Notebook $nb showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
		Notebook $nb ruler=Normal, fSize=14, fStyle=1, textRGB=(52428,1,1), text="Analyze results\r"
		Notebook $nb fSize=-1, fStyle=-1, textRGB=(0,1,3), text="\r"
		Notebook $nb text="Some specifc cases can be analyzed further using Unified method. These are :\r"
		Notebook $nb text="\tInvariant\r"
		Notebook $nb text="\tPorod's law\r"
		Notebook $nb text="\tSize distribution (published by Greg Beaucage). \r"
		Notebook $nb text="\tBranched polymers (published by Greg Beaucage). \r"
		Notebook $nb text="\tTwo Phase system (published by Dale Schaefer)\r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=2, text="References", fStyle=-1, text=": \r"
		Notebook $nb text="Beaucage, Phys rev E (2004), 70(3), p10\r"
		Notebook $nb text="Beaucage, Biophys J. (2008), 95(2), p503\r"
		Notebook $nb text="Naiping Hu, Neha Borkar, Doug Kohls and Dale W. Schaefer, “Characterization of Porous Materials Using Co"
		Notebook $nb text="mbined Small-Angle X-ray and Neutron Scattering Techniques”, J Appl Cryst 2011)\r"
		Notebook $nb text="\r"
		Notebook $nb text="All of these can be analyzed by using “Analyze results” tool. It can be called from the bottom of the Un"
		Notebook $nb text="ified main panel.  There are two options which data can be analyzed… Current Unified data in the Unified"
		Notebook $nb text=" fit tool or Unified results saved to any folder in the Igor experiment.\r"
		Notebook $nb text="\r"
		Notebook $nb text="\r"
		Notebook $nb text="User can output results of any analysis to either command line, the log book (Igor “notebook” into which"
		Notebook $nb text=" many Irena tools save records) or in the top graph as legend.  \r"
		Notebook $nb text="\r"
		Notebook $nb text="\r"
		Notebook $nb fSize=14, fStyle=1, textRGB=(0,0,65535), text="Available methods:\r"
		Notebook $nb fSize=-1, fStyle=-1, textRGB=(0,1,3), text="\r"
		Notebook $nb fSize=12, fStyle=3, text="Invariant", fSize=-1, fStyle=-1, text=":\r"
		Notebook $nb text="Provide contrast (delta-rho squared) and the tool will provide volume of the phase in teh system. \r"
		Notebook $nb text="You can use the button to open Scattering contrast calculator. \r"
		Notebook $nb text="\r"
		Notebook $nb fSize=12, fStyle=3, text="Porods law\r"
		Notebook $nb fSize=-1, fStyle=-1
		Notebook $nb text="ONLY if the P for selected level is close to 4 (3.96 - 4.04). In that case, the tool provides Porod cons"
		Notebook $nb text="tant, P and calculates specific surface area - if the scattering contrast is provided. You need to have "
		Notebook $nb text="data absolutely calibrated. \r"
		Notebook $nb text="\r"
		Notebook $nb fSize=12, fStyle=3, text="Branched mass fractal\r"
		Notebook $nb fSize=-1, fStyle=-1, text="\r"
		Notebook $nb text="Ok, this tool requires users to read the references. The code was provided by Greg Beaucage and provides"
		Notebook $nb text=" results as expected. But I am not clear on what these numbers really mean. Any way, the references are "
		Notebook $nb text="on the panel itself. \r"
		Notebook $nb text="Note, that when the calculations fail, the tool beeps and prints error message in the red box. \r"
		Notebook $nb text="\r"
		Notebook $nb text="Note, to calculate all of the parameters, you need two levels - so there are choices like 2/1 (1 would b"
		Notebook $nb text="e primary particles, 2 would be the mass fractal). But you can also calculate some parameters from only "
		Notebook $nb text="one level  (dmin and c) and if you select only one level, parameters, which cannot be calculated, will b"
		Notebook $nb text="e set to NaN. \r"
		Notebook $nb text="\r"
		Notebook $nb fSize=12, fStyle=3, text="Size distribution\r"
		Notebook $nb fSize=-1, fStyle=-1, text="\r"
		Notebook $nb text="In this case, parameters from one level can be used to calculate log-normal size distribution for the pa"
		Notebook $nb text="rticles - which assumes the P is close to 4 (Porods law). The details are in the manuscript referenced o"
		Notebook $nb text="n the panel. Please, read it as wella smanual, where much more details are provided. \r"
		Notebook $nb text=" \r"
		Notebook $nb fSize=12, fStyle=3, text="Two Phase media (aka: Porous system):\r"
		Notebook $nb fSize=-1, fStyle=-1
		Notebook $nb text="This is copied from the manuscript by Dale Schaefer … For details, please, check the manuscript… It is a"
		Notebook $nb text="pplicable for two-phase systems which at high-Q satisfy Porod's law (power law slope = -4, Porod's law i"
		Notebook $nb text="s valid). \r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="Input and controls", fStyle=-1
		Notebook $nb text=": Top part (above lines with reference and Comments on validity) is for input. All numbers here should b"
		Notebook $nb text="e known and provided by user. Anything below the two text lines are fields with calculated values. Note,"
		Notebook $nb text=" that the results vary depending on what can be calculated from the input data provided. Make sure that "
		Notebook $nb text="assumptions about validity of data (calibration, quality of G and Rg, Power law slope = - 4 (Porod's law"
		Notebook $nb text=" valid) when needed) are satisfied. \r"
		Notebook $nb text="Note, these models can be evaluated also for combination of Unified levels… Only single level or “All” i"
		Notebook $nb text="s allowed. If “All” is used, Porod constant from level 1 is used, but invariant is calculated from all l"
		Notebook $nb text="evels together… \r"
		Notebook $nb text="You can use the button to open Scattering contrast calculator. ", fStyle=1, text="IMPORTANT", fStyle=-1
		Notebook $nb text=": ", fStyle=4
		Notebook $nb text="this tool uses scattering length density per gram of materials. This is kind of unique, I have extended "
		Notebook $nb text="the Scattering contrast calculator to calculate these values. Please, NOTE this… \r"
		Notebook $nb fStyle=-1, text="\r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="TwoPhaseSys1", fStyle=-1
		Notebook $nb text=":  Density of both phases and sample bulk density and B/Q known. rho is calculated \r"
		Notebook $nb text="This approach can be applied when the data are not measured on an absolute scale, but sample densities a"
		Notebook $nb text="re known and the data cover a sufficient q range to determine the ratio B/Q.  In this case, the porosity"
		Notebook $nb text=" is calculated from the densities, and Sv is calculated from B.  The chord lengths are calculated from p"
		Notebook $nb text="hi and Sv. \r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="TwoPhaseSys2", fStyle=-1, text=" : densities, contrast and B known. phi is calculated \r"
		Notebook $nb text="This approach applies where the data are on an absolute intensity but the low q data are lacking so Q is"
		Notebook $nb text=" not known.  The sample density must be known so that phi can be calculated.  \r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="TwoPhaseSys3", fStyle=-1
		Notebook $nb text=" : Bulk density sample, SLD [per gram], B and Invariant known. Minority phase density is calculated \r"
		Notebook $nb text="This approach is similar to approach 2 but the data cover a sufficient q range to calculate Qv.  For por"
		Notebook $nb text="ous materials where one of the two phases is air, SLD is calculated easily,  and if the SLD of the pore "
		Notebook $nb text="material is not zero, an iterative process is applied to calculate SLD.  The calculated SLD is then used"
		Notebook $nb text=" to calculate Sv.\r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="TwoPhaseSys4", fStyle=-1
		Notebook $nb text=". Contrast (SLD and density for both materials), B and Qv known\r"
		Notebook $nb text="This approach requires valid scattering data on absolute scale.  The scattering data must be valid over "
		Notebook $nb text="a sufficient q range to assure that Qv is accurate. This approach does not require the sample density, b"
		Notebook $nb text="ut the chemical composition of the struts must be known.  In addition this approach does require the com"
		Notebook $nb text="plete scattering profile on an absolute scale.\r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="TwoPhaseSys5 ", fStyle=-1, text="and", fStyle=1, text=" TwoPhaseSys6", fStyle=-1
		Notebook $nb text=". Particulate analysis, not published in manuscript. \r"
		Notebook $nb text="There are two more methods provided to me by Dale Schaefer, which are not published in the manuscript. T"
		Notebook $nb text="hey assume we can model the material as systems of particles and take two different methods to calculate"
		Notebook $nb text=" particle density. \r"
		Notebook $nb text="          \r"
		Notebook $nb text="Note, that there are differences in what needs to be known. Method 6 requires knowledge of contrast, whi"
		Notebook $nb text="le the method 5 does not, while method 5 requires knowledge of sample bulk density… \r"
		Notebook $nb text=" \r"
	endif
end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
///          Confidence evaluation code
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

Function IR1A_ConfidenceEvaluation()
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit
	//SVAR ConfEvListOfParameters=root:Packages:Irena_UnifFit:ConfEvListOfParameters
	//NVAR NumberOfLevels= root:Packages:Irena_UnifFit:NumberOfLevels
	//Build list of paramters which user was fitting, and therefore we can analyze stability for them
	//IR1A_ConfEvalBuildListOfParams()
	IR1A_ConfEvResetList()
	DoWindow IR1A_ConfEvaluationPanel
	if(!V_Flag)
		IR1A_ConfEvaluationPanelF()
	else
		DoWindow/F IR1A_ConfEvaluationPanel
	endif
	IR1_CreateResultsNbk()
	setDataFolder OldDf
end

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

Function IR1A_ConfEvaluationPanelF() 
	PauseUpdate    		// building window...
	NewPanel /K=1/W=(405,136,793,600) as "Unified Uncertainity Evaluation"
	DoWIndow/C IR1A_ConfEvaluationPanel
	//ShowTools/A
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 3,textrgb= (1,4,52428)
	DrawText 60,29,"Parameter Uncertainity Evaluation "
	SVAR ConEvSelParameter=root:Packages:Irena_UnifFit:ConEvSelParameter
	PopupMenu SelectParameter,pos={8,59},size={163,20},proc=IR1A_ConfEvPopMenuProc,title="Select parameter  "
	PopupMenu SelectParameter,help={"Select parameter to evaluate, it had to be fitted"}
	PopupMenu SelectParameter,popvalue=ConEvSelParameter,value= #"IR1A_ConfEvalBuildListOfParams()"
	//PopupMenu SelectParameter,mode=1,popvalue="Level1Rg",value= #"root:Packages:Irena_UnifFit:ConfEvListOfParameters"
	SetVariable ParameterMin,pos={15,94},size={149,14},bodyWidth=100,title="Min value"
	SetVariable ParameterMin,value= root:Packages:Irena_UnifFit:ConfEvMinVal
	SetVariable ParameterMax,pos={13,117},size={151,14},bodyWidth=100,title="Max value"
	SetVariable ParameterMax,value= root:Packages:Irena_UnifFit:ConfEvMaxVal
	SetVariable ParameterNumSteps,pos={192,103},size={153,14},bodyWidth=100,title="Num Steps"
	SetVariable ParameterNumSteps,value= root:Packages:Irena_UnifFit:ConfEvNumSteps
	SVAR Method = root:Packages:Irena_UnifFit:ConEvMethod
	PopupMenu Method,pos={70,150},size={212,20},proc=IR1A_ConfEvPopMenuProc,title="Method   "
	PopupMenu Method,help={"Select method to be used for analysis"}
	PopupMenu Method,mode=1,popvalue=Method,value= #"\"Sequential, fix param;Sequential, reset, fix param;Centered, fix param;Random, fix param;Random, fit param;Vary data, fit params;\""
	checkbox AutoOverwrite pos={20,180}, title="Automatically overwrite prior results?", variable=root:Packages:Irena_UnifFit:ConfEvAutoOverwrite
	Checkbox AutoOverwrite help={"Check to avoid being asked if you want to overwrite prior results"}
	checkbox ConfEvAutoCalcTarget pos={20,200},title="Calculate ChiSq range?", variable=root:Packages:Irena_UnifFit:ConfEvAutoCalcTarget
	Checkbox ConfEvAutoCalcTarget help={"Check to calculate the ChiSquae range"}, proc=IR1A_ConfEvalCheckProc
	checkbox ConfEvFixRanges pos={260,180}, title="Fix fit limits?", variable=root:Packages:Irena_UnifFit:ConfEvFixRanges
	Checkbox ConfEvFixRanges help={"Check to avoid being asked if you want to fix ranges during analysis"}
	NVAR tmpVal=root:Packages:Irena_UnifFit:ConfEvAutoCalcTarget
	SetVariable ConfEvTargetChiSqRange,pos={200,200}, limits={1,inf,0.003}, format="%1.4g", size={173,14},bodyWidth=80,title="ChiSq range target"
	SetVariable ConfEvTargetChiSqRange,value= root:Packages:Irena_UnifFit:ConfEvTargetChiSqRange, disable=2*tmpVal
	Button GetHelp,pos={284,37},size={90,20},proc=IR1A_ConfEvButtonProc,title="Get Help"
	Button AnalyzeSelParam,pos={18,225},size={150,20},proc=IR1A_ConfEvButtonProc,title="Analyze selected Parameter"
	Button AddSetToList,pos={187,225},size={150,20},proc=IR1A_ConfEvButtonProc,title="Add  Parameter to List"
	Button AnalyzeListOfParameters,pos={18,250},size={150,20},proc=IR1A_ConfEvButtonProc,title="Analyze list of Parameters"
	Button ResetList,pos={187,250},size={150,20},proc=IR1A_ConfEvButtonProc,title="Reset List"
	Button RecoverFromAbort,pos={18,430},size={150,20},proc=IR1A_ConfEvButtonProc,title="Recover from abort"
EndMacro

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
Function IR1A_ConfEvalCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			SetVariable ConfEvTargetChiSqRange,win= IR1A_ConfEvaluationPanel, disable=2*checked
			if(checked)
				IR1A_ConfEvalCalcChiSqTarget()
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
Function IR1A_ConfEvalCalcChiSqTarget()
	NVAR ConfEvAutoCalcTarget=root:Packages:Irena_UnifFit:ConfEvAutoCalcTarget
	NVAR ConfEvTargetChiSqRange = root:Packages:Irena_UnifFit:ConfEvTargetChiSqRange
	DoWIndow IR1_LogLogPlotU
	if(V_Flag&&ConfEvAutoCalcTarget)
		variable startRange, endRange, Allpoints
		startRange=pcsr(A,"IR1_LogLogPlotU")
		endRange=pcsr(B,"IR1_LogLogPlotU")
		Allpoints = abs(endRange - startRange)
	//	ConfEvTargetChiSqRange = Allpoints
		
		NVAR NumberOfLevels= root:Packages:Irena_UnifFit:NumberOfLevels	
		string ParamNames="Rg;G;P;B;ETA;Pack;"
		variable i, j, NumFItVals
		NumFItVals=0
		NVAR FitSASBackground=root:Packages:Irena_UnifFit:FitSASBackground
		if(FitSASBackground)
			NumFItVals+=1
		endif
		For(i=1;i<=NumberOfLevels;i+=1)
			For(j=0;j<ItemsInList(ParamNames);j+=1)
				NVAR CurPar = $("root:Packages:Irena_UnifFit:"+"Level"+num2str(i)+"Fit"+stringFromList(j,ParamNames))
				if(CurPar)
					NumFItVals+=1
				endif
			endfor
		endfor	
		//print "Found "+num2str(NumFItVals)+" fitted parameters"
		//method I tried...
		//ConfEvTargetChiSqRange = Allpoints/(Allpoints - NumFItVals)
		//ConfEvTargetChiSqRange = (round(1000*ConfEvTargetChiSqRange))/1000
		//method from Mateus
		variable DF = Allpoints - NumFItVals - 1		//DegreesOfFreedom
		variable parY0 = 1.01431
		variable parA1=0.05621
		variable parT1=117.48129
		variable parA2=0.0336
		variable parT2=737.73587
		variable parA3=0.10412
		variable parT3=23.25466
		ConfEvTargetChiSqRange = parY0 + parA1*exp(-DF/parT1) + parA2*exp(-DF/parT2) + parA3*exp(-DF/parT3)
		ConfEvTargetChiSqRange = (round(10000*ConfEvTargetChiSqRange))/10000
		
	endif
	return ConfEvTargetChiSqRange
end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************


Function/S IR1A_ConfEvalBuildListOfParams()
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit
	variable i,j
	SVAR ConfEvListOfParameters=root:Packages:Irena_UnifFit:ConfEvListOfParameters
	NVAR NumberOfLevels= root:Packages:Irena_UnifFit:NumberOfLevels
	//Build list of paramters which user was fitting, and therefore we can analyze stability for them
	
	string ParamNames="Rg;G;P;B;ETA;Pack;"
	ConfEvListOfParameters=""
	string tempName
	For(i=1;i<=NumberOfLevels;i+=1)
		For(j=0;j<ItemsInList(ParamNames);j+=1)
			tempName="Level"+num2str(i)+stringFromList(j,ParamNames)
			NVAR CurPar = $("root:Packages:Irena_UnifFit:"+tempName)
			NVAR FitCurPar =  $("root:Packages:Irena_UnifFit:"+"Level"+num2str(i)+"Fit"+stringFromList(j,ParamNames))
			if(FitCurPar)
				ConfEvListOfParameters+=tempName+";"
			endif
		endfor
	endfor	
	//print ConfEvListOfParameters
	SVAR Method = root:Packages:Irena_UnifFit:ConEvMethod
	SVAR ConEvSelParameter=root:Packages:Irena_UnifFit:ConEvSelParameter
	if(strlen(Method)<5)
		Method = "Sequential, fix param"
	endif
	ConEvSelParameter = stringFromList(0,ConfEvListOfParameters)
	IR1A_ConEvSetValues(ConEvSelParameter)
	setDataFolder OldDf
	return ConfEvListOfParameters+"UncertainityEffect;"
end

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
Function IR1A_ConEvSetValues(popStr)
	string popStr
		SVAR ConEvSelParameter=root:Packages:Irena_UnifFit:ConEvSelParameter
		ConEvSelParameter = popStr
		NVAR/Z CurPar = $("root:Packages:Irena_UnifFit:"+ConEvSelParameter)
		if(!NVAR_Exists(CurPar))
			//something wrong here, bail out
			return 0
		endif
		NVAR CurparLL =  $("root:Packages:Irena_UnifFit:"+ConEvSelParameter+"LowLimit")
		NVAR CurparHL =  $("root:Packages:Irena_UnifFit:"+ConEvSelParameter+"HighLimit")
		NVAR ConfEvMinVal =  root:Packages:Irena_UnifFit:ConfEvMinVal
		NVAR ConfEvMaxVal =  root:Packages:Irena_UnifFit:ConfEvMaxVal
		NVAR ConfEvNumSteps =  root:Packages:Irena_UnifFit:ConfEvNumSteps
		if(ConfEvNumSteps<3)
			ConfEvNumSteps=20
		endif
		if(stringMatch(ConEvSelParameter,"*Rg"))
			ConfEvMinVal = 0.8*CurPar
			ConfEvMaxVal = 1.2 * Curpar
		elseif(stringMatch(ConEvSelParameter,"*P"))
			ConfEvMinVal = 0.95*CurPar
			ConfEvMaxVal = 1.05 * Curpar
		elseif(stringMatch(ConEvSelParameter,"*G"))
			ConfEvMinVal = 0.5*CurPar
			ConfEvMaxVal = 2* Curpar
		elseif(stringMatch(ConEvSelParameter,"*B"))
			ConfEvMinVal = 0.5*CurPar
			ConfEvMaxVal = 2* Curpar
		elseif(stringMatch(ConEvSelParameter,"*Eta"))
			ConfEvMinVal = 0.9*CurPar
			ConfEvMaxVal = 1.1* Curpar
		elseif(stringMatch(ConEvSelParameter,"*Pack"))
			ConfEvMinVal = 0.9*CurPar
			ConfEvMaxVal = 1.1* Curpar
		endif
		//check limits...
		if(CurparLL>ConfEvMinVal)
			ConfEvMinVal = 1.01*CurparLL
		endif
		if(CurparHL<ConfEvMaxVal)
			ConfEvMaxVal = 0.99 * CurparHL
		endif

end

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

Function IR1A_ConfEvPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(stringMatch(pa.ctrlName,"SelectParameter"))
				if(stringmatch(popStr,"UncertainityEffect"))
					SVAR Method = root:Packages:Irena_UnifFit:ConEvMethod
					Method = "Vary data, fit params"
					SetVariable ParameterMin, win=IR1A_ConfEvaluationPanel, disable=1
					SetVariable ParameterMax, win=IR1A_ConfEvaluationPanel, disable=1
					PopupMenu Method, win=IR1A_ConfEvaluationPanel, mode=6
					IR1A_ConEvSetValues(popStr)
		 		else
					SetVariable ParameterMin, win=IR1A_ConfEvaluationPanel, disable=0
					SetVariable ParameterMax, win=IR1A_ConfEvaluationPanel, disable=0
					SVAR Method = root:Packages:Irena_UnifFit:ConEvMethod
					PopupMenu Method, win=IR1A_ConfEvaluationPanel, mode=1
					Method = "Sequential, fix param"
					IR1A_ConEvSetValues(popStr)
				endif
			endif
			if(stringMatch(pa.ctrlname,"Method"))
				//here we do what is needed
				SVAR Method = root:Packages:Irena_UnifFit:ConEvMethod
				Method = popStr
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

Function IR1A_ConfEvButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	SVAR SampleFullName=root:Packages:Irena_UnifFit:DataFolderName
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringMatch(ba.ctrlName,"GetHelp"))
				//Generate help 
				IR1A_ConfEvHelp()
			endif
			if(stringMatch(ba.ctrlName,"AnalyzeSelParam"))
				//analyze this parameter 
				SVAR ParamName = root:Packages:Irena_UnifFit:ConEvSelParameter
				SVAR Method = root:Packages:Irena_UnifFit:ConEvMethod
				NVAR MinValue =root:Packages:Irena_UnifFit:ConfEvMinVal
				NVAR MaxValue =root:Packages:Irena_UnifFit:ConfEvMaxVal
				NVAR NumSteps =root:Packages:Irena_UnifFit:ConfEvNumSteps
				IR1_AppendAnyText("Evaluated sample :"+StringFromList(ItemsInList(SampleFullName,":")-1,SampleFullName,":"), 1)	
				IR1A_ConEvEvaluateParameter(ParamName,MinValue,MaxValue,NumSteps,Method)
			endif
			if(stringMatch(ba.ctrlName,"AddSetToList"))
				//add this parameter to list
				IR1A_ConfEvAddToList()
			endif
			if(stringMatch(ba.ctrlName,"ResetList"))
				//add this parameter to list
				IR1A_ConfEvResetList()
			endif
			if(stringMatch(ba.ctrlName,"AnalyzeListOfParameters"))
				//analyze list of parameters
				IR1_AppendAnyText("Evaluated sample :"+StringFromList(ItemsInList(SampleFullName,":")-1,SampleFullName,":"), 1)	
				IR1A_ConfEvAnalyzeList()
			endif
			if(stringMatch(ba.ctrlName,"RecoverFromAbort"))
				//Recover from abort
				//print ("root:ConfidenceEvaluation:"+possiblyquoteName(StringFromList(ItemsInList(SampleFullName,":")-1,SampleFullName,":")))
				IR1A_ConEvRestoreBackupSettings("root:ConfidenceEvaluation:"+possiblyquoteName(StringFromList(ItemsInList(SampleFullName,":")-1,SampleFullName,":")))
			endif


			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
Function IR1A_ConfEvResetList()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit
	DoWIndow IR1A_ConfEvaluationPanel
	if(V_Flag)
		ControlInfo /W=IR1A_ConfEvaluationPanel  ListOfParamsToProcess
		if(V_Flag==11)
			KillControl /W=IR1A_ConfEvaluationPanel  ListOfParamsToProcess	
		endif
	endif
	Wave/Z ConEvParamNameWv
	Wave/Z ConEvMethodWv
	Wave/Z ConEvMinValueWv
	Wave/Z ConEvMaxValueWv
	Wave/Z ConEvNumStepsWv
	Wave/Z ConEvListboxWv
	SVAR Method = root:Packages:Irena_UnifFit:ConEvMethod
	Method = "Sequential, fix param"
	
	Killwaves/Z ConEvParamNameWv, ConEvMethodWv, ConEvMinValueWv, ConEvMaxValueWv, ConEvNumStepsWv, ConEvListboxWv
	setDataFolder oldDf
end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
static Function IR1A_ConfEvAnalyzeList()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit
	DoWIndow IR1A_ConfEvaluationPanel
	if(!V_Flag)
		abort
	endif
	Wave/T/Z ConEvParamNameWv
	if(!WaveExists(ConEvParamNameWv))
		abort "List of parameters to process does not exist"
	endif
	Wave/T ConEvMethodWv
	Wave ConEvMinValueWv
	Wave ConEvMaxValueWv
	Wave ConEvNumStepsWv
	Wave ConEvListboxWv
	variable i
		
		SVAR ParamName = root:Packages:Irena_UnifFit:ConEvSelParameter
		SVAR Method = root:Packages:Irena_UnifFit:ConEvMethod
		NVAR MinValue =root:Packages:Irena_UnifFit:ConfEvMinVal
		NVAR MaxValue =root:Packages:Irena_UnifFit:ConfEvMaxVal
		NVAR NumSteps =root:Packages:Irena_UnifFit:ConfEvNumSteps
	
	For(i=0;i<numpnts(ConEvParamNameWv);i+=1)
		ParamName=ConEvParamNameWv[i]
		Method=ConEvMethodWv[i]
		MinValue=ConEvMinValueWv[i]
		MaxValue=ConEvMaxValueWv[i]
		NumSteps=ConEvNumStepsWv[i]
		print "Evaluating stability of "+ParamName
		IR1A_ConEvEvaluateParameter(ParamName,MinValue,MaxValue,NumSteps,Method)
	endfor

	DoWIndow IR1A_ConfEvaluationPanel
	if(V_Flag)
		DoWIndow/F IR1A_ConfEvaluationPanel
	endif
	
	setDataFolder oldDf
end



//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
static Function IR1A_ConfEvAddToList()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit
	SVAR ParamName = root:Packages:Irena_UnifFit:ConEvSelParameter
	SVAR Method = root:Packages:Irena_UnifFit:ConEvMethod
	NVAR MinValue =root:Packages:Irena_UnifFit:ConfEvMinVal
	NVAR MaxValue =root:Packages:Irena_UnifFit:ConfEvMaxVal
	NVAR NumSteps =root:Packages:Irena_UnifFit:ConfEvNumSteps
		
	Wave/Z/T ConEvParamNameWv=root:Packages:Irena_UnifFit:ConEvParamNameWv
	if(!WaveExists(ConEvParamNameWv))
		make/O/N=1/T ConEvParamNameWv, ConEvMethodWv, ConEvListboxWv
		make/O/N=1 ConEvMinValueWv, ConEvMaxValueWv, ConEvNumStepsWv
	else
		redimension/N=(numpnts(ConEvParamNameWv)+1) ConEvParamNameWv, ConEvMethodWv, ConEvListboxWv
		redimension/N=(numpnts(ConEvParamNameWv)+1)  ConEvMinValueWv, ConEvMaxValueWv, ConEvNumStepsWv
	endif
	ConEvParamNameWv[numpnts(ConEvParamNameWv)-1]=ParamName
	ConEvMethodWv[numpnts(ConEvParamNameWv)-1]=Method
	ConEvMinValueWv[numpnts(ConEvParamNameWv)-1]=MinValue
	ConEvMaxValueWv[numpnts(ConEvParamNameWv)-1]=MaxValue
	ConEvNumStepsWv[numpnts(ConEvParamNameWv)-1]=NumSteps
	ConEvListboxWv[numpnts(ConEvParamNameWv)-1]=ParamName+": "+Method+";Min="+num2str(MinValue)+";Max="+num2str(MaxValue)+"Steps="+num2str(NumSteps)
	
	ControlInfo /W=IR1A_ConfEvaluationPanel  ListOfParamsToProcess
	if(V_Flag!=11)
		ListBox ListOfParamsToProcess win=IR1A_ConfEvaluationPanel, pos={10,280}, size={370,140}, mode=0
		ListBox ListOfParamsToProcess listWave=root:Packages:Irena_UnifFit:ConEvListboxWv
		ListBox ListOfParamsToProcess help={"This is list of parameters selected to be processed"}	
	endif
	setDataFolder oldDf
end


//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
static function IR1A_ConEvFixParamsIfNeeded()

	NVAR ConfEvFixRanges = root:Packages:Irena_UnifFit:ConfEvFixRanges
	if(ConfEvFixRanges)
		IR1A_FixLimits()
	endif
end 

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
static Function IR1A_ConEvEvaluateParameter(ParamName,MinValue,MaxValue,NumSteps,Method)
	Variable MinValue,MaxValue,NumSteps
	String ParamName,Method
	

	variable LevelUsed=str2num(ParamName[5])
	if(numtype(LevelUsed)==0 && LevelUsed>0 && LevelUsed<6)
		TabControl DistTabs win=IR1A_ControlPanel, value=(LevelUsed-1)
		IR1A_TabPanelControl("",LevelUsed-1)
	endif

	KillWIndow/Z ChisquaredAnalysis
 	KillWIndow/Z ChisquaredAnalysis2
 	//create folder where we dump this thing...
	NewDataFolder/O/S root:ConfidenceEvaluation
	SVAR SampleFullName=root:Packages:Irena_UnifFit:DataFolderName
	NVAR ConfEvAutoOverwrite = root:Packages:Irena_UnifFit:ConfEvAutoOverwrite
	string Samplename=StringFromList(ItemsInList(SampleFullName,":")-1,SampleFullName,":")
	SampleName=IN2G_RemoveExtraQuote(Samplename,1,1)
	NewDataFolder /S/O $(Samplename)
	Wave/Z/T BackupParamNames
	if(checkName(ParamName,11)!=0 && !ConfEvAutoOverwrite)
		DoALert /T="Folder Name Conflict" 1, "Folder with name "+ParamName+" found, do you want to overwrite prior Analyze uncertainity / Confidence Evaluation results?"
		if(!V_Flag)
			abort
		endif
	endif
	if(!WaveExists(BackupParamNames))
		IR1A_ConEvBackupCurrentSettings(GetDataFolder(1))
		print "Stored setting in case of abort, this can be reset by button Reset from abort"
	endif
	NewDataFolder /S/O $(ParamName)
	string BackupFilesLocation=GetDataFolder(1)
	IR1A_ConEvBackupCurrentSettings(BackupFilesLocation)
	//calculate chiSquare target if users asks for it..
	IR1A_ConfEvalCalcChiSqTarget()
	NVAR SkipFitControlDialog=root:Packages:Irena_UnifFit:SkipFitControlDialog
	variable oldSkipFitControlDialog = SkipFitControlDialog
	SkipFitControlDialog = 1
	NVAR ConfEvAutoCalcTarget=root:Packages:Irena_UnifFit:ConfEvAutoCalcTarget
	NVAR ConfEvTargetChiSqRange = root:Packages:Irena_UnifFit:ConfEvTargetChiSqRange
	variable i, currentParValue, tempi
	make/O/N=0  $(ParamName+"ChiSquare")
	Wave ChiSquareValues=$(ParamName+"ChiSquare")
	NVAR AchievedChisq = root:Packages:Irena_UnifFit:AchievedChisq
	variable SortForAnalysis=0
	variable FittedParameter=0


	if(stringMatch(ParamName,"UncertainityEffect"))
		if(stringMatch(Method,"Vary data, fit params"))
			Wave OriginalIntensity = root:Packages:Irena_UnifFit:OriginalIntensity
			Wave OriginalError = root:Packages:Irena_UnifFit:OriginalError
			Duplicate/O OriginalIntensity, ConEvIntensityBackup
			For(i=0;i<NumSteps+1;i+=1)
				OriginalIntensity = ConEvIntensityBackup + gnoise(OriginalError[p])
				IR1A_ConEvFixParamsIfNeeded()
				IR1A_InputPanelButtonProc("DoFittingSkipReset")
				Wave/T CoefNames=root:Packages:Irena_UnifFit:CoefNames
				Wave ValuesAfterFit=root:Packages:Irena_UnifFit:W_coef
				Wave ValuesBeforeFit = root:Packages:Irena_UnifFit:CoefficientInput
				Duplicate/O CoefNames, ConfEvCoefNames
				Wave/Z ConfEvStartValues
				if(!WaveExists(ConfEvStartValues))
					Duplicate/O 	ValuesAfterFit, ConfEvEndValues
					Duplicate/O 	ValuesBeforeFit, ConfEvStartValues
				else
					Wave ConfEvStartValues
					Wave ConfEvEndValues
					redimension/N=(-1,i+1) ConfEvEndValues, ConfEvStartValues
					ConfEvStartValues[][i] = ValuesBeforeFit[p]
					ConfEvEndValues[][i] = ValuesAfterFit[p]
				endif
				redimension/N=(i+1) ChiSquareValues
				ChiSquareValues[i]=AchievedChisq
				DoUpdate
				sleep/s 1	
				IR1A_ConEvRestoreBackupSettings(BackupFilesLocation)		
			endfor	
			OriginalIntensity = ConEvIntensityBackup
			IR1A_ConEvRestoreBackupSettings(BackupFilesLocation)
			IR1A_ConEvAnalyzeEvalResults2(ParamName)
		endif	
	else		//parameter methods
		//Metod = "Sequential, fix param;Sequential, reset, fix param;Random, fix param;Random, fit param;"
		NVAR Param=$("root:Packages:Irena_UnifFit:"+ParamName)
		NVAR ParamFit=$("root:Packages:Irena_UnifFit:"+ParamName[0,5]+"Fit"+ParamName[6,inf])
		make/O/N=0 $(ParamName+"StartValue"), $(ParamName+"EndValue"), $(ParamName+"ChiSquare")
		Wave StartValues=$(ParamName+"StartValue")
		Wave EndValues=$(ParamName+"EndValue")
		variable StartHere=Param
		variable step=(MaxValue-MinValue)/(NumSteps)
		if(stringMatch(Method,"Sequential, fix param"))
			ParamFit=0
			For(i=0;i<NumSteps+1;i+=1)
				redimension/N=(i+1) StartValues, EndValues, ChiSquareValues
				currentParValue = MinValue+ i* step
				StartValues[i]=currentParValue
				Param = currentParValue
				IR1A_ConEvFixParamsIfNeeded()
				IR1A_InputPanelButtonProc("DoFittingSkipReset")
				EndValues[i]=Param
				ChiSquareValues[i]=AchievedChisq
				DoUpdate
				sleep/s 1
			endfor
			SortForAnalysis=0
			FittedParameter=0
		elseif(stringMatch(Method,"Sequential, reset, fix param"))
			ParamFit=0
			For(i=0;i<NumSteps+1;i+=1)
				redimension/N=(i+1) StartValues, EndValues, ChiSquareValues
				currentParValue = MinValue+ i* step
				StartValues[i]=currentParValue
				Param = currentParValue
				IR1A_ConEvFixParamsIfNeeded()
				IR1A_InputPanelButtonProc("DoFittingSkipReset")
				EndValues[i]=Param
				ChiSquareValues[i]=AchievedChisq
				DoUpdate
				sleep/s 1	
				IR1A_ConEvRestoreBackupSettings(BackupFilesLocation)		
			endfor
			SortForAnalysis=0
			FittedParameter=0
		elseif(stringMatch(Method,"Centered, fix param"))
			ParamFit=0
			tempi=0
			variable NumSteps2=Ceil(NumSteps/2)
			For(i=0;i<NumSteps2;i+=1)
				tempi+=1
				redimension/N=(tempi) StartValues, EndValues, ChiSquareValues
				currentParValue = StartHere - i* step
				StartValues[tempi-1]=currentParValue
				Param = currentParValue
				IR1A_ConEvFixParamsIfNeeded()
				IR1A_InputPanelButtonProc("DoFittingSkipReset")
				EndValues[tempi-1]=Param
				ChiSquareValues[tempi-1]=AchievedChisq
				DoUpdate
				sleep/s 1	
			endfor
			IR1A_ConEvRestoreBackupSettings(BackupFilesLocation)		
			For(i=0;i<NumSteps2;i+=1)		//and now 
				tempi+=1
				redimension/N=(tempi) StartValues, EndValues, ChiSquareValues
				currentParValue = StartHere + i* step
				StartValues[tempi-1]=currentParValue
				Param = currentParValue
				IR1A_ConEvFixParamsIfNeeded()
				IR1A_InputPanelButtonProc("DoFittingSkipReset")
				EndValues[tempi-1]=Param
				ChiSquareValues[tempi-1]=AchievedChisq
				DoUpdate
				sleep/s 1	
			endfor
			IR1A_ConEvRestoreBackupSettings(BackupFilesLocation)		
			SortForAnalysis=1
			FittedParameter=0
		elseif(stringMatch(Method,"Random, fix param"))
			ParamFit=0
			For(i=0;i<NumSteps+1;i+=1)
				redimension/N=(i+1) StartValues, EndValues, ChiSquareValues
				currentParValue = MinValue + (0.5+enoise(0.5))*(MaxValue-MinValue)
				StartValues[i]=currentParValue
				Param = currentParValue
				IR1A_ConEvFixParamsIfNeeded()
				IR1A_InputPanelButtonProc("DoFittingSkipReset")
				EndValues[i]=Param
				ChiSquareValues[i]=AchievedChisq
				DoUpdate
				sleep/s 1	
				//IR1A_ConEvRestoreBackupSettings(BackupFilesLocation)		
			endfor
			SortForAnalysis=1
			FittedParameter=0
		elseif(stringMatch(Method,"Random, fit param"))
			ParamFit=1
			For(i=0;i<NumSteps+1;i+=1)
				redimension/N=(i+1) StartValues, EndValues, ChiSquareValues
				currentParValue = MinValue + (0.5+enoise(0.5))*(MaxValue-MinValue)
				StartValues[i]=currentParValue
				Param = currentParValue
				IR1A_ConEvFixParamsIfNeeded()
				IR1A_InputPanelButtonProc("DoFittingSkipReset")
				EndValues[i]=Param
				ChiSquareValues[i]=AchievedChisq
				DoUpdate
				sleep/s 1	
				//IR1A_ConEvRestoreBackupSettings(BackupFilesLocation)		
			endfor	
			SortForAnalysis=1
			FittedParameter=1
		endif
		ParamFit=1
		IR1A_ConEvRestoreBackupSettings(BackupFilesLocation)
		IR1A_InputPanelButtonProc("GraphDistribution")
	
		IR1A_ConEvAnalyzeEvalResults(ParamName, SortForAnalysis,FittedParameter)
	endif	//end of parameters analysis
	SkipFitControlDialog = oldSkipFitControlDialog
	DoWIndow IR1A_ConfEvaluationPanel
	if(V_Flag)
		DoWIndow/F IR1A_ConfEvaluationPanel
	endif

end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

static Function IR1A_ConEvAnalyzeEvalResults2(ParamName)
	string ParamName
	print GetDataFOlder(1)
	SVAR SampleFullName=root:Packages:Irena_UnifFit:DataFolderName
	NVAR ConfEVNumSteps=root:Packages:Irena_UnifFit:ConfEVNumSteps
	Wave ConfEvStartValues=$("ConfEvStartValues")
	Wave ConfEvEndValues=$("ConfEvEndValues")
	Wave/T ConfEvCoefNames=$("ConfEvCoefNames")
	Wave ChiSquareValues=$(ParamName+"ChiSquare")
	
	variable i
	for(i=0;i<numpnts(ChiSquareValues);i+=1)
		if(ChiSquareValues[i]==0)
			ChiSquareValues[i]=NaN
		endif
	endfor
	
	KillWIndow/Z ChisquaredAnalysis
 	KillWIndow/Z ChisquaredAnalysis2
 	variable levellow, levelhigh

	IR1_CreateResultsNbk()
	//IR1_AppendAnyText("Analyzed sample "+SampleFullName, 1)	
	IR1_AppendAnyText("Effect of data uncertainities on variability of parameters", 2)
	IR1_AppendAnyText(SampleFullName, 2)	
	IR1_AppendAnyText("  ", 0)
	IR1_AppendAnyText("Run "+num2str(ConfEVNumSteps)+" fittings using data modified by random Gauss noise within \"Errors\" ", 2)
	IR1_AppendAnyText("To get following statistical results ", 0)
	wavestats/Q ChiSquareValues
	variable MeanChiSquare=V_avg
	variable StdDevChiSquare=V_sdev
	IR1_AppendAnyText("Chi-square values : \taverage = "+num2str(MeanChiSquare)+"\tst. dev. = "+num2str(StdDevChiSquare), 0)	

	variable j
	string tempStrName
	For(j=0;j<numpnts(ConfEvCoefNames);j+=1)
		tempStrName=ConfEvCoefNames[j]
		Duplicate/Free/R=[j][] ConfEvEndValues, tempWv
		wavestats/Q tempWv
		IR1_AppendAnyText(tempStrName+" : \taverage = "+num2str(V_avg)+"\tst. dev. = "+num2str(V_sdev), 0)	
		
	endfor
		 

end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

static Function IR1A_ConEvAnalyzeEvalResults(ParamName,SortForAnalysis,FittedParameter)
	string ParamName
	variable SortForAnalysis,FittedParameter
	
	NVAR ConfEvTargetChiSqRange = root:Packages:Irena_UnifFit:ConfEvTargetChiSqRange
	SVAR SampleFullName=root:Packages:Irena_UnifFit:DataFolderName
	Wave StartValues=$(ParamName+"StartValue")
	Wave EndValues=$(ParamName+"EndValue")
	Wave ChiSquareValues=$(ParamName+"ChiSquare")
	SVAR Method = root:Packages:Irena_UnifFit:ConEvMethod
	if(SortForAnalysis)
		Sort EndValues, EndValues, StartValues, ChiSquareValues
	endif
	
	variable i
	for(i=0;i<numpnts(ChiSquareValues);i+=1)
		if(ChiSquareValues[i]==0)
			ChiSquareValues[i]=NaN
		endif
	endfor
	
	KillWIndow/Z ChisquaredAnalysis
 	KillWIndow/Z ChisquaredAnalysis2
 	variable levellow, levelhigh

	if(FittedParameter)	//fitted parameter, chi-square analysis needs a bit different... 
		wavestats/Q ChiSquareValues
		variable MeanChiSquare=V_avg
		variable StdDevChiSquare=V_sdev
	
		Display/W=(35,44,555,335)/K=1 ChiSquareValues vs EndValues
		DoWindow/C/T ChisquaredAnalysis,ParamName+"Chi-squared analysis of "+SampleFullName
		Label left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Achieved Chi-squared"
		Label bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"End "+ParamName+" value"
		ModifyGraph mirror=1
		ModifyGraph mode=3,marker=19
		SetAxis left (V_avg-1.5*(V_avg-V_min)),(V_avg+1.5*(V_max-V_avg))
		
		wavestats/Q EndValues
		variable MeanEndValue=V_avg
		variable StdDevEndValue=V_sdev
		Display/W=(35,44,555,335)/K=1 EndValues vs StartValues
		DoWindow/C/T ChisquaredAnalysis2,ParamName+" reproducibility analysis of "+SampleFullName
		Label left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"End "+ParamName+" value"
		Label bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Start "+ParamName+" value"
		ModifyGraph mirror=1
		ModifyGraph mode=3,marker=19		
		variable TempDisplayRange=max(V_avg-V_min, V_max-V_avg)
		SetAxis left (V_avg-1.5*(TempDisplayRange)),(V_avg+1.5*(TempDisplayRange))
		duplicate/O ChiSquareValues, EndValuesGraphAvg, EndValuesGraphMin, EndValuesGraphMax
		EndValuesGraphAvg = V_avg
		EndValuesGraphMin = V_avg-V_sdev
		EndValuesGraphMax = V_avg+V_sdev
		Wave Level1RgStartValue
		AppendToGraph EndValuesGraphMax,EndValuesGraphMin,EndValuesGraphAvg vs Level1RgStartValue	
		ModifyGraph lstyle(EndValuesGraphMax)=1,rgb(EndValuesGraphMax)=(0,0,0)
		ModifyGraph lstyle(EndValuesGraphMin)=1,rgb(EndValuesGraphMin)=(0,0,0)
		ModifyGraph lstyle(EndValuesGraphAvg)=7,lsize(EndValuesGraphAvg)=2
		ModifyGraph rgb(EndValuesGraphAvg)=(0,0,0)
		TextBox/C/N=text0/F=0/A=LT "Average = "+num2str(V_avg)+"\rStandard deviation = "+num2str(V_sdev)+"\rMinimum = "+num2str(V_min)+", maximum = "+num2str(V_min)
	
		AutoPositionWindow/M=0/R=IR1A_ConfEvaluationPanel ChisquaredAnalysis
		AutoPositionWindow/M=0/R=ChisquaredAnalysis ChisquaredAnalysis2

		IR1_CreateResultsNbk()
//		IR1_AppendAnyText("Analyzed sample "+SampleFullName, 1)	
		IR1_AppendAnyText("Unified fit uncertainity of parameter "+ParamName, 2)
		IR1_AppendAnyText("  ", 0)
		IR1_AppendAnyText("Method used to evaluate parameter reproducibility: "+Method, 0)	
		//IR1_AppendAnyText("Minimum chi-squared found = "+num2str(V_min)+" for "+ParamName+"  = "+ num2str(EndValues[V_minLoc]), 0)
		//IR1_AppendAnyText("Range of "+ParamName+" in which the chi-squared < 1.037*"+num2str(V_min)+" is from "+num2str(levellow)+" to "+ num2str(levelhigh), 0)
		IR1_AppendAnyGraph("ChisquaredAnalysis")
		IR1_AppendAnyGraph("ChisquaredAnalysis2")
		IR1_AppendAnyText("  ", 0)
		IR1_CreateResultsNbk()
	
	else	//parameter fixed..		
		wavestats/q ChiSquareValues
		variable MinLocation=V_minLoc
		variable minValue=V_min
		Display/W=(35,44,555,335)/K=1 ChiSquareValues vs EndValues
		DoWindow/C/T ChisquaredAnalysis,ParamName+" Chi-squared analysis "
		Label left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Achieved Chi-squared"
		Label bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+ParamName+" value"
		ModifyGraph mirror=1
		ModifyGraph mode=3,marker=19
		//Findlevels/Q/N=2 ChiSquareValues, ConfEvTargetChiSqRange*V_min		//this is failing in some cases...
		//find lower level...
		Findlevel/P/Q/R=[MinLocation,0] ChiSquareValues, ConfEvTargetChiSqRange*V_min
		variable minNotFound=V_FLag
		variable minPLocation = ceil(V_levelX)
		//find higher level...
		Findlevel/P/Q/R=[MinLocation,numpnts(ChiSquareValues)-1] ChiSquareValues, ConfEvTargetChiSqRange*V_min
		variable maxNotFound=V_FLag
		variable maxPLocation = floor(V_levelX)
		
		if(maxNotFound && minNotFound)
			print  "The range of parameters analyzed for "+ParamName +" was not sufficiently large, code did not find large enough values for chi-squared"
			IR1_CreateResultsNbk()
//			IR1_AppendAnyText("Analyzed sample "+SampleFullName, 1)	
			IR1_AppendAnyText("Unified fit evaluation of parameter "+ParamName+" failed", 2)
			IR1_AppendAnyText("  ", 0)
			IR1_AppendAnyText("Method used to evaluate parameter stability: "+Method, 0)	
			IR1_AppendAnyText("Minimum chi-squared found = "+num2str(V_min)+" for "+ParamName+"  = "+ num2str(EndValues[V_minLoc]), 0)
			IR1_AppendAnyText("Range of "+ParamName+" in which the chi-squared < "+num2str(ConfEvTargetChiSqRange)+"*"+num2str(V_min)+" was not between "+num2str(EndValues[0])+" to "+ num2str(EndValues[inf]), 0)
			IR1_CreateResultsNbk()		
			IR1_AppendAnyText("  ", 0)
		else   
			Wave W_FindLevels
			levellow=EndValues[minPLocation]
			levelhigh=EndValues[maxPLocation]
			Tag/C/N=MinTagLL/F=0/L=2/TL=0/X=0.00/Y=30.00 $(nameofwave(ChiSquareValues)), minPLocation,"\\JCLow edge\r\\JC"+num2str(levellow)
			Tag/C/N=MinTagHL/F=0/L=2/TL=0/X=0.00/Y=30.00 $(nameofwave(ChiSquareValues)), maxPLocation,"\\JCHigh edge\r\\JC"+num2str(levelhigh)
			//Tag/C/N=MinTag/F=0/L=2/TL=0/X=0.00/Y=50.00 $(nameofwave(ChiSquareValues)), V_minLoc,"Minimum chi-squared = "+num2str(V_min)+"\rat "+ParamName+" = "+num2str(EndValues[V_minLoc])+"\rRange : "+num2str(levellow)+" to "+num2str(levelhigh)
			Tag/C/N=MinTag/F=0/L=2/TL=0/X=0.00/Y=50.00 $(nameofwave(ChiSquareValues)), V_minLoc,"Minimum chi-squared = "+num2str(V_min)+"\rat "+ParamName+" = "+num2str(EndValues[MinLocation])//+"\rRange : "+num2str(levellow)+" to "+num2str(levelhigh)
			AutoPositionWindow/M=0/R=IR1A_ConfEvaluationPanel ChisquaredAnalysis
			IR1_CreateResultsNbk()
	//		IR1_AppendAnyText("Analyzed sample "+SampleFullName, 1)	
			IR1_AppendAnyText("Unified fit evaluation of parameter "+ParamName, 2)
			IR1_AppendAnyText("  ", 0)
			IR1_AppendAnyText("Method used to evaluate parameter stability: "+Method, 0)	
			IR1_AppendAnyText("Minimum chi-squared found = "+num2str(minValue)+" for "+ParamName+"  = "+ num2str(EndValues[MinLocation]), 0)
			IR1_AppendAnyText("Range of "+ParamName+" in which the chi-squared < "+num2str(ConfEvTargetChiSqRange)+"*"+num2str(minValue)+" is from "+num2str(levellow)+" to "+ num2str(levelhigh), 0)
			IR1_AppendAnyText("           **************************************************     ", 0)
			IR1_AppendAnyText("\"Simplistic presentation\" for publications :    >>>>   "+ParamName+" =  "+IN2G_roundToUncertainity(EndValues[MinLocation], (levelhigh - levellow)/2,2),0)
			IR1_AppendAnyText("           **************************************************     ", 0)
			IR1_AppendAnyGraph("ChisquaredAnalysis")
			IR1_AppendAnyText("  ", 0)
			IR1_CreateResultsNbk()
		endif
	endif
end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

static Function IR1A_ConEvRestoreBackupSettings(BackupLocation)
	string BackupLocation
	//restores backup waves (names/values) for all parameters used in current folder
	DFref oldDf= GetDataFolderDFR()

	setDataFolder $(BackupLocation)
	Wave/T BackupParamNames
	Wave BackupParamValues
	variable i, j
	string tempName
	For(i=0;i<numpnts(BackupParamValues);i+=1)
			tempName=BackupParamNames[i]
			NVAR CurPar = $("root:Packages:Irena_UnifFit:"+tempName)
			CurPar = BackupParamValues[i]
	endfor	
	setDataFolder oldDf
	
end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

static Function IR1A_ConEvBackupCurrentSettings(BackupLocation)
	string BackupLocation
	//creates backup waves (names/values) for all parameters used in current folder
	DFref oldDf= GetDataFolderDFR()

	//create folder where we dump this thing...
	setDataFolder $(BackupLocation)
	NVAR NumberOfLevels= root:Packages:Irena_UnifFit:NumberOfLevels	
	string ParamNames="Rg;G;P;B;ETA;Pack;"
	make/O/N=1/T BackupParamNames
	make/O/N=1 BackupParamValues
	variable i, j
	string tempName
	BackupParamNames[0]="SASBackground"
	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	BackupParamValues=SASBackground
	For(i=1;i<=NumberOfLevels;i+=1)
		For(j=0;j<ItemsInList(ParamNames);j+=1)
			tempName="Level"+num2str(i)+stringFromList(j,ParamNames)
			NVAR CurPar = $("root:Packages:Irena_UnifFit:"+"Level"+num2str(i)+stringFromList(j,ParamNames))
			redimension/N=(numpnts(BackupParamValues)+1) BackupParamValues, BackupParamNames
			BackupParamNames[numpnts(BackupParamNames)-1]=tempName
			BackupParamValues[numpnts(BackupParamNames)-1]=CurPar
		endfor
	endfor	

	setDataFolder oldDf
	
end
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************


Function IR1A_ConfEvHelp()

	DoWindow ConfidenceEvaluationHelp
	if(V_Flag)
		DoWindow/F ConfidenceEvaluationHelp
	else
		String nb = "ConfidenceEvaluationHelp"
		NewNotebook/N=$nb/F=1/V=1/K=1/W=(444,66,960,820)
		Notebook $nb defaultTab=36, statusWidth=252
		Notebook $nb showRuler=1, rulerUnits=1, updating={1, 3600}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
		Notebook $nb ruler=Normal, fSize=14, fStyle=1, textRGB=(52428,1,1), text="Uncertainity evaluation for UF/Modeling parameters\r"
		Notebook $nb fSize=-1, fStyle=1, textRGB=(0,1,3), text="\r"
		Notebook $nb text="This tool is used to estimate uncertainities for the fitted parameters. "
		Notebook $nb text="It is likely that the right uncertainity is some combination of the two implemented methods - or the larger one...", fStyle=-1, text="\r"
		Notebook $nb fStyle=1, text="\r"
		Notebook $nb text="1. \"Uncertainity effect\" \r", fStyle=-1
		//Notebook $nb text="1. Sequential, fix param", fStyle=-1
		Notebook $nb text="Evaluates the influence of DATA uncertainities on uncertainity of Unified fit or Modeling parameter(s). "
		Notebook $nb text="Code varies Intensity data within user provided uncertainities (\"errors\"). All parameters currently selected for fitting are evaluted at once.\r"
		Notebook $nb fStyle=1, text="2. Uncertainity for individual parameters \r", fStyle=-1
		Notebook $nb text="Analysis of quality of fits achievable with tested parameter variation.  "
		Notebook $nb text="The tool will fix tested parameter within the user defined range and fit the other parameters to the data. Plot of achieved chi-squared as function of the fixed value of the tested parameter "
		Notebook $nb text="is used to estimate uncertainity. User needs to pick method of analysis as described below. User can analyze one parameter or create list of parameters and analyze them sequentially. "
		Notebook $nb text="This method is based on chapter 11 \"Testing the fit\" in \"Data Reduction and Error Analysis\" P. Bevington and D. K. Robinson, available here "
		Notebook $nb text="(http://hosting.astro.cornell.edu/academics/courses/astro3310/Books/Bevington_opt.pdf). The calculation of Chi-Square target is obtained by using data from table C4 "
		Notebook $nb text="in this book and approximating them with polynomial function for ease of calculation. Special thanks goes to Mateus Cardoso from LLNL (Brazil) who proposed this method. \r"
		Notebook $nb text="\r"
		Notebook $nb text="All parameters which are supposed to be varied during analysis must have \"Fit?\" checkbox checked before the tool si started. Correct fitting limits may be set or use \"Fix fit limits\" checkbox. "
		Notebook $nb text="Range of data for fitting must be selected correctly with cursors (Unified fit) or set for data with controls (Modeling). The code does not mo"
		Notebook $nb text="dify fitting range. \r"
		Notebook $nb text="\r"
		Notebook $nb text="For Modeling : note, that at this time the only offically supported mode is for using Single input data set. The logic for multiple data sets should work "
		Notebook $nb text="for \"Uncertainity effect\" but for the single parameter tests the results are untested. It may work, but if not - let me know... \r"
		Notebook $nb text="\r"
		Notebook $nb text="For each evaluated parameter the input is its name, range of values (Min/Max) to be stepped through and number "
		Notebook $nb text="of steps (default 20) to take. Depending on the type of parameter, different default Min/Max are generated for thi"
		Notebook $nb text="s analysis when parameter is selected. If the default for any parameters is systematically wrong, let me know and I'll fix it. \r"
		Notebook $nb text="\r"
		Notebook $nb text="You may need to play with fitting limits as it is likely there may be some fitting failures with wrong limits or using too large testing range. No attempt is made \r"
		Notebook $nb text="to gracefully recover from major fitting disasters. The main help is use of button \"Recover from abort\" if you have to abort the fittings.  \r"
		Notebook $nb text="\r"
		Notebook $nb text="After analysis is done, results are recorded in the ResultsNotebook and waves with results for further a"
		Notebook $nb text="nalysis are stored in root:ConfidenceEvaluation:<SampleName>:<Parametername>. Stored are waves names as"
		Notebook $nb text=" follows: <Parameter>ChiSquare, <Parameter>StartValue, <Parameter>EndValue. If the parameter is not fitt"
		Notebook $nb text="ed during evaluation Start and End values are the same. \r"
		Notebook $nb fStyle=1, text="\r"
		Notebook $nb text="Analysis of effect of data uncertainities (\"Uncertainity effect\")", fStyle=-1, text=":\r"
		Notebook $nb fStyle=1, text="Vary data, fit parameters", fStyle=-1
		Notebook $nb text=": Data are varied by adding to input intensity Gaussian noise with standard deviation equal to the unc"
		Notebook $nb text="rtainities provided by user (aka: \"Error data\"). No other scaling is done. "
		Notebook $nb text="All selected parameters are fitted selected number of times and statistics is generated in notebook.     \r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="Methods for analysis for individual parameters", fStyle=-1, text=":\r"
		Notebook $nb fStyle=1, text="1. Sequential, fix param", fStyle=-1
		Notebook $nb text=": Tested parameter is set to Min and all other parameters selected by user for fitting are fit"
		Notebook $nb text="ted. Chi-squared is recorded. Parameter is increased by step (Max-Min/NumberOfSteps) and fitting is done"
		Notebook $nb text=" again - using the result of the prior fit as starting condition.     \r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="2. Sequential, reset, fix param", fStyle=-1
		Notebook $nb text=": Tested parameter is set to Min and all other parameters selected by user for fitting  are fi"
		Notebook $nb text="tted. Chi-squared is recorded. Unified fit is reset to have the parameters which were set byu user before the evaluation"
		Notebook $nb text=" was started. Parameter is increased by step (Max-Min/NumberOfSteps) and fitting is done again - therefore using t"
		Notebook $nb text="he original user settings as the starting condition.  \r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="3. Centered, fix param", fStyle=-1
		Notebook $nb text=": Tested parameter is varied from start value towards Min, using previous fit result as starting condi"
		Notebook $nb text="tion. When Min is reached, the UF is reset to start position and parameter is varied up to Max"
		Notebook $nb text=". Chi-squared is recorded for each parameter value.\r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="4. Random, fix param", fStyle=-1
		Notebook $nb text=": User defined number of random values for the tested parameter are selected in the user defined  range of data"
		Notebook $nb text=" and for each the fit is performed while using the prior setting as starting condition. Chi-squared is r"
		Notebook $nb text="ecorded.\r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=1, text="5. Random, fit param", fStyle=-1
		Notebook $nb text=": User defined number of random starting values for the parameter are selected in the user defined range"
		Notebook $nb text=" of data and for each the fit is performed - including fitting this parameter - using prior setting as s"
		Notebook $nb text="tarting condition. Chi-squared is recorded as well as starting and ending parameter values. "
		Notebook $nb selection={startOfFile, startOfFile}, findText={"",1}
	endif

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//			start of original IR1_Unified_Fit_Fncts2
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_ConstructTheFittingCommand(skipreset)
	variable skipreset
	//here we need to construct the fitting command and prepare the data for fit...

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit
	

	NVAR UseNoLimits=root:Packages:Irena_UnifFit:UseNoLimits
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR FitSASBackground=root:Packages:Irena_UnifFit:FitSASBackground

//Level1 part	
	NVAR  Level1Rg=root:Packages:Irena_UnifFit:Level1Rg
	NVAR  Level1FitRg=root:Packages:Irena_UnifFit:Level1FitRg
	NVAR  Level1RgLowLimit=root:Packages:Irena_UnifFit:Level1RgLowLimit
	NVAR  Level1RgHighLimit =root:Packages:Irena_UnifFit:Level1RgHighLimit
	NVAR  Level1G=root:Packages:Irena_UnifFit:Level1G
	NVAR  Level1FitG=root:Packages:Irena_UnifFit:Level1FitG
	NVAR  Level1GLowLimit=root:Packages:Irena_UnifFit:Level1GLowLimit
	NVAR  Level1GHighLimit =root:Packages:Irena_UnifFit:Level1GHighLimit
	NVAR  Level1P=root:Packages:Irena_UnifFit:Level1P
	NVAR  Level1FitP=root:Packages:Irena_UnifFit:Level1FitP
	NVAR  Level1PLowLimit=root:Packages:Irena_UnifFit:Level1PLowLimit
	NVAR  Level1PHighLimit=root:Packages:Irena_UnifFit:Level1PHighLimit
	NVAR  Level1B=root:Packages:Irena_UnifFit:Level1B
	NVAR  Level1FitB=root:Packages:Irena_UnifFit:Level1FitB
	NVAR  Level1BLowLimit=root:Packages:Irena_UnifFit:Level1BLowLimit
	NVAR  Level1BHighLimit=root:Packages:Irena_UnifFit:Level1BHighLimit
	NVAR  Level1ETA=root:Packages:Irena_UnifFit:Level1ETA
	NVAR  Level1FitETA=root:Packages:Irena_UnifFit:Level1FitETA
	NVAR  Level1ETALowLimit =root:Packages:Irena_UnifFit:Level1ETALowLimit
	NVAR  Level1ETAHighLimit=root:Packages:Irena_UnifFit:Level1ETAHighLimit
	NVAR  Level1PACK=root:Packages:Irena_UnifFit:Level1PACK
	NVAR  Level1FitPACK=root:Packages:Irena_UnifFit:Level1FitPACK
	NVAR  Level1PACKLowLimit=root:Packages:Irena_UnifFit:Level1PACKLowLimit
	NVAR  Level1PACKHighLimit=root:Packages:Irena_UnifFit:Level1PACKHighLimit
	NVAR  Level1RgCO=root:Packages:Irena_UnifFit:Level1RgCO
	NVAR  Level1FitRgCO=root:Packages:Irena_UnifFit:Level1FitRgCO
	NVAR  Level1RgCOLowLimit=root:Packages:Irena_UnifFit:Level1RgCOLowLimit
	NVAR  Level1RgCOHighLimit=root:Packages:Irena_UnifFit:Level1RgCOHighLimit
	NVAR  Level1K=root:Packages:Irena_UnifFit:Level1K
	NVAR  Level1Corelations=root:Packages:Irena_UnifFit:Level1Corelations
	NVAR  Level1MassFractal=root:Packages:Irena_UnifFit:Level1MassFractal
	NVAR  Level1LinkRGCO=root:Packages:Irena_UnifFit:Level1LinkRGCO
	
//Level2 part	
	NVAR  Level2Rg=root:Packages:Irena_UnifFit:Level2Rg
	NVAR  Level2FitRg=root:Packages:Irena_UnifFit:Level2FitRg
	NVAR  Level2RgLowLimit=root:Packages:Irena_UnifFit:Level2RgLowLimit
	NVAR  Level2RgHighLimit =root:Packages:Irena_UnifFit:Level2RgHighLimit
	NVAR  Level2G=root:Packages:Irena_UnifFit:Level2G
	NVAR  Level2FitG=root:Packages:Irena_UnifFit:Level2FitG
	NVAR  Level2GLowLimit=root:Packages:Irena_UnifFit:Level2GLowLimit
	NVAR  Level2GHighLimit =root:Packages:Irena_UnifFit:Level2GHighLimit
	NVAR  Level2P=root:Packages:Irena_UnifFit:Level2P
	NVAR  Level2FitP=root:Packages:Irena_UnifFit:Level2FitP
	NVAR  Level2PLowLimit=root:Packages:Irena_UnifFit:Level2PLowLimit
	NVAR  Level2PHighLimit=root:Packages:Irena_UnifFit:Level2PHighLimit
	NVAR  Level2B=root:Packages:Irena_UnifFit:Level2B
	NVAR  Level2FitB=root:Packages:Irena_UnifFit:Level2FitB
	NVAR  Level2BLowLimit=root:Packages:Irena_UnifFit:Level2BLowLimit
	NVAR  Level2BHighLimit=root:Packages:Irena_UnifFit:Level2BHighLimit
	NVAR  Level2ETA=root:Packages:Irena_UnifFit:Level2ETA
	NVAR  Level2FitETA=root:Packages:Irena_UnifFit:Level2FitETA
	NVAR  Level2ETALowLimit =root:Packages:Irena_UnifFit:Level2ETALowLimit
	NVAR  Level2ETAHighLimit=root:Packages:Irena_UnifFit:Level2ETAHighLimit
	NVAR  Level2PACK=root:Packages:Irena_UnifFit:Level2PACK
	NVAR  Level2FitPACK=root:Packages:Irena_UnifFit:Level2FitPACK
	NVAR  Level2PACKLowLimit=root:Packages:Irena_UnifFit:Level2PACKLowLimit
	NVAR  Level2PACKHighLimit=root:Packages:Irena_UnifFit:Level2PACKHighLimit
	NVAR  Level2RgCO=root:Packages:Irena_UnifFit:Level2RgCO
	NVAR  Level2FitRgCO=root:Packages:Irena_UnifFit:Level2FitRgCO
	NVAR  Level2RgCOLowLimit=root:Packages:Irena_UnifFit:Level2RgCOLowLimit
	NVAR  Level2RgCOHighLimit=root:Packages:Irena_UnifFit:Level2RgCOHighLimit
	NVAR  Level2K=root:Packages:Irena_UnifFit:Level2K
	NVAR  Level2Corelations=root:Packages:Irena_UnifFit:Level2Corelations
	NVAR  Level2MassFractal=root:Packages:Irena_UnifFit:Level2MassFractal
	NVAR  Level2LinkRGCO=root:Packages:Irena_UnifFit:Level2LinkRGCO
//Level3 part	
	NVAR  Level3Rg=root:Packages:Irena_UnifFit:Level3Rg
	NVAR  Level3FitRg=root:Packages:Irena_UnifFit:Level3FitRg
	NVAR  Level3RgLowLimit=root:Packages:Irena_UnifFit:Level3RgLowLimit
	NVAR  Level3RgHighLimit =root:Packages:Irena_UnifFit:Level3RgHighLimit
	NVAR  Level3G=root:Packages:Irena_UnifFit:Level3G
	NVAR  Level3FitG=root:Packages:Irena_UnifFit:Level3FitG
	NVAR  Level3GLowLimit=root:Packages:Irena_UnifFit:Level3GLowLimit
	NVAR  Level3GHighLimit =root:Packages:Irena_UnifFit:Level3GHighLimit
	NVAR  Level3P=root:Packages:Irena_UnifFit:Level3P
	NVAR  Level3FitP=root:Packages:Irena_UnifFit:Level3FitP
	NVAR  Level3PLowLimit=root:Packages:Irena_UnifFit:Level3PLowLimit
	NVAR  Level3PHighLimit=root:Packages:Irena_UnifFit:Level3PHighLimit
	NVAR  Level3B=root:Packages:Irena_UnifFit:Level3B
	NVAR  Level3FitB=root:Packages:Irena_UnifFit:Level3FitB
	NVAR  Level3BLowLimit=root:Packages:Irena_UnifFit:Level3BLowLimit
	NVAR  Level3BHighLimit=root:Packages:Irena_UnifFit:Level3BHighLimit
	NVAR  Level3ETA=root:Packages:Irena_UnifFit:Level3ETA
	NVAR  Level3FitETA=root:Packages:Irena_UnifFit:Level3FitETA
	NVAR  Level3ETALowLimit =root:Packages:Irena_UnifFit:Level3ETALowLimit
	NVAR  Level3ETAHighLimit=root:Packages:Irena_UnifFit:Level3ETAHighLimit
	NVAR  Level3PACK=root:Packages:Irena_UnifFit:Level3PACK
	NVAR  Level3FitPACK=root:Packages:Irena_UnifFit:Level3FitPACK
	NVAR  Level3PACKLowLimit=root:Packages:Irena_UnifFit:Level3PACKLowLimit
	NVAR  Level3PACKHighLimit=root:Packages:Irena_UnifFit:Level3PACKHighLimit
	NVAR  Level3RgCO=root:Packages:Irena_UnifFit:Level3RgCO
	NVAR  Level3FitRgCO=root:Packages:Irena_UnifFit:Level3FitRgCO
	NVAR  Level3RgCOLowLimit=root:Packages:Irena_UnifFit:Level3RgCOLowLimit
	NVAR  Level3RgCOHighLimit=root:Packages:Irena_UnifFit:Level3RgCOHighLimit
	NVAR  Level3K=root:Packages:Irena_UnifFit:Level3K
	NVAR  Level3Corelations=root:Packages:Irena_UnifFit:Level3Corelations
	NVAR  Level3MassFractal=root:Packages:Irena_UnifFit:Level3MassFractal
	NVAR  Level3LinkRGCO=root:Packages:Irena_UnifFit:Level3LinkRGCO
//Level4 part	
	NVAR  Level4Rg=root:Packages:Irena_UnifFit:Level4Rg
	NVAR  Level4FitRg=root:Packages:Irena_UnifFit:Level4FitRg
	NVAR  Level4RgLowLimit=root:Packages:Irena_UnifFit:Level4RgLowLimit
	NVAR  Level4RgHighLimit =root:Packages:Irena_UnifFit:Level4RgHighLimit
	NVAR  Level4G=root:Packages:Irena_UnifFit:Level4G
	NVAR  Level4FitG=root:Packages:Irena_UnifFit:Level4FitG
	NVAR  Level4GLowLimit=root:Packages:Irena_UnifFit:Level4GLowLimit
	NVAR  Level4GHighLimit =root:Packages:Irena_UnifFit:Level4GHighLimit
	NVAR  Level4P=root:Packages:Irena_UnifFit:Level4P
	NVAR  Level4FitP=root:Packages:Irena_UnifFit:Level4FitP
	NVAR  Level4PLowLimit=root:Packages:Irena_UnifFit:Level4PLowLimit
	NVAR  Level4PHighLimit=root:Packages:Irena_UnifFit:Level4PHighLimit
	NVAR  Level4B=root:Packages:Irena_UnifFit:Level4B
	NVAR  Level4FitB=root:Packages:Irena_UnifFit:Level4FitB
	NVAR  Level4BLowLimit=root:Packages:Irena_UnifFit:Level4BLowLimit
	NVAR  Level4BHighLimit=root:Packages:Irena_UnifFit:Level4BHighLimit
	NVAR  Level4ETA=root:Packages:Irena_UnifFit:Level4ETA
	NVAR  Level4FitETA=root:Packages:Irena_UnifFit:Level4FitETA
	NVAR  Level4ETALowLimit =root:Packages:Irena_UnifFit:Level4ETALowLimit
	NVAR  Level4ETAHighLimit=root:Packages:Irena_UnifFit:Level4ETAHighLimit
	NVAR  Level4PACK=root:Packages:Irena_UnifFit:Level4PACK
	NVAR  Level4FitPACK=root:Packages:Irena_UnifFit:Level4FitPACK
	NVAR  Level4PACKLowLimit=root:Packages:Irena_UnifFit:Level4PACKLowLimit
	NVAR  Level4PACKHighLimit=root:Packages:Irena_UnifFit:Level4PACKHighLimit
	NVAR  Level4RgCO=root:Packages:Irena_UnifFit:Level4RgCO
	NVAR  Level4FitRgCO=root:Packages:Irena_UnifFit:Level4FitRgCO
	NVAR  Level4RgCOLowLimit=root:Packages:Irena_UnifFit:Level4RgCOLowLimit
	NVAR  Level4RgCOHighLimit=root:Packages:Irena_UnifFit:Level4RgCOHighLimit
	NVAR  Level4K=root:Packages:Irena_UnifFit:Level4K
	NVAR  Level4Corelations=root:Packages:Irena_UnifFit:Level4Corelations
	NVAR  Level4MassFractal=root:Packages:Irena_UnifFit:Level4MassFractal
	NVAR  Level4LinkRGCO=root:Packages:Irena_UnifFit:Level4LinkRGCO
//Level5 part	
	NVAR  Level5Rg=root:Packages:Irena_UnifFit:Level5Rg
	NVAR  Level5FitRg=root:Packages:Irena_UnifFit:Level5FitRg
	NVAR  Level5RgLowLimit=root:Packages:Irena_UnifFit:Level5RgLowLimit
	NVAR  Level5RgHighLimit =root:Packages:Irena_UnifFit:Level5RgHighLimit
	NVAR  Level5G=root:Packages:Irena_UnifFit:Level5G
	NVAR  Level5FitG=root:Packages:Irena_UnifFit:Level5FitG
	NVAR  Level5GLowLimit=root:Packages:Irena_UnifFit:Level5GLowLimit
	NVAR  Level5GHighLimit =root:Packages:Irena_UnifFit:Level5GHighLimit
	NVAR  Level5P=root:Packages:Irena_UnifFit:Level5P
	NVAR  Level5FitP=root:Packages:Irena_UnifFit:Level5FitP
	NVAR  Level5PLowLimit=root:Packages:Irena_UnifFit:Level5PLowLimit
	NVAR  Level5PHighLimit=root:Packages:Irena_UnifFit:Level5PHighLimit
	NVAR  Level5B=root:Packages:Irena_UnifFit:Level5B
	NVAR  Level5FitB=root:Packages:Irena_UnifFit:Level5FitB
	NVAR  Level5BLowLimit=root:Packages:Irena_UnifFit:Level5BLowLimit
	NVAR  Level5BHighLimit=root:Packages:Irena_UnifFit:Level5BHighLimit
	NVAR  Level5ETA=root:Packages:Irena_UnifFit:Level5ETA
	NVAR  Level5FitETA=root:Packages:Irena_UnifFit:Level5FitETA
	NVAR  Level5ETALowLimit =root:Packages:Irena_UnifFit:Level5ETALowLimit
	NVAR  Level5ETAHighLimit=root:Packages:Irena_UnifFit:Level5ETAHighLimit
	NVAR  Level5PACK=root:Packages:Irena_UnifFit:Level5PACK
	NVAR  Level5FitPACK=root:Packages:Irena_UnifFit:Level5FitPACK
	NVAR  Level5PACKLowLimit=root:Packages:Irena_UnifFit:Level5PACKLowLimit
	NVAR  Level5PACKHighLimit=root:Packages:Irena_UnifFit:Level5PACKHighLimit
	NVAR  Level5RgCO=root:Packages:Irena_UnifFit:Level5RgCO
	NVAR  Level5FitRgCO=root:Packages:Irena_UnifFit:Level5FitRgCO
	NVAR  Level5RgCOLowLimit=root:Packages:Irena_UnifFit:Level5RgCOLowLimit
	NVAR  Level5RgCOHighLimit=root:Packages:Irena_UnifFit:Level5RgCOHighLimit
	NVAR  Level5K=root:Packages:Irena_UnifFit:Level5K
	NVAR  Level5Corelations=root:Packages:Irena_UnifFit:Level5Corelations
	NVAR  Level5MassFractal=root:Packages:Irena_UnifFit:Level5MassFractal
	NVAR  Level5LinkRGCO=root:Packages:Irena_UnifFit:Level5LinkRGCO


	NVAR  Level1LinkB=root:Packages:Irena_UnifFit:Level1LinkB
	NVAR  Level2LinkB=root:Packages:Irena_UnifFit:Level2LinkB
	NVAR  Level3LinkB=root:Packages:Irena_UnifFit:Level3LinkB
	NVAR  Level4LinkB=root:Packages:Irena_UnifFit:Level4LinkB
	NVAR  Level5LinkB=root:Packages:Irena_UnifFit:Level5LinkB



	NVAR  SkipFitControlDialog=root:Packages:Irena_UnifFit:SkipFitControlDialog
	SVAR/Z AdditionalFittingConstraints
	if(!SVAR_Exists(AdditionalFittingConstraints))
		string/g AdditionalFittingConstraints
	endif


///now we can make various parts of the fitting routines...
//
	//First check the reasonability of all parameters

	IR1A_CorrectLimitsAndValues()
	if(UseNoLimits)			//this also fixes limits so user does not have to worry about them, since they are not being used for fitting anyway. 
		IR1A_FixLimits()
	endif

	//
	Make/D/N=0/O W_coef, LowLimit, HighLimit
	Make/T/N=0/O CoefNames, LowLimCoefName, HighLimCoefNames
	Make/D/O/T/N=0 T_Constraints, ParamNamesK
	T_Constraints=""
	CoefNames=""

	//the following was commnted out for unknown reason before 6/28/09 and rtherefore background could nto be fitted. 
	//fixed by JIL on this date... 
	if (FitSASBackground)		//are we fitting background?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK  //, T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SASBackground
		CoefNames[numpnts(CoefNames)-1]="SASBackground"
		LowLimit[numpnts(W_Coef)-1]=NaN
		HighLimit[numpnts(W_Coef)-1]=NaN
		LowLimCoefName[numpnts(CoefNames)-1]=""
		HighLimCoefNames[numpnts(CoefNames)-1]=""
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
	//	T_Constraints[0] = {"K"+num2str(numpnts(W_coef)-1)+" > 0"}
	endif
//Level1 part	
	if (Level1FitRg && NumberOfLevels>0)		//are we fitting distribution 1 Rg?
		if (Level1RgLowLimit > Level1Rg || Level1RgHighLimit < Level1Rg)
			abort "Level 1 Rg limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level1Rg
		LowLimit[numpnts(W_Coef)-1]=Level1RgLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level1RgHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level1Rg"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level1RgLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level1RgHighLimit)}		
	endif
	if (Level1FitG && NumberOfLevels>0)		//are we fitting distribution 1 location?
		if (Level1GLowLimit > Level1G || Level1GHighLimit < Level1G)
			abort "Level 1 G limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level1G
		LowLimit[numpnts(W_Coef)-1]=Level1GLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level1GHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level1G"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level1GLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level1GHighLimit)}		
	endif
	if (Level1FitP && NumberOfLevels>0)		//are we fitting distribution 1 location?
		if (Level1PLowLimit > Level1P || Level1PHighLimit < Level1P)
			abort "Level 1 P limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level1P
		CoefNames[numpnts(CoefNames)-1]="Level1P"
		LowLimit[numpnts(W_Coef)-1]=Level1PLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level1PHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level1PLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level1PHighLimit)}		
	endif
	if (Level1FitB && NumberOfLevels>0 && !(Level1LinkB))		//are we fitting distribution 1 B?
		if (Level1BLowLimit > Level1B || Level1BHighLimit < Level1B)
			abort "Level 1 B limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level1B
		LowLimit[numpnts(W_Coef)-1]=Level1BLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level1BHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level1B"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level1BLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level1BHighLimit)}		
	endif
	if (Level1FitETA && Level1Corelations && NumberOfLevels>0)		//are we fitting distribution 1 location?
		if (Level1ETALowLimit > Level1ETA || Level1ETAHighLimit < Level1ETA)
			abort "Level 1 ETA limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level1ETA
		LowLimit[numpnts(W_Coef)-1]=Level1ETALowLimit
		HighLimit[numpnts(W_Coef)-1]=Level1ETAHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level1ETA"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level1ETALowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level1ETAHighLimit)}		
	endif
	if (Level1FitPACK && Level1Corelations && NumberOfLevels>0)		//are we fitting distribution 1 location?
		if (Level1PACKLowLimit > Level1PACK || Level1PACKHighLimit < Level1PACK)
			abort "Level 1 PACK limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level1PACK
		CoefNames[numpnts(CoefNames)-1]="Level1PACK"
		LowLimit[numpnts(W_Coef)-1]=Level1PACKLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level1PACKHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level1PACKLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level1PACKHighLimit)}		
	endif
	if (Level1FitRGCO && NumberOfLevels>0 && !Level1LinkRGCO)		//are we fitting distribution 1 location?
		if (Level1RGCOLowLimit > Level1RGCO || Level1RGCOHighLimit < Level1RGCO)
			abort "Level 1 RGCO limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level1RGCO
		LowLimit[numpnts(W_Coef)-1]=Level1RGCOLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level1RGCOHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level1RGCO"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level1RGCOLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level1RGCOHighLimit)}		
	endif
	
//Level2 part	
	if (Level2FitRg && NumberOfLevels>1)		//are we fitting distribution 1 volume?
		if (Level2RgLowLimit > Level2Rg || Level2RgHighLimit < Level2Rg)
			abort "Level 2 Rg limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level2Rg
		LowLimit[numpnts(W_Coef)-1]=Level2RgLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level2RgHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level2Rg"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level2RgLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level2RgHighLimit)}		
	endif
	if (Level2FitG && NumberOfLevels>1)		//are we fitting distribution 1 location?
		if (Level2GLowLimit > Level2G || Level2GHighLimit < Level2G)
			abort "Level 2 G limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level2G
		CoefNames[numpnts(CoefNames)-1]="Level2G"
		LowLimit[numpnts(W_Coef)-1]=Level2GLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level2GHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level2GLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level2GHighLimit)}		
	endif
	if (Level2FitP && NumberOfLevels>1)		//are we fitting distribution 1 location?
		if (Level2PLowLimit > Level2P || Level2PHighLimit < Level2P)
			abort "Level 2 P limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level2P
		CoefNames[numpnts(CoefNames)-1]="Level2P"
		LowLimit[numpnts(W_Coef)-1]=Level2PLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level2PHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level2PLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level2PHighLimit)}		
	endif
	if (Level2FitB && NumberOfLevels>1 && !(Level2LinkB))		//are we fitting distribution 1 location?
		if (Level2BLowLimit > Level2B || Level2BHighLimit < Level2B)
			abort "Level 2 B limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level2B
		CoefNames[numpnts(CoefNames)-1]="Level2B"
		LowLimit[numpnts(W_Coef)-1]=Level2BLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level2BHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level2BLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level2BHighLimit)}		
	endif
	if (Level2FitETA && Level2Corelations && NumberOfLevels>1)		//are we fitting distribution 1 location?
		if (Level2ETALowLimit > Level2ETA || Level2ETAHighLimit < Level2ETA)
			abort "Level 2 ETA limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level2ETA
		LowLimit[numpnts(W_Coef)-1]=Level2ETALowLimit
		HighLimit[numpnts(W_Coef)-1]=Level2ETAHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level2ETA"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level2ETALowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level2ETAHighLimit)}		
	endif
	if (Level2FitPACK && Level2Corelations && NumberOfLevels>1)		//are we fitting distribution 1 location?
		if (Level2PACKLowLimit > Level2PACK || Level2PACKHighLimit < Level2PACK)
			abort "Level 2 PACK limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level2PACK
		CoefNames[numpnts(CoefNames)-1]="Level2PACK"
		LowLimit[numpnts(W_Coef)-1]=Level2PACKLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level2PACKHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level2PACKLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level2PACKHighLimit)}		
	endif
	if (Level2FitRGCO && NumberOfLevels>1 && !Level2LinkRGCO)		//are we fitting distribution 1 location?
		if (Level2RGCOLowLimit > Level2RgCO || Level2RgCOHighLimit < Level2RgCO)
			abort "Level 2 RgCO limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level2RGCO
		CoefNames[numpnts(CoefNames)-1]="Level2RGCO"
		LowLimit[numpnts(W_Coef)-1]=Level2RGCOLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level2RGCOHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level2RGCOLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level2RGCOHighLimit)}		
	endif
//Level3 part	
	if (Level3FitRg && NumberOfLevels>2)		//are we fitting distribution 1 volume?
		if (Level3RgLowLimit > Level3Rg || Level3RgHighLimit < Level3Rg)
			abort "Level 3 Rg limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level3Rg
		CoefNames[numpnts(CoefNames)-1]="Level3Rg"
		LowLimit[numpnts(W_Coef)-1]=Level3RgLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level3RgHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level3RgLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level3RgHighLimit)}		
	endif
	if (Level3FitG && NumberOfLevels>2)		//are we fitting distribution 1 location?
		if (Level3GLowLimit > Level3G || Level3GHighLimit < Level3G)
			abort "Level 3 G limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level3G
		LowLimit[numpnts(W_Coef)-1]=Level3GLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level3GHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level3G"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level3GLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level3GHighLimit)}		
	endif
	if (Level3FitP && NumberOfLevels>2)		//are we fitting distribution 1 location?
		if (Level3PLowLimit > Level3P || Level3PHighLimit < Level3P)
			abort "Level 3 P limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level3P
		LowLimit[numpnts(W_Coef)-1]=Level3PLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level3PHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level3P"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level3PLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level3PHighLimit)}		
	endif
	if (Level3FitB && NumberOfLevels>2 && !(Level3LinkB))		//are we fitting distribution 1 location?
		if (Level3BLowLimit > Level3B || Level3BHighLimit < Level3B)
			abort "Level 3 B limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames , LowLimit, HighLimit, ParamNamesK
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level3B
		CoefNames[numpnts(CoefNames)-1]="Level3B"
		LowLimit[numpnts(W_Coef)-1]=Level3BLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level3BHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level3BLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level3BHighLimit)}		
	endif
	if (Level3FitETA && Level3Corelations && NumberOfLevels>2)		//are we fitting distribution 1 location?
		if (Level3ETALowLimit > Level3ETA || Level3ETAHighLimit < Level3ETA)
			abort "Level 3 ETA limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level3ETA
		CoefNames[numpnts(CoefNames)-1]="Level3ETA"
		LowLimit[numpnts(W_Coef)-1]=Level3ETALowLimit
		HighLimit[numpnts(W_Coef)-1]=Level3ETAHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level3ETALowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level3ETAHighLimit)}		
	endif
	if (Level3FitPACK && Level3Corelations && NumberOfLevels>2)		//are we fitting distribution 1 location?
		if (Level3PACKLowLimit > Level3PACK || Level3PACKHighLimit < Level3PACK)
			abort "Level 3 PACK limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level3PACK
		CoefNames[numpnts(CoefNames)-1]="Level3PACK"
		LowLimit[numpnts(W_Coef)-1]=Level3PACKLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level3PACKHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level3PACKLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level3PACKHighLimit)}		
	endif
	if (Level3FitRGCO && NumberOfLevels>2 && !Level3LinkRGCO)		//are we fitting distribution 1 location?
		if (Level3RGCOLowLimit > Level3RgCO || Level3RgCOHighLimit < Level3RgCO)
			abort "Level 3 RgCO limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level3RGCO
		LowLimit[numpnts(W_Coef)-1]=Level3RGCOLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level3RGCOHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level3RGCO"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level3RGCOLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level3RGCOHighLimit)}		
	endif
//Level4 part	
	if (Level4FitRg && NumberOfLevels>3)		//are we fitting distribution 1 volume?
		if (Level4RgLowLimit > Level4Rg || Level4RgHighLimit < Level4Rg)
			abort "Level 4Rg limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level4Rg
		CoefNames[numpnts(CoefNames)-1]="Level4Rg"
		LowLimit[numpnts(W_Coef)-1]=Level4RgLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level4RgHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level4RgLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level4RgHighLimit)}		
	endif
	if (Level4FitG && NumberOfLevels>3)		//are we fitting distribution 1 location?
		if (Level4GLowLimit > Level4G || Level4GHighLimit < Level4G)
			abort "Level 4 G limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level4G
		CoefNames[numpnts(CoefNames)-1]="Level4G"
		LowLimit[numpnts(W_Coef)-1]=Level4GLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level4GHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level4GLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level4GHighLimit)}		
	endif
	if (Level4FitP && NumberOfLevels>3)		//are we fitting distribution 1 location?
		if (Level4PLowLimit > Level4P || Level4PHighLimit < Level4P)
			abort "Level 4 P limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level4P
		LowLimit[numpnts(W_Coef)-1]=Level4PLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level4PHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level4P"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level4PLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level4PHighLimit)}		
	endif
	if (Level4FitB && NumberOfLevels>3 && !(Level4LinkB))		//are we fitting distribution 1 location?
		if (Level4BLowLimit > Level4B || Level4BHighLimit < Level4B)
			abort "Level 4 B limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level4B
		LowLimit[numpnts(W_Coef)-1]=Level4BLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level4BHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level4B"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level4BLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level4BHighLimit)}		
	endif
	if (Level4FitETA && Level4Corelations && NumberOfLevels>3)		//are we fitting distribution 1 location?
		if (Level4ETALowLimit > Level4ETA || Level4ETAHighLimit < Level4ETA)
			abort "Level 4 ETA limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level4ETA
		LowLimit[numpnts(W_Coef)-1]=Level4ETALowLimit
		HighLimit[numpnts(W_Coef)-1]=Level4ETAHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level4ETA"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level4ETALowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level4ETAHighLimit)}		
	endif
	if (Level4FitPACK && Level4Corelations && NumberOfLevels>3)		//are we fitting distribution 1 location?
		if (Level4PACKLowLimit > Level4PACK || Level4PACKHighLimit < Level4PACK)
			abort "Level 4 PACK limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level4PACK
		LowLimit[numpnts(W_Coef)-1]=Level4PACKLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level4PACKHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level4PACK"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level4PACKLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level4PACKHighLimit)}		
	endif
	if (Level4FitRGCO && NumberOfLevels>3 && !Level4LinkRGCO)		//are we fitting distribution 1 location?
		if (Level4RGCOLowLimit > Level4RgCO || Level4RgCOHighLimit < Level4RgCO)
			abort "Level 4 RgCO limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames , LowLimit, HighLimit, ParamNamesK
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level4RGCO
		LowLimit[numpnts(W_Coef)-1]=Level4RGCOLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level4RGCOHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level4RGCO"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level4RGCOLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level4RGCOHighLimit)}		
	endif
//Level5 part	
	if (Level5FitRg && NumberOfLevels>4)		//are we fitting distribution 1 volume?
		if (Level5RgLowLimit > Level5Rg || Level5RgHighLimit < Level5Rg)
			abort "Level 5 Rg limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level5Rg
		LowLimit[numpnts(W_Coef)-1]=Level5RgLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level5RgHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level5Rg"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level5RgLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level5RgHighLimit)}		
	endif
	if (Level5FitG && NumberOfLevels>4)		//are we fitting distribution 1 location?
		if (Level5GLowLimit > Level5G || Level5GHighLimit < Level5G)
			abort "Level 5 G limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level5G
		CoefNames[numpnts(CoefNames)-1]="Level5G"
		LowLimit[numpnts(W_Coef)-1]=Level5GLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level5GHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level5GLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level5GHighLimit)}		
	endif
	if (Level5FitP && NumberOfLevels>4)		//are we fitting distribution 1 location?
		if (Level5PLowLimit > Level5P || Level5PHighLimit < Level5P)
			abort "Level 5 P limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level5P
		LowLimit[numpnts(W_Coef)-1]=Level5PLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level5PHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level5P"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level5PLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level5PHighLimit)}		
	endif
	if (Level5FitB && NumberOfLevels>4  && !(Level5LinkB))		//are we fitting distribution 1 location?
		if (Level5BLowLimit > Level5B || Level5BHighLimit < Level5B)
			abort "Level 5 B limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level5B
		LowLimit[numpnts(W_Coef)-1]=Level5BLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level5BHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level5B"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level5BLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level5BHighLimit)}		
	endif
	if (Level5FitETA && Level5Corelations && NumberOfLevels>4)		//are we fitting distribution 1 location?
		if (Level5ETALowLimit > Level5ETA || Level5ETAHighLimit < Level5ETA)
			abort "Level 5 ETA limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level5ETA
		LowLimit[numpnts(W_Coef)-1]=Level5ETALowLimit
		HighLimit[numpnts(W_Coef)-1]=Level5ETAHighLimit
		CoefNames[numpnts(CoefNames)-1]="Level5ETA"
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level5ETALowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level5ETAHighLimit)}		
	endif
	if (Level5FitPACK && Level5Corelations && NumberOfLevels>4)		//are we fitting distribution 1 location?
		if (Level5PACKLowLimit > Level5PACK || Level5PACKHighLimit < Level5PACK)
			abort "Level 5 PACK limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames , LowLimit, HighLimit, ParamNamesK
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level5PACK
		CoefNames[numpnts(CoefNames)-1]="Level5PACK"
		LowLimit[numpnts(W_Coef)-1]=Level5PACKLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level5PACKHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level5PACKLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level5PACKHighLimit)}		
	endif
	if (Level5FitRGCO && NumberOfLevels>4 && !Level5LinkRGCO)		//are we fitting distribution 1 location?
		if (Level5RGCOLowLimit > Level5RgCO || Level5RgCOHighLimit < Level5RgCO)
			abort "Level 5 RgCO limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames, LowLimCoefName, HighLimCoefNames, LowLimit, HighLimit, ParamNamesK 
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=Level5RGCO
		CoefNames[numpnts(CoefNames)-1]="Level5RGCO"
		LowLimit[numpnts(W_Coef)-1]=Level5RGCOLowLimit
		HighLimit[numpnts(W_Coef)-1]=Level5RGCOHighLimit
		LowLimCoefName[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"LowLimit"
		HighLimCoefNames[numpnts(CoefNames)-1]=CoefNames[numpnts(CoefNames)-1]+"HighLimit"
		ParamNamesK[numpnts(CoefNames)-1] = {"K"+num2str(numpnts(W_coef)-1)}
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(Level5RGCOLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(Level5RGCOHighLimit)}		
	endif
				

	//Now let's check if we have what to fit at all...
	if (numpnts(CoefNames)==0)
		beep
		Abort "Select parameters to fit and set their fitting limits"
	endif
	IR1A_SetErrorsToZero()
	
	DoWindow /F IR1_LogLogPlotU
	Wave OriginalQvector
	Wave OriginalIntensity
	Wave OriginalError	

	if(!SkipFitControlDialog)
		IR1A_CheckFittingParamsFnct()
		PauseForUser IR1A_CheckFittingParams

		NVAR UserCanceled=root:Packages:Irena_UnifFit:UserCanceled
		if (UserCanceled)
			setDataFolder OldDf
			abort
		endif
	endif

	//add more constraints, is user added them or if thy already are in AdditionalFittingConstraints
	if(strlen(AdditionalFittingConstraints)>3)
		AdditionalFittingConstraints = RemoveEnding(AdditionalFittingConstraints , ";")+";"
	else
		AdditionalFittingConstraints=""
	endif
	variable NumOfAddOnConstr=ItemsInList(AdditionalFittingConstraints,";")
	if(NumOfAddOnConstr>0)		//there are some
		print "Added following fitting constraints : "+AdditionalFittingConstraints
		variable oldConstNum=numpnts(T_Constraints)
		redimension/N=(oldConstNum+NumOfAddOnConstr) T_Constraints
		variable ij
		for (ij=0;ij<NumOfAddOnConstr;ij+=1)
			T_Constraints[oldConstNum+ij] = StringFromList(ij, AdditionalFittingConstraints, ";")
		endfor	
	endif


	
	Variable V_chisq
	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave=W_coef/100

	IR1A_RecordResults("before")

	Variable V_FitError=0			//This should prevent errors from being generated
		variable NumParams=numpnts(CoefNames)
		string ParamName, ParamName1, ListOfLimitsReachedParams
		ListOfLimitsReachedParams=""
		variable i, LimitsReached
	
	//and now the fit...
	if (strlen(csrWave(A,"IR1_LogLogPlotU"))!=0 && strlen(csrWave(B,"IR1_LogLogPlotU"))!=0)		//cursors in the graph
		Duplicate/O/R=[pcsr(A,"IR1_LogLogPlotU"),pcsr(B,"IR1_LogLogPlotU")] OriginalIntensity, FitIntensityWave		
		Duplicate/O/R=[pcsr(A,"IR1_LogLogPlotU"),pcsr(B,"IR1_LogLogPlotU")] OriginalQvector, FitQvectorWave
		Duplicate/O/R=[pcsr(A,"IR1_LogLogPlotU"),pcsr(B,"IR1_LogLogPlotU")] OriginalError, FitErrorWave
		//***Catch error issues
		wavestats/Q FitErrorWave
		if(V_Min<1e-20)
			Print "Warning: Looks like you have some very small uncertainties (ERRORS). Any point with uncertaitny (error) < = 0 is masked off and not fitted. "
			Print "Make sure your uncertainties are all LARGER than 0 for ALL points." 
		endif
		if(V_avg<=0)
			Print "Note: these are uncertainties after scaling/processing. Did you accidentally scale uncertainties by 0 ? " 
			Abort "Uncertainties (ERRORS) make NO sense. Points with uncertainty (error) <= 0 are not fitted and this causes troubles. Fix uncertainties and try again. See history area for more details."
		endif
		//***End of Catch error issues
		
		if(UseNoLimits)	
			FuncFit /N=0/W=0/Q IR1A_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /D 
		else
			FuncFit /N=0/W=0/Q IR1A_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /D /C=T_Constraints 
		endif
	else
		Duplicate/O OriginalIntensity, FitIntensityWave		
		Duplicate/O OriginalQvector, FitQvectorWave
		Duplicate/O OriginalError, FitErrorWave
		//***Catch error issues
		wavestats/Q FitErrorWave
		if(V_Min<1e-20)
			Print "Warning: Looks like you have some very small uncertainties (ERRORS). Any point with uncertaitny (error) < = 0 is masked off and not fitted. "
			Print "Make sure your uncertainties are all LARGER than 0 for ALL points." 
		endif
		if(V_avg<=0)
			Print "Note: these are uncertainties after scaling/processing. Did you accidentally scale uncertainties by 0 ? " 
			Abort "Uncertainties (ERRORS) make NO sense. Points with uncertainty (error) <= 0 are not fitted and this causes troubles. Fix uncertainties and try again. See history area for more details."
		endif
		//***End of Catch error issues
		if(UseNoLimits)	
			FuncFit /N=0/W=0/Q IR1A_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D	
		else	
			FuncFit /N=0/W=0/Q IR1A_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D /C=T_Constraints	
		endif
	endif
	if (V_FitError!=0)	//there was error in fitting
		NVAR/Z FitFailed = root:Packages:Irena_UnifFit:FitFailed
		if (NVAR_Exists(FitFailed))
			FitFailed=1
		endif
		IR1A_ResetParamsAfterBadFit()
		if(skipreset==0)
			beep
			Abort "Fitting error, check starting parameters and fitting limits" 
		endif
	else		//results OK, make sure the resulting values are set 
		For(i=0;i<NumParams;i+=1)
			ParamName = CoefNames[i]
			NVAR TempVar = $(ParamName)
			ParamName1 = LowLimCoefName[i]
			NVAR/Z TempVarLL=$(ParamName1)
			ParamName1 = HighLimCoefNames[i]
			NVAR/Z TempVarHL=$(ParamName1)
			TempVar=W_Coef[i]
			if(NVAR_Exists(TempVarLL) && NVAR_Exists(TempVarHL))
				if(abs(TempVarLL-TempVar)/TempVar <0.02)
					LimitsReached = 1
					ListOfLimitsReachedParams+=ParamName+";"
				endif
				if(abs(TempVarHL-TempVar)/TempVar <0.02)
					LimitsReached = 1
					ListOfLimitsReachedParams+=ParamName+";"
				endif
			endif
		endfor
		if(LimitsReached && !UseNoLimits)
			print "Following parameters may have reached their Min/Max limits during fitting:"
			print  ListOfLimitsReachedParams
			if(!stringmatch(GetRTStackInfo(0),"*IR1A_ConEvEvaluateParameter*") && !stringmatch(GetRTStackInfo(0),"*IR2S_ButtonProc*") )		//skip when calling from either Confidence evaluation or scripting tool 
				DoAlert /T="Warning about possible fitting limits violation" 0, "One or more limits may have been reached, check history for the list of parameters" 
			endif
		endif

	endif
	
	IR1A_UpdateMassFractCalc()
	
	variable/g AchievedChisq=V_chisq
	IR1A_RecordErrorsAfterFit()
	IR1A_GraphModelData()
	IR1A_RecordResults("after")
	
	DoWIndow/F IR1A_ControlPanel
	IR1A_FixTabsInPanel()
	
	KillWaves/Z T_Constraints, E_wave
	
	setDataFolder OldDF
end

//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************

Function IR1A_RecordErrorsAfterFit()

	setDataFolder root:Packages:Irena_UnifFit
	
	Wave W_sigma=root:Packages:Irena_UnifFit:W_sigma
	Wave/T CoefNames=root:Packages:Irena_UnifFit:CoefNames
	
	variable i
	For(i=0;i<numpnts(CoefNames);i+=1)
		NVAR InsertErrorHere=$(CoefNames[i]+"Error")
		InsertErrorHere=W_sigma[i]
	endfor
	
end

//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************

Function IR1A_ResetParamsAfterBadFit()
	
	Wave w=root:Packages:Irena_UnifFit:CoefficientInput
	Wave/T CoefNames=root:Packages:Irena_UnifFit:CoefNames		//text wave with names of parameters

	if ((!WaveExists(w)) || (!WaveExists(CoefNames)))
		Beep
		abort "Record of old parameters does not exist, this is BUG, please report it..."
	endif

	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR FitSASBackground=root:Packages:Irena_UnifFit:FitSASBackground

//Level1 part	
	NVAR  Level1Rg=root:Packages:Irena_UnifFit:Level1Rg
	NVAR  Level1FitRg=root:Packages:Irena_UnifFit:Level1FitRg
	NVAR  Level1RgLowLimit=root:Packages:Irena_UnifFit:Level1RgLowLimit
	NVAR  Level1RgHighLimit =root:Packages:Irena_UnifFit:Level1RgHighLimit
	NVAR  Level1G=root:Packages:Irena_UnifFit:Level1G
	NVAR  Level1FitG=root:Packages:Irena_UnifFit:Level1FitG
	NVAR  Level1GLowLimit=root:Packages:Irena_UnifFit:Level1GLowLimit
	NVAR  Level1GHighLimit =root:Packages:Irena_UnifFit:Level1GHighLimit
	NVAR  Level1P=root:Packages:Irena_UnifFit:Level1P
	NVAR  Level1FitP=root:Packages:Irena_UnifFit:Level1FitP
	NVAR  Level1PLowLimit=root:Packages:Irena_UnifFit:Level1PLowLimit
	NVAR  Level1PHighLimit=root:Packages:Irena_UnifFit:Level1PHighLimit
	NVAR  Level1B=root:Packages:Irena_UnifFit:Level1B
	NVAR  Level1FitB=root:Packages:Irena_UnifFit:Level1FitB
	NVAR  Level1BLowLimit=root:Packages:Irena_UnifFit:Level1BLowLimit
	NVAR  Level1BHighLimit=root:Packages:Irena_UnifFit:Level1BHighLimit
	NVAR  Level1ETA=root:Packages:Irena_UnifFit:Level1ETA
	NVAR  Level1FitETA=root:Packages:Irena_UnifFit:Level1FitETA
	NVAR  Level1ETALowLimit =root:Packages:Irena_UnifFit:Level1ETALowLimit
	NVAR  Level1ETAHighLimit=root:Packages:Irena_UnifFit:Level1ETAHighLimit
	NVAR  Level1PACK=root:Packages:Irena_UnifFit:Level1PACK
	NVAR  Level1FitPACK=root:Packages:Irena_UnifFit:Level1FitPACK
	NVAR  Level1PACKLowLimit=root:Packages:Irena_UnifFit:Level1PACKLowLimit
	NVAR  Level1PACKHighLimit=root:Packages:Irena_UnifFit:Level1PACKHighLimit
	NVAR  Level1RgCO=root:Packages:Irena_UnifFit:Level1RgCO
	NVAR  Level1FitRgCO=root:Packages:Irena_UnifFit:Level1FitRgCO
	NVAR  Level1RgCOLowLimit=root:Packages:Irena_UnifFit:Level1RgCOLowLimit
	NVAR  Level1RgCOHighLimit=root:Packages:Irena_UnifFit:Level1RgCOHighLimit
	NVAR  Level1K=root:Packages:Irena_UnifFit:Level1K
	NVAR  Level1Corelations=root:Packages:Irena_UnifFit:Level1Corelations
	NVAR  Level1MassFractal=root:Packages:Irena_UnifFit:Level1MassFractal
//Level2 part	
	NVAR  Level2Rg=root:Packages:Irena_UnifFit:Level2Rg
	NVAR  Level2FitRg=root:Packages:Irena_UnifFit:Level2FitRg
	NVAR  Level2RgLowLimit=root:Packages:Irena_UnifFit:Level2RgLowLimit
	NVAR  Level2RgHighLimit =root:Packages:Irena_UnifFit:Level2RgHighLimit
	NVAR  Level2G=root:Packages:Irena_UnifFit:Level2G
	NVAR  Level2FitG=root:Packages:Irena_UnifFit:Level2FitG
	NVAR  Level2GLowLimit=root:Packages:Irena_UnifFit:Level2GLowLimit
	NVAR  Level2GHighLimit =root:Packages:Irena_UnifFit:Level2GHighLimit
	NVAR  Level2P=root:Packages:Irena_UnifFit:Level2P
	NVAR  Level2FitP=root:Packages:Irena_UnifFit:Level2FitP
	NVAR  Level2PLowLimit=root:Packages:Irena_UnifFit:Level2PLowLimit
	NVAR  Level2PHighLimit=root:Packages:Irena_UnifFit:Level2PHighLimit
	NVAR  Level2B=root:Packages:Irena_UnifFit:Level2B
	NVAR  Level2FitB=root:Packages:Irena_UnifFit:Level2FitB
	NVAR  Level2BLowLimit=root:Packages:Irena_UnifFit:Level2BLowLimit
	NVAR  Level2BHighLimit=root:Packages:Irena_UnifFit:Level2BHighLimit
	NVAR  Level2ETA=root:Packages:Irena_UnifFit:Level2ETA
	NVAR  Level2FitETA=root:Packages:Irena_UnifFit:Level2FitETA
	NVAR  Level2ETALowLimit =root:Packages:Irena_UnifFit:Level2ETALowLimit
	NVAR  Level2ETAHighLimit=root:Packages:Irena_UnifFit:Level2ETAHighLimit
	NVAR  Level2PACK=root:Packages:Irena_UnifFit:Level2PACK
	NVAR  Level2FitPACK=root:Packages:Irena_UnifFit:Level2FitPACK
	NVAR  Level2PACKLowLimit=root:Packages:Irena_UnifFit:Level2PACKLowLimit
	NVAR  Level2PACKHighLimit=root:Packages:Irena_UnifFit:Level2PACKHighLimit
	NVAR  Level2RgCO=root:Packages:Irena_UnifFit:Level2RgCO
	NVAR  Level2FitRgCO=root:Packages:Irena_UnifFit:Level2FitRgCO
	NVAR  Level2RgCOLowLimit=root:Packages:Irena_UnifFit:Level2RgCOLowLimit
	NVAR  Level2RgCOHighLimit=root:Packages:Irena_UnifFit:Level2RgCOHighLimit
	NVAR  Level2K=root:Packages:Irena_UnifFit:Level2K
	NVAR  Level2Corelations=root:Packages:Irena_UnifFit:Level2Corelations
	NVAR  Level2MassFractal=root:Packages:Irena_UnifFit:Level2MassFractal
//Level3 part	
	NVAR  Level3Rg=root:Packages:Irena_UnifFit:Level3Rg
	NVAR  Level3FitRg=root:Packages:Irena_UnifFit:Level3FitRg
	NVAR  Level3RgLowLimit=root:Packages:Irena_UnifFit:Level3RgLowLimit
	NVAR  Level3RgHighLimit =root:Packages:Irena_UnifFit:Level3RgHighLimit
	NVAR  Level3G=root:Packages:Irena_UnifFit:Level3G
	NVAR  Level3FitG=root:Packages:Irena_UnifFit:Level3FitG
	NVAR  Level3GLowLimit=root:Packages:Irena_UnifFit:Level3GLowLimit
	NVAR  Level3GHighLimit =root:Packages:Irena_UnifFit:Level3GHighLimit
	NVAR  Level3P=root:Packages:Irena_UnifFit:Level3P
	NVAR  Level3FitP=root:Packages:Irena_UnifFit:Level3FitP
	NVAR  Level3PLowLimit=root:Packages:Irena_UnifFit:Level3PLowLimit
	NVAR  Level3PHighLimit=root:Packages:Irena_UnifFit:Level3PHighLimit
	NVAR  Level3B=root:Packages:Irena_UnifFit:Level3B
	NVAR  Level3FitB=root:Packages:Irena_UnifFit:Level3FitB
	NVAR  Level3BLowLimit=root:Packages:Irena_UnifFit:Level3BLowLimit
	NVAR  Level3BHighLimit=root:Packages:Irena_UnifFit:Level3BHighLimit
	NVAR  Level3ETA=root:Packages:Irena_UnifFit:Level3ETA
	NVAR  Level3FitETA=root:Packages:Irena_UnifFit:Level3FitETA
	NVAR  Level3ETALowLimit =root:Packages:Irena_UnifFit:Level3ETALowLimit
	NVAR  Level3ETAHighLimit=root:Packages:Irena_UnifFit:Level3ETAHighLimit
	NVAR  Level3PACK=root:Packages:Irena_UnifFit:Level3PACK
	NVAR  Level3FitPACK=root:Packages:Irena_UnifFit:Level3FitPACK
	NVAR  Level3PACKLowLimit=root:Packages:Irena_UnifFit:Level3PACKLowLimit
	NVAR  Level3PACKHighLimit=root:Packages:Irena_UnifFit:Level3PACKHighLimit
	NVAR  Level3RgCO=root:Packages:Irena_UnifFit:Level3RgCO
	NVAR  Level3FitRgCO=root:Packages:Irena_UnifFit:Level3FitRgCO
	NVAR  Level3RgCOLowLimit=root:Packages:Irena_UnifFit:Level3RgCOLowLimit
	NVAR  Level3RgCOHighLimit=root:Packages:Irena_UnifFit:Level3RgCOHighLimit
	NVAR  Level3K=root:Packages:Irena_UnifFit:Level3K
	NVAR  Level3Corelations=root:Packages:Irena_UnifFit:Level3Corelations
	NVAR  Level3MassFractal=root:Packages:Irena_UnifFit:Level3MassFractal
//Level4 part	
	NVAR  Level4Rg=root:Packages:Irena_UnifFit:Level4Rg
	NVAR  Level4FitRg=root:Packages:Irena_UnifFit:Level4FitRg
	NVAR  Level4RgLowLimit=root:Packages:Irena_UnifFit:Level4RgLowLimit
	NVAR  Level4RgHighLimit =root:Packages:Irena_UnifFit:Level4RgHighLimit
	NVAR  Level4G=root:Packages:Irena_UnifFit:Level4G
	NVAR  Level4FitG=root:Packages:Irena_UnifFit:Level4FitG
	NVAR  Level4GLowLimit=root:Packages:Irena_UnifFit:Level4GLowLimit
	NVAR  Level4GHighLimit =root:Packages:Irena_UnifFit:Level4GHighLimit
	NVAR  Level4P=root:Packages:Irena_UnifFit:Level4P
	NVAR  Level4FitP=root:Packages:Irena_UnifFit:Level4FitP
	NVAR  Level4PLowLimit=root:Packages:Irena_UnifFit:Level4PLowLimit
	NVAR  Level4PHighLimit=root:Packages:Irena_UnifFit:Level4PHighLimit
	NVAR  Level4B=root:Packages:Irena_UnifFit:Level4B
	NVAR  Level4FitB=root:Packages:Irena_UnifFit:Level4FitB
	NVAR  Level4BLowLimit=root:Packages:Irena_UnifFit:Level4BLowLimit
	NVAR  Level4BHighLimit=root:Packages:Irena_UnifFit:Level4BHighLimit
	NVAR  Level4ETA=root:Packages:Irena_UnifFit:Level4ETA
	NVAR  Level4FitETA=root:Packages:Irena_UnifFit:Level4FitETA
	NVAR  Level4ETALowLimit =root:Packages:Irena_UnifFit:Level4ETALowLimit
	NVAR  Level4ETAHighLimit=root:Packages:Irena_UnifFit:Level4ETAHighLimit
	NVAR  Level4PACK=root:Packages:Irena_UnifFit:Level4PACK
	NVAR  Level4FitPACK=root:Packages:Irena_UnifFit:Level4FitPACK
	NVAR  Level4PACKLowLimit=root:Packages:Irena_UnifFit:Level4PACKLowLimit
	NVAR  Level4PACKHighLimit=root:Packages:Irena_UnifFit:Level4PACKHighLimit
	NVAR  Level4RgCO=root:Packages:Irena_UnifFit:Level4RgCO
	NVAR  Level4FitRgCO=root:Packages:Irena_UnifFit:Level4FitRgCO
	NVAR  Level4RgCOLowLimit=root:Packages:Irena_UnifFit:Level4RgCOLowLimit
	NVAR  Level4RgCOHighLimit=root:Packages:Irena_UnifFit:Level4RgCOHighLimit
	NVAR  Level4K=root:Packages:Irena_UnifFit:Level4K
	NVAR  Level4Corelations=root:Packages:Irena_UnifFit:Level4Corelations
	NVAR  Level4MassFractal=root:Packages:Irena_UnifFit:Level4MassFractal
//Level5 part	
	NVAR  Level5Rg=root:Packages:Irena_UnifFit:Level5Rg
	NVAR  Level5FitRg=root:Packages:Irena_UnifFit:Level5FitRg
	NVAR  Level5RgLowLimit=root:Packages:Irena_UnifFit:Level5RgLowLimit
	NVAR  Level5RgHighLimit =root:Packages:Irena_UnifFit:Level5RgHighLimit
	NVAR  Level5G=root:Packages:Irena_UnifFit:Level5G
	NVAR  Level5FitG=root:Packages:Irena_UnifFit:Level5FitG
	NVAR  Level5GLowLimit=root:Packages:Irena_UnifFit:Level5GLowLimit
	NVAR  Level5GHighLimit =root:Packages:Irena_UnifFit:Level5GHighLimit
	NVAR  Level5P=root:Packages:Irena_UnifFit:Level5P
	NVAR  Level5FitP=root:Packages:Irena_UnifFit:Level5FitP
	NVAR  Level5PLowLimit=root:Packages:Irena_UnifFit:Level5PLowLimit
	NVAR  Level5PHighLimit=root:Packages:Irena_UnifFit:Level5PHighLimit
	NVAR  Level5B=root:Packages:Irena_UnifFit:Level5B
	NVAR  Level5FitB=root:Packages:Irena_UnifFit:Level5FitB
	NVAR  Level5BLowLimit=root:Packages:Irena_UnifFit:Level5BLowLimit
	NVAR  Level5BHighLimit=root:Packages:Irena_UnifFit:Level5BHighLimit
	NVAR  Level5ETA=root:Packages:Irena_UnifFit:Level5ETA
	NVAR  Level5FitETA=root:Packages:Irena_UnifFit:Level5FitETA
	NVAR  Level5ETALowLimit =root:Packages:Irena_UnifFit:Level5ETALowLimit
	NVAR  Level5ETAHighLimit=root:Packages:Irena_UnifFit:Level5ETAHighLimit
	NVAR  Level5PACK=root:Packages:Irena_UnifFit:Level5PACK
	NVAR  Level5FitPACK=root:Packages:Irena_UnifFit:Level5FitPACK
	NVAR  Level5PACKLowLimit=root:Packages:Irena_UnifFit:Level5PACKLowLimit
	NVAR  Level5PACKHighLimit=root:Packages:Irena_UnifFit:Level5PACKHighLimit
	NVAR  Level5RgCO=root:Packages:Irena_UnifFit:Level5RgCO
	NVAR  Level5FitRgCO=root:Packages:Irena_UnifFit:Level5FitRgCO
	NVAR  Level5RgCOLowLimit=root:Packages:Irena_UnifFit:Level5RgCOLowLimit
	NVAR  Level5RgCOHighLimit=root:Packages:Irena_UnifFit:Level5RgCOHighLimit
	NVAR  Level5K=root:Packages:Irena_UnifFit:Level5K
	NVAR  Level5Corelations=root:Packages:Irena_UnifFit:Level5Corelations
	NVAR  Level5MassFractal=root:Packages:Irena_UnifFit:Level5MassFractal
//
	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	string ParamName=""
	
	for (i=0;i<NumOfParam;i+=1)
		ParamName=CoefNames[i]
	
		if(cmpstr(ParamName,"SASBackground")==0)
			SASBackground=w[i]
		endif

		if(cmpstr(ParamName,"Level1Rg")==0)
			Level1Rg=w[i]
		endif
		if(cmpstr(ParamName,"Level1G")==0)
			Level1G=w[i]
		endif
		if(cmpstr(ParamName,"Level1P")==0)
			Level1P=w[i]
		endif
		if(cmpstr(ParamName,"Level1B")==0)
			Level1B=w[i]
		endif
		if(cmpstr(ParamName,"Level1ETA")==0)
			Level1ETA=w[i]
		endif
		if(cmpstr(ParamName,"Level1PACK")==0)
			Level1PACK=w[i]
		endif
		if(cmpstr(ParamName,"Level1RGCO")==0)
			Level1RGCO=w[i]
		endif
		if(cmpstr(ParamName,"Level1K")==0)
			Level1K=w[i]
		endif
		if(cmpstr(ParamName,"Level2Rg")==0)
			Level2Rg=w[i]
		endif
		if(cmpstr(ParamName,"Level2G")==0)
			Level2G=w[i]
		endif
		if(cmpstr(ParamName,"Level2P")==0)
			Level2P=w[i]
		endif
		if(cmpstr(ParamName,"Level2B")==0)
			Level2B=w[i]
		endif
		if(cmpstr(ParamName,"Level2ETA")==0)
			Level2ETA=w[i]
		endif
		if(cmpstr(ParamName,"Level2PACK")==0)
			Level2PACK=w[i]
		endif
		if(cmpstr(ParamName,"Level2RGCO")==0)
			Level2RGCO=w[i]
		endif
		if(cmpstr(ParamName,"Level2K")==0)
			Level2K=w[i]
		endif
		if(cmpstr(ParamName,"Level3Rg")==0)
			Level3Rg=w[i]
		endif
		if(cmpstr(ParamName,"Level3G")==0)
			Level3G=w[i]
		endif
		if(cmpstr(ParamName,"Level3P")==0)
			Level3P=w[i]
		endif
		if(cmpstr(ParamName,"Level3B")==0)
			Level3B=w[i]
		endif
		if(cmpstr(ParamName,"Level3ETA")==0)
			Level3ETA=w[i]
		endif
		if(cmpstr(ParamName,"Level3PACK")==0)
			Level3PACK=w[i]
		endif
		if(cmpstr(ParamName,"Level3RGCO")==0)
			Level3RGCO=w[i]
		endif
		if(cmpstr(ParamName,"Level3K")==0)
			Level3K=w[i]
		endif
		if(cmpstr(ParamName,"Level4Rg")==0)
			Level4Rg=w[i]
		endif
		if(cmpstr(ParamName,"Level4G")==0)
			Level4G=w[i]
		endif
		if(cmpstr(ParamName,"Level4P")==0)
			Level4P=w[i]
		endif
		if(cmpstr(ParamName,"Level4B")==0)
			Level4B=w[i]
		endif
		if(cmpstr(ParamName,"Level4ETA")==0)
			Level4ETA=w[i]
		endif
		if(cmpstr(ParamName,"Level4PACK")==0)
			Level4PACK=w[i]
		endif
		if(cmpstr(ParamName,"Level4RGCO")==0)
			Level4RGCO=w[i]
		endif
		if(cmpstr(ParamName,"Level4K")==0)
			Level4K=w[i]
		endif
		if(cmpstr(ParamName,"Level5Rg")==0)
			Level5Rg=w[i]
		endif
		if(cmpstr(ParamName,"Level5G")==0)
			Level5G=w[i]
		endif
		if(cmpstr(ParamName,"Level5P")==0)
			Level5P=w[i]
		endif
		if(cmpstr(ParamName,"Level5B")==0)
			Level5B=w[i]
		endif
		if(cmpstr(ParamName,"Level5ETA")==0)
			Level5ETA=w[i]
		endif
		if(cmpstr(ParamName,"Level5PACK")==0)
			Level5PACK=w[i]
		endif
		if(cmpstr(ParamName,"Level5RGCO")==0)
			Level5RGCO=w[i]
		endif
		if(cmpstr(ParamName,"Level5K")==0)
			Level5K=w[i]
		endif
	endfor
	DoWIndow/F IR1A_ControlPanel
	IR1A_FixTabsInPanel()

end

//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************


Function IR1A_FitFunction(w,yw,xw) : FitFunc
	Wave w,yw,xw
	
	//here the w contains the parameters, yw will be the result and xw is the input
	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(q) = very complex calculations, forget about formula
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1 - the q vector...
	//CurveFitDialog/ q

	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR FitSASBackground=root:Packages:Irena_UnifFit:FitSASBackground
//Level1 part	
	NVAR  Level1Rg=root:Packages:Irena_UnifFit:Level1Rg
	NVAR  Level1FitRg=root:Packages:Irena_UnifFit:Level1FitRg
	NVAR  Level1RgLowLimit=root:Packages:Irena_UnifFit:Level1RgLowLimit
	NVAR  Level1RgHighLimit =root:Packages:Irena_UnifFit:Level1RgHighLimit
	NVAR  Level1G=root:Packages:Irena_UnifFit:Level1G
	NVAR  Level1FitG=root:Packages:Irena_UnifFit:Level1FitG
	NVAR  Level1GLowLimit=root:Packages:Irena_UnifFit:Level1GLowLimit
	NVAR  Level1GHighLimit =root:Packages:Irena_UnifFit:Level1GHighLimit
	NVAR  Level1P=root:Packages:Irena_UnifFit:Level1P
	NVAR  Level1FitP=root:Packages:Irena_UnifFit:Level1FitP
	NVAR  Level1PLowLimit=root:Packages:Irena_UnifFit:Level1PLowLimit
	NVAR  Level1PHighLimit=root:Packages:Irena_UnifFit:Level1PHighLimit
	NVAR  Level1B=root:Packages:Irena_UnifFit:Level1B
	NVAR  Level1FitB=root:Packages:Irena_UnifFit:Level1FitB
	NVAR  Level1BLowLimit=root:Packages:Irena_UnifFit:Level1BLowLimit
	NVAR  Level1BHighLimit=root:Packages:Irena_UnifFit:Level1BHighLimit
	NVAR  Level1ETA=root:Packages:Irena_UnifFit:Level1ETA
	NVAR  Level1FitETA=root:Packages:Irena_UnifFit:Level1FitETA
	NVAR  Level1ETALowLimit =root:Packages:Irena_UnifFit:Level1ETALowLimit
	NVAR  Level1ETAHighLimit=root:Packages:Irena_UnifFit:Level1ETAHighLimit
	NVAR  Level1PACK=root:Packages:Irena_UnifFit:Level1PACK
	NVAR  Level1FitPACK=root:Packages:Irena_UnifFit:Level1FitPACK
	NVAR  Level1PACKLowLimit=root:Packages:Irena_UnifFit:Level1PACKLowLimit
	NVAR  Level1PACKHighLimit=root:Packages:Irena_UnifFit:Level1PACKHighLimit
	NVAR  Level1RgCO=root:Packages:Irena_UnifFit:Level1RgCO
	NVAR  Level1FitRgCO=root:Packages:Irena_UnifFit:Level1FitRgCO
	NVAR  Level1RgCOLowLimit=root:Packages:Irena_UnifFit:Level1RgCOLowLimit
	NVAR  Level1RgCOHighLimit=root:Packages:Irena_UnifFit:Level1RgCOHighLimit
	NVAR  Level1K=root:Packages:Irena_UnifFit:Level1K
	NVAR  Level1Corelations=root:Packages:Irena_UnifFit:Level1Corelations
	NVAR  Level1MassFractal=root:Packages:Irena_UnifFit:Level1MassFractal
//Level2 part	
	NVAR  Level2Rg=root:Packages:Irena_UnifFit:Level2Rg
	NVAR  Level2FitRg=root:Packages:Irena_UnifFit:Level2FitRg
	NVAR  Level2RgLowLimit=root:Packages:Irena_UnifFit:Level2RgLowLimit
	NVAR  Level2RgHighLimit =root:Packages:Irena_UnifFit:Level2RgHighLimit
	NVAR  Level2G=root:Packages:Irena_UnifFit:Level2G
	NVAR  Level2FitG=root:Packages:Irena_UnifFit:Level2FitG
	NVAR  Level2GLowLimit=root:Packages:Irena_UnifFit:Level2GLowLimit
	NVAR  Level2GHighLimit =root:Packages:Irena_UnifFit:Level2GHighLimit
	NVAR  Level2P=root:Packages:Irena_UnifFit:Level2P
	NVAR  Level2FitP=root:Packages:Irena_UnifFit:Level2FitP
	NVAR  Level2PLowLimit=root:Packages:Irena_UnifFit:Level2PLowLimit
	NVAR  Level2PHighLimit=root:Packages:Irena_UnifFit:Level2PHighLimit
	NVAR  Level2B=root:Packages:Irena_UnifFit:Level2B
	NVAR  Level2FitB=root:Packages:Irena_UnifFit:Level2FitB
	NVAR  Level2BLowLimit=root:Packages:Irena_UnifFit:Level2BLowLimit
	NVAR  Level2BHighLimit=root:Packages:Irena_UnifFit:Level2BHighLimit
	NVAR  Level2ETA=root:Packages:Irena_UnifFit:Level2ETA
	NVAR  Level2FitETA=root:Packages:Irena_UnifFit:Level2FitETA
	NVAR  Level2ETALowLimit =root:Packages:Irena_UnifFit:Level2ETALowLimit
	NVAR  Level2ETAHighLimit=root:Packages:Irena_UnifFit:Level2ETAHighLimit
	NVAR  Level2PACK=root:Packages:Irena_UnifFit:Level2PACK
	NVAR  Level2FitPACK=root:Packages:Irena_UnifFit:Level2FitPACK
	NVAR  Level2PACKLowLimit=root:Packages:Irena_UnifFit:Level2PACKLowLimit
	NVAR  Level2PACKHighLimit=root:Packages:Irena_UnifFit:Level2PACKHighLimit
	NVAR  Level2RgCO=root:Packages:Irena_UnifFit:Level2RgCO
	NVAR  Level2FitRgCO=root:Packages:Irena_UnifFit:Level2FitRgCO
	NVAR  Level2RgCOLowLimit=root:Packages:Irena_UnifFit:Level2RgCOLowLimit
	NVAR  Level2RgCOHighLimit=root:Packages:Irena_UnifFit:Level2RgCOHighLimit
	NVAR  Level2K=root:Packages:Irena_UnifFit:Level2K
	NVAR  Level2Corelations=root:Packages:Irena_UnifFit:Level2Corelations
	NVAR  Level2MassFractal=root:Packages:Irena_UnifFit:Level2MassFractal
//Level3 part	
	NVAR  Level3Rg=root:Packages:Irena_UnifFit:Level3Rg
	NVAR  Level3FitRg=root:Packages:Irena_UnifFit:Level3FitRg
	NVAR  Level3RgLowLimit=root:Packages:Irena_UnifFit:Level3RgLowLimit
	NVAR  Level3RgHighLimit =root:Packages:Irena_UnifFit:Level3RgHighLimit
	NVAR  Level3G=root:Packages:Irena_UnifFit:Level3G
	NVAR  Level3FitG=root:Packages:Irena_UnifFit:Level3FitG
	NVAR  Level3GLowLimit=root:Packages:Irena_UnifFit:Level3GLowLimit
	NVAR  Level3GHighLimit =root:Packages:Irena_UnifFit:Level3GHighLimit
	NVAR  Level3P=root:Packages:Irena_UnifFit:Level3P
	NVAR  Level3FitP=root:Packages:Irena_UnifFit:Level3FitP
	NVAR  Level3PLowLimit=root:Packages:Irena_UnifFit:Level3PLowLimit
	NVAR  Level3PHighLimit=root:Packages:Irena_UnifFit:Level3PHighLimit
	NVAR  Level3B=root:Packages:Irena_UnifFit:Level3B
	NVAR  Level3FitB=root:Packages:Irena_UnifFit:Level3FitB
	NVAR  Level3BLowLimit=root:Packages:Irena_UnifFit:Level3BLowLimit
	NVAR  Level3BHighLimit=root:Packages:Irena_UnifFit:Level3BHighLimit
	NVAR  Level3ETA=root:Packages:Irena_UnifFit:Level3ETA
	NVAR  Level3FitETA=root:Packages:Irena_UnifFit:Level3FitETA
	NVAR  Level3ETALowLimit =root:Packages:Irena_UnifFit:Level3ETALowLimit
	NVAR  Level3ETAHighLimit=root:Packages:Irena_UnifFit:Level3ETAHighLimit
	NVAR  Level3PACK=root:Packages:Irena_UnifFit:Level3PACK
	NVAR  Level3FitPACK=root:Packages:Irena_UnifFit:Level3FitPACK
	NVAR  Level3PACKLowLimit=root:Packages:Irena_UnifFit:Level3PACKLowLimit
	NVAR  Level3PACKHighLimit=root:Packages:Irena_UnifFit:Level3PACKHighLimit
	NVAR  Level3RgCO=root:Packages:Irena_UnifFit:Level3RgCO
	NVAR  Level3FitRgCO=root:Packages:Irena_UnifFit:Level3FitRgCO
	NVAR  Level3RgCOLowLimit=root:Packages:Irena_UnifFit:Level3RgCOLowLimit
	NVAR  Level3RgCOHighLimit=root:Packages:Irena_UnifFit:Level3RgCOHighLimit
	NVAR  Level3K=root:Packages:Irena_UnifFit:Level3K
	NVAR  Level3Corelations=root:Packages:Irena_UnifFit:Level3Corelations
	NVAR  Level3MassFractal=root:Packages:Irena_UnifFit:Level3MassFractal
//Level4 part	
	NVAR  Level4Rg=root:Packages:Irena_UnifFit:Level4Rg
	NVAR  Level4FitRg=root:Packages:Irena_UnifFit:Level4FitRg
	NVAR  Level4RgLowLimit=root:Packages:Irena_UnifFit:Level4RgLowLimit
	NVAR  Level4RgHighLimit =root:Packages:Irena_UnifFit:Level4RgHighLimit
	NVAR  Level4G=root:Packages:Irena_UnifFit:Level4G
	NVAR  Level4FitG=root:Packages:Irena_UnifFit:Level4FitG
	NVAR  Level4GLowLimit=root:Packages:Irena_UnifFit:Level4GLowLimit
	NVAR  Level4GHighLimit =root:Packages:Irena_UnifFit:Level4GHighLimit
	NVAR  Level4P=root:Packages:Irena_UnifFit:Level4P
	NVAR  Level4FitP=root:Packages:Irena_UnifFit:Level4FitP
	NVAR  Level4PLowLimit=root:Packages:Irena_UnifFit:Level4PLowLimit
	NVAR  Level4PHighLimit=root:Packages:Irena_UnifFit:Level4PHighLimit
	NVAR  Level4B=root:Packages:Irena_UnifFit:Level4B
	NVAR  Level4FitB=root:Packages:Irena_UnifFit:Level4FitB
	NVAR  Level4BLowLimit=root:Packages:Irena_UnifFit:Level4BLowLimit
	NVAR  Level4BHighLimit=root:Packages:Irena_UnifFit:Level4BHighLimit
	NVAR  Level4ETA=root:Packages:Irena_UnifFit:Level4ETA
	NVAR  Level4FitETA=root:Packages:Irena_UnifFit:Level4FitETA
	NVAR  Level4ETALowLimit =root:Packages:Irena_UnifFit:Level4ETALowLimit
	NVAR  Level4ETAHighLimit=root:Packages:Irena_UnifFit:Level4ETAHighLimit
	NVAR  Level4PACK=root:Packages:Irena_UnifFit:Level4PACK
	NVAR  Level4FitPACK=root:Packages:Irena_UnifFit:Level4FitPACK
	NVAR  Level4PACKLowLimit=root:Packages:Irena_UnifFit:Level4PACKLowLimit
	NVAR  Level4PACKHighLimit=root:Packages:Irena_UnifFit:Level4PACKHighLimit
	NVAR  Level4RgCO=root:Packages:Irena_UnifFit:Level4RgCO
	NVAR  Level4FitRgCO=root:Packages:Irena_UnifFit:Level4FitRgCO
	NVAR  Level4RgCOLowLimit=root:Packages:Irena_UnifFit:Level4RgCOLowLimit
	NVAR  Level4RgCOHighLimit=root:Packages:Irena_UnifFit:Level4RgCOHighLimit
	NVAR  Level4K=root:Packages:Irena_UnifFit:Level4K
	NVAR  Level4Corelations=root:Packages:Irena_UnifFit:Level4Corelations
	NVAR  Level4MassFractal=root:Packages:Irena_UnifFit:Level4MassFractal
//Level5 part	
	NVAR  Level5Rg=root:Packages:Irena_UnifFit:Level5Rg
	NVAR  Level5FitRg=root:Packages:Irena_UnifFit:Level5FitRg
	NVAR  Level5RgLowLimit=root:Packages:Irena_UnifFit:Level5RgLowLimit
	NVAR  Level5RgHighLimit =root:Packages:Irena_UnifFit:Level5RgHighLimit
	NVAR  Level5G=root:Packages:Irena_UnifFit:Level5G
	NVAR  Level5FitG=root:Packages:Irena_UnifFit:Level5FitG
	NVAR  Level5GLowLimit=root:Packages:Irena_UnifFit:Level5GLowLimit
	NVAR  Level5GHighLimit =root:Packages:Irena_UnifFit:Level5GHighLimit
	NVAR  Level5P=root:Packages:Irena_UnifFit:Level5P
	NVAR  Level5FitP=root:Packages:Irena_UnifFit:Level5FitP
	NVAR  Level5PLowLimit=root:Packages:Irena_UnifFit:Level5PLowLimit
	NVAR  Level5PHighLimit=root:Packages:Irena_UnifFit:Level5PHighLimit
	NVAR  Level5B=root:Packages:Irena_UnifFit:Level5B
	NVAR  Level5FitB=root:Packages:Irena_UnifFit:Level5FitB
	NVAR  Level5BLowLimit=root:Packages:Irena_UnifFit:Level5BLowLimit
	NVAR  Level5BHighLimit=root:Packages:Irena_UnifFit:Level5BHighLimit
	NVAR  Level5ETA=root:Packages:Irena_UnifFit:Level5ETA
	NVAR  Level5FitETA=root:Packages:Irena_UnifFit:Level5FitETA
	NVAR  Level5ETALowLimit =root:Packages:Irena_UnifFit:Level5ETALowLimit
	NVAR  Level5ETAHighLimit=root:Packages:Irena_UnifFit:Level5ETAHighLimit
	NVAR  Level5PACK=root:Packages:Irena_UnifFit:Level5PACK
	NVAR  Level5FitPACK=root:Packages:Irena_UnifFit:Level5FitPACK
	NVAR  Level5PACKLowLimit=root:Packages:Irena_UnifFit:Level5PACKLowLimit
	NVAR  Level5PACKHighLimit=root:Packages:Irena_UnifFit:Level5PACKHighLimit
	NVAR  Level5RgCO=root:Packages:Irena_UnifFit:Level5RgCO
	NVAR  Level5FitRgCO=root:Packages:Irena_UnifFit:Level5FitRgCO
	NVAR  Level5RgCOLowLimit=root:Packages:Irena_UnifFit:Level5RgCOLowLimit
	NVAR  Level5RgCOHighLimit=root:Packages:Irena_UnifFit:Level5RgCOHighLimit
	NVAR  Level5K=root:Packages:Irena_UnifFit:Level5K
	NVAR  Level5Corelations=root:Packages:Irena_UnifFit:Level5Corelations
	NVAR  Level5MassFractal=root:Packages:Irena_UnifFit:Level5MassFractal

	Wave/T CoefNames=root:Packages:Irena_UnifFit:CoefNames		//text wave with names of parameters

	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	string ParamName=""
	
	for (i=0;i<NumOfParam;i+=1)
		ParamName=CoefNames[i]
	
		if(cmpstr(ParamName,"SASBackground")==0)
			SASBackground=abs(w[i])
		endif

		if(cmpstr(ParamName,"Level1Rg")==0)
			Level1Rg=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level1G")==0)
			Level1G=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level1P")==0)
			Level1P=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level1B")==0)
			Level1B=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level1ETA")==0)
			Level1ETA=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level1PACK")==0)
			Level1PACK=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level1RGCO")==0)
			Level1RGCO=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level1K")==0)
			Level1K=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level2Rg")==0)
			Level2Rg=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level2G")==0)
			Level2G=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level2P")==0)
			Level2P=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level2B")==0)
			Level2B=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level2ETA")==0)
			Level2ETA=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level2PACK")==0)
			Level2PACK=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level2RGCO")==0)
			Level2RGCO=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level2K")==0)
			Level2K=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level3Rg")==0)
			Level3Rg=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level3G")==0)
			Level3G=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level3P")==0)
			Level3P=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level3B")==0)
			Level3B=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level3ETA")==0)
			Level3ETA=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level3PACK")==0)
			Level3PACK=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level3RGCO")==0)
			Level3RGCO=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level3K")==0)
			Level3K=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level4Rg")==0)
			Level4Rg=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level4G")==0)
			Level4G=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level4P")==0)
			Level4P=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level4B")==0)
			Level4B=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level4ETA")==0)
			Level4ETA=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level4PACK")==0)
			Level4PACK=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level4RGCO")==0)
			Level4RGCO=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level4K")==0)
			Level4K=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level5Rg")==0)
			Level5Rg=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level5G")==0)
			Level5G=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level5P")==0)
			Level5P=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level5B")==0)
			Level5B=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level5ETA")==0)
			Level5ETA=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level5PACK")==0)
			Level5PACK=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level5RGCO")==0)
			Level5RGCO=abs(w[i])
		endif
		if(cmpstr(ParamName,"Level5K")==0)
			Level5K=abs(w[i])
		endif

	endfor

	Wave QvectorWave=root:Packages:Irena_UnifFit:FitQvectorWave
	//and now we need to calculate the model Intensity
	IR1A_UnifiedFitCalculateInt(QvectorWave)		
	
	Wave resultWv=root:Packages:Irena_UnifFit:UnifiedFitIntensity
	redimension/N=(numpnts(resultWv)) yw
	yw=resultWv
End

///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************

Function IR1A_UnifiedFitCalculateInt(QvectorWave)
	Wave QvectorWave


	setDataFolder root:Packages:Irena_UnifFit
	
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif

	//for slit smeared data may need to extend the Q range... 
	variable OriginalPointLength
	variable ExtendedTheData=0
	OriginalPointLength = numpnts(QvectorWave)
	if(UseSMRData )
		if(QvectorWave[numpnts(QvectorWave)-1]<(3*SlitLengthUnif))
			ExtendedTheData = 1
			variable QlengthNeeded = 3*SlitLengthUnif - QvectorWave[numpnts(QvectorWave)-1]
			variable LastQstep = 2*(QvectorWave[numpnts(QvectorWave)-1] - QvectorWave[numpnts(QvectorWave)-2])
			variable NumNewPoints = ceil(QlengthNeeded / LastQstep)
			redimension/N=(OriginalPointLength+NumNewPoints) QvectorWave
			QvectorWave[OriginalPointLength, numpnts(QvectorWave)-1] = QvectorWave[OriginalPointLength-1] + LastQstep * (p-OriginalPointLength+1)
		endif
	endif
	//now the new model waves are longer... 
	Duplicate/O QvectorWave, UnifiedFitIntensity
	
	UnifiedFitIntensity=0
	
	variable i
	
	for(i=1;i<=NumberOfLevels;i+=1)	// initialize variables;continue test
		//IR1A_UnifiedFitCalcIntOne(QvectorWave,i)
		IR1A_UnifiedCalcIntOne(i, QvectorWave)
		Wave TempUnifiedIntensity
		UnifiedFitIntensity+=TempUnifiedIntensity
	endfor								
	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	UnifiedFitIntensity+=SASBackground	
	if(UseSMRData)
		duplicate/O  UnifiedFitIntensity, UnifiedFitIntensitySM
		IR1B_SmearData(UnifiedFitIntensity, QvectorWave, SlitLengthUnif, UnifiedFitIntensitySM)
		UnifiedFitIntensity=UnifiedFitIntensitySM
		KillWaves/Z UnifiedFitIntensitySM
	endif

	if(ExtendedTheData)
		//need to undo the extending of data
		redimension/N=(OriginalPointLength) QvectorWave, UnifiedFitIntensity
	endif	

end

///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************

//this one has error since it cannot do LinkB and if B is linked, it does tno fit correctly. 
//10/28/2020 removed, not needed anymore. 
//Function IR1A_UnifiedFitCalcIntOne(QvectorWave,level)
//	variable level
//	Wave QvectorWave
//	
//	setDataFolder root:Packages:Irena_UnifFit
//	Wave OriginalIntensity
//	
//	Duplicate/O QvectorWave, TempUnifiedIntensity
//	Duplicate /O QvectorWave, QstarVector
//	
//	NVAR Rg=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Rg")
//	NVAR G=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"G")
//	NVAR P=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"P")
//	NVAR B=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"B")
//	NVAR ETA=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"ETA")
//	NVAR PACK=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"PACK")
//	NVAR RgCO=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgCO")
//	NVAR K=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"K")
//	NVAR Corelations=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Corelations")
//	NVAR MassFractal=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"MassFractal")
//	NVAR LinkRGCO=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"LinkRGCO")
//	if (LinkRGCO==1 && level>=2)
//		NVAR RgLowerLevel=$("root:Packages:Irena_UnifFit:Level"+num2str(level-1)+"Rg")	
//		RGCO=RgLowerLevel
//	endif
//	QstarVector=QvectorWave/(erf(K*QvectorWave*Rg/sqrt(6)))^3
//	if (MassFractal)
//		B=(G*P/Rg^P)*exp(gammln(P/2))
//	endif
//	
//	TempUnifiedIntensity=G*exp(-QvectorWave^2*Rg^2/3)+(B/QstarVector^P) * exp(-RGCO^2 * QvectorWave^2/3)
//	
//	if (Corelations)
//		TempUnifiedIntensity/=(1+pack*IR1A_SphereAmplitude(QvectorWave,ETA))
//	endif
//end


///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************
///*********************************************************************************************************************



Function IR1A_RecordResults(CalledFromWere)
	string CalledFromWere	
	//before or after - that means fit...
	

	DFref oldDf= GetDataFolderDFR()

	setdataFolder root:Packages:Irena_UnifFit

	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR FitSASBackground=root:Packages:Irena_UnifFit:FitSASBackground
	NVAR SubtractBackground=root:Packages:Irena_UnifFit:SubtractBackground
	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif

	SVAR DataAreFrom=root:Packages:Irena_UnifFit:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena_UnifFit:IntensityWaveName
	SVAR QWavename=root:Packages:Irena_UnifFit:QWavename
	SVAR ErrorWaveName=root:Packages:Irena_UnifFit:ErrorWaveName

	IR1_CreateLoggbook()		//this creates the logbook
	SVAR nbl=root:Packages:SAS_Modeling:NotebookName

	IR1L_AppendAnyText("     ")
	if (cmpstr(CalledFromWere,"before")==0)
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Parameters before starting UNIFIED FIT on the data from: \t"+DataAreFrom)
		IR1_InsertDateAndTime(nbl)
		IR1L_AppendAnyText("Name of data waves Int/Q/Error \t"+IntensityWaveName+"\t"+QWavename+"\t"+ErrorWaveName)
		if(UseSMRData)
			IR1L_AppendAnyText("Slit smeared data were used. Slit length = "+num2str(SlitLengthUnif))
		endif
		IR1L_AppendAnyText("UNIFIED FIT")
		IR1L_AppendAnyText("Number of levels: "+num2str(NumberOfLevels))
	else			//after
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Results of the UNIFIED FIT on the data from: \t"+DataAreFrom)	
		IR1L_AppendAnyText("Name of data waves Int/Q/Error \t"+IntensityWaveName+"\t"+QWavename+"\t"+ErrorWaveName)
		if(UseSMRData)
			IR1L_AppendAnyText("Slit smeared data were used. Slit length = "+num2str(SlitLengthUnif))
		endif
		IR1L_AppendAnyText("UNIFIED FIT")
		IR1L_AppendAnyText("Number of fitted levels: "+num2str(NumberOfLevels))
		IR1L_AppendAnyText("Fitting results: ")
	endif
	IR1L_AppendAnyText("SAS background = "+num2str(SASBackground)+", was fitted? = "+num2str(FitSASBackground)+"       (yes=1/no=0)")
	variable i
	For (i=1;i<=NumberOfLevels;i+=1)
		IR1L_AppendAnyText("***********  Level  "+num2str(i))
		NVAR tempVal =$("Level"+num2str(i)+"Rg")
		NVAR tempValError =$("Level"+num2str(i)+"RgError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitRg")
			IR1L_AppendAnyText("Rg      \t\t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
		NVAR tempVal =$("Level"+num2str(i)+"G")
		NVAR tempValError =$("Level"+num2str(i)+"GError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitG")
			IR1L_AppendAnyText("G      \t\t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
		NVAR tempVal =$("Level"+num2str(i)+"P")
		NVAR tempValError =$("Level"+num2str(i)+"PError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitP")
			IR1L_AppendAnyText("P     \t \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
		NVAR tempValMassFractal =$("Level"+num2str(i)+"MassFractal")
			if (tempValMassFractal)
				IR1L_AppendAnyText("\tAssumed Mass Fractal")
				IR1L_AppendAnyText("Parameter B calculated as B=(G*P/Rg^P)*Gamma(P/2)")
			else
				NVAR tempVal =$("Level"+num2str(i)+"B")
				NVAR tempValError =$("Level"+num2str(i)+"BError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitB")
				IR1L_AppendAnyText("B     \t \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
			endif
		NVAR tempVal =$("Level"+num2str(i)+"RGCO")
		NVAR tempValError =$("Level"+num2str(i)+"RgCOError")
		NVAR LinktempVal=$("Level"+num2str(i)+"LinkRgCO")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitRGCO")
				if (fitTempVal)
					IR1L_AppendAnyText("RgCO linked to lower level Rg =\t"+ num2str(tempVal))
				else
					IR1L_AppendAnyText("RgCO      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
				endif
		NVAR tempVal =$("Level"+num2str(i)+"K")
			IR1L_AppendAnyText("K      \t"+ num2str(tempVal))
		NVAR tempValCorrelations =$("Level"+num2str(i)+"Corelations")
			if (tempValCorrelations)
				IR1L_AppendAnyText("Assumed Corelations so following parameters apply")
				NVAR tempVal =$("Level"+num2str(i)+"ETA")
				NVAR tempValError =$("Level"+num2str(i)+"ETAError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitETA")
					IR1L_AppendAnyText("ETA      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
				NVAR tempVal =$("Level"+num2str(i)+"PACK")
				NVAR tempValError =$("Level"+num2str(i)+"PACKError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitPACK")
				IR1L_AppendAnyText("PACK      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
		else
				IR1L_AppendAnyText("Corelations       \tNot assumed")
			endif

		NVAR tempVal =$("Level"+num2str(i)+"Invariant")
				IR1L_AppendAnyText("Invariant  =\t"+num2str(tempVal)+"   cm^(-1) A^(-3)")
		NVAR tempVal =$("Level"+num2str(i)+"SurfaceToVolRat")
			if (Numtype(tempVal)==0)
				IR1L_AppendAnyText("Surface to volume ratio  =\t"+num2str(tempVal)+"   m^(2) / cm^(3)")
			endif
			IR1L_AppendAnyText("  ")
	endfor
	
	if (cmpstr(CalledFromWere,"after")==0)
		IR1L_AppendAnyText("Fit has been reached with following parameters")
		IR1_InsertDateAndTime(nbl)
		NVAR AchievedChisq
		IR1L_AppendAnyText("Chi-Squared \t"+ num2str(AchievedChisq))

		//DoWindow /F IR1_LogLogPlotU
		if (strlen(csrWave(A,"IR1_LogLogPlotU"))!=0 && strlen(csrWave(B,"IR1_LogLogPlotU"))!=0)		//cursors in the graph
			IR1L_AppendAnyText("Points selected for fitting \t"+ num2str(pcsr(A,"IR1_LogLogPlotU")) + "   to \t"+num2str(pcsr(B,"IR1_LogLogPlotU")))
		else
			IR1L_AppendAnyText("Whole range of data selected for fitting")
		endif
		IR1L_AppendAnyText(" ")
	endif			//after

	setdataFolder oldDf
end

Function IR1A_SaveRecordResults()	
	
	DFref oldDf= GetDataFolderDFR()

	setdataFolder root:Packages:Irena_UnifFit

	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR FitSASBackground=root:Packages:Irena_UnifFit:FitSASBackground
	NVAR SubtractBackground=root:Packages:Irena_UnifFit:SubtractBackground
	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
	NVAR LastSavedUnifOutput=root:Packages:Irena_UnifFit:LastSavedUnifOutput
	NVAR ExportLocalFits=root:Packages:Irena_UnifFit:ExportLocalFits

	SVAR DataAreFrom=root:Packages:Irena_UnifFit:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena_UnifFit:IntensityWaveName
	SVAR QWavename=root:Packages:Irena_UnifFit:QWavename
	SVAR ErrorWaveName=root:Packages:Irena_UnifFit:ErrorWaveName

	IR1_CreateLoggbook()		//this creates the logbook
	SVAR nbl=root:Packages:SAS_Modeling:NotebookName

	IR1L_AppendAnyText("     ")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Saved Results of the UNIFIED FIT on the data from: \t"+DataAreFrom)	
		IR1_InsertDateAndTime(nbl)
		IR1L_AppendAnyText("Name of data waves Int/Q/Error \t"+IntensityWaveName+"\t"+QWavename+"\t"+ErrorWaveName)
		if(UseSMRData)
			IR1L_AppendAnyText("Slit smeared data were used. Slit length = "+num2str(SlitLengthUnif))
		endif
		IR1L_AppendAnyText("Output wave names :")
		IR1L_AppendAnyText("Int/Q \t"+"UnifiedFitIntensity_"+num2str(LastSavedUnifOutput)+"\tUnifiedFitQvector_"+num2str(LastSavedUnifOutput))
		if(ExportLocalFits)
			IR1L_AppendAnyText("Loacl fits saved also")
		endif
		
		IR1L_AppendAnyText("Number of fitted levels: "+num2str(NumberOfLevels))
		IR1L_AppendAnyText("Fitting results: ")
	IR1L_AppendAnyText("SAS background = "+num2str(SASBackground)+", was fitted? = "+num2str(FitSASBackground)+"       (yes=1/no=0)")
	variable i
	For (i=1;i<=NumberOfLevels;i+=1)
		IR1L_AppendAnyText("***********  Level  "+num2str(i))
		NVAR tempVal =$("Level"+num2str(i)+"Rg")
		NVAR tempValError =$("Level"+num2str(i)+"RgError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitRg")
			IR1L_AppendAnyText("Rg      \t\t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
		NVAR tempVal =$("Level"+num2str(i)+"G")
		NVAR tempValError =$("Level"+num2str(i)+"GError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitG")
			IR1L_AppendAnyText("G      \t\t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
		NVAR tempVal =$("Level"+num2str(i)+"P")
		NVAR tempValError =$("Level"+num2str(i)+"PError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitP")
			IR1L_AppendAnyText("P     \t \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
		NVAR tempValMassFractal =$("Level"+num2str(i)+"MassFractal")
			if (tempValMassFractal)
				IR1L_AppendAnyText("\tAssumed Mass Fractal")
				IR1L_AppendAnyText("Parameter B calculated as B=(G*P/Rg^P)*Gamma(P/2)")
			else
				NVAR tempVal =$("Level"+num2str(i)+"B")
				NVAR tempValError =$("Level"+num2str(i)+"BError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitB")
				IR1L_AppendAnyText("B     \t \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
			endif
		NVAR tempVal =$("Level"+num2str(i)+"RGCO")
		NVAR tempValError =$("Level"+num2str(i)+"RgCOError")
		NVAR LinktempVal=$("Level"+num2str(i)+"LinkRgCO")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitRGCO")
				if (fitTempVal)
					IR1L_AppendAnyText("RgCO linked to lower level Rg =\t"+ num2str(tempVal))
				else
					IR1L_AppendAnyText("RgCO      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
				endif
		NVAR tempVal =$("Level"+num2str(i)+"K")
			IR1L_AppendAnyText("K      \t"+ num2str(tempVal))
		NVAR tempValCorrelations =$("Level"+num2str(i)+"Corelations")
			if (tempValCorrelations)
				IR1L_AppendAnyText("Assumed Corelations so following parameters apply")
				NVAR tempVal =$("Level"+num2str(i)+"ETA")
				NVAR tempValError =$("Level"+num2str(i)+"ETAError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitETA")
					IR1L_AppendAnyText("ETA      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
				NVAR tempVal =$("Level"+num2str(i)+"PACK")
				NVAR tempValError =$("Level"+num2str(i)+"PACKError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitPACK")
				IR1L_AppendAnyText("PACK      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
		else
				IR1L_AppendAnyText("Corelations       \tNot assumed")
			endif

		NVAR tempVal =$("Level"+num2str(i)+"Invariant")
				IR1L_AppendAnyText("Invariant  =\t"+num2str(tempVal)+"   cm^(-1) A^(-3)")
		NVAR tempVal =$("Level"+num2str(i)+"SurfaceToVolRat")
			if (Numtype(tempVal)==0)
				IR1L_AppendAnyText("Surface to volume ratio  =\t"+num2str(tempVal)+"   m^(2) / cm^(3)")
			endif
			IR1L_AppendAnyText("  ")
	endfor
	
		IR1L_AppendAnyText("Fit has been reached with following parameters")
		IR1_InsertDateAndTime(nbl)
		NVAR/Z AchievedChisq
		if(NVAR_Exists(AchievedChisq))
			IR1L_AppendAnyText("Chi-Squared \t"+ num2str(AchievedChisq))
		endif
		//DoWindow /F IR1_LogLogPlotU
		if (strlen(csrWave(A,"IR1_LogLogPlotU"))!=0 && strlen(csrWave(B,"IR1_LogLogPlotU"))!=0)		//cursors in the graph
			IR1L_AppendAnyText("Points selected for fitting \t"+ num2str(pcsr(A,"IR1_LogLogPlotU")) + "   to \t"+num2str(pcsr(B,"IR1_LogLogPlotU")))
		else
			IR1L_AppendAnyText("Whole range of data selected for fitting")
		endif
		IR1L_AppendAnyText(" ")
		IR1L_AppendAnyText("***********************************************")

	setdataFolder oldDf
end


//****************************************************************************************************************************


Function IR1A_RecoverOldParameters()
	
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR SASBackgroundError=root:Packages:Irena_UnifFit:SASBackgroundError
	SVAR DataFolderName=root:Packages:Irena_UnifFit:DataFolderName
	

	variable DataExists=0,i
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(DataFolderName, 2)
	string tempString
	if (stringmatch(ListOfWaves, "*UnifiedFitIntensity*" ))
		string ListOfSolutions=""
		For(i=0;i<itemsInList(ListOfWaves);i+=1)
			if (stringmatch(stringFromList(i,ListOfWaves),"*UnifiedFitIntensity*"))
				tempString=stringFromList(i,ListOfWaves)
				Wave tempwv=$(DataFolderName+tempString)
				tempString=stringByKey("UsersComment",note(tempwv),"=")
				ListOfSolutions+=stringFromList(i,ListOfWaves)+"*  "+tempString+";"
			endif
		endfor
		DataExists=1
		string ReturnSolution=""
		Prompt ReturnSolution, "Select solution to recover", popup,  ListOfSolutions+";Start fresh"
		DoPrompt "Previous solutions found, select one to recover", ReturnSolution
		if (V_Flag)
			abort
		endif
	endif

	if (DataExists==1 && cmpstr("Start fresh", ReturnSolution)!=0)
		ReturnSolution=ReturnSolution[0,strsearch(ReturnSolution, "*", 0 )-1]
		Wave/Z OldDistribution=$(DataFolderName+ReturnSolution)

		string OldNote=note(OldDistribution)
		NumberOfLevels=NumberByKey("NumberOfModelledLevels", OldNote,"=")
		//here I need to set appropriately the Number of levels on the panel...
		//
		PopupMenu NumberOfLevels,mode=NumberOfLevels,value= #"\"0;1;2;3;4;5;\"", win = IR1A_ControlPanel
		//	
		SASBackground =NumberByKey("SASBackground", OldNote,"=")
		SASBackgroundError =NumberByKey("SASBackgroundError", OldNote,"=")
		For(i=1;i<=NumberOfLevels;i+=1)		
			IR1A_RecoverOneLevelParam(i,OldNote)	
		endfor
		return 1
	else
		return 0
	endif
end

Function IR1A_RecoverOneLevelParam(i,OldNote)	
	variable i
	string OldNote

	
	NVAR Rg=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Rg")
	NVAR G=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"G")
	NVAR P=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"P")
	NVAR B=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"B")
	NVAR ETA=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"ETA")
	NVAR PACK=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"PACK")
	NVAR RgCO=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"RgCO")
	NVAR RgError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"RgError")
	NVAR GError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"GError")
	NVAR PError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"PError")
	NVAR BError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"BError")
	NVAR ETAError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"ETAError")
	NVAR PACKError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"PACKError")
	NVAR RgCOError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"RgCOError")
	NVAR K=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"K")
	NVAR Corelations=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Corelations")
	NVAR MassFractal=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"MassFractal")
	NVAR Invariant =$("Level"+num2str(i)+"Invariant")
	NVAR SurfaceToVolumeRatio =$("Level"+num2str(i)+"SurfaceToVolRat")
	NVAR LinkRgCO =$("Level"+num2str(i)+"LinkRgCO")
	NVAR DegreeOfAggreg =$("Level"+num2str(i)+"DegreeOfAggreg")
//	 Level1Rg   
//	 Level1G   
//	 Level1P   
//	 Level1B   
//	 Level1ETA   
//	 Level1PACK   
//	 Level1RgCO   
//	 Level1RgError   
//	 Level1GError   
//	 Level1PError   
//	 Level1BError   
//	 Level1ETAError   
//	 Level1PACKError   
//	 Level1RGCOError
//	 Level1K   
//	 Level1Corelations   
//	 Level1MassFractal   
//	 Level1Invariant   
//	 Level1SurfaceToVolRat   
//	 Level1LinkRgCO   
//	 Level1DegreeOfAggreg   

	DegreeOfAggreg=NumberByKey("Level"+num2str(i)+"DegreeOfAggreg", OldNote,"=")
	LinkRgCO=NumberByKey("Level"+num2str(i)+"LinkRgCO", OldNote,"=")
	Rg=NumberByKey("Level"+num2str(i)+"Rg", OldNote,"=")
	RgError=NumberByKey("Level"+num2str(i)+"RgError", OldNote,"=")
	G=NumberByKey("Level"+num2str(i)+"G", OldNote,"=")
	GError=NumberByKey("Level"+num2str(i)+"GError", OldNote,"=")
	P=NumberByKey("Level"+num2str(i)+"P", OldNote,"=")
	PError=NumberByKey("Level"+num2str(i)+"PError", OldNote,"=")
	B=NumberByKey("Level"+num2str(i)+"B", OldNote,"=")
	BError=NumberByKey("Level"+num2str(i)+"BError", OldNote,"=")
	ETA=NumberByKey("Level"+num2str(i)+"ETA", OldNote,"=")
	ETAError=NumberByKey("Level"+num2str(i)+"ETAError", OldNote,"=")
	PACK=NumberByKey("Level"+num2str(i)+"PACK", OldNote,"=")
	PACKError=NumberByKey("Level"+num2str(i)+"PACKError", OldNote,"=")
	RgCO=NumberByKey("Level"+num2str(i)+"RgCO", OldNote,"=")
	RgCOError=NumberByKey("Level"+num2str(i)+"RgCOError", OldNote,"=")
	K=NumberByKey("Level"+num2str(i)+"K", OldNote,"=")
	Corelations=NumberByKey("Level"+num2str(i)+"Corelations", OldNote,"=")
	MassFractal=NumberByKey("Level"+num2str(i)+"MassFractal", OldNote,"=")
	Invariant=NumberByKey("Level"+num2str(i)+"Invariant", OldNote,"=")
	SurfaceToVolumeRatio=NumberByKey("Level"+num2str(i)+"SurfaceToVolumeRatio", OldNote,"=")


end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_CheckFittingParamsFnct() 
	NewPanel /K=1/W=(400,140,970,620) as "Check fitting parameters"
	Dowindow/C IR1A_CheckFittingParams
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 3,textrgb= (0,0,65280)
	DrawText 39,28,"Unified Fit Params & Limits"
	SetDrawEnv fstyle= 1,fsize= 14
	DrawText 20,55,"Verify the list of fitted parameters. Then continue......"
	variable Qmin, Qmax
	Qmin=Nan
	Qmax=inf
	Wave OriginalQvector = root:Packages:Irena_UnifFit:OriginalQvector
	if(strlen(csrInfo(A,"IR1_LogLogPlotU"))>0)		//cursor set
		Qmin = OriginalQvector(pcsr(A,"IR1_LogLogPlotU"))
	endif
	Qmin = numtype(Qmin) == 0 ? Qmin :  OriginalQvector[0]
	if(strlen(csrInfo(B,"IR1_LogLogPlotU"))>0)	//cursor set
		Qmax = OriginalQvector(pcsr(B,"IR1_LogLogPlotU"))
	endif
	Qmax = numtype(Qmax) == 0 ? Qmax :  OriginalQvector[numpnts(OriginalQvector)-1]
	SetDrawEnv fstyle= 1,fsize= 14
	DrawText 30,80, "Data Selected for Fitting are "+num2str(pcsr(B,"IR1_LogLogPlotU")-pcsr(A,"IR1_LogLogPlotU"))+" points from point   "+num2str(pcsr(A,"IR1_LogLogPlotU")) + "   to   "+num2str(pcsr(B,"IR1_LogLogPlotU")) 
	SetDrawEnv fstyle= 1,fsize= 14
	DrawText 30,105, "This is Q range from Qmin = " + num2str(Qmin) + " A\S-1\M  to  Qmax = "+num2str(Qmax) + "  A\S-1\M"
	
	Button CancelBtn,pos={10,445},size={135,20},proc=IR1A_CheckFitPrmsButtonProc,title="Cancel fitting"
	Button ContinueBtn,pos={160,445},size={135,20},proc=IR1A_CheckFitPrmsButtonProc,title="Continue fitting"
	CheckBox SkipFitControlDialog,pos={315,447},size={63,14},noproc,title="Skip this panel next time?"
	CheckBox SkipFitControlDialog,variable= root:Packages:Irena_UnifFit:SkipFitControlDialog, help={"Check if you want to skip the check parameters dialo for fitting"}
	SetVariable AdditionalFittingConstraints, size={460,20}, pos={20,420}, variable=AdditionalFittingConstraints, noproc, title = "Add Fitting Constraints : "
	SetVariable AdditionalFittingConstraints, help={"Add usual Igor constraints separated by ; - e.g., \"K0<K1;\""}


	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Irena_UnifFit:
	SVAR AdditionalFittingConstraints=root:Packages:Irena_UnifFit:AdditionalFittingConstraints
	Wave W_coef=root:Packages:Irena_UnifFit:W_coef
	Wave/T CoefNames=root:Packages:Irena_UnifFit:CoefNames
	Wave/T ParamNamesK=root:Packages:Irena_UnifFit:ParamNamesK
	Duplicate/T/O CoefNames, ParameterWarnings
	variable i
	string tmpStr
	For(i=0;i<Numpnts(CoefNames)-1;i+=1)
		ParameterWarnings[i]=""
		tmpStr = CoefNames[i]
		if(stringmatch(tmpStr,"Background"))
			ParameterWarnings[i]=""		//no problem ever here
		elseif(stringmatch(tmpStr[6,7], "Rg")&& !stringmatch(tmpStr[6,9], "RGCO"))
			if(i==(numpnts(CoefNames)-1))							//this solves issue when looking for paramter which should be after the current parameter and it is not there. 
				ParameterWarnings[i]="G is not fitted?"		
			elseif(!stringmatch(tmpStr[0,5]+"G",CoefNames[i+1]))
				ParameterWarnings[i]="G is not fitted?"		
			endif
		elseif(stringmatch(tmpStr[6], "G")&& !stringmatch(tmpStr[6,8], "GCO"))
			if(i==0)													//this solves issue when looking for paramter which should be before the current parameter and it is not there. 
				ParameterWarnings[i]="Rg is not fitted?"		
			elseif(!stringmatch(tmpStr[0,5]+"Rg",CoefNames[i-1]))
				ParameterWarnings[i]="Rg is not fitted?"		
			endif
		elseif(stringmatch(tmpStr[6], "P")&& !stringmatch(tmpStr[6,8], "PAC")) 
			if(i==(numpnts(CoefNames)-1))							//this solves issue when looking for paramter which should be after the current parameter and it is not there. 
				ParameterWarnings[i]="B is not fitted?"		
			elseif(!stringmatch(tmpStr[0,5]+"B",CoefNames[i +1]))
				ParameterWarnings[i]="B is not fitted?"		
			endif
		elseif(stringmatch(tmpStr[6], "B")&& !stringmatch(tmpStr[6,8], "PAC"))
			if(i==0)													//this solves issue when looking for paramter which should be before the current parameter and it is not there. 
				ParameterWarnings[i]="P is not fitted?"		
			elseif(!stringmatch(tmpStr[0,5]+"P",CoefNames[i -1]))
				ParameterWarnings[i]="P is not fitted?"		
			endif
		elseif(stringmatch(tmpStr[6,9], "PACK")) 
			if(i==0)													//this solves issue when looking for paramter which should be before the current parameter and it is not there. 
				ParameterWarnings[i]="ETA is not fitted?"		
			elseif(!stringmatch(tmpStr[0,5]+"ETA",CoefNames[i -1]))
				ParameterWarnings[i]="ETA is not fitted?"		
			endif
		elseif(stringmatch(tmpStr[6,8], "ETA")) 
			if(i==(numpnts(CoefNames)-1))							//this solves issue when looking for paramter which should be after the current parameter and it is not there. 
				ParameterWarnings[i]="PACK is not fitted?"		
			elseif(!stringmatch(tmpStr[0,5]+"PACK",CoefNames[i +1]))
				ParameterWarnings[i]="PACK is not fitted?"		
			endif
		elseif(stringmatch(tmpStr[6,9], "RGCO")) 
				ParameterWarnings[i]="Fitting RgCO is BAD idea..."		
		endif
	endfor
	NVAR UseNoLimits = root:Packages:Irena_UnifFit:UseNoLimits
	WAVE HighLimit=root:Packages:Irena_UnifFit:HighLimit
	WAVE LowLimit=root:Packages:Irena_UnifFit:LowLimit
	if(!UseNoLimits)
		Edit/W=(0.02,0.25,0.98,0.85)/HOST=#  ParamNamesK,CoefNames, W_coef, LowLimit, HighLimit, ParameterWarnings
		ModifyTable format(Point)=1,width(Point)=0,width(CoefNames)=100,title(CoefNames)="Fitted Coef Name"
		ModifyTable width(W_coef)=90,title(W_coef.y)="Start value",alignment=1, sigDigits(W_coef)=2
		ModifyTable width(LowLimit)=85,title(LowLimit.y)="Low limit", sigDigits(LowLimit)=2
		ModifyTable width(HighLimit)=85,title(HighLimit.y)="High limit", sigDigits(HighLimit)=2
		ModifyTable width(ParameterWarnings)=125,title(ParameterWarnings.y)="Warnings:"
		ModifyTable showParts=254,title(ParamNamesK)="Constr.",width(ParamNamesK)=40
	else
		Edit/W=(0.02,0.25,0.98,0.85)/HOST=#  ParamNamesK,CoefNames, W_coef, ParameterWarnings
		ModifyTable format(Point)=1,width(Point)=0,alignment=2,width(CoefNames)=150,title(CoefNames)="Fitted Coef Name"
		ModifyTable width(W_coef)=120,title(W_coef.y)="Start value",alignment=1,sigDigits(W_coef)=2
		ModifyTable width(ParameterWarnings)=225,title(ParameterWarnings.y)="Warnings:"
		ModifyTable showParts=254, title(ParamNamesK)="Constr.",width(ParamNamesK)=40
	endif
	SetDataFolder fldrSav0
	RenameWindow #,T0
	SetActiveSubwindow ##
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR1A_CheckFitPrmsButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if(stringmatch(ctrlName,"*CancelBtn*"))
		variable/g root:Packages:Irena_UnifFit:UserCanceled=1
		KillWIndow/Z IR1A_CheckFittingParams
	endif

	if(stringmatch(ctrlName,"*ContinueBtn*"))
		variable/g root:Packages:Irena_UnifFit:UserCanceled=0
		KillWIndow/Z IR1A_CheckFittingParams
	endif

End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************




//*****************************************************************************************************************
//*****************************************************************************************************************
//			start of original IR1_Unified_SaveExport
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_ExportASCIIResults()

	//here we need to copy the export results out of Igor
	//before that we need to also attach note to teh waves with the results
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit
	
	Wave OriginalQvector=root:Packages:Irena_UnifFit:OriginalQvector
	Wave OriginalIntensity=root:Packages:Irena_UnifFit:OriginalIntensity
	Wave OriginalError=root:Packages:Irena_UnifFit:OriginalError
	Wave UnifiedFitIntensity=root:Packages:Irena_UnifFit:UnifiedFitIntensity
	
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	SVAR DataFolderName=root:Packages:Irena_UnifFit:DataFolderName
	
	Duplicate/O OriginalQvector, tempOriginalQvector
	Duplicate/O OriginalIntensity, tempOriginalIntensity
	Duplicate/O OriginalError, tempOriginalError
	Duplicate/O UnifiedFitIntensity, tempUnifiedFitIntensity
	string ListOfWavesForNotes="tempOriginalQvector;tempOriginalIntensity;tempOriginalError;tempUnifiedFitIntensity;"
	
	IR1A_AppendWaveNote(ListOfWavesForNotes)

	string Comments="Record of Data evaluation with Irena SAS modeling macros using UNIFIED fit model;"
	Comments+="For details on method see: http://www.eng.uc.edu/~gbeaucag/PDFPapers/Beaucage2.pdf, Beaucage1.pdf, and ma970373t.pdf;"
	Comments+="Intensity is modelled using formula: Ii(q) = Gi exp(-q^2Rgi^2/3) + exp(-q^2Rg(i-1)^2/3)Bi {[erf(q Rgi/sqrt(6))]^3/q}^Pi;where i is level number;"
	Comments+="Note that there are variations on this formula if corelations and mass fractal are assumed, please check references;"
	Comments+=note(tempUnifiedFitIntensity)+"Q[A]\tExperimental intensity[1/cm]\tExperimental error\tUnified Fit model intensity[1/cm]\r"
	variable pos=0
	variable ComLength=strlen(Comments)
	
	Do 
	pos=strsearch(Comments, ";", pos+5)
	Comments=Comments[0,pos-1]+"\r$\t"+Comments[pos+1,inf]
	while (pos>0)

	string filename1
	filename1=StringFromList(ItemsInList(DataFolderName,":")-1, DataFolderName,":")+"_SAS_model.txt"
	variable refnum

	Open/D/T=".txt"/M="Select file to save data to" refnum as filename1
	filename1=S_filename
	if (strlen(filename1)==0)
		abort
	endif
	
	String nb = "Notebook0"
	NewNotebook/N=$nb/F=0/V=0/K=0/W=(5.25,40.25,558,408.5) as "ExportData"
	Notebook $nb defaultTab=20, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nb font="Arial", fSize=10, fStyle=0, textRGB=(0,0,0)
	Notebook $nb text=Comments	
	
	
	SaveNotebook $nb as filename1
	DoWindow /K $nb
	Save/A/G/M="\r\n" tempOriginalQvector,tempOriginalIntensity,tempOriginalError,tempUnifiedFitIntensity as filename1	 
	


	Killwaves/Z tempOriginalQvector,tempOriginalIntensity,tempOriginalError,tempUnifiedFitIntensity
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_AppendWaveNote(ListOfWavesForNotes)
	string ListOfWavesForNotes
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit

	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR SASBackgroundError=root:Packages:Irena_UnifFit:SASBackgroundError
	SVAR DataFolderName=root:Packages:Irena_UnifFit:DataFolderName
	string ExperimentName=IgorInfo(1)
	variable i
	For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)

		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"IgorExperimentName",ExperimentName)
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"DataFolderinIgor",DataFolderName)
		
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"DistributionTypeModelled", "Unified Fit")	
		
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"NumberOfModelledLevels",num2str(NumberOfLevels))

		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"SASBackground",num2str(SASBackground))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"SASBackgroundError",num2str(SASBackgroundError))
	endfor

	For(i=1;i<=NumberOfLevels;i+=1)
		IR1A_AppendWNOfDist(i,ListOfWavesForNotes)
	endfor

	setDataFolder oldDF

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_AppendWNOfDist(level,ListOfWavesForNotes)
	variable level
	string ListOfWavesForNotes
	

	
	NVAR Rg=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Rg")
	NVAR G=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"G")
	NVAR P=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"P")
	NVAR B=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"B")
	NVAR ETA=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"ETA")
	NVAR PACK=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"PACK")
	NVAR RgCO=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgCO")
	NVAR RgError=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgError")
	NVAR GError=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"GError")
	NVAR PError=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"PError")
	NVAR BError=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"BError")
	NVAR ETAError=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"ETAError")
	NVAR PACKError=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"PACKError")
	NVAR RgCOError=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgCOError")
	NVAR K=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"K")
	NVAR Corelations=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Corelations")
	NVAR MassFractal=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"MassFractal")
	NVAR Invariant =$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Invariant")
	NVAR SurfaceToVolumeRatio =$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"SurfaceToVolRat")
	NVAR LinkRgCO =$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"LinkRgCO")
	NVAR DegreeOfAggreg =$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"DegreeOfAggreg")


	variable i
	For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"Rg",num2str(Rg))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"RgError",num2str(RgError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"G",num2str(G))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"GError",num2str(GError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"P",num2str(P))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"PError",num2str(PError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"B",num2str(B))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"BError",num2str(BError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"ETA",num2str(ETA))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"ETAError",num2str(ETAError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"PACK",num2str(PACK))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"PACKError",num2str(PACKError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"RgCO",num2str(RGCO))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"RgCOError",num2str(RGCOError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"K",num2str(K))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"Corelations",num2str(Corelations))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"MassFractal",num2str(MassFractal))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"Invariant",num2str(Invariant))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"SurfaceToVolumeRatio",num2str(SurfaceToVolumeRatio))

		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"LinkRgCO",num2str(LinkRgCO))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"DegreeOfAggreg",num2str(DegreeOfAggreg))
	endfor
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_CopyDataBackToFolder(StandardOrUser, [Saveme])
	string StandardOrUser, SaveMe
	//here we need to copy the final data back to folder
	//before that we need to also attach note to the waves with the results
	if(ParamIsDefault(SaveMe ))
		SaveMe="NO"
	ENDIF
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit
	
	string UsersComment="Unified Fit results from "+date()+"  "+time()
	
	Prompt UsersComment, "Modify comment to be included with these results"
	if(!stringmatch(SaveMe,"Yes"))
		DoPrompt "Copy data back to folder comment", UsersComment
		if (V_Flag)
			abort
		endif
	endif
	Wave UnifiedFitIntensity=root:Packages:Irena_UnifFit:UnifiedFitIntensity
	Wave UnifiedFitQvector=root:Packages:Irena_UnifFit:UnifiedFitQvector
	
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	SVAR DataFolderName=root:Packages:Irena_UnifFit:DataFolderName
	NVAR ExportLocalFits=root:Packages:Irena_UnifFit:ExportLocalFits
	NVAR UseModelData = root:Packages:Irena_UnifFit:UseModelData
	variable/G LastSavedUnifOutput
	
	Duplicate/O UnifiedFitIntensity, tempUnifiedFitIntensity
	Duplicate/O UnifiedFitQvector, tempUnifiedFitQvector
	string ListOfWavesForNotes="tempUnifiedFitIntensity;tempUnifiedFitQvector;"
	
	IR1A_AppendWaveNote(ListOfWavesForNotes)
	
	if(UseModelData)
		string NewFolderNameStr="UnifiedModelResults"
		Prompt NewFolderNameStr, "Model data, need target folder"
		DoPrompt "How should new fodler with model be named?", NewFolderNameStr
		if (V_Flag)
			abort
		endif
		setDataFolder root:
		if(DataFolderExists(NewFolderNameStr))
			NewFolderNameStr=UniqueName(NewFolderNameStr, 11, 0)
		endif
		NewDataFolder/O $(NewFolderNameStr)
		setDataFolder root:Packages:Irena_UnifFit
		DataFolderName = "root:"+NewFolderNameStr+":"
		print "User chose to save data in:"+DataFolderName
	endif
	
	setDataFolder $DataFolderName
	string tempname 
	variable ii=0, i
	For(ii=0;ii<1000;ii+=1)
		tempname="UnifiedFitIntensity_"+num2str(ii)
		if (checkname(tempname,1)==0)
			break
		endif
	endfor
	LastSavedUnifOutput=ii
	Duplicate /O tempUnifiedFitIntensity, $tempname
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm")
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	print "Saved into folder : "+GetDataFolder(1)+" Unified fit result : "+tempname

	tempname="UnifiedFitQvector_"+num2str(ii)
	Duplicate /O tempUnifiedFitQvector, $tempname
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	
	//and now local fits also
	if(ExportLocalFits)
		//export background as flat wave...
		if(NumberOfLevels>0)	//at least Level 1 must exist!
			Wave LevelUnified=$("root:Packages:Irena_UnifFit:Level1Unified")
			tempname="UniLocalLevel0Unified_"+num2str(ii)
			Duplicate /O LevelUnified, $tempname
			Wave ModelLevelInt = $tempname
			NVAR SASBackground = root:Packages:Irena_UnifFit:SASBackground
			ModelLevelInt = SASBackground
			IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
			IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm")
			IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
		endif		
		//and now all used levels. 
		For(i=1;i<=NumberOfLevels;i+=1)
			Wave FitIntPowerLaw=$("root:Packages:Irena_UnifFit:FitLevel"+num2str(i)+"Porod")
			Wave FitIntGuinier=$("root:Packages:Irena_UnifFit:FitLevel"+num2str(i)+"Guinier")
			Wave LevelUnified=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Unified")
			tempname="UniLocalLevel"+num2str(i)+"Unified_"+num2str(ii)
			Duplicate /O LevelUnified, $tempname
			IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
			IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm")
			IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
			tempname="UniLocalLevel"+num2str(i)+"Pwrlaw_"+num2str(ii)
			Duplicate /O FitIntPowerLaw, $tempname
			IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
			IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm")
			IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
			tempname="UniLocalLevel"+num2str(i)+"Guinier_"+num2str(ii)
			Duplicate /O FitIntGuinier, $tempname
			IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
			IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm")
			IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
		endfor
		print "Saved also the local fits for the Unified fit." 
	endif
	setDataFolder root:Packages:Irena_UnifFit

	Killwaves/Z tempUnifiedFitIntensity,tempUnifiedFitQvector
	setDataFolder OldDf
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************



Window ExportToXLSFilePanel() 
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(562.2,177.8,1099.2,518)
	ModifyPanel cbRGB=(0,52224,52224)
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 48,34,"Export Unified Results to Tab Delimited Excel-Type File"
	DrawText 4,112,"1) "
	DrawText 223,106,"2) Iterate"
	DrawText 9,209,"3) Finally Open with 1) and save copy"
	SetDrawEnv linethick= 2
	DrawLine 16,222,517,222
	DrawText 25,267,"1) Erase Old Notebook (above)"
	DrawText 24,327,"3) Finally Open with 1) and Save Copy"
	SetDrawEnv fsize= 18,fstyle= 1
	DrawText 225,248,"Auto Save All"
	Button Add_New_Results_to_XLS,pos={290,78},size={172,45},proc=IR1A_InputPanelButtonXLSProc,title="Select Fit Result to add"
	PopupMenu SelectDataFolderXLS,pos={192,45},size={336,24},proc=IR1A_PanelPopupControlXLS,title="Data: "
	PopupMenu SelectDataFolderXLS,help={"Select folder containing your SAS data"}
	PopupMenu SelectDataFolderXLS,mode=17,popvalue="---",value= #"\"---;\"+IR3D_GenStringOfFolders(\"root:\",root:Packages:Irena_UnifFit:UseIndra2Data,0,0,0,\"\")"
	Button Add_Last_Results_to_XLS01,pos={291,131},size={172,45},proc=IR1A_InputPanelButtonXLSProc,title="Add last Results to XLS"
	Button Start_Erase_XLS_Notebook,pos={19,91},size={195,33},proc=IR1A_InputPanelButtonXLSProc,title="Erase Old Notebook (BtoFront)"
	Button AutoSaveXLS,pos={306,261},size={172,45},proc=IR1A_InputPanelButtonXLSProc,title="2) Auto Save All Latest Fits"
EndMacro

//************************************************************************************************ *****************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_InputPanelButtonXLSProc(ctrlName) : ButtonControl
	String ctrlName

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit
	
	if (cmpstr(ctrlName,"AutoSaveXLS")==0)
		AutoSaveXLSResults()
	endif
	
	if (cmpstr(ctrlName,"Add_New_Results_to_XLS")==0)
		//here goes what is done, when user pushes Graph button
		SVAR DFloc=root:Packages:Irena_UnifFit:DataFolderName
		//SVAR DFInt=root:Packages:Irena_UnifFit:IntensityWaveName
		//SVAR DFQ=root:Packages:Irena_UnifFit:QWaveName
		//SVAR DFE=root:Packages:Irena_UnifFit:ErrorWaveName
		variable IsAllAllRight=1
		if (cmpstr(DFloc,"---")==0)
			IsAllAllRight=0
		endif
		
		if (IsAllAllRight)
			IR1A_RecoverOldParametersXLS()
			//IR1A_FixTabsInPanel()
			//IR1_GraphMeasuredData()
			NVAR ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
			//IR1A_DisplayLocalFits(ActiveTab)
			//IR1A_AutoUpdateIfSelected()
			//MoveWindow /W=IR1_logLogPlot 285,37,760,337
			//MoveWindow /W=IR1_IQ4_Q_Plot 285,360,760,600
		else
			Abort "Data not selected properly"
		endif
	endif
	
	if (cmpstr(ctrlName,"Add_Last_Results_to_XLS01")==0)
		//here goes what is done, when user pushes Add last results button
		SVAR DFloc=root:Packages:Irena_UnifFit:DataFolderName
		//SVAR DFInt=root:Packages:Irena_UnifFit:IntensityWaveName
		//SVAR DFQ=root:Packages:Irena_UnifFit:QWaveName
		//SVAR DFE=root:Packages:Irena_UnifFit:ErrorWaveName
		IsAllAllRight=1
		if (cmpstr(DFloc,"---")==0)
			IsAllAllRight=0
		endif
		
		if (IsAllAllRight)
			//**********************************
			IR1A_ExportASCII_ToXLS_notebook()
		else
			Abort "Data not selected properly"
		endif
	endif
	
	
	if(cmpstr(ctrlName,"Start_Erase_XLS_Notebook")==0)
		//Erase the old notebook that is it if it exists
		DoWindow/F NotebookXLS
	endif

	
	setDataFolder oldDF
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


//Function IR1A_XLS_Output_PanelButtonProc(ctrlName) : ButtonControl
//	String ctrlName
//
//	DFref oldDf= GetDataFolderDFR()

//	setDataFolder root:Packages:Irena_UnifFit
//
//	if (cmpstr(ctrlName,"Add_NewData_to_XLS")==0)
//		//here goes what is done, when user pushes "Add new fit results to XLS" button
//		SVAR DFloc=root:Packages:Irena_UnifFit:DataFolderName
//		//SVAR DFInt=root:Packages:Irena_UnifFit:IntensityWaveName
//		//SVAR DFQ=root:Packages:Irena_UnifFit:QWaveName
//		//SVAR DFE=root:Packages:Irena_UnifFit:ErrorWaveName
//		variable IsAllAllRight=1
//		if (cmpstr(DFloc,"---")==0)
//			IsAllAllRight=0
//		endif
//
//print "hello out there again"
//		if (IsAllAllRight)
//			IR1A_RecoverOldParametersXLS()
//			//IR1A_FixTabsInPanel()
//			//IR1_GraphMeasuredData()
//			NVAR ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
//			//IR1A_DisplayLocalFits(ActiveTab)
//			//IR1A_AutoUpdateIfSelected()
//			//MoveWindow /W=IR1_logLogPlot 285,37,760,337
//			//MoveWindow /W=IR1_IQ4_Q_Plot 285,360,760,600
//		else
//			Abort "Data not selected properly"
//		endif
//	endif
//	
//	setDataFolder oldDF
//end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_RecoverOldParametersXLS()
	
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR SASBackgroundError=root:Packages:Irena_UnifFit:SASBackgroundError
	SVAR DataFolderName=root:Packages:Irena_UnifFit:DataFolderName
	

	variable DataExists=0,i
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(DataFolderName, 2)
	string tempString
	if (stringmatch(ListOfWaves, "*UnifiedFitIntensity*" ))
		string ListOfSolutions=""
		For(i=0;i<itemsInList(ListOfWaves);i+=1)
			if (stringmatch(stringFromList(i,ListOfWaves),"*UnifiedFitIntensity*"))
				tempString=stringFromList(i,ListOfWaves)
				Wave tempwv=$(DataFolderName+tempString)
				tempString=stringByKey("UsersComment",note(tempwv),"=")
				ListOfSolutions+=stringFromList(i,ListOfWaves)+"*  "+tempString+";"
			endif
		endfor
		DataExists=1
		string ReturnSolution=""
		Prompt ReturnSolution, "Select solution to Save in XLS", popup,  ListOfSolutions+";No Solutions Found"
		DoPrompt "Previous solutions found, select one to Save in XLS", ReturnSolution
		if (V_Flag)
			abort
		endif
	endif

	if (DataExists==1 && cmpstr("No Solutions Found", ReturnSolution)!=0)
		ReturnSolution=ReturnSolution[0,strsearch(ReturnSolution, "*", 0 )-1]
		Wave/Z OldDistribution=$(DataFolderName+ReturnSolution)

		string OldNote=note(OldDistribution)
		NumberOfLevels=NumberByKey("NumberOfModelledLevels", OldNote,"=")
		SASBackground =NumberByKey("SASBackground", OldNote,"=")
		SASBackgroundError =NumberByKey("SASBackgroundError", OldNote,"=")
		For(i=1;i<=NumberOfLevels;i+=1)		
			IR1A_RecoverOneLevelParamXLS(i,OldNote)	
		endfor
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_RecoverOneLevelParamXLS(i,OldNote)	
	variable i
	string OldNote

	
	NVAR Rg=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Rg")
	NVAR G=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"G")
	NVAR P=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"P")
	NVAR B=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"B")
	NVAR ETA=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"ETA")
	NVAR PACK=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"PACK")
	NVAR RgCO=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"RgCO")
	NVAR RgError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"RgError")
	NVAR GError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"GError")
	NVAR PError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"PError")
	NVAR BError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"BError")
	NVAR ETAError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"ETAError")
	NVAR PACKError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"PACKError")
	NVAR RgCOError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"RgCOError")
	NVAR K=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"K")
	NVAR Corelations=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Corelations")
	NVAR MassFractal=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"MassFractal")
	NVAR Invariant =$("Level"+num2str(i)+"Invariant")
	NVAR SurfaceToVolumeRatio =$("Level"+num2str(i)+"SurfaceToVolRat")

	Rg=NumberByKey("Level"+num2str(i)+"Rg", OldNote,"=")
	RgError=NumberByKey("Level"+num2str(i)+"RgError", OldNote,"=")
	G=NumberByKey("Level"+num2str(i)+"G", OldNote,"=")
	GError=NumberByKey("Level"+num2str(i)+"GError", OldNote,"=")
	P=NumberByKey("Level"+num2str(i)+"P", OldNote,"=")
	PError=NumberByKey("Level"+num2str(i)+"PError", OldNote,"=")
	B=NumberByKey("Level"+num2str(i)+"B", OldNote,"=")
	BError=NumberByKey("Level"+num2str(i)+"BError", OldNote,"=")
	ETA=NumberByKey("Level"+num2str(i)+"ETA", OldNote,"=")
	ETAError=NumberByKey("Level"+num2str(i)+"ETAError", OldNote,"=")
	PACK=NumberByKey("Level"+num2str(i)+"PACK", OldNote,"=")
	PACKError=NumberByKey("Level"+num2str(i)+"PACKError", OldNote,"=")
	RgCO=NumberByKey("Level"+num2str(i)+"RgCO", OldNote,"=")
	RgCOError=NumberByKey("Level"+num2str(i)+"RgCOError", OldNote,"=")
	K=NumberByKey("Level"+num2str(i)+"K", OldNote,"=")
	Corelations=NumberByKey("Level"+num2str(i)+"Corelations", OldNote,"=")
	MassFractal=NumberByKey("Level"+num2str(i)+"MassFractal", OldNote,"=")
	Invariant=NumberByKey("Level"+num2str(i)+"Invariant", OldNote,"=")
	SurfaceToVolumeRatio=NumberByKey("Level"+num2str(i)+"SurfaceToVolumeRatio", OldNote,"=")
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_PanelPopupControlXLS(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit

	if (cmpstr(ctrlName,"SelectDataFolderXLS")==0)
		//here we do what needs to be done when we select data folder
		SVAR Dtf=root:Packages:Irena_UnifFit:DataFolderName
		Dtf=popStr
		//PopupMenu IntensityDataName mode=1
		//PopupMenu QvecDataName mode=1
		//PopupMenu ErrorDataName mode=1
	endif
	
	setDataFolder oldDF

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_ExportASCII_ToXLS_notebook()

	//here we need to copy the export results out of Igor
	//before that we need to also attach note to teh waves with the results
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit//:XLS_Export
	
	//Wave OriginalQvector=root:Packages:Irena_UnifFit:OriginalQvector
	//Wave OriginalIntensity=root:Packages:Irena_UnifFit:OriginalIntensity
	//Wave OriginalError=root:Packages:Irena_UnifFit:OriginalError
	//Wave UnifiedFitIntensity=root:Packages:Irena_UnifFit:UnifiedFitIntensity
	
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	SVAR DataFolderName=root:Packages:Irena_UnifFit:DataFolderName
	//SVAR XLS_ExportString=root:Packages:Irena_UnifFit:XLS_Export
	
	//Duplicate/O OriginalQvector, tempOriginalQvector
	//Duplicate/O OriginalIntensity, tempOriginalIntensity
	//Duplicate/O OriginalError, tempOriginalError
	//Duplicate/O UnifiedFitIntensity, tempUnifiedFitIntensity
	//string ListOfWavesForNotes="tempOriginalQvector;tempOriginalIntensity;tempOriginalError;tempUnifiedFitIntensity;"
	
	//IR1A_AppendWaveNote(ListOfWavesForNotes)

	//string Comments=""//Record of Data evaluation with Irena SAS modeling macros using UNIFIED fit model;"
	//Comments+="For details on method see: http://www.eng.uc.edu/~gbeaucag/PDFPapers/Beaucage2.pdf, Beaucage1.pdf, and ma970373t.pdf;"
	//Comments+="Intensity is modelled using formula: Ii(q) = Gi exp(-q^2Rgi^2/3) + exp(-q^2Rg(i-1)^2/3)Bi {[erf(q Rgi/sqrt(6))]^3/q}^Pi;where i is level number;"
	//Comments+="Note that there are variations on this formula if corelations and mass fractal are assumed, please check references;"
	//Comments+=note(tempUnifiedFitIntensity)//+"Qvector[A]\tExperimental intensity[1/cm]\tExperimental error\tUnified Fit model intensity[1/cm]\r"
	//variable pos=0
	//variable ComLength=strlen(Comments)
	//Will write Level 1 G Sg Rg sRg B sB P sP eta seta pack spack Level 2 G Sg Rg sRg B sB P sP eta seta pack spack Level 3 Level 4  etc
	
	String nb = "NotebookXLS"
	//Make notebook and Write titles if it doesn't exist
	variable count=1
	if(WinType("NotebookXLS")==0)//if there is no existing notebook by this name
		NewNotebook/N=$nb/F=0/V=0/K=0/W=(5.25,40.25,558,408.5) as "XLS_Export_Notebook"
		Notebook $nb text="Filename	NumberOfLevels	"
		Do 
			Notebook $nb text="Level"+num2str(count)+"G"+"\t"
			Notebook $nb text="Level"+num2str(count)+"GError"+"\t"
			
			Notebook $nb text="Level"+num2str(count)+"Rg"+"\t"
			Notebook $nb text="Level"+num2str(count)+"RgError"+"\t"
			
			Notebook $nb text="Level"+num2str(count)+"B"+"\t"
			Notebook $nb text="Level"+num2str(count)+"BError"+"\t"
			
			Notebook $nb text="Level"+num2str(count)+"P"+"\t"
			Notebook $nb text="Level"+num2str(count)+"PError"+"\t"
			
			Notebook $nb text="Level"+num2str(count)+"RgCO"+"\t"
			Notebook $nb text="Level"+num2str(count)+"RgCOError"+"\t"
			
			Notebook $nb text="Level"+num2str(count)+"Eta"+"\t"
			Notebook $nb text="Level"+num2str(count)+"EtaError"+"\t"
			
			Notebook $nb text="Level"+num2str(count)+"Pack"+"\t"
			Notebook $nb text="Level"+num2str(count)+"PackError"+"\t"
			
			Notebook $nb text="Level"+num2str(count)+"Mass Frac?"+"\t"
			Notebook $nb text="Level"+num2str(count)+"S/V"+"\t"
			Notebook $nb text="Level"+num2str(count)+"DOA"+"\t"
			
			count+=1
		while (count<(NumberOfLevels+1))
		Notebook $nb text="\r"
	endif
	
	count=1
	string varname
	string filename1
	filename1=StringFromList(ItemsInList(DataFolderName,":")-1, DataFolderName,":")
	Notebook $nb text=filename1+"\t"+num2str(NumberOfLevels)+"\t"
	Do 
		varname=("Level"+num2str(count)+"G")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"GError")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		
		varname=("Level"+num2str(count)+"Rg")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"RgError")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		
		varname=("Level"+num2str(count)+"B")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"BError")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		
		varname=("Level"+num2str(count)+"P")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"PError")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		
		varname=("Level"+num2str(count)+"RgCO")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"RgCOError")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		
		varname=("Level"+num2str(count)+"Eta")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"EtaError")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		
		varname=("Level"+num2str(count)+"Pack")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"PackError")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		
		varname=("Level"+num2str(count)+"MassFractal")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"SurfacetoVolRat")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"DegreeofAggreg")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		
		count+=1
	while (count<(NumberOfLevels+1))
	Notebook $nb text="\r"

	
	//variable refnum

	//Open/D/T=".txt"/M="Select file to save data to" refnum as filename1
	//filename1=S_filename
	//if (strlen(filename1)==0)
	//	abort
	//endif
	
	
	
	
	//SaveNotebook $nb as filename1
	//DoWindow /K $nb
	//Save/A/G/M="\r\n" tempOriginalQvector,tempOriginalIntensity,tempOriginalError,tempUnifiedFitIntensity as filename1	 
	


	//Killwaves tempOriginalQvector,tempOriginalIntensity,tempOriginalError,tempUnifiedFitIntensity
	setDataFolder OldDf
end


//************************************************************************************************
//AutoSave
//************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function AutoSaveXLSResults()
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena_UnifFit
	nvar UseIndra2Data
	string FolderNames=IN2G_NewFindFolderWithWaveTypes("root:", 10, "*", 1)
	//Here you do the save to a notebook
	variable counter=0
	SVAR DataFolderName
	string Dtf
	string DFloc
	NVAR ActiveTab
	//variable IsAlAllRight
	do
		DataFolderName=stringfromlist(counter,FolderNames)
		Dtf=DataFolderName
		//At this point I have the folder so step 2a is done, SELECT DATA FOLDER
		//Next I need to find the last solution if there is one, i.e. this could be none or last
		//STEP 2b FIND NEWEST SOLUTION
		DFloc=DataFolderName
		IR1A_RecoLastFitParametersXLS()
		//ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
		
		//Next Save in the xls notebook
		//DFloc=DataFolderName
		//IsAllAllRight=1
		//if (cmpstr(DFloc,"---")==0)
		//	IsAllAllRight=0
		//endif
		
		//if (IsAllAllRight)
			//**********************************
		IR1A_ExportASCII_ToXLS_notebook()
		//else
		//	Abort "Data not selected properly"
		//endif
		counter+=1
	while(counter<(itemsInList(FolderNames,";")))
	
	//Then reset the conditions
	setDataFolder oldDF
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_RecoLastFitParametersXLS()
	
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR SASBackgroundError=root:Packages:Irena_UnifFit:SASBackgroundError
	SVAR DataFolderName=root:Packages:Irena_UnifFit:DataFolderName
	
	variable DataExists=0,i
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(DataFolderName, 2)
	string tempString
	if (stringmatch(ListOfWaves, "*UnifiedFitIntensity*" ))
		string ListOfSolutions=""
		For(i=0;i<itemsInList(ListOfWaves);i+=1)
			if (stringmatch(stringFromList(i,ListOfWaves),"*UnifiedFitIntensity*"))
				tempString=stringFromList(i,ListOfWaves)
				Wave tempwv=$(DataFolderName+tempString)
				tempString=stringByKey("UsersComment",note(tempwv),"=")
				ListOfSolutions+=stringFromList(i,ListOfWaves)+"*  "+tempString+";"
			endif
		endfor
		DataExists=1
		//Return the last solution so number in list minus 1
		string ReturnSolution=stringFromList((itemsInList(ListOfSolutions)-1),ListOfSolutions)
		//Prompt ReturnSolution, "Select solution to Save in XLS", popup,  ListOfSolutions+";No Solutions Found"
		//DoPrompt "Previous solutions found, select one to Save in XLS", ReturnSolution
		//if (V_Flag)
		//	abort
		//endif
	else//This is if there is no solution
		string ReturnString="No Solutions Found"
	endif

	if (DataExists==1 && cmpstr("No Solutions Found", ReturnSolution)!=0)
		ReturnSolution=ReturnSolution[0,strsearch(ReturnSolution, "*", 0 )-1]
		Wave/Z OldDistribution=$(DataFolderName+ReturnSolution)

		string OldNote=note(OldDistribution)
		NumberOfLevels=NumberByKey("NumberOfModelledLevels", OldNote,"=")
		SASBackground =NumberByKey("SASBackground", OldNote,"=")
		SASBackgroundError =NumberByKey("SASBackgroundError", OldNote,"=")
		For(i=1;i<=NumberOfLevels;i+=1)		
			IR1A_RecoverOneLevelParamXLS(i,OldNote)	
		endfor
	endif
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

