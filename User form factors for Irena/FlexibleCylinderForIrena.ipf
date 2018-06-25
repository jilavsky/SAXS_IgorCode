#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


//NOTE: this code is copy of code from FexibleCylinder_v40.ipf from NIST Igor package, modified to use in Irena. 
// Below are original notes from the NIST package:
//CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
//CCCCCCCC
//C      SUBROUTINE FOR THE CALCULATION OF THE SCATTERING FUNCTIONS
//C      OF RODLIKE MICELLES.  METHODLOGY FOLLOWS THAT OF PEDERSEN AND
//C      SCHURTENBERGER, MACORMOLECULES, VOL 29,PG 7602, 1996.
//C      WITH EXCULDED VOLUME EFFECTS (METHOD 3)
//
// - copied directly from FORTRAN code supplied by Jan Pedersen
//		SRK - 2002, but shows discontinuity at Qlb = 3.1
//
//  Jan 2006 - re-worked FORTRAN correcting typos in paper: now is smooth, but
// the splicing is actually at Qlb = 2, which is not what the paper
// says is to be done (and not from earlier models)
//
// July 2006 - now is CORRECT with Wei-Ren's changes to the code
// Matlab code was not too difficult to convert to Igor (only a few hours...)
//
// June 2018 modified for Irena use by Jan Ilavsky, all glory for the code goes to Jan Pedersen and Steven Kline (NIST group). I did nothing useful...  

//*************************************************************************************************
//*************************************************************************************************
//USE in Irena :
//In Modeling II select User form factor 
//In panel put in "Name of ForFactor function this string:    IR1T_FlexExclVolCyl
//In Panel put in Name of volume FF function this string:    IR1T_FlexExclVolCylVol
//
// Parameter 1 is the length of the cylinder
// Parameter 2 is the Kuhn length
// other parameters are not being used. 
//*************************************************************************************************
//*************************************************************************************************


//****   IR1T_FlexExclVolCyl ***** is simply the form factor, which normalizes to 1 at Q=0
Function IR1T_FlexExclVolCyl(Qval,radius, par1,par2,par3,par4,par5)
	variable Qval, radius, par1,par2,par3,par4,par5												
	//create coef wave needed for the parameters
	Make/O/D/Free coef_fle = {1.,par1,par2,radius,2,1,0}
	//this is the meaning of those parameters... 
	//make/o/t parameters_fle = {"scale","Contour Length (A)","Kuhn Length, b (A)","Radius (A)","SLD cylinder (A^-2)","SLD solvent (A^-2)","bkgd (cm^-1)"}
	//Irena handles scaling and background on its own, so those need to be set to 1 and 0
	// this wave also contains the radius, which is parameter Irena changes... 
	//Irena handles contrasts typically also, but in this case it may be easier to stick them here and then use 1 for Contrast in Irena panel. 
	//so par 1 is Contour length
	//par 2 is Kuhn length
	//SLD cylinder (A^-2) I took out the slds from calculations, use irena contrast
	//SLD solvent (A^-2) I took out the slds from calcualtions, use irena contrast
	//this will now calculate the Form factor for a combination of Q and R	
	//note, at this moemnt (with removeal of contrasts, volume and other unit corrections in fFlexExclVolCyl below For factor gives 1 for Q=0, asi it shoudl do... 	
#if exists("FlexExclVolCylX")
	//	flex *= Pi*rad*rad*L	//need to fix this by dividing by (Pi*radius*radius*par1)
	//	flex *= cont^2			//cont is set to 1 above, so this does not apply. 
	//	flex *= 1.0e8			//also, fis this... Convert back to Form factor... 
	return sqrt(FlexExclVolCylX(coef_fle,Qval) / ((Pi*radius*radius*par1)/1e8) )/1e8
#else
	//I have cleaned this out of the form factor, no scaling needed... 
	return sqrt(IR1T_fFlexExclVolCyl(coef_fle,Qval))
#endif
	return(0)
