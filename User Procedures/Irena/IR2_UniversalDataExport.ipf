#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.09
Constant IR2EversionNumber = 1.09

//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.09 added getHelp button calling to www manual
//1.08 changes for panel scaling
//1.07 fixed multiple data erxport with QRS
//1.06 modified GUI to disable Export Data & notes on main panel, when Multiple data selection panel is opened. Confused users. Changeds call to pull up without initialization, if exists. 
//		changed mode for Listbox to enable shift-click selection of range of data, use ctrl/cmd for one-by-one data selection
//1.05 added in panel version control and added vertical scrolling 
//1.04 fixed Multiple data export which was broken by update to control procedures
//1.03 fixed QRS data export which was not working due to eventCode missing in structure
//1.02 removed all font and font size from panel definitions to enable user control
//1.01 added license for ANL


//This is tool to export any type of 2 -3 column data we have (x, y, and error (if exists)

Function IR2E_UniversalDataExport()

	//check for panel if exists - pull up, if not create
	DoWindow UnivDataExportPanel
	if(V_Flag)
		DoWindow/F UnivDataExportPanel
		DoWIndow IR2E_MultipleDataSelectionPnl
		if(V_Flag)
			DoWindow/F IR2E_MultipleDataSelectionPnl
		endif
	else
		//initialize, as usually
		IR2E_InitUnivDataExport()
		NVAR ExportMultipleDataSets = root:Packages:IR2_UniversalDataExport:ExportMultipleDataSets
		ExportMultipleDataSets=0		//do nto start in multiple data export, it does not set parameters well...  
		IR2E_UnivDataExportPanel()
		ING2_AddScrollControl()
		IR1_UpdatePanelVersionNumber("UnivDataExportPanel", IR2EversionNumber,1)
	endif

