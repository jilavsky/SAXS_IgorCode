#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=1


constant IR3DMversionNumber = 0.1			//Data Manipulation III panel version number


/////******************************************************************************************
/////******************************************************************************************
/////******************************************************************************************
/////******************************************************************************************
Function IR3DM_DataManipulationIII()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IN2G_CheckScreenSize("width",1200)
	DoWIndow IR3DM_DataManIIIPanel
	if(V_Flag)
		DoWindow/F IR3DM_DataManIIIPanel
	else
		IR3DM_InitDMIII()
		IR3DM_DataManIIIPanelFnct()
		ING2_AddScrollControl()
		IR1_UpdatePanelVersionNumber("IR3DM_DataManIIIPanel", IR3DMversionNumber,1)
		IR3C_MultiUpdListOfAvailFiles("Irena:DataManIII")	
	endif
	IR3DM_CreateDM3Graphs()
end
////************************************************************************************************************
Function IR3DM_MainCheckVersion()	
	DoWindow IR3DM_DataManIIIPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR3DM_DataManIIIPanel", IR3DMversionNumber))
			DoAlert /T="The Data manipulation 3 panel was created by incorrect version of Irena " 1, "Data manipulation needs to be restarted to work properly. Restart now?"
			if(V_flag==1)
				KillWIndow/Z IR3DM_DataManIIIPanel
				KillWindow/Z IR3DM_LogLogDataDisplay
				IR3DM_DataManipulationIII()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR3DM_InitDMIII()
			endif
		endif
	endif
end
//
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
Function IR3DM_DataManIIIPanelFnct()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(2.25,43.25,530,800) as "Data Manipulation"
	DoWIndow/C IR3DM_DataManIIIPanel
	TitleBox MainTitle title="Data Manipulation III",pos={140,2},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fSize=22,fColor=(0,0,52224)
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena:DataManIII","IR3DM_DataManIIIPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	IR3C_MultiAppendControls("Irena:DataManIII","IR3DM_DataManIIIPanel", "IR3DM_CopyAndAppendData","",1,0)
	//hide what is not needed
	checkbox UseResults, disable=0
	//OK, that is done
	
	//now controls in some locagical order... 
	SetVariable DataFolderName,noproc,title=" ",pos={250,100},size={270,17},frame=0, fstyle=1,valueColor=(0,0,65535)
	Setvariable DataFolderName, variable=root:Packages:Irena:DataManIII:DataFolderName, noedit=1

	CheckBox ProcessData,pos={280,140},size={90,14},proc=IR3DM_CheckProc,title="Process data"
	CheckBox ProcessData,variable= root:Packages:Irena:DataManIII:ProcessData, help={"Check, if you want to process data somehow"}
	CheckBox DeleteData,pos={400,140},size={90,14},proc=IR3DM_CheckProc,title="Delete data"
	CheckBox DeleteData,variable= root:Packages:Irena:DataManIII:DeleteData, help={"Check, if you want to delete data"}
//	PopupMenu ManipulationSelected,pos={250,125},size={200,20},fStyle=2,proc=IR3DM_PopMenuProc,title="Function : "
//	SVAR ManipulationSelected = root:Packages:Irena:DataManIII:ManipulationSelected
//	PopupMenu ManipulationSelected,mode=1,popvalue=ManipulationSelected,value= #"root:Packages:Irena:DataManIII:ListOfManipulations" 

	CheckBox ProcessTrim,variable= root:Packages:Irena:DataManIII:ProcessData, help={"Check, if you want to process data somehow"}
	Button DeleteDataBTN,pos={290,190},size={200,20}, proc=IR3DM_ButtonProc,title="Delete data", help={"This will delete selected data"}
	Button DeleteDataBTN fColor=(65535,0,0)

	CheckBox ProcessTrim,pos={330,170},size={90,14},proc=IR3DM_CheckProc,title="Trim data"
	CheckBox ProcessTrim,variable= root:Packages:Irena:DataManIII:ProcessTrim, help={"Check, if you want to trim Q range"}
	SetVariable DataQEnd,pos={290,190},size={190,15}, proc=IR3DM_SetVarProc,title="Q max "
	Setvariable DataQEnd, variable=root:Packages:Irena:DataManIII:DataQEnd, limits={-inf,inf,0}
	SetVariable DataQstart,pos={290,210},size={190,15}, proc=IR3DM_SetVarProc,title="Q min  "
	Setvariable DataQstart, variable=root:Packages:Irena:DataManIII:DataQstart, limits={-inf,inf,0}

	CheckBox ProcessSubtractData,pos={330,250},size={90,14},proc=IR3DM_CheckProc,title="Subtract data"
	CheckBox ProcessSubtractData,variable= root:Packages:Irena:DataManIII:ProcessSubtractData, help={"Check, if you want to subtract a data set"}

	PopupMenu SelectFolderToSubtract,pos={262,270},size={180,20},fStyle=2,proc=IR3DM_PopMenuProc,title=" "
	SVAR SelectedFolderToSubtract = root:Packages:Irena:DataManIII:SelectedFolderToSubtract
	PopupMenu SelectFolderToSubtract,mode=1,popvalue=SelectedFolderToSubtract,value= IR3DM_ListAllData() 



	Button SelectAll,pos={200,680},size={80,15}, proc=IR3DM_ButtonProc,title="SelectAll", help={"Select All data in Listbox"}
