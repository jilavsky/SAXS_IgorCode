#pragma rtGlobals=3 // Use modern global access method.

#pragma IgorVersion=9.04 //requires Igor version 8.04 or higher
#pragma version=1.87

//*************************************************************************\
//* Copyright (c) 2005 - 2026, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution.
//*************************************************************************/

//This macro loads the Nika 1 set of Igor Pro macros for evaluation of 2D images in small angle scattering
//1.87		Updated all #include version requirements to current versions after AI code review.
//1.86		Nika modification for 12IDE USAXS/SAXS/WAXS instrument, Bug release
//1.86		Beta release, Nika modification for 12IDE USAXS/SAXS/WAXS instrument.
//1.85 		July2023 release, Fix NI1_SetAllPathsInNika which failed to setup properly very long paths.
//1.843 	Fix IP9.02 issue with AxisTransform1.2 change. April2023Beta
//1.842 	February2023 Beta
//1.84 		October2021 version
//			Fixes for some loaders where users found failures.
//1.83		require Igor 8.03 now. Not testing Igor 7 anymore.
//			Improve NXcanSAS 2D calibrated data import for NSLS-SMI beamline.
//1.826 	Beta version after February2020 release
//1.82 		rtGlobal=3 forced for all
//			Added support for 12ID-C data.
//			Add print in history which version has compiled, Useful info later when debugging.
//1.81   	December 2018 release. Updated 64bit xops, mainly for OSX.
//			Added 12ID-C support, first release.
//1.80		Official Igor 8 release, Fixed NEXUS exporter to save data which are easily compatible with sasView. sasView has serious limitations on what it can accept as input NXcanSAS nexus data.
//			Removed range selection controls and moved Save data options to its own tab "Save"
//			Added ImageStatistics and control for user for delay between series of images.
//			Added font type and size control from configuration to be used for CCD image label.
//			Added ability to fix negative intensities oversubtraction. Checkbox on Empty tab and if checked, ~1.5*abs(V_min) is added to ALL points intensities.
//1.79 		December 2018 release.
//1.80 		February 2020 release
//1.81		October2021 release

#include "NI1_BeamCenterUtils", version >= 2.32
#include "NI1_ConvProc", version >= 2.80
#include "NI1_DNDCATsupport", version >= 1.12
#include "NI1_FileLoaders", version >= 2.63
#include "NI1_FITSLoader", version >= 2.19
//#include "NI1_HDF5Browser",version>=1.02

#include "NI1_InstrumentSupport", version >= 1.24
#include "NI1_LineProfile", version >= 2.10
#include "NI1_Main", version >= 1.89
#include "NI1_MainPanel", version >= 2.77
#include "NI1_mask", version >= 1.32
#include "NI1_pix2Dsensitivity", version >= 1.08
#include "NI1_SaveRecallConfig", version >= 1.04
#include "NI1_SquareMatrix", version >= 1.06
#include "NI1_USAXSSupport", version >= 1.58
#include "NI1_WinView", version >= 1.87

#include "IN2_GeneralProcedures", version >= 2.33

#include "IRNI_NexusSupport", version >= 1.20

//#include ":NI1_LineProfCalcs",version>=2.12
//#include ":NI1_mar345", version>=1.03
