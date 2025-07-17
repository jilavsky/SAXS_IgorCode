﻿#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma IgorVersion=9.04		//requires Igor version 9.04 or higher, uses IP9 and IP10 code. 
#pragma version=0.5				//placeholder for file versions, eventually


#include "IN4_SupportCode"
#include "IN4_Calculations"

Constant IN4_RemoveRangeChangeEffects  = 1
 

Menu "USAXS"
	"Data reduction Indra 4", IN4_Main()
	help={"Indra 4 main panel"}
end


Function IN4_Main()

	IN2G_CheckScreenSize("height",900)
	KillWindow/Z IN4_DataReductionPanel
	DoWIndow IN4_DataReductionPanel
	if(V_Flag)
		DoWIndow/F IN4_DataReductionPanel
	else
		IN4_Init()
		//IN4_InitializePython()
		IN4_DataReductionPanelFnct()
		ING2_AddScrollControl()
		//IR1_UpdatePanelVersionNumber("IRB1_ImportBioSAXSASCIIData", IRB1_ImpBioSAXSASCIIVer,1)
	endif
end


//IN4_ProcessSelectedData

////************************************************************************************************************
////************************************************************************************************************
Function IN4_DataReductionPanelFnct()

	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(2.25,43.25,660,850)/N=IN4_DataReductionPanel as "Indra4mainPanel"
	TitleBox MainTitle title="Indra 4 Data reduction / Import",pos={140,2},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fSize=22,fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,40},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	IR3C_AddDataControls("Indra4DataPath", "Indra4", "IN4_DataReductionPanel","h5", "","","IN4_DoubleClickFUnction")
	ListBox ListOfAvailableData,size={260,477}, pos={5,113}, proc=IR4_ListBoxProc
	SetVariable DataExtensionString pos={380,90}
	PopupMenu SortOptionString pos={270,90}
	Button SelectAll,pos={5,595}
	Button DeSelectAll, pos={120,595}
	Button GetHelp,pos={335,50},size={80,15},fColor=(65535,32768,32768), proc=IRB1_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}


	CheckBox IncludeSAXS,pos={290,115},size={16,14},proc=IN4_CheckProc,mode=0,title="Include SAXS?",variable= root:Packages:Indra4:IncludeSAXS, help={"Process SAXS at the same time"}
	CheckBox IncludeWAXS,pos={420,115},size={16,14},proc=IN4_CheckProc,mode=0,title="Include WAXS?",variable= root:Packages:Indra4:IncludeWAXS, help={"Process WAXS at the same time"}
	//recalculate block
	CheckBox RecalcNexusData,pos={290,140},size={30,20},proc=IN4_CheckProc,title="Re-reduce the data?",variable= root:Packages:Indra4:RecalcNexusData,mode=0, help={"Force recalculate data, else just load what is in file"}
	Checkbox SaveRereducedDataToNexus,pos={420,140},size={30,20},proc=IN4_CheckProc,title="Save re-reduced data to Nexus?",variable= root:Packages:Indra4:SaveRereducedDataToNexus,mode=0, help={"Add/save the re-reduced data back to Nexus file for future use"}

	SetVariable BlankFileName,pos={280,165},size={345,23}, noproc,title="Selected Blank Name:", frame=1
	Setvariable BlankFileName, variable=root:Packages:Indra4:BlankFileName
	CheckBox UseIgorCode,pos={290,195},size={16,14},proc=IN4_CheckProc,title="Use Igor?",variable= root:Packages:Indra4:UseIgorCode,mode=1, help={"Use Igor code to recalculate results"}
	CheckBox UsePythonCode,pos={420,195},size={16,14},proc=IN4_CheckProc,title="Use Python?",variable= root:Packages:Indra4:UsePythonCode,mode=1, help={"IP10 only - Use Python code to recalculate results"}
	Button ReduceSelectedData,pos={280,230},size={180,20}, proc=IN4_ButtonProc,title="Re-reduce selected data"
	Button ReduceSelectedData,help={"Reduce Selected data and store them in Igor"}

	Button ImportSelectedData,pos={280,260},size={180,20}, proc=IN4_ButtonProc,title="Import Selected Data to Igor"
	Button ImportSelectedData,help={"Import Selected data and store them in Igor"}
	Button KillGraphs,pos={530,260},size={80,15}, proc=IN4_ButtonProc,title="Kill graphs"
	Button KillGraphs,help={"Preview selected file."}


	TitleBox Comments title="This is under developement, testing mode ONLY",pos={40,650},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={550,30},fSize=22,fColor=(0,0,52224)

	//and update content, if possible...

	IN4_DisplayCorrectControls()