//
	Button GetHelp,pos={430,50},size={80,15},fColor=(65535,32768,32768), proc=IR3DM_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}
//
//	
//	//and fix which controls are displayed:
//	
	IR3DM_SetupControlsOnMainpanel()
end



//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR3DM_SetupControlsOnMainpanel()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//SVAR ManipulationSelected = root:Packages:Irena:DataManIII:ManipulationSelected
	DoWindow IR3DM_DataManIIIPanel
	if(V_Flag)
		NVAR DeleteData = root:Packages:Irena:DataManIII:DeleteData		
		NVAR ProcessData = root:Packages:Irena:DataManIII:ProcessData
		DeleteData = !ProcessData
		NVAR ProcessTrim = root:Packages:Irena:DataManIII:ProcessTrim
		NVAR ProcessSubtractData = root:Packages:Irena:DataManIII:ProcessSubtractData


		Button DeleteDataBTN 	win=IR3DM_DataManIIIPanel, disable=ProcessData
		SetVariable DataQEnd 	win=IR3DM_DataManIIIPanel, disable=!(ProcessData*ProcessTrim)
		SetVariable DataQstart 	win=IR3DM_DataManIIIPanel, disable=!(ProcessData*ProcessTrim)
		CheckBox ProcessTrim	win=IR3DM_DataManIIIPanel, disable=DeleteData
		CheckBox ProcessSubtractData	win=IR3DM_DataManIIIPanel, disable=DeleteData
		PopupMenu SelectFolderToSubtract 	win=IR3DM_DataManIIIPanel, disable=!(ProcessData*ProcessSubtractData)
				
