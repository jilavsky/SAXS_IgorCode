#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1
#include <Multi-peak fitting 2.0>

constant IR3WversionNumber = 0.1		//Diffraction panel version number

//*************************************************************************\
//* Copyright (c) 2005 - 2015, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//0.1 Diffraction tool development version 



///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3W_WAXS()

	IN2G_CheckScreenSize("width",1200)
	IR3W_InitWAXS()
	DoWIndow IR3W_WAXSPanel
	if(V_Flag)
		DoWindow/F IR3W_WAXSPanel
		DoWindow/K IR3W_WAXSPanel
		Execute("IR3W_WAXSPanel()")
	else
		Execute("IR3W_WAXSPanel()")
	endif
//	UpdatePanelVersionNumber("IR3D_DataMergePanel", IR3DversionNumber)
		IR3W_UpdateListOfAvailFiles()
		IR3W_UpdatePDF4OfAvailFiles()
//	IR3D_RebuildListboxTables()
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Proc IR3W_WAXSPanel()
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,550,800) as "Powder Diffraction/WAXS Fits"
	DoWIndow/C IR3W_WAXSPanel
	TitleBox MainTitle title="Powder diffraction/WAXS fits panel",pos={20,2},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fSize=22,fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={200,3},pos={290,130},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox FakeLine2 title=" ",fixedSize=1,size={200,3},pos={290,365},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena:WAXS","IR3W_WAXSPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	DrawText 60,45,"Data selection"
	Checkbox UseIndra2Data, pos={10,50},size={76,14},title="USAXS", proc=IR3W_WAXSCheckProc, variable=root:Packages:Irena:WAXS:UseIndra2Data
	checkbox UseQRSData, pos={120,50}, title="QRS(QIS)", size={76,14},proc=IR3W_WAXSCheckProc, variable=root:Packages:Irena:WAXS:UseQRSdata
	PopupMenu StartFolderSelection,pos={10,70},size={180,15},proc=IR3W_PopMenuProc,title="Start fldr"
	PopupMenu StartFolderSelection,mode=1,popvalue=root:Packages:Irena:WAXS:DataStartFolder,value= #"\"root:;\"+IR2S_GenStringOfFolders2(root:Packages:Irena:WAXS:UseIndra2Data, root:Packages:Irena:WAXS:UseQRSdata, 2,1)"
	SetVariable FolderNameMatchString,pos={10,95},size={210,15}, proc=IR3W_SetVarProc,title="Folder Match (RegEx)"
	Setvariable FolderNameMatchString,fSize=10,fStyle=2, variable=root:Packages:Irena:WAXS:DataMatchString
	PopupMenu SortFolders,pos={10,115},size={180,20},fStyle=2,proc=IR3W_PopMenuProc,title="Sort Folders"
	PopupMenu SortFolders,mode=1,popvalue=root:Packages:Irena:WAXS:FolderSortString,value= root:Packages:Irena:WAXS:FolderSortStringAll

	ListBox DataFolderSelection,pos={4,135},size={250,480}, mode=10
	ListBox DataFolderSelection,listWave=root:Packages:Irena:WAXS:ListOfAvailableData
	ListBox DataFolderSelection,selWave=root:Packages:Irena:WAXS:SelectionOfAvailableData
	ListBox DataFolderSelection,proc=IR3W_WAXSListBoxProc
	SetVariable Energy,pos={4,625},size={200,15}, proc=IR3W_SetVarProc,title="X-ray E [keV] ="
	Setvariable Energy, variable=root:Packages:Irena:WAXS:Energy, limits={0.1,100,0}
	SetVariable Wavelength,pos={4,645},size={200,15}, proc=IR3W_SetVarProc,title="Wavelength [A] ="
	Setvariable Wavelength, variable=root:Packages:Irena:WAXS:Wavelength, limits={0.1,5,0}

	SetVariable DataTTHstart,pos={280,30},size={200,15}, proc=IR3W_SetVarProc,title="Fit 2Theta min      ",bodyWidth=150
	Setvariable DataTTHstart, variable=root:Packages:Irena:WAXS:DataTTHstart, limits={0,inf,0}
	SetVariable DataTTHEnd,pos={280,50},size={200,15}, proc=IR3W_SetVarProc,title="Fit 2Theta max      ",bodyWidth=150
	Setvariable DataTTHEnd, variable=root:Packages:Irena:WAXS:DataTTHEnd, limits={0,inf,0}
	Checkbox DisplayUncertainties, pos={280,80},size={76,14},title="Display Uncertainties", proc=IR3W_WAXSCheckProc, variable=root:Packages:Irena:WAXS:DisplayUncertainties


	TitleBox Info1 title="MultiPeak Fit",pos={350,145},frame=0,fstyle=1, fixedSize=1,size={350,20},fSize=12
	PopupMenu MPFInitializeFromSetMenu,pos={310,170},size={200,20},bodyWidth=190,title="Initialization:"
	PopupMenu MPFInitializeFromSetMenu,mode=1,value= #"IR3W_InitMPF2FromMenuString()", popvalue=root:Packages:Irena:WAXS:MPF2InitFolder, proc=IR3W_PopMenuProc
	Button MultiPeakFittingStart, pos={300,200}, size={200,20}, title="MultiPeak Fitting 2.0", proc=IR3W_WAXSButtonProc, help={"Open and configure MultiPeak 2.0 fitting."}

	TitleBox Info2 title="Store results in :",pos={320,225},frame=0,fstyle=0, fixedSize=1,size={350,20},fSize=12
	SetVariable MultiFitResultsFolder,pos={270,245},size={250,15}, noproc,title=" root:WAXSFitResults:"
	Setvariable MultiFitResultsFolder, variable=root:Packages:Irena:WAXS:MultiFitResultsFolder

	Button MultiPeakRecordFit, pos={270,275}, size={250,20}, title="Record MPF2 Fit Results", proc=IR3W_WAXSButtonProc, help={"Record current MPF2 resultsc for data with Multipeak 2.0."}
	Button MultiPeakFitRange, pos={270,300}, size={250,20}, title="Fit+Record Range of data", proc=IR3W_WAXSButtonProc, help={"Fit Range fo data with Multipeak 2.0."}

	Button MultiPeakPlotTool, pos={300,335}, size={200,20}, title="Plot/Evaluate results", proc=IR3W_WAXSButtonProc, help={"Evaluate results from Multipeak 2.0."}
	

	Button PDF4AddManually, pos={300,375}, size={200,20}, title="Add/Edit/Delete JCPDS/PDF card", proc=IR3W_WAXSButtonProc, help={"Add/Edit/Remove manually card from JDCPS PDF tables"}

	ListBox PDF4CardsSelection,pos={290,400},size={220,200}, mode=10
	ListBox PDF4CardsSelection,listWave=root:Packages:Irena:WAXS:ListOfPDF4Data
	ListBox PDF4CardsSelection,selWave=root:Packages:Irena:WAXS:SelectionOfPDF4Data
	ListBox PDF4CardsSelection,proc=IR3W_PDF4ListBoxProc
	ListBox PDF4CardsSelection colorWave=root:Packages:Irena:WAXS:ListOfPDF4DataColors

//	PopupMenu SimpleModel,pos={280,175},size={180,20},fStyle=2,proc=IR3W_PopMenuProc,title="Model to fit : "
//	PopupMenu SimpleModel,mode=1,popvalue=root:Packages:Irena:WAXS:ListOfSimpleModels,value= root:Packages:Irena:Irena:WAXSeModel

//
//

//	//TextBox/C/N=text1/O=90/A=MC "Save Data", TextBox/C/N=text1/A=MC "S\rA\rV\rE\r\rD\rA\rT\rA"
//
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

//	Display /W=(521,10,1183,340) /HOST=# /N=LogLogDataDisplay
//	SetActiveSubwindow ##
//	Display /W=(521,350,1183,410) /HOST=# /N=ResidualDataDisplay
//	SetActiveSubwindow ##
//	Display /W=(521,420,1183,750) /HOST=# /N=LinearizedDataDisplay
//	SetActiveSubwindow ##

//	SetVariable DataFolderName1,pos={550,625},size={510,15}, noproc,variable=root:Packages:Irena:SASDataMerging:DataFolderName1, title="Data 1:       ", disable=2
//	SetVariable DataFolderName2,pos={550,642},size={510,15}, noproc,variable=root:Packages:Irena:SASDataMerging:DataFolderName2, title="Data 2:       ", disable=2
//	SetVariable NewDataFolderName,pos={550,659},size={510,15}, noproc,variable=root:Packages:Irena:SASDataMerging:NewDataFolderName, title="Merged Data: "

	DrawText 4,680,"Double click to add data to graph."
	DrawText 4,693,"Shift-click to select range of data."
	DrawText 4,706,"Ctrl/Cmd-click to select one data set."
	DrawText 4,719,"Regex for not contain: ^((?!string).)*$"
	DrawText 4,732,"Regex for contain:  string"
	DrawText 4,745,"Regex for case independent contain:  (?i)string"
	
	Execute ("IR3W_ModifyPanelControls()")
end


