#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.29

Constant AlwaysRecalculateFF = 0			//set to 1 to recalculate always the FF. 
#define UseXOPforFFCalcs					//comment out to prevent use of xops

//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.29 remove Unified fit form factors from form factor listings, code stays, but shoudl not be used anymore. Let's see if someone complains. 
//2.28 added controls for debugging (at the top) and added Cylinder and Spheroid as optional XOP form factor.
//2.27 fixed IR1T_CreateAveVolumeWave, IR1T_CreateAveSurfaceAreaWave  to have all form factors, do nto foget to fix next time when adding new FF
//2.26 added Rectangular Parallelepiped (cuboid and other similar shapes) USING NIST XOP - IF the XOP is installed, Parallelpiped is available. Fast, need to convert more FFs to this... 
//2.25 fixed minor glitch when some form factor screen could be initiealized with nan as parameter name, which causes major problems numbericaly for AUtoupdate settings. 
//2.24 added support for "No fitting limits" GUI option.
//2.23 Added CoreShellPrecipitate FF
//2.22 Significantly reduced the form factors availabe to Size distribution tool. Complicated FF make no sense. 
//2.21 FIxed Janus FF micelle and added version 3 - core as particle shape
//2.20 Added Form and Structure factor description as Igor Help file. 
//2.19 removed algebraic form factor and added Janus Core Shell micelles, added special list of form factor for Size Distribution, which cannot handle complex shapes (and should not)... 
//2.18 added SphereWHSLocMonoSq - requested by masato, this is sphere with Hard spheres Percus-Yevic structure factor which has distance which is related linearly to size of the sphere itself. 
//2.17 changed old obsolete BessJ into Besselj - newer implementation in Igor Pro
//2.16 COreShellCylinder should now be multicore
//2.15 fixed check for no change, when for cases with very few points in R (less than 5) the check was failing. 
//2.14 Converted much of the code to thread safe functions to increase speed, reduced number of point in cylinder integration to 181 from 500, seemed too much. Changed all temp waves to /free
//2.13 added Core-shell-shell FF
//2.12 removed minor bug in Cylinder FF
//2.11 added license for ANL

//	note to myself: when adding Form factor, fix also :
		//IR1T_CreateAveSurfaceAreaWave
		//IR1T_CreateAveVolumeWave
//

//this is utility package providing various form factors to be used by Standard model package and Sizes
//this package provides function which generates "G" matrix
//the functions are called IR1T_
//the G matrix is related to measured intensities as:
//	MatrixOp/O Intensity =G_matrix x Model 
// provides also control panel to control the parameters for form factors:
//	Function IR1T_MakeFFParamPanel(TitleStr,FFStr,P1Str,FitP1Str,LowP1Str,HighP1Str,P2Str,FitP2Str,LowP2Str,HighP2Str,P3Str,FitP3Str,LowP3Str,HighP3Str,P4Str,FitP4Str,LowP4Str,HighP4Str,P5Str,FitP5Str,LowP5Str,HighP5Str,FFUserFFformula,FFUserVolumeFormula)
//		example of call to the panel:
//Macro TestPanel()
//
//	string TitleStr="Test FF panel"
//	string FFStr="root:Packages:IR2L_NLSQF:FormFactor_pop1"
//	string P1Str="root:Packages:IR2L_NLSQF:FormFactor_Param1_pop1"
//	string FitP1Str="root:Packages:IR2L_NLSQF:FormFactor_FitParam1_pop1"
//	string LowP1Str="root:Packages:IR2L_NLSQF:FormFactor_LowLimParam1_pop1"
//	string HighP1Str="root:Packages:IR2L_NLSQF:FormFactor_HighLimParam1_pop1"
//	string P2Str="root:Packages:IR2L_NLSQF:FormFactor_Param2_pop1"
//	string FitP2Str="root:Packages:IR2L_NLSQF:FormFactor_FitParam2_pop1"
//	string LowP2Str="root:Packages:IR2L_NLSQF:FormFactor_LowLimParam2_pop1"
//	string HighP2Str="root:Packages:IR2L_NLSQF:FormFactor_HighLimParam2_pop1"
//	string P3Str="root:Packages:IR2L_NLSQF:FormFactor_Param3_pop1"
//	string FitP3Str="root:Packages:IR2L_NLSQF:FormFactor_FitParam3_pop1"
//	string LowP3Str="root:Packages:IR2L_NLSQF:FormFactor_LowLimParam3_pop1"
//	string HighP3Str="root:Packages:IR2L_NLSQF:FormFactor_HighLimParam3_pop1"
//	string P4Str="root:Packages:IR2L_NLSQF:FormFactor_Param4_pop1"
//	string FitP4Str="root:Packages:IR2L_NLSQF:FormFactor_FitParam4_pop1"
//	string LowP4Str="root:Packages:IR2L_NLSQF:FormFactor_LowLimParam4_pop1"
//	string HighP4Str="root:Packages:IR2L_NLSQF:FormFactor_HighLimParam4_pop1"
//	string P5Str="root:Packages:IR2L_NLSQF:FormFactor_Param5_pop1"
//	string FitP5Str="root:Packages:IR2L_NLSQF:FormFactor_FitParam5_pop1"
//	string LowP5Str="root:Packages:IR2L_NLSQF:FormFactor_LowLimParam5_pop1"
//	string HighP5Str="root:Packages:IR2L_NLSQF:FormFactor_HighLimParam5_pop1"
//	string FFUserFFformula="root:Packages:IR2L_NLSQF:FFUserFFformula_pop1"
//	string FFUserVolumeFormula="root:Packages:IR2L_NLSQF:FFUserVolumeFormula_pop1"
//		
//
// 
// 	IR1T_MakeFFParamPanel(TitleStr,FFStr,P1Str,FitP1Str,LowP1Str,HighP1Str,P2Str,FitP2Str,LowP2Str,HighP2Str,P3Str,FitP3Str,LowP3Str,HighP3Str,P4Str,FitP4Str,LowP4Str,HighP4Str,P5Str,FitP5Str,LowP5Str,HighP5Str,FFUserFFformula,FFUserVolumeFormula)
//
//end


// utility functions....
// 	 IR1T_CreateAveSurfaceAreaWave(AveSurfaceAreaWave,Distdiameters,DistShapeModel,Par1,Par2,Par3,Par4,Par5,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)
//creates wave with surface area of particles using the shape (note, some are not supported and return Nan). Returns it in cm2. Used to create specific surface area of the scatterers... 
//check the function for weird shapes (such as tubes and core shells... 
//
// 	 IR1T_CreateAveVolumeWave(AveVolumeWave,Distdiameters,DistShapeModel,Par1,Par2,Par3,Par4,Par5,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)
//cretaes wave with volume of one particle using the shape. SOme are not meaningfull. returns number in cm3. Used to convert volume and number distributions..
// 
// this function returns name of parameter for given form factor:
// IR1T_IdentifyFFParamName(FormFactorName,ParameterOrder) 
// it is text function... 

static constant JanusCoreShellMicNumIngtPnts=66		//weird, with 40 there are specific radii where code fails to produces NaN
//static constant PerpParallelepipedPnts=180

Function IR1T_InitFormFactors()
	//here we initialize the form factor calculations
	
	string OldDf=GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:FormFactorCalc
	
	//string/g ListOfFormFactors="Spheroid;Cylinder;CylinderAR;CoreShell;CoreShellShell;CoreShellCylinder;User;Integrated_Spheroid;Unified_Sphere;Unified_Rod;Unified_RodAR;Unified_Disk;Unified_Tube;Fractal Aggregate;"
	string/g ListOfFormFactors="Spheroid;Cylinder;CylinderAR;CoreShell;CoreShellShell;CoreShellCylinder;User;Integrated_Spheroid;Fractal Aggregate;"
	ListOfFormFactors+="NoFF_setTo1;SphereWHSLocMonoSq;Janus CoreShell Micelle 1;Janus CoreShell Micelle 2;Janus CoreShell Micelle 3;CoreShellPrecipitate;"//"
#if (exists("ParallelepipedX")&&defined(UseXOPforFFCalcs))
	ListOfFormFactors+="---NIST XOP : ;RectParallelepiped;"
#endif	
	string/g ListOfFormFactorsSD="Spheroid;Cylinder;CylinderAR;"//Unified_Sphere;Unified_Rod;Unified_RodAR;Unified_Disk;Unified_Tube;"
	string/g CoreShellVolumeDefinition
	SVAR CoreShellVolumeDefinition			//this will be user choice for definition of volume of core shell particle: "Whole particle;Core;Shell;", NIST standard definition is Whole particle, default... 
	if(strlen(CoreShellVolumeDefinition)<1)
		CoreShellVolumeDefinition="Whole particle"
	endif
	SVAR ListOfFormFactors=root:Packages:FormFactorCalc:ListOfFormFactors
	setDataFolder OldDf
end

//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************
//*******************************************************************************************************************************************************************


Function IR2T_LoadFFDescription()

	//try to open Igor help file first and only if that fails call pdf file...
	DisplayHelpTopic /Z "Form Factors & Structure factors"
	if(V_Flag)

		string WhereIsManual
		string WhereAreProcedures=RemoveEnding(FunctionPath(""),"IR1_FormFactors.ipf")
		String manualPath = ParseFilePath(5,"FormFactorList.pdf","*",0,0)
       	String cmd 
		if (stringmatch(IgorInfo(3), "*Macintosh*"))
	             //  manualPath = "User Procedures:Irena:Irena manual.pdf"
	               sprintf cmd "tell application \"Finder\" to open \"%s\"",WhereAreProcedures+manualPath
	               ExecuteScriptText cmd
	      		if (strlen(S_value)>2)
	//			DoAlert 0, S_value
			endif	
		else 
			//manualPath = "User Procedures\Irena\Irena manual.pdf"
			//WhereIsIgor=WhereIsIgor[0,1]+"\\"+IN2G_ChangePartsOfString(WhereIsIgor[2,inf],":","\\")
			WhereAreProcedures=ParseFilePath(5,WhereAreProcedures,"*",0,0)
			whereIsManual = "\"" + WhereAreProcedures+manualPath+"\""
			NewNotebook/F=0 /N=NewBatchFile
			Notebook NewBatchFile, text=whereIsManual//+"\r"
			SaveNotebook/O NewBatchFile as SpecialDirPath("Temporary", 0, 1, 0 )+"StartFormFactors.bat"
			KillWIndow/Z NewBatchFile
			ExecuteScriptText "\""+SpecialDirPath("Temporary", 0, 1, 0 )+"StartFormFactors.bat\""
		endif
	else
		//help file found, but let's make sure it is visible
		DoIgorMenu "Control", "Retrieve Window"
	endif
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//end

//comments:
//	testing validity of the form factors - useing NIST form factors. 
//   10/28/2004 tested:
	// cylinder. Works great. tested for R=20A and length between 400 and 4000 A. Matches exactly, so differences at higher aspect ratios when my model is sharper... 
	// sphere... Works great, exactly over whole q range
	// spheroid & integrated_spheroid
				// For AR>1 (tested 20) works, there are some differences at high Q range... But at low and medium Qs the shape is exact. 
				// For AR<1 (tested 0.05) is significantly different... <<<<<<<<<<Need to look into this.
	//algebraic_rods   well, I personally do nto liek this, but it seems to work more or less...
	
// do nto forget to fix also : Function IR1_CreateAveVolumeWave(AveVolumeWave,Distdiameters,DistShapeModel,DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)
// this one is in the direct modeling and needs to be fixed right...
	

Function IR1T_GenerateGMatrix(Gmatrix,Q_vec,R_dist,VolumePower,ParticleModel,ParticlePar1,ParticlePar2,ParticlePar3,ParticlePar4,ParticlePar5, User_FormFactorFnct, User_FormFactorVol,[ParticlePar6,ParticlePar7,ParticlePar8,ParticlePar9,ParticlePar10])
		Wave Gmatrix		//result, will be checked if it is needed to recalculate, redimensioned and reculated, if necessary
		Wave Q_vec			//Q vectors, in A-1
		Wave R_dist			//radia in A
		variable VolumePower	//if rest of the code uses volume distribution, set to 1, if number distribution, use 2 (1: G=V*F^2; 2: G=V^2*F^2)
		string ParticleModel	//one of known Particle models
		variable ParticlePar1,ParticlePar2,ParticlePar3,ParticlePar4,ParticlePar5	//possible parameters, let's hope no one needs more than 5
		string User_FormFactorFnct, User_FormFactorVol						//these contain names for user form factor functions  
		variable ParticlePar6,ParticlePar7,ParticlePar8,ParticlePar9,ParticlePar10   //Optional parameters when needed... 
		
		//parameters description:
		//spheroid				AspectRatio = ParticlePar1
		//Integrated_Spheroid		AspectRatio=ParticlePar1
		//Algebraic_Globules		AspectRatio = ParticlePar1
		//Algebraic_Rods			AspectRatio = ParticlePar1, AR > 10
		//Algebraic_Disks			AspectRatio = ParticlePar1, AR < 0.1

		//Unified_Sphere			none needed

		//Cylinder				Length=ParticlePar1
		//CylinderAR				AspectRatio=ParticlePar1
		//Unified_Disk			thickness = ParticlePar1
		//Unified_Rod				length = ParticlePar1
		//Unified_RodAR			AspectRatio = ParticlePar1

		//User					uses user provided functions. There are two userprovided fucntions necessary - F(q,R,par1,par2,par3,par4,par5)
		//						and V(R,par1,par2,par3,par4,par5)
		//						the names for these need to be provided in strings... 
		//						the input is q and R in angstroems 	
		//CoreShellCylinder 					length=ParticlePar1						//length in A
		//						WallThickness=ParticlePar2				//in A
		//						CoreRho=ParticlePar3			// rho for core material
		//						ShellRho=ParticlePar4			// rho for shell material
		//						SolventRho=ParticlePar5			// rho for solvent material
		//CoreShell				CoreShellThickness=ParticlePar1			//skin thickness in Angstroems
		//						CoreRho=ParticlePar2		// rho for core material
		//						ShellRho=ParticlePar3			// rho for shell material
		//						SolventRho=ParticlePar4			// rho for solvent material
		//CoreShellPrecipitate	>>>>> calculated:   CoreShellThickness=ParticlePar1	//skin thickness in Angstroems
		//						CoreRho=ParticlePar2				// rho for core material
		//						ShellRho=ParticlePar3				// rho for shell material
		//						SolventRho=ParticlePar4			// rho for solvent material
		//CoreShell	Shell		CoreShell_1_Thickness=ParticlePar1			//inner shell thickness A
		//						CoreShell_2_Thickness=ParticlePar2			//outer shell thickneess A
		//						SolventRho=ParticlePar3		// rho for solvent material
		//						CoreRho=ParticlePar4			// rho for core material
		//						Shell1Rho=ParticlePar5			// rho for shell 1 material
		//						Shell2Rho=particlePar6			// rho for shell 2 material
		//
		//Janus CoreShell Micelle 1	//particle size is total size of the particle (R0 in the figure in description)
		//							Shell_Thickness=ParticlePar1			//shell thickness A
		//							SolventRho=ParticlePar2		// rho for solvent material
		//							CoreRho=ParticlePar3			// rho for core material
		//							Shell1Rho=ParticlePar4			// rho for shell 1 material
		//							Shell2Rho=particlePar5			// rho for shell 2 material
		//Janus CoreShell Micelle 2	//particle size here is shell thickness!!!
		//							Core_Size=ParticlePar1			// Core radius A
		//							SolventRho=ParticlePar2		// rho for solvent material
		//							CoreRho=ParticlePar3			// rho for core material
		//							Shell1Rho=ParticlePar4			// rho for shell 1 material
		//							Shell2Rho=particlePar5			// rho for shell 2 material
		//Janus CoreShell Micelle 3	//particle size here is core radius!!!
		//							Shell_Thickness=ParticlePar1	// Shell Thickness A
		//							SolventRho=ParticlePar2		// rho for solvent material
		//							CoreRho=ParticlePar3			// rho for core material
		//							Shell1Rho=ParticlePar4			// rho for shell 1 material
		//							Shell2Rho=particlePar5			// rho for shell 2 material
		//RectParallelepiped			//needs side and two scaling paramaters
		//							SideBScale =ParticlePar1		// B = A * P1
		//							SideCScale=ParticlePar2			// C = A * P2
		//CoreShellPrecipitate		sphere with built in Percus yevick Sf
		//							PY length/radius ratio =ParticlePar1
		//							PY volume = ParticlePar2
	
		
		//Fractal aggregate	 	FractalRadiusOfPriPart=ParticlePar1=root:Packages:Sizes:FractalRadiusOfPriPart	//radius of primary particle
		//						FractalDimension=ParticlePar2=root:Packages:Sizes:FractalDimension			//Fractal dimension
		//
		//NoFF_setTo1			no parameter, returns only 1 for every point, for structure factors testing
		//AspectRatio;FractalRadiusOfPriPart;FractalDimension;CylinderLength;CoreShellCylinderLength;
		//CoreShellThicknessRatio;CoreShellContrastRatio;TubeWallThickness;TubeCoreContrastRatio
		//for now...
		
		string OldDf=GetDataFolder(1)
		SetDataFolder root:Packages:FormFactorCalc
		//check the volume multiplier, shoudl be either 1 or 2 or dissasters can happen
		if(!(VolumePower==1) &&!(VolumePower==0) && !(VolumePower==2))
			Abort "Wrong input for volume muliplier in  IR1T_GenerateGMatrix, can be only 0, 1 or 2"
		endif
															//Gmatrix should be M x N points
		variable M=numpnts(Q_vec)
		variable N=numpnts(R_dist)
		variable Recalculate=0
		variable i, currentR, j
		variable tempVal1, tempVal2, tempval3
		string OldNote=note(Gmatrix)
		string NewNote = "", VolDefL=""
		string reason=""
		SVAR CoreShellVolumeDefinition = root:Packages:FormFactorCalc:CoreShellVolumeDefinition
														//let's check, if the G_matrix needs to be recalculated
		if(dimsize(Gmatrix,0)!=M || dimsize(Gmatrix,1)!=N)		//check the dimensions, this needs to be right first
			Recalculate=1
			reason = "Matrix dimension"
		endif
		if(cmpstr(StringByKey("VolumePower", OldNote),num2str(VolumePower))!=0 || cmpstr(StringByKey("ParticleModel", OldNote),ParticleModel)!=0)		//check the model for Particle shape
			Recalculate=1
			reason = "Volume power or Particle model"
		endif
		if(cmpstr(StringByKey("ParticleModel", OldNote),"user")==0 || cmpstr(StringByKey("ParticleModel", OldNote),"User")==0)		//check the model for Particle shape
			if(cmpstr(StringByKey("User_FormFactorFnct", OldNote),User_FormFactorFnct)!=0)
				Recalculate=1
				reason = "User form factor"
			endif
		endif
		if(cmpstr(StringByKey("ParticlePar1", OldNote),num2str(ParticlePar1))!=0 || cmpstr(StringByKey("ParticlePar2", OldNote),num2str(ParticlePar2))!=0)		//check the Particle shape parameter 1 and 2
			Recalculate=1
			reason = "Parameter 1 or 2"
		endif
		if(cmpstr(StringByKey("ParticlePar3", OldNote),num2str(ParticlePar3))!=0 || cmpstr(StringByKey("ParticlePar4", OldNote),num2str(ParticlePar4))!=0)		//check the Particle shape parameter 3 and 4
			Recalculate=1
			reason = "Parameter 3 or 4"
		endif
		if(cmpstr(StringByKey("ParticlePar5", OldNote),num2str(ParticlePar5))!=0 || cmpstr(StringByKey("ParticlePar6", OldNote),num2str(ParticlePar6))!=0)		//check the Particle shape parameter 5
			Recalculate=1
			reason = "Parameter 5 or 6"
		endif
		if(cmpstr(StringByKey("CoreShellVolumeDefinition", OldNote),CoreShellVolumeDefinition)!=0 )		//check the CoreShellVolumeDefinition
			Recalculate=1
			reason = "CoreShellVolumeDefinition"
		endif
		
		For(i=0;i<floor(numpnts(Q_vec)/5);i+=1)
			if(cmpstr(StringByKey("Qvec_"+num2str(i), OldNote),num2str(Q_vec[i]))!=0 )		//check every 5th Q value written in wave note
				Recalculate=1
				reason = "Qvector value"
			endif
		endfor
		if(cmpstr(StringByKey("R_0", OldNote),num2str(R_dist[0]))!=0)
				Recalculate=1
				reason = "Radius value"
		endif
		For(i=0;i<floor(numpnts(R_dist)/5);i+=1)
			if(cmpstr(StringByKey("R_"+num2str(i), OldNote),num2str(R_dist[i]))!=0 )		//check every 5th R value written in wave note
				Recalculate=1
				reason = "Radius value"
			endif
		endfor
		if(AlwaysRecalculateFF)
				Recalculate=1
				reason = "User choice"
		endif

	if(Recalculate)
			redimension/D/N=(M,N) Gmatrix				//redimension G matrix to right size
			Make/D/O/N=(M) TempWave 					//create temp work wave
		
			//and now we need to do selected form factor, each needs to be separate peice of code...
			variable aspectRatio
			variable FractalRadiusOfPriPart
			variable FractalDimension, thickness
			variable QR, QH, topp, bott, Rd, QRd, sqqt, argument, surchi, rP, Qj, bP, bM, length,WallThickness
			variable CoreShellCoreRho,CoreShellThickness,CoreShellShellRho, CoreShellSolvntRho, Shell_Thickness, Core_Size
			variable CoreContrastRatio, CoreShell_1_Thickness, CoreShell_2_Thickness, Shell1Rho, Shell2Rho, SolventRho, CoreRho
			make /free/D/N=6 CylinderParWv			//note, must be DP
			make /free/D/N=6 SpheroidParWv			//note, must be DP
	

			if (cmpstr(ParticleModel,"Spheroid")==0)							//standard (not integrated) spheroid using medium point approximation
				aspectRatio=ParticlePar1									//Aspect ratio is set by particleparam1
				if ((ParticlePar1<=1.01)&&(ParticlePar1>=0.99))				//actually, this is sphere...
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						IR1T_CalculateSphereFormFactor(TempWave,Q_vec,currentR)		//here we calculate one column of data
						TempWave*=IR1T_SphereVolume(currentR)^VolumePower			//multiply by volume of sphere^VolumePower
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
				else														//OK, spheroid...
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
#if (Exists("EllipsoidFormX")&&defined(UseXOPforFFCalcs))
					//The input variables are (and output)
						//[0] scale
						//[1] Axis of rotation
						//[2] two equal radii
						//[3] sld ellipsoid
						//[4] sld solvent (A^-2)
						//[5] background (cm^-1)
						//	MultiThread yw = CylinderFormX(cw,xw)
						SpheroidParWv={1,currentR*aspectRatio,currentR,1e-4,0,0}
						MultiThread TempWave = EllipsoidFormX(SpheroidParWv,Q_vec[p])		//includes VOlumePower=1
						if(VolumePower==2)
							MultiThread 	TempWave*=IR1T_SpheroidVolume(currentR,aspectRatio)
						elseif(VolumePower==0)
							MultiThread 	TempWave/=IR1T_SpheroidVolume(currentR,aspectRatio)
						endif
