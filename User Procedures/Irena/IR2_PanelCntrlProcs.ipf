#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3			// Use modern global access method.
#pragma version = 1.66


//*************************************************************************\
//* Copyright (c) 2005 - 2022, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.66 add to USAXS combination of Detector=Xdata, this is for Tiled imported tune scans. Also fixed IR3C_GenStringOfFolders2
//1.65 added SimpleFits Power Law
//1.64 added SimpleFits 1DCorrelation results: Corr1DZ_N for X and Y are: Corr1DK_N or Corr1DGammaA_N or Corr1DGammaI_N
//1.63 modified IR2C_ReturnKnownToolResults to enable downselection of results types. This makes AllowedResultsTypes parameter finally useful. From code pass "" if no downselection is needed. 
//1.62 added System Speciifc data type in results. 
//1.61 add to Multi controls sorting by _xyzs as time in seconds. 
//1.60 add Multi controls - controls with listbox... For tools needing ability to select multiple data sets. 
//			changed bahavior for generic (no defined data types selected) data. Now, if user selects X, Y, or E wave and in next folder user selects such waves exist, 
//							the names will be reatined and not repalced by "---" as before. Seems mopre reasonable. If waves do nto exist in the new folder, names are reset to "---" 
//			fixes to handling of fUserDefined data - Dale has found few bugs as he is using the tool. Still, some bugs left in there... 
// 
//1.53 addes Level fits for Guinier-Porod. Adds Level0 for Unified/GP and pop0 for Modeling which are simply flat background wave. 
			//fixed results lookup which seemed to have failed for more than two results available... 
			//removed duplicates fromWave with X list. 
//1.52 fixes for special characters " [ ] , . " iused in folder and wave names. Broke grep, fixed by escaping before use. 
//1.51 fixes for generic case of data (all checkboxes unchecked). Should work now. 
//1.50 fixes case when stale FOlder string was returned when user chanegd too fast from USAXS to QRSS type. Fixed case when R_Int was showing as QRS data. 
//1.49 fixed IR2P_CheckForRightQRSTripletWvs to work also for QRS names, not only qrs... 
//1.48 Modifed IR2P_CheckForRightQRSTripletWvs for QRS to use GrepList, seems cleaner and more obviosu. Also, fixes worng includions of DSM waves in QRS. 
//1.47 speed up popup string generation by at least 50%, increased the time for use of cached values to 10 seconds. 
//1.46 Added to Listbox procedure IR3C_ListBoxProc rigth click for Match Blank and Match EMpty. 
//1.45 try to catch bug which pops debugger when panel is being killed. 
//1.44 Added right alignemnet of data path string to show end of the string if it is too long. 
//1.43 Added Listbox for external files programmed similarly to allow easy addition of input directluy from files. Need for multipel tools in the future.
//			Function IR3C_AddDataControls(PckgPathName, PckgDataFolder, PanelWindowName,DefaultExtensionStr, DefaultMatchStr,DefaultSortString)
//1.42 removed PreparematchString - as fighting with regular expressions used by Regex. Added //IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
//1.41 fixed problem when checkbox Use SMR data screwed up the control procedures and put them in non-working condition. Accidentally called old code. 
//1.40 added to IR2P_CleanUpPackagesFolder to remove als any data in root:raw: folder. Not sure if this is OK, but they are there annoying. 
//1.39 fixed qis data selection bug. Further fixes to Irena results handling. 
//1.38 fixed bug which added require errors to qrs data when changed form USAXS data and fixed RegularExpression bug which increased qrs folder search time. 
//1.37 yet another bug - this time on "any" name type, when the Wv string was not matching the folders. 
//1.36 fixed another bug in qrs data structure handling. 
//1.35 fixed weird problem when after change from USAXS to qrs data set, first time user got wrong set of data when same folder contained both USAXS and qrs data.
//1.34 enabled use of following characters in Wavenames: (){}%#^$?|&@, Fixed time cashing problem which caused folder match string to be "retained" for 5 seconds. 
//		minor change in GUI locations. 
//1.33 IR2C_PanelPopupControl changed to handle cases when multiple pairs/triplets of waves reside in the same folder. 
//1.32 modifed IR2C_PanelPopupControl to handle folders with same names in differnet folders. Prior version picked the first one ONLY. `
//1.31 fix for Irena results which caused loss of _GenerationNumber sometimes. 
//1.30 Data manipulation I, fixed Flrd match for Test data folder...
//1.29 hopefully fixed problem, when parent folder appeared, when subfolders were masked off by Wv grep string  
//1.28 modifed and changed handling of Results wave names, mainly Y wave name. It is a mess - need to check this in details... 
//1.27 added Diameters waves for Modeling
//1.26 work around user names for folder with [] in the name. 
//1.25 changed "Indra 2" to "USAXS" to make bit more sense for human beings. 
//1.24 added Guinier-Porod data type
//1.23 fixed user defined data types of QIS type (with type at the end
//1.22 fixed FOlder popup to show only last folder name and indicate which subfolder the data came from. 
//1.21 changed Popups shape and size to use bodyWidth, may be it will be bit more user friendly and tidy. 
//1.20 Added ability to handle twr, drs and mrs data sets produced by Nika - considered for now as qrs data. Removed RegEx from the string fields for matchstrings. All Irena is now RegEx, so this is not necessary.
//1.19 added errors for Size distribution from Sizes to support updated version which can generate errors, fixed IR2P_ListOfWaves to handle the errors... 
//         added also SLDProfileX_ to Reflectivity results as requested feature. 
//1.18 major speed improvement, added caching to speed things up, cached IR2P_GenStringOfFolders to use old folder list, if it was created/used within last 5 secods, major speed improvement
//1.17 minor speed improvements
//1.16 minor changes in GUI placement
//1.15 tried to speed up the qrs data serch, speed increased by factor of 10 or so. 
//1.14 fixed problems with user defined wave pairs and with qrs data structure. Hopefully fixed problems with QIS data structure.
//1.13 added azimuthal data to qrs
//1.12 added display of separate polulations data from Modeling.
//1.11 fixed bug which prevented any folders be displayed when no checbox was selected and no match string was used
//1.10 optimization for speed. Just too slow to get anythign done in some major user experiments...  changed following functions:
//1.09 added license for ANL
//version 1.08 - added Unified size distribution and changed global string to help with upgrades. Now the list of known results is updated every time the cod eis run. 
//version 1.07 fixes minor bug for Model input, when the Qs werento recalculated when log-Q choice wa changed. 
//version 1.06 fixes the NIST qis naming structure 3/8/2008. Only q, int, and error are used, resolution wave is nto used at this time. 
//version 1.05 adds capability to be used on child (or sub) panels and graphs. Keep names short, so the total length is below 28 characters (of both HOST and CHILD together)
//version 1.04 adds to "qrs" also "qis" - NIST intended naming structure as of 11/2007 




//Three different controls supported:

 
//1.	Multi data controls...	Adds multiple data folders selection for WAXS and otehr panel types, where one needs to pick many data setds at once... 
//	Function IR3C_MultiAppendControls(ToolPackageFolder,PanelName, DoubleClickFunNm)
//		string PanelName,ToolPackageFolder,DoubleClickFunNm
	//this will append controls to panels, which require set of control for multi sample selection	
	//	NewPanel /K=1 /W=(5.25,43.25,605,820) as "MultiData plottingg tool"
	//initialize controls first by running this command
	//IR2C_AddDataControls("Irena:MultiSaPlotFit","IR3L_MultiSaPlotFitPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	//then call this function:
	// Function IR3C_MultiAppendControls(ToolPackageFolder,PanelName, DoubleClickFunNm)
	//, it will add listbox and other controls. 
	//   DoubleClickFUnction name is stored with other control info and when called, this happens:
	//				Execute(DoubleClickFunctionName+"("+FoldernameStr+")")
	//this is how the double click action suppose to look:
	//Function IR3L_DoubleClickAction(FoldernameStr)
	//		string FoldernameStr
	//		IR3C_SelectWaveNamesData("Irena:MultiSaPlotFit", FolderNameStr)			//this routine will preset names in strings as needed, so later code know what X, Y, and Z is!!!!
	//	Important note, this double click routine must use the above function before other functionality so the code defines what X, Y, and E is. Else, everything else will break... 

//2.   External files picker....   there is listbox support to select external files :
//	Function IR3C_AddDataControls(PckgPathName, PckgDataFolder, PanelWindowName,DefaultExtensionStr, DefaultMatchStr,DefaultSortString, DoubleCLickFnctName)


//3.   Single data set at a time (oldest) for most Irena panels:
//	IR2C_AddDataControls("testpackage2","TestPanel2","DSM_Int;M_DSM_Int;R_Int;SMR_Int;M_SMR_Int;","SizesFitIntensity;SizesVolumeDistribution;SizesNumberDistribution;",UserDataTypes,UserNameString,XUserLookup,EUserLookup, RequireErrorWaves, AllowModelData)

//Adds controls to select data to panels 
//How to:
//	Following are parameters
//		PckgDataFolder 		-	data folder where strings with folder and Q/Int/Error wave names will be created. Also place for variables use IN2, QRS, Resutls, User...  Will be created if necessary. 
//		PanelWindowName	- 	in which panel to create the controls. Neede for lookup tables
//		AllowedIrenaTypes	-	which of the Indra2 data types are allowed. Note, order is the order in which these will be listed (if they exist) and first existing will be preselected. 
//		AllowedResultsTypes	-	list of Irena allowed results types. For example "SizesNumberDistribution;SizesVolumeDistribution;" etc. There should be list of all existing results in this package. If "", this scontrol will not show. Same about order as above (I hope).
		//NOTE - if set to "AllCurrentlyAllowedTypes" all currently known results types will be used... 

//		AllowedUserTypes	- 	list of user defined types of data. For now can handle either Nika type - where unique names are known ("DSM_Int;SMR_Int;...") or qrs type which can include * for common part of name - at this time ONLY at the end.
//								So, at this time you can use "r*;" to get qrs data and see below for other information needed.					
//		UserNameString		- 	string which will be displayed on panel as name at the chekcbox. Make it SHORT!!!!
//		XUserTypeLookup	- 	Lookup table, which returns for each AllowedUserTypes item one prescription for x axis data.
//								Examples: "DSM_Int:DSM_Qvec;r*:q*;" etc.   NOTE: use ":" between keyword and value and ";" between items in this table. Necessary!!!!
//								Important note: this library can be as large as needed, but ONLY ONE PER EXPERIMENT. It is common for all panels. But, not every panel needs to use all of the known types in this table. 
//								Every package can add to this common library - the unknown typers will be added... But note, that if you redefine relationship, it is redefined for WHOLE EXPERIMENT. Seems only sensible way  to make this. 		
//		EUserTypeLookup	- 	Same as above but for errors.
//		RequireErrorWaves	- 	0 if data without errors are allowed, 1 if errors are required. Can be different for each panel. 
//		AllowModelData		- 	adds option to allow generation of model Q data and provides these data to the other packages
//	
// example which creates test panel:
//Window TestPanel2() : Panel
//	PauseUpdate    		// building window...
//	NewPanel /K=1 /W=(2.25,43.25,390,690) as "Test"
//Uncomment either Example 1 or Example 2 
//Example 1 - User data of Irena type, in this case the names are fully specified with no * in the name.
//	string UserDataTypes="DSM_Int;SMR_Int;"
//	string UserNameString="Test me"
//	string XUserLookup="DSM_Int:DSM_Qvec;SMR_Int:SMR_Qvec;"
//	string EUserLookup="DSM_Int:DSM_Error;SMR_Int:SMR_Error;"
//Example 2 - qrs data type. In thi scase the names are partically specified,. NOTE: The * repalces SAME string in the name, so in this case the names must have same ending as QRS names have. 
//	string UserDataTypes="r_*;"
//	string UserNameString="Test me"
//	string XUserLookup="r_*:q_*;"
//	string EUserLookup="r_*:s_*;"
//	variable RequireErrorWaves =0
//	variable AllowModelData = 0
//and this creates the controls. 
//end

//modifications:
///	Important: There are 4 hook functions, run after folder, Q, intensity, and error data are selected, names must be exactly: 
//	IR2_ContrProc_F_Hook_Proc(), IR2_ContrProc_Q_Hook_Proc(), IR2_ContrProc_R_Hook_Proc(), and IR2_ContrProc_E_Hook_Proc(). 
//	User needs to make sure these can be called with no parameters and that they will not fail if called by different panel!!! 
//	This is important, as they will be called from any panel whic is using this package, so they have to be prrof to that. 
//	I suggest checcking on the name of top active panel window or the current folder...  Example of function is below: 
//Function IR2_ContrProc_Q_Hook_Proc()
//	print getDataFolder(0)
//end

//Input listbox for external file selection, added in version 1.44
//Function IR3C_AddDataControls(PckgPathName, PckgDataFolder, PanelWindowName,DefaultExtensionStr, DefaultMatchStr,DefaultSortString, DoubleCLickFnctName)
//			Call this with :
//			PckgPathName - name of Igor Path which will be created (or used) to point to these files
//			PckgDataFolder - name of package folder name (inside root:Packages:) should be possible to have this in subfolder
//			PanelWindowName  - name of panel to attach these controls to
//			DefaultExtensionStr, DefaultMatchStr,DefaultSortString  - 	default values. Can be left empty if needed. Default Sort if alphabetical. 
//			DoubleCLickFnctName -  string name of function which shoudl be called on double click. Thsi function cannot have any parameters. If "" nothign will happen on double click. 


//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR2C_AddDataControls(PckgDataFolder,PanelWindowName,AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup, RequireErrorWaves,AllowModelData,[DoNotAddControls])
	string PckgDataFolder,PanelWindowName, AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup
	variable RequireErrorWaves, AllowModelData, DoNotAddControls
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable DontAdd =0 
	if(!ParamIsDefault(DoNotAddControls))
		DontAdd = DoNotAddControls
	endif
	if(!DontAdd)
		if(stringmatch(PanelWindowName, "*#*" ))	//# so expect subwindow... Limit only to first child here, else is not allowed for now...
			//first check for the main window existance...
			string MainPnlWinName=StringFromList(0, PanelWindowName , "#")
			string ChildPnlWinName=StringFromList(1, PanelWindowName , "#")
					//check on existence here...
				DoWindow $(MainPnlWinName)
				if(!V_Flag)
					abort //widnow does not exist, nothing to do...
				endif
				//OK, window exists, now check if it has the other in the childlist
				if(!stringmatch(ChildWindowList(MainPnlWinName), "*"+ChildPnlWinName+"*" ))
					abort //that child does nto exist!
				endif
				
		else		//no # no subvwindow. Use old code...
			DoWindow $(PanelWindowName)
			if(!V_Flag)
				abort //widnow does not exist, nothing to do...
			endif
		endif
	endif
	IR2C_InitControls(PckgDataFolder,PanelWindowName,AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup, RequireErrorWaves,AllowModelData)
	
	//This is fix to simplify coding all results
	SVAR AllCurrentlyAllowedTypes=root:Packages:IrenaControlProcs:AllCurrentlyAllowedTypes
	if(cmpstr(AllowedResultsTypes,"AllCurrentlyAllowedTypes")==0)
		AllowedResultsTypes=AllCurrentlyAllowedTypes
	endif

	if(!DontAdd)
		IR2C_AddControlsToWndw(PckgDataFolder,PanelWindowName,AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup, RequireErrorWaves,AllowModelData)
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR2C_InitControls(PckgDataFolder,PanelWindowName,AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup, RequireErrorWaves,AllowModelData)
	string PckgDataFolder,PanelWindowName, AllowedIrenaTypes, AllowedResultsTypes,AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup
	variable RequireErrorWaves,AllowModelData
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()

	setdatafolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S IrenaControlProcs

	SVAR/Z AllCurrentlyAllowedTypes
//	if(!SVAR_Exists(AllCurrentlyAllowedTypes))
	string/g AllCurrentlyAllowedTypes
//	endif
	//List of all types currently existing: 
	AllCurrentlyAllowedTypes = "SizesFitIntensity;SizesVolumeDistribution;SizesNumberDistribution;UnifiedFitIntensity;"
	AllCurrentlyAllowedTypes+="IntensityModelLSQF2;NumberDistModelLSQF2;VolumeDistModelLSQF2;"
	AllCurrentlyAllowedTypes+="IntensityModelLSQF2pop0;IntensityModelLSQF2pop1;NumberDistModelLSQF2pop1;VolumeDistModelLSQF2pop1;"
	AllCurrentlyAllowedTypes+="IntensityModelLSQF2pop2;NumberDistModelLSQF2pop2;VolumeDistModelLSQF2pop2;"
	AllCurrentlyAllowedTypes+="IntensityModelLSQF2pop3;NumberDistModelLSQF2pop3;VolumeDistModelLSQF2pop3;"
	AllCurrentlyAllowedTypes+="IntensityModelLSQF2pop4;NumberDistModelLSQF2pop4;VolumeDistModelLSQF2pop4;"
	AllCurrentlyAllowedTypes+="IntensityModelLSQF2pop5;NumberDistModelLSQF2pop5;VolumeDistModelLSQF2pop5;"
	AllCurrentlyAllowedTypes+="IntensityModelLSQF2pop6;NumberDistModelLSQF2pop6;VolumeDistModelLSQF2pop6;"
	AllCurrentlyAllowedTypes+= "ReflModel;SLDProfile;"
	AllCurrentlyAllowedTypes+="ModelingNumberDistribution;ModelingVolumeDistribution;ModelingIntensity;FractFitIntensity;DebyeBuecheModelInt;AnalyticalModelInt;SysSpecModelInt;"
	AllCurrentlyAllowedTypes+="ModelingNumDist_Pop1;ModelingVolDist_Pop1;Mass1FractFitInt;Surf1FractFitInt;UniLocalLevel1Unified;UniLocalLevel1Pwrlaw;UniLocalLevel1Guinier;"
	AllCurrentlyAllowedTypes+="ModelingNumDist_Pop2;ModelingVolDist_Pop2;Mass2FractFitInt;Surf2FractFitInt;UniLocalLevel2Unified;UniLocalLevel2Pwrlaw;UniLocalLevel2Guinier;"
	AllCurrentlyAllowedTypes+="ModelingNumDist_Pop3;ModelingVolDist_Pop3;Mass3FractFitInt;Surf3FractFitInt;UniLocalLevel3Unified;UniLocalLevel3Pwrlaw;UniLocalLevel3Guinier;"
	AllCurrentlyAllowedTypes+="ModelingNumDist_Pop4;ModelingVolDist_Pop4;Mass4FractFitInt;Surf4FractFitInt;UniLocalLevel4Unified;UniLocalLevel4Pwrlaw;UniLocalLevel4Guinier;"
	AllCurrentlyAllowedTypes+="ModelingNumDist_Pop5;ModelingVolDist_Pop5;Mass5FractFitInt;Surf5FractFitInt;UniLocalLevel5Unified;UniLocalLevel5Pwrlaw;UniLocalLevel5Guinier;"
	AllCurrentlyAllowedTypes+="CumulativeSizeDist;CumulativeSfcArea;MIPVolume;SADModelIntensity;SADModelIntPeak1;SADModelIntPeak2;SADModelIntPeak3;"
	AllCurrentlyAllowedTypes+="SADModelIntPeak4;SADModelIntPeak5;SADModelIntPeak6;"
	AllCurrentlyAllowedTypes+="PDDFIntensity;PDDFDistFunction;PDDFChiSquared;SADUnifiedIntensity;PDDFGammaFunction;"
	AllCurrentlyAllowedTypes+="UnifSizeDistVolumeDist;UnifSizeDistNumberDist;"
	AllCurrentlyAllowedTypes+="UniLocalLevel0Unified;UniLocalLevel1Unified;UniLocalLevel1Pwrlaw;UniLocalLevel1Guinier;"
	AllCurrentlyAllowedTypes+="UniLocalLevel2Unified;UniLocalLevel2Pwrlaw;UniLocalLevel2Guinier;"
	AllCurrentlyAllowedTypes+="UniLocalLevel3Unified;UniLocalLevel3Pwrlaw;UniLocalLevel3Guinier;"
	AllCurrentlyAllowedTypes+="UniLocalLevel4Unified;UniLocalLevel4Pwrlaw;UniLocalLevel4Guinier;"
	AllCurrentlyAllowedTypes+="UniLocalLevel5Unified;UniLocalLevel5Pwrlaw;UniLocalLevel5Guinier;"
	AllCurrentlyAllowedTypes+="GuinierPorodFitIntensity;GuinierPorodIntLevel0;GuinierPorodIntLevel1;GuinierPorodIntLevel2;GuinierPorodIntLevel3;GuinierPorodIntLevel4;GuinierPorodIntLevel5;"
	//Simple fits
	AllCurrentlyAllowedTypes+="SimFitGuinierI;SimFitGuinierRI;SimFitGuinierSII;SimFitSphereI;SimFitSpheroidI;SimFitPorodI;Corr1DK;Corr1DGammaA;Corr1DGammaI;"
	AllCurrentlyAllowedTypes+="SimFitPwrLawI;"

	string/g AllKnownToolsResults
	AllKnownToolsResults = "Unified Fit;Size Distribution;Modeling;Small-angle diffraction;Analytical models;Fractals;PDDF;Reflectivity;Guinier-Porod;Simple Fits;Evaluate Size Dist;System Specific Models;"

	if(cmpstr(AllowedResultsTypes,"AllCurrentlyAllowedTypes")==0)
		AllowedResultsTypes=AllCurrentlyAllowedTypes
	endif

	variable i
	
	SVAR/Z ControlProcsLocations
	if(!SVAR_Exists(ControlProcsLocations))
		string/g ControlProcsLocations
	endif
	ControlProcsLocations=ReplaceStringByKey(PanelWindowName, ControlProcsLocations, PckgDataFolder,":",";" )

	SVAR/Z ControlAllowedIrenaTypes
	if(!SVAR_Exists(ControlAllowedIrenaTypes))
		string/g ControlAllowedIrenaTypes
	endif
	ControlAllowedIrenaTypes=ReplaceStringByKey(PanelWindowName, ControlAllowedIrenaTypes, AllowedIrenaTypes, "=",">" )

	SVAR/Z ControlAllowedUserTypes
	if(!SVAR_Exists(ControlAllowedUserTypes))
		string/g ControlAllowedUserTypes
	endif
	ControlAllowedUserTypes=ReplaceStringByKey(PanelWindowName, ControlAllowedUserTypes, AllowedUserTypes, "=",">" )

	SVAR/Z ControlAllowedResultsTypes
	if(!SVAR_Exists(ControlAllowedResultsTypes))
		string/g ControlAllowedResultsTypes
	endif
	ControlAllowedResultsTypes=ReplaceStringByKey(PanelWindowName, ControlAllowedResultsTypes, AllowedResultsTypes, "=",">" )

	SVAR/Z ControlRequireErrorWvs
	if(!SVAR_Exists(ControlRequireErrorWvs))
		string/g ControlRequireErrorWvs
	endif
	ControlRequireErrorWvs=ReplaceStringByKey(PanelWindowName, ControlRequireErrorWvs, num2str(RequireErrorWaves) )
	//added 7/27/2006
	SVAR/Z ControlAllowModelData
	if(!SVAR_Exists(ControlAllowModelData))
		string/g ControlAllowModelData
	endif
	ControlAllowModelData=ReplaceStringByKey(PanelWindowName, ControlAllowModelData, num2str(AllowModelData) )
	//Added 12/18/2010, match string for Folder string and waveNameString
//	string tempstr=StrVarOrDefault("root:Packages:IrenaControlProcs:FolderMatchStr", "" )
	SVAR/Z FolderMatchStr
	if(!SVAR_Exists(FolderMatchStr))
		string/g FolderMatchStr
	endif
	string tempstr=StringByKey(PanelWindowName, FolderMatchStr,"=",";")
	FolderMatchStr=ReplaceStringByKey(PanelWindowName, FolderMatchStr, tempstr, "=",";" )

	SVAR/Z WaveMatchStr
	if(!SVAR_Exists(WaveMatchStr))
		string/g WaveMatchStr
	endif
	tempstr=StringByKey(PanelWindowName, WaveMatchStr,"=",";")
	WaveMatchStr=ReplaceStringByKey(PanelWindowName, WaveMatchStr, tempstr, "=",";" )
	
	//I suspect I'll need to be able to remeber which fields have displayed... 
//	SVAR/Z ControlError
//	if(!SVAR_Exists(ControlAllowModelData))
//		string/g ControlAllowModelData
//	endif
//	ControlAllowModelData=ReplaceStringByKey(PanelWindowName, ControlAllowModelData, num2str(AllowModelData) )

	SVAR/Z XwaveUserDataTypesLookup
	if(!SVAR_Exists(XwaveUserDataTypesLookup))
		string/g XwaveUserDataTypesLookup
	endif
	For(i=0;i<ItemsInList(XUserTypeLookup,";");i+=1)
		XwaveUserDataTypesLookup = ReplaceStringByKey(StringFromList(0,StringFromList(i,XUserTypeLookup,";"),":"), XwaveUserDataTypesLookup, StringFromList(1,StringFromList(i,XUserTypeLookup,";"),":")  , ":" , ";")
	endfor

	SVAR/Z EwaveUserDataTypesLookup
	if(!SVAR_Exists(EwaveUserDataTypesLookup))
		string/g EwaveUserDataTypesLookup
	endif
	For(i=0;i<ItemsInList(EUserTypeLookup,";");i+=1)
		EwaveUserDataTypesLookup = ReplaceStringByKey(StringFromList(0,StringFromList(i,EUserTypeLookup,";"),":"), EwaveUserDataTypesLookup, StringFromList(1,StringFromList(i,EUserTypeLookup,";"),":")  , ":" , ";")
	endfor


	SVAR/Z XwaveDataTypesLookup
	if(!SVAR_Exists(XwaveDataTypesLookup))
		string/g XwaveDataTypesLookup
	endif
	XwaveDataTypesLookup="DSM_Int:DSM_Qvec;"
	XwaveDataTypesLookup+="M_DSM_Int:M_DSM_Qvec;"
	XwaveDataTypesLookup+="BCK_Int:BCK_Qvec;"
	XwaveDataTypesLookup+="M_BCK_Int:M_BCK_Qvec;"
	XwaveDataTypesLookup+="SMR_Int:SMR_Qvec;"
	XwaveDataTypesLookup+="M_SMR_Int:M_SMR_Qvec;"
	XwaveDataTypesLookup+="R_Int:R_Qvec;"
//	XwaveDataTypesLookup+="r*:q*;"
//	XwaveDataTypesLookup+="DSM_Int:DSM_Qvec;"
	
	SVAR/Z EwaveDataTypesLookup
	if(!SVAR_Exists(EwaveDataTypesLookup))
		string/g EwaveDataTypesLookup
	endif
	EwaveDataTypesLookup="DSM_Int:DSM_Error;"
	EwaveDataTypesLookup+="M_DSM_Int:M_DSM_Error;"
	EwaveDataTypesLookup+="BCK_Int:BCK_Error;"
	EwaveDataTypesLookup+="M_BCK_Int:M_BCK_Error;"
	EwaveDataTypesLookup+="SMR_Int:SMR_Error;"
	EwaveDataTypesLookup+="M_SMR_Int:M_SMR_Error;"
	EwaveDataTypesLookup+="R_Int:R_Error;"
