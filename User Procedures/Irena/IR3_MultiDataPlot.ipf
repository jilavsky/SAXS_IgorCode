#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1
constant IR3LversionNumber = 1			//MultiDataPloting tool version number. 

//*************************************************************************\
//* Copyright (c) 2005 - 2020, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.0 New ploting tool to make plotting various data easy for multiple data sets.  



///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3L_MultiSaPlotFit()

	IN2G_CheckScreenSize("width",1000)
	IN2G_CheckScreenSize("height",670)
	DoWIndow IR3L_MultiSaPlotFitPanel
	if(V_Flag)
		DoWindow/F IR3L_MultiSaPlotFitPanel
	else
		IR3L_InitMultiSaPlotFit()
		IR3L_MultiSaPlotFitPanelFnct()
		//		setWIndow IR3L_MultiSaPlotFitPanel, hook(CursorMoved)=IR3D_PanelHookFunction
		IR1_UpdatePanelVersionNumber("IR3L_MultiSaPlotFitPanel", IR3LversionNumber,1)
		//link it to top graph, if exists
		IR3L_SetStartConditions()
	endif
	//IR3L_UpdateListOfAvailFiles()
	IR3C_MultiUpdateListOfAvailFiles("root:Packages:Irena:MultiSaPlotFit")
//	IR3D_RebuildListboxTables()
end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3L_MainCheckVersion()	
	DoWindow IR3L_MultiSaPlotFitPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR3L_MultiSaPlotFitPanel", IR3LversionNumber))
			DoAlert /T="The Multi Data Plots panel was created by incorrect version of Irena " 1, "Multi Data Plots may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				KillWIndow/Z IR3L_MultiSaPlotFitPanel
				IR3L_MultiSaPlotFit()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR3L_InitMultiSaPlotFit()
			endif
		endif
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3L_SetStartConditions()
		
		SVAR GraphWindowName = root:Packages:Irena:MultiSaPlotFit:GraphWindowName
		SVAR GraphUserTitle=root:Packages:Irena:MultiSaPlotFit:GraphUserTitle
		
		//look for top MultiDataPlot_*, if does nto exist, attach to top graph, if exists... 
		string List=WinList("MultiDataPlot_*", ";", "WIN:1" )
		string TopWinName
		if(ItemsInList(list)>0)
			TopWinName = stringFromList(0,list)
		else
			list = WinList("*", ";", "WIN:1" )
			if(ItemsInList(list)>0)
				TopWinName = stringFromList(0,list)
			else
				TopWinName = ""
			endif
		endif
		if(strlen(TopWinName)>0)
			GetWindow $(TopWinName) title 
			GraphUserTitle = S_value
			GraphWindowName = TopWinName
			DoWindow/F $(TopWinName)
		else
			GraphUserTitle = ""
			GraphWindowName = ""
		
		endif
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR3L_MultiSaPlotFitPanelFnct()
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(5.25,43.25,605,820) as "MultiData Ploting tool"
	DoWIndow/C IR3L_MultiSaPlotFitPanel
	TitleBox MainTitle title="\Zr220Multi Data ploting tool",pos={140,1},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fColor=(0,0,52224)
								//	TitleBox FakeLine2 title=" ",fixedSize=1,size={330,3},pos={16,428},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena:MultiSaPlotFit","IR3L_MultiSaPlotFitPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	Button GetHelp,pos={480,10},size={80,15},fColor=(65535,32768,32768), proc=IR3L_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}
	IR3C_MultiAppendControls("Irena:MultiSaPlotFit","IR3L_MultiSaPlotFitPanel", "IR3L_DoubleClickAction",0,1)
														//	NVAR UseIndra2Data = root:Packages:Irena:MultiSaPlotFit:UseIndra2Data
														//	NVAR UseQRSdata = root:Packages:Irena:MultiSaPlotFit:UseQRSdata
														//	NVAR UseResults = root:Packages:Irena:MultiSaPlotFit:UseResults
														//	if(UseResults+UseQRSdata+UseIndra2Data!=1)
														//		UseIndra2Data = 0
														//		UseQRSdata = 1
														//		UseResults = 0
														//	endif
														//	TitleBox Dataselection title="\Zr130Data selection",size={100,15},pos={10,10},frame=0,fColor=(0,0,65535),labelBack=0
														//	Checkbox UseIndra2Data, pos={10,30},size={76,14},title="USAXS", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSaPlotFit:UseIndra2Data
														//	checkbox UseQRSData, pos={100,30}, title="QRS(QIS)", size={76,14},proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSaPlotFit:UseQRSdata
														//	checkbox UseResults, pos={190,30}, title="Irena results", size={76,14},proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSaPlotFit:UseResults
														//	PopupMenu StartFolderSelection,pos={10,50},size={180,15},proc=IR3L_PopMenuProc,title="Start fldr"
														//	SVAR DataStartFolder = root:Packages:Irena:MultiSaPlotFit:DataStartFolder
														//	PopupMenu StartFolderSelection,mode=1,popvalue=DataStartFolder,value= #"\"root:;\"+IR3C_GenStringOfFolders2(root:Packages:Irena:MultiSaPlotFit:UseIndra2Data, root:Packages:Irena:MultiSaPlotFit:UseQRSdata,2,1)"
														//	SetVariable FolderNameMatchString,pos={10,75},size={210,15}, proc=IR3L_SetVarProc,title="Folder Match (RegEx)"
														//	Setvariable FolderNameMatchString,fSize=10,fStyle=2, variable=root:Packages:Irena:MultiSaPlotFit:DataMatchString
														//	checkbox InvertGrepSearch, pos={222,75}, title="Invert?", size={76,14},proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSaPlotFit:InvertGrepSearch
														//
														//	PopupMenu SortFolders,pos={10,100},size={180,20},fStyle=2,proc=IR3L_PopMenuProc,title="Sort Folders"
														//	SVAR FolderSortString = root:Packages:Irena:MultiSaPlotFit:FolderSortString
														//	PopupMenu SortFolders,mode=1,popvalue=FolderSortString,value= #"root:Packages:Irena:MultiSaPlotFit:FolderSortStringAll"
														//	
														//	//Indra data types:
														//	PopupMenu SubTypeData,pos={10,120},size={180,20},fStyle=2,proc=IR3L_PopMenuProc,title="Sub-type Data"
														//	SVAR DataSubType = root:Packages:Irena:MultiSaPlotFit:DataSubType
														//	PopupMenu SubTypeData,mode=1,popvalue=DataSubType,value= ""
														//	//results data types
														//	SVAR SelectedResultsTool = root:Packages:Irena:MultiSaPlotFit:SelectedResultsTool
														//	SVAR SelectedResultsType = root:Packages:Irena:MultiSaPlotFit:SelectedResultsType
														//	SVAR ResultsGenerationToUse = root:Packages:Irena:MultiSaPlotFit:ResultsGenerationToUse
														//	PopupMenu ToolResultsSelector,pos={10,120},size={230,15},fStyle=2,proc=IR3L_PopMenuProc,title="Which tool results?    "
														//	PopupMenu ToolResultsSelector,mode=1,popvalue=SelectedResultsTool,value= #"root:Packages:IrenaControlProcs:AllKnownToolsResults"
														//	PopupMenu ResultsTypeSelector,pos={10,140},size={230,15},fStyle=2,proc=IR3L_PopMenuProc,title="Which results?          "
														//	PopupMenu ResultsTypeSelector,mode=1,popvalue=SelectedResultsType,value= #"IR2C_ReturnKnownToolResults(root:Packages:Irena:MultiSaPlotFit:SelectedResultsTool)"
														//	PopupMenu ResultsGenerationToUse,pos={10,160},size={230,15},fStyle=2,proc=IR3L_PopMenuProc,title="Results Generation?           "
														//	PopupMenu ResultsGenerationToUse,mode=1,popvalue=ResultsGenerationToUse,value= "Latest;_0;_1;_2;_3;_4;_5;_6;_7;_8;_9;_10;"
														//
														//
														//	ListBox DataFolderSelection,pos={4,180},size={250,495}, mode=10
														//	ListBox DataFolderSelection,listWave=root:Packages:Irena:MultiSaPlotFit:ListOfAvailableData
														//	ListBox DataFolderSelection,selWave=root:Packages:Irena:MultiSaPlotFit:SelectionOfAvailableData
														//	ListBox DataFolderSelection,proc=IR3L_ListBoxProc
														//
															
	//graph controls

	SVAR GraphWindowName=root:Packages:Irena:MultiSaPlotFit:GraphWindowName
	PopupMenu SelectGraphWindows,pos={280,90},size={310,20},proc=IR3L_PopMenuProc, title="Select Graph",help={"Select one of controllable graphs"}
	PopupMenu SelectGraphWindows,value=IR3L_GraphListPopupString(),mode=1, popvalue=GraphWindowName
	
	SetVariable GraphWindowName,pos={280,115},size={310,20}, proc=IR3L_SetVarProc,title="\Zr120Graph Window name: ", noedit=1, valueColor=(65535,0,0)
	Setvariable GraphWindowName,fStyle=2, variable=root:Packages:Irena:MultiSaPlotFit:GraphWindowName, disable=0, frame=0, help={"This is Igro internal name for graph currently selected for controls"}

	SetVariable GraphUserTitle,pos={280,140},size={310,20}, proc=IR3L_SetVarProc,title="\Zr120Graph title: "
	Setvariable GraphUserTitle,fStyle=2, variable=root:Packages:Irena:MultiSaPlotFit:GraphUserTitle, help={"This is huma name for graph currently controlled by teh tool. You can change it."}

	//Plotting controls...
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={260,165},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	
	Button NewGraphPlotData,pos={270,170},size={120,20}, proc=IR3L_ButtonProc,title="New graph", help={"Plot selected data in new graph"}
	Button AppendPlotData,pos={410,170},size={180,20}, proc=IR3L_ButtonProc,title="Append to selected graph", help={"Append selected data to graph selected above"}
	Button ApplyPresetFormating,pos={420,195},size={160,20}, proc=IR3L_ButtonProc,title="Apply All Formating", help={"Apply Preset Formating to update graph based on these choices"}
	Button ExportGraphJPG,pos={420,220},size={70,20}, proc=IR3L_ButtonProc,title="Export jpg", help={"Export as jpg file"}
	Button ExportGraphTIF,pos={505,220},size={70,20}, proc=IR3L_ButtonProc,title="Export tiff", help={"Export as tiff file"}



	TitleBox GraphAxesControls title="\Zr100Graph Axes Options",fixedSize=1,size={150,20},pos={350,260},frame=0,fstyle=1, fixedSize=1

	TitleBox XAxisLegendTB title="\Zr100X Axis Legend",fixedSize=1,size={150,20},pos={280,280},frame=0,fstyle=1, fixedSize=1
	TitleBox YAxisLegendTB title="\Zr100Y Axis Legend",fixedSize=1,size={150,20},pos={450,280},frame=0,fstyle=1, fixedSize=1

	SetVariable XAxisLegend,pos={260,300},size={160,15}, proc=IR3L_SetVarProc,title=" "
	Setvariable XAxisLegend,fSize=10,fStyle=2, variable=root:Packages:Irena:MultiSaPlotFit:XAxisLegend, help={"Legend for X axis, you can change it. "}
	SetVariable YAxislegend,pos={430,300},size={160,15}, proc=IR3L_SetVarProc,title=" "
	Setvariable YAxislegend,fSize=10,fStyle=2, variable=root:Packages:Irena:MultiSaPlotFit:YAxislegend, help={"legend for Y axis. You can change it. "}
	
	Checkbox LogXAxis, pos={280,320},size={76,14},title="LogXAxis?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSaPlotFit:LogXAxis, help={"Use log X axis. You can change it. "}
	Checkbox LogYAxis, pos={450,320},size={76,14},title="LogYAxis?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSaPlotFit:LogYAxis, help={"Use log X axis. You can change it. "}

	SetVariable XOffset,pos={260,340},size={130,15}, proc=IR3L_SetVarProc,title="X offset :     ", limits={0,inf,1}
	Setvariable XOffset,fSize=10,fStyle=2, variable=root:Packages:Irena:MultiSaPlotFit:XOffset, help={"X Offxet for X axis, you can change it. "}
	SetVariable YOffset,pos={430,340},size={130,15}, proc=IR3L_SetVarProc,title="Y offset :     ",limits={0,inf,1}
	Setvariable YOffset,fSize=10,fStyle=2, variable=root:Packages:Irena:MultiSaPlotFit:YOffset, help={"Y Offset for Y axis. You can change it. "}


	TitleBox GraphTraceControls title="\Zr100Graph Trace Options",fixedSize=1,size={150,20},pos={350,420},frame=0,fstyle=1, fixedSize=1

	Checkbox Colorize, pos={280,440},size={76,14},title="Vary colors?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSaPlotFit:Colorize, help={"Colorize the data? Oposite is B/W"}
	Checkbox UseSymbols, pos={280,480},size={76,14},title="Use Symbols?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSaPlotFit:UseSymbols, help={"Use Symbols for data. "}
	Checkbox UseLines, pos={280,500},size={76,14},title="Use Lines?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSaPlotFit:UseLines, help={"Use Lines for data"}

	NVAR SymbolSize=root:Packages:Irena:MultiSaPlotFit:SymbolSize
	PopupMenu SymbolSize,pos={430,480},size={310,20},proc=IR3L_PopMenuProc, title="Symbol Size : ",help={"Symbol Size"}
	PopupMenu SymbolSize,value="0;1;2;3;5;7;10;",mode=1, popvalue=num2str(SymbolSize)
	SetVariable LineThickness,pos={430,500},size={160,15}, proc=IR3L_SetVarProc,title="Line Thickness",limits={0.5,10,0.5}
	Setvariable LineThickness,fSize=10,fStyle=2, variable=root:Packages:Irena:MultiSaPlotFit:LineThickness, help={"Line Thickness. You can change it. "}


	TitleBox GraphOtherControls title="\Zr100Graph Other Options",fixedSize=1,size={150,20},pos={350,560},frame=0,fstyle=1, fixedSize=1

	Checkbox AddLegend, pos={280,580},size={76,14},title="Add Legend?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSaPlotFit:AddLegend, help={"Add legend to data."}
	Checkbox UseOnlyFoldersInLegend, pos={280,600},size={76,14},title="Only Folders?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSaPlotFit:UseOnlyFoldersInLegend, help={"Only Folders in Legend?"}
	NVAR LegendSize=root:Packages:Irena:MultiSaPlotFit:LegendSize
	PopupMenu LegendSize,pos={430,580},size={310,20},proc=IR3L_PopMenuProc, title="Legend Size : ",help={"legend Size"}
	PopupMenu LegendSize,value="8;10;12;14;16;20;24;",mode=1, popvalue=num2str(LegendSize)

	PopupMenu ApplyStyle,pos={260,700},size={400,20},proc=IR3L_PopMenuProc, title="Apply style : ",help={"Set tool setting to defined conditions and apply to graph"}
	PopupMenu ApplyStyle,value=#"root:Packages:Irena:MultiSaPlotFit:ListOfDefinedStyles",mode=1, mode=1



	TitleBox Instructions1 title="\Zr100Double click to add data to graph",size={330,15},pos={4,680},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions2 title="\Zr100Shift-click to select range of data",size={330,15},pos={4,695},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions3 title="\Zr100Ctrl/Cmd-click to select one data set",size={330,15},pos={4,710},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions4 title="\Zr100Regex for not contain: ^((?!string).)*$",size={330,15},pos={4,725},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions5 title="\Zr100Regex for contain:  string, two: str2.*str1",size={330,15},pos={4,740},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions6 title="\Zr100Regex for case independent:  (?i)string",size={330,15},pos={4,755},frame=0,fColor=(0,0,65535),labelBack=0

	//IR3L_FixPanelControls()
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function/S IR3L_GraphListPopupString()
	// Create some waves for demo purposes
	string list = WinList("MultiDataPlot_*", ";", "WIN:1" )
	list = SortList(list)
	//now, append names to them
	variable i
	string LongList=""
	if(strlen(WinList("*", ";", "WIN:1" ))>2)
		GetWindow $(stringFromList(0,WinList("*", ";", "WIN:1" ))) wtitle 
		LongList+="Top Graph"+"="+S_value+";"		
	else
		LongList+="---;"
	endif
	for(i=0;i<ItemsInList(list);i+=1)
		GetWindow $(StringFromList(i, list)) wtitle 
		LongList+=StringFromList(i, list)+"="+S_value+";"
	endfor	
	return LongList
