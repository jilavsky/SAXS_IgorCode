#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.14

Constant IR2MversionNumber = 1.13			//Data mining tool version number
constant IR3BversionNumber = 0.1			//MetadataBrowser tool version number. 

//*************************************************************************\
//* Copyright (c) 2005 - 2020, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.14 added MetadataBrowser tool in this package,
//1.13 GetHelp button
//1.12 more fixes for panel scaling. 
//1.11 fixes for panel scaling
//1.10 removed wave/d, Function/d and variable/d. Obsolete
//1.09 bug fixes, bug found by igor 7. 
//1.08 fixed IR2M_CreateWaveName(WaveNameStr,ItemNameStr) for Modeling II waves
//        removed all font and font size from panel definitions to enable user control
//1.07 who knows?
//1.06 modified to enable multiple selections. Shift select range, cmd/ctrl selected disjoint cells. 
//1.05 added match strings. 
//1.04 modified to handle better wave notes of qrs data. 
//1.03 added license for ANL


//This should be package which allows mining data for variuous outputs.
//Needs to be able to read parts of folder tree and in ech folder provide some servgices:
//	find data and add to new graph if they exist
//	find strings/variables/wave (notes) and print into notebook
//	find strings/variables/wave (notes) and output to waves


//Use no more than about 8 distinct colors.
//Subtle differences are not obvious and can actually
//obscure significant differences between curves.
//Use about 6 different symbols.  You can also
//choose open and filled symbols (but not for
//cross, plus, and dot, of course) but symbols have
//to be large enough to distinguish this.  Be certain
//to have a different number of symbols and colors,
//then the pattern has a longer repeat interval.
//
//
//This example has a repeat interval of 70:
//colors:  red green blue black brown orange purple
//shapes:  circle square diamond uptriangle downtriangle
//fills:   open closed
//Vary the colors and shapes together keeping fill fixed
//for the first half, then change fill and repeat colors
//and shapes.
//
//
//This is not Igor code but describes my selection method.
//(zero-based arrays
// index = zero-based number of curve on the plot
// number(xx) = number of items in xx array
// int(0.9) = 0  and  int(1.1) = 1
//)
//     color = colors[ index % number(colors) ]
//     shape = shapes[ index % number(shapes) ]
//     fill  = fills[ int(2*index/number(fills)) ]







///******************************************************************************************
///******************************************************************************************
///			Data mining tool main procedures. 
///******************************************************************************************
///******************************************************************************************
Function IR2M_GetDataMiner()

	IR2M_InitDataMiner()
	
	KillWIndow/Z DataMiningTool
 	KillWIndow/Z ItemsInFolderPanel
 	
	IR2M_DataMinerPanel()
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("DataMiningTool", IR2MversionNumber,1)
	
	IR2M_SyncSearchListAndListBox()	//sync the list box... 
	IR2M_MakePanelWithListBox(0)	//and create the other panel... 
	//IR1_UpdatePanelVersionNumber("ItemsInFolderPanel", IR2MversionNumber,1)
	popupmenu QvecDataName, win=DataMiningTool, disable=1
	popupmenu IntensityDataName, win=DataMiningTool, disable=1
	popupmenu ErrorDataName, win=DataMiningTool, disable=1
	popupmenu SelectDataFolder, win=DataMiningTool, title="Test data folder"

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2M_MainCheckVersion()	
	DoWindow DataMiningTool
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("DataMiningTool", IR2MversionNumber))
			DoAlert /T="The Data mining panel was created by incorrect version of Irena " 1, "Data mining needs to be restarted to work properly. Restart now?"
			if(V_flag==1)
				IR2M_GetDataMiner()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR2M_InitDataMiner()
				IR2M_SyncSearchListAndListBox()	//sync the list box... 
				IR2M_MakePanelWithListBox(0)	//and create the other panel... 
				//IR1_UpdatePanelVersionNumber("ItemsInFolderPanel", IR2MversionNumber,1)
				popupmenu QvecDataName, win=DataMiningTool, disable=1
				popupmenu IntensityDataName, win=DataMiningTool, disable=1
				popupmenu ErrorDataName, win=DataMiningTool, disable=1
				popupmenu SelectDataFolder, win=DataMiningTool, title="Test data folder"
			endif
		endif
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************



///******************************************************************************************
///******************************************************************************************
///			Metadata Browser tool, easy way to pull metadata out of wave notes
///******************************************************************************************
///******************************************************************************************
Function IR3B_MetadataBrowser()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IN2G_CheckScreenSize("width",1000)
	IN2G_CheckScreenSize("height",670)
	DoWIndow IR3B_MetadataBrowserPanel
	if(V_Flag)
		DoWindow/F IR3B_MetadataBrowserPanel
	else
		IR3B_InitMetadataBrowser()
		IR3B_MetadataBrowserPanelFnct()
		IR1_UpdatePanelVersionNumber("IR3B_MetadataBrowserPanel", IR3BversionNumber,1)
	endif
	IR3C_MultiUpdListOfAvailFiles("Irena:MetadataBrowser")
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3B_MainCheckVersion()	
	DoWindow IR3B_MetadataBrowserPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR3B_MetadataBrowserPanel", IR3BversionNumber))
			DoAlert /T="The Metadata Browser panel was created by different version of Irena " 1, "Metadata Browser may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				KillWIndow/Z IR3B_MetadataBrowserPanel
				IR3B_MetadataBrowser()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR3B_InitMetadataBrowser()
			endif
		endif
	endif
end 
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR3B_MetadataBrowserPanelFnct()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(5.25,43.25,800,820) as "Metadata Browser tool"
	DoWIndow/C IR3B_MetadataBrowserPanel
	TitleBox MainTitle title="\Zr220Metadata Browser",pos={140,1},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fColor=(0,0,52224)
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena:MetadataBrowser","IR3B_MetadataBrowserPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	Button GetHelp,pos={700,10},size={80,15},fColor=(65535,32768,32768), proc=IR3B_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}
	IR3C_MultiAppendControls("Irena:MetadataBrowser","IR3B_MetadataBrowserPanel", "IR3B_DoubleClickAction","IR3B_MouseDownAction", 0,1)
	//graph controls
	TitleBox Instructions1 title="\Zr100Single/Double click to check data note",size={330,15},pos={4,680},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions2 title="\Zr100Shift-click to select range of data",size={330,15},pos={4,695},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions3 title="\Zr100Ctrl/Cmd-click to select one data set",size={330,15},pos={4,710},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions4 title="\Zr100Regex for not contain: ^((?!string).)*$",size={330,15},pos={4,725},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions5 title="\Zr100Regex for contain:  string, two: str2.*str1",size={330,15},pos={4,740},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions6 title="\Zr100Regex for case independent:  (?i)string",size={330,15},pos={4,755},frame=0,fColor=(0,0,65535),labelBack=0

	Button SelectAll,pos={205,695},size={70,15}, proc=IR3B_ButtonProc,title="SelectAll", help={"Select All data in Listbox"}
 
	//Note listing and selection options 
	TitleBox KeySelectionInfo title="\Zr140Selected sample & metadata : ",fixedSize=1,size={220,20},pos={290,100},frame=0,fstyle=1, fixedSize=1,fColor=(0,0,52224)
	SetVariable DataFolderName,pos={270,124},size={280,20}, proc=IR3B_SetVarProc,title=" ",noedit=1,frame=0,fstyle=1, valueColor=(65535,0,0)
	Setvariable DataFolderName,fStyle=2, variable=root:Packages:Irena:MetadataBrowser:DataFolderName, help={"This is grep string to clean up the key names"}
	SetVariable GrepItemNameString,pos={270,150},size={240,20}, proc=IR3B_SetVarProc,title="\Zr120Regex key name: "
	Setvariable GrepItemNameString,fStyle=2, variable=root:Packages:Irena:MetadataBrowser:GrepItemNameString, help={"This is grep string to clean up the key names"}
	ListBox NoteItemsSelection,win=IR3B_MetadataBrowserPanel,pos={265,180},size={250,495}, mode=10, special={0,0,1 }		//this will scale the width of column, users may need to slide right using slider at the bottom. 
	ListBox NoteItemsSelection,listWave=root:Packages:Irena:MetadataBrowser:ListOfWaveNoteItems
	ListBox NoteItemsSelection,selWave=root:Packages:Irena:MetadataBrowser:SelectionOfWaveNoteItems
	ListBox NoteItemsSelection,proc=IR3B_MultiListBoxProc
	
	TitleBox Instructions11 title="\Zr100Use Regex to display less",size={330,15},pos={280,680},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions21 title="\Zr100https://www.rexegg.com/regex-quickstart.html",size={330,15},pos={280,695},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions31 title="\Zr100Double click to add item to list on right",size={330,15},pos={280,710},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions41 title="\Zr100Select range of Data and use following to graph:",size={330,15},pos={280,725},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions51 title="\Zr100ctrl/cmd+Double click to graph selection",size={330,15},pos={280,740},frame=0,fColor=(0,0,65535),labelBack=0
	//TitleBox Instructions61 title="\Zr100",size={330,15},pos={280,755},frame=0,fColor=(0,0,65535),labelBack=0

	//selected data
	TitleBox SelectedItemsInfo title="\Zr140List to process : ",fixedSize=1,size={150,20},pos={590,110},frame=0,fstyle=1, fixedSize=1,fColor=(0,0,52224)
	PopupMenu ExtractFromFileName,pos={560,150},size={310,20},proc=IR3B_PopMenuProc, title="Extract From Folder Name : ",help={"Select if to extarct from name some information"}
	PopupMenu ExtractFromFileName,value="---;_xyzC;_xyzmin;_xyz;_xyzpct;",mode=1, popvalue="---"
	ListBox SeletectedItems,win=IR3B_MetadataBrowserPanel,pos={530,180},size={250,250}, mode=10, special={0,0,1 }		//this will scale the width of column, users may need to slide right using slider at the bottom. 
	ListBox SeletectedItems,listWave=root:Packages:Irena:MetadataBrowser:SeletectedItems
	ListBox SeletectedItems,selWave=root:Packages:Irena:MetadataBrowser:SelectionOfSelectedItems
	ListBox SeletectedItems,proc=IR3B_MultiListBoxProc
	TitleBox Instructions12 title="\Zr100Double click to remove item from list",size={330,15},pos={550,440},frame=0,fColor=(0,0,65535),labelBack=0
	Button DeleleAllSelected,pos={540,460},size={220,15}, proc=IR3B_ButtonProc,title="Remove all selected", help={"Remove all selected above."}

	TitleBox Instructions13 title="\Zr100Select where and extract data : ",size={330,15},pos={530,500},frame=0,fColor=(0,0,65535),labelBack=0


	SetVariable SaveToFoldername,pos={525,530},size={260,20}, noproc,title="\Zr120Save to:"
	Setvariable SaveToFoldername,fStyle=2, variable=root:Packages:Irena:MetadataBrowser:SaveToFoldername, help={"Where to store saved metadata"}

	Button ExtractDataInWave,pos={540,570},size={220,20}, proc=IR3B_ButtonProc,title="Process Selected folders", help={"Extract above listed metadata as waves and save"}
	Button DisplayDataInTable,pos={540,595},size={220,20}, proc=IR3B_ButtonProc,title="Display results in Table", help={"Create table with extracted data"}
	Button DisplayDataInBrowser,pos={540,620},size={220,20}, proc=IR3B_ButtonProc,title="Display results in Data Browser", help={"Open Igor Data Browser and show folder with extracted data"}

	PopupMenu PlotXWave,pos={530,645},size={120,20},proc=IR3B_PopMenuProc, title="X : ",help={"Select Wave to use as x wave to plot"}
	PopupMenu PlotXWave,value="---;"+IR3B_ListResultsWaves(),mode=1
	PopupMenu PlotYWave,pos={530,668},size={120,20},proc=IR3B_PopMenuProc, title="Y : ",help={"Select Wave to use as y wave to plot"}
	PopupMenu PlotYWave,value="---;"+IR3B_ListResultsWaves(),mode=1

	Button PlotDataForUser,pos={680,645},size={100,45}, proc=IR3B_ButtonProc,title="Plot \rSelected", help={"Open Igor Data Browser and show folder with extracted data"}

	TitleBox Instructions45 title="\Zr100Remove stored results from Save to folder :",size={330,15},pos={545,735},frame=0,fColor=(0,0,65535),labelBack=0
	Button DeleleDataFromFolder,pos={580,755},size={150,15}, proc=IR3B_ButtonProc,title="Delete old results", fColor=(43690,43690,43690),labelBack=0, help={"Delete data in the folder previously extracted."}

end
//**********************************************************************************************************
//**********************************************************************************************************
Function/T IR3B_ListResultsWaves()
	SVAR df=root:Packages:Irena:MetadataBrowser:SaveToFoldername
	return IN2G_CreateListOfItemsInFolder(df,2)
end
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3B_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i
	string FoldernameStr
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(cmpstr(ba.ctrlname,"ExtractDataInWave")==0)
				IR3B_ExtractMetadataFromList()
				IR3B_DisplayMetadataResults()
			endif
			if(cmpstr(ba.ctrlname,"DeleleAllSelected")==0)
				Wave/T ListWave=root:Packages:Irena:MetadataBrowser:SeletectedItems
				Wave selWave=root:Packages:Irena:MetadataBrowser:SelectionOfSelectedItems
				Redimension/N=1 ListWave, selWave
			endif

			if(cmpstr(ba.ctrlname,"PlotDataForUser")==0)
				IR3B_PlotSelectedResults()
			endif
			if(cmpstr(ba.ctrlname,"DeleleDataFromFolder")==0)
				IR3B_DeleteMetadataResults()
			endif
			if(cmpstr(ba.ctrlname,"DisplayDataInTable")==0)
				IR3B_DisplayMetadataResults()
			endif
			if(stringmatch(ba.ctrlName,"SelectAll"))
				Wave/Z SelectionOfAvailableData = root:Packages:Irena:MetadataBrowser:SelectionOfAvailableData
				if(WaveExists(SelectionOfAvailableData))
					SelectionOfAvailableData=1
				endif
			endif
			if(cmpstr(ba.ctrlname,"DisplayDataInBrowser")==0)
				SVAR FldrWithData=root:Packages:Irena:MetadataBrowser:SaveToFoldername
				if(DataFolderExists(FldrWithData ))
					CreateBrowser 
					ModifyBrowser  setDataFolder=FldrWithData, showWaves=1		
				else
					abort "Data Folder "+FldrWithData+" does not exist" 
				endif					
			endif
			if(cmpstr(ba.ctrlname,"GetHelp")==0)
				//Open www manual with the right page
				IN2G_OpenWebManual("Irena/MetadataBrowser.html")
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

Function IR3B_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String ctrlName=Pa.ctrlName
	Variable popNum=Pa.popNum
	String popStr=Pa.popStr
	
	if(Pa.eventcode!=2)
		return 0
	endif
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if(stringmatch(ctrlName,"ExtractFromFileName"))
		//do something here
		IR3B_AddToSelectedItems("Extract"+popStr,1)
	endif
	DOWIndow/F IR3L_MultiSamplePlotPanel
end

//**************************************************************************************
//**************************************************************************************
///**************************************************************************************
//**************************************************************************************

Function IR3B_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable tempP
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
				//			if(stringmatch(sva.ctrlName,"FolderNameMatchString"))
				//				IR3L_UpdateListOfAvailFiles()
				//			endif
				if(stringmatch(sva.ctrlName,"GrepItemNameString"))
					IR3B_DisplayWaveNote("")
				endif
				break
		case 3: // live update
			break
		case -1: // control being killed
			break
	endswitch
	DoWIndow/F IR3B_MetadataBrowserPanel
	return 0
End

//**************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


Function IR3B_MultiListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable row = lba.row
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave
	string WinNameStr=lba.win

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
			break
		case 2: // mouse up
			break
		case 3: // double click
			if(lba.eventMod==3 || lba.eventMod==9)	// double click + shift or ctrl/cmd
				IR3B_DisplayTestMetadataValues(listWave[row])
			endif
			
			if(lba.eventMod==1)	//normal double click
				if(stringmatch(lba.ctrlName,"NoteItemsSelection"))
					IR3B_AddToSelectedItems(listWave[row],1)
				endif
				if(stringmatch(lba.ctrlName,"SeletectedItems"))
					IR3B_AddToSelectedItems(listWave[row],0)
				endif
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