//	EwaveDataTypesLookup+="r*:s*;"
	

	SVAR/Z ResultsEDataTypesLookup
	if(!SVAR_Exists(ResultsEDataTypesLookup))
		string/g ResultsEDataTypesLookup
	endif
	ResultsEDataTypesLookup="PDDFDistFunction:PDDFErrors;"		//PDDF has error estimates for the result... 
	ResultsEDataTypesLookup+="SizesVolumeDistribution:SizesVolumeDistErrors;"		//Sizes now have errors also 
	ResultsEDataTypesLookup+="SizesNumberDistribution:SizesNumberDistErrors;"		//Sizes now have errors also 
	
	SVAR/Z ResultsDataTypesLookup
	if(!SVAR_Exists(ResultsDataTypesLookup))
		string/g ResultsDataTypesLookup
	endif
	//sizes
	ResultsDataTypesLookup="SizesFitIntensity:SizesFitQvector;"
	ResultsDataTypesLookup+="SizesVolumeDistribution:SizesDistDiameter;"
	ResultsDataTypesLookup+="SizesNumberDistribution:SizesDistDiameter;"
	//unified
	ResultsDataTypesLookup+="UnifiedFitIntensity:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UnifSizeDistVolumeDist:UnifSizeDistRadius;"
	ResultsDataTypesLookup+="UnifSizeDistNumberDist:UnifSizeDistRadius;"
	ResultsDataTypesLookup+="UniLocalLevel0Unified:UnifiedFitQvector;"			//this is flat background
	ResultsDataTypesLookup+="UniLocalLevel1Unified:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel1Pwrlaw:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel1Guinier:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel2Unified:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel2Pwrlaw:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel2Guinier:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel3Unified:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel3Pwrlaw:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel3Guinier:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel4Unified:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel4Pwrlaw:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel4Guinier:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel5Unified:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel5Pwrlaw:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel5Guinier:UnifiedFitQvector;"
	
	//LSQF
	ResultsDataTypesLookup+="ModelingNumberDistribution:ModelingDiameters;"
	ResultsDataTypesLookup+="ModelingVolumeDistribution:ModelingDiameters;"
	ResultsDataTypesLookup+="ModelingIntensity:ModelingQvector;"
	ResultsDataTypesLookup+="ModelingNumDist_Pop1:ModelingDia_Pop1;"
	ResultsDataTypesLookup+="ModelingVolDist_Pop1:ModelingDia_Pop1;"
	ResultsDataTypesLookup+="ModelingNumDist_Pop2:ModelingDia_Pop2;"
	ResultsDataTypesLookup+="ModelingVolDist_Pop2:ModelingDia_Pop2;"
	ResultsDataTypesLookup+="ModelingNumDist_Pop3:ModelingDia_Pop3;"
	ResultsDataTypesLookup+="ModelingVolDist_Pop3:ModelingDia_Pop3;"
	ResultsDataTypesLookup+="ModelingNumDist_Pop4:ModelingDia_Pop4;"
	ResultsDataTypesLookup+="ModelingVolDist_Pop4:ModelingDia_Pop4;"
	ResultsDataTypesLookup+="ModelingNumDist_Pop5:ModelingDia_Pop5;"
	ResultsDataTypesLookup+="ModelingVolDist_Pop5:ModelingDia_Pop5;"
	//Fractals
	ResultsDataTypesLookup+="FractFitIntensity:FractFitQvector;"
	ResultsDataTypesLookup+="Mass1FractFitInt:Mass1FractFitQvec;"
	ResultsDataTypesLookup+="Surf1FractFitInt:Surf1FractFitQvec;"
	ResultsDataTypesLookup+="Mass2FractFitInt:Mass2FractFitQvec;"
	ResultsDataTypesLookup+="Surf2FractFitInt:Surf2FractFitQvec;"
	ResultsDataTypesLookup+="Mass3FractFitInt:Mass3FractFitQvec;"
	ResultsDataTypesLookup+="Surf3FractFitInt:Surf3FractFitQvec;"
	ResultsDataTypesLookup+="Mass4FractFitInt:Mass4FractFitQvec;"
	ResultsDataTypesLookup+="Surf4FractFitInt:Surf4FractFitQvec;"
	ResultsDataTypesLookup+="Mass5FractFitInt:Mass5FractFitQvec;"
	ResultsDataTypesLookup+="Surf5FractFitInt:Surf5FractFitQvec;"
	//Small-angle diffraction
	ResultsDataTypesLookup+="SADModelIntensity:SADModelQ;"
	ResultsDataTypesLookup+="SADModelIntPeak1:SADModelQPeak1;"
	ResultsDataTypesLookup+="SADModelIntPeak2:SADModelQPeak2;"
	ResultsDataTypesLookup+="SADModelIntPeak3:SADModelQPeak3;"
	ResultsDataTypesLookup+="SADModelIntPeak4:SADModelQPeak4;"
	ResultsDataTypesLookup+="SADModelIntPeak5:SADModelQPeak5;"
	ResultsDataTypesLookup+="SADModelIntPeak6:SADModelQPeak6;"
	ResultsDataTypesLookup+="SADUnifiedIntensity:SADUnifiedQvector;"
	//Gels
	ResultsDataTypesLookup+="DebyeBuecheModelInt:DebyeBuecheModelQvec;"//old, now next line...
	ResultsDataTypesLookup+="AnalyticalModelInt:SysSpecModelQvec;"
	//System Sepcific Models (repalce Gels)
	ResultsDataTypesLookup+="SysSpecModelInt:SysSpecModelQvec;"
	//Reflecitivty
	ResultsDataTypesLookup+="ReflModel:ReflQ;"
	ResultsDataTypesLookup+="SLDProfile:SLDProfileX;SLDProfile:x-scaling;"
	//PDDF
	ResultsDataTypesLookup+="PDDFIntensity:PDDFQvector;"
	ResultsDataTypesLookup+="PDDFChiSquared:PDDFQvector;"
	ResultsDataTypesLookup+="PDDFDistFunction:PDDFDistances;"
	ResultsDataTypesLookup+="PDDFGammaFunction:PDDFDistances;"
	//Guinier-Porod
	ResultsDataTypesLookup+="GuinierPorodFitIntensity:GuinierPorodFitQvector;"
	ResultsDataTypesLookup+="GuinierPorodIntLevel0:GuinierPorodQvecLevel0;"		//this is flat background
	ResultsDataTypesLookup+="GuinierPorodIntLevel1:GuinierPorodQvecLevel1;"
	ResultsDataTypesLookup+="GuinierPorodIntLevel2:GuinierPorodQvecLevel2;"
	ResultsDataTypesLookup+="GuinierPorodIntLevel3:GuinierPorodQvecLevel3;"
	ResultsDataTypesLookup+="GuinierPorodIntLevel4:GuinierPorodQvecLevel4;"
	ResultsDataTypesLookup+="GuinierPorodIntLevel5:GuinierPorodQvecLevel5;"
	
	
	//NLQSF2
	ResultsDataTypesLookup+="IntensityModelLSQF2:QvectorModelLSQF2;"
	ResultsDataTypesLookup+="IntensityModelLSQF2pop0:QvectorModelLSQF2pop0;"		//this is flat background
	ResultsDataTypesLookup+="IntensityModelLSQF2pop1:QvectorModelLSQF2pop1;"
	ResultsDataTypesLookup+="IntensityModelLSQF2pop2:QvectorModelLSQF2pop2;"
	ResultsDataTypesLookup+="IntensityModelLSQF2pop3:QvectorModelLSQF2pop3;"
	ResultsDataTypesLookup+="IntensityModelLSQF2pop5:QvectorModelLSQF2pop5;"
	ResultsDataTypesLookup+="IntensityModelLSQF2pop4:QvectorModelLSQF2pop4;"
	ResultsDataTypesLookup+="IntensityModelLSQF2pop6:QvectorModelLSQF2pop6;"

		ResultsDataTypesLookup+="VolumeDistModelLSQF2:RadiiModelLSQF2,DiametersModelLSQF2;"
		ResultsDataTypesLookup+="NumberDistModelLSQF2:RadiiModelLSQF2,DiametersModelLSQF2;"
		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop1:RadiiModelLSQF2pop1,DiametersModelLSQF2pop1;"
		ResultsDataTypesLookup+="NumberDistModelLSQF2pop1:RadiiModelLSQF2pop1,DiametersModelLSQF2pop1;"
		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop2:RadiiModelLSQF2pop2,DiametersModelLSQF2pop2;"
		ResultsDataTypesLookup+="NumberDistModelLSQF2pop2:RadiiModelLSQF2pop2,DiametersModelLSQF2pop2;"
		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop3:RadiiModelLSQF2pop3,DiametersModelLSQF2pop3;"
		ResultsDataTypesLookup+="NumberDistModelLSQF2pop3:RadiiModelLSQF2pop3,DiametersModelLSQF2pop3;"
		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop4:RadiiModelLSQF2pop4,DiametersModelLSQF2pop4;"
		ResultsDataTypesLookup+="NumberDistModelLSQF2pop4:RadiiModelLSQF2pop4,DiametersModelLSQF2pop4;"
		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop5:RadiiModelLSQF2pop5,DiametersModelLSQF2pop5;"
		ResultsDataTypesLookup+="NumberDistModelLSQF2pop5:RadiiModelLSQF2pop5,DiametersModelLSQF2pop5;"
		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop6:RadiiModelLSQF2pop6,DiametersModelLSQF2pop6;"
		ResultsDataTypesLookup+="NumberDistModelLSQF2pop6:RadiiModelLSQF2pop6,DiametersModelLSQF2pop6;"

	//CumulativeSizeDist Curve from Evaluate Size dist
	ResultsDataTypesLookup+="CumulativeSizeDist:CumulativeDistDiameters;"
	ResultsDataTypesLookup+="CumulativeSfcArea:CumulativeDistDiameters;"
	ResultsDataTypesLookup+="MIPVolume:MIPPressure;"

	//SimpleFits
	ResultsDataTypesLookup+="SimFitGuinierI:SimFitGuinierQ;"
	ResultsDataTypesLookup+="SimFitGuinierRI:SimFitGuinierRQ;"
	ResultsDataTypesLookup+="SimFitGuinierSII:SimFitGuinierSQ;"
	ResultsDataTypesLookup+="SimFitSphereI:SimFitSphereQ;"
	ResultsDataTypesLookup+="SimFitSpheroidI:SimFitSpheroidQ;"
	ResultsDataTypesLookup+="SimFitPorodI:SimFitPorodQ;"
	ResultsDataTypesLookup+="SimFitPwrLawI:SimFitPwrLawQ;"
	ResultsDataTypesLookup+="Corr1DK:Corr1DZ;"
	ResultsDataTypesLookup+="Corr1DGammaA:Corr1DZ;"
	ResultsDataTypesLookup+="Corr1DGammaI:Corr1DZ;"


	string ListOfVariables
	string ListOfStrings

	//************************************************************
	//************************************************************
	//************************************************************
	//And now controls for Modeling - need to generate Q values...
	//ad subfolder with the name of the window
	//include string for FolderMatchStr and WaveMatchStr 
	NewDataFolder/O/S $(PanelWindowName)
	Variable/G Qmin,Qmax,QNumPoints,QLogScale
	if(Qmin<1e-20)
		Qmin=0.0001
	endif
	if(Qmax<1e-20)
		Qmax=1
	endif
	if(QNumPoints<2)
		QNumPoints=100
	endif
	ListOfStrings="tempXlist;tempYlist;tempElist;FolderMatchStr;WaveMatchStr;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	

	//************************************************************
	//************************************************************
	//************************************************************
	setDataFolder root:packages
	if(ItemsInList(PckgDataFolder , ":")>1)
		For(i=0;i<ItemsInList(PckgDataFolder , ":");i+=1)
			NewDataFolder/O/S $(StringFromList(i,PckgDataFolder,":"))
		endfor	
	else
		NewDataFolder/O/S $(PckgDataFolder)
	endif
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;UseSMRData;UseUserDefinedData;UseModelData;"

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	

	setDataFolder OldDf
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR2C_AddControlsToWndw(PckgDataFolder,PanelWindowName,AllowedIrenaTypes,AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup, RequireErrorWaves,AllowModelData)
	string PckgDataFolder,PanelWindowName, AllowedIrenaTypes,AllowedResultsTypes,AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup
	variable RequireErrorWaves,AllowModelData

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs

	string CntrlLocation="root:Packages:"+PckgDataFolder

	setDataFolder $(CntrlLocation)
	string TopPanel=PanelWindowName

//	//Experimental data input
	if(strlen(AllowedIrenaTypes)>0)
		CheckBox UseIndra2Data,pos={100,25},size={141,14},proc=IR2C_InputPanelCheckboxProc,title="USAXS"
		CheckBox UseIndra2Data,variable= $(CntrlLocation+":UseIndra2data"), help={"Check, if you are using USAXS - Indra 2 - produced data with the orginal names, uncheck if the names of data waves are different"}
	endif
	CheckBox UseQRSData,pos={100,40},size={90,14},proc=IR2C_InputPanelCheckboxProc,title="QRS (QIS)"
	CheckBox UseQRSData,variable= $(CntrlLocation+":UseQRSdata"), help={"Check, if you are using QRS or QIS names, uncheck if the names of data waves are different"}
	if(strlen(AllowedResultsTypes)>0)
		CheckBox UseResults,pos={200,25},size={90,14},proc=IR2C_InputPanelCheckboxProc,title="Irena results"
		CheckBox UseResults,variable= $(CntrlLocation+":UseResults"), help={"Check, if you want to use results of Irena macros"}
	endif
	if(strlen(AllowedUserTypes)>0)
		CheckBox UseUserDefinedData,pos={200,40},size={90,14},proc=IR2C_InputPanelCheckboxProc,title=UserNameString
		CheckBox UseUserDefinedData,variable= $(CntrlLocation+":UseUserDefinedData"), help={"Check, if you want to use "+UserNameString+" data"}
	endif
	if(AllowModelData>0)
		CheckBox UseModelData,pos={300,25},size={90,14},proc=IR2C_InputPanelCheckboxProc,title="Model"
		CheckBox UseModelData,variable= $(CntrlLocation+":UseModelData"), help={"Check, if you want to generate Q data for modeling"}
	endif

	SetVariable FolderMatchStr, pos={280,56},size={100,15},bodyWidth=60, proc=IR2C_NamesSetVarProc,title="Fldr :", help={"Regular Expression to match folder names"}
	SetVariable FolderMatchStr, variable=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(PanelWindowName)+":FolderMatchStr")
	SetVariable WaveMatchStr, pos={280,78},size={100,15},bodyWidth=60, proc=IR2C_NamesSetVarProc,title="Wv :", help={"Regular Expression to match wave names"}
	SetVariable WaveMatchStr, variable=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(PanelWindowName)+":WaveMatchStr")

	PopupMenu SelectDataFolder,pos={10,56},size={270,21},proc=IR2C_PanelPopupControl,title="Data fldr:", help={"Select folder with data"}, bodywidth=220
	execute("PopupMenu SelectDataFolder,mode=1,popvalue=\"---\",value= \"---;\"+IR2P_GenStringOfFolders(winNm=\""+TopPanel+"\")")
	//PopupMenu SelectDataFolder,mode=1,popvalue="---",value= ("---;"+IR2P_GenStringOfFolders(winNm=TopPanel))
	PopupMenu QvecDataName,pos={15,79},size={265,21},proc=IR2C_PanelPopupControl,title="Wave with X   ", help={"Select wave with data to be used on X axis (Q, diameters, etc)"}, bodywidth=200
	execute("PopupMenu QvecDataName,mode=1,popvalue=\"---\",value= \"---;\"+IR2P_ListOfWaves(\"Xaxis\",\"*\",\""+TopPanel+"\")")
	//PopupMenu QvecDataName,mode=1,popvalue="---",value=("---;"+IR2P_ListOfWaves("Xaxis","*",TopPanel))
	PopupMenu IntensityDataName,pos={15,102},size={265,21},proc=IR2C_PanelPopupControl,title="Wave with Y   ", help={"Select wave with data to be used on Y data (Intensity, distributions)"}, bodywidth=200
	execute("PopupMenu IntensityDataName,mode=1,popvalue=\"---\",value= \"---;\"+IR2P_ListOfWaves(\"Yaxis\",\"*\",\""+TopPanel+"\")")
	//PopupMenu IntensityDataName,mode=1,popvalue="---",value=("---;"+IR2P_ListOfWaves("Yaxis","*",TopPanel))
	PopupMenu ErrorDataName,pos={15,126},size={265,21},proc=IR2C_PanelPopupControl,title="Error Wave   ", help={"Select wave with error data"}, bodywidth=200
	execute("PopupMenu ErrorDataName,mode=1,popvalue=\"---\",value= \"---;\"+IR2P_ListOfWaves(\"Error\",\"*\",\""+TopPanel+"\")")
	//PopupMenu ErrorDataName,mode=1,popvalue="---",value= ("---;"+IR2P_ListOfWaves("Error","*",TopPanel))

	SetVariable Qmin, pos={8,60},size={220,20}, proc=IR2C_ModelQSetVarProc,title="Min value for Q [A]   ", help={"Value of Q min "}
	SetVariable Qmin, variable=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(PanelWindowName)+":Qmin"), limits={0,10,0}
	SetVariable Qmax, pos={8,85},size={220,20}, proc=IR2C_ModelQSetVarProc,title="Max value for Q [A]  ", help={"Value of Q max "}
	SetVariable Qmax, variable=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(PanelWindowName)+":Qmax"),limits={0,10,0}
	SetVariable QNumPoints, pos={8,110},size={220,20}, proc=IR2C_ModelQSetVarProc,title="Num points in Q        ", help={"Number of points in Q "}
	SetVariable QNumPoints, variable=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(PanelWindowName)+":QNumPoints"),limits={0,1e6,0}
	CheckBox QLogScale,pos={100,135},size={90,14},proc=IR2C_InputPanelCheckboxProc,title="Log-Q stepping?"
	CheckBox QLogScale,variable= $("root:Packages:IrenaControlProcs:"+possiblyQuoteName(PanelWindowName)+":QLogScale"), help={"Check, if you want to generate Q in log scale"}
	
	IR2C_FixDisplayedControls(TopPanel) 

	STRUCT WMSetVariableAction SV_Struct
	SV_Struct.ctrlName=""
	SV_Struct.dval=0
	SV_Struct.win=TopPanel
	SV_Struct.sVAL=""
	SV_Struct.vName=""
	SV_Struct.eventcode=2
	IR2C_ModelQSetVarProc(SV_Struct)
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


