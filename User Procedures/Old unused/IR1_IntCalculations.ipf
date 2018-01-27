#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.01

//thsi should be all commented out and later removed. 3/31/2017



//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.01 added license for ANL

//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from www.uni.aps.anl.gov/~ilavsky
//this package contains 
// Igor functions for modeling of SAS from various distributions of scatterers...

//Jan Ilavsky, January 2002

//please, read Readme in the distribution zip file with more details on the program
//report any problems to: ilavsky@aps.anl.gov


//Calculations of the intensity and errors....



//
//Function IR1_GraphModelData()
//	//first create waves for Distributions
//	IR1_CreateDistributionWaves()		//modified for 5
//	//next we calculate the distributions
//	IR1_CalculateDistributions()		//modified for 5
//	//now lets calculate the whole distribution together
//	IR1_CalcSumOfDistribution()		//works for 5
//	//lets update the mode median and mean
//	IR1S_UpdateModeMedianMean()		//modified for 5
//	//create graphs, if needed...
//	IR1_CreateModelGraphs()			//modified for 5
//	//and now we need to calculate the model Intensity
//	IR1_CalculateModelIntensity()		//modified for 5
//	//smear if desired
//	IR1_SmearLSQFData()
//	//now calculate the normalized error wave
//	IR1_CalculateNormalizedError("graph")
//	//append waves to the two top graphs with measured data
//	IR1_AppendModelToMeasuredData()	//modified for 5
//	DoWindow IR1S_InterferencePanel
//	if (V_Flag)
//		DoWindow/F IR1S_InterferencePanel
//	endif
//
//end
//
//
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//Function IR1_SmearLSQFData()
//
//	string OldDf=GetDataFolder(1)
//	setDataFolder root:Packages:SAS_Modeling
//	Wave ModelQvector
//	Wave DistModelIntensity
//	Wave DistModelIQ4
//	Duplicate/O DistModelIntensity, SmearedDistModelIntensity
//
//	NVAR UseSlitSmearedData=root:Packages:SAS_Modeling:UseSlitSmearedData
//	if(UseSlitSmearedData)
//		NVAR SLitLength=root:Packages:SAS_Modeling:SlitLength
//		IR1B_SmearData(DistModelIntensity, ModelQvector, slitLength, SmearedDistModelIntensity)
//	endif
//	DistModelIntensity=SmearedDistModelIntensity
//	KillWaves/Z SmearedDistModelIntensity
//	
//	DistModelIQ4=DistModelIntensity*ModelQvector^4
//
//end
//
////*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//
//Function	IR1_CalculateNormalizedError(CalledWhere)
//		string CalledWhere	// "fit" or "graph"
//
//	string OldDf
//	OldDf=GetDataFolder(1)
//	setDataFolder root:Packages:SAS_Modeling
//		if (cmpstr(CalledWhere,"fit")==0)
//			Wave/Z ExpInt=root:Packages:SAS_Modeling:FitIntensityWave
//			Wave/Z FitInt=root:Packages:SAS_Modeling:FitDistModelIntensity
//			if (WaveExists(ExpInt) && WaveExists(FitInt))
//				Wave ExpError=root:Packages:SAS_Modeling:FitErrorWave
//				Wave FitQvec=root:Packages:SAS_Modeling:FitQvectorWave
//				Duplicate /O ExpInt, NormalizedError
//				Duplicate/O FitQvec, NormErrorQvec
//				Redimension/D NormalizedError, NormErrorQvec
//				NormalizedError=(ExpInt-FitInt)/ExpError
//			endif
//		endif
//		if (cmpstr(CalledWhere,"graph")==0)
//			Wave ExpInt=root:Packages:SAS_Modeling:OriginalIntensity
//			Wave ExpError=root:Packages:SAS_Modeling:OriginalError
//			Wave FitInt=root:Packages:SAS_Modeling:DistModelIntensity
//			Wave OrgQvec=root:Packages:SAS_Modeling:OriginalQvector
//			Duplicate/O OrgQvec, NormErrorQvec
//			Duplicate/O FitInt, NormalizedError
//			Redimension/D NormalizedError, NormErrorQvec
//			NormalizedError=(ExpInt-FitInt)/ExpError
//		endif
//	
//		
//	
//	setDataFolder oldDf
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_AppendModelToMeasuredData()
//	//here we need to append waves with calculated intensities to the measured data
//
//	string oldDf=GetDataFolder(1)
//	setDataFolder root:Packages:SAS_Modeling
//
//	DoWindow IR1_LogLogPlotLSQF
//	if(!V_flag)
//		abort
//	endif
//	
//	Wave Intensity=root:Packages:SAS_Modeling:DistModelIntensity
//	Wave QVec=root:Packages:SAS_Modeling:ModelQvector
//	Wave IQ4=root:Packages:SAS_Modeling:DistModelIQ4
//	Wave/Z NormalizedError=root:Packages:SAS_Modeling:NormalizedError
//	Wave/Z NormErrorQvec=root:Packages:SAS_Modeling:NormErrorQvec
//	
//	DoWindow/F IR1_LogLogPlotLSQF
//	variable CsrAPos
//	if (strlen(CsrWave(A))!=0)
//		CsrAPos=pcsr(A)
//	else
//		CsrAPos=0
//	endif
//	variable CsrBPos
//	if (strlen(CsrWave(B))!=0)
//		CsrBPos=pcsr(B)
//	else
//		CsrBPos=numpnts(Intensity)-1
//	endif
//	
//	RemoveFromGraph /Z/W=IR1_LogLogPlotLSQF DistModelIntensity 
//	RemoveFromGraph /Z/W=IR1_LogLogPlotLSQF NormalizedError 
//	RemoveFromGraph /Z/W=IR1_IQ4_Q_PlotLSQF DistModelIQ4 
//
//	AppendToGraph/W=IR1_LogLogPlotLSQF Intensity vs Qvec
//	cursor/P/W=IR1_LogLogPlotLSQF A, OriginalIntensity, CsrAPos	
//	cursor/P/W=IR1_LogLogPlotLSQF B, OriginalIntensity, CsrBPos	
//	ModifyGraph/W=IR1_LogLogPlotLSQF rgb(DistModelIntensity)=(0,0,0)
//	ModifyGraph/W=IR1_LogLogPlotLSQF mode(OriginalIntensity)=3
//	ModifyGraph/W=IR1_LogLogPlotLSQF msize(OriginalIntensity)=1
//	TextBox/W=IR1_LogLogPlotLSQF/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
//	ShowInfo/W=IR1_LogLogPlotLSQF
//	if (WaveExists(NormalizedError))
//		AppendToGraph/R/W=IR1_LogLogPlotLSQF NormalizedError vs NormErrorQvec
//		ModifyGraph/W=IR1_LogLogPlotLSQF  mode(NormalizedError)=3,marker(NormalizedError)=8
//		ModifyGraph/W=IR1_LogLogPlotLSQF zero(right)=4
//		ModifyGraph/W=IR1_LogLogPlotLSQF msize(NormalizedError)=1,rgb(NormalizedError)=(0,0,0)
//		SetAxis/W=IR1_LogLogPlotLSQF /A/E=2 right
//		ModifyGraph/W=IR1_LogLogPlotLSQF log(right)=0
//		Label/W=IR1_LogLogPlotLSQF right "Standardized residual"
//	else
//		ModifyGraph/W=IR1_LogLogPlotLSQF mirror(left)=1
//	endif
//	ModifyGraph/W=IR1_LogLogPlotLSQF log(left)=1
//	ModifyGraph/W=IR1_LogLogPlotLSQF log(bottom)=1
//	ModifyGraph/W=IR1_LogLogPlotLSQF mirror(bottom)=1
//	Label/W=IR1_LogLogPlotLSQF left "Intensity [cm\\S-1\\M]"
//	Label/W=IR1_LogLogPlotLSQF bottom "Q [A\\S-1\\M]"
//	ErrorBars/W=IR1_LogLogPlotLSQF OriginalIntensity Y,wave=(root:Packages:SAS_Modeling:OriginalError,root:Packages:SAS_Modeling:OriginalError)
//	Legend/W=IR1_LogLogPlotLSQF/N=text0/K
//	Legend/W=IR1_LogLogPlotLSQF/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 "\\s(OriginalIntensity) Experimental intensity"
//	AppendText/W=IR1_LogLogPlotLSQF "\\s(DistModelIntensity) Model calculated Intensity"
//	if (WaveExists(NormalizedError))
//		AppendText/W=IR1_LogLogPlotLSQF "\\s(NormalizedError) Standardized residual"
//	endif
//
//
//	AppendToGraph/W=IR1_IQ4_Q_PlotLSQF IQ4 vs Qvec
//	ModifyGraph/W=IR1_IQ4_Q_PlotLSQF rgb(DistModelIQ4)=(0,0,0)
//	ModifyGraph/W=IR1_IQ4_Q_PlotLSQF mode=3
//	ModifyGraph/W=IR1_IQ4_Q_PlotLSQF msize=1
//	ModifyGraph/W=IR1_IQ4_Q_PlotLSQF log=1
//	ModifyGraph/W=IR1_IQ4_Q_PlotLSQF mirror=1
//	ModifyGraph/W=IR1_IQ4_Q_PlotLSQF mode(DistModelIQ4)=0
//	TextBox/W=IR1_IQ4_Q_PlotLSQF/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
//	Label/W=IR1_IQ4_Q_PlotLSQF left "Intensity * Q^4"
//	Label/W=IR1_IQ4_Q_PlotLSQF bottom "Q [A\\S-1\\M]"
//	ErrorBars/W=IR1_IQ4_Q_PlotLSQF OriginalIntQ4 Y,wave=(root:Packages:SAS_Modeling:OriginalErrQ4,root:Packages:SAS_Modeling:OriginalErrQ4)
//	Legend/W=IR1_IQ4_Q_PlotLSQF/N=text0/K
//	Legend/W=IR1_IQ4_Q_PlotLSQF/N=text0/J/F=0/A=MC/X=-29.74/Y=37.76 "\\s(OriginalIntQ4) Experimental intensity * Q^4"
//	AppendText/W=IR1_IQ4_Q_PlotLSQF "\\s(DistModelIQ4) Model Calculated intensity * Q^4"
//
//	setDataFolder oldDF
//
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_CalculateModelIntensity()
//	//here we need to calculate the intensities for the model distribution
//	
//	string OldDf=GetDataFolder(1)
//	setDataFolder root:Packages:SAS_Modeling
//	
//	Wave/Z 	OriginalQvector=root:Packages:SAS_Modeling:OriginalQvector
//	if (!WaveExists (OriginalQvector))
//		Abort "Select original data first"
//	endif
//	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
//	
//	Duplicate/O OriginalQvector, ModelQvector, DistModelIntensity, DistModelIQ4
//	Redimension/D ModelQvector, DistModelIntensity, DistModelIQ4
//	DistModelIntensity=0	
//
//	variable i
//	
//	For(i=1;i<=NumberOfDistributions;i+=1)
//		IR1_CalcIntFromOneDist(i,OriginalQvector)
//	endfor
//	//OK, now we have calculated intensities, lets summ tehm together
//
//	For(i=1;i<=NumberOfDistributions;i+=1)
//		Wave IntToAdd=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ModelIntensity")
//		DistModelIntensity+=IntToAdd
//	endfor
//	
//	//add background here:
//	NVAR SASBackground=root:Packages:SAS_Modeling:SASBackground
//	DistModelIntensity+=SASBackground
//	
//	DistModelIQ4=DistModelIntensity*ModelQvector^4
//	
//	setDataFolder OldDF
//end
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
////this is specialized version of Calculate model intensity
//
//Function IR1U_FitCalculateModelIntensity(MyQvectorWave)
//	Wave MyQvectorWave
//	
//	string OldDf=GetDataFolder(1)
//	setDataFolder root:Packages:SAS_Modeling
//	
//	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
//	
//	Duplicate/O MyQvectorWave, FitModelQvector, FitDistModelIntensity, FitDistModelIQ4
//	Redimension/D FitModelQvector, FitDistModelIntensity, FitDistModelIQ4
//	FitDistModelIntensity=0	
//
//	variable i
//	
//	For(i=1;i<=NumberOfDistributions;i+=1)
////		IR1_FitCalcIntFromOneDist(i, FitModelQvector)
//		IR1_CalcIntFromOneDist(i, FitModelQvector)
//	endfor
//	//OK, now we have calculated intensities, lets sum them together
//
//	For(i=1;i<=NumberOfDistributions;i+=1)
//		Wave IntToAdd=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ModelIntensity")
//		FitDistModelIntensity+=IntToAdd
//	endfor
//	
//	//add background here:
//	NVAR SASBackground=root:Packages:SAS_Modeling:SASBackground
//	FitDistModelIntensity+=SASBackground
//	
//	FitDistModelIQ4=FitDistModelIntensity*FitModelQvector^4
//	
//	setDataFolder OldDF
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_CalcIntFromOneDist(DistNum,OriginalQvector)
//	variable DistNum
//	Wave OriginalQvector
//	
//	string OldDf
//	OldDf=getDataFolder(1)
//	setDataFolder root:Packages:SAS_Modeling
//	
////	Wave OriginalQvector=root:Packages:SAS_Modeling:OriginalQvector
//	NVAR UseNumberDistribution=root:Packages:SAS_Modeling:UseNumberDistribution
//	NVAR UseVolumeDistribution=root:Packages:SAS_Modeling:UseVolumeDistribution
//	if((UseNumberDistribution+UseVolumeDistribution)!=1)
//		Abort "Error in UseVolume/Number distribution switches. Restart tool, if happens again, contact program author"
//	endif
//	Wave DistDiameters=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"diameters")
//	Wave DistNumberDist=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NumberDist")
//	Wave DistVolumeDist=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolumeDist")
//	SVAR ShapeType=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ShapeModel")
//	NVAR Param1=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam1")
//	SVAR UserVolumeFnctName=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserVolumeFnct")
//	SVAR UserFormFactorFnct=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFormFactorFnct")
//	NVAR UserPar1=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam1")
//	NVAR UserPar2=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam2")
//	NVAR UserPar3=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam3")
//	NVAR UserPar4=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam4")
//	NVAR UserPar5=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam5")
//	//Param1 is aspect ratio for spheroid, for fractals it is primary particle hard radius
//	//Param1 is the length of cylinder in [A]
//	//Param1 is skin to diameter ratio
//	//Param1 is the length of the tube
//	NVAR Param2=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam2")
//	//Param2 is core rho for core shell sphere, for fractals it is fractal dimension
//	//Param2 is the tube wall thickness in [A}
//	NVAR Param3=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam3")
//	//Param 3 is the shell rho for core shell sphere and core rho for tube
//	NVAR Param4=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam4")
//	//Param 4 is the solvent rho for core shell sphere and shell rho for tube
//	NVAR Param5=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam5")
//	//Param 5 is the solvent rho for tube
//	NVAR DistContrast=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Contrast")
//	
//	string tempName="Dist"+num2str(DistNum)+"ModelIntensity"
//	
//	Duplicate/O OriginalQvector, $tempName
//	Wave DistModelIntensity=$tempName
//	Redimension/D DistModelIntensity
//	Duplicate/O  DistDiameters, R_distribution
//	R_distribution=DistDiameters/2
////test the new method. This is the code for the nes method:
//	//testing....	New Formfactor calculations Check that the G matrix actually exists. We need it... 
//	//we will setup only form factor G matrix G_matrixFF, which will be scaled by contrats later on...
//	Wave/Z G_matrixFF=$("root:Packages:SAS_Modeling:G_matrixFF_"+num2str(DistNum))
//	variable M=numpnts(OriginalQvector)
//	variable N=numpnts(R_distribution)
//	if(!WaveExists(G_matrixFF))
//		Make/D/O/N=(M,N) $("G_matrixFF_"+num2str(DistNum))
//		Wave G_matrixFF=$("root:Packages:SAS_Modeling:G_matrixFF_"+num2str(DistNum))
//	endif	
//	//now need to set the particle parameters according to used particle shape model...
//		//Algebraic_Integrated Spheres		no parameter needed
//		//Algebraic_Globules		AspectRatio = ParticlePar1
//		//Algebraic_Rods			AspectRatio = ParticlePar1
//		//Algebraic_Disks			AspectRatio = ParticlePar1
//		//Integrated_Spheroid		AspectRatio=ParticlePar1
//		//	spheroid				AspectRatio = ParticlePar1
//
//		//Cylinders				CylinderLength=ParticlePar1
//
//		//	Fractal aggregate	 	FractalRadiusOfPriPart=ParticlePar1=root:Packages:Sizes:FractalRadiusOfPriPart	//radius of primary particle
//		//						 FractalDimension=ParticlePar2=root:Packages:Sizes:FractalDimension			//Fractal dimension
//		//Tube 					length=ParticlePar1						//length in A
//		//						WallThickness=ParticlePar2				//in A
//		//						CoreRho=ParticlePar3			// rho for core material
//		//						ShellRho=ParticlePar4			// rho for shell material
//		//						SolventRho=ParticlePar5			// rho for solvent material
//		//CoreShell				CoreShellThickness=ParticlePar1			//skin thickness in Angstroems
//		//						CoreRho=ParticlePar2		// rho for core material
//		//						ShellRho=ParticlePar3			// rho for shell material
//		//						SolventRho=ParticlePar4			// rho for solvent material
//
//	//AspectRatio;FractalRadiusOfPriPart;FractalDimension;CylinderLength;TubeLength;
//	//CylinderLength;CoreShellThicknessRatio;CoreShellContrastRatio;TubeWallThickness;TubeCoreContrastRatio
//	
//	variable ParticlePar1=0,ParticlePar2=0,ParticlePar3=0,ParticlePar4=0,ParticlePar5=0
////	SVAR ShapeType=root:Packages:Sizes:ShapeType
////	NVAR AspectRatio=root:Packages:Sizes:AspectRatio
//
//	if(cmpstr(ShapeType,"Algebraic_Integrated Spheres")==0)		//no parameter at all - it is sphere
//		//no parameter
//	elseif(cmpstr(ShapeType,"Cylinders")==0)						//Cylinder 1 poarameter - length
//	//	NVAR CylinderLength=root:Packages:Sizes:CylinderLength	//CylinderLength
//		ParticlePar1=ParticlePar1
//	elseif(cmpstr(ShapeType,"User")==0)						//Cylinder 1 poarameter - length
//	//	NVAR CylinderLength=root:Packages:Sizes:CylinderLength	//CylinderLength
//		ParticlePar1=UserPar1
//		ParticlePar2=UserPar2
//		ParticlePar3=UserPar3
//		ParticlePar4=UserPar4
//		ParticlePar5=UserPar5
//	elseif(cmpstr(ShapeType,"Janus CoreShell Micelle*")==0)						//Janus core shell Micelle has 5 parameters
//		ParticlePar1=UserPar1
//		ParticlePar2=UserPar2
//		ParticlePar3=UserPar3
//		ParticlePar4=UserPar4
//		ParticlePar5=UserPar5
//	elseif(cmpstr(ShapeType,"CoreShell")==0)				//CoreShell - 2 parameters
//		ParticlePar1=Param1
//		ParticlePar2=Param2	
//		ParticlePar3=Param3	
//		ParticlePar4=Param4	
//	elseif(cmpstr(ShapeType,"Fractal aggregate")==0)				//Fractal aggregate - 2 parameters
//		ParticlePar1=Param1
//		ParticlePar2=Param2	
//	elseif(cmpstr(ShapeType,"Unified_Tube")==0)				//Tube - 3 parameters
//		ParticlePar1=Param1
//		ParticlePar2=Param2	
//	elseif(cmpstr(ShapeType,"CoreShellCylinder")==0)				//Tube - 3 parameters
//		ParticlePar1=Param1
//		ParticlePar2=Param2	
//		ParticlePar3=Param3	
//		ParticlePar4=Param4	
//		ParticlePar5=Param5	
//	else												//the ones which require 1 parameter - aspect ratio
//		ParticlePar1=Param1
//	endif
//	
//	//end setup parameters...
//	if(UseNumberDistribution)
//		IR1T_GenerateGMatrix(G_matrixFF, OriginalQvector,R_distribution,2,ShapeType,ParticlePar1,ParticlePar2,ParticlePar3,ParticlePar4,ParticlePar5,UserFormFactorFnct,UserVolumeFnctName)
//	else
//		IR1T_GenerateGMatrix(G_matrixFF, OriginalQvector,R_distribution,1,ShapeType,ParticlePar1,ParticlePar2,ParticlePar3,ParticlePar4,ParticlePar5,UserFormFactorFnct,UserVolumeFnctName)
//	endif
//	//now handle the contarst by copying data into the G_matrix
//	Duplicate/O G_matrixFF, $("G_matrix_"+num2str(DistNum))				//G_matrixFF (root:Packages:Sizes:G_matrixFF)  contains form factor without contrast, except for Tube and Core shell...  
//	Wave G_matrix=$("G_matrix_"+num2str(DistNum))
//	if(stringmatch(ShapeType,"*CoreShell*"))
//		G_matrix=G_matrixFF * 1e20			//this shape contains contrast already in...
//	else
//		G_matrix=G_matrixFF * DistContrast*1e20		//this multiplies by scattering contrast
//	endif
//	if(UseNumberDistribution)
//		duplicate/O DistNumberDist, TepNumbDist
//		TepNumbDist=DistNumberDist[p]* IR1_BinWidthInDiameters(DistDiameters,p)
//		MatrixOp/O resultMO =G_matrix x TepNumbDist 
//		DistModelIntensity = resultMO
//		Killwaves/Z resultMO
//	else
//		duplicate/O DistVolumeDist, TepVolumeDist
//		TepVolumeDist=DistVolumeDist[p]* IR1_BinWidthInDiameters(DistDiameters,p)
//		MatrixOp/O resultMO =G_matrix x TepVolumeDist 
//		DistModelIntensity = resultMO
//		Killwaves/Z resultMO
//	endif
//
////And this is the old code
////	IR1_CalcIntensityInterStep(DistModelIntensity, DistDiameters, OriginalQvector,DistNumberDist, ShapeType, Param1, Param2, Param3 )
//	
////	DistModelIntensity*=DistContrast*1e20		//this multiplies by scattering contrast
//
//	//Interference, if needed
//	NVAR/Z UseInterference = root:Packages:SAS_Modeling:UseInterference
//	NVAR/Z DistUseInterference=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UseInterference")
//	if(NVAR_Exists(UseInterference) && NVAR_Exists(DistUseInterference))
//		if (UseInterference && DistUseInterference)
//			NVAR Phi = $("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"InterferencePhi")
//			NVAR Eta = $("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"InterferenceEta")
//			//interference		 Int(q, with interference) =Int(q)*(1-8*phi*spherefactor(q,eta))
//			DistModelIntensity /= (1+phi*IR1A_SphereAmplitude(OriginalQvector[p],Eta))
//		endif
//	endif
//	setDataFolder OldDf
//end
//
//
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_CalcIntensityInterStep(DistModelIntensity, DistDiameters, Qvector,DistNumberDist,ShapeType,Param1, Param2, Param3 )
////	Wave DistModelIntensity
////	Wave DistDiameters
////	Wave Qvector
////	Wave DistNumberDist
////	string ShapeType
////	variable Param1, Param2, Param3
////	
////	//Param1 is aspect ratio for spheroid
////	//Param1 is length for cylinder
////	//Param1 is skin to diameter ratio
////	//Param1 is for fractals primary particle hard radius
////	//Param2 is contrast of skin -to- core ratio
////	//Param2 is for fractals the fractal dimension
////	//Param1 is the length of the tube
////	//Param2 is the tube wall thickness in [A}
////	//Param 3 is the contrast of the core for the tube (core shell cylinder) 
////	
////	string oldDf
////	OldDf=GetDataFolder(1)
////	setDataFolder root:Packages:SAS_Modeling
////	variable currentD, i , CurrentMinD, CurrentMaxD
////	
////	DistModelIntensity=0		//clear the model intensity first
////		
////	Duplicate/O DistModelIntensity, tempWave //tempWave is our place for calculated intensity...		
////	Redimension/D tempWave
////		
////	For(i=0;i<numpnts(DistDiameters);i+=1)
////		currentD=DistDiameters[i]							//this is current diameter
////		CurrentMinD=IR1_StartOfBinInDiameters(DistDiameters,i)
////		CurrentMaxD=IR1_EndOfBinInDiameters(DistDiameters,i)
////		
////		if (cmpstr(ShapeType,"Sphere")==0)
////				IR1_CalculateSphereFormFactor(TempWave,Qvector,currentD,CurrentMinD,CurrentMaxD)	//here we calculate F(Qr)^2*V(r)^2
////				TempWave*=DistNumberDist[i]								  //and here we multiply by N(D)
////				TempWave*=IR1_BinWidthInDiameters(DistDiameters,i)			//multiply by the width of radii bin (DELTA D)
////				DistModelIntensity+=TempWave								//and here put it into Resulting intensity
////		endif
////		if (cmpstr(ShapeType,"Spheroid")==0)
////				IR1_CalcSpheroidFormFactor(TempWave,Qvector,currentD,CurrentMinD,CurrentMaxD,Param1)	//here we calculate F(Qr)^2
////				TempWave*=DistNumberDist[i]									//and here we multiply by N(r)
////				TempWave*=IR1_BinWidthInDiameters(DistDiameters,i)						//multiply by the width of radii bin (delta r)
////				DistModelIntensity+=TempWave								//and here put it into Resulting intensity
////		endif
////		if (cmpstr(ShapeType,"Cylinder")==0)
////				IR1_CalcCylinderFormFactor(TempWave,Qvector,currentD,CurrentMinD,CurrentMaxD,Param1)	//here we calculate F(Qr)^2
////				TempWave*=DistNumberDist[i]									//and here we multiply by N(r)
////				TempWave*=IR1_BinWidthInDiameters(DistDiameters,i)						//multiply by the width of radii bin (delta r)
////				DistModelIntensity+=TempWave								//and here put it into Resulting intensity
////		endif
////		if (cmpstr(ShapeType,"Tube")==0)
////				IR1_CalcTubeFormFactor(TempWave,Qvector,currentD,CurrentMinD,CurrentMaxD,Param1,Param2,Param3)	//here we calculate F(Qr)^2
////				TempWave*=DistNumberDist[i]									//and here we multiply by N(r)
////				TempWave*=IR1_BinWidthInDiameters(DistDiameters,i)						//multiply by the width of radii bin (delta r)
////				DistModelIntensity+=TempWave								//and here put it into Resulting intensity
////		endif
////		if (cmpstr(ShapeType,"CoreShell")==0)
////				IR1_CalcCoreShellFormFactor(TempWave,Qvector,currentD,CurrentMinD,CurrentMaxD,Param1, Param2)	//here we calculate F(Qr)^2
////				TempWave*=DistNumberDist[i]									//and here we multiply by N(r)
////				TempWave*=IR1_BinWidthInDiameters(DistDiameters,i)						//multiply by the width of radii bin (delta r)
////				DistModelIntensity+=TempWave								//and here put it into Resulting intensity
////		endif
////		if (cmpstr(ShapeType,"Fractal Aggregate")==0)
////				IR1_CalcFractAggFormFactor(TempWave,Qvector,currentD,CurrentMinD,CurrentMaxD,Param1, Param2)	//here we calculate S(Q,R,r)*F(Qr)^2
////				TempWave*=DistNumberDist[i]									//and here we multiply by N(r)
////				TempWave*=IR1_BinWidthInDiameters(DistDiameters,i)						//multiply by the width of radii bin (delta r)
////				DistModelIntensity+=TempWave								//and here put it into Resulting intensity
////		endif
////	endfor
////	//here we have corrections for units and contrast
////	DistModelIntensity*=1e-48			//this is conversion for Volume of particles from A to cm
////	
////	setDataFolder oldDf
////end
////
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_BinWidthInDiameters(D_distribution,i)			//calculates the width in diameters by taking half distance to point before and after
//	variable i								//returns number in A
//	Wave D_distribution
//	
//	variable width
//	variable Imax=numpnts(D_distribution)
//	
//	if (i==0)
//		width=D_distribution[1]-D_distribution[0]
//		if ((D_distribution[0]-(D_distribution[1]-D_distribution[0])/2)<0)
//			width=D_distribution[0]+(D_distribution[1]-D_distribution[0])/2
//		endif
//	elseif (i==Imax-1)
//		width=D_distribution[i]-D_distribution[i-1]
//	else
//		width=((D_distribution[i]-D_distribution[i-1])/2)+((D_distribution[i+1]-D_distribution[i])/2)
//	endif
//	return abs(width)		//9/17/2010, fix for user models when bins are sorted from large to small
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_StartOfBinInDiameters(D_distribution,i)			//calculates the start of the bin in radii by taking half distance to point before and after
//	variable i								//returns number in A
//	Wave D_distribution
//	
//	variable start
//	variable Imax=numpnts(D_Distribution)
//	
//	if (i==0)
//		start=D_Distribution[0]-(D_Distribution[1]-D_Distribution[0])/2
//		if (start<0)
//			start=1		//we will enforce minimum size of the scatterer as 1 A
//		endif
//	elseif (i==Imax-1)
//		start=D_Distribution[i]-(D_Distribution[i]-D_Distribution[i-1])/2
//	else
//		start=D_Distribution[i]-((D_Distribution[i]-D_Distribution[i-1])/2)
//	endif
//	return start
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_EndOfBinInDiameters(D_distribution,i)			//calculates the start of the bin in radii by taking half distance to point before and after
//	variable i								//returns number in A
//	Wave D_distribution
//	
//	variable endL
//	variable Imax=numpnts(D_distribution)
//	
//	if (i==0)
//		endL=D_distribution[0]+(D_distribution[1]-D_distribution[0])/2
//	elseif (i==Imax-1)
//		endL=D_distribution[i]+((D_distribution[i]-D_distribution[i-1])/2)//fix 2011-9-25
//	else
//		endL=D_distribution[i]+((D_distribution[i+1]-D_distribution[i])/2)
//	endif
//	return endL
//end
//
//
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_CalculateSphereFormFactor(FRwave,Qw,diameter,diameterMin,diameterMax)	
////	Wave Qw,FRwave					//returns column (FRwave) for column of Qw and diameter
////	Variable diameter,diameterMin, diameterMax	
////	
////	//more complicated way to get this simple calculations. We need to divide the interval between QrMin and QrMax 
////	//and get average value for  this oscilatory function...
////	
////	
////	FRwave=IR1_CalculateSphereFFPoints(Qw[p],diameter,diameterMin,diameterMax)		//calculates the formula 
////	FRwave*=FRwave											//second power of the value
////
////end
////
////
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_CalculateSphereFFPoints(Qvalue,diameter,diameterMin,diameterMax)
////	variable Qvalue, diameter, diameterMin, diameterMax							//does the math for Sphere Form factor function
////
////	variable QR=Qvalue*diameter/2					//OK, these are just some limiting values
////	Variable QRMin=Qvalue*diameterMin/2
////	variable QRMax=Qvalue*diameterMax/2
////	variable tempResult
////	variable result=0							//here we will stash the results in each point and then divide them by number of points
////	
////	variable numbOfSteps=floor(3+abs((10*(QRMax-QRMin)/pi)))		//depending on relationship between QR and pi, we will take at least 3
////	if (numbOfSteps>60)											//steps in QR - and maximum 60 steps. Therefore we will get reaasonable average 
////		numbOfSteps=60											//over the QR space. 
////	endif
////	variable step=(QRMax-QRMin)/(numbOfSteps-1)					//step in QR
////	variable stepR=(diameterMax/2-diameterMin/2)/(numbOfSteps-1)			//step in R associated with above, we need this to calculate volume
////	variable i, radius
////	
////	For (i=0;i<numbOfSteps;i+=1)									//here we go through number of points in QR (and R)
////		QR=QRMin+i*step
////		radius=diameterMin/2+i*stepR
////
////		tempResult=(3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))				//calculate sphere scattering factor 
////	
////		tempResult*=(IR1_SphereVolume(radius))							//multiply by volume of sphere, one step above will be ^2
////		result+=tempResult											//and add the values together...
////	endFor
////	
////	result/=numbOfSteps											//this averages the values obtained over the interval....
////	return result													//and rfeturn the value, which is now average over the QR interval.
////end
////
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_SphereVolume(radius)							//returns the sphere...
////	variable radius
////	return ((4/3)*pi*radius*radius*radius)
////end
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_CalcCoreShellFormFactor(FRwave,Qw,diameter,CurrentMinD,CurrentMaxD,Param1,Param2)	
////	Wave Qw,FRwave					//returns column (FRwave) for column of Qw and diameter
////	Variable diameter, Param1, Param2,CurrentMinD,CurrentMaxD
////	//Param1 is skin to diameter ratio
////	//Param2 is contrast of skin -to- core ratio
////	
////	FRwave=IR1_CalculateCoreShellFFPoints(Qw[p],diameter,CurrentMinD,CurrentMaxD,Param1, Param2)	//calculates the formula 
////	FRwave*=FRwave											//second power of the value
////end
////
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_CalculateCoreShellFFPoints(Qvalue,diameter,diameterMin,diameterMax, Param1, Param2)
////	variable Qvalue, diameter, diameterMin, diameterMax, Param1, Param2							//does the math for Sphere Form factor function
////	//Param1 is skin thickness to diameter ratio
////	//Param2 is contrast of skin -to- core ratio
////
////	//this is first part - core
////	
////	variable QR=Qvalue*diameter/2					//OK, these are just some limiting values
////	Variable QRMin=Qvalue*diameterMin/2
////	variable QRMax=Qvalue*diameterMax/2
////	variable tempResult
////	variable result=0							//here we will stash the results in each point and then divide them by number of points
////	variable radius
////	
////	variable numbOfSteps=floor(3+abs((10*(QRMax-QRMin)/pi)))		//depending on relationship between QR and pi, we will take at least 3
////	if (numbOfSteps>60)											//steps in QR - and maximum 60 steps. Therefore we will get reaasonable average 
////		numbOfSteps=60											//over the QR space. 
////	endif
////	variable step=(QRMax-QRMin)/(numbOfSteps-1)					//step in QR
////	variable stepR=(diameterMax/2-diameterMin/2)/(numbOfSteps-1)			//step in R associated with above, we need this to calculate volume
////	variable i
////	
////	For (i=0;i<numbOfSteps;i+=1)									//here we go through number of points in QR (and R)
////		QR=QRMin+i*step
////		radius=diameterMin/2+i*stepR
////
////		tempResult=(3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))				//calculate sphere scattering factor 
////	
////		tempResult*=(IR1_SphereVolume(radius))							//multiply by volume of sphere, one step above will be ^2
////		result+=tempResult											//and add the values together...
////	endFor
////	result=result*abs(1-Param2)									//this scales to contrast difference between shell and core
////	result/=numbOfSteps											//this averages the values obtained over the interval....
////	
////	//Now add the shell (skin) 
////	QRMin=Qvalue*diameterMin/2*(1+Param1)
////	QRMax=Qvalue*diameterMax/2*(1+Param1)
////	step=(QRMax-QRMin)/(numbOfSteps-1)	
////	stepR=(diameterMax/2*(1+Param1)-diameterMin/2*(1+Param1))/(numbOfSteps-1)
////	variable result1=0
////
////	For (i=0;i<numbOfSteps;i+=1)									//here we go through number of points in QR (and R)
////		QR=QRMin+i*step
////		radius=diameterMin/2+i*stepR
////
////		tempResult=(3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))				//calculate sphere scattering factor 
////	
////		tempResult*=(IR1_SphereVolume(radius))							//multiply by volume of sphere, one step above will be ^2
////		result1+=tempResult											//and add the values together...
////	endFor
////	result1=result1*Param2									//this scales to contrast difference between shell and core
////
////	result1/=numbOfSteps											//this averages the values obtained over the interval....
////	
////	result+=result1											//summ them together
////	
////	return result													//and return the value, which is now average over the QR interval.
////end
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_CalcFractAggFormFactor(FRwave,Qw,diameter,CurrentMinD,CurrentMaxD,Param1,Param2)	
////	Wave Qw,FRwave					//returns column (FRwave) for column of Qw and diameter
////	Variable diameter, Param1, Param2,CurrentMinD,CurrentMaxD
////	//Param1 is primary particle radius
////	//Param2 is fractal dimension
////	
////	FRwave=IR1_CalcSphereFormFactor(Qw[p],(2*Param1))	//calculates the F(Q,r) * V(r) part fo formula  
////															//this is same as for sphere of diameter = 2*Param1 (= radius of primary particle, which is hard sphere)
////	FRwave*=FRwave											//second power of the value
////	FRwave*=IR1_CalculateFractAggSQPoints(Qw[p],diameter,CurrentMinD,CurrentMaxD,Param1, Param2)
////															//this last part multiplies by S(Q) part of the formula
////end
////
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_CalcSphereFormFactor(QVal,Diameter)
////		variable Qval, diameter
////		
////		variable radius=diameter/2
////		variable QR=Qval*radius
////		
////		variable tempResult
////		tempResult=(3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))				//calculate sphere scattering factor 
////	
////		tempResult*=(IR1_SphereVolume(radius))							//multiply by volume of sphere, one step above will be ^2
////
////	return tempResult
////end
////
////
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_CalculateFractAggSQPoints(Qvalue,diameter,diameterMin,diameterMax, Param1, Param2)
////	variable Qvalue, diameter, diameterMin, diameterMax, Param1, Param2							//does the math for Sphere Form factor function
////	//Param1 is skin thickness to diameter ratio
////	//Param2 is contrast of skin -to- core ratio
////
////	//this is first part - core
////	
////	variable QR=Qvalue*diameter/2					//OK, these are just some limiting values
////	Variable QRMin=Qvalue*diameterMin/2
////	variable QRMax=Qvalue*diameterMax/2
////	variable tempResult
////	variable result=0							//here we will stash the results in each point and then divide them by number of points
////	variable radius
////	
////	variable numbOfSteps=floor(3+abs((10*(QRMax-QRMin)/pi)))		//depending on relationship between QR and pi, we will take at least 3
////	if (numbOfSteps>60)											//steps in QR - and maximum 60 steps. Therefore we will get reaasonable average 
////		numbOfSteps=60											//over the QR space. 
////	endif
////	variable step=(QRMax-QRMin)/(numbOfSteps-1)					//step in QR
////	variable stepR=(diameterMax/2-diameterMin/2)/(numbOfSteps-1)			//step in R associated with above, we need this to calculate volume
////	variable i
////	
////	For (i=0;i<numbOfSteps;i+=1)									//here we go through number of points in QR (and R)
////		QR=QRMin+i*step
////		radius=diameterMin/2+i*stepR
////
////		tempResult=IR1_Tiexerax(QR,radius,Param1, Param2)			//calculate S(Q) for fractal aggregates 
////	
////		result+=tempResult											//and add the values together...
////	endFor
////	result/=numbOfSteps											//this averages the values obtained over the interval....
////	
////	return result													//and return the value, which is now average over the QR interval.
////end
////
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_Tiexerax(qR,R,r0,D)			//Made by Dale Schaeffer, makes little sense to me....
////    variable qR,R,r0,D						//here we calculate the S(Q) part of formula for fratcal aggregates per Dale Schaefer
////    variable rtiexera
////    variable part1, part2, part3, part4, part5
////    part1=1
////    part2=(qR*r0/R)^-D
////    part3=D*(exp(gammln(D-1)))
////    part5= (1+(qR)^-2)^((D-1)/2)
////    part4=abs(sin((D-1)*atan(qR)))
//////    rtiexera=(qR*r0/radius)^-D
//////    rtiexera=rtiexera*D*(exp(gammln(D-1)))
//////    rtiexera=rtiexera/((1+(qR)^-2)^((D-1)/2))
//////    rtiexera=rtiexera*sin((D-1)*atan(qR))
//////    rtiexera=sqrt(abs(rtiexera))
////
//////	rtiexera=part1+part2*part3*part4
////	rtiexera=part1+part2*part3*part4/part5
////    return rtiexera								//irena squares it
////end
////
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_CalcSpheroidFormFactor(FRwave,Qw,diameter,CurrentMinD,CurrentMaxD,AR)	
////	Wave Qw,FRwave					//returns column (FRwave) for column of Qw and diameter
////	Variable diameter, AR,CurrentMinD,CurrentMaxD	
////	
////	FRwave=IR1_CalcIntgSpheroidFFPoints(Qw[p],diameter,CurrentMinD,CurrentMaxD,AR)	//calculates the formula 
////	// this was bug, second power needs to be done BEFORE the integration  FRwave*=FRwave											//second power of the value
////end
////
////
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_CalcIntgSpheroidFFPoints(Qvalue,diameter,diameterMin,diameterMax,AR)		//we have to integrate from 0 to 1 over cos(th)
////	variable Qvalue, diameter, AR,diameterMin,diameterMax				//and integrate over points in QR...
////
////	string OldDf=GetDataFolder(1)
////	SetDataFolder root:Packages:SAS_Modeling
////
////
////	variable QR=Qvalue*diameter/2					//OK, these are just some limiting values
////	Variable QRMin=Qvalue*diameterMin/2
////	variable QRMax=Qvalue*diameterMax/2
////	variable tempResult
////	variable result=0							//here we will stash the results in each point and then divide them by number of points
////	
////	variable numbOfSteps=floor(3+abs((10*(QRMax-QRMin)/pi)))		//depending on relationship between QR and pi, we will take at least 3
////	if (numbOfSteps>60)											//steps in QR - and maximum 60 steps. Therefore we will get reaasonable average 
////		numbOfSteps=60											//over the QR space. 
////	endif
////	variable step=(QRMax-QRMin)/(numbOfSteps-1)					//step in QR
////	variable stepR=(diameterMax/2-diameterMin/2)/(numbOfSteps-1)			//step in R associated with above, we need this to calculate volume
////	variable i
////
////	Make/D/O/N=50 IntgWave
////	SetScale/P x 0,0.02,"", IntgWave
////	variable radius
////
////	For (i=0;i<numbOfSteps;i+=1)									//here we go through number of points in R in the whole interval...
////
////		radius=diameterMin/2+i*stepR
////
////		IntgWave=IR1_CalcSpheroidFFPoints(Qvalue,radius,AR, x)	//this calculates for each diameter and Q value wave of results for various theta angles
////		IntgWave*=IntgWave										//get second power of this before integration
////		//this was bug found on 3/22/2002...
////		tempResult= area(IntgWave, 0,1)					//and here we integrate for the theta values
////
////		tempResult*=(IR1_SpheroidVolume(radius,AR))^2					//multiply by volume of sphere squared
////	
////		result+=tempResult											//and add the values together...
////	endFor
////	
////	KillWaves IntgWave
////	result/=numbOfSteps											//this averages the values obtained over the interval....
////
////	setDataFolder OldDf
////
////	return result
////
////end
////
//
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_CalcSpheroidFFPoints(Qvalue,radius,AR,CosTh)
////	variable Qvalue, radius	, AR, CosTh							//does the math for Spheroid Form factor function
////	variable QR=Qvalue*radius*sqrt(1+( ((AR*AR)-1)*CosTh*CosTh) )
////
////	return (3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))
////end
////
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_SpheroidVolume(radius,AspectRatio)							//returns the spheroid volume...
////	variable radius, AspectRatio
////	return ((4/3)*pi*radius*radius*radius*AspectRatio)				//what is the volume of spheroid?
////end
////
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_CalcCylinderFormFactor(FRwave,Qw,diameter,CurrentMinD,CurrentMaxD,Length)	
////	Wave Qw,FRwave					//returns column (FRwave) for column of Qw and diameter
////	Variable diameter, Length,CurrentMinD,CurrentMaxD	
////	
////	FRwave=IR1_CalcIntgCylinderFFPoints(Qw[p],diameter,CurrentMinD,CurrentMaxD,Length)	//calculates the formula 
////end
////
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////
////Function IR1_CalcIntgCylinderFFPoints(Qvalue,diameter,diameterMin,diameterMax,Length)		//we have to integrate from 0 to 1 over cos(th)
////	variable Qvalue, diameter, Length,diameterMin,diameterMax				//and integrate over points in QR...
////
////	string OldDf=GetDataFolder(1)
////	SetDataFolder root:Packages:SAS_Modeling
////
////
////	variable QR=Qvalue*diameter/2					//OK, these are just some limiting values
////	Variable QRMin=Qvalue*diameterMin/2
////	variable QRMax=Qvalue*diameterMax/2
////	variable tempResult
////	variable result=0							//here we will stash the results in each point and then divide them by number of points
////	
////	variable numbOfSteps=floor(3+abs((10*(QRMax-QRMin)/pi)))		//depending on relationship between QR and pi, we will take at least 3
////	if (numbOfSteps>60)											//steps in QR - and maximum 60 steps. Therefore we will get reaasonable average 
////		numbOfSteps=60											//over the QR space. 
////	endif
////	variable step=(QRMax-QRMin)/(numbOfSteps-1)					//step in QR
////	variable stepR=(diameterMax/2-diameterMin/2)/(numbOfSteps-1)			//step in R associated with above, we need this to calculate volume
////	variable i
////
////	Make/D/O/N=500 IntgWave
////	SetScale/I x 0,(pi/2),"", IntgWave
////	variable radius
////
////	For (i=0;i<numbOfSteps;i+=1)									//here we go through number of points in R in the whole interval...
////
////		radius=diameterMin/2+i*stepR
////
////		IntgWave=IR1_CalcCylinderFFPoints(Qvalue,radius,Length, x)	//this calculates for each diameter and Q value wave of results for various theta angles
////		IntgWave=IntgWave^2										//get second power of this before integration
////		IntgWave=IntgWave*sin(x)										//multiply by sin alpha which is x from 0 to 90 deg
////		tempResult= area(IntgWave, 0,(pi/2))					//and here we integrate over alpha
////
////		tempResult*=(IR1_CylinderVolume(radius,Length))^2					//multiply by volume of sphere squared
////	
////		result+=tempResult											//and add the values together...
////	endFor
////	
////	KillWaves IntgWave
////	result/=numbOfSteps											//this averages the values obtained over the interval....
////
////	setDataFolder OldDf
////
////	return result
////
////end
////
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_CalcCylinderFFPoints(Qvalue,radius,Length,Alpha)
////	variable Qvalue, radius	, Length, Alpha							//does the math for cylinder Form factor function
////	
////	variable LargeBesArg=0.5*Qvalue*length*Cos(Alpha)
////	variable LargeBes
////	if ((LargeBesArg)<1e-6)
////		LargeBes=1
////	else
////		LargeBes=sin(LargeBesArg) / LargeBesArg
////	endif
////	
////	variable SmallBesArg=Qvalue*radius*Sin(Alpha)
////	variable SmallBessDivided
////	if (SmallBesArg<1e-10)
////		SmallBessDivided=0.5
////	else
////		SmallBessDivided=BessJ(1, SmallBesArg)/SmallBesArg
////	endif
////	return (LargeBes*SmallBessDivided)
////
////end
////
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_CylinderVolume(radius,Length)							//returns the cylinder volume...
////	variable radius, Length
////	return (pi*radius*radius*Length)				
////end
////
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_CalcTubeFormFactor(FRwave,Qw,diameter,CurrentMinD,CurrentMaxD,Length,WallThickness,CoreContrastRatio)	
////	Wave Qw,FRwave					//returns column (FRwave) for column of Qw and diameter
////	Variable diameter, Length,CurrentMinD,CurrentMaxD, WallThickness,CoreContrastRatio	
////	
////	FRwave=IR1_CalcIntgTubeFFPoints(Qw[p],diameter,CurrentMinD,CurrentMaxD,Length, WallThickness,CoreContrastRatio)	//calculates the formula 
////end
////
////
////
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
//////*****************************************************************************************************************
////
////Function IR1_CalcIntgTubeFFPoints(Qvalue,diameter,diameterMin,diameterMax,Length,WallThickness,CoreContrastRatio)		//we have to integrate from 0 to 1 over cos(th)
////	variable Qvalue, diameter, Length,diameterMin,diameterMax,WallThickness,CoreContrastRatio				//and integrate over points in QR...
////
////	string OldDf=GetDataFolder(1)
////	SetDataFolder root:Packages:SAS_Modeling
////
////
////	variable QR=Qvalue*diameter/2					//OK, these are just some limiting values
////	Variable QRMin=Qvalue*diameterMin/2
////	variable QRMax=Qvalue*diameterMax/2
////	variable tempResult
////	variable result=0							//here we will stash the results in each point and then divide them by number of points
////	variable CurrentWallThickness
////	NVAR WallThicknessSpreadInFract
////	variable WallThicknessPrecision=WallThickness*WallThicknessSpreadInFract		//let's set this to fraction of wall thickness variation
////	variable numbOfSteps=floor(3+abs((10*(QRMax-QRMin)/pi)))		//depending on relationship between QR and pi, we will take at least 3
////	if (numbOfSteps>60)											//steps in QR - and maximum 60 steps. Therefore we will get reaasonable average 
////		numbOfSteps=60											//over the QR space. 
////	endif
////	variable step=(QRMax-QRMin)/(numbOfSteps-1)					//step in QR
////	variable stepR=(diameterMax/2-diameterMin/2)/(numbOfSteps-1)			//step in R associated with above, we need this to calculate volume
////	variable i
////
////	Make/D/O/N=500 IntgWave
////	SetScale/I x 0,(pi/2),"", IntgWave
////	variable radius
////
////	For (i=0;i<numbOfSteps;i+=1)									//here we go through number of points in R in the whole interval...
////
////		radius=diameterMin/2+i*stepR
////		//include some spread of wall thicknesses here
////		CurrentWallThickness=WallThickness+(WallThicknessPrecision/(numbOfSteps/2))*(i-(numbOfSteps/2))		//this varies diameter within this bin by using bin width to din middle ratio...
//////		CurrentWallThickness=WallThickness+(WallThicknessPrecision/numbOfSteps)*(i-(numbOfSteps/2))		//this varies diameter within this bin by using bin width to din middle ratio...
////		//let's see if this smears out some of the oscillations...
////		IntgWave=IR1T_CalcTubeFFPoints(Qvalue,radius,Length, CurrentWallThickness,CoreContrastRatio,x)	//this calculates for each diameter and Q value wave of results for various theta angles
////		IntgWave*=IntgWave										//get second power of this before integration
////		IntgWave=IntgWave*sin(x)										//multiply by sin alpha which is x from 0 to 90 deg
////		tempResult= area(IntgWave, 0,(pi/2))					//and here we integrate over alpha
////
////		tempResult*=(IR1T_TubeVolume(radius+WallThickness,Length))^2			//multiply by volume of shell squared
////		result+=tempResult											//and add the values together...
////	endFor
////	
////	KillWaves IntgWave
////	result/=numbOfSteps											//this averages the values obtained over the interval....
////
////	setDataFolder OldDf
////
////	return result
////
////end
////
////
//
////*********************************************************************************************
////*********************************************************************************************
//
//Function IR1_CreateModelGraphs()
//	//here we need to create the graph for model distributions
//	DoWindow IR1_Model_Distributions
//	if (V_Flag==0)
//		Execute ("IR1_Model_Distributions()")
//	endif
//	DoWindow/F IR1_Model_Distributions
//
//	DoWIndow  IR1_IQ4_Q_PlotLSQF
//	if(V_Flag)
//			AutoPositionWindow/M=1 /R=IR1_IQ4_Q_PlotLSQF IR1_Model_Distributions
//	endif	
//	IR1_AppendModelData()
//end
//
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_AppendModelData()	
//
//	string OldDf=GetDataFolder(1)
//	SetDataFolder root:Packages:SAS_Modeling
//
//
//	DoWindow IR1_Model_Distributions
//	if (V_Flag==0)
//		abort
//	endif	
//	DoWindow/F IR1_Model_Distributions
//
//	RemoveFromGraph /Z /W=IR1_Model_Distributions Dist1NumberDist
//	RemoveFromGraph /Z /W=IR1_Model_Distributions Dist1VolumeDist
//	RemoveFromGraph /Z /W=IR1_Model_Distributions Dist2NumberDist
//	RemoveFromGraph /Z /W=IR1_Model_Distributions Dist2VolumeDist
//	RemoveFromGraph /Z /W=IR1_Model_Distributions Dist3NumberDist
//	RemoveFromGraph /Z /W=IR1_Model_Distributions Dist3VolumeDist
//	RemoveFromGraph /Z /W=IR1_Model_Distributions Dist4NumberDist 
//	RemoveFromGraph /Z /W=IR1_Model_Distributions Dist4VolumeDist
//	RemoveFromGraph /Z /W=IR1_Model_Distributions Dist5NumberDist 
//	RemoveFromGraph /Z /W=IR1_Model_Distributions Dist5VolumeDist
//	RemoveFromGraph /Z /W=IR1_Model_Distributions TotalVolumeDist
//	RemoveFromGraph /Z /W=IR1_Model_Distributions TotalNumberDist
//	
//	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
//	NVAR DisplayND=root:Packages:SAS_Modeling:DisplayND
//	NVAR DisplayVD=root:Packages:SAS_Modeling:DisplayVD
//
//	variable i, numOfNDWavesInGraph, numOfVDWavesInGraph
//	numOfNDWavesInGraph=0
//	numOfVDWavesInGraph=0
//	
//	if (DisplayND)
//		IR1_AppendTOTNDDistToGraph()
//		numOfNDWavesInGraph=1
//		For(i=1;i<=NumberOfDistributions;i+=1)
//			IR1_AppendNDDistToGraph(i)
//			numOfNDWavesInGraph+=1
//		endfor
//		ModifyGraph lsize(TotalNumberDist)=2		
//		For(i=1;i<=numOfNDWavesInGraph;i+=1)
//			ModifyGraph/Z mode[i]=1
//		endfor
//		ModifyGraph/Z rgb[0]=(52224,0,0)
//		ModifyGraph/Z rgb[1]=(0,52224,0)
//		ModifyGraph/Z rgb[2]=(0,0,52224)
//		ModifyGraph/Z rgb[3]=(52224,0,41728)
//		ModifyGraph/Z rgb[4]=(52224,52224,0)
//		ModifyGraph/Z rgb[4]=(16300,16300,0)
//	endif
//	if(DisplayVD)
//		IR1_AppendTOTVDDistToGraph()
//		numOfVDWavesInGraph=1
//		For(i=1;i<=NumberOfDistributions;i+=1)
//			IR1_AppendVDDistToGraph(i)
//			numOfVDWavesInGraph+=1
//		endfor
//		For(i=0;i<numOfVDWavesInGraph;i+=1)
//			ModifyGraph/Z lsize[numOfNDWavesInGraph+i]=3
//			ModifyGraph/Z mode[numOfNDWavesInGraph+i]=0
//			ModifyGraph lstyle[numOfNDWavesInGraph+i]=3
//		endfor
//		ModifyGraph lstyle[numOfNDWavesInGraph]=0
//		
//		ModifyGraph/Z rgb[numOfNDWavesInGraph+0]=(52224,0,0)
//		ModifyGraph/Z rgb[numOfNDWavesInGraph+1]=(0,52224,0)
//		ModifyGraph/Z rgb[numOfNDWavesInGraph+2]=(0,0,52224)
//		ModifyGraph/Z rgb[numOfNDWavesInGraph+3]=(52224,0,41728)
//		ModifyGraph/Z rgb[numOfNDWavesInGraph+4]=(52224,52224,0)
//		ModifyGraph/Z rgb[numOfNDWavesInGraph+5]=(16300,16300,0)
//	endif
//
//	
//	TextBox/C/N=text0/F=0/A=LT "\Z07\K(52224,0,0) Total Distribution"
//	AppendText "\K(0,52224,0) Distribution 1"
//	AppendText "\K(0,0,52224) Distribution 2"
//	AppendText "\K(52224,0,41728) Distribution 3"
//	AppendText "\K(52224,52224,0) Distribution 4"
//	AppendText "\K(16300,16300,0) Distribution 4"
//	AppendText "\K(0,0,0) Lines - volume distributions"
//	AppendText " Bars -  number distributions"
//
//	String LabelStr
//	LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Scatterer diameters [A]"
//	Label bottom LabelStr
//
//	ModifyGraph log(bottom)=1
//	ModifyGraph mirror(bottom)=1
////	Label bottom "Scatterer diameters [A]"
//	
//	LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Number distribution N(d) [cm\\S-3\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
//	if (numOfNDWavesInGraph!=0)
//		ModifyGraph lblMargin(left)=8
//		ModifyGraph lblLatPos(left)=9
////		Label left "\\Z07Number distribution N(D) 1/cm\\S3"
//		Label left LabelStr
//	endif
//	LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Volume distribution V(d) [cm\\S3\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"/cm\\S3\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
//	if (numOfVDWavesInGraph!=0)
//		ModifyGraph lblMargin(right)=12
//		ModifyGraph lblLatPos(right)=3
////		Label right "\\Z07Volume distribution V(D) [cm\\S3\\M\\Z07/cm\\S3\\M\\Z07]"	
//		Label right LabelStr
//	endif
//	if (numOfVDWavesInGraph==0)
//		ModifyGraph mirror(left)=1	
//	endif
//	if (numOfNDWavesInGraph==0)
//		ModifyGraph mirror(right)=1	
//	endif
//
//	setDataFolder OldDf
//	
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_AppendNDDistToGraph(DistNum)
//		variable DistNum
//		
//	Wave DistNumberDist=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NumberDist")
//	Wave Distdiameters=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"diameters")
//
//	AppendToGraph /W=IR1_Model_Distributions      DistNumberDist vs Distdiameters
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_AppendTOTNDDistToGraph()
//				
//	Wave DistNumberDist=$("root:Packages:SAS_Modeling:TotalNumberDist")
//	Wave Distdiameters=$("root:Packages:SAS_Modeling:Distdiameters")
//
//	AppendToGraph /W=IR1_Model_Distributions      DistNumberDist vs Distdiameters
//end
//
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_AppendTOTVDDistToGraph()
//				
//	Wave DistVolumeDist=$("root:Packages:SAS_Modeling:TotalVolumeDist")
//	Wave Distdiameters=$("root:Packages:SAS_Modeling:Distdiameters")
//
//	AppendToGraph/R/W=IR1_Model_Distributions    DistVolumeDist vs Distdiameters
//		
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_AppendVDDistToGraph(DistNum)
//		variable DistNum
//		
//	Wave DistVolumeDist=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolumeDist")
//	Wave Distdiameters=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"diameters")
//
//	AppendToGraph/R/W=IR1_Model_Distributions    DistVolumeDist vs Distdiameters
//		
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_CalculateDistributions()
//	//here we calculate the distributions from the data
//	string oldDf=GetDataFolder(1)
//	setDataFolder root:Packages:SAS_Modeling
//	
//	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
//
//	if (NumberOfDistributions>0)	//calculate dist 1
//		IR1_CalcOneDistribution(1)
//	endif
//	if (NumberOfDistributions>1)	//calculate dist 2
//		IR1_CalcOneDistribution(2)
//	endif
//	if (NumberOfDistributions>2)	//calculate dist 3
//		IR1_CalcOneDistribution(3)
//	endif
//	if (NumberOfDistributions>3)	//calculate dist 4
//		IR1_CalcOneDistribution(4)
//	endif
//	if (NumberOfDistributions>4)	//calculate dist 5
//		IR1_CalcOneDistribution(5)
//	endif
//	setDatafolder oldDF
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//
//Function IR1_CalcSumOfDistribution()
//
//	string OldDf
//	OldDf=GetDataFolder(1)
//	setDataFolder root:Packages:SAS_Modeling
//	
//	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
//
//	variable i, tempLength
//	Make/O/N=0/D Distdiameters
//	
//	For(i=1;i<=NumberOfDistributions;i+=1)
//		WAVE DistTempdiameters=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"diameters")
//		tempLength=numpnts(Distdiameters)
//		redimension /N=(tempLength+numpnts(DistTempdiameters)) Distdiameters
//		Distdiameters[tempLength,numpnts(Distdiameters)-1]=DistTempdiameters[p-tempLength]
//	endfor
//
//	Sort Distdiameters, Distdiameters
//	//check if some of the point are the same, that causes trobles later. remove the points
//	variable imax=numpnts(Distdiameters)
//	For(i=imax;i>0;i-=1)
//		if(Distdiameters(i)==Distdiameters(i-1))
//			DeletePoints i,1, Distdiameters
//		endif
//	endfor
//	Duplicate/O Distdiameters, TempVolDist, TempNumDist, TotalVolumeDist, TotalNumberDist
//	Redimension/D TempVolDist, TempNumDist, TotalVolumeDist, TotalNumberDist	
//	TotalVolumeDist=0
//	TotalNumberDist=0
//	
//	For(i=1;i<=NumberOfDistributions;i+=1)	
//		IR1_CalcOneTempDistribution(i, TempVolDist, TempNumDist, Distdiameters)
//		TotalVolumeDist+=TempVolDist
//		TotalNumberDist+=TempNumDist
//	endfor
//	KillWaves/Z TempVolDist, TempNumDist	
//	//fix the procedure
//	setDataFolder OldDf	
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_CalcOneTempDistribution(DistNum, TempVolDist, TempNumDist, Distdiameters)	
//		variable DistNum
//		wave TempVolDist, TempNumDist, Distdiameters
//	//needs to be fixed...
//	
//	string OldDf
//	OldDf=GetDataFolder(1)
//	setDataFolder root:Packages:SAS_Modeling
//	 
//		SVAR DistDistributionType=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"DistributionType")
//		NVAR DistNumberOfPoints=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NumberOfPoints")
//		NVAR DistNegligibleFraction=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NegligibleFraction")
//		NVAR DistLocation=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Location")
//		NVAR DistScale=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Scale")
//		NVAR DistShape=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Shape")
//		NVAR DistVolFraction=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolFraction")
//		NVAR UseNumberDistribution=root:Packages:SAS_Modeling:UseNumberDistribution
//		SVAR DistShapeModel=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ShapeModel")
//		NVAR DistScatShapeParam1=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam1")
//		NVAR DistScatShapeParam2=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam2")
//		NVAR DistScatShapeParam3=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam3")
//		SVAR UserVolumeFnctName=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserVolumeFnct")
//		NVAR UserPar1=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam1")
//		NVAR UserPar2=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam2")
//		NVAR UserPar3=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam3")
//		NVAR UserPar4=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam4")
//		NVAR UserPar5=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam5")
//	
//			Duplicate/O TempNumDist, AveVolumeWave
//			IR1T_CreateAveVolumeWave(AveVolumeWave,Distdiameters,DistShapeModel,DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3,0,0,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)
//		
//		if (UseNumberDistribution)	//using number distributions
//			if (cmpstr(DistDistributionType,"LogNormal")==0)
//				TempNumDist=IR1_LogNormProbability(Distdiameters,DistLocation,DistScale, DistShape)		
//			endif
//			if (cmpstr(DistDistributionType,"Gauss")==0)
//				TempNumDist=IR1_GaussProbability(Distdiameters,DistLocation,DistScale, DistShape)		
//			endif
//			if (cmpstr(DistDistributionType,"LSW")==0)
//				TempNumDist=IR1_LSWProbability(Distdiameters,DistLocation,DistScale, DistShape)		
//			endif
//			
//			if (cmpstr(DistDistributionType,"PowerLaw")==0)
//				TempNumDist=IR1_PowerLawProbability(Distdiameters, DistShape,Distdiameters)		
//			endif
//				//this is to calculate the number distribution, so the volume is right
//			//the way we do this: integrate P(r)*V(r), get Ntotal as Vol/the integral calculated... 
//			//and next multiply the number distribution by the total number of scatterers Ntotaql
//			Duplicate/O TempNumDist, temp_Calc_Wv
//
//			temp_Calc_Wv=TempNumDist*AveVolumeWave
//
//			variable Nt=DistVolFraction/areaXY(Distdiameters,temp_Calc_Wv,-inf,inf)	
//			TempNumDist*=Nt
//			KillWaves/Z temp_Calc_Wv
//		else
//			if (cmpstr(DistDistributionType,"LogNormal")==0)
//				TempVolDist=DistVolFraction*IR1_LogNormProbability(Distdiameters,DistLocation,DistScale, DistShape)		
//			endif
//			if (cmpstr(DistDistributionType,"Gauss")==0)
//				TempVolDist=DistVolFraction*IR1_GaussProbability(Distdiameters,DistLocation,DistScale, DistShape)		
//			endif
//			if (cmpstr(DistDistributionType,"LSW")==0)
//				TempVolDist=DistVolFraction*IR1_LSWProbability(Distdiameters,DistLocation,DistScale, DistShape)		
//			endif
//			if (cmpstr(DistDistributionType,"PowerLaw")==0)
//				TempVolDist=DistVolFraction*IR1_PowerLawProbability(Distdiameters,DistShape,Distdiameters)		
//			endif
//		endif
//		//Ok, now we have diameters distribution and Number or Volume distribution, now need to create the other one...
//		//Ok, now we have diameters distribution and Number or Volume distribution, now need to create the other one...
//		if (UseNumberDistribution)	//using number distributions
//			TempVolDist=TempNumDist*AveVolumeWave
//		else
//			TempNumDist=TempVolDist/AveVolumeWave
//		endif
//			
//	setDataFolder oldDf
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_CalcOneDistribution(DistNum)
//	variable DistNum
//	
//	string OldDf
//	OldDf=GetDataFolder(1)
//	
//	setDataFolder root:Packages:SAS_Modeling
//	 
//		SVAR DistDistributionType=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"DistributionType")
//		WAVE Distdiameters=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"diameters")
//		Wave DistNumberDist=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NumberDist")
//		Wave DistVolumeDist=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolumeDist")
//		NVAR DistNumberOfPoints=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NumberOfPoints")
//		NVAR DistNegligibleFraction=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NegligibleFraction")
//		NVAR DistLocation=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Location")
//		NVAR DistScale=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Scale")
//		NVAR DistShape=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Shape")
//		NVAR DistVolFraction=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolFraction")
//		NVAR UseNumberDistribution=root:Packages:SAS_Modeling:UseNumberDistribution
//		SVAR DistShapeModel=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ShapeModel")
//		NVAR DistScatShapeParam1=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam1")
//		NVAR DistScatShapeParam2=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam2")
//		NVAR DistScatShapeParam3=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam3")
//		SVAR UserVolumeFnctName=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserVolumeFnct")
//		NVAR UserPar1=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam1")
//		NVAR UserPar2=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam2")
//		NVAR UserPar3=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam3")
//		NVAR UserPar4=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam4")
//		NVAR UserPar5=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam5")
//
//		
//		if(IR1_CheckDistDistForUpdateNeed(DistNum))
//			IR1_GeneratediametersDist(DistDistributionType, "Dist"+num2str(DistNum)+"diameters", DistNumberOfPoints, DistNegligibleFraction, DistLocation,DistScale, DistShape)
//		
//				Duplicate/O DistNumberDist, AveVolumeWave
//				IR1T_CreateAveVolumeWave(AveVolumeWave,Distdiameters,DistShapeModel,DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3,0,0,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)
//		
//			
//			if (UseNumberDistribution)	//using number distributions
//				if (cmpstr(DistDistributionType,"LogNormal")==0)
//					DistNumberDist=IR1_LogNormProbability(Distdiameters,DistLocation,DistScale, DistShape)		
//				endif
//				if (cmpstr(DistDistributionType,"Gauss")==0)
//					DistNumberDist=IR1_GaussProbability(Distdiameters,DistLocation,DistScale, DistShape)		
//				endif
//				if (cmpstr(DistDistributionType,"LSW")==0)
//					DistNumberDist=IR1_LSWProbability(Distdiameters,DistLocation,DistScale, DistShape)		
//				endif
//				if (cmpstr(DistDistributionType,"PowerLaw")==0)
//					DistNumberDist=IR1_PowerLawProbability(Distdiameters, DistShape,Distdiameters)		
//				endif
//				
//				//this is to calculate the number distribution, so the volume is right
//				//the way we do this: integrate P(r)*V(r), get Ntotal as Vol/the integral calculated... 
//				//and next multiply the number distribution by the total number of scatterers Ntotaql
//				Duplicate/O DistNumberDist, temp_Calc_Wv
//		
//				temp_Calc_Wv=DistNumberDist*AveVolumeWave
//		
//				variable Nt=DistVolFraction/areaXY(Distdiameters,temp_Calc_Wv,-inf,inf)	
//				DistNumberDist*=Nt
//				KillWaves/Z temp_Calc_Wv
//			else
//				if (cmpstr(DistDistributionType,"LogNormal")==0)
//					DistVolumeDist=DistVolFraction*IR1_LogNormProbability(Distdiameters,DistLocation,DistScale, DistShape)		
//				endif
//				if (cmpstr(DistDistributionType,"Gauss")==0)
//					DistVolumeDist=DistVolFraction*IR1_GaussProbability(Distdiameters,DistLocation,DistScale, DistShape)		
//				endif
//				if (cmpstr(DistDistributionType,"LSW")==0)
//					DistVolumeDist=DistVolFraction*IR1_LSWProbability(Distdiameters,DistLocation,DistScale, DistShape)		
//				endif
//				if (cmpstr(DistDistributionType,"PowerLaw")==0)
//					DistVolumeDist=DistVolFraction*IR1_PowerLawProbability(Distdiameters, DistShape,Distdiameters)		
//				endif
//			endif
//			//Ok, now we have diameters distribution and Number or Volume distribution, now need to create the other one...
//			if (UseNumberDistribution)	//using number distributions
//				DistVolumeDist=DistNumberDist*AveVolumeWave
//			else
//				DistNumberDist=DistVolumeDist/AveVolumeWave
//			endif
//		endif
//		IR1_UpdateWaveNoteDist(DistNum)
//		
//		
//	setDataFolder oldDf
//end
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//Function IR1_UpdateWaveNoteDist(DistNum)
//		variable DistNum
//	//checks the need to update distribution waves 
//	
//		SVAR DistDistributionType=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"DistributionType")
//		SVAR DistShapeModel=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ShapeModel")
//
//		NVAR DistNumberOfPoints=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NumberOfPoints")
//		NVAR DistNegligibleFraction=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NegligibleFraction")
//		NVAR DistLocation=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Location")
//		NVAR DistScale=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Scale")
//		NVAR DistShape=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Shape")
//		NVAR DistVolFraction=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolFraction")
//		NVAR UseNumberDistribution=root:Packages:SAS_Modeling:UseNumberDistribution
//		NVAR DistScatShapeParam1=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam1")
//		NVAR DistScatShapeParam2=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam2")
//		NVAR DistScatShapeParam3=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam3")
//
//		WAVE Distdiameters=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"diameters")
//		Wave DistNumberDist=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NumberDist")
//		Wave DistVolumeDist=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolumeDist")
//		
//		string NewNote=""
//		NewNote=ReplaceStringByKey("DistDistributionType", NewNote, DistDistributionType)
//		NewNote=ReplaceStringByKey("DistShapeModel", NewNote, DistShapeModel)
//
//		NewNote=ReplaceStringByKey("DistNumberOfPoints", NewNote, num2str(DistNumberOfPoints))
//		NewNote=ReplaceStringByKey("DistNegligibleFraction", NewNote, num2str(DistNegligibleFraction))
//		NewNote=ReplaceStringByKey("DistLocation", NewNote, num2str(DistLocation))
//		NewNote=ReplaceStringByKey("DistScale", NewNote, num2str(DistScale))
//		NewNote=ReplaceStringByKey("DistShape", NewNote, num2str(DistShape))
//		NewNote=ReplaceStringByKey("DistVolFraction", NewNote, num2str(DistVolFraction))
//		NewNote=ReplaceStringByKey("UseNumberDistribution", NewNote, num2str(UseNumberDistribution))
//		NewNote=ReplaceStringByKey("DistScatShapeParam1", NewNote, num2str(DistScatShapeParam1))
//		NewNote=ReplaceStringByKey("DistScatShapeParam2", NewNote, num2str(DistScatShapeParam2))
//		NewNote=ReplaceStringByKey("DistScatShapeParam3", NewNote, num2str(DistScatShapeParam3))
//		
//		note /K Distdiameters
//		note Distdiameters, NewNote
//		note /K DistNumberDist
//		note DistNumberDist, NewNote
//		note /K DistVolumeDist
//		note DistVolumeDist, NewNote
//		
//end
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_CheckDistDistForUpdateNeed(DistNum)
//		variable DistNum
//	//checks the need to update distribution waves 
//	
//		SVAR DistDistributionType=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"DistributionType")
//		SVAR DistShapeModel=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ShapeModel")
//
//		NVAR DistNumberOfPoints=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NumberOfPoints")
//		NVAR DistNegligibleFraction=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NegligibleFraction")
//		NVAR DistLocation=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Location")
//		NVAR DistScale=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Scale")
//		NVAR DistShape=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"Shape")
//		NVAR DistVolFraction=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolFraction")
//		NVAR UseNumberDistribution=root:Packages:SAS_Modeling:UseNumberDistribution
//		NVAR DistScatShapeParam1=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam1")
//		NVAR DistScatShapeParam2=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam2")
//		NVAR DistScatShapeParam3=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam3")
//
//		WAVE Distdiameters=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"diameters")
//		Wave DistNumberDist=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NumberDist")
//		Wave DistVolumeDist=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolumeDist")
//		
//		variable Update=0
//		
//		if(cmpstr(DistDistributionType,stringByKey("DistDistributionType",note(Distdiameters)))!=0)
//			Update=1
//		endif
//		if(cmpstr(DistShapeModel,stringByKey("DistShapeModel",note(Distdiameters)))!=0)
//			Update=1
//		endif
//		
//		if(cmpstr(num2str(DistNumberOfPoints),stringByKey("DistNumberOfPoints",note(Distdiameters)))!=0)
//			Update=1
//		endif
//		if(cmpstr(num2str(DistNegligibleFraction),stringByKey("DistNegligibleFraction",note(Distdiameters)))!=0)
//			Update=1
//		endif
//		if(cmpstr(num2str(DistLocation),stringByKey("DistLocation",note(Distdiameters)))!=0)
//			Update=1
//		endif
//		if(cmpstr(num2str(DistScale),stringByKey("DistScale",note(Distdiameters)))!=0)
//			Update=1
//		endif
//		if(cmpstr(num2str(DistShape),stringByKey("DistShape",note(Distdiameters)))!=0)
//			Update=1
//		endif
//		if(cmpstr(num2str(UseNumberDistribution),stringByKey("UseNumberDistribution",note(Distdiameters)))!=0)
//			Update=1
//		endif
//		if(cmpstr(num2str(DistScatShapeParam1),stringByKey("DistScatShapeParam1",note(Distdiameters)))!=0)
//			Update=1
//		endif
//		if(cmpstr(num2str(DistScatShapeParam2),stringByKey("DistScatShapeParam2",note(Distdiameters)))!=0)
//			Update=1
//		endif
//		if(cmpstr(num2str(DistScatShapeParam3),stringByKey("DistScatShapeParam3",note(Distdiameters)))!=0)
//			Update=1
//		endif
//		if(cmpstr(num2str(DistVolFraction),stringByKey("DistVolFraction",note(Distdiameters)))!=0)
//			Update=1
//		endif
//		
//	return Update
//end
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_CreateDistributionWaves()
//	//here we create waves for distributions
//
//	string OldDf=GetDataFolder(1)
//	SetDataFolder root:Packages:SAS_Modeling
//	
//	variable i
//	variable update =0
//	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
//	//Ok,  lets first kill all waves which may not be needed...
//	For(i=1;i<=NumberOfDistributions;i+=1)
//		Wave/Z Distdiameters=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"diameters")
//		Wave/Z DistNumberDist=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"NumberDist")
//		Wave/Z DistVolumeDist=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"VolumeDist")
//		NVAR DistNumberOfPoints=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"NumberOfPoints")
//		if (!WaveExists(Distdiameters) || !WaveExists(DistNumberDist) || !WaveExists(DistVolumeDist) )
//			update=1
//		elseif(DistNumberOfPoints!=numpnts(Distdiameters))
//			update=1
//		else
//			update=0
//		endif
//		if (update)
//			Make/D/O/N=(DistNumberOfPoints) $("Dist"+num2str(i)+"diameters"), $("Dist"+num2str(i)+"NumberDist"), $("Dist"+num2str(i)+"VolumeDist")
//		endif
//	endfor
//
//	setDataFolder OldDf
//		
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Proc  IR1_Model_Distributions() 
//	PauseUpdate; Silent 1		// building window...
//	String fldrSav= GetDataFolder(1)
//	SetDataFolder root:Packages:SAS_Modeling:
//	if (root:Packages:SAS_Modeling:NumberOfDistributions==0)
//		abort 
//		//"No data selected"
//	endif
//	Display/K=1 /W=(281.25,392,759.75,548) Dist1NumberDist vs Dist1diameters as "IR1_Model_Distributions"
//	DoWIndow/C IR1_Model_Distributions
//	AppendToGraph/R Dist1VolumeDist vs Dist1diameters
//	SetDataFolder fldrSav
//	ModifyGraph mode(Dist1NumberDist)=1
//	ModifyGraph rgb(Dist1VolumeDist)=(0,0,0)
//	String LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Number distribution N(d) [cm\\S-3\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
//	Label left LabelStr
//	LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Scatterer diameters [A]"
//	Label bottom LabelStr
////	Label left "Number distribution N(d) 1/cm\\S3"
////	Label bottom "Scatterer diameters [A]"
//	LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Volume distribution V(d) [cm\\S3\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"/cm\\S3\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
//	Label right LabelStr
////	Label right "Volume distribution V(d) [cm\\S3\\M/cm\\S3\\M]"
//EndMacro
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
