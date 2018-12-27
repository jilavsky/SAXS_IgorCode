#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.97
#pragma IgorVersion=7.05

//1.97 	TBA
//1.96   December 2018, updates 64 bit OSX xops, changes and fixes for 2018-03 cycle and general improvements. 
//1.95 	July 2018 release, first official Igor 8 release
//1.94	Converted all procedure files to UTF8 to prevent text encoding issues. 
//			Fixed Case spelling of USAXS Error data to SMR_Error and DSM_Error.
//			Added ability to smooth R_Int data - suitable mostly for Blank where it removes noise from the blank. Should reduce noise of the USAXS data. 
//			Added masking options into FLyscan panel Listbox. 
//			Checked that - with reduced functionality - code will work without Github distributed xops. 
//			Tested and fixed for Igor 8 beta version. 
//1.93 Promoted requirements to 7.05 due to bug in HDF5 support at lower versions
//1.92 Igor 7 compatible ONLY now. 
//1.91 Igor 6 last release. 
//1.90 fixes for Nexus support and some other changes. 
//1.89 FIxes for panel scaling and added new FlyScan load & process tool 
//1.88 Panel scaling and other fixes. 
//1.87 Igor 7 updates
//1.86 Improvements to Flyscan handling
//1.85 9ID move and fixed to Flyscan support as needed. 
//1.84 release with Flyscan support for various modes up to August 2014 measurements. Should handle all of the different modes. 
//1.82 first user release of FLyScan support
//1.81 developement FLyScan version
//1.80 added FlyScan support and some GUI changes. 
//1.79 added ability to read pinDiode Transmission measured first during 4/2013
//1.78 added weight calibration 
//1.77 Use I0 and I00 ranges now included in spec files. 
//1.76 5/30/2012 GUI improvements
//1.75 4/26/2012 I0 auto range changing
//1.74 2/27/2012 minor fixes and improvements
//1.73, 2/19/2012. Changed Xtal calcualtor to be useful for our new crystals.
//1.72, May 7, 2011. Lowered I0 required vaue of counts to indicate beam dump and added filtration of USAXS 5 waves for NaNs


//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//	This is version 2.0 of "Indra" set of macros for USAXS data evaluation
//	"Indra" set of macros for USAXS data evaluation
//	Jan Ilavsky, ilavsky@aps.anl.gov, phone 630 252 0866
//	These macros allow evaluation of data obatined on Bonse-Hartmen camera at UNICAT 32ID beamline at APS
//	The data are collected through spec program.
//	Manual should be included with your distribution - RTFM!!!
//	Report any bugs promptly to me, I'll try to fix them ASAP
//	The macros hould run fine on PC platform and with less ideal graphic on Mac platform too.
//	The display setting of the computer should be 1024 or higher, otherwise the buttons may be unreadable, especially on Macs.
//	Good luck....
//	These macros were developed for Igor 5 on both platofrms.
//	Good luck....


Menu "Macros", dynamic
	IndraMacrosMenuItem(1)
	IndraMacrosMenuItem(2)
	IndraMacrosMenuItem(3)

//	StrVarOrDefault("root:Packages:USAXSItem1Str","Load USAXS Macros"), LoadIndra2()
//   if(Exists("LoadIR1Modeling")==6)
//	  StrVarOrDefault("root:Packages:USAXSItem1Str","Load USAXS+Irena"), LoadIndraAndIrena()
//   endif
//   if(Exists("LoadIR1Modeling")==6 && Exists("LoadNi12DSAS")==6)
//	 StrVarOrDefault("root:Packages:USAXSItem1Str","Load USAXS+Irena+Nika"), LoadIndraAndIrena()
//   endif
end



Function/S IndraMacrosMenuItem(itemNumber)
	Variable itemNumber

	if (itemNumber == 1)
			SVAR/Z USAXSItem1Str =  root:Packages:USAXSItem1Str
			if(SVAR_Exists(USAXSItem1Str))
				return USAXSItem1Str
			else
				return "Load USAXS macros"	
			endif
	endif

	if (itemNumber == 2)
	  if(Exists("LoadIrenaSASMacros")==6)
			SVAR/Z USAXSItem1Str =  root:Packages:USAXSItem1Str
			if(SVAR_Exists(USAXSItem1Str))
				if(StringMatch(USAXSItem1Str, "---" ))
					return "---"
				else
					return "Load USAXS and Irena"
				endif
			else
				return "Load USAXS and Irena"	
			endif
		 // return "StrVarOrDefault(\"root:Packages:USAXSItem1Str\",\"Load USAXS+Irena\"), LoadIndraAndIrena()"
 	 endif
	endif
	if (itemNumber == 3)
	  if(Exists("LoadIrenaSASMacros")==6 && Exists("LoadNika2DSASMacros")==6)
			SVAR/Z USAXSItem1Str =  root:Packages:USAXSItem1Str
			if(SVAR_Exists(USAXSItem1Str))
				if(StringMatch(USAXSItem1Str, "---" ))
					return "---"
				else
					return "Load USAXS, Irena and Nika"
				endif
			else
				return "Load USAXS, Irena and Nika"	
			endif
		   // return "StrVarOrDefault(\"root:Packages:USAXSItem1Str\",\"Load USAXS+Irena\"), LoadIndraAndIrena()"
   	 endif
	endif
End



Proc LoadUSAXSAndIrena()
	LoadUSAXSMacros()
	Execute/P("LoadIrenaSASMacros()")
end
Proc LoadUSAXSIrenaandNika()
	LoadUSAXSMacros()
	Execute/P("LoadIrenaSASMacros()")
	Execute/P("LoadNika2DSASMacros()")
end

Function LoadUSAXSMacros()
	if (str2num(stringByKey("IGORVERS",IgorInfo(0)))>=7.05)
		Execute/P "INSERTINCLUDE \"IN2_Load Indra 2\""
		Execute/P "COMPILEPROCEDURES "
		Execute/P "IN2N_CreateShowNtbkForLogging(0)"
		Execute/P "ionChamberInitPackage()"
		NewDataFolder/O root:Packages			//create the folder for string variable
		string/g root:Packages:USAXSItem1Str
		SVAR USAXSItem1Str = root:Packages:USAXSItem1Str
		USAXSItem1Str= "---"
		BuildMenu "USAXS"
		//IN2L_GenerateReadMe()
	else
		DoAlert 0, "Your version of Igor is lower than 7.05, these macros need version 7.05 or higher"  
	endif
	
end