Function IR2C_NamesSetVarProc(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct

	if(SV_Struct.eventcode==1 || SV_Struct.eventcode==2)
		//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		string TopPanel
		TopPanel = SV_Struct.win
		SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
		string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
		NVAR/Z SetTimeOfIndraFoldersStr = $(CntrlLocation+":SetTimeOfIndraFoldersStr")
		NVAR/Z SetTimeOfQFoldersStr = $(CntrlLocation+":SetTimeOfQFoldersStr")
		NVAR/Z SetTimeOfResultsFoldersStr = $(CntrlLocation+":SetTimeOfResultsFoldersStr")
		NVAR/Z SetTimeOfUserDefFoldersStr = $(CntrlLocation+":SetTimeOfUserDefFoldersStr")
		if(NVAR_Exists(SetTimeOfIndraFoldersStr))
			SetTimeOfIndraFoldersStr=0
		endif
		if(NVAR_Exists(SetTimeOfQFoldersStr))
			SetTimeOfQFoldersStr=0
		endif
		if(NVAR_Exists(SetTimeOfResultsFoldersStr))
			SetTimeOfResultsFoldersStr=0
		endif
		if(NVAR_Exists(SetTimeOfUserDefFoldersStr))
			SetTimeOfUserDefFoldersStr=0
		endif
	endif
	if(SV_Struct.eventcode<1 || SV_Struct.eventcode>5)
		return 0
	endif

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


Function IR2C_ModelQSetVarProc(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct

	if(SV_Struct.eventcode<1 || SV_Struct.eventcode>5)
		return 0
	endif
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String ctrlName=SV_Struct.ctrlName
	Variable varNum=SV_Struct.dval
	String varStr=SV_Struct.sVal
	String varName=SV_Struct.vName

	DFref oldDf= GetDataFolderDFR()

	string TopPanel=SV_Struct.win
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	
	NVAR UseIndra2Data=$(CntrlLocation+":UseIndra2Data")
	NVAR UseQRSData=$(CntrlLocation+":UseQRSData")
	NVAR UseResults=$(CntrlLocation+":UseResults")
	NVAR UseUserDefinedData=$(CntrlLocation+":UseUserDefinedData")
	NVAR UseModelData=$(CntrlLocation+":UseModelData")

	SVAR Dtf=$(CntrlLocation+":DataFolderName")
	SVAR IntDf=$(CntrlLocation+":IntensityWaveName")
	SVAR QDf=$(CntrlLocation+":QWaveName")
	SVAR EDf=$(CntrlLocation+":ErrorWaveName")

	setDataFolder $("root:Packages:IrenaControlProcs:"+possiblyQuoteName(TopPanel))

	NVAR Qmin
	NVAR Qmax
	NVAR QNumPoints
	NVAR QLogScale
	
	Make/O/N=(QNumPoints) ModelQ, ModelInt, ModelError
	ModelInt = 1
	ModelError = 0
	if(QLogScale)	//log scale
		ModelQ = 10^(log(Qmin)+p*((log(Qmax)-log(Qmin))/(QNumPoints-1))) 
	else
		ModelQ = Qmin + p * (Qmax - Qmin)/(QNumPoints-1)
	endif

	Dtf = "root:Packages:IrenaControlProcs:"+possiblyQuoteName(TopPanel)+":"
	IntDf = "ModelInt"
	QDf = "ModelQ"
	EDf = "ModelError"
	
	setDataFolder OldDf

End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR2C_FixDisplayedControls(WnName) 
	string WnName

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()

	string TopPanel=WnName
	//GetWindow $(TopPanel), activeSW		//fix for subwindow controls... This will add teh subwidnow which is selected, I hope that means in which we operate!
	//TopPanel=S_value
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	setDataFolder $(CntrlLocation)
	
	NVAR UseIndra2Data=$(CntrlLocation+":UseIndra2Data")
	NVAR UseQRSData=$(CntrlLocation+":UseQRSData")
	NVAR UseResults=$(CntrlLocation+":UseResults")
	NVAR UseUserDefinedData=$(CntrlLocation+":UseUserDefinedData")
	NVAR UseModelData=$(CntrlLocation+":UseModelData")


	if (UseModelData)
		PopupMenu SelectDataFolder disable=1, win=$(TopPanel)
		PopupMenu IntensityDataName disable=1, win=$(TopPanel)
		PopupMenu QvecDataName disable=1, win=$(TopPanel)
		PopupMenu ErrorDataName disable=1, win=$(TopPanel)
		SetVariable Qmin, disable=0, win=$(TopPanel)
		SetVariable Qmax, disable=0, win=$(TopPanel)
		SetVariable QNumPoints, disable=0, win=$(TopPanel)
		CheckBox QLogScale,disable=0, win=$(TopPanel)
	
	else
		PopupMenu SelectDataFolder disable=0, win=$(TopPanel)
		PopupMenu IntensityDataName disable=0, win=$(TopPanel)
		PopupMenu QvecDataName disable=0, win=$(TopPanel)
		PopupMenu ErrorDataName disable=0, win=$(TopPanel)
		SetVariable Qmin, disable=1, win=$(TopPanel)
		SetVariable Qmax, disable=1, win=$(TopPanel)
		SetVariable QNumPoints, disable=1, win=$(TopPanel)
		CheckBox QLogScale,disable=1, win=$(TopPanel)
	endif
	
	
	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR2C_InputPanelCheckboxProc(CB_Struct)
	STRUCT WMCheckboxAction &CB_Struct

	if(CB_Struct.eventcode<1 ||CB_Struct.eventcode>2)
		return 0
	endif
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String ctrlName=CB_Struct.ctrlName
	Variable checked=CB_Struct.checked
	DFref oldDf= GetDataFolderDFR()

	string TopPanel=CB_Struct.win
	//string TopPanel=WinName(0,65)
	//GetWindow $(TopPanel), activeSW
	//TopPanel=S_value
	if(CB_Struct.eventcode!=2)
		return 0
	endif
	
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations,":",";")
	setDataFolder $(CntrlLocation)
	
	NVAR UseIndra2Data=$(CntrlLocation+":UseIndra2Data")
	NVAR UseQRSData=$(CntrlLocation+":UseQRSData")
	NVAR UseResults=$(CntrlLocation+":UseResults")
	NVAR UseUserDefinedData=$(CntrlLocation+":UseUserDefinedData")
	NVAR UseModelData=$(CntrlLocation+":UseModelData")

	NVAR/Z SetTimeOfQFoldersStr = $(CntrlLocation+":SetTimeOfQFoldersStr")
	NVAR/Z SetTimeOfIndraFoldersStr = $(CntrlLocation+":SetTimeOfIndraFoldersStr")
	NVAR/Z SetTimeOfResultsFoldersStr = $(CntrlLocation+":SetTimeOfResultsFoldersStr")

	Execute ("SetVariable WaveMatchStr disable=0, win="+TopPanel)
	Execute ("SetVariable FolderMatchStr disable=0, win="+TopPanel)

	if (cmpstr(ctrlName,"UseIndra2Data")==0)
		//here we control the data structure checkbox
		if (checked)
			UseQRSData=0
			UseResults=0
			UseUserDefinedData=0
			UseModelData=0
			SetTimeOfIndraFoldersStr = 0
			ControlRequireErrorWvs = ReplaceStringByKey(TopPanel, ControlRequireErrorWvs, "1"  , ":"  , ";")		//Indra 2 data do require errors, let user change that later, if needed.
			Execute ("SetVariable WaveMatchStr disable=1, win="+TopPanel)
		endif
	endif
	if (cmpstr(ctrlName,"UseQRSData")==0)
		//here we control the data structure checkbox
		if (checked)
			UseIndra2Data=0
			UseResults=0
			UseUserDefinedData=0
			UseModelData=0
			SetTimeOfQFoldersStr = 0
			ControlRequireErrorWvs = ReplaceStringByKey(TopPanel, ControlRequireErrorWvs, "0"  , ":"  , ";")		//no require errors, let user change that later, if needed.
		endif
	endif
	if (cmpstr(ctrlName,"UseResults")==0)
		//here we control the data structure checkbox
		if (checked)
			UseIndra2Data=0
			UseQRSData=0
			UseUserDefinedData=0
			UseModelData=0
			SetTimeOfResultsFoldersStr = 0
			ControlRequireErrorWvs = ReplaceStringByKey(TopPanel, ControlRequireErrorWvs, "0"  , ":"  , ";")		//no require errors, let user change that later, if needed.
			Execute ("SetVariable WaveMatchStr disable=1, win="+TopPanel)
		endif
	endif
	if (cmpstr(ctrlName,"UseUserDefinedData")==0)
		//here we control the data structure checkbox
		if (checked)
			UseIndra2Data=0
			UseQRSData=0
			UseResults=0
			ControlRequireErrorWvs = ReplaceStringByKey(TopPanel, ControlRequireErrorWvs, "0"  , ":"  , ";")		//no require errors, let user change that later, if needed.
			UseModelData=0
		endif
	endif
	if (cmpstr(ctrlName,"UseModelData")==0)
		//here we control the data structure checkbox
		if (checked)
			UseIndra2Data=0
			UseQRSData=0
			UseResults=0
			UseUserDefinedData=0
			Execute ("SetVariable WaveMatchStr disable=1, win="+TopPanel)
			Execute ("SetVariable FolderMatchStr disable=1, win="+TopPanel)
		endif
	endif
	
	
	if ( cmpstr(ctrlName,"UseModelData")==0 || cmpstr(ctrlName,"QLogScale")==0)
		STRUCT WMSetVariableAction SV_Struct
		SV_Struct.ctrlName=""
		SV_Struct.dval=0
		SV_Struct.win=TopPanel
		SV_Struct.sVAL=""
		SV_Struct.vName=""
		SV_Struct.eventcode=2
		IR2C_ModelQSetVarProc(SV_Struct)			//here we create the model and stuff the values in the Dtf etc... 
	else				//in case we do not use model, this is the right thing to do... 
		SVAR Dtf=$(CntrlLocation+":DataFolderName")
		SVAR IntDf=$(CntrlLocation+":IntensityWaveName")
		SVAR QDf=$(CntrlLocation+":QWaveName")
		SVAR EDf=$(CntrlLocation+":ErrorWaveName")
			Dtf="---"
			IntDf="---"
			QDf="---"
			EDf="---"
			string TpPnl=TopPanel
			PopupMenu SelectDataFolder mode=1, win=$(TopPanel)
		//	PopupMenu IntensityDataName mode=1,value= #"\"---;\"+IR2P_ListOfWaves(\"Yaxis\",\"*\",\""+TpPnl+"\")", win=$(TopPanel)
			Execute ("PopupMenu IntensityDataName mode=1, value=\"---;\"+IR2P_ListOfWaves(\"Yaxis\",\"*\",\""+TpPnl+"\"), win="+TopPanel)
			Execute ("PopupMenu QvecDataName mode=1, value=\"---;\"+IR2P_ListOfWaves(\"Xaxis\",\"*\",\""+TpPnl+"\"), win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1, value=\"---;\"+IR2P_ListOfWaves(\"Error\",\"*\",\""+TpPnl+"\"), win="+TopPanel)
			//PopupMenu QvecDataName mode=1,value= #"\"---;\"+IR2P_ListOfWaves(\"Xaxis\",\"*\")", win=$(TopPanel)
			//PopupMenu ErrorDataName mode=1,value= #"\"---;\"+IR2P_ListOfWaves(\"Error\",\"*\")", win=$(TopPanel)
	endif
	IR2C_FixDisplayedControls(TopPanel) 
	
	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function/T IR2P_CleanUpPackagesFolder(FolderList)
		string FolderList
		
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	FolderList = GrepList(FolderList, "root:packages" ,1 , ";" )
	FolderList = GrepList(FolderList, "root:Packages" ,1 , ";" )
	FolderList = GrepList(FolderList, "root:raw" ,1 , ";" )
	FolderList = GrepList(FolderList, "root:Raw" ,1 , ";" )
	return FolderList
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function/T IR2P_GenStringOfFolders([winNm, returnListOfFolders, forceReset])
	string winNm
	variable returnListOfFolders, forceReset

	//variable startTicks=ticks
	//part to copy everywhere...	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()

	string TopPanel
	if( ParamIsDefault(winNm))
		TopPanel=WinName(0,65)
		winNm = TopPanel
	else
		TopPanel=winNm
	endif
	if( ParamIsDefault(returnListOfFolders))
		returnListOfFolders = 0
	endif
	if( ParamIsDefault(returnListOfFolders))
		forceReset = 0
	endif	
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedUserTypes=root:Packages:IrenaControlProcs:ControlAllowedUserTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	string LocallyAllowedUserData=StringByKey(TopPanel, ControlAllowedUserTypes,"=",">")
	string LocallyAllowedIndra2Data=StringByKey(TopPanel, ControlAllowedIrenaTypes,"=",">")
	string LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
	SVAR/Z FolderMatchStr=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(winNm)+":FolderMatchStr")
	SVAR/Z WaveMatchStr = $("root:Packages:IrenaControlProcs:"+possiblyQuoteName(winNm)+":WaveMatchStr")
	if(!SVAR_Exists(FolderMatchStr))
		string/g $("root:Packages:IrenaControlProcs:"+possiblyQuoteName(winNm)+":FolderMatchStr")
		SVAR FolderMatchStr=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(winNm)+":FolderMatchStr")
		FolderMatchStr=""
	endif
	if(!SVAR_Exists(WaveMatchStr))
		string/g $("root:Packages:IrenaControlProcs:"+possiblyQuoteName(winNm)+":WaveMatchStr")
		SVAR WaveMatchStr=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(winNm)+":WaveMatchStr")
		WaveMatchStr=""
	endif
	setDataFolder $(CntrlLocation)
	NVAR UseIndra2Structure=$(CntrlLocation+":UseIndra2Data")
	NVAR UseQRSStructure=$(CntrlLocation+":UseQRSData")
	NVAR UseResults=$(CntrlLocation+":UseResults")
	NVAR UseUserDefinedData=$(CntrlLocation+":UseUserDefinedData")
	SVAR Dtf=$(CntrlLocation+":DataFolderName")
	SVAR IntDf=$(CntrlLocation+":IntensityWaveName")
	SVAR QDf=$(CntrlLocation+":QWaveName")
	SVAR EDf=$(CntrlLocation+":ErrorWaveName")
	///end of common block  
	string ListOfQFolders
	string result="", tempResult, resultShort=""
	variable i, j, StartTime, AlreadyIn
	string tempStr="", temp1, temp2, temp3, FixedMatchString
	variable StaleWave=1


	if (UseIndra2Structure)
		SVAR/Z ListOfIndraFolders = $(CntrlLocation+":ListOfIndraFolders")
		NVAR/Z SetTimeOfIndraFoldersStr = $(CntrlLocation+":SetTimeOfIndraFoldersStr")
		if(NVAR_Exists(SetTimeOfIndraFoldersStr) && SVAR_Exists(ListOfIndraFolders) && (datetime - SetTimeOfIndraFoldersStr)<10 && !forceReset)
			result = ListOfIndraFolders
			SVAR/Z DataFldrListOfFolder = $(CntrlLocation+":DataFldrListOfFolder")
			if(SVAR_Exists(DataFldrListOfFolder))
				resultShort = DataFldrListOfFolder
			else
				resultShort = IR2P_CreateFolderPathLists(CntrlLocation, result)	
			endif
			SetTimeOfIndraFoldersStr = datetime			//lets keep it as updated here...
		else
			tempResult=IN2G_FindFolderWithWvTpsList("root:USAXS:", 10,LocallyAllowedIndra2Data, 1) //contains list of all folders which contain any of the tested Intensity waves...
			//match to user mask using greplist
			if(strlen(FolderMatchStr)>0)
				tempResult=GrepList(tempResult, FolderMatchStr)
			endif
			//done, now rest...
			//now prune the folders off the ones which do not contain full triplet of waves...
			For(j=0;j<ItemsInList(tempResult);j+=1)			//each folder one by one
				temp1 = stringFromList(j,tempResult)
				for(i=0;i<ItemsInList(LocallyAllowedIndra2Data);i+=1)			//each type of data one by one...
					temp2=stringFromList(i,LocallyAllowedIndra2Data)
					if(cmpstr("---",IR2P_CheckForRightIN2TripletWvs(TopPanel,stringFromList(j,tempResult),stringFromList(i,LocallyAllowedIndra2Data)))!=0 )//&& AlreadyIn<1)
						result += stringFromList(j,tempResult)+";"
						break
					endif
				endfor
			endfor	
			string/G $(CntrlLocation+":ListOfIndraFolders")
			variable/g $(CntrlLocation+":SetTimeOfIndraFoldersStr")
			SVAR/Z ListOfIndraFolders = $(CntrlLocation+":ListOfIndraFolders")
			NVAR/Z SetTimeOfIndraFoldersStr = $(CntrlLocation+":SetTimeOfIndraFoldersStr")
			ListOfIndraFolders = result
			resultShort = IR2P_CreateFolderPathLists(CntrlLocation, result)
			SetTimeOfIndraFoldersStr = datetime
		endif	
	elseif (UseQRSStructure)
			//Wave/Z/T ResultingWave=$(CntrlLocation+":ResultingWave")
			SVAR/Z  ListOfQFoldersLookup = $(CntrlLocation+":ListOfQFolders")
			NVAR/Z SetTimeOfQFoldersStr = $(CntrlLocation+":SetTimeOfQFoldersStr")
			if(SVAR_Exists(ListOfQFoldersLookup) && (datetime - SetTimeOfQFoldersStr) < 10 && !forceReset)
				result=ListOfQFoldersLookup	
				SVAR/Z DataFldrListOfFolder = $(CntrlLocation+":DataFldrListOfFolder")
				if(SVAR_Exists(DataFldrListOfFolder))
					resultShort = DataFldrListOfFolder
				else
					resultShort = IR2P_CreateFolderPathLists(CntrlLocation, result)	
				endif
				SetTimeOfQFoldersStr = datetime
				//print "Used cache"
			else
				//make/N=0/O/T $(CntrlLocation+":ResultingWave")
				//Wave/T ResultingWave=$(CntrlLocation+":ResultingWave")
				make/N=0/T/Free TempResultingWave
				string/g  $(CntrlLocation+":ListOfQFolders")
				variable/g  $(CntrlLocation+":SetTimeOfQFoldersStr")
				SVAR/Z  ListOfQFoldersLookup = $(CntrlLocation+":ListOfQFolders")
				NVAR/Z SetTimeOfQFoldersStr = $(CntrlLocation+":SetTimeOfQFoldersStr")
				IR2P_FindFolderWithWaveTypesWV("root:", 10, "(?i)^r|i$", 1, TempResultingWave)
				if(strlen(FolderMatchStr)>0)
				     // FixedMatchString = IR2C_PreparematchString(FolderMatchStr)
				      FixedMatchString = (FolderMatchStr)
					variable ii
					for(ii=numpnts(TempResultingWave)-1;ii>=0;ii-=1)
						if(!GrepString(TempResultingWave[ii],FixedMatchString))
							DeletePoints ii, 1, TempResultingWave
						endif
					endfor
				endif
				ListOfQFolders=IR2P_CheckForRightQRSTripletWvs(TopPanel,TempResultingWave,WaveMatchStr)		
				//match to user mask using greplist
				//done, now rest...
				ListOfQFolders=IR2P_CleanUpPackagesFolder(ListOfQFolders)
				ListOfQFolders=IR2P_RemoveDuplicateStrfLst(ListOfQFolders)
				ListOfQFoldersLookup = ListOfQFolders
				result=ListOfQFolders
				resultShort = IR2P_CreateFolderPathLists(CntrlLocation, result)
				SetTimeOfQFoldersStr = datetime
				//print "recalculated lookup"
			endif
	elseif (UseResults)
		SVAR/Z ListOfResultsFolders = $(CntrlLocation+":ListOfResultsFolders")
		NVAR/Z SetTimeOfResultsFoldersStr = $(CntrlLocation+":SetTimeOfResultsFoldersStr")
		if(NVAR_Exists(SetTimeOfResultsFoldersStr) && SVAR_Exists(ListOfResultsFolders) && (datetime - SetTimeOfResultsFoldersStr)<5)
			result = ListOfResultsFolders
			SVAR/Z DataFldrListOfFolder = $(CntrlLocation+":DataFldrListOfFolder")
			if(SVAR_Exists(DataFldrListOfFolder))
				resultShort = DataFldrListOfFolder
			else
				resultShort = IR2P_CreateFolderPathLists(CntrlLocation, result)	
			endif
			SetTimeOfResultsFoldersStr = datetime
		else
			temp3=""
			For(i=0;i<ItemsInList(LocallyAllowedResultsData);i+=1)
				temp3+=stringFromList(i,LocallyAllowedResultsData)+"*;"
			endfor
			tempResult=IN2G_FindFolderWithWvTpsList("root:", 10,temp3, 1) //contains list of all folders which contain any of the tested Y waves... But may not contain the whole duplex of waves...
					//match to user mask using greplist
			if(strlen(FolderMatchStr)>0)
				//tempResult=GrepList(tempResult, IR2C_PreparematchString(FolderMatchStr) )
				tempResult=GrepList(tempResult, (FolderMatchStr) )
			endif
			//done, now rest...
			tempResult=IR2P_CleanUpPackagesFolder(tempResult)
			//the following will remove the folders which accidentally contain not-full duplex of waves and display ONLY folders with the right duplexes of waves.... 
			result = IR2P_CheckForRightINResultsWvs(TopPanel,tempResult,WaveMatchStr)
			string/G $(CntrlLocation+":ListOfResultsFolders")
			variable/g $(CntrlLocation+":SetTimeOfResultsFoldersStr")
			SVAR/Z ListOfResultsFolders = $(CntrlLocation+":ListOfResultsFolders")
			NVAR/Z SetTimeOfResultsFoldersStr = $(CntrlLocation+":SetTimeOfResultsFoldersStr")
			ListOfResultsFolders = result
			resultShort = IR2P_CreateFolderPathLists(CntrlLocation, result)
			SetTimeOfResultsFoldersStr = datetime
			//print "recalculated lookup"
		endif
	elseif (UseUserDefinedData)
		SVAR/Z ListOfUserDefinedFolders = $(CntrlLocation+":ListOfUserDefinedFolders")
		NVAR/Z SetTimeOfUserDefFoldersStr = $(CntrlLocation+":SetTimeOfUserDefFoldersStr")
		if(NVAR_Exists(SetTimeOfUserDefFoldersStr) && SVAR_Exists(ListOfUserDefinedFolders) && (datetime - SetTimeOfUserDefFoldersStr)<5)
			result = ListOfUserDefinedFolders
			SVAR/Z DataFldrListOfFolder = $(CntrlLocation+":DataFldrListOfFolder")
			if(SVAR_Exists(DataFldrListOfFolder))
				resultShort = DataFldrListOfFolder
			else
				resultShort = IR2P_CreateFolderPathLists(CntrlLocation, result)	
			endif
			SetTimeOfUserDefFoldersStr = datetime
		else
			tempResult=IN2G_FindFolderWithWvTpsList("root:", 10,LocallyAllowedUserData, 1) //contains list of all folders which contain any of the tested Intensity waves...
			//match to user mask using greplist
			if(strlen(FolderMatchStr)>0)
				//tempResult=GrepList(tempResult, IR2C_PreparematchString(FolderMatchStr) )
				tempResult=GrepList(tempResult, (FolderMatchStr) )
			endif
			//done, now rest...
			tempResult=IR2P_CleanUpPackagesFolder(tempResult)
			//now prune the folders off the ones which do not contain full triplet of waves...
			For(j=0;j<ItemsInList(tempResult);j+=1)			//each folder one by one
				temp1 = stringFromList(j,tempResult)
				for(i=0;i<ItemsInList(LocallyAllowedUserData);i+=1)			//each type of data one by one...
					temp2=stringFromList(i,LocallyAllowedUserData)
					if(cmpstr("---",IR2P_CheckForRightUsrTripletWvs(TopPanel,stringFromList(j,tempResult),stringFromList(i,LocallyAllowedUserData), WaveMatchStr))!=0 )//&& AlreadyIn<1)
						result += stringFromList(j,tempResult)+";"
						break
					endif
				endfor
			endfor	
			string/G $(CntrlLocation+":ListOfUserDefinedFolders")
			variable/g $(CntrlLocation+":SetTimeOfUserDefFoldersStr")
			SVAR/Z ListOfUserDefinedFolders = $(CntrlLocation+":ListOfUserDefinedFolders")
			NVAR/Z SetTimeOfUserDefFoldersStr = $(CntrlLocation+":SetTimeOfUserDefFoldersStr")
			ListOfUserDefinedFolders = result
			resultShort = IR2P_CreateFolderPathLists(CntrlLocation, result)
			SetTimeOfUserDefFoldersStr = datetime
		endif
	else
		result=IN2G_NewFindFolderWithWaveTypes("root:", 10, "*", 1)         //any data.
	    //match to user mask using greplist
	    if(strlen(FolderMatchStr)>0)
	          result=GrepList(result, (FolderMatchStr) )
	    endif
	    //and prepare short list 
	 	//match to user mask using greplist
		if(strlen(FolderMatchStr)>0)
			result=GrepList(result, (FolderMatchStr) )
		endif
	   //result = IR2P_CheckForRightUsrTripletWvs(TopPanel, result,"*",IR2C_PreparematchString(WaveMatchStr))
		//done, now rest...
		resultShort = IR2P_CreateFolderPathLists(CntrlLocation, result)
	 	SetTimeOfUserDefFoldersStr = datetime
	endif
	setDataFolder OldDf
	if(returnListOfFolders)
		return result
	else
		return resultShort
	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function/T IR2P_CreateFolderPathLists(CntrlLocation, result)
	string CntrlLocation, result
	//create short list...
	String LastFolderPath, tempStrItem, FolderPath, resultShortWP
	string resultShort
	variable i
	resultShortWP=""
	LastFolderPath = ""
	resultShort = ""
	for(i=0;i<ItemsInList(result,";");i+=1)
		tempStrItem = stringFromList(i,result)
		FolderPath = RemoveFromList(stringFromList(ItemsInList(tempStrItem,":")-1, tempStrItem,":"), tempStrItem,":")
		if(!stringMatch(FolderPath, LastFolderPath ))
			resultShort+=FolderPath+" ----------- "+";"
			resultShortWP+=FolderPath+" ----------- "+";"
		endif
		resultShort+=stringFromList(ItemsInList(tempStrItem,":")-1,tempStrItem,":")+";"
		resultShortWP+=tempStrItem+";"
		LastFolderPath = FolderPath
	endfor
	string/g $(CntrlLocation+":RealLongListOfFolder")
	SVAR RealLongListOfFolder = $(CntrlLocation+":RealLongListOfFolder")
	RealLongListOfFolder = result
	string/g $(CntrlLocation+":ShortListOfFolders")
	SVAR ShortListOfFolders = $(CntrlLocation+":ShortListOfFolders")
	ShortListOfFolders = resultShortWP
	string/g $(CntrlLocation+":DataFldrListOfFolder")
	SVAR DataFldrListOfFolder = $(CntrlLocation+":DataFldrListOfFolder")
	DataFldrListOfFolder = resultShort
	return resultShort
end


//static Function/T IR2P_RemoveDuplicateStrfLst(StrList)
//	string StrList
//
//	
//	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
//	variable i
//	string result=""///stringFromList(0,StrList,";")+";"
//	string tempStr
//	For(i=0;i<ItemsInList(StrList,";");i+=1)
//		tempStr=stringFromList(i,StrList,";")
//		if(!stringmatch(result, "*"+tempStr+"*" ))		//surprisingly, this is faster that GrepString... 
//		//if(!GrepString(result, stringFromList(i,StrList,";")))
//			result+=tempStr+";"
//		endif
//	endfor
//	return result
//end
//

Function/T IR2P_RemoveDuplicateStrfLst(StrList)
	string StrList

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if(ItemsInList(StrList)>1)
		Wave/T wr = ListToTextWave(StrList, ";")	// Returns a free wave
		FindDuplicates/RT=StrWvUnique wr
		String result=""
		wfprintf result, "%s;", StrWvUnique 			// ; separated list
	else
		result = StrList
	endif
	return result
end

//static Function/T IR2P_RemoveDuplicateStrfLstOld(StrList) 		//this does not work, I need the most likely one stay at front. 
//	string StrList				//this is faster, but... 
//	
//	String sortedList=SortList(StrList)
//	string tempStr1, tempStr2
//	variable i
//	string result=""
//	tempStr1 = stringFromList(0,sortedList,";")
//	result=tempStr1+";"
//	For(i=1;i<ItemsInList(sortedList,";");i+=1)
//		tempStr2 = stringFromList(i,sortedList,";")
//		if(!stringmatch(tempStr1, tempStr2))		//surprisingly, this is faster that GrepString... 
//			result+=tempStr2+";"
//		endif
//		tempStr1=tempStr2
//	endfor
//	return result
//end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function/T IR2P_ReturnListQRSFolders(ListOfQFolders, AllowQROnly)
	string ListOfQFolders
	variable AllowQROnly
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if(cmpstr(ListOfQFolders,"---")==0)
		return "---"
	endif
	
	string result, tempStringQ, tempStringR, tempStringS, nowFolder,oldDf
	oldDf=GetDataFolder(1)
	variable i, j
	result=""
	string tempStr
	For(i=0;i<ItemsInList(ListOfQFolders);i+=1)
		NowFolder= stringFromList(i,ListOfQFolders)
		setDataFolder NowFolder
		tempStr=IN2G_ConvertDataDirToList(DataFolderDir(2))
		tempStringQ=IR2P_ListOfWavesOfType("q*",tempStr)+IR2P_ListOfWavesOfType("d*",tempStr)+IR2P_ListOfWavesOfType("t*",tempStr)+IR2P_ListOfWavesOfType("m*",tempStr)
		tempStringR=IR2P_ListOfWavesOfType("r*",tempStr)
		tempStringS=IR2P_ListOfWavesOfType("s*",tempStr)
		For (j=0;j<ItemsInList(tempStringQ);j+=1)
			if(AllowQROnly)
				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringQ)[1,inf]+";*"))
					result+=NowFolder+";"
					break
				endif
			else
				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringQ)[1,inf]+";*") && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringQ)[1,inf]+";*"))
					result+=NowFolder+";"
					break
				endif
			endif
		endfor
				
	endfor
	setDataFOlder oldDf
	return result

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function/T IR2P_CheckForRightINResultsWvs(TopPanel, FullFldrNames,WNMStr)
	string TopPanel, FullFldrNames, WNMStr

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()

	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	SVAR XwaveDataTypesLookup=root:Packages:IrenaControlProcs:XwaveDataTypesLookup
	SVAR EwaveDataTypesLookup=root:Packages:IrenaControlProcs:EwaveDataTypesLookup
	SVAR ResultsDataTypesLookup=root:Packages:IrenaControlProcs:ResultsDataTypesLookup
	SVAR ResultsEDataTypesLookup = root:Packages:IrenaControlProcs:ResultsEDataTypesLookup
	
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	string LocallyAllowedIndra2Data=StringByKey(TopPanel, ControlAllowedIrenaTypes,"=",">")
	string LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
	string XwaveType//=stringByKey(DataTypeSearchedFor,XwaveDataTypesLookup)
	string EwaveType//=stringByKey(DataTypeSearchedFor,EwaveDataTypesLookup)
	variable RequireErrorWvs = numberByKey(TopPanel, ControlRequireErrorWvs)
	string result=""
	string tempResult="" , FullFldrName
 	variable i,j,jj, matchX=0,matchE=0
	string AllWaves, allYwaves, currentYWave,currentXWave, currentEwave, TMPX1, TMPX2
	
	for(i=0;i<ItemsInList(FullFldrNames);i+=1)
		FullFldrName = stringFromList(i,FullFldrNames)
		AllWaves = IN2G_CreateListOfItemsInFolder(FullFldrName,2)
//		if(strlen(WNMStr)==0 || GrepString(AllWaves, IR2C_PrepareMatchString(WNMStr)))		//this is not supported for results... Sorry :-)
			matchX=0
			tempresult=""
			For(j=0;j<ItemsInList(LocallyAllowedResultsData);j+=1)
				allYwaves=IR2P_ListOfWavesOfType(stringFromList(j,LocallyAllowedResultsData)+"_*",AllWaves)
				For(jj=0;jj<ItemsInList(allYWaves);jj+=1)
					currentYWave=stringFromList(jj,AllYWaves)
					currentXWave = StringByKey(StringFromList(0,currentYWave,"_"), ResultsDataTypesLookup)
					TMPX1 = STRINGFROMLIST(0,currentXWave,",")
					TMPX2 = stringfromList(1,currentXWave,",")
					if(strlen(TMPX2)<1)
						TMPX2="tndksno jiorhew"
					endif
					currentEwave = StringByKey(StringFromList(0,currentYWave,"_"), ResultsEDataTypesLookup)
					//if(stringmatch(";"+AllWaves, "*;"+currentXWave+"_"+StringFromList(1,currentYWave,"_")+"*" ) || cmpstr("x-scaling",currentXWave)==0)
					if(GrepString(AllWaves, TMPX1+"_"+StringFromList(1,currentYWave,"_") ) || cmpstr("x-scaling",currentXWave)==0 || GrepString(AllWaves, TMPX2+"_"+StringFromList(1,currentYWave,"_") ) )
						matchX=1
						tempresult=FullFldrName+";"
						break
					endif
				endfor
				if(matchX)
					break	
				endif
			endfor
			result+=tempresult
//		endif
	endfor
	setDataFolder OldDf
	if(strlen(result)>1)
		return result
	else
		return "---"
	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//**********************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function/T IR2P_CheckForRightQRSTripletWvs(TopPanel, ResultingWave,WNMStr)
	string TopPanel
	wave/T ResultingWave
	string WNMStr			//waveName match string used by user...
	//FullFldrNames

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()

	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	SVAR XwaveDataTypesLookup=root:Packages:IrenaControlProcs:XwaveDataTypesLookup
	SVAR EwaveDataTypesLookup=root:Packages:IrenaControlProcs:EwaveDataTypesLookup
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	string LocallyAllowedIndra2Data=StringByKey(TopPanel, ControlAllowedIrenaTypes,"=",">")
	string LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
	variable RequireErrorWvs = numberByKey(TopPanel, ControlRequireErrorWvs)
	string result=""
	string tempResult="" , FullFldrName
 	variable i,j, matchX=0,matchE=0, matchU=0
	string AllWaves
	string allRwaves
	string tempStr
	string ShortWaveList

	variable startTime=ticks	
//	for(i=0;i<ItemsInList(FullFldrNames);i+=1)			//this looks for qrs tripplets
//		FullFldrName = stringFromList(i,FullFldrNames)
	for(i=0;i<numpnts(ResultingWave);i+=1)			//this looks for qrs tripplets
		FullFldrName = ResultingWave[i]
		AllWaves = IN2G_CreateListOfItemsInFolder(FullFldrName,2)
		//allRwaves=IR2P_ListOfWavesOfType("r*",AllWaves)
		allRwaves=GrepList(AllWaves,"(?i)^r")
		tempresult=""
			if(strlen(WNMStr)==0 || GrepString(allRwaves, IR2C_PrepareMatchString(WNMStr)))
				for(j=0;j<ItemsInList(allRwaves);j+=1)
					matchX=0
					matchE=0
					tempStr = stringFromList(j,allRwaves)[1,inf]
					tempStr = IN2G_CleanStringForgrep(tempStr)
					//ShortWaveList = GrepList(AllWaves, "q"+tempStr )+GrepList(AllWaves, "az"+tempStr )+GrepList(AllWaves, "d"+tempStr )+GrepList(AllWaves, "t"+tempStr )+GrepList(AllWaves, "m"+tempStr )
					ShortWaveList = GrepList(AllWaves, "(?i)[qzdtm]"+tempStr) //not sure if this really works for az, needs to be tested. 
					if(strlen(ShortWaveList)>0)
						matchX=1
					endif
					//if(stringmatch(";"+AllWaves, ";*q"+tempStr+";*" )||stringmatch(";"+AllWaves, ";*az"+tempStr+";*" )||stringmatch(";"+AllWaves, ";*d"+tempStr+";*" )||stringmatch(";"+AllWaves, ";*t"+tempStr+";*" )||(stringmatch(";"+AllWaves, ";*m"+tempStr+";*" )&&!stringmatch(";"+AllWaves, ";*dsm"+tempStr+";*" )))
					//	matchX=1
					//endif
					ShortWaveList = GrepList(AllWaves, "(?i)s"+tempStr) //not sure if this really works for az, needs to be tested. 
					if(strlen(ShortWaveList)>0)
						matchE=1
					endif
					//if(stringmatch(";"+AllWaves,";*s"+tempStr+";*" ))
					//	matchE=1
					//endif
					if(matchX && (matchE || !RequireErrorWvs))
						tempResult+= FullFldrName+";"
						break
					endif
				endfor
				result+=tempresult
			endif
	//endfor
	//for(i=0;i<ItemsInList(FullFldrNames);i+=1)			//and this for qis NIST standard
		//FullFldrName = stringFromList(i,FullFldrNames)
		//AllWaves = IN2G_CreateListOfItemsInFolder(FullFldrName,2)
		//allRwaves=IR2P_ListOfWavesOfType("*i",AllWaves)
		allRwaves=GrepList(AllWaves,"(?i)i$")
		tempresult=""
			if(strlen(WNMStr)==0 || GrepString(allRwaves, IR2C_PrepareMatchString(WNMStr)))
				for(j=0;j<ItemsInList(allRwaves);j+=1)
					matchX=0
					matchE=0
					if(stringmatch(";"+AllWaves, ";*"+stringFromList(j,allRwaves)[0,strlen(stringFromList(j,allRwaves))-2]+"q;*" ))
						matchX=1
					endif
					if(stringmatch(";"+AllWaves,";*"+stringFromList(j,allRwaves)[0,strlen(stringFromList(j,allRwaves))-2]+"s;*" ))
						matchE=1
					endif
					if(matchX && matchE)
						tempResult+= FullFldrName+";"
						break
					endif
				endfor
				result+=tempresult
			endif
	endfor
//	print ticks-startTime
	setDataFolder OldDf
	if(strlen(result)>1)
		return result
	else
		return "---"
	endif
	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function/T IR2P_ListOfWavesOfType(type,ListOfWaves)
		string type, ListOfWaves
		//optimized for speed 12/10/2010
		//wave types: r* should work
		//wave types : *i  
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string tempresult=""
	string tempType=""
	//if(GrepString(type, "^\*" ) )	//r* type
	//fixed 3/25/2012 after Dale found some bugs looking for his user defined data. Trying to fix and make all working
	if(GrepString(type, "^[*]" ) )			//*r type, qis NIST type data  
		tempType = type[1,inf]+"$"
	elseif(GrepString(type, "[*]$"))		//r* type, qrs type data
		tempType = "^"+stringfromlist(0,type,"*")
	else	
		tempType = "^"+type[0,inf]
	endif
	tempresult = grepList(ListOfWaves, "(?i)"+tempType)
	//end of new method
