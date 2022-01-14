#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version = 1.08
#pragma IgorVersion=8.03


//*************************************************************************\
//* Copyright (c) 2005 - 2022, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//this is tool to setup Sample Plates for USAXS, survey sample positions, and generate Command files. 

//1.08 add Export list of saved sets. Increased version number of the panel.   
//1.07 add IN3S_ImportFile which imports other command files. For nwo set for 12IDB command files. 
//1.06 add Import Image for iamge of sample plate. Straightens paralax and trims based on user corner selection and dimensions provided. 
//1.05 added Append to command file
//1.04 modifications to beamline survey with epics controls. 
//1.03 Remove for MatrixOP /NTHR=0 since it is applicable to 3D matrices only 
//1.02 Added checking if existing sate is saved to reduce number of dialogs user needs to deal with. 
//1.01 Added NMRAcrylicPlate
//1.0 September2020, first release. 
//0.6 many fixes
//0.4 developement, with beamline survey code... 


//************************************************************************************************************
//to add new plate:
//add in popup a name for it, create also wave/variable names 
//add in IN3S_CreateDefaultPlates
//add in IN3S_DrawImageOfPlate
//add to PopulateTabel button in IN3S_ButtonProc
//warnings..
//		SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
//		WarningForUser = "Could not records values for this positon, no row selected" 
//
//for epics support we need epics.xop https://sourceforge.net/p/igor2epics/wiki/Home/

//************************************************************************************************************

constant IN3_SamplePlateSetupVersion=1.08
constant IN3SBeamlineSurveyEpicsMonTicks = 15 
constant IN3SBeamlineSurveyDevelopOn = 0
//  values for beamtime estimate, last calibrated using BS on 7/31/2021 JIL (used 15 scan records BS).
//  result is about 2 minutes more than real time. 
constant IN3BmSrvUSAXSOverhead 		= 10		//overhead for flyscan
constant IN3BmSrvSAXSOverhead 		= 3			//overhead for SAXS, transmission measurement 
constant IN3BmSrvWAXSOverhead 		= 1			//overhead for WAXS 
constant IN3BmSrvSampleMoveSpeed 	= 2			//average moving samples around in mm/sec, is 4rev/sec
constant IN3BmSrvTuneTimeStep 		= 600		//retune every 600 seconds 
constant IN3BmSrvTuneTimeNumU 		= 3			//retune every 3 USAXS scans 
constant IN3BmSrvTuneAveTime  		= 40		//retune takes avergate 40 seconds full preUSAXStune is 40 seconds... 
constant IN3BmSrvSWTuneAveTime 		= 14		//SWAXS tune MR
constant IN3BmSrvMoveGeometryTime 	= 20		//overhead to move from USAXS to SAXS to WAXS


//TODO:
//		add "Saved & Dirty" flag to avoid some dialogs. 


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//****************************************************************************************
 

Function IN3S_SampleSetupMain()

	DFrEF OldDf=GetDataFolderDFR()

	IN3S_Initialize()
	IN3S_CreateDefaultPlates()
	KillWindow/Z TrimCorrectImageDrawing
	IN3S_CreateTablesForPlates(0, 0)
	IN3S_MainPanel()
	ING2_AddScrollControl()
	IN3_UpdatePanelVersionNumber("SamplePlateSetup", IN3_SamplePlateSetupVersion)
	IN3S_FixUSWAXSForAll()
	IN3S_UpdateListOfSavedSets()
	IN3S_AddTagToImage(-4)	//remove all drawings, if needed	
	SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
	WarningForUser = "Tool started... Report bugs and wishes to author!" 
	IN3S_EstimateRunTime()
	setDataFolder OldDf
end

//************************************************************************************************************
//************************************************************************************************************
Function IN3S_ExportHookFunction(listWaveG, LBSelectionWvG)
	wave listWaveG, LBSelectionWvG
	//  Modify this function as needed, for example comment out lines etc. 
	//  These are parameters: 
	//		IN3S_WriteListOfCommands(listWaveG, LBSelectionWvG, sxOffset, syOffset, TitleModifier)
	//	1. Keep the wave names listWaveG, LBSelectionWvG as they are. These contain info for all samples.  
	//	2. Change the sxOffset and syOffset [mm] (these values are added to the sx and sy in the table). 
	//	3. Change the TitleModifier, this is appended to the sample name. 
	//	4. make sure you have "Run Export Hook function" checkbox checked and compiled procedures. 
	//************************************************************************************************S
	//this measures right of center position 
	IN3S_WriteListOfCommands(listWaveG, LBSelectionWvG, -1, 0, "_R")
	//this measures top of center position 
	IN3S_WriteListOfCommands(listWaveG, LBSelectionWvG, 0, -1, "_T")
	//this measures left of center position 
	IN3S_WriteListOfCommands(listWaveG, LBSelectionWvG, 1, 0, "_L")
	//this measures bottom of center position 
	IN3S_WriteListOfCommands(listWaveG, LBSelectionWvG, 0, 1, "_B")
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IN3S_SaPlateCheckVersion()	
	DoWindow SamplePlateSetup
	if(V_Flag)
		if(!IN3_CheckPanelVersionNumber("SamplePlateSetup", IN3_SamplePlateSetupVersion))
			DoAlert /T="The Sample Plate setup panel was created by incorrect version of Indra " 1, "Sample Plate setup needs to be restarted to work properly. Restart now?"
			if(V_flag==1)
 				KillWIndow/Z SamplePlateSetup
				IN3S_SampleSetupMain()
			else		//at least reinitialize the variables so we avoid major crashes...
				IN3S_Initialize()
			endif
		endif
	endif
end
//************************************************************************************************************
//************************************************************************************************************


Function IN3S_MainPanel()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SamplePlateSetup
	DoWindow SamplePlateSetup
	if(V_Flag)
		DoWindow/F SamplePlateSetup
	else
		PauseUpdate    		// building window...
		NewPanel /K=1 /W=(2.25,43.25,590,725)/N=SamplePlateSetup as "Sample Plate setup"
		TitleBox Title title="\Zr210Sample Plate setup",pos={120,3},frame=0,fstyle=3,size={300,24},fColor=(1,4,52428), anchor=MC
		Button GetHelp,pos={490,25},size={80,15},fColor=(65535,32768,32768), proc=IN3S_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}
		//left size
		TitleBox Info1 title="\Zr120New positions : ",pos={10,35},size={250,15},frame=0,fColor=(0,0,65535),labelBack=0
		Button CreateNewSet,pos={10,55},size={150,17}, proc=IN3S_ButtonProc,title="Create New Sample Set", help={"Creates new set of sample positions"}
		Button AddMoreLines,pos={10,75},size={150,17}, proc=IN3S_ButtonProc,title="Add Sample Positions", help={"Adds more sample positions"}
		SetVariable NumberOfSamplesToCreate,pos={170,62},size={100,20}, limits={1, 500, 10}, proc=IN3S_SetVarProc,title="Lines = "
		Setvariable NumberOfSamplesToCreate,fStyle=2, variable=root:Packages:SamplePlateSetup:NumberOfSamplesToCreate, help={"How many sample positions to create"}
		TitleBox Info2 title="\Zr120Saved Sets : ",pos={10,95},size={250,15},frame=0,fColor=(0,0,65535),labelBack=0
		PopupMenu SelectSavedSet,pos={10,110},size={330,21},noproc,title="Select Saved set : ", help={"Select folder with saved set of data"}
		PopupMenu SelectSavedSet,mode=1,value= #"\"---;\"+IN3S_GenStringOfSets()"
		Button LoadSavedSet,pos={10,135},size={180,17}, proc=IN3S_ButtonProc,title="Load saved Positions Set", help={"Loads postions set saved before"}
	
		TitleBox Info3 title="\Zr120Templates : ",pos={300,32},size={250,15},frame=0,fColor=(0,0,65535),labelBack=0
		SVAR SelectedPlateName=root:Packages:SamplePlateSetup:SelectedPlateName
		PopupMenu NewPlateTemplate,pos={300,50},size={330,21},proc=IN3S_PopMenuProc,title="Template :", help={"Pick Plate template"}
		PopupMenu NewPlateTemplate,mode=1,popvalue=SelectedPlateName, fColor=(1,16019,65535)
		PopupMenu NewPlateTemplate,value="9x9 Acrylic/magnetic plate;NMR Acrylic plate;Old Style Al Plate;NMR Tubes holder;NMR tubes heater;Generic Grid holder;AgBehenateLaB6;"
		Button PopulateTable,pos={300,75},size={120,17}, proc=IN3S_ButtonProc,title="Populate Table", help={"Creates new set of positions"}
		Button ImportFile,pos={300,92},size={120,17}, proc=IN3S_ButtonProc,title="Import file", help={"Import file as new set of positions"}
		Button CreateImage,pos={440,75},size={120,17}, proc=IN3S_ButtonProc,title="Create image", help={"Creates image for survey of sample positions"}
		Button ImportImage,pos={440,92},size={120,17}, proc=IN3S_ButtonProc,title="Import image", help={"Import image for survey of sample positions"}
		Button BeamlineSurvey,pos={440,110},size={120,17}, proc=IN3S_ButtonProc,title="Beamline Survey", help={"This opens GUI for survey at the beamline"}

		TitleBox Info4 title="\Zr110Current set name : ",pos={300,110},size={250,15},frame=0,fColor=(0,0,65535),labelBack=0
		SetVariable UserNameForSampleSet,pos={300,130},size={270,20}, proc=IN3S_SetVarProc,title="Set Name: "
		Setvariable UserNameForSampleSet,fStyle=2, variable=root:Packages:SamplePlateSetup:UserNameForSampleSet, help={"Name for these samples"}
		Button SavePositionSet,pos={440,145},size={120,17}, proc=IN3S_ButtonProc,title="Save Position Set", help={"Saves set of positions with user name"}
		
   		TabControl TableTabs  pos={0,160},size={590,430},tabLabel(0)="Sample Table", value= 0, proc=IN3S_TableTabsTabProc
	    TabControl TableTabs  tabLabel(1)="Option Controls",tabLabel(2)="Export Controls"
		TitleBox Info20 title="\Zr080Use shift to select range of lines, ctrl/cmd select disjoint multiple lines",pos={5,590},size={400,10},frame=0,fColor=(0,0,65535),labelBack=0
		//Tab 0
			ListBox CommandsList,pos={8,185},size={573,395} //, special={0,0,1 }		//this will scale the width of column, users may need to slide right using slider at the bottom. 
			ListBox CommandsList,listWave=root:Packages:SamplePlateSetup:LBCommandWv
			ListBox CommandsList,selWave=root:Packages:SamplePlateSetup:LBSelectionWv
			ListBox CommandsList,proc=IN3S_ListBoxMenuProc, selRow= 0, editStyle= 0
			ListBox CommandsList userColumnResize=1,help={"Fill here list of samples, their positions, thickness etc. "}
			ListBox CommandsList titleWave=root:Packages:SamplePlateSetup:LBTtitleWv, frame= 2
			ListBox CommandsList widths={220,50,50,60,40,40,40,0}
			ListBox CommandsList  mode=9 		// mode=1 for single row selection, 4 multiple disjoint rows (shift only), mode=9 for shift conigous+ctrl disjoint.  
		//Tab 1
			TitleBox Info10 title="\Zr120Data Collection Controls ",size={250,15},pos={20,190},frame=0,fColor=(0,0,65535),labelBack=0
			CheckBox USAXSAll pos={30,220},size={70,20},title="USAXS All?", help={"Run USAXS for All"}
			CheckBox USAXSAll variable=root:Packages:SamplePlateSetup:USAXSAll, proc=IN3S_CheckProc
			CheckBox SAXSAll pos={30,250},size={70,20},title="SAXS All?", help={"Run SAXS for All"}
			CheckBox SAXSAll variable=root:Packages:SamplePlateSetup:SAXSAll,  proc=IN3S_CheckProc
			CheckBox WAXSAll pos={30,280},size={70,20},title="WAXS All?", help={"Run WAXS for All"}
			CheckBox WAXSAll variable=root:Packages:SamplePlateSetup:WAXSAll,  proc=IN3S_CheckProc
			SetVariable DefaultSampleThickness,pos={30,310},size={250,20},limits={0.01,20,0.1}, noproc,title="Default Sample thickness [mm]: "
			Setvariable DefaultSampleThickness,fStyle=2, variable=root:Packages:SamplePlateSetup:DefaultSampleThickness, help={"Thickness if not defined."}


			SVAR ExportOrder=root:Packages:SamplePlateSetup:ExportOrder
			PopupMenu ExportOrderPop,pos={30,340},size={350,21},proc=IN3S_PopMenuProc,title="Export order  :      ", help={"Pick order of scans to export"}
			PopupMenu ExportOrderPop,mode=1,popvalue=ExportOrder
			PopupMenu ExportOrderPop,value="USAXS-SAXS-WAXS;SAXS-WAXS-USAXS;USAXS-WAXS-SAXS;"

			CheckBox RunExportHookFunction pos={30,375},size={90,20},title="Run Export hook function? ", help={"Run export hook function"}
			CheckBox RunExportHookFunction variable=root:Packages:SamplePlateSetup:RunExportHookFunction,  noproc

			Button DisplayHookFunction,pos={300,370},size={240,20}, proc=IN3S_ButtonProc,title="Display Hook Function", help={"Displays hook function for user"}

			TitleBox Tab1Info1 title="\Zr130These values are used only for beamtime calculation. They are not exported in command file.",pos={30,420},size={550,15},frame=0,fstyle=1,fColor=(65535,0,0),labelBack=0

			SetVariable USAXSScanTime,pos={30,440},size={250,20},limits={30,360,15}, proc=IN3S_SetVarProc,title="USAXS time for run time estimate = "
			Setvariable USAXSScanTime,fStyle=2, variable=root:Packages:SamplePlateSetup:USAXSScanTime, help={"USAXS time from epics, used to calculate run time."}
			SetVariable SAXSScanTime,pos={30,460},size={250,20},limits={1,60,5}, proc=IN3S_SetVarProc,title="SAXS time for run time estimate   = "
			Setvariable SAXSScanTime,fStyle=2, variable=root:Packages:SamplePlateSetup:SAXSScanTime, help={"SAXS time from epics, used to calculate run time."}
			SetVariable WAXSScanTime,pos={30,480},size={250,20},limits={1,60,5}, proc=IN3S_SetVarProc,title="WAXS time for run time estimate  = "
			Setvariable WAXSScanTime,fStyle=2, variable=root:Packages:SamplePlateSetup:WAXSScanTime, help={"WAXS time from epics, used to calculate run time."}

	

			SetVariable DefaultCommandFileName,pos={100,550},size={450,25},noproc,title="Default Command file name : "
			Setvariable DefaultCommandFileName,fStyle=2, variable=root:Packages:SamplePlateSetup:DefaultCommandFileName, help={"usaxs.mac typically, or user name if wanted."}

			//GUI controls, rigth side
			TitleBox Info11 title="\Zr120GUI Controls ",size={250,15},pos={340,190},frame=0,fColor=(0,0,65535),labelBack=0
			CheckBox DisplayUSWAXScntrls pos={340,220},size={70,20},title="Display Individ Controls?", help={"Individual U-S-WAXS controls per sample"}
			CheckBox DisplayUSWAXScntrls variable=root:Packages:SamplePlateSetup:DisplayUSWAXScntrls,  proc=IN3S_CheckProc
			CheckBox DisplayAllSamplesInImage pos={340,250},size={90,20},title="Display all samples in image? ", help={"Add to image all defined sample positiosn"}
			CheckBox DisplayAllSamplesInImage variable=root:Packages:SamplePlateSetup:DisplayAllSamplesInImage,  proc=IN3S_CheckProc
		//Tab 2 Export controls
			CheckBox ExportCurrentPosSet pos={120,187},size={120,20},title="Export Current set? ", help={"Check to export current set in the table only"}
			CheckBox ExportCurrentPosSet variable=root:Packages:SamplePlateSetup:ExportCurrentPosSet,  proc=IN3S_CheckProc, mode=1
			CheckBox ExportListOfPosSets pos={320,187},size={120,20},title="Export list of sets below? ", help={"Check to export list of sets per list below"}
			CheckBox ExportListOfPosSets variable=root:Packages:SamplePlateSetup:ExportListOfPosSets,  proc=IN3S_CheckProc, mode=1

			TitleBox Tab2Info1 title="\Zr110Drag saved position from here : ",pos={60,210},size={250,15},frame=0,fColor=(0,0,65535),labelBack=0
			TitleBox Tab2Info2 title="\Zr110Drop here in order of export : ",pos={350,210},size={250,15},frame=0,fColor=(0,0,65535),labelBack=0
			ListBox SourceBox,pos={20,230},size={250,300} , listwave=root:Packages:SamplePlateSetup:ListOfSavedSetsWv
		    ListBox SourceBox, selwave=root:Packages:SamplePlateSetup:SelListOfSavedSetsWv, mode=9, focusring=0
		    ListBox SourceBox, Proc=IN3S_DragDropListBoxProc
		    ListBox TargetBox, pos={300,230},size={250,300}, listwave=root:Packages:SamplePlateSetup:ListOfWavesForExport
		    ListBox TargetBox, selwave=root:Packages:SamplePlateSetup:SelListOfWavesForExport, mode=9, focusring=0
		    ListBox TargetBox, Proc=IN3S_DragDropListBoxProc
			TitleBox Tab2Info5 title="\Zr110Make sure you saved the current Positions set !!!! The button needs to be green. ",pos={100,540},size={550,15},frame=0,fstyle=1,fColor=(65535,0,0),labelBack=0
			TitleBox Tab2Info3 title="Drag a Set from left to right listbox. You can use sets multiple times.",pos={120,555},size={550,15},frame=0,fColor=(0,0,65535),labelBack=0
			TitleBox Tab2Info4 title="Delete a Set from right listbox with right click. ",pos={160,570},size={550,15},frame=0,fColor=(0,0,65535),labelBack=0
				

		//controls under the table
		//save export
		Button PreviewCommandFile,pos={260,595},size={140,20}, proc=IN3S_ButtonProc,title="Preview cmd file", help={"Creates and displays command file with current set of positions"}
		Button ExportCommandFile,pos={415,595},size={160,20}, proc=IN3S_ButtonProc,title="Export cmd file", help={"Exports usaxs.mac or defaultname.mac cmd file with current set of positions"}
		Button AppendToCommandFile,pos={415,620},size={160,20}, proc=IN3S_ButtonProc,title="Append to cmd file", help={"Appends to command file on desktop"}
		Button ExportCommandFile2,pos={415,645},size={160,20}, proc=IN3S_ButtonProc,title="Dialog Export cmd file", help={"Dialog - Exports cmd file with current set of positions"}

		Setvariable NumberOfSamples title="\Zr100Samples: ",pos={10,610},size={150,15},frame=0,fstyle=3,fColor=(0,0,65535),valueColor=(0,0,0), labelBack=0, noedit=1
		Setvariable NumberOfSamples,variable=root:Packages:SamplePlateSetup:NumberOfSamples, help={"Number of used saples"}, limits={0,inf,0}


		Setvariable CalculatedOverAllTime title="\Zr120Estimated run time [min]: ",pos={10,628},size={220,15},frame=0,fstyle=3,fColor=(0,0,65535),valueColor=(0,0,0), labelBack=0, noedit=1
		Setvariable CalculatedOverAllTime,variable=root:Packages:SamplePlateSetup:CalculatedOverAllTime, help={"Estimated run time for all"}, limits={0,inf,0}

		Setvariable Warnings title="\Zr120Last Info/Warning: ",pos={10,662},size={550,15},frame=0,fstyle=3,fColor=(0,0,65535),valueColor=(65535,0,0), labelBack=0, noedit=1
		Setvariable Warnings,variable=root:Packages:SamplePlateSetup:WarningForUser, help={"Last warning which code issued"}

	endif
	IN3S_FixTabControl()

end
//*****************************************************************************************************************
//*****************************************************************************************************************

FUnction IN3S_FixSaveButton()

	NVAR TableIsSaved = root:Packages:SamplePlateSetup:TableIsSaved
	string TitleStr
	if(TableIsSaved>0.5)
		TitleStr = "Positions saved"
		Button SavePositionSet,win=SamplePlateSetup, fColor=(32792,65535,1)
		Button SavePositionSet,win=SamplePlateSetup,title=TitleStr, disable=2*TableIsSaved
	else
		TitleStr = "Save Position Set" 
		Button SavePositionSet,win=SamplePlateSetup, fColor=(65535,32768,32768)
		Button SavePositionSet,win=SamplePlateSetup,title=TitleStr, disable=2*TableIsSaved
	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function/T IN3S_GenStringOfSets()
	
	string ListOfQFolders
	string result
	if(DataFolderExists("root:SavedSampleSets:"))
		result=IN2G_CreateListOfItemsInFolder("root:SavedSampleSets:", 1)
	else
		result=""
	endif
	return result
end


//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN3S_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			if(stringMatch(sva.ctrlname,"UserNameForSampleSet"))
				SVAR UserNameForSampleSet = root:Packages:SamplePlateSetup:UserNameForSampleSet
				UserNameForSampleSet = CleanupName(sval, 0)
			endif

			if(stringMatch(sva.ctrlname,"USAXSScanTime")||stringMatch(sva.ctrlname,"SAXSScanTime")||stringMatch(sva.ctrlname,"WAXSScanTime"))
				IN3S_EstimateRunTime()
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//*****************************************************************************************************************
///******************************************************************************************
static Function IN3S_FixTabControl()
	
	variable CurTab
	ControlInfo /W=SamplePlateSetup TableTabs
	CurTab=V_Value
	STRUCT WMTabControlAction tca
	tca.eventCode =2
	tca.tab = CurTab
    IN3S_TableTabsTabProc(tca)


end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IN3S_TableTabsTabProc(tca) : TabControl
	STRUCT WMTabControlAction &tca

	switch( tca.eventCode )
		case 2: // mouse up
			Variable tab = tca.tab
			//tab 0
			ListBox CommandsList, win=SamplePlateSetup, disable=(tab!=0)
			//tab 1
			CheckBox USAXSAll,  win=SamplePlateSetup, disable=(tab!=1)
			CheckBox SAXSAll,  win=SamplePlateSetup, disable=(tab!=1)
			CheckBox WAXSAll,  win=SamplePlateSetup, disable=(tab!=1)
			SetVariable DefaultSampleThickness,  win=SamplePlateSetup, disable=(tab!=1)
			TitleBox Info10,  win=SamplePlateSetup, disable=(tab!=1)
			TitleBox Info11,  win=SamplePlateSetup, disable=(tab!=1)
			CheckBox DisplayUSWAXScntrls,  win=SamplePlateSetup, disable=(tab!=1)
			CheckBox DisplayAllSamplesInImage,  win=SamplePlateSetup, disable=(tab!=1)
			SetVariable DefaultCommandFileName,  win=SamplePlateSetup, disable=(tab!=1)
			CheckBox RunExportHookFunction,  win=SamplePlateSetup, disable=(tab!=1)
			SetVariable USAXSScanTime,  win=SamplePlateSetup, disable=(tab!=1)
			SetVariable SAXSScanTime,  win=SamplePlateSetup, disable=(tab!=1)
			SetVariable WAXSScanTime,  win=SamplePlateSetup, disable=(tab!=1)
			Button DisplayHookFunction,  win=SamplePlateSetup, disable=(tab!=1)
			PopupMenu ExportOrderPop,  win=SamplePlateSetup, disable=(tab!=1)
			TitleBox Tab1Info1,  win=SamplePlateSetup, disable=(tab!=1)
			
			CheckBox ExportCurrentPosSet,  win=SamplePlateSetup, disable=(tab!=2)
			CheckBox ExportListOfPosSets,  win=SamplePlateSetup, disable=(tab!=2)
			NVAR ExportListOfPosSets=root:Packages:SamplePlateSetup:ExportListOfPosSets
			NVAR ExportCurrentPosSet=root:Packages:SamplePlateSetup:ExportCurrentPosSet
			TitleBox Tab2Info1,  win=SamplePlateSetup, disable=(tab!=2||ExportCurrentPosSet)
			TitleBox Tab2Info2,  win=SamplePlateSetup, disable=(tab!=2||ExportCurrentPosSet)
			TitleBox Tab2Info3,  win=SamplePlateSetup, disable=(tab!=2||ExportCurrentPosSet)
			TitleBox Tab2Info4,  win=SamplePlateSetup, disable=(tab!=2||ExportCurrentPosSet)
			TitleBox Tab2Info5,  win=SamplePlateSetup, disable=(tab!=2||ExportCurrentPosSet)
			ListBox SourceBox,  win=SamplePlateSetup, disable=(tab!=2||ExportCurrentPosSet)
		    ListBox TargetBox,  win=SamplePlateSetup, disable=(tab!=2||ExportCurrentPosSet)
			IN3S_EstimateRunTime()
			IN3S_UpdateListOfSavedSets()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
