#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version = 1.01
#include "HDF5Gateway"



// support of Nexus files

//1.01 fix for case when file does nto contain any V2 or V3 indicateors what data are and also has 3d data with dimsize(0)=1
//1.0  initial version, supports replacement of Nexus import in Nika with minor changes. 

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//					This is test procedure
//*****************************************************************************************************************
//*****************************************************************************************************************
Function NEXUS_TestFunction()

	KilLDatafolder/Z root:Packages:NexusImportTMP
	NewDataFolder/O root:Packages:NexusImportTMP
	
	string Status
	string Filename = "ABS_0061.hdf"
	Filename = "IN625_750C_577min_0807.h5"
	Filename = "nexus-example.hdf5"

	//import the file
	Status = H5GW_ReadHDF5("Convert2Dto1DDataPath", "root:Packages:NexusImportTMP", Filename)
	if(strlen(Status)>0)
		print Status		//if not "" then error ocured, Handle somehow!
		abort
	endif
	Filename = stringfromlist(0, Filename, ".")		//new folder name.  Will fail if there are more . in the name!
	string NewDataPath = "root:Packages:NexusImportTMP:"+PossiblyQuoteName(Filename)		//this should be where the file is.
	string AllNXData
	AllNXData = NEXUS_FindNXClassData(NewDataPath, "NXdata")		//find path to all NXdata, but this can be 2D, 1D, or 3D data sets. 
	variable i
	string NX1Ddata="", NX2Ddata="", NX3Ddata=""
	string tmpPath
	FOr(i=0;i<itemsInList(AllNXData);i+=1)
		tmpPath = stringfromlist(i,AllNXData)
		NX1Ddata+=NEXUS_IdentifyData(tmpPath, 1)
		NX2Ddata+=NEXUS_IdentifyData(tmpPath, 2)
		NX3Ddata+=NEXUS_IdentifyData(tmpPath, 3)
	endfor
	print "1d data : "+ NX1Ddata
	print "2d data : "+ NX2Ddata
	print "3d data : "+ NX3Ddata
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//					This is Configuration panel for Nika
//*****************************************************************************************************************
//*****************************************************************************************************************
Function NEXUS_ConfigurationPanelFnct() : Panel
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	DoWIndow NEXUS_ConfigurationPanel
	if(V_Flag)
		DoWIndow/F NEXUS_ConfigurationPanel
	else
		PauseUpdate; Silent 1		// building window...
		NewPanel /K=1/N= NEXUS_ConfigurationPanel/ W=(455,65,855,705) as "Nexus Configuration"
	
		TitleBox MainTitle title="\Zr200Nexus configuration panel",pos={5,2},frame=0,fstyle=3,size={395,24},fColor=(1,4,52428), anchor=MC
		TitleBox Info1 title="\Zr140Import data config",pos={5,30},frame=0,fstyle=1, size={150,20},fColor=(1,4,52428)
		TitleBox Info2 title="\Zr140Export data config",pos={5,335},frame=0,fstyle=1,size={150,20},fColor=(1,4,52428)
	
		
		//Import tabs
		TabControl ImportTabs,pos={2,52},size={396,260},proc=NEXUS_InputTabProc, value= 0
		TabControl ImportTabs,tabLabel(0)="Controls",tabLabel(1)="Param X-ref"
	//	TabControl ImportTabs,tabLabel(2)="3. Level ",tabLabel(3)="4. Level "
	//	TabControl ImportTabs,tabLabel(4)="5. Level ",value= 0
	
		CheckBox NX_InputFileIsNexus,pos={10,80},size={195,14},proc=Nexus_ConfigPanelCheckProc,title="Input file is Nexus?"
		CheckBox NX_InputFileIsNexus,help={"If input file is Nexus, check. This enables input options. "}
		CheckBox NX_InputFileIsNexus,variable= root:Packages:Irena_Nexus:NX_InputFileIsNexus
		CheckBox NX_CreateNotebookWithInfo,pos={10,110},size={195,14},noproc,title="Display Param Notebook?"
		CheckBox NX_CreateNotebookWithInfo,help={"Create Notebook with Parameters from Nexus file?"}
		CheckBox NX_CreateNotebookWithInfo,variable= root:Packages:Irena_Nexus:NX_CreateNotebookWithInfo
		CheckBox NX_ReadParametersOnLoad,pos={10,130},size={195,14},noproc,title="Read Params on Import?"
		CheckBox NX_ReadParametersOnLoad,help={"When importing NX data, read some parameters from the NX values?"}
		CheckBox NX_ReadParametersOnLoad,variable= root:Packages:Irena_Nexus:NX_ReadParametersOnLoad
	
		ListBox NX_LookupTable,pos={5,80},size={390,200}, mode=5, userColumnResize=1, widths={141,182,49}	
		ListBox NX_LookupTable,listWave=root:Packages:Irena_Nexus:ListOfParamsAndPaths
		ListBox NX_LookupTable,selWave=root:Packages:Irena_Nexus:ListOfParamsAndPathsSel
		ListBox NX_LookupTable,proc=NEXUS_ConfigListBox, help={"If needed select which parameters are suppose to be read on load"}
	
		SetVariable NX_GrepStringMask, pos={5,285}, size ={270,18}, variable=root:Packages:Irena_Nexus:GrepStringMask
		SetVariable NX_GrepStringMask, title="Mask Nexus names :"
		
		Button NX_ResetList, pos={290,285}, size={90,20}, title="Reset list", proc=NEXUS_InputPanelButtonProc
		Button NX_ResetList, help={"Reset the list above"}
		NEXUS_InputTabProc("",0)
		//output controls
		CheckBox NX_SaveToNexusFile,pos={10,360},size={195,14},proc=Nexus_ConfigPanelCheckProc,title="Save data to Nexus?"
		CheckBox NX_SaveToNexusFile,help={"Output data to Nexus file as selected below. "}
		CheckBox NX_SaveToNexusFile,variable= root:Packages:Irena_Nexus:NX_SaveToNexusFile
		
		CheckBox NX_CreateNewNexusFile,pos={10,390},size={195,14},proc=Nexus_ConfigPanelCheckProc,title="Create NEW Nexus file?"
		CheckBox NX_CreateNewNexusFile,help={"Create new Nexus file or append to existing file."}
		CheckBox NX_CreateNewNexusFile,variable= root:Packages:Irena_Nexus:NX_CreateNewNexusFile
		
		CheckBox NX_Append2DDataToNexus,pos={10,430},size={195,14},proc=Nexus_ConfigPanelCheckProc,title="Append processed 2D data to Nexus?"
		CheckBox NX_Append2DDataToNexus,help={"Append 2D calibrated and processed data into the Nexus file."}
		CheckBox NX_Append2DDataToNexus,variable= root:Packages:Irena_Nexus:NX_Append2DDataToNexus
	
		CheckBox NX_Append1DDataToNexus,pos={10,455},size={195,14},proc=Nexus_ConfigPanelCheckProc,title="Append processed 1D data to Nexus?"
		CheckBox NX_Append1DDataToNexus,help={"Append 2D calibrated and processed data into the Nexus file."}
		CheckBox NX_Append1DDataToNexus,variable= root:Packages:Irena_Nexus:NX_Append1DDataToNexus
	
		CheckBox NX_AppendBlankToNexus,pos={10,480},size={195,14},proc=Nexus_ConfigPanelCheckProc,title="Append Blank to Nexus?"
		CheckBox NX_AppendBlankToNexus,help={"Append Blank data into the Nexus file."}
		CheckBox NX_AppendBlankToNexus,variable= root:Packages:Irena_Nexus:NX_AppendBlankToNexus
	
		CheckBox NX_AppendMaskToNexus,pos={10,505},size={195,14},proc=Nexus_ConfigPanelCheckProc,title="Append Mask to Nexus?"
		CheckBox NX_AppendMaskToNexus,help={"Append 2D mask into the Nexus file."}
		CheckBox NX_AppendMaskToNexus,variable= root:Packages:Irena_Nexus:NX_AppendMaskToNexus
	endif	
