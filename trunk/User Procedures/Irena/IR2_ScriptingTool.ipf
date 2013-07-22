#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.15
Constant IR2SversionNumber=1.15
//*************************************************************************\
//* Copyright (c) 2005 - 2013, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.01 added license for ANL
//1.02 FIxed Scripting of Size distribution where we wer emissing eventcode=2  which caused the data not to be updated beteen fits.
//1.03 support for single data set Modeling II
//1.04 fixed bug where the tool was missign the one before last folder (wrong wave length)... 
//1.05 fixed bug in scripting Unified fit, eventcode was not set correctly.  Added match string (using grep, no * needed), added check versions. 
//1.06 added sorting order controls and added functionality for the Ploting tool I 
//1.07 yet another fix for Size distribution tool;. It was not loading the new data properly. 
//1.08 added Scripting ability for results in Ploting tool I
//1.09 significant increase in speed due to changes to Control procedures.
//1.10 added handling of uncertainities (errors) for Results data type (needed for Sizes)
//1.11 modified to handle d, t, and m type QRS data (d-spacing, two theta, and distance) for needs to Nika users
//1.12 Added Guinier-Porod as controlled tool and fixed minor Folder selection bug for other tools 
//1.13 modified to handle chanigng of the data type between the scripting tool and the tool being called. 
//1.14 fixed bug in calling Plotting tool with results
//1.15 added skip review of fitting parameters for Unified fit improvement. 

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
		UpdatePanelVersionNumber("IR2S_ScriptingToolPnl", IR2SversionNumber)
	endif

