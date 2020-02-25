#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.1
constant IR3JversionNumber = 1			//Data merging panel version number

//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.1 combined this ipf with "Simple fits models"
//1.0 Simple Fits tool first test version 



///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3J_MultiSaPlotFit()

	IN2G_CheckScreenSize("width",1200)
	DoWIndow IR3J_MultiSaPlotFitPanel
	if(V_Flag)
		DoWindow/F IR3J_MultiSaPlotFitPanel
		//DoWindow/K IR3J_MultiSaPlotFitPanel
		//Execute("IR3J_MultiSaPlotFitPanel()")
	else
		IR3J_InitMultiSaPlotFit()
		IR3J_MultiSaPlotFitPanelFnct()
//		setWIndow IR3J_MultiSaPlotFitPanel, hook(CursorMoved)=IR3D_PanelHookFunction
	endif
//	UpdatePanelVersionNumber("IR3D_DataMergePanel", IR3DversionNumber)
//	IR3D_UpdateListOfAvailFiles(1)
//	IR3D_UpdateListOfAvailFiles(2)
//	IR3D_RebuildListboxTables()
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR3J_MultiSaPlotFitPanelFnct()
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,1195,800) as "Simple Fits"
	DoWIndow/C IR3J_MultiSaPlotFitPanel
	TitleBox MainTitle title="Multi Sample plot & fit",pos={200,2},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fSize=22,fColor=(0,0,52224)
//	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,148},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
//	TitleBox FakeLine2 title=" ",fixedSize=1,size={330,3},pos={16,428},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
//	TitleBox FakeLine3 title=" ",fixedSize=1,size={330,3},pos={16,512},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
//	TitleBox FakeLine4 title=" ",fixedSize=1,size={330,3},pos={16,555},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
//	TitleBox Info1 title="Modify data 1                            Modify Data 2",pos={36,325},frame=0,fstyle=1, fixedSize=1,size={350,20},fSize=12
//	TitleBox FakeLine5 title=" ",fixedSize=1,size={330,3},pos={16,300},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena:MultiSaPlotFit","IR3J_MultiSaPlotFitPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)


	DrawText 60,25,"Data selection"
	Checkbox UseIndra2Data, pos={10,30},size={76,14},title="USAXS", proc=IR3J_LinearFitsCheckProc, variable=root:Packages:Irena:MultiSaPlotFit:UseIndra2Data
	checkbox UseQRSData, pos={120,30}, title="QRS(QIS)", size={76,14},proc=IR3J_LinearFitsCheckProc, variable=root:Packages:Irena:MultiSaPlotFit:UseQRSdata
	PopupMenu StartFolderSelection,pos={10,50},size={180,15},proc=IR3J_PopMenuProc,title="Start fldr"
	SVAR DataStartFolder = root:Packages:Irena:MultiSaPlotFit:DataStartFolder
	PopupMenu StartFolderSelection,mode=1,popvalue=DataStartFolder,value= #"\"root:;\"+IR2S_GenStringOfFolders2(root:Packages:Irena:MultiSaPlotFit:UseIndra2Data, root:Packages:Irena:MultiSaPlotFit:UseQRSdata,2,1)"
	SetVariable FolderNameMatchString,pos={10,75},size={210,15}, proc=IR3J_SetVarProc,title="Folder Match (RegEx)"
	Setvariable FolderNameMatchString,fSize=10,fStyle=2, variable=root:Packages:Irena:MultiSaPlotFit:DataMatchString
	PopupMenu SortFolders,pos={10,100},size={180,20},fStyle=2,proc=IR3J_PopMenuProc,title="Sort Folders"
	SVAR FolderSortString = root:Packages:Irena:MultiSaPlotFit:FolderSortString
	PopupMenu SortFolders,mode=1,popvalue=FolderSortString,value=#"root:Packages:Irena:MultiSaPlotFit:FolderSortStringAll"

	PopupMenu SubTypeData,pos={10,120},size={180,20},fStyle=2,proc=IR3J_PopMenuProc,title="Sub-type Data"
	SVAR DataSubType = root:Packages:Irena:MultiSaPlotFit:DataSubType
	PopupMenu SubTypeData,mode=1,popvalue=DataSubType,value= #""


	ListBox DataFolderSelection,pos={4,165},size={250,500}, mode=10
	ListBox DataFolderSelection,listWave=root:Packages:Irena:MultiSaPlotFit:ListOfAvailableData
	ListBox DataFolderSelection,selWave=root:Packages:Irena:MultiSaPlotFit:SelectionOfAvailableData
	ListBox DataFolderSelection,proc=IR3J_LinFitsListBoxProc


	//Plotting controls...
	
	Button PlotData,pos={280,180},size={100,20}, proc=noproc,title="Plot Selected", help={"Plot selected data"}


	//this is for fits, for now Guinier. Move to tab as needed
	//	ListOfVariables+="DataBackground;"
	//	ListOfVariables+="Guinier_Rg;Guinier_I0;"
	//	ListOfVariables+="ProcessManually;ProcessSequentially;OverwriteExistingData;AutosaveAfterProcessing;"
	//	ListOfVariables+="DataQEnd;DataQstart;"	
	//		SetVariable DataQEnd,pos={280,90},size={200,15}, proc=IR3D_MergeDataSetVarProc,title="Fit Q max      ",bodyWidth=150
	//		Setvariable DataQEnd, variable=root:Packages:Irena:MultiSaPlotFit:DataQEnd, limits={-inf,inf,0}
	//		SetVariable DataQstart,pos={280,110},size={200,15}, proc=IR3D_MergeDataSetVarProc,title="Fit Q start      ",bodyWidth=150
	//		Setvariable DataQstart, variable=root:Packages:Irena:MultiSaPlotFit:DataQstart, limits={-inf,inf,0}
	//		SetVariable DataBackground,pos={280,130},size={200,15}, noproc,title="Background",bodyWidth=150
	//		Setvariable DataBackground, variable=root:Packages:Irena:MultiSaPlotFit:DataBackground, limits={-inf,inf,0}
	//	
	//		PopupMenu SimpleModel,pos={280,175},size={180,20},fStyle=2,proc=IR3J_PopMenuProc,title="Model to fit : "
	//		PopupMenu SimpleModel,mode=1,popvalue=root:Packages:Irena:MultiSaPlotFit:ListOfSimpleModels,value= root:Packages:Irena:MultiSaPlotFit:SimpleModel
	//	
	//		SetVariable Guinier_Rg,pos={280,220},size={200,15}, proc=IR3D_MergeDataSetVarProc,title="Guinier  Rg    ",bodyWidth=150
	//		Setvariable Guinier_Rg, variable=root:Packages:Irena:MultiSaPlotFit:Guinier_Rg, limits={-inf,inf,0}
	//	
	//		SetVariable Guinier_I0,pos={280,200},size={200,15}, proc=IR3D_MergeDataSetVarProc,title="Guinier I0    ",bodyWidth=150
	//		Setvariable Guinier_I0, variable=root:Packages:Irena:MultiSaPlotFit:Guinier_I0, limits={-inf,inf,0}


