#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.03

//thsi should be all commented out and later removed. 3/31/2017


//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.03 DWS changes
//2.02 Dale added some Porod note taking for Unified fit model. 
//2.01 added license for ANL


//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from www.uni.aps.anl.gov/~ilavsky
//this package contains 
// Igor functions for modeling of SAS from various distributions of scatterers...

//Jan Ilavsky, January 2002

//please, read Readme in the distribution zip file with more details on the program
//report any problems to: ilavsky@aps.anl.gov


//this file contains functions related to the recording in the notebook... The recordnig is done 
//only before and after fitting - at this time.


////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//
//Function IR1S_RecordResults(CalledFromWere)
//	string CalledFromWere	//before or after - that means fit...
//
//	string OldDF=GetDataFolder(1)
//	setdataFolder root:Packages:SAS_Modeling
//
//	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
//
//	NVAR SASBackground=root:Packages:SAS_Modeling:SASBackground
//	NVAR FitSASBackground=root:Packages:SAS_Modeling:FitSASBackground
//
//	SVAR DataAreFrom=root:Packages:SAS_Modeling:DataFolderName
//	SVAR Dist1ShapeModel=root:Packages:SAS_Modeling:Dist1ShapeModel
//	SVAR Dist1DistributionType=root:Packages:SAS_Modeling:Dist1DistributionType
//	SVAR Dist2ShapeModel=root:Packages:SAS_Modeling:Dist2ShapeModel
//	SVAR Dist2DistributionType=root:Packages:SAS_Modeling:Dist2DistributionType
//	SVAR Dist3ShapeModel=root:Packages:SAS_Modeling:Dist3ShapeModel
//	SVAR Dist3DistributionType=root:Packages:SAS_Modeling:Dist3DistributionType
//	SVAR Dist4ShapeModel=root:Packages:SAS_Modeling:Dist4ShapeModel
//	SVAR Dist4DistributionType=root:Packages:SAS_Modeling:Dist4DistributionType
//	SVAR Dist5ShapeModel=root:Packages:SAS_Modeling:Dist5ShapeModel
//	SVAR Dist5DistributionType=root:Packages:SAS_Modeling:Dist5DistributionType
//	
//	NVAR Dist1Contrast=root:Packages:SAS_Modeling:Dist1Contrast
//	NVAR Dist2Contrast=root:Packages:SAS_Modeling:Dist2Contrast
//	NVAR Dist3Contrast=root:Packages:SAS_Modeling:Dist3Contrast
//	NVAR Dist4Contrast=root:Packages:SAS_Modeling:Dist4Contrast
//	NVAR Dist5Contrast=root:Packages:SAS_Modeling:Dist5Contrast
//	
//	NVAR Dist1Mean=root:Packages:SAS_Modeling:Dist1Mean
//	NVAR Dist1Median=root:Packages:SAS_Modeling:Dist1Median
//	NVAR Dist1Mode=root:Packages:SAS_Modeling:Dist1Mode
//	NVAR Dist2Mean=root:Packages:SAS_Modeling:Dist2Mean
//	NVAR Dist2Median=root:Packages:SAS_Modeling:Dist2Median
//	NVAR Dist2Mode=root:Packages:SAS_Modeling:Dist2Mode
//	NVAR Dist3Mean=root:Packages:SAS_Modeling:Dist3Mean
//	NVAR Dist3Median=root:Packages:SAS_Modeling:Dist3Median
//	NVAR Dist3Mode=root:Packages:SAS_Modeling:Dist3Mode
//	NVAR Dist4Mean=root:Packages:SAS_Modeling:Dist4Mean
//	NVAR Dist4Median=root:Packages:SAS_Modeling:Dist4Median
//	NVAR Dist4Mode=root:Packages:SAS_Modeling:Dist4Mode
//	NVAR Dist5Mean=root:Packages:SAS_Modeling:Dist5Mean
//	NVAR Dist5Median=root:Packages:SAS_Modeling:Dist5Median
//	NVAR Dist5Mode=root:Packages:SAS_Modeling:Dist5Mode
//	NVAR Dist1FWHM=root:Packages:SAS_Modeling:Dist1FWHM
//	NVAR Dist2FWHM=root:Packages:SAS_Modeling:Dist2FWHM
//	NVAR Dist3FWHM=root:Packages:SAS_Modeling:Dist3FWHM
//	NVAR Dist4FWHM=root:Packages:SAS_Modeling:Dist4FWHM
//	NVAR Dist5FWHM=root:Packages:SAS_Modeling:Dist5FWHM
//	
//	IR1_CreateLoggbook()		//this creates the logbook
//	SVAR nbl=root:Packages:SAS_Modeling:NotebookName
//
//	IR1L_AppendAnyText("     ")
//	if (cmpstr(CalledFromWere,"before")==0)
//		IR1L_AppendAnyText("***********************************************")
//		IR1L_AppendAnyText("***********************************************")
//		IR1L_AppendAnyText("***********************************************")
//		IR1L_AppendAnyText("Parameters before starting Fitting on the data from: "+DataAreFrom)
//		IR1_InsertDateAndTime(nbl)
//		IR1L_AppendAnyText(" ")
//		IR1L_AppendAnyText("Started on       \t"+ Date()+"    "+time())
//		IR1L_AppendAnyText("Number of modelled distributions: "+num2str(NumberOfDistributions))
//	else			//after
//		IR1L_AppendAnyText("***********************************************")
//		IR1L_AppendAnyText("Results of the Fitting on the data from: "+DataAreFrom)	
//		IR1_InsertDateAndTime(nbl)
//		IR1L_AppendAnyText(" ")
//		IR1L_AppendAnyText("Finished on       \t"+ Date()+"    "+time())
//		IR1L_AppendAnyText("Number of fitted distributions: "+num2str(NumberOfDistributions))
//		IR1L_AppendAnyText("Fitting results: ")
//	endif
//	IR1L_AppendAnyText("SAS background = "+num2str(SASBackground)+", was fitted? = "+num2str(FitSASBackground)+"       (yes=1/no=0)")
//	variable i
//	For (i=1;i<=NumberOfDistributions;i+=1)
//		IR1L_AppendAnyText("***********  Distribution "+num2str(i))
//		SVAR tempShape=$("Dist"+num2str(i)+"ShapeModel")
//			IR1L_AppendAnyText("Particle shape:     \t"+tempShape)
//		SVAR tempDistType=$("Dist"+num2str(i)+"DistributionType")
//			IR1L_AppendAnyText("Distribution type:  \t"+tempDistType)
//		NVAR tempVal =$("Dist"+num2str(i)+"Contrast")
//			IR1L_AppendAnyText("Contrast       \t"+ num2str(tempVal))
//			
//		NVAR tempVal =$("Dist"+num2str(i)+"VolFraction")
//		NVAR tempValError =$("Dist"+num2str(i)+"VolFractionError")
//		NVAR fitTempVal=$("Dist"+num2str(i)+"FitVol")
//			IR1L_AppendAnyText("Volume      \t"+ num2str(tempVal)+"       ,  \tfitted? = "+num2str(fitTempVal)+"   , error = "+num2str(tempValError))
//		NVAR tempVal =$("Dist"+num2str(i)+"Location")
//		NVAR tempValError =$("Dist"+num2str(i)+"LocationError")
//		NVAR fitTempVal=$("Dist"+num2str(i)+"FitLocation")
//			IR1L_AppendAnyText("Location       \t"+ num2str(tempVal)+"       ,  \tfitted? = "+num2str(fitTempVal)+"   , error = "+num2str(tempValError))
//
//		if (cmpstr(tempDistType,"LogNormal")==0 || cmpstr(tempDistType,"Gauss")==0)		
//			NVAR tempVal =$("Dist"+num2str(i)+"Scale")
//			NVAR tempValError =$("Dist"+num2str(i)+"ScaleError")
//			NVAR fitTempVal=$("Dist"+num2str(i)+"FitScale")
//				IR1L_AppendAnyText("Scale      \t"+ num2str(tempVal)+"       ,  \tfitted? = "+num2str(fitTempVal)+"   , error = "+num2str(tempValError))
//		endif
//		if (cmpstr(tempDistType,"LogNormal")==0)		
//			NVAR tempVal =$("Dist"+num2str(i)+"Shape")
//			NVAR tempValError =$("Dist"+num2str(i)+"ShapeError")
//			NVAR fitTempVal=$("Dist"+num2str(i)+"FitShape")
//				IR1L_AppendAnyText("Shape       \t"+ num2str(tempVal)+"       ,  \tfitted? = "+num2str(fitTempVal)+"   , error = "+num2str(tempValError))
//		endif
//		
//		NVAR UseInterference=$("Dist"+num2str(i)+"UseInterference")
//		if(UseInterference)
//			NVAR InterferencePhi=$("Dist"+num2str(i)+"InterferencePhi")
//			NVAR InterferenceEta=$("Dist"+num2str(i)+"InterferenceEta")
//			NVAR InterferencePhiError=$("Dist"+num2str(i)+"InterferencePhiError")
//			NVAR InterferenceEtaError=$("Dist"+num2str(i)+"InterferenceEtaError")
//			NVAR FitInterferencePhi=$("Dist"+num2str(i)+"FitInterferencePhi")
//			NVAR FitInterferenceETA=$("Dist"+num2str(i)+"FitInterferenceETA")
//				IR1L_AppendAnyText("Used Interferences")
//				IR1L_AppendAnyText("ETA       \t"+ num2str(InterferenceEta)+"       ,  \tfitted? = "+num2str(FitInterferenceETA)+"   , error = "+num2str(InterferenceEtaError))
//				IR1L_AppendAnyText("Phi/PACK \t"+ num2str(InterferencePhi)+"       ,  \tfitted? = "+num2str(FitInterferencePhi)+"   , error = "+num2str(InterferencePhiError))
//		endif
//		
//		NVAR tempVal =$("Dist"+num2str(i)+"Mean")
//			IR1L_AppendAnyText("Mean       \t"+ num2str(tempVal))
//		NVAR tempVal =$("Dist"+num2str(i)+"Median")
//			IR1L_AppendAnyText("Median       \t"+ num2str(tempVal))
//		NVAR tempVal =$("Dist"+num2str(i)+"Mode")
//			IR1L_AppendAnyText("Mode       \t"+ num2str(tempVal))
//		NVAR tempVal =$("Dist"+num2str(i)+"FWHM")
//			IR1L_AppendAnyText("FWHM       \t"+ num2str(tempVal))
//
//			IR1L_AppendAnyText("  ")
//	endfor
//	
//	if (cmpstr(CalledFromWere,"after")==0)
//		IR1L_AppendAnyText("Fit has been reached with following parameters")
//		IR1_InsertDateAndTime(nbl)
//		NVAR AchievedChisq
//		IR1L_AppendAnyText("Chi-Squared \t"+ num2str(AchievedChisq))
//
//		DoWindow /F IR1_LogLogPlotLSQF
//		if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
//			IR1L_AppendAnyText("Points selected for fitting \t"+ num2str(pcsr(A)) + "   to \t"+num2str(pcsr(B)))
//		else
//			IR1L_AppendAnyText("Whole range of data selected for fitting")
//		endif
//		IR1L_AppendAnyText(" ")
//	endif			//after
//
//	setdataFolder oldDf
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//

//	
//	
//

