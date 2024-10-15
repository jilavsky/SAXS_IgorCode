#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 2.73
#pragma IgorVersion=8.04

//2.73   Added Ellipsoid Cylinder support
//2.72		July2023 release
//2.71x	Development versions
//2.71 	October2021 release
//2.70 	September2020 release
//2.69		February 2020 release
//2.68   December 2018,new 64 bit OSX xops. Data Merge improvements, many other fixes. 
//2.67   July 2018 release, first official Igor 8 release
//2.66   Converted all procedure files to UTF8 to prevent text encoding issues. 
//			Fixed Case spelling of USAXS Error data to SMR_Error and DSM_Error
//			Plotting tool I - added control which enforces maximum number of items in legend (default=30). If more waves are in graph, legend gets decimated by necessary integer(2, 3, 4,...). First and last are always included. This presents selection of data names when too many data sets are used. 
//			MergeData - added ability to fit-extrapolate data 1 at high q end and added possibility to fit arbitrary combination of merging parameters. Lots of changes. More capable and more complicated. 
//			Unified Fit - added button "Copy/Swap level" which will move content of existing level to another level. 
//			Checked that - with reduced functionality - code will work without Github distributed xops. 
//			Tested and fixed for Igor 8 beta version. 
//2.65 Promoted requirements to 7.05 due to bug in HDF5 support at lower versions


//*************************************************************************\
//* Copyright (c) 2005 - 2025, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

Menu "Macros", dynamic
	//StrVarOrDefault("root:Packages:SASItem1Str","Load Irena SAS Macros"), LoadIrenaSASMacros()
	IrenaMacrosMenuItem(1)
	IrenaMacrosMenuItem(2)
end

Function/S IrenaMacrosMenuItem(itemNumber)
	Variable itemNumber

	if (itemNumber == 1)
			SVAR/Z SASItem1Str =  root:Packages:SASItem1Str
			if(SVAR_Exists(SASItem1Str))
				return SASItem1Str
			else
				return "Load Irena SAS macros"	
			endif
	endif

	if (itemNumber == 2)
	  if(Exists("LoadNika2DSASMacros")==6)
			SVAR/Z SASItem1Str =  root:Packages:SASItem1Str
			if(SVAR_Exists(SASItem1Str))
				if(StringMatch(SASItem1Str, "---" ))
					return "---"
				else
					return "Load Irena and Nika"
				endif
			else
				return "Load Irena and Nika"	
			endif
		 // return "StrVarOrDefault(\"root:Packages:USAXSItem1Str\",\"Load USAXS+Irena\"), LoadIndraAndIrena()"
 	 	endif
	endif
end

Proc LoadIrenaandNika()
	LoadIrenaSASMacros()
	Execute/P("LoadNika2DSASMacros()")
end


Function LoadIrenaSASMacros()
	if (str2num(stringByKey("IGORVERS",IgorInfo(0)))>=7.05)
		Execute/P "INSERTINCLUDE \"IR1_Loader\""
		Execute/P "COMPILEPROCEDURES "
		NewDataFolder/O root:Packages			//create the folder for string variable
		string/g root:Packages:SASItem1Str
		SVAR SASItem1Str = root:Packages:SASItem1Str
		SASItem1Str= "---"
		BuildMenu "SAS"
	else
		DoAlert 0, "Your version of Igor is lower than 7.05, these macros need version 7.05 or higher, please update your Igor to the latest release "  
	endif
end