End


//**************************************************************************************
//**************************************************************************************
Function NEXUS_InputTabProc(name,tab) : TabControl
	String name
	Variable tab

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	NVAR NX_ReadParametersOnLoad = root:Packages:Irena_Nexus:NX_ReadParametersOnLoad
	NVAR InputisNexus=root:Packages:Irena_Nexus:NX_InputFileIsNexus
	
	CheckBox NX_InputFileIsNexus, disable=(tab!=0 || !InputisNexus), win=NEXUS_ConfigurationPanel
	CheckBox NX_CreateNotebookWithInfo, disable=(tab!=0 || !InputisNexus), win=NEXUS_ConfigurationPanel
	CheckBox NX_ReadParametersOnLoad, disable=(tab!=0|| !InputisNexus), win=NEXUS_ConfigurationPanel
	ListBox NX_LookupTable, disable=(tab!=1 || NX_ReadParametersOnLoad!=1|| !InputisNexus), win=NEXUS_ConfigurationPanel
	SetVariable NX_GrepStringMask, disable=(tab!=1 || NX_ReadParametersOnLoad!=1|| !InputisNexus), win=NEXUS_ConfigurationPanel
	Button NX_ResetList, disable=(tab!=1 || NX_ReadParametersOnLoad!=1|| !InputisNexus), win=NEXUS_ConfigurationPanel
	return 0