//	Button ProcessSaveData, pos={490,135}, size={20,500}, title="S\rA\rV\rE\r\rD\rA\rT\rA", proc=IR3D_MergeButtonProc, help={"Saves data which were automtaticaly processed already. "}, labelBack=(65535,60076,49151)
//	//TextBox/C/N=text1/O=90/A=MC "Save Data", TextBox/C/N=text1/A=MC "S\rA\rV\rE\r\rD\rA\rT\rA"
//
//	Checkbox ProcessTest, pos={520,30},size={76,14},title="Test mode", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessTest
//	Checkbox ProcessMerge, pos={520,50},size={76,14},title="Merge mode", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessMerge
//	Checkbox ProcessMerge2, pos={520,70},size={76,14},title="Merge 2 mode", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessMerge2
//
//	Checkbox ProcessManually, pos={650,30},size={76,14},title="Process individually", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessManually
//	Checkbox ProcessSequentially, pos={650,50},size={76,14},title="Process as sequence", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessSequentially
//
//	Checkbox AutosaveAfterProcessing, pos={780,30},size={76,14},title="Save Immediately", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:AutosaveAfterProcessing, disable=!root:Packages:Irena:SASDataMerging:ProcessManually
//	Checkbox OverwriteExistingData, pos={780,50},size={76,14},title="Overwrite existing data", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:OverwriteExistingData
//	TitleBox SavedDataMessage title="",fixedSize=1,size={100,17}, pos={780,70}, variable= root:Packages:Irena:SASDataMerging:SavedDataMessage
//	TitleBox SavedDataMessage help={"Are the data saved?"}, fColor=(65535,16385,16385), frame=0, fSize=12,fstyle=1
//
//	TitleBox UserMessage title="",fixedSize=1,size={470,20}, pos={480,90}, variable= root:Packages:Irena:SASDataMerging:UserMessageString
//	TitleBox UserMessage help={"This is what will happen"}
//
//		
//	Button AutoScale,pos={520,117},size={100,17}, proc=IR3D_MergeButtonProc,title="Test AutoScale", help={"Autoscales. Set cursors on data overlap and the data 2 will be scaled to Data 1 using integral intensity"}, disable=!root:Packages:Irena:SASDataMerging:ProcessTest
//	Button MergeData,pos={640,117},size={100,17}, proc=IR3D_MergeButtonProc,title="Test Merge", help={"Scales data 2 to data 1 and sets background for data 1 for merging. Sets checkboxes and trims. Saves data also"}, disable=!root:Packages:Irena:SASDataMerging:ProcessTest
//	Button MergeData2,pos={760,117},size={100,17}, proc=IR3D_MergeButtonProc,title="Test Merge 2", help={"Scales data 2 to data 1, optimizes Q shift for data 2 and sets background for data 1 for merging. Saves data also"}, disable=!root:Packages:Irena:SASDataMerging:ProcessTest

	Display /W=(521,10,1183,340) /HOST=# /N=LogLogDataDisplay
	SetActiveSubwindow ##
	Display /W=(521,350,1183,410) /HOST=# /N=ResidualDataDisplay
	SetActiveSubwindow ##
	Display /W=(521,420,1183,750) /HOST=# /N=LinearizedDataDisplay
	SetActiveSubwindow ##