//	print tempresult
	return tempresult

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//**************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function/T IR2P_CheckForRightUsrTripletWvs(TopPanel, FullFldrNames,DataTypeSearchedFor,WNMStr)
	string TopPanel, FullFldrNames,DataTypeSearchedFor, WNMStr

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()

	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedUserTypes=root:Packages:IrenaControlProcs:ControlAllowedUserTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	SVAR XwaveDataTypesLookup=root:Packages:IrenaControlProcs:XwaveDataTypesLookup
	SVAR EwaveDataTypesLookup=root:Packages:IrenaControlProcs:EwaveDataTypesLookup
	SVAR XwaveUserDataTypesLookup=root:Packages:IrenaControlProcs:XwaveUserDataTypesLookup
	SVAR EwaveUserDataTypesLookup=root:Packages:IrenaControlProcs:EwaveUserDataTypesLookup
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	string LocallyAllowedIndra2Data=StringByKey(TopPanel, ControlAllowedIrenaTypes,"=",">")
	string LocallyAllowedUserData=StringByKey(TopPanel, ControlAllowedUserTypes,"=",">")
	string LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
	string XwaveType=stringByKey(DataTypeSearchedFor,XwaveUserDataTypesLookup)
	string EwaveType=stringByKey(DataTypeSearchedFor,EwaveUserDataTypesLookup)
	variable RequireErrorWvs = numberByKey(TopPanel, ControlRequireErrorWvs)
	string result=""
	string tempResult="" , FullFldrName
 	variable i,j, matchX=0,matchE=0
	string AllWaves, allRwaves
	//string LocallyAllowedUserXData=stringFromList(0,StringByKey(DataTypeSearchedFor, XwaveUserDataTypesLookup , ":", ";"),"*")
	//string LocallyAllowedUserEData=stringFromList(0,StringByKey(DataTypeSearchedFor, EwaveUserDataTypesLookup , ":", ";"),"*")
	string LocallyAllowedUserXData=ReplaceString("*", StringByKey(DataTypeSearchedFor, XwaveUserDataTypesLookup , ":", ";"), "")
	string LocallyAllowedUserEData=ReplaceString("*", StringByKey(DataTypeSearchedFor, EwaveUserDataTypesLookup , ":", ";"), "")
	
	for(i=0;i<ItemsInList(FullFldrNames);i+=1)
		FullFldrName = stringFromList(i,FullFldrNames)
		if(grepstring(DataTypeSearchedFor,"\*"))			//the match contains *, assume semi qrs type...... The data type is Q*, r*, s*
			AllWaves = IN2G_CreateListOfItemsInFolder(FullFldrName,2)
			allRwaves=IR2P_ListOfWavesOfType(DataTypeSearchedFor,AllWaves)
			tempresult=""
			if(strlen(WNMStr)==0 || GrepString(allRwaves, IR2C_PrepareMatchString(WNMStr)))
				for(j=0;j<ItemsInList(allRwaves);j+=1)
					matchX=0
					matchE=0
					if(StringMatch(LocallyAllowedUserXData, "az")||StringMatch(LocallyAllowedUserXData, "qz")||StringMatch(LocallyAllowedUserXData, "qy")||StringMatch(LocallyAllowedUserXData, "qx"))		//these areunique, two letters replace on in wave bames... 
						if(stringmatch(";"+AllWaves, ";*"+LocallyAllowedUserXData+stringFromList(j,allRwaves)[1,inf]+";*" )||stringmatch(XwaveType,"x-scaling"))
							//matchX=1
							if(RequireErrorWvs)
								if(stringmatch(";"+AllWaves,";*"+LocallyAllowedUserEData+stringFromList(j,allRwaves)[1,inf]+";*" ))
									tempResult+= FullFldrName+";"
									break
								else
									//not the right combination
								endif
							else
								tempResult+= FullFldrName+";"
								break					
							endif
						else
							//not the right combination
						endif					
					else
						if(stringmatch(";"+AllWaves, ";*"+LocallyAllowedUserXData+stringFromList(j,allRwaves)[strlen(LocallyAllowedUserXData),inf]+";*" )||stringmatch(";"+AllWaves, ";*"+stringFromList(j,allRwaves)[0,strlen(stringFromList(j,allRwaves))-strlen(LocallyAllowedUserXData)-1]+LocallyAllowedUserXData+";*" )||stringmatch(XwaveType,"x-scaling"))
							//matchX=1
							if(RequireErrorWvs)
								if(stringmatch(";"+AllWaves,";*"+LocallyAllowedUserEData+stringFromList(j,allRwaves)[strlen(LocallyAllowedUserEData),inf]+";*" ) || stringmatch(";"+AllWaves,";*"+stringFromList(j,allRwaves)[0,strlen(stringFromList(j,allRwaves)) - strlen(LocallyAllowedUserEData)-1]+LocallyAllowedUserEData+";*" ))
									tempResult+= FullFldrName+";"
									break
								else
									//not the right combination
								endif
							else
								tempResult+= FullFldrName+";"
								break					
							endif
						else
							//not the right combination
						endif
					endif
				endfor
				result+=tempresult
			endif
		else												//asume Indra2 type system
			AllWaves = IN2G_CreateListOfItemsInFolder(FullFldrName,2)
			if(strlen(WNMStr)==0 || GrepString(allRwaves, IR2C_PrepareMatchString(WNMStr)))
				matchX=0
				matchE=0
				if(stringmatch(";"+AllWaves, "*;"+XwaveType+";*" )||stringmatch(XwaveType,"x-scaling"))
					matchX=1
				endif
				if(stringmatch(";"+AllWaves, "*;"+EwaveType+";*" ))
					matchE=1
				endif
				if(matchX && (matchE || !RequireErrorWvs))
					tempResult+= FullFldrName+";"
				endif
				result+=tempresult
			endif
		endif
	endfor
	setDataFolder OldDf
	if(strlen(result)>1)
		return result
	else
		return "---"
	endif
	
end
//*****************************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function/T IR2P_CheckForRightIN2TripletWvs(TopPanel, FullFldrNames,DataTypeSearchedFor)
	string TopPanel, FullFldrNames,DataTypeSearchedFor

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()

	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	SVAR XwaveDataTypesLookup=root:Packages:IrenaControlProcs:XwaveDataTypesLookup
	SVAR EwaveDataTypesLookup=root:Packages:IrenaControlProcs:EwaveDataTypesLookup
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	string LocallyAllowedIndra2Data=StringByKey(TopPanel, ControlAllowedIrenaTypes,"=",">")
	string LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
	string XwaveType=stringByKey(DataTypeSearchedFor,XwaveDataTypesLookup)
	string EwaveType=stringByKey(DataTypeSearchedFor,EwaveDataTypesLookup)
	variable RequireErrorWvs = numberByKey(TopPanel, ControlRequireErrorWvs)
	string result=""
	string tempResult="" , FullFldrName
 	variable i,j, matchX=0,matchE=0
	string AllWaves
	
	for(i=0;i<ItemsInList(FullFldrNames);i+=1)
		FullFldrName = stringFromList(i,FullFldrNames)
		AllWaves = IN2G_CreateListOfItemsInFolder(FullFldrName,2)
		matchX=0
		matchE=0
		if(stringmatch(";"+AllWaves, "*;"+XwaveType+";*" ))
			matchX=1
		endif
		if(stringmatch(";"+AllWaves, "*;"+EwaveType+";*" ))
			matchE=1
		endif
		if(matchX && (matchE || !RequireErrorWvs))
			tempResult+= FullFldrName+";"
		endif
		result+=tempresult
	endfor
	setDataFolder OldDf
	if(strlen(result)>1)
		return result
	else
		return "---"
	endif
	
end
//**********************************************************************************************************
//**************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function/T IR2P_ListOfWaves(DataType,MatchMeTo, winNm)
	string DataType, MatchMeTo, winNm			//data type   : Xaxis, Yaxis, Error
										//Match me to is string to match the type to... Use "*" to get all... Applicable ONLY to Y and error data
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()

	string TopPanel=winNm

	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlAllowedUserTypes=root:Packages:IrenaControlProcs:ControlAllowedUserTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	SVAR XwaveDataTypesLookup=root:Packages:IrenaControlProcs:XwaveDataTypesLookup
	SVAR EwaveDataTypesLookup=root:Packages:IrenaControlProcs:EwaveDataTypesLookup
	SVAR ResultsDataTypesLookup=root:Packages:IrenaControlProcs:ResultsDataTypesLookup
	SVAR XwaveUserDataTypesLookup=root:Packages:IrenaControlProcs:XwaveUserDataTypesLookup
	SVAR EwaveUserDataTypesLookup=root:Packages:IrenaControlProcs:EwaveUserDataTypesLookup
	SVAR ResultsEDataTypesLookup=root:Packages:IrenaControlProcs:ResultsEDataTypesLookup

	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	SVAR/Z WaveMatchStr=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(TopPanel)+":WaveMatchStr")
	if(!SVAR_Exists(WaveMatchStr))
		string/g $("root:Packages:IrenaControlProcs:"+possiblyQuoteName(TopPanel)+":WaveMatchStr")
		SVAR WaveMatchStr=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(TopPanel)+":WaveMatchStr")
		WaveMatchStr=""
	endif
	
	string LocallyAllowedIndra2Data=StringByKey(TopPanel, ControlAllowedIrenaTypes,"=",">")
	string LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
	string LocallyAllowedUserData=StringByKey(TopPanel, ControlAllowedUserTypes,"=",">")
//	string XwaveType=stringByKey(DataTypeSearchedFor,XwaveDataTypesLookup)
//	string EwaveType=stringByKey(DataTypeSearchedFor,EwaveDataTypesLookup)
	variable RequireErrorWvs = numberByKey(TopPanel, ControlRequireErrorWvs)

	NVAR UseIndra2Structure=$(CntrlLocation+":UseIndra2Data")
	NVAR UseQRSStructure=$(CntrlLocation+":UseQRSData")
	NVAR UseUserDefinedData=$(CntrlLocation+":UseUserDefinedData")
	NVAR UseResults=$(CntrlLocation+":UseResults")
	SVAR Dtf=$(CntrlLocation+":DataFolderName")
	SVAR IntDf=$(CntrlLocation+":IntensityWaveName")
	SVAR QDf=$(CntrlLocation+":QWaveName")
	SVAR EDf=$(CntrlLocation+":ErrorWaveName")

	//variable startTicks=ticks

	string result="", tempresult="", tempStringX="", tempStringY="", tempStringE="", listOfXWvs="", Endstr="", tempstringX2="", tempstringY2="", tempstringE2="", existingYWvs, existingXWvs, existingEWvs,tmpp, tmpstr2
	string ts, tx, ty, tempRadDiaStr, tmpLookupStr
	variable i,j, jj, tempRadDia, ijk
	variable setControls
	tempresult=""
	setControls=0
	tempresult=IN2G_CreateListOfItemsInFolder(Dtf,2)
	if (UseIndra2Structure)
		//matching names makes no sense...
		if(cmpstr(DataType,"Xaxis")==0)
			for(i=0;i<itemsInList(LocallyAllowedIndra2Data);i+=1)
				tempStringY=stringFromList(i,LocallyAllowedIndra2Data)
				tempStringX=stringByKey(tempStringY,XwaveDataTypesLookup)
				tempStringE=stringByKey(tempStringY,EwaveDataTypesLookup)
				if(stringmatch(";"+tempresult, "*;"+tempStringY+";*") && stringmatch(";"+tempresult, "*;"+tempStringX+";*") && (!RequireErrorWvs || stringmatch(";"+tempresult, "*;"+tempStringE+";*")))
					result+=tempStringX+";"
					if(setControls==0)
						IntDf=tempStringY
						QDf=tempStringX
						EDf=tempStringE
						setControls=1
					endif
				endif
			endfor
		elseif(cmpstr(DataType,"Yaxis")==0)
			for(i=0;i<itemsInList(LocallyAllowedIndra2Data);i+=1)
				tempStringY=stringFromList(i,LocallyAllowedIndra2Data)
				tempStringX=stringByKey(tempStringY,XwaveDataTypesLookup)
				tempStringE=stringByKey(tempStringY,EwaveDataTypesLookup)
				if(stringmatch(";"+tempresult, "*;"+tempStringY+";*") && stringmatch(";"+tempresult, "*;"+tempStringX+";*") && (!RequireErrorWvs || stringmatch(";"+tempresult, "*;"+tempStringE+";*")))
					if(cmpstr(MatchMeTo,"*")==0 || cmpstr(stringByKey(tempStringY,XwaveDataTypesLookup),MatchMeTo)==0)
						result+=tempStringY+";"
					endif
				endif
			endfor
		elseif(cmpstr(DataType,"Error")==0)
			for(i=0;i<itemsInList(LocallyAllowedIndra2Data);i+=1)
				tempStringY=stringFromList(i,LocallyAllowedIndra2Data)
				tempStringX=stringByKey(tempStringY,XwaveDataTypesLookup)
				tempStringE=stringByKey(tempStringY,EwaveDataTypesLookup)
				if(stringmatch(";"+tempresult, "*;"+tempStringY+";*") && stringmatch(";"+tempresult, "*;"+tempStringX+";*") && (!RequireErrorWvs || stringmatch(";"+tempresult, "*;"+tempStringE+";*")))
					if(cmpstr(MatchMeTo,"*")==0 || cmpstr(stringByKey(tempStringY,XwaveDataTypesLookup),MatchMeTo)==0)
						result+=tempStringE+";"
					endif
				endif
			endfor
		endif
	elseif(UseUserDefinedData) 
		//match the names if user wants...
		if(strlen(WaveMatchStr)>0)
			tempResult = GrepList(TempResult, IR2C_PrepareMatchString(WaveMatchStr))
		endif
		if(cmpstr(DataType,"Xaxis")==0)
			for(i=0;i<itemsInList(LocallyAllowedUserData);i+=1)
				tempStringY=stringFromList(i,LocallyAllowedUserData)
				tempStringX=stringByKey(tempStringY,XwaveUserDataTypesLookup)
				tempStringE=stringByKey(tempStringY,EwaveUserDataTypesLookup)
				existingYWvs=IR2P_ListOfWavesOfType(tempStringY,tempresult)
				existingXWvs=IR2P_ListOfWavesOfType(tempStringX,tempresult)
				existingEWvs=IR2P_ListOfWavesOfType(tempStringE,tempresult)
				tmpp=replaceString("*",tempStringY,"&")
				if(stringmatch(tmpp, "*&" ))		//Star was at the end,, so we need to match the end of the wave names
					tempstringY2=stringFromList(0,tempstringY,"*")
					tempstringX2=stringFromList(0,tempstringX,"*")
					tempstringE2=stringFromList(0,tempstringE,"*")
					For (j=0;j<ItemsInList(existingXWvs);j+=1)
						if (stringMatch(";"+existingYWvs,"*;"+tempstringY2+StringFromList(j,existingXWvs)[strlen(tempstringX2),inf]+";*") && (!RequireErrorWvs || stringMatch(";"+existingEWvs,"*;"+tempstringE2+StringFromList(j,existingXWvs)[strlen(tempstringX2),inf])))
							result+=StringFromList(j,existingXWvs)+";"
							if(setControls==0)
								IntDf=tempstringY2+StringFromList(j,existingXWvs)[strlen(tempstringX2),inf]
								QDf=StringFromList(j,existingXWvs)
								if(stringMatch(";"+existingEWvs,"*"+tempstringE2+StringFromList(j,existingXWvs)[strlen(tempstringX2),inf]))
									EDf=tempstringE2+StringFromList(j,existingXWvs)[strlen(tempstringX2),inf]
								else
									EDf="---"
								endif
								setControls=1
							endif
						endif
					endfor
				
				elseif(stringmatch(tmpp, "&*" ))						//assume IN2 type data, we need to match the front parts of the wave names...
					if(stringmatch(";"+tempresult, "*;"+tempStringY+";*") && stringmatch(";"+tempresult, "*;"+tempStringX+";*") && (!RequireErrorWvs || stringmatch(";"+tempresult, "*;"+tempStringE+";*")))
						//result+=tempStringX+";"
						result = IR2P_ListOfWavesOfType(tempStringX,tempresult)
						if(setControls==0)
						//	IntDf=tempStringY
						//	QDf=tempStringX
							IntDf=stringFromList(0,IR2P_ListOfWavesOfType(tempStringY,tempresult))
							QDf=stringFromList(0,IR2P_ListOfWavesOfType(tempStringX,tempresult))
							if(stringmatch(";"+tempresult, "*;"+tempStringE+";*"))
								//EDf=tempStringE
								EDf=stringFromList(0,IR2P_ListOfWavesOfType(tempStringE,tempresult))
							else
								EDf="---"
							endif
							setControls=1
						endif
					endif
				else //assume there is not match string to deal with
					if(stringmatch(";"+tempresult, "*;"+tempStringY+";*") && stringmatch(";"+tempresult, "*;"+tempStringX+";*") && (!RequireErrorWvs || stringmatch(";"+tempresult, "*;"+tempStringE+";*")))
						//result+=tempStringX+";"
						result += IR2P_ListOfWavesOfType(tempStringX,tempresult)
						if(setControls==0)
						//	IntDf=tempStringY
						//	QDf=tempStringX
							IntDf=stringFromList(0,IR2P_ListOfWavesOfType(tempStringY,tempresult))
							QDf=stringFromList(0,IR2P_ListOfWavesOfType(tempStringX,tempresult))
							if(stringmatch(";"+tempresult, "*;"+tempStringE+";*"))
								//EDf=tempStringE
								EDf=stringFromList(0,IR2P_ListOfWavesOfType(tempStringE,tempresult))
							else
								EDf="---"
							endif
							setControls=1
						endif
					endif
				endif	
			endfor
		elseif(cmpstr(DataType,"Yaxis")==0)
			for(i=0;i<itemsInList(LocallyAllowedUserData);i+=1)
				tempStringY=stringFromList(i,LocallyAllowedUserData)
				tempStringX=stringByKey(tempStringY,XwaveUserDataTypesLookup)
				tempStringE=stringByKey(tempStringY,EwaveUserDataTypesLookup)
				existingYWvs=IR2P_ListOfWavesOfType(tempStringY,tempresult)
				existingXWvs=IR2P_ListOfWavesOfType(tempStringX,tempresult)
				existingEWvs=IR2P_ListOfWavesOfType(tempStringE,tempresult)
				tmpp=replaceString("*",tempStringY,"&")
				if(stringmatch(tmpp, "*&" ))		//assume qrs type data
					tempstringY2=stringFromList(0,tempstringY,"*")
					tempstringX2=stringFromList(0,tempstringX,"*")
					tempstringE2=stringFromList(0,tempstringE,"*")
					For (j=0;j<ItemsInList(existingYWvs);j+=1)
						if (stringMatch(";"+existingXWvs,"*;"+tempstringX2+StringFromList(j,existingYWvs)[strlen(tempstringY2),inf]+";*") && (!RequireErrorWvs || stringMatch(";"+existingEWvs,"*;"+tempstringE2+StringFromList(j,existingXWvs)[strlen(tempstringX2),inf])))
							if(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(j,existingYWvs)[strlen(tempstringY2),inf],MatchMeTo[strlen(tempstringX2),inf])==0)
								result+=StringFromList(j,existingYWvs)+";"
							endif
						endif
					endfor
				
				elseif(stringmatch(tmpp, "&*" ))						//assume IN2 type data
					tempstringY2=stringFromList(1,tempstringY,"*")
					tempstringX2=stringFromList(1,tempstringX,"*")
					tempstringE2=stringFromList(1,tempstringE,"*")
					For (j=0;j<ItemsInList(existingYWvs);j+=1)
						if (stringMatch(";"+existingXWvs,"*;"+StringFromList(j,existingYWvs)[0,strlen(StringFromList(j,existingYWvs))-strlen(tempstringY)]+tempstringX2+";*") && (!RequireErrorWvs || stringMatch(";"+existingEWvs,"*;"+StringFromList(j,existingYWvs)[0,strlen(StringFromList(j,existingYWvs))-strlen(tempstringY)]+tempstringE2+";*")))
							if(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(j,existingYWvs)[strlen(tempstringY),inf],MatchMeTo[strlen(tempstringX),inf])==0)
								result+=StringFromList(j,existingYWvs)+";"
							endif
						endif
					endfor
				else				//assume data which may not have any match string... 
					tempstringY2=tempstringY
					tempstringX2=tempstringX
					tempstringE2=tempstringE
					//For (j=0;j<ItemsInList(existingYWvs);j+=1)
					//this is purely wrong here. We need to just test, that the xwave is here for the y wave, nothing else... ZRewire this to make sense... 
					//	if (stringMatch(";"+existingXWvs,"*;"+StringFromList(j,existingYWvs)) && (!RequireErrorWvs || stringMatch(";"+existingEWvs,"*;"+StringFromList(j,existingYWvs))))
					//		if(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(j,existingYWvs)[strlen(tempstringY),inf],MatchMeTo[strlen(tempstringX),inf])==0)
					if(StringMatch(tempstringX2, matchMeTo))
							result+=StringFromList(j,existingYWvs)+";"
					endif
					//		endif
					//	endif
					//endfor
				endif
			endfor
		elseif(cmpstr(DataType,"Error")==0)
			for(i=0;i<itemsInList(LocallyAllowedUserData);i+=1)
				tempStringY=stringFromList(i,LocallyAllowedUserData)
				tempStringX=stringByKey(tempStringY,XwaveUserDataTypesLookup)
				tempStringE=stringByKey(tempStringY,EwaveUserDataTypesLookup)
				existingYWvs=IR2P_ListOfWavesOfType(tempStringY,tempresult)
				existingXWvs=IR2P_ListOfWavesOfType(tempStringX,tempresult)
				existingEWvs=IR2P_ListOfWavesOfType(tempStringE,tempresult)
				tmpp=replaceString("*",tempStringY,"&")
				if(stringmatch(tmpp, "*&" ))		//assume qrs type data
					tempstringY2=stringFromList(0,tempstringY,"*")
					tempstringX2=stringFromList(0,tempstringX,"*")
					tempstringE2=stringFromList(0,tempstringE,"*")
					For (j=0;j<ItemsInList(existingEWvs);j+=1)
						if (stringMatch(";"+existingXWvs,"*;"+tempstringX2+StringFromList(j,existingEWvs)[strlen(tempstringE2),inf]+";*") && stringMatch(";"+existingYWvs,"*;"+tempstringY2+StringFromList(j,existingEWvs)[strlen(tempstringE2),inf]+";*"))
							if(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(j,existingEWvs)[strlen(tempstringE2),inf],MatchMeTo[strlen(tempstringX2),inf])==0)
								result+=StringFromList(j,existingEWvs)+";"
							endif
						endif
					endfor
				
				elseif(stringmatch(tmpp, "&*" ))										//asume IN2 type data
						//this is clearly unfinished...
					tempstringY2=stringFromList(1,tempstringY,"*")
					tempstringX2=stringFromList(1,tempstringX,"*")
					tempstringE2=stringFromList(1,tempstringE,"*")
					if(StringMatch(tempstringX2, matchMeTo))
							result+=StringFromList(j,existingEWvs)+";"
					endif
					
				else
					tempstringY2=tempstringY
					tempstringX2=tempstringX
					tempstringE2=tempstringE
					if(StringMatch(tempstringX2, matchMeTo)&&strlen(existingEWvs)>0)
							result+=StringFromList(j,existingEWvs)+";"
					endif
							//For (j=0;j<ItemsInList(existingEWvs);j+=1)
							//						if (stringMatch(";"+existingXWvs,"*;"+StringFromList(j,existingEWvs)[0,strlen(StringFromList(j,existingEWvs))-strlen(tempstringE)]+tempstringX2+";*") && (stringMatch(";"+existingYWvs,"*;"+StringFromList(j,existingEWvs)[0,strlen(StringFromList(j,existingEWvs))-strlen(tempstringE)]+tempstringY2+";*")))
							//							if(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(j,existingEWvs)[strlen(tempstringE),inf],MatchMeTo[strlen(tempstringX),inf])==0)
														//	result+=StringFromList(j,existingEWvs)+";"
							//							endif
							//						endif
												//endfor
							
							//					For (j=0;j<ItemsInList(existingEWvs);j+=1)
							//						if (stringMatch(";"+existingXWvs,"*;"+tempstringX2+StringFromList(j,existingEWvs)[strlen(tempstringE2),inf]+";*") && stringMatch(";"+existingYWvs,"*;"+tempstringY2+StringFromList(j,existingEWvs)[strlen(tempstringE2),inf]+";*"))
							//							if(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(j,existingEWvs)[strlen(tempstringE2),inf],MatchMeTo[strlen(tempstringX2),inf])==0)
							//								result+=StringFromList(j,existingEWvs)+";"
							//							endif
							//						endif
							//					endfor
							//					if(stringmatch(";"+tempresult, "*;"+tempStringY+";*") && stringmatch(";"+tempresult, "*;"+tempStringX+";*") && (!RequireErrorWvs || stringmatch(";"+tempresult, "*;"+tempStringE+";*")))
							//						if(cmpstr(MatchMeTo,"*")==0 || (cmpstr(stringByKey(tempStringY,XwaveUserDataTypesLookup),MatchMeTo)==0 && stringmatch(";"+tempresult, "*;"+tempStringE+";*")))
							//							result+=tempStringE+";"
							//						endif
							//					endif
				endif
			endfor
			if(strlen(result)<1)
				result="---;"
			endif
		endif
	elseif(UseQRSStructure) 
		tempStringX=IR2P_RemoveDuplicateStrfLst(IR2P_ListOfWavesOfType("q*",tempresult)+IR2P_ListOfWavesOfType("*q",tempresult)+IR2P_ListOfWavesOfType("t_*",tempresult)+IR2P_ListOfWavesOfType("m_*",tempresult)+IR2P_ListOfWavesOfType("d_*",tempresult)+IR2P_ListOfWavesOfType("a*",tempresult))
		tempStringY=IR2P_RemoveDuplicateStrfLst(IR2P_ListOfWavesOfType("r*",tempresult)+IR2P_ListOfWavesOfType("*i",tempresult))
		tempStringE=IR2P_RemoveDuplicateStrfLst(IR2P_ListOfWavesOfType("s*",tempresult)+IR2P_ListOfWavesOfType("*s",tempresult))
		
		//match the names if user wants...
		if(strlen(WaveMatchStr)>0)
			tempStringX = GrepList(tempStringX, IR2C_PrepareMatchString(WaveMatchStr))
			tempStringY = GrepList(tempStringY, IR2C_PrepareMatchString(WaveMatchStr))
			tempStringE = GrepList(tempStringE, IR2C_PrepareMatchString(WaveMatchStr))
		endif
		if (cmpstr(DataType,"Yaxis")==0)
			For (j=0;j<ItemsInList(tempStringY);j+=1)
				tmpstr2 = StringFromList(j,tempStringY)
				//split to handle QRS and qis 
				if(StringMatch(tmpstr2[strlen(tmpstr2)-2,inf], "_i"))
					ts=tmpstr2[0,strlen(tmpstr2)-2]
					tx=tempStringX
					if ((stringMatch(tx,ts+"q;*") || stringMatch(tx,"*;"+ts+"q;*")) && (!RequireErrorWvs || stringMatch(";"+tempStringE,ts+"s;*")||stringMatch(tempStringE,ts+"s;*")))
						if(cmpstr(MatchMeTo,"*")==0 || cmpstr(tmpstr2,MatchMeTo[0,strlen(MatchMeTo)-2]+"i")==0)
							result+=StringFromList(j,tempStringY)+";"
						endif
					endif
				else
					ts=tmpstr2[1,inf]
					tx=tempStringX
					if (((stringMatch(";"+tx,"*q"+ts+";*")||stringMatch(";"+tx,"*t"+ts+";*")||stringMatch(";"+tx,"*d"+ts+";*")||stringMatch(";"+tx,"*m"+ts+";*")) && (!RequireErrorWvs || stringMatch(";"+tempStringE,"*s"+ts+";*"))) || (stringMatch(";"+tx,"*q"+ts+";*")) || (stringMatch(";"+tx,"*"+tmpstr2[0,strlen(tmpstr2)-2]+"q;*") && (stringMatch(";"+tempStringE,"*"+tmpstr2[0,strlen(tmpstr2)-2]+"s;*"))))
						if(cmpstr(MatchMeTo,"*")==0 || cmpstr(tmpstr2,"r"+MatchMeTo[1,inf])==0 || cmpstr(tmpstr2,"r"+MatchMeTo[2,inf])==0)
							result+=StringFromList(j,tempStringY)+";"
						endif
					endif
				endif
			endfor
		elseif(cmpstr(DataType,"Xaxis")==0)
			For (j=0;j<ItemsInList(tempStringX);j+=1)
				tmpstr2 = StringFromList(j,tempStringX)
				if ((stringMatch(";"+tempStringY,"*r"+tmpstr2[1,inf]+";*") && (!RequireErrorWvs || stringMatch(";"+tempStringE,"*s"+tmpstr2[1,inf]+";*"))) || (stringMatch(";"+tempStringY,"*r"+tmpstr2[2,inf]+";*"))||(stringMatch(";"+tempStringY,"*"+tmpstr2[0,strlen(tmpstr2)-2]+"i;*") && (stringMatch(";"+tempStringE,"*"+tmpstr2[0,strlen(tmpstr2)-2]+"s;*"))))
					result+=StringFromList(j,tempStringX)+";"
					if(setControls==0)
						IntDf=StringFromList(j,tempStringY)
						QDf=StringFromList(j,tempStringX)
						EDf=StringFromList(j,tempStringE)
						setControls=1
					endif
				endif
			endfor
		elseif(cmpstr(DataType,"Error")==0)
			For (j=0;j<ItemsInList(tempStringE);j+=1)
				tmpstr2 = StringFromList(j,tempStringE)
				//QRS
				ts=tmpstr2[1,inf]
				tx=tempStringX
				ty=tempStringY
				if ((stringMatch(";"+ty,"*r"+ts+";*") && (stringMatch(";"+tx,"*q"+ts+";*")||stringMatch(";"+tx,"*d"+ts+";*")||stringMatch(";"+tx,"*t"+ts+";*"))||stringMatch(";"+tx,"*m"+ts+";*")) || (stringMatch(";"+ty,"*r"+tmpstr2[2,inf]+";*") && stringMatch(";"+tx,"*q"+tmpstr2[2,inf]+";*")))
					if(cmpstr(MatchMeTo,"*")==0 || cmpstr(tmpstr2,"s"+MatchMeTo[1,inf])==0  || cmpstr(tmpstr2,"s"+MatchMeTo[2,inf])==0)
						result+=StringFromList(j,tempStringE)+";"
					endif
				//thsi needed to be split since QIS data starting with s and ending with _s as error were not trerated right 3/25/2012
				elseif (stringMatch(tempStringY,"*"+tmpstr2[0,strlen(tmpstr2)-2]+"i;*")&& stringMatch(tempStringX,"*"+tmpstr2[0,strlen(tmpstr2)-2]+"q;*"))		//QIS
					if((cmpstr(MatchMeTo,"*")==0) || (cmpstr(tmpstr2,MatchMeTo[0,strlen(MatchMeTo)-2]+"s")==0 ))			///&&(stringmatch(tmpstr2,"*_s")))
						result+=StringFromList(j,tempStringE)+";"
					endif
				endif
			endfor
		endif
	elseif(UseResults)
		if(cmpstr(DataType,"Xaxis")==0)
			for(i=0;i<itemsInList(LocallyAllowedResultsData);i+=1)
				tempStringY=stringFromList(i,LocallyAllowedResultsData)
				tempStringX=stringByKey(tempStringY,ResultsDataTypesLookup)
				if(stringmatch(tempStringX,"*,*"))
					tempRadDia=2
				else
					tempRadDia=1
				endif
				For (j=0;j<ItemsInList(tempStringY);j+=1)
					For(jj=0;jj<itemsInList(tempresult);jj+=1)
						if (stringMatch(StringFromList(jj,tempresult), StringFromList(j,tempStringY)+"_*"))
							Endstr="_"+StringByKey(StringFromList(j,tempStringY), StringFromList(jj,tempresult) , "_" )
							for(ijk=0;ijk<tempRadDia;ijk+=1)
								tempRadDiaStr = stringFromList(ijk,tempStringX+",",",")
								if (stringMatch(";"+tempresult,"*;"+tempRadDiaStr+EndStr+";*"))
									result+=StringFromList(j,tempRadDiaStr)+EndStr+";"
									if(stringmatch(tempStringY,"SLDProfile*"))		//patch for backward compatibility... 
										result+="x-scaling"+";"
									endif
								if(setControls==0)
										IntDf=tempStringY+EndStr
										QDf=tempStringX+EndStr
										EDf="---"
										setControls=1
									endif
								elseif(cmpstr("x-scaling",tempStringX)==0 )
									result+=StringFromList(j,tempStringX)+";"
									if(setControls==0)
										IntDf=tempStringY
										QDf=tempStringX
										EDf="---"
										setControls=1
									endif
								endif
							endfor
						endif
					endfor
				endfor
			endfor
		elseif(cmpstr(DataType,"Yaxis")==0)
			string tt1, tt2, EndStr1
			tt1=""
			tt2=""
			if(cmpstr(MatchMeTo,"*")!=0)
				tmpLookupStr = IR2C_ReverseLookup(ResultsDataTypesLookup,stringFromList(0,MatchMeTo,"_"))
				EndStr1="_"+stringFromList(1,MatchMeTo,"_")	//this is current index _XX
				for(jj=0;jj<ItemsInList(tmpLookupStr);jj+=1)
						tt1=stringFromList(jj,tmpLookupStr)
					if(Stringmatch(tempresult, "*"+tt1+EndStr1+";*"))
						result+=tt1+EndStr1+";"
					endif
				endfor
				
				//				tt1=stringFromList(0,tmpLookupStr)
				//				tt2=stringFromList(1,tmpLookupStr)
				//				EndStr1="_"+stringFromList(1,MatchMeTo,"_")	//this is current index _XX	
				//				if(Stringmatch(tempresult, "*"+tt1+EndStr1+";*"))
				//					result+=tt1+EndStr1+";"
				//				endif
				//				if(strlen(tt2)>0 && Stringmatch(tempresult, "*"+tt2+EndStr1+";*"))
				//					result+=tt2+EndStr1+";"
				//				endif
			else		//this is call from GUI and so we need to figure out the order number ourselves... 
				tmpLookupStr = IR2C_ReverseLookup(ResultsDataTypesLookup,stringFromList(0,QDf,"_"))
				//tt1=stringFromList(0,tmpLookupStr)
				//	tt2=stringFromList(1,tmpLookupStr)
				EndStr1="_"+stringFromList(1,QDf,"_")	//this is current index _XX	
				for(jj=0;jj<ItemsInList(tmpLookupStr);jj+=1)
						tt1=stringFromList(jj,tmpLookupStr)
					if(Stringmatch(tempresult, "*"+tt1+EndStr1+";*"))
						result+=tt1+EndStr1+";"
					endif
				endfor
								
				//				if(Stringmatch(tempresult, "*"+tt1+EndStr1+";*"))
				//					result+=tt1+EndStr1+";"
				//				endif
				//				if(strlen(tt2)>0 &&Stringmatch(tempresult, "*"+tt2+EndStr1+";*"))
				//					result+=tt2+EndStr1+";"
				//				endif
							
				//				for(i=0;i<itemsInList(LocallyAllowedResultsData);i+=1)				//iterates over all known Irena data types
				//					tempStringY=stringFromList(i,LocallyAllowedResultsData)			//one data type (Y axis data) at a time
				//					tempStringX=stringByKey(tempStringY,ResultsDataTypesLookup)	//this is appropriate data x data type 
				//					//print tempStringY, tempStringX
				//					if(stringmatch(tempStringX,"*,*"))
				//						tempRadDia=2
				//					else
				//						tempRadDia=1
				//					endif
				//						For(jj=0;jj<itemsInList(tempresult);jj+=1)						//tempresult contains all waves in the given folder
				//							if (stringMatch(StringFromList(jj,tempresult), tempStringY+"_*"))
				//							//if ((stringMatch(StringFromList(jj,tempresult), tempStringY+"_*") &&(cmpstr(MatchMeTo,"*")==0) || stringMatch(StringFromList(jj,tempresult),tt1+EndStr1) || stringMatch(StringFromList(jj,tempresult),tt2+EndStr1) )	)
				//							//if (stringMatch(StringFromList(jj,tempresult), tempStringY+"_*") &&(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(jj,tempresult),IR2C_ReverseLookup(ResultsDataTypesLookup,stringFromList(0,MatchMeTo,"_"))+"_"+stringFromList(1,MatchMeTo,"_"))==0 ))	
				//								//Ok, this is appriapriate Y data set
				//								Endstr="_"+StringByKey(StringFromList(j,tempStringY), StringFromList(jj,tempresult) , "_" )	//this is current index _XX	
				//								for(ijk=0;ijk<tempRadDia;ijk+=1)
				//									tempRadDiaStr = stringFromList(ijk,tempStringX+",",",")
				//									if (stringMatch(";"+tempresult,"*;"+tempRadDiaStr+EndStr+";*") || cmpstr("x-scaling",tempStringX)==0  )		//Ok, the appropriate X data set exists or x-scaling is allowed...
				//										result+=tempStringY+Endstr+";"
				//									endif
				//								endfor
				//							endif
				//						endfor
				//				endfor
			endif
		elseif(cmpstr(DataType,"Error")==0)
			string MatchMeToY = ""					//holds name of Y axis based on MatchMeTo	
			string debugStr1, debugStr2
			if(strlen(MatchMeTo)>2)				//MatchMeTo may be X axis or Y axis... 
				debugStr2 = stringFromList(0,MatchMeTo,"_")
				debugStr1 = IR2C_ReverseLookup(ResultsDataTypesLookup,debugStr2)		//if MatchMeTo was X axis, this contains Y axis...
				if(GrepString(ResultsDataTypesLookup, debugStr2 ) &&(strlen(debugStr1)>0))
					MatchMeToY = debugStr1
				else
					MatchMeToY = debugStr2
				endif
			endif		//Now MatchmeToY contains Y axis...
			debugStr2=	StringByKey(MatchMeToY,ResultsEDataTypesLookup,":",";")		//contains Matching Error pattern
			result=""
			for(i=0;i<itemsInList(LocallyAllowedResultsData);i+=1)						//iterates over all known Indra data types
				tempStringY=stringFromList(i,LocallyAllowedResultsData)					//one data type (Y axis data) at a time
				tempStringX=stringByKey(tempStringY,ResultsEDataTypesLookup)		//this is appropriate data E data type 
				if(strlen(tempStringX)>2)
					For(jj=0;jj<itemsInList(tempresult);jj+=1)					//tempresult contains all waves in the given folder
						debugStr1=	StringFromList(jj,tempresult)
						if (stringMatch(debugStr1, tempStringX+"_*") &&(cmpstr(MatchMeTo,"*")==0) || (stringMatch(debugStr1,debugStr2+"_"+stringFromList(1,MatchMeTo,"_"))))		//Ok, this is appriapriate E data set		
							if (!GrepString(result, debugStr1))
								result+=debugStr1+";"
							endif
						endif
					endfor
				endif
			endfor
			result += "---;"
		endif
	else
		result=tempresult+";x-scaling;"
	endif
	if(strlen(result)<1)
		result="---"
	endif
	setDataFolder OldDf
	return result
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************************
Function/S IR2C_ReverseLookup(StrToSearch,Keywrd)
	string StrToSearch,Keywrd
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string result, tempstr
	result=""
	variable i
	For(i=0;i<ItemsInList(StrToSearch , ";");i+=1)
		tempStr=StringFromList(i, StrToSearch ,";")
		if(stringmatch(tempStr, "*:"+Keywrd ) || stringmatch(tempStr, "*:*,"+Keywrd ) || stringmatch(tempStr, "*:"+Keywrd+",*" ))
			result+= stringFromList(0,tempStr,":")+";"
		endif
	endfor
	return result
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************************

