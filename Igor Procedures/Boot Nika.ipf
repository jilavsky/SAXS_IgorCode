#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.62


Menu "Macros"
	StrVarOrDefault("root:Packages:Nika12DSASItem1Str","Load Nika 2D SAS Macros"), LoadNi12DSAS()
end


Function LoadNi12DSAS()
	if (str2num(stringByKey("IGORVERS",IgorInfo(0)))>6.19)
		Execute/P "INSERTINCLUDE \"NI1_Loader\""
		Execute/P "COMPILEPROCEDURES "
		NewDataFolder/O root:Packages			//create the folder for string variable
		string/g root:Packages:Nika12DSASItem1Str
		SVAR Nika12DSASItem1Str=root:Packages:Nika12DSASItem1Str
		Nika12DSASItem1Str= "---"
		BuildMenu "SAS 2D"
		Execute/P "NI1_ReadIrenaGUIPackagePrefs()"
	else
		DoAlert 0, "Your version of Igor is lower than 6.20, these macros need version 6.20 or higher. Please, update..."  
	endif
end


