#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.37


//*************************************************************************\
//* Copyright (c) 2005 - 2013, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

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
//1.27 added Diameters waves for Modeling II
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
//1.12 added display of separate polulations data from Modeling II.
//1.11 fixed bug which prevented any folders be displayed when no checbox was selected and no match string was used
//1.10 optimization for speed. Just too slow to get anythign done in some major user experiments...  changed following functions:
//1.09 added license for ANL
//version 1.08 - added Unified size distribution and changed global string to help with upgrades. Now the list of known results is updated every time the cod eis run. 
//version 1.07 fixes minor bug for Model input, when the Qs werento recalculated when log-Q choice wa changed. 
//version 1.06 fixes the NIST qis naming structure 3/8/2008. Only q, int, and error are used, resolution wave is nto used at this time. 
//version 1.05 adds capability to be used on child (or sub) panels and graphs. Keep names short, so the total length is below 28 characters (of both HOST and CHILD together)
//version 1.04 adds to "qrs" also "qis" - NIST intended naming structure as of 11/2007 


//How to - readme 
//version 1  7/19/2005 - first release, allows already user type (type Indra2 and QRS logic) of data
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
//	PauseUpdate; Silent 1		// building window...
//	NewPanel /K=1 /W=(2.25,43.25,390,690) as "Test"
//Uncomment either Example 1 or Example 2 
//Example 1 - User data of Irena type
//	string UserDataTypes="DSM_Int;SMR_Int;"
//	string UserNameString="Test me"
//	string XUserLookup="DSM_Int:DSM_Qvec;SMR_Int:SMR_Qvec;"
//	string EUserLookup="DSM_Int:DSM_Error;SMR_Int:SMR_Error;"
//Example 2 - qrs data type
//	string UserDataTypes="r_*;"
//	string UserNameString="Test me"
//	string XUserLookup="r_*:q_*;"
//	string EUserLookup="r_*:s_*;"
//	variable RequireErrorWaves =0
//	variable AllowModelData = 0
//and this creates the controls. 
//	IR2C_AddDataControls("testpackage2","TestPanel2","DSM_Int;M_DSM_Int;R_Int;SMR_Int;M_SMR_Int;","SizesFitIntensity;SizesVolumeDistribution;SizesNumberDistribution;",UserDataTypes,UserNameString,XUserLookup,EUserLookup, RequireErrorWaves, AllowModelData)
//end

