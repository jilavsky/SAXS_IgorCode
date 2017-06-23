#pragma rtGlobals=1		// Use modern global access method.


// This is part of package called "AnisoSAS" for modeling of anisotropic small-angle scattering
// Jan Ilavsky, 6/2017


Menu "Macros"
	StrVarOrDefault("root:Packages:AnisoSASLoad1Str","Load AnisoSAS"), LoadAnisoSAS()
	//StrVarOrDefault("root:Packages:AnisoSASLoad1Str","Clementine MEM modeling help"), DisplayHelpTopic "Clementine MEM decay kinetics modeling"
end


Proc LoadAnisoSAS()
	if (str2num(stringByKey("IGORVERS",IgorInfo(0)))>=6.30)
		Execute/P "INSERTINCLUDE \"ASAS_Loader\""
		Execute/P "COMPILEPROCEDURES "
		NewDataFolder/O root:Packages			//create the folder for string variable
		string/g root:Packages:AnisoSASLoad1Str
		root:Packages:AnisoSASLoad1Str= "---"
	else
		DoAlert 0, "Your version of Igor is lower than 6.30, these macros need version 6.30 or higher. Please, update..."  
	endif
end