end

//*****************************************************************************************************************
//*****************************************************************************************************************
Function IN4_DisplayCorrectControls()

	NVAR RecalcNexusData = root:Packages:Indra4:RecalcNexusData
	variable dispState = RecalcNexusData ? 0 : 1
	SetVariable BlankFileName win=IN4_DataReductionPanel, disable = dispState
	CheckBox SaveRereducedDataToNexus win=IN4_DataReductionPanel, disable = dispState
	//CheckBox IncludeWAXS win=IN4_DataReductionPanel, disable = dispState
	Button ReduceSelectedData win=IN4_DataReductionPanel, disable = dispState
	
#if(IgorVersion()>9.99)
	CheckBox UsePythonCode win=IN4_DataReductionPanel, disable = dispState
	CheckBox UseIgorCode win=IN4_DataReductionPanel, disable = dispState

#else	//IP9, no Python
	CheckBox UsePythonCode win=IN4_DataReductionPanel, disable = 1
	CheckBox UseIgorCode win=IN4_DataReductionPanel, disable = 1
	NVAR UsePythonCode = root:Packages:Indra4:UsePythonCode
	NVAR UseIgorCode = root:Packages:Indra4:UseIgorCode
	UsePythonCode = 0
	UseIgorCode = 1

#endif	
end
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN4_Init()

	DFref oldDf= GetDataFolderDFR()
	variable i
		
	if (!DataFolderExists("root:Packages:Indra4"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Indra4
	endif
	SetDataFolder root:Packages:Indra4					//go into the folder
	string/g ListOfVariables
	string/g ListOfStrings
	
//	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName;SampleFileName;BlankFileName;"
	ListOfStrings+="DataStartFolder;DataMatchString;FolderSortString;FolderSortStringAll;"
//	ListOfStrings+="UserMessageString;SavedDataMessage;"
//	ListOfStrings+="ModelSelected;ListOfModels;FittingPower;ListOfFittingPowers;"
//
	ListOfVariables="UseIgorCode;UsePythonCode;RecalcNexusData;"
	ListOfVariables+="UseIgorCode;UsePythonCode;RecalcNexusData;IncludeSAXS;IncludeWAXS;"
	ListOfVariables+="SaveRereducedDataToNexus;"
//	ListOfVariablesMain+="SaveToNotebook;SaveToWaves;SaveToFolder;DelayBetweenProcessing;DoNotTryRecoverData;HideTagsAlways;"


//	
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	Make/O/T/N=(0)  WaveOfFiles
	Make/O/N=(0) WaveOfSelections
	SetDataFolder oldDf
	IN4_SetInitialValues()

end
//************************************************************************************************************
//************************************************************************************************************

Function IN4_SetInitialValues()


	NVAR UseIgorCode = root:Packages:Indra4:UseIgorCode
	NVAR UsePythonCode = root:Packages:Indra4:UsePythonCode
	if(UseIgorCode+UsePythonCode !=1)
		UseIgorCode = 1
		UsePythonCode = 0
	endif
end

//************************************************************************************************************
//************************************************************************************************************
Function IR4_ListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//Prevent Igor from invoking this before we are done with instance 1
	lba.blockReentry = 1
	string   TopPanel = WinName(0, 64)
	variable row      = lba.row
	variable col      = lba.col
	WAVE/Z/T listWave = lba.listWave
	WAVE/Z   selWave  = lba.selWave
	variable i
	string items             = ""
	SVAR   SortOptionsString = root:Packages:IrenaListboxProcs:SortOptionsString
	//="Sort;Inv_Sort;Sort _XYZ;Inv Sort _XYZ;"
	SVAR ControlProcsLocations      = root:Packages:IrenaListboxProcs:ControlProcsLocations
	SVAR ControlPckgPathName        = root:Packages:IrenaListboxProcs:ControlPckgPathName
	SVAR ControlDoubleCLickFnctName = root:Packages:IrenaListboxProcs:ControlDoubleCLickFnctName

	string CntrlLocation       = "root:Packages:" + StringByKey(TopPanel, ControlProcsLocations, "=", ";")
	string CntrlPathName       = StringByKey(TopPanel, ControlPckgPathName, "=", ";")
	string DoubleCLickFnctName = StringByKey(TopPanel, ControlDoubleCLickFnctName, "=", ";")

	switch(lba.eventCode)
		case -1: // control being killed
			break
		case 1: // mouse down
			WAVE/T WaveOfFiles               = $(CntrlLocation + ":WaveOfFiles")
			WAVE   WaveOfSelections          = $(CntrlLocation + ":WaveOfSelections")
			SVAR   DataSelSortString         = $(CntrlLocation + ":DataSelSortString")
			SVAR   DataSelListBoxMatchString = $(CntrlLocation + ":DataSelListBoxMatchString")
			variable oldSets

			if(lba.eventMod & 0x10) // rightclick
				// list of items for PopupContextualMenu
				items = "Add as Blank;Refresh Content;Select All;Deselect All;Match \"Blank\";Match \"Empty\";Hide \"Blank\";Hide \"Empty\";Remove Match or Hide;" + SortOptionsString
				PopupContextualMenu items
				// V_flag is index of user selected item
				switch(V_flag)
					case 1: // "Add sa Blank"
						SVAR BlankName=root:Packages:Indra4:BlankFileName
						BlankName = listWave[lba.row]

					case 2: // "Refresh Content"
						//refresh content, but here it will depend where we call it from.
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						oldSets = V_startRow
						IR3C_UpdateListOfFilesInWvs(TopPanel)
						IR3C_SortListOfFilesInWvs(TopPanel)
						ListBox ListOfAvailableData, win=$(TopPanel), row=V_startRow
						break;
					case 3: // "Select All;"
						selWave = 1
						break;
					case 4: // "Deselect All"
						selWave = 0
						break;
					case 5: //M<atch Blank
						DataSelListBoxMatchString = "(?i)Blank"
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						oldSets = V_startRow
						IR3C_UpdateListOfFilesInWvs(TopPanel)
						IR3C_SortListOfFilesInWvs(TopPanel)
						ListBox ListOfAvailableData, win=$(TopPanel), row=V_startRow
						break;
					case 6: //Match EMpty
						DataSelListBoxMatchString = "(?i)Empty"
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						oldSets = V_startRow
						IR3C_UpdateListOfFilesInWvs(TopPanel)
						IR3C_SortListOfFilesInWvs(TopPanel)
						ListBox ListOfAvailableData, win=$(TopPanel), row=V_startRow
						break;
					case 7: //hide blank
						DataSelListBoxMatchString = "^((?!(?i)Blank).)*$"
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						oldSets = V_startRow
						IR3C_UpdateListOfFilesInWvs(TopPanel)
						IR3C_SortListOfFilesInWvs(TopPanel)
						ListBox ListOfAvailableData, win=$(TopPanel), row=V_startRow
						break;
					case 8: //hide empty
						DataSelListBoxMatchString = "^((?!(?i)Empty).)*$"
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						oldSets = V_startRow
						IR3C_UpdateListOfFilesInWvs(TopPanel)
						IR3C_SortListOfFilesInWvs(TopPanel)
						ListBox ListOfAvailableData, win=$(TopPanel), row=V_startRow
						break;
					case 9: //remove Match
						DataSelListBoxMatchString = ""
						ControlInfo/W=$(TopPanel) ListOfAvailableData
						oldSets = V_startRow
						IR3C_UpdateListOfFilesInWvs(TopPanel)
						IR3C_SortListOfFilesInWvs(TopPanel)
						ListBox ListOfAvailableData, win=$(TopPanel), row=V_startRow
						break;

					default: // "Sort"
						DataSelSortString = StringFromList(V_flag - 1, items)
						PopupMenu SortOptionString, win=$(TopPanel), mode=1, popvalue=DataSelSortString
						IR3C_SortListOfFilesInWvs(TopPanel)
						break;
				endswitch
			endif
			break
		case 3: // double click
			if(strlen(DoubleCLickFnctName) > 0)
				Execute(DoubleCLickFnctName + "()")
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
//************************************************************************************************************
//************************************************************************************************************

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IN4_InitializePython()

#if (IgorVersion()>9.99)
	pythonenv
	//•print S_PythonEnvInfo
	// NAME=matilda;VERSION=3.12.3;HOME=C:\Users\ilavsky\miniconda3\envs\matilda;
	// LIBRARY=C:\Users\ilavsky\miniconda3\envs\matilda\python312.dll;
	// SITEPACKAGES=C:\Users\ilavsky\miniconda3\envs\matilda\Lib\site-packages;
	//•print V_PythonRunning
	// 0 when not yet run, 1 when already run. If not yet run - after Igor experiment restart, need to init it
	if(V_PythonRunning<1)
		//configure environment... This puts Matilda on Python path
		Python execute="import sys;sys.path.append('C:/Users/ilavsky/Documents/GitHub/Matilda/matilda')"
		//import the file
		//Python execute = "import matildaIgor"
		Python execute = "from matildaIgor import reduceFlyscanData"
		Python execute = "from matildaIgor import reduceSWAXSData"
	endif

#else
	Abort "You need Igor Pro 10 and Python environment with Matilda in order to use Python to reduce data"
#endif

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IN4_DoubleClickFunction()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	
	Wave/T WaveOfFiles    = root:Packages:Indra4:WaveOfFiles
	Wave WaveOfSelections = root:Packages:Indra4:WaveOfSelections

	if(sum(WaveOfSelections)<1)
		WaveOfSelections[0]=1
	endif
	variable i, imax, icount
	string SelectedFileName, selectedfile
	SelectedFileName = "TestImport"
	imax = numpnts(WaveOfSelections)	
	string ImportedFolders
	string FileNameList=""
	for(i=0;i<imax;i+=1)
		if (WaveOfSelections[i])
			FileNameList += WaveOfFiles[i]+";"
			icount+=1
		endif
	endfor
	if(icount>0)
		ImportedFolders = IN4_ProcessSelectedData(FileNameList)
		IN4_PlotDataFolders(ImportedFolders)
	endif
	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************


Function IN4_ProcessSelectedDataFnct()

	DfRef OldDf=GetDataFolderDFR()
	
	Wave/T WaveOfFiles    = root:Packages:Indra4:WaveOfFiles
	Wave WaveOfSelections = root:Packages:Indra4:WaveOfSelections

	if(sum(WaveOfSelections)<1)
		setDataFolder OldDf
		return 0
	endif
	variable i, imax, icount
	string SelectedFileName, selectedfile
	SelectedFileName = "TestImport"
	imax = numpnts(WaveOfSelections)	
	string ImportedFolders
	string FileNameList=""
	for(i=0;i<imax;i+=1)
		if (WaveOfSelections[i])
			FileNameList += WaveOfFiles[i]+";"
			icount+=1
		endif
	endfor
	if(icount>0)
		ImportedFolders = IN4_ProcessSelectedData(FileNameList)
		IN4_PlotDataFolders(ImportedFolders)
	endif

	setDataFolder OldDf
	return 1

end

//************************************************************************************************************
//************************************************************************************************************

Function IN4_PlotDataFolders(ImportedFolders)
	string ImportedFolders
	//handle ONE folder here, but this is list...
	DfRef OldDf=GetDataFolderDFR()
	
	string ImportedFolder
	string SampleName
	variable i
	string listOfGraphs=""
	for(i=0;i<ItemsInList(ImportedFolders);i+=1)
		ImportedFolder = StringFromList(i,ImportedFolders)
	
		If(DataFolderExists(ImportedFolder)&&stringmatch(ImportedFolder, "*:USAXS*"))	//these are USAXS data
			SetDataFolder $ImportedFolder
			SampleName = GetDataFolder(0)
			//find R data
			//BL_Q_wave BL_R_wave BL_S_wave, :DSM_Error,:DSM_Int,:DSM_Qvec,:Q_wave,:R_wave,:SMR_Error,::SMR_Qvec
			Wave/Z R_int
			Wave/Z BL_R_int
			Wave/Z DSM_Int
			Wave/Z SMR_Int
			if(WaveExists(R_int) && WaveExists(BL_R_int))
				Wave R_Qvec
				Wave R_error
				Wave BL_R_Qvec
				Wave BL_R_error
				
				DoWIndow USAXS_R_data
				if(V_Flag==0)
					Display/K=1/N= USAXS_R_data R_int vs R_Qvec as "USAXS RAW data"
					AppendToGraph BL_R_int vs BL_R_Qvec
					Label left "Intensity [normalized, uncalibrated]"
					Label bottom "Q [1/A]"
					ModifyGraph rgb(BL_R_int)=(0,0,0)
					SetAxis bottom 1e-05,0.3	
					ModifyGraph log=1
				else
					DoWIndow/F USAXS_R_data
					AppendToGraph/W=USAXS_R_data R_int vs R_Qvec 
					AppendToGraph/W=USAXS_R_data BL_R_int vs BL_R_Qvec
				endif
				IN2G_ColorTopGrphRainbow()
				IN2G_LegendTopGrphFldr(12, 10, 1, 1)
				
				//Legend/C/N=text0/J/A=MC "\\s(R_wave) "+SampleName+"\r\\s(BL_R_wave) Blank"
				//listOfGraphs+="USAXS_R_data"+","
			endif
			if(WaveExists(SMR_Int))
				Wave SMR_Qvec
				Wave SMR_Error
				DoWIndow USAXS_SMR_data
				if(V_Flag==0)
					Display/K=1/N=USAXS_SMR_data  SMR_Int vs SMR_Qvec as "USAXS SMR data"
					Label left "SMR Intensity [cm2/cm3]"
					Label bottom "Q [1/A]"
					ModifyGraph log=1
					//Legend/C/N=text0/J/A=MC "\\s(SMR_Int) "+SampleName			
				else
					DoWIndow/F USAXS_SMR_data
					AppendToGraph/W=USAXS_SMR_data SMR_Int vs SMR_Qvec
				endif
				IN2G_ColorTopGrphRainbow()
				IN2G_LegendTopGrphFldr(12, 10, 1, 0)

				//listOfGraphs+=SampleName+"_SMR_data"+","
			endif
			if(WaveExists(DSM_Int))
				Wave DSM_Qvec
				Wave DSM_Error
				DoWIndow USAXS_DSM_data
				if(V_Flag==0)
					Display/K=1/N= USAXS_DSM_data DSM_Int vs DSM_Qvec as "USAXS Calibrated data"
					Label left "Intensity [cm2/cm3]"
					Label bottom "Q [1/A]"
					ModifyGraph log=1
					//Legend/C/N=text0/J/A=MC "\\s(DSM_Int) "+SampleName
				else
					DoWIndow/F USAXS_DSM_data
					AppendToGraph/W=USAXS_DSM_data  DSM_Int vs DSM_Qvec
				endif				
				IN2G_ColorTopGrphRainbow()
				IN2G_LegendTopGrphFldr(12, 10, 1, 0)
				//listOfGraphs+=SampleName+"_data"+","
			endif				
		elseIf(DataFolderExists(ImportedFolder)&&stringmatch(ImportedFolder, "*:SAXS*"))	//these are SAXs data
			SetDataFolder $ImportedFolder
			SampleName = GetDataFolder(0)
			SampleName = removeending(SampleName,"_NX")
			SampleName = removeending(SampleName,"_IN4")
			Wave/Z R_R_int
			Wave/Z BL_R_int
			Wave/Z R_wave = $("r_"+SampleName)
//			if(WaveExists(R_R_int) && WaveExists(BL_R_int))
//				Wave R_Q_wave
//				Wave R_S_wave
//				Wave BL_Q_wave
//				Wave BL_S_wave
//				DoWIndow "USAXS_DSM_data"
//				if(V_Flag==0)
//				Display/K=1/N=$(SampleName+"_R_data_SAXS") R_R_int vs R_Q_wave as "SAXS QRS data for "+SampleName
//				AppendToGraph BL_R_int vs BL_Q_wave
//				Label left "Intensity [normalized, uncalibrated]"
//				Label bottom "Q [1/A]"
//				ModifyGraph rgb(BL_R_int)=(0,0,0)
//				SetAxis bottom 1e-05,0.3
//	
//				ModifyGraph log=1
//				Legend/C/N=text0/J/A=MC "\\s(R_R_int) "+SampleName+"\r\\s(BL_R_int) Blank"
//				listOfGraphs+=SampleName+"_R_data_SAXS"+","
//				
//			endif

			if(WaveExists(R_wave))
				Wave Q_wave = $("q_"+SampleName)
				Wave S_wave = $("s_"+SampleName)
				DoWIndow SAXS_Data
				if(V_Flag==0)
					Display/K=1/N=SAXS_Data R_wave vs Q_wave as "SAXS Calibrated data"
					Label left "Intensity [cm2/cm3]"
					Label bottom "Q [1/A]"
					ModifyGraph log=1
				else
					DoWIndow/F SAXS_Data
					AppendToGraph/W=SAXS_Data R_wave vs Q_wave
				endif			
				IN2G_ColorTopGrphRainbow()
				IN2G_LegendTopGrphFldr(12, 10, 1, 0)
				//listOfGraphs+=SampleName+"_data_SAXS"+","
			endif				
		elseIf(DataFolderExists(ImportedFolder)&&stringmatch(ImportedFolder, "*:WAXS*"))	//these are WAXS data
			SetDataFolder $ImportedFolder
			SampleName = GetDataFolder(0)
			SampleName = removeending(SampleName,"_NX")
			SampleName = removeending(SampleName,"_IN4")
			Wave/Z R_R_int
			Wave/Z BL_R_int
			Wave/Z R_wave = $("R_"+SampleName)
//			if(WaveExists(R_R_int) && WaveExists(BL_R_int))
//				Wave R_Q_wave
//				Wave R_S_wave
//				Wave BL_Q_wave
//				Wave BL_S_wave
//				KillWindow/Z $(SampleName+"_R_data_WAXS")
//				Display/K=1/N=$(SampleName+"_R_data_WAXS") R_R_int vs R_Q_wave as "WAXS QRS data for "+SampleName
//				AppendToGraph BL_R_int vs BL_Q_wave
//				Label left "Intensity [normalized, uncalibrated]"
//				Label bottom "Q [1/A]"
//				ModifyGraph rgb(BL_R_int)=(0,0,0)
//				SetAxis bottom 1e-05,0.3
//	
//				ModifyGraph log=1
//				Legend/C/N=text0/J/A=MC "\\s(R_R_int) "+SampleName+"\r\\s(BL_R_int) Blank"
//				listOfGraphs+=SampleName+"_R_data_WAXS"+","
//				
///			endif

			if(WaveExists(R_wave))
				Wave Q_wave = $("Q_"+SampleName)
				Wave S_wave = $("S_"+SampleName)
				DoWIndow WAXS_Data
				if(V_Flag==0)
					Display/K=1/N=WAXS_data R_wave vs Q_wave as "WAXS Calibrated for "+SampleName
					Label left "Intensity [cm2/cm3]"
					Label bottom "Q [1/A]"
					ModifyGraph log=1
					//Legend/C/N=text0/J/A=MC "\\s(R_"+SampleName+") "+SampleName	
				else
					DoWIndow/F WAXS_data
					AppendToGraph/W=WAXS_Data R_wave vs Q_wave
				endif			
				IN2G_ColorTopGrphRainbow()
				IN2G_LegendTopGrphFldr(12, 10, 1, 0)
				//listOfGraphs+=SampleName+"_data_WAXS"+","
			endif				
		endif
	endfor
	TileWindows/A=(2,3)/W=(500,22,1745,760) /O=1
	DoUpdate
	setDataFolder OldDf

end

//************************************************************************************************************
Function IN4_KillGraphs()

	KillWindow/Z USAXS_R_data
	KillWindow/Z USAXS_SMR_data
	KillWindow/Z USAXS_DSM_data
	KillWindow/Z WAXS_data
	KillWindow/Z SAXS_data
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function IN4_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"ReduceSelectedData"))
				IN4_ProcessSelectedDataFnct()		
			endif
			if(stringmatch(ba.ctrlName,"ImportSelectedData"))
				NVAR RecalcNexusData = root:Packages:Indra4:RecalcNexusData
				RecalcNexusData=0
				IN4_ProcessSelectedDataFnct()		
			endif			
			
			if(stringmatch(ba.ctrlName,"KillGraphs"))
				IN4_KillGraphs()
			endif
			if(stringmatch(ba.ctrlName,"GetHelp"))
				IN2G_OpenWebManual("Irena/bioSAXS.html#import-biosaxs-ascii")				//fix me!!			
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************


Function IN4_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR UseIgorCode= root:Packages:Indra4:UseIgorCode
			NVAR UsePythonCode= root:Packages:Indra4:UsePythonCode
			NVAR SaveRereducedDataToNexus = root:Packages:Indra4:SaveRereducedDataToNexus
			if(stringmatch(cba.ctrlname,"UseIgorCode"))
				UseIgorCode = checked
				UsePythonCode = !checked
			endif
			if(stringmatch(cba.ctrlname,"UsePythonCode"))
				UseIgorCode = !checked
				UsePythonCode = checked
				if(UsePythonCode)
					SaveRereducedDataToNexus = 0		//Python saves the data there automatically. 
				endif
			endif			
#if (IgorVersion()<9.99)
	UseIgorCode = 1
	UsePythonCode = 0
#endif

			if(stringmatch(cba.ctrlname,"RecalcNexusData"))
				IN4_DisplayCorrectControls()
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************