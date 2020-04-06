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
constant IRB1_DataManipulation = 0.1							//IRB1_DataManipulation tool version number. 
constant IRB1_SetVariableStepScaling = 0.01					//this is fraction of the value to which the step in SetVariable is set.  
constant IRB1_PDDFInterfaceVersion = 0.1					//IRB1_PDDFInterfaceFunction version number
//functions for bioSAXS community
//
//version summary
//0.1 early beta version

//Contains these main parts:
//Import ASCII data: 	IRB1_ImportASCII()
//Avergae data and other data manipulations : IRB1_DataManipulation()
//ATSAS support IRB1_PDDFInterfaceFunction()



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
Function IR1B_ImportASCIIMainCheckVersion()	
	DoWindow IR1I_ImportBioSAXSASCIIData
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR1I_ImportBioSAXSASCIIData", IRB1_ImportBioSAXSASCIIDataVersion))
			DoAlert /T="The Import ASCII panel was created by incorrect version of Irena " 1, "Import ASCII tool needa to be restarted to work properly. Restart now?"
			if(V_flag==1)
				KillWIndow/Z IR1I_ImportBioSAXSASCIIData
				IRB1_ImportASCII()
			else		//at least reinitialize the variables so we avoid major crashes...
				IRB1_InitializeImportData()
			endif
		endif
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
//add options to use different error propagation, per request uses Standard deviation
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
		IR3C_MultiUpdateListOfAvailFiles("Irena:BioSAXSDataMan")
		ING2_AddScrollControl()
		IR1_UpdatePanelVersionNumber("IRB1_DataManipulationPanel", IRB1_DataManipulation,1)
	endif
end
//************************************************************************************************************
//************************************************************************************************************
Function IR1B_DataManMainCheckVersion()	
	DoWindow IRB1_DataManipulationPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IRB1_DataManipulationPanel", IRB1_DataManipulation))
			DoAlert /T="The Data Manipulation panel was created by incorrect version of Irena " 1, "Data Manipulation tool needa to be restarted to work properly. Restart now?"
			if(V_flag==1)
				KillWIndow/Z IRB1_DataManipulationPanel
				IRB1_DataManipulation()
			else		//at least reinitialize the variables so we avoid major crashes...
				IRB1_DataManInitBioSAXS()
			endif
		endif
	endif
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//				This is BioSAXS Data package to run PDDF and some ATSAS functions
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//NOTE: you need ATSAS 

Function IRB1_PDDFInterfaceFunction()
	IN2G_CheckScreenSize("width",1200)
	DoWIndow IRB1_PDDFInterfacePanel
	if(V_Flag)
		DoWindow/F IRB1_PDDFInterfacePanel
	else
		IRB1_PDDFInitialize()
		IRB1_PDDFPanelFnct()
		SetWindow IRB1_PDDFInterfacePanel, hook(ATSASCursorMoved) = IRB1_PDDFGraphWindowHook
		IR3C_MultiUpdateListOfAvailFiles("Irena:PDDFInterface")
		ING2_AddScrollControl()
		IR1_UpdatePanelVersionNumber("IRB1_PDDFInterfacePanel", IRB1_PDDFInterfaceVersion,1)
	endif
end
//************************************************************************************************************
//************************************************************************************************************
Function IR1B_PDDFMainCheckVersion()	
	DoWindow IRB1_PDDFInterfacePanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IRB1_PDDFInterfacePanel", IRB1_PDDFInterfaceVersion))
			DoAlert /T="The ATSAS panel was created by incorrect version of Irena " 1, "ATSAS tool needa to be restarted to work properly. Restart now?"
			if(V_flag==1)
				KillWIndow/Z IRB1_PDDFInterfacePanel
				IRB1_PDDFInterfaceFunction()
			else		//at least reinitialize the variables so we avoid major crashes...
				IRB1_PDDFInitialize()
			endif
		endif
	endif
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//				This is customized Merge multiple data sets for BioSAXS Data 
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IRB1_MergeMultipleData()
		IR3D_DataMerging()
		//tweak values for users
		NVAR UseQRSdata1 = root:Packages:Irena:SASDataMerging:UseQRSdata1
		UseQRSdata1 = 1
		NVAR UseQRSdata2 = root:Packages:Irena:SASDataMerging:UseQRSdata2
		UseQRSdata1 = 2
		SVAR MatchStr1 = root:Packages:Irena:SASDataMerging:Data1MatchString
		SVAR MatchStr2 = root:Packages:Irena:SASDataMerging:Data2MatchString
		MatchStr1 = "sub"
		MatchStr2 = "sub"
		IR3D_UpdateListOfAvailFiles(1)
		IR3D_UpdateListOfAvailFiles(2)
		IR3D_RebuildListboxTables()	
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//				This is customized ASCII export for BioSAXS Data 
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IRB1_ASCIIExport()
		IR2E_UniversalDataExport()
		//tweak values for users
		NVAR useQRS=root:Packages:IR2_UniversalDataExport:UseQRSdata
		NVAR useResults=root:Packages:IR2_UniversalDataExport:UseResults
		NVAR useUSAXS=root:Packages:IR2_UniversalDataExport:UseIndra2data
		useQRS=1
		useUSAXS = 0
		useResults = 0
		SVAR FolderMatchStr = root:Packages:IrenaControlProcs:UnivDataExportPanel:FolderMatchStr
		FolderMatchStr = "sub"
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
	IR3C_AddDataControls("ImportDataPath", "Irena:ImportBioSAXSData", "IRB1_ImportBioSAXSASCIIData","dat", "","","IRB1_PreviewDataFnct")
	ListBox ListOfAvailableData,size={220,477}, pos={5,113}
	Button SelectAll,pos={5,595}
	Button DeSelectAll, pos={120,595}
	PopupMenu SortOptionString pos={250,120}

	CheckBox SAXSData,pos={250,160},size={16,14},proc=IRB1_CheckProc,title="SAXS data?",variable= root:Packages:Irena:ImportBioSAXSData:SAXSData,mode=1, help={"Check if these are SAXS data..."}
	CheckBox WAXSdata,pos={250,180},size={16,14},proc=IRB1_CheckProc,title="WAXS data data?",variable= root:Packages:Irena:ImportBioSAXSData:WAXSdata,mode=1, help={"Check if these are WAXS data..."}

	CheckBox GroupSamplesTogether,pos={240,220},size={16,14},proc=IRB1_CheckProc,title="Group by Samples?",variable= root:Packages:Irena:ImportBioSAXSData:GroupSamplesTogether,mode=0, help={"Check if you want multipel sample measurements grouped together"}


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

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
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
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
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
					IN2G_OpenWebManual("Irena/ImportDataBio.html")				//fix me!!			
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
//************************************************************************************************************
//************************************************************************************************************
//				Part of customized BioSAXS Import ASCII
//************************************************************************************************************
static Function IRB1_ImportDataFnct()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	string TopPanel=WinName(0, 64)
	DfRef OldDf=GetDataFolderDFR()
	
	Wave/T WaveOfFiles    = root:Packages:Irena:ImportBioSAXSData:WaveOfFiles
	Wave WaveOfSelections = root:Packages:Irena:ImportBioSAXSData:WaveOfSelections
	NVAR SAXSdata= root:Packages:Irena:ImportBioSAXSData:SAXSData
	NVAR WAXSData= root:Packages:Irena:ImportBioSAXSData:WAXSData
	NVAR GroupSamplesTogether	=	root:Packages:Irena:ImportBioSAXSData:GroupSamplesTogether
	PathInfo ImportDataPath
	string DataSelPathString=S_path
	if(SAXSdata)
		NewDataFolder/O/S root:SAXS
	elseif(WAXSdata)
		NewDataFolder/O/S root:WAXS
	else
		NewDataFolder/O/S root:ImportedData
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
	 		//now make assumption about sample name, we can group samples together.
	 		if(GroupSamplesTogether)
	 			SelectedSampleName = RemoveEnding(RemoveListItem(ItemsInList(selectedfile,"_")-1, selectedfile,"_"),"_")
	 			SelectedSampleName = CleanupName(SelectedSampleName,1)
	 			SelectedFileName = CleanupName(SelectedFileName, 1)
				//create and move into the SampleFolder
				if(strlen(SelectedSampleName)>1)		//cases, when name cannot be deduced in above level. 
					NewDataFolder/O/S $((SelectedSampleName))
				endif
			endif
			//now folder for the specific imported ASCII file
			NewDataFolder/O/S $((SelectedFileName))
			KillWaves/Z wave0, wave1, wave2
			LoadWave/Q/A/D/G/P=ImportDataPath  selectedfile
			Wave wave0
			Wave wave1
			Wave/Z wave2
			KillWaves/Z $(PossiblyQuoteName("q_"+SelectedFileName)), $(PossiblyQuoteName("r_"+SelectedFileName)), $(PossiblyQuoteName("s_"+SelectedFileName))
			Rename wave0, $(PossiblyQuoteName("q_"+SelectedFileName))
			Rename wave1, $(PossiblyQuoteName("r_"+SelectedFileName))
			if(WaveExists(wave2))	//this should be error data, but if they do not exist, we need to fake them. ATSAS assume 4% intensity...
				Rename wave2, $(PossiblyQuoteName("s_"+SelectedFileName))
			else
				Duplicate/O wave1, $(PossiblyQuoteName("s_"+SelectedFileName))
				Wave NewErrWv=$(PossiblyQuoteName("s_"+SelectedFileName))
				NewErrWv *=0.04
			endif
			//need to clean upimported waves, if Intensity is 0, point shoudl be removed... 
			Wave Intensity = $(PossiblyQuoteName("r_"+SelectedFileName))
			Wave Qvec = $(PossiblyQuoteName("q_"+SelectedFileName))
			Wave Error = $(PossiblyQuoteName("s_"+SelectedFileName))
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
static Function IRB1_InitializeImportData()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:Irena
	NewDataFolder/O/S root:Packages:Irena:ImportBioSAXSData
	
	string ListOfStrings
	string ListOfVariables
	variable i
	
	ListOfStrings = "DataPathName;DataExtension;IntName;QvecName;ErrorName;NewDataFolderName;NewIntensityWaveName;DataTypeToImport;"
	ListOfStrings+="NewQWaveName;NewErrorWaveName;NewQErrorWavename;NameMatchString;TooManyPointsWarning;RemoveStringFromName;"
	ListOfVariables = "UseFileNameAsFolder;UseIndra2Names;UseQRSNames;DataContainErrors;UseQISNames;"
	ListOfVariables += "SAXSData;WAXSdata;GroupSamplesTogether;"	
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

	NVAR SAXSData
	NVAR WAXSdata
	if(SAXSData+WAXSdata!=1)
		SAXSData=1
		WAXSdata=0
	endif
	NVAR GroupSamplesTogether
	GroupSamplesTogether = 1
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IRB1_PreviewDataFnct()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	
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
static Function IRB1_DataManPanelFnct()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,1195,800) as "BioSAXS data manipulation"
	DoWIndow/C IRB1_DataManipulationPanel
	TitleBox MainTitle title="BioSAXS data manipulation",pos={140,2},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fSize=22,fColor=(0,0,52224)
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena:BioSAXSDataMan","IRB1_DataManipulationPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	IR3C_MultiAppendControls("Irena:BioSAXSDataMan","IRB1_DataManipulationPanel", "IRB1_DataManAppendOneDataSet","",1,0)
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
	TabControl ProcessingTabs,tabLabel(2)="Scale"
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

	Button SubtractBuffer,pos={280,300},size={190,20}, proc=IRB1_DataManButtonProc,title="4. Subtract Buffer & Save", help={"Subtract Buffer from data and save with _sub in name"}
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

	//tab 3 - scaling data
	TitleBox ScaleInstructions1 title="\Zr1201. Add data (double click)",size={330,15},pos={270,175},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox ScaleInstructions2 title="\Zr1202. Tweak Scaling/background",size={330,15},pos={270,200},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox ScaleInstructions3 title="\Zr1203. Data are saved automatically",size={330,15},pos={270,225},frame=0,fColor=(0,0,65535),labelBack=0

	Button ScaleRangeOfData,pos={280,260},size={190,20}, proc=IRB1_DataManButtonProc,title="4. Scale & Save Selected Data", help={"Load and save selected data and save with _scaled in name"}

	SetVariable DataScalingConstant,pos={280,340},size={220,15}, proc=IRB1_DataManSetVarProc,variable=root:Packages:Irena:BioSAXSDataMan:DataScalingConstant
	NVAR TmpVal = root:Packages:Irena:BioSAXSDataMan:DataScalingConstant
	SetVariable DataScalingConstant, title="Data Scaling :                  ", limits={0,inf,IRB1_SetVariableStepScaling*TmpVal}

	SetVariable ErrorScalingConstant,pos={280,370},size={220,15}, proc=IRB1_DataManSetVarProc,variable=root:Packages:Irena:BioSAXSDataMan:ErrorScalingConstant
	NVAR TmpVal = root:Packages:Irena:BioSAXSDataMan:ErrorScalingConstant
	SetVariable ErrorScalingConstant, title="Error Scaling :                 ", limits={0,inf,IRB1_SetVariableStepScaling*TmpVal}

	SetVariable FlatBackgroundSubtract,pos={280,400},size={220,15}, proc=IRB1_DataManSetVarProc,variable=root:Packages:Irena:BioSAXSDataMan:FlatBackgroundSubtract
	NVAR TmpVal = root:Packages:Irena:BioSAXSDataMan:FlatBackgroundSubtract
	SetVariable FlatBackgroundSubtract, title="Flat background subtract :   ", limits={-inf,inf,IRB1_SetVariableStepScaling*TmpVal}


	///*** end of tabs... 
	Display /W=(521,10,1183,750) /HOST=# /N=LogLogDataDisplay
	SetActiveSubwindow ##
			//	Display /W=(521,350,1183,410) /HOST=# /N=ResidualDataDisplay
			//	SetActiveSubwindow ##
			//	Display /W=(521,420,1183,750) /HOST=# /N=LinearizedDataDisplay
			//	SetActiveSubwindow ##


	SetVariable SleepBetweenDataProcesses,pos={275,640},size={220,15}, noproc,variable=root:Packages:Irena:BioSAXSDataMan:SleepBetweenDataProcesses
	SetVariable SleepBetweenDataProcesses, title="Sleep between data sets", limits={0.0,30,1}

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
//**********************************************************************************************************

