#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.05
Constant IRVversionNumber=2.04

//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.05 fixed BessJ into Besselj, newer function. 
//2.04 added controls for Qc width
//2.03 added Qc (transitional Q when Surface fractal changes to Porod's slope)
//2.02 added version control and scrolable controls. 
//2.01 added license for ANL
//Fractals model using Andrew ALlens theory of combining together mass and surface fractal
//systems. 
//Jan Ilavsky, December 2003



///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR1V_FractalsModel()
	
	IN2G_CheckScreenSize("height",670)
	IR1V_InitializeFractals()
	
	DoWindow IR1V_ControlPanel
	if(V_Flag)
		DOWIndow/K IR1V_ControlPanel
	endif
	Execute("IR1V_ControlPanel()")
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("IR1V_ControlPanel", IRVversionNumber,1)

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_MainCheckVersion()	
	DoWindow IR1V_ControlPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR1V_ControlPanel", IRVversionNumber))
			DoAlert /T="The Fractals panel was created by old version of Irena " 1, "Fractals tool may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				Execute/P("IR1V_FractalsModel()")
			else		//at least reinitialize the variables so we avoid major crashes...
				IR1V_InitializeFractals()					//this may be OK now... 
			endif
		endif
	endif
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_CalculateSfcFractal(which)
	variable which

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel

	NVAR Surface=$("SurfFr"+num2str(which)+"_Surface")
	NVAR DS=$("SurfFr"+num2str(which)+"_DS")
	NVAR Ksi=$("SurfFr"+num2str(which)+"_Ksi")
	NVAR Contrast=$("SurfFr"+num2str(which)+"_Contrast")

	NVAR Qc=$("SurfFr"+num2str(which)+"_Qc")
	NVAR QcW=$("SurfFr"+num2str(which)+"_QcWidth")
	
	Wave Qvec=root:Packages:FractalsModel:FractFitQvector
	Wave FractFitIntensity=root:Packages:FractalsModel:FractFitIntensity
	Duplicate/O FractFitIntensity, $("Surf"+num2str(which)+"FractFitIntensity")
	Wave tempFractFitIntensity=$("Surf"+num2str(which)+"FractFitIntensity")
	
	//and now calculations
	tempFractFitIntensity=0
	tempFractFitIntensity = pi * Contrast* 1e20 * Ksi^4 *1e-32* Surface * exp(gammln(5-DS))	
	tempFractFitIntensity *= sin((3-DS)* atan(Qvec*Ksi))/((1+(Qvec*Ksi)^2)^((5-DS)/2) * Qvec*Ksi)
	if(Qc>0)
			//h(Q) = C(xc - x)f(Q) + C(x - xc)g(Q).
			//The transition from one behavior to another is determined by C. Ê
			//For an infinitely sharp transition, C would be a Heaviside step function. Ê
			//Our choice for C is a smoothed step function:
			//C(x) = 0.5 * (1 + erfc(x/W)).
			//C(x) = 0.5 * (1 + ERF( (Qc-Q) /SQRT(2*((Qw/2.3548)^2) ) )
			duplicate/Free tempFractFitIntensity, StepFunction1, StepFunction2, TempFractInt2
			StepFunction1 = 0.5 * (1 + erf((Qc - Qvec)/SQRT(2*((Qc*QcW/2.3548)^2) ) ))
			StepFunction2 = 0.5 * (1 + erf((Qvec-Qc)/SQRT(2*((Qc*QcW/2.3548)^2) ) ))
			//So, the total model, which transitions from f(Q) to Porod law behavior AQ^-4 is:
			//h(Q) = C(xc - x)f(Q) + C(x -xc)AQ^-4.
			//The value for A is not a free parameter. It is fixed by a continuity condition:
			//f(Qc) = g(Qc), or A = Qc^4 * f(Qc).
			//Intensity = ASF *Ê0.5 * (1 + ERF( (Qc-Q) /SQRT(2*((Qw/2.3548)^2) ) )Ê Ê +
			//+ ( ÊPf * Q^-4 *Ê0.5 * (1 + ERF( (Q-Qc) /SQRT(2*((Qw/2.3548)^2) ) )Ê
			variable PorodSurface=Qc^4 * tempFractFitIntensity[BinarySearchInterp(Qvec, Qc )]
			TempFractInt2 = tempFractFitIntensity * StepFunction1 + PorodSurface * Qvec^-4 * StepFunction2
			tempFractFitIntensity = TempFractInt2
	endif
	