//************************************************************************************************************
Function/S IN3S_CreateListOfRows(wave selWave)
	//create list of selected rows (from end) 
	string ListOfSelRows=""
	variable i
	For(i=DimSize(selWave,0)-1;i>=0;i-=1)
		if(selWave[i][0]==3||selWave[i][0]==10)
			ListOfSelRows+=num2str(i)+";"
		endif
	endfor
	return ListOfSelRows
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IN3S_ListBoxMenuProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba
	//see IRB1_ConcSeriesListBoxProc

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable row = lba.row
	Variable col = lba.col
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave
	string WinNameStr=lba.win
	string items
	variable i
	NVAR/Z TableIsSaved = root:Packages:SamplePlateSetup:TableIsSaved
	if(!NVAR_Exists(TableIsSaved))
		variable/g root:Packages:SamplePlateSetup:TableIsSaved
		NVAR TableIsSaved = root:Packages:SamplePlateSetup:TableIsSaved
	endif
	string ListOfSelRows
	variable tempRow, j, firstSelectedRow, NoSelectedRows
	SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
	
	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
  			ListOfSelRows=IN3S_CreateListOfRows(selWave)
  			firstSelectedRow = str2num(StringFromList(ItemsInList(ListOfSelRows)-1, ListOfSelRows))
  			NoSelectedRows = ItemsInList(ListOfSelRows)
  			
			if (lba.eventMod & 0x10)	// rightclick
				//items = "Insert new lines;Delete selected lines;Duplicate selected Lines;Set lines as Blank;Set as Dist. Std. AgBehLaB6;Write same Name;"
				//items += "Write same Thickness;Same Sx to all empty;Same Sy to all empty;Increment Sx from selected row;Increment Sy from selected row;"
				//items += "Copy sel. rows to Clipboard;Paste Clipboard to sel. rows;Insert new rows with Clipboard vals.;"
				items = "Copy sel. rows to Clipboard;Paste Clipboard to sel. rows;Insert new rows with Clipboard vals.;"
				items += "Insert new lines;Delete selected lines;Duplicate selected Lines;Write same Name;"
				items += "Write same Thickness;Same Sx to all empty;Same Sy to all empty;Increment Sx from selected row;Increment Sy from selected row;"
				items += "Add to Sx from selected row;Add to Sy from selected row;Set lines as Blank;Set as Dist. Std. AgBehLaB6;"
				PopupContextualMenu items
				// V_flag is index of user selected item    
				switch (V_flag)
					case 1:	// "Copy in Table Clipboard"
						make/O/T/N=(NoSelectedRows) root:Packages:SamplePlateSetup:TableClipboardWv
						Wave/T TableClipboardWv = root:Packages:SamplePlateSetup:TableClipboardWv
						SVAR TableClipboard = root:Packages:SamplePlateSetup:TableClipboard
						For(j=0;j<NoSelectedRows;j+=1)
							tempRow = str2num(StringFromList(j, ListOfSelRows))
							TableClipboard = "SampleName="+listWave[tempRow][0]+";"
							TableClipboard += "SX="+listWave[tempRow][1]+";"
							TableClipboard += "SY="+listWave[tempRow][2]+";"
							TableClipboard += "TH="+listWave[tempRow][3]+";"
							TableClipboard += "MD="+listWave[tempRow][4]+";"
							TableClipboardWv[j] = TableClipboard
						endfor
						SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
						WarningForUser = "Copied rows "+ListOfSelRows+ " in Clipboard" 
						break;
					case 2:	// "Paste Table Clipboard in a row"
						Wave/T/Z TableClipboardWv = root:Packages:SamplePlateSetup:TableClipboardWv
						//check we have clipboard...
						if(!WaveExists(TableClipboardWv)||numpnts(TableClipboardWv)<1)
							Abort "Nothing is stored in Clipboard"
						endif
						//check we have same number of lines selected. 
						if(numpnts(TableClipboardWv)>1 && NoSelectedRows!=numpnts(TableClipboardWv))
							Abort "Number of lines in Clipboard ("+num2str(numpnts(TableClipboardWv))+") does not match number of selected lines in table ("+num2str(NoSelectedRows)+")"
						endif
						//OK, now we should be able to do this... 
						SVAR TableClipboard = root:Packages:SamplePlateSetup:TableClipboard
						For(j=0;j<NoSelectedRows;j+=1)
							if(numpnts(TableClipboardWv)>1)
								TableClipboard = TableClipboardWv[j]
							else
								TableClipboard = TableClipboardWv[0]
							endif
							tempRow = str2num(StringFromList(j, ListOfSelRows))
							listWave[tempRow][0] = StringByKey("SampleName", TableClipboard, "=" , ";")
							listWave[tempRow][1] = StringByKey("SX", TableClipboard, "=" , ";")
							listWave[tempRow][2] = StringByKey("SY", TableClipboard, "=" , ";")
							listWave[tempRow][3] = StringByKey("TH", TableClipboard, "=" , ";")
							listWave[tempRow][4] = StringByKey("USAXS", TableClipboard, "=" , ";")
							listWave[tempRow][5] = StringByKey("SAXS", TableClipboard, "=" , ";")
							listWave[tempRow][6] = StringByKey("WAXS", TableClipboard, "=" , ";")
							listWave[tempRow][7] = StringByKey("MD", TableClipboard, "=" , ";")
						endfor
						SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
						WarningForUser = "Pasted Clipboard vals. from org. rows "+ListOfSelRows
						IN3S_EstimateRunTime()
						TableIsSaved = 0
						break;
					case 3:	// "Insert New rows with Table Clipboard"
						Wave/T/Z TableClipboardWv = root:Packages:SamplePlateSetup:TableClipboardWv
						//check we have clipboard...
						if(!WaveExists(TableClipboardWv)||numpnts(TableClipboardWv)<1)
							Abort "Nothing is stored in Clipboard"
						endif
						SVAR TableClipboard = root:Packages:SamplePlateSetup:TableClipboard
						For(j=0;j<numpnts(TableClipboardWv);j+=1)
							TableClipboard = TableClipboardWv[j]
							tempRow = firstSelectedRow+1
							IN3S_InsertDeleteLines(1, tempRow,1)
							listWave[tempRow][0] = StringByKey("SampleName", TableClipboard, "=" , ";")
							listWave[tempRow][1] = StringByKey("SX", TableClipboard, "=" , ";")
							listWave[tempRow][2] = StringByKey("SY", TableClipboard, "=" , ";")
							listWave[tempRow][3] = StringByKey("TH", TableClipboard, "=" , ";")
							listWave[tempRow][4] = StringByKey("USAXS", TableClipboard, "=" , ";")
							listWave[tempRow][5] = StringByKey("SAXS", TableClipboard, "=" , ";")
							listWave[tempRow][6] = StringByKey("WAXS", TableClipboard, "=" , ";")
							listWave[tempRow][7] = StringByKey("MD", TableClipboard, "=" , ";")
						endfor
						SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
						WarningForUser = "Inserted "+num2str(numpnts(TableClipboardWv))+" rows with Clipboard (org. rows: "+ListOfSelRows+") "
						IN3S_EstimateRunTime()
						TableIsSaved = 0
						break;
					case 4:	// "Insert new line"
						For(j=0;j<ItemsInList(ListOfSelRows);j+=1)
							tempRow = str2num(StringFromList(j, ListOfSelRows))
							IN3S_InsertDeleteLines(1, tempRow,1)
						endfor
						WarningForUser = "Inserted rows after numbers "+ ListOfSelRows
						IN3S_EstimateRunTime()
						TableIsSaved = 0
						break
					case 5:	// "Delete selected lines"
						For(j=0;j<ItemsInList(ListOfSelRows);j+=1)
							tempRow = str2num(StringFromList(j, ListOfSelRows))
							IN3S_InsertDeleteLines(2, tempRow,1)
						endfor
						WarningForUser = "Deleted rows numbers "+ ListOfSelRows
						IN3S_EstimateRunTime()
						TableIsSaved = 0
						break
					case 6:	// "Duplicate selected Line"
						For(j=0;j<ItemsInList(ListOfSelRows);j+=1)
							tempRow = str2num(StringFromList(j, ListOfSelRows))
							IN3S_InsertDeleteLines(3, tempRow,1)
						endfor
						WarningForUser = "Duplicated rows numbers "+ ListOfSelRows
						IN3S_EstimateRunTime()
						TableIsSaved = 0
						break
					case 7:	// "Write same name"
						string NewSampleName="SampleName"
						string FromWhere = "Selected Rows"
						string AddOrderNumber = "No"
						Prompt NewSampleName, "Write same string in names"
						Prompt FromWhere, "Where to write?", popup "Selected Rows;Empty only;From first selected row;All;"
						Prompt AddOrderNumber, "Add Order numbers (0,1,2,3...)?", popup "No;Yes;"
						DoPrompt /Help="Write same string name" "Default name for all positions", NewSampleName, FromWhere, AddOrderNumber
						if(V_Flag)
							abort
						endif
						string NameStrtemp2=""
						string OrderNumStr=""
						variable OrderNumber=0
						For(i=0;i<DimSize(listWave,0);i+=1)
							if(StringMatch(FromWhere, "Empty only"))
								if(strlen(listWave[i][0])==0)
									if(StringMatch(AddOrderNumber, "Yes"))
										OrderNumStr=num2str(OrderNumber)
										OrderNumber+=1
									endif
									if(strlen(NewSampleName)>0)	
										listWave[i][0] = CleanupName(NewSampleName, 0 , 40)+OrderNumStr
									else
										listWave[i][0] = ""+OrderNumStr
									endif
								endif
							elseif(StringMatch(FromWhere, "From first selected row"))
								if(i>=firstSelectedRow)
									if(StringMatch(AddOrderNumber, "Yes"))
										OrderNumStr=num2str(OrderNumber)
										OrderNumber+=1
									endif
									if(strlen(NewSampleName)>0)	
										listWave[i][0] = CleanupName(NewSampleName, 0 , 40)+OrderNumStr
									else
										listWave[i][0] = ""+OrderNumStr
									endif
								endif
							elseif(StringMatch(FromWhere, "All"))
									if(StringMatch(AddOrderNumber, "Yes"))
										OrderNumStr=num2str(OrderNumber)
										OrderNumber+=1
									endif
									if(strlen(NewSampleName)>0)	
										listWave[i][0] = CleanupName(NewSampleName, 0 , 40)+OrderNumStr
									else
										listWave[i][0] = ""+OrderNumStr
									endif
							elseif(StringMatch(FromWhere, "Selected Rows"))
									For(j=0;j<ItemsInList(ListOfSelRows);j+=1)
										if(StringMatch(AddOrderNumber, "Yes"))
											OrderNumStr=num2str(ItemsInList(ListOfSelRows)-j-1)
											//OrderNumber+=1
										endif
										if(strlen(NewSampleName)>0)	
											NameStrtemp2 = CleanupName(NewSampleName, 0 , 40)+OrderNumStr
										else
											NameStrtemp2 = ""+OrderNumStr
										endif
										tempRow = str2num(StringFromList(j, ListOfSelRows))
										listWave[tempRow][0]=NameStrtemp2
									endfor
							else
								//nothing here... 
							endif
						endfor
						SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
						WarningForUser = "Wrote "+CleanupName(NewSampleName, 0 , 40)+" names as requested" 
						IN3S_EstimateRunTime()
						TableIsSaved = 0
						break;
					case 8:	// "Write Same Thickness"
						variable newThickness
						NVAR DefSaTh = root:Packages:SamplePlateSetup:DefaultSampleThickness
						newThickness = DefSaTh
						Prompt newThickness, "New Thickness [mm] or NaN for empty"
						string FromWhere2 = "Selected Rows"
						Prompt FromWhere2, "Where to write?", popup "Selected Rows;Empty only;From first selected row;All;"
						DoPrompt /Help="Write new thickness?" "New thickness and where selection", newThickness, FromWhere2
						if(V_Flag)
							abort
						endif
						For(i=0;i<DimSize(listWave,0);i+=1)
							if(StringMatch(FromWhere2, "Empty only"))
								if(strlen(listWave[i][3])==0)
									if(numtype(newThickness)==0)
										listWave[i][3] = num2str(newThickness)
									else
										listWave[i][3] = ""
									endif
								endif
							elseif(StringMatch(FromWhere2, "From first selected row"))
								if(i>=firstSelectedRow)
									if(numtype(newThickness)==0)
										listWave[i][3] = num2str(newThickness)
									else
										listWave[i][3] = ""
									endif
								endif
							elseif(StringMatch(FromWhere2, "All"))
									if(numtype(newThickness)==0)
										listWave[i][3] = num2str(newThickness)
									else
										listWave[i][3] = ""
									endif
							elseif(StringMatch(FromWhere2, "Selected Rows"))
									For(j=0;j<ItemsInList(ListOfSelRows);j+=1)
										tempRow = str2num(StringFromList(j, ListOfSelRows))
										if(numtype(newThickness)==0)
											listWave[tempRow][3] = num2str(newThickness)
										else
											listWave[tempRow][3] = ""
										endif
									endfor
							else
								//nothing here... 
							endif
						endfor
						TableIsSaved = 0
						break;						
					case 9:	// "same sx to all empty"
						variable  NewSxForAll=10
						Prompt NewSxForAll, "Write same SX in all empty lines?"
						DoPrompt /Help="Write same SX position for all empty SX?" "Default sx value for all", NewSxForAll
						if(V_Flag)
							abort
						endif
						For(i=0;i<DimSize(listWave,0);i+=1)
							if(strlen(listWave[i][1])==0)
								listWave[i][1] = num2str(NewSxForAll)
							endif
						endfor
						SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
						WarningForUser = "Wrote "+num2str(NewSxForAll)+" for all samples without SX" 
						IN3S_EstimateRunTime()
						TableIsSaved = 0
						break;
					case 10:	// "same sy to all empty"
						variable  NewSyForAll=10
						Prompt NewSyForAll, "Write same SY in all empty lines?"
						DoPrompt /Help="Write same SY position for all empty SY?" "Default sy value for all", NewSyForAll
						if(V_Flag)
							abort
						endif
						For(i=0;i<DimSize(listWave,0);i+=1)
							if(strlen(listWave[i][2])==0)
								listWave[i][2] = num2str(NewSyForAll)
							endif
						endfor
						SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
						WarningForUser = "Wrote "+num2str(NewSyForAll)+" for all samples without SX" 
						IN3S_EstimateRunTime()
						TableIsSaved = 0
						break;
					case 11:	// "Increment Sx from selected row"
						variable  NewSxStep=10
						variable sxstart
						Prompt NewSxStep, "Increment SX from first selected row higher?"
						DoPrompt /Help="Increment SX position for all higher rows?" "Input sx step", NewSxStep
						if(V_Flag)
							abort
						endif
						if(numtype(str2num(listWave[firstSelectedRow][1]))==0)
							sxstart = str2num(listWave[firstSelectedRow][1])
						else
							sxstart = 0
						endif
						For(i=firstSelectedRow;i<DimSize(listWave,0);i+=1)
							listWave[i][1] = num2str(sxstart+(i-firstSelectedRow)*NewSxStep)
						endfor
						SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
						WarningForUser = "Calculated new sx for row higher than : " +num2str(row) 
						IN3S_EstimateRunTime()
						TableIsSaved = 0
						break;
					case 12:	// "Increment Sy from selected row"
						variable  NewSyStep=10
						variable systart
						Prompt NewSyStep, "Increment SY from selected row higher?"
						DoPrompt /Help="Increment SY position for all higher rows?" "Input sy step", NewSyStep
						if(V_Flag)
							abort
						endif
						if(numtype(str2num(listWave[firstSelectedRow][2]))==0)
							systart = str2num(listWave[firstSelectedRow][2])
						else
							systart = 0
						endif
						For(i=firstSelectedRow;i<DimSize(listWave,0);i+=1)
							listWave[i][2] = num2str(systart+(i-firstSelectedRow)*NewSyStep)
						endfor
						SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
						WarningForUser = "Calculated new sy for all samples" 
						IN3S_EstimateRunTime()
						TableIsSaved = 0
						break;
					case 13:	// "Add to sx from first selected row"
						variable  AddValue=0
						Prompt AddValue, "Add value to Sx from first selected row ?"
						DoPrompt /Help="Add value SX position for all higher rows?" "Add value to sx", AddValue
						if(V_Flag)
							abort
						endif
						//if(numtype(str2num(listWave[firstSelectedRow][1]))==0)
						//	sxstart = str2num(listWave[firstSelectedRow][1])
						//else
						//	sxstart = 0
						//endif
						For(i=firstSelectedRow;i<DimSize(listWave,0);i+=1)
							listWave[i][1] = num2str(str2num(listWave[i][1])+AddValue)
						endfor
						SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
						WarningForUser = "Calculated new sx for row higher than : " +num2str(row) 
						IN3S_EstimateRunTime()
						TableIsSaved = 0
						break;
					case 14:	// "Add to sy from first selected row"
						variable  AddValueY=0
						Prompt AddValueY, "Add value to Sy from first selected row ?"
						DoPrompt /Help="Add value Sy position for all higher rows?" "Add value to Sy", AddValueY
						if(V_Flag)
							abort
						endif
						For(i=firstSelectedRow;i<DimSize(listWave,0);i+=1)
							listWave[i][2] = num2str(str2num(listWave[i][2])+AddValueY)
						endfor
						SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
						WarningForUser = "Calculated new sy for row higher than : " +num2str(row) 
						IN3S_EstimateRunTime()
						TableIsSaved = 0
						break;
					case 15:	// "Set line as Blank"
						For(j=0;j<ItemsInList(ListOfSelRows);j+=1)
							tempRow = str2num(StringFromList(j, ListOfSelRows))
							listWave[tempRow][0]="Blank"
							listWave[tempRow][3]="0"
						endfor
						WarningForUser = "Set rows "+ListOfSelRows+" as Blank" 
						IN3S_EstimateRunTime()
						TableIsSaved = 0
						break
					case 16:	// "Set Line as Distance Standard"
						For(j=0;j<ItemsInList(ListOfSelRows);j+=1)
							tempRow = str2num(StringFromList(j, ListOfSelRows))
							listWave[tempRow][0]="AgBehenateLaB6"
							listWave[tempRow][3]="1"
						endfor
						WarningForUser = "Set rows "+ListOfSelRows+" as AgBehenateLaB6" 
						NVAR USAXSAll=root:Packages:SamplePlateSetup:USAXSAll
						USAXSAll=0
						IN3S_EstimateRunTime()
						TableIsSaved = 0
						break
					default :	// "Sort"
						//DataSelSortString = StringFromList(V_flag-1, items)
						//PopupMenu SortOptionString,win=$(TopPanel), mode=1,popvalue=DataSelSortString
						//IR3C_SortListOfFilesInWvs(TopPanel)	
						break;
				endswitch
			else	//left click, do something here... 

			endif
			IN3S_FixSaveButton()
			break
		case 3: // double click

			break
		case 4: // cell selection
			IN3S_AddTagToImage(row)
			//sync to Bealine setup, if exists...
			DoWIndow BeamlinePlateSetup
			if(V_Flag)
				NVAR SelectedRow=root:Packages:SamplePlateSetup:SelectedRow
				SVAR SelectedSampleName=root:Packages:SamplePlateSetup:SelectedSampleName
				Wave/T ListWV = root:Packages:SamplePlateSetup:LBCommandWv
				Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
				NVAR SampleThickness=root:Packages:SamplePlateSetup:SampleThickness
				NVAR SampleXTAR=root:Packages:SamplePlateSetup:SampleXTAR
				NVAR SampleYTAR=root:Packages:SamplePlateSetup:SampleYTAR
				NVAR SampleXTable = root:Packages:SamplePlateSetup:SampleXTable
				NVAR SampleYTable = root:Packages:SamplePlateSetup:SampleYTable
				NVAR defTh=root:Packages:SamplePlateSetup:DefaultSampleThickness
				if(row>=0&& row<DimSize(ListWV, 0))
					SelectedRow=row
					SelectedSampleName = ListWV[SelectedRow][0]
					//ListBox CommandsList, win=SamplePlateSetup, selrow=SelectedRow
					LBSelectionWv[][0]=2
					LBSelectionWv[SelectedRow][0]=3
					SampleXTable = str2num(ListWV[SelectedRow][1])
					SampleYTable = str2num(ListWV[SelectedRow][2])
					SampleThickness = str2num(ListWV[SelectedRow][3])
					SampleThickness = numtype(SampleThickness)==0 ? SampleThickness : defTh
				endif
				IN3S_MoveToPositionIfOK()
			endif
			break
		case 5: // cell selection plus shift key
			break
		case 6: // begin edit
			break
		case 7: // finish edit
			//cleanup the name, if Column 0
			if(col==0)
				string Username=listWave[row][col]
				if(strlen(Username)>0)
					listWave[row][col] = CleanupName(Username, 0 , 40)
					DoWIndow BeamlinePlateSetup
					if(V_Flag)
						SVAR SelectedSampleName = root:Packages:SamplePlateSetup:SelectedSampleName
						SelectedSampleName = listWave[row][col]
					endif
				endif
			endif
			//cleanup the numbers for sx, sy and thickness...
			if(col>0 && col<4)		
				string valueStrFromUser=listWave[row][col]
				if(strlen(valueStrFromUser)>0)
					variable valueNumFromUser = str2num(valueStrFromUser)
					if(numtype(valueNumFromUser)==0)	//something is number... 
						listWave[row][col] = num2str(IN2G_roundDecimalPlaces(valueNumFromUser,3))
						DoWIndow BeamlinePlateSetup
						if(V_Flag)
							NVAR SampleXTable = root:Packages:SamplePlateSetup:SampleXTable
							NVAR SampleYTable = root:Packages:SamplePlateSetup:SampleYTable
							NVAR Thick=root:Packages:SamplePlateSetup:SampleThickness
							if(col==1)
								SampleXTable = IN2G_roundDecimalPlaces(valueNumFromUser,2)
								IN3S_MoveToPositionIfOK()
							elseif(col==2)
								SampleYTable = IN2G_roundDecimalPlaces(valueNumFromUser,2)
								IN3S_MoveToPositionIfOK()
							elseif(col==3)
								Thick = IN2G_roundDecimalPlaces(valueNumFromUser,3)
							endif
						endif
					else
						listWave[row][col] = ""
						Abort "Input was not valid number, try again"
					endif
				endif
			endif
			//add tag
			IN3S_AddTagToImage(row)
			IN3S_EstimateRunTime()
			TableIsSaved = 0
			IN3S_FixSaveButton()
			break
		case 13: // checkbox clicked (Igor 6.2 or later)
			//here we need to deal with what happens when user clicks on selection of checkboxes...
			NVAR USAXSAll = root:Packages:SamplePlateSetup:USAXSAll
			NVAR SAXSAll = root:Packages:SamplePlateSetup:SAXSAll
			NVAR WAXSAll = root:Packages:SamplePlateSetup:WAXSAll 
			if(lba.col==4)	//USAXS
				USAXSAll = 0
			elseif(lba.col==5)	//SAXS
				SAXSAll = 0
			elseif(lba.col==6)	//WAXS
				WAXSAll = 0
			else
			
			endif
			break
	endswitch

	return 0
end
//************************************************************************************************************
//************************************************************************************************************

Function IN3S_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(StringMatch(pa.ctrlName, "NewPlateTemplate"))
				SVAR SelectedPlateName=root:Packages:SamplePlateSetup:SelectedPlateName
				SelectedPlateName = popStr
			endif

			if(StringMatch(pa.ctrlName, "ExportOrderPop"))
				SVAR ExportOrder=root:Packages:SamplePlateSetup:ExportOrder
				ExportOrder = popStr
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************
//************************************************************************************************************