End


//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3L_InitMultiSaPlotFit()	


	string oldDf=GetDataFolder(1)
	string ListOfVariables
	string ListOfStrings
	variable i
		
	if (!DataFolderExists("root:Packages:Irena:MultiSaPlotFit"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena
		NewDataFolder/O root:Packages:Irena:MultiSaPlotFit
	endif
	SetDataFolder root:Packages:Irena:MultiSaPlotFit					//go into the folder

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;DataUnits;"
	ListOfStrings+="DataStartFolder;DataMatchString;FolderSortString;FolderSortStringAll;"
	ListOfStrings+="UserMessageString;SavedDataMessage;"
	ListOfStrings+="SelectedResultsTool;SelectedResultsType;ResultsGenerationToUse;"
	ListOfStrings+="DataSubTypeUSAXSList;DataSubTypeResultsList;DataSubType;"
	ListOfStrings+="GraphUserTitle;GraphWindowName;XAxisLegend;YAxislegend;"
	ListOfStrings+="QvecLookupUSAXS;ErrorLookupUSAXS;dQLookupUSAXS;"
	ListOfStrings+="ListOfDefinedStyles;"

	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;"
	ListOfVariables+="InvertGrepSearch;"
	ListOfVariables+="LogXAxis;LogYAxis;MajorGridXaxis;MajorGridYaxis;MinorGridXaxis;MinorGridYaxis;"
	ListOfVariables+="Colorize;UseSymbols;UseLines;SymbolSize;LineThickness;"
	ListOfVariables+="XOffset;YOffset;"
	ListOfVariables+="AddLegend;UseOnlyFoldersInLegend;LegendSize;"
	
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
	FolderSortStringAll = "Alphabetical;Reverse Alphabetical;_xyz;_xyz.ext;Reverse _xyz;Reverse _xyz.ext;Sxyz_;Reverse Sxyz_;_xyzmin;_xyzC;_xyzpct;_xyz_000;Reverse _xyz_000;"
	SVAR DataSubTypeUSAXSList
	DataSubTypeUSAXSList="DSM_Int;SMR_Int;R_Int;Blank_R_Int;USAXS_PD;Monitor;"
	SVAR DataSubTypeResultsList
	DataSubTypeResultsList="Size"
	SVAR DataSubType
	DataSubType="DSM_Int"
	
	SVAR ListOfDefinedStyles
	ListOfDefinedStyles = "Log-Log;Lin-Log;VolumeSizeDistribution;NumberSizeDistribution;"

	SVAR QvecLookupUSAXS
	QvecLookupUSAXS="R_Int=R_Qvec;Blank_R_Int=Blank_R_Qvec;SMR_Int=SMR_Qvec;DSM_Int=DSM_Qvec;USAXS_PD=Ar_encoder;Monitor=Ar_encoder;"
	SVAR ErrorLookupUSAXS
	ErrorLookupUSAXS="R_Int=R_Error;Blank_R_Int=Blank_R_error;SMR_Int=SMR_Error;DSM_Int=DSM_error;"
	SVAR dQLookupUSAXS
	dQLookupUSAXS="SMR_Int=SMR_dQ;DSM_Int=DSM_dQ;"
	
	SVAR GraphUserTitle
	SVAR GraphWindowName
	GraphUserTitle=""
	GraphWindowName=stringFromList(0,WinList("MultiDataPlot_*", ";", "WIN:1" ))
	if(strlen(GraphWindowName)<2)
		GraphWindowName="---"
	endif
	SVAR SelectedResultsTool 
	SVAR SelectedResultsType 
	SVAR ResultsGenerationToUse
	if(strlen(SelectedResultsTool)<1)
		SelectedResultsTool="Unified Fit"
	endif
	if(strlen(SelectedResultsTool)<1)
		SelectedResultsTool=IR2C_ReturnKnownToolResults(SelectedResultsTool)
	endif
	if(strlen(ResultsGenerationToUse)<1)
		ResultsGenerationToUse="Latest"
	endif
	
	NVAR LegendSize
	if(LegendSize<8)
		LegendSize=12
	endif
	NVAR UseSymbols
	NVAR UseLines
	NVAR Colorize
	NVAR SymbolSize
	NVAR LineThickness
	NVAR AddLegend
	NVAR UseOnlyFoldersInLegend
	NVAR LegendSize
	if(UseSymbols+UseLines < 1)			//seems to start new tool
		UseLines = 1
		Colorize = 1
		SymbolSize = 2
		LineThickness = 2
		AddLegend = 1
		UseOnlyFoldersInLegend = 1
		LegendSize = 12
	endif
	
	Make/O/T/N=(0) ListOfAvailableData
	Make/O/N=(0) SelectionOfAvailableData
	SetDataFolder oldDf

end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3L_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR UseIndra2Data =  root:Packages:Irena:MultiSaPlotFit:UseIndra2Data
			NVAR UseQRSData =  root:Packages:Irena:MultiSaPlotFit:UseQRSData
			NVAR UseResults =  root:Packages:Irena:MultiSaPlotFit:UseResults
			SVAR DataStartFolder = root:Packages:Irena:MultiSaPlotFit:DataStartFolder
			SVAR GraphWindowName = root:Packages:Irena:MultiSaPlotFit:GraphWindowName
		  	NVAR UseLines = root:Packages:Irena:MultiSaPlotFit:UseLines
		  	NVAR UseSymbols = root:Packages:Irena:MultiSaPlotFit:UseSymbols
		  	NVAR SymbolSize = root:Packages:Irena:MultiSaPlotFit:SymbolSize
		  	NVAR LineThickness= root:Packages:Irena:MultiSaPlotFit:LineThickness
		  	NVAR LegendSize = root:Packages:Irena:MultiSaPlotFit:LegendSize
		  	NVAR UseOnlyFoldersInLegend = root:Packages:Irena:MultiSaPlotFit:UseOnlyFoldersInLegend
		  	NVAR AddLegend= root:Packages:Irena:MultiSaPlotFit:AddLegend
//		  	if(stringmatch(cba.ctrlName,"InvertGrepSearch"))
//					IR3L_UpdateListOfAvailFiles()	
//		  	endif
//		  	if(stringmatch(cba.ctrlName,"UseIndra2Data"))
//		  		if(checked)
//		  			UseQRSData = 0
//		  			UseResults = 0
//		  			IR3L_FixPanelControls()
//					IR3L_UpdateListOfAvailFiles()
//		  		endif
//		  	endif
//		  	if(stringmatch(cba.ctrlName,"UseResults"))
//		  		if(checked)
//		  			UseQRSData = 0
//		  			UseIndra2Data = 0
//		  			IR3L_FixPanelControls()
//					IR3L_UpdateListOfAvailFiles()
//		  		endif
//		  	endif
//		  	if(stringmatch(cba.ctrlName,"UseQRSData"))
//		  		if(checked)
//		  			UseIndra2Data = 0
//		  			UseResults = 0
//		  			IR3L_FixPanelControls()
//					IR3L_UpdateListOfAvailFiles()
//		  		endif
//		  	endif
//		  	if(stringmatch(cba.ctrlName,"UseQRSData")||stringmatch(cba.ctrlName,"UseIndra2Data"))
//		  		DataStartFolder = "root:"
//		  		PopupMenu StartFolderSelection,win=IR3L_MultiSaPlotFitPanel, mode=1,popvalue="root:"
//				IR3L_UpdateListOfAvailFiles()
//		  	endif
		  	if(stringmatch(cba.ctrlName,"LogXAxis"))
		  		if(checked)
		  			ModifyGraph/W=$(GraphWindowName) log(bottom)=1
		  		else
		  			ModifyGraph/W=$(GraphWindowName) log(bottom)=0
		  		endif
		  	endif
		  	if(stringmatch(cba.ctrlName,"LogYAxis"))
		  		if(checked)
		  			ModifyGraph/W=$(GraphWindowName) log(left)=1
		  		else
		  			ModifyGraph/W=$(GraphWindowName) log(left)=0
		  		endif
		  	endif
		  	if(stringmatch(cba.ctrlName,"Colorize"))
 	 			DoWIndow/F $(GraphWindowName)
		  		if(checked)
		  			IN2G_ColorTopGrphRainbow()
		  		else
      			ModifyGraph/W=$(GraphWindowName) rgb=(0,0,0)
		  		endif
				DoWIndow/F IR3L_MultiSaPlotFitPanel
		  	endif
		  	if(stringmatch(cba.ctrlName,"UseSymbols"))
 	 			DoWIndow/F $(GraphWindowName)
		  		if(UseLines+UseSymbols<1)
		  			UseSymbols = checked
		  			UseLines = !checked
		  		endif
		  		if(checked)
					ModifyGraph mode=3*UseSymbols+UseLines 	
					IN2G_VaryMarkersTopGrphRainbow(1, SymbolSize, 0)
		  		else
					ModifyGraph mode=!(UseLines) 	
		  		endif
				DoWIndow/F IR3L_MultiSaPlotFitPanel
		  	endif
		  	if(stringmatch(cba.ctrlName,"UseLines"))
 	 			DoWIndow/F $(GraphWindowName)
		  		if(UseLines+UseSymbols<1)
		  			UseSymbols = !checked
		  			UseLines = checked
		  		endif
		  		if(LineThickness<0.5)
		  			LineThickness = 0.5
		  		endif
		  		if(checked)
					ModifyGraph mode=UseSymbols*3 + UseLines
		  			IN2G_VaryLinesTopGrphRainbow(LineThickness, 1)
		  		else
					ModifyGraph mode=UseSymbols*3 	
		  		endif
				DoWIndow/F IR3L_MultiSaPlotFitPanel
		  	endif
		  	
		  	if(stringmatch(cba.ctrlName,"AddLegend") || stringmatch(cba.ctrlName,"UseOnlyFoldersInLegend"))
 	 			DoWIndow/F $(GraphWindowName)
		  		if(AddLegend)
		  			IN2G_LegendTopGrphFldr(LegendSize, 20, 1, !(UseOnlyFoldersInLegend))
		  		else
					Legend/K/N=text0/W=$(GraphWindowName)
		  		endif
				DoWIndow/F IR3L_MultiSaPlotFitPanel
		  	endif
  		
  	
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
//**************************************************************************************

Function IR3L_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	String ctrlName=Pa.ctrlName
	Variable popNum=Pa.popNum
	String popStr=Pa.popStr
	
	if(Pa.eventcode!=2)
		return 0
	endif
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR GraphWindowName = root:Packages:Irena:MultiSaPlotFit:GraphWindowName
	if(strlen(GraphWindowName)>0)
		if(stringmatch(ctrlName,"SelectGraphWindows"))
			//do something here
			SVAR GraphWindowName=root:Packages:Irena:MultiSaPlotFit:GraphWindowName
			SVAR GraphUserTitle=root:Packages:Irena:MultiSaPlotFit:GraphUserTitle
			if(stringmatch(popStr,"---"))
				GraphWindowName = ""
				GraphUserTitle=""
				return 0
			endif
			string StartPopStr=stringFromList(0,popStr,"=")
			if(StringMatch(StartPopStr, "Top Graph"))
				GetWindow $(stringFromList(0,WinList("*", ";", "WIN:1" ))) title 
				GraphUserTitle = S_value
				GraphWindowName = stringFromList(0,WinList("*", ";", "WIN:1" ))
			else
				GetWindow $(StartPopStr) title 
				GraphUserTitle = S_value
				GraphWindowName = StartPopStr		
			endif
			DoWIndow/F $(GraphWindowName)
		endif
	
		if(stringmatch(ctrlName,"SymbolSize"))
			//do something here
			NVAR UseSymbols = root:Packages:Irena:MultiSaPlotFit:UseSymbols
			NVAR SymbolSize = root:Packages:Irena:MultiSaPlotFit:SymbolSize
			NVAR UseLines = root:Packages:Irena:MultiSaPlotFit:UseLines
			SymbolSize = str2num(popStr)
	  		if(UseLines+UseSymbols<1)
	  			UseSymbols = 1
	  		endif
			DoWIndow/F $(GraphWindowName)
			if(UseSymbols)
				ModifyGraph mode=3*UseSymbols+UseLines 	
				IN2G_VaryMarkersTopGrphRainbow(1, SymbolSize, 0)
			else
				ModifyGraph mode=!(UseLines) 	
			endif
	
		endif
	
		if(stringmatch(ctrlName,"LegendSize"))
			//do something here
			NVAR LegendSize = root:Packages:Irena:MultiSaPlotFit:LegendSize
			NVAR AddLegend = root:Packages:Irena:MultiSaPlotFit:AddLegend
			NVAR UseOnlyFoldersInLegend = root:Packages:Irena:MultiSaPlotFit:UseOnlyFoldersInLegend
			LegendSize = str2num(popStr)
			if(AddLegend)
		 			IN2G_LegendTopGrphFldr(LegendSize, 20, 1, !(UseOnlyFoldersInLegend))
			endif
		endif
		if(stringmatch(ctrlName,"ApplyStyle"))
			//do something here
			IR3L_SetAndApplyStyle(popStr)	
		endif
				
	endif
	DOWIndow/F IR3L_MultiSaPlotFitPanel
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3L_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	variable tempP
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
				//			if(stringmatch(sva.ctrlName,"FolderNameMatchString"))
				//				IR3L_UpdateListOfAvailFiles()
				//			endif
		SVAR GraphUserTitle=root:Packages:Irena:MultiSaPlotFit:GraphUserTitle
		SVAR GraphWindowName = root:Packages:Irena:MultiSaPlotFit:GraphWindowName
			if(strlen(GraphWindowName)>0)
				if(stringmatch(sva.ctrlName,"GraphUserTitle"))
					DoWindow/T $(GraphWindowName),(GraphUserTitle)
				endif
				
				if(stringmatch(sva.ctrlName,"LineThickness"))
					NVAR LineThickness = root:Packages:Irena:MultiSaPlotFit:LineThickness
					if(LineThickness<0.5)
						LineThickness = 0.5
					endif
					DoWindow/F $(GraphWindowName)
		  			IN2G_VaryLinesTopGrphRainbow(LineThickness, 1)
				endif
				
				if(stringmatch(sva.ctrlName,"XOffset") || stringmatch(sva.ctrlName,"YOffset"))
					NVAR XOffset=root:Packages:Irena:MultiSaPlotFit:XOffset
					NVAR YOffset=root:Packages:Irena:MultiSaPlotFit:YOffset
					NVAR LogXAxis=root:Packages:Irena:MultiSaPlotFit:LogXAxis
					NVAR LogYAxis=root:Packages:Irena:MultiSaPlotFit:LogYAxis
					DoWindow/F $(GraphWindowName)
					IN2G_OffsetTopGrphTraces(LogXAxis, XOffset ,LogYAxis, YOffset)
				endif
	
				break
			endif
		case 3: // live update
			break
		case -1: // control being killed
			break
	endswitch
	DoWIndow/F IR3L_MultiSaPlotFitPanel
	return 0
End


//**************************************************************************************
//**************************************************************************************
Function IR3L_DoubleClickAction(FoldernameStr)
			string FoldernameStr
			//if called with GraphWindowName = "---" need to create new graph and direct data there, or the tool doe snothing
			SVAR GraphWindowName=root:Packages:Irena:MultiSaPlotFit:GraphWindowName
			string LocalGraphName
			variable CreatedNewGraph=0
			if(strlen(GraphWindowName)<2 || StringMatch(GraphWindowName, "---" ))
				LocalGraphName="none"
			else
				LocalGraphName = GraphWindowName
			endif
			DOWIndow $(LocalGraphName)
			if(V_Flag<1)			//widnow does not exist, need new window to use... 
				//set some meaningful values for these data first
				IR3L_SetPlotLegends()								
				//Create new graph and append data to graph
				IR3L_CreateNewGraph()		
				CreatedNewGraph = 1
			endif		
			IR3L_AppendData(FoldernameStr)
			if(CreatedNewGraph)
				IR3L_ApplyPresetFormating(GraphWindowName)
			endif

end


//**************************************************************************************
//**************************************************************************************
Function IR3L_AppendData(FolderNameStr)
	string FolderNameStr
	
	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena:MultiSaPlotFit					//go into the folder
	//IR3D_SetSavedNotSavedMessage(0)

		SVAR DataStartFolder=root:Packages:Irena:MultiSaPlotFit:DataStartFolder
		SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
		SVAR IntensityWaveName=root:Packages:Irena:MultiSaPlotFit:IntensityWaveName
		SVAR QWavename=root:Packages:Irena:MultiSaPlotFit:QWavename
		SVAR ErrorWaveName=root:Packages:Irena:MultiSaPlotFit:ErrorWaveName
		SVAR dQWavename=root:Packages:Irena:MultiSaPlotFit:dQWavename
		NVAR UseIndra2Data=root:Packages:Irena:MultiSaPlotFit:UseIndra2Data
		NVAR UseQRSdata=root:Packages:Irena:MultiSaPlotFit:UseQRSdata
		NVAR useResults=root:Packages:Irena:MultiSaPlotFit:useResults
		SVAR DataSubType = root:Packages:Irena:MultiSaPlotFit:DataSubType
		//these are variables used by the control procedure
		NVAR  UseUserDefinedData=  root:Packages:Irena:MultiSaPlotFit:UseUserDefinedData
		NVAR  UseModelData = root:Packages:Irena:MultiSaPlotFit:UseModelData
		SVAR DataFolderName  = root:Packages:Irena:MultiSaPlotFit:DataFolderName 
		SVAR IntensityWaveName = root:Packages:Irena:MultiSaPlotFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena:MultiSaPlotFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena:MultiSaPlotFit:ErrorWaveName
		//graph control variable
		SVAR GraphUserTitle=root:Packages:Irena:MultiSaPlotFit:GraphUserTitle
		SVAR GraphWindowName=root:Packages:Irena:MultiSaPlotFit:GraphWindowName
		SVAR ResultsDataTypesLookup=root:Packages:IrenaControlProcs:ResultsDataTypesLookup
		
		if(UseQRSdata+UseIndra2Data+useResults!= 1)
			Abort "Data type not selected right, please, select type of data first" 
		endif
		
		string TempStr, result, tempStr2, TempYName, TempXName, tempStr3
		variable i, j
		
		UseUserDefinedData = 0
		UseModelData = 0
		DataFolderName = DataStartFolder+FolderNameStr
		if(UseQRSdata)
			//get the names of waves, assume this tool actually works. May not under some conditions. In that case this tool will not work. 
			QWavename = stringFromList(0,IR2P_ListOfWaves("Xaxis","", "IR3L_MultiSaPlotFitPanel"))
			IntensityWaveName = stringFromList(0,IR2P_ListOfWaves("Yaxis","*", "IR3L_MultiSaPlotFitPanel"))
			ErrorWaveName = stringFromList(0,IR2P_ListOfWaves("Error","*", "IR3L_MultiSaPlotFitPanel"))
			if(UseIndra2Data)
				dQWavename = ReplaceString("Qvec", QWavename, "dQ")
			elseif(UseQRSdata)
				dQWavename = "w"+QWavename[1,31]
			else
				dQWavename = ""
			endif
		elseif(UseIndra2Data)
			string DataSubTypeInt = DataSubType
			SVAR QvecLookup = root:Packages:Irena:MultiSaPlotFit:QvecLookupUSAXS
			SVAR ErrorLookup = root:Packages:Irena:MultiSaPlotFit:ErrorLookupUSAXS
			SVAR dQLookup = root:Packages:Irena:MultiSaPlotFit:dQLookupUSAXS
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
			SVAR SelectedResultsTool = root:Packages:Irena:MultiSaPlotFit:SelectedResultsTool
			SVAR SelectedResultsType = root:Packages:Irena:MultiSaPlotFit:SelectedResultsType
			SVAR ResultsGenerationToUse = root:Packages:Irena:MultiSaPlotFit:ResultsGenerationToUse
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
					//for some (Modeling II there are two x-wave options, need to figure out which one is present...
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
			ABort "Data type not known, error in IR3L_AppendData"
		endif
		Wave/Z SourceIntWv=$(DataFolderName+IntensityWaveName)
		Wave/Z SourceQWv=$(DataFolderName+QWavename)
		Wave/Z SourceErrorWv=$(DataFolderName+ErrorWaveName)
		Wave/Z SourcedQWv=$(DataFolderName+dQWavename)
		if(!WaveExists(SourceIntWv)||	!WaveExists(SourceQWv))
			print "Data selection failed for "+DataFolderName
			return 0
		endif
		//create graph if needed. 
		if(StringMatch(GraphWindowName, "---" ))
				IR3L_CreateNewGraph()											
		endif
		DoWIndow  $(GraphWindowName)
		if(V_Flag==0)
			print "Graph does not exist, nothing to append"
		endif
		CheckDisplayed /W=$(GraphWindowName) SourceIntWv
		if(V_Flag==0)
			AppendToGraph /W=$(GraphWindowName) SourceIntWv vs  SourceQWv
			print "Appended : "+DataFolderName+IntensityWaveName +" top the graph : "+GraphWindowName
		else
			print "Could not append "+DataFolderName+IntensityWaveName+" to the graph : "+GraphWindowName+" this wave is already displayed in thE graph" 
		endif
		//append data to graph
	SetDataFolder oldDf
	return 1
end
//**********************************************************************************************************
//**********************************************************************************************************
////**********************************************************************************************************
//**********************************************************************************************************
Function IR3L_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	variable i
	string FoldernameStr
	SVAR GraphUserTitle=root:Packages:Irena:MultiSaPlotFit:GraphUserTitle
	SVAR GraphWindowName=root:Packages:Irena:MultiSaPlotFit:GraphWindowName
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlname,"NewGraphPlotData"))
				//set some meaningful values for these data first
				IR3L_SetPlotLegends()								
				//Create new graph and append data to graph
				//use $(GraphWindowName) for now... To be changed. 
				//KillWindow/Z $(GraphWindowName)
				IR3L_CreateNewGraph()
				//now, append the data to it... 
				Wave/T ListOfAvailableData = root:Packages:Irena:MultiSaPlotFit:ListOfAvailableData
				Wave SelectionOfAvailableData = root:Packages:Irena:MultiSaPlotFit:SelectionOfAvailableData	
				for(i=0;i<numpnts(ListOfAvailableData);i+=1)
					if(SelectionOfAvailableData[i]>0.5)
						IR3L_AppendData(ListOfAvailableData[i])
					endif
				endfor
				DoUpdate 
				IR3L_ApplyPresetFormating(GraphWindowName)
			endif


			if(stringmatch(ba.ctrlname,"AppendPlotData"))
				//append data to graph
				DoWIndow $(GraphWindowName)
				if(V_Flag==0)
					//IR3L_CreateNewGraph()
					print "could not find graph we can control"
				endif
				Wave/T ListOfAvailableData = root:Packages:Irena:MultiSaPlotFit:ListOfAvailableData
				Wave SelectionOfAvailableData = root:Packages:Irena:MultiSaPlotFit:SelectionOfAvailableData	
				for(i=0;i<numpnts(ListOfAvailableData);i+=1)	// Initialize variables;continue test
					if(SelectionOfAvailableData[i]>0.5)
						IR3L_AppendData(ListOfAvailableData[i])
					endif
				endfor						// Execute body code until continue test is FALSE
			endif

			if(stringmatch(ba.ctrlname,"ApplyPresetFormating"))
				//append data to graph
				DoWIndow $(GraphWindowName)
				if(V_Flag)
					IR3L_ApplyPresetFormating(GraphWindowName)
				endif
			endif
			if(cmpstr(ba.ctrlname,"GetHelp")==0)
				//Open www manual with the right page
				IN2G_OpenWebManual("Irena/Plotting.html")
			endif
			if(cmpstr(ba.ctrlname,"ExportGraphJPG")==0)
				DoWindow/F $(GraphWindowName)
				SavePICT/E=-6/B=288	as (GraphUserTitle)				//this is jpg
				DoWIndow/F IR3L_MultiSaPlotFitPanel
			endif
			if(cmpstr(ba.ctrlname,"ExportGraphTif")==0)
				DoWindow/F $(GraphWindowName)
				SavePICT/E=-7/B=288	as (GraphUserTitle)					//this is TIFF
				DoWIndow/F IR3L_MultiSaPlotFitPanel
			endif


			break
		case -1: // control being killed
			break
	endswitch
	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3L_CreateNewGraph()

		SVAR GraphWindowName=root:Packages:Irena:MultiSaPlotFit:GraphWindowName
		SVAR GraphUserTitle=root:Packages:Irena:MultiSaPlotFit:GraphUserTitle
		//first create a new GraphWindowName, this is new graph...
		string basename="MultiDataPlot_"
		GraphWindowName = UniqueName(basename, 6, 0)
	 	Display /K=1/W=(1297,231,2097,841) as GraphUserTitle
	 	DoWindow/C $(GraphWindowName)
	 	AutoPositionWindow /M=0 /R=IR3L_MultiSaPlotFitPanel $(GraphWindowName)
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3L_SetAndApplyStyle(WHichStyle)	
	string WHichStyle
	
