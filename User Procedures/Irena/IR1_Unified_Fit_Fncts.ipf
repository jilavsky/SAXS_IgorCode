#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.17

//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

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



Function IR1A_UnifiedCalculateIntensity()

	setDataFolder root:Packages:Irena_UnifFit

	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
	Wave OriginalIntensity
	Duplicate/O OriginalIntensity, UnifiedFitIntensity, UnifiedIQ4
	Redimension/D UnifiedFitIntensity, UnifiedIQ4
	Wave OriginalQvector
	Duplicate/O OriginalQvector, UnifiedFitQvector, UnifiedQ4
	Redimension/D UnifiedFitQvector, UnifiedQ4
	UnifiedQ4=UnifiedFitQvector^4
	
	
	UnifiedFitIntensity=0
	
	variable i
	
	for(i=1;i<=NumberOfLevels;i+=1)	// initialize variables;continue test
		IR1A_UnifiedCalcIntOne(i)
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
	
	UnifiedIQ4=UnifiedFitIntensity*UnifiedQ4
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1A_UnifiedCalcIntOne(level)
	variable level
	
	setDataFolder root:Packages:Irena_UnifFit
	Wave OriginalIntensity
	Wave OriginalQvector
	
	Duplicate/O OriginalIntensity, TempUnifiedIntensity
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
	string oldDf=GetDataFolder(1)
	
	setDataFolder root:Packages:Irena_UnifFit
	
	Wave OriginalIntensity
	Wave OriginalQvector

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
		Pp = abs((log(OriginalIntensity[pcsr(A)])-log(OriginalIntensity[pcsr(B)]))/(log(OriginalQvector[pcsr(B)])-log(OriginalQvector[pcsr(A)])))
	else
		//ntohing to do, we will not be changing P
	endif
	variable LocalB
	if (MassFractal)
		LocalB=(G*Pp/Rg^Pp)*exp(gammln(Pp/2))
	else
		LocalB=OriginalIntensity[pcsr(A)]*(OriginalQvector[pcsr(A)])^Pp
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
	//FuncFit fails if contraints are applied to parameter, which is held....
	//therefore we need to make sure, that if user helds the Porod constant, he/she does not run FuncFit with Constaraints..
	//modifed 12 20 2004 to use fit at once function to allow use on smeared data
	DoWindow IR1_LogLogPlotU
	if(V_Flag)
		DoWindow/F IR1_LogLogPlotU
	else
		abort
	endif
	if(strlen(CsrWave(A))<1 || strlen(CsrWave(B))<1)
		beep
		SetDataFolder oldDf
		abort "Set both cursors before fitting"
	endif
	
	if (FitP)
		FuncFit/Q/H=(num2str(abs(FitB-1))+num2str(abs(FitP-1)))/N IR1_PowerLawFitAllATOnce New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave  /C=T_Constraints 
		//FuncFit/H=(num2str(abs(FitB-1))+num2str(abs(FitP-1)))/N IR1_PowerLawFit New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave  /C=T_Constraints 
	else
		FuncFit/Q/H=(num2str(abs(FitB-1))+num2str(abs(FitP-1)))/N IR1_PowerLawFitAllATOnce New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave 
		//FuncFit/H=(num2str(abs(FitB-1))+num2str(abs(FitP-1)))/N IR1_PowerLawFit New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave 
	endif
	
//	FuncFit/H=(num2str(abs(FitB-1))+num2str(abs(FitP-1)))/N IR1_PowerLawFit New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /W=OriginalError /I=1 /C=T_Constraints 

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
	string oldDf=GetDataFolder(1)
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
	if (strlen(CsrWave(A))==0 || strlen(CsrWave(B))==0)
		beep
		abort "Both Cursors Need to be set in Log-log graph on wave OriginalIntensity"
	endif
	IR1A_SetErrorsToZero()
//	Wave w=root:Packages:Irena_UnifFit:CoefficientInput
//	Wave/T CoefNames=root:Packages:Irena_UnifFit:CoefNames		//text wave with names of parameters
	variable LocalRg = 2*pi/((OriginalQvector[pcsr(A)]+OriginalQvector[pcsr(B)])/2)
	variable LocalG = (OriginalIntensity[pcsr(A)]+OriginalIntensity[pcsr(B)])/2
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
	DoWIndow/F IR1_LogLogPlotU

	if(strlen(CsrWave(A))<1 || strlen(CsrWave(B))<1)
		beep
		SetDataFolder oldDf
		abort "Set both cursors before fitting"
	endif
	Variable V_FitError=0			//This should prevent errors from being generated
	//modifed 12 20 2004 to use fit at once function to allow use on smeared data

	FuncFit/Q/H=(num2str(abs(FitG-1))+num2str(abs(FitRg-1)))/N IR1_GuinierFitAllAtOnce New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave 
