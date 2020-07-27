#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.826
#pragma IgorVersion=7.05

//1.826 	Beta version July2020 release
//1.82		February 2020 release. Maintenance, many small changes. 
//1.81   December 2018. New OSX 64-bit xop version.  
//1.80 	July 2018 release, first official Igor 8 release
//1.79	Converted all procedure files to UTF8 to prevent text encoding issues. 
//			Modified main interface to have radio buttons and only one button for action. This makes cleaner interface as some controls can be hidden. Unluckily, panel is now higher by 20 points. 
//			Added support for ALS SRoXS soft energy beamline. 
//			Improved 9IDC USAXS support. 
//			Added more masking options into main panel listbox right click. 
//			Checked that - with reduced functionality - code will work without Github distributed xops. 
//			Bug fix - changed ki/kout single precision waves to double precision. This caused issues under very small angles when data were unintentionally binned to less points what should have been produced. This is very old bug causing issues at very small Q vectors with short wavelengths and no beamstops.  
//			Tested and fixed for Igor 8 beta version. 
//			 
//1.78 Promoted requirements to 7.05 due to bug in HDF5 support at lower versions


Menu "Macros"
	StrVarOrDefault("root:Packages:Nika12DSASItem1Str","Load Nika 2D SAS macros"), LoadNika2DSASMacros()
end


Function LoadNika2DSASMacros()
	if (str2num(stringByKey("IGORVERS",IgorInfo(0)))>=7.05)
		Execute/P "INSERTINCLUDE \"NI1_Loader\""
		Execute/P "COMPILEPROCEDURES "
		NewDataFolder/O root:Packages			//create the folder for string variable
		string/g root:Packages:Nika12DSASItem1Str
		SVAR Nika12DSASItem1Str=root:Packages:Nika12DSASItem1Str
		Nika12DSASItem1Str= "---"
		BuildMenu "SAS 2D"
		Execute/P "NI1_ReadNikaGUIPackagePrefs()"
	else
		DoAlert 0, "Your version of Igor is lower than 7.05, these macros need version 7.05 or higher. Please, update..."  
	endif
end