end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR2E_MainCheckVersion()	
	DoWindow UnivDataExportPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("UnivDataExportPanel", IR2EversionNumber))
			DoAlert /T="The ASCII Export panel was created by old version of Irena " 1, "Export ASCII may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				Execute/P("IR2E_UniversalDataExport()")
			else		//at least reinitialize the variables so we avoid major crashes...
				IR2E_InitUnivDataExport()
			endif
		endif
	endif
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR2E_UnivDataExportPanel()
	//PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,390,690) as "Universal data export tool"
	DoWindow/C UnivDataExportPanel
	
	string AllowedIrenaTypes="DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;R_Int;"
	IR2C_AddDataControls("IR2_UniversalDataExport","UnivDataExportPanel",AllowedIrenaTypes,"AllCurrentlyAllowedTypes","","","","", 0,0)
	TitleBox MainTitle title="\Zr220Universal data export panel",pos={20,0},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={350,24},anchor=MC,fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,181},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info1 title="\Zr160Data input",pos={10,27},frame=0,fstyle=1, fixedSize=1,size={80,20},fColor=(0,0,52224)
	TitleBox Info2 title="\Zr160Preview Options:",pos={20,190},frame=0,fstyle=2, fixedSize=1,size={150,20},fColor=(0,0,52224)
	TitleBox Info3 title="\Zr160Output Options:",pos={20,320},frame=0,fstyle=2, fixedSize=0,size={20,15},fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,307},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)

	CheckBox ExportMultipleDataSets,pos={100,160},size={225,14},proc=IR2E_UnivExpCheckboxProc,title="Export multiple data sets?"
	CheckBox ExportMultipleDataSets,variable= root:Packages:IR2_UniversalDataExport:ExportMultipleDataSets, help={"When checked the multiple data sets with same data can be exported"}

	Button GetHelp,pos={305,105},size={80,15},fColor=(65535,32768,32768), proc=IR2E_InputPanelButtonProc,title="Get Help", help={"Open www manual page for this tool"}
	CheckBox GraphDataCheckbox,pos={15,220},size={225,14},noproc,title="Display graph with data?"
	CheckBox GraphDataCheckbox,variable= root:Packages:IR2_UniversalDataExport:GraphData, help={"When checked the graph displaying data will be displayed"}
	CheckBox DisplayWaveNote,pos={15,250},size={225,14},noproc,title="Display notes about data?"
	CheckBox DisplayWaveNote,variable= root:Packages:IR2_UniversalDataExport:DisplayWaveNote, help={"When checked notebook with notes about data history will be displayed"}
	Button LoadAndGraphData, pos={100,280},size={180,20}, proc=IR2E_InputPanelButtonProc,title="Load data", help={"Load data into the tool, generate graph and display notes if checkboxes are checked."}
	CheckBox AttachWaveNote,pos={15,350},size={225,14},noproc,title="Attach notes about data?"
	CheckBox AttachWaveNote,variable= root:Packages:IR2_UniversalDataExport:AttachWaveNote, help={"When checked block of text with notes about data history will be attached before the data itself"}
	CheckBox UseFolderNameForOutput,pos={15,370},size={225,14},proc=IR2E_UnivExportCheckProc,title="Use Folder Name for output?"
	CheckBox UseFolderNameForOutput,variable= root:Packages:IR2_UniversalDataExport:UseFolderNameForOutput, help={"Create output name from folder name"}
	CheckBox UseYWaveNameForOutput,pos={15,390},size={225,14},proc=IR2E_UnivExportCheckProc,title="Use Y wave name for output?"
	CheckBox UseYWaveNameForOutput,variable= root:Packages:IR2_UniversalDataExport:UseYWaveNameForOutput, help={"Use Y wave name to create output file name"}

	SetVariable CurrentlyLoadedDataName,limits={0,Inf,0},value= root:Packages:IR2_UniversalDataExport:CurrentlyLoadedDataName, noedit=1,noProc,frame=0
	SetVariable CurrentlyLoadedDataName,pos={3,420},size={370,25},title="Loaded data:", help={"This is data set currently loaded in the tool. These data will be saved."},fstyle=1,labelBack=(65280,21760,0)

	SetVariable CurrentlySetOutputPath,limits={0,Inf,0},value= root:Packages:IR2_UniversalDataExport:CurrentlySetOutputPath, noedit=1,noProc,frame=0
	SetVariable CurrentlySetOutputPath,pos={3,450},size={370,25},title="Export Folder:", help={"This is data folder outside Igor  where the data will be saved."},fstyle=0
	Button ExportOutputPath, pos={100,475},size={180,20}, proc=IR2E_InputPanelButtonProc,title="Set export  folder:", help={"Select export folder where to save new ASCII data sets."}

	SetVariable NewFileOutputName,limits={0,Inf,0},value= root:Packages:IR2_UniversalDataExport:NewFileOutputName,noProc,frame=1
	SetVariable NewFileOutputName,pos={3,520},size={370,25},title="Export file name:", help={"This is name for new data file which will be created"},fstyle=1
	SetVariable OutputNameExtension,limits={0,Inf,0},value= root:Packages:IR2_UniversalDataExport:OutputNameExtension,noProc,frame=1
	SetVariable OutputNameExtension,pos={3,540},size={200,25},title="Export file extension:", help={"This is extension for new data file which will be created"},fstyle=1
	SetVariable HeaderSeparator,limits={0,Inf,0},value= root:Packages:IR2_UniversalDataExport:HeaderSeparator,proc=IR2E_UnivExportToolSetVarProc,frame=1
	SetVariable HeaderSeparator,pos={3,560},size={180,25},title="Header separator:", help={"This is symnol at the start of header line. Include here spaces if you want them..."},fstyle=1
//
	Button ExportData, pos={100,600},size={180,20}, proc=IR2E_InputPanelButtonProc,title="Export Data & Notes", help={"Save ASCII file with data and notes for these data"}
	NVAR MultipleData=root:Packages:IR2_UniversalDataExport:ExportMultipleDataSets
	Button ExportData, disable=2*MultipleData
//;

end
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
Function IR2E_UnivExpCheckboxProc(CB_Struct)
	STRUCT WMCheckboxAction &CB_Struct

