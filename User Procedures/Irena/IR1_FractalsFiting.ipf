#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.03

//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.03 added check for errors = 0 
//2.02 modified fitting to include Igor display with iterations /N=0/W=0
//2.01 added license for ANL


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR1V_ConstructTheFittingCommand()
	//here we need to construct the fitting command and prepare the data for fit...

	string OldDF=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel
	
	NVAR UseMassFract1=root:Packages:FractalsModel:UseMassFract1
	NVAR UseMassFract2=root:Packages:FractalsModel:UseMassFract2
	NVAR UseSurfFract1=root:Packages:FractalsModel:UseSurfFract1
	NVAR UseSurfFract2=root:Packages:FractalsModel:UseSurfFract2
	NVAR SASBackground=root:Packages:FractalsModel:SASBackground
	NVAR FitSASBackground=root:Packages:FractalsModel:FitSASBackground

//Mass fractal1 part	
	NVAR  MassFr1_Phi=root:Packages:FractalsModel:MassFr1_Phi
	NVAR  MassFr1_FitPhi=root:Packages:FractalsModel:MassFr1_FitPhi
	NVAR  MassFr1_PhiError=root:Packages:FractalsModel:MassFr1_PhiError
	NVAR  MassFr1_PhiMin=root:Packages:FractalsModel:MassFr1_PhiMin
	NVAR  MassFr1_PhiMax=root:Packages:FractalsModel:MassFr1_PhiMax

	NVAR  MassFr1_Radius=root:Packages:FractalsModel:MassFr1_Radius
	NVAR  MassFr1_FitRadius=root:Packages:FractalsModel:MassFr1_FitRadius
	NVAR  MassFr1_RadiusError=root:Packages:FractalsModel:MassFr1_RadiusError
	NVAR  MassFr1_RadiusMin=root:Packages:FractalsModel:MassFr1_RadiusMin
	NVAR  MassFr1_RadiusMax=root:Packages:FractalsModel:MassFr1_RadiusMax

	NVAR  MassFr1_Dv=root:Packages:FractalsModel:MassFr1_Dv
	NVAR  MassFr1_FitDv=root:Packages:FractalsModel:MassFr1_FitDv
	NVAR  MassFr1_DvError= root:Packages:FractalsModel:MassFr1_DvError
	NVAR  MassFr1_DvMin=root:Packages:FractalsModel:MassFr1_DvMin
	NVAR  MassFr1_DvMax=root:Packages:FractalsModel:MassFr1_DvMax

	NVAR  MassFr1_Ksi=root:Packages:FractalsModel:MassFr1_Ksi
	NVAR  MassFr1_FitKsi=root:Packages:FractalsModel:MassFr1_FitKsi
	NVAR  MassFr1_KsiError=root:Packages:FractalsModel:MassFr1_KsiError
	NVAR  MassFr1_KsiMin= root:Packages:FractalsModel:MassFr1_KsiMin
	NVAR  MassFr1_KsiMax=root:Packages:FractalsModel:MassFr1_KsiMax

	NVAR  MassFr1_Beta=root:Packages:FractalsModel:MassFr1_Beta
	NVAR  MassFr1_Contrast=root:Packages:FractalsModel:MassFr1_Contrast
	NVAR  MassFr1_Eta=root:Packages:FractalsModel:MassFr1_Eta
	