end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR2S_MainCheckVersion()	
	DoWindow IR2S_ScriptingToolPnl
	if(V_Flag)
		if(!CheckPanelVersionNumber("IR2S_ScriptingToolPnl", IR2SversionNumber))
			DoAlert /T="The Scripting tool panel was created by old version of Irena " 1, "Scripting tool may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				Execute/P("DoWindow/K IR2S_ScriptingToolPnl")
				Execute/P("IR2S_ScriptingTool()")
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
		string ListOfAvailableResults=IR2C_ReturnKnownToolResults(popStr)
		//execute("PopupMenu ResultsTypeSelector, win=IR2S_ScriptingToolPnl, popvalue="+StringFromList(0,ListOfAvailableResults)+", value=IR2C_ReturnKnownToolResults(\""+popStr+"\")")
		execute("PopupMenu ResultsTypeSelector, win=IR2S_ScriptingToolPnl, mode=1, value=IR2C_ReturnKnownToolResults(\""+popStr+"\")")
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

	Button FitWithUnified,win= IR2S_ScriptingToolPnl , disable=UseResults
	Button FitWithSizes,win= IR2S_ScriptingToolPnl , disable=UseResults
	Button FitWithMoldelingII,win= IR2S_ScriptingToolPnl , disable=UseResults
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
		IR2S_HelpPanel()
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
		Notebook $nb text="3. Modeling II (NOTE: supported only with one input data set, not \"Multiple Input data sets\" selected!)\r"
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
		Notebook $nb text="If you are running Unified fit or Modeling II you can reset parameters between the fits. This option is "
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
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(28,44,412,625) as "Scripting tool"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 1,textrgb= (0,0,65535)
	DrawText 29,29,"Scripting tool"

	Button GetHelp,pos={280,4},size={90,15},proc=IR2S_ButtonProc,title="Get help"
	Button GetHelp,fSize=10,fStyle=2
	Button GetLogbook,pos={280,21},size={90,15},proc=IR2S_ButtonProc,title="Open logbook"
	Button GetLogbook,fSize=10,fStyle=2

	PopupMenu StartFolderSelection,pos={10,40},size={130,15},proc=IR2S_PopMenuProc,title="Select start folder"
	PopupMenu StartFolderSelection,mode=1,popvalue=root:Packages:Irena:ScriptingTool:StartFolderName,value= #"\"root:;\"+IR2S_GenStringOfFolders2(root:Packages:Irena:ScriptingTool:UseIndra2Data, root:Packages:Irena:ScriptingTool:UseQRSdata,2,1)"

	CheckBox UseIndra2data,pos={302,45},size={76,14},proc=IR2S_CheckProc,title="USAXS?"
	CheckBox UseIndra2data,variable= root:Packages:Irena:ScriptingTool:UseIndra2Data
	CheckBox UseQRSdata,pos={302,63},size={64,14},proc=IR2S_CheckProc,title="QRS data?"
	CheckBox UseQRSdata,variable= root:Packages:Irena:ScriptingTool:UseQRSdata
	CheckBox UseResults,pos={302,81},size={64,14},proc=IR2S_CheckProc,title="Results?"
	CheckBox UseResults,variable= root:Packages:Irena:ScriptingTool:UseResults

	PopupMenu ToolResultsSelector,pos={10,65},size={230,15},fStyle=2,proc=IR2S_PopMenuProc,title="Which tool results?    ", disable=!(root:Packages:Irena:ScriptingTool:UseResults)
	PopupMenu ToolResultsSelector,mode=1,popvalue=root:Packages:Irena:ScriptingTool:SelectedResultsTool,value= #"root:Packages:IrenaControlProcs:AllKnownToolsResults"//, bodyWidth=170

	PopupMenu ResultsTypeSelector,pos={10,90},size={230,15},fStyle=2,proc=IR2S_PopMenuProc,title="Which results?          ", disable=!(root:Packages:Irena:ScriptingTool:UseResults)
	PopupMenu ResultsTypeSelector,mode=1,popvalue=root:Packages:Irena:ScriptingTool:SelectedResultsType,value= IR2C_ReturnKnownToolResults(root:Packages:IrenaControlProcs:AllKnownToolsResults)//, bodyWidth=170

	PopupMenu ResultsGenerationToUse,pos={10,115},size={230,15},fStyle=2,proc=IR2S_PopMenuProc,title="Results Generation?           ", disable=!(root:Packages:Irena:ScriptingTool:UseResults)
	PopupMenu ResultsGenerationToUse,mode=1,popvalue=root:Packages:Irena:ScriptingTool:ResultsGenerationToUse,value= "Latest;_0;_1;_2;_3;_4;_5;_6;_7;_8;_9;_10;"

	ListBox DataFolderSelection,pos={4,135},size={372,180}, mode=9
	ListBox DataFolderSelection,listWave=root:Packages:Irena:ScriptingTool:ListOfAvailableData
	ListBox DataFolderSelection,selWave=root:Packages:Irena:ScriptingTool:SelectionOfAvailableData

	//SVAR FolderNameMatchString=root:Packages:Irena:ScriptingTool:FolderNameMatchString
	SetVariable FolderNameMatchString,pos={10,325},size={150,15}, proc=IR2S_ScriptToolSetVarProc,title="Match (RegEx)"
	Setvariable FolderNameMatchString,fSize=10,fStyle=2, variable=root:Packages:Irena:ScriptingTool:FolderNameMatchString

	Button AllData,pos={170,325},size={100,15},proc=IR2S_ButtonProc,title="Select all data"
	Button AllData,fSize=10,fStyle=2
	Button NoData,pos={270,325},size={100,15},proc=IR2S_ButtonProc,title="DeSelect all data"
	Button NoData,fSize=10,fStyle=2

	PopupMenu SortFolders,pos={10,348},size={130,20},fStyle=2,proc=IR2S_PopMenuProc,title="Sort Folders"
	PopupMenu SortFolders,mode=1,popvalue=root:Packages:Irena:ScriptingTool:FolderSortString,value= #"\"---;Alphabetical;Reverse Alphabetical;_xyz;_xyz.ext;Reverse _xyz;Reverse _xyz.ext;_xyz_000;Reverse _xyz_000;\""

	Button FitWithUnified,pos={90,375},size={200,15},proc=IR2S_ButtonProc,title="Run Unified Fit on selected data"
	Button FitWithUnified,fSize=10,fStyle=2, disable=(root:Packages:Irena:ScriptingTool:UseResults)

	Button FitWithGuinierPorod,pos={90,395},size={200,15},proc=IR2S_ButtonProc,title="Run Guinier-Porod on selected data"
	Button FitWithGuinierPorod,fSize=10,fStyle=2, disable=(root:Packages:Irena:ScriptingTool:UseResults)

	Button FitWithSizes,pos={20,415},size={160,15},proc=IR2S_ButtonProc,title="Run Size dist. no uncert."
	Button FitWithSizes,fSize=10,fStyle=2, disable=(root:Packages:Irena:ScriptingTool:UseResults)
	Button FitWithSizesU,pos={210,415},size={160,15},proc=IR2S_ButtonProc,title="Run Size distr. w/uncert."
	Button FitWithSizesU,fSize=10,fStyle=2, disable=(root:Packages:Irena:ScriptingTool:UseResults)
	Button FitWithMoldelingII,pos={90,435},size={200,15},proc=IR2S_ButtonProc,title="Run Modeling II on selected data"
	Button FitWithMoldelingII,fSize=10,fStyle=2, disable=(root:Packages:Irena:ScriptingTool:UseResults)
	Button CallPlottingToolII,pos={20,455},size={160,15},proc=IR2S_ButtonProc,title="Run (w/reset) Plotting tool"
	Button CallPlottingToolII,fSize=10,fStyle=2
	Button CallPlottingToolIIA,pos={210,455},size={160,15},proc=IR2S_ButtonProc,title="Append to Plotting tool"
	Button CallPlottingToolIIA,fSize=10,fStyle=2

	CheckBox SaveResultsInNotebook,pos={30,490},size={64,14},proc=IR2S_CheckProc,title="Save results in notebook?"
	CheckBox SaveResultsInNotebook,variable= root:Packages:Irena:ScriptingTool:SaveResultsInNotebook
	CheckBox ResetBeforeNextFit,pos={30,510},size={64,14},proc=IR2S_CheckProc,title="Reset before next fit? (Unified/Modeling II)"
	CheckBox ResetBeforeNextFit,variable= root:Packages:Irena:ScriptingTool:ResetBeforeNextFit
	CheckBox SaveResultsInFldrs,pos={30,530},size={64,14},proc=IR2S_CheckProc,title="Save results in folders?"
	CheckBox SaveResultsInFldrs,variable= root:Packages:Irena:ScriptingTool:SaveResultsInFldrs
	CheckBox SaveResultsInWaves,pos={30,550},size={64,14},proc=IR2S_CheckProc,title="Save results in waves (Modeling II)?"
	CheckBox SaveResultsInWaves,variable= root:Packages:Irena:ScriptingTool:SaveResultsInWaves

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