//	tempFractFitIntensity*=1e-48									//this is conversion for Volume of particles from A to cm
	FractFitIntensity+=tempFractFitIntensity
	
	setDataFolder OldDf
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_CalculateMassFractal(which)
	variable which

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel

	NVAR Phi=$("MassFr"+num2str(which)+"_Phi")
	NVAR Radius=$("MassFr"+num2str(which)+"_Radius")
	NVAR Dv=$("MassFr"+num2str(which)+"_Dv")
	NVAR Ksi=$("MassFr"+num2str(which)+"_Ksi")
	NVAR BetaVar=$("MassFr"+num2str(which)+"_Beta")
	NVAR Contrast=$("MassFr"+num2str(which)+"_Contrast")
	NVAR Eta=$("MassFr"+num2str(which)+"_Eta")
	

	Wave Qvec=root:Packages:FractalsModel:FractFitQvector
	Wave FractFitIntensity=root:Packages:FractalsModel:FractFitIntensity
	Duplicate/O FractFitIntensity, $("Mass"+num2str(which)+"FractFitIntensity")
	Wave tempFractFitIntensity=$("Mass"+num2str(which)+"FractFitIntensity")
	
	variable CHiS=IR1V_CaculateChiS(BetaVar)
	variable RC=Radius*sqrt(2)/ChiS * sqrt(1+((2+BetaVar^2)/3)*ChiS^2)
	//and now calculations
	tempFractFitIntensity=0
//	tempFractFitIntensity = Phi * Contrast* 1e20								//this is phi * deltaRhoSquared
//	tempFractFitIntensity *= IR1V_SpheroidVolume(Radius,Beta)* 1e-24		//volume of particle
	variable Bracket
	Bracket = ( Eta * RC^3 / (BetaVar * Radius^3)) * ((Ksi/RC)^Dv )
	if(BetaVar!=1)
		tempFractFitIntensity = Phi * Contrast* 1e-4 * IR1V_SpheroidVolume(Radius,BetaVar) * (Bracket * sin((Dv-1)*atan(Qvec*Ksi)) / ((Dv-1)*Qvec*Ksi*(1+(Qvec*Ksi)^2)^((Dv-1)/2)) + (1-Eta)^2 )* IR1V_CalculateFSquared(which,Qvec)
	else
		tempFractFitIntensity = Phi * Contrast* 1e-4 * IR1V_SpheroidVolume(Radius,BetaVar) * (Bracket * sin((Dv-1)*atan(Qvec*Ksi)) / ((Dv-1)*Qvec*Ksi*(1+(Qvec*Ksi)^2)^((Dv-1)/2)) + (1-Eta)^2 )* IR1V_SphereFFSquared(which,Qvec)
	endif
	//	tempFractFitIntensity*=1e-48									//this is conversion for Volume of particles from A to cm
	FractFitIntensity+=tempFractFitIntensity
	
	setDataFolder OldDf
end