static Function IR3B_DisplayMetadataResults()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	SVAR FldrWithData=root:Packages:Irena:MetadataBrowser:SaveToFoldername
	if(!DataFolderExists(FldrWithData))
		setDataFolder OldDF
		Abort "Data Folder : "+ FldrWithData+" does not exist."
	endif
	SetDataFolder $(FldrWithData)					//go into the folder
	string ListOfWaves=IN2G_ConvertDataDirToList(DataFolderDir(2))
	KillWIndow/Z MetadataBrowserResTable
	variable i, NumWaves
	string TmpNameStr
	if(strlen(ListOfWaves)>2)
		Edit/W=(423,162,902,874)/K=1/N=MetadataBrowserResTable  as "Table of extracted Metadata"
		NumWaves = ItemsInList(ListOfWaves)
		for(i=0;i<NumWaves;i+=1)
			TmpNameStr = stringFromList(i,ListOfWaves) 
			AppendToTable /W=MetadataBrowserResTable $(TmpNameStr)
			ModifyTable title($TmpNameStr)=TmpNameStr
		endfor
		ModifyTable/W=MetadataBrowserResTable alignment=2, autosize={0, 0, -1, 0, 0 }
		//now we need to make it wide enough, if possible...
		variable TotalWidth=100
		For(i=0;i<NumWaves;i+=1)
			TotalWidth+=NumberByKey("WIDTH", TableInfo("MetadataBrowserResTable", i))
		endfor
		TotalWidth = min(TotalWidth,900)
		MoveWindow /W=MetadataBrowserResTable 250,162, 250+TotalWidth, 874		
	endif
	setDataFolder OldDF
end

//**************************************************************************************
//**************************************************************************************


static Function IR3B_DeleteMetadataResults()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	DoAlert/T="Are you sure???" 1, "Extracted metadata waves will be deleted, are you REALLY sure you want to do this?"
	if(V_Flag)
		SVAR FldrWithData=root:Packages:Irena:MetadataBrowser:SaveToFoldername
		if(!DataFolderExists(FldrWithData))
			setDataFolder OldDF
			return 0	
		endif
		SetDataFolder $(FldrWithData)					//go into the folder
		KillWIndow/Z MetadataBrowserResTable
		KillWaves /A/Z
		string ListOfWaves=IN2G_ConvertDataDirToList(DataFolderDir(2))
		variable i
		if(strlen(ListOfWaves)>2)	//could nto be deleted... Hm, at least redimension to N=0
			for(i=0;i<ItemsInList(ListOfWaves);i+=1)
				Wave tmpWv= $(stringFromList(i,ListOfWaves))
				redimension/N=0 tmpWv
			endfor
		endif
		//clean up popups...
		PopupMenu PlotXWave win=IR3B_MetadataBrowserPanel, mode=1
		PopupMenu PlotYWave win=IR3B_MetadataBrowserPanel, mode=1

	endif
	setDataFolder OldDF
end
//**************************************************************************************
//**************************************************************************************
static Function IR3B_PlotSelectedResults()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	//get needed values... 
	ControlInfo/W=IR3B_MetadataBrowserPanel PlotXWave
	string XwaveNm=S_Value
	ControlInfo/W=IR3B_MetadataBrowserPanel PlotYWave
	string YwaveNm=S_Value
	SVAR FldrWithData=root:Packages:Irena:MetadataBrowser:SaveToFoldername
	string FldrWithDataStr=RemoveEnding(FldrWithData, ":")+":"
	Wave/Z Xwave = $(FldrWithDataStr+XwaveNm)
	Wave/Z Ywave = $(FldrWithDataStr+YwaveNm)
	string NewGraphName="MetadataBrowserResultsPlot"
	NewGraphName = UniqueName(NewGraphName, 6, 0)
	if(WaveExists(Xwave)&&WaveExists(Ywave))
		Display/K=1/N=$(NewGraphName)/W=(423,162,1293,747) Ywave vs Xwave 
		ModifyGraph mirror=1, mode=4, marker=19
		Label left YwaveNm
		Label bottom XwaveNm
	endif
	setDataFolder OldDF	
end
//**************************************************************************************
//**************************************************************************************
static Function IR3B_AddToSelectedItems(ItemToAddorRemove,Add)
	string ItemToAddorRemove
	variable Add			//Add=1 to add, 0 to remove

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string KeyName=StringFromList(0, ItemToAddorRemove, "=")
	Wave/T listWave=root:Packages:Irena:MetadataBrowser:SeletectedItems
	Wave selWave=root:Packages:Irena:MetadataBrowser:SelectionOfSelectedItems
	//no issue to remove it first, if it is nto there, no issue. 
	//this prevents duplicates... 
	//exact match: "\bdeiauk\b"
	make/T/Free wt
	Grep/E={"\b"+KeyName+"\b",0} listWave as wt
	if(numpnts(wt)>0 && Add==0)				//item is already there... Remove
		Grep/E={"\b"+KeyName+"\b",1} listWave as listWave
	elseif(numpnts(wt)>0 && Add)				//item is already there... nothing to do
		//nothing to do
	else											//next, add it if needed
		variable NewLength=numpnts(listWave)
		if(NewLength<1)
			NewLength=1
		endif
		if(Add)	
			Redimension/N=(NewLength+1) listWave
			listWave[0]="FolderName"
			listWave[NewLength] = KeyName
		endif
	endif
	Redimension/N=(numpnts(listWave)) selWave
	selWave = 0
end
//**************************************************************************************
//**************************************************************************************
Function IR3B_DoubleClickAction(FoldernameStr)
		string FoldernameStr
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

		IR3B_DisplayWaveNote(FoldernameStr)
end
//**************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3B_MouseDownAction(FoldernameStr)
		string FoldernameStr
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

		IR3B_DisplayWaveNote(FoldernameStr)
end
//**********************************************************************************************************
//**********************************************************************************************************
static Function 	IR3B_DisplayTestMetadataValues(ParameterSelected)
	string ParameterSelected
		
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:MetadataBrowser					//go into the folder
	string KeyName=StringFromList(0, ParameterSelected, "=")
	
	Wave/T ListOfAvailableData=root:Packages:Irena:MetadataBrowser:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:Irena:MetadataBrowser:SelectionOfAvailableData
	variable i, imax=numpnts(ListOfAvailableData)
	make/Free/T/N=(1+sum(SelectionOfAvailableData)/8) TempStrValues
	variable j=0, TimeInSeconds
	For(i=0;i<imax;i+=1)
		if(SelectionOfAvailableData[i])
			print "Extracting data from "+ListOfAvailableData[i]
			TempStrValues[j] = IR3B_FindSpecificMetadata(ListOfAvailableData[i], KeyName)	
			j+=1
		endif	
	endfor
	//now we need to decide, if these are numbers...
	KillWindow/Z MetadataBrowserTempGraph
	KillWindow/Z MetadataBrowsertempTable
	if(GrepString(TempStrValues[0], "^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$"))		//this si number
		Make/O/N=(numpnts(TempStrValues)) $(CleanupName(KeyName[0,25], 0)+"TmpWv")
		Wave ResultsWv=$(CleanupName(KeyName[0,25], 0)+"TmpWv")
		ResultsWv = str2num(TempStrValues[p])
		Display/W=(423,162,1293,747)/K=1/N=MetadataBrowserTempGraph ResultsWv as "Temporary display of selected parameter"
		ModifyGraph mirror=1, mode=4, marker=19
		Label left KeyName
		Label bottom "Sample Order"
	else
		TimeInSeconds = IN2G_ConvertTimeStringToSecs(TempStrValues[0])
		if(numtype(TimeInSeconds)==0)		//looks like time!
			Make/O/N=(numpnts(TempStrValues)) $(CleanupName(KeyName[0,22], 0)+"TmpTimeWv")
			Wave ResultsTimeWv=$(CleanupName(KeyName[0,22], 0)+"TmpTimeWv")
			ResultsTimeWv = IN2G_ConvertTimeStringToSecs(TempStrValues[p])
			Display/W=(423,162,1293,747)/K=1/N=MetadataBrowserTempGraph ResultsTimeWv as "Temporary display of selected parameter"
			ModifyGraph mirror=1, mode=4, marker=19
			Label left KeyName
			Label bottom "Sample Order"
		else		//ok, this is really string now... 
			Make/O/N=(numpnts(TempStrValues))/T $(CleanupName(KeyName[0,22], 0)+"TmpStrWv")
			Wave/T ResultsStrWv=$(CleanupName(KeyName[0,22], 0)+"TmpStrWv")
			ResultsStrWv = TempStrValues[p]
			Edit/W=(423,162,902,874)/K=1/N=MetadataBrowsertempTable ResultsStrWv as "Temporary Display of selected parameter"
			ModifyTable format(Point)=1,width($nameofwave(ResultsStrWv))=208
			ModifyTable title($nameofwave(ResultsStrWv))=KeyName
			ModifyTable/W=MetadataBrowsertempTable alignment=2, autosize={0, 0, -1, 0, 0 }
		endif
	endif
	setDataFolder OldDF
end
//**********************************************************************************************************
//**********************************************************************************************************
static Function/T IR3B_FindSpecificMetadata(FolderNameStr, KeyString)	
	string FolderNameStr, KeyString

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR DataFolderName=root:Packages:Irena:MetadataBrowser:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena:MetadataBrowser:IntensityWaveName
	string result=""
	if(strlen(FolderNameStr)>0)						//if strlen(FolderNameStr)=0, this is called from other other and all is set here... 
		IR3C_SelectWaveNamesData("Irena:MetadataBrowser", FolderNameStr)			//this routine will preset names in strings as needed
	endif
	Wave/Z SourceIntWv=$(DataFolderName+IntensityWaveName)
	if(!WaveExists(SourceIntWv))
		DoAlert /T="Incorrectly defined data type" 0, "Please, check definition of data type, it seems incorrectly defined yet"
		SetDataFolder oldDf
		abort 
	endif
	string CurrentNote=note(SourceIntWv)
	result = StringByKey(KeyString, CurrentNote, "=", ";")
	return result
end
//**********************************************************************************************************
//**********************************************************************************************************


static Function IR3B_ExtractMetadataFromList()
	
	Wave/T ListOfAvailableData=root:Packages:Irena:MetadataBrowser:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:Irena:MetadataBrowser:SelectionOfAvailableData
	variable i, imax=numpnts(ListOfAvailableData)
	For(i=0;i<imax;i+=1)
		if(SelectionOfAvailableData[i])
			//print "Extracting data from "+ListOfAvailableData[i]
			IR3B_ExtrMtdtFromOneFolder(ListOfAvailableData[i])
		endif	
	endfor
	print "Extracted data from "+num2str(sum(SelectionOfAvailableData))+"   folder with data"
end
//**********************************************************************************************************
//**********************************************************************************************************
static Function IR3B_ExtrMtdtFromOneFolder(FolderNameStr)
	string FolderNameStr

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:MetadataBrowser					//go into the folder
	SVAR SaveToFoldername = root:Packages:Irena:MetadataBrowser:SaveToFoldername
	SVAR DataStartFolder=root:Packages:Irena:MetadataBrowser:DataStartFolder
	SVAR DataFolderName=root:Packages:Irena:MetadataBrowser:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena:MetadataBrowser:IntensityWaveName
	NewDataFOlder/O/S $(SaveToFoldername) 
	//to decide if this value is number of string...
	//print GrepString("Sample1", "^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$")
	// prints 1 for number, 0 for string. 
	if(strlen(FolderNameStr)>0)		//if strlen(FolderNameStr)=0, this is called from other otherols and all is set here... 
		IR3C_SelectWaveNamesData("Irena:MetadataBrowser", FolderNameStr)			//this routine will preset names in strings as needed
	endif
	Wave/Z SourceIntWv=$(DataFolderName+IntensityWaveName)
	if(!WaveExists(SourceIntWv))
		DoAlert /T="Incorrectly defined data type" 0, "Please, check definition of data type, it seems incorrectly defined yet"
		SetDataFolder oldDf
		abort 
	endif
	//OK, this is list of stuff we can get values from...
	string CurrentNote=note(SourceIntWv)
	//now which values?
	Wave/T listofItemsWave=root:Packages:Irena:MetadataBrowser:SeletectedItems	
	variable i, imax=numpnts(listofItemsWave)
	variable TimeInSeconds
	string KeyString, ValueString, CleanKeyName
	Wave/Z/T FolderNameWv
	if(!WaveExists(FolderNameWv))
		Make/O/N=0/T FolderNameWv
	endif
	variable NumberOfExtractedItems
	NumberOfExtractedItems = numpnts(FolderNameWv)
	For(i=0;i<imax;i+=1)
		KeyString = listofItemsWave[i] 
		ValueString = StringByKey(KeyString, CurrentNote, "=", ";")
		if(StringMatch(KeyString, "FolderName"))
			Redimension/N=(NumberOfExtractedItems+1) FolderNameWv
			FolderNameWv[NumberOfExtractedItems] = DataFolderName
		elseif(StringMatch(KeyString, "Extract_xyzC"))		//_xyzC, _xyzmin, _xyzpct, _xyz
				Wave/Z TmpWv=TemperatureWv
				if(!WaveExists(TmpWv))
					Make/O/N=(NumberOfExtractedItems+1) TemperatureWv
				endif
				Wave TmpWv=TemperatureWv
				Redimension/N=(NumberOfExtractedItems+1) TmpWv
				TmpWv[NumberOfExtractedItems] = IN2G_IdentifyNameComponent(DataFolderName, "_xyzC")
		elseif(StringMatch(KeyString, "Extract_xyzmin"))		//_xyzC, _xyzmin, _xyzpct, _xyz
				Wave/Z TmpWv=TimeWv
				if(!WaveExists(TmpWv))
					Make/O/N=(NumberOfExtractedItems+1) TimeWv
				endif
				Wave TmpWv=TimeWv
				Redimension/N=(NumberOfExtractedItems+1) TmpWv
				TmpWv[NumberOfExtractedItems] = IN2G_IdentifyNameComponent(DataFolderName, "_xyzmin")
		elseif(StringMatch(KeyString, "Extract_xyz"))		//_xyzC, _xyzmin, _xyzpct, _xyz
				Wave/Z TmpWv=OrderWv
				if(!WaveExists(TmpWv))
					Make/O/N=(NumberOfExtractedItems+1) OrderWv
				endif
				Wave TmpWv=OrderWv
				Redimension/N=(NumberOfExtractedItems+1) OrderWv
				TmpWv[NumberOfExtractedItems] = IN2G_IdentifyNameComponent(DataFolderName, "_xyz")
		elseif(StringMatch(KeyString, "Extract_xyzpct"))		//_xyzC, _xyzmin, _xyzpct, _xyz
				Wave/Z TmpWv=PercentWv
				if(!WaveExists(TmpWv))
					Make/O/N=(NumberOfExtractedItems+1) PercentWv
				endif
				Wave TmpWv=PercentWv
				Redimension/N=(NumberOfExtractedItems+1) PercentWv
				TmpWv[NumberOfExtractedItems] = IN2G_IdentifyNameComponent(DataFolderName, "_xyzpct")
		//done with special name based waves... 
		else		///all others. 
			if(strlen(ValueString)>1)			//if "", we cannot process it... 
				if(GrepString(ValueString, "^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$"))		//this is number
					CleanKeyName = CleanupName(KeyString[0,31], 0)
					Wave/Z TmpWv=$(CleanKeyName)
					if(!WaveExists(TmpWv))
						Make/O/N=(NumberOfExtractedItems+1) $(CleanKeyName)
					endif
					Wave TmpWv=$(CleanKeyName)
					Redimension/N=(NumberOfExtractedItems+1) TmpWv
					TmpWv[NumberOfExtractedItems] = str2num(ValueString)
				else						//string, check if not date...
					TimeInSeconds = IN2G_ConvertTimeStringToSecs(ValueString)
					if(numtype(TimeInSeconds)==0)		//looks like time!
						CleanKeyName = CleanupName(KeyString[0,24], 0)+"Time"
						Wave/Z TmpTimeWv=$(CleanKeyName)
						if(!WaveExists(TmpStrWv))
							Make/O/N=(NumberOfExtractedItems+1) $(CleanKeyName)
						endif
						Wave TmpTimeWv=$(CleanKeyName)
						Redimension/N=(NumberOfExtractedItems+1) TmpTimeWv
						TmpTimeWv[NumberOfExtractedItems] = TimeInSeconds
					else		//ok, this is really string now... 
						CleanKeyName = CleanupName(KeyString[0,31], 0)
						Wave/Z/T TmpStrWv=$(CleanKeyName)
						if(!WaveExists(TmpStrWv))
							Make/O/N=(NumberOfExtractedItems+1)/T $(CleanKeyName)
						endif
						Wave/T TmpStrWv=$(CleanKeyName)
						Redimension/N=(NumberOfExtractedItems+1) TmpStrWv
						TmpStrWv[NumberOfExtractedItems] = ValueString
					endif
				endif
			endif
		endif

	endfor	

	SetDataFolder oldDf
	return 1

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3B_DisplayWaveNote(FolderNameStr)
	string FolderNameStr
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:MetadataBrowser					//go into the folder
		SVAR DataStartFolder=root:Packages:Irena:MetadataBrowser:DataStartFolder
		SVAR DataFolderName=root:Packages:Irena:MetadataBrowser:DataFolderName
		SVAR IntensityWaveName=root:Packages:Irena:MetadataBrowser:IntensityWaveName
		SVAR QWavename=root:Packages:Irena:MetadataBrowser:QWavename
		SVAR ErrorWaveName=root:Packages:Irena:MetadataBrowser:ErrorWaveName
		SVAR dQWavename=root:Packages:Irena:MetadataBrowser:dQWavename
		NVAR UseIndra2Data=root:Packages:Irena:MetadataBrowser:UseIndra2Data
		NVAR UseQRSdata=root:Packages:Irena:MetadataBrowser:UseQRSdata
		NVAR useResults=root:Packages:Irena:MetadataBrowser:useResults
		SVAR DataSubType = root:Packages:Irena:MetadataBrowser:DataSubType
		//these are variables used by the control procedure
		NVAR  UseUserDefinedData=  root:Packages:Irena:MetadataBrowser:UseUserDefinedData
		NVAR  UseModelData = root:Packages:Irena:MetadataBrowser:UseModelData
		SVAR DataFolderName  = root:Packages:Irena:MetadataBrowser:DataFolderName 
		SVAR IntensityWaveName = root:Packages:Irena:MetadataBrowser:IntensityWaveName
		SVAR QWavename = root:Packages:Irena:MetadataBrowser:QWavename
		SVAR ErrorWaveName = root:Packages:Irena:MetadataBrowser:ErrorWaveName
		//graph control variable
		//SVAR GraphUserTitle=root:Packages:Irena:MetadataBrowser:GraphUserTitle
		//SVAR GraphWindowName=root:Packages:Irena:MetadataBrowser:GraphWindowName
		SVAR ResultsDataTypesLookup=root:Packages:IrenaControlProcs:ResultsDataTypesLookup
		//Grep controls  
		SVAR GrepItemNameString=root:Packages:Irena:MetadataBrowser:GrepItemNameString
		//SVAR ListOfDefinedDataPlots=root:Packages:Irena:MetadataBrowser:ListOfDefinedDataPlots
		if(strlen(FolderNameStr)>0)		//if strlen(FolderNameStr)=0, this is called from other otherols and all is set here... 
			IR3C_SelectWaveNamesData("Irena:MetadataBrowser", FolderNameStr)			//this routine will preset names in strings as needed
		endif
		Wave/Z SourceIntWv=$(DataFolderName+IntensityWaveName)
		if(!WaveExists(SourceIntWv))
			DoAlert /T="Incorrectly defined data type" 0, "Please, check definition of data type, it seems incorrectly defined yet"
			SetDataFolder oldDf
			abort 
		endif
		string CurrentNote=note(SourceIntWv)
		
		WAVE/T ListOfWaveNoteItems = root:Packages:Irena:MetadataBrowser:ListOfWaveNoteItems
		WAVE	 SelectionOfWaveNoteItems = root:Packages:Irena:MetadataBrowser:SelectionOfWaveNoteItems

		Wave/T w = ListToTextWave(CurrentNote, ";")
		Grep/E=GrepItemNameString w as w
		REDIMENSION/N=(numpnts(w)) SelectionOfWaveNoteItems, ListOfWaveNoteItems
		ListOfWaveNoteItems = w
		SelectionOfWaveNoteItems=0

	SetDataFolder oldDf
	return 1