#else
						IR1T_CalcSpheroidFormFactor(TempWave,Q_vec,currentR,aspectRatio)	//here we calculate one column of data
						TempWave*=IR1T_SpheroidVolume(currentR,aspectRatio)^VolumePower		//multiply by volume of spheroid^VolumePower
#endif
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
				endif
			elseif (cmpstr(ParticleModel,"user")==0)						// user, will need more input...
					//here we need to declare (and check for existence) strings with functions for Form factor and volume
						
					String infostr = FunctionInfo(User_FormFactorFnct)
					if (strlen(infostr) == 0)
						Abort "Form factor user function does not exist"
					endif
					if(NumberByKey("N_PARAMS", infostr)!=7 || NumberByKey("RETURNTYPE", infostr)!=4 )
						Abort "Form factor function does not have the right number of parameters or does not return variable"
					endif
					infostr = FunctionInfo(User_FormFactorVol)
					if (strlen(infostr) == 0)
						Abort "Volume function for user form factor does not exist"
					endif
					if(NumberByKey("N_PARAMS", infostr)!=6 || NumberByKey("RETURNTYPE", infostr)!=4)
						Abort "Volume for user form factor does not have the righ number of parameters or does not return variable"
					endif
					string cmd1, cmd2
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						cmd1="TempWave = "+User_FormFactorFnct+"("+GetWavesDataFolder(Q_vec,2)+"[p],"+num2str(currentR)+","+num2str(ParticlePar1)+","+num2str(ParticlePar2)+","+num2str(ParticlePar3)+","+num2str(ParticlePar4)+","+num2str(ParticlePar5)+")"
						cmd2="TempWave*="+User_FormFactorVol+"("+num2str(currentR)+","+num2str(ParticlePar1)+","+num2str(ParticlePar2)+","+num2str(ParticlePar3)+","+num2str(ParticlePar4)+","+num2str(ParticlePar5)+")^"+num2str(VolumePower)
						Execute(cmd1)
						TempWave = TempWave^2
						Execute(cmd2)
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor

			elseif (cmpstr(ParticleModel,"Integrated_Spheroid")==0)			// integrated spheroid using medium point approximation
				aspectRatio=ParticlePar1									//Aspect ratio is set by particleparam1
				if ((aspectRatio<=1.01)&&(aspectRatio>=0.99))				//actually, this is sphere...
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						tempVal1=IR1T_StartOfBinInDiameters(R_dist,i)
						tempVal2=IR1T_EndOfBinInDiameters(R_dist,i)
						multithread TempWave=IR1T_CalculateIntgSphereFFPnts(Q_vec[p],currentR,VolumePower,tempVal1,tempVal2)		//here we calculate one column of data
						//TempWave*=IR1T_SphereVolume(currentR)		//----------	Volume included in the above procedure due to integration
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
				else														//OK, spheroid...
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						tempVal1=IR1T_StartOfBinInDiameters(R_dist,i)
						tempVal2=IR1T_EndOfBinInDiameters(R_dist,i)
						multithread TempWave=IR1T_CalcIntgIntgSpheroidFFPnts(Q_vec[p],currentR,VolumePower,tempVal1,tempVal2,aspectRatio)	//here we calculate one column of data
						//TempWave*=IR1T_SpheroidVolume(currentR,aspectRatio)	//----------	Volume included in the above procedure due to integration
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
				endif
			elseif (cmpstr(ParticleModel,"Cylinder")==0)						// cylinder
				length=ParticlePar1
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						tempVal1=IR1T_StartOfBinInDiameters(R_dist,i)
						tempVal2=IR1T_EndOfBinInDiameters(R_dist,i)
#if (Exists("CylinderFormX")&&defined(UseXOPforFFCalcs))
					//The input variables are (and output)
						//[0] scale
						//[1] cylinder RADIUS (A)
						//[2] total cylinder LENGTH (A)
						//[3] sld cylinder (A^-2)
						//[4] sld solvent
						//[5] background (cm^-1)
						//	MultiThread yw = CylinderFormX(cw,xw)
						CylinderParWv={1,currentR,length,1e-4,0,0}
						MultiThread TempWave = CylinderFormX(CylinderParWv,Q_vec[p])		//includes VOlumePower=1
						if(VolumePower==2)
							MultiThread 	TempWave*=IR1T_CylinderVolume(currentR,length)
						elseif(VolumePower==0)
							MultiThread 	TempWave/=IR1T_CylinderVolume(currentR,length)
						endif
#else
						multithread TempWave=IR1_CalcIntgCylinderFFPnts(Q_vec[p],currentR,VolumePower,tempVal1,tempVal2, length)		//here we calculate one column of data
#endif
						//TempWave*=IR1T_SphereVolume(currentR)		//----------	Volume included in the above procedure due to integration
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif (cmpstr(ParticleModel,"SphereWHSLocMonoSq")==0)						// sphere with Hard Spheres locally monodispersed Sq
					//PY length=ParticlePar1
					//PY volume = ParticlePar2
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						IR1_SphereWHSLocMonoSq(TempWave,Q_vec,currentR,ParticlePar1,ParticlePar2,ParticlePar3,ParticlePar4,ParticlePar5)		//here we calculate one column of data
						TempWave*=IR1T_SphereVolume(currentR)^VolumePower			//multiply by volume of sphere^VolumePower
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif (cmpstr(ParticleModel,"CylinderAR")==0)						// cylinder
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						length=2*ParticlePar1*currentR						//and this is length - aspect ratio * currrentR * 2
						tempVal1=IR1T_StartOfBinInDiameters(R_dist,i)
						tempVal2=IR1T_EndOfBinInDiameters(R_dist,i)
#if (Exists("CylinderFormX")&&defined(UseXOPforFFCalcs))
					//The input variables are (and output)
						//[0] scale
						//[1] cylinder RADIUS (A)
						//[2] total cylinder LENGTH (A)
						//[3] sld cylinder (A^-2)
						//[4] sld solvent
						//[5] background (cm^-1)
						//	MultiThread yw = CylinderFormX(cw,xw)
						CylinderParWv={1,currentR,length,1e-4,0,0}
						MultiThread TempWave = CylinderFormX(CylinderParWv,Q_vec[p])		//includes VOlumePower=1
						if(VolumePower==2)
							MultiThread 	TempWave*=IR1T_CylinderVolume(currentR,length)
						elseif(VolumePower==0)
							MultiThread 	TempWave/=IR1T_CylinderVolume(currentR,length)
						endif
#else
						multithread TempWave=IR1_CalcIntgCylinderFFPnts(Q_vec[p],currentR,VolumePower,tempVal1,tempVal2, length)		//here we calculate one column of data
#endif
						//TempWave*=IR1T_SphereVolume(currentR)		//----------	Volume included in the above procedure due to integration
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif (cmpstr(ParticleModel,"Unified_Disk")==0 || cmpstr(ParticleModel,"Unified_Disc")==0)						// Unified disk
				thickness=ParticlePar1
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						TempWave=(IR1T_UnifiedDiskFF(Q_vec[p],currentR,thickness,0,0,0,0 ) )^2
						TempWave*=IR1T_UnifiedDiscVolume(currentR,thickness,0,0,0,0)^VolumePower	
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif (cmpstr(ParticleModel,"Unified_Rod")==0)						// cylinder
				length=ParticlePar1
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						TempWave=(IR1T_UnifiedrodFF(Q_vec[p],currentR,length,0,0,0,0 ) )^2
						TempWave*=IR1T_UnifiedRodVolume(currentR,length,0,0,0,0)^VolumePower		
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif (cmpstr(ParticleModel,"Unified_Tube")==0)						// Unified tube
				length=ParticlePar1
				Thickness=ParticlePar2
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						TempWave=(IR1T_UnifiedtubeFF(Q_vec[p],currentR,length,thickness,0,0,0 ) )^2
						TempWave*=IR1T_UnifiedTubeVolume(currentR,length,thickness,0,0,0)^VolumePower		
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif (cmpstr(ParticleModel,"Unified_RodAR")==0)						// Unified rod
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						length=ParticlePar1*2*currentR						//this is length = 2 * AR * R
						TempWave=(IR1T_UnifiedrodFF(Q_vec[p],currentR,length,0,0,0,0 ) )^2
						TempWave*=IR1T_UnifiedRodVolume(currentR,length,0,0,0,0)^VolumePower		
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif (cmpstr(ParticleModel,"Unified_Sphere")==0)						// Unified sphere
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						TempWave=(IR1T_UnifiedSphereFF(Q_vec[p],currentR,thickness,0,0,0,0 ) )^2
						TempWave*=IR1T_UnifiedsphereVolume(currentR,thickness,0,0,0,0)^VolumePower	
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif (cmpstr(ParticleModel,"RectParallelepiped")==0)						// parralelepiped
#if (Exists("ParallelepipedX")&&defined(UseXOPforFFCalcs))
						make/O/N=7/D RecParallParams
						Make/Free/N=3 RecParallSidePars
						RecParallSidePars={2,2*ParticlePar1,2*ParticlePar2}
						Sort RecParallSidePars, RecParallSidePars
						For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
							currentR=R_dist[i]								//this is current radius
							//	 Input (fitting) variables are:
							//[0] scale factor
							//[1] Edge A (A)
							//[2] Edge B (A)
							//[3] Edge C (A)
							//[4] contrast (A^-2)
							//[5] incoherent background (cm^-1)
							RecParallParams={1e-8,currentR*RecParallSidePars[0],currentR*RecParallSidePars[1],currentR*RecParallSidePars[2],1,0,0}
							MultiThread TempWave = ParallelepipedX(RecParallParams,Q_vec)
							//TempWave=(IR1T_RecParallFormFactor(Q_vec[p],currentR,ParticlePar1,ParticlePar2,0,0,0 ) )^2
							TempWave*=IR1T_RecParallVolume(currentR,ParticlePar1,ParticlePar2,0,0,0)^(VolumePower-1)	//one is already done in the xop. 
							Gmatrix[][i]=TempWave[p]							//and here put it into G wave
						endfor
#else
						DoAlert 0, "The information about NIST xop for form factor calculations is incorrect, please, restart the tool you are using"
						IR1T_InitFormFactors()
#endif
			elseif (cmpstr(ParticleModel,"NoFF_setTo1")==0)						// NoFF_setTo1 - fvor SF testing, returns 1 for ev ery pooint
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]										//this is current radius
						TempWave=(1 )^2
						TempWave*=100^VolumePower	
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif (cmpstr(ParticleModel,"CoreShellCylinder")==0)						// Tube, CoreShellCylinder
				length=ParticlePar1
				WallThickness=ParticlePar2
				CoreShellCoreRho=ParticlePar3			//rho of core
				CoreShellShellRho=ParticlePar4			//rho of shell
				CoreShellSolvntRho=ParticlePar5			//rho of solvent
				make/Free/N=76 w76, z76
				IR1T_Make76GaussPoints(w76, z76)				//setup parameters so the rest is multithreadsafe
				SVAR CoreShellVolumeDefinition = root:Packages:FormFactorCalc:CoreShellVolumeDefinition
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
					//	TempWave=IR1T_CalcIntgTubeFFPoints(Q_vec[p],currentR,VolumePower,IR1_StartOfBinInDiameters(R_dist,i),IR1T_EndOfBinInDiameters(R_dist,i),Length,WallThickness,CoreShellCoreRho,CoreShellShellRho, CoreShellSolvntRho )		//here we calculate one column of data
						 multithread TempWave=IR1T_CalcTubeFFPointsNIST(Q_vec[p],currentR,VolumePower,Length,WallThickness,CoreShellCoreRho,CoreShellShellRho, CoreShellSolvntRho,w76,z76,CoreShellVolumeDefinition )		//here we calculate one column of data
						//multithread
						//TempWave*=IR1T_SphereVolume(currentR)		//----------	Volume included in the above procedure due to integration
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif (cmpstr(ParticleModel,"CoreShell")==0)						
				CoreShellThickness=ParticlePar1			//skin thickness to diameter ratio
				CoreShellCoreRho=ParticlePar2			//rho of core
				CoreShellShellRho=ParticlePar3			//rho of shell
				CoreShellSolvntRho=ParticlePar4			//rho of solvent
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						tempVal1=IR1T_StartOfBinInDiameters(R_dist,i)
						tempVal2=IR1T_EndOfBinInDiameters(R_dist,i)
						SVAR/Z CoreShellVolumeDefinition = root:Packages:FormFactorCalc:CoreShellVolumeDefinition
						if(SVAR_Exists(CoreShellVolumeDefinition))
							VolDefL=CoreShellVolumeDefinition
						else
							VolDefL="Whole Particle"
						endif	
						multithread TempWave=IR1T_CalculateCoreShellFFPoints(Q_vec[p],currentR,VolumePower,tempVal1,tempVal2, CoreShellThickness, CoreShellCoreRho, CoreShellShellRho, CoreShellSolvntRho,VolDefL)								//and here we multiply by N(r)
						//note, the above calculated form factor contains volume^1 in it... So we need to multiply by volume^(power-1) here. Also we use volume of the core for particle volume!!!
						multithread TempWave*=(IR1T_CoreShellVolume(currentR,CoreShellThickness, VolDefL))^(VolumePower-1)				//Multiplication by volume to appropriate power. Here is now the question - what is the volue of this particle? Here the volue is core only... 
						//TempWave*=IR1T_SphereVolume(currentR+CoreShellThickness)^VolumePower	//This means the volue of particle is core + shell...
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif (cmpstr(ParticleModel,"CoreShellPrecipitate")==0)						
				CoreShellCoreRho=ParticlePar2			//rho of core
				CoreShellShellRho=ParticlePar3			//rho of shell
				CoreShellSolvntRho=ParticlePar4			//rho of solvent
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						CoreShellThickness=IR1T_FixCoreShellPrecipitate(currentR,0,CoreShellCoreRho,CoreShellShellRho,CoreShellSolvntRho,2)			//skin thickness calculated by formula... 
						ParticlePar1 = CoreShellThickness
						if(ParticlePar1<0)
							Abort "Negative shell thickness calculated in CoreShell;Precipitate Form factor. Aborting"
						endif
						tempVal1=IR1T_StartOfBinInDiameters(R_dist,i)
						tempVal2=IR1T_EndOfBinInDiameters(R_dist,i)
						VolDefL="Core"
						multithread TempWave=IR1T_CalculateCoreShellFFPoints(Q_vec[p],currentR,VolumePower,tempVal1,tempVal2, CoreShellThickness, CoreShellCoreRho, CoreShellShellRho, CoreShellSolvntRho,VolDefL)								//and here we multiply by N(r)
						//note, the above calculated form factor contains volume^1 in it... So we need to multiply by volume^(power-1) here. Also we use volume of the core for particle volume!!!
						multithread TempWave*=(IR1T_CoreShellVolume(currentR,CoreShellThickness, VolDefL))^(VolumePower-1)				//Multiplication by volume to appropriate power. Here is now the question - what is the volue of this particle? Here the volue is core only... 
						//TempWave*=IR1T_SphereVolume(currentR+CoreShellThickness)^VolumePower	//This means the volue of particle is core + shell...
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif (cmpstr(ParticleModel,"CoreShellShell")==0)						
						CoreShell_1_Thickness=ParticlePar1			//inner shell thickness A
						CoreShell_2_Thickness=ParticlePar2			//outer shell thickneess A
						SolventRho=ParticlePar3		// rho for solvent material
						CoreRho=ParticlePar4			// rho for core material
						Shell1Rho=ParticlePar5			// rho for shell 1 material
						Shell2Rho=particlePar6			// rho for shell 2 material
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						tempVal1=IR1T_StartOfBinInDiameters(R_dist,i)
						tempVal2=IR1T_EndOfBinInDiameters(R_dist,i)
						SVAR/Z CoreShellVolumeDefinition = root:Packages:FormFactorCalc:CoreShellVolumeDefinition
						if(SVAR_Exists(CoreShellVolumeDefinition))
							VolDefL=CoreShellVolumeDefinition
						else
							VolDefL="Whole Particle"
						endif	
						multithread TempWave=IR1T_CalcCoreShellShellFFPoints(Q_vec[p],currentR,VolumePower,tempVal1,tempVal2, CoreShell_1_Thickness,CoreShell_2_Thickness, SolventRho, CoreRho,Shell1Rho, Shell2Rho, VolDefL)								//and here we multiply by N(r)
						//note, the above calculated form factor contains volume^1 in it... So we need to multiply by volume^(power-1) here. Also we use volume of the core for particle volume!!!
						multithread TempWave*=(IR1T_CoreShellVolume(currentR,CoreShell_1_Thickness+CoreShell_2_Thickness,VolDefL))^(VolumePower-1)				//Multiplication by volume to appropriate power. Here is now the question - what is the volue of this particle? Here the volue is core only... 
						//TempWave*=IR1T_SphereVolume(currentR+CoreShellThickness)^VolumePower	//This means the volue of particle is core + shell...
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif(cmpstr(ParticleModel,"Fractal Aggregate")==0)
				//here we calculate Dale's model of fractal aggregates
				FractalRadiusOfPriPart=ParticlePar1						//radius of primary particle
				FractalDimension=ParticlePar2								//Fractal dimension
				For (i=0;i<N;i+=1)											//calculate the G matrix in columns!!!
					currentR=R_dist[i]