//popup procedure
Function IR2C_PanelPopupControl(Pa) : PopupMenuControl
	STRUCT WMPopupAction &Pa

	if(Pa.eventCode!=2)
		return 0
	endif
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String ctrlName=Pa.ctrlName
	Variable popNum=Pa.popNum
	String popStr=Pa.popStr

	//part to copy everywhere...	
	DFref oldDf= GetDataFolderDFR()

	string TopPanel=Pa.win	
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations,":",";")
	string LocallyAllowedIndra2Data=StringByKey(TopPanel, ControlAllowedIrenaTypes,"=",">")
	string LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
	SVAR/Z FolderMatchStr=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(TopPanel)+":FolderMatchStr")
	if(!SVAR_Exists(FolderMatchStr))
		string/g $("root:Packages:IrenaControlProcs:"+possiblyQuoteName(TopPanel)+":FolderMatchStr")
		SVAR FolderMatchStr=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(TopPanel)+":FolderMatchStr")
		FolderMatchStr=""
	endif
	SVAR/Z WaveMatchStr=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(TopPanel)+":WaveMatchStr")
	if(!SVAR_Exists(WaveMatchStr))
		string/g $("root:Packages:IrenaControlProcs:"+possiblyQuoteName(TopPanel)+":WaveMatchStr")
		SVAR WaveMatchStr=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(TopPanel)+":WaveMatchStr")
		WaveMatchStr=""
	endif
	setDataFolder $(CntrlLocation)
	variable i

 
	NVAR UseIndra2Structure=$(CntrlLocation+":UseIndra2Data")
	NVAR UseQRSStructure=$(CntrlLocation+":UseQRSData")
	NVAR UseResults=$(CntrlLocation+":UseResults")
	NVAR UseUserDefinedData=$(CntrlLocation+":UseUserDefinedData")
	SVAR Dtf=$(CntrlLocation+":DataFolderName")
	SVAR IntDf=$(CntrlLocation+":IntensityWaveName")
	SVAR QDf=$(CntrlLocation+":QWaveName")
	SVAR EDf=$(CntrlLocation+":ErrorWaveName")
	String infostr = ""
	string oldpopStr=popStr
	///endof common block  	
	//

	if (cmpstr(ctrlName,"QvecDataName")==0)
		QDf=popStr
		//and need to fix IntDf & EDf
		//avoid reseting when using general selection...
		if((UseIndra2Structure || UseQRSStructure || UseResults || UseUserDefinedData))
			IntDf=stringFromList(0,IR2P_ListOfWaves("Yaxis",popStr,TopPanel)+";")		
			EDf=stringFromList(0,IR2P_ListOfWaves("Error",popStr,TopPanel)+";")
			//10/27/2013 - changed lines below, why were the top lines commented out when they work (and the ones below do not?)
			Execute ("PopupMenu IntensityDataName mode=1, value=\""+IntDf +";\"+IR2P_ListOfWaves(\"Yaxis\",\"*\",\""+TopPanel+"\"), win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1, value=\""+EDf +";\"+IR2P_ListOfWaves(\"Error\",\"*\",\""+TopPanel+"\"), win="+TopPanel)
			//1/10/2020 - the above has doubled the first element. This seems to work. 
			//Execute ("PopupMenu IntensityDataName mode=1, value=IR2P_ListOfWaves(\"Yaxis\",\"*\",\""+TopPanel+"\"), win="+TopPanel)
			//Execute ("PopupMenu ErrorDataName mode=1, value=IR2P_ListOfWaves(\"Error\",\"*\",\""+TopPanel+"\"), win="+TopPanel)
			//but at the same time, the selected element can be simply wrong. This needs to be smarter or we will preferably have possibly first line doubled. 
		endif
		//now we need to deal with allowing x-scaling...
		if(cmpstr(popStr,"x-scaling")==0)
			setDataFolder  Dtf
			Wave/Z tempYwv=$(IntDf)
			if(WaveExists(tempYwv))
				Duplicate/O tempYWv, $("X_"+IntDf[0,28])
				Wave tempXWv= $("X_"+IntDf[0,28])
				tempXWv = leftx(tempYWv)+p*deltax(tempYWv)
				QDf="X_"+IntDf[0,28]
			endif
			setDataFolder $(CntrlLocation)	
		endif
	 	//allow user function through hook function...
		infostr = FunctionInfo("IR2_ContrProc_Q_Hook_Proc")
		if (strlen(infostr) >0)
			Execute("IR2_ContrProc_Q_Hook_Proc()")
		endif
		//end of allow user function through hook function
	endif
	if (cmpstr(ctrlName,"IntensityDataName")==0)
		IntDf=popStr
		if(cmpstr(QDf,"x-scaling")==0 || cmpstr(QDf,"X_"+IntDf[0,28])==0 )
			setDataFolder Dtf
			Wave/Z tempYwv=$(IntDf)
			if(WaveExists(tempYwv))
				Duplicate/O tempYWv, $("X_"+IntDf[0,28])
				Wave tempXWv= $("X_"+IntDf)
				tempXWv = leftx(tempYWv)+p*deltax(tempYWv)
				QDf="X_"+IntDf[0,28]
			endif
			setDataFolder $(CntrlLocation)	
			//avoid reseting when using general selection...
		elseif((UseIndra2Structure || UseQRSStructure || UseResults || UseUserDefinedData))
			EDf=stringFromList(0,IR2P_ListOfWaves("Error",popStr,TopPanel)+";")
			Execute ("PopupMenu ErrorDataName mode=1, value=\""+EDf +";\"+IR2P_ListOfWaves(\"Error\",\"*\",\""+TopPanel+"\"), win="+TopPanel)
		endif
		//now we need to deal with allowing x-scaling...
	 	//allow user function through hook function...
		infostr = FunctionInfo("IR2_ContrProc_R_Hook_Proc")
		if (strlen(infostr) >0)
			Execute("IR2_ContrProc_R_Hook_Proc()")
		endif
		//end of allow user function through hook function
	endif
	if (cmpstr(ctrlName,"ErrorDataName")==0)
		EDf=popStr
	 	//allow user function through hook function...
		infostr = FunctionInfo("IR2_ContrProc_E_Hook_Proc")
		if (strlen(infostr) >0)
			Execute("IR2_ContrProc_E_Hook_Proc()")
		endif
		//end of allow user function through hook function
	endif

	if (cmpstr(ctrlName,"SelectDataFolder")==0)
		//attempt to fix for same named folders
		SVAR/Z RealLongListOfFolder = $(CntrlLocation+":RealLongListOfFolder")
		if(!SVAR_Exists(RealLongListOfFolder))
			Abort "Stale control procedures. Please, reopen the panel for the tool you are trying to use and try operating once manually. If persists, send this Igor experiment to Jan Ilavsky, ilavsky@aps.anl.gov"
		endif
		//may be we need to know what was the last names for Int, Q, error???
		string OldIntname=IntDf
		string OldQname=QDf
		string OldEname=EDf
		//Now lets move on... 
		if(popNum>=0)
			//let's try to look up using popNum
			//but we need to find how many paths with "-----------" are here before the popNum
			//variable NumPathLines=0
			string ShortList
			SVAR/Z ShortListOfFolders= $(CntrlLocation+":ShortListOfFolders")
			if(SVAR_Exists(ShortListOfFolders))
				ShortList=ShortListOfFolders
			else
				ShortList=IR2P_GenStringOfFolders(winNm=TopPanel)
			endif
			popStr=StringFromList(popNum-2, ShortListOfFolders)	//one for "---" and one for 0 vs 1 based info. 
		else
			//fix the short name of the folder... - old method which uses name to keep compatible with other code... 
			oldpopStr=popStr
			string tempStr5=IR2C_PrepareMatchString(popStr)
			popStr = GrepList(RealLongListOfFolder, tempStr5,0  , ";" )
			if(ItemsInList(popStr , ";")>1)
				For(i=0;i<ItemsInList(popStr , ";");i+=1)
					tempStr5 = StringFromList(i,popStr,";")
					if(stringmatch(oldpopStr,StringFromList(ItemsInList(tempStr5,":")-1,tempStr5,":")))
						popStr=tempStr5
						//break
					endif
				endfor
			endif
			popStr=RemoveEnding(popStr, ";")
		endif
		// the 2 to subtract here... One of for "---" and second because popNum is 1 based, while StringFromList is 0 based.  
		String tempDf=GetDataFolder(1)
		setDataFolder root:Packages:IrenaControlProcs
		setDataFolder $(TopPanel)
		string TopPanelFixed=PossiblyQuoteName(TopPanel)			//this seems to be problem later, wonder why do I have it here... 
		string/g TempYList, tempXList, tempEList
		SVAR TempYList 
		SVAR TempXList 
		SVAR TempEList 
		setDataFolder tempDF
		Dtf=popStr