//	ListOfDefinedStyles = "Log-Log;Lin-Log;VolumeSizeDistribution;NumberSizeDistribution;"
		SVAR GraphWindowName=root:Packages:Irena:MultiSaPlotFit:GraphWindowName
		NVAR LogXAxis=root:Packages:Irena:MultiSaPlotFit:LogXAxis
		NVAR LogYAxis=root:Packages:Irena:MultiSaPlotFit:LogYAxis
		NVAR Colorize=root:Packages:Irena:MultiSaPlotFit:Colorize
		NVAR AddLegend=root:Packages:Irena:MultiSaPlotFit:AddLegend
		SVAR XAxisLegend=root:Packages:Irena:MultiSaPlotFit:XAxisLegend
		SVAR YAxislegend=root:Packages:Irena:MultiSaPlotFit:YAxislegend	
		SVAR GraphUserTitle=root:Packages:Irena:MultiSaPlotFit:GraphUserTitle
		NVAR LineThickness = root:Packages:Irena:MultiSaPlotFit:LineThickness
		NVAR UseSymbols = root:Packages:Irena:MultiSaPlotFit:UseSymbols
		NVAR UseLines = root:Packages:Irena:MultiSaPlotFit:UseLines
		NVAR SymbolSize = root:Packages:Irena:MultiSaPlotFit:SymbolSize
		NVAR LegendSize = root:Packages:Irena:MultiSaPlotFit:LegendSize
		NVAR UseOnlyFoldersInLegend = root:Packages:Irena:MultiSaPlotFit:UseOnlyFoldersInLegend

	if(stringmatch(WHichStyle,"log-Log"))
		LogXAxis = 1
		LogYAxis = 1
		Colorize = 1
		AddLegend = 1
		LineThickness  = 2
		UseSymbols = 0
		UseLines = 1
		SymbolSize = 2
		LegendSize = 12
		UseOnlyFoldersInLegend = 1
	elseif(stringmatch(WHichStyle,"Lin-Log"))
		LogXAxis = 1
		LogYAxis = 0
		Colorize = 1
		AddLegend = 1
		LineThickness  = 2
		UseSymbols = 0
		UseLines = 1
		SymbolSize = 2
		LegendSize = 12
		UseOnlyFoldersInLegend = 1
	elseif(stringmatch(WHichStyle,"VolumeSizeDistribution"))
		LogXAxis = 1
		LogYAxis = 0
		Colorize = 1
		AddLegend = 1
		LineThickness  = 2
		UseSymbols = 0
		UseLines = 1
		SymbolSize = 2
		LegendSize = 12
		UseOnlyFoldersInLegend = 1
	elseif(stringmatch(WHichStyle,"NumberSizeDistribution"))
		LogXAxis = 1
		LogYAxis = 0
		Colorize = 1
		AddLegend = 1
		LineThickness  = 2
		UseSymbols = 0
		UseLines = 1
		SymbolSize = 2
		LegendSize = 12
		UseOnlyFoldersInLegend = 1
	endif
	IR3L_ApplyPresetFormating(GraphWindowName)	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3L_ApplyPresetFormating(GraphNameString)
		string GraphNameString

	DoWIndow $(GraphNameString)
	if(V_Flag)
		NVAR LogXAxis=root:Packages:Irena:MultiSaPlotFit:LogXAxis
		NVAR LogYAxis=root:Packages:Irena:MultiSaPlotFit:LogYAxis
		NVAR Colorize=root:Packages:Irena:MultiSaPlotFit:Colorize
		NVAR AddLegend=root:Packages:Irena:MultiSaPlotFit:AddLegend
		SVAR XAxisLegend=root:Packages:Irena:MultiSaPlotFit:XAxisLegend
		SVAR YAxislegend=root:Packages:Irena:MultiSaPlotFit:YAxislegend	
		SVAR GraphUserTitle=root:Packages:Irena:MultiSaPlotFit:GraphUserTitle
		NVAR LineThickness = root:Packages:Irena:MultiSaPlotFit:LineThickness
		NVAR UseSymbols = root:Packages:Irena:MultiSaPlotFit:UseSymbols
		NVAR UseLines = root:Packages:Irena:MultiSaPlotFit:UseLines
		NVAR SymbolSize = root:Packages:Irena:MultiSaPlotFit:SymbolSize
		NVAR LegendSize = root:Packages:Irena:MultiSaPlotFit:LegendSize
		NVAR UseOnlyFoldersInLegend = root:Packages:Irena:MultiSaPlotFit:UseOnlyFoldersInLegend
		
		ModifyGraph mirror=1
		DoWIndow/F $(GraphNameString)
  		if(LogXAxis)
  			ModifyGraph/W= $(GraphNameString)/Z log(bottom)=1
  		else
  			ModifyGraph/W= $(GraphNameString)/Z log(bottom)=0
  		endif
  		if(LogYAxis)
  			ModifyGraph/W= $(GraphNameString)/Z log(left)=1
  		else
  			ModifyGraph/W= $(GraphNameString)/Z log(left)=0
  		endif
		if(strlen(GraphUserTitle)>0)
			DoWindow/T $(GraphNameString),GraphUserTitle	
		endif
		if(strlen(XAxisLegend)>0)
			Label/Z/W=$(GraphNameString) bottom XAxisLegend
		endif
		if(strlen(YAxisLegend)>0)
			Label/Z/W=$(GraphNameString) left YAxisLegend
		endif
			
  		if(Colorize)
  			DoWIndow/F  $(GraphNameString)
  			IN2G_ColorTopGrphRainbow()
  		else
			ModifyGraph/Z/W=$(GraphNameString) rgb=(0,0,0)
  		endif
 		if(AddLegend)
  			IN2G_LegendTopGrphFldr(LegendSize, 20, 1, !(UseOnlyFoldersInLegend))
  		else
			Legend/K/N=text0/W= $(GraphNameString)
  		endif
	  	if(UseLines)
	  		if(UseLines+UseSymbols<1)
	  			UseSymbols = !UseLines
	  		endif
			if(LineThickness<0.5)
				LineThickness = 0.5
			endif
			ModifyGraph/Z/W=$(GraphNameString) mode=UseSymbols*3 + UseLines
  			IN2G_VaryLinesTopGrphRainbow(LineThickness, 1)
  		else
			ModifyGraph/Z/W=$(GraphNameString) mode=UseSymbols*3 	
	  	endif
	  	if(UseSymbols)
	  		if(UseLines+UseSymbols<1)
	  			UseLines = !UseSymbols
	  		endif
			ModifyGraph/Z/W=$(GraphNameString) mode=3*UseSymbols+UseLines 	
			IN2G_VaryMarkersTopGrphRainbow(1, SymbolSize, 0)
  		else
			ModifyGraph/Z/W=$(GraphNameString) mode=!(UseLines) 	
	  	endif
		NVAR XOffset=root:Packages:Irena:MultiSaPlotFit:XOffset
		NVAR YOffset=root:Packages:Irena:MultiSaPlotFit:YOffset
		NVAR LogXAxis=root:Packages:Irena:MultiSaPlotFit:LogXAxis
		NVAR LogYAxis=root:Packages:Irena:MultiSaPlotFit:LogYAxis
		IN2G_OffsetTopGrphTraces(LogXAxis, XOffset ,LogYAxis, YOffset)


		TextBox/W=$(GraphNameString)/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()		
	
		DoWIndow/F IR3L_MultiSaPlotFitPanel

	endif
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3L_SetPlotLegends()				//this function will set axis legends and otehr stuff based on waves
		//applies only when creating new graph...

		NVAR UseIndra2Data=root:Packages:Irena:MultiSaPlotFit:UseIndra2Data
		NVAR UseQRSdata=root:Packages:Irena:MultiSaPlotFit:UseQRSdata
		NVAR  UseResults=  root:Packages:Irena:MultiSaPlotFit:UseResults
		NVAR  UseUserDefinedData=  root:Packages:Irena:MultiSaPlotFit:UseUserDefinedData
		NVAR  UseModelData = root:Packages:Irena:MultiSaPlotFit:UseModelData
		
		SVAR XAxisLegend=root:Packages:Irena:MultiSaPlotFit:XAxisLegend
		SVAR YAxislegend=root:Packages:Irena:MultiSaPlotFit:YAxislegend	
		SVAR GraphUserTitle=root:Packages:Irena:MultiSaPlotFit:GraphUserTitle
		SVAR GraphWindowName=root:Packages:Irena:MultiSaPlotFit:GraphWindowName
		SVAR DataFolderName  = root:Packages:Irena:MultiSaPlotFit:DataFolderName 
		SVAR IntensityWaveName = root:Packages:Irena:MultiSaPlotFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena:MultiSaPlotFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena:MultiSaPlotFit:ErrorWaveName
		SVAR DataSubType = root:Packages:Irena:MultiSaPlotFit:DataSubType
		SVAR SelectedResultsTool = root:Packages:Irena:MultiSaPlotFit:SelectedResultsTool
		SVAR SelectedResultsType = root:Packages:Irena:MultiSaPlotFit:SelectedResultsType
		SVAR ResultsGenerationToUse = root:Packages:Irena:MultiSaPlotFit:ResultsGenerationToUse
		
		string yAxisUnits="arbitrary"
		string xAxisUnits
		//now, what can we do about naming this for users....
		if(UseIndra2Data)
			IntensityWaveName = DataSubType
			Wave/Z SourceIntWv=$(DataFolderName+IntensityWaveName)
			if(WaveExists(SourceIntWv))
				yAxisUnits= StringByKey("Units", note(SourceIntWv),"=",";")
				//format the units...
				if(stringmatch(yAxisUnits,"cm2/g"))
					yAxisUnits = "cm\S2\Mg\S-1\M"
				elseif(stringmatch(yAxisUnits,"1/cm"))
					yAxisUnits = "cm\S2\M/cm\S3\M"
				endif
			endif
			if(StringMatch(DataSubType, "DSM_Int" ))
				GraphUserTitle = "USAXS desmeared data"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity ["+yAxisUnits+"]"
			elseif(StringMatch(DataSubType, "SMR_Int" ))
				GraphUserTitle = "USAXS slit smeared data"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity ["+yAxisUnits+"]"
			elseif(StringMatch(DataSubType, "Blank_R_int" ))
				GraphUserTitle = "USAXS Blank R Intensity"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity"
			elseif(StringMatch(DataSubType, "R_int" ))
				GraphUserTitle = "USAXS R Intensity"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity [normalized, arbitrary]"
			elseif(StringMatch(DataSubType, "USAXS_PD" ))
				GraphUserTitle = "USAXS Diode Intensity"
				XAxisLegend = "AR angle [degrees]"
				YAxislegend = "Diode Intensity [not normalized, arbitrary counts]"
			elseif(StringMatch(DataSubType, "Monitor" ))
				GraphUserTitle = "USAXS I0 Intensity"
				XAxisLegend = "AR angle [degrees]"
				YAxislegend = "I0 Intensity [not normalized, counts]"
			else
				GraphUserTitle = "USAXS data"
				XAxisLegend = ""
				YAxislegend = ""			
			endif
		elseif(UseQRSdata)
				GraphUserTitle = "SAXS/WAXS data"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity [arb]"
		elseif(UseResults)
			//	AllKnownToolsResults = "Unified Fit;Size Distribution;Modeling II;Modeling I;Small-angle diffraction;Analytical models;Fractals;PDDF;Reflectivity;Guinier-Porod;"
			if(StringMatch(SelectedResultsTool, "Unified Fit" ))
				GraphUserTitle = "Unified Fit results"
				if(StringMatch(SelectedResultsType, "*SizeDistVol*" ))
					XAxisLegend = "Size [A]"
					YAxislegend = "Volume Fraction [arbitrary]"
				elseif(StringMatch(SelectedResultsType, "*SizeDistNum*" ))
					XAxisLegend = "Size [A]"
					YAxislegend = "Number Fraction [arbitrary]"
				endif
			elseif(StringMatch(SelectedResultsTool, "Size Distribution" ))
				GraphUserTitle = "Size Distribution results"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity [arb]"
				if(StringMatch(SelectedResultsType, "SizesVolume*" ))
					XAxisLegend = "Size [A]"
					YAxislegend = "Volume Fraction [1/A]"
				elseif(StringMatch(SelectedResultsType, "SizesNumber*" ))
					XAxisLegend = "Size [A]"
					YAxislegend = "Number Fraction [1/(Acm\S3\M)]"
				endif
			elseif(StringMatch(SelectedResultsTool, "Modeling II" ))
				GraphUserTitle = "Modeling results"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity [arb]"
				if(StringMatch(SelectedResultsType, "VolumeDist*" ))
					XAxisLegend = "Size [A]"
					YAxislegend = "Volume Fraction [1/A]"
				elseif(StringMatch(SelectedResultsType, "NumberDist*" ))
					XAxisLegend = "Size [A]"
					YAxislegend = "Number Fraction [1/(Acm\S3\M)]"
				endif
			elseif(StringMatch(SelectedResultsTool, "Small-angle diffraction" ))
				GraphUserTitle = "Small-angle diffraction results"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity [arb]"
			elseif(StringMatch(SelectedResultsTool, "Analytical models" ))
				GraphUserTitle = "Analytical models results"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity [arb]"
			elseif(StringMatch(SelectedResultsTool, "Fractals" ))
				GraphUserTitle = "Fractals results"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity [arb]"
			elseif(StringMatch(SelectedResultsTool, "Reflectivity" ))
				GraphUserTitle = "Reflectivity results"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity [arb]"
			elseif(StringMatch(SelectedResultsTool, "Guinier-Porod" ))
				GraphUserTitle = "Guinier-Porod results"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity [arb]"
			endif
		else
		
		endif
		
	