end
//****   IR1T_FlexExclVolCylVol ***** is simply the volume of the cylinder
Function IR1T_FlexExclVolCylVol(radius, par1,par2,par3,par4,par5)		//returns the sphere volume
	variable radius, par1,par2,par3,par4,par5
	// par1 = length, so it may be as simple as this:
	return (pi*radius*radius*par1)
end
//*********************************************************************************************************
//*********************************************************************************************************
//*********************************************************************************************************
//notes and edits is likely Steven Kline, NIST, he developed the code. 
//These are all work functions, nothing really useful here for users... 
static Function IR1T_fFlexExclVolCyl(ww,x)
	Wave ww
	Variable x

	//nice names to the input params
	//ww[0] = scale
	//ww[1] = L [A]
	//ww[2] = B [A]
	//ww[3] = rad [A] cross-sectional radius
	//ww[4] = sld cylinder
	//ww[5] = sld solvent [A^-2]
	//ww[6] = bkg [cm-1]
	Variable scale,L,B,bkg,rad,qr,cont,sldc,slds
	
	scale = ww[0]
	L = ww[1]
	B = ww[2]
	rad = ww[3]
	sldc = ww[4]
	slds = ww[5]
	bkg = ww[6]
	qr = x*rad		//used for cross section contribution only
	
	cont = sldc-slds
	
	Variable flex,crossSect
	flex = IR1T_Sk_WR(x,L,B)
    
    if(qr == 0)
	    crossSect = 1
    else
    	crossSect = (2*bessJ(1,qr)/qr)^2
    endif
        
	//normalize form factor by multiplying by cylinder volume * cont^2
   // then convert to cm-1 by multiplying by 10^8
   // then scale = phi 

	flex *= crossSect
	//flex *= Pi*rad*rad*L
	//flex *= cont^2
	//flex *= 1.0e-8
//	print x, flex
   return (scale*flex + bkg)
End


//////////////////WRC corrected code below
// main function
static function IR1T_Sk_WR(q,L,b)
	Variable q,L,b
	//
	Variable p1,p2,p1short,p2short,q0,qconnect
	Variable c,epsilon,ans,q0short,Sexvmodify
	
	p1 = 4.12
	p2 = 4.42
	p1short = 5.36
	p2short = 5.62
	q0 = 3.1
	qconnect = q0/b
	//	
	q0short = max(1.9/sqrt(IR1T_Rgsquareshort(q,L,b)),3)
	
	//
	if(L/b > 10)
		C = 3.06/(L/b)^0.44
		epsilon = 0.176
	else
		C = 1
		epsilon = 0.170
	endif
	//
	
	if( L > 4*b ) // Longer Chains
		if (q*b <= 3.1)
			//Modified by Yun on Oct. 15,
			Sexvmodify = IR1T_Sexvnew(q, L, b)
			ans = Sexvmodify + C * (4/15 + 7./(15*IR1T_u_WR(q,L,b)) - (11/15 + 7./(15*IR1T_u_WR(q,L,b)))*exp(-IR1T_u_WR(q,L,b)))*(b/L) 
		else //q(i)*b > 3.1
			ans = IR1T_a1long(q, L, b, p1, p2, q0)/((q*b)^p1) + IR1T_a2long(q, L, b, p1, p2, q0)/((q*b)^p2) + pi/(q*L)
		endif 
	else //L <= 4*b Shorter Chains
		if (q*b <= max(1.9/sqrt(IR1T_Rgsquareshort(q,L,b)),3) )
			if (q*b<=0.01)
				ans = 1 - IR1T_Rgsquareshort(q,L,b)*(q^2)/3
			else
				ans = IR1T_Sdebye1(q,L,b)
			endif
		else	//q*b > max(1.9/sqrt(Rgsquareshort(q(i),L,b)),3)
			ans = IR1T_a1short(q,L,b,p1short,p2short,q0short)/((q*b)^p1short) + IR1T_a2short(q,L,b,p1short,p2short,q0short)/((q*b)^p2short) + pi/(q*L)
		endif
	endif
	
	return(ans)
