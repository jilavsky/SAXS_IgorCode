#pragma TextEncoding = "UTF-8"
#pragma rtGlobals = 2			// Use strict wave reference mode and runtime bounds checking
#pragma version=2.05


//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/


//		 reduced rtGlobals to 2 due to bug on lines 609, 610 , reported bug to Jon Tisher
//2.05 fixed some values for Be and Mo which were found wrong by John Tishler. 
//2.04  removed unused functions
//2.03 tried converting to rtGlobals=3, but on run there is runtime error on Cromer_Get_fp. Index out od bounds. 
//2.02 Fixed comments on how to use sicne they were from independenrt CremoerLiberman.ipf while this is part of Irena and all non-static function start with IR1_
//2.01 added license for ANL


//This is implementation of Cromer-Liberman code for calcualtions of fprime and f double prime, and mu-over-rho
// included is also code to calculate f0 as function f Q ( = 2p/d = 4*pi*sin(theta)/lambda [A^-1])
//
//   Jan Ilavsky, 1/8/2004
//   ilavsky@aps.anl.gov
//this code gives same results as old fortran code from Cromer and Liberman. It was tested for various energies and 
//elements and I believe, it works. If you have any comments, suggestions or find bugs, please let me know.
//Tested on Igor 4.08 and Igor 5.0

// release 1.4, corrected number of typos in names and Q definition, few bugs fixed and added user control of precision at which the buffered values are returned instead of 
// 		recalculating them. See static constants below for user controllable items.
// release 1.5 fixed problem with folders being changed during calls to the functions. Fixed buffer calls, added "aging" of records, the "buffer" function whould now work. 
//		Changed number of records to keep to 200. Fixed bug, when Q for f0 calcualtions was not properly scaled internally to sin(theta)/Lambda - the results were off significantly...

//this code is translated from C translation of the Fortran source code. It is inefficient and difficult to read.
//
//**********
//				This is OLD README from Fortran
//
///*     QUESTIONS CONCERNING THIS PROGRAM SHOULD BE ADDRESSED TO
//            DON T. CROMER   MST-5
//            MAIL STOP G730
//            LOS ALAMOS NATIONAL LABORATORY
//            LOS ALAMOS, NEW MEXICO 87545
//     THE CROSS SECTION FILE WILL HAVE A NUMBER OF ORBITALS
//     THE FIRST MX CARDS (MX=5 FOR THIS XSECTION FILE AND IS SET IN PROGRAM)
//     FOR EACH ORBITAL WILL HAVE CROSS SECTIONS AT MX VALUES OF ENERGY
//     FROM ABOUT 1 TO 80 KEV APPROXIMATELY EQUALLY SPACED IN LOG(ENERGY)
//     THE NEXT FIVE RECORDS WILL BE CROSS SECTIONS AT ENERGIES SELECTED
//     BY GAUSS INTEGRATION SCHEME. IF THE FUNCTION TYPE IS 0 (IF=0)
//     ( FUNCTION TYPE GIVEN IN CROMER AND LIBERMAN
//         J. CHEM. PHYS. 53,1891-1898(1970)     )
//     A SIXTH VALUE IS READ IN FOR AN ENERGY=1.001*(BINDING ENERGY).
//     IF THE XRAY ENERGY IS LESS THAN BINDING ENERGY, FUNCTION sigma3
//     WILL BE USED (CROMER AND LIBERMAN ACTA CRYST. A37,267-268(1981))
//
//     FILES IN IO AND IS ARE SET AT THE BEGINNING OF THE PROGRAM
//     THESE WILL DEPEND ON LOCAL CONVENTIONS
//
//         ***********WARNING*************
//
//     IF AN XRAY ENERGY IS VERY CLOSE TO ONE OF THE ENERGIES
//     USED IN THE GAUSS INTEGRATION AN ANOMALOUS ANOMALOUS SCATTERING
//     FACTOR MAY RESULT. THERE IS NO EASY WAY OUT OF THIS PROBLEM. A
//     SUGGESTED WAY IS TO COMPUTE SEVERAL VALUES AT NEARBY ENERGIES
//     AND DRAW A SMOOTH CURVE. THIS METHOD SHOULD WORK PROVIDED
//     THE POINTS DO NOT PASS THROUGH AN EDGE
//
//*****************************
//				end of old readme
//***************************
//
//
// 				Comments on use of Igor code by Jan Ilavsky
//
//	Only following four functions are available to user, all other functions are static to this package:
//
//			all return values are in electrons except for (mu over rho) which is in [cm^2/gram]
//
//	IR1_Get_f(AtomType, Q, keV)				returns Complex f0+fp + i* fpp	 in [electron units]		input is "Atom name", Q = 2*pi/d=4*pi*sin(theta)/Lambda [A^-1], and energy in keV
//
//	IR1_Get_fp(AtomType, keV)				returns Complex fp + i* fpp	 in [electron units]			input is "Atom name" and energy in keV
//
//	IR1_Get_RealPartfp(AtomType, keV)		returns  fp as real number in [electron units]				input is "Atom name" and energy in keV
//
//	IR1_Get_ImagPartfpp(AtomType, keV)		returns  fpp as real number in [electron units]				input is "Atom name" and energy in keV
//
//	IR1_Get_MuOverRho(AtomType, keV)		returns mu over rho as real number in [cm^2/gram]		input is "Atom name" and energy in keV
//
//	IR1_Get_f0(AtomType,Q)					returns f0 as real number in  [electron units]				input is "Atom name" and Q = 2*pi/d=4*pi*sin(theta)/Lambda [A^-1]
//
//  	To speedup routine operations, the code creates database of calculated data. It contains up to CromerBufferLength
//      (defined below) values stored for faster access, when value already calculated is requested...

static constant CromerBufferLength=200							//number of last calculations stored for faster recall
static constant CromerBufferEnenergyPrecision=0.0001			//energy precision at which the value in buffer will be considered correct and will be returned to user instead of recalculating new one

//    The use of this database speeds up the process by factor of 40 or so when looking for data existing stored in the database.. 
//
//    It may be useful to reset all of the databases, which this code is using, including the Buffer database.
//		this can be accomplished by calling function
//
//		ResetCromerDataBase()
//
//
//   "Atom name" 	for f0 it is one of known atom states listed below. For other functions it is simple atom name. To simplify
//use, it is possible to pass all of the functions atom states names as listed for f0, they are cleaned up by the code for other calculations
//
//
//The following atoms are known to f0 calculations:
//H;H-1;He;Li;Li+1;Be;Be+2;B;C;N;O;O-1;F;F-1;Na;Na+1;Mg;Mg+2;Al;Al+3;Si;Si+4;P;S;Cl;Cl-1;  
//Ar;K;K+1;Ca;Ca+2;Sc;Sc+3;Ti;Ti+3;Ti+4;V;V+2;V+3;V+5;Cr;Cr+2;Cr+3;Mn;Mn+2;Mn+3;Mn+4;Fe;Fe+2;Fe+3;Co;  
//Co+2;Co+3;Ni;Ni+2;Ni+3;Cu;Cu+1;Cu+2;Zn;Zn+2;Ga;Ga+3;Ge;As;Se;Br;Br-1;Kr;Rb;Rb+1;Sr;Sr+2;Y;Y+3;Zr;  
//Zr+4;Nb;Nb+3;Nb+5;Mo;Mo+3;Mo+5;Mo+6;Tc;Ru;Ru+3;Ru+4;Rh;Rh+3;Rh+4;Pd;Pd+2;Pd+4;Ag;Ag+1;Ag+2;Cd;Cd+2;In;In+3;  
//Sn;Sn+2;Sn+4;Sb;Sb+3;Sb+5;Te;I;I-1;Xe;Cs;Cs+1;Ba;Ba+2;La;La+3;Ce;Ce+3;Ce+4;Pr;Pr+3;Pr+4;Nd;Nd+3;Pm;  
//Pm+3;Sm;Sm+3;Eu;Eu+2;Eu+3;Gd;Gd+3;Tb;Tb+3;Dy;Dy+3;Ho;Ho+3;Er;Er+3;Tm;Tm+3;Yb;Yb+2;Yb+3;Lu;Lu+3;Hf;Ta;  
//W;Re;Os;Ir;Pt;Au;Hg;Tl;Pb;Bi;Po;At;Rn;Fr;Ra;Ac;Th;Pa;U;Np;Pu;Am;Cm;Bk;Cf;  
//
//The following atoms are known to fprime, fdoubleprime and fpmu calculations:
//H;D;T;He;Li;Be;B;C;N;O;F;Ne;Na;Mg;Al;Si;P;S;Cl;Ar;K;Ca;Sc;Ti;V;  
//Cr;Mn;Fe;Co;Ni;Cu;Zn;Ga;Ge;As;Se;Br;Kr;Rb;Sr;Y;Zr;Nb;Mo;Tc;Ru;Rh;Pd;Ag;Cd;  
//In;Sn;Sb;Te;I;Xe;Cs;Ba;La;Ce;Pr;Nd;Pm;Sm;Eu;Gd;Tb;Dy;Ho;Er;Tm;Yb;Lu;Hf;Ta;  
//W;Re;Os;Ir;Pt;Au;Hg;Tl;Pb;Bi;Po;At;Rn;Fr;Ra;Ac;Th;Pa;U;Np;Pu;Am;Cm;Bk;Cf;  
//
//Wrap procedures - initialization (when needed) and calculate the values for user. 


// ************************************************************************ ********************************************************
Function/C IR1_Atomic_f_Xray(AtomType,Q,keV)// compute fo(Q)+f'(E)+f''(E), and mu too, call this from a menu
	String AtomType						// name of atom desired
	Variable Q							// 2*pi/d = 4*pi*sin(theta)/Lambda  (1/Angstroms)
	Variable keV							// energy (keV)


	String symbs=""
	symbs += "H;H-1;He;Li;Li+1;Be;Be+2;B;C;N;O;O-1;F;F-1;Na;Na+1;Mg;Mg+2;Al;Al+3;Si;Si+4;P;S;Cl;Cl-1;"
	symbs += "Ar;K;K+1;Ca;Ca+2;Sc;Sc+3;Ti;Ti+3;Ti+4;V;V+2;V+3;V+5;Cr;Cr+2;Cr+3;Mn;Mn+2;Mn+3;Mn+4;Fe;Fe+2;Fe+3;Co;"
	symbs += "Co+2;Co+3;Ni;Ni+2;Ni+3;Cu;Cu+1;Cu+2;Zn;Zn+2;Ga;Ga+3;Ge;As;Se;Br;Br-1;Kr;Rb;Rb+1;Sr;Sr+2;Y;Y+3;Zr;"
	symbs += "Zr+4;Nb;Nb+3;Nb+5;Mo;Mo+3;Mo+5;Mo+6;Tc;Ru;Ru+3;Ru+4;Rh;Rh+3;Rh+4;Pd;Pd+2;Pd+4;Ag;Ag+1;Ag+2;Cd;Cd+2;In;In+3;"
	symbs += "Sn;Sn+2;Sn+4;Sb;Sb+3;Sb+5;Te;I;I-1;Xe;Cs;Cs+1;Ba;Ba+2;La;La+3;Ce;Ce+3;Ce+4;Pr;Pr+3;Pr+4;Nd;Nd+3;Pm;"
	symbs += "Pm+3;Sm;Sm+3;Eu;Eu+2;Eu+3;Gd;Gd+3;Tb;Tb+3;Dy;Dy+3;Ho;Ho+3;Er;Er+3;Tm;Tm+3;Yb;Yb+2;Yb+3;Lu;Lu+3;Hf;Ta;"
	symbs += "W;Re;Os;Ir;Pt;Au;Hg;Tl;Pb;Bi;Po;At;Rn;Fr;Ra;Ac;Th;Pa;U;Np;Pu;Am;Cm;Bk;Cf;"

	AtomType = LowerStr(AtomType)
	AtomType[0,0] = UpperStr(AtomType[0])
	Variable printIt=0
	if (strlen(AtomType)<1 || numtype(Q) || Q<0 || numtype(keV) || keV<0)
		Q = numtype(Q) ? 0 : abs(Q)
		keV = numtype(keV) ? 8 : abs(keV)
		Prompt keV, "Energy of X-ray (keV)"
		Prompt Q, "Length of Q, 2pi/d = 4*pi*sin(theta)/Lambda (1/Angstrom)"
		Prompt AtomType, "symbol of atom", popup, symbs
		DoPrompt "pick atom, Q and Energy", AtomType,Q,keV
		if (V_flag)
		        return cmplx(NaN,NaN)
		endif
		printIt=1
	endif

	Variable/C f=IR1_Get_f(AtomType,Q,keV)
	Variable muRho=IR1_Get_MuOverRho(AtomType,keV)
	if (numtype(f) && printIt)
		printf "  f(%s,  Q=%g,  keV=%g) = Unknown symbol or bad energy\r",AtomType,Q,keV
	elseif(printIt)
		printf "  f(%s,  Q=%g,  keV=%g) = %g +i%g  (electrons),       and  mu/rho = %g (cm^2/g)\r",AtomType,Q, keV,real(f),imag(f),muRho
	endif
	return f
End
// ************************************************************************ ********************************************************


//********************************************************************************************************************************
Function/C IR1_Get_f(AtomType,Q, keV)				//returns complex value of f0+fp+i*fpp
	string AtomType
	variable keV,Q
	//keV - energy in keV
	//Q is scattering vector (2*pi/d) or also (4*pi*sin(theta)/lambda) [A^-1]
	//AtomType is "Fe" etc. 

	string OldDf=GetDataFOlder(1)
	variable/C result
	result= Cromer_Get_fp(CleanupAtomName(AtomType), keV, "ComplexF")+IR1_Get_f0(AtomType,Q)		
	setDataFOlder OldDf
	return result
end
//********************************************************************************************************************************
Function/C IR1_Get_fp(AtomType, keV)				//returns complex value of fp+i*fpp
	string AtomType
	variable keV
	//keV - energy in keV
	//AtomType is "Fe" etc. 
	
	string OldDf=GetDataFOlder(1)
	variable/C result
	result= Cromer_Get_fp(CleanupAtomName(AtomType), keV, "ComplexF")			//call static routine to calculate this....	
	setDataFOlder OldDf
	return result
end
//********************************************************************************************************************************
Function IR1_Get_RealPartfp(AtomType, keV)				//returns real value of fp
	string AtomType
	variable keV
	//keV - energy in keV
	//AtomType is "Fe" etc. 
	
	string OldDf=GetDataFOlder(1)
	variable result
	result= Cromer_Get_fp(CleanupAtomName(AtomType), keV, "Fprime")		//call static routine to calculate this....
	setDataFOlder OldDf
	return result
end
//********************************************************************************************************************************
Function IR1_Get_ImagPartfpp(AtomType, keV)			//returns real value of fpp
	string AtomType
	variable keV
	//keV - energy in keV
	//AtomType is "Fe" etc. 
	
	string OldDf=GetDataFOlder(1)
	variable result
	result= Cromer_Get_fp(CleanupAtomName(AtomType), keV, "FDoublePrime")	//call static routine to calculate this....
	setDataFOlder OldDf
	return result
end
//********************************************************************************************************************************
Function IR1_Get_MuOverRho(AtomType, keV)			//returns real value of mu over rho
	string AtomType
	variable keV
	//keV - energy in keV
	//AtomType is "Fe" etc. 
	
	string OldDf=GetDataFOlder(1)
	variable result
	result= Cromer_Get_fp(CleanupAtomName(AtomType), keV, "pmu")			//call static routine to calculate this....
	setDataFOlder OldDf
	return result
end
//********************************************************************************************************************************
Function IR1_Get_f0(AtomType,Q)					//returns value of f0
	string AtomType
	variable Q								//2*pi/d for scattering
	
	variable ScattVct
	ScattVct=Q/(4*pi)								//this scales the Q to sin(theta)/Lambda from input Q value. 
	//Cromer Mann code uses sin(theta)/Lambda, which is = Q/(4*pi)
	string OldDf=GetDataFOlder(1)
	variable result
	result= Cromer_Get_f0(AtomType,ScattVct)		//calls static function to calculate this
	setDataFolder OldDf
	return result
end
//********************************************************************************************************************************
Function IR1_ResetCromerDataBase()

	string OldDf=GetDataFolder(1)
	Cromer_Initialize(1)							//initialize
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:CromerCalculations
	Wave/Z FPrimeDataBase=root:Packages:CromerCalculations:FPrimeDataBase
	Wave/Z FPrimeDataBaseCounter=root:Packages:CromerCalculations:FPrimeDataBaseCounter
	Wave/T/Z FPrimeDataBaseAtoms=root:Packages:CromerCalculations:FPrimeDataBaseAtoms
	if (WaveExists(FPrimeDataBaseCounter))
//		FPrimeDataBaseCounter = -1
		Make/O/N=(0,5) FPrimeDataBase
		Make/O/N=(0) FPrimeDataBaseCounter
		Make/O/T/N=(0) FPrimeDataBaseAtoms
	endif
	setDataFolder OldDf
end
//********************************************************************************************************************************
//********************************************************************************************************************************
//********************************************************************************************************************************
// 
//		End of user-interesting part of this code
//
//		Do not change anything below this line, things may go really wrong....
//								You were warned.....
//********************************************************************************************************************************
//********************************************************************************************************************************
//********************************************************************************************************************************
//********************************************************************************************************************************
static Function Cromer_FindData(AtomType, xk, ReturnWhat)
	string AtomType, ReturnWhat	// FPrime, FDoublePrime, pmu
	variable xk
	
	Wave/Z FPrimeDataBase=root:Packages:CromerCalculations:FPrimeDataBase
	Wave/T/Z FPrimeDataBaseAtoms=root:Packages:CromerCalculations:FPrimeDataBaseAtoms
	Wave/Z FPrimeDataBaseCounter=root:Packages:CromerCalculations:FPrimeDataBaseCounter
	variable i
	if (!WaveExists(FPrimeDataBase) || !WaveExists(FPrimeDataBaseAtoms) || !WaveExists(FPrimeDataBaseCounter))
		return NaN
	endif
	FPrimeDataBaseCounter-=1				//decrease counter for all existing records = aging them...
	For(i=0;i<dimsize(FPrimeDataBase,0);i+=1)
		if (cmpstr(FPrimeDataBaseAtoms[i],AtomType)==0 && abs(xk-FPrimeDataBase[i][4])<CromerBufferEnenergyPrecision)		//the data record for this atom and energy exist
			if (cmpstr(ReturnWhat,"FPrime")==0)
				FPrimeDataBaseCounter[i]=100		
				return FPrimeDataBase[i][1]
			endif
			if (cmpstr(ReturnWhat,"FDoublePrime")==0)
				FPrimeDataBaseCounter[i]=100
				return FPrimeDataBase[i][2]
			endif
			if (cmpstr(ReturnWhat,"pmu")==0)
				FPrimeDataBaseCounter[i]=100
				return FPrimeDataBase[i][3]
			endif
		endif
	endfor
	return NaN
end
//********************************************************************************************************************************
//********************************************************************************************************************************
static Function/C Cromer_FindDataC(AtomType, xk)
	string AtomType
	variable xk
	
	Wave/Z FPrimeDataBase=root:Packages:CromerCalculations:FPrimeDataBase
	Wave/T/Z FPrimeDataBaseAtoms=root:Packages:CromerCalculations:FPrimeDataBaseAtoms
	Wave/Z FPrimeDataBaseCounter=root:Packages:CromerCalculations:FPrimeDataBaseCounter
	variable i
	if (!WaveExists(FPrimeDataBase) || !WaveExists(FPrimeDataBaseAtoms) || !WaveExists(FPrimeDataBaseCounter))
		return NaN
	endif
	FPrimeDataBaseCounter-=1				//decrease counter for all existing records = aging them...
	For(i=0;i<dimsize(FPrimeDataBase,0);i+=1)
		if (cmpstr(FPrimeDataBaseAtoms[i],AtomType)==0 && abs(xk-FPrimeDataBase[i][4])<CromerBufferEnenergyPrecision)		//the data record for this atom and energy exist
				FPrimeDataBaseCounter[i]=100														//increase the counter
				return cmplx(FPrimeDataBase[i][1],FPrimeDataBase[i][2])
		endif
	endfor
	return NaN
end
//********************************************************************************************************************************
//********************************************************************************************************************************
static Function Cromer_RecordData(AtomType, xk, fp,fpp, pmu)
	string AtomType
	variable xk, fp,fpp, pmu
	
	string OldDf=GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:CromerCalculations
	Wave/Z FPrimeDataBase=root:Packages:CromerCalculations:FPrimeDataBase
	Wave/Z FPrimeDataBaseCounter=root:Packages:CromerCalculations:FPrimeDataBaseCounter
	Wave/T/Z FPrimeDataBaseAtoms=root:Packages:CromerCalculations:FPrimeDataBaseAtoms
	variable NewLength, counter, i, j, mincounted
	if(!WaveExists(FPrimeDataBase))						//does not exists, create
		Make/O/N=(0,5) FPrimeDataBase
		Make/O/N=(0) FPrimeDataBaseCounter
		Make/O/T/N=(0) FPrimeDataBaseAtoms
		Wave FPrimeDataBase=root:Packages:CromerCalculations:FPrimeDataBase
		Wave FPrimeDataBaseCounter=root:Packages:CromerCalculations:FPrimeDataBaseCounter
		Wave/T FPrimeDataBaseAtoms=root:Packages:CromerCalculations:FPrimeDataBaseAtoms
	endif
	//check if these data are already in the database
	For(i=0;i<dimsize(FPrimeDataBase,0);i+=1)
		if (cmpstr(FPrimeDataBaseAtoms[i],AtomType)==0 && abs(xk-FPrimeDataBase[i][4])<CromerBufferEnenergyPrecision)		//the data record for this atom and energy exist
			if (numtype(fp)==0)
				FPrimeDataBase[i][1]=fp
			endif
			if (numtype(fpp)==0)
				FPrimeDataBase[i][2]=fpp
			endif
			if (numtype(pmu)==0)
				FPrimeDataBase[i][3]=pmu
			endif
			FPrimeDataBaseCounter=100			//reset counter for this record to original 100
		setDataFolder OldDf
		return 1
		endif
	endfor
	//create new record
	if (DimSize(FPrimeDataBase, 0)<=CromerBufferLength)		//less than 100 records in the database, create new record
		NewLength = dimsize(FPrimeDataBase,0)+1
		Redimension/N=(NewLength) FPrimeDataBaseAtoms			//add new field to database
		Redimension/N=(NewLength) FPrimeDataBaseCounter		//add new field to database
		Redimension/N=(NewLength,5) FPrimeDataBase
		FPrimeDataBaseAtoms[NewLength-1]=AtomType		//Atom name
		FPrimeDataBaseCounter[NewLength-1]=100				//how many times was recalled, set to 100 for starters, will be decreased with each call...
		FPrimeDataBase[NewLength-1][1]=fp					//real value with fp
		FPrimeDataBase[NewLength-1][2]=fpp					//real value of fpp
		FPrimeDataBase[NewLength-1][3]=pmu					//real value of pmu
		FPrimeDataBase[NewLength-1][4]=xk					//real value of energy
	else														//more than maximum number of records, find the one used least and replace it
		waveStats/Q FPrimeDataBaseCounter
		FPrimeDataBaseAtoms[V_minLoc]=AtomType				//Atom name
		FPrimeDataBaseCounter[V_minLoc]=100					//how many times was recalled, set to 100 for starters, will be decreased with each call...
		FPrimeDataBase[V_minLoc][1]=fp							//real value with fp
		FPrimeDataBase[V_minLoc][2]=fpp							//real value of fpp
		FPrimeDataBase[V_minLoc][3]=pmu						//real value of pmu
		FPrimeDataBase[V_minLoc][4]=xk							//real value of energy
	endif
	
	setDataFolder OldDf
	return 0
end
//********************************************************************************************************************************
//********************************************************************************************************************************
static Function/T CleanupAtomName(AtomType)
	string AtomType
	
	variable i, imax = strlen(AtomType)
	string FixedAtomType=""
	For(i=0;i<imax;i+=1)
		if(cmpstr(AtomType[i,i],"+")!=0 && cmpstr(AtomType[i,i],"-")!=0)
			FixedAtomType+=AtomType[i,i]
		else
			break
		endif	
	endfor
	return FixedAtomType
end

//********************************************************************************************************************************
//********************************************************************************************************************************
static Function Cromer_Initialize(Force)
	variable force
	
	string OldDf=GetDataFOlder(1)
	NewDataFolder/O/S root:Packages	
	NewDataFolder/O/S root:Packages:CromerCalculations

	if (Force)
		Cromer_SetLookupLists()
		Cromer_InitializeStrings()
		Cromer_InitializeWaves()
		setDataFolder oldDf
		return 0
	endif
	//first check for atomic data lists
	SVAR/Z ListOfElements
	SVAR/Z ListOfElNumbers
	SVAR/Z ListOfElAtomWghts
	if(!SVAR_Exists(ListOfElements) ||!SVAR_Exists(ListOfElNumbers) ||!SVAR_Exists(ListOfElAtomWghts))
		Cromer_SetLookupLists()	
	endif

	//NOw check for Cromer database for selected strings we need
	SVAR/Z '10'
	SVAR/Z '25'
	SVAR/Z '78'
	if(!SVAR_Exists('10') ||!SVAR_Exists('25') ||!SVAR_Exists('78'))
		Cromer_InitializeStrings()	
	endif
	
	//NOw check for Cromer database for selected waves we need
	Wave/Z '10Wv'
	Wave/Z '25Wv'
	Wave/Z '78Wv'
	if(!WaveExists('10Wv') ||!WaveExists('25Wv') ||!WaveExists('78Wv'))
		Cromer_InitializeWaves()
	endif	
	setDataFolder oldDf
end

//********************************************************************************************************************************
//********************************************************************************************************************************
//		Here go calculation functions
//********************************************************************************************************************************
static Function/C Cromer_Get_fp(AtomType, xK, ReturnWhat)
	string AtomType, ReturnWhat
	variable xK
	//Svector - scattering vector - 2*pi/d
	//xK - energy in keV
	//nord - order of interpolation
	//pmu - mu over rho (cm^2/g)
	//ReturnWhat - ComplexF, FPrime, FDoublePrime, pmu
	
	string OldDf=GetDataFolder(1)
	Cromer_Initialize(0)		//initialize, if needed		
	//first check the database, if we have appropriate record for this atom and energy
	if (cmpstr(ReturnWhat,"ComplexF")==0)
		variable/C testResComplex = Cromer_FindDataC(AtomType, xk)	
		if (numtype(real(testResComplex))==0 && abs(real(testResComplex))>0 && numtype(imag(testResComplex))==0 && abs(imag(testResComplex))>0)
			return testResComplex
		endif
	else
		variable testResult = Cromer_FindData(AtomType, xk, ReturnWhat)
		if((numtype(testResult)==0) && abs(testResult)>0)
			return testResult
		endif
	endif
	//we did nto find it in our databse, so let's calculate it...
	variable pmu
	variable nord=2
	
	variable/C fprime
	newDataFolder/O/S root:Packages:CromerCalculations
	//first some definitions of constants
	variable/g au=2.80022e7
	variable/g mx=5
	variable/g c=137.0367
	variable/g c1=0.02721
	variable/g delta_xk=0.1e-3
	//now define the needed waves and variables	
	//waves will be longer by 1 then needed, since we will not use the index 0 usually..
	make/O/d/n=6 sigg, eg		//we need 5 fields, 0 element will not be used...
	make/d/O/n=26 fp, fpp	
	make/d/O/n=11 ew, sig, el, sl	//we need only 10 or 11, will redimension as neeeded later
	make/d/O/n=82 TMatrix		//was T in original code
	variable/g cx, bb, rx, sedge, icount
	//now local variables
	variable f0		//structure factor
	variable zz		//compute simple Z electron point
	variable iz=0		//atomic number
	string natom	//atomic symbol
	string nat	//atomic symbol
	variable be, sigedg, zx, cxb=0, corr, sumfp, sumfpp, xjensn, et
	variable eterm, wt			//eterm from data and weight of atom
	
	variable i,j,k,m, n1, mm, no, nx, mf, IFValue, nj	//paramters and counters
	variable tempCsigma
	
	//here was definitions of everything else as database for all atoms in the system. We whoudl have by now all needed
	//let's read from our own records...
	
	fp = 0
	fpp = 0
	//Check that the element is in the database
	SVAR ListOfElements=root:Packages:CromerCalculations:ListOfElements
	string AtomName=AtomType[0]		//extract the element name
	if ((char2num(AtomType[1])>=65 && char2num(AtomType[1])<=90) ||(char2num(AtomType[1])>=97 && char2num(AtomType[1])<=122))
		AtomName+=AtomType[1]
	endif
	if (!stringmatch(ListOfElements, "*;"+AtomName+";*" ))			//check that the element exists
			Abort "This atom : "+ AtomName+" ; does not exist"
	endif
	if (nord<0 || nord>5)
		Abort "nord must be between 0 and 3"
	endif
	//get atomic number
	SVAR ListOfElNumbers=root:Packages:CromerCalculations:ListOfElNumbers
	iz=NumberByKey(AtomName, ListOfElNumbers  , "="  , ";")
	SVAR ListOfElAtomWghts=root:Packages:CromerCalculations:ListOfElAtomWghts
	wt=NumberByKey(AtomName, ListOfElAtomWghts  , "="  , ";")
	//get f0
//	f0=	Get_f0(AtomName,Svector)
	if (iz<=2)		//no corrections for H or He
		fprime = cmplx(0,0)
		return fprime
	endif
	//here goes Whaqt John has done - saveing results in backup and reusing when fitting... Need to add later.
	SVAR AtomInformation=$("root:Packages:CromerCalculations:'"+num2str(iz)+"'")
	//Wave CurElementWv=$(num2str(CurElementNumber)+"Wv")
	//the idexes are: p - number of triplet lines, q - up to 11 numbers, r - in r=0 we have energies, in r=1 we have cross sections in barns
	Wave CurElementWv=$("root:Packages:CromerCalculations:'"+num2str(iz)+"Wv'")
	eterm = NumberByKey("ETERM", AtomInformation , "=" , ";")
	no = NumberByKey("NSHELLS", AtomInformation , "=" , ";")
	//Now we can do for each orbital the calcualtion
	
	For(j=1;j<=no;j+=1)	//for each orbital

			//read in nat	 - atomic symbol  - that is known, it is AtomName
			//nj - orbital sequence number	- that is j
			//ew - energy in keV			- these are in the wave 
			//sig - cross section in barns	- again, in the wave
			//be  - binding energy			
			//IFvalue
			IFValue = NumberByKey("Shell"+num2str(j)+"FuncType", AtomInformation , "=" , ";")
			be  = NumberByKey("Shell"+num2str(j)+"BindEnergy", AtomInformation , "=" , ";")
			nat = AtomName
			nj = j
			redimension/N=11 ew, sig, el, sl	//reset the length here for this orbital
			//now extract 10 corrections and stuff them in ew and sig
		For(k=1;k<=10;k+=1)		
			ew[k] = CurElementWv[j-1] [k-1] [0]			//CurElementWv indexed from 0, ew from 1 
			sig[k] = CurElementWv[j-1] [k-1] [1]			//CurElementWv indexed from 0, ew from 1 			
		endfor
			//now extract first 5 corrections and stuff them in eg and sigg
		For(k=1;k<=5;k+=1)		
			eg[k] = CurElementWv[j-1] [5+k-1] [0]			//CurElementWv indexed from 0, ew from 1 
			sigg[k] = CurElementWv[j-1] [5+k-1] [1]			//CurElementWv indexed from 0, ew from 1 			
		endfor
		nx = 10
			//if IFValue==0, then we have 11th energy
		if(IFValue==0)
			nx=nx+1
			redimension/n=12 ew, sig, el, sl			//will need the 11th value
			ew[11] = CurElementWv[j-1] [10] [0]			//CurElementWv indexed from 0, ew from 1 
			sig[11] = CurElementWv[j-1] [10] [1]			//CurElementWv indexed from 0, ew from 1 		
			sigedg = sig[11]							//will need the sigedg later....
		endif
		//end of reading enegies and corrections, hopefully
		bb = be/C1		//convert binding energy and sigmas to internal funny units
		sigg = sigg/au
		Csort_fp(nx,ew, sig)		//sort them., use this function so do not have to worry about elements...
		Csort_fp(5,eg, sigg)
		
		el = ln(ew)
		sl = 0
		for(k=1;k<=nx;k+=1)
			if(sig[k]!=0)
				sl[k]=ln(sig[k])
			endif
		endfor
		mf = 0
		zx = ln(xk)			//zx is log of X-ray energy in keV
		cx = 0
		if(be<=xk)
			if(nord==0)
				Cxsect(zx,el,sl,cx,nx)
			else
				for(m=1;m<=nx;m+=1)
					n1 = m
					if (sl[m]!=0)
						break
					endif
				endfor
				mm = nx -n1 +1
				duplicate/O el, elc
				duplicate/O sl, slc
				elc = el[p+n1-1]
				slc = sl[p+n1-1]
				cx = cAknint(zx,mm,nord,elc,slc, tMatrix)
				cx = exp(cx)
			endif
			cxb = cxb + cx		//cxb is sum to get mu/rho
			cx = cx /AU			//change cx to atomic units...
		endif
		icount = 6
		rx=xk /C1				//xray energy in AU
		if((IFValue!=0) || (be<xk))
			if (IFValue>=0 && IFVAlue<=2)
				fp[j]=Cromer_Cgauss(IFValue) * C / (2*pi*pi)
			endif
		else
			sedge = sigedg / AU		//sedge is Xsection in atomic units and energy = 1.001 * BE
			cx = 0
			fp[j]=Cromer_Cgauss(3) * C / (2*pi*pi)			
			mf = 3
		endif
		fpp[j] = 0
		if(cx!=0)
			fpp[j] = C * cx * rx/(4*pi)
		endif
		corr = 0
		if(cx!=0)
			 corr = -cx * rx * 0.5 * ln((rx+bb)/(rx-bb))*C/(2*pi*pi)
		endif
		if(mf==3)
			corr = 0.5 * sedge * bb * bb * ln((-bb+rx)/(-bb-rx))/rx * C/(2*pi*pi)
		endif
		fp[j]=fp[j]+corr

	endfor
	
		sumfp = 0
		sumfpp = 0
		for(j=1;j<=no;j+=1)
			sumfp +=fp[j]
		endfor
		//xjensn = -0.5 * iz * (xk/C1/137.0367/137.0367)^2
		et = eterm
		sumfp = sumfp + et //+ xjensn
		//jensen correction was removed, according to NIST web site (10/09/2003, physics.nist.gov/PhysRevData/FFast/Text1995/chap10.html
		//the correction is incorrect. Also, NIST web site comments, that appropriate relativistic correction is only 3/5ths of Cromer-Leiberman 
		//value. This 3/5ths were not implemented in this code...
		//for deatails see http://physics.nist.gov/PhysRefData/FFast/Text1995/contents1995.html
		for(j=1;j<=no;j+=1)
			sumfpp += fpp[j]
		endfor
		cxb = cxb * 0.602472 / wt	
		pmu = cxb
		
		fprime = cmplx(sumfp,sumfpp)
//		print "f0 = "+num2str(f0)
//		print "fp = " + num2str(sumfp)
//		print "fpp = "+num2str(sumfpp)
//		print "pmu = "+num2str(pmu)

		Cromer_RecordData(AtomType, xk, sumfp,sumfpp, pmu)						//store new result, in the database

		setDataFolder OldDf		
		if(cmpstr(ReturnWhat,"ComplexF")==0)
			return fprime
		endif
		if(cmpstr(ReturnWhat,"FPrime")==0)
			return sumfp
		endif
		if(cmpstr(ReturnWhat,"FDoublePrime")==0)
			return sumfpp
		endif
		if(cmpstr(ReturnWhat,"pmu")==0)
			return pmu
		endif
		return NaN
		
end

//********************************************************************************************************************************
//********************************************************************************************************************************

static Function Cromer_Get_f0(AtomName,Svector)
	string AtomName
	variable Svector				//2*pi/d for scattering
	//this function retuns for give scattering vector value of f0 for any atom
	
	string oldDf=getDataFolder(1)
	//NewDataFolder/O root:Packages
	//NewDataFolder/O/S root:Packages:F0_calculations
	
	
	Wave/Z Awave=$("root:Packages:CromerCalculations:"+possiblyQuoteName(AtomName+"_a"))
	Wave/Z Bwave=$("root:Packages:CromerCalculations:"+possiblyQuoteName(AtomName+"_b"))
	NVAR/Z Cnumber=$("root:Packages:CromerCalculations:"+possiblyQuoteName(AtomName+"_c"))
	
	if (!WaveExists(Awave) || !WaveExists(Bwave) || !NVAR_Exists(Cnumber))
		Initialize_f0()
		Wave/Z Awave=$("root:Packages:CromerCalculations:"+possiblyQuoteName(AtomName+"_a"))
		Wave/Z Bwave=$("root:Packages:CromerCalculations:"+possiblyQuoteName(AtomName+"_b"))
		NVAR/Z Cnumber=$("root:Packages:CromerCalculations:"+possiblyQuoteName(AtomName+"_c"))
		if (!WaveExists(Awave) || !WaveExists(Bwave) || !NVAR_Exists(Cnumber))
			setDataFolder oldDf
			abort "Error in Get_f0 routine, database input for this atom (atom state) does not exist"
		endif
	endif
	
	variable i
	variable sumVal=Cnumber
	
	for(i=0;i<4;i+=1)
		sumVal+=Awave[i] * exp(-Svector*Svector*(Bwave[i]))
	endfor
	
	setDataFolder oldDf
	return sumVal
end

//********************************************************************************************************************************
//********************************************************************************************************************************


static Function Cxsect(zx, el, sl, cx, nx)
	variable zx, nx, cx
	wave el, sl

	variable	er
	variable	p
	variable	det
	variable	a0,a1,a2
	variable	l,ll

	er=1000000.;
	for(l=1;l<=nx;l+=1) 
		p = abs(zx-el[l])
		if (p<=er)
			er = p
			ll = l
		endif
	endfor
	ll-=1
	if (ll==0)
		 ll=1
	endif
	if (ll==12)
		ll=11
	endif
	if (sl[ll]==0.)
		ll+=1	
	endif

	det = el[ll+2]*el[ll+2]*(el[ll+1]-el[ll])+el[ll+1]*el[ll+1]*(el[ll]-el[ll+2])+el[ll]*el[ll]*(el[ll+2]-el[ll+1])
	a0 = (el[ll]*el[ll]*(sl[ll+1]*el[ll+2]-sl[ll+2]*el[ll+1])+el[ll+1]*el[ll+1]*(sl[ll+2]*el[ll]-sl[ll]*el[ll+2])+el[ll+2]*el[ll+2]*(sl[ll]*el[ll+1]-sl[ll+1]*el[ll]))/det
	a1 = (el[ll]*el[ll]*(sl[ll+2]-sl[ll+1])+el[ll+1]*el[ll+1]*(sl[ll]-sl[ll+2])+el[ll+2]*el[ll+2]*(sl[ll+1]-sl[ll]))/det
	a2 = (sl[ll]*(el[ll+2]-el[ll+1])+sl[ll+1]*(el[ll]-el[ll+2])+sl[ll+2]*(el[ll+1]-el[ll]))/det
	cx = exp(a0+a1*zx+a2*zx*zx)
end

//********************************************************************************************************************************
//********************************************************************************************************************************

static Function Cromer_CSigma(which,xPar)
	variable which, xPar
	
	if (which==0)
		return Csigma0(xPar)
	endif	
	if (which==1)
		return Csigma1(xPar)
	endif	
	if (which==2)
		return Csigma2(xPar)
	endif	
	if (which==3)
		return Csigma3(xPar)
	endif	
end

//********************************************************************************************************************************
//********************************************************************************************************************************


static Function Csigma0(xPar)
	variable xPar
	
	NVAR rx=root:Packages:CromerCalculations:rx
	variable sumRes
	NVAR iCount=root:Packages:CromerCalculations:iCount
	NVAR bb=root:Packages:CromerCalculations:bb
	NVAR cx=root:Packages:CromerCalculations:cx
	Wave sigg=root:Packages:CromerCalculations:sigg
	
	iCount = iCount -1
	sumRes = sigg[iCount] * (bb^3)/(xPar^2)/(rx^2*xPar^2 - bb^2) - bb*cx*(rx^2)/(rx^2*xPar^2-bb^2)
	return sumRes

end
//********************************************************************************************************************************
//********************************************************************************************************************************

static Function Csigma1(xPar)
	variable xPar
	
	NVAR rx=root:Packages:CromerCalculations:rx
	variable sumRes
	NVAR iCount=root:Packages:CromerCalculations:iCount
	NVAR bb=root:Packages:CromerCalculations:bb
	NVAR cx=root:Packages:CromerCalculations:cx
	Wave sigg=root:Packages:CromerCalculations:sigg
	
	iCount = iCount -1
	sumRes = 0.5 * bb^3 * sigg[iCount] / (sqrt(xPar) * (rx^2*xPar^2 - bb^2 * xPar))
	return sumRes

end
//********************************************************************************************************************************
//********************************************************************************************************************************

static Function Csigma2(xPar)
	variable xPar
	
	variable bb2, x2, rx2, sumRes, denom
	NVAR rx=root:Packages:CromerCalculations:rx
	NVAR iCount=root:Packages:CromerCalculations:iCount
	NVAR bb=root:Packages:CromerCalculations:bb
	NVAR cx=root:Packages:CromerCalculations:cx
	Wave sigg=root:Packages:CromerCalculations:sigg
	
	iCount = iCount -1
	x2  = xPar^2
	rx2 = rx^2
	bb2 = bb^2
	denom = xPar^3*rx2 - bb2/xPar
	sumRes = (2 * bb^3 * sigg[iCount]) / (xPar^4*denom) - (2 * bb *cx * rx2 /denom)
	return sumRes

end
//********************************************************************************************************************************
//********************************************************************************************************************************

static Function Csigma3(xPar)
	variable xPar
	
	NVAR sedge=root:Packages:CromerCalculations:sedge
	NVAR rx=root:Packages:CromerCalculations:rx
	variable sumRes
	NVAR iCount=root:Packages:CromerCalculations:iCount
	NVAR bb=root:Packages:CromerCalculations:bb
	NVAR cx=root:Packages:CromerCalculations:cx
	Wave sigg=root:Packages:CromerCalculations:sigg
	
	iCount = iCount -1
	sumRes = bb^3 * (sigg[iCount] - sedge * xPar^2) / (xPar^2 *(xPar^2 * rx^2 - bb^2))
	return sumRes

end
//********************************************************************************************************************************
//********************************************************************************************************************************

static Function Clgndr (m,k,aa,z)
	variable M,K,&AA,&Z
	make/O/N=69 AMatrixData
	make/O/N=63 XMatrixData
	XMatrixData[0,9]={0, .06943184420297, .33000947820757, .04691007703067,.23076534494716, .03376524289992, .16939530676687,.38069040695840, .02544604382862, .12923440720030}
	XMatrixData[10,18]={ .29707742431130, .01985507175123, .10166676129319,.23723379504184, .40828267875217, .01591988024619,.08198444633668, .19331428364971, .33787328829809}
	XMatrixData[19,27]={ .01304673574141, .06746831665551, .16029521585049, .28330230293537, .42556283050918, .01088567092697, .05646870011595, .13492399721298, .24045193539659}
	XMatrixData[28,36]={ .36522842202382, .00921968287664, .04794137181476,.11504866290285, .20634102285669, .31608425050091, .43738329574426, .00790847264071, .04120080038851}
	XMatrixData[37,45]={.09921095463335, .17882533027983, .27575362448178,.38477084202243, .00685809565159, .03578255816821,.08639934246512, .15635354759416, .24237568182092}
	XMatrixData[46,54]={.34044381553605, .44597252564632, .00600374098758,.031363303799647, .075896708294787, .13779113431991,.21451391369574, .30292432646121, .39940295300128}
	XMatrixData[55,62]={.00529953250417, .02771248846338, .06718439880608,.12229779582250, .19106187779868, .27099161117138,.35919822461038, .45249374508118}
//
	AMatrixData[0,9]={0,.17392742256873, .32607257743127, .11846344252810,.23931433524968, .28444444444444, .085662246189585,.18038078652407, .23395696728635, .06474248308443}
	AMatrixData[10,18]={ .13985269574464, .19091502525256, .20897959183674,.05061426814519, .11119051722669, .15685332293894,.18134189168918, .04063719418079, .09032408034743}
	AMatrixData[19,27]={ .13030534820147, .03333567215434, .15617353852000,.16511967750063, .07472567457529, .10954318125799,.13463335965500, .14776211235738, .02783428355809}
	AMatrixData[28,36]={ .06279018473245, .09314510546387, .11659688229599,.13140227225512, .13646254338895, .02358766819326,.05346966299766, .08003916427167, .10158371336153}
	AMatrixData[37,45]={ .11674626826918, .12457352290670, .02024200238266,.04606074991886, .06943675510989, .08907299038097,.10390802376845, .11314159013145, .11627577661544}
	AMatrixData[46,54]={.01755973016588, .04007904357988, .06075928534395,.07860158357910, .09276919873897, .10259923186065,.10763192673158, .01537662099806, .03518302374405}
	AMatrixData[55,63]={.05357961023359, .06978533896308, .08313460290850,.09308050000778, .09921574266356, .10128912096278,.01357622970588, .03112676196932, .04757925584125}
	AMatrixData[64,68]={  .06231448562777, .07479799440829, .08457825969750,.09130170752246, .09472530522754}

	variable kk, is, ih,ip,i4,ia,t
	
	kk=k
	if((m>16)||(m<4))
		kk=4
	endif
	is=0
	ih=trunc((m+1)/2)
	z=0.5
	if(mod(m,2)>0.3)
		is=-1
	endif
	ip=kk
	t=0
	if(ip>ih)
		ip=m+1-ip
		t=-1
	endif
	i4 = m -4
	ia = (i4*(m+4)+is)/4 + ip
	aa = AMatrixData[ia]
	if((ip==ih) && (is<0))
		return 1
	endif
	ia = ia - trunc((i4+is)/2)
	//z = -t + ((t<0)? -XMatrixData[ia] : XMatrixData[ia])
	if (t<0)
		z = -t -XMatrixData[ia]
	else
		z = -t +XMatrixData[ia]
	endif

end

//********************************************************************************************************************************
//********************************************************************************************************************************

static Function Cromer_Cgauss(y)
	variable y
	
	variable g, z, a, j
	g=0
	for(j=1;j<=5;j+=1)
		clgndr(5,j,a,z)
		g += a*(Cromer_Csigma(y,z))
	endfor
	return g
end
//********************************************************************************************************************************
//********************************************************************************************************************************


static Function Caknint(xbar,in,im,xMatrix, yMatrix, tMatrix)
		variable xbar, in, im
		wave xMatrix,yMatrix,tMatrix
	
	variable i,j,k,m,n,jj,kk, mend, s, z
	
	n=abs(in)
	m = im
	if(m>=n)
		print("aknint warning, order of interpolation too large")
		m = n -1
	endif	
	
	k = n -1
	if(n<2)
		print("aknint n<2, ybar returned as y[1]")
		return yMatrix[1]
	endif
	
	s= xMatrix[2] - xMatrix[1]
	if((in>=0) && (n!=2))
		for(i=3;i<=n;i+=1)
			z = (xMatrix[i] - xMatrix[i-1]) * s
			if(z<=0)
				print "aknint x(i) not sequenced properly"
				print "aknint n.lt.2 ybar returned as y[1]"
				return yMatrix[1]
			endif
		endfor
	endif
	
	if (s<0)
		for(j=1;j<=n;j+=1)
			if(xbar>=xMatrix[j])
				break
			endif	
		endfor
		if(xbar<xMatrix[j])
			j = n
		endif	
	else
		for(j=1;j<=n;j+=1)
			if(xbar<=xMatrix[j])
				break
			endif	
		endfor
		if (xbar>xMatrix[j])
			j = n
		endif	
	endif
	
	k = m
	m = m+1
	j = j -trunc(m/2)
	j = max(j,1)
	j = min(j,n-k)
	mend = j + k
	for(i=j;i<=mend;i+=1)
		kk= i - j +1
		tMatrix[kk] = yMatrix[i]
		tMatrix[kk+m] = xMatrix[i] - xbar
	endfor
	for(i=1;i<=k;i+=1)
		kk = i + 1
		for(jj=kk;jj<=m;jj+=1)
			tMatrix[jj] = (tMatrix[i]*tMatrix[jj+m]-tMatrix[jj]*tMatrix[i+m])/(xMatrix[jj+j-1] - xMatrix[i+j-1])
		endfor
	endfor
	return tMatrix[m]
end

//********************************************************************************************************************************
//********************************************************************************************************************************

static Function Csort_fp(n,aMatrix,bMatrix)
	variable n
	wave aMatrix, bMatrix

	variable m,i, i1,j, x, y
	m = n-1
	for(i=1;i<=m;i+=1)
		i1=i+1
		for(j=i1;j<=n;j+=1)
			if(aMatrix[j]<=aMatrix[i])
				x = aMatrix[j]
				y = aMatrix[i]
				aMatrix[i]  = x
				aMatrix[j] = y
				x = bMatrix[j]
				y = bMatrix[i]
				bMatrix[i] = x
				bMatrix[j] = y
			endif
		endfor
	endfor

end
//********************************************************************************************************************************
//********************************************************************************************************************************
//		initialization routines for this package
//********************************************************************************************************************************
static Function Initialize_f0()

	string OldDf=GetDataFolder(1)
	NewDataFolder/S/O root:Packages
	NewDataFolder/O/S root:Packages:CromerCalculations
	
	Wave/Z H_a
	if (WaveExists(H_a))
		return 0
	endif
	//********************************     H
	make/N=4/O H_a, H_b
	variable/g H_c
	H_a={0.39875, 0.31285, 0.2144,  0.07135}
	H_b={58.3331, 14.7175, 236.7147, 3.4848}
	H_c=0.00125
	//********************************
	//********************************     H-1
	make/N=4/O 'H-1_a', 'H-1_b'
	variable/g 'H-1_c'
	'H-1_a'={0.7975,  0.6257,  0.4288,  0.1427}
	'H-1_b'={58.3331, 14.7175, 236.7147, 3.4848}
	'H-1_c'=0.00125
	//********************************
	//	"H-1",  0.7975,  0.6257,  0.4288,  0.1427,  58.3331, 14.7175, 236.7147, 3.4848, 0.0025,
	//********************************     He
	make/N=4/O He_a, He_b
	variable/g He_c
	He_a={0.76844, 0.72694, 0.27631, 0.21572}
	He_b={10.9071, 4.30779, 1.33127, 25.6848}
	He_c=0.01249
	//********************************
	//	"HE",   0.76844, 0.72694, 0.27631, 0.21572, 10.9071, 4.30779, 1.33127, 25.6848, 0.01249,
	//********************************     Li
	make/N=4/O Li_a, Li_b
	variable/g Li_c
	Li_a={0.99279, 0.87402, 0.84240, 0.23131}
	Li_b={4.33979, 1.26006, 98.7088, 212.088}
	Li_c=0.05988
	//********************************
	//	"LI",   0.99279, 0.87402, 0.84240, 0.23131, 4.33979, 1.26006, 98.7088, 212.088, 0.05988,
	//********************************     Li+1
	make/N=4/O 'Li+1_a', 'Li+1_b'
	variable/g 'Li+1_c'
	'Li+1_a'={6.08475, 0.86773, 0.80588, 0.17720}
	'Li+1_b'={0.00498, 1.53730, 4.28524, 9.81413}
	'Li+1_c'=-5.93560
	//********************************
	//	"LI+1", 6.08475, 0.86773, 0.80588, 0.17720, 0.00498, 1.53730, 4.28524, 9.81413,-5.93560,
	//********************************     Be
	make/N=4/O Be_a, Be_b
	variable/g Be_c
	Be_a={2.22744, 1.55249, 1.40060, 0.58290}
	Be_b={0.04965, 42.9165, 1.66379, 100.361}
	Be_c=-1.76339
	//********************************
	//	"BE",   2.22744, 1.55249, 1.40060, 0.58290, 0.04965, 42.9165, 1.66379, 100.361,-1.76339,
	//********************************     Be+2
	make/N=4/O 'Be+2_a', 'Be+2_b'
	variable/g 'Be+2_c'
	'Be+2_a'={5.69034, 1.19706, 1.03057, 0.20150}
	'Be+2_b'={-0.01336, 0.39000, 1.97441, 4.90642}
	'Be+2_c'=-6.11950
	//********************************
	//	"BE+2", 5.69034, 1.19706, 1.03057, 0.20150,-0.01336, 0.39000, 1.97441, 4.90642,-6.11950,
	//********************************     B
	make/N=4/O B_a, B_b
	variable/g B_c
	B_a={2.03876, 1.41491, 1.11609, 0.73273}
	B_b={23.0888, 0.97848, 59.8985, 0.08538}
	B_c=-0.30409
	//********************************
	//	"B",    2.03876, 1.41491, 1.11609, 0.73273, 23.0888, 0.97848, 59.8985, 0.08538,-0.30409,
	//********************************     C
	make/N=4/O C_a, C_b
	variable/g C_c
	C_a={1.93019, 1.87812, 1.57415, 0.37108}
	C_b={12.7188, 28.6498, 0.59645, 65.0337}
	C_c=0.24637
	//********************************
	//	"C",    1.93019, 1.87812, 1.57415, 0.37108, 12.7188, 28.6498, 0.59645, 65.0337, 0.24637,
	//********************************     N
	make/N=4/O N_a, N_b
	variable/g N_c
	N_a={12.7913, 3.28546, 1.76483, 0.54709}
	N_b={0.02064, 10.7018, 30.7773, 1.48044}
	N_c=-11.3926
	//********************************
	//	"N",    12.7913, 3.28546, 1.76483, 0.54709, 0.02064, 10.7018, 30.7773, 1.48044,-11.3926,
	//********************************     O
	make/N=4/O O_a, O_b
	variable/g O_c
	O_a={2.95648, 2.45240, 1.50510, 0.78135}
	O_b={13.8964, 5.91765, 0.34537, 34.0811}
	O_c=0.30413
	//********************************
	//	"O",    2.95648, 2.45240, 1.50510, 0.78135, 13.8964, 5.91765, 0.34537, 34.0811, 0.30413,
	//********************************     O-1
	make/N=4/O 'O-1_a', 'O-1_b'
	variable/g 'O-1_c'
	'O-1_a'={3.22563, 3.01717, 1.42553, 0.90525}
	'O-1_b'={18.4991, 6.65680, 0.40589, 61.1889}
	'O-1_c'=0.42362
	//********************************
	//	"O-1",  3.22563, 3.01717, 1.42553, 0.90525, 18.4991, 6.65680, 0.40589, 61.1889, 0.42362,
	//********************************     F
	make/N=4/O F_a, F_b
	variable/g F_c
	F_a={3.30393, 3.01753, 1.35754, 0.83645}
	F_b={11.2651, 4.66504, 0.33760, 27.9898}
	F_c=0.48398
	//********************************
	//	"F",    3.30393, 3.01753, 1.35754, 0.83645, 11.2651, 4.66504, 0.33760, 27.9898, 0.48398,
	//********************************     F-1
	make/N=4/O 'F-1_a', 'F-1_b'
	variable/g 'F-1_c'
	'F-1_a'={3.63220, 3.51057, 1.26064, 0.94071}
	'F-1_b'={5.27756, 14.7353, 0.44226, 47.3437}
	'F-1_c'=0.65340
	//********************************
	//	"F-1",  3.63220, 3.51057, 1.26064, 0.94071, 5.27756, 14.7353, 0.44226, 47.3437, 0.65340,
	//********************************     Na
	make/N=4/O Na_a, Na_b
	variable/g Na_c
	Na_a={5.26400, 2.17549, 1.36690, 1.08859}
	Na_b={4.02579, 10.4796, 0.84222, 133.617}
	Na_c=1.09912
	//********************************
	//	"NA",   5.26400, 2.17549, 1.36690, 1.08859, 4.02579, 10.4796, 0.84222, 133.617, 1.09912,
	//********************************     Na+1
	make/N=4/O 'Na+1_a', 'Na+1_b'
	variable/g 'Na+1_c'
	'Na+1_a'={3.99479, 3.37245, 1.13877, 0.65118}
	'Na+1_b'={3.11047, 7.14318, 0.40692, 15.7319}
	'Na+1_c'=0.84267
	//********************************
	//	"NA+1", 3.99479, 3.37245, 1.13877, 0.65118, 3.11047, 7.14318, 0.40692, 15.7319, 0.84267,
	//********************************     Mg
	make/N=4/O Mg_a, Mg_b
	variable/g Mg_c
	Mg_a={5.59229, 2.68206, 1.72235, 0.73055}
	Mg_b={4.41142, 1.36549, 93.4885, 32.5281}
	Mg_c=1.26883
	//********************************
	//	"MG",   5.59229, 2.68206, 1.72235, 0.73055, 4.41142, 1.36549, 93.4885, 32.5281, 1.26883,
	//********************************     Mg+2
	make/N=4/O 'Mg+2_a', 'Mg+2_b'
	variable/g 'Mg+2_c'
	'Mg+2_a'={4.30491, 3.14719, 1.12859, 0.49034}
	'Mg+2_b'={2.55961, 5.60660, 0.41574, 11.4840}
	'Mg+2_c'=0.92893
	//********************************
	//	"MG+2", 4.30491, 3.14719, 1.12859, 0.49034, 2.55961, 5.60660, 0.41574, 11.4840, 0.92893,
	//********************************     Al
	make/N=4/O Al_a, Al_b
	variable/g Al_c
	Al_a={5.35047, 2.92451, 2.27309, 1.16531}
	Al_b={3.48665, 1.20535, 42.6051, 107.170}
	Al_c=1.28489
	//********************************
	//	"AL",   5.35047, 2.92451, 2.27309, 1.16531, 3.48665, 1.20535, 42.6051, 107.170, 1.28489,
	//********************************     Al+3
	make/N=4/O 'Al+3_a', 'Al+3_b'
	variable/g 'Al+3_c'
	'Al+3_a'={4.17448, 3.38760, 1.20296, 0.52814}
	'Al+3_b'={1.93816, 4.14553, 0.22875, 8.28524}
	'Al+3_c'=0.70679
	//********************************
	//	"AL+3", 4.17448, 3.38760, 1.20296, 0.52814, 1.93816, 4.14553, 0.22875, 8.28524, 0.70679,
	//********************************     Si
	make/N=4/O Si_a, Si_b
	variable/g Si_c
	Si_a={5.79411, 3.22390, 2.42795, 1.32149}
	Si_b={2.57104, 34.1775, 0.86937, 85.3410}
	Si_c=1.23139
	//********************************
	//	"SI",   5.79411, 3.22390, 2.42795, 1.32149, 2.57104, 34.1775, 0.86937, 85.3410, 1.23139,
	//********************************     Si+4
	make/N=4/O 'Si+4_a', 'Si+4_b'
	variable/g 'Si+4_c'
	'Si+4_a'={4.43918, 3.20345, 1.19453, 0.41653}
	'Si+4_b'={1.64167, 3.43757, 0.21490, 6.65365}
	'Si+4_c'=0.74630
	//********************************
	//	"SI+4", 4.43918, 3.20345, 1.19453, 0.41653, 1.64167, 3.43757, 0.21490, 6.65365, 0.74630,
	//********************************     P
	make/N=4/O P_a, P_b
	variable/g P_c
	P_a={6.92073, 4.14396, 2.01697, 1.53860}
	P_b={1.83778, 27.0198, 0.21318, 67.1086}
	P_c=0.37870
	//********************************
	//	"P",    6.92073, 4.14396, 2.01697, 1.53860, 1.83778, 27.0198, 0.21318, 67.1086, 0.37870,
	//********************************     S
	make/N=4/O S_a, S_b
	variable/g S_c
	S_a={7.18742, 5.88671, 5.15858, 1.64403}
	S_b={1.43280, 0.02865, 22.1101, 55.4651}
	S_c=-3.87732
	//********************************
	//	"S",    7.18742, 5.88671, 5.15858, 1.64403, 1.43280, 0.02865, 22.1101, 55.4651,-3.87732,
	//********************************     Cl
	make/N=4/O Cl_a, Cl_b
	variable/g Cl_c
	Cl_a={9.83957, 7.53181, 6.07100, 1.87128}
	Cl_b={-0.00053, 1.11119, 18.0846, 45.3666}
	Cl_c=-8.31430
	//********************************
	//	"CL",   9.83957, 7.53181, 6.07100, 1.87128,-0.00053, 1.11119, 18.0846, 45.3666,-8.31430,
	//********************************     Cl-1
	make/N=4/O 'Cl-1_a', 'Cl-1_b'
	variable/g 'Cl-1_c'
	'Cl-1_a'={18.0842, 7.47202, 6.46337, 2.43918}
	'Cl-1_b'={0.00129, 1.12976, 19.3079, 59.0633}
	'Cl-1_c'=-16.4654
	//********************************
	//	"CL-1", 18.0842, 7.47202, 6.46337, 2.43918, 0.00129, 1.12976, 19.3079, 59.0633,-16.4654,
	//********************************     Ar
	make/N=4/O Ar_a, Ar_b
	variable/g Ar_c
	Ar_a={16.8752, 8.32256, 6.91326, 2.18515}
	Ar_b={-0.01456, 0.83310, 14.9177, 37.2256}
	Ar_c=-16.2972
	//********************************
	//	"AR",   16.8752, 8.32256, 6.91326, 2.18515,-0.01456, 0.83310, 14.9177, 37.2256,-16.2972,
	//********************************     K
	make/N=4/O K_a, K_b
	variable/g K_c
	K_a={8.11756, 7.48062, 1.07795, 0.97218}
	K_b={12.6684, 0.76409, 211.222, 37.2727}
	K_c=1.35009
	//********************************
	//	"K",    8.11756, 7.48062, 1.07795, 0.97218, 12.6684, 0.76409, 211.222, 37.2727, 1.35009,
	//********************************     K+1
	make/N=4/O 'K+1_a', 'K+1_b'
	variable/g 'K+1_c'
	'K+1_a'={9.70659, 7.37245, 5.67228, 1.90668}
	'K+1_b'={0.59947, 11.8765,-0.08359, 26.7668}
	'K+1_c'=-6.65819
	//********************************
	//	"K+1",  9.70659, 7.37245, 5.67228, 1.90668, 0.59947, 11.8765,-0.08359, 26.7668,-6.65819,
	//********************************     Ca
	make/N=4/O Ca_a, Ca_b
	variable/g Ca_c
	Ca_a={8.60272, 7.50769, 1.75117, 0.96216}
	Ca_b={10.2636, 0.62794, 149.301, 60.2274}
	Ca_c=1.17430
	//********************************
	//	"CA",   8.60272, 7.50769, 1.75117, 0.96216, 10.2636, 0.62794, 149.301, 60.2274, 1.17430,
	//********************************     Ca+2
	make/N=4/O 'Ca+2_a', 'Ca+2_b'
	variable/g 'Ca+2_c'
	'Ca+2_a'={13.2063, 11.0586, 7.73221, 1.72057}
	'Ca+2_b'={0.39466,-0.08204, 9.62976, 20.3341}
	'Ca+2_c'=-15.7176
	//********************************
	//	"CA+2", 13.2063, 11.0586, 7.73221, 1.72057, 0.39466,-0.08204, 9.62976, 20.3341,-15.7176,
	//********************************     Sc
	make/N=4/O Sc_a, Sc_b
	variable/g Sc_c
	Sc_a={9.06482, 7.55526, 2.05017, 1.28745}
	Sc_b={8.77431, 0.53306, 123.880, 36.8890}
	Sc_c=1.03849
	//********************************
	//	"SC",   9.06482, 7.55526, 2.05017, 1.28745, 8.77431, 0.53306, 123.880, 36.8890, 1.03849,
	//********************************     Sc+3
	make/N=4/O 'Sc+3_a', 'Sc+3_b'
	variable/g 'Sc+3_c'
	'Sc+3_a'={13.4008, 8.02730, 1.65943, 1.57936}
	'Sc+3_b'={0.29854, 7.96290,-0.28604, 16.0662}
	'Sc+3_c'=-6.66668
	//********************************
	//	"SC+3", 13.4008, 8.02730, 1.65943, 1.57936, 0.29854, 7.96290,-0.28604, 16.0662,-6.66668,
	//********************************     Ti
	make/N=4/O Ti_a, Ti_b
	variable/g Ti_c
	Ti_a={9.54969, 7.60067, 2.17223, 1.75438}
	Ti_b={7.60579, 0.45899, 109.099, 27.5715}
	Ti_c=0.91762
	//********************************
	//	"TI",   9.54969, 7.60067, 2.17223, 1.75438, 7.60579, 0.45899, 109.099, 27.5715, 0.91762,
	//********************************     Ti+3
	make/N=4/O 'Ti+3_a', 'Ti+3_b'
	variable/g 'Ti+3_c'
	'Ti+3_a'={17.7344, 8.73816, 5.25691, 1.92134}
	'Ti+3_b'={0.22061, 7.04716,-0.15762, 15.9768}
	'Ti+3_c'=-14.6519
	//********************************
	//	"TI+3", 17.7344, 8.73816, 5.25691, 1.92134, 0.22061, 7.04716,-0.15762, 15.9768,-14.6519,
	//********************************     Ti+4
	make/N=4/O 'Ti+4_a', 'Ti+4_b'
	variable/g 'Ti+4_c'
	'Ti+4_a'={19.5114, 8.23473, 2.01341, 1.52080}
	'Ti+4_b'={0.17885, 6.67018,-0.29263, 12.9464}
	'Ti+4_c'=-13.2803
	//********************************
	//	"TI+4", 19.5114, 8.23473, 2.01341, 1.52080, 0.17885, 6.67018,-0.29263, 12.9464,-13.2803,
	//********************************     V
	make/N=4/O V_a, V_b
	variable/g V_c
	V_a={10.0661, 7.61420, 2.23551, 2.23170}
	V_b={6.67721, 0.40322, 98.5954, 22.5720}
	V_c=0.84574
	//********************************
	//	"V",    10.0661, 7.61420, 2.23551, 2.23170, 6.67721, 0.40322, 98.5954, 22.5720, 0.84574,
	//********************************     V+2
	make/N=4/O 'V+2_a', 'V+2_b'
	variable/g 'V+2_c'
	'V+2_a'={9.34513, 7.68833, 2.94531, 0.26998}
	'V+2_b'={6.49985, 0.39491, 15.9868, 41.0832}
	'V+2_c'=0.75143
	//********************************
	//	"V+2",  9.34513, 7.68833, 2.94531, 0.26998, 6.49985, 0.39491, 15.9868, 41.0832, 0.75143,
	//********************************     V+3
	make/N=4/O 'V+3_a', 'V+3_b'
	variable/g 'V+3_c'
	'V+3_a'={9.43141, 7.74190, 2.15343, 0.01686}
	'V+3_b'={6.39535, 0.38335, 15.1908, 63.9690}
	'V+3_c'=0.65657
	//********************************
	//	"V+3",  9.43141, 7.74190, 2.15343, 0.01686, 6.39535, 0.38335, 15.1908, 63.9690, 0.65657,
	//********************************     V+5
	make/N=4/O 'V+5_a', 'V+5_b'
	variable/g 'V+5_c'
	'V+5_a'={15.6887, 8.14208, 2.03081,-9.57602}
	'V+5_b'={0.67900, 5.40135, 9.97278, 0.94046}
	'V+5_c'=1.71430
	//********************************
	//	"V+5",  15.6887, 8.14208, 2.03081,-9.57602, 0.67900, 5.40135, 9.97278, 0.94046, 1.71430,
	//********************************     Cr
	make/N=4/O Cr_a, Cr_b
	variable/g Cr_c
	Cr_a={10.4757, 7.51402, 3.50115, 1.54902}
	Cr_b={6.01658, 0.37426, 19.0654, 97.4599}
	Cr_c=0.95226
	//********************************
	//	"CR",   10.4757, 7.51402, 3.50115, 1.54902, 6.01658, 0.37426, 19.0654, 97.4599, 0.95226,
	//********************************     Cr+2
	make/N=4/O 'Cr+2_a', 'Cr+2_b'
	variable/g 'Cr+2_c'
	'Cr+2_a'={9.54034, 7.75090, 3.58274, 0.50911}
	'Cr+2_b'={5.66078, 0.34426, 13.3075, 32.4224}
	'Cr+2_c'=0.61690
	//********************************
	//	"CR+2", 9.54034, 7.75090, 3.58274, 0.50911, 5.66078, 0.34426, 13.3075, 32.4224, 0.61690,
	//********************************     Cr+3
	make/N=4/O 'Cr+3_a', 'Cr+3_b'
	variable/g 'Cr+3_c'
	'Cr+3_a'={9.68090, 7.81136, 2.87603, 0.11357}
	'Cr+3_b'={5.59463, 0.33439, 12.8288, 32.8761}
	'Cr+3_c'=0.51827
	//********************************
	//	"CR+3", 9.68090, 7.81136, 2.87603, 0.11357, 5.59463, 0.33439, 12.8288, 32.8761, 0.51827,
	//********************************     Mn
	make/N=4/O Mn_a, Mn_b
	variable/g Mn_c
	Mn_a={11.2519, 7.36935, 3.04107, 2.27703}
	Mn_b={5.34818, 0.34373, 17.4089, 84.2139}
	Mn_c=1.05195
	//********************************
	//	"MN",   11.2519, 7.36935, 3.04107, 2.27703, 5.34818, 0.34373, 17.4089, 84.2139, 1.05195,
	//********************************     Mn+2
	make/N=4/O 'Mn+2_a', 'Mn+2_b'
	variable/g 'Mn+2_c'
	'Mn+2_a'={9.78094, 7.79153, 4.18544, 0.72736}
	'Mn+2_b'={4.98303, 0.30421, 11.4399, 27.7750}
	'Mn+2_c'=0.51454
	//********************************
	//	"MN+2", 9.78094, 7.79153, 4.18544, 0.72736, 4.98303, 0.30421, 11.4399, 27.7750, 0.51454,
	//********************************     Mn+3
	make/N=4/O 'Mn+3_a', 'Mn+3_b'
	variable/g 'Mn+3_c'
	'Mn+3_a'={9.84521, 7.87194, 3.56531, 0.32361}
	'Mn+3_b'={4.91797, 0.29439, 10.8171, 24.1281}
	'Mn+3_c'=0.39397
	//********************************
	//	"MN+3", 9.84521, 7.87194, 3.56531, 0.32361, 4.91797, 0.29439, 10.8171, 24.1281, 0.39397,
	//********************************     Mn+4
	make/N=4/O 'Mn+4_a', 'Mn+4_b'
	variable/g 'Mn+4_c'
	'Mn+4_a'={9.96253, 7.97057, 2.76067, 0.05445}
	'Mn+4_b'={4.84850, 0.28330, 10.4852, 27.5730}
	'Mn+4_c'=0.25188
	//********************************
	//	"MN+4", 9.96253, 7.97057, 2.76067, 0.05445, 4.84850, 0.28330, 10.4852, 27.5730, 0.25188,
	//********************************     Fe
	make/N=4/O Fe_a, Fe_b
	variable/g Fe_c
	Fe_a={11.9185, 7.04848, 3.34326, 2.27228}
	Fe_b={4.87394, 0.34023, 15.9330, 79.0339}
	Fe_c=1.40818
	//********************************
	//	"FE",   11.9185, 7.04848, 3.34326, 2.27228, 4.87394, 0.34023, 15.9330, 79.0339, 1.40818,
	//********************************     Fe+2
	make/N=4/O 'Fe+2_a', 'Fe+2_b'
	variable/g 'Fe+2_c'
	'Fe+2_a'={10.1270, 7.78007, 4.71825, 0.89547}
	'Fe+2_b'={4.44133, 0.27418, 10.1451, 24.8302}
	'Fe+2_c'=0.47888
	//********************************
	//	"FE+2", 10.1270, 7.78007, 4.71825, 0.89547, 4.44133, 0.27418, 10.1451, 24.8302, 0.47888,
	//********************************     Fe+3
	make/N=4/O 'Fe+3_a', 'Fe+3_b'
	variable/g 'Fe+3_c'
	'Fe+3_a'={10.0333, 7.90625, 4.20562, 0.55048}
	'Fe+3_b'={4.36007, 0.26250, 9.35847, 20.4105}
	'Fe+3_c'=0.30429
	//********************************
	//	"FE+3", 10.0333, 7.90625, 4.20562, 0.55048, 4.36007, 0.26250, 9.35847, 20.4105, 0.30429,
	//********************************     Co
	make/N=4/O Co_a, Co_b
	variable/g Co_c
	Co_a={12.6158, 6.62642, 3.57722, 2.25644}
	Co_b={4.48994, 0.35459, 14.8402, 74.7352}
	Co_c=1.91452
	//********************************
	//	"CO",   12.6158, 6.62642, 3.57722, 2.25644, 4.48994, 0.35459, 14.8402, 74.7352, 1.91452,
	//********************************     Co+2
	make/N=4/O 'Co+2_a', 'Co+2_b'
	variable/g 'Co+2_c'
	'Co+2_a'={10.5942, 7.67791, 5.15947, 1.01440}
	'Co+2_b'={4.00858, 0.25410, 9.21931, 22.7516}
	'Co+2_c'=0.55358
	//********************************
	//	"CO+2", 10.5942, 7.67791, 5.15947, 1.01440, 4.00858, 0.25410, 9.21931, 22.7516, 0.55358,
	//********************************     Co+3
	make/N=4/O 'Co+3_a', 'Co+3_b'
	variable/g 'Co+3_c'
	'Co+3_a'={10.3380, 7.88173, 4.76795, 0.72559}
	'Co+3_b'={3.90969, 0.23867, 8.35583, 18.3491}
	'Co+3_c'=0.28667
	//********************************
	//	"CO+3", 10.3380, 7.88173, 4.76795, 0.72559, 3.90969, 0.23867, 8.35583, 18.3491, 0.28667,
	//********************************     Ni
	make/N=4/O Ni_a, Ni_b
	variable/g Ni_c
	Ni_a={13.3239, 6.18746, 3.74792, 2.23195}
	Ni_b={4.17742, 0.38682, 14.0123, 71.1195}
	Ni_c=2.49899
	//********************************
	//	"NI",   13.3239, 6.18746, 3.74792, 2.23195, 4.17742, 0.38682, 14.0123, 71.1195, 2.49899,
	//********************************     Ni+2
	make/N=4/O 'Ni+2_a', 'Ni+2_b'
	variable/g 'Ni+2_c'
	'Ni+2_a'={11.1650, 7.45636, 5.51106, 1.09496}
	'Ni+2_b'={3.65944, 0.24397, 8.52556, 21.1647}
	'Ni+2_c'=0.77218
	//********************************
	//	"NI+2", 11.1650, 7.45636, 5.51106, 1.09496, 3.65944, 0.24397, 8.52556, 21.1647, 0.77218,
	//********************************     Ni+3
	make/N=4/O 'Ni+3_a', 'Ni+3_b'
	variable/g 'Ni+3_c'
	'Ni+3_a'={10.7806, 7.75868, 5.22746, 0.84711}
	'Ni+3_b'={3.54770, 0.22314, 7.64468, 16.9673}
	'Ni+3_c'=0.38604
	//********************************
	//	"NI+3", 10.7806, 7.75868, 5.22746, 0.84711, 3.54770, 0.22314, 7.64468, 16.9673, 0.38604,
	//********************************     Cu
	make/N=4/O Cu_a, Cu_b
	variable/g Cu_c
	Cu_a={13.9352, 5.84833, 4.64221, 1.44753}
	Cu_b={3.97779, 0.44555, 13.3971, 74.1605}
	Cu_c=3.11686
	//********************************
	//	"CU",   13.9352, 5.84833, 4.64221, 1.44753, 3.97779, 0.44555, 13.3971, 74.1605, 3.11686,
	//********************************     Cu+1
	make/N=4/O 'Cu+1_a', 'Cu+1_b'
	variable/g 'Cu+1_c'
	'Cu+1_a'={12.4655, 6.63111, 5.76679, 1.34230}
	'Cu+1_b'={3.54270, 0.28920, 9.31140, 26.9799}
	'Cu+1_c'=1.79285
	//********************************
	//	"CU+1", 12.4655, 6.63111, 5.76679, 1.34230, 3.54270, 0.28920, 9.31140, 26.9799, 1.79285,
	//********************************     Cu+2
	make/N=4/O 'Cu+2_a', 'Cu+2_b'
	variable/g 'Cu+2_c'
	'Cu+2_a'={11.8168, 7.11181, 5.78135, 1.14523}
	'Cu+2_b'={3.37484, 0.24408, 7.98760, 19.8970}
	'Cu+2_c'=1.14431
	//********************************
	//	"CU+2", 11.8168, 7.11181, 5.78135, 1.14523, 3.37484, 0.24408, 7.98760, 19.8970, 1.14431,
	//********************************     Zn
	make/N=4/O Zn_a, Zn_b
	variable/g Zn_c
	Zn_a={14.6744, 5.62816, 3.92540, 2.16398}
	Zn_b={3.71486, 0.50033, 12.8862, 65.4071}
	Zn_c=3.59838
	//********************************
	//	"ZN",   14.6744, 5.62816, 3.92540, 2.16398, 3.71486, 0.50033, 12.8862, 65.4071, 3.59838,
	//********************************     Zn+2
	make/N=4/O 'Zn+2_a', 'Zn+2_b'
	variable/g 'Zn+2_c'
	'Zn+2_a'={12.5225, 6.68507, 5.98382, 1.17317}
	'Zn+2_b'={3.13961, 0.25431, 7.55544, 18.8543}
	'Zn+2_c'=1.63497
	//********************************
	//	"ZN+2", 12.5225, 6.68507, 5.98382, 1.17317, 3.13961, 0.25431, 7.55544, 18.8543, 1.63497,
	//********************************     Ga
	make/N=4/O Ga_a, Ga_b
	variable/g Ga_c
	Ga_a={15.3412, 5.74150, 3.10733, 2.52764}
	Ga_b={3.63868, 0.65640, 16.0719, 70.7609}
	Ga_c=4.26842
	//********************************
	//	"GA",   15.3412, 5.74150, 3.10733, 2.52764, 3.63868, 0.65640, 16.0719, 70.7609, 4.26842,
	//********************************     Ga+3
	make/N=4/O 'Ga+3_a', 'Ga+3_b'
	variable/g 'Ga+3_c'
	'Ga+3_a'={12.6920, 6.69883, 6.06692, 1.00660}
	'Ga+3_b'={2.80262, 0.22789, 6.36441, 14.4122}
	'Ga+3_c'=1.53545
	//********************************
	//	"GA+3", 12.6920, 6.69883, 6.06692, 1.00660, 2.80262, 0.22789, 6.36441, 14.4122, 1.53545,
	//********************************     Ge
	make/N=4/O Ge_a, Ge_b
	variable/g Ge_c
	Ge_a={15.4378, 6.00432, 3.05158, 2.93572}
	Ge_b={3.39715, 0.73097, 18.9533, 63.7969}
	Ge_c=4.56068
	//********************************
	//	"GE",   15.4378, 6.00432, 3.05158, 2.93572, 3.39715, 0.73097, 18.9533, 63.7969, 4.56068,
	//********************************     As
	make/N=4/O As_a, As_b
	variable/g As_c
	As_a={15.4043, 6.13723, 3.74679, 3.01390}
	As_b={3.07517, 0.74113, 21.0014, 57.7446}
	As_c=4.69149
	//********************************
	//	"AS",   15.4043, 6.13723, 3.74679, 3.01390, 3.07517, 0.74113, 21.0014, 57.7446, 4.69149,
	//********************************     Se
	make/N=4/O Se_a, Se_b
	variable/g Se_c
	Se_a={15.5372, 5.98288, 4.83996, 2.93549}
	Se_b={2.71530, 0.68962, 21.0079, 52.4308}
	Se_c=4.70026
	//********************************
	//	"SE",   15.5372, 5.98288, 4.83996, 2.93549, 2.71530, 0.68962, 21.0079, 52.4308, 4.70026,
	//********************************     Br
	make/N=4/O Br_a, Br_b
	variable/g Br_c
	Br_a={15.9934, 6.02439, 5.51599, 2.88716}
	Br_b={2.35651, 19.7393, 0.58143, 47.3323}
	Br_c=4.57602
	//********************************
	//	"BR",   15.9934, 6.02439, 5.51599, 2.88716, 2.35651, 19.7393, 0.58143, 47.3323, 4.57602,
	//********************************     Br-1
	make/N=4/O 'Br-1_a', 'Br-1_b'
	variable/g 'Br-1_c'
	'Br-1_a'={15.4080, 6.78083, 6.00715, 2.99332}
	'Br-1_b'={2.43532, 22.0832, 0.68621, 64.9193}
	'Br-1_c'=4.80234
	//********************************
	//	"BR-1", 15.4080, 6.78083, 6.00715, 2.99332, 2.43532, 22.0832, 0.68621, 64.9193, 4.80234,
	//********************************     Kr
	make/N=4/O Kr_a, Kr_b
	variable/g Kr_c
	Kr_a={16.8494, 7.19790, 4.92564, 2.91606}
	Kr_b={2.01856, 18.0409, 0.39741, 42.5054}
	Kr_c=4.10864
	//********************************
	//	"KR",   16.8494, 7.19790, 4.92564, 2.91606, 2.01856, 18.0409, 0.39741, 42.5054, 4.10864,
	//********************************     Rb
	make/N=4/O Rb_a, Rb_b
	variable/g Rb_c
	Rb_a={11.4809, 9.46904, 9.16981, 1.42608}
	Rb_b={1.08140, 18.2800, 2.38825, 185.293}
	Rb_c=5.43921
	//********************************
	//	"RB",   11.4809, 9.46904, 9.16981, 1.42608, 1.08140, 18.2800, 2.38825, 185.293, 5.43921,
	//********************************     Rb+1
	make/N=4/O 'Rb+1_a', 'Rb+1_b'
	variable/g 'Rb+1_c'
	'Rb+1_a'={17.8943, 8.59341, 7.91428, 2.47499}
	'Rb+1_b'={1.71750, 0.09258, 15.4484, 32.5110}
	'Rb+1_c'=-.087756
	//********************************
	//	"RB+1", 17.8943, 8.59341, 7.91428, 2.47499, 1.71750, 0.09258, 15.4484, 32.5110,-.087756,
	//********************************     Sr
	make/N=4/O Sr_a, Sr_b
	variable/g Sr_c
	Sr_a={11.6164, 9.73009, 8.68081, 2.60986}
	Sr_b={1.85574, 14.6109, 0.89852, 139.830}
	Sr_c=5.34841
	//********************************
	//	"SR",   11.6164, 9.73009, 8.68081, 2.60986, 1.85574, 14.6109, 0.89852, 139.830, 5.34841,
	//********************************     Sr+2
	make/N=4/O 'Sr+2_a', 'Sr+2_b'
	variable/g 'Sr+2_c'
	'Sr+2_a'={18.2430, 8.90811, 1.69192,-32.1118}
	'Sr+2_b'={1.51215, 13.6536, 27.8238,-0.01488}
	'Sr+2_c'=39.2691
	//********************************
	//	"SR+2", 18.2430, 8.90811, 1.69192,-32.1118, 1.51215, 13.6536, 27.8238,-0.01488, 39.2691,
	//********************************     Y
	make/N=4/O Y_a, Y_b
	variable/g Y_c
	Y_a={19.0567, 6.50783, 4.81524, 2.84786}
	Y_b={1.24615, 9.68019, 18.8903, 121.353}
	Y_c=5.76121
	//********************************
	//	"Y",    19.0567, 6.50783, 4.81524, 2.84786, 1.24615, 9.68019, 18.8903, 121.353, 5.76121,
	//********************************     Y+3
	make/N=4/O 'Y+3_a', 'Y+3_b'
	variable/g 'Y+3_c'
	'Y+3_a'={18.4207, 9.75213, 1.05270,-33.4755}
	'Y+3_b'={1.34457, 12.0631, 25.1684,-0.01023}
	'Y+3_c'=40.2513
	//********************************
	//	"Y+3",  18.4207, 9.75213, 1.05270,-33.4755, 1.34457, 12.0631, 25.1684,-0.01023, 40.2513,
	//********************************     Zr
	make/N=4/O Zr_a, Zr_b
	variable/g Zr_c
	Zr_a={19.2273, 10.1378, 2.48177, 2.42892}
	Zr_b={1.15488, 10.7877, 120.126, 33.3722}
	Zr_c=5.71886
	//********************************
	//	"ZR",   19.2273, 10.1378, 2.48177, 2.42892, 1.15488, 10.7877, 120.126, 33.3722, 5.71886,
	//********************************     Zr+4
	make/N=4/O 'Zr+4_a', 'Zr+4_b'
	variable/g 'Zr+4_c'
	'Zr+4_a'={19.1301, 10.1098, 0.98896,-0.00004}
	'Zr+4_b'={1.16051, 10.4084, 20.7214,-3.20442}
	'Zr+4_c'=5.77164
	//********************************
	//	"ZR+4", 19.1301, 10.1098, 0.98896,-0.00004, 1.16051, 10.4084, 20.7214,-3.20442, 5.77164,
	//********************************     Nb
	make/N=4/O Nb_a, Nb_b
	variable/g Nb_c
	Nb_a={19.3496, 10.8737, 3.47687, 1.64516}
	Nb_b={1.06626, 10.5977, 32.6174, 120.397}
	Nb_c=5.65073
	//********************************
	//	"NB",   19.3496, 10.8737, 3.47687, 1.64516, 1.06626, 10.5977, 32.6174, 120.397, 5.65073,
	//********************************     Nb+3
	make/N=4/O 'Nb+3_a', 'Nb+3_b'
	variable/g 'Nb+3_c'
	'Nb+3_a'={19.1248, 18.2989, 11.0121, 2.04325}
	'Nb+3_b'={1.07235, 0.00315, 10.3385, 25.9292}
	'Nb+3_c'=-12.4799
	//********************************
	//	"NB+3", 19.1248, 18.2989, 11.0121, 2.04325, 1.07235, 0.00315, 10.3385, 25.9292,-12.4799,
	//********************************     Nb+5
	make/N=4/O 'Nb+5_a', 'Nb+5_b'
	variable/g 'Nb+5_c'
	'Nb+5_a'={19.0175, 10.7591, 1.09900, 0.48469}
	'Nb+5_b'={1.06028, 9.36239, 0.03765, 20.9764}
	'Nb+5_c'=4.64045
	//********************************
	//	"NB+5", 19.0175, 10.7591, 1.09900, 0.48469, 1.06028, 9.36239, 0.03765, 20.9764, 4.64045,
	//********************************     Mo
	make/N=4/O Mo_a, Mo_b
	variable/g Mo_c
	Mo_a={19.3885, 11.8308, 3.75919, 1.46772}
	Mo_b={0.97877, 10.0885, 31.9738, 117.932}
	Mo_c=5.55047
	//********************************
	//	"MO",   19.3885, 11.8308, 3.75919, 1.46772, 0.97877, 10.0885, 31.9738, 117.932, 5.55047,
	//********************************     Mo+3
	make/N=4/O 'Mo+3_a', 'Mo+3_b'
	variable/g 'Mo+3_c'
	'Mo+3_a'={19.6761, 18.0893, 11.7086, 2.50624}
	'Mo+3_b'={0.95118,-0.00669, 9.61097, 24.0356}
	'Mo+3_c'=-12.9813
	//********************************
	//	"MO+3", 19.6761, 18.0893, 11.7086, 2.50624, 0.95118,-0.00669, 9.61097, 24.0356,-12.9813,
	//********************************     Mo+5
	make/N=4/O 'Mo+5_a', 'Mo+5_b'
	variable/g 'Mo+5_c'
	'Mo+5_a'={19.6054, 17.9292, 11.3451, 1.04247}
	'Mo+5_b'={0.94029,-0.00795, 8.76715, 19.3690}
	'Mo+5_c'=-12.9217
	//********************************
	//	"MO+5", 19.6054, 17.9292, 11.3451, 1.04247, 0.94029,-0.00795, 8.76715, 19.3690,-12.9217,
	//********************************     Mo+6
	make/N=4/O 'Mo+6_a', 'Mo+6_b'
	variable/g 'Mo+6_c'
	'Mo+6_a'={19.4800, 17.6328, 11.0940, 0.37154}
	'Mo+6_b'={0.94043,-0.00723, 8.29745, 18.9700}
	'Mo+6_c'=-12.5778
	//********************************
	//	"MO+6", 19.4800, 17.6328, 11.0940, 0.37154, 0.94043,-0.00723, 8.29745, 18.9700,-12.5778,
	//********************************     Tc
	make/N=4/O Tc_a, Tc_b
	variable/g Tc_c
	Tc_a={19.3597, 12.8087, 3.41372, 1.99926}
	Tc_b={0.89356, 9.27497, 32.3513, 107.406}
	Tc_c=5.41556
	//********************************
	//	"TC",   19.3597, 12.8087, 3.41372, 1.99926, 0.89356, 9.27497, 32.3513, 107.406, 5.41556,
	//********************************     Ru
	make/N=4/O Ru_a, Ru_b
	variable/g Ru_c
	Ru_a={19.4316, 13.7309, 4.26537, 1.28720}
	Ru_b={0.82092, 8.97737, 28.2621, 111.501}
	Ru_c=5.28192
	//********************************
	//	"RU",   19.4316, 13.7309, 4.26537, 1.28720, 0.82092, 8.97737, 28.2621, 111.501, 5.28192,
	//********************************     Ru+3
	make/N=4/O 'Ru+3_a', 'Ru+3_b'
	variable/g 'Ru+3_c'
	'Ru+3_a'={20.8024, 13.2995, 3.27542, 2.21026}
	'Ru+3_b'={0.74711, 8.36626, 20.6179,-0.14664}
	'Ru+3_c'=1.41087
	//********************************
	//	"RU+3", 20.8024, 13.2995, 3.27542, 2.21026, 0.74711, 8.36626, 20.6179,-0.14664, 1.41087,
	//********************************     Ru+4
	make/N=4/O 'Ru+4_a', 'Ru+4_b'
	variable/g 'Ru+4_c'
	'Ru+4_a'={41.5821, 12.9936, 2.71276,-24.2593}
	'Ru+4_b'={0.61466, 7.99801, 18.1564, 0.43857}
	'Ru+4_c'=6.97025
	//********************************
	//	"RU+4", 41.5821, 12.9936, 2.71276,-24.2593, 0.61466, 7.99801, 18.1564, 0.43857, 6.97025,
	//********************************     Rh
	make/N=4/O Rh_a, Rh_b
	variable/g Rh_c
	Rh_a={19.4524, 14.6845, 4.50240, 1.24740}
	Rh_b={0.75019, 8.42622, 26.1564, 107.780}
	Rh_c=5.11007
	//********************************
	//	"RH",   19.4524, 14.6845, 4.50240, 1.24740, 0.75019, 8.42622, 26.1564, 107.780, 5.11007,
	//********************************     Rh+3
	make/N=4/O 'Rh+3_a', 'Rh+3_b'
	variable/g 'Rh+3_c'
	'Rh+3_a'={25.0958, 14.1510, 3.64428,-12.5768}
	'Rh+3_b'={0.61346, 7.80244, 19.0932, 0.13532}
	'Rh+3_c'=11.6838
	//********************************
	//	"RH+3", 25.0958, 14.1510, 3.64428,-12.5768, 0.61346, 7.80244, 19.0932, 0.13532, 11.6838,
	//********************************     Rh+4
	make/N=4/O 'Rh+4_a', 'Rh+4_b'
	variable/g 'Rh+4_c'
	'Rh+4_a'={41.5236, 13.8272, 3.07969,-25.9694}
	'Rh+4_b'={0.52905, 7.49419, 16.9498, 0.32686}
	'Rh+4_c'=8.53824
	//********************************
	//	"RH+4", 41.5236, 13.8272, 3.07969,-25.9694, 0.52905, 7.49419, 16.9498, 0.32686, 8.53824,
	//********************************     Pd
	make/N=4/O Pd_a, Pd_b
	variable/g Pd_c
	Pd_a={19.5123, 15.3800, 5.38330, 0.81015}
	Pd_b={0.68583, 7.95714, 23.1808, 65.9295}
	Pd_c=4.91427
	//********************************
	//	"PD",   19.5123, 15.3800, 5.38330, 0.81015, 0.68583, 7.95714, 23.1808, 65.9295, 4.91427,
	//********************************     Pd+2
	make/N=4/O 'Pd+2_a', 'Pd+2_b'
	variable/g 'Pd+2_c'
	'Pd+2_a'={19.4652, 15.5805, 4.04748, 0.02216}
	'Pd+2_b'={0.68159, 7.80880, 20.9573, 110.020}
	'Pd+2_c'=4.88510
	//********************************
	//	"PD+2", 19.4652, 15.5805, 4.04748, 0.02216, 0.68159, 7.80880, 20.9573, 110.020, 4.88510,
	//********************************     Pd+4
	make/N=4/O 'Pd+4_a', 'Pd+4_b'
	variable/g 'Pd+4_c'
	'Pd+4_a'={51.1288, 14.6979, 3.41607,-38.2678}
	'Pd+4_b'={0.43734, 7.03139, 15.8623, 0.26589}
	'Pd+4_c'=11.0241
	//********************************
	//	"PD+4", 51.1288, 14.6979, 3.41607,-38.2678, 0.43734, 7.03139, 15.8623, 0.26589, 11.0241,
	//********************************     Ag
	make/N=4/O Ag_a, Ag_b
	variable/g Ag_c
	Ag_a={19.5284, 16.5811, 4.99150, 1.21404}
	Ag_b={0.62387, 7.39504, 22.2282, 100.226}
	Ag_c=4.68114
	//********************************
	//	"AG",   19.5284, 16.5811, 4.99150, 1.21404, 0.62387, 7.39504, 22.2282, 100.226, 4.68114,
	//********************************     Ag+1
	make/N=4/O 'Ag+1_a', 'Ag+1_b'
	variable/g 'Ag+1_c'
	'Ag+1_a'={19.5416, 16.4239, 5.12995, 0.24053}
	'Ag+1_b'={0.62273, 7.39663, 20.5530, 59.0604}
	'Ag+1_c'=4.66470
	//********************************
	//	"AG+1", 19.5416, 16.4239, 5.12995, 0.24053, 0.62273, 7.39663, 20.5530, 59.0604, 4.66470,
	//********************************     Ag+2
	make/N=4/O 'Ag+2_a', 'Ag+2_b'
	variable/g 'Ag+2_c'
	'Ag+2_a'={19.5152, 16.4852, 4.32525, 0.02777}
	'Ag+2_b'={0.62050, 73.0347, 19.3673, 92.9184}
	'Ag+2_c'=4.64695
	//********************************
	//	"AG+2", 19.5152, 16.4852, 4.32525, 0.02777, 0.62050, 73.0347, 19.3673, 92.9184, 4.64695,
	//********************************     Cd
	make/N=4/O Cd_a, Cd_b
	variable/g Cd_c
	Cd_a={19.5528, 17.5717, 4.47374, 1.98562}
	Cd_b={0.56604, 6.79630, 21.2907, 85.2777}
	Cd_c=4.41158
	//********************************
	//	"CD",   19.5528, 17.5717, 4.47374, 1.98562, 0.56604, 6.79630, 21.2907, 85.2777, 4.41158,
	//********************************     Cd+2
	make/N=4/O 'Cd+2_a', 'Cd+2_b'
	variable/g 'Cd+2_c'
	'Cd+2_a'={19.5901, 17.3740, 4.62594, 0.03770}
	'Cd+2_b'={0.56389, 6.83082, 17.8856, 76.2909}
	'Cd+2_c'=4.37269
	//********************************
	//	"CD+2", 19.5901, 17.3740, 4.62594, 0.03770, 0.56389, 6.83082, 17.8856, 76.2909, 4.37269,
	//********************************     In
	make/N=4/O In_a, In_b
	variable/g In_c
	In_a={19.5872, 18.7169, 4.02722, 2.51452}
	In_b={0.51510, 6.29430, 22.7308, 88.5675}
	In_c=4.14542
	//********************************
	//	"IN",   19.5872, 18.7169, 4.02722, 2.51452, 0.51510, 6.29430, 22.7308, 88.5675, 4.14542,
	//********************************     In+3
	make/N=4/O 'In+3_a', 'In+3_b'
	variable/g 'In+3_c'
	'In+3_a'={19.6698, 18.1942, 4.09851, 0.00365}
	'In+3_b'={0.50926, 6.28098, 15.4189, 160.227}
	'In+3_c'=4.03396
	//********************************
	//	"IN+3", 19.6698, 18.1942, 4.09851, 0.00365, 0.50926, 6.28098, 15.4189, 160.227, 4.03396,
	//********************************     Sn
	make/N=4/O Sn_a, Sn_b
	variable/g Sn_c
	Sn_a={19.6527, 19.5108, 3.86895, 3.14764}
	Sn_b={0.46604, 5.76321, 24.0627, 78.1533}
	Sn_c=3.81227
	//********************************
	//	"SN",   19.6527, 19.5108, 3.86895, 3.14764, 0.46604, 5.76321, 24.0627, 78.1533, 3.81227,
	//********************************     Sn+2
	make/N=4/O 'Sn+2_a', 'Sn+2_b'
	variable/g 'Sn+2_c'
	'Sn+2_a'={19.7166, 18.9265, 3.79775, 1.86248}
	'Sn+2_b'={0.46027, 5.66448, 17.7248, 42.8086}
	'Sn+2_c'=3.69648
	//********************************
	//	"SN+2", 19.7166, 18.9265, 3.79775, 1.86248, 0.46027, 5.66448, 17.7248, 42.8086, 3.69648,
	//********************************     Sn+4
	make/N=4/O 'Sn+4_a', 'Sn+4_b'
	variable/g 'Sn+4_c'
	'Sn+4_a'={19.7914, 18.9162, 3.64761, 0.00000}
	'Sn+4_b'={0.45879, 5.76682, 13.3733, 0.00000}
	'Sn+4_c'=3.64494
	//********************************
	//	"SN+4", 19.7914, 18.9162, 3.64761, 0.00000, 0.45879, 5.76682, 13.3733, 0.00000, 3.64494,
	//********************************     Sb
	make/N=4/O Sb_a, Sb_b
	variable/g Sb_c
	Sb_a={20.0755, 19.7766, 4.30389, 3.44952}
	Sb_b={5.24328, 0.41858, 26.0178, 70.1646}
	Sb_c=3.38881
	//********************************
	//	"SB",   20.0755, 19.7766, 4.30389, 3.44952, 5.24328, 0.41858, 26.0178, 70.1646, 3.38881,
	//********************************     Sb+3
	make/N=4/O 'Sb+3_a', 'Sb+3_b'
	variable/g 'Sb+3_c'
	'Sb+3_a'={19.8617, 19.5199, 3.73465, 1.61027}
	'Sb+3_b'={0.41409, 5.18292, 16.8529, 35.1406}
	'Sb+3_c'=3.27356
	//********************************
	//	"SB+3", 19.8617, 19.5199, 3.73465, 1.61027, 0.41409, 5.18292, 16.8529, 35.1406, 3.27356,
	//********************************     Sb+5
	make/N=4/O 'Sb+5_a', 'Sb+5_b'
	variable/g 'Sb+5_c'
	'Sb+5_a'={19.9613, 19.5889, 3.24333, 0.00000}
	'Sb+5_b'={0.41262, 5.30028, 11.7603, 0.00000}
	'Sb+5_c'=3.20701
	//********************************
	//	"SB+5", 19.9613, 19.5889, 3.24333, 0.00000, 0.41262, 5.30028, 11.7603, 0.00000, 3.20701,
	//********************************     Te
	make/N=4/O Te_a, Te_b
	variable/g Te_c
	Te_a={20.4608, 20.0336, 5.38664, 3.33079}
	Te_b={4.74225, 0.37041, 27.3458, 65.0573}
	Te_c=2.78462
	//********************************
	//	"TE",   20.4608, 20.0336, 5.38664, 3.33079, 4.74225, 0.37041, 27.3458, 65.0573, 2.78462,
	//********************************     I
	make/N=4/O I_a, I_b
	variable/g I_c
	I_a={20.7492, 20.5640, 6.86158, 2.97589}
	I_b={4.27091, 0.31960, 27.3186, 61.5375}
	I_c=1.84739
	//********************************
	//	"I",    20.7492, 20.5640, 6.86158, 2.97589, 4.27091, 0.31960, 27.3186, 61.5375, 1.84739,
	//********************************     I-1
	make/N=4/O 'I-1_a', 'I-1_b'
	variable/g 'I-1_c'
	'I-1_a'={20.8307, 20.4454, 7.52618, 3.18616}
	'I-1_b'={4.29514, 0.32402, 29.8990, 81.4344}
	'I-1_c'=2.00513
	//********************************
	//	"I-1",  20.8307, 20.4454, 7.52618, 3.18616, 4.29514, 0.32402, 29.8990, 81.4344, 2.00513,
	//********************************     Xe
	make/N=4/O Xe_a, Xe_b
	variable/g Xe_c
	Xe_a={21.6679, 21.0085, 8.43382, 2.62265}
	Xe_b={0.26422, 3.83526, 26.2297, 58.4830}
	Xe_c=0.26635
	//********************************
	//	"XE",   21.6679, 21.0085, 8.43382, 2.62265, 0.26422, 3.83526, 26.2297, 58.4830, 0.26635,
	//********************************     Cs
	make/N=4/O Cs_a, Cs_b
	variable/g Cs_c
	Cs_a={22.3163, 21.1792, 10.7382, 1.46163}
	Cs_b={0.23092, 3.49464, 25.1864, 232.829}
	Cs_c=-0.70709
	//********************************
	//	"CS",   22.3163, 21.1792, 10.7382, 1.46163, 0.23092, 3.49464, 25.1864, 232.829,-0.70709,
	//********************************     Cs+1
	make/N=4/O 'Cs+1_a', 'Cs+1_b'
	variable/g 'Cs+1_c'
	'Cs+1_a'={23.9649, 21.2204, 9.76727, 1.61550}
	'Cs+1_b'={0.20448, 3.43876, 23.4941, 49.7057}
	'Cs+1_c'=-2.56728
	//********************************
	//	"CS+1", 23.9649, 21.2204, 9.76727, 1.61550, 0.20448, 3.43876, 23.4941, 49.7057,-2.56728,
	//********************************     Ba
	make/N=4/O Ba_a, Ba_b
	variable/g Ba_c
	Ba_a={27.7489, 21.3777, 11.0400, 2.68186}
	Ba_b={0.15152, 3.09817, 20.6774, 178.819}
	Ba_c=-6.85854
	//********************************
	//	"BA",   27.7489, 21.3777, 11.0400, 2.68186, 0.15152, 3.09817, 20.6774, 178.819,-6.85854,
	//********************************     Ba+2
	make/N=4/O 'Ba+2_a', 'Ba+2_b'
	variable/g 'Ba+2_c'
	'Ba+2_a'={29.2996, 21.4669, 10.9209, 0.80126}
	'Ba+2_b'={0.14047, 3.08785, 20.8818, 46.8842}
	'Ba+2_c'=-8.48753
	//********************************
	//	"BA+2", 29.2996, 21.4669, 10.9209, 0.80126, 0.14047, 3.08785, 20.8818, 46.8842,-8.48753,
	//********************************     La
	make/N=4/O La_a, La_b
	variable/g La_c
	La_a={33.2109, 21.7181, 11.6222, 3.17239}
	La_b={0.11040, 2.83641, 19.3886, 144.438}
	La_c=-12.7404
	//********************************
	//	"LA",   33.2109, 21.7181, 11.6222, 3.17239, 0.11040, 2.83641, 19.3886, 144.438,-12.7404,
	//********************************     La+3
	make/N=4/O 'La+3_a', 'La+3_b'
	variable/g 'La+3_c'
	'La+3_a'={43.6346, 21.7192, 11.7264, 0.32945}
	'La+3_b'={0.07854, 2.78360, 18.4930, 49.2222}
	'La+3_c'=-23.4085
	//********************************
	//	"LA+3", 43.6346, 21.7192, 11.7264, 0.32945, 0.07854, 2.78360, 18.4930, 49.2222,-23.4085,
	//********************************     Ce
	make/N=4/O Ce_a, Ce_b
	variable/g Ce_c
	Ce_a={29.4100, 22.2428, 11.9818, 3.19259}
	Ce_b={0.12335, 2.74837, 18.3794, 139.603}
	Ce_c=-8.84560
	//********************************
	//	"CE",   29.4100, 22.2428, 11.9818, 3.19259, 0.12335, 2.74837, 18.3794, 139.603,-8.84560,
	//********************************     Ce+3
	make/N=4/O 'Ce+3_a', 'Ce+3_b'
	variable/g 'Ce+3_c'
	'Ce+3_a'={49.1105, 22.3499, 11.8399, 0.67455}
	'Ce+3_b'={0.06535, 2.67229, 17.2040, 38.1904}
	'Ce+3_c'=-28.9739
	//********************************
	//	"CE+3", 49.1105, 22.3499, 11.8399, 0.67455, 0.06535, 2.67229, 17.2040, 38.1904,-28.9739,
	//********************************     Ce+4
	make/N=4/O 'Ce+4_a', 'Ce+4_b'
	variable/g 'Ce+4_c'
	'Ce+4_a'={66.7693, 21.8563, 12.2486, 0.09617}
	'Ce+4_b'={0.04464, 2.53711, 16.4477, 64.4675}
	'Ce+4_c'=-46.9691
	//********************************
	//	"CE+4", 66.7693, 21.8563, 12.2486, 0.09617, 0.04464, 2.53711, 16.4477, 64.4675,-46.9691,
	//********************************     Pr
	make/N=4/O Pr_a, Pr_b
	variable/g Pr_c
	Pr_a={22.9220, 22.2518, 12.2269, 2.72431}
	Pr_b={2.78604, 0.18015, 17.6663, 160.915}
	Pr_c=-1.13930
	//********************************
	//	"PR",   22.9220, 22.2518, 12.2269, 2.72431, 2.78604, 0.18015, 17.6663, 160.915,-1.13930,
	//********************************     Pr+3
	make/N=4/O 'Pr+3_a', 'Pr+3_b'
	variable/g 'Pr+3_c'
	'Pr+3_a'={49.4655, 22.9705, 11.8015, 1.12179}
	'Pr+3_b'={0.06197, 2.57634, 16.0371, 32.3673}
	'Pr+3_c'=-29.3586
	//********************************
	//	"PR+3", 49.4655, 22.9705, 11.8015, 1.12179, 0.06197, 2.57634, 16.0371, 32.3673,-29.3586,
	//********************************     Pr+4
	make/N=4/O 'Pr+4_a', 'Pr+4_b'
	variable/g 'Pr+4_c'
	'Pr+4_a'={62.6752, 22.4952, 12.4946, 0.20294}
	'Pr+4_b'={0.04586, 2.45900, 15.5713, 46.5889}
	'Pr+4_c'=-42.8667
	//********************************
	//	"PR+4", 62.6752, 22.4952, 12.4946, 0.20294, 0.04586, 2.45900, 15.5713, 46.5889,-42.8667,
	//********************************     Nd
	make/N=4/O Nd_a, Nd_b
	variable/g Nd_c
	Nd_a={23.4069, 19.7073, 12.5016, 2.72850}
	Nd_b={2.71587, 0.20950, 16.9122, 156.556}
	Nd_c=1.64038
	//********************************
	//	"ND",   23.4069, 19.7073, 12.5016, 2.72850, 2.71587, 0.20950, 16.9122, 156.556, 1.64038,
	//********************************     Nd+3
	make/N=4/O 'Nd+3_a', 'Nd+3_b'
	variable/g 'Nd+3_c'
	'Nd+3_a'={49.4292, 23.6116, 11.6190, 1.68986}
	'Nd+3_b'={0.05936, 2.48611, 14.9366, 28.4515}
	'Nd+3_c'=-29.3493
	//********************************
	//	"ND+3", 49.4292, 23.6116, 11.6190, 1.68986, 0.05936, 2.48611, 14.9366, 28.4515,-29.3493,
	//********************************     Pm
	make/N=4/O Pm_a, Pm_b
	variable/g Pm_c
	Pm_a={23.8480, 17.5535, 12.7324, 2.72975}
	Pm_b={2.65746, 0.24780, 16.2463, 152.682}
	Pm_c=4.12018
	//********************************
	//	"PM",   23.8480, 17.5535, 12.7324, 2.72975, 2.65746, 0.24780, 16.2463, 152.682, 4.12018,
	//********************************     Pm+3
	make/N=4/O 'Pm+3_a', 'Pm+3_b'
	variable/g 'Pm+3_c'
	'Pm+3_a'={49.2699, 24.2700, 11.3481, 2.32869}
	'Pm+3_b'={0.05709, 2.40059, 13.9124, 25.6906}
	'Pm+3_c'=-29.2165
	//********************************
	//	"PM+3", 49.2699, 24.2700, 11.3481, 2.32869, 0.05709, 2.40059, 13.9124, 25.6906,-29.2165,
	//********************************     Sm
	make/N=4/O Sm_a, Sm_b
	variable/g Sm_c
	Sm_a={24.2242, 15.9132, 12.9238, 2.72836}
	Sm_b={2.60993, 0.29475, 15.6554, 149.221}
	Sm_c=6.19355
	//********************************
	//	"SM",   24.2242, 15.9132, 12.9238, 2.72836, 2.60993, 0.29475, 15.6554, 149.221, 6.19355,
	//********************************     Sm+3
	make/N=4/O 'Sm+3_a', 'Sm+3_b'
	variable/g 'Sm+3_c'
	'Sm+3_a'={36.3271, 24.8202, 11.3426, 2.62300}
	'Sm+3_b'={0.07823, 2.33602, 13.1872, 24.3996}
	'Sm+3_c'=-16.1429
	//********************************
	//	"SM+3", 36.3271, 24.8202, 11.3426, 2.62300, 0.07823, 2.33602, 13.1872, 24.3996,-16.1429,
	//********************************     Eu
	make/N=4/O Eu_a, Eu_b
	variable/g Eu_c
	Eu_a={24.5148, 14.8058, 13.0799, 2.72477}
	Eu_b={2.57225, 0.34930, 15.1280, 146.103}
	Eu_c=7.85731
	//********************************
	//	"EU",   24.5148, 14.8058, 13.0799, 2.72477, 2.57225, 0.34930, 15.1280, 146.103, 7.85731,
	//********************************     Eu+2
	make/N=4/O 'Eu+2_a', 'Eu+2_b'
	variable/g 'Eu+2_c'
	'Eu+2_a'={25.6516, 23.9387, 10.5738, 4.05853}
	'Eu+2_b'={2.36073, 0.13260, 12.6495, 25.0026}
	'Eu+2_c'=-3.22358
	//********************************
	//	"EU+2", 25.6516, 23.9387, 10.5738, 4.05853, 2.36073, 0.13260, 12.6495, 25.0026,-3.22358,
	//********************************     Eu+3
	make/N=4/O 'Eu+3_a', 'Eu+3_b'
	variable/g 'Eu+3_c'
	'Eu+3_a'={33.2862, 25.5041, 11.1494, 3.13496}
	'Eu+3_b'={0.08350, 2.26275, 12.3883, 22.8351}
	'Eu+3_c'=-13.0748
	//********************************
	//	"EU+3", 33.2862, 25.5041, 11.1494, 3.13496, 0.08350, 2.26275, 12.3883, 22.8351,-13.0748,
	//********************************     Gd
	make/N=4/O Gd_a, Gd_b
	variable/g Gd_c
	Gd_a={24.4004, 14.0308, 13.1754, 3.24472}
	Gd_b={2.47491, 0.40238, 14.4670, 119.738}
	Gd_c=9.12488
	//********************************
	//	"GD",   24.4004, 14.0308, 13.1754, 3.24472, 2.47491, 0.40238, 14.4670, 119.738, 9.12488,
	//********************************     Gd+3
	make/N=4/O 'Gd+3_a', 'Gd+3_b'
	variable/g 'Gd+3_c'
	'Gd+3_a'={29.0290, 26.1387, 11.0510, 3.52244}
	'Gd+3_b'={0.09521, 2.19696, 11.7141, 21.6929}
	'Gd+3_c'=-8.74150
	//********************************
	//	"GD+3", 29.0290, 26.1387, 11.0510, 3.52244, 0.09521, 2.19696, 11.7141, 21.6929,-8.74150,
	//********************************     Tb
	make/N=4/O Tb_a, Tb_b
	variable/g Tb_c
	Tb_a={24.3736, 13.8649, 13.2510, 3.24435}
	Tb_b={2.46637, 0.47517, 14.0424, 117.446}
	Tb_c=10.2420
	//********************************
	//	"TB",   24.3736, 13.8649, 13.2510, 3.24435, 2.46637, 0.47517, 14.0424, 117.446, 10.2420,
	//********************************     Tb+3
	make/N=4/O 'Tb+3_a', 'Tb+3_b'
	variable/g 'Tb+3_c'
	'Tb+3_a'={26.7821, 25.9463, 10.9724, 3.88172}
	'Tb+3_b'={2.13333, 0.10597, 11.0974, 20.7042}
	'Tb+3_c'=-5.58307
	//********************************
	//	"TB+3", 26.7821, 25.9463, 10.9724, 3.88172, 2.13333, 0.10597, 11.0974, 20.7042,-5.58307,
	//********************************     Dy
	make/N=4/O Dy_a, Dy_b
	variable/g Dy_c
	Dy_a={24.6193, 14.2735, 13.3567, 2.70316}
	Dy_b={2.52208, 0.54556, 13.8487, 138.385}
	Dy_c=11.0290
	//********************************
	//	"DY",   24.6193, 14.2735, 13.3567, 2.70316, 2.52208, 0.54556, 13.8487, 138.385, 11.0290,
	//********************************     Dy+3
	make/N=4/O 'Dy+3_a', 'Dy+3_b'
	variable/g 'Dy+3_c'
	'Dy+3_a'={27.3805, 22.2062, 10.9975, 4.10030}
	'Dy+3_b'={2.07832, 0.12643, 10.5960, 19.9671}
	'Dy+3_c'=-1.68516
	//********************************
	//	"DY+3", 27.3805, 22.2062, 10.9975, 4.10030, 2.07832, 0.12643, 10.5960, 19.9671,-1.68516,
	//********************************     Ho
	make/N=4/O Ho_a, Ho_b
	variable/g Ho_c
	Ho_a={24.3162, 14.9012, 13.3895, 2.69309}
	Ho_b={2.52724, 0.61572, 13.5041, 136.246}
	Ho_c=11.6817
	//********************************
	//	"HO",   24.3162, 14.9012, 13.3895, 2.69309, 2.52724, 0.61572, 13.5041, 136.246, 11.6817,
	//********************************     Ho+3
	make/N=4/O 'Ho+3_a', 'Ho+3_b'
	variable/g 'Ho+3_c'
	'Ho+3_a'={27.9956, 19.9560, 11.0106, 4.33205}
	'Ho+3_b'={2.02324, 0.14275, 10.1165, 19.2589}
	'Ho+3_c'=0.70499
	//********************************
	//	"HO+3", 27.9956, 19.9560, 11.0106, 4.33205, 2.02324, 0.14275, 10.1165, 19.2589, 0.70499,
	//********************************     Er
	make/N=4/O Er_a, Er_b
	variable/g Er_c
	Er_a={23.8201, 15.8796, 13.3938, 2.68190}
	Er_b={2.54419, 0.68445, 13.1932, 134.282}
	Er_c=12.2062
	//********************************
	//	"ER",   23.8201, 15.8796, 13.3938, 2.68190, 2.54419, 0.68445, 13.1932, 134.282, 12.2062,
	//********************************     Er+3
	make/N=4/O 'Er+3_a', 'Er+3_b'
	variable/g 'Er+3_c'
	'Er+3_a'={28.5315, 17.4316, 11.1113, 4.43156}
	'Er+3_b'={1.97796, 0.17182, 9.73821, 18.7294}
	'Er+3_c'=3.49325
	//********************************
	//	"ER+3", 28.5315, 17.4316, 11.1113, 4.43156, 1.97796, 0.17182, 9.73821, 18.7294, 3.49325,
	//********************************     Tm
	make/N=4/O Tm_a, Tm_b
	variable/g Tm_c
	Tm_a={23.1386, 17.1707, 13.3703, 2.66981}
	Tm_b={2.57320, 0.74948, 12.9126, 132.468}
	Tm_c=12.6322
	//********************************
	//	"TM",   23.1386, 17.1707, 13.3703, 2.66981, 2.57320, 0.74948, 12.9126, 132.468, 12.6322,
	//********************************     Tm+3
	make/N=4/O 'Tm+3_a', 'Tm+3_b'
	variable/g 'Tm+3_c'
	'Tm+3_a'={29.0215, 15.6168, 11.2288, 4.49403}
	'Tm+3_b'={1.93707, 0.20467, 9.40342, 18.2607}
	'Tm+3_c'=5.63812
	//********************************
	//	"TM+3", 29.0215, 15.6168, 11.2288, 4.49403, 1.93707, 0.20467, 9.40342, 18.2607, 5.63812,
	//********************************     Yb
	make/N=4/O Yb_a, Yb_b
	variable/g Yb_c
	Yb_a={22.3028, 18.7202, 13.3200, 2.65701}
	Yb_b={2.61393, 0.80868, 12.6590, 130.783}
	Yb_c=12.9818
	//********************************
	//	"YB",   22.3028, 18.7202, 13.3200, 2.65701, 2.61393, 0.80868, 12.6590, 130.783, 12.9818,
	//********************************     Yb+2
	make/N=4/O 'Yb+2_a', 'Yb+2_b'
	variable/g 'Yb+2_c'
	'Yb+2_a'={29.1313, 13.5855, 11.4132, 4.69659}
	'Yb+2_b'={1.99979, 0.32335, 9.59277, 20.3507}
	'Yb+2_c'=9.17182
	//********************************
	//	"YB+2", 29.1313, 13.5855, 11.4132, 4.69659, 1.99979, 0.32335, 9.59277, 20.3507, 9.17182,
	//********************************     Yb+3
	make/N=4/O 'Yb+3_a', 'Yb+3_b'
	variable/g 'Yb+3_c'
	'Yb+3_a'={29.4761, 14.4357, 11.3446, 4.54681}
	'Yb+3_b'={1.89879, 0.23793, 9.09408, 17.8206}
	'Yb+3_c'=7.19600
	//********************************
	//	"YB+3", 29.4761, 14.4357, 11.3446, 4.54681, 1.89879, 0.23793, 9.09408, 17.8206, 7.19600,
	//********************************     Lu
	make/N=4/O Lu_a, Lu_b
	variable/g Lu_c
	Lu_a={21.1866, 20.1760, 13.0532, 3.21190}
	Lu_b={0.88654, 2.68610, 12.2746, 107.128}
	Lu_c=13.3489
	//********************************
	//	"LU",   21.1866, 20.1760, 13.0532, 3.21190, 0.88654, 2.68610, 12.2746, 107.128, 13.3489,
	//********************************     'Lu+3
	make/N=4/O 'Lu+3_a', 'Lu+3_b'
	variable/g 'Lu+3_c'
	'Lu+3_a'={29.8480, 13.6268, 11.4750, 4.56009}
	'Lu+3_b'={1.86596, 0.27623, 8.82479, 17.4364}
	'Lu+3_c'=8.48923
	//********************************
	//	"LU+3", 29.8480, 13.6268, 11.4750, 4.56009, 1.86596, 0.27623, 8.82479, 17.4364, 8.48923,
	//********************************     Hf
	make/N=4/O Hf_a, Hf_b
	variable/g Hf_c
	Hf_a={24.6725, 17.2295, 12.8069, 3.55970}
	Hf_b={0.97400, 2.89038, 12.2897, 93.4381}
	Hf_c=13.7049
	//********************************
	//	"HF",   24.6725, 17.2295, 12.8069, 3.55970, 0.97400, 2.89038, 12.2897, 93.4381, 13.7049,
	//********************************     Ta
	make/N=4/O Ta_a, Ta_b
	variable/g Ta_c
	Ta_a={28.1757, 14.4288, 12.6412, 3.74436}
	Ta_b={1.04034, 3.20784, 12.5054, 85.0183}
	Ta_c=13.9824
	//********************************
	//	"TA",   28.1757, 14.4288, 12.6412, 3.74436, 1.04034, 3.20784, 12.5054, 85.0183, 13.9824,
	//********************************     W
	make/N=4/O W_a, W_b
	variable/g W_c
	W_a={31.0935, 12.5273, 12.3769, 3.79138}
	W_b={1.07885, 12.8331, 3.63298, 79.7647}
	W_c=14.1842
	//********************************
	//	"W",    31.0935, 12.5273, 12.3769, 3.79138, 1.07885, 12.8331, 3.63298, 79.7647, 14.1842,
	//********************************     Re
	make/N=4/O Re_a, Re_b
	variable/g Re_c
	Re_a={33.2961, 12.3497, 11.2819, 3.72367}
	Re_b={1.09315, 13.2559, 4.16736, 76.6562}
	Re_c=14.3239
	//********************************
	//	"RE",   33.2961, 12.3497, 11.2819, 3.72367, 1.09315, 13.2559, 4.16736, 76.6562, 14.3239,
	//********************************     Os
	make/N=4/O Os_a, Os_b
	variable/g Os_c
	Os_a={34.8667, 11.9524, 11.1851, 3.56436}
	Os_b={1.08840, 13.8042, 4.79179, 75.1399}
	Os_c=14.4097
	//********************************
	//	"OS",   34.8667, 11.9524, 11.1851, 3.56436, 1.08840, 13.8042, 4.79179, 75.1399, 14.4097,
	//********************************     Ir
	make/N=4/O Ir_a, Ir_b
	variable/g Ir_c
	Ir_a={35.9454, 11.9980, 11.2501, 3.34312}
	Ir_b={1.06924, 5.43443, 14.4983, 74.7918}
	Ir_c=14.4449
	//********************************
	//	"IR",   35.9454, 11.9980, 11.2501, 3.34312, 1.06924, 5.43443, 14.4983, 74.7918, 14.4449,
	//********************************     Pt
	make/N=4/O Pt_a, Pt_b
	variable/g Pt_c
	Pt_a={36.8102, 13.0747, 11.3323, 2.31421}
	Pt_b={1.04422, 6.07340, 15.7018, 73.8375}
	Pt_c=14.4526
	//********************************
	//	"PT",   36.8102, 13.0747, 11.3323, 2.31421, 1.04422, 6.07340, 15.7018, 73.8375, 14.4526,
	//********************************     Au
	make/N=4/O Au_a, Au_b
	variable/g Au_c
	Au_a={37.3027, 14.9306, 10.3425, 2.01229}
	Au_b={1.00810, 6.52550, 16.5100, 76.9117}
	Au_c=14.3992
	//********************************
	//	"AU",   37.3027, 14.9306, 10.3425, 2.01229, 1.00810, 6.52550, 16.5100, 76.9117, 14.3992,
	//********************************     Hg
	make/N=4/O Hg_a, Hg_b
	variable/g Hg_c
	Hg_a={37.5186, 17.0353, 8.51121, 2.63340}
	Hg_b={0.96455, 6.65786, 16.8438, 76.7228}
	Hg_c=14.2911
	//********************************
	//	"HG",   37.5186, 17.0353, 8.51121, 2.63340, 0.96455, 6.65786, 16.8438, 76.7228, 14.2911,
	//********************************     Tl
	make/N=4/O Tl_a, Tl_b
	variable/g Tl_c
	Tl_a={37.6947, 19.7195, 6.38290, 3.00960}
	Tl_b={0.92263, 6.78248, 19.2435, 85.9267}
	Tl_c=14.1800
	//********************************
	//	"TL",   37.6947, 19.7195, 6.38290, 3.00960, 0.92263, 6.78248, 19.2435, 85.9267, 14.1800,
	//********************************     Pb
	make/N=4/O Pb_a, Pb_b
	variable/g Pb_c
	Pb_a={37.7383, 21.3394, 5.17527, 3.71604}
	Pb_b={0.87755, 6.58964, 21.2437, 78.8094}
	Pb_c=14.0203
	//********************************
	//	"PB",   37.7383, 21.3394, 5.17527, 3.71604, 0.87755, 6.58964, 21.2437, 78.8094, 14.0203,
	//********************************     Bi
	make/N=4/O Bi_a, Bi_b
	variable/g Bi_c
	Bi_a={37.7143, 22.4542, 4.84549, 4.14816}
	Bi_b={0.83222, 6.27051, 24.4693, 72.1558}
	Bi_c=13.8301
	//********************************
	//	"BI",   37.7143, 22.4542, 4.84549, 4.14816, 0.83222, 6.27051, 24.4693, 72.1558, 13.8301,
	//********************************     Po
	make/N=4/O Po_a, Po_b
	variable/g Po_c
	Po_a={37.6297, 23.1323, 5.59203, 4.04218}
	Po_b={0.78640, 5.86644, 27.8678, 68.1617}
	Po_c=13.5991
	//********************************
	//	"PO",   37.6297, 23.1323, 5.59203, 4.04218, 0.78640, 5.86644, 27.8678, 68.1617, 13.5991,
	//********************************     At
	make/N=4/O At_a, At_b
	variable/g At_c
	At_a={37.4971, 23.5635, 7.15953, 3.45924}
	At_b={0.74012, 5.42694, 29.8350, 66.3564}
	At_c=13.3183
	//********************************
	//	"AT",   37.4971, 23.5635, 7.15953, 3.45924, 0.74012, 5.42694, 29.8350, 66.3564, 13.3183,
	//********************************     Rn
	make/N=4/O Rn_a, Rn_b
	variable/g Rn_c
	Rn_a={37.3308, 23.8933, 9.02222, 2.77349}
	Rn_b={0.69354, 4.98696, 30.0338, 65.5799}
	Rn_c=12.9796
	//********************************
	//	"RN",   37.3308, 23.8933, 9.02222, 2.77349, 0.69354, 4.98696, 30.0338, 65.5799, 12.9796,
	//********************************     Fr
	make/N=4/O Fr_a, Fr_b
	variable/g Fr_c
	Fr_a={37.1902, 24.1306, 11.5026, 1.47980}
	Fr_b={0.65303, 4.61305, 29.2597, 257.965}
	Fr_c=12.6868
	//********************************
	//	"FR",   37.1902, 24.1306, 11.5026, 1.47980, 0.65303, 4.61305, 29.2597, 257.965, 12.6868,
	//********************************     Ra
	make/N=4/O Ra_a, Ra_b
	variable/g Ra_c
	Ra_a={36.9820, 24.2495, 11.8719, 2.72428}
	Ra_b={0.60394, 4.17857, 24.3782, 200.024}
	Ra_c=12.1642
	//********************************
	//	"RA",   36.9820, 24.2495, 11.8719, 2.72428, 0.60394, 4.17857, 24.3782, 200.024, 12.1642,
	//********************************     Ac
	make/N=4/O Ac_a, Ac_b
	variable/g Ac_c
	Ac_a={36.8705, 24.7131, 12.3889, 3.26501}
	Ac_b={0.56458, 3.88776, 23.1506, 161.726}
	Ac_c=11.7484
	//********************************
	//	"AC",   36.8705, 24.7131, 12.3889, 3.26501, 0.56458, 3.88776, 23.1506, 161.726, 11.7484,
	//********************************     Th
	make/N=4/O Th_a, Th_b
	variable/g Th_c
	Th_a={36.7754, 25.2506, 13.0681, 3.63791}
	Th_b={0.52510, 3.61658, 22.3410, 139.164}
	Th_c=11.2497
	//********************************
	//	"TH",   36.7754, 25.2506, 13.0681, 3.63791, 0.52510, 3.61658, 22.3410, 139.164, 11.2497,
	//********************************     Pa
	make/N=4/O Pa_a, Pa_b
	variable/g Pa_c
	Pa_a={37.1457, 25.2998, 13.7846, 3.29611}
	Pa_b={0.52020, 3.66300, 20.6539, 150.973}
	Pa_c=11.4561
	//********************************
	//	"PA",   37.1457, 25.2998, 13.7846, 3.29611, 0.52020, 3.66300, 20.6539, 150.973, 11.4561,
	//********************************     U
	make/N=4/O U_a, U_b
	variable/g U_c
	U_a={37.2808, 25.6563, 14.3501, 3.30732}
	U_b={0.50239, 3.58562, 19.6342, 146.633}
	U_c=11.3864
	//********************************
	//	"U",    37.2808, 25.6563, 14.3501, 3.30732, 0.50239, 3.58562, 19.6342, 146.633, 11.3864,
	//********************************     Np
	make/N=4/O Np_a, Np_b
	variable/g Np_c
	Np_a={37.3968, 26.0671, 14.8366, 3.31586}
	Np_b={0.48676, 3.52325, 18.7419, 142.798}
	Np_c=11.3632
	//********************************
	//	"NP",   37.3968, 26.0671, 14.8366, 3.31586, 0.48676, 3.52325, 18.7419, 142.798, 11.3632,
	//********************************     Pu
	make/N=4/O Pu_a, Pu_b
	variable/g Pu_c
	Pu_a={37.6407, 26.5603, 15.4492, 2.79814}
	Pu_b={0.47976, 3.57178, 17.9814, 165.232}
	Pu_c=11.5358
	//********************************
	//	"PU",   37.6407, 26.5603, 15.4492, 2.79814, 0.47976, 3.57178, 17.9814, 165.232, 11.5358,
	//********************************     Am
	make/N=4/O Am_a, Am_b
	variable/g Am_c
	Am_a={37.6909, 27.1436, 15.7842, 2.79600}
	Am_b={0.46617, 3.52195, 17.3069, 161.931}
	Am_c=11.5685
	//********************************
	//	"AM",   37.6909, 27.1436, 15.7842, 2.79600, 0.46617, 3.52195, 17.3069, 161.931, 11.5685,
	//********************************     Cm
	make/N=4/O Cm_a, Cm_b
	variable/g Cm_c
	Cm_a={37.5543, 27.6657, 15.8858, 3.32758}
	Cm_b={0.44932, 3.38713, 16.6498, 133.547}
	Cm_c=11.5431
	//********************************
	//	"CM",   37.5543, 27.6657, 15.8858, 3.32758, 0.44932, 3.38713, 16.6498, 133.547, 11.5431,
	//********************************     Bk
	make/N=4/O Bk_a, Bk_b
	variable/g Bk_c
	Bk_a={37.5273, 28.3202, 16.1181, 3.32793}
	Bk_b={0.43930, 3.35014, 16.1000, 131.027}
	Bk_c=11.6823
	//********************************
	//	"BK",   37.5273, 28.3202, 16.1181, 3.32793, 0.43930, 3.35014, 16.1000, 131.027, 11.6823,
	//********************************     Cf
	make/N=4/O Cf_a, Cf_b
	variable/g Cf_c
	Cf_a={37.6111, 29.2465, 16.4566, 2.78216}
	Cf_b={0.43255, 3.39285, 15.6791, 153.766}
	Cf_c=11.8853
	//********************************
	//	"CF",   37.6111, 29.2465, 16.4566, 2.78216, 0.43255, 3.39285, 15.6791, 153.766, 11.8853,
	//********************************     Es
	make/N=4/O Es_a, Es_b
	variable/g Es_c
	Es_a={37.4979, 30.0495, 16.5881, 2.77596}
	Es_b={0.42353, 3.35234, 15.2381, 151.474}
	Es_c=12.0698
	//********************************
	//	"ES",   37.4979, 30.0495, 16.5881, 2.77596, 0.42353, 3.35234, 15.2381, 151.474, 12.0698,
	//********************************     Fm
	make/N=4/O Fm_a, Fm_b
	variable/g Fm_c
	Fm_a={37.3380, 30.8936, 16.6818, 2.76929}
	Fm_b={0.41562, 3.31193, 14.8362, 149.344}
	Fm_c=12.2983
	//********************************
	//	"FM",   37.3380, 30.8936, 16.6818, 2.76929, 0.41562, 3.31193, 14.8362, 149.344, 12.2983,
	//********************************     Md
	make/N=4/O Md_a, Md_b
	variable/g Md_c
	Md_a={37.1301, 31.7721, 16.7422, 2.76232}
	Md_b={0.40883, 3.27132, 14.4683, 147.353}
	Md_c=12.5741
	//********************************
	//	"MD",   37.1301, 31.7721, 16.7422, 2.76232, 0.40883, 3.27132, 14.4683, 147.353, 12.5741,
	//********************************     No
	make/N=4/O No_a, No_b
	variable/g No_c
	No_a={36.8731, 32.6784, 16.7732, 2.75513}
	No_b={0.40324, 3.23045, 14.1302, 145.481}
	No_c=12.9008
	//********************************
	//	"NO",   36.8731, 32.6784, 16.7732, 2.75513, 0.40324, 3.23045, 14.1302, 145.481, 12.9008,
	//********************************     Lw
	make/N=4/O Lw_a, Lw_b
	variable/g Lw_c
	Lw_a={36.3813, 33.1999, 16.6469, 3.31406}
	Lw_b={0.40165, 3.13608, 13.7255, 119.377}
	Lw_c=13.4313
	//********************************
	//	"LW",   36.3813, 33.1999, 16.6469, 3.31406, 0.40165, 3.13608, 13.7255, 119.377, 13.4313,
	//********************************     H
//	make/N=4/O H_a, H_b
//	variable/g H_c
//	H_a={0.39875, 0.31285, 0.2144,  0.07135}
//	H_b={58.3331, 14.7175, 236.7147, 3.4848}
//	H_c=0.00125
//	//********************************
	setDataFolder OldDf
end


static Function Cromer_InitializeStrings()
	
	string OldDf=GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:CromerCalculations

	string/g $("CromerCalculationsPath")  
	SVAR FillMeStr = $("CromerCalculationsPath")  
	FillMeStr = "C:Program Files:WaveMetrics:Igor Pro Folder:User Procedures:Irena"  
	string/g $("1")  
	SVAR FillMeStr = $("1")  
	FillMeStr = "SYM=H;ETERM=0;NSHELLS=0;"  
	string/g $("2")  
	SVAR FillMeStr = $("2")  
	FillMeStr = "SYM=HE;ETERM=0;NSHELLS=0;"  
	string/g $("3")  
	SVAR FillMeStr = $("3")  
	FillMeStr = "SYM=LI;ETERM=-0.001;NSHELLS=2;Shell1Shell=1S1/2;Shell1FuncType=2;Shell1BindEnergy=0.05475;Shell1NumX"  
	FillMeStr += "sect=10;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.00534;Shell2NumXsect=10;"  
	string/g $("4")  
	SVAR FillMeStr = $("4")  
	FillMeStr = "SYM=BE;ETERM=-0.001;NSHELLS=2;Shell1Shell=1S1/2;Shell1FuncType=2;Shell1BindEnergy=0.111;Shell1NumXse"  
	FillMeStr += "ct=10;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.00842;Shell2NumXsect=10;"  
	string/g $("5")  
	SVAR FillMeStr = $("5")  
	FillMeStr = "SYM=B;ETERM=-0.002;NSHELLS=3;Shell1Shell=1S1/2;Shell1FuncType=2;Shell1BindEnergy=0.188;Shell1NumXsec"  
	FillMeStr += "t=10;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.01347;Shell2NumXsect=10;Shell3Shell=2P1/2"  
	FillMeStr += ";Shell3FuncType=2;Shell3BindEnergy=0.0047;Shell3NumXsect=10;"  
	string/g $("6")  
	SVAR FillMeStr = $("6")  
	FillMeStr = "SYM=C;ETERM=-0.003;NSHELLS=3;Shell1Shell=1S1/2;Shell1FuncType=2;Shell1BindEnergy=0.2838;Shell1NumXse"  
	FillMeStr += "ct=10;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.01951;Shell2NumXsect=10;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=2;Shell3BindEnergy=0.0064;Shell3NumXsect=10;"  
	string/g $("7")  
	SVAR FillMeStr = $("7")  
	FillMeStr = "SYM=N;ETERM=-0.005;NSHELLS=4;Shell1Shell=1S1/2;Shell1FuncType=2;Shell1BindEnergy=0.4016;Shell1NumXse"  
	FillMeStr += "ct=10;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.02631;Shell2NumXsect=10;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=2;Shell3BindEnergy=0.0092;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shel"  
	FillMeStr += "l4BindEnergy=0.0092;Shell4NumXsect=10;"  
	string/g $("8")  
	SVAR FillMeStr = $("8")  
	FillMeStr = "SYM=O;ETERM=-0.007;NSHELLS=4;Shell1Shell=1S1/2;Shell1FuncType=2;Shell1BindEnergy=0.532;Shell1NumXsec"  
	FillMeStr += "t=10;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.0237;Shell2NumXsect=10;Shell3Shell=2P1/2;"  
	FillMeStr += "Shell3FuncType=2;Shell3BindEnergy=0.0071;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shell4"  
	FillMeStr += "BindEnergy=0.0071;Shell4NumXsect=10;"  
	string/g $("9")  
	SVAR FillMeStr = $("9")  
	FillMeStr = "SYM=F;ETERM=-0.009;NSHELLS=4;Shell1Shell=1S1/2;Shell1FuncType=2;Shell1BindEnergy=0.6854;Shell1NumXse"  
	FillMeStr += "ct=10;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.031;Shell2NumXsect=10;Shell3Shell=2P1/2;"  
	FillMeStr += "Shell3FuncType=2;Shell3BindEnergy=0.0086;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shell4"  
	FillMeStr += "BindEnergy=0.0086;Shell4NumXsect=10;"  
	string/g $("10")  
	SVAR FillMeStr = $("10")  
	FillMeStr = "SYM=NE;ETERM=-0.011;NSHELLS=4;Shell1Shell=1S1/2;Shell1FuncType=2;Shell1BindEnergy=0.8669;Shell1NumXs"  
	FillMeStr += "ect=10;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.045;Shell2NumXsect=10;Shell3Shell=2P1/2"  
	FillMeStr += ";Shell3FuncType=2;Shell3BindEnergy=0.0183;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shell"  
	FillMeStr += "4BindEnergy=0.0183;Shell4NumXsect=10;"  
	string/g $("11")  
	SVAR FillMeStr = $("11")  
	FillMeStr = "SYM=NA;ETERM=-0.014;NSHELLS=4;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=1.0721;Shell1NumXs"  
	FillMeStr += "ect=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.0633;Shell2NumXsect=10;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=2;Shell3BindEnergy=0.0311;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shel"  
	FillMeStr += "l4BindEnergy=0.0311;Shell4NumXsect=10;"  
	string/g $("12")  
	SVAR FillMeStr = $("12")  
	FillMeStr = "SYM=MG;ETERM=-0.018;NSHELLS=4;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=1.305;Shell1NumXse"  
	FillMeStr += "ct=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.0894;Shell2NumXsect=10;Shell3Shell=2P1/2"  
	FillMeStr += ";Shell3FuncType=2;Shell3BindEnergy=0.0514;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shell"  
	FillMeStr += "4BindEnergy=0.0514;Shell4NumXsect=10;"  
	string/g $("13")  
	SVAR FillMeStr = $("13")  
	FillMeStr = "SYM=AL;ETERM=-0.021;NSHELLS=5;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=1.5596;Shell1NumXs"  
	FillMeStr += "ect=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.1177;Shell2NumXsect=10;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=2;Shell3BindEnergy=0.0731;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shel"  
	FillMeStr += "l4BindEnergy=0.0731;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.00837567"  
	FillMeStr += ";Shell5NumXsect=10;"  
	string/g $("14")  
	SVAR FillMeStr = $("14")  
	FillMeStr = "SYM=SI;ETERM=-0.026;NSHELLS=6;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=1.8389;Shell1NumXs"  
	FillMeStr += "ect=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.1487;Shell2NumXsect=10;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=2;Shell3BindEnergy=0.0992;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shel"  
	FillMeStr += "l4BindEnergy=0.0992;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.0113572;"  
	FillMeStr += "Shell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.00508305;Shell6NumXsect=10;"  
	string/g $("15")  
	SVAR FillMeStr = $("15")  
	FillMeStr = "SYM=P;ETERM=-0.03;NSHELLS=7;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=2.1455;Shell1NumXsec"  
	FillMeStr += "t=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.1893;Shell2NumXsect=10;Shell3Shell=2P1/2;"  
	FillMeStr += "Shell3FuncType=2;Shell3BindEnergy=0.1322;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shell4"  
	FillMeStr += "BindEnergy=0.1322;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.0144615;Sh"  
	FillMeStr += "ell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.00638493;Shell6NumXsect=10;She"  
	FillMeStr += "ll7Shell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.00633669;Shell7NumXsect=10;"  
	string/g $("16")  
	SVAR FillMeStr = $("16")  
	FillMeStr = "SYM=S;ETERM=-0.035;NSHELLS=7;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=2.472;Shell1NumXsec"  
	FillMeStr += "t=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.2292;Shell2NumXsect=10;Shell3Shell=2P1/2;"  
	FillMeStr += "Shell3FuncType=2;Shell3BindEnergy=0.1648;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shell4"  
	FillMeStr += "BindEnergy=0.1648;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.0176882;Sh"  
	FillMeStr += "ell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.00781363;Shell6NumXsect=10;She"  
	FillMeStr += "ll7Shell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.00773488;Shell7NumXsect=10;"  
	string/g $("17")  
	SVAR FillMeStr = $("17")  
	FillMeStr = "SYM=CL;ETERM=-0.041;NSHELLS=7;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=2.8224;Shell1NumXs"  
	FillMeStr += "ect=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.2702;Shell2NumXsect=10;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=2;Shell3BindEnergy=0.2016;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shel"  
	FillMeStr += "l4BindEnergy=0.2;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.0175;Shell5"  
	FillMeStr += "NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.0068;Shell6NumXsect=10;Shell7Shell"  
	FillMeStr += "=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.0068;Shell7NumXsect=10;"  
	string/g $("18")  
	SVAR FillMeStr = $("18")  
	FillMeStr = "SYM=AR;ETERM=-0.047;NSHELLS=7;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=3.2029;Shell1NumXs"  
	FillMeStr += "ect=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.32;Shell2NumXsect=10;Shell3Shell=2P1/2;"  
	FillMeStr += "Shell3FuncType=2;Shell3BindEnergy=0.2473;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shell4"  
	FillMeStr += "BindEnergy=0.2452;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.0253;Shell"  
	FillMeStr += "5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.0124;Shell6NumXsect=10;Shell7Shel"  
	FillMeStr += "l=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.0124;Shell7NumXsect=10;"  
	string/g $("19")  
	SVAR FillMeStr = $("19")  
	FillMeStr = "SYM=K;ETERM=-0.053;NSHELLS=7;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=3.6074;Shell1NumXse"  
	FillMeStr += "ct=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.3771;Shell2NumXsect=10;Shell3Shell=2P1/2"  
	FillMeStr += ";Shell3FuncType=2;Shell3BindEnergy=0.2963;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shell"  
	FillMeStr += "4BindEnergy=0.2936;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.0339;Shel"  
	FillMeStr += "l5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.0178;Shell6NumXsect=10;Shell7She"  
	FillMeStr += "ll=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.0178;Shell7NumXsect=10;"  
	string/g $("20")  
	SVAR FillMeStr = $("20")  
	FillMeStr = "SYM=CA;ETERM=-0.06;NSHELLS=7;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=4.0381;Shell1NumXse"  
	FillMeStr += "ct=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.4378;Shell2NumXsect=10;Shell3Shell=2P1/2"  
	FillMeStr += ";Shell3FuncType=2;Shell3BindEnergy=0.35;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shell4B"  
	FillMeStr += "indEnergy=0.3464;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.0437;Shell5"  
	FillMeStr += "NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.0254;Shell6NumXsect=10;Shell7Shell"  
	FillMeStr += "=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.0254;Shell7NumXsect=10;"  
	string/g $("21")  
	SVAR FillMeStr = $("21")  
	FillMeStr = "SYM=SC;ETERM=-0.068;NSHELLS=7;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=4.4928;Shell1NumXs"  
	FillMeStr += "ect=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.5004;Shell2NumXsect=10;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=2;Shell3BindEnergy=0.4067;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shel"  
	FillMeStr += "l4BindEnergy=0.4022;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.0538;She"  
	FillMeStr += "ll5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.0323;Shell6NumXsect=10;Shell7Sh"  
	FillMeStr += "ell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.0323;Shell7NumXsect=10;"  
	string/g $("22")  
	SVAR FillMeStr = $("22")  
	FillMeStr = "SYM=TI;ETERM=-0.075;NSHELLS=7;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=4.9664;Shell1NumXs"  
	FillMeStr += "ect=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.5637;Shell2NumXsect=10;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=2;Shell3BindEnergy=0.4615;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shel"  
	FillMeStr += "l4BindEnergy=0.4555;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.0603;She"  
	FillMeStr += "ll5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.0346;Shell6NumXsect=10;Shell7Sh"  
	FillMeStr += "ell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.0346;Shell7NumXsect=10;"  
	string/g $("23")  
	SVAR FillMeStr = $("23")  
	FillMeStr = "SYM=V;ETERM=-0.084;NSHELLS=8;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=5.4651;Shell1NumXse"  
	FillMeStr += "ct=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.6282;Shell2NumXsect=10;Shell3Shell=2P1/2"  
	FillMeStr += ";Shell3FuncType=2;Shell3BindEnergy=0.5205;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shell"  
	FillMeStr += "4BindEnergy=0.5129;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.0665;Shel"  
	FillMeStr += "l5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.0378;Shell6NumXsect=10;Shell7She"  
	FillMeStr += "ll=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.0378;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncType"  
	FillMeStr += "=2;Shell8BindEnergy=0.0022;Shell8NumXsect=10;"  
	string/g $("24")  
	SVAR FillMeStr = $("24")  
	FillMeStr = "SYM=CR;ETERM=-0.093;NSHELLS=9;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=5.9892;Shell1NumXs"  
	FillMeStr += "ect=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.6946;Shell2NumXsect=10;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=2;Shell3BindEnergy=0.5837;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shel"  
	FillMeStr += "l4BindEnergy=0.5745;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.0741;She"  
	FillMeStr += "ll5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.0425;Shell6NumXsect=10;Shell7Sh"  
	FillMeStr += "ell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.0425;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTyp"  
	FillMeStr += "e=2;Shell8BindEnergy=0.0023;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0."  
	FillMeStr += "0023;Shell9NumXsect=10;"  
	string/g $("25")  
	SVAR FillMeStr = $("25")  
	FillMeStr = "SYM=MN;ETERM=-0.102;NSHELLS=9;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=6.539;Shell1NumXse"  
	FillMeStr += "ct=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.769;Shell2NumXsect=10;Shell3Shell=2P1/2;"  
	FillMeStr += "Shell3FuncType=2;Shell3BindEnergy=0.6514;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shell4"  
	FillMeStr += "BindEnergy=0.6403;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.0839;Shell"  
	FillMeStr += "5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.0486;Shell6NumXsect=10;Shell7Shel"  
	FillMeStr += "l=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.0486;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncType="  
	FillMeStr += "2;Shell8BindEnergy=0.00726159;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy="  
	FillMeStr += "0.00714378;Shell9NumXsect=10;"  
	string/g $("26")  
	SVAR FillMeStr = $("26")  
	FillMeStr = "SYM=FE;ETERM=-0.113;NSHELLS=9;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=7.112;Shell1NumXse"  
	FillMeStr += "ct=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.8461;Shell2NumXsect=10;Shell3Shell=2P1/2"  
	FillMeStr += ";Shell3FuncType=2;Shell3BindEnergy=0.7211;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shell"  
	FillMeStr += "4BindEnergy=0.7081;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.0929;Shel"  
	FillMeStr += "l5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.054;Shell6NumXsect=10;Shell7Shel"  
	FillMeStr += "l=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.054;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncType=2"  
	FillMeStr += ";Shell8BindEnergy=0.0036;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0.003"  
	FillMeStr += "6;Shell9NumXsect=10;"  
	string/g $("27")  
	SVAR FillMeStr = $("27")  
	FillMeStr = "SYM=CO;ETERM=-0.123;NSHELLS=9;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=7.7089;Shell1NumXs"  
	FillMeStr += "ect=11;Shell2Shell=2S1/2;Shell2FuncType=2;Shell2BindEnergy=0.9256;Shell2NumXsect=10;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=2;Shell3BindEnergy=0.7936;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shel"  
	FillMeStr += "l4BindEnergy=0.7786;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.1007;She"  
	FillMeStr += "ll5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.0595;Shell6NumXsect=10;Shell7Sh"  
	FillMeStr += "ell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.0595;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTyp"  
	FillMeStr += "e=2;Shell8BindEnergy=0.0029;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0."  
	FillMeStr += "0029;Shell9NumXsect=10;"  
	string/g $("28")  
	SVAR FillMeStr = $("28")  
	FillMeStr = "SYM=NI;ETERM=-0.135;NSHELLS=9;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=8.3328;Shell1NumXs"  
	FillMeStr += "ect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=1.0081;Shell2NumXsect=11;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=2;Shell3BindEnergy=0.8719;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shel"  
	FillMeStr += "l4BindEnergy=0.8547;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.1118;She"  
	FillMeStr += "ll5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.0681;Shell6NumXsect=10;Shell7Sh"  
	FillMeStr += "ell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.0681;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTyp"  
	FillMeStr += "e=2;Shell8BindEnergy=0.0036;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0."  
	FillMeStr += "0036;Shell9NumXsect=10;"  
	string/g $("29")  
	SVAR FillMeStr = $("29")  
	FillMeStr = "SYM=CU;ETERM=-0.146;NSHELLS=9;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=8.9789;Shell1NumXs"  
	FillMeStr += "ect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=1.0961;Shell2NumXsect=11;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=2;Shell3BindEnergy=0.951;Shell3NumXsect=10;Shell4Shell=2P3/2;Shell4FuncType=2;Shell"  
	FillMeStr += "4BindEnergy=0.9311;Shell4NumXsect=10;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.1198;Shel"  
	FillMeStr += "l5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.0736;Shell6NumXsect=10;Shell7She"  
	FillMeStr += "ll=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.0736;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncType"  
	FillMeStr += "=2;Shell8BindEnergy=0.0016;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0.0"  
	FillMeStr += "016;Shell9NumXsect=10;"  
	string/g $("30")  
	SVAR FillMeStr = $("30")  
	FillMeStr = "SYM=ZN;ETERM=-0.159;NSHELLS=9;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=9.6586;Shell1NumXs"  
	FillMeStr += "ect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=1.1936;Shell2NumXsect=11;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=0;Shell3BindEnergy=1.0428;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Shel"  
	FillMeStr += "l4BindEnergy=1.0197;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.1359;She"  
	FillMeStr += "ll5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.0866;Shell6NumXsect=10;Shell7Sh"  
	FillMeStr += "ell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.0866;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTyp"  
	FillMeStr += "e=2;Shell8BindEnergy=0.0081;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0."  
	FillMeStr += "0081;Shell9NumXsect=10;"  
	string/g $("31")  
	SVAR FillMeStr = $("31")  
	FillMeStr = "SYM=GA;ETERM=-0.172;NSHELLS=9;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=10.3671;Shell1NumX"  
	FillMeStr += "sect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=1.2977;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=1.1423;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=1.1154;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.1581;Sh"  
	FillMeStr += "ell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.1068;Shell6NumXsect=10;Shell7S"  
	FillMeStr += "hell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.1029;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=2;Shell8BindEnergy=0.0174;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0"  
	FillMeStr += ".0174;Shell9NumXsect=10;"  
	string/g $("32")  
	SVAR FillMeStr = $("32")  
	FillMeStr = "SYM=GE;ETERM=-0.186;NSHELLS=9;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=11.1031;Shell1NumX"  
	FillMeStr += "sect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=1.4143;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=1.2478;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=1.2167;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.18;Shel"  
	FillMeStr += "l5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.1279;Shell6NumXsect=10;Shell7She"  
	FillMeStr += "ll=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.1208;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncType"  
	FillMeStr += "=2;Shell8BindEnergy=0.0287;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0.0"  
	FillMeStr += "287;Shell9NumXsect=10;"  
	string/g $("33")  
	SVAR FillMeStr = $("33")  
	FillMeStr = "SYM=AS;ETERM=-0.2;NSHELLS=9;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=11.8667;Shell1NumXse"  
	FillMeStr += "ct=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=1.5265;Shell2NumXsect=11;Shell3Shell=2P1/2"  
	FillMeStr += ";Shell3FuncType=0;Shell3BindEnergy=1.3586;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Shell"  
	FillMeStr += "4BindEnergy=1.3231;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.2035;Shel"  
	FillMeStr += "l5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.1464;Shell6NumXsect=10;Shell7She"  
	FillMeStr += "ll=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.1405;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncType"  
	FillMeStr += "=2;Shell8BindEnergy=0.0412;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0.0"  
	FillMeStr += "412;Shell9NumXsect=10;"  
	string/g $("34")  
	SVAR FillMeStr = $("34")  
	FillMeStr = "SYM=SE;ETERM=-0.215;NSHELLS=9;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=12.6578;Shell1NumX"  
	FillMeStr += "sect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=1.6539;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=1.4762;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=1.4358;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.2315;Sh"  
	FillMeStr += "ell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.1682;Shell6NumXsect=10;Shell7S"  
	FillMeStr += "hell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.1619;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=2;Shell8BindEnergy=0.0567;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0"  
	FillMeStr += ".0567;Shell9NumXsect=10;"  
	string/g $("35")  
	SVAR FillMeStr = $("35")  
	FillMeStr = "SYM=BR;ETERM=-0.231;NSHELLS=9;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=13.4737;Shell1NumX"  
	FillMeStr += "sect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=1.782;Shell2NumXsect=11;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=0;Shell3BindEnergy=1.596;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Shell"  
	FillMeStr += "4BindEnergy=1.5499;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.2565;Shel"  
	FillMeStr += "l5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.1893;Shell6NumXsect=10;Shell7She"  
	FillMeStr += "ll=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.1815;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncType"  
	FillMeStr += "=2;Shell8BindEnergy=0.0701;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0.0"  
	FillMeStr += "69;Shell9NumXsect=10;"  
	string/g $("36")  
	SVAR FillMeStr = $("36")  
	FillMeStr = "SYM=KR;ETERM=-0.247;NSHELLS=9;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=14.3256;Shell1NumX"  
	FillMeStr += "sect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=1.921;Shell2NumXsect=11;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=0;Shell3BindEnergy=1.7272;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Shel"  
	FillMeStr += "l4BindEnergy=1.6749;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.28833;Sh"  
	FillMeStr += "ell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.2227;Shell6NumXsect=10;Shell7S"  
	FillMeStr += "hell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.2138;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=2;Shell8BindEnergy=0.0889;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0"  
	FillMeStr += ".0889;Shell9NumXsect=10;"  
	string/g $("37")  
	SVAR FillMeStr = $("37")  
	FillMeStr = "SYM=RB;ETERM=-0.264;NSHELLS=9;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=15.1997;Shell1NumX"  
	FillMeStr += "sect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=2.0651;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=1.8639;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=1.8044;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.3221;Sh"  
	FillMeStr += "ell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.2474;Shell6NumXsect=10;Shell7S"  
	FillMeStr += "hell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.2385;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=2;Shell8BindEnergy=0.1118;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0"  
	FillMeStr += ".1103;Shell9NumXsect=10;"  
	string/g $("38")  
	SVAR FillMeStr = $("38")  
	FillMeStr = "SYM=SR;ETERM=-0.282;NSHELLS=12;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=16.1046;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=2.2163;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=2.0068;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=1.9396;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.3575;S"  
	FillMeStr += "hell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.2798;Shell6NumXsect=10;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.2691;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncT"  
	FillMeStr += "ype=2;Shell8BindEnergy=0.135;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0"  
	FillMeStr += ".1331;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.0377;Shell10NumXsec"  
	FillMeStr += "t=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.0199;Shell11NumXsect=10;Shell12Shell=4"  
	FillMeStr += "P3/2;Shell12FuncType=2;Shell12BindEnergy=0.0199;Shell12NumXsect=10;"  
	string/g $("39")  
	SVAR FillMeStr = $("39")  
	FillMeStr = "SYM=Y;ETERM=-0.3;NSHELLS=12;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=17.0384;Shell1NumXse"  
	FillMeStr += "ct=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=2.3725;Shell2NumXsect=11;Shell3Shell=2P1/2"  
	FillMeStr += ";Shell3FuncType=0;Shell3BindEnergy=2.1555;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Shell"  
	FillMeStr += "4BindEnergy=2.08;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.3936;Shell5"  
	FillMeStr += "NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.3124;Shell6NumXsect=10;Shell7Shell"  
	FillMeStr += "=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.3003;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncType=2"  
	FillMeStr += ";Shell8BindEnergy=0.1596;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0.157"  
	FillMeStr += "4;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.0454;Shell10NumXsect=10"  
	FillMeStr += ";Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.0256;Shell11NumXsect=10;Shell12Shell=4P3/2"  
	FillMeStr += ";Shell12FuncType=2;Shell12BindEnergy=0.0256;Shell12NumXsect=10;"  
	string/g $("40")  
	SVAR FillMeStr = $("40")  
	FillMeStr = "SYM=ZR;ETERM=-0.319;NSHELLS=13;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=17.9976;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=2.5316;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=2.3067;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=2.2223;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.4303;S"  
	FillMeStr += "hell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.3442;Shell6NumXsect=10;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.3305;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncT"  
	FillMeStr += "ype=2;Shell8BindEnergy=0.1824;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy="  
	FillMeStr += "0.18;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.0513;Shell10NumXsect"  
	FillMeStr += "=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.0287;Shell11NumXsect=10;Shell12Shell=4P"  
	FillMeStr += "3/2;Shell12FuncType=2;Shell12BindEnergy=0.0287;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType"  
	FillMeStr += "=2;Shell13BindEnergy=0.00402345;Shell13NumXsect=10;"  
	string/g $("41")  
	SVAR FillMeStr = $("41")  
	FillMeStr = "SYM=NB;ETERM=-0.338;NSHELLS=13;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=18.9856;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=2.6977;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=2.4647;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=2.3705;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.4684;S"  
	FillMeStr += "hell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.3784;Shell6NumXsect=10;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.363;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=2;Shell8BindEnergy=0.2074;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0"  
	FillMeStr += ".2046;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.0581;Shell10NumXsec"  
	FillMeStr += "t=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.0339;Shell11NumXsect=10;Shell12Shell=4"  
	FillMeStr += "P3/2;Shell12FuncType=2;Shell12BindEnergy=0.0339;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTyp"  
	FillMeStr += "e=2;Shell13BindEnergy=0.0032;Shell13NumXsect=10;"  
	string/g $("42")  
	SVAR FillMeStr = $("42")  
	FillMeStr = "SYM=MO;ETERM=-0.359;NSHELLS=14;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=19.9995;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=2.8655;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=2.6251;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=2.5202;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.5046;S"  
	FillMeStr += "hell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.4097;Shell6NumXsect=10;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.3923;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncT"  
	FillMeStr += "ype=2;Shell8BindEnergy=0.2303;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy="  
	FillMeStr += "0.227;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.0618;Shell10NumXsec"  
	FillMeStr += "t=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.0348;Shell11NumXsect=10;Shell12Shell=4"  
	FillMeStr += "P3/2;Shell12FuncType=2;Shell12BindEnergy=0.0348;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTyp"  
	FillMeStr += "e=2;Shell13BindEnergy=0.0018;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEner"  
	FillMeStr += "gy=0.0018;Shell14NumXsect=10;"  
	string/g $("43")  
	SVAR FillMeStr = $("43")  
	FillMeStr = "SYM=TC;ETERM=-0.38;NSHELLS=14;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=21.044;Shell1NumXs"  
	FillMeStr += "ect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=3.0425;Shell2NumXsect=11;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=0;Shell3BindEnergy=2.7932;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Shel"  
	FillMeStr += "l4BindEnergy=2.6769;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.5476;She"  
	FillMeStr += "ll5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.4449;Shell6NumXsect=10;Shell7Sh"  
	FillMeStr += "ell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.425;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncType"  
	FillMeStr += "=2;Shell8BindEnergy=0.2564;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0.2"  
	FillMeStr += "529;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.0684;Shell10NumXsect="  
	FillMeStr += "10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.0389;Shell11NumXsect=10;Shell12Shell=4P3"  
	FillMeStr += "/2;Shell12FuncType=2;Shell12BindEnergy=0.0389;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType="  
	FillMeStr += "2;Shell13BindEnergy=0.00701158;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEn"  
	FillMeStr += "ergy=0.00672942;Shell14NumXsect=10;"  
	string/g $("44")  
	SVAR FillMeStr = $("44")  
	FillMeStr = "SYM=RU;ETERM=-0.401;NSHELLS=14;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=22.1172;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=3.224;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=2.9669;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=2.8379;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.585;She"  
	FillMeStr += "ll5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.4828;Shell6NumXsect=10;Shell7Sh"  
	FillMeStr += "ell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.4606;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTyp"  
	FillMeStr += "e=2;Shell8BindEnergy=0.2836;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0."  
	FillMeStr += "2794;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.0749;Shell10NumXsect"  
	FillMeStr += "=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.0431;Shell11NumXsect=10;Shell12Shell=4P"  
	FillMeStr += "3/2;Shell12FuncType=2;Shell12BindEnergy=0.0431;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType"  
	FillMeStr += "=2;Shell13BindEnergy=0.002;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnergy"  
	FillMeStr += "=0.002;Shell14NumXsect=10;"  
	string/g $("45")  
	SVAR FillMeStr = $("45")  
	FillMeStr = "SYM=RH;ETERM=-0.424;NSHELLS=14;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=23.2199;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=3.4119;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=3.1461;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=3.0038;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.6271;S"  
	FillMeStr += "hell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.521;Shell6NumXsect=10;Shell7S"  
	FillMeStr += "hell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.4962;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=2;Shell8BindEnergy=0.3117;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0"  
	FillMeStr += ".307;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.081;Shell10NumXsect="  
	FillMeStr += "10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.0479;Shell11NumXsect=10;Shell12Shell=4P3"  
	FillMeStr += "/2;Shell12FuncType=2;Shell12BindEnergy=0.0479;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType="  
	FillMeStr += "2;Shell13BindEnergy=0.0025;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnergy"  
	FillMeStr += "=0.0025;Shell14NumXsect=10;"  
	string/g $("46")  
	SVAR FillMeStr = $("46")  
	FillMeStr = "SYM=PD;ETERM=-0.447;NSHELLS=14;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=24.3503;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=3.6043;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=3.3303;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=3.1733;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.6699;S"  
	FillMeStr += "hell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.5591;Shell6NumXsect=10;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.5315;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncT"  
	FillMeStr += "ype=2;Shell8BindEnergy=0.34;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0."  
	FillMeStr += "3347;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.0864;Shell10NumXsect"  
	FillMeStr += "=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.0511;Shell11NumXsect=10;Shell12Shell=4P"  
	FillMeStr += "3/2;Shell12FuncType=2;Shell12BindEnergy=0.0511;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType"  
	FillMeStr += "=2;Shell13BindEnergy=0.00544663;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindE"  
	FillMeStr += "nergy=0.00501841;Shell14NumXsect=10;"  
	string/g $("47")  
	SVAR FillMeStr = $("47")  
	FillMeStr = "SYM=AG;ETERM=-0.471;NSHELLS=14;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=25.514;Shell1NumX"  
	FillMeStr += "sect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=3.8058;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=3.5237;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=3.3511;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.7175;Sh"  
	FillMeStr += "ell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.6024;Shell6NumXsect=10;Shell7S"  
	FillMeStr += "hell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.5714;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=2;Shell8BindEnergy=0.3728;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0"  
	FillMeStr += ".3667;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.0952;Shell10NumXsec"  
	FillMeStr += "t=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.0626;Shell11NumXsect=10;Shell12Shell=4"  
	FillMeStr += "P3/2;Shell12FuncType=2;Shell12BindEnergy=0.0559;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTyp"  
	FillMeStr += "e=2;Shell13BindEnergy=0.0033;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEner"  
	FillMeStr += "gy=0.0033;Shell14NumXsect=10;"  
	string/g $("48")  
	SVAR FillMeStr = $("48")  
	FillMeStr = "SYM=CD;ETERM=-0.496;NSHELLS=14;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=26.7112;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=4.018;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=3.727;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Shel"  
	FillMeStr += "l4BindEnergy=3.5375;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.7702;She"  
	FillMeStr += "ll5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.6507;Shell6NumXsect=10;Shell7Sh"  
	FillMeStr += "ell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.6165;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTyp"  
	FillMeStr += "e=2;Shell8BindEnergy=0.4105;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0."  
	FillMeStr += "4037;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.1076;Shell10NumXsect"  
	FillMeStr += "=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.0669;Shell11NumXsect=10;Shell12Shell=4P"  
	FillMeStr += "3/2;Shell12FuncType=2;Shell12BindEnergy=0.0669;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType"  
	FillMeStr += "=2;Shell13BindEnergy=0.0093;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnerg"  
	FillMeStr += "y=0.0093;Shell14NumXsect=10;"  
	string/g $("49")  
	SVAR FillMeStr = $("49")  
	FillMeStr = "SYM=IN;ETERM=-0.521;NSHELLS=14;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=27.9399;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=4.2375;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=3.938;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=3.7301;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.8256;Sh"  
	FillMeStr += "ell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.7022;Shell6NumXsect=10;Shell7S"  
	FillMeStr += "hell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.6643;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=2;Shell8BindEnergy=0.4508;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0"  
	FillMeStr += ".4431;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.1219;Shell10NumXsec"  
	FillMeStr += "t=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.0774;Shell11NumXsect=10;Shell12Shell=4"  
	FillMeStr += "P3/2;Shell12FuncType=2;Shell12BindEnergy=0.0774;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTyp"  
	FillMeStr += "e=2;Shell13BindEnergy=0.0162;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEner"  
	FillMeStr += "gy=0.0162;Shell14NumXsect=10;"  
	string/g $("50")  
	SVAR FillMeStr = $("50")  
	FillMeStr = "SYM=SN;ETERM=-0.547;NSHELLS=14;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=29.2001;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=4.4647;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=4.1561;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=3.9288;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.8838;S"  
	FillMeStr += "hell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.7564;Shell6NumXsect=10;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.7144;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncT"  
	FillMeStr += "ype=2;Shell8BindEnergy=0.4933;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy="  
	FillMeStr += "0.4848;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.1365;Shell10NumXse"  
	FillMeStr += "ct=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.0886;Shell11NumXsect=10;Shell12Shell="  
	FillMeStr += "4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.0886;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTy"  
	FillMeStr += "pe=2;Shell13BindEnergy=0.0239;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEne"  
	FillMeStr += "rgy=0.0239;Shell14NumXsect=10;"  
	string/g $("51")  
	SVAR FillMeStr = $("51")  
	FillMeStr = "SYM=SB;ETERM=-0.575;NSHELLS=14;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=30.4912;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=4.6983;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=4.3804;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=4.1322;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=2;Shell5BindEnergy=0.9437;S"  
	FillMeStr += "hell5NumXsect=10;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.8119;Shell6NumXsect=10;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.7656;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncT"  
	FillMeStr += "ype=2;Shell8BindEnergy=0.5369;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy="  
	FillMeStr += "0.5275;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.152;Shell10NumXsec"  
	FillMeStr += "t=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.0984;Shell11NumXsect=10;Shell12Shell=4"  
	FillMeStr += "P3/2;Shell12FuncType=2;Shell12BindEnergy=0.0984;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTyp"  
	FillMeStr += "e=2;Shell13BindEnergy=0.0314;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEner"  
	FillMeStr += "gy=0.0314;Shell14NumXsect=10;"  
	string/g $("52")  
	SVAR FillMeStr = $("52")  
	FillMeStr = "SYM=TE;ETERM=-0.602;NSHELLS=14;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=31.8138;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=4.9392;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=4.612;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=4.3414;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=1.006;She"  
	FillMeStr += "ll5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.8697;Shell6NumXsect=10;Shell7Sh"  
	FillMeStr += "ell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.8187;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTyp"  
	FillMeStr += "e=2;Shell8BindEnergy=0.5825;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0."  
	FillMeStr += "5721;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.1683;Shell10NumXsect"  
	FillMeStr += "=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.1102;Shell11NumXsect=10;Shell12Shell=4P"  
	FillMeStr += "3/2;Shell12FuncType=2;Shell12BindEnergy=0.1102;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType"  
	FillMeStr += "=2;Shell13BindEnergy=0.0398;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnerg"  
	FillMeStr += "y=0.0398;Shell14NumXsect=10;"  
	string/g $("53")  
	SVAR FillMeStr = $("53")  
	FillMeStr = "SYM=I;ETERM=-0.631;NSHELLS=14;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=33.1694;Shell1NumX"  
	FillMeStr += "sect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=5.1881;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=4.8521;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=4.5571;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=1.0721;Sh"  
	FillMeStr += "ell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.9305;Shell6NumXsect=10;Shell7S"  
	FillMeStr += "hell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.8746;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=2;Shell8BindEnergy=0.6313;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0"  
	FillMeStr += ".6194;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.1864;Shell10NumXsec"  
	FillMeStr += "t=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.1227;Shell11NumXsect=10;Shell12Shell=4"  
	FillMeStr += "P3/2;Shell12FuncType=2;Shell12BindEnergy=0.1227;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTyp"  
	FillMeStr += "e=2;Shell13BindEnergy=0.0496;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEner"  
	FillMeStr += "gy=0.0496;Shell14NumXsect=10;"  
	string/g $("54")  
	SVAR FillMeStr = $("54")  
	FillMeStr = "SYM=XE;ETERM=-0.66;NSHELLS=14;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=34.5614;Shell1NumX"  
	FillMeStr += "sect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=5.4528;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=5.1037;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=4.7822;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=1.1446;Sh"  
	FillMeStr += "ell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=2;Shell6BindEnergy=0.999;Shell6NumXsect=10;Shell7Sh"  
	FillMeStr += "ell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.937;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncType"  
	FillMeStr += "=2;Shell8BindEnergy=0.6854;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0.6"  
	FillMeStr += "723;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.2081;Shell10NumXsect="  
	FillMeStr += "10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.1467;Shell11NumXsect=10;Shell12Shell=4P3"  
	FillMeStr += "/2;Shell12FuncType=2;Shell12BindEnergy=0.1467;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType="  
	FillMeStr += "2;Shell13BindEnergy=0.064;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnergy="  
	FillMeStr += "0.064;Shell14NumXsect=10;"  
	string/g $("55")  
	SVAR FillMeStr = $("55")  
	FillMeStr = "SYM=CS;ETERM=-0.69;NSHELLS=17;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=35.9846;Shell1NumX"  
	FillMeStr += "sect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=5.7143;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=5.3594;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=5.0119;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=1.2171;Sh"  
	FillMeStr += "ell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=1.065;Shell6NumXsect=11;Shell7Sh"  
	FillMeStr += "ell=3P3/2;Shell7FuncType=2;Shell7BindEnergy=0.9976;Shell7NumXsect=10;Shell8Shell=3D3/2;Shell8FuncTyp"  
	FillMeStr += "e=2;Shell8BindEnergy=0.7395;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0."  
	FillMeStr += "7255;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.2308;Shell10NumXsect"  
	FillMeStr += "=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.1723;Shell11NumXsect=10;Shell12Shell=4P"  
	FillMeStr += "3/2;Shell12FuncType=2;Shell12BindEnergy=0.1616;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType"  
	FillMeStr += "=2;Shell13BindEnergy=0.0788;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnerg"  
	FillMeStr += "y=0.0765;Shell14NumXsect=10;Shell15Shell=5S1/2;Shell15FuncType=2;Shell15BindEnergy=0.0227;Shell15Num"  
	FillMeStr += "Xsect=10;Shell16Shell=5P1/2;Shell16FuncType=2;Shell16BindEnergy=0.0131;Shell16NumXsect=10;Shell17She"  
	FillMeStr += "ll=5P3/2;Shell17FuncType=2;Shell17BindEnergy=0.0114;Shell17NumXsect=10;"  
	string/g $("56")  
	SVAR FillMeStr = $("56")  
	FillMeStr = "SYM=BA;ETERM=-0.721;NSHELLS=17;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=37.4406;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=5.9888;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=5.6236;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=5.247;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=1.2928;Sh"  
	FillMeStr += "ell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=1.1367;Shell6NumXsect=11;Shell7S"  
	FillMeStr += "hell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=1.0622;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=2;Shell8BindEnergy=0.7961;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0"  
	FillMeStr += ".7807;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.253;Shell10NumXsect"  
	FillMeStr += "=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.1918;Shell11NumXsect=10;Shell12Shell=4P"  
	FillMeStr += "3/2;Shell12FuncType=2;Shell12BindEnergy=0.1797;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType"  
	FillMeStr += "=2;Shell13BindEnergy=0.0925;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnerg"  
	FillMeStr += "y=0.0899;Shell14NumXsect=10;Shell15Shell=5S1/2;Shell15FuncType=2;Shell15BindEnergy=0.0391;Shell15Num"  
	FillMeStr += "Xsect=10;Shell16Shell=5P1/2;Shell16FuncType=2;Shell16BindEnergy=0.0166;Shell16NumXsect=10;Shell17She"  
	FillMeStr += "ll=5P3/2;Shell17FuncType=2;Shell17BindEnergy=0.0146;Shell17NumXsect=10;"  
	string/g $("57")  
	SVAR FillMeStr = $("57")  
	FillMeStr = "SYM=LA;ETERM=-0.753;NSHELLS=17;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=38.9246;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=6.2663;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=5.8906;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=5.4827;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=1.3613;S"  
	FillMeStr += "hell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=1.2044;Shell6NumXsect=11;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=1.1234;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncT"  
	FillMeStr += "ype=2;Shell8BindEnergy=0.8485;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy="  
	FillMeStr += "0.8317;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.2704;Shell10NumXse"  
	FillMeStr += "ct=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.2058;Shell11NumXsect=10;Shell12Shell="  
	FillMeStr += "4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.1914;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTy"  
	FillMeStr += "pe=2;Shell13BindEnergy=0.0989;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEne"  
	FillMeStr += "rgy=0.0989;Shell14NumXsect=10;Shell15Shell=5S1/2;Shell15FuncType=2;Shell15BindEnergy=0.0323;Shell15N"  
	FillMeStr += "umXsect=10;Shell16Shell=5P1/2;Shell16FuncType=2;Shell16BindEnergy=0.0144;Shell16NumXsect=10;Shell17S"  
	FillMeStr += "hell=5P3/2;Shell17FuncType=2;Shell17BindEnergy=0.0144;Shell17NumXsect=10;"  
	string/g $("58")  
	SVAR FillMeStr = $("58")  
	FillMeStr = "SYM=CE;ETERM=-0.786;NSHELLS=18;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=40.443;Shell1NumX"  
	FillMeStr += "sect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=6.5488;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=6.1642;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=5.7234;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=1.4346;Sh"  
	FillMeStr += "ell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=1.2728;Shell6NumXsect=11;Shell7S"  
	FillMeStr += "hell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=1.1854;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=2;Shell8BindEnergy=0.9013;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0"  
	FillMeStr += ".8833;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.2896;Shell10NumXsec"  
	FillMeStr += "t=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.2233;Shell11NumXsect=10;Shell12Shell=4"  
	FillMeStr += "P3/2;Shell12FuncType=2;Shell12BindEnergy=0.2072;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTyp"  
	FillMeStr += "e=2;Shell13BindEnergy=0.11;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnergy"  
	FillMeStr += "=0.11;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0859;Shell15NumXse"  
	FillMeStr += "ct=10;Shell16Shell=5S1/2;Shell16FuncType=2;Shell16BindEnergy=0.0378;Shell16NumXsect=10;Shell17Shell="  
	FillMeStr += "5P1/2;Shell17FuncType=2;Shell17BindEnergy=0.0198;Shell17NumXsect=10;Shell18Shell=5P3/2;Shell18FuncTy"  
	FillMeStr += "pe=2;Shell18BindEnergy=0.0198;Shell18NumXsect=10;"  
	string/g $("59")  
	SVAR FillMeStr = $("59")  
	FillMeStr = "SYM=PR;ETERM=-0.819;NSHELLS=18;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=41.9906;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=6.8348;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=6.4404;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=5.9643;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=1.511;Sh"  
	FillMeStr += "ell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=1.3374;Shell6NumXsect=11;Shell7S"  
	FillMeStr += "hell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=1.2422;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=2;Shell8BindEnergy=0.9511;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0"  
	FillMeStr += ".931;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.3045;Shell10NumXsect"  
	FillMeStr += "=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.2363;Shell11NumXsect=10;Shell12Shell=4P"  
	FillMeStr += "3/2;Shell12FuncType=2;Shell12BindEnergy=0.2176;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType"  
	FillMeStr += "=2;Shell13BindEnergy=0.1132;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnerg"  
	FillMeStr += "y=0.1132;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0035;Shell15Num"  
	FillMeStr += "Xsect=10;Shell16Shell=5S1/2;Shell16FuncType=2;Shell16BindEnergy=0.0374;Shell16NumXsect=10;Shell17She"  
	FillMeStr += "ll=5P1/2;Shell17FuncType=2;Shell17BindEnergy=0.0223;Shell17NumXsect=10;Shell18Shell=5P3/2;Shell18Fun"  
	FillMeStr += "cType=2;Shell18BindEnergy=0.0223;Shell18NumXsect=10;"  
	string/g $("60")  
	SVAR FillMeStr = $("60")  
	FillMeStr = "SYM=ND;ETERM=-0.854;NSHELLS=18;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=43.5689;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=7.126;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=6.7215;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=6.2079;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=1.5753;Sh"  
	FillMeStr += "ell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=1.4028;Shell6NumXsect=11;Shell7S"  
	FillMeStr += "hell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=1.2974;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=2;Shell8BindEnergy=0.9995;Shell8NumXsect=10;Shell9Shell=3D5/2;Shell9FuncType=2;Shell9BindEnergy=0"  
	FillMeStr += ".9777;Shell9NumXsect=10;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.3152;Shell10NumXsec"  
	FillMeStr += "t=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.2433;Shell11NumXsect=10;Shell12Shell=4"  
	FillMeStr += "P3/2;Shell12FuncType=2;Shell12BindEnergy=0.2246;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTyp"  
	FillMeStr += "e=2;Shell13BindEnergy=0.1175;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEner"  
	FillMeStr += "gy=0.1175;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.003;Shell15Num"  
	FillMeStr += "Xsect=10;Shell16Shell=5S1/2;Shell16FuncType=2;Shell16BindEnergy=0.0375;Shell16NumXsect=10;Shell17She"  
	FillMeStr += "ll=5P1/2;Shell17FuncType=2;Shell17BindEnergy=0.0211;Shell17NumXsect=10;Shell18Shell=5P3/2;Shell18Fun"  
	FillMeStr += "cType=2;Shell18BindEnergy=0.0211;Shell18NumXsect=10;"  
	string/g $("61")  
	SVAR FillMeStr = $("61")  
	FillMeStr = "SYM=PM;ETERM=-0.889;NSHELLS=18;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=45.184;Shell1NumX"  
	FillMeStr += "sect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=7.4279;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=7.0128;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=6.4593;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=1.6465;Sh"  
	FillMeStr += "ell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=1.4714;Shell6NumXsect=11;Shell7S"  
	FillMeStr += "hell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=1.3569;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=0;Shell8BindEnergy=1.0515;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy=1"  
	FillMeStr += ".0269;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.3304;Shell10NumXsec"  
	FillMeStr += "t=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.2544;Shell11NumXsect=10;Shell12Shell=4"  
	FillMeStr += "P3/2;Shell12FuncType=2;Shell12BindEnergy=0.236;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType"  
	FillMeStr += "=2;Shell13BindEnergy=0.1204;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnerg"  
	FillMeStr += "y=0.1204;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.004;Shell15NumX"  
	FillMeStr += "sect=10;Shell16Shell=5S1/2;Shell16FuncType=2;Shell16BindEnergy=0.0375;Shell16NumXsect=10;Shell17Shel"  
	FillMeStr += "l=5P1/2;Shell17FuncType=2;Shell17BindEnergy=0.0211;Shell17NumXsect=10;Shell18Shell=5P3/2;Shell18Func"  
	FillMeStr += "Type=2;Shell18BindEnergy=0.0211;Shell18NumXsect=10;"  
	string/g $("62")  
	SVAR FillMeStr = $("62")  
	FillMeStr = "SYM=SM;ETERM=-0.925;NSHELLS=18;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=46.8342;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=7.7368;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=7.3118;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=6.7162;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=1.7228;S"  
	FillMeStr += "hell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=1.5407;Shell6NumXsect=11;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=1.4198;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncT"  
	FillMeStr += "ype=0;Shell8BindEnergy=1.106;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy=1"  
	FillMeStr += ".0802;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.3457;Shell10NumXsec"  
	FillMeStr += "t=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.2656;Shell11NumXsect=10;Shell12Shell=4"  
	FillMeStr += "P3/2;Shell12FuncType=2;Shell12BindEnergy=0.2474;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTyp"  
	FillMeStr += "e=2;Shell13BindEnergy=0.129;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnerg"  
	FillMeStr += "y=0.129;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0055;Shell15NumX"  
	FillMeStr += "sect=10;Shell16Shell=5S1/2;Shell16FuncType=2;Shell16BindEnergy=0.0374;Shell16NumXsect=10;Shell17Shel"  
	FillMeStr += "l=5P1/2;Shell17FuncType=2;Shell17BindEnergy=0.0213;Shell17NumXsect=10;Shell18Shell=5P3/2;Shell18Func"  
	FillMeStr += "Type=2;Shell18BindEnergy=0.0213;Shell18NumXsect=10;"  
	string/g $("63")  
	SVAR FillMeStr = $("63")  
	FillMeStr = "SYM=EU;ETERM=-0.962;NSHELLS=18;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=48.519;Shell1NumX"  
	FillMeStr += "sect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=8.052;Shell2NumXsect=11;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=0;Shell3BindEnergy=7.6171;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Shel"  
	FillMeStr += "l4BindEnergy=6.9769;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=1.8;Shell5"  
	FillMeStr += "NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=1.6139;Shell6NumXsect=11;Shell7Shell"  
	FillMeStr += "=3P3/2;Shell7FuncType=0;Shell7BindEnergy=1.4806;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncType=0"  
	FillMeStr += ";Shell8BindEnergy=1.1606;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy=1.130"  
	FillMeStr += "9;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.3602;Shell10NumXsect=10"  
	FillMeStr += ";Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.2839;Shell11NumXsect=10;Shell12Shell=4P3/2"  
	FillMeStr += ";Shell12FuncType=2;Shell12BindEnergy=0.2566;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType=2;"  
	FillMeStr += "Shell13BindEnergy=0.1332;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnergy=0"  
	FillMeStr += ".1332;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.00291151;Shell15Nu"  
	FillMeStr += "mXsect=10;Shell16Shell=5S1/2;Shell16FuncType=2;Shell16BindEnergy=0.0318;Shell16NumXsect=10;Shell17Sh"  
	FillMeStr += "ell=5P1/2;Shell17FuncType=2;Shell17BindEnergy=0.022;Shell17NumXsect=10;Shell18Shell=5P3/2;Shell18Fun"  
	FillMeStr += "cType=2;Shell18BindEnergy=0.022;Shell18NumXsect=10;"  
	string/g $("64")  
	SVAR FillMeStr = $("64")  
	FillMeStr = "SYM=GD;ETERM=-1;NSHELLS=19;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=50.2391;Shell1NumXsec"  
	FillMeStr += "t=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=8.3756;Shell2NumXsect=11;Shell3Shell=2P1/2;"  
	FillMeStr += "Shell3FuncType=0;Shell3BindEnergy=7.9303;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Shell4"  
	FillMeStr += "BindEnergy=7.2428;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=1.8808;Shell"  
	FillMeStr += "5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=1.6883;Shell6NumXsect=11;Shell7Shel"  
	FillMeStr += "l=3P3/2;Shell7FuncType=0;Shell7BindEnergy=1.544;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncType=0"  
	FillMeStr += ";Shell8BindEnergy=1.2172;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy=1.185"  
	FillMeStr += "2;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.3758;Shell10NumXsect=10"  
	FillMeStr += ";Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.2885;Shell11NumXsect=10;Shell12Shell=4P3/2"  
	FillMeStr += ";Shell12FuncType=2;Shell12BindEnergy=0.2709;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType=2;"  
	FillMeStr += "Shell13BindEnergy=0.1405;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnergy=0"  
	FillMeStr += ".1405;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0092794;Shell15Num"  
	FillMeStr += "Xsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.00852419;Shell16NumXsect=10;Shell1"  
	FillMeStr += "7Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.0361;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell1"  
	FillMeStr += "8FuncType=2;Shell18BindEnergy=0.0203;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19"  
	FillMeStr += "BindEnergy=0.0203;Shell19NumXsect=10;"  
	string/g $("65")  
	SVAR FillMeStr = $("65")  
	FillMeStr = "SYM=TB;ETERM=-1.039;NSHELLS=19;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=51.9957;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=8.708;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=8.2516;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=7.514;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=1.9675;She"  
	FillMeStr += "ll5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=1.7677;Shell6NumXsect=11;Shell7Sh"  
	FillMeStr += "ell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=1.6113;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncTyp"  
	FillMeStr += "e=0;Shell8BindEnergy=1.275;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy=1.2"  
	FillMeStr += "412;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.3979;Shell10NumXsect="  
	FillMeStr += "10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.3102;Shell11NumXsect=10;Shell12Shell=4P3"  
	FillMeStr += "/2;Shell12FuncType=2;Shell12BindEnergy=0.285;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType=2"  
	FillMeStr += ";Shell13BindEnergy=0.147;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnergy=0"  
	FillMeStr += ".147;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0094;Shell15NumXsec"  
	FillMeStr += "t=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.0086;Shell16NumXsect=10;Shell17Shell=5"  
	FillMeStr += "S1/2;Shell17FuncType=2;Shell17BindEnergy=0.039;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18FuncType"  
	FillMeStr += "=2;Shell18BindEnergy=0.0254;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19BindEnerg"  
	FillMeStr += "y=0.0254;Shell19NumXsect=10;"  
	string/g $("66")  
	SVAR FillMeStr = $("66")  
	FillMeStr = "SYM=DY;ETERM=-1.079;NSHELLS=19;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=53.7885;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=9.0458;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=8.5806;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=7.7901;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=2.0468;S"  
	FillMeStr += "hell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=1.8418;Shell6NumXsect=11;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=1.6756;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncT"  
	FillMeStr += "ype=0;Shell8BindEnergy=1.3325;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy="  
	FillMeStr += "1.2949;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.4163;Shell10NumXse"  
	FillMeStr += "ct=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.3318;Shell11NumXsect=10;Shell12Shell="  
	FillMeStr += "4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.2929;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTy"  
	FillMeStr += "pe=2;Shell13BindEnergy=0.1542;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEne"  
	FillMeStr += "rgy=0.1542;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0042;Shell15N"  
	FillMeStr += "umXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.0042;Shell16NumXsect=10;Shell17S"  
	FillMeStr += "hell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.0629;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18F"  
	FillMeStr += "uncType=2;Shell18BindEnergy=0.0263;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19Bi"  
	FillMeStr += "ndEnergy=0.0263;Shell19NumXsect=10;"  
	string/g $("67")  
	SVAR FillMeStr = $("67")  
	FillMeStr = "SYM=HO;ETERM=-1.119;NSHELLS=19;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=55.6177;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=9.3942;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=8.9178;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=8.0711;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=2.1283;S"  
	FillMeStr += "hell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=1.9228;Shell6NumXsect=11;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=1.7412;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncT"  
	FillMeStr += "ype=0;Shell8BindEnergy=1.3915;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy="  
	FillMeStr += "1.3514;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.4357;Shell10NumXse"  
	FillMeStr += "ct=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.3435;Shell11NumXsect=10;Shell12Shell="  
	FillMeStr += "4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.3066;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTy"  
	FillMeStr += "pe=2;Shell13BindEnergy=0.161;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEner"  
	FillMeStr += "gy=0.161;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0037;Shell15Num"  
	FillMeStr += "Xsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.0037;Shell16NumXsect=10;Shell17She"  
	FillMeStr += "ll=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.0512;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18Fun"  
	FillMeStr += "cType=2;Shell18BindEnergy=0.0203;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19Bind"  
	FillMeStr += "Energy=0.0203;Shell19NumXsect=10;"  
	string/g $("68")  
	SVAR FillMeStr = $("68")  
	FillMeStr = "SYM=ER;ETERM=-1.161;NSHELLS=19;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=57.4855;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=9.7513;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=9.2643;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=8.3579;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=2.2065;S"  
	FillMeStr += "hell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=2.0058;Shell6NumXsect=11;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=1.8118;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncT"  
	FillMeStr += "ype=0;Shell8BindEnergy=1.4533;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy="  
	FillMeStr += "1.4093;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.4491;Shell10NumXse"  
	FillMeStr += "ct=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.3662;Shell11NumXsect=10;Shell12Shell="  
	FillMeStr += "4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.32;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType"  
	FillMeStr += "=2;Shell13BindEnergy=0.1767;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnerg"  
	FillMeStr += "y=0.1676;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0043;Shell15Num"  
	FillMeStr += "Xsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.0043;Shell16NumXsect=10;Shell17She"  
	FillMeStr += "ll=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.0598;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18Fun"  
	FillMeStr += "cType=2;Shell18BindEnergy=0.0294;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19Bind"  
	FillMeStr += "Energy=0.0294;Shell19NumXsect=10;"  
	string/g $("69")  
	SVAR FillMeStr = $("69")  
	FillMeStr = "SYM=TM;ETERM=-1.204;NSHELLS=19;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=59.3896;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=10.1157;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=9.6169;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;S"  
	FillMeStr += "hell4BindEnergy=8.648;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=2.3068;S"  
	FillMeStr += "hell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=2.0898;Shell6NumXsect=11;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=1.8845;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncT"  
	FillMeStr += "ype=0;Shell8BindEnergy=1.5146;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy="  
	FillMeStr += "1.4677;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.4717;Shell10NumXse"  
	FillMeStr += "ct=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.3859;Shell11NumXsect=10;Shell12Shell="  
	FillMeStr += "4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.3366;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTy"  
	FillMeStr += "pe=2;Shell13BindEnergy=0.1796;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEne"  
	FillMeStr += "rgy=0.1796;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0053;Shell15N"  
	FillMeStr += "umXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.0053;Shell16NumXsect=10;Shell17S"  
	FillMeStr += "hell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.0532;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18F"  
	FillMeStr += "uncType=2;Shell18BindEnergy=0.0323;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19Bi"  
	FillMeStr += "ndEnergy=0.0323;Shell19NumXsect=10;"  
	string/g $("70")  
	SVAR FillMeStr = $("70")  
	FillMeStr = "SYM=YB;ETERM=-1.248;NSHELLS=19;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=61.3323;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=10.4864;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=9.9782;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;S"  
	FillMeStr += "hell4BindEnergy=8.9436;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=2.3981;"  
	FillMeStr += "Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=2.173;Shell6NumXsect=11;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=1.9498;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncT"  
	FillMeStr += "ype=0;Shell8BindEnergy=1.5763;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy="  
	FillMeStr += "1.5278;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.4872;Shell10NumXse"  
	FillMeStr += "ct=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.3967;Shell11NumXsect=10;Shell12Shell="  
	FillMeStr += "4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.3435;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTy"  
	FillMeStr += "pe=2;Shell13BindEnergy=0.1981;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEne"  
	FillMeStr += "rgy=0.1849;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0063;Shell15N"  
	FillMeStr += "umXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.0063;Shell16NumXsect=10;Shell17S"  
	FillMeStr += "hell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.0541;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18F"  
	FillMeStr += "uncType=2;Shell18BindEnergy=0.0234;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19Bi"  
	FillMeStr += "ndEnergy=0.0234;Shell19NumXsect=10;"  
	string/g $("71")  
	SVAR FillMeStr = $("71")  
	FillMeStr = "SYM=LU;ETERM=-1.293;NSHELLS=19;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=63.3138;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=10.8704;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=10.3486;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;"  
	FillMeStr += "Shell4BindEnergy=9.2441;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=2.4912"  
	FillMeStr += ";Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=2.2635;Shell6NumXsect=11;Shel"  
	FillMeStr += "l7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=2.0236;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8Fun"  
	FillMeStr += "cType=0;Shell8BindEnergy=1.6394;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnerg"  
	FillMeStr += "y=1.5885;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.5062;Shell10NumX"  
	FillMeStr += "sect=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.4101;Shell11NumXsect=10;Shell12Shel"  
	FillMeStr += "l=4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.3593;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13Func"  
	FillMeStr += "Type=2;Shell13BindEnergy=0.2048;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindE"  
	FillMeStr += "nergy=0.195;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0069;Shell15"  
	FillMeStr += "NumXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.0069;Shell16NumXsect=10;Shell17"  
	FillMeStr += "Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.0568;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18"  
	FillMeStr += "FuncType=2;Shell18BindEnergy=0.028;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19Bi"  
	FillMeStr += "ndEnergy=0.028;Shell19NumXsect=10;"  
	string/g $("72")  
	SVAR FillMeStr = $("72")  
	FillMeStr = "SYM=HF;ETERM=-1.338;NSHELLS=20;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=65.3508;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=11.2707;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=10.7394;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;"  
	FillMeStr += "Shell4BindEnergy=9.5607;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=2.6009"  
	FillMeStr += ";Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=2.3654;Shell6NumXsect=11;Shel"  
	FillMeStr += "l7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=2.1076;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8Fun"  
	FillMeStr += "cType=0;Shell8BindEnergy=1.7164;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnerg"  
	FillMeStr += "y=1.6617;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.5381;Shell10NumX"  
	FillMeStr += "sect=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.437;Shell11NumXsect=10;Shell12Shell"  
	FillMeStr += "=4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.3804;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncT"  
	FillMeStr += "ype=2;Shell13BindEnergy=0.2238;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEn"  
	FillMeStr += "ergy=0.2137;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0171;Shell15"  
	FillMeStr += "NumXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.0171;Shell16NumXsect=10;Shell17"  
	FillMeStr += "Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.0649;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18"  
	FillMeStr += "FuncType=2;Shell18BindEnergy=0.0381;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19B"  
	FillMeStr += "indEnergy=0.0306;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.005;She"  
	FillMeStr += "ll20NumXsect=10;"  
	string/g $("73")  
	SVAR FillMeStr = $("73")  
	FillMeStr = "SYM=TA;ETERM=-1.385;NSHELLS=20;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=67.4164;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=11.6815;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=11.1361;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;"  
	FillMeStr += "Shell4BindEnergy=9.8811;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=2.708;"  
	FillMeStr += "Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=2.4687;Shell6NumXsect=11;Shell"  
	FillMeStr += "7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=2.194;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncT"  
	FillMeStr += "ype=0;Shell8BindEnergy=1.7932;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy="  
	FillMeStr += "1.7351;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.5655;Shell10NumXse"  
	FillMeStr += "ct=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.4648;Shell11NumXsect=10;Shell12Shell="  
	FillMeStr += "4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.4045;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTy"  
	FillMeStr += "pe=2;Shell13BindEnergy=0.2413;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEne"  
	FillMeStr += "rgy=0.2293;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.025;Shell15Nu"  
	FillMeStr += "mXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.025;Shell16NumXsect=10;Shell17She"  
	FillMeStr += "ll=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.0711;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18Fun"  
	FillMeStr += "cType=2;Shell18BindEnergy=0.0449;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19Bind"  
	FillMeStr += "Energy=0.0364;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.0057;Shell"  
	FillMeStr += "20NumXsect=10;"  
	string/g $("74")  
	SVAR FillMeStr = $("74")  
	FillMeStr = "SYM=W;ETERM=-1.433;NSHELLS=20;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=69.525;Shell1NumXs"  
	FillMeStr += "ect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=12.0998;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=11.544;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=10.2068;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=2.8196;S"  
	FillMeStr += "hell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=2.5749;Shell6NumXsect=11;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=2.281;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=0;Shell8BindEnergy=1.8716;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy=1"  
	FillMeStr += ".8092;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.595;Shell10NumXsect"  
	FillMeStr += "=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.4916;Shell11NumXsect=10;Shell12Shell=4P"  
	FillMeStr += "3/2;Shell12FuncType=2;Shell12BindEnergy=0.4253;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType"  
	FillMeStr += "=2;Shell13BindEnergy=0.2588;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnerg"  
	FillMeStr += "y=0.2454;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0365;Shell15Num"  
	FillMeStr += "Xsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.0336;Shell16NumXsect=10;Shell17She"  
	FillMeStr += "ll=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.0771;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18Fun"  
	FillMeStr += "cType=2;Shell18BindEnergy=0.0468;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19Bind"  
	FillMeStr += "Energy=0.0356;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.0061;Shell"  
	FillMeStr += "20NumXsect=10;"  
	string/g $("75")  
	SVAR FillMeStr = $("75")  
	FillMeStr = "SYM=RE;ETERM=-1.482;NSHELLS=21;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=71.6764;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=12.5267;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=11.9587;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;"  
	FillMeStr += "Shell4BindEnergy=10.5353;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=2.931"  
	FillMeStr += "7;Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=2.6816;Shell6NumXsect=11;She"  
	FillMeStr += "ll7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=2.3673;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8Fu"  
	FillMeStr += "ncType=0;Shell8BindEnergy=1.9489;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEner"  
	FillMeStr += "gy=1.8829;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.625;Shell10NumX"  
	FillMeStr += "sect=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.5179;Shell11NumXsect=10;Shell12Shel"  
	FillMeStr += "l=4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.4444;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13Func"  
	FillMeStr += "Type=2;Shell13BindEnergy=0.2737;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindE"  
	FillMeStr += "nergy=0.2602;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0406;Shell1"  
	FillMeStr += "5NumXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.0406;Shell16NumXsect=10;Shell1"  
	FillMeStr += "7Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.0828;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell1"  
	FillMeStr += "8FuncType=2;Shell18BindEnergy=0.0456;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19"  
	FillMeStr += "BindEnergy=0.0346;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.006062"  
	FillMeStr += "67;Shell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.00520913;Shell21NumXs"  
	FillMeStr += "ect=10;"  
	string/g $("76")  
	SVAR FillMeStr = $("76")  
	FillMeStr = "SYM=OS;ETERM=-1.532;NSHELLS=21;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=73.8708;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=12.968;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=12.385;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=10.8709;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=3.0485;"  
	FillMeStr += "Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=2.7922;Shell6NumXsect=11;Shell"  
	FillMeStr += "7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=2.4572;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8Func"  
	FillMeStr += "Type=0;Shell8BindEnergy=2.0308;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy"  
	FillMeStr += "=1.9601;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.6543;Shell10NumXs"  
	FillMeStr += "ect=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.5465;Shell11NumXsect=10;Shell12Shell"  
	FillMeStr += "=4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.4682;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncT"  
	FillMeStr += "ype=2;Shell13BindEnergy=0.2894;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEn"  
	FillMeStr += "ergy=0.2728;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0463;Shell15"  
	FillMeStr += "NumXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.0463;Shell16NumXsect=10;Shell17"  
	FillMeStr += "Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.0837;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18"  
	FillMeStr += "FuncType=2;Shell18BindEnergy=0.058;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19Bi"  
	FillMeStr += "ndEnergy=0.0454;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.00705265"  
	FillMeStr += ";Shell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.00602794;Shell21NumXsec"  
	FillMeStr += "t=10;"  
	string/g $("77")  
	SVAR FillMeStr = $("77")  
	FillMeStr = "SYM=IR;ETERM=-1.583;NSHELLS=21;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=76.111;Shell1NumX"  
	FillMeStr += "sect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=13.4185;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=12.8241;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;S"  
	FillMeStr += "hell4BindEnergy=11.2152;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=3.1737"  
	FillMeStr += ";Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=2.9087;Shell6NumXsect=11;Shel"  
	FillMeStr += "l7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=2.5507;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8Fun"  
	FillMeStr += "cType=0;Shell8BindEnergy=2.1161;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnerg"  
	FillMeStr += "y=2.0404;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.6901;Shell10NumX"  
	FillMeStr += "sect=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.5771;Shell11NumXsect=10;Shell12Shel"  
	FillMeStr += "l=4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.4943;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13Func"  
	FillMeStr += "Type=2;Shell13BindEnergy=0.3114;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindE"  
	FillMeStr += "nergy=0.2949;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0634;Shell1"  
	FillMeStr += "5NumXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.0605;Shell16NumXsect=10;Shell1"  
	FillMeStr += "7Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.0952;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell1"  
	FillMeStr += "8FuncType=2;Shell18BindEnergy=0.063;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19B"  
	FillMeStr += "indEnergy=0.0505;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.0080627"  
	FillMeStr += "4;Shell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.00685456;Shell21NumXse"  
	FillMeStr += "ct=10;"  
	string/g $("78")  
	SVAR FillMeStr = $("78")  
	FillMeStr = "SYM=PT;ETERM=-1.636;NSHELLS=21;Shell1Shell=1S1/2;Shell1FuncType=0;Shell1BindEnergy=78.3948;Shell1Num"  
	FillMeStr += "Xsect=11;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=13.8799;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=13.2726;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;"  
	FillMeStr += "Shell4BindEnergy=11.5637;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=3.296"  
	FillMeStr += ";Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=3.0265;Shell6NumXsect=11;Shel"  
	FillMeStr += "l7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=2.6454;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8Fun"  
	FillMeStr += "cType=0;Shell8BindEnergy=2.2019;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnerg"  
	FillMeStr += "y=2.1216;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.722;Shell10NumXs"  
	FillMeStr += "ect=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.6092;Shell11NumXsect=10;Shell12Shell"  
	FillMeStr += "=4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.519;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTy"  
	FillMeStr += "pe=2;Shell13BindEnergy=0.3308;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEne"  
	FillMeStr += "rgy=0.3133;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0743;Shell15N"  
	FillMeStr += "umXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.0711;Shell16NumXsect=10;Shell17S"  
	FillMeStr += "hell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.1017;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18F"  
	FillMeStr += "uncType=2;Shell18BindEnergy=0.0653;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19Bi"  
	FillMeStr += "ndEnergy=0.0517;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.00743991"  
	FillMeStr += ";Shell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.00612538;Shell21NumXsec"  
	FillMeStr += "t=10;"  
	string/g $("79")  
	SVAR FillMeStr = $("79")  
	FillMeStr = "SYM=AU;ETERM=-1.689;NSHELLS=21;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=80.7249;Shell1Num"  
	FillMeStr += "Xsect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=14.3528;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=13.7336;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;"  
	FillMeStr += "Shell4BindEnergy=11.9187;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=3.424"  
	FillMeStr += "9;Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=3.1478;Shell6NumXsect=11;She"  
	FillMeStr += "ll7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=2.743;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8Fun"  
	FillMeStr += "cType=0;Shell8BindEnergy=2.2911;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnerg"  
	FillMeStr += "y=2.2057;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.7588;Shell10NumX"  
	FillMeStr += "sect=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.6437;Shell11NumXsect=10;Shell12Shel"  
	FillMeStr += "l=4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.5454;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13Func"  
	FillMeStr += "Type=2;Shell13BindEnergy=0.352;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEn"  
	FillMeStr += "ergy=0.3339;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.0864;Shell15"  
	FillMeStr += "NumXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.0828;Shell16NumXsect=10;Shell17"  
	FillMeStr += "Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.1078;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18"  
	FillMeStr += "FuncType=2;Shell18BindEnergy=0.0717;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19B"  
	FillMeStr += "indEnergy=0.0537;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.0083083"  
	FillMeStr += "9;Shell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.00679032;Shell21NumXse"  
	FillMeStr += "ct=10;"  
	string/g $("80")  
	SVAR FillMeStr = $("80")  
	FillMeStr = "SYM=HG;ETERM=-1.743;NSHELLS=22;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=83.1023;Shell1Num"  
	FillMeStr += "Xsect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=14.8393;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=14.2087;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;"  
	FillMeStr += "Shell4BindEnergy=12.2839;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=3.561"  
	FillMeStr += "6;Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=3.2785;Shell6NumXsect=11;She"  
	FillMeStr += "ll7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=2.8471;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8Fu"  
	FillMeStr += "ncType=0;Shell8BindEnergy=2.3849;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEner"  
	FillMeStr += "gy=2.2949;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.8003;Shell10Num"  
	FillMeStr += "Xsect=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.6769;Shell11NumXsect=10;Shell12She"  
	FillMeStr += "ll=4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.571;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13Func"  
	FillMeStr += "Type=2;Shell13BindEnergy=0.3783;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindE"  
	FillMeStr += "nergy=0.3598;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.1022;Shell1"  
	FillMeStr += "5NumXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.0985;Shell16NumXsect=10;Shell1"  
	FillMeStr += "7Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.1203;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell1"  
	FillMeStr += "8FuncType=2;Shell18BindEnergy=0.0805;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19"  
	FillMeStr += "BindEnergy=0.0576;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.0064;S"  
	FillMeStr += "hell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.0064;Shell21NumXsect=10;S"  
	FillMeStr += "hell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.00771361;Shell22NumXsect=10;"  
	string/g $("81")  
	SVAR FillMeStr = $("81")  
	FillMeStr = "SYM=TL;ETERM=-1.799;NSHELLS=22;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=85.5304;Shell1Num"  
	FillMeStr += "Xsect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=15.3467;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=14.6979;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;"  
	FillMeStr += "Shell4BindEnergy=12.6575;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=3.704"  
	FillMeStr += "1;Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=3.4157;Shell6NumXsect=11;She"  
	FillMeStr += "ll7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=2.9566;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8Fu"  
	FillMeStr += "ncType=0;Shell8BindEnergy=2.4851;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEner"  
	FillMeStr += "gy=2.3893;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.8455;Shell10Num"  
	FillMeStr += "Xsect=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.7213;Shell11NumXsect=10;Shell12She"  
	FillMeStr += "ll=4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.609;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13Func"  
	FillMeStr += "Type=2;Shell13BindEnergy=0.4066;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindE"  
	FillMeStr += "nergy=0.3862;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.1228;Shell1"  
	FillMeStr += "5NumXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.1185;Shell16NumXsect=10;Shell1"  
	FillMeStr += "7Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.1363;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell1"  
	FillMeStr += "8FuncType=2;Shell18BindEnergy=0.0996;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19"  
	FillMeStr += "BindEnergy=0.0754;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.0153;S"  
	FillMeStr += "hell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.0131;Shell21NumXsect=10;S"  
	FillMeStr += "hell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.00966483;Shell22NumXsect=10;"  
	string/g $("82")  
	SVAR FillMeStr = $("82")  
	FillMeStr = "SYM=PB;ETERM=-1.856;NSHELLS=23;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=88.0045;Shell1Num"  
	FillMeStr += "Xsect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=15.8608;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=15.2;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=13.0352;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=3.8507;S"  
	FillMeStr += "hell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=3.5542;Shell6NumXsect=11;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=3.0664;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncT"  
	FillMeStr += "ype=0;Shell8BindEnergy=2.5856;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy="  
	FillMeStr += "2.484;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.8936;Shell10NumXsec"  
	FillMeStr += "t=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.7639;Shell11NumXsect=10;Shell12Shell=4"  
	FillMeStr += "P3/2;Shell12FuncType=2;Shell12BindEnergy=0.6445;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncTyp"  
	FillMeStr += "e=2;Shell13BindEnergy=0.4352;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEner"  
	FillMeStr += "gy=0.4129;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.1429;Shell15Nu"  
	FillMeStr += "mXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.1381;Shell16NumXsect=10;Shell17Sh"  
	FillMeStr += "ell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.1473;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18Fu"  
	FillMeStr += "ncType=2;Shell18BindEnergy=0.1048;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19Bin"  
	FillMeStr += "dEnergy=0.086;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.0218;Shell"  
	FillMeStr += "20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.0192;Shell21NumXsect=10;Shell"  
	FillMeStr += "22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.0116904;Shell22NumXsect=10;Shell23Shell=6P1/2;Sh"  
	FillMeStr += "ell23FuncType=2;Shell23BindEnergy=0.00491166;Shell23NumXsect=10;"  
	string/g $("83")  
	SVAR FillMeStr = $("83")  
	FillMeStr = "SYM=BI;ETERM=-1.914;NSHELLS=23;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=90.5259;Shell1Num"  
	FillMeStr += "Xsect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=16.3875;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=15.7111;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;"  
	FillMeStr += "Shell4BindEnergy=13.4186;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=3.999"  
	FillMeStr += "1;Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=3.6963;Shell6NumXsect=11;She"  
	FillMeStr += "ll7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=3.1769;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8Fu"  
	FillMeStr += "ncType=0;Shell8BindEnergy=2.6876;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEner"  
	FillMeStr += "gy=2.5796;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.9382;Shell10Num"  
	FillMeStr += "Xsect=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.8053;Shell11NumXsect=10;Shell12She"  
	FillMeStr += "ll=4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.6789;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13Fun"  
	FillMeStr += "cType=2;Shell13BindEnergy=0.4636;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14Bind"  
	FillMeStr += "Energy=0.44;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.1619;Shell15"  
	FillMeStr += "NumXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.1574;Shell16NumXsect=10;Shell17"  
	FillMeStr += "Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.1593;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18"  
	FillMeStr += "FuncType=2;Shell18BindEnergy=0.1168;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19B"  
	FillMeStr += "indEnergy=0.0928;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.0265;Sh"  
	FillMeStr += "ell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.0244;Shell21NumXsect=10;Sh"  
	FillMeStr += "ell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.0142334;Shell22NumXsect=10;Shell23Shell=6P1/2"  
	FillMeStr += ";Shell23FuncType=2;Shell23BindEnergy=0.00616991;Shell23NumXsect=10;"  
	string/g $("84")  
	SVAR FillMeStr = $("84")  
	FillMeStr = "SYM=PO;ETERM=-1.973;NSHELLS=24;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=93.105;Shell1NumX"  
	FillMeStr += "sect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=16.9393;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=16.2443;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;S"  
	FillMeStr += "hell4BindEnergy=13.8138;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=4.1494"  
	FillMeStr += ";Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=3.8541;Shell6NumXsect=11;Shel"  
	FillMeStr += "l7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=3.3019;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8Fun"  
	FillMeStr += "cType=0;Shell8BindEnergy=2.798;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy"  
	FillMeStr += "=2.683;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=2;Shell10BindEnergy=0.9953;Shell10NumXse"  
	FillMeStr += "ct=10;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.851;Shell11NumXsect=10;Shell12Shell=4"  
	FillMeStr += "P3/2;Shell12FuncType=2;Shell12BindEnergy=0.705;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType"  
	FillMeStr += "=2;Shell13BindEnergy=0.5002;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnerg"  
	FillMeStr += "y=0.4734;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.175344;Shell15N"  
	FillMeStr += "umXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.169362;Shell16NumXsect=10;Shell1"  
	FillMeStr += "7Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.170906;Shell17NumXsect=10;Shell18Shell=5P1/2;Shel"  
	FillMeStr += "l18FuncType=2;Shell18BindEnergy=0.125695;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;She"  
	FillMeStr += "ll19BindEnergy=0.0983141;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0"  
	FillMeStr += ".0314;Shell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.0314;Shell21NumXse"  
	FillMeStr += "ct=10;Shell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.0167777;Shell22NumXsect=10;Shell23She"  
	FillMeStr += "ll=6P1/2;Shell23FuncType=2;Shell23BindEnergy=0.00755974;Shell23NumXsect=10;Shell24Shell=6P3/2;Shell2"  
	FillMeStr += "4FuncType=2;Shell24BindEnergy=0.00539477;Shell24NumXsect=10;"  
	string/g $("85")  
	SVAR FillMeStr = $("85")  
	FillMeStr = "SYM=AT;ETERM=-2.033;NSHELLS=24;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=95.7299;Shell1Num"  
	FillMeStr += "Xsect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=17.493;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=16.7847;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;S"  
	FillMeStr += "hell4BindEnergy=14.2135;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=4.317;"  
	FillMeStr += "Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=4.008;Shell6NumXsect=11;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=3.426;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=0;Shell8BindEnergy=2.9087;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy=2"  
	FillMeStr += ".7867;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=0;Shell10BindEnergy=1.042;Shell10NumXsect"  
	FillMeStr += "=11;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.886;Shell11NumXsect=10;Shell12Shell=4P3"  
	FillMeStr += "/2;Shell12FuncType=2;Shell12BindEnergy=0.74;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType=2;"  
	FillMeStr += "Shell13BindEnergy=0.5332;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnergy=0"  
	FillMeStr += ".475385;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.197076;Shell15Nu"  
	FillMeStr += "mXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.190577;Shell16NumXsect=10;Shell17"  
	FillMeStr += "Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.185617;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell"  
	FillMeStr += "18FuncType=2;Shell18BindEnergy=0.138499;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shel"  
	FillMeStr += "l19BindEnergy=0.108426;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.0"  
	FillMeStr += "415942;Shell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.0376618;Shell21Nu"  
	FillMeStr += "mXsect=10;Shell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.019339;Shell22NumXsect=10;Shell23"  
	FillMeStr += "Shell=6P1/2;Shell23FuncType=2;Shell23BindEnergy=0.00903104;Shell23NumXsect=10;Shell24Shell=6P3/2;She"  
	FillMeStr += "ll24FuncType=2;Shell24BindEnergy=0.0062445;Shell24NumXsect=10;"  
	string/g $("86")  
	SVAR FillMeStr = $("86")  
	FillMeStr = "SYM=RN;ETERM=-2.095;NSHELLS=24;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=98.404;Shell1NumX"  
	FillMeStr += "sect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=18.049;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=17.3371;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=14.6194;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=4.482;S"  
	FillMeStr += "hell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=4.159;Shell6NumXsect=11;Shell7S"  
	FillMeStr += "hell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=3.538;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncTyp"  
	FillMeStr += "e=0;Shell8BindEnergy=3.0215;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy=2."  
	FillMeStr += "8924;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=0;Shell10BindEnergy=1.097;Shell10NumXsect="  
	FillMeStr += "11;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.929;Shell11NumXsect=10;Shell12Shell=4P3/"  
	FillMeStr += "2;Shell12FuncType=2;Shell12BindEnergy=0.768;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType=2;"  
	FillMeStr += "Shell13BindEnergy=0.5666;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnergy=0"  
	FillMeStr += ".537;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.219631;Shell15NumXs"  
	FillMeStr += "ect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.212588;Shell16NumXsect=10;Shell17She"  
	FillMeStr += "ll=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.200831;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18F"  
	FillMeStr += "uncType=2;Shell18BindEnergy=0.151771;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19"  
	FillMeStr += "BindEnergy=0.118817;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.0486"  
	FillMeStr += "912;Shell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.044255;Shell21NumXse"  
	FillMeStr += "ct=10;Shell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.0219397;Shell22NumXsect=10;Shell23She"  
	FillMeStr += "ll=6P1/2;Shell23FuncType=2;Shell23BindEnergy=0.0105726;Shell23NumXsect=10;Shell24Shell=6P3/2;Shell24"  
	FillMeStr += "FuncType=2;Shell24BindEnergy=0.00712588;Shell24NumXsect=10;"  
	string/g $("87")  
	SVAR FillMeStr = $("87")  
	FillMeStr = "SYM=FR;ETERM=-2.157;NSHELLS=24;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=101.137;Shell1Num"  
	FillMeStr += "Xsect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=18.639;Shell2NumXsect=11;Shell3Shell=2P"  
	FillMeStr += "1/2;Shell3FuncType=0;Shell3BindEnergy=17.9065;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;S"  
	FillMeStr += "hell4BindEnergy=15.0312;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=4.652;"  
	FillMeStr += "Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=4.327;Shell6NumXsect=11;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=3.663;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncTy"  
	FillMeStr += "pe=0;Shell8BindEnergy=3.1362;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy=2"  
	FillMeStr += ".9997;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=0;Shell10BindEnergy=1.153;Shell10NumXsect"  
	FillMeStr += "=11;Shell11Shell=4P1/2;Shell11FuncType=2;Shell11BindEnergy=0.98;Shell11NumXsect=10;Shell12Shell=4P3/"  
	FillMeStr += "2;Shell12FuncType=2;Shell12BindEnergy=0.81;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType=2;S"  
	FillMeStr += "hell13BindEnergy=0.6033;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnergy=0."  
	FillMeStr += "577;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.246488;Shell15NumXse"  
	FillMeStr += "ct=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.238863;Shell16NumXsect=10;Shell17Shel"  
	FillMeStr += "l=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.220035;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18Fu"  
	FillMeStr += "ncType=2;Shell18BindEnergy=0.169009;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19B"  
	FillMeStr += "indEnergy=0.132957;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.05953"  
	FillMeStr += "78;Shell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.0545529;Shell21NumXse"  
	FillMeStr += "ct=10;Shell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.0278679;Shell22NumXsect=10;Shell23She"  
	FillMeStr += "ll=6P1/2;Shell23FuncType=2;Shell23BindEnergy=0.015165;Shell23NumXsect=10;Shell24Shell=6P3/2;Shell24F"  
	FillMeStr += "uncType=2;Shell24BindEnergy=0.0106123;Shell24NumXsect=10;"  
	string/g $("88")  
	SVAR FillMeStr = $("88")  
	FillMeStr = "SYM=RA;ETERM=-2.221;NSHELLS=24;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=103.922;Shell1Num"  
	FillMeStr += "Xsect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=19.2367;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=18.4843;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;"  
	FillMeStr += "Shell4BindEnergy=15.4444;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=4.822"  
	FillMeStr += ";Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=4.4895;Shell6NumXsect=11;Shel"  
	FillMeStr += "l7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=3.7918;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8Fun"  
	FillMeStr += "cType=0;Shell8BindEnergy=3.2484;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnerg"  
	FillMeStr += "y=3.1049;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=0;Shell10BindEnergy=1.2084;Shell10NumX"  
	FillMeStr += "sect=11;Shell11Shell=4P1/2;Shell11FuncType=0;Shell11BindEnergy=1.0576;Shell11NumXsect=11;Shell12Shel"  
	FillMeStr += "l=4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.8791;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13Func"  
	FillMeStr += "Type=2;Shell13BindEnergy=0.6359;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindE"  
	FillMeStr += "nergy=0.6027;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.2989;Shell1"  
	FillMeStr += "5NumXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.2989;Shell16NumXsect=10;Shell1"  
	FillMeStr += "7Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.2544;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell1"  
	FillMeStr += "8FuncType=2;Shell18BindEnergy=0.2004;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19"  
	FillMeStr += "BindEnergy=0.1528;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.0672;S"  
	FillMeStr += "hell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.0672;Shell21NumXsect=10;S"  
	FillMeStr += "hell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.0435;Shell22NumXsect=10;Shell23Shell=6P1/2;S"  
	FillMeStr += "hell23FuncType=2;Shell23BindEnergy=0.0188;Shell23NumXsect=10;Shell24Shell=6P3/2;Shell24FuncType=2;Sh"  
	FillMeStr += "ell24BindEnergy=0.0188;Shell24NumXsect=10;"  
	string/g $("89")  
	SVAR FillMeStr = $("89")  
	FillMeStr = "SYM=AC;ETERM=-2.287;NSHELLS=24;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=106.755;Shell1Num"  
	FillMeStr += "Xsect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=19.84;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=19.0832;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=15.871;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=5.002;Sh"  
	FillMeStr += "ell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=4.656;Shell6NumXsect=11;Shell7Sh"  
	FillMeStr += "ell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=3.909;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncType"  
	FillMeStr += "=0;Shell8BindEnergy=3.3702;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy=3.2"  
	FillMeStr += "19;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=0;Shell10BindEnergy=1.269;Shell10NumXsect=11"  
	FillMeStr += ";Shell11Shell=4P1/2;Shell11FuncType=0;Shell11BindEnergy=1.08;Shell11NumXsect=11;Shell12Shell=4P3/2;S"  
	FillMeStr += "hell12FuncType=2;Shell12BindEnergy=0.89;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13FuncType=2;Shel"  
	FillMeStr += "l13BindEnergy=0.6749;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnergy=0.637"  
	FillMeStr += ";Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.303944;Shell15NumXsect="  
	FillMeStr += "10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.295067;Shell16NumXsect=10;Shell17Shell=5"  
	FillMeStr += "S1/2;Shell17FuncType=2;Shell17BindEnergy=0.261255;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18FuncT"  
	FillMeStr += "ype=2;Shell18BindEnergy=0.206171;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19Bind"  
	FillMeStr += "Energy=0.163234;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.0831361;"  
	FillMeStr += "Shell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.0769389;Shell21NumXsect="  
	FillMeStr += "10;Shell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.0404636;Shell22NumXsect=10;Shell23Shell="  
	FillMeStr += "6P1/2;Shell23FuncType=2;Shell23BindEnergy=0.0251851;Shell23NumXsect=10;Shell24Shell=6P3/2;Shell24Fun"  
	FillMeStr += "cType=2;Shell24BindEnergy=0.0184021;Shell24NumXsect=10;"  
	string/g $("90")  
	SVAR FillMeStr = $("90")  
	FillMeStr = "SYM=TH;ETERM=-2.353;NSHELLS=24;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=109.651;Shell1Num"  
	FillMeStr += "Xsect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=20.4721;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=19.6932;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;"  
	FillMeStr += "Shell4BindEnergy=16.3003;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=5.182"  
	FillMeStr += "3;Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=4.8304;Shell6NumXsect=11;She"  
	FillMeStr += "ll7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=4.0461;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8Fu"  
	FillMeStr += "ncType=0;Shell8BindEnergy=3.4908;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEner"  
	FillMeStr += "gy=3.332;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=0;Shell10BindEnergy=1.3295;Shell10NumX"  
	FillMeStr += "sect=11;Shell11Shell=4P1/2;Shell11FuncType=0;Shell11BindEnergy=1.1682;Shell11NumXsect=11;Shell12Shel"  
	FillMeStr += "l=4P3/2;Shell12FuncType=2;Shell12BindEnergy=0.9673;Shell12NumXsect=10;Shell13Shell=4D3/2;Shell13Func"  
	FillMeStr += "Type=2;Shell13BindEnergy=0.7141;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindE"  
	FillMeStr += "nergy=0.6764;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.3444;Shell1"  
	FillMeStr += "5NumXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.3352;Shell16NumXsect=10;Shell1"  
	FillMeStr += "7Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.2902;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell1"  
	FillMeStr += "8FuncType=2;Shell18BindEnergy=0.2294;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19"  
	FillMeStr += "BindEnergy=0.1818;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.0943;S"  
	FillMeStr += "hell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.0879;Shell21NumXsect=10;S"  
	FillMeStr += "hell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.0595;Shell22NumXsect=10;Shell23Shell=6P1/2;S"  
	FillMeStr += "hell23FuncType=2;Shell23BindEnergy=0.049;Shell23NumXsect=10;Shell24Shell=6P3/2;Shell24FuncType=2;She"  
	FillMeStr += "ll24BindEnergy=0.043;Shell24NumXsect=10;"  
	string/g $("91")  
	SVAR FillMeStr = $("91")  
	FillMeStr = "SYM=PA;ETERM=-2.421;NSHELLS=24;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=112.601;Shell1Num"  
	FillMeStr += "Xsect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=21.1046;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=20.3137;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;"  
	FillMeStr += "Shell4BindEnergy=16.7331;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=5.366"  
	FillMeStr += "9;Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=5.0009;Shell6NumXsect=11;She"  
	FillMeStr += "ll7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=4.1738;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8Fu"  
	FillMeStr += "ncType=0;Shell8BindEnergy=3.6112;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEner"  
	FillMeStr += "gy=3.4418;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=0;Shell10BindEnergy=1.3871;Shell10Num"  
	FillMeStr += "Xsect=11;Shell11Shell=4P1/2;Shell11FuncType=0;Shell11BindEnergy=1.2243;Shell11NumXsect=11;Shell12She"  
	FillMeStr += "ll=4P3/2;Shell12FuncType=0;Shell12BindEnergy=1.0067;Shell12NumXsect=11;Shell13Shell=4D3/2;Shell13Fun"  
	FillMeStr += "cType=2;Shell13BindEnergy=0.7434;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14Bind"  
	FillMeStr += "Energy=0.7082;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.3712;Shell"  
	FillMeStr += "15NumXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.3595;Shell16NumXsect=10;Shell"  
	FillMeStr += "17Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.3096;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell"  
	FillMeStr += "18FuncType=2;Shell18BindEnergy=0.233624;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shel"  
	FillMeStr += "l19BindEnergy=0.18305;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.09"  
	FillMeStr += "66789;Shell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.0892408;Shell21Num"  
	FillMeStr += "Xsect=10;Shell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.0454585;Shell22NumXsect=10;Shell23"  
	FillMeStr += "Shell=6P1/2;Shell23FuncType=2;Shell23BindEnergy=0.0285451;Shell23NumXsect=10;Shell24Shell=6P3/2;Shel"  
	FillMeStr += "l24FuncType=2;Shell24BindEnergy=0.0203206;Shell24NumXsect=10;"  
	string/g $("92")  
	SVAR FillMeStr = $("92")  
	FillMeStr = "SYM=U;ETERM=-2.49;NSHELLS=24;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=115.606;Shell1NumXs"  
	FillMeStr += "ect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=21.7574;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=20.9476;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Sh"  
	FillMeStr += "ell4BindEnergy=17.1663;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=5.548;S"  
	FillMeStr += "hell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=5.1822;Shell6NumXsect=11;Shell7"  
	FillMeStr += "Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=4.3034;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncT"  
	FillMeStr += "ype=0;Shell8BindEnergy=3.7276;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy="  
	FillMeStr += "3.5517;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=0;Shell10BindEnergy=1.4408;Shell10NumXse"  
	FillMeStr += "ct=11;Shell11Shell=4P1/2;Shell11FuncType=0;Shell11BindEnergy=1.2726;Shell11NumXsect=11;Shell12Shell="  
	FillMeStr += "4P3/2;Shell12FuncType=0;Shell12BindEnergy=1.0449;Shell12NumXsect=11;Shell13Shell=4D3/2;Shell13FuncTy"  
	FillMeStr += "pe=2;Shell13BindEnergy=0.7804;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEne"  
	FillMeStr += "rgy=0.7377;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.3913;Shell15N"  
	FillMeStr += "umXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.3809;Shell16NumXsect=10;Shell17S"  
	FillMeStr += "hell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.3237;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18F"  
	FillMeStr += "uncType=2;Shell18BindEnergy=0.2593;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19Bi"  
	FillMeStr += "ndEnergy=0.1951;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.105;Shel"  
	FillMeStr += "l20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.0963;Shell21NumXsect=10;Shel"  
	FillMeStr += "l22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.0707;Shell22NumXsect=10;Shell23Shell=6P1/2;Shel"  
	FillMeStr += "l23FuncType=2;Shell23BindEnergy=0.0423;Shell23NumXsect=10;Shell24Shell=6P3/2;Shell24FuncType=2;Shell"  
	FillMeStr += "24BindEnergy=0.0323;Shell24NumXsect=10;"  
	string/g $("93")  
	SVAR FillMeStr = $("93")  
	FillMeStr = "SYM=NP;ETERM=-2.561;NSHELLS=24;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=118.678;Shell1Num"  
	FillMeStr += "Xsect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=22.4268;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=21.6005;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;"  
	FillMeStr += "Shell4BindEnergy=17.61;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=5.7232;"  
	FillMeStr += "Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=5.3662;Shell6NumXsect=11;Shell"  
	FillMeStr += "7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=4.4347;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8Func"  
	FillMeStr += "Type=0;Shell8BindEnergy=3.8503;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy"  
	FillMeStr += "=3.6658;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=0;Shell10BindEnergy=1.5007;Shell10NumXs"  
	FillMeStr += "ect=11;Shell11Shell=4P1/2;Shell11FuncType=0;Shell11BindEnergy=1.3277;Shell11NumXsect=11;Shell12Shell"  
	FillMeStr += "=4P3/2;Shell12FuncType=0;Shell12BindEnergy=1.0868;Shell12NumXsect=11;Shell13Shell=4D3/2;Shell13FuncT"  
	FillMeStr += "ype=2;Shell13BindEnergy=0.8159;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEn"  
	FillMeStr += "ergy=0.7703;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.415;Shell15N"  
	FillMeStr += "umXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.4044;Shell16NumXsect=10;Shell17S"  
	FillMeStr += "hell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.323735;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell1"  
	FillMeStr += "8FuncType=2;Shell18BindEnergy=0.2834;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19"  
	FillMeStr += "BindEnergy=0.2061;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.1093;S"  
	FillMeStr += "hell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.1013;Shell21NumXsect=10;S"  
	FillMeStr += "hell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.0496075;Shell22NumXsect=10;Shell23Shell=6P1/"  
	FillMeStr += "2;Shell23FuncType=2;Shell23BindEnergy=0.0312007;Shell23NumXsect=10;Shell24Shell=6P3/2;Shell24FuncTyp"  
	FillMeStr += "e=2;Shell24BindEnergy=0.0215627;Shell24NumXsect=10;"  
	string/g $("94")  
	SVAR FillMeStr = $("94")  
	FillMeStr = "SYM=PU;ETERM=-2.633;NSHELLS=24;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=122.011;Shell1Num"  
	FillMeStr += "Xsect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=22.9714;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=22.1644;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;"  
	FillMeStr += "Shell4BindEnergy=17.9039;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=5.835"  
	FillMeStr += "72;Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=5.46938;Shell6NumXsect=11;S"  
	FillMeStr += "hell7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=4.48219;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell"  
	FillMeStr += "8FuncType=0;Shell8BindEnergy=3.90746;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9Bind"  
	FillMeStr += "Energy=3.70962;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=0;Shell10BindEnergy=1.50245;Shel"  
	FillMeStr += "l10NumXsect=11;Shell11Shell=4P1/2;Shell11FuncType=0;Shell11BindEnergy=1.33662;Shell11NumXsect=11;She"  
	FillMeStr += "ll12Shell=4P3/2;Shell12FuncType=0;Shell12BindEnergy=1.07618;Shell12NumXsect=11;Shell13Shell=4D3/2;Sh"  
	FillMeStr += "ell13FuncType=2;Shell13BindEnergy=0.813765;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;S"  
	FillMeStr += "hell14BindEnergy=0.766256;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy="  
	FillMeStr += "0.420633;Shell15NumXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.408012;Shell16N"  
	FillMeStr += "umXsect=10;Shell17Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.334984;Shell17NumXsect=10;Shell1"  
	FillMeStr += "8Shell=5P1/2;Shell18FuncType=2;Shell18BindEnergy=0.269481;Shell18NumXsect=10;Shell19Shell=5P3/2;Shel"  
	FillMeStr += "l19FuncType=2;Shell19BindEnergy=0.205866;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;She"  
	FillMeStr += "ll20BindEnergy=0.110411;Shell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0."  
	FillMeStr += "100979;Shell21NumXsect=10;Shell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.0486186;Shell22Nu"  
	FillMeStr += "mXsect=10;Shell23Shell=6P1/2;Shell23FuncType=2;Shell23BindEnergy=0.0298109;Shell23NumXsect=10;Shell2"  
	FillMeStr += "4Shell=6P3/2;Shell24FuncType=2;Shell24BindEnergy=0.0199005;Shell24NumXsect=10;"  
	string/g $("95")  
	SVAR FillMeStr = $("95")  
	FillMeStr = "SYM=AM;ETERM=-2.707;NSHELLS=24;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=125.027;Shell1Num"  
	FillMeStr += "Xsect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=23.7729;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=22.944;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;S"  
	FillMeStr += "hell4BindEnergy=18.5041;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=6.1205"  
	FillMeStr += ";Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=5.7102;Shell6NumXsect=11;Shel"  
	FillMeStr += "l7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=4.667;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8Func"  
	FillMeStr += "Type=0;Shell8BindEnergy=4.0921;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy"  
	FillMeStr += "=3.8869;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=0;Shell10BindEnergy=1.6171;Shell10NumXs"  
	FillMeStr += "ect=11;Shell11Shell=4P1/2;Shell11FuncType=0;Shell11BindEnergy=1.4118;Shell11NumXsect=11;Shell12Shell"  
	FillMeStr += "=4P3/2;Shell12FuncType=0;Shell12BindEnergy=1.1357;Shell12NumXsect=11;Shell13Shell=4D3/2;Shell13FuncT"  
	FillMeStr += "ype=2;Shell13BindEnergy=0.8787;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEn"  
	FillMeStr += "ergy=0.8276;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.44524;Shell1"  
	FillMeStr += "5NumXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.431764;Shell16NumXsect=10;Shel"  
	FillMeStr += "l17Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.350755;Shell17NumXsect=10;Shell18Shell=5P1/2;Sh"  
	FillMeStr += "ell18FuncType=2;Shell18BindEnergy=0.283096;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;S"  
	FillMeStr += "hell19BindEnergy=0.214591;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy="  
	FillMeStr += "0.1158;Shell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.1033;Shell21NumXs"  
	FillMeStr += "ect=10;Shell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.0504377;Shell22NumXsect=10;Shell23Sh"  
	FillMeStr += "ell=6P1/2;Shell23FuncType=2;Shell23BindEnergy=0.0308816;Shell23NumXsect=10;Shell24Shell=6P3/2;Shell2"  
	FillMeStr += "4FuncType=2;Shell24BindEnergy=0.0202617;Shell24NumXsect=10;"  
	string/g $("96")  
	SVAR FillMeStr = $("96")  
	FillMeStr = "SYM=CM;ETERM=-2.782;NSHELLS=24;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=128.22;Shell1NumX"  
	FillMeStr += "sect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=24.46;Shell2NumXsect=11;Shell3Shell=2P1/"  
	FillMeStr += "2;Shell3FuncType=0;Shell3BindEnergy=23.779;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;Shel"  
	FillMeStr += "l4BindEnergy=18.93;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=6.288;Shell"  
	FillMeStr += "5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=5.895;Shell6NumXsect=11;Shell7Shell"  
	FillMeStr += "=3P3/2;Shell7FuncType=0;Shell7BindEnergy=4.797;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncType=0;"  
	FillMeStr += "Shell8BindEnergy=4.227;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy=3.971;S"  
	FillMeStr += "hell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=0;Shell10BindEnergy=1.643;Shell10NumXsect=11;She"  
	FillMeStr += "ll11Shell=4P1/2;Shell11FuncType=0;Shell11BindEnergy=1.44;Shell11NumXsect=11;Shell12Shell=4P3/2;Shell"  
	FillMeStr += "12FuncType=0;Shell12BindEnergy=1.154;Shell12NumXsect=11;Shell13Shell=4D3/2;Shell13FuncType=2;Shell13"  
	FillMeStr += "BindEnergy=0.884263;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnergy=0.8310"  
	FillMeStr += "1;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.470135;Shell15NumXsect"  
	FillMeStr += "=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.455751;Shell16NumXsect=10;Shell17Shell="  
	FillMeStr += "5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.385;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18FuncTyp"  
	FillMeStr += "e=2;Shell18BindEnergy=0.296927;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19BindEn"  
	FillMeStr += "ergy=0.223245;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.121646;She"  
	FillMeStr += "ll20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.110701;Shell21NumXsect=10;S"  
	FillMeStr += "hell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.0522254;Shell22NumXsect=10;Shell23Shell=6P1/"  
	FillMeStr += "2;Shell23FuncType=2;Shell23BindEnergy=0.0319399;Shell23NumXsect=10;Shell24Shell=6P3/2;Shell24FuncTyp"  
	FillMeStr += "e=2;Shell24BindEnergy=0.0205731;Shell24NumXsect=10;"  
	string/g $("97")  
	SVAR FillMeStr = $("97")  
	FillMeStr = "SYM=BK;ETERM=-2.858;NSHELLS=24;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=131.59;Shell1NumX"  
	FillMeStr += "sect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=25.275;Shell2NumXsect=11;Shell3Shell=2P1"  
	FillMeStr += "/2;Shell3FuncType=0;Shell3BindEnergy=24.385;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;She"  
	FillMeStr += "ll4BindEnergy=19.452;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=6.556;She"  
	FillMeStr += "ll5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=6.147;Shell6NumXsect=11;Shell7She"  
	FillMeStr += "ll=3P3/2;Shell7FuncType=0;Shell7BindEnergy=4.977;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell8FuncType="  
	FillMeStr += "0;Shell8BindEnergy=4.366;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9BindEnergy=4.132"  
	FillMeStr += ";Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=0;Shell10BindEnergy=1.755;Shell10NumXsect=11;S"  
	FillMeStr += "hell11Shell=4P1/2;Shell11FuncType=0;Shell11BindEnergy=1.554;Shell11NumXsect=11;Shell12Shell=4P3/2;Sh"  
	FillMeStr += "ell12FuncType=0;Shell12BindEnergy=1.235;Shell12NumXsect=11;Shell13Shell=4D3/2;Shell13FuncType=2;Shel"  
	FillMeStr += "l13BindEnergy=0.920204;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;Shell14BindEnergy=0.8"  
	FillMeStr += "63912;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0.495366;Shell15NumX"  
	FillMeStr += "sect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.480032;Shell16NumXsect=10;Shell17Sh"  
	FillMeStr += "ell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.398;Shell17NumXsect=10;Shell18Shell=5P1/2;Shell18Fun"  
	FillMeStr += "cType=2;Shell18BindEnergy=0.311035;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell19FuncType=2;Shell19Bi"  
	FillMeStr += "ndEnergy=0.231895;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shell20BindEnergy=0.127215"  
	FillMeStr += ";Shell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.115465;Shell21NumXsect="  
	FillMeStr += "10;Shell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.0540424;Shell22NumXsect=10;Shell23Shell="  
	FillMeStr += "6P1/2;Shell23FuncType=2;Shell23BindEnergy=0.0330119;Shell23NumXsect=10;Shell24Shell=6P3/2;Shell24Fun"  
	FillMeStr += "cType=2;Shell24BindEnergy=0.0208517;Shell24NumXsect=10;"  
	string/g $("98")  
	SVAR FillMeStr = $("98")  
	FillMeStr = "SYM=CF;ETERM=-2.936;NSHELLS=24;Shell1Shell=1S1/2;Shell1FuncType=1;Shell1BindEnergy=135.354;Shell1Num"  
	FillMeStr += "Xsect=10;Shell2Shell=2S1/2;Shell2FuncType=0;Shell2BindEnergy=25.9027;Shell2NumXsect=11;Shell3Shell=2"  
	FillMeStr += "P1/2;Shell3FuncType=0;Shell3BindEnergy=25.0203;Shell3NumXsect=11;Shell4Shell=2P3/2;Shell4FuncType=0;"  
	FillMeStr += "Shell4BindEnergy=19.7527;Shell4NumXsect=11;Shell5Shell=3S1/2;Shell5FuncType=0;Shell5BindEnergy=6.665"  
	FillMeStr += "73;Shell5NumXsect=11;Shell6Shell=3P1/2;Shell6FuncType=0;Shell6BindEnergy=6.26603;Shell6NumXsect=11;S"  
	FillMeStr += "hell7Shell=3P3/2;Shell7FuncType=0;Shell7BindEnergy=5.03215;Shell7NumXsect=11;Shell8Shell=3D3/2;Shell"  
	FillMeStr += "8FuncType=0;Shell8BindEnergy=4.41774;Shell8NumXsect=11;Shell9Shell=3D5/2;Shell9FuncType=0;Shell9Bind"  
	FillMeStr += "Energy=4.17726;Shell9NumXsect=11;Shell10Shell=4S1/2;Shell10FuncType=0;Shell10BindEnergy=1.75697;Shel"  
	FillMeStr += "l10NumXsect=11;Shell11Shell=4P1/2;Shell11FuncType=0;Shell11BindEnergy=1.57404;Shell11NumXsect=11;She"  
	FillMeStr += "ll12Shell=4P3/2;Shell12FuncType=0;Shell12BindEnergy=1.24194;Shell12NumXsect=11;Shell13Shell=4D3/2;Sh"  
	FillMeStr += "ell13FuncType=2;Shell13BindEnergy=0.956658;Shell13NumXsect=10;Shell14Shell=4D5/2;Shell14FuncType=2;S"  
	FillMeStr += "hell14BindEnergy=0.89718;Shell14NumXsect=10;Shell15Shell=4F5/2;Shell15FuncType=2;Shell15BindEnergy=0"  
	FillMeStr += ".520934;Shell15NumXsect=10;Shell16Shell=4F7/2;Shell16FuncType=2;Shell16BindEnergy=0.504621;Shell16Nu"  
	FillMeStr += "mXsect=10;Shell17Shell=5S1/2;Shell17FuncType=2;Shell17BindEnergy=0.399858;Shell17NumXsect=10;Shell18"  
	FillMeStr += "Shell=5P1/2;Shell18FuncType=2;Shell18BindEnergy=0.325483;Shell18NumXsect=10;Shell19Shell=5P3/2;Shell"  
	FillMeStr += "19FuncType=2;Shell19BindEnergy=0.240559;Shell19NumXsect=10;Shell20Shell=5D3/2;Shell20FuncType=2;Shel"  
	FillMeStr += "l20BindEnergy=0.13277;Shell20NumXsect=10;Shell21Shell=5D5/2;Shell21FuncType=2;Shell21BindEnergy=0.12"  
	FillMeStr += "0199;Shell21NumXsect=10;Shell22Shell=6S1/2;Shell22FuncType=2;Shell22BindEnergy=0.0558717;Shell22NumX"  
	FillMeStr += "sect=10;Shell23Shell=6P1/2;Shell23FuncType=2;Shell23BindEnergy=0.0340771;Shell23NumXsect=10;Shell24S"  
	FillMeStr += "hell=6P3/2;Shell24FuncType=2;Shell24BindEnergy=0.0211275;Shell24NumXsect=10;"  
	string/g $("99")  
	SVAR FillMeStr = $("99")  
	FillMeStr = "SYM=ES;ETERM=0;NSHELLS=0;"  
	string/g $("100")  
	SVAR FillMeStr = $("100")  
	FillMeStr = "SYM=FM;ETERM=0;NSHELLS=0;"  
	string/g $("101")  
	SVAR FillMeStr = $("101")  
	FillMeStr = "SYM=MD;ETERM=0;NSHELLS=0;"  
	string/g $("102")  
	SVAR FillMeStr = $("102")  
	FillMeStr = "SYM=NO;ETERM=0;NSHELLS=0;"  
	string/g $("103")  
	SVAR FillMeStr = $("103")  
	FillMeStr = "SYM=LW;ETERM=0;NSHELLS=0;"  
	setDataFOlder OldDf
end


static Function Cromer_InitializeWaves()

	string OldDf=GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:CromerCalculations   
	Make/O/N=(0,11,2) '2Wv'  
	'2Wv'[][0][0]={0}  
	'2Wv'[][1][0]={0}  
	'2Wv'[][2][0]={0}  
	'2Wv'[][3][0]={0}  
	'2Wv'[][4][0]={0}  
	'2Wv'[][5][0]={0}  
	'2Wv'[][6][0]={0}  
	'2Wv'[][7][0]={0}  
	'2Wv'[][8][0]={0}  
	'2Wv'[][9][0]={0}  
	'2Wv'[][10][0]={0}  
	'2Wv'[][0][1]={0}  
	'2Wv'[][1][1]={0}  
	'2Wv'[][2][1]={0}  
	'2Wv'[][3][1]={0}  
	'2Wv'[][4][1]={0}  
	'2Wv'[][5][1]={0}  
	'2Wv'[][6][1]={0}  
	'2Wv'[][7][1]={0}  
	'2Wv'[][8][1]={0}  
	'2Wv'[][9][1]={0}  
	'2Wv'[][10][1]={0}  
   
	Make/O/N=(2,11,2) '3Wv'  
	'3Wv'[][0][0]={80.000298,80.000298}  
	'3Wv'[][1][0]={26.700100,26.700100}  
	'3Wv'[][2][0]={ 8.899960, 8.899960}  
	'3Wv'[][3][0]={ 3.000030, 3.000030}  
	'3Wv'[][4][0]={ 1.000000, 1.000000}  
	'3Wv'[][5][0]={24.880100, 2.426660}  
	'3Wv'[][6][0]={ 1.028120, 0.100277}  
	'3Wv'[][7][0]={ 0.219000, 0.021360}  
	'3Wv'[][8][0]={ 0.092527, 0.009025}  
	'3Wv'[][9][0]={ 0.060272, 0.005879}  
	'3Wv'[][10][0]={ 0.000000, 0.000000}  
	'3Wv'[][0][1]={ 0.001302, 0.000025}  
	'3Wv'[][1][1]={ 0.051677, 0.000866}  
	'3Wv'[][2][1]={ 2.045730, 0.032190}  
	'3Wv'[][3][1]={73.682701, 1.143650}  
	'3Wv'[][4][1]={2367.260010,35.462601}  
	'3Wv'[][5][1]={ 0.065318, 2.255430}  
	'3Wv'[][6][1]={2174.790039,17745.800781}  
	'3Wv'[][7][1]={189730.000000,440576.000000}  
	'3Wv'[][8][1]={1618910.000000,1333730.000000}  
	'3Wv'[][9][1]={3022230.000000,1448480.000000}  
	'3Wv'[][10][1]={ 0.000000, 0.000000}  
   
	Make/O/N=(2,11,2) '4Wv'  
	'4Wv'[][0][0]={80.000298,80.000298}  
	'4Wv'[][1][0]={26.700100,26.700100}  
	'4Wv'[][2][0]={ 8.899960, 8.899960}  
	'4Wv'[][3][0]={ 3.000030, 3.000030}  
	'4Wv'[][4][0]={ 1.000000, 1.000000}  
	'4Wv'[][5][0]={50.441799, 3.826310}  
	'4Wv'[][6][0]={ 2.084400, 0.158114}  
	'4Wv'[][7][0]={ 0.444000, 0.033680}  
	'4Wv'[][8][0]={ 0.187588, 0.014230}  
	'4Wv'[][9][0]={ 0.122196, 0.009269}  
	'4Wv'[][10][0]={ 0.000000, 0.000000}  
	'4Wv'[][0][1]={ 0.005502, 0.000208}  
	'4Wv'[][1][1]={ 0.216351, 0.007329}  
	'4Wv'[][2][1]={ 8.283570, 0.263835}  
	'4Wv'[][3][1]={277.734009, 8.652010}  
	'4Wv'[][4][1]={7976.129883,237.104996}  
	'4Wv'[][5][1]={ 0.025604, 4.029220}  
	'4Wv'[][6][1]={866.963013,31112.800781}  
	'4Wv'[][7][1]={81105.101563,621490.000000}  
	'4Wv'[][8][1]={771925.000000,1648230.000000}  
	'4Wv'[][9][1]={2051790.000000,1031230.000000}  
	'4Wv'[][10][1]={ 0.000000, 0.000000}  
   
	Make/O/N=(3,11,2) '5Wv'  
	'5Wv'[][0][0]={80.000298,80.000298,80.000298}  
	'5Wv'[][1][0]={26.700100,26.700100,26.700100}  
	'5Wv'[][2][0]={ 8.899960, 8.899960, 8.899960}  
	'5Wv'[][3][0]={ 3.000030, 3.000030, 3.000030}  
	'5Wv'[][4][0]={ 1.000000, 1.000000, 1.000000}  
	'5Wv'[][5][0]={85.432999, 6.121180, 2.135820}  
	'5Wv'[][6][0]={ 3.530340, 0.252945, 0.088258}  
	'5Wv'[][7][0]={ 0.752000, 0.053880, 0.018800}  
	'5Wv'[][8][0]={ 0.317717, 0.022764, 0.007943}  
	'5Wv'[][9][0]={ 0.206962, 0.014829, 0.005174}  
	'5Wv'[][10][0]={ 0.000000, 0.000000, 0.000000}  
	'5Wv'[][0][1]={ 0.016520, 0.000828, 0.000000}  
	'5Wv'[][1][1]={ 0.639404, 0.029313, 0.000013}  
	'5Wv'[][2][1]={23.617399, 1.025590, 0.001205}  
	'5Wv'[][3][1]={741.658020,31.202499, 0.104659}  
	'5Wv'[][4][1]={19577.500000,776.768982, 7.679660}  
	'5Wv'[][5][1]={ 0.013360, 3.395960, 0.400328}  
	'5Wv'[][6][1]={447.894989,26979.300781,30321.800781}  
	'5Wv'[][7][1]={43871.601563,581240.000000,1377610.000000}  
	'5Wv'[][8][1]={435450.000000,1365940.000000,6894480.000000}  
	'5Wv'[][9][1]={1167090.000000,870619.000000,14448500.000000}  
	'5Wv'[][10][1]={ 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(3,11,2) '6Wv'  
	'6Wv'[][0][0]={80.000298,80.000298,80.000298}  
	'6Wv'[][1][0]={26.700100,26.700100,26.700100}  
	'6Wv'[][2][0]={ 8.899960, 8.899960, 8.899960}  
	'6Wv'[][3][0]={ 3.000030, 3.000030, 3.000030}  
	'6Wv'[][4][0]={ 1.000000, 1.000000, 1.000000}  
	'6Wv'[][5][0]={128.966995, 8.865940, 2.908360}  
	'6Wv'[][6][0]={ 5.329310, 0.366367, 0.120182}  
	'6Wv'[][7][0]={ 1.135200, 0.078040, 0.025600}  
	'6Wv'[][8][0]={ 0.479617, 0.032972, 0.010816}  
	'6Wv'[][9][0]={ 0.312424, 0.021478, 0.007046}  
	'6Wv'[][10][0]={ 0.000000, 0.000000, 0.000000}  
	'6Wv'[][0][1]={ 0.040228, 0.002235, 0.000002}  
	'6Wv'[][1][1]={ 1.527500, 0.078572, 0.000131}  
	'6Wv'[][2][1]={54.380501, 2.655920, 0.011822}  
	'6Wv'[][3][1]={1610.339966,75.417397, 0.941144}  
	'6Wv'[][4][1]={39562.101563,1707.099976,63.741600}  
	'6Wv'[][5][1]={ 0.008320, 2.688380, 1.063300}  
	'6Wv'[][6][1]={275.130005,21804.599609,76115.398438}  
	'6Wv'[][7][1]={27737.300781,492388.000000,3070110.000000}  
	'6Wv'[][8][1]={281873.000000,1077520.000000,11208000.000000}  
	'6Wv'[][9][1]={765563.000000,678007.000000,18939000.000000}  
	'6Wv'[][10][1]={ 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(4,11,2) '7Wv'  
	'7Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298}  
	'7Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100}  
	'7Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960}  
	'7Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030}  
	'7Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000}  
	'7Wv'[][5][0]={182.498993,11.956100, 4.180760, 4.180760}  
	'7Wv'[][6][0]={ 7.541410, 0.494060, 0.172761, 0.172761}  
	'7Wv'[][7][0]={ 1.606400, 0.105240, 0.036800, 0.036800}  
	'7Wv'[][8][0]={ 0.678697, 0.044464, 0.015548, 0.015548}  
	'7Wv'[][9][0]={ 0.442106, 0.028964, 0.010128, 0.010128}  
	'7Wv'[][10][0]={ 0.000000, 0.000000, 0.000000, 0.000000}  
	'7Wv'[][0][1]={ 0.084740, 0.004934, 0.000006, 0.000002}  
	'7Wv'[][1][1]={ 3.154850, 0.170915, 0.000451, 0.000212}  
	'7Wv'[][2][1]={108.397003, 5.563660, 0.039588, 0.019391}  
	'7Wv'[][3][1]={3054.149902,148.862000, 2.994860, 1.481270}  
	'7Wv'[][4][1]={70342.898438,3093.780029,182.203995,90.318604}  
	'7Wv'[][5][1]={ 0.005561, 2.197900, 0.817082, 0.402362}  
	'7Wv'[][6][1]={182.453003,17981.099609,60970.398438,30338.699219}  
	'7Wv'[][7][1]={18816.300781,406346.000000,2508750.000000,1251750.000000}  
	'7Wv'[][8][1]={196109.000000,854338.000000,7526410.000000,3764250.000000}  
	'7Wv'[][9][1]={545683.000000,509075.000000,10705900.000000,5362580.000000}  
	'7Wv'[][10][1]={ 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(4,11,2) '8Wv'  
	'8Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298}  
	'8Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100}  
	'8Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960}  
	'8Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030}  
	'8Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000}  
	'8Wv'[][5][0]={241.757004,10.770000, 3.226460, 3.226460}  
	'8Wv'[][6][0]={ 9.990110, 0.445048, 0.133327, 0.133327}  
	'8Wv'[][7][0]={ 2.128000, 0.094800, 0.028400, 0.028400}  
	'8Wv'[][8][0]={ 0.899071, 0.040053, 0.011999, 0.011999}  
	'8Wv'[][9][0]={ 0.585658, 0.026090, 0.007816, 0.007816}  
	'8Wv'[][10][0]={ 0.000000, 0.000000, 0.000000, 0.000000}  
	'8Wv'[][0][1]={ 0.160505, 0.009547, 0.000016, 0.000013}  
	'8Wv'[][1][1]={ 5.857070, 0.325385, 0.001246, 0.001175}  
	'8Wv'[][2][1]={194.311996,10.191100, 0.105102, 0.102652}  
	'8Wv'[][3][1]={5221.689941,256.265991, 7.582700, 7.483690}  
	'8Wv'[][4][1]={111658.000000,4902.520020,419.397003,415.101990}  
	'8Wv'[][5][1]={ 0.004204, 5.650280, 5.733740, 5.654940}  
	'8Wv'[][6][1]={135.399994,33413.800781,230141.000000,228981.000000}  
	'8Wv'[][7][1]={14075.400391,514644.000000,3959250.000000,3953840.000000}  
	'8Wv'[][8][1]={147498.000000,839020.000000,8621530.000000,8638010.000000}  
	'8Wv'[][9][1]={417833.000000,466361.000000,10632600.000000,10673800.000000}  
	'8Wv'[][10][1]={ 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(4,11,2) '9Wv'  
	'9Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298}  
	'9Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100}  
	'9Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960}  
	'9Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030}  
	'9Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000}  
	'9Wv'[][5][0]={311.467010,14.087400, 3.908100, 3.908100}  
	'9Wv'[][6][0]={12.870700, 0.582131, 0.161494, 0.161494}  
	'9Wv'[][7][0]={ 2.741600, 0.124000, 0.034400, 0.034400}  
	'9Wv'[][8][0]={ 1.158310, 0.052389, 0.014534, 0.014534}  
	'9Wv'[][9][0]={ 0.754530, 0.034127, 0.009467, 0.009467}  
	'9Wv'[][10][0]={ 0.000000, 0.000000, 0.000000, 0.000000}  
	'9Wv'[][0][1]={ 0.280725, 0.016849, 0.000038, 0.000048}  
	'9Wv'[][1][1]={10.040700, 0.564889, 0.002953, 0.004174}  
	'9Wv'[][2][1]={322.388000,17.078199, 0.240616, 0.351481}  
	'9Wv'[][3][1]={8296.849609,405.709015,16.367399,24.164600}  
	'9Wv'[][4][1]={164968.000000,7241.600098,847.312012,1255.790039}  
	'9Wv'[][5][1]={ 0.003362, 4.161260, 6.026390, 8.867740}  
	'9Wv'[][6][1]={102.272003,25509.599609,224444.000000,334560.000000}  
	'9Wv'[][7][1]={10744.000000,409592.000000,3326680.000000,4983430.000000}  
	'9Wv'[][8][1]={113532.000000,663627.000000,6272800.000000,9439700.000000}  
	'9Wv'[][9][1]={328531.000000,342295.000000,6917330.000000,10439700.000000}  
	'9Wv'[][10][1]={ 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(4,11,2) '10Wv'  
	'10Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298}  
	'10Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100}  
	'10Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960}  
	'10Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030}  
	'10Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000}  
	'10Wv'[][5][0]={393.946014,20.449400, 8.316080, 8.316080}  
	'10Wv'[][6][0]={16.278999, 0.845028, 0.343645, 0.343645}  
	'10Wv'[][7][0]={ 3.467600, 0.180000, 0.073200, 0.073200}  
	'10Wv'[][8][0]={ 1.465050, 0.076049, 0.030927, 0.030927}  
	'10Wv'[][9][0]={ 0.954336, 0.049539, 0.020146, 0.020146}  
	'10Wv'[][10][0]={ 0.000000, 0.000000, 0.000000, 0.000000}  
	'10Wv'[][0][1]={ 0.461049, 0.027831, 0.000081, 0.000136}  
	'10Wv'[][1][1]={16.176001, 0.915888, 0.006273, 0.011774}  
	'10Wv'[][2][1]={504.382996,26.759800, 0.495196, 0.960985}  
	'10Wv'[][3][1]={12497.000000,604.638977,31.896000,62.607101}  
	'10Wv'[][4][1]={235837.000000,10104.400391,1569.140015,3095.169922}  
	'10Wv'[][5][1]={ 0.002751, 2.098200, 0.647713, 1.256620}  
	'10Wv'[][6][1]={77.597504,14937.400391,45953.101563,91012.000000}  
	'10Wv'[][7][1]={8264.120117,281952.000000,1562450.000000,3113750.000000}  
	'10Wv'[][8][1]={88571.000000,503242.000000,3068620.000000,6153210.000000}  
	'10Wv'[][9][1]={262355.000000,240853.000000,2868420.000000,5780000.000000}  
	'10Wv'[][10][1]={ 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(4,11,2) '11Wv'  
	'11Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298}  
	'11Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100}  
	'11Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960}  
	'11Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030}  
	'11Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000}  
	'11Wv'[][5][0]={22.854401,28.765499,14.132800,14.132800}  
	'11Wv'[][6][0]={ 4.645840, 1.188670, 0.584009, 0.584009}  
	'11Wv'[][7][0]={ 2.144200, 0.253200, 0.124400, 0.124400}  
	'11Wv'[][8][0]={ 1.393720, 0.106976, 0.052559, 0.052559}  
	'11Wv'[][9][0]={ 1.124870, 0.069684, 0.034237, 0.034237}  
	'11Wv'[][10][0]={ 1.073170, 0.000000, 0.000000, 0.000000}  
	'11Wv'[][0][1]={ 0.719679, 0.045490, 0.000179, 0.000300}  
	'11Wv'[][1][1]={24.757500, 1.475490, 0.013787, 0.025871}  
	'11Wv'[][2][1]={749.831970,41.757702, 1.064710, 2.062770}  
	'11Wv'[][3][1]={17837.599609,896.968018,65.013802,127.486000}  
	'11Wv'[][4][1]={ 0.000000,13934.500000,2978.449951,5874.600098}  
	'11Wv'[][5][1]={40.499599, 1.172960, 0.172414, 0.329745}  
	'11Wv'[][6][1]={5139.830078,9320.540039,16576.099609,32774.898438}  
	'11Wv'[][7][1]={44760.398438,201357.000000,938348.000000,1869310.000000}  
	'11Wv'[][8][1]={137346.000000,518225.000000,2437550.000000,4888040.000000}  
	'11Wv'[][9][1]={242031.000000,355564.000000,1397260.000000,2814550.000000}  
	'11Wv'[][10][1]={194894.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(4,11,2) '12Wv'  
	'12Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298}  
	'12Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100}  
	'12Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960}  
	'12Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030}  
	'12Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000}  
	'12Wv'[][5][0]={27.819201,40.626099,23.357700,23.357700}  
	'12Wv'[][6][0]={ 5.655100, 1.678790, 0.965210, 0.965210}  
	'12Wv'[][7][0]={ 2.610000, 0.357600, 0.205600, 0.205600}  
	'12Wv'[][8][0]={ 1.696490, 0.151084, 0.086865, 0.086865}  
	'12Wv'[][9][0]={ 1.369230, 0.098417, 0.056584, 0.056584}  
	'12Wv'[][10][0]={ 1.306310, 0.000000, 0.000000, 0.000000}  
	'12Wv'[][0][1]={ 1.077490, 0.071234, 0.000358, 0.000599}  
	'12Wv'[][1][1]={36.359001, 2.274680, 0.027310, 0.051063}  
	'12Wv'[][2][1]={1071.030029,62.369499, 2.050530, 3.962110}  
	'12Wv'[][3][1]={24479.300781,1277.609985,119.007004,232.970993}  
	'12Wv'[][4][1]={ 0.000000,18539.199219,5120.120117,10091.799805}  
	'12Wv'[][5][1]={31.945299, 0.615425, 0.046360, 0.086936}  
	'12Wv'[][6][1]={4077.840088,5559.930176,5738.629883,11313.000000}  
	'12Wv'[][7][1]={35751.199219,139329.000000,450838.000000,896493.000000}  
	'12Wv'[][8][1]={110367.000000,436743.000000,2111520.000000,4229250.000000}  
	'12Wv'[][9][1]={192796.000000,487871.000000,1121000.000000,2257600.000000}  
	'12Wv'[][10][1]={195278.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(5,11,2) '13Wv'  
	'13Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298}  
	'13Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100}  
	'13Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'13Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'13Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'13Wv'[][5][0]={33.246601,53.486500,33.218899,33.218899, 3.806160}  
	'13Wv'[][6][0]={ 6.758380, 2.210220, 1.372700, 1.372700, 0.157282}  
	'13Wv'[][7][0]={ 3.119200, 0.470800, 0.292400, 0.292400, 0.033503}  
	'13Wv'[][8][0]={ 2.027470, 0.198911, 0.123538, 0.123538, 0.014155}  
	'13Wv'[][9][0]={ 1.636360, 0.129571, 0.080473, 0.080473, 0.009220}  
	'13Wv'[][10][0]={ 1.561160, 0.000000, 0.000000, 0.000000, 0.000000}  
	'13Wv'[][0][1]={ 1.557510, 0.107319, 0.000667, 0.001113, 0.007880}  
	'13Wv'[][1][1]={51.572498, 3.367060, 0.050235, 0.093484, 0.224163}  
	'13Wv'[][2][1]={1478.339966,89.389503, 3.652290, 7.036640, 5.652370}  
	'13Wv'[][3][1]={32428.099609,1748.369995,201.835007,394.388000,109.528999}  
	'13Wv'[][4][1]={ 0.000000,23709.199219,8114.770020,15981.200195,1489.209961}  
	'13Wv'[][5][1]={25.910101, 0.384381, 0.021483, 0.039481,58.855999}  
	'13Wv'[][6][1]={3315.870117,3783.989990,2929.540039,5758.069824,45791.699219}  
	'13Wv'[][7][1]={29194.699219,104031.000000,269588.000000,535215.000000,266194.000000}  
	'13Wv'[][8][1]={90483.601563,369607.000000,1592400.000000,3186260.000000,71344.796875}  
	'13Wv'[][9][1]={157688.000000,494166.000000,1433480.000000,2885160.000000,347981.000000}  
	'13Wv'[][10][1]={167248.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(6,11,2) '14Wv'  
	'14Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'14Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'14Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'14Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'14Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'14Wv'[][5][0]={39.200500,67.573898,45.079498,45.079498, 5.161050, 2.309900}  
	'14Wv'[][6][0]={ 7.968700, 2.792350, 1.862820, 1.862820, 0.213270, 0.095452}  
	'14Wv'[][7][0]={ 3.677800, 0.594800, 0.396800, 0.396800, 0.045429, 0.020332}  
	'14Wv'[][8][0]={ 2.390560, 0.251300, 0.167646, 0.167646, 0.019193, 0.008590}  
	'14Wv'[][9][0]={ 1.929410, 0.163698, 0.109205, 0.109205, 0.012503, 0.005596}  
	'14Wv'[][10][0]={ 1.840740, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'14Wv'[][0][1]={ 2.186370, 0.156228, 0.001176, 0.001960, 0.014118, 0.000062}  
	'14Wv'[][1][1]={71.067299, 4.810150, 0.087148, 0.161602, 0.401187, 0.003997}  
	'14Wv'[][2][1]={1984.180054,123.654999, 6.128230,11.772100, 9.876700, 0.261709}  
	'14Wv'[][3][1]={41782.000000,2312.419922,323.640015,631.226013,183.102997,13.445300}  
	'14Wv'[][4][1]={ 0.000000,29410.800781,12196.500000,24000.800781,2358.030029,475.203003}  
	'14Wv'[][5][1]={21.395700, 0.263393, 0.011261, 0.020111,44.442902,32.831402}  
	'14Wv'[][6][1]={2740.580078,2770.070068,1652.949951,3237.929932,42208.601563,122244.000000}  
	'14Wv'[][7][1]={24228.900391,81446.500000,172008.000000,340892.000000,313736.000000,216557.000000}  
	'14Wv'[][8][1]={75374.500000,310727.000000,1209020.000000,2417060.000000,162653.000000,11215000.000000}  
	'14Wv'[][9][1]={131083.000000,444896.000000,1656120.000000,3331670.000000,80005.203125,32290600.000000}  
	'14Wv'[][10][1]={142536.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(7,11,2) '15Wv'  
	'15Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'15Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'15Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'15Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'15Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'15Wv'[][5][0]={45.736401,86.023697,60.075699,60.075699, 6.571750, 2.901510, 2.879590}  
	'15Wv'[][6][0]={ 9.297320, 3.554750, 2.482510, 2.482510, 0.271564, 0.119899, 0.118993}  
	'15Wv'[][7][0]={ 4.291000, 0.757200, 0.528800, 0.528800, 0.057846, 0.025540, 0.025347}  
	'15Wv'[][8][0]={ 2.789140, 0.319914, 0.223416, 0.223416, 0.024440, 0.010790, 0.010709}  
	'15Wv'[][9][0]={ 2.251100, 0.208393, 0.145534, 0.145534, 0.015920, 0.007029, 0.006976}  
	'15Wv'[][10][0]={ 2.147650, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'15Wv'[][0][1]={ 2.991100, 0.220794, 0.001978, 0.003279, 0.022434, 0.000134, 0.000055}  
	'15Wv'[][1][1]={95.534500, 6.667940, 0.144056, 0.265864, 0.631072, 0.008599, 0.003981}  
	'15Wv'[][2][1]={2601.350098,166.182999, 9.800490,18.769199,15.114000, 0.548111, 0.261432}  
	'15Wv'[][3][1]={52644.300781,2980.129883,496.497986,966.596985,268.410004,26.810900,12.988200}  
	'15Wv'[][4][1]={ 0.000000,35851.699219,17670.900391,34750.699219,3296.840088,882.156006,431.338989}  
	'15Wv'[][5][1]={17.768101, 0.176891, 0.006065, 0.010498,34.870899,30.027100,14.938100}  
	'15Wv'[][6][1]={2290.760010,1945.689941,949.570007,1852.479980,38114.898438,129890.000000,65373.699219}  
	'15Wv'[][7][1]={20345.599609,61948.101563,110776.000000,219094.000000,321233.000000,204304.000000,102237.000000}  
	'15Wv'[][8][1]={63556.101563,254934.000000,887976.000000,1773570.000000,227968.000000,12901800.000000,6433920.000000}  
	'15Wv'[][9][1]={110514.000000,385899.000000,1629470.000000,3276620.000000,4926.229980,30727200.000000,15426000.000000}  
	'15Wv'[][10][1]={121778.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(7,11,2) '16Wv'  
	'16Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'16Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'16Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'16Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'16Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'16Wv'[][5][0]={52.696602,104.155998,74.890198,74.890198, 8.038080, 3.550750, 3.514970}  
	'16Wv'[][6][0]={10.712200, 4.304010, 3.094680, 3.094680, 0.332157, 0.146728, 0.145249}  
	'16Wv'[][7][0]={ 4.944000, 0.916800, 0.659200, 0.659200, 0.070753, 0.031255, 0.030940}  
	'16Wv'[][8][0]={ 3.213580, 0.387344, 0.278509, 0.278509, 0.029893, 0.013205, 0.013072}  
	'16Wv'[][9][0]={ 2.593670, 0.252317, 0.181422, 0.181422, 0.019472, 0.008602, 0.008515}  
	'16Wv'[][10][0]={ 2.474470, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'16Wv'[][0][1]={ 4.002980, 0.303694, 0.003195, 0.005275, 0.033368, 0.000253, 0.000208}  
	'16Wv'[][1][1]={125.644997, 8.995590, 0.228410, 0.419764, 0.925767, 0.016165, 0.014854}  
	'16Wv'[][2][1]={3336.600098,217.438004,15.026400,28.690201,21.549200, 0.997794, 0.948393}  
	'16Wv'[][3][1]={64908.300781,3737.790039,729.671021,1417.979980,366.829010,46.418900,44.867599}  
	'16Wv'[][4][1]={ 0.000000,42614.601563,24527.099609,48208.398437,4318.390137,1431.599976,1397.849976}  
	'16Wv'[][5][1]={15.058200, 0.130291, 0.004100, 0.006840,28.517401,26.262100,26.226700}  
	'16Wv'[][6][1]={1949.680054,1515.560059,656.268982,1274.829956,34478.000000,127480.000000,128772.000000}  
	'16Wv'[][7][1]={17367.500000,50511.800781,81419.601563,160726.000000,311271.000000,190661.000000,192191.000000}  
	'16Wv'[][8][1]={54399.398438,218042.000000,699896.000000,1396900.000000,263840.000000,13336900.000000,13350400.000000}  
	'16Wv'[][9][1]={94464.601563,344550.000000,1532040.000000,3080350.000000,5097.200195,26273600.000000,26480800.000000}  
	'16Wv'[][10][1]={105087.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(7,11,2) '17Wv'  
	'17Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'17Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'17Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'17Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'17Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'17Wv'[][5][0]={60.166199,122.787003,91.613197,90.886200, 7.952540, 3.090130, 3.090130}  
	'17Wv'[][6][0]={12.230600, 5.073930, 3.785730, 3.755680, 0.328622, 0.127693, 0.127693}  
	'17Wv'[][7][0]={ 5.644800, 1.080800, 0.806400, 0.800000, 0.070000, 0.027200, 0.027200}  
	'17Wv'[][8][0]={ 3.669100, 0.456633, 0.340701, 0.337997, 0.029575, 0.011492, 0.011492}  
	'17Wv'[][9][0]={ 2.961320, 0.297452, 0.221933, 0.220172, 0.019265, 0.007486, 0.007486}  
	'17Wv'[][10][0]={ 2.825220, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'17Wv'[][0][1]={ 5.254140, 0.408017, 0.004982, 0.008186, 0.047339, 0.000439, 0.000539}  
	'17Wv'[][1][1]={162.141006,11.855100, 0.349480, 0.639392, 1.294620, 0.027814, 0.038119}  
	'17Wv'[][2][1]={4201.450195,278.075989,22.261000,42.352600,29.296000, 1.662590, 2.361640}  
	'17Wv'[][3][1]={78930.898438,4582.910156,1037.189941,2009.420044,478.583008,73.491203,106.294998}  
	'17Wv'[][4][1]={ 0.000000,49648.300781,33091.199219,64820.101563,5403.120117,2122.909912,3105.209961}  
	'17Wv'[][5][1]={12.965000, 0.106113, 0.002998, 0.004982,39.770302,66.647797,96.364098}  
	'17Wv'[][6][1]={1677.900024,1241.040039,469.980988,933.104004,42692.898438,197430.000000,295092.000000}  
	'17Wv'[][7][1]={14986.099609,42662.800781,61464.800781,123397.000000,342223.000000,462804.000000,665788.000000}  
	'17Wv'[][8][1]={47054.500000,190255.000000,560663.000000,1131530.000000,275203.000000,20593600.000000,30513600.000000}  
	'17Wv'[][9][1]={81640.601563,310957.000000,1384550.000000,2813500.000000,19442.500000,28671500.000000,43049600.000000}  
	'17Wv'[][10][1]={91375.296875, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(7,11,2) '18Wv'  
	'18Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'18Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'18Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'18Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'18Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'18Wv'[][5][0]={68.277397,145.417999,112.380997,111.426003,11.497100, 5.634940, 5.634940}  
	'18Wv'[][6][0]={13.879500, 6.009090, 4.643900, 4.604470, 0.475094, 0.232852, 0.232852}  
	'18Wv'[][7][0]={ 6.405800, 1.280000, 0.989200, 0.980800, 0.101200, 0.049600, 0.049600}  
	'18Wv'[][8][0]={ 4.163750, 0.540795, 0.417933, 0.414384, 0.042757, 0.020956, 0.020956}  
	'18Wv'[][9][0]={ 3.360540, 0.352275, 0.272243, 0.269931, 0.027852, 0.013651, 0.013651}  
	'18Wv'[][10][0]={ 3.206100, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'18Wv'[][0][1]={ 6.780460, 0.537746, 0.007536, 0.012321, 0.064864, 0.000718, 0.001171}  
	'18Wv'[][1][1]={205.873001,15.321600, 0.518802, 0.945011, 1.748610, 0.045013, 0.081758}  
	'18Wv'[][2][1]={5211.410156,349.144989,32.066101,60.812801,38.527802, 2.610000, 4.923710}  
	'18Wv'[][3][1]={ 0.000000,5530.569824,1437.979980,2780.080078,606.492981,110.124001,211.845001}  
	'18Wv'[][4][1]={ 0.000000,57250.000000,43965.000000,86040.398438,6609.770020,3000.179932,5842.470215}  
	'18Wv'[][5][1]={11.220700, 0.080581, 0.002034, 0.003250,19.125099,13.210200,25.158600}  
	'18Wv'[][6][1]={1451.260010,990.482971,325.794006,644.775024,27166.300781,91612.398438,181295.000000}  
	'18Wv'[][7][1]={13007.599609,35425.101563,45366.800781,91015.101563,268914.000000,198423.000000,407273.000000}  
	'18Wv'[][8][1]={40969.398438,163750.000000,443202.000000,894592.000000,284672.000000,10275700.000000,20135500.000000}  
	'18Wv'[][9][1]={71071.398438,276381.000000,1192490.000000,2427440.000000,42450.800781,15258300.000000,30561300.000000}  
	'18Wv'[][10][1]={79858.500000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(7,11,2) '19Wv'  
	'19Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'19Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'19Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'19Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'19Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'19Wv'[][5][0]={76.900299,171.365997,134.647995,133.421005,15.405200, 8.088870, 8.088870}  
	'19Wv'[][6][0]={15.632300, 7.081340, 5.564040, 5.513340, 0.636588, 0.334256, 0.334256}  
	'19Wv'[][7][0]={ 7.214800, 1.508400, 1.185200, 1.174400, 0.135600, 0.071200, 0.071200}  
	'19Wv'[][8][0]={ 4.689600, 0.637293, 0.500742, 0.496179, 0.057290, 0.030082, 0.030082}  
	'19Wv'[][9][0]={ 3.784950, 0.415134, 0.326185, 0.323213, 0.037319, 0.019595, 0.019595}  
	'19Wv'[][10][0]={ 3.611010, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'19Wv'[][0][1]={ 8.615590, 0.695426, 0.011099, 0.018051, 0.089548, 0.001234, 0.002019}  
	'19Wv'[][1][1]={257.381012,19.444000, 0.749247, 1.358730, 2.387570, 0.077721, 0.141052}  
	'19Wv'[][2][1]={6361.009766,430.744995,44.923000,84.923599,51.316601, 4.404200, 8.310270}  
	'19Wv'[][3][1]={ 0.000000,6562.669922,1933.979980,3731.179932,778.872009,177.011002,341.028015}  
	'19Wv'[][4][1]={ 0.000000,64891.699219,56408.500000,110303.000000,8213.990234,4530.330078,8845.389648}  
	'19Wv'[][5][1]={ 9.753150, 0.063388, 0.001547, 0.002378,11.399700, 6.190710,11.707300}  
	'19Wv'[][6][1]={1266.260010,788.968018,238.654999,470.764008,19505.699219,62596.101563,123851.000000}  
	'19Wv'[][7][1]={11374.299805,29275.800781,34589.000000,69328.601563,222586.000000,371855.000000,762296.000000}  
	'19Wv'[][8][1]={35897.300781,139686.000000,352951.000000,712622.000000,398011.000000,2104740.000000,4081950.000000}  
	'19Wv'[][9][1]={62242.500000,254293.000000,918932.000000,1866130.000000,198677.000000,26572800.000000,52652700.000000}  
	'19Wv'[][10][1]={70476.500000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(7,11,2) '20Wv'  
	'20Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'20Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'20Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'20Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'20Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'20Wv'[][5][0]={86.081703,198.949997,159.050995,157.414993,19.858601,11.542500,11.542500}  
	'20Wv'[][6][0]={17.498699, 8.221190, 6.572440, 6.504840, 0.820617, 0.476972, 0.476972}  
	'20Wv'[][7][0]={ 8.076200, 1.751200, 1.400000, 1.385600, 0.174800, 0.101600, 0.101600}  
	'20Wv'[][8][0]={ 5.249500, 0.739875, 0.591494, 0.585410, 0.073852, 0.042926, 0.042926}  
	'20Wv'[][9][0]={ 4.236850, 0.481957, 0.385301, 0.381338, 0.048108, 0.027962, 0.027962}  
	'20Wv'[][10][0]={ 4.042140, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'20Wv'[][0][1]={10.801200, 0.886401, 0.015982, 0.025875, 0.121024, 0.001984, 0.003221}  
	'20Wv'[][1][1]={317.500000,24.306601, 1.057440, 1.909580, 3.187520, 0.123838, 0.223583}  
	'20Wv'[][2][1]={7660.649902,523.445984,61.538101,115.956001,66.821297, 6.822750,12.849000}  
	'20Wv'[][3][1]={ 0.000000,7676.930176,2544.060059,4897.310059,979.659973,261.554993,503.649994}  
	'20Wv'[][4][1]={ 0.000000,72531.101563,70789.500000,138283.000000,10024.400391,6312.279785,12333.299805}  
	'20Wv'[][5][1]={ 8.589400, 0.051926, 0.001160, 0.001727, 7.391780, 2.691910, 5.035760}  
	'20Wv'[][6][1]={1112.520020,645.348999,180.251007,354.881012,14683.500000,38421.398438,75807.601563}  
	'20Wv'[][7][1]={10011.299805,24651.099609,26956.599609,54049.800781,186835.000000,406731.000000,827791.000000}  
	'20Wv'[][8][1]={31645.099609,120791.000000,284359.000000,574529.000000,421673.000000,350113.000000,700752.000000}  
	'20Wv'[][9][1]={54821.800781,221150.000000,774664.000000,1575390.000000,383247.000000,4626080.000000,9119560.000000}  
	'20Wv'[][10][1]={62620.800781, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(7,11,2) '21Wv'  
	'21Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'21Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'21Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'21Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'21Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'21Wv'[][5][0]={95.774696,227.397003,184.817001,182.772003,24.448400,14.678100,14.678100}  
	'21Wv'[][6][0]={19.469101, 9.396720, 7.637180, 7.552680, 1.010280, 0.606543, 0.606543}  
	'21Wv'[][7][0]={ 8.985600, 2.001600, 1.626800, 1.608800, 0.215200, 0.129200, 0.129200}  
	'21Wv'[][8][0]={ 5.840610, 0.845667, 0.687316, 0.679711, 0.090921, 0.054586, 0.054586}  
	'21Wv'[][9][0]={ 4.713930, 0.550871, 0.447720, 0.442766, 0.059226, 0.035558, 0.035558}  
	'21Wv'[][10][0]={ 4.497290, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'21Wv'[][0][1]={13.375500, 1.114670, 0.022595, 0.036338, 0.157317, 0.002941, 0.004760}  
	'21Wv'[][1][1]={387.105011,29.988501, 1.464560, 2.632030, 4.071920, 0.180803, 0.325097}  
	'21Wv'[][2][1]={9124.259766,628.362000,82.830299,155.574005,83.123299, 9.670060,18.151300}  
	'21Wv'[][3][1]={ 0.000000,8892.740234,3300.459961,6340.279785,1180.569946,354.716003,681.726990}  
	'21Wv'[][4][1]={ 0.000000,80391.898438,88189.601563,172182.000000,11781.099609,8119.830078,15855.299805}  
	'21Wv'[][5][1]={ 7.632460, 0.044459, 0.000955, 0.001371, 5.225140, 1.616270, 2.991890}  
	'21Wv'[][6][1]={985.741028,544.732971,142.253998,279.049988,11549.500000,27698.699219,54482.300781}  
	'21Wv'[][7][1]={8887.639648,21299.099609,21884.000000,43849.199219,158023.000000,365879.000000,742811.000000}  
	'21Wv'[][8][1]={28145.199219,106496.000000,237792.000000,480607.000000,381183.000000,277918.000000,575778.000000}  
	'21Wv'[][9][1]={48765.300781,198788.000000,660498.000000,1344320.000000,393902.000000,1868140.000000,3671600.000000}  
	'21Wv'[][10][1]={55765.898438, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(7,11,2) '22Wv'  
	'22Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'22Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'22Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'22Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'22Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'22Wv'[][5][0]={105.871002,256.162994,209.720001,206.992996,27.402201,15.723300,15.723300}  
	'22Wv'[][6][0]={21.521400,10.585400, 8.666240, 8.553570, 1.132340, 0.649733, 0.649733}  
	'22Wv'[][7][0]={ 9.932800, 2.254800, 1.846000, 1.822000, 0.241200, 0.138400, 0.138400}  
	'22Wv'[][8][0]={ 6.456290, 0.952643, 0.779927, 0.769787, 0.101906, 0.058473, 0.058473}  
	'22Wv'[][9][0]={ 5.210840, 0.620555, 0.508047, 0.501442, 0.066382, 0.038090, 0.038090}  
	'22Wv'[][10][0]={ 4.971370, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'22Wv'[][0][1]={16.378401, 1.383610, 0.031345, 0.050112, 0.199401, 0.004219, 0.006784}  
	'22Wv'[][1][1]={466.730011,36.528500, 1.989850, 3.559520, 5.072170, 0.254281, 0.454848}  
	'22Wv'[][2][1]={10741.299805,744.958008,109.355003,204.701996,100.853996,13.171900,24.637100}  
	'22Wv'[][3][1]={ 0.000000,10184.500000,4199.169922,8047.529785,1388.920044,462.252014,886.507019}  
	'22Wv'[][4][1]={ 0.000000,88024.500000,107379.000000,209401.000000,13522.400391,10030.299805,19570.900391}  
	'22Wv'[][5][1]={ 6.814140, 0.036959, 0.000847, 0.001191, 4.714820, 1.745930, 3.210360}  
	'22Wv'[][6][1]={881.864990,473.029999,120.095001,235.651993,10629.299805,28436.199219,55870.500000}  
	'22Wv'[][7][1]={7959.779785,18804.599609,18723.800781,37602.800781,147303.000000,360343.000000,732971.000000}  
	'22Wv'[][8][1]={25236.699219,95396.101563,206432.000000,418222.000000,361211.000000,275575.000000,575839.000000}  
	'22Wv'[][9][1]={43721.898438,180584.000000,581896.000000,1187200.000000,393500.000000,1358420.000000,2673430.000000}  
	'22Wv'[][10][1]={50025.101563, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(8,11,2) '23Wv'  
	'23Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'23Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'23Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'23Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'23Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'23Wv'[][5][0]={116.501999,285.472992,236.531006,233.078003,30.219601,17.177500,17.177500, 0.999748}  
	'23Wv'[][6][0]={23.682501,11.796600, 9.774160, 9.631450, 1.248760, 0.709824, 0.709824, 0.041313}  
	'23Wv'[][7][0]={10.930200, 2.512800, 2.082000, 2.051600, 0.266000, 0.151200, 0.151200, 0.008800}  
	'23Wv'[][8][0]={ 7.104590, 1.061650, 0.879636, 0.866792, 0.112384, 0.063881, 0.063881, 0.003718}  
	'23Wv'[][9][0]={ 5.734090, 0.691561, 0.572998, 0.564631, 0.073207, 0.041612, 0.041612, 0.002422}  
	'23Wv'[][10][0]={ 5.470570, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'23Wv'[][0][1]={19.859301, 1.697360, 0.042749, 0.067928, 0.248242, 0.005895, 0.009414, 0.000008}  
	'23Wv'[][1][1]={557.294006,43.980999, 2.658450, 4.733360, 6.206600, 0.348193, 0.619589, 0.001303}  
	'23Wv'[][2][1]={12524.900391,873.231995,142.065002,265.037994,120.278000,17.478100,32.573399, 0.193255}  
	'23Wv'[][3][1]={ 0.000000,11541.900391,5268.319824,10073.700195,1608.430054,587.835999,1124.900024,20.069099}  
	'23Wv'[][4][1]={ 0.000000,95371.703125,129183.000000,251757.000000,15290.299805,12128.700195,23648.599609,1380.060059}  
	'23Wv'[][5][1]={ 6.152570, 0.033135, 0.000721, 0.001000, 4.389100, 1.717440, 3.131780,1381.319946}  
	'23Wv'[][6][1]={793.151001,418.869995,102.273003,200.470993,9963.040039,27477.400391,53901.500000,5239240.000000}  
	'23Wv'[][7][1]={7166.370117,16851.099609,16152.099609,32481.699219,138626.000000,344221.000000,701182.000000,9182670.000000}  
	'23Wv'[][8][1]={22744.699219,86395.500000,180568.000000,366493.000000,342481.000000,266125.000000,560652.000000,10412800.000000}  
	'23Wv'[][9][1]={39397.199219,165305.000000,515993.000000,1054870.000000,385243.000000,1052710.000000,2076640.000000,10710500.000000}  
	'23Wv'[][10][1]={45205.300781, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(9,11,2) '24Wv'  
	'24Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'24Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'24Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'24Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'24Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'24Wv'[][5][0]={127.674004,315.648010,265.251007,261.070007,33.673302,19.313299,19.313299, 1.045190, 1.045190}  
	'24Wv'[][6][0]={25.953600,13.043500,10.961000,10.788200, 1.391480, 0.798082, 0.798082, 0.043190, 0.043190}  
	'24Wv'[][7][0]={11.978400, 2.778400, 2.334800, 2.298000, 0.296400, 0.170000, 0.170000, 0.009200, 0.009200}  
	'24Wv'[][8][0]={ 7.785920, 1.173860, 0.986443, 0.970895, 0.125228, 0.071824, 0.071824, 0.003887, 0.003887}  
	'24Wv'[][9][0]={ 6.283980, 0.764658, 0.642572, 0.632444, 0.081574, 0.046787, 0.046787, 0.002532, 0.002532}  
	'24Wv'[][10][0]={ 5.995190, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'24Wv'[][0][1]={23.858400, 2.062180, 0.057447, 0.090777, 0.302707, 0.007974, 0.012638, 0.000016, 0.000002}  
	'24Wv'[][1][1]={659.702026,52.438599, 3.501190, 6.205920, 7.432040, 0.460968, 0.815584, 0.002490, 0.000472}  
	'24Wv'[][2][1]={14486.900391,1014.190002,182.162003,338.714996,140.449997,22.434200,41.636902, 0.352081, 0.077981}  
	'24Wv'[][3][1]={ 0.000000,12981.000000,6545.919922,12490.799805,1828.280029,725.294006,1384.219971,35.309399, 8.360310}  
	'24Wv'[][4][1]={ 0.000000,102526.000000,154517.000000,301108.000000,17014.699219,14298.700195,27850.699219,2332.489990,565.273010}  
	'24Wv'[][5][1]={ 5.584670, 0.030258, 0.000645, 0.000881, 3.901130, 1.479130, 2.668070,1990.500000,482.098999}  
	'24Wv'[][6][1]={716.948975,375.973999,87.940804,171.919998,9012.980469,24397.000000,47729.000000,5731100.000000,1422490.000000}  
	'24Wv'[][7][1]={6486.020020,15277.200195,14092.799805,28343.900391,126690.000000,310076.000000,632149.000000,11103800.000000,2800120.000000}  
	'24Wv'[][8][1]={20613.400391,79048.101563,160078.000000,325226.000000,309776.000000,223924.000000,472556.000000,15900400.000000,4079130.000000}  
	'24Wv'[][9][1]={35712.601563,151559.000000,468846.000000,960945.000000,321822.000000,1302580.000000,2572400.000000,17579000.000000,4554580.000000}  
	'24Wv'[][10][1]={40917.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(9,11,2) '25Wv'  
	'25Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'25Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'25Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'25Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'25Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'25Wv'[][5][0]={139.393997,349.457001,296.015991,290.971985,38.126701,22.085300,22.085300, 3.299890, 3.246350}  
	'25Wv'[][6][0]={28.336100,14.440600,12.232300,12.023800, 1.575510, 0.912631, 0.912631, 0.136361, 0.134149}  
	'25Wv'[][7][0]={13.078000, 3.076000, 2.605600, 2.561200, 0.335600, 0.194400, 0.194400, 0.029046, 0.028575}  
	'25Wv'[][8][0]={ 8.500660, 1.299600, 1.100850, 1.082100, 0.141790, 0.082133, 0.082133, 0.012272, 0.012073}  
	'25Wv'[][9][0]={ 6.860840, 0.846562, 0.717100, 0.704881, 0.092362, 0.053502, 0.053502, 0.007994, 0.007864}  
	'25Wv'[][10][0]={ 6.545540, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'25Wv'[][0][1]={28.420900, 2.478260, 0.076023, 0.119361, 0.369769, 0.010851, 0.017044, 0.000028, 0.000004}  
	'25Wv'[][1][1]={774.182983,61.882801, 4.540180, 8.009090, 8.926790, 0.614777, 1.081660, 0.004537, 0.000859}  
	'25Wv'[][2][1]={16600.400391,1166.319946,229.839005,425.920990,164.651001,29.017099,53.681599, 0.637379, 0.141584}  
	'25Wv'[][3][1]={ 0.000000,14460.000000,7990.759766,15215.700195,2087.090088,900.749023,1716.150024,61.796001,14.681500}  
	'25Wv'[][4][1]={ 0.000000,109372.000000,180338.000000,351553.000000,18974.699219,16910.500000,32937.601563,3924.169922,954.534973}  
	'25Wv'[][5][1]={ 5.094750, 0.027375, 0.000580, 0.000786, 3.253460, 1.213440, 2.162770,42.098499,10.656400}  
	'25Wv'[][6][1]={650.500000,333.640991,75.900002,148.009003,7935.609863,20973.199219,40929.800781,1352010.000000,346167.000000}  
	'25Wv'[][7][1]={5888.910156,13715.900391,12276.900391,24697.000000,114449.000000,287629.000000,586109.000000,6780920.000000,1705720.000000}  
	'25Wv'[][8][1]={18730.199219,71665.796875,140811.000000,286420.000000,292233.000000,238536.000000,510701.000000,5107830.000000,1301680.000000}  
	'25Wv'[][9][1]={32452.099609,139515.000000,412272.000000,845586.000000,339665.000000,650342.000000,1289950.000000,3621650.000000,926459.000000}  
	'25Wv'[][10][1]={37298.300781, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(9,11,2) '26Wv'  
	'26Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'26Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'26Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'26Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'26Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'26Wv'[][5][0]={151.608994,384.493988,327.690002,321.782013,42.216599,24.539301,24.539301, 1.635950, 1.635950}  
	'26Wv'[][6][0]={30.819201,15.888400,13.541100,13.297000, 1.744510, 1.014030, 1.014030, 0.067602, 0.067602}  
	'26Wv'[][7][0]={14.224000, 3.384400, 2.884400, 2.832400, 0.371600, 0.216000, 0.216000, 0.014400, 0.014400}  
	'26Wv'[][8][0]={ 9.245550, 1.429890, 1.218650, 1.196680, 0.156999, 0.091259, 0.091259, 0.006084, 0.006084}  
	'26Wv'[][9][0]={ 7.462050, 0.931438, 0.793830, 0.779519, 0.102270, 0.059446, 0.059446, 0.003963, 0.003963}  
	'26Wv'[][10][0]={ 7.119110, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'26Wv'[][0][1]={33.596699, 2.952980, 0.099439, 0.155009, 0.443231, 0.014340, 0.022411, 0.000044, 0.000012}  
	'26Wv'[][1][1]={901.827026,72.434097, 5.818860,10.213500,10.524400, 0.796495, 1.394970, 0.006916, 0.002617}  
	'26Wv'[][2][1]={18909.099609,1331.500000,286.808014,529.719971,189.634995,36.494301,67.266296, 0.943885, 0.418636}  
	'26Wv'[][3][1]={ 0.000000,16011.599609,9667.259766,18373.699219,2345.000000,1089.900024,2072.010010,88.191101,41.846100}  
	'26Wv'[][4][1]={ 0.000000,115667.000000,209152.000000,407789.000000,20846.900391,19528.900391,38024.898438,5344.890137,2598.330078}  
	'26Wv'[][5][1]={ 4.647990, 0.025147, 0.000534, 0.000720, 2.902820, 1.076150, 1.896220,904.588013,436.013000}  
	'26Wv'[][6][1]={593.257996,299.204010,66.812599,129.785995,7199.490234,18903.800781,36796.000000,4360850.000000,2171090.000000}  
	'26Wv'[][7][1]={5374.180176,12430.000000,10892.299805,21899.699219,105066.000000,265301.000000,540919.000000,6479450.000000,3276080.000000}  
	'26Wv'[][8][1]={17106.800781,65528.398438,126080.000000,256621.000000,271252.000000,225421.000000,485733.000000,6033490.000000,3056090.000000}  
	'26Wv'[][9][1]={29643.800781,128504.000000,372604.000000,765136.000000,318037.000000,544294.000000,1083630.000000,5995080.000000,3007960.000000}  
	'26Wv'[][10][1]={34122.898437, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(9,11,2) '27Wv'  
	'27Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'27Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'27Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'27Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'27Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'27Wv'[][5][0]={164.334000,420.621002,360.635986,353.820007,45.761200,27.038601,27.038601, 1.317850, 1.317850}  
	'27Wv'[][6][0]={33.405800,17.381300,14.902500,14.620900, 1.890990, 1.117320, 1.117320, 0.054457, 0.054457}  
	'27Wv'[][7][0]={15.417800, 3.702400, 3.174400, 3.114400, 0.402800, 0.238000, 0.238000, 0.011600, 0.011600}  
	'27Wv'[][8][0]={10.021500, 1.564250, 1.341170, 1.315820, 0.170181, 0.100554, 0.100554, 0.004901, 0.004901}  
	'27Wv'[][9][0]={ 8.088320, 1.018960, 0.873643, 0.857130, 0.110857, 0.065501, 0.065501, 0.003192, 0.003192}  
	'27Wv'[][10][0]={ 7.716610, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'27Wv'[][0][1]={39.431301, 3.492100, 0.128448, 0.199024, 0.527080, 0.018688, 0.028988, 0.000066, 0.000028}  
	'27Wv'[][1][1]={1043.130005,84.128197, 7.370030,12.876200,12.297300, 1.017610, 1.772660, 0.010247, 0.005796}  
	'27Wv'[][2][1]={21369.300781,1508.709961,353.903992,651.492004,216.457993,45.282398,83.153900, 1.360490, 0.903280}  
	'27Wv'[][3][1]={ 0.000000,17605.800781,11571.700195,21956.599609,2613.659912,1302.380005,2470.610107,122.745003,87.219498}  
	'27Wv'[][4][1]={ 0.000000,121267.000000,239974.000000,468721.000000,22692.300781,22269.199219,43352.500000,7140.049805,5200.959961}  
	'27Wv'[][5][1]={ 4.281470, 0.023473, 0.000496, 0.000673, 2.735000, 0.973131, 1.693540,2703.989990,1960.569946}  
	'27Wv'[][6][1]={543.328979,270.816986,59.511002,115.055000,6767.109863,17233.900391,33457.500000,5272270.000000,3948210.000000}  
	'27Wv'[][7][1]={4923.979980,11345.900391,9754.959961,19594.400391,98785.203125,245676.000000,501270.000000,5839490.000000,4443490.000000}  
	'27Wv'[][8][1]={15684.000000,60245.500000,113755.000000,231615.000000,255470.000000,212414.000000,460572.000000,6107420.000000,4623940.000000}  
	'27Wv'[][9][1]={27185.000000,118856.000000,338722.000000,696498.000000,301436.000000,467092.000000,933397.000000,6859510.000000,5131740.000000}  
	'27Wv'[][10][1]={31321.699219, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(9,11,2) '28Wv'  
	'28Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'28Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'28Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'28Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'28Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'28Wv'[][5][0]={177.632996,21.490101,396.217987,388.402008,50.805401,30.946699,30.946699, 1.635950, 1.635950}  
	'28Wv'[][6][0]={36.109402, 4.368510,16.372900,16.049900, 2.099430, 1.278810, 1.278810, 0.067602, 0.067602}  
	'28Wv'[][7][0]={16.665600, 2.016200, 3.487600, 3.418800, 0.447200, 0.272400, 0.272400, 0.014400, 0.014400}  
	'28Wv'[][8][0]={10.832600, 1.310520, 1.473500, 1.444430, 0.188940, 0.115088, 0.115088, 0.006084, 0.006084}  
	'28Wv'[][9][0]={ 8.742930, 1.057720, 0.959840, 0.940905, 0.123076, 0.074969, 0.074969, 0.003963, 0.003963}  
	'28Wv'[][10][0]={ 8.341130, 1.009110, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'28Wv'[][0][1]={45.969299, 4.098780, 0.164238, 0.252629, 0.620444, 0.024099, 0.037100, 0.000097, 0.000054}  
	'28Wv'[][1][1]={1198.949951,97.001900, 9.240360,16.062300,14.243700, 1.285170, 2.226660, 0.014839, 0.011158}  
	'28Wv'[][2][1]={23975.099609,1697.910034,432.608002,793.752991,245.278000,55.559700,101.644997, 1.916030, 1.692580}  
	'28Wv'[][3][1]={ 0.000000,19234.199219,13745.700195,26041.099609,2896.929932,1541.969971,2918.949951,167.095001,158.037994}  
	'28Wv'[][4][1]={ 0.000000, 0.000000,277654.000000,541307.000000,24583.400391,25191.400391,49043.500000,9355.450195,9076.379883}  
	'28Wv'[][5][1]={ 3.956730,175.453003, 0.000460, 0.000634, 2.322500, 0.763313, 1.308910,1645.670044,1582.099976}  
	'28Wv'[][6][1]={499.031006,8759.099609,52.934601,101.764999,6039.979980,14306.599609,27669.099609,4322540.000000,4310800.000000}  
	'28Wv'[][7][1]={4524.919922,41247.199219,8730.519531,17515.000000,89677.101563,218936.000000,446311.000000,4872570.000000,4948050.000000}  
	'28Wv'[][8][1]={14424.599609,85691.000000,102717.000000,209194.000000,235189.000000,199738.000000,435479.000000,4804620.000000,4847300.000000}  
	'28Wv'[][9][1]={25003.699219,115743.000000,308361.000000,634733.000000,278220.000000,384962.000000,771988.000000,5332220.000000,5294120.000000}  
	'28Wv'[][10][1]={28779.599609,125380.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(9,11,2) '29Wv'  
	'29Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'29Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'29Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'29Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'29Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'29Wv'[][5][0]={191.406998,23.365999,432.164001,423.119995,54.440800,33.446098,33.446098, 0.727089, 0.727089}  
	'29Wv'[][6][0]={38.909199, 4.749850,17.858299,17.484600, 2.249650, 1.382090, 1.382090, 0.030046, 0.030046}  
	'29Wv'[][7][0]={17.957800, 2.192200, 3.804000, 3.724400, 0.479200, 0.294400, 0.294400, 0.006400, 0.006400}  
	'29Wv'[][8][0]={11.672500, 1.424920, 1.607170, 1.573540, 0.202460, 0.124383, 0.124383, 0.002704, 0.002704}  
	'29Wv'[][9][0]={ 9.420830, 1.150050, 1.046920, 1.025010, 0.131883, 0.081023, 0.081023, 0.001761, 0.001761}  
	'29Wv'[][10][0]={ 8.987880, 1.097200, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'29Wv'[][0][1]={53.275200, 4.777000, 0.207877, 0.317747, 0.722816, 0.030504, 0.046487, 0.000134, 0.000112}  
	'29Wv'[][1][1]={1370.020020,111.154999,11.477400,19.855600,16.298100, 1.591640, 2.739260, 0.019556, 0.021889}  
	'29Wv'[][2][1]={ 0.000000,1901.579956,524.465027,959.083008,274.493988,66.856796,121.780998, 2.423530, 3.189540}  
	'29Wv'[][3][1]={ 0.000000,20946.099609,16219.500000,30679.800781,3175.110107,1792.959961,3385.159912,204.524002,288.272003}  
	'29Wv'[][4][1]={ 0.000000, 0.000000,335328.000000,642350.000000,26342.500000,27991.199219,54478.800781,11062.700195,16006.700195}  
	'29Wv'[][5][1]={ 3.675580,159.815994, 0.000435, 0.000614, 2.214260, 0.722356, 1.223890,31380.800781,45622.199219}  
	'29Wv'[][6][1]={460.388000,8044.520020,47.988602,91.837601,5730.029785,13405.500000,25846.099609,4706220.000000,7098640.000000}  
	'29Wv'[][7][1]={4176.020020,38107.199219,7946.919922,15938.000000,84846.796875,202316.000000,413025.000000,6409200.000000,9932950.000000}  
	'29Wv'[][8][1]={13321.400391,79578.398438,94237.898438,192159.000000,216483.000000,164978.000000,362459.000000,8098560.000000,12575800.000000}  
	'29Wv'[][9][1]={23094.599609,107952.000000,285755.000000,590128.000000,234566.000000,484288.000000,968524.000000,9343090.000000,14364400.000000}  
	'29Wv'[][10][1]={26531.400391,98264.703125, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(9,11,2) '30Wv'  
	'30Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'30Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'30Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'30Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'30Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'30Wv'[][5][0]={205.895996,25.444401,22.229799,21.737301,61.757099,39.353699,39.353699, 3.680890, 3.680890}  
	'30Wv'[][6][0]={41.854599, 5.172350, 4.518880, 4.418770, 2.551990, 1.626210, 1.626210, 0.152105, 0.152105}  
	'30Wv'[][7][0]={19.317200, 2.387200, 2.085600, 2.039400, 0.543600, 0.346400, 0.346400, 0.032400, 0.032400}  
	'30Wv'[][8][0]={12.556100, 1.551670, 1.355630, 1.325600, 0.229669, 0.146353, 0.146353, 0.013689, 0.013689}  
	'30Wv'[][9][0]={10.134000, 1.252350, 1.094130, 1.069890, 0.149607, 0.095335, 0.095335, 0.008917, 0.008917}  
	'30Wv'[][10][0]={ 9.668260, 1.194790, 1.043840, 1.020720, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'30Wv'[][0][1]={61.385101, 5.532300, 0.260641, 0.395632, 0.843118, 0.038758, 0.058645, 0.000197, 0.000164}  
	'30Wv'[][1][1]={1556.510010,126.529999,14.119600,24.304001,18.713699, 1.983630, 3.396990, 0.029217, 0.032747}  
	'30Wv'[][2][1]={ 0.000000,2115.270020,629.830017,1147.849976,308.696991,81.058502,147.175995, 3.585380, 4.729950}  
	'30Wv'[][3][1]={ 0.000000,22648.300781,18958.199219,35802.500000,3499.219971,2100.580078,3960.260010,293.221985,414.446991}  
	'30Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,28351.599609,31268.099609,60918.101563,15270.900391,22173.500000}  
	'30Wv'[][5][1]={ 3.417380,144.203995,27.090599,51.206200, 1.810620, 0.500795, 0.831810,132.654999,185.929001}  
	'30Wv'[][6][1]={424.862000,7324.250000,5521.709961,11047.599609,4876.259766,10337.099609,19836.199219,1802450.000000,2675330.000000}  
	'30Wv'[][7][1]={3855.020020,34937.398438,53473.500000,108700.000000,74630.898438,176976.000000,360243.000000,3597670.000000,5466530.000000}  
	'30Wv'[][8][1]={12305.700195,73252.296875,167395.000000,343778.000000,200414.000000,176503.000000,388555.000000,2548660.000000,3880210.000000}  
	'30Wv'[][9][1]={21342.199219,99417.796875,300248.000000,622573.000000,237135.000000,277111.000000,559753.000000,2326430.000000,3443700.000000}  
	'30Wv'[][10][1]={24597.900391,107037.000000,1333240.000000,2775660.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(9,11,2) '31Wv'  
	'31Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'31Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'31Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'31Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'31Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'31Wv'[][5][0]={220.998993,27.663601,24.350800,23.777399,71.845497,48.533199,46.760899, 7.907090, 7.907090}  
	'31Wv'[][6][0]={44.924900, 5.623460, 4.950050, 4.833480, 2.968870, 2.005530, 1.932300, 0.326744, 0.326744}  
	'31Wv'[][7][0]={20.734200, 2.595400, 2.284600, 2.230800, 0.632400, 0.427200, 0.411600, 0.069600, 0.069600}  
	'31Wv'[][8][0]={13.477200, 1.687000, 1.484980, 1.450010, 0.267186, 0.180490, 0.173899, 0.029406, 0.029406}  
	'31Wv'[][9][0]={10.877400, 1.361570, 1.198520, 1.170300, 0.174046, 0.117572, 0.113279, 0.019155, 0.019155}  
	'31Wv'[][10][0]={10.377500, 1.299000, 1.143440, 1.116520, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'31Wv'[][0][1]={70.351501, 6.368800, 0.323960, 0.488046, 0.980048, 0.048897, 0.073582, 0.000286, 0.000236}  
	'31Wv'[][1][1]={1759.010010,143.186996,17.223000,29.489901,21.416800, 2.457860, 4.189870, 0.042668, 0.047747}  
	'31Wv'[][2][1]={ 0.000000,2339.800049,750.229980,1362.550049,346.233002,97.832298,176.936996, 5.155940, 6.806130}  
	'31Wv'[][3][1]={ 0.000000,24352.500000,21983.400391,41448.898438,3849.909912,2453.610107,4610.370117,408.520996,578.010986}  
	'31Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,30489.500000,34869.199219,67755.796875,20417.800781,29699.800781}  
	'31Wv'[][5][1]={ 3.186050,130.087997,23.870600,44.849300, 1.327880, 0.302032, 0.556340, 8.490550,11.316000}  
	'31Wv'[][6][1]={392.891998,6664.979980,4887.520020,9771.769531,3933.510010,7056.100098,14740.500000,496642.000000,733049.000000}  
	'31Wv'[][7][1]={3565.459961,32003.000000,47695.398438,97009.101563,63336.601563,145256.000000,307470.000000,3697580.000000,5574050.000000}  
	'31Wv'[][8][1]={11387.900391,67459.703125,150168.000000,308733.000000,180888.000000,194212.000000,427068.000000,1791700.000000,2732380.000000}  
	'31Wv'[][9][1]={19762.400391,93002.203125,264293.000000,547965.000000,223852.000000,153909.000000,334535.000000,1466860.000000,2190760.000000}  
	'31Wv'[][10][1]={22863.099609,97879.898438,1161610.000000,2423530.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(9,11,2) '32Wv'  
	'32Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'32Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'32Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'32Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'32Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'32Wv'[][5][0]={236.688995,30.149200,26.599800,25.936899,81.797501,58.121700,54.895199,13.042200,13.042200}  
	'32Wv'[][6][0]={48.114201, 6.128740, 5.407220, 5.272460, 3.380110, 2.401760, 2.268430, 0.538940, 0.538940}  
	'32Wv'[][7][0]={22.206200, 2.828600, 2.495600, 2.433400, 0.720000, 0.511600, 0.483200, 0.114800, 0.114800}  
	'32Wv'[][8][0]={14.434000, 1.838580, 1.622130, 1.581700, 0.304197, 0.216149, 0.204150, 0.048503, 0.048503}  
	'32Wv'[][9][0]={11.649600, 1.483910, 1.309220, 1.276580, 0.198155, 0.140800, 0.132984, 0.031595, 0.031595}  
	'32Wv'[][10][0]={11.114200, 1.415710, 1.249050, 1.217920, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'32Wv'[][0][1]={80.224602, 7.289650, 0.399252, 0.597487, 1.135510, 0.061461, 0.091695, 0.000411, 0.000338}  
	'32Wv'[][1][1]={1978.030029,161.231995,20.842100,35.507801,24.431400, 3.030550, 5.138130, 0.060921, 0.068171}  
	'32Wv'[][2][1]={ 0.000000,2578.179932,887.158997,1605.670044,387.217987,117.448997,211.667007, 7.220770, 9.529970}  
	'32Wv'[][3][1]={ 0.000000,26116.599609,25319.000000,47667.300781,4224.910156,2851.639893,5344.660156,554.849976,785.182007}  
	'32Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,32690.699219,38661.000000,75049.703125,26606.199219,38736.000000}  
	'32Wv'[][5][1]={ 2.979580,116.148003,21.120899,39.424900, 1.066910, 0.194859, 0.374449, 1.409500, 1.787510}  
	'32Wv'[][6][1]={364.208008,6021.060059,4340.140137,8668.750000,3305.139893,5125.180176,11211.900391,170373.000000,250344.000000}  
	'32Wv'[][7][1]={3305.439941,29166.099609,42661.199219,86800.500000,55324.199219,121457.000000,263859.000000,2955300.000000,4433120.000000}  
	'32Wv'[][8][1]={10563.299805,61864.898438,135140.000000,278111.000000,165297.000000,203937.000000,451812.000000,1788000.000000,2723440.000000}  
	'32Wv'[][9][1]={18339.800781,85900.500000,236204.000000,490046.000000,210960.000000,119521.000000,274453.000000,925162.000000,1394700.000000}  
	'32Wv'[][10][1]={21252.500000,91946.796875,1025460.000000,2151650.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(9,11,2) '33Wv'  
	'33Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'33Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'33Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'33Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'33Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'33Wv'[][5][0]={252.966995,32.541000,28.961800,28.205000,92.476700,66.528702,63.847500,18.722500,18.722500}  
	'33Wv'[][6][0]={51.423199, 6.614940, 5.887370, 5.733530, 3.821410, 2.749160, 2.638370, 0.773671, 0.773671}  
	'33Wv'[][7][0]={23.733400, 3.053000, 2.717200, 2.646200, 0.814000, 0.585600, 0.562000, 0.164800, 0.164800}  
	'33Wv'[][8][0]={15.426600, 1.984440, 1.766170, 1.720020, 0.343912, 0.247414, 0.237443, 0.069627, 0.069627}  
	'33Wv'[][9][0]={12.450800, 1.601630, 1.425470, 1.388220, 0.224025, 0.161166, 0.154671, 0.045355, 0.045355}  
	'33Wv'[][10][0]={11.878600, 1.528030, 1.359960, 1.324420, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'33Wv'[][0][1]={91.058998, 8.302340, 0.488622, 0.725964, 1.310270, 0.076720, 0.113692, 0.000581, 0.000477}  
	'33Wv'[][1][1]={2214.209961,180.559998,25.042601,42.443802,27.761200, 3.710090, 6.262900, 0.085260, 0.095275}  
	'33Wv'[][2][1]={ 0.000000,2823.689941,1041.920044,1879.380005,431.583008,139.957001,251.658997, 9.888420,13.043600}  
	'33Wv'[][3][1]={ 0.000000,27807.400391,28968.400391,54474.199219,4623.310059,3287.159912,6162.209961,737.481018,1043.500000}  
	'33Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,34990.601563,42463.300781,82752.796875,33899.000000,49382.601563}  
	'33Wv'[][5][1]={ 2.779990,106.028999,18.808901,34.841400, 0.875532, 0.146437, 0.268082, 0.408280, 0.488065}  
	'33Wv'[][6][1]={338.074005,5528.850098,3873.250000,7723.310059,2808.810059,4137.729980,8669.269531,74780.500000,109408.000000}  
	'33Wv'[][7][1]={3071.300049,26914.699219,38317.699219,77956.703125,48673.500000,106420.000000,226514.000000,2276190.000000,3403490.000000}  
	'33Wv'[][8][1]={9819.919922,57309.300781,122052.000000,251347.000000,152044.000000,207359.000000,457978.000000,1982260.000000,3013130.000000}  
	'33Wv'[][9][1]={17059.800781,79884.000000,212554.000000,441192.000000,200913.000000,121933.000000,282961.000000,636077.000000,961700.000000}  
	'33Wv'[][10][1]={19765.800781,86638.796875,910311.000000,1911490.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(9,11,2) '34Wv'  
	'34Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'34Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'34Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'34Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'34Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'34Wv'[][5][0]={269.830994,35.256802,31.468700,30.607500,105.200996,76.435303,73.572304,25.766199,25.766199}  
	'34Wv'[][6][0]={54.851398, 7.167020, 6.396970, 6.221910, 4.347200, 3.158530, 3.040220, 1.064740, 1.064740}  
	'34Wv'[][7][0]={25.315599, 3.307800, 2.952400, 2.871600, 0.926000, 0.672800, 0.647600, 0.226800, 0.226800}  
	'34Wv'[][8][0]={16.455099, 2.150060, 1.919050, 1.866530, 0.391231, 0.284255, 0.273608, 0.095822, 0.095822}  
	'34Wv'[][9][0]={13.280800, 1.735300, 1.548860, 1.506470, 0.254849, 0.185165, 0.178229, 0.062419, 0.062419}  
	'34Wv'[][10][0]={12.670500, 1.655550, 1.477680, 1.437240, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'34Wv'[][0][1]={102.903999, 9.413550, 0.593882, 0.875946, 1.507310, 0.095102, 0.139977, 0.000809, 0.000662}  
	'34Wv'[][1][1]={2467.750000,201.408997,29.891399,50.396301,31.431700, 4.511310, 7.581200, 0.117164, 0.130726}  
	'34Wv'[][2][1]={ 0.000000,3084.020020,1216.390015,2186.659912,479.497009,165.746994,297.261993,13.290900,17.518900}  
	'34Wv'[][3][1]={ 0.000000,29570.900391,32970.699219,61936.398438,5048.240234,3769.600098,7063.009766,963.809021,1363.390015}  
	'34Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,37444.199219,46480.398438,90829.398438,42543.800781,62003.898438}  
	'34Wv'[][5][1]={ 2.613090,95.526497,16.794100,30.863001, 0.671761, 0.111424, 0.190036, 0.137164, 0.154018}  
	'34Wv'[][6][1]={314.813995,5028.899902,3464.040039,6894.740234,2349.340088,3291.010010,6817.169922,34927.300781,50843.101563}  
	'34Wv'[][7][1]={2859.959961,24670.199219,34490.500000,70160.898438,42372.898438,92255.601563,195496.000000,1639090.000000,2443790.000000}  
	'34Wv'[][8][1]={9148.330078,52813.601563,110469.000000,227645.000000,138260.000000,204267.000000,450909.000000,2139140.000000,3244720.000000}  
	'34Wv'[][9][1]={15902.400391,73890.203125,192158.000000,399124.000000,189296.000000,134721.000000,315884.000000,459565.000000,694652.000000}  
	'34Wv'[][10][1]={18405.300781,80790.601563,806455.000000,1695920.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(9,11,2) '35Wv'  
	'35Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'35Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'35Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'35Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'35Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'35Wv'[][5][0]={287.223999,37.987598,34.022499,33.039799,116.560997,86.023697,82.479202,31.855600,31.355700}  
	'35Wv'[][6][0]={58.387001, 7.722130, 6.916120, 6.716350, 4.816660, 3.554750, 3.408280, 1.316370, 1.295710}  
	'35Wv'[][7][0]={26.947399, 3.564000, 3.192000, 3.099800, 1.026000, 0.757200, 0.726000, 0.280400, 0.276000}  
	'35Wv'[][8][0]={17.515699, 2.316590, 2.074790, 2.014860, 0.433481, 0.319914, 0.306732, 0.118468, 0.116609}  
	'35Wv'[][9][0]={14.136900, 1.869710, 1.674550, 1.626180, 0.282371, 0.208393, 0.199806, 0.077170, 0.075959}  
	'35Wv'[][10][0]={13.487200, 1.783780, 1.597600, 1.551450, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'35Wv'[][0][1]={115.802002,10.624200, 0.717057, 1.049390, 1.724060, 0.117057, 0.171111, 0.001109, 0.000903}  
	'35Wv'[][1][1]={2738.540039,223.628998,35.442600,59.430599,35.412601, 5.446460, 9.110560, 0.158324, 0.176224}  
	'35Wv'[][2][1]={ 0.000000,3352.689941,1410.520020,2526.899902,530.380981,194.888000,348.548004,17.543100,23.094601}  
	'35Wv'[][3][1]={ 0.000000,31288.800781,37236.199219,69876.796875,5485.790039,4290.669922,8031.589844,1235.589966,1745.569946}  
	'35Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,39851.398438,50516.101563,98925.000000,52167.101562,75881.296875}  
	'35Wv'[][5][1]={ 2.464360,87.076202,15.190600,27.712200, 0.576584, 0.091259, 0.153153, 0.072766, 0.084068}  
	'35Wv'[][6][1]={293.933014,4614.439941,3129.469971,6221.359863,2067.879883,2744.770020,5720.560059,21845.500000,33285.601563}  
	'35Wv'[][7][1]={2669.649902,22768.400391,31291.900391,63677.000000,38239.398438,81830.703125,174394.000000,1291750.000000,1971110.000000}  
	'35Wv'[][8][1]={8542.259766,48947.398438,100619.000000,207571.000000,128470.000000,199422.000000,441952.000000,2164520.000000,3277090.000000}  
	'35Wv'[][9][1]={14855.799805,68661.296875,174957.000000,364118.000000,181361.000000,151312.000000,357867.000000,369368.000000,564616.000000}  
	'35Wv'[][10][1]={17168.500000,75400.796875,717155.000000,1505880.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(9,11,2) '36Wv'  
	'36Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'36Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'36Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'36Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'36Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'36Wv'[][5][0]={305.384003,40.950699,36.819401,35.704498,131.026001,101.202003,97.157303,40.398899,40.398899}  
	'36Wv'[][6][0]={62.078602, 8.324470, 7.484660, 7.258020, 5.414380, 4.181950, 4.014820, 1.669400, 1.669400}  
	'36Wv'[][7][0]={28.651199, 3.842000, 3.454400, 3.349800, 1.153320, 0.890800, 0.855200, 0.355600, 0.355600}  
	'36Wv'[][8][0]={18.623199, 2.497290, 2.245350, 2.177360, 0.487273, 0.376359, 0.361318, 0.150239, 0.150239}  
	'36Wv'[][9][0]={15.030700, 2.015550, 1.812210, 1.757340, 0.317411, 0.245162, 0.235364, 0.097866, 0.097866}  
	'36Wv'[][10][0]={14.339900, 1.922920, 1.728930, 1.676570, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'36Wv'[][0][1]={129.996002,11.942000, 0.860746, 1.250330, 1.963700, 0.143167, 0.208088, 0.001499, 0.001217}  
	'36Wv'[][1][1]={3029.050049,247.393005,41.803101,69.720901,39.744598, 6.538220,10.891300, 0.210860, 0.234330}  
	'36Wv'[][2][1]={ 0.000000,3634.129883,1629.109985,2908.560059,584.966003,228.272995,407.197998,22.847401,30.060400}  
	'36Wv'[][3][1]={ 0.000000,33032.500000,41976.500000,78711.796875,5951.279785,4881.629883,9133.870117,1567.290039,2215.639893}  
	'36Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,42458.300781,55085.300781,108258.000000,63664.199219,92852.203125}  
	'36Wv'[][5][1]={ 2.326210,78.644997,13.648600,24.688499, 0.475202, 0.061402, 0.098876, 0.033608, 0.033555}  
	'36Wv'[][6][1]={274.609985,4222.160156,2812.360107,5580.729980,1761.069946,2028.229980,4190.490234,12333.900391,17778.699219}  
	'36Wv'[][7][1]={2494.080078,20975.099609,28296.900391,57580.101563,33711.101563,67512.296875,143477.000000,935435.000000,1389060.000000}  
	'36Wv'[][8][1]={7984.879883,45307.500000,91485.898438,188882.000000,117090.000000,185535.000000,410401.000000,2128650.000000,3219010.000000}  
	'36Wv'[][9][1]={13894.299805,63711.898438,159344.000000,332067.000000,170235.000000,159879.000000,378941.000000,295130.000000,444753.000000}  
	'36Wv'[][10][1]={16032.099609,70149.703125,637128.000000,1340000.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(9,11,2) '37Wv'  
	'37Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'37Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'37Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'37Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'37Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'37Wv'[][5][0]={324.018005,44.022499,39.733501,38.465099,146.371994,112.426003,108.382004,50.805401,50.123699}  
	'37Wv'[][6][0]={65.866501, 8.948920, 8.077040, 7.819200, 6.048530, 4.645780, 4.478650, 2.099430, 2.071260}  
	'37Wv'[][7][0]={30.399401, 4.130200, 3.727800, 3.608800, 1.288400, 0.989600, 0.954000, 0.447200, 0.441200}  
	'37Wv'[][8][0]={19.759501, 2.684620, 2.423060, 2.345710, 0.544344, 0.418102, 0.403061, 0.188940, 0.186405}  
	'37Wv'[][9][0]={15.947800, 2.166740, 1.955640, 1.893210, 0.354587, 0.272353, 0.262555, 0.123076, 0.121425}  
	'37Wv'[][10][0]={15.214900, 2.067170, 1.865760, 1.806200, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'37Wv'[][0][1]={145.151001,13.368500, 1.026730, 1.480780, 2.229200, 0.173849, 0.250937, 0.001996, 0.001618}  
	'37Wv'[][1][1]={3335.250000,272.545990,49.000900,81.290100,44.425800, 7.786260,12.911800, 0.276898, 0.307256}  
	'37Wv'[][2][1]={ 0.000000,3922.280029,1869.270020,3325.669922,642.403015,264.756012,471.177002,29.340500,38.544498}  
	'37Wv'[][3][1]={ 0.000000,34714.898438,46924.101563,87919.500000,6425.020020,5475.890137,10247.400391,1958.400024,2763.939941}  
	'37Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,45004.000000,59050.398438,116534.000000,76366.898438,111083.000000}  
	'37Wv'[][5][1]={ 2.203700,71.662399,12.334300,22.134001, 0.379439, 0.051995, 0.080014, 0.015699, 0.015646}  
	'37Wv'[][6][1]={257.035004,3874.449951,2535.959961,5025.319824,1512.920044,1728.849976,3515.189941,6946.479980,10406.099609}  
	'37Wv'[][7][1]={2335.370117,19358.699219,25624.300781,52153.300781,29823.300781,60143.699219,126855.000000,651207.000000,990322.000000}  
	'37Wv'[][8][1]={7478.149902,41990.601563,83175.500000,171870.000000,106568.000000,179116.000000,395169.000000,2144910.000000,3254540.000000}  
	'37Wv'[][9][1]={13017.000000,59185.300781,145148.000000,302482.000000,166563.000000,170479.000000,401145.000000,288034.000000,431920.000000}  
	'37Wv'[][10][1]={15004.700195,64918.300781,169550.000000,355350.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(12,11,2) '38Wv'  
	'38Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'38Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'38Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'38Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'38Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'38Wv'[][5][0]={343.308014,47.245701,42.779701,41.347198,162.459000,127.150002,122.287003,61.348202,60.484699,17.132000, 9.043170, 9.043170}  
	'38Wv'[][6][0]={69.787804, 9.604130, 8.696280, 8.405080, 6.713280, 5.254200, 5.053270, 2.535090, 2.499410, 0.707946, 0.373690, 0.373690}  
	'38Wv'[][7][0]={32.209202, 4.432600, 4.013600, 3.879200, 1.430000, 1.119200, 1.076400, 0.540000, 0.532400, 0.150800, 0.079600, 0.079600}  
	'38Wv'[][8][0]={20.935900, 2.881180, 2.608830, 2.521470, 0.604169, 0.472857, 0.454774, 0.228148, 0.224937, 0.063712, 0.033631, 0.033631}  
	'38Wv'[][9][0]={16.897301, 2.325380, 2.105570, 2.035070, 0.393558, 0.308021, 0.296242, 0.148616, 0.146525, 0.041502, 0.021907, 0.021907}  
	'38Wv'[][10][0]={16.120701, 2.218520, 2.008810, 1.941540, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'38Wv'[][0][1]={161.514008,14.910100, 1.218650, 1.744230, 2.518230, 0.209908, 0.300864, 0.002633, 0.002129, 0.378551, 0.025904, 0.036948}  
	'38Wv'[][1][1]={3660.199951,299.184998,57.140202,94.274300,49.454601, 9.222960,15.222800, 0.359632, 0.398271, 7.149780, 1.072600, 1.760240}  
	'38Wv'[][2][1]={ 0.000000,4219.240234,2133.739990,3783.110107,703.054016,305.694000,542.591980,37.226898,48.848301,99.856697,34.124001,60.221298}  
	'38Wv'[][3][1]={ 0.000000,36356.199219,52165.898438,97674.398438,6912.589844,6123.250000,11453.000000,2414.139893,3404.979980,995.346008,668.742981,1243.119995}  
	'38Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,47542.800781,63259.898438,125274.000000,90173.898438,131124.000000,7467.839844,7179.049805,14006.299805}  
	'38Wv'[][5][1]={ 2.091550,65.429199,11.142300,19.818100, 0.320202, 0.041409, 0.062027, 0.008880, 0.008410,21.424999,32.539299,57.378201}  
	'38Wv'[][6][1]={241.108994,3560.540039,2294.350098,4538.410156,1313.709961,1399.069946,2845.770020,4397.250000,6564.339844,13344.400391,33407.699219,68820.796875}  
	'38Wv'[][7][1]={2189.629883,17888.500000,23263.099609,47343.800781,26578.000000,51847.101563,109598.000000,476698.000000,725246.000000,124350.000000,113940.000000,243546.000000}  
	'38Wv'[][8][1]={7012.839844,38957.199219,75764.203125,156658.000000,97467.203125,167731.000000,370478.000000,2032990.000000,3091870.000000,205973.000000,2081550.000000,3774910.000000}  
	'38Wv'[][9][1]={12210.700195,55047.199219,132248.000000,275883.000000,153494.000000,180221.000000,422458.000000,424227.000000,635317.000000,104677.000000,15789300.000000,30677100.000000}  
	'38Wv'[][10][1]={14059.599609,60405.601563,150196.000000,315142.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(12,11,2) '39Wv'  
	'39Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'39Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'39Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'39Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'39Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'39Wv'[][5][0]={363.213989,50.575500,45.949600,44.340199,178.863998,141.964005,136.466003,72.527100,71.527397,20.631201,11.633400,11.633400}  
	'39Wv'[][6][0]={73.834297,10.281000, 9.340660, 9.013480, 7.391180, 5.866380, 5.639160, 2.997030, 2.955720, 0.852540, 0.480727, 0.480727}  
	'39Wv'[][7][0]={34.076801, 4.745000, 4.311000, 4.160000, 1.574400, 1.249600, 1.201200, 0.638400, 0.629600, 0.181600, 0.102400, 0.102400}  
	'39Wv'[][8][0]={22.149799, 3.084230, 2.802140, 2.703990, 0.665177, 0.527951, 0.507502, 0.269721, 0.266003, 0.076725, 0.043264, 0.043264}  
	'39Wv'[][9][0]={17.877001, 2.489270, 2.261590, 2.182380, 0.433299, 0.343909, 0.330588, 0.175697, 0.173275, 0.049979, 0.028182, 0.028182}  
	'39Wv'[][10][0]={17.055401, 2.374870, 2.157660, 2.082080, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'39Wv'[][0][1]={179.147003,16.572300, 1.439400, 2.044430, 2.836390, 0.251976, 0.358618, 0.003440, 0.002773, 0.451180, 0.033780, 0.047902}  
	'39Wv'[][1][1]={4003.610107,327.369995,66.326401,108.828003,54.869400,10.862300,17.846001, 0.462345, 0.510966, 8.432120, 1.381490, 2.260030}  
	'39Wv'[][2][1]={ 0.000000,4525.750000,2426.010010,4286.779785,767.065979,351.089996,621.632019,46.764099,61.291000,116.126999,42.976700,75.765503}  
	'39Wv'[][3][1]={ 0.000000,38015.500000,57802.699219,108219.000000,7417.850098,6813.450195,12742.900391,2949.669922,4158.109863,1141.380005,816.078979,1518.699951}  
	'39Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,50142.601563,67504.203125,134270.000000,105897.000000,153978.000000,8498.559570,8485.080078,16619.000000}  
	'39Wv'[][5][1]={ 1.989530,60.016399,10.167400,17.909500, 0.276592, 0.032961, 0.050004, 0.005328, 0.004748,15.977900,19.219801,33.394199}  
	'39Wv'[][6][1]={226.567993,3284.600098,2085.790039,4117.660156,1157.780029,1167.859985,2364.530029,2960.229980,4387.529785,11141.000000,27772.699219,56679.699219}  
	'39Wv'[][7][1]={2056.580078,16586.599609,21221.000000,43180.000000,23958.199219,45512.601563,96150.601563,360749.000000,547964.000000,112213.000000,103375.000000,234335.000000}  
	'39Wv'[][8][1]={6588.129883,36256.300781,69344.601563,143478.000000,89794.296875,156651.000000,346162.000000,1858940.000000,2829980.000000,209914.000000,1032200.000000,1845420.000000}  
	'39Wv'[][9][1]={11473.500000,51340.898438,121139.000000,252981.000000,144308.000000,183206.000000,429719.000000,552809.000000,828897.000000,150483.000000,6357130.000000,12221600.000000}  
	'39Wv'[][10][1]={13194.200195,56210.500000,138702.000000,291438.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(13,11,2) '40Wv'  
	'40Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'40Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'40Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'40Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'40Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'40Wv'[][5][0]={383.661987,53.967098,49.172798,47.373600,195.542007,156.414993,150.188995,82.888199,81.797501,23.312300,13.042200,13.042200, 1.828380}  
	'40Wv'[][6][0]={77.990898,10.970500, 9.995870, 9.630130, 8.080350, 6.463530, 6.206260, 3.425180, 3.380110, 0.963332, 0.538940, 0.538940, 0.075554}  
	'40Wv'[][7][0]={35.995201, 5.063200, 4.613400, 4.444600, 1.721200, 1.376800, 1.322000, 0.729600, 0.720000, 0.205200, 0.114800, 0.114800, 0.016094}  
	'40Wv'[][8][0]={23.396799, 3.291060, 2.998690, 2.888980, 0.727200, 0.581692, 0.558539, 0.308253, 0.304197, 0.086696, 0.048503, 0.048503, 0.006800}  
	'40Wv'[][9][0]={18.883400, 2.656200, 2.420230, 2.331680, 0.473700, 0.378916, 0.363834, 0.200797, 0.198155, 0.056474, 0.031595, 0.031595, 0.004429}  
	'40Wv'[][10][0]={18.015600, 2.534130, 2.309010, 2.224520, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'40Wv'[][0][1]={198.085007,18.357901, 1.691960, 2.384620, 3.179470, 0.301005, 0.425387, 0.004447, 0.003570, 0.529819, 0.043010, 0.060573, 0.000156}  
	'40Wv'[][1][1]={4365.350098,357.057007,76.625298,125.029999,60.636398,12.723200,20.806801, 0.588056, 0.648276, 9.780680, 1.729270, 2.816520, 0.017516}  
	'40Wv'[][2][1]={ 0.000000,4839.549805,2745.350098,4834.979980,834.237000,400.983002,708.234985,58.112801,76.076103,132.753998,52.489201,92.325401, 1.570120}  
	'40Wv'[][3][1]={ 0.000000,39608.898438,63772.300781,119323.000000,7938.180176,7538.529785,14099.400391,3562.129883,5019.270020,1287.170044,965.794983,1797.189941,90.421501}  
	'40Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,52774.699219,71666.101563,143236.000000,122820.000000,178620.000000,9516.610352,9737.620117,19125.400391,2764.080078}  
	'40Wv'[][5][1]={ 1.897530,55.078701, 9.370190,16.341999, 0.243396, 0.028413, 0.040151, 0.003797, 0.003210,13.686700,16.674900,28.684700,465.709015}  
	'40Wv'[][6][1]={213.369995,3045.330078,1911.560059,3766.080078,1033.270020,1006.950012,2032.819946,2218.649902,3261.679932,10142.799805,26720.500000,54410.800781,26196.900391}  
	'40Wv'[][7][1]={1935.439941,15444.500000,19491.300781,39653.800781,21803.199219,40732.101563,86105.796875,291803.000000,442122.000000,105999.000000,106705.000000,245642.000000,11198600.000000}  
	'40Wv'[][8][1]={6200.750000,33866.699219,63848.398438,132204.000000,83217.398438,147046.000000,325501.000000,1696030.000000,2581910.000000,209340.000000,768987.000000,1375090.000000,13479400.000000}  
	'40Wv'[][9][1]={10803.500000,48042.500000,111592.000000,233354.000000,135922.000000,182757.000000,429293.000000,631847.000000,947469.000000,171249.000000,4248020.000000,8130740.000000,12719200.000000}  
	'40Wv'[][10][1]={12404.000000,52498.101563,128467.000000,270296.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(13,11,2) '41Wv'  
	'41Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'41Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'41Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'41Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'41Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'41Wv'[][5][0]={404.722992,57.507900,52.540901,50.532902,212.854996,171.957001,164.957993,94.248901,92.976501,26.402399,15.405200,15.405200, 1.454180}  
	'41Wv'[][6][0]={82.272301,11.690200,10.680500,10.272300, 8.795810, 7.105750, 6.816560, 3.894640, 3.842060, 1.091030, 0.636588, 0.636588, 0.060091}  
	'41Wv'[][7][0]={37.971199, 5.395400, 4.929400, 4.741000, 1.873600, 1.513600, 1.452000, 0.829600, 0.818400, 0.232400, 0.135600, 0.135600, 0.012800}  
	'41Wv'[][8][0]={24.681200, 3.506990, 3.204090, 3.081630, 0.791588, 0.639490, 0.613464, 0.350502, 0.345771, 0.098188, 0.057290, 0.057290, 0.005408}  
	'41Wv'[][9][0]={19.920099, 2.830480, 2.586010, 2.487170, 0.515643, 0.416566, 0.399612, 0.228318, 0.225236, 0.063960, 0.037319, 0.037319, 0.003523}  
	'41Wv'[][10][0]={19.004601, 2.700400, 2.467160, 2.372870, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'41Wv'[][0][1]={218.421005,20.274599, 1.980300, 2.769250, 3.554030, 0.357288, 0.501356, 0.005694, 0.004561, 0.612750, 0.053333, 0.074476, 0.000421}  
	'41Wv'[][1][1]={4747.140137,388.375000,88.177902,143.078995,66.800797,14.822600,24.126900, 0.741096, 0.815524,11.158400, 2.104680, 3.407280, 0.046035}  
	'41Wv'[][2][1]={ 0.000000,5163.629883,3097.129883,5436.609863,904.765991,455.976990,803.455017,71.630096,93.653801,149.253998,62.324501,109.204002, 4.007650}  
	'41Wv'[][3][1]={ 0.000000,41282.500000,70272.101563,131535.000000,8477.389648,8313.549805,15553.299805,4274.310059,6019.169922,1429.060059,1112.890015,2067.709961,222.856003}  
	'41Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,55445.898438,75939.398438,152661.000000,142226.000000,206829.000000,10510.500000,10910.900391,21464.400391,6501.549805}  
	'41Wv'[][5][1]={ 1.814060,50.888401, 8.616030,14.952200, 0.217098, 0.024614, 0.033770, 0.002645, 0.002153,11.471700,11.979400,20.274799,2256.229980}  
	'41Wv'[][6][1]={201.294998,2828.090088,1756.819946,3454.310059,928.643982,870.914978,1751.859985,1681.380005,2458.729980,9049.179688,23103.099609,46713.000000,360910.000000}  
	'41Wv'[][7][1]={1824.369995,14406.400391,17960.599609,36536.398438,19960.199219,36546.601563,77277.000000,238178.000000,360692.000000,97834.296875,102424.000000,237588.000000,21367400.000000}  
	'41Wv'[][8][1]={5845.459961,31691.500000,58998.601563,122268.000000,77480.898438,137495.000000,305102.000000,1534820.000000,2338200.000000,196611.000000,574272.000000,1027880.000000,27653700.000000}  
	'41Wv'[][9][1]={10199.000000,45017.398438,103245.000000,216200.000000,127575.000000,179672.000000,423001.000000,582568.000000,869593.000000,157352.000000,3695230.000000,7088900.000000,29049500.000000}  
	'41Wv'[][10][1]={11666.799805,49136.898438,118983.000000,250722.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(14,11,2) '42Wv'  
	'42Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'42Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'42Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'42Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'42Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'42Wv'[][5][0]={426.337006,61.084999,55.960300,53.724098,229.306000,186.179993,178.272995,104.654999,103.155998,28.083799,15.814200,15.814200, 0.817975, 0.817975}  
	'42Wv'[][6][0]={86.666000,12.417400,11.375600,10.921100, 9.475590, 7.693510, 7.366770, 4.324670, 4.262700, 1.160510, 0.653489, 0.653489, 0.033801, 0.033801}  
	'42Wv'[][7][0]={39.999001, 5.731000, 5.250200, 5.040400, 2.018400, 1.638800, 1.569200, 0.921200, 0.908000, 0.247200, 0.139200, 0.139200, 0.007200, 0.007200}  
	'42Wv'[][8][0]={25.999201, 3.725130, 3.412610, 3.276240, 0.852765, 0.692386, 0.662980, 0.389203, 0.383626, 0.104441, 0.058811, 0.058811, 0.003042, 0.003042}  
	'42Wv'[][9][0]={20.983900, 3.006540, 2.754300, 2.644240, 0.555494, 0.451022, 0.431868, 0.253528, 0.249895, 0.068033, 0.038310, 0.038310, 0.001982, 0.001982}  
	'42Wv'[][10][0]={20.019501, 2.868370, 2.627730, 2.522720, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'42Wv'[][0][1]={240.097000,22.321301, 2.307390, 3.201230, 3.958300, 0.422186, 0.588181, 0.007225, 0.005769, 0.703809, 0.065677, 0.091011, 0.000615, 0.000080}  
	'42Wv'[][1][1]={5144.729980,421.096008,101.003998,162.970001,73.324402,17.176001,27.826500, 0.925237, 1.015930,12.661900, 2.547810, 4.103350, 0.067146, 0.012051}  
	'42Wv'[][2][1]={ 0.000000,5490.910156,3476.330078,6082.299805,977.726990,515.354980,905.909973,87.403603,114.129997,167.026993,73.635101,128.649002, 5.737470, 1.220950}  
	'42Wv'[][3][1]={ 0.000000,42420.199219,77040.203125,144061.000000,9017.910156,9102.089844,17032.800781,5065.709961,7128.850098,1579.000000,1275.050049,2367.610107,308.015015,70.667603}  
	'42Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,57976.300781,79867.796875,161458.000000,162128.000000,235719.000000,11535.500000,12151.500000,23964.400391,8571.790039,2032.780029}  
	'42Wv'[][5][1]={ 1.737830,47.323898, 8.023740,13.718300, 0.199403, 0.022427, 0.030096, 0.002093, 0.001657,11.180500,13.232400,22.259600,14348.599609,3417.120117}  
	'42Wv'[][6][1]={190.097000,2639.040039,1624.739990,3188.790039,851.257996,782.379028,1572.459961,1372.979980,2001.520020,8929.440430,24509.699219,49670.800781,7814270.000000,1867870.000000}  
	'42Wv'[][7][1]={1722.390015,13488.500000,16628.199219,33827.101562,18528.199219,33536.199219,71061.703125,203375.000000,308183.000000,96923.203125,107404.000000,251517.000000,25720000.000000,6514210.000000}  
	'42Wv'[][8][1]={5518.709961,29747.500000,54710.800781,113491.000000,72779.796875,130016.000000,289480.000000,1406530.000000,2145400.000000,196240.000000,547930.000000,985744.000000,33348200.000000,8738790.000000}  
	'42Wv'[][9][1]={9627.549805,42304.000000,95766.398438,200843.000000,121043.000000,176863.000000,417791.000000,614488.000000,914660.000000,165728.000000,3136450.000000,6027430.000000,36858900.000000,9799360.000000}  
	'42Wv'[][10][1]={11005.000000,46096.300781,109727.000000,231035.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(14,11,2) '43Wv'  
	'43Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'43Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'43Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'43Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'43Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'43Wv'[][5][0]={448.602997,64.858101,59.543701,57.064499,248.845993,202.175995,193.132996,116.515999,114.926003,31.083099,17.677401,17.677401, 3.186280, 3.058060}  
	'43Wv'[][6][0]={91.192200,13.184400,12.104100,11.600100,10.283100, 8.354510, 7.980820, 4.814780, 4.749060, 1.284440, 0.730480, 0.730480, 0.131666, 0.126368}  
	'43Wv'[][7][0]={42.088001, 6.085000, 5.586400, 5.353800, 2.190400, 1.779600, 1.700000, 1.025600, 1.011600, 0.273600, 0.155600, 0.155600, 0.028046, 0.026918}  
	'43Wv'[][8][0]={27.357100, 3.955230, 3.631140, 3.479950, 0.925435, 0.751873, 0.718243, 0.433312, 0.427397, 0.115595, 0.065740, 0.065740, 0.011850, 0.011373}  
	'43Wv'[][9][0]={22.079800, 3.192250, 2.930680, 2.808650, 0.602831, 0.489773, 0.467866, 0.282261, 0.278408, 0.075299, 0.042824, 0.042824, 0.007719, 0.007408}  
	'43Wv'[][10][0]={21.065001, 3.045540, 2.795990, 2.679580, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'43Wv'[][0][1]={263.217987,24.505199, 2.677470, 3.685250, 4.390640, 0.496396, 0.686616, 0.009093, 0.007237, 0.807470, 0.080674, 0.111049, 0.000926, 0.000121}  
	'43Wv'[][1][1]={5561.270020,455.364014,115.234001,184.882996,80.224998,19.807301,31.936600, 1.145770, 1.255370,14.333000, 3.076260, 4.934000, 0.103054, 0.018618}  
	'43Wv'[][2][1]={ 0.000000,5825.049805,3886.969971,6779.140137,1054.030029,579.823975,1016.760010,105.810997,138.003006,186.406998,86.798103,151.376007, 8.741460, 1.875510}  
	'43Wv'[][3][1]={ 0.000000, 0.000000,83721.398438,157491.000000,9577.980469,9923.719727,18575.599609,5955.500000,8377.700195,1740.920044,1458.619995,2710.179932,454.143005,105.119003}  
	'43Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,60510.101563,83685.000000,170209.000000,183483.000000,266887.000000,12638.599609,13531.799805,26790.400391,12115.599609,2899.719971}  
	'43Wv'[][5][1]={ 1.667410,43.973598, 7.478700,12.649200, 0.167935, 0.020203, 0.026551, 0.001629, 0.001249, 9.872790,11.223500,18.660999,370.902008,98.503601}  
	'43Wv'[][6][1]={179.843994,2460.909912,1503.180054,2943.570068,766.106018,694.726013,1396.540039,1102.359985,1592.069946,8206.639648,22794.400391,46080.800781,161809.000000,38843.898437}  
	'43Wv'[][7][1]={1627.829956,12623.200195,15398.099609,31316.199219,16960.500000,30512.000000,64830.000000,171081.000000,258446.000000,91428.898438,109566.000000,257801.000000,18166800.000000,4626660.000000}  
	'43Wv'[][8][1]={5215.589844,27913.599609,50740.601563,105332.000000,67560.500000,122120.000000,272704.000000,1266380.000000,1929500.000000,195055.000000,395359.000000,728720.000000,12834700.000000,3323490.000000}  
	'43Wv'[][9][1]={9100.879883,39756.000000,88811.296875,186493.000000,114273.000000,171241.000000,405984.000000,811328.000000,1213100.000000,189214.000000,1882570.000000,3596760.000000,8273540.000000,2198280.000000}  
	'43Wv'[][10][1]={10391.299805,43286.398438,101944.000000,215055.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(14,11,2) '44Wv'  
	'44Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'44Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'44Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'44Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'44Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'44Wv'[][5][0]={471.480988,68.727203,63.246498,60.496601,265.842010,219.399002,209.311005,128.876999,126.968002,34.036900,19.586000,19.586000, 0.908862, 0.908862}  
	'44Wv'[][6][0]={95.842796,13.970900,12.856800,12.297800,10.985400, 9.066220, 8.649340, 5.325560, 5.246690, 1.406500, 0.809349, 0.809349, 0.037557, 0.037557}  
	'44Wv'[][7][0]={44.234402, 6.448000, 5.933800, 5.675800, 2.340000, 1.931200, 1.842400, 1.134400, 1.117600, 0.299600, 0.172400, 0.172400, 0.008000, 0.008000}  
	'44Wv'[][8][0]={28.752199, 4.191180, 3.856950, 3.689250, 0.988640, 0.815924, 0.778406, 0.479279, 0.472181, 0.126580, 0.072838, 0.072838, 0.003380, 0.003380}  
	'44Wv'[][9][0]={23.205799, 3.382680, 3.112930, 2.977580, 0.644003, 0.531495, 0.507056, 0.312204, 0.307580, 0.082454, 0.047447, 0.047447, 0.002202, 0.002202}  
	'44Wv'[][10][0]={22.139299, 3.227220, 2.969870, 2.840740, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'44Wv'[][0][1]={287.872009,26.834999, 3.096030, 4.227100, 4.857590, 0.581027, 0.797202, 0.011367, 0.009016, 0.910864, 0.096565, 0.131692, 0.001168, 0.000456}  
	'44Wv'[][1][1]={6000.270020,491.312988,131.069000,209.091003,87.516800,22.749500,36.497501, 1.409310, 1.540620,15.958300, 3.614680, 5.758460, 0.126145, 0.067722}  
	'44Wv'[][2][1]={ 0.000000,6168.330078,4337.209961,7540.310059,1132.910034,650.460999,1138.060059,127.388000,165.916000,204.764999,99.573502,172.904999,10.360200, 6.611260}  
	'44Wv'[][3][1]={ 0.000000, 0.000000,97572.500000,170757.000000,10143.500000,10807.700195,20246.599609,6982.279785,9814.370117,1891.680054,1626.650024,3016.979980,519.234009,357.740997}  
	'44Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,62980.800781,87569.101563,179560.000000,208328.000000,302963.000000,13675.799805,14724.599609,29205.099609,13235.599609,9436.860352}  
	'44Wv'[][5][1]={ 1.599240,41.015800, 6.999400,11.713700, 0.155832, 0.018236, 0.023343, 0.001303, 0.000978, 8.822710, 9.532230,15.621600,16849.300781,12039.799805}  
	'44Wv'[][6][1]={170.412003,2302.530029,1396.530029,2729.479980,712.179016,617.007019,1236.630005,903.104004,1300.550049,7577.250000,20959.400391,42190.300781,9683040.000000,6975330.000000}  
	'44Wv'[][7][1]={1540.849976,11851.900391,14326.000000,29138.400391,15922.000000,27822.900391,59170.601563,146946.000000,222253.000000,85910.500000,105125.000000,248404.000000,18919200.000000,14523300.000000}  
	'44Wv'[][8][1]={4937.020020,26274.699219,47300.699219,98301.000000,64010.101563,114441.000000,256475.000000,1154550.000000,1762290.000000,181338.000000,355984.000000,657352.000000,21132300.000000,16583400.000000}  
	'44Wv'[][9][1]={8611.950195,37438.101563,82868.000000,174311.000000,108311.000000,165762.000000,394525.000000,683887.000000,1013430.000000,162905.000000,1938330.000000,3728870.000000,22473200.000000,17588300.000000}  
	'44Wv'[][10][1]={9830.629883,40693.199219,93226.601563,196049.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(14,11,2) '45Wv'  
	'45Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'45Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'45Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'45Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'45Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'45Wv'[][5][0]={494.987000,72.732803,67.066597,64.033096,284.973999,236.757996,225.488998,141.645996,139.509995,36.808899,21.767200,21.767200, 1.136080, 1.136080}  
	'45Wv'[][6][0]={100.621002,14.785100,13.633300,13.016700,11.775900, 9.783550, 9.317850, 5.853230, 5.764970, 1.521050, 0.899486, 0.899486, 0.046946, 0.046946}  
	'45Wv'[][7][0]={46.439800, 6.823800, 6.292200, 6.007600, 2.508400, 2.084000, 1.984800, 1.246800, 1.228000, 0.324000, 0.191600, 0.191600, 0.010000, 0.010000}  
	'45Wv'[][8][0]={30.185699, 4.435450, 4.089910, 3.904920, 1.059790, 0.880481, 0.838570, 0.526768, 0.518825, 0.136889, 0.080950, 0.080950, 0.004225, 0.004225}  
	'45Wv'[][9][0]={24.362801, 3.579830, 3.300950, 3.151640, 0.690350, 0.573548, 0.546247, 0.343138, 0.337964, 0.089170, 0.052731, 0.052731, 0.002752, 0.002752}  
	'45Wv'[][10][0]={23.243099, 3.415310, 3.149250, 3.006800, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'45Wv'[][0][1]={314.037994,29.308500, 3.566320, 4.829960, 5.358180, 0.676430, 0.922077, 0.014107, 0.011141, 1.024150, 0.115625, 0.156398, 0.001554, 0.000806}  
	'45Wv'[][1][1]={6447.439941,528.739014,148.507996,235.563004,95.202400,26.000099,41.524799, 1.720600, 1.876170,17.733299, 4.248560, 6.730330, 0.166203, 0.118710}  
	'45Wv'[][2][1]={ 0.000000,6515.350098,4819.839844,8353.980469,1214.719971,726.101990,1267.579956,152.195007,197.973007,224.654007,114.261002,197.785995,13.368000,11.362600}  
	'45Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,10722.500000,11706.200195,21949.500000,8114.729980,11399.400391,2052.979980,1814.729980,3364.050049,647.823975,594.924011}  
	'45Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,65303.398438,91176.898438,188446.000000,234224.000000,340687.000000,14765.400391,16040.799805,31917.500000,15844.099609,15067.200195}  
	'45Wv'[][5][1]={ 1.539890,38.084400, 6.574110,10.876900, 0.143014, 0.015830, 0.020986, 0.001021, 0.000753, 8.122980, 8.035060,12.980100,11416.799805,10823.000000}  
	'45Wv'[][6][1]={161.669006,2156.860107,1300.569946,2535.840088,655.645020,554.689026,1109.500000,751.619995,1075.530029,7134.240234,19158.599609,38417.000000,6163890.000000,5871010.000000}  
	'45Wv'[][7][1]={1460.089966,11137.700195,13350.099609,27146.900391,14831.900391,25534.099609,54388.300781,127058.000000,191978.000000,81918.398438,102680.000000,243174.000000,15592800.000000,15941300.000000}  
	'45Wv'[][8][1]={4677.979980,24749.599609,44139.101563,91811.101563,60216.800781,107596.000000,241933.000000,1049450.000000,1602120.000000,174729.000000,292163.000000,550758.000000,15830300.000000,16474100.000000}  
	'45Wv'[][9][1]={8160.649902,35295.699219,77349.203125,162952.000000,102613.000000,159663.000000,381713.000000,715685.000000,1057860.000000,160097.000000,1562780.000000,3011170.000000,16222800.000000,16681600.000000}  
	'45Wv'[][10][1]={9308.910156,38326.300781,85781.703125,181020.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(14,11,2) '46Wv'  
	'46Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'46Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'46Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'46Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'46Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'46Wv'[][5][0]={519.085022,76.834198,70.993301,67.646400,304.423004,254.072006,241.529999,154.505997,152.098007,39.262798,23.221399,23.221399, 2.475120, 2.280520}  
	'46Wv'[][6][0]={105.519997,15.618900,14.431500,13.751200,12.579700,10.499000, 9.980730, 6.384660, 6.285130, 1.622450, 0.959577, 0.959577, 0.102279, 0.094238}  
	'46Wv'[][7][0]={48.700600, 7.208600, 6.660600, 6.346600, 2.679600, 2.236400, 2.126000, 1.360000, 1.338800, 0.345600, 0.204400, 0.204400, 0.021786, 0.020074}  
	'46Wv'[][8][0]={31.655199, 4.685570, 4.329370, 4.125270, 1.132120, 0.944869, 0.898226, 0.574594, 0.565637, 0.146015, 0.086358, 0.086358, 0.009205, 0.008481}  
	'46Wv'[][9][0]={25.548800, 3.781700, 3.494210, 3.329490, 0.737466, 0.615491, 0.585107, 0.374293, 0.368458, 0.095114, 0.056254, 0.056254, 0.005996, 0.005525}  
	'46Wv'[][10][0]={24.374701, 3.607900, 3.333630, 3.176470, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'46Wv'[][0][1]={341.821014,31.933100, 4.095280, 5.501180, 5.893250, 0.784810, 1.062010, 0.017374, 0.013687, 1.146790, 0.136756, 0.183273, 0.001932, 0.001496}  
	'46Wv'[][1][1]={6929.890137,567.749023,167.751999,264.561005,103.292000,29.603800,47.054298, 2.086560, 2.270850,19.580799, 4.933070, 7.763070, 0.200469, 0.212520}  
	'46Wv'[][2][1]={ 0.000000,6867.770020,5341.660156,9230.240234,1299.569946,807.572998,1406.770020,180.792999,234.873993,244.712997,129.563004,223.362000,15.642400,19.703899}  
	'46Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,11316.500000,12640.700195,23728.900391,9387.089844,13178.599609,2213.709961,2002.119995,3706.399902,734.317993,999.830017}  
	'46Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,67682.601563,94440.398438,197114.000000,262496.000000,381904.000000,15841.400391,17290.699219,34494.398438,17329.500000,24445.400391}  
	'46Wv'[][5][1]={ 1.485570,35.673901, 6.167050,10.147700, 0.132441, 0.014618, 0.018150, 0.000852, 0.000622, 7.488690, 7.610370,12.143600,1353.560059,2400.719971}  
	'46Wv'[][6][1]={153.623993,2025.890015,1215.630005,2365.250000,607.179993,505.420990,1009.280029,640.333984,911.242004,6840.040039,18528.800781,37082.000000,96768.000000,231654.000000}  
	'46Wv'[][7][1]={1385.510010,10492.400391,12484.500000,25387.800781,13884.299805,23651.599609,50481.601563,111922.000000,169022.000000,78827.898438,100142.000000,238696.000000,11283200.000000,17024600.000000}  
	'46Wv'[][8][1]={4438.490234,23366.099609,41325.699219,86059.500000,56833.699219,101696.000000,229668.000000,965542.000000,1475320.000000,166242.000000,282794.000000,533498.000000,9874700.000000,16258400.000000}  
	'46Wv'[][9][1]={7752.140137,33331.398438,72403.000000,152841.000000,97394.296875,154143.000000,370053.000000,597959.000000,876122.000000,137746.000000,1683920.000000,3273070.000000,7802600.000000,13481000.000000}  
	'46Wv'[][10][1]={8818.309570,36074.601563,74949.101563,156775.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(14,11,2) '47Wv'  
	'47Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'47Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'47Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'47Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'47Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'47Wv'[][5][0]={543.892029,81.129700,75.116096,71.436699,326.053986,273.748993,259.661987,169.412003,166.639999,43.261799,28.447399,25.402700, 1.499620, 1.499620}  
	'47Wv'[][6][0]={110.563004,16.492100,15.269600,14.521700,13.473500,11.312100,10.730000, 7.000590, 6.886040, 1.787700, 1.175530, 1.049710, 0.061969, 0.061969}  
	'47Wv'[][7][0]={51.028000, 7.611600, 7.047400, 6.702200, 2.870000, 2.409600, 2.285600, 1.491200, 1.466800, 0.380800, 0.250400, 0.223600, 0.013200, 0.013200}  
	'47Wv'[][8][0]={33.167999, 4.947510, 4.580790, 4.356410, 1.212560, 1.018050, 0.965656, 0.630026, 0.619717, 0.160886, 0.105793, 0.094470, 0.005577, 0.005577}  
	'47Wv'[][9][0]={26.769800, 3.993120, 3.697130, 3.516040, 0.789867, 0.663158, 0.629032, 0.410401, 0.403686, 0.104802, 0.068914, 0.061538, 0.003633, 0.003633}  
	'47Wv'[][10][0]={25.539499, 3.809610, 3.527220, 3.354450, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'47Wv'[][0][1]={371.174011,34.708500, 4.685180, 6.241950, 6.463240, 0.906831, 1.218010, 0.021278, 0.016689, 1.279120, 0.161788, 0.215594, 0.002605, 0.002015}  
	'47Wv'[][1][1]={7404.359863,608.203003,188.830002,296.091003,111.763000,33.568699,53.098900, 2.514500, 2.729700,21.591499, 5.739010, 8.987790, 0.273271, 0.291225}  
	'47Wv'[][2][1]={ 0.000000,7222.560059,5899.140137,10163.799805,1386.699951,894.525024,1554.819946,213.350998,276.807007,266.562988,147.378006,253.145004,21.078400,26.798000}  
	'47Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,11912.900391,13595.200195,25551.300781,10782.400391,15126.299805,2387.340088,2218.770020,4098.160156,955.893005,1314.859985}  
	'47Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,69822.000000,97441.898438,205387.000000,292004.000000,424862.000000,16980.199219,18746.199219,37397.300781,21619.000000,30838.400391}  
	'47Wv'[][5][1]={ 1.434810,33.402100, 5.809710, 9.396010, 0.121660, 0.013284, 0.016239, 0.000691, 0.000502, 6.523930, 4.714690,10.539200,7536.339844,10630.400391}  
	'47Wv'[][6][1]={146.067993,1901.810059,1135.119995,2202.820068,557.752014,453.929993,905.296997,531.765015,752.546021,6185.689941,14223.799805,34347.101563,3400270.000000,4795130.000000}  
	'47Wv'[][7][1]={1315.530029,9878.919922,11660.700195,23704.599609,12908.000000,21669.599609,46351.398438,96376.796875,145540.000000,73095.500000,92560.601563,236129.000000,11635200.000000,17853900.000000}  
	'47Wv'[][8][1]={4213.750000,22047.500000,38641.898438,80536.898438,53366.101563,95233.296875,215771.000000,867885.000000,1326620.000000,159422.000000,182654.000000,444850.000000,10617800.000000,16372000.000000}  
	'47Wv'[][9][1]={7359.549805,31481.500000,67712.796875,143151.000000,92075.203125,146966.000000,354874.000000,780111.000000,1146640.000000,149676.000000,980772.000000,2185660.000000,10882400.000000,16260400.000000}  
	'47Wv'[][10][1]={8367.530273,34135.000000,72616.796875,152821.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(14,11,2) '48Wv'  
	'48Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'48Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'48Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'48Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'48Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'48Wv'[][5][0]={569.413025,85.653198,79.449898,75.410202,350.002991,295.697998,280.157013,186.544006,183.453995,48.896702,30.401400,30.401400, 4.226210, 4.226210}  
	'48Wv'[][6][0]={115.750000,17.411600,16.150600,15.329400,14.463100,12.219100,11.576900, 7.708540, 7.580840, 2.020560, 1.256280, 1.256280, 0.174639, 0.174639}  
	'48Wv'[][7][0]={53.422401, 8.036000, 7.454000, 7.075000, 3.080800, 2.602800, 2.466000, 1.642000, 1.614800, 0.430400, 0.267600, 0.267600, 0.037200, 0.037200}  
	'48Wv'[][8][0]={34.724400, 5.223370, 4.845080, 4.598730, 1.301620, 1.099670, 1.041870, 0.693738, 0.682246, 0.181842, 0.113060, 0.113060, 0.015717, 0.015717}  
	'48Wv'[][9][0]={28.025900, 4.215760, 3.910440, 3.711610, 0.847883, 0.716330, 0.678680, 0.451903, 0.444417, 0.118453, 0.073648, 0.073648, 0.010238, 0.010238}  
	'48Wv'[][10][0]={26.737900, 4.022020, 3.730730, 3.541040, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'48Wv'[][0][1]={402.192993,37.653801, 5.343510, 7.060050, 7.070090, 1.043930, 1.391770, 0.025909, 0.020251, 1.426040, 0.190790, 0.252440, 0.003445, 0.002670}  
	'48Wv'[][1][1]={ 0.000000,650.309998,211.951996,330.427002,120.648003,37.931599,59.712101, 3.013590, 3.264260,23.774401, 6.651830,10.376400, 0.363392, 0.388388}  
	'48Wv'[][2][1]={ 0.000000,7583.029785,6498.779785,11165.400391,1476.839966,987.710999,1713.339966,250.567993,324.691010,289.901001,166.873993,286.514008,27.669600,35.334301}  
	'48Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,12524.299805,14587.099609,27461.400391,12343.200195,17305.300781,2572.530029,2444.550049,4532.950195,1215.859985,1681.060059}  
	'48Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,71821.101563,100178.000000,213595.000000,324397.000000,472221.000000,18192.900391,20169.300781,40641.800781,26505.599609,38035.300781}  
	'48Wv'[][5][1]={ 1.387440,31.252800, 5.470510, 8.736490, 0.111077, 0.011943, 0.014338, 0.000548, 0.000399, 5.350370, 4.455440, 6.852890,395.825012,537.642029}  
	'48Wv'[][6][1]={139.001999,1783.920044,1059.400024,2050.070068,508.901001,403.859009,801.577026,432.802002,607.127014,5335.200195,13676.000000,27041.000000,203485.000000,312977.000000}  
	'48Wv'[][7][1]={1250.040039,9296.459961,10888.500000,22124.599609,11937.000000,19719.800781,42172.699219,81783.000000,123269.000000,65342.000000,92448.101563,218305.000000,14914500.000000,22128600.000000}  
	'48Wv'[][8][1]={4003.469971,20793.300781,36130.898438,75358.796875,49828.300781,88850.500000,201693.000000,773230.000000,1181360.000000,151706.000000,160555.000000,345192.000000,6239630.000000,9579850.000000}  
	'48Wv'[][9][1]={6993.009766,29788.500000,63333.398438,134078.000000,87278.601563,138627.000000,335676.000000,1046750.000000,1555560.000000,158377.000000,692736.000000,1344780.000000,4870770.000000,7131410.000000}  
	'48Wv'[][10][1]={7938.740234,32232.900391,70256.500000,148945.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(14,11,2) '49Wv'  
	'49Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'49Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'49Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'49Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'49Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'49Wv'[][5][0]={595.604980,90.332397,83.947800,79.515999,375.178009,319.101013,301.877991,204.856995,201.358002,55.395100,35.172901,35.172901, 7.361780, 7.361780}  
	'49Wv'[][6][0]={121.074997,18.362801,17.065001,16.164000,15.503500,13.186200,12.474500, 8.465310, 8.320710, 2.289090, 1.453450, 1.453450, 0.304210, 0.304210}  
	'49Wv'[][7][0]={55.879799, 8.475000, 7.876000, 7.460200, 3.302400, 2.808800, 2.657200, 1.803200, 1.772400, 0.487600, 0.309600, 0.309600, 0.064800, 0.064800}  
	'49Wv'[][8][0]={36.321701, 5.508720, 5.119370, 4.849110, 1.395250, 1.186710, 1.122660, 0.761844, 0.748831, 0.206009, 0.130805, 0.130805, 0.027378, 0.027378}  
	'49Wv'[][9][0]={29.315100, 4.446070, 4.131820, 3.913690, 0.908870, 0.773024, 0.731302, 0.496268, 0.487791, 0.134195, 0.085207, 0.085207, 0.017834, 0.017834}  
	'49Wv'[][10][0]={27.967800, 4.241740, 3.941940, 3.733830, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'49Wv'[][0][1]={434.917999,40.749802, 6.075680, 7.960110, 7.714660, 1.197390, 1.584440, 0.031347, 0.024434, 1.583180, 0.224246, 0.294053, 0.004494, 0.003483}  
	'49Wv'[][1][1]={ 0.000000,693.809998,237.184006,367.610992,129.927002,42.707199,66.906197, 3.590380, 3.881340,26.099800, 7.685000,11.930100, 0.474454, 0.507674}  
	'49Wv'[][2][1]={ 0.000000,7944.259766,7137.359863,12227.700195,1569.219971,1086.680054,1881.260010,292.592987,378.674011,314.571991,188.436996,323.079987,35.574402,45.548500}  
	'49Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,13137.799805,15595.700195,29413.699219,14046.500000,19679.199219,2766.399902,2689.429932,4995.250000,1514.219971,2100.530029}  
	'49Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,73556.203125,102573.000000,221525.000000,358033.000000,521345.000000,19425.900391,21684.599609,43961.398438,31813.000000,45842.300781}  
	'49Wv'[][5][1]={ 1.343540,29.277399, 5.160420, 8.135990, 0.101870, 0.010753, 0.012726, 0.000439, 0.000324, 4.188460, 3.295740, 4.951710,71.556801,93.443001}  
	'49Wv'[][6][1]={132.399994,1675.010010,989.901001,1910.119995,464.898987,359.388000,710.294983,353.923004,492.437988,4565.290039,11402.599609,22385.500000,237795.000000,355700.000000}  
	'49Wv'[][7][1]={1188.880005,8755.650391,10175.700195,20666.800781,11044.700195,17930.099609,38356.500000,69448.601563,104545.000000,58088.500000,87467.203125,204828.000000,6435900.000000,9263120.000000}  
	'49Wv'[][8][1]={3806.959961,19626.199219,33801.398438,70551.703125,46562.800781,82653.398438,188043.000000,684299.000000,1045670.000000,144033.000000,132859.000000,312472.000000,6812900.000000,10435700.000000}  
	'49Wv'[][9][1]={6656.970215,28158.900391,59266.398438,125639.000000,82384.796875,131364.000000,317845.000000,1362900.000000,2049510.000000,158710.000000,445683.000000,859850.000000,3388420.000000,5075460.000000}  
	'49Wv'[][10][1]={7536.040039,30508.599609,68483.898438,145913.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(14,11,2) '50Wv'  
	'50Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'50Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'50Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'50Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'50Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'50Wv'[][5][0]={622.469971,95.175697,88.597198,83.751701,401.626007,343.730988,324.644989,224.171005,220.307999,62.029800,40.262600,40.262600,10.860900,10.860900}  
	'50Wv'[][6][0]={126.536003,19.347401,18.010099,17.025101,16.596399,14.204000,13.415300, 9.263390, 9.103770, 2.563250, 1.663770, 1.663770, 0.448804, 0.448804}  
	'50Wv'[][7][0]={58.400200, 8.929400, 8.312200, 7.857600, 3.535200, 3.025600, 2.857600, 1.973200, 1.939200, 0.546000, 0.354400, 0.354400, 0.095600, 0.095600}  
	'50Wv'[][8][0]={37.959900, 5.804080, 5.402900, 5.107410, 1.493610, 1.278300, 1.207320, 0.833669, 0.819304, 0.230683, 0.149732, 0.149732, 0.040391, 0.040391}  
	'50Wv'[][9][0]={30.637300, 4.684450, 4.360660, 4.122170, 0.972940, 0.832691, 0.786455, 0.543054, 0.533697, 0.150267, 0.097536, 0.097536, 0.026311, 0.026311}  
	'50Wv'[][10][0]={29.229300, 4.469160, 4.160260, 3.932730, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'50Wv'[][0][1]={469.335999,44.010899, 6.888190, 8.948670, 8.397940, 1.368770, 1.797630, 0.037761, 0.029306, 1.753890, 0.262703, 0.342184, 0.005804, 0.004493}  
	'50Wv'[][1][1]={ 0.000000,738.827026,264.686005,407.852997,139.619003,47.928101,74.722298, 4.257060, 4.590720,28.594299, 8.849360,13.683900, 0.608824, 0.651290}  
	'50Wv'[][2][1]={ 0.000000,8308.230469,7817.500000,13358.299805,1664.250000,1191.890015,2059.409912,340.029999,439.542999,340.727997,212.117004,363.286011,44.793598,57.412701}  
	'50Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,13759.500000,16629.599609,31430.000000,15917.000000,22287.400391,2970.669922,2951.290039,5493.020020,1847.770020,2567.689941}  
	'50Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,75257.203125,104685.000000,228987.000000,393437.000000,573263.000000,20701.400391,23259.400391,47471.601563,37422.199219,54067.199219}  
	'50Wv'[][5][1]={ 1.302780,27.463301, 4.879640, 7.590240, 0.093850, 0.009724, 0.011391, 0.000357, 0.000269, 3.482420, 2.449250, 3.596490,21.229099,26.579100}  
	'50Wv'[][6][1]={126.259003,1574.339966,926.750000,1782.530029,425.282013,320.816010,631.474976,292.079010,402.347992,3979.110107,9630.530273,18782.900391,173032.000000,256065.000000}  
	'50Wv'[][7][1]={1131.640015,8254.040039,9525.740234,19333.699219,10229.700195,16334.099609,34957.199219,59357.601563,89147.601563,52240.398437,82213.898438,191162.000000,872345.000000,1202450.000000}  
	'50Wv'[][8][1]={3622.850098,18540.699219,31671.000000,66145.101563,43525.398438,76944.703125,175521.000000,608254.000000,928811.000000,135490.000000,119546.000000,299461.000000,11045100.000000,16681700.000000}  
	'50Wv'[][9][1]={6329.850098,26645.599609,55551.699219,117903.000000,77673.898438,124711.000000,302965.000000,1563260.000000,2384800.000000,154490.000000,314799.000000,616534.000000,2410030.000000,3680550.000000}  
	'50Wv'[][10][1]={7176.649902,28882.599609,64946.300781,138816.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(14,11,2) '51Wv'  
	'51Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'51Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'51Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'51Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'51Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'51Wv'[][5][0]={649.992981,100.154999,93.378700,88.087700,428.846008,368.951996,347.911987,243.983994,239.712006,69.073502,44.716000,44.716000,14.269100,14.269100}  
	'51Wv'[][6][0]={132.130997,20.359600,18.982100,17.906500,17.721201,15.246200,14.376800,10.082100, 9.905610, 2.854320, 1.847800, 1.847800, 0.589642, 0.589642}  
	'51Wv'[][7][0]={60.982399, 9.396600, 8.760800, 8.264400, 3.774800, 3.247600, 3.062400, 2.147600, 2.110000, 0.608000, 0.393600, 0.393600, 0.125600, 0.125600}  
	'51Wv'[][8][0]={39.638401, 6.107760, 5.694490, 5.371830, 1.594840, 1.372100, 1.293850, 0.907352, 0.891466, 0.256877, 0.166294, 0.166294, 0.053066, 0.053066}  
	'51Wv'[][9][0]={31.991899, 4.929550, 4.596000, 4.335580, 1.038880, 0.893789, 0.842819, 0.591052, 0.580704, 0.167331, 0.108325, 0.108325, 0.034567, 0.034567}  
	'51Wv'[][10][0]={30.521700, 4.703000, 4.384780, 4.136330, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'51Wv'[][0][1]={505.496002,47.439800, 7.787590,10.033400, 9.121290, 1.559580, 2.032680, 0.045259, 0.034999, 1.940810, 0.306472, 0.397217, 0.007412, 0.005727}  
	'51Wv'[][1][1]={ 0.000000,785.260986,294.563995,451.272003,149.716995,53.611900,83.181702, 5.022400, 5.404060,31.264000,10.146400,15.637900, 0.769713, 0.822775}  
	'51Wv'[][2][1]={ 0.000000,8672.919922,8538.690430,14553.599609,1761.589966,1303.030029,2247.330078,393.184998,507.654999,368.240997,237.725006,406.766998,55.478100,71.140900}  
	'51Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,14384.000000,17677.099609,33490.398437,17949.800781,25119.599609,3183.979980,3225.060059,6016.450195,2218.219971,3086.080078}  
	'51Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000,76311.203125,106433.000000,236239.000000,429913.000000,626949.000000,22000.800781,24828.300781,51029.300781,43305.500000,62696.101563}  
	'51Wv'[][5][1]={ 1.265030,25.654499, 4.628270, 7.104040, 0.087170, 0.008891, 0.010336, 0.000279, 0.000219, 2.830880, 2.042470, 2.944460, 9.274820,11.195500}  
	'51Wv'[][6][1]={120.533997,1482.060059,869.749023,1667.569946,390.635986,288.707001,565.778992,244.953003,334.194000,3493.350098,8548.250000,16596.699219,126240.000000,185710.000000}  
	'51Wv'[][7][1]={1078.209961,7791.750000,8935.700195,18124.199219,9503.690430,14956.700195,32018.300781,51304.199219,76888.000000,47218.699219,78516.296875,181994.000000,148987.000000,206236.000000}  
	'51Wv'[][8][1]={3450.949951,17536.199219,29728.699219,62121.699219,40772.199219,71811.703125,164209.000000,542743.000000,828476.000000,127795.000000,115484.000000,300498.000000,18163200.000000,26991800.000000}  
	'51Wv'[][9][1]={6030.910156,25232.699219,52155.500000,110941.000000,73333.101563,118305.000000,288258.000000,1568720.000000,2417230.000000,150779.000000,241015.000000,492359.000000,1913120.000000,2937260.000000}  
	'51Wv'[][10][1]={6829.839844,27353.900391,61254.601562,131078.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(14,11,2) '52Wv'  
	'52Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'52Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'52Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'52Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'52Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'52Wv'[][5][0]={678.187012,105.291000,98.315804,92.547302,21.445299,395.217987,372.041992,264.705994,259.980011,76.480698,50.078300,50.078300,18.086300,18.086300}  
	'52Wv'[][6][0]={137.862000,21.403601,19.985701,18.813101, 4.359410,16.331600,15.373900,10.938400,10.743100, 3.160410, 2.069380, 2.069380, 0.747381, 0.747381}  
	'52Wv'[][7][0]={63.627602, 9.878400, 9.224000, 8.682800, 2.012000, 3.478800, 3.274800, 2.330000, 2.288400, 0.673200, 0.440800, 0.440800, 0.159200, 0.159200}  
	'52Wv'[][8][0]={41.357700, 6.420930, 5.995570, 5.643790, 1.307790, 1.469780, 1.383590, 0.984415, 0.966839, 0.284424, 0.186236, 0.186236, 0.067261, 0.067261}  
	'52Wv'[][9][0]={33.379601, 5.182300, 4.839000, 4.555080, 1.055510, 0.957418, 0.901274, 0.641251, 0.629802, 0.185275, 0.121315, 0.121315, 0.043814, 0.043814}  
	'52Wv'[][10][0]={31.845600, 4.944140, 4.616610, 4.345740, 1.007010, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'52Wv'[][0][1]={543.458008,51.038799, 8.783020,11.216400, 9.885430, 1.771390, 2.291340, 0.053957, 0.041602, 2.138590, 0.356053, 0.458347, 0.009369, 0.007223}  
	'52Wv'[][1][1]={ 0.000000,833.151978,327.007996,498.023987,160.227997,59.789501,92.320503, 5.896820, 6.332250,34.077400,11.585600,17.787300, 0.960885, 1.026020}  
	'52Wv'[][2][1]={ 0.000000,9037.269531,9303.799805,15818.700195,1861.390015,1420.439941,2445.540039,452.653992,583.755005,397.045990,265.414001,453.763000,67.779404,86.925400}  
	'52Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,15013.200195,18742.400391,35605.101562,20165.300781,28203.599609,3406.030029,3513.790039,6571.939941,2628.520020,3659.909912}  
	'52Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,107932.000000,243247.000000,467900.000000,682898.000000,23322.000000,26433.599609,54741.101563,49492.000000,71778.796875}  
	'52Wv'[][5][1]={ 1.230060,24.135500, 4.375030, 6.659490,268.346985, 0.008182, 0.009464, 0.000232, 0.000190, 2.399710, 1.611860, 2.268320, 4.535590, 5.260380}  
	'52Wv'[][6][1]={115.191002,1396.819946,817.692993,1562.569946,7620.709961,260.859985,509.013000,207.141006,279.898010,3090.330078,7437.319824,14359.000000,91436.703125,133818.000000}  
	'52Wv'[][7][1]={1028.250000,7363.060059,8395.019531,17016.800781,29398.900391,13730.599609,29406.500000,44610.101563,66722.500000,42859.199219,73759.398438,170265.000000,153574.000000,240598.000000}  
	'52Wv'[][8][1]={3290.149902,16601.900391,27941.900391,58433.000000,55816.500000,67091.398438,153819.000000,485887.000000,741277.000000,120638.000000,112976.000000,300900.000000,16884100.000000,24838300.000000}  
	'52Wv'[][9][1]={5755.029785,23920.199219,49082.000000,104471.000000,72969.296875,112187.000000,274295.000000,1451070.000000,2247020.000000,147176.000000,191477.000000,417149.000000,1665410.000000,2550610.000000}  
	'52Wv'[][10][1]={6500.189941,25939.000000,57618.500000,123284.000000,78514.296875, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(14,11,2) '53Wv'  
	'53Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'53Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'53Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'53Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'53Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'53Wv'[][5][0]={707.085022,110.597000,103.433998,97.145401,22.854401,422.847992,397.445007,286.881989,281.473999,84.705902,55.758701,55.758701,22.539801,22.539801}  
	'53Wv'[][6][0]={143.735992,22.482100,21.026100,19.747801, 4.645840,17.473301,16.423599,11.854800,11.631300, 3.500300, 2.304110, 2.304110, 0.931409, 0.931409}  
	'53Wv'[][7][0]={66.338799,10.376200, 9.704200, 9.114200, 2.144200, 3.722000, 3.498400, 2.525200, 2.477600, 0.745600, 0.490800, 0.490800, 0.198400, 0.198400}  
	'53Wv'[][8][0]={43.119999, 6.744500, 6.307700, 5.924200, 1.393720, 1.572530, 1.478060, 1.066890, 1.046780, 0.315013, 0.207361, 0.207361, 0.083823, 0.083823}  
	'53Wv'[][9][0]={34.801998, 5.443450, 5.090920, 4.781400, 1.124870, 1.024350, 0.962812, 0.694973, 0.681873, 0.205200, 0.135076, 0.135076, 0.054603, 0.054603}  
	'53Wv'[][10][0]={33.202599, 5.193290, 4.856950, 4.561660, 1.073170, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'53Wv'[][0][1]={583.244995,54.825199, 9.878770,12.506900,10.691900, 2.006150, 2.575100, 0.064089, 0.049230, 2.353380, 0.412523, 0.526673, 0.011712, 0.009004}  
	'53Wv'[][1][1]={ 0.000000,882.531006,362.166992,548.317017,171.167999,66.491997,102.177002, 6.896000, 7.388250,37.066299,13.180000,20.147900, 1.185660, 1.264410}  
	'53Wv'[][2][1]={ 0.000000,9402.860352,10115.500000,17158.800781,1963.880005,1544.359985,2654.610107,519.143982,668.624023,427.165985,295.147003,504.200989,81.860199,104.972000}  
	'53Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,15650.500000,19827.400391,37784.101563,22592.199219,31571.199219,3637.139893,3815.270020,7155.669922,3081.739990,4293.620117}  
	'53Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,108353.000000,250097.000000,509126.000000,743101.000000,24670.400391,28041.000000,58536.199219,56009.500000,81361.203125}  
	'53Wv'[][5][1]={ 1.197410,22.737400, 4.161310, 6.215490,246.686005, 0.007553, 0.008724, 0.000193, 0.000166, 2.034950, 1.325230, 1.819270, 2.332270, 2.587370}  
	'53Wv'[][6][1]={110.184998,1317.680054,769.583984,1465.910034,7083.810059,236.123993,458.359985,175.291000,235.063995,2725.110107,6511.540039,12502.000000,65372.101563,95179.101563}  
	'53Wv'[][7][1]={981.341003,6963.470215,7895.640137,15995.799805,27512.199219,12618.799805,27024.300781,38821.398438,58034.300781,38797.500000,69118.101563,159002.000000,245734.000000,385469.000000}  
	'53Wv'[][8][1]={3138.850098,15728.299805,26294.000000,55028.000000,52495.800781,62695.500000,144082.000000,435246.000000,664276.000000,113234.000000,111561.000000,301011.000000,7527100.000000,10990800.000000}  
	'53Wv'[][9][1]={5488.680176,22737.300781,46208.000000,98476.703125,68881.000000,106306.000000,260778.000000,1298460.000000,2012410.000000,142574.000000,161006.000000,377584.000000,1628420.000000,2475890.000000}  
	'53Wv'[][10][1]={6199.580078,24558.500000,54148.601563,116015.000000,74222.101563, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(14,11,2) '54Wv'  
	'54Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'54Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'54Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'54Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'54Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'54Wv'[][5][0]={736.758972,116.238998,108.797997,101.944000,24.399900,453.976013,425.802002,311.467010,305.514008,94.567001,66.665001,66.665001,29.083599,29.083599}  
	'54Wv'[][6][0]={149.768997,23.629200,22.116400,20.723200, 4.960020,18.759600,17.595400,12.870700,12.624700, 3.907790, 2.754790, 2.754790, 1.201820, 1.201820}  
	'54Wv'[][7][0]={69.122803,10.905600,10.207400, 9.564400, 2.289200, 3.996000, 3.748000, 2.741600, 2.689200, 0.832400, 0.586800, 0.586800, 0.256000, 0.256000}  
	'54Wv'[][8][0]={44.929600, 7.088600, 6.634780, 6.216830, 1.487970, 1.688290, 1.583510, 1.158310, 1.136180, 0.351685, 0.247920, 0.247920, 0.108159, 0.108159}  
	'54Wv'[][9][0]={36.262501, 5.721180, 5.354900, 5.017570, 1.200940, 1.099760, 1.031510, 0.754530, 0.740108, 0.229089, 0.161496, 0.161496, 0.070455, 0.070455}  
	'54Wv'[][10][0]={34.596001, 5.458250, 5.108800, 4.786980, 1.145740, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'54Wv'[][0][1]={624.903015,58.791199,11.086400,13.912800,11.542300, 2.265990, 2.886290, 0.075814, 0.058017, 2.582660, 0.475487, 0.603809, 0.014529, 0.011113}  
	'54Wv'[][1][1]={ 0.000000,933.677002,400.324005,602.491028,182.559998,73.775902,112.821999, 8.034520, 8.588400,40.218700,14.939300,22.761000, 1.449950, 1.542860}  
	'54Wv'[][2][1]={ 0.000000,9777.099609,10981.599609,18586.599609,2069.689941,1676.359985,2876.840088,593.645996,763.666016,458.666992,327.582001,559.288025,97.982697,125.608002}  
	'54Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,16305.200195,20961.699219,40080.601563,25286.099609,35315.500000,3879.219971,4144.669922,7799.189941,3587.870117,5001.279785}  
	'54Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,125156.000000,254937.000000,554710.000000,810876.000000,26078.500000,29800.199219,62819.398438,63078.898438,91777.703125}  
	'54Wv'[][5][1]={ 1.166690,21.362200, 3.956150, 5.825890,225.554001, 0.006453, 0.008000, 0.000159, 0.000146, 1.623060, 0.845944, 1.115120, 1.029800, 1.071940}  
	'54Wv'[][6][1]={105.468002,1240.569946,724.057007,1374.630005,6558.439941,211.358002,408.549011,146.910995,194.779999,2361.199951,4936.919922,9363.080078,41673.000000,60255.101563}  
	'54Wv'[][7][1]={937.120972,6577.080078,7425.859863,15035.799805,25666.500000,11509.200195,24666.199219,33567.699219,50045.699219,34653.800781,59695.699219,135641.000000,314020.000000,485718.000000}  
	'54Wv'[][8][1]={2996.300049,14887.799805,24750.099609,51837.300781,49240.800781,58277.101563,134316.000000,388216.000000,592061.000000,104899.000000,104646.000000,282985.000000,2160810.000000,3088150.000000}  
	'54Wv'[][9][1]={5237.450195,21553.199219,43523.101563,92885.398438,64829.500000,100208.000000,246849.000000,1148920.000000,1774540.000000,136051.000000,133242.000000,336482.000000,2001500.000000,2997720.000000}  
	'54Wv'[][10][1]={5917.149902,23289.599609,50915.898438,109282.000000,69698.703125, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(17,11,2) '55Wv'  
	'55Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'55Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'55Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'55Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'55Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'55Wv'[][5][0]={767.096985,121.814003,114.248001,106.841003,25.945400,22.702999,453.339996,336.052002,329.690002,104.883003,78.298401,73.435997,35.809101,34.764000,10.315600, 5.953040, 5.180510}  
	'55Wv'[][6][0]={155.936005,24.762400,23.224501,21.718599, 5.274190, 4.615080,18.733299,13.886600,13.623700, 4.334060, 3.235520, 3.034590, 1.479740, 1.436550, 0.426270, 0.245997, 0.214074}  
	'55Wv'[][7][0]={71.969200,11.428600,10.718800,10.023800, 2.434200, 2.130000, 3.990400, 2.958000, 2.902000, 0.923200, 0.689200, 0.646400, 0.315200, 0.306000, 0.090800, 0.052400, 0.045600}  
	'55Wv'[][8][0]={46.779701, 7.428550, 6.967180, 6.515440, 1.582220, 1.384490, 1.685930, 1.249740, 1.226080, 0.390048, 0.291184, 0.273101, 0.133171, 0.129284, 0.038363, 0.022139, 0.019266}  
	'55Wv'[][9][0]={37.755699, 5.995550, 5.623180, 5.258580, 1.277000, 1.117420, 1.098220, 0.814086, 0.798674, 0.254079, 0.189678, 0.177899, 0.086748, 0.084216, 0.024990, 0.014421, 0.012550}  
	'55Wv'[][10][0]={36.020599, 5.720010, 5.364760, 5.016910, 1.218320, 1.066070, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'55Wv'[][0][1]={668.320984,62.914799,12.408900,15.440000,12.434600, 2.551660, 3.225130, 0.089295, 0.068073, 2.823130, 0.545892, 0.688148, 0.017830, 0.013596, 0.472456, 0.073155, 0.089450}  
	'55Wv'[][1][1]={ 0.000000,985.461975,441.205994,660.234985,194.302994,81.579201,124.162003, 9.316520, 9.936900,43.503899,16.863199,25.570499, 1.755450, 1.864670, 6.953200, 2.108970, 3.085630}  
	'55Wv'[][2][1]={ 0.000000,10133.599609,11877.700195,20066.699219,2176.169922,1811.979980,3105.350098,674.935974,867.317017,491.151001,362.007996,616.469971,116.101997,148.681000,76.915901,43.636799,71.483803}  
	'55Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,16932.800781,22041.400391,42307.898438,28080.400391,39209.398438,4124.459961,4482.419922,8429.509766,4130.709961,5751.560059,654.312012,542.000977,977.463989}  
	'55Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,286715.000000,598648.000000,875926.000000,27439.500000,31513.500000,66677.296875,70102.796875,101874.000000,4590.279785,4002.729980,8012.709961}  
	'55Wv'[][5][1]={ 1.138310,20.203899, 3.776640, 5.476280,207.813004,132.541000, 0.007031, 0.000135, 0.000131, 1.356600, 0.584037, 0.917055, 0.542042, 0.606637,56.503399,117.950996,281.477997}  
	'55Wv'[][6][1]={101.049004,1173.680054,683.333008,1291.510010,6103.189941,8887.509766,369.942993,125.515999,164.259995,2063.270020,3832.929932,8224.599609,28382.699219,43811.300781,17553.099609,22826.199219,62977.699219}  
	'55Wv'[][7][1]={895.577026,6234.700195,6998.490234,14149.700195,24027.199219,41439.898438,22729.199219,29354.199219,43590.199219,31075.699219,51790.300781,126087.000000,333746.000000,516660.000000,113059.000000,299503.000000,667454.000000}  
	'55Wv'[][8][1]={2862.360107,14132.000000,23326.800781,48858.800781,46306.199219,78768.703125,125856.000000,347528.000000,529143.000000,96953.898438,99812.500000,282214.000000,509264.000000,794425.000000,88327.203125,6245060.000000,14187200.000000}  
	'55Wv'[][9][1]={5007.009766,20480.500000,41032.000000,87793.398438,61175.300781,99256.296875,234658.000000,1013740.000000,1566130.000000,136826.000000,119685.000000,341443.000000,33172800.000000,40387100.000000,39314.500000,34782600.000000,75207296.000000}  
	'55Wv'[][10][1]={5643.020020,22111.300781,48133.699219,103287.000000,66349.101563,116908.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(17,11,2) '56Wv'  
	'56Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'56Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'56Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'56Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'56Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'56Wv'[][5][0]={798.135986,127.666000,119.879997,111.851997,27.559099,24.231501,22.643299,361.772003,354.773987,114.971001,87.159798,81.661201,42.034801,40.853298,17.768200, 7.543550, 6.634690}  
	'56Wv'[][6][0]={162.244995,25.951900,24.369301,22.737400, 5.602230, 4.925780, 4.602940,14.949500,14.660300, 4.750940, 3.601700, 3.374480, 1.737000, 1.688180, 0.734236, 0.311722, 0.274165}  
	'56Wv'[][7][0]={74.881203,11.977600,11.247200,10.494000, 2.585600, 2.273400, 2.124400, 3.184400, 3.122800, 1.012000, 0.767200, 0.718800, 0.370000, 0.359600, 0.156400, 0.066400, 0.058400}  
	'56Wv'[][8][0]={48.672501, 7.785400, 7.310640, 6.821070, 1.680630, 1.477700, 1.380850, 1.345400, 1.319370, 0.427566, 0.324139, 0.303690, 0.156323, 0.151929, 0.066078, 0.028054, 0.024674}  
	'56Wv'[][9][0]={39.283401, 6.283560, 5.900390, 5.505250, 1.356430, 1.192650, 1.114480, 0.876395, 0.859442, 0.278518, 0.211145, 0.197825, 0.101830, 0.098967, 0.043044, 0.018274, 0.016073}  
	'56Wv'[][10][0]={37.478001, 5.994790, 5.629220, 5.252250, 1.294090, 1.137840, 1.063260, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'56Wv'[][0][1]={713.581970,67.228500,13.860600,17.090599,13.371200, 2.866100, 3.594440, 0.104761, 0.079563, 3.082630, 0.625213, 0.781741, 0.021734, 0.016552, 0.551031, 0.093692, 0.115232}  
	'56Wv'[][1][1]={ 0.000000,1038.760010,485.220001,721.809998,206.457993,89.996696,136.313004,10.761700,11.452400,46.971600,18.966700,28.636499, 2.109920, 2.239140, 8.083160, 2.686140, 3.968150}  
	'56Wv'[][2][1]={ 0.000000,10493.200195,12817.000000,21613.900391,2284.669922,1954.589966,3344.860107,764.411011,981.137024,524.796997,398.200989,677.619019,136.500000,174.731995,88.918701,54.688801,90.773598}  
	'56Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,17555.699219,23138.800781,44586.000000,31069.099609,43359.898438,4374.580078,4820.640137,9093.280273,4715.899902,6567.910156,753.341003,664.929016,1219.180054}  
	'56Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,644373.000000,943256.000000,28774.800781,33107.300781,70677.203125,77176.703125,112285.000000,5275.689941,4825.649902,9861.190430}  
	'56Wv'[][5][1]={ 1.111800,19.088100, 3.611230, 5.157370,191.703995,120.214996,227.145996, 0.000116, 0.000121, 1.170170, 0.478750, 0.729823, 0.333375, 0.355158,20.181400,82.713699,193.207993}  
	'56Wv'[][6][1]={96.902802,1109.390015,645.643005,1215.439941,5684.000000,8159.100098,17394.099609,107.815002,139.529007,1838.280029,3297.270020,7054.220215,21233.900391,32598.900391,8736.700195,21627.599609,59549.101563}  
	'56Wv'[][7][1]={856.468994,5906.620117,6601.720215,13334.400391,22503.699219,38513.300781,87520.296875,25759.699219,38155.800781,28246.400391,47314.398438,115113.000000,328205.000000,509330.000000,76697.898438,176768.000000,412173.000000}  
	'56Wv'[][8][1]={2735.899902,13409.099609,22001.900391,46105.398438,43555.898437,74012.296875,177929.000000,311501.000000,473915.000000,90572.101563,97750.000000,276223.000000,191382.000000,286084.000000,119735.000000,2802740.000000,5905090.000000}  
	'56Wv'[][9][1]={4783.979980,19454.900391,38780.398437,82941.500000,57755.898438,93928.898438,235299.000000,900985.000000,1389460.000000,129712.000000,109831.000000,328282.000000,5116670.000000,8133640.000000,46879.699219,14047000.000000,30859800.000000}  
	'56Wv'[][10][1]={5391.819824,20961.000000,45369.601563,97501.898438,62266.000000,108999.000000,271843.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(17,11,2) '57Wv'  
	'57Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'57Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'57Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'57Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'57Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'57Wv'[][5][0]={829.770996,133.580994,125.571999,116.876999,29.019400,25.674700,23.947901,385.584015,377.950012,122.877998,93.521797,86.977997,44.943199,44.943199,14.678100, 6.543800, 6.543800}  
	'57Wv'[][6][0]={168.675995,27.154400,25.526400,23.758801, 5.899070, 5.219150, 4.868150,15.933500,15.618000, 5.077680, 3.864600, 3.594190, 1.857180, 1.857180, 0.606543, 0.270409, 0.270409}  
	'57Wv'[][7][0]={77.849197,12.532600,11.781200,10.965400, 2.722600, 2.408800, 2.246800, 3.394000, 3.326800, 1.081600, 0.823200, 0.765600, 0.395600, 0.395600, 0.129200, 0.057600, 0.057600}  
	'57Wv'[][8][0]={50.601700, 8.146150, 7.657740, 7.127470, 1.769680, 1.565710, 1.460410, 1.433950, 1.405560, 0.456971, 0.347798, 0.323463, 0.167139, 0.167139, 0.054586, 0.024336, 0.024336}  
	'57Wv'[][9][0]={40.840401, 6.574720, 6.180530, 5.752550, 1.428300, 1.263680, 1.178690, 0.934080, 0.915586, 0.297673, 0.226557, 0.210705, 0.108875, 0.108875, 0.035558, 0.015852, 0.015852}  
	'57Wv'[][10][0]={38.963501, 6.272570, 5.896490, 5.488180, 1.362660, 1.205600, 1.124520, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'57Wv'[][0][1]={760.622986,71.734398,15.444700,18.873800,14.357500, 3.210710, 3.995310, 0.122429, 0.092621, 3.353690, 0.712527, 0.885865, 0.026345, 0.019999, 0.634120, 0.115328, 0.141208}  
	'57Wv'[][1][1]={ 0.000000,1093.239990,532.367981,787.280029,218.964005,99.004799,149.248993,12.379600,13.144600,50.571602,21.241301,31.958799, 2.517430, 2.668250, 9.225740, 3.266710, 4.821520}  
	'57Wv'[][2][1]={ 0.000000,10849.599609,13792.900391,23222.800781,2393.100098,2101.870117,3592.679932,861.627014,1104.650024,559.346008,436.217987,741.742004,159.059006,203.688004,100.572998,65.226402,108.560997}  
	'57Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,18141.099609,24202.099609,46846.199219,34171.898438,47668.800781,4626.129883,5161.819824,9764.769531,5327.979980,7435.589844,845.609009,776.052002,1432.339966}  
	'57Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,689898.000000,1009630.000000,30044.000000,34613.300781,74519.500000,83920.796875,122601.000000,5863.560059,5532.490234,11431.700195}  
	'57Wv'[][5][1]={ 1.087470,18.102699, 3.468290, 4.881590,180.240997,111.235001,208.944000, 0.000103, 0.000116, 1.076070, 0.422869, 0.670627, 0.305605, 0.280723,34.937401,138.578003,237.852997}  
	'57Wv'[][6][1]={93.039497,1051.479980,612.458008,1148.780029,5369.850098,7595.970215,16194.599609,95.933296,122.896004,1714.859985,3052.050049,6612.560059,19869.800781,28343.699219,13069.099609,28625.300781,70301.601563}  
	'57Wv'[][7][1]={819.901001,5608.290039,6248.759766,12612.400391,21318.699219,36149.300781,82333.000000,23207.400391,34300.398438,26598.300781,45007.699219,110712.000000,330691.000000,502299.000000,102414.000000,268284.000000,474000.000000}  
	'57Wv'[][8][1]={2617.469971,12748.299805,20815.000000,43647.699219,41354.800781,70033.203125,168956.000000,284373.000000,432386.000000,86576.203125,97081.101563,276994.000000,173071.000000,256710.000000,145775.000000,3371860.000000,5534420.000000}  
	'57Wv'[][9][1]={4574.850098,18545.599609,36688.398438,78571.000000,55034.101563,89405.398438,224955.000000,819914.000000,1263590.000000,125810.000000,109125.000000,337661.000000,1769130.000000,2599750.000000,82583.296875,11701500.000000,21534200.000000}  
	'57Wv'[][10][1]={5157.290039,19904.400391,41857.500000,89963.703125,58846.898438,104330.000000,259558.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(18,11,2) '58Wv'  
	'58Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'58Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'58Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'58Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'58Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'58Wv'[][5][0]={862.138977,139.602997,131.404999,122.008003,30.581900,27.132799,25.269600,409.578003,401.398987,131.602997,101.473999,94.158096,49.987400,49.987400,39.035599,17.177500, 8.997730, 8.997730}  
	'58Wv'[][6][0]={175.255997,28.378599,26.712000,24.801800, 6.216700, 5.515560, 5.136820,16.924999,16.587000, 5.438230, 4.193220, 3.890890, 2.065630, 2.065630, 1.613070, 0.709824, 0.371813, 0.371813}  
	'58Wv'[][7][0]={80.886002,13.097600,12.328400,11.446800, 2.869200, 2.545600, 2.370800, 3.605200, 3.533200, 1.158400, 0.893200, 0.828800, 0.440000, 0.440000, 0.343600, 0.151200, 0.079200, 0.079200}  
	'58Wv'[][8][0]={52.575600, 8.513400, 8.013420, 7.440380, 1.864970, 1.654630, 1.541010, 1.523180, 1.492760, 0.489419, 0.377373, 0.350164, 0.185898, 0.185898, 0.145170, 0.063881, 0.033462, 0.033462}  
	'58Wv'[][9][0]={42.433601, 6.871130, 6.467600, 6.005100, 1.505210, 1.335450, 1.243740, 0.992205, 0.972390, 0.318809, 0.245822, 0.228098, 0.121095, 0.121095, 0.094564, 0.041612, 0.021797, 0.021797}  
	'58Wv'[][10][0]={40.483398, 6.555350, 6.170360, 5.729120, 1.436030, 1.274070, 1.186590, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'58Wv'[][0][1]={809.807983,76.451797,17.187099,20.819700,15.399500, 3.593190, 4.436260, 0.142988, 0.107753, 3.610790, 0.800607, 0.984948, 0.030890, 0.023297, 0.000010, 0.651443, 0.121410, 0.146372}  
	'58Wv'[][1][1]={ 0.000000,1149.859985,583.775024,858.343018,232.210007,108.887001,163.382004,14.249000,15.095000,53.837700,23.436399,35.028999, 2.903100, 3.065720, 0.003611, 9.371040, 3.368060, 4.909510}  
	'58Wv'[][2][1]={ 0.000000,11217.599609,14862.599609,24986.500000,2510.770020,2263.310059,3865.469971,974.596985,1248.109985,589.919006,471.346008,799.215027,179.589005,229.529999, 0.808585,101.202003,65.764397,108.452003}  
	'58Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,18812.000000,25395.099609,49440.199219,37971.500000,52964.699219,4852.890137,5469.029785,10361.400391,5875.509766,8191.419922,99.477402,846.455994,767.276001,1408.650024}  
	'58Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,766256.000000,1117030.000000,31144.900391,35751.898438,77732.601563,89656.000000,131030.000000,7211.279785,5819.000000,5356.129883,11072.599609}  
	'58Wv'[][5][1]={ 1.064950,17.211599, 3.340470, 4.633590,169.179993,103.819000,193.664001, 0.000094, 0.000113, 0.976828, 0.367918, 0.551236, 0.224790, 0.198385, 0.000505,25.034201,63.993900,105.411003}  
	'58Wv'[][6][1]={89.419701,999.252991,582.965027,1089.410034,5079.000000,7137.410156,15214.799805,86.694099,109.799004,1578.109985,2727.520020,5903.729980,16450.400391,23346.699219,1200.000000,10096.799805,19259.300781,45629.699219}  
	'58Wv'[][7][1]={785.679016,5340.450195,5939.500000,11981.700195,20256.500000,34230.398438,78193.296875,21337.000000,31450.599609,24810.500000,41595.898438,102664.000000,302829.000000,458748.000000,226162.000000,82769.101563,134978.000000,262445.000000}  
	'58Wv'[][8][1]={2507.050049,12156.200195,19788.400391,41540.101563,39390.000000,66648.000000,161654.000000,266197.000000,404560.000000,80955.203125,90040.500000,259701.000000,155294.000000,230270.000000,939982.000000,119175.000000,2124580.000000,3349820.000000}  
	'58Wv'[][9][1]={4384.169922,17694.300781,34880.500000,74921.203125,52409.601563,85321.296875,216239.000000,783598.000000,1208480.000000,117011.000000,99440.398438,312581.000000,2181360.000000,3252530.000000,176164.000000,54989.601563,10484800.000000,19155700.000000}  
	'58Wv'[][10][1]={4934.350098,18956.300781,39648.699219,87887.296875,56607.800781,100858.000000,250859.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(18,11,2) '59Wv'  
	'59Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'59Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'59Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'59Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'59Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'59Wv'[][5][0]={895.130005,145.699997,137.292007,127.142998,32.210602,28.509899,26.480499,432.209015,423.075012,138.373993,107.382004,98.884102,51.441601,51.441601, 1.590510,16.995701,10.133800,10.133800}  
	'59Wv'[][6][0]={181.962006,29.618000,27.908899,25.845699, 6.547780, 5.795500, 5.382960,17.860100,17.482700, 5.718030, 4.437340, 4.086180, 2.125720, 2.125720, 0.065724, 0.702313, 0.418759, 0.418759}  
	'59Wv'[][7][0]={83.981201,13.669600,12.880800,11.928600, 3.022000, 2.674800, 2.484400, 3.804400, 3.724000, 1.218000, 0.945200, 0.870400, 0.452800, 0.452800, 0.014000, 0.149600, 0.089200, 0.089200}  
	'59Wv'[][8][0]={54.587502, 8.885200, 8.372480, 7.753550, 1.964290, 1.738610, 1.614850, 1.607340, 1.573370, 0.514600, 0.399343, 0.367740, 0.191306, 0.191306, 0.005915, 0.063205, 0.037687, 0.037687}  
	'59Wv'[][9][0]={44.057301, 7.171200, 6.757390, 6.257860, 1.585370, 1.403230, 1.303340, 1.047030, 1.024900, 0.335212, 0.260133, 0.239547, 0.124617, 0.124617, 0.003853, 0.041172, 0.024549, 0.024549}  
	'59Wv'[][10][0]={42.032600, 6.841630, 6.446840, 5.970260, 1.512510, 1.338740, 1.243440, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'59Wv'[][0][1]={860.711975,81.339600,19.079599,22.903700,16.482599, 4.008490, 4.912300, 0.166180, 0.124732, 3.888050, 0.899813, 1.098920, 0.036379, 0.027320, 0.000022, 0.698365, 0.134909, 0.160756}  
	'59Wv'[][1][1]={ 0.000000,1207.109985,638.302979,933.039978,245.755005,119.320000,178.216995,16.310301,17.237700,57.357498,25.875700,38.481300, 3.363180, 3.542760, 0.007403, 9.932350, 3.681970, 5.322110}  
	'59Wv'[][2][1]={ 0.000000,11565.799805,15951.500000,26775.599609,2628.280029,2425.899902,4139.189941,1094.479980,1399.790039,622.517029,509.420013,862.007019,203.367004,259.574005, 1.583990,106.226997,70.440300,115.588997}  
	'59Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,19448.900391,26482.900391,51840.800781,41736.101563,58175.699219,5085.459961,5787.859863,10987.799805,6471.140137,9017.200195,180.477005,882.846985,805.635986,1477.569946}  
	'59Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,853500.000000,1234410.000000,32177.199219,36860.500000,80905.601563,95183.703125,139187.000000,11228.900391,6008.069824,5511.180176,11442.799805}  
	'59Wv'[][5][1]={ 1.044040,16.310900, 3.229550, 4.416000,158.746994,98.305000,182.809998, 0.000088, 0.000113, 0.930876, 0.347548, 0.521491, 0.234063, 0.203850,2134.209961,27.043400,50.894798,82.335899}  
	'59Wv'[][6][1]={86.025703,951.270020,556.463989,1036.270020,4798.379883,6764.589844,14453.500000,79.955002,100.571999,1505.270020,2571.419922,5636.459961,16634.000000,23572.199219,3177410.000000,10559.700195,17093.000000,40193.398438}  
	'59Wv'[][7][1]={753.414978,5091.450195,5655.640137,11404.400391,19215.699219,32577.500000,74755.500000,19838.400391,29242.900391,23761.199219,39730.101563,99302.703125,300942.000000,456057.000000,1800970.000000,83490.296875,110354.000000,223770.000000}  
	'59Wv'[][8][1]={2402.429932,11600.599609,18830.699219,39572.101563,37455.699219,63681.101563,155398.000000,249923.000000,380224.000000,77547.601563,86691.000000,253925.000000,155594.000000,231231.000000,1281230.000000,114421.000000,1795620.000000,2781510.000000}  
	'59Wv'[][9][1]={4199.049805,16877.099609,33142.199219,71370.703125,49881.500000,81833.296875,208608.000000,741483.000000,1145310.000000,112280.000000,95286.703125,306985.000000,1859520.000000,2776130.000000,1149310.000000,52936.000000,9865040.000000,17979600.000000}  
	'59Wv'[][10][1]={4728.580078,18157.699219,37849.699219,83811.203125,54007.898438,95781.796875,243150.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(18,11,2) '60Wv'  
	'60Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'60Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'60Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'60Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'60Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'60Wv'[][5][0]={928.775024,151.908005,143.285004,132.335999,33.581299,29.903999,27.657200,454.204010,444.296997,143.237000,110.563004,102.065002,53.395599,53.395599, 1.363290,17.041201, 9.588490, 9.588490}  
	'60Wv'[][6][0]={188.802002,30.879900,29.127001,26.901400, 6.826420, 6.078900, 5.622160,18.768999,18.359699, 5.918950, 4.568790, 4.217630, 2.206460, 2.206460, 0.056335, 0.704190, 0.396224, 0.396224}  
	'60Wv'[][7][0]={87.137802,14.252000,13.443000,12.415800, 3.150600, 2.805600, 2.594800, 3.998000, 3.910800, 1.260800, 0.973200, 0.898400, 0.470000, 0.470000, 0.012000, 0.150000, 0.084400, 0.084400}  
	'60Wv'[][8][0]={56.639301, 9.263750, 8.737910, 8.070230, 2.047880, 1.823630, 1.686610, 1.689140, 1.652300, 0.532683, 0.411173, 0.379570, 0.198573, 0.198573, 0.005070, 0.063374, 0.035659, 0.035659}  
	'60Wv'[][9][0]={45.713299, 7.476730, 7.052330, 6.513450, 1.652830, 1.471840, 1.361260, 1.100310, 1.076310, 0.346991, 0.267839, 0.247253, 0.129351, 0.129351, 0.003303, 0.041282, 0.023228, 0.023228}  
	'60Wv'[][10][0]={43.612499, 7.133130, 6.728220, 6.214110, 1.576880, 1.404200, 1.298700, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'60Wv'[][0][1]={913.447021,86.429604,21.141600,25.143700,17.607700, 4.461380, 5.423370, 0.192459, 0.143891, 4.176070, 1.007700, 1.220210, 0.042616, 0.031916, 0.000038, 0.744406, 0.149897, 0.176585}  
	'60Wv'[][1][1]={ 0.000000,1265.459961,696.520996,1012.179993,259.519012,130.455994,193.899002,18.603600,19.616699,60.953201,28.461399,42.103802, 3.876160, 4.075010, 0.012911,10.488500, 4.015070, 5.756020}  
	'60Wv'[][2][1]={ 0.000000,11914.799805,17076.599609,28640.400391,2743.409912,2594.320068,4421.399902,1224.459961,1564.229980,655.200989,548.302002,926.315979,229.197006,292.152008, 2.730840,111.216003,75.164299,122.751999}  
	'60Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,20013.699219,27548.599609,54216.101563,45675.398438,63646.000000,5311.160156,6095.669922,11606.700195,7099.169922,9887.370117,303.519989,918.484009,842.401001,1543.739990}  
	'60Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,10258800.000000,1330190.000000,33073.500000,37795.000000,83823.703125,100679.000000,147313.000000,18331.500000,6185.990234,5641.870117,11766.400391}  
	'60Wv'[][5][1]={ 1.024910,15.573100, 3.131810, 4.220060,152.315002,93.461197,174.003998, 0.000078, 0.000108, 0.876960, 0.357061, 0.521504, 0.234245, 0.200787,6201.410156,28.290501,62.522900,101.253998}  
	'60Wv'[][6][1]={82.839600,906.955017,532.388977,987.991028,4609.479980,6428.930176,13811.799805,74.732597,93.212799,1476.410034,2562.560059,5574.419922,16402.500000,23199.000000,4246960.000000,10784.799805,18275.000000,43792.398438}  
	'60Wv'[][7][1]={723.044006,4859.870117,5395.259766,10876.200195,18466.099609,31062.500000,71773.101563,18626.199219,27422.800781,23229.199219,39166.199219,98074.601563,296048.000000,448627.000000,1898920.000000,82883.796875,129761.000000,248609.000000}  
	'60Wv'[][8][1]={2304.070068,11082.700195,17946.900391,37762.199219,35998.000000,60916.699219,149866.000000,236190.000000,359431.000000,75376.296875,84976.796875,251389.000000,154744.000000,230926.000000,1260280.000000,109374.000000,2142590.000000,3320070.000000}  
	'60Wv'[][9][1]={4028.500000,16151.500000,31614.800781,68143.703125,47936.000000,78521.601563,201881.000000,705053.000000,1089680.000000,109103.000000,93437.101563,305621.000000,1601790.000000,2393270.000000,900741.000000,51805.898438,11493900.000000,21039700.000000}  
	'60Wv'[][10][1]={4529.640137,17348.400391,36935.398437,79710.703125,51975.101563,91443.500000,238360.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(18,11,2) '61Wv'  
	'61Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'61Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'61Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'61Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'61Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'61Wv'[][5][0]={963.205017,158.343002,149.494995,137.695007,35.099098,31.366400,28.925600,22.415199,21.890800,150.143997,115.607002,107.246002,54.713501,54.713501, 1.817720,17.041201, 9.588490, 9.588490}  
	'61Wv'[][6][0]={195.800995,32.188099,30.389299,27.990801, 7.134950, 6.376170, 5.880000, 4.556580, 4.449970, 6.204390, 4.777230, 4.431700, 2.260920, 2.260920, 0.075114, 0.704190, 0.396224, 0.396224}  
	'61Wv'[][7][0]={90.367996,14.855800,14.025600,12.918600, 3.293000, 2.942800, 2.713800, 2.103000, 2.053800, 1.321600, 1.017600, 0.944000, 0.481600, 0.481600, 0.016000, 0.150000, 0.084400, 0.084400}  
	'61Wv'[][8][0]={58.738899, 9.656220, 9.116590, 8.397050, 2.140440, 1.912810, 1.763960, 1.366940, 1.334960, 0.558370, 0.429932, 0.398836, 0.203474, 0.203474, 0.006760, 0.063374, 0.035659, 0.035659}  
	'61Wv'[][9][0]={47.407902, 7.793490, 7.357960, 6.777220, 1.727540, 1.543820, 1.423690, 1.103250, 1.077440, 0.363724, 0.280059, 0.259803, 0.132544, 0.132544, 0.004403, 0.041282, 0.023228, 0.023228}  
	'61Wv'[][10][0]={45.229198, 7.435330, 7.019810, 6.465760, 1.648150, 1.472870, 1.358260, 1.052550, 1.027930, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'61Wv'[][0][1]={968.104980,91.707397,23.382099,27.558701,18.790701, 4.957160, 5.975030, 0.222329, 0.165465, 4.480260, 1.125270, 1.350850, 0.049676, 0.037039, 0.000060, 0.793454, 0.165404, 0.192575}  
	'61Wv'[][1][1]={ 0.000000,1325.109985,758.867004,1096.410034,273.776001,142.365005,210.569000,21.164301,22.259300,64.674004,31.221800,45.944901, 4.445080, 4.661350, 0.020645,11.057000, 4.358530, 6.196640}  
	'61Wv'[][2][1]={ 0.000000,12264.000000,18264.500000,30605.199219,2861.629883,2769.530029,4716.790039,1367.030029,1743.819946,688.633972,588.890991,993.455017,257.014008,327.162994, 4.315170,116.162003,79.959297,129.966995}  
	'61Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,20585.400391,28606.300781,56664.699219,49949.500000,69536.203125,5541.970215,6411.080078,12249.700195,7749.390137,10787.400391,468.574005,953.135986,878.541016,1609.010010}  
	'61Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,33968.000000,38681.101563,86818.500000,105897.000000,155039.000000,27527.300781,6350.879883,5760.629883,12074.400391}  
	'61Wv'[][5][1]={ 1.006730,14.866000, 3.018000, 4.033560,145.210007,88.788399,164.718994,42.286400,51.132401, 0.835677, 0.348930, 0.489623, 0.246039, 0.208176,3282.389893,29.700300,66.608597,107.335999}  
	'61Wv'[][6][1]={79.822601,864.577026,509.440002,942.017029,4405.810059,6105.680176,13151.099609,13450.200195,19737.699219,1411.660034,2468.010010,5293.720215,16661.400391,23532.000000,4659900.000000,11026.400391,18324.800781,44408.601563}  
	'61Wv'[][7][1]={694.223999,4639.049805,5148.709961,10375.299805,17676.400391,29603.099609,68740.398438,140667.000000,213320.000000,22272.000000,37817.000000,94433.601563,293729.000000,445345.000000,2167960.000000,82262.703125,136199.000000,253856.000000}  
	'61Wv'[][8][1]={2210.449951,10588.799805,17113.199219,36054.000000,34478.199219,58231.000000,144250.000000,436547.000000,671214.000000,72218.203125,82121.296875,244521.000000,154142.000000,229930.000000,1106790.000000,104472.000000,2281660.000000,3515570.000000}  
	'61Wv'[][9][1]={3862.620117,15432.599609,30120.599609,65171.398438,45973.000000,75172.703125,195117.000000,768295.000000,1194340.000000,104548.000000,90096.296875,298490.000000,1425010.000000,2132980.000000,625465.000000,51364.199219,12365200.000000,22673000.000000}  
	'61Wv'[][10][1]={4345.930176,16601.199219,35252.300781,76039.898438,49837.199219,87920.000000,227490.000000,9587680.000000,14725400.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(18,11,2) '62Wv'  
	'62Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'62Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'62Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'62Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'62Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'62Wv'[][5][0]={998.382996,164.927994,155.867996,143.171997,36.725601,32.843700,30.266399,23.577000,23.027000,157.097000,120.696999,112.426003,58.621601,58.621601, 2.499370,16.995701, 9.679370, 9.679370}  
	'62Wv'[][6][0]={202.951996,33.526699,31.684999,29.104000, 7.465590, 6.676480, 6.152570, 4.792750, 4.680950, 6.491700, 4.987550, 4.645780, 2.422410, 2.422410, 0.103281, 0.702313, 0.399980, 0.399980}  
	'62Wv'[][7][0]={93.668404,15.473600,14.623600,13.432400, 3.445600, 3.081400, 2.839600, 2.212000, 2.160400, 1.382800, 1.062400, 0.989600, 0.516000, 0.516000, 0.022000, 0.149600, 0.085200, 0.085200}  
	'62Wv'[][8][0]={60.884201,10.057800, 9.505290, 8.731020, 2.239630, 2.002900, 1.845730, 1.437790, 1.404250, 0.584227, 0.448859, 0.418102, 0.218008, 0.218008, 0.009295, 0.063205, 0.035997, 0.035997}  
	'62Wv'[][9][0]={49.139301, 8.117600, 7.671680, 7.046760, 1.807590, 1.616530, 1.489680, 1.160440, 1.133370, 0.380567, 0.292389, 0.272353, 0.142011, 0.142011, 0.006055, 0.041172, 0.023448, 0.023448}  
	'62Wv'[][10][0]={46.881001, 7.744540, 7.319110, 6.722920, 1.724520, 1.542240, 1.421220, 1.107110, 1.081280, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'62Wv'[][0][1]={1024.609985,97.180000,25.814501,30.145500,20.015699, 5.493690, 6.569060, 0.255927, 0.189811, 4.791810, 1.254340, 1.491080, 0.057670, 0.042803, 0.000091, 0.841388, 0.182548, 0.210071}  
	'62Wv'[][1][1]={ 0.000000,1385.829956,825.375977,1185.640015,288.433014,155.005005,228.257004,24.006399,25.196600,68.466797,34.167198,49.995602, 5.078880, 5.312200, 0.031203,11.618800, 4.722010, 6.657720}  
	'62Wv'[][2][1]={ 0.000000,12577.500000,19507.000000,32645.900391,2982.330078,2950.280029,5024.910156,1522.650024,1940.550049,722.491028,630.851013,1062.770020,287.475006,365.429993, 6.441680,121.064003,84.816200,137.216003}  
	'62Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,21155.099609,29631.300781,59169.500000,54543.398438,75954.500000,5771.560059,6726.209961,12899.400391,8456.419922,11766.200195,684.031982,986.825012,913.744995,1672.800049}  
	'62Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,34794.699219,39463.300781,89694.500000,111497.000000,163379.000000,39105.101563,6502.879883,5864.529785,12359.500000}  
	'62Wv'[][5][1]={ 0.989990,14.209700, 2.928310, 3.858280,137.929993,84.666603,155.505997,39.238098,46.815601, 0.798738, 0.342500, 0.462455, 0.214876, 0.176703,1407.569946,31.284000,69.139900,110.741997}  
	'62Wv'[][6][1]={76.971703,824.943970,488.057007,899.062012,4200.350098,5814.600098,12499.700195,12562.799805,18364.199219,1352.469971,2380.820068,5043.359863,15080.799805,21222.599609,4632810.000000,11289.400391,18138.500000,44411.800781}  
	'62Wv'[][7][1]={666.947998,4431.950195,4918.680176,9907.230469,16887.599609,28265.800781,65756.601563,132371.000000,200433.000000,21380.300781,36525.800781,91066.203125,279951.000000,423829.000000,2616720.000000,81614.601563,140177.000000,255105.000000}  
	'62Wv'[][8][1]={2122.070068,10124.299805,16334.599609,34452.398438,32973.101563,55739.699219,138697.000000,413445.000000,635389.000000,69235.203125,79284.398438,237873.000000,151400.000000,228382.000000,1052930.000000,99689.796875,2382270.000000,3646090.000000}  
	'62Wv'[][9][1]={3709.040039,14750.400391,28715.199219,62228.000000,43966.601563,72101.703125,188337.000000,727642.000000,1130760.000000,100162.000000,86797.000000,291452.000000,1231860.000000,1842800.000000,517782.000000,51566.500000,13121800.000000,24088800.000000}  
	'62Wv'[][10][1]={4167.850098,15886.400391,33631.800781,73187.796875,47779.800781,84933.000000,217892.000000,8914730.000000,13595900.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(18,11,2) '63Wv'  
	'63Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'63Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'63Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'63Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'63Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'63Wv'[][5][0]={1034.300049,171.647995,162.376999,148.729004,38.371300,34.404099,31.562500,24.740999,24.107800,163.686005,129.013000,116.607002,60.530201,60.530201, 1.323080,14.450900, 9.997480, 9.997480}  
	'63Wv'[][6][0]={210.253006,34.892601,33.007999,30.233700, 7.800130, 6.993680, 6.416040, 5.029350, 4.900650, 6.763980, 5.331190, 4.818540, 2.501280, 2.501280, 0.054674, 0.597153, 0.413125, 0.413125}  
	'63Wv'[][7][0]={97.038002,16.104000,15.234200,13.953800, 3.600000, 3.227800, 2.961200, 2.321200, 2.261800, 1.440800, 1.135600, 1.026400, 0.532800, 0.532800, 0.011646, 0.127200, 0.088000, 0.088000}  
	'63Wv'[][8][0]={63.074402,10.467500, 9.902180, 9.069920, 2.339990, 2.098060, 1.924770, 1.508770, 1.470160, 0.608732, 0.479786, 0.433650, 0.225106, 0.225106, 0.004920, 0.053741, 0.037180, 0.037180}  
	'63Wv'[][9][0]={50.907101, 8.448310, 7.992010, 7.320300, 1.888590, 1.693330, 1.553470, 1.217720, 1.186560, 0.396530, 0.312534, 0.282481, 0.146635, 0.146635, 0.003205, 0.035007, 0.024219, 0.024219}  
	'63Wv'[][10][0]={48.567501, 8.060050, 7.624720, 6.983880, 1.801800, 1.615510, 1.482080, 1.161760, 1.132030, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'63Wv'[][0][1]={1082.959961,102.862000,28.454100,32.914902,21.289700, 6.076340, 7.209680, 0.293706, 0.216937, 5.115830, 1.393580, 1.643420, 0.066679, 0.049269, 0.000115, 0.893049, 0.200392, 0.228656}  
	'63Wv'[][1][1]={ 0.000000,1447.520020,896.137024,1279.880005,303.460999,168.462006,246.910995,27.149000,28.422800,72.358704,37.307201,54.282299, 5.778280, 6.028350, 0.039012,12.199100, 5.099990, 7.138640}  
	'63Wv'[][2][1]={ 0.000000,12906.599609,20760.300781,34769.101563,3104.040039,3137.870117,5340.700195,1690.920044,2151.360107,756.796997,675.028992,1134.030029,319.997986,406.214996, 7.919070,125.938004,89.808502,144.625000}  
	'63Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,21702.400391,30639.500000,61623.898438,59373.000000,82561.703125,5998.939941,7056.299805,13547.299805,9173.610352,12758.099609,820.721985,1018.710022,948.916992,1736.839966}  
	'63Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,35548.199219,40208.601563,92375.796875,116564.000000,170930.000000,45399.398438,6625.910156,5960.549805,12636.799805}  
	'63Wv'[][5][1]={ 0.974171,13.605100, 2.846940, 3.675840,131.339005,80.575104,148.134995,36.663200,43.572899, 0.771125, 0.312349, 0.452581, 0.217282, 0.176096,17581.599609,46.283501,67.762497,107.580002}  
	'63Wv'[][6][1]={74.278603,788.036011,468.368988,859.465027,4011.770020,5529.350098,11953.799805,11795.000000,17289.300781,1304.560059,2182.679932,4910.609863,14959.099609,21010.699219,5085650.000000,14583.200195,17511.699219,43169.000000}  
	'63Wv'[][7][1]={641.096008,4237.810059,4705.220215,9473.740234,16156.599609,26960.099609,63179.300781,125045.000000,189922.000000,20625.199219,34230.800781,88969.898438,275113.000000,416564.000000,1741770.000000,92570.101563,136996.000000,246648.000000}  
	'63Wv'[][8][1]={2037.959961,9688.200195,15609.000000,32965.300781,31568.199219,53302.800781,133790.000000,392674.000000,605157.000000,66597.203125,75077.703125,233275.000000,149905.000000,226318.000000,1076830.000000,99155.500000,2374780.000000,3599110.000000}  
	'63Wv'[][9][1]={3560.110107,14137.799805,27462.199219,59528.500000,42096.601563,69107.101563,182081.000000,691059.000000,1076520.000000,96260.000000,81696.898438,287084.000000,1111820.000000,1665860.000000,847386.000000,59714.500000,13462000.000000,24708400.000000}  
	'63Wv'[][10][1]={4002.510010,15188.799805,32092.099609,70212.101563,45800.500000,80889.203125,211428.000000,8393960.000000,12751700.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(19,11,2) '64Wv'  
	'64Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'64Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'64Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'64Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'64Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'64Wv'[][5][0]={1070.969971,178.546005,169.052994,154.397995,40.093700,35.990101,32.914001,25.947500,25.265400,170.774994,131.102997,123.105003,63.847500,63.847500, 4.216850, 3.873660,16.405001, 9.224940, 9.224940}  
	'64Wv'[][6][0]={217.705994,36.294899,34.365200,31.386000, 8.150270, 7.316090, 6.690780, 5.274620, 5.135950, 7.056930, 5.417570, 5.087070, 2.638370, 2.638370, 0.174252, 0.160071, 0.677901, 0.381202, 0.381202}  
	'64Wv'[][7][0]={100.477997,16.751200,15.860600,14.485600, 3.761600, 3.376600, 3.088000, 2.434400, 2.370400, 1.503200, 1.154000, 1.083600, 0.562000, 0.562000, 0.037118, 0.034097, 0.144400, 0.081200, 0.081200}  
	'64Wv'[][8][0]={65.310501,10.888200,10.309300, 9.415590, 2.445030, 2.194780, 2.007190, 1.582350, 1.540750, 0.635096, 0.487560, 0.457816, 0.237443, 0.237443, 0.015682, 0.014406, 0.061008, 0.034307, 0.034307}  
	'64Wv'[][9][0]={52.711800, 8.787840, 8.320620, 7.599280, 1.973370, 1.771400, 1.619990, 1.277110, 1.243530, 0.413703, 0.317598, 0.298223, 0.154671, 0.154671, 0.010215, 0.009384, 0.039741, 0.022348, 0.022348}  
	'64Wv'[][10][0]={50.289299, 8.383980, 7.938230, 7.250040, 1.882680, 1.689990, 1.545540, 1.218420, 1.186390, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'64Wv'[][0][1]={1143.109985,108.706001,31.297199,35.870499,22.605301, 6.703970, 7.889500, 0.335776, 0.247009, 5.464810, 1.548280, 1.811820, 0.077354, 0.056926, 0.000138, 0.000022, 0.981479, 0.233047, 0.263996}  
	'64Wv'[][1][1]={ 0.000000,1509.589966,970.747986,1378.489990,318.704987,182.570999,266.343994,30.573999,31.936300,76.511497,40.700199,58.997101, 6.594240, 6.865870, 0.050502, 0.007653,13.311300, 5.845950, 8.172960}  
	'64Wv'[][2][1]={ 0.000000,13262.700195,22037.000000,36935.601563,3224.010010,3325.800049,5659.060059,1868.079956,2374.020020,792.898987,720.487976,1211.790039,357.122009,452.947998,10.463800, 1.618830,136.460007,100.984001,163.253006}  
	'64Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,22194.400391,31544.599609,63945.398438,64148.199219,89178.101563,6229.290039,7362.810059,14245.900391,9967.379883,13862.299805,1061.439941,167.511993,1096.660034,1045.939941,1930.430054}  
	'64Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,36273.000000,40852.500000,95347.703125,122044.000000,179168.000000,56876.500000,9102.129883,7067.839844,6441.270020,13845.099609}  
	'64Wv'[][5][1]={ 0.959366,13.032700, 2.770010, 3.524960,124.234001,76.852402,140.800003,34.214100,40.231300, 0.742980, 0.332672, 0.417873, 0.202336, 0.160692,267.740997,59.680599,38.408501,92.702202,149.188995}  
	'64Wv'[][6][1]={71.725403,752.893005,449.687988,821.968994,3824.290039,5260.089844,11401.400391,11034.299805,16143.099609,1255.479980,2226.520020,4602.700195,14063.799805,19700.300781,3219000.000000,582469.000000,12845.200195,20351.800781,51857.500000}  
	'64Wv'[][7][1]={616.497009,4052.270020,4501.180176,9058.120117,15422.900391,25697.599609,60519.699219,117431.000000,178307.000000,19840.000000,34165.000000,84913.398438,268269.000000,405766.000000,2688460.000000,432664.000000,87107.000000,175720.000000,306966.000000}  
	'64Wv'[][8][1]={1957.810059,9269.200195,14910.599609,31526.699219,30159.099609,50940.101563,128701.000000,370179.000000,570634.000000,64191.500000,74950.703125,227769.000000,165320.000000,255306.000000,642600.000000,113484.000000,106089.000000,2570080.000000,3910140.000000}  
	'64Wv'[][9][1]={3417.840088,13526.099609,26208.000000,57033.300781,40230.500000,66192.601563,175722.000000,640742.000000,998727.000000,93504.500000,83071.203125,286891.000000,712463.000000,1038430.000000,712302.000000,131451.000000,71148.101563,10158500.000000,18497000.000000}  
	'64Wv'[][10][1]={3844.550049,14527.700195,29811.500000,67089.601563,43631.101563,77765.500000,205292.000000,7457940.000000,11790400.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(19,11,2) '65Wv'  
	'65Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'65Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'65Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'65Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'65Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'65Wv'[][5][0]={1108.410034,185.632004,175.903000,160.179001,41.941898,37.682701,34.348701,27.179701,26.459101,180.817993,140.964005,129.513000,66.801300,66.801300, 4.271650, 3.908100,17.722799,11.542500,11.542500}  
	'65Wv'[][6][0]={225.317993,37.735298,35.757500,32.561199, 8.525980, 7.660160, 6.982420, 5.525090, 5.378620, 7.471930, 5.825060, 5.351850, 2.760430, 2.760430, 0.176517, 0.161494, 0.732358, 0.476972, 0.476972}  
	'65Wv'[][7][0]={103.990997,17.416000,16.503201,15.028000, 3.935000, 3.535400, 3.222600, 2.550000, 2.482400, 1.591600, 1.240800, 1.140000, 0.588000, 0.588000, 0.037600, 0.034400, 0.156000, 0.101600, 0.101600}  
	'65Wv'[][8][0]={67.594101,11.320300,10.727000, 9.768150, 2.557740, 2.298000, 2.094680, 1.657490, 1.613550, 0.672444, 0.524233, 0.481645, 0.248427, 0.248427, 0.015886, 0.014534, 0.065909, 0.042926, 0.042926}  
	'65Wv'[][9][0]={54.554901, 9.136600, 8.657730, 7.883830, 2.064340, 1.854700, 1.690610, 1.337750, 1.302290, 0.438032, 0.341487, 0.313745, 0.161826, 0.161826, 0.010348, 0.009467, 0.042934, 0.027962, 0.027962}  
	'65Wv'[][10][0]={52.047699, 8.716710, 8.259850, 7.521510, 1.969470, 1.769470, 1.612910, 1.276270, 1.242440, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'65Wv'[][0][1]={1205.349976,114.815002,34.397301,39.047699,23.999701, 7.394350, 8.626810, 0.383781, 0.281034, 5.806750, 1.707200, 1.979880, 0.088292, 0.064642, 0.000172, 0.000053, 1.033940, 0.254086, 0.285247}  
	'65Wv'[][1][1]={ 0.000000,1573.869995,1051.349976,1484.500000,334.799011,197.906998,287.359985,34.452900,35.900700,80.482597,44.126202,63.559799, 7.404870, 7.686000, 0.061804, 0.018682,13.901100, 6.271690, 8.703310}  
	'65Wv'[][2][1]={ 0.000000,13375.799805,23490.699219,39273.800781,3353.479980,3531.169922,6009.160156,2070.810059,2629.070068,827.447998,766.398987,1285.209961,392.962006,497.457001,12.533200, 3.869780,141.431000,106.286003,171.063004}  
	'65Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,22756.000000,32558.900391,66647.296875,69956.398438,97290.898438,6460.790039,7688.830078,14906.099609,10726.900391,14906.000000,1244.160034,392.015015,1129.079956,1080.550049,1995.060059}  
	'65Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,36959.601562,41268.101563,97783.296875,126636.000000,186049.000000,64718.199219,20690.000000,7199.439941,6513.520020,14106.599609}  
	'65Wv'[][5][1]={ 0.945950,12.500200, 2.699810, 3.385100,117.801003,73.197197,133.595993,32.126202,37.286900, 0.686060, 0.283821, 0.387637, 0.185696, 0.144533,299.457001,135.322006,33.875401,56.700298,88.245796}  
	'65Wv'[][6][1]={69.318604,720.184998,432.708008,787.802979,3644.350098,5008.930176,10891.299805,10430.400391,15211.000000,1169.969971,2007.780029,4321.580078,13399.799805,18709.599609,3195600.000000,1153530.000000,11612.299805,16049.099609,39786.800781}  
	'65Wv'[][7][1]={593.315002,3880.370117,4317.919922,8687.360352,14739.799805,24554.000000,58180.101563,111924.000000,169811.000000,18663.300781,31646.300781,81055.101563,256613.000000,388001.000000,2391840.000000,769300.000000,80027.296875,111103.000000,217100.000000}  
	'65Wv'[][8][1]={1882.569946,8883.490234,14290.900391,30263.500000,28850.599609,48755.398438,124257.000000,355110.000000,547589.000000,60345.101563,69303.898438,217234.000000,146052.000000,222528.000000,624618.000000,221515.000000,98025.500000,1789580.000000,2625970.000000}  
	'65Wv'[][9][1]={3287.110107,12978.500000,25130.000000,54709.101563,38510.199219,63337.898438,170151.000000,624042.000000,974825.000000,87095.203125,75000.898438,268993.000000,902967.000000,1354790.000000,773388.000000,285723.000000,66108.398438,8258510.000000,14889200.000000}  
	'65Wv'[][10][1]={3693.979980,13936.400391,29369.000000,64491.101563,41981.398437,75171.703125,197384.000000,7105360.000000,10944600.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(19,11,2) '66Wv'  
	'66Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'66Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'66Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'66Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'66Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'66Wv'[][5][0]={1146.630005,192.832993,182.916000,166.065002,43.632401,39.262402,35.719398,28.405399,27.603901,189.179993,150.779999,133.102997,70.073196,70.073196, 1.908610, 1.908610,28.583700,11.951500,11.951500}  
	'66Wv'[][6][0]={233.087006,39.199100,37.183201,33.757702, 8.869620, 7.981270, 7.261060, 5.774260, 5.611330, 7.817450, 6.230680, 5.500200, 2.895630, 2.895630, 0.078869, 0.078869, 1.181160, 0.493872, 0.493872}  
	'66Wv'[][7][0]={107.577003,18.091600,17.161200,15.580200, 4.093600, 3.683600, 3.351200, 2.665000, 2.589800, 1.665200, 1.327200, 1.171600, 0.616800, 0.616800, 0.016800, 0.016800, 0.251600, 0.105200, 0.105200}  
	'66Wv'[][8][0]={69.924698,11.759500,11.154700,10.127100, 2.660830, 2.394330, 2.178270, 1.732240, 1.683360, 0.703540, 0.560736, 0.494996, 0.260595, 0.260595, 0.007098, 0.007098, 0.106300, 0.044447, 0.044447}  
	'66Wv'[][9][0]={56.435902, 9.491020, 9.002930, 8.173520, 2.147540, 1.932450, 1.758070, 1.398080, 1.358630, 0.458288, 0.365265, 0.322442, 0.169753, 0.169753, 0.004624, 0.004624, 0.069244, 0.028953, 0.028953}  
	'66Wv'[][10][0]={53.842300, 9.054850, 8.589180, 7.797890, 2.048850, 1.843640, 1.677280, 1.333830, 1.296190, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'66Wv'[][0][1]={1269.040039,121.072998,37.727100,42.429798,25.421400, 8.131000, 9.413060, 0.436786, 0.318683, 6.168910, 1.885870, 2.164160, 0.101031, 0.073626, 0.000219, 0.000139, 1.052310, 0.263115, 0.289452}  
	'66Wv'[][1][1]={ 0.000000,1638.189941,1136.069946,1595.160034,350.885010,213.815002,309.148987,38.651100,40.182598,84.683502,47.883099,68.513901, 8.340410, 8.634630, 0.072335, 0.043908,13.991300, 6.353000, 8.666740}  
	'66Wv'[][2][1]={ 0.000000, 0.000000,24637.599609,41594.800781,3476.929932,3732.610107,6356.029785,2282.510010,2893.489990,863.450012,815.258972,1362.910034,433.510010,548.028015,13.917500, 8.518590,141.300003,105.325996,167.292007}  
	'66Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,23219.500000,33409.300781,69104.296875,75612.898438,105063.000000,6687.700195,8020.149902,15563.099609,11552.500000,16047.099609,1352.660034,845.184998,1124.239990,1050.540039,1923.849976}  
	'66Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,37538.898438,41676.601563,100089.000000,131407.000000,193262.000000,68482.203125,43485.898438,7125.839844,6179.100098,13377.000000}  
	'66Wv'[][5][1]={ 0.933117,12.005600, 2.633530, 3.254330,112.960999,70.557198,127.893997,30.322001,34.968102, 0.654099, 0.256207, 0.388950, 0.174231, 0.132820,7500.479980,4717.450195,12.056200,51.814602,79.142403}  
	'66Wv'[][6][1]={67.032799,689.448975,416.575012,755.406006,3499.949951,4805.430176,10452.700195,9870.320313,14408.700195,1115.979980,1830.930054,4276.520020,12695.799805,17672.099609,4132830.000000,2783730.000000,5477.910156,14368.000000,35618.500000}  
	'66Wv'[][7][1]={571.200012,3717.620117,4142.220215,8330.669922,14161.799805,23562.800781,56052.500000,106393.000000,161739.000000,17845.099609,29529.199219,79927.796875,247717.000000,374286.000000,1385390.000000,1026050.000000,47303.601563,105506.000000,194357.000000}  
	'66Wv'[][8][1]={1810.449951,8515.120117,13691.400391,29036.599609,27715.099609,46824.800781,120101.000000,338903.000000,523697.000000,57640.800781,65308.699219,214024.000000,144066.000000,220294.000000,828736.000000,612731.000000,71032.500000,1987610.000000,2880930.000000}  
	'66Wv'[][9][1]={3159.199951,12437.000000,24045.000000,52571.101563,36980.898438,60916.699219,164736.000000,594703.000000,931776.000000,83085.796875,70211.601563,265998.000000,825162.000000,1239740.000000,883879.000000,501246.000000,36958.800781,12897200.000000,23535900.000000}  
	'66Wv'[][10][1]={3552.199951,13368.799805,28127.099609,61865.300781,40356.699219,71674.398438,191838.000000,6478020.000000,10292200.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(19,11,2) '67Wv'  
	'67Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'67Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'67Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'67Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'67Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'67Wv'[][5][0]={1185.619995,200.259995,190.104004,172.054993,45.369801,40.989101,37.117802,29.663099,28.808300,197.994995,156.097000,139.328003,73.163399,73.163399, 1.681390, 1.681390,23.266899, 9.224940, 9.224940}  
	'67Wv'[][6][0]={241.014008,40.708900,38.644501,34.975399, 9.222790, 8.332270, 7.545330, 6.029930, 5.856170, 8.181750, 6.450380, 5.757460, 3.023320, 3.023320, 0.069480, 0.069480, 0.961455, 0.381202, 0.381202}  
	'67Wv'[][7][0]={111.235001,18.788401,17.835600,16.142200, 4.256600, 3.845600, 3.482400, 2.783000, 2.702800, 1.742800, 1.374000, 1.226400, 0.644000, 0.644000, 0.014800, 0.014800, 0.204800, 0.081200, 0.081200}  
	'67Wv'[][8][0]={72.302597,12.212400,11.593100,10.492400, 2.766780, 2.499630, 2.263550, 1.808940, 1.756810, 0.736326, 0.580509, 0.518149, 0.272087, 0.272087, 0.006253, 0.006253, 0.086527, 0.034307, 0.034307}  
	'67Wv'[][9][0]={58.355099, 9.856570, 9.356720, 8.468350, 2.233050, 2.017440, 1.826900, 1.459990, 1.417910, 0.479645, 0.378146, 0.337524, 0.177239, 0.177239, 0.004073, 0.004073, 0.056364, 0.022348, 0.022348}  
	'67Wv'[][10][0]={55.673302, 9.403590, 8.926720, 8.079170, 2.130430, 1.924720, 1.742940, 1.392890, 1.352750, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'67Wv'[][0][1]={1334.609985,127.541000,41.318298,46.026402,26.894100, 8.926860,10.248200, 0.495855, 0.360296, 6.549650, 2.076050, 2.361020, 0.115379, 0.083694, 0.000267, 0.000210, 1.106940, 0.286340, 0.311033}  
	'67Wv'[][1][1]={ 0.000000,1703.469971,1225.849976,1711.560059,367.326996,230.692993,331.990997,43.255798,44.868999,89.006599,51.795700,73.734901, 9.367760, 9.673340, 0.087515, 0.066187,14.588800, 6.801500, 9.197050}  
	'67Wv'[][2][1]={ 0.000000, 0.000000, 0.000000,44107.800781,3601.060059,3941.909912,6713.109863,2510.429932,3179.040039,899.932007,864.182983,1444.099976,476.764008,601.872009,16.528400,12.617900,146.121994,110.561996,174.798996}  
	'67Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,23651.199219,34243.898437,71558.101563,81572.296875,113356.000000,6912.589844,8324.959961,16252.599609,12403.799805,17223.300781,1573.180054,1226.530029,1151.680054,1080.750000,1979.670044}  
	'67Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,38045.300781,41912.601563,102490.000000,135893.000000,200079.000000,77197.398438,61204.300781,7187.399902,6214.209961,13542.599609}  
	'67Wv'[][5][1]={ 0.921625,11.533300, 2.571560, 3.131750,108.356003,67.234100,122.530998,28.656099,32.678001, 0.623715, 0.255674, 0.350761, 0.166401, 0.124392,13586.200195,10686.099609,19.670401,101.692001,159.988007}  
	'67Wv'[][6][1]={64.866798,660.078003,401.451996,725.036011,3362.000000,4589.649902,10040.099609,9351.129883,13619.700195,1062.709961,1787.680054,4059.060059,12151.799805,16865.400391,3802450.000000,3229000.000000,7636.680176,18338.099609,48520.699219}  
	'67Wv'[][7][1]={550.195984,3562.110107,3977.120117,7996.140137,13608.299805,22539.300781,54037.601563,101241.000000,153860.000000,17037.900391,28664.500000,76799.000000,239900.000000,362281.000000,1208610.000000,1132930.000000,57470.500000,212051.000000,316385.000000}  
	'67Wv'[][8][1]={1742.119995,8163.540039,13127.599609,27882.300781,26627.500000,44850.500000,116146.000000,323746.000000,500478.000000,54990.199219,63006.199219,207235.000000,141879.000000,217465.000000,892396.000000,786885.000000,72151.296875,3549130.000000,5354900.000000}  
	'67Wv'[][9][1]={3040.189941,11921.400391,23027.800781,50455.699219,35508.300781,58392.800781,159646.000000,568443.000000,889989.000000,79177.101563,67616.203125,258289.000000,761919.000000,1146450.000000,1131810.000000,737857.000000,45606.898438,20366600.000000,37786000.000000}  
	'67Wv'[][10][1]={3414.989990,12839.000000,27011.900391,59582.199219,38797.898438,69366.296875,188161.000000,6167650.000000,9361720.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(19,11,2) '68Wv'  
	'68Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'68Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'68Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'68Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'68Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'68Wv'[][5][0]={1225.439941,207.871994,197.490997,178.169006,47.036800,42.758400,38.622799,30.980600,30.042601,204.085007,166.412994,145.417999,80.297897,76.162598, 1.954050, 1.954050,27.174999,13.360300,13.360300}  
	'68Wv'[][6][0]={249.108002,42.256302,40.146000,36.218201, 9.561660, 8.691950, 7.851270, 6.297740, 6.107070, 8.433380, 6.876650, 6.009090, 3.318150, 3.147260, 0.080747, 0.080747, 1.122950, 0.552085, 0.552085}  
	'68Wv'[][7][0]={114.971001,19.502600,18.528601,16.715799, 4.413000, 4.011600, 3.623600, 2.906600, 2.818600, 1.796400, 1.464800, 1.280000, 0.706800, 0.670400, 0.017200, 0.017200, 0.239200, 0.117600, 0.117600}  
	'68Wv'[][8][0]={74.730797,12.676600,12.043500,10.865200, 2.868440, 2.607530, 2.355330, 1.889280, 1.832080, 0.758971, 0.618872, 0.540795, 0.298620, 0.283241, 0.007267, 0.007267, 0.101061, 0.049686, 0.049686}  
	'68Wv'[][9][0]={60.314899,10.231200, 9.720280, 8.769270, 2.315100, 2.104520, 1.900970, 1.524830, 1.478660, 0.494396, 0.403135, 0.352275, 0.194522, 0.184504, 0.004734, 0.004734, 0.065831, 0.032365, 0.032365}  
	'68Wv'[][10][0]={57.542999, 9.761050, 9.273560, 8.366260, 2.208710, 2.007810, 1.813610, 1.454750, 1.410710, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'68Wv'[][0][1]={1402.229980,134.225006,45.193401,49.860500,28.424500, 9.787880,11.144100, 0.561815, 0.406346, 6.937040, 2.281880, 2.573160, 0.131258, 0.094728, 0.000327, 0.000307, 1.166280, 0.312212, 0.334919}  
	'68Wv'[][1][1]={ 0.000000,1769.510010,1320.920044,1834.040039,384.056000,248.511993,356.092010,48.310600,49.984699,93.375000,55.966202,79.227997,10.497600,10.800500, 0.105457, 0.095434,15.221600, 7.285300, 9.765860}  
	'68Wv'[][2][1]={ 0.000000, 0.000000, 0.000000,46768.101563,3723.590088,4155.959961,7084.560059,2756.409912,3485.590088,936.192017,915.903992,1527.530029,524.155029,659.166016,19.513000,17.833799,151.309006,116.162003,182.850998}  
	'68Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,24031.400391,35022.601563,74073.601563,87908.296875,122086.000000,7123.009766,8649.780273,16944.199219,13348.200195,18436.400391,1820.589966,1700.109985,1184.739990,1114.949951,2044.660034}  
	'68Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,38406.898438,42045.199219,104755.000000,140833.000000,206537.000000,86677.703125,82362.398438,7322.169922,6270.959961,13802.099609}  
	'68Wv'[][5][1]={ 0.910494,11.091900, 2.513350, 3.016600,104.603996,64.494904,116.849998,27.031200,30.572500, 0.617027, 0.232939, 0.332286, 0.129287, 0.117730,9084.099609,8540.370117,14.650600,43.907200,65.282600}  
	'68Wv'[][6][1]={62.808601,632.328979,387.175995,696.403992,3244.120117,4388.029785,9610.549805,8847.349609,12886.500000,1041.069946,1638.239990,3873.149902,10204.200195,16194.700195,3613570.000000,3669610.000000,6117.939941,12625.099609,31433.400391}  
	'68Wv'[][7][1]={530.176025,3414.580078,3820.939941,7680.220215,13121.599609,21574.400391,51969.500000,96264.101563,146503.000000,16609.800781,26802.599609,74026.203125,221112.000000,351368.000000,1161610.000000,1304630.000000,48891.000000,90044.601563,168210.000000}  
	'68Wv'[][8][1]={1676.709961,7830.029785,12594.400391,26794.000000,25649.199219,42972.699219,112101.000000,309125.000000,478717.000000,53253.500000,59393.101563,201023.000000,141987.000000,214191.000000,818143.000000,859613.000000,66023.296875,1784280.000000,2505130.000000}  
	'68Wv'[][9][1]={2924.080078,11448.799805,22104.400391,48556.000000,34204.800781,55936.101563,154344.000000,542705.000000,852600.000000,76497.203125,63320.199219,251265.000000,671700.000000,1068540.000000,1083410.000000,804831.000000,41461.601563,12572100.000000,22829400.000000}  
	'68Wv'[][10][1]={3286.570068,12303.900391,25883.599609,57260.199219,37387.199219,66895.398438,183118.000000,5805500.000000,8976750.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(19,11,2) '69Wv'  
	'69Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'69Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'69Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'69Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'69Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'69Wv'[][5][0]={1266.030029,215.639999,205.007004,184.352997,49.174900,44.549099,40.172600,32.287300,31.287500,214.354996,175.365005,152.960999,81.615799,81.615799, 2.408480, 2.408480,24.175699,14.678100,14.678100}  
	'69Wv'[][6][0]={257.359009,43.835400,41.673901,37.475300, 9.996300, 9.055950, 8.166300, 6.563380, 6.360140, 8.857780, 7.246590, 6.320810, 3.372600, 3.372600, 0.099526, 0.099526, 0.999011, 0.606543, 0.606543}  
	'69Wv'[][7][0]={118.778999,20.231400,19.233801,17.296000, 4.613600, 4.179600, 3.769000, 3.029200, 2.935400, 1.886800, 1.543600, 1.346400, 0.718400, 0.718400, 0.021200, 0.021200, 0.212800, 0.129200, 0.129200}  
	'69Wv'[][8][0]={77.206100,13.150300,12.501900,11.242300, 2.998820, 2.716730, 2.449840, 1.968970, 1.908000, 0.797165, 0.652164, 0.568848, 0.303521, 0.303521, 0.008957, 0.008957, 0.089907, 0.054586, 0.054586}  
	'69Wv'[][9][0]={62.312698,10.613600,10.090200, 9.073650, 2.420340, 2.192660, 1.977250, 1.589150, 1.539940, 0.519276, 0.424822, 0.370550, 0.197715, 0.197715, 0.005835, 0.005835, 0.058566, 0.035558, 0.035558}  
	'69Wv'[][10][0]={59.449001,10.125800, 9.626520, 8.656650, 2.309110, 2.091890, 1.886380, 1.516110, 1.469170, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'69Wv'[][0][1]={1471.390015,141.087997,49.352100,53.922901,30.009701,10.709900,12.093400, 0.634686, 0.457369, 7.338880, 2.505470, 2.796480, 0.148810, 0.106935, 0.000395, 0.000437, 1.227010, 0.338816, 0.359960}  
	'69Wv'[][1][1]={ 0.000000,1836.069946,1421.060059,1962.260010,401.449005,267.221985,381.321014,53.814098,55.560299,97.880699,60.366001,84.969704,11.713500,12.033000, 0.125986, 0.133366,15.855000, 7.780600,10.348900}  
	'69Wv'[][2][1]={ 0.000000, 0.000000, 0.000000,48693.199219,3854.010010,4373.770020,7467.220215,3018.669922,3813.179932,973.763000,968.578979,1614.069946,572.791016,721.104980,22.903500,24.366100,156.278000,121.763000,190.830994}  
	'69Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,24460.300781,35729.500000,76588.101563,94442.398438,131185.000000,7345.049805,8961.889648,17656.400391,14228.700195,19745.800781,2096.219971,2279.199951,1212.510010,1146.569946,2105.000000}  
	'69Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,38792.199219,42031.101563,106992.000000,144490.000000,213307.000000,96838.796875,107211.000000,7389.149902,6304.620117,14006.299805}  
	'69Wv'[][5][1]={ 0.900794,10.677000, 2.460120, 2.910110,98.967003,62.031200,110.839996,25.660500,28.713800, 0.582199, 0.220133, 0.306047, 0.137195, 0.097865,4822.569824,5262.509766,19.642401,36.690300,53.486099}  
	'69Wv'[][6][1]={60.857899,606.148010,373.953003,669.807983,3083.909912,4203.399902,9201.049805,8411.940430,12225.700195,982.922974,1537.439941,3628.439941,10440.700195,14379.400391,3442960.000000,4053070.000000,7400.310059,11354.299805,28089.099609}  
	'69Wv'[][7][1]={511.148987,3275.280029,3675.540039,7385.810059,12506.700195,20678.099609,49991.000000,91863.398438,139788.000000,15753.299805,25404.300781,70536.398438,219469.000000,330647.000000,1159070.000000,1512070.000000,53884.398438,76200.601563,148433.000000}  
	'69Wv'[][8][1]={1614.699951,7513.660156,12095.400391,25773.699219,24474.599609,41215.601563,108227.000000,295954.000000,458624.000000,50548.601563,56425.699219,193485.000000,138376.000000,213969.000000,719061.000000,890228.000000,65175.800781,1554980.000000,2130200.000000}  
	'69Wv'[][9][1]={2815.889893,10981.299805,21194.699219,46685.101563,32640.400391,53704.398437,149432.000000,518979.000000,816952.000000,72527.203125,59866.601563,242423.000000,642768.000000,969476.000000,957709.000000,796651.000000,49021.101563,11641600.000000,21017100.000000}  
	'69Wv'[][10][1]={3162.199951,11814.099609,24834.599609,55122.000000,35710.500000,63454.300781,174450.000000,5293580.000000,8491170.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(19,11,2) '70Wv'  
	'70Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'70Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'70Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'70Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'70Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'70Wv'[][5][0]={1307.439941,223.542999,212.709000,190.654007,51.121201,46.322701,41.564602,33.602600,32.568699,221.399002,180.272995,156.097000,90.022697,84.024200, 2.862910, 2.862910,24.584700,10.633700,10.633700}  
	'70Wv'[][6][0]={265.778015,45.441799,43.239601,38.756302,10.391900, 9.416490, 8.449280, 6.830750, 6.620580, 9.148840, 7.449400, 6.450380, 3.720000, 3.472130, 0.118304, 0.118304, 1.015910, 0.439415, 0.439415}  
	'70Wv'[][7][0]={122.665001,20.972799,19.956400,17.887199, 4.796200, 4.346000, 3.899600, 3.152600, 3.055600, 1.948800, 1.586800, 1.374000, 0.792400, 0.739600, 0.025200, 0.025200, 0.216400, 0.093600, 0.093600}  
	'70Wv'[][8][0]={79.731598,13.632300,12.971600,11.626600, 3.117510, 2.824890, 2.534730, 2.049180, 1.986130, 0.823360, 0.670416, 0.580509, 0.334786, 0.312478, 0.010647, 0.010647, 0.091428, 0.039546, 0.039546}  
	'70Wv'[][9][0]={64.350998,11.002500,10.469300, 9.383790, 2.516130, 2.279950, 2.045770, 1.653880, 1.603000, 0.536339, 0.436711, 0.378146, 0.218080, 0.203549, 0.006935, 0.006935, 0.059556, 0.025760, 0.025760}  
	'70Wv'[][10][0]={61.393600,10.496900, 9.988180, 8.952540, 2.400500, 2.175170, 1.951750, 1.577880, 1.529330, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'70Wv'[][0][1]={1541.719971,148.158997,53.827301,58.243401,31.649799,11.699300,13.098100, 0.715344, 0.513392, 7.759420, 2.742660, 3.035570, 0.168597, 0.120509, 0.000478, 0.000601, 1.286770, 0.368141, 0.384862}  
	'70Wv'[][1][1]={ 0.000000,1903.050049,1526.739990,2096.820068,419.014008,286.825989,407.446991,59.806198,61.618500,102.476997,64.936401,90.932602,13.065500,13.366400, 0.150039, 0.180948,16.492701, 8.300170,10.929600}  
	'70Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,3980.239990,4593.759766,7849.080078,3298.459961,4163.959961,1010.940002,1021.219971,1700.319946,627.023010,785.539978,26.741301,32.429699,161.412003,127.264999,198.542007}  
	'70Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,24817.099609,36350.101563,78921.000000,101215.000000,140750.000000,7549.700195,9246.309570,18316.300781,15258.500000,21021.000000,2401.419922,2977.810059,1242.089966,1173.849976,2156.729980}  
	'70Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,39027.398438,41915.898438,108793.000000,148995.000000,218893.000000,107613.000000,135967.000000,7478.629883,6308.040039,14119.799805}  
	'70Wv'[][5][1]={ 0.891276,10.295700, 2.410820, 2.810240,94.827301,59.959202,107.206001,24.450300,26.967501, 0.573738, 0.224003, 0.312239, 0.104631, 0.097044,2872.090088,3564.330078,19.698000,84.370300,128.184998}  
	'70Wv'[][6][1]={59.003899,581.685974,361.532990,644.728027,2958.560059,4040.459961,8900.719727,8020.990234,11601.700195,957.573975,1520.109985,3632.250000,8614.629883,14176.200195,3231040.000000,4325050.000000,7301.850098,15436.200195,41605.398438}  
	'70Wv'[][7][1]={493.002014,3144.110107,3538.260010,7107.529785,12004.400391,19866.199219,48445.699219,87857.601563,133430.000000,15289.000000,24818.699219,70013.796875,200359.000000,323828.000000,1160470.000000,1725410.000000,52230.398438,179142.000000,259133.000000}  
	'70Wv'[][8][1]={1555.280029,7215.609863,11624.099609,24811.000000,23485.400391,39596.699219,105082.000000,283851.000000,439541.000000,48781.699219,54561.500000,191273.000000,139437.000000,209292.000000,645745.000000,922834.000000,62098.699219,3209780.000000,4670220.000000}  
	'70Wv'[][9][1]={2710.340088,10556.700195,20376.000000,44999.601563,31333.699219,51595.800781,145282.000000,498112.000000,782702.000000,69840.398438,57819.699219,240423.000000,566869.000000,922033.000000,861925.000000,786039.000000,51460.800781,20651000.000000,38034900.000000}  
	'70Wv'[][10][1]={3045.120117,11334.200195,23828.699219,53053.000000,34275.398438,61729.101563,172125.000000,5105320.000000,7711610.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(19,11,2) '71Wv'  
	'71Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'71Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'71Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'71Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'71Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'71Wv'[][5][0]={1349.680054,231.727997,220.604996,197.059998,53.105900,48.251900,43.137901,34.947701,33.862701,230.033005,186.362000,163.276993,93.067398,88.613998, 3.135570, 3.135570,25.811701,12.724100,12.724100}  
	'71Wv'[][6][0]={274.364014,47.105900,44.844700,40.058399,10.795400, 9.808660, 8.769080, 7.104190, 6.883620, 9.505630, 7.701030, 6.747080, 3.845820, 3.661790, 0.129571, 0.129571, 1.066610, 0.525795, 0.525795}  
	'71Wv'[][7][0]={126.627998,21.740801,20.697201,18.488199, 4.982400, 4.527000, 4.047200, 3.278800, 3.177000, 2.024800, 1.640400, 1.437200, 0.819200, 0.780000, 0.027600, 0.027600, 0.227200, 0.112000, 0.112000}  
	'71Wv'[][8][0]={82.307503,14.131400,13.453100,12.017300, 3.238540, 2.942540, 2.630670, 2.131210, 2.065040, 0.855469, 0.693062, 0.607211, 0.346109, 0.329547, 0.011661, 0.011661, 0.095991, 0.047320, 0.047320}  
	'71Wv'[][9][0]={66.430000,11.405400,10.857900, 9.699080, 2.613810, 2.374910, 2.123200, 1.720090, 1.666680, 0.557256, 0.451463, 0.395539, 0.225456, 0.214668, 0.007596, 0.007596, 0.062529, 0.030824, 0.030824}  
	'71Wv'[][10][0]={63.377102,10.881300,10.358900, 9.253340, 2.493690, 2.265760, 2.025620, 1.641040, 1.590090, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'71Wv'[][0][1]={1613.489990,155.393005,58.605900,62.793999,33.320202,12.761200,14.166700, 0.804120, 0.574538, 8.197990, 3.002050, 3.294220, 0.190909, 0.135901, 0.000549, 0.000655, 1.391140, 0.419142, 0.437313}  
	'71Wv'[][1][1]={ 0.000000,1970.140015,1637.079956,2236.169922,436.623993,307.311005,434.670013,66.242897,68.097603,107.264999,69.831100,97.366096,14.559300,14.869100, 0.180792, 0.215257,17.712000, 9.316580,12.298500}  
	'71Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,4102.149902,4814.399902,8237.320313,3587.739990,4525.439941,1049.339966,1076.060059,1793.270020,684.130981,857.072021,32.542999,39.664700,172.229996,140.337006,220.535004}  
	'71Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,25088.800781,36885.398438,81203.203125,107705.000000,149874.000000,7751.490234,9526.980469,19027.500000,16224.400391,22396.699219,2858.239990,3566.219971,1314.030029,1269.650024,2363.429932}  
	'71Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,39244.800781,41866.398438,110932.000000,152659.000000,225082.000000,123095.000000,156586.000000,7828.319824,6687.049805,15287.599609}  
	'71Wv'[][5][1]={ 0.883233, 9.920600, 2.363110, 2.715360,90.346901,57.627399,102.608002,23.302900,25.374399, 0.527745, 0.224305, 0.293063, 0.099877, 0.086545,2413.560059,3008.989990,19.048500,60.994099,90.749397}  
	'71Wv'[][6][1]={57.237099,557.767029,349.589996,620.747009,2837.820068,3863.489990,8537.139648,7631.870117,10999.200195,922.143982,1484.569946,3441.919922,8417.000000,13099.799805,3257710.000000,4377750.000000,7102.069824,13675.299805,36299.101563}  
	'71Wv'[][7][1]={475.653992,3016.219971,3405.750000,6838.919922,11514.200195,19000.800781,46617.800781,83671.500000,126918.000000,14694.900391,24069.800781,67151.703125,196324.000000,310840.000000,1017190.000000,1460490.000000,51647.800781,119010.000000,200420.000000}  
	'71Wv'[][8][1]={1498.609985,6924.040039,11166.200195,23871.199219,22520.400391,37902.199219,101414.000000,270692.000000,419047.000000,46854.300781,53115.800781,186272.000000,150398.000000,230789.000000,744482.000000,957146.000000,66721.898438,2060830.000000,2854340.000000}  
	'71Wv'[][9][1]={2611.310059,10125.500000,19539.599609,43283.601563,30028.699219,49390.699219,140450.000000,470974.000000,740054.000000,67806.101563,57030.199219,238990.000000,419206.000000,645990.000000,1443660.000000,1859930.000000,55492.898438,9758690.000000,17617800.000000}  
	'71Wv'[][10][1]={2931.000000,10887.099609,22904.400391,51212.601562,32739.800781,59108.800781,166391.000000,4747010.000000,7348300.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(20,11,2) '72Wv'  
	'72Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'72Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'72Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'72Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'72Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'72Wv'[][5][0]={1393.109985,240.261993,228.936005,203.809006,55.444401,50.424099,44.928501,36.589199,35.423100,244.529007,198.585999,172.865005,101.702003,97.111801, 7.770770, 7.770770,29.492599,17.313801,13.905600, 2.272150}  
	'72Wv'[][6][0]={283.191986,48.840500,46.538200,41.430401,11.270800,10.250200, 9.133090, 7.437860, 7.200820,10.104700, 8.206170, 7.143310, 4.202610, 4.012950, 0.321111, 0.321111, 1.218720, 0.715457, 0.574619, 0.093892}  
	'72Wv'[][7][0]={130.701996,22.541401,21.478800,19.121401, 5.201800, 4.730800, 4.215200, 3.432800, 3.323400, 2.152400, 1.748000, 1.521600, 0.895200, 0.854800, 0.068400, 0.068400, 0.259600, 0.152400, 0.122400, 0.020000}  
	'72Wv'[][8][0]={84.955597,14.651800,13.961100,12.428800, 3.381150, 3.075000, 2.739870, 2.231310, 2.160200, 0.909380, 0.738523, 0.642870, 0.378218, 0.361149, 0.028899, 0.028899, 0.109680, 0.064388, 0.051714, 0.008450}  
	'72Wv'[][9][0]={68.567299,11.825400,11.268000,10.031300, 2.728910, 2.481820, 2.211330, 1.800880, 1.743490, 0.592373, 0.481076, 0.418767, 0.246373, 0.235254, 0.018825, 0.018825, 0.071446, 0.041943, 0.033686, 0.005504}  
	'72Wv'[][10][0]={65.416199,11.282000,10.750100, 9.570260, 2.603500, 2.367770, 2.109710, 1.718120, 1.663360, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'72Wv'[][0][1]={1688.199951,162.862000,63.753700,67.643898,35.050701,13.897700,15.297600, 0.902078, 0.642105, 8.658310, 3.284290, 3.572960, 0.216102, 0.153188, 0.000668, 0.000790, 1.511120, 0.477280, 0.495674, 0.005636}  
	'72Wv'[][1][1]={ 0.000000,2038.150024,1754.599976,2383.939941,454.803009,328.928986,463.294006,73.312897,75.201599,112.285004,75.095001,104.230003,16.232300,16.543100, 0.220822, 0.262668,19.087500,10.459400,13.801100, 0.354511}  
	'72Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,4229.040039,5043.810059,8645.299805,3907.989990,4923.740234,1090.130005,1134.989990,1892.040039,748.213989,936.577026,39.383202,48.090099,184.360001,154.856003,244.304001,14.764600}  
	'72Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,25362.300781,37395.699219,83623.203125,115234.000000,160372.000000,7975.209961,9836.730469,19789.199219,17346.500000,23953.699219,3398.260010,4250.569824,1395.630005,1375.180054,2582.969971,333.032013}  
	'72Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,39552.898438,41694.101563,113294.000000,157134.000000,232305.000000,141960.000000,181162.000000,8246.860352,7105.660156,16523.800781,3140.320068}  
	'72Wv'[][5][1]={ 0.874796, 9.502460, 2.310850, 2.616570,85.504303,54.844101,97.069199,21.624901,23.258801, 0.480294, 0.205113, 0.264104, 0.078532, 0.062620,71.215500,87.191200,15.416500,31.803499,80.388702,648.280029}  
	'72Wv'[][6][1]={55.528198,534.484985,337.441010,596.336975,2697.139893,3668.770020,8123.259766,7123.049805,10237.400391,849.728027,1359.130005,3174.729980,7099.689941,10912.799805,1770790.000000,2318390.000000,6106.859863,10495.099609,35074.500000,102470.000000}  
	'72Wv'[][7][1]={458.902008,2891.830078,3274.010010,6570.359863,10965.400391,18083.699219,44606.101563,78621.796875,119206.000000,13673.599609,22479.199219,63355.300781,181098.000000,285928.000000,1856730.000000,2598050.000000,47050.000000,64203.300781,189363.000000,7361420.000000}  
	'72Wv'[][8][1]={1443.760010,6642.310059,10717.599609,22947.199219,21466.500000,36142.601563,97459.601563,255715.000000,395984.000000,44007.000000,50541.500000,179580.000000,164955.000000,257060.000000,476388.000000,641885.000000,67087.796875,1095130.000000,2306190.000000,11662000.000000}  
	'72Wv'[][9][1]={2514.030029,9725.179688,18738.500000,41677.601563,28631.300781,47197.601563,135487.000000,441644.000000,693805.000000,64164.000000,54532.500000,234114.000000,298311.000000,446284.000000,709763.000000,975641.000000,55035.601563,5265650.000000,12463300.000000,12384600.000000}  
	'72Wv'[][10][1]={2823.040039,10437.000000,21985.800781,49231.199219,31063.199219,55615.500000,157065.000000,4246290.000000,6792580.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(20,11,2) '73Wv'  
	'73Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'73Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'73Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'73Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'73Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'73Wv'[][5][0]={1437.140015,249.018997,237.391998,210.639008,57.727501,52.626202,46.770302,38.226299,36.987801,256.980988,211.218994,183.817001,109.653999,104.200996,11.360800,11.360800,32.310001,20.403900,16.541300, 2.590260}  
	'73Wv'[][6][0]={292.143005,50.620701,48.257198,42.818802,11.734900,10.697900, 9.507490, 7.770660, 7.518890,10.619200, 8.728210, 7.595870, 4.531230, 4.305890, 0.469460, 0.469460, 1.335140, 0.843151, 0.683534, 0.107037}  
	'73Wv'[][7][0]={134.832993,23.363001,22.272200,19.762199, 5.416000, 4.937400, 4.388000, 3.586400, 3.470200, 2.262000, 1.859200, 1.618000, 0.965200, 0.917200, 0.100000, 0.100000, 0.284400, 0.179600, 0.145600, 0.022800}  
	'73Wv'[][8][0]={87.640900,15.185900,14.476900,12.845400, 3.520380, 3.209290, 2.852190, 2.331150, 2.255620, 0.955685, 0.785504, 0.683598, 0.407793, 0.387513, 0.042250, 0.042250, 0.120158, 0.075880, 0.061515, 0.009633}  
	'73Wv'[][9][0]={70.734596,12.256500,11.684200,10.367400, 2.841280, 2.590210, 2.301990, 1.881460, 1.820500, 0.622537, 0.511680, 0.445298, 0.265638, 0.252427, 0.027522, 0.027522, 0.078271, 0.049429, 0.040071, 0.006275}  
	'73Wv'[][10][0]={67.483803,11.693200,11.147200, 9.890980, 2.710710, 2.471170, 2.196190, 1.794990, 1.736840, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'73Wv'[][0][1]={1764.079956,170.509995,69.264503,72.758598,36.840000,15.112500,16.500700, 1.009690, 0.715727, 9.136850, 3.592100, 3.871730, 0.244224, 0.172409, 0.000816, 0.000959, 1.640400, 0.541975, 0.561230, 0.011507}  
	'73Wv'[][1][1]={ 0.000000,2106.439941,1877.569946,2537.899902,473.191986,351.514008,493.183014,80.949997,82.849998,117.434998,80.687798,111.500999,18.066999,18.373699, 0.268452, 0.318981,20.557199,11.706200,15.443200, 0.728107}  
	'73Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,4352.819824,5274.740234,9062.790039,4246.049805,5344.450195,1131.150024,1195.900024,1995.660034,816.784973,1021.239990,47.183701,57.666401,197.212997,170.307007,269.733002,30.032200}  
	'73Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,25634.099609,37790.000000,86019.000000,122892.000000,171114.000000,8187.009766,10142.799805,20583.099609,18500.500000,25537.400391,3992.979980,5002.069824,1480.760010,1483.920044,2815.320068,661.442017}  
	'73Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,39774.800781,41449.898438,115725.000000,161460.000000,239193.000000,161294.000000,206290.000000,8680.730469,7528.129883,17838.500000,6055.979980}  
	'73Wv'[][5][1]={ 0.868328, 9.152320, 2.264940, 2.524620,81.403900,52.073898,91.911003,20.202900,21.432800, 0.450499, 0.189176, 0.234615, 0.065210, 0.051505,15.836700,19.278299,13.664500,23.390900,56.724701,944.120972}  
	'73Wv'[][6][1]={53.922401,511.630005,326.307007,573.538025,2574.120117,3491.100098,7732.410156,6680.410156,9566.490234,800.081970,1248.689941,2898.199951,6196.160156,9607.099609,1023420.000000,1330570.000000,5590.109863,9218.459961,30256.500000,119037.000000}  
	'73Wv'[][7][1]={443.058014,2773.239990,3151.530029,6318.839844,10475.599609,17234.500000,42691.398438,74131.796875,112277.000000,12929.400391,21034.199219,59393.000000,169042.000000,268493.000000,2180540.000000,3008530.000000,44458.000000,50637.601563,162222.000000,11622500.000000}  
	'73Wv'[][8][1]={1391.930054,6372.740234,10298.099609,22075.800781,20512.099609,34495.300781,93661.703125,242188.000000,374942.000000,41821.398438,48140.898438,172378.000000,178055.000000,279922.000000,449507.000000,611872.000000,67152.601563,783714.000000,1595020.000000,14882900.000000}  
	'73Wv'[][9][1]={2423.330078,9331.019531,18016.500000,40093.800781,27388.699219,45095.199219,130547.000000,416389.000000,652197.000000,61330.800781,52246.699219,228287.000000,224480.000000,331132.000000,567392.000000,797209.000000,56622.500000,3727580.000000,8489140.000000,12524700.000000}  
	'73Wv'[][10][1]={2718.729980,10000.799805,20370.000000,47404.601563,29542.000000,53710.699219,151170.000000,3998760.000000,6060170.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(20,11,2) '74Wv'  
	'74Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'74Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'74Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'74Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'74Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'74Wv'[][5][0]={1482.089966,257.936005,246.087997,217.582001,60.106499,54.890099,48.624901,39.897598,38.567402,270.385986,223.397995,193.268997,117.607002,111.516998,16.586700,15.268900,35.036598,21.267401,16.177700, 2.772030}  
	'74Wv'[][6][0]={301.279999,52.433300,50.024799,44.230202,12.218500,11.158100, 9.884500, 8.110400, 7.840000,11.173200, 9.231470, 7.986460, 4.859850, 4.608220, 0.685412, 0.630955, 1.447820, 0.878830, 0.668511, 0.114548}  
	'74Wv'[][7][0]={139.050003,24.199600,23.087999,20.413601, 5.639200, 5.149800, 4.562000, 3.743200, 3.618400, 2.380000, 1.966400, 1.701200, 1.035200, 0.981600, 0.146000, 0.134400, 0.308400, 0.187200, 0.142400, 0.024400}  
	'74Wv'[][8][0]={90.382004,15.729700,15.007100,13.268800, 3.665460, 3.347350, 2.965280, 2.433070, 2.351950, 1.005540, 0.830796, 0.718750, 0.437368, 0.414722, 0.061684, 0.056783, 0.130298, 0.079091, 0.060163, 0.010309}  
	'74Wv'[][9][0]={72.946899,12.695300,12.112200,10.709200, 2.958380, 2.701630, 2.393270, 1.963720, 1.898250, 0.655012, 0.541183, 0.468196, 0.284903, 0.270151, 0.040181, 0.036989, 0.084876, 0.051520, 0.039191, 0.006715}  
	'74Wv'[][10][0]={69.594498,12.111900,11.555500,10.217000, 2.822420, 2.577470, 2.283280, 1.873470, 1.811010, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'74Wv'[][0][1]={1839.589966,178.335999,75.155197,78.168999,38.669102,16.415899,17.765800, 1.128260, 0.796106, 9.641800, 3.920760, 4.190670, 0.275549, 0.193729, 0.000991, 0.001164, 1.777900, 0.614716, 0.630772, 0.019813}  
	'74Wv'[][1][1]={ 0.000000,2174.810059,2006.750000,2698.550049,491.845001,375.141998,524.185974,89.211899,91.086700,122.773003,86.561203,119.128998,20.075500,20.375200, 0.324058, 0.385088,22.106001,13.061200,17.180401, 1.251900}  
	'74Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,4476.149902,5507.759766,9487.110352,4604.430176,5788.830078,1173.079956,1258.349976,2102.090088,890.190002,1112.000000,56.142700,68.570702,210.645004,186.514008,296.237000,50.960098}  
	'74Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,25778.699219,38107.601563,88367.601563,130793.000000,182139.000000,8399.040039,10439.900391,21368.900391,19696.599609,27188.500000,4666.750000,5836.609863,1568.560059,1593.650024,3050.070068,1095.760010}  
	'74Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,39935.601563,41147.601563,118119.000000,165692.000000,246115.000000,182839.000000,232993.000000,9127.759766,7943.890137,19139.900391,9751.230469}  
	'74Wv'[][5][1]={ 0.861603, 8.826460, 2.208300, 2.439090,77.427200,49.771400,87.258797,18.836599,19.828699, 0.421602, 0.177314, 0.216527, 0.055269, 0.042908, 3.275450, 5.840870,12.378700,23.399200,66.559402,1327.140015}  
	'74Wv'[][6][1]={52.389702,490.718994,315.302002,552.122986,2455.250000,3324.679932,7375.700195,6276.399902,8965.349609,751.281982,1160.640015,2712.239990,5477.470215,8504.040039,496493.000000,776562.000000,5189.839844,9255.580078,33376.699219,150278.000000}  
	'74Wv'[][7][1]={427.891998,2661.260010,3034.929932,6081.450195,10003.299805,16432.900391,40920.199219,69987.898438,105974.000000,12201.400391,19814.199219,56548.500000,158390.000000,252342.000000,2512080.000000,3326170.000000,42301.601563,50394.601563,178938.000000,16371700.000000}  
	'74Wv'[][8][1]={1342.069946,6117.270020,9898.469727,21254.199219,19595.500000,32928.398438,90119.000000,229587.000000,355593.000000,39692.800781,46024.101563,167151.000000,189602.000000,300490.000000,442646.000000,600367.000000,66690.703125,732290.000000,1679720.000000,17352900.000000}  
	'74Wv'[][9][1]={2334.810059,8952.000000,17287.400391,38657.398438,26147.500000,43064.898438,125967.000000,393426.000000,616300.000000,58542.000000,50295.000000,224852.000000,177491.000000,259115.000000,433334.000000,668056.000000,58239.898438,3191620.000000,7773800.000000,12707100.000000}  
	'74Wv'[][10][1]={2620.139893,9617.080078,19599.000000,45660.601562,28204.699219,51348.898438,147796.000000,3693190.000000,5715920.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(21,11,2) '75Wv'  
	'75Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'75Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'75Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'75Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'75Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'75Wv'[][5][0]={1527.949951,267.036011,254.927994,224.585007,62.496201,57.164700,50.464600,41.545399,40.138500,284.019012,235.350006,201.949005,124.377998,118.242996,18.449900,18.449900,37.626900,20.722000,15.723300, 2.755060, 2.367190}  
	'75Wv'[][6][0]={310.602997,54.283298,51.821899,45.653702,12.704200,11.620500,10.258500, 8.445380, 8.159370,11.736500, 9.725340, 8.345130, 5.139650, 4.886140, 0.762403, 0.762403, 1.554850, 0.856296, 0.649733, 0.113847, 0.097819}  
	'75Wv'[][7][0]={143.352997,25.053400,23.917400,21.070601, 5.863400, 5.363200, 4.734600, 3.897800, 3.765800, 2.500000, 2.071600, 1.777600, 1.094800, 1.040800, 0.162400, 0.162400, 0.331200, 0.182400, 0.138400, 0.024251, 0.020837}  
	'75Wv'[][8][0]={93.178802,16.284599,15.546200,13.695800, 3.811190, 3.486060, 3.077470, 2.533560, 2.447760, 1.056240, 0.875242, 0.751028, 0.462548, 0.439734, 0.068613, 0.068613, 0.139931, 0.077063, 0.058473, 0.010246, 0.008803}  
	'75Wv'[][9][0]={75.204201,13.143300,12.547300,11.053800, 3.076000, 2.813590, 2.483820, 2.044820, 1.975570, 0.688038, 0.570136, 0.489222, 0.301305, 0.286444, 0.044695, 0.044695, 0.091151, 0.050199, 0.038090, 0.006674, 0.005735}  
	'75Wv'[][10][0]={71.748100,12.539200,11.970700,10.545800, 2.934630, 2.684280, 2.369670, 1.950850, 1.884780, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'75Wv'[][0][1]={1915.939941,186.363007,81.450203,83.858398,40.547600,17.799700,19.099600, 1.257570, 0.884033,10.158300, 4.274050, 4.534240, 0.310283, 0.217295, 0.001201, 0.001404, 1.920730, 0.693706, 0.708792, 0.024987, 0.002776}  
	'75Wv'[][1][1]={ 0.000000,2243.050049,2141.639893,2865.330078,510.696991,399.694000,556.301025,98.082603,99.936699,128.223999,92.741501,127.161003,22.260599,22.552000, 0.388672, 0.461421,23.725700,14.519000,19.075100, 1.574360, 0.249567}  
	'75Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,4597.080078,5740.299805,9915.429688,4979.799805,6255.140137,1215.589966,1322.239990,2211.550049,967.830994,1208.339966,66.132202,80.866798,224.695999,203.630005,324.471008,63.208401,12.276000}  
	'75Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000,25755.300781,38368.500000,90657.898438,138712.000000,193281.000000,8605.820313,10726.299805,22153.599609,20901.099609,28870.900391,5375.470215,6745.740234,1659.160034,1705.739990,3295.989990,1326.849976,284.824005}  
	'75Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,40085.898438,40762.199219,120494.000000,169630.000000,252725.000000,202675.000000,260033.000000,9583.940430,8358.349609,20495.300781,11485.299805,2630.479980}  
	'75Wv'[][5][1]={ 0.856772, 8.521720, 2.167430, 2.359740,73.840797,47.742802,83.202599,17.767200,18.371901, 0.396186, 0.159107, 0.204284, 0.049611, 0.037302, 2.355560, 2.827140,11.429800,27.679899,79.113403,1627.000000,502.536011}  
	'75Wv'[][6][1]={50.927502,470.998993,305.454010,532.164001,2346.290039,3174.260010,7056.899902,5929.140137,8438.240234,707.320984,1087.439941,2572.770020,5023.959961,7712.629883,417514.000000,538840.000000,4883.950195,10018.400391,37051.199219,192283.000000,73570.000000}  
	'75Wv'[][7][1]={413.388000,2555.020020,2925.899902,5859.450195,9565.459961,15695.799805,39308.398438,66329.898438,100325.000000,11537.099609,18750.300781,54298.699219,150751.000000,239449.000000,2530010.000000,3440590.000000,40571.800781,56246.000000,198683.000000,17979400.000000,4687250.000000}  
	'75Wv'[][8][1]={1294.550049,5874.970215,9523.160156,20479.000000,18739.300781,31477.199219,86865.203125,218231.000000,337943.000000,37729.199219,44108.500000,162975.000000,199682.000000,318652.000000,432044.000000,593334.000000,66197.796875,783516.000000,1777100.000000,15546400.000000,4525270.000000}  
	'75Wv'[][9][1]={2251.550049,8606.570313,16639.000000,37230.500000,25000.199219,41229.500000,121819.000000,373205.000000,584597.000000,55959.300781,48576.101563,222608.000000,149001.000000,215458.000000,420179.000000,597202.000000,60112.101563,2965130.000000,7157210.000000,10769100.000000,3534140.000000}  
	'75Wv'[][10][1]={2524.550049,9233.929688,18821.599609,42373.398438,26851.599609,48126.601563,139127.000000,3301170.000000,5269130.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(21,11,2) '76Wv'  
	'76Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'76Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'76Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'76Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'76Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'76Wv'[][5][0]={1574.729980,276.444000,264.015991,231.738998,64.986000,59.522400,52.381100,43.291302,41.784199,297.334015,248.345993,212.764008,131.511993,123.969002,21.040100,21.040100,38.035900,26.357000,20.631201, 3.204940, 2.739280}  
	'76Wv'[][6][0]={320.112000,56.195599,53.669201,47.108002,13.210400,12.099700,10.648000, 8.800280, 8.493910,12.286700,10.262400, 8.792050, 5.434470, 5.122750, 0.869440, 0.869440, 1.571750, 1.089150, 0.852540, 0.132437, 0.113195}  
	'76Wv'[][7][0]={147.742004,25.936001,24.770000,21.741800, 6.097000, 5.584400, 4.914400, 4.061600, 3.920200, 2.617200, 2.186000, 1.872800, 1.157600, 1.091200, 0.185200, 0.185200, 0.334800, 0.232000, 0.181600, 0.028211, 0.024112}  
	'76Wv'[][8][0]={96.031601,16.858299,16.100401,14.132100, 3.963030, 3.629840, 3.194340, 2.640030, 2.548120, 1.105760, 0.923576, 0.791250, 0.489081, 0.461027, 0.078246, 0.078246, 0.141452, 0.098019, 0.076725, 0.011919, 0.010187}  
	'76Wv'[][9][0]={77.506599,13.606300,12.994600,11.406000, 3.198540, 2.929630, 2.578140, 2.130750, 2.056570, 0.720293, 0.601620, 0.515423, 0.318589, 0.300315, 0.050970, 0.050970, 0.092142, 0.063850, 0.049979, 0.007764, 0.006636}  
	'76Wv'[][10][0]={73.944702,12.981000,12.397400,10.881800, 3.051550, 2.794990, 2.459660, 2.032830, 1.962060, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'76Wv'[][0][1]={1998.910034,194.572998,88.167999,89.869598,42.490799,19.281900,20.514200, 1.399270, 0.979503,10.693900, 4.653880, 4.896790, 0.348784, 0.243262, 0.001448, 0.001687, 2.074210, 0.781922, 0.793199, 0.030706, 0.006824}  
	'76Wv'[][1][1]={ 0.000000,2311.510010,2283.050049,3039.389893,529.875000,425.341003,589.783997,107.672997,109.459000,133.809006,99.252296,135.598007,24.640900,24.911501, 0.463261, 0.549520,25.420000,16.103500,21.103399, 1.927300, 0.613249}  
	'76Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,4717.129883,5974.600098,10354.500000,5380.700195,6751.129883,1258.500000,1388.010010,2326.229980,1050.640015,1310.109985,77.430397,94.671997,239.048996,221.873001,354.554993,76.297096,29.793501}  
	'76Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,38379.800781,92906.203125,147113.000000,205035.000000,8806.450195,11008.400391,22975.699219,22148.400391,30572.099609,6157.799805,7731.370117,1749.079956,1824.390015,3559.820068,1563.939941,675.614990}  
	'76Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,40180.101562,40285.101563,122933.000000,173515.000000,259095.000000,223774.000000,287447.000000,10019.400391,8787.280273,21988.500000,13180.500000,6084.069824}  
	'76Wv'[][5][1]={ 0.851440, 8.226210, 2.127920, 2.284650,70.394798,45.818699,78.829300,16.695000,17.048901, 0.375633, 0.149091, 0.187398, 0.044529, 0.034032, 1.487240, 1.776970,11.989700,16.644400,42.516102,1332.170044,842.825989}  
	'76Wv'[][6][1]={49.532398,451.903992,296.023987,513.146973,2240.750000,3030.620117,6746.390137,5585.859863,7928.560059,669.973022,1014.799988,2393.860107,4606.270020,7209.490234,326497.000000,420702.000000,5035.509766,7928.810059,27586.800781,118386.000000,94287.101563}  
	'76Wv'[][7][1]={399.505005,2452.530029,2821.879883,5647.549805,9141.830078,14990.500000,37738.300781,62751.000000,94875.000000,10958.299805,17698.900391,51509.300781,143339.000000,230275.000000,2556640.000000,3466840.000000,41312.398438,40503.500000,154678.000000,17022300.000000,9001080.000000}  
	'76Wv'[][8][1]={1248.810059,5641.009766,9165.030273,19742.599609,17910.099609,30079.500000,83675.898438,207209.000000,320961.000000,35978.101563,42183.000000,157549.000000,208318.000000,334488.000000,422423.000000,580206.000000,67346.703125,488540.000000,1046580.000000,13249800.000000,7622130.000000}  
	'76Wv'[][9][1]={2170.239990,8263.150391,15993.599609,35937.101563,23923.599609,39400.699219,117594.000000,354913.000000,555184.000000,53634.398438,46797.101563,218335.000000,130931.000000,191419.000000,388640.000000,554103.000000,65126.101563,2061220.000000,4693890.000000,8565130.000000,5465840.000000}  
	'76Wv'[][10][1]={2434.479980,8874.190430,18093.199219,40865.800781,25566.000000,45775.000000,133297.000000,3120920.000000,4692290.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(21,11,2) '77Wv'  
	'77Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'77Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'77Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'77Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'77Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'77Wv'[][5][0]={1622.489990,286.046997,273.376007,239.078995,67.654999,62.005901,54.374199,45.109699,43.495998,313.602997,262.252014,224.625000,141.509995,134.011993,28.810900,27.493099,43.261799,28.629101,22.948799, 3.663960, 3.114920}  
	'77Wv'[][6][0]={329.820007,58.147800,55.571999,48.599998,13.752900,12.604600,11.053200, 9.169920, 8.841880,12.959000,10.837000, 9.282170, 5.847600, 5.537750, 1.190550, 1.136090, 1.787700, 1.183040, 0.948310, 0.151406, 0.128718}  
	'77Wv'[][7][0]={152.222000,26.837000,25.648199,22.430401, 6.347400, 5.817400, 5.101400, 4.232200, 4.080800, 2.760400, 2.308400, 1.977200, 1.245600, 1.179600, 0.253600, 0.242000, 0.380800, 0.252000, 0.202000, 0.032251, 0.027418}  
	'77Wv'[][8][0]={98.943802,17.444000,16.671200,14.579700, 4.125790, 3.781290, 3.315890, 2.750920, 2.652510, 1.166260, 0.975289, 0.835359, 0.526261, 0.498376, 0.107145, 0.102244, 0.160886, 0.106469, 0.085344, 0.013626, 0.011584}  
	'77Wv'[][9][0]={79.857101,14.078900,13.455300,11.767200, 3.329910, 3.051860, 2.676240, 2.220250, 2.140830, 0.759704, 0.635307, 0.544155, 0.342808, 0.324644, 0.069794, 0.066602, 0.104802, 0.069354, 0.055593, 0.008876, 0.007546}  
	'77Wv'[][10][0]={76.187103,13.431900,12.836900,11.226400, 3.176870, 2.911610, 2.553250, 2.118220, 2.042440, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'77Wv'[][0][1]={2084.320068,202.977997,95.350800,96.200401,44.476700,20.856400,21.998899, 1.554740, 1.083760,11.249400, 5.061450, 5.282750, 0.391451, 0.271959, 0.001736, 0.002017, 2.235260, 0.877922, 0.883788, 0.037284, 0.012410}  
	'77Wv'[][1][1]={ 0.000000,2379.830078,2431.260010,3221.250000,549.367981,452.088013,624.556030,118.027000,119.709999,139.565994,106.099998,144.459000,27.244900,27.496799, 0.549802, 0.651284,27.186899,17.785801,23.241600, 2.320020, 1.109080}  
	'77Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,4837.609863,6211.600098,10804.299805,5806.810059,7277.569824,1302.670044,1455.520020,2445.389893,1140.300049,1421.430054,90.500099,110.501999,254.041000,240.621002,385.563995,90.358200,53.088299}  
	'77Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,38778.601563,95120.398438,155937.000000,217373.000000,9012.440430,11283.799805,23822.800781,23494.500000,32464.800781,7081.020020,8871.019531,1844.420044,1940.790039,3824.129883,1808.819946,1176.699951}  
	'77Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,40174.398438,39719.601562,125402.000000,177508.000000,266096.000000,250508.000000,320563.000000,10506.700195,9193.330078,23458.000000,14857.099609,10343.299805}  
	'77Wv'[][5][1]={ 0.848373, 7.949620, 2.089590, 2.210840,66.870300,43.891399,74.971001,15.675600,15.803900, 0.349639, 0.139375, 0.170844, 0.035539, 0.027196, 0.377159, 0.563207, 9.463630,14.890400,35.085201,1107.310059,1072.800049}  
	'77Wv'[][6][1]={48.198399,433.875000,286.992004,494.704010,2134.540039,2889.770020,6445.200195,5258.799805,7443.310059,625.132996,945.073975,2215.439941,4019.149902,6175.180176,152774.000000,223357.000000,4318.919922,7501.680176,25319.400391,77534.500000,94213.703125}  
	'77Wv'[][7][1]={386.204010,2355.209961,2722.280029,5443.540039,8720.200195,14303.099609,36214.699219,59341.398438,89684.000000,10294.000000,16682.500000,48694.101563,132923.000000,212257.000000,2498330.000000,3402950.000000,37110.800781,37936.199219,146989.000000,15999600.000000,12927600.000000}  
	'77Wv'[][8][1]={1205.150024,5418.979980,8823.250000,19033.599609,17093.199219,28721.599609,80581.500000,196701.000000,304796.000000,34029.601563,40277.300781,151871.000000,214696.000000,346230.000000,461862.000000,615074.000000,63932.699219,423220.000000,863663.000000,11557000.000000,9863560.000000}  
	'77Wv'[][9][1]={2093.689941,7944.379883,15401.599609,34653.398438,22808.800781,37636.601563,113507.000000,337881.000000,528760.000000,51012.500000,44989.500000,213374.000000,117753.000000,172286.000000,300964.000000,444890.000000,62294.800781,1749260.000000,3837080.000000,7199740.000000,6704390.000000}  
	'77Wv'[][10][1]={2346.689941,8525.540039,17388.099609,39425.000000,24449.300781,44253.199219,130228.000000,2871180.000000,4303920.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(21,11,2) '78Wv'  
	'78Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'78Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'78Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'78Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'78Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'78Wv'[][5][0]={1671.170044,295.882996,282.937012,246.507996,70.262100,64.517097,56.393002,46.938702,45.227001,328.098999,276.838989,235.850006,150.326004,142.373001,33.764198,32.310001,46.215599,29.674299,23.494101, 3.380920, 2.783560}  
	'78Wv'[][6][0]={339.717010,60.147202,57.515598,50.110199,14.282900,13.115100,11.463600, 9.541730, 9.193760,13.558000,11.439800, 9.745990, 6.211900, 5.883280, 1.395240, 1.335140, 1.909760, 1.226230, 0.970844, 0.139710, 0.115025}  
	'78Wv'[][7][0]={156.789993,27.759800,26.545200,23.127399, 6.592000, 6.053000, 5.290800, 4.403800, 4.243200, 2.888000, 2.436800, 2.076000, 1.323200, 1.253200, 0.297200, 0.284400, 0.406800, 0.261200, 0.206800, 0.029760, 0.024502}  
	'78Wv'[][8][0]={101.913002,18.043800,17.254299,15.032700, 4.284780, 3.934430, 3.439000, 2.862460, 2.758070, 1.220170, 1.029540, 0.877101, 0.559046, 0.529472, 0.125566, 0.120158, 0.171871, 0.110356, 0.087372, 0.012573, 0.010352}  
	'78Wv'[][9][0]={82.253304,14.563100,13.925900,12.132900, 3.458230, 3.175460, 2.775600, 2.310280, 2.226020, 0.794821, 0.670644, 0.571347, 0.364165, 0.344900, 0.081794, 0.078271, 0.111958, 0.071886, 0.056915, 0.008190, 0.006743}  
	'78Wv'[][10][0]={78.473198,13.893800,13.285900,11.575300, 3.299300, 3.029530, 2.648050, 2.204100, 2.123720, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'78Wv'[][0][1]={2152.870117,211.556000,103.002998,102.875000,46.523201,22.531900,23.570801, 1.723890, 1.196650,11.823300, 5.502690, 5.692520, 0.438516, 0.303463, 0.002074, 0.002402, 2.397870, 0.977953, 0.973817, 0.042771, 0.023465}  
	'78Wv'[][1][1]={ 0.000000,2448.270020,2586.149902,3410.679932,569.038025,479.916992,660.747009,129.156998,130.709000,145.440002,113.329002,153.742004,30.067200,30.290899, 0.648876, 0.767768,28.944099,19.488400,25.313000, 2.608240, 2.049960}  
	'78Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,4954.470215,6448.810059,11264.900391,6258.430176,7836.310059,1346.930054,1525.040039,2568.580078,1235.319946,1539.010010,105.027000,128.175995,268.688995,258.885986,414.665985,99.390404,95.890701}  
	'78Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,97432.000000,165190.000000,230390.000000,9208.599609,11554.299805,24683.300781,24872.599609,34389.398438,8065.939941,10105.000000,1934.869995,2048.149902,4062.570068,1943.160034,2077.520020}  
	'78Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,40178.000000,38976.500000,127953.000000,181224.000000,272765.000000,276767.000000,354411.000000,10957.000000,9545.519531,24760.000000,15571.599609,17845.800781}  
	'78Wv'[][5][1]={ 0.846432, 7.687040, 2.053880, 2.130920,63.483601,42.172699,71.461800,14.778300,14.696000, 0.332288, 0.130481, 0.149948, 0.031049, 0.022411, 0.201936, 0.297192, 8.762060,14.910500,35.813000,1458.410034,2485.030029}  
	'78Wv'[][6][1]={46.926601,416.657013,278.498993,476.970001,2041.329956,2761.560059,6167.740234,4969.399902,7008.560059,592.278992,880.565002,2075.379883,3631.540039,5549.029785,105968.000000,154105.000000,4065.820068,7464.910156,25837.000000,130757.000000,306833.000000}  
	'78Wv'[][7][1]={373.480011,2262.500000,2628.659912,5252.700195,8343.530273,13670.099609,34803.300781,56307.000000,85020.500000,9783.349609,15729.400391,46410.101563,125298.000000,200042.000000,2356520.000000,3225300.000000,35385.500000,37688.800781,149481.000000,15573300.000000,19785600.000000}  
	'78Wv'[][8][1]={1163.339966,5206.620117,8500.879883,18371.800781,16352.000000,27461.300781,77696.296875,187320.000000,290271.000000,32463.500000,38386.300781,147090.000000,218162.000000,352991.000000,450271.000000,597038.000000,60787.699219,426001.000000,885650.000000,10632800.000000,15738900.000000}  
	'78Wv'[][9][1]={2020.089966,7630.899902,14814.500000,33486.601563,21835.500000,36029.398438,109724.000000,322146.000000,504087.000000,48631.199219,43068.000000,209243.000000,112476.000000,165764.000000,288862.000000,432387.000000,60415.601563,1793900.000000,4116500.000000,7138560.000000,11531200.000000}  
	'78Wv'[][10][1]={2262.840088,8209.950195,16786.400391,38127.101562,23311.300781,40899.101563,123099.000000,2506650.000000,4003910.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(21,11,2) '79Wv'  
	'79Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'79Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'79Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'79Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'79Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'79Wv'[][5][0]={372.713013,305.963989,292.764008,254.074997,73.009903,67.102898,58.473598,48.840302,47.019699,344.821991,292.516998,247.847000,159.960007,151.733994,39.262798,37.626900,48.987598,32.582699,24.402901, 3.775590, 3.085730}  
	'79Wv'[][6][0]={168.044006,62.196499,59.513302,51.648602,14.841500,13.640700,11.886500, 9.928270, 9.558190,14.249100,12.087700,10.241700, 6.610000, 6.270110, 1.622450, 1.554850, 2.024310, 1.346410, 1.008400, 0.156018, 0.127511}  
	'79Wv'[][7][0]={114.162003,28.705601,27.467199,23.837400, 6.849800, 6.295600, 5.486000, 4.582200, 4.411400, 3.035200, 2.574800, 2.181600, 1.408000, 1.335600, 0.345600, 0.331200, 0.431200, 0.286800, 0.214800, 0.033234, 0.027161}  
	'79Wv'[][8][0]={92.040298,18.658501,17.853600,15.494200, 4.452350, 4.092120, 3.565880, 2.978420, 2.867400, 1.282360, 1.087840, 0.921717, 0.594874, 0.564285, 0.146015, 0.139931, 0.182180, 0.121172, 0.090752, 0.014041, 0.011475}  
	'79Wv'[][9][0]={82.687599,15.059200,14.409600,12.505300, 3.593470, 3.302730, 2.878010, 2.403870, 2.314260, 0.835333, 0.708624, 0.600409, 0.387503, 0.367577, 0.095114, 0.091151, 0.118673, 0.078932, 0.059116, 0.009146, 0.007475}  
	'79Wv'[][10][0]={ 0.000000,14.367200,13.747300,11.930600, 3.428320, 3.150950, 2.745740, 2.293390, 2.207910, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'79Wv'[][0][1]={ 0.000000,220.632004,111.160004,109.872002,48.608501,24.318600,25.214800, 1.908770, 1.318990,12.424600, 5.970690, 6.131340, 0.490304, 0.337983, 0.002465, 0.002847, 2.572200, 1.090610, 1.076830, 0.050855, 0.033386}  
	'79Wv'[][1][1]={ 0.000000,2516.199951,2747.679932,3607.070068,588.896973,508.802002,698.127991,141.108002,142.470001,151.485992,120.865997,163.470993,33.118500,33.306599, 0.761895, 0.900383,30.813000,21.378599,27.666800, 3.074160, 2.900800}  
	'79Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,5069.569824,6683.990234,11731.099609,6733.830078,8423.349609,1391.800049,1595.739990,2695.159912,1335.729980,1663.359985,121.242996,147.876999,284.109009,278.903992,447.593994,115.277000,133.738007}  
	'79Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,99664.203125,174732.000000,243802.000000,9401.990234,11811.200195,25549.300781,26275.900391,36360.000000,9131.000000,11437.799805,2028.680054,2164.770020,4332.259766,2201.760010,2833.179932}  
	'79Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,40092.699219,38153.699219,130381.000000,184692.000000,279084.000000,303589.000000,388956.000000,11406.400391,9921.419922,26230.900391,17229.400391,23805.300781}  
	'79Wv'[][5][1]={38.629299, 7.438450, 2.019550, 2.065370,60.482300,40.569000,68.088501,13.922300,13.653400, 0.312763, 0.121744, 0.137876, 0.026898, 0.018936, 0.108959, 0.162118, 8.259630,12.929800,35.295799,1262.500000,2647.120117}  
	'79Wv'[][6][1]={324.666992,400.268005,270.381989,460.459991,1949.150024,2639.750000,5900.459961,4690.479980,6592.490234,555.851990,818.143005,1938.359985,3259.020020,4930.040039,73797.398438,107022.000000,3872.290039,6920.779785,25916.699219,93408.203125,271471.000000}  
	'79Wv'[][7][1]={902.221985,2173.699951,2538.770020,5069.529785,7972.600098,13064.500000,33435.500000,53360.898438,80502.796875,9229.879883,14799.000000,44127.199219,117528.000000,187188.000000,2183820.000000,3008850.000000,34036.699219,34738.800781,151242.000000,14953300.000000,22768300.000000}  
	'79Wv'[][8][1]={1572.689941,5003.649902,8191.919922,17732.000000,15626.099609,26247.000000,74900.101563,178147.000000,276057.000000,30793.099609,36558.101563,142208.000000,221380.000000,359200.000000,473625.000000,623508.000000,59422.101563,363106.000000,843603.000000,9368700.000000,16474100.000000}  
	'79Wv'[][9][1]={2059.219971,7338.009766,14277.099609,32306.099609,20858.400391,34417.601562,106049.000000,308141.000000,481926.000000,46336.500000,41252.300781,204849.000000,109209.000000,162360.000000,254615.000000,379320.000000,61084.398438,1527340.000000,3729800.000000,6231520.000000,11680700.000000}  
	'79Wv'[][10][1]={ 0.000000,7891.479980,16157.200195,36908.101563,22135.500000,38574.101563,113810.000000,2278070.000000,3517300.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(22,11,2) '80Wv'  
	'80Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'80Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'80Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'80Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'80Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'80Wv'[][5][0]={383.690002,316.334991,302.891998,261.860992,75.924004,69.889000,60.692699,50.839802,48.921299,363.681000,307.604004,259.480011,171.910995,163.503998,46.442799,44.761398,54.667999,36.581699,26.175200, 2.908360, 2.908360, 3.505300}  
	'80Wv'[][6][0]={172.992996,64.304703,61.572102,53.231098,15.433900,14.207100,12.337600,10.334700, 9.944730,15.028400,12.711100,10.722500, 7.103870, 6.756470, 1.919150, 1.849670, 2.259040, 1.511660, 1.081640, 0.120182, 0.120182, 0.144849}  
	'80Wv'[][7][0]={117.524002,29.678600,28.417400,24.567801, 7.123200, 6.557000, 5.694200, 4.769800, 4.589800, 3.201200, 2.707600, 2.284000, 1.513200, 1.439200, 0.408800, 0.394000, 0.481200, 0.322000, 0.230400, 0.025600, 0.025600, 0.030854}  
	'80Wv'[][8][0]={94.750999,19.291000,18.471201,15.969000, 4.630060, 4.262030, 3.701210, 3.100350, 2.983350, 1.352490, 1.143950, 0.964980, 0.639321, 0.608056, 0.172716, 0.166463, 0.203305, 0.136044, 0.097343, 0.010816, 0.010816, 0.013036}  
	'80Wv'[][9][0]={85.122803,15.569700,14.908000,12.888500, 3.736900, 3.439860, 2.987230, 2.502280, 2.407850, 0.881019, 0.745172, 0.628591, 0.416455, 0.396090, 0.112508, 0.108435, 0.132434, 0.088619, 0.063410, 0.007046, 0.007046, 0.008492}  
	'80Wv'[][10][0]={ 0.000000,14.854100,14.222900,12.296200, 3.565160, 3.281780, 2.849950, 2.387280, 2.297190, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'80Wv'[][0][1]={ 0.000000,229.522995,119.987999,117.238998,50.744900,26.212099,26.952200, 2.109240, 1.451950,13.036800, 6.469680, 6.590160, 0.547235, 0.375783, 0.002916, 0.003360, 2.759420, 1.217360, 1.194940, 0.062019, 0.040860, 0.243562}  
	'80Wv'[][1][1]={ 0.000000,2583.530029,2916.040039,3811.510010,608.994995,538.838013,736.974976,153.906006,155.072006,157.634003,128.707993,173.533005,36.421700,36.566700, 0.890594, 1.051180,32.808998,23.472300,30.348900, 3.750500, 3.580660, 2.622760}  
	'80Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,5182.549805,6920.410156,12208.200195,7234.729980,9043.049805,1437.089966,1666.589966,2823.669922,1442.550049,1795.800049,139.378006,169.904007,300.529999,300.726990,484.944000,138.964996,163.794006,22.937500}  
	'80Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,101485.000000,184604.000000,257821.000000,9591.419922,12044.700195,26396.599609,27737.000000,38421.800781,10294.000000,12895.799805,2128.760010,2289.889893,4637.799805,2591.219971,3392.000000,163.815994}  
	'80Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,39842.300781,37353.199219,132725.000000,187947.000000,285280.000000,331972.000000,425758.000000,11891.000000,10319.099609,27901.300781,19821.199219,27899.599609,958.838989}  
	'80Wv'[][5][1]={37.670898, 7.198990, 1.985580, 2.001010,57.488201,38.626999,64.644798,13.076000,12.630200, 0.291844, 0.115271, 0.128319, 0.022318, 0.015292, 0.054329, 0.076155, 6.721560,10.639300,32.023499,2782.540039,3650.290039,125.570999}  
	'80Wv'[][6][1]={314.210999,384.036011,262.480011,444.345001,1857.459961,2514.959961,5628.209961,4416.370117,6177.839844,517.651978,767.518982,1824.180054,2837.850098,4230.520020,47886.601562,68313.898438,3397.790039,6229.200195,24897.099609,354707.000000,417584.000000,11494.900391}  
	'80Wv'[][7][1]={871.379028,2088.100098,2451.870117,4891.009766,7605.569824,12453.900391,32045.199219,50452.898438,75985.203125,8656.080078,13999.400391,42133.500000,108309.000000,171749.000000,1922910.000000,2655410.000000,30976.000000,31394.500000,149796.000000,17363400.000000,25729800.000000,45396.000000}  
	'80Wv'[][8][1]={1518.189941,4807.279785,7892.879883,17112.699219,14912.500000,25036.099609,72048.203125,169043.000000,261801.000000,29067.199219,34956.601563,137870.000000,223220.000000,362658.000000,565485.000000,744125.000000,57560.199219,282175.000000,723184.000000,9453460.000000,15345400.000000,1154200.000000}  
	'80Wv'[][9][1]={1988.589966,7049.549805,13737.700195,31212.599609,19887.800781,32819.898438,102182.000000,294713.000000,461423.000000,44198.199219,39751.699219,200981.000000,109609.000000,165933.000000,208792.000000,302197.000000,60507.300781,1138390.000000,2809720.000000,8431510.000000,12314200.000000,5944230.000000}  
	'80Wv'[][10][1]={ 0.000000,7582.370117,15523.700195,35622.898438,21237.699219,37971.601563,110843.000000,2243730.000000,3343580.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(22,11,2) '81Wv'  
	'81Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'81Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'81Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'81Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'81Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'81Wv'[][5][0]={394.899994,327.151001,313.321014,269.825012,78.961700,72.813797,63.027000,52.975800,50.933601,384.221008,327.781006,276.747986,184.772003,175.501007,55.804100,53.849998,61.938900,45.261299,34.264099, 6.952790, 5.953040, 4.392000}  
	'81Wv'[][6][0]={178.046997,66.503502,63.692001,54.850101,16.051399,14.801600,12.812100,10.768900,10.353800,15.877100,13.544900,11.436100, 7.635300, 7.252220, 2.305990, 2.225240, 2.559500, 1.870330, 1.415890, 0.287310, 0.245997, 0.181490}  
	'81Wv'[][7][0]={120.958000,30.693399,29.395800,25.315001, 7.408200, 6.831400, 5.913200, 4.970200, 4.778600, 3.382000, 2.885200, 2.436000, 1.626400, 1.544800, 0.491200, 0.474000, 0.545200, 0.398400, 0.301600, 0.061200, 0.052400, 0.038659}  
	'81Wv'[][8][0]={97.519402,19.950600,19.107201,16.454700, 4.815310, 4.440390, 3.843560, 3.230610, 3.106070, 1.428880, 1.218980, 1.029200, 0.687147, 0.652671, 0.207530, 0.200263, 0.230345, 0.168322, 0.127425, 0.025857, 0.022139, 0.016333}  
	'81Wv'[][9][0]={87.610001,16.101999,15.421300,13.280500, 3.886410, 3.583820, 3.102120, 2.607410, 2.506900, 0.930777, 0.794051, 0.670424, 0.447610, 0.425152, 0.135186, 0.130452, 0.150047, 0.109646, 0.083005, 0.016843, 0.014421, 0.010640}  
	'81Wv'[][10][0]={ 0.000000,15.362000,14.712600,12.670200, 3.707800, 3.419120, 2.959560, 2.487590, 2.391690, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'81Wv'[][0][1]={ 0.000000,238.656006,129.225998,124.958000,52.944401,28.229300,28.768499, 2.327260, 1.595280,13.668400, 7.003950, 7.077360, 0.609680, 0.417017, 0.003436, 0.003948, 2.955450, 1.353430, 1.321090, 0.074891, 0.049695, 0.322028}  
	'81Wv'[][1][1]={ 0.000000,2650.929932,3091.139893,4023.649902,629.299011,570.030029,777.151001,167.645996,168.537003,163.903000,136.960999,184.147003,39.980202,40.066799, 1.036890, 1.222200,34.880199,25.704300,33.229500, 4.534070, 4.377030, 3.492570}  
	'81Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,5292.600098,7155.319824,12694.700195,7766.120117,9697.690430,1482.599976,1740.099976,2959.820068,1555.040039,1934.579956,159.679993,194.503006,317.410004,323.764008,525.348999,166.225006,198.447998,30.563999}  
	'81Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,107800.000000,195036.000000,272518.000000,9774.769531,12279.099609,27318.199219,29221.599609,40495.500000,11575.099609,14495.200195,2230.550049,2419.939941,4973.020020,3031.790039,4021.899902,216.845001}  
	'81Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,39569.699219,36269.199219,135200.000000,190982.000000,291232.000000,362794.000000,465411.000000,12376.099609,10712.000000,29784.199219,22667.300781,32401.000000,1261.869995}  
	'81Wv'[][5][1]={36.750500, 6.962730, 1.952640, 1.938680,54.617100,36.942001,61.221401,12.154300,11.630800, 0.271509, 0.104859, 0.112246, 0.018479, 0.012583, 0.023893, 0.033166, 5.453520, 6.597650,16.868299,343.808014,667.043030,112.208000}  
	'81Wv'[][6][1]={304.158997,368.510010,254.904999,428.747009,1768.810059,2393.399902,5359.049805,4141.640137,5770.270020,480.141998,698.989990,1642.630005,2464.540039,3661.520020,28986.400391,41200.300781,2901.149902,4895.479980,17707.300781,39589.898438,60946.300781,11709.500000}  
	'81Wv'[][7][1]={841.719971,2004.359985,2368.219971,4718.600098,7250.069824,11859.799805,30669.000000,47547.800781,71525.101563,8090.290039,12999.299805,39087.800781,99482.898438,157913.000000,1593840.000000,2209710.000000,27592.900391,25824.500000,122690.000000,6899230.000000,13976100.000000,38995.601563}  
	'81Wv'[][8][1]={1465.030029,4616.490234,7605.979980,16512.599609,14218.599609,23856.900391,69222.796875,159970.000000,247681.000000,27381.400391,33023.699219,131049.000000,224271.000000,365015.000000,749133.000000,983727.000000,54876.199219,174385.000000,433154.000000,9519480.000000,14531100.000000,972106.000000}  
	'81Wv'[][9][1]={1917.290039,6773.049805,13237.000000,30123.900391,19002.500000,31273.199219,98373.500000,281338.000000,440288.000000,41939.800781,37786.601562,192620.000000,117338.000000,181976.000000,184318.000000,257940.000000,56690.000000,777126.000000,1640880.000000,4303450.000000,7702540.000000,5652070.000000}  
	'81Wv'[][10][1]={ 0.000000,7278.799805,14920.700195,34298.800781,20241.800781,36988.300781,113082.000000,2133380.000000,3370420.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(23,11,2) '82Wv'  
	'82Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'82Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'82Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'82Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'82Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'82Wv'[][5][0]={406.322998,338.110992,324.023987,277.876007,82.086800,75.766197,65.367599,55.118198,52.952400,406.079010,347.140015,292.881012,197.768005,187.634003,64.938202,62.756901,66.937599,47.624298,39.081001, 9.906590, 8.725070, 5.312470, 2.232010}  
	'82Wv'[][6][0]={183.197998,68.731300,65.867798,56.486801,16.686600,15.401800,13.288000,11.204500,10.764200,16.780399,14.344800,12.102700, 8.172360, 7.753610, 2.683430, 2.593300, 2.766060, 1.967980, 1.614940, 0.409369, 0.360545, 0.219527, 0.092233}  
	'82Wv'[][7][0]={124.457001,31.721600,30.400000,26.070400, 7.701400, 7.108400, 6.132800, 5.171200, 4.968000, 3.574400, 3.055600, 2.578000, 1.740800, 1.651600, 0.571600, 0.552400, 0.589200, 0.419200, 0.344000, 0.087200, 0.076800, 0.046762, 0.019647}  
	'82Wv'[][8][0]={100.339996,20.618900,19.759899,16.945700, 5.005880, 4.620440, 3.986300, 3.361260, 3.229180, 1.510170, 1.290980, 1.089190, 0.735481, 0.697794, 0.241499, 0.233387, 0.248934, 0.177110, 0.145339, 0.036842, 0.032448, 0.019756, 0.008301}  
	'82Wv'[][9][0]={90.144203,16.641500,15.948100,13.676800, 4.040230, 3.729130, 3.217320, 2.712860, 2.606260, 0.983729, 0.840947, 0.709505, 0.479094, 0.454545, 0.157313, 0.152029, 0.162157, 0.115370, 0.094674, 0.023999, 0.021136, 0.012869, 0.005407}  
	'82Wv'[][10][0]={ 0.000000,15.876700,15.215200,13.048200, 3.854550, 3.557750, 3.069470, 2.588190, 2.486480, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'82Wv'[][0][1]={ 0.000000,247.876999,139.016006,133.052002,55.178699,30.357300,30.680000, 2.564410, 1.750500,14.318500, 7.572760, 7.591560, 0.678053, 0.461994, 0.004032, 0.004621, 3.161780, 1.501970, 1.458890, 0.089543, 0.059543, 0.393189, 0.097781}  
	'82Wv'[][1][1]={ 0.000000,2717.179932,3272.979980,4242.770020,649.716980,602.176025,818.620972,182.313004,182.878006,170.298004,145.542007,195.160995,43.810299,43.826302, 1.202290, 1.415210,37.036499,28.081200,36.328800, 5.399270, 5.241070, 4.273420, 1.603690}  
	'82Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,5399.470215,7385.020020,13184.599609,8320.599609,10380.900391,1528.430054,1813.839966,3098.270020,1673.459961,2080.629883,182.167999,221.727997,334.695007,347.391998,567.994019,195.322006,234.869995,37.325401,18.622801}  
	'82Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,205728.000000,287412.000000,9952.650391,12491.099609,28227.500000,30730.900391,42607.800781,12949.900391,16211.799805,2332.000000,2546.100098,5318.390137,3483.389893,4658.669922,262.933014,137.449005}  
	'82Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,39227.101562,35186.300781,137553.000000,193727.000000,296820.000000,394024.000000,505706.000000,12834.099609,11081.900391,31683.599609,25483.099609,36794.300781,1523.900024,629.869019}  
	'82Wv'[][5][1]={35.871700, 6.743670, 1.920850, 1.880790,51.904301,35.439800,58.181900,11.409500,10.704400, 0.252745, 0.097209, 0.100782, 0.015561, 0.010584, 0.012623, 0.017377, 4.738880, 6.373040,12.528500,141.210999,249.895996,97.195503,216.537994}  
	'82Wv'[][6][1]={294.523987,353.929993,247.397003,414.138000,1684.869995,2282.719971,5114.120117,3897.820068,5407.709961,444.717010,644.844971,1504.729980,2162.639893,3199.590088,19181.699219,27119.900391,2667.750000,4764.160156,15330.200195,48489.699219,77629.703125,11322.200195,37120.300781}  
	'82Wv'[][7][1]={813.226990,1925.359985,2288.320068,4556.140137,6912.609863,11311.400391,29399.599609,44929.101562,67492.000000,7553.370117,12162.299805,36656.699219,91739.703125,145721.000000,1324030.000000,1836850.000000,25855.599609,25354.500000,114309.000000,2526930.000000,4999400.000000,38387.800781,2332260.000000}  
	'82Wv'[][8][1]={1414.640015,4434.959961,7330.950195,15947.200195,13559.900391,22763.199219,66591.703125,151687.000000,234747.000000,25753.199219,31334.099609,125313.000000,223298.000000,364429.000000,962868.000000,1265560.000000,53445.398438,153903.000000,348896.000000,13927000.000000,19581000.000000,706199.000000,14477400.000000}  
	'82Wv'[][9][1]={1851.959961,6505.569824,12735.900391,29116.500000,18136.000000,29838.500000,94860.898438,268430.000000,419984.000000,39676.500000,36176.101562,186196.000000,131121.000000,208738.000000,169274.000000,233725.000000,55956.101563,663843.000000,1225270.000000,3251420.000000,5958860.000000,4520770.000000,33478300.000000}  
	'82Wv'[][10][1]={ 0.000000,6997.189941,14381.000000,33094.898438,19197.500000,35104.101563,109804.000000,2024230.000000,3163860.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(23,11,2) '83Wv'  
	'83Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'83Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'83Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'83Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'83Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'83Wv'[][5][0]={417.964996,349.338989,334.920013,286.049011,85.250298,78.795403,67.723198,57.292599,54.990299,426.346985,365.953003,308.513000,210.673996,199.949997,73.572304,71.527397,72.390800,53.077499,42.171200,12.042400,11.088100, 6.468090, 2.803800}  
	'83Wv'[][6][0]={188.445999,71.013702,68.082603,58.148201,17.329700,16.017599,13.766800,11.646500,11.178500,17.617901,15.122300,12.748700, 8.705670, 8.262500, 3.040220, 2.955720, 2.991400, 2.193320, 1.742640, 0.497628, 0.458193, 0.267280, 0.115861}  
	'83Wv'[][7][0]={128.022995,32.775002,31.422199,26.837200, 7.998200, 7.392600, 6.353800, 5.375200, 5.159200, 3.752800, 3.221200, 2.715600, 1.854400, 1.760000, 0.647600, 0.629600, 0.637200, 0.467200, 0.371200, 0.106000, 0.097600, 0.056934, 0.024680}  
	'83Wv'[][8][0]={103.214996,21.303600,20.424299,17.444099, 5.198800, 4.805170, 4.129950, 3.493860, 3.353460, 1.585540, 1.360940, 1.147330, 0.783476, 0.743592, 0.273608, 0.266003, 0.269214, 0.197390, 0.156830, 0.044785, 0.041236, 0.024054, 0.010427}  
	'83Wv'[][9][0]={92.726898,17.194099,16.484400,14.079000, 4.195930, 3.878230, 3.333260, 2.819880, 2.706570, 1.032830, 0.886523, 0.747374, 0.510359, 0.484379, 0.178229, 0.173275, 0.175367, 0.128580, 0.102160, 0.029173, 0.026861, 0.015669, 0.006792}  
	'83Wv'[][10][0]={ 0.000000,16.403900,15.726800,13.432000, 4.003100, 3.700000, 3.180080, 2.690290, 2.582180, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'83Wv'[][0][1]={ 0.000000,257.295013,149.416000,141.511002,57.472500,32.609600,32.670700, 2.820400, 1.917080,14.995000, 8.183040, 8.133240, 0.752777, 0.510925, 0.004714, 0.005388, 3.372750, 1.666260, 1.607680, 0.106654, 0.070755, 0.468858, 0.144044}  
	'83Wv'[][1][1]={ 0.000000,2782.750000,3460.820068,4469.100098,670.226013,635.364014,861.231995,197.929001,198.100006,176.798004,154.479004,206.587006,47.918400,47.855400, 1.388420, 1.632110,39.250599,30.635201,39.625301, 6.368260, 6.198560, 5.102200, 2.365910}  
	'83Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,5501.379883,7610.209961,13676.700195,8899.629883,11092.500000,1573.420044,1887.630005,3239.149902,1797.390015,2233.800049,206.899002,251.695999,352.372986,372.131989,612.517029,226.639999,273.989014,44.455601,27.226299}  
	'83Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,216495.000000,302748.000000,10112.500000,12679.900391,29128.000000,32245.800781,44745.000000,14403.500000,18037.599609,2434.270020,2675.409912,5670.959961,3950.729980,5317.549805,311.039001,197.455994}  
	'83Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,38650.601563,34116.398437,139812.000000,196220.000000,302076.000000,424836.000000,546186.000000,13285.799805,11441.500000,33584.300781,28295.699219,41195.000000,1796.660034,895.054993}  
	'83Wv'[][5][1]={35.031300, 6.536830, 1.892200, 1.825880,49.434101,34.043499,55.412300,10.736000, 9.931030, 0.239858, 0.091529, 0.091959, 0.013350, 0.009049, 0.007370, 0.009793, 4.229700, 5.133490,11.083500,89.741501,136.016998,80.693703,219.574005}  
	'83Wv'[][6][1]={285.286987,340.036987,240.638000,400.200989,1606.949951,2178.879883,4888.970215,3675.459961,5079.459961,417.084015,600.692017,1392.099976,1920.670044,2817.760010,13740.099609,19018.000000,2445.929932,4271.240234,14409.599609,51561.101563,83653.101563,10730.599609,28690.099609}  
	'83Wv'[][7][1]={785.885010,1849.790039,2213.100098,4401.359863,6596.790039,10793.000000,28219.500000,42511.398437,63789.898438,7116.509766,11441.799805,34588.398438,85025.898438,134831.000000,1117140.000000,1538130.000000,24154.900391,23504.800781,111980.000000,1270820.000000,2191220.000000,40150.199219,2224830.000000}  
	'83Wv'[][8][1]={1365.579956,4261.910156,7071.680176,15404.900391,12940.500000,21720.800781,64132.800781,143959.000000,222771.000000,24382.699219,29811.400391,120338.000000,221362.000000,361423.000000,1183280.000000,1575190.000000,52025.500000,121862.000000,313722.000000,20336800.000000,29711300.000000,452449.000000,15599700.000000}  
	'83Wv'[][9][1]={1786.270020,6253.209961,12280.500000,28119.500000,17344.500000,28461.800781,91479.296875,255535.000000,401488.000000,37838.398438,34709.398438,181400.000000,148494.000000,242470.000000,157518.000000,216121.000000,55566.898438,547338.000000,1009970.000000,2788150.000000,5008160.000000,3054770.000000,32534500.000000}  
	'83Wv'[][10][1]={ 0.000000,6720.549805,13831.900391,32014.199219,18283.099609,34004.898438,105628.000000,1912360.000000,2956410.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(24,11,2) '84Wv'  
	'84Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'84Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'84Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'84Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'84Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'84Wv'[][5][0]={429.872986,361.101990,346.286011,294.473999,88.454300,82.159302,70.387901,59.646000,57.194500,452.295013,386.721008,320.373993,227.306000,215.128006,79.681602,76.963203,77.665100,57.119801,44.676998,14.269100,14.269100, 7.624290, 3.435380, 2.451550}  
	'84Wv'[][6][0]={193.815002,73.404900,70.393204,59.860802,17.981001,16.701401,14.308500,12.124900,11.626500,18.690201,15.980400,13.238800, 9.392960, 8.889700, 3.292680, 3.180350, 3.209350, 2.360360, 1.846180, 0.589642, 0.589642, 0.315058, 0.141960, 0.101305}  
	'84Wv'[][7][0]={131.669998,33.878601,32.488602,27.627600, 8.298800, 7.708200, 6.603800, 5.596000, 5.366000, 3.981200, 3.404000, 2.820000, 2.000800, 1.893600, 0.701375, 0.677447, 0.683625, 0.502781, 0.393257, 0.125600, 0.125600, 0.067111, 0.030239, 0.021579}  
	'84Wv'[][8][0]={106.155998,22.021000,21.117500,17.957899, 5.394190, 5.010300, 4.292450, 3.637380, 3.487880, 1.682040, 1.438180, 1.191440, 0.845329, 0.800038, 0.296328, 0.286219, 0.288829, 0.212423, 0.166149, 0.053066, 0.053066, 0.028354, 0.012776, 0.009117}  
	'84Wv'[][9][0]={95.368698,17.773001,17.043800,14.493700, 4.353630, 4.043790, 3.464420, 2.935710, 2.815050, 1.095690, 0.936832, 0.776107, 0.550650, 0.521147, 0.193029, 0.186444, 0.188144, 0.138373, 0.108230, 0.034567, 0.034567, 0.018470, 0.008322, 0.005939}  
	'84Wv'[][10][0]={ 0.000000,16.956200,16.260500,13.827600, 4.153550, 3.857950, 3.305200, 2.800800, 2.685680, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'84Wv'[][0][1]={ 0.000000,266.872986,160.466995,150.406006,59.795399,35.014702,34.769100, 3.099300, 2.097720,15.684800, 8.827960, 8.707450, 0.834614, 0.564271, 0.005490, 0.006258, 3.597580, 1.841240, 1.770560, 0.125401, 0.083185, 0.542585, 0.191404, 0.072355}  
	'84Wv'[][1][1]={ 0.000000,2848.689941,3658.000000,4705.509766,690.732971,670.142029,905.965027,214.751007,214.449005,183.453003,163.770004,218.373001,52.368801,52.201801, 1.596230, 1.873390,41.554100,33.319199,43.141998, 7.424110, 7.246290, 5.907120, 3.128500, 1.556680}  
	'84Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,5598.089844,7840.279785,14199.099609,9521.849609,11856.200195,1620.000000,1962.599976,3379.199951,1930.890015,2397.889893,233.664993,283.921997,370.382996,397.509003,658.956970,260.130005,315.867004,51.319302,35.564701,22.373301}  
	'84Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,227992.000000,319487.000000,10283.500000,12855.400391,29970.000000,33889.898438,47040.000000,15881.799805,19864.800781,2536.760010,2802.800049,6033.040039,4433.509766,6001.970215,356.645996,253.442993,205.542999}  
	'84Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,40372.101563,32902.601563,142041.000000,198118.000000,306972.000000,452387.000000,580929.000000,13722.799805,11776.900391,35510.199219,31103.000000,45624.398438,2053.419922,1136.239990,1246.630005}  
	'84Wv'[][5][1]={34.220798, 6.328120, 1.861500, 1.771590,47.148300,32.478001,51.932499,10.036100, 9.146490, 0.207704, 0.085503, 0.088004, 0.010863, 0.007494, 0.005607, 0.007690, 3.846130, 4.656310,10.319000,60.444698,68.074097,68.613602,204.102997,294.815002}  
	'84Wv'[][6][1]={276.376007,326.251007,233.860992,386.574005,1534.449951,2068.590088,4640.200195,3448.909912,4746.339844,383.014008,556.333984,1331.040039,1641.410034,2406.560059,11417.500000,16142.799805,2268.729980,4009.550049,13909.500000,51791.199219,80080.898438,10094.200195,22289.699219,26750.699219}  
	'84Wv'[][7][1]={759.478027,1775.420044,2139.080078,4250.649902,6301.299805,10257.799805,26946.099609,40089.500000,60081.300781,6601.270020,10723.900391,33340.199219,77060.203125,122601.000000,1004740.000000,1399410.000000,22722.300781,22531.400391,111364.000000,671769.000000,830642.000000,41401.601563,1829070.000000,1685100.000000}  
	'84Wv'[][8][1]={1318.859985,4091.750000,6818.000000,14882.299805,12359.099609,20659.000000,61510.300781,136317.000000,210905.000000,22815.599609,28273.199219,117201.000000,216239.000000,353810.000000,1346150.000000,1789340.000000,50754.199219,105179.000000,296457.000000,21656200.000000,31194100.000000,322850.000000,15444500.000000,14813700.000000}  
	'84Wv'[][9][1]={1725.670044,6004.200195,11823.700195,27186.199219,16543.800781,27085.400391,87958.000000,242564.000000,381530.000000,35706.000000,33159.000000,178629.000000,163055.000000,272669.000000,148291.000000,204765.000000,55935.398438,468122.000000,870142.000000,2575330.000000,4331100.000000,2148360.000000,30499800.000000,35154400.000000}  
	'84Wv'[][10][1]={ 0.000000,6452.109863,13289.200195,30899.599609,17596.099609,32381.400391,102044.000000,1774240.000000,2765610.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(24,11,2) '85Wv'  
	'85Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'85Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'85Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'85Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'85Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'85Wv'[][5][0]={441.992004,372.904999,357.806000,302.994995,92.027100,85.440102,73.033302,62.005901,59.405102,22.212700,402.626007,336.278992,242.302002,216.029007,89.557198,86.604103,84.349998,62.938400,49.272099,18.901699,17.114700, 8.788230, 4.103980, 2.837690}  
	'85Wv'[][6][0]={199.279007,75.804298,72.734901,61.592899,18.707300,17.368299,14.846300,12.604600,12.075900, 4.515410,16.637699,13.896000,10.012600, 8.926970, 3.700770, 3.578740, 3.485590, 2.600800, 2.036070, 0.781073, 0.707229, 0.363155, 0.169589, 0.117262}  
	'85Wv'[][7][0]={135.382996,34.986000,33.569401,28.427000, 8.634000, 8.016000, 6.852000, 5.817400, 5.573400, 2.084000, 3.544000, 2.960000, 2.132800, 1.901540, 0.788303, 0.762309, 0.742467, 0.553998, 0.433704, 0.166377, 0.150647, 0.077356, 0.036124, 0.024978}  
	'85Wv'[][8][0]={109.149002,22.740801,21.820000,18.477501, 5.612070, 5.210370, 4.453780, 3.781290, 3.622690, 1.354590, 1.497320, 1.250590, 0.901099, 0.803392, 0.333054, 0.322072, 0.313689, 0.234062, 0.183238, 0.070294, 0.063648, 0.032683, 0.015262, 0.010553}  
	'85Wv'[][9][0]={98.057503,18.354000,17.610800,14.913100, 4.529480, 4.205270, 3.594620, 3.051860, 2.923860, 1.093290, 0.975362, 0.814637, 0.586979, 0.523332, 0.216953, 0.209799, 0.204338, 0.152468, 0.119362, 0.045789, 0.041460, 0.021289, 0.009942, 0.006874}  
	'85Wv'[][10][0]={ 0.000000,17.510500,16.801500,14.227700, 4.321320, 4.012010, 3.429430, 2.911610, 2.789490, 1.043040, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'85Wv'[][0][1]={ 0.000000,276.584991,172.179001,159.925995,62.195499,37.538898,36.970200, 3.399540, 2.291230,16.388901, 9.509230, 9.308280, 0.923649, 0.621270, 0.006375, 0.007248, 3.831460, 2.033090, 1.945420, 0.147015, 0.097448, 0.619182, 0.239918, 0.139622}  
	'85Wv'[][1][1]={ 0.000000,2912.149902,3860.639893,4949.450195,711.726013,705.635986,951.974976,232.615005,231.772003,190.113007,173.291000,230.684006,57.113400,56.660099, 1.831080, 2.145760,43.928398,36.174801,46.873299, 8.597400, 8.403320, 6.722060, 3.897940, 3.009800}  
	'85Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,5696.379883,8058.359863,14722.299805,10169.799805,12651.299805,1664.520020,2035.140015,3526.370117,2069.050049,2550.729980,263.773987,320.238007,388.764008,423.726013,707.781006,296.192993,360.462006,58.130901,43.747501,43.043999}  
	'85Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,245535.000000,335992.000000,10423.299805,12990.900391,30878.000000,35504.500000,48721.699219,17566.900391,21964.800781,2640.739990,2930.540039,6413.439941,4941.330078,6706.189941,401.326996,306.356995,391.753998}  
	'85Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,31972.699219,144277.000000,199756.000000,312525.000000,485917.000000,624340.000000,14159.299805,12088.500000,37545.800781,33948.000000,50046.800781,2302.449951,1357.959961,2370.469971}  
	'85Wv'[][5][1]={33.447800, 6.141430, 1.834720, 1.720840,44.691299,31.198099,49.168400, 9.422390, 8.460730,278.480988, 0.083510, 0.081300, 0.008757, 0.008164, 0.003499, 0.004750, 3.402370, 3.978400, 8.318410,27.701799,41.876202,59.530701,184.360001,433.118011}  
	'85Wv'[][6][1]={267.846008,313.562012,227.643005,373.738007,1457.780029,1973.780029,4418.109863,3247.659912,4449.709961,5473.950195,532.281006,1240.099976,1450.810059,2526.780029,8310.040039,11686.700195,2059.040039,3629.360107,12550.900391,44771.898438,74827.898438,9449.209961,18016.699219,39754.800781}  
	'85Wv'[][7][1]={734.164978,1706.160034,2070.030029,4108.200195,5995.040039,9784.150391,25790.400391,37907.199219,56726.898438,17455.599609,10250.099609,31601.599609,71079.703125,124632.000000,839269.000000,1168260.000000,21035.599609,21085.699219,105897.000000,226887.000000,402869.000000,41729.898438,1456160.000000,2284650.000000}  
	'85Wv'[][8][1]={1273.400024,3932.879883,6580.410156,14386.799805,11764.099609,19706.199219,59101.800781,129372.000000,200026.000000,29099.900391,27125.599609,112773.000000,211478.000000,362389.000000,1534910.000000,2054850.000000,48738.199219,88093.500000,270470.000000,12036500.000000,22061400.000000,253141.000000,14650200.000000,23007800.000000}  
	'85Wv'[][9][1]={1664.619995,5771.069824,11404.299805,26292.599609,15779.799805,25816.900391,84776.000000,231362.000000,362109.000000,35251.898438,32082.900391,173837.000000,175527.000000,312909.000000,132977.000000,183563.000000,55508.898438,389902.000000,729714.000000,2545710.000000,4196650.000000,1605020.000000,28570300.000000,52331800.000000}  
	'85Wv'[][10][1]={ 0.000000,6200.069824,12789.500000,29845.099609,16738.900391,30766.199219,97927.796875,1661650.000000,2547310.000000,36664.199219, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(24,11,2) '86Wv'  
	'86Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'86Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'86Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'86Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'86Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'86Wv'[][5][0]={454.338989,384.756989,369.582001,311.647003,95.544502,88.658997,75.420898,64.410500,61.658401,23.385201,422.165985,349.002991,257.480011,244.029007,99.806999,96.606300,91.263702,68.969498,53.993900,22.126801,20.110901, 9.970060, 4.804520, 3.238220}  
	'86Wv'[][6][0]={204.845993,78.213699,75.128700,63.351799,19.422300,18.022600,15.331600,13.093400,12.533900, 4.753750,17.445101,14.421800,10.639800,10.084000, 4.124320, 3.992060, 3.771290, 2.850020, 2.231190, 0.914342, 0.831039, 0.411992, 0.198537, 0.133813}  
	'86Wv'[][7][0]={139.164001,36.098000,34.674198,29.238800, 8.964000, 8.318000, 7.076000, 6.043000, 5.784800, 2.194000, 3.716000, 3.072000, 2.266400, 2.148000, 0.878523, 0.850350, 0.803324, 0.607085, 0.475266, 0.194765, 0.177020, 0.087759, 0.042290, 0.028503}  
	'86Wv'[][8][0]={112.197998,23.463600,22.538099,19.005100, 5.826570, 5.406670, 4.599380, 3.927930, 3.760100, 1.426090, 1.569990, 1.297910, 0.957544, 0.907521, 0.371172, 0.359269, 0.339401, 0.256491, 0.200798, 0.082287, 0.074790, 0.037078, 0.017867, 0.012043}  
	'86Wv'[][9][0]={100.796997,18.937401,18.190399,15.339000, 4.702600, 4.363700, 3.712140, 3.170210, 3.034760, 1.150990, 1.022700, 0.845461, 0.623747, 0.591162, 0.241783, 0.234029, 0.221087, 0.167079, 0.130800, 0.053602, 0.048719, 0.024153, 0.011639, 0.007845}  
	'86Wv'[][10][0]={ 0.000000,18.066999,17.354401,14.634000, 4.486480, 4.163160, 3.541540, 3.024520, 2.895290, 1.098100, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'86Wv'[][0][1]={ 0.000000,286.324005,184.544006,169.612000,64.617897,40.206799,39.241699, 3.724810, 2.499890,17.122499,10.234500, 9.937260, 1.020500, 0.684727, 0.007387, 0.008377, 4.073900, 2.236590, 2.128710, 0.170608, 0.112920, 0.697725, 0.290860, 0.230380}  
	'86Wv'[][1][1]={ 0.000000,2972.899902,4069.379883,5201.729980,732.538025,741.914001,998.335022,251.647003,250.186996,196.949997,183.233002,243.324997,62.188400,61.786900, 2.094590, 2.450780,46.364899,39.163898,50.774101, 9.867090, 9.653800, 7.551330, 4.692200, 4.948950}  
	'86Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,5786.850098,8263.900391,15222.500000,10847.900391,13483.700195,1709.780029,2109.270020,3672.860107,2213.629883,2747.370117,296.885010,360.115997,407.378998,450.546997,758.426025,334.364014,407.838989,64.988098,51.961399,70.249001}  
	'86Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,359265.000000,10565.500000,13117.000000,31733.099609,37139.500000,51662.199219,19373.000000,24213.699219,2744.469971,3056.469971,6803.629883,5458.490234,7431.879883,445.700989,357.584015,633.439026}  
	'86Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,30837.300781,146492.000000,201149.000000,315464.000000,520579.000000,669276.000000,14580.500000,12372.700195,39616.199219,36754.000000,54478.699219,2547.709961,1567.239990,3824.139893}  
	'86Wv'[][5][1]={32.708199, 5.971150, 1.809360, 1.672480,42.535702,30.153700,47.177700, 8.866610, 7.842880,259.227997, 0.079913, 0.077895, 0.007512, 0.005323, 0.002186, 0.002965, 3.037170, 3.319040, 6.972340,18.700701,27.105301,52.451599,165.203995,551.077026}  
	'86Wv'[][6][1]={259.657990,301.750000,221.735992,361.447998,1389.390015,1891.119995,4247.640137,3063.100098,4177.109863,5127.470215,501.214996,1185.839966,1292.479980,1855.349976,6192.970215,8667.490234,1877.469971,3301.199951,11398.000000,40889.300781,68483.898438,8863.209961,15162.700195,52583.000000}  
	'86Wv'[][7][1]={709.806030,1641.260010,2004.339966,3972.320068,5717.680176,9358.379883,24860.699219,35888.898438,53618.800781,16426.500000,9699.650391,30463.000000,65799.796875,104140.000000,704436.000000,979375.000000,19520.699219,19788.699219,100880.000000,129309.000000,222145.000000,41573.101563,1169020.000000,2657890.000000}  
	'86Wv'[][8][1]={1230.239990,3782.340088,6352.870117,13912.099609,11219.500000,18830.800781,57111.898438,122888.000000,189896.000000,27496.599609,25842.400391,109737.000000,206197.000000,337458.000000,1681180.000000,2265210.000000,46664.300781,75461.703125,252484.000000,7570710.000000,13698600.000000,212389.000000,13539800.000000,30586500.000000}  
	'86Wv'[][9][1]={1608.560059,5549.049805,10987.900391,25430.199219,15059.700195,24668.500000,81949.203125,219814.000000,344056.000000,33384.000000,30759.300781,170845.000000,184907.000000,316494.000000,119903.000000,165191.000000,54876.101563,327917.000000,626282.000000,2955380.000000,4497880.000000,1263300.000000,26944500.000000,67924304.000000}  
	'86Wv'[][10][1]={ 0.000000,5963.910156,12345.500000,28817.900391,15867.400391,29424.500000,94896.703125,1555680.000000,2367020.000000,34959.800781, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(24,11,2) '87Wv'  
	'87Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'87Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'87Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'87Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 2.929150, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'87Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'87Wv'[][5][0]={466.957001,397.334991,381.720001,320.425995,99.168503,92.240303,78.085602,66.855598,63.945702,24.578899,445.342010,368.088989,274.157990,262.207001,112.012001,108.546997,99.990898,76.803001,60.419998,27.055799,24.790501,12.664000, 6.891430, 4.822540}  
	'87Wv'[][6][0]={210.535004,80.770401,77.596100,65.136299,20.159000,18.750601,15.873300,13.590400,12.998900, 4.996420,18.402800,15.210500,11.329000,10.835100, 4.628660, 4.485470, 4.131920, 3.173730, 2.496730, 1.118030, 1.024420, 0.523314, 0.284774, 0.199281}  
	'87Wv'[][7][0]={143.029007,37.278000,35.813000,30.062401, 9.304000, 8.654000, 7.326000, 6.272400, 5.999400, 2.306000, 3.920000, 3.240000, 2.413200, 2.308000, 0.985954, 0.955452, 0.880142, 0.676037, 0.531830, 0.238151, 0.218212, 0.111471, 0.060660, 0.042449}  
	'87Wv'[][8][0]={115.314003,24.230600,23.278299,19.540501, 6.047570, 5.625070, 4.761880, 4.077040, 3.899590, 1.498890, 1.656180, 1.368890, 1.019570, 0.975120, 0.416561, 0.403674, 0.371856, 0.285623, 0.224696, 0.100618, 0.092193, 0.047096, 0.025628, 0.017934}  
	'87Wv'[][9][0]={103.596001,19.556400,18.787800,15.771000, 4.880970, 4.539970, 3.843290, 3.290560, 3.147340, 1.209750, 1.078840, 0.891697, 0.664149, 0.635196, 0.271349, 0.262955, 0.242228, 0.186056, 0.146368, 0.065543, 0.060055, 0.030679, 0.016694, 0.011683}  
	'87Wv'[][10][0]={ 0.000000,18.657600,17.924400,15.046200, 4.656650, 4.331330, 3.666660, 3.139340, 3.002700, 1.154150, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'87Wv'[][0][1]={ 0.000000,296.321014,197.660995,179.735001,67.079697,43.024101,41.633301, 4.073760, 2.722580,17.863400,11.004300,10.601400, 1.125710, 0.753192, 0.008525, 0.009641, 4.319730, 2.458260, 2.327410, 0.197201, 0.130039, 0.786665, 0.361461, 0.309050}  
	'87Wv'[][1][1]={ 0.000000,3034.510010,4284.529785,5460.529785,753.291016,779.583008,1046.609985,271.747009,269.585999,203.804993,193.559998,256.579987,67.601997,67.109100, 2.387880, 2.789540,48.840698,42.317600,54.900501,11.259000,11.016800, 8.523360, 5.836400, 6.738060}  
	'87Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,5871.180176,8468.990234,15742.700195,11546.299805,14340.200195,1753.939941,2184.040039,3827.439941,2364.320068,2937.000000,333.178986,403.792999,426.179993,477.885986,810.926025,374.992004,458.343994,73.145302,64.022400,95.792702}  
	'87Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,10689.799805,13225.400391,32666.900391,38783.398438,54118.699219,21303.699219,26616.800781,2847.600098,3179.370117,7203.270020,5991.899902,8182.580078,498.471985,433.053009,856.510986}  
	'87Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,29552.300781,148676.000000,202301.000000,319031.000000,556148.000000,715483.000000,14988.200195,12626.599609,41725.601563,39558.000000,58945.601563,2841.090088,1879.619995,5166.660156}  
	'87Wv'[][5][1]={31.994400, 5.795190, 1.784690, 1.626790,40.235100,28.927799,44.901402, 8.356860, 7.283220,241.903000, 0.070723, 0.070961, 0.006375, 0.004454, 0.001353, 0.001831, 2.512130, 2.737850, 5.501170,10.760300,14.481800,37.413300,105.093002,348.738007}  
	'87Wv'[][6][1]={251.755997,289.815002,216.020996,349.417999,1324.109985,1801.750000,4058.739990,2892.120117,3925.110107,4810.640137,465.378998,1090.479980,1142.469971,1579.800049,4465.520020,6212.439941,1672.810059,2921.139893,9947.129883,34290.300781,57083.000000,7173.569824,9165.910156,41605.101563}  
	'87Wv'[][7][1]={686.283997,1576.209961,1940.709961,3842.149902,5452.160156,8913.320313,23851.699219,33985.300781,50692.101563,15469.799805,9094.540039,28607.000000,60534.300781,94146.703125,575198.000000,797996.000000,17778.000000,18260.500000,93407.398438,76739.500000,127450.000000,38451.898438,527249.000000,1091980.000000}  
	'87Wv'[][8][1]={1188.500000,3633.449951,6133.700195,13457.400391,10698.200195,17933.800781,54968.699219,116673.000000,180248.000000,25993.199219,24473.500000,104814.000000,200026.000000,324777.000000,1800090.000000,2448280.000000,43958.199219,62075.500000,232022.000000,3658160.000000,6339320.000000,127379.000000,7122330.000000,18438100.000000}  
	'87Wv'[][9][1]={1554.369995,5330.500000,10599.900391,24601.599609,14343.700195,23499.699219,79106.703125,208211.000000,327725.000000,31721.199219,29371.000000,165224.000000,191195.000000,324697.000000,109305.000000,148537.000000,55705.199219,251624.000000,531928.000000,16185300.000000,18006100.000000,560245.000000,30174100.000000,72377296.000000}  
	'87Wv'[][10][1]={ 0.000000,5726.509766,11879.299805,27843.099609,15202.400391,24925.000000,91997.101563,1432290.000000,2252030.000000,33730.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(24,11,2) '88Wv'  
	'88Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'88Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'88Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'88Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'88Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'88Wv'[][5][0]={479.815002,410.075989,394.036987,329.234009,102.792000,95.704399,80.831200,69.247398,66.188301,25.759899,22.545300,399.489990,288.972992,273.885010,135.828995,135.828995,115.607002,91.067902,69.436996,30.537701,30.537701,19.767700, 8.543300, 8.543300}  
	'88Wv'[][6][0]={216.332993,83.360397,80.099998,66.926903,20.895700,19.454800,16.431400,14.076600,13.454800, 5.236490, 4.583010,16.508101,11.941200,11.317700, 5.612870, 5.612870, 4.777230, 3.763190, 2.869340, 1.261910, 1.261910, 0.816861, 0.353034, 0.353034}  
	'88Wv'[][7][0]={146.968002,38.473400,36.968601,30.888800, 9.644000, 8.979000, 7.583600, 6.496800, 6.209800, 2.416800, 2.115200, 3.516400, 2.543600, 2.410800, 1.195600, 1.195600, 1.017600, 0.801600, 0.611200, 0.268800, 0.268800, 0.174000, 0.075200, 0.075200}  
	'88Wv'[][8][0]={118.488998,25.007601,24.029499,20.077600, 6.268570, 5.836320, 4.929320, 4.222900, 4.036350, 1.570910, 1.374870, 1.485660, 1.074660, 1.018550, 0.505136, 0.505136, 0.429932, 0.338673, 0.258229, 0.113567, 0.113567, 0.073514, 0.031772, 0.031772}  
	'88Wv'[][9][0]={106.448997,20.183500,19.394100,16.204599, 5.059330, 4.710470, 3.978430, 3.408280, 3.257720, 1.267880, 1.109650, 0.967766, 0.700037, 0.663489, 0.329047, 0.329047, 0.280059, 0.220612, 0.168211, 0.073978, 0.073978, 0.047887, 0.020696, 0.020696}  
	'88Wv'[][10][0]={ 0.000000,19.255899,18.502800,15.459800, 4.826820, 4.493990, 3.795590, 3.251650, 3.108000, 1.209610, 1.058660, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'88Wv'[][0][1]={ 0.000000,306.343994,211.453003,190.220993,69.591904,45.979599,44.117100, 4.448300, 2.961440,18.620199,11.834600,11.314400, 1.240390, 0.826027, 0.009833, 0.011098, 4.580840, 2.694160, 2.536450, 0.226391, 0.149073, 0.886056, 0.436373, 0.385011}  
	'88Wv'[][1][1]={ 0.000000,3094.580078,4504.410156,5724.520020,773.903015,817.757996,1096.229980,292.898987,289.993011,210.705994,204.557999,270.821014,73.349701,72.643402, 2.724800, 3.181800,51.426800,45.647099,59.241199,12.772500,12.512200, 9.584400, 7.012170, 8.427860}  
	'88Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,5947.180176,8657.509766,16268.599609,12257.700195,15213.799805,1796.989990,2264.340088,3999.070068,2518.399902,3123.739990,376.080994,456.725006,445.765991,506.502014,866.091980,418.153992,512.666016,81.934196,75.971100,119.413002}  
	'88Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,10796.799805,13339.900391,33804.199219,40360.000000,56255.699219,23819.800781,29953.400391,2958.889893,3306.689941,7624.390137,6537.439941,8971.580078,555.458984,505.078003,1059.339966}  
	'88Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,150626.000000,203749.000000,323509.000000,611913.000000,797489.000000,15452.599609,12853.599609,43971.800781,42370.300781,63542.800781,3162.229980,2168.340088,6383.580078}  
	'88Wv'[][5][1]={31.310101, 5.630810, 1.762410, 1.584670,38.397400,27.954901,42.719398, 7.889700, 6.813880,226.921997,305.868011, 0.059388, 0.005655, 0.004171, 0.000558, 0.000652, 1.909090, 1.919330, 3.861000, 8.060640, 7.592920,17.509100,82.329399,130.729996}  
	'88Wv'[][6][1]={244.164001,278.546997,210.690002,338.502991,1264.319946,1725.489990,3877.760010,2745.010010,3706.679932,4529.740234,7298.839844,935.521973,1039.390015,1465.790039,2402.489990,2963.929932,1359.270020,2339.100098,8254.290039,31118.599609,45706.800781,4264.080078,7616.540039,25809.300781}  
	'88Wv'[][7][1]={663.638000,1514.609985,1880.819946,3719.790039,5205.850098,8520.219727,22881.199219,32304.500000,48087.601562,14609.599609,19680.300781,25656.300781,56579.800781,89226.796875,393223.000000,509080.000000,15092.700195,15853.700195,83413.601563,70931.601563,114508.000000,28889.400391,335531.000000,308458.000000}  
	'88Wv'[][8][1]={1147.819946,3491.290039,5925.330078,13024.599609,10210.700195,17128.500000,52901.800781,111104.000000,171447.000000,24648.900391,26306.800781,96879.203125,194991.000000,319067.000000,1755930.000000,2362530.000000,39370.000000,47174.800781,208302.000000,2077290.000000,2777720.000000,65586.398438,4094730.000000,4742940.000000}  
	'88Wv'[][9][1]={1499.780029,5121.870117,10222.000000,23807.599609,13711.099609,22414.099609,76370.601563,198679.000000,311221.000000,30129.300781,27586.099609,155201.000000,198087.000000,341851.000000,120076.000000,161797.000000,50218.101563,179422.000000,416361.000000,27086300.000000,44059300.000000,260056.000000,19157000.000000,31345800.000000}  
	'88Wv'[][10][1]={ 0.000000,5501.390137,11428.799805,26958.500000,14467.400391,23930.199219,82590.898438,177188.000000,214833.000000,32176.099609,29280.099609, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(24,11,2) '89Wv'  
	'89Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'89Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'89Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'89Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'89Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'89Wv'[][5][0]={492.897003,422.937012,406.803986,338.328003,106.629997,99.253700,83.329597,71.843803,68.620697,27.051800,23.022800,404.442993,306.695007,289.471985,138.121002,134.087997,118.722000,93.690598,74.178802,37.779598,34.963402,18.387899,11.444900, 8.362470}  
	'89Wv'[][6][0]={222.231003,85.974800,82.695297,68.775497,21.675699,20.176300,16.939301,14.604400,13.949200, 5.499090, 4.680080,16.712799,12.673500,11.961800, 5.707580, 5.540890, 4.905960, 3.871570, 3.065280, 1.561160, 1.444790, 0.759842, 0.472936, 0.345562}  
	'89Wv'[][7][0]={150.975006,39.680000,38.166401,31.742001,10.004000, 9.312000, 7.818000, 6.740400, 6.438000, 2.538000, 2.160000, 3.560000, 2.699600, 2.548000, 1.215770, 1.180270, 1.045020, 0.824686, 0.652938, 0.332544, 0.307756, 0.161854, 0.100740, 0.073608}  
	'89Wv'[][8][0]={121.719002,25.791901,24.808001,20.632200, 6.502570, 6.052770, 5.081670, 4.381240, 4.184680, 1.649690, 1.403990, 1.504080, 1.140570, 1.076520, 0.513660, 0.498658, 0.441517, 0.348426, 0.275863, 0.140499, 0.130025, 0.068383, 0.042562, 0.031099}  
	'89Wv'[][9][0]={109.350998,20.816500,20.022499,16.652201, 5.248190, 4.885160, 4.101400, 3.536080, 3.377440, 1.331460, 1.133160, 0.979766, 0.742971, 0.701248, 0.334600, 0.324828, 0.287606, 0.226966, 0.179698, 0.091521, 0.084699, 0.044545, 0.027725, 0.020258}  
	'89Wv'[][10][0]={ 0.000000,19.859800,19.102301,15.886900, 5.007000, 4.660660, 3.912910, 3.373570, 3.222220, 1.270270, 1.081080, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'89Wv'[][0][1]={ 0.000000,316.476990,226.113998,201.240997,72.138000,49.104198,46.698299, 4.854330, 3.217420,19.395500,12.686300,12.033000, 1.364140, 0.904943, 0.011268, 0.012679, 4.848240, 2.948500, 2.761660, 0.259258, 0.170383, 0.987140, 0.515478, 0.456029}  
	'89Wv'[][1][1]={ 0.000000,3151.500000,4733.350098,6000.459961,794.611023,856.942017,1146.290039,315.625000,311.809998,217.705002,215.212006,284.424988,79.507599,78.592499, 3.078500, 3.584710,54.013199,49.086102,63.789101,14.438600,14.143500,10.650400, 8.193250, 9.972080}  
	'89Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,6019.700195,8836.009766,16771.599609,13025.099609,16155.400391,1840.069946,2330.639893,4142.140137,2682.739990,3324.620117,416.329987,503.618011,464.316010,534.169983,922.138977,464.838989,570.172974,90.567200,87.414902,140.421005}  
	'89Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,10899.599609,13359.799805,34493.101563,42052.000000,58619.398438,25565.699219,31914.000000,3051.770020,3416.870117,8038.069824,7122.890137,9780.200195,609.544006,571.221985,1234.910034}  
	'89Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,152799.000000,204244.000000,326985.000000,630210.000000,811952.000000,15752.599609,13048.900391,46089.500000,45260.398438,68143.500000,3449.399902,2425.959961,7425.080078}  
	'89Wv'[][5][1]={30.656700, 5.482010, 1.740030, 1.542550,36.561501,26.887300,41.137402, 7.435380, 6.323290,211.895996,305.483002, 0.061493, 0.004857, 0.003751, 0.000588, 0.000799, 1.906760, 1.877810, 3.454110, 4.385000, 5.168550,22.465000,52.804699,161.046005}  
	'89Wv'[][6][1]={236.888000,267.834015,205.477997,327.727997,1205.209961,1653.849976,3736.699951,2592.810059,3482.080078,4251.279785,7156.790039,947.456970,925.638977,1309.660034,2465.199951,3393.060059,1345.010010,2321.250000,7736.160156,24185.000000,39766.300781,5156.589844,5783.990234,30990.599609}  
	'89Wv'[][7][1]={641.888977,1456.670044,1822.599976,3600.139893,4964.370117,8148.220215,22090.300781,30611.099609,45468.398437,13759.599609,19147.000000,25668.300781,52212.000000,82803.703125,390488.000000,539409.000000,14846.000000,15658.400391,80580.101563,72250.296875,124322.000000,33851.101563,182337.000000,365110.000000}  
	'89Wv'[][8][1]={1109.160034,3357.550049,5724.740234,12607.200195,9734.849609,16358.599609,51169.101563,105577.000000,162752.000000,23289.000000,25651.099609,96631.898438,188150.000000,309027.000000,1801450.000000,2470860.000000,39057.300781,45475.800781,203540.000000,1012150.000000,1605790.000000,80294.398438,2409590.000000,4785400.000000}  
	'89Wv'[][9][1]={1449.540039,4923.819824,9864.780273,23046.599609,13080.299805,21413.099609,74077.398438,188527.000000,295088.000000,28643.300781,27067.000000,155587.000000,202630.000000,346923.000000,137988.000000,183959.000000,50900.000000,160936.000000,375717.000000,6806870.000000,11435300.000000,275116.000000,9638920.000000,23329600.000000}  
	'89Wv'[][10][1]={ 0.000000,5289.560059,11008.400391,26069.300781,13720.700195,22850.300781,79779.898438,195329.000000,338237.000000,29793.400391,29640.300781, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(24,11,2) '90Wv'  
	'90Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'90Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'90Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'90Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'90Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'90Wv'[][5][0]={506.265991,436.411987,419.807007,347.480011,110.473000,102.971001,86.252296,74.414703,71.029503,28.341499,24.903000,439.571014,324.509003,307.377014,156.505997,152.324997,131.876007,104.246002,82.615501,42.852798,39.944500,27.038601,22.267099,19.540501}  
	'90Wv'[][6][0]={228.257996,88.713898,85.338600,70.635803,22.457001,20.932100,17.533400,15.127100,14.438900, 5.761260, 5.062290,18.164400,13.409700,12.701700, 6.467280, 6.294520, 5.449490, 4.307770, 3.413920, 1.770800, 1.650620, 1.117320, 0.920142, 0.807472}  
	'90Wv'[][7][0]={155.070007,40.944199,39.386398,32.600601,10.364600, 9.660800, 8.092200, 6.981600, 6.664000, 2.659000, 2.336400, 3.869200, 2.856400, 2.705600, 1.377600, 1.340800, 1.160800, 0.917600, 0.727200, 0.377200, 0.351600, 0.238000, 0.196000, 0.172000}  
	'90Wv'[][8][0]={125.021004,26.613600,25.601000,21.190300, 6.736960, 6.279490, 5.259900, 4.538020, 4.331580, 1.728340, 1.518650, 1.634720, 1.206820, 1.143100, 0.582030, 0.566482, 0.490433, 0.387682, 0.307239, 0.159365, 0.148550, 0.100554, 0.082809, 0.072669}  
	'90Wv'[][9][0]={112.317001,21.479700,20.662500,17.102600, 5.437370, 5.068150, 4.245240, 3.662610, 3.496000, 1.394940, 1.225700, 1.064860, 0.786124, 0.744622, 0.379136, 0.369008, 0.319470, 0.252537, 0.200136, 0.103811, 0.096766, 0.065501, 0.053942, 0.047337}  
	'90Wv'[][10][0]={ 0.000000,20.492599,19.712900,16.316601, 5.187480, 4.835230, 4.050150, 3.494290, 3.335330, 1.330830, 1.169370, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'90Wv'[][0][1]={ 0.000000,326.747986,241.548004,212.660995,74.732201,52.388401,49.401798, 5.288660, 3.490790,20.196699,13.611000,12.812000, 1.498040, 0.990161, 0.012916, 0.014497, 5.125440, 3.221470, 3.001220, 0.295376, 0.193716, 1.094750, 0.599824, 0.530632}  
	'90Wv'[][1][1]={ 0.000000,3206.739990,4967.709961,6283.759766,815.166016,897.195007,1199.050049,339.584015,334.796997,224.785004,227.001007,299.763000,86.058899,84.954399, 3.487620, 4.054660,56.692200,52.717400,68.581200,16.233200,15.903300,11.742000, 9.409070,11.533100}  
	'90Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,6084.660156,9006.379883,17318.699219,13815.900391,17127.400391,1882.170044,2411.929932,4325.419922,2854.000000,3537.860107,465.506989,562.677979,483.871002,563.078979,981.033997,513.687012,630.955017,99.263199,98.810997,161.250000}  
	'90Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,10988.599609,13423.799805,35709.000000,43763.199219,61136.699219,28162.800781,35155.699219,3157.560059,3531.899902,8479.299805,7711.879883,10614.900391,664.997009,635.234009,1410.660034}  
	'90Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,154997.000000,204403.000000,329523.000000,678549.000000,875816.000000,16144.900391,13205.299805,48400.300781,48096.101563,72772.000000,3763.639893,2668.689941,8507.929688}  
	'90Wv'[][5][1]={30.025600, 5.329420, 1.719240, 1.503240,34.909599,25.980301,39.106899, 7.044240, 5.867130,198.750000,267.613007, 0.051513, 0.004223, 0.003323, 0.000332, 0.000454, 1.593350, 1.543820, 2.729400, 3.093350, 3.417300,11.450000,14.223400,25.324900}  
	'90Wv'[][6][1]={229.867996,257.385986,200.574997,317.605988,1150.949951,1583.890015,3568.879883,2459.689941,3284.889893,4002.679932,6459.700195,808.669983,831.181030,1151.619995,1685.939941,2291.959961,1164.630005,2036.420044,6723.080078,21043.400391,34181.898438,3186.360107,2937.010010,11615.599609}  
	'90Wv'[][7][1]={620.880005,1399.469971,1767.550049,3487.479980,4740.580078,7787.529785,21193.199219,29104.199219,43138.101563,12988.799805,17602.900391,22940.099609,48406.699219,76118.000000,305011.000000,418691.000000,13204.599609,14326.299805,73879.296875,77838.101563,135001.000000,24798.400391,40275.601563,91773.796875}  
	'90Wv'[][8][1]={1071.319946,3225.709961,5533.500000,12211.099609,9292.070313,15613.900391,49261.101563,100584.000000,154990.000000,22050.800781,23771.500000,89038.296875,181424.000000,296862.000000,1679500.000000,2306520.000000,35900.101562,39397.601563,190434.000000,631898.000000,965734.000000,56315.601563,688249.000000,862096.000000}  
	'90Wv'[][9][1]={1398.479980,4730.330078,9516.230469,22325.400391,12494.099609,20437.000000,71324.703125,179252.000000,281640.000000,27266.699219,25100.900391,145700.000000,203291.000000,351033.000000,175044.000000,230359.000000,47830.000000,133588.000000,334628.000000,3774980.000000,5904870.000000,174274.000000,3604660.000000,6226570.000000}  
	'90Wv'[][10][1]={ 0.000000,5081.209961,10637.299805,25228.900391,13091.599609,21649.199219,77849.000000,217436.000000,284613.000000,27966.599609,26531.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(24,11,2) '91Wv'  
	'91Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'91Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'91Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'91Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'91Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'91Wv'[][5][0]={519.888977,449.894989,433.035004,356.705994,114.407997,106.606003,88.974503,76.981300,73.370201,29.569300,26.098900,21.460199,337.824005,321.828003,168.684998,163.367996,140.692001,106.166000,83.183601,43.933899,40.553799,20.657801,12.971800, 9.234290}  
	'91Wv'[][6][0]={234.399994,91.454803,88.027496,72.511299,23.257000,21.670900,18.086800,15.648800,14.914700, 6.010870, 5.305390, 4.362440,13.959900,13.298900, 6.970550, 6.750840, 5.813800, 4.387080, 3.437390, 1.815480, 1.675800, 0.853639, 0.536032, 0.381588}  
	'91Wv'[][7][0]={159.242004,42.209202,40.627399,33.466202,10.733800,10.001800, 8.347600, 7.222400, 6.883600, 2.774200, 2.448600, 2.013400, 2.973600, 2.832800, 1.484800, 1.438000, 1.238400, 0.934495, 0.732200, 0.386716, 0.356963, 0.181834, 0.114180, 0.081282}  
	'91Wv'[][8][0]={128.384995,27.435801,26.407700,21.752899, 6.976930, 6.501140, 5.425910, 4.694540, 4.474320, 1.803220, 1.591580, 1.308700, 1.256330, 1.196850, 0.627322, 0.607549, 0.523219, 0.394820, 0.309351, 0.163386, 0.150815, 0.076824, 0.048241, 0.034341}  
	'91Wv'[][9][0]={115.338997,22.143299,21.313499,17.556700, 5.631050, 5.247040, 4.379230, 3.788940, 3.611200, 1.455370, 1.284560, 1.056250, 0.818380, 0.779629, 0.408639, 0.395759, 0.340826, 0.257187, 0.201513, 0.106430, 0.098242, 0.050044, 0.031424, 0.022370}  
	'91Wv'[][10][0]={ 0.000000,21.125700,20.334000,16.749800, 5.372270, 5.005900, 4.177970, 3.614810, 3.445240, 1.388490, 1.225520, 1.007710, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'91Wv'[][0][1]={ 0.000000,337.117004,257.906006,224.645996,77.362198,55.859600,52.228600, 5.759610, 3.785390,21.002100,14.576100,13.620900, 1.642300, 1.081770, 0.014752, 0.016514, 5.398680, 3.500530, 3.233090, 0.330870, 0.215998, 1.131410, 0.630836, 0.545299}  
	'91Wv'[][1][1]={ 0.000000,3259.909912,5207.939941,6579.080078,835.906982,938.531006,1253.229980,365.342010,359.354004,231.889008,238.804001,315.044006,92.996300,91.704903, 3.936040, 4.567070,59.288200,56.288502,73.076202,17.903400,17.495199,12.035100, 9.712650,11.676700}  
	'91Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,6148.069824,9165.860352,17866.400391,14669.000000,18164.500000,1923.849976,2485.850098,4494.870117,3031.000000,3760.600098,518.093018,625.223999,502.306000,589.690002,1033.859985,556.263000,682.322998,100.864998,99.953102,161.000000}  
	'91Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,11070.000000,13426.299805,36691.601563,45459.699219,63706.500000,30809.900391,38389.300781,3254.179932,3624.110107,8852.530273,8182.759766,11258.500000,670.138000,630.237976,1393.060059}  
	'91Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,204357.000000,331340.000000,723687.000000,933007.000000,16468.599609,13284.500000,50242.800781,50086.101563,75960.101563,3754.409912,2609.600098,8330.910156}  
	'91Wv'[][5][1]={29.421801, 5.195370, 1.701570, 1.467020,33.352600,25.257099,37.562500, 6.706120, 5.521090,187.910004,251.955002,555.757019, 0.003935, 0.003110, 0.000254, 0.000364, 1.389260, 1.604610, 2.882040, 3.147490, 3.565150,20.066500,47.174999,148.432999}  
	'91Wv'[][6][1]={223.136002,247.796997,195.931000,308.213989,1100.020020,1523.979980,3435.590088,2344.939941,3122.330078,3793.620117,6102.919922,18990.599609,784.073975,1058.859985,1390.439941,1922.260010,1076.479980,2043.359985,6938.000000,21223.199219,35011.500000,4731.220215,5376.100098,30669.699219}  
	'91Wv'[][7][1]={600.697021,1346.479980,1716.459961,3383.149902,4531.100098,7469.330078,20462.500000,27821.300781,41225.800781,12330.099609,16669.300781,68248.203125,46293.398437,71959.898438,268268.000000,372285.000000,12352.900391,14154.700195,75841.000000,79335.703125,137911.000000,31794.900391,160319.000000,333496.000000}  
	'91Wv'[][8][1]={1035.430054,3103.389893,5356.149902,11847.099609,8875.429688,14942.200195,47677.199219,96391.000000,148619.000000,20968.800781,22509.699219,119065.000000,177026.000000,288209.000000,1602620.000000,2212280.000000,33862.800781,39618.500000,194803.000000,639017.000000,1001620.000000,81578.000000,2133790.000000,4265280.000000}  
	'91Wv'[][9][1]={1351.729980,4549.069824,9198.299805,21659.800781,11910.400391,19542.099609,69167.101563,172092.000000,270617.000000,25971.400391,23724.199219,148119.000000,205539.000000,349292.000000,154226.000000,202474.000000,45490.101563,134923.000000,341960.000000,3930550.000000,6357600.000000,277155.000000,8486700.000000,21050700.000000}  
	'91Wv'[][10][1]={ 0.000000,4889.180176,10276.599609,24503.099609,12559.299805,20611.699219,75423.296875,199770.000000,243040.000000,26566.699219,26403.699219,170990.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(24,11,2) '92Wv'  
	'92Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'92Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'92Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'92Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'92Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'92Wv'[][5][0]={533.762024,463.811005,446.548004,365.941010,118.268997,110.471001,91.737198,79.462700,75.712898,30.714100,27.128500,22.274500,354.638000,335.234009,177.819000,173.093002,147.098999,117.834000,88.659401,47.715199,43.761700,32.128300,19.222401,14.678100}  
	'92Wv'[][6][0]={240.654999,94.283699,90.774498,74.388603,24.041700,22.456600,18.648399,16.153200,15.391000, 6.243570, 5.514690, 4.527980,14.654700,13.852800, 7.347990, 7.152700, 6.078570, 4.869240, 3.663670, 1.971730, 1.808360, 1.327630, 0.794327, 0.606543}  
	'92Wv'[][7][0]={163.492004,43.514801,41.895199,34.332600,11.096000,10.364400, 8.606800, 7.455200, 7.103400, 2.881600, 2.545200, 2.089800, 3.121600, 2.950800, 1.565200, 1.523600, 1.294800, 1.037200, 0.780400, 0.420000, 0.385200, 0.282800, 0.169200, 0.129200}  
	'92Wv'[][8][0]={131.811005,28.284500,27.231701,22.316099, 7.212360, 6.736830, 5.594390, 4.845860, 4.617190, 1.873030, 1.654370, 1.358360, 1.318860, 1.246700, 0.661290, 0.643715, 0.547047, 0.438213, 0.329716, 0.177448, 0.162745, 0.119482, 0.071486, 0.054586}  
	'92Wv'[][9][0]={118.417000,22.828300,21.978600,18.011200, 5.821070, 5.437260, 4.515210, 3.911070, 3.726510, 1.511710, 1.335240, 1.096330, 0.859111, 0.812105, 0.430767, 0.419318, 0.356349, 0.285453, 0.214778, 0.115590, 0.106013, 0.077831, 0.046566, 0.035558}  
	'92Wv'[][10][0]={ 0.000000,21.779200,20.968500,17.183500, 5.553550, 5.187380, 4.307700, 3.731330, 3.555250, 1.442240, 1.273870, 1.045940, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'92Wv'[][0][1]={ 0.000000,347.511993,275.066010,237.039001,80.025299,59.496201,55.147202, 6.259870, 4.098710,21.819700,15.596200,14.456100, 1.799390, 1.180610, 0.016799, 0.018759, 5.686140, 3.801440, 3.483440, 0.370926, 0.241214, 1.196810, 0.688192, 0.585495}  
	'92Wv'[][1][1]={ 0.000000,3312.689941,5450.259766,6878.430176,856.125000,980.760010,1308.349976,392.130005,385.029999,238.938004,250.807999,330.643005,100.412003,98.811501, 4.424580, 5.126520,61.941200,60.087601,77.905899,19.787701,19.302299,12.658000,10.429600,12.428200}  
	'92Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,6198.500000,9314.129883,18408.400391,15519.799805,19217.300781,1962.869995,2555.260010,4663.990234,3217.189941,3986.340088,573.094971,691.396973,520.421021,617.835999,1090.790039,604.218018,740.695007,105.485001,105.452003,169.843994}  
	'92Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,11122.599609,13389.099609,37632.699219,47229.101563,66153.601563,33343.699219,41594.398438,3343.239990,3722.439941,9263.059570,8715.610352,11996.000000,698.401978,653.458984,1460.209961}  
	'92Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,203494.000000,333878.000000,759709.000000,982997.000000,16722.400391,13322.099609,52299.199219,52328.699219,79632.000000,3911.919922,2669.100098,8725.379883}  
	'92Wv'[][5][1]={28.841999, 5.046700, 1.684610, 1.433840,31.993401,24.486700,36.096100, 6.428840, 5.210980,179.128998,241.628998,529.206970, 0.003539, 0.002971, 0.000220, 0.000310, 1.323220, 1.327340, 2.576040, 2.620850, 2.945540, 8.772210,21.701200,54.263100}  
	'92Wv'[][6][1]={216.662994,238.440994,191.638000,299.444000,1054.079956,1463.060059,3308.429932,2246.629883,2972.629883,3616.699951,5830.259766,18250.500000,720.359009,987.693970,1242.750000,1681.140015,1028.750000,1789.099976,6471.060059,19450.300781,32409.400391,2555.120117,3465.790039,17623.199219}  
	'92Wv'[][7][1]={581.247986,1294.839966,1667.369995,3284.610107,4338.330078,7151.399902,19758.099609,26677.900391,39420.199219,11754.900391,15898.299805,66057.500000,43531.601563,68520.500000,246723.000000,338206.000000,11836.500000,12876.500000,72662.796875,81746.101563,142581.000000,20492.099609,66133.601563,145705.000000}  
	'92Wv'[][8][1]={1000.750000,2983.780029,5184.470215,11500.200195,8489.070313,14279.700195,46138.500000,92562.398438,142481.000000,20010.599609,21466.599609,115953.000000,171140.000000,280925.000000,1552040.000000,2135760.000000,32616.000000,34906.500000,188445.000000,509537.000000,805837.000000,50161.699219,1070070.000000,1739230.000000}  
	'92Wv'[][9][1]={1306.560059,4374.049805,8887.000000,21017.800781,11394.700195,18608.199219,67105.398438,165678.000000,259586.000000,24775.599609,22644.900391,145725.000000,204808.000000,351001.000000,155875.000000,203558.000000,44416.000000,119073.000000,325468.000000,3205390.000000,5159190.000000,174645.000000,5223840.000000,11441900.000000}  
	'92Wv'[][10][1]={ 0.000000,4702.310059,9914.980469,23796.300781,11993.200195,19801.900391,72027.101563,161129.000000,218466.000000,25608.900391,25456.199219,141867.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(24,11,2) '93Wv'  
	'93Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'93Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'93Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'93Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'93Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'93Wv'[][5][0]={547.945007,478.080994,460.466003,375.398987,122.003998,114.392998,94.536201,82.078300,78.145302,31.990999,28.303101,23.167700,370.769989,350.048004,188.589005,183.772003,147.115005,128.785995,93.658203,49.669300,46.033798,22.543200,14.178500, 9.798750}  
	'93Wv'[][6][0]={247.050003,97.184402,93.603699,76.311302,24.801001,23.253901,19.217400,16.684900,15.885400, 6.503140, 5.753460, 4.709550,15.321300,14.465000, 7.793040, 7.593990, 6.079230, 5.321800, 3.870230, 2.052480, 1.902250, 0.931550, 0.585899, 0.404913}  
	'93Wv'[][7][0]={167.835999,44.853600,43.201000,35.220001,11.446400,10.732400, 8.869400, 7.700600, 7.331600, 3.001400, 2.655400, 2.173600, 3.263600, 3.081200, 1.660000, 1.617600, 1.294940, 1.133600, 0.824400, 0.437200, 0.405200, 0.198430, 0.124803, 0.086251}  
	'93Wv'[][8][0]={135.313004,29.154699,28.080500,22.892900, 7.440120, 6.976020, 5.765080, 5.005360, 4.765520, 1.950900, 1.726000, 1.412830, 1.378860, 1.301790, 0.701343, 0.683429, 0.547107, 0.478941, 0.348305, 0.184715, 0.171195, 0.083836, 0.052729, 0.036441}  
	'93Wv'[][9][0]={121.564003,23.530600,22.663700,18.476700, 6.004890, 5.630320, 4.652970, 4.039810, 3.846230, 1.574560, 1.393050, 1.140290, 0.898192, 0.847993, 0.456857, 0.445188, 0.356387, 0.311984, 0.226887, 0.120324, 0.111517, 0.054611, 0.034348, 0.023737}  
	'93Wv'[][10][0]={ 0.000000,22.449200,21.622101,17.627600, 5.728920, 5.371570, 4.439130, 3.854150, 3.669470, 1.502200, 1.329030, 1.087890, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'93Wv'[][0][1]={ 0.000000,358.020996,293.221008,249.917007,82.688599,63.325600,58.192902, 6.799130, 4.432230,22.663300,16.665001,15.337900, 1.967320, 1.285950, 0.019085, 0.021256, 5.970990, 4.123620, 3.749160, 0.414069, 0.268242, 1.260100, 0.748399, 0.627067}  
	'93Wv'[][1][1]={ 0.000000,3363.820068,5701.020020,7188.109863,875.770020,1023.739990,1364.920044,420.667999,412.200989,246.084000,263.161011,346.846008,108.227997,106.333000, 4.963750, 5.741930,64.543602,64.013702,82.900398,21.773800,21.205500,13.237300,11.133200,13.154000}  
	'93Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,6237.140137,9445.919922,18954.000000,16422.199219,20326.199219,2001.500000,2624.280029,4837.910156,3409.010010,4222.970215,633.197998,763.297974,537.473999,645.588013,1148.310059,653.189026,800.543030,109.375999,110.328003,177.684998}  
	'93Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,11170.099609,13324.200195,38605.500000,48979.199219,68694.296875,36101.898438,45035.199219,3418.399902,3811.540039,9672.450195,9236.740234,12726.700195,717.505981,670.859985,1513.719971}  
	'93Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,202572.000000,335440.000000,799233.000000,1035870.000000,16873.300781,13313.099609,54308.500000,54432.601563,83133.500000,3969.330078,2701.270020,8989.629883}  
	'93Wv'[][5][1]={28.280399, 4.920130, 1.668620, 1.400630,30.820700,23.791800,34.737400, 6.144960, 4.909180,169.774002,229.716995,501.071014, 0.003233, 0.002817, 0.000186, 0.000264, 1.396650, 1.147980, 2.269450, 2.448030, 2.675410,18.516899,43.992298,143.882004}  
	'93Wv'[][6][1]={210.404007,229.466995,187.488007,290.806000,1013.330017,1406.439941,3188.689941,2147.909912,2827.040039,3432.000000,5537.270020,17473.699219,669.419006,913.380005,1083.160034,1456.130005,1058.479980,1600.130005,6114.089844,19083.300781,31203.199219,4399.450195,5026.180176,30503.500000}  
	'93Wv'[][7][1]={562.408997,1245.219971,1619.989990,3188.479980,4163.819824,6851.910156,19091.800781,25546.400391,37674.601563,11163.200195,15095.400391,63754.699219,41220.898438,64906.398438,223569.000000,305420.000000,11987.700195,11851.099609,70203.703125,83930.601563,146622.000000,29880.599609,151541.000000,320979.000000}  
	'93Wv'[][8][1]={966.828003,2869.320068,5019.799805,11160.799805,8134.540039,13648.599609,44680.199219,88784.601563,136563.000000,19031.599609,20377.099609,112587.000000,165915.000000,272650.000000,1489900.000000,2046790.000000,32718.300781,31477.000000,183511.000000,458382.000000,699684.000000,85173.101563,2019850.000000,4110260.000000}  
	'93Wv'[][9][1]={1260.969971,4204.149902,8590.769531,20406.199219,10917.400391,17771.199219,65136.800781,158912.000000,248966.000000,23651.300781,21490.199219,141943.000000,202651.000000,352826.000000,157314.000000,206386.000000,45181.699219,107533.000000,313201.000000,2766690.000000,4388130.000000,294023.000000,8169040.000000,21099800.000000}  
	'93Wv'[][10][1]={ 0.000000,4522.810059,9578.120117,23114.099609,11430.900391,18879.800781,69643.898438,146705.000000,254815.000000,24237.699219,24530.599609,135961.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(24,11,2) '94Wv'  
	'94Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'94Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'94Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'94Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'94Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'94Wv'[][5][0]={563.335022,489.690002,472.487000,381.664001,124.402000,116.593002,95.548599,83.296799,79.079498,32.028198,28.493200,22.941401,369.799988,348.209991,191.149002,185.412994,152.227005,122.459999,93.551697,50.174301,45.887901,22.093800,13.547000, 9.043400}  
	'94Wv'[][6][0]={253.988998,99.544296,96.047302,77.584900,25.288601,23.701000,19.423201,16.932600,16.075300, 6.510710, 5.792110, 4.663540,15.281200,14.389100, 7.898820, 7.661820, 6.290460, 5.060420, 3.865830, 2.073350, 1.896220, 0.912979, 0.559801, 0.373700}  
	'94Wv'[][7][0]={172.550003,45.942799,44.328800,35.807800,11.671400,10.938800, 8.964390, 7.814920, 7.419250, 3.004890, 2.673240, 2.152370, 3.255060, 3.065020, 1.682530, 1.632050, 1.339930, 1.077920, 0.823463, 0.441646, 0.403916, 0.194474, 0.119244, 0.079602}  
	'94Wv'[][8][0]={139.113998,29.862600,28.813601,23.275000, 7.586400, 7.110160, 5.826820, 5.079670, 4.822490, 1.953170, 1.737600, 1.399030, 1.375250, 1.294960, 0.710863, 0.689534, 0.566117, 0.455418, 0.347910, 0.186593, 0.170653, 0.082165, 0.050380, 0.033631}  
	'94Wv'[][9][0]={124.977997,24.101999,23.255301,18.785101, 6.122950, 5.738580, 4.702800, 4.099780, 3.892210, 1.576400, 1.402410, 1.129150, 0.895842, 0.843541, 0.463058, 0.449164, 0.368770, 0.296661, 0.226629, 0.121548, 0.111164, 0.053522, 0.032818, 0.021908}  
	'94Wv'[][10][0]={ 0.000000,22.994400,22.186600,17.921801, 5.841560, 5.474850, 4.486680, 3.911370, 3.713330, 1.503950, 1.337960, 1.077260, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'94Wv'[][0][1]={ 0.000000,367.729004,311.378998,262.019012,85.304199,67.178596,61.198002, 7.352850, 4.774910,23.485800,17.776600,16.223600, 2.144370, 1.396840, 0.021626, 0.024004, 6.258390, 4.451870, 4.013160, 0.458602, 0.296179, 1.294590, 0.781207, 0.635721}  
	'94Wv'[][1][1]={ 0.000000,3396.909912,5925.529785,7425.419922,893.161011,1062.949951,1415.439941,447.756989,437.751007,252.653000,275.221008,362.329987,116.096001,113.903000, 5.545300, 6.400510,67.151398,67.857002,87.798401,23.773800,23.104799,13.491900,11.409900,13.153100}  
	'94Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,6244.390137,9510.370117,19313.699219,17101.699219,21126.400391,2029.000000,2680.620117,4983.040039,3582.239990,4436.459961,694.632019,836.103027,554.617981,670.281982,1203.219971,700.823975,857.659973,110.573997,110.865997,175.565994}  
	'94Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,11128.900391,13212.599609,39169.699219,50177.300781,70429.500000,38589.199219,48065.199219,3498.360107,3871.649902,10046.700195,9719.629883,13386.400391,720.643005,661.611023,1484.290039}  
	'94Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,207407.000000,343121.000000,826358.000000,1069790.000000,17051.400391,13290.700195,56026.000000,56182.199219,86037.203125,3955.139893,2621.770020,8772.580078}  
	'94Wv'[][5][1]={27.658899, 4.866410, 1.670890, 1.406360,30.489201,24.096600,35.408501, 6.272430, 5.021400,174.167007,236.806000,535.812988, 0.003609, 0.003134, 0.000197, 0.000287, 1.358400, 1.422350, 2.442790, 2.600390, 2.972280,19.616301,48.927399,169.567993}  
	'94Wv'[][6][1]={203.863007,223.531006,185.498001,289.033997,993.893982,1394.670044,3204.419922,2157.600098,2852.050049,3455.889893,5535.339844,18163.599609,717.054016,985.585999,1123.020020,1534.390015,1026.170044,1782.819946,6373.839844,19611.400391,32789.398437,4508.089844,5199.759766,32570.300781}  
	'94Wv'[][7][1]={543.036987,1208.829956,1587.810059,3149.560059,4057.850098,6712.419922,19024.300781,25363.400391,37555.800781,11104.700195,14822.200195,65394.898438,42542.398438,67331.601563,226209.000000,312322.000000,11610.900391,12409.299805,72398.398438,84586.796875,148381.000000,29780.500000,182419.000000,382322.000000}  
	'94Wv'[][8][1]={932.557007,2779.040039,4892.069824,10976.099609,7892.470215,13268.900391,44315.199219,87442.000000,134965.000000,18853.800781,19881.199219,114983.000000,168416.000000,278058.000000,1499210.000000,2072390.000000,31646.900391,34837.000000,188139.000000,489790.000000,774187.000000,96618.500000,2407820.000000,5384570.000000}  
	'94Wv'[][9][1]={1216.439941,4067.419922,8344.099609,20016.300781,10576.400391,17222.000000,64500.898438,155715.000000,245065.000000,23260.000000,21007.900391,144185.000000,210807.000000,363045.000000,125730.000000,163709.000000,44190.300781,118919.000000,322806.000000,2944720.000000,4934890.000000,344780.000000,11601000.000000,33504900.000000}  
	'94Wv'[][10][1]={ 0.000000,4373.520020,9326.019531,22676.199219,11062.099609,18054.400391,68563.796875,152188.000000,195620.000000,25298.599609,24203.400391,174532.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(24,11,2) '95Wv'  
	'95Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'95Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'95Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'95Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'95Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'95Wv'[][5][0]={577.258972,506.776001,489.105988,394.459015,130.473007,121.726997,99.488197,87.232903,82.858498,34.472301,30.095900,24.210100,399.308014,376.087006,202.330994,196.207001,159.393997,128.647003,97.516899,52.623100,46.942699,22.920401,14.033500, 9.207550}  
	'95Wv'[][6][0]={260.266998,103.017998,99.425697,80.185799,26.522600,24.744600,20.224001,17.732700,16.843500, 7.007550, 6.117900, 4.921450,16.500601,15.541000, 8.360910, 8.107840, 6.586620, 5.316090, 4.029690, 2.174540, 1.939810, 0.947139, 0.579907, 0.380483}  
	'95Wv'[][7][0]={176.815002,47.545799,45.888000,37.008202,12.241000,11.420400, 9.334000, 8.184200, 7.773800, 3.234200, 2.823600, 2.271400, 3.514800, 3.310400, 1.780960, 1.727050, 1.403020, 1.132380, 0.858366, 0.463200, 0.413200, 0.201751, 0.123526, 0.081047}  
	'95Wv'[][8][0]={142.552002,30.904600,29.827000,24.055201, 7.956610, 7.423220, 6.067070, 5.319700, 5.052940, 2.102220, 1.835330, 1.476400, 1.484990, 1.398630, 0.752449, 0.729673, 0.592769, 0.478427, 0.362656, 0.195700, 0.174575, 0.085239, 0.052189, 0.034242}  
	'95Wv'[][9][0]={128.067001,24.943001,24.073299,19.414900, 6.421740, 5.991250, 4.896700, 4.293510, 4.078210, 1.696690, 1.481290, 1.191600, 0.967326, 0.911072, 0.490147, 0.475312, 0.386132, 0.311649, 0.236235, 0.127480, 0.113719, 0.055525, 0.033996, 0.022305}  
	'95Wv'[][10][0]={ 0.000000,23.796700,22.966900,18.522600, 6.126620, 5.715910, 4.671670, 4.096190, 3.890790, 1.618720, 1.413210, 1.136840, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'95Wv'[][0][1]={ 0.000000,378.895996,332.365997,277.174011,88.169899,71.476601,64.558800, 7.990790, 5.165910,24.375999,18.966999,17.179501, 2.342500, 1.520190, 0.024453, 0.027093, 6.554540, 4.804650, 4.301670, 0.509680, 0.327267, 1.359520, 0.844831, 0.675190}  
	'95Wv'[][1][1]={ 0.000000,3446.489990,6215.470215,7829.220215,915.517029,1109.920044,1479.160034,482.375000,470.691986,260.294006,288.393005,379.781006,125.194000,122.632004, 6.193020, 7.137090,69.807404,71.943100,93.061600,26.021799,25.220600,14.056600,12.113600,13.813900}  
	'95Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,6306.729980,9638.299805,19982.000000,18315.400391,22639.699219,2073.830078,2749.340088,5172.490234,3809.429932,4717.549805,764.267029,918.971008,571.755981,696.630005,1261.839966,753.492004,920.989990,114.260002,115.391998,182.453003}  
	'95Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,11216.799805,13087.299805,40275.800781,52418.398438,73742.398438,41631.898438,51829.398437,3576.580078,3938.709961,10453.000000,10253.400391,14114.799805,739.901978,675.750000,1531.520020}  
	'95Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,200723.000000,339031.000000,866939.000000,1123860.000000,17213.300781,13220.799805,57906.000000,58137.101563,89304.203125,4030.879883,2639.080078,9012.870117}  
	'95Wv'[][5][1]={27.210400, 4.702560, 1.636050, 1.341280,28.268200,22.918600,32.782902, 5.684560, 4.434330,154.358994,218.815002,488.888000, 0.002871, 0.002671, 0.000167, 0.000248, 1.284930, 1.359700, 2.312920, 2.422710, 2.990700,18.984800,47.797298,169.501007}  
	'95Wv'[][6][1]={198.524994,213.302994,179.940002,275.126007,927.601990,1319.040039,3019.020020,1984.069946,2591.070068,3118.189941,5159.850098,16968.500000,603.737976,816.903015,983.023987,1341.000000,973.916016,1694.560059,6153.879883,18907.800781,32992.800781,4357.689941,5036.549805,32552.099609}  
	'95Wv'[][7][1]={526.593994,1154.719971,1532.510010,3012.889893,3807.729980,6355.200195,18084.500000,23630.199219,34787.300781,10140.599609,13885.900391,61953.101563,37952.000000,59882.398438,205561.000000,283791.000000,11059.500000,11809.500000,70836.703125,86035.296875,152063.000000,29032.000000,181236.000000,380779.000000}  
	'95Wv'[][8][1]={902.562988,2658.310059,4712.970215,10541.500000,7424.049805,12561.900391,42379.699219,82284.898438,126683.000000,17323.400391,18624.500000,109874.000000,157666.000000,260183.000000,1433360.000000,1984010.000000,30329.400391,33181.699219,185015.000000,435780.000000,730138.000000,100303.000000,2388410.000000,5448340.000000}  
	'95Wv'[][9][1]={1175.510010,3891.889893,8032.950195,19273.099609,9940.400391,16307.700195,61679.800781,147281.000000,231779.000000,21438.000000,19652.900391,139533.000000,202329.000000,348573.000000,124910.000000,161935.000000,42984.398437,113359.000000,314723.000000,2544090.000000,4334410.000000,357761.000000,11804700.000000,35166200.000000}  
	'95Wv'[][10][1]={ 0.000000,4187.009766,8973.339844,21851.900391,10475.000000,17011.500000,67405.601563,134812.000000,123843.000000,23474.699219,22412.300781,127605.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(24,11,2) '96Wv'  
	'96Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'96Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'96Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'96Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'96Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'96Wv'[][5][0]={592.000977,521.422974,506.906006,403.537994,134.044006,125.666000,102.259003,90.108597,84.651299,35.024502,30.697001,24.600300,401.835999,377.635986,213.643997,207.106995,174.955994,134.932999,101.448997,55.279499,50.305698,23.732800,14.514500, 9.349040}  
	'96Wv'[][6][0]={266.912994,105.995003,103.043999,82.031403,27.248501,25.545401,20.787300,18.317301,17.208000, 7.119790, 6.240110, 5.000750,16.605101,15.605000, 8.828380, 8.558280, 7.229690, 5.575820, 4.192190, 2.284310, 2.078780, 0.980709, 0.599781, 0.386330}  
	'96Wv'[][7][0]={181.330002,48.919998,47.557999,37.860001,12.576000,11.790000, 9.594000, 8.454000, 7.942000, 3.286000, 2.880000, 2.308000, 3.537050, 3.324040, 1.880540, 1.823000, 1.540000, 1.187710, 0.892981, 0.486583, 0.442802, 0.208901, 0.127760, 0.082292}  
	'96Wv'[][8][0]={146.192993,31.797800,30.912500,24.608900, 8.174360, 7.663460, 6.236070, 5.495070, 5.162270, 2.135890, 1.871990, 1.500190, 1.494390, 1.404390, 0.794520, 0.770212, 0.650643, 0.501802, 0.377281, 0.205579, 0.187082, 0.088260, 0.053978, 0.034768}  
	'96Wv'[][9][0]={131.337997,25.663900,24.949400,19.861700, 6.597490, 6.185150, 5.033100, 4.435050, 4.166450, 1.723870, 1.510880, 1.210800, 0.973450, 0.914826, 0.517553, 0.501718, 0.423831, 0.326876, 0.245762, 0.133915, 0.121866, 0.057493, 0.035161, 0.022648}  
	'96Wv'[][10][0]={ 0.000000,24.484501,23.802799,18.948900, 6.294290, 5.900890, 4.801800, 4.231230, 3.974970, 1.644640, 1.441440, 1.155150, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'96Wv'[][0][1]={ 0.000000,389.253998,354.846985,291.286011,90.890602,75.840897,67.942101, 8.653140, 5.561130,25.228300,20.190500,18.161100, 2.546940, 1.647050, 0.027587, 0.030486, 6.863200, 5.176700, 4.597050, 0.563844, 0.361245, 1.421240, 0.908098, 0.712296}  
	'96Wv'[][1][1]={ 0.000000,3484.110107,6513.250000,8144.839844,933.536011,1153.989990,1539.060059,516.255005,500.596985,266.966003,301.109009,396.756989,133.994995,131.070007, 6.901080, 7.939100,72.533501,76.133499,98.434196,28.384399,27.481701,14.601700,12.806500,14.447800}  
	'96Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,6314.979980,9709.610352,20518.099609,19355.400391,23680.699219,2101.080078,2803.639893,5336.770020,3996.050049,4947.709961,839.130981,1007.929993,589.458984,722.479004,1321.280029,807.883972,987.403015,117.797997,119.690002,189.076996}  
	'96Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,11174.299805,12926.400391,41033.699219,53659.500000,75560.101563,44826.601562,55782.601563,3663.719971,3996.560059,10860.000000,10789.799805,14876.700195,758.078003,687.690002,1576.040039}  
	'96Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,205218.000000,346749.000000,907827.000000,1178230.000000,17411.800781,13120.400391,59751.000000,59982.800781,92563.203125,4096.470215,2645.620117,9230.750000}  
	'96Wv'[][5][1]={26.731899, 4.604660, 1.596580, 1.319870,27.471500,22.444599,31.728701, 5.421390, 4.350460,153.533997,218.742996,489.803986, 0.003077, 0.002873, 0.000145, 0.000217, 1.090760, 1.305450, 2.198610, 2.237410, 2.435780,18.403700,46.715801,170.007004}  
	'96Wv'[][6][1]={193.084000,205.806000,174.110001,268.851990,897.078979,1274.989990,2923.570068,1894.780029,2536.889893,3066.729980,5054.020020,16874.800781,628.427979,853.984985,866.927002,1181.619995,851.982971,1611.550049,5953.669922,18131.000000,30535.800781,4212.069824,4874.209961,32523.400391}  
	'96Wv'[][7][1]={510.020996,1112.439941,1476.219971,2939.020020,3670.120117,6110.879883,17538.300781,22622.199219,33949.000000,9898.490234,13436.099609,61478.500000,38479.898438,60946.300781,187735.000000,259178.000000,9899.200195,11232.099609,69376.203125,87057.500000,153749.000000,28373.000000,180501.000000,381003.000000}  
	'96Wv'[][8][1]={872.869019,2559.129883,4532.830078,10272.599609,7137.220215,12035.200195,41158.601563,78958.203125,123299.000000,16860.400391,17945.400391,109140.000000,158438.000000,262488.000000,1370930.000000,1898700.000000,27736.699219,31662.900391,182006.000000,387950.000000,612902.000000,104466.000000,2373900.000000,5542610.000000}  
	'96Wv'[][9][1]={1136.689941,3746.110107,7720.799805,18765.900391,9551.219727,15536.400391,60002.800781,141517.000000,225093.000000,21025.400391,18976.199219,138930.000000,204625.000000,361040.000000,124047.000000,159868.000000,39880.601563,108555.000000,307293.000000,2219000.000000,3694840.000000,372138.000000,12067200.000000,37190100.000000}  
	'96Wv'[][10][1]={ 0.000000,4031.629883,8611.080078,21292.099609,10047.799805,16447.800781,65611.296875,118531.000000,96089.601563,21546.199219,19639.300781,122011.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(24,11,2) '97Wv'  
	'97Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'97Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'97Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'97Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'97Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'97Wv'[][5][0]={607.560974,538.796997,519.823975,414.665985,139.757004,131.037994,106.097000,93.071701,88.083397,37.411999,33.127201,26.327000,418.169006,392.588013,225.108994,218.141006,180.863007,141.343994,105.379997,57.810501,52.470901,24.558500,15.001600, 9.475650}  
	'97Wv'[][6][0]={273.928986,109.527000,105.669998,84.293404,28.409800,26.637400,21.567400,18.919701,17.905600, 7.605130, 6.734110, 5.351760,17.280001,16.222900, 9.302180, 9.014230, 7.473810, 5.840750, 4.354610, 2.388900, 2.168250, 1.014830, 0.619912, 0.391561}  
	'97Wv'[][7][0]={186.095993,50.549999,48.770000,38.903999,13.112000,12.294000, 9.954000, 8.732000, 8.264000, 3.510000, 3.108000, 2.470000, 3.680820, 3.455650, 1.981460, 1.920130, 1.592000, 1.244140, 0.927579, 0.508861, 0.461860, 0.216170, 0.132048, 0.083407}  
	'97Wv'[][8][0]={150.035004,32.857300,31.700300,25.287500, 8.522760, 7.991060, 6.470070, 5.675770, 5.371570, 2.281490, 2.020190, 1.605490, 1.555130, 1.460000, 0.837159, 0.811246, 0.672613, 0.525645, 0.391898, 0.214991, 0.195134, 0.091331, 0.055790, 0.035239}  
	'97Wv'[][9][0]={134.789001,26.518999,25.585199,20.409401, 6.878680, 6.449550, 5.221960, 4.580890, 4.335370, 1.841380, 1.630490, 1.295790, 1.013020, 0.951046, 0.545328, 0.528448, 0.438142, 0.342407, 0.255284, 0.140046, 0.127111, 0.059493, 0.036341, 0.022955}  
	'97Wv'[][10][0]={ 0.000000,25.300301,24.409401,19.471500, 6.562560, 6.153150, 4.981980, 4.370370, 4.136130, 1.756760, 1.555550, 1.236230, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'97Wv'[][0][1]={ 0.000000,400.321014,375.899994,306.806000,93.762901,80.556602,71.539200, 9.359190, 5.998800,26.127001,21.531200,19.208599, 2.769510, 1.785550, 0.031055, 0.034231, 7.166960, 5.574200, 4.904250, 0.622140, 0.396970, 1.485780, 0.976491, 0.752469}  
	'97Wv'[][1][1]={ 0.000000,3543.020020,6738.399902,8522.330078,954.315002,1202.229980,1605.030029,552.067017,536.098022,274.463013,315.412994,415.717987,143.675003,140.354004, 7.673890, 8.812260,75.171898,80.453697,103.945999,30.882099,29.841400,15.143600,13.516100,15.096000}  
	'97Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,6348.629883,9795.700195,21173.199219,20445.000000,25208.000000,2141.540039,2874.969971,5545.709961,4213.029785,5216.029785,919.479004,1103.270020,605.557007,747.755005,1381.359985,864.036987,1055.290039,121.144997,123.782997,195.533997}  
	'97Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,11221.099609,12715.200195,42313.398437,55406.300781,78155.703125,48178.699219,59926.500000,3730.800049,4044.820068,11267.700195,11329.599609,15629.700195,774.492004,697.620972,1618.719971}  
	'97Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,204363.000000,347143.000000,949346.000000,1233490.000000,17496.500000,12995.500000,61547.199219,61741.101563,95661.101563,4153.720215,2642.899902,9430.759766}  
	'97Wv'[][5][1]={26.229401, 4.466470, 1.606310, 1.280750,25.806000,21.426800,29.838200, 5.166500, 3.948410,137.996002,192.619995,431.074005, 0.002857, 0.002774, 0.000126, 0.000194, 1.062300, 1.202210, 2.096740, 2.095940, 2.257360,17.836800,45.627800,170.863007}  
	'97Wv'[][6][1]={187.582993,196.869995,172.541000,259.626007,845.155029,1208.579956,2773.649902,1809.369995,2350.199951,2795.449951,4563.640137,15381.799805,590.682983,798.249023,769.367004,1047.500000,824.301025,1534.099976,5764.200195,17490.900391,29551.800781,4067.780029,4710.819824,32473.099609}  
	'97Wv'[][7][1]={493.410004,1064.449951,1448.439941,2842.080078,3467.949951,5792.740234,16757.199219,21661.199219,31883.800781,9109.339844,12308.799805,57204.601562,36690.500000,58110.398438,172051.000000,237630.000000,9559.269531,10674.099609,67958.898438,87825.500000,155614.000000,27773.800781,179855.000000,382369.000000}  
	'97Wv'[][8][1]={843.192017,2451.040039,4421.180176,9947.620117,6751.520020,11398.799805,39518.699219,75817.101563,116828.000000,15613.500000,16461.300781,102640.000000,153790.000000,255019.000000,1308300.000000,1815870.000000,26875.000000,30268.699219,179005.000000,350626.000000,554493.000000,108859.000000,2361520.000000,5659310.000000}  
	'97Wv'[][9][1]={1097.930054,3587.860107,7507.200195,18179.199219,9044.179688,14706.500000,57887.699219,136162.000000,214118.000000,19364.300781,17324.699219,129846.000000,204433.000000,357307.000000,122328.000000,157553.000000,39262.500000,104429.000000,300424.000000,1961380.000000,3261110.000000,386890.000000,12332000.000000,39327100.000000}  
	'97Wv'[][10][1]={ 0.000000,3864.639893,8367.009766,20652.599609,9456.900391,15543.900391,61344.601563,75948.000000,145324.000000,21295.099609,17860.900391,165074.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(24,11,2) '98Wv'  
	'98Wv'[][0][0]={80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298,80.000298}  
	'98Wv'[][1][0]={26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100,26.700100}  
	'98Wv'[][2][0]={ 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960, 8.899960}  
	'98Wv'[][3][0]={ 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030, 3.000030}  
	'98Wv'[][4][0]={ 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000}  
	'98Wv'[][5][0]={624.937988,552.177979,533.367004,421.075012,142.095993,133.574997,107.272003,94.174599,89.048302,37.453999,33.554401,26.474899,434.734985,407.705994,236.727997,229.315994,181.707993,147.908997,109.317001,60.334599,54.622200,25.389799,15.485700, 9.600990}  
	'98Wv'[][6][0]={281.763000,112.247002,108.422997,85.596298,28.885300,27.153299,21.806400,19.143900,18.101801, 7.613670, 6.820950, 5.381820,17.964500,16.847601, 9.782310, 9.475990, 7.508700, 6.112040, 4.517310, 2.493200, 2.257150, 1.049180, 0.639913, 0.396741}  
	'98Wv'[][7][0]={191.419006,51.805401,50.040600,39.505299,13.331500,12.532100,10.064300, 8.835480, 8.354530, 3.513940, 3.148080, 2.483880, 3.826630, 3.588720, 2.083730, 2.018490, 1.599430, 1.301930, 0.962235, 0.531079, 0.480797, 0.223487, 0.136308, 0.084510}  
	'98Wv'[][8][0]={154.326004,33.673302,32.526199,25.678301, 8.665410, 8.145800, 6.541770, 5.743030, 5.430410, 2.284050, 2.046240, 1.614510, 1.616740, 1.516220, 0.880369, 0.852802, 0.675753, 0.550060, 0.406540, 0.224378, 0.203135, 0.094422, 0.057590, 0.035705}  
	'98Wv'[][9][0]={138.645004,27.177601,26.251801,20.724899, 6.993820, 6.574440, 5.279830, 4.635170, 4.382860, 1.843450, 1.651510, 1.303060, 1.053150, 0.987670, 0.573475, 0.555518, 0.440188, 0.358311, 0.264822, 0.146161, 0.132323, 0.061507, 0.037514, 0.023258}  
	'98Wv'[][10][0]={ 0.000000,25.928600,25.045300,19.772400, 6.672400, 6.272300, 5.037190, 4.422160, 4.181440, 1.758730, 1.575610, 1.243180, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
	'98Wv'[][0][1]={ 0.000000,410.054993,398.040985,320.488007,96.406197,85.161903,74.985100,10.072000, 6.432630,26.996401,22.870800,20.261499, 3.009380, 1.932190, 0.034889, 0.038355, 7.473390, 5.986300, 5.229130, 0.684877, 0.435123, 1.547080, 1.045370, 0.792541}  
	'98Wv'[][1][1]={ 0.000000,3567.110107,6994.759766,8771.530273,969.135010,1242.609985,1659.449951,584.268005,566.593018,280.770996,328.404999,433.272003,153.895996,150.093002, 8.516230, 9.761360,77.774101,84.837196,109.635002,33.522900,32.323399,15.667200,14.227000,15.728200}  
	'98Wv'[][2][1]={ 0.000000, 0.000000, 0.000000, 0.000000,6316.709961,9789.679688,21519.099609,21133.599609,26058.599609,2160.280029,2920.209961,5705.160156,4436.770020,5492.850098,1005.580017,1205.270020,620.546997,772.302002,1442.040039,922.039001,1125.180054,124.361000,127.762001,201.656998}  
	'98Wv'[][3][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,11124.900391,12495.400391,42955.500000,57152.898438,80763.500000,51692.601563,64265.800781,3785.290039,4082.969971,11675.799805,11873.299805,16386.300781,789.984009,705.862976,1658.010010}  
	'98Wv'[][4][1]={ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,192331.000000,348317.000000,991337.000000,1289600.000000,17520.500000,12851.599609,63290.101563,63409.398438,98628.898438,4203.049805,2635.830078,9606.450195}  
	'98Wv'[][5][1]={25.636400, 4.413230, 1.613560, 1.287200,25.661301,21.686300,30.308500, 5.317800, 4.041820,141.307999,195.516006,442.795990, 0.002667, 0.002687, 0.000105, 0.000175, 1.103200, 1.155070, 2.007130, 1.974530, 2.103530,17.284100,44.624100,171.403000}  
	'98Wv'[][6][1]={181.615005,191.319000,170.759003,258.194000,831.562012,1196.900024,2781.169922,1828.750000,2372.350098,2807.689941,4510.229980,15559.099609,556.507019,747.982971,687.005981,934.336975,836.504028,1461.089966,5590.189941,16893.099609,28646.900391,3927.000000,4550.149902,32351.500000}  
	'98Wv'[][7][1]={475.769989,1031.060059,1419.729980,2810.969971,3385.840088,5664.720215,16671.900391,21601.199219,31795.599609,9037.679688,11970.000000,57470.699219,35022.500000,55498.898438,158355.000000,218638.000000,9569.129883,10133.400391,66575.500000,88319.296875,157040.000000,27241.800781,180030.000000,382394.000000}  
	'98Wv'[][8][1]={811.781006,2369.219971,4307.990234,9792.209961,6557.689941,11056.000000,39147.101563,74913.500000,115481.000000,15421.400391,15901.599609,102959.000000,149221.000000,247908.000000,1251420.000000,1735640.000000,26768.000000,28983.199219,176016.000000,319606.000000,505720.000000,113707.000000,2354980.000000,5780810.000000}  
	'98Wv'[][9][1]={1056.030029,3465.110107,7289.399902,17859.900391,8767.719727,14226.299805,57274.398438,133790.000000,210664.000000,19133.199219,16750.900391,130267.000000,201664.000000,348896.000000,122152.000000,154971.000000,39809.601563,100800.000000,294117.000000,1750300.000000,2908250.000000,402479.000000,12611600.000000,41439100.000000}  
	'98Wv'[][10][1]={ 0.000000,3728.290039,8141.189941,20260.699219,9164.040039,14758.799805,60365.398437,60161.101563,1179700.000000,21258.900391,19372.000000,172616.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000}  
   
	Make/O/N=(0,11,2) '99Wv'  
	'99Wv'[][0][0]={0}  
	'99Wv'[][1][0]={0}  
	'99Wv'[][2][0]={0}  
	'99Wv'[][3][0]={0}  
	'99Wv'[][4][0]={0}  
	'99Wv'[][5][0]={0}  
	'99Wv'[][6][0]={0}  
	'99Wv'[][7][0]={0}  
	'99Wv'[][8][0]={0}  
	'99Wv'[][9][0]={0}  
	'99Wv'[][10][0]={0}  
	'99Wv'[][0][1]={0}  
	'99Wv'[][1][1]={0}  
	'99Wv'[][2][1]={0}  
	'99Wv'[][3][1]={0}  
	'99Wv'[][4][1]={0}  
	'99Wv'[][5][1]={0}  
	'99Wv'[][6][1]={0}  
	'99Wv'[][7][1]={0}  
	'99Wv'[][8][1]={0}  
	'99Wv'[][9][1]={0}  
	'99Wv'[][10][1]={0}  
   
	Make/O/N=(0,11,2) '100Wv'  
	'100Wv'[][0][0]={0}  
	'100Wv'[][1][0]={0}  
	'100Wv'[][2][0]={0}  
	'100Wv'[][3][0]={0}  
	'100Wv'[][4][0]={0}  
	'100Wv'[][5][0]={0}  
	'100Wv'[][6][0]={0}  
	'100Wv'[][7][0]={0}  
	'100Wv'[][8][0]={0}  
	'100Wv'[][9][0]={0}  
	'100Wv'[][10][0]={0}  
	'100Wv'[][0][1]={0}  
	'100Wv'[][1][1]={0}  
	'100Wv'[][2][1]={0}  
	'100Wv'[][3][1]={0}  
	'100Wv'[][4][1]={0}  
	'100Wv'[][5][1]={0}  
	'100Wv'[][6][1]={0}  
	'100Wv'[][7][1]={0}  
	'100Wv'[][8][1]={0}  
	'100Wv'[][9][1]={0}  
	'100Wv'[][10][1]={0}  
   
	Make/O/N=(0,11,2) '101Wv'  
	'101Wv'[][0][0]={0}  
	'101Wv'[][1][0]={0}  
	'101Wv'[][2][0]={0}  
	'101Wv'[][3][0]={0}  
	'101Wv'[][4][0]={0}  
	'101Wv'[][5][0]={0}  
	'101Wv'[][6][0]={0}  
	'101Wv'[][7][0]={0}  
	'101Wv'[][8][0]={0}  
	'101Wv'[][9][0]={0}  
	'101Wv'[][10][0]={0}  
	'101Wv'[][0][1]={0}  
	'101Wv'[][1][1]={0}  
	'101Wv'[][2][1]={0}  
	'101Wv'[][3][1]={0}  
	'101Wv'[][4][1]={0}  
	'101Wv'[][5][1]={0}  
	'101Wv'[][6][1]={0}  
	'101Wv'[][7][1]={0}  
	'101Wv'[][8][1]={0}  
	'101Wv'[][9][1]={0}  
	'101Wv'[][10][1]={0}  
   
	Make/O/N=(0,11,2) '102Wv'  
	'102Wv'[][0][0]={0}  
	'102Wv'[][1][0]={0}  
	'102Wv'[][2][0]={0}  
	'102Wv'[][3][0]={0}  
	'102Wv'[][4][0]={0}  
	'102Wv'[][5][0]={0}  
	'102Wv'[][6][0]={0}  
	'102Wv'[][7][0]={0}  
	'102Wv'[][8][0]={0}  
	'102Wv'[][9][0]={0}  
	'102Wv'[][10][0]={0}  
	'102Wv'[][0][1]={0}  
	'102Wv'[][1][1]={0}  
	'102Wv'[][2][1]={0}  
	'102Wv'[][3][1]={0}  
	'102Wv'[][4][1]={0}  
	'102Wv'[][5][1]={0}  
	'102Wv'[][6][1]={0}  
	'102Wv'[][7][1]={0}  
	'102Wv'[][8][1]={0}  
	'102Wv'[][9][1]={0}  
	'102Wv'[][10][1]={0}  
   
	Make/O/N=(0,11,2) '103Wv'  
	'103Wv'[][0][0]={0}  
	'103Wv'[][1][0]={0}  
	'103Wv'[][2][0]={0}  
	'103Wv'[][3][0]={0}  
	'103Wv'[][4][0]={0}  
	'103Wv'[][5][0]={0}  
	'103Wv'[][6][0]={0}  
	'103Wv'[][7][0]={0}  
	'103Wv'[][8][0]={0}  
	'103Wv'[][9][0]={0}  
	'103Wv'[][10][0]={0}  
	'103Wv'[][0][1]={0}  
	'103Wv'[][1][1]={0}  
	'103Wv'[][2][1]={0}  
	'103Wv'[][3][1]={0}  
	'103Wv'[][4][1]={0}  
	'103Wv'[][5][1]={0}  
	'103Wv'[][6][1]={0}  
	'103Wv'[][7][1]={0}  
	'103Wv'[][8][1]={0}  
	'103Wv'[][9][1]={0}  
	'103Wv'[][10][1]={0}  

	setDataFolder OldDf
end

//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************

static Function Cromer_SetLookupLists()

//here we fill in the infor for all known elements
	string OldDf=GetDataFolder(1)
	NewDataFolder/O/S root:Packages	
	NewDataFolder/O/S root:Packages:CromerCalculations

	string/g ListOfElements
	string/g  ListOfElNumbers
	string/g  ListOfElAtomWghts
	string/g  ListOfIsotopes
	string/g  ListOfElNeutronBs
	string/g  ListOfElNeuIncohBs
	string/g  ListofNeutronAbsCross
	SVAR ListOfElements
	SVAR ListOfElNumbers
	SVAR ListOfElAtomWghts
	SVAR ListOfIsotopes
	SVAR ListOfElNeutronBs
	SVAR ListOfElNeuIncohBs
	SVAR ListofNeutronAbsCross
	

//common for X rays and neutrons
// 	ListOfElements = "H;D;He;..."
//	ListOfElNumbers = "H=1;D=1;He=2;..."
//	ListOfElAtomWghts = "H=1;D=2;He=4;..."
	//H
	ListOfElements ="---;H;"
	ListOfElNumbers ="H=1;"
	ListOfElAtomWghts ="H=1.00794;"
	//D  (see http://en.wikipedia.org/wiki/Isotopes_of_hydrogen)
	ListOfElements +="D;"
	ListOfElNumbers +="D=1;"
	ListOfElAtomWghts +="D=2.014101778;"
	//T
	ListOfElements +="T;"
	ListOfElNumbers +="T=1;"
	ListOfElAtomWghts +="T=3.0160493;"
	//He
	ListOfElements +="He;"
	ListOfElNumbers +="He=2;"
	ListOfElAtomWghts +="He=4.002602;"
	//Li
	ListOfElements +="Li;"
	ListOfElNumbers +="Li=3;"
	ListOfElAtomWghts +="Li=6.941;"
	//Be
	ListOfElements +="Be;"
	ListOfElNumbers +="Be=4;"
	ListOfElAtomWghts +="Be=9.012182;"
	//B
	ListOfElements +="B;"
	ListOfElNumbers +="B=5;"
	ListOfElAtomWghts +="B=10.811;"
	//C
	ListOfElements +="C;"
	ListOfElNumbers +="C=6;"
	ListOfElAtomWghts +="C=12.011;"
	//N
	ListOfElements +="N;"
	ListOfElNumbers +="N=7;"
	ListOfElAtomWghts +="N=14.00674;"
	//O
	ListOfElements +="O;"
	ListOfElNumbers +="O=8;"
	ListOfElAtomWghts +="O=15.9994;"
	//F
	ListOfElements +="F;"
	ListOfElNumbers +="F=9;"
	ListOfElAtomWghts +="F=18.9984032;"
	//Ne
	ListOfElements +="Ne;"
	ListOfElNumbers +="Ne=10;"
	ListOfElAtomWghts +="Ne=20.1797;"
//  III line
	//Na
	ListOfElements +="Na;"
	ListOfElNumbers +="Na=11;"
	ListOfElAtomWghts +="Na=22.989768;"
	//Mg
	ListOfElements +="Mg;"
	ListOfElNumbers +="Mg=12;"
	ListOfElAtomWghts +="Mg=24.3050;"
	//Al
	ListOfElements +="Al;"
	ListOfElNumbers +="Al=13;"
	ListOfElAtomWghts +="Al=26.981539;"
	//Si
	ListOfElements +="Si;"
	ListOfElNumbers +="Si=14;"
	ListOfElAtomWghts +="Si=28.0855;"
	//P
	ListOfElements +="P;"
	ListOfElNumbers +="P=15;"
	ListOfElAtomWghts +="P=30.973762;"
	//S
	ListOfElements +="S;"
	ListOfElNumbers +="S=16;"
	ListOfElAtomWghts +="S=32.066;"
	//Cl
	ListOfElements +="Cl;"
	ListOfElNumbers +="Cl=17;"
	ListOfElAtomWghts +="Cl=35.4527;"
	//Ar
	ListOfElements +="Ar;"
	ListOfElNumbers +="Ar=18;"
	ListOfElAtomWghts +="Ar=39.948;"
	//K
	ListOfElements +="K;"
	ListOfElNumbers +="K=19;"
	ListOfElAtomWghts +="K=39.0983;"
	//Ca
	ListOfElements +="Ca;"
	ListOfElNumbers +="Ca=20;"
	ListOfElAtomWghts +="Ca=40.078;"
	//Sc
	ListOfElements +="Sc;"
	ListOfElNumbers +="Sc=21;"
	ListOfElAtomWghts +="Sc=44.95591;"
	//Ti
	ListOfElements +="Ti;"
	ListOfElNumbers +="Ti=22;"
	ListOfElAtomWghts +="Ti=47.88;"
	//V
	ListOfElements +="V;"
	ListOfElNumbers +="V=23;"
	ListOfElAtomWghts +="V=50.9415;"
	//Cr
	ListOfElements +="Cr;"
	ListOfElNumbers +="Cr=24;"
	ListOfElAtomWghts +="Cr=51.9961;"
	//Mn
	ListOfElements +="Mn;"
	ListOfElNumbers +="Mn=25;"
	ListOfElAtomWghts +="Mn=54.93805;"
	//Fe
	ListOfElements +="Fe;"
	ListOfElNumbers +="Fe=26;"
	ListOfElAtomWghts +="Fe=55.847;"
	//Co
	ListOfElements +="Co;"
	ListOfElNumbers +="Co=27;"
	ListOfElAtomWghts +="Co=58.93320;"
	//Ni
	ListOfElements +="Ni;"
	ListOfElNumbers +="Ni=28;"
	ListOfElAtomWghts +="Ni=58.6934;"
	//Cu
	ListOfElements +="Cu;"
	ListOfElNumbers +="Cu=29;"
	ListOfElAtomWghts +="Cu=63.546;"
	//Zn
	ListOfElements +="Zn;"
	ListOfElNumbers +="Zn=30;"
	ListOfElAtomWghts +="Zn=65.38;"
	//Ga
	ListOfElements +="Ga;"
	ListOfElNumbers +="Ga=31;"
	ListOfElAtomWghts +="Ga=69.723;"
	//Ge
	ListOfElements +="Ge;"
	ListOfElNumbers +="Ge=32;"
	ListOfElAtomWghts +="Ge=72.61;"
	//As
	ListOfElements +="As;"
	ListOfElNumbers +="As=33;"
	ListOfElAtomWghts +="As=74.92159;"
	//Se
	ListOfElements +="Se;"
	ListOfElNumbers +="Se=34;"
	ListOfElAtomWghts +="Se=78.96;"
	//Br
	ListOfElements +="Br;"
	ListOfElNumbers +="Br=35;"
	ListOfElAtomWghts +="Br=79.904;"
	//Kr
	ListOfElements +="Kr;"
	ListOfElNumbers +="Kr=36;"
	ListOfElAtomWghts +="Kr=83.80;"
	//Rb
	ListOfElements +="Rb;"
	ListOfElNumbers +="Rb=37;"
	ListOfElAtomWghts +="Rb=85.4678;"
	//Sr
	ListOfElements +="Sr;"
	ListOfElNumbers +="Sr=38;"
	ListOfElAtomWghts +="Sr=87.62;"
	//Y
	ListOfElements +="Y;"
	ListOfElNumbers +="Y=39;"
	ListOfElAtomWghts +="Y=88.90585;"
	//Zr
	ListOfElements +="Zr;"
	ListOfElNumbers +="Zr=40;"
	ListOfElAtomWghts +="Zr=91.224;"
	//Nb
	ListOfElements +="Nb;"
	ListOfElNumbers +="Nb=41;"
	ListOfElAtomWghts +="Nb=92.9064;"
	//Mo
	ListOfElements +="Mo;"
	ListOfElNumbers +="Mo=42;"
	ListOfElAtomWghts +="Mo=95.94;"
	//Tc
	ListOfElements +="Tc;"
	ListOfElNumbers +="Tc=43;"
	ListOfElAtomWghts +="Tc=98.0;"
	//Ru
	ListOfElements +="Ru;"
	ListOfElNumbers +="Ru=44;"
	ListOfElAtomWghts +="Ru=101.07;"
	//Rh
	ListOfElements +="Rh;"
	ListOfElNumbers +="Rh=45;"
	ListOfElAtomWghts +="Rh=102.9055;"
	//Pd
	ListOfElements +="Pd;"
	ListOfElNumbers +="Pd=46;"
	ListOfElAtomWghts +="Pd=106.42;"
	//Ag
	ListOfElements +="Ag;"
	ListOfElNumbers +="Ag=47;"
	ListOfElAtomWghts +="Ag=107.868;"
	//Cd
	ListOfElements +="Cd;"
	ListOfElNumbers +="Cd=48;"
	ListOfElAtomWghts +="Cd=112.411;"
	//In
	ListOfElements +="In;"
	ListOfElNumbers +="In=49;"
	ListOfElAtomWghts +="In=114.818;"
	//Sn
	ListOfElements +="Sn;"
	ListOfElNumbers +="Sn=50;"
	ListOfElAtomWghts +="Sn=118.710;"
	//Sb
	ListOfElements +="Sb;"
	ListOfElNumbers +="Sb=51;"
	ListOfElAtomWghts +="Sb=121.75;"
	//Te
	ListOfElements +="Te;"
	ListOfElNumbers +="Te=52;"
	ListOfElAtomWghts +="Te=127.60;"
	//I
	ListOfElements +="I;"
	ListOfElNumbers +="I=53;"
	ListOfElAtomWghts +="I=126.9045;"
	//Xe
	ListOfElements +="Xe;"
	ListOfElNumbers +="Xe=54;"
	ListOfElAtomWghts +="Xe=131.29;"
	//Cs
	ListOfElements +="Cs;"
	ListOfElNumbers +="Cs=55;"
	ListOfElAtomWghts +="Cs=132.9054;"
	//Ba
	ListOfElements +="Ba;"
	ListOfElNumbers +="Ba=56;"
	ListOfElAtomWghts +="Ba=137.327;"
	//La
	ListOfElements +="La;"
	ListOfElNumbers +="La=57;"
	ListOfElAtomWghts +="La=138.9055;"
	//Ce
	ListOfElements +="Ce;"
	ListOfElNumbers +="Ce=58;"
	ListOfElAtomWghts +="Ce=140.115;"
	//Pr
	ListOfElements +="Pr;"
	ListOfElNumbers +="Pr=59;"
	ListOfElAtomWghts +="Pr=140.90765;"
	//Nd
	ListOfElements +="Nd;"
	ListOfElNumbers +="Nd=60;"
	ListOfElAtomWghts +="Nd=144.24;"
	//Pm
	ListOfElements +="Pm;"
	ListOfElNumbers +="Pm=61;"
	ListOfElAtomWghts +="Pm=146.9151;"
	//Sm
	ListOfElements +="Sm;"
	ListOfElNumbers +="Sm=62;"
	ListOfElAtomWghts +="Sm=150.36;"
	//Eu
	ListOfElements +="Eu;"
	ListOfElNumbers +="Eu=63;"
	ListOfElAtomWghts +="Eu=151.965;"
	//Gd
	ListOfElements +="Gd;"
	ListOfElNumbers +="Gd=64;"
	ListOfElAtomWghts +="Gd=157.25;"
	//Tb
	ListOfElements +="Tb;"
	ListOfElNumbers +="Tb=65;"
	ListOfElAtomWghts +="Tb=158.92534;"
	//Dy
	ListOfElements +="Dy;"
	ListOfElNumbers +="Dy=66;"
	ListOfElAtomWghts +="Dy=162.50;"
	//Ho
	ListOfElements +="Ho;"
	ListOfElNumbers +="Ho=67;"
	ListOfElAtomWghts +="Ho=164.93032;"
	//Er
	ListOfElements +="Er;"
	ListOfElNumbers +="Er=68;"
	ListOfElAtomWghts +="Er=167.26;"
	//Tm
	ListOfElements +="Tm;"
	ListOfElNumbers +="Tm=69;"
	ListOfElAtomWghts +="Tm=168.9342;"
	//Yb
	ListOfElements +="Yb;"
	ListOfElNumbers +="Yb=70;"
	ListOfElAtomWghts +="Yb=173.04;"
	//Lu
	ListOfElements +="Lu;"
	ListOfElNumbers +="Lu=71;"
	ListOfElAtomWghts +="Lu=174.967;"
	//Hf
	ListOfElements +="Hf;"
	ListOfElNumbers +="Hf=72;"
	ListOfElAtomWghts +="Hf=178.49;"
	//Ta
	ListOfElements +="Ta;"
	ListOfElNumbers +="Ta=73;"
	ListOfElAtomWghts +="Ta=180.9479;"
	//W
	ListOfElements +="W;"
	ListOfElNumbers +="W=74;"
	ListOfElAtomWghts +="W=183.84;"
	//Re
	ListOfElements +="Re;"
	ListOfElNumbers +="Re=75;"
	ListOfElAtomWghts +="Re=186.207;"
	//Os
	ListOfElements +="Os;"
	ListOfElNumbers +="Os=76;"
	ListOfElAtomWghts +="Os=190.23;"
	//Ir
	ListOfElements +="Ir;"
	ListOfElNumbers +="Ir=77;"
	ListOfElAtomWghts +="Ir=192.22;"
	//Pt
	ListOfElements +="Pt;"
	ListOfElNumbers +="Pt=78;"
	ListOfElAtomWghts +="Pt=195.08;"
	//Au
	ListOfElements +="Au;"
	ListOfElNumbers +="Au=79;"
	ListOfElAtomWghts +="Au=196.96654;"
	//Hg
	ListOfElements +="Hg;"
	ListOfElNumbers +="Hg=80;"
	ListOfElAtomWghts +="Hg=200.59;"
	//Tl
	ListOfElements +="Tl;"
	ListOfElNumbers +="Tl=81;"
	ListOfElAtomWghts +="Tl=204.3833;"
	//Pb
	ListOfElements +="Pb;"
	ListOfElNumbers +="Pb=82;"
	ListOfElAtomWghts +="Pb=207.2;"
	//Bi
	ListOfElements +="Bi;"
	ListOfElNumbers +="Bi=83;"
	ListOfElAtomWghts +="Bi=208.98037;"
	//Po
	ListOfElements +="Po;"
	ListOfElNumbers +="Po=84;"
	ListOfElAtomWghts +="Po=208.9824;"
	//At
	ListOfElements +="At;"
	ListOfElNumbers +="At=85;"
	ListOfElAtomWghts +="At=209.9871;"
	//Rn
	ListOfElements +="Rn;"
	ListOfElNumbers +="Rn=86;"
	ListOfElAtomWghts +="Rn=222.0176;"
	//Fr
	ListOfElements +="Fr;"
	ListOfElNumbers +="Fr=87;"
	ListOfElAtomWghts +="Fr=223.0197;"
	//Ra
	ListOfElements +="Ra;"
	ListOfElNumbers +="Ra=88;"
	ListOfElAtomWghts +="Ra=226.0254;"
	//Ac
	ListOfElements +="Ac;"
	ListOfElNumbers +="Ac=89;"
	ListOfElAtomWghts +="Ac=227.0278;"
	//Th
	ListOfElements +="Th;"
	ListOfElNumbers +="Th=90;"
	ListOfElAtomWghts +="Th=232.0381;"
	//Pa
	ListOfElements +="Pa;"
	ListOfElNumbers +="Pa=91;"
	ListOfElAtomWghts +="Pa=231.0359;"
	//U
	ListOfElements +="U;"
	ListOfElNumbers +="U=92;"
	ListOfElAtomWghts +="U=238.0289;"
	//Np
	ListOfElements +="Np;"
	ListOfElNumbers +="Np=93;"
	ListOfElAtomWghts +="Np=237.0482;"
	//Pu
	ListOfElements +="Pu;"
	ListOfElNumbers +="Pu=94;"
	ListOfElAtomWghts +="Pu=244.0642;"
	//Am
	ListOfElements +="Am;"
	ListOfElNumbers +="Am=95;"
	ListOfElAtomWghts +="Am=243.0614;"
	//Cm
	ListOfElements +="Cm;"
	ListOfElNumbers +="Cm=96;"
	ListOfElAtomWghts +="Cm=247.0703;"
	//Bk
	ListOfElements +="Bk;"
	ListOfElNumbers +="Bk=97;"
	ListOfElAtomWghts +="Bk=247.0703;"
	//Cf
	ListOfElements +="Cf;"
	ListOfElNumbers +="Cf=98;"
	ListOfElAtomWghts +="Cf=251.0796;"
	//Es
	ListOfElements +="Es;"
	ListOfElNumbers +="Es=99;"
	ListOfElAtomWghts +="Es=252.0829;"
	//Fm
	ListOfElements +="Fm;"
	ListOfElNumbers +="Fm=100;"
	ListOfElAtomWghts +="Fm=257.0951;"
	//Md
	ListOfElements +="Md;"
	ListOfElNumbers +="Md=101;"
	ListOfElAtomWghts +="Md=258.0986;"
	//No
	ListOfElements +="No;"
	ListOfElNumbers +="No=102;"
	ListOfElAtomWghts +="No=259.1009;"
	//Lr
	ListOfElements +="Lr;"
	ListOfElNumbers +="Lr=103;"
	ListOfElAtomWghts +="Lr=262.11;"
	//Rf
	ListOfElements +="Rf;"
	ListOfElNumbers +="Rf=104;"
	ListOfElAtomWghts +="Rf=261.1087;"
	//Db
	ListOfElements +="Db;"
	ListOfElNumbers +="Db=105;"
	ListOfElAtomWghts +="Db=262.1138;"
	//Sg
	ListOfElements +="Sg;"
	ListOfElNumbers +="Sg=106;"
	ListOfElAtomWghts +="Sg=263.1182;"
	//Bh
	ListOfElements +="Bh;"
	ListOfElNumbers +="Bh=107;"
	ListOfElAtomWghts +="Bh=262.1229;"
	//Hs
	ListOfElements +="Hs;"
	ListOfElNumbers +="Hs=108;"
	ListOfElAtomWghts +="Hs=265;"
	//Mt
	ListOfElements +="Mt;"
	ListOfElNumbers +="Mt=109;"
	ListOfElAtomWghts +="Mt=266;"
	
	setDataFolder OldDf
end