//modifications:
//	1.01		if Indra 2 data type is empty, controls will not show...
//	1.03      Modifed PanelControlProcedures to enable user to write "hook" functions which can be run after the selection is made... 
//	Important: There are 4 hook functions, run after folder, Q, intensity, and error data are selected, names must be exactly: 
//	IR2_ContrProc_F_Hook_Proc(), IR2_ContrProc_Q_Hook_Proc(), IR2_ContrProc_R_Hook_Proc(), and IR2_ContrProc_E_Hook_Proc(). 
//	User needs to make sure these can be called with no parameters and that they will not fail if called by different panel!!! 
//	This is important, as they will be called from any panel whic is using this package, so they have to be prrof to that. 
//	I suggest checcking on the name of top active panel window or the current folder...  Example of function is below: 
//Function IR2_ContrProc_Q_Hook_Proc()
//	print getDataFolder(0)
//end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR2C_AddDataControls(PckgDataFolder,PanelWindowName,AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup, RequireErrorWaves,AllowModelData)
	string PckgDataFolder,PanelWindowName, AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup
	variable RequireErrorWaves, AllowModelData
	
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

	IR2C_InitControls(PckgDataFolder,PanelWindowName,AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup, RequireErrorWaves,AllowModelData)
	
	//This is fix to simplify coding all results
	SVAR AllCurrentlyAllowedTypes=root:Packages:IrenaControlProcs:AllCurrentlyAllowedTypes
	if(cmpstr(AllowedResultsTypes,"AllCurrentlyAllowedTypes")==0)
		AllowedResultsTypes=AllCurrentlyAllowedTypes
	endif

	IR2C_AddControlsToWndw(PckgDataFolder,PanelWindowName,AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup, RequireErrorWaves,AllowModelData)
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//Function IR2C_ReInitTheListOfFIleTypes()
//
//	string OldDf=GetDataFolder(1)
//	setdatafolder root:
//	NewDataFolder/O/S root:Packages
//	NewDataFolder/O/S IrenaControlProcs
//
//	SVAR/Z XwaveDataTypesLookup
//	if(!SVAR_Exists(XwaveDataTypesLookup))
//		string/g XwaveDataTypesLookup
//	endif
//	XwaveDataTypesLookup="DSM_Int:DSM_Qvec;"
//	XwaveDataTypesLookup+="M_DSM_Int:M_DSM_Qvec;"
//	XwaveDataTypesLookup+="BCK_Int:BCK_Qvec;"
//	XwaveDataTypesLookup+="M_BCK_Int:M_BCK_Qvec;"
//	XwaveDataTypesLookup+="SMR_Int:SMR_Qvec;"
//	XwaveDataTypesLookup+="M_SMR_Int:M_SMR_Qvec;"
//	XwaveDataTypesLookup+="R_Int:R_Qvec;"
////	XwaveDataTypesLookup+="r*:q*;"
////	XwaveDataTypesLookup+="DSM_Int:DSM_Qvec;"
//	
//	SVAR/Z EwaveDataTypesLookup
//	if(!SVAR_Exists(EwaveDataTypesLookup))
//		string/g EwaveDataTypesLookup
//	endif
//	EwaveDataTypesLookup="DSM_Int:DSM_Error;"
//	EwaveDataTypesLookup+="M_DSM_Int:M_DSM_Error;"
//	EwaveDataTypesLookup+="BCK_Int:BCK_Error;"
//	EwaveDataTypesLookup+="M_BCK_Int:M_BCK_Error;"
//	EwaveDataTypesLookup+="SMR_Int:SMR_Error;"
//	EwaveDataTypesLookup+="M_SMR_Int:M_SMR_Error;"
//	EwaveDataTypesLookup+="R_Int:R_Error;"
////	EwaveDataTypesLookup+="r*:s*;"
//	
//
//	SVAR/Z ResultsEDataTypesLookup
//	if(!SVAR_Exists(ResultsEDataTypesLookup))
//		string/g ResultsEDataTypesLookup
//	endif
//	ResultsEDataTypesLookup="PDDFDistFunction:PDDFErrors;"		//PDDF has error estimates for the result... 
//	ResultsEDataTypesLookup+="SizesVolumeDistribution:SizesVolumeDistErrors;"		//Sizes now have errors also 
//	ResultsEDataTypesLookup+="SizesNumberDistribution:SizesNumberDistErrors;"		//Sizes now have errors also 
//	
//	SVAR/Z ResultsDataTypesLookup
//	if(!SVAR_Exists(ResultsDataTypesLookup))
//		string/g ResultsDataTypesLookup
//	endif
//	//sizes
//	ResultsDataTypesLookup="SizesFitIntensity:SizesFitQvector;"
//	ResultsDataTypesLookup+="SizesVolumeDistribution:SizesDistDiameter;"
//	ResultsDataTypesLookup+="SizesNumberDistribution:SizesDistDiameter;"
//	//unified
//	ResultsDataTypesLookup+="UnifiedFitIntensity:UnifiedFitQvector;"
//	ResultsDataTypesLookup+="UnifSizeDistVolumeDist:UnifSizeDistRadius;"
//	ResultsDataTypesLookup+="UnifSizeDistNumberDist:UnifSizeDistRadius;"
//	ResultsDataTypesLookup+="UniLocalLevel1Unified:UnifiedFitQvector;"
//	ResultsDataTypesLookup+="UniLocalLevel1Pwrlaw:UnifiedFitQvector;"
//	ResultsDataTypesLookup+="UniLocalLevel1Guinier:UnifiedFitQvector;"
//	ResultsDataTypesLookup+="UniLocalLevel2Unified:UnifiedFitQvector;"
//	ResultsDataTypesLookup+="UniLocalLevel2Pwrlaw:UnifiedFitQvector;"
//	ResultsDataTypesLookup+="UniLocalLevel2Guinier:UnifiedFitQvector;"
//	ResultsDataTypesLookup+="UniLocalLevel3Unified:UnifiedFitQvector;"
//	ResultsDataTypesLookup+="UniLocalLevel3Pwrlaw:UnifiedFitQvector;"
//	ResultsDataTypesLookup+="UniLocalLevel3Guinier:UnifiedFitQvector;"
//	ResultsDataTypesLookup+="UniLocalLevel4Unified:UnifiedFitQvector;"
//	ResultsDataTypesLookup+="UniLocalLevel4Pwrlaw:UnifiedFitQvector;"
//	ResultsDataTypesLookup+="UniLocalLevel4Guinier:UnifiedFitQvector;"
//	ResultsDataTypesLookup+="UniLocalLevel5Unified:UnifiedFitQvector;"
//	ResultsDataTypesLookup+="UniLocalLevel5Pwrlaw:UnifiedFitQvector;"
//	ResultsDataTypesLookup+="UniLocalLevel5Guinier:UnifiedFitQvector;"
//	
//	//LSQF
//	ResultsDataTypesLookup+="ModelingNumberDistribution:ModelingDiameters;"
//	ResultsDataTypesLookup+="ModelingVolumeDistribution:ModelingDiameters;"
//	ResultsDataTypesLookup+="ModelingIntensity:ModelingQvector;"
//	ResultsDataTypesLookup+="ModelingNumDist_Pop1:ModelingDia_Pop1;"
//	ResultsDataTypesLookup+="ModelingVolDist_Pop1:ModelingDia_Pop1;"
//	ResultsDataTypesLookup+="ModelingNumDist_Pop2:ModelingDia_Pop2;"
//	ResultsDataTypesLookup+="ModelingVolDist_Pop2:ModelingDia_Pop2;"
//	ResultsDataTypesLookup+="ModelingNumDist_Pop3:ModelingDia_Pop3;"
//	ResultsDataTypesLookup+="ModelingVolDist_Pop3:ModelingDia_Pop3;"
//	ResultsDataTypesLookup+="ModelingNumDist_Pop4:ModelingDia_Pop4;"
//	ResultsDataTypesLookup+="ModelingVolDist_Pop4:ModelingDia_Pop4;"
//	ResultsDataTypesLookup+="ModelingNumDist_Pop5:ModelingDia_Pop5;"
//	ResultsDataTypesLookup+="ModelingVolDist_Pop5:ModelingDia_Pop5;"
//	//Fractals
//	ResultsDataTypesLookup+="FractFitIntensity:FractFitQvector;"
//	ResultsDataTypesLookup+="Mass1FractFitInt:Mass1FractFitQvec;"
//	ResultsDataTypesLookup+="Surf1FractFitInt:Surf1FractFitQvec;"
//	ResultsDataTypesLookup+="Mass2FractFitInt:Mass2FractFitQvec;"
//	ResultsDataTypesLookup+="Surf2FractFitInt:Surf2FractFitQvec;"
//	ResultsDataTypesLookup+="Mass3FractFitInt:Mass3FractFitQvec;"
//	ResultsDataTypesLookup+="Surf3FractFitInt:Surf3FractFitQvec;"
//	ResultsDataTypesLookup+="Mass4FractFitInt:Mass4FractFitQvec;"
//	ResultsDataTypesLookup+="Surf4FractFitInt:Surf4FractFitQvec;"
//	ResultsDataTypesLookup+="Mass5FractFitInt:Mass5FractFitQvec;"
//	ResultsDataTypesLookup+="Surf5FractFitInt:Surf5FractFitQvec;"
//	//Small-angle diffraction
//	ResultsDataTypesLookup+="SADModelIntensity:SADModelQ;"
//	ResultsDataTypesLookup+="SADModelIntPeak1:SADModelQPeak1;"
//	ResultsDataTypesLookup+="SADModelIntPeak2:SADModelQPeak2;"
//	ResultsDataTypesLookup+="SADModelIntPeak3:SADModelQPeak3;"
//	ResultsDataTypesLookup+="SADModelIntPeak4:SADModelQPeak4;"
//	ResultsDataTypesLookup+="SADModelIntPeak5:SADModelQPeak5;"
//	ResultsDataTypesLookup+="SADModelIntPeak6:SADModelQPeak6;"
//	ResultsDataTypesLookup+="SADUnifiedIntensity:SADUnifiedQvector;"
//	//Gels
//	ResultsDataTypesLookup+="DebyeBuecheModelInt:DebyeBuecheModelQvec;"//old, now next line...
//	ResultsDataTypesLookup+="AnalyticalModelInt:AnalyticalModelQvec;"
//	//Reflcecitivty
//	ResultsDataTypesLookup+="ReflModel:ReflQ;"
//	ResultsDataTypesLookup+="SLDProfile:SLDProfileX;SLDProfile:x-scaling;"
//	//PDDF
//	ResultsDataTypesLookup+="PDDFIntensity:PDDFQvector;"
//	ResultsDataTypesLookup+="PDDFChiSquared:PDDFQvector;"
//	ResultsDataTypesLookup+="PDDFDistFunction:PDDFDistances;"
//	ResultsDataTypesLookup+="PDDFGammaFunction:PDDFDistances;"
//	//Guinier-Porod
//	ResultsDataTypesLookup+="GuinierPorodFitIntensity:GuinierPorodFitQvector;"//old, now next line...
//	
//	//NLQSF2
//	ResultsDataTypesLookup+="IntensityModelLSQF2:QvectorModelLSQF2;"
//	ResultsDataTypesLookup+="IntensityModelLSQF2pop6:QvectorModelLSQF2pop6;"
//	ResultsDataTypesLookup+="IntensityModelLSQF2pop1:QvectorModelLSQF2pop1;"
//	ResultsDataTypesLookup+="IntensityModelLSQF2pop2:QvectorModelLSQF2pop2;"
//	ResultsDataTypesLookup+="IntensityModelLSQF2pop3:QvectorModelLSQF2pop3;"
//	ResultsDataTypesLookup+="IntensityModelLSQF2pop5:QvectorModelLSQF2pop5;"
//	ResultsDataTypesLookup+="IntensityModelLSQF2pop4:QvectorModelLSQF2pop4;"
//
//	NVAR/Z DimensionIsDiameter = root:Packages:IR2L_NLSQF:SizeDist_DimensionIsDiameter
//	variable LDimensionISDiameter = 0	
//	if(NVAR_Exists(DimensionIsDiameter))
//		LDimensionISDiameter = DimensionIsDiameter
//	endif
//	if(LDimensionISDiameter) 				//all calculations above are done in radii, if we use Diameters, volume/number distributions needs to be half 
//		ResultsDataTypesLookup+="VolumeDistModelLSQF2:DiametersModelLSQF2;"
//		ResultsDataTypesLookup+="NumberDistModelLSQF2:DiametersModelLSQF2;"
//		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop1:DiametersModelLSQF2pop1;"
//		ResultsDataTypesLookup+="NumberDistModelLSQF2pop1:DiametersModelLSQF2pop1;"
//		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop2:DiametersModelLSQF2pop2;"
//		ResultsDataTypesLookup+="NumberDistModelLSQF2pop2:DiametersModelLSQF2pop2;"
//		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop3:DiametersModelLSQF2pop3;"
//		ResultsDataTypesLookup+="NumberDistModelLSQF2pop3:DiametersModelLSQF2pop3;"
//		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop4:DiametersModelLSQF2pop4;"
//		ResultsDataTypesLookup+="NumberDistModelLSQF2pop4:DiametersModelLSQF2pop4;"
//		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop5:DiametersModelLSQF2pop5;"
//		ResultsDataTypesLookup+="NumberDistModelLSQF2pop5:DiametersModelLSQF2pop5;"
//		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop6:DiametersModelLSQF2pop6;"
//		ResultsDataTypesLookup+="NumberDistModelLSQF2pop6:DiametersModelLSQF2pop6;"
//	else
//		ResultsDataTypesLookup+="VolumeDistModelLSQF2:RadiiModelLSQF2;"
//		ResultsDataTypesLookup+="NumberDistModelLSQF2:RadiiModelLSQF2;"
//		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop1:RadiiModelLSQF2pop1;"
//		ResultsDataTypesLookup+="NumberDistModelLSQF2pop1:RadiiModelLSQF2pop1;"
//		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop2:RadiiModelLSQF2pop2;"
//		ResultsDataTypesLookup+="NumberDistModelLSQF2pop2:RadiiModelLSQF2pop2;"
//		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop3:RadiiModelLSQF2pop3;"
//		ResultsDataTypesLookup+="NumberDistModelLSQF2pop3:RadiiModelLSQF2pop3;"
//		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop4:RadiiModelLSQF2pop4;"
//		ResultsDataTypesLookup+="NumberDistModelLSQF2pop4:RadiiModelLSQF2pop4;"
//		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop5:RadiiModelLSQF2pop5;"
//		ResultsDataTypesLookup+="NumberDistModelLSQF2pop5:RadiiModelLSQF2pop5;"
//		ResultsDataTypesLookup+="VolumeDistModelLSQF2pop6:RadiiModelLSQF2pop6;"
//		ResultsDataTypesLookup+="NumberDistModelLSQF2pop6:RadiiModelLSQF2pop6;"
//	endif		
//
//
//
//
//	//CumulativeSizeDist Curve from Evaluate Size dist
//	ResultsDataTypesLookup+="CumulativeSizeDist:CumulativeDistDiameters;"
//	ResultsDataTypesLookup+="CumulativeSfcArea:CumulativeDistDiameters;"
//	ResultsDataTypesLookup+="MIPVolume:MIPPressure;"
//
//
//	setDataFolder OldDf
//
//end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR2C_InitControls(PckgDataFolder,PanelWindowName,AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup, RequireErrorWaves,AllowModelData)
	string PckgDataFolder,PanelWindowName, AllowedIrenaTypes, AllowedResultsTypes,AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup
	variable RequireErrorWaves,AllowModelData
	
	string OldDf=GetDataFolder(1)
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
	AllCurrentlyAllowedTypes+="IntensityModelLSQF2pop1;NumberDistModelLSQF2pop1;VolumeDistModelLSQF2pop1;"
	AllCurrentlyAllowedTypes+="IntensityModelLSQF2pop2;NumberDistModelLSQF2pop2;VolumeDistModelLSQF2pop2;"
	AllCurrentlyAllowedTypes+="IntensityModelLSQF2pop3;NumberDistModelLSQF2pop3;VolumeDistModelLSQF2pop3;"
	AllCurrentlyAllowedTypes+="IntensityModelLSQF2pop4;NumberDistModelLSQF2pop4;VolumeDistModelLSQF2pop4;"
	AllCurrentlyAllowedTypes+="IntensityModelLSQF2pop5;NumberDistModelLSQF2pop5;VolumeDistModelLSQF2pop5;"
	AllCurrentlyAllowedTypes+="IntensityModelLSQF2pop6;NumberDistModelLSQF2pop6;VolumeDistModelLSQF2pop6;"
	AllCurrentlyAllowedTypes+= "ReflModel;SLDProfile;"
	AllCurrentlyAllowedTypes+="ModelingNumberDistribution;ModelingVolumeDistribution;ModelingIntensity;FractFitIntensity;DebyeBuecheModelInt;AnalyticalModelInt;"
	AllCurrentlyAllowedTypes+="ModelingNumDist_Pop1;ModelingVolDist_Pop1;Mass1FractFitInt;Surf1FractFitInt;UniLocalLevel1Unified;UniLocalLevel1Pwrlaw;UniLocalLevel1Guinier;"
	AllCurrentlyAllowedTypes+="ModelingNumDist_Pop2;ModelingVolDist_Pop2;Mass2FractFitInt;Surf2FractFitInt;UniLocalLevel2Unified;UniLocalLevel2Pwrlaw;UniLocalLevel2Guinier;"
	AllCurrentlyAllowedTypes+="ModelingNumDist_Pop3;ModelingVolDist_Pop3;Mass3FractFitInt;Surf3FractFitInt;UniLocalLevel3Unified;UniLocalLevel3Pwrlaw;UniLocalLevel3Guinier;"
	AllCurrentlyAllowedTypes+="ModelingNumDist_Pop4;ModelingVolDist_Pop4;Mass4FractFitInt;Surf4FractFitInt;UniLocalLevel4Unified;UniLocalLevel4Pwrlaw;UniLocalLevel4Guinier;"
	AllCurrentlyAllowedTypes+="ModelingNumDist_Pop5;ModelingVolDist_Pop5;Mass5FractFitInt;Surf5FractFitInt;UniLocalLevel5Unified;UniLocalLevel5Pwrlaw;UniLocalLevel5Guinier;"
	AllCurrentlyAllowedTypes+="CumulativeSizeDist;CumulativeSfcArea;MIPVolume;SADModelIntensity;SADModelIntPeak1;SADModelIntPeak2;SADModelIntPeak3;"
	AllCurrentlyAllowedTypes+="SADModelIntPeak4;SADModelIntPeak5;SADModelIntPeak6;"
	AllCurrentlyAllowedTypes+="PDDFIntensity;PDDFDistFunction;PDDFChiSquared;SADUnifiedIntensity;PDDFGammaFunction;"
	AllCurrentlyAllowedTypes+="UnifSizeDistVolumeDist;UnifSizeDistNumberDist;"
	AllCurrentlyAllowedTypes+="GuinierPorodFitIntensity;"


	string/g AllKnownToolsResults
	AllKnownToolsResults = "Unified Fit;Size Distribution;Modeling II;Modeling I;Small-angle diffraction;Analytical models;Fractals;PDDF;Reflectivity;Guinier-Porod;"

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
	ResultsDataTypesLookup+="AnalyticalModelInt:AnalyticalModelQvec;"
	//Reflcecitivty
	ResultsDataTypesLookup+="ReflModel:ReflQ;"
	ResultsDataTypesLookup+="SLDProfile:SLDProfileX;SLDProfile:x-scaling;"
	//PDDF
	ResultsDataTypesLookup+="PDDFIntensity:PDDFQvector;"
	ResultsDataTypesLookup+="PDDFChiSquared:PDDFQvector;"
	ResultsDataTypesLookup+="PDDFDistFunction:PDDFDistances;"
	ResultsDataTypesLookup+="PDDFGammaFunction:PDDFDistances;"
	//Guinier-Porod
	ResultsDataTypesLookup+="GuinierPorodFitIntensity:GuinierPorodFitQvector;"//old, now next line...
	
	//NLQSF2
	ResultsDataTypesLookup+="IntensityModelLSQF2:QvectorModelLSQF2;"
	ResultsDataTypesLookup+="IntensityModelLSQF2pop6:QvectorModelLSQF2pop6;"
	ResultsDataTypesLookup+="IntensityModelLSQF2pop1:QvectorModelLSQF2pop1;"
	ResultsDataTypesLookup+="IntensityModelLSQF2pop2:QvectorModelLSQF2pop2;"
	ResultsDataTypesLookup+="IntensityModelLSQF2pop3:QvectorModelLSQF2pop3;"
	ResultsDataTypesLookup+="IntensityModelLSQF2pop5:QvectorModelLSQF2pop5;"
	ResultsDataTypesLookup+="IntensityModelLSQF2pop4:QvectorModelLSQF2pop4;"

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
	PopupMenu QvecDataName,pos={15,79},size={265,21},proc=IR2C_PanelPopupControl,title="Wave with X   ", help={"Select wave with data to be used on X axis (Q, diameters, etc)"}, bodywidth=200
	execute("PopupMenu QvecDataName,mode=1,popvalue=\"---\",value= \"---;\"+IR2P_ListOfWaves(\"Xaxis\",\"*\",\""+TopPanel+"\")")
	PopupMenu IntensityDataName,pos={15,102},size={265,21},proc=IR2C_PanelPopupControl,title="Wave with Y   ", help={"Select wave with data to be used on Y data (Intensity, distributions)"}, bodywidth=200
	execute("PopupMenu IntensityDataName,mode=1,popvalue=\"---\",value= \"---;\"+IR2P_ListOfWaves(\"Yaxis\",\"*\",\""+TopPanel+"\")")
	PopupMenu ErrorDataName,pos={15,126},size={265,21},proc=IR2C_PanelPopupControl,title="Error Wave   ", help={"Select wave with error data"}, bodywidth=200
	execute("PopupMenu ErrorDataName,mode=1,popvalue=\"---\",value= \"---;\"+IR2P_ListOfWaves(\"Error\",\"*\",\""+TopPanel+"\")")

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
	String ctrlName=SV_Struct.ctrlName
	Variable varNum=SV_Struct.dval
	String varStr=SV_Struct.sVal
	String varName=SV_Struct.vName

	string oldDf=GetDataFolder(1)
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

	string oldDf=GetDataFolder(1)
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