End

//**************************************************************************************
//**************************************************************************************

Function Nexus_ConfigPanelCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(stringmatch(cba.ctrlName,"NX_InputFileIsNexus"))
				NEXUS_InputTabProc("",0)
				Nexus_SetOutputControls()
			endif
			if(stringmatch(cba.ctrlName,"NX_SaveToNexusFile"))
				Nexus_SetOutputControls()
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//**************************************************************************************
//**************************************************************************************

Function Nexus_SetOutputControls()
	NVAR SaveToNexus=root:Packages:Irena_Nexus:NX_SaveToNexusFile
	NVAR InputisNexus=root:Packages:Irena_Nexus:NX_InputFileIsNexus
	NVAR NX_CreateNewNexusFile=root:Packages:Irena_Nexus:NX_CreateNewNexusFile
	if(!InputisNexus && SaveToNexus)
		NX_CreateNewNexusFile=1
	endif

	CheckBox NX_CreateNewNexusFile,disable=!SaveToNexus, win=NEXUS_ConfigurationPanel
	CheckBox NX_Append2DDataToNexus,disable=!SaveToNexus, win=NEXUS_ConfigurationPanel
	CheckBox NX_Append1DDataToNexus,disable=!SaveToNexus, win=NEXUS_ConfigurationPanel
	CheckBox NX_AppendBlankToNexus,disable=!SaveToNexus, win=NEXUS_ConfigurationPanel
	CheckBox NX_AppendMaskToNexus,disable=!SaveToNexus, win=NEXUS_ConfigurationPanel
	
end

//**************************************************************************************
//**************************************************************************************

