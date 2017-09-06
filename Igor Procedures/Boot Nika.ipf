#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.77
#pragma IgorVersion=7.05


//		 Promoted requriements to 7.05 due to bug in HDF5 support at lower versions


Menu "Macros"
	StrVarOrDefault("root:Packages:Nika12DSASItem1Str","Load Nika 2D SAS macros"), LoadNika2DSASMacros()
end


Function LoadNika2DSASMacros()
	if (str2num(stringByKey("IGORVERS",IgorInfo(0)))>=6.34)
		Execute/P "INSERTINCLUDE \"NI1_Loader\""
		Execute/P "COMPILEPROCEDURES "
		NewDataFolder/O root:Packages			//create the folder for string variable
		string/g root:Packages:Nika12DSASItem1Str
		SVAR Nika12DSASItem1Str=root:Packages:Nika12DSASItem1Str
		Nika12DSASItem1Str= "---"
		BuildMenu "SAS 2D"
		Execute/P "NI1_ReadNikaGUIPackagePrefs()"
	else
		DoAlert 0, "Your version of Igor is lower than 6.34, these macros need version 6.34 or higher. Please, update..."  
	endif
end


