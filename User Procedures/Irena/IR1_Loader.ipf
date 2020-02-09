#pragma rtGlobals = 3	// Use strict wave reference mode and runtime bounds checking
//#pragma rtGlobals=2		// Use modern global access method.
#pragma IgorVersion=7.05 	//requires Igor version 7.00 or higher
#pragma version=2.23

//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.23 February 2020 release
//2.22 added 3DSupportFunctions, February 2019
//2.21 Added 3DModels, December/January 2018
//2.20 removed files December/January 2018
//2.19 December 2018 release. 
//2.18 July 2018 release
//2.17 November 2017 release
//2.16 March 31, 2017 removed code related to Modeling I finally. 
//2.15 release 2.61 with new Import non-SAS ASCII tool and better panel scaling & preferences management. 
//2.14 added panel scaling.
//2.13 added WAXS tool
//2.12 added Simple fits, developement version
//2.11 added Data Merging, removed LSQF1 versions
//2.10 changed back to rtGlobals=2, need to check code much more to make it 3
//2.09 converted to rtGlobals=3
//2.08 added GuinierPorod fit package
//2.07 change how to look for files (now looking relative to this file location). This should enable in the future multiple Irean versions to be installed.
//2.06 updates after August8, 2011
//2.05 added Unified level as Form factor
//2.04 removed Genetic optimization
//2.03 September 2010, added license for ANL
//2.01 February 2010
//2.02 May 2010

//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from www.uni.aps.anl.gov/~ilavsky
//this package contains 
// Igor functions for modeling of SAS from various distributions of scatterers...

//Jan Ilavsky, November 12017
//please, read Readme in the distribution zip file with more details on the program
//report any problems to: ilavsky@aps.anl.gov


//this function loads the modeling of Distribution modeling macros...

//these should be all in /User Procedures/Irena folder
#include ":IR1_CromerLiberman", version>=2.05						//cannot be rtG=1, runtime error in Cromer_Get_fp
#include ":IR1_DataManipulation", version>=2.68
#include ":IR1_Desmearing", version>=2.13
#include ":IR1_EvaluationGraph", version>=2.11
#include ":IR1_FormFactors", version>=2.29
#include ":IR1_Fractals", version>=2.10
#include ":IR1_ImportData", version>=2.40
#include ":IR1_Main", version>=2.69
#include ":IR1_PlotingToolI", version >=2.34
#include ":IR1_PlotingToolI2", version >=2.24
#include ":IR1_ScattContrast", version>=2.27
#include ":IR1_Sizes", version>=2.31
#include ":IR1_UnifiedFitFncts", version>=2.33
#include ":IR1_UnifiedFitPanel", version>=2.26
#include ":IR2_AnalyticalModels", version>=4.16
#include ":IR2_DataExport", version>=1.13
#include ":IR2_DataMiner", version >=1.13
#include ":IR2_ModelingMain", version>=1.31
#include ":IR2_ModelingSupport", version>=1.51
#include ":IR2_PanelCntrlProcs", version>=1.53
#include ":IR2_PlotingToolII", version>=1.1
#include ":IR2_Reflectivity", version >=1.21
#include ":IR2_ScriptingTool", version>=1.30
#include ":IR2_SmallAngleDiffraction", version>=1.19
#include ":IR2_StructureFactors", version>=1.07
#include ":IR2_PDDF", version>=1.15
#include ":IR3_3DModels", version>=1.01
#include ":IR3_3DSupportFunctions", version>=1.00
#include ":IR3_3DTwoPhaseSolid", version>=1.02
#include ":IR3_Anisotropy", version>=1.00
#include ":IR3_GuinierPorodModel", version>=1.11
#include ":IR3_MergingData", version>=1.19
#include ":IR3_SimpleFits", version>=1.10
#include ":IR3_WAXSDiffraction", version>=1.14

//these are in different folders... 
#include "::CanSAS:cansasXML_GUI", version>=1.04
#include "::CanSAS:cansasXML", version>=1.12

#include "::Indra 2:IN2_GeneralProcedures", version>=2.20

#include "::CanSAS:IRNI_NexusSupport", version>=1.14


//removed December 2018, need to delete them from distributions 
//#include ":IR1_Unified_Panel_Fncts", version>=2.25
//#include ":IR1_Unified_SaveExport", version>=2.03
//#include ":IR1_UnifiedSavetoXLS", version>=2.01
//#include ":IR1_Unified_Fit_Fncts2", version>=2.08
//#include ":IR1_FractalsFiting", version>=2.03
//#include ":IR1_FractalsInit", version>=2.02
//#include ":IR1_FractalsCtrlPanel", version>=2.08
//#include ":IR2L_NLSQFfunctions", version>=1.29
//#include ":IR2L_NLSQFCalc", version>=1.15
//#include ":IR2_DWSGraphControls", version>=1
//#include ":IR3_SimpleFitsModels", version>=1
//#include ":IR1_CreateFldrStrctr", version>=2.06
//#include ":IR1_GraphStyling", version>=2.01
//#include ":IR2Pr_Regularization", version>=1.03