Function NEXUS_ConfigListBox(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	Variable/g row = lba.row
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave
	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
			if (lba.eventMod & 0x10)			// Right-click?
			//if (lba.eventMod & 2^4)			// Right-click?
				row = lba.row
				PopupContextualMenu NEXUS_NXParamSelection(row) 
				if( strlen(S_selection) <1  )
					//Print "User did not select anything"
				else
					listWave[row][1] = S_selection
				endif
			endif
			break
		case 3: // double click
			break
		case 4: // cell selection
			selWave = 0
			if (lba.col ==2 )			//third column is the only editable one
				selWave [lba.row][lba.col] = 3
			endif
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
Function/T NEXUS_NXParamSelection(row)
	variable row
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	SVAR DataFolderName = root:Packages:Irena_Nexus:DataFolderName
	SVAR GrepStringMask = root:Packages:Irena_Nexus:GrepStringMask
	Wave HDF5___xref = $(DataFolderName+"HDF5___xref")					//list of parameters in teh Nexdus file
	Wave ListOfParamsAndPaths = root:Packages:Irena_Nexus:ListOfParamsAndPaths	//list of parameters in Nika
	
	string result, SearchTerm
	SearchTerm =""
	variable i
	result = "---;"
	Duplicate/FREE/R=[][1]/T HDF5___xref,  UsefulNodes
	Grep/E=GrepStringMask UsefulNodes as UsefulNodes
	for(i=0;i<numpnts(UsefulNodes);i+=1)
		if(strlen(UsefulNodes[i])>5)
			result+=UsefulNodes[i]+";"
		endif	
	endfor
	return result
end
//**************************************************************************************
//**************************************************************************************
Function NEXUS_InputPanelButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlname,"NX_ResetList"))
				//reset the list now... 
				NEXUS_ResetParamXRef(1)
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**************************************************************************************
//**************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
// 		Nexus_2DDataReader - copies functionality of the old NI2NX_NexusReader to function as replacement. 
//*****************************************************************************************************************
//*****************************************************************************************************************


Function NEXUS_Nexus2DDataReader(FilePathName,Filename)
		string FilePathName,Filename
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
		
		string OldDf=getDataFolder(1)
		SVAR/Z DataFolderName = root:Packages:Irena_Nexus:DataFolderName
		if(!SVAR_Exists(DataFOldername))	//not yet initialized and used?
			NEXUS_Initialize(0)
		endif
		string PathToNewData= NEXUS_ImportAFile(FilePathName,Filename)		//this will import data file. "" if failed
		if(strlen(PathToNewData)<1)
			Abort "Import of the data failed"
		else
			PathToNewData+=":"						//needs ending ":" and it is not there...
		endif
		DataFolderName = PathToNewData
		string AllNXData
		AllNXData = NEXUS_FindNXClassData(PathToNewData, "NXdata")		//find path to all NXdata, but this can be 2D, 1D, 3D, or 4D data sets. 
		//note: 3D and 4D data which are degenerate (some dimensions have 1 element) will be collapsed by this function to 2D data
		string NX2Ddata=""
		string tmpPath
		variable i
		For(i=0;i<itemsInList(AllNXData);i+=1)
			tmpPath = stringfromlist(i,AllNXData)
			NX2Ddata+=NEXUS_IdentifyData(tmpPath, 2)
		endfor
		if(ItemsInList(NX2Ddata)>1 || ItemsInList(NX2Ddata)<1)
			Abort "More or less than 1 2D data set found, cannot handle this for now, stopping"
		endif
		Wave DataWave = $(stringfromlist(0,NX2Ddata))			//just to make sure, pick the first one here (removes ending ;)
		Duplicate/O DataWave, $("root:Packages:Convert2Dto1D:Loadedwave0")
		Wave DataWv=$("root:Packages:Convert2Dto1D:Loadedwave0")
		//If it is actually 3D wave but with first dimension of dimsize=1, reduce rank from [1][p][q] to only [p][q]
		if(WaveDims(DataWave) == 3)
			Redimension/N=(dimsize(DataWv,1),dimsize(DataWv,2)) DataWv
		else

		endif
		NEXUS_CleanUpHDF5Structure(DataWv, PathToNewData)
		NEXUS_CreateWvNtNbk(DataWv, Filename)
		NEXUS_ReadNXparameters(PathToNewData)
		SetDataFolder OldDF
End

