#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1
constant IR3DversionNumber = 1			//Data merging panel version number

//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
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
	SetVariable FolderNameMatchString1,pos={10,75},size={210,15}, proc=IR3D_ScriptToolSetVarProc,title="Folder Match (RegEx)"
	Setvariable FolderNameMatchString1,fSize=10,fStyle=2, variable=root:Packages:Irena:SASDataMerging:Data1MatchString
	PopupMenu SortFolders1,pos={10,100},size={180,20},fStyle=2,proc=IR3D_MergingPopMenuProc,title="Sort Folders1"
	PopupMenu SortFolders1,mode=1,popvalue=root:Packages:Irena:SASDataMerging:FolderSortString1,value= root:Packages:Irena:SASDataMerging:FolderSortStringAll

	DrawText 290,25,"Second data set"
	Checkbox UseIndra2Data2, pos={260,30},size={76,14},title="USAXS", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:UseIndra2Data2
	checkbox UseQRSData2, pos={370,30}, title="QRS(QIS)", size={76,14},proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:UseQRSdata2
	PopupMenu StartFolderSelection2,pos={260,50},size={210,15},proc=IR3D_PopMenuProc,title="Start fldr"
	PopupMenu StartFolderSelection2,mode=1,popvalue=root:Packages:Irena:SASDataMerging:Data2StartFolder,value= #"\"root:;\"+IR2S_GenStringOfFolders2(root:Packages:Irena:SASDataMerging:UseIndra2Data2, root:Packages:Irena:SASDataMerging:UseQRSdata2,2,1)"
	SetVariable FolderNameMatchString2,pos={260,75},size={210,15}, proc=IR3D_ScriptToolSetVarProc,title="Folder Match (RegEx)"
	Setvariable FolderNameMatchString2,fSize=10,fStyle=2, variable=root:Packages:Irena:SASDataMerging:Data2MatchString
	PopupMenu SortFolders2,pos={260,100},size={180,20},fStyle=2,proc=IR3D_MergingPopMenuProc,title="Sort Folders2"
	PopupMenu SortFolders2,mode=1,popvalue=root:Packages:Irena:SASDataMerging:FolderSortString2,value=root:Packages:Irena:SASDataMerging:FolderSortStringAll

	Checkbox IsUSAXSSAXSdata, pos={170,118},size={76,14},title="is USAXS/SAXS/WAXS data ", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:IsUSAXSSAXSdata

	SetVariable Data1_Background,pos={990,30},size={200,15}, proc=IR3D_ScriptToolSetVarProc,title="Data 1 Background",bodyWidth=150
	Setvariable Data1_Background, variable=root:Packages:Irena:SASDataMerging:Data1_Background, limits={-inf,inf,0}
	SetVariable Data2_IntMultiplier,pos={990,50},size={200,15}, proc=IR3D_ScriptToolSetVarProc,title="Data 2 Scaling      ",bodyWidth=150
	Setvariable Data2_IntMultiplier, variable=root:Packages:Irena:SASDataMerging:Data2_IntMultiplier, limits={-inf,inf,0}
	SetVariable Data2Qshift,pos={990,70},size={200,15}, proc=IR3D_ScriptToolSetVarProc,title="Data 2 Q shift      ",bodyWidth=150
	Setvariable Data2Qshift, variable=root:Packages:Irena:SASDataMerging:Data2Qshift, limits={-inf,inf,0}
	SetVariable Data1QEnd,pos={990,90},size={200,15}, proc=IR3D_ScriptToolSetVarProc,title="Data 1 Q max      ",bodyWidth=150
	Setvariable Data1QEnd, variable=root:Packages:Irena:SASDataMerging:Data1QEnd, limits={-inf,inf,0.05}
	SetVariable Data2Qstart,pos={990,110},size={200,15}, proc=IR3D_ScriptToolSetVarProc,title="Data 2 Q start      ",bodyWidth=150
	Setvariable Data2Qstart, variable=root:Packages:Irena:SASDataMerging:Data2Qstart, limits={-inf,inf,0.05}

	ListBox DataFolderSelection,pos={4,135},size={480,500}, mode=8
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

	TitleBox UserMessage title="",fixedSize=1,size={400,20}, pos={520,90}, variable= root:Packages:Irena:SASDataMerging:UserMessageString
	TitleBox UserMessage help={"This is what will happen"}

		
	Button AutoScale,pos={520,117},size={100,17}, proc=IR3D_MergeButtonProc,title="Test AutoScale", help={"Autoscales. Set cursors on data overlap and the data 2 will be scaled to Data 1 using integral intensity"}, disable=!root:Packages:Irena:SASDataMerging:ProcessTest
	Button MergeData,pos={640,117},size={100,17}, proc=IR3D_MergeButtonProc,title="Test Merge", help={"Scales data 2 to data 1 and sets background for data 1 for merging. Sets checkboxes and trims. Saves data also"}, disable=!root:Packages:Irena:SASDataMerging:ProcessTest
	Button MergeData2,pos={760,117},size={100,17}, proc=IR3D_MergeButtonProc,title="Test Merge 2", help={"Scales data 2 to data 1, optimizes Q shift for data 2 and sets background for data 1 for merging. Saves data also"}, disable=!root:Packages:Irena:SASDataMerging:ProcessTest

	Display /W=(521,135,1183,620) /HOST=# /N=DataDisplay

	SetActiveSubwindow ##

	SetVariable DataFolderName1,pos={550,625},size={510,15}, noproc,variable=root:Packages:Irena:SASDataMerging:DataFolderName1, title="Data 1:     "
	SetVariable DataFolderName2,pos={550,642},size={510,15}, noproc,variable=root:Packages:Irena:SASDataMerging:DataFolderName2, title="Data 2:     "
	SetVariable NewDataFolderName,pos={550,659},size={510,15}, noproc,variable=root:Packages:Irena:SASDataMerging:NewDataFolderName, title="Merged Data: "

	DrawText 4,650,"Double click to add data to graph."
	DrawText 4,663,"Shift-click to select range of data."
	DrawText 4,676,"Ctrl/Cmd-click to select one data set."
	DrawText 254,650,"Regex for not contain: ^((?!string).)*$"
	
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
	ListOfVariables+="Data1_Background;Data2_IntMultiplier;Data2_Qshift;"
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
	ListOfStrings+="NewDataFolderName;NewIntensityWaveName;NewQWavename;NewErrorWaveName;NewdQWavename1;"
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
	FolderSortStringAll = "Alphabetical;Reverse Alphabetical;_xyz;_xyz.ext;Reverse _xyz;Reverse _xyz.ext;Sxyz_;Reverse Sxyz_;_xyzmin;_xyzC;_xyz_000;Reverse _xyz_000;"
	
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
	setDataFolder root:Packages:Irena:ScriptingTool
	
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
		  	NVAR ProcessTest = root:Packages:Irena:SASDataMerging:ProcessTest
		  	NVAR ProcessMerge=root:Packages:Irena:SASDataMerging:ProcessMerge
		  	NVAR ProcessMerge2=root:Packages:Irena:SASDataMerging:ProcessMerge2
		  	SVAR UserMessageString=root:Packages:Irena:SASDataMerging:UserMessageString
			NVAR ProcessManually =root:Packages:Irena:SASDataMerging:ProcessManually
			NVAR ProcessSequentially=root:Packages:Irena:SASDataMerging:ProcessSequentially
			NVAR OverwriteExistingData=root:Packages:Irena:SASDataMerging:OverwriteExistingData
			NVAR AutosaveAfterProcessing=root:Packages:Irena:SASDataMerging:AutosaveAfterProcessing
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
					//Checkbox AutosaveAfterProcessing, win=IR3D_DataMergePanel, disable=1
	  			endif
	  		endif
		  	if(stringmatch(cba.ctrlName,"ProcessTest"))
	  			if(checked)
	  				ProcessMerge = 0
	  				ProcessMerge2 = 0
					//Checkbox AutosaveAfterProcessing, win=IR3D_DataMergePanel, disable=1
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
		  	if(stringmatch(cba.ctrlName,"ProcessMerge2")||stringmatch(cba.ctrlName,"ProcessMerge")||stringmatch(cba.ctrlName,"ProcessTest"))
				Button AutoScale,win=IR3D_DataMergePanel, disable=!ProcessTest
				Button MergeData,win=IR3D_DataMergePanel, disable=!ProcessTest
				Button MergeData2,win=IR3D_DataMergePanel, disable=!ProcessTest
			endif
			IR3D_SetProcessSetDataButton()
	  		
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**************************************************************************************
//**************************************************************************************