//	SetVariable DataFolderName1,pos={550,625},size={510,15}, noproc,variable=root:Packages:Irena:SASDataMerging:DataFolderName1, title="Data 1:       ", disable=2
//	SetVariable DataFolderName2,pos={550,642},size={510,15}, noproc,variable=root:Packages:Irena:SASDataMerging:DataFolderName2, title="Data 2:       ", disable=2
//	SetVariable NewDataFolderName,pos={550,659},size={510,15}, noproc,variable=root:Packages:Irena:SASDataMerging:NewDataFolderName, title="Merged Data: "

	DrawText 4,678,"Double click to add data to graph."
	DrawText 4,695,"Shift-click to select range of data."
	DrawText 4,710,"Ctrl/Cmd-click to select one data set."
	DrawText 4,725,"Regex for not contain: ^((?!string).)*$"
	DrawText 4,740,"Regex for contain:  string"
	DrawText 4,755,"Regex for case independent contain:  (?i)string"
	
	IR3J_FixPanelControls()
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3J_FixPanelControls()

	NVAR UseIndra2Data = root:Packages:Irena:MultiSaPlotFit:UseIndra2Data
	NVAR UseQRSData=root:Packages:Irena:MultiSaPlotFit:UseQRSdata
	SVAR DataSubType = root:Packages:Irena:MultiSaPlotFit:DataSubType
	SVAR DataSubTypeResultsList=root:Packages:Irena:MultiSaPlotFit:DataSubTypeResultsList
	SVAR DataSubTypeUSAXSList = root:Packages:Irena:MultiSaPlotFit:DataSubTypeUSAXSList 
	if(UseIndra2Data)
			PopupMenu SubTypeData, disable =0
			PopupMenu SubTypeData,mode=1,popvalue=DataSubType,value=#"root:Packages:Irena:MultiSaPlotFit:DataSubTypeUSAXSList"
	else
			PopupMenu SubTypeData,mode=1,popvalue=DataSubType,value= ""
			PopupMenu SubTypeData, disable=1
	endif
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3J_InitMultiSaPlotFit()	


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
	ListOfStrings+="SimpleModel;ListOfSimpleModels;"
	ListOfStrings+="DataSubTypeUSAXSList;DataSubTypeResultsList;DataSubType;"

	ListOfVariables="UseIndra2Data1;UseQRSdata1;"
	ListOfVariables+="DataBackground;"
	ListOfVariables+="Guinier_Rg;Guinier_I0;"
	ListOfVariables+="ProcessManually;ProcessSequentially;OverwriteExistingData;AutosaveAfterProcessing;"
	ListOfVariables+="DataQEnd;DataQstart;"

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
	SVAR ListOfSimpleModels
	ListOfSimpleModels="Guinier;"
	SVAR FolderSortStringAll
	FolderSortStringAll = "Alphabetical;Reverse Alphabetical;_xyz;_xyz.ext;Reverse _xyz;Reverse _xyz.ext;Sxyz_;Reverse Sxyz_;_xyzmin;_xyzC;_xyzpct;_xyz_000;Reverse _xyz_000;"
	SVAR SimpleModel
	if(strlen(SimpleModel)<1)
		SimpleModel="Guinier"
	endif
	SVAR DataSubTypeUSAXSList
	DataSubTypeUSAXSList="DSM_Int;SMR_Int;R_Int;BL_R_Int;USAXS_PD;Monitor;"
	SVAR DataSubTypeResultsList
	DataSubTypeResultsList="Size"
	SVAR DataSubType
	DataSubType="DSM_Int"