//		Setvariable Guinier_I0, disable=1
//		SetVariable Guinier_Rg, disable=1
//		SetVariable Porod_Constant, disable=1
//		Setvariable Sphere_ScalingConstant,  disable=1
//		SetVariable Sphere_Radius, disable=1
//		Setvariable Spheroid_ScalingConstant,  disable=1
//		SetVariable Spheroid_Radius, disable=1
//		Setvariable Spheroid_Beta,  disable=1
//		SetVariable DataBackground,  disable=1
//		SetVariable Porod_SpecificSurface, disable=1
//		SetVariable ScatteringContrast, disable=1
//
//		strswitch(SimpleModel)	// string switch
//			case "Guinier":	// execute if case matches expression
//				Setvariable Guinier_I0, disable=0
//				SetVariable Guinier_Rg, disable=0
//				break		// exit from switch
//			case "Porod":	// execute if case matches expression
//				SetVariable Porod_Constant, disable=0
//				SetVariable Porod_SpecificSurface, disable=0
//				SetVariable ScatteringContrast, disable=0
//				SetVariable DataBackground,  disable=0
//				break
//			case "Sphere":	// execute if case matches expression
//				Setvariable Sphere_ScalingConstant,  disable=0
//				SetVariable Sphere_Radius, disable=0
//				SetVariable DataBackground,  disable=0
//				break
//			case "Spheroid":	// execute if case matches expression
//				Setvariable Spheroid_ScalingConstant,  disable=0
//				SetVariable Spheroid_Radius, disable=0
//				Setvariable Spheroid_Beta,  disable=0
//				SetVariable DataBackground,  disable=0
//				break
//			default:			// optional default expression executed
//		endswitch
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3DM_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			NVAR DeleteData = root:Packages:Irena:DataManIII:DeleteData		
			NVAR ProcessData = root:Packages:Irena:DataManIII:ProcessData
			NVAR ProcessTrim = root:Packages:Irena:DataManIII:ProcessTrim
			if(stringmatch(cba.ctrlName,"DeleteData"))
				ProcessData  = !DeleteData
				if(DeleteData)
					KillWIndow/Z IR3DM_LogLogDataDisplay
				else
					IR3DM_CreateDM3Graphs()
				endif
				IR3DM_SetupControlsOnMainpanel()
			endif
			if(stringmatch(cba.ctrlName,"ProcessData"))
				DeleteData  = !ProcessData
				if(DeleteData)
					KillWIndow/Z IR3DM_LogLogDataDisplay
				else
					IR3DM_CreateDM3Graphs()
				endif
				IR3DM_SetupControlsOnMainpanel()
			endif
			if(stringmatch(cba.ctrlName,"ProcessTrim"))
				IR3DM_SetupControlsOnMainpanel()
			endif
			if(stringmatch(cba.ctrlName,"ProcessSubtractData"))
				IR3DM_SetupControlsOnMainpanel()
				IR3DM_AppendDataToGraphLogLog()
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3DM_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
//			if(stringmatch(ba.ctrlName,"FitCurrentDataSet"))
//				IR3J_FitData()
//			endif
//			if(stringmatch(ba.ctrlName,"RecordCurrentresults"))
//				NVAR SaveToNotebook=root:Packages:Irena:SimpleFits:SaveToNotebook
//				NVAR SaveToWaves=root:Packages:Irena:SimpleFits:SaveToWaves
//				NVAR SaveToFolder=root:Packages:Irena:SimpleFits:SaveToFolder
//				if(SaveToNotebook+SaveToWaves+SaveToFolder<1)
//					Abort "Nothing is selected to Record, check at least on checkbox above" 
//				endif	
//				IR3J_SaveResultsToNotebook()
//				IR3J_SaveResultsToWaves()
//				//IR3J_CleanUnusedParamWaves()
//				IR3J_SaveResultsToFolder()
//			endif
//			if(stringmatch(ba.ctrlName,"FitSelectionDataSet"))
//				IR3J_FitSequenceOfData()
//			endif
//			if(stringmatch(ba.ctrlName,"GetTableWithResults"))
//				IR3J_GetTableWithresults()	
//			endif
//			if(stringmatch(ba.ctrlName,"DeleteOldResults"))
//				IR3J_DeleteExistingModelResults()	
//			endif
			if(stringmatch(ba.ctrlName,"DeleteDataBTN"))
				DoAlert /T="This will REALLY delete data, are you sure?" 1, "Choose \"Yes\" to delete selected data type for ALL selected folders in the table. Are you sure you want to delete the data?"
				if(V_Flag==1)
					IR3DM_ProcessSequenceOfData("DeleteData")
				endif
				
			endif
			if(stringmatch(ba.ctrlName,"SelectAll"))
				Wave/Z SelectionOfAvailableData = root:Packages:Irena:SimpleFits:SelectionOfAvailableData
				if(WaveExists(SelectionOfAvailableData))
					SelectionOfAvailableData=1
				endif
			endif

			if(stringmatch(ba.ctrlName,"GetHelp"))
				IN2G_OpenWebManual("Irena/bioSAXS.html#basic-fits")				//fix me!!			
			endif

			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**************************************************************************************
//**************************************************************************************
//cannot be static, called from panel. 
Function/T IR3DM_ListAllData()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String AllDataFolders
	NVAR UseIndra2Data=root:Packages:Irena:DataManIII:UseIndra2Data
	NVAR UseQRSdata=root:Packages:Irena:DataManIII:UseQRSData
	NVAR  UseResults=  root:Packages:Irena:DataManIII:UseResults
	NVAR  UseUserDefinedData=  root:Packages:Irena:DataManIII:UseUserDefinedData
	NVAR  UseModelData = root:Packages:Irena:DataManIII:UseModelData
	SVAR StartFolderName=root:Packages:Irena:DataManIII:DataStartFolder
	SVAR DataMatchString= root:Packages:Irena:DataManIII:DataMatchString
	NVAR InvertGrepSearch=root:Packages:Irena:DataManIII:InvertGrepSearch
	
	AllDataFolders=IR3C_MultiGenStringOfFolders("Irena:DataManIII", StartFolderName,UseIndra2Data, UseQRSData,UseResults, 0,1)
	AllDataFolders = GrepList(AllDataFolders, "Packages", 1) 
	if(strlen(DataMatchString)>0)
		AllDataFolders = GrepList(AllDataFolders, DataMatchString, InvertGrepSearch) 
	endif
	AllDataFolders = ReplaceString(StartFolderName, AllDataFolders,"")
	//SVAR BufferMatchString=root:Packages:Irena:BioSAXSDataMan:BufferMatchString
	//select only Averaged data. 
	//if(strlen(BufferMatchString)>0)
	//	AllDataFolders = GrepList(AllDataFolders, BufferMatchString, 0) 
	//endif
	return AllDataFolders
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3DM_ProcessSequenceOfData(WhatToDO)
		string WhatToDO
		
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		//NVAR DelayBetweenProcessing=root:Packages:Irena:DataManIII:DelayBetweenProcessing
		Wave SelectionOfAvailableData = root:Packages:Irena:DataManIII:SelectionOfAvailableData
		Wave/T ListOfAvailableData = root:Packages:Irena:DataManIII:ListOfAvailableData
		variable i, imax
		imax = numpnts(ListOfAvailableData)
		For(i=0;i<imax;i+=1)
			if(SelectionOfAvailableData[i]>0.5)		//data set selected
				if(StringMatch(WhatToDO, "DeleteData"))
					IR3DM_DeleteData(ListOfAvailableData[i])
				endif
				//DoUpdate 
				//sleep/S/C=6/M="Fitted data for "+ListOfAvailableData[i] DelayBetweenProcessing
			endif
		endfor
		//IR3J_CleanUnusedParamWaves()
		print "all selected data processed"
		IR3C_MultiUpdListOfAvailFiles("Irena:DataManIII")