end

//WR named this w (too generic)
static Function IR1T_w_WR(x)
    Variable x

    //C4 = 1.523;
    //C5 = 0.1477;
    Variable yy
    yy = 0.5*(1 + tanh((x - 1.523)/0.1477))

    return (yy)
end

//
static function IR1T_u1(q,L,b)
    Variable q,L,b
    Variable yy

    yy = IR1T_Rgsquareshort(q,L,b)*q^2
    
    return yy
end

// was named u
static function IR1T_u_WR(q,L,b)
    Variable q,L,b
    
    Variable yy
    yy = IR1T_Rgsquare(q,L,b)*(q^2)
    return yy
end



//
static function IR1T_Rgsquarezero(q,L,b)
    Variable q,L,b
    
    Variable yy
    yy = (L*b/6) * (1 - 1.5*(b/L) + 1.5*(b/L)^2 - 0.75*(b/L)^3*(1 - exp(-2*(L/b))))
    
    return yy
end

//
static function IR1T_Rgsquareshort(q,L,b)
    Variable q,L,b
    
    Variable yy
    yy = IR1T_AlphaSquare(L/b) * IR1T_Rgsquarezero(q,L,b)
    
    return yy
end

//
static function IR1T_Rgsquare(q,L,b)
    Variable q,L,b
    
    Variable yy
    yy = IR1T_AlphaSquare(L/b)*L*b/6
    
    return yy
end

//
static function IR1T_AlphaSquare(x)
    Variable x
    
    Variable yy
    yy = (1 + (x/3.12)^2 + (x/8.67)^3)^(0.176/3)

    return yy
end

//
static function IR1T_miu(x)
    Variable x
    
    Variable yy
    yy = (1/8)*(9*x - 2 + 2*log(1 + x)/x)*exp(1/2.565*(1/x + (1 - 1/(x^2))*log(1 + x)))
    
    return yy
end

//
static function IR1T_Sdebye(q,L,b)
    Variable q,L,b
    
    Variable yy
    yy = 2*(exp(-IR1T_u_WR(q,L,b)) + IR1T_u_WR(q,L,b) -1)/((IR1T_u_WR(q,L,b))^2) 

    return yy
end

//
static function IR1T_Sdebye1(q,L,b)
    Variable q,L,b
    
    Variable yy
    yy = 2*(exp(-IR1T_u1(q,L,b)) + IR1T_u1(q,L,b) -1)/((IR1T_u1(q,L,b))^2)
    
    return yy
end

//
static function IR1T_Sexv(q,L,b)
    Variable q,L,b
    
    Variable yy,C1,C2,C3,miu,Rg2
    C1=1.22
    C2=0.4288
    C3=-1.651
    miu = 0.585

    Rg2 = IR1T_Rgsquare(q,L,b)
    
    yy = (1 - IR1T_w_WR(q*sqrt(Rg2)))*IR1T_Sdebye(q,L,b) + IR1T_w_WR(q*sqrt(Rg2))*(C1*(q*sqrt(Rg2))^(-1/miu) +  C2*(q*sqrt(Rg2))^(-2/miu) +    C3*(q*sqrt(Rg2))^(-3/miu))
    
    return yy
end

// this must be WR modified version
static function IR1T_Sexvnew(q,L,b)
    Variable q,L,b
    
    Variable yy,C1,C2,C3,miu
    C1=1.22
    C2=0.4288
    C3=-1.651
    miu = 0.585

    //calculating the derivative to decide on the corection (cutoff) term?
    // I have modified this from WRs original code
    Variable del=1.05,C_star2,Rg2
    if( (IR1T_Sexv(q*del,L,b)-IR1T_Sexv(q,L,b))/(q*del - q) >= 0 )
        C_star2 = 0
    else
        C_star2 = 1
    endif

    Rg2 = IR1T_Rgsquare(q,L,b)
    
    yy = (1 - IR1T_w_WR(q*sqrt(Rg2)))*IR1T_Sdebye(q,L,b) + C_star2*IR1T_w_WR(q*sqrt(Rg2))*(C1*(q*sqrt(Rg2))^(-1/miu) + C2*(q*sqrt(Rg2))^(-2/miu) + C3*(q*sqrt(Rg2))^(-3/miu))

    return yy
