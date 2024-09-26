#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.30

Constant IR2SversionNumber=1.30
//*************************************************************************\
//* Copyright (c) 2005 - 2025, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.30 added ability to save separate ppopulation data in Modeling
//1.29 fix probem with DSM data folders showing as QRS data folders which caused issues. 
//1.28 added better regular expression cheat sheet on the panel. 
//1.27 added getHelp button calling to www manual
//1.26 added in popup grandparent folder to the parent folder to reduce scope. 
//1.25 added ability to sort data by minutes (_xyzmin), pct (_xyzpct), and  temperature (_xyzC). 
//1.24 fixed bug in Scripting tool which caused qrs start folder return only ones with qrs, but not qds, and other "semi" qrs data 
//1.23 Modeling - fixed the preservation of user choices on error settings and Intensity scaling. 
//1.22 added AfterDataLoaded_Hook() to Modeling call function to enable user modify something after the data set is loaded. 
//1.21 added for QRS data wave name match string. 
//1.20 Plotting tool now - if not opened will open now, not abort. Fixed Buttons for Guinier-Porod and Size Dist with uncertainities appering in wrong time. 
//1.19 fix for Diameters/Radii option in Modeling - it was failing to add such data in Plotting tool. 
//1.18 will set cursors for first and last point of data, if not set by user ahead of fitting. Sync FolderNameStr and set WavenameStr=""
//1.17 minor fix when list fo folders contained ;; somehow and we got stale content in the listbox. 
//1.16 fix to make compatible with changes in Controls procedures. 
//1.15 added skip review of fitting parameters for Unified fit improvement. 
//1.14 fixed bug in calling Plotting tool with results
//1.13 modified to handle chanigng of the data type between the scripting tool and the tool being called. 
//1.12 Added Guinier-Porod as controlled tool and fixed minor Folder selection bug for other tools 
//1.11 modified to handle d, t, and m type QRS data (d-spacing, two theta, and distance) for needs to Nika users
//1.10 added handling of uncertainities (errors) for Results data type (needed for Sizes)
//1.09 significant increase in speed due to changes to Control procedures.
//1.08 added Scripting ability for results in plotting tool I
//1.07 yet another fix for Size distribution tool;. It was not loading the new data properly. 
//1.06 added sorting order controls and added functionality for the plotting tool I 
//1.05 fixed bug in scripting Unified fit, eventcode was not set correctly.  Added match string (using grep, no * needed), added check versions. 
//1.04 fixed bug where the tool was missign the one before last folder (wrong wave length)... 
//1.03 support for single data set Modeling
//1.02 FIxed Scripting of Size distribution where we wer emissing eventcode=2  which caused the data not to be updated beteen fits.
//1.01 added license for ANL

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_ScriptingTool()

	IN2G_CheckScreenSize("height",670)
	
	IR2S_InitScriptingTool()
	
	IR2S_UpdateListOfAvailFiles()
	IR2S_SortListOfAvailableFldrs()
	DoWindow IR2S_ScriptingToolPnl
	if(V_Flag)
		DoWindow/F IR2S_ScriptingToolPnl
	else
		Execute("IR2S_ScriptingToolPnl()")
		IR1_UpdatePanelVersionNumber("IR2S_ScriptingToolPnl", IR2SversionNumber,1)
	endif

end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR2S_MainCheckVersion()	
	DoWindow IR2S_ScriptingToolPnl
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR2S_ScriptingToolPnl", IR2SversionNumber))
			DoAlert /T="The Scripting tool panel was created by incorrect version of Irena " 1, "Scripting tool may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				KillWIndow/Z IR2S_ScriptingToolPnl
				IR2S_ScriptingTool()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR2S_InitScriptingTool()
				IR2S_UpdateListOfAvailFiles()
				IR2S_SortListOfAvailableFldrs()
			endif
		endif
	endif
end


//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if(stringmatch(ctrlName,"StartFolderSelection"))
		//Update the listbox using start folde popStr
		SVAR StartFolderName=root:Packages:Irena:ScriptingTool:StartFolderName
		StartFolderName = popStr
		IR2S_UpdateListOfAvailFiles()
		IR2S_SortListOfAvailableFldrs()
	endif
	
	if(stringmatch(ctrlName,"SortFolders"))
		//Update the listbox using start folde popStr
		SVAR FolderSortString=root:Packages:Irena:ScriptingTool:FolderSortString
		FolderSortString = popStr
		IR2S_SortListOfAvailableFldrs()
	endif
	if(stringmatch(ctrlName,"ToolResultsSelector"))
		//Update the listbox using start folde popStr
		SVAR SelectedResultsTool=root:Packages:Irena:ScriptingTool:SelectedResultsTool
		SelectedResultsTool = popStr
		string ListOfAvailableResults=IR2C_ReturnKnownToolResults(popStr,"")
		execute("PopupMenu ResultsTypeSelector, win=IR2S_ScriptingToolPnl, mode=1, value=IR2C_ReturnKnownToolResults(\""+popStr+"\",\"\")")
		SVAR SelectedResultsType=root:Packages:Irena:ScriptingTool:SelectedResultsType
		SelectedResultsType = stringFromList(0,ListOfAvailableResults)
		IR2S_UpdateListOfAvailFiles()
		IR2S_SortListOfAvailableFldrs()
	endif
	if(stringmatch(ctrlName,"ResultsTypeSelector"))
		//Update the listbox using start folde popStr
		SVAR SelectedResultsType=root:Packages:Irena:ScriptingTool:SelectedResultsType
		SelectedResultsType = popStr
		IR2S_UpdateListOfAvailFiles()
		IR2S_SortListOfAvailableFldrs()
	endif
	if(stringmatch(ctrlName,"ResultsGenerationToUse"))
		//Update the listbox using start folde popStr
		SVAR ResultsGenerationToUse=root:Packages:Irena:ScriptingTool:ResultsGenerationToUse
		ResultsGenerationToUse = popStr
		IR2S_UpdateListOfAvailFiles()
		IR2S_SortListOfAvailableFldrs()
	endif	
End


//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_CheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	NVAR UseIndra2Data=root:Packages:Irena:ScriptingTool:UseIndra2Data
	NVAR UseQRSdata=root:Packages:Irena:ScriptingTool:UseQRSdata
	NVAR UseResults = root:Packages:Irena:ScriptingTool:UseResults
	if(stringmatch(ctrlname,"UseIndra2Data"))
		if(checked)
			UseQRSdata =0
			UseResults = 0
		endif
		//update listbox 
		IR2S_UpdateListOfAvailFiles()
		IR2S_SortListOfAvailableFldrs()
	endif
	if(stringmatch(ctrlname,"UseQRSdata"))
		if(checked)
			UseIndra2Data =0
			UseResults=0
		endif
		//update listbox 
		IR2S_UpdateListOfAvailFiles()
		IR2S_SortListOfAvailableFldrs()
	endif
	if(stringmatch(ctrlname,"UseResults"))
		if(checked)
			UseIndra2Data =0
			UseQRSdata=0
		endif
		//update listbox 
		IR2S_UpdateListOfAvailFiles()
		IR2S_SortListOfAvailableFldrs()
	endif
	Setvariable WaveNameMatchString, win= IR2S_ScriptingToolPnl ,disable =!UseQRSdata

	Button FitWithUnified,win= IR2S_ScriptingToolPnl , disable=UseResults
	Button FitWithSizes,win= IR2S_ScriptingToolPnl , disable=UseResults
	Button FitWithMoldelingII,win= IR2S_ScriptingToolPnl , disable=UseResults
	Button FitWithGuinierPorod,win= IR2S_ScriptingToolPnl , disable=UseResults
	Button FitWithSizesU,win= IR2S_ScriptingToolPnl , disable=UseResults
	//Button CallPlottingToolII,pos={90,450},size={200,15},proc=IR2S_ButtonProc,title="Run Plotting tool with selected data"
	PopupMenu ToolResultsSelector win= IR2S_ScriptingToolPnl , disable=!UseResults
	PopupMenu ResultsTypeSelector win= IR2S_ScriptingToolPnl , disable=!UseResults
	PopupMenu ResultsGenerationToUse win= IR2S_ScriptingToolPnl , disable=!UseResults
	
End
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR2S_ScriptToolSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
			if(stringmatch(sva.ctrlName,"FolderNameMatchString"))
				IR2S_UpdateListOfAvailFiles()
				IR2S_SortListOfAvailableFldrs()
			endif
			if(stringmatch(sva.ctrlName,"WaveNameMatchString"))
				IR2S_UpdateListOfAvailFiles()
				IR2S_SortListOfAvailableFldrs()
			endif
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_ButtonProc(ctrlName) : ButtonControl
	String ctrlName

	wave SelectionOfAvailableData=root:Packages:Irena:ScriptingTool:SelectionOfAvailableData
	if(stringmatch(ctrlName,"GetHelp"))
		//IR2S_HelpPanel()
		IN2G_OpenWebManual("Irena/ScriptingTool.html")
	endif
	if(stringmatch(ctrlName,"GetLogbook"))
		//generate help in notebook.
		IR2S_GetLogbook()
	endif
	if(stringmatch(ctrlName,"AllData"))
		SelectionOfAvailableData=1
	endif
	if(stringmatch(ctrlName,"NoData"))
		SelectionOfAvailableData=0
	endif
	if(stringmatch(ctrlName,"FitWithUnified"))
		IR2S_FItWithUnifiedFit()
	endif
	if(stringmatch(ctrlName,"FitWithGuinierPorod"))
		IR2S_FitWithGuinierPorod()
	endif
	if(stringmatch(ctrlName,"FitWithSizes"))
		IR2S_FItWithSizes(0)
	endif
	if(stringmatch(ctrlName,"FitWithSizesU"))
		IR2S_FItWithSizes(1)
	endif

	if(stringmatch(ctrlName,"FitWithMoldelingII"))
		IR2S_FItWithModelingII()
	endif
	if(stringmatch(ctrlName,"CallPlottingToolII"))
		IR2S_CallWithPlottingToolII(1)
	endif
	if(stringmatch(ctrlName,"CallPlottingToolIIA"))
		IR2S_CallWithPlottingToolII(0)
	endif

	
	
End

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR2S_HelpPanel()
	String nb = "ScriptingToolHelp"
	DoWIndow ScriptingToolHelp
	if(!V_Flag)
		NewNotebook/N=$nb/F=1/V=1/OPTS=14/K=1/W=(732,67,1253,700)
		Notebook $nb defaultTab=36, statusWidth=252
		Notebook $nb showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
		Notebook $nb newRuler=Heading, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",12,3,(0,0,65535)}
		Notebook $nb ruler=Heading, text="Help for Irena Scripting tool \r"
		Notebook $nb text="\r"
		Notebook $nb ruler=Normal, fSize=12, text="To use scripting tool, please open one fo the tools it can control:\r"
		Notebook $nb text="\r"
		Notebook $nb text="1. Unified fit\r"
		Notebook $nb text="2. Size distribution\r"
		Notebook $nb text="3. Modeling (NOTE: supported only with one input data set, not \"Multiple Input data sets\" selected!)\r"
		Notebook $nb text="\r"
		Notebook $nb text="Setup the tool with fittign parameters on representative case (cases) and make sure the data selection w"
		Notebook $nb text="ith cursors (Unified/Size dist) or with Qmin/Qmax is appropriate for all data you intend to analyze. Mak"
		Notebook $nb text="e sure the fitting limits are appropriate and correct (important especially for Unified). \r"
		Notebook $nb text="\r"
		Notebook $nb text="Select all needed checkboxes. \r"
		Notebook $nb text="\r"
		Notebook $nb text="Keep the tool panels and graphs opened, scripting tool needs them to work.\r"
		Notebook $nb text="\r"
		Notebook $nb text="Select data in Scripting tool. Select data type and pick the folders to analyze. \r"
		Notebook $nb text=">   Use the Match(grep) field to reduce clutter, use ONLY string to match to, no * needed, uses grep tool. \r"
		Notebook $nb text=">   To pick separate folders, use ctrl/cmd click. \r"
		Notebook $nb text=">   To select range of folders, use click for start, shift-click for end of range. \r"
		Notebook $nb text="\r"
		Notebook $nb text="Select output options. Note that some options may not be applicablefor specific tool. \r"
		Notebook $nb text="\r"
		Notebook $nb text="If you are running Unified fit or Modeling you can reset parameters between the fits. This option is "
		Notebook $nb text="not applicable for Size distribution. \r"
		Notebook $nb text="\r"
		Notebook $nb text="NOTE: If the fit fails, nothing is recorded in the folder/waves and some notes are commented into the no"
		Notebook $nb text="tebook.  The run is not stopped, next sample is analyzed. \r"
		Notebook $nb text="However: If if you run out of fitting limits the tools stop themselves and break the queue. This cannot be caught by this tool."
		Notebook $nb text="\r"
		Notebook $nb fStyle=2
		Notebook $nb text=" E-mail me Igor experiments exhibiting problems with this tool so I can fix it. There are potentially ma"
		Notebook $nb text="ny chances for failures I may have not predicted.\r"
	else
		DoWIndow/F ScriptingToolHelp
	endif
	AutoPositionWindow/R=IR2S_ScriptingToolPnl ScriptingToolHelp

