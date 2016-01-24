#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1
#include <Multi-peak fitting 2.0>

//local configurations
Strconstant  WAXSPDF4Location= "WAXS_PDFCards"
constant IR3WversionNumber = 0.3		//Diffraction panel version number

//*************************************************************************\
//* Copyright (c) 2005 - 2015, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//0.31 removed eps data for now, they were incorrect. Proper errors estimates are in the text waves and mining of data from teh results needs to be worked out in the future. 
//0.3 Christmas 2015 developements. many changes. 
//0.1 Diffraction tool development version 



///******************************************************************************************
///******************************************************************************************
Function IR3W_MainCheckVersion()	
	DoWindow IR3W_WAXSPanel
	if(V_Flag)
		if(!CheckPanelVersionNumber("IR3W_WAXSPanel", IR3WversionNumber))
			DoAlert /T="The WAXS panel was created by old version of Irena " 1, "WAXS tool may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				DoWIndow IR3W_WAXSPanel
				if(V_Flag)
					DoWindow/K IR3W_WAXSPanel
				endif
				Execute/P("IR3W_WAXS()")
			else		//at least reinitialize the variables so we avoid major crashes...
				Execute/P("IR3W_WAXS()")
			endif
		endif
	endif
end
///******************************************************************************************
///******************************************************************************************
Function IR3W_WAXS()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 3,"Starting WAXS tool")
	IN2G_CheckScreenSize("width",1200)
	IR3W_InitWAXS()
	DoWIndow IR3W_WAXSPanel
	if(V_Flag)
		DoWindow/F IR3W_WAXSPanel
	else
		Execute("IR3W_WAXSPanel()")
		UpdatePanelVersionNumber("IR3W_WAXSPanel", IR3WversionNumber)
	endif
	IR3W_UpdateListOfAvailFiles()
	IR3W_UpdatePDF4OfAvailFiles()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 3,"Finished WAXS tool")
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
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena:WAXS","IR3W_WAXSPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	TitleBox DataSelection title="Data selection",pos={60,34},frame=0,fstyle=1, fixedSize=1,size={350,20},fSize=12
	Checkbox UseIndra2Data, pos={10,50},size={76,14},title="USAXS", proc=IR3W_WAXSCheckProc, variable=root:Packages:Irena:WAXS:UseIndra2Data
	checkbox UseQRSData, pos={120,50}, title="QRS(QIS)", size={76,14},proc=IR3W_WAXSCheckProc, variable=root:Packages:Irena:WAXS:UseQRSdata
	//fix case when neither is selected and default to qrs
	//NVAR UseIndra2Data = root:Packages:Irena:WAXS:UseIndra2Data
	//NVAR UseQRSdata = root:Packages:Irena:WAXS:UseQRSdata
	if(root:Packages:Irena:WAXS:UseQRSdata+root:Packages:Irena:WAXS:UseIndra2Data!=1)
		root:Packages:Irena:WAXS:UseIndra2Data=0
		root:Packages:Irena:WAXS:UseQRSdata = 1
	endif
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
	Button DisplayHelp,pos={420,5.00},size={90.00,15},proc=IR3W_WAXSButtonProc,title="Display Help"
	Button DisplayHelp,help={"Open WAXS help"}

