#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1
constant IR3DversionNumber = 1			//Data merging panel version number

//*************************************************************************\
//* Copyright (c) 2005 - 2015, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.0 Data Merging tool first release version 



///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3D_DataMerging()

	IN2G_CheckScreenSize("width",1200)
	IR3D_InitDataMerging()
	DoWIndow IR3D_DataMergePanel
	if(V_Flag)
		DoWindow/F IR3D_DataMergePanel
	else
		Execute("IR3D_DataMergePanel()")
		setWIndow IR3D_DataMergePanel, hook(CursorMoved)=IR3D_PanelHookFunction
	endif
	UpdatePanelVersionNumber("IR3D_DataMergePanel", IR3DversionNumber)
	IR3D_UpdateListOfAvailFiles(1)
	IR3D_UpdateListOfAvailFiles(2)
	IR3D_RebuildListboxTables()
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR3D_MainCheckVersion()	
	DoWindow IR3D_DataMergePanel
	if(V_Flag)
		if(!CheckPanelVersionNumber("IR3D_DataMergePanel", IR3DversionNumber))
			DoAlert /T="The Data Merging panel was created by old version of Irena " 1, "Data Merging may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				Execute/P("IR3D_DataMerging()")
			else		//at least reinitialize the variables so we avoid major crashes...
				IR3D_InitDataMerging()
			endif
		endif
	endif
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Proc IR3D_DataMergePanel()
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,1195,720) as "Data Merging"
	DoWIndow/C IR3D_DataMergePanel
	TitleBox MainTitle title="Data merging  panel",pos={480,2},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fSize=22,fColor=(0,0,52224)
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
	IR2C_AddDataControls("Irena:SASDataMerging","IR3D_DataMergePanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)


	DrawText 60,25,"First data set"
	Checkbox UseIndra2Data1, pos={10,30},size={76,14},title="USAXS", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:UseIndra2Data1
	checkbox UseQRSData1, pos={120,30}, title="QRS(QIS)", size={76,14},proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:UseQRSdata1
	PopupMenu StartFolderSelection1,pos={10,50},size={180,15},proc=IR3D_PopMenuProc,title="Start fldr"
	PopupMenu StartFolderSelection1,mode=1,popvalue=root:Packages:Irena:SASDataMerging:Data1StartFolder,value= #"\"root:;\"+IR2S_GenStringOfFolders2(root:Packages:Irena:SASDataMerging:UseIndra2Data1, root:Packages:Irena:SASDataMerging:UseQRSdata1,2,1)"
	SetVariable FolderNameMatchString1,pos={10,75},size={210,15}, proc=IR3D_MergeDataSetVarProc,title="Folder Match (RegEx)"
	Setvariable FolderNameMatchString1,fSize=10,fStyle=2, variable=root:Packages:Irena:SASDataMerging:Data1MatchString
	PopupMenu SortFolders1,pos={10,100},size={180,20},fStyle=2,proc=IR3D_MergingPopMenuProc,title="Sort Folders1"
	PopupMenu SortFolders1,mode=1,popvalue=root:Packages:Irena:SASDataMerging:FolderSortString1,value= root:Packages:Irena:SASDataMerging:FolderSortStringAll

	DrawText 290,25,"Second data set"
	Checkbox UseIndra2Data2, pos={260,30},size={76,14},title="USAXS", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:UseIndra2Data2
	checkbox UseQRSData2, pos={370,30}, title="QRS(QIS)", size={76,14},proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:UseQRSdata2
	PopupMenu StartFolderSelection2,pos={260,50},size={210,15},proc=IR3D_PopMenuProc,title="Start fldr"
	PopupMenu StartFolderSelection2,mode=1,popvalue=root:Packages:Irena:SASDataMerging:Data2StartFolder,value= #"\"root:;\"+IR2S_GenStringOfFolders2(root:Packages:Irena:SASDataMerging:UseIndra2Data2, root:Packages:Irena:SASDataMerging:UseQRSdata2,2,1)"
	SetVariable FolderNameMatchString2,pos={260,75},size={210,15}, proc=IR3D_MergeDataSetVarProc,title="Folder Match (RegEx)"
	Setvariable FolderNameMatchString2,fSize=10,fStyle=2, variable=root:Packages:Irena:SASDataMerging:Data2MatchString
	PopupMenu SortFolders2,pos={260,100},size={180,20},fStyle=2,proc=IR3D_MergingPopMenuProc,title="Sort Folders2"
	PopupMenu SortFolders2,mode=1,popvalue=root:Packages:Irena:SASDataMerging:FolderSortString2,value=root:Packages:Irena:SASDataMerging:FolderSortStringAll

	Button IsUSAXSSAXSdata, pos={140,119}, size={200,14}, title="Sort USAXS/SAXS/WAXS data", proc=IR3D_MergeButtonProc, help={"Sorts USAXS/SAXS?WAXS data to order proper pairs together. "}

	SetVariable Data1Background,pos={990,30},size={200,15}, noproc,title="Data 1 Background",bodyWidth=150, disable=2
	Setvariable Data1Background, variable=root:Packages:Irena:SASDataMerging:Data1Background, limits={-inf,inf,0}
	SetVariable Data2IntMultiplier,pos={990,50},size={200,15}, noproc,title="Data 2 Scaling      ",bodyWidth=150, disable=2
	Setvariable Data2IntMultiplier, variable=root:Packages:Irena:SASDataMerging:Data2IntMultiplier, limits={-inf,inf,0}
	SetVariable Data2Qshift,pos={990,70},size={200,15}, noproc,title="Data 2 Q shift      ",bodyWidth=150, disable=2
	Setvariable Data2Qshift, variable=root:Packages:Irena:SASDataMerging:Data2Qshift, limits={-inf,inf,0}
	SetVariable Data1QEnd,pos={990,90},size={200,15}, proc=IR3D_MergeDataSetVarProc,title="Data 1 Q max      ",bodyWidth=150
	Setvariable Data1QEnd, variable=root:Packages:Irena:SASDataMerging:Data1QEnd, limits={-inf,inf,0}
	SetVariable Data2Qstart,pos={990,110},size={200,15}, proc=IR3D_MergeDataSetVarProc,title="Data 2 Q start      ",bodyWidth=150
	Setvariable Data2Qstart, variable=root:Packages:Irena:SASDataMerging:Data2Qstart, limits={-inf,inf,0}

	ListBox DataFolderSelection,pos={4,135},size={480,500}, mode=10
	ListBox DataFolderSelection,listWave=root:Packages:Irena:SASDataMerging:ListOfAvailableData
	ListBox DataFolderSelection,selWave=root:Packages:Irena:SASDataMerging:SelectionOfAvailableData
	ListBox DataFolderSelection,proc=IR3D_DataMergeListBoxProc
	Button ProcessSaveData, pos={490,135}, size={20,500}, title="S\rA\rV\rE\r\rD\rA\rT\rA", proc=IR3D_MergeButtonProc, help={"Saves data which were automtaticaly processed already. "}, labelBack=(65535,60076,49151)
	//TextBox/C/N=text1/O=90/A=MC "Save Data", TextBox/C/N=text1/A=MC "S\rA\rV\rE\r\rD\rA\rT\rA"

	Checkbox ProcessTest, pos={520,30},size={76,14},title="Test mode", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessTest
	Checkbox ProcessMerge, pos={520,50},size={76,14},title="Merge mode", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessMerge
	Checkbox ProcessMerge2, pos={520,70},size={76,14},title="Merge 2 mode", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessMerge2

	Checkbox ProcessManually, pos={650,30},size={76,14},title="Process individually", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessManually
	Checkbox ProcessSequentially, pos={650,50},size={76,14},title="Process as sequence", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessSequentially

	Checkbox AutosaveAfterProcessing, pos={780,30},size={76,14},title="Save Immediately", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:AutosaveAfterProcessing, disable=!root:Packages:Irena:SASDataMerging:ProcessManually
	Checkbox OverwriteExistingData, pos={780,50},size={76,14},title="Overwrite existing data", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:OverwriteExistingData
	TitleBox SavedDataMessage title="",fixedSize=1,size={100,17}, pos={780,70}, variable= root:Packages:Irena:SASDataMerging:SavedDataMessage
	TitleBox SavedDataMessage help={"Are the data saved?"}, fColor=(65535,16385,16385), frame=0, fSize=12,fstyle=1

	TitleBox UserMessage title="",fixedSize=1,size={470,20}, pos={480,90}, variable= root:Packages:Irena:SASDataMerging:UserMessageString
	TitleBox UserMessage help={"This is what will happen"}

		
	Button AutoScale,pos={520,117},size={100,17}, proc=IR3D_MergeButtonProc,title="Test AutoScale", help={"Autoscales. Set cursors on data overlap and the data 2 will be scaled to Data 1 using integral intensity"}, disable=!root:Packages:Irena:SASDataMerging:ProcessTest
	Button MergeData,pos={640,117},size={100,17}, proc=IR3D_MergeButtonProc,title="Test Merge", help={"Scales data 2 to data 1 and sets background for data 1 for merging. Sets checkboxes and trims. Saves data also"}, disable=!root:Packages:Irena:SASDataMerging:ProcessTest
	Button MergeData2,pos={760,117},size={100,17}, proc=IR3D_MergeButtonProc,title="Test Merge 2", help={"Scales data 2 to data 1, optimizes Q shift for data 2 and sets background for data 1 for merging. Saves data also"}, disable=!root:Packages:Irena:SASDataMerging:ProcessTest

	Display /W=(521,135,1183,620) /HOST=# /N=DataDisplay

	SetActiveSubwindow ##

	SetVariable DataFolderName1,pos={550,625},size={510,15}, noproc,variable=root:Packages:Irena:SASDataMerging:DataFolderName1, title="Data 1:       ", disable=2
	SetVariable DataFolderName2,pos={550,642},size={510,15}, noproc,variable=root:Packages:Irena:SASDataMerging:DataFolderName2, title="Data 2:       ", disable=2
	SetVariable NewDataFolderName,pos={550,659},size={510,15}, noproc,variable=root:Packages:Irena:SASDataMerging:NewDataFolderName, title="Merged Data: "

	DrawText 4,650,"Double click to add data to graph."
	DrawText 4,663,"Shift-click to select range of data."
	DrawText 4,676,"Ctrl/Cmd-click to select one data set."
	DrawText 254,650,"Regex for not contain: ^((?!string).)*$"
	DrawText 254,663,"Regex for contain:  string"
	DrawText 254,676,"Regex for case independent contain:  (?i)string"
end


//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3D_InitDataMerging()	


	string oldDf=GetDataFolder(1)
	string ListOfVariables
	string ListOfStrings
	variable i
	//First the ones needed in SASDataModification for compatibility
		
	if (!DataFolderExists("root:Packages:Irena:SASDataMerging"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena
		NewDataFolder/O root:Packages:Irena:SASDataMerging
	endif
	SetDataFolder root:Packages:Irena:SASDataMerging					//go into the folder

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName1;IntensityWaveName1;QWavename1;ErrorWaveName1;dQWavename1;DataUnits1;"
	ListOfStrings+="DataFolderName2;IntensityWaveName2;QWavename2;ErrorWaveName2;dQWavename2;DataUnits2;"
	ListOfStrings+="NewDataFolderName;NewIntensityWaveName;NewQWavename;NewErrorWaveName;NewdQWavename;OutputDataUnits;"
	ListOfStrings+="Data1StartFolder;Data1MatchString;Data2StartFolder;Data2MatchString;FolderSortString1;FolderSortString2;FolderSortStringAll;"
	ListOfStrings+="UserMessageString;SavedDataMessage;"

	ListOfVariables="UseIndra2Data1;UseQRSdata1;"
	ListOfVariables+="UseIndra2Data2;UseQRSdata2;"
	ListOfVariables+="Data1Background;Data2IntMultiplier;Data2Qshift;"
	ListOfVariables+="IsUSAXSSAXSdata;ProcessMerge;ProcessMerge2;ProcessTest;"
	ListOfVariables+="ProcessManually;ProcessSequentially;OverwriteExistingData;AutosaveAfterProcessing;"
	ListOfVariables+="Data1QEnd;Data2Qstart;"

	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	ListOfStrings="DataFolderName1;IntensityWaveName1;QWavename1;ErrorWaveName1;dQWavename1;"
	ListOfStrings+="DataFolderName2;IntensityWaveName2;QWavename2;ErrorWaveName2;dQWavename2;"
	ListOfStrings+="NewDataFolderName;NewIntensityWaveName;NewQWavename;NewErrorWaveName;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR teststr=$(StringFromList(i,ListOfStrings))
		teststr =""
	endfor		
	ListOfStrings="Data1MatchString;Data2MatchString;FolderSortString1;FolderSortString2;FolderSortStringAll;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR teststr=$(StringFromList(i,ListOfStrings))
		if(strlen(teststr)<1)
			teststr =""
		endif
	endfor		
	ListOfStrings="Data1StartFolder;Data2StartFolder;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR teststr=$(StringFromList(i,ListOfStrings))
		if(strlen(teststr)<1)
			teststr ="root:"
		endif
	endfor		
	SVAR FolderSortStringAll
	FolderSortStringAll = "Alphabetical;Reverse Alphabetical;_xyz;_xyz.ext;Reverse _xyz;Reverse _xyz.ext;Sxyz_;Reverse Sxyz_;_xyzmin;_xyzC;_xyzpct;_xyz_000;Reverse _xyz_000;"
	
	NVAR ProcessMerge
	NVAR ProcessMerge2
	NVAR ProcessTest
	SVAR UserMessageString
	if(ProcessMerge+ProcessMerge2+ProcessTest!=1)
		ProcessMerge = 0
		ProcessMerge2 = 0
		ProcessTest = 1
		UserMessageString = "In test mode - no saving - select Q range and method."
	endif
	NVAR OverwriteExistingData
	NVAR AutosaveAfterProcessing
	OverwriteExistingData=1
	AutosaveAfterProcessing=1
	if(ProcessTest)
		AutosaveAfterProcessing=0
	endif

	Make/O/T/N=(0,2) ListOfAvailableData
	Make/O/N=(0,2) SelectionOfAvailableData
	Make/O/T/N=(0) ListOfAvailableData1, ListOfAvailableData2
	Make/O/N=(0) SelectionOfAvailableData1, SelectionOfAvailableData2

	SetDataFolder oldDf

end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3D_RebuildListboxTables()

	Wave/T ListOfAvailableData= root:Packages:Irena:SASDataMerging:ListOfAvailableData
	Wave/T ListOfAvailableData1= root:Packages:Irena:SASDataMerging:ListOfAvailableData1
	Wave/T ListOfAvailableData2= root:Packages:Irena:SASDataMerging:ListOfAvailableData2
	Wave SelectionOfAvailableData= root:Packages:Irena:SASDataMerging:SelectionOfAvailableData
	//now we need to merge the data together right... 
	variable Length1, Length2
	Length1 = numpnts(ListOfAvailableData1)
	Length2 = numpnts(ListOfAvailableData2)
	variable length=max(Length1, Length2 )
	redimension/N=(length) ListOfAvailableData1, ListOfAvailableData2
	if(Length1<length)
		ListOfAvailableData1[Length1,] = ""
	endif
	if(Length2<length)
		ListOfAvailableData2[Length2,] = ""
	endif
	redimension/N=(length,2) ListOfAvailableData, SelectionOfAvailableData
	SelectionOfAvailableData = 0
	ListOfAvailableData = ""
	ListOfAvailableData[][0] = ListOfAvailableData1[p]
	ListOfAvailableData[][1] = ListOfAvailableData2[p]
end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function IR3D_UpdateListOfAvailFiles(WhichOne)
	variable WhichOne

	string OldDF=GetDataFolder(1)
	setDataFolder root:Packages:Irena:SASDataMerging
	
	NVAR UseIndra2Data=$("root:Packages:Irena:SASDataMerging:UseIndra2Data"+num2str(WhichOne))
	NVAR UseQRSdata=$("root:Packages:Irena:SASDataMerging:UseQRSData"+num2str(WhichOne))
	SVAR StartFolderName=$("root:Packages:Irena:SASDataMerging:Data"+num2str(WhichOne)+"StartFolder")
	SVAR DataMatchString= $("root:Packages:Irena:SASDataMerging:Data"+num2str(WhichOne)+"MatchString")
	string LStartFolder, FolderContent
	if(stringmatch(StartFolderName,"---"))
		LStartFolder="root:"
	else
		LStartFolder = StartFolderName
	endif
	string CurrentFolders=IR3D_GenStringOfFolders(LStartFolder,UseIndra2Data, UseQRSData, 2,0,DataMatchString)

	Wave/T ListOfAvailableData=$("root:Packages:Irena:SASDataMerging:ListOfAvailableData"+num2str(WhichOne))
	Wave SelectionOfAvailableData=$("root:Packages:Irena:SASDataMerging:SelectionOfAvailableData"+num2str(WhichOne))
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
	IR3D_SortListOfAvailableFldrs(WhichOne)
	setDataFolder OldDF
end


//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function/T IR3D_GenStringOfFolders(StartFolder,UseIndra2Structure, UseQRSStructure, SlitSmearedData, AllowQRDataOnly, FolderNameMatchString)
	string StartFolder
	variable UseIndra2Structure, UseQRSStructure, SlitSmearedData, AllowQRDataOnly
	string FolderNameMatchString
		//SlitSmearedData =0 for DSM data, 
		//                          =1 for SMR data 
		//                    and =2 for both
		// AllowQRDataOnly=1 if Q and R data are allowed only (no error wave). For QRS data ONLY!
	
	string ListOfQFolders
	string TempStr, tempStr2
	variable i
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
			make/N=0/FREE/T ResultingWave
			IR2P_FindFolderWithWaveTypesWV(StartFolder, 10, "(?i)^r|i$", 1, ResultingWave)
			result=IR2S_CheckForRightQRSTripletWvs(ResultingWave,AllowQRDataOnly)
	else
		result=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*", 1)
	endif
	//leave ONLY folders matching FolderNameMatchStringstring is set
	if(strlen(FolderNameMatchString)>0)
		result = GrepList(result, FolderNameMatchString) 
	endif
	if(stringmatch(";",result[0]))
		result = result [1, inf]
	endif
	return result
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3D_DataMergeCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR UseIndra2Data1 =  root:Packages:Irena:SASDataMerging:UseIndra2Data1
			NVAR UseQRSData1 =  root:Packages:Irena:SASDataMerging:UseQRSData1
			SVAR Data1StartFolder = root:Packages:Irena:SASDataMerging:Data1StartFolder
			NVAR UseIndra2Data2 =  root:Packages:Irena:SASDataMerging:UseIndra2Data2
			NVAR UseQRSData2 =  root:Packages:Irena:SASDataMerging:UseQRSData2
			SVAR Data2StartFolder = root:Packages:Irena:SASDataMerging:Data2StartFolder
		  	NVAR ProcessTest = root:Packages:Irena:SASDataMerging:ProcessTest
		  	NVAR ProcessMerge=root:Packages:Irena:SASDataMerging:ProcessMerge
		  	NVAR ProcessMerge2=root:Packages:Irena:SASDataMerging:ProcessMerge2
		  	SVAR UserMessageString=root:Packages:Irena:SASDataMerging:UserMessageString
			NVAR ProcessManually =root:Packages:Irena:SASDataMerging:ProcessManually
			NVAR ProcessSequentially=root:Packages:Irena:SASDataMerging:ProcessSequentially
			NVAR OverwriteExistingData=root:Packages:Irena:SASDataMerging:OverwriteExistingData
			NVAR AutosaveAfterProcessing=root:Packages:Irena:SASDataMerging:AutosaveAfterProcessing
			Checkbox AutosaveAfterProcessing, win=IR3D_DataMergePanel, disable=0
			Checkbox ProcessSequentially, win=IR3D_DataMergePanel, disable=0
		  	if(stringmatch(cba.ctrlName,"UseIndra2Data1"))
		  		if(checked)
		  			UseQRSData1 = 0
		  		endif
		  	endif
		  	if(stringmatch(cba.ctrlName,"UseQRSData1"))
		  		if(checked)
		  			UseIndra2Data1 = 0
		  		endif
		  	endif
		  	if(stringmatch(cba.ctrlName,"UseQRSData1")||stringmatch(cba.ctrlName,"UseIndra2Data1"))
		  		Data1StartFolder = "root:"
		  		PopupMenu StartFolderSelection1,win=IR3D_DataMergePanel, mode=1,popvalue="root:"
				IR3D_UpdateListOfAvailFiles(1)
		  		IR3D_RebuildListboxTables()
		  	endif
		  	if(stringmatch(cba.ctrlName,"UseIndra2Data2"))
		  		if(checked)
		  			UseQRSData2 = 0
		  		endif
		  	endif
		  	if(stringmatch(cba.ctrlName,"UseQRSData2"))
		  		if(checked)
		  			UseIndra2Data2 = 0
		  		endif
		  	endif
		  	if(stringmatch(cba.ctrlName,"UseQRSData2")||stringmatch(cba.ctrlName,"UseIndra2Data2"))
		  		Data2StartFolder = "root:"
		  		PopupMenu StartFolderSelection2,win=IR3D_DataMergePanel, mode=1,popvalue="root:"
				IR3D_UpdateListOfAvailFiles(2)
		  		IR3D_RebuildListboxTables()
		  	endif
			Checkbox AutosaveAfterProcessing, win=IR3D_DataMergePanel, disable=0
			UserMessageString = ""
		  	if(stringmatch(cba.ctrlName,"ProcessManually"))
	  			if(checked)
	  				ProcessSequentially = 0
	  			endif
	  		endif
		  	if(stringmatch(cba.ctrlName,"ProcessSequentially"))
	  			if(checked)
	  				ProcessManually = 0
	  				ProcessTest = 0
	  				AutosaveAfterProcessing = 1
	  				if(ProcessTest+ProcessMerge+ProcessMerge2!=1)
	  					ProcessMerge2=1
	  					ProcessMerge =0
	  				endif
					//Checkbox AutosaveAfterProcessing, win=IR3D_DataMergePanel, disable=1
	  			endif
	  		endif
		  	if(stringmatch(cba.ctrlName,"ProcessTest"))
	  			if(checked)
	  				ProcessMerge = 0
	  				ProcessMerge2 = 0
	  				AutosaveAfterProcessing = 0
	  				ProcessManually = 1
	  				ProcessSequentially = 0
	  			endif
	  		endif
		  	if(stringmatch(cba.ctrlName,"ProcessMerge"))
	  			if(checked)
	  				ProcessTest = 0
	  				ProcessMerge2 = 0
					UserMessageString += "Using Merge. "
	  			endif
	  		endif
		  	if(stringmatch(cba.ctrlName,"ProcessMerge2"))
	  			if(checked)
	  				ProcessMerge = 0
	  				ProcessTest = 0
					UserMessageString += "Using Merge2. "
	  			endif
	  		endif
	//	  	if(stringmatch(cba.ctrlName,"ProcessMerge2")||stringmatch(cba.ctrlName,"ProcessMerge")||stringmatch(cba.ctrlName,"ProcessTest"))
//			endif
			IR3D_SetGUIControls()
	  		
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**************************************************************************************
//**************************************************************************************

Function IR3D_SetGUIControls()
			NVAR ProcessTest=root:Packages:Irena:SASDataMerging:ProcessTest
			SVAR UserMessageString=root:Packages:Irena:SASDataMerging:UserMessageString
			NVAR ProcessMerge=root:Packages:Irena:SASDataMerging:ProcessMerge
			NVAR ProcessSequentially=root:Packages:Irena:SASDataMerging:ProcessSequentially
			NVAR ProcessManually=root:Packages:Irena:SASDataMerging:ProcessManually
			NVAR AutosaveAfterProcessing = root:Packages:Irena:SASDataMerging:AutosaveAfterProcessing
			NVAR OverwriteExistingData=root:Packages:Irena:SASDataMerging:OverwriteExistingData
			

			Checkbox AutosaveAfterProcessing, win=IR3D_DataMergePanel, disable=ProcessTest
			Checkbox ProcessSequentially, win=IR3D_DataMergePanel, disable=ProcessTest
			Button AutoScale,win=IR3D_DataMergePanel, disable=!ProcessTest
			Button MergeData,win=IR3D_DataMergePanel, disable=!ProcessTest
			Button MergeData2,win=IR3D_DataMergePanel, disable=!ProcessTest

			if(ProcessTest)
				//Button ProcessSaveData,win=IR3D_DataMergePanel, disable=1
				UserMessageString = "In test mode - manual save - select Q range and method."
				Button ProcessSaveData,win=IR3D_DataMergePanel, title="S\rA\rV\rE\r\r\rD\rA\rT\rA", disable=0
			else
				if(ProcessManually)
					Button ProcessSaveData,win=IR3D_DataMergePanel, title="S\rA\rV\rE\r\r\rD\rA\rT\rA", disable=0
					if(ProcessMerge)
						if(AutosaveAfterProcessing)
							UserMessageString = "Select Data1& Data2, processing using Merge, will be saved immediately."
						else
							UserMessageString = "Select Data1& Data2, processing using Merge. User needs to SAVE."
						endif
					else
						if(AutosaveAfterProcessing)
							UserMessageString = "Select Data1& Data2, processing using Merge2, will be saved immediately. "
						else
							UserMessageString = "Select Data1& Data2, processing using Merge2. User needs to SAVE."
						endif
					endif
				elseif(ProcessSequentially)
					Button ProcessSaveData,win=IR3D_DataMergePanel, title="P\rR\rO\rC\rE\rS\rS\r\r\ra\rn\rd\r\r\rS\rA\rV\rE\r\r\rD\rA\rT\rA", disable=0
					if(ProcessMerge)
						UserMessageString = "Select ranges of Data1 & 2 and push PROCESS Data button. Using Merge & save."
					else
						UserMessageString = "Select ranges of Data1 & 2 and push PROCESS Data button. Using Merge2 & save."
					endif
				endif			
			endif
			if(OverwriteExistingData)
				UserMessageString+=" Overwrite existing data."
			else
				UserMessageString+=" Will create unique folder."
			endif

end
//**************************************************************************************
//**************************************************************************************

Function IR3D_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if(stringmatch(ctrlName,"StartFolderSelection1"))
		//Update the listbox using start folde popStr
		SVAR StartFolderName=root:Packages:Irena:SASDataMerging:Data1StartFolder
		StartFolderName = popStr
		IR3D_UpdateListOfAvailFiles(1)
		IR3D_RebuildListboxTables()
//		IR2S_SortListOfAvailableFldrs()
	endif
	if(stringmatch(ctrlName,"StartFolderSelection2"))
		//Update the listbox using start folde popStr
		SVAR StartFolderName=root:Packages:Irena:SASDataMerging:Data2StartFolder
		StartFolderName = popStr
		IR3D_UpdateListOfAvailFiles(2)
		IR3D_RebuildListboxTables()
//		IR2S_SortListOfAvailableFldrs()
	endif

end

//**************************************************************************************
//**************************************************************************************

Function IR3D_MergeDataSetVarProc(sva) : SetVariableControl
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
			if(stringmatch(sva.ctrlName,"FolderNameMatchString2"))
				IR3D_UpdateListOfAvailFiles(2)
				IR3D_RebuildListboxTables()
//				IR2S_SortListOfAvailableFldrs()
			endif
			NVAR Data2Qstart=root:Packages:Irena:SASDataMerging:Data2Qstart
			NVAR Data1QEnd=root:Packages:Irena:SASDataMerging:Data1QEnd
			
			if(stringmatch(sva.ctrlName,"Data1QEnd"))
				NVAR Data1QEnd = root:Packages:Irena:SASDataMerging:Data1QEnd
				WAVE OriginalData1QWave = root:Packages:Irena:SASDataMerging:OriginalData1QWave
				tempP = BinarySearch(OriginalData1QWave, Data1QEnd )
				if(tempP<1)
					print "Wrong Q value set, Data 1 Q max must be at most 1 point before the end of Data 1"
					tempP = numpnts(OriginalData1QWave)-2
					Data1QEnd = OriginalData1QWave[tempP]
				endif
				cursor /W=IR3D_DataMergePanel#DataDisplay B, OriginalData1IntWave, tempP
			endif
			if(stringmatch(sva.ctrlName,"Data2Qstart"))
				NVAR Data2Qstart = root:Packages:Irena:SASDataMerging:Data2Qstart
				WAVE OriginalData2QWave = root:Packages:Irena:SASDataMerging:OriginalData2QWave
				tempP = BinarySearch(OriginalData2QWave, Data2Qstart )
				if(tempP<1)
					print "Wrong Q value set, Data 2 Q min must be at least 1 point from the start of Data 2"
					tempP = 1
					Data2Qstart = OriginalData2QWave[tempP]
				endif
				cursor /W=IR3D_DataMergePanel#DataDisplay A, OriginalData2IntWave, tempP
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

Function IR3D_DataMergeListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable row = lba.row
	Variable col = lba.col
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
			NVAR ProcessTest=root:Packages:Irena:SASDataMerging:ProcessTest
			NVAR ProcessManually=root:Packages:Irena:SASDataMerging:ProcessManually
			NVAR AutosaveAfterProcessing = root:Packages:Irena:SASDataMerging:AutosaveAfterProcessing
			if(col==0)
				isData1or2=1
			else
				isData1or2=2
			endif
			FoldernameStr=listWave[row][col]
			IR3D_CopyAndAppendData(isData1or2, FoldernameStr)
			if(col==1&&!ProcessTest)		//this is second column of data
				IR3D_MergeProcessData()
			endif
			if(col==1&&AutosaveAfterProcessing&&ProcessManually)
				IR3D_SaveData()
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
//Function IR3D_CopyAndAppendData(lba)
//	STRUCT WMListboxAction &lba
//	Variable row = lba.row
//	Variable col = lba.col
//	WAVE/T/Z listWave = lba.listWave
//	WAVE/Z selWave = lba.selWave
//

Function IR3D_CopyAndAppendData(Data1or2,FolderNameStr)
	variable Data1or2			//set to 1 for Data1, 2 for Data2
	string FolderNameStr
	
	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena:SASDataMerging					//go into the folder
	IR3D_SetSavedNotSavedMessage(0)

	if(Data1or2==1)		//these are data 1
		SVAR Data1StartFolder=root:Packages:Irena:SASDataMerging:Data1StartFolder
		SVAR DataFolderName1=root:Packages:Irena:SASDataMerging:DataFolderName1
		SVAR IntensityWaveName1=root:Packages:Irena:SASDataMerging:IntensityWaveName1
		SVAR QWavename1=root:Packages:Irena:SASDataMerging:QWavename1
		SVAR ErrorWaveName1=root:Packages:Irena:SASDataMerging:ErrorWaveName1
		SVAR dQWavename1=root:Packages:Irena:SASDataMerging:dQWavename1
		NVAR UseIndra2Data1=root:Packages:Irena:SASDataMerging:UseIndra2Data1
		NVAR UseQRSdata1=root:Packages:Irena:SASDataMerging:UseQRSdata1
		//these are variables used by the control procedure
		NVAR UseIndra2Data = root:Packages:Irena:SASDataMerging:UseIndra2Data
		NVAR  UseQRSdata =  root:Packages:Irena:SASDataMerging:UseQRSdata
		NVAR  UseResults=  root:Packages:Irena:SASDataMerging:UseResults
		NVAR  UseUserDefinedData=  root:Packages:Irena:SASDataMerging:UseUserDefinedData
		NVAR  UseModelData = root:Packages:Irena:SASDataMerging:UseModelData
		SVAR DataFolderName  = root:Packages:Irena:SASDataMerging:DataFolderName 
		SVAR IntensityWaveName = root:Packages:Irena:SASDataMerging:IntensityWaveName
		SVAR QWavename = root:Packages:Irena:SASDataMerging:QWavename
		SVAR ErrorWaveName = root:Packages:Irena:SASDataMerging:ErrorWaveName
		UseIndra2Data = UseIndra2Data1
		UseQRSdata = UseQRSdata1
		UseResults = 0
		UseUserDefinedData = 0
		UseModelData = 0
		//get the names of waves, assume this tool actually works. May not under some conditions. In that case this tool will not work. 
		DataFolderName1 = Data1StartFolder+FolderNameStr
		DataFolderName = DataFolderName1
		QWavename1 = stringFromList(0,IR2P_ListOfWaves("Xaxis","", "IR3D_DataMergePanel"))
		IntensityWaveName1 = stringFromList(0,IR2P_ListOfWaves("Yaxis","*", "IR3D_DataMergePanel"))
		ErrorWaveName1 = stringFromList(0,IR2P_ListOfWaves("Error","*", "IR3D_DataMergePanel"))
		if(UseIndra2Data1)
			dQWavename1 = ReplaceString("Qvec", QWavename1, "dQ")
		elseif(UseQRSdata1)
			dQWavename1 = "w"+QWavename1[1,31]
		else
			dQWavename1 = ""
		endif
		Wave/Z SourceIntWv=$(DataFolderName1+IntensityWaveName1)
		Wave/Z SourceQWv=$(DataFolderName1+QWavename1)
		Wave/Z SourceErrorWv=$(DataFolderName1+ErrorWaveName1)
		Wave/Z SourcedQWv=$(DataFolderName1+dQWavename1)
		if(!WaveExists(SourceIntWv)||	!WaveExists(SourceQWv)||!WaveExists(SourceErrorWv))
			Abort "Data selection failed for Data 1"
		endif
		Duplicate/O SourceIntWv, OriginalData1IntWave
		Duplicate/O SourceQWv, OriginalData1QWave
		Duplicate/O SourceErrorWv, OriginalData1ErrorWave
		if(WaveExists(SourcedQWv))
			Duplicate/O SourcedQWv, OriginalData1dQWave
		else
			dQWavename1=""
		endif
		IR3D_AppendDataToGraph("Data1")
		IR3D_PresetOutputStrings()
		Wave/Z ResultIntensity = root:Packages:Irena:SASDataMerging:ResultIntensity
		if(WaveExists(ResultIntensity))
			ResultIntensity= NaN
		endif
		print "Added Data 1 from folder : "+DataFolderName1
	endif
	if(Data1or2==2)		//these are data 2
		SVAR Data2StartFolder=root:Packages:Irena:SASDataMerging:Data2StartFolder
		SVAR DataFolderName2=root:Packages:Irena:SASDataMerging:DataFolderName2
		SVAR IntensityWaveName2=root:Packages:Irena:SASDataMerging:IntensityWaveName2
		SVAR QWavename2=root:Packages:Irena:SASDataMerging:QWavename2
		SVAR ErrorWaveName2=root:Packages:Irena:SASDataMerging:ErrorWaveName2
		SVAR dQWavename2=root:Packages:Irena:SASDataMerging:dQWavename2
		NVAR UseIndra2Data2=root:Packages:Irena:SASDataMerging:UseIndra2Data2
		NVAR UseQRSdata2=root:Packages:Irena:SASDataMerging:UseQRSdata2
		//these are variables used by the control procedure
		NVAR UseIndra2Data = root:Packages:Irena:SASDataMerging:UseIndra2Data
		NVAR  UseQRSdata =  root:Packages:Irena:SASDataMerging:UseQRSdata
		NVAR  UseResults=  root:Packages:Irena:SASDataMerging:UseResults
		NVAR  UseUserDefinedData=  root:Packages:Irena:SASDataMerging:UseUserDefinedData
		NVAR  UseModelData = root:Packages:Irena:SASDataMerging:UseModelData
		SVAR DataFolderName  = root:Packages:Irena:SASDataMerging:DataFolderName 
		SVAR IntensityWaveName = root:Packages:Irena:SASDataMerging:IntensityWaveName
		SVAR QWavename = root:Packages:Irena:SASDataMerging:QWavename
		SVAR ErrorWaveName = root:Packages:Irena:SASDataMerging:ErrorWaveName
		UseIndra2Data = UseIndra2Data2
		UseQRSdata = UseQRSdata2
		UseResults = 0
		UseUserDefinedData = 0
		UseModelData = 0
		//get the names of waves, assume this tool actually works. May not under some conditions. In thtat case this tool will not work. 
		DataFolderName2 = Data2StartFolder+FolderNameStr
		DataFolderName = DataFolderName2
		QWavename2 = stringFromList(0,IR2P_ListOfWaves("Xaxis","", "IR3D_DataMergePanel"))
		IntensityWaveName2 = stringFromList(0,IR2P_ListOfWaves("Yaxis","*", "IR3D_DataMergePanel"))
		ErrorWaveName2= stringFromList(0,IR2P_ListOfWaves("Error","*", "IR3D_DataMergePanel"))
		if(UseIndra2Data2)
			dQWavename2 = ReplaceString("Qvec", QWavename2, "dQ")
		elseif(UseQRSdata2)
			dQWavename2 = "w"+QWavename2[1,31]
		else
			dQWavename2 = ""
		endif
		Wave/Z SourceIntWv=$(DataFolderName2+IntensityWaveName2)
		Wave/Z SourceQWv=$(DataFolderName2+QWavename2)
		Wave/Z SourceErrorWv=$(DataFolderName2+ErrorWaveName2)
		Wave/Z SourcedQWv=$(DataFolderName2+dQWavename2)
		if(!WaveExists(SourceIntWv)||	!WaveExists(SourceQWv)||!WaveExists(SourceErrorWv))
			Abort "Data selection failed for Data 2"
		endif
		Duplicate/O SourceIntWv, OriginalData2IntWave
		Duplicate/O SourceQWv, OriginalData2QWave
		Duplicate/O SourceErrorWv, OriginalData2ErrorWave
		if(WaveExists(SourcedQWv))
			Duplicate/O SourcedQWv, OriginalData2dQWave
		else
			dQWavename2 = ""
		endif
		IR3D_AppendDataToGraph("Data2")
		Wave/Z ResultIntensity = root:Packages:Irena:SASDataMerging:ResultIntensity
		if(WaveExists(ResultIntensity))
			ResultIntensity= NaN
		endif
		print "Added Data 2 from folder : "+DataFolderName2
	endif

	SetDataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3D_MergeProcessData()
	
	NVAR  ProcessMerge = root:Packages:Irena:SASDataMerging:ProcessMerge 
	NVAR  ProcessMerge2 = root:Packages:Irena:SASDataMerging:ProcessMerge2 
	NVAR ProcessManually = root:Packages:Irena:SASDataMerging:ProcessManually
	NVAR ProcessSequentially=root:Packages:Irena:SASDataMerging:ProcessSequentially
	if(ProcessManually || ProcessSequentially)
		IR3D_MergeData(ProcessMerge2)
		IR3D_AppendDataToGraph("Merged")
	endif
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3D_AppendDataToGraph(WhichData)
	string WhichData		//WhichData = "Data1, Data2, Merged
	
	DoWindow IR3D_DataMergePanel
	if(!V_Flag)
		return 0
	endif
	variable WhichLegend=0
	variable startQp, endQp, tmpStQ
	if(StringMatch(WhichData, "Data1" ))
		Wave OriginalData1IntWave=root:Packages:Irena:SASDataMerging:OriginalData1IntWave
		Wave OriginalData1QWave=root:Packages:Irena:SASDataMerging:OriginalData1QWave
		Wave OriginalData1ErrorWave=root:Packages:Irena:SASDataMerging:OriginalData1ErrorWave
		CheckDisplayed /W=IR3D_DataMergePanel#DataDisplay OriginalData1IntWave
		if(!V_flag)
			AppendToGraph /W=IR3D_DataMergePanel#DataDisplay  OriginalData1IntWave  vs OriginalData1QWave
			ModifyGraph /W=IR3D_DataMergePanel#DataDisplay log=1, mirror(bottom)=1
			Label /W=IR3D_DataMergePanel#DataDisplay left "Intensity 1"
			Label /W=IR3D_DataMergePanel#DataDisplay bottom "Q [A\\S-1\\M]"
			ErrorBars /W=IR3D_DataMergePanel#DataDisplay OriginalData1IntWave Y,wave=(OriginalData1ErrorWave,OriginalData1ErrorWave)		
		endif
		NVAR Data1QEnd = root:Packages:Irena:SASDataMerging:Data1QEnd
		if(Data1QEnd>0)	 		//old Q max already set.
			endQp = BinarySearch(OriginalData1QWave, Data1QEnd)
		endif
		if(endQp<1)	//Qmax not set or not found. Set to last point-1 on that wave. 
			Data1QEnd = OriginalData1QWave[numpnts(OriginalData1QWave)-2]
			endQp = numpnts(OriginalData1QWave)-2
		endif
		cursor /W=IR3D_DataMergePanel#DataDisplay B, OriginalData1IntWave, endQp
		DoUpdate
	endif
	if(StringMatch(WhichData, "Data2" ))
		Wave OriginalData2IntWave=root:Packages:Irena:SASDataMerging:OriginalData2IntWave
		Wave OriginalData2QWave=root:Packages:Irena:SASDataMerging:OriginalData2QWave
		Wave OriginalData2ErrorWave=root:Packages:Irena:SASDataMerging:OriginalData2ErrorWave
		CheckDisplayed /W=IR3D_DataMergePanel#DataDisplay OriginalData2IntWave
		if(!V_flag)
			AppendToGraph /W=IR3D_DataMergePanel#DataDisplay/R  OriginalData2IntWave  vs OriginalData2QWave
			ModifyGraph /W=IR3D_DataMergePanel#DataDisplay log=1, mirror(bottom)=1
			ModifyGraph /W=IR3D_DataMergePanel#DataDisplay rgb(OriginalData2IntWave)=(0,0,0)
			ErrorBars /W=IR3D_DataMergePanel#DataDisplay OriginalData2IntWave Y,wave=(OriginalData2ErrorWave,OriginalData2ErrorWave)		
		endif
		NVAR Data2QStart = root:Packages:Irena:SASDataMerging:Data2QStart
		if(Data2QStart>0)	 		//old Q min already set.
			startQp = BinarySearch(OriginalData2QWave, Data2QStart)
		endif
		if(startQp<1)	//Qmin not set or not found. Set to last point-1 on that wave. 
			startQp = OriginalData2QWave[1]
			startQp = 1
		endif
		cursor /W=IR3D_DataMergePanel#DataDisplay A, OriginalData2IntWave, startQp
		DoUpdate
	endif
	if(StringMatch(WhichData, "Merged" ))
		Wave ResultIntensity=root:Packages:Irena:SASDataMerging:ResultIntensity
		Wave ResultQ=root:Packages:Irena:SASDataMerging:ResultQ
		Wave ResultError=root:Packages:Irena:SASDataMerging:ResultError
		CheckDisplayed /W=IR3D_DataMergePanel#DataDisplay ResultIntensity
		if(!V_flag)
			AppendToGraph /W=IR3D_DataMergePanel#DataDisplay  ResultIntensity  vs ResultQ
			ModifyGraph /W=IR3D_DataMergePanel#DataDisplay log=1, mirror(bottom)=1
			ModifyGraph /W=IR3D_DataMergePanel#DataDisplay rgb(ResultIntensity)=(1,16019,65535)
			ErrorBars /W=IR3D_DataMergePanel#DataDisplay ResultIntensity Y,wave=(ResultError,ResultError)		
		endif
		DoUpdate
	endif

	Wave/Z OriginalData1IntWave=root:Packages:Irena:SASDataMerging:OriginalData1IntWave
	Wave/Z OriginalData2IntWave=root:Packages:Irena:SASDataMerging:OriginalData2IntWave
	CheckDisplayed /W=IR3D_DataMergePanel#DataDisplay OriginalData1IntWave, OriginalData2IntWave, ResultIntensity
	string Shortname1, ShortName2
	
	switch(V_Flag)	// numeric switch
		case 0:		// execute if case matches expression
			Legend/W=IR3D_DataMergePanel#DataDisplay /N=text0/K
			break						// exit from switch
		case 1:		// execute if case matches expression
			SVAR DataFolderName1=root:Packages:Irena:SASDataMerging:DataFolderName1
			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
			Legend/W=IR3D_DataMergePanel#DataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1
			break
		case 2:
			SVAR DataFolderName2=root:Packages:Irena:SASDataMerging:DataFolderName2
			Shortname2 = StringFromList(ItemsInList(DataFolderName2, ":")-1, DataFolderName2  ,":")
			Legend/W=IR3D_DataMergePanel#DataDisplay /C/N=text0/J/A=LB "\\s(OriginalData2IntWave) " + Shortname2		
			break
		case 3:
			SVAR DataFolderName1=root:Packages:Irena:SASDataMerging:DataFolderName1
			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
			SVAR DataFolderName2=root:Packages:Irena:SASDataMerging:DataFolderName2
			Shortname2 = StringFromList(ItemsInList(DataFolderName2, ":")-1, DataFolderName2  ,":")
			Legend/W=IR3D_DataMergePanel#DataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2
			break
		case 7:
			SVAR DataFolderName1=root:Packages:Irena:SASDataMerging:DataFolderName1
			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
			SVAR DataFolderName2=root:Packages:Irena:SASDataMerging:DataFolderName2
			Shortname2 = StringFromList(ItemsInList(DataFolderName2, ":")-1, DataFolderName2  ,":")
			Legend/W=IR3D_DataMergePanel#DataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2+"\r\\s(ResultIntensity) Merged Data"
			break
	endswitch
	
end
	
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
	

Function IR3D_MergingPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			String ctrlName = pa.ctrlName
			
			if(stringmatch(ctrlName,"SortFolders1"))
				//do something here
				SVAR FolderSortString1 = root:Packages:Irena:SASDataMerging:FolderSortString1
				FolderSortString1 = popStr
				IR3D_UpdateListOfAvailFiles(1)
				IR3D_RebuildListboxTables()
			endif
			
			if(stringmatch(ctrlName,"SortFolders2"))
				//do something here
				SVAR FolderSortString2 = root:Packages:Irena:SASDataMerging:FolderSortString2
				FolderSortString2 = popStr
				IR3D_UpdateListOfAvailFiles(2)
				IR3D_RebuildListboxTables()
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
Function IR3D_SortListOfAvailableFldrs(WhichOne)
	variable WhichOne
	
	SVAR FolderSortString=$("root:Packages:Irena:SASDataMerging:FolderSortString"+num2str(WhichOne))
	Wave/T ListOfAvailableData=$("root:Packages:Irena:SASDataMerging:ListOfAvailableData"+num2str(WhichOne))
	Wave SelectionOfAvailableData=$("root:Packages:Irena:SASDataMerging:SelectionOfAvailableData"+num2str(WhichOne))
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
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3D_PresetOutputStrings()

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena:SASDataMerging:
	SVAR DataFolderName1=root:Packages:Irena:SASDataMerging:DataFolderName1
	SVAR IntensityWaveName1=root:Packages:Irena:SASDataMerging:IntensityWaveName1
	SVAR QWavename1=root:Packages:Irena:SASDataMerging:QWavename1
	SVAR ErrorWaveName1=root:Packages:Irena:SASDataMerging:ErrorWaveName1
	SVAR dQWavename1 = root:Packages:Irena:SASDataMerging:dQWavename1

	SVAR NewDataFolderName=root:Packages:Irena:SASDataMerging:NewDataFolderName
	SVAR NewIntensityWaveName=root:Packages:Irena:SASDataMerging:NewIntensityWaveName
	SVAR NewQWavename=root:Packages:Irena:SASDataMerging:NewQWavename
	SVAR NewErrorWaveName=root:Packages:Irena:SASDataMerging:NewErrorWaveName
	SVAR NewdQWavename = root:Packages:Irena:SASDataMerging:NewdQWavename
	
	NVAR OverwriteExistingData=root:Packages:Irena:SASDataMerging:OverwriteExistingData

	
	NewDataFolderName = DataFolderName1
	NewIntensityWaveName = IntensityWaveName1
	NewQWavename = QWavename1
	NewErrorWaveName = ErrorWaveName1
	NewdQWavename = dQWavename1
	string MostOfThePath
	string LastPartOfPath
	variable NumberOfLevelsInPath
	NumberOfLevelsInPath= ItemsInList(NewDataFolderName , ":")
	LastPartOfPath = StringFromList(NumberOfLevelsInPath-1, NewDataFolderName ,":")
	MostOfThePath = RemoveFromList(LastPartOfPath, NewDataFolderName ,":")
	
	if (stringmatch(IntensityWaveName1,"*DSM_Int*") && stringmatch(QWavename1,"*DSM_Qvec*") && stringmatch(ErrorWaveName1,"*DSM_Error*"))
		//using Indra naming convention on input Data 1, change NewDataFolderName
		LastPartOfPath = IN2G_RemoveExtraQuote(LastPartOfPath,1,1)	//remove ' from liberal names
		LastPartOfPath = LastPartOfPath[0,26]
		LastPartOfPath += "_mrg" 
		LastPartOfPath = PossiblyQuoteName(LastPartOfPath)
		NewDataFolderName = MostOfThePath+LastPartOfPath+":"
	endif
	if (stringmatch(IntensityWaveName1,"*SMR_Int*") && stringmatch(QWavename1,"*SMR_Qvec*") && stringmatch(ErrorWaveName1,"*SMR_Error*"))
		//using Indra naming convention on input Data 1, change NewDataFolderName
		LastPartOfPath = IN2G_RemoveExtraQuote(LastPartOfPath,1,1)	//remove ' from liberal names
		LastPartOfPath = LastPartOfPath[0,26]
		LastPartOfPath += "_mrg" 
		LastPartOfPath = PossiblyQuoteName(LastPartOfPath)
		NewDataFolderName = MostOfThePath+LastPartOfPath+":"
	endif
	if(!OverwriteExistingData)		//check for uniquness
		NewDataFolderName = IN2G_CreateUniqueFolderName(NewDataFolderName)
	endif
	string tempNIN, tempNQN, tempNEN
	tempNIN = IN2G_RemoveExtraQuote(NewIntensityWaveName,1,1)
	tempNQN = IN2G_RemoveExtraQuote(NewQWavename,1,1)
	tempNEN = IN2G_RemoveExtraQuote(NewErrorWaveName,1,1)
	if ((cmpstr(tempNIN[0],"r")==0) &&(cmpstr(tempNQN[0],"q")==0) &&(cmpstr(tempNEN[0],"s")==0))
		//using qrs data structure, rename the waves names
		//intensity
		NewIntensityWaveName = IN2G_RemoveExtraQuote(NewIntensityWaveName,1,1)
		NewIntensityWaveName = NewIntensityWaveName[0,26]
		NewIntensityWaveName = NewIntensityWaveName+"_mrg"
		//Q vector
		NewQWavename = IN2G_RemoveExtraQuote(NewQWavename,1,1)
		NewQWavename = NewQWavename[0,26]
		NewQWavename = NewQWavename+"_mrg"
		//error
		NewErrorWaveName = IN2G_RemoveExtraQuote(NewErrorWaveName,1,1)
		NewErrorWaveName = NewErrorWaveName[0,26]
		NewErrorWaveName = NewErrorWaveName+"_mrg"
		//DQ
		NewdQWavename = IN2G_RemoveExtraQuote(NewdQWavename,1,1)
		NewdQWavename = NewdQWavename[0,26]
		NewdQWavename = NewdQWavename+"_mrg"
		if(!OverwriteExistingData)		//check for uniquness
			DoAlert /T="Save data warning" 1, "If Data 1 type is qrs, the Overwrite existing data must be checked"
			 OverwriteExistingData=1
		endif
	endif
	
		
	setDataFolder OldDf
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3D_MergeButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlname,"AutoScale"))
				//Autoscale data only
				IR3D_AutoScale()
				IR3D_AppendDataToGraph("Merged")
				IR3D_SetSavedNotSavedMessage(0)
			endif
			if(stringmatch(ba.ctrlname,"MergeData"))
				//Merge data only
				IR3D_MergeData(0)
				IR3D_AppendDataToGraph("Merged")
				IR3D_SetSavedNotSavedMessage(0)
			endif
			if(stringmatch(ba.ctrlname,"MergeData2"))
				//Merge with Q shift data only
				IR3D_MergeData(1)
				IR3D_AppendDataToGraph("Merged")
				IR3D_SetSavedNotSavedMessage(0)
			endif
			if(stringmatch(ba.ctrlname,"ProcessSaveData"))
				IR3D_ProcessDataAsAppropriate()
			endif			
			if(stringmatch(ba.ctrlname,"IsUSAXSSAXSdata"))
				IR3D_SortIsUSAXSSAXSdata()
				//IR3D_ProcessDataAsAppropriate()
			endif			


			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3D_SortIsUSAXSSAXSdata()
	//sort the USAXS/SAXS/WAXS data to match as well as possible... 
	//here are the lists which we need to process:
	WAVE/T ListOfAvailableData  = root:Packages:Irena:SASDataMerging:ListOfAvailableData
	WAVE SelectionOfAvailableData= root:Packages:Irena:SASDataMerging:SelectionOfAvailableData
	//First, create lists of data
	Duplicate/T/Free/R=[][0] ListOfAvailableData, ListOfAvailableData1
	Duplicate/T/Free/R=[][1] ListOfAvailableData, ListOfAvailableData2
	Redimension /N=(-1,0,0,0) ListOfAvailableData1, ListOfAvailableData2
	Make/Free/T/N=0 OutPutData1, NotFoundData1, OutPutData2, NotFoundData2
	//check that we do nto have more folders than the last one
	if(ItemsInList(ListOfAvailableData1[0]  ,":")>1 || ItemsInList(ListOfAvailableData2[0]  ,":")>1)
		Abort "Plese select as high folder in Start fldr popup as possible, only last folder can be used for this to work"
	endif
	//set all selections to 0
	SelectionOfAvailableData=0
	OutPutData1 = ""
	OutPutData2 = ""
	NotFoundData1 = ""
	NotFoundData2 = ""
	variable i, j, numpairs, maxlength
	string TmpData1, TmpData2, AllData2
	AllData2=""
	For(i=0;i<numpnts(ListOfAvailableData2);i+=1)
		AllData2+=ListOfAvailableData2[i]+";"
	endfor
	if(strlen(ListOfAvailableData1[0])<5)
		Abort "These names do not seem to be USAXS names"
	endif
	For(i=0;i<numpnts(ListOfAvailableData1);i+=1)
		if(strlen(ListOfAvailableData1[i])>5)		//this contains something which has chance to be name
			TmpData1 = ListOfAvailableData1[i]			//this is Sxyz_SampleName:
			TmpData1 = ReplaceString(":", TmpData1,"")
		 	TmpData1 = RemoveFromList(StringFromList(0, TmpData1 , "_"), TmpData1  , "_")
			//this is now without the USAXS Scan number
			TmpData2 = GrepList(AllData2, TmpData1 ,0, ";")
			if(ItemsInList(TmpData2 , ";")<1)		//did not find match
				redimension/N=(numpnts(NotFoundData1)+1) NotFoundData1
				NotFoundData1[numpnts(NotFoundData1)-1] = ListOfAvailableData1[i]		
				print "Did not Find proper match for   "+ListOfAvailableData1[i]
			elseif(ItemsInList(TmpData2 , ";")<2)	//found one match
				redimension/N=(numpnts(OutPutData1)+1) OutPutData1, OutPutData2
				OutPutData1[numpnts(OutPutData1)-1] = ListOfAvailableData1[i]	
				OutPutData2[numpnts(OutPutData1)-1] = ReplaceString(";", TmpData2, "")	
				AllData2 = RemoveFromList(TmpData2, AllData2 , ";")
				print "Found proper match     "+ListOfAvailableData1[i]+"    :      "+TmpData2
			else		//found more matches, same as above, but use the fiirst one and print note in history area... 
				redimension/N=(numpnts(OutPutData1)+1) OutPutData1, OutPutData2
				OutPutData1[numpnts(OutPutData1)-1] = ListOfAvailableData1[i]	
				OutPutData2[numpnts(OutPutData1)-1] = ReplaceString(";", StringFromList(0,TmpData2,";"), "")	
				AllData2 = RemoveFromList(StringFromList(0,TmpData2,";"), AllData2 , ";")
				print "Found multiple matches for "+ListOfAvailableData1[i]+", using the first one from : "+TmpData2
			endif
		endif
	endfor
	//now we have found pairs in OutPutData1 - OutPutData2 and not found data in NotFoundData1 and AllData2
	if(ItemsInList(AllData2)>0)
		Redimension/N	=(ItemsInList(AllData2)) NotFoundData2
	endif
	For(i=0;i<numpnts(NotFoundData2);i+=1)
		NotFoundData2[i] = stringFromList(i, AllData2)
	endfor
	//OK, now all is in waves again. 
	//We need to build the waves and set the 1 and 0 as needed. 
	numpairs = numpnts(OutPutData1)
	maxlength = max((numpnts(OutPutData1)+numpnts(NotFoundData1)), (numpnts(OutPutData2)+numpnts(NotFoundData2)) )
	Redimension/N=(maxlength,2) ListOfAvailableData, SelectionOfAvailableData
	SelectionOfAvailableData = 0
	SelectionOfAvailableData[0,numpnts(OutPutData1)-1][0] =1
	SelectionOfAvailableData[0,numpnts(OutPutData1)-1][1] =1
	ListOfAvailableData[0,numpnts(OutPutData1)-1][0] = OutPutData1[p]
	ListOfAvailableData[0,numpnts(OutPutData1)-1][1] = OutPutData2[p]
	//fix the problem that NotFoundData may nto have same legth
	variable tmpNumPnts=max(numpnts(NotFoundData1),numpnts(NotFoundData2))
	redimension/N=(tmpNumPnts) NotFoundData1, NotFoundData2
	ListOfAvailableData[numpnts(OutPutData1), maxlength-1][0] = NotFoundData1[p-numpnts(OutPutData1)]
	ListOfAvailableData[numpnts(OutPutData1), maxlength-1][1] = NotFoundData2[p-numpnts(OutPutData1)]
	print "USAXS/SAXS/WAXS data sorted using standard name logic for common samples."
end
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3D_ProcessSequenceOfDataSets()
	
	//here are the lists which we need to process:
	WAVE/T ListOfAvailableData  = root:Packages:Irena:SASDataMerging:ListOfAvailableData
	WAVE SelectionOfAvailableData= root:Packages:Irena:SASDataMerging:SelectionOfAvailableData
	//In here we have column 0 contains Folder Names and Selections for Data 1
	//In here we have column 1 contains Folder Names and Selections for Data 2
	//In this case we need to load first data set selected to process from Data 1 and first from Data 2, process
	//save and iterate through second, third, etc... 
	//First, create lists of data
	Duplicate/Free/R=[][0] SelectionOfAvailableData, SelectionOfAvailableData1
	Duplicate/Free/R=[][1] SelectionOfAvailableData, SelectionOfAvailableData2
	Redimension /N=(-1,0,0,0) SelectionOfAvailableData1, SelectionOfAvailableData2
	SelectionOfAvailableData1 = (SelectionOfAvailableData1[p]<1) ? 0  : 1
	SelectionOfAvailableData2 = (SelectionOfAvailableData2[p]<1) ? 0  : 1
	variable NumDataSetsToProcess1, NumDataSetsToProcess2, i, j
	NumDataSetsToProcess1 = sum(SelectionOfAvailableData1)
	NumDataSetsToProcess2 = sum(SelectionOfAvailableData2)
	if(NumDataSetsToProcess1!=NumDataSetsToProcess2)
		Abort "Number of selected Data 1 and Data 2 is not same, cannot proceed. Please, select same number of cells for Data 1 and Data 2. "
	endif
	//Ok, create Text lists for Data1 and Data 2 with ONLY data to process in the right order...
	Make/Free/T/N=(NumDataSetsToProcess1) ListofData1, ListOfData2
	j=0
	For(i=0;i<numpnts(SelectionOfAvailableData1);i+=1)
		if(SelectionOfAvailableData1[i])
			ListofData1[j] = ListOfAvailableData[i][0]
			j+=1
		endif
	endfor
	j=0
	For(i=0;i<numpnts(SelectionOfAvailableData2);i+=1)
		if(SelectionOfAvailableData2[i])
			ListofData2[j] = ListOfAvailableData[i][1]
			j+=1
		endif
	endfor
	//Ok, we have two lists of data folders to process... 
	For(i=0;i<NumDataSetsToProcess1;i+=1)				//iterate through the lists and process...
		IR3D_CopyAndAppendData(1, ListofData1[i])
		IR3D_CopyAndAppendData(2, ListofData2[i])
		IR3D_MergeProcessData()
		DoUpdate
		IR3D_SaveData()
		sleep/S 1
	endfor
end 
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3D_ProcessDataAsAppropriate()


	string OldDf
	OldDf= GetDataFOlder(1)
	setDataFolder root:Packages:Irena:SASDataMerging
	NVAR ProcessTest=root:Packages:Irena:SASDataMerging:ProcessTest
	NVAR ProcessManually=root:Packages:Irena:SASDataMerging:ProcessManually
	NVAR ProcessSequentially=root:Packages:Irena:SASDataMerging:ProcessSequentially
	if(ProcessTest)			//test mode but user decided to save manually, should be allowed. In this case this is simply save button
		IR3D_SaveData()
	endif
	if(ProcessManually)			//manual mode, probably with NOT Save Immediately selected. In this case this is simply save button
		IR3D_SaveData()
	endif
	if(ProcessSequentially)			//here we will need to loop through the samples and process and save them. 
		IR3D_ProcessSequenceOfDataSets()
	endif
	
	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3D_AutoScale()

	string OldDf
	OldDf= GetDataFOlder(1)
	setDataFolder root:Packages:Irena:SASDataMerging
	
	Wave/Z Intensity1=root:Packages:Irena:SASDataMerging:OriginalData1IntWave
	Wave/Z Intensity2=root:Packages:Irena:SASDataMerging:OriginalData2IntWave
	Wave/Z Qvector1=root:Packages:Irena:SASDataMerging:OriginalData1QWave
	Wave/Z Qvector2=root:Packages:Irena:SASDataMerging:OriginalData2QWave
	Wave/Z Error1=root:Packages:Irena:SASDataMerging:OriginalData1ErrorWave
	Wave/Z Error2=root:Packages:Irena:SASDataMerging:OriginalData2ErrorWave
	NVAR Data1QEnd = root:Packages:Irena:SASDataMerging:Data1QEnd
	NVAR Data2QStart = root:Packages:Irena:SASDataMerging:Data2QStart
	variable startQ, endQ
	//select the Q range... 
	if(Data2QStart>0)
		startQ = Data2QStart
	elseif ((strlen(CsrWave(A,"IR3D_DataMergePanel#DataDisplay"))>0))		//user set cursor A
		startQ = CsrXWaveRef(A,"IR3D_DataMergePanel#DataDisplay")[pcsr(A,"IR3D_DataMergePanel#DataDisplay")]
		Data2QStart = startQ
	else
		startQ = Qvector2[0]
		Data2QStart = startQ
	endif
	
	
	if(Data1QEnd>0)
		endQ = Data1QEnd
	elseif ((strlen(CsrWave(B,"IR3D_DataMergePanel#DataDisplay"))==0))
		endQ = CsrXWaveRef(B,"IR3D_DataMergePanel#DataDisplay")[pcsr(B,"IR3D_DataMergePanel#DataDisplay")]
		Data1QEnd = endQ
	else
		endQ = Qvector1[numpnts(Qvector1)-1]
		Data1QEnd = endQ
	endif
	
	NVAR Data1Background=root:Packages:Irena:SASDataMerging:Data1Background
	NVAR Data2IntMultiplier=root:Packages:Irena:SASDataMerging:Data2IntMultiplier
	NVAR Data2Qshift = root:Packages:Irena:SASDataMerging:Data2Qshift

	Data2Qshift = 0
	Data1Background = 0
	
	Duplicate/O/Free Intensity1, TempInt1
	Duplicate/O/Free Intensity2, TempInt2
	Duplicate/O/Free Qvector1, TempQ1
	Duplicate/O/Free Qvector2, TempQ2
	Duplicate/O/Free Error1, TempE1
	Duplicate/O/Free Error2, TempE2
	variable integral1, integral2
	IN2G_RemoveNaNsFrom3Waves(TempInt1,TempQ1,TempE1)
	IN2G_RemoveNaNsFrom3Waves(TempInt2,TempQ2,TempE2)
	
	integral1=areaXY(TempQ1, TempInt1, startQ, endQ )
	integral2=areaXY(TempQ2, TempInt2, startQ, endQ )
	
	Data2IntMultiplier = integral1/integral2
	
	Duplicate/O TempInt2, ResultIntensity	
	Duplicate/O TempQ2, ResultQ	
	Duplicate/O TempE2, ResultError	
	ResultIntensity = ResultIntensity*Data2IntMultiplier
	ResultError = ResultError*Data2IntMultiplier

	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3D_MergeData(VaryQshift)
	variable VaryQshift

	string OldDf
	OldDf= GetDataFOlder(1)
	setDataFolder root:Packages:Irena:SASDataMerging
	
	Wave/Z Intensity1=root:Packages:Irena:SASDataMerging:OriginalData1IntWave
	Wave/Z Intensity2=root:Packages:Irena:SASDataMerging:OriginalData2IntWave
	Wave/Z Qvector1=root:Packages:Irena:SASDataMerging:OriginalData1QWave
	Wave/Z Qvector2=root:Packages:Irena:SASDataMerging:OriginalData2QWave
	Wave/Z Error1=root:Packages:Irena:SASDataMerging:OriginalData1ErrorWave
	Wave/Z Error2=root:Packages:Irena:SASDataMerging:OriginalData2ErrorWave
	Wave/Z dQ2=root:Packages:Irena:SASDataMerging:OriginalData2dQWave
	Wave/Z dQ1=root:Packages:Irena:SASDataMerging:OriginalData1dQWave
	
	NVAR Data1QEnd = root:Packages:Irena:SASDataMerging:Data1QEnd
	NVAR Data2QStart = root:Packages:Irena:SASDataMerging:Data2QStart
	variable startQ, endQ, tmpStQ, tmpEQ
	//select the Q range... 
	if(Data2QStart>0)
		startQ = Data2QStart
	elseif ((strlen(CsrWave(A,"IR3D_DataMergePanel#DataDisplay"))>0))		//user set cursor A
		tmpStQ = pcsr(A,"IR3D_DataMergePanel#DataDisplay")
		tmpStQ = (tmpStQ>0) ? tmpStQ : 1
		cursor /W=IR3D_DataMergePanel#DataDisplay A, OriginalData2IntWave, tmpStQ
		startQ = CsrXWaveRef(A,"IR3D_DataMergePanel#DataDisplay")[tmpStQ]
		Data2QStart = startQ	
	else
		startQ = Qvector2[0]
		Data2QStart = startQ	
	endif
	if(Data1QEnd>0)
		endQ = Data1QEnd
	elseif ((strlen(CsrWave(B,"IR3D_DataMergePanel#DataDisplay"))>0))
		tmpEQ = pcsr(B,"IR3D_DataMergePanel#DataDisplay")
		tmpEQ = (tmpEQ<numpnts(Intensity1)-2) ? tmpEQ : numpnts(Intensity1)-2
		cursor /W=IR3D_DataMergePanel#DataDisplay B, OriginalData1IntWave, tmpEQ
		endQ = CsrXWaveRef(B,"IR3D_DataMergePanel#DataDisplay")[tmpEQ]
		//Data1QEnd = endQ
	else
		endQ = Qvector1[numpnts(Qvector1)-1]
	//	Data1QEnd = endQ
	endif
	
	NVAR Data1Background=root:Packages:Irena:SASDataMerging:Data1Background
	NVAR Data2IntMultiplier=root:Packages:Irena:SASDataMerging:Data2IntMultiplier
	NVAR Data2Qshift = root:Packages:Irena:SASDataMerging:Data2Qshift	
	
	if (!WaveExists(Intensity1) || !WaveExists(Intensity2) || !WaveExists(Qvector1) || !WaveExists(Qvector2))
		Abort "Bad call to IR3D_MergeData routine"
	endif
	if(WaveExists(Error1))
		Duplicate/Free Error1, TempErr1
	else
		Duplicate/Free Intensity1, TempErr1
	endif
	if(WaveExists(Error2))
		Duplicate/Free Error2, TempErr2
	else
		Duplicate/Free Intensity2, TempErr2
	endif
	if(WaveExists(dQ1))
		Duplicate/Free dQ1, TempdQ1
	else
		Duplicate/Free Intensity1, TempdQ1
	endif
	if(WaveExists(dQ2))
		Duplicate/Free dQ2, TempdQ2
	else
		Duplicate/Free Intensity2, TempdQ2
	endif
	
	
	variable StartQp, EndQp
	StartQp = BinarySearch(Qvector1, startQ )
	EndQp = BinarySearch(Qvector1, endQ )

	Duplicate/O/Free Intensity1, TempInt1
	Duplicate/O/Free Intensity2, TempInt2
	Duplicate/O/Free Qvector1, TempQ1
	Duplicate/O/Free Qvector2, TempQ2
	IN2G_RemoveNaNsFrom4Waves(TempInt1,TempQ1,TempErr1,TempdQ1)
	IN2G_RemoveNaNsFrom4Waves(TempInt2,TempQ2,TempErr2,TempdQ2)
	Duplicate/O/Free/R=[StartQp, EndQp] TempInt1, TempInt1Part, TempInt2Part
	Duplicate/O/Free/R=[StartQp, EndQp] TempQ1, TempQ1Part
	Duplicate/O/Free/R=[StartQp, EndQp] TempErr1, TempErr1Part, TempErr2Part
	Duplicate/O/Free/R=[StartQp, EndQp] TempdQ1, TempdQ1Part, TempdQ2Part
	
	TempInt2Part = TempInt2[BinarySearchInterp(Qvector2, TempQ1Part[p])]
	TempErr2Part = TempErr2[BinarySearchInterp(Qvector2, TempQ1Part[p])]
	variable integral1, integral2, scalingFactor, highQDifference, Q2shift
	integral1=areaXY(TempQ1, TempInt1, startQ, endQ )
	integral2=areaXY(TempQ2, TempInt2, startQ, endQ )
	scalingFactor = integral1/integral2
	highQDifference = TempInt1Part[numpnts(TempInt1Part)-1] - scalingFactor*TempInt2Part[numpnts(TempInt2Part)-1]
	Q2shift = 0.0
	Data2Qshift = 0
	
	Concatenate /O {TempQ1Part, TempInt1Part, TempInt2Part, TempErr1Part, TempErr2Part}, TempIntCombined

	variable ValueEst= 0.1* IR3D_FindMergeValues(TempIntCombined, scalingFactor, highQDifference, Q2shift)
	//print ValueEst
	if(VaryQshift>0)
		Optimize/Q/X={scalingFactor,highQDifference, Q2shift}/R={scalingFactor,highQDifference, (TempQ1Part[0]/2)}/Y =(ValueEst) IR3D_FindMergeValues,TempIntCombined
	else	//keep Qshift=0
		Optimize/Q/X={scalingFactor,highQDifference}/R={scalingFactor,highQDifference}/Y =(ValueEst) IR3D_FindMergeValues1,TempIntCombined
	endif
	Wave W_Extremum	
	KillWaves TempIntCombined
	Data2IntMultiplier = W_Extremum[0]
	Data1Background = W_Extremum[1]
	if(VaryQshift>0)
		Data2Qshift =W_Extremum[2] 
	else
		Data2Qshift = 0 
	endif
//	SetVariable Data2IntMultiplier, win=IR1D_DataManipulationPanel, limits={-inf,inf,0.01*Data2IntMultiplier}
//	SetVariable Data1Background,  win=IR1D_DataManipulationPanel, limits={-inf,inf,0.02*abs(Data1Background)}
	StartQp = BinarySearch(Qvector2, startQ )

	Duplicate/Free/R=[0,EndQp] TempInt1, ResultIntensity1	
	Duplicate/Free/R=[0,EndQp] TempQ1, ResultQ1	
	Duplicate/Free/R=[0,EndQp] TempErr1, ResultErr1	
	Duplicate/Free/R=[0,EndQp] TempdQ1, ResultdQ1	
	Duplicate/Free/R=[StartQp,numpnts(TempInt1)-1] TempInt2, ResultIntensity2
	Duplicate/Free/R=[StartQp,numpnts(TempInt1)-1] TempQ2, ResultQ2	
	Duplicate/Free/R=[StartQp,numpnts(TempInt1)-1] TempErr2, ResultErr2	
	Duplicate/Free/R=[StartQp,numpnts(TempInt1)-1] TempdQ2, ResultdQ2	

	ResultIntensity2*=Data2IntMultiplier
	ResultErr2 *=Data2IntMultiplier
	ResultIntensity1-=Data1Background
	ResultQ2-=Data2Qshift
	
	Concatenate/NP/O {ResultIntensity1, ResultIntensity2}, ResultIntensity
	Concatenate/NP/O {ResultQ1, ResultQ2}, ResultQ
	Concatenate/NP/O {ResultErr1, ResultErr2}, ResultError
	Concatenate/NP/O {ResultdQ1, ResultdQ2}, ResultdQ
	
	Sort  ResultQ, ResultQ, ResultIntensity, ResultError, ResultdQ
	print "Merged data with following parameters: Data 2 ScalingFct = "+num2str(Data2IntMultiplier)+" , Data 1 bckg = "+num2str(Data1Background)+" , and Data 2 Q shift = "+num2str(Data2Qshift)
	//EvaluatePar()
	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3D_FindMergeValues(w, scalingFactor, highQDifference, Q2shift)
	Wave w
	Variable scalingFactor,highQDifference, Q2shift
	variable PowerLaw=0, tmpVal
	//dimensions 0 is Q, 1 is USAXS, 2 is SAXS, 3 is USAXS error, 4 is SAXS error
	make/Free/N=(dimsize(w,0)) tempDifference, tempWeights, Int2shifted, tmpQ, Int2tmp
	tmpQ = w[p][0]
	Int2tmp = w[p][2]
	InsertPoints 0,1, tmpQ, Int2tmp
	Int2tmp[0]=Int2tmp[1]
	tmpQ[0]=tmpQ[1]/2
	InsertPoints (numpnts(tmpQ)),1, tmpQ, Int2tmp
	Int2tmp[numpnts(tmpQ)-1]=Int2tmp[numpnts(tmpQ)-2]
	tmpQ[numpnts(tmpQ)-1]=tmpQ[numpnts(tmpQ)-2]*2
	Q2shift = (Q2shift >  -1*tmpQ[0]/2) ? Q2shift :  -1*tmpQ[0]/2
	Q2shift = (Q2shift <  2*tmpQ[0]) ? Q2shift :  2*tmpQ[0]
	Int2shifted = Int2tmp[BinarySearchInterp(tmpQ,(w[p][0]+Q2shift))]
	//print Int2shifted - Int2shifted2
	tempDifference = ((w[p][1]-highQDifference) - (abs(scalingFactor) * Int2shifted[p]))	//difference between the two values
	tempDifference = tempDifference^2										//distance squared... 
	tempWeights = (w[p][3] + scalingFactor * w[p][4])						//sum of uncertainities
	tempDifference/=tempWeights											//normalize the difference by uncertainity
	tempDifference = abs(tempDifference)									//this may not be necessary if difference is squared
	return sum(tempDifference)												//total distance as defined above. 
End
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3D_FindMergeValues1(w, scalingFactor, highQDifference)
	Wave w
	Variable scalingFactor,highQDifference
	variable PowerLaw=0
	//dimensions 0 is Q, 1 is USAXS, 2 is SAXS, 3 is USAXS error, 4 is SAXS error
	make/Free/N=(dimsize(w,0)) tempDifference, tempWeights
	tempDifference = ((w[p][1]-highQDifference) - (abs(scalingFactor) * w[p][2]))	//difference between the two values
	tempDifference = tempDifference^2										//distance squared... 
	tempWeights = (w[p][3] + scalingFactor * w[p][4])						//sum of uncertainities
	tempDifference/=tempWeights											//normalize the difference by uncertainity
	tempDifference = abs(tempDifference)									//this may not be necessary if difference is squared
	return sum(tempDifference)												//total distance as defined above. 
End


//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function  IR3D_SaveData()

	string OldDf
	OldDf = GetDataFolder(1)
	SVAR NewDataFolderName=root:Packages:Irena:SASDataMerging:NewDataFolderName
	SVAR NewIntensityWaveName=root:Packages:Irena:SASDataMerging:NewIntensityWaveName
	SVAR NewQWavename=root:Packages:Irena:SASDataMerging:NewQWavename
	SVAR NewErrorWaveName=root:Packages:Irena:SASDataMerging:NewErrorWaveName
	SVAR NewdQWavename=root:Packages:Irena:SASDataMerging:NewdQWavename
	
	NewIntensityWaveName=cleanupName(NewIntensityWaveName,1)
	NewQWavename=cleanupName(NewQWavename,1)
	NewErrorWaveName=cleanupName(NewErrorWaveName,1)
	NewdQWavename=cleanupName(NewdQWavename,1)
	
	Wave/Z ResultsInt = root:Packages:Irena:SASDataMerging:ResultIntensity
	Wave/Z ResultsQ = root:Packages:Irena:SASDataMerging:ResultQ
	Wave/Z ResultsE = root:Packages:Irena:SASDataMerging:ResultError
	Wave/Z ResultdQ = root:Packages:Irena:SASDataMerging:ResultdQ
	NVAR OverwriteExistingData=root:Packages:Irena:SASDataMerging:OverwriteExistingData
	
	if(DataFolderExists(NewDataFolderName)&&!OverwriteExistingData)
		Abort "Data folder exists and Overwrite existing data is not selected."
	endif

	if ((strlen(NewDataFolderName)<=1) || (strlen(NewIntensityWaveName)<=0)|| (strlen(NewQWaveName)<=0))
		Abort "Output waves names do not exist"
	endif
	variable i
	string DataFldrNameStr

	if (WaveExists(ResultsE) && (strlen(NewErrorWaveName)>0))
		if(WaveExists(ResultsInt)&&WaveExists(ResultsQ))
			if ((numpnts(ResultsInt)!=numpnts(ResultsQ)) || (numpnts(ResultsInt)!=numpnts(ResultsE)))
				DoAlert 1, "Intensity, Q and Error waves DO NOT have same number of points. Do you want really to continue?"
				if (V_Flag==2)
					abort
				endif
			endif
		endif
	else
		if(WaveExists(ResultsInt)&&WaveExists(ResultsQ))
			if (numpnts(ResultsInt)!=numpnts(ResultsQ))
				DoAlert 1, "Intensity and Q waves DO NOT have same number of points. Do you want really to continue?"
				if (V_Flag==2)
					abort
				endif
			endif
		endif
	endif


	if(WaveExists(ResultsInt)&&WaveExists(ResultsQ))
		if (cmpstr(NewDataFolderName[strlen(NewDataFolderName)-1],":")!=0)
			NewDataFolderName+=":"
		endif
		setDataFolder root:
		For(i=0;i<ItemsInList(NewDataFolderName,":");i+=1)
			if (cmpstr(StringFromList(i, NewDataFolderName , ":"),"root")!=0)
				DataFldrNameStr = StringFromList(i, NewDataFolderName , ":")
				DataFldrNameStr = IN2G_RemoveExtraQuote(DataFldrNameStr, 1,1)
				//NewDataFolder/O/S $(possiblyquotename(DataFldrNameStr))
				NewDataFolder/O/S $((DataFldrNameStr[0,30]))
			endif
		endfor	
	endif
	if(WaveExists(ResultsInt)&&WaveExists(ResultsQ))
//		Wave/Z testOutputInt=$NewIntensityWaveName
//		Wave/Z testOutputQ=$NewQWaveName
//		if (WaveExists(testOutputInt) || WaveExists(testOutputQ))
//			DoAlert 1, "Intensity and/or Q data with this name already exist, overwrite?"
//			if (V_Flag!=1)
//				abort 
//			endif
//		endif 
		Duplicate/O ResultsInt, $NewIntensityWaveName
		Duplicate/O ResultsQ, $NewQWaveName
		Wave TmpIntNote=$NewIntensityWaveName
		Wave TmpQnote=$NewQWaveName
		string OldNote, PriormergeInfo
		SVAR DataFolderName1 = root:Packages:Irena:SASDataMerging:DataFolderName1
		SVAR DataFolderName2 = root:Packages:Irena:SASDataMerging:DataFolderName2
		OldNOte=note(TmpIntNote)
		PriormergeInfo = StringByKey("Data from merged", OldNOte, "=",";")
		if(strlen(PriormergeInfo)>0)
			PriormergeInfo+=","
		endif
		PriormergeInfo+=DataFolderName1
		OldNOte=ReplaceStringByKey("Data from merged", OldNOte, PriormergeInfo  , "=" ,";")
		PriormergeInfo = StringByKey("Data merged with", OldNOte, "=",";")
		if(strlen(PriormergeInfo)>0)
			PriormergeInfo+=","
		endif
		PriormergeInfo+=DataFolderName2
		OldNOte=ReplaceStringByKey("Data merged with", OldNOte, PriormergeInfo  , "=" ,";")
		note/K TmpIntNote, OldNOte
		OldNOte=note(TmpQnote)
		PriormergeInfo = StringByKey("Data from merged", OldNOte, "=",";")
		if(strlen(PriormergeInfo)>0)
			PriormergeInfo+=","
		endif
		PriormergeInfo+=DataFolderName1
		OldNOte=ReplaceStringByKey("Data from merged", OldNOte, PriormergeInfo  , "=" ,";")
		PriormergeInfo = StringByKey("Data merged with", OldNOte, "=",";")
		if(strlen(PriormergeInfo)>0)
			PriormergeInfo+=","
		endif
		PriormergeInfo+=DataFolderName2
		OldNOte=ReplaceStringByKey("Data merged with", OldNOte, PriormergeInfo  , "=" ,";")
		note/K TmpQnote, OldNOte
		
		if (WaveExists(ResultsE) && (strlen(NewErrorWaveName)>0))
			Duplicate/O ResultsE, $NewErrorWaveName
		endif
		SVAR dQWavename2 = root:Packages:Irena:SASDataMerging:dQWavename2
		SVAR dQWavename1 = root:Packages:Irena:SASDataMerging:dQWavename1
		
		if (WaveExists(ResultdQ) && (strlen(dQWavename2)>0)&&(strlen(dQWavename1)>0)&&(strlen(NewdQWavename)>0))
			Duplicate/O ResultdQ, $NewdQWavename
		endif
		
					
		IR3D_SetSavedNotSavedMessage(1)
		print "Saved data to folder : "+GetDataFolder(1)
	endif
	setDataFolder OldDf
end
//**************************************************************************************
//**************************************************************************************
Function IR3D_SetSavedNotSavedMessage(Saved)
	variable Saved
	
	SVAR SavedDataMessage = root:Packages:Irena:SASDataMerging:SavedDataMessage
	if(!Saved)
		SavedDataMessage = "Data not saved"
		TitleBox SavedDataMessage win=IR3D_DataMergePanel,fColor=(65535,16385,16385)
		Button ProcessSaveData,win=IR3D_DataMergePanel, fColor=(65535,21845,0)
	else
		SavedDataMessage = "Data saved"
		TitleBox SavedDataMessage win=IR3D_DataMergePanel, fColor=(3,52428,1)	
		Button ProcessSaveData,win=IR3D_DataMergePanel, fColor=(0,0,0)
	endif
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3D_PanelHookFunction(H_Struct)
	STRUCT WMWinHookStruct &H_Struct
	Variable statusCode= 0	// 0 if nothing done, else 1

	Variable keyCode 		= H_Struct.keyCode
	Variable eventCode	= H_Struct.eventCode
	Variable Modifier 		= H_Struct.eventMod
	
	String subWinName 	= H_Struct.winName
	String cursorName 		= H_Struct.cursorName
	// *!*! The only way to determine which subWindow is active
	//GetWindow $"" activeSW
	//print S_value
//	String panelName 		= ParseFilePath(0, S_value, "#", 0, 0)
//	String plotName 		= ParseFilePath(0, S_value, "#", 1, 0)
//	print H_Struct
//	STRUCT WMWinHookStruct
//	 winName[200]: IR3D_DataMergePanel#DataDisplay
//	 winRect: STRUCT Rect
//	  top: 135
//	  left: 521
//	  bottom: 620
//	  right: 1183
//	 mouseLoc: STRUCT Point
//	  v: 174
//	  h: 894
//	 ticks: 7739140
//	 eventCode: 7
//	 eventName[32]: cursormoved
//	 eventMod: 1
//	 menuName[256]: 
//	 menuItem[256]: 
//	 traceName[34]: OriginalData2IntWave
//	 cursorName[2]: A
//	 pointNumber: 2
//	 yPointNumber: nan
//	 isFree: 0
//	 keycode: 0
//	 oldWinName[32]: 
//	 doSetCursor: 0
//	 cursorCode: 0
//	 wheelDx: 0
//	 wheelDy: 0
//	if(stringmatch(S_value,"IR3D_DataMergePanel#DataDisplay"))
	if(stringmatch(subWinName,"IR3D_DataMergePanel#DataDisplay"))
		if(stringmatch(GetRTStackInfo(3),"*IR3D_CopyAndAppendData*"))
			return 0
		else
			NVAR Data2Qstart = root:Packages:Irena:SASDataMerging:Data2Qstart
			NVAR Data1QEnd = root:Packages:Irena:SASDataMerging:Data1QEnd
			if(stringmatch(cursorName,"A")&&stringmatch(H_Struct.eventName,"cursormoved"))
				WAVE OriginalData2QWave = root:Packages:Irena:SASDataMerging:OriginalData2QWave
				if(!stringmatch(H_Struct.traceName,"OriginalData2IntWave"))
					cursor /W=IR3D_DataMergePanel#DataDisplay A, OriginalData2IntWave, 1
					Data2Qstart = OriginalData2QWave[1]
					Print "A cursor must be on OriginalData2IntWave and at least on second point from start"
				else		//on correct wave...
					if(H_Struct.pointNumber==0)			//bad point, needs to be at least 1
						cursor /W=IR3D_DataMergePanel#DataDisplay A, OriginalData2IntWave, 1
						Data2Qstart = OriginalData2QWave[1]
						Print "A cursor must be on OriginalData2IntWave and at least on second point from the start"
					else
						Data2Qstart = OriginalData2QWave[H_Struct.pointNumber]
						if(Data2Qstart>=Data1QEnd)
							cursor /W=IR3D_DataMergePanel#DataDisplay A, OriginalData2IntWave, 1
							Data2Qstart = OriginalData2QWave[1]
							Abort "Must have overlap of the data set. You are trying to set Data 2 start Q value higher than your current end value for Data 1. Reset Data 2 start to default position. "
						endif
					endif
				endif
			endif
			if(stringmatch(cursorName,"B")&&stringmatch(H_Struct.eventName,"cursormoved"))
				WAVE OriginalData1QWave = root:Packages:Irena:SASDataMerging:OriginalData1QWave
				if(!stringmatch(H_Struct.traceName,"OriginalData1IntWave"))
					cursor /W=IR3D_DataMergePanel#DataDisplay B, OriginalData1IntWave, numpnts(OriginalData1QWave)-2
					Data1QEnd = OriginalData2QWave[numpnts(OriginalData1QWave)-2]
					Print "B cursor must be on OriginalData1IntWave and at least on second point from the end"
				else		//on correct wave...
					if(H_Struct.pointNumber==0)			//bad point, needs to be at least 1
						cursor /W=IR3D_DataMergePanel#DataDisplay B, OriginalData1IntWave, numpnts(OriginalData1QWave)-2
						Data1QEnd = OriginalData1QWave[numpnts(OriginalData1QWave)-2]
						Print "B cursor must be on OriginalData1IntWave and at least on second point from the end"
					else
						Data1QEnd = OriginalData1QWave[H_Struct.pointNumber]		
						if(Data2Qstart>=Data1QEnd)
							cursor /W=IR3D_DataMergePanel#DataDisplay B, OriginalData1IntWave, numpnts(OriginalData1QWave)-2
							Data1QEnd = OriginalData1QWave[numpnts(OriginalData1QWave)-2]
							Abort "Must have overlap of the data set. You are trying to set end value for Data 1 lower than your current Data 2 start Q value. Reset Data 1 end to default position."
						endif
					endif
				endif
			endif
		endif
	endif
	return statusCode		// 0 if nothing done, else 1
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