end

//				GraphUserTitle = "Size Distribution results"
//				XAxisLegend = "Q [A\S-1\M]"
//				YAxislegend = "Intensity [arb]"
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
////**********************************************************************************************************
//Function IR3L_CreateLinearizedData()
//
//	string oldDf=GetDataFolder(1)
//	SetDataFolder root:Packages:Irena:MultiSaPlotFit					//go into the folder
//	Wave OriginalDataIntWave=root:Packages:Irena:MultiSaPlotFit:OriginalDataIntWave
//	Wave OriginalDataQWave=root:Packages:Irena:MultiSaPlotFit:OriginalDataQWave
//	Wave OriginalDataErrorWave=root:Packages:Irena:MultiSaPlotFit:OriginalDataErrorWave
//	SVAR SimpleModel=root:Packages:Irena:MultiSaPlotFit:SimpleModel
//	Duplicate/O OriginalDataIntWave, LinModelDataIntWave, ModelNormalizedResidual
//	Duplicate/O OriginalDataQWave, LinModelDataQWave, ModelNormResXWave
//	Duplicate/O OriginalDataErrorWave, LinModelDataEWave
//	ModelNormalizedResidual = 0
//	if(stringmatch(SimpleModel,"Guinier"))
//		LinModelDataQWave = OriginalDataQWave^2
//		ModelNormResXWave = OriginalDataQWave^2
//	endif
//	
//	
//	SetDataFolder oldDf
//end
//
////**********************************************************************************************************