//	FuncFit/H=(num2str(abs(FitG-1))+num2str(abs(FitRg-1)))/N IR1_GuinierFit New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave 

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

	string WvList=TraceNameList("IR1_LogLogPlotU", ",", 1 )
	WvList = GrepList(WvList, "FitLevel.Porod" , 0, ","  )
	Execute("RemoveFromGraph /W=IR1_LogLogPlotU /Z "+ WvList[0,strlen(WvList)-2])

	 WvList=TraceNameList("IR1_IQ4_Q_PlotU", ",", 1 )
	WvList = GrepList(WvList, "FitLevel.PorodIQ4" , 0, ","  )
	Execute("RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z "+ WvList[0,strlen(WvList)-2])

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
			
		GetAxis /W=IR1_LogLogPlotU /Q left
		AppendToGraph /W=IR1_LogLogPlotU FitInt vs OriginalQvector
		ModifyGraph /W=IR1_LogLogPlotU lsize($(FitIntName))=1,rgb($(FitIntName))=(0,65280,0)
		SetAxis /W=IR1_LogLogPlotU left V_min, V_max

		GetAxis /W=IR1_IQ4_Q_PlotU /Q left
		AppendToGraph /W=IR1_IQ4_Q_PlotU FitIntIQ4 vs OriginalQvector
		ModifyGraph /W=IR1_IQ4_Q_PlotU lsize($(FitIntNameIQ4))=1,rgb($(FitIntNameIQ4))=(0,65280,0)
		SetAxis /W=IR1_IQ4_Q_PlotU left V_min, V_max
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
	string WvList=TraceNameList("IR1_LogLogPlotU", ",", 1 )
	WvList = GrepList(WvList, "FitLevel.Guinier" , 0, ","  )
	Execute("RemoveFromGraph /W=IR1_LogLogPlotU /Z "+ WvList[0,strlen(WvList)-2])

	 WvList=TraceNameList("IR1_IQ4_Q_PlotU", ",", 1 )
	WvList = GrepList(WvList, "FitLevel.GuinierIQ4" , 0, ","  )
	Execute("RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z "+ WvList[0,strlen(WvList)-2])

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
			
		DoUpdate
		GetAxis /W=IR1_LogLogPlotU /Q left
		AppendToGraph /W=IR1_LogLogPlotU FitInt vs OriginalQvector
		ModifyGraph /W=IR1_LogLogPlotU lsize($(FitIntName))=1,rgb($(FitIntName))=(0,0,65280),lstyle($(FitIntName))=3
		SetAxis /W=IR1_LogLogPlotU left V_min, V_max

		GetAxis /W=IR1_IQ4_Q_PlotU /Q left
		AppendToGraph /W=IR1_IQ4_Q_PlotU FitIntIQ4 vs OriginalQvector
		ModifyGraph /W=IR1_IQ4_Q_PlotU lsize($(FitIntNameIQ4))=1,rgb($(FitIntNameIQ4))=(0,0,65280),lstyle($(FitIntNameIQ4))=3
		SetAxis /W=IR1_IQ4_Q_PlotU left V_min, V_max
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

	string WvList=TraceNameList("IR1_LogLogPlotU", ",", 1 )
	WvList = GrepList(WvList, "Level.Unified" , 0, ","  )
	Execute("RemoveFromGraph /W=IR1_LogLogPlotU /Z "+ WvList[0,strlen(WvList)-2])

	 WvList=TraceNameList("IR1_IQ4_Q_PlotU", ",", 1 )
	WvList = GrepList(WvList, "Level.UnifiedIQ4" , 0, ","  )
	Execute("RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z "+ WvList[0,strlen(WvList)-2])

	NVAR DisplayLocalFits
	
	if (DisplayLocalFits || overwride)	
	
		Wave OriginalIntensity
		Wave OriginalQvector
	
		Duplicate/O OriginalIntensity, $("Level"+num2str(Level)+"Unified"),$("Level"+num2str(Level)+"UnifiedIQ4") 
	
		Wave FitInt=$("Level"+num2str(Level)+"Unified")
		string FitIntName="Level"+num2str(Level)+"Unified"
		Wave FitIntIQ4=$("Level"+num2str(Level)+"UnifiedIQ4")
		string FitIntNameIQ4="Level"+num2str(Level)+"UnifiedIQ4"
		
		//NVAR G=$("Level"+num2str(level)+"G")
		//NVAR Rg=$("Level"+num2str(level)+"Rg")
	
		
		//FitInt=G*exp(-OriginalQvector^2*Rg^2/3)
		//FitIntIQ4=FitInt*OriginalQvector^4
		IR1A_UnifiedCalcIntOne(level)
		Wave TempUnifiedIntensity=root:Packages:Irena_UnifFit:TempUnifiedIntensity
		NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
		NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
		if(UseSMRData)
			duplicate/O  TempUnifiedIntensity, UnifiedFitIntensitySM
			IR1B_SmearData(TempUnifiedIntensity, OriginalQvector, SlitLengthUnif, UnifiedFitIntensitySM)
			TempUnifiedIntensity=UnifiedFitIntensitySM
			KillWaves/Z UnifiedFitIntensitySM
		endif
		FitInt=TempUnifiedIntensity
		FitIntIQ4=FitInt*OriginalQvector^4
		
		DoUpdate
		GetAxis /W=IR1_LogLogPlotU /Q left        
		AppendToGraph /W=IR1_LogLogPlotU FitInt vs OriginalQvector  
		ModifyGraph /W=IR1_LogLogPlotU lsize($(FitIntName))=1,rgb($(FitIntName))=(52224,0,41728),lstyle($(FitIntName))=13
		ModifyGraph /W=IR1_LogLogPlotU mode($(FitIntName))=4,marker($(FitIntName))=23,msize($(FitIntName))=1
		SetAxis /W=IR1_LogLogPlotU left V_min, V_max

		GetAxis /W=IR1_IQ4_Q_PlotU /Q left
		AppendToGraph /W=IR1_IQ4_Q_PlotU FitIntIQ4 vs OriginalQvector
		ModifyGraph /W=IR1_IQ4_Q_PlotU lsize($(FitIntNameIQ4))=1,rgb($(FitIntNameIQ4))=(52224,0,41728),lstyle($(FitIntNameIQ4))=13
		ModifyGraph /W=IR1_IQ4_Q_PlotU mode($(FitIntNameIQ4))=4,marker($(FitIntNameIQ4))=23,msize($(FitIntNameIQ4))=1
		SetAxis /W=IR1_IQ4_Q_PlotU left V_min, V_max
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
		Make/O/D/N=(Newnumpnts) SurfToVolQvec, SurfToVolInt, SurfToVolInvariant
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
		if (Porod>=3.95 && Porod<=4.05)
			SurfaceToVolRat=1e4*pi*B/Invariant//***DWS  This is not the suface to volume ratio.  S/V = piB/Q * (phi*(1-phi))
		else
			SurfaceToVolRat=NaN
		endif
		Invariant = Invariant * 10^24		//and now it is in cm-4
//		print Invariant
	endfor
	
	KillWaves/Z SurfToVolQvec, SurfToVolInt, SurfToVolInvariant
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
	endif
	DoWIndow/K/Z IR2U_UnifLogNormalSizeDist
end