Function IR3D_SetProcessSetDataButton()
			NVAR ProcessTest=root:Packages:Irena:SASDataMerging:ProcessTest
			SVAR UserMessageString=root:Packages:Irena:SASDataMerging:UserMessageString
			NVAR ProcessMerge=root:Packages:Irena:SASDataMerging:ProcessMerge
			NVAR ProcessSequentially=root:Packages:Irena:SASDataMerging:ProcessSequentially
			NVAR ProcessManually=root:Packages:Irena:SASDataMerging:ProcessManually
			NVAR AutosaveAfterProcessing = root:Packages:Irena:SASDataMerging:AutosaveAfterProcessing
			
			if(ProcessTest)
				//Button ProcessSaveData,win=IR3D_DataMergePanel, disable=1
				UserMessageString = "In test mode - manual save - select Q range and method."
			else
				if(ProcessManually)
					Button ProcessSaveData,win=IR3D_DataMergePanel, title="S\rA\rV\rE\r\r\rD\rA\rT\rA", disable=0
					if(ProcessMerge)
						if(AutosaveAfterProcessing)
							UserMessageString = "Select data1& data2 - will be saved immediately. Using merge."
						else
							UserMessageString = "Select data1& data2 and use SAVE DATA. Using merge."
						endif
					else
						if(AutosaveAfterProcessing)
							UserMessageString = "Select data1& data2 - will be saved immediately. Using merge2."
						else
							UserMessageString = "Select data1& data2 and use SAVE DATA. Using merge2."
						endif
					endif
				elseif(ProcessSequentially)
					Button ProcessSaveData,win=IR3D_DataMergePanel, title="P\rR\rO\rC\rE\rS\rS\r\r\rD\rA\rT\rA", disable=0
					if(ProcessMerge)
						UserMessageString = "Select ranges of data1 & 2 and use PROCESS DATA. Using merge."
					else
						UserMessageString = "Select ranges of data1 & 2 and use PROCESS DATA. Using merge2."
					endif
				endif			
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

