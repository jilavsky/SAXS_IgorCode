#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.1

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

Function IR1T_InitFormFactors()
	//here we initialize the form factor calculations
	
	string OldDf=GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:FormFactorCalc
	
	string/g ListOfFormFactors="Spheroid;Cylinder;CylinderAR;CoreShell;CoreShellCylinder;User;Integrated_Spheroid;Algebraic_Globules;Algebraic_Rods;Algebraic_Disks;Unified_Sphere;Unified_Rod;Unified_RodAR;Unified_Disk;Unified_Tube;Fractal Aggregate;"
	ListOfFormFactors+="NoFF_setTo1;"
	string/g CoreShellVolumeDefinition
	SVAR CoreShellVolumeDefinition			//this will be user choice for definition of volume of core shell particle: "Whole particle;Core;Shell:", NIST standard definition is Whole particle, default... 
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
		DoWindow/K NewBatchFile
		ExecuteScriptText "\""+SpecialDirPath("Temporary", 0, 1, 0 )+"StartFormFactors.bat\""
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
	

Function IR1T_GenerateGMatrix(Gmatrix,Q_vec,R_dist,VolumePower,ParticleModel,ParticlePar1,ParticlePar2,ParticlePar3,ParticlePar4,ParticlePar5, User_FormFactorFnct, User_FormFactorVol)
		Wave Gmatrix		//result, will be checked if it is needed to recalculate, redimensioned and reculated, if necessary
		Wave Q_vec			//Q vectors, in A-1
		Wave R_dist			//radia in A
		variable VolumePower	//if rest of the code uses volume distribution, set to 1, if number distribution, use 2 (1: G=V*F^2; 2: G=V^2*F^2)
		string ParticleModel	//one of known Particle models
		variable ParticlePar1,ParticlePar2,ParticlePar3,ParticlePar4,ParticlePar5	//possible parameters, let's hope no one needs more than 5
		string User_FormFactorFnct, User_FormFactorVol						//these contain names for user form factor functions  
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
		string OldNote=note(Gmatrix)
		string NewNote = ""
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
		if(cmpstr(StringByKey("ParticleModel", OldNote),"user")==0)		//check the model for Particle shape
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
		if(cmpstr(StringByKey("ParticlePar5", OldNote),num2str(ParticlePar5))!=0 )		//check the Particle shape parameter 5
			Recalculate=1
			reason = "Parameter 5"
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
		For(i=0;i<floor(numpnts(R_dist)/5);i+=1)
			if(cmpstr(StringByKey("R_"+num2str(i), OldNote),num2str(R_dist[i]))!=0 )		//check every 5th R value written in wave note
				Recalculate=1
				reason = "Radius value"
			endif
		endfor

	if(Recalculate)
			redimension/D/N=(M,N) Gmatrix				//redimension G matrix to right size
			Make/D/O/N=(M) TempWave 					//create temp work wave
		
			//and now we need to do selected form factor, each needs to be separate peice of code...
			variable aspectRatio
			variable FractalRadiusOfPriPart
			variable FractalDimension, thickness
			variable QR, QH, topp, bott, Rd, QRd, sqqt, argument, surchi, rP, Qj, bP, bM, length,WallThickness
			variable CoreShellCoreRho,CoreShellThickness,CoreShellShellRho, CoreShellSolvntRho
			variable CoreContrastRatio
	

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
						IR1T_CalcSpheroidFormFactor(TempWave,Q_vec,currentR,aspectRatio)	//here we calculate one column of data
						TempWave*=IR1T_SpheroidVolume(currentR,aspectRatio)^VolumePower		//multiply by volume of spheroid^VolumePower
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
				endif
			elseif (cmpstr(ParticleModel,"user")==0)						// user, will need more input...
					//here we need to declare (and check for existence) strings with functions for Form factor and volume
						
					String infostr = FunctionInfo(User_FormFactorFnct)
					if (strlen(infostr) == 0)
						Abort "Form facotr user function does not exist"
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
						Execute/Z(cmd1)
						TempWave = TempWave^2
						Execute/Z(cmd2)
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor

			elseif (cmpstr(ParticleModel,"Integrated_Spheroid")==0)			// integrated spheroid using medium point approximation
				aspectRatio=ParticlePar1									//Aspect ratio is set by particleparam1
				if ((aspectRatio<=1.01)&&(aspectRatio>=0.99))				//actually, this is sphere...
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						TempWave=IR1T_CalculateIntgSphereFFPnts(Q_vec[p],currentR,VolumePower,IR1_StartOfBinInDiameters(R_dist,i),IR1T_EndOfBinInDiameters(R_dist,i))		//here we calculate one column of data
						//TempWave*=IR1T_SphereVolume(currentR)		//----------	Volume included in the above procedure due to integration
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
				else														//OK, spheroid...
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						TempWave=IR1T_CalcIntgIntgSpheroidFFPnts(Q_vec[p],currentR,VolumePower,IR1_StartOfBinInDiameters(R_dist,i),IR1T_EndOfBinInDiameters(R_dist,i),aspectRatio)	//here we calculate one column of data
						//TempWave*=IR1T_SpheroidVolume(currentR,aspectRatio)	//----------	Volume included in the above procedure due to integration
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
				endif
			elseif (cmpstr(ParticleModel,"Cylinder")==0)						// cylinder
				length=ParticlePar1
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						TempWave=IR1_CalcIntgCylinderFFPnts(Q_vec[p],currentR,VolumePower,IR1_StartOfBinInDiameters(R_dist,i),IR1T_EndOfBinInDiameters(R_dist,i), length)		//here we calculate one column of data
						//TempWave*=IR1T_SphereVolume(currentR)		//----------	Volume included in the above procedure due to integration
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif (cmpstr(ParticleModel,"CylinderAR")==0)						// cylinder
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						length=2*ParticlePar1*currentR						//and this is length - aspect ratio * currrentR * 2
						TempWave=IR1_CalcIntgCylinderFFPnts(Q_vec[p],currentR,VolumePower,IR1_StartOfBinInDiameters(R_dist,i),IR1T_EndOfBinInDiameters(R_dist,i), length)		//here we calculate one column of data
						//TempWave*=IR1T_SphereVolume(currentR)		//----------	Volume included in the above procedure due to integration
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif (cmpstr(ParticleModel,"Unified_Disk")==0 || cmpstr(ParticleModel,"Unified_Disc")==0)						// cylinder
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
			elseif (cmpstr(ParticleModel,"Unified_Tube")==0)						// cylinder
				length=ParticlePar1
				Thickness=ParticlePar2
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						TempWave=(IR1T_UnifiedtubeFF(Q_vec[p],currentR,length,thickness,0,0,0 ) )^2
						TempWave*=IR1T_UnifiedTubeVolume(currentR,length,thickness,0,0,0)^VolumePower		
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif (cmpstr(ParticleModel,"Unified_RodAR")==0)						// cylinder
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						length=ParticlePar1*2*currentR						//this is length = 2 * AR * R
						TempWave=(IR1T_UnifiedrodFF(Q_vec[p],currentR,length,0,0,0,0 ) )^2
						TempWave*=IR1T_UnifiedRodVolume(currentR,length,0,0,0,0)^VolumePower		
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
			elseif (cmpstr(ParticleModel,"Unified_Sphere")==0)						// cylinder
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
						TempWave=(IR1T_UnifiedSphereFF(Q_vec[p],currentR,thickness,0,0,0,0 ) )^2
						TempWave*=IR1T_UnifiedsphereVolume(currentR,thickness,0,0,0,0)^VolumePower	
						Gmatrix[][i]=TempWave[p]							//and here put it into G wave
					endfor
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
					For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
						currentR=R_dist[i]								//this is current radius
					//	TempWave=IR1T_CalcIntgTubeFFPoints(Q_vec[p],currentR,VolumePower,IR1_StartOfBinInDiameters(R_dist,i),IR1T_EndOfBinInDiameters(R_dist,i),Length,WallThickness,CoreShellCoreRho,CoreShellShellRho, CoreShellSolvntRho )		//here we calculate one column of data
						TempWave=IR1T_CalcTubeFFPointsNIST(Q_vec[p],currentR,VolumePower,Length,WallThickness,CoreShellCoreRho,CoreShellShellRho, CoreShellSolvntRho )		//here we calculate one column of data
			
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
						TempWave=IR1T_CalculateCoreShellFFPoints(Q_vec[p],currentR,VolumePower,IR1_StartOfBinInDiameters(R_dist,i),IR1T_EndOfBinInDiameters(R_dist,i), CoreShellThickness, CoreShellCoreRho, CoreShellShellRho, CoreShellSolvntRho)								//and here we multiply by N(r)
						//note, the above calculated form factor contains volume^1 in it... So we need to multiply by volume^(power-1) here. Also we use volume of the core for particle volume!!!
						TempWave*=(IR1T_CoreShellVolume(currentR,CoreShellThickness))^(VolumePower-1)				//Multiplication by volume to appropriate power. Here is now the question - what is the volue of this particle? Here the volue is core only... 
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
					TempWave=IR1T_FractalAggofSpheresFF(Q_vec[p],CurrentR,FractalRadiusOfPriPart,FractalDimension,1,1,1)^2				//DWS 6 2 2005
					TempWave*= IR1T_FractalAggofSpheresVol(CurrentR,FractalRadiusOfPriPart,FractalDimension,1,1,1)^VolumePower		//DWS 6 2 2005
					Gmatrix[][i]=TempWave[p]								//and here put it into G wave
				endfor
			elseif(cmpstr(ParticleModel,"Algebraic_Rods")==0)				//Pete's rods model, apparently using AJA code from whenever
				aspectRatio=ParticlePar1									//Aspect ratio is set by particleparam1
				For (i=0;i<N;i+=1)											//calculate the G matrix in columns!!!
					currentR=R_dist[i]
					for(j=0;j<numpnts(TempWave);j+=1)						//calulate separately TempWave
						QR = currentR * Q_vec[j]
						QH = Q_vec[j] * AspectRatio * currentR
						topp = 1 + 2*pi*QH^3 * QR/(9 * (4 + QR^2)) + (QH^3 * QR^4)/8
						bott = 1 + QH^2 * (1 + QH^2 * QR)/9 + (QH^4 * QR^7)/16
						tempWave[j] = (2*pi*AspectRatio * currentR^3)^VolumePower * topp/bott
					endfor
					Gmatrix[][i]=TempWave[p]								//and here put it into G wave
				endfor
			elseif(cmpstr(ParticleModel,"Algebraic_Disks")==0)				//Pete's disk model, apparently using AJA code from whenever
				aspectRatio=ParticlePar1									//Aspect ratio is set by particleparam1
				For (i=0;i<N;i+=1)											//calculate the G matrix in columns!!!
					currentR=R_dist[i]
					for(j=0;j<numpnts(TempWave);j+=1)
						QR = currentR * Q_vec[j]
						Rd = currentR * AspectRatio						//disk radius
						QH = Q_vec[j] *  currentR
						QRd = Q_vec[j] *  currentR * AspectRatio
						topp = 1 + QRd^3 / (3 + QH^2) + (QH^2 * QRd / 3)^2
						bott = 1 + QRd^2 * (1 + QH * QRd^2)/16 + (QH^3 * QRd^2 / 3)^2
						tempWave[j] = (2*pi*AspectRatio * currentR^3)^VolumePower * topp/bott
					endfor
					Gmatrix[][i]=TempWave[p]								//and here put it into G wave
				endfor
			elseif(cmpstr(ParticleModel,"Algebraic_Globules")==0)			//Pete's Globules model, apparently using AJA code from whenever
				aspectRatio=ParticlePar1									//Aspect ratio is set by particleparam1
				if(AspectRatio<0.99)
					sqqt = sqrt(1-AspectRatio^2)
					argument = (2 - AspectRatio^2 + 2*sqqt)/(AspectRatio^2)
					surchi = (1 + AspectRatio^2 * ln(argument) / (2*sqqt)) / (2 * AspectRatio)
				elseif(AspectRatio>1.01)
					sqqt = sqrt(AspectRatio^2 - 1)
					argument = sqqt / AspectRatio
					surchi = (1 + AspectRatio^2 * asin(argument) / (sqqt)) / (2 * AspectRatio)
				else														//AspectRatio==1
					surchi = 1
				endif
				For (i=0;i<N;i+=1)											//calculate the G matrix in columns!!!
					currentR=R_dist[i]
					for(j=0;j<numpnts(TempWave);j+=1)
						QR = currentR * Q_vec[j]
						bott = 1 + QR^2 * (2 + AspectRatio^2)/15 + 2 * AspectRatio * QR^4 / (9 * surchi)
						tempWave[j] = (4/3 * pi * AspectRatio * currentR^3)^VolumePower  /  bott
					endfor
					Gmatrix[][i]=TempWave[p]								//and here put it into G wave
				endfor
		elseif(cmpstr(ParticleModel,"Algebraic_Spheres")==0)		//Pete's Algebraic Spheres model, apparently using Petes old code from whenever
				For (i=0;i<N;i+=1)											//calculate the G matrix in columns!!!
					currentR=R_dist[i]
					rP = currentR + IR1T_BinWidthInRadia(R_dist,i)
					for(j=0;j<numpnts(TempWave);j+=1)
						Qj = Q_vec[j]
						bP = rp/2 + (Qj^2)	*(rP^3)/6 + (0.25*(Qj * rP^2) - 0.625/Qj) * sin(2 * Qj * rP) + 0.75 * rP * cos(2 * Qj * rP)
						bM = currentR/2 + (Qj^2)*(currentR^3)/6 + (0.25 * (Qj * currentR^2) - 0.625/Qj) * sin(2 * Qj * currentR) + 0.75 * currentR * cos(2 * Qj * currentR)			
						topp = bP - bM
						bott = Qj^6 * (rP^4 - currentR^4) * currentR^3
						tempWave[j] =  36 * (4/3 * pi * currentR^3)^VolumePower * topp/bott
					endfor
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
	NewNote+= "ParticlePar4:"+num2str(ParticlePar4)+";"+"ParticlePar5:"+num2str(ParticlePar5)+";"+"VolumePower:"+num2str(VolumePower)+";"+"CoreShellVolumeDefinition:"+CoreShellVolumeDefinition+";"
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


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1T_CalculateCoreShellFFPoints(Qvalue,radius,VolumePower,radiusMin,radiusMax, Param1, Param2,Param3,Param4)
	variable Qvalue, radius, radiusMin,radiusMax, Param1, Param2	,Param3,Param4,VolumePower						//does the math for Sphere Form factor function
	//Param1 is skin thickness in A  
	//Param2 is core rho (not delta rho squared)
	//Param3 is shell rho (not delta rho squared)
	//Param4 is solvent rho (not delta rho squared)

	//this is first part - core
	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:FormFactorCalc
	
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
	result=result*	(Param2 - Param3)						 			//this scales to contrast difference between shell and core
	//another change, 7/3/2006... To sync with NIST macros... Need to plug in the voluem here again...
	//result=result* (IR1_SphereVolume(tempRad))^VolumePower							//multiply by volume of sphere
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
	//another change, 7/3/2006... To sync with NIST macros... Need to plug in the volume here again...
	result1=result1*(IR1T_SphereVolume(radius+Param1))				//multiply by volume of sphere)
	
	variable finalResult=(result + result1)^2											//summ and square them together
	//finalResult = finalResult / (IR1T_SphereVolume(radius+Param1))				//scale down volume scaling from above... This assumes the volume of particle is volue of core+shell
	finalResult = finalResult / (IR1T_CoreShellVolume(radius,Param1))				//scale down volume scaling from above... This assumes the volue of particle is the volume of core ONLY
	//note, after this step we have left Volume^1 in the current form factor!!!! result and result1 both contain Volume^1, then they are squared, and we took out only volume^1... 
	
	//this is end of the calculations for form factor... Now we can return, except this form factor contains the contrasts, so future calculations cannot multiply by this form factor...
	//this will be done at higher level... 
	//result = result *(IR1T_SphereVolume(radius+Param1))^VolumePower   			//add usual volume scaling needed in G matrix...  
	setDataFolder OldDf
	
	return finalResult													//and return the value, which is now average over the QR interval.
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