//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_UnifiedEvaPanelFnct() : Panel
	//PauseUpdate; Silent 1		// building window...
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
	checkbox UseCsrInv pos={255,485},size={30,20},title="Calc inv btwn csrs",proc=IR2U_DWSCheckboxProc//***DWS
	checkbox UseCsrInv variable=root:Packages:Irena_AnalUnifFit:UseCsrInv,value=0//***DWS
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
	PopupMenu AvailableLevels,pos={230,140},size={109,20},proc=IR2U_PopMenuProc,title="Level:"
	PopupMenu AvailableLevels,help={"Select level to use for data analysis"}
	PopupMenu AvailableLevels,mode=1,popvalue="---", value=#"root:Packages:Irena_AnalUnifFit:AvailableLevels"


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

	SetVariable BrFract_dmin, pos={10,240}, size={120,20}, title="dmin = ", help={"Parameter as defined in the references"}, format="%.4g"
	SetVariable BrFract_dmin, variable=root:Packages:Irena_AnalUnifFit:BrFract_dmin, noedit=1,limits={-inf,inf,0}
	SetVariable BrFract_c, pos={170,240}, size={120,20}, title="c =     ", help={"Parameter as defined in the references"}, format="%.4g"
	SetVariable BrFract_c, variable=root:Packages:Irena_AnalUnifFit:BrFract_c, noedit=1,limits={-inf,inf,0}
	SetVariable BrFract_z, pos={10,260}, size={120,20}, title="z =      ", help={"Parameter as defined in the references"}, format="%.4g"
	SetVariable BrFract_z, variable=root:Packages:Irena_AnalUnifFit:BrFract_z, noedit=1,limits={-inf,inf,0}
	SetVariable BrFract_fBr, pos={170,260}, size={120,20}, title="fBr = ", help={"Parameter as defined in the referecnes"}, format="%.4g"
	SetVariable BrFract_fBr, variable=root:Packages:Irena_AnalUnifFit:BrFract_fBr, noedit=1,limits={-inf,inf,0}
	SetVariable BrFract_fM, pos={10,280}, size={120,20}, title="fM =   ", help={"Parameter as defined in the references"}, format="%.4g"
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

	SetVariable PiBoverQ, pos={20,375}, size={300,20}, title="pi*B/Invariant [m^2/cm^2]    =     ", format="%.4g"
	SetVariable PiBoverQ, variable=root:Packages:Irena_AnalUnifFit:PiBoverQ, noedit=1, bodyWidth=80, disable=2, noedit=1
	SetVariable PiBoverQ,proc=IR2U_SetVarProc, help={"Calculated pi * B / invariant from Unif fit"}, limits={0,inf,0}//, fColor=(13107,13107,13107), valueColor=(13107,13107,13107)


	SetVariable SurfacePerVolume, pos={20,400}, size={300,20}, title="Surface per Volume  [m^2/cm^3]    =     ", format="%.4g"
	SetVariable SurfacePerVolume, variable=root:Packages:Irena_AnalUnifFit:SurfacePerVolume, noedit=1, bodyWidth=80, disable=2, noedit=1
	SetVariable SurfacePerVolume,proc=IR2U_SetVarProc, help={"Surface areea per volume in m2 per cm3"}, limits={0,inf,0}//, fColor=(13107,13107,13107), valueColor=(13107,13107,13107)


	SetVariable MinorityPhasePhi, pos={15,425}, size={180,20}, title="Volume Fraction  :    Minority = ", format="%.4g"
	SetVariable MinorityPhasePhi, variable=root:Packages:Irena_AnalUnifFit:MinorityPhasePhi, noedit=1, bodyWidth=80, disable=2, noedit=1
	SetVariable MinorityPhasePhi,proc=IR2U_SetVarProc, help={"Fractional volume of the minority phase "}, limits={0,inf,0}//, fColor=(13107,13107,13107), valueColor=(13107,13107,13107)

	SetVariable MajorityPhasePhi, pos={260,425}, size={110,20}, title="Majority = ", format="%.4g"
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
	SetVariable PartAnalRgFromVp, pos={20,365}, size={300,20}, title="Rg from Vp [A]    =     ", help={"Rg calculated from single particle volume"}, noedit=1
	SetVariable PartAnalRgFromVp, variable=root:Packages:Irena_AnalUnifFit:PartAnalRgFromVp,limits={0,inf,0}, proc=IR2U_SetVarProc, bodyWidth=80, format="%.4g"
	SetVariable PartAnalParticleDensity, pos={20,385}, size={300,20}, title="Particle density  [1/cm3]    =     ", help={"Single particle volume from I(Q=0) and invariant"}, noedit=1
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
	Button GetHelp, pos={210,273}, size={90,20}, title="Get Help"
	Button GetHelp proc=IR2U_ButtonProc, help={"Open notebook with some help"}
	Button CalcLogNormalDist, pos={225,482}, size={100,20}, title="Display Dist."
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
	
	string oldDf=GetDataFolder(1)
	
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
	ListOfVariables+="MajorityPhasePhi;MinorityPhasePhi;PiBoverQ;MinorityCordLength;MajorityCordLength;SurfacePerVolume;"//
	ListOfVariables+="BforTwoPhMat;PartAnalVolumeOfParticle;PartAnalRgFromVp;PartAnalParticleDensity;PartANalRHard;"//
	ListOfVariables+="TwoPhaseInvariantBetweenCursors;InvariantUsed;printexcel;printlogbook;UseCsrInv;"

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
				IR2U_RecalculateAppropriateVals()
			endif
			
			if(stringMatch(CtrlName,"IntensityDataName")||stringMatch(CtrlName,"SelectDataFolder"))
				IR2C_PanelPopupControl(pa)		
				SVAR Model=root:Packages:Irena_AnalUnifFit:Model
				Model = "---"
//				PopupMenu Model,win=UnifiedEvaluationPanel, mode=1,popvalue="---",value= root:Packages:Irena_AnalUnifFit:KnownModels
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
//***********************************************************
//***********************************************************

Function IR2U_SetControlsInPanel()

		SVAR Model=root:Packages:Irena_AnalUnifFit:Model
		NVAR CurrentResults = root:packages:Irena_AnalUnifFit:CurrentResults
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
				SetVariable MinorityPhasePhi, disable=0
				SetVariable MajorityPhasePhi, disable=0
				SetVariable TwoPhaseSystem_reference, disable=0
				SetVariable TwoPhaseSystem_comment1, disable=0
				PopupMenu MinorityPhaseVals, disable=0
				PopupMenu MajorityPhaseVals, disable=0
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
			//	SetVariable InvariantUserContrast2, disable=0
				Button OpenScattContrCalc, disable=0
				SetVariable BforTwoPhMat, disable=0
				SetVariable TwoPhaseSystem_reference, disable=0
				SetVariable TwoPhaseSystem_comment2, disable=0
				PopupMenu MinorityPhaseVals, disable=0
				PopupMenu MajorityPhaseVals, disable=0
			elseif(stringmatch(Model,"TwoPhaseSys3"))
				SetVariable TwoPhaseSys_MinName, disable=0
				SetVariable TwoPhaseSys_MajName, disable=0
				SetVariable SurfacePerVolume, disable=0
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
				SetVariable SampleBulkDensity2, disable=0
				PopupMenu MinorityPhaseVals, disable=0
				PopupMenu MajorityPhaseVals, disable=0
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
				DoWindow/F InvariantGraph
				Wave w = CsrWaveRef(A)
				if (!WaveExists(w))		// Cursor is not on any wave.
					Doalert 0, "Cursor is not on any graph\r Put cursor A on a trace"
					abort
				endif
				string WDF=getwavesDataFolder(w,3)
				setdatafolder $WDF
				dowindow/k InvariantGraph
				killwaves/z rwaveq2,qq2,rq2,backqq2,backrq2,frontqq2,frontrq2,rlevel1,qlevel1
				setdatafolder DF
			endif
			
	endif
	
	if(stringmatch(ctrlName, "PrentExcel"))
		NVAR value=root:packages:Irena_AnalUnifFit:printlogbook
		value=checked
	endif
	
	if(stringmatch(ctrlName, "includelogbook"))
		NVAR value=root:packages:Irena_AnalUnifFit:printlogbook
		value=checked
	endif
	
