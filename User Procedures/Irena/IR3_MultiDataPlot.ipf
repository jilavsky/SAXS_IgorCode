#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.04
constant IR3LversionNumber = 1.03			//MultiDataplotting tool version number. 

//*************************************************************************\
//* Copyright (c) 2005 - 2021, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/


//1.04 	fix bug for same name waves (USAXS, results) which run into wave/trace name issues as appending error bars.  
//1.03 	Added more graph controls. Reverse traces, added ability to create contour plot. 
//1.02 	Added Two more versionf of Porod plot - IQ4 vs Q and IQ3 vs Q. 
//1.01		Changed working folder name.  
//1.0 		New plotting tool to make plotting various data easy for multiple data sets.  



///******************************************************************************************
///******************************************************************************************
///			Multi-Data plotting tool, easy way to plot many data sets at once
///******************************************************************************************
///******************************************************************************************
Function IR3L_MultiSamplePlot()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IN2G_CheckScreenSize("width",1000)
	IN2G_CheckScreenSize("height",670)
	DoWIndow IR3L_MultiSamplePlotPanel
	if(V_Flag)
		DoWindow/F IR3L_MultiSamplePlotPanel
	else
		IR3L_InitMultiSamplePlot()
		IR3L_MultiSamplePlotPanelFnct()
		//		setWIndow IR3L_MultiSamplePlotPanel, hook(CursorMoved)=IR3D_PanelHookFunction
		IR1_UpdatePanelVersionNumber("IR3L_MultiSamplePlotPanel", IR3LversionNumber,1)
		//link it to top graph, if exists
		IR3L_SetStartConditions()
	endif
	IR3C_MultiUpdListOfAvailFiles("Irena:MultiSamplePlot")
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3L_MainCheckVersion()	
	DoWindow IR3L_MultiSamplePlotPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR3L_MultiSamplePlotPanel", IR3LversionNumber))
			DoAlert /T="The Multi Data Plots panel was created by incorrect version of Irena " 1, "Multi Data Plots may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				KillWIndow/Z IR3L_MultiSamplePlotPanel
				IR3L_MultiSamplePlot()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR3L_InitMultiSamplePlot()
			endif
		endif
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3L_SetStartConditions()
		
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		SVAR GraphWindowName = root:Packages:Irena:MultiSamplePlot:GraphWindowName
		SVAR GraphUserTitle=root:Packages:Irena:MultiSamplePlot:GraphUserTitle
		
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
Function IR3L_MultiSamplePlotPanelFnct()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(5.25,43.25,605,820) as "MultiData plotting tool"
	DoWIndow/C IR3L_MultiSamplePlotPanel
	TitleBox MainTitle title="\Zr220Multi Data plotting tool",pos={140,1},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fColor=(0,0,52224)
								//	TitleBox FakeLine2 title=" ",fixedSize=1,size={330,3},pos={16,428},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena:MultiSamplePlot","IR3L_MultiSamplePlotPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	Button GetHelp,pos={480,10},size={80,15},fColor=(65535,32768,32768), proc=IR3L_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}
	IR3C_MultiAppendControls("Irena:MultiSamplePlot","IR3L_MultiSamplePlotPanel", "IR3L_DoubleClickAction","",0,1)
	//graph controls
	SVAR GraphWindowName=root:Packages:Irena:MultiSamplePlot:GraphWindowName
	PopupMenu SelectGraphWindows,pos={280,90},size={310,20},proc=IR3L_PopMenuProc, title="Select Graph",help={"Select one of controllable graphs"}
	PopupMenu SelectGraphWindows,value=IR3L_GraphListPopupString(),mode=1, popvalue=GraphWindowName
	
	SetVariable GraphWindowName,pos={280,115},size={310,20}, proc=IR3L_SetVarProc,title="\Zr120Graph Window name: ", noedit=1, valueColor=(65535,0,0)
	Setvariable GraphWindowName,fStyle=2, variable=root:Packages:Irena:MultiSamplePlot:GraphWindowName, disable=0, frame=0, help={"This is Igro internal name for graph currently selected for controls"}

	SetVariable GraphUserTitle,pos={280,140},size={310,20}, proc=IR3L_SetVarProc,title="\Zr120Graph title: "
	Setvariable GraphUserTitle,fStyle=2, variable=root:Packages:Irena:MultiSamplePlot:GraphUserTitle, help={"This is human name for graph currently controlled by the tool. You can change it."}

	//Plotting controls...
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={260,170},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	
	Button NewGraphPlotData,pos={270,180},size={120,20}, proc=IR3L_ButtonProc,title="New graph", help={"Plot selected data in new graph"}
	Button AppendPlotData,pos={410,180},size={180,20}, proc=IR3L_ButtonProc,title="Append to selected graph", help={"Append selected data to graph selected above"}
	//this is selection of data types the code will plot. 
	SVAR SelectedDataPlot=root:Packages:Irena:MultiSamplePlot:SelectedDataPlot
	PopupMenu SelectedDataPlot,pos={260,215},size={310,20},proc=IR3L_PopMenuProc, title="\Zr120Data type to plot?  : ",help={"Select data to create if needed to graph"}
	PopupMenu SelectedDataPlot,value=#"root:Packages:Irena:MultiSamplePlot:ListOfDefinedDataPlots",mode=1, popvalue=SelectedDataPlot, bodyWidth=150
	PopupMenu SelectedDataPlot fstyle=5,fColor=(0,0,65535)
	TitleBox SelectedDataPlotInstructions title="\Zr100",size={245,15},pos={260,240},frame=0,fColor=(0,0,65535),labelBack=0


	TitleBox GraphAxesControls title="\Zr100Graph Axes Options",fixedSize=1,size={150,20},pos={350,260},frame=0,fstyle=1, fixedSize=1

	TitleBox XAxisLegendTB title="\Zr100X Axis Legend",fixedSize=1,size={150,20},pos={280,280},frame=0,fstyle=1, fixedSize=1
	TitleBox YAxisLegendTB title="\Zr100Y Axis Legend",fixedSize=1,size={150,20},pos={450,280},frame=0,fstyle=1, fixedSize=1

	SetVariable XAxisLegend,pos={260,300},size={160,15}, proc=IR3L_SetVarProc,title=" "
	Setvariable XAxisLegend, fStyle=2, variable=root:Packages:Irena:MultiSamplePlot:XAxisLegend, help={"Legend for X axis, you can change it. "}
	SetVariable YAxislegend,pos={430,300},size={160,15}, proc=IR3L_SetVarProc,title=" "
	Setvariable YAxislegend, fStyle=2, variable=root:Packages:Irena:MultiSamplePlot:YAxislegend, help={"legend for Y axis. You can change it. "}
	
	Checkbox LogXAxis, pos={280,320},size={76,14},title="LogXAxis?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSamplePlot:LogXAxis, help={"Use log X axis. You can change it. "}
	Checkbox LogYAxis, pos={450,320},size={76,14},title="LogYAxis?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSamplePlot:LogYAxis, help={"Use log X axis. You can change it. "}

	SetVariable XOffset,pos={260,340},size={130,15}, proc=IR3L_SetVarProc,title="X offset :     ", limits={-inf,inf,1}
	Setvariable XOffset, fStyle=2, variable=root:Packages:Irena:MultiSamplePlot:XOffset, help={"X Offxet for X axis, you can change it. "}
	SetVariable YOffset,pos={430,340},size={130,15}, proc=IR3L_SetVarProc,title="Y offset :     ",limits={-inf,inf,1}
	Setvariable YOffset, fStyle=2, variable=root:Packages:Irena:MultiSamplePlot:YOffset, help={"Y Offset for Y axis. You can change it. "}


	TitleBox GraphTraceControls title="\Zr100Graph Trace Options",fixedSize=1,size={150,20},pos={350,420},frame=0,fstyle=1, fixedSize=1

	Checkbox Colorize, pos={280,440},size={76,14},title="Vary colors?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSamplePlot:Colorize, help={"Colorize the data? Oposite is B/W"}
	Checkbox UseSymbols, pos={280,480},size={76,14},title="Use Symbols?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSamplePlot:UseSymbols, help={"Use Symbols for data. "}
	Checkbox UseLines, pos={280,500},size={76,14},title="Use Lines?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSamplePlot:UseLines, help={"Use Lines for data"}

	Checkbox DisplayErrorBars, pos={280,520},size={76,14},title="Display Error bars?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSamplePlot:DisplayErrorBars, help={"Display error bars (if they exist)"}


	NVAR SymbolSize=root:Packages:Irena:MultiSamplePlot:SymbolSize
	PopupMenu SymbolSize,pos={430,480},size={310,20},proc=IR3L_PopMenuProc, title="Symbol Size : ",help={"Symbol Size"}
	PopupMenu SymbolSize,value="0;1;2;3;5;7;10;",mode=1, popvalue=num2str(SymbolSize)
	SetVariable LineThickness,pos={430,500},size={160,15}, proc=IR3L_SetVarProc,title="Line Thickness",limits={0.5,10,0.5}
	Setvariable LineThickness, fStyle=2, variable=root:Packages:Irena:MultiSamplePlot:LineThickness, help={"Line Thickness. You can change it. "}


	TitleBox GraphOtherControls title="\Zr100Graph Other Options",fixedSize=1,size={150,20},pos={350,560},frame=0,fstyle=1, fixedSize=1

	Checkbox AddLegend, pos={280,580},size={76,14},title="Add Legend?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSamplePlot:AddLegend, help={"Add legend to data."}
	Checkbox UseOnlyFoldersInLegend, pos={280,600},size={76,14},title="Only Folders?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSamplePlot:UseOnlyFoldersInLegend, help={"Only Folders in Legend?"}
	NVAR LegendSize=root:Packages:Irena:MultiSamplePlot:LegendSize
	PopupMenu LegendSize,pos={430,580},size={310,20},proc=IR3L_PopMenuProc, title="Legend Size : ",help={"legend Size"}
	PopupMenu LegendSize,value="8;10;12;14;16;20;24;",mode=1, popvalue=num2str(LegendSize)


	TitleBox Instructions1 title="\Zr100Double click to add data ",size={330,15},pos={4,680},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions2 title="\Zr100Shift-click to select range ",size={330,15},pos={4,695},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions3 title="\Zr100Ctrl/Cmd-click to select one data set",size={330,15},pos={4,710},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions4 title="\Zr100Regex for not contain: ^((?!string).)*$",size={330,15},pos={4,725},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions5 title="\Zr100Regex for contain:  string, two: str2.*str1",size={330,15},pos={4,740},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions6 title="\Zr100Regex for case independent:  (?i)string",size={330,15},pos={4,755},frame=0,fColor=(0,0,65535),labelBack=0
	Button SelectAll,pos={175,680},size={80,15}, proc=IR3L_ButtonProc,title="SelectAll", help={"Select All data in Listbox"}

	SVAR SelectedStyle = root:Packages:Irena:MultiSamplePlot:SelectedStyle
	SVAR allStyles=root:Packages:Irena:MultiSamplePlot:ListOfDefinedStyles
	Checkbox ApplyFormatingEveryTime, pos={260,642},size={76,14},title="Apply Formating automatically?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSamplePlot:ApplyFormatingEveryTime, help={"Should all formatting be applied after every data additon?"}
	PopupMenu ApplyStyle,pos={260,660},size={300,20},proc=IR3L_PopMenuProc, title="Apply style:",help={"Set tool setting to defined conditions and apply to graph"}
	PopupMenu ApplyStyle,value=#"root:Packages:Irena:MultiSamplePlot:ListOfDefinedStyles",mode=WhichListItem(SelectedStyle, allStyles)+1  
	Button ApplyPresetFormating,pos={260,685},size={160,20}, proc=IR3L_ButtonProc,title="Apply All Formating", help={"Apply Preset Formating to update graph based on these choices"}
	Button ReverseTraces,pos={275,710},size={130,17}, proc=IR3L_ButtonProc,title="Reverse traces", help={"Reverse traces in the controled graph"}
	
	Button ExportGraphJPG,pos={450,660},size={140,20}, proc=IR3L_ButtonProc,title="Export as jpg", help={"Export as jpg file"}
	Button ExportGraphTIF,pos={450,685},size={140,20}, proc=IR3L_ButtonProc,title="Export as tiff", help={"Export as tiff file"}
	Button SaveGraphAsFile,pos={450,710},size={140,20}, proc=IR3L_ButtonProc,title="Export as pxp", help={"Save Graph As Igor experiment"}
	//this is not finioshed, ots of tedious work needs to be done copying code
	//major issue - Gizmo window name may not be suitable to corry folder name? 
	//Button CreateGizmo,pos={300,737},size={140,15}, proc=IR3L_ButtonProc,title="Create Gizmo plot", help={"Create Gizmo 3D plot of the controlled graph"}
	Button CreateContour,pos={450,737},size={140,15}, proc=IR3L_ButtonProc,title="Create Countour plot", help={"Create contour plot of the controlled graph"}
	Button CreateWaterFall,pos={450,755},size={140,15}, proc=IR3L_ButtonProc,title="Create Waterfall plot", help={"Create waterfall plot of the controlled graph"}


	IR3L_FixPanelControls()
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3L_FixPanelControls()
	//fix panel controls to whatever selection user made...

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR SelectedDataPlot=root:Packages:Irena:MultiSamplePlot:SelectedDataPlot
	strswitch(SelectedDataPlot)						// string switch
		case "X-Y (q-Int, etc.)":				// execute if case matches expression
			TitleBox SelectedDataPlotInstructions win=IR3L_MultiSamplePlotPanel, title="\Zr100Original data will be used"
			break										// exit from switch
		case "Guinier (Q^2-ln(I))":				// execute if case matches expression
			TitleBox SelectedDataPlotInstructions win=IR3L_MultiSamplePlotPanel, title="\Zr100Guinier data will be created"
			break
		case "Guinier Rod (Q^2-ln(I*Q))":				// execute if case matches expression
			TitleBox SelectedDataPlotInstructions win=IR3L_MultiSamplePlotPanel, title="\Zr100Guinier Rod data will be created"
			break
		case "Guinier Sheet (Q^2-ln(I*Q^2))":				// execute if case matches expression
			TitleBox SelectedDataPlotInstructions win=IR3L_MultiSamplePlotPanel, title="\Zr100Guinier Sheet data will be created"
			break
		case "Kratky (Q-IQ^2)":					// execute if case matches expression
			TitleBox SelectedDataPlotInstructions win=IR3L_MultiSamplePlotPanel, title="\Zr100Kratky data will be created"
			break
		case "DimLess Kratky (Q-I*(Q*Rg)^2/I0)":					// execute if case matches expression
			TitleBox SelectedDataPlotInstructions win=IR3L_MultiSamplePlotPanel, title="\Zr100DimLess Kratky data will be created if Guinier fit results exist"
			break
		case "Porod (Q^4-IQ^4)":					// execute if case matches expression
			TitleBox SelectedDataPlotInstructions win=IR3L_MultiSamplePlotPanel, title="\Zr100Porod data will be created"
			break
		case "Porod 2 (Q-IQ^4)":					// execute if case matches expression
			TitleBox SelectedDataPlotInstructions win=IR3L_MultiSamplePlotPanel, title="\Zr100Porod data will be created"
			break
		case "Porod 3 (Q-IQ^3)":					// execute if case matches expression
			TitleBox SelectedDataPlotInstructions win=IR3L_MultiSamplePlotPanel, title="\Zr100Porod data will be created"
			break
		default:										// optional default expression executed, this is basically X-Y case again
														// when no case matches
	endswitch

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function/S IR3L_GraphListPopupString()
	// Create some waves for demo purposes
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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