//					IR1T_CalcFractAggFormFactor(TempWave,Q_vec,currentR,VolumePower,FractalRadiusOfPriPart,FractalDimension)	//this contains S(Q)*(V(R)*F(Q,R))^2
//					Gmatrix[][i]=TempWave[p]								//and here put it into G wave
					multithread TempWave=IR1T_FractalAggofSpheresFF(Q_vec[p],CurrentR,FractalRadiusOfPriPart,FractalDimension,1,1,1)^2				//DWS 6 2 2005
					multithread TempWave*= IR1T_FractalAggofSpheresVol(CurrentR,FractalRadiusOfPriPart,FractalDimension,1,1,1)^VolumePower		//DWS 6 2 2005
					Gmatrix[][i]=TempWave[p]								//and here put it into G wave
				endfor
			elseif(cmpstr(ParticleModel,"Janus CoreShell Micelle 1")==0)
				//Janus CoreShell Micelle 1	//particle size is total size of the particle (R0 in the figure in description)
				Shell_Thickness=ParticlePar1			//shell thickness A
				SolventRho=ParticlePar5		// rho for solvent material
				CoreRho=ParticlePar2			// rho for core material
				Shell1Rho=ParticlePar3			// rho for shell 1 material
				Shell2Rho=particlePar4			// rho for shell 2 material											
				For (i=0;i<N;i+=1)											//calculate the G matrix in columns!!!
					currentR=R_dist[i]
					multithread TempWave=IR1T_JanusFF(Q_vec[p], CurrentR, CoreRho, Shell1Rho, Shell2Rho, SolventRho,CurrentR-Shell_Thickness)	//this is already ^2
					TempWave*= IR1T_JanusAveContrast(CurrentR-Shell_Thickness, Shell_Thickness, CoreRho, Shell1Rho, Shell2Rho, SolventRho)		//need to crrect for contrast as the above formula 
					//contians only one delta-rho. Average delta-rho seems to fix this... params: Rcore, RShell, RhoCore, RhoA, RhoB, ShoSolv
					multithread TempWave*= IR1T_JanusVp(CurrentR,CoreRho, Shell1Rho, Shell2Rho,CurrentR-Shell_Thickness)^VolumePower			//scale by volume
					Gmatrix[][i]=TempWave[p]								//and here put it into G wave
				endfor
			elseif(cmpstr(ParticleModel,"Janus CoreShell Micelle 2")==0)
				//Janus CoreShell Micelle 2	//particle size here is shell thickness!!!
				Core_Size=ParticlePar1			//Core radius A
				SolventRho=ParticlePar5		// rho for solvent material
				CoreRho=ParticlePar2			// rho for core material
				Shell1Rho=ParticlePar3			// rho for shell 1 material
				Shell2Rho=particlePar4			// rho for shell 2 material											
				For (i=0;i<N;i+=1)											//calculate the G matrix in columns!!!
					currentR=R_dist[i]
					multithread TempWave=IR1T_JanusFF(Q_vec[p], Core_Size+CurrentR, CoreRho, Shell1Rho, Shell2Rho, SolventRho,Core_Size)	//this is already ^2
					TempWave*= IR1T_JanusAveContrast(Core_Size, CurrentR, CoreRho, Shell1Rho, Shell2Rho, SolventRho)//Rcore, RShell, RhoCore, RhoA, RhoB, ShoSolv
					multithread TempWave*= IR1T_JanusVp(Core_Size+CurrentR,CoreRho, Shell1Rho, Shell2Rho,Core_Size)^VolumePower			//scale by volume
					//print IR1T_JanusVp(Core_Size+CurrentR,CoreRho, Shell1Rho, Shell2Rho,Core_Size)
					//multithread TempWave*= IR1T_SphereVolume(Core_Size+CurrentR)^VolumePower			//scale by volume
					Gmatrix[][i]=TempWave[p]								//and here put it into G wave
				endfor
			elseif(cmpstr(ParticleModel,"Janus CoreShell Micelle 3")==0)
				//Janus CoreShell Micelle 3		//particle size here is shell thickness!!!
				Shell_Thickness=ParticlePar1	//Core radius A
				SolventRho=ParticlePar5		// rho for solvent material
				CoreRho=ParticlePar2			// rho for core material
				Shell1Rho=ParticlePar3			// rho for shell 1 material
				Shell2Rho=particlePar4			// rho for shell 2 material											
				variable NormVal
				For (i=0;i<N;i+=1)											//calculate the G matrix in columns!!!
					currentR=R_dist[i]
					NormVal=IR1T_JanusFF(0.00001, CurrentR+Shell_Thickness, CoreRho, Shell1Rho, Shell2Rho, SolventRho,CurrentR)
					multithread TempWave=IR1T_JanusFF(Q_vec[p], CurrentR+Shell_Thickness, CoreRho, Shell1Rho, Shell2Rho, SolventRho,CurrentR)	//this is already ^2
					TempWave*= IR1T_JanusAveContrast(CurrentR, Shell_Thickness, CoreRho, Shell1Rho, Shell2Rho, SolventRho)//Rcore, RShell, RhoCore, RhoA, RhoB, ShoSolv
					multithread TempWave*= IR1T_JanusVp(CurrentR+Shell_Thickness,CoreRho, Shell1Rho, Shell2Rho,CurrentR)^VolumePower			//scale by volume
					//print IR1T_JanusVp(Core_Size+CurrentR,CoreRho, Shell1Rho, Shell2Rho,Core_Size)
					//multithread TempWave*= (IR1T_SphereVolume(CurrentR+Shell_Thickness)^VolumePower)/NormVal 			//scale by volume
					Gmatrix[][i]=TempWave[p]								//and here put it into G wave
				endfor

		else
			Gmatrix[][]=NaN		
		endif
		//conversion to cm... Volume conversion is (10^8)^3   that is 10^24 conversion from A^3 to cm^3. The volume may be here once or twice... 	
		Gmatrix=Gmatrix*(1e-24)^VolumePower												//this is conversion for Volume of particles from A to cm
	//	print "recalculated, reason: "+reason+"  G matrix name: "+NameOfWave(Gmatrix )
	else
	//	print "NOT recalculated"
	
	endif

	//Now write new Note to the Gmatrix
	NewNote = "ParticleModel:"+ParticleModel+";"+"ParticlePar1:"+num2str(ParticlePar1)+";"+"ParticlePar2:"+num2str(ParticlePar2)+";"+"ParticlePar3:"+num2str(ParticlePar3)+";"
	NewNote+= "ParticlePar4:"+num2str(ParticlePar4)+";"+"ParticlePar5:"+num2str(ParticlePar5)+";"+"ParticlePar6:"+num2str(ParticlePar6)+";"+"VolumePower:"+num2str(VolumePower)+";"+"CoreShellVolumeDefinition:"+CoreShellVolumeDefinition+";"
	if(cmpstr(ParticleModel,"user")==0)
		NewNote+= "User_FormFactorFnct:"+User_FormFactorFnct+";"
	endif
	For(i=0;i<floor(numpnts(Q_vec)/5);i+=1)
			NewNote+= "Qvec_"+num2str(i)+":"+num2str(Q_vec[i])+";"		//add every 5th Q value written in wave note
	endfor
	For(i=0;i<floor(numpnts(R_dist)/5);i+=1)
			NewNote+= "R_"+num2str(i)+":"+num2str(R_dist[i])+";"		//add every 5th R value written in wave note
	endfor
	
	//Now, if N=1 (calculation for only single value of R mG matrix should be for simplicity vector, not matrix...
	if(N==1)
		redimension/N=(-1,0) Gmatrix
	endif

	note/K Gmatrix
	note Gmatrix, NewNote
	setDataFolder OldDf

end



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//
//function IR1T_FractalAggofSpheresFF(q,Rcluster,PriParticleRadius,D,par3,par4,par5)//amplitude//dws modified
//	variable q,PriParticleRadius,Rcluster,D,par3,par4,par5
//	variable ,fractalpart,spherepart
//	//Fractalpart=FractalDWS(Q,Rcluster, priradius,D)
//	variable rtiexera
//	rtiexera=(q*PriParticleRadius)^-D
//	rtiexera=rtiexera*D*(exp(gammln(D-1)))
//	rtiexera=rtiexera/((1+(q*Rcluster)^-2)^((D-1)/2))
//	rtiexera=rtiexera*sin((D-1)*atan(q*Rcluster))
//	FractalPart= (1+rtiexera)^.5
//	//FractalPart*=(PriParticleRadius/RCluster)^D//normalize to one
//	SpherePart =IR1T_UniFiedsphereFF(Q,PriParticleRadius,1,1,1,1,1)
//	return fractalpart*spherepart//needs to be squared
//end
//
//function IR1T_FractalAggofSpheresVol(Rcluster,PriParticleRadius,D,par3,par4,par5)//dws added
//	variable PriParticleRadius,Rcluster,D,par3,par4,par5
//	 variable v=(4/3)*pi*(PriParticleRadius^3)
//        v*=(RCluster/PriParticleRadius)^D
//        return v
//end               

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IR1T_RecParallVolume(A,P1,P2,P3,P4,P5)
	Variable A, P1, P2,P3,P4,P5
	//A is size, 
	variable side=2*A   	//size going in is "radius" 
	return side*side*side*P1*P2
end
//*****************************************************************************************************************
static Function IR1T_RecParallSurface(A,P1,P2,P3,P4,P5)
	Variable A, P1, P2,P3,P4,P5
	//A is size, 
	variable side=2*A   	//size going in is "radius" 
	//Surface Area = 2lw + 2lh + 2wh
	return 2*side*side*P1+2*side*side*P2+2*side*side*P1*P2
end
//*****************************************************************************************************************
//
//Function IR1T_RecParallFormFactor(Qv,A,P1,P2,P3,P4,P5)
//	variable Qv,A,P1,P2,P3,P4,P5
//	//size going in is "radius" , formula requires side length, which is radius * 2
//	variable FormFactor=2/pi* IR1T_ParallExtIntegral(Qv,2*A, P1, P2)
//	return FormFactor
//end 
//
////*****************************************************************************************************************
//threadsafe static Function IR1T_Parall_InternalPart(Qv,A2, P1, P2,Alfa,Bta)
//	variable Qv,A2, P1, P2,Alfa,Bta
//	
//	variable sinAlfa=sin(Alfa)
//	variable cosAlfa=cos(Alfa)
//	variable cosBta=cos(Bta)
//	variable sinBta=sin(Bta)
//	variable qa=Qv*A2
//	variable qb=Qv*P1*A2
//	variable qc=Qv*P2*A2	
//	variable result=sinc(qa*sinAlfa*cosBta)
//	result*=sinc(qb*sinAlfa*cosBta)
//	//result*=sin(qb*sinAlfa*cosBta)/(qb*sinAlfa*sinBta)	//tyhis is typo in Pedersen97 manuscript... 
//	result*=sinc(qc*cosAlfa)
//	result*=sinAlfa
//	return result
//end
////*****************************************************************************************************************
//threadsafe static Function IR1T_Parall_IntIntegral(Qv,A2, P1, P2,Bta)
//	variable Qv,A2, P1, P2,Bta
//	
//	make/FREE/N=(PerpParallelepipedPnts) TempIntgWv
//	SetScale/I x, 0, pi/2 , TempIntgWv
//	multithread TempIntgWv=IR1T_Parall_InternalPart(Qv,A2, P1, P2,x,Bta)
//	TempIntgWv[0]=0
//	return area(TempIntgWv)
//end	
////*****************************************************************************************************************
//static Function  IR1T_ParallExtIntegral(Qv,A2, P1, P2)	
//	variable Qv,A2, P1, P2
//	
//	make/FREE/N=(PerpParallelepipedPnts) TempIntgExtWv
//	setScale/I x, 0, pi/2, TempIntgExtWv
//	//multithread TempIntgExtWv = IR1T_Parall_IntIntegral(Qv,A, P1, P2,x)	//here x is beta
//	TempIntgExtWv = IR1T_Parall_IntIntegral(Qv,A2, P1, P2,x)	//here x is beta
//	return area(TempIntgExtWv)
//end	
////*********** end of the code

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//
threadsafe static Function IR1T_CalcCoreShellShellFFPoints(Qvalue,radius,VolumePower,radiusMin,radiusMax, CoreShell_1_Thickness, CoreShell_2_Thickness,SolventRho,CoreRho, Shell1Rho,Shell2Rho,VolDefL)
	variable Qvalue, radius, radiusMin,radiusMax, CoreShell_1_Thickness, CoreShell_2_Thickness,SolventRho,CoreRho, Shell1Rho,Shell2Rho, VolumePower
	string VolDefL
	
	string OldDf=GetDataFolder(1)
//	SetDataFolder root:Packages:FormFactorCalc
	
	variable QR=Qvalue*radius					//OK, these are just some limiting values
	Variable QRMin=Qvalue*radiusMin
	variable QRMax=Qvalue*radiusMax
	variable tempResult
	variable result=0							//here we will stash the results in each point and then divide them by number of points
	variable tempRad
	
	variable numbOfSteps=floor(3+abs((10*(QRMax-QRMin)/pi)))		//depending on relationship between QR and pi, we will take at least 3
	if (numbOfSteps>60)											//steps in QR - and maximum 60 steps. Therefore we will get reaasonable average 
		numbOfSteps=60											//over the QR space. 
	endif
	variable step=(QRMax-QRMin)/(numbOfSteps-1)					//step in QR
	variable stepR=(radiusMax-radiusMin)/(numbOfSteps-1)			//step in R associated with above, we need this to calculate volume
	variable i
	
	For (i=0;i<numbOfSteps;i+=1)									//here we go through number of points in QR (and R)
		QR=QRMin+i*step
		tempRad=radiusMin+i*stepR

		tempResult=(3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))				//calculate sphere scattering factor 
	
		result+=tempResult											//scale by volume add the values together...
	endFor
	result=result/numbOfSteps											//this averages the values obtained over the interval....
	result=result*	(CoreRho - Shell1Rho)						 			//this scales to contrast difference between shell and core
	result=result*(IR1T_SphereVolume(radius))						//multiply by volume of sphere)
	
	//Now add the shell 1 (skin) 
	QRMin=Qvalue*(radiusMin+CoreShell_1_Thickness)
	QRMax=Qvalue*(radiusMax+CoreShell_1_Thickness)
	step=(QRMax-QRMin)/(numbOfSteps-1)	
	stepR=((radiusMax+CoreShell_1_Thickness)-(radiusMin+CoreShell_1_Thickness))/(numbOfSteps-1)
	variable result1=0

	For (i=0;i<numbOfSteps;i+=1)											//here we go through number of points in QR (and R)
		QR=QRMin+i*step
		tempRad=radiusMin+CoreShell_1_Thickness+i*stepR

		tempResult=(3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))				//calculate sphere scattering factor 
	
		result1+=tempResult												//and add the values together...
	endFor
	result1=result1/numbOfSteps												//this averages the values obtained over the interval....
	result1=result1*(Shell1Rho - Shell2Rho)									//this scales to contrast difference between shell and shell2
	result1=result1*(IR1T_SphereVolume(radius+CoreShell_1_Thickness))				//multiply by volume of sphere)
	
	//Now add the shell 2 (skin) 
	QRMin=Qvalue*(radiusMin+CoreShell_1_Thickness+CoreShell_2_Thickness)
	QRMax=Qvalue*(radiusMax+CoreShell_1_Thickness+CoreShell_2_Thickness)
	step=(QRMax-QRMin)/(numbOfSteps-1)	
	stepR=((radiusMax+CoreShell_1_Thickness+CoreShell_2_Thickness)-(radiusMin+CoreShell_1_Thickness+CoreShell_2_Thickness))/(numbOfSteps-1)
	variable result2=0

	For (i=0;i<numbOfSteps;i+=1)											//here we go through number of points in QR (and R)
		QR=QRMin+i*step
		tempRad=radiusMin+CoreShell_1_Thickness+CoreShell_2_Thickness+i*stepR

		tempResult=(3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))				//calculate sphere scattering factor 
	
		result2+=tempResult													//and add the values together...
	endFor
	result2=result2/numbOfSteps										//this averages the values obtained over the interval....
	result2=result2*(Shell2Rho - SolventRho)									//this scales to contrast difference between shell and solvent
	result2=result2*(IR1T_SphereVolume(radius+CoreShell_1_Thickness+CoreShell_2_Thickness))				//multiply by volume of sphere)
	
	variable finalResult=(result + result1+result2)^2											//summ and square them together
	finalResult = finalResult / (IR1T_CoreShellVolume(radius,CoreShell_1_Thickness+CoreShell_2_Thickness,VolDefL))	//scale down volume scaling from above... This assumes the volue of particle is the volume of core ONLY
	setDataFolder OldDf
	
	return finalResult													//and return the value, which is now average over the QR interval.
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//static
threadsafe   Function IR1T_CalculateCoreShellFFPoints(Qvalue,radius,VolumePower,radiusMin,radiusMax, Param1, Param2,Param3,Param4,VolDefL)
	variable Qvalue, radius, radiusMin,radiusMax, Param1, Param2	,Param3,Param4,VolumePower						//does the math for Sphere Form factor function
	string VolDefL
	//Param1 is skin thickness in A  
	//Param2 is core rho (not delta rho squared)
	//Param3 is shell rho (not delta rho squared)
	//Param4 is solvent rho (not delta rho squared)

	//this is first part - core
//	string OldDf=GetDataFolder(1)
//	SetDataFolder root:Packages:FormFactorCalc
	
	variable QR=Qvalue*radius					//OK, these are just some limiting values
	Variable QRMin=Qvalue*radiusMin
	variable QRMax=Qvalue*radiusMax
	variable tempResult
	variable result=0							//here we will stash the results in each point and then divide them by number of points
	variable tempRad
	
	variable numbOfSteps=floor(3+abs((10*(QRMax-QRMin)/pi)))		//depending on relationship between QR and pi, we will take at least 3
	if (numbOfSteps>60)											//steps in QR - and maximum 60 steps. Therefore we will get reaasonable average 
		numbOfSteps=60											//over the QR space. 
	endif
	variable step=(QRMax-QRMin)/(numbOfSteps-1)					//step in QR
	variable stepR=(radiusMax-radiusMin)/(numbOfSteps-1)			//step in R associated with above, we need this to calculate volume
	variable i
	
	For (i=0;i<numbOfSteps;i+=1)									//here we go through number of points in QR (and R)
		QR=QRMin+i*step
		tempRad=radiusMin+i*stepR

		tempResult=(3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))				//calculate sphere scattering factor 
	
		result+=tempResult//* (IR1T_SphereVolume(tempRad))				//scale by volume add the values together...
	endFor
	result=result/numbOfSteps											//this averages the values obtained over the interval....
	result=result*(Param2 - Param3)						 			//this scales to contrast difference between shell and core
	result=result*(IR1T_SphereVolume(radius))						//multiply by volume of sphere)
	
	//Now add the shell (skin) 
	QRMin=Qvalue*(radiusMin+Param1)
	QRMax=Qvalue*(radiusMax+Param1)
	step=(QRMax-QRMin)/(numbOfSteps-1)	
	stepR=((radiusMax+Param1)-(radiusMin+Param1))/(numbOfSteps-1)
	variable result1=0

	For (i=0;i<numbOfSteps;i+=1)									//here we go through number of points in QR (and R)
		QR=QRMin+i*step
		tempRad=radiusMin+Param1+i*stepR

		tempResult=(3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))				//calculate sphere scattering factor 
	
		result1+=tempResult//*(IR1T_SphereVolume(tempRad)) 			//and add the values together...
	endFor
	result1=result1/numbOfSteps										//this averages the values obtained over the interval....
	result1=result1*(Param3 - Param4)									//this scales to contrast difference between shell and solvent
	result1=result1*(IR1T_SphereVolume(radius+Param1))				//multiply by volume of sphere)
	
	variable finalResult=(result + result1)^2											//summ and square them together
	finalResult = finalResult / (IR1T_CoreShellVolume(radius,Param1,VolDefL))				//scale down volume scaling from above... This assumes the volue of particle is the volume of core ONLY
	//note, after this step we have left Volume^1 in the current form factor!!!! result and result1 both contain Volume^1, then they are squared, and we took out only volume^1... 
	
	//this is end of the calculations for form factor... Now we can return, except this form factor contains the contrasts, so future calculations cannot multiply by this form factor...
	//this will be done at higher level... 
//	setDataFolder OldDf
	
	return finalResult													//and return the value, which is now average over the QR interval.
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

threadsafe function  IR1T_UnifiedrodFF(qvalue,radius,length,par2,par3,par4,par5)//calculates  amplitude  may 
        variable qvalue,radius,length,par2,par3,Par4,par5
        variable B2, G2 =1,P2,Rg2,RgCO2, B1, G1,P1,Rg1
        Rg2=sqrt(Radius^2/2+Length^2/12)
        B2=G2*pi/length
        P2=1
        Rg1=sqrt(3)*Radius/2
        RgCO2=Rg1
        G1=2*G2*Radius/(3*Length)
        B1=4*G2*(Length+Radius)/(Radius^3*Length^2)
        P1=4
        variable result = 0
        variable QstarVector=qvalue/(erf(qvalue*Rg2/sqrt(6)))^3
        result=G2*exp(-qvalue^2*Rg2^2/3)+(B2/QstarVector^P2) * exp(-RGCO2^2 * qvalue^2/3)
        QstarVector=qvalue/(erf(qvalue*Rg1/sqrt(6)))^3
        result+=G1*exp(-qvalue^2*Rg1^2/3)+(B1/QstarVector^P1)
    
        return result ^.5
end


threadsafe function  IR1T_UnifiedRodVolume(radius, length,par2,par3,par4,par5)
        variable radius, length,par2,par3,par4,par5
        variable v=pi*(radius^2)*length
        return v
end

threadsafe function  IR1T_UnifiedtubeFF(qvalue, radius, length,thickness,par3,par4,par5)//calculates  amplitude normalized to 1
       variable qvalue, radius, length,thickness,par3,Par4,par5
       variable B3, B2, B1, tubevolume, Rg3,Rg2, Rg1, P3, P2,P1, G3=1
       variable rinner=radius-thickness
       variable dradiisq=radius^2-rinner^2
 	 tubevolume=Pi*dradiisq*length
 	 Rg3=sqrt((length^2)/12+(radius^2-rinner^2)/2)
 	 Rg2=Radius
 	 Rg1=(radius-rinner)
        P3=1
        P2=2
        P1=4
        B1=G3*(2*Pi/tubevolume^2)*((2*Pi*dradiisq)+(2*Pi*length*(radius+rinner)))
 	 B2=G3*Pi^2*(radius-rinner)/tubevolume
 	 B3=G3*Pi/length
        variable result = 0
        variable QstarVector=qvalue/(erf(qvalue*Rg3/sqrt(6)))^3
        result=G3*exp(-qvalue^2*Rg3^2/3)+(B3/QstarVector^P3)*exp(-qvalue^2*Rg2^2/3)
        QstarVector=qvalue/(erf(qvalue*Rg2/sqrt(6)))^3
        result+=(B2/QstarVector^P2)*exp(-qvalue^2*Rg1^2/3)
        QstarVector=qvalue/(erf(qvalue*Rg1/sqrt(6)))^3
        result+=(B1/QstarVector^P1)       
        return result ^.5
      
end

threadsafe function IR1T_UnifiedTubeVolume(radius,length,thickness,par3,par4, par5)
	variable radius, length, thickness, par3, par4, par5
	variable v,rinner=radius-thickness
	 v=pi*(radius^2-rinner^2)*length
	 return v
end


threadsafe function IR1T_UnifiedDiskFF(Q,radius,thickness,par2,par3,par4,par5 )  //calculates amplitude
        variable Q,thickness,radius,par2,par3,par4,par5
     variable B2,G2=1,P2,RgCO2,Rg2,B1,G1,P1,Rg1
      Rg2=sqrt(Radius^2/2+thickness^2/12)
      B2=G2*2/(radius^2)//dws guess
      P2=2
      Rg1=sqrt(3)*thickness/2// Kratky and glatter = Thickness/2
      RgCO2=1.1*Rg1
      G1=2*G2*thickness^2/(3*radius^2)//beaucage not sure how this is  justified, but it works
       B1=4*G2*(thickness+Radius)/(Radius^3*thickness^2)//same as rod
       P1=4
       variable result = 0
        variable QstarVector=Q/(erf(Q*Rg2/sqrt(6)))^3
        result=G2*exp(-Q^2*Rg2^2/3)+(B2/QstarVector^P2) * exp(-RGCO2^2 * Q^2/3)
        QstarVector=Q/(erf(Q*Rg1/sqrt(6)))^3
        result+=G1*exp(-Q^2*Rg1^2/3)+(B1/QstarVector^P1)
        return result^.5
