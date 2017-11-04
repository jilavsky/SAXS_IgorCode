#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.93
#pragma IgorVersion=7.05

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
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
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
		IN2L_GenerateReadMe()
	else
		DoAlert 0, "Your version of Igor is lower than 7.05, these macros need version 7.05 or higher"  
	endif
	
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN2L_GenerateReadMe()
	Dowindow USAXSQuickManual
	if (V_flag)
		Dowindow/F USAXSQuickManual
		abort
	endif
	String nb = "USAXSQuickManual"
	NewNotebook/N=$nb/F=1/V=1/K=3/W=(464,45,1152,768) as "Read Me"
	Notebook $nb defaultTab=36, magnification=150
	Notebook $nb showRuler=1, rulerUnits=2, updating={1, 3600}
	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",9,0,(0,0,0)}
	Notebook $nb newRuler=Header, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",14,0,(0,0,0)}
	Notebook $nb ruler=Header, text="Quick Manual for Indra 2 version of USAXS macros\r"
	Notebook $nb ruler=Normal, text="This is version 1.90 of Indra macros, date: 2/20/2017\r"
	Notebook $nb text="\r"
	Notebook $nb text="Data reduction summary:\r"
	Notebook $nb ruler=Normal; Notebook $nb  margins={0,35,468}
	Notebook $nb text="1.\tImport data: menu \"USAXS\" - \"Import and Reduce USAXS data\". ", fStyle=1
	Notebook $nb text="ONLY if you have Flyscan Nexus files as input", fStyle=-1, text=". ", fStyle=4, text="Most common"
	Notebook $nb fStyle=-1
	Notebook $nb text=". Opens GUI which can import data and process them at the same time. Follow procedure in step 3. \r"
	Notebook $nb text="2.\tAlternative: \r"
	Notebook $nb text="\ta.\tmenu \"USAXS\" - \"Other input methods\" - \"Import USAXS .... data\" - imports either Flyscan Nexus data,"
	Notebook $nb text=" Step scan data from spec file or Osmic-Rigaku data. Opens separate GUI to import appropriate data type."
	Notebook $nb text=" \r"
	Notebook $nb text="\tb. \tmenu \"USAXS\" - \"Other input methods\" - \"Reduce data \"    This will open GUI panel which is used to "
	Notebook $nb text="reduce data imported in step 2a. Follow procedure in step 3. \r"
	Notebook $nb text="3.\tProcess data - FIRST you need instrumental curve  (\"Process as Blank\"). Save processed instrumental c"
	Notebook $nb text="urve (Blank). With ", fStyle=1, text="correct", fStyle=-1, text=" Blank you can process samples. \r"
	Notebook $nb text="\tIf you want absolute intensities, you will need to know the sample thickness at this time.  If you don'"
	Notebook $nb text="t have that \tnow, you will need to repeat this procedure from this step. [NOTE: not exactly true, you ca"
	Notebook $nb text="n calculate it, if you \tknow linear absorption coefficient]\r"
	Notebook $nb text="\tIf we measured USAXS transmission (most likely) using pinDiode, it will be used automatically ("
	Notebook $nb fStyle=4, text="MSAXS correction is not needed", fStyle=-1
	Notebook $nb text=") If we did not measure pinDIode, may be you need to use MSAXS correction - but only if data are contami"
	Notebook $nb text="nated by mulitple scattering in the main tool. Check with staff. \r"
	Notebook $nb text="\tIf you use FlyScan, you may need to select FlyScan rebin to number of points...\r"
	Notebook $nb text="\tFor regular samples - 200 - 300 points\r"
	Notebook $nb text="\tFor Samples with monodispersed systems/diff peaks: more (up to 1000-2000) may be necessary\r"
	Notebook $nb text="\tDo NOT produce needlesly too many points - data will take much more time to analyze.  \r"
	Notebook $nb ruler=Normal, text="4.\tOther possible useful tools:\r"
	Notebook $nb text="\tTo Desmear data you will need Irena package which contains the desmearing routine in \"Other tools\"\r"
	Notebook $nb text="\t\"USAXS->USAXS Plotting tools\" - preferably use Irena \"Plotting tool I\"\r"
	Notebook $nb text="\t\t\"Standard ....\"\t standard USAXS type plots (Int-Q, Porod plot, Guinier plot)\r"
	Notebook $nb text="\t\t\"Basic ....\"\toffers wave variables most likely to be used in USAXS plots\r"
	Notebook $nb text="\t\t\"Generic ....\"\tallows user to plot any available wave variables (only one for non-USAXS data)\r"
	Notebook $nb ruler=Normal; Notebook $nb  margins={0,34,468}
	Notebook $nb text="5.\tTo export data use Irena, data export tool. But if you need to export ASCII data, they should be desm"
	Notebook $nb text="eared first, very likely... Keep that in mind. \r"
	Notebook $nb ruler=Normal, text="\t\r"
	Notebook $nb text="Suggestions: \r"
	Notebook $nb text="a.\tSave Igor experiment once in a while.\r"
	Notebook $nb text="b.\tDo not work with Igor files over an NFS network connection, first copy those files to a local disk.\r"
	Notebook $nb text="c.\tUse automatic logging functions -  \r"
	Notebook $nb text="\tmenu \"USAXS\" - \"Log in Notebook\" - \"Create logbook\" and \"Create Summary Notebook\". \r"
	Notebook $nb text="\r"
	Notebook $nb text="Make notes of any bugs and forward them to me. Make notes of any suggestions on changes in the wording o"
	Notebook $nb text="f dialogs - I am opened to any reasonable changes....\r"
end

