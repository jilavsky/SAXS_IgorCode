#pragma rtGlobals=3			// Use modern global access method.
#pragma IgorVersion=8.03  	//requires Igor version 8.03 or higher
#pragma version=1.98


//*************************************************************************\
//* Copyright (c) 2005 - 2020, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.98 September2020 release. 
//1.97 February 2020 release. 
//1.96 December 2018 release. 
//1.95 July 2018 release
//1.93 November 2017 updates
//1.92 May 2017 updates
//1.89, added Import & COnvert tool, foldes cleanup and some modifications and fixes to panel scaling. 
//1.88 added Import & process Flyscan GUI
//1.87 Igor 7 beta updates, 
//1.86 Igor 7 beta updates, dQ wave added, Flyscan improvements
//1.85 Flyscan improvements for 9ID March 2015
//1.84 Flyscan support up to August 2014
//1.82 first user release of FlyScan support
//1.80 added FlyScan data reduction
//1.79 minor changes to use USAXS PD transmission measurements
// 1.78 added wieght calibration
// 1.77 update, small changes, use of I0gain and I00gain
// 1.76 update, small chanegs. 5/30/2012
// 1.75 update, added autoraning I0 option. 4/30/2012
// 1.74 update, Added new Crystal calculator, 15/1/2012

//	Jan Ilavsky, ilavsky@aps.anl.gov, phone 630 252 0866
//	These macros allow evaluation of data obatined on Bonse-Hartman camera at 9ID beamline at APS
//	The data are collected through spec program.
//	Report any bugs promptly to me, I'll try to fix them ASAP
//	The macros hould run fine on PC platform and with less ideal graphic on Mac platform too.
//	The display setting of the computer should be 1024 or higher, otherwise the buttons may be unreadable, especially on Macs.
//	Good luck....


//this is in Indra2 folder
#include "IN2_ConversionProcedure", version>=1.10
#include "IN2_DesktopUSAXS", version>=0.3
#include "IN2_GeneralProcedures", version>=2.25
#include "IN2_NotebookLogging", version>=1.10
#include "IN2_PlottingTools", version>=1.14
#include "IN2_SpecInput", version>=1.21
#include "IN2_StandardPlots", version>=1.13
#include "IN2_USAXS", version>=1.98
#include "IN2_XtalCalculations", version>=1.1
#include "IN3_CalcScattering", version>=1.01
#include "IN3_Calculations", version>=1.42
#include "IN3_FlyScan", version>=1.06
#include "IN3_Main", version>=1.98
#include "IN3_Rwave", version>=1
#include "IN3_SupportFnct", version>=1.13
#include "IN3_SamplePlate", version>=1.0
#include "spec", version>=2.21
//#include ":IN2_XtalCalculations", version>=1
#include "IonChamber3.1", version>=3.1

#include "IR2_PanelCntrlProcs", version>=1.61
#include "IRNI_NexusSupport", version>=1.14

#if(IgorVersion()<9)  	//no need to include, Igor 9 has this by default.  
#include <HDF5 Browser>
#endif


