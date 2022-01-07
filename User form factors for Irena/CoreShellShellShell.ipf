#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

//this is form factor and volume function for Irena for Core-Shell-Shell-Shell particles
//		this can be used os User form factor in Modeling package. 
//		this is a copy of code from NIST Igor package, Core_and_NShell_v40.ipf, orginal form factor function is fThreeShell
// 		Jan Ilavsky, 2022-01-07

//How to use:
//  -- important -- 
// 	set contrast in Modeling package to 1, core-shell form factors have rho values (SLD) as part of the form factor...
// 	set constants below to proper for the parameter values. This form factor has too many parameters, some need to be in constants.  
// 	Therefore, you need to use one parameter - C3ShellPar6 - as constant, Irena has limit of 5 form factor parameters. 
// 	If needed, you can change what par1-par5 mean, but this may require redefining also volume function   FF_CoreThreeShellVolume 
//		The FF_CoreThreeShellVolume is assuming, that par1, par3, and par5 are shell thicknesses. 
//		*** change therefore both FF_CoreThreeShell AND FF_CoreThreeShellVolume ***
// Default parameter definitions:
	//radius -  radius of core [Å]
	//par1		thickness of shell 1 [Å]
	//par2 		SLD of shell 1
	//par3 		thickness of shell 2 [Å]
	//par4 		SLD of shell 2
	//par5 		thickness of shell 3 [Å]

	//C3ShellCoreSLD   		SLD of the core	[Å-2]
	//C3ShellSolventSLD 	SLD of the solvent
	//C3ShellPar6 			SLD of shell 3


constant C3ShellCoreSLD 	= 22.45					//this is rho for core (default SiO2), can be changed here. 
constant C3ShellSolventSLD 	= 9.4197				//this is rho for solvent (default water), can be changed here. 
// Since we are limited to 5 GUI parameters, one more parameter needs to be fixed. Below is defined Par6 which in default code is Shell3SLD. 
constant C3ShellPar6 		= 9.42					//this is rho for core, can be changed here. Not enough parameters in Irena GUI
	// water is 9.42 [*10^10]
	// SiO2 is 22.45 [10^10]
	// FYI (for testing) delta-rho-squared for H2O-SiO2 is 169.9 10^20. Yu can set shell thicknesses to 0 with Water/SiO2
	// and get same intensity/curve as with sphere with contrast to 169.9. I have tested this and other edge cases. 


Function FF_CoreThreeShell(Q,radius, par1,par2,par3,par4,par5)		//returns Form factor for given Q, Radius and Par1-Par5
	variable Q, radius, par1,par2,par3,par4,par5												
	
	// variables are:
	//radius -  radius of core [Å]
	//par1		thickness of shell 1 [Å]
	//par2 		SLD of shell 1
	//par3 		thickness of shell 2 [Å]
	//par4 		SLD of shell 2
	//par5 		thickness of shell 3 [Å]

	//C3ShellCoreSLD   		SLD of the core	[Å-2]
	//C3ShellPar6 			SLD of shell 3
	//C3ShellSolventSLD 	SLD of the solvent
	
	// All inputs are in ANGSTROMS
	//OUTPUT is normalized by the particle volume, and converted to [cm-1]
	
	
	Variable scale,rcore,thick1,thick2,thick3,rhoshel1,rhoshel2,rhoshel3
	Variable rhocore,rhosolv,bkg
	rcore = radius
	rhocore = C3ShellCoreSLD
	thick1 = par1
	rhoshel1 = par2
	thick2 = par3
	rhoshel2 = par4
	thick3 = par5
	rhoshel3 = C3ShellPar6
	rhosolv = C3ShellSolventSLD
	
	// calculates f
	Variable bes,f,vol,qr,contr,f2
	
	// core first, then add in shells
	qr=Q*rcore
	contr = rhocore-rhoshel1
	if(qr == 0)
		bes = 1
	else
		bes = 3*(sin(qr)-qr*cos(qr))/qr^3
	endif
	vol = 4*pi/3*rcore^3
	f = vol*bes*contr
	//now the shell (1)
	qr=Q*(rcore+thick1)
	contr = rhoshel1-rhoshel2
	if(qr == 0)
		bes = 1
	else
		bes = 3*(sin(qr)-qr*cos(qr))/qr^3
	endif
	vol = 4*pi/3*(rcore+thick1)^3
	f += vol*bes*contr
	//now the shell (2)
	qr=Q*(rcore+thick1+thick2)
	contr = rhoshel2-rhoshel3
	if(qr == 0)
		bes = 1
	else
		bes = 3*(sin(qr)-qr*cos(qr))/qr^3
	endif
	vol = 4*pi/3*(rcore+thick1+thick2)^3
	f += vol*bes*contr
	//now the shell (3)
	qr=Q*(rcore+thick1+thick2+thick3)
	contr = rhoshel3-rhosolv
	if(qr == 0)
		bes = 1
	else
		bes = 3*(sin(qr)-qr*cos(qr))/qr^3
	endif
	f += vol*bes*contr

	vol = 4*pi/3*(rcore+thick1+thick2+thick3)^3
	
	f/=vol		//correct for volumes accounted in here. 
	
	return (f)
End


Function FF_CoreThreeShellVolume(radius, par1,par2,par3,par4,par5)		//returns the sphere volume, this particle is now normalized by volume of the core. 
	variable radius, par1,par2,par3,par4,par5

	//radius -  radius of core [Å]
	//par1		thickness of shell 1 [Å]
	//par2 		SLD of shell 1
	//par3 		thickness of shell 2 [Å]
	//par4 		SLD of shell 2
	//par5 		thickness of shell 3 [Å]
	variable realRad=radius + par1 + par3 + par5
	return ((4/3)*pi*realRad*realRad*realRad)
end
   