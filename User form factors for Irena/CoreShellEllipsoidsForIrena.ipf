#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include "IR1_Loader"




////////////////////////////////////////////////
//NOTE: this code is copy of code from OblateCoreShell.ipf from NIST Igor package, modified to use in Irena. Below is original notes from the NIST package:
////////////////////////////////////////////////
//
// this function is for the form factor of an oblate ellipsoid with a core-shell structure
//
// 06 NOV 98 SRK
// 
// 2018-06 modified for use in Irena, all glory goes to Steven Kline!!!!
//note: modified for use in Irena by reducing flexibility and changing parameters description

//*************************************************************************************************
//*************************************************************************************************
//USE in Irena :
//In Modeling II select User form factor 
//In panel put in "Name of ForFactor function this string:    IR1T_EllipsoidalCoreShell
//In Panel put in Name of volume FF function this string:     IR1T_EllipsoidalVolume
//
// Par1 is the aspect ratio which for ellipsoids are defiend as rotational objects with dimensions R x R x AR*R, note, AR=1 may fail. 
// par 2 is shell thickness in A, and it is the same thickness everywhere on teh ellipsoid. 
// par3, 4 and 5 are contrasts as this is core shell system and contrasts are part of the form factor. 
// par3, 4 and 5 are implicitelyu multipled by 10^10cm^-2, so insert only a number. These are rhos not, delta-rho-square
// In main panel set contrast = 1 !!!!!
//*************************************************************************************************
//*************************************************************************************************
 
////////////////////////////////////////////////
//****   IR1T_OblateCoreShell ***** is simply the form factor, which normalizes to 1 at Q=0
//Threadsafe

Function IR1T_EllipsoidalCoreShell(Qval,radius, par1,par2,par3,par4,par5)
	variable Qval, radius, par1,par2,par3,par4,par5												
	//par1	aspect ratio
	//par2	shell thickness (same everywhere)
	//par3, par4, par5		SLD of core, shell, and sovent
	
	Make/D/Free coef_oef = {1.,200,20,250,30,1e-6,2e-6,6.3e-6,0}
	//make/o/t parameters_oef = {"scale","major core (A)","minor core (A)","major shell (A)","minor shell (A)","SLD core (A-2)","SLD shell (A-2)","SLD solvent (A^-2)","bkg (cm-1)"}
	//set scale to 1, background to 0, 
	//
	if(par1 <= 1 )			//oblate shape
		coef_oef[0] =1									//scale, set to 1, Irena uses its own scale
		coef_oef[1] = radius							//this is the main dimension of the shape
		coef_oef[2] = radius*par1					//minor, smaller, diemnsion = secondary (AR*R) dimension of the particle
		coef_oef[3] = radius+par2					//major shell = radius+ShellThickness
		coef_oef[4] = radius*par1+par2				//minor shell (A) = radius*AR+ShellThickness
		coef_oef[5] = par3//	*1e-6							//SLD core, their input units are A^-2 and values around 10-6 A^-2, for Irena input units are N*10^10 cm^-2, 
		coef_oef[6] = par4	//*1e-6      					//SLD shell, this 	*1e-6 converts it into their original units... 
		coef_oef[7] = par5	//*1e-6      					//SLD solvent
		coef_oef[8] = 0									//background, irena uses its own background
	else		//prolate
		coef_oef[0] =1									//scale, set to 1, Irena uses its own scale
		coef_oef[1] = radius*par1					//this is the main dimension of the shape
		coef_oef[2] = radius							//minor, smaller, diemnsion = secondary (AR*R) dimension of the particle
		coef_oef[3] = radius*par1+par2					//major shell = radius+ShellThickness
		coef_oef[4] = radius+par2						//minor shell (A) = radius*AR+ShellThickness
		coef_oef[5] = par3//	*1e-6							//SLD core, their input units are A^-2 and values around 10-6 A^-2, for Irena input units are N*10^10 cm^-2, 
		coef_oef[6] = par4	//*1e-6      					//SLD shell, this 	*1e-6 converts it into their original units... 
		coef_oef[7] = par5	//*1e-6      					//SLD solvent
		coef_oef[8] = 0									//background, irena uses its own background
	endif
	//
	
	if(par1 <= 1 )			//oblate shape