Function IN3S_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			NVAR TableIsSaved = root:Packages:SamplePlateSetup:TableIsSaved

			if(StringMatch(ba.ctrlName, "CreateNewSet" ))
				DoAlert/T="This will delete your existing data" 1,  "New Sample positions will be created and existing one deleted, Do you want to continue?"
				if(V_Flag==1)	//yes...
					NVAR NumberOfSamplesToCreate = root:Packages:SamplePlateSetup:NumberOfSamplesToCreate
					IN3S_CreateTablesForPlates(NumberOfSamplesToCreate, 1)
					SVAR NewPlateName = root:Packages:SamplePlateSetup:UserNameForSampleSet
					NewPlateName = "NewSampleSet"+num2str(abs(round(gnoise(100))))
					//ListBox CommandsList win=SamplePlateSetup, selRow=0					
					Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
					LBSelectionWv[][0]=2
					LBSelectionWv[0][0]=3
					IN3S_AddTagToImage(0)		
					SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
					WarningForUser = "Created a new set of positions" 
					IN3S_EstimateRunTime()
					TableIsSaved = 0
				endif
			endif
			if(StringMatch(ba.ctrlName, "CreateImage" ))
				KillWindow/Z TrimCorrectImageDrawing
				SVAR SelectedPlateName = root:Packages:SamplePlateSetup:SelectedPlateName
				IN3S_DrawImageOfPlate(SelectedPlateName)
				AutoPositionWindow/M=0 /R=SamplePlateSetup SamplePlateImageDrawing
				Wave/T LBCommandWv = root:Packages:SamplePlateSetup:LBCommandWv
				ControlInfo/W=SamplePlateSetup CommandsList
				if(V_Flag>=0 && V_Flag<dimsize(LBCommandWv,0))
					IN3S_AddTagToImage(V_Value)	
				else
					IN3S_AddTagToImage(-4)	//remove all drawings, if needed	
				endif
			endif

			if(StringMatch(ba.ctrlName, "TrimImportedImage" ))
				IN3S_TrimAndStraightenImage()
			endif

			if(StringMatch(ba.ctrlName, "ImportImage" ))
				KillWindow/Z TrimCorrectImageDrawing
				IN3S_ImportImageOfPlate()
			endif
			if(StringMatch(ba.ctrlName, "ImportFile" ))
				//KillWindow/Z TrimCorrectImageDrawing
				IN3S_ImportFile()
			endif

			if(StringMatch(ba.ctrlName, "DisplayHookFunction" ))
				//DisplayProcedure "IN3S_ExportHookFunction"
				IN3_InsertHookIntoMainProc()
			endif


			if(StringMatch(ba.ctrlName, "PopulateTable" ))
				//populate table with positions
				DoAlert/T="This will delete your existing data" 1,  "New Sample positions will be created and existing one deleted, Do you want to continue?"
				if(V_Flag==1)	//yes...
					KillWindow/Z TrimCorrectImageDrawing
					SVAR SelectedPlateName=root:Packages:SamplePlateSetup:SelectedPlateName
					NVAR USAXSAll=root:Packages:SamplePlateSetup:USAXSAll
					NVAR SAXSAll=root:Packages:SamplePlateSetup:SAXSAll
					NVAR WAXSAll=root:Packages:SamplePlateSetup:WAXSAll
					SVAR NewPlateName = root:Packages:SamplePlateSetup:UserNameForSampleSet
					SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
					USAXSAll= 1
					SAXSAll = 1
					WAXSAll = 1
					Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
					strswitch (SelectedPlateName) 
						case "9x9 Acrylic/magnetic plate":	 
							Wave Centers = root:Packages:SamplePlatesAvailable:Acrylic9x9PlateCenters
			 				//create enough space:
							IN3S_CreateTablesForPlates(DimSize(Centers, 0 ), 0)
							Wave/T LBCommandWv = root:Packages:SamplePlateSetup:LBCommandWv
							LBCommandWv[][1]=num2str(Centers[p][0])
							LBCommandWv[][2]=num2str(Centers[p][1])
							LBCommandWv[][0]=""
							LBCommandWv[0][0]="Empty for LaB6AgBehehnate"
							LBCommandWv[1][0]="AirBlank"
							NewPlateName = "AcrylicPlateSet"+num2str(abs(round(gnoise(100))))
							//select first row
							LBSelectionWv[][0]=2
							LBSelectionWv[0][0]=3
							WarningForUser = "Created a new set of positions for "+ SelectedPlateName
							IN3S_EstimateRunTime()
							break		// exit from switch
						case "NMR Acrylic plate":	 
							Wave Centers = root:Packages:SamplePlatesAvailable:AcrylicNMRPlateCenters
			 				//create enough space:
							IN3S_CreateTablesForPlates(DimSize(Centers, 0 ), 0)
							Wave/T LBCommandWv = root:Packages:SamplePlateSetup:LBCommandWv
							LBCommandWv[][1]=num2str(Centers[p][0])
							LBCommandWv[][2]=num2str(Centers[p][1])
							LBCommandWv[][0]=""
							LBCommandWv[0][0]="Empty for LaB6AgBehehnate"
							LBCommandWv[1][0]="NMRTubeBlank"
							//SVAR NewPlateName = root:Packages:SamplePlateSetup:UserNameForSampleSet
							NewPlateName = "AcrylicPlateSet"+num2str(abs(round(gnoise(100))))
							//select first row
							//ListBox CommandsList win=SamplePlateSetup, selRow=1					
							LBSelectionWv[][0]=2
							LBSelectionWv[0][0]=3
							//SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
							WarningForUser = "Created a new set of positions for "+ SelectedPlateName
							IN3S_EstimateRunTime()
							break		// exit from switch
						case "Old Style Al Plate":	 
							Wave Centers = root:Packages:SamplePlatesAvailable:OldStyleAlPlateCenters
			 				//create enough space:
							IN3S_CreateTablesForPlates(DimSize(Centers, 0 ), 0)
							Wave/T LBCommandWv = root:Packages:SamplePlateSetup:LBCommandWv
							LBCommandWv[][1]=num2str(Centers[p][0])
							LBCommandWv[][2]=num2str(Centers[p][1])
							LBCommandWv[][0]=""
							LBCommandWv[0][0]="Empty for LaB6AgBehehnate"
							LBCommandWv[1][0]="AirBlank"
							//SVAR NewPlateName = root:Packages:SamplePlateSetup:UserNameForSampleSet
							NewPlateName = "AlPlateSet"+num2str(abs(round(gnoise(100))))
							ListBox CommandsList win=SamplePlateSetup, selRow=1					
							//SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
							WarningForUser = "Created a new set of positions for "+ SelectedPlateName
							IN3S_EstimateRunTime()
							break		// exit from switch
						case "NMR Tubes holder":	 
							Wave Centers = root:Packages:SamplePlatesAvailable:NMRTubesHolderCenters
			 				//create enough space:
							IN3S_CreateTablesForPlates(DimSize(Centers, 0 ), 0)
							Wave/T LBCommandWv = root:Packages:SamplePlateSetup:LBCommandWv
							LBCommandWv[][0]=""
							LBCommandWv[][1]=num2str(Centers[p][0])
							LBCommandWv[][2]=num2str(Centers[p][1])
							//SVAR NewPlateName = root:Packages:SamplePlateSetup:UserNameForSampleSet
							NewPlateName = "NMRTubesSet"+num2str(abs(round(gnoise(100))))
							ListBox CommandsList win=SamplePlateSetup, selRow=1					
							//SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
							WarningForUser = "Created a new set of positions for "+ SelectedPlateName
							IN3S_EstimateRunTime()
							break		// exit from switch
						case "NMR Tubes heater":	 
							Wave Centers = root:Packages:SamplePlatesAvailable:NMRTubesHolderCenters
			 				//create enough space:
							IN3S_CreateTablesForPlates(DimSize(Centers, 0 ), 0)
							Wave/T LBCommandWv = root:Packages:SamplePlateSetup:LBCommandWv
							LBCommandWv[][0]=""
							LBCommandWv[][1]=num2str(Centers[p][0])
							LBCommandWv[][2]=num2str(Centers[p][1])
							//SVAR NewPlateName = root:Packages:SamplePlateSetup:UserNameForSampleSet
							NewPlateName = "NMRTubesSet"+num2str(abs(round(gnoise(100))))
							ListBox CommandsList win=SamplePlateSetup, selRow=1					
							//SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
							WarningForUser = "Created a new set of positions for "+ SelectedPlateName
							IN3S_EstimateRunTime()
							break		// exit from switch
						case "Generic Grid holder":	 
							Wave Centers = root:Packages:SamplePlatesAvailable:GenericGridHolderCenters
							//get from user needed information
							variable SX0=0, SY0=0, NX=5, NY=5, DX=10, DY=10
							Prompt SX0, "Input sx for first center: "
							Prompt SY0, "Input sy for first center: "
							Prompt NX, "Number of points horizontal : "
							Prompt NY, "Number of points vertical   : "
							Prompt DX, "Step in x (horizontal) : "
							Prompt DY, "Step in y (vertical)   : "
							DoPrompt "Define grid start, point numebrs and steps", SX0, SY0, NX, NY, DX, DY
							if(V_Flag)
								abort
							endif
							redimension/N=(NX*NY,2) Centers
							variable i, j, ict
							ict=0
							FOr(i=0;i<NX;i+=1)
								For(j=0;j<NY;j+=1)
									Centers[ict][0]=SX0+i*DX
									Centers[ict][1]=SY0+j*DY
									ict+=1
								endfor
							endfor
							IN3S_CreateTablesForPlates(DimSize(Centers, 0 ), 0)
							Wave/T LBCommandWv = root:Packages:SamplePlateSetup:LBCommandWv
							LBCommandWv[][1]=num2str(Centers[p][0])
							LBCommandWv[][2]=num2str(Centers[p][1])
							LBCommandWv[][0]=""
							LBCommandWv[0][0]=""
							LBCommandWv[1][0]=""
							SVAR NewPlateName = root:Packages:SamplePlateSetup:UserNameForSampleSet
							NewPlateName = "GenericPlateSet"+num2str(abs(round(gnoise(100))))
							//ListBox CommandsList win=SamplePlateSetup, selRow=1					
							LBSelectionWv[][0]=2
							LBSelectionWv[0][0]=3
							//SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
							WarningForUser = "Created a new set of positions for "+ SelectedPlateName
							IN3S_EstimateRunTime()
							break		// exit from switch
						case "AgBehenateLaB6":	 
							IN3S_CreateTablesForPlates(1, 1)
							Wave/T LBCommandWv = root:Packages:SamplePlateSetup:LBCommandWv
							Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
							LBCommandWv[][0]="AgBehenateLaB6"
							LBCommandWv[][1]="20"
							LBCommandWv[][2]="20"
							LBCommandWv[][3]="1"
							LBSelectionWv[][4]=32
							LBSelectionWv[][5]=48
							LBSelectionWv[][6]=48
							//SVAR NewPlateName = root:Packages:SamplePlateSetup:UserNameForSampleSet
							NewPlateName = "Standard"
							//NVAR USAXSAll=root:Packages:SamplePlateSetup:USAXSAll
							USAXSAll=0
							//SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
							WarningForUser = "Created AgBehenateLaB6 and disabled USAXS"
							break		// exit from switch
						case "Image":	
							//nothing to do here... 
							//here is code which loads image and deal with that. this will be different code and complciated.
							
							break
						case "Another Plate":	
								//	<code>
							break
						default:			
						//	<code>]		// when no case matches
					endswitch
					IN3S_AddTagToImage(-4)	//remove all drawings, if needed	
					TableIsSaved = 0
				endif			
			endif

			if(StringMatch(ba.ctrlName, "AddMoreLines" ))
				NVAR NewLines=root:Packages:SamplePlateSetup:NumberOfSamplesToCreate
				IN3S_InsertDeleteLines(4, 0, NewLines)	
				SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
				WarningForUser = "Added "+num2str(NewLines)+" new lines"
				IN3S_EstimateRunTime()
				TableIsSaved = 0
			endif
			if(StringMatch(ba.ctrlName, "SavePositionSet" ))
				IN3S_SaveCurrentSampleSet(0,1)				
				SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
				WarningForUser = "Saved set of positions"
				TableIsSaved = 1
			endif
			if(StringMatch(ba.ctrlName, "LoadSavedSet" ))
				ControlInfo /W=SamplePlateSetup  SelectSavedSet
				string SelectedFolder=S_Value
				if(StringMatch(SelectedFolder, "---" ))
					return 0
				endif
				if(TableIsSaved<0.5)
					DoAlert/T="This will overwrite your existing set of positions !!! " 1,  "Existing set is not saved! New set of Sample positions will be created and existing one deleted. Do you want to continue?"
					if(V_Flag==1)	//yes...
						//KillWIndow/Z SamplePlateImageDrawing
						IN3S_LoadSavedSampleSet()
					endif
				else
					IN3S_LoadSavedSampleSet()		
				endif
				SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
				WarningForUser = "Loaded set of positions for "+SelectedFolder
				IN3S_EstimateRunTime()
				TableIsSaved = 1
			endif
			if(StringMatch(ba.ctrlName, "PreviewCommandFile" ))
				IN3S_CheckForSensibility()
				IN3S_WriteCommandFile(1,1)
				SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
				WarningForUser = "Created Notebook with commands for review"
			endif
			string newName
			if(StringMatch(ba.ctrlName, "ExportCommandFile" ))
				//here we need to save that notebook somewhere
				newName = IN3S_ExportMacroFile(0,0)
				SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
				WarningForUser = "Exported usaxs.mac on your desktop"
				IN3_FTPUSAXSMacFile()
			endif
			if(StringMatch(ba.ctrlName, "ExportCommandFile2" ))
				//here we need to save that notebook somewhere
				newName = IN3S_ExportMacroFile(1,0)
				if(strlen(newName)>0)
					SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
					WarningForUser = "Exported command file as "+newName
				else
					SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
					WarningForUser = "Command file export was cancelled"
				endif
			endif
			if(StringMatch(ba.ctrlName, "AppendToCommandFile" ))
				newName = IN3S_ExportMacroFile(0,1)
				if(strlen(newName)>0)
					SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
					WarningForUser = "Appended to command file "+newName
					IN3_FTPUSAXSMacFile()
				else
					SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
					WarningForUser = "Append To Command file export was cancelled"
				endif
			endif

			if(StringMatch(ba.ctrlName, "BeamlineSurvey" ))
				KillWindow/Z TrimCorrectImageDrawing
				IN3S_BeamlineSurvey()
			endif
			if(StringMatch(ba.ctrlName, "GetHelp" ))
			//https://saxs-igorcodedocs.readthedocs.io/en/latest/Indra/SamplePlateSurvey.html
			//Open www manual with the right page
			IN2G_OpenWebManual("Indra/SamplePlateSurvey.html")
			endif

			IN3S_FixSaveButton()
			
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End
//************************************************************************************************************
static Function IN3_InsertHookIntoMainProc()
	//figure out if we have the hook function in main package or already in main Proc window
	string FuncInfo = FunctionInfo("IN3S_ExportHookFunction")
	//PROCWIN:IN3_SamplePlate.ipf
	if(StringMatch(StringByKey("PROCWIN", FuncInfo), "IN3_SamplePlate.ipf" ))
		//original location, need to create override function. Or   
	    String currScrap = GetScrapText()      	// copy current scrap text
	    DisplayProcedure/W=Procedure			
	    DoIgorMenu "Edit" "Select All"
	    DoIgorMenu "Edit" "Copy"
	    string existingProCode=GetScrapText()	// modify procedure code
  		String newCode = existingProCode + "\r\roverride "+ProcedureText("IN3S_ExportHookFunction") // modify procedure code
	    PutScrapText newCode				 	// new code in clipboard... 
	    DoIgorMenu "Edit" "Paste"			 	//put in main proc window. 
	    PutScrapText currScrap               	// put previous scrap text back
	    Execute/P/Q/Z "COMPILEPROCEDURES "   	// recompile all
	    HideProcedures                       	// hide all procedure windows
	endif
    DisplayProcedure/W=Procedure
    //DisplayProcedure "IN3S_ExportHookFunction"
End
//************************************************************************************************************

Function IN3_FTPUSAXSMacFile()
	//look for ftp batch file and if available and instrument is not running, upload usaxs.mac from desktop. 

	GetfileFolderInfo/Q/Z "C:Users:usaxs:Documents:WinSCP:putUSAXSMacFile.bat"
	if(V_Flag!=0)
		return 0
	else
		GetfileFolderInfo/Q/Z "C:Users:usaxs:Desktop:usaxs.mac"
		if(V_Flag!=0)
			DoAlert /T="sftp error" 0, "usaxs.mac was not found on the desktop" 
		else
			IN3S_BeramlineSurveyAbortIfNeeded("Cannot sftp usaxs.mac")				//this will abort if instrument is running. 
			DoAlert /T="Sftp usaxs.mac to usaxscontrol?" 1, "Do you want to sftp new usaxs.mac to usaxscontrol? Existing one will be overwritten!"
			if(V_Flag==1)
				ExecuteScriptText /W=5 "\"C:\\Users\\usaxs\\Documents\\WinSCP\\putUSAXSMacFile.bat\""
			endif
		endif
	
	endif

end
//************************************************************************************************************
//************************************************************************************************************


Function IN3S_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
			Wave/T LBCommandWv = root:Packages:SamplePlateSetup:LBCommandWv
			NVAR WAXSAll = root:Packages:SamplePlateSetup:WAXSAll
			NVAR USAXSAll = root:Packages:SamplePlateSetup:USAXSAll
			NVAR SAXSAll = root:Packages:SamplePlateSetup:SAXSAll
			NVAR ExportCurrentPosSet = root:Packages:SamplePlateSetup:ExportCurrentPosSet
			NVAR ExportListOfPosSets = root:Packages:SamplePlateSetup:ExportListOfPosSets
			
			STRUCT WMTabControlAction tca

			if(stringmatch(cba.ctrlName,"ExportCurrentPosSet"))
				ExportListOfPosSets = !ExportCurrentPosSet
				tca.eventCode=2
				tca.tab = 2
				IN3S_TableTabsTabProc(tca)
			endif
			if(stringmatch(cba.ctrlName,"ExportListOfPosSets"))
				ExportCurrentPosSet = !ExportListOfPosSets
				tca.eventCode=2
				tca.tab = 2
				IN3S_TableTabsTabProc(tca)
			endif
			if(stringmatch(cba.ctrlName,"USAXSAll"))
				if(USAXSAll)
					LBSelectionWv[][4]=48
				else
					LBSelectionWv[][4]=32
				endif
				IN3S_EstimateRunTime()
			endif
			if(stringmatch(cba.ctrlName,"SAXSAll"))
				if(SAXSAll)
					LBSelectionWv[][5]=48
				else
					LBSelectionWv[][5]=32
				endif
				IN3S_EstimateRunTime()
			endif
			if(stringmatch(cba.ctrlName,"WAXSAll"))
				if(WAXSAll)
					LBSelectionWv[][6]=48
				else
					LBSelectionWv[][6]=32
				endif
				IN3S_EstimateRunTime()
			endif
			if(stringmatch(cba.ctrlName,"DisplayUSWAXScntrls"))
				IN3S_FixUSWAXSForAll()
				if(checked)
					WAXSAll  = 0
					USAXSAll = 0
					SAXSAll  = 0 
				else
					WAXSAll  = 1
					USAXSAll = 1
					SAXSAll  = 1 
				endif
			endif
			if(stringmatch(cba.ctrlName,"DisplayAllSamplesInImage"))
				Wave/T listWave=root:Packages:SamplePlateSetup:LBCommandWv
				if(checked)
					IN3S_AddTagToImage(dimSize(listWave,0)-1)
				else
					ControlInfo/W=SamplePlateSetup CommandsList
					if(V_Flag>=0 && V_Flag<dimsize(LBCommandWv,0))
						IN3S_AddTagToImage(V_Flag)	
					else
						IN3S_AddTagToImage(0)	//remove all drawings, if needed	
						LBSelectionWv[][0]=2
						LBSelectionWv[0][0]=3
						//ListBox CommandsList, win=SamplePlateSetup, selRow= 0
					endif
				endif
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************
//************************************************************************************************************
static Function IN3S_FixUSWAXSForAll()

	NVAR USAXSAll = root:Packages:SamplePlateSetup:USAXSAll
	NVAR SAXSAll = root:Packages:SamplePlateSetup:SAXSAll
	NVAR WAXSAll = root:Packages:SamplePlateSetup:WAXSAll
	NVAR DiasplyCheckb = root:Packages:SamplePlateSetup:DisplayUSWAXScntrls
	Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
	Wave/T LBTtitleWv = root:Packages:SamplePlateSetup:LBTtitleWv
	variable USAXSWidth, SAXSWidth, WAXSWidth, MDwidth
	//LBTtitleWv = {"Sample Name", "X [mm]", "Y [mm]", "Thick [mm]", "USAXS", "SAXS", "WAXS", "Metadata"}
	//now set the columns based on what is checked... 
	if(DiasplyCheckb)	//display checkboxes...
		LBTtitleWv[4]="USAXS"
		USAXSWidth = 40	
		LBTtitleWv[5]="SAXS"
		SAXSWidth = 40
		LBTtitleWv[6]="WAXS"
		WAXSWidth = 40
		LBTtitleWv[7]="MD"
		MDwidth = 40
	else
		LBTtitleWv[4]=""
		USAXSWidth = 0	
		LBTtitleWv[5]=""
		SAXSWidth = 0
		LBTtitleWv[6]=""
		WAXSWidth = 0
		LBTtitleWv[7]=""
		MDwidth = 0
	endif
	ListBox CommandsList win=SamplePlateSetup, widths={220,50,50,60,USAXSWidth,SAXSWidth,WAXSWidth,MDwidth}
end
//************************************************************************************************************
//************************************************************************************************************
static Function IN3S_LoadSavedSampleSet([folderToLoad])
	string folderToLoad

	DFrEF OldDf=GetDataFolderDFR()
	string SelectedFolder
	if(ParamIsDefault(folderToLoad))
		ControlInfo /W=SamplePlateSetup  SelectSavedSet
		SelectedFolder=S_Value
		if(StringMatch(SelectedFolder, "---" ))
			SetDataFolder OldDf	
			abort
		endif
	else
		SelectedFolder = folderToLoad
	endif
	if(DataFolderExists("root:SavedSampleSets:"))
		setDataFolder root:SavedSampleSets:
		if(DataFolderExists(SelectedFolder))
			SetDataFolder SelectedFolder
			Wave/T listWave
			Wave LBSelectionWv
			Wave/T LBTtitleWv
			NVAR USAXSAll
			NVAR SAXSAll
			NVAR WAXSAll
			//these are global ones... 
			Wave/T listWaveG=root:Packages:SamplePlateSetup:LBCommandWv
			Wave LBSelectionWvG= root:Packages:SamplePlateSetup:LBSelectionWv
			Wave/T LBTtitleWvG  = root:Packages:SamplePlateSetup:LBTtitleWv
			NVAR USAXSAllG = root:Packages:SamplePlateSetup:USAXSAll
			NVAR SAXSAllG = root:Packages:SamplePlateSetup:SAXSAll
			NVAR WAXSAllG = root:Packages:SamplePlateSetup:WAXSAll
			//and write the values...
			USAXSAllG = USAXSAll
			SAXSAllG = SAXSAll
			WAXSAllG = WAXSAll
			redimension/N=(DimSize(listWave,0), DimSize(listWave,1)) listWaveG, LBSelectionWvG
			LBSelectionWvG = LBSelectionWv
			listWaveG = listWave
			LBTtitleWvG =  LBTtitleWv
			print "Restored settings from folder "+GetDataFolder(1)
			SVAR NewPlateName = root:Packages:SamplePlateSetup:UserNameForSampleSet
			NewPlateName = SelectedFolder
		endif
	endif	
	SetDataFolder OldDf	
end
//************************************************************************************************************
//************************************************************************************************************

static Function IN3S_SaveCurrentSampleSet(Overwrite, AddToList)
	variable Overwrite, AddToList

	DFrEF OldDf=GetDataFolderDFR()
		Wave/T listWaveG   =  root:Packages:SamplePlateSetup:LBCommandWv
		Wave LBSelectionWvG= root:Packages:SamplePlateSetup:LBSelectionWv
		Wave/T LBTtitleWvG  = root:Packages:SamplePlateSetup:LBTtitleWv
		NVAR USAXSAllG = root:Packages:SamplePlateSetup:USAXSAll
		NVAR SAXSAllG = root:Packages:SamplePlateSetup:SAXSAll
		NVAR WAXSAllG = root:Packages:SamplePlateSetup:WAXSAll
		SVAR NewPlateName = root:Packages:SamplePlateSetup:UserNameForSampleSet
		NewPlateName = CleanupName(NewPlateName, 1)  
		newDatafolder/O/S root:SavedSampleSets
		string newUniqueName
		if(DataFolderExists(NewPlateName)&& !Overwrite)
			DoAlert /T="This name is already used" 2, "Saved named set exists, Overwite(Yes) - Make Name unique (No) - Cancel"
			if(V_Flag==3)
				SetDataFolder OldDf
				abort
			elseif(V_Flag==2)
				newUniqueName= UniqueName(NewPlateName, 11, 1)
			elseif(V_Flag==1)
				newUniqueName = NewPlateName
				KillDataFolder $(newUniqueName)
			endif	
		else
		 	newUniqueName = NewPlateName
			if(Overwrite)
				KillDataFolder/Z $(newUniqueName)
			endif
		endif
		NewDataFOlder/O/S $(newUniqueName)
		variable/g USAXSAll
		USAXSAll = USAXSAllG
		variable/g SAXSAll
		SAXSAll = SAXSAllG
		variable/g WAXSAll
		WAXSAll = WAXSAllG
		Duplicate/O listWaveG, listWave
		Duplicate/O LBSelectionWvG, LBSelectionWv
		Duplicate/O LBTtitleWvG, LBTtitleWv
		print "Stored settings in folder "+GetDataFolder(1)
		
		PopupMenu SelectSavedSet,win=SamplePlateSetup, mode=1,value= #"\"---;\"+IN3S_GenStringOfSets()"
		//add this to list in waves for multi export
		if(AddToList)
			IN3S_UpdateListOfSavedSets()
			//Wave/T ListOfSavedSetsWv=root:Packages:SamplePlateSetup:ListOfSavedSetsWv
			//Wave SelListOfSavedSetsWv=root:Packages:SamplePlateSetup:SelListOfSavedSetsWv
			//variable OldLength=numpnts(ListOfSavedSetsWv)
			//redimension/N=(OldLength+1) ListOfSavedSetsWv, SelListOfSavedSetsWv
			//ListOfSavedSetsWv[OldLength] = newUniqueName
		endif
	SetDataFolder OldDf	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IN3S_UpdateListOfSavedSets()

	DFrEF OldDf=GetDataFolderDFR()
	Wave/T ListOfSavedSetsWv=root:Packages:SamplePlateSetup:ListOfSavedSetsWv
	Wave SelListOfSavedSetsWv=root:Packages:SamplePlateSetup:SelListOfSavedSetsWv
	string ListOfSavedSetsStr
	variable i
	if(DataFolderExists("root:SavedSampleSets"))
		SetDataFolder root:SavedSampleSets
		DFrEF SavedSetsDRF=GetDataFolderDFR()
		ListOfSavedSetsStr = DataFolderList("*", ";", SavedSetsDRF)
		variable NewLength=ItemsInList(ListOfSavedSetsStr)
		redimension/N=(NewLength) ListOfSavedSetsWv, SelListOfSavedSetsWv
		SelListOfSavedSetsWv = 0
		For(i=0;i<NewLength;i+=1)
			ListOfSavedSetsWv[i] = stringFromList(i,ListOfSavedSetsStr)
		endfor
	else
		redimension/N=(0) ListOfSavedSetsWv, SelListOfSavedSetsWv
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IN3S_CheckForSensibility()
	//this will check table for sensibility fo data.
	
	//at this time warns about lack of Blanks...
	
	//create USAXS command file... For now as notebook and just display for user. 

	DFrEF OldDf=GetDataFolderDFR()
	Wave/T listWaveG   =  root:Packages:SamplePlateSetup:LBCommandWv
	Wave LBSelectionWvG= root:Packages:SamplePlateSetup:LBSelectionWv
	Wave/T LBTtitleWvG  = root:Packages:SamplePlateSetup:LBTtitleWv
	NVAR USAXSAllG = root:Packages:SamplePlateSetup:USAXSAll
	NVAR SAXSAllG = root:Packages:SamplePlateSetup:SAXSAll
	NVAR WAXSAllG = root:Packages:SamplePlateSetup:WAXSAll
	NVAR DefaultSampleThickness=root:Packages:SamplePlateSetup:DefaultSampleThickness
	SVAR UserNameForSampleSet = root:Packages:SamplePlateSetup:UserNameForSampleSet
	NVAR RunExportHookFunction= root:Packages:SamplePlateSetup:RunExportHookFunction
	
	variable i, haveAnySAXS, haveAnyWAXS,haveAnyUSAXS
	//figure out list of names which will be used... 
	string ListOfSAXSNames, ListOfWAXSNames, ListOfUSAXSNames
	ListOfSAXSNames=""
	ListOfWAXSNames=""
	ListOfUSAXSNames=""
   //SAXS is first. 
   For(i=0;i<dimsize(listWaveG,0);i+=1)
   		if(SAXSAllG || LBSelectionWvG[i][5]==48)
			if(strlen(listWaveG[i][0])>0 && strlen(listWaveG[i][1])>0 && strlen(listWaveG[i][2])>0)
	   			haveAnySAXS=1
				ListOfSAXSNames+=listWaveG[i][0]+";"
			endif
		endif   
   endfor
   //WAXS is next. 
   For(i=0;i<dimsize(listWaveG,0);i+=1)
   		if(WAXSAllG || LBSelectionWvG[i][6]==48)
			if(strlen(listWaveG[i][0])>0 && strlen(listWaveG[i][1])>0 && strlen(listWaveG[i][2])>0)
	   			haveAnyWAXS=1
				ListOfWAXSNames+=listWaveG[i][0]+";"
			endif
		endif   
   endfor
   //do we have any USAXS scans?
   For(i=0;i<dimsize(listWaveG,0);i+=1)
   		if(USAXSAllG || LBSelectionWvG[i][4]==48)
			if(strlen(listWaveG[i][0])>0 && strlen(listWaveG[i][1])>0 && strlen(listWaveG[i][2])>0)
	   			haveAnyUSAXS=1
				ListOfUSAXSNames+=listWaveG[i][0]+";"
			endif
		endif   
   endfor
	variable NumWAXS, NumWAXSBlanks
	variable NumSAXS, NumSAXSBlanks
	variable NumUSAXS, NumUSAXSBlanks
	NumWAXS=ItemsInList(ListOfWAXSNames)
	NumWAXSBlanks=ItemsInList(GrepList(ListOfWAXSNames, "(?i)blank")+GrepList(ListOfWAXSNames, "(?i)empty"))
	NumSAXS=ItemsInList(ListOfSAXSNames)
	NumSAXSBlanks=ItemsInList(GrepList(ListOfSAXSNames, "(?i)blank")+GrepList(ListOfSAXSNames, "(?i)empty"))
	NumUSAXS=ItemsInList(ListOfUSAXSNames)
	NumUSAXSBlanks=ItemsInList(GrepList(ListOfUSAXSNames, "(?i)blank")+GrepList(ListOfUSAXSNames, "(?i)empty"))
	string MessageToUser=""
   if((NumUSAXSBlanks/NumUSAXS)<(1/15))
   		MessageToUser+=" Blanks for USAXS, "
   endif
   if((NumSAXSBlanks/NumSAXS)<(1/15))
   		MessageToUser+=" Blanks for SAXS, "
   endif
   if((NumWAXSBlanks/NumWAXS)<(1/15))
   		MessageToUser+=" Blanks for WAXS "
   endif
   if(strlen(MessageToUser)>5 &&(NumWAXS>1 || NumSAXS>1 || NumUSAXS>1))
   	DoAlert /T="Not enough blanks, check history area" 0, "Looks like there is not enough "+MessageToUser
   	Print "You need enough background = blanks/empty runs. Default is at least 1 blank per 15 samples, Suggested is 1 blank per 10 samples."
   	print "Code expects background measurements will have blank of empty in the name, but name can contain more. e.g.: TapeBlank is recognized as blank."
   	print "If your background names are different you can go ahead as is."
   endif
	SetDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IN3S_WriteCommandFile(show, AppendHeaders)
	variable show, AppendHeaders

	
	//Options to export multiple saved sets of positions...
	NVAR ExportCurrentPosSet=root:Packages:SamplePlateSetup:ExportCurrentPosSet
	NVAR ExportListOfPosSets=root:Packages:SamplePlateSetup:ExportListOfPosSets
	SVAR CurNameStr=root:Packages:SamplePlateSetup:UserNameForSampleSet
	variable i
	string CurFolder, TempFolder
	curFolder=CurNameStr

	if(ExportListOfPosSets)		//user wants to export multiple saved set...
		Wave/T ListOfWavesForExport=root:Packages:SamplePlateSetup:ListOfWavesForExport
		if(numpnts(ListOfWavesForExport)>0)
			CurNameStr = "TempExportSetStored"
			//save current, just in case
			IN3S_SaveCurrentSampleSet(1,0)
			//cleanup old notebook.
			SVAR/Z nbl=root:Packages:SamplePlateSetup:NotebookName
			if(!SVAR_Exists(nbl))
				NewDataFolder/O root:Packages
				NewDataFolder/O root:Packages:SamplePlateSetup 
				String/G root:Packages:SamplePlateSetup:NotebookName=""
				SVAR nbl=root:Packages:SamplePlateSetup:NotebookName
				nbL="CommandFile"
			endif
			if ((strsearch(WinList("*",";","WIN:16"),nbL,0)!=-1))		///CommandFile notebook exists 
				KillWindow/Z $(nbl)
			endif
			//cycle through the list
			For(i=0;i<numpnts(ListOfWavesForExport);i+=1)
				TempFolder = ListOfWavesForExport[i]
				IN3S_LoadSavedSampleSet(folderToLoad=TempFolder)
				IN3S_WriteCommandFileInternal(show, AppendHeaders,0)
			endfor
			IN3S_LoadSavedSampleSet(folderToLoad="TempExportSetStored")
			KillDataFolder/Z root:SavedSampleSets:TempExportSetStored:		//clean up the temp saved data set. 
			CurNameStr = curFolder
		else
			abort "Nothing is on the list here"
		endif
	elseif(ExportCurrentPosSet)
		IN3S_WriteCommandFileInternal(show, AppendHeaders,1)
	else
		Abort "SOmething wrong with the code in IN3S_WriteCommandFile"
	endif
