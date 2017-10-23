#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version = 1.05
#include "HDF5Gateway"

constant NexusVersionNumber=1.05

// support of Nexus files

//1.05 add support for multidimensional data
//1.04 fixes for Nexus standard development and suggested units
//1.03 minor fix to forcing naming of output data. 
//1.02 Many modifications for Nexus Import - and EXPORT of data, import to Irena, export from and to Nika. 
//		Irena - import NXcanSAS, Nika - import NXsas, export NXcanSAS or NXsas.  
//1.01 fix for case when file does nto contain any V2 or V3 indicateors what data are and also has 3d data with dimsize(0)=1
//1.0  initial version, supports replacement of Nexus import in Nika with minor changes. 

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//					This is test procedure
//*****************************************************************************************************************
//*****************************************************************************************************************
//Function NEXUS_TestFunction()
//
//	KilLDatafolder/Z root:Packages:NexusImportTMP
//	NewDataFolder/O root:Packages:NexusImportTMP
//	
//	string Status
//	string Filename = "ABS_0061.hdf"
//	Filename = "IN625_750C_577min_0807.h5"
//	Filename = "nexus-example.hdf5"
//
//	//import the file
//	Status = H5GW_ReadHDF5("Convert2Dto1DDataPath", "root:Packages:NexusImportTMP", Filename)
//	if(strlen(Status)>0)
//		print Status		//if not "" then error ocured, Handle somehow!
//		abort
//	endif
//	Filename = stringfromlist(0, Filename, ".")		//new folder name.  Will fail if there are more . in the name!
//	string NewDataPath = "root:Packages:NexusImportTMP:"+PossiblyQuoteName(Filename)		//this should be where the file is.
//	string AllNXData
//	AllNXData = NEXUS_FindNXdataClassData(NewDataPath, "NXdata")		//find path to all NXdata, but this can be 2D, 1D, or 3D data sets. 
//	variable i
//	string NX1Ddata="", NX2Ddata="", NX3Ddata=""
//	string tmpPath
//	FOr(i=0;i<itemsInList(AllNXData);i+=1)
//		tmpPath = stringfromlist(i,AllNXData)
//		NX1Ddata+=NEXUS_IdentifyNxData(tmpPath, 1)
//		NX2Ddata+=NEXUS_IdentifyNxData(tmpPath, 2)
//		NX3Ddata+=NEXUS_IdentifyNxData(tmpPath, 3)
//	endfor
//	print "1d data : "+ NX1Ddata
//	print "2d data : "+ NX2Ddata
//	print "3d data : "+ NX3Ddata
//end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//					This is Configuration panel for Nika
//*****************************************************************************************************************
//*****************************************************************************************************************
Function NEXUS_NikaCall(CreatePanel)
	variable CreatePanel

	if(CreatePanel==2)
		KillWIndow/Z NEXUS_ConfigurationPanel
	endif
	
	if(CreatePanel>0)
		DoWindow NEXUS_ConfigurationPanel
		if(V_Flag)
			DoWIndow/F NEXUS_ConfigurationPanel
		else
			NEXUS_Initialize(0)
			NEXUS_NikaConfigPanelFnct()
			IR1_UpdatePanelVersionNumber("NEXUS_ConfigurationPanel", NexusVersionNumber,1)
		endif
		SVAR DataFileExtension=root:Packages:Convert2Dto1D:DataFileExtension
		NVAR NX_InputFileIsNexus = root:Packages:Irena_Nexus:NX_InputFileIsNexus
		//sync with Nika input Image type here...
		if(StringMatch(DataFileExtension, "Nexus"))
			NX_InputFileIsNexus=1
		else
			NX_InputFileIsNexus=0
		endif
		///NEXUS_InputTabProc("",0)
	endif 

	DoWindow NEXUS_ConfigurationPanel
	if(V_Flag)
		DoWIndow/F NEXUS_ConfigurationPanel
		NEXUS_InputTabProc("",0)
		Nexus_SetOutputControls()
		DoWindow NI1A_Convert2Dto1DPanel
		if(V_Flag)
			AutoPositionWindow/M=0 /R=NI1A_Convert2Dto1DPanel  NEXUS_ConfigurationPanel
		endif
	endif
end
//***********************************************************
//***********************************************************
static Function IR1_UpdatePanelVersionNumber(panelName, CurentProcVersion, AddResizeHookFunction)
	string panelName
	variable CurentProcVersion
	variable AddResizeHookFunction  		//set to 0 for no, 1 for simple Irena one and 2 for Wavemetrics one
	DoWIndow $panelName
	if(V_Flag)
		GetWindow $(panelName), note
		SetWindow $(panelName), note=S_value+";"+"NikaProcVersion:"+num2str(CurentProcVersion)+";"
		if(AddResizeHookFunction==1)
			IN2G_PanelAppendSizeRecordNote(panelName)
			SetWindow $panelName,hook(ResizePanelControls)=IN2G_PanelResizePanelSize
		endif
	endif
end
 
//*****************************************************************************************************************
//*****************************************************************************************************************
Function Nexus_MainCheckVersion()	
	DoWindow NEXUS_ConfigurationPanel
	if(V_Flag)
		if(!NI1_CheckPanelVersionNumber("NEXUS_ConfigurationPanel", NexusVersionNumber))
			DoAlert /T="The Nexus configuration panel was created by old version of Nika " 1, "Nexus Config needs to be reopened to work properly. Restart now?"
			if(V_flag==1)
				Execute/P("NEXUS_NikaCall(2)")
			else		//at least reinitialize the variables so we avoid major crashes...
				NEXUS_Initialize(0)
			endif
		endif
	endif
end
//***********************************************************
//*********************************************************** 
static Function NI1_CheckPanelVersionNumber(panelName, CurentProcVersion)
	string panelName
	variable CurentProcVersion
 
	DoWIndow $panelName
	if(V_Flag)	
		GetWindow $(panelName), note
		if(stringmatch(stringbyKey("NikaProcVersion",S_value),num2str(CurentProcVersion))) //matches
			return 1
		else
			return 0
		endif
	else
		return 1
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
Function NEXUS_NikaConfigPanelFnct() : Panel
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
		TabControl ImportTabs,pos={2,52},size={396,275},proc=NEXUS_InputTabProc, value= 0
		TabControl ImportTabs,tabLabel(0)="Controls",tabLabel(1)="Param X-ref"
	
		CheckBox NX_InputFileIsNexus,pos={10,80},size={195,14},proc=Nexus_ConfigPanelCheckProc,title="Input file is Nexus?"
		CheckBox NX_InputFileIsNexus,help={"If input file is Nexus, check. This enables input options. "}
		CheckBox NX_InputFileIsNexus,variable= root:Packages:Irena_Nexus:NX_InputFileIsNexus
		CheckBox NX_CreateNotebookWithInfo,pos={10,110},size={195,14},noproc,title="Display Param Notebook?"
		CheckBox NX_CreateNotebookWithInfo,help={"Create Notebook with Parameters from Nexus file?"}
		CheckBox NX_CreateNotebookWithInfo,variable= root:Packages:Irena_Nexus:NX_CreateNotebookWithInfo
		CheckBox NX_ReadParametersOnLoad,pos={10,130},size={195,14},title="Read Params on Import?", proc=Nexus_ConfigPanelCheckProc
		CheckBox NX_ReadParametersOnLoad,help={"When importing NX data, read some parameters from the NX values?"}
		CheckBox NX_ReadParametersOnLoad,variable= root:Packages:Irena_Nexus:NX_ReadParametersOnLoad
		
		TitleBox Info5 title="\Zr140Multi Dimensional Data found",pos={20,160},frame=0,fstyle=1,size={150,20},fColor=(1,4,52428)
		NVAR NX_Index0Max = root:Packages:Irena_Nexus:NX_Index0Max
		NVAR NX_Index1Max = root:Packages:Irena_Nexus:NX_Index1Max
		SVAR NX_Index1ProcessRule = root:Packages:Irena_Nexus:NX_Index1ProcessRule
		SetVariable NX_Index0Max, pos={10,180}, size ={200,18},limits={0,NX_Index0Max,1}, variable=root:Packages:Irena_Nexus:NX_Index0Value
		SetVariable NX_Index0Max, title="0 index value"
		SetVariable NX_Index1Max, pos={10,205}, size ={200,18},limits={0,NX_Index1Max,1}, variable=root:Packages:Irena_Nexus:NX_Index1Value
		SetVariable NX_Index1Max, title="1 index value"
		PopupMenu NX_Index1ProcessRule, pos={250, 205}, size={100,20}, mode=1,  value="One selected;All sequentially;Sum together;", popValue=NX_Index1ProcessRule, proc=NEXUS_PopMenuProc
		//values={0,NX_Index0Max,1}
		//ListOfVariables+=";NX_Index0Max;;NX_Index1Max;"		//note, next two indexes are the image indexes... 

		Button NX_OpenFileInBrowser,pos={200,80},size={190,20},proc=NEXUS_InputPanelButtonProc,title="Open Sel. File in Browser"
		Button NX_OpenFileInBrowser,help={"Check file in HDF5 Browser"}
	
		ListBox NX_LookupTable,pos={5,80},size={390,200}, mode=5, userColumnResize=1, widths={141,182,49}	
		ListBox NX_LookupTable,listWave=root:Packages:Irena_Nexus:ListOfParamsAndPaths
		ListBox NX_LookupTable,selWave=root:Packages:Irena_Nexus:ListOfParamsAndPathsSel
		ListBox NX_LookupTable,proc=NEXUS_ConfigListBox, help={"If needed select which parameters are suppose to be read on load"}
	
		SetVariable NX_GrepStringMask, pos={10,285}, size ={270,18}, variable=root:Packages:Irena_Nexus:GrepStringMask
		SetVariable NX_GrepStringMask, title="Mask Nexus names :"
		
		Button NX_GuessList, pos={290,285}, size={90,15}, title="Guess links", proc=NEXUS_InputPanelButtonProc
		Button NX_GuessList, help={"Set list above based on Nexus NXsas definitions"}
		Button NX_ResetList, pos={290,305}, size={90,15}, title="Reset list", proc=NEXUS_InputPanelButtonProc
		Button NX_ResetList, help={"Reset the list above"}
		//output controls
		Button NX_CreateNXOutputPath, pos={200,335}, size={200,18}, title="Select path for Export", proc=NEXUS_InputPanelButtonProc
		Button NX_CreateNXOutputPath, help={"Find output folder for the Export data."}
	
		SetVariable NX_ShowExportPath, pos={10,360}, size={380,20}, variable=root:Packages:Irena_Nexus:ExportDataFolderName, noedit=1
		SetVariable NX_ShowExportPath, help={"This is where data will be exported"}, title="Path:", disable=2,frame=0
		
		TitleBox Info3 title="\Zr100Processed data Nexus (NXcanSAS) template: InputDataName_Nika.hdf",pos={10,390},frame=0,fstyle=0,size={380,20},fColor=(1,4,52428)
		
		CheckBox NX_SaveToProcNexusFile,pos={10,420},size={195,14},proc=Nexus_ConfigPanelCheckProc,title="Save data in canSAS Nexus file?"
		CheckBox NX_SaveToProcNexusFile,help={"Output data to canSAS Nexus file as selected below. "}
		CheckBox NX_SaveToProcNexusFile,variable= root:Packages:Irena_Nexus:NX_SaveToProcNexusFile
		
		CheckBox NX_Append1DDataToProcNexus,pos={10,445},size={195,14},proc=Nexus_ConfigPanelCheckProc,title="Append processed 1D data to Nexus?"
		CheckBox NX_Append1DDataToProcNexus,help={"Append 2D calibrated and processed data into the Nexus file."}
		CheckBox NX_Append1DDataToProcNexus,variable= root:Packages:Irena_Nexus:NX_Append1DDataToProcNexus
	
		CheckBox NX_Append2DDataToProcNexus,pos={10,470},size={195,14},proc=Nexus_ConfigPanelCheckProc,title="Append processed 2D data to Nexus?"
		CheckBox NX_Append2DDataToProcNexus,help={"Append 2D calibrated and processed data into the Nexus file."}
		CheckBox NX_Append2DDataToProcNexus,variable= root:Packages:Irena_Nexus:NX_Append2DDataToProcNexus

		CheckBox NX_Rebin2DData,pos={25,495},size={195,14},proc=Nexus_ConfigPanelCheckProc,title="Rebin 2D data before appending?"
		CheckBox NX_Rebin2DData,help={"Rebin 2D calibrated and processed data before inserting in the Nexus file."}
		CheckBox NX_Rebin2DData,variable= root:Packages:Irena_Nexus:NX_Rebin2DData

		CheckBox NX_UseQxQyCalib2DData,pos={260,468},size={195,14},proc=Nexus_ConfigPanelCheckProc,title="Use Qx/Qy not |Q|?"
		CheckBox NX_UseQxQyCalib2DData,help={"Use Qx and QY for the 2D data inserted in Nexus."}
		CheckBox NX_UseQxQyCalib2DData,variable= root:Packages:Irena_Nexus:NX_UseQxQyCalib2DData

		SVAR NX_RebinCal2DDtToPnts = root:Packages:Irena_Nexus:NX_RebinCal2DDtToPnts
		PopupMenu NX_RebinCal2DDtToPnts,mode=1,popvalue=NX_RebinCal2DDtToPnts,value= "100x100;200x200;300x300;400x400;600x600;"
		PopupMenu NX_RebinCal2DDtToPnts,pos={260,495},size={214,21},proc=NEXUS_PopMenuProc,title="Rebin to:"
		PopupMenu NX_RebinCal2DDtToPnts,help={"Select Line profile method to use"}
	
		TitleBox Info4 title="\Zr100New RAW Nexus (NXsas) file name template: InputDataName.hdf",pos={10,535},frame=0,fstyle=0,size={380,20},fColor=(1,4,52428)

		CheckBox NX_CreateNewRawNexusFile,pos={10,555},size={195,14},proc=Nexus_ConfigPanelCheckProc,title="Create NEW Nexus file with RAW data? (NXsas data)"
		CheckBox NX_CreateNewRawNexusFile,help={"Create new RAW data (NXsas) Nexus file."}
		CheckBox NX_CreateNewRawNexusFile,variable= root:Packages:Irena_Nexus:NX_CreateNewRawNexusFile

		CheckBox NX_AppendBlankToRawNexus,pos={10,580},size={195,14},proc=Nexus_ConfigPanelCheckProc,title="Append 2D Blank to Nexus?"
		CheckBox NX_AppendBlankToRawNexus,help={"Append Blank data into the Nexus file."}
		CheckBox NX_AppendBlankToRawNexus,variable= root:Packages:Irena_Nexus:NX_AppendBlankToRawNexus
	
		CheckBox NX_AppendMaskToRawNexus,pos={10,605},size={195,14},proc=Nexus_ConfigPanelCheckProc,title="Append 2D Mask to Nexus?"
		CheckBox NX_AppendMaskToRawNexus,help={"Append 2D mask into the Nexus file."}
		CheckBox NX_AppendMaskToRawNexus,variable= root:Packages:Irena_Nexus:NX_AppendMaskToRawNexus

	endif	
	NEXUS_SetMultiDImCOntrols()
End


//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function NEXUS_InputTabProc(name,tab) : TabControl
	String name
	Variable tab

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	TabControl ImportTabs value=tab, win=NEXUS_ConfigurationPanel
	//set here to Tab tab or things go out of whack... 
	NVAR NX_ReadParametersOnLoad = root:Packages:Irena_Nexus:NX_ReadParametersOnLoad
	NVAR InputisNexus=root:Packages:Irena_Nexus:NX_InputFileIsNexus
	
	CheckBox NX_InputFileIsNexus, disable=(tab!=0), win=NEXUS_ConfigurationPanel
	CheckBox NX_CreateNotebookWithInfo, disable=(tab!=0 || !InputisNexus), win=NEXUS_ConfigurationPanel
	CheckBox NX_ReadParametersOnLoad, disable=(tab!=0|| !InputisNexus), win=NEXUS_ConfigurationPanel
	Button NX_OpenFileInBrowser, disable=(tab!=0), win=NEXUS_ConfigurationPanel
	//SetVariable NX_Index0Max, disable=(tab!=0), win=NEXUS_ConfigurationPanel
	//SetVariable NX_Index1Max, disable=(tab!=0), win=NEXUS_ConfigurationPanel
	NEXUS_SetMultiDImCOntrols()

	ListBox NX_LookupTable, disable=(tab!=1 || NX_ReadParametersOnLoad!=1|| !InputisNexus), win=NEXUS_ConfigurationPanel
	SetVariable NX_GrepStringMask, disable=(tab!=1 || NX_ReadParametersOnLoad!=1|| !InputisNexus), win=NEXUS_ConfigurationPanel
	Button NX_ResetList, disable=(tab!=1 || NX_ReadParametersOnLoad!=1|| !InputisNexus), win=NEXUS_ConfigurationPanel
	Button NX_GuessList, disable=(tab!=1 || NX_ReadParametersOnLoad!=1|| !InputisNexus), win=NEXUS_ConfigurationPanel
	
	//lower panel controls can be here also:
	NVAR Append2DData=root:Packages:Irena_Nexus:NX_Append2DDataToProcNexus
	NVAR RebinData=root:Packages:Irena_Nexus:NX_Rebin2DData
	CheckBox NX_Rebin2DData, disable=!Append2DData, win=NEXUS_ConfigurationPanel
	CheckBox NX_UseQxQyCalib2DData, disable=(!Append2DData  || !RebinData), win=NEXUS_ConfigurationPanel
	PopupMenu NX_RebinCal2DDtToPnts, disable=(!Append2DData || !RebinData) , win=NEXUS_ConfigurationPanel

	
	return 0
End

//**************************************************************************************
//**************************************************************************************
Function NEXUS_SetMultiDImCOntrols()
		NVAR NX_Index0Value = root:Packages:Irena_Nexus:NX_Index0Value
		NVAR NX_Index0Max = root:Packages:Irena_Nexus:NX_Index0Max
		NVAR NX_Index1Value = root:Packages:Irena_Nexus:NX_Index1Value
		NVAR NX_Index1Max = root:Packages:Irena_Nexus:NX_Index1Max
		string Newtext
		Newtext = "\\Zr140Multi Dimensional Data found : "
		if(NX_Index1Max>0)
			if(NX_Index0Max>0)
				Newtext += num2str(NX_Index0Max+1)+" x "+num2str(NX_Index1Max+1)+" x 2D Image"
			else
				Newtext += num2str(NX_Index1Max+1)+" x 2D Image"
			endif
		endif
		//update range of the dim display in window 
		DoWIndow NEXUS_ConfigurationPanel
		if(V_Flag)
			ControlInfo/W=NEXUS_ConfigurationPanel ImportTabs			
			SetVariable NX_Index0Max, win=NEXUS_ConfigurationPanel, limits={0,NX_Index0Max,1}, disable=(NX_Index0Max==0||V_Value>0)
			SetVariable NX_Index1Max, win=NEXUS_ConfigurationPanel, limits={0,NX_Index1Max,1}, disable=(NX_Index1Max==0||V_Value>0)
			TitleBox Info5, title=Newtext,  disable=(NX_Index1Max==0||V_Value>0)
			PopupMenu NX_Index1ProcessRule,  disable=(NX_Index1Max==0||V_Value>0)
		endif