function  IR1T_UnifiedrodFF(qvalue,radius,length,par2,par3,par4,par5)//calculates  amplitude  may 
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


function  IR1T_UnifiedRodVolume(radius, length,par2,par3,par4,par5)
        variable radius, length,par2,par3,par4,par5
        variable v=pi*(radius^2)*length
        return v
end

function  IR1T_UnifiedtubeFF(qvalue, radius, length,thickness,par3,par4,par5)//calculates  amplitude normalized to 1
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

function IR1T_UnifiedTubeVolume(radius,length,thickness,par3,par4, par5)
	variable radius, length, thickness, par3, par4, par5
	variable v,rinner=radius-thickness
	 v=pi*(radius^2-rinner^2)*length
	 return v
end


function IR1T_UnifiedDiskFF(Q,radius,thickness,par2,par3,par4,par5 )  //calculates amplitude
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


function IR1T_UnifiedDiscVolume(radius,thickness,par2,par3,par4,par5)
        variable radius, thickness,par2,par3,par4,par5
        variable v=pi*(radius^2)*thickness
        return v
end


function  IR1T_UnifiedSphereFF(qvalue,radius,par1,par2,par3,par4,par5)// calculates amplitude
        variable qvalue,radius,par1,par2,par3,par4,par5
       Variable G1=1, P1=4, Rg1=sqrt(3/5)*radius
     //  variable B1=6*pi*G1/((4/3)*Radius^4)
       variable B1=1.62*G1/Rg1^4
        variable QstarVector=qvalue/(erf(qvalue*Rg1/sqrt(6)))^3
        variable result =G1*exp(-qvalue^2*Rg1^2/3)+(B1/QstarVector^P1)
        return (result)^.5//normalized to one