//Function IR3L_AppendDataToGraphModel()
//	
//	DoWindow IR3L_MultiSaPlotFitPanel
//	if(!V_Flag)
//		return 0
//	endif
//	variable WhichLegend=0
//	variable startQp, endQp, tmpStQ
//
////	Duplicate/O OriginalDataIntWave, LinModelDataIntWave, ModelNormalizedResidual
////	Duplicate/O OriginalDataQWave, LinModelDataQWave, ModelNormResXWave
////	Duplicate/O OriginalDataErrorWave, LinModelDataEWave
//
//	Wave LinModelDataIntWave=root:Packages:Irena:MultiSaPlotFit:LinModelDataIntWave
//	Wave LinModelDataQWave=root:Packages:Irena:MultiSaPlotFit:LinModelDataQWave
//	Wave LinModelDataEWave=root:Packages:Irena:MultiSaPlotFit:LinModelDataEWave
//	CheckDisplayed /W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay LinModelDataIntWave
//	if(!V_flag)
//		AppendToGraph /W=IR3L_MultiSaPlotFitPanel#LinearizedDataDisplay  LinModelDataIntWave  vs LinModelDataQWave
//		ModifyGraph /W=IR3L_MultiSaPlotFitPanel#LinearizedDataDisplay log=1, mirror(bottom)=1
//		Label /W=IR3L_MultiSaPlotFitPanel#LinearizedDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity"
//		Label /W=IR3L_MultiSaPlotFitPanel#LinearizedDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M]"
//		ErrorBars /W=IR3L_MultiSaPlotFitPanel#LinearizedDataDisplay LinModelDataIntWave Y,wave=(LinModelDataEWave,LinModelDataEWave)		
//	endif
////	NVAR DataQEnd = root:Packages:Irena:MultiSaPlotFit:DataQEnd
////	if(DataQEnd>0)	 		//old Q max already set.
////		endQp = BinarySearch(OriginalDataQWave, DataQEnd)
////	endif
////	if(endQp<1)	//Qmax not set or not found. Set to last point-1 on that wave. 
////		DataQEnd = OriginalDataQWave[numpnts(OriginalDataQWave)-2]
////		endQp = numpnts(OriginalDataQWave)-2
////	endif
////	cursor /W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay B, OriginalDataIntWave, endQp
//	DoUpdate
//
//	Wave/Z ModelNormalizedResidual=root:Packages:Irena:MultiSaPlotFit:ModelNormalizedResidual
//	Wave/Z ModelNormResXWave=root:Packages:Irena:MultiSaPlotFit:ModelNormResXWave
//	CheckDisplayed /W=IR3L_MultiSaPlotFitPanel#ResidualDataDisplay ModelNormalizedResidual  //, ResultIntensity
//	if(!V_flag)
//		AppendToGraph /W=IR3L_MultiSaPlotFitPanel#ResidualDataDisplay  ModelNormalizedResidual  vs ModelNormResXWave
//		ModifyGraph /W=IR3L_MultiSaPlotFitPanel#LinearizedDataDisplay log=1, mirror(bottom)=1
//		Label /W=IR3L_MultiSaPlotFitPanel#LinearizedDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Normalized res."
//		Label /W=IR3L_MultiSaPlotFitPanel#LinearizedDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M]"
//	endif
//
//
//
//	string Shortname1, ShortName2
//	
//	switch(V_Flag)	// numeric switch
//		case 0:		// execute if case matches expression
//			Legend/W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay /N=text0/K
//			break						// exit from switch
////		case 1:		// execute if case matches expression
////			SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
////			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
////			Legend/W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1
////			break
////		case 2:
////			SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
////			Shortname2 = StringFromList(ItemsInList(DataFolderName2, ":")-1, DataFolderName2  ,":")
////			Legend/W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData2IntWave) " + Shortname2		
////			break
////		case 3:
////			SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
////			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
////			Legend/W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2
////			break
////		case 7:
////			SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
////			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
////			Legend/W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2+"\r\\s(ResultIntensity) Merged Data"
//			break
//	endswitch
//
//	
//end
//**********************************************************************************************************
//**********************************************************************************************************
//
//
//Function IR3L_AppendDataToGraphLogLog()
//	
//	DoWindow IR3L_MultiSaPlotFitPanel
//	if(!V_Flag)
//		return 0
//	endif
//	variable WhichLegend=0
//	variable startQp, endQp, tmpStQ
//	Wave OriginalDataIntWave=root:Packages:Irena:MultiSaPlotFit:OriginalDataIntWave
//	Wave OriginalDataQWave=root:Packages:Irena:MultiSaPlotFit:OriginalDataQWave
//	Wave OriginalDataErrorWave=root:Packages:Irena:MultiSaPlotFit:OriginalDataErrorWave
//	CheckDisplayed /W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay OriginalDataIntWave
//	if(!V_flag)
//		AppendToGraph /W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay  OriginalDataIntWave  vs OriginalDataQWave
//		ModifyGraph /W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay log=1, mirror(bottom)=1
//		Label /W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay left "Intensity 1"
//		Label /W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay bottom "Q [A\\S-1\\M]"
//		ErrorBars /W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay OriginalDataIntWave Y,wave=(OriginalDataErrorWave,OriginalDataErrorWave)		
//	endif
//	NVAR DataQEnd = root:Packages:Irena:MultiSaPlotFit:DataQEnd
//	if(DataQEnd>0)	 		//old Q max already set.
//		endQp = BinarySearch(OriginalDataQWave, DataQEnd)
//	endif
//	if(endQp<1)	//Qmax not set or not found. Set to last point-1 on that wave. 
//		DataQEnd = OriginalDataQWave[numpnts(OriginalDataQWave)-2]
//		endQp = numpnts(OriginalDataQWave)-2
//	endif
//	cursor /W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay B, OriginalDataIntWave, endQp
//	DoUpdate
//
//	Wave/Z OriginalDataIntWave=root:Packages:Irena:MultiSaPlotFit:OriginalDataIntWave
//	CheckDisplayed /W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay OriginalDataIntWave  //, ResultIntensity
//	string Shortname1, ShortName2
//	
//	switch(V_Flag)	// numeric switch
//		case 0:		// execute if case matches expression
//			Legend/W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay /N=text0/K
//			break						// exit from switch
////		case 1:		// execute if case matches expression
////			SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
////			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
////			Legend/W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1
////			break
////		case 2:
////			SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
////			Shortname2 = StringFromList(ItemsInList(DataFolderName2, ":")-1, DataFolderName2  ,":")
////			Legend/W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData2IntWave) " + Shortname2		
////			break
////		case 3:
////			SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
////			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
////			Legend/W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2
////			break
////		case 7:
////			SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
////			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
////			Legend/W=IR3L_MultiSaPlotFitPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2+"\r\\s(ResultIntensity) Merged Data"
//			break
//	endswitch
//
//	
//end
////**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************
//**************************************************************************************
//Function IR3L_UpdateListOfAvailFiles()
//
//
//	string OldDF=GetDataFolder(1)
//	setDataFolder root:Packages:Irena:MultiSaPlotFit
//	
//	NVAR UseIndra2Data=root:Packages:Irena:MultiSaPlotFit:UseIndra2Data
//	NVAR UseQRSdata=root:Packages:Irena:MultiSaPlotFit:UseQRSData
//	NVAR UseResults=root:Packages:Irena:MultiSaPlotFit:UseResults
//	SVAR StartFolderName=root:Packages:Irena:MultiSaPlotFit:DataStartFolder
//	SVAR DataMatchString= root:Packages:Irena:MultiSaPlotFit:DataMatchString
//	SVAR DataSubType = root:Packages:Irena:MultiSaPlotFit:DataSubType
//	NVAR InvertGrepSearch=root:Packages:Irena:MultiSaPlotFit:InvertGrepSearch
//	string LStartFolder, FolderContent
//	if(stringmatch(StartFolderName,"---"))
//		LStartFolder="root:"
//	else
//		LStartFolder = StartFolderName
//	endif
//	//build list of availabe folders here...
//	string CurrentFolders
//	if(UseIndra2Data && !(StringMatch(DataSubType, "DSM_Int")||StringMatch(DataSubType, "SMR_Int")))		//special folders...
//		CurrentFolders=IN2G_FindFolderWithWaveTypes(LStartFolder, 10, DataSubType, 1)							//this does not clean up by matchstring...
//		if(strlen(DataMatchString)>0)																							//match string selections
//			CurrentFolders = GrepList(CurrentFolders, DataMatchString, InvertGrepSearch) 
//		endif
//	elseif(UseIndra2Data && (StringMatch(DataSubType, "DSM_Int")||StringMatch(DataSubType, "SMR_Int")))			//DSM or SMR data wanted. 
//		//need to check if user wants DSM or SMR data. 
//		if(StringMatch(DataSubType, "DSM_Int"))
//			CurrentFolders=IR3L_GenStringOfFolders(LStartFolder,UseIndra2Data, UseQRSData,UseResults, 0,1)
//		else
//			CurrentFolders=IR3L_GenStringOfFolders(LStartFolder,UseIndra2Data, UseQRSData,UseResults, 1,1)
//		endif
//		//apply grep list. 
//		if(strlen(DataMatchString)>0)
//			CurrentFolders = GrepList(CurrentFolders, DataMatchString, InvertGrepSearch) 
//		endif
//	else
//		CurrentFolders=IR3L_GenStringOfFolders(LStartFolder,UseIndra2Data, UseQRSData,UseResults, 0,1)
//		//apply grep list. 
//		if(strlen(DataMatchString)>0)
//			CurrentFolders = GrepList(CurrentFolders, DataMatchString, InvertGrepSearch) 
//		endif
//	endif
//
//	
//
//	Wave/T ListOfAvailableData=root:Packages:Irena:MultiSaPlotFit:ListOfAvailableData
//	Wave SelectionOfAvailableData=root:Packages:Irena:MultiSaPlotFit:SelectionOfAvailableData
//	variable i, j, match
//	string TempStr, FolderCont
//
//		
//	Redimension/N=(ItemsInList(CurrentFolders , ";")) ListOfAvailableData, SelectionOfAvailableData
//	j=0
//	For(i=0;i<ItemsInList(CurrentFolders , ";");i+=1)
//		TempStr = ReplaceString(LStartFolder, StringFromList(i, CurrentFolders , ";"),"")
//		if(strlen(TempStr)>0)
//			ListOfAvailableData[j] = tempStr
//			j+=1
//		endif
//	endfor
//	if(j<ItemsInList(CurrentFolders , ";"))
//		DeletePoints j, numpnts(ListOfAvailableData)-j, ListOfAvailableData, SelectionOfAvailableData
//	endif
//	SelectionOfAvailableData = 0
//	IR3L_SortListOfAvailableFldrs()
//	setDataFolder OldDF
//end
//