end


threadsafe function IR1T_UnifiedDiscVolume(radius,thickness,par2,par3,par4,par5)
        variable radius, thickness,par2,par3,par4,par5
        variable v=pi*(radius^2)*thickness
        return v
end


threadsafe function  IR1T_UnifiedSphereFF(qvalue,radius,par1,par2,par3,par4,par5)// calculates amplitude
        variable qvalue,radius,par1,par2,par3,par4,par5
       Variable G1=1, P1=4, Rg1=sqrt(3/5)*radius
     //  variable B1=6*pi*G1/((4/3)*Radius^4)
       variable B1=1.62*G1/Rg1^4
        variable QstarVector=qvalue/(erf(qvalue*Rg1/sqrt(6)))^3
        variable result =G1*exp(-qvalue^2*Rg1^2/3)+(B1/QstarVector^P1)
        return (result)^.5//normalized to one
end


threadsafe function IR1T_UnifiedsphereVolume(radius,par1,par2,par3,par4,par5)
        variable radius, par1,par2,par3,par4,par5
        variable v=(4/3)*pi*(radius^3)
        return v
end


//replace starting here********************
 threadsafe Function IR1T_FractalCluster(q,Rcluster,r0,D)//amplitude  Teixeira//not normalized
	variable q,Rcluster,r0,D
	variable rTeixeira
	rTeixeira=(q*r0)^-D
	rTeixeira=rTeixeira*D*(exp(gammln(D-1)))
	rTeixeira=rTeixeira/((1+(q*Rcluster)^-2)^((D-1)/2))
	rTeixeira=rTeixeira*sin((D-1)*atan(q*Rcluster))
	return (1+rTeixeira)^.5
end

 threadsafe function IR1T_FractalAggofSpheresFF(q,Rcluster,PriParticleRadius,D,par3,par4,par5)//calculates amplitude//dws 
	variable q,PriParticleRadius,Rcluster,D,par3,par4,par5
	variable fractalpart,spherepart
	variable rtiexera
	FractalPart=  IR1T_FractalCluster(q,Rcluster,PriParticleRadius,D)
	FractalPart/=(gamma(D+1)*(Rcluster/PriParticleRadius)^D)^.5//normalize to one.  gamma causes problems for Jan
	SpherePart =IR1T_UniFiedsphereFF(Q,PriParticleRadius,1,1,1,1,1)//already normalized to one
	Rtiexera=fractalpart*spherepart
	return Rtiexera// Normalized to one.  intensity~ (gamma(D+1* IR1T_FractalAggofSpheresVol)^2
						//to calculate intensity
end

threadsafe function IR1T_FractalAggofSpheresVol(Rcluster,PriParticleRadius,D,par3,par4,par5)//dws added
	variable PriParticleRadius,Rcluster,D,par3,par4,par5
	variable v=(4/3)*pi*(PriParticleRadius^3)	//vol of one primary
	  v*=(Rcluster/PriParticleRadius)^D//mult by numb er of primaries
        return v
end               

threadsafe function IR1T_FractalAggofRodsFF(Q,Rcluster, persistencelength,radius,D,par4,par5)
	variable Q,radius,persistencelength,rcluster,D,par4,par5
	variable fractalpart,rodpart
	Fractalpart=IR1T_FractalCluster(q,Rcluster,persistencelength,D)//  not normalized this was corrected 3/2008
	FractalPart/=(gamma(D+1)*(Rcluster/persistencelength)^D)^.5//normalize to one at low q
	rodpart =IR1T_UniFiedrodFF(Q,radius,persistencelength,1,1,1,1)//normalized at low q
	return (fractalpart*rodpart)//  Normalized to one.  needs to be squared and multiplied by the  (IR1T_FractalAggofrodsVol)^2
end					//to calculate intensity
	

threadsafe function IR1T_FractalAggofRodsVol(Rcluster,Persistencelength,radius, D,par3,par4)
	variable Persistencelength,Rcluster,D,radius,par3,par4
	variable v=pi*persistencelength*radius^2//vol of one primary
	 v*=(Rcluster/persistencelength)^D//mult by numb er of primaries
        return v
end
	
threadsafe function  IR1T_FractalAggofDisksFF(Q,thickness, persistencelength,Rcluster,D,par4,par5)
	variable Q,thickness, persistencelength,Rcluster,D,par4,par5
	variable fractalpart,diskpart
	Fractalpart=IR1T_FractalCluster(q,Rcluster,persistencelength,D)
	FractalPart/=(gamma(D+1)*(Rcluster/persistencelength)^D)^.5//normalize to one at low q
	diskpart =IR1T_UniFiedDiskFF(Q,persistencelength,thickness,0,0,0,0)
	return fractalpart*diskpart
end

threadsafe function IR1T_FractalAggofDisksVol(Rcluster, thickness,Persistencelength,radius, D,par3,par4)
	variable Rcluster, thickness,Persistencelength,D,radius,par3,par4
	variable v=pi*(persistencelength^2)*thickness//vol of one primary
	 v*=(Rcluster/persistencelength)^D//mult by numb er of primaries	         	
        return v
end

threadsafe function IR1T_FractalAggofTubesFF(Q,Rcluster, persistencelength,radius,D,thickness,par5)//added RSJ 6July2006
	variable Q,radius,persistencelength,rcluster,D,thickness,par5
	variable fractalpart,tubepart
	Fractalpart=IR1T_FractalCluster(q,Rcluster,persistencelength,D)
	FractalPart/=(gamma(D+1)*(Rcluster/persistencelength)^D)^.5//normalize to one at low q
	tubepart =IR1T_UniFiedtubeFF(Q,radius,persistencelength,thickness,1,1,1)
	return (fractalpart*tubepart)//needs to be squared
	
end

threadsafe function IR1T_FractalAggofTubesVol(Rcluster, persistencelength,radius,D,thickness,par5)//added RSJ 6July2006
	variable radius,persistencelength,rcluster,D,thickness,par5
	variable v, rinner
	rinner=radius-thickness
	v=pi*(radius^2-rinner^2)*persistencelength
	 v*=(Rcluster/persistencelength)^D//mult by numb er of primaries	 
	return v
end


////replace end here

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1T_CalcIntgTubeFFPoints(Qvalue,radius,VolumePower,radiusMin,radiusMax,Length,WallThickness,CoreShellCoreRho,CoreShellShellRho, CoreShellSolvntRho)		//we have to integrate from 0 to 1 over cos(th)
	variable Qvalue, radius, Length,radiusMin,radiusMax,WallThickness,CoreShellCoreRho,CoreShellShellRho, CoreShellSolvntRho,VolumePower				//and integrate over points in QR...

	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:FormFactorCalc


	variable QR=Qvalue*radius					//OK, these are just some limiting values
	Variable QRMin=Qvalue*radiusMin
	variable QRMax=Qvalue*radiusMax
	variable tempResult
	variable result=0							//here we will stash the results in each point and then divide them by number of points
	variable CurrentWallThickness
	NVAR/Z WallThicknessSpreadInFract
	if(!NVAR_Exists(WallThicknessSpreadInFract))
		variable/g WallThicknessSpreadInFract
		WallThicknessSpreadInFract=0
	endif
	variable WallThicknessPrecision=WallThickness*WallThicknessSpreadInFract		//let's set this to fraction of wall thickness variation
	variable numbOfSteps=floor(3+abs((10*(QRMax-QRMin)/pi)))		//depending on relationship between QR and pi, we will take at least 3
	if (numbOfSteps>60)											//steps in QR - and maximum 60 steps. Therefore we will get reasonable average 
		numbOfSteps=60											//over the QR space. 
	endif
	variable step=(QRMax-QRMin)/(numbOfSteps-1)					//step in QR
	variable stepR=(radiusMax-radiusMin/2)/(numbOfSteps-1)			//step in R associated with above, we need this to calculate volume
	variable i

	Make/D/O/N=181/Free IntgWave
	SetScale/I x 0,(pi/2),"", IntgWave
	variable tempRad
	SVAR CoreShellVolumeDefinition=CoreShellVolumeDefinition

	For (i=0;i<numbOfSteps;i+=1)									//here we go through number of points in R in the whole interval...

		tempRad=radius+i*stepR
		//include some spread of wall thicknesses here
		CurrentWallThickness=WallThickness//+(WallThicknessPrecision/(numbOfSteps/2))*(i-(numbOfSteps/2))		//this varies diameter within this bin by using bin width to din middle ratio...
		//let's see if this smears out some of the oscillations...
		IntgWave=IR1T_CalcTubeFFPoints(Qvalue,tempRad,Length, CurrentWallThickness,CoreShellCoreRho,CoreShellShellRho, CoreShellSolvntRho,x)	//this calculates for each diameter and Q value wave of results for various theta angles
		IntgWave=IntgWave^2										//get second power of this before integration
		IntgWave=IntgWave*sin(x)										//multiply by sin alpha which is x from 0 to 90 deg
		tempResult= area(IntgWave, 0,(pi/2))					//and here we integrate over alpha

		tempResult=tempResult*(IR1T_TubeVolume(radius,Length, WallThickness, CoreShellVolumeDefinition))^VolumePower			//multiply by volume of shell squared
		result+=tempResult											//and add the values together...
	endFor
	result/=numbOfSteps											//this averages the values obtained over the interval....

	setDataFolder OldDf

	return result

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
threadsafe static  Function IR1T_CalcTubeFFPointsNIST(Qvalue,radius,VolumePower,Length,WallThickness,CoreShellCoreRho,CoreShellShellRho, CoreShellSolvntRho, w76, z76, CoreShellVolumeDefinition)
	variable Qvalue, radius,VolumePower, Length, WallThickness,CoreShellCoreRho,CoreShellShellRho, CoreShellSolvntRho		
	wave w76, z76
	string CoreShellVolumeDefinition
	
	//converted to threadsafe 3/8/2012. What a mess... 
	// This is modified NIST code... Need to change to use their XOP later!!!!
	//They use wave for input, I use variables so here we need to match them together... 
	 
	//The input variables are (and output)
	//[0] scale
	//[1] cylinder CORE RADIUS (A)
	//[2] shell Thickness (A)
	//[3]  cylinder CORE LENGTH (A)
	//[4] core SLD (A^-2)
	//[5] shell SLD (A^-2)
	//[6] solvent SLD (A^-2)
	//[7] background (cm^-1)	
	Variable scale,delrho,bkg,rcore,thick,rhoc,rhos,rhosolv
	scale = 1			//I will scale later myself
	rcore = radius
	thick = WallThickness
	//length = Length
	rhoc = CoreShellCoreRho 
	rhos = CoreShellShellRho 
	rhosolv = CoreShellSolvntRho 
	bkg = 0		//I will add later myself
// local variables
	Variable nord,ii,va,vb,contr,vcyl,nden,summ,yyy,zi,qq,halfheight
	Variable answer
// set up the integration
	// end points and weights
	nord = 76
	va = 0
	vb = Pi/2
      halfheight = length/2.0
// evaluate at Gauss points 
	qq = Qvalue		//current x point is the q-value for evaluation
      summ = 0.0		// initialize integral
      ii=0
      do
		// Using 76 Gauss points
		zi = ( z76[ii]*(vb-va) + vb + va )/2.0		
		yyy = w76[ii] * IR1T_CoreShellcyl(qq, rcore, thick, rhoc,rhos,rhosolv, halfheight, zi)
		summ += yyy 
        	ii+=1
	while (ii<nord)				// end of loop over quadrature points
// calculate value of integral to return
      answer = (vb-va)/2.0*summ
// contrast is now explicitly included in the core-shell calculation
//normalize by cylinder volume
//NOTE that for this (Fournet) definition of the integral, one must MULTIPLY by Vcyl
//calculate TOTAL volume
// length is the total core length 
	vcyl=IR1T_TubeVolume(rcore,length, thick, CoreShellVolumeDefinition)
	answer /= vcyl
	answer *= vcyl^(VolumePower-1)
	Return (answer)


end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1T_CalcTubeFFPoints(Qvalue,radius,Length,WallThickness,CoreShellCoreRho,CoreShellShellRho, CoreShellSolvntRho,Alpha)
	variable Qvalue, radius	, Length, WallThickness,CoreShellCoreRho,CoreShellShellRho, CoreShellSolvntRho,Alpha							//does the math for cylinder Form factor function
	
	variable LargeBesArg=0.5*Qvalue*length*Cos(Alpha)
	variable LargeBes
	if(LargeBesArg<1e-6)
		LargeBes=1
	else
		LargeBes=sin(LargeBesArg)/(LargeBesArg)
	endif
	
	variable SmallBesArg=Qvalue*radius*Sin(Alpha)
	variable SmallBessDivided
	if (SmallBesArg<1e-10)
		SmallBessDivided=0.5
	else
		SmallBessDivided=Besselj(1, SmallBesArg)/SmallBesArg
	endif

	variable LargeBesShellArg=0.5*Qvalue*(length+WallThickness)*Cos(Alpha)
	variable LargeBesShell
	if(LargeBesShellArg<1e-6)
		LargeBesShell=1
	else
		LargeBesShell=sin(LargeBesShellArg)/(LargeBesShellArg)
	endif
	
	variable SmallBesShellArg=Qvalue*(radius+WallThickness)*Sin(Alpha)
	variable SmallBessShellDivided
	if (SmallBesShellArg<1e-10)
		SmallBessShellDivided=0.5
	else
		SmallBessShellDivided=Besselj(1, SmallBesShellArg)/SmallBesShellArg
	endif
	SVAR CoreShellVolumeDefinition = root:Packages:FormFactorCalc:CoreShellVolumeDefinition
	Variable ratioOfVolumes=IR1T_TubeVolume(radius,Length,WallThickness, CoreShellVolumeDefinition)/IR1T_TubeVolume(radius+WallThickness,Length,WallThickness,CoreShellVolumeDefinition )
	

	return 2*ratioOfVolumes*(CoreShellCoreRho-CoreShellShellRho)*(LargeBes*SmallBessDivided)+2*(CoreShellShellRho - CoreShellSolvntRho)*(LargeBesShell*SmallBessShellDivided)
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

threadsafe static Function IR1T_TubeVolume(radius,Length,thick, CoreShellVolumeDefinition)							//returns the tube volume...
	variable radius, Length, thick
	string CoreShellVolumeDefinition
//	SVAR/Z CoreShellVolumeDefinition = root:Packages:FormFactorCalc:CoreShellVolumeDefinition
//	if(!SVAR_exists(CoreShellVolumeDefinition))
		//DoAlert 0, "Please reinitialize the package. CoreShellCylinder definition has changed. Please read Readme.txt"
		//abort
//		return NaN
//	endif
	
	if(stringMatch(CoreShellVolumeDefinition,"Whole Particle"))
		 return  Pi*(radius+thick)*(radius+thick)*(Length+2*thick)
	elseif(stringmatch(CoreShellVolumeDefinition,"Core"))
		return (pi*radius*radius*Length)
	else		//shell only
		return ( Pi*(radius+thick)*(radius+thick)*(Length+2*thick)    -   (pi*radius*radius*Length))
	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

threadsafe  static Function IR1T_CoreShellVolume(radius,thick,CoreShellVolumeDefinition )							//returns the shell volume...
	variable radius, thick
	string CoreShellVolumeDefinition

	if(stringMatch(CoreShellVolumeDefinition,"Whole Particle"))
		 return  (4/3)*Pi*(radius+thick)*(radius+thick)*(radius+thick)
	elseif(stringmatch(CoreShellVolumeDefinition,"Core"))
		return (4/3)*(pi*radius*radius*radius)
	else		//shell only
		return (4/3)*( Pi*(radius+thick)*(radius+thick)*(radius+thick)    -   (pi*radius*radius*radius))
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1T_FixCoreShellPrecipitate(Radius,ShellThick,ContrastCore,ContrastShell,ContrastSolvent,WhichToFix)
	variable Radius,ShellThick,ContrastCore,ContrastShell,ContrastSolvent,WhichToFix
	//WhichToFix = 1 for calculating Shell contrast, 2 for calculating the Shell thickness
	
	variable result, tempVShell
	// IR1T_CoreShellVolume(radius,thick,CoreShellVolumeDefinition )		//CoreShellVolumeDefinition =  "Core", "Whole Particle", "Shell"
	if(WhichToFix==1)		//WhichToFix = 1 for calculating Shell Contrast
		result = (ContrastSolvent*IR1T_CoreShellVolume(radius,ShellThick,"Whole Particle") - ContrastCore*IR1T_CoreShellVolume(radius,ShellThick,"Core"))/IR1T_CoreShellVolume(radius,ShellThick,"Shell" )
	else
		//tempVShell =  (ContrastSolvent*IR1T_CoreShellVolume(radius,ShellThick,"Whole Particle") - ContrastCore*IR1T_CoreShellVolume(radius,ShellThick,"Core"))/ ContrastShell //IR1T_CoreShellVolume(radius,ShellThick,"Shell" )
		tempVShell = IR1T_CoreShellVolume(radius,ShellThick,"Core") *(ContrastSolvent - ContrastCore ) / (ContrastShell - ContrastSolvent)
		result = IR1T_Solve3rdPolyShellVol(tempVShell,Radius)
	endif
	return result	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IR1T_Solve3rdPolyShellVol(Volume,Radius)
	variable Volume,Radius
	
	string OldDf=GetDataFolder(1)
	
	setDataFolder root:Packages:FormFactorCalc	
	variable a, b, c, d, result
	a = 1
	b = 3*Radius
	c = 3* Radius* Radius
	d = -3 * Volume / (4*pi)
	make/Free/N=4 polyCoefWave
	polyCoefWave={d,c,b,a}
	FindRoots/P=polyCoefWave
	Wave/C W_PolyRoots
	variable i 
	result = NaN
	For(i=2;i>=0;i-=1)
		if(imag(W_polyRoots[i])==0)
			result = real(W_polyRoots[i])
		endif
	endfor
	KilLWaves W_polyRoots
	setDataFolder OldDf
	return result
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


threadsafe  static Function IR1_CalcIntgCylinderFFPnts(Qvalue,radius,VolumePower,radiusMin,radiusMax,Length)		//we have to integrate from 0 to 1 over cos(th)
	variable Qvalue, Length,radius,radiusMin,radiusMax,VolumePower				//and integrate over points in QR...

	variable QR=Qvalue*radius				//OK, these are just some limiting values
	Variable QRMin=Qvalue*radiusMin
	variable QRMax=Qvalue*radiusMax
	variable tempResult
	variable result=0							//here we will stash the results in each point and then divide them by number of points
	
	variable numbOfSteps=floor(3+abs((10*(QRMax-QRMin)/pi)))		//depending on relationship between QR and pi, we will take at least 3
	if (numbOfSteps>60)											//steps in QR - and maximum 60 steps. Therefore we will get reaasonable average 
		numbOfSteps=60											//over the QR space. 
	endif
	variable step=(QRMax-QRMin)/(numbOfSteps-1)					//step in QR
	variable stepR=(radiusMax-radiusMin)/(numbOfSteps-1)			//step in R associated with above, we need this to calculate volume
	variable i

	Make/D/O/N=181/FREE IntgWave					//change 8/26/2011: chnaged to /Free and reduced number of point to 181, 500 seems really too much for 90 degrees integration
	SetScale/I x 0,(pi/2),"", IntgWave
	variable tempRad

	For (i=0;i<numbOfSteps;i+=1)											//here we go through number of points in R in the whole interval...

		tempRad=radiusMin+i*stepR

		IntgWave=IR1T_CalcCylinderFFPoints(Qvalue,tempRad,Length, x)		//this calculates for each diameter and Q value wave of results for various theta angles
		IntgWave=IntgWave^2												//get second power of this before integration
		IntgWave=IntgWave*sin(x)											//multiply by sin alpha which is x from 0 to 90 deg
		tempResult=4 * area(IntgWave, 0,(pi/2))								//and here we integrate over alpha

		tempResult*=(IR1T_CylinderVolume(tempRad,Length))^VolumePower		//multiply by volume of cylinder squared
	
		result+=tempResult												//and add the values together...
	endFor
	result/=numbOfSteps													//this averages the values obtained over the interval....

	return result

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

threadsafe static Function IR1T_CalcCylinderFFPoints(Qvalue,radius,Length,Alpha)
	variable Qvalue, radius	, Length, Alpha							//does the math for cylinder Form factor function
	
	variable LargeBesArg=0.5*Qvalue*length*Cos(Alpha)
	variable LargeBes
	if ((LargeBesArg)<1e-6)
		LargeBes=1
	else
		LargeBes=sin(LargeBesArg) / LargeBesArg
	endif
	
	variable SmallBesArg=Qvalue*radius*Sin(Alpha)
	variable SmallBessDivided
	if (SmallBesArg<1e-10)
		SmallBessDivided=0.5
	else
		SmallBessDivided=Besselj(1, SmallBesArg)/SmallBesArg
	endif
	return (LargeBes*SmallBessDivided)

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

threadsafe static Function IR1T_CylinderVolume(radius,Length)							//returns the cylinder volume...
	variable radius, Length
	return (pi*radius*radius*Length)				
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
static  Function IR1T_CalculateSphereFormFactor(FRwave,Qw,radius)	
	Wave Qw,FRwave					//returns column (FRwave) for column of Qw and radius
	Variable radius	
	
	Multithread FRwave=IR1T_CalculateSphereFFPoints(Qw[p],radius)		//calculates the formula 
	FRwave*=FRwave											//second power of the value
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_SphereWHSLocMonoSq(FRwave,Q_vec,Radius,ParticlePar1,ParticlePar2,ParticlePar3,ParticlePar4,ParticlePar5)	
	wave FRwave, Q_vec
	variable Radius,ParticlePar1,ParticlePar2,ParticlePar3,ParticlePar4,ParticlePar5

	Multithread FRwave=IR1T_CalculateSphereFFPoints(Q_vec[p],radius)		//calculates the formula 
	FRwave*=FRwave											//second power of the value

	make/FREE/N=2 PYparams
	PYparams[0] = radius * ParticlePar1			//distance, radius * Param1
	PYparams[1] = ParticlePar2
	Multithread FRwave *= IR2S_HardSphereStruct(PYparams,Q_vec[p])
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

