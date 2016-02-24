#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.60

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
				return "Load Irena SAS Macros"	
			endif
	endif

	if (itemNumber == 2)
	  if(Exists("LoadNika2DSASMacros")==6)
			SVAR/Z SASItem1Str =  root:Packages:SASItem1Str
			if(SVAR_Exists(SASItem1Str))
				if(StringMatch(SASItem1Str, "---" ))
					return "---"
				else
					return "Load Nika And Irena"
				endif
			else
				return "Load Nika And Irena"	
			endif
		 // return "StrVarOrDefault(\"root:Packages:USAXSItem1Str\",\"Load USAXS+Irena\"), LoadIndraAndIrena()"
 	 	endif
	endif
end

Proc LoadNikaAndIrena()
	LoadIrenaSASMacros()
	Execute/P("LoadNika2DSASMacros()")
end


Function LoadIrenaSASMacros()
	if (str2num(stringByKey("IGORVERS",IgorInfo(0)))>=6.30)
		//check for old version of Irena
		pathInfo Igor
		NewPath/Q/O/Z UserProcPath , S_path+"User procedures"
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
		SVAR SASItem1Str = root:Packages:SASItem1Str
		//root:Packages:SASItem1Str= "(Load Irena SAS Modeling Macros"
		SASItem1Str= "---"
		BuildMenu "SAS"
		//Execute/P ("IR2C_ReadIrenaGUIPackagePrefs()")			//this executes configuration and makes sure all exists.
		//not needed, done automatically as part of after compile hook function
	else
		DoAlert 0, "Your version of Igor is lower than 6.30, these macros need version 6.30 or higher, please update your Igor 6 to the latest release "  
	endif
end