end



// these are the messy ones
static function IR1T_a2short(q, L, b, p1short, p2short, q0)
    Variable q, L, b, p1short, p2short, q0
    
    Variable yy,Rg2_sh
    Rg2_sh = IR1T_Rgsquareshort(q,L,b)
    
    Variable t1
    t1 = ((q0^2*Rg2_sh)/b^2)
    
    //E is the number e
    yy = ((-(1/(L*((p1short - p2short))*Rg2_sh^2)*((b*E^(-t1)*q0^(-4 + p2short)*((8*b^3*L - 8*b^3*E^t1*L - 2*b^3*L*p1short + 2*b^3*E^t1*L*p1short + 4*b*L*q0^2*Rg2_sh + 4*b*E^t1*L*q0^2*Rg2_sh - 2*b*E^t1*L*p1short*q0^2*Rg2_sh - E^t1*pi*q0^3*Rg2_sh^2 + E^t1*p1short*pi*q0^3*Rg2_sh^2)))))))
          
    return yy
end

//
static function IR1T_a1short(q, L, b, p1short, p2short, q0)
    Variable q, L, b, p1short, p2short, q0
    
    Variable yy,Rg2_sh
    Rg2_sh = IR1T_Rgsquareshort(q,L,b)

    Variable t1
    t1 = ((q0^2*Rg2_sh)/b^2)
    
    yy = ((1/(L*((p1short - p2short))*Rg2_sh^2)*((b*E^(-t1)*q0^((-4) + p1short)*((8*b^3*L - 8*b^3*E^t1*L - 2*b^3*L*p2short + 2*b^3*E^t1*L*p2short + 4*b*L*q0^2*Rg2_sh + 4*b*E^t1*L*q0^2*Rg2_sh - 2*b*E^t1*L*p2short*q0^2*Rg2_sh - E^t1*pi*q0^3*Rg2_sh^2 + E^t1*p2short*pi*q0^3*Rg2_sh^2)))))) 
        
    return yy
end

