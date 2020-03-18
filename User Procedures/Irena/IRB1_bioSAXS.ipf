#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=0.1
#pragma IgorVersion = 8.03


//*************************************************************************\
//* Copyright (c) 2005 - 2020, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/
constant IRB1_ImportBioSAXSASCIIDataVersion = 0.1			//IRB1_ImportBioSAXSASCIIData tool version number. 
constant IRB1_DataManipulation = 0.1			//IRB1_ImportBioSAXSASCIIData tool version number. 


//functions for bioSAXS community
//
//version summary
//0.1 early beta version

//Contains these main parts:
//Import ASCII data: 	IRB1_ImportASCII()
//Avergae data and other data manipulations : IRB1_DataManipulation()




//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//				This is customized BioSAXS Import ASCII
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//todo: 
//add scaling controls
//check capcilities and add any needed fixes on data
//fix manual link (aka: vrite manual)
//fix version control and restarting, add to kill function
//fix any bugs and functionality... 
Function IRB1_ImportASCII()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IN2G_CheckScreenSize("height",720)
	DoWindow IR1I_ImportBioSAXSASCIIData
	if(V_Flag)
		DoWindow/F IR1I_ImportBioSAXSASCIIData
	else
		//intit first
		//need to create panel
		IRB1_InitializeImportData()
		IRB1_ImportBioSAXSASCIIDataFnct()
		ING2_AddScrollControl()
		IR1_UpdatePanelVersionNumber("IRB1_ImportBioSAXSASCIIData", IRB1_ImportBioSAXSASCIIDataVersion,1)
	endif
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//				This is customized BioSAXS Data manipulation package
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//todo: 
//add options to use different error propagation, for nwo uses Errro rpopagation
//	UseStdDev = 0
//	UseSEM = 0 
//	PropagateErrors = 1

Function IRB1_DataManipulation()

	IN2G_CheckScreenSize("width",1200)
	DoWIndow IRB1_DataManipulationPanel
	if(V_Flag)
		DoWindow/F IRB1_DataManipulationPanel
	else
		IRB1_DataManInitBioSAXS()
		IRB1_DataManPanelFnct()
//		setWIndow IR3J_SimpleFitsPanel, hook(CursorMoved)=IR3D_PanelHookFunction
		IR3C_MultiUpdateListOfAvailFiles("root:Packages:Irena:BioSAXSDataMan")
		ING2_AddScrollControl()
		IR1_UpdatePanelVersionNumber("IRB1_DataManipulationPanel", IRB1_DataManipulation,0)
	endif
end



//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//				Part of customized BioSAXS Import ASCII
//************************************************************************************************************

Function IRB1_ImportBioSAXSASCIIDataFnct() 
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(3,40,430,760)/N=IRB1_ImportBioSAXSASCIIData as "Import Bio SAXS data"
	TitleBox MainTitle title="\Zr200Import bioSAXS ASCII Data in Igor",pos={20,5},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={400,24},anchor=MC,fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,40},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	IR3C_AddDataControls("ImportDataPath", "Irena:ImportBioSAXSData", "IRB1_ImportBioSAXSASCIIData","dat", "","","IR1I_DoubleClickFUnction")
	ListBox ListOfAvailableData,size={220,477}, pos={5,113}
	Button SelectAll,pos={5,595}
	Button DeSelectAll, pos={120,595}
	PopupMenu SortOptionString pos={250,120}

	CheckBox SAXSData,pos={250,160},size={16,14},proc=IRB1_CheckProc,title="SAXS data?",variable= root:Packages:Irena:ImportBioSAXSData:SAXSData,mode=1, help={"Check if these are SAXS data..."}
	CheckBox WAXSdata,pos={250,180},size={16,14},proc=IRB1_CheckProc,title="WAXS data data?",variable= root:Packages:Irena:ImportBioSAXSData:WAXSdata,mode=1, help={"Check if these are WAXS data..."}
//	SetVariable SkipNumberOfLines,pos={300,133},size={70,19},proc=IR1I_SetVarProc,title=" "
//	SetVariable SkipNumberOfLines,help={"Insert number of lines to skip"}
//	NVAR DisableSkipLines=root:Packages:ImportData:SkipLines
//	SetVariable SkipNumberOfLines,variable= root:Packages:ImportData:SkipNumberOfLines, disable=(!DisableSkipLines)
//
	Button Preview,pos={280,370},size={80,20}, proc=IRB1_ButtonProc,title="Preview"
	Button Preview,help={"Preview selected file."}
	Button ImportSelectedData,pos={230,400},size={180,20}, proc=IRB1_ButtonProc,title="Import Selected Data"
	Button ImportSelectedData,help={"Test how if import can be succesful and how many waves are found"}
	Button GetHelp,pos={335,50},size={80,15},fColor=(65535,32768,32768), proc=IRB1_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}
////
////
////
//	SetVariable FoundNWaves,pos={239,296},size={160,19},title="Found cols.:  ",proc=IR1I_SetVarProc
//	SetVariable FoundNWaves,help={"This is how many columns were found in the tested file"}, disable=2
//	SetVariable FoundNWaves,limits={0,Inf,0},value= root:Packages:ImportData:FoundNWaves
//
//	Button Plot,pos={330,317},size={80,15}, proc=IR1I_ButtonProc,title="Plot"
//	Button Plot,help={"Preview selected file."}
//

end
//************************************************************************************************************
//************************************************************************************************************
//				Part of customized BioSAXS Import ASCII
//************************************************************************************************************