Function IR3D_ScriptToolSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

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
//			if(stringmatch(sva.ctrlName,"WaveNameMatchString"))
//				IR3D_UpdateListOfAvailFiles()
//				IR2S_SortListOfAvailableFldrs()
//			endif
//		case 3: // Live update
//			Variable dval = sva.dval
//			String sval = sva.sval
//			break
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

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
			break
		case 3: // double click
			IR3D_CopyAndAppendData(lba)
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
//**************************************************************************************
//**************************************************************************************
Function IR3D_CopyAndAppendData(lba)
	STRUCT WMListboxAction &lba
	
	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena:SASDataMerging					//go into the folder
	IR3D_SetSavedNotSavedMessage(0)

	Variable row = lba.row
	Variable col = lba.col
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave
	if(col==0)		//these are data 1
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
		//get the names of waves, assume this tool actually works. May not under some conditions. In thtat case this tool will not work. 
		DataFolderName1 = Data1StartFolder+listWave[row][col]
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
	endif
	if(col==1)		//these are data 2
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
		DataFolderName2 = Data2StartFolder+listWave[row][col]
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
		IR3D_MergeProcessData()
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
	if(ProcessManually)
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
	Duplicate/Free SelectionOfAvailableData, TempWv
	variable i, InfoLoc, j=0
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
				endif
			endfor
			j+=1
			if(j>(numpnts(ListOfAvailableData)-1))
				Abort "Cannot find location of _xyzmin information" 
			endif
		while (InfoLoc<1) 
		For(i=0;i<numpnts(TempWv);i+=1)
			TempWv[i] = str2num(ReplaceString("min", StringFromList(InfoLoc, ListOfAvailableData[i], "_"), ""))
		endfor
		Sort TempWv, ListOfAvailableData
	elseif(stringMatch(FolderSortString,"_xyzC"))
		Do
			For(i=0;i<ItemsInList(ListOfAvailableData[j] , "_");i+=1)
				if(StringMatch(ReplaceString(":", StringFromList(i, ListOfAvailableData[j], "_"),""), "*C" ))
					InfoLoc = i
				endif
			endfor
			j+=1
			if(j>(numpnts(ListOfAvailableData)-1))
				Abort "Cannot find location of _xyzC information" 
			endif
		while (InfoLoc<1) 
		For(i=0;i<numpnts(TempWv);i+=1)
			TempWv[i] = str2num(ReplaceString("C", StringFromList(InfoLoc, ListOfAvailableData[i], "_"), ""))
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
		LastPartOfPath += "_com" 
		LastPartOfPath = PossiblyQuoteName(LastPartOfPath)
		NewDataFolderName = MostOfThePath+LastPartOfPath+":"
	endif
	if (stringmatch(IntensityWaveName1,"*SMR_Int*") && stringmatch(QWavename1,"*SMR_Qvec*") && stringmatch(ErrorWaveName1,"*SMR_Error*"))
		//using Indra naming convention on input Data 1, change NewDataFolderName
		LastPartOfPath = IN2G_RemoveExtraQuote(LastPartOfPath,1,1)	//remove ' from liberal names
		LastPartOfPath = LastPartOfPath[0,26]
		LastPartOfPath += "_com" 
		LastPartOfPath = PossiblyQuoteName(LastPartOfPath)
		NewDataFolderName = MostOfThePath+LastPartOfPath+":"
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
		NewIntensityWaveName = NewIntensityWaveName+"_com"
		//Q vector
		NewQWavename = IN2G_RemoveExtraQuote(NewQWavename,1,1)
		NewQWavename = NewQWavename[0,26]
		NewQWavename = NewQWavename+"_com"
		//error
		NewErrorWaveName = IN2G_RemoveExtraQuote(NewErrorWaveName,1,1)
		NewErrorWaveName = NewErrorWaveName[0,26]
		NewErrorWaveName = NewErrorWaveName+"_com"
		//DQ
		NewdQWavename = IN2G_RemoveExtraQuote(NewdQWavename,1,1)
		NewdQWavename = NewdQWavename[0,26]
		NewdQWavename = NewdQWavename+"_com"
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
				IR3D_SaveData()
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
	if ((strlen(CsrWave(A,"IR3D_DataMergePanel#DataDisplay"))>0))		//user set cursor A
		startQ = CsrXWaveRef(A,"IR3D_DataMergePanel#DataDisplay")[pcsr(A,"IR3D_DataMergePanel#DataDisplay")]
	elseif(Data2QStart>0)
		startQ = Data2QStart
	else
		startQ = Qvector2[0]
	endif
	Data2QStart = startQ
	
	
	if ((strlen(CsrWave(B,"IR3D_DataMergePanel#DataDisplay"))==0))
		endQ = CsrXWaveRef(B,"IR3D_DataMergePanel#DataDisplay")[pcsr(B,"IR3D_DataMergePanel#DataDisplay")]
	elseif(Data1QEnd>0)
		endQ = Data1QEnd
	else
		endQ = Qvector1[numpnts(Qvector1)-1]
	endif
	Data1QEnd = endQ
	
	NVAR Data1_Background=root:Packages:Irena:SASDataMerging:Data1_Background
	NVAR Data2_IntMultiplier=root:Packages:Irena:SASDataMerging:Data2_IntMultiplier
	NVAR Data2Qshift = root:Packages:Irena:SASDataMerging:Data2Qshift

	Data2Qshift = 0
	Data1_Background = 0
	
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
	
	Data2_IntMultiplier = integral1/integral2
	
	Duplicate/O TempInt2, ResultIntensity	
	Duplicate/O TempQ2, ResultQ	
	Duplicate/O TempE2, ResultError	
	ResultIntensity = ResultIntensity*Data2_IntMultiplier
	ResultError = ResultError*Data2_IntMultiplier

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
	if ((strlen(CsrWave(A,"IR3D_DataMergePanel#DataDisplay"))>0))		//user set cursor A
		tmpStQ = pcsr(A,"IR3D_DataMergePanel#DataDisplay")
		tmpStQ = (tmpStQ>0) ? tmpStQ : 1
		cursor /W=IR3D_DataMergePanel#DataDisplay A, OriginalData2IntWave, tmpStQ
		startQ = CsrXWaveRef(A,"IR3D_DataMergePanel#DataDisplay")[tmpStQ]
	elseif(Data2QStart>0)
		startQ = Data2QStart
	else
		startQ = Qvector2[0]
	endif
	Data2QStart = startQ	
	if ((strlen(CsrWave(B,"IR3D_DataMergePanel#DataDisplay"))>0))
		tmpEQ = pcsr(B,"IR3D_DataMergePanel#DataDisplay")
		tmpEQ = (tmpEQ<numpnts(Intensity1)-2) ? tmpEQ : numpnts(Intensity1)-2
		cursor /W=IR3D_DataMergePanel#DataDisplay B, OriginalData1IntWave, tmpEQ
		endQ = CsrXWaveRef(B,"IR3D_DataMergePanel#DataDisplay")[tmpEQ]
	elseif(Data1QEnd>0)
		endQ = Data1QEnd
	else
		endQ = Qvector1[numpnts(Qvector1)-1]
	endif
	Data1QEnd = endQ
	
	NVAR Data1_Background=root:Packages:Irena:SASDataMerging:Data1_Background
	NVAR Data2_IntMultiplier=root:Packages:Irena:SASDataMerging:Data2_IntMultiplier
	NVAR Data2_Qshift = root:Packages:Irena:SASDataMerging:Data2Qshift	
	
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
	Data2_Qshift = 0
	
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
	Data2_IntMultiplier = W_Extremum[0]
	Data1_Background = W_Extremum[1]
	if(VaryQshift>0)
		Data2_Qshift =W_Extremum[2] 
	else
		Data2_Qshift = 0 
	endif