end

Function IR2U_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR CurrentResults=root:packages:Irena_AnalUnifFit:CurrentResults
			NVAR StoredResults=root:packages:Irena_AnalUnifFit:StoredResults
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
			IR2U_ClearVariables()
			SVAR Model=root:Packages:Irena_AnalUnifFit:Model
			Model = "---"
			PopupMenu Model,win=UnifiedEvaluationPanel, mode=1,popvalue="---",value= #"root:Packages:Irena_AnalUnifFit:KnownModels"
			IR2U_SetControlsInPanel()
			break
	endswitch

	return 0
End
//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_FindAvailableLevels()
	
	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults

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
	if(stringmatch(Model,"TwoPhase*"))	
		AvailableLevels+="All;"
	endif	
	String quote = "\""
	AvailableLevels = quote + AvailableLevels + quote
	PopupMenu AvailableLevels,win=UnifiedEvaluationPanel,mode=1,popvalue="---", value=#AvailableLevels
end
//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_CalculateInvariantVals()

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel
	NVAR InvariantValue = root:Packages:Irena_AnalUnifFit:InvariantValue
	NVAR InvariantUserContrast = root:Packages:Irena_AnalUnifFit:InvariantUserContrast
	NVAR InvariantPhaseVolume = root:Packages:Irena_AnalUnifFit:InvariantPhaseVolume

	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults

	if(SelectedLevel>=1)
		if(UseCurrentResults)
			NVAR Invariant=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"Invariant")
			InvariantValue = Invariant
		else
			//look up from wave note...
			InvariantValue = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"Invariant")
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

	string OldDf=GetDataFolder(1)
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

	string OldDf=GetDataFolder(1)
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
		BrFract_dmin  =BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2)
		BrFract_c  =BrFract_P2/(BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2))
		BrFract_z  =BrFract_G2/BrFract_G1
		BrFract_fBr =(1-(BrFract_G2/BrFract_G1)^(1/(BrFract_P2/(BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2)))-1))
		BrFract_fM  = (1-(BrFract_G2/BrFract_G1)^(1/((BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2)))-1))
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
		IR2U_TwoPhaseModelCalc()
	ENDIF
	
end

//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
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
			If (cmpstr(ba.ctrlName,"KillInvWindow")==0)				//Kill invariant window and waves  DWS
				string DF=getdatafolder(1)
				DoWindow/F InvariantGraph
				Wave w = CsrWaveRef(A)
				if (!WaveExists(w))		// Cursor is not on any wave.
					Doalert 0, "Cursor is not on any graph\r Put cursor A on a trace"
					abort
				endif
				string WDF=getwavesDataFolder(w,3)
				setdatafolder $WDF
				dowindow/k InvariantGraph
				killwaves/z rwaveq2,qq2,rq2,backqq2,backrq2,frontqq2,frontrq2,rlevel1,qlevel1,frontrwave
				setdatafolder DF
			endif
			If (cmpstr(ba.ctrlName,"Invariantbutt")==0)			
				IR2U_TwoPhaseModelCalc()		
			endif
			if(stringMatch(ba.ctrlName,"SaveToHistory"))//***DWS
				//here code to print results to history area
				NVAR  printlogbook=root:Packages:Irena_AnalUnifFit:printlogbook
				If (printlogbook==1)
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