static Function IR3L_InitMultiSamplePlot()	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	string ListOfVariables
	string ListOfStrings
	variable i
		
	if (!DataFolderExists("root:Packages:Irena:MultiSamplePlot"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena
		NewDataFolder/O root:Packages:Irena:MultiSamplePlot
	endif
	SetDataFolder root:Packages:Irena:MultiSamplePlot					//go into the folder

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;DataUnits;"
	ListOfStrings+="DataStartFolder;DataMatchString;FolderSortString;FolderSortStringAll;"
	ListOfStrings+="UserMessageString;SavedDataMessage;"
	ListOfStrings+="SelectedResultsTool;SelectedResultsType;ResultsGenerationToUse;"
	ListOfStrings+="DataSubTypeUSAXSList;DataSubTypeResultsList;DataSubType;"
	ListOfStrings+="GraphUserTitle;GraphWindowName;XAxisLegend;YAxislegend;"
	ListOfStrings+="QvecLookupUSAXS;ErrorLookupUSAXS;dQLookupUSAXS;"
	ListOfStrings+="ListOfDefinedStyles;SelectedStyle;ListOfDefinedDataPlots;SelectedDataPlot;"

	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;"
	ListOfVariables+="InvertGrepSearch;"
	ListOfVariables+="LogXAxis;LogYAxis;MajorGridXaxis;MajorGridYaxis;MinorGridXaxis;MinorGridYaxis;"
	ListOfVariables+="Colorize;UseSymbols;UseLines;SymbolSize;LineThickness;"
	ListOfVariables+="XOffset;YOffset;DisplayErrorBars;ApplyFormatingEveryTime;"
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
	ListOfDefinedStyles = "Log-Log;Lin-Lin;Lin-Log;VolumeSizeDistribution;NumberSizeDistribution;"
	SVAR ListOfDefinedDataPlots
	ListOfDefinedDataPlots = "X-Y (q-Int, etc.);Guinier (Q^2-ln(I));Kratky (Q-IQ^2);Porod (Q^4-IQ^4);Guinier Rod (Q^2-ln(I*Q));Guinier Sheet (Q^2-ln(I*Q^2));DimLess Kratky (Q-I*(Q*Rg)^2/I0);Porod 2 (Q-IQ^4);Porod 3 (Q-IQ^3);"
	SVAR SelectedStyle
	if(strlen(SelectedStyle)<2)
		SelectedStyle="Log-Log"
	endif
	SVAR SelectedDataPlot
	if(strlen(SelectedDataPlot)<2)
		SelectedDataPlot=StringFromList(0,ListOfDefinedDataPlots)
	endif



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
		SelectedResultsTool=IR2C_ReturnKnownToolResults(SelectedResultsTool,"")
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
	NVAR LogXAxis
	NVAR LogYAxis
	if(StringMatch(SelectedStyle, "Log-Log"))
		LogXAxis = 1
		LogYAxis = 1
	endif
	
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
Function IR3L_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR UseIndra2Data =  root:Packages:Irena:MultiSamplePlot:UseIndra2Data
			NVAR UseQRSData =  root:Packages:Irena:MultiSamplePlot:UseQRSData
			NVAR UseResults =  root:Packages:Irena:MultiSamplePlot:UseResults
			SVAR DataStartFolder = root:Packages:Irena:MultiSamplePlot:DataStartFolder
			SVAR GraphWindowName = root:Packages:Irena:MultiSamplePlot:GraphWindowName
		  	NVAR UseLines = root:Packages:Irena:MultiSamplePlot:UseLines
		  	NVAR UseSymbols = root:Packages:Irena:MultiSamplePlot:UseSymbols
		  	NVAR SymbolSize = root:Packages:Irena:MultiSamplePlot:SymbolSize
		  	NVAR LineThickness= root:Packages:Irena:MultiSamplePlot:LineThickness
		  	NVAR LegendSize = root:Packages:Irena:MultiSamplePlot:LegendSize
		  	NVAR UseOnlyFoldersInLegend = root:Packages:Irena:MultiSamplePlot:UseOnlyFoldersInLegend
		  	NVAR AddLegend= root:Packages:Irena:MultiSamplePlot:AddLegend
		  	//abort if GraphWindowName is not right
		  	if(strlen(GraphWindowName)<1)	//name has any length	
		  		return 0
			endif		  	
		  	DOWindow $(GraphWindowName)	//widnow doesnot exist
		  	if(V_Flag==0)
		  		return 0
		  	endif
		  	
		  	if(stringmatch(cba.ctrlName,"DisplayErrorBars"))
		  		NVAR DisplayErrorBars = root:Packages:Irena:MultiSamplePlot:DisplayErrorBars
				IN2G_ShowHideErrorBars(DisplayErrorBars, topGraphStr=GraphWindowName)
		  	endif
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
				DoWIndow/F IR3L_MultiSamplePlotPanel
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
				DoWIndow/F IR3L_MultiSamplePlotPanel
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
				DoWIndow/F IR3L_MultiSamplePlotPanel
		  	endif
		  	
		  	if(stringmatch(cba.ctrlName,"AddLegend") || stringmatch(cba.ctrlName,"UseOnlyFoldersInLegend"))
 	 			DoWIndow/F $(GraphWindowName)
		  		if(AddLegend)
		  			IN2G_LegendTopGrphFldr(LegendSize, 20, 1, !(UseOnlyFoldersInLegend))
		  		else
					Legend/K/N=text0/W=$(GraphWindowName)
		  		endif
				DoWIndow/F IR3L_MultiSamplePlotPanel
		  	endif
  		
  	
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End
//**************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3L_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	String ctrlName=Pa.ctrlName
	Variable popNum=Pa.popNum
	String popStr=Pa.popStr
	
	if(Pa.eventcode!=2)
		return 0
	endif
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR GraphWindowName = root:Packages:Irena:MultiSamplePlot:GraphWindowName
	if(strlen(GraphWindowName)>0)
		if(stringmatch(ctrlName,"SelectGraphWindows"))
			//do something here
			SVAR GraphWindowName=root:Packages:Irena:MultiSamplePlot:GraphWindowName
			SVAR GraphUserTitle=root:Packages:Irena:MultiSamplePlot:GraphUserTitle
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
			NVAR UseSymbols = root:Packages:Irena:MultiSamplePlot:UseSymbols
			NVAR SymbolSize = root:Packages:Irena:MultiSamplePlot:SymbolSize
			NVAR UseLines = root:Packages:Irena:MultiSamplePlot:UseLines
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
			NVAR LegendSize = root:Packages:Irena:MultiSamplePlot:LegendSize
			NVAR AddLegend = root:Packages:Irena:MultiSamplePlot:AddLegend
			NVAR UseOnlyFoldersInLegend = root:Packages:Irena:MultiSamplePlot:UseOnlyFoldersInLegend
			LegendSize = str2num(popStr)
			if(AddLegend)
		 			IN2G_LegendTopGrphFldr(LegendSize, 20, 1, !(UseOnlyFoldersInLegend))
			endif
		endif		
	endif
	if(stringmatch(ctrlName,"ApplyStyle"))
		//do something here
		SVAR SelectedStyle=root:Packages:Irena:MultiSamplePlot:SelectedStyle
		SelectedStyle = popStr
		IR3L_SetAndApplyStyle(popStr)	
	endif
	if(stringmatch(ctrlName,"SelectedDataPlot"))
		//do something here
		SVAR SelectedDataPlot=root:Packages:Irena:MultiSamplePlot:SelectedDataPlot
		SelectedDataPlot=popStr
		IR3L_SetPlotLegends()	
		SVAR SelectedStyle=root:Packages:Irena:MultiSamplePlot:SelectedStyle
		SelectedStyle = "Lin-Lin"
		IR3L_SetAndApplyStyle(SelectedStyle)	
		PopupMenu ApplyStyle,win=IR3L_MultiSamplePlotPanel, popmatch=SelectedStyle
		IR3L_FixPanelControls()
	endif
	DOWIndow/F IR3L_MultiSamplePlotPanel
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
		SVAR GraphUserTitle=root:Packages:Irena:MultiSamplePlot:GraphUserTitle
		SVAR GraphWindowName = root:Packages:Irena:MultiSamplePlot:GraphWindowName
			if(strlen(GraphWindowName)>0)
				if(stringmatch(sva.ctrlName,"GraphUserTitle"))
					DoWindow/T $(GraphWindowName),(GraphUserTitle)
				endif
				
				if(stringmatch(sva.ctrlName,"LineThickness"))
					NVAR LineThickness = root:Packages:Irena:MultiSamplePlot:LineThickness
					if(LineThickness<0.5)
						LineThickness = 0.5
					endif
					DoWindow/F $(GraphWindowName)
		  			IN2G_VaryLinesTopGrphRainbow(LineThickness, 1)
				endif
				
				if(stringmatch(sva.ctrlName,"XOffset") || stringmatch(sva.ctrlName,"YOffset"))
					NVAR XOffset=root:Packages:Irena:MultiSamplePlot:XOffset
					NVAR YOffset=root:Packages:Irena:MultiSamplePlot:YOffset
					NVAR LogXAxis=root:Packages:Irena:MultiSamplePlot:LogXAxis
					NVAR LogYAxis=root:Packages:Irena:MultiSamplePlot:LogYAxis
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
	DoWIndow/F IR3L_MultiSamplePlotPanel
	return 0
End


//**************************************************************************************
//**************************************************************************************
Function IR3L_DoubleClickAction(FoldernameStr)
		string FoldernameStr
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		//if called with GraphWindowName = "---" need to create new graph and direct data there, or the tool doe snothing
		SVAR GraphWindowName=root:Packages:Irena:MultiSamplePlot:GraphWindowName
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
		else
			DoWindow/F $(LocalGraphName)
		endif		
		IR3L_AppendData(FoldernameStr)
		if(CreatedNewGraph)
			IR3L_ApplyPresetFormating(GraphWindowName)
		endif

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3L_AppendData(FolderNameStr)
	string FolderNameStr
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:MultiSamplePlot					//go into the folder
		SVAR DataStartFolder=root:Packages:Irena:MultiSamplePlot:DataStartFolder
		SVAR DataFolderName=root:Packages:Irena:MultiSamplePlot:DataFolderName
		SVAR IntensityWaveName=root:Packages:Irena:MultiSamplePlot:IntensityWaveName
		SVAR QWavename=root:Packages:Irena:MultiSamplePlot:QWavename
		SVAR ErrorWaveName=root:Packages:Irena:MultiSamplePlot:ErrorWaveName
		SVAR dQWavename=root:Packages:Irena:MultiSamplePlot:dQWavename
		NVAR UseIndra2Data=root:Packages:Irena:MultiSamplePlot:UseIndra2Data
		NVAR UseQRSdata=root:Packages:Irena:MultiSamplePlot:UseQRSdata
		NVAR useResults=root:Packages:Irena:MultiSamplePlot:useResults
		SVAR DataSubType = root:Packages:Irena:MultiSamplePlot:DataSubType
		//these are variables used by the control procedure
		NVAR  UseUserDefinedData=  root:Packages:Irena:MultiSamplePlot:UseUserDefinedData
		NVAR  UseModelData = root:Packages:Irena:MultiSamplePlot:UseModelData
		SVAR DataFolderName  = root:Packages:Irena:MultiSamplePlot:DataFolderName 
		SVAR IntensityWaveName = root:Packages:Irena:MultiSamplePlot:IntensityWaveName
		SVAR QWavename = root:Packages:Irena:MultiSamplePlot:QWavename
		SVAR ErrorWaveName = root:Packages:Irena:MultiSamplePlot:ErrorWaveName
		//graph control variable
		SVAR GraphUserTitle=root:Packages:Irena:MultiSamplePlot:GraphUserTitle
		SVAR GraphWindowName=root:Packages:Irena:MultiSamplePlot:GraphWindowName
		SVAR ResultsDataTypesLookup=root:Packages:IrenaControlProcs:ResultsDataTypesLookup
		//what data are actually plot??? 
		SVAR SelectedDataPlot=root:Packages:Irena:MultiSamplePlot:SelectedDataPlot
		SVAR ListOfDefinedDataPlots=root:Packages:Irena:MultiSamplePlot:ListOfDefinedDataPlots

		IR3C_SelectWaveNamesData("Irena:MultiSamplePlot", FolderNameStr)			//thsi routine will presetn names in strings as needed
		Wave/Z SourceIntWv=$(DataFolderName+possiblyQUoteName(IntensityWaveName))
		Wave/Z SourceQWv=$(DataFolderName+possiblyQUoteName(QWavename))
		Wave/Z SourceErrorWv=$(DataFolderName+possiblyQUoteName(ErrorWaveName))
		Wave/Z SourcedQWv=$(DataFolderName+possiblyQUoteName(dQWavename))
		if(!WaveExists(SourceIntWv)||	!WaveExists(SourceQWv))
			print "Data selection failed for "+DataFolderName
			return 0
		endif
		//create local copies of original data, inc case their are needed later
		Duplicate/Free SourceIntWv, SourceIntWvOrig
		Duplicate/Free SourceQWv, SourceQWvOrig
		if(WaveExists(SourceErrorWv))
			Duplicate/Free SourceErrorWv, SourceErrorWvOrig
		endif
		//create graph if needed. 
		if(StringMatch(GraphWindowName, "---" ))
				IR3L_CreateNewGraph()											
		endif
		DoWIndow  $(GraphWindowName)
		if(V_Flag==0)
			print "Graph does not exist, nothing to append to, stopping... "
			SetDataFolder oldDf
			return 0
		endif
		//now we need to create data, if they do not exist. Here is where we decide what data user wants to plot. 
		//	ListOfDefinedDataPlots = "X-Y (q-Int, etc.);Guinier (Q^2-ln(I));Kratky (Q-IQ^2);Porod (Q^4-IQ^4);DimLess Kratky (Q-I*(Q*Rg)^2/I0);"
		strswitch(SelectedDataPlot)						// string switch
			case "X-Y (q-Int, etc.)":				// execute if case matches expression
				//nothing to do... 
				break										// exit from switch
			case "Guinier (Q^2-ln(I))":				// execute if case matches expression
				//create and save Guinier data
				Duplicate/O SourceIntWv, $(DataFolderName+possiblyQUoteName("Guinier_"+IntensityWaveName))
				Duplicate/O SourceQWv, $(DataFolderName+possiblyQUoteName("Guinier_"+QWavename))
				Wave SourceIntWv=$(DataFolderName+possiblyQUoteName("Guinier_"+IntensityWaveName))
				Wave SourceQWv=$(DataFolderName+possiblyQUoteName("Guinier_"+QWavename))
				SourceQWv = SourceQWv^2
				SourceIntWv = ln(SourceIntWv)						//error propagation, see: https://terpconnect.umd.edu/~toh/models/ErrorPropagation.pdf
				if(WaveExists(SourceErrorWv))
					Duplicate/O SourceErrorWv, $(DataFolderName+possiblyQUoteName("Guinier_"+ErrorWaveName))
						Wave SourceErrorWv=$(DataFolderName+possiblyQUoteName("Guinier_"+ErrorWaveName))
					SourceErrorWv = SourceErrorWvOrig/SourceIntWvOrig
				endif
				break
			case "Guinier Rod (Q^2-ln(I*Q))":				// execute if case matches expression
				//create and save Guinier data
				Duplicate/O SourceIntWv, $(DataFolderName+possiblyQUoteName("GuinierR_"+IntensityWaveName))
				Duplicate/O SourceQWv, $(DataFolderName+possiblyQUoteName("GuinierR_"+QWavename))
				Wave SourceIntWv=$(DataFolderName+possiblyQUoteName("GuinierR_"+IntensityWaveName))
				Wave SourceQWv=$(DataFolderName+possiblyQUoteName("GuinierR_"+QWavename))
				SourceQWv = SourceQWv^2
				SourceIntWv = ln(SourceIntWv*SourceQWvOrig)						//error propagation, see: https://terpconnect.umd.edu/~toh/models/ErrorPropagation.pdf
				if(WaveExists(SourceErrorWv))
					Duplicate/O SourceErrorWv, $(DataFolderName+possiblyQUoteName("GuinierR_"+ErrorWaveName))
						Wave SourceErrorWv=$(DataFolderName+possiblyQUoteName("GuinierR_"+ErrorWaveName))
					SourceErrorWv = (SourceErrorWvOrig)/(SourceIntWvOrig)
				endif
				break
			case "Guinier Sheet (Q^2-ln(I*Q^2))":				// execute if case matches expression
				//create and save Guinier data
				Duplicate/O SourceIntWv, $(DataFolderName+possiblyQUoteName("GuinierS_"+IntensityWaveName))
				Duplicate/O SourceQWv, $(DataFolderName+possiblyQUoteName("GuinierS_"+QWavename))
				Wave SourceIntWv=$(DataFolderName+possiblyQUoteName("GuinierS_"+IntensityWaveName))
				Wave SourceQWv=$(DataFolderName+possiblyQUoteName("GuinierS_"+QWavename))
				SourceQWv = SourceQWv^2
				SourceIntWv = ln(SourceIntWv*SourceQWvOrig^2)						//error propagation, see: https://terpconnect.umd.edu/~toh/models/ErrorPropagation.pdf
				if(WaveExists(SourceErrorWv))
					Duplicate/O SourceErrorWv, $(DataFolderName+possiblyQUoteName("GuinierS_"+ErrorWaveName))
						Wave SourceErrorWv=$(DataFolderName+possiblyQUoteName("GuinierS_"+ErrorWaveName))
					SourceErrorWv = (SourceErrorWvOrig)/(SourceIntWvOrig)
				endif
				break
			case "Kratky (Q-IQ^2)":					// execute if case matches expression
				//create and save Kratky data
				Duplicate/O SourceIntWv, $(DataFolderName+possiblyQUoteName("Kratky_"+IntensityWaveName))
				Duplicate/O SourceQWv, $(DataFolderName+possiblyQUoteName("Kratky_"+QWavename))
				Wave SourceIntWv=$(DataFolderName+possiblyQUoteName("Kratky_"+IntensityWaveName))
				Wave SourceQWv=$(DataFolderName+possiblyQUoteName("Kratky_"+QWavename))
				SourceIntWv = SourceIntWv * SourceQWv^2
				if(WaveExists(SourceErrorWv))
					Duplicate/O SourceErrorWv, $(DataFolderName+possiblyQUoteName("Kratky_"+ErrorWaveName))
					Wave SourceErrorWv=$(DataFolderName+possiblyQUoteName("Kratky_"+ErrorWaveName))
					SourceErrorWv = SourceErrorWv * SourceQWv^2
				endif
				break
			case "DimLess Kratky (Q-I*(Q*Rg)^2/I0)":					// execute if case matches expression
				//create and save Kraky data corrected for Rg and I0
				//need to find Guinier fit results
				Wave/Z/T SampleName =  root:GuinierFitResults:SampleName
				Wave/Z GuinierI0 = root:GuinierFitResults:GuinierI0
				Wave/Z GuinierRg = root:GuinierFitResults:GuinierRg
				if(!WaveExists(SampleName) || !WaveExists(GuinierI0) ||!WaveExists(GuinierRg))
					Abort "Guinier results not found. In order to use this data type, you need to save results from Guinier fit using Simple Fits tool for all data you want to plot"
				endif
				variable I0 = IR3L_LookUpValueForWaveName(DataFolderName, SampleName,GuinierI0)
				variable Rg = IR3L_LookUpValueForWaveName(DataFolderName, SampleName,GuinierRg)
				if(numtype(I0) || numtype(Rg))
					Abort "Could not find Guinier results for "+DataFolderName+" in the Guinier fit results from Simple fit."
				endif
				Duplicate/O SourceIntWv, $(DataFolderName+possiblyQUoteName("DLKratky_"+IntensityWaveName))
				Duplicate/O SourceQWv, $(DataFolderName+possiblyQUoteName("DLKratky_"+QWavename))
				Wave SourceIntWv=$(DataFolderName+possiblyQUoteName("DLKratky_"+IntensityWaveName))
				Wave SourceQWv=$(DataFolderName+possiblyQUoteName("DLKratky_"+QWavename))
				SourceIntWv = SourceIntWv * ((Rg*SourceQWv)^2)/I0
				if(WaveExists(SourceErrorWv))
					Duplicate/O SourceErrorWv, $(DataFolderName+possiblyQUoteName("DLKratky_"+ErrorWaveName))
					Wave SourceErrorWv=$(DataFolderName+possiblyQUoteName("DLKratky_"+ErrorWaveName))
					SourceErrorWv = SourceErrorWv * ((Rg*SourceQWv)^2)/I0
				endif
				break
			case "Porod (Q^4-IQ^4)":					// execute if case matches expression
				//create and save Porod data
				Duplicate/O SourceIntWv, $(DataFolderName+possiblyQUoteName("Porod_"+IntensityWaveName))
				Duplicate/O SourceQWv, $(DataFolderName+possiblyQUoteName("Porod_"+QWavename))
				Wave SourceIntWv=$(DataFolderName+possiblyQUoteName("Porod_"+IntensityWaveName))
				Wave SourceQWv=$(DataFolderName+possiblyQUoteName("Porod_"+QWavename))
				SourceQWv = SourceQWv^4
				SourceIntWv = SourceIntWv * SourceQWv
				if(WaveExists(SourceErrorWv))
					Duplicate/O SourceErrorWv, $(DataFolderName+possiblyQUoteName("Porod_"+ErrorWaveName))
					Wave SourceErrorWv=$(DataFolderName+possiblyQUoteName("Porod_"+ErrorWaveName))
					SourceErrorWv = SourceErrorWv * SourceQWv
				endif
				break
			case "Porod 2 (Q-IQ^4)":					// execute if case matches expression
				//create and save Porod data
				Duplicate/O SourceIntWv, $(DataFolderName+possiblyQUoteName("Porod2_"+IntensityWaveName))
				Duplicate/O SourceQWv, $(DataFolderName+possiblyQUoteName("Porod2_"+QWavename))
				Wave SourceIntWv=$(DataFolderName+possiblyQUoteName("Porod2_"+IntensityWaveName))
				Wave SourceQWv=$(DataFolderName+possiblyQUoteName("Porod2_"+QWavename))
				//SourceQWv = SourceQWv
				SourceIntWv = SourceIntWv * SourceQWv^4
				if(WaveExists(SourceErrorWv))
					Duplicate/O SourceErrorWv, $(DataFolderName+possiblyQUoteName("Porod2_"+ErrorWaveName))
					Wave SourceErrorWv=$(DataFolderName+possiblyQUoteName("Porod2_"+ErrorWaveName))
					SourceErrorWv = SourceErrorWv * SourceQWv^4
				endif
				break
			case "Porod 3 (Q-IQ^3)":					// execute if case matches expression
				//create and save Porod data
				Duplicate/O SourceIntWv, $(DataFolderName+possiblyQUoteName("Porod3_"+IntensityWaveName))
				Duplicate/O SourceQWv, $(DataFolderName+possiblyQUoteName("Porod3_"+QWavename))
				Wave SourceIntWv=$(DataFolderName+possiblyQUoteName("Porod3_"+IntensityWaveName))
				Wave SourceQWv=$(DataFolderName+possiblyQUoteName("Porod3_"+QWavename))
				SourceQWv = SourceQWv
				SourceIntWv = SourceIntWv * SourceQWv^3
				if(WaveExists(SourceErrorWv))
					Duplicate/O SourceErrorWv, $(DataFolderName+possiblyQUoteName("Porod3_"+ErrorWaveName))
					Wave SourceErrorWv=$(DataFolderName+possiblyQUoteName("Porod3_"+ErrorWaveName))
					SourceErrorWv = SourceErrorWv * SourceQWv^3
				endif
				break
			default:										// optional default expression executed, this is basically X-Y case again
															// when no case matches
		endswitch

		//handle meanigless trace names here
		string NewTraceName
		if(UseIndra2Data ||useResults) 	//here we should name these by folder
			NewTraceName= GetWavesDataFolder(SourceIntWv, 0)
		else				//this is QRS, data shoudl already be named by folder, more or less... 
			NewTraceName=NameOfWave(SourceIntWv)
		endif
		
		CheckDisplayed /W=$(GraphWindowName) SourceIntWv
		if(V_Flag==0)
			AppendToGraph /W=$(GraphWindowName) SourceIntWv/TN=$(NewTraceName) vs  SourceQWv
			//AppendToGraph /W=$(GraphWindowName) SourceIntWv vs  SourceQWv
			if(WaveExists(SourceErrorWv))
				//ErrorBars /W=$(GraphWindowName)  $(NameOfWave(SourceIntWv)) Y,wave=(SourceErrorWv,SourceErrorWv)
				ErrorBars /W=$(GraphWindowName)  $(NewTraceName) Y,wave=(SourceErrorWv,SourceErrorWv)
			endif
			print "Appended : "+DataFolderName+IntensityWaveName +" top the graph : "+GraphWindowName
		else
			print "Could not append "+DataFolderName+IntensityWaveName+" to the graph : "+GraphWindowName+" this wave is already displayed in the graph" 
		endif
		//append data to graph
		NVAR ApplyFormatingEveryTime = root:Packages:Irena:MultiSamplePlot:ApplyFormatingEveryTime
		if(ApplyFormatingEveryTime)
			IR3L_ApplyPresetFormating(GraphWindowName)
		endif
	SetDataFolder oldDf
	return 1
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3L_LookUpValueForWaveName(SampleNameStr, SampleNameWV,ValueWv)
		string SampleNameStr			//folder name only, no wabe nae and include ":" at the end. 
		wave/T SampleNameWV
		Wave ValueWv
		
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i
	For (i=0;i<numpnts(SampleNameWV);i+=1)
		if(StringMatch(SampleNameStr, SampleNameWV[i]))
			return ValueWv[i] 
		endif
	endfor
	return NaN
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3L_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	variable i
	string FoldernameStr
	switch( ba.eventCode )
		case 2: // mouse up
			SVAR GraphUserTitle=root:Packages:Irena:MultiSamplePlot:GraphUserTitle
			SVAR GraphWindowName=root:Packages:Irena:MultiSamplePlot:GraphWindowName
			// click code here
			if(stringmatch(ba.ctrlname,"NewGraphPlotData"))
				//set some meaningful values for these data first
				IR3L_SetPlotLegends()								
				//Create new graph and append data to graph
				//use $(GraphWindowName) for now... To be changed. 
				//KillWindow/Z $(GraphWindowName)
				IR3L_CreateNewGraph()
				//now, append the data to it... 
				Wave/T ListOfAvailableData = root:Packages:Irena:MultiSamplePlot:ListOfAvailableData
				Wave SelectionOfAvailableData = root:Packages:Irena:MultiSamplePlot:SelectionOfAvailableData	
				for(i=0;i<numpnts(ListOfAvailableData);i+=1)
					if(SelectionOfAvailableData[i]>0.5)
						IR3L_AppendData(ListOfAvailableData[i])
					endif
				endfor
				DoUpdate 
				IR3L_ApplyPresetFormating(GraphWindowName)
			endif
			if(stringmatch(ba.ctrlName,"SelectAll"))
				Wave/Z SelectionOfAvailableData = root:Packages:Irena:MultiSamplePlot:SelectionOfAvailableData
				if(WaveExists(SelectionOfAvailableData))
					SelectionOfAvailableData=1
				endif
			endif
			//*****************
		  	//rest here needs sensible graph... abort if GraphWindowName is not right
		  	if(strlen(GraphWindowName)<1)	//name has any length	
		  		return 0
			endif		  	
			if(stringmatch(ba.ctrlname,"AppendPlotData"))
				//append data to graph
				DoWIndow $(GraphWindowName)
				if(V_Flag==0)
					//IR3L_CreateNewGraph()
					print "could not find graph we can control"
				endif
				Wave/T ListOfAvailableData = root:Packages:Irena:MultiSamplePlot:ListOfAvailableData
				Wave SelectionOfAvailableData = root:Packages:Irena:MultiSamplePlot:SelectionOfAvailableData	
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
				IN2G_OpenWebManual("Irena/Plotting.html#plotting-tool-3")
			endif
			if(cmpstr(ba.ctrlname,"ExportGraphJPG")==0)
				//append data to graph
				DoWIndow $(GraphWindowName)
				if(V_Flag)
					DoWindow/F $(GraphWindowName)
					SavePICT/E=-6/B=288	as (GraphUserTitle)				//this is jpg
					DoWIndow/F IR3L_MultiSamplePlotPanel
				endif
			endif
			if(cmpstr(ba.ctrlname,"ExportGraphTif")==0)
				DoWIndow $(GraphWindowName)
				if(V_Flag)
					DoWindow/F $(GraphWindowName)
					SavePICT/E=-7/B=288	as (GraphUserTitle)					//this is TIFF
					DoWIndow/F IR3L_MultiSamplePlotPanel
				endif
			endif
			if(cmpstr(ba.ctrlname,"SaveGraphAsFile")==0)
				DoWIndow $(GraphWindowName)
				if(V_Flag)
					DoWindow/F $(GraphWindowName)
					SaveGraphCopy /I /W=$(GraphWindowName)  						//	saves current graph as Igor packed experiment
					//Igor 9: use flag /T=1 and ".h5xp" as the file name extension to save to hdf file
					DoWIndow/F IR3L_MultiSamplePlotPanel
				endif
			endif
			if(stringmatch(ba.ctrlname,"ReverseTraces"))
				//append data to graph
				DoWIndow $(GraphWindowName)
				if(V_Flag)
					IR3L_ReverseTraces(GraphWindowName)
				endif
			endif
			if(stringmatch(ba.ctrlname,"CreateContour"))
				//append data to graph
				DoWIndow $(GraphWindowName)
				if(V_Flag)
					IR3L_ConvertXYto3DPlot(GraphWindowName, "Contour")
				endif
			endif
			if(stringmatch(ba.ctrlname,"CreateWaterFall"))
				//append data to graph
				DoWIndow $(GraphWindowName)
				if(V_Flag)
					IR3L_ConvertXYto3DPlot(GraphWindowName, "Waterfall")
				endif
			endif
			if(stringmatch(ba.ctrlname,"CreateGizmo"))
				//append data to graph
				DoWIndow $(GraphWindowName)
				if(V_Flag)
					IR3L_ConvertXYto3DPlot(GraphWindowName, "Gizmo")
				endif
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
static Function IR3L_CreateNewGraph()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR GraphWindowName=root:Packages:Irena:MultiSamplePlot:GraphWindowName
	SVAR GraphUserTitle=root:Packages:Irena:MultiSamplePlot:GraphUserTitle
	//first create a new GraphWindowName, this is new graph...
	string basename="MultiDataPlot_"
	GraphWindowName = UniqueName(basename, 6, 0)
 	Display /K=1/W=(200,30,1000,730) as GraphUserTitle
 	DoWindow/C $(GraphWindowName)
 	AutoPositionWindow /M=0 /R=IR3L_MultiSamplePlotPanel $(GraphWindowName)
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function IR3L_SetAndApplyStyle(WHichStyle)	
	string WHichStyle
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//	ListOfDefinedStyles = "Log-Log;Lin-Log;VolumeSizeDistribution;NumberSizeDistribution;"
		SVAR GraphWindowName=root:Packages:Irena:MultiSamplePlot:GraphWindowName
		NVAR LogXAxis=root:Packages:Irena:MultiSamplePlot:LogXAxis
		NVAR LogYAxis=root:Packages:Irena:MultiSamplePlot:LogYAxis
		NVAR Colorize=root:Packages:Irena:MultiSamplePlot:Colorize
		NVAR AddLegend=root:Packages:Irena:MultiSamplePlot:AddLegend
		SVAR XAxisLegend=root:Packages:Irena:MultiSamplePlot:XAxisLegend
		SVAR YAxislegend=root:Packages:Irena:MultiSamplePlot:YAxislegend	
		SVAR GraphUserTitle=root:Packages:Irena:MultiSamplePlot:GraphUserTitle
		NVAR LineThickness = root:Packages:Irena:MultiSamplePlot:LineThickness
		NVAR UseSymbols = root:Packages:Irena:MultiSamplePlot:UseSymbols
		NVAR UseLines = root:Packages:Irena:MultiSamplePlot:UseLines
		NVAR SymbolSize = root:Packages:Irena:MultiSamplePlot:SymbolSize
		NVAR LegendSize = root:Packages:Irena:MultiSamplePlot:LegendSize
		NVAR UseOnlyFoldersInLegend = root:Packages:Irena:MultiSamplePlot:UseOnlyFoldersInLegend

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
	elseif(stringmatch(WHichStyle,"Lin-Lin"))
		LogXAxis = 0
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
static Function IR3L_ReverseTraces(GraphNameString)
		string GraphNameString
		String tlist = tracenameList(GraphNameString, ";", 1)
		Variable i
		//Variable start = StopMSTimer(-2)
		WAVE/T traceNameListWave = ListToTextWave(tlist, ";")
		Variable nt = numpnts(traceNameListWave)
		//for (i = nt-1; i >= 0; i--)
		//per Adam WM seems 15% faster in this order... 
		for (i = 0; i < nt; i++)
			String oneTrace = traceNameListWave[i]
			//ReorderTraces/W=$GraphNameString _front_, {$oneTrace}
			ReorderTraces/W=$GraphNameString _back_, {$oneTrace}
		endfor
		//printf "Took %g for %d traces.\r", (StopMSTimer(-2)-start)/1e6, nt
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function IR3L_ApplyPresetFormating(GraphNameString)
		string GraphNameString

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if(strlen(GraphNameString)<1)
		return 0
	endif
	DoWIndow $(GraphNameString)
	if(V_Flag)
		NVAR LogXAxis=root:Packages:Irena:MultiSamplePlot:LogXAxis
		NVAR LogYAxis=root:Packages:Irena:MultiSamplePlot:LogYAxis
		NVAR Colorize=root:Packages:Irena:MultiSamplePlot:Colorize
		NVAR AddLegend=root:Packages:Irena:MultiSamplePlot:AddLegend
		SVAR XAxisLegend=root:Packages:Irena:MultiSamplePlot:XAxisLegend
		SVAR YAxislegend=root:Packages:Irena:MultiSamplePlot:YAxislegend	
		SVAR GraphUserTitle=root:Packages:Irena:MultiSamplePlot:GraphUserTitle
		NVAR LineThickness = root:Packages:Irena:MultiSamplePlot:LineThickness
		NVAR UseSymbols = root:Packages:Irena:MultiSamplePlot:UseSymbols
		NVAR UseLines = root:Packages:Irena:MultiSamplePlot:UseLines
		NVAR SymbolSize = root:Packages:Irena:MultiSamplePlot:SymbolSize
		NVAR LegendSize = root:Packages:Irena:MultiSamplePlot:LegendSize
		NVAR UseOnlyFoldersInLegend = root:Packages:Irena:MultiSamplePlot:UseOnlyFoldersInLegend
		NVAR DisplayErrorBars = root:Packages:Irena:MultiSamplePlot:DisplayErrorBars
		//mirror axis when needed, but do not choke on graphs with more axis...
		if(ItemsInList(AxisList(GraphNameString))<3)
			ModifyGraph/W= $(GraphNameString)/Z  mirror=1
		endif
		DoWIndow/F $(GraphNameString)
		IN2G_ShowHideErrorBars(DisplayErrorBars, topGraphStr=GraphNameString)
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
		NVAR XOffset=root:Packages:Irena:MultiSamplePlot:XOffset
		NVAR YOffset=root:Packages:Irena:MultiSamplePlot:YOffset
		NVAR LogXAxis=root:Packages:Irena:MultiSamplePlot:LogXAxis
		NVAR LogYAxis=root:Packages:Irena:MultiSamplePlot:LogYAxis
		IN2G_OffsetTopGrphTraces(LogXAxis, XOffset ,LogYAxis, YOffset)


		TextBox/W=$(GraphNameString)/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()		
	
		DoWIndow/F IR3L_MultiSamplePlotPanel

	endif
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3L_SetPlotLegends()				//this function will set axis legends and otehr stuff based on waves
		//applies only when creating new graph...

		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		NVAR UseIndra2Data=root:Packages:Irena:MultiSamplePlot:UseIndra2Data
		NVAR UseQRSdata=root:Packages:Irena:MultiSamplePlot:UseQRSdata
		NVAR  UseResults=  root:Packages:Irena:MultiSamplePlot:UseResults
		NVAR  UseUserDefinedData=  root:Packages:Irena:MultiSamplePlot:UseUserDefinedData
		NVAR  UseModelData = root:Packages:Irena:MultiSamplePlot:UseModelData
		
		SVAR XAxisLegend=root:Packages:Irena:MultiSamplePlot:XAxisLegend
		SVAR YAxislegend=root:Packages:Irena:MultiSamplePlot:YAxislegend	
		SVAR GraphUserTitle=root:Packages:Irena:MultiSamplePlot:GraphUserTitle
		SVAR GraphWindowName=root:Packages:Irena:MultiSamplePlot:GraphWindowName
		SVAR DataFolderName  = root:Packages:Irena:MultiSamplePlot:DataFolderName 
		SVAR IntensityWaveName = root:Packages:Irena:MultiSamplePlot:IntensityWaveName
		SVAR QWavename = root:Packages:Irena:MultiSamplePlot:QWavename
		SVAR ErrorWaveName = root:Packages:Irena:MultiSamplePlot:ErrorWaveName
		SVAR DataSubType = root:Packages:Irena:MultiSamplePlot:DataSubType
		SVAR SelectedResultsTool = root:Packages:Irena:MultiSamplePlot:SelectedResultsTool
		SVAR SelectedResultsType = root:Packages:Irena:MultiSamplePlot:SelectedResultsType
		SVAR ResultsGenerationToUse = root:Packages:Irena:MultiSamplePlot:ResultsGenerationToUse
		
		string yAxisUnits="arbitrary"
		string xAxisUnits = ""
		variable CanDoLinearization = 0
		string InputDataType=""
		//now, what can we do about naming this for users....
		if(UseIndra2Data)
			IntensityWaveName = DataSubType
			Wave/Z SourceIntWv=$(DataFolderName+possiblyQUoteName(IntensityWaveName))
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
				CanDoLinearization = 1
				InputDataType="USAXS desmeared data"
			elseif(StringMatch(DataSubType, "SMR_Int" ))
				GraphUserTitle = "USAXS slit smeared data"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity ["+yAxisUnits+"]"
				InputDataType="USAXS slit smeared data"
			elseif(StringMatch(DataSubType, "Blank_R_int" ))
				GraphUserTitle = "USAXS Blank R Intensity"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity"
				InputDataType="USAXS Blank data"
			elseif(StringMatch(DataSubType, "R_int" ))
				GraphUserTitle = "USAXS R Intensity"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity [normalized, arbitrary]"
				InputDataType="USAXS R intensity data"
			elseif(StringMatch(DataSubType, "USAXS_PD" ))
				GraphUserTitle = "USAXS Diode Intensity"
				XAxisLegend = "AR angle [degrees]"
				YAxislegend = "Diode Intensity [not normalized, arbitrary counts]"
				InputDataType="USAXS Diode intensity data"
			elseif(StringMatch(DataSubType, "Monitor" ))
				GraphUserTitle = "USAXS I0 Intensity"
				XAxisLegend = "AR angle [degrees]"
				YAxislegend = "I0 Intensity [not normalized, counts]"
				InputDataType="USAXS I0 intensity data"
			else
				GraphUserTitle = "USAXS data"
				XAxisLegend = ""
				YAxislegend = ""			
				InputDataType="USAXS data"
			endif
		elseif(UseQRSdata)
				GraphUserTitle = "SAXS/WAXS data"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity [arb]"
				CanDoLinearization = 1
				InputDataType="QRS data"
		elseif(UseResults)
			//	AllKnownToolsResults = "Unified Fit;Size Distribution;Modeling;Modeling I;Small-angle diffraction;Analytical models;Fractals;PDDF;Reflectivity;Guinier-Porod;Evaluate Size Dist;"
			if(StringMatch(SelectedResultsTool, "Unified Fit" ))
				GraphUserTitle = "Unified Fit results"
				if(StringMatch(SelectedResultsType, "*SizeDistVol*" ))
					XAxisLegend = "Size [A]"
					YAxislegend = "Volume Fraction [arbitrary]"
				elseif(StringMatch(SelectedResultsType, "*SizeDistNum*" ))
					XAxisLegend = "Size [A]"
					YAxislegend = "Number Fraction [arbitrary]"
				endif
				InputDataType="Unified fit results"
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
				InputDataType="Size distribution results"
			elseif(StringMatch(SelectedResultsTool, "Modeling" ))
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
				InputDataType="Modeling results"
			elseif(StringMatch(SelectedResultsTool, "PDDF" ))
				GraphUserTitle = "PDDF results"
				XAxisLegend = "Radius [A]"
				YAxislegend = "PDDF [arb]"
				if(StringMatch(SelectedResultsType, "PDDFDistFunction" ))
					XAxisLegend = "Radius [A]"
					YAxislegend = "PDDF"
				elseif(StringMatch(SelectedResultsType, "PDDFGammaFunction" ))
					XAxisLegend = "Radius [A]"
					YAxislegend = "Gamma"
				elseif(StringMatch(SelectedResultsType, "PDDFIntensity" ))
					XAxisLegend = "Q [A\S-1\M]"
					YAxislegend = "Intensity [arb]"
				elseif(StringMatch(SelectedResultsType, "PDDFChiSquared" ))
					XAxisLegend = "Radius [A]"
					YAxislegend = "Chi\S2"
				endif
				InputDataType="Modeling results"
			elseif(StringMatch(SelectedResultsTool, "Small-angle diffraction" ))
				GraphUserTitle = "Small-angle diffraction results"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity [arb]"
				InputDataType="Small-angle diffraction results"
			elseif(StringMatch(SelectedResultsTool, "Analytical models" ))
				GraphUserTitle = "Analytical models results"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity [arb]"
				InputDataType="Analytical models results"
			elseif(StringMatch(SelectedResultsTool, "Fractals" ))
				GraphUserTitle = "Fractals results"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity [arb]"
				InputDataType="Fractals results"
			elseif(StringMatch(SelectedResultsTool, "Reflectivity" ))
				GraphUserTitle = "Reflectivity results"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity [arb]"
				InputDataType="Reflectivity results"
			elseif(StringMatch(SelectedResultsTool, "Guinier-Porod" ))
				GraphUserTitle = "Guinier-Porod results"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity [arb]"
				InputDataType="Guinier-Porod results"
			elseif(StringMatch(SelectedResultsTool, "Evaluate Size Dist" ))
					if(StringMatch(SelectedResultsType, "*CumulativeSizeDist*" ))
					GraphUserTitle = "SSA from Evaluate Size Dist"
					XAxisLegend = "Diameter [A]"
					YAxislegend = "Cumulative Volume [cm\S3\M/cm\S3\M]"
					InputDataType="Cumulative Volume from Evaluate Size Dist"
				elseif(StringMatch(SelectedResultsType, "*CumulativeSfcArea*" ))
					GraphUserTitle = "Cumulative Volume from Evaluate Size Dist"
					XAxisLegend = "Diameter [A]"
					YAxislegend = "Cumulative Specific surface area [cm\S2\M/cm\S3\M]"
					InputDataType="SSA from Evaluate Size Dist"
				elseif(StringMatch(SelectedResultsType, "*MIPVolume*" ))
					GraphUserTitle = "MIP from Evaluate Size Dist"
					XAxisLegend = "Pressure [Psi]"
					YAxislegend = "Intruded Volume [cm\S3\M / cm\S3\M]"
					InputDataType="MIP from Evaluate Size Dist"
				endif
			endif

		else
				GraphUserTitle = "Arbitrary data Plot"
				XAxisLegend = "X"
				YAxislegend = "Y"
				InputDataType="User selected"
		endif
		//now, this is for standard X-Y data. Next we need to deal with option to plot linearization plots...
	
		SVAR SelectedDataPlot=root:Packages:Irena:MultiSamplePlot:SelectedDataPlot
		//	ListOfDefinedDataPlots = "X-Y (q-Int, etc.);Guinier (Q^2-ln(I));Kratky (Q-IQ^2);Porod (Q^4-IQ^4);"
		strswitch(SelectedDataPlot)						// string switch
			case "X-Y (q-Int, etc.)":				// execute if case matches expression
				//nothing to do... 
				//this was sorted out above... 
				break										// exit from switch
			case "Guinier (Q^2-ln(I))":				// execute if case matches expression
				//create and save Guinier data
				GraphUserTitle = "Guinier Plot for data"
				XAxisLegend = "Q\S2\M [A\S-2\M]"
				YAxislegend = "ln(Intensity)"
				break
			case "Guinier Rod (Q^2-ln(I*Q))":				// execute if case matches expression
				//create and save Guinier data
				GraphUserTitle = "Guinier Plot for data"
				XAxisLegend = "Q\S2\M [A\S-2\M]"
				YAxislegend = "ln(Intensity*Q)"
				break
			case "Guinier Sheet (Q^2-ln(I*Q^2))":				// execute if case matches expression
				//create and save Guinier data
				GraphUserTitle = "Guinier Plot for data"
				XAxisLegend = "Q\S2\M [A\S-2\M]"
				YAxislegend = "ln(Intensity*Q^2)"
				break
			case "Kratky (Q-IQ^2)":					// execute if case matches expression
				//create and save Kratky data
				GraphUserTitle = "Kratky Plot for data"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity*Q\S2\M"
				break
			case "DimLess Kratky (Q-I*(Q*Rg)^2/I0)":					// execute if case matches expression
				//create and save Kratky data
				GraphUserTitle = "Dimension less Kratky Plot for data"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity/I0*(QRg)\S2\M"
				break
			case "Porod (Q^4-IQ^4)":					// execute if case matches expression
				//create and save Porod data
				GraphUserTitle = "Porod Plot for data"
				XAxisLegend = "Q\S4\M [A\S-4\M]"
				YAxislegend = "Intensity*Q\S4\M"
				break
			case "Porod 2 (Q-IQ^4)":					// execute if case matches expression
				//create and save Porod data
				GraphUserTitle = "Modified Porod Plot for data"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity*Q\S4\M"
				break
			case "Porod 3 (Q-IQ^3)":					// execute if case matches expression
				//create and save Porod data
				GraphUserTitle = "Modified Porod Plot for data"
				XAxisLegend = "Q [A\S-1\M]"
				YAxislegend = "Intensity*Q\S3\M"
				break
			default:										// optional default expression executed, this is basically X-Y case again
															// when no case matches
		endswitch

		if(	!CanDoLinearization && !StringMatch(SelectedDataPlot, "X-Y (q-Int, etc.)"))					//abort and warn user, if linearization plots are nto possible... 
			Abort "Selected input data type is not compatible with selected plot type. Cannot create "+SelectedDataPlot+" for "+InputDataType+"  Linearization plots are only for QRS and USAXS desmeared data"
		endif
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3L_ConvertXYto3DPlot(string WindowName, string WhichGraph)
	//WhichGraph = Contour, Waterfall or GizmoPlot. 
	//this will take X-Y plot with more than 5 waves
	//create data for Waterfall or countour plots, 
	//save in root:MultiDataPlot3DPlots:ContourPlotX
	//and display contour plot. 
	//attach bar with controls using functions in this package.  
	//step 1 Check the top graph if it makes any sense... 
	//   John Weeks suggestion: 
	//TraceInfo has the keyword TYPE:
	//TYPE    Gives the type of trace:
	//    0: XY or waveform trace
	//    1: Contour trace
	//    2: Box plot trace
	//    3: Violin plot trace
	//    TYPE was added in Igor Pro 8.00.
	//So a value of zero is what you're looking for; to get XY or Waveform you then need to check the XWAVE keyword
	// 
	if(strlen(WindowName)==0)
		print "No Graph widnow specified"
		abort
	endif
	DoWIndow $(WindowName)
	if(!V_Flag)
		print "No Graph widnow specified"
		abort 
	endif
	if(WinType(WindowName)!=1)
		print "This is NOT Graph widnow"
		abort 
	endif
	//string RecString=WinRecreation(WindowName, 0 )
	//print RecString
	string axisListStr=AxisList(WindowName )
	if(ItemsInList(axisListStr)!=2)
		print "This works only for XY graphs with two axes, this is not correct graph type"
		abort
	endif
	string XaxisName, YAxisName, XAxisInfo, YAxisInfo, XAxisLabel
	XaxisName = SelectString(StringMatch(axisListStr, "*bottom*" ), "top", "bottom" ) 
	YaxisName = SelectString(StringMatch(axisListStr, "*left*" ), "right", "left" )  
	if(strlen(XaxisName)<1 || strlen(YaxisName)<1)
		print "The graph needs to use regular X and Y axes left, right, bottom top, this one is wrong"
		abort
	endif
	XAxisInfo = AxisInfo(WindowName, XaxisName )
	variable XisLog = NumberByKey("log(x)", XAxisInfo, "=", ";")
	YAxisInfo = AxisInfo(WindowName, YaxisName )
	variable YisLog = NumberByKey("log(x)", YAxisInfo, "=", ";")
	//need to get label from bottom axis here.
	//Label left "Intensity [arb]"
	//Label bottom "Q [A\\S-1\\M]"
	//string OldClipb = GetScrapText()
	//PutScrapText WinRecreation(WindowName, 0 )
	//Grep /E={"bottom|top",0}/Q/LIST "Clipboard"
	//XAxisLabel = S_value[strsearch(S_value, "\"", 0)+1, strsearch(S_value, "\"", strlen(S_value)-1,1 )-1]
	//XAxisLabel = ReplaceString("\\\\", XAxisLabel, "\\")
	XAxisLabel = IN2G_ReturnLabelForAxis(WindowName, "bottom|top")
	string TraceNameListStr =  TraceNameList(WindowName, ";", 1)
	if(NumberByKey("TYPE", TraceInfo(WindowName, StringFromList(0, TraceNameListStr), 0 ))!=0 || strlen(StringByKey("XWAVE", TraceInfo(WindowName, StringFromList(0, TraceNameListStr), 0 )))<1)
		print "This is NOT correct graph type"
		abort
	endif
	variable NumWaves=ItemsInList(TraceNameListStr)
	if(NumWaves<5)
		print "Contour plots needs at least 5 waves, the graph has less"
		abort
	endif
	//OK, by now we should have meaningful graph to work with. 
	//Next lets get idea what are we going to do. 
	// Ranges of axes. For Contour plot in our case : 
	// x axis is where we read the range from graph
	// y axis is simply number of waves in the graph, scaled by user conversion factor 
	// z range is range of data, but read from the graph so we retain user scaling. 
	GetWindow  $WindowName  title 
	string ExistingGraphTitle=S_value
	variable xmin, xmax, xnum, ymin, ymax, ynum, zmin, zmax, znum
	variable i, j 
	GetAxis /W=$WindowName/Q $XaxisName
	xmin = V_min
	xmax = V_max
	GetAxis /W=$WindowName/Q $YaxisName
	zmin = V_min
	zmax = V_max
	ymin = 0
	ymax = NumWaves
	//now we need to create location for data...
	DFref OldDf=GetDataFolderDFR()
	NewDataFolder/S/O root:MultiDataPlot3DPlots
	string NewGraphName = UniqueName(WhichGraph+"Plot" , 11, 0)
	string NewFldrName = "root:MultiDataPlot3DPlots:"+NewGraphName
	NewDataFolder/S/O $(NewFldrName)
	//now we need to create here the data. 
	//first we need to know how many intervals in x we need. But to make this simple, let's skip this
	//we need to create main x axis here, let's pick x axis for data set 1 and use its visible range
	Wave FirstXwave= XWaveRefFromTrace(WindowName, StringFromList(0, TraceNameListStr))
	variable startx, starty
	startx = BinarySearch(FirstXwave, xmin )
	starty = BinarySearch(FirstXwave, xmax )			
	//this lookup needs bit cleaning
	startx = (startx >=0) ? startX : 0
	starty = (starty <= numpnts(FirstXwave) && starty>0) ? starty : numpnts(FirstXwave)-1
	Duplicate/O/R=(startx,starty) FirstXwave, xWaveValues
	Make/O/N=(NumWaves) yWaveValues
	yWaveValues = p
	Duplicate/Free xWaveValues, tempYWaveIntp
	Make/O/N=((starty-startx+1),NumWaves) MultiDataPlot3DWvData
	variable StartP, EndP, MaxP=numpnts(tempYWaveIntp)-1
	variable StartXTemp = xWaveValues[0]
	variable EndXTemp   = xWaveValues[numpnts(xWaveValues)-1]
	For(i=0;i<NumWaves;i+=1)
		Wave TempXwave= XWaveRefFromTrace(WindowName, StringFromList(i, TraceNameListStr))
		Wave TempYwave= TraceNameToWaveRef(WindowName, StringFromList(i, TraceNameListStr))
		tempYWaveIntp = nan							//fill with NaNs
		//find where to start on low-end... 
		StartP = BinarySearch(xWaveValues, TempXwave[0])>=0 ? BinarySearch(xWaveValues, TempXwave[0])+1 : 0																//BinarySearch(xWaveValues, TempXwave[0]+1)
		EndP = BinarySearch(xWaveValues, TempXwave[numpnts(TempXwave)-1])>0 ? BinarySearch(xWaveValues, TempXwave[numpnts(TempXwave)-1]) : MaxP				//BinarySearch(xWaveValues, TempXwave[numpnts(TempXwave)-1]+1) 
		//this may fail if we start asking for values out of range for these data,
		multithread tempYWaveIntp[StartP,EndP] = interp(xWaveValues[p], TempXwave, TempYwave)		 
		//there is nothing in the manual about this... 
		MultiDataPlot3DWvData[][i]=tempYWaveIntp[p]
	endfor
	Duplicate/O MultiDataPlot3DWvData, MultiDataPlot3DWvDataRaw			//this is copy of data for smoothing operation, 

	if(StringMatch(WhichGraph, "Contour"))
		make/O/N=(7) CountourPlot_left_values
		make/O/N=(7)/T CountourPlot_left_labels
		//create needed global variables for controls... 
		variable/g NumCountours=100
		variable/g MinCountourVal=zmin
		variable/g MaxCountourVal=zmax
		String/G ContourColorScale = "Rainbow"
		variable/g Graph3DColorsReverse = 1
		variable/g ContSmoothOverValue = 0
		variable/g ContLogColors = YisLog
		variable/g ContLogContours = YisLog
		variable/g ContUseOnlyRedColor = 0
		variable/g ContDisplayContValues = 0
		variable/g ContYWaveScaling = 1
		variable/g ContYWaveIntervals = 7
		variable/g ContLogXAxis = XisLog
		variable StepVal = floor((NumWaves-1)/(ContYWaveIntervals-1))
		CountourPlot_left_values = 0 + p*StepVal
		CountourPlot_left_labels =  num2str(CountourPlot_left_values)
		
		NewFldrName = NewFldrName+":"
		SVAR Graph3DColorScale = $(NewFldrName+"ContourColorScale")
		NVAR ContSmoothOverValue = $(NewFldrName+"ContSmoothOverValue")
		//ando now create the graph
		Display /K=1/W=(405,467,1100,1050)/N=$(NewGraphName) as NewGraphName+" of "+ExistingGraphTitle
		AppendMatrixContour MultiDataPlot3DWvData vs {xWaveValues,yWaveValues}
		ModifyGraph userticks(left)={CountourPlot_left_values,CountourPlot_left_labels}
		ModifyGraph mirror=2
		ControlBar /T/W=$(NewGraphName) 60
		SetVariable ContNumCountours,pos={10,1},size={160,15},title="Num. contours ",bodyWidth=70
		SetVariable ContNumCountours, proc=IR3L_ContSetVarProc, help={"Number of contours to use"}
		SetVariable ContNumCountours,limits={11,100,5},value= $(NewFldrName+"NumCountours")
		SetVariable ContMinValue,pos={10,20},size={160,15},title="Min Contour val ",bodyWidth=70
		SetVariable ContMinValue, proc=IR3L_ContSetVarProc, help={"Value of minimum Contour"}, format="%3.3g"	
		SetVariable ContMinValue,limits={0,inf,0},value= $(NewFldrName+"MinCountourVal") 
		SetVariable ContMaxValue,pos={10,39},size={160,15},title="Max Contour val ",bodyWidth=70
		SetVariable ContMaxValue, proc=IR3L_ContSetVarProc, help={"Value of Max Contour"}
		SetVariable ContMaxValue,limits={0,inf,0},value= $(NewFldrName+"MaxCountourVal"), format="%3.3g"	
		SetVariable ContYWaveScaling,pos={180,1},size={150,15},title="Y axis scale ",bodyWidth=70
		SetVariable ContYWaveScaling, proc=IR3L_ContSetVarProc, help={"Step on Y axis"}
		SetVariable ContYWaveScaling,limits={0,inf,0},value= $(NewFldrName+"ContYWaveScaling"), format="%3.3g"	
		SetVariable ContYWaveIntervals,pos={180,20},size={150,15},title="Y axis scale ",bodyWidth=70
		SetVariable ContYWaveIntervals, proc=IR3L_ContSetVarProc, help={"Y axis ticks"}
		SetVariable ContYWaveIntervals,limits={3,inf,1},value= $(NewFldrName+"ContYWaveIntervals"), format="%3.3g"	
		Checkbox ContLogXAxis, pos={260,39}, title="Log(X)?", size={100,15}, variable=$(NewFldrName+"ContLogXAxis"), proc=IR3L_ContCheckProc
	
		Checkbox ContDisplayContValues, pos={340,3}, title="Labels?", size={100,15}, variable=$(NewFldrName+"ContDisplayContValues"), proc=IR3L_ContCheckProc
		Checkbox ContLogColors, pos={410,3}, title="Log colors?", size={100,15}, variable=$(NewFldrName+"ContLogColors"), proc=IR3L_ContCheckProc
		Checkbox ContLogContours, pos={510,3}, title="Log contours?", size={100,15}, variable=$(NewFldrName+"ContLogContours"), proc=IR3L_ContCheckProc
		Checkbox Graph3DColorsReverse, pos={610,30}, title="Reverse Clr?", size={100,15}, variable=$(NewFldrName+"Graph3DColorsReverse"), proc=IR3L_ContCheckProc
		Checkbox ContUseOnlyRedColor, pos={610,3}, title="Only red?", size={100,15}, variable=$(NewFldrName+"ContUseOnlyRedColor"), proc=IR3L_ContCheckProc
	
		PopupMenu ColorTable,pos={330,30},size={150,20},title="Colors:", help={"Select color table"}
		PopupMenu ColorTable,mode=1,popvalue=Graph3DColorScale,value= #"CTabList()", bodyWidth=100, proc=IR3L_ContPopMenuProc
		PopupMenu SmoothOverValue,pos={450,30},size={150,20},title="Smooth val:", help={"Smooth value"}, proc=IR3L_ContPopMenuProc
		PopupMenu SmoothOverValue,mode=1,popvalue=num2str(ContSmoothOverValue),value= "0;3;5;9;", bodyWidth=40
		//And now basic setup
		IR3L_FormatContourPlot(NewGraphName)
		ModifyContour /W=$(NewGraphName) MultiDataPlot3DWvData labels=0,fill=0
		Label /W=$(NewGraphName) bottom XAxisLabel
		ModifyGraph log(bottom)=XisLog
	elseif(StringMatch(WhichGraph, "Waterfall"))
		//globals are cretaed here...
		string/g Graph3DColorScale = "Rainbow"
		string/g Graph3DVisibility = "Off"
		variable/g Graph3DAngle = 30
		variable/g Graph3DAxLength = 0.3
		variable/g Graph3DLogColors = 0
		variable/g Graph3DColorsReverse = 0
		variable/g Graph3DClrMin = zmin
		variable/g Graph3DClrMax = zmax
		
		//and now the graph
		NewWaterfall/W=(405,467,950,900) /K=1/N=$NewGraphName MultiDataPlot3DWvData vs {xWaveValues,*} as NewGraphName+" of "+ExistingGraphTitle
		ControlBar /T/W=$NewGraphName 50
		pauseUpdate
		//Angle, colorscale, ax length
		PopupMenu ColorTableWf,pos={140,5},size={150,20},title="Colors:", proc=IR3L_ContPopMenuProc, help={"Select color table"}
		PopupMenu ColorTableWf,mode=1,popvalue=Graph3DColorScale,value= #"CTabList()", bodyWidth=100
		PopupMenu Graph3DVisibilityWf,pos={140,30},size={150,20},title="Hidden lines:", bodyWidth=100, proc=IR3L_ContPopMenuProc
		PopupMenu Graph3DVisibilityWf,mode=1,popvalue=Graph3DVisibility,value= #"\"Off;Painter;True;No bottom;Color bottom\""
		SetVariable angVar,size={120,15},pos={10,5},bodyWidth=50,title="Angle"
		SetVariable angVar,format="%.1f", proc=IR3L_ContSetVarProc, help={"Change angle of the slant"}
		SetVariable angVar,limits={10,90,1},value= $(NewFldrName+":Graph3DAngle")
		SetVariable alenVar,pos={10,30},size={120,15},bodyWidth=50,title="Axis Length"
		SetVariable alenVar,format="%.2f", proc=IR3L_ContSetVarProc, help={"change length of slanted axis"}
		SetVariable alenVar,limits={0.1,0.9,0.05},value= $(NewFldrName+":Graph3DAxLength")
		Checkbox Graph3DLogColors, pos={420,10}, title="Log Colors?", size={80,15}, variable=$(NewFldrName+":Graph3DLogColors"), proc=IR3L_ContCheckProc
		Checkbox Graph3DColorsReverse, pos={420,30}, title="Reverse Colors?", size={80,15}, variable=$(NewFldrName+":Graph3DColorsReverse"), proc=IR3L_ContCheckProc
	
		Slider /Z Graph3DClrMax  limits = {Graph3DClrMin,Graph3DClrMax,0} , vert=0, pos = {300,10}, size = {100,10}, variable= $(NewFldrName+":Graph3DClrMax")
		Slider /Z Graph3DClrMax proc=IR3L_ContSliderProc,ticks=0, help={"Slide to change color scaling"}, title = "Max"
	
		Slider /Z Graph3DClrMin  limits = {Graph3DClrMin,Graph3DClrMax,0} , vert=0, pos = {300,30}, size = {100,10}, variable= $(NewFldrName+":Graph3DClrMin")
		Slider /Z Graph3DClrMin proc=IR3L_ContSliderProc,ticks=0, help={"Slide to change color scaling"}, title="min"
		//format
		SetAxis/W=$NewGraphName bottom xmin,xmax
		SetAxis/W=$NewGraphName left zmin,zmax
		ModifyGraph/W=$NewGraphName log(bottom)=XisLog
		ModifyWaterfall/W=$NewGraphName  angle=Graph3DAngle, axlen= Graph3DAxLength, hidden= 0
		ModifyGraph /W=$NewGraphName zColor(MultiDataPlot3DWvData)={MultiDataPlot3DWvData,*,*,$(Graph3DColorScale),Graph3DColorsReverse}	
		resumeUpdate
	elseif(StringMatch(WhichGraph, "Gizmo"))
		DoAlert /T="Unfinsihed feature" 0, "This is unfinsihed feature. If you really need to use it, conatct author of the software."
//		if(!IR1P_GizmoFunctionality())
//			Abort "The graphic card of your system is insufficient for Gizmo functionality. You need to get better graphic card before using Gizmo."
//		endif
//		//create  Gizmo related globals here... Using codee from Plotting tool...
//		variable/g GizmoNumLevels = 100
//		variable/g GizmoEstimatedVoronoiTime = 0
//		variable/g GizmoDisplayGrids = 0
//		variable/g GizmoDisplayLabels = 0
//		string/g GizmoYaxisLegend = ""
//		string/g Graph3DColorScale = "Rainbow"
//		NVAR GizmoEstimatedVoronoiTime
//		
//		
//		IR3L_GizmoCreatePanel(NewFldrName)
////		Button GizmoGenerateDataAndGraph,pos={62,80},size={200,15},title="Create 3D data and plot", proc=IR1P_InputPanelButtonProc, help={"Create/Recreate the data and create plot"}
////		Button GizmoReGraph,pos={62,100},size={200,15},title="Recreate 3D plot", proc=IR1P_InputPanelButtonProc,help={"Use old data iof available without recreating them. Create plot. Fast. "}
////		
////		Button UpdateGizmo,pos={62,240},size={200,20},title="Sync w/Main panel", proc=IR1P_InputPanelButtonProc, help={"update to reflect changes made in main panel, such as zoom etc. "}
//		GizmoEstimatedVoronoiTime = IR3L_GuessVoronoiTime(NumWaves, MaxP+1,GizmoNumLevels)
//		
//	
	endif

	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************


//static Function IR3L_GizmoCreatePanel(string NewFldrName)
////GizmoNumLevels
//	DoWindow GizmoControlPanel
//	if(V_Flag)
//		DoWindow/F GizmoControlPanel
//	else
//	
//		NewPanel /K=1/N=GizmoControlPanel/W=(402,44,782,319) as "Irena Gizmo control panel"
//		SetDrawLayer UserBack
//		SetDrawEnv fsize= 14,fstyle= 3,textrgb= (0,0,65535)
//		DrawText 87,28,"Irena \"Gizmo\" 3D plot panel"
//		SetVariable GizmoNumLevels,pos={13,37},size={200,15},title="Number of q points", help={"Number of points in Q rto be calculated"}
//		SetVariable GizmoNumLevels,value= $(NewFldrName+":GizmoNumLevels"), limits={10,500,25}
//		SetVariable GizmoNumLevels proc=IR1P_GizmoSetVarProc
//		SetVariable GizmoEstimatedVoronoiTime,pos={13,60},size={300,15},title="Estimated Calculation time [sec]   ", help={"Wild guess how long the Data preparation will take"}
//		SetVariable GizmoEstimatedVoronoiTime,value= $(NewFldrName+":GizmoEstimatedVoronoiTime")
//		SetVariable GizmoEstimatedVoronoiTime noedit=1,fstyle=2,valueColor=(65535,0,0),limits={-inf,inf,0}, frame=0
//
//	
//		Button GizmoGenerateDataAndGraph,pos={62,80},size={200,15},title="Create 3D data and plot", proc=IR1P_InputPanelButtonProc, help={"Create/Recreate the data and create plot"}
//		Button GizmoReGraph,pos={62,100},size={200,15},title="Recreate 3D plot", proc=IR1P_InputPanelButtonProc,help={"Use old data iof available without recreating them. Create plot. Fast. "}
//	
//		CheckBox GizmoDisplayGridLines title="Grid lines?",proc=IR1P_GizmoCheckProc, pos={10,130}, help={"Display grid lines"}
//		CheckBox GizmoDisplayGridLines variable=$(NewFldrName+":GizmoDisplayGrids")
//		CheckBox GizmoDisplayLabels title="Axes lables?",proc=IR1P_GizmoCheckProc, pos={10,150},help={"Display legends, uses legends from main tool"}
//		CheckBox GizmoDisplayLabels variable=$(NewFldrName+"::GizmoDisplayLabels")
//	
//		SetVariable GizmoYaxisLegend,pos={120,150},size={250,15},title="Data order legend", help={"Text to be used on data order axis"}
//		SetVariable GizmoYaxisLegend,value= $(NewFldrName+":GizmoYaxisLegend"), limits={-inf,inf,0}
//		SetVariable GizmoYaxisLegend proc=IR1P_GizmoSetVarProc
//	
//		PopupMenu ColorTable,pos={15,180},size={180,20},title="Colors:", proc=IR1P_Gizmo_PopMenuProc, help={"Select color table"}
//		SVAR Graph3DColorScale=$(NewFldrName+":Graph3DColorScale")
//		PopupMenu ColorTable,mode=1,popvalue=Graph3DColorScale,value= #"CTabList()", bodyWidth=150
//	
//		Button UpdateGizmo,pos={62,240},size={200,20},title="Sync w/Main panel", proc=IR1P_InputPanelButtonProc, help={"update to reflect changes made in main panel, such as zoom etc. "}
//		// add Gizmo procedures
//		Execute/P "INSERTINCLUDE <All Gizmo Procedures>"
//		Execute/P "COMPILEPROCEDURES "
//		
//	endif
//	SetWindow GizmoControlPanel, hook(GizmoHook)= IR1P_GizmoHookFunction
//	AutoPositionWindow/M=0/R=IR3L_MultiSamplePlotPanel GizmoControlPanel
//	DoWIndow Irena_Gizmo
//	if(V_Flag)
//		AutoPositionWindow/M=1/R=GizmoControlPanel  Irena_Gizmo
//	endif
//end
////*************************************************************************************************************
////*************************************************************************************************************
//
//static Function IR3L_GuessVoronoiTime(NumWave, NumPoints, NumLevels)
//	variable NumWave, NumPoints, NumLevels
//	//	t=k1*(Ninp^2)+k3*Ninp*(Nx*Ny)
//	//count Ninp
//	variable NumberOfWaves,i, Ninp, Nx, Ny
//	Ninp=NumPoints
//	Nx=NumLevels
//	Ny=NumWave
//	
//	variable TriangK=2.111e-08
//	variable CalcK=4.50514e-08
//	variable result=TriangK*Ninp^2 + CalcK*Ninp*Nx*Ny
//	return result
//end
//**********************************************************************************************************
//**********************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function IR3L_ContSliderProc(sa) : SliderControl
	STRUCT WMSliderAction &sa

	string Foldername
	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			Foldername = "root:MultiDataPlot3DPlots:"+sa.win
			if(!DataFolderExists(Foldername))
				return 0
			endif
			//Waterfall controls
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				NVAR Graph3DClrMax = $(Foldername+":Graph3DClrMax")
				NVAR Graph3DClrMin = $(Foldername+":Graph3DClrMin")
				SVAR Graph3DColorScale=$(Foldername+":Graph3DColorScale")
				NVAR Graph3DColorsReverse=$(Foldername+":Graph3DColorsReverse")
				WAVE MultiDataPlot3DWvData = $(Foldername+":MultiDataPlot3DWvData")
				ModifyGraph zColor(MultiDataPlot3DWvData)={MultiDataPlot3DWvData,Graph3DClrMin,Graph3DClrMax,$(Graph3DColorScale),Graph3DColorsReverse}	
			endif
			break
	endswitch

	return 0
End

//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
Function IR3L_ContCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	string Foldername
	switch( cba.eventCode )
		case 2: // mouse up
			Foldername = "root:MultiDataPlot3DPlots:"+cba.win
			if(!DataFolderExists(Foldername))
				return 0
			endif
			Variable checked = cba.checked
			if(stringmatch(cba.ctrlName,"ContDisplayContValues"))
				//NVAR ContMinValue = $(Foldername+":MinCountourVal")
				//NVAR ContMaxValue = $(Foldername+":MaxCountourVal")
				//NVAR ContLogColors = $(Foldername+":ContLogColors")
				//NVAR ContUseOnlyRedColor = $(Foldername+":ContUseOnlyRedColor")
				//SVAR Graph3DColorScale = $(Foldername+":ContourColorScale")
				//Wave MultiDataPlot3DWvData = $(Foldername+":MultiDataPlot3DWvData")
				NVAR ContDisplayContValues = $(Foldername+":ContDisplayContValues")
				ModifyContour/W=$(cba.win) MultiDataPlot3DWvData labels=2*ContDisplayContValues
				//do something
			endif
			if(stringmatch(cba.ctrlName,"ContUseOnlyRedColor"))
				NVAR ContLogColors = $(Foldername+":ContLogColors")
				ContLogColors = 0
				NVAR ContUseOnlyRedColor = $(Foldername+":ContUseOnlyRedColor")
				ContUseOnlyRedColor = checked
				IR3L_FormatContourPlot(cba.win)
					//				SVAR Graph3DColorScale = $(Foldername+":ContourColorScale")
					//				Wave MultiDataPlot3DWvData = $(Foldername+":MultiDataPlot3DWvData")
					//				NVAR Graph3DColorsReverse = $(Foldername+":Graph3DColorsReverse")
					//				if(checked)
					//					ContLogColors=0
					//					ModifyContour MultiDataPlot3DWvData rgbLines=(65535, 0, 0 )
					//					ModifyContour MultiDataPlot3DWvData logLines=ContLogColors
					//				else
					//					ModifyContour MultiDataPlot3DWvData ctabLines={ContMinValue, ContMaxValue, $(Graph3DColorScale), Graph3DColorsReverse }
					//					ModifyContour MultiDataPlot3DWvData logLines=ContLogColors
					//				endif
			endif
			if(stringmatch(cba.ctrlName,"ContLogColors")|| stringmatch(cba.ctrlName,"Graph3DColorsReverse") )
					NVAR ContLogColors = $(Foldername+":ContLogColors")
					ContLogColors = checked
					NVAR ContUseOnlyRedColor = $(Foldername+":ContUseOnlyRedColor")
					ContUseOnlyRedColor = 0
					IR3L_FormatContourPlot(cba.win)
					//				SVAR Graph3DColorScale = $(Foldername+":ContourColorScale")
					//				Wave MultiDataPlot3DWvData = $(Foldername+":MultiDataPlot3DWvData")
					//				NVAR Graph3DColorsReverse = $(Foldername+":Graph3DColorsReverse")
					//				ContUseOnlyRedColor = 0
					//				//cannot have 0 as Minvalue or everything is red... 
					//				if(ContMinValue<1e-20)
					//					Wavestats/Q MultiDataPlot3DWvData
					//					ContMinValue = V_min>0 ? 0.99*V_min : 0.00001*ContMaxValue
					//					print "Had to reset min value displayed, for log-colors you cannot have minimum <= 0"
					//				endif
					//				ModifyContour MultiDataPlot3DWvData ctabLines={ContMinValue, ContMaxValue, $(Graph3DColorScale), Graph3DColorsReverse }
					//				ModifyContour MultiDataPlot3DWvData logLines=ContLogColors
			endif
			if(stringmatch(cba.ctrlName,"ContLogXAxis"))
				ModifyGraph log(bottom)=checked
			endif
			//Waterfall controls
			if(stringmatch(cba.ctrlName,"Graph3DLogColors"))
				NVAR Graph3DLogColors=$(Foldername+":Graph3DLogColors")
				NVAR Graph3DColorsReverse=$(Foldername+":Graph3DColorsReverse")
				SVAR Graph3DColorScale=$(Foldername+":Graph3DColorScale")
				WAVE MultiDataPlot3DWvData = $(Foldername+":MultiDataPlot3DWvData")
				NVAR Graph3DColorsReverse = $(Foldername+":Graph3DColorsReverse")
				ModifyGraph zColor(MultiDataPlot3DWvData)={MultiDataPlot3DWvData,*,*,$(Graph3DColorScale),Graph3DColorsReverse}	
				ModifyGraph/W=$(cba.win) logZColor=Graph3DLogColors
			endif
			if(stringmatch(cba.ctrlName,"ContLogContours"))
				IR3L_FormatContourPlot(cba.win)
			endif

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//Function IR3L_FormatContourPlot(string WindowNameStr)
//	
//	string Foldername
//	Foldername = "root:MultiDataPlot3DPlots:"+WindowNameStr
//	if(!DataFolderExists(Foldername))
//		return 0
//	endif
//	DFref OldDf=GetDataFolderDFR()
//	//SVAR XAxisLabel = $(Foldername+":XAxisLabel")
//	SVAR Graph3DColorScale = $(Foldername+":ContourColorScale")
//	NVAR ContMinValue = $(Foldername+":MinCountourVal")
//	NVAR ContMaxValue = $(Foldername+":MaxCountourVal")
//	NVAR ContLogColors = $(Foldername+":ContLogColors")
//	NVAR ContUseOnlyRedColor = $(Foldername+":ContUseOnlyRedColor")
//	NVAR ContSmoothOverValue=$(Foldername+":ContSmoothOverValue")
//	WAVE MultiDataPlot3DWvData = $(Foldername+":MultiDataPlot3DWvData")
//	WAVE MultiDataPlot3DWvDataRaw = $(Foldername+":MultiDataPlot3DWvDataRaw")
//	NVAR Graph3DColorsReverse = $(Foldername+":Graph3DColorsReverse")
//
//	NVAR ContNumCountours = $(Foldername+":NumCountours")
//	NVAR ContMinValue = $(Foldername+":MinCountourVal")
//	NVAR ContMaxValue = $(Foldername+":MaxCountourVal")
//	IR3L_LogLinContours(WindowNameStr)
//
////	//setvariable stuff...
////	//min, max and num contours. 
////	ModifyContour MultiDataPlot3DWvData autoLevels={ContMinValue,ContMaxValue,ContNumCountours}
////	//popup stuff
////	if(stringMatch(Graph3DColorScale,"none"))
////		ModifyContour MultiDataPlot3DWvData rgbLines=(65535, 0, 0 )
////	else
////		ModifyContour MultiDataPlot3DWvData ctabLines={ContMinValue, ContMaxValue, $(Graph3DColorScale), Graph3DColorsReverse }
////		ModifyContour MultiDataPlot3DWvData logLines=ContLogColors
////	endif
////	//smoothing is done ONLY in popup procedure to reduce cpu load. 
////	//checkbox stuff
////	if(ContUseOnlyRedColor)
////		ContLogColors=0
////		ModifyContour MultiDataPlot3DWvData rgbLines=(65535, 0, 0 )
////	else
////		ModifyContour MultiDataPlot3DWvData ctabLines={ContMinValue, ContMaxValue, $(Graph3DColorScale), Graph3DColorsReverse }
////		ModifyContour MultiDataPlot3DWvData logLines=ContLogColors
////	endif
////	if(ContLogColors)
////		ContUseOnlyRedColor = 0
////		//cannot have 0 as Minvalue or everything is red... 
////		if(ContMinValue<1e-20)
////			Wavestats/Q MultiDataPlot3DWvData
////			ContMinValue = V_min>0 ? 0.99*V_min : 0.00001*ContMaxValue
////			print "Had to reset min value displayed, for log-colors you cannot have minimum <= 0"
////		endif
////		ModifyContour MultiDataPlot3DWvData ctabLines={ContMinValue, ContMaxValue, $(Graph3DColorScale), Graph3DColorsReverse }
////		ModifyContour MultiDataPlot3DWvData logLines=ContLogColors
////	endif
//	
////	Label/W=plottingToolContourGrph left "Data Order"
//	setDataFolder oldDf
//end
//************************************************************************************************************************
//************************************************************************************************************************
static Function IR3L_FormatContourPlot(string WinNameStr)

	string Foldername
	Foldername = "root:MultiDataPlot3DPlots:"+WinNameStr
	if(!DataFolderExists(Foldername))
		return 0
	endif
	NVAR ContLogColors = $(Foldername+":ContLogColors")
	NVAR ContLogContours = $(Foldername+":ContLogContours")
	NVAR NumCountours = $(Foldername+":NumCountours")
	NVAR MinCountourVal = $(Foldername+":MinCountourVal")
	NVAR MaxCountourVal = $(Foldername+":MaxCountourVal")
	NVAR ContUseOnlyRedColor = $(Foldername+":ContUseOnlyRedColor")
	NVAR ContMaxValue = $(Foldername+":MaxCountourVal")
	SVAR ContourColorScale = $(Foldername+":ContourColorScale")
	NVAR Graph3DColorsReverse=$(Foldername+":Graph3DColorsReverse")
	Wave MultiDataPlot3DWvData = $(Foldername+":MultiDataPlot3DWvData")

	if(ContLogContours)
		//cannot have 0 as Minvalue or everything is red... 
		if(MinCountourVal<1e-20)
			Wavestats/Q MultiDataPlot3DWvData
			MinCountourVal = V_min>0 ? 0.99*V_min : 0.00001*MaxCountourVal
			print "Had to reset min value displayed, for log-colors you cannot have minimum <= 0"
		endif
		make/O/N=(NumCountours) LogContours
		Wave LogContours
		LogContours = log(MinCountourVal) + p*((log(MaxCountourVal)- log(MinCountourVal))/(NumCountours-1))
		LogContours =  10^LogContours
		ModifyContour/W=$(WinNameStr) MultiDataPlot3DWvData manLevels=LogContours
	else
		ModifyContour /W=$(WinNameStr) MultiDataPlot3DWvData autoLevels={MinCountourVal,MaxCountourVal,NumCountours}	//up to 100 levels. 
	endif
	if(ContUseOnlyRedColor)
		ContLogColors=0
		ModifyContour/W=$(WinNameStr) MultiDataPlot3DWvData rgbLines=(65535, 0, 0 )
	else
		if(ContLogColors)
			ContUseOnlyRedColor = 0
			//cannot have 0 as Minvalue or everything is red... 
			if(MinCountourVal<1e-20)
				Wavestats/Q MultiDataPlot3DWvData
				MinCountourVal = V_min>0 ? 0.99*V_min : 0.00001*MaxCountourVal
				print "Had to reset min value displayed, for log-colors you cannot have minimum <= 0"
			endif
		endif
		ModifyContour/W=$(WinNameStr) MultiDataPlot3DWvData ctabLines={MinCountourVal,MaxCountourVal,$(ContourColorScale),Graph3DColorsReverse}
		ModifyContour/W=$(WinNameStr) MultiDataPlot3DWvData logLines=ContLogColors
	endif

end


//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
Function IR3L_ContPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	string Foldername
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(stringmatch(pa.ctrlName,"ColorTable"))
				Foldername = "root:MultiDataPlot3DPlots:"+pa.win
				if(!DataFolderExists(Foldername))
					return 0
				endif
				SVAR Graph3DColorScale = $(Foldername+":ContourColorScale")
				Graph3DColorScale = popStr
				NVAR ContUseOnlyRedColor = $(Foldername+":ContUseOnlyRedColor")
				ContUseOnlyRedColor=0
				IR3L_FormatContourPlot(pa.win)
			endif
			if(stringmatch(pa.ctrlName,"SmoothOverValue"))
				Foldername = "root:MultiDataPlot3DPlots:"+pa.win
				if(!DataFolderExists(Foldername))
					return 0
				endif
				NVAR ContSmoothOverValue=$(Foldername+":ContSmoothOverValue")
				WAVE MultiDataPlot3DWvData = $(Foldername+":MultiDataPlot3DWvData")
				WAVE MultiDataPlot3DWvDataRaw = $(Foldername+":MultiDataPlot3DWvDataRaw")
				Duplicate /O MultiDataPlot3DWvDataRaw, MultiDataPlot3DWvData
				ContSmoothOverValue = str2num(pa.popStr)
				if(ContSmoothOverValue>1)
					MatrixFilter /N=(ContSmoothOverValue) avg MultiDataPlot3DWvData
				endif
				IR3L_FormatContourPlot(pa.win)
			endif
			//Waterfall controls
			if(stringmatch(pa.ctrlName,"ColorTableWf"))
				Foldername = "root:MultiDataPlot3DPlots:"+pa.win
				if(!DataFolderExists(Foldername))
					return 0
				endif
				SVAR Graph3DColorScale=$(Foldername+":Graph3DColorScale")
				NVAR Graph3DColorsReverse = $(Foldername+":Graph3DColorsReverse")
				Graph3DColorScale = popStr
				NVAR Graph3DColorsReverse=$(Foldername+":Graph3DColorsReverse")
				WAVE MultiDataPlot3DWvData = $(Foldername+":MultiDataPlot3DWvData")
				WAVE MultiDataPlot3DWvDataRaw = $(Foldername+":MultiDataPlot3DWvDataRaw")
				ModifyGraph /W=$(pa.win) zColor(MultiDataPlot3DWvData)={MultiDataPlot3DWvData,*,*,$(Graph3DColorScale),Graph3DColorsReverse}	
			endif
			if(stringmatch(pa.ctrlName,"Graph3DVisibilityWf"))
				Foldername = "root:MultiDataPlot3DPlots:"+pa.win
				if(!DataFolderExists(Foldername))
					return 0
				endif
				SVAR Graph3DVisibility=$(Foldername+":Graph3DVisibility")
				Graph3DVisibility = popStr
				//ModifyGraph zColor(MultiDataPlot3DWvData)={MultiDataPlot3DWvData,*,*,$(Graph3DColorScale),Graph3DColorsReverse}	
				if(stringmatch(Graph3DVisibility,"Off"))
					ModifyWaterfall /W=$(pa.win) hidden=0
				elseif(stringmatch(Graph3DVisibility,"Painter"))
					ModifyWaterfall /W=$(pa.win) hidden=1
				elseif(stringmatch(Graph3DVisibility,"True"))
					ModifyWaterfall /W=$(pa.win) hidden=2
				elseif(stringmatch(Graph3DVisibility,"No bottom"))
					ModifyWaterfall /W=$(pa.win) hidden=3
				elseif(stringmatch(Graph3DVisibility,"Color bottom"))
					ModifyWaterfall /W=$(pa.win) hidden=4
				endif
			endif

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
Function IR3L_ContSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	string Foldername
	variable NumWaves, StepVal
	if(sva.eventCode==1 || sva.eventCode==2)
			Foldername = "root:MultiDataPlot3DPlots:"+sva.win
			if(!DataFolderExists(Foldername))
				return 0
			endif
			if(stringmatch(sva.ctrlName,"ContNumCountours")||stringmatch(sva.ctrlName,"ContMinValue")||stringmatch(sva.ctrlName,"ContMaxValue"))
				NVAR ContNumCountours = $(Foldername+":NumCountours")
				NVAR ContMinValue = $(Foldername+":MinCountourVal")
				NVAR ContMaxValue = $(Foldername+":MaxCountourVal")
				NVAR Graph3DColorsReverse = $(Foldername+":Graph3DColorsReverse")
				SVAR ContourColorScale = $(Foldername+":ContourColorScale")
				if(ContNumCountours>100)
					ContNumCountours=100
					print "Cannot set more than 100 contours in Igor Pro"
				endif
				IR3L_FormatContourPlot(sva.win)
			endif
			if(stringmatch(sva.ctrlName,"ContYWaveScaling")||stringmatch(sva.ctrlName,"ContYWaveIntervals"))
				NVAR ContYWaveScaling = $(Foldername+":ContYWaveScaling")
				NVAR ContYWaveIntervals = $(Foldername+":ContYWaveIntervals")
				Wave CountourPlot_left_values = $(Foldername+":CountourPlot_left_values")
				Wave/T CountourPlot_left_labels = $(Foldername+":CountourPlot_left_labels")
				WAVE MultiDataPlot3DWvData = $(Foldername+":MultiDataPlot3DWvData")
				Redimension/N=(ContYWaveIntervals) CountourPlot_left_labels, CountourPlot_left_values
				NumWaves = DimSize(MultiDataPlot3DWvData, 1 )
				StepVal = floor((NumWaves-1)/(ContYWaveIntervals-1))
				CountourPlot_left_values = (0 + p*StepVal)
				CountourPlot_left_labels =  num2str(CountourPlot_left_values[p]*ContYWaveScaling)
			endif
			//Waterfall controls
			if(stringmatch(sva.ctrlName,"angVar")||stringmatch(sva.ctrlName,"alenVar"))
				Foldername = "root:MultiDataPlot3DPlots:"+sva.win
				if(!DataFolderExists(Foldername))
					return 0
				endif
				NVAR Graph3DAxLength	=$(Foldername+":Graph3DAxLength")
				NVAR Graph3DAngle		=$(Foldername+":Graph3DAngle")
				WAVE MultiDataPlot3DWvData = $(Foldername+":MultiDataPlot3DWvData")
				WAVE MultiDataPlot3DWvDataRaw = $(Foldername+":MultiDataPlot3DWvDataRaw")
				ModifyWaterfall /W=$(sva.win) angle=Graph3DAngle, axlen= Graph3DAxLength	
			endif
			
		endif
		
	return 0
End
//************************************************************************************************************************
//************************************************************************************************************************




//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