end
//**********************************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function IR3DM_DeleteData(FolderNameStr)
	string FolderNameStr
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:DataManIII					//go into the folder
		SVAR DataStartFolder=root:Packages:Irena:DataManIII:DataStartFolder
		SVAR DataFolderName=root:Packages:Irena:DataManIII:DataFolderName
		SVAR IntensityWaveName=root:Packages:Irena:DataManIII:IntensityWaveName
		SVAR QWavename=root:Packages:Irena:DataManIII:QWavename
		SVAR ErrorWaveName=root:Packages:Irena:DataManIII:ErrorWaveName
		SVAR dQWavename=root:Packages:Irena:DataManIII:dQWavename
		NVAR UseIndra2Data=root:Packages:Irena:DataManIII:UseIndra2Data
		NVAR UseQRSdata=root:Packages:Irena:DataManIII:UseQRSdata
		//these are variables used by the control procedure
		NVAR  UseResults=  root:Packages:Irena:DataManIII:UseResults
		NVAR  UseUserDefinedData=  root:Packages:Irena:DataManIII:UseUserDefinedData
		NVAR  UseModelData = root:Packages:Irena:DataManIII:UseModelData
		SVAR DataFolderName  = root:Packages:Irena:DataManIII:DataFolderName 
		SVAR IntensityWaveName = root:Packages:Irena:DataManIII:IntensityWaveName
		SVAR QWavename = root:Packages:Irena:DataManIII:QWavename
		SVAR ErrorWaveName = root:Packages:Irena:DataManIII:ErrorWaveName
		UseUserDefinedData = 0
		UseModelData = 0
		//get the names of waves, assume this tool actually works. May not under some conditions. In that case this tool will not work. 
		IR3C_SelectWaveNamesData("Irena:DataManIII", FolderNameStr)			//this routine will preset names in strings as needed,		
		Wave/Z SourceIntWv=$(DataFolderName+possiblyQUoteName(IntensityWaveName))
		Wave/Z SourceQWv=$(DataFolderName+possiblyQUoteName(QWavename))
		Wave/Z SourceErrorWv=$(DataFolderName+possiblyQUoteName(ErrorWaveName))
		Wave/Z SourcedQWv=$(DataFolderName+possiblyQUoteName(dQWavename))
		CheckDisplayed /A SourceIntWv, SourceQWv, SourceErrorWv, SourcedQWv
		if(V_Flag>0)
			Abort "Data from "+DataFolderName+" are in use in graph or table. Close all tables and graphs using it and try again."
		else
			print "Deleted Data from folder : "+DataFolderName
			KillWaves/Z SourceIntWv, SourceQWv, SourceErrorWv, SourcedQWv
			print "Deleted following waves: "+IntensityWaveName+", "+QWavename+", "+ErrorWaveName+", "+dQWavename
		endif
	SetDataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3DM_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	variable tempP
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
			NVAR DataQstart=root:Packages:Irena:DataManIII:DataQstart
			NVAR DataQEnd=root:Packages:Irena:DataManIII:DataQEnd
			NVAR DataQEndPoint = root:Packages:Irena:DataManIII:DataQEndPoint
			NVAR DataQstartPoint = root:Packages:Irena:DataManIII:DataQstartPoint
			
			if(stringmatch(sva.ctrlName,"DataQEnd"))
				WAVE OriginalDataQWave = root:Packages:Irena:DataManIII:OriginalDataQWave
				tempP = BinarySearch(OriginalDataQWave, DataQEnd )
				if(tempP<1)
					print "Wrong Q value set, Data Q max must be at most 1 point before the end of Data"
					tempP = numpnts(OriginalDataQWave)-2
					DataQEnd = OriginalDataQWave[tempP]
				endif
				DataQEndPoint = tempP	
				//set cursor
				Cursor /W=IR3DM_LogLogDataDisplay /P B  OriginalDataIntWave  DataQEndPoint		
				IR3DM_SyncCursorsTogether("OriginalDataIntWave","B",tempP)
			endif
			if(stringmatch(sva.ctrlName,"DataQstart"))
				WAVE OriginalDataQWave = root:Packages:Irena:DataManIII:OriginalDataQWave
				tempP = BinarySearch(OriginalDataQWave, DataQstart )
				if(tempP<1)
					print "Wrong Q value set, Data Q min must be at least 1 point from the start of Data"
					tempP = 1
					DataQstart = OriginalDataQWave[tempP]
				endif
				DataQstartPoint=tempP
				Cursor /W=IR3DM_LogLogDataDisplay /P A  OriginalDataIntWave  DataQstartPoint		
				IR3DM_SyncCursorsTogether("OriginalDataIntWave","A",tempP)
		endif
			break

		case 3: // live update
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3DM_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
//			if(StringMatch(pa.ctrlName, "ManipulationSelected" ))
//				SVAR ManipulationSelected = root:Packages:Irena:DataManIII:ManipulationSelected
//				ManipulationSelected = popStr
//				KillWindow/Z IR3DM_LogLogDataDisplay
//				IR3DM_CreateDM3Graphs()
//			endif
			if(StringMatch(pa.ctrlName, "SelectFolderToSubtract" ))
				SVAR SelectedFolderToSubtract = root:Packages:Irena:DataManIII:SelectedFolderToSubtract
				SelectedFolderToSubtract = popStr
				IR3DM_CopyAndAppendDataToSubtract(SelectedFolderToSubtract)
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