//	SetVariable Data2_IntMultiplier, win=IR1D_DataManipulationPanel, limits={-inf,inf,0.01*Data2_IntMultiplier}
//	SetVariable Data1_Background,  win=IR1D_DataManipulationPanel, limits={-inf,inf,0.02*abs(Data1_Background)}
	StartQp = BinarySearch(Qvector2, startQ )

	Duplicate/Free/R=[0,EndQp] TempInt1, ResultIntensity1	
	Duplicate/Free/R=[0,EndQp] TempQ1, ResultQ1	
	Duplicate/Free/R=[0,EndQp] TempErr1, ResultErr1	
	Duplicate/Free/R=[0,EndQp] TempdQ1, ResultdQ1	
	Duplicate/Free/R=[StartQp,numpnts(TempInt1)-1] TempInt2, ResultIntensity2
	Duplicate/Free/R=[StartQp,numpnts(TempInt1)-1] TempQ2, ResultQ2	
	Duplicate/Free/R=[StartQp,numpnts(TempInt1)-1] TempErr2, ResultErr2	
	Duplicate/Free/R=[StartQp,numpnts(TempInt1)-1] TempdQ2, ResultdQ2	

	ResultIntensity2*=Data2_IntMultiplier
	ResultErr2 *=Data2_IntMultiplier
	ResultIntensity1-=Data1_Background
	ResultQ2-=Data2_Qshift
	
	Concatenate/NP/O {ResultIntensity1, ResultIntensity2}, ResultIntensity
	Concatenate/NP/O {ResultQ1, ResultQ2}, ResultQ
	Concatenate/NP/O {ResultErr1, ResultErr2}, ResultError
	Concatenate/NP/O {ResultdQ1, ResultdQ2}, ResultdQ
	
	Sort  ResultQ, ResultQ, ResultIntensity, ResultError, ResultdQ
	//print "Merged data with following parameters: ScalingFct = "+num2str(Data2_IntMultiplier)+" , and bckg = "+num2str(Data1_Background)
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
		string OldNote
		OldNOte=note(TmpIntNote)
//		OldNOte=ReplaceStringByKey("Units", OldNOte, OutputDataUnits, "=" , ";")
		note/K TmpIntNote, OldNOte
		OldNOte=note(TmpQnote)
//		OldNOte=ReplaceStringByKey("Units", OldNOte, "A-1", "=" , ";")
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
	endif
	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