//*****************************************************************************************************************
//*****************************************************************************************************************
Function NEXUS_ReadNXparameters(PathToNewData)
		string PathToNewData
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
		//print GetRTStackInfo(0 )
		string OldDf=getDataFolder(1)
		NVAR ReadParams = root:Packages:Irena_Nexus:NX_ReadParametersOnLoad
		variable i, ScaleFctVal, skipLoading
		string NikaParameterStr, NexusPathStr
		//depending on what we are reading, replace these SampleI0, SampleMeasurementTime; 
		//removed Blank and empty values here: EmptyI0;BackgroundMeasTime;EmptyMeasurementTime;
		SVAR ImageBeingLoaded=root:Packages:Convert2Dto1D:ImageBeingLoaded
		//this will be Empty, Dark, sample, or ""
		if(ReadParams&&(strlen(ImageBeingLoaded)>3))
			Wave/Z/T ListOfParamsAndPaths = root:Packages:Irena_Nexus:ListOfParamsAndPaths
			if(WaveExists(ListOfParamsAndPaths))
				SetDataFolder root:Packages:Convert2Dto1D:
				For(i=0;i<dimsize(ListOfParamsAndPaths,0);i+=1)
					NikaParameterStr = ListOfParamsAndPaths[i][0]
					skipLoading = 0
					//now the replacements if needed... This will be cumbersome. 
					if(stringMatch(ImageBeingLoaded,"Empty"))
						if(stringmatch(NikaParameterStr,"SampleI0"))
							NikaParameterStr = "EmptyI0"
						endif
						if(stringmatch(NikaParameterStr,"SampleMeasurementTime"))
							NikaParameterStr = "EmptyMeasurementTime"
						endif
					elseif(stringMatch(ImageBeingLoaded,"Dark"))
						if(stringmatch(NikaParameterStr,"SampleI0"))
							skipLoading= 1
						endif
						if(stringmatch(NikaParameterStr,"SampleMeasurementTime"))
							NikaParameterStr = "BackgroundMeasTime"
						endif
					endif
					NexusPathStr = ListOfParamsAndPaths[i][1]
					ScaleFctVal = str2num(ListOfParamsAndPaths[i][2])
					Wave/Z NexParWv = $(removeending(PathToNewData,":")+NexusPathStr)
					if(WaveExists(NexParWv)&&!skipLoading)			//there is valid pointer to the data.
						NVAR NikaPar = $(NikaParameterStr)
						NikaPar = ScaleFctVal * NexParWv[0]
						print "Read Nexus parameter "+NexusPathStr+", scaled by "+num2str(ScaleFctVal)+" and set "+NikaParameterStr+" = "+num2str(NikaPar)
					endif
				endfor
			else
				Abort "Lookup table does not exist." 
			endif
		endif
		SetDataFolder OldDF
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function/T NEXUS_ImportAFile(FilePathName,Filename)
		string FilePathName,Filename

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	NEXUS_Initialize(0)
	KilLDatafolder/Z root:Packages:NexusImportTMP
	NewDataFolder/O root:Packages:NexusImportTMP
	string Status
	//import the file
	Status = H5GW_ReadHDF5(FilePathName, "root:Packages:NexusImportTMP", Filename)
	if(strlen(Status)>0)
		print Status		//if not "" then error ocured, Handle somehow!
		return ""
	endif
	Filename = stringfromlist(0, Filename, ".")		//new folder name.  Will fail if there are more . in the name!
	string NewDataPath = "root:Packages:NexusImportTMP:"+PossiblyQuoteName(Filename)		//this should be where the file is.
	return NewDataPath
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function NEXUS_CreateWvNtNbk(WaveWithWaveNote, SampleName)
	wave WaveWithWaveNote
	string SampleName
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	if(!WaveExists(WaveWithWaveNote))		//hm, are we laoding the empty?
		return 0
	else
		string OldNOte=note(WaveWithWaveNote)
		variable i
		String nb 	
		nb = "Sample_Information"
		DoWindow Sample_Information
		if(V_Flag)
			DoWindow /K Sample_Information
		endif
		NVAR NX_CreateNotebookWithInfo = root:Packages:Irena_Nexus:NX_CreateNotebookWithInfo
		if(NX_CreateNotebookWithInfo)
			NewNotebook/N=$nb/F=1/V=1/K=1/W=(700,10,1100,700)
			Notebook $nb defaultTab=36, statusWidth=252
			Notebook $nb showRuler=1, rulerUnits=1, updating={1, 60}
			Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
			Notebook $nb newRuler=Title, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",12,3,(0,0,0)}
			Notebook $nb ruler=Title, text="Header information for "+SampleName+"\r"
			Notebook $nb ruler=Normal, text="\r"
			For(i=0;i<ItemsInList(OldNOte,";");i+=1)
					Notebook $nb text=stringFromList(i,OldNOte,";")+ " \r"
			endfor
			Notebook $nb selection={startOfFile,startOfFile}
			Notebook $nb text=""
		endif
	endif	
	return 1