//**************************************************************************************
//**************************************************************************************

Function IR3DM_CopyAndAppendDataToSubtract(FolderNameStr)
	string FolderNameStr
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:DataManIII					//go into the folder

	SVAR DataFolderName=root:Packages:Irena:DataManIII:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena:DataManIII:IntensityWaveName
	SVAR QWavename=root:Packages:Irena:DataManIII:QWavename
	SVAR ErrorWaveName=root:Packages:Irena:DataManIII:ErrorWaveName
	SVAR dQWavename=root:Packages:Irena:DataManIII:dQWavename
	NVAR UseIndra2Data=root:Packages:Irena:DataManIII:UseIndra2Data
	NVAR UseQRSdata=root:Packages:Irena:DataManIII:UseQRSdata
	string OldFOlderName=DataFolderName
	IR3C_SelectWaveNamesData("Irena:DataManIII", FolderNameStr)			//this routine will preset names in strings as needed	
	SVAR SelectedFolderToSubtract = SelectedFolderToSubtract
	SelectedFolderToSubtract = 	FolderNameStr
	Wave/Z SourceIntWv=$(DataFolderName+possiblyQUoteName(IntensityWaveName))
	Wave/Z SourceQWv=$(DataFolderName+possiblyQUoteName(QWavename))
	Wave/Z SourceErrorWv=$(DataFolderName+possiblyQUoteName(ErrorWaveName))
	Wave/Z SourcedQWv=$(DataFolderName+possiblyQUoteName(dQWavename))
	if(!WaveExists(SourceIntWv)||	!WaveExists(SourceQWv))				//||!WaveExists(SourceErrorWv))
		Abort "Data selection failed for Data in routine IR3DM_CopyAndAppendDataToSubtract"
	endif
	Duplicate/O SourceIntWv, OrigIntToSubtractWave
	Duplicate/O SourceQWv, OrigQToSubtractWave
	if(WaveExists(SourceErrorWv))
		Duplicate/O SourceErrorWv, OrigErrorToSubtractWave
	else
		Duplicate/O SourceIntWv, OrigErrorToSubtractWave
		OrigErrorToSubtractWave = 0
	endif
	if(WaveExists(SourcedQWv))
		Duplicate/O SourcedQWv, OrigdQToSubtractWave
	else
		Duplicate/O SourceIntWv, OrigdQToSubtractWave
		OrigdQToSubtractWave = 0
	endif
	print "Added Data from folder for subtraction : "+DataFolderName
	IR3C_SelectWaveNamesData("Irena:DataManIII", OldFOlderName)			//this routine will preset names in strings as needed		
	IR3DM_AppendDataToGraphLogLog()
	SetDataFolder oldDf