//	NVAR OverwriteExistingData
//	NVAR AutosaveAfterProcessing
//	OverwriteExistingData=1
//	AutosaveAfterProcessing=1
//	if(ProcessTest)
//		AutosaveAfterProcessing=0
//	endif

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

Function IR3J_LinearFitsCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR UseIndra2Data =  root:Packages:Irena:MultiSaPlotFit:UseIndra2Data
			NVAR UseQRSData =  root:Packages:Irena:MultiSaPlotFit:UseQRSData
			SVAR DataStartFolder = root:Packages:Irena:MultiSaPlotFit:DataStartFolder
//		  	SVAR UserMessageString=root:Packages:Irena:SASDataMerging:UserMessageString
//			NVAR ProcessManually =root:Packages:Irena:SASDataMerging:ProcessManually
//			NVAR ProcessSequentially=root:Packages:Irena:SASDataMerging:ProcessSequentially
//			NVAR OverwriteExistingData=root:Packages:Irena:SASDataMerging:OverwriteExistingData
//			NVAR AutosaveAfterProcessing=root:Packages:Irena:SASDataMerging:AutosaveAfterProcessing
//			Checkbox AutosaveAfterProcessing, win=IR3D_DataMergePanel, disable=0
//			Checkbox ProcessSequentially, win=IR3D_DataMergePanel, disable=0
		  	if(stringmatch(cba.ctrlName,"UseIndra2Data"))
		  		if(checked)
		  			UseQRSData = 0
		  			IR3J_FixPanelControls()
		  		endif
		  	endif
		  	if(stringmatch(cba.ctrlName,"UseQRSData"))
		  		if(checked)
		  			UseIndra2Data = 0
		  			IR3J_FixPanelControls()
		  		endif
		  	endif
		  	if(stringmatch(cba.ctrlName,"UseQRSData")||stringmatch(cba.ctrlName,"UseIndra2Data"))
		  		DataStartFolder = "root:"
		  		PopupMenu StartFolderSelection,win=IR3J_MultiSaPlotFitPanel, mode=1,popvalue="root:"
				IR3J_UpdateListOfAvailFiles()
		  	endif
//			Checkbox AutosaveAfterProcessing, win=IR3D_DataMergePanel, disable=0
//			UserMessageString = ""
//		  	if(stringmatch(cba.ctrlName,"ProcessManually"))
//	  			if(checked)
//	  				ProcessSequentially = 0
//	  			endif
//	  		endif
//		  	if(stringmatch(cba.ctrlName,"ProcessSequentially"))
//	  			if(checked)
//	  				ProcessManually = 0
//	  				ProcessTest = 0
//	  				AutosaveAfterProcessing = 1
//	  				if(ProcessTest+ProcessMerge+ProcessMerge2!=1)
//	  					ProcessMerge2=1
//	  					ProcessMerge =0
//	  				endif
//					//Checkbox AutosaveAfterProcessing, win=IR3D_DataMergePanel, disable=1
//	  			endif
//	  		endif
//		  	if(stringmatch(cba.ctrlName,"ProcessTest"))
//	  			if(checked)
//	  				ProcessMerge = 0
//	  				ProcessMerge2 = 0
//	  				AutosaveAfterProcessing = 0
//	  				ProcessManually = 1
//	  				ProcessSequentially = 0
//	  			endif
//	  		endif
//		  	if(stringmatch(cba.ctrlName,"ProcessMerge"))
//	  			if(checked)
//	  				ProcessTest = 0
//	  				ProcessMerge2 = 0
//					UserMessageString += "Using Merge. "
//	  			endif
//	  		endif
//		  	if(stringmatch(cba.ctrlName,"ProcessMerge2"))
//	  			if(checked)
//	  				ProcessMerge = 0
//	  				ProcessTest = 0
//					UserMessageString += "Using Merge2. "
//	  			endif
//	  		endif
//	//	  	if(stringmatch(cba.ctrlName,"ProcessMerge2")||stringmatch(cba.ctrlName,"ProcessMerge")||stringmatch(cba.ctrlName,"ProcessTest"))
////			endif
//			IR3D_SetGUIControls()
	  		
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
Function IR3J_UpdateListOfAvailFiles()


	string OldDF=GetDataFolder(1)
	setDataFolder root:Packages:Irena:MultiSaPlotFit
	
	NVAR UseIndra2Data=root:Packages:Irena:MultiSaPlotFit:UseIndra2Data
	NVAR UseQRSdata=root:Packages:Irena:MultiSaPlotFit:UseQRSData
	SVAR StartFolderName=root:Packages:Irena:MultiSaPlotFit:DataStartFolder
	SVAR DataMatchString= root:Packages:Irena:MultiSaPlotFit:DataMatchString
	string LStartFolder, FolderContent
	if(stringmatch(StartFolderName,"---"))
		LStartFolder="root:"
	else
		LStartFolder = StartFolderName
	endif
	string CurrentFolders=IR3D_GenStringOfFolders(LStartFolder,UseIndra2Data, UseQRSData, 2,0,DataMatchString)

	Wave/T ListOfAvailableData=root:Packages:Irena:MultiSaPlotFit:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:Irena:MultiSaPlotFit:SelectionOfAvailableData
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
	SelectionOfAvailableData = 0
	IR3J_SortListOfAvailableFldrs()
	setDataFolder OldDF