end

//*****************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

static Function NEXUS_CleanUpHDF5Structure(DataWv, Fldrname)
	Wave DataWv
	string FldrName
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	string StartDf
	StartDf = Fldrname+"entry:"
	string PathToStrVarValues = "root:Packages:NexusImportTMP:"
	IN2G_UniversalFolderScan(startDF, 50, "NEXUS_ConvertTxTwvToStringList(\""+StartDf+"\",\""+PathToStrVarValues+"\")")
	IN2G_UniversalFolderScan(startDF, 50, "NEXUS_ConvertNumWvToStringList(\""+StartDf+"\",\""+PathToStrVarValues+"\")")
	//now we have moved the data to stringgs and main folder of the Nexus file name 
	SVAR/Z StringVals=$(PathToStrVarValues+"ListOfStrValues")
	SVAR/Z NumVals=$(PathToStrVarValues+"ListOfNumValues")
	if(SVAR_Exists(StringVals))
		note/NOCR DataWv, "\r\t\tNEXUS_StringDataStartHere;"+StringVals+"\t\tNEXUS_StringDataEndHere;"
	endif
	if(SVAR_Exists(NumVals))
		note/NOCR DataWv, "\t\tNEXUS_VariablesDataStartHere;"+NumVals+"\t\tNEXUS_VariablesDataEndHere;"
	endif
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NEXUS_ConvertTxTwvToStringList(StartFolderStr, Fldrname)
	string StartFolderStr, Fldrname

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	string Newkey=GetDataFolder(1)[strlen(StartFolderStr),inf]
	string ListOfTXTWaves=WaveList("*", ";", "TEXT:1" )
      SVAR/Z ListOfStrValues = $(Fldrname+"ListOfStrValues")
	if(!SVAR_Exists(ListOfStrValues))
		string/g $(Fldrname+"ListOfStrValues")
		SVAR/Z ListOfStrValues = $(Fldrname+"ListOfStrValues")
	endif
		variable i
		for(i=0;i<ItemsInList(ListOfTXTWaves,";");i+=1)
			ListOfStrValues+=Newkey+StringFromList(i, ListOfTXTWaves  , ";")+"="
			Wave/T tempWv=$(StringFromList(i, ListOfTXTWaves  , ";"))
			ListOfStrValues+=tempWv[0]+";"
			//KillWaves/Z tempWv
		endfor
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NEXUS_ConvertNumWvToStringList(StartFolderStr, Fldrname)
	string  StartFolderStr, Fldrname
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	//SVAR StartFolderStr=root:Packages:NexusImportTMP:StartFolderStr
	string Newkey=GetDataFolder(1)[strlen(StartFolderStr),inf]
	string ListOfNumWaves=WaveList("*", ";", "TEXT:0,DIMS:1" )
      SVAR/Z ListOfNumValues = $(Fldrname+"ListOfNumValues")
	if(!SVAR_Exists(ListOfNumValues))
		string/g $(Fldrname+"ListOfNumValues")
		SVAR/Z ListOfNumValues = $(Fldrname+"ListOfNumValues")
	endif
		variable i
		for(i=0;i<ItemsInList(ListOfNumWaves,";");i+=1)
			ListOfNumValues+=Newkey+StringFromList(i, ListOfNumWaves  , ";")+"="
			Wave tempWv=$(StringFromList(i, ListOfNumWaves  , ";"))
			ListOfNumValues+=num2str(tempWv[0])+";"
			//KillWaves/Z tempWv
		endfor
end