//Function IR2C_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
//	String ctrlName
//	Variable checked

Function IR2C_InputPanelCheckboxProc(CB_Struct)
	STRUCT WMCheckboxAction &CB_Struct

	if(CB_Struct.eventcode<1 ||CB_Struct.eventcode>2)
		return 0
	endif
	
	String ctrlName=CB_Struct.ctrlName
	Variable checked=CB_Struct.checked
	string oldDf=GetDataFolder(1)
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

	Execute ("SetVariable WaveMatchStr disable=0, win="+TopPanel)
	Execute ("SetVariable FolderMatchStr disable=0, win="+TopPanel)

	if (cmpstr(ctrlName,"UseIndra2Data")==0)
		//here we control the data structure checkbox
		if (checked)
			UseQRSData=0
			UseResults=0
			UseUserDefinedData=0
			UseModelData=0
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
		endif
	endif
	if (cmpstr(ctrlName,"UseResults")==0)
		//here we control the data structure checkbox
		if (checked)
			UseIndra2Data=0
			UseQRSData=0
			UseUserDefinedData=0
			UseModelData=0
			Execute ("SetVariable WaveMatchStr disable=1, win="+TopPanel)
		endif
	endif
	if (cmpstr(ctrlName,"UseUserDefinedData")==0)
		//here we control the data structure checkbox
		if (checked)
			UseIndra2Data=0
			UseQRSData=0
			UseResults=0
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
	
	
//	if (cmpstr(ctrlName,"QLogScale")==0 || cmpstr(ctrlName,"UseModelData")==0)
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
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
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
		
		variable i
		string tempstr
		string newList=""
		For(I=0;i<ItemsInList(FolderList , ";" );i+=1)
			tempstr=StringFromList(i, FolderList , ";")
			if(!stringmatch(Tempstr,"root:packages:*"))
				NewList+=Tempstr+";"
			endif
		endfor
	return newList