end


//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function IR3J_SortListOfAvailableFldrs()
	
	SVAR FolderSortString=root:Packages:Irena:MultiSaPlotFit:FolderSortString
	Wave/T ListOfAvailableData=root:Packages:Irena:MultiSaPlotFit:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:Irena:MultiSaPlotFit:SelectionOfAvailableData
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
	elseif(stringMatch(FolderSortString,"_xyz"))
		For(i=0;i<numpnts(TempWv);i+=1)
			TempWv[i] = str2num(StringFromList(ItemsInList(ListOfAvailableData[i]  , "_")-1, ListOfAvailableData[i]  , "_"))
		endfor
		Sort TempWv, ListOfAvailableData
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
//**************************************************************************************
//**************************************************************************************

Function IR3J_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if(stringmatch(ctrlName,"StartFolderSelection"))
		//Update the listbox using start folde popStr
		SVAR StartFolderName=root:Packages:Irena:MultiSaPlotFit:DataStartFolder
		StartFolderName = popStr
		IR3J_UpdateListOfAvailFiles()
	endif
	if(stringmatch(ctrlName,"SortFolders"))
		//do something here
		SVAR FolderSortString = root:Packages:Irena:MultiSaPlotFit:FolderSortString
		FolderSortString = popStr
		IR3J_UpdateListOfAvailFiles()
	endif
	if(stringmatch(ctrlName,"SimpleModel"))
		//do something here
		SVAR SimpleModel = root:Packages:Irena:MultiSaPlotFit:SimpleModel
		SimpleModel = popStr
		IR3J_CreateLinearizedData()
		IR3J_AppendDataToGraphModel()
	endif

	if(stringmatch(ctrlName,"SubTypeData"))
		//do something here
		SVAR DataSubType = root:Packages:Irena:MultiSaPlotFit:DataSubType
		DataSubType = popStr
	endif
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3J_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	variable tempP
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
			if(stringmatch(sva.ctrlName,"FolderNameMatchString1"))
				IR3D_UpdateListOfAvailFiles(1)
				IR3D_RebuildListboxTables()
//				IR2S_SortListOfAvailableFldrs()
			endif
			NVAR DataQstart=root:Packages:Irena:MultiSaPlotFit:DataQstart
			NVAR DataQEnd=root:Packages:Irena:MultiSaPlotFit:DataQEnd
			
			if(stringmatch(sva.ctrlName,"DataQEnd"))
				WAVE OriginalDataQWave = root:Packages:Irena:MultiSaPlotFit:OriginalDataQWave
				tempP = BinarySearch(OriginalDataQWave, DataQEnd )
				if(tempP<1)
					print "Wrong Q value set, Data Q max must be at most 1 point before the end of Data"
					tempP = numpnts(OriginalDataQWave)-2
					DataQEnd = OriginalDataQWave[tempP]
				endif
	//			cursor /W=IR3D_DataMergePanel#DataDisplay B, OriginalData1IntWave, tempP
			endif
			if(stringmatch(sva.ctrlName,"DataQstart"))
				WAVE OriginalDataQWave = root:Packages:Irena:MultiSaPlotFit:OriginalDataQWave
				tempP = BinarySearch(OriginalDataQWave, DataQstart )
				if(tempP<1)
					print "Wrong Q value set, Data Q min must be at least 1 point from the start of Data"
					tempP = 1
					DataQstart = OriginalDataQWave[tempP]
				endif
	//			cursor /W=IR3D_DataMergePanel#DataDisplay A, OriginalData2IntWave, tempP
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
//**************************************************************************************
//**************************************************************************************