Function IR2U_CalculateInvariantbutton()//***DWS lots of revisons as of 2013 12 02 and minor fix 10/1/2016
	string OldDf=GetDataFolder(1)
	
	variable extrapts=600 //number of points in extrapolation waves
	
	Variable overlap=1//number of overlaped points for Porod extrapolation
	
	SVAR rwavename=root:Packages:Irena_UnifFit:IntensityWaveName
	SVAR qwavename=root:Packages:Irena_UnifFit:QWavename
	SVAR swavename=root:Packages:Irena_UnifFit:IntensityWaveName
	SVAR datafoldername=root:Packages:Irena_UnifFit:DataFolderName
	NVAR majorityphi=root:Packages:Irena_AnalUnifFit:MajorityPhasePhi//phi is picked up from unified fit data evaluation panel
	NVAR dens=root:Packages:Irena_AnalUnifFit:SampleBulkDensity
	NVAR inv=root:Packages:Irena_AnalUnifFit:TwoPhaseInvariantBetweenCursors//***DWS
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
	setdatafolder root:Packages:Irena_UnifFit:		//do nto contaminate users data folder, just store it in Unified Fit folder... 
	Duplicate/o rwave,$"root:Packages:Irena_UnifFit:rwaveq2"
	wave rwaveq2=$"root:Packages:Irena_UnifFit:rwaveq2"
	 rwaveq2=rwave*qwave^2
	  DoWindow/F IR1_LogLogPlotU
	 If (0==WinType("IR1_LogLogPlotU" ))
	  	Doalert 0, "Load a unified fit in the Unified modeling input panel"
	  	abort
	 endif
	 if ((strlen(CsrInfo(A)) == 0)||(strlen(CsrInfo(B)) == 0))
	 	Doalert 0, "Cursors not on graph"
	 	abort
	 endif
	//bring graph to top
	variable npts=pcsr(b)-pcsr(a)+1
	make /o/n=(extrapts)  frontrwave,frontrq2,frontqq2,backrq2,backqq2
	duplicate/o rwave,rq2
	rq2=rwave*qwave^2	
	NVAR SelectedLevel=root:Packages:Irena_AnalUnifFit:SelectedLevel//level number selected for analysis.  can be NaN for "all"
	Variable SelectedLevelForB=SelectedLevel
	variable InitialselectedLevel=SelectedLevel//used to reset the panel at the end
	NVAR LNumOfLevels =root:Packages:Irena_UnifFit:NumberOfLevels//number of levels in the full unified fit
	NVAR B=$("root:Packages:irena_UnifFit:Level"+num2istr(SelectedLevel)+"B")
	If (numtype(selectedLevel)==2)//  SelectedLevel = "all",  If you pick all levels igor will take B for level 1---gets tricky here
				//Doalert 0, "using level-1 B"
				SelectedLevel=LNumOfLevels // use the top level when "all" is selected
				NVAR B=$("root:Packages:irena_UnifFit:Level"+num2istr(1)+"B")//uses level 1 for B when "all" is picked. DWS 2016 09 20 
				SelectedLevelForB=1
	endif
	NVAR PorodSlope=$("root:Packages:irena_UnifFit:Level"+num2istr(SelectedLevelForB)+"P")
	If (PorodSlope!=4)
		Doalert 0, "Porod Slope is not equal to -4"
	endif
	
	NVAR RgselectedLevel=$("root:Packages:irena_UnifFit:Level"+num2istr(SelectedLevel)+"Rg")//Rg is only used for caculating the invariant.
	NVAR G=$("root:Packages:irena_UnifFit:Level"+num2istr(SelectedLevel)+"G")
	frontqq2=(P+1)*qwave[pcsr(a)]/(extrapts)//first element can't be zero	 Sets limit of lowest q as qwave[pcsr(a)]/extrapts up to about qwave[pcsr(a)]
	IR2U_UnifiedCalcLowq_DWS(frontqq2,frontrwave, SelectedLevel)//calculates unified   IR2U_UnifiedCalcLowq_DWS(qwave,rwave, uptolevel)
	frontrq2=frontrwave*frontqq2^2
	variable maxqback=10*hcsr(B)//max q for porod extrapolation
	backqq2=qwave[pcsr(b)-overlap]+P*(maxqback-qwave[pcsr(b)-overlap])/extrapts	
	backrq2=B/backqq2^2
	 variable invariant=areaXY(qwave, rq2,hcsr(a), hcsr(b))+areaxy(frontqq2,frontrq2)+abs((B*hcsr(B)^-1))//extends with -4 exponent
	 variable QvFrontPart=(G*qwave[pcsr(a)]^3/3)+(qwave[pcsr(a)]^5*RgSelectedLevel^2/15)//analytical extension to low q  NOT USED
	inv=invariant//***DWS  Store the result so it can be used by   IR2U_TwoPhaseModelCalc()
	If(1)
		//Print B*hcsr(B)
		print "Qlowq using area = "+ num2str(areaxy(frontqq2,frontrq2))
		print "Qlowq  analytical (not used) = "+num2str( QvFrontPart)
		print  "Qdata part = "+ num2str(areaXY(qwave, rq2,hcsr(a), hcsr(b)))
		Print  "Qtail analytical = "+num2str(abs((B*hcsr(B)^-1)))
		print "Qtail using area (not used) = "+num2str (areaXY(backqq2, backrq2))
		Print "Qtotal = "+num2str (invariant)
		Print "B = "+num2str (B)
		Print "___________"
	endif
	NVAR TwoPhaseInvariantBetweenCursors=root:Packages:Irena_AnalUnifFit:TwoPhaseInvariantBetweenCursors
	TwoPhaseInvariantBetweenCursors=invariant*1e24
	variable Sv=(1e4*pi*B/invariant)*majorityphi*(1-majorityphi)
	variable majchord=4*majorityphi/Sv
	variable minchord=4* (1-majorityphi)/Sv
	//string outtext="Qv = "+num2str(invariant)+" cm^-4\rB = "+num2str(B)+ " cm-1Å-4"
	string outtext="Qv = "+num2str(invariant)+" cm^-1 Å^-3\rB = "+num2str(B)+ " cm-1Å-4"
	outtext=outtext+"\rpiB/Q = "+num2str(1e4*pi*B/invariant)+" m2/cm3\rSv = "+num2str(Sv)+" m2/cm3\rSm = "+num2str(Sv/dens)+" m2/g\rlmin = "+num2str(minchord*1e4)+" Å\rlmaj = "+num2str(majchord*1e4)+" Å"		
	dowindow/R/k InvariantGraph
	display/K=2  rq2 vs qwave as "q2 I(q) vs q"
	appendtograph frontrq2 vs frontqq2
	appendtograph backrq2 vs backqq2
	ModifyGraph rgb(frontrq2)=(8738,8738,8738)
	ModifyGraph rgb(backrq2)=(8738,8738,8738)
	Cursor /A=1  A  rq2  0
	Tag/C/N=text1/F=0/A=LC frontrq2,100,"Level Used = "+Num2str(LNumOfLevels)
	ModifyGraph grid=2,tick=2,mirror=1,fStyle=1,fSize=15,font="Times"
	Button KillInvWindow,pos={2,1},size={70,20},proc=IR2U_ButtonProc,title="Kill Window"	
	ModifyGraph log=0 //***DWS
	SetAxis bottom 1e-5,maxqback//***DWS
	ModifyGraph log=1
	Label left "\\F'arial'\\Z18I(q)·(q \\S2\\M)"
	Label bottom "\\F'arial'\\Z18q (A\\S-1\\M)"
	textbox/C/N=text1df/F=0/X=46.00/Y=30.00  outtext
	HideTools/A
	dowindow/c InvariantGraph
	SelectedLevel=InitialselectedLevel
	setDataFolder OldDf
	
	If ((numtype(invariant)==2))
		doAlert 0, "Pick a level";abort
	endif
End

//***********************************************************
//***********************************************************
//***********************************************************

Function  IR2U_SaveLogNormalDistData()