Function IRB1_DataManTabProc(tca) : TabControl
	STRUCT WMTabControlAction &tca

	switch( tca.eventCode )
		case 2: // mouse up
			IN2G_PrintDebugStatement(IrenaDebugLevel, 3,"Calling Tabcontrol procedure")
			SVAR DataMatchString = root:Packages:Irena:BioSAXSDataMan:DataMatchString
			NVAR InvertGrepSearch = root:Packages:Irena:BioSAXSDataMan:InvertGrepSearch
			Variable tab = tca.tab
			//tab 0
				Button SelectAllData,win=IRB1_DataManipulationPanel, disable=(tab!=0)
				Button PlotSelectedData,win=IRB1_DataManipulationPanel, disable=(tab!=0)
				TitleBox AverageInstructions,win=IRB1_DataManipulationPanel, disable=(tab!=0)
				Button AverageData,win=IRB1_DataManipulationPanel, disable=(tab!=0)
				Button ClearGraph,win=IRB1_DataManipulationPanel, disable=(tab!=0 && tab!=2)
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
			//tab 2
				TitleBox ScaleInstructions1,win=IRB1_DataManipulationPanel, disable=(tab!=2)
				TitleBox ScaleInstructions2,win=IRB1_DataManipulationPanel, disable=(tab!=2)
				TitleBox ScaleInstructions3,win=IRB1_DataManipulationPanel, disable=(tab!=2)
				SetVariable DataScalingConstant,win=IRB1_DataManipulationPanel, disable=(tab!=2)
				SetVariable ErrorScalingConstant,win=IRB1_DataManipulationPanel, disable=(tab!=2)
				Button ScaleRangeOfData,win=IRB1_DataManipulationPanel, disable=(tab!=2)
				SetVariable FlatBackgroundSubtract,win=IRB1_DataManipulationPanel, disable=(tab!=2)
				
			//other stuff, clear teh graph
				//IRB1_DataManRemoveAllDataSets()
				IN2G_RemoveDataFromGraph(topGraphStr = "IRB1_DataManipulationPanel#LogLogDataDisplay")
			//set controls for names
			if(tab==1)
				InvertGrepSearch = 0
				DataMatchString="ave"
			elseif(tab==0)
				InvertGrepSearch = 1
				DataMatchString="ave|sub"
			elseif(tab==2)
				InvertGrepSearch = 0
				DataMatchString=""
			endif
			
				IR3C_MultiUpdateListOfAvailFiles("Irena:BioSAXSDataMan")
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
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
				Wave SelectionOfAvailableData = root:Packages:Irena:BioSAXSDataMan:SelectionOfAvailableData	
				SelectionOfAvailableData = 1
			endif
			if(stringMatch(ba.ctrlName,"ClearGraph"))
				IN2G_RemoveDataFromGraph(topGraphStr = "IRB1_DataManipulationPanel#LogLogDataDisplay")
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
			if(stringMatch(ba.ctrlName,"ScaleRangeOfData"))
				IRB1_DataManScaleMany()
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
//**********************************************************************************************************

Function IRB1_DataManSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			if(StringMatch(sva.CtrlName, "DataScalingConstant"))
				NVAR TmpVal = root:Packages:Irena:BioSAXSDataMan:DataScalingConstant
				SetVariable DataScalingConstant,win=IRB1_DataManipulationPanel, limits={0,inf,IRB1_SetVariableStepScaling*TmpVal}
				//and here call recalculate the curves....
				IRB1_DataManScaleDataOne()
			endif
			if(StringMatch(sva.CtrlName, "ErrorScalingConstant"))
				NVAR TmpVal = root:Packages:Irena:BioSAXSDataMan:ErrorScalingConstant
				SetVariable ErrorScalingConstant,win=IRB1_DataManipulationPanel, limits={0,inf,IRB1_SetVariableStepScaling*TmpVal}
				//and here call recalculate the curves....
				IRB1_DataManScaleDataOne()
			endif
			if(StringMatch(sva.CtrlName, "FlatBackgroundSubtract"))
				NVAR TmpVal = root:Packages:Irena:BioSAXSDataMan:FlatBackgroundSubtract
				SetVariable FlatBackgroundSubtract,win=IRB1_DataManipulationPanel, limits={0,inf,IRB1_SetVariableStepScaling*TmpVal}
				//and here call recalculate the curves....
				IRB1_DataManScaleDataOne()
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
//
//static Function IRB1_DataManRemoveAllDataSets()
//
//	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
//	DfRef OldDf=GetDataFolderDFR()
//	setDataFolder root:Packages:Irena:BioSAXSDataMan
//	variable i, numTraces
//	string TraceNames
//	
//	TraceNames= TraceNameList("IRB1_DataManipulationPanel#LogLogDataDisplay",";",3)
//	numTraces = ItemsInList(TraceNames)
//	//remove all traces...
//	For(i=0;i<numTraces;i+=1)
//		RemoveFromGraph/W=IRB1_DataManipulationPanel#LogLogDataDisplay /Z $(StringFromList(i,TraceNames))
//	endfor
//
//end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IRB1_DataManAverageDataSetsts()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
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
	UseStdDev = 1
	UseSEM = 0 
	PropagateErrors = 0
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
//**********************************************************************************************************
//**********************************************************************************************************
Function IRB1_DataManAppendSelectedDataSets()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i
	string FoldernameStr
	PauseUpdate
	IN2G_RemoveDataFromGraph(topGraphStr = "IRB1_DataManipulationPanel#LogLogDataDisplay")
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
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:BioSAXSDataMan					//go into the folder
	//IR3D_SetSavedNotSavedMessage(0)
	//figure out if we are doing averaging or buffer subtraction
	ControlInfo /W=IRB1_DataManipulationPanel ProcessingTabs
	variable UsingAveraging=0
	variable Subtracting=0
	variable Scaling=0
	if(V_Value==0)
		UsingAveraging=1
	elseif(V_Value==1)
		Subtracting=1			//buffer subtraction
	elseif(V_Value==2)
		Scaling=1					//scaling data		
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
	IR3C_SelectWaveNamesData("Irena:BioSAXSDataMan", FolderNameStr)			//this routine will preset names in strings as needed,
//	DataFolderName = DataStartFolder+FolderNameStr
//	QWavename = stringFromList(0,IR2P_ListOfWaves("Xaxis","", "IRB1_DataManipulationPanel"))
//	IntensityWaveName = stringFromList(0,IR2P_ListOfWaves("Yaxis","*", "IRB1_DataManipulationPanel"))
//	ErrorWaveName = stringFromList(0,IR2P_ListOfWaves("Error","*", "IRB1_DataManipulationPanel"))
//	if(UseIndra2Data)
//		dQWavename = ReplaceString("Qvec", QWavename, "dQ")
//	elseif(UseQRSdata)
//		dQWavename = "w"+QWavename[1,31]
//	else
//		dQWavename = ""
//	endif
	Wave/Z SourceIntWv=$(DataFolderName+IntensityWaveName)
	Wave/Z SourceQWv=$(DataFolderName+QWavename)
	Wave/Z SourceErrorWv=$(DataFolderName+ErrorWaveName)
	Wave/Z SourcedQWv=$(DataFolderName+dQWavename)
	if(!WaveExists(SourceIntWv)||	!WaveExists(SourceQWv)||!WaveExists(SourceErrorWv))
		Abort "Data selection failed for Data"
	endif
	if(Subtracting)		//subtracting buffer from ave data or scaling data, in each case, must remove the existing files. 
		//preset for user output name for merged data
		UserSourceDataFolderName = StringFromList(ItemsInList(FolderNameStr, ":")-1, FolderNameStr, ":")
		SubtractedOutputFldrName = ReplaceString("_ave", UserSourceDataFolderName, "_sub")
		//remove, if needed, all data from graph
		IN2G_RemoveDataFromGraph(topGraphStr = "IRB1_DataManipulationPanel#LogLogDataDisplay")
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
	if(Scaling)
		//remove, if needed, all data from graph
		IN2G_RemoveDataFromGraph(topGraphStr = "IRB1_DataManipulationPanel#LogLogDataDisplay")
	endif
	CheckDisplayed /W=IRB1_DataManipulationPanel#LogLogDataDisplay SourceIntWv
	if(!V_flag)
		AppendToGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay  SourceIntWv  vs SourceQWv
		ModifyGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay log=1, mirror=1
		Label /W=IRB1_DataManipulationPanel#LogLogDataDisplay left "Intensity 1"
		Label /W=IRB1_DataManipulationPanel#LogLogDataDisplay bottom "Q [A\\S-1\\M]"
		ErrorBars /W=IRB1_DataManipulationPanel#LogLogDataDisplay $(NameOfWave(SourceIntWv)) Y,wave=(SourceErrorWv,SourceErrorWv)
	endif
	if(Scaling)		//in this case we can safely process data or user looks at graph with no change. 
		IRB1_DataManScaleDataOne()
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

static Function IRB1_DataManInitBioSAXS()	

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
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
	ListOfVariables+="OverwriteExistingData;SleepBetweenDataProcesses;"
	ListOfVariables+="BufferScalingFraction;DataQEnd;DataQstart;"
	ListOfVariables+="DataScalingConstant;ErrorScalingConstant;FlatBackgroundSubtract;"

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
	NVAR DataScalingConstant
	NVAR ErrorScalingConstant
	if(DataScalingConstant<1e-30)
		DataScalingConstant=1
	endif
	if(ErrorScalingConstant<1e-30)
		ErrorScalingConstant=1
	endif
	NVAR SleepBetweenDataProcesses
	if(SleepBetweenDataProcesses<0.1)
		SleepBetweenDataProcesses = 2
	endif
	
	Make/O/T/N=(0) ListOfAvailableData
	Make/O/N=(0) SelectionOfAvailableData
	SetDataFolder oldDf

end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//cannot be static, called from panel. 
Function/T IRB1_ListBufferScans()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String AllDataFolders
	AllDataFolders=IR3C_MultiGenStringOfFolders("Irena:BioSAXSDataMan", "root:",0, 1,0, 0,1)
	//seelct only AVeraged data. 
	AllDataFolders = GrepList(AllDataFolders, "ave", 0) 
	
	return AllDataFolders
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

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
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

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

static Function IR1B_DataManCopyAndScaleBuffer()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
static Function IRB1_DataManSubtractBufferMany()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:BioSAXSDataMan:
	IN2G_RemoveDataFromGraph(topGraphStr = "IRB1_DataManipulationPanel#LogLogDataDisplay")
	variable i
	Wave/T ListOfAvailableData = root:Packages:Irena:BioSAXSDataMan:ListOfAvailableData
	Wave SelectionOfAvailableData = root:Packages:Irena:BioSAXSDataMan:SelectionOfAvailableData	
	NVAR SleepBetweenDataProcesses = root:Packages:Irena:BioSAXSDataMan:SleepBetweenDataProcesses
	for(i=0;i<numpnts(ListOfAvailableData);i+=1)
		if(SelectionOfAvailableData[i]>0.5)
			IRB1_DataManAppendOneDataSet(ListOfAvailableData[i])
			IRB1_DataManSubtractBufferOne()
			DoUpdate 
			sleep/S/C=6/M="Subtracted buffer for "+ListOfAvailableData[i] SleepBetweenDataProcesses
		endif
	endfor
	Print "Done subtracting buffer"
	SetDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IRB1_DataManScaleMany()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:BioSAXSDataMan:
	IN2G_RemoveDataFromGraph(topGraphStr = "IRB1_DataManipulationPanel#LogLogDataDisplay")
	variable i
	Wave/T ListOfAvailableData = root:Packages:Irena:BioSAXSDataMan:ListOfAvailableData
	Wave SelectionOfAvailableData = root:Packages:Irena:BioSAXSDataMan:SelectionOfAvailableData	
	NVAR SleepBetweenDataProcesses = root:Packages:Irena:BioSAXSDataMan:SleepBetweenDataProcesses
	for(i=0;i<numpnts(ListOfAvailableData);i+=1)
		if(SelectionOfAvailableData[i]>0.5)
			IRB1_DataManAppendOneDataSet(ListOfAvailableData[i])
			IRB1_DataManScaleDataOne()
			DoUpdate 
			sleep/S/C=6/M="Subtracted buffer for "+ListOfAvailableData[i] SleepBetweenDataProcesses
		endif
	endfor
	Print "Done subtracting buffer"
	SetDataFolder OldDf
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