Function IRB1_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR SAXSdata= root:Packages:Irena:ImportBioSAXSData:SAXSData
			NVAR WAXSData= root:Packages:Irena:ImportBioSAXSData:WAXSData
			if(stringmatch(cba.ctrlname,"SAXSData"))
				SAXSdata = checked
				WAXSData = !checked
			endif
			if(stringmatch(cba.ctrlname,"WAXSData"))
				SAXSdata = !checked
				WAXSData = checked
			endif
			if(stringmatch(cba.ctrlname,"DisplayErrorBars"))
				pauseUpdate
				NVAR DisplayErrorBars = root:Packages:Irena:BioSAXSDataMan:DisplayErrorBars
				IN2G_ShowHideErrorBars(DisplayErrorBars, topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
				DoUpdate
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************
//************************************************************************************************************
//				Part of customized BioSAXS Import ASCII
//************************************************************************************************************


Function IRB1_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"ImportSelectedData"))
				IRB1_ImportDataFnct()		
			endif
			if(stringmatch(ba.ctrlName,"Preview"))
				IRB1_PreviewDataFnct()
			endif
			if(stringmatch(ba.ctrlName,"GetHelp"))
					IN2G_OpenWebManual("Irena/ImportData.html")				//fix me!!			
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************
//************************************************************************************************************
//				Part of customized BioSAXS Import ASCII
//************************************************************************************************************
Function IRB1_ImportDataFnct()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	string TopPanel=WinName(0, 64)
	string OldDf = getDataFolder(1)
	
	Wave/T WaveOfFiles    = root:Packages:Irena:ImportBioSAXSData:WaveOfFiles
	Wave WaveOfSelections = root:Packages:Irena:ImportBioSAXSData:WaveOfSelections
	NVAR SAXSdata= root:Packages:Irena:ImportBioSAXSData:SAXSData
	NVAR WAXSData= root:Packages:Irena:ImportBioSAXSData:WAXSData
	PathInfo ImportDataPath
	string DataSelPathString=S_path
	if(SAXSdata)
		NewDataFOlder/O/S root:SAXS
	elseif(WAXSdata)
		NewDataFOlder/O/S root:WAXS
	else
		NewDataFOlder/O/S root:ImportedData
	endif
	string BaseFolder = getDataFolder(1)
	variable i, imax, icount
	string SelectedFile
	string SelectedFileName
	string SelectedSampleName
	string NewNote
	imax = numpnts(WaveOfSelections)
	icount = 0
	for(i=0;i<imax;i+=1)
		if (WaveOfSelections[i])
			NewNote=""
			setDataFolder BaseFolder
			selectedfile = WaveOfFiles[i]
	 		SelectedFileName = RemoveEnding(RemoveListItem(ItemsInList(selectedfile,".")-1, selectedfile,"."),".")
	 		//now make assumption about sample name
	 		SelectedSampleName = RemoveEnding(RemoveListItem(ItemsInList(selectedfile,"_")-1, selectedfile,"_"),"_")
	 		SelectedSampleName = CleanupName(SelectedSampleName,1)
	 		SelectedFileName = CleanupName(SelectedFileName, 1)
			//create and move into the SampleFolder
			if(strlen(SelectedSampleName)>1)		//cases, when name cannot be deduced in above level. 
				NewDataFolder/O/S $((SelectedSampleName))
			endif
			//now folder for the specific imported ASCII file
			NewDataFolder/O/S $((SelectedFileName))
			KillWaves/Z wave0, wave1, wave2
			LoadWave/Q/A/D/G/P=ImportDataPath  selectedfile
			Wave wave0
			Wave wave1
			Wave wave2
			Rename wave0, $(PossiblyQuoteName("q_"+SelectedFileName))
			Rename wave1, $(PossiblyQuoteName("r_"+SelectedFileName))
			Rename wave2, $(PossiblyQuoteName("s_"+SelectedFileName))
			//need to clean upimported waves, if Intensity is 0, point shoudl be removed... 
			Wave Intensity = $(PossiblyQuoteName("r_"+SelectedFileName))
			Wave Qvec = $(PossiblyQuoteName("q_"+SelectedFileName))
			Wave Error = $(PossiblyQuoteName("S_"+SelectedFileName))
			Intensity = Intensity[p]>0 ? Intensity[p] : nan
			IN2G_RemoveNaNsFrom3Waves(Qvec,Intensity,Error)
			NewNote="Imported data;"+date()+";"+time()+";Original File Name="+selectedfile+";Original file location="+DataSelPathString+";"
			Note /K/NOCR Intensity, NewNote
			Note /K/NOCR Qvec, NewNote
			Note /K/NOCR Error, NewNote
			icount+=1
		endif
	endfor
	print "Imported "+num2str(icount)+" data file(s) in total"
	setDataFolder OldDf
end

//************************************************************************************************************
//************************************************************************************************************
//				Part of customized BioSAXS Import ASCII
//************************************************************************************************************
Function IRB1_InitializeImportData()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf = GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:Irena
	NewDataFolder/O/S root:Packages:Irena:ImportBioSAXSData
	
	string ListOfStrings
	string ListOfVariables
	variable i
	
	ListOfStrings = "DataPathName;DataExtension;IntName;QvecName;ErrorName;NewDataFolderName;NewIntensityWaveName;DataTypeToImport;"
	ListOfStrings+="NewQWaveName;NewErrorWaveName;NewQErrorWavename;NameMatchString;TooManyPointsWarning;RemoveStringFromName;"
	ListOfVariables = "UseFileNameAsFolder;UseIndra2Names;UseQRSNames;DataContainErrors;UseQISNames;"
	ListOfVariables += "SAXSData;WAXSdata;"	
//	ListOfVariables += "CreateSQRTErrors;Col1Int;Col1Qvec;Col1Err;Col1QErr;FoundNWaves;"	
//	ListOfVariables += "QvectInA;QvectInNM;QvectInDegrees;CreateSQRTErrors;CreatePercentErrors;PercentErrorsToUse;"
//	ListOfVariables += "ScaleImportedData;ScaleImportedDataBy;ImportSMRdata;SkipLines;SkipNumberOfLines;"	
//	ListOfVariables += "IncludeExtensionInName;RemoveNegativeIntensities;AutomaticallyOverwrite;"	
//	ListOfVariables += "TrimData;TrimDataQMin;TrimDataQMax;ReduceNumPnts;TargetNumberOfPoints;ReducePntsParam;"	
//	ListOfVariables += "NumOfPointsFound;TrunkateStart;TrunkateEnd;Wavelength;"	
//	ListOfVariables += "DataCalibratedArbitrary;DataCalibratedVolume;DataCalibratedWeight;"	


		//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	SVAR TooManyPointsWarning
	TooManyPointsWarning=" "
	
	Make/O/T/N=0 WaveOfFiles
	Make/O/N=0 WaveOfSelections
	
	ListOfVariables = "CreateSQRTErrors;Col1Int;Col1Qvec;Col1Err;Col1QErr;"	
	ListOfVariables += "QvectInNM;CreateSQRTErrors;CreatePercentErrors;"	
	ListOfVariables += "ScaleImportedData;ImportSMRdata;SkipLines;SkipNumberOfLines;UseQISNames;UseIndra2Names;NumOfPointsFound;"	

	NVAR SAXSData
	NVAR WAXSdata
	if(SAXSData+WAXSdata!=1)
		SAXSData=1
		WAXSdata=0
	endif
end
//************************************************************************************************************
//************************************************************************************************************