threadsafe static Function IR1T_CalculateIntgSphereFFPnts(Qvalue,Radius,VolumePower,RadiusMin,RadiusMax)
	variable Qvalue, Radius,RadiusMin,RadiusMax,VolumePower							//does the math for Sphere Form factor function

	variable QR=Qvalue*Radius					//OK, these are just some limiting values
	Variable QRMin=Qvalue*RadiusMin
	variable QRMax=Qvalue*RadiusMax
	variable tempResult
	variable result=0							//here we will stash the results in each point and then divide them by number of points
	variable AverageVolume
	variable numbOfSteps=floor(3+abs((10*(QRMax-QRMin)/pi)))		//depending on relationship between QR and pi, we will take at least 3
	if (numbOfSteps>60)											//steps in QR - and maximum 60 steps. Therefore we will get reaasonable average 
		numbOfSteps=60											//over the QR space. 
	endif
	variable step=(QRMax-QRMin)/(numbOfSteps-1)					//step in QR
	variable stepR=(RadiusMax-RadiusMin)/(numbOfSteps-1)			//step in R associated with above, we need this to calculate volume
	variable i, tempRad
	
	For (i=0;i<numbOfSteps;i+=1)									//here we go through number of points in QR (and R)
		QR=QRMin+i*step
		tempRad=RadiusMin+i*stepR

		tempResult=(3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))			//calculate sphere scattering factor 
	
		AverageVolume+=(IR1T_SphereVolume(tempRad))			//calculate average volume of sphere
		result+=tempResult										//and add the values together...
	endFor
	AverageVolume=AverageVolume/numbOfSteps
	result=(result/numbOfSteps)^2 * AverageVolume^VolumePower		//this averages the values obtained over the interval....
	return result													//and return the value, which is now average over the QR interval.
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

threadsafe static  Function IR1T_BinWidthInRadia(R_distribution,i)			//calculates the width in radia by taking half distance to point before and after
	wave R_distribution
	variable i								//returns number in A

	variable width
	variable Imax=numpnts(R_distribution)
	
	if (i==0)
		width=R_distribution[1]-R_distribution[0]
	elseif (i==Imax-1)
		width=R_distribution[i]-R_distribution[i-1]
	else
		width=((R_distribution[i]-R_distribution[i-1])/2)+((R_distribution[i+1]-R_distribution[i])/2)
	endif
	return width
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Static Function IR1T_StartOfBinInDiameters(D_distribution,i)			//calculates the start of the bin in radii by taking half distance to point before and after
	variable i								//returns number in A
	Wave D_distribution
	
	variable start
	variable Imax=numpnts(D_Distribution)
	
	if (i==0)
		start=D_Distribution[0]-(D_Distribution[1]-D_Distribution[0])/2
		if (start<0)
			start=1		//we will enforce minimum size of the scatterer as 1 A
		endif
	elseif (i==Imax-1)
		start=D_Distribution[i]-(D_Distribution[i]-D_Distribution[i-1])/2
	else
		start=D_Distribution[i]-((D_Distribution[i]-D_Distribution[i-1])/2)
	endif
	return start
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1T_EndOfBinInDiameters(D_distribution,i)			//calculates the start of the bin in radii by taking half distance to point before and after
	variable i								//returns number in A
	Wave D_distribution
	
	variable endL
	variable Imax=numpnts(D_distribution)
	
	if (i==0)
		endL=D_distribution[0]+(D_distribution[1]-D_distribution[0])/2
	elseif (i==Imax-1)
		endL=D_distribution[i]+((D_distribution[i+1]-D_distribution[i])/2)
	else
		endL=D_distribution[i]+((D_distribution[i+1]-D_distribution[i])/2)
	endif
	return endL
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************




//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

threadsafe static Function IR1T_SphereVolume(radius)							//returns the sphere...
	variable radius
	return ((4/3)*pi*radius*radius*radius)
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1T_CalcSpheroidFormFactor(FRwave,Qw,radius,AR)	
	Wave Qw,FRwave					//returns column (FRwave) for column of Qw and radius
	Variable radius, AR	
	
	FRwave=IR1T_CalcIntgSpheroidFFPoints(Qw[p],radius,AR)	//calculates the formula 
	// second power needs to be done before integration...FRwave*=FRwave											//second power of the value
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1T_CalcIntgSpheroidFFPoints(Qvalue,radius,AR)		//we have to integrate from 0 to 1 over cos(th)
	variable Qvalue, radius	, AR
	
	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:FormFactorCalc

	Make/O/D/N=50/Free IntgWave
	SetScale/I x 0,1,"", IntgWave
	multithread IntgWave=IR1T_CalcSpheroidFFPoints(Qvalue,radius,AR, x)	//this 
	IntgWave*=IntgWave						//calculate second power before integration, thsi was bug
	variable result= area(IntgWave, 0,1)
	setDataFolder OldDf
	return result
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

threadsafe static  Function IR1T_CalculateSphereFFPoints(Qvalue,radius)
	variable Qvalue, radius										//does the math for Sphere Form factor function
	variable QR=Qvalue*radius

	return (3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

threadsafe static  Function IR1T_CalcSpheroidFFPoints(Qvalue,radius,AR,CosTh)
	variable Qvalue, radius	, AR, CosTh							//does the math for Spheroid Form factor function
	variable QR=Qvalue*radius*sqrt(1+(((AR*AR)-1)*CosTh*CosTh))

	return (3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

threadsafe static  Function IR1T_SpheroidVolume(radius,AspectRatio)							//returns the spheroid volume...
	variable radius, AspectRatio
	return ((4/3)*pi*radius*radius*radius*AspectRatio)				//what is the volume of spheroid?
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

threadsafe static Function IR1T_CalcIntgIntgSpheroidFFPnts(Qvalue,radius,VolumePower,radiusMin,radiusMax,AR)		//we have to integrate from 0 to 1 over cos(th)
	variable Qvalue,  AR,radius,radiusMin,radiusMax,VolumePower				//and integrate over points in QR...

	variable QR=Qvalue*radius					//OK, these are just some limiting values
	Variable QRMin=Qvalue*radiusMin
	variable QRMax=Qvalue*radiusMax
	variable tempResult
	variable result=0							//here we will stash the results in each point and then divide them by number of points
	variable AverageVolume=0
	variable numbOfSteps=floor(3+abs((10*(QRMax-QRMin)/pi)))		//depending on relationship between QR and pi, we will take at least 3
	if (numbOfSteps>60)											//steps in QR - and maximum 60 steps. Therefore we will get reaasonable average 
		numbOfSteps=60											//over the QR space. 
	endif
	variable step=(QRMax-QRMin)/(numbOfSteps-1)					//step in QR
	variable stepR=(radiusMax-radiusMin)/(numbOfSteps-1)			//step in R associated with above, we need this to calculate volume
	variable i
	Make/D/O/N=50/Free IntgWave
	SetScale/P x 0,0.02,"", IntgWave
	variable tempRad

	For (i=0;i<numbOfSteps;i+=1)									//here we go through number of points in R in the whole interval...

		tempRad=radiusMin+i*stepR

		IntgWave=IR1T_CalcSpheroidFFPoints(Qvalue,tempRad,AR, x)	//this calculates for each diameter and Q value wave of results for various theta angles
		IntgWave*=IntgWave											//get second power of this before integration
		//this was bug found on 3/22/2002...
		tempResult= area(IntgWave, 0,1)								//and here we integrate for the theta values

		AverageVolume+=(IR1T_SpheroidVolume(tempRad,AR))			//get average volume of spheroid
	
		result+=tempResult											//and add the values together...
	endFor	
	AverageVolume=AverageVolume/numbOfSteps
	result=(result/numbOfSteps)*AverageVolume^VolumePower						//this averages the values obtained over the interval....
	return result

end



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

threadsafe static  Function IR1T_CalcFractAggFormFactor(FRwave,Qw,currentR,VolumePower,Param1,Param2)	
	Wave Qw,FRwave					//returns column (FRwave) for column of Qw and diameter
	Variable currentR, Param1, Param2,VolumePower
	//Param1 is primary particle radius
	//Param2 is fractal dimension
	
	FRwave=IR1T_CalcSphereFormFactor(Qw[p],(Param1))			//calculates the F(Q,r) * V(r) part fo formula  
																//this is same as for sphere of diameter = 2*Param1 (= radius of primary particle, which is hard sphere)
	FRwave=FRwave^2 * (IR1T_SphereVolume(currentR))^VolumePower				//F^2 multiply by volume of sphere^VolumePower
												
	FRwave=FRwave * IR1T_CalculateFractAggSQPoints(Qw[p],currentR,Param1, Param2)
															//this last part multiplies by S(Q) part of the formula
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


threadsafe static  Function IR1T_CalcSphereFormFactor(QVal,currentR)
		variable Qval, currentR
		
		variable radius=currentR
		variable QR=Qval*radius
		
		variable tempResult
		tempResult=(3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))				//calculate sphere scattering factor 
	
	return tempResult
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


threadsafe static  Function IR1T_CalculateFractAggSQPoints(Qvalue,R,r0, D)
	variable Qvalue, R, r0, D							//does the math for S(Q) factor function
	
	variable QR=Qvalue*R	
	variable tempResult
	
 	   variable part1, part2, part3, part4, part5
	   part1=1
	   part2=(qR*r0/R)^-D
 	   part3=D*(exp(gammln(D-1)))
	   part5= (1+(qR)^-2)^((D-1)/2)
	   part4=abs(sin((D-1)*atan(qR)))
	   
	return (part1+part2*part3*part4/part5)													
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

threadsafe static  Function IR1T_VolumeOfFractalAggregate(FractalRadius, PrimaryPartRadius,Dimension)
	variable FractalRadius, PrimaryPartRadius,Dimension
	
	variable result
	result=((4/3)*pi*PrimaryPartRadius^3)*((FractalRadius/PrimaryPartRadius)^Dimension)*10^(-24)		//solid volume 
//	result=((4/3)*pi*PrimaryPartRadius^3)*10^(-24)
//	result=((4/3)*pi*FractalRadius^3)*10^(-24)
//	result=((4/3)*pi*FractalRadius^3)*10^(-24)				//envelope volume
	return result
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1T_GenerateHelpForUserFF()

	String nb = "HelpForUserFF"
	
	DoWindow HelpForUserFF
	if(!V_Flag)
		NewNotebook/K=1/N=$nb/F=1/V=1/K=0/W=(221.25,52.25,812.5,830) as "HowToUseUserFF"
		Notebook $nb defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
		Notebook $nb showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",10,0,(0,0,0)}
		Notebook $nb ruler=Normal, fSize=12, fStyle=1, text="How to use \"User\" form factor\r"
		Notebook $nb fSize=-1, fStyle=-1, text="\r"
		Notebook $nb text="User contributed form factors you can use are now available on Github:\r"
		Notebook $nb fStyle=4, textRGB=(0,0,65535)
		Notebook $nb text="https://github.com/jilavsky/SAXS_IgorCode/tree/master/User%20form%20factors%20for%20Irena\r"
		Notebook $nb fStyle=-1, textRGB=(0,0,0), text="\r"
		Notebook $nb text="\r"
		Notebook $nb text="To use \"User\" form factor you will need to supply two functions:\r"
		Notebook $nb fStyle=6, text="1. Form factor itself\r"
		Notebook $nb text="2. Volume of particle function\r"
		Notebook $nb fStyle=-1
		Notebook $nb text="Both have to be supplied. Use of form factors which would include volume scaling within is possible, but"
		Notebook $nb text=" MUCH more challenging due to other parts of code. If you  really insist on doing so, contact me and I w"
		Notebook $nb text="ill create rules and explanation.\r"
		Notebook $nb text="\r"
		Notebook $nb text="Both functions must work with radius in Angstroems and Q in inverse Angstroems. \r"
		Notebook $nb fStyle=1, text="Both have to declare following parameters, in following order:\r"
		Notebook $nb fStyle=-1, text="\r"
		Notebook $nb text="Form factor: \tQ, radius, par1,par2,par3,par4,par5\r"
		Notebook $nb text="Volume :\tradius, par1,par2,par3,par4,par5\r"
		Notebook $nb text="\r"
		Notebook $nb text="These function are not required to use these 5 user parameters, but they have to declare them. \r"
		Notebook $nb text="\r"
		Notebook $nb text="\r"
		Notebook $nb fStyle=2, text="Examples for sphere:\r"
		Notebook $nb fStyle=-1
		Notebook $nb text="Function IR1T_ExampleSphereFFPoints(Q,radius, par1,par2,par3,par4,par5)\t//Sphere Form factor\r"
		Notebook $nb text="\tvariable Q, radius, par1,par2,par3,par4,par5\t\t\t\t\t\t\t\t\t\t\t\t\r"
		Notebook $nb text="\tvariable QR=Q*radius\r"
		Notebook $nb text="\treturn (3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))\r"
		Notebook $nb text="end\r"
		Notebook $nb text="\r"
		Notebook $nb text="Function IR1T_ExampleSphereVolume(radius, par1,par2,par3,par4,par5)\t\t//returns the sphere volume\r"
		Notebook $nb text="\tvariable radius, par1,par2,par3,par4,par5\r"
		Notebook $nb text="\r"
		Notebook $nb text="\treturn ((4/3)*pi*radius*radius*radius)\r"
		Notebook $nb text="end\r"
		Notebook $nb text="   "
	else
		DoWindow/F HelpForUserFF
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR1T_ExampleSphereFFPoints(Qvalue,radius, par1,par2,par3,par4,par5)
	variable Qvalue, radius	, par1,par2,par3,par4,par5									//does the math for Sphere Form factor function
	variable QR=Qvalue*radius

	return (3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))
end

Function IR1T_ExampleSphereVolume(radius, par1,par2,par3,par4,par5)							//returns the sphere...
	variable radius, par1,par2,par3,par4,par5
	return ((4/3)*pi*radius*radius*radius)
end