//	DoAlert 0,"Fix IR2E_UnivExpCheckboxProc"
	if(CB_Struct.EventCode==2)
		NVAR MultipleData=root:Packages:IR2_UniversalDataExport:ExportMultipleDataSets
		Button ExportData, win=UnivDataExportPanel, disable=2*MultipleData
		if(CB_Struct.checked)

			IR2E_UpdateListOfAvailFiles()
			DoWindow IR2E_MultipleDataSelectionPnl
			if(!V_Flag)
				//DoWindow/K IR2E_MultipleDataSelectionPnl
			
				NewPanel/K=1 /W=(400,44,800,355) as "Multiple Data Export selection"
				DoWIndow/C IR2E_MultipleDataSelectionPnl
				SetDrawLayer UserBack
				SetDrawEnv fsize= 20,fstyle= 1,textrgb= (0,0,65535)
				DrawText 29,29,"Multiple Data Export selection"
				DrawText 10,255,"Configure Universal export tool panel options"
				DrawText 10,275,"Select multiple data above and export : "
				ListBox DataFolderSelection,pos={4,35},size={372,200}, mode=10
				ListBox DataFolderSelection,listWave=root:Packages:IR2_UniversalDataExport:ListOfAvailableData
				ListBox DataFolderSelection,selWave=root:Packages:IR2_UniversalDataExport:SelectionOfAvailableData

				Button UpdateData,pos={280,245},size={100,15},proc=IR2E_ButtonProc,title="Update list"
				Button UpdateData,fSize=10,fStyle=2
				
				Button AllData,pos={4,285},size={100,15},proc=IR2E_ButtonProc,title="Select all data"
				Button AllData,fSize=10,fStyle=2
				Button NoData,pos={120,285},size={100,15},proc=IR2E_ButtonProc,title="DeSelect all data"
				Button NoData,fSize=10,fStyle=2
				Button ProcessAllData,pos={240,285},size={150,15},proc=IR2E_ButtonProc,title="Export selected data"
				Button ProcessAllData,fSize=10,fStyle=2
				Button ProcessAllData fColor=(65535,16385,16385)
			else
			
				DoWindow/F IR2E_MultipleDataSelectionPnl
				
			endif
			AutoPositionWindow/M=0 /R=UnivDataExportPanel IR2E_MultipleDataSelectionPnl
		else
			DoWindow IR2E_MultipleDataSelectionPnl
			if(V_Flag)
				DoWindow/K IR2E_MultipleDataSelectionPnl
			endif
		
		endif
	
	endif

End
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2E_ButtonProc(ctrlName) : ButtonControl
	String ctrlName

		wave SelectionOfAvailableData=root:Packages:IR2_UniversalDataExport:SelectionOfAvailableData
	if(stringmatch(ctrlName,"AllData"))
		SelectionOfAvailableData=1
	endif
	if(stringmatch(ctrlName,"NoData"))
		SelectionOfAvailableData=0
	endif
	if(stringmatch(ctrlName,"UpdateData"))
		IR2E_UpdateListOfAvailFiles()
	endif
	if(stringmatch(ctrlName,"ProcessAllData"))
		IR2E_ExportMultipleFiles()
	endif
	
	
End

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function IR2E_ExportMultipleFiles()

	string OldDF=GetDataFolder(1)
	setDataFolder root:Packages:IR2_UniversalDataExport

	NVAR UseQRSdata=root:Packages:IR2_UniversalDataExport:UseQRSData
	SVAR DataFolderName = root:Packages:IR2_UniversalDataExport:DataFolderName
	SVAR IntensityWaveName=root:Packages:IR2_UniversalDataExport:IntensityWaveName
	SVAR QWavename=root:Packages:IR2_UniversalDataExport:QWavename
	SVAR ErrorWaveName=root:Packages:IR2_UniversalDataExport:ErrorWaveName
	string StartFolderName = RemoveFromList(stringFromList(ItemsInList(DataFolderName , ":")-1,DataFolderName,":"), DataFolderName  , ":")

	Wave/T ListOfAvailableData=root:Packages:IR2_UniversalDataExport:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:IR2_UniversalDataExport:SelectionOfAvailableData

	variable i
	
	For(i=0;i<numpnts(ListOfAvailableData);i+=1)
		if(!UseQRSdata)		//just stuff in Folder name and go ahead...
			if(SelectionOfAvailableData[i])
				DataFolderName = StartFolderName+ListOfAvailableData[i]
				if(!DataFolderExists(DataFolderName ))
					Abort "Problem with data folder definition. Please \"Update list\" and try again" 
				endif
				IR2E_LoadDataInTool()		
				DoUpdate
				sleep/S 1	
				IR2E_ExportTheData()
			endif
		else	//we need to set all strings for qrs data... 
			if(SelectionOfAvailableData[i])
				DataFolderName = StartFolderName+ListOfAvailableData[i]
				if(!DataFolderExists(DataFolderName ))
					Abort "Problem with data folder definition. Please \"Update list\" and try again" 
				endif
				//now for qrs we need to reload the other wave names... 
				STRUCT WMPopupAction PU_Struct
				PU_Struct.ctrlName = "SelectDataFolder"
				PU_Struct.popNum=-1
				PU_Struct.eventCode=2
				PU_Struct.popStr=DataFolderName
				PU_Struct.win = "UnivDataExportPanel"
				//PopupMenu SelectDataFolder win=UnivDataExportPanel, popmatch=DataFolderName
				PopupMenu SelectDataFolder win=UnivDataExportPanel, popmatch=StringFromList(ItemsInList(DataFolderName,":")-1,DataFolderName,":")
				IR2C_PanelPopupControl(PU_Struct)
				IR2E_LoadDataInTool()		
				DoUpdate
				sleep/S 1	
				IR2E_ExportTheData()
			endif
		endif
	
	endfor
	

	setDataFolder OldDF