//root:Packages:Irena:WAXSBackground
//	IR2C_AddDataControls("Irena:WAXS","IR3W_WAXSPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	//Experimental data input
	NewPanel /W=(255,690,545,770) /HOST=# /N=Background
	ModifyPanel cbRGB=(52428,52428,52428), frameStyle=1
	IR2C_AddDataControls("Irena:WAXSBackground","IR3W_WAXSPanel#Background","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=0)
	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman",fsize= 22,fstyle= 3,textrgb= (0,0,52224)
	SetDrawEnv fsize= 12,fstyle= 1
	DrawText 10,20,"Background if needed for fitting"
	//fix case when neither is selected and default to qrs
	root:Packages:Irena:WAXSBackground:DataFolderName=""
	//note, this sets up the dependence for same type of data for background and fit data, seems logical. 
	root:Packages:Irena:WAXSBackground:UseIndra2Data := root:Packages:Irena:WAXS:UseIndra2Data
	root:Packages:Irena:WAXSBackground:UseQRSdata := root:Packages:Irena:WAXS:UseQRSdata
	// done... 
	Checkbox UseIndra2Data, pos={100,5}, disable=1
	Checkbox UseResults, pos={250,5}, disable=1
	Checkbox UseModelData, pos={330,5}, disable=1
	checkbox UseQRSData, pos={180,5}, disable=1
	popupMenu SelectDataFolder, pos={10,20}, proc=IR3W_BackgroundPopMenuProc
	setVariable FolderMatchStr, pos={10,40}
	checkbox DisplayDataBackground, pos={140,40}, title="Display in Graph?", size={76,14},proc=IR3W_WAXSCheckProc, variable=root:Packages:Irena:WAXS:DisplayDataBackground
	
	//setVariable WaveMatchStr, pos={150,120}	
	SetActiveSubwindow ##

	//TitleBox FakeLine1 title=" ",fixedSize=1,size={200,3},pos={290,130},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	//Data Tabs definition
	TabControl AnalysisTabs,pos={265,135},size={280,400}
	TabControl AnalysisTabs,tabLabel(0)="Peak Fit",tabLabel(1)="Diff. Lines"
	TabControl AnalysisTabs proc=IR3W_PDF4TabProc
//tab0
	TitleBox Info1,pos={351.00,160.00},size={99.00,17.00},title="MultiPeak Fit"
	TitleBox Info1,fSize=12,frame=0,fStyle=1,anchor= MC,fixedSize=1
	PopupMenu MPFInitializeFromSetMenu,pos={285.00,180.00},size={235.00,23.00},bodyWidth=190,title="Initialize:"
	PopupMenu MPFInitializeFromSetMenu,mode=1,value= #"IR3W_InitMPF2FromMenuString()", popvalue=root:Packages:Irena:WAXS:MPF2InitFolder, proc=IR3W_PopMenuProc
	Button MultiPeakFittingStart,pos={300.00,210.00},size={200.00,20.00},proc=IR3W_WAXSButtonProc,title="Start MultiPeak Fitting 2.0"
	Button MultiPeakFittingStart,help={"Open and configure MultiPeak 2.0 fitting."}
	TitleBox Info2,pos={350.00,160.00},size={350.00,20.00},disable=1,title="Diffraction lines"
	TitleBox Info2,fSize=12,frame=0,fStyle=1,fixedSize=1
	SetVariable MultiFitResultsFolder,pos={275.00,464.00},size={250.00,16.00},title=" root:WAXSFitResults:"
	SetVariable MultiFitResultsFolder,value= root:Packages:Irena:WAXS:MultiFitResultsFolder
	Button MultiPeakRecordFit,pos={278.00,293.00},size={250.00,20.00},proc=IR3W_WAXSButtonProc,title="Record Current MPF2 Fit Results"
	Button MultiPeakRecordFit,help={"Record current MPF2 resultsc for data with Multipeak 2.0."}
	Button MultiPeakFitRange,pos={279.00,395.00},size={250.00,20.00},proc=IR3W_WAXSButtonProc,title="Fit + Record Range of data"
	Button MultiPeakFitRange,help={"Fit Range fo data with Multipeak 2.0."}
	Button MultiPeakPlotTool,pos={308.00,489.00},size={200.00,20.00},proc=IR3W_WAXSButtonProc,title="Plot/Evaluate results"
	Button MultiPeakPlotTool,help={"Evaluate results from Multipeak 2.0."}

	Button MPF2_DoFitButton,pos={302.00,270.00},size={194.00,16.00},proc=IR3W_WAXSButtonProc,title="Do MPF2 Fit"
	Button MPF2_DoFitButton,fSize=10,fStyle=1,fColor=(32768,32770,65535)
	TitleBox Info3,pos={280.00,373.00},size={248.00,18.00},title="Select range of data sets and :"
	TitleBox Info3,fSize=12,frame=0,fStyle=1,anchor= MC,fixedSize=1
	TitleBox Info4,pos={281.00,247.00},size={232.00,17.00},title="Fit manually using setup MPF2"
	TitleBox Info4,fSize=12,frame=0,fStyle=1,anchor= MC,fixedSize=1
	TitleBox Info5,pos={280.00,350.00},size={248.00,18.00},title="Fit sequence of data using setup MPF2"
	TitleBox Info5,fSize=12,frame=0,fStyle=1,anchor= MC,fixedSize=1
	TitleBox Info6,pos={275.00,439.00},size={248.00,18.00},title="Results are stored here"
	TitleBox Info6,fSize=12,frame=0,fStyle=1,anchor= MC,fixedSize=1

//tab1	
	TitleBox FakeLine2 title=" ",fixedSize=1,size={200,3},pos={290,365},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info2 title="Diffraction lines",pos={350,160},frame=0,fstyle=1, fixedSize=1,size={350,20},fSize=12
	ListBox PDF4CardsSelection,pos={290,180},size={240,220}, mode=10
	ListBox PDF4CardsSelection,listWave=root:Packages:Irena:WAXS:ListOfPDF4Data
	ListBox PDF4CardsSelection,selWave=root:Packages:Irena:WAXS:SelectionOfPDF4Data
	ListBox PDF4CardsSelection,proc=IR3W_PDF4ListBoxProc
	ListBox PDF4CardsSelection colorWave=root:Packages:Irena:WAXS:ListOfPDF4DataColors
	
	Checkbox PDF4_DisplayHKLTags, pos={340,405},size={76,14},title="Display HKL tags", proc=IR3W_WAXSCheckProc, variable=root:Packages:Irena:WAXS:PDF4_DisplayHKLTags
	Button PDF4UpdateList, pos={300,425}, size={200,20}, title="Update list of cards", proc=IR3W_WAXSButtonProc, help={"After using LaueGo package from Jon Tischler update list"}

	Button PDF4ExportImport, pos={300,450}, size={200,20}, title="Export/Import/Delete PDF cards", proc=IR3W_WAXSButtonProc, help={"Add Diffraction lines from hard drive folder on this computer"}
	Button PDF4AddFromLaueGo, pos={300,475}, size={200,20}, title="Calculate PDF card", proc=IR3W_WAXSButtonProc, help={"Add Diffraction lines using LaueGo package from Jon Tischler"}
	Button PDF4AddManually, pos={300,500}, size={200,20}, title="Add manually or Edit PDF card", proc=IR3W_WAXSButtonProc, help={"Add/Edit manually card, e.g. type from JCPDS PDF2 or 4 cards"}

	DrawText 4,680,"Double click to add data to graph."
	DrawText 4,693,"Shift-click to select range of data."
	DrawText 4,706,"Ctrl/Cmd-click to select one data set."
	DrawText 4,719,"Regex for not contain: ^((?!string).)*$"
	DrawText 4,732,"Regex for contain:  string"
	DrawText 4,745,"Case indep. contain:  (?i)string"
	
	Execute ("IR3W_ModifyPanelControls()")
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3W_PDF4TabProc(tca) : TabControl
	STRUCT WMTabControlAction &tca

	variable DisplayFitBtns=0
	DoWindow IR3W_WAXSMainGraph
	if(V_Flag)	//exists
		if(StringMatch(ChildWindowList("IR3W_WAXSMainGraph"),"*MultiPeak2Panel*"))	//and MPF2panel is up
			DisplayFitBtns=1
		endif
	endif
	//DoWIndow/F IR3W_WAXSPanel 
	switch( tca.eventCode )
		case 2: // mouse up
			IN2G_PrintDebugStatement(IrenaDebugLevel, 3,"Calling Tabcontrol procedure")
			Variable tab = tca.tab
			//tab0
				TitleBox Info1 title="MultiPeak Fit",win=IR3W_WAXSPanel, disable=(tab!=0)
				PopupMenu MPFInitializeFromSetMenu,win=IR3W_WAXSPanel, disable=(tab!=0)
				Button MultiPeakFittingStart,win=IR3W_WAXSPanel, disable=(tab!=0)
				//TitleBox Info2, disable=(tab!=0||!DisplayFitBtns)
				SetVariable MultiFitResultsFolder,win=IR3W_WAXSPanel, disable=(tab!=0)
				Button MultiPeakRecordFit,win=IR3W_WAXSPanel, disable=(tab!=0 || !DisplayFitBtns)
				Button MultiPeakFitRange,win=IR3W_WAXSPanel, disable=(tab!=0 || !DisplayFitBtns)
				Button MultiPeakPlotTool,win=IR3W_WAXSPanel, disable=(tab!=0)
				Button MPF2_DoFitButton,win=IR3W_WAXSPanel, disable=(tab!=0 || !DisplayFitBtns)
				TitleBox Info3,fSize=12,win=IR3W_WAXSPanel, disable=(tab!=0 || !DisplayFitBtns)
				TitleBox Info4,fSize=12,win=IR3W_WAXSPanel, disable=(tab!=0 || !DisplayFitBtns)
				TitleBox Info5,fSize=12,win=IR3W_WAXSPanel, disable=(tab!=0 || !DisplayFitBtns)
				TitleBox Info6,fSize=12,win=IR3W_WAXSPanel, disable=(tab!=0)
			//tab1	
				TitleBox FakeLine2,win=IR3W_WAXSPanel, disable=(tab!=1)
				TitleBox Info2, win=IR3W_WAXSPanel, disable=(tab!=1)
				ListBox PDF4CardsSelection, win=IR3W_WAXSPanel, disable=(tab!=1)
				Button PDF4AddManually, win=IR3W_WAXSPanel, disable=(tab!=1)
				Button PDF4AddFromLaueGo, win=IR3W_WAXSPanel, disable=(tab!=1)
				Button PDF4UpdateList, win=IR3W_WAXSPanel, disable=(tab!=1)
				Button PDF4ExportImport, win=IR3W_WAXSPanel, disable=(tab!=1)			
				Checkbox PDF4_DisplayHKLTags, win=IR3W_WAXSPanel, disable=(tab!=1)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3W_ModifyPanelControls()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	if(DataFolderExists("root:Packages:MultiPeakFit2"))
		PopupMenu MPFInitializeFromSetMenu, win=IR3W_WAXSPanel, disable=0
	else
		PopupMenu MPFInitializeFromSetMenu, win=IR3W_WAXSPanel, disable=2
	endif
	ControlInfo/W=IR3W_WAXSPanel AnalysisTabs
	STRUCT WMTabControlAction tca
	tca.eventCode = 2
	tca.tab = V_Value
	IR3W_PDF4TabProc(tca)

end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3W_BackgroundPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			IN2G_PrintDebugStatement(IrenaDebugLevel,5,GetRTStackInfo(1))
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			NVAR  DisplayBackg = root:Packages:Irena:WAXS:DisplayDataBackground		
			if(StringMatch(popStr, "---" ))
				DisplayBackg = 0
				CheckBox DisplayDataBackground win=IR3W_WAXSPanel#Background, value=0
			endif
			IR2C_PanelPopupControl(Pa)
			IR3W_AddbackgroundToGraph()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3W_InitWAXS()	


	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	string oldDf=GetDataFolder(1)
	string ListOfVariables
	string ListOfStrings
	variable i
		
	if (!DataFolderExists("root:Packages:Irena:WAXS"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena
		NewDataFolder/O root:Packages:Irena:WAXS
		NewDataFolder/O root:Packages:Irena:WAXSBackground
	endif
	if (!DataFolderExists("root:Packages:Irena:WAXSBackground"))		//create folder
		NewDataFolder/O root:Packages:Irena:WAXSBackground
	endif
	SetDataFolder root:Packages:Irena:WAXS					//go into the folder

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;DataUnits;"
	ListOfStrings+="DataStartFolder;DataMatchString;FolderSortString;FolderSortStringAll;"
	ListOfStrings+="UserMessageString;SavedDataMessage;MPF2InitFolder;"
	ListOfStrings+="MultiFitResultsFolder;MPF2PlotFolderStart;MPF2PlotPeakProfile;MPF2PlotPeakParameter;"

	ListOfVariables="UseIndra2Data1;UseQRSdata1;"
	ListOfVariables+="DisplayDataBackground;"
	ListOfVariables+="DisplayUncertainties;DataTTHEnd;DataTTHstart;MPF2CurrentFolderNumber;"
	ListOfVariables+="ProcessManually;ProcessSequentially;OverwriteExistingData;AutosaveAfterProcessing;"
	ListOfVariables+="Energy;Wavelength;"
	ListOfVariables+="PDF4_DisplayHKLTags;"

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
	FolderSortStringAll = "Alphabetical;Reverse Alphabetical;_xyz;_xyz.ext;Reverse _xyz;Reverse _xyz.ext;Sxyz_;Reverse Sxyz_;_xyzmin;Reverse_xyzmin;_xyzC;Reverse_xyzC;_xyzpct;_xyz_000;Reverse _xyz_000;"
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
			IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
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
							WAVE DataErrorWave= root:Packages:Irena:WAXS:DataErrorWave
							ErrorBars /W=IR3W_WAXSMainGraph DataIntWave Y,wave=(DataErrorWave,DataErrorWave)		
					else
						ErrorBars /W=IR3W_WAXSMainGraph DataIntWave OFF
					endif
				endif
		  	endif

		  	if(stringmatch(cba.ctrlName,"PDF4_DisplayHKLTags"))
				IR3W_PDF4AddLines()
	  		endif
		  	if(stringmatch(cba.ctrlName,"DisplayDataBackground"))
				IR3W_AddBackgroundToGraph()
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
//**************************************************************************************
//**************************************************************************************
Function IR3W_UpdateListOfAvailFiles()


	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
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
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
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
	elseif(stringMatch(FolderSortString,"Reverse_xyzmin"))
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
			Sort /A/R ListOfAvailableData, ListOfAvailableData
		else
			For(i=0;i<numpnts(TempWv);i+=1)
				if(StringMatch(StringFromList(InfoLoc, ListOfAvailableData[i], "_"), "*min*" ))
					TempWv[i] = str2num(ReplaceString("min", StringFromList(InfoLoc, ListOfAvailableData[i], "_"), ""))
				else	//data not found
					TempWv[i] = inf
				endif
			endfor
			Sort/R TempWv, ListOfAvailableData
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
	elseif(stringMatch(FolderSortString,"Reverse_xyzC"))
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
			Sort /A/R ListOfAvailableData, ListOfAvailableData
		else
			For(i=0;i<numpnts(TempWv);i+=1)
				if(StringMatch(StringFromList(InfoLoc, ListOfAvailableData[i], "_"), "*C*" ))
					TempWv[i] = str2num(ReplaceString("C", StringFromList(InfoLoc, ListOfAvailableData[i], "_"), ""))
				else	//data not found
					TempWv[i] = inf
				endif
			endfor
			Sort/R TempWv, ListOfAvailableData
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

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
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
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:MultiPeakFit2
	String theList = "Start Fresh;"
	if(DataFolderExists("root:Packages:MultiPeakFit2:")) 
		theList += "\\M1(---;"
		String SetList = ListExistingSets()
		Variable i
		Variable nSets = ItemsInList(SetList)
		for (i = 0; i < nSets; i += 1)
				theList += "Set "+StringFromList(i, SetList)
				setDataFolder $("root:Packages:MultiPeakFit2:MPF_SetFolder_"+StringFromList(i, SetList))
				SVAR/Z IrenaUserComment
				if(SVAR_Exists(IrenaUserComment))
						theList += " : "+IrenaUserComment
				endif
				theList += ";"
		endfor
	endif
	setDataFolder oldDf
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
			IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
			if(stringmatch(sva.ctrlName,"FolderNameMatchString1"))
				IR3D_UpdateListOfAvailFiles(1)
				IR3D_RebuildListboxTables()
//				IR2S_SortListOfAvailableFldrs()
			endif

			NVAR DataTTHstart = root:Packages:Irena:WAXS:DataTTHstart
			NVAR DataTTHEnd = root:Packages:Irena:WAXS:DataTTHEnd
	
			if(stringmatch(sva.ctrlName,"DataTTHEnd"))
				WAVE Data2ThetaWave = root:Packages:Irena:WAXS:Data2ThetaWave
				tempP = BinarySearch(Data2ThetaWave, DataTTHEnd )
				if(tempP<0)
					print "Wrong 2Theta value set, 2 Theta max must be at most 1 point before the end of Data"
					tempP = numpnts(Data2ThetaWave)-1
					DataTTHEnd = Data2ThetaWave[tempP]
				endif
				cursor /W=IR3W_WAXSMainGraph B, DataIntWave, tempP
			endif
			if(stringmatch(sva.ctrlName,"DataTTHstart"))
				WAVE Data2ThetaWave = root:Packages:Irena:WAXS:Data2ThetaWave
				tempP = BinarySearch(Data2ThetaWave, DataTTHstart )
				if(tempP<1)
					print "Wrong 2 Theta value set, 2 Theta start  must be at least 1 point from the start of Data"
					tempP = 1
					DataTTHstart = Data2ThetaWave[tempP]
				endif
				cursor /W=IR3W_WAXSMainGraph A, DataIntWave, tempP
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
			IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
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
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
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
		Duplicate/O SourceIntWv, DataIntWave
		Duplicate/O SourceQWv, Data2ThetaWave
		Duplicate/O SourceErrorWv, DataErrorWave
		if(WaveExists(SourcedQWv))
			Duplicate/O SourcedQWv, DataD2ThetaWave
		else
			Duplicate/O SourceQWv, DataD2ThetaWave
			DataD2ThetaWave=0
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
		IR3W_ConvertXdataToTTH(Data2ThetaWave,DataD2ThetaWave,XaxisType,wavelength)
		IR3W_GraphWAXSData()
		print "Added Data from folder : "+DataFolderName
		IR3W_AddBackgroundToGraph()
	SetDataFolder oldDf
end


//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3W_ConvertXdataToTTH(Data2ThetaWave,DataD2ThetaWave,XaxisType,wavelength)
	wave Data2ThetaWave,DataD2ThetaWave
	variable XaxisType,wavelength
	//q = 4pi sin(theta)/lambda
	//theta = (q * lamda / 4pi) * 180/pi [deg]
	//asin(q * lambda /4pi) = theta
	//d ~ 2*pi/Q
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))

	if(XaxisType==0)
		Abort "Unknown X axis type"
	elseif(XaxisType==1)		//Q
		Data2ThetaWave =   114.592 * asin(Data2ThetaWave[p]* wavelength / (4*pi))
		DataD2ThetaWave =  114.592 * asin(DataD2ThetaWave[p] * wavelength / (4*pi))
	elseif(XaxisType==2)		//d
		Data2ThetaWave =   114.592 * asin((2 * pi / Data2ThetaWave[p])* wavelength / (4*pi))
		DataD2ThetaWave =  114.592 * asin((2 * pi / DataD2ThetaWave[p])* wavelength / (4*pi))
	elseif(XaxisType==3)		//TwoTheta
		//nothing to do
	endif
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3W_CreateLinearizedData()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	string oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena:WAXS					//go into the folder
	Wave DataIntWave=root:Packages:Irena:WAXS:DataIntWave
	Wave DataQWave=root:Packages:Irena:WAXS:DataQWave
	Wave DataErrorWave=root:Packages:Irena:WAXS:DataErrorWave
//	SVAR SimpleModel=root:Packages:Irena:WAXS:SimpleModel
	Duplicate/O DataIntWave, LinModelDataIntWave, ModelNormalizedResidual
	Duplicate/O DataQWave, LinModelDataQWave, ModelNormResXWave
	Duplicate/O DataErrorWave, LinModelDataEWave
	ModelNormalizedResidual = 0	
	SetDataFolder oldDf
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************



Function IR3W_AppendDataToGraphModel()
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


Function IR3W_GraphWAXSData()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	variable WhichLegend=0
	variable startTTHp, endTTHp, tmpStQ
	Wave DataIntWave=root:Packages:Irena:WAXS:DataIntWave
	Wave Data2ThetaWave=root:Packages:Irena:WAXS:Data2ThetaWave
	Wave DataErrorWave=root:Packages:Irena:WAXS:DataErrorWave
	NVAR DisplayUncertainties = root:Packages:Irena:WAXS:DisplayUncertainties
	SVAR DataFolderName = root:Packages:Irena:WAXS:DataFolderName


	DoWindow IR3W_WAXSMainGraph 
	if(!V_Flag)
		Display/K=1/W=(630,45,1531,570) DataIntWave  vs Data2ThetaWave as "Powder Diffraction / WAXS Main Graph"
		DoWindow/C IR3W_WAXSMainGraph
		setWIndow IR3W_WAXSMainGraph, hook(CursorMoved)=IR3W_GraphHookFunction
		Label /W=IR3W_WAXSMainGraph left "Intensity"
		Label /W=IR3W_WAXSMainGraph bottom "2Theta [deg]"
		ErrorBars /W=IR3W_WAXSMainGraph DataIntWave Y,wave=(DataErrorWave,DataErrorWave)		
		showinfo
	endif
	AutopositionWindow /R=IR3W_WAXSPanel IR3W_WAXSMainGraph
	if(DisplayUncertainties)
		//ErrorBars DataIntWave OFF 
	else
		ErrorBars /W=IR3W_WAXSMainGraph DataIntWave OFF
	endif
	string LastFldername=StringFromList(ItemsInList(DataFolderName , ":")-1, DataFolderName  , ":")
	TextBox/C/N=SampleName/F=0/S=3/A=RT "\\Z18\\F'Geneva'\\K(0,0,65535)"+LastFldername

	NVAR DataTTHstart = root:Packages:Irena:WAXS:DataTTHstart
	NVAR DataTTHEnd = root:Packages:Irena:WAXS:DataTTHEnd
	
	if(DataTTHEnd>0)	 		//old 2Theta max already set.
		endTTHp = BinarySearch(Data2ThetaWave, DataTTHEnd)
		if(endTTHp<0)
			endTTHp = numpnts(Data2ThetaWave)-1
			DataTTHEnd = Data2ThetaWave[endTTHp]
		endif
	else
		endTTHp = numpnts(Data2ThetaWave)-1
		DataTTHEnd = Data2ThetaWave[endTTHp]
	endif
	if(DataTTHstart>0)	 		//old 2Theta min already set.
		startTTHp = BinarySearch(Data2ThetaWave, DataTTHstart)
		if(startTTHp<0)
			startTTHp = 1
			DataTTHstart = Data2ThetaWave[1]
		endif
	else
		startTTHp = 1
		DataTTHstart = Data2ThetaWave[1]
	endif
	cursor /W=IR3W_WAXSMainGraph B, DataIntWave, endTTHp
	cursor /W=IR3W_WAXSMainGraph A, DataIntWave, startTTHp
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3W_AddBackgroundToGraph()

		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
		string OldDf=GetDataFOlder(1)
		setDataFOlder root:Packages:Irena:WAXS:
		NVAR  DisplayBackg = root:Packages:Irena:WAXS:DisplayDataBackground
		NVAR  Energy = root:Packages:Irena:WAXS:Energy
		NVAR  Wavelength = root:Packages:Irena:WAXS:Wavelength
		//these are variables used by the control procedure
		NVAR  UseIndra2Data = root:Packages:Irena:WAXSBackground:UseIndra2Data
		NVAR  UseQRSdata = root:Packages:Irena:WAXSBackground:UseQRSdata
		//now background, if it exists
		SVAR DataFolderNameB  = root:Packages:Irena:WAXSBackground:DataFolderName 
		SVAR IntensityWaveNameB = root:Packages:Irena:WAXSBackground:IntensityWaveName
		SVAR QWavenameB = root:Packages:Irena:WAXSBackground:QWavename
		SVAR ErrorWaveNameB = root:Packages:Irena:WAXSBackground:ErrorWaveName

		if(stringmatch(DataFolderNameB,"*---*"))
			//to do: remove from graph!
			RemoveFromGraph/Z BackgroundIntWave#0, BackgroundIntWave#1, BackgroundIntWave#2, BackgroundIntWave#3, BackgroundIntWave#4
			Wave/Z BackgroundIntWave=root:Packages:Irena:WAXS:BackgroundIntWave
			Wave/Z Background2ThetaWave=root:Packages:Irena:WAXS:Background2ThetaWave
			Wave/Z BackgroundErrorWave=root:Packages:Irena:WAXS:BackgroundErrorWave
			KillWaves/Z BackgroundIntWave, Background2ThetaWave, BackgroundErrorWave, BackgroundD2ThetaWave
		else
			Wave/Z SourceBIntWv=$(DataFolderNameB+IntensityWaveNameB)
			Wave/Z SourceBQWv=$(DataFolderNameB+QWavenameB)
			Wave/Z SourceBErrorWv=$(DataFolderNameB+ErrorWaveNameB)
			if(!WaveExists(SourceBIntWv)||	!WaveExists(SourceBQWv)||!WaveExists(SourceBErrorWv))
				Abort "Data selection failed"
			endif
			Duplicate/O SourceBIntWv, BackgroundIntWave
			Duplicate/O SourceBQWv, Background2ThetaWave
			Duplicate/O SourceBErrorWv, BackgroundErrorWave
			Duplicate/O SourceBQWv, BackgroundD2ThetaWave
			//figure out what data you have... 
			Wave BackgroundIntWave=root:Packages:Irena:WAXS:BackgroundIntWave
			Wave Background2ThetaWave=root:Packages:Irena:WAXS:Background2ThetaWave
			Wave Background2ThetaWave=root:Packages:Irena:WAXS:Background2ThetaWave
			Wave BackgroundD2ThetaWave=root:Packages:Irena:WAXS:BackgroundD2ThetaWave
			variable XaxisType=0
			if(UseIndra2Data)
				XaxisType = 1 //Q data
			elseif(UseQRSdata)
				if(StringMatch(QWavenameB, "q*")||StringMatch(QWavenameB, "'q*"))
					XaxisType = 1 //Q data
				elseif(StringMatch(QWavenameB, "d*")||StringMatch(QWavenameB, "'d*"))
					XaxisType = 2 //d data
				elseif(StringMatch(QWavenameB, "t*")||StringMatch(QWavenameB, "'t*"))
					XaxisType = 3 //2Theta data
				else	//unknown or mm, do not use
					XaxisType=0
				endif
			else
				XaxisType=0
			endif
			if(XaxisType>0)
				IR3W_ConvertXdataToTTH(Background2ThetaWave,BackgroundD2ThetaWave,XaxisType,wavelength)		
			else	//somethign went wrong
				IN2G_PrintDebugStatement(IrenaDebugLevel, 0,"Incorrect background data found.")
				KillWaves/Z BackgroundIntWave, Background2ThetaWave, BackgroundErrorWav, BackgroundD2ThetaWave
				DisplayBackg=0
			endif
		endif
	if(DisplayBackg)	
		if(WaveExists(BackgroundIntWave)&&WaveExists(Background2ThetaWave))
		 	CheckDisplayed /W=IR3W_WAXSMainGraph BackgroundIntWave
		 	if(!V_Flag)
				AppendToGraph/W=IR3W_WAXSMainGraph BackgroundIntWave vs Background2ThetaWave
				ModifyGraph lstyle(BackgroundIntWave)=7,rgb(BackgroundIntWave)=(0,0,0)
			endif
		endif
	else		//do not display
		Wave/Z BackgroundIntWave=root:Packages:Irena:WAXS:BackgroundIntWave
		Wave/Z Background2ThetaWave=root:Packages:Irena:WAXS:Background2ThetaWave
		Wave/Z BackgroundErrorWave=root:Packages:Irena:WAXS:BackgroundErrorWave
		RemoveFromGraph/Z BackgroundIntWave#0, BackgroundIntWave#1, BackgroundIntWave#2, BackgroundIntWave#3, BackgroundIntWave#4
		//KillWaves/Z BackgroundIntWave, Background2ThetaWave, BackgroundErrorWave
	endif
	setDataFOlder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//Start Peak Fitting GUI for WAXS

Function IR3W_StartMultiPeakGUIForWAXS()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	String yWName = "root:Packages:Irena:WAXS:DataIntWave"	
	String xWName = "root:Packages:Irena:WAXS:Data2ThetaWave"
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
		Cursor/P A  DataIntWave  0 
	endif
	if(strlen(csrInfo(B,"IR3W_WAXSMainGraph"))<5)		//not set
		Cursor/P B  DataIntWave  numpnts(yw)-1
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
		sscanf MPF2InitFolder, "Set %d", menuSetnumber	
	else
		initializeFrom = 1
		menuSetnumber=0
	endif
	
	MPF2_StartNewMPFit(Panelposition, theGraph, yWName, xWName, initializeFrom, menuSetNumber)
	MPF2CurrentFolderNumber = currentSetNumber
	SVAR MPF2WeightWaveName = $("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(currentSetNumber)+":MPF2WeightWaveName")
	MPF2WeightWaveName = "root:Packages:Irena:WAXS:DataErrorWave"
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
	string WinNmWChild
	switch( ba.eventCode )
		case 2: // mouse up
			IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
			// click code here
			if(stringmatch(ba.ctrlname,"MultiPeakFittingStart"))
				if(!DataFolderExists("root:Packages:MultiPeakFit2"))
					fStartMultipeakFit2()
				endif
				IR3W_StartMultiPeakGUIForWAXS()
				DoWindow IR3W_WAXSMainGraph
				if(V_Flag)	//exists
					if(StringMatch(ChildWindowList("IR3W_WAXSMainGraph"),"*MultiPeak2Panel*"))	//and MPF2panel is up
						WinNmWChild = "IR3W_WAXSMainGraph#"+StringFromList(0,ChildWindowList("IR3W_WAXSMainGraph"))
						SetWindow $WinNmWChild, hook(IrenaWAXSHook) = IR3W_MPF2PanelHookFunction	// Install window hook
						IR3W_ModifyPanelControls()
					endif
				endif
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
			if(stringmatch(ba.ctrlname,"MPF2_DoFitButton"))
				STRUCT WMButtonAction s
				s.eventCode = 2
				s.ctrlName="MPF2_DoFitButton"
				s.win  ="IR3W_WAXSMainGraph#MultiPeak2Panel#P2"
				MPF2_DoFitButtonProc(s)
			endif
			if(stringmatch(ba.ctrlname,"MPF2PlotPeakGraph"))
				IR3W_MPF2PlotPeakGraph()
			endif
			if(stringmatch(ba.ctrlname,"MPF2PlotPeakParams"))
				IR3W_MPF2PlotPeakParameters()
			endif
			if(stringmatch(ba.ctrlname,"DisplayHelp"))
				DisplayHelpTopic "Irena WAXS tool"
			endif
			if(stringmatch(ba.ctrlname,"PDF4AddManually"))
				IR3W_PDF4AddManually()
				IR3W_UpdatePDF4OfAvailFiles()
			endif
			if(stringmatch(ba.ctrlname,"PDF4AddFromLaueGo"))
				IR3W_PDF4AddFromLaueGo()
			endif
			if(stringmatch(ba.ctrlname,"PDF4UpdateList"))
				IR3W_UpdatePDF4OfAvailFiles()
			endif
			if(stringmatch(ba.ctrlname,"PDF4ExportImport"))
				IR3W_PDF4SaveLoadDifPtnPnl()
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
Function IR3W_MPF2PanelHookFunction(s)
	STRUCT WMWinHookStruct &s
	Variable hookResult = 0	// 0 if we do not handle event, 1 if we handle it.
	switch(s.eventCode)
		case 2:					// Keyboard event
				IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
				ControlInfo/W=IR3W_WAXSPanel AnalysisTabs
	
				variable tab
				tab = V_Value
				SetVariable MultiFitResultsFolder,win=IR3W_WAXSPanel, disable=(tab!=0)
				Button MultiPeakRecordFit,win=IR3W_WAXSPanel, disable=(1)
				Button MultiPeakFitRange,win=IR3W_WAXSPanel, disable=(1)
				Button MultiPeakPlotTool,win=IR3W_WAXSPanel, disable=(tab!=0)
				Button MPF2_DoFitButton,win=IR3W_WAXSPanel, disable=(1)
				TitleBox Info3,fSize=12,win=IR3W_WAXSPanel, disable=(1)
				TitleBox Info4,fSize=12,win=IR3W_WAXSPanel, disable=(1)
				TitleBox Info5,fSize=12,win=IR3W_WAXSPanel, disable=(1)
				TitleBox Info6,fSize=12,win=IR3W_WAXSPanel, disable=(tab!=0)
				//Get User comment and store it in IrenaUserComment
				NVAR CurrentSetNumber=root:Packages:MultiPeakFit2:currentSetNumber
				string OldDf=GetDataFolder(1)
				if(DataFolderExists("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(CurrentSetNumber)))
					setDataFolder $("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(CurrentSetNumber))
					string UserComment=""
					SVAR/Z IrenaUserComment
					if(SVAR_Exists(IrenaUserComment))
						UserComment = IrenaUserComment
					else
						string/g IrenaUserComment
						SVAR IrenaUserComment
						IrenaUserComment=""
					endif
					Prompt UserComment, "Comment for dialogs?"
					DoPrompt /Help="This comment will be useful in the future" "Add notes to the MPF2 folder?", UserComment
					if(V_Flag)			
					endif
					IrenaUserComment = UserComment
				else
					//using existing folder for initialization, no new input needed. This looks like bug in MPF2 that it is needed. 
				endif
			setDataFolder OldDf
			hookResult = 1
			break
	endswitch
	return hookResult	// If non-zero, we handled event and Igor will ignore it.
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3W_FitMultiPeakFit2ForWAXS()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))

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
			print "Fitted Peak positions and saved data for sample ; "+FoldernameStr
			DoWIndow/F IR3W_WAXSMainGraph
			DoWIndow/F IR3W_WAXSPanel
			sleep/S (1)
		endif
	endfor
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3W_DoMultiPeak2Fits()
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
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

static function IR3W_SaveMultiPeakResults()
 
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	NVAR MPF2CurrentFolderNumber = root:Packages:Irena:WAXS:MPF2CurrentFolderNumber	
 	string Oldf=GetDataFolder(1)
 	setDataFolder $("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber))
 
		STRUCT WMButtonAction s
		s.ctrlName="MPF2_PeakResultsButton"
		s.win="IR3W_WAXSMainGraph#MultiPeak2Panel#P2"
		s.eventCode=2
		MPF2_PeakResultsButtonProc(s)
		//this generates the new panel with results (keep up for few seconds and close... and following waves with the results
		//this creates and saves in the notebook...
		//if fitting failed, the panel does not come up, so check i=on its presence and if nto present, abort here. 
		//panel has name something like... MPF2_ResultsPanel_4
		NVAR MPF2CurrentFolderNumber = root:Packages:Irena:WAXS:MPF2CurrentFolderNumber	
		string PanelWIthResultsName = 	"MPF2_ResultsPanel_"+num2str(MPF2CurrentFolderNumber)	
		DoWIndow $(PanelWIthResultsName)
		if(!V_Flag)
			Print "Fitting has likely failed, check parameters and try again"
			Abort
		endif
		//No error, can continue
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
		Wave MMPF2_FitToData = $("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber)+":fit_DataIntWave")
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
		Duplicate/O/T MPF2_ResultsListWave, WAXS_ResultsListWave
		Duplicate/O MPF2_ResultsListTitles, WAXS_ResultsListTitles
		Duplicate/O MMPF2_BSubData, WAXS_BckgSubtractedData
		Duplicate/O MMPF2_FitToData, WAXS_FitToData		
		Duplicate/O  MMPF2_FitToData, WAXS_FitToData_d
		Wave WAXS_FitToData_d=WAXS_FitToData_d
		WAXS_FitToData_d[] = IN2G_ConvertTTHtoD(pnt2x(MMPF2_FitToData, p ),Wavelength)
		//add indexes for users to figure this out...
		Wave/T WAXS_ResultsListWave
		SetDimLabel 1,0,Index,WAXS_ResultsListWave
		SetDimLabel 1,1,PeakType,WAXS_ResultsListWave
		SetDimLabel 1,2,Pos_d,WAXS_ResultsListWave
		SetDimLabel 1,3,Pos_d_Uncert,WAXS_ResultsListWave
		SetDimLabel 1,4,Amplitude,WAXS_ResultsListWave
		SetDimLabel 1,5,Ampl_uncert,WAXS_ResultsListWave
		SetDimLabel 1,6,Area,WAXS_ResultsListWave
		SetDimLabel 1,7,Area_uncert,WAXS_ResultsListWave
		SetDimLabel 1,8,FWHM_TTH,WAXS_ResultsListWave
		SetDimLabel 1,9,FWHM_Uncert,WAXS_ResultsListWave
		SetDimLabel 1,10,Pos_TTH,WAXS_ResultsListWave
		SetDimLabel 1,11,PosTTH_Uncert,WAXS_ResultsListWave
		SetDimLabel 1,12,Widh_TTH,WAXS_ResultsListWave
		SetDimLabel 1,13,WidthTTH_Uncert,WAXS_ResultsListWave
		SetDimLabel 1,14,Height,WAXS_ResultsListWave
		SetDimLabel 1,15,Height_Uncert,WAXS_ResultsListWave
		WAXS_ResultsListWave[][2] = num2str(IN2G_ConvertTTHtoD(str2num(WAXS_ResultsListWave[p][10]),wavelength)	)
		variable tmpVal, tmpWidth, Val1, val2
		For(i=0;i<(DimSize(WAXS_ResultsListWave,0));i+=1)
				tmpVal = str2num(WAXS_ResultsListWave[i][10])
				tmpWidth= str2num((WAXS_ResultsListWave[i][11])[4,inf])
				Val1 = IN2G_ConvertTTHtoD((tmpVal-tmpWidth),wavelength)
				Val2 = IN2G_ConvertTTHtoD((tmpVal+tmpWidth),wavelength)
				WAXS_ResultsListWave[i][3] = "+/- "+num2str((Val1-Val2)/2)
		endfor

		//separate peaks... 
		For(i=0;i<dimsize(MPF2_ResultsListWave,0);i+=1)
			Wave/Z PeakData=$("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber)+":'Peak "+num2str(i)+"'")
			if(WaveExists(PeakData))
				Wave PeakData=$("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber)+":'Peak "+num2str(i)+"'")
				Wave PeakDataCoefs=$("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber)+":'Peak "+num2str(i)+" Coefs'")
				//Wave PeakDataCoefSig=$("root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(MPF2CurrentFolderNumber)+":'Peak "+num2str(i)+" Coefseps'")
				Duplicate/O  PeakData, $("Peak "+num2str(i))
				Duplicate/O  PeakData, $("Peak "+num2str(i)+"_d")
				Wave NewDwave=$("Peak "+num2str(i)+"_d")
				NewDwave[] = IN2G_ConvertTTHtoD(pnt2x(PeakData, p ),Wavelength)
				Duplicate/O  PeakDataCoefs, $("Peak "+num2str(i)+" Coefs")
				//Duplicate/O  PeakDataCoefSig, $("Peak "+num2str(i)+" Coefseps")		//these are starting parameter estimates, not errors..., always set to 1e-6
			endif
		endfor

		DoUpdate
		DoWindow $("MPF2_ResultsPanel_"+num2str(MPF2CurrentFolderNumber))
		if(V_Flag)
			DoWIndow/K $("MPF2_ResultsPanel_"+num2str(MPF2CurrentFolderNumber))
		endif
		//arrange the widnows around...
		string TableWinName, NotebookWinName
		TableWinName= WinList("MultipeakSet*_TD",";","") //MultipeakSet5_TD
		NotebookWinName= WinList("MultipeakSet*Report",";","") //MultipeakSet5_TD
		For(i=0;i<ItemsInList(TableWinName);i+=1)
			AutoPositionWindow/E/M=1/R=IR3W_WAXSMainGraph $(StringFromList(i,TableWinName))
		endfor
		For(i=0;i<ItemsInList(NotebookWinName);i+=1)
			AutoPositionWindow/E/M=1/R=IR3W_WAXSMainGraph $(StringFromList(i,NotebookWinName))
		endfor
		 
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
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	
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
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	
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
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))	
	return "root:Packages:MultiPeakFit2:MPF_SetFolder_"+num2str(setnumber)
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
// ********* Jans Polynomial BASELINE *********
Function/S IR3W_WAXSBckDATA_BLFuncInfo(InfoDesired)
	Variable InfoDesired
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))

	String info=""
	switch(InfoDesired)
		case BLFuncInfo_ParamNames:
			info = "Const;ScaleBckg;"
			break;
		case BLFuncInfo_BaselineFName:
			info = "IR3W_WAXSBackSubtrDTA"
			break;
	endswitch

	return info
end
//**********************************************************************************************************
Function IR3W_WAXSBackSubtrDTA(s)
	STRUCT MPF2_BLFitStruct &s	
	Wave/Z TTHWv = root:Packages:Irena:WAXS:BackgroundD2ThetaWave
	Wave/Z BckgIntwv = root:Packages:Irena:WAXS:BackgroundIntWave
	//s.cWave[0] = Constant
	//s.cWave[1] = scaling of background wave
	// if TTH or Int do not exist, it is simply fixed constant...
	variable result
	if(WaveExists(TTHWv)&&WaveExists(BckgIntwv))
		result = s.cWave[0] + s.cWave[1]*BckgIntwv[BinarySearchInterp(TTHWv, s.x )]
	else
		result = s.cWave[0]
	endif
	return result
end
//**********************************************************************************************************
//**********************************************************************************************************
Function/S IR3W_WAXSPoly10_BLFuncInfo(InfoDesired)
	Variable InfoDesired
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	String info=""
	switch(InfoDesired)
		case BLFuncInfo_ParamNames:
			info = "Const;Lin;Sqr;Cub;4th;5th;6th;7th;8th;9th;"
			break;
		case BLFuncInfo_BaselineFName:
			info = "IR3W_WAXSPoly10_BLFunc"
			break;
	endswitch
	return info
end
//**********************************************************************************************************
Function IR3W_WAXSPoly10_BLFunc(s)
	STRUCT MPF2_BLFitStruct &s
	Variable xr = s.xEnd - s.xStart
	Variable x = (2*s.x - (s.xStart + s.xEnd))/xr
	return poly(s.cWave, x)
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
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
				IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
				WAVE Data2ThetaWave = root:Packages:Irena:WAXS:Data2ThetaWave
				if(!stringmatch(H_Struct.traceName,"DataIntWave"))
					cursor /W=IR3W_WAXSMainGraph A, DataIntWave, 1
					DataTTHstart = Data2ThetaWave[1]
					Print "A cursor must be on DataIntWave and at least on second point from start"
				else		//on correct wave...
					if(H_Struct.pointNumber==0)			//bad point, needs to be at least 1
						cursor /W=IR3W_WAXSMainGraph A, DataIntWave, 1
						DataTTHstart = Data2ThetaWave[1]
						Print "A cursor must be on DataIntWave and at least on second point from the start"
					else
						DataTTHstart = Data2ThetaWave[H_Struct.pointNumber]
					endif
				endif
			endif
			if(stringmatch(cursorName,"B")&&stringmatch(H_Struct.eventName,"cursormoved"))
				IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
				WAVE Data2ThetaWave = root:Packages:Irena:WAXS:Data2ThetaWave
				WAVE DataIntWave = root:Packages:Irena:WAXS:DataIntWave
				if(!stringmatch(H_Struct.traceName,"DataIntWave"))
					cursor /W=IR3W_WAXSMainGraph B,DataIntWave, numpnts(DataIntWave)-2
					DataTTHEnd = Data2ThetaWave[numpnts(DataIntWave)-2]
					Print "B cursor must be on DataIntWave and at least on second point from the end"
				else		//on correct wave...
					if(H_Struct.pointNumber==0)			//bad point, needs to be at least 1
						cursor /W=IR3W_WAXSMainGraph B, DataIntWave, numpnts(DataIntWave)-2
						DataTTHEnd = Data2ThetaWave[numpnts(DataIntWave)-2]
						Print "B cursor must be on DataIntWave and at least on second point from the end"
					else
						DataTTHEnd = Data2ThetaWave[H_Struct.pointNumber]		
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

		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	string OldDF=GetDataFolder(1)
	if(!DataFolderExists("root:WAXSFitResults"))
		return ""
	endif
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
	//elseif(stringmatch(ReturnWhat,"Peak Profiles Coeficients EPS"))
		//result = GrepList(AllResultsWaxs, "Peak [0-9] (Coefseps)$" )
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
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
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
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
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
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
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
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function IR3W_MPF2ExtractParamsToGraph(StartFolder, DataWvName)
	string StartFolder, DataWvName
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))

	variable NumGraphs, i

	Wave/Z WaveToAppend=$((DataWvName+" Coefs"))
	if(!WaveExists(WaveToAppend))
		return 0
	endif	
	//Wave/Z WvErsToAppend=$((DataWvName+" Coefseps"))
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
	wv0[curLength][1] =NaN	//WvErsToAppend[0]
	wv0[curLength][2] =WaveToAppend[1]
	wv0[curLength][3] =NaN	//WvErsToAppend[1]
	wv0[curLength][4] =WaveToAppend[2]
	wv0[curLength][5] =NaN	//WvErsToAppend[2]
	wvT[curLength] = GetDataFOlder(0)
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3W_PDF4AddManually()
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	string OldDf=GetDataFolder(1)
	string NewCardFullName
	DoWIndow JCPDS_Input
	if(V_Flag)
		DoWIndow/K JCPDS_Input
	endif
	NewDataFolder/O/S root:WAXS_PDF
	string OldCardName, NewCardNumber, NewCardName, NewCardNote, DeleteCardName
	DeleteCardName="---"
	OldCardName = "---"
	NewCardNumber = ""
	NewCardName="---"
	NewCardNote =""
	//Prompt DeleteCardName, "Delete card?", popup "---;"+IR3W_PDF4CreateListOfCards()
	Prompt OldCardName, "Select existing card to edit", popup "---;"+IR3W_PDF4CreateListOfCards()
	//Prompt NewCardNumber, "Enter new card number, e.g. 46-1212"
	Prompt NewCardName, "Enter new card name, e.g. Corundum"
	//Prompt NewCardNote, "Enter new card note, whatever you may need later"
	DoPrompt "Select to Modify existing card or Create new card? " OldCardName, NewCardName//, NewCardNote
	if(V_Flag)
		setDataFolder OldDf
		return 0
	endif
	if(stringmatch(OldCardName,"---"))
		NewCardFullName=((NewCardName)[0,23])
		if(CheckName(NewCardFullName,1)!=0)
			setDataFolder OldDf
			DoAlert 0, "Not unique name"	
			return 0
		endif
		make/O/N=(50,8) $(NewCardFullName)
		make/O/T/N=(50) $(NewCardFullName+"_hklStr")
		Wave NewCard= $(NewCardFullName)
		SetDimLabel 1,0,d_A,NewCard
		SetDimLabel 1,1,h,NewCard
		SetDimLabel 1,2,k,NewCard
		SetDimLabel 1,3,l,NewCard
		SetDimLabel 1,4,theta,NewCard
		SetDimLabel 1,5,F2,NewCard
		SetDimLabel 1,6,Intensity,NewCard
		SetDimLabel 1,7,mult,NewCard
	elseif(!stringmatch(OldCardName,"---"))//&&stringmatch(DeleteCardName,"---"))
		NewCardFullName=OldCardName
		Wave NewCard= $(NewCardFullName)
//	elseif(stringmatch(OldCardName,"---")&&!stringmatch(DeleteCardName,"---"))
//		NewCardFullName=DeleteCardName
//		Wave NewCard= $(NewCardFullName)
//		Wave NewCardhkl= $(NewCardFullName+"_hklStr")
//		DoALert/T="Check deleting card" 1, "Really delete "+DeleteCardName+" card?" 
//		if(V_Flag)
//			KillWaves NewCard
//			KillWaves NewCardhkl
//			setDataFolder OldDf
//			return 0
//		endif
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
Function/T IR3W_PDF4CreateListOfCards()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	string ListOfCards = IN2G_CreateListOfItemsInFolder("root:WAXS_PDF:", 2)
	ListOfCards = GrepList(ListOfCards, "^((?!hklStr).)*$",0,";")
	return ListOfCards
end

//**************************************************************************************
//**************************************************************************************

Function IR3W_UpdatePDF4OfAvailFiles()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	string OldDF=GetDataFolder(1)
	string AvailableCards=""
	string AvailableCardsHKL=""
	if(DataFolderExists("root:WAXS_PDF" ))
		setDataFolder root:WAXS_PDF
		//AvailableCards=ReplaceString("\n", stringfromList(1,DataFolderDir(2),":"), "")
		AvailableCards=IN2G_CreateListOfItemsInFolder("root:WAXS_PDF",2)
		//AvailableCards=ReplaceString("\r", stringfromList(1,DataFolderDir(2),":"), "")
		//AvailableCards=ReplaceString(";", stringfromList(1,DataFolderDir(2),":"), "")
		AvailableCardsHKL = GrepList(AvailableCards, "_hklStr",0,";")
		AvailableCards = GrepList(AvailableCards, "^((?!hklStr).)*$",0,";")
	else
		newDataFolder/O/S root:WAXS_PDF
	endif
	string TempStr

	Wave/T ListOfAvailableData=root:Packages:Irena:WAXS:ListOfPDF4Data
	Wave SelectionOfAvailableData=root:Packages:Irena:WAXS:SelectionOfPDF4Data
	Wave/Z ListOfPDF4DataColors = root:Packages:Irena:WAXS:ListOfPDF4DataColors
	if(!WaveExists(ListOfPDF4DataColors))
		make/O/N=(0,3) ListOfPDF4DataColors
	endif
	variable i, j, match
	Redimension/N=(ItemsInList(AvailableCards , ";"),1) ListOfAvailableData
	Redimension/N=(ItemsInList(AvailableCards , ";"),1,2) SelectionOfAvailableData
	Redimension/N=(ItemsInList(AvailableCards , ";"),3) ListOfPDF4DataColors
	For(i=0;i<ItemsInList(AvailableCards , ";");i+=1)
		TempStr =  StringFromList(i, AvailableCards , ";")
		if(strlen(TempStr)>0)
			ListOfAvailableData[i] = tempStr
		endif
	endfor
	SelectionOfAvailableData[][][0] = 0x20
	SelectionOfAvailableData[][][1] = p

	For(i=0;i<ItemsInList(AvailableCards , ";");i+=1)
		TempStr =  StringFromList(i, AvailableCards , ";")
		//let's also check that hklStr waves are correct...
		Wave DtaWv=$("root:WAXS_PDF:"+possiblyquotename(TempStr))
		Wave/T/Z DtaWvHklDStr=$("root:WAXS_PDF:"+possiblyquotename(TempStr[0,23]+"_hklStr"))
		if(!WaveExists(DtaWvHklDStr))
			make/O/T/N=(DimSize(DtaWv, 0 )) $("root:WAXS_PDF:"+possiblyquotename(TempStr[0,23]+"_hklStr"))
			Wave/T DtaWvHklDStr=$("root:WAXS_PDF:"+possiblyquotename(TempStr[0,23]+"_hklStr"))
		endif
		if(strlen(DtaWvHklDStr[0])<1)	//empty wave, not filled...
			For(j=0;j<numpnts(DtaWvHklDStr);j+=1)
				DtaWvHklDStr[j] = "("+num2str(DtaWv[j][1])+num2str(DtaWv[j][2])+num2str(DtaWv[j][3])+")"
			endfor	
		endif
	endfor
	setDataFolder OldDF
end

//**************************************************************************************
//**************************************************************************************

Function IR3W_PDF4ListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
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
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
Menu "IR3W_ColorWaveEditorMenu",contextualmenu
	"*COLORPOP*(65535,0,0)", ;	// initially red, no execution command
	//"Edit Card", IR3W_EditJCPDSCard()
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3W_PDF4AddLines()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	Wave/T listWave=root:Packages:Irena:WAXS:ListOfPDF4Data
	Wave selWave=root:Packages:Irena:WAXS:SelectionOfPDF4Data
	Wave ListOfPDF4DataColors = root:Packages:Irena:WAXS:ListOfPDF4DataColors
	NVAR PDF4_DisplayHKLTags = root:Packages:Irena:WAXS:PDF4_DisplayHKLTags
	
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
			if(PDF4_DisplayHKLTags)
				Wave LabelWave=$("root:WAXS_PDF:"+(listWave[i][0])[0,23]+"_hklStr")
				IR3W_PDF4AddTagsFromWave("IR3W_WAXSMainGraph", listWave[i][0], labelWave, ListOfPDF4DataColors[i][0], ListOfPDF4DataColors[i][1],ListOfPDF4DataColors[i][2])
			endif
		else 		//remove if needed...
			WvName = listWave[i][0]
			RemoveFromGraph /W=IR3W_WAXSMainGraph /Z $(WvName)
		endif
	endfor
	SetAxis /W=IR3W_WAXSMainGraph  bottom , minX, maxX
end

//**************************************************************************************
//**************************************************************************************
Function IR3W_PDF4AddTagsFromWave(graphName, traceName, labelWave, Cr, Cg, Cb )
	String graphName
	String traceName
	Wave/T labelWave
	variable Cr, Cg, Cb
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
 
	Wave w = TraceNameToWaveRef(graphName, traceName)
 
	Variable index
	for(index = 0; index < dimsize(w,0); index+=1)
		String tagName = "Lab" +traceName[0,12]+num2str(index)
		Tag/C/N=$tagName/F=0/TL=0/G=(Cr,Cg,Cb)/I=1 $traceName, index, labelWave[index]
	endfor
End

//**************************************************************************************
//**************************************************************************************

Function IR3W_PDF4AppendLinesToGraph(CardName, V_Red, V_Green, V_Blue)
	string cardname
	variable V_Red, V_Green, V_Blue
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	string OldDf=GetDataFolder(1)
	NVAR  Wavelength = root:Packages:Irena:WAXS:Wavelength
	wave TheCard=$("root:WAXS_PDF:"+possiblyquotename(CardName))
	wave/T TheCardHKL=$("root:WAXS_PDF:"+possiblyquotename(CardName[0,23]+"_hklStr"))
	NewDataFolder/O/S root:Packages:Irena:WAXSTemp
	Duplicate/O TheCard, $(CardName)
	Duplicate/O/T TheCardHKL, $(CardName[0,23]+"_hklStr")
	Wave TheCardNew = $((CardName))
	string DimensionUnit=GetDimLabel(TheCardNew, 1, 0 )
	if(stringmatch(DimensionUnit,"d_A"))		//manually inserted, dimension is in d and A
		TheCardNew[][4] =   114.592 * asin((2 * pi / TheCard[p][0])* wavelength / (4*pi))
	else		//other choice is "Q_nm" from LaueGo
		TheCardNew[][4] =  114.592 * asin((TheCard[p][0]*wavelength/125.664 ))		//this is conversion to A and from Q
		//10*4*pi = 
	endif
	SetDimLabel 1,4,TwoTheta,TheCardNew
	Wave DataIntWave = root:Packages:Irena:WAXS:DataIntWave
	//Wave Data2ThetaWave = root:Packages:Irena:WAXS:Data2ThetaWave
	make/Free/N=(DimSize(TheCard, 0)) TmpWv, TmpWvTTH
	TmpWv = TheCard[p][6]
	TmpWvTTH = TheCardNew[p][4]
	//wavestats/Q DataIntWave
	GetAxis /W=IR3W_WAXSMainGraph /Q bottom
	variable oldMin, OldMax, OldMinInt, OldIntMax
	OldMin = V_min
	OldMax = V_max
	V_min=binarysearch(TmpWvTTH, V_min)
	V_min  = (V_min > 0) ? V_min : 0
	V_max= binarysearch(TmpWvTTH,V_max)
	V_max = (V_max>V_min) ? V_Max : numpnts(TmpWv)-1
	variable MaxInt=WaveMax(TmpWv, pnt2x(TmpWv,V_min ),pnt2x(TmpWv,V_max))
	GetAxis /W=IR3W_WAXSMainGraph /Q left
	OldMinInt = V_min
	OldIntMax = V_max
	TheCardNew[][6] = V_min + TheCard[p][6] * (V_Max-V_min)/MaxInt
	AppendToGraph/W=IR3W_WAXSMainGraph TheCardNew[][6] vs TheCardNew[][4]
	//DoUpdate  /W=IR3W_WAXSMainGraph 
	string WvName=possiblyquotename(NameOfWave(TheCardNew))
	ModifyGraph mode($(WvName))=1,usePlusRGB($(WvName))=1, lsize($(WvName))=3
	ModifyGraph plusRGB($(WvName))=(V_Red, V_Green, V_Blue)	
	SetAxis bottom oldMin, OldMax
	SetAxis left OldMinInt, OldIntMax
	setDataFolder oldDf
end

//**************************************************************************************
//**************************************************************************************
//			PDF4 - Export/Import parts. 
//**************************************************************************************
//**************************************************************************************
Function IR3W_PDF4SaveLoadDifPtnPnl()
	string OldDf=GetDataFolder(1)
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	SetDataFolder root:Packages:Irena:WAXS:
	string PathToFiles=FunctionPath("")
	PathToFiles = ReplaceString("IR3_WAXSDiffraction.ipf", PathToFiles , WAXSPDF4Location)
	NewPath /C/O/Q WAXSPDF4Path, PathToFiles
	PathInfo WAXSPDF4Path
	if(V_flag==0)
		//something went wrong - the folder does not exist and cannot be created.
		Abort "WAXS PDF cards folder does not exist and annot be even created. Aborting." 
	endif
	//mini initialization for this panel
	DoWindow IR3W_PDF4SaveLoadPanel
	if(!V_Flag)
		Wave/Z/T SaveLoadPDFInside, SaveLoadPDFOutside
		if(!WaveExists(SaveLoadPDFInside))
			make/O/N=0/T SaveLoadPDFInside, SaveLoadPDFOutside	
			make/O/N=0 SaveLoadPDFInsideSel, SaveLoadPDFOutsideSel	
		endif
		Execute("IR3W_PDF4SaveLoadPanel()")
	else
		DoWindow/F IR3W_PDF4SaveLoadPanel
	endif
	IR3W_PDF4UpdateOutsideListBox()
	IR3W_PDF4UpdateInsideListBox()
	setDataFolder OldDf
end
//**************************************************************************************
//**************************************************************************************
Proc IR3W_PDF4SaveLoadPanel()
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(236,50,600,555) as "Save and Recall PDF data"
	DoWindow/C IR3W_PDF4SaveLoadPanel
	TitleBox TitleStuff title="Save and Load PDF files",pos={40,15},frame=0,fstyle=3, fixedSize=1,size={350,20},fSize=16, fColor=(1,4,52428)
	TitleBox Warning1 title="PDF downloaded from Irena www are not guarranteed. ",pos={5,425},frame=0,fstyle=3, fixedSize=1,size={350,20},fSize=12, fColor=(52428,1,1)
	TitleBox Warning2 title="They are calculated using LaueGo for model structures.",pos={5,445},frame=0,fstyle=3, fixedSize=1,size={350,20},fSize=12, fColor=(52428,1,1)
	TitleBox Warning3 title="Verify using proper source (JCPDS/PDF4)! ",pos={5,465},frame=0,fstyle=3, fixedSize=1,size={350,20},fSize=12, fColor=(52428,1,1)
	TitleBox Warning4 title="Simply ... get/calculate your own reliable cards. ",pos={5,485},frame=0,fstyle=3, fixedSize=1,size={350,20},fSize=12, fColor=(52428,1,1)
	//Button SelectSaveLoadPath,pos={84,31},size={150,20},proc=NI1A_SaveLoadButtonProc,title="Select data path"
	//Button SelectSaveLoadPath,help={"Select path to your configuration files. You can create new folders by typing them in."}
	TitleBox OutsideData title="Outside",pos={55,45},frame=0,fstyle=1, fixedSize=1,size={350,20},fSize=12
	ListBox OutsidePDFDataList,pos={5,65},size={170,220}//,proc=NI1A_SaveLoadListBoxProc
	ListBox OutsidePDFDataList,listWave=root:Packages:Irena:WAXS:SaveLoadPDFOutside
	ListBox OutsidePDFDataList,selWave=root:Packages:Irena:WAXS:SaveLoadPDFOutsideSel
	ListBox OutsidePDFDataList, mode= 9

	TitleBox InsideData title="Inside",pos={230,45},frame=0,fstyle=1, fixedSize=1,size={350,20},fSize=12
	ListBox InsidePDFDataList,pos={180,65},size={170,220}//,proc=NI1A_SaveLoadListBoxProc
	ListBox InsidePDFDataList,listWave=root:Packages:Irena:WAXS:SaveLoadPDFInside
	ListBox InsidePDFDataList,selWave=root:Packages:Irena:WAXS:SaveLoadPDFInsideSel
	ListBox InsidePDFDataList, mode= 9

	Button UpdateListbox,pos={65,290},size={230,20},proc=IR3W_PDF4ButtonProc,title="Update listboxes"
	Button UpdateListbox,help={"Read selected PDF4 from the file"}
	Button CopyPDF4In,pos={65,315},size={230,20},proc=IR3W_PDF4ButtonProc,title=">>> Copy IN >>>"
	Button CopyPDF4In,help={"Read selected PDF4 from the file"}
	Button CopyPDF4Out,pos={65,340},size={230,20},proc=IR3W_PDF4ButtonProc,title="<<< Copy OUT <<<"
	Button CopyPDF4Out,help={"Store selected PDF4 into the file"}
	Button DeteteCardIn,pos={185,375},size={170,15},proc=IR3W_PDF4ButtonProc,title="Delete selected Cards Inside"
	Button DeteteCardIn,help={"Deletes selected cards Inside"}
	Button DeteteCardOut,pos={5,375},size={170,15},proc=IR3W_PDF4ButtonProc,title="Delete selected Cards Outside"
	Button DeteteCardOut,help={"Deletes selected cards Outside"}
	Button DownloadPDFCards,pos={65,400},size={230,20},proc=IR3W_PDF4ButtonProc,title="Download Irena Cards"
	Button DownloadPDFCards,help={"Download PDf cards from Irena web site"}
EndMacro


//**************************************************************************************
//**************************************************************************************
Function IR3W_PDF4ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))

	string OldDf=GetDataFolder(1)
	string ctrlName=ba.ctrlName
	variable i
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ctrlName,"UpdateListbox"))
				IR3W_PDF4UpdateOutsideListBox()
				IR3W_PDF4UpdateInsideListBox()
				IR3W_UpdatePDF4OfAvailFiles()
			endif
			if(stringmatch(ctrlName,"DeteteCardIn"))
				wave/T SaveLoadPDFInside=root:Packages:Irena:WAXS:SaveLoadPDFInside
				wave SaveLoadPDFInsideSel=root:Packages:Irena:WAXS:SaveLoadPDFInsideSel
				DoAlert /T="Are you sure?" 1, "You are about to delete PDF number of cards in this Igor experiment, are you sure?" 
				if(V_Flag==1)
					for(I=0;i<numpnts(SaveLoadPDFInside);i+=1)
						if(SaveLoadPDFInsideSel[i]&0x09)
							setDataFolder root:WAXS_PDF
							KillWaves/Z $(SaveLoadPDFInside[i])
						endif
					endfor
				endif
				IR3W_PDF4UpdateInsideListBox()
				IR3W_UpdatePDF4OfAvailFiles()
				SaveLoadPDFInsideSel=0
			endif
			if(stringmatch(ctrlName,"DeteteCardOut"))
				wave/T SaveLoadPDFOutside=root:Packages:Irena:WAXS:SaveLoadPDFOutside
				wave SaveLoadPDFOutsideSel=root:Packages:Irena:WAXS:SaveLoadPDFOutsideSel
				DoAlert /T="Are you sure?" 1, "You are about to delete PDF number of cards from this computer, are you sure?" 
				if(V_Flag==1)
					for(I=0;i<numpnts(SaveLoadPDFOutside);i+=1)
						if(SaveLoadPDFOutsideSel[i]&0x09)
							DeleteFile /P=WAXSPDF4Path  /Z   SaveLoadPDFOutside[i]+".xml"
						endif
					endfor
				endif
				IR3W_PDF4UpdateOutsideListBox()
				SaveLoadPDFOutsideSel=0
			endif
			if(stringmatch(ctrlName,"CopyPDF4Out"))
				wave/T SaveLoadPDFInside=root:Packages:Irena:WAXS:SaveLoadPDFInside
				wave SaveLoadPDFInsideSel=root:Packages:Irena:WAXS:SaveLoadPDFInsideSel
				for(I=0;i<numpnts(SaveLoadPDFInside);i+=1)
					if(SaveLoadPDFInsideSel[i]&0x09)
						IR3W_PDF4WriteDataOutXML(SaveLoadPDFInside[i])
					endif
				endfor
				IR3W_PDF4UpdateOutsideListBox()
				SaveLoadPDFInsideSel=0
			endif
			if(stringmatch(ctrlName,"CopyPDF4In"))
				wave/T SaveLoadPDFOutside=root:Packages:Irena:WAXS:SaveLoadPDFOutside
				wave SaveLoadPDFOutsideSel=root:Packages:Irena:WAXS:SaveLoadPDFOutsideSel
				for(I=0;i<numpnts(SaveLoadPDFOutside);i+=1)
					if(SaveLoadPDFOutsideSel[i]&0x09)
						IR3W_PDF4readPDFfromXML(SaveLoadPDFOutside[i])
					endif
				endfor
				IR3W_PDF4UpdateInsideListBox()
				IR3W_UpdatePDF4OfAvailFiles()
				SaveLoadPDFOutsideSel=0
			endif
			if(stringmatch(ctrlName,"DownloadPDFCards"))
				DoAlert /T="This feature is not finished yet" 0, "Here we help user to download cards from Irena web site"
				//to be done before release... Download zip file with existing PDF cards from APS web site
				//put it on the dekstop
				//open for users the folder where cards belong
				//provide instructions on what to do. 
				//should be easy. Make sure bailout is possible for users where Igor is not allowed to do http... 
			endif


			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//**************************************************************************************
