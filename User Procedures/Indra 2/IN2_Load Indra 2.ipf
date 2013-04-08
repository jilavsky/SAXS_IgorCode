#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion=6.2	//requires Igor version 6 or higher
#pragma version=1.78

// 1.78 added wieght calibration
// 1.77 update, small changes, use of I0gain and I00gain
// 1.76 update, small chanegs. 5/30/2012
// 1.75 update, added autoraning I0 option. 4/30/2012
// 1.74 update, Added new Crystal calculator, 15/1/2012

//	This is version 3.0 of "Indra" set of macros for USAXS data evaluation
//	Jan Ilavsky, ilavsky@aps.anl.gov, phone 630 252 0866
//	These macros allow evaluation of data obatined on Bonse-Hartman camera at 15ID beamline at APS
//	The data are collected through spec program.
//	Report any bugs promptly to me, I'll try to fix them ASAP
//	The macros hould run fine on PC platform and with less ideal graphic on Mac platform too.
//	The display setting of the computer should be 1024 or higher, otherwise the buttons may be unreadable, especially on Macs.
//	Good luck....


#include ":IN2_BckgSubtr", version>=1.01
#include ":IN2_Conversion Procedure", version>=1.10
#include ":IN2_DesktopUSAXS", version>=0.2
#include ":IN2_GAUSAXS 1", version>=1
#include ":IN2_GeneralProcedures", version>=1.64
#include ":IN2_ImportX23", version>=1.10
#include ":IN2_Merging Data", version>=1.10
#include ":IN2_NotebookLogging", version>=1.10
#include ":IN2_PlottingTools", version>=1.13
#include ":IN2_SpecInput", version>=1.18
#include ":IN2_Standard Plots", version>=1.13
#include ":IN2_USAXS", version>=1.30
#include ":IN2_XtalCalculationsP", version>=1

#include ":IN3_CalcScattering", version>=1
#include ":IN3_Calculations", version>=1.06
#include ":IN3_Main", version>=1.78
#include ":IN3_Rwave", version>=1
#include ":IN3_SupportFnct", version>=1.01

#include ":Spec", version>=2.2
//#include ":IN2_XtalCalculations", version>=1
#include ":IonChamber3.1", version>=3.1

#include "::Irena:IR2_PanelCntrlProcs", version>=1.25