end
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3B_InitMetadataBrowser()	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	string ListOfVariables
	string ListOfStrings
	variable i
		
	if (!DataFolderExists("root:Packages:Irena:MetadataBrowser"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena
		NewDataFolder/O root:Packages:Irena:MetadataBrowser
	endif
	SetDataFolder root:Packages:Irena:MetadataBrowser					//go into the folder

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;DataUnits;"
	ListOfStrings+="DataStartFolder;DataMatchString;FolderSortString;FolderSortStringAll;"
	ListOfStrings+="GrepItemNameString;"
	ListOfStrings+="SelectedResultsTool;SelectedResultsType;ResultsGenerationToUse;"
	ListOfStrings+="DataSubTypeUSAXSList;DataSubTypeResultsList;DataSubType;"
	ListOfStrings+="SaveToFoldername;"
	ListOfStrings+="QvecLookupUSAXS;ErrorLookupUSAXS;dQLookupUSAXS;"
//	ListOfStrings+="ListOfDefinedStyles;SelectedStyle;ListOfDefinedDataPlots;SelectedDataPlot;"

	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;"
	ListOfVariables+="InvertGrepSearch;"
//	ListOfVariables+="LogXAxis;LogYAxis;MajorGridXaxis;MajorGridYaxis;MinorGridXaxis;MinorGridYaxis;"
//	ListOfVariables+="Colorize;UseSymbols;UseLines;SymbolSize;LineThickness;"
//	ListOfVariables+="XOffset;YOffset;DisplayErrorBars;ApplyFormatingEveryTime;"
//	ListOfVariables+="AddLegend;UseOnlyFoldersInLegend;LegendSize;"
	
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
	
	SVAR QvecLookupUSAXS
	QvecLookupUSAXS="R_Int=R_Qvec;Blank_R_Int=Blank_R_Qvec;SMR_Int=SMR_Qvec;DSM_Int=DSM_Qvec;USAXS_PD=Ar_encoder;Monitor=Ar_encoder;"
	SVAR ErrorLookupUSAXS
	ErrorLookupUSAXS="R_Int=R_Error;Blank_R_Int=Blank_R_error;SMR_Int=SMR_Error;DSM_Int=DSM_error;"
	SVAR dQLookupUSAXS
	dQLookupUSAXS="SMR_Int=SMR_dQ;DSM_Int=DSM_dQ;"
	
	SVAR SaveToFoldername
	if(strlen(SaveToFoldername)<5)
		SaveToFoldername="root:SavedMetadata"
	endif
//	SVAR GraphWindowName
//	GraphUserTitle=""
//	GraphWindowName=stringFromList(0,WinList("MultiDataPlot_*", ";", "WIN:1" ))
//	if(strlen(GraphWindowName)<2)
//		GraphWindowName="---"
//	endif
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
	
//	NVAR LegendSize
//	if(LegendSize<8)
//		LegendSize=12
//	endif
//	NVAR UseSymbols
//	NVAR UseLines
//	NVAR Colorize
//	NVAR SymbolSize
//	NVAR LineThickness
//	NVAR AddLegend
//	NVAR UseOnlyFoldersInLegend
//	NVAR LegendSize
//	if(UseSymbols+UseLines < 1)			//seems to start new tool
//		UseLines = 1
//		Colorize = 1
//		SymbolSize = 2
//		LineThickness = 2
//		AddLegend = 1
//		UseOnlyFoldersInLegend = 1
//		LegendSize = 12
//	endif
	
	Make/O/T/N=(0) ListOfAvailableData, ListOfWaveNoteItems
	Make/O/N=(0) SelectionOfAvailableData, SelectionOfWaveNoteItems
	Make/O/T/N=(1) SeletectedItems
	Make/O/N=(1) SelectionOfSelectedItems
	Wave/T SeletectedItems
	SeletectedItems[0]="FolderName"
	Wave SelectionOfSelectedItems
	SelectionOfSelectedItems = 0
	SetDataFolder oldDf

end
//**************************************************************************************
//**************************************************************************************











///******************************************************************************************
///******************************************************************************************
///			Data mining tool procedrues. 
///******************************************************************************************
///******************************************************************************************
//**********************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2M_DataMinerPanel()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:DataMiner
	SVAR DataFolderName=root:Packages:DataMiner:DataFolderName
	DataFolderName="---"

	//PauseUpdate    		// building window...
	NewPanel /K=1 /W=(2.25,43.25,390,690) as "Data mining tool"
	DoWindow/C DataMiningTool
	
	string AllowedIrenaTypes="DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;R_Int;"
	IR2C_AddDataControls("DataMiner","DataMiningTool",AllowedIrenaTypes,"AllCurrentlyAllowedTypes","","","","", 0,0)
		PopupMenu SelectDataFolder proc=IR2M_DataFolderPopMenuProc
		//PopupMenu SelectDataFolder value=#DataFolderName+"+IR2P_GenStringOfFolders()"
		popupmenu QvecDataName, pos={500,500},disable=1
		popupmenu IntensityDataName, pos={500,500}, disable=1
		popupmenu ErrorDataName, pos={500,500}, disable=1
		popupmenu SelectDataFolder, title="Test data folder"

	TitleBox MainTitle title="\Zr200Data mining tool panel",pos={20,0},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={350,24},anchor=MC,fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,160},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info1 title="\Zr140Test folder",pos={10,30},frame=0,fstyle=3, fixedSize=1,size={80,20},fColor=(0,0,52224)
	TitleBox Info2 title="\Zr140Which data:",pos={10,170},frame=0,fstyle=3, fixedSize=1,size={150,20},fColor=(0,0,52224)
	TitleBox Info6 title="\Zr140Output Options:",pos={10,440},frame=0,fstyle=3, fixedSize=0,size={40,15},fColor=(0,0,52224)
	TitleBox FakeLine2 title=" ",fixedSize=1,size={330,3},pos={16,420},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)

	SVAR StartFolder
	PopupMenu StartFolder,pos={10,100},size={180,20},proc=IR2M_PanelPopupControl,title="Start Folder", help={"Select folder where to start. Only subfolders will be searched"}
	PopupMenu StartFolder,mode=(WhichListItem(StartFolder, IR2M_ListFoldersWithSubfolders("root:", 25))+1),value=  #"IR2M_ListFoldersWithSubfolders(\"root:\", 25)"
	SetVariable FolderMatchString,value= root:Packages:DataMiner:FolderMatchString,noProc, frame=1
	SetVariable FolderMatchString,pos={10,130},size={350,25},title="Folder Match String (RegEx):", help={"Optional Regular expression to match folder name to."}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)
	Button GetHelp,pos={305,105},size={80,15},fColor=(65535,32768,32768), proc=IR2M_DataMinerPanelButtonProc,title="Get Help", help={"Open www manual page for this tool"}


//	ListOfVariables+="MineVariables;MineStrings;MineWaves;MineWavenotes;"
	CheckBox MineVariables,pos={5,200},size={80,14},proc= IR2M_DataMinerCheckProc,title="Variable?"
	CheckBox MineVariables,variable= root:Packages:DataMiner:MineVariables, help={"Is the info stored as variable?"}
	CheckBox MineStrings,pos={100,200},size={80,14},proc= IR2M_DataMinerCheckProc,title="String?"
	CheckBox MineStrings,variable= root:Packages:DataMiner:MineStrings, help={"Is the info stored as string?"}
	CheckBox MineWavenotes,pos={195,200},size={80,14},proc= IR2M_DataMinerCheckProc,title="Wave notes?"
	CheckBox MineWavenotes,variable= root:Packages:DataMiner:MineWavenotes, help={"Info in wave notes?"}
	CheckBox MineWaves,pos={290,200},size={80,14},proc= IR2M_DataMinerCheckProc,title="Waves?"
	CheckBox MineWaves,variable= root:Packages:DataMiner:MineWaves, help={"Waves - you can only plot the waves matching some pattern?"}

	CheckBox MineLatestGenerationWaves,pos={195,220},size={80,14},proc= IR2M_DataMinerCheckProc,title="Latest generation (results)?"
	CheckBox MineLatestGenerationWaves,variable= root:Packages:DataMiner:MineLatestGenerationWaves, help={"For Waves and Wavenotes, picks the last generation found?"}

//Waves_Xtemplate;Waves_Ytemplate;Waves_Etemplate
	//Graph controls
	SetVariable Waves_Xtemplate,variable= root:Packages:DataMiner:Waves_Xtemplate,noProc, frame=1, bodywidth=220
	SetVariable Waves_Xtemplate,pos={3,260},size={280,25},title="X data:", help={"Template for X data waves"}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)
	SetVariable Waves_Ytemplate,variable= root:Packages:DataMiner:Waves_Ytemplate,noProc, frame=1,bodywidth=220
	SetVariable Waves_Ytemplate,pos={3,280},size={280,25},title="Y data:", help={"Template for Y data waves"}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)
	SetVariable Waves_Etemplate,variable= root:Packages:DataMiner:Waves_Etemplate,noProc, frame=1, bodywidth=220
	SetVariable Waves_Etemplate,pos={3,300},size={280,25},title="Error data:", help={"Template for Error data waves"}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)
	Button Waves_ReadX, pos={300,260},size={80,15}, proc=IR2M_DataMinerPanelButtonProc,title="Read X", help={"Read name from table"}
	Button Waves_ReadY, pos={300,280},size={80,15}, proc=IR2M_DataMinerPanelButtonProc,title="Read Y", help={"Read name from table"}
	Button Waves_ReadE, pos={300,300},size={80,15}, proc=IR2M_DataMinerPanelButtonProc,title="Read Error", help={"Read name from table"}

	//Waves notebook controls
	//
	Button Others_Read, pos={10,245},size={100,15}, proc=IR2M_DataMinerPanelButtonProc,title="Add to list", help={"Add selected item to list of searched"}
	Button Others_Clear, pos={150,245},size={100,15}, proc=IR2M_DataMinerPanelButtonProc,title="Clear list", help={"Reset the list oif searched items..."}

	ListBox SelectedItems,pos={10,270},size={330,150}
	ListBox SelectedItems,listWave=root:Packages:DataMiner:SelectedItems
	ListBox SelectedItems selRow= 0//, proc=IR2M_ListBoxProc
	ListBox SelectedItems mode=0,help={"List of items selected to be mined..."}

//	ListOfVariables+="SaveToNotebook;SaveToWaves;SaveToGraph;"
	CheckBox SaveToNotebook,pos={5,480},size={80,14},proc= IR2M_DataMinerCheckProc,title="Save to notebook?"
	CheckBox SaveToNotebook,variable= root:Packages:DataMiner:SaveToNotebook, help={"Info will be stored in notebook."}
	CheckBox SaveToWaves,pos={130,480},size={80,14},proc= IR2M_DataMinerCheckProc,title="Save to waves?"
	CheckBox SaveToWaves,variable= root:Packages:DataMiner:SaveToWaves, help={"Info will be stored in waves"}
	CheckBox SaveToGraph,pos={255,480},size={80,14},proc= IR2M_DataMinerCheckProc,title="Create graph?"
	CheckBox SaveToGraph,variable= root:Packages:DataMiner:SaveToGraph, help={"Data will be graphed"}


	SetVariable Others_FolderForWaves,variable= root:Packages:DataMiner:Others_FolderForWaves,proc=IR2M_MinerSetVarProc, frame=1
	SetVariable Others_FolderForWaves,pos={3,455},size={350,25},title="Folder to save waves to   root:", help={"Folder to save waves with results. "}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)