static Function IRB1_DataManSubtractBufferOne()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
//**********************************************************************************************************

static Function IRB1_DataManScaleDataOne()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:BioSAXSDataMan:
	variable i, numTraces
	string TraceNames
	string OriginalDataNote, BufferDataNote
	
	SVAR SourceFolderName = root:Packages:Irena:BioSAXSDataMan:DataFolderName
	NVAR Overwrite=root:Packages:Irena:BioSAXSDataMan:OverwriteExistingData
	NVAR DataScalingConstant=root:Packages:Irena:BioSAXSDataMan:DataScalingConstant
	NVAR ErrorScalingConstant=root:Packages:Irena:BioSAXSDataMan:ErrorScalingConstant
	NVAR FlatBackgroundSubtract=root:Packages:Irena:BioSAXSDataMan:FlatBackgroundSubtract

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
	Duplicate/Free r_SampleData, ResultsInt
	Duplicate/Free q_SampleData, ResultsQ
	Duplicate/Free s_SampleData, ResultsE
	//process the data
	ResultsInt = DataScalingConstant * (r_SampleData -FlatBackgroundSubtract)
	ResultsE = ErrorScalingConstant * s_SampleData
	
	IN2G_ReplaceNegValsByNaNWaves(ResultsInt,ResultsQ,ResultsE)
	IN2G_RemoveNaNsFrom3Waves(ResultsInt,ResultsQ,ResultsE)

	String OutFldrNm, OutXWvNm, OutYWvNm,OutEWvNm
	OutFldrNm = removeEnding(SourceFolderName,":") + "_scaled"
	string FirstFolderShortName=StringFromList(ItemsInList(OutFldrNm, ":")-1, OutFldrNm, ":")
	string OutputWaveNameMain = RemoveListItem(ItemsInList(FirstFolderShortName,"_")-1, FirstFolderShortName, "_") +"scaled"
	OutYWvNm = "r_"+OutputWaveNameMain
	OutEWvNm = "s_"+OutputWaveNameMain
	OutXWvNm = "q_"+OutputWaveNameMain
	//and now I need to save the data
	if(DataFolderExists(OutFldrNm)&&!Overwrite)
		DoAlert /T="Folder for Scaled data exists" 1, "Folder "+OutFldrNm+" exists, do you want to overwrite?"
		if(V_Flag!=1)
			abort
		endif
	endif
	NewDataFolder/O/S $(RemoveEnding(OutFldrNm , ":") )
	Duplicate/O ResultsQ, $(OutXWvNm)
	Duplicate/O ResultsInt, $(OutYWvNm)
	Duplicate/O ResultsE, $(OutEWvNm)
	Wave NewScaledXWave = $(OutXWvNm)
	Wave NewScaledYWave = $(OutYWvNm)
	Wave NewScaledEWave = $(OutEWvNm)
	print "Scaled data from "+SourceFolderName+"   and saved into new folder :    "+OutFldrNm
	string NewNote
	NewNote="Data scaled;"+date()+";"+time()+";Data Folder="+SourceFolderName+";"
	NewNote+="Intensity values scaled by:"+num2str(DataScalingConstant)+";"+"After subtracting flat background:"+num2str(FlatBackgroundSubtract)+";"
	NewNote+="Error values scaled by:"+num2str(ErrorScalingConstant)+";"
	NewNote+="Prior data note:"+OriginalDataNote+";"
	Note /K/NOCR NewScaledYWave, NewNote
	Note /K/NOCR NewScaledXWave, NewNote
	Note /K/NOCR NewScaledEWave, NewNote
	CheckDisplayed /W=IRB1_DataManipulationPanel#LogLogDataDisplay $(NameOfWave(NewScaledYWave))
	if(V_Flag!=1)
		AppendToGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay  NewScaledYWave  vs NewScaledXWave
		ErrorBars/T=2/L=2 /W=IRB1_DataManipulationPanel#LogLogDataDisplay $(NameOfWave(NewScaledYWave)) Y,wave=(NewScaledEWave,NewScaledEWave)
		ModifyGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay lstyle($(NameOfWave(NewScaledYWave)))=3,lsize($(NameOfWave(NewScaledYWave)))=3,rgb($(NameOfWave(NewScaledYWave)))=(0,0,0)
		ModifyGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay rgb($(NameOfWave(NewScaledYWave)))=(0,0,65535)
	endif
	IN2G_ColorTopGrphRainbow(topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
	IN2G_LegendTopGrphFldr(12, 20, 1, 0, topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
	NVAR DisplayErrorBars = root:Packages:Irena:BioSAXSDataMan:DisplayErrorBars
	IN2G_ShowHideErrorBars(DisplayErrorBars, topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")

	setDataFOlder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


//************************************************************************************************************
//							ATSAS support in Irena Tool
//************************************************************************************************************
//************************************************************************************************************
Function IRB1_PDDFPanelFnct()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,1210,800) as "PDDF Interface"
	DoWIndow/C IRB1_PDDFInterfacePanel
	TitleBox MainTitle title="PDDF using Irena or ATSAS",pos={140,2},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fSize=22,fColor=(0,0,52224)
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena:PDDFInterface","IRB1_PDDFInterfacePanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	IR3C_MultiAppendControls("Irena:PDDFInterface","IRB1_PDDFInterfacePanel", "IRB1_PDDFAppendOneDataSet","",1,0)
	TitleBox Dataselection pos={10,25}
	ListBox DataFolderSelection pos={4,135},size={250,540}
	CheckBox UseIndra2Data disable=3
	CheckBox UseResults disable=3
	CheckBox UseQRSData disable=1
	NVAR UseQRSData = root:Packages:Irena:PDDFInterface:UseQRSData
	NVAR UseResults = root:Packages:Irena:PDDFInterface:UseResults
	NVAR UseIndra2Data = root:Packages:Irena:PDDFInterface:UseIndra2Data
	UseResults = 0
	UseIndra2Data = 0
	UseQRSData = 1
	Button GetHelp,pos={335,50},size={80,15},fColor=(65535,32768,32768), proc=IRB1_DataManButtonProc,title="Get Help", help={"Open www manual page for this tool"}

	SetVariable DataQstart,pos={290,90},size={170,15}, proc=IR3J_SetVarProc,title="Q min for fitting     "
	Setvariable DataQstart, variable=root:Packages:Irena:PDDFInterface:DataQstart, limits={-inf,inf,0}
	SetVariable DataQEnd,pos={290,110},size={170,15}, proc=IR3J_SetVarProc,title="Q max for fitting    "
	Setvariable DataQEnd, variable=root:Packages:Irena:PDDFInterface:DataQEnd, limits={-inf,inf,0}

	TitleBox PDDFInstructions1 title="\Zr100Double click data, pick & run method",size={330,15},pos={270,136},frame=0,fColor=(0,0,65535),labelBack=0
	//PDDFUseGNOM;PDDFuseMoore;PDDFuseregularization
	checkbox PDDFUseGNOM, pos={270,160}, title="GNOM", size={76,14},proc=IRB1_PDDFCheckProc, variable=root:Packages:Irena:PDDFInterface:PDDFUseGNOM, mode=1, help={"Run PDDF using ATSAS gnom"}
	checkbox PDDFUseAutoGNOM, pos={370,160}, title="autoGNOM", size={76,14},proc=IRB1_PDDFCheckProc, variable=root:Packages:Irena:PDDFInterface:PDDFUseAutoGNOM, mode=1, help={"Run PDDF using ATSAS datgnom"}
	checkbox PDDFuseregularization, pos={310,185}, title="Regularization", size={76,14},proc=IRB1_PDDFCheckProc, variable=root:Packages:Irena:PDDFInterface:PDDFuseregularization,mode=1 , help={"Run PDDF using Irena regularization method"}
	checkbox PDDFuseMoore, pos={430,185}, title="Moore", size={76,14},proc=IRB1_PDDFCheckProc, variable=root:Packages:Irena:PDDFInterface:PDDFuseMoore,mode=1,  help={"Run PDDF using Irena Moore method"}
	//controls for various methods as needed... 
	//Dmax
	SetVariable DmaxEstimate,pos={270,212},size={130,15}, noproc,title="Dmax =  ", variable=root:Packages:Irena:PDDFInterface:DmaxEstimate, limits={1,3000,5}, format="%1.4g"
	Button CalculateDmaxOnData,pos={410,213},size={100,15}, proc=IRB1_PDDFButtonProc,title="Calc. Dmax", help={"Calculate Dmax on these data"}
	checkbox CalculateDmaxEstOnImport, pos={270,237}, title="Calc. Dmax on add data?", size={76,14},proc=IRB1_PDDFCheckProc, variable=root:Packages:Irena:PDDFInterface:CalculateDmaxEstOnImport, help={"Calculate Dmax when new data are added (useful when multiprocessing)"}
	//Gnom specifics
	checkbox GnomForceRmin0, pos={270,260}, title="Rmin==0?", size={76,14},proc=IRB1_PDDFCheckProc, variable=root:Packages:Irena:PDDFInterface:GnomForceRmin0, help={"Force Rmin=0 for Gnom"}
	checkbox GnomForceRmax0, pos={400,260}, title="Rmax==0?", size={76,14},proc=IRB1_PDDFCheckProc, variable=root:Packages:Irena:PDDFInterface:GnomForceRmax0, help={"Force Dmax=0 for Gnom"}
	SetVariable GnomAlfaValue,pos={260,285},size={110,15}, noproc,title="Alfa = ",variable=root:Packages:Irena:PDDFInterface:GnomAlfaValue, limits={0,5,0.1}
	//common settings
	SetVariable NumBinsInR,pos={400,285},size={110,15}, noproc,title="R pnts=",variable=root:Packages:Irena:PDDFInterface:NumBinsInR, limits={0,1000,20}
	//Moore settings
	SetVariable MooreNumFunctions,pos={270,315},size={160,15}, noproc,title="Num Func =",variable=root:Packages:Irena:PDDFInterface:MooreNumFunctions, limits={10,300,10}
	checkbox MooreDetNumFunctions, pos={265,340}, title="Det Num Functions?", size={76,14},proc=IRB1_PDDFCheckProc, variable=root:Packages:Irena:PDDFInterface:MooreDetNumFunctions, help={"Determine number of functions"}
	checkbox MooreFitMaxSize, pos={405,340}, title="Fit max size?", size={76,14},proc=IRB1_PDDFCheckProc, variable=root:Packages:Irena:PDDFInterface:MooreFitMaxSize, help={"Fit max size"}
	//run the fit
	Button RunPDDFonData,pos={280,395},size={190,20}, proc=IRB1_PDDFButtonProc,title="Run PDDF on current data", help={"Run PDDF method of yoru choice on these data"}
	Button SelectAllData,pos={265,420},size={80,20}, proc=IRB1_PDDFButtonProc,title="Select All", help={"Select all data in the Listbox"}
	Button RunSequenceofPDDF,pos={360,420},size={150,20}, proc=IRB1_PDDFButtonProc,title="Run all selected", help={"Run GNOM on these data"}
	//calculated results
	TitleBox PDDFInstructions2 title="\Zr120Calculated results:",size={330,15},pos={300,448},frame=0,fColor=(0,0,65535),labelBack=0
	SetVariable CalculatedRg,pos={270,470},size={200,15}, noproc,title="Calculated Rg =     ",variable=root:Packages:Irena:PDDFInterface:CalculatedRg, disable=0, noedit=1,limits={0,inf,0},frame=0,fstyle=1, fsize=13
	SetVariable CalculatedI0,pos={270,490},size={200,15}, noproc,title="Calculated I0 =     ",variable=root:Packages:Irena:PDDFInterface:CalculatedI0,  disable=0, noedit=1,limits={0,inf,0},frame=0,fstyle=1, fsize=13
	//ConcentrationForCals;ScattLengthDensDifference;CalculatedMW
	SetVariable ConcentrationForCals,pos={270,510},size={220,15}, proc=IR1B_PDDFSetVarProc,title="c [mg/ml] =              ",variable=root:Packages:Irena:PDDFInterface:ConcentrationForCals,limits={0,inf,0.1}, help={"Concentration for MW calculations"}
	SetVariable ScattLengthDensDifference,pos={270,530},size={220,15}, proc=IR1B_PDDFSetVarProc,title="SLD [10^10 cm^-2]= ",variable=root:Packages:Irena:PDDFInterface:ScattLengthDensDifference,  limits={0.01,100,0.1}, help={"Scattering length density (without 10^10)"}
	SetVariable CalculatedMW,pos={270,555},size={200,15}, noproc,title="Calculated MW =     ",variable=root:Packages:Irena:PDDFInterface:CalculatedMW, disable=0, noedit=1,limits={0,inf,0},frame=0,fstyle=1, fsize=13
	//Buttons for results	
	TitleBox PDDFInstructions3 title="\Zr100How to save results?",size={330,15},pos={320,575},frame=0,fColor=(0,0,65535),labelBack=0
	checkbox SaveToFolderAutomatically, pos={265,591}, title="Folder", size={76,14},noproc, variable=root:Packages:Irena:PDDFInterface:SaveToFolderAutomatically, mode=0, help={"Save to folder when running sequence"}
	checkbox SaveToNotebookAutomatically, pos={340,591}, title="Notebook", size={76,14},noproc, variable=root:Packages:Irena:PDDFInterface:SaveToNotebookAutomatically, mode=0, help={"Save to notebook when running sequence"}
	checkbox SaveToWavesAutomatically, pos={430,591}, title="Waves", size={76,14},noproc, variable=root:Packages:Irena:PDDFInterface:SaveToWavesAutomatically, mode=0, help={"Save to notebook when running sequence"}
	Button SavePDDFresults,pos={280,612},size={190,20}, proc=IRB1_PDDFButtonProc,title="Save PDDF results", help={"Save PDDF results to folder"}

	Button OpenResultsAndTable,pos={280,643},size={190,15}, proc=IRB1_PDDFButtonProc,title="Open Table and Notebook", help={"Open Table and Notebook with results"}
	Button DeleteResultsAndTable,pos={280,662},size={190,15}, proc=IRB1_PDDFButtonProc,title="Delete results waves", help={"Delete waves wirth results, this will clean the records!"}

	SetVariable SleepBetweenDataProcesses,pos={275,684},size={220,15}, noproc,variable=root:Packages:Irena:PDDFInterface:SleepBetweenDataProcesses
	SetVariable SleepBetweenDataProcesses, title="Sleep between data sets", limits={0.0,30,1}
	Checkbox OverwriteExistingData, pos={250,705},size={76,14},title="Overwrite Ouput?", noproc, variable=root:Packages:Irena:PDDFInterface:OverwriteExistingData
	Checkbox DisplayErrorBars, pos={390,705},size={76,14},title="Display Error Bars", proc=IRB1_PDDFCheckProc, variable=root:Packages:Irena:PDDFInterface:DisplayErrorBars
	Button AutoScaleGraph,pos={350,730},size={140,15}, proc=IRB1_PDDFButtonProc,title="Autoscale Graph", help={"Autoscale the graph axes"}

	//create graph
	
	Display /W=(521,10,1183,410) /HOST=# /N=DataDisplay
	SetActiveSubwindow ##

	Display /W=(521,420,1183,750) /HOST=# /N=PDFDisplay
	SetActiveSubwindow ##

	TitleBox Instructions1 title="\Zr100Double click to add data to graph",size={330,15},pos={4,680},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions2 title="\Zr100Shift-click to select range of data",size={330,15},pos={4,695},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions3 title="\Zr100Ctrl/Cmd-click to select one data set",size={330,15},pos={4,710},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions4 title="\Zr100Regex for not contain: ^((?!string).)*$",size={330,15},pos={4,725},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions5 title="\Zr100Regex for contain:  string, two: str2.*str1",size={330,15},pos={4,740},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions6 title="\Zr100Regex for case independent:  (?i)string",size={330,15},pos={4,755},frame=0,fColor=(0,0,65535),labelBack=0	
	
	IR1B_PDDFSetControls()
end
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1B_PDDFSetControls()
	
	NVAR PDDFUseGNOM					=root:Packages:Irena:PDDFInterface:PDDFUseGNOM
	NVAR PDDFuseMoore					=root:Packages:Irena:PDDFInterface:PDDFuseMoore	
	NVAR PDDFuseregularization		=root:Packages:Irena:PDDFInterface:PDDFuseregularization
	NVAR PDDFUseAutoGNOM				=root:Packages:Irena:PDDFInterface:PDDFUseAutoGNOM

	checkbox GnomForceRmin0, win=IRB1_PDDFInterfacePanel, disable=!PDDFUseGNOM
	checkbox GnomForceRmax0, win=IRB1_PDDFInterfacePanel, disable=!PDDFUseGNOM
	SetVariable GnomAlfaValue, win=IRB1_PDDFInterfacePanel, disable=!PDDFUseGNOM
	//common settings
	SetVariable NumBinsInR, win=IRB1_PDDFInterfacePanel, disable=PDDFUseAutoGNOM
	//Moore settings
	SetVariable MooreNumFunctions, win=IRB1_PDDFInterfacePanel, disable=!PDDFuseMoore
	checkbox MooreDetNumFunctions, win=IRB1_PDDFInterfacePanel, disable=!PDDFuseMoore
	checkbox MooreFitMaxSize, win=IRB1_PDDFInterfacePanel, disable=!PDDFuseMoore
end
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1B_PDDFSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
			if(StringMatch(sva.ctrlName, "ConcentrationForCals" )||StringMatch(sva.ctrlName, "ScattLengthDensDifference" ))
				IRB1_PDDFCalculateRgI0()
			endif
			break
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************
Function IRB1_PDDFCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(stringmatch(cba.ctrlname,"DisplayErrorBars"))
				pauseUpdate
				NVAR DisplayErrorBars = root:Packages:Irena:PDDFInterface:DisplayErrorBars
				IN2G_ShowHideErrorBars(DisplayErrorBars, topGraphStr="IRB1_PDDFInterfacePanel#DataDisplay")
				DoUpdate
			endif
			NVAR PDDFUseGNOM = root:Packages:Irena:PDDFInterface:PDDFUseGNOM
			NVAR PDDFuseMoore = root:Packages:Irena:PDDFInterface:PDDFuseMoore
			NVAR PDDFuseregularization = root:Packages:Irena:PDDFInterface:PDDFuseregularization
			NVAR PDDFUseAutoGNOM = root:Packages:Irena:PDDFInterface:PDDFUseAutoGNOM
			if(stringmatch(cba.ctrlname,"PDDFUseGNOM"))
				if(checked)
					//PDDFUseGNOM = 0
					PDDFuseMoore = 0
					PDDFuseregularization = 0
					PDDFUseAutoGNOM = 0
				endif
				IR1B_PDDFSetControls()
			endif
			if(stringmatch(cba.ctrlname,"PDDFUseAutoGNOM"))
				if(checked)
					PDDFUseGNOM = 0
					PDDFuseMoore = 0
					PDDFuseregularization = 0
					PDDFUseAutoGNOM = 1
				endif
				IR1B_PDDFSetControls()
			endif
			if(stringmatch(cba.ctrlname,"PDDFuseMoore"))
				if(checked)
					PDDFUseGNOM = 0
					//PDDFuseMoore = 0
					PDDFuseregularization = 0
					PDDFUseAutoGNOM = 0
				endif
				IR1B_PDDFSetControls()
			endif
			if(stringmatch(cba.ctrlname,"PDDFuseregularization"))
				if(checked)
					PDDFUseGNOM = 0
					PDDFuseMoore = 0
					//PDDFuseregularization = 0
					PDDFUseAutoGNOM = 0
				endif
				IR1B_PDDFSetControls()
			endif
			
		
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************

Function IRB1_PDDFButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringMatch(ba.ctrlName,"RunPDDFonData"))
				NVAR PDDFUseGNOM = root:Packages:Irena:PDDFInterface:PDDFUseGNOM
				NVAR PDDFuseMoore = root:Packages:Irena:PDDFInterface:PDDFuseMoore
				NVAR PDDFuseregularization = root:Packages:Irena:PDDFInterface:PDDFuseregularization
				if(PDDFuseregularization)
					IRB1_PDDFRunIrenaPDDF()
					IRB1_PDDFMakeResChi2()
					IRB1_PDDFAppendPDDFModel() 
					IRB1_PDDFCalculateRgI0()
				elseif(PDDFuseMoore)
					IRB1_PDDFRunIrenaPDDF()
					IRB1_PDDFMakeResChi2()
					IRB1_PDDFAppendPDDFModel()
					IRB1_PDDFCalculateRgI0()
				else //this is autognom or gom, handled by oen function
					IRB1_PDDFRunGNOM()
					IRB1_PDDFMakeResChi2()
					IRB1_PDDFAppendPDDFModel()				
					IRB1_PDDFCalculateRgI0()
				endif
			endif
			if(stringMatch(ba.ctrlName,"SavePDDFresults"))
				IRB1_PDDFSaveResultsToNotebook()
				IRB1_PDDFSaveResultsToFldr()
				IRB1_PDDFSaveToWaves()
			endif
			if(stringMatch(ba.ctrlName,"RunSequenceofPDDF"))
				IRB1_PDDFFitSequenceOfData()
			endif
			if(stringMatch(ba.ctrlName,"SelectAllData"))
				Wave SelectionOfAvailableData = root:Packages:Irena:PDDFInterface:SelectionOfAvailableData	
				SelectionOfAvailableData = 1
			endif
			if(stringMatch(ba.ctrlName,"ClearGraph"))
				IN2G_RemoveDataFromGraph(topGraphStr = "IRB1_PDDFInterfacePanel#DataDisplay")
			endif
			if(stringMatch(ba.ctrlName,"AutoScaleGraph"))
				SetAxis/W=IRB1_PDDFInterfacePanel#DataDisplay /A
			endif
			if(stringmatch(ba.ctrlName,"GetHelp"))
				IN2G_OpenWebManual("Irena/ImportData.html")				//fix me!!			
			endif
			if(stringMatch(ba.ctrlName,"CalculateDmaxOnData"))
				IRB1_PDDFEstimateRgAndDmax()
			endif
			if(stringMatch(ba.ctrlName,"OpenResultsAndTable"))
				IR1_CreateResultsNbk()
				DoWindow IRB1_PDDFFitResultsTable
				if(V_Flag)
					DoWIndow/F IRB1_PDDFFitResultsTable
				else
					IRB1_PDDFFitResultsTableFnct()
				endif		
			endif
			if(stringMatch(ba.ctrlName,"DeleteResultsAndTable"))
				KillWIndow/Z IRB1_PDDFFitResultsTable
				KillDataFOlder/Z root:PDDFFitResults: 
			endif


			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************

static Function IRB1_PDDFFitSequenceOfData()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		Wave SelectionOfAvailableData = root:Packages:Irena:PDDFInterface:SelectionOfAvailableData
		Wave/T ListOfAvailableData = root:Packages:Irena:PDDFInterface:ListOfAvailableData
		NVAR SleepBetweenDataProcesses=root:Packages:Irena:PDDFInterface:SleepBetweenDataProcesses
		variable i, imax
		imax = numpnts(ListOfAvailableData)
		For(i=0;i<imax;i+=1)
			if(SelectionOfAvailableData[i]>0.5)		//data set selected
				IRB1_PDDFAppendOneDataSet(ListOfAvailableData[i])
				NVAR PDDFUseGNOM = root:Packages:Irena:PDDFInterface:PDDFUseGNOM
				NVAR PDDFuseMoore = root:Packages:Irena:PDDFInterface:PDDFuseMoore
				NVAR PDDFuseregularization = root:Packages:Irena:PDDFInterface:PDDFuseregularization
				if(PDDFuseregularization)
					IRB1_PDDFRunIrenaPDDF()
					IRB1_PDDFMakeResChi2()
					IRB1_PDDFAppendPDDFModel() 
					IRB1_PDDFCalculateRgI0()
				elseif(PDDFuseMoore)
					IRB1_PDDFRunIrenaPDDF()
					IRB1_PDDFMakeResChi2()
					IRB1_PDDFAppendPDDFModel()
					IRB1_PDDFCalculateRgI0()
				else
					IRB1_PDDFRunGNOM()
					IRB1_PDDFMakeResChi2()
					IRB1_PDDFAppendPDDFModel()	
					IRB1_PDDFCalculateRgI0()			
				endif
				IRB1_PDDFSaveResultsToNotebook()
				IRB1_PDDFSaveResultsToFldr()
				IRB1_PDDFSaveToWaves()
				DoUpdate 
				if(SleepBetweenDataProcesses>0.5)
					sleep/S/C=6/M="Fitted data for "+ListOfAvailableData[i] SleepBetweenDataProcesses
				endif
			endif
		endfor
		print "all selected data processed"
end
//**********************************************************************************************************

Function IRB1_PDDFCalculateRgI0()

	NVAR CalcRg=root:Packages:Irena:PDDFInterface:CalculatedRg
	NVAR CalcI0=root:Packages:Irena:PDDFInterface:CalculatedI0
	Wave Radius = root:Packages:Irena:PDDFInterface:pddfRadius
	Wave Pr = root:Packages:Irena:PDDFInterface:pddfPr
	NVAR ConcentrationForCals=root:Packages:Irena:PDDFInterface:ConcentrationForCals
	NVAR ScattLengthDensDifference=root:Packages:Irena:PDDFInterface:ScattLengthDensDifference
	NVAR CalculatedMW=root:Packages:Irena:PDDFInterface:CalculatedMW
	
	Duplicate/Free Pr, R2Pr
	R2Pr = Radius^2 * Pr
	
	CalcI0 = 4*pi*areaXY(Radius, Pr )
	
	CalcRg = sqrt(areaXY(Radius, R2Pr )/areaXY(Radius, Pr ))
	
	CalculatedMW = 6.023e23*CalcI0/(ConcentrationForCals*(ScattLengthDensDifference*1e10)^2)

end
//**********************************************************************************************************
//**********************************************************************************************************

static Function IRB1_PDDFEstimateRgAndDmax()
	//copy of IR2Pr_EstimateDmax

	DFref oldDf= GetDataFolderDFR()
	setDataFolder root:Packages:Irena:PDDFInterface

	Wave OriginalIntensity=root:Packages:Irena:PDDFInterface:Intensity
	Wave OriginalQvector=root:Packages:Irena:PDDFInterface:Q_vec
	Wave OriginalError=root:Packages:Irena:PDDFInterface:Errors
	variable AcsrPnt=pcsr(A, "IRB1_PDDFInterfacePanel#DataDisplay")
	variable BcsrPnt=pcsr(B, "IRB1_PDDFInterfacePanel#DataDisplay")

	variable Rg
	Variable G
	Variable B
	G = OriginalIntensity[0]
	FindLevel /P/Q OriginalIntensity, OriginalIntensity[0]*0.3
	variable GetQAtRg=OriginalQvector[V_levelX]
	Rg = 2/GetQAtRg
	B = OriginalIntensity[V_levelX]*OriginalQvector[V_levelX]^4
	Make /N=5/O W_coef, LocalEwave
	Make/N=5/T/O T_Constraints
	T_Constraints[0] = {"K1 > 0"}
	T_Constraints[1] = {"K0 > 0"}
	T_Constraints[2] = {"K2 > 0"}
	T_Constraints[3] = {"K3 > 2"}
	T_Constraints[4] = {"K4 > 0"}
	Variable V_FitError=0			//This should prevent errors from being generated
	W_coef[0]=G 	//G
	W_coef[1]=Rg	//Rg
	W_coef[2]=B	//B
	W_coef[3]=4	//Porod slope
	W_coef[4]=OriginalIntensity[numpnts(OriginalIntensity)-20]	//background
	FuncFit IRB1_PDDFIntensityFit W_coef OriginalIntensity[AcsrPnt,]  /X=OriginalQvector /C=T_Constraints //W=OriginalError //I=1//E=LocalEwave 
	if (V_FitError!=0)	//there was error in fitting
		beep
		Abort "Fitting error, Cannot fit Rg" 
	endif
	Duplicate/O OriginalIntensity, QstarVector, GuessFitScattProfile
	QstarVector = OriginalQvector / (erf(OriginalQvector*w_coef[1]/sqrt(6)))^3
	GuessFitScattProfile =  w_coef[0]*exp(-OriginalQvector^2*w_coef[1]^2/3)+(w_coef[2]/QstarVector^w_coef[3]) + w_coef[4]
	CheckDisplayed /W=IRB1_PDDFInterfacePanel#DataDisplay  GuessFitScattProfile  
	if(!V_flag)
		GetAxis /W=IRB1_PDDFInterfacePanel#DataDisplay /Q left
		AppendToGraph  /W=IRB1_PDDFInterfacePanel#DataDisplay  GuessFitScattProfile  vs OriginalQvector
		SetAxis/W=IRB1_PDDFInterfacePanel#DataDisplay left, V_min, V_max
		ModifyGraph /W=IRB1_PDDFInterfacePanel#DataDisplay lstyle(GuessFitScattProfile)=2,lsize(GuessFitScattProfile)=1
		ModifyGraph /W=IRB1_PDDFInterfacePanel#DataDisplay rgb(GuessFitScattProfile)=(1,3,39321)
	endif
	//Update tag result...
	string Tagtext="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("TagSize")+"Fitted Rg [A] = "+num2str(W_Coef[1])+"\r"
	Tagtext+="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("TagSize")+"Fitted I0 = "+num2str(W_Coef[0])
	Tag/C/N=GuessRg/L=0/TL=0/W=IRB1_PDDFInterfacePanel#DataDisplay GuessFitScattProfile, numpnts(GuessFitScattProfile)/10,Tagtext

	NVAR Dmax=root:Packages:Irena:PDDFInterface:DmaxEstimate
	Dmax=2.5*abs(W_coef[1])
	KillWaves/Z LocalEwave, W_coef, T_constraints, QstarVector
	SetDataFolder oldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IRB1_PDDFIntensityFit(w,q) : FitFunc
	Wave w
	Variable q

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ Prefactor=abs(Prefactor)
	//CurveFitDialog/ Rg=abs(Rg)
	//CurveFitDialog/ f(q) = Prefactor*exp(-q^2*Rg^2/3))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Prefactor
	//CurveFitDialog/ w[1] = Rg
	//CurveFitDialog/ w[2] = Porod prefactor
	//CurvefitDialog/ w[3] = PorodSlope
	//CurvefitDialog/ w[4] = Background

	w[0]=abs(w[0])
	w[1]=abs(w[1])
	w[2]=abs(w[2])
	w[3]=abs(W[3])
	w[4]=abs(W[4])
	variable qstar=q/(erf(q*w[1]/sqrt(6)))^3
	return w[0]*exp(-q^2*w[1]^2/3)+(w[2]/qstar^w[3])+w[4]
//	QstarVector=QvectorWave/(erf(QvectorWave*Rg/sqrt(6)))^3
//G*exp(-QvectorWave^2*Rg^2/3)+(B/QstarVector^P) 

End

//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//**********************************************************************************************************
static Function IRB1_PDDFMakeResChi2()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	setDataFolder root:Packages:Irena:PDDFInterface
	wave/Z pddfInputIntensity = root:Packages:Irena:PDDFInterface:pddfInputIntensity
	Wave/Z pddfInputError = root:Packages:Irena:PDDFInterface:pddfInputError
	Wave/Z pddfModelIntensity = root:Packages:Irena:PDDFInterface:pddfModelIntensity
	Wave/Z pddfRadius				=root:Packages:Irena:PDDFInterface:pddfRadius
	Wave/Z pddfPr					=root:Packages:Irena:PDDFInterface:pddfPr
	if(!WaveExists(pddfInputIntensity)||!WaveExists(pddfPr)||!WaveExists(pddfModelIntensity))
		return 0
	endif
	Duplicate/O pddfInputIntensity, NormalizedResidual, ChisquaredWave	//waves for data
	IN2G_AppendorReplaceWaveNote("NormalizedResidual","Units"," ")
	IN2G_AppendorReplaceWaveNote("ChisquaredWave","Units"," ")
	NormalizedResidual=(pddfInputIntensity-pddfModelIntensity)/pddfInputError		//we need this for graph
	ChisquaredWave=NormalizedResidual^2											//and this is wave with Chisquared
	Duplicate/O pddfPr, CurrentResultsGamma
	CurrentResultsGamma = pddfPr/(4*pi*pddfPr^2)

	setDataFolder oldDF
end
//**********************************************************************************************************
//**********************************************************************************************************

Function IRB1_PDDFRunGNOM()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	//OK, these are existing data user wants to run ATSAS DATGNOM (formerly known as AUTOGNOM)
	//https://www.embl-hamburg.de/biosaxs/manuals/datpddf.html
	//process: 
	//1. write out ASCII file q,r,s
	//2. run script for DATGNOM
	//3. load final result back in and display for users. 
	SVAR DataFolderName=root:Packages:Irena:PDDFInterface:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena:PDDFInterface:IntensityWaveName
	SVAR QWavename=root:Packages:Irena:PDDFInterface:QWavename
	SVAR ErrorWaveName=root:Packages:Irena:PDDFInterface:ErrorWaveName
	NVAR DataQEnd = root:Packages:Irena:PDDFInterface:DataQEnd
	NVAR DataQstart = root:Packages:Irena:PDDFInterface:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:PDDFInterface:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:PDDFInterface:DataQstartPoint

	SVAR DATGNOMLocation=root:Packages:Irena:PDDFInterface:DATGNOMLocation
	SVAR FittingResults=root:Packages:Irena:PDDFInterface:FittingResults
	//parameters to use...
	NVAR DmaxEstimate=root:Packages:Irena:PDDFInterface:DmaxEstimate
	NVAR NumBinsInR=root:Packages:Irena:PDDFInterface:NumBinsInR
	NVAR GnomForceRmin0=root:Packages:Irena:PDDFInterface:GnomForceRmin0
	NVAR GnomForceRmax0=root:Packages:Irena:PDDFInterface:GnomForceRmax0
	NVAR GnomAlfaValue=root:Packages:Irena:PDDFInterface:GnomAlfaValue
	NVAR PDDFUseGNOM					=root:Packages:Irena:PDDFInterface:PDDFUseGNOM
	NVAR PDDFUseAutoGNOM				=root:Packages:Irena:PDDFInterface:PDDFUseAutoGNOM


	//locate system tempPath
	newPath/O/Q/C ATSASWorkPath, (SpecialDirPath("Temporary", 0, 0, 0)+"IrenaATSAStmp:")		//this is Igor formated path
	PathInfo ATSASWorkPath
	String PathToATSASWorkPath = ParseFilePath(5, S_Path, "*", 0, 0) 							//this is system formated path
	////   PRG2 HD:Users:ilavsky:tmp:IrenaATSAStmp:
	//locate DATGNOM
	PathInfo DATGNOMPath
	if(V_Flag<0.5)	//does not exist
		newPath/O/Q/Z DATGNOMPath, DATGNOMLocation		//this is Igor formated path
		if(V_Flag!=0)
			string PathToApps = SpecialDirPath("Igor Application", 0, 0, 0)
			PathToApps = RemoveListItem(ItemsInList(PathToApps, ":")-1, PathToApps, ":")		//remove Igor Pro X Folder
			PathToApps = RemoveFromList("Wavemetrics", PathToApps, ":", 0)		//Remove Wavemetrics folder
			newPath/O/Q/Z DATGNOMPath, PathToApps
		endif
	endif
	//now, find if the DATGNOM
	//are we on Windows or mac? 
	string datgnomName=""
	string datgnomNameTemp
	if(PDDFUseGNOM)
		datgnomName="gnom"
	elseif(PDDFUseAutoGNOM)
		datgnomName="datgnom"
	else
		Abort "Unknown gnom executable selected"
	endif
	//On WIndows, to test for gnom, need gnom.exe, but to run, no extension. Make life difficutl...  
	if(stringmatch(IgorInfo(2),"Windows"))
		datgnomNameTemp=datgnomName+".exe"
	else
		datgnomNameTemp=datgnomName
	endif
	GetFileFolderInfo /Q/Z/P=DATGNOMPath datgnomNameTemp
	if(V_Flag!=0)
		DoAlert /T="GNOM/datGNOM executable not found" 0, "In next dialog locate FOLDER, where executable gnom (gnom.exe) and datgnom (datgnom.exe) files are located, please. Typically Windows: Program Files (x86)\ATSAS 3.01\bin and MacOS: Applications:ATSAS:bin"
		GetFileFolderInfo/D/P=DATGNOMPath datgnomNameTemp
		newPath/O/Q/Z DATGNOMPath, S_Path
		DATGNOMLocation = S_Path
	endif
	//At this moment we should have DATGNOMLocation be string with Igor path to datpddf and datpddfeName be name of executable. 
	GetFileFolderInfo /Q/Z/P=DATGNOMPath datgnomNameTemp
	if(V_Flag!=0)
		Abort "Cannot find properly datgnom executable, something is worng here. Report as bug to author, please"  
	endif	
	//now export the data file.
	Wave/Z SourceIntWv=$(DataFolderName+IntensityWaveName)
	Wave/Z SourceQWv=$(DataFolderName+QWavename)
	Wave/Z SourceErrorWv=$(DataFolderName+ErrorWaveName)
	if(!WaveExists(SourceIntWv)||!WaveExists(SourceQWv)||!WaveExists(SourceErrorWv))
		Abort "Cannot find QRS data to export" 
	endif
	//trim data to user selected range
	Duplicate/Free/R=[DataQstartPoint,DataQEndPoint] SourceQWv, ExportQ
	Duplicate/Free/R=[DataQstartPoint,DataQEndPoint] SourceIntWv, ExportInt
	Duplicate/Free/R=[DataQstartPoint,DataQEndPoint] SourceErrorWv, ExportErr
	//save the data file. Simply 3 columns, QRS
	Save/G/O/M="\n"/P=ATSASWorkPath ExportQ,ExportInt,ExportErr as "DataIn.dat"
	//create script file...
	string cmd, ATSASPath, OutputFilePath, InputFilePath
	ATSASPath = RemoveFromList("bin", DATGNOMLocation, ":") 
	//notes on how to run this nightmare:
	//1. One needs to change directory to ATSAS folder. 
	//2. there we can start ./bin/datpddf4 
	//3. Input file must have absolute path to file
	//4. Need to specify absolute file to output file, or it will be created in ATSAS folder...
	//Oh dear...   
	string rminForce, rmaxForce, alphaValForce, NumBinsForce, RgForce, GnomWInPath, wincmd
	if(GnomForceRmin0)
		//rminForce=" --rmin=Yes "
		rminForce=""
	else
		rminForce=" --rmin=No "
	endif
	if(GnomForceRmax0)
		rmaxForce=""
		//rmaxForce=" --rmax=Yes "
	else
		rmaxForce=" --rmax=No "
	endif
	if(GnomAlfaValue>0.001)
		alphaValForce=" --alpha="+num2str(GnomAlfaValue)+" "
	else
		alphaValForce=""
	endif
	if(NumBinsInR>0.001)
		NumBinsForce=" --nr="+num2str(NumBinsInR)+" "
	else
		NumBinsForce=""
	endif
	RgForce = " --rmax="+Num2Str(DmaxEstimate)
	string unixCmd, igorCmd
	if(stringmatch(IgorInfo(2),"Windows"))								//Windows script... 	
		//this will need to be customized on Windows... 
		GnomWInPath =  ParseFilePath(5, DATGNOMLocation, "\\", 0, 0)
		InputFilePath = ParseFilePath(5, PathToATSASWorkPath, "\\", 0, 0)+"DataIn.dat"
		OutputFilePath = ParseFilePath(5, PathToATSASWorkPath, "\\", 0, 0)+"DataOut.out"	
		if(PDDFUseGNOM)
			//and now build it together
			//note, this is needeed, see the " - whole command is "" as well as each part which may contain spaces. 
			//example from https://stackoverflow.com/questions/6376113/how-do-i-use-spaces-in-the-command-prompt
			//  cmd /C ""C:\Program Files (x86)\WinRar\Rar.exe" a "D:\Hello 2\File.rar" "D:\Hello 2\*.*""
			wincmd="cmd.exe /C \"\""+GnomWInPath+datgnomName+".exe\" \""+InputFilePath+"\""+RgForce+NumBinsForce+alphaValForce+rmaxForce+rminForce+" -o \""+OutputFilePath+"\"\""		
			//print wincmd
		elseif(PDDFUseAutoGNOM)
			wincmd="cmd.exe /C  \"\""+GnomWInPath+datgnomName+".exe\" \""+InputFilePath+"\" -r "+Num2Str(DmaxEstimate)+" -o \""+OutputFilePath+"\"\""			
			//print wincmd
		else
			ABort "Unknown gnom executable selected"
		endif
		ExecuteScriptText/Z  wincmd
		if(V_Flag!=0)	//error happened
			Abort "There was error scripting and running GNOM/DATGNOM" 
		endif
		//Print S_value		// actually datgnom adn gnom do report anything contrary to datgnom4... 
		//FittingResults = S_value
	else										//Mac, need to convert to Posix path
		ATSASPath = "'"+ParseFilePath(9, ATSASPath, "*", 0, 0)+"'"
		InputFilePath ="'"+ ParseFilePath(9, PathToATSASWorkPath, "*", 0, 0)+"DataIn.dat'"
		OutputFilePath = "'"+ParseFilePath(9, PathToATSASWorkPath, "*", 0, 0)+"DataOut.out'"	
		if(PDDFUseGNOM)
			//and now build it together
			unixCmd="cd "+ATSASPath+";./bin/"+datgnomName+" "+InputFilePath+RgForce+NumBinsForce+alphaValForce+rmaxForce+rminForce+" -o "+OutputFilePath		
		elseif(PDDFUseAutoGNOM)
			unixCmd="cd "+ATSASPath+";./bin/"+datgnomName+" "+InputFilePath+" -r "+Num2Str(DmaxEstimate)+" -o "+OutputFilePath		
		else
			ABort "Unknown gnom executable selected"
		endif
		//unixCmd="cd "+ATSASPath+";./bin/"+datgnomName+" "+InputFilePath+" -r "+Num2Str(DmaxEstimate)+" -o "+OutputFilePath	
		sprintf igorCmd, "do shell script \"%s\"", unixCmd
		Print igorCmd		// For debugging only
		ExecuteScriptText/UNQ/Z igorCmd
		if(V_Flag!=0)	//error happened
			Abort "There was error scripting and running GNOM/DATGNOM" 
		endif
		//Print S_value		// actually datgnom adn gnom do report anything contrary to datgnom4... 
		//FittingResults = S_value
	endif
	//import GNOM output file in Irena
	KillDataFolder/Z root:Packages:Irena:PDDFTemp
	NewDataFolder/O/S root:Packages:Irena:PDDFTemp	
	LoadWave/G/D/Q/N/P=ATSASWorkPath "DataOut.out"
	variable NumLoadedWaves = ItemsInList(S_waveNames,";")
	//now looking at this...
	//last three waves are      R          P(R)      ERROR
	//lets call them something useful 
	Wave pddfRad = $("wave"+num2str(NumLoadedWaves-3))
	Wave pddfPrr = $("wave"+num2str(NumLoadedWaves-2))
	Wave pddfEr = $("wave"+num2str(NumLoadedWaves-1))
	//five before that are:     S          J EXP       ERROR       J REG       I REG
	Wave pddfModelIntGunier = $("wave"+num2str(NumLoadedWaves-4))
	Wave pddfModelInt = $("wave"+num2str(NumLoadedWaves-5))
	Wave pddfInputErr = $("wave"+num2str(NumLoadedWaves-6))
	Wave pddfInputInt = $("wave"+num2str(NumLoadedWaves-7))
	Wave pddfQvec = $("wave"+num2str(NumLoadedWaves-8))					
	//and this is the main part where thre are all columns.
	//early part of column 1 and 5 are in 
	Wave pddfQvecSt = $("wave"+num2str(NumLoadedWaves-10))					
	Wave pddfModelIntGunierSt = $("wave"+num2str(NumLoadedWaves-9))
	//great. how do we call this stuff??? 
	//fix for unknown data, columnd 5 designated as pddfModelErr seems to have copy fo column 4 in it
	//seems like extended model data to Q=0.
	//For now not sure what to do with it,. so set to 0
	//If possible, I would like to have three sets of SAXS data from this out file: 
	//(1) col #1, #2, #3 (with same meaningful length); 
	//(2) col #1, #4, #3; and 
	//(3) col #1, #5
	//Last column is the fitted data with intensities extrapolating to q=0 using Guinier equation.
 	//SAXS data (3) sometime is useful.
	SetDataFolder root:Packages:Irena:PDDFInterface:
	Duplicate/O pddfQvec, pddfInputQVector
	Duplicate/O pddfInputInt, pddfInputIntensity
	Duplicate/O pddfInputErr, pddfInputError
	Duplicate/O pddfQvec, pddfModelQvector
	Duplicate/O pddfModelInt, pddfModelIntensity
	Duplicate/O pddfRad, pddfRadius
	Duplicate/O pddfPrr, pddfPr
	Duplicate/O pddfEr, pddfPrError
	//now the extetrapolated data
	Make/O/N=(numpnts(pddfModelIntGunierSt)+numpnts(pddfModelIntGunier)), pddfQvecExtrap, pddfModelIntExtrap
	pddfQvecExtrap[0,numpnts(pddfModelIntGunierSt)-1] = pddfQvecSt[p]
	pddfQvecExtrap[numpnts(pddfModelIntGunierSt), ] = pddfQvec[p-numpnts(pddfModelIntGunierSt)]
	pddfModelIntExtrap[0,numpnts(pddfModelIntGunierSt)-1] = pddfModelIntGunierSt[p]
	pddfModelIntExtrap[numpnts(pddfModelIntGunierSt), ] = pddfModelIntGunier[p-numpnts(pddfModelIntGunierSt)]
	
	//and delete teh path we created... 
	PathInfo ATSASWorkPath
	//IN2G_ForceDeleteFolder(S_Path)		//leave the file in Temporary folder, system will clean it up at some point. 
	KillPath/Z DATGNOMPath
	KillPath/Z ATSASWorkPath
	//print "Delete following folder from your desktop : "+PathToATSASWorkPath
	setDataFolder OldDf
end
//**************************************************************************************
//**************************************************************************************

static Function IRB1_PDDFRunIrenaPDDF()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	//script old PDDF model here... 
	//basically, need to run: IR2Pr_PdfFitting
	IR2Pr_InitializePDDF()	
	DoWIndow/K/Z IR2Pr_PDFInputGraph
	NVAR SlitSmearedData=root:Packages:Irena_PDDF:UseSMRData	
	SlitSmearedData = 0
	//done prep
	SVAR DataFolderName=root:Packages:Irena:PDDFInterface:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena:PDDFInterface:IntensityWaveName
	SVAR QWavename=root:Packages:Irena:PDDFInterface:QWavename
	SVAR ErrorWaveName=root:Packages:Irena:PDDFInterface:ErrorWaveName
	NVAR DataQEnd = root:Packages:Irena:PDDFInterface:DataQEnd
	NVAR DataQstart = root:Packages:Irena:PDDFInterface:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:PDDFInterface:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:PDDFInterface:DataQstartPoint
	//COpy data where they belong:
	//this is IR2Pr_InputPanelButtonProc work:
	SVAR DFloc=root:Packages:Irena_PDDF:DataFolderName
	SVAR DFInt=root:Packages:Irena_PDDF:IntensityWaveName
	SVAR DFQ=root:Packages:Irena_PDDF:QWaveName
	SVAR DFE=root:Packages:Irena_PDDF:ErrorWaveName
	NVAR UseRegularization=root:Packages:Irena_PDDF:UseRegularization
	NVAR UseMoore=root:Packages:Irena_PDDF:UseMoore
	NVAR PDDFUseGNOM = root:Packages:Irena:PDDFInterface:PDDFUseGNOM
	NVAR PDDFuseMoore = root:Packages:Irena:PDDFInterface:PDDFuseMoore
	NVAR PDDFuseregularization = root:Packages:Irena:PDDFInterface:PDDFuseregularization
	NVAR Moore_DetNumFncts = root:Packages:Irena_PDDF:Moore_DetNumFncts
	NVAR Moore_HolDmaxSize = root:Packages:Irena_PDDF:Moore_HolDmaxSize
	NVAR MaximumR = root:Packages:Irena_PDDF:MaximumR
	NVAR NumberOfBins = root:Packages:Irena_PDDF:NumberOfBins
	NVAR DmaxBio=root:Packages:Irena:PDDFInterface:DmaxEstimate
	NVAR NumBinsBio=root:Packages:Irena:PDDFInterface:NumBinsInR
	NVAR MooreDetNumFnctsBio=root:Packages:Irena:PDDFInterface:MooreDetNumFunctions
	NVAR MooreFitMaxSizeBio=root:Packages:Irena:PDDFInterface:MooreFitMaxSize
	//set the values... 
	UseRegularization = PDDFuseregularization
	UseMoore = PDDFuseMoore
	DFloc = DataFolderName
	DFInt = IntensityWaveName
	DFQ = QWavename
	DFE = ErrorWaveName
	Moore_DetNumFncts=MooreDetNumFnctsBio
	Moore_HolDmaxSize = MooreFitMaxSizeBio
	MaximumR = DmaxBio*1.5
	NumberOfBins = NumBinsBio
	if(NumberOfBins<100)
	 	NumberOfBins = 100
	endif
	//start processing
	IR2Pr_SelectAndCopyData()
	Execute("IR2Pr_PdfInputGraph()")				//this creates the graph
	Cursor/P/W=IR2Pr_PDFInputGraph A  IntensityOriginal  DataQstartPoint
	Cursor/P /W=IR2Pr_PDFInputGraph B  IntensityOriginal  DataQEndPoint
	//IR2Pr_EstimateDmax()
	//and now run:  IR2Pr_PdfFitting
	IR2Pr_PdfFitting("EIther")
	DoWindow/K/Z IR2Pr_PDFInputGraph
	//now pickup the data from the folder and copy to current folder...
	Wave CurrentResultPdf = root:Packages:Irena_PDDF:CurrentResultPdf
	Wave R_distribution=root:Packages:Irena_PDDF:R_distribution
	Wave PDDFErrors = root:Packages:Irena_PDDF:PDDFErrors
	Wave Intensity = root:Packages:Irena_PDDF:Intensity
	Wave Q_vec=root:Packages:Irena_PDDF:Q_vec
	Wave Errors= root:Packages:Irena_PDDF:Errors
	Wave PdfFitIntensity = root:Packages:Irena_PDDF:PdfFitIntensity	
	SVAR FittingResultsIrena = root:Packages:Irena_PDDF:FittingResults
	SVAR FittingResults=root:Packages:Irena:PDDFInterface:FittingResults
	setDataFolder root:Packages:Irena:PDDFInterface
	FittingResults = FittingResultsIrena	
	Duplicate/O Q_vec, pddfInputQVector
	Duplicate/O Intensity, pddfInputIntensity
	Duplicate/O Errors, pddfInputError
	Duplicate/O Q_vec, pddfModelQvector
	Duplicate/O PdfFitIntensity, pddfModelIntensity
	Duplicate/O PDDFErrors, pddfModelError
	Duplicate/O R_distribution, pddfRadius
	Duplicate/O CurrentResultPdf, pddfPr
	Duplicate/O PDDFErrors, pddfPrError
	//DmaxBio = MaximumR
	//NumBinsBio = NumberOfBins
	KillWindow/Z IR2PR_GammaFunction
	setDataFolder OldDf
	
end
//**********************************************************************************************************
//**************************************************************************************
//**************************************************************************************
static Function IRB1_PDDFAppendPDDFModel()

	DoWIndow IRB1_PDDFInterfacePanel
	if(!V_Flag)
		return 0
	endif
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:PDDFInterface					//go into the folder

	Wave/Z pddfInputQVector		=root:Packages:Irena:PDDFInterface:pddfInputQVector
	Wave/Z pddfInputIntensity	=root:Packages:Irena:PDDFInterface:pddfInputIntensity
	Wave/Z pddfInputError			=root:Packages:Irena:PDDFInterface:pddfInputError
	Wave/Z pddfModelQvector		=root:Packages:Irena:PDDFInterface:pddfModelQvector
	Wave/Z pddfModelIntensity	=root:Packages:Irena:PDDFInterface:pddfModelIntensity
	//Wave/Z pddfModelError			=root:Packages:Irena:PDDFInterface:pddfModelError
	Wave/Z pddfRadius				=root:Packages:Irena:PDDFInterface:pddfRadius
	Wave/Z pddfPr					=root:Packages:Irena:PDDFInterface:pddfPr
	Wave/Z pddfPrError				=root:Packages:Irena:PDDFInterface:pddfPrError
	
	if(WaveExists(pddfPr)&&WaveExists(pddfInputIntensity)&&WaveExists(pddfModelIntensity))
		CheckDisplayed /W=IRB1_PDDFInterfacePanel#DataDisplay pddfModelIntensity
		if(!V_flag)
			AppendToGraph /W=IRB1_PDDFInterfacePanel#DataDisplay  pddfModelIntensity  vs pddfModelQvector
		endif
		ModifyGraph/W=IRB1_PDDFInterfacePanel#DataDisplay mode(pddfModelIntensity)=3,marker(pddfModelIntensity)=8,msize(pddfModelIntensity)=4,rgb(pddfModelIntensity)=(0,0,65535)
		
		CheckDisplayed /W=IRB1_PDDFInterfacePanel#PDFDisplay pddfPr
		if(!V_flag)
			AppendToGraph /W=IRB1_PDDFInterfacePanel#PDFDisplay  pddfPr  vs pddfRadius
			ErrorBars /W=IRB1_PDDFInterfacePanel#PDFDisplay pddfPr Y,wave=(pddfPrError,pddfPrError)		
		endif
		ModifyGraph/W=IRB1_PDDFInterfacePanel#PDFDisplay mirror=1
		SetAxis/W=IRB1_PDDFInterfacePanel#PDFDisplay/A/E=1 left
	else
		DoAlert /T="Did not find GNOM data" 0, "Something went wrong, did not find PDDF data" 
	endif
	Label/W=IRB1_PDDFInterfacePanel#PDFDisplay left "P(r)"
	Label/W=IRB1_PDDFInterfacePanel#PDFDisplay bottom "Radius [A]"
	SetDataFolder oldDf
end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//cannot be static, called from panel. 
Function IRB1_PDDFAppendOneDataSet(FolderNameStr)
	string FolderNameStr
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:PDDFInterface					//go into the folder
	SVAR DataStartFolder=root:Packages:Irena:PDDFInterface:DataStartFolder
	SVAR DataFolderName=root:Packages:Irena:PDDFInterface:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena:PDDFInterface:IntensityWaveName
	SVAR QWavename=root:Packages:Irena:PDDFInterface:QWavename
	SVAR ErrorWaveName=root:Packages:Irena:PDDFInterface:ErrorWaveName
	SVAR dQWavename=root:Packages:Irena:PDDFInterface:dQWavename
	NVAR UseIndra2Data=root:Packages:Irena:PDDFInterface:UseIndra2Data
	NVAR UseQRSdata=root:Packages:Irena:PDDFInterface:UseQRSdata
	//these are variables used by the control procedure
	NVAR UseResults=  root:Packages:Irena:PDDFInterface:UseResults
	NVAR UseUserDefinedData=  root:Packages:Irena:PDDFInterface:UseUserDefinedData
	NVAR UseModelData = root:Packages:Irena:PDDFInterface:UseModelData
	UseResults = 0
	UseUserDefinedData = 0
	UseModelData = 0
	//get the names of waves, assume this tool actually works. May not under some conditions. In that case this tool will not work. 
	IR3C_SelectWaveNamesData("Irena:PDDFInterface", FolderNameStr)			//this routine will preset names in strings as needed,	DataFolderName = DataStartFolder+FolderNameStr
	Wave/Z SourceIntWv=$(DataFolderName+IntensityWaveName)
	Wave/Z SourceQWv=$(DataFolderName+QWavename)
	Wave/Z SourceErrorWv=$(DataFolderName+ErrorWaveName)
	Wave/Z SourcedQWv=$(DataFolderName+dQWavename)
	if(!WaveExists(SourceIntWv)||	!WaveExists(SourceQWv)||!WaveExists(SourceErrorWv))
		Abort "Data selection failed for Data"
	endif
	//copy to working folder, so we can work with the data when needed..
	Duplicate/O SourceIntWv, $("root:Packages:Irena:PDDFInterface:Intensity")
	Duplicate/O SourceQWv, $("root:Packages:Irena:PDDFInterface:Q_vec")
	Duplicate/O SourceErrorWv, $("root:Packages:Irena:PDDFInterface:Errors")
	//now attach to graph... 
	IN2G_RemoveDataFromGraph(topGraphStr = "IRB1_PDDFInterfacePanel#DataDisplay")
	CheckDisplayed /W=IRB1_PDDFInterfacePanel#DataDisplay SourceIntWv
	if(!V_flag)
		AppendToGraph /W=IRB1_PDDFInterfacePanel#DataDisplay  SourceIntWv  vs SourceQWv
		ModifyGraph /W=IRB1_PDDFInterfacePanel#DataDisplay log=1, mirror=1
		Label /W=IRB1_PDDFInterfacePanel#DataDisplay left "Intensity 1"
		Label /W=IRB1_PDDFInterfacePanel#DataDisplay bottom "Q [A\\S-1\\M]"
		ErrorBars /W=IRB1_PDDFInterfacePanel#DataDisplay $(NameOfWave(SourceIntWv)) Y,wave=(SourceErrorWv,SourceErrorWv)
	endif
	//set cursors
	NVAR DataQEnd = root:Packages:Irena:PDDFInterface:DataQEnd
	NVAR DataQstart = root:Packages:Irena:PDDFInterface:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:PDDFInterface:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:PDDFInterface:DataQstartPoint
	if(DataQstartPoint<1)
		DataQstartPoint=1
		DataQstart=SourceQWv[1]
	else
		DataQstartPoint = round(BinarySearchInterp(SourceQWv, DataQstart) )
	endif
	if(DataQEndPoint<10)
		DataQEndPoint=numpnts(SourceQWv)-5
		DataQEnd= SourceQWv[DataQEndPoint]
	else
		DataQEndPoint = round(BinarySearchInterp(SourceQWv, DataQEnd) )
	endif
	Cursor /P/W=IRB1_PDDFInterfacePanel#DataDisplay A  $(nameofWave(SourceIntWv))  DataQstartPoint
	Cursor /P/W=IRB1_PDDFInterfacePanel#DataDisplay B  $(nameofWave(SourceIntWv))  DataQEndPoint
	
	IN2G_ColorTopGrphRainbow(topGraphStr="IRB1_PDDFInterfacePanel#DataDisplay")
	IN2G_LegendTopGrphFldr(12, 20, 1, 0, topGraphStr="IRB1_PDDFInterfacePanel#DataDisplay")
	NVAR DisplayErrorBars = root:Packages:Irena:PDDFInterface:DisplayErrorBars
	IN2G_ShowHideErrorBars(DisplayErrorBars, topGraphStr="IRB1_PDDFInterfacePanel#DataDisplay")
	//and caluclate Dmax if user wants:
	NVAR CalcDmax = root:Packages:Irena:PDDFInterface:CalculateDmaxEstOnImport
	if(CalcDmax)
				IRB1_PDDFEstimateRgAndDmax()	
	endif
	
	
	SetDataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IRB1_PDDFGraphWindowHook(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0

	switch(s.eventCode)
		case 0:				// Activate
			// Handle activate
			break

		case 1:				// Deactivate
			// Handle deactivate
			break
		case 7:				//coursor moved
			IRB1_PDDFRecordCursorPosition(s.traceName,s.cursorName,s.pointNumber)
			hookResult = 1
		// And so on . . .
	endswitch

	return hookResult	// 0 if nothing done, else 1
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IRB1_PDDFRecordCursorPosition(traceName,CursorName,PointNumber)
	string traceName,CursorName
	variable PointNumber

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR DataQEnd = root:Packages:Irena:PDDFInterface:DataQEnd
	NVAR DataQstart = root:Packages:Irena:PDDFInterface:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:PDDFInterface:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:PDDFInterface:DataQstartPoint
	Wave/Z CursorAWave = CsrWaveRef(A, "IRB1_PDDFInterfacePanel#DataDisplay")
	Wave/Z CursorBWave = CsrWaveRef(B, "IRB1_PDDFInterfacePanel#DataDisplay")
	Wave/Z CursorAXWave= CsrXWaveRef(A, "IRB1_PDDFInterfacePanel#DataDisplay")
	Wave/Z CursorBXWave= CsrXWaveRef(B, "IRB1_PDDFInterfacePanel#DataDisplay")

	variable tempMaxQ, tempMaxQY, tempMinQY, maxY, minY
	variable LinDataExist = 0
	//check if user removed cursor from graph, in which case do nothing for now...
	if(numtype(PointNumber)==0)
		if(stringmatch(CursorName,"A"))		//moved cursor A, which is start of Q range
			DataQstartPoint = PointNumber
			DataQstart = CursorAXWave[PointNumber]
		endif
		if(stringmatch(CursorName,"B"))		//moved cursor B, which is end of Q range
			DataQEndPoint = PointNumber
			DataQEnd = CursorBXWave[PointNumber]
		endif
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function IRB1_PDDFInitialize()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:Irena
	NewDataFolder/O/S root:Packages:Irena:PDDFInterface
	
	string ListOfStrings
	string ListOfVariables
	variable i
	
	ListOfStrings = "DataPathName;DataExtension;IntName;QvecName;ErrorName;NewDataFolderName;NewIntensityWaveName;DataTypeToImport;"
	ListOfStrings+="NewQWaveName;NewErrorWaveName;NewQErrorWavename;NameMatchString;TooManyPointsWarning;RemoveStringFromName;"
	ListOfStrings+="DATGNOMLocation;FittingResults;"

	ListOfVariables = "UseFileNameAsFolder;UseIndra2Names;UseQRSNames;DataContainErrors;UseQISNames;"
	ListOfVariables += "DisplayErrorBars;DataQEnd;DataQstart;DataQEndPoint;DataQstartPoint;"	
	ListOfVariables += "SleepBetweenDataProcesses;OverwriteExistingData;DisplayErrorBars;"	
	ListOfVariables += "PDDFUseGNOM;PDDFuseMoore;PDDFuseregularization;PDDFUseAutoGNOM;"	
	ListOfVariables += "DmaxEstimate;CalculateDmaxEstOnImport;GnomForceRmin0;GnomForceRmax0;NumBinsInR;GnomAlfaValue;"	
	ListOfVariables += "MooreNumFunctions;MooreDetNumFunctions;MooreFitMaxSize;"	
	ListOfVariables += "CalculatedRg;CalculatedI0;ConcentrationForCals;ScattLengthDensDifference;CalculatedMW;"	
	ListOfVariables += "SaveToFolderAutomatically;SaveToNotebookAutomatically;SaveToWavesAutomatically;"	
		//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	
	Make/O/T/N=0 WaveOfFiles
	Make/O/N=0 WaveOfSelections
	
	SVAR DATGNOMLocation
	if(strlen(DATGNOMLocation)<1)
		DATGNOMLocation=" "
	endif
	
	NVAR PDDFUseGNOM
	NVAR PDDFuseMoore
	NVAR PDDFuseregularization
	NVAR PDDFUseAutoGNOM
	if(PDDFUseGNOM+PDDFuseMoore+PDDFuseregularization+PDDFUseAutoGNOM!=1)
		PDDFUseGNOM = 1
		PDDFuseMoore = 0
		PDDFuseregularization = 0
		PDDFUseAutoGNOM = 0
	endif
	NVAR DmaxEstimate
	if(DmaxEstimate<1)
		DmaxEstimate=30
	endif	
	NVAR GnomForceRmin0
	GnomForceRmin0 = 1
	NVAR GnomForceRmax0
	GnomForceRmax0 = 1
	NVAR NumBinsInR
//	if(NumBinsInR<10)
//		NumBinsInR = 100
//	endif
	NVAR GnomAlfaValue
	NVAR ConcentrationForCals
	if(ConcentrationForCals<0.0001)
		GnomAlfaValue=1
	endif
	NVAR ScattLengthDensDifference
	if(ScattLengthDensDifference<0.1)
		ScattLengthDensDifference = 2.086		//average protein
	endif
	NVAR MooreNumFunctions
	if(MooreNumFunctions<50)
		MooreNumFunctions = 101
	endif
	NVAR MooreFitMaxSize
	MooreFitMaxSize = 1
	
	
	NVAR SaveToFolderAutomatically
	NVAR SaveToNotebookAutomatically
	NVAR SaveToWavesAutomatically
	if(SaveToFolderAutomatically+SaveToNotebookAutomatically+SaveToWavesAutomatically<1)
		SaveToFolderAutomatically=1
		SaveToNotebookAutomatically=1
		SaveToWavesAutomatically=1
	endif
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function IRB1_PDDFSaveResultsToNotebook()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")	
	DFref oldDf= GetDataFolderDFR()
	setDataFolder root:Packages:Irena:PDDFInterface
	NVAR SaveToFolderAutomatically=root:Packages:Irena:PDDFInterface:SaveToFolderAutomatically
	NVAR SaveToNotebookAutomatically=root:Packages:Irena:PDDFInterface:SaveToNotebookAutomatically
	NVAR SaveToWavesAutomatically=root:Packages:Irena:PDDFInterface:SaveToWavesAutomatically
	if(SaveToNotebookAutomatically!=1)
		setDataFolder OldDf
		return 0
	endif
	IR1_CreateResultsNbk()
	SVAR DataFolderName=root:Packages:Irena:PDDFInterface:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena:PDDFInterface:IntensityWaveName
	SVAR QWavename=root:Packages:Irena:PDDFInterface:QWavename
	SVAR ErrorWaveName=root:Packages:Irena:PDDFInterface:ErrorWaveName
	NVAR DataQEnd = root:Packages:Irena:PDDFInterface:DataQEnd
	NVAR DataQstart = root:Packages:Irena:PDDFInterface:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:PDDFInterface:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:PDDFInterface:DataQstartPoint
	string MethodRun
	NVAR PDDFUseGNOM = root:Packages:Irena:PDDFInterface:PDDFUseGNOM
	NVAR PDDFuseMoore = root:Packages:Irena:PDDFInterface:PDDFuseMoore
	NVAR PDDFuseregularization = root:Packages:Irena:PDDFInterface:PDDFuseregularization
	NVAR PPDFUseAutoGNOM=root:Packages:Irena:PDDFInterface:PDDFUseAutoGNOM
	if(PPDFUseAutoGNOM)	
		MethodRun = "AutoGNOM"
	elseif(PDDFUseGNOM)
		MethodRun = "GNOM"
	elseif(PDDFuseMoore)
		MethodRun = "Moore"
	elseif(PDDFuseregularization)
		MethodRun = "Regularization"
	endif

	IR1_AppendAnyText("\r Results of Pair distance distribution function fitting\r",1)	
	IR1_AppendAnyText("Date & time: \t"+Date()+"   "+time(),0)	
	IR1_AppendAnyText("Data from folder: \t"+DataFolderName,0)	
	IR1_AppendAnyText("Intensity: \t"+IntensityWaveName,0)	
	IR1_AppendAnyText("Q: \t"+QWavename,0)	
	IR1_AppendAnyText("Error: \t"+ErrorWaveName,0)	
	IR1_AppendAnyText("Method used: \t"+MethodRun,0)	
	
	DoWindow/K/Z DupWindwFromPanel					//kill the window... 
	IN2G_DuplGraphInPanelSubwndw("IRB1_PDDFInterfacePanel#DataDisplay")
	MoveWindow /W=DataDisplay 20, 20, 920, 520
	IR1_AppendAnyGraph("DataDisplay")
	DoWindow/K/Z DataDisplay					//kill the window... 
	IN2G_DuplGraphInPanelSubwndw("IRB1_PDDFInterfacePanel#PDFDisplay")
	MoveWindow /W=PDFDisplay 20, 20, 920, 520
	IR1_AppendAnyGraph("PDFDisplay")
	DoWindow/K/Z PDFDisplay					//kill the window... 
	
	//save data here... For Moore include "Fittingresults" which is Intensity Fit stuff
	SVAR FittingResults=root:Packages:Irena:PDDFInterface:FittingResults
	IR1_AppendAnyText(FittingResults,0)	
	IR1_AppendAnyText("******************************************\r",0)	
	SetDataFolder OldDf
	SVAR/Z nbl=root:Packages:Irena:ResultsNotebookName	
	DoWindow/F $nbl
	setDataFolder OldDf
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function IRB1_PDDFSaveToWaves()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")	
	DFref oldDf= GetDataFolderDFR()
	NVAR SaveToFolderAutomatically=root:Packages:Irena:PDDFInterface:SaveToFolderAutomatically
	NVAR SaveToNotebookAutomatically=root:Packages:Irena:PDDFInterface:SaveToNotebookAutomatically
	NVAR SaveToWavesAutomatically=root:Packages:Irena:PDDFInterface:SaveToWavesAutomatically
	if(SaveToWavesAutomatically!=1)
		setDataFolder OldDf
		return 0
	endif

	NVAR CalcRg=root:Packages:Irena:PDDFInterface:CalculatedRg
	NVAR CalcI0=root:Packages:Irena:PDDFInterface:CalculatedI0
	NVAR ConcentrationForCals=root:Packages:Irena:PDDFInterface:ConcentrationForCals
	NVAR ScattLengthDensDifference=root:Packages:Irena:PDDFInterface:ScattLengthDensDifference
	NVAR CalculatedMW=root:Packages:Irena:PDDFInterface:CalculatedMW
	SVAR DataFolderName = root:Packages:Irena:PDDFInterface:DataFolderName

	NVAR PDDFUseGNOM = root:Packages:Irena:PDDFInterface:PDDFUseGNOM
	NVAR PDDFuseMoore = root:Packages:Irena:PDDFInterface:PDDFuseMoore
	NVAR PDDFuseregularization = root:Packages:Irena:PDDFInterface:PDDFuseregularization
	NVAR PPDFUseAutoGNOM=root:Packages:Irena:PDDFInterface:PDDFUseAutoGNOM
	string Methodused=""
	if(PPDFUseAutoGNOM)	
		Methodused = "AutoGNOM"
	elseif(PDDFUseGNOM)
		Methodused = "GNOM"
	elseif(PDDFuseMoore)
		Methodused = "Moore"
	elseif(PDDFuseregularization)
		Methodused = "Regularization"
	endif
	NewDATAFolder/O/S root:PDDFFitResults
	Wave/Z PDDF_Rg
	if(!WaveExists(PDDF_Rg))
		make/O/N=0 PDDF_Rg, PDDF_I0, PDDF_MW, PDDF_Conc, PDDF_SLD
		make/O/N=0/T SampleName, MethodName
	endif
	variable curlength = numpnts(PDDF_Rg)
	redimension/N=(curlength+1) SampleName,MethodName, PDDF_Rg, PDDF_I0, PDDF_MW, PDDF_Conc, PDDF_SLD 
	SampleName[curlength] = stringFromList(ItemsInList(DataFolderName, ":")-1, DataFolderName,":")
	MethodName[curlength] = Methodused
	PDDF_Rg[curlength] = CalcRg
	PDDF_I0[curlength] = CalcI0
	PDDF_MW[curlength] = CalculatedMW
	PDDF_Conc[curlength] = ConcentrationForCals
	PDDF_SLD[curlength] = ScattLengthDensDifference
	DoWindow IRB1_PDDFFitResultsTable
	if(V_Flag)
		DoWIndow/F IRB1_PDDFFitResultsTable
	else
		IRB1_PDDFFitResultsTableFnct()
	endif		
	setDataFolder OldDf	
end

//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IRB1_PDDFFitResultsTableFnct() : Table
	PauseUpdate; Silent 1		// building window...
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()	
	if(!DataFolderExists("root:PDDFFitResults:"))
		Abort "No PDDF Fit data exist."
	endif
	SetDataFolder root:PDDFFitResults:
	Wave/T SampleName, MethodName
	Wave PDDF_Rg, PDDF_I0, PDDF_MW, PDDF_Conc, PDDF_SLD
	Edit/K=1/W=(860,772,1831,1334)/N=IRB1_PDDFFitResultsTable SampleName,PDDF_Rg, PDDF_I0, PDDF_MW, MethodName as "PDDF fitting results Table"
	AppendToTable PDDF_Conc, PDDF_SLD
	ModifyTable format(Point)=1,width(SampleName)=150,title(SampleName)="Sample Folder"
	ModifyTable width(MethodName)=100,title(MethodName)="Method"
	ModifyTable alignment(PDDF_Rg)=1,sigDigits(PDDF_Rg)=4,title(PDDF_Rg)="Rg [A]"
	ModifyTable alignment(PDDF_I0)=1,sigDigits(PDDF_I0)=4,width(PDDF_I0)=100,title(PDDF_I0)="I0"
	ModifyTable alignment(PDDF_MW)=1,sigDigits(PDDF_MW)=4,width(PDDF_MW)=104
	ModifyTable title(PDDF_MW)="MW",alignment(PDDF_Conc)=1,sigDigits(PDDF_Conc)=4
	ModifyTable width(PDDF_Conc)=92,title(PDDF_Conc)="Conc [mg/ml]",alignment(PDDF_SLD)=1
	ModifyTable sigDigits(PDDF_SLD)=4,width(PDDF_SLD)=110,title(PDDF_SLD)="SLD [10^10 cm^2]"
	SetDataFolder oldDf
EndMacro
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IRB1_PDDFSaveResultsToFldr()
	DFref oldDf= GetDataFolderDFR()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	setDataFolder root:Packages:Irena:PDDFInterface

	NVAR SaveToFolderAutomatically=root:Packages:Irena:PDDFInterface:SaveToFolderAutomatically
	NVAR SaveToNotebookAutomatically=root:Packages:Irena:PDDFInterface:SaveToNotebookAutomatically
	NVAR SaveToWavesAutomatically=root:Packages:Irena:PDDFInterface:SaveToWavesAutomatically
	if(SaveToFolderAutomatically!=1)
		return 0
	endif
	//save data here... For Moore include "Fittingresults" which is Intensity Fit stuff
	//Parameters: 
	SVAR DataFolderName=root:Packages:Irena:PDDFInterface:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena:PDDFInterface:IntensityWaveName
	SVAR QWavename=root:Packages:Irena:PDDFInterface:QWavename
	SVAR ErrorWaveName=root:Packages:Irena:PDDFInterface:ErrorWaveName
	NVAR DataQEnd = root:Packages:Irena:PDDFInterface:DataQEnd
	NVAR DataQstart = root:Packages:Irena:PDDFInterface:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:PDDFInterface:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:PDDFInterface:DataQstartPoint
	string MethodRun
	NVAR PDDFUseGNOM = root:Packages:Irena:PDDFInterface:PDDFUseGNOM
	NVAR PDDFuseMoore = root:Packages:Irena:PDDFInterface:PDDFuseMoore
	NVAR PDDFuseregularization = root:Packages:Irena:PDDFInterface:PDDFuseregularization
	NVAR PPDFUseAutoGNOM=root:Packages:Irena:PDDFInterface:PDDFUseAutoGNOM
	if(PPDFUseAutoGNOM)	
		MethodRun = "AutoGNOM"
	elseif(PDDFUseGNOM)
		MethodRun = "GNOM"
	elseif(PDDFuseMoore)
		MethodRun = "Moore"
	elseif(PDDFuseregularization)
		MethodRun = "Regularization"
	endif
	SVAR FittingResults=root:Packages:Irena:PDDFInterface:FittingResults
	Wave pddfInputIntensity = root:Packages:Irena:PDDFInterface:pddfInputIntensity
	string oldNote=note(pddfInputIntensity)
	string ResultsComment=ReplaceString("\r", FittingResults, ";")
	variable i
	String NewWaveNote="PDDF analysis;"+date()+";"+time()+";Reported results="+ResultsComment+";"
	NewWaveNote+=oldNote

	Wave/Z pddfInputQVector		=root:Packages:Irena:PDDFInterface:pddfInputQVector
	Wave/Z pddfInputIntensity	=root:Packages:Irena:PDDFInterface:pddfInputIntensity
	Wave/Z pddfInputError			=root:Packages:Irena:PDDFInterface:pddfInputError
	Wave/Z pddfModelQvector		=root:Packages:Irena:PDDFInterface:pddfModelQvector
	Wave/Z pddfModelIntensity	=root:Packages:Irena:PDDFInterface:pddfModelIntensity
	//Wave/Z pddfModelError			=root:Packages:Irena:PDDFInterface:pddfModelError
	Wave/Z pddfRadius				=root:Packages:Irena:PDDFInterface:pddfRadius
	Wave/Z pddfPr					=root:Packages:Irena:PDDFInterface:pddfPr
	Wave/Z pddfPrError				=root:Packages:Irena:PDDFInterface:pddfPrError
	Wave/Z NormalizedResidual	=root:Packages:Irena:PDDFInterface:NormalizedResidual
	Wave/Z ChisquaredWave			=root:Packages:Irena:PDDFInterface:ChisquaredWave
	Wave/Z CurrentResultsGamma	=root:Packages:Irena:PDDFInterface:CurrentResultsGamma

	Duplicate/O pddfRadius, tempR_distribution
	Duplicate/O pddfPr, tempCurrentResultPdf
	Duplicate/O CurrentResultsGamma, tempCurrentResultsGamma
	//Duplicate/O pddfModelError, tempPDDFErrors
	Duplicate/O pddfInputQVector, tempQ_vec
	Duplicate/O ChisquaredWave, tempCurrentChiSq
	Duplicate/O pddfModelIntensity, tempPdfFitIntensity
	string ListOfWavesForNotes="tempR_distribution;tempCurrentResultPdf;tempQ_vec;tempPdfFitIntensity;tempPDDFErrors;tempCurrentChiSq;tempCurrentResultsGamma;"
	For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)
		IN2G_AddListToWaveNote(stringFromList(i,ListOfWavesForNotes),NewWavenote)
		IN2G_AddListToWaveNote(stringFromList(i,ListOfWavesForNotes),Fittingresults)
	endfor
	setDataFolder $DataFolderName
	string tempname 
	variable ii=0
	For(ii=0;ii<1000;ii+=1)
		tempname="PDDFIntensity_"+num2str(ii)
		if (checkname(tempname,1)==0)
			break
		endif
	endfor
	Duplicate /O tempPdfFitIntensity, $tempname
	tempname="PDDFQvector_"+num2str(ii)
	Duplicate /O tempQ_vec, $tempname
	tempname="PDDFChiSquared_"+num2str(ii)
	Duplicate /O tempCurrentChiSq, $tempname
	tempname="PDDFDistFunction_"+num2str(ii)
	Duplicate /O tempCurrentResultPdf, $tempname
	//tempname="PDDFErrors_"+num2str(ii)
	//Duplicate /O tempPDDFErrors, $tempname
	tempname="PDDFDistances_"+num2str(ii)
	Duplicate /O tempR_distribution, $tempname
	tempname="PDDFGammaFunction_"+num2str(ii)
	Duplicate /O tempCurrentResultsGamma, $tempname
	
	print "Saved data to folder "+getDataFolder(1)+" , data generation is "+num2str(ii)
	Killwaves/Z tempR_distribution, tempCurrentResultPdf, tempQ_vec, tempCurrentChiSq, tempPdfFitIntensity, tempPDDFErrors, tempCurrentResultsGamma
	
	SetDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