end


function IR1T_UnifiedsphereVolume(radius,par1,par2,par3,par4,par5)
        variable radius, par1,par2,par3,par4,par5
        variable v=(4/3)*pi*(radius^3)
        return v
end


//replace starting here********************
Function IR1T_FractalCluster(q,Rcluster,r0,D)//amplitude  Teixeira//not normalized
	variable q,Rcluster,r0,D
	variable rTeixeira
	rTeixeira=(q*r0)^-D
	rTeixeira=rTeixeira*D*(exp(gammln(D-1)))
	rTeixeira=rTeixeira/((1+(q*Rcluster)^-2)^((D-1)/2))
	rTeixeira=rTeixeira*sin((D-1)*atan(q*Rcluster))
	return (1+rTeixeira)^.5
end


function IR1T_FractalAggofSpheresFF(q,Rcluster,PriParticleRadius,D,par3,par4,par5)//calculates amplitude//dws 
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

function IR1T_FractalAggofSpheresVol(Rcluster,PriParticleRadius,D,par3,par4,par5)//dws added
	variable PriParticleRadius,Rcluster,D,par3,par4,par5
	variable v=(4/3)*pi*(PriParticleRadius^3)	//vol of one primary
	  v*=(Rcluster/PriParticleRadius)^D//mult by numb er of primaries
        return v
end               

function IR1T_FractalAggofRodsFF(Q,Rcluster, persistencelength,radius,D,par4,par5)
	variable Q,radius,persistencelength,rcluster,D,par4,par5
	variable fractalpart,rodpart
	Fractalpart=IR1T_FractalCluster(q,Rcluster,persistencelength,D)//  not normalized this was corrected 3/2008
	FractalPart/=(gamma(D+1)*(Rcluster/persistencelength)^D)^.5//normalize to one at low q
	rodpart =IR1T_UniFiedrodFF(Q,radius,persistencelength,1,1,1,1)//normalized at low q
	return (fractalpart*rodpart)//  Normalized to one.  needs to be squared and multiplied by the  (IR1T_FractalAggofrodsVol)^2
end					//to calculate intensity
	

function IR1T_FractalAggofRodsVol(Rcluster,Persistencelength,radius, D,par3,par4)
	variable Persistencelength,Rcluster,D,radius,par3,par4
	variable v=pi*persistencelength*radius^2//vol of one primary
	 v*=(Rcluster/persistencelength)^D//mult by numb er of primaries
        return v
end
	
function  IR1T_FractalAggofDisksFF(Q,thickness, persistencelength,Rcluster,D,par4,par5)
	variable Q,thickness, persistencelength,Rcluster,D,par4,par5
	variable fractalpart,diskpart
	Fractalpart=IR1T_FractalCluster(q,Rcluster,persistencelength,D)
	FractalPart/=(gamma(D+1)*(Rcluster/persistencelength)^D)^.5//normalize to one at low q
	diskpart =IR1T_UniFiedDiskFF(Q,persistencelength,thickness,0,0,0,0)
	return fractalpart*diskpart
end

function IR1T_FractalAggofDisksVol(Rcluster, thickness,Persistencelength,radius, D,par3,par4)
	variable Rcluster, thickness,Persistencelength,D,radius,par3,par4
	variable v=pi*(persistencelength^2)*thickness//vol of one primary
	 v*=(Rcluster/persistencelength)^D//mult by numb er of primaries	         	
        return v
end