end
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************

Function IR2E_UpdateListOfAvailFiles()

	string OldDF=GetDataFolder(1)
	setDataFolder root:Packages:IR2_UniversalDataExport
	
	NVAR UseIndra2Data=root:Packages:IR2_UniversalDataExport:UseIndra2Data
	NVAR UseQRSdata=root:Packages:IR2_UniversalDataExport:UseQRSData
	NVAR UseResults = root:Packages:IR2_UniversalDataExport:UseResults
	NVAR UseSMRData = root:Packages:IR2_UniversalDataExport:UseSMRData
//	SVAR StartFolderName=root:Packages:IR2_UniversalDataExport:StartFolderName
	SVAR DataFolderName = root:Packages:IR2_UniversalDataExport:DataFolderName
	string StartFolderName = RemoveFromList(stringFromList(ItemsInList(DataFolderName , ":")-1,DataFolderName,":"), DataFolderName  , ":")
	SVAR IntensityWaveName=root:Packages:IR2_UniversalDataExport:IntensityWaveName
	
	//string CurrentFolders=IR2S_GenStringOfFolders(StartFolderName,UseIndra2Data, UseQRSData,UseSMRData,1)
	string CurrentFolders
	IR2P_GenStringOfFolders(winNm="UnivDataExportPanel")
	SVAR RealLongListOfFolder = root:Packages:IR2_UniversalDataExport:RealLongListOfFolder		//after 2/2013 update this is where the list is.
	CurrentFolders = RealLongListOfFolder
	//these are all folders with data... Now we need to check for results of different type... And clean up those which are not in the same subfolder... 
	variable i, j
	string TempStr
	For(i=ItemsInList(CurrentFolders , ";")-1;i>=0;i-=1)			//cleanup from other start folders...
		TempStr =  StringFromList(i, CurrentFolders , ";")
		if(!stringmatch(TempStr, StartFolderName+"*" ))
			CurrentFolders = RemoveListItem(i, CurrentFolders , ";")
		endif
	endfor	
	//now cleanup from different wave names... Valid only for Indra 2 data and results, not qrs data...
	if(UseIndra2Data || UseResults)
		For(i=ItemsInList(CurrentFolders , ";")-1;i>=0;i-=1)			//cleanup from other start folders...
			TempStr =  StringFromList(i, CurrentFolders , ";")
			if(UseIndra2Data)		//check for Indra 2 data of the right kind... 
				if(!stringmatch(IN2G_CreateListOfItemsInFolder(TempStr,2), "*"+IntensityWaveName+"*" ))
					CurrentFolders = RemoveListItem(i, CurrentFolders , ";")
				endif
			else		//results... May need to modify later, this will manage only same generation results... 
				if(!stringmatch(IN2G_CreateListOfItemsInFolder(TempStr,2), "*"+IntensityWaveName+"*" ))
					CurrentFolders = RemoveListItem(i, CurrentFolders , ";")
				endif
			endif
		endfor	
		
	endif
	
	Wave/T ListOfAvailableData=root:Packages:IR2_UniversalDataExport:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:IR2_UniversalDataExport:SelectionOfAvailableData
		
	Redimension/N=(ItemsInList(CurrentFolders , ";")) ListOfAvailableData
	j=0
	For(i=0;i<ItemsInList(CurrentFolders , ";");i+=1)
		TempStr = ReplaceString(StartFolderName, StringFromList(i, CurrentFolders , ";"),"")
		if(strlen(TempStr)>0)
			ListOfAvailableData[j] = tempStr
			j+=1
		endif
	endfor
	Redimension/N=(Numpnts(ListOfAvailableData))  SelectionOfAvailableData
	SelectionOfAvailableData = 0
	setDataFolder OldDF