end
//*****************************************************************************************************************
static FUnction IN3S_WriteCommandFileInternal(show, AppendHeaders, KillIfFound)
	variable show, AppendHeaders, KillIfFound
	//create USAXS command file... For now as notebook and just display for user. 

	DFrEF OldDf=GetDataFolderDFR()
	Wave/T listWaveG   =  root:Packages:SamplePlateSetup:LBCommandWv
	Wave LBSelectionWvG= root:Packages:SamplePlateSetup:LBSelectionWv
	Wave/T LBTtitleWvG  = root:Packages:SamplePlateSetup:LBTtitleWv
	NVAR USAXSAllG = root:Packages:SamplePlateSetup:USAXSAll
	NVAR SAXSAllG = root:Packages:SamplePlateSetup:SAXSAll
	NVAR WAXSAllG = root:Packages:SamplePlateSetup:WAXSAll
	NVAR DefaultSampleThickness=root:Packages:SamplePlateSetup:DefaultSampleThickness
	SVAR UserNameForSampleSet = root:Packages:SamplePlateSetup:UserNameForSampleSet
	NVAR RunExportHookFunction= root:Packages:SamplePlateSetup:RunExportHookFunction
	SVAR/Z nbl=root:Packages:SamplePlateSetup:NotebookName
	variable i, haveAnySWAXS, thickness
	haveAnySWAXS = 0
	if(!SVAR_Exists(nbl))
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:SamplePlateSetup 
		String/G root:Packages:SamplePlateSetup:NotebookName=""
		SVAR nbl=root:Packages:SamplePlateSetup:NotebookName
		nbL="CommandFile"
	endif
	if ((strsearch(WinList("*",";","WIN:16"),nbL,0)!=-1) && KillIfFound)		///CommandFile notebook exists 
		KillWindow/Z $(nbl)
	endif
	
	if ((strsearch(WinList("*",";","WIN:16"),nbL,0) <0))
		NewNotebook/K=1/F=0/ENCG={3,0}/N=$nbl/V=1/W=(235.5,44.75,817.5,592.25) as nbl		
		Notebook $nbl writeBOM = 0
		if(AppendHeaders)
			Notebook $nbl text="        CURRENT_EXPERIMENT_NAME \""+UserNameForSampleSet+"\"\r"
			Notebook $nbl text="		# This file runs USAXS, SAXS and WAXS scans according to the syntax shown below\r"
			Notebook $nbl text="		#       \r"
			Notebook $nbl text="		# Scan Type      sx         sy   Thickness  Sample Name\r"
			Notebook $nbl text="		# ------------------------------------------------------  \r"
			Notebook $nbl text="		# USAXSscan    45.07       98.3     0      \"Water Blank\"\r"
			Notebook $nbl text="		# saxsExp      45.07       98.3     0      \"Water Blank\"\r"
			Notebook $nbl text="		# waxsExp      45.07       98.3     0      \"Water Blank\"  \r"
			Notebook $nbl text="		#      Use a space (not a tab) to separate arguments (i.e., 45.07 <space> 98.3 in the examples above)\r"  
			Notebook $nbl text="\r"
			Notebook $nbl text="		# Run this file by typing the following command in the spec window:   USAXS> CollectData usaxs.mac \r"             
			Notebook $nbl text="\r"                                   
			Notebook $nbl text="		# Stop the run using the \"Stop after this scan?\" checkbox in USAXS user main intf  \r" 
			Notebook $nbl text="		# and wait until the USAXS> prompt reappears\r"
			Notebook $nbl text="\r"          
			Notebook $nbl text="		############ PLACE ALL USER COMMANDS AFTER THIS LINE ############  \r"              
			Notebook $nbl text="\r"
		endif
	endif
	Notebook $nbl text="		 \r"

   //and now we will write the commands... 
   //SAXS is first. 
   
   IN3S_WriteListOfCommands(listWaveG, LBSelectionWvG, 0, 0, "")
   if(RunExportHookFunction)
   		IN3S_ExportHookFunction(listWaveG, LBSelectionWvG)
   endif

	if (show)		///Logbook want to show it...
		DoWindow/F $nbl
	else
		DoWindow/HIDE=1 $nbl
	endif
	SetDataFolder OldDf
end

//Function IN3S_ExportHookFunction(Command, SampleName,SX, SY, Thickness, MD)
//	string Command, SampleName,SX, SY, Thickness, MD 
//	//this hook function will modify output of the command file for given line. This needs to be cutomized for specific need. 
//	SVAR nbl=root:Packages:SamplePlateSetup:NotebookName
//
//	//in this case it will write each command in notebook multiple times, in original position and then +/- 1mm in sx and sy
//	//center	
//	Notebook $nbl text="      "+Command+"        "+SX+"      "+SY+"      "+Thickness+"      \""+SampleName+"\"  \r"
//	//and now the variations, only if Sample Name is NOT Blank or Empty
//	if(!StringMatch(SampleName, "*Blank*")&&!StringMatch(SampleName, "*Empty*"))
//		string TempStr
//		TempStr = num2str(str2num(SX)-1)
//		Notebook $nbl text="      "+Command+"        "+TempStr+"      "+SY+"      "+Thickness+"      \""+SampleName+"_R"+"\"  \r"
//		TempStr = num2str(str2num(SX)+1)
//		Notebook $nbl text="      "+Command+"        "+TempStr+"      "+SY+"      "+Thickness+"      \""+SampleName+"_L"+"\"  \r"
//		TempStr = num2str(str2num(SY)-1)
//		Notebook $nbl text="      "+Command+"        "+SX+"      "+TempStr+"      "+Thickness+"      \""+SampleName+"_B"+"\"  \r"
//		TempStr = num2str(str2num(SY)+1)
//		Notebook $nbl text="      "+Command+"        "+SX+"      "+TempStr+"      "+Thickness+"      \""+SampleName+"_T"+"\"  \r"
//	endif	
//end

//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN3S_WriteListOfCommands(listWaveG, LBSelectionWvG, sxOffset, syOffset, TitleModifier)
	wave/T listWaveG
	wave LBSelectionWvG
	variable sxOffset, syOffset
	string  TitleModifier
	
	NVAR DefaultSampleThickness=root:Packages:SamplePlateSetup:DefaultSampleThickness
	NVAR USAXSAllG = root:Packages:SamplePlateSetup:USAXSAll
	NVAR SAXSAllG = root:Packages:SamplePlateSetup:SAXSAll
	NVAR WAXSAllG = root:Packages:SamplePlateSetup:WAXSAll
	SVAR ExportOrder=root:Packages:SamplePlateSetup:ExportOrder
	// ExportOrder can be: USAXS-SAXS-WAXS, SAXS-WAXS-USAXS, or USAXS-WAXS-SAXS

	variable i, haveAnySWAXS, thickness, sxMod, syMod, numSAXSWAXS
	haveAnySWAXS = 0
	numSAXSWAXS = 0

	string Command, SampleName
	variable SX, SY 
	variable HaveUSAXS
	//this  function will write (potentially modified) output of the command file for given line. This needs to be cutomized for specific need. 
	SVAR nbl=root:Packages:SamplePlateSetup:NotebookName

	strswitch(ExportOrder)
	
		case "USAXS-SAXS-WAXS":
		   Notebook $nbl text="\r"
		   Notebook $nbl text="		#USAXS measurements \r"
		   For(i=0;i<dimsize(listWaveG,0);i+=1)
		   		if(USAXSAllG || LBSelectionWvG[i][4]==48)
					if(strlen(listWaveG[i][0])>0 && strlen(listWaveG[i][1])>0 && strlen(listWaveG[i][2])>0)
			   			thickness = str2num(listWaveG[i][3])
			   			thickness = thickness>0 ? thickness : DefaultSampleThickness
			   			SX=str2num(listWaveG[i][1])+sxOffset
			   			SY=str2num(listWaveG[i][2])+syOffset
						Notebook $nbl text="      USAXSscan        "+num2str(SX)+"      "+num2str(SY)+"      "+num2str(thickness)+"      \""+listWaveG[i][0]+TitleModifier+"\"  \r"
					endif
				endif   
		   endfor
			Notebook $nbl text="\r"
			Notebook $nbl text="		#SAXS measurements \r"
		   //this is SAXS
		   For(i=0;i<dimsize(listWaveG,0);i+=1)
		   		if(SAXSAllG || LBSelectionWvG[i][5]==48)
					if(strlen(listWaveG[i][0])>0 && strlen(listWaveG[i][1])>0 && strlen(listWaveG[i][2])>0)
			   			haveAnySWAXS=1
			   			numSAXSWAXS+=1
			   			thickness = str2num(listWaveG[i][3])
			   			thickness = thickness>0 ? thickness : DefaultSampleThickness
			   			SX=str2num(listWaveG[i][1])+sxOffset
			   			SY=str2num(listWaveG[i][2])+syOffset
						Notebook $nbl text="      saxsExp        "+num2str(SX)+"      "+num2str(SY)+"      "+num2str(thickness)+"      \""+listWaveG[i][0]+TitleModifier+"\"  \r"
					endif
				endif   
		   endfor
		   //WAXS is next. 
			Notebook $nbl text="\r"
			Notebook $nbl text="		#WAXS measurements \r"
		   For(i=0;i<dimsize(listWaveG,0);i+=1)
		   		if(WAXSAllG || LBSelectionWvG[i][6]==48)
					if(strlen(listWaveG[i][0])>0 && strlen(listWaveG[i][1])>0 && strlen(listWaveG[i][2])>0)
			   			haveAnySWAXS=1
			   			numSAXSWAXS+=1
			   			thickness = str2num(listWaveG[i][3])
			   			thickness = thickness>0 ? thickness : DefaultSampleThickness
			   			SX=str2num(listWaveG[i][1])+sxOffset
			   			SY=str2num(listWaveG[i][2])+syOffset
						Notebook $nbl text="      waxsExp        "+num2str(SX)+"      "+num2str(SY)+"      "+num2str(thickness)+"      \""+listWaveG[i][0]+TitleModifier+"\"  \r"
					endif
				endif   
		   endfor
			Notebook $nbl text="		#END of batch of measurements \r"
			break
		case "USAXS-WAXS-SAXS":
		   Notebook $nbl text="\r"
		   Notebook $nbl text="		#USAXS measurements \r"
		   For(i=0;i<dimsize(listWaveG,0);i+=1)
		   		if(USAXSAllG || LBSelectionWvG[i][4]==48)
					if(strlen(listWaveG[i][0])>0 && strlen(listWaveG[i][1])>0 && strlen(listWaveG[i][2])>0)
			   			thickness = str2num(listWaveG[i][3])
			   			thickness = thickness>0 ? thickness : DefaultSampleThickness
			   			SX=str2num(listWaveG[i][1])+sxOffset
			   			SY=str2num(listWaveG[i][2])+syOffset
						Notebook $nbl text="      USAXSscan        "+num2str(SX)+"      "+num2str(SY)+"      "+num2str(thickness)+"      \""+listWaveG[i][0]+TitleModifier+"\"  \r"
					endif
				endif   
		   endfor
		   //WAXS is next. 
			Notebook $nbl text="\r"
			Notebook $nbl text="		#WAXS measurements \r"
		   For(i=0;i<dimsize(listWaveG,0);i+=1)
		   		if(WAXSAllG || LBSelectionWvG[i][6]==48)
					if(strlen(listWaveG[i][0])>0 && strlen(listWaveG[i][1])>0 && strlen(listWaveG[i][2])>0)
			   			haveAnySWAXS=1
			   			numSAXSWAXS+=1
			   			thickness = str2num(listWaveG[i][3])
			   			thickness = thickness>0 ? thickness : DefaultSampleThickness
			   			SX=str2num(listWaveG[i][1])+sxOffset
			   			SY=str2num(listWaveG[i][2])+syOffset
						Notebook $nbl text="      waxsExp        "+num2str(SX)+"      "+num2str(SY)+"      "+num2str(thickness)+"      \""+listWaveG[i][0]+TitleModifier+"\"  \r"
					endif
				endif   
		   endfor
			Notebook $nbl text="\r"
			Notebook $nbl text="		#SAXS measurements \r"
		   //this is SAXS
		   For(i=0;i<dimsize(listWaveG,0);i+=1)
		   		if(SAXSAllG || LBSelectionWvG[i][5]==48)
					if(strlen(listWaveG[i][0])>0 && strlen(listWaveG[i][1])>0 && strlen(listWaveG[i][2])>0)
			   			haveAnySWAXS=1
			   			numSAXSWAXS+=1
			   			thickness = str2num(listWaveG[i][3])
			   			thickness = thickness>0 ? thickness : DefaultSampleThickness
			   			SX=str2num(listWaveG[i][1])+sxOffset
			   			SY=str2num(listWaveG[i][2])+syOffset
						Notebook $nbl text="      saxsExp        "+num2str(SX)+"      "+num2str(SY)+"      "+num2str(thickness)+"      \""+listWaveG[i][0]+TitleModifier+"\"  \r"
					endif
				endif   
		   endfor
			Notebook $nbl text="		#END of batch of measurements \r"
			break
		case "SAXS-WAXS-USAXS":
		   //this is SAXS
		   For(i=0;i<dimsize(listWaveG,0);i+=1)
		   		if(SAXSAllG || LBSelectionWvG[i][5]==48)
					if(strlen(listWaveG[i][0])>0 && strlen(listWaveG[i][1])>0 && strlen(listWaveG[i][2])>0)
			   			haveAnySWAXS=1
			   			numSAXSWAXS+=1
			   			thickness = str2num(listWaveG[i][3])
			   			thickness = thickness>0 ? thickness : DefaultSampleThickness
			   			SX=str2num(listWaveG[i][1])+sxOffset
			   			SY=str2num(listWaveG[i][2])+syOffset
						Notebook $nbl text="      saxsExp        "+num2str(SX)+"      "+num2str(SY)+"      "+num2str(thickness)+"      \""+listWaveG[i][0]+TitleModifier+"\"  \r"
					endif
				endif   
		   endfor
		   //WAXS is next. 
			Notebook $nbl text="\r"
			Notebook $nbl text="		#WAXS measurements \r"
		   For(i=0;i<dimsize(listWaveG,0);i+=1)
		   		if(WAXSAllG || LBSelectionWvG[i][6]==48)
					if(strlen(listWaveG[i][0])>0 && strlen(listWaveG[i][1])>0 && strlen(listWaveG[i][2])>0)
			   			haveAnySWAXS=1
			   			numSAXSWAXS+=1
			   			thickness = str2num(listWaveG[i][3])
			   			thickness = thickness>0 ? thickness : DefaultSampleThickness
			   			SX=str2num(listWaveG[i][1])+sxOffset
			   			SY=str2num(listWaveG[i][2])+syOffset
						Notebook $nbl text="      waxsExp        "+num2str(SX)+"      "+num2str(SY)+"      "+num2str(thickness)+"      \""+listWaveG[i][0]+TitleModifier+"\"  \r"
					endif
				endif   
		   endfor
		   //and USAXS . 
		   //do we have any USAXS scans?
		   Duplicate/Free/R=[][4] LBSelectionWvG, TempUSAXSChoice
		   WaveStats/Q TempUSAXSChoice
		   HaveUSAXS = (V_max>40) ? 1 : 0
		   if(haveAnySWAXS && USAXSAllG && HaveUSAXS)
				Notebook $nbl text="\r"
				Notebook $nbl text="		preUSAXStune \r"   
				if(numSAXSWAXS>15)
					Notebook $nbl text="		preUSAXStune \r"   
				endif
				if(numSAXSWAXS>30)
					Notebook $nbl text="		preUSAXStune \r"   	
				endif
		   endif
			Notebook $nbl text="\r"
			Notebook $nbl text="		#USAXS measurements \r"
		   For(i=0;i<dimsize(listWaveG,0);i+=1)
		   		if(USAXSAllG || LBSelectionWvG[i][4]==48)
					if(strlen(listWaveG[i][0])>0 && strlen(listWaveG[i][1])>0 && strlen(listWaveG[i][2])>0)
			   			thickness = str2num(listWaveG[i][3])
			   			thickness = thickness>0 ? thickness : DefaultSampleThickness
			   			SX=str2num(listWaveG[i][1])+sxOffset
			   			SY=str2num(listWaveG[i][2])+syOffset
						Notebook $nbl text="      USAXSscan        "+num2str(SX)+"      "+num2str(SY)+"      "+num2str(thickness)+"      \""+listWaveG[i][0]+TitleModifier+"\"  \r"
					endif
				endif   
		   endfor
			Notebook $nbl text="\r"
			Notebook $nbl text="		#END USAXS measurements \r"
			break

	endswitch

end

//*****************************************************************************************************************
//*****************************************************************************************************************

static Function/T IN3S_ExportMacroFile(UseUsername, AppendToExisting)	
	variable UseUsername		//set to 0 for usaxs.mac, 1 for user choice. 
	variable AppendToExisting 	//set to 1 if one should append to existing file on desktop. 
	
	IN3S_CheckForSensibility()
	string NewFileName
	SVAR UserDefinedCmdName=root:Packages:SamplePlateSetup:DefaultCommandFileName
	string UseCmdName
	if(strlen(UserDefinedCmdName)>4)
		UseCmdName = UserDefinedCmdName
	else
		UseCmdName = "usaxs.mac" 
	endif
	NewPath /C/Q/O UserDesktop , SpecialDirPath("Desktop", 0, 0, 0 )
	if(UseUsername)
		IN3S_WriteCommandFile(0,1)		//this creates notebook with commands, 
		SVAR nbl=root:Packages:SamplePlateSetup:NotebookName
		SaveNotebook /P=UserDesktop/ENCG=1/S=6/I/M="Select location and name for your command file" $(nbl)  as UseCmdName
		if(strlen(S_path)<1)
			Abort
		endif
		NewFileName = S_path
		string NewFullNamePath =  ReplaceString(".txt", NewFileName, "" )
		//if needed and user did not use .mac, append it. 
		if(!StringMatch(NewFullNamePath, "*.mac"))
			NewFullNamePath = NewFullNamePath+".mac"
		endif
		MoveFile/O  NewFileName  as NewFullNamePath		
		NewFileName = NewFullNamePath
	else			//using default name set in panel... Typically usaxs.mac. 
		if(AppendToExisting)	//need to reimport the existing notebook, cannot append using SaveNotebook
			IN3S_WriteCommandFile(0,0)		//this creates notebook with commands, no header of comments. 
			SVAR nbl=root:Packages:SamplePlateSetup:NotebookName
			OpenNotebook /P=UserDesktop/N=TempOldCmdFile/Z UseCmdName
			if(V_Flag!=0)
				NewNotebook as "TempOldCmdFile" 
			endif
			//read all from imported TempOldCmdFile and stuff it at the beggining of the nbl
			notebook  TempOldCmdFile, selection={startOfFile, endOfFile }
			GetSelection notebook, TempOldCmdFile, 3
			KillWindow/Z TempOldCmdFile
			//print S_selection
			//got to top of the notebook
			notebook  $(nbl), selection={startOfFile, startOfFile }
			//insert old content from existing file. 
			notebook  $(nbl), text=S_selection
			notebook  $(nbl), text="\r"
			notebook  $(nbl), text="###  Appended commands \r"
			notebook  $(nbl), text="\r"
		else
			IN3S_WriteCommandFile(0,1)		//this creates notebook with commands, 	
			SVAR nbl=root:Packages:SamplePlateSetup:NotebookName
		endif
		SaveNotebook /P=UserDesktop/ENCG=1/S=6/O $(nbl)  as UseCmdName
	endif
	SVAR nbl=root:Packages:SamplePlateSetup:NotebookName
	KillWindow/Z $(nbl)
	if(strlen(S_path)>0)
		NewFileName = S_path
		print "Your command file was saved as "+NewFileName 
		return NewFileName
	else
		print "Save of command file was cancelled " 
		return ""
	endif
end


//************************************************************************************************************
//************************************************************************************************************