//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3W_ModifyPanelControls()

	if(DataFolderExists("root:Packages:MultiPeakFit2"))
		PopupMenu MPFInitializeFromSetMenu, win=IR3W_WAXSPanel, disable=0
	else
		PopupMenu MPFInitializeFromSetMenu, win=IR3W_WAXSPanel, disable=2
	endif

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3W_InitWAXS()	


	string oldDf=GetDataFolder(1)
	string ListOfVariables
	string ListOfStrings
	variable i
		
	if (!DataFolderExists("root:Packages:Irena:WAXS"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena
		NewDataFolder/O root:Packages:Irena:WAXS
	endif
	SetDataFolder root:Packages:Irena:WAXS					//go into the folder

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;DataUnits;"
	ListOfStrings+="DataStartFolder;DataMatchString;FolderSortString;FolderSortStringAll;"
	ListOfStrings+="UserMessageString;SavedDataMessage;MPF2InitFolder;"
	ListOfStrings+="MultiFitResultsFolder;MPF2PlotFolderStart;MPF2PlotPeakProfile;MPF2PlotPeakParameter;"

	ListOfVariables="UseIndra2Data1;UseQRSdata1;"
	ListOfVariables+="DataBackground;"
	ListOfVariables+="DisplayUncertainties;DataTTHEnd;DataTTHstart;MPF2CurrentFolderNumber;"
	ListOfVariables+="ProcessManually;ProcessSequentially;OverwriteExistingData;AutosaveAfterProcessing;"
	ListOfVariables+="Energy;Wavelength;"

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
	ListOfStrings="MultiFitResultsFolder;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR teststr=$(StringFromList(i,ListOfStrings))
		if(strlen(teststr)<6)
			teststr ="FitResults1:"
		endif
	endfor		
	SVAR MPF2InitFolder
	if(strlen(MPF2InitFolder)<5)
		MPF2InitFolder = "Start Fresh"
	endif
	
//	SVAR ListOfSimpleModels
//	ListOfSimpleModels="Guinier;"
	SVAR FolderSortStringAll
	FolderSortStringAll = "Alphabetical;Reverse Alphabetical;_xyz;_xyz.ext;Reverse _xyz;Reverse _xyz.ext;Sxyz_;Reverse Sxyz_;_xyzmin;_xyzC;_xyzpct;_xyz_000;Reverse _xyz_000;"
//	SVAR SimpleModel
//	if(strlen(SimpleModel)<1)
//		SimpleModel="Guinier"
//	endif
//	NVAR OverwriteExistingData
//	NVAR AutosaveAfterProcessing
//	OverwriteExistingData=1
//	AutosaveAfterProcessing=1
//	if(ProcessTest)
//		AutosaveAfterProcessing=0
//	endif
	NVAR Wavelength
	NVAR Energy
	if(Wavelength<0.1)
		Wavelength = 1
	endif
	Energy = 12.39842 / Wavelength

	Make/O/T/N=(0) ListOfAvailableData
	Make/O/N=(0) SelectionOfAvailableData
	Make/O/T/N=(0,1) ListOfPDF4Data
	Make/O/N=(0,1,2) SelectionOfPDF4Data
	Make/O/N=(0,3) ListOfPDF4DataColors
	SetDimLabel 2,1,foreColors,SelectionOfPDF4Data
	SetDataFolder oldDf

end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3W_WAXSCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR UseIndra2Data =  root:Packages:Irena:WAXS:UseIndra2Data
			NVAR UseQRSData =  root:Packages:Irena:WAXS:UseQRSData
			SVAR DataStartFolder = root:Packages:Irena:WAXS:DataStartFolder
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
		  		PopupMenu StartFolderSelection,win=IR3W_WAXSPanel, mode=1,popvalue="root:"
				IR3W_UpdateListOfAvailFiles()
		  	endif


		  	if(stringmatch(cba.ctrlName,"DisplayUncertainties"))
				NVAR DisplayUncertainties = root:Packages:Irena:WAXS:DisplayUncertainties
				DoWindow IR3W_WAXSMainGraph 
				if(V_Flag)
					if(DisplayUncertainties)
							WAVE OriginalDataErrorWave= root:Packages:Irena:WAXS:OriginalDataErrorWave
							ErrorBars /W=IR3W_WAXSMainGraph OriginalDataIntWave Y,wave=(OriginalDataErrorWave,OriginalDataErrorWave)		
					else
						ErrorBars /W=IR3W_WAXSMainGraph OriginalDataIntWave OFF
					endif
				endif
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
Function IR3W_UpdateListOfAvailFiles()


	string OldDF=GetDataFolder(1)
	setDataFolder root:Packages:Irena:WAXS
	
	NVAR UseIndra2Data=root:Packages:Irena:WAXS:UseIndra2Data
	NVAR UseQRSdata=root:Packages:Irena:WAXS:UseQRSData
	SVAR StartFolderName=root:Packages:Irena:WAXS:DataStartFolder
	SVAR DataMatchString= root:Packages:Irena:WAXS:DataMatchString
	string LStartFolder, FolderContent
	if(stringmatch(StartFolderName,"---"))
		LStartFolder="root:"
	else
		LStartFolder = StartFolderName
	endif
	string CurrentFolders=IR3D_GenStringOfFolders(LStartFolder,UseIndra2Data, UseQRSData, 2,0,DataMatchString)

	Wave/T ListOfAvailableData=root:Packages:Irena:WAXS:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:Irena:WAXS:SelectionOfAvailableData
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
	IR3W_SortListOfAvailableFldrs()
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
Function IR3W_SortListOfAvailableFldrs()
	
	SVAR FolderSortString=root:Packages:Irena:WAXS:FolderSortString
	Wave/T ListOfAvailableData=root:Packages:Irena:WAXS:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:Irena:WAXS:SelectionOfAvailableData
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

Function IR3W_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if(stringmatch(ctrlName,"StartFolderSelection"))
		//Update the listbox using start folde popStr
		SVAR StartFolderName=root:Packages:Irena:WAXS:DataStartFolder
		StartFolderName = popStr
		IR3W_UpdateListOfAvailFiles()
	endif
	if(stringmatch(ctrlName,"SortFolders"))
		//do something here
		SVAR FolderSortString = root:Packages:Irena:WAXS:FolderSortString
		FolderSortString = popStr
		IR3W_UpdateListOfAvailFiles()
	endif
	if(stringmatch(ctrlName,"MPF2PlotFolderStart"))
		//do something here
		SVAR MPF2PlotFolderStart = root:Packages:Irena:WAXS:MPF2PlotFolderStart
		SVAR MPF2PlotPeakProfile = root:Packages:Irena:WAXS:MPF2PlotPeakProfile
		MPF2PlotFolderStart = popStr
		MPF2PlotPeakProfile = stringFromList(0,IR3W_PlotUpdateListsOfResults("Peak Profiles"))
		PopupMenu MPF2PlotPeakProfile,win=IR3W_WAXS_MPFPlots ,mode=1,value= #"IR3W_PlotUpdateListsOfResults(\"Peak Profiles\")"
		//PopupMenu MPF2PlotPeakProfile,win=IR3W_WAXS_MPFPlots ,popvalue=MPF2PlotPeakProfile,value= #"IR3W_PlotUpdateListsOfResults(\"Peak Profiles\")"
	endif
	if(stringmatch(ctrlName,"MPF2PlotPeakProfile"))
		//do something here
		SVAR MPF2PlotPeakProfile = root:Packages:Irena:WAXS:MPF2PlotPeakProfile
		MPF2PlotPeakProfile = popStr
	endif
	if(stringmatch(ctrlName,"MPFInitializeFromSetMenu"))
		//do something here
		SVAR MPF2InitFolder = root:Packages:Irena:WAXS:MPF2InitFolder
		MPF2InitFolder = popStr
	endif
	
	
end


//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function/S IR3W_InitMPF2FromMenuString()

	String theList = "Start Fresh;"
	theList += "\\M1(---;"
	
	String SetList = ListExistingSets()
	Variable i
	Variable nSets = ItemsInList(SetList)
	for (i = 0; i < nSets; i += 1)
		theList += "Set Number "+StringFromList(i, SetList)+";"
	endfor

	return theList
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3W_SetVarProc(sva) : SetVariableControl
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

			NVAR DataTTHstart = root:Packages:Irena:WAXS:DataTTHstart
			NVAR DataTTHEnd = root:Packages:Irena:WAXS:DataTTHEnd
	
			if(stringmatch(sva.ctrlName,"DataTTHEnd"))
				WAVE OriginalData2ThetaWave = root:Packages:Irena:WAXS:OriginalData2ThetaWave
				tempP = BinarySearch(OriginalData2ThetaWave, DataTTHEnd )
				if(tempP<0)
					print "Wrong 2Theta value set, 2 Theta max must be at most 1 point before the end of Data"
					tempP = numpnts(OriginalData2ThetaWave)-1
					DataTTHEnd = OriginalData2ThetaWave[tempP]
				endif
				cursor /W=IR3W_WAXSMainGraph B, OriginalDataIntWave, tempP
			endif
			if(stringmatch(sva.ctrlName,"DataTTHstart"))
				WAVE OriginalData2ThetaWave = root:Packages:Irena:WAXS:OriginalData2ThetaWave
				tempP = BinarySearch(OriginalData2ThetaWave, DataTTHstart )
				if(tempP<1)
					print "Wrong 2 Theta value set, 2 Theta start  must be at least 1 point from the start of Data"
					tempP = 1
					DataTTHstart = OriginalData2ThetaWave[tempP]
				endif
				cursor /W=IR3W_WAXSMainGraph A, OriginalDataIntWave, tempP
			endif
			NVAR Energy = root:Packages:Irena:WAXS:Energy
			NVAR Wavelength = root:Packages:Irena:WAXS:Wavelength
			if(stringmatch(sva.ctrlName,"Wavelength"))
				Energy = 12.39842 / wavelength
			endif
			if(stringmatch(sva.ctrlName,"Energy"))
				wavelength = 12.39842 / Energy
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

Function IR3W_WAXSListBoxProc(lba) : ListBoxControl
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
			FoldernameStr=listWave[row]
			IR3W_CopyAndAppendData(FoldernameStr)
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
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3W_CopyAndAppendData(FolderNameStr)
	string FolderNameStr
	
	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena:WAXS					//go into the folder
	//IR3D_SetSavedNotSavedMessage(0)

		SVAR DataStartFolder=root:Packages:Irena:WAXS:DataStartFolder
		SVAR DataFolderName=root:Packages:Irena:WAXS:DataFolderName
		SVAR IntensityWaveName=root:Packages:Irena:WAXS:IntensityWaveName
		SVAR QWavename=root:Packages:Irena:WAXS:QWavename
		SVAR ErrorWaveName=root:Packages:Irena:WAXS:ErrorWaveName
		SVAR dQWavename=root:Packages:Irena:WAXS:dQWavename
		NVAR UseIndra2Data=root:Packages:Irena:WAXS:UseIndra2Data
		NVAR UseQRSdata=root:Packages:Irena:WAXS:UseQRSdata
		//these are variables used by the control procedure
		NVAR  UseResults=  root:Packages:Irena:WAXS:UseResults
		NVAR  UseUserDefinedData=  root:Packages:Irena:WAXS:UseUserDefinedData
		NVAR  UseModelData = root:Packages:Irena:WAXS:UseModelData
		SVAR DataFolderName  = root:Packages:Irena:WAXS:DataFolderName 
		SVAR IntensityWaveName = root:Packages:Irena:WAXS:IntensityWaveName
		SVAR QWavename = root:Packages:Irena:WAXS:QWavename
		SVAR ErrorWaveName = root:Packages:Irena:WAXS:ErrorWaveName
		
		UseResults = 0
		UseUserDefinedData = 0
		UseModelData = 0
		//get the names of waves, assume this tool actually works. May not under some conditions. In that case this tool will not work. 
		DataFolderName = DataStartFolder+FolderNameStr
		QWavename = possiblyQUoteName(stringFromList(0,IR2P_ListOfWaves("Xaxis","", "IR3W_WAXSPanel")))
		IntensityWaveName =  possiblyQUoteName(stringFromList(0,IR2P_ListOfWaves("Yaxis","*", "IR3W_WAXSPanel")))
		ErrorWaveName =  possiblyQUoteName(stringFromList(0,IR2P_ListOfWaves("Error","*", "IR3W_WAXSPanel")))
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
			Abort "Data selection failed"
		endif
		Duplicate/O SourceIntWv, OriginalDataIntWave
		Duplicate/O SourceQWv, OriginalData2ThetaWave
		Duplicate/O SourceErrorWv, OriginalDataErrorWave
		if(WaveExists(SourcedQWv))
			Duplicate/O SourcedQWv, OriginalDatad2ThetaWave
		else
			Duplicate/O SourceQWv, OriginalDatad2ThetaWave
			OriginalDatad2ThetaWave=0
		endif
		//figrue out what data you have... 
		variable XaxisType=0
		if(UseIndra2Data)
			XaxisType = 1 //Q data
		elseif(UseQRSdata)
			if(StringMatch(QWavename, "q*")||StringMatch(QWavename, "'q*"))
				XaxisType = 1 //Q data
			elseif(StringMatch(QWavename, "d*")||StringMatch(QWavename, "'d*"))
				XaxisType = 2 //d data
			elseif(StringMatch(QWavename, "t*")||StringMatch(QWavename, "'t*"))
				XaxisType = 3 //2Theta data
			else	//unknown or mm, do not use
				XaxisType=0
			endif
		else
			XaxisType=0
		endif
		//figure out if the data do have X-ray energy in the note...
		string DataNote=Note(SourceIntWv)
		NVAR  Energy = root:Packages:Irena:WAXS:Energy
		NVAR  Wavelength = root:Packages:Irena:WAXS:Wavelength
		if(GrepString(DataNote, "(?i)energy"))		//found energy, primary info
			Energy =  str2num(StringFromList(1,GrepList(DataNote, "(?i)energy"),"="))
			print "Found X-ray energy in the  wave note : "+num2str(Energy)
			Wavelength  = 12.39842 / Energy 
		elseif(GrepString(DataNote, "(?i)wavelength"))	//found wavelength
			wavelength =  str2num(StringFromList(1,GrepList(DataNote, "(?i)wavelength"),"="))
			print "Found X-ray wavelength in the  wave note : "+num2str(wavelength)
			Energy  = 12.39842 / wavelength 
		else
			//found nothing, use the existing ones... 
		endif
		IR3W_ConvertXdataToTTH(OriginalData2ThetaWave,OriginalDatad2ThetaWave,XaxisType,wavelength)
		IR3W_GraphWAXSData()
	//	IR3W_CreateLinearizedData()
	//	IR3W_AppendDataToGraphModel()
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

Function IR3W_ConvertXdataToTTH(OriginalData2ThetaWave,OriginalDatad2ThetaWave,XaxisType,wavelength)
	wave OriginalData2ThetaWave,OriginalDatad2ThetaWave
	variable XaxisType,wavelength
	//q = 4pi sin(theta)/lambda
	//theta = (q * lamda / 4pi) * 180/pi [deg]
	//asin(q * lambda /4pi) = theta
	//d ~ 2*pi/Q

	if(XaxisType==0)
		Abort "Unknown X axis type"
	elseif(XaxisType==1)		//Q
		OriginalData2ThetaWave =   114.592 * asin(OriginalData2ThetaWave[p]* wavelength / (4*pi))
		OriginalDatad2ThetaWave =  114.592 * asin(OriginalDatad2ThetaWave[p] * wavelength / (4*pi))
	elseif(XaxisType==2)		//d
		OriginalData2ThetaWave =   114.592 * asin((2 * pi / OriginalData2ThetaWave[p])* wavelength / (4*pi))
		OriginalDatad2ThetaWave =  114.592 * asin((2 * pi / OriginalDatad2ThetaWave[p])* wavelength / (4*pi))
	elseif(XaxisType==3)		//TwoTheta
		//nothing to do
	endif
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3W_ConvertTTHdataTod(TTH,wavelength)
	variable TTH,wavelength
	//q = 4pi sin(theta)/lambda
	//theta = (q * lamda / 4pi) * 180/pi [deg]
	//asin(q * lambda /4pi) = theta
	//d ~ 2*pi/Q

	return  wavelength  / (2*sin(pi*TTH/360))	
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3W_CreateLinearizedData()

	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena:WAXS					//go into the folder
	Wave OriginalDataIntWave=root:Packages:Irena:WAXS:OriginalDataIntWave
	Wave OriginalDataQWave=root:Packages:Irena:WAXS:OriginalDataQWave
	Wave OriginalDataErrorWave=root:Packages:Irena:WAXS:OriginalDataErrorWave
//	SVAR SimpleModel=root:Packages:Irena:WAXS:SimpleModel
	Duplicate/O OriginalDataIntWave, LinModelDataIntWave, ModelNormalizedResidual
	Duplicate/O OriginalDataQWave, LinModelDataQWave, ModelNormResXWave
	Duplicate/O OriginalDataErrorWave, LinModelDataEWave
	ModelNormalizedResidual = 0	
	SetDataFolder oldDf
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************



Function IR3W_AppendDataToGraphModel()
	
//	DoWindow IR3W_WAXSPanel
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
//	Wave LinModelDataIntWave=root:Packages:Irena:WAXS:LinModelDataIntWave
//	Wave LinModelDataQWave=root:Packages:Irena:WAXS:LinModelDataQWave
//	Wave LinModelDataEWave=root:Packages:Irena:WAXS:LinModelDataEWave
//	CheckDisplayed /W=IR3W_WAXSPanel#LogLogDataDisplay LinModelDataIntWave
//	if(!V_flag)
//		AppendToGraph /W=IR3W_WAXSPanel#LinearizedDataDisplay  LinModelDataIntWave  vs LinModelDataQWave
//		ModifyGraph /W=IR3W_WAXSPanel#LinearizedDataDisplay log=1, mirror(bottom)=1
//		Label /W=IR3W_WAXSPanel#LinearizedDataDisplay left "Intensity"
//		Label /W=IR3W_WAXSPanel#LinearizedDataDisplay bottom "Q [A\\S-1\\M]"
//		ErrorBars /W=IR3W_WAXSPanel#LinearizedDataDisplay LinModelDataIntWave Y,wave=(LinModelDataEWave,LinModelDataEWave)		
//	endif
////	NVAR DataQEnd = root:Packages:Irena:WAXS:DataQEnd
////	if(DataQEnd>0)	 		//old Q max already set.
////		endQp = BinarySearch(OriginalDataQWave, DataQEnd)
////	endif
////	if(endQp<1)	//Qmax not set or not found. Set to last point-1 on that wave. 
////		DataQEnd = OriginalDataQWave[numpnts(OriginalDataQWave)-2]
////		endQp = numpnts(OriginalDataQWave)-2
////	endif
////	cursor /W=IR3W_WAXSPanel#LogLogDataDisplay B, OriginalDataIntWave, endQp
//	DoUpdate
//
//	Wave/Z ModelNormalizedResidual=root:Packages:Irena:WAXS:ModelNormalizedResidual
//	Wave/Z ModelNormResXWave=root:Packages:Irena:WAXS:ModelNormResXWave
//	CheckDisplayed /W=IR3W_WAXSPanel#ResidualDataDisplay ModelNormalizedResidual  //, ResultIntensity
//	if(!V_flag)
//		AppendToGraph /W=IR3W_WAXSPanel#ResidualDataDisplay  ModelNormalizedResidual  vs ModelNormResXWave
//		ModifyGraph /W=IR3W_WAXSPanel#LinearizedDataDisplay log=1, mirror(bottom)=1
//		Label /W=IR3W_WAXSPanel#LinearizedDataDisplay left "Normalized res."
//		Label /W=IR3W_WAXSPanel#LinearizedDataDisplay bottom "Q [A\\S-1\\M]"
//	endif
//
//
//
//	string Shortname1, ShortName2
//	
//	switch(V_Flag)	// numeric switch
//		case 0:		// execute if case matches expression
//			Legend/W=IR3W_WAXSPanel#LogLogDataDisplay /N=text0/K
//			break						// exit from switch
////		case 1:		// execute if case matches expression
////			SVAR DataFolderName=root:Packages:Irena:WAXS:DataFolderName
////			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
////			Legend/W=IR3W_WAXSPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1
////			break
////		case 2:
////			SVAR DataFolderName=root:Packages:Irena:WAXS:DataFolderName
////			Shortname2 = StringFromList(ItemsInList(DataFolderName2, ":")-1, DataFolderName2  ,":")
////			Legend/W=IR3W_WAXSPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData2IntWave) " + Shortname2		
////			break
////		case 3:
////			SVAR DataFolderName=root:Packages:Irena:WAXS:DataFolderName
////			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
////			Legend/W=IR3W_WAXSPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2
////			break
////		case 7:
////			SVAR DataFolderName=root:Packages:Irena:WAXS:DataFolderName
////			Shortname1 = StringFromList(ItemsInList(DataFolderName1, ":")-1, DataFolderName1  ,":")
////			Legend/W=IR3W_WAXSPanel#LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalData1IntWave) "+Shortname1+"\r\\s(OriginalData2IntWave) "+Shortname2+"\r\\s(ResultIntensity) Merged Data"
//			break
//	endswitch
//
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


Function IR3W_GraphWAXSData()
	
	variable WhichLegend=0
	variable startTTHp, endTTHp, tmpStQ
	Wave OriginalDataIntWave=root:Packages:Irena:WAXS:OriginalDataIntWave
	Wave OriginalData2ThetaWave=root:Packages:Irena:WAXS:OriginalData2ThetaWave
	Wave OriginalDataErrorWave=root:Packages:Irena:WAXS:OriginalDataErrorWave
	NVAR DisplayUncertainties = root:Packages:Irena:WAXS:DisplayUncertainties


	DoWindow IR3W_WAXSMainGraph 
	if(!V_Flag)
		Display/K=1/W=(630,45,1531,570) OriginalDataIntWave  vs OriginalData2ThetaWave as "Powder Diffraction / WAXS Main Graph"
		DoWindow/C IR3W_WAXSMainGraph
		setWIndow IR3W_WAXSMainGraph, hook(CursorMoved)=IR3W_GraphHookFunction
		Label /W=IR3W_WAXSMainGraph left "Intensity"
		Label /W=IR3W_WAXSMainGraph bottom "2Theta [deg]"
		ErrorBars /W=IR3W_WAXSMainGraph OriginalDataIntWave Y,wave=(OriginalDataErrorWave,OriginalDataErrorWave)		
		showinfo
	endif
	AutopositionWindow /R=IR3W_WAXSPanel IR3W_WAXSMainGraph
	if(DisplayUncertainties)
		//ErrorBars OriginalDataIntWave OFF 
	else
		ErrorBars /W=IR3W_WAXSMainGraph OriginalDataIntWave OFF
	endif

	NVAR DataTTHstart = root:Packages:Irena:WAXS:DataTTHstart
	NVAR DataTTHEnd = root:Packages:Irena:WAXS:DataTTHEnd
	
	if(DataTTHEnd>0)	 		//old 2Theta max already set.
		endTTHp = BinarySearch(OriginalData2ThetaWave, DataTTHEnd)
		if(endTTHp<0)
			endTTHp = numpnts(OriginalData2ThetaWave)-1
			DataTTHEnd = OriginalData2ThetaWave[endTTHp]
		endif
	else
		endTTHp = numpnts(OriginalData2ThetaWave)-1
		DataTTHEnd = OriginalData2ThetaWave[endTTHp]
	endif
	if(DataTTHstart>0)	 		//old 2Theta min already set.
		startTTHp = BinarySearch(OriginalData2ThetaWave, DataTTHstart)
		if(startTTHp<0)
			startTTHp = 1
			DataTTHstart = OriginalData2ThetaWave[1]
		endif
	else
		startTTHp = 1
		DataTTHstart = OriginalData2ThetaWave[1]
	endif
	cursor /W=IR3W_WAXSMainGraph B, OriginalDataIntWave, endTTHp
	cursor /W=IR3W_WAXSMainGraph A, OriginalDataIntWave, startTTHp
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//Start Peak Fitting GUI for WAXS

Function IR3W_StartMultiPeakGUIForWAXS()
	String yWName = "root:Packages:Irena:WAXS:OriginalDataIntWave"	
	String xWName = "root:Packages:Irena:WAXS:OriginalData2ThetaWave"
	Wave/Z yw = $yWName
	Wave/Z xw = $xWName
	
	if (!WaveExists(yw))
		DoAlert 0, "It appears you have not selected data waves yet."
		return -1
	endif
	
	if (WaveExists(xw))
		if (!IR3W_isMonotonic(xw))
			DoAlert 0, "Your X data wave is not monotonic."
			return -1
		endif
	endif

	//check for cursors in the main window and presence of the window anyway, so no failures... 
	DoWindow IR3W_WAXSMainGraph
	if(!V_FLag)
		Abort "Create the graph widnow and add data in it"
	endif
	if(strlen(csrInfo(A,"IR3W_WAXSMainGraph"))<5)		//not set
		Cursor/P A  OriginalDataIntWave  0 
	endif
	if(strlen(csrInfo(B,"IR3W_WAXSMainGraph"))<5)		//not set
		Cursor/P B  OriginalDataIntWave  numpnts(yw)-1
	endif	

	Variable Panelposition = 0
	String theGraph = "IR3W_WAXSMainGraph"
	SVAR MPF2InitFolder = root:Packages:Irena:WAXS:MPF2InitFolder	
	NVAR currentSetNumber = root:Packages:MultiPeakFit2:currentSetNumber	
	NVAR MPF2CurrentFolderNumber = root:Packages:Irena:WAXS:MPF2CurrentFolderNumber	
	Variable menuSetNumber
	Variable initializeFrom = 1
	if(!StringMatch(MPF2InitFolder, "Start Fresh" ))
		initializeFrom = 3
		sscanf MPF2InitFolder, "Set Number %d", menuSetnumber	
	else
		initializeFrom = 1
		menuSetnumber=0
	endif
	
	MPF2_StartNewMPFit(Panelposition, theGraph, yWName, xWName, initializeFrom, menuSetNumber)
	MPF2CurrentFolderNumber = currentSetNumber
	SVAR MPF2WeightWaveName = $("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(currentSetNumber)+":MPF2WeightWaveName")
	MPF2WeightWaveName = "root:Packages:Irena:WAXS:OriginalDataErrorWave"
	CheckBox MPF2_UserCursorsCheckbox value=1
//	NVAR negativePeaks = root:Packages:MultiPeakFit2:MPF_SetFolder_100:negativePeaks
//	negativePeaks=0
//	NVAR MPF2_UserCursors = root:Packages:MultiPeakFit2:MPF_SetFolder_100:MPF2_UserCursors
//	MPF2_UserCursors = 1
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3W_WAXSButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlname,"MultiPeakFittingStart"))
				if(!DataFolderExists("root:Packages:MultiPeakFit2"))
					fStartMultipeakFit2()
				endif
				IR3W_StartMultiPeakGUIForWAXS()
				IR3W_ModifyPanelControls()
			endif
			if(stringmatch(ba.ctrlname,"MultiPeakFitRange"))
				IR3W_FitMultiPeakFit2ForWAXS()
			endif
			if(stringmatch(ba.ctrlname,"MultiPeakRecordFit"))
				IR3W_SaveMultiPeakResults()
			endif
			if(stringmatch(ba.ctrlname,"MultiPeakPlotTool"))
				DoWIndow IR3W_WAXS_MPFPlots
				if(V_Flag)
					DoWIndow/F IR3W_WAXS_MPFPlots
				else
					Execute("IR3W_WAXS_MPFPlots() ")
				endif
			endif
			if(stringmatch(ba.ctrlname,"MPF2PlotPeakGraph"))
				IR3W_MPF2PlotPeakGraph()
			endif
			if(stringmatch(ba.ctrlname,"MPF2PlotPeakParams"))
				IR3W_MPF2PlotPeakParameters()
			endif
			if(stringmatch(ba.ctrlname,"PDF4AddManually"))
				IR3W_PDF4AddManually()
				IR3W_UpdatePDF4OfAvailFiles()
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
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3W_FitMultiPeakFit2ForWAXS()

	WAVE/T/Z listWave = root:Packages:Irena:WAXS:ListOfAvailableData
	WAVE/Z selWave = root:Packages:Irena:WAXS:SelectionOfAvailableData
	string FoldernameStr
	variable i
	For(I=0;i<numpnts(selWave);i+=1)
		if(selWave[i]>0)
			FoldernameStr=listWave[i]
			IR3W_CopyAndAppendData(FoldernameStr)
			IR3W_DoMultiPeak2Fits()
			IR3W_SaveMultiPeakResults()
			DoWIndow/F IR3W_WAXSMainGraph
			sleep/S (1)
		endif
	endfor
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3W_DoMultiPeak2Fits()
		NVAR MPF2CurrentFolderNumber = root:Packages:Irena:WAXS:MPF2CurrentFolderNumber	
		setDataFolder $("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber))
		STRUCT WMButtonAction s
		s.ctrlName="MPF2_DoFitButton"
		s.win="IR3W_WAXSMainGraph#MultiPeak2Panel#P2"
		s.eventCode=2
		MPF2_DoFitButtonProc(s)

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

 function IR3W_SaveMultiPeakResults()
 
	NVAR MPF2CurrentFolderNumber = root:Packages:Irena:WAXS:MPF2CurrentFolderNumber	
 	string Oldf=GetDataFolder(1)
 	setDataFolder $("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber))
 
		STRUCT WMButtonAction s
		s.ctrlName="MPF2_PeakResultsButton"
		s.win="IR3W_WAXSMainGraph#MultiPeak2Panel#P2"
		s.eventCode=2
		MPF2_PeakResultsButtonProc(s)
		//this generates the new panel with results (keep up for few seconds and close... and followign waves with the results
		//tshi cretaes and saves int ehnotebook...
		s.ctrlName="MPF2_ResultsDoNotebookButton"
		s.win="MPF2_ResultsPanel_"+num2str(MPF2CurrentFolderNumber)
		s.eventCode=2		
		MPF2_ResultsDoNotebookButtnProc(s)
		controlInfo/W=$("MPF2_ResultsPanel_"+num2str(MPF2CurrentFolderNumber)) MPFTResults_BackgroundCheck
		if(V_Value!=1)
			checkbox MPFTResults_BackgroundCheck win=$("MPF2_ResultsPanel_"+num2str(MPF2CurrentFolderNumber)), value=1
			STRUCT WMCheckboxAction ss
			ss.win="MPF2_ResultsPanel_"+num2str(MPF2CurrentFolderNumber)
			ss.eventCode=2		
			MPF2_reportBackground(ss)
		endif
		Killwaves/Z $("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber)+":MPFit2Model_BSub")
		SetVariable MPF2_BLSubtractedWaveName, win=$("MPF2_ResultsPanel_"+num2str(MPF2CurrentFolderNumber)), value=_STR:"MPFit2Model_BSub"
		s.win="MPF2_ResultsPanel_"+num2str(MPF2CurrentFolderNumber)
		s.eventCode=2		
		MPF2_BLSubtractedDataButtonProc(s)		
		IR3W_TabDelimitedResultsBtnProc(s)
		//Parameters are here
		Wave/T MPF2_ResultsListWave = $("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber)+":MPF2_ResultsListWave")
		Wave/T MPF2_ResultsListTitles = $("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber)+":MPF2_ResultsListTitles")
		//Peaks without background are here:
		Wave MMPF2_BSubData = $("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber)+":MPFit2Model_BSub")
		Wave MMPF2_FitToData = $("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber)+":fit_OriginalDataIntWave")
		SVAR MultiFitResultsFolder = root:Packages:Irena:WAXS:MultiFitResultsFolder
		SVAR DataFolderName = root:Packages:Irena:WAXS:DataFolderName
		NVAR Wavelength = root:Packages:Irena:WAXS:Wavelength
		string OldDf=GetDataFOlder(1)
		if (cmpstr(MultiFitResultsFolder[strlen(MultiFitResultsFolder)-1],":")!=0)
			MultiFitResultsFolder+=":"
		endif
		setDataFolder root:
		string DataFldrNameStr
		variable i
		NewDataFolder/O/S root:WAXSFitResults
		if(strlen(MultiFitResultsFolder)<2)
			MultiFitResultsFolder = UniqueName("FittingResults", 11, 0)
		endif
		For(i=0;i<ItemsInList(MultiFitResultsFolder,":");i+=1)
			if (cmpstr(StringFromList(i, MultiFitResultsFolder , ":"),"root")!=0)
				DataFldrNameStr = StringFromList(i, MultiFitResultsFolder , ":")
				DataFldrNameStr = IN2G_RemoveExtraQuote(DataFldrNameStr, 1,1)
				//NewDataFolder/O/S $(possiblyquotename(DataFldrNameStr))
				NewDataFolder/O/S $((DataFldrNameStr[0,30]))
			endif
		endfor	
		DataFldrNameStr = StringFromList(ItemsInList(DataFolderName,":")-1, DataFolderName,  ":")
		DataFldrNameStr = ReplaceString("'", DataFldrNameStr, "")
		NewDataFolder/O/S $(DataFldrNameStr)
		Duplicate/O MPF2_ResultsListWave, WAXS_ResultsListWave
		Duplicate/O MPF2_ResultsListTitles, WAXS_ResultsListTitles
		Duplicate/O MMPF2_BSubData, WAXS_BckgSubtractedData
		Duplicate/O MMPF2_FitToData, WAXS_FitToData		
		Duplicate/O  MMPF2_FitToData, WAXS_FitToData_d
		Wave WAXS_FitToData_d=WAXS_FitToData_d
		WAXS_FitToData_d[] = IR3W_ConvertTTHdataTod(pnt2x(MMPF2_FitToData, p ),Wavelength)

			For(i=0;i<dimsize(MPF2_ResultsListWave,0);i+=1)
			Wave/Z PeakData=$("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber)+":'Peak "+num2str(i)+"'")
			if(WaveExists(PeakData))
				Wave PeakData=$("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber)+":'Peak "+num2str(i)+"'")
				Wave PeakDataCoefs=$("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber)+":'Peak "+num2str(i)+" Coefs'")
				Wave PeakDataCoefSig=$("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber)+":'Peak "+num2str(i)+" Coefseps'")
				Duplicate/O  PeakData, $("Peak "+num2str(i))
				Duplicate/O  PeakData, $("Peak "+num2str(i)+"_d")
				Wave NewDwave=$("Peak "+num2str(i)+"_d")
				NewDwave[] = IR3W_ConvertTTHdataTod(pnt2x(PeakData, p ),Wavelength)
				Duplicate/O  PeakDataCoefs, $("Peak "+num2str(i)+" Coefs")
				Duplicate/O  PeakDataCoefSig, $("Peak "+num2str(i)+" Coefseps")
			endif
		endfor
		setDataFolder OldDf
		DoUpdate
		DoWindow $("MPF2_ResultsPanel_"+num2str(MPF2CurrentFolderNumber))
		if(V_Flag)
			DoWIndow/K $("MPF2_ResultsPanel_"+num2str(MPF2CurrentFolderNumber))
		endif
	SetDataFolder Oldf
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3W_TabDelimitedResultsBtnProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode != 2)		// mouse-up in the control
		return 0
	endif
	
//	NVAR currentSetNumber = root:Packages:MultiPeakFit2:currentSetNumber
//	String gname = WinName(0,1)
	Variable setNumber = IR3W_GetSetNumberFromWinName(s.win)
	String DFpath = IR3W_FolderPathFromSetNumber(setNumber)
	String saveDF = GetDataFolder(1)
	SetDataFolder DFpath
	SVAR gname = GraphName
	
	String nb = "MultipeakSet"+num2str(setNumber)+"_TD"
	if (WinType(nb) == 5)
		DoWindow/F $nb
	else
		NewNotebook/F=0/K=1/N=$nb
	endif
	String/G MPF2_TDReportName = nb
	Notebook $nb defaultTab=108
	
	Wave wpi = W_AutoPeakInfo
	Variable npeaks = DimSize(wpi, 0)
	
	Variable i, nParamsMax=0
	Variable j
	Variable theRow
	String PeakTypeName
	String ParamNames
	String DerivedParamNames
	
	SVAR YWvName = $(DFpath+":YWvName")
	SVAR XWvName = $(DFpath+":XWvName")
	Wave yw = $YWvName
	Wave/Z xw = $XWvName
	NVAR XPointRangeBegin
	NVAR XPointRangeEnd
	NVAR MPF2_FitDate
	NVAR MPF2_FitPoints
	NVAR MPF2_FitChiSq
	SVAR WAXSDataFolderName = root:Packages:Irena:WAXS:DataFolderName
	SVAR IntensityWaveName = root:Packages:Irena:WAXS:IntensityWaveName
	SVAR QWaveName = root:Packages:Irena:WAXS:QWaveName

	Notebook $nb selection={endOfFile,endOfFile}
	Notebook $nb text="Fit on data : "+WAXSDataFolderName+"\r"
	Notebook $nb text="Fit completed "+Secs2Time(MPF2_FitDate, 0)+" "+Secs2Date(MPF2_FitDate, 1)+"\r"
	
	Notebook $nb text="Y data wave: "+IntensityWaveName
	if ( (XPointRangeBegin != 0) || (XPointRangeEnd != numpnts(yw)-1) )
		Notebook $nb text="["+num2str(XPointRangeBegin)+", "+num2str(XPointRangeEnd)+"]"
	endif
	Notebook $nb text="\r"
	
	if (WaveExists(xw))
		Notebook $nb text="X data wave: "+QWaveName+"\r"
	endif
	
	Notebook $nb text="Chi square: "+num2str(MPF2_FitChiSq)+"\r"
	Notebook $nb text="Total fitted points: "+num2str(MPF2_FitPoints)+"\r"

	Notebook $nb text="Multi-peak fit version "+"Modifed for Irena use"+"\r"

	GetSelection notebook, $nb, 1
	Variable paragraphNumberforTotalArea = V_startParagraph

	Notebook $nb text="\r"
	
	Wave/T MPF2_ResultsListWave

	Notebook $nb text="Type\tLocation\tLocSigma\tAmplitude\tAmpSigma\tArea\tAreaSigma\tFWHM\tFWHMSigma\r"

	Variable numBLParams = 0
	String BL_typename = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, 0) )
	if (CmpStr(BL_typename, "None") != 0)
//		String ParamNameList, BL_FuncName
		FUNCREF MPF2_FuncInfoTemplate blinfo = $(BL_typename + BL_INFO_SUFFIX)
//		ParamNameList = blinfo(BLFuncInfo_ParamNames)
//		BL_FuncName = blinfo(BLFuncInfo_BaselineFName)
		numBLParams = ItemsInList(blinfo(BLFuncInfo_ParamNames))
	endif
	
	Variable totalParams = numBLParams
	String OneParamText
	String oneLine
	
	Variable totalArea = 0
	Variable totalAreaVariance = 0

	for (i = 0; i < npeaks; i += 1)
		oneLine = ""
		
		Wave coefs = $("Peak "+num2istr(i)+" Coefs")
		theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2istr(i))
		PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, theRow) )
		oneLine = PeakTypeName
		
		FUNCREF MPF2_FuncInfoTemplate infoFunc=$(PeakTypeName+PEAK_INFO_SUFFIX)
		ParamNames = infoFunc(PeakFuncInfo_ParamNames)
		Variable nParams = ItemsInList(ParamNames)

		Wave coefs = $("Peak "+num2istr(i)+" Coefs")
		Variable sigmaSequenceNumber = (numBLParams > 0) ? i+1 : i
		Wave sigma = $("W_sigma_"+num2istr(sigmaSequenceNumber))


		MPF2_ResultsListWave[i][0] = "Peak "+num2str(i)
		MPF2_ResultsListWave[i][1] = PeakTypeName
		
		String ParamFuncName = infoFunc(PeakFuncInfo_ParameterFunc)
		if (strlen(ParamFuncName) > 0)
			FUNCREF MPF2_ParamFuncTemplate paramFunc=$ParamFuncName
			Wave M_covar
			Make/O/D/N=(nParams, nParams) MPF2_TempCovar
			Make/O/D/N=(4,2) MPF2_TempParams=NaN			// initialize to blanks so that if the function doesn't exist, we just get blanks back- the template function doesn't do anything.
			MPF2_TempCovar[][] = M_covar[totalParams+p][totalParams+q]
			paramFunc(coefs, MPF2_TempCovar, MPF2_TempParams)
			
			totalArea += MPF2_TempParams[2][0]				// area is always in row 2
			totalAreaVariance += MPF2_TempParams[2][1]^2
			
			// the first four parameters are always the same and the names are always in the column titles
			for (j = 0; j < 4; j += 1)
				sprintf OneParamText, "\t%g\t%g", MPF2_TempParams[j][0], MPF2_TempParams[j][1]
				oneLine += OneParamText
			endfor
			Notebook $nb text=oneLine+"\r"
		endif
	
		totalParams += nParams
	endfor
	
	Notebook $nb, selection={(paragraphNumberforTotalArea, 0), (paragraphNumberforTotalArea, 0)}
	Notebook $nb, text = "Total Peak Area = "+num2str(totalArea)+" +/- "+num2str(sqrt(totalAreaVariance))+"\r"
	Notebook $nb selection={endOfFile,endOfFile}
	Notebook $nb text="\r"
	Notebook $nb text="\r"
	
	SetDataFolder saveDF
End
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Static Function IR3W_GetSetNumberFromWinName(windowName)
	String windowName
	
	String windowWithData
	
	Variable poundPos = strsearch(windowName, "#", 0)
	if (poundPos < 0)
		windowWithData = windowName
	else
		poundPos = strsearch(windowName, "#", poundPos+1)
		if (poundPos < 0)
			windowWithData = windowName
		else
			windowWithData = windowName[0,poundPos-1]
		endif
	endif
	
	return str2num(GetUserData(windowWithData, "", "MPF2_DataSetNumber"))
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function/S IR3W_FolderPathFromSetNumber(setnumber)
	Variable setnumber
	
	return "root:Packages:MultiPeakFit2:"+IR3W_FolderNameFromSetNumber(setnumber)
end
static Function/S IR3W_FolderNameFromSetNumber(setnumber)
	Variable setnumber
	
	return "MPF_SetFolder_"+num2str(setnumber)
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
// ********* Jans Polynomial BASELINE *********
Function/S WAXSPoly10_BLFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""

	switch(InfoDesired)
		case BLFuncInfo_ParamNames:
			info = "Const;Lin;Sqr;Cub;4th;5th;6th;7th;8th;9th;"
			break;
		case BLFuncInfo_BaselineFName:
			info = "WAXSPoly10_BLFunc"
			break;
	endswitch

	return info
end
Function WAXSPoly10_BLFunc(s)
	STRUCT MPF2_BLFitStruct &s
	Variable xr = s.xEnd - s.xStart
	Variable x = (2*s.x - (s.xStart + s.xEnd))/xr
	return poly(s.cWave, x)
end
static Function IR3W_isMonotonic(wx)
	Wave wx	
	Variable smallestXIncrement
	Variable isMonotonic=0
	Duplicate/O/Free wx, diff
	Differentiate/DIM=0/EP=0/METH=1/P diff 
	WaveStats/Q/M=0 diff
	isMonotonic= (V_min >= 0) == (V_max >= 0)
	return isMonotonic
End
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3W_GraphHookFunction(H_Struct)
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
	if(stringmatch(subWinName,"IR3W_WAXSMainGraph"))
		if(stringmatch(GetRTStackInfo(3),"*IR3W_GraphWAXSData*"))
			return 0
		else
			NVAR DataTTHstart = root:Packages:Irena:WAXS:DataTTHstart
			NVAR DataTTHEnd = root:Packages:Irena:WAXS:DataTTHEnd
			if(stringmatch(cursorName,"A")&&stringmatch(H_Struct.eventName,"cursormoved"))
				WAVE OriginalData2ThetaWave = root:Packages:Irena:WAXS:OriginalData2ThetaWave
				if(!stringmatch(H_Struct.traceName,"OriginalDataIntWave"))
					cursor /W=IR3W_WAXSMainGraph A, OriginalDataIntWave, 1
					DataTTHstart = OriginalData2ThetaWave[1]
					Print "A cursor must be on OriginalDataIntWave and at least on second point from start"
				else		//on correct wave...
					if(H_Struct.pointNumber==0)			//bad point, needs to be at least 1
						cursor /W=IR3W_WAXSMainGraph A, OriginalDataIntWave, 1
						DataTTHstart = OriginalData2ThetaWave[1]
						Print "A cursor must be on OriginalDataIntWave and at least on second point from the start"
					else
						DataTTHstart = OriginalData2ThetaWave[H_Struct.pointNumber]
					endif
				endif
			endif
			if(stringmatch(cursorName,"B")&&stringmatch(H_Struct.eventName,"cursormoved"))
				WAVE OriginalData2ThetaWave = root:Packages:Irena:WAXS:OriginalData2ThetaWave
				WAVE OriginalDataIntWave = root:Packages:Irena:WAXS:OriginalDataIntWave
				if(!stringmatch(H_Struct.traceName,"OriginalDataIntWave"))
					cursor /W=IR3W_WAXSMainGraph B, OriginalData1IntWave, numpnts(OriginalDataIntWave)-2
					DataTTHEnd = OriginalData2ThetaWave[numpnts(OriginalDataIntWave)-2]
					Print "B cursor must be on OriginalData1IntWave and at least on second point from the end"
				else		//on correct wave...
					if(H_Struct.pointNumber==0)			//bad point, needs to be at least 1
						cursor /W=IR3W_WAXSMainGraph B, OriginalDataIntWave, numpnts(OriginalDataIntWave)-2
						DataTTHEnd = OriginalData2ThetaWave[numpnts(OriginalDataIntWave)-2]
						Print "B cursor must be on OriginalData1IntWave and at least on second point from the end"
					else
						DataTTHEnd = OriginalData2ThetaWave[H_Struct.pointNumber]		
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

Window IR3W_WAXS_MPFPlots() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(625,232,1066,702) as "PowderMPF2 DIff/WAXS plots"
	DoWIndow/C IR3W_WAXS_MPFPlots
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 3,textrgb= (0,0,65535)
	TitleBox MainTitle title="Plots for MPF2 results",pos={100,10},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={250,30},fSize=22,fColor=(0,0,52224)
	TitleBox Info1 title="Plot Individual Peak Profiles",pos={60,75},frame=0,fstyle=1, fixedSize=1,font= "Times New Roman", size={200,20},fSize=15,fColor=(0,0,52224)
	
	PopupMenu MPF2PlotFolderStart, pos={10,50},size={180,15},proc=IR3W_PopMenuProc,title="Folder with Data"
	PopupMenu MPF2PlotFolderStart,mode=1,popvalue=root:Packages:Irena:WAXS:MPF2PlotFolderStart,value= #"IN2G_CreateListOfItemsInFolder(\"root:WAXSFitResults\",1)"

	PopupMenu MPF2PlotPeakProfile, pos={20,100},size={200,15},proc=IR3W_PopMenuProc,title="Selected Peak"
	PopupMenu MPF2PlotPeakProfile,mode=1,popvalue=root:Packages:Irena:WAXS:MPF2PlotPeakProfile,value= #"IR3W_PlotUpdateListsOfResults(\"Peak Profiles\")"
	
	Button MPF2PlotPeakGraph, pos={50,130}, size={250,20}, title="Graph above of selected Peaks profiles", proc=IR3W_WAXSButtonProc, help={"Create graph of selected peaks"}
	Button MPF2PlotPeakParams, pos={50,158}, size={250,20}, title="Graph above selected Peaks parameters", proc=IR3W_WAXSButtonProc, help={"Create graph of selected peaks parameters"}
	
EndMacro


//**************************************************************************************
//**************************************************************************************
Function/S IR3W_PlotUpdateListsOfResults(ReturnWhat)
	string ReturnWhat

	string OldDF=GetDataFolder(1)
	setDataFolder root:WAXSFitResults
	SVAR MPF2PlotFolderStart = root:Packages:Irena:WAXS:MPF2PlotFolderStart
	string AllResults=IN2G_CreateListOfItemsInFolder(MPF2PlotFolderStart,1)
	string TestFOlder = StringFromList(0, AllResults, ";")
	string AllResultsWaxs = IN2G_CreateListOfItemsInFolder("root:WAXSFitResults:"+MPF2PlotFolderStart+":"+possiblyQuoteName(TestFOlder),2)
	 
	//print 	AllResultsWaxs
	string result
	result=""
	if(stringmatch(ReturnWhat,"Peak Profiles"))
		result = GrepList(AllResultsWaxs, "Peak [0-9]$" )
	elseif(stringmatch(ReturnWhat,"Peak Profiles Coeficients"))
		result = GrepList(AllResultsWaxs, "Peak [0-9] (Coefs)$" )
	elseif(stringmatch(ReturnWhat,"Peak Profiles Coeficients EPS"))
		result = GrepList(AllResultsWaxs, "Peak [0-9] (Coefseps)$" )
//	elseif(stringmatch(ReturnWhat,"Peak Profiles Coeficients EPS"))
//		result = GrepList(AllResultsWaxs, "Peak [0-9] (Coefseps)$" )
	endif
//	print result
	setDataFolder OldDF
	return result
end
//**************************************************************************************
//**************************************************************************************


Function IR3W_MPF2PlotPeakGraph()
	string OldDF=GetDataFolder(1)
	SVAR MPF2PlotFolderStart = root:Packages:Irena:WAXS:MPF2PlotFolderStart
	SVAR MPF2PlotPeakProfile = root:Packages:Irena:WAXS:MPF2PlotPeakProfile
	string StartFolder = "root:WAXSFitResults:"+MPF2PlotFolderStart
	Display /K=1/W=(386,292,1042,715) as "MPF2 "+MPF2PlotPeakProfile+" Profile Plot"
	string NewGraphName=WinName(0, 1)	
	IN2G_UniversalFolderScan(StartFolder, 2, "IR3W_MPF2AppendDataToGraph(\""+NewGraphName+"\",\""+ MPF2PlotPeakProfile+"\")")
	DoUpdate
	if(strlen(AxisInfo(NewGraphName, "left" ))<1)
		return 0
	endif
	Label/W=$(NewGraphName) left "Intensity"
	Label/W=$(NewGraphName) bottom "d [A]"
	DoWindow/F $(NewGraphName)
	IN2G_ColorTopGrphRainbow()
	IN2G_LegendTopGrphFldr(10)
	setDataFolder OldDF
end
Function IR3W_MPF2AppendDataToGraph(GraphName, DataWvName)
	string GraphName, DataWvName
	Wave/Z WaveToAppend=$(DataWvName)
	Wave/Z WaveToAppendD=$(DataWvName+"_d")
	if(WaveExists(WaveToAppend) & WaveExists(WaveToAppendD))
		DoWindow $(GraphName)
		if(V_Flag)
			AppendToGraph WaveToAppend vs WaveToAppendD
		endif
	endif
	
end
//**************************************************************************************
//**************************************************************************************

Function IR3W_MPF2PlotPeakParameters()
	string OldDF=GetDataFolder(1)
	string NewGraphName
	SVAR MPF2PlotFolderStart = root:Packages:Irena:WAXS:MPF2PlotFolderStart
	SVAR MPF2PlotPeakProfile = root:Packages:Irena:WAXS:MPF2PlotPeakProfile
	string StartFolder = "root:WAXSFitResults:"+MPF2PlotFolderStart
      	if (stringmatch(":", StartFolder[strlen(StartFolder)-1,strlen(StartFolder)-1] )!=1)
        		StartFolder=StartFolder+":"
     	endif
	string AllResults=IN2G_CreateListOfItemsInFolder(StartFolder,1)
	string TestFolder = StringFromList(0, AllResults, ";")
	SetDataFolder $("root:WAXSFitResults:"+MPF2PlotFolderStart)
	//root:WAXSFitResults:Test1:'Inconel718_1066C_629._C':'Peak 0 Coefs'
	Wave/Z testWv = $("root:WAXSFitResults:"+MPF2PlotFolderStart+":"+possiblyQuoteName(TestFOlder)+":"+possiblyQuoteName(MPF2PlotPeakProfile+" Coefs"))
	if(!WaveExists(testWv))
		abort "No parameters data found"
	endif
	variable i, NumGraphs=3	
	string TmpName
	WAVE/Z ParamWv = $(StartFolder+possiblyquotename(MPF2PlotPeakProfile+"_Params"))
	WAVE/Z/T ParamLabels = $(StartFolder+possiblyquotename(MPF2PlotPeakProfile+"_Labels"))
	KillWaves/Z ParamWv, ParamLabels
	IN2G_UniversalFolderScan(StartFolder, 2, "IR3W_MPF2ExtractParamsToGraph(\""+GetDataFolder(1)+"\",\""+ MPF2PlotPeakProfile+"\")")
	WAVE/Z ParamWv = $(StartFolder+possiblyquotename(MPF2PlotPeakProfile+"_Params"))
	WAVE/Z/T ParamLabels = $(StartFolder+possiblyquotename(MPF2PlotPeakProfile+"_Labels"))
	make/O/N=(numpnts(ParamLabels)) $(StartFolder+possiblyquotename(MPF2PlotPeakProfile+"_LabelLocs"))
	WAVE/Z LabelLocs = $(StartFolder+possiblyquotename(MPF2PlotPeakProfile+"_LabelLocs"))
	LabelLocs = p
	if(!WaveExists(ParamWv))
		abort
	endif
	For(i=0;i<NumGraphs;i+=1)
		Display /K=1/W=(386,292,1042,715) as "MPF2 "+MPF2PlotPeakProfile+" Parameter "+num2str(i)+" Plot"
		AppendToGraph ParamWv[*][2*i]
	 	NewGraphName=WinName(0, 1)	
		TmpName = stringFromList(0,TraceNameList(NewGraphName, ";", 1 ))
		ErrorBars $(TmpName) Y,wave=(ParamWv[*][1],ParamWv[*][1])
		ModifyGraph userticks(bottom)={LabelLocs,ParamLabels}
		ModifyGraph tkLblRot(bottom)=90
		ModifyGraph mode=3
		switch(i)	// numeric switch
			case 0:		// execute if case matches expression
				Label/W=$(NewGraphName) left "Angle [deg]"
				Label/W=$(NewGraphName) bottom "Sequence"
				break					// exit from switch
			case 1:		// execute if case matches expression
				Label/W=$(NewGraphName) left "Width [deg]"
				Label/W=$(NewGraphName) bottom "Sequence"
				break
			case 2:		// execute if case matches expression
				Label/W=$(NewGraphName) left "Area"
				Label/W=$(NewGraphName) bottom "Sequence"
				break
			default:							// optional default expression executed
				Label/W=$(NewGraphName) left " "
				Label/W=$(NewGraphName) bottom " "
		endswitch
		DoWindow/F $(NewGraphName)
		//IN2G_ColorTopGrphRainbow()
		IN2G_LegendTopGrphFldr(10)
	endfor
	SetDimLabel 1,0,Angle,ParamWv
	SetDimLabel 1,1,AngleESD,ParamWv
	SetDimLabel 1,2,Width,ParamWv
	SetDimLabel 1,3,WidthESD,ParamWv
	SetDimLabel 1,4,Height,ParamWv
	SetDimLabel 1,5,HeightESD,ParamWv

	Edit/K=1/W=(335,384,1274,710) ParamLabels, ParamWv as "MPF2 "+MPF2PlotPeakProfile+" Parameter Listing "
	ModifyTable format(Point)=1,width(ParamLabels)=172,title(ParamLabels)="Sample Name"
	ModifyTable width(ParamWv)=92
	ModifyTable showParts=0x76
	ModifyTable horizontalIndex=2
	setDataFolder OldDF
end
Function IR3W_MPF2ExtractParamsToGraph(StartFolder, DataWvName)
	string StartFolder, DataWvName

	variable NumGraphs, i

	Wave/Z WaveToAppend=$((DataWvName+" Coefs"))
	if(!WaveExists(WaveToAppend))
		return 0
	endif	
	Wave/Z WvErsToAppend=$((DataWvName+" Coefseps"))
	NumGraphs = numpnts(WaveToAppend)
	variable curLength=0
	
	WAVE/Z wv0 = $(StartFolder+possiblyquotename(DataWvName+"_Params"))
	WAVE/Z/T wvT = $(StartFolder+possiblyquotename(DataWvName+"_Labels"))
	if(!WaveExists(wv0))
		make/O/N=(0,6) $(StartFolder+possiblyquotename(DataWvName+"_Params"))
		make/O/N=(0)/T $(StartFolder+possiblyquotename(DataWvName+"_Labels"))
		WAVE wv0 = $(StartFolder+possiblyquotename(DataWvName+"_Params"))
		WAVE/T wvT = $(StartFolder+possiblyquotename(DataWvName+"_Labels"))
	endif
	curLength = numpnts(wvT)	
	redimension/N=(curLength+1,6) wv0
	redimension/N=(curLength+1)  wvT
	wv0[curLength][0] =WaveToAppend[0]
	wv0[curLength][1] =WvErsToAppend[0]
	wv0[curLength][2] =WaveToAppend[1]
	wv0[curLength][3] =WvErsToAppend[1]
	wv0[curLength][4] =WaveToAppend[2]
	wv0[curLength][5] =WvErsToAppend[2]
	wvT[curLength] = GetDataFOlder(0)
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3W_PDF4AddManually()
	string OldDf=GetDataFolder(1)
	string NewCardFullName
	DoWIndow JCPDS_Input
	if(V_Flag)
		DoWIndow/K JCPDS_Input
	endif
	NewDataFolder/O/S root:JCPDS_PDF4
	string OldCardName, NewCardNumber, NewCardName, NewCardNote, DeleteCardName
	DeleteCardName="---"
	OldCardName = "---"
	NewCardNumber = "11-1111"
	NewCardName="Unknown"
	NewCardNote =""
	Prompt DeleteCardName, "Delete card?", popup "---;"+IN2G_CreateListOfItemsInFolder("root:JCPDS_PDF4:", 2)
	Prompt OldCardName, "Select existing card to edit", popup "---;"+IN2G_CreateListOfItemsInFolder("root:JCPDS_PDF4:", 2)
	Prompt NewCardNumber, "Enter new card number, e.g. 46-1212"
	Prompt NewCardName, "Enter new card name, e.g. Corundum"
	Prompt NewCardNote, "Enter new card note, whatever you may need later"
	DoPrompt "What to do: 1. Delete, 2. Modify, or 3. Create new Card? ", DeleteCardName, OldCardName, NewCardNumber, NewCardName, NewCardNote
	if(V_Flag)
		setDataFolder OldDf
		return 0
	endif
	if(stringmatch(OldCardName,"---")&&stringmatch(DeleteCardName,"---"))
		NewCardFullName=((NewCardNumber+"_"+NewCardName)[0,30])
		if(CheckName(NewCardFullName,1)!=0)
			setDataFolder OldDf
			DoAlert 0, "Not unique name"	
			return 0
		endif
		make/O/N=(50,5) $(NewCardFullName)
		Wave NewCard= $(NewCardFullName)
		SetDimLabel 1,0,d_A,NewCard
		SetDimLabel 1,1,Intensity,NewCard
		SetDimLabel 1,2,h,NewCard
		SetDimLabel 1,3,k,NewCard
		SetDimLabel 1,4,l,NewCard
	elseif(!stringmatch(OldCardName,"---")&&stringmatch(DeleteCardName,"---"))
		NewCardFullName=OldCardName
		Wave NewCard= $(NewCardFullName)
	elseif(stringmatch(OldCardName,"---")&&!stringmatch(DeleteCardName,"---"))
		NewCardFullName=DeleteCardName
		Wave NewCard= $(NewCardFullName)
		DoALert/T="Check deleting card" 1, "Really delete "+DeleteCardName+" card?" 
		if(V_Flag)
			KillWaves NewCard
			setDataFolder OldDf
			return 0
		endif
	else
		Print "Could not figure out what to do..."
	endif
	Edit/K=1/W=(351,213,873,819) NewCard
	DoWindow/C/R JCPDS_Input
	ModifyTable format(Point)=1
	ModifyTable horizontalIndex=2
	ModifyTable showParts=0xFD
	
	setDataFolder OldDf
end
//**************************************************************************************
//**************************************************************************************

Function IR3W_UpdatePDF4OfAvailFiles()
	string OldDF=GetDataFolder(1)
	string AvailableCards=""
	if(DataFolderExists("root:JCPDS_PDF4" ))
		setDataFolder root:JCPDS_PDF4
		AvailableCards=ReplaceString(";\r", stringfromList(1,DataFolderDir(2 ),":"), "") +","
	endif
	string TempStr

	Wave/T ListOfAvailableData=root:Packages:Irena:WAXS:ListOfPDF4Data
	Wave SelectionOfAvailableData=root:Packages:Irena:WAXS:SelectionOfPDF4Data
	Wave/Z ListOfPDF4DataColors = root:Packages:Irena:WAXS:ListOfPDF4DataColors
	if(!WaveExists(ListOfPDF4DataColors))
		make/O/N=(0,3) ListOfPDF4DataColors
	endif
	variable i, j, match
	Redimension/N=(ItemsInList(AvailableCards , ","),1) ListOfAvailableData
	Redimension/N=(ItemsInList(AvailableCards , ","),1,2) SelectionOfAvailableData
	Redimension/N=(ItemsInList(AvailableCards , ","),3) ListOfPDF4DataColors
	For(i=0;i<ItemsInList(AvailableCards , ",");i+=1)
		TempStr =  StringFromList(i, AvailableCards , ",")
		if(strlen(TempStr)>0)
			ListOfAvailableData[i] = tempStr
		endif
	endfor
	SelectionOfAvailableData[][][0] = 0x20
	SelectionOfAvailableData[][][1] = p
	setDataFolder OldDF
end

//**************************************************************************************
//**************************************************************************************

Function IR3W_PDF4ListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable/g row = lba.row
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave
	Wave/Z ListOfPDF4DataColors = root:Packages:Irena:WAXS:ListOfPDF4DataColors
	string FoldernameStr
	Variable isData1or2
	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
			if (lba.eventMod & 0x10)			// Right-click?
				row = lba.row
				PopupContextualMenu/N "IR3W_ColorWaveEditorMenu"
				if( V_flag < 0 )
					Print "User did not select anything"
				else
					ListOfPDF4DataColors[row][0]=V_Red
					ListOfPDF4DataColors[row][1]=V_Green
					ListOfPDF4DataColors[row][2]=V_Blue
					//ListOfPDF4DataColors[row][3]=V_Alpha
					IR3W_PDF4AddLines()
				endif
			endif
			break
		case 3: // double click
		//	FoldernameStr=listWave[row]
		//	IR3W_CopyAndAppendData(FoldernameStr)
			break
		case 4: // cell selection
		case 5: // cell selection plus shift key
			break
		case 6: // begin edit
			break
		case 7: // finish edit
			break
		case 13: // checkbox clicked (Igor 6.2 or later)
			IR3W_PDF4AddLines() 
			break
	endswitch

	return 0
End
//***
Menu "IR3W_ColorWaveEditorMenu",contextualmenu
	"*COLORPOP*(65535,0,0)", ;	// initially red, no execution command
	//"Edit Card", IR3W_EditJCPDSCard()
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3W_PDF4AddLines()

	Wave/T listWave=root:Packages:Irena:WAXS:ListOfPDF4Data
	Wave selWave=root:Packages:Irena:WAXS:SelectionOfPDF4Data
	Wave ListOfPDF4DataColors = root:Packages:Irena:WAXS:ListOfPDF4DataColors
	string WvName
	variable i, minX, maxX
	DoWIndow IR3W_WAXSMainGraph
	if(!V_Flag)
		abort
	endif
	GetAxis /W=IR3W_WAXSMainGraph/Q bottom
	minX=V_min
	maxX=V_max
	For(i=0;i<numpnts(listWave);i+=1)
		if(selWave[i][0][0]>40)		//unselected is 32, selected is 48
			WvName = listWave[i]
			RemoveFromGraph /W=IR3W_WAXSMainGraph /Z $(WvName)
			IR3W_PDF4AppendLinesToGraph(listWave[i][0],ListOfPDF4DataColors[i][0], ListOfPDF4DataColors[i][1],ListOfPDF4DataColors[i][2])
		else 		//remove if needed...
			WvName = listWave[i][0]
			RemoveFromGraph /W=IR3W_WAXSMainGraph /Z $(WvName)
		endif
	endfor
	SetAxis /W=IR3W_WAXSMainGraph  bottom , minX, maxX
end
//**************************************************************************************
//**************************************************************************************

Function IR3W_PDF4AppendLinesToGraph(CardName, V_Red, V_Green, V_Blue)
	string cardname
	variable V_Red, V_Green, V_Blue
	
	string OldDf=GetDataFolder(1)
	NVAR  Wavelength = root:Packages:Irena:WAXS:Wavelength
	wave TheCard=$("root:JCPDS_PDF4:"+possiblyquotename(CardName))
	NewDataFolder/O/S root:Packages:Irena:WAXSTemp
	Duplicate/O TheCard, $(CardName)
	Wave TheCardNew = $((CardName))
	TheCardNew[][0] =   114.592 * asin((2 * pi / TheCard[p][0])* wavelength / (4*pi))
	SetDimLabel 1,0,TTh,TheCardNew
	Wave OriginalDataIntWave = root:Packages:Irena:WAXS:OriginalDataIntWave
	//wavestats/Q OriginalDataIntWave
	GetAxis /W=IR3W_WAXSMainGraph /Q left
	TheCardNew[][1] = V_min + TheCardNew[p][1] * (V_Max-V_min)/100
	AppendToGraph/W=IR3W_WAXSMainGraph TheCardNew[][1] vs TheCardNew[][0]
	string WvName=possiblyquotename(NameOfWave(TheCardNew ))
	ModifyGraph mode($(WvName))=1,usePlusRGB($(WvName))=1, lsize($(WvName))=3
	ModifyGraph plusRGB($(WvName))=(V_Red, V_Green, V_Blue)	
	setDataFolder oldDf
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************