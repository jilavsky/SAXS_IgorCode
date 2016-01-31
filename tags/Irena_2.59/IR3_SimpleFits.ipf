#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1
constant IR3LversionNumber = 1			//Data merging panel version number

//*************************************************************************\
//* Copyright (c) 2005 - 2015, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.0 Simple Fits tool first release version 



///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3L_SimpleFits()

	IN2G_CheckScreenSize("width",1200)
	IR3L_InitSimpleFits()
	DoWIndow IR3L_SimpleFitsPanel
	if(V_Flag)
		DoWindow/F IR3L_SimpleFitsPanel
		DoWindow/K IR3L_SimpleFitsPanel
		Execute("IR3L_SimpleFitsPanel()")
	else
		Execute("IR3L_SimpleFitsPanel()")
//		setWIndow IR3L_SimpleFitsPanel, hook(CursorMoved)=IR3D_PanelHookFunction
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
Proc IR3L_SimpleFitsPanel()
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,1195,800) as "Simple Fits"
	DoWIndow/C IR3L_SimpleFitsPanel
	TitleBox MainTitle title="Linerization fits panel",pos={280,2},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fSize=22,fColor=(0,0,52224)
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
	IR2C_AddDataControls("Irena:SimpleFits","IR3L_SimpleFitsPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)


	DrawText 60,25,"Data selection"
	Checkbox UseIndra2Data, pos={10,30},size={76,14},title="USAXS", proc=IR3L_LinearFitsCheckProc, variable=root:Packages:Irena:SimpleFits:UseIndra2Data
	checkbox UseQRSData, pos={120,30}, title="QRS(QIS)", size={76,14},proc=IR3L_LinearFitsCheckProc, variable=root:Packages:Irena:SimpleFits:UseQRSdata
	PopupMenu StartFolderSelection,pos={10,50},size={180,15},proc=IR3L_PopMenuProc,title="Start fldr"
	PopupMenu StartFolderSelection,mode=1,popvalue=root:Packages:Irena:SimpleFits:DataStartFolder,value= #"\"root:;\"+IR2S_GenStringOfFolders2(root:Packages:Irena:SimpleFits:UseIndra2Data, root:Packages:Irena:SimpleFits:UseQRSdata,2,1)"
	SetVariable FolderNameMatchString,pos={10,75},size={210,15}, proc=IR3L_SetVarProc,title="Folder Match (RegEx)"
	Setvariable FolderNameMatchString,fSize=10,fStyle=2, variable=root:Packages:Irena:SimpleFits:DataMatchString
	PopupMenu SortFolders,pos={10,100},size={180,20},fStyle=2,proc=IR3L_PopMenuProc,title="Sort Folders"
	PopupMenu SortFolders,mode=1,popvalue=root:Packages:Irena:SimpleFits:FolderSortString,value= root:Packages:Irena:SimpleFits:FolderSortStringAll

	ListBox DataFolderSelection,pos={4,135},size={250,480}, mode=10
	ListBox DataFolderSelection,listWave=root:Packages:Irena:SimpleFits:ListOfAvailableData
	ListBox DataFolderSelection,selWave=root:Packages:Irena:SimpleFits:SelectionOfAvailableData
	ListBox DataFolderSelection,proc=IR3L_LinFitsListBoxProc

	SetVariable DataQEnd,pos={280,90},size={200,15}, proc=IR3D_MergeDataSetVarProc,title="Fit Q max      ",bodyWidth=150
	Setvariable DataQEnd, variable=root:Packages:Irena:SimpleFits:DataQEnd, limits={-inf,inf,0}
	SetVariable DataQstart,pos={280,110},size={200,15}, proc=IR3D_MergeDataSetVarProc,title="Fit Q start      ",bodyWidth=150
	Setvariable DataQstart, variable=root:Packages:Irena:SimpleFits:DataQstart, limits={-inf,inf,0}
	SetVariable DataBackground,pos={280,130},size={200,15}, noproc,title="Background",bodyWidth=150
	Setvariable DataBackground, variable=root:Packages:Irena:SimpleFits:DataBackground, limits={-inf,inf,0}
//	ListOfVariables+="DataBackground;"
//	ListOfVariables+="Guinier_Rg;Guinier_I0;"
//	ListOfVariables+="ProcessManually;ProcessSequentially;OverwriteExistingData;AutosaveAfterProcessing;"
//	ListOfVariables+="DataQEnd;DataQstart;"

	PopupMenu SimpleModel,pos={280,175},size={180,20},fStyle=2,proc=IR3L_PopMenuProc,title="Model to fit : "
	PopupMenu SimpleModel,mode=1,popvalue=root:Packages:Irena:SimpleFits:ListOfSimpleModels,value= root:Packages:Irena:SimpleFits:SimpleModel

	SetVariable Guinier_Rg,pos={280,220},size={200,15}, proc=IR3D_MergeDataSetVarProc,title="Guinier  Rg    ",bodyWidth=150
	Setvariable Guinier_Rg, variable=root:Packages:Irena:SimpleFits:Guinier_Rg, limits={-inf,inf,0}

	SetVariable Guinier_I0,pos={280,200},size={200,15}, proc=IR3D_MergeDataSetVarProc,title="Guinier I0    ",bodyWidth=150
	Setvariable Guinier_I0, variable=root:Packages:Irena:SimpleFits:Guinier_I0, limits={-inf,inf,0}


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

	DrawText 4,650,"Double click to add data to graph."
	DrawText 4,663,"Shift-click to select range of data."
	DrawText 4,676,"Ctrl/Cmd-click to select one data set."
	DrawText 4,689,"Regex for not contain: ^((?!string).)*$"
	DrawText 4,702,"Regex for contain:  string"
	DrawText 4,715,"Regex for case independent contain:  (?i)string"
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3L_InitSimpleFits()	


	string oldDf=GetDataFolder(1)
	string ListOfVariables
	string ListOfStrings
	variable i
		
	if (!DataFolderExists("root:Packages:Irena:SimpleFits"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena
		NewDataFolder/O root:Packages:Irena:SimpleFits
	endif
	SetDataFolder root:Packages:Irena:SimpleFits					//go into the folder

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;DataUnits;"
	ListOfStrings+="DataStartFolder;DataMatchString;FolderSortString;FolderSortStringAll;"
	ListOfStrings+="UserMessageString;SavedDataMessage;"
	ListOfStrings+="SimpleModel;ListOfSimpleModels;"

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
//	ListOfStrings+="NewDataFolderName;NewIntensityWaveName;NewQWavename;NewErrorWaveName;"
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

Function IR3L_LinearFitsCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR UseIndra2Data =  root:Packages:Irena:SimpleFits:UseIndra2Data
			NVAR UseQRSData =  root:Packages:Irena:SimpleFits:UseQRSData
			SVAR DataStartFolder = root:Packages:Irena:SimpleFits:DataStartFolder
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
		  		endif
		  	endif
		  	if(stringmatch(cba.ctrlName,"UseQRSData"))
		  		if(checked)
		  			UseIndra2Data = 0
		  		endif
		  	endif
		  	if(stringmatch(cba.ctrlName,"UseQRSData")||stringmatch(cba.ctrlName,"UseIndra2Data"))
		  		DataStartFolder = "root:"
		  		PopupMenu StartFolderSelection,win=IR3L_SimpleFitsPanel, mode=1,popvalue="root:"
				IR3L_UpdateListOfAvailFiles()
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
Function IR3L_UpdateListOfAvailFiles()


	string OldDF=GetDataFolder(1)
	setDataFolder root:Packages:Irena:SimpleFits
	
	NVAR UseIndra2Data=root:Packages:Irena:SimpleFits:UseIndra2Data
	NVAR UseQRSdata=root:Packages:Irena:SimpleFits:UseQRSData
	SVAR StartFolderName=root:Packages:Irena:SimpleFits:DataStartFolder
	SVAR DataMatchString= root:Packages:Irena:SimpleFits:DataMatchString
	string LStartFolder, FolderContent
	if(stringmatch(StartFolderName,"---"))
		LStartFolder="root:"
	else
		LStartFolder = StartFolderName
	endif
	string CurrentFolders=IR3D_GenStringOfFolders(LStartFolder,UseIndra2Data, UseQRSData, 2,0,DataMatchString)

	Wave/T ListOfAvailableData=root:Packages:Irena:SimpleFits:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:Irena:SimpleFits:SelectionOfAvailableData
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
	IR3L_SortListOfAvailableFldrs()
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
Function IR3L_SortListOfAvailableFldrs()
	
	SVAR FolderSortString=root:Packages:Irena:SimpleFits:FolderSortString
	Wave/T ListOfAvailableData=root:Packages:Irena:SimpleFits:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:Irena:SimpleFits:SelectionOfAvailableData
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

Function IR3L_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if(stringmatch(ctrlName,"StartFolderSelection"))
		//Update the listbox using start folde popStr
		SVAR StartFolderName=root:Packages:Irena:SimpleFits:DataStartFolder
		StartFolderName = popStr
		IR3L_UpdateListOfAvailFiles()
	endif
	if(stringmatch(ctrlName,"SortFolders"))
		//do something here
		SVAR FolderSortString = root:Packages:Irena:SimpleFits:FolderSortString
		FolderSortString = popStr
		IR3L_UpdateListOfAvailFiles()
	endif
	if(stringmatch(ctrlName,"SimpleModel"))
		//do something here
		SVAR SimpleModel = root:Packages:Irena:SimpleFits:SimpleModel
		SimpleModel = popStr
		IR3L_CreateLinearizedData()
		IR3L_AppendDataToGraphModel()
	endif
	
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
			if(stringmatch(sva.ctrlName,"FolderNameMatchString1"))
				IR3D_UpdateListOfAvailFiles(1)
				IR3D_RebuildListboxTables()
//				IR2S_SortListOfAvailableFldrs()
			endif
			NVAR DataQstart=root:Packages:Irena:SimpleFits:DataQstart
			NVAR DataQEnd=root:Packages:Irena:SimpleFits:DataQEnd
			
			if(stringmatch(sva.ctrlName,"DataQEnd"))
				WAVE OriginalDataQWave = root:Packages:Irena:SimpleFits:OriginalDataQWave
				tempP = BinarySearch(OriginalDataQWave, DataQEnd )
				if(tempP<1)
					print "Wrong Q value set, Data Q max must be at most 1 point before the end of Data"
					tempP = numpnts(OriginalDataQWave)-2
					DataQEnd = OriginalDataQWave[tempP]
				endif
	//			cursor /W=IR3D_DataMergePanel#DataDisplay B, OriginalData1IntWave, tempP
			endif
			if(stringmatch(sva.ctrlName,"DataQstart"))
				WAVE OriginalDataQWave = root:Packages:Irena:SimpleFits:OriginalDataQWave
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

Function IR3L_LinFitsListBoxProc(lba) : ListBoxControl
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
			IR3L_CopyAndAppendData(FoldernameStr)
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
Function IR3L_CopyAndAppendData(FolderNameStr)
	string FolderNameStr
	
	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena:SimpleFits					//go into the folder
	//IR3D_SetSavedNotSavedMessage(0)

		SVAR DataStartFolder=root:Packages:Irena:SimpleFits:DataStartFolder
		SVAR DataFolderName=root:Packages:Irena:SimpleFits:DataFolderName
		SVAR IntensityWaveName=root:Packages:Irena:SimpleFits:IntensityWaveName
		SVAR QWavename=root:Packages:Irena:SimpleFits:QWavename
		SVAR ErrorWaveName=root:Packages:Irena:SimpleFits:ErrorWaveName
		SVAR dQWavename=root:Packages:Irena:SimpleFits:dQWavename
		NVAR UseIndra2Data=root:Packages:Irena:SimpleFits:UseIndra2Data
		NVAR UseQRSdata=root:Packages:Irena:SimpleFits:UseQRSdata
		//these are variables used by the control procedure
		NVAR  UseResults=  root:Packages:Irena:SimpleFits:UseResults
		NVAR  UseUserDefinedData=  root:Packages:Irena:SimpleFits:UseUserDefinedData
		NVAR  UseModelData = root:Packages:Irena:SimpleFits:UseModelData
		SVAR DataFolderName  = root:Packages:Irena:SimpleFits:DataFolderName 
		SVAR IntensityWaveName = root:Packages:Irena:SimpleFits:IntensityWaveName
		SVAR QWavename = root:Packages:Irena:SimpleFits:QWavename
		SVAR ErrorWaveName = root:Packages:Irena:SimpleFits:ErrorWaveName
		UseResults = 0
		UseUserDefinedData = 0
		UseModelData = 0
		//get the names of waves, assume this tool actually works. May not under some conditions. In that case this tool will not work. 
		DataFolderName = DataStartFolder+FolderNameStr
		QWavename = stringFromList(0,IR2P_ListOfWaves("Xaxis","", "IR3L_SimpleFitsPanel"))
		IntensityWaveName = stringFromList(0,IR2P_ListOfWaves("Yaxis","*", "IR3L_SimpleFitsPanel"))
		ErrorWaveName = stringFromList(0,IR2P_ListOfWaves("Error","*", "IR3L_SimpleFitsPanel"))
		if(UseIndra2Data)
			dQWavename = ReplaceString("Qvec", QWavename, "dQ")
		elseif(UseQRSdata)
			dQWavename = "w"+QWavename[1,31]
		else
			dQWavename = ""
		endif
		Wave/Z SourceIntWv=$(DataFolderName+IntensityWaveName)
		Wave/Z SourceQWv=$(DataFolderName+QWavename)
		Wave/Z SourceErrorWv=$(DataFolderName+ErrorWaveName)
		Wave/Z SourcedQWv=$(DataFolderName+dQWavename)
		if(!WaveExists(SourceIntWv)||	!WaveExists(SourceQWv)||!WaveExists(SourceErrorWv))
			Abort "Data selection failed for Data 1"
		endif
		Duplicate/O SourceIntWv, OriginalDataIntWave
		Duplicate/O SourceQWv, OriginalDataQWave
		Duplicate/O SourceErrorWv, OriginalDataErrorWave
		if(WaveExists(SourcedQWv))
			Duplicate/O SourcedQWv, OriginalDatadQWave
		else
			dQWavename=""
		endif
		IR3L_AppendDataToGraphLogLog()
		IR3L_CreateLinearizedData()
		IR3L_AppendDataToGraphModel()
//		IR3D_PresetOutputStrings()
//		Wave/Z ResultIntensity = root:Packages:Irena:SASDataMerging:ResultIntensity
//		if(WaveExists(ResultIntensity))
//			ResultIntensity= NaN
//		endif
		print "Added Data from folder : "+DataFolderName
	SetDataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3L_CreateLinearizedData()

	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena:SimpleFits					//go into the folder
	Wave OriginalDataIntWave=root:Packages:Irena:SimpleFits:OriginalDataIntWave
	Wave OriginalDataQWave=root:Packages:Irena:SimpleFits:OriginalDataQWave
	Wave OriginalDataErrorWave=root:Packages:Irena:SimpleFits:OriginalDataErrorWave
	SVAR SimpleModel=root:Packages:Irena:SimpleFits:SimpleModel
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



Function IR3L_AppendDataToGraphModel()
	
	DoWindow IR3L_SimpleFitsPanel
	if(!V_Flag)
		return 0
	endif
	variable WhichLegend=0
	variable startQp, endQp, tmpStQ

//	Duplicate/O OriginalDataIntWave, LinModelDataIntWave, ModelNormalizedResidual
//	Duplicate/O OriginalDataQWave, LinModelDataQWave, ModelNormResXWave
//	Duplicate/O OriginalDataErrorWave, LinModelDataEWave

	Wave LinModelDataIntWave=root:Packages:Irena:SimpleFits:LinModelDataIntWave
	Wave LinModelDataQWave=root:Packages:Irena:SimpleFits:LinModelDataQWave
	Wave LinModelDataEWave=root:Packages:Irena:SimpleFits:LinModelDataEWave
	CheckDisplayed /W=IR3L_SimpleFitsPanel#LogLogDataDisplay LinModelDataIntWave
	if(!V_flag)
		AppendToGraph /W=IR3L_SimpleFitsPanel#LinearizedDataDisplay  LinModelDataIntWave  vs LinModelDataQWave
		ModifyGraph /W=IR3L_SimpleFitsPanel#LinearizedDataDisplay log=1, mirror(bottom)=1
		Label /W=IR3L_SimpleFitsPanel#LinearizedDataDisplay left "Intensity"
		Label /W=IR3L_SimpleFitsPanel#LinearizedDataDisplay bottom "Q [A\\S-1\\M]"
		ErrorBars /W=IR3L_SimpleFitsPanel#LinearizedDataDisplay LinModelDataIntWave Y,wave=(LinModelDataEWave,LinModelDataEWave)		
	endif
//	NVAR DataQEnd = root:Packages:Irena:SimpleFits:DataQEnd
//	if(DataQEnd>0)	 		//old Q max already set.
//		endQp = BinarySearch(OriginalDataQWave, DataQEnd)
//	endif
//	if(endQp<1)	//Qmax not set or not found. Set to last point-1 on that wave. 
//		DataQEnd = OriginalDataQWave[numpnts(OriginalDataQWave)-2]
//		endQp = numpnts(OriginalDataQWave)-2
//	endif
//	cursor /W=IR3L_SimpleFitsPanel#LogLogDataDisplay B, OriginalDataIntWave, endQp
	DoUpdate

	Wave/Z ModelNormalizedResidual=root:Packages:Irena:SimpleFits:ModelNormalizedResidual
	Wave/Z ModelNormResXWave=root:Packages:Irena:SimpleFits:ModelNormResXWave
	CheckDisplayed /W=IR3L_SimpleFitsPanel#ResidualDataDisplay ModelNormalizedResidual  //, ResultIntensity
	if(!V_flag)
		AppendToGraph /W=IR3L_SimpleFitsPanel#ResidualDataDisplay  ModelNormalizedResidual  vs ModelNormResXWave
		ModifyGraph /W=IR3L_SimpleFitsPanel#LinearizedDataDisplay log=1, mirror(bottom)=1
		Label /W=IR3L_SimpleFitsPanel#LinearizedDataDisplay left "Normalized res."
		Label /W=IR3L_SimpleFitsPanel#LinearizedDataDisplay bottom "Q [A\\S-1\\M]"
	endif



	string Shortname1, ShortName2
	
	switch(V_Flag)	// numeric switch
		case 0:		// execute if case matches expression
			Legend/W=IR3L_SimpleFitsPanel#LogLogDataDisplay /N=text0/K
			break						// exit from switch
//		case 1:		// execute if case matches expression
//			SVAR DataFolderName=root:Packages:Irena:SimpleFits:DataFolderName
//			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
//			Legend/W=IR3L_SimpleFitsPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1
//			break
//		case 2:
//			SVAR DataFolderName=root:Packages:Irena:SimpleFits:DataFolderName
//			Shortname2 = StringFromList(ItemsInList(DataFolderName2, ":")-1, DataFolderName2  ,":")
//			Legend/W=IR3L_SimpleFitsPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData2IntWave) " + Shortname2		
//			break
//		case 3:
//			SVAR DataFolderName=root:Packages:Irena:SimpleFits:DataFolderName
//			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
//			Legend/W=IR3L_SimpleFitsPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2
//			break
//		case 7:
//			SVAR DataFolderName=root:Packages:Irena:SimpleFits:DataFolderName
//			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
//			Legend/W=IR3L_SimpleFitsPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2+"\r\\s(ResultIntensity) Merged Data"
			break
	endswitch

	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


Function IR3L_AppendDataToGraphLogLog()
	
	DoWindow IR3L_SimpleFitsPanel
	if(!V_Flag)
		return 0
	endif
	variable WhichLegend=0
	variable startQp, endQp, tmpStQ
	Wave OriginalDataIntWave=root:Packages:Irena:SimpleFits:OriginalDataIntWave
	Wave OriginalDataQWave=root:Packages:Irena:SimpleFits:OriginalDataQWave
	Wave OriginalDataErrorWave=root:Packages:Irena:SimpleFits:OriginalDataErrorWave
	CheckDisplayed /W=IR3L_SimpleFitsPanel#LogLogDataDisplay OriginalDataIntWave
	if(!V_flag)
		AppendToGraph /W=IR3L_SimpleFitsPanel#LogLogDataDisplay  OriginalDataIntWave  vs OriginalDataQWave
		ModifyGraph /W=IR3L_SimpleFitsPanel#LogLogDataDisplay log=1, mirror(bottom)=1
		Label /W=IR3L_SimpleFitsPanel#LogLogDataDisplay left "Intensity 1"
		Label /W=IR3L_SimpleFitsPanel#LogLogDataDisplay bottom "Q [A\\S-1\\M]"
		ErrorBars /W=IR3L_SimpleFitsPanel#LogLogDataDisplay OriginalDataIntWave Y,wave=(OriginalDataErrorWave,OriginalDataErrorWave)		
	endif
	NVAR DataQEnd = root:Packages:Irena:SimpleFits:DataQEnd
	if(DataQEnd>0)	 		//old Q max already set.
		endQp = BinarySearch(OriginalDataQWave, DataQEnd)
	endif
	if(endQp<1)	//Qmax not set or not found. Set to last point-1 on that wave. 
		DataQEnd = OriginalDataQWave[numpnts(OriginalDataQWave)-2]
		endQp = numpnts(OriginalDataQWave)-2
	endif
	cursor /W=IR3L_SimpleFitsPanel#LogLogDataDisplay B, OriginalDataIntWave, endQp
	DoUpdate

	Wave/Z OriginalDataIntWave=root:Packages:Irena:SimpleFits:OriginalDataIntWave
	CheckDisplayed /W=IR3L_SimpleFitsPanel#LogLogDataDisplay OriginalDataIntWave  //, ResultIntensity
	string Shortname1, ShortName2
	
	switch(V_Flag)	// numeric switch
		case 0:		// execute if case matches expression
			Legend/W=IR3L_SimpleFitsPanel#LogLogDataDisplay /N=text0/K
			break						// exit from switch
//		case 1:		// execute if case matches expression
//			SVAR DataFolderName=root:Packages:Irena:SimpleFits:DataFolderName
//			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
//			Legend/W=IR3L_SimpleFitsPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1
//			break
//		case 2:
//			SVAR DataFolderName=root:Packages:Irena:SimpleFits:DataFolderName
//			Shortname2 = StringFromList(ItemsInList(DataFolderName2, ":")-1, DataFolderName2  ,":")
//			Legend/W=IR3L_SimpleFitsPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData2IntWave) " + Shortname2		
//			break
//		case 3:
//			SVAR DataFolderName=root:Packages:Irena:SimpleFits:DataFolderName
//			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
//			Legend/W=IR3L_SimpleFitsPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2
//			break
//		case 7:
//			SVAR DataFolderName=root:Packages:Irena:SimpleFits:DataFolderName
//			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
//			Legend/W=IR3L_SimpleFitsPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2+"\r\\s(ResultIntensity) Merged Data"
			break
	endswitch

	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