static Function IN3S_Initialize()

	DFrEF OldDf=GetDataFolderDFR()
	setdatafolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O USAXS
	NewDataFolder/O/S SamplePlateSetup
	//NewDataFolder/O root:AvailableSamplePlates

	string ListOfVariables
	string ListOfStrings
	variable i, j
	
	ListOfVariables="NumberOfSamplesToCreate;DisplayAllSamplesInImage;"
	ListOfVariables+="DefaultSampleThickness;USAXSAll;SAXSAll;WAXSAll;DisplayUSWAXScntrls;"
	ListOfVariables+="SampleXTAR;SampleYTAR;SelectedRow;SampleThickness;SampleXRBV;SampleYRBV;"
	ListOfVariables+="SampleXTable;SampleYTable;SurveySXStep;SurveySYStep;MoveWhenRowChanges;"
	ListOfVariables+="RunExportHookFunction;"
	ListOfVariables+="USAXSScanTime;SAXSScanTime;WAXSScanTime;CalculatedOverAllTime;NumberOfSamples;"
	ListOfVariables+="TableIsSaved;ExportCurrentPosSet;ExportListOfPosSets;"

	ListOfStrings="SelectedPlateName;UserNameForSampleSet;UserName;WarningForUser;"
	ListOfStrings+="SelectedSampleName;DefaultCommandFileName;TableClipboard;"
	ListOfStrings+="ExportOrder;"
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	//waves for multi table export...
	Wave/Z/T ListOfSavedSetsWv
	if(!WaveExists(ListOfSavedSetsWv))
		make/O/N=0/T ListOfSavedSetsWv, ListOfWavesForExport
		make/O/N=0 SelListOfSavedSetsWv, SelListOfWavesForExport
	endif 
	
	NVAR USAXSAll
	NVAR SAXSAll
	NVAR WAXSAll
	USAXSAll =1
	SAXSAll = 1
	WAXSAll = 1
	NVAR NumberOfSamplesToCreate
	if(NumberOfSamplesToCreate<1)
		NumberOfSamplesToCreate = 20
	endif
	SVAR SelectedPlateName
	if(strlen(SelectedPlateName)<2)
		SelectedPlateName = "9x9 Acrylic/magnetic plate"
	endif
	NVAR DefaultSampleThickness
	if(DefaultSampleThickness<0.01||DefaultSampleThickness>20)
		DefaultSampleThickness=1
	endif
	SVAR WarningForUser
	WarningForUser="Tool started... Report bugs and wishes to author!"
	SVAR DefaultCommandFileName
	if(strlen(DefaultCommandFileName)<4)
		DefaultCommandFileName="usaxs.mac"
	endif
	SVAR ExportOrder
	if(strlen(ExportOrder)<2)
		ExportOrder="USAXS-SAXS-WAXS"
	endif
	
	NVAR ExportCurrentPosSet
	NVAR ExportListOfPosSets
	if(ExportCurrentPosSet+ExportListOfPosSets!=1)
		ExportCurrentPosSet=1
		ExportListOfPosSets=0
	endif
	NVAR SurveySXStep
	if(SurveySXStep<0.01)
		SurveySXStep = 1
	endif
	NVAR SurveySYStep
	if(SurveySYStep<0.01)
		SurveySYStep = 1
	endif
	NVAR USAXSScanTime
	NVAR SAXSScanTime
	NVAR WAXSScanTime
	if(USAXSScanTime<30)
		USAXSScanTime = 90
	endif
	if(SAXSScanTime<3)
		SAXSScanTime = 20
	endif
	if(WAXSScanTime<3)
		WAXSScanTime = 20
	endif
	//kill potentially old stuff here
	killwaves/Z imageWave, M_RGB2Gray, PlateImageTemp

	SetDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IN3S_EstimateRunTime()
	
	NVAR USAXSScanTime = root:Packages:SamplePlateSetup:USAXSScanTime
	NVAR SAXSScanTime = root:Packages:SamplePlateSetup:SAXSScanTime
	NVAR WAXSScanTime = root:Packages:SamplePlateSetup:WAXSScanTime
	NVAR CalculatedOverAllTime = root:Packages:SamplePlateSetup:CalculatedOverAllTime
	NVAR USAXSAllG = root:Packages:SamplePlateSetup:USAXSAll
	NVAR SAXSAllG = root:Packages:SamplePlateSetup:SAXSAll
	NVAR WAXSAllG = root:Packages:SamplePlateSetup:WAXSAll

	Wave/T listWaveG   =  root:Packages:SamplePlateSetup:LBCommandWv
	Wave LBSelectionWvG= root:Packages:SamplePlateSetup:LBSelectionWv
	
	NVAR/Z NumberOfSamples   =  root:Packages:SamplePlateSetup:NumberOfSamples
	if(!NVAR_Exists(NumberOfSamples))
		variable/g  root:Packages:SamplePlateSetup:NumberOfSamples
		NVAR NumberOfSamples   =  root:Packages:SamplePlateSetup:NumberOfSamples
	endif
	
	//SAXS LBSelectionWvG[i][5]==48
	//WAXS LBSelectionWvG[i][6]==48
	//USAXS LBSelectionWvG[i][4]==48
	//constant IN3BmSrvUSAXSOverhead = 25			//overhead for flyscan 
	//constant IN3BmSrvSAXSOverhead = 10			//overhead for SAXS, transmission measurement 
	//constant IN3BmSrvWAXSOverhead = 3				//overhead for WAXS 
	//constant IN3BmSrvSampleMoveSpeed = 8			//average moving samples around in mm/sec
	//constant IN3BmSrvTuneTimeStep = 600			//retune every 600 seconds 
	//constant IN3BmSrvTuneTimeNumU = 3				//retune every 3 USAXS scans 
	//constant IN3BmSrvTuneAveTime  = 40			//retune takes avergate 40 seconds full preUSAXStune is 40 seconds... 
	//constant IN3BmSrvSWTuneAveTime = 14			//SWAXS tune MR
	//constant IN3BmSrvMoveGeometryTime = 20		//overhead to mvoe from USAXS to SAXS to WAXS
	variable NumUSAXS, NumSAXS, NumWAXS, numSamples
	variable i, isused
	variable lastSXSAXS, lastSYSAXS, totalSXSYSAXS, firstSXSAXS, firstSYSAXS
	variable lastSXUSAXS, lastSYUSAXS, totalSXSYUSAXS, firstSXUSAXS, firstSYUSAXS
	variable lastSXWAXS, lastSYWAXS, totalSXSYWAXS, firstSXWAXS, firstSYWAXS
    variable SWAXSTime=0
	NumUSAXS=0 
	NumSAXS=0
	NumWAXS=0
	lastSXSAXS = str2num(listWaveG[0][1])
	lastSYSAXS = str2num(listWaveG[0][2])
	firstSXSAXS = str2num(listWaveG[0][1])
	firstSYSAXS = str2num(listWaveG[0][2])
	lastSXUSAXS = str2num(listWaveG[0][1])
	lastSYUSAXS = str2num(listWaveG[0][2])
	firstSXUSAXS = str2num(listWaveG[0][1])
	firstSYUSAXS = str2num(listWaveG[0][2])
	lastSXWAXS = str2num(listWaveG[0][1])
	lastSYWAXS = str2num(listWaveG[0][2])
	firstSXWAXS = str2num(listWaveG[0][1])
	firstSYWAXS = str2num(listWaveG[0][2])
   For(i=0;i<dimsize(listWaveG,0);i+=1)
   		isused = (strlen(listWaveG[i][0])>0 && strlen(listWaveG[i][1])>0 && strlen(listWaveG[i][2])>0)
   		if((SAXSAllG || LBSelectionWvG[i][5]==48)&& isused )
			NumSAXS+=1
			totalSXSYSAXS += sqrt((str2num(listWaveG[i][1])-lastSXSAXS)^2 + (str2num(listWaveG[i][2])-lastSYSAXS)^2 )
			lastSXSAXS = str2num(listWaveG[i][1])
			lastSYSAXS = str2num(listWaveG[i][2])	
		endif   
   		if((WAXSAllG || LBSelectionWvG[i][6]==48)&& isused )
			NumWAXS+=1
			totalSXSYWAXS += sqrt((str2num(listWaveG[i][1])-lastSXWAXS)^2 + (str2num(listWaveG[i][2])-lastSYWAXS)^2 )
			lastSXWAXS = str2num(listWaveG[i][1])
			lastSYWAXS = str2num(listWaveG[i][2])	
		endif   
    	if((USAXSAllG || LBSelectionWvG[i][4]==48)&& isused )
			NumUSAXS+=1
			totalSXSYUSAXS += sqrt((str2num(listWaveG[i][1])-lastSXUSAXS)^2 + (str2num(listWaveG[i][2])-lastSYUSAXS)^2 )
			lastSXUSAXS = str2num(listWaveG[i][1])
			lastSYUSAXS = str2num(listWaveG[i][2])	
		endif   
   endfor
   numSamples = max(NumUSAXS, NumSAXS, NumWAXS)
   NumberOfSamples = numSamples

	CalculatedOverAllTime  =  NumUSAXS*(USAXSScanTime+IN3BmSrvUSAXSOverhead)+totalSXSYUSAXS/IN3BmSrvSampleMoveSpeed+NumUSAXS	//this is USAXS
								//   USAXS scans 			+				Total distance/ speed + assume 1 second speed ramp up and down
	if(NumUSAXS>0)
		//move to USAXS geometry.... 
		CalculatedOverAllTime +=  IN3BmSrvMoveGeometryTime																		//USAXS->SAXS
		//travel from end to start... 
		CalculatedOverAllTime += sqrt((lastSXUSAXS-firstSXSAXS)^2+(lastSYUSAXS-firstSXSAXS)^2)/IN3BmSrvSampleMoveSpeed			//last sample to first sample
	endif

	CalculatedOverAllTime +=  NumSAXS*(SAXSScanTime+IN3BmSrvSAXSOverhead)+totalSXSYSAXS/IN3BmSrvSampleMoveSpeed+NumSAXS 		//SAXS
								//	SAXS scans				 +				Total distance/ speed + assume 1 second speed ramp up and down
	SWAXSTime = NumSAXS*(SAXSScanTime+IN3BmSrvSAXSOverhead)+totalSXSYSAXS/IN3BmSrvSampleMoveSpeed+NumSAXS 
	if(NumSAXS>0)
		//move to SAXS geometry.... 
		CalculatedOverAllTime +=  IN3BmSrvMoveGeometryTime																		//SAXS->WAXS
		//travel from end to start 
		CalculatedOverAllTime += sqrt((lastSXSAXS-firstSXWAXS)^2+(lastSYSAXS-firstSXWAXS)^2)/IN3BmSrvSampleMoveSpeed			//last sample to first sample
	endif
	CalculatedOverAllTime +=  NumWAXS*(WAXSScanTime+IN3BmSrvWAXSOverhead)+totalSXSYWAXS/IN3BmSrvSampleMoveSpeed+NumWAXS  		//WAXS
								//  WAXS scans 				+				Total distance/ speed + assume 1 second speed ramp up and down
	SWAXSTime += NumWAXS*(WAXSScanTime+IN3BmSrvWAXSOverhead)+totalSXSYWAXS/IN3BmSrvSampleMoveSpeed+NumWAXS 
	if(NumWAXS>0)
		//move to WAXS geometry.... 
		CalculatedOverAllTime +=  IN3BmSrvMoveGeometryTime																		//WAXS->USAXS
		//travel from end to start 
		CalculatedOverAllTime += sqrt((lastSXWAXS-firstSXUSAXS)^2+(lastSYWAXS-firstSXUSAXS)^2)/IN3BmSrvSampleMoveSpeed			//last sample to first sample
	endif
	variable NumSWTunes = floor(SWAXSTime / IN3BmSrvTuneTimeStep)			//this is approximate number of SAXS/WAXS tunes * tune time
	variable NumUSAXStunes = floor(NumUSAXS/IN3BmSrvTuneTimeNumU)			//this is typical number of USAXS related tunes (3 flyscans/tune)
	CalculatedOverAllTime +=  NumSWTunes*IN3BmSrvSWTuneAveTime + NumUSAXStunes*IN3BmSrvTuneAveTime
																			//done, calculated average scan time for all which are well defined. 
	CalculatedOverAllTime/=60		//convert to minutes
	CalculatedOverAllTime = round(CalculatedOverAllTime)
end

//************************************************************************************************************
//************************************************************************************************************

Function IN3S_CreateDefaultPlates()

	DFrEF OldDf=GetDataFolderDFR()
	setdatafolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S SamplePlatesAvailable
	//Definitions for:
	//Acrylic9x9Plate = 9x9 Acrylic/magnetic plate
	//OldStyleAlPlate = Old Style Al Plate
	//NMRTubesHolder = NMR Tubes holder 300mm x 75mm, sample center sy=25mm 
	make/O/N=(81,2) Acrylic9x9PlateCenters
	make/O/N=(100,2) AcrylicNMRPlateCenters
	make/O/N=(60,2) OldStyleAlPlateCenters
	make/O/N=(20,2) NMRTubesHolderCenters 
	make/O/N=(0,2) GenericGridHolderCenters 

	string ListOfVariables
	string ListOfStrings
	variable i, j
	
	ListOfVariables="OldStyleAlPlateRadius;OldStyleAlPlateScale;"
	ListOfVariables+="Acrylic9x9PlateRadius;Acrylic9x9PlateScale;AcrylicNMRPlateScale;"
	ListOfVariables+="NMRTubesHolderRadius;NMRTubesHolderScale;"

	ListOfStrings=""
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	//setup parameters
	NVAR Acrylic9x9PlateRadius
	NVAR Acrylic9x9PlateScale
	Acrylic9x9PlateRadius = 4		//radius of sample hole in mm
	Acrylic9x9PlateScale = 0.25		//pixels per mm
	NVAR AcrylicNMRPlateScale
	AcrylicNMRPlateScale = 0.25		//pixels per mm
	Wave Acrylic9x9PlateCenters
	Acrylic9x9PlateCenters[][0] = 20*ceil(0.01+p/9)  
	Acrylic9x9PlateCenters[][1] = 20+20*(p - 9*trunc(p/9)) 
	//NMT Acrylic plate
	Wave AcrylicNMRPlateCenters
	AcrylicNMRPlateCenters[][0] = 10+10*(p - 20*trunc(p/20))				///10*ceil(0.01+p/19)		
	AcrylicNMRPlateCenters[][1] = 24.181 + 40*(ceil(0.01+p/20)-1)			///24.181+40*(p - 20*trunc(p/20)) 		
	
	//Al plate here
	NVAR OldStyleAlPlateRadius
	OldStyleAlPlateRadius=4
	NVAR OldStyleAlPlateScale
	OldStyleAlPlateScale = 0.25
	Wave OldStyleAlPlateCenters
	For(i=0;i<4;i+=1)
		For(j=0;j<8;j+=1)
			OldStyleAlPlateCenters[i*15+j][0] = 12.5+i*25 
		endfor
		For(j=8;j<15;j+=1)
			OldStyleAlPlateCenters[i*15+j][0] = 25+i*25 
		endfor
	endfor	
	For(i=0;i<4;i+=1)
		For(j=0;j<8;j+=1)
			OldStyleAlPlateCenters[i*15+j][1] = 12.5+j*25 
		endfor
		For(j=8;j<15;j+=1)
			OldStyleAlPlateCenters[i*15+j][1] = 25+(j-8)*25 
		endfor
	endfor	
	//NMR tubes holder here
	NVAR NMRTubesHolderRadius
	NVAR NMRTubesHolderScale
	NMRTubesHolderRadius=20
	NMRTubesHolderScale=0.25
	Wave NMRTubesHolderCenters
	NMRTubesHolderCenters[][0] = 15+p*10
	NMRTubesHolderCenters[][1] = 43
	SetDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IN3S_CreateTablesForPlates(HowManySamples, forceReset)
	variable HowManySamples, forceReset	//set forceReset=1 to rezero all waves. 
	
	DFrEF OldDf=GetDataFolderDFR()
	setdatafolder root:Packages:SamplePlateSetup
	Wave/T/Z LBCommandWv = root:Packages:SamplePlateSetup:LBCommandWv
	Wave/Z LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
	Make/N=8/T/O LBTtitleWv
	if(forceReset || !WaveExists(LBSelectionWv) || !WaveExists(LBCommandWv))
		Make/N=(0,8)/T/O LBCommandWv
		Make/N=(0,8)/O LBSelectionWv
	endif
	Wave/T LBCommandWv = root:Packages:SamplePlateSetup:LBCommandWv
	Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
	Wave/T LBTtitleWv = root:Packages:SamplePlateSetup:LBTtitleWv
	if(DimSize(LBSelectionWv,0)<1 && HowManySamples<1)
		HowManySamples = 20
	endif
	if(HowManySamples>0)
		Redimension/N=(HowManySamples,8) LBCommandWv, LBSelectionWv
	endif
	LBTtitleWv = {"Sample Name", "X [mm]", "Y [mm]", "Thick [mm]", "USAXS", "SAXS", "WAXS", "MetaData"}
	//setup the LBSelectionWv to allow what is needed...
	LBSelectionWv[][0] = 2 //set Bit 1, 0x02
	LBSelectionWv[][1] = 2 //set Bit 1,
	LBSelectionWv[][2] = 2 //set Bit 1,
	LBSelectionWv[][3] = 2 //set Bit 1,
	LBSelectionWv[][7] = 2 //set Bit 1,
	IN3S_SetAllOptions()
	SetDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IN3S_SetAllOptions()

	Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
	NVAR USAXSAll = root:Packages:SamplePlateSetup:USAXSAll
		if(USAXSAll)
			LBSelectionWv[][4]=48
		else
			LBSelectionWv[][4]=32
		endif
	NVAR SAXSAll = root:Packages:SamplePlateSetup:SAXSAll
		if(SAXSAll)
			LBSelectionWv[][5]=48
		else
			LBSelectionWv[][5]=32
		endif
	NVAR WAXSAll = root:Packages:SamplePlateSetup:WAXSAll
		if(WAXSAll)
			LBSelectionWv[][6]=48
		else
			LBSelectionWv[][6]=32
		endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//
static Function IN3S_InsertDeleteLines(InsertDelete, row, newLines)	//InsertDelete = 1 for insert, 2 for delete
	variable InsertDelete, row, newLines						//3 duplicate and add there, 4 add at the end. 
	//newLines used only with InsertDelete=4 and is number of new lines. 
	
	Wave/T LBCommandWv = root:Packages:SamplePlateSetup:LBCommandWv
	Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
	variable i
	if(InsertDelete==1)				//insert. 
		InsertPoints row, 1, LBSelectionWv, LBCommandWv
		LBSelectionWv[row][0]=2
		LBSelectionWv[row][1]=2
		LBSelectionWv[row][2]=2
		LBSelectionWv[row][3]=2
		NVAR USAXSAll = root:Packages:SamplePlateSetup:USAXSAll
		if(USAXSAll)
			LBSelectionWv[row][4]=48
		else
			LBSelectionWv[row][4]=32
		endif
		NVAR SAXSAll = root:Packages:SamplePlateSetup:SAXSAll
		if(SAXSAll)
			LBSelectionWv[row][5]=48
		else
			LBSelectionWv[row][5]=32
		endif
		NVAR WAXSAll = root:Packages:SamplePlateSetup:WAXSAll
		if(WAXSAll)
			LBSelectionWv[row][6]=48
		else
			LBSelectionWv[row][6]=32
		endif
		//ListBox CommandsList win=SamplePlateSetup, selRow=row					
		LBSelectionWv[][0]=2
		LBSelectionWv[row][0]=3
		SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
		WarningForUser = "Inserted row number "+ num2str(row)
	elseif(InsertDelete==2)					//delete, easier...
		if(dimsize(LBSelectionWv,0)>1)
			DeletePoints /M=0 row, 1, LBSelectionWv, LBCommandWv
			variable newrow
			newrow = row<(dimSize(LBCommandWv,0))?row : row-1
			//ListBox CommandsList win=SamplePlateSetup, selRow=newrow					
			LBSelectionWv[][0]=2
			LBSelectionWv[newrow][0]=3
			SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
			WarningForUser = "Deleted row number "+ num2str(row)
		else
			SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
			WarningForUser = "Cannot delete last row ! "
		endif
	elseif(InsertDelete==3)					//duplicate
		Duplicate/Free/T/R=[row][] LBCommandWv, tempLBCommandWv
		Duplicate/Free/R=[row][] LBSelectionWv, tempLBSelectionWv
		InsertPoints row, 1, LBSelectionWv, LBCommandWv
		LBCommandWv[row][] 		= tempLBCommandWv[0][q]
		LBSelectionWv[row][] 	= tempLBSelectionWv[0][q]
		//ListBox CommandsList win=SamplePlateSetup, selRow=row+1					
		LBSelectionWv[][0]=2
		LBSelectionWv[row+1][0]=3
		SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
		WarningForUser = "Duplicated row number "+ num2str(row)
	elseif(InsertDelete==4)					//add line at the end
		variable Curlength=dimsize(LBCommandWv,0)
		Redimension/N=(Curlength+newLines,-1) LBCommandWv, LBSelectionWv
		LBSelectionWv[Curlength, ][0]=2
		LBSelectionWv[Curlength, ][1]=2
		LBSelectionWv[Curlength, ][2]=2
		LBSelectionWv[Curlength, ][3]=2
		NVAR USAXSAll = root:Packages:SamplePlateSetup:USAXSAll
		if(USAXSAll)
			LBSelectionWv[Curlength, ][4]=48
		else
			LBSelectionWv[Curlength, ][4]=32
		endif
		NVAR SAXSAll = root:Packages:SamplePlateSetup:SAXSAll
		if(SAXSAll)
			LBSelectionWv[Curlength, ][5]=48
		else
			LBSelectionWv[Curlength, ][5]=32
		endif
		NVAR WAXSAll = root:Packages:SamplePlateSetup:WAXSAll
		if(WAXSAll)
			LBSelectionWv[Curlength, ][6]=48
		else
			LBSelectionWv[Curlength, ][6]=32
		endif
		//ListBox CommandsList win=SamplePlateSetup, selRow=Curlength					
		LBSelectionWv[][0]=2
		LBSelectionWv[Curlength][0]=3
		SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
		WarningForUser = "Added row at the end "
	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//this is from //https://www.wavemetrics.com/code-snippet/listbox-drag-drop, version 1.60, 1-13-2022


function IN3S_DragDropListBoxProc(STRUCT WMListboxAction &lba)
    
     
    if(!(lba.eventCode & 0x03)) // neither mouseup nor mousedown
        return 0
    endif
    
    variable f = 72/PanelResolution(lba.win) // point/pixel
    int dragStarted = strlen(GetUserData(lba.win, lba.ctrlName, "drag"))
    string otherListBox = SelectString(cmpstr(lba.ctrlName, "SourceBox")==0, "SourceBox", "TargetBox")
    string items
    variable j
       
    if (lba.eventCode==2 && dragStarted) // mouseup, drag completed
        // find whether mouse is within OTHER listbox
        if(IN3S_isInControl(lba.mouseLoc, lba.win, otherListBox))
            ControlInfo /W=$lba.win $otherListBox           
            int beforeItem = round(V_startRow + (lba.mouseLoc.v-V_top/f)/V_rowHeight)
            wave /SDFR=$S_DataFolder otherListBoxWave=$S_Value
            beforeItem = limit(beforeItem, 0, numpnts(otherListBoxWave))
            IN3S_copySelection(otherListBox, lba.selwave, lba.listwave, beforeItem)
        endif
        ListBox $lba.ctrlName, win=$lba.win, userdata(drag)=""
    endif
    //add right click to remove right column data
    if(lba.eventCode==1 && lba.eventMod & 0x10)
    	if(stringmatch(nameofWave(lba.listWave),"ListOfWavesForExport"))
    		items = "DeleteRow;"
    		PopupContextualMenu items
 			switch (V_flag)
				case 1:	// "Delete row"
					DeletePoints /M=0 lba.row, 1, lba.listWave, lba.selWave
					break;
				endswitch
    	endif
    endif

    if(lba.eventCode==1 && dragStarted==0) // mousedown, new drag
        if( lba.row < 0 || lba.row >= (DimSize(lba.listWave, 0)) )
            return 0
        endif
        //this can be done only from right to left...
        if(cmpstr(lba.ctrlName, "SourceBox"))
        	return 0
        endif
        
        int i, numBoxes, startrow, endrow, mode, fontSize
       
        // figure out visible rows
        ControlInfo /W=$lba.win $lba.ctrlName
        startrow = V_startRow
        endrow = min(numpnts(lba.selwave)-1, startrow + ceil((V_height/f/V_rowHeight)-2))
        // record current value of mode & fsize
        string strMode, strFsize
        SplitString/E=("mode=\s?([[:digit:]]+)") S_recreation, strMode
        mode = strlen(strMode) ? str2num(strMode) : 1
        SplitString/E=("fSize=\s?([[:digit:]]+)") S_recreation, strFsize
        fontSize = strlen(strFsize) ? str2num(strFsize) : 9
        // stops cell selection as mouse moves by setting mode=0
        ListBox $lba.ctrlName, win=$lba.win, userdata(drag)="started", mode=0
        // userdata(drag) indicates dragging is active, cleared on mouseup
       
        // create a titlebox for every visible selected item
        numBoxes=0
        string DBname, strTitle
        variable height, width, top , left
        for (i=startrow;i<endrow+1;i++)
            if (lba.selwave[i] & 0x09)
                wave /T listwave=lba.listWave
                DBname = "DragBox" + num2str(numBoxes)
                height = f*(V_rowHeight-1)
                width = f*(lba.ctrlRect.right-lba.ctrlRect.left)
                top = f*(lba.ctrlRect.top+(i-startrow)*V_rowHeight+1.5)
                left = f*lba.ctrlRect.left
                sprintf strTitle, "\\sa%+03d\\x%+03d %s", 3-(fontSize>12), (20-fontSize)*0.625, listwave[i]
                TitleBox $DBname, win=$lba.win, title=strTitle, labelBack=(41760,52715,65482), pos={left, top}
                TitleBox $DBname, win=$lba.win, fsize=fontSize, fixedSize=1, frame=0, size={width, height}
                numBoxes ++
            endif
        endfor
        
        // save coordinates of other listbox
        ControlInfo /W=$lba.win $otherListBox
        struct rect pixelRect
        pixelRect.left = v_left/f // point -> pixel
        pixelRect.right = v_right/f
        pixelRect.top = v_top/f
        pixelRect.bottom = pixelRect.top + v_height/f

        // monitor mouse movement until mouseup
        variable dx, dy, buttondown
        
        do
            GetMouse /W=$lba.win
            buttondown = V_flag & 1
            dx = v_left - lba.mouseLoc.h // pixels
            dy = v_top - lba.mouseLoc.v // pixels
            // keep current mouse position updated as mouse moves
            lba.mouseLoc.h = v_left
            lba.mouseLoc.v = v_top
            
            // move titleboxes with mouse                   
            for(i=0; i<numBoxes; i++)
                TitleBox /Z $"DragBox"+num2str(i), win=$lba.win, pos+={dx,dy}
            endfor
            
            // draw focus ring when mouse is over other listbox
            if (IN3S_pointInRect(lba.mouseLoc, pixelRect)) // all units are pixels
                ListBox $otherListBox, win=$lba.win, focusRing=1
                ModifyControl $otherListBox activate
            else
                ModifyControl $lba.ctrlName activate
            endif
            
            DoUpdate /W=$lba.win
        while(buttondown)

        // clear titleboxes and return listboxes to normal mode
        for(i=0; i<numBoxes; i++)
            KillControl /W=$lba.win $"DragBox"+num2str(i)
        endfor
        ListBox $otherListBox, win=$lba.win, focusRing=0
        ListBox $lba.ctrlName, win=$lba.win, mode=mode
        ModifyControl $lba.ctrlName activate
    endif // end of drag
end

//*****************************************************************************************************************
//*****************************************************************************************************************

static function IN3S_copySelection(string toLB, wave selwave, wave /T listwave, variable beforeItem)
       
    Extract /free/T listwave, switchwave, (selwave & 0x09)
    //Extract /O/T listwave, listwave, !(selwave & 0x09)		//this fremoves teh line from teh source, we want to keep it... 
    //Extract /O selwave, selwave, !(selwave & 0x09)
    wave destSelWave = root:Packages:SamplePlateSetup:SelListOfWavesForExport
    wave/T  destListWave = root:Packages:SamplePlateSetup:ListOfWavesForExport 
    destSelWave = 0
    variable numItems = numpnts(switchwave)
    InsertPoints beforeItem, numItems, destSelWave, destListWave
    destSelWave[beforeItem, beforeItem+numItems-1] = 1
    destListWave[beforeItem, beforeItem+numItems-1] = switchwave[p-beforeItem]
end
//*****************************************************************************************************************
//*****************************************************************************************************************

// point and rect structures must have same units
static function IN3S_pointInRect(STRUCT point &pnt, STRUCT rect &r) 
    return ( pnt.h>r.left && pnt.h<r.right && pnt.v>r.top && pnt.v<r.bottom )
end
//*****************************************************************************************************************
//*****************************************************************************************************************