//	return FolderList
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function/T IR2P_GenStringOfFolders([winNm])
	string winNm

	//variable startTicks=ticks
	//part to copy everywhere...	
	string oldDf=GetDataFolder(1)
	string TopPanel
	if( ParamIsDefault(winNm))
		TopPanel=WinName(0,65)
		winNm = TopPanel
	else
		TopPanel=winNm
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
	///endof common block  
	string ListOfQFolders
	string result="", tempResult, resultShort=""
	variable i, j, StartTime, AlreadyIn
	string tempStr="", temp1, temp2, temp3
	variable StaleWave=1


	if (UseIndra2Structure)
		SVAR/Z ListOfIndraFolders = $(CntrlLocation+":ListOfIndraFolders")
		NVAR/Z SetTimeOfIndraFoldersStr = $(CntrlLocation+":SetTimeOfIndraFoldersStr")
		if(NVAR_Exists(SetTimeOfIndraFoldersStr) && SVAR_Exists(ListOfIndraFolders) && (datetime - SetTimeOfIndraFoldersStr)<5)
			result = ListOfIndraFolders
			SetTimeOfIndraFoldersStr = datetime			//lets keep it as updated here...
		else
			tempResult=IN2G_FindFolderWithWvTpsList("root:USAXS:", 10,LocallyAllowedIndra2Data, 1) //contains list of all folders which contain any of the tested Intensity waves...
			//match to user mask using greplist
			if(strlen(FolderMatchStr)>0)
				//really does not like *
				tempResult=GrepList(tempResult, IR2C_PreparematchString(FolderMatchStr) )
			endif
			//done, now rest...
			//now prune the folders off the ones which do not contain full triplet of waves...
			For(j=0;j<ItemsInList(tempResult);j+=1)			//each folder one by one
				temp1 = stringFromList(j,tempResult)
				//AlreadyIn=0
				for(i=0;i<ItemsInList(LocallyAllowedIndra2Data);i+=1)			//each type of data one by one...
					temp2=stringFromList(i,LocallyAllowedIndra2Data)
					if(cmpstr("---",IR2P_CheckForRightIN2TripletWvs(TopPanel,stringFromList(j,tempResult),stringFromList(i,LocallyAllowedIndra2Data)))!=0 )//&& AlreadyIn<1)
						//AlreadyIn=1
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
			SetTimeOfIndraFoldersStr = datetime
		endif	
	elseif (UseQRSStructure)
			Wave/Z/T ResultingWave=$(CntrlLocation+":ResultingWave")
			SVAR/Z  ListOfQFoldersLookup = $(CntrlLocation+":ListOfQFolders")
			NVAR/Z SetTimeOfQFoldersStr = $(CntrlLocation+":SetTimeOfQFoldersStr")
			if(SVAR_Exists(ListOfQFoldersLookup) && (datetime - SetTimeOfQFoldersStr) < 5)
				result=ListOfQFoldersLookup	
				SetTimeOfQFoldersStr = datetime
			else
				make/N=0/O/T $(CntrlLocation+":ResultingWave")
				Wave/T ResultingWave=$(CntrlLocation+":ResultingWave")
				string/g  $(CntrlLocation+":ListOfQFolders")
				variable/g  $(CntrlLocation+":SetTimeOfQFoldersStr")
				SVAR/Z  ListOfQFoldersLookup = $(CntrlLocation+":ListOfQFolders")
				NVAR/Z SetTimeOfQFoldersStr = $(CntrlLocation+":SetTimeOfQFoldersStr")
				IR2P_FindFolderWithWaveTypesWV("root:", 10, "(?i)^r||i$", 1, ResultingWave)
				//IR2P_FindFolderWithWaveTypesWV("root:", 10, "*i*", 1, ResultingWave)
				if(strlen(FolderMatchStr)>0)
					variable ii
					for(ii=numpnts(ResultingWave)-1;ii>=0;ii-=1)
					//	if(!GrepString(ResultingWave[ii],FolderMatchStr))
						if(!GrepString(ResultingWave[ii],IR2C_PreparematchString(FolderMatchStr)))
							DeletePoints ii, 1, ResultingWave
						endif
					endfor
					//ListOfQFolders=GrepList(ListOfQFolders, FolderMatchStr )
				endif
				ListOfQFolders=IR2P_CheckForRightQRSTripletWvs(TopPanel,ResultingWave,WaveMatchStr)		
				//match to user mask using greplist
				//done, now rest...
				ListOfQFolders=IR2P_CleanUpPackagesFolder(ListOfQFolders)
				ListOfQFolders=IR2P_RemoveDuplicateStrfLst(ListOfQFolders)
				ListOfQFoldersLookup = ListOfQFolders
				result=ListOfQFolders
				SetTimeOfQFoldersStr = datetime
				//print "recalculated lookup"
			endif
	elseif (UseResults)
		SVAR/Z ListOfResultsFolders = $(CntrlLocation+":ListOfResultsFolders")
		NVAR/Z SetTimeOfResultsFoldersStr = $(CntrlLocation+":SetTimeOfResultsFoldersStr")
		if(NVAR_Exists(SetTimeOfResultsFoldersStr) && SVAR_Exists(ListOfResultsFolders) && (datetime - SetTimeOfResultsFoldersStr)<5)
			result = ListOfResultsFolders
			SetTimeOfResultsFoldersStr = datetime
		else
			temp3=""
			For(i=0;i<ItemsInList(LocallyAllowedResultsData);i+=1)
				temp3+=stringFromList(i,LocallyAllowedResultsData)+"*;"
			endfor
			tempResult=IN2G_FindFolderWithWvTpsList("root:", 10,temp3, 1) //contains list of all folders which contain any of the tested Y waves... But may not contain the whole duplex of waves...
					//match to user mask using greplist
			if(strlen(FolderMatchStr)>0)
				tempResult=GrepList(tempResult, IR2C_PreparematchString(FolderMatchStr) )
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
			SetTimeOfResultsFoldersStr = datetime
			//print "recalculated lookup"
		endif
	elseif (UseUserDefinedData)
		SVAR/Z ListOfUserDefinedFolders = $(CntrlLocation+":ListOfUserDefinedFolders")
		NVAR/Z SetTimeOfUserDefFoldersStr = $(CntrlLocation+":SetTimeOfUserDefFoldersStr")
		if(NVAR_Exists(SetTimeOfUserDefFoldersStr) && SVAR_Exists(ListOfUserDefinedFolders) && (datetime - SetTimeOfUserDefFoldersStr)<5)
			result = ListOfUserDefinedFolders
			SetTimeOfUserDefFoldersStr = datetime
		else
			tempResult=IN2G_FindFolderWithWvTpsList("root:", 10,LocallyAllowedUserData, 1) //contains list of all folders which contain any of the tested Intensity waves...
			//match to user mask using greplist
			if(strlen(FolderMatchStr)>0)
				tempResult=GrepList(tempResult, IR2C_PreparematchString(FolderMatchStr) )
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
			SetTimeOfUserDefFoldersStr = datetime
		endif
	else
		result=IN2G_NewFindFolderWithWaveTypes("root:", 10, "*", 1)         //any data.
		
            //match to user mask using greplist
            if(strlen(FolderMatchStr)>0)
                  result=GrepList(result, IR2C_PreparematchString(FolderMatchStr) )
            endif
           result= IR2P_CheckForRightUsrTripletWvs(TopPanel, result,"*",IR2C_PreparematchString(WaveMatchStr))
	endif
	//create short list...
	String LastFolderPath, tempStrItem, FolderPath, resultShortWP
	resultShortWP=""
	LastFolderPath = ""//		RemoveFromList(stringFromList(ItemsInList(tempStrItem,":")-1, tempStrItem,":"), tempStrItem,":")	//stringFromList(ItemsInList(stringFromList(j,result),":")-1,stringFromList(j,result),":")+";"
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
//print "the long one"
//print resultShortWP
//print "now the shorter one"
//print resultShort
//print "done"
//print StringFromList(20,resultShortWP)
//print StringFromList(20,resultShort)
	setDataFolder OldDf
	return resultShort