////**************************************************************************************
////**************************************************************************************
//Function/T IR3L_GenStringOfFolders(StartFolder,UseIndra2Structure, UseQRSStructure, UseResults, SlitSmearedData, AllowQRDataOnly)
//	string StartFolder
//	variable UseIndra2Structure, UseQRSStructure, UseResults, SlitSmearedData, AllowQRDataOnly
//		//SlitSmearedData =0 for DSM data, 
//		//                          =1 for SMR data 
//		//                    and =2 for both
//		// AllowQRDataOnly=1 if Q and R data are allowed only (no error wave). For QRS data ONLY!
//	
//	string ListOfQFolders
//	string TempStr, tempStr2
//	variable i
//	//	if UseIndra2Structure = 1 we are using Indra2 data, else return all folders 
//	string result
//	if (UseIndra2Structure)
//		if(SlitSmearedData==1)
//			result=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*SMR*", 1)
//		elseif(SlitSmearedData==2)
//			tempStr=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*SMR*", 1)
//			result=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*DSM*", 1)+";"
//			for(i=0;i<ItemsInList(tempStr);i+=1)
//			//print stringmatch(result, "*"+StringFromList(i, tempStr,";")+"*")
//				if(stringmatch(result, "*"+StringFromList(i, tempStr,";")+"*")==0)
//					result+=StringFromList(i, tempStr,";")+";"
//				endif
//			endfor
//		else
//			result=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*DSM*", 1)
//		endif
//	elseif (UseQRSStructure)
////		ListOfQFolders=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "q*", 1)
////		result=IR1_ReturnListQRSFolders(ListOfQFolders,AllowQRDataOnly)
//			make/N=0/FREE/T ResultingWave
//			IR2P_FindFolderWithWaveTypesWV(StartFolder, 10, "(?i)^r|i$", 1, ResultingWave)
//			//IR2P_FindFolderWithWaveTypesWV("root:", 10, "*i*", 1, ResultingWave)
//			result=IR3C_CheckForRightQRSTripletWvs(ResultingWave,AllowQRDataOnly)
//	elseif (UseResults)
//		SVAR SelectedResultsTool=root:Packages:Irena:MultiSaPlotFit:SelectedResultsTool
//		SVAR SelectedResultsType=root:Packages:Irena:MultiSaPlotFit:SelectedResultsType
//		SVAR ResultsGenerationToUse=root:Packages:Irena:MultiSaPlotFit:ResultsGenerationToUse
//		if(stringmatch(ResultsGenerationToUse,"Latest"))
//			result=IN2G_FindFolderWithWvTpsList(StartFolder, 10,SelectedResultsType+"*", 1) 
//		else
//			result=IN2G_FindFolderWithWvTpsList(StartFolder, 10,SelectedResultsType+ResultsGenerationToUse, 1) 
//		endif
//	else
//		result=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*", 1)
//	endif
//	if(stringmatch(";",result[0]))
//		result = result [1, inf]
//	endif
//	return result
//end