// this one will be lots of trouble
static function IR1T_a2long(q, L, b, p1, p2, q0)
    variable q, L, b, p1, p2, q0

    Variable yy,c1,c2,c3,c4,c5,miu,c,Rg2,rRg
    Variable t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13

    if( L/b > 10)
        C = 3.06/(L/b)^0.44
    else
        C = 1
    endif

    C1 = 1.22 
    C2 = 0.4288
    C3 = -1.651
    C4 = 1.523
    C5 = 0.1477
    miu = 0.585

    Rg2 = IR1T_Rgsquare(q,L,b)
    t1 = (1/(b* p1*q0^((-1) - p1 - p2) - b*p2*q0^((-1) - p1 - p2)))
    t2 = (b*C*(((-1*((14*b^3)/(15*q0^3*Rg2))) + (14*b^3*E^(-((q0^2*Rg2)/b^2)))/(15*q0^3*Rg2) + (2*E^(-((q0^2*Rg2)/b^2))*q0*((11/15 + (7*b^2)/(15*q0^2*Rg2)))*Rg2)/b)))/L
    t3 = (sqrt(Rg2)*((C3*(((sqrt(Rg2)*q0)/b))^((-3)/miu) + C2*(((sqrt(Rg2)*q0)/b))^((-2)/miu) + C1*(((sqrt(Rg2)*q0)/b))^((-1)/miu)))*IR1T_sech_WR(((-C4) + (sqrt(Rg2)*q0)/b)/C5)^2)/(2*C5)
    t4 = (b^4*sqrt(Rg2)*(((-1) + E^(-((q0^2*Rg2)/b^2)) + (q0^2*Rg2)/b^2))*IR1T_sech_WR(((-C4) + (sqrt(Rg2)*q0)/b)/C5)^2)/(C5*q0^4*Rg2^2)
    t5 = (2*b^4*(((2*q0*Rg2)/b - (2*E^(-((q0^2*Rg2)/b^2))*q0*Rg2)/b))*((1 + 1/2*(((-1) - tanh(((-C4) + (sqrt(Rg2)*q0)/b)/C5))))))/(q0^4*Rg2^2)
    t6 = (8*b^5*(((-1) + E^(-((q0^2*Rg2)/b^2)) + (q0^2*Rg2)/b^2))*((1 + 1/2*(((-1) - tanh(((-C4) + (sqrt(Rg2)*q0)/b)/C5))))))/(q0^5*Rg2^2)
    t7 = (((-((3*C3*sqrt(Rg2)*(((sqrt(Rg2)*q0)/b))^((-1) - 3/miu))/miu)) - (2*C2*sqrt(Rg2)*(((sqrt(Rg2)*q0)/b))^((-1) - 2/miu))/miu - (C1*sqrt(Rg2)*(((sqrt(Rg2)*q0)/b))^((-1) - 1/miu))/miu))
    t8 = ((1 + tanh(((-C4) + (sqrt(Rg2)*q0)/b)/C5)))
    t9 = (b*C*((4/15 - E^(-((q0^2*Rg2)/b^2))*((11/15 + (7*b^2)/(15*q0^2*Rg2))) + (7*b^2)/(15*q0^2*Rg2))))/L
    t10 = (2*b^4*(((-1) + E^(-((q0^2*Rg2)/b^2)) + (q0^2*Rg2)/b^2))*((1 + 1/2*(((-1) - tanh(((-C4) + (sqrt(Rg2)*q0)/b)/C5))))))/(q0^4*Rg2^2)
 
    
    yy = ((-1*(t1* (((-q0^(-p1))*(((b^2*pi)/(L*q0^2) + t2 + t3 - t4 + t5 - t6 + 1/2*t7*t8)) - b*p1*q0^((-1) - p1)*(((-((b*pi)/(L*q0))) + t9 + t10 + 1/2*((C3*(((sqrt(Rg2)*q0)/b))^((-3)/miu) + C2*(((sqrt(Rg2)*q0)/b))^((-2)/miu) + C1*(((sqrt(Rg2)*q0)/b))^((-1)/miu)))*((1 + tanh(((-C4) + (sqrt(Rg2)*q0)/b)/C5))))))))))


    return yy
end

//need to define this on my own
static Function IR1T_sech_WR(x)
	variable x
	
	return(1/cosh(x))