Function IR3J_LinFitsListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable row = lba.row
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave
	string FoldernameStr
	Variable isData1or2
	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
			break
		case 3: // double click
//			NVAR ProcessTest=root:Packages:Irena:SASDataMerging:ProcessTest
//			NVAR ProcessManually=root:Packages:Irena:SASDataMerging:ProcessManually
//			NVAR AutosaveAfterProcessing = root:Packages:Irena:SASDataMerging:AutosaveAfterProcessing
//			if(col==0)
//				isData1or2=1
//			else
//				isData1or2=2
//			endif
			FoldernameStr=listWave[row]
			IR3J_CopyAndAppendData(FoldernameStr)
//			if(col==1&&!ProcessTest)		//this is second column of data
//				IR3D_MergeProcessData()
//			endif
//			if(col==1&&AutosaveAfterProcessing&&ProcessManually)
//				IR3D_SaveData()
//			endif
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
Function IR3J_CopyAndAppendData(FolderNameStr)
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
		SVAR DataSubType = root:Packages:Irena:MultiSaPlotFit:DataSubType
		//these are variables used by the control procedure
		NVAR  UseResults=  root:Packages:Irena:MultiSaPlotFit:UseResults
		NVAR  UseUserDefinedData=  root:Packages:Irena:MultiSaPlotFit:UseUserDefinedData
		NVAR  UseModelData = root:Packages:Irena:MultiSaPlotFit:UseModelData
		SVAR DataFolderName  = root:Packages:Irena:MultiSaPlotFit:DataFolderName 
		SVAR IntensityWaveName = root:Packages:Irena:MultiSaPlotFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena:MultiSaPlotFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena:MultiSaPlotFit:ErrorWaveName
		UseResults = 0
		UseUserDefinedData = 0
		UseModelData = 0
		DataFolderName = DataStartFolder+FolderNameStr
		if(UseQRSdata)
			//get the names of waves, assume this tool actually works. May not under some conditions. In that case this tool will not work. 
			QWavename = stringFromList(0,IR2P_ListOfWaves("Xaxis","", "IR3J_MultiSaPlotFitPanel"))
			IntensityWaveName = stringFromList(0,IR2P_ListOfWaves("Yaxis","*", "IR3J_MultiSaPlotFitPanel"))
			ErrorWaveName = stringFromList(0,IR2P_ListOfWaves("Error","*", "IR3J_MultiSaPlotFitPanel"))
			if(UseIndra2Data)
				dQWavename = ReplaceString("Qvec", QWavename, "dQ")
			elseif(UseQRSdata)
				dQWavename = "w"+QWavename[1,31]
			else
				dQWavename = ""
			endif
		elseif(UseIndra2Data)
			string DataSubTypeInt = DataSubType
			string QvecLookup="R_Int=R_Qvec;BL_R_Int=BL_R_Qvec;SMR_Int=SMR_Qvec;DSM_Int=DSM_Qvec;USAXS_PD=Ar_encoder;Monitor=Ar_encoder;"
			string ErrorLookup="R_Int=R_Error;BL_R_Int=BL_R_error;SMR_Int=SMR_Error;DSM_Int=DSM_error;"
			string dQLookup="SMR_Int=SMR_dQ;DSM_Int=DSM_dQ;"
			string DataSubTypeQvec = StringByKey(DataSubTypeInt, QvecLookup,"=",";")
			string DataSubTypeError = StringByKey(DataSubTypeInt, ErrorLookup,"=",";")
			string DataSubTypedQ = StringByKey(DataSubTypeInt, dQLookup,"=",";")
			IntensityWaveName = DataSubTypeInt
			QWavename = QvecLookup
			ErrorWaveName = ErrorLookup
			dQWavename = dQLookup
		endif
		Wave/Z SourceIntWv=$(DataFolderName+IntensityWaveName)
		Wave/Z SourceQWv=$(DataFolderName+QWavename)
		Wave/Z SourceErrorWv=$(DataFolderName+ErrorWaveName)
		Wave/Z SourcedQWv=$(DataFolderName+dQWavename)
		if(!WaveExists(SourceIntWv)||	!WaveExists(SourceQWv))
			print "Data selection failed for "+DataFolderName
			return 0
		endif
		Duplicate/O SourceIntWv, OriginalDataIntWave
		Duplicate/O SourceQWv, OriginalDataQWave
		if(WaveExists(SourceErrorWv))
			Duplicate/O SourceErrorWv, OriginalDataErrorWave
		else
			Duplicate/O OriginalDataIntWave, OriginalDataErrorWave
			Wave OriginalDataErrorWave
			OriginalDataErrorWave = 0
		endif
		if(WaveExists(SourcedQWv))
			Duplicate/O SourcedQWv, OriginalDatadQWave
		else
			dQWavename=""
		endif
		IR3J_AppendDataToGraphLogLog()
		IR3J_CreateLinearizedData()
		IR3J_AppendDataToGraphModel()
		print "Added Data from folder : "+DataFolderName
	SetDataFolder oldDf
	return 1
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3J_CreateLinearizedData()

	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena:MultiSaPlotFit					//go into the folder
	Wave OriginalDataIntWave=root:Packages:Irena:MultiSaPlotFit:OriginalDataIntWave
	Wave OriginalDataQWave=root:Packages:Irena:MultiSaPlotFit:OriginalDataQWave
	Wave OriginalDataErrorWave=root:Packages:Irena:MultiSaPlotFit:OriginalDataErrorWave
	SVAR SimpleModel=root:Packages:Irena:MultiSaPlotFit:SimpleModel
	Duplicate/O OriginalDataIntWave, LinModelDataIntWave, ModelNormalizedResidual
	Duplicate/O OriginalDataQWave, LinModelDataQWave, ModelNormResXWave
	Duplicate/O OriginalDataErrorWave, LinModelDataEWave
	ModelNormalizedResidual = 0
	if(stringmatch(SimpleModel,"Guinier"))
		LinModelDataQWave = OriginalDataQWave^2
		ModelNormResXWave = OriginalDataQWave^2
	endif
	
	
	SetDataFolder oldDf
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************