////*****************************************************************************************************************
////*****************************************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//Function IR3L_SortListOfAvailableFldrs()
//	
//	SVAR FolderSortString=root:Packages:Irena:MultiSaPlotFit:FolderSortString
//	Wave/T ListOfAvailableData=root:Packages:Irena:MultiSaPlotFit:ListOfAvailableData
//	Wave SelectionOfAvailableData=root:Packages:Irena:MultiSaPlotFit:SelectionOfAvailableData
//	if(numpnts(ListOfAvailableData)<2)
//		return 0
//	endif
//	Duplicate/Free SelectionOfAvailableData, TempWv
//	variable i, InfoLoc, j=0
//	variable DIDNotFindInfo
//	DIDNotFindInfo =0
//	string tempstr 
//	SelectionOfAvailableData=0
//	if(stringMatch(FolderSortString,"---"))
//		//nothing to do
//	elseif(stringMatch(FolderSortString,"Alphabetical"))
//		Sort /A ListOfAvailableData, ListOfAvailableData
//	elseif(stringMatch(FolderSortString,"Reverse Alphabetical"))
//		Sort /A /R ListOfAvailableData, ListOfAvailableData
//	elseif(stringMatch(FolderSortString,"_xyz"))
//		For(i=0;i<numpnts(TempWv);i+=1)
//			TempWv[i] = str2num(StringFromList(ItemsInList(ListOfAvailableData[i]  , "_")-1, ListOfAvailableData[i]  , "_"))
//		endfor
//		Sort TempWv, ListOfAvailableData
//	elseif(stringMatch(FolderSortString,"Sxyz_"))
//		For(i=0;i<numpnts(TempWv);i+=1)
//			TempWv[i] = str2num(ReplaceString("S", StringFromList(0, ListOfAvailableData[i], "_"), ""))
//		endfor
//		Sort TempWv, ListOfAvailableData
//	elseif(stringMatch(FolderSortString,"Reverse Sxyz_"))
//		For(i=0;i<numpnts(TempWv);i+=1)
//			TempWv[i] = str2num(ReplaceString("S", StringFromList(0, ListOfAvailableData[i], "_"), ""))
//		endfor
//		Sort/R TempWv, ListOfAvailableData
//	elseif(stringMatch(FolderSortString,"_xyzmin"))
//		Do
//			For(i=0;i<ItemsInList(ListOfAvailableData[j] , "_");i+=1)
//				if(StringMatch(ReplaceString(":", StringFromList(i, ListOfAvailableData[j], "_"),""), "*min" ))
//					InfoLoc = i
//					break
//				endif
//			endfor
//			j+=1
//			if(j>(numpnts(ListOfAvailableData)-1))
//				DIDNotFindInfo=1
//				break
//			endif
//		while (InfoLoc<1) 
//		if(DIDNotFindInfo)
//			DoALert /T="Information not found" 0, "Cannot find location of _xyzmin information, sorting alphabetically" 
//			Sort /A ListOfAvailableData, ListOfAvailableData
//		else
//			For(i=0;i<numpnts(TempWv);i+=1)
//				if(StringMatch(StringFromList(InfoLoc, ListOfAvailableData[i], "_"), "*min*" ))
//					TempWv[i] = str2num(ReplaceString("min", StringFromList(InfoLoc, ListOfAvailableData[i], "_"), ""))
//				else	//data not found
//					TempWv[i] = inf
//				endif
//			endfor
//			Sort TempWv, ListOfAvailableData
//		endif
//	elseif(stringMatch(FolderSortString,"_xyzpct"))
//		Do
//			For(i=0;i<ItemsInList(ListOfAvailableData[j] , "_");i+=1)
//				if(StringMatch(ReplaceString(":", StringFromList(i, ListOfAvailableData[j], "_"),""), "*pct" ))
//					InfoLoc = i
//					break
//				endif
//			endfor
//			j+=1
//			if(j>(numpnts(ListOfAvailableData)-1))
//				DIDNotFindInfo=1
//				break
//			endif
//		while (InfoLoc<1) 
//		if(DIDNotFindInfo)
//			DoAlert/T="Information not found" 0, "Cannot find location of _xyzpct information, sorting alphabetically" 
//			Sort /A ListOfAvailableData, ListOfAvailableData
//		else
//			For(i=0;i<numpnts(TempWv);i+=1)
//				if(StringMatch(StringFromList(InfoLoc, ListOfAvailableData[i], "_"), "*pct*" ))
//					TempWv[i] = str2num(ReplaceString("pct", StringFromList(InfoLoc, ListOfAvailableData[i], "_"), ""))
//				else	//data not found
//					TempWv[i] = inf
//				endif
//			endfor
//			Sort TempWv, ListOfAvailableData
//		endif
//	elseif(stringMatch(FolderSortString,"_xyzC"))
//		Do
//			For(i=0;i<ItemsInList(ListOfAvailableData[j] , "_");i+=1)
//				if(StringMatch(ReplaceString(":", StringFromList(i, ListOfAvailableData[j], "_"),""), "*C" ))
//					InfoLoc = i
//					break
//				endif
//			endfor
//			j+=1
//			if(j>(numpnts(ListOfAvailableData)-1))
//				DIDNotFindInfo=1
//				break
//			endif
//		while (InfoLoc<1) 
//		if(DIDNotFindInfo)
//			DoAlert /T="Information not found" 0, "Cannot find location of _xyzC information, sorting alphabetically" 
//			Sort /A ListOfAvailableData, ListOfAvailableData
//		else
//			For(i=0;i<numpnts(TempWv);i+=1)
//				if(StringMatch(StringFromList(InfoLoc, ListOfAvailableData[i], "_"), "*C*" ))
//					TempWv[i] = str2num(ReplaceString("C", StringFromList(InfoLoc, ListOfAvailableData[i], "_"), ""))
//				else	//data not found
//					TempWv[i] = inf
//				endif
//			endfor
//			Sort TempWv, ListOfAvailableData
//		endif
//	elseif(stringMatch(FolderSortString,"Reverse _xyz"))
//		For(i=0;i<numpnts(TempWv);i+=1)
//			TempWv[i] = str2num(StringFromList(ItemsInList(ListOfAvailableData[i]  , "_")-1, ListOfAvailableData[i]  , "_"))
//		endfor
//		Sort /R  TempWv, ListOfAvailableData
//	elseif(stringMatch(FolderSortString,"_xyz.ext"))
//		For(i=0;i<numpnts(TempWv);i+=1)
//			tempstr = StringFromList(ItemsInList(ListOfAvailableData[i]  , ".")-2, ListOfAvailableData[i]  , ".")
//			TempWv[i] = str2num(StringFromList(ItemsInList(tempstr , "_")-1, tempstr , "_"))
//		endfor
//		Sort TempWv, ListOfAvailableData
//	elseif(stringMatch(FolderSortString,"Reverse _xyz.ext"))
//		For(i=0;i<numpnts(TempWv);i+=1)
//			tempstr = StringFromList(ItemsInList(ListOfAvailableData[i]  , ".")-2, ListOfAvailableData[i]  , ".")
//			TempWv[i] = str2num(StringFromList(ItemsInList(tempstr , "_")-1, tempstr , "_"))
//		endfor
//		Sort /R  TempWv, ListOfAvailableData
//	elseif(stringMatch(FolderSortString,"_xyz_000"))
//		For(i=0;i<numpnts(TempWv);i+=1)
//			TempWv[i] = str2num(StringFromList(ItemsInList(ListOfAvailableData[i]  , "_")-2, ListOfAvailableData[i]  , "_"))
//		endfor
//		Sort TempWv, ListOfAvailableData
//	elseif(stringMatch(FolderSortString,"Reverse _xyz_000"))
//		For(i=0;i<numpnts(TempWv);i+=1)
//			TempWv[i] = str2num(StringFromList(ItemsInList(ListOfAvailableData[i]  , "_")-2, ListOfAvailableData[i]  , "_"))
//		endfor
//		Sort /R  TempWv, ListOfAvailableData
//	endif
//
//end
////**************************************************************************************