Function IRB1_PreviewDataFnct()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf = getDataFolder(1)
	
	Wave/T WaveOfFiles    = root:Packages:Irena:ImportBioSAXSData:WaveOfFiles
	Wave WaveOfSelections = root:Packages:Irena:ImportBioSAXSData:WaveOfSelections
	if(sum(WaveOfSelections)<1)
		WaveOfSelections[0]=1
	endif
	variable i, imax, icount
	string SelectedFileName, selectedfile
	SelectedFileName = "TestImport"
	imax = numpnts(WaveOfSelections)	
	newDataFOlder/O/S root:Packages:Irena:Temp
	KillWindow/Z TestImportGraph
	KillWaves/Z q_TestImport, r_TestImport, s_TestImport, wave0, wave1, wave2
	for(i=0;i<imax;i+=1)
		if (WaveOfSelections[i])
			selectedfile = WaveOfFiles[i]
			LoadWave/Q/A/D/G/P=ImportDataPath  selectedfile
			Wave wave0
			Wave wave1
			Wave wave2
			Rename wave0, $(PossiblyQuoteName("q_"+SelectedFileName))
			Rename wave1, $(PossiblyQuoteName("r_"+SelectedFileName))
			Rename wave2, $(PossiblyQuoteName("s_"+SelectedFileName))
			Wave Intensity = $(PossiblyQuoteName("r_"+SelectedFileName))
			Wave Qvec = $(PossiblyQuoteName("q_"+SelectedFileName))
			Wave Error = $(PossiblyQuoteName("S_"+SelectedFileName))
			Display/K=1 /N=TestImportGraph/W=(50, 50, 550,400 ) Intensity vs Qvec as "Test import of "+selectedfile
			ModifyGraph log=1,mirror=1
			Label left "Intensity [arbitrary]"
			Label bottom "Q [1/A]"
			ModifyGraph mode=3
			AutoPositionWindow/R=IRB1_ImportBioSAXSASCIIData TestImportGraph
			setDataFolder OldDf
			return 1
			icount+=1
		endif
	endfor
	setDataFolder OldDf
end
//************************************************************************************************************
//************************************************************************************************************
//				End of customized BioSAXS Import ASCII
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//				Part of customized BioSAXS Data Manipulation package
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IRB1_DataManPanelFnct()
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,1195,800) as "BioSAXS data manipulation"
	DoWIndow/C IRB1_DataManipulationPanel
	TitleBox MainTitle title="BioSAXS data manipulation",pos={140,2},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fSize=22,fColor=(0,0,52224)
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena:BioSAXSDataMan","IRB1_DataManipulationPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	IR3C_MultiAppendControls("Irena:BioSAXSDataMan","IRB1_DataManipulationPanel", "IRB1_DataManAppendOneDataSet",1,0)
	TitleBox Dataselection pos={10,25}
	ListBox DataFolderSelection pos={4,135},size={250,540}
	CheckBox UseIndra2Data disable=3
	CheckBox UseResults disable=3
	CheckBox UseQRSData disable=1
	NVAR UseQRSData = root:Packages:Irena:BioSAXSDataMan:UseQRSData
	NVAR UseResults = root:Packages:Irena:BioSAXSDataMan:UseResults
	NVAR UseIndra2Data = root:Packages:Irena:BioSAXSDataMan:UseIndra2Data
	UseResults = 0
	UseIndra2Data = 0
	UseQRSData = 1
	Button GetHelp,pos={335,50},size={80,15},fColor=(65535,32768,32768), proc=IRB1_DataManButtonProc,title="Get Help", help={"Open www manual page for this tool"}



	TabControl ProcessingTabs,pos={262,135},size={250,500}
	TabControl ProcessingTabs,tabLabel(0)="Average",tabLabel(1)="Subtract"
	TabControl ProcessingTabs proc=IRB1_DataManTabProc

	//tab 1 controls
	Button SelectAllData,pos={280,170},size={190,20}, proc=IRB1_DataManButtonProc,title="1. Select All Data", help={"Select all data in the Listbox"}
	Button PlotSelectedData,pos={280,200},size={190,20}, proc=IRB1_DataManButtonProc,title="2. Plot Selected Data", help={"Plot selected data in the graph"}
	TitleBox AverageInstructions title="\Zr1203. Remove data by right click",size={330,15},pos={275,237},frame=0,fColor=(0,0,65535),labelBack=0
	Button AverageData,pos={280,270},size={190,20}, proc=IRB1_DataManButtonProc,title="4. Average & save Data", help={"Average data in the Graph and save with _avg in name"}
	Button ClearGraph,pos={280,300},size={190,20}, proc=IRB1_DataManButtonProc,title="5. Clear graph", help={"Clear the graph Graph"}

	TitleBox AverageInstructions2 title="\Zr120Name for ave folder : ",size={330,15},pos={270,350},frame=0,fColor=(0,0,65535),labelBack=0
	SetVariable AverageOutputFolderString,pos={265,370},size={245,15}, noproc,title=" ", noedit=1, frame=0
	Setvariable AverageOutputFolderString, variable=root:Packages:Irena:BioSAXSDataMan:AverageOutputFolderString

	
	//tab 2 controls
	TitleBox AverageInstructions3 title="\Zr1201. Pick Buffer folder (ave) : ",size={330,15},pos={270,175},frame=0,fColor=(0,0,65535),labelBack=0
	PopupMenu SelectBufferData,pos={262,200},size={180,20},fStyle=2,proc=IRB1_PopMenuProc,title=" "
	SVAR SelectedBufferFolder = root:Packages:Irena:BioSAXSDataMan:SelectedBufferFolder
	PopupMenu SelectBufferData,mode=1,popvalue=SelectedBufferFolder,value= IRB1_ListBufferScans() 
	TitleBox AverageInstructions7 title="\Zr1202. Add data (double click) ",size={330,15},pos={270,225},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox AverageInstructions8 title="\Zr1203. Tweak scaling ",size={330,15},pos={270,250},frame=0,fColor=(0,0,65535),labelBack=0

	SetVariable BufferScalingFraction,pos={270,275},size={220,15}, proc=IRB1_SetVarProc,title="Scale buffer =", noedit=0, frame=1, limits={0,10,0.002}
	Setvariable BufferScalingFraction, variable=root:Packages:Irena:BioSAXSDataMan:BufferScalingFraction, bodyWidth=100

	Button SubtractBuffer,pos={280,300},size={190,20}, proc=IRB1_DataManButtonProc,title="4. Subtract Buffer", help={"Subtract Buffer from data and save with _sub in name"}
	TitleBox AverageInstructions9 title="\Zr120Or, select many and process all ",size={330,15},pos={270,350},frame=0,fColor=(0,0,65535),labelBack=0
	Button SubtractBufferMany,pos={280,375},size={190,20}, proc=IRB1_DataManButtonProc,title="Sub. Buffer On Selected", help={"Subtract Buffer from all selected data and save with _sub in name"}

	TitleBox AverageInstructions4 title="\Zr120Input Data Name : ",size={245,15},pos={270,410},frame=0,fColor=(0,0,65535),labelBack=0
	SetVariable UserSourceDataFolderName,pos={280,430},size={245,15}, noproc,variable=root:Packages:Irena:BioSAXSDataMan:UserSourceDataFolderName
	SetVariable UserSourceDataFolderName, title=" ", limits={0,0,0}, noedit=1, frame=0
	TitleBox AverageInstructions5 title="\Zr120Buffer Data Name : ",size={245,15},pos={270,460},frame=0,fColor=(0,0,65535),labelBack=0
	SetVariable UserBufferDataFolderName,pos={280,480},size={245,15}, noproc,variable=root:Packages:Irena:BioSAXSDataMan:UserBufferDataFolderName
	SetVariable UserBufferDataFolderName, title=" ", limits={0,0,0}, noedit=1, frame=0
	TitleBox AverageInstructions6 title="\Zr120Output Data Name : ",size={245,15},pos={270,510},frame=0,fColor=(0,0,65535),labelBack=0
	SetVariable SubtractedOutputFldrName,pos={280,530},size={245,15}, noproc,variable=root:Packages:Irena:BioSAXSDataMan:SubtractedOutputFldrName
	SetVariable SubtractedOutputFldrName, title=" ", limits={0,0,0}, noedit=1, frame=0