#if exists("OblateFormX")
   //  this returns F^2, we need F, so square root that
   //		after scaling by volume which needs to be converted to cm. 
   // 	IR1T_EllispodalVolume(radius, par1, par2,par3,par4,par5)/1e8
   //   oblatevol = IR1T_OblateVolume(trmaj, AspectRatio)
   //   answer /= oblatevol			-- this is needs to be taken out, Irena does its own volumehandling here...  
   //	also creect for their conversion to [A-1] to [cm-1]
   //   answer *= 1.0e8  
   //	not needed, set to 1 scale
   //  answer *= scale
   // not needed, set to 0 then add background
   //   answer += bkg
	return sqrt(OblateFormX(coef_oef,Qval)/(IR1T_EllipsoidalVolume(radius, par1, par2,par3,par4,par5)/1e8))/1e8
#else
	return sqrt(IR1T_fOblateForm(coef_oef,Qval)/(IR1T_EllipsoidalVolume(radius, par1, par2,par3,par4,par5)/1e8))/1e8
#endif
	else		//prolate shape
#if exists("ProlateFormX")
	return sqrt(ProlateFormX(coef_oef,Qval)/(IR1T_EllipsoidalVolume(radius, par1, par2,par3,par4,par5)/1e8))/1e8
#else
	return sqrt(IR1T_fProlateForm(coef_oef,Qval)/(IR1T_EllipsoidalVolume(radius, par1, par2,par3,par4,par5)/1e8))/1e8
#endif	
	endif
end

Threadsafe Function IR1T_EllipsoidalVolume(radius, AspectRatio, par2,par3,par4,par5)
	variable radius, AspectRatio, par2,par3,par4,par5
	return 4*Pi/3*radius*radius*radius*AspectRatio
end


///////////////////////////////////////////////////////////////
// Oblate functions unsmeared model calculation
///////////////////////////
static Function IR1T_fOblateForm(w,x) : FitFunc
	Wave w
	Variable x

//The input variables are (and output)
	//[0] scale
	//[1] crmaj, major radius of core	[A]
	//[2] crmin, minor radius of core
	//[3] trmaj, overall major radius
	//[4] trmin, overall minor radius
	//[5] sldc, core [A-2]
	//[6] slds, shell
	//[7] sld (solvent)
	//[8] bkg, [cm-1]
	Variable scale,crmaj,crmin,trmaj,trmin,delpc,delps,bkg,sldc,slds,sld
	scale = w[0]
	crmaj = w[1]
	crmin = w[2]
	trmaj = w[3]
	trmin = w[4]
	sldc = w[5]
	slds = w[6]
	sld = w[7]
	bkg = w[8]

	delpc = sldc - slds			//core - shell
	delps = slds - sld			//shell - solvent
	
// local variables
	Variable yyy,va,vb,ii,nord,zi,qq,summ,nfn,npro,answer,oblatevol
	String weightStr,zStr
	
	weightStr = "gauss76wt"
	zStr = "gauss76z"

	
//	if wt,z waves don't exist, create them

	if (WaveExists($weightStr) == 0) // wave reference is not valid, 
		Make/D/N=76 $weightStr,$zStr
		Wave w76 = $weightStr
		Wave z76 = $zStr		// wave references to pass
		IR1T_Make76GaussPoints(w76,z76)	
	//		    printf "w[0],z[0] = %g %g\r", w76[0],z76[0]
	else
		if(exists(weightStr) > 1) 
			 Abort "wave name is already in use"	// execute if condition is false
		endif
		Wave w76 = $weightStr
		Wave z76 = $zStr		// Not sure why this has to be "declared" twice
	//	    printf "w[0],z[0] = %g %g\r", w76[0],z76[0]	
	endif

// set up the integration
	// end points and weights
	nord = 76
	nfn = 2		//only <f^2> is calculated
	npro = 0	// OBLATE ELLIPSOIDS
	va =0
	vb =1 

	qq = x		//current x point is the q-value for evaluation
      summ = 0.0
      ii=0
      do
      		//printf "top of nord loop, i = %g\r",i
        if(nfn ==1) //then 		// "f1" required for beta factor
          if(npro ==1) //then	// prolate
          	 zi = ( z76[ii]*(vb-va) + vb + va )/2.0	
//            yyy = w76[ii]*gfn1(zi,crmaj,crmin,trmaj,trmin,delpc,delps,qq)
          Endif
//
          if(npro ==0) //then	// oblate  
          	 zi = ( z76[ii]*(vb-va) + vb + va )/2.0