//**************************************************************************************
Function IR3W_PDF4UpdateOutsideListBox()
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
		Wave/T  ww=root:Packages:Irena:WAXS:SaveLoadPDFOutside
		Wave  ww2=root:Packages:Irena:WAXS:SaveLoadPDFOutsideSel
		string ListOfAvailablePDF2s
		PathInfo WAXSPDF4Path
		if(V_Flag==0)
			abort
		endif
		ListOfAvailablePDF2s=IndexedFile(WAXSPDF4Path,-1,".xml")
		redimension/N=(ItemsInList(ListOfAvailablePDF2s)) ww, ww2
		variable i
		For(i=0;i<ItemsInList(ListOfAvailablePDF2s);i+=1)
			ww[i]=StringFromList(0,StringFromList(i, ListOfAvailablePDF2s),".")
		endfor
		sort ww, ww, ww2
end	
//**************************************************************************************
//**************************************************************************************
Function IR3W_PDF4UpdateInsideListBox()
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
		Wave/T  ww=root:Packages:Irena:WAXS:SaveLoadPDFInside
		Wave  ww2=root:Packages:Irena:WAXS:SaveLoadPDFInsideSel
		
		string ListOfAvailablePDF2s
		if(!DataFolderExists("root:WAXS_PDF"))
			abort
		endif
		ListOfAvailablePDF2s=IN2G_CreateListOfItemsInFolder("root:WAXS_PDF",2) 
		ListOfAvailablePDF2s = GrepList(ListOfAvailablePDF2s, "^((?!hklStr).)*$",0,";")
		redimension/N=(ItemsInList(ListOfAvailablePDF2s)) ww, ww2
		variable i
		For(i=0;i<ItemsInList(ListOfAvailablePDF2s);i+=1)
			ww[i]=StringFromList(i, ListOfAvailablePDF2s)
		endfor
		sort ww, ww, ww2
