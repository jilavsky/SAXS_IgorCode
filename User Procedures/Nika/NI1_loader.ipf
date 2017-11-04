#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion=7	.05	//requires Igor version 7.05 or higher
#pragma version=1.78


//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//This macro loads the Nika 1 set of Igor Pro macros for evaluation of 2D images in small angle scattering



#include ":NI1_15IDDsupport",version>=1.42
#include ":NI1_BeamCenterUtils",version>=2.27
#include ":NI1_ConvProc", version>=2.61
#include ":NI1_DNDCATsupport",version>=1.11
#include ":NI1_FileLoaders",version>=2.46
#include ":NI1_HDF5Browser",version>=1.01
#include ":NI1_FITSLoader",version>=2.17
#include ":NI1_InstrumentSupport",version>=1.00
#include ":NI1_LineProfCalcs",version>=2.12
#include ":NI1_LineProfile", version>=2.04
#include ":NI1_Main", version>=1.78
#include ":NI1_MainPanel", version>=2.58
#include ":NI1_mar345", version>=1.03
#include ":NI1_mask", version>=1.28
#include ":NI1_pix2Dsensitivity",version>=1.06
#include ":NI1_SaveRecallConfig", version>=1.03
#include ":NI1_SquareMatrix", version>=1.04
#include ":NI1_WinView",version>=1.87

#include "::Indra 2:IN2_GeneralProcedures", version>=2.06

#include "::CanSAS:IRNI_NexusSupport", version>=1.05