//	ListOfVariables+="GraphLogX;GraphLogY;GraphColorScheme1;GraphColorScheme2;GraphColorScheme3;"
	CheckBox GraphLogX,pos={155,500},size={80,14},proc= IR2M_DataMinerCheckProc,title="log X axis?"
	CheckBox GraphLogX,variable= root:Packages:DataMiner:GraphLogX, help={"Graph with log X axis"}
	CheckBox GraphLogY,pos={255,500},size={80,14},proc= IR2M_DataMinerCheckProc,title="log Y axis?"
	CheckBox GraphLogY,variable= root:Packages:DataMiner:GraphLogY, help={"Graph with log Y axis"}

	CheckBox GraphColorScheme1,pos={155,515},size={80,14},proc= IR2M_DataMinerCheckProc,title="Color scheme 1?"
	CheckBox GraphColorScheme1,variable= root:Packages:DataMiner:GraphColorScheme1, help={"One of preselected color schemes for graph"}
	CheckBox GraphColorScheme2,pos={255,515},size={80,14},proc= IR2M_DataMinerCheckProc,title="Color scheme 2?"
	CheckBox GraphColorScheme2,variable= root:Packages:DataMiner:GraphColorScheme2, help={"One of preselected color schemes for graph"}
	CheckBox GraphColorScheme3,pos={155,530},size={80,14},proc= IR2M_DataMinerCheckProc,title="Color scheme 3?"
	CheckBox GraphColorScheme3,variable= root:Packages:DataMiner:GraphColorScheme3, help={"One of preselected color schemes for graph"}
	NVAR GraphFontSize=root:Packages:DataMiner:GraphFontSize
	PopupMenu GraphFontSize,pos={155,550},size={180,20},proc=IR2M_PanelPopupControl,title="Legend font size", help={"Select font size for legend to be used."}
	PopupMenu GraphFontSize,mode=WhichListItem(num2str(GraphFontSize),  "6;8;10;12;14;16;18;20;22;24;")+1,value= "06;08;10;12;14;16;18;20;22;24;"//, popvalue="10"


	// 
	CheckBox WavesNbk_contains,pos={20,500},size={80,14},proc= IR2M_DataMinerCheckProc,title="Find present?"
	CheckBox WavesNbk_contains,variable= root:Packages:DataMiner:WavesNbk_contains, help={"Find Folders which contain these waves..."}
	CheckBox WavesNbk_NOTcontains,pos={20,520},size={80,14},proc= IR2M_DataMinerCheckProc,title="Find not present?"
	CheckBox WavesNbk_NOTcontains,variable= root:Packages:DataMiner:WavesNbk_NOTcontains, help={"Find folders which do not contain these waves..."}

//	Button LoadAndGraphData, pos={100,280},size={180,20}, proc=IR2E_InputPanelButtonProc,title="Load data", help={"Load data into the tool, generate graph and display notes if checkboxes are checked."}
//
//

	Button SearchAndMineData, pos={10,615},size={180,20}, proc=IR2M_DataMinerPanelButtonProc,title="Mine data", help={"Run data miner"}
	Button PullUpNotebook, pos={200,590},size={180,20}, proc=IR2M_DataMinerPanelButtonProc,title="Get notebook with results", help={"Get notebook with results if it was closed"}
	Button KillNotebook, pos={200,615},size={180,20}, proc=IR2M_DataMinerPanelButtonProc,title="Kill notebook with results", help={"Close (kill totally) notebook with results"}

	IR2M_FixPanelControls()
	setDataFolder oldDF
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2M_DataFolderPopMenuProc(Pa) : PopupMenuControl
	STRUCT WMPopupAction &Pa

//	Pa.win = WinName(0,64)
	if(Pa.eventCode!=2)
		return 0
	endif
	//IR2C_PanelPopupControl(ctrlName,popNum,popStr) 
	IR2C_PanelPopupControl(Pa) 
	
	IR2M_MakePanelWithListBox(0)
	//IR1_UpdatePanelVersionNumber("ItemsInFolderPanel", IR2MversionNumber,1)
End
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_MinerSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	variable i
	DFref oldDf= GetDataFolderDFR()

	
	
	if(cmpstr(ctrlName,"Others_FolderForWaves")==0)
		SVAR Others_FolderForWaves= root:Packages:DataMiner:Others_FolderForWaves
		//add ":" at the end, if not there
		if(cmpstr(Others_FolderForWaves[strlen(Others_FolderForWaves)-1,inf],":")!=0)
			Others_FolderForWaves+=":"
		endif
		setDataFolder root:
		//Now make the folder, so it exists... Assume more than single level...
		For(i=0;i<ItemsInList(Others_FolderForWaves,":");I+=1)
			NewDataFolder/O/S $(stringFromList(i,Others_FolderForWaves,":"))
		endfor
	endif
	
	setDataFolder OldDf
End
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function/S IR2M_ListFoldersWithSubfolders(startDF, levels)
        String startDF               // startDF requires trailing colon.
        Variable levels		//set 1 for long type and 0 for short type return
        			// 
        String dfSave
        String list = "", templist, tempWvName, tempWaveType
        variable i, skipRest, j
        
        dfSave = GetDataFolder(1)
  	
  	if (!DataFolderExists(startDF))
  		return ""
  	endif
  	
        SetDataFolder startDF
        
        templist = DataFolderDir(1)
//        skipRest=0
//        string AllWaves = ";"+WaveList("*",";","")
////	For(i=0;i<ItemsInList(WaveList("*",";",""));i+=1)
////		tempWvName = StringFromList(i, WaveList("*",";","") ,";")
////	 //   	 if (Stringmatch(WaveList("*",";",""),WaveTypes))
//		For(j=0;j<ItemsInList(WaveTypes);j+=1)
//
//			if(skipRest || strlen(AllWaves)<2)
//				//nothing needs to be done
//			else
//				tempWaveType = stringFromList(j,WaveTypes)
//			    	 if (Stringmatch(AllWaves,"*;"+tempWaveType+";*") && skipRest==0)
//					if (LongShortType)
//				            		list += startDF + ";"
//							skipRest=1
//				      	else
//			     		      		list += GetDataFolder(0) + ";"
//		      					skipRest=1
//			      		endif
//		        	endif
//		      //  endfor
//	        endif
//   	     endfor
	templist=templist[8,strlen(templist)-3]
	if(strlen(tempList)>0)
		list=GetDataFolder(1)+";"
	endif
        levels -= 1
        if (levels <= 0)
                return list
        endif
        
        String subDF
        Variable index = 0
        do
                String temp
                temp = PossiblyQuoteName(GetIndexedObjName(startDF, 4, index))     	// Name of next data folder.
                if (strlen(temp) == 0)
                        break                                                                           			// No more data folders.
                endif
     	              subDF = startDF + temp + ":"
            		 list += IR2M_ListFoldersWithSubfolders(subDF, levels)       	// Recurse.
                index += 1
        while(1)
        
        SetDataFolder(dfSave)
        return list
End
//**********************************************************************************************
//**********************************************************************************************

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
//popup procedure
Function IR2M_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:DataMiner

	NVAR GraphFontSize=root:Packages:DataMiner:GraphFontSize

	if (cmpstr(ctrlName,"GraphFontSize")==0)
		GraphFontSize=str2num(popStr)
		IR2M_AppendLegend(GraphFontSize)
	endif
	if (cmpstr(ctrlName,"StartFolder")==0)
		SVAR StartFolder
		StartFolder=popStr
	endif
	
	
	setDataFolder oldDF
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2M_FixPanelControls()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:DataMiner
	DoWindow/F DataMiningTool
	
	NVAR MineVariables = root:Packages:DataMiner:MineVariables
	NVAR MineStrings = root:Packages:DataMiner:MineStrings
	NVAR MineWaves = root:Packages:DataMiner:MineWaves
	NVAR MineWavenotes = root:Packages:DataMiner:MineWavenotes

	NVAR SaveToNotebook = root:Packages:DataMiner:SaveToNotebook
	NVAR SaveToWaves = root:Packages:DataMiner:SaveToWaves
	NVAR SaveToGraph = root:Packages:DataMiner:SaveToGraph

	if(MineWaves)
		CheckBox SaveToNotebook,win=DataMiningTool, disable=0
		CheckBox SaveToWaves,win=DataMiningTool, disable=1
		CheckBox SaveToGraph,win=DataMiningTool, disable=0
		SetVariable Waves_Xtemplate,win=DataMiningTool, disable=0
		SetVariable Waves_Ytemplate,win=DataMiningTool, disable=0
		SetVariable Waves_Etemplate,win=DataMiningTool, disable=0
		Button Waves_ReadX,win=DataMiningTool, disable=0
		Button Waves_ReadY,win=DataMiningTool, disable=0
		Button Waves_ReadE,win=DataMiningTool, disable=0
		ListBox SelectedItems,win=DataMiningTool, disable=1
		Button Others_Read,win=DataMiningTool, disable=1
		Button Others_Clear,win=DataMiningTool, disable=1
		SetVariable Others_FolderForWaves, disable=1

	endif
	if(MineVariables || MineStrings || MineWavenotes)
		CheckBox SaveToNotebook,win=DataMiningTool, disable=0
		CheckBox SaveToWaves,win=DataMiningTool, disable=0
		CheckBox SaveToGraph,win=DataMiningTool, disable=1
		SetVariable Waves_Xtemplate,win=DataMiningTool, disable=1
		SetVariable Waves_Ytemplate,win=DataMiningTool, disable=1
		SetVariable Waves_Etemplate,win=DataMiningTool, disable=1
		Button Waves_ReadX,win=DataMiningTool, disable=1
		Button Waves_ReadY,win=DataMiningTool, disable=1
		Button Waves_ReadE,win=DataMiningTool, disable=1
		ListBox SelectedItems,win=DataMiningTool, disable=0
		Button Others_Read,win=DataMiningTool, disable=0
		Button Others_Clear,win=DataMiningTool, disable=0
	endif

	if(MineVariables || MineStrings || MineWavenotes && SaveToWaves)
		SetVariable Others_FolderForWaves, disable=0
	else
		SetVariable Others_FolderForWaves, disable=1
	endif

	if(MineWaves && SaveToGraph)
		CheckBox GraphLogX, disable=0
		CheckBox GraphLogY, disable=0
		CheckBox GraphColorScheme1, disable=0
		CheckBox GraphColorScheme2, disable=0
		CheckBox GraphColorScheme3, disable=0
		PopupMenu GraphFontSize, disable=0
	else
		CheckBox GraphLogX, disable=1
		CheckBox GraphLogY, disable=1
		CheckBox GraphColorScheme1, disable=1
		CheckBox GraphColorScheme2, disable=1
		CheckBox GraphColorScheme3, disable=1	
		PopupMenu GraphFontSize, disable=1
	endif	
	if(MineWaves && SaveToNotebook)
		CheckBox WavesNbk_contains, disable=0
		CheckBox WavesNbk_NOTcontains, disable=0
	else
		CheckBox WavesNbk_contains, disable=1
		CheckBox WavesNbk_NOTcontains, disable=1
	endif	

	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_DataMinerPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:DataMiner

	if(cmpstr(ctrlName,"Waves_ReadX")==0)
		IR2M_ReadWavesFromListBox("Waves_X")
	endif
	if(cmpstr(ctrlName,"Waves_ReadY")==0)
		IR2M_ReadWavesFromListBox("Waves_Y")
	endif
	if(cmpstr(ctrlName,"Waves_ReadE")==0)
		IR2M_ReadWavesFromListBox("Waves_E")
	endif
	if(stringmatch(ctrlName,"GetHelp"))
		IN2G_OpenWebManual("Irena/DataMining.html")
	endif

	if(cmpstr(ctrlName,"SearchAndMineData")==0)
		IR2M_MineTheDataFunction()
	endif
	if(cmpstr(ctrlName,"PullUpNotebook")==0)
		IR2M_PullUpNotebook()
	endif
	if(cmpstr(ctrlName,"KillNotebook")==0)
		IR2M_KillNotebook()
	endif

	if(cmpstr(ctrlName,"Others_Read")==0)
		IR2M_ReadOthersIntoLists()
	endif
	if(cmpstr(ctrlName,"Others_Clear")==0)
		IR2M_ClearOthersLists()
	endif
	
	setDataFolder oldDF
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_ReadOthersIntoLists()


	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:DataMiner

	SVAR Variables_ListToFind
	SVAR Strings_ListToFind
	SVAR WaveNotes_ListToFind
	NVAR MineVariables = root:Packages:DataMiner:MineVariables
	NVAR MineStrings = root:Packages:DataMiner:MineStrings
	NVAR MineWaves = root:Packages:DataMiner:MineWaves
	NVAR MineWavenotes = root:Packages:DataMiner:MineWavenotes
	NVAR UseIndra2Data = root:Packages:DataMiner:UseIndra2Data
	NVAR UseQRSdata = root:Packages:DataMiner:UseQRSdata
	wave/T ItemsInFolder =root:Packages:DataMiner:ItemsInFolder
	wave/T WaveNoteList =root:Packages:DataMiner:WaveNoteList
	variable ItmsFldr, WvNote, i
	string TempVValue
	wave WaveNoteListSelections =root:Packages:DataMiner:WaveNoteListSelections
	wave ItemsInFolderSelections = root:Packages:DataMiner:ItemsInFolderSelections
	
	if(MineVariables)
		//ControlInfo  /W=ItemsInFolderPanel ItemsInCurrentFolder
		for(i=0;i<numpnts(ItemsInFolderSelections);i+=1)
			if(ItemsInFolderSelections[i]>0 && FindListItem(ItemsInFolder[i],Variables_ListToFind)<0)
				Variables_ListToFind+= ItemsInFolder[i]+";"
			endif
		endfor
	endif
	if(MineStrings)
		//ControlInfo  /W=ItemsInFolderPanel ItemsInCurrentFolder
		for(i=0;i<numpnts(ItemsInFolderSelections);i+=1)
			if(ItemsInFolderSelections[i]>0&& FindListItem(ItemsInFolder[i],Strings_ListToFind)<0)
				Strings_ListToFind+= ItemsInFolder[i]+";"
			endif
		endfor
	endif
	if(MineWavenotes)
		ControlInfo  /W=ItemsInFolderPanel ItemsInCurrentFolder
		ItmsFldr = V_Value
		//ControlInfo  /W=ItemsInFolderPanel WaveNoteList
		for(i=0;i<numpnts(WaveNoteListSelections);i+=1)
			WvNote = i
			//WvNote = V_Value
			string tempKey
			tempKey = StringFromList(0,WaveNoteList[WvNote],"=")
			if(UseQRSdata)		//wave containts also name of the folder, so this will keep failing all the time... 
								//however, the first letter here indicates which wave to look at...
				if(WaveNoteListSelections[i]>0&& FindListItem(ItemsInFolder[ItmsFldr]+":"+tempKey,WaveNotes_ListToFind)<0)
					WaveNotes_ListToFind+= (ItemsInFolder[ItmsFldr])[0]+"_qrs_>"+tempKey+";"
				endif
			else
				if(WaveNoteListSelections[i]>0&& FindListItem(ItemsInFolder[ItmsFldr]+":"+tempKey,WaveNotes_ListToFind)<0)
					WaveNotes_ListToFind+= ItemsInFolder[ItmsFldr]+">"+tempKey+";"
				endif
			endif
		endfor
	endif


	
	IR2M_SyncSearchListAndListBox()
	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_ClearOthersLists()


	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:DataMiner

	SVAR Variables_ListToFind
	SVAR Strings_ListToFind
	SVAR WaveNotes_ListToFind

	Variables_ListToFind=""
	Strings_ListToFind=""
	WaveNotes_ListToFind=""
	
	IR2M_SyncSearchListAndListBox()
	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_PullUpNotebook()

	IR2M_CreateNotebook()	
end

