#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion=6.3	//requires Igor version 6.3 or higher
#pragma version=1.59

//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//This macro loads the Nika 1 set of Igor Pro macros for evaluation of 2D images in small angle scattering



#include ":NI1_15IDDsupport",version>=1.14
#include ":NI1_BeamCenterUtils",version>=2.18
#include ":NI1_ConvProc", version>=2.35
#include ":NI1_DNDCATsupport",version>=1.11
#include ":NI1_FileLoaders",version>=2.36
#include ":NI1_HDF5Browser",version>=1.01
#include ":NI1_InstrumentSupport",version>=1.00
#include ":NI1_LineProfCalcs",version>=2.10
#include ":NI1_LineProfile", version>=2.02
#include ":NI1_main", version>=1.67
#include ":NI1_MainPanel", version>=2.38
#include ":NI1_mar345", version>=1.03
#include ":NI1_mask", version>=1.21
#include ":NI1_pix2Dsensitivity",version>=1.03
#include ":NI1_SaveRecallConfig", version>=1.02
#include ":NI1_SquareMatrix", version>=1.04
#include ":NI1_WinView",version>=1.87

#include "::Indra 2:IN2_GeneralProcedures", version>=1.75
