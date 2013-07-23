#pragma rtGlobals=2		// Use modern global access method.
#pragma version=2.10

//*************************************************************************\
//* Copyright (c) 2005 - 2013, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

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

//Jan Ilavsky, April 2004, version 2.00

//please, read Readme in the distribution zip file with more details on the program
//report any problems to: ilavsky@aps.anl.gov


//this function loads the modeling of Distribution modeling macros...

//these should be all in /User Procedures/Irena folder
#include ":IR1_CreateFldrStrctr", version>=2.05
#include ":IR1_CromerLiberman", version>=2.03					//cannot be rtG=1, runtime error in Cromer_Get_fp
#include ":IR1_DataManipulation", version>=2.43
#include ":IR1_Desmearing", version>=2.06
#include ":IR1_EvaluationGraph", version>=2.03
#include ":IR1_FittingProc", version>=2.02
#include ":IR1_FormFactors", version>=2.23
#include ":IR1_FractalsCtrlPanel", version>=2.02
#include ":IR1_FractalsFiting", version>=2.01
#include ":IR1_FractalsInit", version>=2.01
#include ":IR1_FractalsMain", version>=2.02
#include ":IR1_Functions", version>=2.04
#include ":IR1_GeneralGraph", version >=2.16
#include ":IR1_GeneralGraph2", version >=2.12
#include ":IR1_GraphStyling", version>=2.01
#include ":IR1_ImportData", version>=2.18
#include ":IR1_IntCalculations", version>=2.01
#include ":IR1_InterferenceLQSF", version>=2.01
#include ":IR1_LSQF_UserFit", version>=2.01
#include ":IR1_LSQF_UserFncts", version>=2.01
#include ":IR1_LSQF_UserModelMain", version>=2.01
#include ":IR1_LSQF_UserPanel", version>=2.02
#include ":IR1_Main", version>=2.52
#include ":IR1_Panel", version>=2.03
//#include ":IR1_PlotStylesMngr", version>=2.01
#include ":IR1_Recording", version>=2.01
#include ":IR1_ScattContr_New", version>=2.16
#include ":IR1_Sizes", version>=2.10
#include ":IR1_SupportFncts", version>=2.03
#include ":IR1_Unified_Fit_Fncts", version>=2.09
#include ":IR1_Unified_Fit_Fncts2", version>=2.04
#include ":IR1_Unified_Panel", version>=2.12
#include ":IR1_Unified_Panel_Fncts", version>=2.12
#include ":IR1_Unified_SaveExport", version>=2.01
#include ":IR1_UnifiedSaveToXLS", version>=2.01
#include ":IR2_dataMiner", version >=1.08
#include ":IR2_GelsTool", version>=4.07
#include ":IR2_PanelCntrlProcs", version>=1.26
#include ":IR2_Reflectivity", version >=1.14
#include ":IR2_ScriptingTool", version>=1.15
#include ":IR2_SmallAngleDiff", version>=1.09
#include ":IR2_StructureFactors", version>=1.05
#include ":IR2_UniversalDataExport", version>=1.05
#include ":IR2L_NLSQFCalc", version>=1.06
#include ":IR2L_NLSQFfunctions", version>=1.11
#include ":IR2L_NLSQFmain", version>=1.10
#include ":IR2L_NLSQFsupport", version>=1.18
#include ":IR2Pr_PDFMain", version>=1.05
#include ":IR2Pr_Regularization", version>=1.02
#include ":IR2_DWSGraphControls", version>=1
#include ":IR2_DWSgraph", version>=1
#include ":IR3_GuinierPorodModel", version>=1.00

//these are in different folders...
#include "::CanSAS:canSASXML_GUI", version>=1.03
#include "::CanSAS:canSASXML", version>=1.12

#include "::Indra 2:IN2_GeneralProcedures", version>=1.67