Function IR2M_KillNotebook()

	string nbl="DataMinerNotebook"
	    
	if (strsearch(WinList("*",";","WIN:16"),nbL,0)!=-1) 		///Logbook exists
		KillWIndow/Z $nbl
	endif
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2M_MineTheDataFunction()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:DataMiner

	NVAR MineVariables = root:Packages:DataMiner:MineVariables
	NVAR MineStrings = root:Packages:DataMiner:MineStrings
	NVAR MineWaves = root:Packages:DataMiner:MineWaves
	NVAR MineWavenotes = root:Packages:DataMiner:MineWavenotes
	NVAR WavesNbk_contains=root:Packages:DataMiner:WavesNbk_contains
	NVAR WavesNbk_NOTcontains=root:Packages:DataMiner:WavesNbk_NOTcontains

	NVAR SaveToNotebook = root:Packages:DataMiner:SaveToNotebook
	NVAR SaveToWaves = root:Packages:DataMiner:SaveToWaves
	NVAR SaveToGraph = root:Packages:DataMiner:SaveToGraph

	SVAR Waves_Xtemplate=root:Packages:DataMiner:Waves_Xtemplate
	SVAR Waves_Ytemplate=root:Packages:DataMiner:Waves_Ytemplate
	SVAR Waves_Etemplate=root:Packages:DataMiner:Waves_Etemplate
	NVAR GraphFontSize=root:Packages:DataMiner:GraphFontSize
	
	SVAR StartFolder=root:Packages:DataMiner:StartFolder
	string NotebookHeader
	
	if(MineWaves && SaveToNotebook)
		IR2M_CreateNotebook()	
		if(WavesNbk_contains)
			if(strlen(Waves_Etemplate)>0)
				NotebookHeader="Folders containing "+Waves_Xtemplate+" , "+Waves_Ytemplate+" , and "+Waves_Etemplate+"\r"
			elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)>0 && strlen(Waves_Xtemplate)>0)
				NotebookHeader="Folders containing "+Waves_Xtemplate+" and "+Waves_Ytemplate+"\r"
			elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)==0 && strlen(Waves_Xtemplate)>0)
				NotebookHeader="Folders containing "+Waves_Xtemplate+"\r"
			else
				//nothing to do..
				abort
			endif
		else
			if(strlen(Waves_Etemplate)>0)
				NotebookHeader="Folders not containing "+Waves_Xtemplate+" , "+Waves_Ytemplate+" , and "+Waves_Etemplate+"\r"
			elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)>0 && strlen(Waves_Xtemplate)>0)
				NotebookHeader="Folders not containing "+Waves_Xtemplate+" and "+Waves_Ytemplate+"\r"
			elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)==0 && strlen(Waves_Xtemplate)>0)
				NotebookHeader="Folders not containing "+Waves_Xtemplate+"\r"
			else
				//nothing to do..
				abort
			endif
		endif
		IR2M_InsertText(NotebookHeader)
		IN2G_UniversalFolderScan(StartFolder, 25, "IR2M_MineWavesIntoNotebook()")
		IR2M_InsertDateAndTime()
	endif
	if(MineWaves && SaveToGraph)
		IR2M_CreateGraph()
		IN2G_UniversalFolderScan(StartFolder, 25, "IR2M_MineWavesIntoGraph()")
		IR2M_AppendLegend(GraphFontSize)
		IR2M_FormatGraphAsRequested()
	endif
	if((MineVariables || MineStrings || MineWavenotes) && SaveToNotebook)
		IR2M_CreateNotebook()	
		NotebookHeader="Result of search through data "+"\r"
		IR2M_InsertText(NotebookHeader)
		IN2G_UniversalFolderScan(StartFolder, 25, "IR2M_MineOthersIntoNotebook()")
		IR2M_InsertDateAndTime()
	endif
	if((MineVariables || MineStrings || MineWavenotes) && SaveToWaves)
		IR2M_CreateWavestoMineOthers()
		IN2G_UniversalFolderScan(StartFolder, 25, "IR2M_MineOthersIntoWaves()")
		IR2M_ConvertWavestoMineOthers()
		IR2M_CreateOutputTable()
	endif

	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_MineOthersIntoWaves()
	
	
	SVAR Variables_ListToFind=root:Packages:DataMiner:Variables_ListToFind
	SVAR Strings_ListToFind=root:Packages:DataMiner:Strings_ListToFind
	SVAR WaveNotes_ListToFind=root:Packages:DataMiner:WaveNotes_ListToFind
	SVAR Others_FolderForWaves=root:Packages:DataMiner:Others_FolderForWaves
	SVAR FolderMatchString=root:Packages:DataMiner:FolderMatchString

	variable i, tempVal
	string curFolder=GetDataFolder(0)
	string curWvName, curNote, curStrVal
	variable curLength
	
	//if(stringmatch(curFolder, FolderMatchString))
	if(GrepString(curFolder, FolderMatchString))
		if(IR2M_CheckIfSomethingToDo())			
			Wave/T DataFolderName=$("root:"+Others_FolderForWaves+"DataFolderName")
			curLength=numpnts(DataFolderName)
			redimension/N=(curLength+1) DataFolderName
			DataFolderName[curLength]=GetDataFolder(0)
	
			For(i=0;i<ItemsInList(Variables_ListToFind);i+=1)
			 	curWvName=StringFromList(i,Variables_ListToFind)
			 	curWvName = CleanupName(curWvName,1)
				Wave TempWv= $("root:"+Others_FolderForWaves+curWvName)
				redimension/N=(curLength+1) TempWv
				NVAR/Z tempVar = $(curWvName)
				if(NVAR_Exists(tempVar))
					TempWv[curLength]=tempVar
				else
					TempWv[curLength]=NaN
				endif
			endfor
			For(i=0;i<ItemsInList(Strings_ListToFind);i+=1)
			 	curWvName=StringFromList(i,Strings_ListToFind)
			 	curWvName = CleanupName(curWvName,1)
				Wave/T TempWvText= $("root:"+Others_FolderForWaves+curWvName)
				redimension/N=(curLength+1) TempWvText
				SVAR/Z tempStr = $(curWvName)
				if(SVAR_Exists(tempStr))
					TempWvText[curLength]=tempStr
				else
					TempWvText[curLength]=""
				endif
			endfor
			string tempName, FrontPart, EndPart, EndPart2, tempFrontPart
			NVAR MineLatestGenerationWaves = root:Packages:DataMiner:MineLatestGenerationWaves
			For(i=0;i<ItemsInList(WaveNotes_ListToFind,";");i+=1)
					tempName=StringFromList(i,WaveNotes_ListToFind,";")	
					FrontPart=StringFromList(0,tempName,">")				//here goes function, which trunkates these damn names to 5-8 characters....
					tempFrontPart = FrontPart			
					EndPart=StringFromList(1,tempName,">")
					if(!stringmatch(FrontPart, "*_qrs_*" ))
						if(MineLatestGenerationWaves)
							tempFrontPart = IR2M_FindLatestGeneration(FrontPart)
				 			Wave/Z SourceWv=$(tempFrontPart)
				 		else
				 			Wave/Z SourceWv=$(FrontPart)
				 		endif
				 		//Wave/Z SourceWv=$(FrontPart)
				 	else
				 		string ListOfWaves=IN2G_CreateListOfItemsInFolder(GetDataFolder(1), 2)
				 		ListOfWaves = GrepList(ListOfWaves, FrontPart[0] )
				 		tempName = stringfromlist(0, ListOfWaves)
				 		Wave/Z SourceWv=$(tempName)
				 	endif
				if(stringmatch(EndPart,"*:*"))
					EndPart2= StringFromList(ItemsInList(ENdPart,":")-1,EndPart,":")
				else
					EndPart2=EndPart
				endif
				curWvName = IR2M_CreateWaveName(FrontPart,EndPart2)
				Wave/T TempTextWave=$("root:"+Others_FolderForWaves+possiblyQuoteName(curWvName))
				redimension/N=(curLength+1) TempTextWave
				if(WaveExists(SourceWv))
					curNote=note(SourceWv)
					curStrVal = StringByKey(EndPart, curNote , "=") 
					TempTextWave[curLength] = curStrVal
				else
					TempTextWave[curLength] = ""
				endif
			endfor
		endif
	endif
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_isWaveNumbers(ws)
    Wave/T ws
    Variable N=numpnts(ws)
    String wName = UniqueName("isNumbers",1,0)
    Make/N=(N) $wName
    Wave w = $wName
    w = !IR2M_isaNumber(ws[p])
    Variable allNumbers = (!sum(w))
    KillWaves/Z w
    return allNumbers
End


static Function IR2M_isaNumber(in)                // checks if the input string  is ONLY a number
    String in
    String str
    Variable v
    if(strlen(in)==0)
    	return 1
    endif
    sscanf in, "%g%s", v,str
    return (V_flag==1)
End

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2M_ConvertWavestoMineOthers()
	
	
	SVAR Variables_ListToFind=root:Packages:DataMiner:Variables_ListToFind
	SVAR Strings_ListToFind=root:Packages:DataMiner:Strings_ListToFind
	SVAR WaveNotes_ListToFind=root:Packages:DataMiner:WaveNotes_ListToFind
	SVAR Others_FolderForWaves=root:Packages:DataMiner:Others_FolderForWaves
	SVAR FolderMatchString=root:Packages:DataMiner:FolderMatchString

    	String wName = UniqueName("Temp_ConvWv",1,0)
    
	variable i, tempVal
	string curWvName
	DFref oldDf= GetDataFolderDFR()

	SetDataFolder $("root:"+Others_FolderForWaves)
	
//	Wave/T/Z DataFolderName
//	
//	For(i=0;i<ItemsInList(Strings_ListToFind);i+=1)
//	 	curWvName=StringFromList(i,Strings_ListToFind)
//	 	curWvName = CleanupName(curWvName,1)
//		Wave/T CurStrWave= $(curWvName)
//		if(IR2M_isWaveNumbers(CurStrWave))
//			make/O/N=(numpnts(CurStrWave)) $wName
//			Wave TempNumWave = $wName
//			tempNumWave=str2num(CurStrWave)
//			killwaves CurStrWave
//			Duplicate/O tempNumWave, $(curWvName)
//		endif
//	endfor
	For(i=0;i<ItemsInList(WaveNotes_ListToFind);i+=1)
		String TempName, FrontPart, EndPart, EndPart2
		TempName = StringFromList(i,WaveNotes_ListToFind,";")
		FrontPart = StringFromList(0,TempName,">")
		EndPart = StringFromList(1,TempName,">")
		if(stringmatch(EndPart,"*:*"))
			EndPart2=stringFromList(ItemsInList(EndPart,":")-1,EndPart,":")
		else
			EndPart2=EndPart
		endif
		
		curWvName = IR2M_CreateWaveName(FrontPart,EndPart2)
		Wave/T CurStrWave= $(curWvName)
		//if(strlen(CurStrWave)>0)
		if(numpnts(CurStrWave)>0)			//bug found by Igor 7. Not sure what the fixs should be... 
			if(IR2M_isWaveNumbers(CurStrWave))
				make/O/N=(numpnts(CurStrWave)) $wName
				Wave TempNumWave = $wName
				tempNumWave=str2num(CurStrWave)
				killwaves/Z CurStrWave
				Duplicate/O tempNumWave, $(curWvName)
			endif
		endif
	endfor
	KillWaves/Z tempNumWave
	
	setDataFolder OldDf
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2M_CreateWavestoMineOthers()
	
	
	SVAR Variables_ListToFind=root:Packages:DataMiner:Variables_ListToFind
	SVAR Strings_ListToFind=root:Packages:DataMiner:Strings_ListToFind
	SVAR WaveNotes_ListToFind=root:Packages:DataMiner:WaveNotes_ListToFind
	SVAR Others_FolderForWaves=root:Packages:DataMiner:Others_FolderForWaves
	SVAR FolderMatchString=root:Packages:DataMiner:FolderMatchString

	variable i, tempVal
	string curWvName
	DFref oldDf= GetDataFolderDFR()

	if(!DataFolderExists("root:"+Others_FolderForWaves))
		setDataFolder root:
		For(i=0;i<itemsInList(Others_FolderForWaves,":");i+=1)
			NewDataFolder/O/S $(StringFromList(i,Others_FolderForWaves,":"))
		endfor
	endif
	SetDataFolder $("root:"+Others_FolderForWaves)
	
	KillWIndow/Z SearchOutputTable
 	
	Wave/T/Z DataFolderName
	if(WaveExists(DataFoldername))
		DoAlert 1, "Some search results in this folder exists, do you want to overwrite them? If not, click No and change output folder name."
		if(V_flag==2)
			setDataFolder OldDf
			abort
		endif
	endif
	
	
	make/T/O/N=0 DataFolderName
	For(i=0;i<ItemsInList(Variables_ListToFind);i+=1)
	 	curWvName=StringFromList(i,Variables_ListToFind)
	 	curWvName = CleanupName(curWvName,1)
	 	Wave/Z testWv=$(curWvName)
	 	if(WaveExists(testWv))
	 		killWaves/Z testWv
	 	endif
		Make/O/N=0 $(curWvName)
	endfor
	For(i=0;i<ItemsInList(Strings_ListToFind);i+=1)
	 	curWvName=StringFromList(i,Strings_ListToFind)
	 	curWvName = CleanupName(curWvName,1)
	 	Wave/Z testWv=$(curWvName)
	 	if(WaveExists(testWv))
	 		killWaves/Z testWv
	 	endif
		Make/T/O/N=0 $(curWvName)
	endfor
	For(i=0;i<ItemsInList(WaveNotes_ListToFind,";");i+=1)
		String TempName, StartPart, EndPart, EndPart2
		TempName = StringFromList(i,WaveNotes_ListToFind,";")
		StartPart = StringFromList(0,TempName, ">")
		EndPart = StringFromList(1,TempName, ">")
		if(stringMatch(EndPart,"*:*"))
			EndPart2=stringfromlist(ItemsInList(EndPart,":")-1,EndPart,":")
		else
			EndPart2=EndPart
		endif
		curWvName = IR2M_CreateWaveName(StartPart,EndPart2)
	 	Wave/Z testWv=$(curWvName)
	 	if(WaveExists(testWv))
	 		killWaves testWv
	 	endif
		Make/T/O/N=0 $(curWvName)
	endfor

	
	setDataFolder OldDf
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function/T IR2M_CreateWaveName(WaveNameStr,ItemNameStr)
	string WaveNameStr,ItemNameStr

	string finalStr

	 	finalStr=WaveNameStr+"."+ItemNameStr
	 	if(strlen(finalStr)>28)
	 		//tempVal = 28 - strlen(StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":"))
	 		//finalStr=StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":")[0,tempVal]+"."+StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":")
			//treat Separately the offending cases...
			if (stringmatch(finalStr, "*Intensity*"))
				finalStr = ReplaceString("Intensity", finalStr, "Int" , 1 , 10)
			endif 
			if (stringmatch(finalStr, "*Qvector*"))
				finalStr = ReplaceString("Qvector", finalStr, "Qvec" , 1 , 10)
			endif 
			if (stringmatch(finalStr, "*Error*"))
				finalStr = ReplaceString("Error", finalStr, "Err" , 1 , 10)
			endif 
			if (stringmatch(finalStr, "*Volume*"))
				finalStr = ReplaceString("Volume", finalStr, "Vol" , 1 , 10)
			endif 
			if (stringmatch(finalStr, "*Surface*"))
				finalStr = ReplaceString("Surface", finalStr, "Surf" , 1 , 10)
			endif 
			if (stringmatch(finalStr, "*Background*"))
				finalStr = ReplaceString("Background", finalStr, "Bckg" , 1 , 10)
			endif 
			if (stringmatch(finalStr, "*Maximum*"))
				finalStr = ReplaceString("Maximum", finalStr, "Max" , 1 , 10)
			endif 
			if (stringmatch(finalStr, "*Minimum*"))
				finalStr = ReplaceString("Minimum", finalStr, "Min" , 1 , 10)
			endif 
			if (stringmatch(finalStr, "*ModelLSQF2*"))
				finalStr = ReplaceString("ModelLSQF2", finalStr, "Mod2" , 1 , 10)
			endif 
			if (stringmatch(finalStr, "*StructureParam*"))
				finalStr = ReplaceString("StructureParam", finalStr, "SFpar" , 1 , 10)
			endif 

			if (stringmatch(finalStr, "UnifiedFit*"))
				finalStr = ReplaceString("UnifiedFit", finalStr, "UF" , 1 , 1)
			endif 
		endif
	
	 	finalStr = CleanupName(finalStr,1)
	
	
	return finalStr
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_CreateOutputTable()
	//PauseUpdate    		// building window...
	String fldrSav0= GetDataFolder(1)
	
	SVAR Variables_ListToFind=root:Packages:DataMiner:Variables_ListToFind
	SVAR Strings_ListToFind=root:Packages:DataMiner:Strings_ListToFind
	SVAR WaveNotes_ListToFind=root:Packages:DataMiner:WaveNotes_ListToFind
	SVAR Others_FolderForWaves=root:Packages:DataMiner:Others_FolderForWaves
	SVAR FolderMatchString=root:Packages:DataMiner:FolderMatchString

	variable tempVal
	SetDataFolder $("root:"+Others_FolderForWaves)
	KillWIndow/Z SearchOutputTable
 	Edit/K=1/W=(471,48.5,1149,600.5) DataFolderName
	DoWindow/C SearchOutputTable

	variable i
	string curWvName
	DFref oldDf= GetDataFolderDFR()

	setDataFolder $(" root:"+Others_FolderForWaves)
	
	For(i=0;i<ItemsInList(Variables_ListToFind);i+=1)
	 	curWvName=StringFromList(i,Variables_ListToFind)
	 	curWvName = CleanupName(curWvName,1)
		AppendToTable $(curWvName)
	endfor
	For(i=0;i<ItemsInList(Strings_ListToFind);i+=1)
	 	curWvName=StringFromList(i,Strings_ListToFind)
	 	curWvName = CleanupName(curWvName,1)
		AppendToTable $(curWvName)
	endfor
	For(i=0;i<ItemsInList(WaveNotes_ListToFind,";");i+=1)
	
		String TempName, FrontPart, EndPart, EndPart2
		TempName = StringFromList(i,WaveNotes_ListToFind,";")
		FrontPart = StringFromList(0,TempName,">")
		EndPart = StringFromList(1,TempName,">")
		if(stringmatch(EndPart,"*:*"))
			EndPart2=stringFromList(ItemsInList(EndPart,":")-1,EndPart,":")
		else
			EndPart2=EndPart
		endif
		
		curWvName = IR2M_CreateWaveName(FrontPart,EndPart2)
		Wave/T CurStrWave= $(curWvName)
		AppendToTable $(curWvName)
	endfor

	AutoPositionWindow/M=0 /R=DataMiningTool SearchOutputTable

	SetDataFolder fldrSav0