//*****************************************************************************************************************
//*****************************************************************************************************************
Function/T NEXUS_FindNXClassData(DataPathStr, NXClassStr)
	string DataPathStr, NXClassStr
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	string oldDf=GetDataFolder(1)
	SetdataFolder root:Packages:Irena_Nexus
	string/g FoundClassDataLocation
	FoundClassDataLocation = ""
	IN2G_UniversalFolderScan(DataPathStr, 30, "NEXUS_SearchForType(\""+NXClassStr+"\")")
	setDataFOlder OldDF
	return FoundClassDataLocation
end

//*****************************************************************************************************************
//*****************************************************************************************************************
Function/T NEXUS_IdentifyData(PathToData, dimensions)
	string PathToData
	variable dimensions
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	string oldDf=GetDataFolder(1)
	SetDataFolder $(PathToData)
	Wave/Z Igor___folder_attributes
	string tmpnote,result, tmpSigName,tmpIndices
	result = ""
	if(WaveExists(Igor___folder_attributes))
		tmpnote = note(Igor___folder_attributes)
		if(GrepString(tmpnote, "NX_class=NXdata"))
			tmpSigName = StringByKey("signal", tmpnote, "=" , "\r" )			//this is V3 of Nexus data, signal = dataname in Folder attributes
			if(strlen(tmpSigName)<1)		//OK, Version 3 failed, may be it is Version 2? In that case signal =  1 is in the note of the Signal wave itself
				tmpSigName = NEXUS_FindSignalV2Data()
			endif
			//fix if this is missing (WAXS) and try to pick the "data" wave
			if(strlen(tmpSigName)<2)
				Wave/Z Data
				if(WaveExists(Data))
					tmpSigName="Data"
				endif
			endif
			//OK, even this seems to fail on some data, so let's see if there is at least one 2D wave here and use that. Pick the first one, bad choice but what else can we do? 
			if(strlen(tmpSigName)<1)		//
				tmpSigName = NEXUS_FindAnySignalData()
			endif
			
			tmpIndices = StringByKey("Q_indices", tmpnote, "=" , "\r" )
			if(strlen(tmpIndices)>0)
				tmpSigName+=tmpIndices
			endif
			Wave/Z Signal=$(tmpSigName)
			variable tempDims
			if(WaveExists(Signal))
				tempDims = WaveDims(Signal)
				if(DimSize(Signal,0)==1)
					tempDims-=1
				endif
				if(dimensions == tempDims)
					result = PathToData+tmpSigName
				endif
			endif
		endif
	else
		Abort "Cannot find necessary Igor___folder_attributes"
	endif
	setDataFOlder OldDF
	if(strlen(result)>1)
		result+=";"
	endif
	return result
