#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.55

Menu "Macros"
//	"Load Irena SAS Modeling Macros", LoadIR1Modeling()
	StrVarOrDefault("root:Packages:SASItem1Str","Load Irena SAS Macros"), LoadIR1Modeling()
end


Proc LoadIR1Modeling()
	if (str2num(stringByKey("IGORVERS",IgorInfo(0)))>=6.30)
		//check for old version of Irena
		pathInfo Igor
		NewPath/Q/O UserProcPath , S_path+"User procedures"
		GetfILEfOLDERiNFO/Q/Z/P=UserProcPath "Irena 1"
		string MessageStr="Original Irena folder found in User Procedures! \nFrom the version 2.04 Irena should be installed in \"Irena\" folder."
		MessageStr +=" Delete old version in folder \"Irena 1\" and the folder itself and install new version in \"Irena\" folder"
		if(V_Flag==0)
			Abort MessageStr
		endif
		GetfILEfOLDERiNFO/Q/Z/P=UserProcPath "Irena1_Saved_styles"
		variable StylesExist=V_Flag
		GetfILEfOLDERiNFO/Q/Z/P=UserProcPath "Irena1_CalcSavedCompounds"
		variable CompoundsExist=V_Flag
		if(StylesExist==0 || CompoundsExist==0)
			MessageStr ="Old folders for Styles and Compounds found! \nRename folders \"Irena1_Saved_styles\" into \"Irena_Saved_styles\""
			MessageStr +=" and \"Irena1_CalcSavedCompounds\" into \"Irena_CalcSavedCompounds\" if these exist in User procedures"
			Abort MessageStr		
		endif
	
		Execute/P "INSERTINCLUDE \"IR1_Loader\""
		Execute/P "COMPILEPROCEDURES "
		NewDataFolder/O root:Packages			//create the folder for string variable
		string/g root:Packages:SASItem1Str
//		root:Packages:SASItem1Str= "(Load Irena SAS Modeling Macros"
		root:Packages:SASItem1Str= "---"
		BuildMenu "SAS"
		Execute/P ("IR2C_ReadIrenaGUIPackagePrefs()")			//this executes configuration and makes sure all exists.
	else
		DoAlert 0, "Your version of Igor is lower than 6.30, these macros need version 6.30 or higher, please update your Igor 6 to the latest release "  
	endif
end