//            yyy = w76[ii]*gfn3(zi,crmaj,crmin,trmaj,trmin,delpc,delps,qq)
          Endif
        Endif		//nfn = 1
        //
        if(nfn !=1) //then		//calculate"f2" = <f^2> = averaged form factor
          if(npro ==1) //then	//prolate
             zi = ( z76[ii]*(vb-va) + vb + va )/2.0
//            yyy = w76[ii]*gfn2(zi,crmaj,crmin,trmaj,trmin,delpc,delps,qq)
          //printf "yyy = %g\r",yyy
          Endif
//
          if(npro ==0) //then	//oblate
          	 zi = ( z76[ii]*(vb-va) + vb + va )/2.0
          	yyy = w76[ii]*IR1T_gfn4(zi,crmaj,crmin,trmaj,trmin,delpc,delps,qq)
          Endif
        Endif		//nfn <>1
        
        summ = yyy + summ		// get running total of integral
        ii+=1
	while (ii<nord)				// end of loop over quadrature points
//   
// calculate value of integral to return

      answer = (vb-va)/2.0*summ
      
      // normalize by particle volume
      oblatevol = 4*Pi/3*trmaj*trmaj*trmin
      answer /= oblatevol
      
      //convert answer [A-1] to [cm-1]
      answer *= 1.0e8  
      //scale
      answer *= scale
      // //then add background
      answer += bkg

	Return (answer)
End
//
//     FUNCTION gfn4:    CONTAINS F(Q,A,B,MU)**2  AS GIVEN
//                       BY (53) & (58-59) IN CHEN AND
//                       KOTLARCHYK REFERENCE
//
//       <OBLATE ELLIPSOID>

static Function IR1T_gfn4(xx,crmaj,crmin,trmaj,trmin,delpc,delps,qq)
	Variable xx,crmaj,crmin,trmaj,trmin,delpc,delps,qq
	// local variables
	Variable aa,bb,u2,ut2,uq,ut,vc,vt,gfnc,gfnt,tgfn,gfn4,pi43
	Variable siq,sit
	
	PI43=4.0/3.0*PI
  	aa = crmaj
 	bb = crmin
 	u2 = (bb*bb*xx*xx + aa*aa*(1.0-xx*xx))
 	ut2 = (trmin*trmin*xx*xx + trmaj*trmaj*(1.0-xx*xx))
   	uq = sqrt(u2)*qq
 	ut= sqrt(ut2)*qq
	vc = PI43*aa*aa*bb
   	vt = PI43*trmaj*trmaj*trmin
   	if(uq == 0)
   		siq = 1/3
   	else
   		siq = (sin(uq)/uq/uq - cos(uq)/uq)/uq
   	endif
   	if(ut == 0)
   		sit = 1/3
   	else
   		sit = (sin(ut)/ut/ut - cos(ut)/ut)/ut
   	endif
   	
   	gfnc = 3.0*siq*vc*delpc
  	gfnt = 3.0*sit*vt*delps
  	tgfn = gfnc+gfnt
  	gfn4 = tgfn*tgfn
  	
  	return gfn4
  	
End 		// function gfn4 for oblate ellipsoids 

///////////////////////////////////////////////////////////////
// unsmeared model calculation
///////////////////////////
static Function IR1T_fProlateForm(w,x) : FitFunc
	Wave w
	Variable x

//The input variables are (and output)
	//[0] scale
	//[1] crmaj, major radius of core	[A]
	//[2] crmin, minor radius of core
	//[3] trmaj, overall major radius
	//[4] trmin, overall minor radius
	//[5] sld core, [A^-2]
	//[6] sld shell, 
	//[7] sld solvent
	//[8] bkg [cm-1]
	Variable scale,crmaj,crmin,trmaj,trmin,delpc,delps,bkg,sldc,slds,sld
	scale = w[0]
	crmaj = w[1]
	crmin = w[2]
	trmaj = w[3]
	trmin = w[4]
	sldc = w[5]
	slds = w[6]
	sld = w[7]
	bkg = w[8]

	delpc = sldc - slds			//core - shell
	delps = slds - sld 			//shell - solvent
// local variables
	Variable yyy,va,vb,ii,nord,zi,qq,summ,nfn,npro,answer,prolatevol
	String weightStr,zStr
	
	weightStr = "gauss76wt"
	zStr = "gauss76z"

//	if wt,z waves don't exist, create them

	if (WaveExists($weightStr) == 0) // wave reference is not valid, 
		Make/D/N=76 $weightStr,$zStr
		Wave w76 = $weightStr
		Wave z76 = $zStr		// wave references to pass
		IR1T_Make76GaussPoints(w76,z76)	
	else
		if(exists(weightStr) > 1) 
			 Abort "wave name is already in use"	// execute if condition is false
		endif
		Wave w76 = $weightStr
		Wave z76 = $zStr
	endif