//*****************************************************************************************************************
//*****************************************************************************************************************


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//
//Function IR1T_CreateAveVolumeWave(AveVolumeWave,Distdiameters,DistShapeModel,DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)
//	Wave AveVolumeWave,Distdiameters
//	string DistShapeModel, UserVolumeFnctName
//	variable DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3, UserPar1,UserPar2,UserPar3,UserPar4,UserPar5
//
//	variable i,j
//	variable StartValue, EndValue, tempVolume, tempRadius
//	string cmd2, infostr
//	
//	string OldDf=GetDataFolder(1)
//	setDataFolder root:Packages
//	NewDataFolder/O/S root:Packages:FormFactorCalc
//	variable/g tempVolCalc
//	
//	For (i=0;i<numpnts(Distdiameters);i+=1)
//		StartValue=IR1_StartOfBinInDiameters(Distdiameters,i)
//		EndValue=IR1_EndOfBinInDiameters(Distdiameters,i)
//		tempVolume=0
//		tempVolCalc=0
//
////	string/g ListOfFormFactors="CoreShell;Tube;;;;;;
////
//	//done: 	Unified_Sphere, Spheroid, Integrated_Spheroid, Algebraic_Globules, Algebraic_Disks
//	//	Unified_Disk, Unified_Rod, Algebraic_Rods, Cylinder, CylinderAR, Unified_RodAR, Unified_Tube
//	//	Fractal Aggregate, User
//		For(j=0;j<=50;j+=1)
//			tempRadius=(StartValue+j*(EndValue-StartValue)/50 ) /2
//			if(cmpstr(DistShapeModel,"Unified_sphere")==0)		//spheroid, volume 4/3 pi * r^3 *beta
//				tempVolume+=4/3*pi*(tempRadius^3)
//			elseif(cmpstr(DistShapeModel,"spheroid")==0 ||cmpstr(DistShapeModel,"Integrated_Spheroid")==0)		//spheroid, volume 4/3 pi * r^3 *beta
//				tempVolume+=4/3*pi*(tempRadius^3)*DistScatShapeParam1
//			elseif(cmpstr(DistShapeModel,"Algebraic_Globules")==0)		//globule 4/3 pi * r^3 *beta
//				tempVolume+=4/3*pi*(tempRadius^3)*DistScatShapeParam1
//			elseif(cmpstr(DistShapeModel,"Algebraic_Disks")==0)		//Alg disk, 
//				tempVolume+=2*pi*(tempRadius^3)*DistScatShapeParam1
//			elseif(cmpstr(DistShapeModel,"Unified_Disc")==0 || cmpstr(DistShapeModel,"Unified_rod")==0)		//Uni & rod disk, 
//				tempVolume+=2*pi*(tempRadius^2)*DistScatShapeParam1
//			elseif(cmpstr(DistShapeModel,"Algebraic_Rods")==0)		//Alg rod, 
//				tempVolume+=2*pi*(tempRadius^3)*DistScatShapeParam1
//			elseif(cmpstr(DistShapeModel,"cylinder")==0)		//cylinder volume = pi* r^2 * length
//				tempVolume+=pi*(tempRadius^2)*DistScatShapeParam1
//			elseif(cmpstr(DistShapeModel,"cylinderAR")==0 || cmpstr(DistShapeModel,"Unified_RodAR")==0)		//cylinder volume = pi* r^2 * length
//				tempVolume+=pi*(tempRadius^2)*(2*DistScatShapeParam1*tempRadius)
//			elseif(cmpstr(DistShapeModel,"tube")==0)			//tube volume = pi* (r+tube wall thickness)^2 * length
////this is likely wrong... 
//				tempVolume+=pi*((tempRadius+DistScatShapeParam2)^2)*DistScatShapeParam1
//			elseif(cmpstr(DistShapeModel,"Unifiedtube")==0)			//tube volume = pi* (r+tube wall thickness)^2 * length
//				tempVolume+=IR1T_UnifiedTubeVolume(tempRadius,DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3,1, 1)
//			elseif(cmpstr(DistShapeModel,"coreshell")==0)
//				//In curretn implementation (7/5/2006) we assume volue of particle is the volue of CORE, as we use core diameter(radius) for particle description... 
//				//tempVolume+=4/3*pi*((tempRadius+DistScatShapeParam1)^3)			
//				tempVolume+=4/3*pi*((tempRadius)^3)			
//			elseif(cmpstr(DistShapeModel,"Fractal Aggregate")==0)
//				tempVolume+=IR1T_FractalAggofSpheresVol(tempRadius, DistScatShapeParam1,DistScatShapeParam2, 1, 1, 1)
//			elseif(cmpstr(DistShapeModel,"NoFF_setTo1")==0)
//				tempVolume+=1
//			elseif(cmpstr(DistShapeModel,"User")==0)	
//					infostr = FunctionInfo(UserVolumeFnctName)
//					if (strlen(infostr) == 0)
//						Abort
//					endif
//					if(NumberByKey("N_PARAMS", infostr)!=6 || NumberByKey("RETURNTYPE", infostr)!=4)
//						Abort
//					endif
//				cmd2="root:Packages:SAS_Modeling:tempVolCalc="+UserVolumeFnctName+"("+num2str(tempRadius)+","+num2str(UserPar1)+","+num2str(UserPar2)+","+num2str(UserPar3)+","+num2str(UserPar4)+","+num2str(UserPar5)+")"
//				Execute (cmd2)
//				tempVolume+=tempVolCalc
//			endif		
//		endfor
//		tempVolume/=50				//average
//		tempVolume*=10^(-24)		//conversion from A to cm
//		AveVolumeWave[i]=tempVolume
//	endfor
//	setDataFolder OldDf
//end
//

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR1T_MakeFFParamPanel(TitleStr,FFStr,P1Str,FitP1Str,LowP1Str,HighP1Str,P2Str,FitP2Str,LowP2Str,HighP2Str,P3Str,FitP3Str,LowP3Str,HighP3Str,P4Str,FitP4Str,LowP4Str,HighP4Str,P5Str,FitP5Str,LowP5Str,HighP5Str,FFUserFFformula,FFUserVolumeFormula,[P6Str,FitP6Str,LowP6Str,HighP6Str,P7Str,FitP7Str,LowP7Str,HighP7Str,NoFittingLimits])
	string TitleStr,FFStr,P1Str,FitP1Str,LowP1Str,HighP1Str,P2Str,FitP2Str,LowP2Str,HighP2Str,P3Str,FitP3Str,LowP3Str,HighP3Str,P4Str,FitP4Str,LowP4Str,HighP4Str,P5Str,FitP5Str,LowP5Str,HighP5Str,FFUserFFformula,FFUserVolumeFormula
	string P6Str,FitP6Str,LowP6Str,HighP6Str,P7Str,FitP7Str,LowP7Str,HighP7Str
	variable NoFittingLimits
	//to use this panel, provide strings with paths to controled variables - or "" if the variable does not exist
	
	variable NoFittingLimitsL=0
	if(!ParamIsDefault(NoFittingLimits))	
		NoFittingLimitsL=NoFittingLimits
	endif
	string OldDf=GetDataFolder(1)
	if(!DataFolderExists("root:Packages:FormFactorCalc"))
		IR1T_InitFormFactors()
	endif
	SetDataFolder root:Packages:FormFactorCalc
	SVAR ListOfFormFactors=root:Packages:FormFactorCalc:ListOfFormFactors
	SVAR CoreShellVolumeDefinition=root:Packages:FormFactorCalc:CoreShellVolumeDefinition
	
	KillWIndow/Z FormFactorControlScreen
	SVAR CurFF=$(FFStr)

		NVAR FitP1=$(FitP1Str)
		NVAR FitP2=$(FitP2Str)
		NVAR FitP3=$(FitP3Str)
		NVAR FitP4=$(FitP4Str)
		NVAR FitP5=$(FitP5Str)

	//need to disable usused fitting parameters so the code which is using this package does not have to contain list of form factors... 
	
	//go through all form factors known and set the ones unsused to zeroes...
	if(stringmatch(CurFF,"Unified_Sphere")||stringmatch(CurFF,"NoFF_setTo1"))			//no parameters at all...
		FitP1=0
		FitP2=0
		FitP3=0
		FitP4=0
		FitP5=0
	endif	
 	if(stringmatch(CurFF,"spheroid"))   //these ones use just one parameters, so the others need to be set to 
		FitP2=0
		FitP3=0
		FitP4=0
		FitP5=0
 	elseif(stringmatch(CurFF,"cylinder"))   //these ones use just one parameters, so the others need to be set to 
		FitP2=0
		FitP3=0
		FitP4=0
		FitP5=0
	elseif(stringmatch(CurFF,"SphereWHSLocMonoSq")||stringmatch(CurFF,"RectParallelepiped"))		//uses 2 parameters...
		FitP3=0
		FitP4=0
		FitP5=0
	elseif(stringmatch(CurFF,"CylinderAR"))
		FitP2=0
		FitP3=0
		FitP4=0
		FitP5=0
	elseif(stringmatch(CurFF,"CoreShell"))
		FitP5=0
	elseif(stringmatch(CurFF,"CoreShellPrecipitate"))
		FitP1=0
		FitP5=0
	elseif(stringmatch(CurFF,"CoreShellShell"))

	elseif(stringmatch(CurFF,"CoreShellCylinder"))
	
	elseif(stringmatch(CurFF,"Janus CoreShell Micelle 1"))
	
	elseif(stringmatch(CurFF,"Janus CoreShell Micelle 2"))
	
	elseif(stringmatch(CurFF,"Janus CoreShell Micelle 3"))
	
	elseif(stringmatch(CurFF,"User"))
	
	elseif(stringmatch(CurFF,"Integreated_Spheroid"))
		FitP2=0
		FitP3=0
		FitP4=0
		FitP5=0
	elseif(stringmatch(CurFF,"Unified_Disk"))
		FitP2=0
		FitP3=0
		FitP4=0
		FitP5=0
	elseif(stringmatch(CurFF,"Unified_Rod"))
		FitP2=0
		FitP3=0
		FitP4=0
		FitP5=0
	elseif(stringmatch(CurFF,"Unified_Tube"))
		FitP3=0
		FitP4=0
		FitP5=0
	elseif(stringmatch(CurFF,"Unified_RodAR"))
		FitP2=0
		FitP3=0
		FitP4=0
		FitP5=0
	endif
	if(stringmatch(CurFF,"Fractal aggregate"))   //and now 2 parameters..
		FitP3=0
		FitP4=0
		FitP5=0
	endif

	variable ji
	string tempStr, tempStr2
		NVAR/Z CurVal= $(P1Str)
		if(NVAR_Exists(CurVal) && numtype(CurVal)!=0)		//something si wrong, this should be number, lets set something here as crash prevention
			CurVal = 1
		endif
		NVAR/Z CurVal= $(P2Str)
		if(NVAR_Exists(CurVal) && numtype(CurVal)!=0)		//something si wrong, this should be number, lets set something here as crash prevention
			CurVal = 1
		endif
		NVAR/Z CurVal= $(P3Str)
		if(NVAR_Exists(CurVal) && numtype(CurVal)!=0)		//something si wrong, this should be number, lets set something here as crash prevention
			CurVal = 1
		endif
		NVAR/Z CurVal= $(P4Str)
		if(NVAR_Exists(CurVal) && numtype(CurVal)!=0)		//something si wrong, this should be number, lets set something here as crash prevention
			CurVal = 1
		endif
		NVAR/Z CurVal= $(P5Str)
		if(NVAR_Exists(CurVal) && numtype(CurVal)!=0)		//something si wrong, this should be number, lets set something here as crash prevention
			CurVal = 1
		endif

	if(stringmatch(CurFF,"Unified_Sphere")||stringmatch(CurFF,"NoFF_setTo1"))			//does not need this screen!!!
		setDataFolder OldDf
		abort	
	endif	
	//make the new panel 
	NewPanel/K=1 /W=(96,94,530,370)/N=FormFactorControlScreen as "FormFactorControlScreen"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 3,textrgb= (0,12800,52224)
	DrawText 32,34,TitleStr
	SetDrawEnv fstyle= 1
	DrawText 80,93,"Parameter value"
	SetDrawEnv fstyle= 1
	DrawText 201,93,"Fit?"
	SetDrawEnv fstyle= 1
	DrawText 236,93,"Low limit?"
	SetDrawEnv fstyle= 1
	DrawText 326,93,"High Limit"
	SetWindow FormFactorControlScreen note="NoFittingLimits="+num2str(NoFittingLimits)+";"

	SVAR/Z CurrentFF=$(FFStr)
	if(!SVAR_Exists(CurrentFF))
		Abort "Error in call to FF control panel. Current FF string does not exist. This is bug!"
	endif
	SetVariable FormFactor title="Form factor: ", pos={10,50}, noedit=1, size={300,16},disable=2,frame=0,fstyle=1
	SetVariable FormFactor variable=CurrentFF
	SetVariable FormFactor help={"Form factor to be used"}
	//Unified_Sphere			none needed
	//first variable......
	NVAR/Z CurVal= $(P1Str)
	if(!NVAR_Exists(CurVal))
		Abort "at least one parameter must exist for this shape, bug"
	endif
	SetVariable P1Value,limits={-inf,Inf,0},variable= $(P1Str), proc=IR1T_FFCntrlPnlSetVarProc
	SetVariable P1Value,pos={5,100},size={180,15},title="Aspect ratio = ", help={"Aspect ratio of this shape (Form factor). Larger than 1 is elongated, less than 1 is prolated object"}
	NVAR/Z CurVal= $(FitP1Str)
	NVAR/Z CurVal2= $(LowP1Str)
	NVAR/Z CurVal3= $(HighP1Str)
	
	if (strlen(FitP1Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
		CheckBox FitP1Value,pos={200,100},size={25,16},proc=IR1T_FFCntrlPnlCheckboxProc,title=" "
		CheckBox FitP1Value,variable= $(FitP1Str), help={"Fit this parameter?"}
		NVAR disableMe= $(FitP1Str)
		SetVariable P1LowLim,limits={-inf,Inf,0},variable= $(LowP1Str), disable=(!disableMe||NoFittingLimitsL)
		SetVariable P1LowLim,pos={220,100},size={80,15},title=" ", help={"Low limit for fitting param 1"}
		SetVariable P1HighLim,limits={-inf,Inf,0},variable= $(HighP1Str), disable=(!disableMe||NoFittingLimitsL)
		SetVariable P1HighLim,pos={320,100},size={80,15},title=" ", help={"High limit for fitting param 1"}
	endif
	
	//these we need to rename the parameter 1 only...
	if(stringmatch(CurrentFF,"Cylinder"))
		//Cylinder				Length=ParticlePar1
		SetVariable P1Value, title="Length = ", help={"Length of the cylinder in same units as the radius"} 
	elseif(stringmatch(CurrentFF,"CylinderAR"))
		//CylinderAR				AspectRatio=ParticlePar1
		SetVariable P1Value, title="Aspect ratio = ", help={"Aspect ratio of the cylinder. Length / radius"} 
	elseif(stringmatch(CurrentFF,"Unified_Disk"))
		SetVariable P1Value, title="Thickness = ", help={"Thickness of the disk in same units as radius"} 
	elseif(stringmatch(CurrentFF,"RectParallelepiped"))
		SetVariable P1Value, title="Side B ratio = ", help={"Scaling ratio for side B"} 
	elseif(stringmatch(CurrentFF,"SphereWHSLocMonoSq"))
		SetVariable P1Value, title="Dist/R ratio = ", help={"Ratio of PY nearest neighbor distance to Size of particle"} 
		NVAR tempLowVal=$(LowP1Str)
		tempLowVal=2			//minimum distance possible is 2x radius
	elseif(stringmatch(CurrentFF,"Unified_Rod"))
		SetVariable P1Value, title="Length = ", help={"Length of the rod. Same units as radius"} 
	elseif(stringmatch(CurrentFF,"Unified_Rod"))
		SetVariable P1Value, title="Length = ", help={"Length of the rod. Same units as radius"} 
	elseif(stringmatch(CurrentFF,"Unified_tube"))
		SetVariable P1Value, title="Length = ", help={"Length in angstroems"} 
	elseif(stringmatch(CurrentFF,"Fractal aggregate"))
		SetVariable P1Value, title="Frctl rad. prim part = ", help={"Fractal Radius of primary particle"} 
	elseif(stringmatch(CurrentFF,"Janus CoreShell Micelle 1"))
		SetVariable P1Value, title="Shell thickness [A] = ", help={"Thickness of the shell for Janus CoreShell micelle"} 
	elseif(stringmatch(CurrentFF,"Janus CoreShell Micelle 2"))
		SetVariable P1Value, title="Core radius [A] = ", help={"Radius of core for Janus CoreShell Micelle"} 
	elseif(stringmatch(CurrentFF,"Janus CoreShell Micelle 3"))
		SetVariable P1Value, title="Shell thickness [A] = ", help={"Thickness of the shell for Janus CoreShell micelle"} 
	endif

		//Fractal aggregate	 	FractalRadiusOfPriPart=ParticlePar1=root:Packages:Sizes:FractalRadiusOfPriPart	//radius of primary particle
		//						FractalDimension=ParticlePar2=root:Packages:Sizes:FractalDimension			//Fractal dimension

	if(stringmatch(CurrentFF,"Fractal aggregate")|| stringmatch(CurrentFF,"Unified_Tube") || stringmatch(CurrentFF,"SphereWHSLocMonoSq") || stringmatch(CurrentFF,"RectParallelepiped") )
		NVAR/Z CurVal= $(FitP2Str)
		NVAR/Z CurVal2= $(LowP2Str)
		NVAR/Z CurVal3= $(HighP2Str)
		SetVariable P2Value,limits={-inf,Inf,0},variable= $(P2Str), proc=IR1T_FFCntrlPnlSetVarProc
		SetVariable P2Value,pos={5,120},size={180,15},title="Fractal dimension = ", help={"Fractal dimension"} 
		if (strlen(FitP2Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP2Value,pos={200,120},size={25,16},proc=IR1T_FFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP2Value,variable= $(FitP2Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP2Str)
			SetVariable P2LowLim,limits={-inf,Inf,0},variable= $(LowP2Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P2LowLim,pos={220,120},size={80,15},title=" ", help={"Low limit for fitting param 2"} 
			SetVariable P2HighLim,limits={-inf,Inf,0},variable= $(HighP2Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P2HighLim,pos={320,120},size={80,15},title=" ", help={"High limit for fitting param 2"} 
		endif
	endif
	if(stringmatch(CurrentFF,"Unified_Tube"))
		SetVariable P2Value,title="Wall thickness = ", help={"Wall thickness in A"} 	
	elseif(stringmatch(CurrentFF,"RectParallelepiped"))
		SetVariable P2Value, title="Side C ratio = ", help={"Scaling ratio for side C"} 
	elseif(stringmatch(CurrentFF,"SphereWHSLocMonoSq"))
		SetVariable P2Value,title="PY Fraction = ", help={"volume fraction for Percus Yevic model"} 	
		NVAR tempVal=$(LowP2Str)
		if(tempVal>0.9)
			tempLowVal=0.5
		endif
	endif

	if(stringmatch(CurrentFF,"User") || stringmatch(CurrentFF,"CoreShellCylinder") || stringmatch(CurrentFF,"CoreShell*")|| stringmatch(CurrentFF,"Janus CoreShell Micelle*"))
		//define next 3 parameters ( need at least 4 params for these three...)
		NVAR/Z CurVal= $(FitP2Str)
		NVAR/Z CurVal2= $(LowP2Str)
		NVAR/Z CurVal3= $(HighP2Str)
		SetVariable P2Value,limits={-inf,Inf,0},variable= $(P2Str), proc=IR1T_FFCntrlPnlSetVarProc
		SetVariable P2Value,pos={5,120},size={180,15},title="Fractal dimension = ", help={"Fractal dimension"} 
		if (strlen(FitP2Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP2Value,pos={200,120},size={25,16},proc=IR1T_FFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP2Value,variable= $(FitP2Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP2Str)
			SetVariable P2LowLim,limits={-inf,Inf,0},variable= $(LowP2Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P2LowLim,pos={220,120},size={80,15},title=" ", help={"Low limit for fitting param 2"} 
			SetVariable P2HighLim,limits={-inf,Inf,0},variable= $(HighP2Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P2HighLim,pos={320,120},size={80,15},title=" ", help={"High limit for fitting param 2"} 
		endif

		NVAR/Z CurVal= $(FitP3Str)
		NVAR/Z CurVal2= $(LowP3Str)
		NVAR/Z CurVal3= $(HighP3Str)
		SetVariable P3Value,limits={-inf,Inf,0},variable= $(P3Str), proc=IR1T_FFCntrlPnlSetVarProc
		SetVariable P3Value,pos={5,140},size={180,15},title="Fractal dimension = ", help={"Fractal dimension"} 
		if (strlen(FitP3Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP3Value,pos={200,140},size={25,16},proc=IR1T_FFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP3Value,variable= $(FitP3Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP3Str)
			SetVariable P3LowLim,limits={-inf,Inf,0},variable= $(LowP3Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P3LowLim,pos={220,140},size={80,15},title=" ", help={"Low limit for fitting param 3"} 
			SetVariable P3HighLim,limits={-inf,Inf,0},variable= $(HighP3Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P3HighLim,pos={320,140},size={80,15},title=" ", help={"High limit for fitting param 3"} 
		endif

		NVAR/Z CurVal= $(FitP4Str)
		NVAR/Z CurVal2= $(LowP4Str)
		NVAR/Z CurVal3= $(HighP4Str)
		SetVariable P4Value,limits={-inf,Inf,0},variable= $(P4Str), proc=IR1T_FFCntrlPnlSetVarProc
		SetVariable P4Value,pos={5,160},size={180,15},title="Fractal dimension = ", help={"Fractal dimension"} 
		if (strlen(FitP4Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP4Value,pos={200,160},size={25,16},proc=IR1T_FFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP4Value,variable= $(FitP4Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP4Str)
			SetVariable P4LowLim,limits={-inf,Inf,0},variable= $(LowP4Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P4LowLim,pos={220,160},size={80,15},title=" ", help={"Low limit for fitting param 4"} 
			SetVariable P4HighLim,limits={-inf,Inf,0},variable= $(HighP4Str), disable=(!disableMe||NoFittingLimitsL)
			SetVariable P4HighLim,pos={320,160},size={80,15},title=" ", help={"High limit for fitting param 4"} 
		endif
		
		if(stringmatch(CurrentFF,"CoreShell"))
		//CoreShell				CoreShellThickness=ParticlePar1			//skin thickness in Angstroems
		//						CoreRho=ParticlePar2		// rho for core material
		//						ShellRho=ParticlePar3			// rho for shell material
		//						SolventRho=ParticlePar4			// rho for solvent material
			SetVariable P1Value, title="CoreShellThickness [A]= ", help={"Thickness of the core shell layer in Angstroems"} 
			SetVariable P2Value, title="Core Rho = ", help={"Scattering length density of core"} 
			SetVariable P3Value, title="Shell Rho = ", help={"Scattering length density of shell "} 
			SetVariable P4Value, title="Solvent Rho = ", help={"Solvent Scattering length density"} 		
		endif
		if(stringmatch(CurrentFF,"CoreShellPrecipitate"))
			SetVariable P1Value, title="Shell is calculated = ", help={"Thickness of the shell, linked to contrast"},disable=2
			CheckBox FitP1Value,disable=1
			SetVariable P1LowLim,disable=1
			SetVariable P1HighLim,disable=1
			SetVariable P2Value, title="Core Rho = ", help={"Scattering length density of core"} 
			SetVariable P3Value, title="Shell Rho = ", help={"Scattering length density of shell "} 
			SetVariable P4Value, title="Solvent Rho = ", help={"Solvent Scattering length density"} 		
		endif
		if(stringmatch(CurrentFF,"CoreShellCylinder" ) ||stringmatch(CurrentFF,"CoreShellShell" ) || stringmatch(CurrentFF,"User")||stringmatch(CurrentFF,"Janus CoreShell Micelle*"))
			//add fifth set of values... 
			NVAR/Z CurVal= $(FitP5Str)
			NVAR/Z CurVal2= $(LowP5Str)
			NVAR/Z CurVal3= $(HighP5Str)
			SetVariable P5Value,limits={-inf,Inf,0},variable= $(P5Str), proc=IR1T_FFCntrlPnlSetVarProc
			SetVariable P5Value,pos={5,180},size={180,15},title="Fractal dimension = ", help={"Fractal dimension"} 
			if (strlen(FitP5Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
				CheckBox FitP5Value,pos={200,180},size={25,16},proc=IR1T_FFCntrlPnlCheckboxProc,title=" "
				CheckBox FitP5Value,variable= $(FitP5Str), help={"Fit this parameter?"}
				NVAR disableMe= $(FitP5Str)
				SetVariable P5LowLim,limits={-inf,Inf,0},variable= $(LowP5Str), disable=(!disableMe||NoFittingLimitsL)
				SetVariable P5LowLim,pos={220,180},size={80,15},title=" ", help={"Low limit for fitting param 5"} 
				SetVariable P5HighLim,limits={-inf,Inf,0},variable= $(HighP5Str), disable=(!disableMe||NoFittingLimitsL)
				SetVariable P5HighLim,pos={320,180},size={80,15},title=" ", help={"High limit for fitting param5"} 
			endif		
		endif
		if(stringmatch(CurrentFF,"CoreShellCylinder"))
		//CoreShellCylinder 					length=ParticlePar1						//length in A
		//						WallThickness=ParticlePar2				//in A
		//						CoreRho=ParticlePar3			// rho for core material
		//						ShellRho=ParticlePar4			// rho for shell material
		//						SolventRho=ParticlePar5			// rho for solvent material
			SetVariable P1Value, title="Length [A] = ", help={"Length of CoreShellCylinder in A"} 
			SetVariable P2Value, title="WallThickness [A] = ", help={"Wall thickness"} 
			SetVariable P3Value, title="Core Rho = ", help={"Scattering length density of core "} 
			SetVariable P4Value, title="Shell Rho = ", help={"Shell Scattering length density"} 
			SetVariable P5Value, title="Solvent Rho = ", help={"Solvent Scattering length density"} 
		
		endif
		if(stringmatch(CurrentFF,"Janus CoreShell Micelle*"))
		//CoreShell				CoreShellThickness=ParticlePar1			//skin thickness in Angstroems
		//						CoreRho=ParticlePar2		// rho for core material
		//						ShellRho=ParticlePar3			// rho for shell material
		//						SolventRho=ParticlePar4			// rho for solvent material
			SetVariable P2Value, title="Core Rho = ", help={"Scattering length density of core"} 
			SetVariable P3Value, title="Shell 1 Rho = ", help={"Scattering length density of shell "} 
			SetVariable P4Value, title="Shell 2 Rho = ", help={"Scattering length density of shell "} 		
			SetVariable P5Value, title="Solvent Rho = ", help={"Solvent Scattering length density"} 
		endif
	if(stringmatch(CurrentFF,"User"))
		//User					uses user provided functions. There are two userprovided fucntions necessary - F(q,R,par1,par2,par3,par4,par5)
		//						and V(R,par1,par2,par3,par4,par5)
		//						the names for these need to be provided in strings... 
		//						the input is q and R in angstroems 	
			SetVariable P1Value, title="Param 1 = ", help={"Parameter 1 for this From factor"} 
			SetVariable P2Value, title="Param 2 = ", help={"Parameter 2 for this From factor"} 
			SetVariable P3Value, title="Param 3 = ", help={"Parameter 3 for this From factor "} 
			SetVariable P4Value, title="Param 4 = ", help={"Parameter 4 for this From factor"} 
			SetVariable P5Value, title="Param 5 = ", help={"Parameter 5 for this From factor"} 
			SVAR/Z test1=$(FFUserFFformula)
			SVAR/Z test2=$(FFUserVolumeFormula)
			if(SVAR_Exists(test1) && SVAR_Exists(test2))
				SetVariable FFUserFFformula,variable= $(FFUserFFformula)
				SetVariable FFUserFFformula,pos={5,210},size={380,20},title="Name of FormFactor function ", help={"The name of form factor function (see FF manual!)"}
				SetVariable FFUserVolumeFormula,variable= $(FFUserVolumeFormula)
				SetVariable FFUserVolumeFormula,pos={5,240},size={380,20},title="Name of volume FF function ", help={"The name of factor function calculating the volume of particle (see FF manual!)"}
			endif
		endif

		if(stringmatch(CurrentFF,"CoreShellShell"))
		//CoreShell	Shell		CoreShell_1_Thickness=ParticlePar1			//inner shell thickness A
		//						CoreShell_2_Thickness=ParticlePar2			//outer shell thickneess A
		//						SolventRho=ParticlePar3		// rho for solvent material
		//						CoreRho=ParticlePar4			// rho for core material
		//						Shell1Rho=ParticlePar5			// rho for shell 1 material
		//						Shell2Rho=particlePar6			// rho for shell 2 material
			SetVariable P1Value, title="CoreShell 1 Thickness [A]= ", help={"Thickness of the internal shell layer in Angstroems"} 
			SetVariable P2Value, title="CoreShell 2 Thickness [A]= ", help={"Thickness of the internal shell layer in Angstroems"} 
			SetVariable P3Value, title="Solvent Rho = ", help={"Scattering length density of solvent "} 
			SetVariable P4Value, title="Core Rho = ", help={"Scattering length density of Core"} 
			SetVariable P5Value, title="Shell 1 rho = ", help={"Scattering length density of internal shell"} 
			NVAR/Z CurVal= $(FitP6Str)
			NVAR/Z CurVal2= $(LowP6Str)
			NVAR/Z CurVal3= $(HighP6Str)
			SetVariable P6Value,limits={-inf,Inf,0},variable= $(P6Str), proc=IR1T_FFCntrlPnlSetVarProc
			SetVariable P6Value,pos={5,200},size={180,15},title="Shell 2 rho = ", help={"Scattering length density of external shell"} 
			if (strlen(FitP6Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
				CheckBox FitP6Value,pos={200,200},size={25,16},proc=IR1T_FFCntrlPnlCheckboxProc,title=" "
				CheckBox FitP6Value,variable= $(FitP6Str), help={"Fit this parameter?"}
				NVAR disableMe= $(FitP6Str)
				SetVariable P6LowLim,limits={-inf,Inf,0},variable= $(LowP6Str), disable=(!disableMe||NoFittingLimitsL)
				SetVariable P6LowLim,pos={220,200},size={80,15},title=" ", help={"Low limit for fitting param 5"} 
				SetVariable P6HighLim,limits={-inf,Inf,0},variable= $(HighP6Str), disable=(!disableMe||NoFittingLimitsL)
				SetVariable P6HighLim,pos={320,200},size={80,15},title=" ", help={"High limit for fitting param5"} 
			endif		

		endif

		if(stringmatch(CurrentFF,"CoreShellCylinder")||stringmatch(CurrentFF,"CoreShell")||stringmatch(CurrentFF,"CoreShellShell"))	//special controls for core shell particles... 
			PopupMenu CoreShellVolumeDefinition,pos={20,250},size={180,21},proc=IR1T_FFPanelPopupControl,title="Volume definition:    ", help={"Select what you consider volume of particle"}
			PopupMenu CoreShellVolumeDefinition,mode=1,popvalue=stringFromList(WhichListItem(CoreShellVolumeDefinition, "Whole particle;Core;Shell;" ),"Whole particle;Core;Shell;"),value= "Whole particle;Core;Shell;"
		endif

	endif
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR1T_FFPanelPopupControl(PU_Struct): PopupMenuControl
	STRUCT WMPopupAction &PU_Struct

	if(PU_Struct.eventCode==2)
		SVAR CoreShellVolumeDefinition = root:Packages:FormFactorCalc:CoreShellVolumeDefinition
		CoreShellVolumeDefinition=PU_Struct.popStr
	endif

end

//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR1T_FFCntrlPnlSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable tempValue

	if(stringmatch("P1Value",ctrlName))
		ControlInfo/W=FormFactorControlScreen P1value
		NVAR P1Var=$(S_DataFolder+S_value)
		ControlInfo/W=FormFactorControlScreen P1LowLim
		NVAR P1LowLimVar=$(S_DataFolder+S_value)
		ControlInfo/W=FormFactorControlScreen P1HighLim
		NVAR P1HighLimVar=$(S_DataFolder+S_value)
		P1LowLimVar=0.8 *  P1Var
		P1HighLimVar= 1.2 * P1Var
		if(P1LowLimVar>P1HighLimVar)
			tempValue=P1LowLimVar
			P1LowLimVar=P1HighLimVar
			P1HighLimVar=tempValue
		endif
	endif

	if(stringmatch("P2Value",ctrlName))
		ControlInfo/W=FormFactorControlScreen P2value
		NVAR P2Var=$(S_DataFolder+S_value)
		ControlInfo/W=FormFactorControlScreen P2LowLim
		NVAR P2LowLimVar=$(S_DataFolder+S_value)
		ControlInfo/W=FormFactorControlScreen P2HighLim
		NVAR P2HighLimVar=$(S_DataFolder+S_value)
		P2LowLimVar=0.8 *  P2Var
		P2HighLimVar= 1.2 * P2Var
		if(P2LowLimVar>P2HighLimVar)
			tempValue=P2LowLimVar
			P2LowLimVar=P2HighLimVar
			P2HighLimVar=tempValue
		endif
	endif

	if(stringmatch("P3Value",ctrlName))
		ControlInfo/W=FormFactorControlScreen P3value
		NVAR P3Var=$(S_DataFolder+S_value)
		ControlInfo/W=FormFactorControlScreen P3LowLim
		NVAR P3LowLimVar=$(S_DataFolder+S_value)
		ControlInfo/W=FormFactorControlScreen P3HighLim
		NVAR P3HighLimVar=$(S_DataFolder+S_value)
		P3LowLimVar=0.8 *  P3Var
		P3HighLimVar= 1.2 * P3Var
		if(P3LowLimVar>P3HighLimVar)
			tempValue=P3LowLimVar
			P3LowLimVar=P3HighLimVar
			P3HighLimVar=tempValue
		endif
	endif


	if(stringmatch("P4Value",ctrlName))
		ControlInfo/W=FormFactorControlScreen P4value
		NVAR P4Var=$(S_DataFolder+S_value)
		ControlInfo/W=FormFactorControlScreen P4LowLim
		NVAR P4LowLimVar=$(S_DataFolder+S_value)
		ControlInfo/W=FormFactorControlScreen P4HighLim
		NVAR P4HighLimVar=$(S_DataFolder+S_value)
		P4LowLimVar=0.8 *  P4Var
		P4HighLimVar= 1.2 * P4Var
		if(P4LowLimVar>P4HighLimVar)
			tempValue=P4LowLimVar
			P4LowLimVar=P4HighLimVar
			P4HighLimVar=tempValue
		endif
	endif


	if(stringmatch("P5Value",ctrlName))
		ControlInfo/W=FormFactorControlScreen P5value
		NVAR P5Var=$(S_DataFolder+S_value)
		ControlInfo/W=FormFactorControlScreen P5LowLim
		NVAR P5LowLimVar=$(S_DataFolder+S_value)
		ControlInfo/W=FormFactorControlScreen P5HighLim
		NVAR P5HighLimVar=$(S_DataFolder+S_value)
		P5LowLimVar=0.8 *  P5Var
		P5HighLimVar= 1.2 * P5Var
		if(P5LowLimVar>P5HighLimVar)
			tempValue=P5LowLimVar
			P5LowLimVar=P5HighLimVar
			P5HighLimVar=tempValue
		endif
	endif

	if(stringmatch("P6Value",ctrlName))
		ControlInfo/W=FormFactorControlScreen P6value
		NVAR P6Var=$(S_DataFolder+S_value)
		ControlInfo/W=FormFactorControlScreen P6LowLim
		NVAR P6LowLimVar=$(S_DataFolder+S_value)
		ControlInfo/W=FormFactorControlScreen P6HighLim
		NVAR P6HighLimVar=$(S_DataFolder+S_value)
		P6LowLimVar=0.8 *  P6Var
		P6HighLimVar= 1.2 * P6Var
		if(P6LowLimVar>P6HighLimVar)
			tempValue=P6LowLimVar
			P6LowLimVar=P6HighLimVar
			P6HighLimVar=tempValue
		endif
	endif

	if(stringmatch("P7Value",ctrlName))
		ControlInfo/W=FormFactorControlScreen P7value
		NVAR P7Var=$(S_DataFolder+S_value)
		ControlInfo/W=FormFactorControlScreen P7LowLim
		NVAR P7LowLimVar=$(S_DataFolder+S_value)
		ControlInfo/W=FormFactorControlScreen P7HighLim
		NVAR P7HighLimVar=$(S_DataFolder+S_value)
		P7LowLimVar=0.8 *  P7Var
		P7HighLimVar= 1.2 * P7Var
		if(P7LowLimVar>P7HighLimVar)
			tempValue=P7LowLimVar
			P7LowLimVar=P7HighLimVar
			P7HighLimVar=tempValue
		endif
	endif

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1T_FFCntrlPnlCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:FormFactorCalc
	SVAR ListOfFormFactors=root:Packages:FormFactorCalc:ListOfFormFactors
	GetWindow FormFactorControlScreen note
	variable NoFittingLimits = NumberByKey("NoFittingLimits", S_Value,"=",";")
	if(numtype(NoFittingLimits))
		NoFittingLimits = 0
	endif

//	SVAR FFParamPanelControls=root:Packages:FormFactorCalc:FFParamPanelControls
	string ListOfParams="TitleStr;FFStr;P1Str;FitP1Str;LowP1Str;HighP1Str;P2Str;FitP2Str;LowP2Str;HighP2Str;P3Str;FitP3Str;LowP3Str;HighP3Str;P4Str;FitP4Str;LowP4Str;HighP4Str;P5Str;FitP5Str;LowP5Str;HighP5Str"

	if(stringMatch(ctrlName,"FitP1Value"))
		SetVariable P1LowLim,disable=(!(checked)||NoFittingLimits), win=FormFactorControlScreen
		SetVariable P1HighLim,disable=(!(checked)||NoFittingLimits), win=FormFactorControlScreen
	endif
	if(stringMatch(ctrlName,"FitP2Value"))
		SetVariable P2LowLim,disable=(!(checked)||NoFittingLimits), win=FormFactorControlScreen
		SetVariable P2HighLim,disable=(!(checked)||NoFittingLimits), win=FormFactorControlScreen
	endif
	if(stringMatch(ctrlName,"FitP3Value"))
		SetVariable P3LowLim,disable=(!(checked)||NoFittingLimits), win=FormFactorControlScreen
		SetVariable P3HighLim,disable=(!(checked)||NoFittingLimits), win=FormFactorControlScreen
	endif
	if(stringMatch(ctrlName,"FitP4Value"))
		SetVariable P4LowLim,disable=(!(checked)||NoFittingLimits), win=FormFactorControlScreen
		SetVariable P4HighLim,disable=(!(checked)||NoFittingLimits), win=FormFactorControlScreen
	endif
	if(stringMatch(ctrlName,"FitP5Value"))
		SetVariable P5LowLim,disable=(!(checked)||NoFittingLimits), win=FormFactorControlScreen
		SetVariable P5HighLim,disable=(!(checked)||NoFittingLimits), win=FormFactorControlScreen
	endif
	if(stringMatch(ctrlName,"FitP6Value"))
		SetVariable P6LowLim,disable=(!(checked)||NoFittingLimits), win=FormFactorControlScreen
		SetVariable P6HighLim,disable=(!(checked)||NoFittingLimits), win=FormFactorControlScreen
	endif
	if(stringMatch(ctrlName,"FitP7Value"))
		SetVariable P7LowLim,disable=(!(checked)||NoFittingLimits), win=FormFactorControlScreen
		SetVariable P7HighLim,disable=(!(checked)||NoFittingLimits), win=FormFactorControlScreen
	endif
	if(stringMatch(ctrlName,"FitP8Value"))
		SetVariable P8LowLim,disable=(!(checked)||NoFittingLimits), win=FormFactorControlScreen
		SetVariable P8HighLim,disable=(!(checked)||NoFittingLimits), win=FormFactorControlScreen
	endif

	setDataFolder OldDf

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function/T IR1T_IdentifyFFParamName(FormFactorName,ParameterOrder)
	string FormFactorName
	variable ParameterOrder

	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:FormFactorCalc
	string FFParamName=""
	
	Make/O/T/N=5 Spheroid,Cylinder,CylinderAR,CoreShell,CoreShellCylinder,User,Integrated_Spheroid
	Make/O/T/N=5 Algebraic_Globules,Algebraic_Rods,Algebraic_Disks,Unified_Sphere,Unified_Rod
	Make/O/T/N=5 Unified_RodAR,Unified_Disk,Unified_Tube,'Fractal Aggregate', NoFF_setTo1, CoreShellPrecipitate
	Make/O/T/N=5 SphereWHSLocMonoSq, 'Janus CoreShell Micelle 1','Janus CoreShell Micelle 2','Janus CoreShell Micelle 3' 
	Make/O/T/N=6 CoreShellShell
	
	Spheroid 				= {"Aspect Ratio","","","",""}
	Integrated_Spheroid 	= {"Aspect Ratio","","","",""}
	Algebraic_Globules		= {"Aspect Ratio","","","",""}
	Algebraic_Rods			= {"Aspect Ratio","","","",""}
	Algebraic_Disks		 = {"Aspect Ratio","","","",""}

	Unified_Sphere		= {"","","","",""}
	NoFF_setTo1		={"","","","",""}
	Cylinder			={"Length","","","",""}
	CylinderAR			={"Aspect ratio","","","",""}
	CoreShell			={"Shell thickness","Core rho","Shell rho","Solvent rho",""}
	CoreShellShell		={"Shell 1 thickness","Shell 1 thickness","Solvent rho","Core rho","Shell 1 rho","Shell 2 rho"}
	CoreShellCylinder	= {"Length","Wall thickness","Core rho","Shell rho","Solvant rho"}
	User				= {"User param 1","User param 2","User param 3","User param 4","User param 5"}
	Unified_Rod			= {"Length","","","",""}
	Unified_RodAR		= {"Aspect ratio","","","",""}
	Unified_Disk		= {"Thickness","","","",""}
	Unified_Tube		= {"Length","Thickness","","",""}
	'Fractal Aggregate'	= {"Radius Primary Particle","Fractal dimension","","",""}
	SphereWHSLocMonoSq = {"Dist/R ratio","PY Fraction","","",""}
	'Janus CoreShell Micelle 1' = {"Shell Thickness [A]","Core Rho","Shell 1 Rho","Shell 2 Rho","Solvent Rho"}
	'Janus CoreShell Micelle 2' = {"Core radius [A]","Core Rho","Shell 1 Rho","Shell 2 Rho","Solvent Rho"}
	'Janus CoreShell Micelle 3' = {"Shell Thickness [A]","Core Rho","Shell 1 Rho","Shell 2 Rho","Solvent Rho"}
	CoreShellPrecipitate = {"Shell thickness calc","Core Rho","Shell Rho","Solvent Rho"}
	
	Wave/T/Z Lookup=$(FormFactorName) 
	if(WaveExists(Lookup))
		FFParamName=Lookup[ParameterOrder-1]
	endif
	
	setDataFolder OldDf
	return FFParamName
end



/////*********************************************************************************************************************
/////*********************************************************************************************************************
/////*********************************************************************************************************************
/////*********************************************************************************************************************
/////*********************************************************************************************************************
/////*********************************************************************************************************************

Function IR1T_CreateAveVolumeWave(AveVolumeWave,Distdiameters,DistShapeModel,Par1,Par2,Par3,Par4,Par5,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)
	Wave AveVolumeWave,Distdiameters
	string DistShapeModel, UserVolumeFnctName
	variable Par1,Par2,Par3,Par4,Par5, UserPar1,UserPar2,UserPar3,UserPar4,UserPar5

	variable i,j
	variable StartValue, EndValue, tempVolume, tempRadius
	string cmd2, infostr
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages
	NewDataFolder/O/S root:Packages:FormFactorCalc
	variable/g tempVolCalc
	string VolDefL
	SVAR/Z CoreShellVolumeDefinition = root:Packages:FormFactorCalc:CoreShellVolumeDefinition
	if(SVAR_Exists(CoreShellVolumeDefinition))
		VolDefL=CoreShellVolumeDefinition
	else
		VolDefL="Whole Particle"
	endif	
	
	For (i=0;i<numpnts(Distdiameters);i+=1)
		StartValue=IR1T_StartOfBinInDiameters(Distdiameters,i)
		EndValue=IR1T_EndOfBinInDiameters(Distdiameters,i)
		tempVolume=0
		tempVolCalc=0

		For(j=0;j<50;j+=1)
			tempRadius=(StartValue+j*(EndValue-StartValue)/50 ) /2
			
			if(cmpstr(DistShapeModel,"Unified_sphere")==0 || cmpstr(DistShapeModel,"Algebraic_Spheres")==0)		//spheroid, volume 4/3 pi * r^3 *beta
				tempVolume+=IR1T_UnifiedsphereVolume(tempRadius,0,0,0,0,0)
			elseif(cmpstr(DistShapeModel,"Spheroid")==0 ||cmpstr(DistShapeModel,"Integrated_Spheroid")==0)		//spheroid, volume 4/3 pi * r^3 *beta
				tempVolume+=IR1T_SpheroidVolume(tempRadius, Par1)
			elseif(cmpstr(DistShapeModel,"Algebraic_Globules")==0)									//globule 4/3 pi * r^3 *beta
				tempVolume+=4/3*pi*(tempRadius^3)*Par1
			elseif(cmpstr(DistShapeModel,"Algebraic_Disks")==0)										//Alg disk, 
				tempVolume+=2*pi*(tempRadius^3)*Par1
			elseif(cmpstr(DistShapeModel,"Unified_Disc")==0 ||cmpstr(DistShapeModel,"Unified_Disk")==0)				//Uni & rod disk, 
				tempVolume+=IR1T_UnifiedDiscVolume(tempRadius,Par1,0,0,0,0) 					//2*pi*(tempRadius^2)*DistScatShapeParam1
			elseif(cmpstr(DistShapeModel,"Unified_rod")==0)											//Uni & rod disk, 
				tempVolume+=IR1T_UnifiedRodVolume(tempRadius,Par1,0,0,0,0) 					//2*pi*(tempRadius^2)*DistScatShapeParam1
			elseif(cmpstr(DistShapeModel,"Unified_rodAR")==0)									//Uni & rod disk, 
				tempVolume+=IR1T_UnifiedRodVolume(tempRadius,2*Par1*tempRadius,0,0,0,0) 					//2*pi*(tempRadius^2)*DistScatShapeParam1
			elseif(cmpstr(DistShapeModel,"Algebraic_Rods")==0)										//Alg rod, 
				tempVolume+=2*pi*(tempRadius^3)*Par1
			elseif(cmpstr(DistShapeModel,"cylinder")==0)											//cylinder volume = pi* r^2 * length
				tempVolume+=IR1T_CylinderVolume(tempRadius, Par1)
			elseif(cmpstr(DistShapeModel,"cylinderAR")==0)										//cylinder volume = pi* r^2 * length
				tempVolume+=IR1T_CylinderVolume(tempRadius, 2*Par1*tempRadius)
			elseif(cmpstr(DistShapeModel,"CoreShellCylinder")==0)							//CoreShellCylinder volume = pi* (r+CoreShellCylinder wall thickness)^2 * length
				SVAR CoreShellVolumeDefinition = root:Packages:FormFactorCalc:CoreShellVolumeDefinition
				tempVolume+=IR1T_TubeVolume(tempRadius,Par1,Par2, CoreShellVolumeDefinition)
			elseif(cmpstr(DistShapeModel,"Unified_tube")==0)									//tube volume = pi* (r+tube wall thickness)^2 * length
				tempVolume+=IR1T_UnifiedTubeVolume(tempRadius,Par1,Par2,par3,1, 1)
			elseif(cmpstr(DistShapeModel,"CoreShell")==0)
				tempVolume+=IR1T_CoreShellVolume(tempRadius,Par1,VolDefL)	
			elseif(cmpstr(DistShapeModel,"CoreShellShell")==0)
				tempVolume+=IR1T_CoreShellVolume(tempRadius,Par1+Par2,VolDefL)	
			elseif(cmpstr(DistShapeModel,"Fractal Aggregate")==0)
				tempVolume+=IR1T_FractalAggofSpheresVol(tempRadius, Par1,Par2, 1, 1, 1)
			elseif(cmpstr(DistShapeModel,"NoFF_setTo1")==0)
				tempVolume+=1
			elseif(cmpstr(DistShapeModel,"SphereWHSLocMonoSq")==0)
				tempVolume+=IR1T_SpheroidVolume(tempRadius, 1)
			elseif(cmpstr(DistShapeModel,"Janus CoreShell Micelle*")==0)
				tempVolume+=IR1T_JanusVp(tempRadius,Par1,Par2,Par3,Par4 )
			elseif(cmpstr(DistShapeModel,"CoreShellPrecipitate")==0)
				tempVolume+=IR1T_CoreShellVolume(tempRadius,Par1,VolDefL)
			elseif(cmpstr(DistShapeModel,"RectParallelepiped")==0)
				tempVolume+=IR1T_RecParallVolume(tempRadius,Par1,Par2,1,1,1)
			elseif(cmpstr(DistShapeModel,"User")==0)	
					infostr = FunctionInfo(UserVolumeFnctName)
					if (strlen(infostr) == 0)
						Abort "Bad name passed to User FF as Volume function"
					endif
					if(NumberByKey("N_PARAMS", infostr)!=6 || NumberByKey("RETURNTYPE", infostr)!=4)
						Abort "Bad number of parameters passed to User FF for Form factor or Volume"
					endif
				cmd2="root:Packages:FormFactorCalc:tempVolCalc="+UserVolumeFnctName+"("+num2str(tempRadius)+","+num2str(UserPar1)+","+num2str(UserPar2)+","+num2str(UserPar3)+","+num2str(UserPar4)+","+num2str(UserPar5)+")"
				Execute (cmd2)
				tempVolume+=tempVolCalc
			endif		
		endfor
		tempVolume/=50				//average
		tempVolume*=10^(-24)		//conversion from A to cm
		AveVolumeWave[i]=tempVolume
	endfor
	setDataFolder OldDf
end
/////*********************************************************************************************************************
/////*********************************************************************************************************************
/////*********************************************************************************************************************
/////*********************************************************************************************************************
/////*********************************************************************************************************************
/////*********************************************************************************************************************


Function IR1T_CreateAveSurfaceAreaWave(AveSurfaceAreaWave,Distdiameters,DistShapeModel,Par1,Par2,Par3,Par4,Par5,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)
	Wave AveSurfaceAreaWave,Distdiameters
	string DistShapeModel, UserVolumeFnctName
	variable Par1,Par2,Par3,Par4,Par5, UserPar1,UserPar2,UserPar3,UserPar4,UserPar5

	variable i,j
	variable StartValue, EndValue, tempSurface, tempRadius, exc
	string cmd2, infostr
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages
	NewDataFolder/O/S root:Packages:FormFactorCalc
	variable/g tempVolCalc
	string VolDefL
	SVAR/Z CoreShellVolumeDefinition = root:Packages:FormFactorCalc:CoreShellVolumeDefinition
	if(SVAR_Exists(CoreShellVolumeDefinition))
		VolDefL=CoreShellVolumeDefinition
	else
		VolDefL="Whole Particle"
	endif	

	For (i=0;i<numpnts(Distdiameters);i+=1)
		StartValue=IR1T_StartOfBinInDiameters(Distdiameters,i)
		EndValue=IR1T_EndOfBinInDiameters(Distdiameters,i)
		tempSurface=0
		tempVolCalc=0

		For(j=0;j<50;j+=1)
			tempRadius=(StartValue+j*(EndValue-StartValue)/50 ) /2
			
			if(cmpstr(DistShapeModel,"Unified_sphere")==0 || cmpstr(DistShapeModel,"Algebraic_Spheres")==0)		//spheroid, volume 4/3 pi * r^3 *beta
				tempSurface+=4*pi*tempRadius^2
			elseif(cmpstr(DistShapeModel,"spheroid")==0 ||cmpstr(DistShapeModel,"Integrated_Spheroid")==0 || cmpstr(DistShapeModel,"Algebraic_Globules")==0)		//spheroid, volume 4/3 pi * r^3 *beta
				if (Par1>0.99 && Par1<1.01)			//still sphere close enough...., Par1 = aspect ratio
					tempSurface+=4*pi*tempRadius^2
				elseif(Par1>1.01)						//Prolate ellipsoid (R, R, Par1*R)
					exc = sqrt((tempRadius*Par1)^2-tempRadius^2)/(TempRadius*Par1)
					tempSurface+= 2*Pi*tempRadius*(TempRadius+(TempRadius*Par1) * asin(exc)/exc)
				else
					exc = sqrt(tempRadius^2 - (tempRadius*Par1)^2)/(TempRadius)
					tempSurface+= 2*Pi*tempRadius*(TempRadius+(TempRadius*Par1) * asinh(tempRadius*exc/(TempRadius*Par1))/(tempRadius*exc/(TempRadius*Par1)))
				endif
			elseif(cmpstr(DistShapeModel,"Algebraic_Disks")==0)		//Alg disk, Par 1 = aspect ratio
					tempSurface+=2*pi*tempRadius^2 + ((Par1*tempRadius)*2 * pi * tempRadius)
			elseif(cmpstr(DistShapeModel,"Unified_Disc")==0 ||cmpstr(DistShapeModel,"Unified_Disk")==0)				//Uni & rod disk, Par 1 = thickness
					tempSurface+=2*pi*tempRadius^2 + (Par1 * pi * tempRadius)
			elseif(cmpstr(DistShapeModel,"Unified_rod")==0)										//Uni & rod disk,  Par1 = length
					tempSurface+=2*pi*tempRadius^2 + (Par1 * pi * tempRadius)
			elseif(cmpstr(DistShapeModel,"Unified_rodAR")==0)									//Uni & rod disk, Par1 = aspect ratio
					tempSurface+=2*pi*tempRadius^2 + ((Par1*tempRadius)*2 * pi * tempRadius)
			elseif(cmpstr(DistShapeModel,"Algebraic_Rods")==0)									//Alg rod,  Par1 = aspect ratio
					tempSurface+=2*pi*tempRadius^2 + ((Par1*tempRadius)*2 * pi * tempRadius)
			elseif(cmpstr(DistShapeModel,"cylinder")==0)											//Par 1 = length
					tempSurface+=2*pi*tempRadius^2 + (Par1 * pi * tempRadius)
			elseif(cmpstr(DistShapeModel,"cylinderAR")==0)										//Par 1 = aspect ratio
					tempSurface+=2*pi*tempRadius^2 + ((Par1*tempRadius)*2 * pi * tempRadius)
			elseif(cmpstr(DistShapeModel,"CoreShellCylinder")==0)												//Par 1 = length, Par 2 = wall thickness... Assume two surfaces together...
					tempSurface+=2*pi*((tempRadius+Par2)^2 - tempRadius^2) + (Par1 * pi * tempRadius) + (Par1 * pi * (tempRadius+Par2))
			elseif(cmpstr(DistShapeModel,"Unified_tube")==0)										//Par 1 = length, Par 2 = wall thickness... Assume two surfaces together..
					tempSurface+=2*pi*((tempRadius+Par2)^2 - tempRadius^2) + (Par1 * pi * tempRadius) + (Par1 * pi * (tempRadius+Par2))
			elseif(cmpstr(DistShapeModel,"CoreShell")==0)										//Par 1 = cores shell thickness, take both surfaces....
				tempSurface+=4*pi*tempRadius^2 + 4*pi*(tempRadius+Par1)^2
			elseif(cmpstr(DistShapeModel,"CoreShellShell")==0)										//Par 1 = cores shell thickness, take both surfaces....
				tempSurface+=4*pi*tempRadius^2 + 4*pi*(tempRadius+Par1+Par2)^2
			elseif(cmpstr(DistShapeModel,"Fractal Aggregate")==0)
				tempSurface+=NaN																	//no idea....
			elseif(cmpstr(DistShapeModel,"NoFF_setTo1")==0)
				tempSurface+=1																	//no idea....
			elseif(cmpstr(DistShapeModel,"SphereWHSLocMonoSq")==0)								//ignore PY Sf internally, this is simply sphere. 
				tempSurface+=4*pi*tempRadius^2
			elseif(cmpstr(DistShapeModel,"Janus CoreShell Micelle*")==0)
				tempSurface+=4*pi*tempRadius^2 + 4*pi*(tempRadius+Par1)^2						//this is basically simple Core Shell particle form this point of view... 
			elseif(cmpstr(DistShapeModel,"CoreShellPrecipitate")==0)
				tempSurface+=4*pi*tempRadius^2 + 4*pi*(tempRadius+Par1)^2						//this is basically simple Core Shell particle form this point of view... 
			elseif(cmpstr(DistShapeModel,"RectParallelepiped")==0)									//Surface Area = 2lw + 2lh + 2wh
				tempSurface+=IR1T_RecParallSurface(tempRadius,Par1,Par2,Par3,Par4,Par5)
			elseif(cmpstr(DistShapeModel,"User")==0)				//no idea... 
//					infostr = FunctionInfo(UserVolumeFnctName)
//					if (strlen(infostr) == 0)
//						Abort
//					endif
//					if(NumberByKey("N_PARAMS", infostr)!=6 || NumberByKey("RETURNTYPE", infostr)!=4)
//						Abort
//					endif
//				cmd2="root:Packages:FormFactorCalc:tempVolCalc="+UserVolumeFnctName+"("+num2str(tempRadius)+","+num2str(UserPar1)+","+num2str(UserPar2)+","+num2str(UserPar3)+","+num2str(UserPar4)+","+num2str(UserPar5)+")"
//				Execute (cmd2)
				tempSurface+=NaN		//no function for user surface area... 
			endif		
		endfor
		tempSurface/=50				//average
		tempSurface*=10^(-16)		//conversion from A to cm
		AveSurfaceAreaWave[i]=tempSurface
	endfor
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


///////////////////////////////////////////////////////////////
// F(qq, rcore, thick, rhoc,rhos,rhosolv, length, zi)
//
threadsafe Function IR1T_CoreShellcyl(qq, rcore, thick, rhoc,rhos,rhosolv, length, dum)
	Variable qq, rcore, thick, rhoc,rhos,rhosolv, length, dum
	
// qq is the q-value for the calculation (1/A)
// rcore is the core radius of the cylinder (A)
//thick is the uniform thickness
// rho(n) are the respective SLD's

// length is the *Half* CORE-LENGTH of the cylinder = L (A)

// dum is the dummy variable for the integration (x in Feigin's notation)

   //Local variables 
	Variable dr1,dr2,besarg1,besarg2,vol1,vol2,sinarg1,sinarg2,t1,t2,retval
	
	dr1 = rhoc-rhos
	dr2 = rhos-rhosolv
	vol1 = Pi*rcore*rcore*(2*length)
	vol2 = Pi*(rcore+thick)*(rcore+thick)*(2*length+2*thick)
	
	besarg1 = qq*rcore*sin(dum)
	besarg2 = qq*(rcore+thick)*sin(dum)
	sinarg1 = qq*length*cos(dum)
	sinarg2 = qq*(length+thick)*cos(dum)
	
	t1 = 2*vol1*dr1*sin(sinarg1)/sinarg1*Besselj(1,besarg1)/besarg1
	t2 = 2*vol2*dr2*sin(sinarg2)/sinarg2*Besselj(1,besarg2)/besarg2
	
	retval = ((t1+t2)^2)*sin(dum)
	
    return retval
    
End 	//Function CoreShellcyl()
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1T_Make76GaussPoints(w76,z76)
	wave w76,z76
	
     		z76[0] = .999505948362153*(-1.0)
	    z76[75] = -.999505948362153*(-1.0)
	    z76[1] = .997397786355355*(-1.0)
	    z76[74] = -.997397786355355*(-1.0)
	    z76[2] = .993608772723527*(-1.0)
	    z76[73] = -.993608772723527*(-1.0)
	    z76[3] = .988144453359837*(-1.0)
	    z76[72] = -.988144453359837*(-1.0)
	    z76[4] = .981013938975656*(-1.0)
	    z76[71] = -.981013938975656*(-1.0)
	    z76[5] = .972229228520377*(-1.0)
	    z76[70] = -.972229228520377*(-1.0)
	    z76[6] = .961805126758768*(-1.0)
	    z76[69] = -.961805126758768*(-1.0)
	    z76[7] = .949759207710896*(-1.0)
	    z76[68] = -.949759207710896*(-1.0)
	    z76[8] = .936111781934811*(-1.0)
	    z76[67] = -.936111781934811*(-1.0)
	    z76[9] = .92088586125215*(-1.0)
	    z76[66] = -.92088586125215*(-1.0)
	    z76[10] = .904107119545567*(-1.0)
	    z76[65] = -.904107119545567*(-1.0)
	    z76[11] = .885803849292083*(-1.0)
	    z76[64] = -.885803849292083*(-1.0)
	    z76[12] = .866006913771982*(-1.0)
	    z76[63] = -.866006913771982*(-1.0)
	    z76[13] = .844749694983342*(-1.0)
	    z76[62] = -.844749694983342*(-1.0)
	    z76[14] = .822068037328975*(-1.0)
	    z76[61] = -.822068037328975*(-1.0)
	    z76[15] = .7980001871612*(-1.0)
	    z76[60] = -.7980001871612*(-1.0)
	    z76[16] = .77258672828181*(-1.0)
	    z76[59] = -.77258672828181*(-1.0)
	    z76[17] = .74587051350361*(-1.0)
	    z76[58] = -.74587051350361*(-1.0)
	    z76[18] = .717896592387704*(-1.0)
	    z76[57] = -.717896592387704*(-1.0)
	    z76[19] = .688712135277641*(-1.0)
	    z76[56] = -.688712135277641*(-1.0)
	    z76[20] = .658366353758143*(-1.0)
	    z76[55] = -.658366353758143*(-1.0)
	    z76[21] = .626910417672267*(-1.0)
	    z76[54] = -.626910417672267*(-1.0)
	    z76[22] = .594397368836793*(-1.0)
	    z76[53] = -.594397368836793*(-1.0)
	    z76[23] = .560882031601237*(-1.0)
	    z76[52] = -.560882031601237*(-1.0)
	    z76[24] = .526420920401243*(-1.0)
	    z76[51] = -.526420920401243*(-1.0)
	    z76[25] = .491072144462194*(-1.0)
	    z76[50] = -.491072144462194*(-1.0)
	    z76[26] = .454895309813726*(-1.0)
	    z76[49] = -.454895309813726*(-1.0)
	    z76[27] = .417951418780327*(-1.0)
	    z76[48] = -.417951418780327*(-1.0)
	    z76[28] = .380302767117504*(-1.0)
	    z76[47] = -.380302767117504*(-1.0)
	    z76[29] = .342012838966962*(-1.0)
	    z76[46] = -.342012838966962*(-1.0)
	    z76[30] = .303146199807908*(-1.0)
	    z76[45] = -.303146199807908*(-1.0)
	    z76[31] = .263768387584994*(-1.0)
	    z76[44] = -.263768387584994*(-1.0)
	    z76[32] = .223945802196474*(-1.0)
	    z76[43] = -.223945802196474*(-1.0)
	    z76[33] = .183745593528914*(-1.0)
	    z76[42] = -.183745593528914*(-1.0)
	    z76[34] = .143235548227268*(-1.0)
	    z76[41] = -.143235548227268*(-1.0)
	    z76[35] = .102483975391227*(-1.0)
	    z76[40] = -.102483975391227*(-1.0)
	    z76[36] = .0615595913906112*(-1.0)
	    z76[39] = -.0615595913906112*(-1.0)
	    z76[37] = .0205314039939986*(-1.0)
	    z76[38] = -.0205314039939986*(-1.0)
	    
		w76[0] =  .00126779163408536
		w76[75] = .00126779163408536
		w76[1] =  .00294910295364247
	    w76[74] = .00294910295364247
	    w76[2] = .00462793522803742
	    w76[73] =  .00462793522803742
	    w76[3] = .00629918049732845
	    w76[72] = .00629918049732845
	    w76[4] = .00795984747723973
	    w76[71] = .00795984747723973
	    w76[5] = .00960710541471375
	    w76[70] =  .00960710541471375
	    w76[6] = .0112381685696677
	    w76[69] = .0112381685696677
	    w76[7] =  .0128502838475101
	    w76[68] = .0128502838475101
	    w76[8] = .0144407317482767
	    w76[67] =  .0144407317482767
	    w76[9] = .0160068299122486
	    w76[66] = .0160068299122486
	    w76[10] = .0175459372914742
	    w76[65] = .0175459372914742
	    w76[11] = .0190554584671906
	    w76[64] = .0190554584671906
	    w76[12] = .020532847967908
	    w76[63] = .020532847967908
	    w76[13] = .0219756145344162
	    w76[62] = .0219756145344162
	    w76[14] = .0233813253070112
	    w76[61] = .0233813253070112
	    w76[15] = .0247476099206597
	    w76[60] = .0247476099206597
	    w76[16] = .026072164497986
	    w76[59] = .026072164497986
	    w76[17] = .0273527555318275
	    w76[58] = .0273527555318275
	    w76[18] = .028587223650054
	    w76[57] = .028587223650054
	    w76[19] = .029773487255905
	    w76[56] = .029773487255905
	    w76[20] = .0309095460374916
	    w76[55] = .0309095460374916
	    w76[21] = .0319934843404216
	    w76[54] = .0319934843404216
	    w76[22] = .0330234743977917
	    w76[53] = .0330234743977917
	    w76[23] = .0339977794120564
	    w76[52] = .0339977794120564
	    w76[24] = .0349147564835508
	    w76[51] = .0349147564835508
	    w76[25] = .0357728593807139
	    w76[50] = .0357728593807139
	    w76[26] = .0365706411473296
	    w76[49] = .0365706411473296
	    w76[27] = .0373067565423816
	    w76[48] = .0373067565423816
	    w76[28] = .0379799643084053
	    w76[47] = .0379799643084053
	    w76[29] = .0385891292645067
	    w76[46] = .0385891292645067
	    w76[30] = .0391332242205184
	    w76[45] = .0391332242205184
	    w76[31] = .0396113317090621
	    w76[44] = .0396113317090621
	    w76[32] = .0400226455325968
	    w76[43] = .0400226455325968
	    w76[33] = .040366472122844
	    w76[42] = .040366472122844
	    w76[34] = .0406422317102947
	    w76[41] = .0406422317102947
	    w76[35] = .0408494593018285
	    w76[40] = .0408494593018285
	    w76[36] = .040987805464794
	    w76[39] = .040987805464794
	    w76[37] = .0410570369162294
	    w76[38] = .0410570369162294

End		//Make76GaussPoints()
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//			Janus coreshell Micelle functions... 
//*****************************************************************************************************************
//static 
threadsafe  Function IR1T_JanusFF(Qv, Ro, RhoA, RhoB, RhoC, RhoSolv,Ri)
	variable Qv, Ro, RhoA, RhoB, RhoC, RhoSolv, Ri

	variable RhoARel, RhoBRel, RhoCRel
	RhoARel = RhoA - RhoSolv
	RhoBRel = RhoB - RhoSolv
	RhoCRel = RhoC - RhoSolv
	variable numP=JanusCoreShellMicNumIngtPnts	
	// Ro = Ro in Fig 1
	// Ri =  Ri in Fig 1
	//define parameters as per manuscript. 
	variable mu 		//cos(th), where th is that from the figure 7 going from 0 to pi/2
	//we need to integrate this per whole particle - remember to weigh by cos(th) in the integration as AnisoPorod used to be
	variable kv		//is Q * mu
	variable DrhoBA	= RhoARel - RhoBRel	// RhoA - RhoB
	variable DrhoCA = RhoARel - RhoCRel	//RhoA - RhoC
	// now we need to do the calculations.
	variable Vp = IR1T_JanusVp(Ro,RhoARel, RhoBRel, RhoCRel,Ri)
	make/O/N=(numP) IntgWvMu, weightFac
	SetScale /I x, 0, pi/2,"", IntgWvMu, weightFac
	weightFac = sin(x)
	multithread IntgWvMu = IR1T_JanusOneMu(Qv,Ro,Ri, DrhoBA, DrhoCA, RhoBRel, RhoCRel, Qv*cos(x), numP, Vp, cos(x))
	IntgWvMu[0]=IntgWvMu[1]			//IntgWvMu[0] = NaN so needs to be replaced by next point. Known numercial issue... 
	IntgWvMu *=weightFac
	return area(IntgWvMu, 0, pi/2) 
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR1T_JanusAveContrast(Rcore, RShell, RhoCore, RhoA, RhoB, RhoSolv)
	variable Rcore, RShell, RhoCore, RhoA, RhoB, RhoSolv

	variable CoreVolume = 4/3 * pi * Rcore^3
	variable ShellVolume = 4/3 * pi * (Rcore+RShell)^3 - CoreVolume
	variable SummContr = CoreVolume*(RhoCore-RhoSolv) + 0.5*ShellVolume*(RhoA-RhoSolv) +  0.5*ShellVolume*(RhoB-RhoSolv)
	variable DeltaRho = (SummContr / (CoreVolume+ShellVolume))
	return abs(DeltaRho)
end

//*****************************************************************************************************************
//*****************************************************************************************************************
threadsafe static Function IR1T_JanusOneMu(Qv,Ro,Ri, DrhoBA, DrhoCA, RhoB, RhoC, kv, numP, Vp, mu )
	variable Qv,Ro,Ri, DrhoBA, DrhoCA, RhoB, RhoC, kv, numP, Vp, mu
	
	variable Prefactor =  4 * pi^2 /(Qv^2 * (1 - mu^2) * Vp^2)
	variable part1, part2, part3, part4
	part1 = (RhoB + RhoC) * IR1T_JanusIntgCos(kv,Qv, Ro,mu, numP)
	part2 = (DrhoBA + DrhoCA) * IR1T_JanusIntgCos(kv,Qv, Ri,mu, numP)
	part3 = (RhoB - RhoC) * IR1T_JanusIntgSin(kv,Qv, Ro,mu, numP)
	part4 = (DrhoBA - DrhoCA) * IR1T_JanusIntgSin(kv,Qv, Ri,mu, numP)
	
	return Prefactor * ((part1+part2)^2+(part3+part4)^2)	 
end
//*****************************************************************************************************************
//*****************************************************************************************************************
threadsafe static Function IR1T_JanusIntgCos(kv,Qv, Rx,mu, numP)
	variable kv,Qv, Rx,mu, numP	
	make/Free/N=(numP) IntgWv
	SetScale /I x, 0, Rx ,"", IntgWv 
	IntgWv = cos(kv * x) * IR1T_JanusF(Qv, Rx,x,mu)
	return area(IntgWv , 0, Rx)
end
//*****************************************************************************************************************
//*****************************************************************************************************************
threadsafe static Function IR1T_JanusIntgSin(kv,Qv, Rx,mu, numP)
	variable kv,Qv, Rx,mu, numP	
	make/Free/N=(numP) IntgWv
	SetScale /I x, 0, Rx ,"", IntgWv 
	IntgWv = sin(kv * x) * IR1T_JanusF(Qv, Rx,x,mu)
	return area(IntgWv , 0, Rx)
end
//*****************************************************************************************************************
//*****************************************************************************************************************
threadsafe static Function IR1T_JanusF(Qv, Rj,Zv,mu)
	variable Qv, Rj, Zv, mu
	variable part1 = sqrt(Rj^2 - Zv^2)
	variable BesArg= Qv * sqrt(1-mu^2)*part1
	variable part2 = Besselj(1,BesArg)
	return part1 * part2	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
threadsafe static Function IR1T_JanusVp(Ro,RhoA, RhoB, RhoC,Ri )	
	variable Ro,RhoA, RhoB, RhoC,Ri
	return (4/3)*pi*(((RhoB+RhoC)/2)*(Ro^3 - Ri^3) + RhoA*Ri^3)	
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