//	Checkbox ProcessTest, pos={520,30},size={76,14},title="Test mode", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessTest
//	Checkbox ProcessMerge, pos={520,50},size={76,14},title="Merge mode", proc=IR3D_DatamergeCheckProc, variable=root:Packages:Irena:SASDataMerging:ProcessMerge
//
//	TitleBox UserMessage title="",fixedSize=1,size={470,20}, pos={480,90}, variable= root:Packages:Irena:SASDataMerging:UserMessageString
//	TitleBox UserMessage help={"This is what will happen"}

	Display /W=(521,10,1183,750) /HOST=# /N=LogLogDataDisplay
	SetActiveSubwindow ##
//	Display /W=(521,350,1183,410) /HOST=# /N=ResidualDataDisplay
//	SetActiveSubwindow ##
//	Display /W=(521,420,1183,750) /HOST=# /N=LinearizedDataDisplay
//	SetActiveSubwindow ##


	Checkbox OverwriteExistingData, pos={320,670},size={76,14},title="Overwrite Ouput?", noproc, variable=root:Packages:Irena:BioSAXSDataMan:OverwriteExistingData
	Checkbox DisplayErrorBars, pos={320,695},size={76,14},title="Display Error Bars", proc=IRB1_CheckProc, variable=root:Packages:Irena:BioSAXSDataMan:DisplayErrorBars
	Button AutoScaleGraph,pos={280,720},size={190,20}, proc=IRB1_DataManButtonProc,title="Autoscale Graph", help={"Autoscale the graph axes"}

	TitleBox Instructions1 title="\Zr100Double click to add data to graph",size={330,15},pos={4,680},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions2 title="\Zr100Shift-click to select range of data",size={330,15},pos={4,695},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions3 title="\Zr100Ctrl/Cmd-click to select one data set",size={330,15},pos={4,710},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions4 title="\Zr100Regex for not contain: ^((?!string).)*$",size={330,15},pos={4,725},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions5 title="\Zr100Regex for contain:  string, two: str2.*str1",size={330,15},pos={4,740},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions6 title="\Zr100Regex for case independent:  (?i)string",size={330,15},pos={4,755},frame=0,fColor=(0,0,65535),labelBack=0
	
	//and set the tab control to tab=0
	STRUCT WMTabControlAction TempTCA
	TempTCA.eventcode=2
	TempTCA.tab=0
	IRB1_DataManTabProc(TempTCA)
end
//**********************************************************************************************************
//**********************************************************************************************************

Function IRB1_DataManTabProc(tca) : TabControl
	STRUCT WMTabControlAction &tca

	switch( tca.eventCode )
		case 2: // mouse up
			IN2G_PrintDebugStatement(IrenaDebugLevel, 3,"Calling Tabcontrol procedure")
			SVAR DataMatchString = root:Packages:Irena:BioSAXSDataMan:DataMatchString
			NVAR InvertGrepSearch = root:Packages:Irena:BioSAXSDataMan:InvertGrepSearch
			Variable tab = tca.tab
			//tab0
				Button SelectAllData,win=IRB1_DataManipulationPanel, disable=(tab!=0)
				Button PlotSelectedData,win=IRB1_DataManipulationPanel, disable=(tab!=0)
				TitleBox AverageInstructions,win=IRB1_DataManipulationPanel, disable=(tab!=0)
				Button AverageData,win=IRB1_DataManipulationPanel, disable=(tab!=0)
				Button ClearGraph,win=IRB1_DataManipulationPanel, disable=(tab!=0)
				TitleBox AverageInstructions2,win=IRB1_DataManipulationPanel, disable=(tab!=0)
				SetVariable AverageOutputFolderString,win=IRB1_DataManipulationPanel, disable=(tab!=0)
			//tab 1
				TitleBox AverageInstructions3,win=IRB1_DataManipulationPanel, disable=(tab!=1)
				PopupMenu SelectBufferData,win=IRB1_DataManipulationPanel, disable=(tab!=1)
				SetVariable BufferScalingFraction,win=IRB1_DataManipulationPanel, disable=(tab!=1)
				Button SubtractBuffer,win=IRB1_DataManipulationPanel, disable=(tab!=1)
				Button SubtractBufferMany,win=IRB1_DataManipulationPanel, disable=(tab!=1)
				TitleBox AverageInstructions4 ,win=IRB1_DataManipulationPanel, disable=(tab!=1)
				TitleBox AverageInstructions5 ,win=IRB1_DataManipulationPanel, disable=(tab!=1)
				TitleBox AverageInstructions6 ,win=IRB1_DataManipulationPanel, disable=(tab!=1)
				TitleBox AverageInstructions7 ,win=IRB1_DataManipulationPanel, disable=(tab!=1)
				TitleBox AverageInstructions8 ,win=IRB1_DataManipulationPanel, disable=(tab!=1)
				TitleBox AverageInstructions9 ,win=IRB1_DataManipulationPanel, disable=(tab!=1)
				SetVariable SubtractedOutputFldrName,win=IRB1_DataManipulationPanel, disable=(tab!=1)
				SetVariable UserBufferDataFolderName,win=IRB1_DataManipulationPanel, disable=(tab!=1)
				SetVariable UserSourceDataFolderName,win=IRB1_DataManipulationPanel, disable=(tab!=1)
				
			//other stuff, clear teh graph
				IRB1_DataManRemoveAllDataSets()
			//set controls for names
			if(tab==1)
				InvertGrepSearch = 0
				DataMatchString="ave"
			else
				InvertGrepSearch = 1
				DataMatchString="ave|sub"
			endif
				IR3C_MultiUpdateListOfAvailFiles("root:Packages:Irena:BioSAXSDataMan")
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************

Function IRB1_DataManButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringMatch(ba.ctrlName,"PlotSelectedData"))
				IRB1_DataManAppendSelectedDataSets()
			endif
			if(stringMatch(ba.ctrlName,"AverageData"))
				IRB1_DataManAverageDataSetsts()
			endif//

			if(stringMatch(ba.ctrlName,"SelectAllData"))
				IRB1_DataManSelectAllData()
			endif
			if(stringMatch(ba.ctrlName,"ClearGraph"))
				IRB1_DataManRemoveAllDataSets()
			endif
			if(stringMatch(ba.ctrlName,"AutoScaleGraph"))
				SetAxis/W=IRB1_DataManipulationPanel#LogLogDataDisplay /A
			endif
			if(stringMatch(ba.ctrlName,"SubtractBuffer"))
				IRB1_DataManSubtractBufferOne()
			endif
			if(stringMatch(ba.ctrlName,"SubtractBufferMany"))
				IRB1_DataManSubtractBufferMany()
			endif

			if(stringmatch(ba.ctrlName,"GetHelp"))
					IN2G_OpenWebManual("Irena/ImportData.html")				//fix me!!			
			endif

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************