End
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_CheckIfSomethingToDo()

	SVAR Variables_ListToFind=root:Packages:DataMiner:Variables_ListToFind
	SVAR Strings_ListToFind=root:Packages:DataMiner:Strings_ListToFind
	SVAR WaveNotes_ListToFind=root:Packages:DataMiner:WaveNotes_ListToFind
	NVAR MineLatestGenerationWaves = root:Packages:DataMiner:MineLatestGenerationWaves
	string tempName
	
	variable i
	string curNote
	For(i=0;i<ItemsInList(Variables_ListToFind);i+=1)
	 	NVAR/Z testVar=$(StringFromList(i,Variables_ListToFind))
		if(NVAR_Exists(testVar))
			return 1
		endif
	endfor
	For(i=0;i<ItemsInList(Strings_ListToFind);i+=1)
	 	SVAR/Z testStr=$(StringFromList(i,Strings_ListToFind))
		if(SVAR_Exists(testStr))
			return 1
		endif
	endfor
	For(i=0;i<ItemsInList(WaveNotes_ListToFind,";");i+=1)
		tempName=StringFromList(0,StringFromList(i,WaveNotes_ListToFind,";"),">")
		if(!stringmatch(tempName, "*_qrs_*" ))
					if(MineLatestGenerationWaves)
			 			Wave/Z testWave=$(IR2M_FindLatestGeneration(tempName))
			 		else
			 			Wave/Z testWave=$(tempName)
			 		endif
	 	else
	 		string ListOfWaves=IN2G_CreateListOfItemsInFolder(GetDataFolder(1), 2)
	 		ListOfWaves = GrepList(ListOfWaves, tempName[0] )
	 		tempName = stringfromlist(0, ListOfWaves)
	 		Wave/Z testWave=$(tempName)
	 	endif
		if(WaveExists(testWave))
			curNote=note(testWave)
			if(strlen(StringByKey(StringFromList(1,StringFromList(i,WaveNotes_ListToFind,";"),">"), curNote , "=")))
				return 1
			endif
		endif
	endfor
	return 0

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_MineOthersIntoNotebook()
	
	
	SVAR Variables_ListToFind=root:Packages:DataMiner:Variables_ListToFind
	SVAR Strings_ListToFind=root:Packages:DataMiner:Strings_ListToFind
	SVAR WaveNotes_ListToFind=root:Packages:DataMiner:WaveNotes_ListToFind
	SVAR Others_FolderForWaves=root:Packages:DataMiner:Others_FolderForWaves
	SVAR FolderMatchString=root:Packages:DataMiner:FolderMatchString

	variable i, FolderNameInserted=0
	string curNote
	string curFolder=GetDataFolder(0)
	string textToInsert
	string nbl="DataMinerNotebook"
	
	//if(stringmatch(curFolder, FolderMatchString))
	if(GrepString(curFolder, FolderMatchString)||strlen(FolderMatchString)==0)
		if(IR2M_CheckIfSomethingToDo())			

			For(i=0;i<ItemsInList(Variables_ListToFind);i+=1)
			 	NVAR/Z testVar=$(StringFromList(i,Variables_ListToFind))
				if(NVAR_Exists(testVar))
					if(!FolderNameInserted)
						Notebook $nbl selection={endOfFile, endOfFile}
						textToInsert = "\r"+GetDataFolder(1)+"\r"
						Notebook $nbl text=textToInsert		
						FolderNameInserted=1
					endif
					textToInsert = StringFromList(i,Variables_ListToFind)+"   =   "+num2str(testVar)+ "\r"
					Notebook $nbl text=textToInsert
				endif
			endfor
			For(i=0;i<ItemsInList(Strings_ListToFind);i+=1)
			 	SVAR/Z testStr=$(StringFromList(i,Strings_ListToFind))
				if(SVAR_Exists(testStr))
					if(!FolderNameInserted)
						Notebook $nbl selection={endOfFile, endOfFile}
						textToInsert = "\r"+GetDataFolder(1)+"\r"
						Notebook $nbl text=textToInsert		
						FolderNameInserted=1
					endif
					textToInsert = StringFromList(i,Strings_ListToFind)+"   =   "+testStr+ "\r"
					Notebook $nbl text=textToInsert
				endif
			endfor
			string tempName1, tempStr, tempName2
			NVAR MineLatestGenerationWaves = root:Packages:DataMiner:MineLatestGenerationWaves
			For(i=0;i<ItemsInList(WaveNotes_ListToFind,";");i+=1)
				tempStr = StringFromList(i,WaveNotes_ListToFind,";")
				tempName1 =StringFromList(0,tempStr,">")
				tempName2 =StringFromList(1,tempStr,">")
				if(!stringmatch(tempName1, "*_qrs_*" ))
					if(MineLatestGenerationWaves)
						tempName1 = IR2M_FindLatestGeneration(tempName1)
			 			Wave/Z testWave=$(tempName1)
			 		else
			 			Wave/Z testWave=$(tempName1)
			 		endif
			 	else
			 		string ListOfWaves=IN2G_CreateListOfItemsInFolder(GetDataFolder(1), 2)
			 		ListOfWaves = GrepList(ListOfWaves, tempName1[0] )
			 		tempName1 = stringfromlist(0, ListOfWaves)
			 		Wave/Z testWave=$(tempName1)
			 	endif
			 	//testWave 
				if(WaveExists(testWave))
					curNote=note(testWave)
					if(strlen(StringByKey(tempName2, curNote , "=")))
						if(!FolderNameInserted)
							Notebook $nbl selection={endOfFile, endOfFile}
							textToInsert = "\r"+GetDataFolder(1)+"\r"
							Notebook $nbl text=textToInsert		
							FolderNameInserted=1
						endif
						textToInsert = tempName1 +"   ;   "
						textToInsert+= tempName2+"   =   "
						textToInsert+= StringByKey(tempName2, curNote , "=") + "\r"
						Notebook $nbl text=textToInsert
					endif
				endif
			endfor
		endif
	endif
end
///******************************************************************************************
///******************************************************************************************
Function/S IR2M_FindLatestGeneration(ResultsName)
	string resultsname
	//assume we are in current folder, find last index of results known
	variable i
	string tempName, latestResult
	string endingStr, CommonPartStr
	latestResult = ResultsName
	endingStr = StringFromList(ItemsInList(ResultsName,"_")-1, ResultsName , "_")
	if(!GrepString(endingStr, "^[0-9]+$" ))
		return ResultsName
	endif
	//this is fix for cases, when some of the order numbers are missing. User is changing the model
	//in this case we need to create al list of matching wave names and sort it acroding to the index. 
	CommonPartStr = RemoveEnding(ResultsName, endingStr)
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(GetDataFolder(1), 2)	//all waves
	ListOfWaves = GrepList(ListOfWaves, CommonPartStr)								//waves which match the string part of the name except the order number
	ListOfWaves = SortList(ListOfWaves , ";" , 16+1)									//this sorts the higherst order number first, 16 is special sort mode for this case and +1 inverses teh order. 
	//print ListOfWaves
	if(strlen(ListOfWaves)<1)
		return ""
	else
		return StringFromList(0, ListOfWaves)											//returns first element of the list, highest order
	endif
	return " "
	//this is old code, it failed with some of the order numebrs were missing. 
	//	tempName = RemoveEnding(ResultsName  , StringFromList(ItemsInList(ResultsName,"_")-1, ResultsName , "_"))
	//	//print tempName
	//	For(i=0;i<1000;i+=1)
	//		if(checkname(tempName+num2str(i),1))
	//			latestResult = tempName+num2str(i)
	//		else
	//			if(strlen(latestResult)>1)
	//				return latestResult
	//			else
	//				return " "
	//			endif
	//		endif
	//	endfor
	//	return " "
	
end
///******************************************************************************************
///******************************************************************************************

Function IR2M_FormatGraphAsRequested()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:DataMiner

	NVAR GraphLogX
	NVAR GraphLogY
	NVAR GraphColorScheme1
	NVAR GraphColorScheme2
	NVAR GraphColorScheme3
	
	DoWIndow DataMiningGraph
	if(!V_Flag)
		abort
	else
		DoWindow/F DataMiningGraph
	endif
	
	ModifyGraph/Z  /W=DataMiningGraph  log(bottom)=GraphLogX
	ModifyGraph/Z  /W=DataMiningGraph  log(left)=GraphLogY
	if(GraphColorScheme1)
		IR2M_MultiColorStyle()
	elseif(GraphColorScheme2)
		IR2M_ColorCurves()
	elseif(GraphColorScheme3)
		IR2M_RainbowColorizeTraces(0)
	else
	
	endif
	
	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2M_MineWavesIntoGraph()
	
	SVAR Waves_Xtemplate=root:Packages:DataMiner:Waves_Xtemplate
	SVAR Waves_Ytemplate=root:Packages:DataMiner:Waves_Ytemplate
	SVAR Waves_Etemplate=root:Packages:DataMiner:Waves_Etemplate

	SVAR FolderMatchString=root:Packages:DataMiner:FolderMatchString

	string curFolder=GetDataFolder(0)
	string ListOfAllWaves="", ListOfXWaves="", ListOfYWaves="", ListOfEWaves="", curName=""
	variable i

	//need to deal with two cases. Number one is case when full names are given, number two is when partial name and * are given...

	//first check that the folder is selected by user to deal with
	//if(!stringmatch(curFolder, FolderMatchString ))
	if(!GrepString(curFolder, FolderMatchString ))
		return 1
	endif
	NVAR MineLatestGenerationWaves = root:Packages:DataMiner:MineLatestGenerationWaves
	NVAR UseResults = root:Packages:DataMiner:UseResults
	//Now we can start dealing with this
	if(strsearch(Waves_Xtemplate, "*", 0)<0 && strsearch(Waves_Ytemplate, "*", 0)<0  && strsearch(Waves_Etemplate, "*", 0)<0 )
		//no * in any of the names
					if(MineLatestGenerationWaves)
			 			//Wave/Z testWave=$(IR2M_FindLatestGeneration(tempName1))
						Wave/Z testX=$(IR2M_FindLatestGeneration(Waves_Xtemplate))
						Wave/Z testY=$(IR2M_FindLatestGeneration(Waves_Ytemplate))
						Wave/Z testE=$(IR2M_FindLatestGeneration(Waves_Etemplate))
			 		else
						Wave/Z testX=$(Waves_Xtemplate)
						Wave/Z testY=$(Waves_Ytemplate)
						Wave/Z testE=$(Waves_Etemplate)
			 		endif
			
				if(strlen(Waves_Etemplate)>0)
					if(WaveExists(testX) && WaveExists(testY) && WaveExists(testE))
						AppendToGraph /W=DataMiningGraph testY vs TestX
						//		ErrorBars /W=DataMiningGraph "traceName", Y 
						//ErrorBars SMR_Int#31 Y,wave=(:'S32_-2.3 aluminum':SMR_Error,:'S32_-2.3 aluminum':SMR_Error)		
					endif
				else
					if(WaveExists(testX) && WaveExists(testY))
						AppendToGraph /W=DataMiningGraph testY vs TestX
					endif
				endif	
	else		//User wants to find partially defined waves. Much more trouble...
		//OK, let's figure out, which all waves should be ploted...
		ListOfAllWaves = stringFromList(1,DataFolderDir(2),":")
		ListOfAllWaves = ListOfAllWaves[0,strlen(ListOfAllWaves)-3]+","
		if(strlen(ListOfAllWaves)>0)
			For(i=0;i<ItemsInList(ListOfAllWaves,",");i+=1)
				curName = StringFromList(i,ListOfAllWaves,",")
				if(stringmatch(curName,Waves_Xtemplate))
					ListOfXWaves+=curName+";"
				endif
				if(stringmatch(curName,Waves_Ytemplate))
					ListOfYWaves+=curName+";"
				endif
				if(stringmatch(curName,Waves_Etemplate))
					ListOfEWaves+=curName+";"
				endif
			endfor
			//Note, for now... This can miserably fail and assign wave together, which do not belong together.
			//there is no gurrantee, that this will not assign wrong "ends/starts" together...
			//but at least we need to run this for cases when we find same number for each X and Y and when we have just one X and many Y
			if(ItemsInList(ListOfXWaves)==1)
				For(i=0;i<ItemsInList(ListOfYWaves);i+=1)
					Wave/Z testX=$(stringFromList(0,ListOfXWaves))
					Wave/Z testY=$(stringFromList(i,ListOfYWaves))
					Wave/Z testE=$(stringFromList(i,ListOfEWaves))
				
					if(strlen(Waves_Etemplate)>0)
						if(WaveExists(testX) && WaveExists(testY) && WaveExists(testE))
							AppendToGraph /W=DataMiningGraph testY vs TestX
					//		ErrorBars /W=DataMiningGraph "traceName", Y 
					//ErrorBars SMR_Int#31 Y,wave=(:'S32_-2.3 aluminum':SMR_Error,:'S32_-2.3 aluminum':SMR_Error)		
						endif
					else
						if(WaveExists(testX) && WaveExists(testY))
							AppendToGraph /W=DataMiningGraph testY vs TestX
						endif
					endif	
				endfor
			else
				For(i=0;i<ItemsInList(ListOfXWaves);i+=1)
					Wave/Z testX=$(stringFromList(i,ListOfXWaves))
					Wave/Z testY=$(stringFromList(i,ListOfYWaves))
					Wave/Z testE=$(stringFromList(i,ListOfEWaves))
				
					if(strlen(Waves_Etemplate)>0)
						if(WaveExists(testX) && WaveExists(testY) && WaveExists(testE))
							AppendToGraph /W=DataMiningGraph testY vs TestX
					//		ErrorBars /W=DataMiningGraph "traceName", Y 
					//ErrorBars SMR_Int#31 Y,wave=(:'S32_-2.3 aluminum':SMR_Error,:'S32_-2.3 aluminum':SMR_Error)		
						endif
					else
						if(WaveExists(testX) && WaveExists(testY))
							AppendToGraph /W=DataMiningGraph testY vs TestX
						endif
					endif	
				endfor
			endif
		endif
	endif
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_AppendLegend(FontSize)
	variable FontSize

	string Traces=TraceNameList("DataMiningGraph", ";", 1 )
	variable i
	string legendStr=""
	if(Fontsize<10)
		legendStr="\Z0"+num2str(floor(FontSize))	
	else
		legendStr="\Z"+num2str(floor(FontSize))	
	endif
	For(i=0;i<ItemsInList(Traces);i+=1)
		legendStr+="\\s("+StringFromList(i,traces)+") "+GetWavesDataFolder(TraceNameToWaveRef("DataMiningGraph", StringFromList(i,traces)),0)+":"+StringFromList(i,traces)+"\r"
	endfor
	
	Legend/C/N=text0/A=LB legendStr
end

///******************************************************************************************
///******************************************************************************************
Function IR2M_CreateGraph()
	
	KillWIndow/Z DataMiningGraph
 	Display/K=1/W=(305.25,42.5,870,498.5) 
	DoWindow/C DataMiningGraph

end