//		Execute ("PopupMenu IntensityDataName noproc, win="+TopPanel)
//		Execute ("PopupMenu QvecDataName noproc, win="+TopPanel)
//		Execute ("PopupMenu ErrorDataName noproc, win="+TopPanel)
		if(stringmatch(oldpopStr,"---"))
			QDf="---"
			IntDf="---"
			EDf="---"
			TempXList="---"
			TempYList="---"
			TempEList="---"
			Execute ("PopupMenu IntensityDataName mode=1,value= #\"\\\"---;\\\"+root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			Execute ("PopupMenu QvecDataName mode=1,value= #\"\\\"---;\\\"+root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempXList\", win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1,value= #\"\\\"---;\\\"+root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
			return 0
		endif
		TempXList=IR2P_ListOfWaves("Xaxis","*",TopPanel)
		QDf=stringFromList(0,TempXlist)
		TempYlist=IR2P_ListOfWaves("Yaxis","*",TopPanel)
		IntDf=stringFromList(0,TempYlist)
		TempEList=IR2P_ListOfWaves("Error","*",TopPanel)
		EDf=stringFromList(0,TempElist)
		if(strlen(WaveMatchStr)>0 && strlen(TempXList)>5&&!UseIndra2Structure)		
			TempXList=GrepList(TempXList,IR2C_PrepareMatchString(WaveMatchStr))	
			if(strlen(TempXList)<1)
				TempXList="---;"	
			endif
		endif
		//seems we need to remove from tempXlist duplicates... 
		//TempXList=SortList(TempXList,";", 32)
		TempXList = IR2P_RemoveDUplicatesFromList(TempXList)
		if (UseIndra2Structure)
			QDf=stringFromList(0,TempXlist)
			IntDf=stringFromList(0,TempYlist)
			EDf=stringFromList(0,TempElist)
			Execute ("PopupMenu IntensityDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			Execute ("PopupMenu QvecDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempXList\", win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
		elseif(UseQRSStructure)
			QDf=stringFromList(0,TempXlist)
			Execute ("PopupMenu QvecDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempXList\", win="+TopPanel)
			IntDf=stringFromList(0,IR2P_ListOfWaves("Yaxis",QDf,TopPanel)+";")		
			EDf=stringFromList(0,IR2P_ListOfWaves("Error",QDf,TopPanel)+";")
			//workaround, when nothing is found for X axis but somehtign is found for one of the other axis...
			if(stringmatch(QDf,"---"))
				TempYlist = "---"
				tempEList="---"
			endif
			Execute ("PopupMenu IntensityDataName mode="+num2str(WhichListItem(IntDf, TempYlist, ";")+1)+",value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode="+num2str(WhichListItem(EDf, tempEList, ";")+1)+",value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
		elseif(UseResults)
			Execute ("PopupMenu IntensityDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			Execute ("PopupMenu QvecDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempXList\", win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
			//needs to be done in opposite order, seems to fail due to Execute calling PopProc
			QDf=stringFromList(0,TempXlist)
			IntDf=stringFromList(0,TempYlist)
			EDf=stringFromList(0,TempElist)
		elseif(UseUserDefinedData)
			Execute ("PopupMenu IntensityDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			Execute ("PopupMenu QvecDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempXList\", win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
			//needs to be done in opposite order, seems to fail due to Execute calling PopProc
			QDf=stringFromList(0,TempXlist)
			IntDf=stringFromList(0,TempYlist)
			EDf=stringFromList(0,TempElist)
		else
			//Dale would like to remember last selected wavenames... It may be possible here.  
				//		string OldIntname=IntDf
				//		string OldQname=QDf
				//		string OldEname=EDf
			if(StringMatch(TempYlist, "*"+OldIntname+"*" ))
				IntDf=OldIntname
				Execute ("PopupMenu IntensityDataName mode="+num2str(WhichListItem(IntDf, TempYlist, ";")+1)+",value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			else
				IntDf="---"
				Execute ("PopupMenu IntensityDataName mode=1,value= #\"\\\"---;\\\"+root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			endif
			if(StringMatch(TempXlist, "*"+OldQname+"*" ))
				QDf=OldQname
				Execute ("PopupMenu QvecDataName mode="+num2str(WhichListItem(QDf, tempEList, ";")+1)+",value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempXList\", win="+TopPanel)
			else
				QDf="---"
				Execute ("PopupMenu QvecDataName mode=1,value= #\"\\\"---;\\\"+root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempXList\", win="+TopPanel)
			endif
			if(StringMatch(TempElist, "*"+OldEname+"*" ))
				EDf=OldQname
				Execute ("PopupMenu ErrorDataName mode="+num2str(WhichListItem(QDf, tempEList, ";")+1)+",value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
			else
				EDf="---"
				Execute ("PopupMenu ErrorDataName mode=1,value= #\"\\\"---;\\\"+root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
			endif

		endif

	 	//allow user function through hook function...
		infostr = FunctionInfo("IR2_ContrProc_F_Hook_Proc")
		if (strlen(infostr) >0)
			Execute("IR2_ContrProc_F_Hook_Proc()")
		endif
		//end of allow user function through hook function
	endif
	setDataFolder oldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
Function/T IR2P_RemoveDuplicatesFromList(Listin)
	string ListIn
	string ListOut="", tmpStr
	variable i
	For(i=0;i<ItemsInList(ListIn);i+=1)
		tmpStr = stringFromList(i, ListIn)
		if(! stringmatch(ListOut, "*"+tmpStr+";*") )
			ListOut += tmpStr+";"
		endif
	endfor
	return ListOut
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2P_FindFolderWithWaveTypesWV(startDF, levels, WaveTypes, LongShortType, ResultingWave)
        String startDF, WaveTypes                  // startDF requires trailing colon.
        Variable levels, LongShortType		//set 1 for long type and 0 for short type return
        wave/T ResultingWave
        			 
		  //IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
        String dfSave
        String list = "", templist, tempWvName
        variable i, skipRest
        
       	dfSave = GetDataFolder(1)
     	 	//DFREF startDFRef = $(startDF)
     	 	setDataFolder startDF
     		//templist = IN2G_ConvertDataDirToList(DataFolderDir(2,startDFRef))
     		templist = IN2G_ConvertDataDirToList(DataFolderDir(2))
     		string ListOfRWaves=GrepList(templist,WaveTypes)
	 		if (strlen(ListOfRWaves)>0)
	 			if(!stringMatch(ListOfRWaves,"*R_Int;*"))
					if (LongShortType)
			      		Redimension /N=(numpnts(ResultingWave)+1) ResultingWave
			      		ResultingWave[numpnts(ResultingWave)-1]=startDF
			     	else
			      		Redimension /N=(numpnts(ResultingWave)+1) ResultingWave
			      		ResultingWave[numpnts(ResultingWave)-1]=GetDataFolder(0)
		     		endif
		     	endif
      	endif
        levels -= 1
        if (levels <= 0)
                return 1
        endif
        
      String subDF
      Variable index = 0, npnts
   	Make/Free/T/N=0 FoldersToScanWv
  	   //variable NumOfFolders= CountObjectsDFR(startDFRef, 4)
   	variable NumOfFolders= CountObjects("", 4)
 	   for(i=0;i<NumOfFolders;i+=1)
  	   	npnts=numpnts(FoldersToScanWv)
  	  		redimension/N=(npnts+1) FoldersToScanWv
  	  		//FoldersToScanWv[npnts] = GetIndexedObjNameDFR(startDFRef, 4, i )
  	  		FoldersToScanWv[npnts] = GetIndexedObjName("", 4, i )
  	   endfor
  	  
      String temp
        For(i=0;i<NumOfFolders;i+=1)
               //temp = PossiblyQuoteName(StringFromList(i,FoldersToScan))     	// Name of next data folder.
               temp = PossiblyQuoteName(FoldersToScanWv[i])     	// Name of next data folder.
     	         subDF = startDF + temp + ":"
		 		if(!stringmatch(subDF, "*:Packages*" ))		
           		 IR2P_FindFolderWithWaveTypesWV(subDF, levels, WaveTypes, LongShortType,ResultingWave)       	// Recurse.
     	 		endif
        endfor
        setDataFolder dfSave
        return 1
End

//**********************************************************************************************
//**********************************************************************************************

Function/S IR2C_ReturnKnownToolResults(ToolName, TopPanel)
	string ToolName, TopPanel
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string KnownToolResults=""

	SVAR AllKnownToolsResults= root:Packages:IrenaControlProcs:AllKnownToolsResults
	string LocallyAllowedResultsData
	if(strlen(TopPanel)>0)		//this is called from IR2_ControlsCntrlProc [package and not form old code]
		SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
		LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
	else
		LocallyAllowedResultsData=""
	endif
	// "Unified Fit;Size Distribution;Modeling;Small-angle diffraction;Analytical models;Fractals;PDDF;Reflectivity;"
	SVAR ResultsDataTypesLookup= root:Packages:IrenaControlProcs:ResultsDataTypesLookup
	string ListOfLookups=""
	if(stringmatch(ToolName,"Size Distribution"))
		ListOfLookups = GrepList(ResultsDataTypesLookup, "^Sizes",0, ";" )
	elseif(stringmatch(ToolName,"Unified Fit"))
		ListOfLookups = GrepList(ResultsDataTypesLookup, "^Uni",0, ";" )
	elseif(stringmatch(ToolName,"Modeling I"))
		ListOfLookups = GrepList(ResultsDataTypesLookup, "^Modeling",0, ";" )
	elseif(stringmatch(ToolName,"Fractals"))
		ListOfLookups = GrepList(ResultsDataTypesLookup, "Fract",0, ";" )
	elseif(stringmatch(ToolName,"Small-angle diffraction"))
		ListOfLookups = GrepList(ResultsDataTypesLookup, "^SAD",0, ";" )
	elseif(stringmatch(ToolName,"Analytical models"))
		ListOfLookups = GrepList(ResultsDataTypesLookup, "^Analytical",0, ";" )
	elseif(stringmatch(ToolName,"PDDF"))
		ListOfLookups = GrepList(ResultsDataTypesLookup, "^PDDF",0, ";" )
	elseif(stringmatch(ToolName,"Reflectivity"))
		ListOfLookups = GrepList(ResultsDataTypesLookup, "^(Refl|SLD)",0, ";" )
	elseif(stringmatch(ToolName,"Modeling"))
		ListOfLookups = GrepList(ResultsDataTypesLookup, "ModelLSQF",0, ";" )
	elseif(stringmatch(ToolName,"System Specific Models"))
		ListOfLookups = GrepList(ResultsDataTypesLookup, "^SysSpecModel",0, ";" )
	elseif(stringmatch(ToolName,"Guinier-Porod"))
		ListOfLookups = GrepList(ResultsDataTypesLookup, "GuinierPorod",0, ";" )
	elseif(stringmatch(ToolName,"Simple Fits"))
		ListOfLookups = GrepList(ResultsDataTypesLookup, "^SimFit",0, ";" )
		ListOfLookups += GrepList(ResultsDataTypesLookup, "^Corr1D",0, ";" ) //Corr1DK;Corr1DGammaA;Corr1DGammaI
	elseif(stringmatch(ToolName,"Evaluate Size Dist"))
		ListOfLookups = GrepList(ResultsDataTypesLookup, "^(Cumulative|MIP)",0, ";" )
		//ListOfLookups += GrepList(ResultsDataTypesLookup, "^CumulativeSfcArea",0, ";" )
		//ListOfLookups += GrepList(ResultsDataTypesLookup, "^MIPVolume",0, ";" )
	else
		ListOfLookups = ""
	endif

	variable i, j
	For(i=0;i<ItemsInList(ListOfLookups, ";");i+=1)	//we have found some stuff
		KnownToolResults += stringFromList(0,stringFromList(i,ListOfLookups,";"),":")+";"
	endfor
	string TmpList="" , TmpName=""
	if(strlen(LocallyAllowedResultsData)>0)			//need to limit to only predefined smaller number of stuff...
		For(i=0;i<ItemsInList(LocallyAllowedResultsData, ";");i+=1)	//we have found some stuff
			TmpName = stringFromList(i,LocallyAllowedResultsData,";")
			TmpList += GrepList(KnownToolResults, TmpName,0, ";")
		endfor
		KnownToolResults = TmpList
	endif
	
	
	return KnownToolResults
end
//**********************************************************************************************
//**********************************************************************************************

Function/S IR2C_PrepareMatchString(StrIn)
	string StrIn
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string StrOut = ""
	variable ic
	for (ic=0;ic<strlen(StrIn);ic+=1)
		StrOut = StrOut + IR2C_EscapeCharTable(StrIn[ic])
	endfor
	return StrOut
end

// build your escape code table here

Function/S IR2C_EscapeCharTable(cstr)
	string cstr
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string estr = ""
	strswitch(cstr)
		case "(":
			estr = "\\"
			break
		case ")":
			estr = "\\"
			break
		case "{":
			estr = "\\"
			break
		case "}":
			estr = "\\"
			break
		case "%":
			estr = "\\"
			break
		case "#":
			estr = "\\"
			break
		case "^":
			estr = "\\"
			break
		case "$":
			estr = "\\"
			break
		case "?":
			estr = "\\"
			break
		case "|":
			estr = "\\"
			break
		case "&":
			estr = "\\"
			break
		case "=":
			estr = "\\"
			break
		case "-":
			estr = "\\"
			break
		case ".":
			estr = "\\"
			break
		default:
			break
	endswitch
	
	return (estr + cstr)
end
//**********************************************************************************************
//**********************************************************************************************

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

//Select path, populate Listbox with files with input extension and allow one or more files selection. 
//Include Match name string and make this universally usable as data selection tool so we do not have to this again.
//this is used by Import ASCII and Nexus/CanSAS data
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3C_AddDataControls(PckgPathName, PckgDataFolder, PanelWindowName,DefaultExtensionStr, DefaultMatchStr,DefaultSortString, DoubleCLickFnctName)
	string PckgPathName, PckgDataFolder, PanelWindowName,DefaultExtensionStr, DefaultMatchStr, DefaultSortString, DoubleCLickFnctName
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable DontAdd =0 
	if(stringmatch(PanelWindowName, "*#*" ))	//# so expect subwindow... Limit only to first child here, else is not allowed for now...
			//first check for the main window existance...
		string MainPnlWinName=StringFromList(0, PanelWindowName , "#")
		string ChildPnlWinName=StringFromList(1, PanelWindowName , "#")
					//check on existence here...
		DoWindow $(MainPnlWinName)
		if(!V_Flag)
			abort //widnow does not exist, nothing to do...
		endif
		//OK, window exists, now check if it has the other in the childlist
		if(!stringmatch(ChildWindowList(MainPnlWinName), "*"+ChildPnlWinName+"*" ))
			abort //that child does nto exist!
		endif	
	else		//no # no subvwindow. Use old code...
		DoWindow $(PanelWindowName)
		if(!V_Flag)
			abort //widnow does not exist, nothing to do...
		endif
	endif
	IR3C_InitControls(PckgPathName, PckgDataFolder, PanelWindowName,DefaultExtensionStr, DefaultMatchStr,DefaultSortString, DoubleCLickFnctName)
	IR3C_AddControlsToWndw(PckgPathName, PckgDataFolder, PanelWindowName,DefaultExtensionStr, DefaultMatchStr,DefaultSortString, DoubleCLickFnctName)
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3C_AddControlsToWndw(PckgPathName, PckgDataFolder, PanelWindowName,DefaultExtensionStr, DefaultMatchStr, DefaultSortString, DoubleCLickFnctName)
	string PckgPathName, PckgDataFolder, PanelWindowName,DefaultExtensionStr, DefaultMatchStr, DefaultSortString, DoubleCLickFnctName

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR ControlProcsLocations=root:Packages:IrenaListboxProcs:ControlProcsLocations
	SVAR ControlPckgPathName=root:Packages:IrenaListboxProcs:ControlPckgPathName
	SVAR ControlPanelWindowName=root:Packages:IrenaListboxProcs:ControlPanelWindowName
	SVAR SortOptionsString=root:Packages:IrenaListboxProcs:SortOptionsString
//	SVAR ControlMatchString=root:Packages:IrenaListboxProcs:ControlMatchString

	string CntrlLocation="root:Packages:"+PckgDataFolder 
	setDataFolder $(CntrlLocation)
	SVAR DataSelSortString = $(CntrlLocation+":DataSelSortString")
	string CurSortString = DataSelSortString
	string TopPanel=PanelWindowName
	
	Button SelectDataPath,pos={99,50},size={130,20}, proc=IR3C_ButtonProc,title="Select data path"
	Button SelectDataPath,help={"Select data path to the data"}
	SetVariable DataPathString,pos={2,72},size={415,19},title="Data path :", noedit=1
	SetVariable DataPathString,help={"This is currently selected data path where Igor looks for the data"}
	SetVariable DataPathString,limits={-Inf,Inf,0},value= $(CntrlLocation+":DataSelPathString")
	SetVariable DataPathString disable=0,frame=0, styledText=1, valueColor=(1,4,52428)
	SetVariable NameMatchString,pos={5,91},size={240,19},proc=IR3C_SetVarProc,title="Match name (string):"
	SetVariable NameMatchString,help={"Insert RegEx to select only data with matching name (uses grep)"}
	SetVariable NameMatchString,value= $(CntrlLocation+":DataSelListBoxMatchString")
	SetVariable DataExtensionString,pos={260,91},size={150,19},proc=IR3C_SetVarProc,title="Data extension:"
	SetVariable DataExtensionString,help={"Insert extension string to mask data of only some type (dat, txt, ...)"}
	SetVariable DataExtensionString,value= $(CntrlLocation+":DataSelListBoxExtString")
	Button SelectAll,pos={5,112},size={110,15}, proc=IR3C_ButtonProc,title="Select all"
	Button SelectAll,help={"Select all data in the listbox"}
	Button DeSelectAll,pos={145,112},size={110,15}, proc=IR3C_ButtonProc,title="Deselect all"
	Button DeSelectAll,help={"DeSelect all data in the listbox"}
	PopupMenu SortOptionString,pos={280,112},size={160,21},proc=IR3C_PopMenuProc,title="Sort:", help={"Select how to sort the data"}
	PopupMenu SortOptionString,mode=1,popvalue=CurSortString, value=#"root:Packages:IrenaListboxProcs:SortOptionsString"
	TitleBox Info1PanelProc title="\Zr110List of available files",pos={10,128},frame=0,fstyle=1, fixedSize=1,size={220,20},fColor=(0,0,52224)
	ListBox ListOfAvailableData,pos={5,147},size={230,280}
	ListBox ListOfAvailableData,help={"Select files from this location you want to import"}
	ListBox ListOfAvailableData,listWave=$(CntrlLocation+":WaveOfFiles")
	ListBox ListOfAvailableData,selWave=$(CntrlLocation+":WaveOfSelections")
	ListBox ListOfAvailableData,mode= 9, proc=IR3C_ListBoxProc
	//and update content, if possible... 
	IR3C_UpdateListOfFilesInWvs(PanelWindowName)
	IR3C_SortListOfFilesInWvs(PanelWindowName)	
end	
//**********************************************************************************************************
//**********************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR3C_ListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
      //Prevent Igor from invoking this before we are done with instance 1
      lba.blockReentry = 1
	string TopPanel=WinName(0, 64)
	Variable row = lba.row
	Variable col = lba.col
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave
	Variable i
	string items=""
	SVAR 	SortOptionsString = root:Packages:IrenaListboxProcs:SortOptionsString
												//="Sort;Inv_Sort;Sort _XYZ;Inv Sort _XYZ;"
	SVAR ControlProcsLocations=root:Packages:IrenaListboxProcs:ControlProcsLocations
	SVAR ControlPckgPathName=root:Packages:IrenaListboxProcs:ControlPckgPathName
	SVAR ControlDoubleCLickFnctName=root:Packages:IrenaListboxProcs:ControlDoubleCLickFnctName
	
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations,"=",";")
	string CntrlPathName=StringByKey(TopPanel, ControlPckgPathName,"=",";")
	string DoubleCLickFnctName=StringByKey(TopPanel, ControlDoubleCLickFnctName,"=",";")

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
			Wave/T WaveOfFiles      	= $(CntrlLocation+":WaveOfFiles")
			Wave WaveOfSelections 	= $(CntrlLocation+":WaveOfSelections")
			SVAR DataSelSortString = $(CntrlLocation+":DataSelSortString")
			SVAR DataSelListBoxMatchString = $(CntrlLocation+":DataSelListBoxMatchString")
			variable oldSets

			if (lba.eventMod & 0x10)	// rightclick
				// list of items for PopupContextualMenu
				items = "Refresh Content;Select All;Deselect All;Match \"Blank\";Match \"Empty\";Hide \"Blank\";Hide \"Empty\";Remove Match or Hide;"+SortOptionsString	
				PopupContextualMenu items
				// V_flag is index of user selected item
				switch (V_flag)
					case 1:	// "Refresh Content"
						//refresh content, but here it will depend where we call it from.
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						 oldSets=V_startRow
						IR3C_UpdateListOfFilesInWvs(TopPanel)
						IR3C_SortListOfFilesInWvs(TopPanel)	
						ListBox ListOfAvailableData,win=$(TopPanel),row=V_startRow
						break;
					case 2:	// "Select All;"
					      selWave = 1
						break;
					case 3:	// "Deselect All"
					      selWave = 0
						break;
					case 4:	//M<atch Blank
						DataSelListBoxMatchString="(?i)Blank"
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						 oldSets=V_startRow
						IR3C_UpdateListOfFilesInWvs(TopPanel)
						IR3C_SortListOfFilesInWvs(TopPanel)	
						ListBox ListOfAvailableData,win=$(TopPanel),row=V_startRow
						break;
					case 5:	//Match EMpty
						DataSelListBoxMatchString="(?i)Empty"
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						 oldSets=V_startRow
						IR3C_UpdateListOfFilesInWvs(TopPanel)
						IR3C_SortListOfFilesInWvs(TopPanel)	
						ListBox ListOfAvailableData,win=$(TopPanel),row=V_startRow
						break;
					case 6:	//hide blank
						DataSelListBoxMatchString="^((?!(?i)Blank).)*$"
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						 oldSets=V_startRow
						IR3C_UpdateListOfFilesInWvs(TopPanel)
						IR3C_SortListOfFilesInWvs(TopPanel)	
						ListBox ListOfAvailableData,win=$(TopPanel),row=V_startRow
						break;
					case 7:	//hide empty
						DataSelListBoxMatchString="^((?!(?i)Empty).)*$"
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						 oldSets=V_startRow
						IR3C_UpdateListOfFilesInWvs(TopPanel)
						IR3C_SortListOfFilesInWvs(TopPanel)	
						ListBox ListOfAvailableData,win=$(TopPanel),row=V_startRow
						break;
					case 8:	//remove Match
						DataSelListBoxMatchString=""
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						 oldSets=V_startRow
						IR3C_UpdateListOfFilesInWvs(TopPanel)
						IR3C_SortListOfFilesInWvs(TopPanel)	
						ListBox ListOfAvailableData,win=$(TopPanel),row=V_startRow
						break;

					default :	// "Sort"
						DataSelSortString = StringFromList(V_flag-1, items)
						PopupMenu SortOptionString,win=$(TopPanel), mode=1,popvalue=DataSelSortString
						IR3C_SortListOfFilesInWvs(TopPanel)	
						break;
					endswitch
				endif
			break
		case 3: // double click
			if(strlen(DoubleCLickFnctName)>0)
				Execute(DoubleCLickFnctName+"()")
			endif
			break
		case 4: // cell selection
		case 5: // cell selection plus shift key
			break
		case 6: // begin edit
			break
		case 7: // finish edit
			break
		case 13: // checkbox clicked (Igor 6.2 or later)
			break
	endswitch

	return 0
End
//************************************************************************************************************
//************************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3C_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string TopPanel=WinName(0, 64)

	if (Cmpstr(ctrlName,"SortOptionString")==0)
		SVAR ControlProcsLocations=root:Packages:IrenaListboxProcs:ControlProcsLocations
		string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations,"=",";")
		SVAR DataSelSortString = $(CntrlLocation+":DataSelSortString")
		DataSelSortString = popStr
		IR3C_SortListOfFilesInWvs(TopPanel)
	endif
End
//**********************************************************************************************************
//**********************************************************************************************************
//************************************************************************************************************
Function IR3C_SortListOfFilesInWvs(TopPanel)
	string TopPanel
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR ControlProcsLocations=root:Packages:IrenaListboxProcs:ControlProcsLocations
	SVAR ControlPckgPathName=root:Packages:IrenaListboxProcs:ControlPckgPathName
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations,"=",";")
	string CntrlPathName=StringByKey(TopPanel, ControlPckgPathName,"=",";")

	Wave/T WaveOfFiles      	= $(CntrlLocation+":WaveOfFiles")
	Wave WaveOfSelections 	= $(CntrlLocation+":WaveOfSelections")
	SVAR DataSelSortString = $(CntrlLocation+":DataSelSortString")
	variable i
	if(numpnts(WaveOfFiles)<2)
		return 0
	endif
//	string/g SortOptionsString="Sort;Inv_Sort;Sort _XYZ;Inv Sort _XYZ;"
	Duplicate/Free WaveOfSelections, TempWv
	if(StringMatch(DataSelSortString, "Sort" ))
		Sort WaveOfFiles, WaveOfFiles, WaveOfSelections
	elseif(StringMatch(DataSelSortString, "Inv_Sort" ))
		Sort/R WaveOfFiles, WaveOfFiles, WaveOfSelections
	elseif(StringMatch(DataSelSortString, "Sort _XYZ" ))
			//For(i=0;i<numpnts(TempWv);i+=1)
		TempWv = IN2G_FindNumIndxForSort(WaveOfFiles[p])
			//TempWv[i] = str2num(StringFromList(ItemsInList(WaveOfFiles[i]  , "_")-1, WaveOfFiles[i]  , "_"))
			//endfor
		Sort TempWv, WaveOfFiles, WaveOfSelections
	elseif(StringMatch(DataSelSortString, "Inv Sort _XYZ" ))
			//For(i=0;i<numpnts(TempWv);i+=1)
		TempWv = IN2G_FindNumIndxForSort(WaveOfFiles[p])
			//TempWv[i] = str2num(StringFromList(ItemsInList(WaveOfFiles[i]  , "_")-1, WaveOfFiles[i]  , "_"))
			//endfor
		Sort/R TempWv, WaveOfFiles, WaveOfSelections
	elseif(StringMatch(DataSelSortString, "Sort _XYZ_xyz" ))			//sort by XYZ first and then by xyz
		For(i=0;i<numpnts(TempWv);i+=1)
			TempWv[i] = str2num(StringFromList(ItemsInList(WaveOfFiles[i]  , "_")-2, WaveOfFiles[i]  , "_"))*1e6+str2num(StringFromList(ItemsInList(WaveOfFiles[i]  , "_")-1, WaveOfFiles[i]  , "_"))
		endfor
		Sort TempWv, WaveOfFiles, WaveOfSelections
	endif
	
end
//************************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3C_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	Variable dval = sva.dval
	String sval = sva.sval
	string ctrlName = sva.ctrlName
	string TopPanel=sva.win

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if (cmpstr(ctrlName,"NameMatchString")==0)
		IR3C_UpdateListOfFilesInWvs(TopPanel)
		IR3C_SortListOfFilesInWvs(TopPanel)
	endif
	if (cmpstr(ctrlName,"DataExtensionString")==0)
		IR3C_UpdateListOfFilesInWvs(TopPanel)
		IR3C_SortListOfFilesInWvs(TopPanel)
	endif
	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************


Function IR3C_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	switch( ba.eventCode )
		case 2: // mouse up
			string TopPanel=ba.win
			// click code here
			if(stringMatch(ba.ctrlName,"SelectDataPath"))
				IR3C_SelectDataPath(TopPanel)	
				IR3C_UpdateListOfFilesInWvs(TopPanel)
				IR3C_SortListOfFilesInWvs(TopPanel)
			endif
			if(stringMatch(ba.ctrlName,"SelectAll"))
				IR3C_SelectDeselectAll(TopPanel,1)	
			endif
			if(stringMatch(ba.ctrlName,"DeSelectAll"))
				IR3C_SelectDeselectAll(TopPanel,0)	
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************
//************************************************************************************************************

Function IR3C_SelectDataPath(TopPanel)
	string TopPanel
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR ControlProcsLocations=root:Packages:IrenaListboxProcs:ControlProcsLocations
	SVAR ControlPckgPathName=root:Packages:IrenaListboxProcs:ControlPckgPathName
	SVAR ControlPanelWindowName=root:Packages:IrenaListboxProcs:ControlPanelWindowName
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations,"=",";")
	string CntrlPathName=StringByKey(TopPanel, ControlPckgPathName,"=",";")
	//check if we are running on USAXS computers
	GetFileFOlderInfo/Q/Z "Z:USAXS_data:"
	if(V_isFolder)
		//OK, this computer has Z:USAXS_data 
		PathInfo $(CntrlPathName)
		if(V_flag==0)
			NewPath/Q  $(CntrlPathName), "Z:USAXS_data:"
			pathinfo/S $(CntrlPathName)
		endif
	endif
	
	NewPath /M="Select path to data" /O $(CntrlPathName)
	if (V_Flag!=0)
		abort
	endif 
	PathInfo $(CntrlPathName)
	string tmpStr= S_Path
	SVAR DataSelPathString=$(CntrlLocation+":DataSelPathString")
	
	//figure out the size of the string we can use...
	variable Width = FontSizeStringWidth(ReplaceString("'",IN2G_LkUpDfltStr("DefaultFontType"),""), str2num(IN2G_LkUpDfltVar("DefaultFontSize")),0,S_Path)
	variable ratio = (415 - FontSizeStringWidth(ReplaceString("'",IN2G_LkUpDfltStr("DefaultFontType"),""), str2num(IN2G_LkUpDfltVar("DefaultFontSize")),0,"Data Path :"))/width
	if(ratio<0.8)
		DataSelPathString = "\JR\Zr080"+S_Path
	elseif(ratio>0.8 && ratio<0.9)
		DataSelPathString = "\JR\Zr080"+S_Path
	elseif(ratio>0.9 && ratio<1)
		DataSelPathString = "\JR\Zr090"+S_Path
	elseif(ratio>1 && ratio<1.1)
		DataSelPathString = "\JR"+S_Path
	elseif(ratio>1.1 && ratio<1.2)
		DataSelPathString = "\JR\Zr110"+S_Path
	elseif(ratio>1.2 && ratio<1.3)
		DataSelPathString = "\JR\Zr120"+S_Path
	elseif(ratio>1.3 && ratio<1.4)
		DataSelPathString = "\JR\Zr130"+S_Path
	elseif(ratio>1.4 && ratio<1.5)
		DataSelPathString = "\JR\Zr130"+S_Path
	elseif(ratio>1.5)
		DataSelPathString = "\JR\Zr130"+S_Path
	endif
	
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR3C_UpdateListOfFilesInWvs(TopPanel)
	string TopPanel
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR ControlProcsLocations=root:Packages:IrenaListboxProcs:ControlProcsLocations
	SVAR ControlPckgPathName=root:Packages:IrenaListboxProcs:ControlPckgPathName
	SVAR ControlPanelWindowName=root:Packages:IrenaListboxProcs:ControlPanelWindowName
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations,"=",";")
	string CntrlPathName=StringByKey(TopPanel, ControlPckgPathName,"=",";")

	SVAR NameMatchString 		= $(CntrlLocation+":DataSelListBoxMatchString")
	SVAR DataExtension  		= $(CntrlLocation+":DataSelListBoxExtString")
	Wave/T WaveOfFiles      	= $(CntrlLocation+":WaveOfFiles")
	Wave WaveOfSelections 	= $(CntrlLocation+":WaveOfSelections")
	string ListOfAllFiles
	string LocalDataExtension
	variable i, imax
	LocalDataExtension = DataExtension
	if (cmpstr(LocalDataExtension[0],".")!=0)
		LocalDataExtension = "."+LocalDataExtension
	endif
	PathInfo $(CntrlPathName)
	if(V_Flag)
		if (strlen(LocalDataExtension)<=1)
			ListOfAllFiles = IndexedFile($(CntrlPathName),-1,"????")
		else		
			ListOfAllFiles = IndexedFile($(CntrlPathName),-1,LocalDataExtension)
		endif
		if(strlen(NameMatchString)>0)
			ListOfAllFiles = GrepList(ListOfAllFiles, NameMatchString )
		endif
		//remove Invisible Mac files, .DS_Store and .plist
		//ListOfAllFiles = RemoveFromList(".DS_Store", ListOfAllFiles)
		//ListOfAllFiles = RemoveFromList("EagleFiler Metadata.plist", ListOfAllFiles)
		ListOfAllFiles = IN2G_RemoveInvisibleFiles(ListOfAllFiles)
	
		imax = ItemsInList(ListOfAllFiles,";")
		Redimension/N=(imax) WaveOfSelections
		Redimension/N=(imax) WaveOfFiles
		for (i=0;i<imax;i+=1)
			WaveOfFiles[i] = stringFromList(i, ListOfAllFiles,";")
		endfor
	else
		Redimension/N=0 WaveOfSelections
		Redimension/N=0 WaveOfFiles
	endif 
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR3C_SelectDeselectAll(TopPanel, Select)
	string TopPanel
	variable Select
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR ControlProcsLocations=root:Packages:IrenaListboxProcs:ControlProcsLocations
	SVAR ControlPckgPathName=root:Packages:IrenaListboxProcs:ControlPckgPathName
	SVAR ControlPanelWindowName=root:Packages:IrenaListboxProcs:ControlPanelWindowName
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations,"=",";")
	string CntrlPathName=StringByKey(TopPanel, ControlPckgPathName,"=",";")

	Wave WaveOfSelections 	= $(CntrlLocation+":WaveOfSelections")
	if(select)
		WaveOfSelections=1
	else
		WaveOfSelections=0
	endif
end
//************************************************************************************************************
//************************************************************************************************************

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3C_InitControls(PckgPathName, PckgDataFolder, PanelWindowName,DefaultExtensionStr, DefaultMatchStr, DefaultSortString, DoubleCLickFnctName )
	string PckgPathName, PckgDataFolder, PanelWindowName,DefaultExtensionStr, DefaultMatchStr, DefaultSortString, DoubleCLickFnctName
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()

	setdatafolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S IrenaListboxProcs

	variable i
	
	SVAR/Z ControlProcsLocations
	if(!SVAR_Exists(ControlProcsLocations))
		string/g ControlProcsLocations
	endif
	ControlProcsLocations=ReplaceStringByKey(PanelWindowName, ControlProcsLocations, PckgDataFolder,"=",";" )

	SVAR/Z ControlPckgPathName
	if(!SVAR_Exists(ControlPckgPathName))
		string/g ControlPckgPathName
	endif
	ControlPckgPathName=ReplaceStringByKey(PanelWindowName, ControlPckgPathName, PckgPathName, "=",";" )

	SVAR/Z ControlPanelWindowName
	if(!SVAR_Exists(ControlPanelWindowName))
		string/g ControlPanelWindowName
	endif
	ControlPanelWindowName=ReplaceStringByKey(PanelWindowName, ControlPanelWindowName, PanelWindowName, "=",";" )
	
	SVAR/Z ControlDoubleCLickFnctName
	if(!SVAR_Exists(ControlDoubleCLickFnctName))
		string/g ControlDoubleCLickFnctName
	endif
	ControlDoubleCLickFnctName=ReplaceStringByKey(PanelWindowName, ControlDoubleCLickFnctName, DoubleCLickFnctName, "=",";" )

	string/g SortOptionsString="Sort;Inv_Sort;Sort _XYZ;Inv Sort _XYZ;Sort _XYZ_xyz;"
	SVAR SortOptionsString

	//check for presence of the folder where this is suppose to work.
	setDataFolder root:Packages
	string TmpStr=PckgDataFolder
	TmpStr = ReplaceString("root:Packages:", TmpStr, "")
	if(!DataFolderExists(TmpStr))
		For(i=0;i<itemsInList(TmpStr,":");i+=1)
 				NewDataFOlder/O/S $(StringFromList(i,TmpStr,":"))
		endfor
	else
		setDataFolder PckgDataFolder
	endif
	//Make the waves & strings needed. 
	Make/O/N=0/T	 WaveOfFiles
	Make/O/N=0 WaveOfSelections
	string/g DataSelListBoxMatchString
	DataSelListBoxMatchString = DefaultMatchStr
	string/g DataSelListBoxExtString = DefaultExtensionStr
	PathInfo  $PckgPathName
	string/g DataSelPathString = "\Zr140"+S_path
	//figure out the size of the string we can use...
	variable Width = FontSizeStringWidth(ReplaceString("'",IN2G_LkUpDfltStr("DefaultFontType"),""), str2num(IN2G_LkUpDfltVar("DefaultFontSize")),0,S_Path)
	variable ratio = (415 - FontSizeStringWidth(ReplaceString("'",IN2G_LkUpDfltStr("DefaultFontType"),""), str2num(IN2G_LkUpDfltVar("DefaultFontSize")),0,"Data Path :"))/width
	if(ratio<0.8)
		DataSelPathString = "\JR\Zr080"+S_Path
	elseif(ratio>0.8 && ratio<0.9)
		DataSelPathString = "\JR\Zr080"+S_Path
	elseif(ratio>0.9 && ratio<1)
		DataSelPathString = "\JR\Zr090"+S_Path
	elseif(ratio>1 && ratio<1.1)
		DataSelPathString = "\JR"+S_Path
	elseif(ratio>1.1 && ratio<1.2)
		DataSelPathString = "\JR\Zr110"+S_Path
	elseif(ratio>1.2 && ratio<1.3)
		DataSelPathString = "\JR\Zr120"+S_Path
	elseif(ratio>1.3 && ratio<1.4)
		DataSelPathString = "\JR\Zr130"+S_Path
	elseif(ratio>1.4 && ratio<1.5)
		DataSelPathString = "\JR\Zr130"+S_Path
	elseif(ratio>1.5)
		DataSelPathString = "\JR\Zr130"+S_Path
	endif
		
	string/g DataSelSortString
	SVAR DataSelSortString
	if(strlen(DefaultSortString)>0 && StringMatch(SortOptionsString, "*"+DefaultSortString+"*" ))
		DataSelSortString = DefaultSortString
	else
		DataSelSortString = StringFromList(0,SortOptionsString)
	endif
	setDataFolder OldDf
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//			Multi data selection tools  		!!!!!!!
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3C_MultiAppendControls(ToolPackageFolder,PanelName, DoubleClickFunNm, MouseDownFunNm, OnlyUSAXSReducedData,AllowSlitSmearedData)
		string PanelName,ToolPackageFolder,DoubleClickFunNm, MouseDownFunNm
		variable OnlyUSAXSReducedData,AllowSlitSmearedData
		//this will append controls to panels, which require set of control for multi sample selection	
		//	NewPanel /K=1 /W=(5.25,43.25,605,820) as "MultiData plottingg tool"
		//initialize controls first by running this command
		//IR2C_AddDataControls("Irena:MultiSaPlotFit","IR3L_MultiSaPlotFitPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
		//then call this function, it will add listbox and other controls. 
		//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		string PathToPackagesFolder="root:Packages:"+ToolPackageFolder
		IR3C_InitMultiControls(PathToPackagesFolder, PanelName, DoubleClickFunNm,MouseDownFunNm, OnlyUSAXSReducedData,AllowSlitSmearedData)			
		TitleBox Dataselection, win=$(PanelName), title="\Zr130Data selection",size={100,15},pos={10,10},frame=0,fColor=(0,0,65535),labelBack=0
		Checkbox UseIndra2Data, win=$(PanelName),pos={10,30},size={76,14},title="USAXS", proc=IR3C_MultiCheckProc, variable=$(PathToPackagesFolder+":UseIndra2Data")
		checkbox UseQRSData, win=$(PanelName),pos={100,30}, title="QRS(QIS)", size={76,14},proc=IR3C_MultiCheckProc, variable=$(PathToPackagesFolder+":UseQRSdata") 
		checkbox UseResults, win=$(PanelName),pos={190,30}, title="Irena results", size={76,14},proc=IR3C_MultiCheckProc, variable=$(PathToPackagesFolder+":UseResults") 
		PopupMenu StartFolderSelection,win=$(PanelName),pos={10,50},size={180,15},proc=IR3C_MultiPopMenuProc,title="Start fldr"
		SVAR DataStartFolder =  $(PathToPackagesFolder+":DataStartFolder") 
		//PopupMenu StartFolderSelection,mode=1,popvalue=DataStartFolder,value= #"\"root:;\"+IR3C_GenStringOfFolders2(\"+PathToPackagesFolder+\":UseIndra2Data, \"+PathToPackagesFolder+\":UseQRSdata,2,1)"
		PopupMenu StartFolderSelection,mode=1,popvalue=DataStartFolder,value= IR2C_MultiSTartFolderSelection()
		
		SetVariable FolderNameMatchString,win=$(PanelName),pos={10,75},size={210,15}, proc=IR3C_MultiSetVarProc,title="Folder Match (RegEx)"
		Setvariable FolderNameMatchString,fSize=10,fStyle=2, variable=$(PathToPackagesFolder+":DataMatchString"), help={"Scope down the folder selection using grep"}
		checkbox InvertGrepSearch, win=$(PanelName),pos={222,75}, title="Invert?", size={76,14},proc=IR3C_MultiCheckProc, variable=$(PathToPackagesFolder+":InvertGrepSearch")
	
		PopupMenu SortFolders,win=$(PanelName),pos={10,100},size={180,20},fStyle=2,proc=IR3C_MultiPopMenuProc,title="Sort Folders"
		SVAR FolderSortString =  $(PathToPackagesFolder+":FolderSortString") 
		string pathToAll
		pathToAll = PathToPackagesFolder+":FolderSortStringAll"
		PopupMenu SortFolders,mode=1,popvalue=FolderSortString,value= #pathToAll
		
		//Indra data types:
		PopupMenu SubTypeData,win=$(PanelName),pos={10,120},size={180,20},fStyle=2,proc=IR3C_MultiPopMenuProc,title="Sub-type Data"
		SVAR DataSubType = $(PathToPackagesFolder+":DataSubType") 
		PopupMenu SubTypeData,mode=1,popvalue=DataSubType,value= ""
		//results data types
		SVAR SelectedResultsTool =  $(PathToPackagesFolder+":SelectedResultsTool") 
		SVAR SelectedResultsType =  $(PathToPackagesFolder+":SelectedResultsType") 
		SVAR ResultsGenerationToUse =  $(PathToPackagesFolder+":ResultsGenerationToUse") 
		PopupMenu ToolResultsSelector,win=$(PanelName),pos={10,120},size={230,15},fStyle=2,proc=IR3C_MultiPopMenuProc,title="Which tool results?    "
		PopupMenu ToolResultsSelector,win=$(PanelName),mode=1,popvalue=SelectedResultsTool,value= #"root:Packages:IrenaControlProcs:AllKnownToolsResults"
		PopupMenu ResultsTypeSelector,win=$(PanelName),pos={10,140},size={230,15},fStyle=2,proc=IR3C_MultiPopMenuProc,title="Which results?          "
		PopupMenu ResultsTypeSelector,win=$(PanelName),mode=1,popvalue=SelectedResultsType,value= #"IR2C_ReturnKnownToolResults(\"+PathToPackagesFolder+\":SelectedResultsTool,\"+PanelName+\")"
		PopupMenu ResultsGenerationToUse,pos={10,160},size={230,15},fStyle=2,proc=IR3C_MultiPopMenuProc,title="Results Generation?           "
		PopupMenu ResultsGenerationToUse,win=$(PanelName),mode=1,popvalue=ResultsGenerationToUse,value= "Latest;_0;_1;_2;_3;_4;_5;_6;_7;_8;_9;_10;"

		SetVariable genericXgrepString,win=$(PanelName),pos={10,120},size={210,15}, proc=IR3C_MultiSetVarProc,title="X match (RegEx)"
		Setvariable genericXgrepString,fSize=10,fStyle=2, variable=$(PathToPackagesFolder+":genericXgrepString"), help={"Scope down the X wave selection using grep"}
		SetVariable genericYgrepString,win=$(PanelName),pos={10,140},size={210,15}, proc=IR3C_MultiSetVarProc,title="Y match (RegEx)"
		Setvariable genericYgrepString,fSize=10,fStyle=2, variable=$(PathToPackagesFolder+":genericYgrepString"), help={"Scope down the Y wave selection using grep"}
		SetVariable genericEgrepString,win=$(PanelName),pos={10,160},size={210,15}, proc=IR3C_MultiSetVarProc,title="E match (RegEx)"
		Setvariable genericEgrepString,fSize=10,fStyle=2, variable=$(PathToPackagesFolder+":genericEgrepString"), help={"Scope down the E wave selection using grep"}
		
		ListBox DataFolderSelection,win=$(PanelName),pos={4,180},size={250,495}, mode=10
		ListBox DataFolderSelection,listWave=$(PathToPackagesFolder+":ListOfAvailableData")
		ListBox DataFolderSelection,selWave=$(PathToPackagesFolder+":SelectionOfAvailableData")
		ListBox DataFolderSelection,proc=IR3C_MultiListBoxProc, special={0,0,1 }		//this will scale the width of column, users may need to slide right using slider at the bottom. 
	
	
		IR3C_MultiFixPanelControls(PanelName,ToolPackageFolder)	

end
//**************************************************************************************
//**************************************************************************************
//					this follwoing is very important function, 
//			it sets the names of selected X, Y, and E data for user
//					this may require bit more of debugging... 
//**************************************************************************************
//**************************************************************************************

Function IR3C_SelectWaveNamesData(CntrlLocationG, SelectedDataFolderName)
		string CntrlLocationG, SelectedDataFolderName
		
		string CntrlLocation="root:Packages:"+CntrlLocationG

		SVAR StartFolderName=$(CntrlLocation+":DataStartFolder")
		SVAR DataFolderName=$(CntrlLocation+":DataFolderName")
		SVAR IntensityWaveName=$(CntrlLocation+":IntensityWaveName")
		SVAR QWavename=$(CntrlLocation+":QWavename")
		SVAR ErrorWaveName=$(CntrlLocation+":ErrorWaveName")
		SVAR dQWavename=$(CntrlLocation+":dQWavename")
		NVAR UseIndra2Data=$(CntrlLocation+":UseIndra2Data")
		NVAR UseQRSdata=$(CntrlLocation+":UseQRSdata")
		NVAR useResults=$(CntrlLocation+":useResults")
		SVAR DataSubType = $(CntrlLocation+":DataSubType")
		//these are variables used by the control procedure
		NVAR  UseUserDefinedData=  $(CntrlLocation+":UseUserDefinedData")
		NVAR  UseModelData = $(CntrlLocation+":UseModelData")
		SVAR DataFolderName  = $(CntrlLocation+":DataFolderName")
		SVAR IntensityWaveName = $(CntrlLocation+":IntensityWaveName")
		SVAR QWavename = $(CntrlLocation+":QWavename")
		SVAR ErrorWaveName = $(CntrlLocation+":ErrorWaveName")
		SVAR ResultsDataTypesLookup=root:Packages:IrenaControlProcs:ResultsDataTypesLookup
		
		if(UseQRSdata+UseIndra2Data+useResults> 1)
			Abort "Data type not selected right, please, select type of data first" 
		endif
		
		string ControlPanelName			///name of top panel which this is called from...
		ControlPanelName = WinName(0,64)
		string TempStr, result, tempStr2, TempYName, TempXName, tempStr3
		variable i, j
		
		UseUserDefinedData = 0
		UseModelData = 0
		DataFolderName = StartFolderName+SelectedDataFolderName
		if(UseQRSdata)
			//get the names of waves, assume this tool actually works. May not under some conditions. In that case this tool will not work. 
			QWavename = stringFromList(0,IR2P_ListOfWaves("Xaxis","", ControlPanelName))
			IntensityWaveName = stringFromList(0,IR2P_ListOfWaves("Yaxis","*", ControlPanelName))
			ErrorWaveName = stringFromList(0,IR2P_ListOfWaves("Error","*", ControlPanelName))
			if(UseIndra2Data)
				dQWavename = ReplaceString("Qvec", QWavename, "dQ")
			elseif(UseQRSdata)
				dQWavename = "w"+QWavename[1,31]
			else
				dQWavename = ""
			endif
		elseif(UseIndra2Data)
			string DataSubTypeInt = DataSubType
			SVAR QvecLookup = $(CntrlLocation+":QvecLookupUSAXS")
			SVAR ErrorLookup = $(CntrlLocation+":ErrorLookupUSAXS")
			SVAR dQLookup = $(CntrlLocation+":dQLookupUSAXS")
			//string QvecLookup="R_Int=R_Qvec;BL_R_Int=BL_R_Qvec;SMR_Int=SMR_Qvec;DSM_Int=DSM_Qvec;USAXS_PD=Ar_encoder;Monitor=Ar_encoder;"
			//string ErrorLookup="R_Int=R_Error;BL_R_Int=BL_R_error;SMR_Int=SMR_Error;DSM_Int=DSM_error;"
			// string dQLookup="SMR_Int=SMR_dQ;DSM_Int=DSM_dQ;"
			string DataSubTypeQvec = StringByKey(DataSubTypeInt, QvecLookup,"=",";")
			string DataSubTypeError = StringByKey(DataSubTypeInt, ErrorLookup,"=",";")
			string DataSubTypedQ = StringByKey(DataSubTypeInt, dQLookup,"=",";")
			IntensityWaveName = DataSubTypeInt
			QWavename = DataSubTypeQvec
			ErrorWaveName = DataSubTypeError
			dQWavename = DataSubTypedQ
		elseif(useResults)
			SVAR SelectedResultsTool = $(CntrlLocation+":SelectedResultsTool")
			SVAR SelectedResultsType = $(CntrlLocation+":SelectedResultsType")
			SVAR ResultsGenerationToUse = $(CntrlLocation+":ResultsGenerationToUse")
			//follow IR2S_CallWithPlottingToolII
			if(stringmatch(ResultsGenerationToUse,"Latest"))
					DFREF TestFldr=$(DataFolderName)
					TempStr = GrepList(stringfromList(1,RemoveEnding(DataFolderDir(2, TestFldr),";\r"),":"), SelectedResultsType,0,",")
					//and need to find the one with highest generation number.
					result = stringFromList(0,TempStr,",")
					For(j=1;j<ItemsInList(TempStr,",");j+=1)
						tempStr2=stringFromList(j,TempStr,",")
						if(str2num(StringFromList(ItemsInList(result,"_")-1, result, "_"))<str2num(StringFromList(ItemsInList(tempStr2,"_")-1, tempStr2, "_")))
							result = tempStr2
						endif
					endfor
					IntensityWaveName = result				//this is intensity wave name
					tempStr2 = removeending(result, "_"+StringFromList(ItemsInList(result,"_")-1, result, "_"))
					//for some (Modeling there are two x-wave options, need to figure out which one is present...
					TempXName=StringByKey(tempStr2, ResultsDataTypesLookup  , ":", ";")
					TempXName=RemoveEnding(TempXName , ",")+","
					if(ItemsInList(TempXName,",")>1)
						j=0
						Do
							tempStr3=stringFromList(j,TempXName,",")
							if(stringmatch(DataFolderDir(2, TestFldr), "*"+tempStr3+"_"+StringFromList(ItemsInList(result,"_")-1, result, "_")+"*" ))
								TempXName=tempStr3
								break
							endif
							j+=1
						while(j<ItemsInList(TempXName,","))	
					endif
					TempXName=RemoveEnding(TempXName , ",")
					QWavename = TempXName+"_"+StringFromList(ItemsInList(result,"_")-1, result, "_")			//this is X wave name
					ErrorWaveName = ""
					dQWavename = ""
					
				else	//known result we want to use... It should exist (guarranteed by prior code)
					DFREF TestFldr=$(DataFolderName)
					IntensityWaveName = SelectedResultsType+ResultsGenerationToUse
					TempXName=StringByKey(SelectedResultsType, ResultsDataTypesLookup  , ":", ";")
					TempXName=RemoveEnding(TempXName , ",")+","
					if(ItemsInList(TempXName,",")>1)
						j=0
						Do
							tempStr3=stringFromList(j,TempXName,",")
							if(stringmatch(DataFolderDir(2, TestFldr), "*"+tempStr3+ResultsGenerationToUse+"*" ))
								TempXName=tempStr3+ResultsGenerationToUse
								break
							endif
							j+=1
						while(j<ItemsInList(TempXName,","))	
					endif
					TempXName=RemoveEnding(TempXName , ",")
					QWavename = TempXName+ResultsGenerationToUse
					ErrorWaveName = ""
					dQWavename = ""
				endif
		else
			//these are generic data... 
			SVAR genericXgrepString=$(CntrlLocation+":genericXgrepString")
			SVAR genericYgrepString=$(CntrlLocation+":genericYgrepString")
			SVAR genericEgrepString=$(CntrlLocation+":genericEgrepString")
			DFREF TestFldr=$(DataFolderName)
			string ListOfWavesStr=DataFolderDir(2, TestFldr)
			ListOfWavesStr = removeListItem(0,ListOfWavesStr,":")
			ListOfWavesStr = ReplaceString("\r", ListOfWavesStr, "")
			ListOfWavesStr = ReplaceString(",", ListOfWavesStr, ";")
			IntensityWaveName=StringFromList(0,GrepList(ListOfWavesStr, genericYgrepString ))
			QWavename = StringFromList(0,GrepList(ListOfWavesStr, genericXgrepString ))
			if(strlen(genericEgrepString)>0)
				ErrorWaveName = StringFromList(0,GrepList(ListOfWavesStr, genericEgrepString ))
			else
				ErrorWaveName=""
			endif
		endif


end
//**************************************************************************************
//**************************************************************************************
Function/S IR2C_MultiSTartFolderSelection()		//this si specifically for only ONE MultiPlot tool...
		string PopStringPath
		SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
		string PanelName = WinName(0,64)
		string CntrlLocation="root:Packages:"+StringByKey(PanelName, ControlProcsLocations,":",";")
		NVAR UseIndra2=$(CntrlLocation+":UseIndra2Data")
		NVAR UseQRSdata=$(CntrlLocation+":UseQRSdata")		
		SVAR DataSubType = $(CntrlLocation+":DataSubType")	
		string OtherFolders=IR3C_GenStringOfFolders2(UseIndra2,UseQRSdata,2,1, DataSubType = DataSubType)
		OtherFolders=RemoveFromList("root:", OtherFolders , ";")
		PopStringPath = "root:;"+OtherFolders
		return PopStringPath
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3C_MultiListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable row = lba.row
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave
	string WinNameStr=lba.win
	string FoldernameStr
	Variable isData1or2
	string DoubleClickFunctionName
	string ControlMouseDownFunctionName
	string items
	string TopPanel=WinName(0, 64)
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	string CntrlLocation=StringByKey(WinNameStr, ControlProcsLocations,":",";")
	//SVAR DataSelSortString = $(CntrlLocation+":DataSelSortString")
	SVAR DataMatchString = $("root:Packages:"+CntrlLocation+":DataMatchString")
	NVAR InvertGrepSearch = $("root:Packages:"+CntrlLocation+":InvertGrepSearch")
	variable oldSets

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down

			if (lba.eventMod & 0x10)	// rightclick
				items = "Refresh Content;Match \"ave\";Match \"avg\";Match \"sub\";Hide \"sub|avg|ave\";Remove Match;"	
				PopupContextualMenu items
				// V_flag is index of user selected item
				switch (V_flag)
					case 1:	// "Refresh Content"
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						oldSets=V_startRow
						IR3C_MultiUpdListOfAvailFiles(CntrlLocation)
						ListBox DataFolderSelection,win=$(TopPanel),row=V_startRow
						break;
					case 2:	//Match ave
						DataMatchString="ave"
						InvertGrepSearch = 0
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						 oldSets=V_startRow
						IR3C_MultiUpdListOfAvailFiles(CntrlLocation)
						ListBox DataFolderSelection,win=$(TopPanel),row=V_startRow
						break;
					case 3:	//Match avg
						DataMatchString="avg"
						InvertGrepSearch = 0
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						 oldSets=V_startRow
						IR3C_MultiUpdListOfAvailFiles(CntrlLocation)
						ListBox DataFolderSelection,win=$(TopPanel),row=V_startRow
						break;
					case 4:	//Match sub
						DataMatchString="sub"
						InvertGrepSearch = 0
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						 oldSets=V_startRow
						IR3C_MultiUpdListOfAvailFiles(CntrlLocation)
						ListBox DataFolderSelection,win=$(TopPanel),row=V_startRow
						break;
					case 5:	//Match sub
						DataMatchString="sub|avg|ave"
						InvertGrepSearch = 1
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						 oldSets=V_startRow
						IR3C_MultiUpdListOfAvailFiles(CntrlLocation)
						ListBox DataFolderSelection,win=$(TopPanel),row=V_startRow
						break;
					case 6:	//remove Match
						DataMatchString=""
						InvertGrepSearch = 0
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						 oldSets=V_startRow
						IR3C_MultiUpdListOfAvailFiles(CntrlLocation)
						ListBox DataFolderSelection,win=$(TopPanel),row=V_startRow
						break;

					default :	// "Sort"
						//DataSelSortString = StringFromList(V_flag-1, items)
						//PopupMenu SortOptionString,win=$(TopPanel), mode=1,popvalue=DataSelSortString
						//IR3C_SortListOfFilesInWvs(TopPanel)	
						break;
					endswitch
				
			else
				SVAR ControlMouseDownFunction = root:Packages:IrenaControlProcs:ControlMouseDownFunction
				ControlMouseDownFunctionName=StringByKey(WinNameStr, ControlMouseDownFunction,":",";" )
				if(numpnts(listWave)<(row+1)||row<0)
					return 0
				endif		
				FoldernameStr=listWave[row]
				if(strlen(ControlMouseDownFunctionName)>0)
					Execute(ControlMouseDownFunctionName+"(\""+FoldernameStr+"\")")
				endif
			endif
			break
		case 3: // double click
			SVAR ControlDoubleClickFunction = root:Packages:IrenaControlProcs:ControlDoubleClickFunction
			DoubleClickFunctionName=StringByKey(WinNameStr, ControlDoubleClickFunction,":",";" )
			FoldernameStr=listWave[row]
			if(strlen(DoubleClickFunctionName)>0)
				Execute(DoubleClickFunctionName+"(\""+FoldernameStr+"\")")
			endif
			break
		case 4: // cell selection
		case 5: // cell selection plus shift key
			break
		case 6: // begin edit
			break
		case 7: // finish edit
			break
		case 13: // checkbox clicked (Igor 6.2 or later)
			break
	endswitch

	return 0
End
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************


Function IR3C_InitMultiControls(PathToPackagesFolder, PanelName, DoubleClickFunction,MouseDownFunction, OnlyUSAXSReducedData,AllowSlitSmearedData)	
	string PathToPackagesFolder, PanelName, DoubleClickFunction, MouseDownFunction
	variable OnlyUSAXSReducedData,AllowSlitSmearedData

	DFref oldDf= GetDataFolderDFR()

	string ListOfVariables
	string ListOfStrings
	variable i
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		
	string/G root:Packages:IrenaControlProcs:ControlMouseDownFunction
	SVAR ControlMouseDownFunction = root:Packages:IrenaControlProcs:ControlMouseDownFunction
	ControlMouseDownFunction=ReplaceStringByKey(PanelName, ControlMouseDownFunction, MouseDownFunction,":",";" )
	
	string/G root:Packages:IrenaControlProcs:ControlDoubleClickFunction
	SVAR ControlDoubleClickFunction = root:Packages:IrenaControlProcs:ControlDoubleClickFunction
	ControlDoubleClickFunction=ReplaceStringByKey(PanelName, ControlDoubleClickFunction, DoubleClickFunction,":",";" )


	SetDataFolder $(PathToPackagesFolder)					//go into the folder

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;DataUnits;"
	ListOfStrings+="DataStartFolder;DataMatchString;FolderSortString;FolderSortStringAll;"
	ListOfStrings+="SelectedResultsTool;SelectedResultsType;ResultsGenerationToUse;"
	ListOfStrings+="DataSubTypeUSAXSList;DataSubTypeResultsList;DataSubType;"
	ListOfStrings+="QvecLookupUSAXS;ErrorLookupUSAXS;dQLookupUSAXS;"
	ListOfStrings+="genericXgrepString;genericYgrepString;genericEgrepString;"

	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;"
	ListOfVariables+="InvertGrepSearch;"
	
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR teststr=$(StringFromList(i,ListOfStrings))
		teststr =""
	endfor		
	ListOfStrings="DataMatchString;FolderSortString;FolderSortStringAll;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR teststr=$(StringFromList(i,ListOfStrings))
		if(strlen(teststr)<1)
			teststr =""
		endif
	endfor		
	ListOfStrings="DataStartFolder;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR teststr=$(StringFromList(i,ListOfStrings))
		if(strlen(teststr)<1)
			teststr ="root:"
		endif
	endfor		
	SVAR FolderSortStringAll
	FolderSortStringAll = "Alphabetical;Reverse Alphabetical;_xyz;_xyz.ext;Reverse _xyz;Reverse _xyz.ext;Sxyz_;Reverse Sxyz_;_xyzmin;_xyzC;_xyzpct;_xyz_000;Reverse _xyz_000;_XYZ_xyz;_xyzs;Reverse _xyzs;"
	SVAR DataSubTypeUSAXSList
	if(OnlyUSAXSReducedData)
		if(AllowSlitSmearedData)
			DataSubTypeUSAXSList="DSM_Int;SMR_Int;"
		else
			DataSubTypeUSAXSList="DSM_Int;"
		endif
	else
		DataSubTypeUSAXSList="DSM_Int;SMR_Int;R_Int;Blank_R_Int;USAXS_PD;Monitor;Detector;"
	endif
	SVAR DataSubTypeResultsList
	DataSubTypeResultsList="Size"
	SVAR DataSubType
	DataSubType="DSM_Int"

	SVAR QvecLookupUSAXS
	QvecLookupUSAXS="R_Int=R_Qvec;Blank_R_Int=Blank_R_Qvec;SMR_Int=SMR_Qvec;DSM_Int=DSM_Qvec;USAXS_PD=Ar_encoder;Monitor=Ar_encoder;Detector=Xdata;"
	SVAR ErrorLookupUSAXS
	ErrorLookupUSAXS="R_Int=R_Error;Blank_R_Int=Blank_R_error;SMR_Int=SMR_Error;DSM_Int=DSM_error;"
	SVAR dQLookupUSAXS
	dQLookupUSAXS="SMR_Int=SMR_dQ;DSM_Int=DSM_dQ;"
	
	SVAR SelectedResultsTool 
	SVAR SelectedResultsType 
	SVAR ResultsGenerationToUse
	if(strlen(SelectedResultsTool)<1 || strlen(SelectedResultsType)<1)
		SelectedResultsTool="Unified Fit"
		SelectedResultsType="UnifiedFitIntensity"
	endif
//	if(strlen(SelectedResultsTool)<1)
//		SelectedResultsTool=IR2C_ReturnKnownToolResults(SelectedResultsTool)
//	endif
	if(strlen(ResultsGenerationToUse)<1)
		ResultsGenerationToUse="Latest"
	endif
	Make/O/T/N=(0) ListOfAvailableData
	Make/O/N=(0) SelectionOfAvailableData

	NVAR UseIndra2Data 
	NVAR UseQRSdata
	NVAR UseResults 
	if(UseResults+UseQRSdata+UseIndra2Data!=1)
		UseIndra2Data = 0
		UseQRSdata = 1
		UseResults = 0
	endif


	SetDataFolder oldDf

end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3C_MultiSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable dval = sva.dval
	String sval = sva.sval
	String WinNm = sva.win
	string ctrlName = sva.ctrlName
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	string CntrlLocation=StringByKey(WinNm, ControlProcsLocations,":",";")

	variable tempP
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
			if(stringmatch(sva.ctrlName,"FolderNameMatchString")||stringmatch(sva.ctrlName,"genericXgrepString")||stringmatch(sva.ctrlName,"genericYgrepString")||stringmatch(sva.ctrlName,"genericEgrepString"))
				IR3C_MultiUpdListOfAvailFiles(CntrlLocation)
			endif
		break
		case 3: // live update
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

//**************************************************************************************
//**************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3C_MultiCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	if(cba.eventcode<1 ||cba.eventcode>2)
		return 0
	endif
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//figure out where are controls
	String ctrlName=cba.ctrlName
	Variable checked=cba.checked
	DFref oldDf= GetDataFolderDFR()

	string TopPanel=cba.win

	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	string CntrolLocationShort=StringByKey(TopPanel, ControlProcsLocations,":",";")
	string CntrlLocation="root:Packages:"+CntrolLocationShort

	switch( cba.eventCode )
		case 2: // mouse up
			NVAR UseIndra2Data=$(CntrlLocation+":UseIndra2Data")
			NVAR UseQRSData=$(CntrlLocation+":UseQRSData")
			NVAR UseResults=$(CntrlLocation+":UseResults")
			NVAR UseUserDefinedData=$(CntrlLocation+":UseUserDefinedData")
			NVAR UseModelData=$(CntrlLocation+":UseModelData")
			SVAR DataStartFolder=$(CntrlLocation+":DataStartFolder")

		  	if(stringmatch(cba.ctrlName,"InvertGrepSearch"))
					IR3C_MultiUpdListOfAvailFiles(CntrolLocationShort)	
		  	endif
		  	if(stringmatch(cba.ctrlName,"UseIndra2Data"))
		  		if(checked)
		  			UseQRSData = 0
		  			UseResults = 0
		  		endif
				IR3C_MultiFixPanelControls(TopPanel,CntrolLocationShort)	
				//IR3C_MultiUpdListOfAvailFiles(CntrlLocation)
		  	endif
		  	if(stringmatch(cba.ctrlName,"UseResults"))
		  		if(checked)
		  			UseQRSData = 0
		  			UseIndra2Data = 0
		  		endif
				IR3C_MultiFixPanelControls(TopPanel,CntrolLocationShort)	
				//IR3C_MultiUpdListOfAvailFiles(CntrlLocation)
		  	endif
		  	if(stringmatch(cba.ctrlName,"UseQRSData"))
		  		if(checked)
		  			UseIndra2Data = 0
		  			UseResults = 0
		  		endif
				IR3C_MultiFixPanelControls(TopPanel,CntrolLocationShort)	
				//IR3C_MultiUpdListOfAvailFiles(CntrlLocation)
		  	endif
		  	if(stringmatch(cba.ctrlName,"UseQRSData")||stringmatch(cba.ctrlName,"UseIndra2Data")||stringmatch(cba.ctrlName,"UseResults"))
		  		DataStartFolder = "root:"
		  		PopupMenu StartFolderSelection,win=$(TopPanel), mode=1,popvalue="root:"
				IR3C_MultiUpdListOfAvailFiles(CntrolLocationShort)
		  	endif
			break
		case -1: // control being killed
			break
	endswitch
	setDataFolder OldDf
	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3C_MultiFixPanelControls(TopPanel,CntrlLocationG)	
	string TopPanel,CntrlLocationG

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string CntrlLocation="root:Packages:"+CntrlLocationG
	NVAR UseIndra2Data=$(CntrlLocation+":UseIndra2Data")
	NVAR UseQRSData=$(CntrlLocation+":UseQRSData")
	NVAR UseResults=$(CntrlLocation+":UseResults")
	NVAR UseUserDefinedData=$(CntrlLocation+":UseUserDefinedData")
	NVAR UseModelData=$(CntrlLocation+":UseModelData")
	SVAR DataSubType = $(CntrlLocation+":DataSubType")
	SVAR DataSubTypeResultsList=$(CntrlLocation+":DataSubTypeResultsList")
	SVAR DataSubTypeUSAXSList = $(CntrlLocation+":DataSubTypeUSAXSList")
	string tempStr=CntrlLocation+":DataSubTypeUSAXSList"
	if(UseIndra2Data)
			PopupMenu SubTypeData, win=$(TopPanel), disable =0
			PopupMenu SubTypeData,mode=1,popvalue=DataSubType,value=#tempStr
			PopupMenu ToolResultsSelector,win=$(TopPanel),disable=1
			PopupMenu ResultsTypeSelector,win=$(TopPanel),disable=1
			PopupMenu ResultsGenerationToUse,win=$(TopPanel),disable=1
			SetVariable genericXgrepString,win=$(TopPanel),disable=1
			SetVariable genericYgrepString,win=$(TopPanel),disable=1
			SetVariable genericEgrepString,win=$(TopPanel),disable=1
	elseif(UseQRSData)
			PopupMenu SubTypeData,win=$(TopPanel),mode=1,popvalue=DataSubType,value= ""
			PopupMenu SubTypeData, disable=1
			PopupMenu ToolResultsSelector,win=$(TopPanel),disable=1
			PopupMenu ResultsTypeSelector,win=$(TopPanel),disable=1
			PopupMenu ResultsGenerationToUse,win=$(TopPanel),disable=1
			SetVariable genericXgrepString,win=$(TopPanel),disable=1
			SetVariable genericYgrepString,win=$(TopPanel),disable=1
			SetVariable genericEgrepString,win=$(TopPanel),disable=1
	elseif(UseResults)
			PopupMenu SubTypeData, win=$(TopPanel),disable=1
			PopupMenu ToolResultsSelector,win=$(TopPanel),disable=0
			PopupMenu ResultsTypeSelector,win=$(TopPanel),disable=0
			PopupMenu ResultsGenerationToUse,win=$(TopPanel),disable=0
			SetVariable genericXgrepString,win=$(TopPanel),disable=1
			SetVariable genericYgrepString,win=$(TopPanel),disable=1
			SetVariable genericEgrepString,win=$(TopPanel),disable=1
	else		//this is generic type
			PopupMenu SubTypeData,win=$(TopPanel),mode=1,popvalue=DataSubType,value= ""
			PopupMenu SubTypeData, disable=1
			PopupMenu ToolResultsSelector,win=$(TopPanel),disable=1
			PopupMenu ResultsTypeSelector,win=$(TopPanel),disable=1
			PopupMenu ResultsGenerationToUse,win=$(TopPanel),disable=1
			SetVariable genericXgrepString,win=$(TopPanel),disable=0
			SetVariable genericYgrepString,win=$(TopPanel),disable=0
			SetVariable genericEgrepString,win=$(TopPanel),disable=0
	endif
end

//**********************************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3C_MultiPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	if(Pa.eventCode!=2)
		return 0
	endif
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String ctrlName=Pa.ctrlName
	Variable popNum=Pa.popNum
	String popStr=Pa.popStr
	//part to copy everywhere...	
	DFref oldDf= GetDataFolderDFR()

	string TopPanel=Pa.win	
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	string CntrlLocationShort=StringByKey(TopPanel, ControlProcsLocations,":",";")
	string CntrlLocation="root:packages:"+CntrlLocationShort

	if(stringmatch(ctrlName,"StartFolderSelection"))
		//Update the listbox using start folde popStr
		SVAR StartFolderName=$(CntrlLocation+":DataStartFolder")
		StartFolderName = popStr
		IR3C_MultiUpdListOfAvailFiles(CntrlLocationShort)
	endif
	if(stringmatch(ctrlName,"SortFolders"))
		//do something here
		SVAR FolderSortString = $(CntrlLocation+":FolderSortString")
		FolderSortString = popStr
		IR3C_MultiUpdListOfAvailFiles(CntrlLocationShort)
	endif
	if(stringmatch(ctrlName,"SubTypeData"))
		//do something here
		SVAR DataSubType = $(CntrlLocation+":DataSubType")
		DataSubType = popStr
		//need to deal with slit smeared data...
		NVAR UseSMRData = $(CntrlLocation+":UseSMRData")
		if(StringMatch(popStr, "SMR_Int"))
			UseSMRData = 1
		else
			UseSMRData = 0
		endif
		IR3C_MultiUpdListOfAvailFiles(CntrlLocationShort)
	endif
	if(stringmatch(ctrlName,"ToolResultsSelector"))
		SVAR SelectedResultsTool=$(CntrlLocation+":SelectedResultsTool")
		SelectedResultsTool = popStr
		string ListOfAvailableResults=IR2C_ReturnKnownToolResults(popStr, TopPanel)
		execute("PopupMenu ResultsTypeSelector, win="+TopPanel+", mode=1, value=IR2C_ReturnKnownToolResults(\""+popStr+"\",\""+TopPanel+"\")")
		//execute("PopupMenu ResultsTypeSelector, win="+TopPanel+", mode=1, value=IR2C_ReturnKnownToolResults(\""+popStr+","+TopPanel+"\")")
		SVAR SelectedResultsType=$(CntrlLocation+":SelectedResultsType")
		SelectedResultsType = stringFromList(0,ListOfAvailableResults)
		IR3C_MultiUpdListOfAvailFiles(CntrlLocationShort)
	endif
	if(stringmatch(ctrlName,"ResultsTypeSelector"))
		//Update the listbox using start folde popStr
		SVAR SelectedResultsType=$(CntrlLocation+":SelectedResultsType")
		SelectedResultsType = popStr
		IR3C_MultiUpdListOfAvailFiles(CntrlLocationShort)
	endif
	if(stringmatch(ctrlName,"ResultsGenerationToUse"))
		//Update the listbox using start folde popStr
		SVAR ResultsGenerationToUse=$(CntrlLocation+":ResultsGenerationToUse")
		ResultsGenerationToUse = popStr
		IR3C_MultiUpdListOfAvailFiles(CntrlLocationShort)
	endif
	setDataFolder OldDf
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function IR3C_MultiUpdListOfAvailFiles(CntrlLocationG)
	string CntrlLocationG

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()
	string CntrlLocation="root:Packages:"+CntrlLocationG

	setDataFolder $(CntrlLocation)
	
	NVAR UseIndra2Data=$(CntrlLocation+":UseIndra2Data")
	NVAR UseQRSdata=$(CntrlLocation+":UseQRSData")
	NVAR UseResults=$(CntrlLocation+":UseResults")
	SVAR StartFolderName=$(CntrlLocation+":DataStartFolder")
	SVAR DataMatchString= $(CntrlLocation+":DataMatchString")
	SVAR DataSubType = $(CntrlLocation+":DataSubType")
	NVAR InvertGrepSearch=$(CntrlLocation+":InvertGrepSearch")
	string LStartFolder, FolderContent
	if(stringmatch(StartFolderName,"---")||!(DataFolderExists(StartFolderName )))
		LStartFolder="root:"
	else
		LStartFolder = StartFolderName
	endif
	//build list of availabe folders here...
	string CurrentFolders
	if(UseIndra2Data && !(StringMatch(DataSubType, "DSM_Int")||StringMatch(DataSubType, "SMR_Int")))		//special folders...
		CurrentFolders=IN2G_FindFolderWithWaveTypes(LStartFolder, 10, DataSubType, 1)							//this does not clean up by matchstring...
		if(strlen(DataMatchString)>0)																							//match string selections
			CurrentFolders = GrepList(CurrentFolders, DataMatchString, InvertGrepSearch) 
		endif
	elseif(UseIndra2Data && (StringMatch(DataSubType, "DSM_Int")||StringMatch(DataSubType, "SMR_Int")))			//DSM or SMR data wanted. 
		//need to check if user wants DSM or SMR data. 
		if(StringMatch(DataSubType, "DSM_Int"))
			CurrentFolders=IR3C_MultiGenStringOfFolders(CntrlLocation, LStartFolder,UseIndra2Data, UseQRSData,UseResults, 0,1)
		else
			CurrentFolders=IR3C_MultiGenStringOfFolders(CntrlLocation, LStartFolder,UseIndra2Data, UseQRSData,UseResults, 1,1)
		endif
		//apply grep list. 
		if(strlen(DataMatchString)>0)
			CurrentFolders = GrepList(CurrentFolders, DataMatchString, InvertGrepSearch) 
		endif
	else
		CurrentFolders=IR3C_MultiGenStringOfFolders(CntrlLocation, LStartFolder,UseIndra2Data, UseQRSData,UseResults, 0,1)
		//apply grep list. 
		if(strlen(DataMatchString)>0)
			CurrentFolders = GrepList(CurrentFolders, DataMatchString, InvertGrepSearch) 
		endif
	endif

	CurrentFolders = GrepList(CurrentFolders, "Packages", 1) 

	Wave/T ListOfAvailableData=$(CntrlLocation+":ListOfAvailableData")
	Wave SelectionOfAvailableData=$(CntrlLocation+":SelectionOfAvailableData")
	variable i, j, match
	string TempStr, FolderCont

		
	Redimension/N=(ItemsInList(CurrentFolders , ";")) ListOfAvailableData, SelectionOfAvailableData
	j=0
	For(i=0;i<ItemsInList(CurrentFolders , ";");i+=1)
		TempStr = ReplaceString(LStartFolder, StringFromList(i, CurrentFolders , ";"),"")
		if(strlen(TempStr)>0)
			ListOfAvailableData[j] = tempStr
			j+=1
		endif
	endfor
	if(j<ItemsInList(CurrentFolders , ";"))
		DeletePoints j, numpnts(ListOfAvailableData)-j, ListOfAvailableData, SelectionOfAvailableData
	endif
	SelectionOfAvailableData = 0
	IR3C_MultiSortListOfAvailFldrs(CntrlLocation)
	setDataFolder OldDF
end


//**************************************************************************************
//**************************************************************************************
Function IR3C_MultiSortListOfAvailFldrs(CntrlLocation)
	string CntrlLocation
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR FolderSortString=$(CntrlLocation+":FolderSortString")
	Wave/T ListOfAvailableData=$(CntrlLocation+":ListOfAvailableData")
	Wave SelectionOfAvailableData=$(CntrlLocation+":SelectionOfAvailableData")
	if(numpnts(ListOfAvailableData)<2)
		return 0
	endif
	Duplicate/Free SelectionOfAvailableData, TempWv
	variable i, InfoLoc, j=0
	variable DIDNotFindInfo
	DIDNotFindInfo =0
	string tempstr 
	SelectionOfAvailableData=0
	if(stringMatch(FolderSortString,"---"))
		//nothing to do
	elseif(stringMatch(FolderSortString,"Alphabetical"))
		Sort /A ListOfAvailableData, ListOfAvailableData
	elseif(stringMatch(FolderSortString,"Reverse Alphabetical"))
		Sort /A /R ListOfAvailableData, ListOfAvailableData
	elseif(stringMatch(FolderSortString,"_xyz")&&(numpnts(ListOfAvailableData)>2))
			//For(i=0;i<numpnts(TempWv);i+=1)
		TempWv = IN2G_FindNumIndxForSort(ListOfAvailableData[p])
			//TempWv[i] = str2num(StringFromList(ItemsInList(ListOfAvailableData[i]  , "_")-1, ListOfAvailableData[i]  , "_"))
			//endfor
		Sort TempWv, ListOfAvailableData
	elseif(stringMatch(FolderSortString,"Reverse _xyz"))
			//For(i=0;i<numpnts(TempWv);i+=1)
			TempWv = IN2G_FindNumIndxForSort(ListOfAvailableData[p])
			//TempWv[i] = str2num(StringFromList(ItemsInList(ListOfAvailableData[i]  , "_")-1, ListOfAvailableData[i]  , "_"))
			//endfor
		Sort /R  TempWv, ListOfAvailableData
	elseif(stringMatch(FolderSortString,"Sxyz_"))
		For(i=0;i<numpnts(TempWv);i+=1)
			TempWv[i] = str2num(ReplaceString("S", StringFromList(0, ListOfAvailableData[i], "_"), ""))
		endfor
		Sort TempWv, ListOfAvailableData
	elseif(stringMatch(FolderSortString,"Reverse Sxyz_"))
		For(i=0;i<numpnts(TempWv);i+=1)
			TempWv[i] = str2num(ReplaceString("S", StringFromList(0, ListOfAvailableData[i], "_"), ""))
		endfor
		Sort/R TempWv, ListOfAvailableData
	elseif(stringMatch(FolderSortString,"_xyzmin"))
		Do
			For(i=0;i<ItemsInList(ListOfAvailableData[j] , "_");i+=1)
				if(StringMatch(ReplaceString(":", StringFromList(i, ListOfAvailableData[j], "_"),""), "*min" ))
					InfoLoc = i
					break
				endif
			endfor
			j+=1
			if(j>(numpnts(ListOfAvailableData)-1))
				DIDNotFindInfo=1
				break
			endif
		while (InfoLoc<1) 
		if(DIDNotFindInfo)
			DoALert /T="Information not found" 0, "Cannot find location of _xyzmin information, sorting alphabetically" 
			Sort /A ListOfAvailableData, ListOfAvailableData
		else
			For(i=0;i<numpnts(TempWv);i+=1)
				if(StringMatch(StringFromList(InfoLoc, ListOfAvailableData[i], "_"), "*min*" ))
					TempWv[i] = str2num(ReplaceString("min", StringFromList(InfoLoc, ListOfAvailableData[i], "_"), ""))
				else	//data not found
					TempWv[i] = inf
				endif
			endfor
			Sort TempWv, ListOfAvailableData
		endif
	elseif(stringMatch(FolderSortString,"_xyzpct"))
		Do
			For(i=0;i<ItemsInList(ListOfAvailableData[j] , "_");i+=1)
				if(StringMatch(ReplaceString(":", StringFromList(i, ListOfAvailableData[j], "_"),""), "*pct" ))
					InfoLoc = i
					break
				endif
			endfor
			j+=1
			if(j>(numpnts(ListOfAvailableData)-1))
				DIDNotFindInfo=1
				break
			endif
		while (InfoLoc<1) 
		if(DIDNotFindInfo)
			DoAlert/T="Information not found" 0, "Cannot find location of _xyzpct information, sorting alphabetically" 
			Sort /A ListOfAvailableData, ListOfAvailableData
		else
			For(i=0;i<numpnts(TempWv);i+=1)
				if(StringMatch(StringFromList(InfoLoc, ListOfAvailableData[i], "_"), "*pct*" ))
					TempWv[i] = str2num(ReplaceString("pct", StringFromList(InfoLoc, ListOfAvailableData[i], "_"), ""))
				else	//data not found
					TempWv[i] = inf
				endif
			endfor
			Sort TempWv, ListOfAvailableData
		endif
	elseif(stringMatch(FolderSortString,"_xyzC"))
		Do
			For(i=0;i<ItemsInList(ListOfAvailableData[j] , "_");i+=1)
				if(StringMatch(ReplaceString(":", StringFromList(i, ListOfAvailableData[j], "_"),""), "*C" ))
					InfoLoc = i
					break
				endif
			endfor
			j+=1
			if(j>(numpnts(ListOfAvailableData)-1))
				DIDNotFindInfo=1
				break
			endif
		while (InfoLoc<1) 
		if(DIDNotFindInfo)
			DoAlert /T="Information not found" 0, "Cannot find location of _xyzC information, sorting alphabetically" 
			Sort /A ListOfAvailableData, ListOfAvailableData
		else
			For(i=0;i<numpnts(TempWv);i+=1)
				if(StringMatch(StringFromList(InfoLoc, ListOfAvailableData[i], "_"), "*C*" ))
					TempWv[i] = str2num(ReplaceString("C", StringFromList(InfoLoc, ListOfAvailableData[i], "_"), ""))
				else	//data not found
					TempWv[i] = inf
				endif
			endfor
			Sort TempWv, ListOfAvailableData
		endif
	elseif(stringMatch(FolderSortString,"_xyzs"))
		Do
			For(i=0;i<ItemsInList(ListOfAvailableData[j] , "_");i+=1)
				if(StringMatch(ReplaceString(":", StringFromList(i, ListOfAvailableData[j], "_"),""), "*s" ))
					InfoLoc = i
					break
				endif
			endfor
			j+=1
			if(j>(numpnts(ListOfAvailableData)-1))
				DIDNotFindInfo=1
				break
			endif
		while (InfoLoc<1) 
		if(DIDNotFindInfo)
			DoAlert /T="Information not found" 0, "Cannot find location of _xyzs information, sorting alphabetically" 
			Sort /A ListOfAvailableData, ListOfAvailableData
		else
			For(i=0;i<numpnts(TempWv);i+=1)
				if(StringMatch(StringFromList(InfoLoc, ListOfAvailableData[i], "_"), "*s*" ))
					TempWv[i] = str2num(ReplaceString("s", StringFromList(InfoLoc, ListOfAvailableData[i], "_"), ""))
				else	//data not found
					TempWv[i] = inf
				endif
			endfor
			Sort TempWv, ListOfAvailableData
		endif
	elseif(stringMatch(FolderSortString,"Reverse _xyzs"))
		Do
			For(i=0;i<ItemsInList(ListOfAvailableData[j] , "_");i+=1)
				if(StringMatch(ReplaceString(":", StringFromList(i, ListOfAvailableData[j], "_"),""), "*s" ))
					InfoLoc = i
					break
				endif
			endfor
			j+=1
			if(j>(numpnts(ListOfAvailableData)-1))
				DIDNotFindInfo=1
				break
			endif
		while (InfoLoc<1) 
		if(DIDNotFindInfo)
			DoAlert /T="Information not found" 0, "Cannot find location of _xyzs information, sorting alphabetically" 
			Sort /A ListOfAvailableData, ListOfAvailableData
		else
			For(i=0;i<numpnts(TempWv);i+=1)
				if(StringMatch(StringFromList(InfoLoc, ListOfAvailableData[i], "_"), "*s*" ))
					TempWv[i] = str2num(ReplaceString("s", StringFromList(InfoLoc, ListOfAvailableData[i], "_"), ""))
				else	//data not found
					TempWv[i] = inf
				endif
			endfor
			Sort/R TempWv, ListOfAvailableData
		endif
	elseif(stringMatch(FolderSortString,"_xyz.ext"))
		For(i=0;i<numpnts(TempWv);i+=1)
			tempstr = StringFromList(ItemsInList(ListOfAvailableData[i]  , ".")-2, ListOfAvailableData[i]  , ".")
			TempWv[i] = str2num(StringFromList(ItemsInList(tempstr , "_")-1, tempstr , "_"))
		endfor
		Sort TempWv, ListOfAvailableData
	elseif(stringMatch(FolderSortString,"Reverse _xyz.ext"))
		For(i=0;i<numpnts(TempWv);i+=1)
			tempstr = StringFromList(ItemsInList(ListOfAvailableData[i]  , ".")-2, ListOfAvailableData[i]  , ".")
			TempWv[i] = str2num(StringFromList(ItemsInList(tempstr , "_")-1, tempstr , "_"))
		endfor
		Sort /R  TempWv, ListOfAvailableData
	elseif(stringMatch(FolderSortString,"_xyz_000"))
		For(i=0;i<numpnts(TempWv);i+=1)
			TempWv[i] = str2num(StringFromList(ItemsInList(ListOfAvailableData[i]  , "_")-2, ListOfAvailableData[i]  , "_"))
		endfor
		Sort TempWv, ListOfAvailableData
	elseif(stringMatch(FolderSortString,"Reverse _xyz_000"))
		For(i=0;i<numpnts(TempWv);i+=1)
			TempWv[i] = str2num(StringFromList(ItemsInList(ListOfAvailableData[i]  , "_")-2, ListOfAvailableData[i]  , "_"))
		endfor
		Sort /R  TempWv, ListOfAvailableData
	elseif(stringMatch(FolderSortString,"_XYZ_xyz"))
		For(i=0;i<numpnts(TempWv);i+=1)
			TempWv[i] = str2num(StringFromList(ItemsInList(ListOfAvailableData[i]  , "_")-2, ListOfAvailableData[i]  , "_"))*1e6+str2num(StringFromList(ItemsInList(ListOfAvailableData[i]  , "_")-1, ListOfAvailableData[i]  , "_"))
		endfor
		Sort  TempWv, ListOfAvailableData
	endif

end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function/T IR3C_MultiGenStringOfFolders(CntrlLocation, StartFolder,UseIndra2Structure, UseQRSStructure, UseResults, SlitSmearedData, AllowQRDataOnly)
	string StartFolder, CntrlLocation
	variable UseIndra2Structure, UseQRSStructure, UseResults, SlitSmearedData, AllowQRDataOnly
		//SlitSmearedData =0 for DSM data, 
		//                          =1 for SMR data 
		//                    and =2 for both
		// AllowQRDataOnly=1 if Q and R data are allowed only (no error wave). For QRS data ONLY!
	DFref oldDf= GetDataFolderDFR()
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string ListOfQFolders
	string TempStr, tempStr2
	variable i
	//	if UseIndra2Structure = 1 we are using Indra2 data, else return all folders 
	string result
	if (UseIndra2Structure)
		if(SlitSmearedData==1)
			result=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*SMR*", 1)
		elseif(SlitSmearedData==2)
			tempStr=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*SMR*", 1)
			result=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*DSM*", 1)+";"
			for(i=0;i<ItemsInList(tempStr);i+=1)
			//print stringmatch(result, "*"+StringFromList(i, tempStr,";")+"*")
				if(stringmatch(result, "*"+StringFromList(i, tempStr,";")+"*")==0)
					result+=StringFromList(i, tempStr,";")+";"
				endif
			endfor
		else
			result=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*DSM*", 1)
		endif
	elseif (UseQRSStructure)
			make/N=0/FREE/T ResultingWave
			IR2P_FindFolderWithWaveTypesWV(StartFolder, 10, "(?i)^r|i$", 1, ResultingWave)
			result=IR3C_CheckForRightQRSTripletWvs(ResultingWave,AllowQRDataOnly)
	elseif (UseResults)
		SVAR SelectedResultsTool=$(CntrlLocation+":SelectedResultsTool")
		SVAR SelectedResultsType=$(CntrlLocation+":SelectedResultsType")
		SVAR ResultsGenerationToUse=$(CntrlLocation+":ResultsGenerationToUse")
		if(stringmatch(ResultsGenerationToUse,"Latest"))
			result=IN2G_FindFolderWithWvTpsList(StartFolder, 10,SelectedResultsType+"*", 1) 
		else
			result=IN2G_FindFolderWithWvTpsList(StartFolder, 10,SelectedResultsType+ResultsGenerationToUse, 1) 
		endif
	else			//modify to get folder with matching type of X, Y, Z waves using grep
			//result=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*", 1)
			SVAR genericXgrepString=$(CntrlLocation+":genericXgrepString")
			SVAR genericYgrepString=$(CntrlLocation+":genericYgrepString")
			SVAR genericEgrepString=$(CntrlLocation+":genericEgrepString")
			make/N=0/FREE/T ResultingWave
			IR2P_FindFolderWithWaveTypesWV(StartFolder, 10, genericXgrepString, 1, ResultingWave)		//these folder should match X grep string
			IR3C_SelectFldrWithWaveMatch(ResultingWave,genericYgrepString)								//these should match Y grep string
			//ignore E string for now, assume we can use just X/Y
			result=IN2G_ConvTextWaveToStringList(ResultingWave) 
	endif
	if(stringmatch(";",result[0]))
		result = result [1, inf]
	endif
	setDataFolder oldDf
	return result
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3C_SelectFldrWithWaveMatch(WaveOfFolders,grepStringS)
			wave/T WaveOfFolders
			string grepStringS
		DFref oldDf= GetDataFolderDFR()
		variable i, imax
		string curfldr, AllWaves
		imax=numpnts(WaveOfFolders)
		For(i=imax-1;i>=0;i-=1)
			curfldr = WaveOfFolders[i]
			AllWaves = IN2G_CreateListOfItemsInFolder(curfldr,2)
			AllWaves=GrepList(AllWaves,grepStringS)
			if(strlen(AllWaves)<1)
				DeletePoints i, 1, WaveOfFolders 
			endif
		endfor
	setDataFolder oldDf			
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function/T IR3C_CheckForRightQRSTripletWvs(ResultingWave, AllowQROnly)
	wave/T ResultingWave
	variable AllowQROnly	

	DFref oldDf= GetDataFolderDFR()

	string result=""
	string tempResult="" , FullFldrName
 	variable i,j, matchX=0,matchE=0
	string AllWaves
	string allRwaves
	string ts, tx, ty

	for(i=0;i<numpnts(ResultingWave);i+=1)			//this looks for qrs tripplets
		FullFldrName = ResultingWave[i]
		AllWaves = IN2G_CreateListOfItemsInFolder(FullFldrName,2)
		allRwaves=GrepList(AllWaves,"(?i)^r")
		tempresult=""
			for(j=0;j<ItemsInList(allRwaves);j+=1)
				matchX=0
				matchE=0
				ty=stringFromList(j,allRwaves)[1,inf]
				if((stringmatch(";"+AllWaves, ";*q"+ty+";*" )||stringmatch(";"+AllWaves, ";*m"+ty+";*" )||stringmatch(";"+AllWaves, ";*t"+ty+";*" )||stringmatch(";"+AllWaves, ";*d"+ty+";*" )||stringmatch(";"+AllWaves, ";*az"+ty+";*" )&&!stringmatch(";"+AllWaves, ";*DSM"+ty+";*" )))
					matchX=1
				endif
				if(stringmatch(";"+AllWaves,";*s"+ty+";*" ))
					matchE=1
				endif
				if(matchX && (matchE || AllowQROnly))
					tempResult+= FullFldrName+";"
					break
				endif
			endfor
			result+=tempresult
		allRwaves=GrepList(AllWaves,"(?i)i$")
		tempresult=""
			for(j=0;j<ItemsInList(allRwaves);j+=1)
				matchX=0
				matchE=0
				if(stringmatch(";"+AllWaves, ";*"+stringFromList(j,allRwaves)[0,strlen(stringFromList(j,allRwaves))-2]+"q;*" ))
					matchX=1
				endif
				if(stringmatch(";"+AllWaves,";*"+stringFromList(j,allRwaves)[0,strlen(stringFromList(j,allRwaves))-2]+"s;*" ))
					matchE=1
				endif
				if(matchX && matchE)
					tempResult+= FullFldrName+";"
					break
				endif
			endfor
			result+=tempresult
	endfor
//	print ticks-startTime
	if(strlen(result)>1)
		return result
	else
		return "---"
	endif
	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//**********************************************************************************************************


Function/T IR3C_GenStringOfFolders2(UseIndra2Structure, UseQRSStructure, SlitSmearedData, AllowQRDataOnly, [DataSubType])
	variable UseIndra2Structure, UseQRSStructure, SlitSmearedData, AllowQRDataOnly
	String DataSubType
		//SlitSmearedData =0 for DSM data, 
		//                          =1 for SMR data 
		//                    and =2 for both
		// DataSubType = this is subtype of USAXS data, Detector needs special handling... 
		// AllowQRDataOnly=1 if Q and R data are allowed only (no error wave). For QRS data ONLY!
	string DataSubTypeLocal = "SMR_Int"
	if(!paramIsDefault(DataSubType))
		DataSubTypeLocal = DataSubType
	endif
	string ListOfQFolders
	//	if UseIndra2Structure = 1 we are using Indra2 data, else return all folders 
	string result
	variable i
	if (UseIndra2Structure)
		//These are standard USAXS types, 
		if(StringMatch("SMR_Int,DSM_Int,R_Int,Blank_R_Int,Monitor,USAXS_PD", "*"+DataSubTypeLocal+"*"))
			if(SlitSmearedData==1)
				result=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "*SMR*", 1)
			elseif(SlitSmearedData==2)
				string tempStr=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "*SMR*", 1)
				result=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "*DSM*", 1)+";"
				for(i=0;i<ItemsInList(tempStr);i+=1)
				//print stringmatch(result, "*"+StringFromList(i, tempStr,";")+"*")
					if(stringmatch(result, "*"+StringFromList(i, tempStr,";")+"*")==0)
						result+=StringFromList(i, tempStr,";")+";"
					endif
				endfor
			else
				result=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "*DSM*", 1)
			endif
		else //this is for non-standard (Tiled) data types. 
			result=IN2G_FindFolderWithWaveTypes("root:", 10, DataSubTypeLocal, 1)
		endif
	elseif (UseQRSStructure)
		make/N=0/FREE/T ResultingWave
		IR2P_FindFolderWithWaveTypesWV("root:", 10, "(?i)^r|i$", 1, ResultingWave)
		//IR2S_SortWaveOfFolders(ResultingWave)
		result=IR3C_CheckForRightQRSTripletWvs(ResultingWave,AllowQRDataOnly)
	else
		result=IN2G_FindFolderWithWaveTypes("root:", 10, "*", 1)
	endif
	
	//now the result contains folder, we want list of parents and grandparents here. create new list...
	string newresult=""
	string tempstr2, tempstr3
	for(i=0;i<ItemsInList(result , ";");i+=1)
		tempstr2=stringFromList(i,result,";")
		tempstr2=RemoveListItem(ItemsInList(tempstr2,":")-1, tempstr2  , ":")
		if(ItemsInList(tempstr2,":")>1)
			tempstr3=RemoveListItem(ItemsInList(tempstr2,":")-1, tempstr2  , ":")
			if(!stringmatch(newresult, "*"+tempstr3+";*" ))
				newresult+=tempstr3+";"
			endif
		endif
		if(!stringmatch(newresult, "*"+tempstr2+";*" ))
			newresult+=tempstr2+";"
		endif
	endfor
	
	newresult=GrepList(newresult, "^((?!Packages).)*$" )
	return newresult
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//**********************************************************************************************************