//	DoAlert 0, "IR2U_SaveLogNormalDistData is not yet finished"
	string OldDf=getDataFolder(1)
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

	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena_AnalUnifFit
	
	SVAR DF=root:Packages:Irena_UnifFit:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena_UnifFit:IntensityWaveName
	NVAR OriginalLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	SVAR SlectedBranchedLevels = root:Packages:Irena_AnalUnifFit:SlectedBranchedLevels
	variable level, UsesAll
	if(stringmatch(SlectedBranchedLevels,"---"))
		abort
	elseif(stringmatch(SlectedBranchedLevels,"All"))	//we use values from level 1 but summ all invariants...
		level=1
		UsesAll=1
	else
		level=str2num(SlectedBranchedLevels)
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
	NVAR TwoPhaseInvariantbtnCursors= root:Packages:Irena_AnalUnifFit:TwoPhaseInvariantBetweenCursors//***DWS
	NVAR TwoPhaseInvariant=root:Packages:Irena_AnalUnifFit:TwoPhaseInvariant
	NVAR UseCsrInv=root:Packages:Irena_AnalUnifFit:UseCsrInv//***DWS
	NVAR SelectedLevel=root:Packages:Irena_AnalUnifFit:SelectedLevel//level number selected for analysis.  can be NaN for "all"
	NVAR InvariantUsed= root:Packages:Irena_AnalUnifFit:InvariantUsed//***DWS
	variable Qv

	
	If (UseCsrInv)//***DWS
		IR2U_CalculateInvariantbutton()//***DWS
		Qv=TwoPhaseInvariantbtnCursors//***DWS
	elseif (UsesAll==1)		//use full invarient for all levels used in unified fit. Generates TempUnifiedIntensity wave used below
			Qv=1e24*IR2U_InvariantForMultipleLevels(OriginalLevels)//units cm-1 A-3 changed to cm-4
			TwoPhaseInvariantbtnCursors=Qv
	else
			Qv=Qvunified
			Twophaseinvariant=Qv//cm-4
	endif
			//print "invariant used = "+num2str(Qv)
			InvariantUsed=Qv//in cm-1A-3
			
	NVAR Contrast=root:Packages:Irena_AnalUnifFit:TwoPhaseMediaContrast		//Let's use the Scattering contrast calcualterif needed to ge this instead of this complciated mess...
	SVAR Model=root:Packages:Irena_AnalUnifFit:Model
	variable deltaSLD = (SLDDensityMajorityPhase*DensityMajorityPhase - SLDDensityMinorityPhase*DensityMinorityPhase)*10^10
	Contrast = (deltaSLD)^2
	
	variable densold, phi
	if(stringmatch(Model,"TwoPhaseSys1"))	
		if ((P<=3.95 ||P>=4.05))
			Doalert 0,"This method can be applied ONLY for P = 4"
		endif
		//method 1 analysis, not calibrated data, valid low-q data (relative invariant valid)
		MinorityPhasePhi =(SampleBulkDensity-DensityMajorityPhase)/(DensityMinorityPhase-DensityMajorityPhase)//Phi referes to minority phase phi(solid)
		MajorityPhasePhi  = 1-MinorityPhasePhi
		SurfacePerVolume=(1e-4*Pi*Bloc/Qv)*MajorityPhasePhi*MinorityPhasePhi   //m^2/cm^3 calculate from densities and Qp 
		MinorityCordLength = (4/SurfacePerVolume)*(MinorityPhasePhi)*10000
		MajorityCordLength = (4/SurfacePerVolume)*(1-MinorityPhasePhi)*10000
		PiBoverQ = SurfacePerVolume / (MajorityPhasePhi*MinorityPhasePhi)
		//end of method 1 analysis...
	elseif(stringmatch(Model,"TwoPhaseSys2"))	
		if ((P<=3.95 ||P>=4.05))
			Doalert 0,"This method can be applied ONLY for P = 4"
		endif
		//method 2 analysis, calibrated data, not valid  data (relative invariant invalid), need contrast to get anything... 
		MinorityPhasePhi =(SampleBulkDensity-DensityMajorityPhase)/(DensityMinorityPhase-DensityMajorityPhase)//Phi referes to minority phase phi(solid)
		MajorityPhasePhi  = 1-MinorityPhasePhi
		BforTwoPhMat = Bloc*1e-32
		SurfacePerVolume=(1e-4*Bloc/(2*pi*Contrast))   //m^2/cm^3 calculate from densities and Qp 
		MinorityCordLength = (4/SurfacePerVolume)*(MinorityPhasePhi)*10000
		MajorityCordLength = (4/SurfacePerVolume)*(1-MinorityPhasePhi)*10000
		//end of method 2
	elseif(stringmatch(Model,"TwoPhaseSys3"))	
		if ((P<=3.95 ||P>=4.05))
			Doalert 0,"This method can be applied ONLY for P = 4"
		endif
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
		MinorityCordLength = (4/SurfacePerVolume)*(MinorityPhasePhi)*10000
		MajorityCordLength = (4/SurfacePerVolume)*(1-MinorityPhasePhi)*10000
		PiBoverQ = SurfacePerVolume / (MajorityPhasePhi*MinorityPhasePhi)
	elseif(stringmatch(Model,"TwoPhaseSys4"))	
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
		MinorityCordLength = (4/SurfacePerVolume)*(MinorityPhasePhi)*10000
		MajorityCordLength = (4/SurfacePerVolume)*(1-MinorityPhasePhi)*10000
		PiBoverQ = SurfacePerVolume / (MajorityPhasePhi*MinorityPhasePhi)
	elseif(stringmatch(Model,"TwoPhaseSys5"))//particulate analysis	, calculate Vp from I(0) and Qinv
		MinorityPhasePhi =(SampleBulkDensity-DensityMajorityPhase)/(DensityMinorityPhase-DensityMajorityPhase)
		PartAnalVolumeOfParticle = (2 *Gloc*(pi^2))*(1-MinorityPhasePhi)/(Qv)
		PartAnalParticleDensity = MinorityPhasePhi/PartAnalVolumeOfParticle
		PartAnalRgFromVp = 1e8*sqrt(3/5)*(3*PartAnalVolumeOfParticle/(4*pi))^(1/3)
	elseif(stringmatch(Model,"TwoPhaseSys6"))//particulate analysis, calcualate Vp from Rg and get numdens from I(0)/(Contrast*Vp^2)	
		PartANalRHard = (Rgloc*sqrt(5/3))	//in A
		PartAnalVolumeOfParticle=((PartANalRHard*1e-8)^3)*4*pi/3	//calculated from RG, converted to cm
		Qv=2*(pi^2)*Gloc/PartAnalVolumeOfParticle  	//calculate Q from Rg and I(0)
		PartAnalParticleDensity = Gloc/(PartAnalVolumeOfParticle^2*Contrast)
		SurfacePerVolume = 1e-4*Bloc/((Contrast)*2*pi)
		MinorityPhasePhi =PartAnalParticleDensity*PartAnalVolumeOfParticle
		MajorityPhasePhi = 1 - MinorityPhasePhi

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
				IR1L_AppendAnyText( "    Results: minority chord ="+num2str(MinorityCordLength)+" [A]  MajorityChord = "+num2str(MajorityCordLength)+" [A] ")

		elseif(stringmatch(Model,"TwoPhaseSys2"))
			IR1L_AppendAnyText( "    Method 2:Contrast known;  B absolute.")
			IR1L_AppendAnyText( "    Minority phase : "+TwoPhaseSys_MinName+"          Majority phase : "+TwoPhaseSys_MajName)
			IR1L_AppendAnyText( "    Known: B= "+num2str(BforTwoPhMat)+"   [1/(A^4 cm^1)]")
			IR1L_AppendAnyText( "    Skeletal density = "+num2str(DensityMinorityPhase)+" [g/cm^3], Pore density = "+num2str(MajorityPhasePhi)+" [g/cm^3]")
			IR1L_AppendAnyText( "    Sample density = "+num2str(SampleBulkDensity)+" [g/cm^3]")
	 		IR1L_AppendAnyText( "    Contrast = "+num2str(Contrast)+"  [1/cm^4]")
	 		IR1L_AppendAnyText( "    Calculated: S/V = "+num2str(SurfacePerVolume)+" [m^2/cm^3] Per sample volume")
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
	
	
	elseif((excel==1)&&(StringMatch(where, "graph" )==0))//***DWS
		variable N=strlen(model)-1
		string mdl=model[N]
		variable SL=SelectedLevel
		If (numtype(SL)==2)//User chose all
			SL = 10//code for all levels	
		endif		
		SVAR IntensityWaveName=root:Packages:Irena_UnifFit:IntensityWaveName
		NVAR printlogbook=root:Packages:Irena_AnalUnifFit:printlogbook
		TEXT="rWave\tModel\tLvL\tIrenaLvls\tUseCsrs\tB[cm-1A-4]\tQ[Cm-1A-3]\tpiB/Q[m2/cm3]\tMinDens[g/cm3]\tMajDens[g/cm3]\tSamDens[g/cm3]\tphimin\tSv[m2/cm3]\tSm[m2/g]\tMinChord[A]\tMajChord[A]"
		TEXT+="\t10^-10xSLmin[cm/g]\t10^-10xSLmaj[cm/g]"
		string TEXT2=IntensityWaveName+"\t"+Mdl+"\t"+num2str(SL)+"\t"+num2str( LNumOfLevels) +"\t"+num2str(usecsrs)+"\t" +num2str(B*1e-28)+"\t"+num2str(Qv*1e-24)+"\t"+num2str(piBoverQ)
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
Function IR2U_UnifiedCalcLowq_DWS(qwave,rwave, uptolevel)//**DWS
	wave rwave,qwave
	Variable uptolevel
	string DF=getdatafolder(1)	
	
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
		variable Newnumpnts=numpnts(qwave)
		Make/O/D/N=(Newnumpnts) qUnifiedfit,rUnifiedfit,tempunifiedIntensity
		qUnifiedfit=qwave
		runifiedfit=0
		variable i
		for(i=1;i<=uptolevel;i+=1)	
				IR2U_UnifiedCalcIntOneX(qUnifiedfit,i,1)//qcutoff is zero for no cutoff    could cause a problem
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
	string OldDf=getDataFolder(1)
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
	PauseUpdate; Silent 1		// building window...
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
	
	string OldDf=getDataFolder(1)
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

	string OldDf=getDataFolder(1)
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

	string OldDf=getDataFolder(1)
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

	string OldDf=getDataFolder(1)
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
	TabControl DistTabs win=IR1A_ControlPanel, value=(LevelUsed-1)
	IR1A_TabPanelControl("",LevelUsed-1)
	//DoUpdate

	DoWindow ChisquaredAnalysis
	if(V_Flag)
		DoWindow/K ChisquaredAnalysis
	endif
	DoWindow ChisquaredAnalysis2
	if(V_Flag)
		DoWindow/K ChisquaredAnalysis2
	endif
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
	NVAR CoefEVNumSteps=root:Packages:Irena_UnifFit:CoefEVNumSteps
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
	
	DoWindow ChisquaredAnalysis
	if(V_Flag)
		DoWindow/K ChisquaredAnalysis
	endif
	DoWindow ChisquaredAnalysis2
	if(V_Flag)
		DoWindow/K ChisquaredAnalysis2
	endif
	variable levellow, levelhigh

	IR1_CreateResultsNbk()
	//IR1_AppendAnyText("Analyzed sample "+SampleFullName, 1)	
	IR1_AppendAnyText("Effect of data uncertainities on variability of parameters", 2)
	IR1_AppendAnyText(SampleFullName, 2)	
	IR1_AppendAnyText("  ", 0)
	IR1_AppendAnyText("Run "+num2str(CoefEVNumSteps)+" fittings using data modified by random Gauss noise within \"Errors\" ", 2)
	IR1_AppendAnyText("To get following statistical results ", 0)
	wavestats/Q ChiSquareValues
	variable MeanChiSquare=V_avg
	variable StdDevChiSquare=V_sdev
	IR1_AppendAnyText("Chi-square values : \taverage = "+num2str(MeanChiSquare)+"\tst. dev. = "+num2str(StdDevChiSquare), 0)	

	variable j
	string tempStrName
	For(j=0;j<numpnts(ConfEvCoefNames);j+=1)
		tempStrName=ConfEvCoefNames[j]
		Duplicate/Free/O/R=[j][] ConfEvEndValues, tempWv
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
	
	DoWindow ChisquaredAnalysis
	if(V_Flag)
		DoWindow/K ChisquaredAnalysis
	endif
	DoWindow ChisquaredAnalysis2
	if(V_Flag)
		DoWindow/K ChisquaredAnalysis2
	endif
	variable levellow, levelhigh

	if(FittedParameter)	//fitted parameter, chi-square analysis needs a bit different... 
		wavestats/Q ChiSquareValues
		variable MeanChiSquare=V_avg
		variable StdDevChiSquare=V_sdev
	
		Display/W=(35,44,555,335)/K=1 ChiSquareValues vs EndValues
		DoWindow/C/T ChisquaredAnalysis,ParamName+"Chi-squared analysis of "+SampleFullName
		Label left "Achieved Chi-squared"
		Label bottom "End "+ParamName+" value"
		ModifyGraph mirror=1
		ModifyGraph mode=3,marker=19
		SetAxis left (V_avg-1.5*(V_avg-V_min)),(V_avg+1.5*(V_max-V_avg))
		
		wavestats/Q EndValues
		variable MeanEndValue=V_avg
		variable StdDevEndValue=V_sdev
		Display/W=(35,44,555,335)/K=1 EndValues vs StartValues
		DoWindow/C/T ChisquaredAnalysis2,ParamName+" reproducibility analysis of "+SampleFullName
		Label left "End "+ParamName+" value"
		Label bottom "Start "+ParamName+" value"
		ModifyGraph mirror=1
		ModifyGraph mode=3,marker=19		
		variable TempDisplayRange=max(V_avg-V_min, V_max-V_avg)
		SetAxis left (V_avg-1.5*(TempDisplayRange)),(V_avg+1.5*(TempDisplayRange))
		duplicate/O ChiSquareValues, EndValuesGraphAvg, EndValuesGraphMin, EndValuesGraphMax
		EndValuesGraphAvg = V_avg
		EndValuesGraphMin = V_avg-V_sdev
		EndValuesGraphMax = V_avg+V_sdev
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
		
		Display/W=(35,44,555,335)/K=1 ChiSquareValues vs EndValues
		DoWindow/C/T ChisquaredAnalysis,ParamName+" Chi-squared analysis "
		Label left "Achieved Chi-squared"
		Label bottom ParamName+" value"
		ModifyGraph mirror=1
		ModifyGraph mode=3,marker=19
		Findlevels/Q/N=2 ChiSquareValues, ConfEvTargetChiSqRange*V_min
		if(V_Flag!=0)
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
			levellow=EndValues[W_FindLevels[0]]
			levelhigh=EndValues[W_FindLevels[1]]
			Tag/C/N=MinTagLL/F=0/L=2/TL=0/X=0.00/Y=30.00 $(nameofwave(ChiSquareValues)), W_FindLevels[0],"\\JCLow edge\r\\JC"+num2str(levellow)
			Tag/C/N=MinTagHL/F=0/L=2/TL=0/X=0.00/Y=30.00 $(nameofwave(ChiSquareValues)), W_FindLevels[1],"\\JCHigh edge\r\\JC"+num2str(levelhigh)
			//Tag/C/N=MinTag/F=0/L=2/TL=0/X=0.00/Y=50.00 $(nameofwave(ChiSquareValues)), V_minLoc,"Minimum chi-squared = "+num2str(V_min)+"\rat "+ParamName+" = "+num2str(EndValues[V_minLoc])+"\rRange : "+num2str(levellow)+" to "+num2str(levelhigh)
			Tag/C/N=MinTag/F=0/L=2/TL=0/X=0.00/Y=50.00 $(nameofwave(ChiSquareValues)), V_minLoc,"Minimum chi-squared = "+num2str(V_min)+"\rat "+ParamName+" = "+num2str(EndValues[V_minLoc])//+"\rRange : "+num2str(levellow)+" to "+num2str(levelhigh)
			AutoPositionWindow/M=0/R=IR1A_ConfEvaluationPanel ChisquaredAnalysis
			IR1_CreateResultsNbk()
	//		IR1_AppendAnyText("Analyzed sample "+SampleFullName, 1)	
			IR1_AppendAnyText("Unified fit evaluation of parameter "+ParamName, 2)
			IR1_AppendAnyText("  ", 0)
			IR1_AppendAnyText("Method used to evaluate parameter stability: "+Method, 0)	
			IR1_AppendAnyText("Minimum chi-squared found = "+num2str(V_min)+" for "+ParamName+"  = "+ num2str(EndValues[V_minLoc]), 0)
			IR1_AppendAnyText("Range of "+ParamName+" in which the chi-squared < "+num2str(ConfEvTargetChiSqRange)+"*"+num2str(V_min)+" is from "+num2str(levellow)+" to "+ num2str(levelhigh), 0)
			IR1_AppendAnyText("           **************************************************     ", 0)
			IR1_AppendAnyText("\"Simplistic presentation\" for publications :    >>>>   "+ParamName+" =  "+IN2G_roundToUncertainity(EndValues[V_minLoc], (levelhigh - levellow)/2,2),0)
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
	string OldDf=GetDataFOlder(1)
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
	string OldDf=GetDataFOlder(1)
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
		Notebook $nb ruler=Normal, fSize=14, fStyle=1, textRGB=(52428,1,1), text="Uncertainity evaluation for UF/Modeling II parameters\r"
		Notebook $nb fSize=-1, fStyle=1, textRGB=(0,1,3), text="\r"
		Notebook $nb text="This tool is used to estimate uncertainities for the fitted parameters. "
		Notebook $nb text="It is likely that the right uncertainity is some combination of the two implemented methods - or the larger one...", fStyle=-1, text="\r"
		Notebook $nb fStyle=1, text="\r"
		Notebook $nb text="1. \"Uncertainity effect\" \r", fStyle=-1
		//Notebook $nb text="1. Sequential, fix param", fStyle=-1
		Notebook $nb text="Evaluates the influence of DATA uncertainities on uncertainity of Unified fit or Modeling II parameter(s). "
		Notebook $nb text="Code varies Intensity data within user provided uncertainities (\"errors\"). All parameters currently selected for fitting are evaluted at once.\r"
		Notebook $nb fStyle=1, text="2. Uncertainity for individual parameters \r", fStyle=-1
		Notebook $nb text="Analysis of quality of fits achievable with tested parameter variation.  "
		Notebook $nb text="The tool will fix tested parameter within the user defined range and fit the other parameters to the data. Plot of achieved chi-squared as function of the fixed value of the tested parameter "
		Notebook $nb text="is used to estimate uncertainity. User needs to pick method of analysis as described below. User can analyze one parameter or create list of parameters and analyze them sequentially. \r"
		Notebook $nb text="\r"
		Notebook $nb text="All parameters which are supposed to be varied during analysis must have \"Fit?\" checkbox checked before the tool si started. Correct fitting limits may be set or use \"Fix fit limits\" checkbox. "
		Notebook $nb text="Range of data for fitting must be selected correctly with cursors (Unified fit) or set for data with controls (Modeling II). The code does not mo"
		Notebook $nb text="dify fitting range. \r"
		Notebook $nb text="\r"
		Notebook $nb text="For Modeling II : note, that at this time the only offically supported mode is for using Single input data set. The logic for multiple data sets should work "
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