///******************************************************************************************
///******************************************************************************************
Function IR2M_InsertDateAndTime()

	Variable now=datetime
	string bucket11=Secs2Date(now,0)+",  "+Secs2Time(now,0) +"\r"
	string nbl="DataMinerNotebook"
	Notebook $nbl selection={endOfFile, endOfFile}
	Notebook $nbl text="\r\rList created on :     "+bucket11

end
///******************************************************************************************
///******************************************************************************************
Function IR2M_InsertText(textToInsert)
	string textToInsert

	string nbl="DataMinerNotebook"
	Notebook $nbl selection={endOfFile, endOfFile}
	Notebook $nbl text=textToInsert+"\r"

end

///******************************************************************************************
///******************************************************************************************
Function IR2M_MineWavesIntoNotebook()
	
	SVAR Waves_Xtemplate=root:Packages:DataMiner:Waves_Xtemplate
	SVAR Waves_Ytemplate=root:Packages:DataMiner:Waves_Ytemplate
	SVAR Waves_Etemplate=root:Packages:DataMiner:Waves_Etemplate
	NVAR WavesNbk_contains=root:Packages:DataMiner:WavesNbk_contains
	NVAR WavesNbk_NOTcontains=root:Packages:DataMiner:WavesNbk_NOTcontains
	SVAR FolderMatchString=root:Packages:DataMiner:FolderMatchString

	string curFolder=GetDataFolder(0)
	string ListOfAllWaves="",curName="",ListOfXWaves="",ListOfYWaves="",ListOfEWaves=""
		string textToInsert
		string nbl="DataMinerNotebook"
	variable i
	//if(!stringmatch(curFolder, FolderMatchString ))
	if(!GrepString(curFolder, FolderMatchString ))
		return 1
	endif
	
	NVAR MineLatestGenerationWaves = root:Packages:DataMiner:MineLatestGenerationWaves
	NVAR UseResults = root:Packages:DataMiner:UseResults
	string RealYWaveName, RealXWaveName, RealEName
	//Now we can start dealing with this
	if(strsearch(Waves_Xtemplate, "*", 0)<0 && strsearch(Waves_Ytemplate, "*", 0)<0  && strsearch(Waves_Etemplate, "*", 0)<0 )
		if(MineLatestGenerationWaves)
 			//Wave/Z testWave=$(IR2M_FindLatestGeneration(tempName1))
			Wave/Z testX=$(IR2M_FindLatestGeneration(Waves_Xtemplate))
			Wave/Z testY=$(IR2M_FindLatestGeneration(Waves_Ytemplate))
			Wave/Z testE=$(IR2M_FindLatestGeneration(Waves_Etemplate))
			RealYWaveName=IR2M_FindLatestGeneration(Waves_Ytemplate)
			RealXWaveName=IR2M_FindLatestGeneration(Waves_Xtemplate)
			RealEName=IR2M_FindLatestGeneration(Waves_Etemplate)
 		else
			Wave/Z testX=$(Waves_Xtemplate)
			Wave/Z testY=$(Waves_Ytemplate)
			Wave/Z testE=$(Waves_Etemplate)
 			RealYWaveName=(Waves_Ytemplate)
			RealXWaveName=(Waves_Xtemplate)
			RealEName=(Waves_Etemplate)
 		endif
		Notebook $nbl selection={endOfFile, endOfFile}
	
		if(strlen(Waves_Etemplate)>0)
			if(((WaveExists(testX) && WaveExists(testY) && WaveExists(testE)) && WavesNbk_contains) || (!(WaveExists(testX) && WaveExists(testY) && WaveExists(testE)) && WavesNbk_NOTcontains))
				if(MineLatestGenerationWaves)
					textToInsert = GetDataFolder(1)+"    contains   "+RealYWaveName+"\r"
				else
					textToInsert = GetDataFolder(1)+"\r"
				endif
				Notebook $nbl text=textToInsert
			endif
		elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)>0 && strlen(Waves_Xtemplate)>0 )
			if(((WaveExists(testX) && WaveExists(testY)) && WavesNbk_contains) || (!(WaveExists(testX) && WaveExists(testY)) && WavesNbk_NOTcontains)) 
				if(MineLatestGenerationWaves)
					textToInsert = GetDataFolder(1)+"    contains   "+RealYWaveName+"\r"
				else
					textToInsert = GetDataFolder(1)+"\r"
				endif
				Notebook $nbl text=textToInsert
			endif
		elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)==0 && strlen(Waves_Xtemplate)>0)
			if((WaveExists(testX) && WavesNbk_contains) || (!WaveExists(testX) && WavesNbk_NOTcontains)) 
				if(MineLatestGenerationWaves)
					textToInsert = GetDataFolder(1)+"    contains   "+RealYWaveName+"\r"
				else
					textToInsert = GetDataFolder(1)+"\r"
				endif
				Notebook $nbl text=textToInsert
			endif
		else
			//nothing to do... 
		endif
	else
		//here we deal with the cases when user partially described the waves... Much more difficult.
		//note, this will work ONLY with present, not present needs special treatment. 
		
		ListOfAllWaves = stringFromList(1,DataFolderDir(2),":")
		ListOfAllWaves = ListOfAllWaves[0,strlen(ListOfAllWaves)-3]+","
		if(strlen(ListOfAllWaves)>0)
			For(i=0;i<ItemsInList(ListOfAllWaves,",");i+=1)
				curName = StringFromList(i,ListOfAllWaves,",")
				if(stringmatch(curName,Waves_Xtemplate))
					ListOfXWaves+=curName+";"
				endif
				if(stringmatch(curName,Waves_Ytemplate))
					ListOfYWaves+=curName+";"
				endif
				if(stringmatch(curName,Waves_Etemplate))
					ListOfEWaves+=curName+";"
				endif
			endfor
			//Note, for now... This can miserably fail and assign wave together, which do not belong together.
			//there is no gurrantee, that this will not assign wrong "ends/starts" together...
			For(i=0;i<ItemsInList(ListOfXWaves);i+=1)
				Wave/Z testX=$(stringFromList(i,ListOfXWaves))
				Wave/Z testY=$(stringFromList(i,ListOfYWaves))
				Wave/Z testE=$(stringFromList(i,ListOfEWaves))
				if(strlen(Waves_Etemplate)>0)
					if(((WaveExists(testX) && WaveExists(testY) && WaveExists(testE)) && WavesNbk_contains) || (!(WaveExists(testX) && WaveExists(testY) && WaveExists(testE)) && WavesNbk_NOTcontains))
						textToInsert = GetDataFolder(1)+"  contains    "+stringFromList(i,ListOfXWaves)+", "+stringFromList(i,ListOfYWaves)+", and "+stringFromList(i,ListOfEWaves)+"\r"
						Notebook $nbl text=textToInsert
					endif
				elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)>0 && strlen(Waves_Xtemplate)>0 )
					if(((WaveExists(testX) && WaveExists(testY)) && WavesNbk_contains) || (!(WaveExists(testX) && WaveExists(testY)) && WavesNbk_NOTcontains)) 
						textToInsert = GetDataFolder(1)+"  contains    "+stringFromList(i,ListOfXWaves)+", and "+stringFromList(i,ListOfYWaves)+"\r"
						Notebook $nbl text=textToInsert
					endif
				elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)==0 && strlen(Waves_Xtemplate)>0)
					if((WaveExists(testX) && WavesNbk_contains) || (!WaveExists(testX) && WavesNbk_NOTcontains)) 
						textToInsert = GetDataFolder(1)+"  contains    "+stringFromList(i,ListOfXWaves)+"\r"
						Notebook $nbl text=textToInsert
					endif
				else
					//nothing to do... 
				endif
			endfor
		endif
			
	endif
end

///******************************************************************************************
///******************************************************************************************
Function IR2M_CreateNotebook()
	
	string nbl="DataMinerNotebook"
	    
	if (strsearch(WinList("*",";","WIN:16"),nbL,0)!=-1) 		///Logbook exists
		DoWindow/F $nbl
	else
		NewNotebook/K=3/V=0/N=$nbl/F=1/V=1/W=(235.5,44.75,817.5,592.25) as nbl
		Notebook $nbl defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
		Notebook $nbl showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nbl newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",10,0,(0,0,0)}
		Notebook $nbl ruler=Normal; Notebook $nbl  justification=1, rulerDefaults={"Arial",14,1,(0,0,0)}
		Notebook $nbl text="This is log results of data mining of SAS data with Irena package.\r"
		Notebook $nbl text="\r"
		Notebook $nbl ruler=Normal
	endif
	DoWindow/F $nbl
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_ReadWavesFromListBox(which)
	string which
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:DataMiner
	Wave/T ItemsInFolder
	
	if(cmpstr(which,"Waves_X")==0)
		SVAR Waves_Xtemplate=root:Packages:DataMiner:Waves_Xtemplate
		ControlInfo  /W=ItemsInFolderPanel ItemsInCurrentFolder
		Waves_Xtemplate = ItemsInFolder[V_Value]
	endif
	if(cmpstr(which,"Waves_Y")==0)
		SVAR Waves_Ytemplate=root:Packages:DataMiner:Waves_Ytemplate
		ControlInfo  /W=ItemsInFolderPanel ItemsInCurrentFolder
		Waves_Ytemplate = ItemsInFolder[V_Value]
	endif
	if(cmpstr(which,"Waves_E")==0)
		SVAR Waves_Etemplate=root:Packages:DataMiner:Waves_Etemplate
		ControlInfo  /W=ItemsInFolderPanel ItemsInCurrentFolder
		Waves_Etemplate = ItemsInFolder[V_Value]
	endif
	
	
	setDataFolder oldDF	
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2M_MakePanelWithListBox(skipCreatePanel)
	variable skipCreatePanel
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:DataMiner
	if(!skipCreatePanel)
		KillWIndow/Z ItemsInFolderPanel
 	endif
	SVAR DataFolderName=root:Packages:DataMiner:DataFolderName
	if(!DataFolderExists(DataFolderName) || cmpstr(DataFolderName,"---")==0)
		return 1
	endif
	NVAR MineVariables = root:Packages:DataMiner:MineVariables
	NVAR MineStrings = root:Packages:DataMiner:MineStrings
	NVAR MineWaves = root:Packages:DataMiner:MineWaves
	NVAR MineWavenotes = root:Packages:DataMiner:MineWavenotes
 	SVAR LastSelectedItem = root:Packages:DataMiner:LastSelectedItem
 	SVAR ItemMatchString = root:Packages:DataMiner:ItemMatchString

	variable WhatToTest
	string TitleStr
	if(MineWaves || MineWavenotes)
		WhatToTest=2
		TitleStr = "Waves in test folder"
	endif
	if(MineVariables)
		WhatToTest=4
		TitleStr = "Variables in test folder"
	endif
	if(MineStrings)
		WhatToTest=8
		TitleStr = "Strings in test folder"
	endif
	setDataFolder DataFolderName
	string ListOfItems = StringFromList(1,(DataFolderDir(WhatToTest)),":")
	if(strlen(ItemMatchString)>0)
		ListOfItems = GrepList(ListOfItems, ItemMatchString,0,",")
	endif
	setDataFolder root:Packages:DataMiner
	make/O/T/N=(itemsInList(ListOfItems,",")) ItemsInFolder
	variable i
	variable selItemOld=0
	for(i=0;i<itemsInList(ListOfItems,",");i+=1)
		ItemsInFolder[i]= stringFromList(0,stringFromList(i,ListOfItems,","),";")
		if(stringmatch(ItemsInFolder[i], LastSelectedItem ))
			selItemOld=i
		endif
	endfor
	
	if(strlen(ItemsInFolder[0])>0)
		if(MineWaves || MineWavenotes)
			Wave FirstSelectedWave=$(DataFolderName+possiblyQuoteName(ItemsInFolder[selItemOld]))
			string CurNote=note(FirstSelectedWave)
			if(MineWaves || MineWavenotes)
				make/T/O/N=(itemsInList(CurNote)) WaveNoteList
				for(i=0;i<itemsInList(CurNote);i+=1)
					WaveNoteList[i]= stringFromList(i,CurNote)
				endfor
			endif
		else
			if(MineStrings)
				SVAR SelectedString=$(DataFolderName+possiblyQuoteName(ItemsInFolder[selItemOld]))
				make/T/O/N=(1) WaveNoteList
				WaveNoteList[0]=SelectedString
			else
				NVAR SelectedVariable=$(DataFolderName+possiblyQuoteName(ItemsInFolder[selItemOld]))
				make/T/O/N=(1) WaveNoteList
				WaveNoteList[0]=num2str(SelectedVariable)
			endif
		endif
	else
			make/T/O/N=(1) WaveNoteList
			WaveNoteList=""
	endif
	Make/O/N=(numpnts(ItemsInFolder)) ItemsInFolderSelections
	Make/O/N=(numpnts(WaveNoteList)) WaveNoteListSelections
	WaveNoteListSelections = 0
	ItemsInFolderSelections = 0
	if(!skipCreatePanel)
		KillWIndow/Z ItemsInFolderPanel
 		//PauseUpdate    		// building window...
		NewPanel /K=1 /W=(400,50,720,696) as "Items in selected folder"
		DoWindow/C ItemsInFolderPanel
		SetDrawLayer UserBack
		//SetDrawEnv fsize= 16,fstyle= 3,textrgb= (0,0,65280)
		//DrawText 45,21,"Items In the selected folder"
		TitleBox Text0 title="\Zr140Items In the selected folder:",pos={15,5},frame=0,fstyle=3,size={100,24},fColor=(1,4,52428)
		//SetDrawEnv fsize= 16,fstyle= 3,textrgb= (0,0,65280)
		//DrawText 11,343,"Wave note/value for selection above:"
		TitleBox Text1 title="\Zr140Wave note/value for selection above:",pos={15,320},frame=0,fstyle=3,size={100,24},fColor=(1,4,52428)

		ListBox ItemsInCurrentFolder,pos={2,23},size={311,268}, selWave=root:Packages:DataMiner:ItemsInFolderSelections
		ListBox ItemsInCurrentFolder,listWave=root:Packages:DataMiner:ItemsInFolder
		ListBox ItemsInCurrentFolder,mode= 1,selRow= selItemOld, proc=IR2M_ListBoxProc
		setVariable ItemMatchString, pos={5,295}, size={210,20}, bodyWidth=130, title="Match (RegEx)", limits={-inf,inf,0}, proc=IR2M_ListboxSetVarProc
		setVariable ItemMatchString, help={"Input Regular expressiong to match names of items to "}, variable= root:Packages:DataMiner:ItemMatchString
		ListBox WaveNoteList,pos={3,347},size={313,244},mode=0, selWave=root:Packages:DataMiner:WaveNoteListSelections
		ListBox WaveNoteList,listWave=root:Packages:DataMiner:WaveNoteList,row= 0
		setVariable WaveNoteMatchString, pos={5,595}, size={210,20}, bodyWidth=130, title="Match (RegEx)", limits={-inf,inf,0}, proc=IR2M_ListboxSetVarProc
		setVariable WaveNoteMatchString, help={"Input Regular expressiong to match names of items to "}, variable= root:Packages:DataMiner:WaveNoteMatchString
		
		IR1_UpdatePanelVersionNumber("ItemsInFolderPanel", IR2MversionNumber,1)
		AutoPositionWindow/M=0 /R=DataMiningTool ItemsInFolderPanel
	endif

	if(MineWaves)
			ListBox WaveNoteList,win=ItemsInFolderPanel,mode=0
			ListBox ItemsInCurrentFolder,win=ItemsInFolderPanel,mode=1	
	elseif(MineVariables||MineStrings)
			ListBox ItemsInCurrentFolder,win=ItemsInFolderPanel,mode=9
			ListBox WaveNoteList,win=ItemsInFolderPanel,mode=0		
	else//wave notes
			ListBox ItemsInCurrentFolder,win=ItemsInFolderPanel,mode=1	
			ListBox WaveNoteList,win=ItemsInFolderPanel,mode=9	
	endif

	setDataFolder oldDF
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function  IR2M_ListboxSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
			if(stringmatch("ItemMatchString",sva.ctrlName))
				IR2M_MakePanelWithListBox(1)
			endif
			
			if(stringmatch("WaveNoteMatchString",sva.ctrlName))
				IR2M_UpdateValueListBox()
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
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR2M_ListBoxProc(ctrlName,row,col,event) : ListBoxControl
	String ctrlName
	Variable row
	Variable col
	Variable event	//1=mouse down, 2=up, 3=dbl click, 4=cell select with mouse or keys
					//5=cell select with shift key, 6=begin edit, 7=end

	if(event==4)
		//update
		IR2M_UpdateValueListBox()
	endif
	return 0