end
//**************************************************************************************
//**************************************************************************************

Function NEXUS_ConfigPanelCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR NX_Append2DDataToProcNexus = root:Packages:Irena_Nexus:NX_Append2DDataToProcNexus
	NVAR NX_Append1DDataToProcNexus = root:Packages:Irena_Nexus:NX_Append1DDataToProcNexus
	NVAR NX_InputFileIsNexus = root:Packages:Irena_Nexus:NX_InputFileIsNexus
	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(stringmatch(cba.ctrlName,"NX_InputFileIsNexus"))
				SVAR DataFileExtension=root:Packages:Convert2Dto1D:DataFileExtension
				if(checked)
					if(!StringMatch(DataFileExtension, "Nexus"))
						NX_InputFileIsNexus = 0
						Abort "Input file is NOT Nexus, first select Nexus as import file and then you can use this feature."
					endif
				endif
				NEXUS_InputTabProc("",0)
				Nexus_SetOutputControls()
			endif
			if(stringmatch(cba.ctrlName,"NX_SaveToProcNexusFile"))
				NVAR/Z AppendToNexusFile=root:Packages:Convert2Dto1D:AppendToNexusFile
				if(NVAR_Exists(AppendToNexusFile))
					AppendToNexusFile = cba.checked
				endif
				if(cba.checked)
					if((NX_Append2DDataToProcNexus + NX_Append1DDataToProcNexus)<1)
						NX_Append1DDataToProcNexus = 1
					endif
				endif
				Nexus_SetOutputControls()
			endif
			if(stringmatch(cba.ctrlName,"NX_ReadParametersOnLoad"))
				Wave ListOfParamsAndPaths = root:Packages:Irena_Nexus:ListOfParamsAndPaths
				if(dimsize(ListOfParamsAndPaths,0)<15)
					NEXUS_ResetParamXRef(1)
				endif
				NVAR/Z My9IDRead=root:Packages:Convert2Dto1D:ReadParametersFromEachFile
				if(NVAR_Exists(My9IDRead))
					My9IDRead = cba.checked
				endif
			endif
			if(stringmatch(cba.ctrlName,"NX_CreateNewRawNexusFile"))
				Nexus_SetOutputControls()
			endif
			ControlInfo/W=NEXUS_ConfigurationPanel ImportTabs
			NEXUS_InputTabProc("",V_Value)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//**************************************************************************************
//**************************************************************************************

static Function NEXUS_SetOutputControls()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	NVAR SaveToNexus=root:Packages:Irena_Nexus:NX_SaveToProcNexusFile
	NVAR NX_Append2DDataToProcNexus=root:Packages:Irena_Nexus:NX_Append2DDataToProcNexus
	NVAR InputisNexus=root:Packages:Irena_Nexus:NX_InputFileIsNexus
	NVAR NX_CreateNewRawNexusFile=root:Packages:Irena_Nexus:NX_CreateNewRawNexusFile
	if(!InputisNexus && SaveToNexus)
		print "Warning: To save to existing Nexus file the input file must be also Nexus file."
		NX_CreateNewRawNexusFile=1
	endif

	CheckBox NX_CreateNewRawNexusFile,disable=0, win=NEXUS_ConfigurationPanel
	CheckBox NX_Append2DDataToProcNexus,disable=!SaveToNexus, win=NEXUS_ConfigurationPanel
	CheckBox NX_Rebin2DData,disable=(!SaveToNexus || !NX_Append2DDataToProcNexus ) , win=NEXUS_ConfigurationPanel

	CheckBox NX_Append1DDataToProcNexus,disable=!SaveToNexus, win=NEXUS_ConfigurationPanel
	CheckBox NX_AppendBlankToRawNexus,disable=!NX_CreateNewRawNexusFile, win=NEXUS_ConfigurationPanel
	CheckBox NX_AppendMaskToRawNexus,disable=!NX_CreateNewRawNexusFile, win=NEXUS_ConfigurationPanel
	
	
end

//**************************************************************************************
//**************************************************************************************

Function NEXUS_ConfigListBox(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
					if(!StringMatch(S_selection, "NO match to Mask Nexus names*" ))
						listWave[row][1] = S_selection
					endif
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
static Function/T NEXUS_NXParamSelection(row)
	variable row
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR DataFolderName = root:Packages:Irena_Nexus:DataFolderName
	SVAR GrepStringMask = root:Packages:Irena_Nexus:GrepStringMask
	Wave HDF5___xref = $(DataFolderName+"HDF5___xref")					//list of parameters in the Nexus file
	Wave ListOfParamsAndPaths = root:Packages:Irena_Nexus:ListOfParamsAndPaths	//list of parameters in Nika
	
	string result, SearchTerm
	SearchTerm =""
	variable i
	result = "\\M0::---;"
	Duplicate/FREE/R=[][1]/T HDF5___xref,  UsefulNodes
	Grep/E=GrepStringMask UsefulNodes as UsefulNodes
	for(i=0;i<numpnts(UsefulNodes);i+=1)
		if(strlen(UsefulNodes[i])>5)
			result+=UsefulNodes[i]+";"
		endif	
	endfor
	if(ItemsInList(result,";")<2)
		result+="NO match to Mask Nexus names string;"
	endif
	return result
end
//**************************************************************************************
//**************************************************************************************
Function NEXUS_InputPanelButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlname,"NX_ResetList"))
				//reset the list now... 
				NEXUS_ResetParamXRef(1)
			endif
			if(stringmatch(ba.ctrlname,"NX_GuessList"))
				//guess the list based on standard... 
				NEXUS_GuessParamXRef()
			endif
			if(stringmatch(ba.ctrlname,"NX_OpenFileInBrowser"))
				Nexus_NexusOpenHdf5File()
			endif
			if(stringmatch(ba.ctrlname,"NX_CreateNXOutputPath"))
				//Generate new path for Nexus output... 
				SVAR ExportDataFolderName = root:Packages:Irena_Nexus:ExportDataFolderName
				NewPath /M="Select exiting folder to place Nexus outptu files in" /O/Q Nexus_OutputFilePath
				if(V_Flag==0)
					PathInfo Nexus_OutputFilePath
					ExportDataFolderName = S_Path
				endif
			endif
			
			
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**************************************************************************************
//**************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function Nexus_NexusOpenHdf5File()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Wave/T WaveOfFiles      = root:Packages:Convert2Dto1D:ListOf2DSampleData
	Wave WaveOfSelections = root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers

		//root:Packages:Convert2Dto1D:ListOf2DSampleData,root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers	
	variable NumSelFiles=sum(WaveOfSelections)	
	variable OpenMultipleFiles=0
	if(NumSelFiles==0)
		return 0
	endif
	if(NumSelFiles>1)
		DoAlert /T="Choose what to do:" 2, "You have selected multiple files, do you want to open the first one [Yes], all [No], or cancel?" 
		if(V_Flag==0)
			return 0
		elseif(V_Flag==2)
			OpenMultipleFiles=1
		endif
	endif
	
	variable i
	string FileName
	String browserName
	Variable locFileID
	For(i=0;i<numpnts(WaveOfSelections);i+=1)
		if(WaveOfSelections[i])
			FileName= WaveOfFiles[i]
			CreateNewHDF5Browser()
		 	browserName = WinName(0, 64)
			HDF5OpenFile/R /P=Convert2Dto1DDataPath locFileID as FileName
			if (V_flag == 0)					// Open OK?
				HDf5Browser#UpdateAfterFileCreateOrOpen(0, browserName, locFileID, S_path, S_fileName)
			endif
			if(!OpenMultipleFiles)
				return 0
			endif
		endif
	endfor
	//HDf5Browser#LoadGroupButtonProc("LoadGroup")
	
	//HDf5Browser#CloseFileButtonProc("CloseFIle")
	
	//KillWindow $(browserName)
end

//************************************************************************************************************
//************************************************************************************************************//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
// 		Nexus_2DDataReader - copies functionality of the old NI2NX_NexusReader to function as replacement. 
//*****************************************************************************************************************
//*****************************************************************************************************************


Function NEXUS_NexusNXsasDataReader(FilePathName,Filename)
		string FilePathName,Filename
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		
		string OldDf=getDataFolder(1)
		//check if the file was recently imported... SKip to save time. 
		string PathToOldData = "root:Packages:NexusImportTMP:"+possiblyQuoteName(stringFromList(0,Filename,"."))
		string PathToNewData
		if(!DataFolderExists(PathToOldData))
		 	PathToNewData= NEXUS_ImportAFile(FilePathName,Filename)		//this will import data file. "" if failed
			if(strlen(PathToNewData)<1)
				Abort "Import of the data failed"
			else
				PathToNewData+=":"						//needs ending ":" and it is not there...
			endif
		else
			PathToNewData = PathToOldData+":"
		endif
		SVAR DataFolderName = root:Packages:Irena_Nexus:DataFolderName
		DataFolderName = PathToNewData
		string AllNXData
		AllNXData = NEXUS_FindNXdataClassData(PathToNewData, "NX_class=NXdata")		//find path to all NXdata, but this can be 2D, 1D, 3D, or 4D data sets. 
		//note: 3D and 4D data which are degenerate (some dimensions have 1 element) will be collapsed by this function to 2D data
		string NX2Ddata=""
		string tmpPath
		variable i
		For(i=0;i<itemsInList(AllNXData);i+=1)
			tmpPath = stringfromlist(i,AllNXData)
			NX2Ddata+=NEXUS_IdentifyNxData(tmpPath, 2)
			NX2Ddata+=NEXUS_IdentifyNxData(tmpPath, 3)
			NX2Ddata+=NEXUS_IdentifyNxData(tmpPath, 4)
		endfor
		if(ItemsInList(NX2Ddata)>1 || ItemsInList(NX2Ddata)<1)
			Abort "More or less than 1 2D data set found, cannot handle this for now, stopping"
		endif
		Wave DataWave = $(stringfromlist(0,NX2Ddata))			//just to make sure, pick the first one here (removes ending ;)
		//now, 6-2017 this may be up to 4D wave, so now we need to handle this...
		NVAR NX_Index0Value = root:Packages:Irena_Nexus:NX_Index0Value
		NVAR NX_Index0Max = root:Packages:Irena_Nexus:NX_Index0Max
		NVAR NX_Index1Value = root:Packages:Irena_Nexus:NX_Index1Value
		NVAR NX_Index1Max = root:Packages:Irena_Nexus:NX_Index1Max
		if(WaveDims(DataWave) == 2)		//usual, 1 image in file, nothing new to handle here...
			NX_Index0Value = 0
			NX_Index0Max = 0
			NX_Index1Value = 0
			NX_Index1Max = 0
			Duplicate/O DataWave, $("root:Packages:Convert2Dto1D:Loadedwave0")
		elseif(WaveDims(DataWave) == 3)		//this is 3D wave
			NX_Index0Value = 0
			NX_Index0Max = 0
			NX_Index1Max = dimsize(DataWave,0)
			if(NX_Index1Value>NX_Index1Max)
				NX_Index1Value = 0
			endif
			make/Free/N=(dimsize(DataWave,1),dimsize(DataWave,2)) My2DImg
			My2DImg = DataWave[NX_Index1Value][p][q]
			Duplicate/O My2DImg, $("root:Packages:Convert2Dto1D:Loadedwave0")
			//MatrixOp/Free My2DImg = layer(DataWave,NX_Index1Value)	
			//Duplicate/O My2DImg, $("root:Packages:Convert2Dto1D:Loadedwave0")
			//Redimension/N=(dimsize(DataWv,1),dimsize(DataWv,2)) DataWv
		elseif(WaveDims(DataWave) == 4)		//this is 3D wave
			NX_Index0Max = dimsize(DataWave,0)-1
			if(NX_Index0Value>NX_Index0Max)
				NX_Index0Value = 0
			endif
			NX_Index1Max = dimsize(DataWave,1)-1
			if(NX_Index1Value>NX_Index1Max)
				NX_Index1Value = 0
			endif
			make/Free/N=(dimsize(DataWave,2),dimsize(DataWave,3)) My2DImg
			My2DImg = DataWave[NX_Index0Value][NX_Index1Value][p][q]
			//Redimension/N=(dimsize(My2DImg,2),dimsize(My2DImg,3)) My2DImg
			Duplicate/O My2DImg, $("root:Packages:Convert2Dto1D:Loadedwave0")
			//MatrixOp/Free My2DImg = layer(DataWave,NX_Index1Value)	
			//Duplicate/O My2DImg, $("root:Packages:Convert2Dto1D:Loadedwave0")
			//Redimension/N=(dimsize(DataWv,1),dimsize(DataWv,2)) DataWv
		else
			print "We should never get here"
			print "Error in NEXUS_NexusNXsasDataReader"
		endif
		Wave DataWv=$("root:Packages:Convert2Dto1D:Loadedwave0")	
		NEXUS_SetMultiDImCOntrols()	
		NEXUS_CleanUpHDF5Structure(DataWv, PathToNewData)
		NEXUS_CreateWvNtNbk(DataWv, Filename)
		NEXUS_ReadNXparameters(PathToNewData)
		SetDataFolder OldDF
End

//*****************************************************************************************************************
//*****************************************************************************************************************
static Function NEXUS_ReadNXparameters(PathToNewData)
		string PathToNewData
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
						if(stringmatch(NikaParameterStr,"SampleName"))
							NikaParameterStr = ""
						endif
					elseif(stringMatch(ImageBeingLoaded,"Dark"))
						if(stringmatch(NikaParameterStr,"SampleI0"))
							skipLoading= 1
						endif
						if(stringmatch(NikaParameterStr,"SampleMeasurementTime"))
							NikaParameterStr = "BackgroundMeasTime"
						endif
						if(stringmatch(NikaParameterStr,"SampleName"))
							NikaParameterStr = ""
						endif
					endif
					NexusPathStr = ListOfParamsAndPaths[i][1]
					ScaleFctVal = str2num(ListOfParamsAndPaths[i][2])
					Wave/Z NexParWv = $(removeending(PathToNewData,":")+NexusPathStr)
					if(WaveExists(NexParWv)&&!skipLoading && strlen(NikaParameterStr)>0)			//there is valid pointer to the data.
						NVAR/Z NikaPar = $(NikaParameterStr)
						if(NVAR_Exists(NikaPar))
							NikaPar = ScaleFctVal * NexParWv[0]
							print "Read Nexus parameter "+NexusPathStr+", scaled by "+num2str(ScaleFctVal)+" and set "+NikaParameterStr+" = "+num2str(NikaPar)
						else //may be string?
							SVAR NikaParS = $(NikaParameterStr)
							if(SVAR_Exists(NikaParS))
								Wave/Z/T NexParWvS = $(removeending(PathToNewData,":")+NexusPathStr)
								NikaParS = NexParWvS[0]
								print "Read Nexus parameter "+NexusPathStr+",  and set "+NikaParameterStr+" = "+(NikaParS)
							endif
						endif
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
static Function/T NEXUS_ImportAFile(FilePathName,Filename)		//imports any Nexus (HDF5) file and returns path to it. 
		string FilePathName,Filename

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NEXUS_Initialize(0)
	KilLDatafolder/Z root:Packages:NexusImportTMP
	NewDataFolder/O root:Packages:NexusImportTMP
	string Status
	//import the file
	Status = H5GW_ReadHDF5(FilePathName, "root:Packages:NexusImportTMP", Filename)
	if(strlen(Status)>0)
		print "HDF5 import failed, message: "+Status		//if not "" then error ocured, Handle somehow!
		return ""
	endif
	Filename = stringfromlist(0, Filename, ".")		//new folder name.  Will fail if there are more . in the name!
	string NewDataPath = "root:Packages:NexusImportTMP:"+PossiblyQuoteName(Filename)		//this should be where the file is.
	return NewDataPath
end
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function NEXUS_CreateWvNtNbk(WaveWithWaveNote, SampleName)
	wave WaveWithWaveNote
	string SampleName
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
			NVAR NX_Index0Value = root:Packages:Irena_Nexus:NX_Index0Value
			NVAR NX_Index0Max = root:Packages:Irena_Nexus:NX_Index0Max
			NVAR NX_Index1Value = root:Packages:Irena_Nexus:NX_Index1Value
			NVAR NX_Index1Max = root:Packages:Irena_Nexus:NX_Index1Max
			if(NX_Index1Max>0)			//at least 3D data
				if(NX_Index0Max>0)		//4D data
					Notebook $nb text="This is multidimensions Nexus file"
					Notebook $nb text="Input data are 4D, loaded image has indexes : "+Num2Str(NX_Index0Value)+"  and "+num2str(NX_Index1Value)
				else
					Notebook $nb text="This is multidimensions Nexus file"
					Notebook $nb text="Input data are 3D, loaded image has index : "+num2str(NX_Index1Value)
				endif
			endif
			
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
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string StartDf
	//StartDf = Fldrname+"entry:"
	StartDf = stringFromList(0,NEXUS_FindNXClassData(Fldrname, "NXentry"))
	if(strlen(StartDf)<1)
		StartDf = Fldrname+"entry:"
	endif
	string PathToStrVarValues = "root:Packages:NexusImportTMP:"
	string/g $(PathToStrVarValues+"ListOfStrValues")
	string/g $(PathToStrVarValues+"ListOfNumValues")
	SVAR tmpStr=$(PathToStrVarValues+"ListOfStrValues")
	tmpStr=""
	SVAR tmpStr=$(PathToStrVarValues+"ListOfNumValues")
	tmpStr=""
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

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string Newkey=GetDataFolder(1)[strlen(StartFolderStr),inf]
	string ListOfTXTWaves=WaveList("*", ";", "TEXT:1" )
   SVAR/Z ListOfStrValues = $(Fldrname+"ListOfStrValues")
