#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1
 
//	This is version 3.0 of "Indra" set of macros for USAXS data evaluation
//	Jan Ilavsky, ilavsky@aps.anl.gov, phone 630 252 0866
//	These macros allow evaluation of data obatined on Bonse-Hartmen camera at UNICAT 32ID beamline at APS
//	The data are collected through spec program.
//	Manual should be included with your distribution - RTFM!!!
//	Report any bugs promptly to me, I'll try to fix them ASAP
//	The macros hould run fine on PC platform and with less ideal graphic on Mac platform too.
//	The display setting of the computer should be 1024 or higher, otherwise the buttons may be unreadable, especially on Macs.
//	Good luck....

//latest update 12/1/2003

#include "IN3_Main", version>=1
#include "IN3_SupportFnct", version>=1
#include "IN3_Calculations", version>=1
#include "IN3_Rwave", version>=1
#include "IN2_GeneralProcedures", version>=1.46

#include "IR2_PanelCntrlProcs", version>=1.02