function IR1T_FractalAggofTubesFF(Q,Rcluster, persistencelength,radius,D,thickness,par5)//added RSJ 6July2006
	variable Q,radius,persistencelength,rcluster,D,thickness,par5
	variable fractalpart,tubepart
	Fractalpart=IR1T_FractalCluster(q,Rcluster,persistencelength,D)
	FractalPart/=(gamma(D+1)*(Rcluster/persistencelength)^D)^.5//normalize to one at low q
	tubepart =IR1T_UniFiedtubeFF(Q,radius,persistencelength,thickness,1,1,1)
	return (fractalpart*tubepart)//needs to be squared
	
end

function IR1T_FractalAggofTubesVol(Rcluster, persistencelength,radius,D,thickness,par5)//added RSJ 6July2006
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

	Make/D/O/N=500 IntgWave
	SetScale/I x 0,(pi/2),"", IntgWave
	variable tempRad

	For (i=0;i<numbOfSteps;i+=1)									//here we go through number of points in R in the whole interval...

		tempRad=radius+i*stepR
		//include some spread of wall thicknesses here
		CurrentWallThickness=WallThickness//+(WallThicknessPrecision/(numbOfSteps/2))*(i-(numbOfSteps/2))		//this varies diameter within this bin by using bin width to din middle ratio...
		//let's see if this smears out some of the oscillations...
		IntgWave=IR1T_CalcTubeFFPoints(Qvalue,tempRad,Length, CurrentWallThickness,CoreShellCoreRho,CoreShellShellRho, CoreShellSolvntRho,x)	//this calculates for each diameter and Q value wave of results for various theta angles
		IntgWave=IntgWave^2										//get second power of this before integration
		IntgWave=IntgWave*sin(x)										//multiply by sin alpha which is x from 0 to 90 deg
		tempResult= area(IntgWave, 0,(pi/2))					//and here we integrate over alpha

		tempResult=tempResult*(IR1T_TubeVolume(radius,Length, WallThickness))^VolumePower			//multiply by volume of shell squared
		result+=tempResult											//and add the values together...
	endFor
	
	KillWaves IntgWave
	result/=numbOfSteps											//this averages the values obtained over the interval....

	setDataFolder OldDf

	return result

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IR1T_CalcTubeFFPointsNIST(Qvalue,radius,VolumePower,Length,WallThickness,CoreShellCoreRho,CoreShellShellRho, CoreShellSolvntRho)
	variable Qvalue, radius,VolumePower, Length, WallThickness,CoreShellCoreRho,CoreShellShellRho, CoreShellSolvntRho		
	
	string OldDf=GetDataFolder(1)
	
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
//
// the OUTPUT form factor is <f^2>/Vcyl [cm-1]
//

// local variables
	Variable nord,ii,va,vb,contr,vcyl,nden,summ,yyy,zi,qq,halfheight
	Variable answer
	String weightStr,zStr
	
	weightStr = "gauss76wt"
	zStr = "gauss76z"

	
//	if wt,z waves don't exist, create them
// 20 Gauss points is not enough for cylinder calculation
	
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
		Wave z76 = $zStr		// Not sure why this has to be "declared" twice
	endif


// set up the integration
	// end points and weights
	nord = 76
	va = 0
	vb = Pi/2
      halfheight = length/2.0

// evaluate at Gauss points 
	// remember to index from 0,size-1

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
//   
// calculate value of integral to return

      answer = (vb-va)/2.0*summ
      
// contrast is now explicitly included in the core-shell calculation

//normalize by cylinder volume
//NOTE that for this (Fournet) definition of the integral, one must MULTIPLY by Vcyl
//calculate TOTAL volume
// length is the total core length 
	//vcyl=Pi*(rcore+thick)*(rcore+thick)*(length+2*thick)
	vcyl=IR1T_TubeVolume(rcore,length, thick)
	answer /= vcyl
	answer *= vcyl^(VolumePower-1)
//convert to [cm-1]
//	answer *= 1.0e8
//Scale
///	answer *= scale
// add in the background
///	answer += bkg

	setDataFolder OldDf
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
		SmallBessDivided=BessJ(1, SmallBesArg)/SmallBesArg
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
		SmallBessShellDivided=BessJ(1, SmallBesShellArg)/SmallBesShellArg
	endif

	Variable ratioOfVolumes=IR1T_TubeVolume(radius,Length,WallThickness)/IR1T_TubeVolume(radius+WallThickness,Length,WallThickness)
	

	return 2*ratioOfVolumes*(CoreShellCoreRho-CoreShellShellRho)*(LargeBes*SmallBessDivided)+2*(CoreShellShellRho - CoreShellSolvntRho)*(LargeBesShell*SmallBessShellDivided)
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1T_TubeVolume(radius,Length,thick)							//returns the tube volume...
	variable radius, Length, thick

	SVAR/Z CoreShellVolumeDefinition = root:Packages:FormFactorCalc:CoreShellVolumeDefinition
	if(!SVAR_exists(CoreShellVolumeDefinition))
		DoAlert 0, "Please reinitialize the package. CoreShellCylinder definition has changed. Please read Readme.txt"
		abort
	endif
	
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

static Function IR1T_CoreShellVolume(radius,thick)							//returns the tube volume...
	variable radius, thick

	SVAR/Z CoreShellVolumeDefinition = root:Packages:FormFactorCalc:CoreShellVolumeDefinition
	if(!SVAR_exists(CoreShellVolumeDefinition))
		DoAlert 0, "Please reinitialize the package. CoreShell definition has changed. Please read Readme.txt"
		abort
	endif
	
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


static Function IR1_CalcIntgCylinderFFPnts(Qvalue,radius,VolumePower,radiusMin,radiusMax,Length)		//we have to integrate from 0 to 1 over cos(th)
	variable Qvalue, Length,radius,radiusMin,radiusMax,VolumePower				//and integrate over points in QR...

	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:FormFactorCalc


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

	Make/D/O/N=500 IntgWave
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
	
	KillWaves IntgWave
	result/=numbOfSteps													//this averages the values obtained over the interval....

	setDataFolder OldDf

	return result

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1T_CalcCylinderFFPoints(Qvalue,radius,Length,Alpha)
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
		SmallBessDivided=BessJ(1, SmallBesArg)/SmallBesArg
	endif
	return (LargeBes*SmallBessDivided)

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1T_CylinderVolume(radius,Length)							//returns the cylinder volume...
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
	
	FRwave=IR1T_CalculateSphereFFPoints(Qw[p],radius)		//calculates the formula 
	FRwave*=FRwave											//second power of the value
end




//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1T_CalculateIntgSphereFFPnts(Qvalue,Radius,VolumePower,RadiusMin,RadiusMax)
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

static  Function IR1T_BinWidthInRadia(R_distribution,i)			//calculates the width in radia by taking half distance to point before and after
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

Static Function IR1_StartOfBinInDiameters(D_distribution,i)			//calculates the start of the bin in radii by taking half distance to point before and after
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