end
//
static function IR1T_a1long(q, L, b, p1, p2, q0)
    Variable q, L, b, p1, p2, q0
    
    Variable yy,c,c1,c2,c3,c4,c5,miu,Rg2,rRg
    Variable t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16
    
    if( L/b > 10)
        C = 3.06/(L/b)^0.44
    else
        C = 1
    endif

    C1 = 1.22
    C2 = 0.4288
    C3 = -1.651
    C4 = 1.523
    C5 = 0.1477
    miu = 0.585

    Rg2 = IR1T_Rgsquare(q,L,b)
    t1 = (b*C*((4/15 - E^(-((q0^2*Rg2)/b^2))*((11/15 + (7*b^2)/(15*q0^2*Rg2))) + (7*b^2)/(15*q0^2*Rg2))))
    t2 = (2*b^4*(((-1) + E^(-((q0^2*Rg2)/b^2)) + (q0^2*Rg2)/b^2))*((1 + 1/2*(((-1) - tanh(((-C4) + (sqrt(Rg2)*q0)/b)/C5))))))
    t3 = ((C3*(((sqrt(Rg2)*q0)/b))^((-3)/miu) + C2*(((sqrt(Rg2)*q0)/b))^((-2)/miu) + C1*(((sqrt(Rg2)*q0)/b))^((-1)/miu)))
    t4 = ((1 + tanh(((-C4) + (sqrt(Rg2)*q0)/b)/C5)))
    t5 = (1/(b*p1*q0^((-1) - p1 - p2) - b*p2*q0^((-1) - p1 - p2)))
    t6 = (b*C*(((-((14*b^3)/(15*q0^3*Rg2))) + (14*b^3*E^(-((q0^2*Rg2)/b^2)))/(15*q0^3*Rg2) + (2*E^(-((q0^2*Rg2)/b^2))*q0*((11/15 + (7*b^2)/(15*q0^2*Rg2)))*Rg2)/b)))
    t7 = (sqrt(Rg2)*((C3*(((sqrt(Rg2)*q0)/b))^((-3)/miu) + C2*(((sqrt(Rg2)*q0)/b))^((-2)/miu) + C1*(((sqrt(Rg2)*q0)/b))^((-1)/miu)))*IR1T_sech_WR(((-C4) + (sqrt(Rg2)*q0)/b)/C5)^2)
    t8 = (b^4*sqrt(Rg2)*(((-1) + E^(-((q0^2*Rg2)/b^2)) + (q0^2*Rg2)/b^2))*IR1T_sech_WR(((-C4) + (sqrt(Rg2)*q0)/b)/C5)^2)
    t9 = (2*b^4*(((2*q0*Rg2)/b - (2*E^(-((q0^2*Rg2)/b^2))*q0*Rg2)/b))*((1 + 1/2*(((-1) - tanh(((-C4) + (sqrt(Rg2)*q0)/b)/C5))))))
    t10 = (8*b^5*(((-1) + E^(-((q0^2*Rg2)/b^2)) + (q0^2*Rg2)/b^2))*((1 + 1/2*(((-1) - tanh(((-C4) + (sqrt(Rg2)*q0)/b)/C5))))))
    t11 = (((-((3*C3*sqrt(Rg2)*(((sqrt(Rg2)*q0)/b))^((-1) - 3/miu))/miu)) - (2*C2*sqrt(Rg2)*(((sqrt(Rg2)*q0)/b))^((-1) - 2/miu))/miu - (C1*sqrt(Rg2)*(((sqrt(Rg2)*q0)/b))^((-1) - 1/miu))/miu))
    t12 = ((1 + tanh(((-C4) + (sqrt(Rg2)*q0)/b)/C5)))
    t13 = (b*C*((4/15 - E^(-((q0^2*Rg2)/b^2))*((11/15 + (7*b^2)/(15*q0^2* Rg2))) + (7*b^2)/(15*q0^2*Rg2))))
    t14 = (2*b^4*(((-1) + E^(-((q0^2*Rg2)/b^2)) + (q0^2*Rg2)/b^2))*((1 + 1/2*(((-1) - tanh(((-C4) + (sqrt(Rg2)*q0)/b)/C5))))))
    t15 = ((C3*(((sqrt(Rg2)*q0)/b))^((-3)/miu) + C2*(((sqrt(Rg2)*q0)/b))^((-2)/miu) + C1*(((sqrt(Rg2)*q0)/b))^((-1)/miu)))

    
    yy = (q0^p1*(((-((b*pi)/(L*q0))) +t1/L +t2/(q0^4*Rg2^2) + 1/2*t3*t4)) + (t5*((q0^(p1 - p2)*(((-q0^(-p1))*(((b^2*pi)/(L*q0^2) +t6/L +t7/(2*C5) -t8/(C5*q0^4*Rg2^2) +t9/(q0^4*Rg2^2) -t10/(q0^5*Rg2^2) + 1/2*t11*t12)) - b*p1*q0^((-1) - p1)*(((-((b*pi)/(L*q0))) +t13/L +t14/(q0^4*Rg2^2) + 1/2*t15*((1 + tanh(((-C4) + (sqrt(Rg2)*q0)/b)/C5)))))))))))

    
    return yy
end