//Mass fractal 2 part	
	NVAR  MassFr2_Phi=root:Packages:FractalsModel:MassFr2_Phi
	NVAR  MassFr2_FitPhi=root:Packages:FractalsModel:MassFr2_FitPhi
	NVAR  MassFr2_PhiError=root:Packages:FractalsModel:MassFr2_PhiError
	NVAR  MassFr2_PhiMin=root:Packages:FractalsModel:MassFr2_PhiMin
	NVAR  MassFr2_PhiMax=root:Packages:FractalsModel:MassFr2_PhiMax

	NVAR  MassFr2_Radius=root:Packages:FractalsModel:MassFr2_Radius
	NVAR  MassFr2_FitRadius=root:Packages:FractalsModel:MassFr2_FitRadius
	NVAR  MassFr2_RadiusError=root:Packages:FractalsModel:MassFr2_RadiusError
	NVAR  MassFr2_RadiusMin=root:Packages:FractalsModel:MassFr2_RadiusMin
	NVAR  MassFr2_RadiusMax=root:Packages:FractalsModel:MassFr2_RadiusMax

	NVAR  MassFr2_Dv=root:Packages:FractalsModel:MassFr2_Dv
	NVAR  MassFr2_FitDv=root:Packages:FractalsModel:MassFr2_FitDv
	NVAR  MassFr2_DvError= root:Packages:FractalsModel:MassFr2_DvError
	NVAR  MassFr2_DvMin=root:Packages:FractalsModel:MassFr2_DvMin
	NVAR  MassFr2_DvMax=root:Packages:FractalsModel:MassFr2_DvMax

	NVAR  MassFr2_Ksi=root:Packages:FractalsModel:MassFr2_Ksi
	NVAR  MassFr2_FitKsi=root:Packages:FractalsModel:MassFr2_FitKsi
	NVAR  MassFr2_KsiError=root:Packages:FractalsModel:MassFr2_KsiError
	NVAR  MassFr2_KsiMin= root:Packages:FractalsModel:MassFr2_KsiMin
	NVAR  MassFr2_KsiMax=root:Packages:FractalsModel:MassFr2_KsiMax

	NVAR  MassFr2_Beta=root:Packages:FractalsModel:MassFr2_Beta
	NVAR  MassFr2_Contrast=root:Packages:FractalsModel:MassFr2_Contrast
	NVAR  MassFr2_Eta=root:Packages:FractalsModel:MassFr2_Eta

//Surface fractal 1
	NVAR  SurfFr1_Surface=root:Packages:FractalsModel:SurfFr1_Surface
	NVAR SurfFr1_FitSurface =root:Packages:FractalsModel:SurfFr1_FitSurface
	NVAR SurfFr1_SurfaceMin =root:Packages:FractalsModel:SurfFr1_SurfaceMin
	NVAR  SurfFr1_SurfaceMax=root:Packages:FractalsModel:SurfFr1_SurfaceMax
	NVAR  SurfFr1_SurfaceError=root:Packages:FractalsModel:SurfFr1_SurfaceError

	NVAR  SurfFr1_Ksi=root:Packages:FractalsModel:SurfFr1_Ksi
	NVAR  SurfFr1_FitKsi=root:Packages:FractalsModel:SurfFr1_FitKsi
	NVAR  SurfFr1_KsiMin=root:Packages:FractalsModel:SurfFr1_KsiMin
	NVAR  SurfFr1_KsiMax=root:Packages:FractalsModel:SurfFr1_KsiMax
	NVAR  SurfFr1_KsiError=root:Packages:FractalsModel:SurfFr1_KsiError

	NVAR  SurfFr1_DS=root:Packages:FractalsModel:SurfFr1_DS
	NVAR  SurfFr1_FitDS=root:Packages:FractalsModel:SurfFr1_FitDS
	NVAR  SurfFr1_DSMin=root:Packages:FractalsModel:SurfFr1_DSMin
	NVAR  SurfFr1_DSMax=root:Packages:FractalsModel:SurfFr1_DSMax
	NVAR  SurfFr1_DSError=root:Packages:FractalsModel:SurfFr1_DSError

	NVAR  SurfFr1_Contrast=root:Packages:FractalsModel:SurfFr1_Contrast

	NVAR SurfFr1_SurfaceStep =root:Packages:FractalsModel:SurfFr1_SurfaceStep

	NVAR  SurfFr2_Surface=root:Packages:FractalsModel:SurfFr2_Surface
	NVAR SurfFr2_FitSurface =root:Packages:FractalsModel:SurfFr2_FitSurface
	NVAR SurfFr2_SurfaceMin =root:Packages:FractalsModel:SurfFr2_SurfaceMin
	NVAR  SurfFr2_SurfaceMax=root:Packages:FractalsModel:SurfFr2_SurfaceMax
	NVAR  SurfFr2_SurfaceError=root:Packages:FractalsModel:SurfFr2_SurfaceError

	NVAR  SurfFr2_Ksi=root:Packages:FractalsModel:SurfFr2_Ksi
	NVAR  SurfFr2_FitKsi=root:Packages:FractalsModel:SurfFr2_FitKsi
	NVAR  SurfFr2_KsiMin=root:Packages:FractalsModel:SurfFr2_KsiMin
	NVAR  SurfFr2_KsiMax=root:Packages:FractalsModel:SurfFr2_KsiMax
	NVAR  SurfFr2_KsiError=root:Packages:FractalsModel:SurfFr2_KsiError

	NVAR  SurfFr2_DS=root:Packages:FractalsModel:SurfFr2_DS
	NVAR  SurfFr2_FitDS=root:Packages:FractalsModel:SurfFr2_FitDS
	NVAR  SurfFr2_DSMin=root:Packages:FractalsModel:SurfFr2_DSMin
	NVAR  SurfFr2_DSMax=root:Packages:FractalsModel:SurfFr2_DSMax
	NVAR  SurfFr2_DSError=root:Packages:FractalsModel:SurfFr2_DSError

	NVAR  SurfFr2_Contrast=root:Packages:FractalsModel:SurfFr2_Contrast

	NVAR SurfFr2_SurfaceStep =root:Packages:FractalsModel:SurfFr2_SurfaceStep
