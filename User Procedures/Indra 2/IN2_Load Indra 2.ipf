#pragma TextEncoding     = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma rtGlobals        = 3    // Use modern global access method.
#pragma IgorVersion      = 9.05 //requires Igor version 9 or higher
#pragma version          = 2.05

//*************************************************************************\
//* Copyright (c) 2005 - 2026, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution.
//*************************************************************************/

//2.05 force Irena and Nika to be included, add new data reduction at the top 
//2.04 July 2025, cleanup code.
//2.03  Add IN4 Python/Igor new tools.
//2.02 	June 2025 release,  Fixes for new 12IDE USAXS instrument operations, tested with IP10Beta
//2.01		Beta release, Changes for 12IDE USAXS/SAXS/WAXS. WIP//2.00		July2023 release
//2.00	 Added IN3_BlueSkyReader
//1.99	 October2021 release
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

// this is now required (89-25-2025
#include "NI1_Loader"
#include "IR1_Loader"

//this is in Indra2 folder
#include "IN2_ConversionProcedure", version >= 1.10
#include "IN2_GeneralProcedures", version >= 2.31
#include "IN2_USAXS", version >= 2.00
#include "IN2_XtalCalculations", version >= 1.1
#include "IN3_CalcScattering", version >= 1.01
#include "IN3_Calculations", version >= 1.42
#include "IN3_FlyScan", version >= 1.10
#include "IN3_Main", version >= 2.02
#include "IN3_Rwave", version >= 1
#include "IN3_SupportFnct", version >= 1.14
#include "IN3_SamplePlate", version >= 1.09
#include "IN3_BlueSkyReader", version >= 1.06

#include "spec", version >= 2.21
#include "IonChamber3.3", version >= 3.3

//#include "IN2_SpecInput", version >= 1.21
//#include "IN2_DesktopUSAXS", version >= 0.3
//#include "IN2_PlottingTools", version >= 1.15
//#include "IN2_NotebookLogging", version >= 1.10
//

#include "IN4_MainCode"
#include "IN4_SupportCode"
#include "IN4_Calculations"

#include "IR2_PanelCntrlProcs", version >= 1.66
#include "IRNI_NexusSupport", version >= 1.17