static function IN3S_isInControl(STRUCT point &mouse, string strWin, string strCtrl)
    ControlInfo /W=$strWin $strCtrl
    variable f = 72/PanelResolution(strWin)
    variable hpoint = mouse.h * f
    variable vpoint = mouse.v * f   
    return ( hpoint>V_left && hpoint<(V_right) && vpoint>V_top && vpoint<(V_top+V_height) )
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IN3S_DrawImageOfPlate(WhichOne)
	string WhichOne
	
	//WhichOne = "9x9 Acrylic/magnetic plate"
	
	DFrEF OldDf=GetDataFolderDFR()
	setdatafolder root:Packages:SamplePlatesAvailable
	KillWindow/Z SamplePlateImageDrawing
	variable HorSize, VertSize
	if(stringMatch(whichOne,"9x9 Acrylic/magnetic plate"))
		Wave Centers = root:Packages:SamplePlatesAvailable:Acrylic9x9PlateCenters
		NVAR Radius = root:Packages:SamplePlatesAvailable:Acrylic9x9PlateRadius
		NVAR Scaling = root:Packages:SamplePlatesAvailable:Acrylic9x9PlateScale
		//plate is 304.8mm wide x 200mm high, use 1200x800 wave, 0.25mm pixel scaling. 
		HorSize = 300/Scaling
		VertSize = 200/Scaling
		Make/O/N=(HorSize,VertSize)/B/U PlateImage
		wave PlateImage
		//PlateImage = 128				//set image to 128, that is medium grey in our color system. 
		SetScale/P x 0,Scaling,"mm", PlateImage
		SetScale/P y 0,Scaling,"mm", PlateImage	
		Duplicate/Free Centers, CentersForDrawing
		//create circles, set image to 128, that is medium grey in our color system in solid and 0 in opening for samples. 
		IN3S_CreateCircles(PlateImage, CentersForDrawing, Radius, Scaling)
	elseif(stringMatch(whichOne,"NMR Acrylic plate"))
		Wave Centers = root:Packages:SamplePlatesAvailable:AcrylicNMRPlateCenters
		//NVAR Radius = root:Packages:SamplePlatesAvailable:Acrylic9x9PlateRadius
		NVAR Scaling = root:Packages:SamplePlatesAvailable:AcrylicNMRPlateScale
		//plate is 330.2mm wide x 200mm high, use 1200x800 wave, 0.25mm pixel scaling. 
		HorSize = 330/Scaling
		VertSize = 200/Scaling
		Make/O/N=(HorSize,VertSize)/B/U PlateImage
		wave PlateImage
		//PlateImage = 128				//set image to 128, that is medium grey in our color system. 
		SetScale/P x 0,Scaling,"mm", PlateImage
		SetScale/P y 0,Scaling,"mm", PlateImage	
		Duplicate/Free Centers, CentersForDrawing
		//create NMR tubes, set image to 128, that is medium grey in our color system in solid and 0 in opening for samples. 
		IN3S_CreateNMRTubes(PlateImage, CentersForDrawing, Scaling)
	elseif(stringMatch(whichOne,"Old Style Al Plate"))
		Wave Centers = root:Packages:SamplePlatesAvailable:OldStyleAlPlateCenters
		NVAR Radius = root:Packages:SamplePlatesAvailable:OldStyleAlPlateRadius
		NVAR Scaling = root:Packages:SamplePlatesAvailable:OldStyleAlPlateScale
		//plate is 250mm wide x 200mm high, use 1000x800 wave, 0.25mm pixel scaling. 
		HorSize = 250/Scaling
		VertSize = 200/Scaling
		Make/O/N=(HorSize,VertSize)/B/U PlateImage
		wave PlateImage
		//PlateImage = 128				//set image to 128, that is medium grey in our color system. 
		SetScale/P x 0,Scaling,"mm", PlateImage
		SetScale/P y 0,Scaling,"mm", PlateImage	
		Duplicate/Free Centers, CentersForDrawing
		//create circles, set image to 128, that is medium grey in our color system in solid and 0 in opening for samples. 
		IN3S_CreateCircles(PlateImage, CentersForDrawing, Radius, Scaling)
	elseif(stringMatch(whichOne,"NMR Tubes holder"))
		Wave Centers = root:Packages:SamplePlatesAvailable:NMRTubesHolderCenters
		NVAR Radius = root:Packages:SamplePlatesAvailable:NMRTubesHolderRadius
		NVAR Scaling = root:Packages:SamplePlatesAvailable:NMRTubesHolderScale
		//plate is 300mm wide x 75mm high, use 1200x300 wave with 0.25mm pixel scaling. 
		HorSize = 300/Scaling
		VertSize = 75/Scaling
		Make/O/N=(HorSize,VertSize)/B/U PlateImage
		wave PlateImage
		//PlateImage = 128				//set image to 128, that is medium grey in our color system. 
		SetScale/P x 0,Scaling,"mm", PlateImage
		SetScale/P y 0,Scaling,"mm", PlateImage	
		Duplicate/Free/R=[1,12] Centers, CentersForDrawing
		//create opening for samples, set image to 128, that is medium grey in our color system in solid and 0 in opening for samples. 
		//IN3S_CreateCircles(PlateImage, CentersForDrawing, Radius, Scaling)
		PlateImage = 128
		PlateImage[10/Scaling, 210/Scaling][20/Scaling,66/Scaling] = 0
		
		//add tube lines...
		IN3S_AddOtherDrawings(PlateImage, Centers, Radius, Scaling, "VerticalNMR") 

	elseif(stringMatch(whichOne,"Image"))
		//here is code which loads image and deal with that. this will be different code and complciated.

	else
		Abort "This sample plate name does not have drawign available."
	endif
	//create plate drawing. 	
	DoWIndow SamplePlateImageDrawing
	if(V_Flag!=1)
		PauseUpdate
		NewImage/K=1/N=SamplePlateImageDrawing root:Packages:SamplePlatesAvailable:PlateImage
		DoWindow/T SamplePlateImageDrawing,"Image of "+WhichOne
		ModifyImage PlateImage ctab= {0,256,Grays,1}
		ModifyGraph margin(left)=28,margin(bottom)=28,margin(top)=28,margin(right)=28
		SetAxis/R left (VertSize*Scaling+0.125),-0.125
		SetAxis/R top (HorSize*Scaling+0.125),-0.125
		Label left "\\Zr133millimeters from top right corner"
		Label top "\\Zr133millimeters from top right corner"
		ModifyGraph grid=1
		ModifyGraph mirror=3
		ModifyGraph nticks(left)=22,nticks(top)=22
		ModifyGraph minor=1
		ModifyGraph standoff=0
		ModifyGraph tkLblRot(left)=90
		ModifyGraph btLen=3
		ModifyGraph tlOffset=-2
		DoUpdate
	endif
	SetWindow SamplePlateImageDrawing  hook(ImageHook)=IN3S_PlateImageHook

	SetDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IN3S_WritePositionInTable(mouseVert, mouseHor)
	variable mouseHor, mouseVert
	
	Wave/T LBCommandWv = root:Packages:SamplePlateSetup:LBCommandWv
	Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
	SVAR SelectedPlateName = root:Packages:SamplePlateSetup:SelectedPlateName
	//need to identify where we are and what size the image is
	string Margins =  IN2G_FindInRecreation(winrecreation("SamplePlateImageDrawing",0), "margin")
	variable margleft=NumberByKey("margin(left)", Margins,"=", ",")
	variable margright=NumberByKey("margin(right)", Margins,"=", ",")
	variable margtop=NumberByKey("margin(top)", Margins,"=", ",")
	variable margbot=NumberByKey("margin(bottom)", Margins,"=", ",")
	getwindow SamplePlateImageDrawing wsizeDC
	variable horsize=(V_right - V_left)
	variable versize=(V_bottom - V_top)
	GetAxis /W=SamplePlateImageDrawing /Q left
	variable VertMin=min(V_min, V_max)
	variable VertMax=max(V_min, V_max)
	GetAxis /W=SamplePlateImageDrawing /Q top
	variable HorMin=min(V_min, V_max)
	variable HorMax=max(V_min, V_max)
	variable xpos, ypos	
	horsize = horsize-margleft-margright
	versize = versize-margtop-margbot
	variable HorRange=HorMax - HorMin
	variable VertRange=VertMax - VertMin
	xpos = HorMin + HorRange*(horsize - (mouseHor-margleft))/(horsize)
	
	ypos = VertMin + VertRange *(mouseVert-margtop)/(versize)
	
	//FindLevel  /EDGE=1 /P/Q  LBSelectionWv, 0.5
	variable SelectedRow = IN3S_FindFirstSelectedRow()
	//ControlInfo /W=SamplePlateSetup CommandsList
	if(SelectedRow>=0&&SelectedRow<dimSize(LBCommandWv,0))
		LBCommandWv[SelectedRow][1]=num2str(xpos)
		LBCommandWv[SelectedRow][2]=num2str(ypos)
	else
		SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
		WarningForUser = "Could not records values for this positon, no row selected" 
		print "Could not records values for this positon, no row selected" 
	endif
	
end
//*****************************************************************************************************************
static Function IN3S_FindFirstSelectedRow()

	Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
	string ListOfSelRows=IN3S_CreateListOfRows(LBSelectionWv)
	variable firstSelectedRow = str2num(StringFromList(ItemsInList(ListOfSelRows)-1, ListOfSelRows))
	firstSelectedRow = numtype(firstSelectedRow)==0 ? firstSelectedRow : 0 
	return firstSelectedRow
end

//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IN3S_AddTagToImage(row)	//add one tag if row is number, all if -1 or DisplayAllSamplesInImage=1
	variable row
	
	DoWindow SamplePlateImageDrawing
	if(V_Flag)
		Wave/T listWave=root:Packages:SamplePlateSetup:LBCommandWv
		if(row>DimSize(listWave,0)-1)
			return 0	//we seem to have issues with row being selected while there are no rows... 
		endif
		NVAR DisplayAllSamplesInImage = root:Packages:SamplePlateSetup:DisplayAllSamplesInImage
		//removeFromGraph /Z/W=SamplePlateImageDrawing Tagy
		if(row>=0 && !DisplayAllSamplesInImage)
			MAKE/O/N=1 root:Packages:SamplePlateSetup:TagX
			MAKE/O/N=1 root:Packages:SamplePlateSetup:Tagy
			MAKE/O/N=1/T root:Packages:SamplePlateSetup:TagNames
			Wave tagx=root:Packages:SamplePlateSetup:TagX
			Wave tagy= root:Packages:SamplePlateSetup:Tagy
			Wave/T TagNames= root:Packages:SamplePlateSetup:TagNames
			if(strlen(listWave[row][1])>0 && strlen(listWave[row][2])>0)
				tagx=str2num(listWave[row][1])
				tagy=str2num(listWave[row][2])
				Duplicate/O tagy, root:Packages:SamplePlateSetup:TagyLabel
				Wave TagyLabel= root:Packages:SamplePlateSetup:TagyLabel
				TagNames = "   "+listWave[row][0]
				CheckDisplayed /W=SamplePlateImageDrawing Tagy
				if(V_Flag==0)
					AppendToGraph /W=SamplePlateImageDrawing/T/L Tagy vs tagx
					ModifyGraph /W=SamplePlateImageDrawing mode(Tagy)=3,marker(Tagy)=19,msize(Tagy)=0,mrkThick(Tagy)=1
					ModifyGraph /W=SamplePlateImageDrawing useMrkStrokeRGB(Tagy)=1
				endif
				CheckDisplayed /W=SamplePlateImageDrawing TagyLabel
				if(V_Flag==0)
					AppendToGraph /W=SamplePlateImageDrawing/T/L TagyLabel vs tagx
					ModifyGraph mode=3,textMarker(TagyLabel)={TagNames,"default",0,20,4,0.00,0.00}
				endif
			else
				removeFromGraph /Z/W=SamplePlateImageDrawing Tagy
				removeFromGraph /Z/W=SamplePlateImageDrawing TagyLabel
			endif
			//Tag/C/W=SamplePlateImageDrawing/N=SampleName/F=0/TL=0/I=1/B=0/G=(64640,0,2246) Tagy, 0, TagNames[0]
		elseif(row==-1 || DisplayAllSamplesInImage)
			MAKE/O/N=(dimsize(listWave,0)) root:Packages:SamplePlateSetup:TagX
			MAKE/O/N=(dimsize(listWave,0)) root:Packages:SamplePlateSetup:Tagy
			MAKE/O/N=(dimsize(listWave,0))/T root:Packages:SamplePlateSetup:TagNames
			Wave tagx=root:Packages:SamplePlateSetup:TagX
			Wave tagy= root:Packages:SamplePlateSetup:Tagy
			Wave/T TagNames= root:Packages:SamplePlateSetup:TagNames
			tagx=str2num(listWave[p][1])
			tagy=str2num(listWave[p][2])
			Duplicate/O tagy, root:Packages:SamplePlateSetup:TagyLabel
			Wave TagyLabel= root:Packages:SamplePlateSetup:TagyLabel
			TagNames = "   "+listWave[p][0]
			CheckDisplayed /W=SamplePlateImageDrawing Tagy
			if(V_Flag==0)
				AppendToGraph /W=SamplePlateImageDrawing/T/L Tagy vs tagx
				ModifyGraph /W=SamplePlateImageDrawing mode(Tagy)=3,marker(Tagy)=19,msize(Tagy)=0,mrkThick(Tagy)=1
				ModifyGraph /W=SamplePlateImageDrawing useMrkStrokeRGB(Tagy)=1
			endif
			CheckDisplayed /W=SamplePlateImageDrawing TagyLabel
			if(V_Flag==0)
				AppendToGraph /W=SamplePlateImageDrawing/T/L TagyLabel vs tagx
				ModifyGraph mode=3,textMarker(TagyLabel)={TagNames,"default",0,40,4,0.00,0.00}
			endif
		else
			Wave/Z tagx=root:Packages:SamplePlateSetup:TagX
			Wave/Z tagy= root:Packages:SamplePlateSetup:Tagy
			Wave/T/Z TagNames= root:Packages:SamplePlateSetup:TagNames
			if(WaveExists(tagx)&&WaveExists(tagy)&&WaveExists(TagNames))
				redimension/N=0 tagx, tagy, TagNames
			endif
			removeFromGraph /Z/W=SamplePlateImageDrawing Tagy
			removeFromGraph /Z/W=SamplePlateImageDrawing TagyLabel
		endif	
		
	
	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN3S_PlateImageHook(s)
	STRUCT WMWinHookStruct &s

	if(stringMatch(s.winName, "SamplePlateImageDrawing"))
		switch( s.eventCode )
			case -1: // control being killed
				break
			case 3: // mouse down
				if (s.eventMod & 0x10)	// rightclick
					string items
					Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
					items = "Write position;Add Line with positions;Igor right click cmds;"
						PopupContextualMenu items
						// V_flag is index of user selected item    
						switch (V_flag)
							case 1:	// "Write position"
								IN3S_WritePositionInTable(s.mouseLoc.v, s.mouseLoc.h)
								//ControlInfo /W=SamplePlateSetup CommandsList
								variable V_Value=IN3S_FindFirstSelectedRow()
								IN3S_AddTagToImage(V_Value)
								variable serrow=V_Value
								//sync to Bealine setup, if exists...
								DoWIndow BeamlinePlateSetup
								if(V_Flag)
									NVAR SelectedRow=root:Packages:SamplePlateSetup:SelectedRow
									SVAR SelectedSampleName=root:Packages:SamplePlateSetup:SelectedSampleName
									Wave/T ListWV = root:Packages:SamplePlateSetup:LBCommandWv
									NVAR SampleThickness=root:Packages:SamplePlateSetup:SampleThickness
									NVAR SampleXTAR=root:Packages:SamplePlateSetup:SampleXTAR
									NVAR SampleYTAR=root:Packages:SamplePlateSetup:SampleYTAR
									NVAR SampleXTable = root:Packages:SamplePlateSetup:SampleXTable
									NVAR SampleYTable = root:Packages:SamplePlateSetup:SampleYTable
									if(serrow>=0)
										SelectedRow=serrow
										SelectedSampleName = ListWV[SelectedRow][0]
										//ListBox CommandsList, win=SamplePlateSetup, selrow=SelectedRow
										LBSelectionWv[][0]=2
										LBSelectionWv[SelectedRow][0]=3
										SampleXTable = str2num(ListWV[SelectedRow][1])
										SampleYTable = str2num(ListWV[SelectedRow][2])
										SampleThickness = str2num(ListWV[SelectedRow][3])
										SampleThickness = numtype(SampleThickness)==0 ? SampleThickness : 1
									endif
									SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
									WarningForUser = "Written right click position in table" 			
									IN3S_MoveToPositionIfOK()
								endif
								return 1
								break;
							case 2:	// "Add Line with positions"
								IN3S_InsertDeleteLines(4, 0,1)
								//now select the line. 
								variable SelRow2
								Wave/T listWave=root:Packages:SamplePlateSetup:LBCommandWv
								SelRow2 = dimSize(listWave,0)-1
								Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
								LBSelectionWv[][0]=2
								LBSelectionWv[SelRow2][0]=3
								ListBox CommandsList, win=SamplePlateSetup, selRow= SelRow2
								IN3S_WritePositionInTable(s.mouseLoc.v, s.mouseLoc.h)
								IN3S_AddTagToImage(SelRow2)
								//sync to Bealine setup, if exists...
								DoWIndow BeamlinePlateSetup
								if(V_Flag)
									NVAR SelectedRow=root:Packages:SamplePlateSetup:SelectedRow
									SVAR SelectedSampleName=root:Packages:SamplePlateSetup:SelectedSampleName
									Wave/T ListWV = root:Packages:SamplePlateSetup:LBCommandWv
									NVAR SampleThickness=root:Packages:SamplePlateSetup:SampleThickness
									NVAR SampleXTAR=root:Packages:SamplePlateSetup:SampleXTAR
									NVAR SampleYTAR=root:Packages:SamplePlateSetup:SampleYTAR
									NVAR SampleXTable = root:Packages:SamplePlateSetup:SampleXTable
									NVAR SampleYTable = root:Packages:SamplePlateSetup:SampleYTable
									if(dimSize(listWave,0)-1>=0)
										SelectedRow=dimSize(listWave,0)-1
										SelectedSampleName = ListWV[SelectedRow][0]
										//ListBox CommandsList, win=SamplePlateSetup, selrow=SelectedRow
										LBSelectionWv[][0]=2
										LBSelectionWv[SelectedRow][0]=3
										SampleXTable = str2num(ListWV[SelectedRow][1])
										SampleYTable = str2num(ListWV[SelectedRow][2])
										SampleThickness = str2num(ListWV[SelectedRow][3])
										SampleThickness = numtype(SampleThickness)==0 ? SampleThickness : 1
									endif
									SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
									WarningForUser = "Added new line with rigth click positions" 			
									IN3S_MoveToPositionIfOK()
								endif
								return 1
								break
							case 3:	// "Igor right click cmds"
								return 0
								break
							case 4:	// "Duplicate selected Line"
								//IN3S_InsertDeleteLines(3, row)
								break
							default :	// "Sort"
								break;
						endswitch
				else	//left click, do something here... 
					//IN3S_WritePositionInTable(s.mouseLoc.v, s.mouseLoc.h)
					break
				endif
				break
			case 4: // mousemoved
					break
			case 5: // mouseup
				break
			case 6: // begin edit
				break
			case 7: // finish edit
				break
			case 13: // checkbox clicked (Igor 6.2 or later)
				break
		endswitch
	endif
	return 0
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IN3S_AddOtherDrawings(PlateImage, Centers, Radius, Scaling, WhatDrawing)
	wave PlateImage, Centers
	variable Radius, Scaling
	string WhatDrawing
	//here we draw other drawings in the image as needed. 
	variable i, j
	variable locCenterX, locCenterY, locWidthX
	variable tmpX, tmpYt, tmpYb
	
	variable NMRverticallenght=23
	variable NMRradius=2
	if(StringMatch(WhatDrawing, "VerticalNMR"))
		
		For(i=0;i<dimSize(Centers,0);i+=1)
			locCenterX = centers[i][0]/Scaling
			locCenterY = centers[i][1]/Scaling
			locWidthX = floor(NMRradius/Scaling)
			//left line
			tmpX = locCenterX - locWidthX
			tmpYt = locCenterY + NMRverticallenght/Scaling
			tmpYb = locCenterY - NMRverticallenght/Scaling
			PlateImage[tmpX][tmpYb,tmpYt] = 255
			//right line
			tmpX = locCenterX + locWidthX
			PlateImage[tmpX][tmpYb,tmpYt] = 255
			//fill
			PlateImage[locCenterX-locWidthX+1,locCenterX+locWidthX-1][tmpYb,tmpYt] = 64

		endfor
	
	endif

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IN3S_CreateCircles(PlateImage, Centers, Radius,Scaling)
	wave PlateImage, Centers
	variable Radius, Scaling
	
	variable i
	//this needs to be done by FFT, this is crazy slow... 
	//For(i=0;i<DimSize(Centers, 0);i+=1)
	//	PlateImage = sqrt((x - Centers[i][0])^2+( y - Centers[i][1])^2)<Radius ? 0 : PlateImage(x)(y)
	//endfor
	//now FFT... Much faster, but bit cumbersome... 
	//this method - in convolutions - shifts the centers by : 
	variable PadSphere=Radius/Scaling
	//make work space... 
	Make/Free/S/N=(dimsize(PlateImage,0)+PadSphere, dimsize(PlateImage,1)+PadSphere) WaveToWorkOn, Circle
	//SET TO 1 where will be centers of holes
	For(i=0;i<DimSize(Centers, 0);i+=1)
		WaveToWorkOn [Centers[i][0]/Scaling][Centers[i][1]/Scaling] = 1
	endfor
	//create image of hole
	Circle[0,ceil(2*Radius/Scaling+2)][0,ceil(2*Radius/Scaling+2)] = (sqrt((p*Scaling-Radius)^2+(q*Scaling-Radius)^2)<Radius) ? 1 : 0
	//now use fft. MatrixOp should be bit faster. 
	//fft/DEST=CircleFFT/Free Circle
	MatrixOp/FREE CircleFFT=fft(Circle,0)
	//fft/DEST=Wave2DInFFT/Free WaveToWorkOn
	MatrixOp/FREE Wave2DInFFT=fft(WaveToWorkOn,0)
	//convolute together
	MatrixOp/FREE MultipliedFFT = Wave2DInFFT * CircleFFT
	//IFFT, force real result
	//IFFT/Dest=Wave2DOutIFFT/Free MultipliedFFT
	MatrixOp/FREE Wave2DOutIFFT=ifft(MultipliedFFT,1)
	//this depends on what is used for convolution. If sharp sphere, this is what you need... thresholds are  much smaller for gauss... 
	imageThreshold/T=(0.5)  Wave2DOutIFFT
	wave M_ImageThresh
	//now we need to shrink it back to size and remove first PadSphere rows and columns
	Duplicate/Free/R=[PadSphere, ][PadSphere, ] M_ImageThresh, ShrunkImageThresh
	//and return back to the code. 
	PlateImage = 128 - (ShrunkImageThresh/2)
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IN3S_CreateNMRTubes(PlateImage, Centers, Scaling)
	wave PlateImage, Centers
	variable Scaling
	
	variable i
	variable NMRTubeRadius, NMRTubeHeight, CenterP, CenterQ
	NMRTubeRadius = 2/Scaling
	NMRTubeHeight = 10/Scaling
	CenterP = NMRTubeHeight - NMRTubeRadius
	CenterQ = NMRTubeHeight - NMRTubeRadius
	//this needs to be done by FFT, this is crazy slow... 
	//For(i=0;i<DimSize(Centers, 0);i+=1)
	//	PlateImage = sqrt((x - Centers[i][0])^2+( y - Centers[i][1])^2)<Radius ? 0 : PlateImage(x)(y)
	//endfor
	//now FFT... Much faster, but bit cumbersome... 
	//this method - in convolutions - shifts the centers by : 
	variable PadSphereP=NMRTubeRadius/Scaling
	variable PadSphereQ=0//NMRTubeHeight/Scaling
	//make work space... 
	Make/Free/S/N=(dimsize(PlateImage,0)+PadSphereP, dimsize(PlateImage,1)+PadSphereP) WaveToWorkOn, NMRTube
	//SET TO 1 where will be centers of holes
	For(i=0;i<DimSize(Centers, 0);i+=1)
		WaveToWorkOn [Centers[i][0]/Scaling][Centers[i][1]/Scaling] = 1
	endfor
	//create image of hole
	NMRTube[0,ceil(2*NMRTubeHeight+2)][0,ceil(2*NMRTubeHeight+2)] = ((abs(p-CenterP)<NMRTubeRadius)&& (abs(q-CenterQ)<NMRTubeHeight)) ? 1 : 0
	//now use fft. MatrixOp should be bit faster. 
	//fft/DEST=CircleFFT/Free Circle
	MatrixOp/FREE NMRTubeFFT=fft(NMRTube,0)
	//fft/DEST=Wave2DInFFT/Free WaveToWorkOn
	MatrixOp/FREE Wave2DInFFT=fft(WaveToWorkOn,0)
	//convolute together
	MatrixOp/FREE MultipliedFFT = Wave2DInFFT * NMRTubeFFT
	//IFFT, force real result
	//IFFT/Dest=Wave2DOutIFFT/Free MultipliedFFT
	MatrixOp/FREE Wave2DOutIFFT=ifft(MultipliedFFT,1)
	//this depends on what is used for convolution. If sharp sphere, this is what you need... thresholds are  much smaller for gauss... 
	imageThreshold/T=(0.5)  Wave2DOutIFFT
	wave M_ImageThresh
	//now we need to shrink it back to size and remove first PadSphere rows and columns
	Duplicate/Free/R=[PadSphereP, ][PadSphereP, ] M_ImageThresh, ShrunkImageThresh
	//and return back to the code. 
	PlateImage = 128 - (ShrunkImageThresh/2)
end

//************************************************************************************************************
//************************************************************************************************************
Function  IN3S_ImportFile()			//thsi imports ASCII file, need to add otehr types of fioles as needed. 

	DFrEF OldDf=GetDataFolderDFR()
	setdatafolder root:Packages:SamplePlateSetup:

	Wave/T LBCommandWv = root:Packages:SamplePlateSetup:LBCommandWv
	Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
	//Wave/T LBTtitleWv = root:Packages:SamplePlateSetup:LBTtitleWv
	redimension/N=(400,8) LBCommandWv, LBSelectionWv
	//initialize...
	string/g ImportFileType
	SVAR ImportFileType
	if(strlen(ImportFileType)<1)
		ImportFileType="12IDB command file"
	endif
	//import the the text file. 
	variable refNum, i, imax, iused
    String line, tmpStr, MDStart=""
	if(StringMatch(ImportFileType, "12IDB command file" ))			//this is reading web created command files from 12IDB
		open/R/F="????" refnum 
		if(strlen(S_fileName)==0)
			abort
		endif
		print "Importing 12IDB commands from file : "+S_fileName
		SVAR SetName = root:Packages:SamplePlateSetup:UserNameForSampleSet
		SetName = CleanupName(StringFromList(ItemsInList(S_fileName,":")-1, S_fileName, ":"), 0)
		i=0;imax=0
        FSetPos refnum,0
		do
        	FReadLine refnum, line
			if(!StringMatch(line, "#*")&&strlen(line)>1)		//if does not start with #
				//# sample_Name	sample_x	sample_y	ExposureTime	thickness(???)	sample_description
				LBCommandWv[i][0] = CleanupName(StringFromList(0, line , ","), 0 , 40)
				LBCommandWv[i][1] = StringFromList(1, line , ",")
				LBCommandWv[i][2] = StringFromList(2, line , ",")
				LBCommandWv[i][3] = StringFromList(4, line , ",")
				//LBCommandWv[i][4] = StringFromList(3, line , ",")
				//LBCommandWv[i][5] = StringFromList(3, line , ",")
				//LBCommandWv[i][6] = StringFromList(3, line , ",")
				//SG4M4, 78, 0, 1.0, 1, 1.5, 100x diluted short nanowires, pH=10, 1.5 M KCl
				tmpStr = line
				tmpStr = RemoveFromList(StringFromList(0, line , ","), tmpStr, ",")	//remove name
				tmpStr = RemoveFromList(StringFromList(1, line , ","), tmpStr, ",")	//remove x
				tmpStr = RemoveFromList(StringFromList(2, line , ","), tmpStr, ",")	//remove y
				tmpStr = RemoveFromList(StringFromList(3, line , ","), tmpStr, ",")	//remove exposure time
				tmpStr = RemoveFromList(StringFromList(4, line , ","), tmpStr, ",")	//remove thickness
				tmpStr = RemoveEnding(tmpStr, "\r")
				tmpStr = RemoveEnding(tmpStr, "\r\n")
				LBCommandWv[i][7] = MDStart+"Sample description: "+tmpStr		//StringFromList(6, line , ",")		//this is MD for BS, ddi tno work with , used by users in description. 
				i+=1
			else
				if(!(StringMatch(line, "#IP*") ||StringMatch(line, "# sample_Name*")||StringMatch(line, "#Holder*") ))
					tmpStr = ReplaceString("#", line, "")
					tmpStr = ReplaceString("^t", tmpStr, "")
					MDStart+=RemoveEnding(tmpStr, "\r")+";"
				endif
			endif
		while(strlen(line)>0)
		close refnum		
		LBSelectionWv[][0]=2
		LBSelectionWv[][1]=2
		LBSelectionWv[][2]=2
		LBSelectionWv[][3]=2
		NVAR USAXSAll = root:Packages:SamplePlateSetup:USAXSAll
		if(USAXSAll)
			LBSelectionWv[][4]=48
		else
			LBSelectionWv[][4]=32
		endif
		NVAR SAXSAll = root:Packages:SamplePlateSetup:SAXSAll
		if(SAXSAll)
			LBSelectionWv[][5]=48
		else
			LBSelectionWv[][5]=32
		endif
		NVAR WAXSAll = root:Packages:SamplePlateSetup:WAXSAll
		if(WAXSAll)
			LBSelectionWv[][6]=48
		else
			LBSelectionWv[][6]=32
		endif
	endif
	redimension/N=(i,8) LBSelectionWv,LBCommandWv 
	

	SetDataFolder OldDf