end	


//**************************************************************************************
//**************************************************************************************
Function IR3W_PDF4WriteDataOutXML(NewFileName)
		string NewFileName
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
		PathInfo WAXSPDF4Path
		if(V_Flag==0)
			abort
		endif
		string cif
		cif = IR3W_PDF4writePDFtoXMLstr(NewFileName)
		string NL="\r"
		Variable f
		//Open/C="R*ch"/F="XML Files (*.xml):.xml;"/P=WAXSPDF4Path/Z=2 f as NewFileName+".xml"
		Open/C="R*ch"/P=WAXSPDF4Path/Z=2 f as NewFileName+".xml"
		if (V_flag==0)
			fprintf f,  "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"+NL+NL
			FBinWrite f, cif
			Close f
		else
			DoAlert /T="Canot write file" 0, "File "+NewFileName+".xml could not be written. ßomething wnet wrong here."
		endif
		return V_flag
end
//**************************************************************************************
//**************************************************************************************

Function/T IR3W_PDF4writePDFtoXMLstr(DataName)
	string DataName
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	
	wave ww=$("root:WAXS_PDF:"+DataName)
	string NL="\r"

	String xmlStr="<IrenaPDF>"+NL
	String str, unit=" unit=\"A\""
	variable i, imax=dimsize(ww,0)
	variable tempd, tempvals
	xmlStr += "\t<user_name_common>"+nameofwave(ww)+"</user_name_common>"+NL
	xmlStr += "\t<!-- This card was generated by Irena WAXS tool. To edit this card manually, copy card under new name"+NL
	xmlStr += "\tThen edit the content. Make sure you rename the material name into unique name type (less than 23 characters!)"+NL
	xmlStr += "\tRequired content is : 1. either d [A] or Two Theta (TTH) [degrees for Cu wavelength] and Intensity [arbitrary units]."+NL
	xmlStr += "\tNote, that d is primary inforamtion, but if d is 0 it is calculated from TTH assuming wavelength of 1.54184A."+NL
	xmlStr += "\tNote, that h k l are very useful. F2 and mult are not useful at this time and can be empty or 0."+NL
	xmlStr += "\tData distributed with Irena are NOT GUARATEED and are calculated from theoretical models. If you find "+NL
	xmlStr += "\twrong values or want to add some cards to Irena distribution, please send the data to ilavsky@aps.anl.gov. "+NL
	xmlStr += "\tKeep the structure of this file unchanged or it may not be interpretted correctly by the reader."+NL
	xmlStr += "\tSource of data: LaueGo calculation.   -->"+NL
	xmlStr += "\t<data>"+NL
		For(i=0;i<imax;i+=1)
			//convert Q if neede to d and A and append to the string. 
			tempd = ww[i][0]
			if(stringmatch(GetDimLabel(ww, 1, 0),"Q_nm"))		//calculated from LaueGo, Q in nm-1
				tempd = IN2G_ConvertQtoD(tempd/10,1)				//d in A
			endif
			unit=" unit=\"A\""
			xmlStr += "\t\t<d"+unit+">"+num2str(tempd)+"</d>"
			tempvals = ww[i][1]
			xmlStr += "<h>"+num2str(tempvals)+"</h>"
			tempvals = ww[i][2]
			xmlStr += "<k>"+num2str(tempvals)+"</k>"
			tempvals = ww[i][3]
			xmlStr += "<l>"+num2str(tempvals)+"</l>"
			tempd = IN2G_ConvertDtoTTH(tempd,1.54184)		//convert to TWoTheta Cu wavelength
			unit=" unit=\"deg_for_Cu\""
			xmlStr += "<TTH"+unit+">"+num2str(tempd)+"</TTH>"
			tempvals = ww[i][5]
			xmlStr += "<F2>"+num2str(tempvals)+"</F2>"
			tempvals = ww[i][6]
			xmlStr += "<Intensity>"+num2str(tempvals)+"</Intensity>"
			tempvals = ww[i][7]
			xmlStr += "<mult>"+num2str(tempvals)+"</mult>"+NL
		endfor
	xmlStr += "\t</data>"+NL
	xmlStr += "</IrenaPDF>"+NL
	return xmlStr