Function IR3J_AppendDataToGraphModel()
	
	DoWindow IR3J_MultiSaPlotFitPanel
	if(!V_Flag)
		return 0
	endif
	variable WhichLegend=0
	variable startQp, endQp, tmpStQ

//	Duplicate/O OriginalDataIntWave, LinModelDataIntWave, ModelNormalizedResidual
//	Duplicate/O OriginalDataQWave, LinModelDataQWave, ModelNormResXWave
//	Duplicate/O OriginalDataErrorWave, LinModelDataEWave

	Wave LinModelDataIntWave=root:Packages:Irena:MultiSaPlotFit:LinModelDataIntWave
	Wave LinModelDataQWave=root:Packages:Irena:MultiSaPlotFit:LinModelDataQWave
	Wave LinModelDataEWave=root:Packages:Irena:MultiSaPlotFit:LinModelDataEWave
	CheckDisplayed /W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay LinModelDataIntWave
	if(!V_flag)
		AppendToGraph /W=IR3J_MultiSaPlotFitPanel#LinearizedDataDisplay  LinModelDataIntWave  vs LinModelDataQWave
		ModifyGraph /W=IR3J_MultiSaPlotFitPanel#LinearizedDataDisplay log=1, mirror(bottom)=1
		Label /W=IR3J_MultiSaPlotFitPanel#LinearizedDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity"
		Label /W=IR3J_MultiSaPlotFitPanel#LinearizedDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M]"
		ErrorBars /W=IR3J_MultiSaPlotFitPanel#LinearizedDataDisplay LinModelDataIntWave Y,wave=(LinModelDataEWave,LinModelDataEWave)		
	endif
