#pragma rtGlobals=3		// Use modern global access method.
//#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion=8.03	//requires Igor version 8.03 or higher
#pragma version=1.81


//*************************************************************************\
//* Copyright (c) 2005 - 2022, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//This macro loads the Nika 1 set of Igor Pro macros for evaluation of 2D images in small angle scattering
//1.79 December 2018 release. 
//1.80 	February 2020 release
//1.81		October2021 release

#include "NI1_InstrumentSupport",version>=1.22
//#include "NI1_HDF5Browser",version>=1.01
#include "NI1_FileLoaders",version>=2.57
#include "NI1_ConvProc", version>=2.73
#include "NI1_BeamCenterUtils",version>=2.3
#include "NI1_DNDCATsupport",version>=1.12
#include "NI1_LineProfile", version>=2.08
#include "NI1_FITSLoader",version>=2.18
#include "NI1_MainPanel", version>=2.71
#include "NI1_WinView",version>=1.87
#include "NI1_USAXSSupport",version>=1.53
#include "NI1_SquareMatrix", version>=1.05
#include "NI1_SaveRecallConfig", version>=1.03
#include "NI1_pix2Dsensitivity",version>=1.07
#include "NI1_mask", version>=1.30
#include "NI1_Main", version>=1.84


#include "IN2_GeneralProcedures", version>=2.28

#include "IRNI_NexusSupport", version>=1.17

//#include ":NI1_LineProfCalcs",version>=2.12
//#include ":NI1_mar345", version>=1.03