end
//************************************************************************************************************
//************************************************************************************************************
Function IN3S_ImportImageOfPlate()
	// imports the image in here: root:Packages:SamplePlatesAvailable:PlateImage
	// and allows user to remvoe parralax and trim, set dimensions. 
	
	DFrEF OldDf=GetDataFolderDFR()
	setdatafolder root:Packages:SamplePlatesAvailable
	KillWindow/Z SamplePlateImageDrawing
	NVAR Scaling = root:Packages:SamplePlatesAvailable:Acrylic9x9PlateScale
	//need variables here, this may go in Init routine later
	variable HorSize, VertSize
	variable/g xRT, xRB, xLT, xLB
	variable/g yRT, yRB, yLT, yLB
	variable/g xDimension
	variable/g yDimension
	//import the image somehwere
	ImageLoad/T=any/O
	if(V_Flag!=1)
		abort
	endif
	string/g LoadedImageName=S_fileName
	wave imageWave = $(LoadedImageName)
	ImageTransform rgb2gray  imageWave
	Wave M_RGB2Gray
	Duplicate/O M_RGB2Gray, PlateImageTemp
	killwaves/Z imageWave, M_RGB2Gray
	//set values for the variables, for now 0,0 is in top left corner... 
	xRT = dimsize(PlateImageTemp,0)*0.9
	xRB = dimsize(PlateImageTemp,0)*0.9
	xLT = dimsize(PlateImageTemp,0)*0.1
	xLB = dimsize(PlateImageTemp,0)*0.2
	yRT = dimsize(PlateImageTemp,1)*0.1
	yRB = dimsize(PlateImageTemp,1)*0.9
	yLT = dimsize(PlateImageTemp,1)*0.2
	yLB = dimsize(PlateImageTemp,1)*0.8
	if((xDimension+yDimension)<50)
		xDimension = 200	
		yDimension = 100
	endif

	//make image, get user input here so we can trim the image and return it back... 
	KillWindow/Z TrimCorrectImageDrawing
	NewImage/K=1/N=TrimCorrectImageDrawing root:Packages:SamplePlatesAvailable:PlateImageTemp
	Cursor/W=TrimCorrectImageDrawing/C=(65535,0,0)/H=0/I/P/S=1/T={1,1,1}/NUML=1 A, PlateImageTemp, xRT, yRT  
	Cursor/W=TrimCorrectImageDrawing/C=(65535,0,0)/H=0/I/P/S=1/T={1,2,2}/NUML=2 B, PlateImageTemp, xRB, yRB  
	Cursor/W=TrimCorrectImageDrawing/C=(65535,0,0)/H=0/I/P/S=1/T={1,3,3}/NUML=3 C, PlateImageTemp, xLT, yLT  
	Cursor/W=TrimCorrectImageDrawing/C=(65535,0,0)/H=0/I/P/S=1/T={1,4,4}/NUML=4 D, PlateImageTemp, xLB, yLB  
	ControlBar /T/W=TrimCorrectImageDrawing 80
	TitleBox LeftTop title="\Zr120Left top (C) : ",pos={10,5},size={250,15},frame=0,fColor=(0,0,65535),labelBack=0
	SetVariable xLT,pos={10,25},size={90,20}, disable=2, noedit=1,limits={-inf,inf,0},noproc ,title="Xpos = "
	Setvariable xLT,fStyle=2, variable=root:Packages:SamplePlatesAvailable:xLT, help={"This is x postion of C corner"}
	SetVariable yLT,pos={10,45},size={90,20}, disable=2, noedit=1,limits={-inf,inf,0},noproc ,title="Ypos = "
	Setvariable yLT,fStyle=2, variable=root:Packages:SamplePlatesAvailable:yLT, help={"This is y postion of C corner"}

	TitleBox LeftBot title="\Zr120Left bot (D) : ",pos={150,5},size={250,15},frame=0,fColor=(0,0,65535),labelBack=0
	SetVariable xLB,pos={150,25},size={90,20}, disable=2, noedit=1,limits={-inf,inf,0},noproc ,title="Xpos = "
	Setvariable xLB,fStyle=2, variable=root:Packages:SamplePlatesAvailable:xLB, help={"This is x postion of D corner"}
	SetVariable yLB,pos={150,45},size={90,20}, disable=2, noedit=1,limits={-inf,inf,0},noproc ,title="Ypos = "
	Setvariable yLB,fStyle=2, variable=root:Packages:SamplePlatesAvailable:yLB, help={"This is y postion of D corner"}

	TitleBox Dimensions title="\Zr120Dimensions[mm]: ",pos={260,30},size={150,15},frame=0,fColor=(0,0,65535),labelBack=0
	SetVariable xDimension,pos={270,5},size={200,20}, noedit=0,limits={50,500,10},noproc,bodyWidth=70, title="Horizontal [mm] "
	Setvariable xDimension,fStyle=2, variable=root:Packages:SamplePlatesAvailable:xDimension, help={"This is x dimension in mm of C corner"}
	SetVariable yDimension,pos={270,55},size={200,20}, noedit=0,limits={50,500,10},noproc,bodyWidth=70,title="Vertical    [mm] "
	Setvariable yDimension,fStyle=2, variable=root:Packages:SamplePlatesAvailable:yDimension, help={"This is y dimension in mm of C corner"}

	Button TrimImportedImage,pos={400,30},size={120,17}, proc=IN3S_ButtonProc,title="Trim image", help={"Trims the image"}

	TitleBox RightBot title="\Zr120Right bot (B) : ",pos={550,5},size={250,15},frame=0,fColor=(0,0,65535),labelBack=0
	SetVariable xRB,pos={550,25},size={90,20}, disable=2, noedit=1,limits={-inf,inf,0},noproc ,title="Xpos = "
	Setvariable xRB,fStyle=2, variable=root:Packages:SamplePlatesAvailable:xRB, help={"This is x postion of B corner"}
	SetVariable yRB,pos={550,45},size={90,20}, disable=2, noedit=1,limits={-inf,inf,0},noproc ,title="Ypos = "
	Setvariable yRB,fStyle=2, variable=root:Packages:SamplePlatesAvailable:yRB, help={"This is y postion of B corner"}

	TitleBox RightTop title="\Zr120Right top (A) : ",pos={690,5},size={250,15},frame=0,fColor=(0,0,65535),labelBack=0
	SetVariable xRT,pos={690,25},size={90,20}, disable=2, noedit=1,limits={-inf,inf,0},noproc ,title="Xpos = "
	Setvariable xRT,fStyle=2, variable=root:Packages:SamplePlatesAvailable:xRT, help={"This is x postion of A corner"}
	SetVariable yRT,pos={690,45},size={90,20}, disable=2, noedit=1,limits={-inf,inf,0},noproc ,title="Ypos = "
	Setvariable yRT,fStyle=2, variable=root:Packages:SamplePlatesAvailable:yRT, help={"This is y postion of A corner"}

	SetWindow TrimCorrectImageDrawing, hook(CursorsMoved) = IN3S_MyCursorsMovedHook	// Install window hook

	SetDataFolder OldDf

end
//************************************************************************************************************
//************************************************************************************************************

Function IN3S_TrimAndStraightenImage()
	
	
	DFrEF OldDf=GetDataFolderDFR()
	setdatafolder root:Packages:SamplePlatesAvailable
	wave ImageIn = root:Packages:SamplePlatesAvailable:PlateImageTemp
	
	NVAR xRT=root:Packages:SamplePlatesAvailable:xRT
	NVAR xRB=root:Packages:SamplePlatesAvailable:xRB
	NVAR xLT=root:Packages:SamplePlatesAvailable:xLT
	NVAR xLB=root:Packages:SamplePlatesAvailable:xLB
	
	NVAR yRT=root:Packages:SamplePlatesAvailable:yRT
	NVAR yRB=root:Packages:SamplePlatesAvailable:yRB
	NVAR yLT=root:Packages:SamplePlatesAvailable:yLT
	NVAR yLB=root:Packages:SamplePlatesAvailable:yLB

	NVAR xDimension=root:Packages:SamplePlatesAvailable:xDimension
	NVAR yDimension=root:Packages:SamplePlatesAvailable:yDimension
	
	SVAR LoadedImageName=root:Packages:SamplePlatesAvailable:LoadedImageName
	
	variable x1,x2,x3,x4,y1,y2,y3,y4
	x1 = xRT
	x2 = xRB
	x3 = xLT
	x4 = xLB
	y1 = yRT
	y2 = yRB
	y3 = yLT
	y4 = yLB
	
	variable Scaling = 10	//10 points/mm. 0.1 mm/pixel. 
	variable Pwidth
	variable NumPx = xDimension*Scaling
	variable NumPy = yDimension*Scaling
	Pwidth = DimSize(ImageIn,1)/NumPy
	make/O/N=(NumPx, NumPy) PlateImage
	SetScale/I x 0,xDimension,"mm", PlateImage
	SetScale/I y 0,yDimension,"mm", PlateImage

	//now we need to fill this image with interpolated lines... 
	make/N=(NumPx)/O/FREE xwave, ywave
	make/N=(NumPy)/O/FREE dummy
	MatrixOP/O/free pWave=indexRows(xWave)

	MultiThread dummy=IN3S_TrimImgCalcOneLine(p,x1,x2,x3,x4,y1,y2,y3,y4,NumPx-1,NumPy-1,ImageIn,PlateImage, pWave, Pwidth)
	
	//	//create plate drawing. 	
	KillWIndow/Z SamplePlateImageDrawing
	PauseUpdate
	NewImage/K=1/N=SamplePlateImageDrawing root:Packages:SamplePlatesAvailable:PlateImage
	DoWindow/T SamplePlateImageDrawing,"Image of "+LoadedImageName
	//ModifyImage PlateImage ctab= {0,256,Grays,1}
	ModifyGraph margin(left)=28,margin(bottom)=28,margin(top)=28,margin(right)=28
	SetAxis/R left (yDimension+0.125),-0.125
	SetAxis/R top (xDimension+0.125),-0.125
	Label left "\\Zr133millimeters from top right corner"
	Label top "\\Zr133millimeters from top right corner"
	ModifyGraph grid=1
	ModifyGraph mirror=3
	ModifyGraph nticks(left)=22,nticks(top)=22
	ModifyGraph minor=1
	ModifyGraph standoff=0
	ModifyGraph tkLblRot(left)=90
	ModifyGraph btLen=3
	ModifyGraph tlOffset=-2
	DoUpdate
	SetWindow SamplePlateImageDrawing  hook(ImageHook)=IN3S_PlateImageHook

	SetDataFolder OldDf
	
End
//************************************************************************************************************
//************************************************************************************************************

Function IN3S_MyCursorsMovedHook(s)
	STRUCT WMWinHookStruct &s
	
	Variable hookResult = 0	// 0 if we do not handle event, 1 if we handle it.
	NVAR xRT=root:Packages:SamplePlatesAvailable:xRT
	NVAR xRB=root:Packages:SamplePlatesAvailable:xRB
	NVAR xLT=root:Packages:SamplePlatesAvailable:xLT
	NVAR xLB=root:Packages:SamplePlatesAvailable:xLB
	
	NVAR yRT=root:Packages:SamplePlatesAvailable:yRT
	NVAR yRB=root:Packages:SamplePlatesAvailable:yRB
	NVAR yLT=root:Packages:SamplePlatesAvailable:yLT
	NVAR yLB=root:Packages:SamplePlatesAvailable:yLB
	
	switch(s.eventCode)
		case 7:				// cursor moved is 7... 
			//print s.cursorName
			//print s.pointNumber
			//print s.yPointNumber
			strswitch(s.cursorName)
				hookResult =1
				case "A":
					xRT = s.pointNumber
					yRT = s.yPointNumber
					break
				case "B":
					xRB = s.pointNumber
					yRB = s.yPointNumber
					break
				case "C":
					xLT = s.pointNumber
					yLT = s.yPointNumber
					break
				case "D":
					xLB = s.pointNumber
					yLB = s.yPointNumber	
					break
			endswitch	
			break
	endswitch

	return hookResult		// 0 if nothing done, else 1
End

//************************************************************************************************************
//************************************************************************************************************

ThreadSafe static function IN3S_TrimImgCalcOneLine(i,x1,x2,x3,x4,y1,y2,y3,y4,NumPx,NumPy,M_RGB2Gray,DestImage,pWave, Pwidth)
	Variable i,x1,x2,x3,x4,y1,y2,y3,y4,NumPx,NumPy, Pwidth
	Wave M_RGB2Gray,DestImage,pWave


		Variable xfrac = i/(NumPy)
		Variable xstart = (1-xfrac)*x1 + xfrac*x2
		Variable ystart = (1-xfrac)*y1 + xfrac*y2
		Variable xend	=  (1-xfrac)*x3 + xfrac*x4
		Variable yend	=  (1-xfrac)*y3 + xfrac*y4
		Variable xScale=(xend-xstart)/(NumPx)
		Variable yScale=(yend-ystart)/(NumPx)

		MatrixOP/O/FREE xwave=xstart+pWave*xScale		//
		MatrixOP/O/FREE ywave=ystart+pWave*yScale
		ImageLineProfile/V xWave=xwave, yWave=ywave, srcwave=M_RGB2Gray, width=Pwidth

		Wave W_ImageLineProfile
		//DestImage[][i]=W_ImageLineProfile[p]
		//MatrixOP/O DestImage=setCol(DestImage,i,W_ImageLineProfile)
		ImageTransform/G=(i)/D=W_ImageLineProfile putCol DestImage
End
//************************************************************************************************************
//************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//				B E A M L I N E    S U R V E Y    C O D E

//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN3S_BeamlineSurvey()

	//abort if epics support does not exist...
	if(exists("pvOpen")!=4 && IN3SBeamlineSurveyDevelopOn<1)
		Abort "This is useful only at the beamline on usaxspc7 or usaxspc11" 
	endif
	/// abort if instrument in use. 
	IN3S_BeramlineSurveyAbortIfNeeded("Cannot use survey tool")
	//
	Wave/T ListWV = root:Packages:SamplePlateSetup:LBCommandWv
	NVAR SelectedRow=root:Packages:SamplePlateSetup:SelectedRow
	//ControlInfo/W=SamplePlateSetup CommandsList
	variable V_Value=IN3S_FindFirstSelectedRow()
	if(V_Value>=0 && V_Value<DimSize(ListWV,0)-1)
		SelectedRow = V_Value
	else
		SelectedRow = 0
	endif	
	//Sync values
	SVAR SelectedSampleName=root:Packages:SamplePlateSetup:SelectedSampleName
	NVAR SampleThickness=root:Packages:SamplePlateSetup:SampleThickness
	NVAR SampleXTAR=root:Packages:SamplePlateSetup:SampleXTAR
	NVAR SampleYTAR=root:Packages:SamplePlateSetup:SampleYTAR
	NVAR SampleXTable = root:Packages:SamplePlateSetup:SampleXTable
	NVAR SampleYTable = root:Packages:SamplePlateSetup:SampleYTable
	NVAR SampleXRBV=root:Packages:SamplePlateSetup:SampleXRBV
	NVAR SampleYRBV=root:Packages:SamplePlateSetup:SampleYRBV
	Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
	SelectedSampleName = ListWV[SelectedRow][0]
	//ListBox CommandsList, win=SamplePlateSetup, selrow=SelectedRow
	LBSelectionWv[][0]=2
	LBSelectionWv[SelectedRow][0]=3
	SampleXTable = str2num(ListWV[SelectedRow][1])
	SampleYTable = str2num(ListWV[SelectedRow][2])
	SampleThickness = str2num(ListWV[SelectedRow][3])
	SampleThickness = numtype(SampleThickness)==0 ? SampleThickness : 1
	IN3S_AddTagToImage(SelectedRow)			
	DoWIndow BeamlinePlateSetup
	if(V_Flag)
		DoWindow/F BeamlinePlateSetup
	else
		IN3S_BeamlineSurveyPanel()
	endif
	SetWindow BeamlinePlateSetup  hook(EpicsMon)=IN3S_BeamlineSurveyEpicsHook
	IN3S_BeamlineSurveyStartEpicsUpdate()
	//sync epics, RBV and TAR positions here
#if(exists("pvOpen")==4)
	variable SxPV, SyPV
	pvOpen/Q SxPV, "9idcLAX:m58:c2:m1.RBV"
	pvOpen/Q SyPV, "9idcLAX:m58:c2:m2.RBV"
	pvWait 5
	//this needs to be in background function and in 10Hz loop. 	
	SampleXRBV = IN3S_GetMotorPositions(SxPV)
	SampleYRBV = IN3S_GetMotorPositions(SyPV)
	//end of background function loop. 
	pvClose SxPV
	pvClose SyPV
#endif
	SampleXTAR = SampleXRBV
	SampleYTAR = SampleYRBV
end

//*************************************************************************************************
//*************************************************************************************************
static Function IN3S_BeramlineSurveyAbortIfNeeded(string WhyString)
	variable InstrumentUsed
#if(exists("pvOpen")==4)
		InstrumentUsed = IN3S_GetPVVariableValue("9idcLAX:dataColInProgress")	
		if(InstrumentUsed)
			abort "Instrument is collecting data, cannot "+WhyString
		endif
#endif
end
//*************************************************************************************************
static Function IN3S_BeamlineSurveyStartEpicsUpdate()
	//this starts updating epics.
	CtrlNamedBackground IN2SMonitorEpics, period=IN3SBeamlineSurveyEpicsMonTicks, proc=IN3S_BackgroundEpics 
	CtrlNamedBackground IN2SMonitorEpics, start
	return 0
end
//*************************************************************************************************
static Function IN3S_BeamlineSurveyStopEpicsUpdate()
	//this starts updating epics.
	//CtrlNamedBackground IN2SMonitorEpics, period=IN3SBeamlineSurveyEpicsMonTicks, proc=IN3S_BackgroundEpics 
	CtrlNamedBackground IN2SMonitorEpics, stop
	return 1
end
//*************************************************************************************************
Function IN3S_BeamlineSurveyEpicsHook(s)
	STRUCT WMWinHookStruct &s

	if(stringMatch(s.winName, "BeamlinePlateSetup"))
		switch( s.eventCode )
			case 0: // window being activated
				IN3S_BeamlineSurveyStartEpicsUpdate()
				break
			case 1: // window being deactivated
				//IN3S_BeamlineSurveyStopEpicsUpdate()
				break
			case 2: // window being killed
				IN3S_BeamlineSurveyStopEpicsUpdate()
				break
			case 15: // hide
				IN3S_BeamlineSurveyStopEpicsUpdate()
				break
			case 16: // show
				IN3S_BeamlineSurveyStartEpicsUpdate()
				break
			case 7: // finish edit
				break
		endswitch
	endif
	return 0
end
//*************************************************************************************************
Function IN3S_BackgroundEpics(s) // This is the function that will be called periodically 
	STRUCT WMBackgroundStruct &s	//note: cannot be static or things will not work. 
	NVAR SampleXRBV=root:Packages:SamplePlateSetup:SampleXRBV
	NVAR SampleYRBV=root:Packages:SamplePlateSetup:SampleYRBV
#if(exists("pvOpen")==4)
	variable SxPV, SyPV
	pvOpen/Q SxPV, "9idcLAX:m58:c2:m1.RBV"
	pvOpen/Q SyPV, "9idcLAX:m58:c2:m2.RBV"
	pvWait 5
	//this needs to be in background function and in 10Hz loop. 	
	SampleXRBV = IN3S_GetMotorPositions(SxPV)
	SampleYRBV = IN3S_GetMotorPositions(SyPV)
	//end of background function loop. 
	pvClose SxPV
	pvClose SyPV
#endif
	return 0
end
//*************************************************************************************************
static function IN3S_GetMotorPositions(SPV)
	variable SPV

#if(exists("pvOpen")==4)
	variable tempRBV
	pvGet SPV, tempRBV
	return tempRBV
#endif
end
//*************************************************************************************************
static function IN3S_GetPVVariableValue(PVString)
	string  PVString

#if(exists("pvOpen")==4)
	variable tempRBV, PVv
	pvOpen/Q PVv, PVString
	pvGet PVv, tempRBV
	pvClose PVv
	return tempRBV