//	NVAR DataQEnd = root:Packages:Irena:MultiSaPlotFit:DataQEnd
//	if(DataQEnd>0)	 		//old Q max already set.
//		endQp = BinarySearch(OriginalDataQWave, DataQEnd)
//	endif
//	if(endQp<1)	//Qmax not set or not found. Set to last point-1 on that wave. 
//		DataQEnd = OriginalDataQWave[numpnts(OriginalDataQWave)-2]
//		endQp = numpnts(OriginalDataQWave)-2
//	endif
//	cursor /W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay B, OriginalDataIntWave, endQp
	DoUpdate

	Wave/Z ModelNormalizedResidual=root:Packages:Irena:MultiSaPlotFit:ModelNormalizedResidual
	Wave/Z ModelNormResXWave=root:Packages:Irena:MultiSaPlotFit:ModelNormResXWave
	CheckDisplayed /W=IR3J_MultiSaPlotFitPanel#ResidualDataDisplay ModelNormalizedResidual  //, ResultIntensity
	if(!V_flag)
		AppendToGraph /W=IR3J_MultiSaPlotFitPanel#ResidualDataDisplay  ModelNormalizedResidual  vs ModelNormResXWave
		ModifyGraph /W=IR3J_MultiSaPlotFitPanel#LinearizedDataDisplay log=1, mirror(bottom)=1
		Label /W=IR3J_MultiSaPlotFitPanel#LinearizedDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Normalized res."
		Label /W=IR3J_MultiSaPlotFitPanel#LinearizedDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M]"
	endif



	string Shortname1, ShortName2
	
	switch(V_Flag)	// numeric switch
		case 0:		// execute if case matches expression
			Legend/W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay /N=text0/K
			break						// exit from switch
//		case 1:		// execute if case matches expression
//			SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
//			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
//			Legend/W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1
//			break
//		case 2:
//			SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
//			Shortname2 = StringFromList(ItemsInList(DataFolderName2, ":")-1, DataFolderName2  ,":")
//			Legend/W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData2IntWave) " + Shortname2		
//			break
//		case 3:
//			SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
//			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
//			Legend/W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2
//			break
//		case 7:
//			SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
//			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
//			Legend/W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2+"\r\\s(ResultIntensity) Merged Data"
			break
	endswitch

	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


Function IR3J_AppendDataToGraphLogLog()
	
	DoWindow IR3J_MultiSaPlotFitPanel
	if(!V_Flag)
		return 0
	endif
	variable WhichLegend=0
	variable startQp, endQp, tmpStQ
	Wave OriginalDataIntWave=root:Packages:Irena:MultiSaPlotFit:OriginalDataIntWave
	Wave OriginalDataQWave=root:Packages:Irena:MultiSaPlotFit:OriginalDataQWave
	Wave OriginalDataErrorWave=root:Packages:Irena:MultiSaPlotFit:OriginalDataErrorWave
	CheckDisplayed /W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay OriginalDataIntWave
	if(!V_flag)
		AppendToGraph /W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay  OriginalDataIntWave  vs OriginalDataQWave
		ModifyGraph /W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay log=1, mirror(bottom)=1
		Label /W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay left "Intensity 1"
		Label /W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay bottom "Q [A\\S-1\\M]"
		ErrorBars /W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay OriginalDataIntWave Y,wave=(OriginalDataErrorWave,OriginalDataErrorWave)		
	endif
	NVAR DataQEnd = root:Packages:Irena:MultiSaPlotFit:DataQEnd
	if(DataQEnd>0)	 		//old Q max already set.
		endQp = BinarySearch(OriginalDataQWave, DataQEnd)
	endif
	if(endQp<1)	//Qmax not set or not found. Set to last point-1 on that wave. 
		DataQEnd = OriginalDataQWave[numpnts(OriginalDataQWave)-2]
		endQp = numpnts(OriginalDataQWave)-2
	endif
	cursor /W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay B, OriginalDataIntWave, endQp
	DoUpdate

	Wave/Z OriginalDataIntWave=root:Packages:Irena:MultiSaPlotFit:OriginalDataIntWave
	CheckDisplayed /W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay OriginalDataIntWave  //, ResultIntensity
	string Shortname1, ShortName2
	
	switch(V_Flag)	// numeric switch
		case 0:		// execute if case matches expression
			Legend/W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay /N=text0/K
			break						// exit from switch
//		case 1:		// execute if case matches expression
//			SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
//			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
//			Legend/W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1
//			break
//		case 2:
//			SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
//			Shortname2 = StringFromList(ItemsInList(DataFolderName2, ":")-1, DataFolderName2  ,":")
//			Legend/W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData2IntWave) " + Shortname2		
//			break
//		case 3:
//			SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
//			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
//			Legend/W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2
//			break
//		case 7:
//			SVAR DataFolderName=root:Packages:Irena:MultiSaPlotFit:DataFolderName
//			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
//			Legend/W=IR3J_MultiSaPlotFitPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2+"\r\\s(ResultIntensity) Merged Data"
			break
	endswitch

	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