end
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function/T IR2P_RemoveDuplicateStrfLst(StrList)
	string StrList

	
	variable i
	string result=""///stringFromList(0,StrList,";")+";"
	string tempStr
	For(i=0;i<ItemsInList(StrList,";");i+=1)
		tempStr=stringFromList(i,StrList,";")
		if(!stringmatch(result, "*"+tempStr+"*" ))		//surprisingly, this is faster that GrepString... 
		//if(!GrepString(result, stringFromList(i,StrList,";")))
			result+=tempStr+";"
		endif
	endfor
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

	string oldDf=GetDataFolder(1)
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

	string oldDf=GetDataFolder(1)
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
					if(stringmatch(";"+AllWaves, ";*q"+tempStr+";*" )||stringmatch(";"+AllWaves, ";*az"+tempStr+";*" )||stringmatch(";"+AllWaves, ";*d"+tempStr+";*" )||stringmatch(";"+AllWaves, ";*t"+tempStr+";*" )||stringmatch(";"+AllWaves, ";*m"+tempStr+";*" ))
						matchX=1
					endif
					if(stringmatch(";"+AllWaves,";*s"+tempStr+";*" ))
						matchE=1
					endif
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
		string tempresult=""
	//start of old method
//		variable i
//		for (i=0;i<ItemsInList(ListOfWaves);i+=1)
//			if (stringMatch(StringFromList(i,ListOfWaves),type))
//				tempresult+=StringFromList(i,ListOfWaves)+";"
//			endif
//		endfor
	//end of old method
	//new method
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

	string oldDf=GetDataFolder(1)
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

	string oldDf=GetDataFolder(1)
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
	string oldDf=GetDataFolder(1)
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
					For (j=0;j<ItemsInList(existingYWvs);j+=1)
					//this is purely wrong here. We need to just test, that the xwave is here for the y wave, nothing else... ZRewire this to make sense... 