///now we can make various parts of the fitting routines...
//
	//First check the reasonability of all parameters

//	IR1A_CorrectLimitsAndValues()

	//
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
//Mass fractal 1 part	
	if (MassFr1_FitPhi && UseMassFract1)		
		if (MassFr1_PhiMin > MassFr1_Phi || MassFr1_PhiMax < MassFr1_Phi)
			abort "Maas fractal 1 Phi limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=MassFr1_Phi
		CoefNames[numpnts(CoefNames)-1]="MassFr1_Phi"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(MassFr1_PhiMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(MassFr1_PhiMax)}		
	endif
	if (MassFr1_FitRadius && UseMassFract1)	
		if (MassFr1_RadiusMin > MassFr1_Radius || MassFr1_RadiusMax < MassFr1_Radius)
			abort "Mass fractal 1 Radius limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=MassFr1_Radius
		CoefNames[numpnts(CoefNames)-1]="MassFr1_Radius"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(MassFr1_RadiusMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(MassFr1_RadiusMax)}		
	endif
	if (MassFr1_FitDv && UseMassFract1)		
		if (MassFr1_DvMin > MassFr1_Dv || MassFr1_DvMax < MassFr1_Dv)
			abort "Level 1 P limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=MassFr1_Dv
		CoefNames[numpnts(CoefNames)-1]="MassFr1_Dv"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(MassFr1_DvMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(MassFr1_DvMax)}		
	endif
	if (MassFr1_FitKsi && UseMassFract1)	
		if (MassFr1_KsiMin > MassFr1_Ksi || MassFr1_KsiMax < MassFr1_Ksi)
			abort "Mass fractal 1 Ksi limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=MassFr1_Ksi
		CoefNames[numpnts(CoefNames)-1]="MassFr1_Ksi"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(MassFr1_KsiMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(MassFr1_KsiMax)}		
	endif

	
//Mass fractal 2 part	

	if (MassFr2_FitPhi && UseMassFract2)		
		if (MassFr2_PhiMin > MassFr2_Phi || MassFr2_PhiMax < MassFr2_Phi)
			abort "Mass fractal 1 Phi limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=MassFr2_Phi
		CoefNames[numpnts(CoefNames)-1]="MassFr2_Phi"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(MassFr2_PhiMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(MassFr2_PhiMax)}		
	endif
	if (MassFr2_FitRadius && UseMassFract2)	
		if (MassFr2_RadiusMin > MassFr2_Radius || MassFr2_RadiusMax < MassFr2_Radius)
			abort "Mass fractal 1 Radius limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=MassFr2_Radius
		CoefNames[numpnts(CoefNames)-1]="MassFr2_Radius"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(MassFr2_RadiusMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(MassFr2_RadiusMax)}		
	endif
	if (MassFr2_FitDv && UseMassFract2)		
		if (MassFr2_DvMin > MassFr2_Dv || MassFr2_DvMax < MassFr2_Dv)
			abort "Level 1 P limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=MassFr2_Dv
		CoefNames[numpnts(CoefNames)-1]="MassFr2_Dv"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(MassFr2_DvMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(MassFr2_DvMax)}		
	endif
	if (MassFr2_FitKsi && UseMassFract2)	
		if (MassFr2_KsiMin > MassFr2_Ksi || MassFr2_KsiMax < MassFr2_Ksi)
			abort "Mass fractal 1 Ksi limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=MassFr2_Ksi
		CoefNames[numpnts(CoefNames)-1]="MassFr2_Ksi"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(MassFr2_KsiMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(MassFr2_KsiMax)}		
	endif