end

//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************

Function IR2E_UnivExportToolSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	if(cmpstr(ctrlName,"HeaderSeparator")==0)
		DoWindow ExportNoteDisplay
		if(V_Flag)
			DoWindow/K ExportNoteDisplay
		else
			abort
		endif

		string oldDf=GetDataFolder(1)
		setDataFolder root:Packages:IR2_UniversalDataExport

		NVAR AttachWaveNote
		NVAR DisplayWaveNote
		NVAR UseFolderNameForOutput
		NVAR UseYWaveNameForOutput

		SVAR DataFolderName
		SVAR IntensityWaveName
		SVAR QWavename
		SVAR ErrorWaveName
		SVAR CurrentlyLoadedDataName
		SVAR CurrentlySetOutputPath
		SVAR NewFileOutputName
		SVAR HeaderSeparator
		
		
		Wave/Z tempY=$(DataFolderName+IntensityWaveName)
		if(!WaveExists(tempY))
			setDataFolder OldDf
			abort
		endif	
		string OldNote
		String nb = "ExportNoteDisplay"
		variable i
		if(DisplayWaveNote)
			OldNote = note(TempY) +"Exported="+date()+" "+time()+";"
			NewNotebook/K=1/N=$nb/F=0/V=1/K=0/W=(300,270,700,530) as "Data Notes"
			Notebook $nb defaultTab=20, statusWidth=238, pageMargins={72,72,72,72}
			Notebook $nb font="Arial", fStyle=0, textRGB=(0,0,0)
			For(i=0;i<ItemsInList(OldNOte);i+=1)
				Notebook $nb text=HeaderSeparator + stringFromList(i,OldNote)+"\r"
			endfor
		endif
		setDataFolder OldDf
	endif

End

//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************

Function IR2E_UnivExportCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	NVAR UseFolderNameForOutput
	NVAR UseYWaveNameForOutput

	SVAR DataFolderName
	SVAR IntensityWaveName
	SVAR QWavename
	SVAR ErrorWaveName
	SVAR CurrentlyLoadedDataName
	SVAR CurrentlySetOutputPath
	SVAR NewFileOutputName
	if(cmpstr(ctrlName,"UseFolderNameForOutput")==0 || cmpstr(ctrlName,"UseYWaveNameForOutput")==0)
		
		NewFileOutputName = ""
		if(UseFolderNameForOutput)
			NewFileOutputName += IN2G_RemoveExtraQuote(StringFromList(ItemsInList(DataFolderName,":")-1,DataFolderName,":"),1,1)
		endif
		if(UseFolderNameForOutput && UseYWaveNameForOutput)
			NewFileOutputName += "_"
		endif
		if(UseYWaveNameForOutput)
			NewFileOutputName += IN2G_RemoveExtraQuote(IntensityWaveName,1,1)
		endif	
		
	endif

End

//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************

Function IR2E_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2_UniversalDataExport
	if(cmpstr(ctrlName,"LoadAndGraphData")==0)
		//here we load the data and create default values
		IR2E_LoadDataInTool()
	endif
	if(cmpstr(ctrlName,"ExportOutputPath")==0)
		//here we set output path and patch it in the string to be seen by user 
		IR2E_ChangeExportPath()
	endif
	if(cmpstr(ctrlName,"ExportData")==0)
		//here we do whatever is appropriate...
		IR2E_ExportTheData()
	endif
	if(cmpstr(ctrlName,"GetHelp")==0)
		//Open www manual with the right page
		IN2G_OpenWebManual("Irena/ExportData.html")
	endif
	
	setDataFolder oldDF