//	if(!SVAR_Exists(ListOfStrValues))
//		string/g $(Fldrname+"ListOfStrValues")
//		SVAR/Z ListOfStrValues = $(Fldrname+"ListOfStrValues")
//	endif
	variable i
	NVAR NX_Index0Value = root:Packages:Irena_Nexus:NX_Index0Value
	NVAR NX_Index0Max = root:Packages:Irena_Nexus:NX_Index0Max
	NVAR NX_Index1Value = root:Packages:Irena_Nexus:NX_Index1Value
	NVAR NX_Index1Max = root:Packages:Irena_Nexus:NX_Index1Max
	for(i=0;i<ItemsInList(ListOfTXTWaves,";");i+=1)
		ListOfStrValues+=Newkey+StringFromList(i, ListOfTXTWaves  , ";")+"="
		Wave/T tempWv=$(StringFromList(i, ListOfTXTWaves  , ";"))
		//modify for multidimensional input data...
		if(WaveDims(tempWv)==1)//this is usual thing - it is scalar, one value for all... or just one dimension (vector)
			if(dimsize(tempWv,0)==1)		//one value for all..
				ListOfStrValues+=tempWv[0]+";"
			elseif(dimsize(tempWv,0)==NX_Index0Max+1)		//this is per Index 0
				ListOfStrValues+=tempWv[NX_Index0Value]+";"
			elseif(dimsize(tempWv,0)==NX_Index1Max+1)		//this is per Index 1
				ListOfStrValues+=tempWv[NX_Index1Value]+";"
			else
				//what is here???
				print "We should neverget here - NEXUS_ConvertTxTwvToStringList - 1..."
			endif
		elseif(WaveDims(tempWv)==2)//this is for multidim data (4D) with two indexes. This should be indexed as 2D data...
			ListOfStrValues+=tempWv[NX_Index0Value][NX_Index1Value]+";"
		else
			//what is here???
			print "We should neverget here - NEXUS_ConvertTxTwvToStringList - 2..."
		endif
	endfor
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NEXUS_ConvertNumWvToStringList(StartFolderStr, Fldrname)
	string  StartFolderStr, Fldrname
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//SVAR StartFolderStr=root:Packages:NexusImportTMP:StartFolderStr
	NVAR NX_Index0Value = root:Packages:Irena_Nexus:NX_Index0Value
	NVAR NX_Index0Max = root:Packages:Irena_Nexus:NX_Index0Max
	NVAR NX_Index1Value = root:Packages:Irena_Nexus:NX_Index1Value
	NVAR NX_Index1Max = root:Packages:Irena_Nexus:NX_Index1Max
	string Newkey=GetDataFolder(1)[strlen(StartFolderStr),inf]
	string ListOfNumWaves=WaveList("*", ";", "TEXT:0,DIMS:1" )
	//depends on dimensionality...
	if(NX_Index1Max>0)	//at least 3D input  data
		ListOfNumWaves+=WaveList("*", ";", "TEXT:0,DIMS:2" )
		if(NX_Index0Max>0)	//4D data
			ListOfNumWaves+=WaveList("*", ";", "TEXT:0,DIMS:3" )
		endif
	endif
   SVAR/Z ListOfNumValues = $(Fldrname+"ListOfNumValues")
//	if(!SVAR_Exists(ListOfNumValues))
//		string/g $(Fldrname+"ListOfNumValues")
//		SVAR/Z ListOfNumValues = $(Fldrname+"ListOfNumValues")
//	endif
	variable i
	for(i=0;i<ItemsInList(ListOfNumWaves,";");i+=1)
		ListOfNumValues+=Newkey+StringFromList(i, ListOfNumWaves  , ";")+"="
		Wave tempWv=$(StringFromList(i, ListOfNumWaves  , ";"))
		//modify for multidimensional input data...
		if(WaveDims(tempWv)==1)//this is usual thing - it is scalar, one value for all... or just one dimension (vector)
			if(dimsize(tempWv,0)==1)		//one value for all..
				ListOfNumValues+=num2str(tempWv[0])+";"
			elseif(dimsize(tempWv,0)==NX_Index0Max+1)		//this is per Index 0
				ListOfNumValues+=num2str(tempWv[NX_Index0Value])+";"
			elseif(dimsize(tempWv,0)==NX_Index1Max+1)		//this is per Index 1
				ListOfNumValues+=num2str(tempWv[NX_Index1Value])+";"
			else
				//This looks like data or something else... Ignore. 
				//print "We should neverget here... NEXUS_ConvertNumWvToStringList - 1"
			endif
		elseif(WaveDims(tempWv)==2)//this is for multidim data (4D) with two indexes. This should be indexed as 2D data...
			ListOfNumValues+=num2str(tempWv[NX_Index0Value][NX_Index1Value])+";"
		else
			//what is here???
			print "We should neverget here... NEXUS_ConvertNumWvToStringList - 2"
		endif
	endfor
end

//*****************************************************************************************************************
//*****************************************************************************************************************
static Function/T NEXUS_FindNXdataClassData(DataPathStr, NXClassStr)
	string DataPathStr, NXClassStr
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
static Function/T NEXUS_IdentifyNxData(PathToData, dimensions)
	string PathToData
	variable dimensions
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
static Function/S NEXUS_FindAnySignalData()
	//check each wave in current folder and selects the first one which has 2D data in it
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
		if(WaveDims(TestWv) == 2 || WaveDims(TestWv) == 3 || WaveDims(TestWv) ==4 )
			//6-2017 added ability to handel higher dimensions, up to 4 dimensions allowed by standard
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
	//e.g., 	WhichNXClass = "NX_class=NXdata;canSAS_class=SASdata;"	- must match the Nexus spelling/format
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR FoundClassDataLocation = root:Packages:Irena_Nexus:FoundClassDataLocation
	Wave/Z Igor___folder_attributes
	string tmpnote, tmpClass
	variable i, matches=1
	if(WaveExists(Igor___folder_attributes))
		tmpnote = note(Igor___folder_attributes)
//		if(GrepString(tmpnote, "NX_class="+WhichNXClass))
//		endif
		for(i=0;i<ItemsInList(WhichNXClass);i+=1)
			tmpClass = stringFromList(i,WhichNXClass)
			if(!GrepString(tmpnote,tmpClass))
				matches*=0
			endif
		endfor
	endif
	if(matches)
		FoundClassDataLocation+=GetDataFolder(1)+";"
	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function NEXUS_Initialize(enforceReset)
	variable enforceReset
	//function, which creates the folder and creates the strings and variables
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string oldDf=GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewdataFolder/O/S root:Packages:Irena_Nexus	
	string ListOfVariables
	string ListOfStrings
	
	//here define the lists of variables and strings needed, separate names by ;...
	//read part
	ListOfVariables="NX_InputFileIsNexus;NX_CreateNotebookWithInfo;NX_ReadParametersOnLoad;"
	//write part
	ListOfVariables+="NX_SaveToProcNexusFile;NX_CreateNewRawNexusFile;NX_Append2DDataToProcNexus;NX_Append1DDataToProcNexus;"
	ListOfVariables+="NX_AppendBlankToRawNexus;NX_AppendMaskToRawNexus;NX_Rebin2DData;NX_UseQxQyCalib2DData;"
	ListOfVariables+="NX_Index0Value;NX_Index0Max;NX_Index1Value;NX_Index1Max;"		//note, next two indexes are the image indexes... 
	//read part	
	ListOfStrings="DataFolderName;GrepStringMask;NX_RebinCal2DDtToPnts;NX_Index1ProcessRule;"
	//write part
	ListOfStrings+="ExportDataFolderName;"
	//Nika cross referecne
	ListOfStrings+="NikaParamsNames;"
	
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	SVAR NX_RebinCal2DDtToPnts
	if(strlen(NX_RebinCal2DDtToPnts)<1)
		NX_RebinCal2DDtToPnts="100x100"
	endif
	
	wave/Z/T ListOfParamsAndPaths 
	WAVE/Z ListOfParamsAndPathsSel
	if(!WaveExists(ListOfParamsAndPathsSel) || !WaveExists(ListOfParamsAndPaths)|| enforceReset)	
		NEXUS_ResetParamXRef(enforceReset)
	endif
	//these are old Nexus support variables in Nika. Need to sync these if they exist and set them to 0 so old code does not complain. 
	//2DCalibratedDataInput & output
	//ListOfVariables+="ExpCalib2DData;RebinCalib2DData;InclMaskCalib2DData;UseQxyCalib2DData;ReverseBinnedData;AppendToNexusFile;"
	//	SVAR RebinCalib2DDataToPnts=root:Packages:Convert2Dto1D:RebinCalib2DDataToPnts
	// SVAR Calib2DDataOutputFormat =root:Packages:Convert2Dto1D:Calib2DDataOutputFormat
	SVAR NikaParamsNames
	NikaParamsNames="UserSampleName;SampleThickness;SampleTransmission;SampleI0;"
	NikaParamsNames+="SampleMeasurementTime;"
	NikaParamsNames+="SampleToCCDDistance;Wavelength;XrayEnergy;BeamCenterX;BeamCenterY;"
	NikaParamsNames+="BeamSizeX;BeamSizeY;PixelSizeX;PixelSizeY;HorizontalTilt;VerticalTilt;"
	NikaParamsNames+="CorrectionFactor;"
	//removed Blank and empty values here: EmptyI0;BackgroundMeasTime;EmptyMeasurementTime;
	
	SVAR/Z RebinCalib2DDataToPnts=root:Packages:Convert2Dto1D:RebinCalib2DDataToPnts
	if(SVAR_Exists(RebinCalib2DDataToPnts))
		if(!StringMatch(RebinCalib2DDataToPnts, "100x100" ))
			SVAR NX_RebinCal2DDtToPnts 
			NX_RebinCal2DDtToPnts = RebinCalib2DDataToPnts
			RebinCalib2DDataToPnts = "100x100"
		endif
	endif
	
	SVAR NX_Index1ProcessRule
	if(!StringMatch(NX_Index1ProcessRule, "One selected") && !Stringmatch(NX_Index1ProcessRule,"All sequentially") && !Stringmatch(NX_Index1ProcessRule,"Sum together") )
		NX_Index1ProcessRule="One selected"
	endif

	NVAR/Z UseQxyCalib2DData=root:Packages:Convert2Dto1D:UseQxyCalib2DData
	if(NVAR_Exists(UseQxyCalib2DData))
		if(UseQxyCalib2DData==1)
			NVAR NX_UseQxQyCalib2DData 
			NX_UseQxQyCalib2DData = UseQxyCalib2DData
			UseQxyCalib2DData = 0
		endif
	endif
	NVAR/Z AppendToNexusFile=root:Packages:Convert2Dto1D:AppendToNexusFile
	if(NVAR_Exists(AppendToNexusFile))
		if(AppendToNexusFile==1)
			NVAR NX_Append2DDataToProcNexus 
			NX_Append2DDataToProcNexus = AppendToNexusFile
			AppendToNexusFile = 0
		endif
	endif
	NVAR/Z InclMaskCalib2DData=root:Packages:Convert2Dto1D:InclMaskCalib2DData
	if(NVAR_Exists(InclMaskCalib2DData))
		if(InclMaskCalib2DData==1)
			NVAR NX_AppendMaskToRawNexus 
			NX_AppendMaskToRawNexus = InclMaskCalib2DData
			InclMaskCalib2DData = 0
		endif
	endif
	NVAR/Z ExpCalib2DData=root:Packages:Convert2Dto1D:ExpCalib2DData
	if(NVAR_Exists(ExpCalib2DData))
		if(ExpCalib2DData==1)
			NVAR NX_SaveToProcNexusFile 
			NX_SaveToProcNexusFile = ExpCalib2DData
			ExpCalib2DData = 0
		endif
	endif
	NVAR/Z RebinCalib2DData=root:Packages:Convert2Dto1D:RebinCalib2DData
	if(NVAR_Exists(RebinCalib2DData))
		if(RebinCalib2DData==1)
			NVAR NX_Rebin2DData 
			NX_Rebin2DData = RebinCalib2DData
			RebinCalib2DData = 0
		endif
	endif
	//and amke sure the naming is automatic and as needed...	
	NVAR/Z Use2DdataName=root:Packages:Convert2Dto1D:Use2DdataName
	NVAR/Z UseSampleNameFnct=root:Packages:Convert2Dto1D:UseSampleNameFnct
	if(NVAR_Exists(Use2DdataName))
		if((Use2DdataName+UseSampleNameFnct)!=1)
			Use2DdataName = 1
			UseSampleNameFnct=0
		endif
	endif
	setDataFolder OldDF							
end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function NEXUS_ResetParamXRef(enforce)
	variable enforce
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena_Nexus
	SVAR ParamsNames=root:Packages:Irena_Nexus:NikaParamsNames
	variable i
	
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
//*************************************************************************************************

Function NEXUS_GuessParamXRef()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena_Nexus
	SVAR ParamsNames=root:Packages:Irena_Nexus:NikaParamsNames
	variable i
//	SVAR NikaParamsNames
//	NikaParamsNames="UserSampleName;SampleThickness;SampleTransmission;SampleI0;"
//	NikaParamsNames+="SampleMeasurementTime;"
//	NikaParamsNames+="SampleToCCDDistance;Wavelength;XrayEnergy;BeamCenterX;BeamCenterY;"
//	NikaParamsNames+="BeamSizeX;BeamSizeY;PixelSizeX;PixelSizeY;HorizontalTilt;VerticalTilt;"
//	NikaParamsNames+="CorrectionFactor;"
	SVAR DataFolderName = root:Packages:Irena_Nexus:DataFolderName
	Wave/T HDF5___xref = $(DataFolderName+"HDF5___xref")					//list of parameters in the Nexus file
	Wave/T ListOfParamsAndPaths = root:Packages:Irena_Nexus:ListOfParamsAndPaths	//list of parameters in Nika
	WAVE/Z ListOfParamsAndPathsSel= root:Packages:Irena_Nexus:ListOfParamsAndPathsSel
	String LookUpList=""
	LookUpList+="UserSampleName=:entry:title;"//UserSampleName=entry:sample:name;" 
	LookUpList+="SampleThickness=:entry:sample:thickness;"
	LookUpList+="SampleTransmission=:entry:sample:transmission;"
	LookUpList+="SampleI0=:entry:control:integral;"
	LookUpList+="SampleMeasurementTime=:entry:control:preset;"
	LookUpList+="SampleToCCDDistance=:entry:instrument:detector:distance;"
	LookUpList+="Wavelength=:entry:instrument:monochromator:wavelength;"// [A]
	LookUpList+="XrayEnergy=:entry:instrument:monochromator:energy;"// or :entry:instrument:monochromator:energy  [keV]
	LookUpList+="BeamCenterX=pin_ccd_center_x_pixel;"	
	LookUpList+="BeamCenterY=pin_ccd_center_y_pixel;"
	LookUpList+="BeamSizeX=:entry:instrument:collimator:geometry:shape:xsize;"
	LookUpList+="BeamSizeY=:entry:instrument:collimator:geometry:shape:ysize;"
	LookUpList+="PixelSizeX=:entry:instrument:detector:x_pixel_size;"
	LookUpList+="PixelSizeY=:entry:instrument:detector:y_pixel_size;"
	LookUpList+="HorizontalTilt=:pin_ccd_tilt_x;"
	LookUpList+="VerticalTilt=:pin_ccd_tilt_y;"
//	CorrectionFactor
	make/Free/T/N=1 ResultsWv
	make/Free/T/N=(dimsize(HDF5___xref,0)) ListOfFOundPaths
	ListOfFOundPaths = HDF5___xref[p][1]
	string tempPath, SearchedParam
	For(i=0;i<dimsize(ListOfParamsAndPaths,0);i+=1)
		SearchedParam = ListOfParamsAndPaths[i][0]
		tempPath = StringByKey(SearchedParam, LookUpList, "=" , ";")
		grep/e=tempPath ListOfFOundPaths as ResultsWv
		if(strlen(ResultsWv[0])>3)
			ListOfParamsAndPaths[i][1] = ResultsWv[0]
		endif
	endfor
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
// write out Nexus/CanSAS file for Nika, Irena or Indra
Function NEXUS_WriteNx1DCanSASNika(SampleName, Iwv, dIwv, Qwv, dQwv, AppendToNameString, NoteData)
		String SampleName, AppendToNameString, NoteData
		wave Iwv, dIwv, Qwv, dQwv
		
		string Writer = "Nika"
		
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		NVAR NX_SaveToProcNexusFile=root:Packages:Irena_Nexus:NX_SaveToProcNexusFile
		if(NX_SaveToProcNexusFile!=1)
			return 0
		endif
				
		//this needs to change as I now need to store 1D data there... 
		//Writes Nexus/CanSAS data based on proposed format:
		// to this structure (NX_class attribute MUST name a NeXus base class)
		//
		///sasentry01							<-- HDF5 group
		//  @NX_class = "NXentry"			<-- NeXus requires this
		//  @canSAS_class = "SASentry"		<-- this is between you and me, for now. Perhaps optional?
		//
		//  /sasdata01						<-- HDF5 group
		//    @NX_class = "NXdata"			<-- NeXus requires this
		//    @canSAS_class = "SASdata"		<-- this is between you and me, for now.
		//    @canSAS_version = "0.1"		<-- this is between you and me, for now.
		//	 	@I_axes = "Q,Q"				<-- canSAS 2012 agreed model
		//	 	@Q_indices = "0,1"			<-- canSAS 2012 agreed model
		//	 	@Mask_indices = "0,1"			<-- canSAS 2012 agreed model
		//
		//	 I: float[M,N]					<-- HDF5 dataset, the intensity array
		//	    @uncertainty="Idev"		<-- canSAS 2012 agreed model
		//	    @signal=1					<-- NeXus requires this
		//		   @axes="Q"					<-- NeXus suggests this is identified
		//	 Idev: float[M,N]				<-- HDF5 dataset, the intensity array <<<<optional
		//	 Q: float[M,N]					<-- HDF5 dataset, |Q| at each pixel  <<<<optional
		//or
		//	 	@I_axes = "Qx,Qy"				<-- canSAS 2012 agreed model
		//	Qx: float[M,N]   <-- Qx at each pixel
		//	Qy: float[M,N]   <-- Qy at each pixel
		//	Qz: float[M,N]   <-- Qz at each pixel (might be all zero)
		
		////		Q :
		////  @units: (required) NX_CHAR
		////    Engineering units to use when expressing Q and related terms.
		////            
		////    Data expressed in other units might be ignored by some software packages.
		////
		////    choices:
		////       1/m
		////       1/nm  (preferred)
		////       1/angstrom
		////
		////I:
		////  @units: (required) NX_CHAR
		////    Engineering units to use when expressing intensity and related terms.
		////            
		////    Data expressed in other units will be treated as "arbitrary" by some software packages.
		////
		////    choices:
		////       1/m  (includes m2/m3 and 1/m/sr)
		////       1/cm  (includes cm2/cm3 and 1/cm/sr)
		////       m2/g
		////       cm2/g
		////       arbitrary (includes "counts" and any unrecognized units)

		
	//to do - change where the data go and how they go there. Find way to indicate what type of sector it is etc. 