end

//**************************************************************************************
Function IR3DM_CopyAndAppendData(FolderNameStr)
	string FolderNameStr
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:DataManIII					//go into the folder
		//OK, now we need to do what user wants. 
		//If Delete data, skip rest and do what user wants. 
		NVAR DeleteData= root:Packages:Irena:DataManIII:DeleteData
		if(DeleteData)
			NVAR WarnUserDeleteData=root:Packages:Irena:DataManIII:WarnUserDeleteData
			if(WarnUserDeleteData<0.5)
				DoAlert /T="This will REALLY delete data, are you sure?" 1, "Choose \"Yes\" to delete selected data type for ALL selected folders in the table. Are you sure you want to delete the data?"
				if(V_Flag==1)
					WarnUserDeleteData = 1
				else
					WarnUserDeleteData = 0
				endif
			endif
			if(WarnUserDeleteData)
				IR3DM_ProcessSequenceOfData("DeleteData")
				IR3C_MultiUpdListOfAvailFiles("Irena:DataManIII")
			endif
		else	//Add data to graph and process 
			SVAR DataStartFolder=root:Packages:Irena:DataManIII:DataStartFolder
			SVAR DataFolderName=root:Packages:Irena:DataManIII:DataFolderName
			SVAR IntensityWaveName=root:Packages:Irena:DataManIII:IntensityWaveName
			SVAR QWavename=root:Packages:Irena:DataManIII:QWavename
			SVAR ErrorWaveName=root:Packages:Irena:DataManIII:ErrorWaveName
			SVAR dQWavename=root:Packages:Irena:DataManIII:dQWavename
			NVAR UseIndra2Data=root:Packages:Irena:DataManIII:UseIndra2Data
			NVAR UseQRSdata=root:Packages:Irena:DataManIII:UseQRSdata
			//these are variables used by the control procedure
			NVAR  UseResults=  root:Packages:Irena:DataManIII:UseResults
			NVAR  UseUserDefinedData=  root:Packages:Irena:DataManIII:UseUserDefinedData
			NVAR  UseModelData = root:Packages:Irena:DataManIII:UseModelData
			SVAR DataFolderName  = root:Packages:Irena:DataManIII:DataFolderName 
			SVAR IntensityWaveName = root:Packages:Irena:DataManIII:IntensityWaveName
			SVAR QWavename = root:Packages:Irena:DataManIII:QWavename
			SVAR ErrorWaveName = root:Packages:Irena:DataManIII:ErrorWaveName
			UseUserDefinedData = 0
			UseModelData = 0
			//get the names of waves, assume this tool actually works. May not under some conditions. In that case this tool will not work. 
			IR3C_SelectWaveNamesData("Irena:DataManIII", FolderNameStr)			//this routine will preset names in strings as needed,		
			Wave/Z SourceIntWv=$(DataFolderName+possiblyQUoteName(IntensityWaveName))
			Wave/Z SourceQWv=$(DataFolderName+possiblyQUoteName(QWavename))
			Wave/Z SourceErrorWv=$(DataFolderName+possiblyQUoteName(ErrorWaveName))
			Wave/Z SourcedQWv=$(DataFolderName+possiblyQUoteName(dQWavename))
			if(!WaveExists(SourceIntWv)||	!WaveExists(SourceQWv))//||!WaveExists(SourceErrorWv))
				Abort "Data selection failed for Data in routine IR3DM_CopyAndAppendData"
			endif
			Duplicate/O SourceIntWv, OriginalDataIntWave
			Duplicate/O SourceQWv, OriginalDataQWave
			if(WaveExists(SourceErrorWv))
				Duplicate/O SourceErrorWv, OriginalDataErrorWave
			else
				Duplicate/O SourceIntWv, OriginalDataErrorWave
				OriginalDataErrorWave = 0
			endif
			if(WaveExists(SourcedQWv))
				Duplicate/O SourcedQWv, OriginalDatadQWave
			else
				dQWavename=""
			endif
			IR3DM_CreateDM3Graphs()
			//pauseUpdate
			IR3DM_AppendDataToGraphLogLog()
			//DoUpdate
			print "Added Data from folder : "+DataFolderName
		endif
	SetDataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