end

//**************************************************************************************
//**************************************************************************************

Function IR3W_PDF4readPDFfromXML(NewFileName)
	string NewFileName
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
		
		if(!DataFolderExists("root:WAXS_PDF"))
			abort
		endif
		string OldDf=GetDataFolder(1)
		setDataFolder root:WAXS_PDF
		PathInfo WAXSPDF4Path
		if(V_Flag==0)
			abort
		endif
		Variable f
		Open/R/P=WAXSPDF4Path/Z=2 f as NewFileName+".xml"
		Variable lineNumber, len, isIrenaPDF, isData
		String buffer, UserSampleName
		lineNumber = 0
		isIrenaPDF=0
		isData=0
		UserSampleName = ""
		do
			FReadLine f, buffer
			len = strlen(buffer)
			if (len == 0)
				break						// No more lines to be read
			endif
			if(grepString(buffer,"IrenaPDF"))
				isIrenaPDF = 1
			endif
			if(isIrenaPDF)
				if(grepString(buffer,"user_name_common"))
					UserSampleName = buffer
					UserSampleName = ReplaceString("\t<user_name_common>", buffer, "")
					UserSampleName = ReplaceString("</user_name_common>\r", UserSampleName, "")
					//check if the file exists, and ask user what to do...
					UserSampleName  = cleanupname(UserSampleName,0)
					wave/Z ww=$(UserSampleName)
					if(WaveExists(ww))
						DoAlert /T="Card with this name exists" 2, "Choose what to do: Overwrite = OK, Create new unique name = NO, Cancel"
						if(V_Flag==1)
							KillWaves ww
						elseif(V_Flag==2)
							UserSampleName=UniqueName(UserSampleName, 1, 0)
						else  //cancel
							close f
							setDataFOlder OldDf
							abort
						endif
					endif
				endif
				if(grepString(buffer,"<data>"))
					isData = 1
				endif
				if(grepString(buffer,"</data>"))
					isData = 0
				endif
				if(isData&&!(grepString(buffer,"<data>")))
					IR3W_PDF4parseXMLFileLine(buffer,UserSampleName)
				endif
			endif
			lineNumber += 1
		while (1)	
		close f
		//add the dimensions to this new data and cretae the hklStr wave also... 
		wave/Z ww=$(UserSampleName)
		if(WaveExists(ww))
			make/O/T/N=(dimsize(ww,0)) $(UserSampleName[0,23]+"_hklStr")
			wave/T wwT = $(UserSampleName[0,23]+"_hklStr") 
			SetDimLabel 1,0,d_A,ww
			SetDimLabel 1,1,h,ww
			SetDimLabel 1,2,k,ww
			SetDimLabel 1,3,l,ww
			SetDimLabel 1,4,theta,ww
			SetDimLabel 1,5,F2,ww
			SetDimLabel 1,6,Intensity,ww
			SetDimLabel 1,7,mult,ww
			wwT = "("+num2str(ww[p][1])+num2str(ww[p][2])+num2str(ww[p][3])+")"
		endif
		setDataFOlder OldDf