// set up the integration
	// end points and weights
	nord = 76
	nfn = 2		//only <f^2> is calculated
	npro = 1	// PROLATE ELLIPSOIDS
	va =0
	vb =1 
//move this zi(i) evaluation inside other nord loop, since I don't have an array
//      i=0
//      do 
//       zi[i] = ( z76[i]*(vb-va) + vb + va )/2.0
 //       i +=1
 //  	while (i<nord)
//
// evaluate at Gauss points 
	// remember to index from 0,size-1

	qq = x		//current x point is the q-value for evaluation
	summ = 0.0
	ii=0
	do
		//printf "top of nord loop, i = %g\r",i
		if(nfn ==1) //then 		// "f1" required for beta factor
			if(npro ==1) //then	// prolate
				zi = ( z76[ii]*(vb-va) + vb + va )/2.0	
//	     yyy = w76[ii]*gfn1(zi,crmaj,crmin,trmaj,trmin,delpc,delps,qq)
			Endif
//
			if(npro ==0) //then	// oblate  
				zi = ( z76[ii]*(vb-va) + vb + va )/2.0
//	      yyy = w76[i]*gfn3(zi,crmaj,crmin,trmaj,trmin,delpc,delps,qq)
			Endif
		Endif		//nfn = 1
	  //
		if(nfn !=1) //then		//calculate"f2" = <f^2> = averaged form factor
			if(npro ==1) //then	//prolate
				zi = ( z76[ii]*(vb-va) + vb + va )/2.0
				yyy = w76[ii]*IR1T_gfn2(zi,crmaj,crmin,trmaj,trmin,delpc,delps,qq)
				//printf "yyy = %g\r",yyy
			Endif
//
			if(npro ==0) //then	//oblate
				zi = ( z76[ii]*(vb-va) + vb + va )/2.0
//	   	yyy = w76[ii]*gfn4(zi,crmaj,crmin,trmaj,trmin,delpc,delps,qq)
			Endif
		Endif		//nfn <>1
	  
		summ = yyy + summ		// get running total of integral
		ii+=1
	while (ii<nord)				// end of loop over quadrature points
//   
// calculate value of integral to return

	answer = (vb-va)/2.0*summ
	
	//normailze by particle volume
	prolatevol = 4*Pi/3*trmaj*trmin*trmin
	answer /= prolatevol
	
	// rescale from 1/A to 1/cm
	answer *= 1.0e8
	//scale (arb)
	answer *= scale
	////then add in background
	answer += bkg

	Return (answer)
End 	//prolate form factor

//
//     FUNCTION gfn2:    CONTAINS F(Q,A,B,mu)**2  AS GIVEN
//                       BY (53) AND (56,57) IN CHEN AND 
//                       KOTLARCHYK REFERENCE
//
//     <PROLATE ELLIPSOIDS>
//
static Function IR1T_gfn2(xx,crmaj,crmin,trmaj,trmin,delpc,delps,qq)
	Variable xx,crmaj,crmin,trmaj,trmin,delpc,delps,qq
	// local variables
	Variable aa,bb,u2,ut2,uq,ut,vc,vt,gfnc,gfnt,tgfn,gfn2,pi43,gfn
	Variable siq,sit

	PI43=4.0/3.0*PI
	aa = crmaj
	bb = crmin
	u2 = (aa*aa*xx*xx + bb*bb*(1.0-xx*xx))
	ut2 = (trmaj*trmaj*xx*xx + trmin*trmin*(1.0-xx*xx))
	uq = sqrt(u2)*qq
	ut= sqrt(ut2)*qq
	vc = PI43*aa*bb*bb
	vt = PI43*trmaj*trmin*trmin
	
	if(uq == 0.0)
   		siq = 1.0/3.0
   else
   		siq = (sin(uq)/uq/uq - cos(uq)/uq)/uq
   	endif
   	if(ut == 0.0)
   		sit = 1.0/3.0
   	else
   		sit = (sin(ut)/ut/ut - cos(ut)/ut)/ut
   	endif
   	
	gfnc = 3.0*siq*vc*delpc
	gfnt = 3.0*sit*vt*delps
	gfn = gfnc+gfnt
	gfn2 = gfn*gfn
	
	return gfn2
End		//function gfn2 for prolate ellipsoids


