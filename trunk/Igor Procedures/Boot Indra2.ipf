#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.82

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
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
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


Menu "Macros"
	StrVarOrDefault("root:Packages:USAXSItem1Str","Load USAXS Macros"), LoadIndra2()
end



Proc LoadIndra2()
	if (str2num(stringByKey("IGORVERS",IgorInfo(0)))>6.30)
		Execute/P "INSERTINCLUDE \"IN2_Load Indra 2\""
		Execute/P "COMPILEPROCEDURES "
		Execute/P "IN2N_CreateShowNtbkForLogging(0)"
		Execute/P "ionChamberInitPackage()"
		NewDataFolder/O root:Packages			//create the folder for string variable
		string/g root:Packages:USAXSItem1Str
		root:Packages:USAXSItem1Str= "---"
		BuildMenu "USAXS"
		IN2L_GenerateReadMe()
	else
		DoAlert 0, "Your version of Igor is lower than 6.30, these macros need version 6.3x or higher"  
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
	NewNotebook/N=$nb/F=1/V=1/K=3/W=(266,68,1002,696) as "Read Me"
	Notebook $nb defaultTab=36, statusWidth=238, magnification=150
	Notebook $nb showRuler=1, rulerUnits=2, updating={1, 3600}
	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",9,0,(0,0,0)}
	Notebook $nb newRuler=Header, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",14,0,(0,0,0)}
	Notebook $nb ruler=Header, text="Quick Manual for Indra 2 version of USAXS macros\r"
	Notebook $nb ruler=Normal, text="This is version 1.82 of Indra macros, date: 2/20/2014\r"
	Notebook $nb text="\r"
	Notebook $nb text="Procedure review:\r"
	Notebook $nb text="1.\tImport data: menu \"USAXS\" - \"Import RAW data\", \"Import Desktop..\", \"Import USAXS FlyScan data\".\r"
	Notebook $nb text="2.\tmenu \"USAXS\" - \"Reduce data main\"\tThis will open main panel which is used to reduce data.\r"
	Notebook $nb text="\tIf you want absolute intensities, you will need to know the sample thickness at this time.  If you don'"
	Notebook $nb text="t have that \tnow, you will need to repeat this procedure from this step. [NOTE: not exactly true, you ca"
	Notebook $nb text="n calculate t, if you \tknow linear absorption coefficient]\r"
	Notebook $nb text="\tIf we measured USAXS transmission using pinDiode, use it (and do nto use MSAXS correction)\r"
	Notebook $nb text="\tIf we did tno measure pinDIode, may be you need to MSAXS correction - but only if data are contaminated"
	Notebook $nb text="\r"
	Notebook $nb text="\tby mulitple scattering in the main tool.\r"
	Notebook $nb text="\tMain menu also allows user to subtract background and export the data for use in external programs.\r"
	Notebook $nb text="\tThis is not needed and should not be used if data evaluation tools in Irena are going to be used.\r"
	Notebook $nb text="2a.\tIf you use FlyScan, you may need to select FlyScan rebin to number of points...\r"
	Notebook $nb text="\tFor regular samples - 200 - 300 points\r"
	Notebook $nb text="\tFor Samples with monodispersed systems/.diff peaks: 1000-3000 may be necessary\r"
	Notebook $nb text="\tDo NOT produce unnecessary many points - data will take much more time to analyze.  \r"
	Notebook $nb text="3.\tOther possible useful tools:\r"
	Notebook $nb text="\tTo Desmear data you will need Irena package which contains the desmearing routine in \"Other tools\"\r"
	Notebook $nb text="\t\"USAXS->USAXS Plotting tools\" - preferably use Irena \"Plotting tool I\"\r"
	Notebook $nb text="\t\t\"Standard ....\"\t standard USAXS type plots (Int-Q, Porod plot, Guinier plot)\r"
	Notebook $nb text="\t\t\"Basic ....\"\toffers wave variables most likely to be used in USAXS plots\r"
	Notebook $nb text="\t\t\"Generic ....\"\tallows user to plot any available wave variables (only one for non-USAXS data)\r"
	Notebook $nb text="\t\r"
	Notebook $nb text="Suggestions: \r"
	Notebook $nb text="a.\tSave Igor experiment once in a while.\r"
	Notebook $nb text="b.\tDo not work with Igor files over an NFS network connection, first copy those files to a local disk.\r"
	Notebook $nb text="c.\tUse automatic logging functions -  \r"
	Notebook $nb text="\tmenu \"USAXS\" - \"Log in Notebook\" - \"Create logbook\" and \"Create Summary Notebook\". \r"
	Notebook $nb text="\r"
	Notebook $nb text="Make notes of any bugs and forward them to me. Make notes of any suggestions on changes in the wording o"
	Notebook $nb text="f dialogs - I am opened to any reasonable changes....\r"
end