#endif
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function IN3S_BeamlineSurveyPanel()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SamplePlateSetup
	/// abort if instrument in use. 
	IN3S_BeramlineSurveyAbortIfNeeded("Cannot use survey tool")
	
	DoWindow BeamlinePlateSetup
	if(V_Flag)
		DoWindow/F BeamlinePlateSetup
	else
		PauseUpdate    		// building window...
		NewPanel /K=1 /W=(592.25,43.25,1000,550)/N=BeamlinePlateSetup as "Beamline Sample Plate survey"
		SetDrawLayer UserBack
		//SetDrawEnv fillfgc= (16386,65535,16385),fillbgc= (0,65535,0)
		//SetDrawEnv linefgc= (32792,65535,1),fillbgc= (32792,65535,1),fillfgc= (32792,65535,1)
		SetDrawEnv linefgc= (49151,65535,49151),fillbgc= (49151,65535,49151),fillfgc= (49151,65535,49151)
		DrawRect 194,175,400,198
		SetDrawEnv fillfgc= (49151,65535,49151)
		DrawRRect 6,234,189,400
		SetDrawEnv fillfgc= (49151,65535,49151)
		DrawRRect 212,234,395,400
		TitleBox Title title="\Zr210Beamline survey",pos={50,3},frame=0,fstyle=3,size={300,24},fColor=(1,4,52428), anchor=MC
		//selected row and sample name
		SetVariable SelectedRow,pos={100,40},size={180,20}, limits={0,200,0}, proc=IN3S_SurveySetVarProc,title="Selected row: ",fSize=14
		Setvariable SelectedRow,fStyle=2, variable=root:Packages:SamplePlateSetup:SelectedRow, help={"Selected row in the table"},format="%3.0f"

		Button MoveRowUp,pos={80,70},size={100,25}, proc=IN3S_SurveyButtonProc,title="Row ⇑",fSize=14, help={"Moves row up (lower row number)"}
		Button MoveRowDown,pos={220,70},size={100,25}, proc=IN3S_SurveyButtonProc,title="Row ⇓",fSize=14, help={"Moves row up (lower row number)"}
		SetVariable SelectedSampleName,pos={10,105},size={370,25}, limits={0,200,1}, proc=IN3S_SurveySetVarProc,title="Sa Name: ",fSize=14
		Setvariable SelectedSampleName,fStyle=2, variable=root:Packages:SamplePlateSetup:SelectedSampleName, help={"Sample name from the table or saved to table"}
		SetVariable SampleThickness,pos={20,130},size={250,25}, limits={0,20,0.1}, proc=IN3S_SurveySetVarProc,title="Sa Thickness [mm]: ",fSize=14
		Setvariable SampleThickness,fStyle=2, variable=root:Packages:SamplePlateSetup:SampleThickness, help={"Sample Thickness in mm"},format="%3.3f"
		Button GoTo00,pos={300,130},size={100,15}, proc=IN3S_SurveyButtonProc,title="Go 0,0",fSize=14, help={"Moves to 0,0"}
		Button GoTo00 fColor=(0,65535,0)

		SetVariable SampleXTable,pos={30,155},size={130,15}, limits={-inf,inf,0}, noproc, noedit=1,title="Sa X tbl =",fSize=12, frame=0
		Setvariable SampleXTable,fStyle=2, variable=root:Packages:SamplePlateSetup:SampleXTable, help={"Sample Thickness in mm"},format="%3.2f"
		SetVariable SampleYTable,pos={220,155},size={130,15}, limits={-inf,inf,0}, proc=IN3S_SetVarProc,title="Sa Y tbl =",fSize=12, frame=0
		Setvariable SampleYTable,fStyle=2, variable=root:Packages:SamplePlateSetup:SampleYTable, help={"Sample Thickness in mm"},format="%3.2f"
		
		Button DriveTovals,pos={10,178},size={160,20}, proc=IN3S_SurveyButtonProc,title="Drive to table values",fSize=12, help={"Moves SX and SY to table positions"}
		Button DriveTovals fColor=(0,65535,0)
		CheckBox MoveWhenRowChanges pos={200,180},size={70,20},title="Drive to SX/SY on row change?", help={"When selected, SX and SY will move when row is changed"}
		CheckBox MoveWhenRowChanges variable=root:Packages:SamplePlateSetup:MoveWhenRowChanges,  noproc, fColor=(0,0,0),labelBack=(49151,65535,49151)

		//save values...
		Button SaveValues,pos={100,208.00},size={200,20}, proc=IN3S_SurveyButtonProc,title="Save Values",fSize=14, help={"Copies values to the table of positions"}
		Button SaveValues fColor=(65535,32768,32768)

		TitleBox Info1 title="\Zr200Sx : ",pos={45,238},size={20,15},frame=0,fColor=(0,0,65535),labelBack=0,fstyle=1
		TitleBox Info2 title="\Zr200Sy : ",pos={265,238},size={20,15},frame=0,fColor=(0,0,65535),labelBack=0,fstyle=1
		SetVariable SampleXRBV,pos={80,238},size={60,30}, limits={-200,200, 0}, noproc,title=" ",fSize=18, noedit=1, frame=0
		SetVariable SampleXRBV,variable=root:Packages:SamplePlateSetup:SampleXRBV, help={"SX RBV position"},format="%6.2f"
		SetVariable SampleYRBV,pos={300,238},size={60,30}, limits={-200,200, 0}, noproc,title=" ",fSize=18, noedit=1, frame=0
		SetVariable SampleYRBV,variable=root:Packages:SamplePlateSetup:SampleYRBV, help={"SY RBV position"},format="%6.2f"

		SetVariable SampleXTAR,pos={50,270},size={90,30}, limits={-200,200, 0}, proc=IN3S_SurveySetVarProc,title=" ",fSize=25
		Setvariable SampleXTAR,fStyle=2, variable=root:Packages:SamplePlateSetup:SampleXTAR, help={"SX position"},format="%6.2f"
		SetVariable SampleYTAR,pos={260,270},size={90,30}, limits={-200,200, 0}, proc=IN3S_SurveySetVarProc,title=" ",fSize=25
		Setvariable SampleYTAR,fStyle=2, variable=root:Packages:SamplePlateSetup:SampleYTAR, help={"SY position"},format="%6.2f"

		Button MoveSXLow,pos={10,260},size={30,50}, proc=IN3S_SurveyButtonProc,title="-",help={"Moves SX lower by the step value"}
		Button MoveSXLow,fSize=24,fstyle=1,fColor=(1,16019,65535)
		Button MoveSXHigh,pos={150,260},size={30,50}, proc=IN3S_SurveyButtonProc,title="+",help={"Moves SX higher by the step value"}
		Button MoveSXHigh,fSize=24,fstyle=1,fColor=(1,16019,65535)

		Button MoveSYLow,pos={220,260},size={30,50}, proc=IN3S_SurveyButtonProc,title="-",help={"Moves SY lower by the step value"}
		Button MoveSYLow,fSize=24,fstyle=1,fColor=(1,16019,65535)
		Button MoveSYHigh,pos={360,260},size={30,50}, proc=IN3S_SurveyButtonProc,title="+",help={"Moves SY higher by the step value"}
		Button MoveSYHigh,fSize=24,fstyle=1,fColor=(1,16019,65535)


		TitleBox Info3 title="\Zr130Sx step : ",pos={50,310},size={250,15},frame=0,fColor=(0,0,65535),labelBack=0,fstyle=1
		TitleBox Info4 title="\Zr130Sy step : ",pos={265,310},size={250,15},frame=0,fColor=(0,0,65535),labelBack=0,fstyle=1

		SetVariable SurveySXStep,pos={52,330},size={90,20}, limits={0,100, 1}, proc=IN3S_SurveySetVarProc,title=" ",fSize=20
		Setvariable SurveySXStep,fStyle=2, variable=root:Packages:SamplePlateSetup:SurveySXStep, help={"SX step"},format="%6.2f"
		SetVariable SurveySYStep,pos={262,330},size={90,20}, limits={0,100, 1}, proc=IN3S_SurveySetVarProc,title=" ",fSize=20
		Setvariable SurveySYStep,fStyle=2, variable=root:Packages:SamplePlateSetup:SurveySYStep, help={"SY step"},format="%6.2f"


		Button ChangeSXStepLow,pos={10,370},size={75,20}, proc=IN3S_SurveyButtonProc,title="x 0.1",fSize=14, help={"Changes SX step by 0.1"}
		Button ChangeSXStepHigh,pos={100,370},size={75,20}, proc=IN3S_SurveyButtonProc,title="x 10",fSize=14, help={"Changes SX step by 10"}

		Button ChangeSYStepLow,pos={220,370},size={75,20}, proc=IN3S_SurveyButtonProc,title="x 0.1",fSize=14, help={"Changes SX step by 0.1"}
		Button ChangeSYStepHigh,pos={310,370},size={75,20}, proc=IN3S_SurveyButtonProc,title="x 10",fSize=14, help={"Changes SX step by 10"}

		Button SetSXAs00,pos={50,405},size={70,15}, proc=IN3S_SurveyButtonProc,title="Set SX 0",fSize=14, help={"Sets current position as 0,0"}
		Button SetSXAs00 fColor=(65535,32768,32768)
		Button SetSYAs00,pos={260,405},size={70,15}, proc=IN3S_SurveyButtonProc,title="Set SY 0",fSize=14, help={"Sets current position as 0,0"}
		Button SetSYAs00 fColor=(65535,32768,32768)

		Button SyncMotors,pos={10,425},size={105,15}, proc=IN3S_SurveyButtonProc,title="Sync w/epics",fSize=14, help={"Sync all motors positons with epics"}
		Button STOPMotors,pos={10,450},size={105,30}, proc=IN3S_SurveyButtonProc,title="STOP motors",fSize=14, help={"STOP ALL MOTORS MOVEMENT"}
		Button STOPMotors fColor=(65535,32768,32768)

		Button OpenSlitsLarge,pos={250,425},size={135,20}, proc=IN3S_SurveyButtonProc,title="Open Slits Large",fSize=14, help={"Open slits as large as possible"}
		Button OpenSlitsUSAXS,pos={250,450},size={135,20}, proc=IN3S_SurveyButtonProc,title="USAXS Slits",fSize=14, help={"Open Slits for USAXS"}
		Button OpenSlitsSWAXS,pos={250,475},size={135,20}, proc=IN3S_SurveyButtonProc,title="SWAXS Slits",fSize=14, help={"Open Slits for SAXS/WAXS"}

		TitleBox Info5 title="\Zr110NOTE: row numbering is 0 based...",size={355,20},pos={5,485},frame=0,fColor=(0,0,65535),labelBack=0

	endif

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function IN3S_SurveySetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			if(StringMatch(sva.ctrlName, "SelectedRow"))
				NVAR SelectedRow=root:Packages:SamplePlateSetup:SelectedRow
				SVAR SelectedSampleName=root:Packages:SamplePlateSetup:SelectedSampleName
				Wave/T ListWV = root:Packages:SamplePlateSetup:LBCommandWv
				NVAR SampleThickness=root:Packages:SamplePlateSetup:SampleThickness
				NVAR SampleXTAR=root:Packages:SamplePlateSetup:SampleXTAR
				NVAR SampleYTAR=root:Packages:SamplePlateSetup:SampleYTAR
				NVAR SampleXTable = root:Packages:SamplePlateSetup:SampleXTable
				NVAR SampleYTable = root:Packages:SamplePlateSetup:SampleYTable
				NVAR DefSaThick = root:Packages:SamplePlateSetup:DefaultSampleThickness
				if(SelectedRow>DimSize(ListWV,0)-2)
					IN3S_InsertDeleteLines(4, SelectedRow, 1)
				endif
				SelectedRow=SelectedRow+1
				SelectedSampleName = ListWV[SelectedRow][0]
				//ListBox CommandsList, win=SamplePlateSetup, selrow=SelectedRow
				Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
				LBSelectionWv[][0]=2
				LBSelectionWv[SelectedRow][0]=3
				SampleXTable = str2num(ListWV[SelectedRow][1])
				SampleYTable = str2num(ListWV[SelectedRow][2])
				SampleThickness = str2num(ListWV[SelectedRow][3])
				SampleThickness = numtype(SampleThickness)==0 ? SampleThickness : DefSaThick
				IN3S_AddTagToImage(SelectedRow)
				IN3S_EstimateRunTime()			
			endif
			
			if(StringMatch(sva.ctrlName, "SampleXTAR"))
				IN3S_BeamlineSurveyStartEpicsUpdate()
				IN3S_MoveMotorInEpics("SX",dval)
			endif
			if(StringMatch(sva.ctrlName, "SampleYTAR"))
				IN3S_BeamlineSurveyStartEpicsUpdate()
				IN3S_MoveMotorInEpics("SY",dval)	
			endif
			if(StringMatch(sva.ctrlName, "SelectedSampleName"))
				SVAR SelectedSampleName = root:Packages:SamplePlateSetup:SelectedSampleName
				SelectedSampleName = CleanupName(sval, 0 , 40)
			endif
			if(StringMatch(sva.ctrlName, "SampleThickness"))
				NVAR SampleThickness = root:Packages:SamplePlateSetup:SampleThickness
				if(dval<0 || dval>20)
					DoAlert /T="Wrong thickness" 0, "Thickness must be between 0 and 20 [mm]"
					SampleThickness = DefSaThick
				endif
			endif
		
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function IN3S_SurveyButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			NVAR SXStep = root:Packages:SamplePlateSetup:SurveySXStep
			NVAR SYStep = root:Packages:SamplePlateSetup:SurveySYStep
//			NVAR CurentSX=root:Packages:SamplePlateSetup:SampleXTAR
//			NVAR CurentSY=root:Packages:SamplePlateSetup:SampleYTAR
			NVAR SampleXTAR = root:Packages:SamplePlateSetup:SampleXTAR
			NVAR SampleYTAR = root:Packages:SamplePlateSetup:SampleYTAR
			NVAR SampleXRBV = root:Packages:SamplePlateSetup:SampleXRBV
			NVAR SampleYRBV = root:Packages:SamplePlateSetup:SampleYRBV
			Wave LBSelectionWv = root:Packages:SamplePlateSetup:LBSelectionWv
			if(StringMatch(ba.ctrlName, "MoveSXLow"))		
				SampleXTAR = SampleXTAR-SXStep
				IN3S_MoveMotorInEpics("SX",SampleXTAR)			
			endif
			if(StringMatch(ba.ctrlName, "MoveSXHigh"))
				SampleXTAR = SampleXTAR+SXStep
				IN3S_MoveMotorInEpics("SX",SampleXTAR)
			endif
			if(StringMatch(ba.ctrlName, "MoveSYLow"))		
				SampleyTAR = SampleYTAR-SyStep
				IN3S_MoveMotorInEpics("SY",SampleyTAR)
			endif
			if(StringMatch(ba.ctrlName, "MoveSYHigh"))
				SampleyTAR = SampleYTAR+SyStep
				IN3S_MoveMotorInEpics("SY",SampleyTAR)
			endif
			if(StringMatch(ba.ctrlName, "ChangeSXStepLow"))
				SXStep = (SXStep<0.01 || SXStep>100) ? 1 : SXStep
				SXStep = SXStep>0.1 ? SXStep*0.1 : 0.01
			endif
			if(StringMatch(ba.ctrlName, "ChangeSXStepHigh"))
				SXStep = (SXStep<0.01 || SXStep>100) ? 1 : SXStep
				SXStep = SXStep<10 ? SXStep*10 : 100
			endif

			if(StringMatch(ba.ctrlName, "ChangeSYStepLow"))
				SYStep = (SYStep<0.01 || SYStep>100) ? 1 : SYStep
				SYStep = SYStep>0.1 ? SYStep*0.1 : 0.01
			endif
			if(StringMatch(ba.ctrlName, "ChangeSYStepHigh"))
				SYStep = (SYStep<0.01 || SYStep>100) ? 1 : SYStep
				SYStep = SYStep<10 ? SYStep*10 : 100
			endif
			
			if(StringMatch(ba.ctrlName, "GoTo00"))
				SampleXTAR = 0
				SampleYTAR = 0
				IN3S_MoveMotorInEpics("SX",SampleXTAR)
				IN3S_MoveMotorInEpics("SY",SampleYTAR)
			endif
			if(StringMatch(ba.ctrlName, "SyncMotors"))
#if(exists("pvOpen")==4)
				variable SxPV, SyPV
				pvOpen/Q SxPV, "9idcLAX:m58:c2:m1.RBV"
				pvOpen/Q SyPV, "9idcLAX:m58:c2:m2.RBV"
				SampleXTAR = IN3S_GetMotorPositions(SxPV)
				SampleYTAR = IN3S_GetMotorPositions(SyPV)
				SampleXRBV = IN3S_GetMotorPositions(SxPV)
				SampleYRBV = IN3S_GetMotorPositions(SyPV)
				pvWait 5
				pvClose SxPV
				pvClose SyPV
#endif
			endif
			variable InstrumentUsed
			if(StringMatch(ba.ctrlName, "SetSXAs00"))
#if(exists("pvOpen")==4)
					InstrumentUsed = IN3S_GetPVVariableValue("9idcLAX:dataColInProgress")	
					if(InstrumentUsed)
						abort "Instrument is collecting data, cannot move motors"
					else	
						//"SX"
						IN3S_PutEpicsPv("9idcLAX:m58:c2:m1.SSET", 1)
						sleep/T 10
						IN3S_PutEpicsPv("9idcLAX:m58:c2:m1.VAL", 0)
						sleep/T 10
						IN3S_PutEpicsPv("9idcLAX:m58:c2:m1.SUSE", 1)
					endif
				SampleXTAR = 0
#endif
			endif		
			if(StringMatch(ba.ctrlName, "SetSYAs00"))
#if(exists("pvOpen")==4)
					InstrumentUsed = IN3S_GetPVVariableValue("9idcLAX:dataColInProgress")	
					if(InstrumentUsed)
						abort "Instrument is collecting data, cannot move motors"
					else	
						//"SY"
						IN3S_PutEpicsPv("9idcLAX:m58:c2:m2.SSET", 1)
						sleep/T 10
						IN3S_PutEpicsPv("9idcLAX:m58:c2:m2.VAL", 0)
						sleep/T 10
						IN3S_PutEpicsPv("9idcLAX:m58:c2:m2.SUSE", 1)
					endif
				SampleYTAR = 0
#endif
			endif		
			if(StringMatch(ba.ctrlName, "STOPMotors"))
#if(exists("pvOpen")==4)
					InstrumentUsed = IN3S_GetPVVariableValue("9idcLAX:dataColInProgress")	
					if(InstrumentUsed)
						abort "Instrument is collecting data, cannot move motors"
					else	
						IN3S_PutEpicsPv("9idcLAX:alltop", 1)
					endif
#endif
			endif		
			variable HorSlit, VertSLit, HorGuardSlit, VertGuardSlit
			if(StringMatch(ba.ctrlName, "OpenSlitsLarge"))
#if(exists("pvOpen")==4)
					InstrumentUsed = IN3S_GetPVVariableValue("9idcLAX:dataColInProgress")	
					if(InstrumentUsed)
						abort "Instrument is collecting data, cannot move motors"
					else	
						//c2:m8 is Horizontal slit size
						IN3S_PutEpicsPv("9idcLAX:m58:c2:m8.VAL", 2.5)
						IN3S_PutEpicsPv("9idcLAX:GSlit1H:size", 2.8)
						//c2:m8 is Vertical slit size
						IN3S_PutEpicsPv("9idcLAX:m58:c2:m7.VAL", 1.2)
						IN3S_PutEpicsPv("9idcLAX:GSlit1V:size", 1.4)
					endif
#endif
			endif		

			if(StringMatch(ba.ctrlName, "OpenSlitsUSAXS"))
#if(exists("pvOpen")==4)
					InstrumentUsed = IN3S_GetPVVariableValue("9idcLAX:dataColInProgress")	
					if(InstrumentUsed)
						abort "Instrument is collecting data, cannot move motors"
					else	
						HorSlit = IN3S_GetPVVariableValue("9idcLAX:USAXS_hslit_ap")
						VertSLit = IN3S_GetPVVariableValue("9idcLAX:USAXS_vslit_ap")
						HorGuardSlit = IN3S_GetPVVariableValue("9idcLAX:USAXS_hgslit_ap")
						VertGuardSlit = IN3S_GetPVVariableValue("9idcLAX:USAXS_vgslit_ap")
						//c2:m8 is Horizontal slit size
						IN3S_PutEpicsPv("9idcLAX:m58:c2:m8.VAL", HorSlit)
						IN3S_PutEpicsPv("9idcLAX:GSlit1H:size", HorGuardSlit)
						//c2:m8 is Vertical slit size
						IN3S_PutEpicsPv("9idcLAX:m58:c2:m7.VAL", VertSLit)
						IN3S_PutEpicsPv("9idcLAX:GSlit1V:size", VertGuardSlit)
					endif
#endif
			endif		
			if(StringMatch(ba.ctrlName, "OpenSlitsSWAXS"))
#if(exists("pvOpen")==4)
					InstrumentUsed = IN3S_GetPVVariableValue("9idcLAX:dataColInProgress")	
					if(InstrumentUsed)
						abort "Instrument is collecting data, cannot move motors"
					else	
						HorSlit = IN3S_GetPVVariableValue("9idcLAX:SAXS_hslit_ap")
						VertSLit = IN3S_GetPVVariableValue("9idcLAX:SAXS_vslit_ap")
						HorGuardSlit = IN3S_GetPVVariableValue("9idcLAX:SAXS_hgslit_ap")
						VertGuardSlit = IN3S_GetPVVariableValue("9idcLAX:SAXS_vgslit_ap")
						//c2:m8 is Horizontal slit size
						IN3S_PutEpicsPv("9idcLAX:m58:c2:m8.VAL", HorSlit)
						IN3S_PutEpicsPv("9idcLAX:GSlit1H:size", HorGuardSlit)
						//c2:m8 is Vertical slit size
						IN3S_PutEpicsPv("9idcLAX:m58:c2:m7.VAL", VertSLit)
						IN3S_PutEpicsPv("9idcLAX:GSlit1V:size", VertGuardSlit)
					endif
#endif
			endif		
		
			if(StringMatch(ba.ctrlName, "MoveRowUp"))
				Wave SelWv=root:Packages:SamplePlateSetup:LBSelectionWv
				NVAR SelectedRow=root:Packages:SamplePlateSetup:SelectedRow
				SVAR SelectedSampleName=root:Packages:SamplePlateSetup:SelectedSampleName
				Wave/T ListWV = root:Packages:SamplePlateSetup:LBCommandWv
				NVAR SampleThickness=root:Packages:SamplePlateSetup:SampleThickness
				NVAR SampleXTAR=root:Packages:SamplePlateSetup:SampleXTAR
				NVAR SampleYTAR=root:Packages:SamplePlateSetup:SampleYTAR
				NVAR SampleXTable = root:Packages:SamplePlateSetup:SampleXTable
				NVAR SampleYTable = root:Packages:SamplePlateSetup:SampleYTable
				NVAR DefSaThick = root:Packages:SamplePlateSetup:DefaultSampleThickness
				if(SelectedRow>0)
					SelectedRow=SelectedRow-1
					SelWv[][0]=2
					SelWv[SelectedRow]=3
					SelectedSampleName = ListWV[SelectedRow][0]
					//LBSelectionWv[][0]=2
					//LBSelectionWv[SelectedRow][0]=3
					SampleXTable = str2num(ListWV[SelectedRow][1])
					SampleYTable = str2num(ListWV[SelectedRow][2])
					SampleThickness = str2num(ListWV[SelectedRow][3])
					SampleThickness = numtype(SampleThickness)==0 ? SampleThickness : DefSaThick
				endif
				IN3S_AddTagToImage(SelectedRow)
				SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
				WarningForUser = "Moved selected row up" 
				IN3S_MoveToPositionIfOK()
				IN3S_EstimateRunTime()
			endif
			if(StringMatch(ba.ctrlName, "MoveRowDown"))
				Wave SelWv=root:Packages:SamplePlateSetup:LBSelectionWv
				NVAR SelectedRow=root:Packages:SamplePlateSetup:SelectedRow
				SVAR SelectedSampleName=root:Packages:SamplePlateSetup:SelectedSampleName
				Wave/T ListWV = root:Packages:SamplePlateSetup:LBCommandWv
				NVAR SampleThickness=root:Packages:SamplePlateSetup:SampleThickness
				NVAR SampleXTAR=root:Packages:SamplePlateSetup:SampleXTAR
				NVAR SampleYTAR=root:Packages:SamplePlateSetup:SampleYTAR
				NVAR SampleXTable = root:Packages:SamplePlateSetup:SampleXTable
				NVAR SampleYTable = root:Packages:SamplePlateSetup:SampleYTable
				NVAR DefSaThick = root:Packages:SamplePlateSetup:DefaultSampleThickness
				if(SelectedRow>DimSize(ListWV,0)-2)
					IN3S_InsertDeleteLines(4, SelectedRow, 1)
				endif
				SelectedRow=SelectedRow+1
				SelWv[][0]=2
				SelWv[SelectedRow]=3
				SelectedSampleName = ListWV[SelectedRow][0]
				//LBSelectionWv[][0]=2
				//LBSelectionWv[SelectedRow][0]=3
				SampleXTable = str2num(ListWV[SelectedRow][1])
				SampleYTable = str2num(ListWV[SelectedRow][2])
				SampleThickness = str2num(ListWV[SelectedRow][3])
				SampleThickness = numtype(SampleThickness)==0 ? SampleThickness : DefSaThick
				IN3S_AddTagToImage(SelectedRow)
				SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
				WarningForUser = "Moved selected row down" 
				IN3S_MoveToPositionIfOK()
				IN3S_EstimateRunTime()
			endif
			if(StringMatch(ba.ctrlName, "DriveTovals"))
				NVAR SelectedRow=root:Packages:SamplePlateSetup:SelectedRow
				Wave/T ListWV = root:Packages:SamplePlateSetup:LBCommandWv
				NVAR SampleXTable = root:Packages:SamplePlateSetup:SampleXTable
				NVAR SampleYTable = root:Packages:SamplePlateSetup:SampleYTable
				NVAR SampleXTAR = root:Packages:SamplePlateSetup:SampleXTAR
				NVAR SampleYTAR = root:Packages:SamplePlateSetup:SampleYTAR
				SampleXTAR = SampleXTable
				SampleYTAR = SampleYTable
				IN3S_MoveMotorInEpics("SX",SampleXTAR)	
				IN3S_MoveMotorInEpics("SY",SampleYTAR)
				SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
				WarningForUser = "Moved to sample position from table" 
			endif
			if(StringMatch(ba.ctrlName, "SaveValues"))
				NVAR SelectedRow=root:Packages:SamplePlateSetup:SelectedRow
				NVAR SampleThickness=root:Packages:SamplePlateSetup:SampleThickness
				SVAR SelectedSampleName=root:Packages:SamplePlateSetup:SelectedSampleName
				NVAR SampleXRBV=root:Packages:SamplePlateSetup:SampleXRBV
				NVAR SampleYRBV=root:Packages:SamplePlateSetup:SampleYRBV
				Wave/T ListWV = root:Packages:SamplePlateSetup:LBCommandWv
				ListWV[SelectedRow][0] = SelectedSampleName
				ListWV[SelectedRow][1] = num2str(IN2G_RoundDecimalPlaces(SampleXRBV,3))
				ListWV[SelectedRow][2] = num2str(IN2G_RoundDecimalPlaces(SampleYRBV,3))
				ListWV[SelectedRow][3] = num2str(IN2G_RoundDecimalPlaces(SampleThickness,3))
				NVAR SelectedRow=root:Packages:SamplePlateSetup:SelectedRow
				IN3S_AddTagToImage(SelectedRow)
				SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
				WarningForUser = "Saved positions to table" 
				NVAR TableIsSaved = root:Packages:SamplePlateSetup:TableIsSaved
				TableIsSaved = 0
				IN3S_FixSaveButton()				
				IN3S_EstimateRunTime()
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IN3S_MoveToPositionIfOK()
	//moves to SX and SY on row change, if OK
	//root:Packages:SamplePlateSetup:MoveWhenRowChanges = 1
	//panel BeamlinePlateSetup exists
	DoWindow BeamlinePlateSetup
	if(V_Flag)	//exists
		NVAR ShouldMove=root:Packages:SamplePlateSetup:MoveWhenRowChanges
		if(ShouldMove)
			NVAR SampleXTAR=root:Packages:SamplePlateSetup:SampleXTAR
			NVAR SampleYTAR=root:Packages:SamplePlateSetup:SampleYTAR
			NVAR TableSX=root:Packages:SamplePlateSetup:SampleXTable
			NVAR TableSY=root:Packages:SamplePlateSetup:SampleYTable
			if(numtype(TableSX)==0 && numtype(TableSY)==0) //are these numbers?
				SampleXTAR = TableSX
				SampleYTAR = TableSY
				IN3S_MoveMotorInEpics("SX",TableSX)
				IN3S_MoveMotorInEpics("SY",TableSY)	
				//SVAR WarningForUser = root:Packages:SamplePlateSetup:WarningForUser
				//WarningForUser = "Moving to SX and SY position read from Table" 
			endif
		endif
	endif
end
//*****************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

static Function IN3S_MoveMotorInEpics(WhichMotor,MovePosition)
	string WhichMotor		//SX or SY
	variable MovePosition	
	//avoid moving if instrument is running, 9idcLAX:dataColInProgress = 1
	variable InstrumentUsed=0
#if(exists("pvOpen")==4)
	InstrumentUsed = IN3S_GetPVVariableValue("9idcLAX:dataColInProgress")	
	if(InstrumentUsed)
		abort "Instrument is collecting data, cannot move motors"
	else	
		if(stringMatch(WhichMotor,"SX"))
			IN3S_PutEpicsPv("9idcLAX:m58:c2:m1.VAL", MovePosition)
		elseif(stringMatch(WhichMotor,"SY"))
			IN3S_PutEpicsPv("9idcLAX:m58:c2:m2.VAL", MovePosition)
		endif
	endif
#else
	print "Could not move motors, no epics installed"
#endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

static Function IN3S_PutEpicsPv(PVAddress, target)	//note, this waits until motor is done moving...
	string PVAddress
	variable target
#if(exists("pvOpen")==4)
	variable sxRBV
	pvOpen/T=5 sxRBV, PVAddress				// /T is timeout, should wait only this timeout. 
	pvPutNumber/Q sxRBV, target				// /Q returns immediately, else waits until completion.  
	pvClose sxRBV
#endif	
end

//*****************************************************************************************************************
//*****************************************************************************************************************

//			      E N D     B E A M L I N E    S U R V E Y    C O D E

//*****************************************************************************************************************
//*****************************************************************************************************************

//Function IN3S_ExportHookFunction(Command, SampleName,SX, SY, Thickness, MD)
//	string Command, SampleName,SX, SY, Thickness, MD 
//	//this hook function will modify output of the command file for given line. This needs to be cutomized for specific need. 
//	SVAR nbl=root:Packages:SamplePlateSetup:NotebookName
//
//	//in this case it will write each command in notebook multiple times, in original position and then +/- 1mm in sx and sy
//	//center	
//	Notebook $nbl text="      "+Command+"        "+SX+"      "+SY+"      "+Thickness+"      \""+SampleName+"\"  \r"
//	//and now the variations, only if Sample Name is NOT Blank or Empty
//	if(!StringMatch(SampleName, "*Blank*")&&!StringMatch(SampleName, "*Empty*"))
//		string TempStr
//		TempStr = num2str(str2num(SX)-1)
//		Notebook $nbl text="      "+Command+"        "+TempStr+"      "+SY+"      "+Thickness+"      \""+SampleName+"_R"+"\"  \r"
//		TempStr = num2str(str2num(SX)+1)
//		Notebook $nbl text="      "+Command+"        "+TempStr+"      "+SY+"      "+Thickness+"      \""+SampleName+"_L"+"\"  \r"
//		TempStr = num2str(str2num(SY)-1)
//		Notebook $nbl text="      "+Command+"        "+SX+"      "+TempStr+"      "+Thickness+"      \""+SampleName+"_B"+"\"  \r"
//		TempStr = num2str(str2num(SY)+1)
//		Notebook $nbl text="      "+Command+"        "+SX+"      "+TempStr+"      "+Thickness+"      \""+SampleName+"_T"+"\"  \r"
//	endif	
//end