//						if (stringMatch(";"+existingXWvs,"*;"+StringFromList(j,existingYWvs)) && (!RequireErrorWvs || stringMatch(";"+existingEWvs,"*;"+StringFromList(j,existingYWvs))))
//							if(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(j,existingYWvs)[strlen(tempstringY),inf],MatchMeTo[strlen(tempstringX),inf])==0)
								result+=StringFromList(j,existingYWvs)+";"
//							endif
//						endif
					endfor
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
				
				else									//asume IN2 type data

					tempstringY2=stringFromList(1,tempstringY,"*")
					tempstringX2=stringFromList(1,tempstringX,"*")
					tempstringE2=stringFromList(1,tempstringE,"*")
					For (j=0;j<ItemsInList(existingEWvs);j+=1)
//						if (stringMatch(";"+existingXWvs,"*;"+StringFromList(j,existingEWvs)[0,strlen(StringFromList(j,existingEWvs))-strlen(tempstringE)]+tempstringX2+";*") && (stringMatch(";"+existingYWvs,"*;"+StringFromList(j,existingEWvs)[0,strlen(StringFromList(j,existingEWvs))-strlen(tempstringE)]+tempstringY2+";*")))
//							if(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(j,existingEWvs)[strlen(tempstringE),inf],MatchMeTo[strlen(tempstringX),inf])==0)
								result+=StringFromList(j,existingEWvs)+";"