//note: SampleName now has no orientation, add curOrient to make sensible... 
	variable GroupID
	Variable fileID, result
	string Hdf5FileName=NEXUS_NikaCreateOrLocNexusFile(2)
	GetFileFolderInfo  /Q /Z Hdf5FileName
	if(V_Flag==0)		//file found	
		HDF5OpenFile /Z fileID as Hdf5FileName
		if (V_flag != 0)
			Print "HDF5 OpenFile failed"
			return -1
		endif
	else
		print "Output Nexus canSAS data file does not exist, creating it"
		HDF5CreateFile /O /Z fileID as Hdf5FileName
		if (V_flag != 0)
			Print "HDF5CreateFile failed"
			return -1
		endif
	endif
	//NEXUS_HdfSaveAttrib("default","sasentry-1","/", fileID) - this makes no sense for me...
	//create sample group	
	//NXentry aka SASentry group here... 
	string RootGroupName=Nexus_FixNxGroupName(SampleName)
	string ViewName=""
	if(strlen(AppendToNameString)>0)	//this is needed for Nika or when something is needed to be added.
		if(StringMatch(Writer, "Nika"))
			ViewName=Nexus_FixNxGroupName("1D"+"_"+AppendToNameString)
		else
			ViewName=Nexus_FixNxGroupName("_"+AppendToNameString)
		endif
	else
		ViewName=""
	endif
	string NewGroupName
	NEXUS_HdfSaveAttrib("creator",Writer,"/", fileID)
	if(StringMatch(Writer, "Nika"))
		NEXUS_HdfSaveAttrib("url","http://usaxs.xray.aps.anl.gov/staff/ilavsky/nika.html","/", fileID)
	elseif(StringMatch(Writer, "Irena"))
		NEXUS_HdfSaveAttrib("url","http://usaxs.xray.aps.anl.gov/staff/ilavsky/irena.html","/", fileID)
	elseif(StringMatch(Writer, "Indra"))
		NEXUS_HdfSaveAttrib("url","http://usaxs.xray.aps.anl.gov/staff/ilavsky/Indra_2.html","/", fileID)	
	else
		NEXUS_HdfSaveAttrib("url","http://usaxs.xray.aps.anl.gov/staff/ilavsky/irena.html","/", fileID)		
	endif
	NEXUS_HdfSaveAttrib( "default",RootGroupName,"/", fileID)
	RootGroupName="/"+RootGroupName
	HDF5CreateGroup fileID , RootGroupName , groupID		//this is NXentry group containinng possibly many "views" on sample
	RootGroupName=RootGroupName+"/"
	//its attributes
	NEXUS_HdfSaveAttrib("NX_class","NXentry",RootGroupName, fileID)
	NEXUS_HdfSaveAttrib( "canSAS_class","SASentry",RootGroupName, fileID)
	NEXUS_HdfSaveAttrib( "canSAS_name",SampleName,RootGroupName, fileID)
	NEXUS_HdfSaveAttrib( "version","1.0",RootGroupName, fileID)
	NEXUS_HdfSaveAttrib( "default",ViewName,RootGroupName, fileID, DoNotOverwrite=1)
	//required items in here... 
	NEXUS_HdfSaveData("definition","NXcanSAS",RootGroupName, fileID)
	NEXUS_HdfSaveData("title",SampleName,RootGroupName, fileID)
	NEXUS_HdfSaveData("run"," ",RootGroupName, fileID)
	//now NXdata group
	NewGroupName = RootGroupName+ViewName
	HDF5CreateGroup fileID , NewGroupName , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXdata",NewGroupName, fileID)
	NEXUS_HdfSaveAttrib("canSAS_class","SASdata",NewGroupName, fileID)
	NEXUS_HdfSaveAttrib("canSAS_version","1.0",NewGroupName, fileID)
	NEXUS_HdfSaveAttrib( "canSAS_name",SampleName,NewGroupName, fileID)
	NEXUS_HdfSaveAttrib("I_axes","Q",NewGroupName, fileID)
	NEXUS_HdfSaveAttrib("signal","I",NewGroupName, fileID)
	NEXUS_HdfSaveAttrib("I_uncertainties","Idev",NewGroupName, fileID)
	NEXUS_HdfSaveAttrib("Q_indices","0",NewGroupName, fileID)
	// Save I wave as dataset
	string Inote=note(Iwv)
	HDF5SaveData /O /Z /GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1} Iwv, fileID, NewGroupName+"/I"
	NEXUS_HdfSaveAttrib("uncertainties","Idev",NewGroupName+"/I", fileID)
	NEXUS_HdfSaveAttrib("units","1/cm",NewGroupName+"/I", fileID)
	//store out note in the same place as I is?
	NEXUS_WriteWaveNote(fileID,NewGroupName,Inote)
	//Now deal with Q axes...
	//NEXUS_HdfSaveAttrib("axes","Q",NewGroupName+"/sasdata01/I", fileID)
	//convert to 1/nm and use that, Nexus preferred units
	Duplicate/Free Qwv, Qwvnm
	Qwvnm = Qwvnm*10
	HDF5SaveData /O /Z/GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1}   Qwvnm , fileID, NewGroupName+"/Q"
	NEXUS_HdfSaveAttrib("units","1/nm",NewGroupName+"/Q", fileID)
	NEXUS_HdfSaveAttrib("resolutions","Qdev",NewGroupName+"/Q", fileID)
	//Now deal with Uncertainty
	//NEXUS_HdfSaveAttrib("uncertainty","Idev",NewGroupName+"/sasdata01/I", fileID)
	HDF5SaveData /O /Z/GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1}   dIwv, fileID, NewGroupName+"/Idev"
	//NEXUS_HdfSaveAttrib("axes","Q",NewGroupName+"/sasdata01/Idev", fileID)
	NEXUS_HdfSaveAttrib("units","1/cm",NewGroupName+"/Idev", fileID)
	//Now Qres.   dQwv
	Duplicate/Free dQwv, dQwvnm
	dQwvnm = dQwvnm*10
	HDF5SaveData /O /Z/GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1}   dQwvnm, fileID, NewGroupName+"/Qdev"
	NEXUS_HdfSaveAttrib("units","1/nm",NewGroupName+"/Qdev", fileID)
	
	//add instrument data...
	string InstrumentPathStr=RootGroupName+"/"+"instrument"
	string tmpPath
	HDF5CreateGroup fileID , InstrumentPathStr , groupID		//this is NXentry group containinng instrument description
	NEXUS_HdfSaveAttrib("NX_class","NXinstrument",InstrumentPathStr, fileID)
	NEXUS_HdfSaveAttrib("canSAS_class","SASinstrument",InstrumentPathStr, fileID)
	InstrumentPathStr=InstrumentPathStr+"/"

	tmpPath = InstrumentPathStr+"source"
	HDF5CreateGroup fileID , tmpPath , groupID		//this is NXentry group containinng instrument description
	NEXUS_HdfSaveAttrib("NX_class","NXsource",tmpPath, fileID)
	tmpPath=tmpPath+"/"
	NVAR WV = root:Packages:Convert2Dto1D:Wavelength
	NEXUS_HdfSaveDataVar("incident_wavelength",(Wv),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","angstrom",tmpPath+"incident_wavelength", fileID)
	NVAR Bsx = root:Packages:Convert2Dto1D:BeamSizeX
	NVAR BsY = root:Packages:Convert2Dto1D:BeamSizeY
	NEXUS_HdfSaveDataVar("beam_size_x",(BsX),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","mm",tmpPath+"beam_size_x", fileID)
	//	eznx.write_dataset(nxshape_slit, 'size_y', h5['/entry/EPICS_PV_metadata/USAXSslitVap'], units='mm')
	NEXUS_HdfSaveDataVar("beam_size_y",(BsY),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","mm",tmpPath+"beam_size_y", fileID)

	tmpPath = InstrumentPathStr+"detector"
	HDF5CreateGroup fileID , tmpPath , groupID		//this is NXentry group containinng instrument description
	NEXUS_HdfSaveAttrib("NX_class","NXdetector",tmpPath, fileID)
	NEXUS_HdfSaveAttrib("canSAS_class","SASdetector",tmpPath, fileID)
	tmpPath=tmpPath+"/"
	NEXUS_HdfSaveData("name","unknown",tmpPath, fileID)
	NVAR PixX = root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixY = root:Packages:Convert2Dto1D:PixelSizeY
	NVAR SDD= root:Packages:Convert2Dto1D:SampleToCCDDistance
	NEXUS_HdfSaveDataVar("SDD",(SDD),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","mm",tmpPath+"SDD", fileID)
	NEXUS_HdfSaveDataVar("x_pixel_size",(PixX),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","mm",tmpPath+"x_pixel_size", fileID)
	NEXUS_HdfSaveDataVar("y_pixel_size",(PixY),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","mm",tmpPath+"y_pixel_size", fileID)
	NVAR BCX = root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BCY = root:Packages:Convert2Dto1D:BeamCenterY
	NEXUS_HdfSaveDataVar("beam_center_x",(BCX),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","px",tmpPath+"beam_center_x", fileID)
	NEXUS_HdfSaveDataVar("beam_center_y",(BCY),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","px",tmpPath+"beam_center_y", fileID)
	NVAR HorizontalTilt = root:Packages:Convert2Dto1D:HorizontalTilt
	NVAR VerticalTilt = root:Packages:Convert2Dto1D:VerticalTilt
	NEXUS_HdfSaveDataVar("yaw",(HorizontalTilt),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","degree",tmpPath+"yaw", fileID)
	NEXUS_HdfSaveDataVar("pitch",(VerticalTilt),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","degree",tmpPath+"pitch", fileID)


	
	HDF5CloseFile fileID  
	print "Wrote 1D data into Nexus/CanSAS file : "+Hdf5FileName
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
// write out Nexus/CanSAS file for Irena or Indra
Function NEXUS_WriteNx1DCanSASdata(SampleName, Hdf5FileName, Iwv, dIwv, Qwv, dQwv, AppendToNameString, Writer, NoteData, Slit_Length)
		String SampleName,Hdf5FileName, AppendToNameString, NoteData, Writer
		wave Iwv, dIwv, Qwv, dQwv
		variable Slit_Length
				
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		
		//DataType = "qrs", "trs", "drs", "distrs"
		
		//this needs to change as I now need to store 1D data there... 
		//Writes Nexus/CanSAS data based on proposed format:
		// to this structure (NX_class attribute MUST name a NeXus base class)
		//
		///sasentry01							<-- HDF5 group
		//  @NX_class = "NXentry"			<-- NeXus requires this
		//  @canSAS_class = "SASentry"		<-- this is between you and me, for now. Perhaps optional?
		//
		//  /sasdata01						<-- HDF5 group
		//    @NX_class = "NXdata"			<-- NeXus requires this
		//    @canSAS_class = "SASdata"		<-- this is between you and me, for now.
		//    @canSAS_version = "0.1"		<-- this is between you and me, for now.
		//	 	@I_axes = "Q,Q"				<-- canSAS 2012 agreed model
		//	 	@Q_indices = "0,1"			<-- canSAS 2012 agreed model
		//	 	@Mask_indices = "0,1"			<-- canSAS 2012 agreed model
		//
		//	 I: float[M,N]					<-- HDF5 dataset, the intensity array
		//	    @uncertainty="Idev"		<-- canSAS 2012 agreed model
		//	    @signal=1					<-- NeXus requires this
		//		   @axes="Q"					<-- NeXus suggests this is identified
		//	 Idev: float[M,N]				<-- HDF5 dataset, the intensity array <<<<optional
		//	 Q: float[M,N]					<-- HDF5 dataset, |Q| at each pixel  <<<<optional
		//or
		//	 	@I_axes = "Qx,Qy"				<-- canSAS 2012 agreed model
		//	Qx: float[M,N]   <-- Qx at each pixel
		//	Qy: float[M,N]   <-- Qy at each pixel
		//	Qz: float[M,N]   <-- Qz at each pixel (might be all zero)
		
		////		Q :
		////  @units: (required) NX_CHAR
		////    Engineering units to use when expressing Q and related terms.
		////            
		////    Data expressed in other units might be ignored by some software packages.
		////
		////    choices:
		////       1/m
		////       1/nm  (preferred)
		////       1/angstrom
		////
		////I:
		////  @units: (required) NX_CHAR
		////    Engineering units to use when expressing intensity and related terms.
		////            
		////    Data expressed in other units will be treated as "arbitrary" by some software packages.
		////
		////    choices:
		////       1/m  (includes m2/m3 and 1/m/sr)
		////       1/cm  (includes cm2/cm3 and 1/cm/sr)
		////       m2/g
		////       cm2/g
		////       arbitrary (includes "counts" and any unrecognized units)

		
	//to do - change where the data go and how they go there. Find way to indicate what type of sector it is etc. 
//note: SampleName now has no orientation, add curOrient to make sensible... 
	variable GroupID
	Variable fileID, result
	//string Hdf5FileName=NEXUS_NikaCreateOrLocNexusFile(2)
	GetFileFolderInfo  /Q /Z Hdf5FileName
	if(V_Flag==0)		//file found	
		HDF5OpenFile /Z fileID as Hdf5FileName
		if (V_flag != 0)
			Print "HDF5 OpenFile failed"
			return -1
		endif
	else
		print "Output Nexus canSAS data file does not exist, creating it"
		HDF5CreateFile /O /Z fileID as Hdf5FileName
		if (V_flag != 0)
			Print "HDF5CreateFile failed"
			return -1
		endif
	endif
	//NEXUS_HdfSaveAttrib("default","sasentry-1","/", fileID) - this makes no sense for me...
	//create sample group	
	//NXentry aka SASentry group here... 
	string RootGroupName=Nexus_FixNxGroupName(SampleName)
	string ViewName=""
	if(strlen(AppendToNameString)>0)	//this is needed for Nika or when something is needed to be added.
		if(StringMatch(Writer, "Nika"))
			ViewName=Nexus_FixNxGroupName("1D"+"_"+AppendToNameString)
		else
			ViewName=Nexus_FixNxGroupName("_"+AppendToNameString)
		endif
	else
		ViewName=RootGroupName
	endif
	string NewGroupName
	NEXUS_HdfSaveAttrib("creator",Writer,"/", fileID)
	if(StringMatch(Writer, "Nika"))
		NEXUS_HdfSaveAttrib("url","http://usaxs.xray.aps.anl.gov/staff/ilavsky/nika.html","/", fileID)
	elseif(StringMatch(Writer, "Irena"))
		NEXUS_HdfSaveAttrib("url","http://usaxs.xray.aps.anl.gov/staff/ilavsky/irena.html","/", fileID)
	elseif(StringMatch(Writer, "Indra"))
		NEXUS_HdfSaveAttrib("url","http://usaxs.xray.aps.anl.gov/staff/ilavsky/Indra_2.html","/", fileID)	
	else
		NEXUS_HdfSaveAttrib("url","http://usaxs.xray.aps.anl.gov/staff/ilavsky/irena.html","/", fileID)		
	endif
	NEXUS_HdfSaveAttrib( "default",RootGroupName,"/", fileID)
	RootGroupName="/"+RootGroupName
	HDF5CreateGroup fileID , RootGroupName , groupID		//this is NXentry group containinng possibly many "views" on sample
	RootGroupName=RootGroupName+"/"
	//its attributes
	NEXUS_HdfSaveAttrib("NX_class","NXentry",RootGroupName, fileID)
	NEXUS_HdfSaveAttrib( "canSAS_class","SASentry",RootGroupName, fileID)
	NEXUS_HdfSaveAttrib( "canSAS_name",SampleName,RootGroupName, fileID)
	NEXUS_HdfSaveAttrib( "version","1.0",RootGroupName, fileID)
	NEXUS_HdfSaveAttrib( "default",ViewName,RootGroupName, fileID, DoNotOverwrite=1)
	//required items in here... 
	NEXUS_HdfSaveData("definition","NXcanSAS",RootGroupName, fileID)
	NEXUS_HdfSaveData("title",SampleName,RootGroupName, fileID)
	NEXUS_HdfSaveData("run","unknown",RootGroupName, fileID)
	//now NXdata group
	NewGroupName = RootGroupName+ViewName
	HDF5CreateGroup fileID , NewGroupName , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXdata",NewGroupName, fileID)
	NEXUS_HdfSaveAttrib("canSAS_class","SASdata",NewGroupName, fileID)
	NEXUS_HdfSaveAttrib("canSAS_version","1.0",NewGroupName, fileID)
	NEXUS_HdfSaveAttrib( "canSAS_name",SampleName,NewGroupName, fileID)
	NEXUS_HdfSaveAttrib("I_axes","Q",NewGroupName, fileID)
	NEXUS_HdfSaveAttrib("signal","I",NewGroupName, fileID)
	NEXUS_HdfSaveAttrib("I_uncertainties","Idev",NewGroupName, fileID)
	NEXUS_HdfSaveAttrib("Q_indices","0",NewGroupName, fileID)
	// Save I wave as dataset
	string Inote=note(Iwv)
	HDF5SaveData /O /Z /GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1} Iwv, fileID, NewGroupName+"/I"
	NEXUS_HdfSaveAttrib("uncertainties","Idev",NewGroupName+"/I", fileID)
	NEXUS_HdfSaveAttrib("units","1/cm",NewGroupName+"/I", fileID)
	//store out note in the same place as I is?
	NEXUS_WriteWaveNote(fileID,NewGroupName,Inote)
	//Now deal with Q axes...
	//NEXUS_HdfSaveAttrib("axes","Q",NewGroupName+"/sasdata01/I", fileID)
	//convert to 1/nm and use that, Nexus preferred units
	Duplicate/Free Qwv, Qwvnm
	Qwvnm = Qwvnm*10
	HDF5SaveData /O /Z/GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1}   Qwvnm , fileID, NewGroupName+"/Q"
	NEXUS_HdfSaveAttrib("units","1/nm",NewGroupName+"/Q", fileID)
	NEXUS_HdfSaveAttrib("resolutions","Qdev",NewGroupName+"/Q", fileID)
	//Now deal with Uncertainty
	//NEXUS_HdfSaveAttrib("uncertainty","Idev",NewGroupName+"/sasdata01/I", fileID)
	HDF5SaveData /O /Z/GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1}   dIwv, fileID, NewGroupName+"/Idev"
	//NEXUS_HdfSaveAttrib("axes","Q",NewGroupName+"/sasdata01/Idev", fileID)
	NEXUS_HdfSaveAttrib("units","1/cm",NewGroupName+"/Idev", fileID)
	//Now Qres.   dQwv
	Duplicate/Free dQwv, dQwvnm
	dQwvnm = dQwvnm*10
	HDF5SaveData /O /Z/GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1}   dQwvnm, fileID, NewGroupName+"/Qdev"
	NEXUS_HdfSaveAttrib("units","1/nm",NewGroupName+"/Qdev", fileID)
	
	//add instrument data...
	string InstrumentPathStr=RootGroupName+"instrument"
	string tmpPath
	HDF5CreateGroup fileID , InstrumentPathStr , groupID		//this is NXentry group containing instrument description
	NEXUS_HdfSaveAttrib("NX_class","NXinstrument",InstrumentPathStr, fileID)
	NEXUS_HdfSaveAttrib("canSAS_class","SASinstrument",InstrumentPathStr, fileID)
	InstrumentPathStr=InstrumentPathStr+"/"

	tmpPath = InstrumentPathStr+"source"
	HDF5CreateGroup fileID , tmpPath , groupID		//this is NXentry group containinng instrument description
	NEXUS_HdfSaveAttrib("NX_class","NXsource",tmpPath, fileID)
	tmpPath=tmpPath+"/"


	variable wavelength
	wavelength = NumberByKey("wavelength", NoteData, "=", ";",0)
	if(wavelength>0)
		NEXUS_HdfSaveDataVar("incident_wavelength",(wavelength),tmpPath, fileID)	
		NEXUS_HdfSaveAttrib("units","angstrom",tmpPath+"incident_wavelength", fileID)
		//HDF5CreateLink /HARD=1 targetLocationID , targetName , linkLocationID , linkName
		HDF5CreateLink/HARD=1 fileID, InstrumentPathStr+"source/incident_wavelength", fileID, InstrumentPathStr+"incident_wavelength"
		//NEXUS_HdfSaveAttrib(AttribName,AttribValue,AttribLoc, fileID,[DoNotOverwrite])
		NEXUS_HdfSaveAttrib("target",InstrumentPathStr+"source/incident_wavelength",InstrumentPathStr+"incident_wavelength", fileID)
		if(stringMatch(NameOfWave(Qwv),"*SMR_Q*") || stringMatch(NameOfWave(Qwv),"*DSM_Q*"))
			NEXUS_HdfSaveData("radiation","Synchrotron X-ray Source",tmpPath, fileID)
		else
			NEXUS_HdfSaveData("radiation","unknown",tmpPath, fileID)
		endif
	endif
	

	tmpPath = InstrumentPathStr+"detector"
	HDF5CreateGroup fileID , tmpPath , groupID		//this is NXentry group containinng instrument description
	NEXUS_HdfSaveAttrib("NX_class","NXdetector",tmpPath, fileID)
	NEXUS_HdfSaveAttrib("canSAS_class","SASdetector",tmpPath, fileID)
	tmpPath=tmpPath+"/"
	if(stringMatch(NameOfWave(Qwv),"*SMR_Q*") || stringMatch(NameOfWave(Qwv),"*DSM_Q*"))
		NEXUS_HdfSaveData("name","photodiode",tmpPath, fileID)
	else
		NEXUS_HdfSaveData("name","unknown",tmpPath, fileID)
	endif
	//NXentry
  		//NXinstrument
    		//NXdetector
      		//slit_length
	if(Slit_Length>0)
		NEXUS_HdfSaveDataVar("slit_length",(Slit_Length*10),tmpPath, fileID)
		NEXUS_HdfSaveAttrib("units","1/nm",tmpPath+"slit_length", fileID)
	endif

	HDF5CloseFile fileID  
	print "Wrote 1D data into Nexus/CanSAS file : "+Hdf5FileName
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
// write out Nexus/CanSAS 2D file for Nika
static Function NEXUS_WriteNx2DCanSASData(SampleName, Iwv, [dIwv, Qwv, Mask, Qx, Qy,AzimAngles,UnbinnedQx,UnbinnedQy])
		String SampleName
		wave Iwv, dIwv, Qwv, Mask, Qx, Qy, AzimAngles, UnbinnedQx,UnbinnedQy
		variable usedIwv, useQwv, useMask, useQx, useQy, use3Q, useUnbinnedQxy
		usedIwv= !ParamIsDefault(dIwv) 
		useQwv= !ParamIsDefault(Qwv) 
		useMask= !ParamIsDefault(Mask) 
		useQx= !ParamIsDefault(Qx) 
		useQy= !ParamIsDefault(Qy) 
		useUnbinnedQxy =  !ParamIsDefault(UnbinnedQx) 
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		use3Q = useQx*useQy
		if(use3Q + useQwv != 1)
			abort "Wrong Q data passed to WriteHdf5CanSASData"
		endif
		NVAR NX_SaveToProcNexusFile=root:Packages:Irena_Nexus:NX_SaveToProcNexusFile
		if(NX_SaveToProcNexusFile!=1)
			return 0
		endif
		
		//Writes Nexus/CanSAS data based on proposed format:
		// to this structure (NX_class attribute MUST name a NeXus base class)
		//
		///sasentry01							<-- HDF5 group
		//  @NX_class = "NXentry"			<-- NeXus requires this
		//  @canSAS_class = "SASentry"		<-- this is between you and me, for now. Perhaps optional?
		//
		//  /sasdata01						<-- HDF5 group
		//    @NX_class = "NXdata"			<-- NeXus requires this
		//    @canSAS_class = "SASdata"		<-- this is between you and me, for now.
		//    @canSAS_version = "0.1"		<-- this is between you and me, for now.
		//	 	@I_axes = "Q,Q"				<-- canSAS 2012 agreed model
		//	 	@Q_indices = "0,1"			<-- canSAS 2012 agreed model
		//	 	@Mask_indices = "0,1"			<-- canSAS 2012 agreed model
		//
		//	 I: float[M,N]					<-- HDF5 dataset, the intensity array
		//	    @uncertainty="Idev"		<-- canSAS 2012 agreed model
		//	    @signal=1					<-- NeXus requires this
		//		   @axes="Q"					<-- NeXus suggests this is identified
		//	 Idev: float[M,N]				<-- HDF5 dataset, the intensity array <<<<optional
		//	 Q: float[M,N]					<-- HDF5 dataset, |Q| at each pixel  <<<<optional
		//or
		//	 	@I_axes = "Qx,Qy"				<-- canSAS 2012 agreed model
		//	Qx: float[M,N]   <-- Qx at each pixel
		//	Qy: float[M,N]   <-- Qy at each pixel
		//	Qz: float[M,N]   <-- Qz at each pixel (might be all zero)

	variable GroupID
	Variable fileID, result
	string Hdf5FileName=NEXUS_NikaCreateOrLocNexusFile(2)
	GetFileFolderInfo  /Q /Z Hdf5FileName
	if(V_Flag==0)		//file found	
		HDF5OpenFile /Z fileID as Hdf5FileName
		if (V_flag != 0)
			Print "HDF5 OpenFile failed"
			return -1
		endif
	else
		print "Output Nexus canSAS data file does not exist, creating it"
		HDF5CreateFile /O /Z fileID as Hdf5FileName
		if (V_flag != 0)
			Print "HDF5CreateFile failed"
			return -1
		endif
	endif
	string RootGroupName=Nexus_FixNxGroupName(SampleName)
	string ViewName=Nexus_FixNxGroupName("2DCalibrated")
	string NewGroupName
	NEXUS_HdfSaveAttrib("creator","Nika","/", fileID)
	NEXUS_HdfSaveAttrib("url","http://usaxs.xray.aps.anl.gov/staff/ilavsky/nika.html","/", fileID)
	NEXUS_HdfSaveAttrib( "default",RootGroupName,"/", fileID)
	RootGroupName="/"+RootGroupName
	HDF5CreateGroup fileID , RootGroupName , groupID
	RootGroupName=RootGroupName+"/"
	//its attributes
	NEXUS_HdfSaveAttrib("NX_class","NXentry",RootGroupName, fileID)
	NEXUS_HdfSaveAttrib( "canSAS_class","SASentry",RootGroupName, fileID)
	NEXUS_HdfSaveAttrib( "canSAS_name",SampleName,RootGroupName, fileID)
	NEXUS_HdfSaveAttrib( "version","1.0",RootGroupName, fileID)
	NEXUS_HdfSaveAttrib( "default",ViewName,RootGroupName, fileID,DoNotOverwrite=1)
	//required items in here... 
	NEXUS_HdfSaveData("definition","NXcanSAS",RootGroupName, fileID)
	NEXUS_HdfSaveData("title",SampleName,RootGroupName, fileID)
	NEXUS_HdfSaveData("run"," ",RootGroupName, fileID)
	//now NXdata group
	NewGroupName = RootGroupName+ViewName
	HDF5CreateGroup fileID , NewGroupName , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXdata",NewGroupName, fileID)
	NEXUS_HdfSaveAttrib("canSAS_class","SASdata",NewGroupName, fileID)
	NEXUS_HdfSaveAttrib("canSAS_version","1.0",NewGroupName, fileID)
	NEXUS_HdfSaveAttrib("signal","I",NewGroupName, fileID)
	NEXUS_HdfSaveAttrib( "canSAS_name",SampleName,NewGroupName, fileID)
	NEXUS_HdfSaveAttrib("Q_indices","0,1",NewGroupName, fileID)
	if(useQwv)
		//now this is for use |Q|
		NEXUS_HdfSaveAttrib("I_axes","Q,Q",NewGroupName, fileID)
	else
		//now this is for use Qx, Qy
		NEXUS_HdfSaveAttrib("I_axes","Qx,Qy",NewGroupName, fileID)
	endif
	if(useMask)
		//this is if we use Mask 
		NEXUS_HdfSaveAttrib("Mask_indices","0,1",NewGroupName, fileID)
		NEXUS_HdfSaveAttrib("mask","Mask",NewGroupName, fileID)
	endif
	// Save wave as dataset
	string Inote=note(Iwv)
	HDF5SaveData /O /Z /GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1} Iwv, fileID, NewGroupName+"/I"
	NEXUS_HdfSaveAttrib("units","1/cm",NewGroupName+"/I", fileID)
	//store out note in the same place as I is?
	NEXUS_WriteWaveNote(fileID,NewGroupName,Inote)
//	HDF5CreateGroup fileID , NewGroupName+"/IGORWaveNote" , groupID		//this is NXentry group containinng possibly many "views" on sample
//	NEXUS_HdfSaveAttrib("NX_class","NXnote",NewGroupName+"/IGORWaveNote", fileID)
//	NEXUS_HdfSaveData("wave_note",Inote,NewGroupName+"/IGORWaveNote/", fileID)
//	NEXUS_HdfSaveAttrib("NX_class","NX_CHAR",NewGroupName+"/IGORWaveNote/wave_note", fileID)
	//Now deal with Q axes...
	if(useQwv)
		NEXUS_HdfSaveAttrib("axes","Q",NewGroupName+"/I", fileID)
		HDF5SaveData /O /Z/GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1}   Qwv , fileID, NewGroupName+"/Q"
		NEXUS_HdfSaveAttrib("units","1/A",NewGroupName+"/Q", fileID)
	else		//UIse Qx, Qy, Qz
		NEXUS_HdfSaveAttrib("axes","Qx,Qy",NewGroupName+"/I", fileID)
		HDF5SaveData /O /Z/GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1}   Qx , fileID, NewGroupName+"/Qx"
		HDF5SaveData /O /Z/GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1}   Qy , fileID, NewGroupName+"/Qy"
		Duplicate/Free Qx, Qz
		Qz=0
		HDF5SaveData /O /Z/GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1}   Qz , fileID, NewGroupName+"/Qz"
		NEXUS_HdfSaveAttrib("units","1/A",NewGroupName+"/Qx", fileID)
		NEXUS_HdfSaveAttrib("units","1/A",NewGroupName+"/Qy", fileID)
		NEXUS_HdfSaveAttrib("units","1/A",NewGroupName+"/Qz", fileID)
	endif
	//Now deal with Uncertainty
	if(usedIwv)
		NEXUS_HdfSaveAttrib("I_uncertainty","Idev",NewGroupName, fileID)
		NEXUS_HdfSaveAttrib("uncertainties","Idev",NewGroupName+"/I", fileID)
		HDF5SaveData /O /Z/GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1}   dIwv, fileID, NewGroupName+"/Idev"
		if(useQwv)
			NEXUS_HdfSaveAttrib("axes","Q",NewGroupName+"/Idev", fileID)
		else
			NEXUS_HdfSaveAttrib("axes","Qx,Qy",NewGroupName+"/Idev", fileID)
		endif
	else	//no uncertainty
		//NEXUS_HdfSaveAttrib("uncertainty","","/sasentry01/sasdata01/I", fileID)
		//per Pete, if dIw dows not exist, do not even mention the attribute. 
	endif
	//Now deal with mask. 
	if(useMask)
		//note, mask is 1 when the point is removed, 0 when is used. 
		HDF5SaveData /O /Z/GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1}   Mask, fileID, NewGroupName+"/Mask"
	endif
	//deal with unibnnedQxy for rebinned data
	if(useUnbinnedQxy)
		HDF5SaveData /O /Z/GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1}   UnbinnedQx, fileID, NewGroupName+"/UnbinnedQx"
		HDF5SaveData /O /Z/GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1}   UnbinnedQy, fileID, NewGroupName+"/UnbinnedQy"
	endif
	//add instruemnt data...
	string InstrumentPathStr=RootGroupName+"/"+"instrument"
	string tmpPath
	HDF5CreateGroup fileID , InstrumentPathStr , groupID		//this is NXentry group containinng instrument description
	NEXUS_HdfSaveAttrib("NX_class","NXinstrument",InstrumentPathStr, fileID)
	NEXUS_HdfSaveAttrib("canSAS_class","SASinstrument",InstrumentPathStr, fileID)
	InstrumentPathStr=InstrumentPathStr+"/"

	tmpPath = InstrumentPathStr+"source"
	HDF5CreateGroup fileID , tmpPath , groupID		//this is NXentry group containinng instrument description
	NEXUS_HdfSaveAttrib("NX_class","NXsource",tmpPath, fileID)
	tmpPath=tmpPath+"/"
	NVAR WV = root:Packages:Convert2Dto1D:Wavelength
	NEXUS_HdfSaveDataVar("incident_wavelength",(Wv),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","angstrom",tmpPath+"incident_wavelength", fileID)
	NVAR Bsx = root:Packages:Convert2Dto1D:BeamSizeX
	NVAR BsY = root:Packages:Convert2Dto1D:BeamSizeY
	NEXUS_HdfSaveDataVar("beam_size_x",(BsX),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","mm",tmpPath+"beam_size_x", fileID)
	//	eznx.write_dataset(nxshape_slit, 'size_y', h5['/entry/EPICS_PV_metadata/USAXSslitVap'], units='mm')
	NEXUS_HdfSaveDataVar("beam_size_y",(BsY),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","mm",tmpPath+"beam_size_y", fileID)

	tmpPath = InstrumentPathStr+"detector"
	HDF5CreateGroup fileID , tmpPath , groupID		//this is NXentry group containinng instrument description
	NEXUS_HdfSaveAttrib("NX_class","NXdetector",tmpPath, fileID)
	NEXUS_HdfSaveAttrib("canSAS_class","SASdetector",tmpPath, fileID)
	tmpPath=tmpPath+"/"
	NEXUS_HdfSaveData("name","unknown",tmpPath, fileID)
	NVAR PixX = root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixY = root:Packages:Convert2Dto1D:PixelSizeY
	NVAR SDD= root:Packages:Convert2Dto1D:SampleToCCDDistance
	NEXUS_HdfSaveDataVar("SDD",(SDD),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","mm",tmpPath+"SDD", fileID)
	NEXUS_HdfSaveDataVar("x_pixel_size",(PixX),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","mm",tmpPath+"x_pixel_size", fileID)
	NEXUS_HdfSaveDataVar("y_pixel_size",(PixY),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","mm",tmpPath+"y_pixel_size", fileID)
	NVAR BCX = root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BCY = root:Packages:Convert2Dto1D:BeamCenterY
	NEXUS_HdfSaveDataVar("beam_center_x",(BCX),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","px",tmpPath+"beam_center_x", fileID)
	NEXUS_HdfSaveDataVar("beam_center_y",(BCY),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","px",tmpPath+"beam_center_y", fileID)
	NVAR HorizontalTilt = root:Packages:Convert2Dto1D:HorizontalTilt
	NVAR VerticalTilt = root:Packages:Convert2Dto1D:VerticalTilt
	NEXUS_HdfSaveDataVar("yaw",(HorizontalTilt),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","degree",tmpPath+"yaw", fileID)
	NEXUS_HdfSaveDataVar("pitch",(VerticalTilt),tmpPath, fileID)
	NEXUS_HdfSaveAttrib("units","degree",tmpPath+"pitch", fileID)

	
	HDF5SaveData /O /Z/GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1}   AzimAngles, fileID, NewGroupName+"/AzimAngles"
	NEXUS_HdfSaveAttrib("units","degrees",NewGroupName+"/AzimAngles", fileID)
	HDF5CloseFile fileID  
end
//*************************************************************************************************
//*****************************************************************************************************************

static Function NEXUS_WriteNikaNexus2DRawFile(FileName)
	string FileName			//this is full path string, that is with the absolute path. 
	//creates new Nexus file with RAW data using Nika values.  
	//this file should follow NXsas structure and be understandable to Nexus file readers which expect to get NX type data as raw input. 

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable GroupID
	Variable fileID, result
	//following Pete's python code here...
//		# create file and group structure
//		root = eznx.makeFile(TARGET_FILE, default='entry')
	HDF5CreateFile /O /Z fileID as FileName
	if (V_flag != 0)
		Print "HDF5CreateFile failed"
		return -1
	endif
	//here we need to insert in the Nexus file raw data, since as far as I know Nexus file must have raw data in it? 
	//		nxentry = eznx.makeGroup(root, 'entry', 'NXentry', default='data')
	HDF5CreateGroup fileID , "/entry" , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXentry","/entry/", fileID)
	NEXUS_HdfSaveAttrib("default","data","/entry/", fileID)
	//		nxdata = eznx.makeGroup(nxentry, 'data', 'NXdata', signal='frames', )
	HDF5CreateGroup fileID , "/entry/data" , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXdata","/entry/data", fileID)
	NEXUS_HdfSaveAttrib("signal","data","/entry/data", fileID)
	//		nxinstrument = eznx.makeGroup(nxentry, 'instrument', 'NXinstrument')
	HDF5CreateGroup fileID , "/entry/instrument" , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXinstrument","/entry/instrument", fileID)
	//		nxdetector = eznx.makeGroup(nxinstrument, 'detector', 'NXdetector')
	HDF5CreateGroup fileID , "/entry/instrument/detector" , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXdetector","/entry/instrument/detector", fileID)
	//		nxsource = eznx.makeGroup(nxinstrument, 'source', 'NXsource')
	HDF5CreateGroup fileID , "/entry/instrument/source" , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXsource","/entry/instrument/source", fileID)
	//		nxmonochromator = eznx.makeGroup(nxinstrument, 'monochromator', 'NXmonochromator')
	HDF5CreateGroup fileID , "/entry/instrument/monochromator" , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXmonochromator","/entry/instrument/monochromator", fileID)
	//		nxcollimator = eznx.makeGroup(nxinstrument, 'collimator', 'NXcollimator')
	HDF5CreateGroup fileID , "/entry/instrument/collimator" , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXcollimator","/entry/instrument/collimator", fileID)
	//		nxgeometry_slit = eznx.makeGroup(nxcollimator, 'geometry', 'NXgeometry')
	HDF5CreateGroup fileID , "/entry/instrument/collimator/geometry" , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXgeometry","/entry/instrument/collimator/geometry", fileID)
	//		nxshape_slit = eznx.makeGroup(nxgeometry_slit, 'shape', 'NXshape')
	HDF5CreateGroup fileID , "/entry/instrument/collimator/geometry/shape" , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXshape","/entry/instrument/collimator/geometry/shape", fileID)
	//		aperture
	HDF5CreateGroup fileID , "/entry/instrument/aperture" , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXaperture","/entry/instrument/aperture", fileID)
	HDF5CreateGroup fileID , "/entry/instrument/aperture/geometry" , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXgeometry","/entry/instrument/aperture/geometry", fileID)
	HDF5CreateGroup fileID , "/entry/instrument/aperture/geometry/shape" , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXshape","/entry/instrument/aperture/geometry/shape", fileID)
	//		nxsample = eznx.makeGroup(nxentry, 'sample', 'NXsample')
	HDF5CreateGroup fileID , "/entry/sample" , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXsample","/entry/sample", fileID)
	//		nxmonitor = eznx.makeGroup(nxentry, 'control', 'NXmonitor')
	HDF5CreateGroup fileID , "/entry/control" , groupID
	NEXUS_HdfSaveAttrib("NX_class","NXmonitor","/entry/control", fileID)
	//this should be all needed structure
	//now write values in there.
	//	eznx.addAttributes(root, creator=h5_files[0].attrs['creator'] + ' and spec2nexus.eznx')
	NEXUS_HdfSaveAttrib("NeXus_version","4.3.0","/", fileID)
	NEXUS_HdfSaveAttrib("creator","Nika","/", fileID)
	NEXUS_HdfSaveAttrib("url","http://usaxs.xray.aps.anl.gov/staff/ilavsky/nika.html","/", fileID)
	NEXUS_HdfSaveAttrib("default","entry","/", fileID)
	NEXUS_HdfSaveAttrib("file_time",date()+" "+time(),"/", fileID)	
	//	eznx.write_dataset(nxentry, 'title', 'NeXus NXsas example')
	//Wave Wv2Ddata=root:Packages:Convert2Dto1D:CCDImageToConvert
	SVAR LoadedFile=root:Packages:Convert2Dto1D:FileNameToLoad				//current file name
	SVAR UserSampleName=root:Packages:Convert2Dto1D:UserSampleName				//current file name
	//	eznx.write_dataset(nxsample, 'name', h5['/entry/EPICS_PV_metadata/SampleTitle'])
	NEXUS_HdfSaveData("title", UserSampleName,"/entry/", fileID)
	//need to fake start_time and end_time .
	string whatistime=Secs2Date(DateTime,-2)+" "+Secs2Time(DateTime,3)
	NEXUS_HdfSaveData("start_time", whatistime,"/entry/", fileID)
	NEXUS_HdfSaveData("end_time", whatistime,"/entry/", fileID)
	//name = name of instrument, let's use Nika here
	NEXUS_HdfSaveData("name", "Nika","/entry/", fileID)
	//NEXUS_HdfSaveData("title","Nika NXsas example","/entry/", fileID)
	//	eznx.write_dataset(nxentry, 'definition', 'NXsas', URL='http://download.nexusformat.org/doc/html/classes/applications/NXsas.html')
	NEXUS_HdfSaveData("definition","NXsas","/entry/", fileID)
	NEXUS_HdfSaveAttrib("URL","http://download.nexusformat.org/doc/html/classes/applications/NXsas.html","/entry/definition", fileID)
	//	eznx.write_dataset(nxentry, 'start_time', h5_files[0].attrs['file_time'])
	//NEXUS_HdfSaveData("title","Nika NXsas example","/entry/", fileID
	//	eznx.write_dataset(nxentry, 'end_time', h5_files[-1].attrs['file_time'])
	//NEXUS_HdfSaveData("title","Nika NXsas example","/entry/", fileID
	//	eznx.write_dataset(nxdetector, 'frame_files', '\n'.join(names))
	//NEXUS_HdfSaveData("title","Nika NXsas example","/entry/", fileID
	//	eznx.write_dataset(nxinstrument, 'name', 'APS 9-ID-C USAXS pinSAXS')
	NEXUS_HdfSaveData("name","Nika software package","/entry/instrument/", fileID)
	//	eznx.write_dataset(nxsource, 'type', 'Synchrotron X-ray Source')
	//NEXUS_HdfSaveData("title","Nika NXsas example","/entry/", fileID
	//	eznx.write_dataset(nxsource, 'name', 'Advanced Photon Source Undulator A, sector 9ID-C')
	NEXUS_HdfSaveData("name","unknown","/entry/instrument/source/", fileID)
	//	eznx.write_dataset(nxsource, 'probe', 'x-ray')
	NEXUS_HdfSaveData("probe","x-ray","/entry/instrument/source/", fileID)
	//	eznx.write_dataset(nxsource, 'current', h5['/entry/EPICS_PV_metadata/SRcurrent'], units='mA')
	//NEXUS_HdfSaveData("title","Nika NXsas example","/entry/", fileID
	//	eznx.write_dataset(nxsource, 'energy', float(7), units='GeV')
	//	eznx.write_dataset(nxmonochromator, 'energy', h5['/entry/instrument/monochromator/energy'], units='keV')
	NVAR EN = root:Packages:Convert2Dto1D:XrayEnergy	
	//NEXUS_HdfSaveDataVar("energy",EN,"/entry/instrument/source/", fileID)
	//NEXUS_HdfSaveAttrib("units","keV","/entry/instrument/source/energy", fileID)
	NEXUS_HdfSaveDataVar("energy",EN,"/entry/instrument/monochromator/", fileID)
	NEXUS_HdfSaveAttrib("units","keV","/entry/instrument/monochromator/energy", fileID)
	//	eznx.write_dataset(nxmonochromator, 'wavelength', h5['/entry/EPICS_PV_metadata/wavelength'], units='angstrom')
	NVAR WV = root:Packages:Convert2Dto1D:Wavelength
	NEXUS_HdfSaveDataVar("wavelength",(Wv),"/entry/instrument/monochromator/", fileID)
	NEXUS_HdfSaveAttrib("units","angstrom","/entry/instrument/monochromator/wavelength", fileID)
	//	eznx.write_dataset(nxmonochromator, 'wavelength_spread', h5['/entry/EPICS_PV_metadata/wavelength_spread'], units='angstrom/angstrom')
	//NEXUS_HdfSaveData("title","Nika NXsas example","/entry/", fileID)
	//	eznx.write_dataset(nxshape_slit, 'shape', 'nxbox')
	//NEXUS_HdfSaveData("title","Nika NXsas example","/entry/", fileID)
	//	# next four are not defined in the NXsas specification
	NVAR PixX = root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixY = root:Packages:Convert2Dto1D:PixelSizeY
	NVAR Bsx = root:Packages:Convert2Dto1D:BeamSizeX
	NVAR BsY = root:Packages:Convert2Dto1D:BeamSizeY
	//	eznx.write_dataset(nxshape_slit, 'size_x', h5['/entry/EPICS_PV_metadata/USAXSslitHap'], units='mm')
	NEXUS_HdfSaveDataVar("xsize",(BsX),"/entry/instrument/collimator/geometry/shape/", fileID)
	NEXUS_HdfSaveAttrib("units","mm","/entry/instrument/collimator/geometry/shape/xsize", fileID)
	//	eznx.write_dataset(nxshape_slit, 'size_y', h5['/entry/EPICS_PV_metadata/USAXSslitVap'], units='mm')
	NEXUS_HdfSaveDataVar("ysize",(BsY),"/entry/instrument/collimator/geometry/shape/", fileID)
	NEXUS_HdfSaveAttrib("units","mm","/entry/instrument/collimator/geometry/shape/ysize", fileID)

	NEXUS_HdfSaveDataVar("sizex",(BsX),"/entry/instrument/aperture/geometry/shape/", fileID)
	NEXUS_HdfSaveAttrib("units","mm","/entry/instrument/aperture/geometry/shape/sizex", fileID)
	//	eznx.write_dataset(nxshape_slit, 'size_y', h5['/entry/EPICS_PV_metadata/USAXSslitVap'], units='mm')
	NEXUS_HdfSaveDataVar("sizey",(BsY),"/entry/instrument/aperture/geometry/shape/", fileID)
	NEXUS_HdfSaveAttrib("units","mm","/entry/instrument/aperture/geometry/shape/sizey", fileID)
	NEXUS_HdfSaveData("shape","nxbox","/entry/instrument/aperture/geometry/shape/", fileID)

	//	eznx.write_dataset(nxshape_slit, 'center_x', h5['/entry/EPICS_PV_metadata/USAXSslitHpos'], units='mm')
	//NEXUS_HdfSaveData("title","Nika NXsas example","/entry/", fileID)
	//	eznx.write_dataset(nxshape_slit, 'center_y', h5['/entry/EPICS_PV_metadata/USAXSslitVpos'], units='mm')
	//NEXUS_HdfSaveData("title","Nika NXsas example","/entry/", fileID)
	NVAR SDD= root:Packages:Convert2Dto1D:SampleToCCDDistance
	//	eznx.write_dataset(nxdetector, 'distance', h5['/entry/EPICS_PV_metadata/SDD'], units='mm')
	NEXUS_HdfSaveDataVar("distance",(SDD),"/entry/instrument/detector/", fileID)
	NEXUS_HdfSaveAttrib("units","mm","/entry/instrument/detector/distance", fileID)
	//	eznx.write_dataset(nxdetector, 'x_pixel_size', h5['/entry/EPICS_PV_metadata/pin_ccd_pixel_size_x'], units='mm')
	NEXUS_HdfSaveDataVar("x_pixel_size",(PixX),"/entry/instrument/detector/", fileID)
	NEXUS_HdfSaveAttrib("units","mm","/entry/instrument/detector/x_pixel_size", fileID)
	//	eznx.write_dataset(nxdetector, 'y_pixel_size', h5['/entry/EPICS_PV_metadata/pin_ccd_pixel_size_y'], units='mm')
	NEXUS_HdfSaveDataVar("y_pixel_size",(PixY),"/entry/instrument/detector/", fileID)
	NEXUS_HdfSaveAttrib("units","mm","/entry/instrument/detector/y_pixel_size", fileID)
	NVAR BCX = root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BCY = root:Packages:Convert2Dto1D:BeamCenterY
	//	eznx.write_dataset(nxdetector, 'beam_center_x', h5['/entry/EPICS_PV_metadata/pin_ccd_center_x'], units='mm')
	//NEXUS_HdfSaveDataVar("beam_center_x",(BCX*PixX),"/entry/instrument/detector/", fileID)
	///NEXUS_HdfSaveAttrib("units","mm","/entry/instrument/detector/beam_center_x", fileID)
	NEXUS_HdfSaveDataVar("beam_center_x",(BCX),"/entry/instrument/detector/", fileID)
	NEXUS_HdfSaveAttrib("units","px","/entry/instrument/detector/beam_center_x", fileID)
	//	eznx.write_dataset(nxdetector, 'beam_center_y', h5['/entry/EPICS_PV_metadata/pin_ccd_center_y'], units='mm')
	NEXUS_HdfSaveDataVar("beam_center_y",(BCY),"/entry/instrument/detector/", fileID)
	NEXUS_HdfSaveAttrib("units","px","/entry/instrument/detector/beam_center_y", fileID)
	//	eznx.write_dataset(nxdetector, 'beam_center_x_pixel', h5['/entry/EPICS_PV_metadata/pin_ccd_center_x_pixel'])
	NEXUS_HdfSaveDataVar("pin_ccd_center_x_pixel",(BCX),"/entry/instrument/detector/", fileID)
	NEXUS_HdfSaveAttrib("units","px","/entry/instrument/detector/pin_ccd_center_x_pixel", fileID)
	//	eznx.write_dataset(nxdetector, 'beam_center_y_pixel', h5['/entry/EPICS_PV_metadata/pin_ccd_center_y_pixel'])
	NEXUS_HdfSaveDataVar("pin_ccd_center_y_pixel",(BCY),"/entry/instrument/detector/", fileID)
	NEXUS_HdfSaveAttrib("units","px","/entry/instrument/detector/pin_ccd_center_y_pixel", fileID)
//	LookUpList+="HorizontalTilt=pin_ccd_tilt_x:;"
//	LookUpList+="VerticalTilt=pin_ccd_tilt_y:;"
	NVAR HorizontalTilt = root:Packages:Convert2Dto1D:HorizontalTilt
	NVAR VerticalTilt = root:Packages:Convert2Dto1D:VerticalTilt
	NEXUS_HdfSaveDataVar("pin_ccd_tilt_x",(HorizontalTilt),"/entry/instrument/detector/", fileID)
	NEXUS_HdfSaveAttrib("units","degree","/entry/instrument/detector/pin_ccd_tilt_x", fileID)
	NEXUS_HdfSaveDataVar("pin_ccd_tilt_y",(VerticalTilt),"/entry/instrument/detector/", fileID)
	NEXUS_HdfSaveAttrib("units","degree","/entry/instrument/detector/pin_ccd_tilt_y", fileID)

	Wave Wv2Ddata=root:Packages:Convert2Dto1D:CCDImageToConvert
	//	eznx.write_dataset(nxsample, 'name', h5['/entry/EPICS_PV_metadata/SampleTitle'])
	NEXUS_HdfSaveData("name",StringByKey("DataFileName", note(Wv2Ddata), "=", ";"),"/entry/sample/", fileID)
	//	eznx.write_dataset(nxmonitor, 'mode', 'time')
	//NEXUS_HdfSaveData("title","Nika NXsas example","/entry/", fileID)
	NVAR ExpTime=root:Packages:Convert2Dto1D:SampleMeasurementTime
	//	eznx.write_dataset(nxmonitor, 'preset', h5['/entry/EPICS_PV_metadata/PresetTime'], units='s')
	NEXUS_HdfSaveDataVar("preset",(ExpTime),"/entry/control/", fileID)
	NEXUS_HdfSaveAttrib("units","s","/entry/control/preset", fileID)
	//	# NXsas specifies a scaler, we have a frame set so we record a 1-D array here
	NVAR ExpCounts=root:Packages:Convert2Dto1D:SampleI0
	//	eznx.write_dataset(nxmonitor, 'integral', monitor, units='s')
	NEXUS_HdfSaveData("mode","timer","/entry/control/", fileID)
	NEXUS_HdfSaveDataVar("integral",(ExpCounts),"/entry/control/", fileID)
	NEXUS_HdfSaveAttrib("units","counts","/entry/control/integral", fileID)
	NVAR Thick=root:Packages:Convert2Dto1D:SampleThickness
	NEXUS_HdfSaveDataVar("thickness",(ExpTime),"/entry/sample/", fileID)
	NEXUS_HdfSaveAttrib("units","s","/entry/sample/thickness", fileID)
	string Inote = note(Wv2Ddata)
	NEXUS_WriteWaveNote(fileID,"/entry",Inote)
	
		//root:Packages:Convert2Dto1D:EmptyI0
		//root:Packages:Convert2Dto1D:EmptyMeasurementTime
		//root:Packages:Convert2Dto1D:HorizontalTilt
		//,
		//,,root:Packages:Convert2Dto1D:SampleTransmission
	//	ds = nxdetector.create_dataset('data', data=numpy.array(frame_set), compression='gzip', compression_opts=9)
	Wave data2D = root:Packages:Convert2Dto1D:CCDImageToConvert
	HDF5SaveData /O /Z /GZIP={2 , 1}  /LAYO={2,32,32}/IGOR=0 /MAXD={-1,-1} data2D, fileID, "entry/instrument/detector/data"
	if (V_flag != 0)
		Print "HDF5SaveData failed"
		result = -1
	endif
	HDF5CreateLink/HARD=1 fileID, "entry/instrument/detector/data", fileID, "/entry/data/data"

	//NEXUS_HdfSaveAttrib("units","s","/entry/sample/thickness", fileID)
	//	eznx.addAttributes(ds, units='counts', compression='gzip')
	//	eznx.makeLink(nxdata, ds, 'frames')
	//	ds = eznx.write_dataset(nxsample, 'image_times', sample_times, units='minutes')
	//	eznx.makeLink(nxdata, ds, 'sample_times')
	//	# ds = eznx.write_dataset(fake_nxdetector, 'fake_image', fake_image_data, units='counts')
	//	# eznx.makeLink(nxdata, ds, 'fake_frame')
	
	HDF5CloseFile fileID  

end
//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
Function NEXUS_NikaSave2DData()
	//appends 2D data if user requests it
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR NX_SaveToProcNexusFile 		= root:Packages:Irena_Nexus:NX_SaveToProcNexusFile
	NVAR NX_Append2DDataToProcNexus = root:Packages:Irena_Nexus:NX_Append2DDataToProcNexus		//2D calibrated data
	NVAR NX_Rebin2DData = root:Packages:Irena_Nexus:NX_Rebin2DData							//rebin 2D data
	SVAR NX_RebinCal2DDtToPnts=root:Packages:Irena_Nexus:NX_RebinCal2DDtToPnts			//rebin to what
	NVAR NX_AppendMaskToRawNexus	=root:Packages:Irena_Nexus:NX_AppendMaskToRawNexus			//mask
	NVAR NX_AppendBlankToRawNexus=root:Packages:Irena_Nexus:NX_AppendBlankToRawNexus
	NVAR NX_UseQxQyCalib2DData=root:Packages:Irena_Nexus:NX_UseQxQyCalib2DData
	NVAR NX_CreateNewRawNexusFile=root:Packages:Irena_Nexus:NX_CreateNewRawNexusFile
	
	SVAR LoadedFile=root:Packages:Convert2Dto1D:FileNameToLoad
	SVAR UserSampleName=root:Packages:Convert2Dto1D:UserSampleName
	
	if(NX_CreateNewRawNexusFile)
		NEXUS_WriteNikaNexus2DRawFile(NEXUS_NikaCreateOrLocNexusFile(1))
	endif
	string Calibrated2DDataName = UserSampleName
	//string Calibrated2DDataName = RemoveEnding(RemoveListItem(ItemsInList(LoadedFile,".")-1, LoadedFile, "."))+"_2DCalibrated"

	NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY
	variable XDimension, YDimension
	if(NX_Append2DDataToProcNexus)
		
		strswitch(NX_RebinCal2DDtToPnts)	// string switch
			case "100x100":		// execute if case matches expression
				XDimension=100
				YDimension=100
				break					// exit from switch
			case "200x200":		// execute if case matches expression
				XDimension=200
				YDimension=200
				break					// exit from switch
			case "300x300":		// execute if case matches expression
				XDimension=300
				YDimension=300
				break					// exit from switch
			case "400x400":		// execute if case matches expression
				XDimension=400
				YDimension=400
				break					// exit from switch
			case "600x600":		// execute if case matches expression
				XDimension=600
				YDimension=600
				break					// exit from switch
			default:							// optional default expression executed
				XDimension=800
				YDimension=800
			endswitch
		//here we get only if user wants to export 2D calibrated data...
		//check the wave of interest exist...
		wave/Z Calibrated2DDataSet = root:Packages:Convert2Dto1D:Calibrated2DDataSet
		if(!WaveExists(Calibrated2DDataSet))
				Abort "Error in NEXUS_NikaSave2DData. Calibrated data do not exist..."
				return 0
		endif
		wave/Z Q2DWave = root:Packages:Convert2Dto1D:Q2DWave
		if(!WaveExists(Q2DWave))
				Abort "Error in NEXUS_NikaSave2DData. Q2DWave data do not exist..."
				return 0
		endif
		//check for Mask presence...
		if(NX_AppendMaskToRawNexus)
			Wave/Z Mask = root:Packages:Convert2Dto1D:M_ROIMask
			if(!WaveExists(Mask))
					Abort "Error in NEXUS_NikaSave2DData. Mask data do not exist..."
					return 0
			endif
		endif
		Duplicate/Free Calibrated2DDataSet, IntExp2DData
		Duplicate/Free Q2DWave, QExp2DData
		if(NX_AppendMaskToRawNexus)
			Duplicate/O Mask, MaskExp2DData
			//Igor Mask has 0 where masked, 1 where used. This is opposite (of course) to what Nexus/CanSAS uses:
			//Pete:   mask is 1 when the point is removed, 0 when is used. 
			//MatrixOp/O/NTHR=0 MaskExp2DData = abs(MaskExp2DData-1)
			MaskExp2DData = !MaskExp2DData
		else
			Duplicate/Free Q2DWave, MaskExp2DData		//fake for possible rebinning...
		endif
		Wave AnglesWave= root:Packages:Convert2Dto1D:AnglesWave
		Duplicate/Free AnglesWave, AnglesWaveExp
	
		if(NX_Rebin2DData && NX_Append2DDataToProcNexus)
			//here we need to create proper rebinned data
			//first need to create UnbinnedQx, and UnbinnedQy
			MatrixOp/Free QxExp2DData = QExp2DData * sin(AnglesWaveExp)
			MatrixOp/Free QyExp2DData = QExp2DData * cos(AnglesWaveExp)
			make/Free/N=(DimSize(QxExp2DData, 0)) UnbinnedQx
			make/Free/N=(DimSize(QyExp2DData, 1)) UnbinnedQy
			//did fail in any beam center index is negative (out of image)
			//this code is wrong, this is wrongly indexed somehow. Needs fixing before use 
			DoAlert 0, "This code in NEXUS_NikaSave2DData() is wrong, fix me before use" 
			if(BeamCenterX>0)
				UnbinnedQx = QxExp2DData[BeamCenterX][p]
			else
				UnbinnedQx = QxExp2DData[0][p]
			endif
			if(BeamCenterY>0)
				UnbinnedQy = QyExp2DData[p][BeamCenterY]
			else
				UnbinnedQy = QyExp2DData[p][0]
			endif
			NEXUS_RebinOnLogScale2DData(IntExp2DData,QExp2DData, AnglesWaveExp, MaskExp2DData, XDimension, YDimension,BeamCenterX, BeamCenterY)
			MatrixOp/O MaskExp2DData = ceil(MaskExp2DData)	//any point which had mask in it will be masked, I need to revisit this later, if this works. 
		else
			//exporting data in their original size. This may be large for SAXS data sets!
		endif
		//create Qx and Qy if needed, using rebinned data, if these were created.
		if(NX_UseQxQyCalib2DData)
			MatrixOp/Free QxExp2DData = QExp2DData * sin(AnglesWaveExp)
			MatrixOp/Free QyExp2DData = QExp2DData * cos(AnglesWaveExp)
		endif
		string PathToExportData=NEXUS_NikaCreateOrLocNexusFile(2)	
		//variable AppendToNexus=!NX_CreateNewRawNexusFile
		if(NX_AppendMaskToRawNexus)
			if(NX_UseQxQyCalib2DData)
				if(NX_Rebin2DData)
					NEXUS_WriteNx2DCanSASData(Calibrated2DDataName, IntExp2DData, Qx=QxExp2DData, Qy=QyExp2DData, Mask=MaskExp2DData, AzimAngles=AnglesWaveExp,UnbinnedQx=UnbinnedQx,UnbinnedQy=UnbinnedQy)
				else
					NEXUS_WriteNx2DCanSASData(Calibrated2DDataName, IntExp2DData, Qx=QxExp2DData, Qy=QyExp2DData, Mask=MaskExp2DData, AzimAngles=AnglesWaveExp)
				endif
			else
				if(NX_Rebin2DData)
					NEXUS_WriteNx2DCanSASData(Calibrated2DDataName, IntExp2DData, Mask=MaskExp2DData,Qwv=QExp2DData, AzimAngles=AnglesWaveExp,UnbinnedQx=UnbinnedQx,UnbinnedQy=UnbinnedQy)
				else
					NEXUS_WriteNx2DCanSASData(Calibrated2DDataName, IntExp2DData, Mask=MaskExp2DData,Qwv=QExp2DData, AzimAngles=AnglesWaveExp)
				endif
			endif
		else
			if(NX_UseQxQyCalib2DData)
				if(NX_Rebin2DData)
					NEXUS_WriteNx2DCanSASData(Calibrated2DDataName, IntExp2DData, Qx=QxExp2DData, Qy=QyExp2DData, AzimAngles=AnglesWaveExp,UnbinnedQx=UnbinnedQx,UnbinnedQy=UnbinnedQy)
				else
					NEXUS_WriteNx2DCanSASData(Calibrated2DDataName, IntExp2DData, Qx=QxExp2DData, Qy=QyExp2DData, AzimAngles=AnglesWaveExp)
				endif
			else
				if(NX_Rebin2DData)
					NEXUS_WriteNx2DCanSASData(Calibrated2DDataName, IntExp2DData,Qwv=QExp2DData, AzimAngles=AnglesWaveExp,UnbinnedQx=UnbinnedQx,UnbinnedQy=UnbinnedQy)
				else
					NEXUS_WriteNx2DCanSASData(Calibrated2DDataName, IntExp2DData,Qwv=QExp2DData, AzimAngles=AnglesWaveExp)
				endif
			endif	
		endif
	endif
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************


static Function NEXUS_RebinOnLogScale2DData(Calibrated2DData,Qmatrix, AnglesWave, Mask, XDimension, YDimension,BeamCenterX, BeamCenterY)
	wave Calibrated2DData,Qmatrix, AnglesWave, Mask
	variable XDimension, YDimension, BeamCenterX, BeamCenterY
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//here we rebin the data using fake log binning and return really weird data
	//how to rebin the data.
	variable Dim1=DimSize(Calibrated2DData, 0 )		//this is hwo many points we have here. 
	variable Dim2=DimSize(Calibrated2DData, 1)		//this is hwo many points we have here. 
	//assume this is X, so here is how much user wants: XDimension, beam center is BeamCenterX
	variable distance1, distance2
	distance1 = (Dim1 - BeamCenterX)
	distance2 = BeamCenterX
	//this way distance1+distance2 = Dim1
	variable Rebin1, Rebin2
	Rebin1 = ceil(XDimension * distance1/Dim1)
	Rebin2 = ceil(XDimension * distance2/Dim1)
	//now we need to spread around points correctly... N is original number of points, M is output number of points. 
	//average in each M point is N/M, so M array starts from 1 and goes to 2*N/M - 1, use Round to have the values integers.
	Make/Free/N=(ceil(Rebin1)) Rebin1Wv, Rebin2Wv
	Rebin1Wv = round(1+p/(Rebin1-1) * ((2*distance1/Rebin1)-2))
	Rebin2Wv = round(1+p/(Rebin2-1) * ((2*distance2/Rebin2)-2))
	//now rebinning...
	make/Free/N=(XDimension,Dim2) CalDataRebin1, QmatrixRebin1, MaskRebin1,AnglesRebin1
	variable i, j, ii, jj, iii
	ii = -1
	jj = BeamCenterX
	For(i=ceil(BeamCenterX*XDimension/Dim1);i<XDimension;i+=1)
		ii+=1
		FOr(j=0;j<Rebin1Wv[ii];j+=1)
			CalDataRebin1[i][] += Calibrated2DData[j+jj][q]
			QmatrixRebin1[i][] += Qmatrix[j+jj][q]
			AnglesRebin1[i][] += AnglesWave[j+jj][q]
			MaskRebin1[i][] 	+= Mask[j+jj][q]
		endfor
		CalDataRebin1[i][]/=Rebin1Wv[ii]
		QmatrixRebin1[i][]/=Rebin1Wv[ii]
		AnglesRebin1[i][]/=Rebin1Wv[ii]
		MaskRebin1[i][]/=Rebin1Wv[ii]
		jj += Rebin1Wv[ii]
	endfor
	//now the other side
	ii = -1
	jj = BeamCenterX
	For(i=floor(BeamCenterX*XDimension/Dim1);i>=0;i-=1)
		ii+=1
		FOr(j=0;j<Rebin2Wv[ii];j+=1)
			CalDataRebin1[i][] += Calibrated2DData[jj-j][q]
			QmatrixRebin1[i][] += Qmatrix[jj-j][q]
			AnglesRebin1[i][] += AnglesWave[jj-j][q]
			MaskRebin1[i][] += Mask[jj-j][q]
		endfor
		CalDataRebin1[i][]/=Rebin2Wv[ii]
		QmatrixRebin1[i][]/=Rebin2Wv[ii]
		AnglesRebin1[i][]/=Rebin2Wv[ii]
		MaskRebin1[i][]/=Rebin2Wv[ii]
		jj -= Rebin2Wv[ii]
	endfor
	//now the other dimension
	distance1 = (Dim2 - BeamCenterY)
	distance2 = BeamCenterY
	Rebin1 = ceil(YDimension * distance1/Dim2)
	Rebin2 = ceil(YDimension * distance2/Dim2)
	Make/Free/N=(ceil(Rebin2)) Rebin1Wv2, Rebin2Wv2
	Rebin1Wv2 = round(1+p/(Rebin1-1) * ((2*distance1/Rebin1)-2))
	Rebin2Wv2 = round(1+p/(Rebin2-1) * ((2*distance2/Rebin2)-2))
	make/Free/N=(XDimension,YDimension) CalDataRebin2, QmatrixRebin2, MaskRebin2, AnglesRebin2
	ii = -1
	jj = BeamCenterY
	For(i=ceil(BeamCenterY*YDimension/Dim2);i<YDimension;i+=1)
		ii+=1
		FOr(j=0;j<Rebin1Wv2[ii];j+=1)
			CalDataRebin2[][i] += CalDataRebin1[p][j+jj]
			QmatrixRebin2[][i] += QmatrixRebin1[p][j+jj]
			AnglesRebin2[][i] += AnglesRebin1[p][j+jj]
			MaskRebin2[][i] 	+= MaskRebin1[p][j+jj]
		endfor
		CalDataRebin2[][i]/=Rebin1Wv2[ii]
		QmatrixRebin2[][i]/=Rebin1Wv2[ii]
		AnglesRebin2[][i]/=Rebin1Wv2[ii]
		MaskRebin2[][i]/=Rebin1Wv2[ii]
		jj += Rebin1Wv2[ii]
	endfor
	//now the other side
	ii = -1
	jj = BeamCenterY
	For(i=floor(BeamCenterY*YDimension/Dim1);i>=0;i-=1)
		ii+=1
		FOr(j=0;j<Rebin2Wv2[ii];j+=1)
			CalDataRebin2[][i] += CalDataRebin1[p][jj-j]
			QmatrixRebin2[][i] += QmatrixRebin1[p][jj-j]
			AnglesRebin2[][i] += AnglesRebin1[p][jj-j]
			MaskRebin2[][i] += MaskRebin1[p][jj-j]
		endfor
		CalDataRebin2[][i]/=Rebin2Wv2[ii]
		QmatrixRebin2[][i]/=Rebin2Wv2[ii]
		AnglesRebin2[][i]/=Rebin2Wv2[ii]
		MaskRebin2[][i]/=Rebin2Wv2[ii]
		jj -= Rebin2Wv2[ii]
	endfor	
	Duplicate/O CalDataRebin2,Calibrated2DData
	Duplicate/O QmatrixRebin2,Qmatrix
	Duplicate/O AnglesRebin2,AnglesWave
	Duplicate/O MaskRebin2,Mask
end
//**************************************************************************************************************************************************************************************
//**************************************************************************************************************************************************************************************
//*************************************************************************************************
static FUnction/T Nexus_FixNxGroupName(basename)
	string BaseName
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if(GrepString(BaseName, "^[0-9]"))
		BaseName="_"+BaseName
	endif
	return BaseName
end
//*************************************************************************************************
//*************************************************************************************************
static Function NEXUS_HdfSaveDataVar(DataName,DataValueVar,DataLoc, fileID)
	string DataName,DataLoc
	Variable fileID, DataValueVar
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	make/Free/N=1 dataWv
	dataWv = DataValueVar									
	HDF5SaveData /O  dataWv, fileID, DataLoc+DataName
	if (V_flag != 0)
		Print "HDF5SaveData failed when saving data "+DataName+" with value of "+num2str(DataValueVar)+" at location of "+DataLoc
	endif	
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
static Function NEXUS_HdfSaveData(DataName,DataValueStr,DataLoc, fileID)
	string DataName,DataValueStr,DataLoc
	Variable fileID
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if(NEXUS_isaNumber(DataValueStr))
		make/Free/N=1 dataWvN
		dataWvN = str2num(DataValueStr)			
		HDF5SaveData /O/IGOR=0  dataWvN, fileID, DataLoc+DataName
	else
		make/T/Free/N=1 dataWv
		dataWv = DataValueStr			
		HDF5SaveData /O/IGOR=0  dataWv, fileID, DataLoc+DataName
	endif						
	if (V_flag != 0)
		Print "HDF5SaveData failed when saving data "+DataName+" with value of "+DataValueStr+" at location of "+DataLoc
	endif	
end

static Function NEXUS_isaNumber(in)                // checks if the input string  is ONLY a number
    String in
    String str
    Variable v
    if(strlen(in)==0)
    	return 1
    endif
    sscanf in, "%g%s", v,str
    return (V_flag==1)
End


//*************************************************************************************************
//*************************************************************************************************
static Function NEXUS_WriteWaveNote(fileID,Location,NoteStr)
	variable fileID
	String Location,NoteStr
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//Create NXnote group 
	variable GroupID, i
	string Key, Value, tempStr
	NoteStr= ReplaceString("\r", NoteStr, ";")
	HDF5CreateGroup fileID , Location+"/IGORWaveNote" , groupID		
	NEXUS_HdfSaveAttrib("NX_class","NXnote",Location+"/IGORWaveNote", fileID)
	For(i=0;i<ItemsInList(NoteStr,";");i+=1)
		tempStr = StringFromList(i,NoteStr,";")
		if((strlen(tempStr)>2) && StringMatch(tempStr, "*=*" ))
			Key = NEXUS_FixNXGroupName(StringFromList(0, tempStr,"="))
			Key = ReplaceString(":", Key, "_")
			Key = ReplaceString(" ", Key, "_")
			Value= StringFromList(1, tempStr,"=")
			NEXUS_HdfSaveData(Key,Value,Location+"/IGORWaveNote/", fileID)
			//NEXUS_HdfSaveAttrib("NX_class","NX_CHAR",Location+"/IGORWaveNote/"+Key, fileID)
		endif
	endfor
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
static Function NEXUS_HdfSaveAttrib(AttribName,AttribValue,AttribLoc, fileID,[DoNotOverwrite])
	string AttribName,AttribValue,AttribLoc
	Variable fileID,DoNotOverwrite
	variable DoNotOverwriteL= !ParamIsDefault(DoNotOverwrite)
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	make/T/Free/N=1 groupAttribute
	groupAttribute = AttribValue		
	if(DoNotOverwriteL)	
		HDF5LoadData /Z/O/TYPE=1/A=AttribName fileID, AttribLoc
		if(V_Flag==0)
			return 0
		endif
	endif						
	HDF5SaveData /O/A=AttribName groupAttribute, fileID, AttribLoc
	if (V_flag != 0)
		Print "HDF5SaveData failed when saving Attribute "+AttribName+" with value of "+AttribValue+" at location of "+AttribLoc
	endif	
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
static Function NEXUS_HdfSaveAttribIntg(AttribName,AttribValue,AttribLoc, fileID)
	string AttribName,AttribLoc
	Variable fileID, AttribValue
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	make/U/W/Free/N=1 groupAttribute
	groupAttribute = AttribValue									
	HDF5SaveData /O/A=AttribName groupAttribute, fileID, AttribLoc
	if (V_flag != 0)
		Print "HDF5SaveData failed when saving Attribute "+AttribName+" with value of "+num2str(AttribValue)+" at location of "+AttribLoc
	endif	
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

static Function/T NEXUS_NikaCreateOrLocNexusFile(RawOrProcessedFile)
	variable RawOrProcessedFile
	//this function will create path to Nexus file based on users wishes and input file name...
	//=1 for Raw file (same name as input file).hdf and 2 for Processed data file - name _Nika.hdf

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//get the file name right...
	string LocalUserFileName
	string UseName
	string LongUseName
	SVAR LoadedFile=root:Packages:Convert2Dto1D:FileNameToLoad				//current file name
	SVAR UserSampleName=root:Packages:Convert2Dto1D:UserSampleName
	SVAR MainPathInfoStr=root:Packages:Convert2Dto1D:MainPathInfoStr		//current folder name
	

	NVAR NX_InputFileIsNexus=root:Packages:Irena_Nexus:NX_InputFileIsNexus
	NVAR NX_SaveToProcNexusFile=root:Packages:Irena_Nexus:NX_SaveToProcNexusFile
	NVAR NX_CreateNewRawNexusFile=root:Packages:Irena_Nexus:NX_CreateNewRawNexusFile	
	SVAR ExportDataFolderName= root:Packages:Irena_Nexus:ExportDataFolderName		//  
	PathInfo Nexus_OutputFilePath
	if(!V_Flag)
		Abort "Export Symbolic Path does not exist, please, set the Export path first"
	endif
	ExportDataFolderName = S_Path
	GetFileFolderInfo/Q ExportDataFolderName	
	if(V_Flag!=0)
		Abort "Export Path does not exist on the drive" 
	endif
	string MainFileNamePart
	MainFileNamePart = RemoveListItem(ItemsInList(LoadedFile, ".")-1, LoadedFile, ".")
	MainFileNamePart = RemoveEnding(MainFileNamePart, "." )
	string FullPathAndName
	if(RawOrProcessedFile==1)
		FullPathAndName = ExportDataFolderName+MainFileNamePart+".hdf"
		return FullPathAndName
	endif
	if(RawOrProcessedFile==2)
		FullPathAndName = ExportDataFolderName+MainFileNamePart+"_Nika.hdf"
		return FullPathAndName
	endif
end
//*************************************************************************************************
//*************************************************************************************************
//Function/T NEXUS_PossiblyQUoteNXPathinIgor(PathIn)
//	string PathIn
//	//possiblyqoutes parts of path if needed.
//	//assume in goes :test1:test2:test3
//	
//	string result, tmpStr
//	variable i
//	if(stringmatch(PathIn,":"))
//		return ":"
//	endif
//	result = ""
//	PathIn = PathIn[1,inf]+":"		//remove ":" from front and add it to end, so it is proper list... 
//	For(i=0;i<ItemsInList(PathIn,":");i+=1)
//		result+=":"+PossiblyQUoteName(stringFromList(i,PathIn,":"))
//	endfor
//	return result
//end
//*************************************************************************************************
//*************************************************************************************************
// 				Irena NXcanSAS support
//
Function NEXUS_NXcanSASDataReader(FilePathName,Filename,Read1D, Read2D, UseFileNameasFolder, UsesasEntryNameAsFolder,UseTileNameAsFolder, InclNX_SasIns,InclNX_SASSam,InclNX_SASNote)	
	string FilePathName,Filename
	variable Read1D, Read2D, UseFileNameasFolder, UsesasEntryNameAsFolder,UseTileNameAsFolder, InclNX_SasIns,InclNX_SASSam,InclNX_SASNote
	//this function imports one Nexus NXcanSAS File
	//follow NEXUS_NexusNXsasDataReader
	//assume 1D only for now. 
			//here si my logic;
			//1.	identify location of all canSAS datasets - @NX_class=NXentry & @canSAS_class=SASentry
			//2.	for each data set identify all "views" on the data - @NX_class=NXdata & @canSAS_class=SASdata
			//		use;
					//		title or @canSAS_name  as name for the sample
					//		if fails, name the sample, using file name...
			//3.	1D version: for each "view" identify @signal - (should be I or in Igor speak I0), locate @I_axes-(should be Q)
			//		@I_uncertainties (if available). From the data I and Q identify also uncertainties and resolution, if available. 
			//		convert to QRS system data in Igor. Read Instrument group if availabel and stick in wave note, add title 
			//3.	2D is TBD as Irena cannot use it for now. Nika can, but I may not be able to finish this now. 
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	
		string OldDf=getDataFolder(1)
		string NewFileDataLocation = NEXUS_ImportAFile(FilePathName,Filename)			//import file as HFD5 in Igor 
		if(strlen(NewFileDataLocation)<1)
			Abort "Import of the data failed"
		else
			NewFileDataLocation+=":"						//needs ending ":" and it is not there...
		endif
		string AllSASentryData, AllSASdataData, SASentryName, SASdataName
		string tempSASEntryPath, tmpPath
		AllSASentryData = NEXUS_FindNXClassData(NewFileDataLocation, "NX_class=NXentry;canSAS_class=SASentry;")		//find path to all NXdata, but this can be 2D, 1D, 3D, or 4D data sets. 
					//these are all SAS entry - each is one data but possibly many SASdata of the same data
		string SASEntryNameOnly
		variable i, j, k
		string tempAttrStr
					//i will iterate over SASentries, j over SASdata inside each entry...
		variable FoundSasEntries
		For(i=0;i<ItemsInList(AllSASentryData,";");i+=1)		//SAS entry, likely sample name
			tempSASEntryPath = stringFromList(i,AllSASentryData,";")
			AllSASdataData = NEXUS_FindNXClassData(tempSASEntryPath, "NX_class=NXdata;canSAS_class=SASdata;")		//find path to all NXdata, but this can be 2D, 1D, 3D, or 4D data sets. 
								//note: 3D and 4D data which are not meaningful at this time... 
			Wave/T/Z DataTitle = $(tempSASEntryPath+"title")
			if(UseFileNameasFolder)		//selection if to use internal sample name in title or Filename as folder name. 
				SASentryName=(RemoveEnding(RemoveListItem(ItemsInList(Filename,".")-1,Filename,"."),"."))[0,28]
			elseif(UseTileNameAsFolder && WaveExists(DataTitle))
				SASentryName=(DataTitle[0])[0,28]
			else
				SASentryName=(stringFromList(ItemsInList(tempSASEntryPath,":")-1,tempSASEntryPath,":"))[0,28]
			endif
			FoundSasEntries = ItemsInList(AllSASdataData)*ItemsInList(AllSASentryData,";")
			For(j=0;j<ItemsInList(AllSASdataData);j+=1)			//SASdata, sectors, segments,... 				
				//need to load each indvidually...
				tmpPath = stringfromlist(j,AllSASdataData)
				//is it 1D or 2D data?
				tempAttrStr = NEXUS_GetNXAttributeInIgor(tmpPath, "I_axes")
				if(stringmatch(tempAttrStr,"Q"))		//1D data
					if(Read1D)
						NEXUS_ReadOne1DcanSASDataset(tmpPath, SASentryName, Filename, FoundSasEntries, InclNX_SasIns,InclNX_SASSam,InclNX_SASNote)	
					endif		
				elseif(stringmatch(tempAttrStr,"Q,Q"))	//2D data 
					if(Read2D)
						//future 2D data reading
					endif
				else
					Print "The type of data is not known for : "+tempAttrStr+" , I_axes are: "+tempAttrStr
				endif
			endfor
		endfor
		SetDataFolder OldDF
end

//*****************************************************************************************************************
//*****************************************************************************************************************
static Function/T NEXUS_ReadOne1DcanSASDataset(PathToDataSet, DataTitleStr, sourceFileName, FoundSasEntries, InclNX_SasIns,InclNX_SASSam,InclNX_SASNote)
	string PathToDataSet, DataTitleStr, sourceFileName
	variable InclNX_SasIns,InclNX_SASSam,InclNX_SASNote, FoundSasEntries

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFREF saveDFR = GetDataFolderDFR()		// Save
	SetDataFolder root:
	//now we are in the temp data place, we need to locate and copy these waves...
	string IName, QName, QdevName, IdevName, tmpStr, tmpFldrName

	NewDataFolder/O/S root:ImportedData
	//need to create location using File name, if the file contains more than one data set...
	if(FoundSasEntries>1)
		//NewDataFolder/O/S $("root:ImportedData:"+PossiblyQUoteName(CleanupName(DataTitleStr,1)))
		tmpStr=(RemoveEnding(RemoveListItem(ItemsInList(sourceFileName,".")-1,sourceFileName,"."),"."))[0,28]
		NewDataFolder/O/S $("root:ImportedData:"+PossiblyQUoteName(CleanupName(tmpStr,1)))			//use file name as input
	endif
	//create place for data
	NewDataFolder/O/S $(IN2G_RemoveExtraQuote(DataTitleStr,1,1))
	//need to add one more layer and in this case, it is the last item in the path
	string NewDataName = stringFromList(ItemsInList(PathToDataSet,":")-1,PathToDataSet, ":")
	NewDataName = IN2G_RemoveExtraQuote(NewDataName,1,1)
	NewDataName = ReplaceString("sasdata", NewDataName, "")			//sasdata is default name, not helpful for anything... 
//	if(strlen(NewDataName)>0 && !stringMatch(NewDataName[0,0],"_"))		//append _ between names, if there is some name left... 
///		NewDataName="_"+NewDataName
///	endif
	//NewDataName = CleanupName((DataTitleStr+NewDataName)[0,25],1)	
	if(strlen(NewDataName)>0)
		NewDataName = CleanupName((NewDataName)[0,25],1)	
		if(DataFolderExists(NewDataName ))
			tmpFldrName = UniqueName(NewDataName, 11, 0)
		else
			tmpFldrName = NewDataName
		endif
		NewDataFolder/O/S $(tmpFldrName)
	endif
	print "Created new data folder : "+ GetDataFOlder(1)
	string NewFolderFullPath=GetDataFolder(1)
	setDataFolder PathToDataSet
	//get basic waves, Q and I must be in attributes
	IName	  	= NEXUS_GetNXAttributeInIgor(PathToDataSet, "signal")
	QName		= NEXUS_GetNXAttributeInIgor(PathToDataSet, "I_axes")
	Wave/Z Iwv = $(IName)
	if(!WaveExists(Iwv))
		Wave/Z Iwv = $(IName+"0")		//I cannot be used as name, so in Igor it shoudl be I0
		if(!WaveExists(Iwv))
			Abort "Could not find I wave in : "+"NEXUS_ReadOne1DcanSASDataset function"
		endif	
	endif
	Wave/Z Qwv = $(QName)
	if(!WaveExists(Qwv))
		Wave/Z Qwv = $(QName+"0")		//I cannot be used as name, so in Igor it shoudl be I0
		if(!WaveExists(Qwv))
			Abort "Could not find Q wave in : "+"NEXUS_ReadOne1DcanSASDataset function"
		endif	
	endif
	IdevName	= NEXUS_GetNXAttributeInIgor(PathToDataSet, "I_uncertainties")	
	if(strlen(IdevName)<1)		//not there, hm... There is other way:
		tmpStr = note(Iwv)
		IdevName	= StringByKey("uncertainties", tmpStr, "=", "\r")
	endif
	Wave/Z IdevWv=$(IdevName)
	//This is in attribute to Q
	tmpStr = note(Qwv)
	QdevName	= StringByKey("resolutions", tmpStr, "=", "\r")
	Wave/Z QdevWv=$(QdevName)
	//basic waves shoudl be located.
	//copy them to new place using qrs naming system:
	//new name is q_NewDataName  etc...
	//string newNameShort=(DataTitleStr+NewDataName)
	DUplicate/O Iwv, $(NewFolderFullPath+PossiblyQuoteName(CleanupName("r_"+NewDataName[0,28],1)))
	Wave NewIwv=$(NewFolderFullPath+PossiblyQuoteName(CleanupName("r_"+NewDataName[0,28],1)))
	
	DUplicate/O Qwv, $(NewFolderFullPath+PossiblyQuoteName(CleanupName("q_"+NewDataName[0,28],1)))
	Wave NewQwv=$(NewFolderFullPath+PossiblyQuoteName(CleanupName("q_"+NewDataName[0,28],1)))
	//fix units, if needed... Following loosely what SASView is using... https://groups.google.com/forum/#!topic/cansas-dfwg/pItbRKXeFfE
	//https://www.google.com/url?q=https%3A%2F%2Fgithub.com%2FSasView%2Fsasview%2Fblob%2Fmaster%2Fsrc%2Fsas%2Fsascalc%2Fdata_util%2Fnxsunit.py&sa=D&sntz=1&usg=AFQjCNFYvjzNK4FalmyIKxi-lswwvv0QWQ
	string Qunits =  StringByKey("units", note(Qwv), "=", "\r")
	string ConversionFactorQ="no scaling done, assumed 1/angstrom"
	if(stringmatch(Qunits,"nm*")||stringmatch(Qunits,"1/nm")||stringmatch(Qunits,"n_m^-1"))		//assume Q in nm^-1, need to scale by 10x
		NewQwv/=10
		ConversionFactorQ = "10"
	elseif(stringmatch(Qunits,"cm*")||stringmatch(Qunits,"1/cm"))		//assume Q in cm^-1, need to scale by 10^8x
		NewQwv/=10^8
		ConversionFactorQ = "10^8"
	elseif(stringmatch(Qunits,"10^-3 angstrom^-1"))		//assume Q in 10^-3 A^-1, need to scale by 10^3x
		NewQwv/=10^3
		ConversionFactorQ = "10^3"
	elseif(stringmatch(Qunits,"m*")||stringmatch(Qunits,"1/m"))		//assume Q in m^-1, need to scale by 10^10x
		NewQwv/=10^10
		ConversionFactorQ = "10^10"
	elseif(stringmatch(Qunits,"invA*")||stringmatch(Qunits,"1/A*"))		// Q in 1/A
		//NewQwv*=10^10
		ConversionFactorQ = "1"
	else		//not matched to anything above? What is the damn unit? 
		//assume input is 1/A and do not change, e.g.: 'invA', 'invAng', 'invAngstroms', '1/A'
		ConversionFactorQ="units not identified, assume it is already 1/angstrom"
	endif
	//int units
	string Intunits =  StringByKey("units", note(Iwv), "=", "\r")
	if(stringmatch(Intunits,"1/cm*") || stringmatch(Intunits,"cm2/cm3") )		//assume 1/cm units. 
		Intunits="Units=cm2/cm3;"	
	elseif(stringmatch(Intunits,"cm2/g"))
		Intunits="Units=cm2/g;"	
	else				//assume arbitrary if(DataCalibratedArbitrary)
		Intunits="Units=Arbitrary;"	
	endif
	print "Imported data from  : "+ sourceFileName
	print "Created new I and Q data  : "+ PossiblyQuoteName(CleanupName("r_"+NewDataName[0,28],1)) +"   "+PossiblyQuoteName(CleanupName("q_"+NewDataName[0,28],1))
	print "Found Intensity units  : "+ StringByKey("units", note(Iwv), "=", "\r")+"   converted to : "+Intunits
	print "Found Q units  : "+ Qunits+ "   converted to [1/A] by scaling using conversion factor of : "+ConversionFactorQ


	if(WaveExists(IdevWv))
		DUplicate/O IdevWv, $(NewFolderFullPath+PossiblyQuoteName(CleanupName("s_"+NewDataName[0,28],1)))
		Wave NewIdevwv=$(NewFolderFullPath+PossiblyQuoteName(CleanupName("s_"+NewDataName[0,28],1)))
		print "Created new Idev data  : "+ PossiblyQuoteName(CleanupName("s_"+NewDataName[0,28],1)) 
	endif
	if(WaveExists(QdevWv))
		DUplicate/O QdevWv, $(NewFolderFullPath+PossiblyQuoteName(CleanupName("w_"+NewDataName[0,28],1)))
		Wave NewQdevwv=$(NewFolderFullPath+PossiblyQuoteName(CleanupName("w_"+NewDataName[0,28],1)))
		if(stringmatch(Qunits,"nm*"))		//assume Q in nm^-1, need to scale by 10x
			NewQdevwv*=10
		endif
		print "Created new Qres data  : "+ PossiblyQuoteName(CleanupName("w_"+NewDataName[0,28],1)) 
	endif
	//main wave exist.
	
	//now we need to get together some wave notes... 
	string WaveNoteStr="Imported_to_Irena="+date()+" "+time()+";"
	WaveNoteStr+="Imported_from_source="+sourceFileName+";"
	//title and definition are one level higher above the data.
	tmpStr = RemoveListItem(ItemsInList(PathToDataSet,":")-1, PathToDataSet, ":" )
	Wave/T/Z tmpWv=$(tmpStr +"title")
	if(WaveExists(tmpWv))
		WaveNoteStr+="NexusTitle="+tmpWv[0]+";"
	else
		print "Did not find Title in the file, this is non-standard, we will use file name instead of Title"
		WaveNoteStr+="NexusTitle="+sourceFileName+";"
	endif
	Wave/T/Z tmpWv=$(tmpStr+"definition")
	if(WaveExists(tmpWv))
		WaveNoteStr+="NexusDefinition="+tmpWv[0]+";"
	else
		print "Did not find NexusDefinition in the file, this is non-standard"	
	endif
	
	
	WaveNoteStr+=Intunits	
	//need to add stuff from NXinstrument. 
	if(InclNX_SasIns) 
		string NXinstrumentData=	NEXUS_FindNXClassData(tmpStr, "NX_class=NXinstrument;canSAS_class=SASinstrument;")		//find path to NXinstrument
		NXinstrumentData = RemoveEnding(NXinstrumentData, ";")
		WaveNoteStr+=NEXUS_CreateNoteFromFolder(NXinstrumentData)
	endif
	if(InclNX_SASSam) 
		string NXSampleData=	NEXUS_FindNXClassData(tmpStr, "NX_class=NXsample;canSAS_class=SASsample;")		//find path to NXinstrument
		NXSampleData = RemoveEnding(NXSampleData, ";")
		WaveNoteStr+=NEXUS_CreateNoteFromFolder(NXSampleData)
	endif
	if(InclNX_SASNote) 
		string NXNoteData=	NEXUS_FindNXClassData(tmpStr, "NX_class=NXnote;canSAS_class=SASnote;")		//find path to NXinstrument
		NXNoteData = RemoveEnding(NXNoteData, ";")
		WaveNoteStr+=NEXUS_CreateNoteFromFolder(NXNoteData)
	endif

	Note /K/NOCR NewIwv, WaveNoteStr 
	Note /K/NOCR NewQwv, "units=1/A;" 
	if(WaveExists(NewQdevwv))
		Note /K/NOCR NewQdevwv, "units=1/A;" 
	endif
	if(WaveExists(NewIdevwv))
		Note /K/NOCR NewIdevwv , Intunits
	endif

	SetDataFolder saveDFR		// and restore
	return NewDataName
end
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function/T  NEXUS_CreateNoteFromFolder(PathToFolder)
	string PathToFolder
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string/g root:Packages:Irena_Nexus:TmpStringForNote
	SVAR TmpStringForNote = root:Packages:Irena_Nexus:TmpStringForNote
	TmpStringForNote = ""
	IN2G_UniversalFolderScan(PathToFolder, 50, "NEXUS_CopyAllDataTOStringNote()")
	return TmpStringForNote
end
//*****************************************************************************************************************
Function NEXUS_CopyAllDataTOStringNote()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR TmpStringForNote = root:Packages:Irena_Nexus:TmpStringForNote
	string ALlItems=IN2G_CreateListOfItemsInFolder(GetDataFolder(1),2)
	variable i, WaveTypeNum
	string result="", tempName, tmpStr, tmpUnits
	For(i=0;i<ItemsInList(ALlItems);i+=1)
		tempName=stringFromList(i,ALlItems)
		if(!StringMatch(tempName, "Igor__*"))
			Wave/Z tmpWv=$(tempName)
			WaveTypeNum = WaveType(tmpWv,1)
			if ( WaveTypeNum>1)		//text wave
				Wave/T tmpTxtWv=$(tempName)
				result+=tempName+"="+tmpTxtWv[0]+";"
			elseif(WaveTypeNum==1)//num wave
				Wave tmpNumWv=$(tempName)
				result+=tempName+"="+num2str(tmpNumWv[0])+";"
				//try to store units...
				tmpStr = note(tmpNumWv)
				tmpUnits	= StringByKey("units", tmpStr, "=", "\r")
				if(strlen(tmpUnits)>0)
					result+=tempName+"_units="+tmpUnits+";"			
				endif
			else
			endif
		endif
	endfor
	TmpStringForNote += result
end


//*****************************************************************************************************************
//*****************************************************************************************************************
static Function/T NEXUS_GetNXAttributeInIgor(PathToFolder, AttributeStr)
	string PathToFolder, AttributeStr

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFREF saveDFR = GetDataFolderDFR()		// Save
	SetDataFolder $(PathToFolder)
	Wave/Z Igor___folder_attributes
	string tmpnote,result, tmpClass
	result = ""
	variable i, matches=1
	if(WaveExists(Igor___folder_attributes))
		tmpnote = note(Igor___folder_attributes)+"\r"		//uses + as key separators and \r as list separators
		result = StringByKey(AttributeStr, tmpnote,"=","\r")
	else
		Abort "Cannot find necessary Igor___folder_attributes"
	endif
	
	SetDataFolder saveDFR		// and restore
	return result
	
end

//*****************************************************************************************************************
//*****************************************************************************************************************
static Function/T NEXUS_FindNXClassData(DataPathStr, NXClassStr)
	string DataPathStr, NXClassStr
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
static Function/T NEXUS_IdentifyNxclassFolder(PathToData, ClassList)	//find location of all Groups/Folders with specific list of classes
	string PathToData, ClassList
	
	//e.g., 	ClassList = "NX_class=NXdata;canSAS_class=SASdata;"	- must match the Nexus spelling/format
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string oldDf=GetDataFolder(1)
	SetDataFolder $(PathToData)
	Wave/Z Igor___folder_attributes
	string tmpnote,result, tmpClass
	result = ""
	variable i, matches=1
	if(WaveExists(Igor___folder_attributes))
		tmpnote = note(Igor___folder_attributes)
		for(i=0;i<ItemsInList(ClassList);i+=1)
			tmpClass = stringFromList(i,ClassList)
			if(!GrepString(tmpnote,tmpClass))
				matches*=0
			endif
		endfor
	else
		Abort "Cannot find necessary Igor___folder_attributes"
	endif
	setDataFOlder OldDF
	if(matches)
		result+=PathToData+";"
	endif
	return result
end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function NEXUS_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr		
		//	SVAR NX_RebinCal2DDtToPnts=root:Packages:Convert2Dto1D:NX_RebinCal2DDtToPnts
			SVAR NX_Index1ProcessRule=root:Packages:Irena_Nexus:NX_Index1ProcessRule
			if(StringMatch(pa.ctrlName,"NX_RebinCal2DDtToPnts"))
			//	NX_RebinCal2DDtToPnts = popStr
			endif
			if(stringMatch(pa.ctrlName,"NX_Index1ProcessRule"))
				NX_Index1ProcessRule = popStr
			endif
			break
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
