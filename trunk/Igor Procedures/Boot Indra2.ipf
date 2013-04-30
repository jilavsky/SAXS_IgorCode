#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.79

//1.79 added ability to read pinDiode Transmission measured first during 4/2013
//1.78 added weight calibration 
//1.77 Use I0 and I00 ranges now included in spec files. 
//1.76 5/30/2012 GUI improvements
//1.75 4/26/2012 I0 auto range changing
//1.74 2/27/2012 minor fixes and improvements
//1.73, 2/19/2012. Changed Xtal calcualtor to be useful for our new crystals.
//1.72, May 7, 2011. Lowered I0 required vaue of counts to indicate beam dump and added filtration of USAXS 5 waves for NaNs

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
	if (str2num(stringByKey("IGORVERS",IgorInfo(0)))>5.04)
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
		DoAlert 0, "Your version of Igor is lower than 5.05, these macros need version 5.05 or higher"  
	endif
	
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//
//Function IN2L_ReadmeNISTMacros()
//	//creates or brings forward the readme for use of NISt macros...
//
//	String nb = "IN2F_NISTModelsReadMe"
//
//	Silent 1
//	if (strsearch(WinList("*",";","WIN:16"),nb,0)!=-1) 		///Logbook exists
//		DoWindow/F $nb
//	else
//	NewNotebook/N=$nb/F=1/V=1/K=3/W=(69,43.25,579,369.5) as "IN2F_NISTModelsReadMe"
//	Notebook $nb defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
//	Notebook $nb showRuler=1, rulerUnits=2, updating={1, 3600}
//	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",10,0,(0,0,0)}
//	Notebook $nb newRuler=Title, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",14,0,(0,0,0)}
//	Notebook $nb ruler=Title, text="This is ReadMe for use of NIST Models with USAXS\r"
//	Notebook $nb text="\r"
//	Notebook $nb ruler=Normal
//	Notebook $nb text="NIST models are freely distributed by NIST Center for Neutron research. For any special rules regarding "
//	Notebook $nb text="their use, please contact them. I am including the copy of these macros in Indra2 package, because this "
//	Notebook $nb text="was requested by users. I am unable to provide any support for these macros. I am, however, supporting i"
//	Notebook $nb text="nterface for use of these macros with Indra2 package.\r"
//	Notebook $nb text="\r"
//	Notebook $nb text="Comments: NIST macros expect data with different naming convention then I use in the Indra2 macros. To"
//	Notebook $nb text="provide good integration with Indra2 USAXS macros the data are copied in new (fitting) folder and named w"
//	Notebook $nb text="ith the NIST convention. Then you - user - are on your own. You can do whatever you want in this folder."
//	Notebook $nb text="..\r"
//	Notebook $nb text="\r"
//	Notebook $nb text="Use:\r"
//	Notebook $nb text="Select \"Use NIST models\" from \"USAXS\" menu. Pick folder with data - ONLY folders with Desmeared data are"
//	Notebook $nb text=" shown. The data are then copied in new folder with same name in the \"Modeling\" folder. If this folder e"
//	Notebook $nb text="xists, the data in the folder are overwritten!!! The data are copied with appropriate NIST naming conve"
//	Notebook $nb text="nition, keeping as much Indra2 structure as possible... \r"
//	Notebook $nb text="\r"
//	Notebook $nb text="With NIST fitting macros use only models without smearing!!! Your data are desmeared already.\r"
//	Notebook $nb text="\r"
//	Notebook $nb text="Jan Ilavsky, 4/17/2007  "
//	endif
//end