end
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************

Function IR2E_ExportTheData()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2_UniversalDataExport

	NVAR AttachWaveNote
	NVAR GraphData
	NVAR DisplayWaveNote
	NVAR UseFolderNameForOutput
	NVAR UseYWaveNameForOutput

	SVAR DataFolderName
	SVAR IntensityWaveName
	SVAR QWavename
	SVAR ErrorWaveName
	SVAR CurrentlyLoadedDataName
	SVAR CurrentlySetOutputPath
	SVAR NewFileOutputName
	SVAR OutputNameExtension
	SVAR HeaderSeparator
	
	Wave/Z TempY=$(DataFolderName+possiblyquoteName(IntensityWaveName))
	Wave/Z TempX=$(DataFolderName+possiblyquoteName(QWavename))
	Wave/Z TempE=$(DataFolderName+possiblyquoteName(ErrorWaveName))

	if(!WaveExists(TempY) && !WaveExists(TempX))
		abort
	endif
	variable HaveErrors=0
	if(WaveExists(TempE))
		HaveErrors=1
	endif

	if(strlen(NewFileOutputName)==0)
		abort "Create output file name, please first"
	endif
	//Chhek for existing file and manage on our own...
	variable refnum
	string FinalOutputName=NewFileOutputName
	if(stringmatch(IgorInfo(2),"Macintosh") && strlen(FinalOutputName)>25)
		FinalOutputName = FinalOutputName[0,25]
	endif
	if(strlen(OutputNameExtension)>0)
		FinalOutputName+="."+OutputNameExtension
	endif
	
	Open/Z=1 /R/P=IR2E_ExportPath refnum as FinalOutputName
	if(V_Flag==0)
		DoAlert 1, "The file with this name: "+FinalOutputName+ " in this location already exists, overwrite?"
		if(V_Flag!=1)
			abort
		endif
		close/A
		//user wants to delete the file
		OpenNotebook/V=0/P=IR2E_ExportPath/N=JunkNbk  FinalOutputName
		DoWindow/D /K JunkNbk
	endif
	close/A
	
	Duplicate TempY, NoteTempY
	string OldNoteT=note(TempY)
	note/K NoteTempY
	note NoteTempY, OldNoteT+"Exported="+date()+" "+time()+";"
	make/T/O WaveNoteWave
	if (AttachWaveNote)
		IN2G_PasteWnoteToWave("NoteTempY", WaveNoteWave,HeaderSeparator)
		Save/G/M="\r\n"/P=IR2E_ExportPath WaveNoteWave as FinalOutputName
	endif
	if(HaveErrors)
		Save/A=2/G/W/M="\r\n"/P=IR2E_ExportPath TempX,TempY,TempE as FinalOutputName			///P=Datapath
	else
		Save/A=2/G/W/M="\r\n"/P=IR2E_ExportPath TempX,TempY as FinalOutputName			///P=Datapath
	endif

	KillWaves/Z WaveNoteWave, NoteTempY
	print "Saved data into : "+FinalOutputName
end

//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************