end
//**************************************************************************************
//**************************************************************************************

Function IR3W_PDF4parseXMLFileLine(line,InternalName)
	string line,InternalName
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	
	if(!DataFolderExists("root:WAXS_PDF"))
		abort
	endif
	string OldDf=GetDataFolder(1)
	setDataFolder root:WAXS_PDF
	InternalName  = cleanupname(InternalName,0)
	wave/Z ww=$(InternalName)
	if(!WaveExists(ww))
		make/O/N=(0,8) $(InternalName)
		wave ww=$(InternalName)
	endif
	variable i=dimsize(ww,0)
	variable tempd, tempTTH
	redimension/N=(dimsize(ww,0)+1,dimsize(ww,1)) ww
	//<d unit="A">2.338</d><h>1</h><k>1</l><l>1</l><TTH unit="deg_for_Cu">38.506</TTH><F2>1313.5</F2><Intensity>25023</Intensity><mult>8</mult>
	tempd= str2num(IN2G_XMLtagContents("d",line))
	tempTTH= str2num(IN2G_XMLtagContents("TTH",line))
	if(numtype(tempd)!=0 || tempd<0.0001)		//no d spacing data, calculate from TTH
		tempd = IN2G_ConvertTTHtoD(tempTTH,1.54184)
	endif
	ww[i][0] = tempd
	ww[i][1] = str2num(IN2G_XMLtagContents("h",line))
	ww[i][2] = str2num(IN2G_XMLtagContents("k",line))
	ww[i][3] = str2num(IN2G_XMLtagContents("l",line))
	ww[i][4] = tempTTH/2											//this card saves TH, not TTH to macth LaueGo format. 
	ww[i][5] = str2num(IN2G_XMLtagContents("F2",line))
	ww[i][6] = str2num(IN2G_XMLtagContents("Intensity",line))
	ww[i][7] = str2num(IN2G_XMLtagContents("mult",line))
	setDataFOlder OldDf