Function IR3DM_AppendDataToGraphLogLog()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IR3DM_CreateDM3Graphs()
	variable WhichLegend=0
	string Shortname1, SubtractShortName, legendText
	Wave/Z OriginalDataIntWave=root:Packages:Irena:DataManIII:OriginalDataIntWave
	Wave/Z OriginalDataQWave=root:Packages:Irena:DataManIII:OriginalDataQWave
	Wave/Z OriginalDataErrorWave=root:Packages:Irena:DataManIII:OriginalDataErrorWave
	if(!WaveExists(OriginalDataIntWave))
		return 0
	endif
	CheckDisplayed /W=IR3DM_LogLogDataDisplay OriginalDataIntWave
	if(!V_flag)
		AppendToGraph /W=IR3DM_LogLogDataDisplay  OriginalDataIntWave  vs OriginalDataQWave
		ModifyGraph /W=IR3DM_LogLogDataDisplay log=1, mirror(bottom)=1
		Label /W=IR3DM_LogLogDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity"
		Label /W=IR3DM_LogLogDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q[A\\S-1\\M"+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
		ErrorBars /W=IR3DM_LogLogDataDisplay OriginalDataIntWave Y,wave=(OriginalDataErrorWave,OriginalDataErrorWave)		
	endif
	NVAR DataQEnd = root:Packages:Irena:DataManIII:DataQEnd
	NVAR DataQstart = root:Packages:Irena:DataManIII:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:DataManIII:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:DataManIII:DataQstartPoint
	if(DataQstart>0)	 		//old Q min already set.
		DataQstartPoint = BinarySearch(OriginalDataQWave, DataQstart)
	endif
	if(DataQstartPoint<1)	//Qmin not set or not found. Set to point 2 on that wave. 
		DataQstart = OriginalDataQWave[1]
		DataQstartPoint = 1
	endif
	if(DataQEnd>0)	 		//old Q max already set.
		DataQEndPoint = BinarySearch(OriginalDataQWave, DataQEnd)
	endif
	if(DataQEndPoint<1)	//Qmax not set or not found. Set to last point-1 on that wave. 
		DataQEnd = OriginalDataQWave[numpnts(OriginalDataQWave)-2]
		DataQEndPoint = numpnts(OriginalDataQWave)-2
	endif
	SetWindow IR3DM_LogLogDataDisplay, hook(DM3LogCursorMoved) = $""
	cursor /W=IR3DM_LogLogDataDisplay B, OriginalDataIntWave, DataQEndPoint
	cursor /W=IR3DM_LogLogDataDisplay A, OriginalDataIntWave, DataQstartPoint
	SetWindow IR3DM_LogLogDataDisplay, hook(DM3LogCursorMoved) = IR3DM_GraphWindowHook


	NVAR ProcessSubtractData = root:Packages:Irena:DataManIII:ProcessSubtractData
	Wave/Z OriginalSubtractIntWave=root:Packages:Irena:DataManIII:OrigIntToSubtractWave
	Wave/Z OriginalSubtractQWave=root:Packages:Irena:DataManIII:OrigQToSubtractWave
	Wave/Z OriginalSubtractErrorWave=root:Packages:Irena:DataManIII:OrigErrorToSubtractWave
	if(ProcessSubtractData)
		if(WaveExists(OriginalSubtractIntWave) && WaveExists(OriginalSubtractQWave))
			CheckDisplayed /W=IR3DM_LogLogDataDisplay OriginalSubtractIntWave
			if(!V_flag)
				AppendToGraph /W=IR3DM_LogLogDataDisplay  OriginalSubtractIntWave  vs OriginalSubtractQWave
				ModifyGraph /W=IR3DM_LogLogDataDisplay rgb($(nameofWave(OriginalSubtractIntWave)))=(0,0,0)
				//ErrorBars /W=IR3DM_LogLogDataDisplay $(nameofWave(OriginalSubtractIntWave)) Y,wave=(OriginalSubtractErrorWave,OriginalSubtractErrorWave)		
			endif
		endif
	else
		RemoveFromGraph /W=IR3DM_LogLogDataDisplay /Z $(nameofWave(OriginalSubtractIntWave))
	endif

	SVAR DataFolderName=root:Packages:Irena:DataManIII:DataFolderName
	SVAR SelectedFolderToSubtract  = root:Packages:Irena:DataManIII:SelectedFolderToSubtract
	Shortname1 = StringFromList(ItemsInList(DataFolderName, ":")-1, DataFolderName  ,":")
	SubtractShortName = StringFromList(ItemsInList(SelectedFolderToSubtract, ":")-1, SelectedFolderToSubtract  ,":")
	if(ProcessSubtractData)
		SubtractShortName = "\\s("+nameofWave(OriginalSubtractIntWave)+") Subtract wave : "+ SubtractShortName
		legendText = "\\s(OriginalDataIntWave) "+Shortname1+"\r"+ SubtractShortName
		Legend/W=IR3DM_LogLogDataDisplay /C/N=text0/J/A=LB legendText
	else
		Legend/W=IR3DM_LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalDataIntWave) "+Shortname1
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3DM_GraphWindowHook(s)
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
			IR3DM_SyncCursorsTogether(s.traceName,s.cursorName,s.pointNumber)
			hookResult = 1
		// And so on . . .
	endswitch

	return hookResult	// 0 if nothing done, else 1