End

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2M_UpdateValueListBox()
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:DataMiner
	
	SVAR DataFolderName=root:Packages:DataMiner:DataFolderName
	if(!DataFolderExists(DataFolderName))
		abort
	endif
	NVAR MineVariables = root:Packages:DataMiner:MineVariables
	NVAR MineStrings = root:Packages:DataMiner:MineStrings
	NVAR MineWaves = root:Packages:DataMiner:MineWaves
	NVAR MineWavenotes = root:Packages:DataMiner:MineWavenotes
	SVAR LastSelectedItem = root:Packages:DataMiner:LastSelectedItem
	SVAR WaveNoteMatchString = root:Packages:DataMiner:WaveNoteMatchString
	
	variable WhatToTest
	string TitleStr
	if(MineWaves || MineWavenotes)
		WhatToTest=2
		TitleStr = "Waves in test folder"
	endif
	if(MineVariables)
		WhatToTest=4
		TitleStr = "Variables in test folder"
	endif
	if(MineStrings)
		WhatToTest=8
		TitleStr = "Strings in test folder"
	endif
	variable i
	ControlInfo  /W=ItemsInFolderPanel ItemsInCurrentFolder
	Wave/T ItemsInFolder
	variable SelectedItem=V_Value
	LastSelectedItem = ItemsInFolder[SelectedItem]
	if(MineWaves || MineWavenotes)
		Wave FirstSelectedWave=$(DataFolderName+possiblyQuoteName(ItemsInFolder[SelectedItem]))
		string CurNote=note(FirstSelectedWave)
		if(strlen(WaveNoteMatchString)>0)
			CurNote = GrepList(CurNote, WaveNoteMatchString,0,";")
		endif
		if(MineWaves || MineWavenotes)
			make/T/O/N=(itemsInList(CurNote)) WaveNoteList
			for(i=0;i<itemsInList(CurNote);i+=1)
				WaveNoteList[i]= stringFromList(i,CurNote)
			endfor
		endif
	else
		if(MineStrings)
			SVAR SelectedString=$(DataFolderName+possiblyQuoteName(ItemsInFolder[SelectedItem]))
			string tempString
			tempString = SelectedString
			if(strlen(WaveNoteMatchString)>0)
				tempString = GrepList(tempString, WaveNoteMatchString,0,";")
			endif
			make/T/O/N=(itemsInList(tempString)) WaveNoteList
			for(i=0;i<itemsInList(tempString);i+=1)
				WaveNoteList[i]= stringFromList(i,tempString)
			endfor
		else
			NVAR SelectedVariable=$(DataFolderName+possiblyQuoteName(ItemsInFolder[SelectedItem]))
			make/T/O/N=(1) WaveNoteList
			WaveNoteList[0]=num2str(SelectedVariable)
		endif
	endif
	Make/O/N=(numpnts(ItemsInFolder)) ItemsInFolderSelections
	Make/O/N=(numpnts(WaveNoteList)) WaveNoteListSelections
//	WaveNoteListSelections = 0
//	ItemsInFolderSelections = 0

	DoWindow ItemsInFolderPanel
	if(V_Flag)
		DoWindow/F ItemsInFolderPanel
	else
		abort
	endif
	ControlUpdate  /W=ItemsInFolderPanel  WaveNoteList
//	ListBox WaveNoteList,win=ItemsInFolderPanel, listWave=root:Packages:DataMiner:WaveNoteList,row= 0
	
	setDataFolder oldDF

end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function  IR2M_DataMinerCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

//	ListOfVariables+="MineVariables;MineStrings;MineWaves;MineWavenotes;"
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:DataMiner
	NVAR MineVariables = root:Packages:DataMiner:MineVariables
	NVAR MineStrings = root:Packages:DataMiner:MineStrings
	NVAR MineWaves = root:Packages:DataMiner:MineWaves
	NVAR MineWavenotes = root:Packages:DataMiner:MineWavenotes
	
	NVAR SaveToNotebook = root:Packages:DataMiner:SaveToNotebook
	NVAR SaveToWaves = root:Packages:DataMiner:SaveToWaves
	NVAR SaveToGraph = root:Packages:DataMiner:SaveToGraph

	if(cmpstr(ctrlName,"MineVariables")==0 || cmpstr(ctrlName,"MineStrings")==0 || cmpstr(ctrlName,"MineWaves")==0 || cmpstr(ctrlName,"MineWavenotes")==0)
		KillWIndow/Z ItemsInFolderPanel
 	endif
	if(cmpstr(ctrlName,"MineVariables")==0)
		if(Checked)
			// MineVariables = 0
			 MineStrings = 0
			 MineWaves = 0
			 MineWavenotes = 0
			 IR2M_MakePanelWithListBox(0)
		endif
	endif
	if(cmpstr(ctrlName,"MineStrings")==0)
		if(Checked)
			 MineVariables = 0
			// MineStrings = 0
			 MineWaves = 0
			 MineWavenotes = 0
			 IR2M_MakePanelWithListBox(0)
		endif
	endif
	if(cmpstr(ctrlName,"MineWaves")==0)
		if(Checked)
			 MineVariables = 0
			 MineStrings = 0
			// MineWaves = 0
			 MineWavenotes = 0
			 IR2M_MakePanelWithListBox(0)
		endif
	endif
	if(cmpstr(ctrlName,"MineWavenotes")==0)
		if(Checked)
			 MineVariables = 0
			 MineStrings = 0
			 MineWaves = 0
			// MineWavenotes = 0
			 IR2M_MakePanelWithListBox(0)
		endif
	endif
	if(cmpstr(ctrlName,"SaveToNotebook")==0)
		if(Checked)
			// SaveToNotebook = 0
			 SaveToWaves = 0
			 SaveToGraph = 0
		endif
	endif
	if(cmpstr(ctrlName,"SaveToWaves")==0)
		if(Checked)
			 SaveToNotebook = 0
			// SaveToWaves = 0
		//	 SaveToGraph = 0
		endif
	endif
		if((SaveToNotebook + SaveToWaves !=1)&&(MineVariables || MineStrings || MineWavenotes))
				SaveToWaves=1
				SaveToNotebook=0
		endif

		if((SaveToNotebook + SaveToGraph !=1)&& MineWaves)
				SaveToGraph=1
				SaveToNotebook=0
		endif

	if(cmpstr(ctrlName,"GraphLogX")==0)
		//fix graph axis if exists
		IR2M_FormatGraphAsRequested()
	endif
	if(cmpstr(ctrlName,"GraphLogY")==0)
		//fix graph axis if exists
		IR2M_FormatGraphAsRequested()
	endif

	NVAR GraphColorScheme1
	NVAR GraphColorScheme2
	NVAR GraphColorScheme3
	if(cmpstr(ctrlName,"GraphColorScheme1")==0)
		if(checked)
			// GraphColorScheme1=0
			 GraphColorScheme2=0
			 GraphColorScheme3=0
			 //apply formating if graph exists
			 IR2M_FormatGraphAsRequested()
		endif
	endif
	if(cmpstr(ctrlName,"GraphColorScheme2")==0)
		if(checked)
			 GraphColorScheme1=0
			// GraphColorScheme2=0
			 GraphColorScheme3=0
			 //apply formating if graph exists
			 IR2M_FormatGraphAsRequested()
		endif
	endif
	if(cmpstr(ctrlName,"GraphColorScheme3")==0)
		if(checked)
			 GraphColorScheme1=0
			 GraphColorScheme2=0
			// GraphColorScheme3=0
			 //apply formating if graph exists
			 IR2M_FormatGraphAsRequested()
		endif
	endif

	NVAR WavesNbk_contains
	NVAR WavesNbk_NOTcontains
	if(cmpstr(ctrlName,"WavesNbk_contains")==0)
		if(Checked)
			WavesNbk_NOTcontains = 0
		else
			WavesNbk_NOTcontains=1
		endif
	endif
	if(cmpstr(ctrlName,"WavesNbk_NOTcontains")==0)
		if(Checked)
			WavesNbk_contains = 0
		else
			WavesNbk_contains=1
		endif
	endif

	IR2M_FixPanelControls()
	setDataFolder oldDF
	
End


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_SyncSearchListAndListBox()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:DataMiner
	SVAR Variables_ListToFind
	SVAR Strings_ListToFind
	SVAR WaveNotes_ListToFind
	Wave/T SelectedItems
	variable i
	variable numVariables=ItemsInList(Variables_ListToFind)
	variable numStrings=ItemsInList(Strings_ListToFind)
	variable numWaveNotes=ItemsInList(WaveNotes_ListToFind)
	redimension/N=(numVariables+numStrings+numWaveNotes+4) SelectedItems
	SelectedItems[0]="DataFolderName"
	SelectedItems[1]="               Variables:"
	for(i=0;i<ItemsInList(Variables_ListToFind);i+=1)
		SelectedItems[i+2]=stringFromList(i,Variables_ListToFind)
	endfor
	SelectedItems[2+numVariables]="               Strings:"
	for(i=0;i<ItemsInList(Strings_ListToFind);i+=1)
		SelectedItems[i+3+numVariables]=stringFromList(i,Strings_ListToFind)
	endfor
	SelectedItems[3+numVariables+numStrings]="               WaveNotes:"
	for(i=0;i<ItemsInList(WaveNotes_ListToFind);i+=1)
		SelectedItems[i+4+numVariables+numStrings]=stringFromList(i,WaveNotes_ListToFind)
	endfor

	setDataFolder oldDF

end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2M_InitDataMiner()


	DFref oldDf= GetDataFolderDFR()

	setdatafolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S DataMiner

	string ListOfVariables
	string ListOfStrings
	variable i
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;UseSMRData;UseUserDefinedData;"
	ListOfVariables+="MineVariables;MineStrings;MineWaves;MineWavenotes;MineLatestGenerationWaves;"
	ListOfVariables+="SaveToNotebook;SaveToWaves;SaveToGraph;"
	ListOfVariables+="GraphLogX;GraphLogY;GraphColorScheme1;GraphColorScheme2;GraphColorScheme3;GraphFontSize;"
	ListOfVariables+="WavesNbk_contains;WavesNbk_NOTcontains;"
//
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	ListOfStrings+="Waves_Xtemplate;Waves_Ytemplate;Waves_Etemplate;"
	ListOfStrings+="StartFolder;FolderMatchString;LastSelectedItem;ItemMatchString;WaveNoteMatchString;"
	ListOfStrings+="Variables_ListToFind;Strings_ListToFind;WaveNotes_ListToFind;Others_FolderForWaves;Others_ListToFind;"
//	
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	
	//Waves
	Wave/T/Z SelectedItems 
	if(!WaveExists(SelectedItems))
		make/T/N=1 SelectedItems
		SelectedItems[0]="DataFolderName;"
	endif
	
	NVAR GraphFontSize
	if(GraphFontSize<6)
		GraphFontSize=8
	endif
	NVAR WavesNbk_contains
	NVAR WavesNbk_NOTcontains
	if(WavesNbk_contains+WavesNbk_NOTcontains!=1)
		WavesNbk_contains=1
		WavesNbk_NOTcontains=0
	endif
	SVAR StartFolder
	if(!DataFolderExists(StartFolder) || strlen(StartFolder)<1)
		StartFolder="root:"
	endif
	SVAR FolderMatchString
	if(StringMatch(FolderMatchString,"*"))
		FolderMatchString=""
	endif
	SVAR Others_FolderForWaves
	if(Strlen(Others_FolderForWaves)==0)
		Others_FolderForWaves="SearchResults:"
	endif
	SVAR Others_ListToFind
	if(Strlen(Others_ListToFind)==0)
		Others_ListToFind="DataFolderName;Variables;Strings;WaveNotes;"
	endif
	
	NVAR MineVariables
	NVAR MineStrings
	NVAR MineWaves
	NVAR MineWavenotes
	if(MineVariables+MineStrings+MineWaves+MineWavenotes!=1)
		MineVariables=0
		MineStrings=0
		MineWaves=1
		MineWavenotes=0
	endif
	
//	SVAR/Z OutputNameExtension
//	if(!SVAR_Exists(OutputNameExtension))
//		string/G OutputNameExtension
//		OutputNameExtension="dat"
//	endif
//	SVAR/Z HeaderSeparator
//	if(!SVAR_Exists(HeaderSeparator))
//		string/G HeaderSeparator
//		HeaderSeparator="#   "
//	endif
//	//Ouptu path
//	PathInfo IR2E_ExportPath
//	if(!V_Flag)
//		PathInfo Igor
//		NewPath/Q IR2E_ExportPath S_Path
//	endif
//	PathInfo IR2E_ExportPath
//	SVAR CurrentlySetOutputPath
//	CurrentlySetOutputPath=S_Path
//	
//	SVAR NewFileOutputName
//	NewFileOutputName=""
//	SVAR CurrentlyLoadedDataName
//	CurrentlyLoadedDataName = ""
//	SVAR DataFolderName
//	DataFolderName=""
//	SVAR IntensityWaveName
//	IntensityWaveName=""
//	SVAR QWavename
//	QWavename=""
//	SVAR ErrorWaveName
//	ErrorWaveName=""
	setDataFolder OldDf


end



function IR2M_RainbowColorizeTraces(rev)
variable rev  //Reverses coloring order if non-zero


    Variable k, km
    variable r,g,b,scale


    // Find the number of traces on the top graph
    String tnl = TraceNameList( "", ";", 1 )
    k = ItemsInList(tnl)
    if (k <= 1)
        return -1
    endif


    km = k
    colortab2wave Rainbow
    wave M_colors


    do
        k-=1
        scale = (rev==0 ? k : (km-k-1))  / (km-1) * dimsize(M_colors,0)
        r = M_colors[scale][0]
        g = M_colors[scale][1]
        b = M_colors[scale][2]
        ModifyGraph/Z rgb[k]=( r, g, b )
    while(k>0)
    killwaves/Z M_colors
    return 1
end


Function IR2M_ColorCurves()
        //PauseUpdate    


        Variable i, NumTraces, iRed, iBlue, iGreen, io, w, Red, Blue, Green,  ColorNorm
        String DataName
        NumTraces=ItemsInList(TraceNameList("", ";", 1),";")


        i=0
        w = (NumTraces/2)
        do
                DataName = StringFromList(i, TraceNameList("", ";", 1),";")
                if(strlen(DataName)>0)
	                io = 0
	                iRed = exp(-(i-io)^2/w)
	                io = NumTraces/2
	                iBlue = exp(-(i-io)^2/w)
	                io = NumTraces
	                iGreen = exp(-(i-io)^2/w)
	
	
	                ColorNorm = sqrt(iRed^2 + iBlue^2 + iGreen^2)
	
	
	                Red = 65535 * (iRed/ColorNorm)
	                Blue = 65535 * (iBlue/ColorNorm)
	                Green = 65535 * (iGreen/ColorNorm)
	
	
	                ModifyGraph/Z rgb($DataName)=(Red,Blue,Green)
	                ModifyGraph/Z lsize($DataName)=1
                endif
                i+=1
        while(i<NumTraces)
End

function IR2M_MultiColorStyle()
    variable i
    variable traces=ItemsInList(TraceNameList("",";",1))
    //there is only 18 (0-17) lstyles... so traces/8 needs to be less than 17, that is 144 waves  
    variable chunks	//number of 144 sets of 8 axis
    if(traces<144)
    	chunks=traces
    else
    	chunks=144
    endif
    for(i=0;(i<chunks/8);i+=1)
        ModifyGraph/Z lstyle[0+8*i]=i,lstyle[1+8*i]=i,lstyle[2+8*i] =i,lstyle[3+8*i]=i
        ModifyGraph/Z lstyle[4+8*i]=i,lstyle[5+8*i]=i,lstyle[6+8*i]=i
        ModifyGraph/Z lstyle[7+8*i]=i
        ModifyGraph/Z rgb[0+8*i]=(0,0,0),rgb[1+8*i]=(0,65535,0), rgb [2+8*i]=(0,65535,65535),rgb[3+8*i]=(32768,0,65535)
        ModifyGraph/Z rgb[4+8*i]=(65535,32768,0),rgb[5+8*i]= (65535,65535,0),rgb[6+8*i]=(65535,26214,52428)
        ModifyGraph/Z rgb[7+8*i]=(32768,16384,0)
    endfor
End

