#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion=7		//requires Igor version 6.3 or higher
#pragma version=1.74
//Panel size controls package, need version for Igor 6.38 and higher
//#if(Igorversion()>=6.38)
//#include <Resize Controls> version>=6.38
//#include <Resize Controls Panel> version>=6.38
//#include <Rewrite Control Positions>
//#endif

//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//This macro loads the Nika 1 set of Igor Pro macros for evaluation of 2D images in small angle scattering



#include ":NI1_15IDDsupport",version>=1.35
#include ":NI1_BeamCenterUtils",version>=2.24
#include ":NI1_ConvProc", version>=2.55
#include ":NI1_DNDCATsupport",version>=1.11
#include ":NI1_FileLoaders",version>=2.45
#include ":NI1_HDF5Browser",version>=1.01
#include ":NI1_FITSLoader",version>=2.17
#include ":NI1_InstrumentSupport",version>=1.00
#include ":NI1_LineProfCalcs",version>=2.11
#include ":NI1_LineProfile", version>=2.03
#include ":NI1_Main", version>=1.74
#include ":NI1_MainPanel", version>=2.51
#include ":NI1_mar345", version>=1.03
#include ":NI1_mask", version>=1.25
#include ":NI1_pix2Dsensitivity",version>=1.04
#include ":NI1_SaveRecallConfig", version>=1.03
#include ":NI1_SquareMatrix", version>=1.04
#include ":NI1_WinView",version>=1.87

#include "::Indra 2:IN2_GeneralProcedures", version>=1.92

#include "::CanSAS:IRNI_NexusSupport", version>=1.04