end
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function/S NEXUS_FindSignalV2Data()
	//check each wave in curren tfolder if it has signal= 1 in the wavenote
	string WavenameStr=""
	string objName
	variable index
	do
		objName = GetIndexedObjName(":", 1, index)
		if (strlen(objName) == 0)
			break
		endif
		Wave TestWv = $(objName)
		if(NumberByKey("signal", note(TestWv), "=", "\r"))
			WavenameStr = objName
			break
		endif
		index += 1
	while(1)
	return WavenameStr
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function/S NEXUS_FindAnySignalData()
	//check each wave in current folder and selects the first one which has 2D data in it
	string WavenameStr=""
	string objName
	variable index
	do
		objName = GetIndexedObjName(":", 1, index)
		if (strlen(objName) == 0)
			WavenameStr=""
			break
		endif
		Wave TestWv = $(objName)
		if(WaveDims(TestWv) == 2 || (WaveDims(TestWv) == 3 && DimSize(TestWv, 0)==1))
			WavenameStr = objName
			break
		endif
		index += 1
	while(1)
	return WavenameStr
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function NEXUS_SearchForType(WhichNXClass)
	string WhichNXClass
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	SVAR FoundClassDataLocation = root:Packages:Irena_Nexus:FoundClassDataLocation
	Wave/Z Igor___folder_attributes
	string tmpnote
	if(WaveExists(Igor___folder_attributes))
		tmpnote = note(Igor___folder_attributes)
		if(GrepString(tmpnote, "NX_class="+WhichNXClass))
			FoundClassDataLocation+=GetDataFolder(1)+";"
		endif
	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function NEXUS_Initialize(enforceReset)
	variable enforceReset
	//function, which creates the folder and creates the strings and variables
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	string oldDf=GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewdataFolder/O/S root:Packages:Irena_Nexus	
	string ListOfVariables
	string ListOfStrings
	
	//here define the lists of variables and strings needed, separate names by ;...
	//read part
	ListOfVariables="NX_InputFileIsNexus;NX_CreateNotebookWithInfo;NX_ReadParametersOnLoad;"
	//write part
	ListOfVariables+="NX_SaveToNexusFile;NX_CreateNewNexusFile;NX_Append2DDataToNexus;NX_Append1DDataToNexus;"
	ListOfVariables+="NX_AppendBlankToNexus;NX_AppendMaskToNexus;"
	//read part	
	ListOfStrings="DataFolderName;GrepStringMask;"
	//write part
	ListOfStrings+="ExportDataFolderName;"
	
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	
	wave/Z/T ListOfParamsAndPaths 
	WAVE/Z ListOfParamsAndPathsSel
	if(!WaveExists(ListOfParamsAndPathsSel) || !WaveExists(ListOfParamsAndPaths)|| enforceReset)	
		NEXUS_ResetParamXRef(enforceReset)
	endif
	
	setDataFolder OldDF							
end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function NEXUS_ResetParamXRef(enforce)
	variable enforce
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena_Nexus
	string ParamsNames
	variable i
	ParamsNames="SampleThickness;SampleTransmission;SampleI0;"
	ParamsNames+="SampleMeasurementTime;"
	ParamsNames+="SampleToCCDDistance;Wavelength;XrayEnergy;BeamCenterX;BeamCenterY;"
	ParamsNames+="BeamSizeX;BeamSizeY;PixelSizeX;PixelSizeY;HorizontalTilt;VerticalTilt;"
	ParamsNames+="CorrectionFactor;"
	//removed Blank and empty values here: EmptyI0;BackgroundMeasTime;EmptyMeasurementTime;
	
	variable OldListLength
	wave/Z/T ListOfParamsAndPaths 
	WAVE/Z ListOfParamsAndPathsSel
	if(WaveExists(ListOfParamsAndPaths))
		OldListLength=dimsize(ListOfParamsAndPaths,0)
		if(OldListLength!=ItemsInList(ParamsNames))		//this list has changed from last time...
			enforce =1				//need to be reset!
		endif
	endif
	if(!WaveExists(ListOfParamsAndPathsSel) || !WaveExists(ListOfParamsAndPaths) || enforce)	
		Make/O/T/N=(ItemsInList(ParamsNames),3) ListOfParamsAndPaths
		SetDimLabel 1,0,NikaParameter,ListOfParamsAndPaths
		SetDimLabel 1,1,NexusPath,ListOfParamsAndPaths
		SetDimLabel 1,2,ScaleFct,ListOfParamsAndPaths
		Make/O/N=(ItemsInList(ParamsNames),3,2) ListOfParamsAndPathsSel
		//and set the proper values...
		For(i=0;i<ItemsInList(ParamsNames);i+=1)
			ListOfParamsAndPaths[i][0] = stringFromList(i,ParamsNames)
		endfor	
		//ListOfParamsAndPathsSel[][0][0] = 0x20
		//ListOfParamsAndPathsSel[][0][1] = p
		ListOfParamsAndPathsSel[][0] = 0
		ListOfParamsAndPathsSel[][1] = 0
		ListOfParamsAndPathsSel[][2] = 0
			ListOfParamsAndPaths[][1] = "---"
		ListOfParamsAndPaths[][2] = "1"
	endif
	setDataFolder OldDF							
end
//*****************************************************************************************************************
//*****************************************************************************************************************