//Surface fractal 1 part	
	if (SurfFr1_FitSurface && UseSurfFract1)		//are we fitting distribution 1 volume?
		if (SurfFr1_SurfaceMin > SurfFr1_Surface || SurfFr1_SurfaceMax < SurfFr1_Surface)
			abort "Surface Fractal 1 Surface limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SurfFr1_Surface
		CoefNames[numpnts(CoefNames)-1]="SurfFr1_Surface"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(SurfFr1_SurfaceMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(SurfFr1_SurfaceMax)}		
	endif
	if (SurfFr1_FitKsi && UseSurfFract1)		//are we fitting distribution 1 location?
		if (SurfFr1_KsiMin > SurfFr1_Ksi || SurfFr1_KsiMax < SurfFr1_Ksi)
			abort "Surface fractal 1 Ksi limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SurfFr1_Ksi
		CoefNames[numpnts(CoefNames)-1]="SurfFr1_Ksi"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(SurfFr1_KsiMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(SurfFr1_KsiMax)}		
	endif
	if (SurfFr1_FitDS && UseSurfFract1)		//are we fitting distribution 1 location?
		if (SurfFr1_DSMin > SurfFr1_DS || SurfFr1_DSMax < SurfFr1_DS)
			abort "Surface fractal 1 DS limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SurfFr1_DS
		CoefNames[numpnts(CoefNames)-1]="SurfFr1_DS"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(SurfFr1_DSMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(SurfFr1_DSMax)}		
	endif
//Surface fractal 2 part	
	if (SurfFr2_FitSurface && UseSurfFract2)		//are we fitting distribution 1 volume?
		if (SurfFr2_SurfaceMin > SurfFr2_Surface || SurfFr2_SurfaceMax < SurfFr2_Surface)
			abort "Surface Fractal 1 Surface limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SurfFr2_Surface
		CoefNames[numpnts(CoefNames)-1]="SurfFr2_Surface"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(SurfFr2_SurfaceMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(SurfFr2_SurfaceMax)}		
	endif
	if (SurfFr2_FitKsi && UseSurfFract2)		//are we fitting distribution 1 location?
		if (SurfFr2_KsiMin > SurfFr2_Ksi || SurfFr2_KsiMax < SurfFr2_Ksi)
			abort "Surface fractal 1 Ksi limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SurfFr2_Ksi
		CoefNames[numpnts(CoefNames)-1]="SurfFr2_Ksi"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(SurfFr2_KsiMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(SurfFr2_KsiMax)}		
	endif
	if (SurfFr2_FitDS && UseSurfFract2)		//are we fitting distribution 1 location?
		if (SurfFr2_DSMin > SurfFr2_DS || SurfFr2_DSMax < SurfFr2_DS)
			abort "Surface fractal 1 DS limits set incorrectly, fix the limits before fitting"
		endif
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SurfFr2_DS
		CoefNames[numpnts(CoefNames)-1]="SurfFr2_DS"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(SurfFr2_DSMin)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(SurfFr2_DSMax)}		
	endif
				

	//Now let's check if we have what to fit at all...
	if (numpnts(CoefNames)==0)
		beep
		Abort "Select parameters to fit and set their fitting limits"
	endif
	IR1V_SetErrorsToZero()
	
	DoWindow /F IR1V_LogLogPlotV
	Wave OriginalQvector
	Wave OriginalIntensity
	Wave OriginalError	
	
	Variable V_chisq
	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave=W_coef/100