end



//**************************************************************************************
//**************************************************************************************


//**************************************************************************************
//**************************************************************************************


//**************************************************************************************
//**************************************************************************************

//**************************************************************************************
//**************************************************************************************
//				LAUEGO part
//**************************************************************************************
//**************************************************************************************

Function IR3W_PDF4AddFromLaueGo()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	String OldDf=GetDataFolder(1)
	NewDataFolder/O/S root:WAXS_PDF 
	
	DoWindow LatticeSet
	if(V_Flag)		//already opened...
		DoWIndow/F LatticeSet
	else				//no window, let/s open it.
		variable isLaueGoLoaded = IR3W_CheckOrLoadForLaueGo()
		if(isLaueGoLoaded<1)
			setDataFolder OldDf
			return 0
		endif
	endif
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3W_CheckOrLoadForLaueGo()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	if(exists("MakeLatticeParametersPanel"))		//aleready loaded...	
		Execute "MakeLatticeParametersPanel(\"\")"
		return 1
	elseif(exists("microMenuShowN")==6)			//one of LaueGoFirst.ipf package functions exists, so LaueGoFirst.ipf is loaded, should be easy to do...
			Execute/P "INSERTINCLUDE  \"LatticeSym\", version>=3.77";Execute/P "COMPILEPROCEDURES ";Execute/P "InitLatticeSymPackage(showPanel=1)"
			return 1
	else		//not included yet, need to find, if it exists or give instructions...
		IR3W_LaueGoProgressPanelF() 
		IR3W_ListIgorProcFiles()
		IR3W_ListUserProcFiles()
		Wave/T FileNames = root:Packages:UseProcedureFiles:FileNames
		make/FREE/T/N=0 TestedNames
		//string MatchedList 
		Grep/E="LaueGoFirst" FileNames as TestedNames
		KillDataFolder root:Packages:UseProcedureFiles:
		DoWIndow/K IR3W_LaueGoProgressPanel
		
		if(numpnts(TestedNames)>0)
			//found the package, assume LaueGo can be loaded. This may still fail, but I have not better way to check here. 
			Execute/P "INSERTINCLUDE  \"LatticeSym\", version>=3.77";Execute/P "COMPILEPROCEDURES ";Execute/P "InitLatticeSymPackage(showPanel=1)"
			return 1
		else
			DoAlert 0, "LaueGo not available. Go to http://sector34.xray.aps.anl.gov/~tischler/ and download LaueGo_install.ipf. Install LaueGo using this file and come back to this exeriment. "
			saveExperiment
			return 0
		endif
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//********
Function IR3W_LaueGoProgressPanelF() : Panel
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(593,358,1039,435) as "Checking for LaueGo Presence"
	DoWindow/C IR3W_LaueGoProgressPanel
	SetDrawLayer UserBack
	SetDrawEnv fstyle= 3,textrgb= (0,0,65535)
	DrawText 21,28,"\\Z18Checking for presence of LayeGo Package"
	DrawText 30,57,"\\Z18 . . .     working   ..."