Function/T IR2S_GenStringOfFolders2(UseIndra2Structure, UseQRSStructure, SlitSmearedData, AllowQRDataOnly)
	variable UseIndra2Structure, UseQRSStructure, SlitSmearedData, AllowQRDataOnly
		//SlitSmearedData =0 for DSM data, 
		//                          =1 for SMR data 
		//                    and =2 for both
		// AllowQRDataOnly=1 if Q and R data are allowed only (no error wave). For QRS data ONLY!
	
	string ListOfQFolders
	//	if UseIndra2Structure = 1 we are using Indra2 data, else return all folders 
	string result
	variable i
	if (UseIndra2Structure)
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
	elseif (UseQRSStructure)
		ListOfQFolders=IN2G_FindFolderWithWaveTypes("root:", 10, "q*", 1)
		result=IR1_ReturnListQRSFolders(ListOfQFolders,AllowQRDataOnly)
	else
		result=IN2G_FindFolderWithWaveTypes("root:", 10, "*", 1)
	endif
	
	//now the result contains folder, we want list of parents here. create new list...
	string newresult=""
	string tempstr2
	for(i=0;i<ItemsInList(result , ";");i+=1)
		tempstr2=stringFromList(i,result,";")
		tempstr2=RemoveListItem(ItemsInList(tempstr2,":")-1, tempstr2  , ":")
		if(!stringmatch(newresult, "*"+tempstr2+"*" ))
			newresult+=tempstr2+";"
		endif
		
	endfor
	
	newresult=GrepList(newresult, "^((?!Packages).)*$" )
	return newresult
end