static Function IR1T_SphereVolume(radius)							//returns the sphere...
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

	Make/O/D/N=50 IntgWave
	SetScale/I x 0,1,"", IntgWave
	IntgWave=IR1T_CalcSpheroidFFPoints(Qvalue,radius,AR, x)	//this 
	IntgWave*=IntgWave						//calculate second power before integration, thsi was bug
	variable result= area(IntgWave, 0,1)
	KillWaves IntgWave
	setDataFolder OldDf
	return result
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1T_CalculateSphereFFPoints(Qvalue,radius)
	variable Qvalue, radius										//does the math for Sphere Form factor function
	variable QR=Qvalue*radius

	return (3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1T_CalcSpheroidFFPoints(Qvalue,radius,AR,CosTh)
	variable Qvalue, radius	, AR, CosTh							//does the math for Spheroid Form factor function
	variable QR=Qvalue*radius*sqrt(1+(((AR*AR)-1)*CosTh*CosTh))

	return (3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1T_SpheroidVolume(radius,AspectRatio)							//returns the spheroid volume...
	variable radius, AspectRatio
	return ((4/3)*pi*radius*radius*radius*AspectRatio)				//what is the volume of spheroid?
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1T_CalcIntgIntgSpheroidFFPnts(Qvalue,radius,VolumePower,radiusMin,radiusMax,AR)		//we have to integrate from 0 to 1 over cos(th)
	variable Qvalue,  AR,radius,radiusMin,radiusMax,VolumePower				//and integrate over points in QR...

	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:FormFactorCalc


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

	Make/D/O/N=50 IntgWave
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
	
	KillWaves IntgWave
	AverageVolume=AverageVolume/numbOfSteps
	result=(result/numbOfSteps)*AverageVolume^VolumePower						//this averages the values obtained over the interval....

	setDataFolder OldDf

	return result

end



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1T_CalcFractAggFormFactor(FRwave,Qw,currentR,VolumePower,Param1,Param2)	
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


static  Function IR1T_CalcSphereFormFactor(QVal,currentR)
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


static  Function IR1T_CalculateFractAggSQPoints(Qvalue,R,r0, D)
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

static  Function IR1T_VolumeOfFractalAggregate(FractalRadius, PrimaryPartRadius,Dimension)
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
		NewNotebook/K=3/N=$nb/F=1/V=1/K=0/W=(221.25,52.25,712.5,530) as "HowToUseUserFF"
		Notebook $nb defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
		Notebook $nb showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",10,0,(0,0,0)}
		Notebook $nb ruler=Normal, fSize=12, fStyle=1, text="How to use \"User\" form factor\r"
		Notebook $nb fSize=-1, fStyle=-1, text="\r"
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
Function IR1T_MakeFFParamPanel(TitleStr,FFStr,P1Str,FitP1Str,LowP1Str,HighP1Str,P2Str,FitP2Str,LowP2Str,HighP2Str,P3Str,FitP3Str,LowP3Str,HighP3Str,P4Str,FitP4Str,LowP4Str,HighP4Str,P5Str,FitP5Str,LowP5Str,HighP5Str,FFUserFFformula,FFUserVolumeFormula)
	string TitleStr,FFStr,P1Str,FitP1Str,LowP1Str,HighP1Str,P2Str,FitP2Str,LowP2Str,HighP2Str,P3Str,FitP3Str,LowP3Str,HighP3Str,P4Str,FitP4Str,LowP4Str,HighP4Str,P5Str,FitP5Str,LowP5Str,HighP5Str,FFUserFFformula,FFUserVolumeFormula
	//to use this panel, provide strings with paths to controled variables - or "" if the variable does not exist
	
	string OldDf=GetDataFolder(1)
	if(!DataFolderExists("root:Packages:FormFactorCalc"))
		IR1T_InitFormFactors()
	endif
	SetDataFolder root:Packages:FormFactorCalc
	SVAR ListOfFormFactors=root:Packages:FormFactorCalc:ListOfFormFactors
	SVAR CoreShellVolumeDefinition=root:Packages:FormFactorCalc:CoreShellVolumeDefinition
	
	DoWindow FormFactorControlScreen
	if(V_Flag)
		DoWindow/K FormFactorControlScreen
	endif
	SVAR CurFF=$(FFStr)

		NVAR FitP1=$(FitP1Str)
		NVAR FitP2=$(FitP2Str)
		NVAR FitP3=$(FitP3Str)
		NVAR FitP4=$(FitP4Str)
		NVAR FitP5=$(FitP5Str)

	//need to disable usused fitting parameters so the code which is using this package does not have to contain list of form factors... 
	
	//go through all form factors knwon and set the ones unsused to zeroes...
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
	elseif(stringmatch(CurFF,"CylinderAR"))
		FitP2=0
		FitP3=0
		FitP4=0
		FitP5=0
	elseif(stringmatch(CurFF,"CoreShell"))
		FitP5=0
	elseif(stringmatch(CurFF,"CoreShellCylinder"))
	
	elseif(stringmatch(CurFF,"User"))
	
	elseif(stringmatch(CurFF,"Integreated_Spheroid"))
		FitP2=0
		FitP3=0
		FitP4=0
		FitP5=0
	elseif(stringmatch(CurFF,"Algebraic_*"))
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


	if(stringmatch(CurFF,"Unified_Sphere")||stringmatch(CurFF,"NoFF_setTo1"))			//does not need this screen!!!
		setDataFolder OldDf
		abort	
	endif	
	//make the new panel 
	NewPanel/K=1 /W=(96,94,530,370) as "FormFactorControlScreen"
	DoWindow/C FormFactorControlScreen
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

	SVAR/Z CurrentFF=$(FFStr)
	if(!SVAR_Exists(CurrentFF))
		Abort "Error in call to FF control panel. Current FF string does not exist. This is bug!"
	endif
	SetVariable FormFactor title="Form factor: ", pos={10,50}, noedit=1, size={300,16},disable=2,frame=0,fSize=16,fstyle=1
	SetVariable FormFactor variable=CurrentFF
	SetVariable FormFactor help={"Form factor to be used"}

	//Unified_Sphere			none needed

	//for these we need just one parameter, that is aspect ratio....
	//spheroid				AspectRatio = ParticlePar1
	//Integrated_Spheroid		AspectRatio=ParticlePar1
	//Algebraic_Globules		AspectRatio = ParticlePar1
	//Algebraic_Rods			AspectRatio = ParticlePar1, AR > 10
	//Algebraic_Disks			AspectRatio = ParticlePar1, AR < 0.1
//first variable......
	NVAR/Z CurVal= $(P1Str)
	if(!NVAR_Exists(CurVal))
		Abort "at least one parameter must exist for this shape, bug"
	endif
	SetVariable P1Value,limits={0,Inf,0},variable= $(P1Str), proc=IR1T_FFCntrlPnlSetVarProc
	SetVariable P1Value,pos={5,100},size={180,15},title="Aspect ratio = ", help={"Aspect ratio of this shape (Form factor). Larger than 1 is elongated, less than 1 is prolated object"}, fSize=10
	NVAR/Z CurVal= $(FitP1Str)
	NVAR/Z CurVal2= $(LowP1Str)
	NVAR/Z CurVal3= $(HighP1Str)
	
	if (strlen(FitP1Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
		CheckBox FitP1Value,pos={200,100},size={25,16},proc=IR1T_FFCntrlPnlCheckboxProc,title=" "
		CheckBox FitP1Value,variable= $(FitP1Str), help={"Fit this parameter?"}
		NVAR disableMe= $(FitP1Str)
		SetVariable P1LowLim,limits={0,Inf,0},variable= $(LowP1Str), disable=!disableMe
		SetVariable P1LowLim,pos={220,100},size={80,15},title=" ", help={"Low limit for fitting param 1"}, fSize=10
		SetVariable P1HighLim,limits={0,Inf,0},variable= $(HighP1Str), disable=!disableMe
		SetVariable P1HighLim,pos={320,100},size={80,15},title=" ", help={"High limit for fitting param 1"}, fSize=10
	endif
	
	//these we need to rename the parameter 1 only...
	if(stringmatch(CurrentFF,"Cylinder"))
		//Cylinder				Length=ParticlePar1
		SetVariable P1Value, title="Length = ", help={"Length of the cylinder in same units as the radius"}, fSize=10
	elseif(stringmatch(CurrentFF,"CylinderAR"))
		//CylinderAR				AspectRatio=ParticlePar1
		SetVariable P1Value, title="Aspect ratio = ", help={"Aspect ratio of the cylinder. Length / radius"}, fSize=10
	elseif(stringmatch(CurrentFF,"Unified_Disk"))
		SetVariable P1Value, title="Thickness = ", help={"Thickness of the disk in same units as radius"}, fSize=10
	elseif(stringmatch(CurrentFF,"Unified_Rod"))
		SetVariable P1Value, title="Length = ", help={"Length of the rod. Same units as radius"}, fSize=10
	elseif(stringmatch(CurrentFF,"Unified_RodAR"))
		SetVariable P1Value, title="Aspect ratio = ", help={"Aspect ratio of the rod. Length / radius"}, fSize=10
	elseif(stringmatch(CurrentFF,"Unified_tube"))
		SetVariable P1Value, title="Length = ", help={"Length in angstroems"}, fSize=10
	elseif(stringmatch(CurrentFF,"Fractal aggregate"))
		SetVariable P1Value, title="Frctl rad. prim part = ", help={"Fractal Radius of primary particle"}, fSize=10
	endif

		//Fractal aggregate	 	FractalRadiusOfPriPart=ParticlePar1=root:Packages:Sizes:FractalRadiusOfPriPart	//radius of primary particle
		//						FractalDimension=ParticlePar2=root:Packages:Sizes:FractalDimension			//Fractal dimension

	if(stringmatch(CurrentFF,"Fractal aggregate")|| stringmatch(CurrentFF,"Unified_Tube"))
		NVAR/Z CurVal= $(FitP2Str)
		NVAR/Z CurVal2= $(LowP2Str)
		NVAR/Z CurVal3= $(HighP2Str)
		SetVariable P2Value,limits={0,Inf,0},variable= $(P2Str), proc=IR1T_FFCntrlPnlSetVarProc
		SetVariable P2Value,pos={5,120},size={180,15},title="Fractal dimension = ", help={"Fractal dimension"}, fSize=10
		if (strlen(FitP2Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP2Value,pos={200,120},size={25,16},proc=IR1T_FFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP2Value,variable= $(FitP2Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP2Str)
			SetVariable P2LowLim,limits={0,Inf,0},variable= $(LowP2Str), disable=!disableMe
			SetVariable P2LowLim,pos={220,120},size={80,15},title=" ", help={"Low limit for fitting param 2"}, fSize=10
			SetVariable P2HighLim,limits={0,Inf,0},variable= $(HighP2Str), disable=!disableMe
			SetVariable P2HighLim,pos={320,120},size={80,15},title=" ", help={"High limit for fitting param 2"}, fSize=10
		endif
	endif
	if(stringmatch(CurrentFF,"Unified_Tube"))
		SetVariable P2Value,title="Wall thickness = ", help={"Wall thickness in A"}, fSize=10	
	endif

	if(stringmatch(CurrentFF,"User") || stringmatch(CurrentFF,"CoreShellCylinder") || stringmatch(CurrentFF,"CoreShell"))
		//define next 3 parameters ( need at least 4 arams for these three...)
		NVAR/Z CurVal= $(FitP2Str)
		NVAR/Z CurVal2= $(LowP2Str)
		NVAR/Z CurVal3= $(HighP2Str)
		SetVariable P2Value,limits={0,Inf,0},variable= $(P2Str), proc=IR1T_FFCntrlPnlSetVarProc
		SetVariable P2Value,pos={5,120},size={180,15},title="Fractal dimension = ", help={"Fractal dimension"}, fSize=10
		if (strlen(FitP2Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP2Value,pos={200,120},size={25,16},proc=IR1T_FFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP2Value,variable= $(FitP2Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP2Str)
			SetVariable P2LowLim,limits={0,Inf,0},variable= $(LowP2Str), disable=!disableMe
			SetVariable P2LowLim,pos={220,120},size={80,15},title=" ", help={"Low limit for fitting param 2"}, fSize=10
			SetVariable P2HighLim,limits={0,Inf,0},variable= $(HighP2Str), disable=!disableMe
			SetVariable P2HighLim,pos={320,120},size={80,15},title=" ", help={"High limit for fitting param 2"}, fSize=10
		endif

		NVAR/Z CurVal= $(FitP3Str)
		NVAR/Z CurVal2= $(LowP3Str)
		NVAR/Z CurVal3= $(HighP3Str)
		SetVariable P3Value,limits={0,Inf,0},variable= $(P3Str), proc=IR1T_FFCntrlPnlSetVarProc
		SetVariable P3Value,pos={5,140},size={180,15},title="Fractal dimension = ", help={"Fractal dimension"}, fSize=10
		if (strlen(FitP3Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP3Value,pos={200,140},size={25,16},proc=IR1T_FFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP3Value,variable= $(FitP3Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP3Str)
			SetVariable P3LowLim,limits={0,Inf,0},variable= $(LowP3Str), disable=!disableMe
			SetVariable P3LowLim,pos={220,140},size={80,15},title=" ", help={"Low limit for fitting param 3"}, fSize=10
			SetVariable P3HighLim,limits={0,Inf,0},variable= $(HighP3Str), disable=!disableMe
			SetVariable P3HighLim,pos={320,140},size={80,15},title=" ", help={"High limit for fitting param 3"}, fSize=10
		endif

		NVAR/Z CurVal= $(FitP4Str)
		NVAR/Z CurVal2= $(LowP4Str)
		NVAR/Z CurVal3= $(HighP4Str)
		SetVariable P4Value,limits={0,Inf,0},variable= $(P4Str), proc=IR1T_FFCntrlPnlSetVarProc
		SetVariable P4Value,pos={5,160},size={180,15},title="Fractal dimension = ", help={"Fractal dimension"}, fSize=10
		if (strlen(FitP4Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
			CheckBox FitP4Value,pos={200,160},size={25,16},proc=IR1T_FFCntrlPnlCheckboxProc,title=" "
			CheckBox FitP4Value,variable= $(FitP4Str), help={"Fit this parameter?"}
			NVAR disableMe= $(FitP4Str)
			SetVariable P4LowLim,limits={0,Inf,0},variable= $(LowP4Str), disable=!disableMe
			SetVariable P4LowLim,pos={220,160},size={80,15},title=" ", help={"Low limit for fitting param 4"}, fSize=10
			SetVariable P4HighLim,limits={0,Inf,0},variable= $(HighP4Str), disable=!disableMe
			SetVariable P4HighLim,pos={320,160},size={80,15},title=" ", help={"High limit for fitting param 4"}, fSize=10
		endif
		
		if(stringmatch(CurrentFF,"CoreShell"))
		//CoreShell				CoreShellThickness=ParticlePar1			//skin thickness in Angstroems
		//						CoreRho=ParticlePar2		// rho for core material
		//						ShellRho=ParticlePar3			// rho for shell material
		//						SolventRho=ParticlePar4			// rho for solvent material
			SetVariable P1Value, title="CoreShellThickness [A]= ", help={"Thickness of the core shell layer in Angstroems"}, fSize=10
			SetVariable P2Value, title="Core Rho = ", help={"Scattering length density of core"}, fSize=10
			SetVariable P3Value, title="Shell Rho = ", help={"Scattering length density of shell "}, fSize=10
			SetVariable P4Value, title="Solvent Rho = ", help={"Solvent Scattering length density"}, fSize=10
		
		endif
		if(stringmatch(CurrentFF,"CoreShellCylinder" ) || stringmatch(CurrentFF,"User"))
			//add fifth set of values... 
			NVAR/Z CurVal= $(FitP5Str)
			NVAR/Z CurVal2= $(LowP5Str)
			NVAR/Z CurVal3= $(HighP5Str)
			SetVariable P5Value,limits={0,Inf,0},variable= $(P5Str), proc=IR1T_FFCntrlPnlSetVarProc
			SetVariable P5Value,pos={5,180},size={180,15},title="Fractal dimension = ", help={"Fractal dimension"}, fSize=10
			if (strlen(FitP5Str)>6 && NVAR_Exists(CurVal)&& NVAR_Exists(CurVal2)&& NVAR_Exists(CurVal3))
				CheckBox FitP5Value,pos={200,180},size={25,16},proc=IR1T_FFCntrlPnlCheckboxProc,title=" "
				CheckBox FitP5Value,variable= $(FitP5Str), help={"Fit this parameter?"}
				NVAR disableMe= $(FitP5Str)
				SetVariable P5LowLim,limits={0,Inf,0},variable= $(LowP5Str), disable=!disableMe
				SetVariable P5LowLim,pos={220,180},size={80,15},title=" ", help={"Low limit for fitting param 5"}, fSize=10
				SetVariable P5HighLim,limits={0,Inf,0},variable= $(HighP5Str), disable=!disableMe
				SetVariable P5HighLim,pos={320,180},size={80,15},title=" ", help={"High limit for fitting param5"}, fSize=10
			endif		
		endif
		if(stringmatch(CurrentFF,"CoreShellCylinder"))
		//CoreShellCylinder 					length=ParticlePar1						//length in A
		//						WallThickness=ParticlePar2				//in A
		//						CoreRho=ParticlePar3			// rho for core material
		//						ShellRho=ParticlePar4			// rho for shell material
		//						SolventRho=ParticlePar5			// rho for solvent material
			SetVariable P1Value, title="Length [A] = ", help={"Length of CoreShellCylinder in A"}, fSize=10
			SetVariable P2Value, title="WallThickness [A] = ", help={"Wall thickness"}, fSize=10
			SetVariable P3Value, title="Core Rho = ", help={"Scattering length density of core "}, fSize=10
			SetVariable P4Value, title="Shell Rho = ", help={"Shell Scattering length density"}, fSize=10
			SetVariable P5Value, title="Solvent Rho = ", help={"Solvent Scattering length density"}, fSize=10
		
		endif
		if(stringmatch(CurrentFF,"User"))
		//User					uses user provided functions. There are two userprovided fucntions necessary - F(q,R,par1,par2,par3,par4,par5)
		//						and V(R,par1,par2,par3,par4,par5)
		//						the names for these need to be provided in strings... 
		//						the input is q and R in angstroems 	
			SetVariable P1Value, title="Param 1 = ", help={"Parameter 1 for this From factor"}, fSize=10
			SetVariable P2Value, title="Param 2 = ", help={"Parameter 2 for this From factor"}, fSize=10
			SetVariable P3Value, title="Param 3 = ", help={"Parameter 3 for this From factor "}, fSize=10
			SetVariable P4Value, title="Param 4 = ", help={"Parameter 4 for this From factor"}, fSize=10
			SetVariable P5Value, title="Param 5 = ", help={"Parameter 5 for this From factor"}, fSize=10
			SVAR/Z test1=$(FFUserFFformula)
			SVAR/Z test2=$(FFUserVolumeFormula)
			if(SVAR_Exists(test1) && SVAR_Exists(test2))
				SetVariable FFUserFFformula,variable= $(FFUserFFformula)
				SetVariable FFUserFFformula,pos={5,210},size={380,20},title="Name of FormFactor function ", help={"The name of form factor function (see FF manual!)"}, fSize=12
				SetVariable FFUserVolumeFormula,variable= $(FFUserVolumeFormula)
				SetVariable FFUserVolumeFormula,pos={5,240},size={380,20},title="Name of volume FF function ", help={"The name of factor function calculating the volume of particle (see FF manual!)"}, fSize=12
			endif
		endif

		if(stringmatch(CurrentFF,"CoreShellCylinder")||stringmatch(CurrentFF,"CoreShell"))	//special controls for core shell particles... 
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

	if(stringmatch("P1Value",ctrlName))
		ControlInfo/W=FormFactorControlScreen P1value
		NVAR P1Var=$(S_DataFolder+S_value)
		ControlInfo/W=FormFactorControlScreen P1LowLim
		NVAR P1LowLimVar=$(S_DataFolder+S_value)
		ControlInfo/W=FormFactorControlScreen P1HighLim
		NVAR P1HighLimVar=$(S_DataFolder+S_value)
		P1LowLimVar=0.8 *  P1Var
		P1HighLimVar= 1.2 * P1Var
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
//	SVAR FFParamPanelControls=root:Packages:FormFactorCalc:FFParamPanelControls
	string ListOfParams="TitleStr;FFStr;P1Str;FitP1Str;LowP1Str;HighP1Str;P2Str;FitP2Str;LowP2Str;HighP2Str;P3Str;FitP3Str;LowP3Str;HighP3Str;P4Str;FitP4Str;LowP4Str;HighP4Str;P5Str;FitP5Str;LowP5Str;HighP5Str"

	if(stringMatch(ctrlName,"FitP1Value"))
		SetVariable P1LowLim,disable=!(checked), win=FormFactorControlScreen
		SetVariable P1HighLim,disable=!(checked), win=FormFactorControlScreen
	endif
	if(stringMatch(ctrlName,"FitP2Value"))
		SetVariable P2LowLim,disable=!(checked), win=FormFactorControlScreen
		SetVariable P2HighLim,disable=!(checked), win=FormFactorControlScreen
	endif
	if(stringMatch(ctrlName,"FitP3Value"))
		SetVariable P3LowLim,disable=!(checked), win=FormFactorControlScreen
		SetVariable P3HighLim,disable=!(checked), win=FormFactorControlScreen
	endif
	if(stringMatch(ctrlName,"FitP4Value"))
		SetVariable P4LowLim,disable=!(checked), win=FormFactorControlScreen
		SetVariable P4HighLim,disable=!(checked), win=FormFactorControlScreen
	endif
	if(stringMatch(ctrlName,"FitP5Value"))
		SetVariable P5LowLim,disable=!(checked), win=FormFactorControlScreen
		SetVariable P5HighLim,disable=!(checked), win=FormFactorControlScreen
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
	Make/O/T/N=5 Unified_RodAR,Unified_Disk,Unified_Tube,'Fractal Aggregate', NoFF_setTo1
	
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
	CoreShellCylinder	= {"Length","Wall thickness","Core rho","Shell rho","Solvant rho"}
	User				= {"User param 1","User param 2","User param 3","User param 4","User param 5"}
	Unified_Rod			= {"Length","","","",""}
	Unified_RodAR		= {"Aspect ratio","","","",""}
	Unified_Disk		= {"Thickness","","","",""}
	Unified_Tube		= {"Length","Thickness","","",""}
	'Fractal Aggregate'	= {"Radius Primary Particle","Fractal dimension","","",""}
	
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
	
	For (i=0;i<numpnts(Distdiameters);i+=1)
		StartValue=IR1_StartOfBinInDiameters(Distdiameters,i)
		EndValue=IR1_EndOfBinInDiameters(Distdiameters,i)
		tempVolume=0
		tempVolCalc=0

		For(j=0;j<50;j+=1)
			tempRadius=(StartValue+j*(EndValue-StartValue)/50 ) /2
			
			if(cmpstr(DistShapeModel,"Unified_sphere")==0 || cmpstr(DistShapeModel,"Algebraic_Spheres")==0)		//spheroid, volume 4/3 pi * r^3 *beta
				tempVolume+=IR1T_UnifiedsphereVolume(tempRadius,0,0,0,0,0)
			elseif(cmpstr(DistShapeModel,"spheroid")==0 ||cmpstr(DistShapeModel,"Integrated_Spheroid")==0)		//spheroid, volume 4/3 pi * r^3 *beta
				tempVolume+=IR1T_SpheroidVolume(tempRadius, Par1)
			elseif(cmpstr(DistShapeModel,"Algebraic_Globules")==0)		//globule 4/3 pi * r^3 *beta
				tempVolume+=4/3*pi*(tempRadius^3)*Par1
			elseif(cmpstr(DistShapeModel,"Algebraic_Disks")==0)		//Alg disk, 
				tempVolume+=2*pi*(tempRadius^3)*Par1
			elseif(cmpstr(DistShapeModel,"Unified_Disc")==0 ||cmpstr(DistShapeModel,"Unified_Disk")==0)				//Uni & rod disk, 
				tempVolume+=IR1T_UnifiedDiscVolume(tempRadius,Par1,0,0,0,0) 					//2*pi*(tempRadius^2)*DistScatShapeParam1
			elseif(cmpstr(DistShapeModel,"Unified_rod")==0)									//Uni & rod disk, 
				tempVolume+=IR1T_UnifiedRodVolume(tempRadius,Par1,0,0,0,0) 					//2*pi*(tempRadius^2)*DistScatShapeParam1
			elseif(cmpstr(DistShapeModel,"Unified_rodAR")==0)									//Uni & rod disk, 
				tempVolume+=IR1T_UnifiedRodVolume(tempRadius,2*Par1*tempRadius,0,0,0,0) 					//2*pi*(tempRadius^2)*DistScatShapeParam1
			elseif(cmpstr(DistShapeModel,"Algebraic_Rods")==0)		//Alg rod, 
				tempVolume+=2*pi*(tempRadius^3)*Par1
			elseif(cmpstr(DistShapeModel,"cylinder")==0)											//cylinder volume = pi* r^2 * length
				tempVolume+=IR1T_CylinderVolume(tempRadius, Par1)
			elseif(cmpstr(DistShapeModel,"cylinderAR")==0)										//cylinder volume = pi* r^2 * length
				tempVolume+=IR1T_CylinderVolume(tempRadius, 2*Par1*tempRadius)
			elseif(cmpstr(DistShapeModel,"CoreShellCylinder")==0)												//CoreShellCylinder volume = pi* (r+CoreShellCylinder wall thickness)^2 * length
				tempVolume+=IR1T_TubeVolume(tempRadius,Par1,Par2)
			elseif(cmpstr(DistShapeModel,"Unified_tube")==0)			//tube volume = pi* (r+tube wall thickness)^2 * length
				tempVolume+=IR1T_UnifiedTubeVolume(tempRadius,Par1,Par2,par3,1, 1)
			elseif(cmpstr(DistShapeModel,"coreshell")==0)
				//In curretn implementation (7/5/2006) we assume volue of particle is the volue of CORE, as we use core diameter(radius) for particle description... 
				//tempVolume+=4/3*pi*((tempRadius+DistScatShapeParam1)^3)			
				//tempVolume+=4/3*pi*((tempRadius)^3)			
				tempVolume+=IR1T_CoreShellVolume(tempRadius,Par1)	
			elseif(cmpstr(DistShapeModel,"Fractal Aggregate")==0)
				tempVolume+=IR1T_FractalAggofSpheresVol(tempRadius, Par1,Par2, 1, 1, 1)
			elseif(cmpstr(DistShapeModel,"NoFF_setTo1")==0)
				tempVolume+=1
			elseif(cmpstr(DistShapeModel,"User")==0)	
					infostr = FunctionInfo(UserVolumeFnctName)
					if (strlen(infostr) == 0)
						Abort
					endif
					if(NumberByKey("N_PARAMS", infostr)!=6 || NumberByKey("RETURNTYPE", infostr)!=4)
						Abort
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
	
	For (i=0;i<numpnts(Distdiameters);i+=1)
		StartValue=IR1_StartOfBinInDiameters(Distdiameters,i)
		EndValue=IR1_EndOfBinInDiameters(Distdiameters,i)
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
			elseif(cmpstr(DistShapeModel,"Unifiedtube")==0)										//Par 1 = length, Par 2 = wall thickness... Assume two surfaces together..
					tempSurface+=2*pi*((tempRadius+Par2)^2 - tempRadius^2) + (Par1 * pi * tempRadius) + (Par1 * pi * (tempRadius+Par2))
			elseif(cmpstr(DistShapeModel,"coreshell")==0)										//Par 1 = cores shell thickness, take both surfaces....
				tempSurface+=4*pi*tempRadius^2 + 4*pi*(tempRadius+Par1)^2
			elseif(cmpstr(DistShapeModel,"Fractal Aggregate")==0)
				tempSurface+=NaN										//no idea....
			elseif(cmpstr(DistShapeModel,"NoFF_setTo1")==0)
				tempSurface+=1
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
Function IR1T_CoreShellcyl(qq, rcore, thick, rhoc,rhos,rhosolv, length, dum)
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
	
	t1 = 2*vol1*dr1*sin(sinarg1)/sinarg1*bessJ(1,besarg1)/besarg1
	t2 = 2*vol2*dr2*sin(sinarg2)/sinarg2*bessJ(1,besarg2)/besarg2
	
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
	Wave w76,z76

//	printf  "in make Gauss Pts\r"
	
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
//*****************************************************************************************************************
