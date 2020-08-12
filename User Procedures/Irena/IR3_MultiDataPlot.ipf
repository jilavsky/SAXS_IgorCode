#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1
constant IR3LversionNumber = 1.01			//MultiDataPloting tool version number. 

//*************************************************************************\
//* Copyright (c) 2005 - 2020, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/


//1.01		Changed working folder name.  
//1.0 		New ploting tool to make plotting various data easy for multiple data sets.  



///******************************************************************************************
///******************************************************************************************
///			Multi-Data ploting tool, easy way to plot many data sets at once
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
	NewPanel /K=1 /W=(5.25,43.25,605,820) as "MultiData Ploting tool"
	DoWIndow/C IR3L_MultiSamplePlotPanel
	TitleBox MainTitle title="\Zr220Multi Data ploting tool",pos={140,1},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fColor=(0,0,52224)
								//	TitleBox FakeLine2 title=" ",fixedSize=1,size={330,3},pos={16,428},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena:MultiSamplePlot","IR3L_MultiSamplePlotPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	Button GetHelp,pos={480,10},size={80,15},fColor=(65535,32768,32768), proc=IR3L_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}
	IR3C_MultiAppendControls("Irena:MultiSamplePlot","IR3L_MultiSamplePlotPanel", "IR3L_DoubleClickAction","",0,1)

	Button SelectAll,pos={190,680},size={80,15}, proc=IR3L_ButtonProc,title="SelectAll", help={"Select All data in Listbox"}

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

	SetVariable XOffset,pos={260,340},size={130,15}, proc=IR3L_SetVarProc,title="X offset :     ", limits={0,inf,1}
	Setvariable XOffset, fStyle=2, variable=root:Packages:Irena:MultiSamplePlot:XOffset, help={"X Offxet for X axis, you can change it. "}
	SetVariable YOffset,pos={430,340},size={130,15}, proc=IR3L_SetVarProc,title="Y offset :     ",limits={0,inf,1}
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



	TitleBox Instructions1 title="\Zr100Double click to add data to graph",size={330,15},pos={4,680},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions2 title="\Zr100Shift-click to select range of data",size={330,15},pos={4,695},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions3 title="\Zr100Ctrl/Cmd-click to select one data set",size={330,15},pos={4,710},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions4 title="\Zr100Regex for not contain: ^((?!string).)*$",size={330,15},pos={4,725},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions5 title="\Zr100Regex for contain:  string, two: str2.*str1",size={330,15},pos={4,740},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions6 title="\Zr100Regex for case independent:  (?i)string",size={330,15},pos={4,755},frame=0,fColor=(0,0,65535),labelBack=0

	SVAR SelectedStyle = root:Packages:Irena:MultiSamplePlot:SelectedStyle
	PopupMenu ApplyStyle,pos={280,660},size={400,20},proc=IR3L_PopMenuProc, title="Apply style:",help={"Set tool setting to defined conditions and apply to graph"}
	PopupMenu ApplyStyle,value=#"root:Packages:Irena:MultiSamplePlot:ListOfDefinedStyles",popvalue=SelectedStyle
	Button ApplyPresetFormating,pos={260,710},size={160,20}, proc=IR3L_ButtonProc,title="Apply All Formating", help={"Apply Preset Formating to update graph based on these choices"}
	Checkbox ApplyFormatingEveryTime, pos={250,735},size={76,14},title="Apply Formating automatically?", proc=IR3L_CheckProc, variable=root:Packages:Irena:MultiSamplePlot:ApplyFormatingEveryTime, help={"Should all formatting be applied after every data additon?"}

	
	Button ExportGraphJPG,pos={450,680},size={140,20}, proc=IR3L_ButtonProc,title="Export as jpg", help={"Export as jpg file"}
	Button ExportGraphTIF,pos={450,705},size={140,20}, proc=IR3L_ButtonProc,title="Export as tiff", help={"Export as tiff file"}
	Button SaveGraphAsFile,pos={450,730},size={140,20}, proc=IR3L_ButtonProc,title="Export as pxp", help={"Save Graph As Igor experiment"}


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
	ListOfDefinedDataPlots = "X-Y (q-Int, etc.);Guinier (Q^2-ln(I));Kratky (Q-IQ^2);Porod (Q^4-IQ^4);Guinier Rod (Q^2-ln(I*Q));Guinier Sheet (Q^2-ln(I*Q^2));DimLess Kratky (Q-I*(Q*Rg)^2/I0);"
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
		Wave/Z SourceIntWv=$(DataFolderName+IntensityWaveName)
		Wave/Z SourceQWv=$(DataFolderName+QWavename)
		Wave/Z SourceErrorWv=$(DataFolderName+ErrorWaveName)
		Wave/Z SourcedQWv=$(DataFolderName+dQWavename)
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
				Duplicate/O SourceIntWv, $(DataFolderName+"Guinier_"+IntensityWaveName)
				Duplicate/O SourceQWv, $(DataFolderName+"Guinier_"+QWavename)
				Wave SourceIntWv=$(DataFolderName+"Guinier_"+IntensityWaveName)
				Wave SourceQWv=$(DataFolderName+"Guinier_"+QWavename)
				SourceQWv = SourceQWv^2
				SourceIntWv = ln(SourceIntWv)						//error propagation, see: https://terpconnect.umd.edu/~toh/models/ErrorPropagation.pdf
				if(WaveExists(SourceErrorWv))
					Duplicate/O SourceErrorWv, $(DataFolderName+"Guinier_"+ErrorWaveName)
						Wave SourceErrorWv=$(DataFolderName+"Guinier_"+ErrorWaveName)
					SourceErrorWv = SourceErrorWvOrig/SourceIntWvOrig
				endif
				break
			case "Guinier Rod (Q^2-ln(I*Q))":				// execute if case matches expression
				//create and save Guinier data
				Duplicate/O SourceIntWv, $(DataFolderName+"GuinierR_"+IntensityWaveName)
				Duplicate/O SourceQWv, $(DataFolderName+"GuinierR_"+QWavename)
				Wave SourceIntWv=$(DataFolderName+"GuinierR_"+IntensityWaveName)
				Wave SourceQWv=$(DataFolderName+"GuinierR_"+QWavename)
				SourceQWv = SourceQWv^2
				SourceIntWv = ln(SourceIntWv*SourceQWvOrig)						//error propagation, see: https://terpconnect.umd.edu/~toh/models/ErrorPropagation.pdf
				if(WaveExists(SourceErrorWv))
					Duplicate/O SourceErrorWv, $(DataFolderName+"GuinierR_"+ErrorWaveName)
						Wave SourceErrorWv=$(DataFolderName+"GuinierR_"+ErrorWaveName)
					SourceErrorWv = (SourceErrorWvOrig)/(SourceIntWvOrig)
				endif
				break
			case "Guinier Sheet (Q^2-ln(I*Q^2))":				// execute if case matches expression
				//create and save Guinier data
				Duplicate/O SourceIntWv, $(DataFolderName+"GuinierS_"+IntensityWaveName)
				Duplicate/O SourceQWv, $(DataFolderName+"GuinierS_"+QWavename)
				Wave SourceIntWv=$(DataFolderName+"GuinierS_"+IntensityWaveName)
				Wave SourceQWv=$(DataFolderName+"GuinierS_"+QWavename)
				SourceQWv = SourceQWv^2
				SourceIntWv = ln(SourceIntWv*SourceQWvOrig^2)						//error propagation, see: https://terpconnect.umd.edu/~toh/models/ErrorPropagation.pdf
				if(WaveExists(SourceErrorWv))
					Duplicate/O SourceErrorWv, $(DataFolderName+"GuinierS_"+ErrorWaveName)
						Wave SourceErrorWv=$(DataFolderName+"GuinierS_"+ErrorWaveName)
					SourceErrorWv = (SourceErrorWvOrig)/(SourceIntWvOrig)
				endif
				break
			case "Kratky (Q-IQ^2)":					// execute if case matches expression
				//create and save Kratky data
				Duplicate/O SourceIntWv, $(DataFolderName+"Kratky_"+IntensityWaveName)
				Duplicate/O SourceQWv, $(DataFolderName+"Kratky_"+QWavename)
				Wave SourceIntWv=$(DataFolderName+"Kratky_"+IntensityWaveName)
				Wave SourceQWv=$(DataFolderName+"Kratky_"+QWavename)
				SourceIntWv = SourceIntWv * SourceQWv^2
				if(WaveExists(SourceErrorWv))
					Duplicate/O SourceErrorWv, $(DataFolderName+"Kratky_"+ErrorWaveName)
					Wave SourceErrorWv=$(DataFolderName+"Kratky_"+ErrorWaveName)
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
				Duplicate/O SourceIntWv, $(DataFolderName+"DLKratky_"+IntensityWaveName)
				Duplicate/O SourceQWv, $(DataFolderName+"DLKratky_"+QWavename)
				Wave SourceIntWv=$(DataFolderName+"DLKratky_"+IntensityWaveName)
				Wave SourceQWv=$(DataFolderName+"DLKratky_"+QWavename)
				SourceIntWv = SourceIntWv * ((Rg*SourceQWv)^2)/I0
				if(WaveExists(SourceErrorWv))
					Duplicate/O SourceErrorWv, $(DataFolderName+"DLKratky_"+ErrorWaveName)
					Wave SourceErrorWv=$(DataFolderName+"DLKratky_"+ErrorWaveName)
					SourceErrorWv = SourceErrorWv * ((Rg*SourceQWv)^2)/I0
				endif
				break
			case "Porod (Q^4-IQ^4)":					// execute if case matches expression
				//create and save Porod data
				Duplicate/O SourceIntWv, $(DataFolderName+"Porod_"+IntensityWaveName)
				Duplicate/O SourceQWv, $(DataFolderName+"Porod_"+QWavename)
				Wave SourceIntWv=$(DataFolderName+"Porod_"+IntensityWaveName)
				Wave SourceQWv=$(DataFolderName+"Porod_"+QWavename)
				SourceQWv = SourceQWv^4
				SourceIntWv = SourceIntWv * SourceQWv
				if(WaveExists(SourceErrorWv))
					Duplicate/O SourceErrorWv, $(DataFolderName+"Porod_"+ErrorWaveName)
					Wave SourceErrorWv=$(DataFolderName+"Porod_"+ErrorWaveName)
					SourceErrorWv = SourceErrorWv * SourceQWv
				endif
				break
			default:										// optional default expression executed, this is basically X-Y case again
															// when no case matches
		endswitch
		
		CheckDisplayed /W=$(GraphWindowName) SourceIntWv
		if(V_Flag==0)
			AppendToGraph /W=$(GraphWindowName) SourceIntWv vs  SourceQWv
			if(WaveExists(SourceErrorWv))
				ErrorBars /W=$(GraphWindowName)  $(NameOfWave(SourceIntWv)) Y,wave=(SourceErrorWv,SourceErrorWv)
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
		  	//abort if GraphWindowName is not right
		  	if(strlen(GraphWindowName)<1)	//name has any length	
		  		return 0
			endif		  	
			//  	DoWindow $(GraphWindowName)	//widnow does not exist
			//  	if(V_Flag==0)
			//  		return 0
			//  	endif
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

			if(stringmatch(ba.ctrlName,"SelectAll"))
				Wave/Z SelectionOfAvailableData = root:Packages:Irena:MultiSamplePlot:SelectionOfAvailableData
				if(WaveExists(SelectionOfAvailableData))
					SelectionOfAvailableData=1
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
			//	AllKnownToolsResults = "Unified Fit;Size Distribution;Modeling II;Modeling I;Small-angle diffraction;Analytical models;Fractals;PDDF;Reflectivity;Guinier-Porod;Evaluate Size Dist;"
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