//**************************************************************************************
//**************************************************************************************
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
			IR2P_FindFolderWithWaveTypesWV(StartFolder, 10, "(?i)^r||i$", 1, ResultingWave)
			//IR2P_FindFolderWithWaveTypesWV("root:", 10, "*i*", 1, ResultingWave)
			result=IR2S_CheckForRightQRSTripletWvs(ResultingWave,AllowQRDataOnly)
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

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//**********************************************************************************************************
static Function/T IR2S_CheckForRightQRSTripletWvs(ResultingWave, AllowQROnly)
	wave/T ResultingWave
	variable AllowQROnly	

	string oldDf=GetDataFolder(1)
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
				if(stringmatch(";"+AllWaves, ";*q"+ty+";*" )||stringmatch(";"+AllWaves, ";*m"+ty+";*" )||stringmatch(";"+AllWaves, ";*t"+ty+";*" )||stringmatch(";"+AllWaves, ";*d"+ty+";*" )||stringmatch(";"+AllWaves, ";*az"+ty+";*" ))
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
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function IR2S_SortListOfAvailableFldrs()

	SVAR FolderSortString=root:Packages:Irena:ScriptingTool:FolderSortString
	Wave/T ListOfAvailableData=root:Packages:Irena:ScriptingTool:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:Irena:ScriptingTool:SelectionOfAvailableData
	Duplicate/Free SelectionOfAvailableData, TempWv
	variable i
	string tempstr 
	SelectionOfAvailableData=0
	if(stringMatch(FolderSortString,"---"))
		//nothing to do
	elseif(stringMatch(FolderSortString,"Alphabetical"))
		Sort /A ListOfAvailableData, ListOfAvailableData
	elseif(stringMatch(FolderSortString,"Reverse Alphabetical"))
		Sort /A /R ListOfAvailableData, ListOfAvailableData
	elseif(stringMatch(FolderSortString,"_xyz"))
		For(i=0;i<numpnts(TempWv);i+=1)
			TempWv[i] = str2num(StringFromList(ItemsInList(ListOfAvailableData[i]  , "_")-1, ListOfAvailableData[i]  , "_"))
		endfor
		Sort TempWv, ListOfAvailableData
	elseif(stringMatch(FolderSortString,"Reverse _xyz"))
		For(i=0;i<numpnts(TempWv);i+=1)
			TempWv[i] = str2num(StringFromList(ItemsInList(ListOfAvailableData[i]  , "_")-1, ListOfAvailableData[i]  , "_"))
		endfor
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