End
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3DM_SyncCursorsTogether(traceName,CursorName,PointNumber)
	string traceName,CursorName
	variable PointNumber

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IR3DM_CreateDM3Graphs()
	NVAR DataQEnd = root:Packages:Irena:DataManIII:DataQEnd
	NVAR DataQstart = root:Packages:Irena:DataManIII:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:DataManIII:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:DataManIII:DataQstartPoint
	Wave OriginalDataQWave=root:Packages:Irena:DataManIII:OriginalDataQWave
	Wave OriginalDataIntWave=root:Packages:Irena:DataManIII:OriginalDataIntWave
	variable tempMaxQ, tempMaxQY, tempMinQY, maxY, minY
	//check if user removed cursor from graph, in which case do nothing for now...
	if(numtype(PointNumber)==0)
		if(stringmatch(CursorName,"A"))		//moved cursor A, which is start of Q range
			DataQstartPoint = PointNumber
			DataQstart = OriginalDataQWave[PointNumber]
		endif
		if(stringmatch(CursorName,"B"))		//moved cursor B, which is end of Q range
			DataQEndPoint = PointNumber
			DataQEnd = OriginalDataQWave[PointNumber]
		endif
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3DM_CreateDM3Graphs()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable exists1=0
	NVAR DeleteData= root:Packages:Irena:DataManIII:DeleteData
	if(DeleteData)
		KillWindow/Z IR3DM_LogLogDataDisplay
	else
		DoWIndow IR3DM_LogLogDataDisplay
		if(V_Flag)
			DoWIndow/hide=? IR3DM_LogLogDataDisplay
			if(V_Flag==2)
				DoWIndow/F IR3DM_LogLogDataDisplay
			endif
		else
			Display /W=(521,10,1383,750)/K=1 /N=IR3DM_LogLogDataDisplay
			ShowInfo/W=IR3DM_LogLogDataDisplay
			exists1=1
		endif
		AutoPositionWindow/M=0/R=IR3DM_DataManIIIPanel IR3DM_LogLogDataDisplay	
	endif
end

//**********************************************************************************************************
//**********************************************************************************************************

//**********************************************************************************************************
//**********************************************************************************************************

Function IR3DM_InitDMIII()	


	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()
	string ListOfVariables
	string ListOfStrings
	variable i
		
	if (!DataFolderExists("root:Packages:Irena:DataManIII"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena
		NewDataFolder/O root:Packages:Irena:DataManIII
	endif
	SetDataFolder root:Packages:Irena:DataManIII					//go into the folder

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;DataUnits;"
	ListOfStrings+="DataStartFolder;DataMatchString;FolderSortString;FolderSortStringAll;"
	ListOfStrings+="UserMessageString;SavedDataMessage;SelectedFolderToSubtract;"
	//ListOfStrings+="SubtractWaveFolder;"

	ListOfVariables="UseIndra2Data1;UseQRSdata1;DataQEnd;DataQStart;DataQEndPoint;DataQstartPoint;"
	ListOfVariables+="DeleteData;ProcessData;WarnUserDeleteData;"
	ListOfVariables+="ProcessTrim;ProcessRebin;ProcessSubtractValue;ProcessSubtractData;"
	ListOfVariables+="ProcessRebinTarget;ProcessSubtractValueNumber;"

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
	SVAR SelectedFolderToSubtract
	SelectedFolderToSubtract = ""
//	SVAR ListOfManipulations
//	ListOfManipulations="TrimData;RebinData;SmoothData;DeleteData;"
//	SVAR ManipulationSelected
//	if(strlen(ManipulationSelected)<1)
//		ManipulationSelected="TrimData"
//	endif
	NVAR DeleteData
	NVAR ProcessData
	ProcessData = 1
	DeleteData = 0
	NVAR WarnUserDeleteData
	WarnUserDeleteData = 0
	
	Make/O/T/N=(0) ListOfAvailableData
	Make/O/N=(0) SelectionOfAvailableData
	SetDataFolder oldDf

end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