Function IRB1_DataManRemoveAllDataSets()

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena:BioSAXSDataMan
	variable i, numTraces
	string TraceNames
	
	TraceNames= TraceNameList("IRB1_DataManipulationPanel#LogLogDataDisplay",";",3)
	numTraces = ItemsInList(TraceNames)
	//remove all traces...
	For(i=0;i<numTraces;i+=1)
		RemoveFromGraph/W=IRB1_DataManipulationPanel#LogLogDataDisplay /Z $(StringFromList(i,TraceNames))
	endfor

end
//**********************************************************************************************************
//**********************************************************************************************************
Function IRB1_DataManAverageDataSetsts()

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena:BioSAXSDataMan
	variable i, numTraces
	string TraceNames, NewNote
	
	TraceNames= TraceNameList("IRB1_DataManipulationPanel#LogLogDataDisplay",";",3)
	TraceNames=GrepList(TraceNames, "_ave",1 , ";" )											//this removes any _ave waves which user may have generated by multiple push of the button. 
	NewNote = "Averaged Data;"+date()+";"+time()+";List of Data waves="+TraceNames
	numTraces = ItemsInList(TraceNames)
	//create needed lists first... 
	make/Free/T/N=(numTraces) FldrNamesTWv
	make/Free/N=(numTraces) SelFldrs
	SelFldrs = 1
	string TempStrName
	string Xtmplt,Ytmplt,Etmplt,OutFldrNm,OutXWvNm, OutYWvNm,OutEWvNm
	variable UseStdDev,UseSEM, UseMinMax, PropagateErrors

	//build the lists of folders...
	make/WAVE/N=(numTraces)/Free  wr
	For(i=0;i<numTraces;i+=1)
		wr[i] = TraceNameToWaveRef("IRB1_DataManipulationPanel#LogLogDataDisplay", StringFromList(i,TraceNames))
	endfor
	FldrNamesTWv = GetWavesDataFolder(wr[p], 1)
	//take first folder name, append the user appendix and create new strings here... 
	string FirstFolderShortName=StringFromList(ItemsInList(FldrNamesTWv[0], ":")-1, FldrNamesTWv[0], ":")
	string OutputWaveNameMain = RemoveListItem(ItemsInList(FirstFolderShortName,"_")-1, FirstFolderShortName, "_") +"ave"
	OutYWvNm = "r_"+OutputWaveNameMain
	OutEWvNm = "s_"+OutputWaveNameMain
	OutXWvNm = "q_"+OutputWaveNameMain
	string FullPathToFirstFolder = FldrNamesTWv[numpnts(FldrNamesTWv)-1]
	string OldFolderName = StringFromList(ItemsInList(FullPathToFirstFolder,":")-1, FullPathToFirstFolder, ":")
	FullPathToFirstFolder  = ReplaceString(OldFOlderName, FullPathToFirstFolder, OutputWaveNameMain)
	OutFldrNm = FullPathToFirstFolder	
	Xtmplt = "(?i)q_"
	Ytmplt = "(?i)r_"
	Etmplt = "(?i)s_"
	UseStdDev = 0
	UseSEM = 0 
	PropagateErrors = 1
	UseMinMax = 0
	IR3M_AverageMultipleWaves(FldrNamesTWv,SelFldrs,Xtmplt,Ytmplt,Etmplt,UseStdDev,UseSEM, UseMinMax, PropagateErrors)	
	Wave AveragedDataXwave = root:Packages:DataManipulationII:AveragedDataXwave
	Wave AveragedDataYwave = root:Packages:DataManipulationII:AveragedDataYwave
	Wave AveragedDataEwave = root:Packages:DataManipulationII:AveragedDataEwave
	NVAR Overwrite=root:Packages:Irena:BioSAXSDataMan:OverwriteExistingData

	//and now I need to save the data
	if(DataFolderExists(OutFldrNm)&&!Overwrite)
		DoAlert /T="Folder for Average data exists" 1, "Folder "+OutFldrNm+" exists, do you want to overwrite?"
		if(V_Flag!=1)
			abort
		endif
	endif
	NewDataFolder/O/S $(RemoveEnding(OutFldrNm , ":") )
	Duplicate/O AveragedDataXwave, $(OutXWvNm)
	Duplicate/O AveragedDataYwave, $(OutYWvNm)
	Duplicate/O AveragedDataEwave, $(OutEWvNm)
	Wave NewAveXWave = $(OutXWvNm)
	Wave NewAveYWave = $(OutYWvNm)
	Wave NewAveEWave = $(OutEWvNm)
	Note /K/NOCR NewAveXWave, NewNote
	Note /K/NOCR NewAveYWave, NewNote
	Note /K/NOCR NewAveEWave, NewNote
	Print "Created averaged data set in:"+OutFldrNm +"\r       Averaged following data sets:"+TraceNames
	CheckDisplayed /W=IRB1_DataManipulationPanel#LogLogDataDisplay $(nameOfWave(NewAveYWave))
	if(V_Flag!=1)
		AppendToGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay  NewAveYWave  vs NewAveXWave
		ErrorBars/T=2/L=2 /W=IRB1_DataManipulationPanel#LogLogDataDisplay $(NameOfWave(NewAveYWave)) Y,wave=(NewAveEWave,NewAveEWave)
		ModifyGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay lstyle($(NameOfWave(NewAveYWave)))=3,lsize($(NameOfWave(NewAveYWave)))=3,rgb($(NameOfWave(NewAveYWave)))=(0,0,0)
	endif
	//IN2G_ColorTopGrphRainbow(topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
	IN2G_LegendTopGrphFldr(12, 20, 1, 0, topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
	//NVAR DisplayErrorBars = root:Packages:Irena:BioSAXSDataMan:DisplayErrorBars
	//IN2G_ShowHideErrorBars(DisplayErrorBars, topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
	DoUpdate 
	setDataFOlder oldDf
end

//**********************************************************************************************************
//**********************************************************************************************************
Function IRB1_DataManSelectAllData()
	Wave SelectionOfAvailableData = root:Packages:Irena:BioSAXSDataMan:SelectionOfAvailableData	
	SelectionOfAvailableData = 1
end
//**********************************************************************************************************
//**********************************************************************************************************
Function IRB1_DataManAppendSelectedDataSets()

	variable i
	string FoldernameStr
	PauseUpdate
	IRB1_DataManRemoveAllDataSets()
	Wave/T ListOfAvailableData = root:Packages:Irena:BioSAXSDataMan:ListOfAvailableData
	Wave SelectionOfAvailableData = root:Packages:Irena:BioSAXSDataMan:SelectionOfAvailableData	
	for(i=0;i<numpnts(ListOfAvailableData);i+=1)
		if(SelectionOfAvailableData[i]>0.5)
			IRB1_DataManAppendOneDataSet(ListOfAvailableData[i])
		endif
	endfor
	IN2G_ColorTopGrphRainbow(topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
	IN2G_LegendTopGrphFldr(12, 20, 1, 0, topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
	NVAR DisplayErrorBars = root:Packages:Irena:BioSAXSDataMan:DisplayErrorBars
	IN2G_ShowHideErrorBars(DisplayErrorBars, topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
	DoUpdate 

end

//**********************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************
	Function IRB1_DataManAppendOneDataSet(FolderNameStr)
	string FolderNameStr
	
	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena:BioSAXSDataMan					//go into the folder
	//IR3D_SetSavedNotSavedMessage(0)
	//figure out if we are doing averaging or buffer subtraction
	ControlInfo /W=IRB1_DataManipulationPanel ProcessingTabs
	variable UsingAveraging
	if(V_Value==0)
		UsingAveraging=1
	else
		UsingAveraging=0			//buffer subtraction
	endif
	SVAR DataStartFolder=root:Packages:Irena:BioSAXSDataMan:DataStartFolder
	SVAR DataFolderName=root:Packages:Irena:BioSAXSDataMan:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena:BioSAXSDataMan:IntensityWaveName
	SVAR QWavename=root:Packages:Irena:BioSAXSDataMan:QWavename
	SVAR ErrorWaveName=root:Packages:Irena:BioSAXSDataMan:ErrorWaveName
	SVAR dQWavename=root:Packages:Irena:BioSAXSDataMan:dQWavename
	NVAR UseIndra2Data=root:Packages:Irena:BioSAXSDataMan:UseIndra2Data
	NVAR UseQRSdata=root:Packages:Irena:BioSAXSDataMan:UseQRSdata
	//these are variables used by the control procedure
	NVAR UseResults=  root:Packages:Irena:BioSAXSDataMan:UseResults
	NVAR UseUserDefinedData=  root:Packages:Irena:BioSAXSDataMan:UseUserDefinedData
	NVAR UseModelData = root:Packages:Irena:BioSAXSDataMan:UseModelData
	SVAR DataFolderName  = root:Packages:Irena:BioSAXSDataMan:DataFolderName 
	SVAR IntensityWaveName = root:Packages:Irena:BioSAXSDataMan:IntensityWaveName
	SVAR QWavename = root:Packages:Irena:BioSAXSDataMan:QWavename
	SVAR ErrorWaveName = root:Packages:Irena:BioSAXSDataMan:ErrorWaveName
	SVAR AverageOutputFolderString = root:Packages:Irena:BioSAXSDataMan:AverageOutputFolderString
	SVAR SubtractedOutputFldrName=root:Packages:Irena:BioSAXSDataMan:SubtractedOutputFldrName
	SVAR UserSourceDataFolderName=root:Packages:Irena:BioSAXSDataMan:UserSourceDataFolderName
	UseResults = 0
	UseUserDefinedData = 0
	UseModelData = 0
	//get the names of waves, assume this tool actually works. May not under some conditions. In that case this tool will not work. 
	string tempStr
	if(ItemsInList(FolderNameStr, ":")>1)
		tempStr=StringFromList(ItemsInList(FolderNameStr, ":")-1, FolderNameStr, ":")
	else
		tempStr = FolderNameStr
	endif
	AverageOutputFolderString = RemoveListItem(ItemsInList(tempStr,"_")-1, tempStr, "_") +"ave"
	DataFolderName = DataStartFolder+FolderNameStr
	QWavename = stringFromList(0,IR2P_ListOfWaves("Xaxis","", "IRB1_DataManipulationPanel"))
	IntensityWaveName = stringFromList(0,IR2P_ListOfWaves("Yaxis","*", "IRB1_DataManipulationPanel"))
	ErrorWaveName = stringFromList(0,IR2P_ListOfWaves("Error","*", "IRB1_DataManipulationPanel"))
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
		Abort "Data selection failed for Data"
	endif
	if(!UsingAveraging)		//subtracting buffer from ave data
		//preset for user output name for merged data
		UserSourceDataFolderName = StringFromList(ItemsInList(FolderNameStr, ":")-1, FolderNameStr, ":")
		SubtractedOutputFldrName = ReplaceString("_ave", UserSourceDataFolderName, "_sub")
		//remove, if needed, all data from graph
		IRB1_DataManRemoveAllDataSets()
		//append Buffer data if exist...
		Wave/Z q_BufferData = q_BufferData
		Wave/Z r_BufferData = r_BufferData
		Wave/Z s_BufferData = s_BufferData
		if(WaveExists(r_BufferData) || WaveExists(q_BufferData) || WaveExists(s_BufferData))
			//and check the data are in the graph, else it willconfuse user. 
			CheckDisplayed /W=IRB1_DataManipulationPanel#LogLogDataDisplay r_BufferData
			if(V_Flag!=1)
				AppendToGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay  r_BufferData  vs q_BufferData
				ErrorBars/T=2/L=2 /W=IRB1_DataManipulationPanel#LogLogDataDisplay r_BufferData Y,wave=(s_BufferData,s_BufferData)
				ModifyGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay lstyle(r_BufferData)=3,lsize(r_BufferData)=3,rgb(r_BufferData)=(0,0,0)	
			endif
		endif
	endif
	CheckDisplayed /W=IRB1_DataManipulationPanel#LogLogDataDisplay SourceIntWv
	if(!V_flag)
		AppendToGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay  SourceIntWv  vs SourceQWv
		ModifyGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay log=1, mirror=1
		Label /W=IRB1_DataManipulationPanel#LogLogDataDisplay left "Intensity 1"
		Label /W=IRB1_DataManipulationPanel#LogLogDataDisplay bottom "Q [A\\S-1\\M]"
		ErrorBars /W=IRB1_DataManipulationPanel#LogLogDataDisplay $(NameOfWave(SourceIntWv)) Y,wave=(SourceErrorWv,SourceErrorWv)
	endif
	IN2G_ColorTopGrphRainbow(topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
	IN2G_LegendTopGrphFldr(12, 20, 1, 0, topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
	NVAR DisplayErrorBars = root:Packages:Irena:BioSAXSDataMan:DisplayErrorBars
	IN2G_ShowHideErrorBars(DisplayErrorBars, topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
	SetDataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IRB1_DataManInitBioSAXS()	


	string oldDf=GetDataFolder(1)
	string ListOfVariables
	string ListOfStrings
	variable i
		
	if (!DataFolderExists("root:Packages:Irena:BioSAXSDataMan"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena
		NewDataFolder/O root:Packages:Irena:BioSAXSDataMan
	endif
	SetDataFolder root:Packages:Irena:BioSAXSDataMan					//go into the folder

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;DataUnits;"
	ListOfStrings+="DataStartFolder;DataMatchString;FolderSortString;FolderSortStringAll;"
	ListOfStrings+="UserMessageString;SavedDataMessage;UserSourceDataFolderName;UserBufferDataFolderName;"
	ListOfStrings+="AverageOutputFolderString;SelectedBufferFolder;SubtractedOutputFldrName;"

	ListOfVariables="UseIndra2Data1;UseQRSdata1;DisplayErrorBars;"
	ListOfVariables+="OverwriteExistingData;"
	ListOfVariables+="BufferScalingFraction;DataQEnd;DataQstart;"

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
	SVAR SelectedBufferFolder
	if(strlen(SelectedBufferFolder)<2)
		SelectedBufferFolder = "---"
	endif
	NVAR BufferScalingFraction
	if(BufferScalingFraction<0.001)
		BufferScalingFraction = 1
	endif
	Make/O/T/N=(0) ListOfAvailableData
	Make/O/N=(0) SelectionOfAvailableData
	SetDataFolder oldDf

end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function/T IRB1_ListBufferScans()

		String AllDataFolders
		AllDataFolders=IR3C_MultiGenStringOfFolders("Irena:BioSAXSDataMan", "root:",0, 1,0, 0,1)
		//seelct only AVeraged data. 
		AllDataFolders = GrepList(AllDataFolders, "ave", 0) 
		
		return AllDataFolders
end

///******************************************************************************************
///******************************************************************************************
Function IRB1_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			if(stringmatch(sva.ctrlName,"BufferScalingFraction"))
				NVAR BufferScalingFraction = root:Packages:Irena:BioSAXSDataMan:BufferScalingFraction
				IR1B_DataManCopyAndScaleBuffer()
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
///******************************************************************************************
///******************************************************************************************


Function IRB1_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(stringmatch(pa.ctrlName,"SelectBufferData"))
				SVAR SelectedBufferFolder = root:Packages:Irena:BioSAXSDataMan:SelectedBufferFolder
				SelectedBufferFolder = popStr
				IR1B_DataManCopyAndScaleBuffer()
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1B_DataManCopyAndScaleBuffer()

	DfRef OldDf=GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:BioSAXSDataMan:
	SVAR SelectedBufferFolder = root:Packages:Irena:BioSAXSDataMan:SelectedBufferFolder
	NVAR BufferScalingFraction = root:Packages:Irena:BioSAXSDataMan:BufferScalingFraction
	SVAR UserBufferDataFolderName = root:Packages:Irena:BioSAXSDataMan:UserBufferDataFolderName
	
	string XwaveNameStr = SelectedBufferFolder+"q_"+StringFromList(ItemsInList(SelectedBufferFolder,":")-1, SelectedBufferFolder, ":")
	string YwaveNameStr = SelectedBufferFolder+"r_"+StringFromList(ItemsInList(SelectedBufferFolder,":")-1, SelectedBufferFolder, ":")
	string EwaveNameStr = SelectedBufferFolder+"s_"+StringFromList(ItemsInList(SelectedBufferFolder,":")-1, SelectedBufferFolder, ":")
	
	Wave/Z Xwave = $(XwaveNameStr)
	Wave/Z Ywave = $(YwaveNameStr)
	Wave/Z Ewave = $(EwaveNameStr)
	if(!WaveExists(XWave) || !WaveExists(YWave) || !WaveExists(EWave))
		ABort "Buffer wave selection failed" 
	endif
	
	Duplicate/O Xwave, q_BufferData
	Duplicate/O Ywave, r_BufferData
	Duplicate/O Ewave, s_BufferData
	
	Wave q_BufferData = q_BufferData
	Wave r_BufferData = r_BufferData
	Wave s_BufferData = s_BufferData
	
	r_BufferData*=BufferScalingFraction
	s_BufferData*=BufferScalingFraction

	CheckDisplayed /W=IRB1_DataManipulationPanel#LogLogDataDisplay r_BufferData
	if(V_Flag!=1)
		AppendToGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay  r_BufferData  vs q_BufferData
		ErrorBars/T=2/L=2 /W=IRB1_DataManipulationPanel#LogLogDataDisplay r_BufferData Y,wave=(s_BufferData,s_BufferData)
		ModifyGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay lstyle(r_BufferData)=3,lsize(r_BufferData)=3,rgb(r_BufferData)=(0,0,0)	
		ModifyGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay log=1, mirror=1
	endif
	UserBufferDataFolderName = StringFromList(ItemsInList(SelectedBufferFolder, ":")-1, SelectedBufferFolder, ":")
	NVAR DisplayErrorBars = root:Packages:Irena:BioSAXSDataMan:DisplayErrorBars
	IN2G_ShowHideErrorBars(DisplayErrorBars, topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")

	SetDataFolder OldDf
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IRB1_DataManSubtractBufferMany()

	DfRef OldDf=GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:BioSAXSDataMan:
	IRB1_DataManRemoveAllDataSets()
	variable i
	Wave/T ListOfAvailableData = root:Packages:Irena:BioSAXSDataMan:ListOfAvailableData
	Wave SelectionOfAvailableData = root:Packages:Irena:BioSAXSDataMan:SelectionOfAvailableData	
	for(i=0;i<numpnts(ListOfAvailableData);i+=1)
		if(SelectionOfAvailableData[i]>0.5)
			IRB1_DataManAppendOneDataSet(ListOfAvailableData[i])
			IRB1_DataManSubtractBufferOne()
			DoUpdate 
			sleep/S/C=6/M="Subtracted buffer for "+ListOfAvailableData[i] 2
		endif
	endfor
	Print "Done subtracting buffer"
	SetDataFolder OldDf
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IRB1_DataManSubtractBufferOne()

	DfRef OldDf=GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:BioSAXSDataMan:
	variable i, numTraces
	string TraceNames
	string OriginalDataNote, BufferDataNote
	
	SVAR SourceFolderName = root:Packages:Irena:BioSAXSDataMan:DataFolderName
	NVAR Overwrite=root:Packages:Irena:BioSAXSDataMan:OverwriteExistingData

	string XwaveNameStr = SourceFolderName+"q_"+StringFromList(ItemsInList(SourceFolderName,":")-1, SourceFolderName, ":")
	string YwaveNameStr = SourceFolderName+"r_"+StringFromList(ItemsInList(SourceFolderName,":")-1, SourceFolderName, ":")
	string EwaveNameStr = SourceFolderName+"s_"+StringFromList(ItemsInList(SourceFolderName,":")-1, SourceFolderName, ":")

	Wave/Z Xwave = $(XwaveNameStr)
	Wave/Z Ywave = $(YwaveNameStr)
	Wave/Z Ewave = $(EwaveNameStr)
	if(!WaveExists(XWave) || !WaveExists(YWave) || !WaveExists(EWave))
		ABort "Source wave selection failed" 
	endif

	Duplicate/O Xwave, q_SampleData
	Duplicate/O Ywave, r_SampleData
	Duplicate/O Ewave, s_SampleData

	Wave q_SampleData = q_SampleData
	Wave r_SampleData = r_SampleData
	Wave s_SampleData = s_SampleData
	OriginalDataNote=note(r_SampleData)
	Wave/Z q_BufferData = q_BufferData
	Wave/Z r_BufferData = r_BufferData
	Wave/Z s_BufferData = s_BufferData
	if(!WaveExists(r_BufferData) || !WaveExists(q_BufferData) || !WaveExists(s_BufferData))
		ABort "Buffer waves Do not exist, seelct buffer first, then run again" 
	endif
	BufferDataNote=note(r_BufferData)
	//and check the data are in the graph, else it willconfuse user. 
	CheckDisplayed /W=IRB1_DataManipulationPanel#LogLogDataDisplay r_BufferData
	if(V_Flag!=1)
		AppendToGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay  r_BufferData  vs q_BufferData
		ErrorBars/T=2/L=2 /W=IRB1_DataManipulationPanel#LogLogDataDisplay r_BufferData Y,wave=(s_BufferData,s_BufferData)
		ModifyGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay lstyle(r_BufferData)=3,lsize(r_BufferData)=3,rgb(r_BufferData)=(0,0,0)	
	endif
	
	//do subtraction, thhere is not general procedrue in the Data manipulation...
	Duplicate/Free r_SampleData, ResultsInt, TempBufIntInterp2
	Duplicate/Free q_SampleData, ResultsQ, TempBuffEInterp2
	Duplicate/Free s_SampleData, ResultsE
	Duplicate/Free r_BufferData, TempIntLog2
	Duplicate/Free s_BufferData, TempELog2
	TempIntLog2=log(r_BufferData)
	TempELog2=log(s_BufferData)
	TempBufIntInterp2 = 10^(interp(q_SampleData, q_BufferData, TempIntLog2))
	TempBuffEInterp2 = 10^(interp(q_SampleData, q_BufferData, TempELog2))
	if (BinarySearch(ResultsQ, q_BufferData[0] )>0)
		TempBufIntInterp2[0,BinarySearch(ResultsQ, q_BufferData[0] )]=NaN
		TempBuffEInterp2[0,BinarySearch(ResultsQ, q_BufferData[0] )]=NaN
	endif
	if ((BinarySearch(ResultsQ, q_BufferData[numpnts(q_BufferData)-1] )!=numpnts(ResultsQ)-1)&&(BinarySearch(ResultsQ, q_BufferData[numpnts(q_BufferData)-1] )!=-2))
		TempBufIntInterp2[BinarySearch(ResultsQ, q_BufferData[numpnts(q_BufferData)-1])+1,inf]=Nan
		TempBuffEInterp2[BinarySearch(ResultsQ, q_BufferData[numpnts(q_BufferData)-1])+1,inf]=Nan
	endif
	ResultsInt = r_SampleData - TempBufIntInterp2
	ResultsE = sqrt(s_SampleData^2 + TempBuffEInterp2^2)
	IN2G_ReplaceNegValsByNaNWaves(ResultsInt,ResultsQ,ResultsE)
	IN2G_RemoveNaNsFrom3Waves(ResultsInt,ResultsQ,ResultsE)

	String OutFldrNm, OutXWvNm, OutYWvNm,OutEWvNm
	OutFldrNm = ReplaceString("_ave", SourceFolderName, "_sub")
	string FirstFolderShortName=StringFromList(ItemsInList(OutFldrNm, ":")-1, OutFldrNm, ":")
	string OutputWaveNameMain = RemoveListItem(ItemsInList(FirstFolderShortName,"_")-1, FirstFolderShortName, "_") +"sub"
	OutYWvNm = "r_"+OutputWaveNameMain
	OutEWvNm = "s_"+OutputWaveNameMain
	OutXWvNm = "q_"+OutputWaveNameMain
	//and now I need to save the data
	if(DataFolderExists(OutFldrNm)&&!Overwrite)
		DoAlert /T="Folder for Subtracted data exists" 1, "Folder "+OutFldrNm+" exists, do you want to overwrite?"
		if(V_Flag!=1)
			abort
		endif
	endif
	NewDataFolder/O/S $(RemoveEnding(OutFldrNm , ":") )
	Duplicate/O ResultsQ, $(OutXWvNm)
	Duplicate/O ResultsInt, $(OutYWvNm)
	Duplicate/O ResultsE, $(OutEWvNm)
	Wave NewSubtractedXWave = $(OutXWvNm)
	Wave NewSubtractedYWave = $(OutYWvNm)
	Wave NewSubtractedEWave = $(OutEWvNm)
	print "Subtracted buffer from "+SourceFolderName
	string NewNote
	SVAR BufferName=root:Packages:Irena:BioSAXSDataMan:UserBufferDataFolderName
	NewNote="Subtracted Buffer;"+date()+";"+time()+";Data Folder="+SourceFolderName+";Buffer Folder="+BufferName+";"
	NewNote+="DataNote:"+OriginalDataNote+";"
	NewNote+="BufferNote:"+BufferDataNote+";"
	Note /K/NOCR NewSubtractedYWave, NewNote
	Note /K/NOCR NewSubtractedXWave, NewNote
	Note /K/NOCR NewSubtractedEWave, NewNote
	CheckDisplayed /W=IRB1_DataManipulationPanel#LogLogDataDisplay $(NameOfWave(NewSubtractedYWave))
	if(V_Flag!=1)
		AppendToGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay  NewSubtractedYWave  vs NewSubtractedXWave
		ErrorBars/T=2/L=2 /W=IRB1_DataManipulationPanel#LogLogDataDisplay $(NameOfWave(NewSubtractedYWave)) Y,wave=(NewSubtractedEWave,NewSubtractedEWave)
		ModifyGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay lstyle($(NameOfWave(NewSubtractedYWave)))=3,lsize($(NameOfWave(NewSubtractedYWave)))=3,rgb($(NameOfWave(NewSubtractedYWave)))=(0,0,0)
		ModifyGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay rgb($(NameOfWave(NewSubtractedYWave)))=(0,0,65535)
	endif
	IN2G_ColorTopGrphRainbow(topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
	IN2G_LegendTopGrphFldr(12, 20, 1, 0, topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
	NVAR DisplayErrorBars = root:Packages:Irena:BioSAXSDataMan:DisplayErrorBars
	IN2G_ShowHideErrorBars(DisplayErrorBars, topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")

	setDataFOlder oldDf
end

//**********************************************************************************************************
//**********************************************************************************************************