Function IR2S_UpdateListOfAvailFiles()

	string OldDF=GetDataFolder(1)
	setDataFolder root:Packages:Irena:ScriptingTool
	
	NVAR UseIndra2Data=root:Packages:Irena:ScriptingTool:UseIndra2Data
	NVAR UseQRSdata=root:Packages:Irena:ScriptingTool:UseQRSData
	NVAR UseResults=root:Packages:Irena:ScriptingTool:UseResults
	SVAR StartFolderName=root:Packages:Irena:ScriptingTool:StartFolderName
	string LStartFolder
	if(stringmatch(StartFolderName,"---"))
		LStartFolder="root:"
	else
		LStartFolder = StartFolderName
	endif
	string CurrentFolders=IR2S_GenStringOfFolders(LStartFolder,UseIndra2Data, UseQRSData,UseResults, 2,1)

	Wave/T ListOfAvailableData=root:Packages:Irena:ScriptingTool:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:Irena:ScriptingTool:SelectionOfAvailableData
	variable i, j
	string TempStr
		
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
	
	string OldDF=GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S Irena
	NewDataFolder/O/S ScriptingTool
	
	string ListOfVariables
	string ListOfStrings
	variable i

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="StartFolderName;FolderNameMatchString;FolderSortString;SelectedResultsType;SelectedResultsTool;ResultsGenerationToUse;"
	//"DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;SaveResultsInNotebook;ResetBeforeNextFit;SaveResultsInFldrs;SaveResultsInWaves;"

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
		Abort  "The Plotting Tool II panel must be opened"
	else
		DoWIndow/F IR1P_ControlPanel 
	endif
	
	string OldDF=GetDataFolder(1)
	setDataFolder root:Packages:Irena:ScriptingTool
	//set to same data types...
	NVAR STUseIndra2Data = root:Packages:Irena:ScriptingTool:UseIndra2Data
	NVAR STUseQRSdata =root:Packages:Irena:ScriptingTool:UseQRSdata
	NVAR STUseResults=root:Packages:Irena:ScriptingTool:UseResults
	
	NVAR PTUseIndra2Data=root:Packages:GeneralplottingTool:UseIndra2Data
	NVAR PTUseQRSdata=root:Packages:GeneralplottingTool:UseQRSdata
	NVAR PTUseResults=root:Packages:GeneralplottingTool:UseResults
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
	string CurrentFolderName, TempStr, result, tempStr2
	if(reset)
		IR1P_InputPanelButtonProc("ResetAll")				//resent graph?
	endif	
	variable AddedFiles=0
	Print " **** working : adding data sets to plotting tool"
	For(i=0;i<numpnts(ListOfAvailableData);i+=1)
		if(SelectionOfAvailableData[i]>0.5)
			CurrentFolderName = LStartFolder + ListOfAvailableData[i]
			//OK, now we know which files to process	
			//now stuff the name of the new folder in the folder name in Ploting tool.
			SVAR DataFolderName = root:Packages:GeneralplottingTool:DataFolderName
			DataFolderName = CurrentFolderName
			//now except for case when we use Indra 2 data we need to reload the other wave names... 
			STRUCT WMPopupAction PU_Struct
			PU_Struct.ctrlName = "SelectDataFolder"
			PU_Struct.popNum=0
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
					//tempStr2 = StringByKey(tempStr2, ResultsDataTypesLookup  , ":", ";")
					TempXName=StringByKey(tempStr2, ResultsDataTypesLookup  , ":", ";")+"_"+StringFromList(ItemsInList(result,"_")-1, result, "_")
				else	//known result we want to use... It should exist (guarranteed by prior code)
					TempYName=SelectedResultsType+ResultsGenerationToUse
					TempXName=StringByKey(SelectedResultsType, ResultsDataTypesLookup  , ":", ";")+ResultsGenerationToUse
				endif

				SVAR XnameStr=root:Packages:GeneralplottingTool:QWavename
				XnameStr = TempXName
				PopupMenu QvecDataName win=IR1P_ControlPanel, popmatch=TempXName
				SVAR YnameStr=root:Packages:GeneralplottingTool:IntensityWaveName
				YnameStr = TempYName
				PopupMenu IntensityDataName win=IR1P_ControlPanel, popmatch=TempYName
				//and update errors if needed...
				PU_Struct.ctrlName = "IntensityDataName"
				PU_Struct.popNum=0
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
	if(AddedFiles==0)
		//user did tno select any data, probaby screwed up...
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
		Abort  "The Modeling II panel and graph must be opened"
	else
		DoWIndow/F LSQF2_MainPanel 
	endif
	
	DoWindow LSQF_MainGraph
	if(!V_Flag)
		Abort  "The Modeling II panel and graph must be opened"
	else
		DoWIndow/F LSQF_MainGraph 
	endif

	string OldDF=GetDataFolder(1)
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
	variable StartQ, EndQ		//need to store these sothe tool does not reset them... 
	NVAR CurMinQ=root:Packages:IR2L_NLSQF:Qmin_set1
	NVAR CurMaxQ=root:Packages:IR2L_NLSQF:Qmax_set1
	StartQ=CurMinQ
	EndQ=CurMaxQ
	
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
			PU_Struct.popNum=0
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
			doUpdate
			//now we need to set back the Qmin and max.
			CurMinQ = StartQ
			CurMaxQ = EndQ
		
			variable/g root:Packages:IR2L_NLSQF:FitFailed
			//do fitting
			IR2L_InputPanelButtonProc("FitModelSkipDialogs")
			DoUpdate
			NVAR FitFailed=root:Packages:IR2L_NLSQF:FitFailed
			
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

	string OldDF=GetDataFolder(1)
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
	if(V_Flag)
		Wave Ywv = csrXWaveRef(A  , "IR1R_SizesInputGraph" )
		StartQ = Ywv[pcsr(A  , "IR1R_SizesInputGraph" )]
		EndQ = Ywv[pcsr(B  , "IR1R_SizesInputGraph" )]
	endif
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
			PU_Struct.popNum=0
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
				if(binarysearch(Qwave,StartQ)>0)
					Cursor  /P /W=IR1R_SizesInputGraph A  IntensityOriginal binarysearch(Qwave,StartQ)
				endif	
			endif
			if(EndQ>0)
				Wave Qwave = root:Packages:Sizes:Q_vecOriginal
				if(binarysearch(Qwave,EndQ)>0)
					Cursor  /P /W=IR1R_SizesInputGraph B  IntensityOriginal binarysearch(Qwave,EndQ)	
				endif
			endif
			
			variable/g root:Packages:Sizes:FitFailed
			//do fitting
			if(uncert)
				IR1R_SizesEstimateErrors()	
			else
				IR1R_SizesFitting("DoFittingSkipReset")
			endif
			DoUpdate
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
	
	DoWindow GunierPorod_LogLogPlot
	if(!V_Flag)
		Abort  "The Guinier Porod tool panel and graph must be opened"
	else
		DoWIndow/F GunierPorod_LogLogPlot 
	endif


	string OldDF=GetDataFolder(1)
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
	DoWIndow IR1_LogLogPlotU
	if(V_Flag)
		Wave Ywv = csrXWaveRef(A  , "GunierPorod_LogLogPlot" )
		StartQ = Ywv[pcsr(A  , "GunierPorod_LogLogPlot" )]
		EndQ = Ywv[pcsr(B  , "GunierPorod_LogLogPlot" )]
	endif
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
			PU_Struct.popNum=0
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
				if(binarysearch(Qwave,StartQ)>0)
					Cursor  /P /W=IR1_LogLogPlotU A  OriginalIntensity binarysearch(Qwave,StartQ)
				endif	
			endif
			if(EndQ>0)
				Wave Qwave = root:Packages:Irena:GuinierPorod:OriginalQvector
				if(binarysearch(Qwave,EndQ)>0)
					Cursor  /P /W=IR1_LogLogPlotU B  OriginalIntensity binarysearch(Qwave,EndQ)	
				endif
			endif
			
			variable/g root:Packages:Irena:GuinierPorod:FitFailed
			//do fitting
			IR3GP_PanelButtonProc("DoFittingSkipReset")
			DoUpdate
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


	string OldDF=GetDataFolder(1)
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
		Wave Ywv = csrXWaveRef(A  , "IR1_LogLogPlotU" )
		StartQ = Ywv[pcsr(A  , "IR1_LogLogPlotU" )]
		EndQ = Ywv[pcsr(B  , "IR1_LogLogPlotU" )]
	endif
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
			PU_Struct.popNum=0
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
				if(binarysearch(Qwave,StartQ)>0)
					Cursor  /P /W=IR1_LogLogPlotU A  OriginalIntensity binarysearch(Qwave,StartQ)
				endif	
			endif
			if(EndQ>0)
				Wave Qwave = root:Packages:Irena_UnifFit:OriginalQvector
				if(binarysearch(Qwave,EndQ)>0)
					Cursor  /P /W=IR1_LogLogPlotU B  OriginalIntensity binarysearch(Qwave,EndQ)	
				endif
			endif
			
			variable/g root:Packages:Irena_UnifFit:FitFailed
			//do fitting
			IR1A_InputPanelButtonProc("DoFittingSkipReset")
			DoUpdate
			NVAR FitFailed=root:Packages:Irena_UnifFit:FitFailed
			
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
		Notebook ScriptingToolNbk text="Gunier-Porod results from folder :   "+ DataFolderName+"\r"
		Notebook ScriptingToolNbk text="\r"
		if(FitFailed)
			Notebook ScriptingToolNbk text="Fit failed\r"
		else
			Notebook ScriptingToolNbk  scaling={50,50}, frame=1, picture={GunierPorod_LogLogPlot,2,1}	
			Notebook ScriptingToolNbk text="\r"
			IR2S_RecordResultsToNbkGP()
		endif
end	

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_RecordResultsToNbkGP()	

	string OldDF=GetDataFolder(1)
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
	Notebook ScriptingToolNbk text="Summary of Gunier Porod fit results :"+"\r"
	if(UseSMRData)
		Notebook ScriptingToolNbk text="Slit smeared data were. Slit length [A^-1] = "+num2str(SlitLengthUnif)+"\r"
	endif
	Notebook ScriptingToolNbk text="Name of data waves Int/Q/Error \t"+IntensityWaveName+"\t"+QWavename+"\t"+ErrorWaveName+"\r"
	Notebook ScriptingToolNbk text="Number of levels: "+num2str(NumberOfLevels)+"\r"
	Notebook ScriptingToolNbk text="SAS background = "+num2str(SASBackground)+", was fitted? = "+num2str(FitSASBackground)+"       (yes=1/no=0)"+"\r"
	Notebook ScriptingToolNbk text="\r"
	variable i
	STRUCT GunierPorodLevel Par
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

		DoWindow /F GunierPorod_LogLogPlot
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

	string OldDF=GetDataFolder(1)
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

	string OldDF=GetDataFolder(1)
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
//	string OldDF=GetDataFolder(1)
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