end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Window IR2S_ScriptingToolPnl() 
	PauseUpdate    		// building window...
	NewPanel/K=1 /W=(28,44,412,660) as "Scripting tool"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 1,textrgb= (0,0,65535)
	DrawText 29,29,"Scripting tool"

	if(!DataFolderExists("root:Packages:IrenaControlProcs"))
		string UserDataTypes=""
		string UserNameString=""
		string XUserLookup=""
		string EUserLookup=""
		IR2C_AddDataControls("Irena:WAXS","IR3W_WAXSPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	endif

	Button GetHelp,pos={280,4},size={90,15},proc=IR2S_ButtonProc,title="Get help"
	Button GetHelp,fSize=10,fStyle=2, fColor=(65535,32768,32768)
	Button GetLogbook,pos={280,21},size={90,15},proc=IR2S_ButtonProc,title="Open logbook"
	Button GetLogbook,fSize=10,fStyle=2
//	Button GetHelp,pos={280,105},size={80,15},fColor=(65535,32768,32768), proc=IR2S_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}

	PopupMenu StartFolderSelection,pos={10,40},size={130,15},proc=IR2S_PopMenuProc,title="Select start folder"
	PopupMenu StartFolderSelection,mode=1,popvalue=root:Packages:Irena:ScriptingTool:StartFolderName,value= #"\"root:;\"+IR3C_GenStringOfFolders2(root:Packages:Irena:ScriptingTool:UseIndra2Data, root:Packages:Irena:ScriptingTool:UseQRSdata,2,1)"

	CheckBox UseIndra2data,pos={302,45},size={76,14},proc=IR2S_CheckProc,title="USAXS?"
	CheckBox UseIndra2data,variable= root:Packages:Irena:ScriptingTool:UseIndra2Data
	CheckBox UseQRSdata,pos={302,63},size={64,14},proc=IR2S_CheckProc,title="QRS data?"
	CheckBox UseQRSdata,variable= root:Packages:Irena:ScriptingTool:UseQRSdata
	CheckBox UseResults,pos={302,81},size={64,14},proc=IR2S_CheckProc,title="Results?"
	CheckBox UseResults,variable= root:Packages:Irena:ScriptingTool:UseResults

	PopupMenu ToolResultsSelector,pos={10,65},size={230,15},fStyle=2,proc=IR2S_PopMenuProc,title="Which tool results?    ", disable=!(root:Packages:Irena:ScriptingTool:UseResults)
	PopupMenu ToolResultsSelector,mode=1,popvalue=root:Packages:Irena:ScriptingTool:SelectedResultsTool,value= #"root:Packages:IrenaControlProcs:AllKnownToolsResults"//, bodyWidth=170

	PopupMenu ResultsTypeSelector,pos={10,90},size={230,15},fStyle=2,proc=IR2S_PopMenuProc,title="Which results?          ", disable=!(root:Packages:Irena:ScriptingTool:UseResults)
	PopupMenu ResultsTypeSelector,mode=1,popvalue=root:Packages:Irena:ScriptingTool:SelectedResultsType,value= IR2C_ReturnKnownToolResults(root:Packages:IrenaControlProcs:AllKnownToolsResults,"")//, bodyWidth=170

	PopupMenu ResultsGenerationToUse,pos={10,115},size={230,15},fStyle=2,proc=IR2S_PopMenuProc,title="Results Generation?           ", disable=!(root:Packages:Irena:ScriptingTool:UseResults)
	PopupMenu ResultsGenerationToUse,mode=1,popvalue=root:Packages:Irena:ScriptingTool:ResultsGenerationToUse,value= "Latest;_0;_1;_2;_3;_4;_5;_6;_7;_8;_9;_10;"

	ListBox DataFolderSelection,pos={4,135},size={372,180}, mode=9
	ListBox DataFolderSelection,listWave=root:Packages:Irena:ScriptingTool:ListOfAvailableData
	ListBox DataFolderSelection,selWave=root:Packages:Irena:ScriptingTool:SelectionOfAvailableData

	//SVAR FolderNameMatchString=root:Packages:Irena:ScriptingTool:FolderNameMatchString
	SetVariable FolderNameMatchString,pos={10,325},size={170,15}, proc=IR2S_ScriptToolSetVarProc,title="Match (RegEx)"
	Setvariable FolderNameMatchString,fSize=10,fStyle=2, variable=root:Packages:Irena:ScriptingTool:FolderNameMatchString

	SetVariable WaveNameMatchString,pos={200,325},size={170,15}, proc=IR2S_ScriptToolSetVarProc,title="Wave Match (RegEx)"
	Setvariable WaveNameMatchString,fSize=10,fStyle=2, variable=root:Packages:Irena:ScriptingTool:WaveNameMatchString, disable =!root:Packages:Irena:ScriptingTool:UseQRSdata

	Button AllData,pos={170,350},size={100,15},proc=IR2S_ButtonProc,title="Select all data"
	Button AllData,fSize=10,fStyle=2
	Button NoData,pos={270,350},size={100,15},proc=IR2S_ButtonProc,title="DeSelect all data"
	Button NoData,fSize=10,fStyle=2

	PopupMenu SortFolders,pos={10,348},size={130,20},fStyle=2,proc=IR2S_PopMenuProc,title="Sort Folders"
	PopupMenu SortFolders,mode=1,popvalue=root:Packages:Irena:ScriptingTool:FolderSortString,value= #"\"---;Alphabetical;Reverse Alphabetical;_xyz;_xyz.ext;Reverse _xyz;Reverse _xyz.ext;Sxyz_;Reverse Sxyz_;_xyzmin;_xyzpct;_xyzC;_xyz_000;Reverse _xyz_000;\""

	Button FitWithUnified,pos={90,375},size={200,15},proc=IR2S_ButtonProc,title="Run Unified Fit on selected data"
	Button FitWithUnified,fSize=10,fStyle=2, disable=(root:Packages:Irena:ScriptingTool:UseResults)

	Button FitWithGuinierPorod,pos={90,395},size={200,15},proc=IR2S_ButtonProc,title="Run Guinier-Porod on selected data"
	Button FitWithGuinierPorod,fSize=10,fStyle=2, disable=(root:Packages:Irena:ScriptingTool:UseResults)

	Button FitWithSizes,pos={20,415},size={160,15},proc=IR2S_ButtonProc,title="Run Size dist. no uncert."
	Button FitWithSizes,fSize=10,fStyle=2, disable=(root:Packages:Irena:ScriptingTool:UseResults)
	Button FitWithSizesU,pos={210,415},size={160,15},proc=IR2S_ButtonProc,title="Run Size distr. w/uncert."
	Button FitWithSizesU,fSize=10,fStyle=2, disable=(root:Packages:Irena:ScriptingTool:UseResults)
	Button FitWithMoldelingII,pos={90,435},size={200,15},proc=IR2S_ButtonProc,title="Run Modeling on selected data"
	Button FitWithMoldelingII,fSize=10,fStyle=2, disable=(root:Packages:Irena:ScriptingTool:UseResults)
	Button CallPlottingToolII,pos={20,455},size={160,15},proc=IR2S_ButtonProc,title="Run (w/reset) Plotting tool"
	Button CallPlottingToolII,fSize=10,fStyle=2
	Button CallPlottingToolIIA,pos={210,455},size={160,15},proc=IR2S_ButtonProc,title="Append to Plotting tool"
	Button CallPlottingToolIIA,fSize=10,fStyle=2

	CheckBox SaveResultsInNotebook,pos={10,490},size={64,14},proc=IR2S_CheckProc,title="Save results in notebook?"
	CheckBox SaveResultsInNotebook,variable= root:Packages:Irena:ScriptingTool:SaveResultsInNotebook
	CheckBox ResetBeforeNextFit,pos={10,510},size={64,14},proc=IR2S_CheckProc,title="Reset before next fit? (Unif./Model.)"
	CheckBox ResetBeforeNextFit,variable= root:Packages:Irena:ScriptingTool:ResetBeforeNextFit
	CheckBox SaveResultsInFldrs,pos={10,530},size={64,14},proc=IR2S_CheckProc,title="Save results in folders?"
	CheckBox SaveResultsInFldrs,variable= root:Packages:Irena:ScriptingTool:SaveResultsInFldrs
	CheckBox ExportSeparatePopData,pos={30,550},size={64,14},proc=IR2S_CheckProc,title="Modeling - save separate Pop results?"
	CheckBox ExportSeparatePopData,variable= root:Packages:Irena:ScriptingTool:ExportSeparatePopData
	CheckBox SaveResultsInWaves,pos={10,570},size={64,14},proc=IR2S_CheckProc,title="Save results in waves (Modeling)?"
	CheckBox SaveResultsInWaves,variable= root:Packages:Irena:ScriptingTool:SaveResultsInWaves
	
	

	//DrawText 170,505,"RegEx - Not contain: ^((?!string).)*$"
	TitleBox Regex1 title="\Zr150Regex cheat sheet",pos={240,490},frame=0,fstyle=2, size={184,15}, fColor=(1,16019,65535)
	TitleBox Regex2 title="\Zr130Contain str: 		  str",pos={220,510},frame=0,fstyle=2,size={144,15}
	TitleBox Regex3 title="\Zr130str1 AND str2: 	str1.*str2",pos={220,525},frame=0,fstyle=2,size={144,15}
	TitleBox Regex4 title="\Zr130Not contain:     ^((?!str).)*$",pos={220,540},frame=0,fstyle=2,size={184,15}
	TitleBox Regex5 title="\Zr130str1 OR str2: 	 str1|str2",pos={220,555},frame=0,fstyle=2,size={184,15}
	
	IR2S_UpdateListOfAvailFiles()
	IR2S_SortListOfAvailableFldrs()
EndMacro

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function IR2S_GetLogbook()

	DoWIndow ScriptingToolNbk
	if(V_Flag)
		DoWindow/F ScriptingToolNbk
	else
		DoWIndow SAS_FitLog
		if(V_Flag)
			DoWindow/F SAS_FitLog
		endif
	endif
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

//**************************************************************************************
//**************************************************************************************
//static Function IR2S_SortWaveOfFolders(WaveToSort)
//	wave/T WaveToSort
//	
//	make/N=(numpnts(WaveToSort))/Free IndexWv
//	IndexWv = ItemsInList(WaveToSort[p],":")
//	Sort IndexWv, WaveToSort
//end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function/T IR2S_GenStringOfFolders(StartFolder,UseIndra2Structure, UseQRSStructure, UseResults, SlitSmearedData, AllowQRDataOnly)
	string StartFolder
	variable UseIndra2Structure, UseQRSStructure, UseResults, SlitSmearedData, AllowQRDataOnly
		//SlitSmearedData =0 for DSM data, 
		//                          =1 for SMR data 
		//                    and =2 for both
		// AllowQRDataOnly=1 if Q and R data are allowed only (no error wave). For QRS data ONLY!
	
	string ListOfQFolders
	string TempStr, tempStr2
	variable i
	SVAR FolderNameMatchString=root:Packages:Irena:ScriptingTool:FolderNameMatchString
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
//		ListOfQFolders=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "q*", 1)
//		result=IR1_ReturnListQRSFolders(ListOfQFolders,AllowQRDataOnly)
			make/N=0/FREE/T ResultingWave
			IR2P_FindFolderWithWaveTypesWV(StartFolder, 10, "(?i)^r|i$", 1, ResultingWave)
			//IR2P_FindFolderWithWaveTypesWV("root:", 10, "*i*", 1, ResultingWave)
			result=IR3C_CheckForRightQRSTripletWvs(ResultingWave,AllowQRDataOnly)
	elseif (UseResults)
		SVAR SelectedResultsTool=root:Packages:Irena:ScriptingTool:SelectedResultsTool
		SVAR SelectedResultsType=root:Packages:Irena:ScriptingTool:SelectedResultsType
		SVAR ResultsGenerationToUse=root:Packages:Irena:ScriptingTool:ResultsGenerationToUse
		if(stringmatch(ResultsGenerationToUse,"Latest"))
			result=IN2G_FindFolderWithWvTpsList(StartFolder, 10,SelectedResultsType+"*", 1) 
		else
			result=IN2G_FindFolderWithWvTpsList(StartFolder, 10,SelectedResultsType+ResultsGenerationToUse, 1) 
		endif
	else
		result=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*", 1)
	endif
	//leave ONLY folders matching FolderNameMatchStringstring is set
	if(strlen(FolderNameMatchString)>0)
		result = GrepList(result, FolderNameMatchString ) 
	endif
	if(stringmatch(";",result[0]))
		result = result [1, inf]
	endif
	return result
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function IR2S_SortListOfAvailableFldrs()

	SVAR FolderSortString=root:Packages:Irena:ScriptingTool:FolderSortString
	Wave/T ListOfAvailableData=root:Packages:Irena:ScriptingTool:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:Irena:ScriptingTool:SelectionOfAvailableData
	if(numpnts(ListOfAvailableData)<2)
		return 0
	endif
	Duplicate/Free SelectionOfAvailableData, TempWv
	variable i, j
	j=0
	string tempstr 
	SelectionOfAvailableData=0
	variable InfoLoc, DIDNotFindInfo
	DIDNotFindInfo =0
	if(stringMatch(FolderSortString,"---"))
		//nothing to do
	elseif(stringMatch(FolderSortString,"Alphabetical"))
		Sort /A ListOfAvailableData, ListOfAvailableData
	elseif(stringMatch(FolderSortString,"Reverse Alphabetical"))
		Sort /A /R ListOfAvailableData, ListOfAvailableData
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
		while (InfoLoc<1)// && j<(numpnts(ListOfAvailableData))) 
		if(DIDNotFindInfo)
			DoAlert/T="Information not found" 0, "Cannot find location of _xyzmin information, sorting alphabetically" 
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
			DoAlert/T="Information not found" 0, "Cannot find location of _xyzC information, sorting alphabetically" 
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
	elseif(stringMatch(FolderSortString,"_xyz"))
			//For(i=0;i<numpnts(TempWv);i+=1)
		TempWv = IN2G_FindNumIndxForSort(ListOfAvailableData[p])
			//TempWv[i] = str2num(StringFromList(ItemsInList(ListOfAvailableData[i]  , "_")-1, ListOfAvailableData[i]  , "_"))
			//endfor
		Sort TempWv, ListOfAvailableData
	elseif(stringMatch(FolderSortString,"Reverse _xyz"))
			//For(i=0;i<numpnts(TempWv);i+=1)
		TempWv = IN2G_FindNumIndxForSort(ListOfAvailableData[i])
			//TempWv[i] = str2num(StringFromList(ItemsInList(ListOfAvailableData[i]  , "_")-1, ListOfAvailableData[i]  , "_"))
			//endfor
		Sort /R  TempWv, ListOfAvailableData
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
	endif

end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

//WaveNameMatchString


Function IR2S_UpdateListOfAvailFiles()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:ScriptingTool
	
	NVAR UseIndra2Data=root:Packages:Irena:ScriptingTool:UseIndra2Data
	NVAR UseQRSdata=root:Packages:Irena:ScriptingTool:UseQRSData
	NVAR UseResults=root:Packages:Irena:ScriptingTool:UseResults
	SVAR StartFolderName=root:Packages:Irena:ScriptingTool:StartFolderName
	SVAR WaveNameMatchString=root:Packages:Irena:ScriptingTool:WaveNameMatchString
	string LStartFolder, FolderContent
	if(stringmatch(StartFolderName,"---"))
		LStartFolder="root:"
	else
		LStartFolder = StartFolderName
	endif
	string CurrentFolders=IR2S_GenStringOfFolders(LStartFolder,UseIndra2Data, UseQRSData,UseResults, 2,1)

	Wave/T ListOfAvailableData=root:Packages:Irena:ScriptingTool:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:Irena:ScriptingTool:SelectionOfAvailableData
	variable i, j, match
	string TempStr, FolderCont

		
	Redimension/N=(ItemsInList(CurrentFolders , ";")) ListOfAvailableData, SelectionOfAvailableData
	j=0
	For(i=0;i<ItemsInList(CurrentFolders , ";");i+=1)
		//TempStr = RemoveFromList("USAXS",RemoveFromList("root",StringFromList(i, CurrentFolders , ";"),":"),":")
		TempStr = ReplaceString(LStartFolder, StringFromList(i, CurrentFolders , ";"),"")
		if(strlen(TempStr)>0)
			ListOfAvailableData[j] = tempStr
			j+=1
		endif
	endfor
	if(j<ItemsInList(CurrentFolders , ";"))
		DeletePoints j, numpnts(ListOfAvailableData)-j, ListOfAvailableData, SelectionOfAvailableData
	endif
	//now we need to clean up the folder list if wave name match string is used, valid ONLy for qrs data type...
	if(strlen(WaveNameMatchString)>0 && UseQRSdata)
		For(i=numpnts(ListOfAvailableData)-1;I>=0;i-=1)
		      match = 0
			TempStr = LStartFolder+ListOfAvailableData[i]
			DFREF tmpDFR = $(TempStr)
			//FolderCont = ReplaceString(",",RemoveEnding(StringFromList(1,DataFolderDir(2, tmpDFR ),":"),";\r"),";")+";"
			FolderCont = IN2G_ConvertDataDirToList(DataFolderDir(2,tmpDFR))
			if(strlen(GrepList(FolderCont,"(?i)^r.*"+WaveNameMatchString+"|"+WaveNameMatchString+".*(?i)i$"))<1)
				DeletePoints i, 1, ListOfAvailableData, SelectionOfAvailableData
			endif
		endfor		
	endif
	SelectionOfAvailableData = 0
	setDataFolder OldDF
end


//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_InitScriptingTool()
	
	DFref oldDf= GetDataFolderDFR()

	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S Irena
	NewDataFolder/O/S ScriptingTool
	
	string ListOfVariables
	string ListOfStrings
	variable i

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="StartFolderName;FolderNameMatchString;FolderSortString;SelectedResultsType;SelectedResultsTool;ResultsGenerationToUse;"
	ListOfStrings+="WaveNameMatchString;"
	//"DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;SaveResultsInNotebook;ResetBeforeNextFit;SaveResultsInFldrs;SaveResultsInWaves;"
	ListOfVariables+="ExportSeparatePopData;"

	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	
	SVAR StartFolderName	
	if(strlen(StartFolderName)<1)
		StartFolderName="root:"
	endif
	
	SVAR SelectedResultsType
	SVAR SelectedResultsTool
	SVAR ResultsGenerationToUse
	if(strlen(SelectedResultsType)<1)
		SelectedResultsType="UnifiedFitIntensity"
	endif
	if(strlen(SelectedResultsTool)<1)
		SelectedResultsTool="Unified Fit"
	endif
	if(strlen(ResultsGenerationToUse)<1)
		ResultsGenerationToUse="Latest"
	endif
	
	Make/O/T/N=(0) ListOfAvailableData
	Make/O/N=(0) SelectionOfAvailableData
	
	NVAR UseIndra2Data
	NVAR UseQRSdata
	NVAR UseResults
	if(UseIndra2Data+UseQRSdata+UseResults!=1)
		UseIndra2Data=0
		UseQRSdata=1
		UseResults=0
	endif
	setDataFolder OldDF
end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR2S_CallWithPlottingToolII(reset)
	variable reset
	DoWindow IR1P_ControlPanel
	if(!V_Flag)
		//Abort  "The Plotting Tool II panel must be opened"
		IR1P_GeneralPlotTool()
	else
		DoWIndow/F IR1P_ControlPanel 
	endif
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:ScriptingTool
	//set to same data types...
	NVAR STUseIndra2Data = root:Packages:Irena:ScriptingTool:UseIndra2Data
	NVAR STUseQRSdata =root:Packages:Irena:ScriptingTool:UseQRSdata
	NVAR STUseResults=root:Packages:Irena:ScriptingTool:UseResults

	
	NVAR PTUseIndra2Data=root:Packages:GeneralplottingTool:UseIndra2Data
	NVAR PTUseQRSdata=root:Packages:GeneralplottingTool:UseQRSdata
	NVAR PTUseResults=root:Packages:GeneralplottingTool:UseResults
	SVAR FolderMatchStr=root:Packages:IrenaControlProcs:IR1P_ControlPanel:FolderMatchStr
	SVAR WaveMatchStr=root:Packages:IrenaControlProcs:IR1P_ControlPanel:WaveMatchStr
	SVAR ScriptToolFMS=root:Packages:Irena:ScriptingTool:FolderNameMatchString
	SVAR ScriptToolWMS=root:Packages:Irena:ScriptingTool:WaveNameMatchString
	if(STUseQRSdata)
		WaveMatchStr=ScriptToolWMS
	else
		WaveMatchStr=""
	endif
	FolderMatchStr=ScriptToolFMS
	PTUseResults=STUseResults
	PTUseQRSdata=STUseQRSdata
	PTUseIndra2Data=STUseIndra2Data
	STRUCT WMCheckboxAction CB_Struct
	CB_Struct.eventcode=2
	if(PTUseIndra2Data)
		CB_Struct.ctrlName="UseIndra2Data"
	elseif(PTUseQRSdata)
		CB_Struct.ctrlName="UseQRSData"
	elseif(PTUseResults)
		CB_Struct.ctrlName="UseResults"
	else
		Abort "error, report it"
	endif
	CB_Struct.checked=1
	CB_Struct.win="IR1P_ControlPanel"	
	IR2C_InputPanelCheckboxProc(CB_Struct)
	Wave/T ListOfAvailableData = root:Packages:Irena:ScriptingTool:ListOfAvailableData
	Wave SelectionOfAvailableData =root:Packages:Irena:ScriptingTool:SelectionOfAvailableData
	NVAR UseIndra2Data = root:Packages:Irena:ScriptingTool:UseIndra2Data
	variable NumOfSelectedFiles = sum(SelectionOfAvailableData)
	NVAR SaveResultsInNotebook = root:Packages:Irena:ScriptingTool:SaveResultsInNotebook
	NVAR ResetBeforeNextFit = root:Packages:Irena:ScriptingTool:ResetBeforeNextFit
	NVAR SaveResultsInFldrs = root:Packages:Irena:ScriptingTool:SaveResultsInFldrs
	NVAR SaveResultsInWaves = root:Packages:Irena:ScriptingTool:SaveResultsInWaves
	SVAR StartFolderName = root:Packages:Irena:ScriptingTool:StartFolderName
	SVAR SelectedResultsTool=root:Packages:Irena:ScriptingTool:SelectedResultsTool
	SVAR SelectedResultsType=root:Packages:Irena:ScriptingTool:SelectedResultsType
	SVAR ResultsGenerationToUse=root:Packages:Irena:ScriptingTool:ResultsGenerationToUse
	SVAR ResultsDataTypesLookup=root:Packages:IrenaControlProcs:ResultsDataTypesLookup

	string LStartFolder, TempXName, TempYName
	if(stringmatch(StartFolderName,"---"))
		LStartFolder="root:"
	else
		LStartFolder=StartFolderName
	endif
	variable i, j
	string CurrentFolderName, TempStr, result, tempStr2, tempStr3
	if(reset)
		IR1P_InputPanelButtonProc("ResetAll")				//resent graph?
	endif	
	variable AddedFiles=0
	Print " **** working : adding data sets to plotting tool"
	string LastDiameterOrRadius=""
	variable raiseWarning=0
	For(i=0;i<numpnts(ListOfAvailableData);i+=1)
		if(SelectionOfAvailableData[i]>0.5)
			CurrentFolderName = LStartFolder + ListOfAvailableData[i]
			//OK, now we know which files to process	
			//now stuff the name of the new folder in the folder name in plotting tool.
			SVAR DataFolderName = root:Packages:GeneralplottingTool:DataFolderName
			DataFolderName = CurrentFolderName
			//now except for case when we use Indra 2 data we need to reload the other wave names... 
			STRUCT WMPopupAction PU_Struct
			PU_Struct.ctrlName = "SelectDataFolder"
			PU_Struct.popNum=-1
			PU_Struct.eventcode=2
			PU_Struct.popStr=DataFolderName
			PU_Struct.win = "IR1P_ControlPanel"
			IR2C_PanelPopupControl(PU_Struct)
			//PopupMenu SelectDataFolder win=IR1P_ControlPanel, popmatch=CurrentFolderName
			PopupMenu SelectDataFolder win=IR1P_ControlPanel, value="---;"+IR2P_GenStringOfFolders(winNm="IR1P_ControlPanel")
			PopupMenu SelectDataFolder win=IR1P_ControlPanel, popmatch=StringFromList(ItemsInList(DataFolderName,":")-1,DataFolderName,":")
			//not enough if using results, which user can select what to plot very specifically...
			if(STUseResults)
				if(stringmatch(ResultsGenerationToUse,"Latest"))
					DFREF TestFldr=$(CurrentFolderName)
					TempStr = GrepList(stringfromList(1,RemoveEnding(DataFolderDir(2, TestFldr),";\r"),":"), SelectedResultsType,0,",")
					//and need to find the one with highest generation number.
					result = stringFromList(0,TempStr,",")
					For(j=1;j<ItemsInList(TempStr,",");j+=1)
						tempStr2=stringFromList(j,TempStr,",")
						if(str2num(StringFromList(ItemsInList(result,"_")-1, result, "_"))<str2num(StringFromList(ItemsInList(tempStr2,"_")-1, tempStr2, "_")))
							result = tempStr2
						endif
					endfor
					TempYName=result
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
					TempXName=TempXName+"_"+StringFromList(ItemsInList(result,"_")-1, result, "_")
				else	//known result we want to use... It should exist (guarranteed by prior code)
					DFREF TestFldr=$(CurrentFolderName)
					TempYName=SelectedResultsType+ResultsGenerationToUse
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
					TempXName=TempXName+ResultsGenerationToUse
					//TempXName=StringByKey(SelectedResultsType, ResultsDataTypesLookup  , ":", ";")+ResultsGenerationToUse
				endif
				if(strlen(LastDiameterOrRadius)==0)
					LastDiameterOrRadius=TempXName[0,10]
				else
					if(!StringMatch(LastDiameterOrRadius, TempXName[0,10]))
						raiseWarning=1
					endif
				endif
				SVAR XnameStr=root:Packages:GeneralplottingTool:QWavename
				XnameStr = TempXName
				PopupMenu QvecDataName win=IR1P_ControlPanel, popmatch=TempXName
				PU_Struct.ctrlName = "QvecDataName"
				PU_Struct.popNum=-1
				PU_Struct.eventcode=2
				PU_Struct.popStr=TempXName
				PU_Struct.win = "IR1P_ControlPanel"			
				IR2C_PanelPopupControl(PU_Struct)

				SVAR YnameStr=root:Packages:GeneralplottingTool:IntensityWaveName
				YnameStr = TempYName
				PopupMenu IntensityDataName win=IR1P_ControlPanel, popmatch=TempYName
				//and update errors if needed...
				PU_Struct.ctrlName = "IntensityDataName"
				PU_Struct.popNum=-1
				PU_Struct.eventcode=2
				PU_Struct.popStr=TempYName
				PU_Struct.win = "IR1P_ControlPanel"			
				IR2C_PanelPopupControl(PU_Struct)
			endif
			IR1P_InputPanelButtonProc("AddDataToGraph")			//add data
			AddedFiles+=1
			if(mod(AddedFiles,25)==0)
				print "Added  "+num2str(AddedFiles)+" data sets to Plotting tool"
			endif
		endif	
	endfor
	if(raiseWarning)
		//data contained both Radii and Diameters, this may not make much sense....
		DoAlert /T="User Warning" 0, "Added data included both Diameters and Radii as x-axis, this may not make much sense to plot!" 
	endif
	if(AddedFiles==0)
		//user did not select any data, probaby screwed up...
		DoAlert /T="User Warning" 0, "No data were selected in the data selector listbox. Please, select one or more data then run again" 
	endif
	IR1P_InputPanelButtonProc("CreateGraph")				//create graph
	setDataFolder OldDF
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR2S_FItWithModelingII()

	DoWindow LSQF2_MainPanel
	if(!V_Flag)
		Abort  "The Modeling panel and graph must be opened"
	else
		DoWIndow/F LSQF2_MainPanel 
	endif
	
	DoWindow LSQF_MainGraph
	if(!V_Flag)
		Abort  "The Modeling panel and graph must be opened"
	else
		DoWIndow/F LSQF_MainGraph 
	endif

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:ScriptingTool
	NVAR STUseIndra2Data = root:Packages:Irena:ScriptingTool:UseIndra2Data
	NVAR STUseQRSdata =root:Packages:Irena:ScriptingTool:UseQRSdata
	
	NVAR PTUseIndra2Data=root:Packages:IR2L_NLSQF:UseIndra2Data
	NVAR PTUseQRSdata=root:Packages:IR2L_NLSQF:UseQRSdata
	NVAR PTUseModelData=root:Packages:IR2L_NLSQF:UseModelData
	PTUseModelData=0
	PTUseQRSdata=STUseQRSdata
	PTUseIndra2Data=STUseIndra2Data
	STRUCT WMCheckboxAction CB_Struct
	CB_Struct.eventcode=2
	if(PTUseIndra2Data)
		CB_Struct.ctrlName="UseIndra2Data"
	elseif(PTUseQRSdata)
		CB_Struct.ctrlName="UseQRSData"
	else
		Abort "error, report it"
	endif
	CB_Struct.checked=1
	CB_Struct.win="LSQF2_MainPanel"
	IR2C_InputPanelCheckboxProc(CB_Struct)
	Wave/T ListOfAvailableData = root:Packages:Irena:ScriptingTool:ListOfAvailableData
	Wave SelectionOfAvailableData =root:Packages:Irena:ScriptingTool:SelectionOfAvailableData
	NVAR UseIndra2Data = root:Packages:Irena:ScriptingTool:UseIndra2Data
	variable NumOfSelectedFiles = sum(SelectionOfAvailableData)
	NVAR SaveResultsInNotebook = root:Packages:Irena:ScriptingTool:SaveResultsInNotebook
	NVAR ResetBeforeNextFit = root:Packages:Irena:ScriptingTool:ResetBeforeNextFit
	NVAR SaveResultsInFldrs = root:Packages:Irena:ScriptingTool:SaveResultsInFldrs
	NVAR SaveResultsInWaves = root:Packages:Irena:ScriptingTool:SaveResultsInWaves
	SVAR StartFolderName = root:Packages:Irena:ScriptingTool:StartFolderName
	string LStartFolder
	if(stringmatch(StartFolderName,"---"))
		LStartFolder="root:"
	else
		LStartFolder=StartFolderName
	endif
	
	variable i
	string CurrentFolderName
	variable StartQ, EndQ		//need to store these so the tool does not reset them... 
	NVAR CurMinQ=root:Packages:IR2L_NLSQF:Qmin_set1
	NVAR CurMaxQ=root:Packages:IR2L_NLSQF:Qmax_set1
	StartQ=CurMinQ
	EndQ=CurMaxQ
	//setup error settings for users
	variable UserErrs, SQRTErrs, PctErrs
	NVAR UseUserErrors = root:Packages:IR2L_NLSQF:UseUserErrors_set1
	NVAR UseSQRTErrors = root:Packages:IR2L_NLSQF:UseSQRTErrors_set1
	NVAR UsePercentErrors = root:Packages:IR2L_NLSQF:UsePercentErrors_set1
	UserErrs =UseUserErrors
	SQRTErrs=UseSQRTErrors
	PctErrs  =UsePercentErrors
	//setup error and intensity scaling
	variable ErrScale, IntScale
	NVAR DataScalingFactor = root:Packages:IR2L_NLSQF:DataScalingFactor_set1
	NVAR ErrorScalingFactor = root:Packages:IR2L_NLSQF:ErrorScalingFactor_set1
	IntScale = DataScalingFactor
	ErrScale = ErrorScalingFactor
	SVAR FolderMatchStr=root:Packages:IrenaControlProcs:LSQF2_MainPanel:FolderMatchStr
	SVAR WaveMatchStr=root:Packages:IrenaControlProcs:LSQF2_MainPanel:WaveMatchStr
	SVAR ScriptToolFMS=root:Packages:Irena:ScriptingTool:FolderNameMatchString
	SVAR ScriptToolWMS=root:Packages:Irena:ScriptingTool:WaveNameMatchString
	if(STUseQRSdata)
		WaveMatchStr=ScriptToolWMS
	else
		WaveMatchStr=""
	endif
	FolderMatchStr=ScriptToolFMS
	
	For(i=0;i<numpnts(ListOfAvailableData);i+=1)
		if(SelectionOfAvailableData[i]>0.5)
			CurrentFolderName = LStartFolder + ListOfAvailableData[i]
			//OK, now we know which files to process	
			//now stuff the name of the new folder in the folder name in Unified...
			SVAR DataFolderName = root:Packages:IR2L_NLSQF:FolderName_set1
			DataFolderName = CurrentFolderName
			//now except for case when we use Indra 2 data we need to reload the other wave names... 
			STRUCT WMPopupAction PU_Struct
			PU_Struct.ctrlName = "SelectDataFolder"
			PU_Struct.popNum=-1
			PU_Struct.eventcode=2
			PU_Struct.popStr=DataFolderName
			PU_Struct.win = "LSQF2_MainPanel"
			IR2C_PanelPopupControl(PU_Struct)
			//PopupMenu SelectDataFolder win=LSQF2_MainPanel, popmatch=CurrentFolderName
			PopupMenu SelectDataFolder win=LSQF2_MainPanel, value="---;"+IR2P_GenStringOfFolders(winNm="LSQF2_MainPanel")
			PopupMenu SelectDataFolder win=LSQF2_MainPanel, popmatch=StringFromList(ItemsInList(DataFolderName,":")-1,DataFolderName,":")
			//preset the right setting of the tool here, just in case...
			IR2L_Data_TabPanelControl("",0)	//sets the tab 0 active.
			IR2L_DataTabCheckboxProc("DisplayDataControls",1)
			NVAR MultipleInputData=	root:Packages:IR2L_NLSQF:MultipleInputData
			MultipleInputData=0
			//this should create the new graph...
			IR2L_InputPanelButtonProc("AddDataSetSkipRecover")
			//call user hook function if they need it
			if(exists("AfterDataLoaded_Hook")==6)
				Execute ("AfterDataLoaded_Hook()")
			endif
			//now we need to set back the Qmin and max.
			CurMinQ = StartQ
			CurMaxQ = EndQ
			IR2L_setQMinMax(1)
			//set the user error settings and int scaling back
			UseUserErrors = UserErrs 
			UseSQRTErrors = SQRTErrs
			UsePercentErrors = PctErrs  
			DataScalingFactor = IntScale 
			ErrorScalingFactor = ErrScale 
			//and recalculate as needed... 
			IR2L_RecalculateIntAndErrors(1)
			doUpdate
			sleep/s 0.2		//this seems to be needed for Igor 9 or we are getting failed fits. 

			variable/g root:Packages:IR2L_NLSQF:FitFailed
			//do fitting
			IR2L_InputPanelButtonProc("FitModelSkipDialogs")
			DoUpdate
			NVAR FitFailed=root:Packages:IR2L_NLSQF:FitFailed
			NVAR ExportSeparatePopData=root:Packages:Irena:ScriptingTool:ExportSeparatePopData
			
			if(SaveResultsInNotebook)
				IR2L_InputPanelButtonProc("SaveInNotebook")
			endif
			if(SaveResultsInFldrs && !FitFailed)
				IR2L_InputPanelButtonProc("SaveInDataFolderSkipDialog")
			endif
			if(SaveResultsInWaves && !FitFailed)
				IR2L_InputPanelButtonProc("SaveInWavesSkipDialog")
			endif
			if(ResetBeforeNextFit)
				IR2L_InputPanelButtonProc("ReverseFit")
			endif			
			KillVariables  FitFailed
		endif
		
	
	endfor
	
	

	setDataFolder OldDF


end



//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR2S_FItWithSizes(Uncert)
	variable uncert
	
	DoWindow IR1R_SizesInputPanel
	if(!V_Flag)
		Abort  "The Size distribution tool panel and graph must be opened"
	else
		DoWIndow/F IR1R_SizesInputPanel 
	endif
	
	DoWindow IR1R_SizesInputGraph
	if(!V_Flag)
		Abort  "The Size distribution tool panel and graph must be opened"
	else
		DoWIndow/F IR1R_SizesInputGraph 
	endif

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:ScriptingTool
	NVAR STUseIndra2Data = root:Packages:Irena:ScriptingTool:UseIndra2Data
	NVAR STUseQRSdata =root:Packages:Irena:ScriptingTool:UseQRSdata
	
	NVAR PTUseIndra2Data=root:Packages:Sizes:UseIndra2Data
	NVAR PTUseQRSdata=root:Packages:Sizes:UseQRSdata
	PTUseQRSdata=STUseQRSdata
	PTUseIndra2Data=STUseIndra2Data
	STRUCT WMCheckboxAction CB_Struct
	CB_Struct.eventcode=2
	if(PTUseIndra2Data)
		CB_Struct.ctrlName="UseIndra2Data"
	elseif(PTUseQRSdata)
		CB_Struct.ctrlName="UseQRSData"
	else
		Abort "error, report it"
	endif
	CB_Struct.checked=1
	CB_Struct.win="IR1R_SizesInputPanel"
	IR2C_InputPanelCheckboxProc(CB_Struct)


	Wave/T ListOfAvailableData = root:Packages:Irena:ScriptingTool:ListOfAvailableData
	Wave SelectionOfAvailableData =root:Packages:Irena:ScriptingTool:SelectionOfAvailableData
	NVAR UseIndra2Data = root:Packages:Irena:ScriptingTool:UseIndra2Data
	variable NumOfSelectedFiles = sum(SelectionOfAvailableData)
	NVAR SaveResultsInNotebook = root:Packages:Irena:ScriptingTool:SaveResultsInNotebook
	NVAR ResetBeforeNextFit = root:Packages:Irena:ScriptingTool:ResetBeforeNextFit
	NVAR SaveResultsInFldrs = root:Packages:Irena:ScriptingTool:SaveResultsInFldrs
	SVAR StartFolderName = root:Packages:Irena:ScriptingTool:StartFolderName
	string LStartFolder
	if(stringmatch(StartFolderName,"---"))
		LStartFolder="root:"
	else
		LStartFolder=StartFolderName
	endif
	
	variable i
	string CurrentFolderName
	variable StartQ, EndQ		//need to store these from cursor positions (if set)
	DoWIndow IR1R_SizesInputGraph
//	if(V_Flag)
//		Wave Ywv = csrXWaveRef(A  , "IR1R_SizesInputGraph" )
//		StartQ = Ywv[pcsr(A  , "IR1R_SizesInputGraph" )]
//		EndQ = Ywv[pcsr(B  , "IR1R_SizesInputGraph" )]
//	endif
	if(V_Flag)
		if(strlen(CsrInfo(A , "IR1R_SizesInputGraph"))>0)
			Wave Ywv = csrXWaveRef(A  , "IR1R_SizesInputGraph" )
			StartQ = Ywv[pcsr(A  , "IR1R_SizesInputGraph" )]
		else
			Wave Qwave = root:Packages:Sizes:Q_vecOriginal
			StartQ=Qwave[0]
		endif
		if(strlen(CsrInfo(B , "IR1R_SizesInputGraph"))>0)
			Wave Ywv = csrXWaveRef(B  , "IR1R_SizesInputGraph" )
			EndQ = Ywv[pcsr(B  , "IR1R_SizesInputGraph" )]
		else
			Wave Qwave = root:Packages:Sizes:Q_vecOriginal
			EndQ=Qwave[numpnts(Qwave)-1]
		endif
		//EndQ = Ywv[pcsr(B  , "IR1_LogLogPlotU" )]
	endif
	//preserver user error choices settings and reapply after loading of the data.
	variable UserErrs, SQRTErrs, PctErrs
	NVAR UseUserErrors = root:Packages:Sizes:UseUserErrors
	NVAR UseSQRTErrors = root:Packages:Sizes:UseSQRTErrors
	NVAR UsePercentErrors = root:Packages:Sizes:UsePercentErrors 
	UserErrs=UseUserErrors
	SQRTErrs=UseSQRTErrors
	PctErrs=UsePercentErrors
	
	SVAR FolderMatchStr=root:Packages:IrenaControlProcs:IR1R_SizesInputPanel:FolderMatchStr
	SVAR WaveMatchStr=root:Packages:IrenaControlProcs:IR1R_SizesInputPanel:WaveMatchStr
	SVAR ScriptToolFMS=root:Packages:Irena:ScriptingTool:FolderNameMatchString
	SVAR ScriptToolWMS=root:Packages:Irena:ScriptingTool:WaveNameMatchString
	if(STUseQRSdata)
		WaveMatchStr=ScriptToolWMS
	else
		WaveMatchStr=""
	endif
	FolderMatchStr=ScriptToolFMS

	For(i=0;i<numpnts(ListOfAvailableData);i+=1)
		if(SelectionOfAvailableData[i]>0.5)
			CurrentFolderName = LStartFolder + ListOfAvailableData[i]
			//OK, now we know which files to process	
			//now stuff the name of the new folder in the folder name in Unified...
			SVAR DataFolderName = root:Packages:Sizes:DataFolderName
			DataFolderName = CurrentFolderName
			//now except for case when we use Indra 2 data we need to reload the other wave names... 
			STRUCT WMPopupAction PU_Struct
			PU_Struct.ctrlName = "SelectDataFolder"
			PU_Struct.popNum=-1
			PU_Struct.eventcode=2
			PU_Struct.popStr=DataFolderName
			PU_Struct.win = "IR1R_SizesInputPanel"
			IR2C_PanelPopupControl(PU_Struct)
				
			//this should create the new graph...
			IR1R_GraphIfAllowed("GraphIfAllowedSkipRecover")
			//PopupMenu SelectDataFolder win=IR1R_SizesInputPanel, popmatch=DataFolderName
			PopupMenu SelectDataFolder win=IR1R_SizesInputPanel, value="---;"+IR2P_GenStringOfFolders(winNm="IR1R_SizesInputPanel")
			PopupMenu SelectDataFolder win=IR1R_SizesInputPanel, popmatch=StringFromList(ItemsInList(DataFolderName,":")-1,DataFolderName,":")
			//now we need to set back the cursors.
			if(StartQ>0)
				Wave Qwave = root:Packages:Sizes:Q_vecOriginal
				if(binarysearch(Qwave,StartQ)>=0)
					Cursor  /P /W=IR1R_SizesInputGraph A  IntensityOriginal binarysearch(Qwave,StartQ)
				endif	
			endif
			if(EndQ>0)
				Wave Qwave = root:Packages:Sizes:Q_vecOriginal
				if(binarysearch(Qwave,EndQ)>=0)
					Cursor  /P /W=IR1R_SizesInputGraph B  IntensityOriginal binarysearch(Qwave,EndQ)	
				endif
			endif
			//set back user choices ofr errros
			UseUserErrors = UserErrs
			UseSQRTErrors = SQRTErrs
			UsePercentErrors = PctErrs
			IR1R_UpdateErrorWave()
			DoUpdate			
			variable/g root:Packages:Sizes:FitFailed
			//do fitting
			if(uncert)
				IR1R_SizesEstimateErrors()	
			else
				IR1R_SizesFitting("DoFittingSkipReset")
			endif
			DoUpdate
			sleep/s 0.2		//this seems to be needed for Igor 9 or we are getting failed fits. 
			NVAR FitFailed=root:Packages:Sizes:FitFailed
			
			if(SaveResultsInNotebook)
				IR2S_SaveResInNbkSizes(FitFailed)
			endif
			if(SaveResultsInFldrs && !FitFailed)
				IR1R_saveData("SaveDataNoQuestions")
			endif
			KillVariables  FitFailed
		endif
		
	
	endfor
	
	

	setDataFolder OldDF


end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function IR2S_FitWithGuinierPorod()

	DoWindow IR3DP_MainPanel
	if(!V_Flag)
		Abort  "The Unified fit tool panel and graph must be opened"
	else
		DoWIndow/F IR3DP_MainPanel 
	endif
	
	DoWindow GuinierPorod_LogLogPlot
	if(!V_Flag)
		Abort  "The Guinier Porod tool panel and graph must be opened"
	else
		DoWIndow/F GuinierPorod_LogLogPlot 
	endif


	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:ScriptingTool
	NVAR STUseIndra2Data = root:Packages:Irena:ScriptingTool:UseIndra2Data
	NVAR STUseQRSdata =root:Packages:Irena:ScriptingTool:UseQRSdata
	
	NVAR PTUseIndra2Data=root:Packages:Irena:GuinierPorod:UseIndra2Data
	NVAR PTUseQRSdata=root:Packages:Irena:GuinierPorod:UseQRSdata
	PTUseQRSdata=STUseQRSdata
	PTUseIndra2Data=STUseIndra2Data
	STRUCT WMCheckboxAction CB_Struct
	CB_Struct.eventcode=2
	if(PTUseIndra2Data)
		CB_Struct.ctrlName="UseIndra2Data"
	elseif(PTUseQRSdata)
		CB_Struct.ctrlName="UseQRSData"
	else
		Abort "error, report it"
	endif
	CB_Struct.checked=1
	CB_Struct.win="IR3DP_MainPanel"
	IR2C_InputPanelCheckboxProc(CB_Struct)
	Wave/T ListOfAvailableData = root:Packages:Irena:ScriptingTool:ListOfAvailableData
	Wave SelectionOfAvailableData =root:Packages:Irena:ScriptingTool:SelectionOfAvailableData
	NVAR UseIndra2Data = root:Packages:Irena:ScriptingTool:UseIndra2Data
	variable NumOfSelectedFiles = sum(SelectionOfAvailableData)
	NVAR SaveResultsInNotebook = root:Packages:Irena:ScriptingTool:SaveResultsInNotebook
	NVAR ResetBeforeNextFit = root:Packages:Irena:ScriptingTool:ResetBeforeNextFit
	NVAR SaveResultsInFldrs = root:Packages:Irena:ScriptingTool:SaveResultsInFldrs
	SVAR StartFolderName = root:Packages:Irena:ScriptingTool:StartFolderName
	string LStartFolder
	if(stringmatch(StartFolderName,"---"))
		LStartFolder="root:"
	else
		LStartFolder=StartFolderName
	endif
	
	variable i
	string CurrentFolderName
	variable StartQ, EndQ		//need to store these from cursor positions (if set)
	DoWIndow GuinierPorod_LogLogPlot
//	if(V_Flag)
//		Wave Ywv = csrXWaveRef(A  , "GuinierPorod_LogLogPlot" )
//		StartQ = Ywv[pcsr(A  , "GuinierPorod_LogLogPlot" )]
//		EndQ = Ywv[pcsr(B  , "GuinierPorod_LogLogPlot" )]
//	endif
	if(V_Flag)
		if(strlen(CsrInfo(A , "GuinierPorod_LogLogPlot"))>0)
			Wave Ywv = csrXWaveRef(A  , "GuinierPorod_LogLogPlot" )
			StartQ = Ywv[pcsr(A  , "GuinierPorod_LogLogPlot" )]
		else
			Wave Qwave = root:Packages:Irena:GuinierPorod:OriginalQvector
			StartQ=Qwave[0]
		endif
		if(strlen(CsrInfo(B , "GuinierPorod_LogLogPlot"))>0)
			Wave Ywv = csrXWaveRef(B  , "GuinierPorod_LogLogPlot" )
			EndQ = Ywv[pcsr(B  , "GuinierPorod_LogLogPlot" )]
		else
			Wave Qwave = root:Packages:Irena:GuinierPorod:OriginalQvector
			EndQ=Qwave[numpnts(Qwave)-1]
		endif
		//EndQ = Ywv[pcsr(B  , "IR1_LogLogPlotU" )]
	endif
	SVAR FolderMatchStr=root:Packages:IrenaControlProcs:IR3DP_MainPanel:FolderMatchStr
	SVAR WaveMatchStr=root:Packages:IrenaControlProcs:IR3DP_MainPanel:WaveMatchStr
	SVAR ScriptToolFMS=root:Packages:Irena:ScriptingTool:FolderNameMatchString
	SVAR ScriptToolWMS=root:Packages:Irena:ScriptingTool:WaveNameMatchString
	if(STUseQRSdata)
		WaveMatchStr=ScriptToolWMS
	else
		WaveMatchStr=""
	endif
	FolderMatchStr=ScriptToolFMS
	For(i=0;i<numpnts(ListOfAvailableData);i+=1)
		if(SelectionOfAvailableData[i]>0.5)
			//here process the Unified...
			//CurrentFolderName="root:"
			//if(UseIndra2Data)
			//	CurrentFolderName+="USAXS:"
			//endif
			CurrentFolderName = LStartFolder + ListOfAvailableData[i]
			//OK, now we know which files to process	
			//now stuff the name of the new folder in the folder name in Unified...
			SVAR DataFolderName = root:Packages:Irena:GuinierPorod:DataFolderName
			DataFolderName = CurrentFolderName
			//now except for case when we use Indra 2 data we need to reload the other wave names... 
			STRUCT WMPopupAction PU_Struct
			PU_Struct.ctrlName = "SelectDataFolder"
			PU_Struct.popNum=-1
			PU_Struct.eventcode=2
			PU_Struct.popStr=DataFolderName
			PU_Struct.win = "IR3DP_MainPanel"
			IR2C_PanelPopupControl(PU_Struct)
			PopupMenu SelectDataFolder win=IR3DP_MainPanel, value="---;"+IR2P_GenStringOfFolders(winNm="IR3DP_MainPanel")
			PopupMenu SelectDataFolder win=IR3DP_MainPanel, popmatch=StringFromList(ItemsInList(DataFolderName,":")-1,DataFolderName,":")
			
			//this should create the new graph...
			IR3GP_PanelButtonProc("DrawGraphsSkipDialogs")
			//now we need to set back the cursors.
			if(StartQ>0)
				Wave Qwave = root:Packages:Irena:GuinierPorod:OriginalQvector
				if(binarysearch(Qwave,StartQ)>=0)
					Cursor  /P /W=IR1_LogLogPlotU A  OriginalIntensity binarysearch(Qwave,StartQ)
				endif	
			endif
			if(EndQ>0)
				Wave Qwave = root:Packages:Irena:GuinierPorod:OriginalQvector
				if(binarysearch(Qwave,EndQ)>=0)
					Cursor  /P /W=IR1_LogLogPlotU B  OriginalIntensity binarysearch(Qwave,EndQ)	
				endif
			endif
			
			variable/g root:Packages:Irena:GuinierPorod:FitFailed
			//do fitting
			IR3GP_PanelButtonProc("DoFittingSkipReset")
			DoUpdate
			sleep/s 0.2		//this seems to be needed for Igor 9 or we are getting failed fits. 
			NVAR FitFailed=root:Packages:Irena:GuinierPorod:FitFailed
			
			if(SaveResultsInNotebook)
				IR2S_SaveResInNbkGunPor(FitFailed)
			endif
			if(SaveResultsInFldrs && !FitFailed)
				IR3GP_PanelButtonProc("CopyTFolderNoQuestions")
			endif
			if(ResetBeforeNextFit && !FitFailed)
				IR3GP_PanelButtonProc("RevertFitting")   
			endif
			KillVariables  FitFailed
		endif
		
	
	endfor
	
	

	setDataFolder OldDF
end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_FItWithUnifiedFit()

	DoWindow IR1A_ControlPanel
	if(!V_Flag)
		Abort  "The Unified fit tool panel and graph must be opened"
	else
		DoWIndow/F IR1A_ControlPanel 
	endif
	
	DoWindow IR1_LogLogPlotU
	if(!V_Flag)
		Abort  "The Unified fit tool panel and graph must be opened"
	else
		DoWIndow/F IR1_LogLogPlotU 
	endif


	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:ScriptingTool
	NVAR STUseIndra2Data = root:Packages:Irena:ScriptingTool:UseIndra2Data
	NVAR STUseQRSdata =root:Packages:Irena:ScriptingTool:UseQRSdata
	
	NVAR PTUseIndra2Data=root:Packages:Irena_UnifFit:UseIndra2Data
	NVAR PTUseQRSdata=root:Packages:Irena_UnifFit:UseQRSdata
	PTUseQRSdata=STUseQRSdata
	PTUseIndra2Data=STUseIndra2Data
	STRUCT WMCheckboxAction CB_Struct
	CB_Struct.eventcode=2
	if(PTUseIndra2Data)
		CB_Struct.ctrlName="UseIndra2Data"
	elseif(PTUseQRSdata)
		CB_Struct.ctrlName="UseQRSData"
	else
		Abort "error, report it"
	endif
	CB_Struct.checked=1
	CB_Struct.win="IR1A_ControlPanel"
	IR2C_InputPanelCheckboxProc(CB_Struct)


	Wave/T ListOfAvailableData = root:Packages:Irena:ScriptingTool:ListOfAvailableData
	Wave SelectionOfAvailableData =root:Packages:Irena:ScriptingTool:SelectionOfAvailableData
	NVAR UseIndra2Data = root:Packages:Irena:ScriptingTool:UseIndra2Data
	variable NumOfSelectedFiles = sum(SelectionOfAvailableData)
	NVAR SaveResultsInNotebook = root:Packages:Irena:ScriptingTool:SaveResultsInNotebook
	NVAR ResetBeforeNextFit = root:Packages:Irena:ScriptingTool:ResetBeforeNextFit
	NVAR SaveResultsInFldrs = root:Packages:Irena:ScriptingTool:SaveResultsInFldrs
	SVAR StartFolderName = root:Packages:Irena:ScriptingTool:StartFolderName
	string LStartFolder
	if(stringmatch(StartFolderName,"---"))
		LStartFolder="root:"
	else
		LStartFolder=StartFolderName
	endif
	NVAR SkipFitControlDialog = root:Packages:Irena_UnifFit:SkipFitControlDialog
	variable oldSkipFitControlDialog = SkipFitControlDialog
	SkipFitControlDialog = 1
	variable i
	string CurrentFolderName
	variable StartQ, EndQ		//need to store these from cursor positions (if set)
	DoWIndow IR1_LogLogPlotU
	if(V_Flag)
		if(strlen(CsrInfo(A , "IR1_LogLogPlotU"))>0)
			Wave Ywv = csrXWaveRef(A  , "IR1_LogLogPlotU" )
			StartQ = Ywv[pcsr(A  , "IR1_LogLogPlotU" )]
		else
			Wave Qwave = root:Packages:Irena_UnifFit:OriginalQvector
			StartQ=Qwave[0]
		endif
		if(strlen(CsrInfo(B , "IR1_LogLogPlotU"))>0)
			Wave Ywv = csrXWaveRef(B  , "IR1_LogLogPlotU" )
			EndQ = Ywv[pcsr(B  , "IR1_LogLogPlotU" )]
		else
			Wave Qwave = root:Packages:Irena_UnifFit:OriginalQvector
			EndQ=Qwave[numpnts(Qwave)-1]
		endif
		//EndQ = Ywv[pcsr(B  , "IR1_LogLogPlotU" )]
	endif
	SVAR FolderMatchStr=root:Packages:IrenaControlProcs:IR1A_ControlPanel:FolderMatchStr
	SVAR WaveMatchStr=root:Packages:IrenaControlProcs:IR1A_ControlPanel:WaveMatchStr
	SVAR ScriptToolFMS=root:Packages:Irena:ScriptingTool:FolderNameMatchString
	SVAR ScriptToolWMS=root:Packages:Irena:ScriptingTool:WaveNameMatchString
	if(STUseQRSdata)
		WaveMatchStr=ScriptToolWMS
	else
		WaveMatchStr=""
	endif
	FolderMatchStr=ScriptToolFMS
	For(i=0;i<numpnts(ListOfAvailableData);i+=1)
		if(SelectionOfAvailableData[i]>0.5)
			//here process the Unified...
			//CurrentFolderName="root:"
			//if(UseIndra2Data)
			//	CurrentFolderName+="USAXS:"
			//endif
			CurrentFolderName = LStartFolder + ListOfAvailableData[i]
			//OK, now we know which files to process	
			//now stuff the name of the new folder in the folder name in Unified...
			SVAR DataFolderName = root:Packages:Irena_UnifFit:DataFolderName
			DataFolderName = CurrentFolderName
			//now except for case when we use Indra 2 data we need to reload the other wave names... 
			STRUCT WMPopupAction PU_Struct
			PU_Struct.ctrlName = "SelectDataFolder"
			PU_Struct.popNum=-1
			PU_Struct.eventcode=2
			PU_Struct.popStr=DataFolderName
			PU_Struct.win = "IR1A_ControlPanel"
			IR2C_PanelPopupControl(PU_Struct)
			//PopupMenu SelectDataFolder win=IR1A_ControlPanel, popmatch=DataFolderName
			PopupMenu SelectDataFolder win=IR1A_ControlPanel, value="---;"+IR2P_GenStringOfFolders(winNm="IR1A_ControlPanel")
			PopupMenu SelectDataFolder win=IR1A_ControlPanel, popmatch=StringFromList(ItemsInList(DataFolderName,":")-1,DataFolderName,":")
			
			//this should create the new graph...
			IR1A_InputPanelButtonProc("DrawGraphsSkipDialogs")
			//now we need to set back the cursors.
			if(StartQ>0)
				Wave Qwave = root:Packages:Irena_UnifFit:OriginalQvector
				if(binarysearch(Qwave,StartQ)>=0)
					Cursor  /P /W=IR1_LogLogPlotU A  OriginalIntensity binarysearch(Qwave,StartQ)
				endif	
			endif
			if(EndQ>0)
				Wave Qwave = root:Packages:Irena_UnifFit:OriginalQvector
				if(binarysearch(Qwave,EndQ)>=0)
					Cursor  /P /W=IR1_LogLogPlotU B  OriginalIntensity binarysearch(Qwave,EndQ)	
				endif
			endif
			
			variable/g root:Packages:Irena_UnifFit:FitFailed
			//do fitting
			IR1A_InputPanelButtonProc("DoFittingSkipReset")
			DoUpdate
			sleep/s 0.2		//this seems to be needed for Igor 9 or we are getting failed fits. 
			NVAR FitFailed=root:Packages:Irena_UnifFit:FitFailed
			NVAR ExportSeparatePopData=root:Packages:Irena:ScriptingTool:ExportSeparatePopData
			
			if(SaveResultsInNotebook)
				IR2S_SaveResInNbkUnif(FitFailed)
			endif
			if(SaveResultsInFldrs && !FitFailed)
				IR1A_InputPanelButtonProc("CopyTFolderNoQuestions")
			endif
			if(ResetBeforeNextFit && !FitFailed)
				IR1A_InputPanelButtonProc("RevertFitting")   
			endif
			KillVariables  FitFailed
		endif
		
	
	endfor
	SkipFitControlDialog = oldSkipFitControlDialog
	

	setDataFolder OldDF
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************


Function IR2S_SaveResInNbkGunPor(FitFailed)
	variable FitFailed
	
		DoWIndow ScriptingToolNbk

		if(!V_Flag)
			NewNotebook /F=1 /K=1 /N=ScriptingToolNbk /W=(400,20,1000,700 ) as "Results of scripting tool runs"		
		endif
		SVAR DataFolderName = root:Packages:Irena:GuinierPorod:DataFolderName


		Notebook ScriptingToolNbk   selection={endOfFile, endOfFile}
		Notebook ScriptingToolNbk text="\r"
		Notebook ScriptingToolNbk text="\r"
		Notebook ScriptingToolNbk text="\r"
		Notebook ScriptingToolNbk text="***********************************************\r"
		Notebook ScriptingToolNbk text="***********************************************\r"
		Notebook ScriptingToolNbk text=date()+"   "+time()+"\r"
		Notebook ScriptingToolNbk text="Guinier-Porod results from folder :   "+ DataFolderName+"\r"
		Notebook ScriptingToolNbk text="\r"
		if(FitFailed)
			Notebook ScriptingToolNbk text="Fit failed\r"
		else
			Notebook ScriptingToolNbk  scaling={50,50}, frame=1, picture={GuinierPorod_LogLogPlot,2,1}	
			Notebook ScriptingToolNbk text="\r"
			IR2S_RecordResultsToNbkGP()
		endif
end	

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_RecordResultsToNbkGP()	

	DFref oldDf= GetDataFolderDFR()

	setdataFolder root:Packages:Irena_UnifFit

	NVAR NumberOfLevels=root:Packages:Irena:GuinierPorod:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena:GuinierPorod:SASBackground
	NVAR FitSASBackground=root:Packages:Irena:GuinierPorod:FitSASBackground
	NVAR SubtractBackground=root:Packages:Irena:GuinierPorod:SubtractBackground
	NVAR UseSMRData=root:Packages:Irena:GuinierPorod:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena:GuinierPorod:SlitLengthUnif

	SVAR DataAreFrom=root:Packages:Irena:GuinierPorod:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena:GuinierPorod:IntensityWaveName
	SVAR QWavename=root:Packages:Irena:GuinierPorod:QWavename
	SVAR ErrorWaveName=root:Packages:Irena:GuinierPorod:ErrorWaveName

	Notebook ScriptingToolNbk   selection={endOfFile, endOfFile}
	Notebook ScriptingToolNbk text="\r"
	Notebook ScriptingToolNbk text="Summary of Guinier Porod fit results :"+"\r"
	if(UseSMRData)
		Notebook ScriptingToolNbk text="Slit smeared data were. Slit length [A^-1] = "+num2str(SlitLengthUnif)+"\r"
	endif
	Notebook ScriptingToolNbk text="Name of data waves Int/Q/Error \t"+IntensityWaveName+"\t"+QWavename+"\t"+ErrorWaveName+"\r"
	Notebook ScriptingToolNbk text="Number of levels: "+num2str(NumberOfLevels)+"\r"
	Notebook ScriptingToolNbk text="SAS background = "+num2str(SASBackground)+", was fitted? = "+num2str(FitSASBackground)+"       (yes=1/no=0)"+"\r"
	Notebook ScriptingToolNbk text="\r"
	variable i
	STRUCT GuinierPorodLevel Par
	For (i=1;i<=NumberOfLevels;i+=1)
		IR3GP_LoadStructureFromWave(Par, i)
		Notebook ScriptingToolNbk text="***********  Level  "+num2str(i)+"\r"
		Notebook ScriptingToolNbk text="P     \t \t"+ num2str(Par.P)+"\t\t+/- "+num2str(Par.PError)+"\t,  \tfitted? = "+num2str(Par.PFit)+"\r"
		if(Par.Rg1>=1e6)
			Notebook ScriptingToolNbk text="\t Guinier 1 not assumed, using just power law slope"+"\r"
		else
			Notebook ScriptingToolNbk text="Rg1     \t\t"+ num2str(Par.Rg1)+"\t\t+/- "+num2str(Par.Rg1Error)+"\t,  \tfitted? = "+num2str(Par.Rg1Fit)+"\r"
			Notebook ScriptingToolNbk text="G      \t\t"+ num2str(Par.G)+"\t\t+/- "+num2str(Par.GError)+"\t,  \tfitted? = "+num2str(Par.GFit)+"\r"
			if(Par.S1>0)
				Notebook ScriptingToolNbk text="S1     \t \t"+ num2str(Par.S1)+"\t\t+/- "+num2str(Par.S1Error)+"\t,  \tfitted? = "+num2str(Par.S1Fit)+"\r"
				if(Par.Rg2>=1e10)
					Notebook ScriptingToolNbk text="\t Guinier 2 not assumed, using just power law slope 2"+"\r"
				else
					Notebook ScriptingToolNbk text="Rg2     \t \t"+ num2str(Par.Rg2)+"\t\t+/- "+num2str(Par.Rg2Error)+"\t,  \tfitted? = "+num2str(Par.Rg2Fit)+"\r"
				endif
				if(Par.S2>0)
					Notebook ScriptingToolNbk text="S2     \t \t"+ num2str(Par.S2)+"\t\t+/- "+num2str(Par.S2Error)+"\t,  \tfitted? = "+num2str(Par.S2Fit)+"\r"
				endif
			endif
		endif
		if(Par.RgCutOff>0)
			Notebook ScriptingToolNbk text="RgCO     \t \t"+ num2str(Par.RgCutOff)+"\r"
		endif
		if(Par.UseCorrelations)
			Notebook ScriptingToolNbk text="\tAssumed Correlations (Structure factor)"+"\r"
			Notebook ScriptingToolNbk text="ETA     \t \t"+ num2str(Par.ETA)+"\t\t+/- "+num2str(Par.ETAError)+"\t,  \tfitted? = "+num2str(Par.ETAFit)+"\r"
			Notebook ScriptingToolNbk text="Pack     \t \t"+ num2str(Par.Pack)+"\t\t+/- "+num2str(Par.PackError)+"\t,  \tfitted? = "+num2str(Par.PackFit)+"\r"
		endif
	endfor
	
		NVAR AchievedChisq=root:Packages:Irena:GuinierPorod:AchievedChisq
		Notebook ScriptingToolNbk text="Chi-Squared \t"+ num2str(AchievedChisq)+"\r"

		DoWindow /F GuinierPorod_LogLogPlot
		if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
			Notebook ScriptingToolNbk text="Points selected for fitting \t"+ num2str(pcsr(A)) + "   to \t"+num2str(pcsr(B))+"\r"
		else
			Notebook ScriptingToolNbk text="Whole range of data selected for fitting"+"\r"
		endif
				
	setdataFolder oldDf
end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_SaveResInNbkUnif(FitFailed)
	variable FitFailed
	
		DoWIndow ScriptingToolNbk

		if(!V_Flag)
			NewNotebook /F=1 /K=1 /N=ScriptingToolNbk /W=(400,20,1000,700 ) as "Results of scripting tool runs"		
		endif
		SVAR DataFolderName = root:Packages:Irena_UnifFit:DataFolderName


		Notebook ScriptingToolNbk   selection={endOfFile, endOfFile}
		Notebook ScriptingToolNbk text="\r"
		Notebook ScriptingToolNbk text="\r"
		Notebook ScriptingToolNbk text="\r"
		Notebook ScriptingToolNbk text="***********************************************\r"
		Notebook ScriptingToolNbk text="***********************************************\r"
		Notebook ScriptingToolNbk text=date()+"   "+time()+"\r"
		Notebook ScriptingToolNbk text="Unified results from folder :   "+ DataFolderName+"\r"
		Notebook ScriptingToolNbk text="\r"
		if(FitFailed)
			Notebook ScriptingToolNbk text="Fit failed\r"
		else
			Notebook ScriptingToolNbk  scaling={50,50}, frame=1, picture={IR1_LogLogPlotU,2,1}	
			Notebook ScriptingToolNbk text="\r"
			IR2S_RecordResultsToNbkUnif()
		endif
end	
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_SaveResInNbkSizes(FitFailed)
	variable FitFailed
	
		DoWIndow ScriptingToolNbk

		if(!V_Flag)
			NewNotebook /F=1 /K=1 /N=ScriptingToolNbk /W=(400,20,1000,700 ) as "Results of scripting tool runs"		
		endif
		SVAR DataFolderName = root:Packages:Sizes:DataFolderName


		Notebook ScriptingToolNbk   selection={endOfFile, endOfFile}
		Notebook ScriptingToolNbk text="\r"
		Notebook ScriptingToolNbk text="\r"
		Notebook ScriptingToolNbk text="\r"
		Notebook ScriptingToolNbk text="***********************************************\r"
		Notebook ScriptingToolNbk text="***********************************************\r"
		Notebook ScriptingToolNbk text=date()+"   "+time()+"\r"
		Notebook ScriptingToolNbk text="Size Distribution results from folder :   "+ DataFolderName+"\r"
		Notebook ScriptingToolNbk text="\r"
		if(FitFailed)
			Notebook ScriptingToolNbk text="Fit failed\r"
		else
			Notebook ScriptingToolNbk  scaling={40,40}, frame=1, picture={IR1R_SizesInputGraph,2,1}	
			Notebook ScriptingToolNbk text="\r"
			IR2S_RecordResultsToNbkSizes()
		endif
end	


//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR2S_RecordResultsToNbkSizes()

	DFref oldDf= GetDataFolderDFR()

	setdataFolder root:Packages:Sizes

	SVAR DataFolderName=root:Packages:Sizes:DataFolderName
	SVAR OriginalIntensityWvName=root:Packages:Sizes:IntensityWaveName
	SVAR OriginalQvectorWvName=root:Packages:Sizes:QWaveName
	SVAR OriginalErrorWvName=root:Packages:Sizes:ErrorWaveName
	SVAR SizesParameters=root:Packages:Sizes:SizesParameters
	SVAR LogDist=root:Packages:Sizes:LogDist
	SVAR ShapeType=root:Packages:Sizes:ShapeType
	SVAR SlitSmearedData=root:Packages:Sizes:SlitSmearedData
	SVAR MethodRun=root:Packages:Sizes:MethodRun
	
	
	Notebook ScriptingToolNbk text="\r"

	Notebook ScriptingToolNbk text="   "
	Notebook ScriptingToolNbk text="***********************************************"
	Notebook ScriptingToolNbk text="***********************************************"
	Notebook ScriptingToolNbk text="Sizes fitting record \r"
	Notebook ScriptingToolNbk text="Input data names \t"
	Notebook ScriptingToolNbk text="\t\tFolder \t\t"+ DataFolderName+"\r"
	Notebook ScriptingToolNbk text="\t\tIntensity/Q/errror wave names \t"+ OriginalIntensityWvName+"\t"+OriginalQvectorWvName+"\t"+OriginalErrorWvName+"\r"
	variable i
	For(i=0;i<ItemsInList(SizesParameters , ";");i+=1)
		Notebook ScriptingToolNbk text="\t\t"+StringFromList(i, SizesParameters, ";")+"\r"
	endfor
	Notebook ScriptingToolNbk text="\r"
	
	setdataFolder oldDf

end


//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_RecordResultsToNbkUnif()	

	DFref oldDf= GetDataFolderDFR()

	setdataFolder root:Packages:Irena_UnifFit

	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR FitSASBackground=root:Packages:Irena_UnifFit:FitSASBackground
	NVAR SubtractBackground=root:Packages:Irena_UnifFit:SubtractBackground
	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif

	SVAR DataAreFrom=root:Packages:Irena_UnifFit:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena_UnifFit:IntensityWaveName
	SVAR QWavename=root:Packages:Irena_UnifFit:QWavename
	SVAR ErrorWaveName=root:Packages:Irena_UnifFit:ErrorWaveName

	Notebook ScriptingToolNbk   selection={endOfFile, endOfFile}
	Notebook ScriptingToolNbk text="\r"
	Notebook ScriptingToolNbk text="Summary of Unified fit results :"+"\r"
	if(UseSMRData)
		Notebook ScriptingToolNbk text="Slit smeared data were. Slit length [A^-1] = "+num2str(SlitLengthUnif)+"\r"
	endif
	Notebook ScriptingToolNbk text="Name of data waves Int/Q/Error \t"+IntensityWaveName+"\t"+QWavename+"\t"+ErrorWaveName+"\r"
	Notebook ScriptingToolNbk text="Number of levels: "+num2str(NumberOfLevels)+"\r"
	Notebook ScriptingToolNbk text="SAS background = "+num2str(SASBackground)+", was fitted? = "+num2str(FitSASBackground)+"       (yes=1/no=0)"+"\r"
	Notebook ScriptingToolNbk text="\r"
	variable i
	For (i=1;i<=NumberOfLevels;i+=1)
		Notebook ScriptingToolNbk text="***********  Level  "+num2str(i)+"\r"
		NVAR tempVal =$("Level"+num2str(i)+"Rg")
		NVAR tempValError =$("Level"+num2str(i)+"RgError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitRg")
			Notebook ScriptingToolNbk text="Rg      \t\t"+ num2str(tempVal)+"\t\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal)+"\r"
		NVAR tempVal =$("Level"+num2str(i)+"G")
		NVAR tempValError =$("Level"+num2str(i)+"GError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitG")
			Notebook ScriptingToolNbk text="G      \t\t"+ num2str(tempVal)+"\t\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal)+"\r"
		NVAR tempVal =$("Level"+num2str(i)+"P")
		NVAR tempValError =$("Level"+num2str(i)+"PError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitP")
			Notebook ScriptingToolNbk text="P     \t \t"+ num2str(tempVal)+"\t\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal)+"\r"
		NVAR tempValMassFractal =$("Level"+num2str(i)+"MassFractal")
			if (tempValMassFractal)
				Notebook ScriptingToolNbk text="\tAssumed Mass Fractal"
				Notebook ScriptingToolNbk text="Parameter B calculated as B=(G*P/Rg^P)*Gamma(P/2)"+"\r"
			else
				NVAR tempVal =$("Level"+num2str(i)+"B")
				NVAR tempValError =$("Level"+num2str(i)+"BError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitB")
				Notebook ScriptingToolNbk text="B     \t \t"+ num2str(tempVal)+"\t\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal)+"\r"
			endif
		NVAR tempVal =$("Level"+num2str(i)+"RGCO")
		NVAR tempValError =$("Level"+num2str(i)+"RgCOError")
		NVAR LinktempVal=$("Level"+num2str(i)+"LinkRgCO")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitRGCO")
				if (fitTempVal)
					Notebook ScriptingToolNbk text="RgCO linked to lower level Rg =\t"+ num2str(tempVal)+"\r"
				else
					Notebook ScriptingToolNbk text="RgCO      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal)+"\r"
				endif
		NVAR tempVal =$("Level"+num2str(i)+"K")
			Notebook ScriptingToolNbk text="K      \t"+ num2str(tempVal)+"\r"
		NVAR tempValCorrelations =$("Level"+num2str(i)+"Corelations")
			if (tempValCorrelations)
				Notebook ScriptingToolNbk text="Assumed Corelations so following parameters apply"+"\r"
				NVAR tempVal =$("Level"+num2str(i)+"ETA")
				NVAR tempValError =$("Level"+num2str(i)+"ETAError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitETA")
					Notebook ScriptingToolNbk text="ETA      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal)+"\r"
				NVAR tempVal =$("Level"+num2str(i)+"PACK")
				NVAR tempValError =$("Level"+num2str(i)+"PACKError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitPACK")
				Notebook ScriptingToolNbk text="PACK      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal)+"\r"
		else
				Notebook ScriptingToolNbk text="Corelations       \tNot assumed\r"
			endif

		NVAR tempVal =$("Level"+num2str(i)+"Invariant")
				Notebook ScriptingToolNbk text="Invariant  =\t"+num2str(tempVal)+"   cm^(-1) A^(-3)\r"
		NVAR tempVal =$("Level"+num2str(i)+"SurfaceToVolRat")
			if (Numtype(tempVal)==0)
				Notebook ScriptingToolNbk text="Surface to volume ratio  =\t"+num2str(tempVal)+"   m^(2) / cm^(3)\r"
			endif
			Notebook ScriptingToolNbk text=" \r "
	endfor
	
		NVAR AchievedChisq
		Notebook ScriptingToolNbk text="Chi-Squared \t"+ num2str(AchievedChisq)+"\r"

		DoWindow /F IR1_LogLogPlotU
		if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
			Notebook ScriptingToolNbk text="Points selected for fitting \t"+ num2str(pcsr(A)) + "   to \t"+num2str(pcsr(B))+"\r"
		else
			Notebook ScriptingToolNbk text="Whole range of data selected for fitting"+"\r"
		endif
				
	setdataFolder oldDf
end

//Function IR1A_SaveRecordResults()	
//
//	DFref oldDf= GetDataFolderDFR()

//	setdataFolder root:Packages:Irena_UnifFit
//
//	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
//
//	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
//	NVAR FitSASBackground=root:Packages:Irena_UnifFit:FitSASBackground
//	NVAR SubtractBackground=root:Packages:Irena_UnifFit:SubtractBackground
//	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
//	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
//	NVAR LastSavedUnifOutput=root:Packages:Irena_UnifFit:LastSavedUnifOutput
//	NVAR ExportLocalFits=root:Packages:Irena_UnifFit:ExportLocalFits
//
//	SVAR DataAreFrom=root:Packages:Irena_UnifFit:DataFolderName
//	SVAR IntensityWaveName=root:Packages:Irena_UnifFit:IntensityWaveName
//	SVAR QWavename=root:Packages:Irena_UnifFit:QWavename
//	SVAR ErrorWaveName=root:Packages:Irena_UnifFit:ErrorWaveName
//
//	IR1_CreateLoggbook()		//this creates the logbook
//	SVAR nbl=root:Packages:SAS_Modeling:NotebookName
//
//	IR1L_AppendAnyText("     ")
//		IR1L_AppendAnyText("***********************************************")
//		IR1L_AppendAnyText("***********************************************")
//		IR1L_AppendAnyText("Saved Results of the UNIFIED FIT on the data from: \t"+DataAreFrom)	
//		IR1_InsertDateAndTime(nbl)
//		IR1L_AppendAnyText("Name of data waves Int/Q/Error \t"+IntensityWaveName+"\t"+QWavename+"\t"+ErrorWaveName)
//		if(UseSMRData)
//			IR1L_AppendAnyText("Slit smeared data were used. Slit length = "+num2str(SlitLengthUnif))
//		endif
//		IR1L_AppendAnyText("Output wave names :")
//		IR1L_AppendAnyText("Int/Q \t"+"UnifiedFitIntensity_"+num2str(LastSavedUnifOutput)+"\tUnifiedFitQvector_"+num2str(LastSavedUnifOutput))
//		if(ExportLocalFits)
//			IR1L_AppendAnyText("Loacl fits saved also")
//		endif
//		
//		IR1L_AppendAnyText("Number of fitted levels: "+num2str(NumberOfLevels))
//		IR1L_AppendAnyText("Fitting results: ")
//	IR1L_AppendAnyText("SAS background = "+num2str(SASBackground)+", was fitted? = "+num2str(FitSASBackground)+"       (yes=1/no=0)")
//	variable i
//	For (i=1;i<=NumberOfLevels;i+=1)
//		IR1L_AppendAnyText("***********  Level  "+num2str(i))
//		NVAR tempVal =$("Level"+num2str(i)+"Rg")
//		NVAR tempValError =$("Level"+num2str(i)+"RgError")
//		NVAR fitTempVal=$("Level"+num2str(i)+"FitRg")
//			IR1L_AppendAnyText("Rg      \t\t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
//		NVAR tempVal =$("Level"+num2str(i)+"G")
//		NVAR tempValError =$("Level"+num2str(i)+"GError")
//		NVAR fitTempVal=$("Level"+num2str(i)+"FitG")
//			IR1L_AppendAnyText("G      \t\t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
//		NVAR tempVal =$("Level"+num2str(i)+"P")
//		NVAR tempValError =$("Level"+num2str(i)+"PError")
//		NVAR fitTempVal=$("Level"+num2str(i)+"FitP")
//			IR1L_AppendAnyText("P     \t \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
//		NVAR tempValMassFractal =$("Level"+num2str(i)+"MassFractal")
//			if (tempValMassFractal)
//				IR1L_AppendAnyText("\tAssumed Mass Fractal")
//				IR1L_AppendAnyText("Parameter B calculated as B=(G*P/Rg^P)*Gamma(P/2)")
//			else
//				NVAR tempVal =$("Level"+num2str(i)+"B")
//				NVAR tempValError =$("Level"+num2str(i)+"BError")
//				NVAR fitTempVal=$("Level"+num2str(i)+"FitB")
//				IR1L_AppendAnyText("B     \t \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
//			endif
//		NVAR tempVal =$("Level"+num2str(i)+"RGCO")
//		NVAR tempValError =$("Level"+num2str(i)+"RgCOError")
//		NVAR LinktempVal=$("Level"+num2str(i)+"LinkRgCO")
//		NVAR fitTempVal=$("Level"+num2str(i)+"FitRGCO")
//				if (fitTempVal)
//					IR1L_AppendAnyText("RgCO linked to lower level Rg =\t"+ num2str(tempVal))
//				else
//					IR1L_AppendAnyText("RgCO      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
//				endif
//		NVAR tempVal =$("Level"+num2str(i)+"K")
//			IR1L_AppendAnyText("K      \t"+ num2str(tempVal))
//		NVAR tempValCorrelations =$("Level"+num2str(i)+"Corelations")
//			if (tempValCorrelations)
//				IR1L_AppendAnyText("Assumed Corelations so following parameters apply")
//				NVAR tempVal =$("Level"+num2str(i)+"ETA")
//				NVAR tempValError =$("Level"+num2str(i)+"ETAError")
//				NVAR fitTempVal=$("Level"+num2str(i)+"FitETA")
//					IR1L_AppendAnyText("ETA      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
//				NVAR tempVal =$("Level"+num2str(i)+"PACK")
//				NVAR tempValError =$("Level"+num2str(i)+"PACKError")
//				NVAR fitTempVal=$("Level"+num2str(i)+"FitPACK")
//				IR1L_AppendAnyText("PACK      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
//		else
//				IR1L_AppendAnyText("Corelations       \tNot assumed")
//			endif
//
//		NVAR tempVal =$("Level"+num2str(i)+"Invariant")
//				IR1L_AppendAnyText("Invariant  =\t"+num2str(tempVal)+"   cm^(-1) A^(-3)")
//		NVAR tempVal =$("Level"+num2str(i)+"SurfaceToVolRat")
//			if (Numtype(tempVal)==0)
//				IR1L_AppendAnyText("Surface to volume ratio  =\t"+num2str(tempVal)+"   m^(2) / cm^(3)")
//			endif
//			IR1L_AppendAnyText("  ")
//	endfor
//	
//		IR1L_AppendAnyText("Fit has been reached with following parameters")
//		IR1_InsertDateAndTime(nbl)
//		NVAR/Z AchievedChisq
//		if(NVAR_Exists(AchievedChisq))
//			IR1L_AppendAnyText("Chi-Squared \t"+ num2str(AchievedChisq))
//		endif
//		DoWindow /F IR1_LogLogPlotU
//		if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
//			IR1L_AppendAnyText("Points selected for fitting \t"+ num2str(pcsr(A)) + "   to \t"+num2str(pcsr(B)))
//		else
//			IR1L_AppendAnyText("Whole range of data selected for fitting")
//		endif
//		IR1L_AppendAnyText(" ")
//		IR1L_AppendAnyText("***********************************************")
//
//	setdataFolder oldDf
//end
//