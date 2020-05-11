#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.



//****************************************************************************************************
//this is Irena Modeling package User form factor.
//to use, open Modeling package, switch to Model controls and select "User" for Form Factor. 
Function TriaxSpheroid(Q,radius, par1,par2,par3,par4,par5)	//Triaxial Spheroid, 
	variable Q, radius, par1,par2,par3,par4,par5	
	//based on Triaxial Spherdoid from NIST SANS tools, 
	//ftp.ncnr.nist.gov/pub/sans/kline/Download/SANS_Model_Docs_v4.10.pdf 		
	//the shape is elllipsoid with 3 different radii : dimensions R, R1, R2, R<R1<R2. This is important!!!		
	//				note Rg = (R^2+R1^2+R2^2)/5		
	//assumptions: 	Par1 is ratio of R1/R, requirement: Par1>1
	//					Par2 is R2/R,  requirements:  Par2>1, Par2>Par1
	//Par3-Par5 are not used 
	if(Par2<1 || Par1<1 || Par2<Par1)
		abort "Parameters in TriaxSpheroid form factor are  not correct"
	endif
	variable aa,bb,cc
	aa=radius
	bb=Par1*radius
	cc=Par2*radius
	return TriaxSpheroidIntgOut(Q,aa,bb,cc)
end
//****************************************************************************************************
Function TriaxSpheroidVolume(radius, par1,par2,par3,par4,par5)
	variable radius, par1,par2,par3,par4,par5	
	//based on Triaxial Spherdoid from NIST SANS tools, 
	//ftp://ftp.ncnr.nist.gov/pub/sans/kline/Download/SANS_Model_Docs_v4.10.pdf 								
	variable aa,bb,cc
	aa=radius
	bb=Par1*radius
	cc=Par2*radius
	return 4*pi*aa*bb*cc/3
end
//****************************************************************************************************
//work functions, do not change 
Function TriaxSpheroidIntgOut(qq,aa,bb,cc)
	Variable qq,aa,bb,cc		
	make/Free TempWave
	SetScale/I x, 0, 1,  TempWave
	multithread TempWave = TriaxSpheroidIntgInside(qq,aa,bb,cc,x)
	return area(TempWave)	
end
//****************************************************************************************************
threadsafe Function TriaxSpheroidIntgInside(qq,aa,bb,cc,dy)
	Variable qq,aa,bb,cc,dy		
	make/Free TempWave
	SetScale/I x, 0, 1,  TempWave
	TempWave = TriaxSpheroidInside(qq,aa,bb,cc,x,dy)
	return area(TempWave)	
end
//****************************************************************************************************
threadsafe Function TriaxSpheroidInside(qq,aa,bb,cc,dx,dy)
	Variable qq,aa,bb,cc,dx,dy
	//aa, bb, cc are simply dimensions
	//qq is Q
	//dx, dy are integrants. 
	Variable val,arg
	arg = aa*aa*cos(pi*dx/2)*cos(pi*dx/2)
	arg += bb*bb*sin(pi*dx/2)*sin(pi*dx/2)*(1-dy*dy)
	arg += cc*cc*dy*dy
	arg = qq*sqrt(arg)
	if(arg == 0)
		val = 1
	else
		val = 9*((sin(arg) - arg*cos(arg))/arg^3 )^2
	endif
	return(val)
end
//****************************************************************************************************