EndMacro

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//********
static Function IR3W_ListIgorProcFiles()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	GetFileFolderInfo/Q/Z/P=Igor "Igor Procedures"	
	if(V_Flag==0)
		IR3W_ListProcFiles(S_Path,1 )
	endif
	GetFileFolderInfo/Q/Z IR3W_GetIgorUserFilesPath()+"Igor Procedures:"
	if(V_Flag==0)
		IR3W_ListProcFiles(IR3W_GetIgorUserFilesPath()+"Igor Procedures:",0)
	endif
	KillPath/Z tempPath
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//********
static Function IR3W_ListUserProcFiles()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	GetFileFolderInfo/Q/Z/P=Igor "User Procedures"	
	if(V_Flag==0)
		IR3W_ListProcFiles(S_Path,1)
	endif
	String path
	//HR Create path variable for easier debugging
	path = IR3W_GetIgorUserFilesPath()				//HR This is needed because of a bug in SpecialDirPath prior to 6.20B03.
	path += "User Procedures:"	
	GetFileFolderInfo/Q/Z (path)	
	if(V_Flag==0)
		IR3W_ListProcFiles(path,0)	//HR Reuse path variable
	endif

	KillPath/Z tempPath
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//********
static Function/S IR3W_GetIgorUserFilesPath()
	// This should be a Macintosh path but, because of a bug prior to Igor Pro 6.20B03
	// it may be a Windows path.
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	String path = SpecialDirPath("Igor Pro User Files", 0, 0, 0)
	path = ParseFilePath(5, path, ":", 0, 0)
	return path
End
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function IR3W_ListProcFiles(PathStr, resetWaves)
	string PathStr
	variable resetWaves
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,GetRTStackInfo(1))
	
	String abortMessage	//HR Used if we have to abort because of an unexpected error
	
	string OldDf=GetDataFolder(1)
	//create location for the results waves...
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:UseProcedureFiles
	//if this is top call to the routine we need to wipe out the waves so we remove old junk
	string CurFncName=GetRTStackInfo(1)
	string CallingFncName=GetRTStackInfo(2)
	variable runningTopLevel=0
	if(!stringmatch(CurFncName,CallingFncName))
		runningTopLevel=1
	endif
	if(resetWaves)
			Make/O/N=0/T FileNames		
			Make/O/N=0/T PathToFiles
			Make/O/N=0 FileVersions
	endif
	
	
	//if this was first call, now the waves are gone.
	//and now we need to create the output waves
	Wave/Z/T FileNames
	Wave/Z/T PathToFiles
	Wave/Z FIleVersions
	If(!WaveExists(FileNames) || !WaveExists(PathToFiles) || !WaveExists(FIleVersions))
		Make/O/T/N=0 FileNames, PathToFIles
		Make/O/N=0 FileVersions
		Wave/T FileNames
		Wave/T PathToFiles
		Wave FileVersions
		//I am not sure if we really need all of those declarations, but, well, it should not hurt...
	endif 
	
	//this is temporary path to the place we are looking into now...  
	NewPath/Q/O tempPath, PathStr
	if (V_flag != 0)		//HR Add error checking to prevent infinite loop
		sprintf abortMessage, "Unexpected error creating a symbolic path pointing to \"%s\"", PathStr
		Print abortMessage	// To make debugging easier
		Abort abortMessage
	endif

	//list al items in this path
	string ItemsInTheFolder= IndexedFile(tempPath,-1,"????")+IndexedDir(tempPath, -1, 0 )
	
	//HR If there is a shortcut in "Igor Procedures", ItemsInTheFolder will include something like "HDF5 Browser.ipf.lnk". Windows shortcuts are .lnk files.	
	
	//remove all . files. 
	ItemsInTheFolder = GrepList(ItemsInTheFolder, "^\." ,1)
	//Now we removed all junk files on Macs (starting with .)
	//now lets check what each of these files are and add to the right lists or follow...
	variable i, imax=ItemsInList(ItemsInTheFolder)
	string tempFileName, tempScraptext, tempPathStr
	variable IamOnMac, isItXOP
	if(stringmatch(IgorInfo(2),"Windows"))
		IamOnMac=0
	else
		IamOnMac=1
	endif
	For(i=0;i<imax;i+=1)
		tempFileName = stringfromlist(i,ItemsInTheFolder)
		GetFileFolderInfo/Z/Q/P=tempPath tempFileName
		isItXOP = IamOnMac * stringmatch(tempFileName, "*xop*" )
		
		if(V_isAliasShortcut)
			//HR If tempFileName is "HDF5 Browser.ipf.lnk", or any other shortcut to a file, S_aliasPath is a path to a file, not a folder.
			//HR Thus the "NewPath tempPath" command will fail.
			//HR Thus tempPath will retain its old value, causing you to recurse the same folder as before, resulting in an infinite loop.
			
			//is alias, need to follow and look further. Use recursion...
			if(strlen(S_aliasPath)>3)		//in case user has stale alias, S_aliasPath has 0 length. Need to skip this pathological case. 
				//HR Recurse only if S_aliasPath points to a folder. I don't really know what I'm doing here but this seems like it will prevent the infinite loop.
				GetFileFolderInfo/Z/Q/P=tempPath S_aliasPath	
				isItXOP = IamOnMac * stringmatch(S_aliasPath, "*xop*" )
				if (V_flag==0 && V_isFolder&&!isItXOP)		//this is folder, so all items in the folder are included... Except XOP is folder too... 
					IR3W_ListProcFiles(S_aliasPath, 0)
				elseif(V_flag==0 && (!V_isFolder || isItXOP))	//this is link to file. Need to include the info on the file...
					//*************
					Redimension/N=(numpnts(FileNames)+1) FileNames, PathToFiles,FileVersions
					tempFileName =stringFromList(ItemsInList(S_aliasPath,":")-1, S_aliasPath,":")
					tempPathStr = RemoveFromList(tempFileName, S_aliasPath,":")
					FileNames[numpnts(FileNames)-1] = tempFileName
					PathToFiles[numpnts(FileNames)-1] = tempPathStr
					//try to get version from #pragma version = ... This seems to be the most robust way I found...
					NewPath/Q/O tempPath, tempPathStr
					if(stringmatch(tempFileName, "*.ipf"))
						Grep/P=tempPath/E="(?i)^#pragma[ ]*version[ ]*=[ ]*" tempFileName as "Clipboard"
						sleep/s (0.02)
						tempScraptext = GetScrapText()
						if(strlen(tempScraptext)>10)		//found line with #pragma version"
							tempScraptext = replaceString("#pragma",tempScraptext,"")	//remove #pragma
							tempScraptext = replaceString("version",tempScraptext,"")		//remove version
							tempScraptext = replaceString("=",tempScraptext,"")			//remove =
							tempScraptext = replaceString("\t",tempScraptext,"  ")			//remove optional tabulators, some actually use them. 
							tempScraptext = removeending(tempScraptext," \r")			//remove optional tabulators, some actually use them. 
							//forget about the comments behind the text. 
		                                       //str2num is actually quite clever in this and converts start of the string which makes sense. 
							FileVersions[numpnts(FileNames)-1]=str2num(tempScraptext)
						else             //no version found, set to NaN
							FileVersions[numpnts(FileNames)-1]=NaN
						endif
					else                    //no version for non-ipf files
						FileVersions[numpnts(FileNames)-1]=NaN
					endif
				//************


				endif
			endif
			//and now when we got back, fix the path definition to previous or all will crash...
			NewPath/Q/O tempPath, PathStr
			if (V_flag != 0)		//HR Add error checking to prevent infinite loop
				sprintf abortMessage, "Unexpected error creating a symbolic path pointing to \"%s\"", PathStr
				Print abortMessage	// To make debugging easier
				Abort abortMessage
			endif
		elseif(V_isFolder&&!isItXOP)	
			//is folder, need to follow into it. Use recursion.
			IR3W_ListProcFiles(PathStr+tempFileName+":", 0)
			//and fix the path back or all will fail...
			NewPath/Q/O tempPath, PathStr
			if (V_flag != 0)		//HR Add error checking to prevent infinite loop
				sprintf abortMessage, "Unexpected error creating a symbolic path pointing to \"%s\"", PathStr
				Print abortMessage	// To make debugging easier
				Abort abortMessage
			endif
		elseif(V_isFile||isItXOP)
			//this is real file. Store information as needed. 
			Redimension/N=(numpnts(FileNames)+1) FileNames, PathToFiles,FileVersions
			FileNames[numpnts(FileNames)-1] = tempFileName
			PathToFiles[numpnts(FileNames)-1] = PathStr
			//try to get version from #pragma version = ... This seems to be the most robust way I found...
			if(stringmatch(tempFileName, "*.ipf"))
				Grep/P=tempPath/E="(?i)^#pragma[ ]*version[ ]*=[ ]*" tempFileName as "Clipboard"
				sleep/s(0.02)
				tempScraptext = GetScrapText()
				if(strlen(tempScraptext)>10)		//found line with #pragma version"
					tempScraptext = replaceString("#pragma",tempScraptext,"")	//remove #pragma
					tempScraptext = replaceString("version",tempScraptext,"")		//remove version
					tempScraptext = replaceString("=",tempScraptext,"")			//remove =
					tempScraptext = replaceString("\t",tempScraptext,"  ")			//remove optional tabulators, some actually use them. 
					//forget about the comments behind the text. 
                                       //str2num is actually quite clever in this and converts start of the string which makes sense. 
					FileVersions[numpnts(FileNames)-1]=str2num(tempScraptext)
				else             //no version found, set to NaN
					FileVersions[numpnts(FileNames)-1]=NaN
				endif
			else                    //no version for non-ipf files
				FileVersions[numpnts(FileNames)-1]=NaN
			endif
		endif
	endfor 
	setDataFolder OldDf
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