//							endif
//						endif
					endfor

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
		endif
	elseif(UseQRSStructure) 
		tempStringX=IR2P_RemoveDuplicateStrfLst(IR2P_ListOfWavesOfType("q*",tempresult)+IR2P_ListOfWavesOfType("*q",tempresult)+IR2P_ListOfWavesOfType("t*",tempresult)+IR2P_ListOfWavesOfType("m*",tempresult)+IR2P_ListOfWavesOfType("d*",tempresult)+IR2P_ListOfWavesOfType("a*",tempresult))
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
				ts=tmpstr2[1,inf]
				tx=tempStringX
				if (((stringMatch(";"+tx,"*q"+ts+";*")||stringMatch(";"+tx,"*t"+ts+";*")||stringMatch(";"+tx,"*d"+ts+";*")||stringMatch(";"+tx,"*m"+ts+";*")) && (!RequireErrorWvs || stringMatch(";"+tempStringE,"*s"+ts+";*"))) || (stringMatch(";"+tx,"*q"+ts+";*")) || (stringMatch(";"+tx,"*"+tmpstr2[0,strlen(tmpstr2)-2]+"q;*") && (stringMatch(";"+tempStringE,"*"+tmpstr2[0,strlen(tmpstr2)-2]+"s;*"))))
					if(cmpstr(MatchMeTo,"*")==0 || cmpstr(tmpstr2,"r"+MatchMeTo[1,inf])==0 || cmpstr(tmpstr2,"r"+MatchMeTo[2,inf])==0)
						result+=StringFromList(j,tempStringY)+";"
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
				//thsi needed to be spliut sicne QIS data starting with s and ending with _s as error were not trerated right 3/25/2012
				elseif (stringMatch(";"+tempStringY,"*"+tmpstr2[0,strlen(tmpstr2)-2]+"i;*")&& stringMatch(";"+tempStringX,"*"+tmpstr2[0,strlen(tmpstr2)-2]+"q;*"))		//QIS
					if((cmpstr(MatchMeTo,"*")==0 || cmpstr(tmpstr2,"s"+MatchMeTo[1,inf])==0  || cmpstr(tmpstr2,"s"+MatchMeTo[2,inf])==0)&&(stringmatch(tmpstr2,"*_s")))
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
				tt1=stringFromList(0,tmpLookupStr)
				tt2=stringFromList(1,tmpLookupStr)
				EndStr1="_"+stringFromList(1,MatchMeTo,"_")	//this is current index _XX	
				if(Stringmatch(tempresult, "*"+tt1+EndStr1+";*"))
					result+=tt1+EndStr1+";"
				endif
				if(strlen(tt2)>0 && Stringmatch(tempresult, "*"+tt2+EndStr1+";*"))
					result+=tt2+EndStr1+";"
				endif
			else		//this is call from GUI and so we need to figure out the order number ourselves... 
				tmpLookupStr = IR2C_ReverseLookup(ResultsDataTypesLookup,stringFromList(0,QDf,"_"))
				tt1=stringFromList(0,tmpLookupStr)
				tt2=stringFromList(1,tmpLookupStr)
				EndStr1="_"+stringFromList(1,QDf,"_")	//this is current index _XX	
				if(Stringmatch(tempresult, "*"+tt1+EndStr1+";*"))
					result+=tt1+EndStr1+";"
				endif
				if(strlen(tt2)>0 &&Stringmatch(tempresult, "*"+tt2+EndStr1+";*"))
					result+=tt2+EndStr1+";"
				endif
			
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
//	print result
	return result
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************************
Function/S IR2C_ReverseLookup(StrToSearch,Keywrd)
	string StrToSearch,Keywrd
	
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
//Function IR2C_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
Function IR2C_PanelPopupControl(Pa) : PopupMenuControl
	STRUCT WMPopupAction &Pa

	if(Pa.eventCode!=2)
		return 0
	endif
	String ctrlName=Pa.ctrlName
	Variable popNum=Pa.popNum
	String popStr=Pa.popStr

	//part to copy everywhere...	
	string oldDf=GetDataFolder(1)
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
			//10/27/2013 - changed lies below, why were the top lines commented out when they work (and the ones below do not?)
			Execute ("PopupMenu IntensityDataName mode=1, value=\""+IntDf +";\"+IR2P_ListOfWaves(\"Yaxis\",\"*\",\""+TopPanel+"\"), win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1, value=\""+EDf +";\"+IR2P_ListOfWaves(\"Error\",\"*\",\""+TopPanel+"\"), win="+TopPanel)
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
			Execute ("PopupMenu IntensityDataName mode="+num2str(WhichListItem(IntDf, TempYlist, ";")+1)+",value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode="+num2str(WhichListItem(EDf, tempEList, ";")+1)+",value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
//			Execute ("PopupMenu IntensityDataName mode=1, value=\""+IntDf +";\"+IR2P_ListOfWaves(\"Yaxis\",\""+QDf+"\",\""+TopPanel+"\"), win="+TopPanel)
//			Execute ("PopupMenu ErrorDataName mode=1, value=\""+EDf +";\"+IR2P_ListOfWaves(\"Error\",\""+QDf+"\",\""+TopPanel+"\"), win="+TopPanel)
		elseif(UseResults)
			QDf=stringFromList(0,TempXlist)
			IntDf=stringFromList(0,TempYlist)
			EDf=stringFromList(0,TempElist)
			Execute ("PopupMenu IntensityDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			Execute ("PopupMenu QvecDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempXList\", win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
		elseif(UseUserDefinedData)
			QDf=stringFromList(0,TempXlist)
			IntDf=stringFromList(0,TempYlist)
			EDf=stringFromList(0,TempElist)
			Execute ("PopupMenu IntensityDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			Execute ("PopupMenu QvecDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempXList\", win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
		else
			IntDf="---"
			QDf="---"
			EDf="---"
			Execute ("PopupMenu IntensityDataName mode=1,value= #\"\\\"---;\\\"+root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			Execute ("PopupMenu QvecDataName mode=1,value= #\"\\\"---;\\\"+root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempXList\", win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1,value= #\"\\\"---;\\\"+root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
		endif

//		Execute ("PopupMenu IntensityDataName proc=IR2C_PanelPopupControl, win="+TopPanel)
//		Execute ("PopupMenu QvecDataName proc=IR2C_PanelPopupControl, win="+TopPanel)
//		Execute ("PopupMenu ErrorDataName proc=IR2C_PanelPopupControl, win="+TopPanel)


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
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//
//Function/T IR2C_ListWavesForPopups(WhichWave,TopPanel,CntrlLocation,UseIndra2Structure,UseQRSStructure,UseResults)
//	string WhichWave,CntrlLocation, TopPanel
//	variable UseIndra2Structure,UseQRSStructure,UseResults		
//
//	string result=""
//	string AllWaves=""
//	variable i, j
//	SVAR Dtf=$(CntrlLocation+":DataFolderName")
//	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
//	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
//	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
//	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
//
//	SVAR XwaveDataTypesLookup=root:Packages:IrenaControlProcs:XwaveDataTypesLookup
//	SVAR EwaveDataTypesLookup=root:Packages:IrenaControlProcs:EwaveDataTypesLookup
//	SVAR ResultsDataTypesLookup=root:Packages:IrenaControlProcs:ResultsDataTypesLookup
//
//	string LocallyAllowedIndra2Data=StringByKey(TopPanel, ControlAllowedIrenaTypes,"=",">")
//	string LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
//	
//	AllWaves = IN2G_CreateListOfItemsInFolder(Dtf,2)
//	if (cmpstr(WhichWave,"Y")==0)
//		if(UseIndra2Structure)
//			For(i=0;i<ItemsInList(LocallyAllowedIndra2Data);i+=1)
//				For(j=0;j<ItemsInList(AllWaves);j+=1)
//					if(cmpstr(stringfromList(i,LocallyAllowedIndra2Data),stringfromList(j,AllWaves))==0)
//						result+=stringfromList(i,LocallyAllowedIndra2Data)+";"
//					endif
//				endfor	
//			endfor
//		elseif(UseQRSStructure)
//			For(i=0;i<ItemsInList(LocallyAllowedIndra2Data);i+=1)
//				For(j=0;j<ItemsInList(AllWaves);j+=1)
//					if(cmpstr(stringfromList(i,LocallyAllowedIndra2Data),stringfromList(j,AllWaves))==0)
//						result+=stringfromList(i,LocallyAllowedIndra2Data)+";"
//					endif
//				endfor	
//			endfor
//		endif
//	endif
//	if (cmpstr(WhichWave,"X")==0)
//		if(UseIndra2Structure)
//			For(i=0;i<ItemsInList(LocallyAllowedIndra2Data);i+=1)
//				For(j=0;j<ItemsInList(AllWaves);j+=1)
//					if(cmpstr(stringByKey(stringfromList(i,LocallyAllowedIndra2Data),XwaveDataTypesLookup),stringfromList(j,AllWaves))==0)
//						result+=stringByKey(stringfromList(i,LocallyAllowedIndra2Data),XwaveDataTypesLookup)+";"
//					endif
//				endfor	
//			endfor
//		elseif(UseQRSStructure)
//			For(i=0;i<ItemsInList(LocallyAllowedIndra2Data);i+=1)
//				For(j=0;j<ItemsInList(AllWaves);j+=1)
//					if(cmpstr(stringfromList(i,LocallyAllowedIndra2Data),stringfromList(j,AllWaves))==0)
//						result+=stringfromList(i,LocallyAllowedIndra2Data)+";"
//					endif
//				endfor	
//			endfor
//		endif
//	endif
//	if (cmpstr(WhichWave,"E")==0)
//		if(UseIndra2Structure)
//			For(i=0;i<ItemsInList(LocallyAllowedIndra2Data);i+=1)
//				For(j=0;j<ItemsInList(AllWaves);j+=1)
//					if(cmpstr(stringByKey(stringfromList(i,LocallyAllowedIndra2Data),EwaveDataTypesLookup),stringfromList(j,AllWaves))==0)
//						result+=stringByKey(stringfromList(i,LocallyAllowedIndra2Data),EwaveDataTypesLookup)+";"
//					endif
//				endfor	
//			endfor
//		elseif(UseQRSStructure)
//			For(i=0;i<ItemsInList(LocallyAllowedIndra2Data);i+=1)
//				For(j=0;j<ItemsInList(AllWaves);j+=1)
//					if(cmpstr(stringfromList(i,LocallyAllowedIndra2Data),stringfromList(j,AllWaves))==0)
//						result+=stringfromList(i,LocallyAllowedIndra2Data)+";"
//					endif
//				endfor	
//			endfor
//		endif
//	endif
//	return result
//end
//
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//**********************************************************************************************
//**********************************************************************************************

Function IR2P_FindFolderWithWaveTypesWV(startDF, levels, WaveTypes, LongShortType, ResultingWave)
        String startDF, WaveTypes                  // startDF requires trailing colon.
        Variable levels, LongShortType		//set 1 for long type and 0 for short type return
        wave/T ResultingWave
        			 
        String dfSave
        String list = "", templist, tempWvName
        variable i, skipRest
        
       dfSave = GetDataFolder(1)
     	 DFREF startDFRef = $(startDF)
   	 //if (!DataFolderRefStatus(startDFRef))
  	//	return 0
  	 //endif
       //SetDataFolder startDF
      templist = IN2G_ConvertDataDirToList(DataFolderDir(2,startDFRef))
      //templist = IN2G_ConvertDataDirToList(DataFolderDir(2))
 	if (strlen(GrepList(templist,WaveTypes))>0)
			if (LongShortType)
		      			Redimension /N=(numpnts(ResultingWave)+1) ResultingWave
		      			ResultingWave[numpnts(ResultingWave)-1]=startDF
		      	else
		      			Redimension /N=(numpnts(ResultingWave)+1) ResultingWave
		      			ResultingWave[numpnts(ResultingWave)-1]=GetDataFolder(0)
	      		endif
      	endif
 
        levels -= 1
        if (levels <= 0)
                return 1
        endif
        
        String subDF
        Variable index = 0, npnts
  	  Make/Free/T/N=0 FoldersToScanWv
  	  variable NumOfFolders= CountObjectsDFR(startDFRef, 4)
  	  for(i=0;i<NumOfFolders;i+=1)
  	  	npnts=numpnts(FoldersToScanWv)
  	  	redimension/N=(npnts+1) FoldersToScanWv
  	  	FoldersToScanWv[npnts] = GetIndexedObjNameDFR(startDFRef, 4, i )
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
        
      // SetDataFolder(dfSave)
        return 1
End

//**********************************************************************************************
//**********************************************************************************************

Function/S IR2C_ReturnKnownToolResults(ToolName)
	string ToolName
	
	string KnownToolResults=""

	SVAR KnownTools= root:Packages:IrenaControlProcs:AllKnownToolsResults
	// "Unified Fit;Size Distribution;Modeling II;Modeling I;Small-angle diffraction;Analytical models;Fractals;PDDF;Reflectivity;"
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
	elseif(stringmatch(ToolName,"Modeling II"))
		ListOfLookups = GrepList(ResultsDataTypesLookup, "ModelLSQF",0, ";" )
	endif



	variable i
	For(i=0;i<ItemsInList(ListOfLookups  , ";");i+=1)
		KnownToolResults += stringFromList(0,stringFromList(i,ListOfLookups,";"),":")+";"
	endfor
	
	
	return KnownToolResults
end
//**********************************************************************************************
//**********************************************************************************************

Function/S IR2C_PrepareMatchString(StrIn)
	string StrIn
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