Function IR2E_LoadDataInTool()

	DoWindow TempExportGraph
	if(V_Flag)
		DoWindow/K TempExportGraph
	endif
	DoWindow ExportNoteDisplay
	if(V_Flag)
		DoWindow/K ExportNoteDisplay
	endif
	KillWaves/Z TempX, TampY, TempE


	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2_UniversalDataExport

	NVAR AttachWaveNote
	NVAR GraphData
	NVAR DisplayWaveNote
	NVAR UseFolderNameForOutput
	NVAR UseYWaveNameForOutput

	SVAR DataFolderName
	SVAR IntensityWaveName
	SVAR QWavename
	SVAR ErrorWaveName
	SVAR CurrentlyLoadedDataName
	SVAR CurrentlySetOutputPath
	SVAR NewFileOutputName
	SVAR HeaderSeparator
	
	
	Wave/Z tempY=$(DataFolderName+possiblyquoteName(IntensityWaveName))
	Wave/Z tempX=$(DataFolderName+possiblyquoteName(QWavename))
	Wave/Z tempE=$(DataFolderName+possiblyquoteName(ErrorWaveName))
	
	if(!WaveExists(tempY) && !WaveExists(tempX))
		abort
	endif
	
	CurrentlyLoadedDataName = DataFolderName+IntensityWaveName

	if(GraphData)
		Display/K=1/W=(300,40,700,250)  TempY vs TempX as "Preview of export data"
		DoWindow/C TempExportGraph
		ModifyGraph log=1
		TextBox/C/N=text0  CurrentlyLoadedDataName
		IN2G_AutoAlignPanelAndGraph()
	endif
	string OldNote
	String nb = "ExportNoteDisplay"
	variable i
	if(DisplayWaveNote)
		OldNote = note(TempY) +"Exported="+date()+" "+time()+";"
		NewNotebook/K=1/N=$nb/F=0/V=1/K=0/W=(300,270,700,530) as "Data Notes"
		Notebook $nb defaultTab=20, statusWidth=238, pageMargins={72,72,72,72}
		Notebook $nb font="Arial", fSize=10, fStyle=0, textRGB=(0,0,0)
		For(i=0;i<ItemsInList(OldNOte);i+=1)
			Notebook $nb text=HeaderSeparator+ stringFromList(i,OldNote)+"\r"
		endfor
			AutopositionWindow/M=0 /R=TempExportGraph ExportNoteDisplay 
	endif
	
// UseFolderNameForOutput
// UseYWaveNameForOutput

	NewFileOutputName = ""
	if(UseFolderNameForOutput)
		NewFileOutputName += IN2G_RemoveExtraQuote(StringFromList(ItemsInList(DataFolderName,":")-1,DataFolderName,":"),1,1)
	endif
	if(UseFolderNameForOutput && UseYWaveNameForOutput)
		NewFileOutputName += "_"
	endif
	if(UseYWaveNameForOutput)
		NewFileOutputName += IN2G_RemoveExtraQuote(IntensityWaveName,1,1)
	endif	
//	if(UseFolderNameForOutput || UseYWaveNameForOutput)
//		NewFileOutputName += ".dat"
//	endif

	setDataFolder oldDF

end
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************

Function IR2E_ChangeExportPath()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2_UniversalDataExport
	SVAR CurrentlySetOutputPath=root:Packages:IR2_UniversalDataExport:CurrentlySetOutputPath
	NewPath/O/M="Select new output folder" IR2E_ExportPath
	PathInfo IR2E_ExportPath
	CurrentlySetOutputPath=S_Path

	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR2E_InitUnivDataExport()


	string OldDf=GetDataFolder(1)
	setdatafolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S IR2_UniversalDataExport

	string ListOfVariables
	string ListOfStrings
	variable i
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;UseSMRData;UseUserDefinedData;"
	ListOfVariables+="AttachWaveNote;GraphData;DisplayWaveNote;UseFolderNameForOutput;UseYWaveNameForOutput;"
	ListOfVariables+="ExportMultipleDataSets;"

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	ListOfStrings+="CurrentlyLoadedDataName;CurrentlySetOutputPath;NewFileOutputName;"
	
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	


	make/O/T/N=0 ListOfAvailableData
	make/O/N=0 SelectionOfAvailableData
	
	SVAR/Z OutputNameExtension
	if(!SVAR_Exists(OutputNameExtension))
		string/G OutputNameExtension
		OutputNameExtension="dat"
	endif
	SVAR/Z HeaderSeparator
	if(!SVAR_Exists(HeaderSeparator))
		string/G HeaderSeparator
		HeaderSeparator="#   "
	endif
	//Ouptu path
	PathInfo IR2E_ExportPath
	if(!V_Flag)
		PathInfo Igor
		NewPath/Q IR2E_ExportPath S_Path
	endif
	PathInfo IR2E_ExportPath
	SVAR CurrentlySetOutputPath
	CurrentlySetOutputPath=S_Path
	
	SVAR NewFileOutputName
	NewFileOutputName=""
	SVAR CurrentlyLoadedDataName
	CurrentlyLoadedDataName = ""
	SVAR DataFolderName
	DataFolderName=""
	SVAR IntensityWaveName
	IntensityWaveName=""
	SVAR QWavename
	QWavename=""
	SVAR ErrorWaveName
	ErrorWaveName=""
	setDataFolder OldDf


end

//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
