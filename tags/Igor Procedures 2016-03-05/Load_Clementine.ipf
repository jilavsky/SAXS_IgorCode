#pragma rtGlobals=1		// Use modern global access method.


// This is part of package called "Clementine" for modeling of decay kinetics using Maximum Entropy method
// Jan Ilavsky, PhD June 1 2008


Menu "Macros"
	StrVarOrDefault("root:Packages:ClementineLoad1Str","Load Clementine MEM modeling"), LoadClementine()
	StrVarOrDefault("root:Packages:ClementineLoad1Str","Clementine MEM modeling help"), DisplayHelpTopic "Clementine MEM decay kinetics modeling"
end


Proc LoadClementine()
	if (str2num(stringByKey("IGORVERS",IgorInfo(0)))>=6.02)
		Execute/P "INSERTINCLUDE \"DecayModeling_Load\""
		Execute/P "COMPILEPROCEDURES "
		NewDataFolder/O root:Packages			//create the folder for string variable
		string/g root:Packages:ClementineLoad1Str
//		root:Packages:SASItem1Str= "(Load Irena SAS Modeling Macros"
		root:Packages:ClementineLoad1Str= "---"
		//BuildMenu "SAS 2D"
	else
		DoAlert 0, "Your version of Igor is lower than 6.02, these macros need version 6.02 or higher. Please, update..."  
	endif
end