//	IR1A_RecordResults("before")

	Variable V_FitError=0			//This should prevent errors from being generated
	
	//and now the fit...
	if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalIntensity, FitIntensityWave		
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalQvector, FitQvectorWave
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalError, FitErrorWave
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
		FuncFit /N=0/W=0/Q IR1V_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /D /C=T_Constraints 
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
		FuncFit /N=0/W=0/Q IR1V_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D /C=T_Constraints	
	endif
	if (V_FitError!=0)	//there was error in fitting
		IR1V_ResetParamsAfterBadFit()
		beep
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	
	variable/g AchievedChisq=V_chisq
	IR1V_RecordErrorsAfterFit()
	IR1V_GraphModelData()
//	IR1A_RecordResults("after")
//	
	DoWIndow/F IR1V_ControlPanel
//	IR1A_FixTabsInPanel()
	
	KillWaves T_Constraints, E_wave
	
	setDataFolder OldDF
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_ResetParamsAfterBadFit()
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel

	Wave w=root:Packages:FractalsModel:CoefficientInput
	Wave/T CoefNames=root:Packages:FractalsModel:CoefNames		//text wave with names of parameters

	if ((!WaveExists(w)) || (!WaveExists(CoefNames)))
		Beep
		abort "Record of old parameters does not exist, this is BUG, please report it..."
	endif

	variable i
	For(i=0;i<numpnts(w);i+=1)
		NVAR testVal=$(CoefNames[i])
		testVal=w[i]
	endfor
	setDataFolder oldDF
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_RecordErrorsAfterFit()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel
	
	Wave W_sigma=root:Packages:FractalsModel:W_sigma
	Wave/T CoefNames=root:Packages:FractalsModel:CoefNames
	
	variable i
	For(i=0;i<numpnts(CoefNames);i+=1)
		NVAR InsertErrorHere=$(CoefNames[i]+"Error")
		InsertErrorHere=W_sigma[i]
	endfor
	setDataFolder oldDF

end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_FitFunction(w,yw,xw) : FitFunc
	Wave w,yw,xw
	
	//here the w contains the parameters, yw will be the result and xw is the input
	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(q) = very complex calculations, forget about formula
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1 - the q vector...
	//CurveFitDialog/ q
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel
	
	NVAR SASBackground=root:Packages:FractalsModel:SASBackground
	NVAR FitSASBackground=root:Packages:FractalsModel:FitSASBackground
	NVAR UseMassFract1=root:Packages:FractalsModel:UseMassFract1
	NVAR UseMassFract2=root:Packages:FractalsModel:UseMassFract2
	NVAR UseSurfFract1=root:Packages:FractalsModel:UseSurfFract1
	NVAR UseSurfFract2=root:Packages:FractalsModel:UseSurfFract2
	NVAR SASBackground=root:Packages:FractalsModel:SASBackground
	NVAR FitSASBackground=root:Packages:FractalsModel:FitSASBackground


	Wave/T CoefNames=root:Packages:FractalsModel:CoefNames		//text wave with names of parameters

	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	string ParamName=""
	
	for (i=0;i<NumOfParam;i+=1)
		ParamName=CoefNames[i]
		NVAR tempVar=$(ParamName)
		tempVar = w[i]
	endfor

	Wave QvectorWave=root:Packages:FractalsModel:FitQvectorWave
	Duplicate/O QvectorWave, FractFitIntensity
	//and now we need to calculate the model Intensity
	IR1V_FitFractalCalcIntensity(QvectorWave)		
	
	Wave resultWv=root:Packages:FractalsModel:FractFitIntensity
	
	yw=resultWv
	setDataFolder oldDF
End


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_FitFractalCalcIntensity(OriginalQvector)
	wave OriginalQvector

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel

//	Wave OriginalQvector
	Duplicate/O OriginalQvector, FractFitIntensity
	Redimension/D FractFitIntensity
	Duplicate/O OriginalQvector, FractFitQvector
	Redimension/D FractFitQvector
	
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
	setDataFolder oldDF
	
end