//*****************************************************************************************************************
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
	NewNotebook/N=$nb/F=1/V=1/K=3/W=(563,114,1628,866) as "Read Me"
	Notebook $nb defaultTab=36, statusWidth=238, magnification=150
	Notebook $nb showRuler=1, rulerUnits=2, updating={1, 3600}
	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",9,0,(0,0,0)}
	Notebook $nb newRuler=Header, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",14,0,(0,0,0)}
	Notebook $nb ruler=Header, text="Quick Manual for Indra2 version of USAXS macros\r"
	Notebook $nb ruler=Normal, text="This is version 1.76 of Indra 2 macros, date: 10/1/2012\r"
	Notebook $nb text="\r"
	Notebook $nb text="Procedure review:\r"
	Notebook $nb text="1.\tmenu \"USAXS\" - \"Import RAW data\"\r"
	Notebook $nb text="2.\tmenu \"USAXS\" - \"Reduce data main\"\tThis wil open main panel which is used to reduce data.\r"
	Notebook $nb text="\tIf you want absolute intensities, you will need to know the sample thickness at this time.  If you don'"
	Notebook $nb text="t have that \tnow, you will need to repeat this procedure from this step. [NOTE: not exactly true, you ca"
	Notebook $nb text="n calculate t, if you \tknow linear absorption coefficient]\r"
	Notebook $nb text="\tUse MSAXS correction only if data are contaminated by mulitple scattering in the main tool.\r"
	Notebook $nb text="\tMain menu also allows user to subtract background and export the data for use in external programs.\r"
	Notebook $nb text="\tThis is not needed and should not be used if data evaluation tools in Irena are going to be used.\r"
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

//	Notebook $nb text="(2.)\tusually started automatically menu \"USAXS\"->\"Spec\" -> \"Raw to USAXS ...\"\r"
//	Notebook $nb text="\tNote, that you will have to set first time data conversion table (started automatically).\r"
//	Notebook $nb text="3.\tmenu \"USAXS\" - \"Create R wave\"\tCreate Rocking curve data.\r"
//	Notebook $nb text="4.\tmenu \"USAXS\" - \"Subtract Blank from Sample\"\r"
//	Notebook $nb text="\tIf you want absolute intensities, you will need to know the sample thickness\r"
//	Notebook $nb text="\tat this time.  If you don't have that now, you will need to repeat this procedure\r"
//	Notebook $nb text="\tfrom this step. [NOTE: not exactly true, you _could_ guess t, then make adjustments afterwards.]\r"
//	Notebook $nb text="(5.)\tmenu \"USAXS\" - \"MSAXS correction\"\t(only if data are contaminated by mulitple scattering)\r"
//	Notebook $nb text="6.\tmenu \"USAXS\" - \"Desmear data\"\r"
//	Notebook $nb text="(7.)\tmenu \"USAXS\" - \"Export all data\"\r"
//	Notebook $nb text="\tThe data can be exported in each step, but exports all the \r"
//	Notebook $nb text="\tdifferent types of data into a user-specified directory.\r"
//	Notebook $nb text="(8.)\tmenu \"USAXS\" - \"Subtract Background\"\r"
//	Notebook $nb text="\tAllows user to subtract background and export the data for use in external programs.\r"
//	Notebook $nb text="\tThis is not needed and should not be used if data evaluation tools in Irena are going to be used.\r"
//	Notebook $nb text="(9.)\tmenu \"USAXS->USAXS Plotting tools\"\r"
//	Notebook $nb text="\t\t\"Standard ....\"\t standard USAXS type plots (Int-Q, Porod plot, Guinier plot)\r"
//	Notebook $nb text="\t\t\"Basic ....\"\toffers wave variables most likely to be used in USAXS plots\r"
//	Notebook $nb text="\t\t\"Generic ....\"\tallows user to plot any available wave variables (only one for non-USAXS data)\r"
//	Notebook $nb text="(10.)\tmenu \"Macros\" - \"Load NIST models\"\r"
//	Notebook $nb text="\tThis starts small code to aid use of NIST SAS modeling functions and loads a set of these functions.\r"
//	Notebook $nb text="\r"
//	Notebook $nb text="Suggestions: \r"
//	Notebook $nb text="a.\tSet Autosave (menu \"Macros\" - \"Set Autosave\") to reasonable time, it will save automatically for you.\r"
//	Notebook $nb text="\t(you need autosave.xop installed for this feature)\r"
//	Notebook $nb text="b.\tDo not work with Igor files over an NFS network connection, first copy those files to a local disk.\r"
//	Notebook $nb text="c.\tUse automatic logging functions -  \r"
//	Notebook $nb text="\tmenu \"USAXS\" - \"Log in Notebook\" - \"Create logbook\" and \"Create Summary Notebook\". \r"
//	Notebook $nb text="\r"
//	Notebook $nb text="Make notes of any bugs and forward them to me. Make notes of any suggestions on changes in the wording o"
//	Notebook $nb text="f dialogs - I am opened to any reasonable changes....\r"