//*****************************************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_SphereFFSquared(which, Qvalue)
	variable Qvalue, which										//does the math for Sphere Form factor function

	NVAR Radius=$("MassFr"+num2str(which)+"_Radius")

	variable QR=Qvalue*radius

	return  ((3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR))))^2
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_SpheroidVolume(radius,AspectRatio)							//returns the spheroid volume...
	variable radius, AspectRatio
	return ((4/3)*pi*radius*radius*radius*AspectRatio)				//what is the volume of spheroid?
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_CalculateFSquared(which,Qval)
	variable which,Qval

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel

	NVAR Phi=$("MassFr"+num2str(which)+"_Phi")
	NVAR Radius=$("MassFr"+num2str(which)+"_Radius")
	NVAR Dv=$("MassFr"+num2str(which)+"_Dv")
	NVAR Ksi=$("MassFr"+num2str(which)+"_Ksi")
	NVAR BetaVar=$("MassFr"+num2str(which)+"_Beta")
	NVAR Contrast=$("MassFr"+num2str(which)+"_Contrast")
	NVAR Eta=$("MassFr"+num2str(which)+"_Eta")
	NVAR IntgNumPnts=$("MassFr"+num2str(which)+"_IntgNumPnts")
	
	 variable result 
	 variable TempBessArg
	//now we need the integral
	Make/O/D/N=(IntgNumPnts) FractF2IntgWave
	SetScale/I x 0,1,"", FractF2IntgWave
	//FractF2IntgWave = BessJ(3/2,Qval*Radius*sqrt(1+(BetaVar^2 - 1)*x^2),1)/(Qval*Radius*sqrt(1+(BetaVar^2 - 1)*x^2))^(3/2)
	FractF2IntgWave = Besselj(3/2,Qval*Radius*sqrt(1+(BetaVar^2 - 1)*x^2))/(Qval*Radius*sqrt(1+(BetaVar^2 - 1)*x^2))^(3/2)
	//fix end points, if they are wrong:
	if (numtype(FractF2IntgWave[0])!=0)
		FractF2IntgWave[0]=FractF2IntgWave[1]
	endif
	if (numtype(FractF2IntgWave[IntgNumPnts-1])!=0)
		FractF2IntgWave[IntgNumPnts-1]=FractF2IntgWave[IntgNumPnts-2]
	endif
	
	result =  9*pi/2 * (area(FractF2IntgWave, 0, 1 ))^2
	killwaves FractF2IntgWave
	setDataFolder oldDF
	return result 
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_CaculateChiS(BetaVar)
	variable BetaVar
	
	variable result
	
	if (BetaVar<1)
		result = (1/(2*BetaVar)) * (1+(BetaVar^2/sqrt(1-BetaVar^2))*ln((1+sqrt(1-BetaVar^2))/BetaVar))
	elseif(BetaVar>1)
		result = (1/(2*BetaVar)) * (1+(BetaVar^2/sqrt(BetaVar^2 -1))*asin(sqrt(BetaVar^2 - 1)/BetaVar))
	else
		result = 1
	endif
	return result
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_FractalCalculateIntensity()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel

	Wave/Z OriginalIntensity
	Wave/Z OriginalQvector
	if(!WaveExists(OriginalIntensity) || !WaveExists(OriginalQvector))
		abort
	endif
	Duplicate/O OriginalIntensity, FractFitIntensity, FractIQ4
	Redimension/D FractFitIntensity, FractIQ4
	Duplicate/O OriginalQvector, FractFitQvector, FractQ4
	Redimension/D FractFitQvector, FractQ4
	FractQ4=FractFitQvector^4
	
	FractFitIntensity=0
	
	NVAR UseMassFract1
	NVAR UseMassFract2
	NVAR UseSurfFract1
	NVAR UseSurfFract2

	if(UseMassFract1)	
		IR1V_CalculateMassFractal(1)
	endif
	if(UseMassFract2)	
		IR1V_CalculateMassFractal(2)
	endif
	if(UseSurfFract1)	
		IR1V_CalculateSfcFractal(1)
	endif
	if(UseSurfFract2)	
		IR1V_CalculateSfcFractal(2)
	endif
	
	NVAR SASBackground=root:Packages:FractalsModel:SASBackground
	FractFitIntensity+=SASBackground	
	
	FractIQ4=FractFitIntensity*FractQ4
	RemoveFromGraph /Z/W=IR1V_LogLogPlotV FractFitIntensity
	AppendToGraph /W=IR1V_LogLogPlotV/C=(0,0,0) FractFitIntensity vs FractFitQvector
	RemoveFromGraph /Z/W=IR1V_IQ4_Q_PlotV FractIQ4
	AppendToGraph /W=IR1V_IQ4_Q_PlotV/C=(0,0,0) FractIQ4 vs FractFitQvector
	setDataFolder oldDF
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function	IR1V_CalculateNormalizedError(CalledWhere)
		string CalledWhere	// "fit" or "graph"

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel
//		if (cmpstr(CalledWhere,"fit")==0)
//			Wave/Z ExpInt=root:Packages:FractalsModel:FitIntensityWave
//			if (WaveExists(ExpInt))
//				Wave ExpError=root:Packages:FractalsModel:FitErrorWave
//				Wave FitIntCalc=root:Packages:FractalsModel:FractFitIntensity
//				Wave FitIntQvec=root:Packages:FractalsModel:FractFitQvector
//				Wave FitQvec=root:Packages:FractalsModel:FitQvectorWave
//				variable mystart=binarysearch(FitIntQvec,FitQvec[0])
//				variable myend=binarysearch(FitIntQvec,FitQvec[numpnts(FitQvec)-1])
//				Duplicate/O/R=[mystart,myend] FitIntCalc, FitInt
//				Wave FitInt
//				Duplicate /O ExpInt, NormalizedError
//				Duplicate/O FitQvec, NormErrorQvec
//				NormalizedError=(ExpInt-FitInt)/ExpError
//				KillWaves FitInt
//			endif
//		endif
		if (cmpstr(CalledWhere,"graph")==0)
			Wave ExpInt=root:Packages:FractalsModel:OriginalIntensity
			Wave ExpError=root:Packages:FractalsModel:OriginalError
			Wave FitInt=root:Packages:FractalsModel:FractFitIntensity
			Wave OrgQvec=root:Packages:FractalsModel:OriginalQvector
			Duplicate/O OrgQvec, NormErrorQvec
			Duplicate/O FitInt, NormalizedError
			NormalizedError=(ExpInt-FitInt)/ExpError
		endif	
	setDataFolder oldDf
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_AppendModelToMeasuredData()
	//here we need to append waves with calculated intensities to the measured data

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel
	
	Wave Intensity=root:Packages:FractalsModel:FractFitIntensity
	Wave QVec=root:Packages:FractalsModel:FractFitQvector
	Wave IQ4=root:Packages:FractalsModel:FractIQ4
	Wave/Z NormalizedError=root:Packages:FractalsModel:NormalizedError
	Wave/Z NormErrorQvec=root:Packages:FractalsModel:NormErrorQvec
	
	DoWindow/F IR1V_LogLogPlotV
	variable CsrAPos
	if (strlen(CsrWave(A))!=0)
		CsrAPos=pcsr(A)
	else
		CsrAPos=0
	endif
	variable CsrBPos
	if (strlen(CsrWave(B))!=0)
		CsrBPos=pcsr(B)
	else
		CsrBPos=numpnts(Intensity)-1
	endif
	
	DoWIndow IR1V_LogLogPlotV
	if (!V_Flag)
		abort
	endif
	DoWIndow IR1V_IQ4_Q_PlotV
	if (!V_Flag)
		abort
	endif
	
	RemoveFromGraph /Z/W=IR1V_LogLogPlotV FractFitIntensity 
	RemoveFromGraph /Z/W=IR1V_LogLogPlotV NormalizedError 
	RemoveFromGraph /Z/W=IR1V_IQ4_Q_PlotV UnifiedIQ4 

	AppendToGraph/W=IR1V_LogLogPlotV Intensity vs Qvec
	cursor/P/W=IR1V_LogLogPlotV A, OriginalIntensity, CsrAPos	
	cursor/P/W=IR1V_LogLogPlotV B, OriginalIntensity, CsrBPos	
	ModifyGraph/W=IR1V_LogLogPlotV rgb(FractFitIntensity)=(0,0,0)
	ModifyGraph/W=IR1V_LogLogPlotV mode(OriginalIntensity)=3
	ModifyGraph/W=IR1V_LogLogPlotV msize(OriginalIntensity)=1
	TextBox/W=IR1V_LogLogPlotV/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	ShowInfo/W=IR1V_LogLogPlotV
	if (WaveExists(NormalizedError))
		AppendToGraph/R/W=IR1V_LogLogPlotV NormalizedError vs NormErrorQvec
		ModifyGraph/W=IR1V_LogLogPlotV  mode(NormalizedError)=3,marker(NormalizedError)=8
		ModifyGraph/W=IR1V_LogLogPlotV zero(right)=4
		ModifyGraph/W=IR1V_LogLogPlotV msize(NormalizedError)=1,rgb(NormalizedError)=(0,0,0)
		SetAxis/W=IR1V_LogLogPlotV /A/E=2 right
		ModifyGraph/W=IR1V_LogLogPlotV log(right)=0
		Label/W=IR1V_LogLogPlotV right "Standardized residual"
	else
		ModifyGraph/W=IR1V_LogLogPlotV mirror(left)=1
	endif
	ModifyGraph/W=IR1V_LogLogPlotV log(left)=1
	ModifyGraph/W=IR1V_LogLogPlotV log(bottom)=1
	ModifyGraph/W=IR1V_LogLogPlotV mirror(bottom)=1
	Label/W=IR1V_LogLogPlotV left "Intensity [cm\\S-1\\M]"
	Label/W=IR1V_LogLogPlotV bottom "Q [A\\S-1\\M]"
	ErrorBars/Y=1/W=IR1V_LogLogPlotV OriginalIntensity Y,wave=(root:Packages:FractalsModel:OriginalError,root:Packages:FractalsModel:OriginalError)
	Legend/W=IR1V_LogLogPlotV/N=text0/K
	Legend/W=IR1V_LogLogPlotV/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 "\\s(OriginalIntensity) Experimental intensity"
	AppendText/W=IR1V_LogLogPlotV "\\s(FractFitIntensity) Fractal model calculated Intensity"
	if (WaveExists(NormalizedError))
		AppendText/W=IR1V_LogLogPlotV "\\s(NormalizedError) Standardized residual"
	endif
	ModifyGraph/W=IR1V_LogLogPlotV rgb(OriginalIntensity)=(0,0,0),lstyle(FractFitIntensity)=0
	ModifyGraph/W=IR1V_LogLogPlotV rgb(FractFitIntensity)=(65280,0,0)

	AppendToGraph/W=IR1V_IQ4_Q_PlotV IQ4 vs Qvec
	ModifyGraph/W=IR1V_IQ4_Q_PlotV rgb(FractIQ4)=(65280,0,0)
	ModifyGraph/W=IR1V_IQ4_Q_PlotV mode=3
	ModifyGraph/W=IR1V_IQ4_Q_PlotV msize=1
	ModifyGraph/W=IR1V_IQ4_Q_PlotV log=1
	ModifyGraph/W=IR1V_IQ4_Q_PlotV mirror=1
	ModifyGraph/W=IR1V_IQ4_Q_PlotV mode(FractIQ4)=0
	TextBox/W=IR1V_IQ4_Q_PlotV/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	Label/W=IR1V_IQ4_Q_PlotV left "Intensity * Q^4"
	Label/W=IR1V_IQ4_Q_PlotV bottom "Q [A\\S-1\\M]"
	ErrorBars/Y=1/W=IR1V_IQ4_Q_PlotV OriginalIntQ4 Y,wave=(root:Packages:FractalsModel:OriginalErrQ4,root:Packages:FractalsModel:OriginalErrQ4)
	Legend/W=IR1V_IQ4_Q_PlotV/N=text0/K
	Legend/W=IR1V_IQ4_Q_PlotV/N=text0/J/F=0/A=MC/X=-29.74/Y=37.76 "\\s(OriginalIntQ4) Experimental intensity * Q^4"
	AppendText/W=IR1V_IQ4_Q_PlotV "\\s(FractIQ4) Fractal model Calculated intensity * Q^4"
	ModifyGraph/W=IR1V_IQ4_Q_PlotV rgb(OriginalIntq4)=(0,0,0)
	setDataFolder oldDF

end
