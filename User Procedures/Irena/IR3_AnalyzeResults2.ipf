#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=0.2


//*************************************************************************\
//* Copyright (c) 2005 - 2022, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/


constant IR3EversionNumber = 0.1			//AnalyzeResults panel version number

// AnalyzeResults = short name of package
// IR3E = working prefix, short (e.g., IR3DM) 
// add IR3E_MainCheckVersion to Irena after compile hook finction correctly

// Version notes:
//0.2 add handling of USAXS M_... waves 
//0.1	Working version. 

//
//Menu "Development"
//	"Analyze results", IR3E_AnalyzeResults()
//end
/////******************************************************************************************
/////******************************************************************************************
/////******************************************************************************************
/////******************************************************************************************
Function IR3E_AnalyzeResults()

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IN2G_CheckScreenSize("width",1200)
	DoWIndow IR3E_AnalyzeResultsPanel
	if(V_Flag)
		DoWindow/F IR3E_AnalyzeResultsPanel
	else
		IR3E_InitAnalyzeResults()
		IR3E_AnalyzeResultsPanelFnct()
		ING2_AddScrollControl()
		IR1_UpdatePanelVersionNumber("IR3E_AnalyzeResultsPanel", IR3EversionNumber,1)
		IR3C_MultiUpdListOfAvailFiles("Irena:AnalyzeResults")	
	endif
	IR3E_CreateAnalyzeResultsGraphs()
end
////************************************************************************************************************
Function IR3E_MainCheckVersion()	
	DoWindow IR3E_AnalyzeResultsPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR3E_AnalyzeResultsPanel", IR3EversionNumber))
			DoAlert /T="The AnalyzeResults panel was created by incorrect version of Irena " 1, "AnalyzeResults needs to be restarted to work properly. Restart now?"
			if(V_flag==1)
				KillWIndow/Z IR3E_AnalyzeResultsPanel
				KillWindow/Z IR3E_MainDataDisplay
				IR3E_AnalyzeResults()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR3E_InitAnalyzeResults()
			endif
		endif
	endif
end
//
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
Function IR3E_AnalyzeResultsPanelFnct()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(2.25,43.25,530,800) as "Analyze results"
	DoWIndow/C IR3E_AnalyzeResultsPanel
	TitleBox MainTitle title="Analyze Results",pos={140,2},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fSize=22,fColor=(0,0,52224)
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	string ResultsAllowed="SizesVolumeDistribution;SizesNumberDistribution;NumberDistModelLSQF2;VolumeDistModelLSQF2;"
	ResultsAllowed+="NumberDistModelLSQF2pop1;VolumeDistModelLSQF2pop1;NumberDistModelLSQF2pop2;VolumeDistModelLSQF2pop2;"
	ResultsAllowed+="NumberDistModelLSQF2pop3;VolumeDistModelLSQF2pop3;NumberDistModelLSQF2pop4;VolumeDistModelLSQF2pop4;"
	ResultsAllowed+="NumberDistModelLSQF2pop5;VolumeDistModelLSQF2pop5;NumberDistModelLSQF2pop6;VolumeDistModelLSQF2pop6;"
	IR2C_AddDataControls("Irena:AnalyzeResults","IR3E_AnalyzeResultsPanel","",ResultsAllowed,UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	IR3C_MultiAppendControls("Irena:AnalyzeResults","IR3E_AnalyzeResultsPanel", "IR3E_CopyAndAppendData","",1,0)
	//hide what is not needed
	Checkbox UseIndra2Data, disable=1
	checkbox UseQRSData, disable=1 
	checkbox UseResults, disable=1
	NVAR UseResults = root:Packages:Irena:AnalyzeResults:UseResults
	UseResults = 1
	NVAR UseQRSData = root:Packages:Irena:AnalyzeResults:UseQRSData
	UseQRSData = 0
	NVAR UseIndra2Data = root:Packages:Irena:AnalyzeResults:UseIndra2Data
	UseIndra2Data = 0
	IR3C_MultiFixPanelControls("IR3E_AnalyzeResultsPanel","Irena:AnalyzeResults")	
	TitleBox Dataselection, pos={15,25}
	SetVariable DataQEnd,pos={290,90},size={190,15}, proc=IR3E_SetVarProc,title="Data max "
	Setvariable DataQEnd, variable=root:Packages:Irena:AnalyzeResults:DataQEnd, limits={-inf,inf,0}
	SetVariable DataQstart,pos={290,110},size={190,15}, proc=IR3E_SetVarProc,title="Data min "
	Setvariable DataQstart, variable=root:Packages:Irena:AnalyzeResults:DataQstart, limits={-inf,inf,0}
	SetVariable DataFolderName,noproc,title=" ",pos={260,160},size={270,17},frame=0, fstyle=1,valueColor=(0,0,65535)
	Setvariable DataFolderName, variable=root:Packages:Irena:AnalyzeResults:DataFolderName, noedit=1



	Button SelectAll,pos={180,680},size={80,15}, proc=IR3E_ButtonProc,title="SelectAll", help={"Select All data in Listbox"}
//
	Button GetHelp,pos={430,50},size={80,15},fColor=(65535,32768,32768), proc=IR3E_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}

//	here go various controls...
	PopupMenu AnalysisMethodSelected,pos={280,175},size={200,20},fStyle=2,proc=IR3E_PopMenuProc,title="Function : "
	SVAR AnalysisMethodSelected = root:Packages:Irena:AnalyzeResults:AnalysisMethodSelected
	PopupMenu AnalysisMethodSelected,mode=1,popvalue=AnalysisMethodSelected,value= #"root:Packages:Irena:AnalyzeResults:ListOfAnalysisMethods" 
	CheckBox AnalysisCheckbox1,pos={275,200},size={79,14},noproc,title="TBA", help={""}
	CheckBox AnalysisCheckbox2,pos={400,200},size={79,14},noproc,title="TBA", help={""}
	CheckBox AnalysisCheckbox3,pos={275,217},size={79,14},noproc,title="TBA", help={""}
	CheckBox AnalysisCheckbox4,pos={400,217},size={79,14},noproc,title="TBA", help={""}
	
	SetVariable AnalysisInputPar1,pos={370,240},size={140,17},title="AnalysisInputPar1",proc=IR3E_SetVarProc, disable=1, bodywidth=90,limits={0,inf,1}, help={"AnalysisInputPar1"}
	SetVariable AnalysisInputPar2,pos={370,263},size={140,17},title="AnalysisInputPar2",proc=IR3E_SetVarProc, disable=1, bodywidth=90,limits={0,inf,1}, help={"AnalysisInputPar2"}
	SetVariable AnalysisInputPar3,pos={370,286},size={140,17},title="AnalysisInputPar3",proc=IR3E_SetVarProc, disable=1, bodywidth=90,limits={0,inf,1}, help={"AnalysisInputPar3"}
	
	
	SetVariable AnalysisOutputPar1,pos={370,330},size={140,17},title="AnalysisOutputPar1",proc=IR3E_SetVarProc, disable=1, bodywidth=90,limits={0,inf,1}, help={"AnalysisOutputPar1"}
	SetVariable AnalysisOutputPar2,pos={370,353},size={140,17},title="AnalysisOutputPar2",proc=IR3E_SetVarProc, disable=1, bodywidth=90,limits={0,inf,1}, help={"AnalysisOutputPar2"}
	SetVariable AnalysisOutputPar3,pos={370,376},size={140,17},title="AnalysisOutputPar3",proc=IR3E_SetVarProc, disable=1, bodywidth=90,limits={0,inf,1}, help={"AnalysisOutputPar3"}
	SetVariable AnalysisOutputPar4,pos={370,399},size={140,17},title="AnalysisOutputPar4",proc=IR3E_SetVarProc, disable=1, bodywidth=90,limits={0,inf,1}, help={"AnalysisOutputPar4"}
	SetVariable AnalysisOutputPar5,pos={370,422},size={140,17},title="AnalysisOutputPar5",proc=IR3E_SetVarProc, disable=1, bodywidth=90,limits={0,inf,1}, help={"AnalysisOutputPar5"}
	SetVariable AnalysisOutputPar6,pos={370,445},size={140,17},title="AnalysisOutputPar6",proc=IR3E_SetVarProc, disable=1, bodywidth=90,limits={0,inf,1}, help={"AnalysisOutputPar6"}
	SetVariable AnalysisOutputPar7,pos={370,468},size={140,17},title="AnalysisOutputPar7",proc=IR3E_SetVarProc, disable=1, bodywidth=90,limits={0,inf,1}, help={"AnalysisOutputPar7"}
	SetVariable AnalysisOutputPar8,pos={370,491},size={140,17},title="AnalysisOutputPar8",proc=IR3E_SetVarProc, disable=1, bodywidth=90,limits={0,inf,1}, help={"AnalysisOutputPar8"}
	SetVariable AnalysisOutputPar9,pos={370,514},size={140,17},title="AnalysisOutputPar9",proc=IR3E_SetVarProc, disable=1, bodywidth=90,limits={0,inf,1}, help={"AnalysisOutputPar9"}
	SetVariable AnalysisOutputPar10,pos={370,537},size={140,17},title="AnalysisOutputPar10",proc=IR3E_SetVarProc, disable=1, bodywidth=90,limits={0,inf,1}, help={"AnalysisOutputPar10"}


	TitleBox Instructions1 title="\Zr100Double click to add data to graph",size={330,15},pos={4,680},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions2 title="\Zr100Shift-click to select range of data",size={330,15},pos={4,695},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions3 title="\Zr100Ctrl/Cmd-click to select one data set",size={330,15},pos={4,710},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions4 title="\Zr100Regex for not contain: ^((?!string).)*$",size={330,15},pos={4,725},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions5 title="\Zr100Regex for contain:  string, two: str2.*str1",size={330,15},pos={4,740},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions6 title="\Zr100Regex for case independent:  (?i)string",size={330,15},pos={4,755},frame=0,fColor=(0,0,65535),labelBack=0

	//Button RecalculateModel,pos={275,640},size={110,20}, proc=IR3E_ButtonProc, title="Calculate Results", help={"Calculate results now"}
	Button CalculateResults,pos={275,665},size={110,20}, proc=IR3E_ButtonProc, title="Calculate Results", help={"Calculate results now"}
	Button CalculateSequenceResults, pos={275,690},size={110,20}, proc=IR3E_ButtonProc, title="Evaluate sequence", help={"Evaluate sequence of data selected in the ListBox "}

	//CheckBox RecalculateAutomatically,pos={400,640},size={79,14},proc=IR3E_MainPanelCheckProc,title="Auto Recalculate?", variable= root:Packages:Irena:AnalyzeResults:UpdateAutomatically, help={"Recalculate when any number changes?"}
	CheckBox SaveToNotebook,pos={400,660},size={79,14},noproc,title="Save To Notebook?", variable= root:Packages:Irena:AnalyzeResults:SaveToNotebook, help={"Save results to Notebook?"}
	CheckBox SaveToFolder,pos={400,680},size={79,14},noproc,title="Save To folder?", variable= root:Packages:Irena:AnalyzeResults:SaveToFolder, help={"Save results to folder?"}
	CheckBox SaveToWaves,pos={400,700},size={79,14},noproc,title="Save To waves?", variable= root:Packages:Irena:AnalyzeResults:SaveToWaves, help={"Save results to waves in folder?"}
	Button   SaveResults,pos={400,720},size={110,18}, proc=IR3E_ButtonProc, title="Save Results", help={"Save results"}

	SetVariable DelayBetweenProcessing,pos={240,735},size={150,16},noproc,title="Delay in Seq. Proc:", help={"Delay between sample in sequence of processing data sets"}
	SetVariable DelayBetweenProcessing,limits={0,30,0},variable= root:Packages:Irena:AnalyzeResults:DelayBetweenProcessing, bodywidth=50

//	
//	//and fix which controls are displayed:
//	
	IR3E_SetupControlsOnMainPanel()
end



//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3E_SetupControlsOnMainPanel()
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR AnalysisMethodSelected = root:Packages:Irena:AnalyzeResults:AnalysisMethodSelected
	DoWindow IR3E_AnalyzeResultsPanel
	if(V_Flag)

		PopupMenu AnalysisMethodSelected,win=IR3E_AnalyzeResultsPanel, disable=0
		SVAR AnalysisMethodSelected = root:Packages:Irena:AnalyzeResults:AnalysisMethodSelected	
		if(stringMatch(AnalysisMethodSelected,"SizeDistribution"))
			CheckBox AnalysisCheckbox1,win=IR3E_AnalyzeResultsPanel,proc=IR3E_CheckProc,title="Display MIP curve?", variable=root:Packages:Irena:AnalyzeResults:SDMIPCreateCurves, help={"Check to display MIP curve"}, disable=0
			CheckBox AnalysisCheckbox2,win=IR3E_AnalyzeResultsPanel,proc=IR3E_CheckProc,title="Cumulative curves?", variable=root:Packages:Irena:AnalyzeResults:SDCreateCumulativeCurves, help={"Check to display cumulative curves"}, disable=0
			CheckBox AnalysisCheckbox3,win=IR3E_AnalyzeResultsPanel,disable=1
			CheckBox AnalysisCheckbox4,win=IR3E_AnalyzeResultsPanel,proc=IR3E_CheckProc,title="Invert Cumulative?", variable=root:Packages:Irena:AnalyzeResults:InvertCumulativeDists, help={"Invert Cumulative curves"}, disable=0
		
	
			SetVariable AnalysisInputPar1,win=IR3E_AnalyzeResultsPanel,disable=1
			SetVariable AnalysisInputPar2,win=IR3E_AnalyzeResultsPanel,disable=1
			SetVariable AnalysisInputPar3,win=IR3E_AnalyzeResultsPanel,disable=1
		
			SetVariable AnalysisOutputPar1,win=IR3E_AnalyzeResultsPanel,value=root:Packages:Irena:AnalyzeResults:SDVolumeInRange ,title="Volume fraction   ", disable=0,noedit=1, limits={0,inf,0}, help={"Calculated volume fraction in between cursors"}		
			SetVariable AnalysisOutputPar2,win=IR3E_AnalyzeResultsPanel,value=root:Packages:Irena:AnalyzeResults:SDNumberDensity ,title="Number density [1/cm3] ", disable=0,noedit=1, limits={0,inf,0}, help={"Calculated number desnity 1/cm3 in between cursors"}
			SetVariable AnalysisOutputPar3,win=IR3E_AnalyzeResultsPanel,value=root:Packages:Irena:AnalyzeResults:SDSpecSurfaceArea ,title="Spec sfc area [cm2/cm3] ", disable=0,noedit=1, limits={0,inf,0}, help={"Calculated specific surface area in cm2/cm3 in between cursors"}
			SetVariable AnalysisOutputPar4,win=IR3E_AnalyzeResultsPanel,value=root:Packages:Irena:AnalyzeResults:SDMean   ,title="Mean   [A]  ", disable=0,noedit=1, limits={0,inf,0}, help={"Calculated mean in between cursors"}
			SetVariable AnalysisOutputPar5,win=IR3E_AnalyzeResultsPanel,value=root:Packages:Irena:AnalyzeResults:SDMode   ,title="Mode   [A]  ", disable=0,noedit=1, limits={0,inf,0}, help={"Calculated mode in between cursors"}
			SetVariable AnalysisOutputPar6,win=IR3E_AnalyzeResultsPanel,value=root:Packages:Irena:AnalyzeResults:SDMedian ,title="Median [A]  ", disable=0,noedit=1, limits={0,inf,0}, help={"Calculated median in between cursors"}
			SetVariable AnalysisOutputPar7,win=IR3E_AnalyzeResultsPanel,value=root:Packages:Irena:AnalyzeResults:SDFWHM   ,title="FWHM   [A]  ", disable=0,noedit=1, limits={0,inf,0}, help={"Calculated FWHM in between cursors"}
			SetVariable AnalysisOutputPar8,win=IR3E_AnalyzeResultsPanel,value=root:Packages:Irena:AnalyzeResults:SDMIPsigma ,title="MIP sigma ", disable=0,noedit=0, limits={0,inf,0}, help={"Sigma typ 485 mN/m2 = dynes/cm, Radlinski, Oct 2007"}
			SetVariable AnalysisOutputPar9,win=IR3E_AnalyzeResultsPanel,value=root:Packages:Irena:AnalyzeResults:SDMIPcosTheta ,title="MIP cos(theta) ", disable=0,noedit=1, limits={0,inf,0}, help={"Cos(theta) - surface tension typ -0.766, Radlinski, Oct 2007"}
			SetVariable AnalysisOutputPar10,win=IR3E_AnalyzeResultsPanel,value=root:Packages:Irena:AnalyzeResults:SDRg 	  ,title="Rg [A]     ", disable=0,noedit=1, limits={0,inf,0}, help={"Rg for whole distribution [A]"}
			Setvariable DataQEnd,win=IR3E_AnalyzeResultsPanel, title="Max size for analysis"
			SetVariable DataQstart,win=IR3E_AnalyzeResultsPanel, title="Min size for analysis"
		endif
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3E_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			if(StringMatch(cba.ctrlName, "AnalysisCheckbox1"))	//this is Display MIP curves.. 
				IR3E_SDCreateMIPCurve()
				IR3E_SDMIPDataGraph()
			endif
			if(StringMatch(cba.ctrlName, "AnalysisCheckbox2")||StringMatch(cba.ctrlName, "AnalysisCheckbox4"))	//these are Cumulative Curves checkbox.. 
				IR3E_SDCreateCumulativeCurves()
				IR3E_SDDisplayCumulativeCurves()
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3E_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"CalculateResults"))
				IR3E_RecalculateAnalysis()
			endif
			if(stringmatch(ba.ctrlName,"SaveResults"))
				NVAR SaveToNotebook=root:Packages:Irena:AnalyzeResults:SaveToNotebook
				NVAR SaveToWaves=root:Packages:Irena:AnalyzeResults:SaveToWaves
				NVAR SaveToFolder=root:Packages:Irena:AnalyzeResults:SaveToFolder
				if(SaveToNotebook+SaveToWaves+SaveToFolder<1)
					Abort "Nothing is selected to Record, check at least on checkbox above" 
				endif	
				IR3E_RecalculateAnalysis()
				IR3E_SaveResultsToNotebook()
				IR3E_SaveResultsToWaves()
				IR3E_SaveResultsToFolder()
			endif
			if(stringmatch(ba.ctrlName,"CalculateSequenceResults"))
				IR3E_AnalyzeSequenceOfData()
			endif
//			if(stringmatch(ba.ctrlName,"GetTableWithResults"))
//				IR3J_GetTableWithresults()	
//			endif
//			if(stringmatch(ba.ctrlName,"DeleteOldResults"))
//				IR3J_DeleteExistingModelResults()	
//			endif
//			if(stringmatch(ba.ctrlName,"GetNotebookWithResults"))
//				IR1_CreateResultsNbk()
//			endif
			if(stringmatch(ba.ctrlName,"SelectAll"))
				Wave/Z SelectionOfAvailableData = root:Packages:Irena:AnalyzeResults:SelectionOfAvailableData
				if(WaveExists(SelectionOfAvailableData))
					SelectionOfAvailableData=1
				endif
			endif

			if(stringmatch(ba.ctrlName,"GetHelp"))
				IN2G_OpenWebManual("Irena/AnalyzeResults.html")				//fix me!!			
			endif

			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**************************************************************************************
//**************************************************************************************

Function IR3E_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	variable tempP
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
			NVAR DataQstart=root:Packages:Irena:AnalyzeResults:DataQstart
			NVAR DataQEnd=root:Packages:Irena:AnalyzeResults:DataQEnd
			NVAR DataQEndPoint = root:Packages:Irena:AnalyzeResults:DataQEndPoint
			NVAR DataQstartPoint = root:Packages:Irena:AnalyzeResults:DataQstartPoint
			
			if(stringmatch(sva.ctrlName,"DataQEnd"))
				WAVE OriginalXDataWave = root:Packages:Irena:AnalyzeResults:OriginalXDataWave
				tempP = BinarySearch(OriginalXDataWave, DataQEnd )
				if(tempP<1)
					print "Wrong Q value set, Data Q max must be at most 1 point before the end of Data"
					tempP = numpnts(OriginalXDataWave)-2
					DataQEnd = OriginalXDataWave[tempP]
				endif
				DataQEndPoint = tempP			
				IR3E_SyncCursorsTogether("OriginalYDataWave","B",tempP)
				IR3E_SyncCursorsTogether("LinModelDataIntWave","B",tempP)
			endif
			if(stringmatch(sva.ctrlName,"DataQstart"))
				WAVE OriginalXDataWave = root:Packages:Irena:AnalyzeResults:OriginalXDataWave
				tempP = BinarySearch(OriginalXDataWave, DataQstart )
				if(tempP<1)
					print "Wrong Q value set, Data Q min must be at least 1 point from the start of Data"
					tempP = 1
					DataQstart = OriginalXDataWave[tempP]
				endif
				DataQstartPoint=tempP
				IR3E_SyncCursorsTogether("OriginalYDataWave","A",tempP)
				IR3E_SyncCursorsTogether("LinModelDataIntWave","A",tempP)
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

Function IR3E_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(StringMatch(pa.ctrlName, "AnalysisMethodSelected" ))
				SVAR AnalysisMethodSelected = root:Packages:Irena:AnalyzeResults:AnalysisMethodSelected
				AnalysisMethodSelected = popStr
//				IR3J_SetupControlsOnMainpanel()
//				KillWaves/Z $("root:Packages:Irena:SimpleFits:ModelLogLogInt")
//				KillWaves/Z $("root:Packages:Irena:SimpleFits:ModelLogLogQ")
//				KillWIndow/Z IR3J_LinDataDisplay
				KillWindow/Z IR3E_MainDataDisplay
				IR3E_CreateAnalyzeResultsGraphs()
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


//**************************************************************************************
//**************************************************************************************
//**********************************************************************************************************

static Function IR3E_AnalyzeSequenceOfData()

		//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		//warn user if not saving results...
		NVAR SaveToNotebook=root:Packages:Irena:AnalyzeResults:SaveToNotebook
		NVAR SaveToWaves=root:Packages:Irena:AnalyzeResults:SaveToWaves
		NVAR SaveToFolder=root:Packages:Irena:AnalyzeResults:SaveToFolder
		NVAR DelayBetweenProcessing=root:Packages:Irena:AnalyzeResults:DelayBetweenProcessing
		if(SaveToNotebook+SaveToWaves+SaveToFolder<1)
			DoAlert /T="Results not being saved anywhere" 1, "Results of the analysis are not being saved anywhere. Do you want to continue (Yes) or abort (No)?"
			if(V_Flag==2)
				abort
			endif
		endif	
		if(SaveToFolder)
			print "Analysis results will be saved in original fits as Intensity and Q vector"
		endif
		if(SaveToWaves)
			print "Analysis results will be saved in waves to create a table"
		endif
		if(SaveToNotebook)
			print "Analysis results will be saved in notebook"
		endif
		Wave SelectionOfAvailableData = root:Packages:Irena:AnalyzeResults:SelectionOfAvailableData
		Wave/T ListOfAvailableData = root:Packages:Irena:AnalyzeResults:ListOfAvailableData
		variable i, imax
		imax = numpnts(ListOfAvailableData)
		For(i=0;i<imax;i+=1)
			if(SelectionOfAvailableData[i]>0.5)		//data set selected
				IR3E_CopyAndAppendData(ListOfAvailableData[i])
				IR3E_RecalculateAnalysis()
				IR3E_SaveResultsToNotebook()
				IR3E_SaveResultsToWaves()
				IR3E_SaveResultsToFolder()
				DoUpdate 
				sleep/S/C=6/M="Analyzed data for "+ListOfAvailableData[i] DelayBetweenProcessing
			endif
		endfor
		//IR3J_CleanUnusedParamWaves()
		print "all selected data processed"
end
//**********************************************************************************************************
//**************************************************************************************
Function IR3E_CopyAndAppendData(FolderNameStr)
	string FolderNameStr
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:AnalyzeResults					//go into the folder
		SVAR DataStartFolder=root:Packages:Irena:AnalyzeResults:DataStartFolder
		SVAR DataFolderName=root:Packages:Irena:AnalyzeResults:DataFolderName
		NVAR  UseResults=  root:Packages:Irena:AnalyzeResults:UseResults
		NVAR  UseUserDefinedData=  root:Packages:Irena:AnalyzeResults:UseUserDefinedData
		NVAR  UseModelData = root:Packages:Irena:AnalyzeResults:UseModelData
		SVAR YDataWaveName=root:Packages:Irena:AnalyzeResults:IntensityWaveName
		SVAR XDataWaveName=root:Packages:Irena:AnalyzeResults:QWavename
		SVAR ErrorWaveName=root:Packages:Irena:AnalyzeResults:ErrorWaveName
		SVAR dXDataWaveName=root:Packages:Irena:AnalyzeResults:dXDataWaveName
		NVAR UseIndra2Data=root:Packages:Irena:AnalyzeResults:UseIndra2Data
		NVAR UseQRSdata=root:Packages:Irena:AnalyzeResults:UseQRSdata
		//these are variables used by the control procedure
		UseUserDefinedData = 0
		UseModelData = 0
		//get the names of waves, assume this tool actually works. May not under some conditions. In that case this tool will not work. 
		IR3C_SelectWaveNamesData("Irena:AnalyzeResults", FolderNameStr)			//this routine will preset names in strings as needed,		
		Wave/Z SourceIntWv=$(DataFolderName+possiblyQUoteName(YDataWaveName))
		Wave/Z SourceQWv=$(DataFolderName+possiblyQUoteName(XDataWaveName))
		Wave/Z SourceErrorWv=$(DataFolderName+possiblyQUoteName(ErrorWaveName))
		Wave/Z SourcedQWv=$(DataFolderName+possiblyQUoteName(dXDataWaveName))
		if(!WaveExists(SourceIntWv) &&	!WaveExists(SourceQWv) && UseIndra2Data)		//may be we heve M_... data here?
			Wave/Z SourceIntWv=$(DataFolderName+possiblyQUoteName("M_"+YDataWaveName))
			Wave/Z SourceQWv=$(DataFolderName+possiblyQUoteName("M_"+XDataWaveName))
			Wave/Z SourceErrorWv=$(DataFolderName+possiblyQUoteName("M_"+ErrorWaveName))
			Wave/Z SourcedQWv=$(DataFolderName+possiblyQUoteName("M_"+dXDataWaveName))
		endif
		if(!WaveExists(SourceIntWv)||	!WaveExists(SourceQWv))//||!WaveExists(SourceErrorWv))
			Abort "Data selection failed for Data in Simple/basic fits routine IR3E_CopyAndAppendData"
		endif
		Duplicate/O SourceIntWv, OriginalYDataWave
		Duplicate/O SourceQWv, OriginalXDataWave
		if(WaveExists(SourceErrorWv))
			Duplicate/O SourceErrorWv, OriginalDataErrorWave
		else
			Duplicate/O SourceIntWv, OriginalDataErrorWave
			OriginalDataErrorWave *= 0.02
		endif
		if(WaveExists(SourcedQWv))
			Duplicate/O SourcedQWv, OriginalDatadQWave
		else
			dXDataWaveName=""
		endif
		IR3E_CreateAnalyzeResultsGraphs()
		//clear obsolete data:
//		Wave/Z NormRes1=root:Packages:Irena:SimpleFits:NormalizedResidualLinLin
//		Wave/Z NormRes2=root:Packages:Irena:SimpleFits:NormalizedResidualLogLog
//		if(WaveExists(NormRes1))
//			NormRes1=0
//		endif
//		if(WaveExists(NormRes2))
//			NormRes2=0
//		endif
//		//done cleaning... 
//		DoWIndow IR3E_MainDataDisplay
//		if(V_Flag)
//			RemoveFromGraph /W=IR3J_LogLogDataDisplay /Z NormalizedResidualLogLog
//			DoWIndow/F IR3J_LogLogDataDisplay
//		endif
//		DoWIndow IR3J_LinDataDisplay
//		if(V_Flag)
//			RemoveFromGraph /W=IR3J_LinDataDisplay /Z NormalizedResidualLinLin
//			DoWIndow/F IR3J_LinDataDisplay
//		endif
		pauseUpdate
		IR3E_AppendDataToGraph()
//		//now this deals with linearized data, if needed...
//		IR3J_CreateLinearizedData()
//		IR3J_AppendDataToGraphModel()
		DoUpdate
		print "Added Data from folder : "+DataFolderName
	SetDataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


Function IR3E_AppendDataToGraph()
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IR3E_CreateAnalyzeResultsGraphs()
	variable WhichLegend=0
	string Shortname1
	Wave OriginalYDataWave=root:Packages:Irena:AnalyzeResults:OriginalYDataWave
	Wave OriginalXDataWave=root:Packages:Irena:AnalyzeResults:OriginalXDataWave
	Wave OriginalDataErrorWave=root:Packages:Irena:AnalyzeResults:OriginalDataErrorWave
	CheckDisplayed /W=IR3E_MainDataDisplay OriginalYDataWave
	if(!V_flag)
		AppendToGraph /W=IR3E_MainDataDisplay  OriginalYDataWave  vs OriginalXDataWave
		//ModifyGraph /W=IR3E_MainDataDisplay log=1, mirror(bottom)=1
		ModifyGraph /W=IR3E_MainDataDisplay  mirror(bottom)=1
		Label /W=IR3E_MainDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity"
		Label /W=IR3E_MainDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q[A\\S-1\\M"+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
		ErrorBars /W=IR3E_MainDataDisplay OriginalYDataWave Y,wave=(OriginalDataErrorWave,OriginalDataErrorWave)		
	endif
	// for "Size Distribution" use linear left axis.  
	//SVAR SimpleModel = root:Packages:Irena:AnalyzeResults:SimpleModel
		//	if(StringMatch(SimpleModel, "*size distribution"))
		//				ModifyGraph /W=IR3E_MainDataDisplay log(left)=0, mirror=1
		//	endif
	
	NVAR DataQEnd = root:Packages:Irena:AnalyzeResults:DataQEnd
	NVAR DataQstart = root:Packages:Irena:AnalyzeResults:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:AnalyzeResults:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:AnalyzeResults:DataQstartPoint
	if(DataQstart>0)	 		//old Q min already set.
		DataQstartPoint = BinarySearch(OriginalXDataWave, DataQstart)
	endif
	if(DataQstartPoint<1)	//Qmin not set or not found. Set to point 2 on that wave. 
		DataQstart = OriginalXDataWave[1]
		DataQstartPoint = 1
	endif
	if(DataQEnd>0)	 		//old Q max already set.
		DataQEndPoint = BinarySearch(OriginalXDataWave, DataQEnd)
	endif
	if(DataQEndPoint<1)	//Qmax not set or not found. Set to last point-1 on that wave. 
		DataQEnd = OriginalXDataWave[numpnts(OriginalXDataWave)-2]
		DataQEndPoint = numpnts(OriginalXDataWave)-2
	endif
	SetWindow IR3E_MainDataDisplay, hook(DM3LogCursorMoved) = $""
	cursor /W=IR3E_MainDataDisplay B, OriginalYDataWave, DataQEndPoint
	cursor /W=IR3E_MainDataDisplay A, OriginalYDataWave, DataQstartPoint
	SetWindow IR3E_MainDataDisplay, hook(AnalyzeResultsLogCursorMoved) = IR3E_GraphWindowHook

	SVAR DataFolderName=root:Packages:Irena:AnalyzeResults:DataFolderName
	Shortname1 = StringFromList(ItemsInList(DataFolderName, ":")-1, DataFolderName  ,":")
	Legend/W=IR3E_MainDataDisplay /C/N=text0/J/A=LB "\\s(OriginalYDataWave) "+Shortname1

	
end
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3E_GraphWindowHook(s)
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
			IR3E_SyncCursorsTogether(s.traceName,s.cursorName,s.pointNumber)
			hookResult = 1
		// And so on . . .
	endswitch

	return hookResult	// 0 if nothing done, else 1
End
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3E_SyncCursorsTogether(traceName,CursorName,PointNumber)
	string traceName,CursorName
	variable PointNumber

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IR3E_CreateAnalyzeResultsGraphs()
	NVAR DataQEnd = root:Packages:Irena:AnalyzeResults:DataQEnd
	NVAR DataQstart = root:Packages:Irena:AnalyzeResults:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:AnalyzeResults:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:AnalyzeResults:DataQstartPoint
	Wave OriginalXDataWave=root:Packages:Irena:AnalyzeResults:OriginalXDataWave
	Wave OriginalYDataWave=root:Packages:Irena:AnalyzeResults:OriginalYDataWave
		variable tempMaxQ, tempMaxQY, tempMinQY, maxY, minY
	//check if user removed cursor from graph, in which case do nothing for now...
	if(numtype(PointNumber)==0)
		if(stringmatch(CursorName,"A"))		//moved cursor A, which is start of Q range
			DataQstartPoint = PointNumber
			DataQstart = OriginalXDataWave[PointNumber]
		endif
		if(stringmatch(CursorName,"B"))		//moved cursor B, which is end of Q range
			DataQEndPoint = PointNumber
			DataQEnd = OriginalXDataWave[PointNumber]
		endif
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3E_CreateAnalyzeResultsGraphs()
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable exists1=0
	DoWIndow IR3E_MainDataDisplay
	if(V_Flag)
		DoWIndow/hide=? IR3E_MainDataDisplay
		if(V_Flag==2)
			DoWIndow/F IR3E_MainDataDisplay
		endif
	else
		Display /W=(521,10,1383,750)/K=1 /N=IR3E_MainDataDisplay
		ShowInfo/W=IR3E_MainDataDisplay
		exists1=1
	endif
	AutoPositionWindow/M=0/R=IR3E_AnalyzeResultsPanel IR3E_MainDataDisplay	
end

//**********************************************************************************************************
//**********************************************************************************************************

//**********************************************************************************************************
//**********************************************************************************************************

Function IR3E_InitAnalyzeResults()	


	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()
	string ListOfVariables
	string ListOfStrings
	variable i
		
	if (!DataFolderExists("root:Packages:Irena:AnalyzeResults"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena
		NewDataFolder/O root:Packages:Irena:AnalyzeResults
	endif
	SetDataFolder root:Packages:Irena:AnalyzeResults					//go into the folder

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dXDataWaveName;DataUnits;"
	ListOfStrings+="DataStartFolder;DataMatchString;FolderSortString;FolderSortStringAll;"
	ListOfStrings+="UserMessageString;SavedDataMessage;"
	ListOfStrings+="AnalysisMethodSelected;ListOfAnalysisMethods;"

	string/g SDListOfVariables
	ListOfVariables		="DataQEnd;DataQStart;DataQEndPoint;DataQstartPoint;ScatteringContrast;SaveToNotebook;SaveToFolder;SaveToWaves;DelayBetweenProcessing;"
	//these are SizeDistribution 
	SDListOfVariables 	="SDVolumeInRange;SDNumberDensity;SDSpecSurfaceArea;SDMean;SDMode;SDMedian;SDFWHM;SDRg;"
	SDListOfVariables  +="SDMIPsigma;SDMIPcosTheta;SDMIPCreateCurves;SDCreateCumulativeCurves;InvertCumulativeDists;"
	//
	ListOfVariables = ListOfVariables+SDListOfVariables
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dXDataWaveName;"
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
	SVAR ListOfAnalysisMethods
	ListOfAnalysisMethods="SizeDistribution;"
	SVAR AnalysisMethodSelected
	if(strlen(AnalysisMethodSelected)<1)
		AnalysisMethodSelected="SizeDistribution"
	endif
	//set SD default parameters:
	NVAR SDMIPsigma
	NVAR SDMIPcosTheta
	SDMIPsigma = 485
	SDMIPcosTheta = -0.7660
	NVAR DelayBetweenProcessing
	if(DelayBetweenProcessing<0.5)
		DelayBetweenProcessing = 2
	endif
	
	Make/O/T/N=(0) ListOfAvailableData
	Make/O/N=(0) SelectionOfAvailableData
	SetDataFolder oldDf

end
//**************************************************************************************
//**********************************************************************************************************
////**********************************************************************************************************
////**********************************************************************************************************
Function IR3E_RecalculateAnalysis()
	
	SVAR AnalysisMethodSelected = root:Packages:Irena:AnalyzeResults:AnalysisMethodSelected
	SVAR XwvName = root:Packages:Irena:AnalyzeResults:QWavename
	SVAR YwvName = root:Packages:Irena:AnalyzeResults:IntensityWaveName
	Wave/Z DistributionWV	 = root:Packages:Irena:AnalyzeResults:OriginalYDataWave
	Wave/Z DimensionWV		 = root:Packages:Irena:AnalyzeResults:OriginalXDataWave
	if(WaveExists(DistributionWV)&&WaveExists(DimensionWV)&& strlen(XwvName)>0 && strlen(YwvName)>0)
		//input data exist... 
		if(stringMatch(AnalysisMethodSelected,"SizeDistribution"))
			IR3E_SDCalculateStatistics()
		endif
	else
		IR3E_NaNAnalysisValues()
		DoAlert 0, "Data not selected correctly, model cannot be calculated & values resent to NaN."
	endif
end
////**********************************************************************************************************
////**********************************************************************************************************

Function IR3E_NaNAnalysisValues()

	//this is for Size Distribution
		//these are values we want... 
	NVAR SDVolumeInRange 	= root:Packages:Irena:AnalyzeResults:SDVolumeInRange
	NVAR SDNumberDensity 	= root:Packages:Irena:AnalyzeResults:SDNumberDensity
	NVAR SDSpecSurfaceArea 	= root:Packages:Irena:AnalyzeResults:SDSpecSurfaceArea
	NVAR SDMean 			= root:Packages:Irena:AnalyzeResults:SDMean
	NVAR SDMode 			= root:Packages:Irena:AnalyzeResults:SDMode
	NVAR SDMedian 			= root:Packages:Irena:AnalyzeResults:SDMedian
	NVAR SDFWHM 			= root:Packages:Irena:AnalyzeResults:SDFWHM
	SDVolumeInRange = NaN
	SDNumberDensity = NaN
	SDSpecSurfaceArea = NaN
	SDMean = NaN
	SDMode = NaN
	SDMedian = NaN
	SDFWHM = NaN
end
//**********************************************************************************************************
 Function IR3E_SaveResultsToNotebook()

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR SaveToNotebook=root:Packages:Irena:AnalyzeResults:SaveToNotebook
	NVAR SaveToWaves=root:Packages:Irena:AnalyzeResults:SaveToWaves
	NVAR SaveToFolder=root:Packages:Irena:AnalyzeResults:SaveToFolder
	if(!SaveToNotebook)
		return 0
	endif	
	IR1_CreateResultsNbk()
	DFref oldDf= GetDataFolderDFR()	
	SetDataFolder root:Packages:Irena:AnalyzeResults								//go into the folder
	SVAR  DataFolderName=root:Packages:Irena:AnalyzeResults:DataFolderName
	SVAR  IntensityWaveName=root:Packages:Irena:AnalyzeResults:IntensityWaveName
	SVAR  QWavename=root:Packages:Irena:AnalyzeResults:QWavename
	SVAR  ErrorWaveName=root:Packages:Irena:AnalyzeResults:ErrorWaveName
	SVAR  AnalysisMethodSelected = root:Packages:Irena:AnalyzeResults:AnalysisMethodSelected

	NVAR DataQEnd = root:Packages:Irena:AnalyzeResults:DataQEnd
	NVAR DataQstart = root:Packages:Irena:AnalyzeResults:DataQstart
	NVAR SDVolumeInRange 	= root:Packages:Irena:AnalyzeResults:SDVolumeInRange
	NVAR SDNumberDensity 	= root:Packages:Irena:AnalyzeResults:SDNumberDensity
	NVAR SDSpecSurfaceArea 	= root:Packages:Irena:AnalyzeResults:SDSpecSurfaceArea
	NVAR SDMean 			= root:Packages:Irena:AnalyzeResults:SDMean
	NVAR SDMode 			= root:Packages:Irena:AnalyzeResults:SDMode
	NVAR SDMedian 			= root:Packages:Irena:AnalyzeResults:SDMedian
	NVAR SDFWHM 			= root:Packages:Irena:AnalyzeResults:SDFWHM
	NVAR Rg = root:Packages:Irena:AnalyzeResults:SDRg

	Wave DistributionWV	 = root:Packages:Irena:AnalyzeResults:OriginalYDataWave
	Wave DimensionWV		 = root:Packages:Irena:AnalyzeResults:OriginalXDataWave

	IR1_AppendAnyText("\r Results of "+AnalysisMethodSelected+" Analysis of results\r",1)	
	IR1_AppendAnyText("Date & time: \t"+Date()+"   "+time(),0)	
	IR1_AppendAnyText("Data from folder: \t"+DataFolderName,0)	
	if(stringmatch(AnalysisMethodSelected,"SizeDistribution"))
		IR1_AppendAnyText("Intensity: \t"+IntensityWaveName,0)	
		IR1_AppendAnyText("Q: \t"+QWavename,0)	
		//IR1_AppendAnyText("Error: \t"+ErrorWaveName,0)	
		IR1_AppendAnyText(" ",0)	
		IR1_AppendAnyText("\tVolume fraction                  = "+num2str(SDVolumeInRange),0)
		IR1_AppendAnyText("\tNumber density [1/cm]            = "+num2str(SDNumberDensity),0)
		IR1_AppendAnyText("\tSpecific Surf. area [cm2/cm3]    = "+num2str(SDSpecSurfaceArea),0)
		IR1_AppendAnyText("\tMean [A]			            = "+num2str(SDMean),0)
		IR1_AppendAnyText("\tMode [A]			            = "+num2str(SDMode),0)
		IR1_AppendAnyText("\tMedian [A]			            = "+num2str(SDMedian),0)
		IR1_AppendAnyText("\tFWHM  [A]			            = "+num2str(SDFWHM),0)
		IR1_AppendAnyText("\tRg  [A]			            = "+num2str(Rg),0)
	//elseif(stringmatch(SimpleModel,"Guinier Rod"))
		//IR1_AppendAnyText("\tRc                  = "+num2str(Guinier_Rg),0)
		//IR1_AppendAnyText("\tI0                  = "+num2str(Guinier_I0),0)
	endif

	IR1_AppendAnyText("Min size = "+num2str(DataQstart),0)
	IR1_AppendAnyText("Max Size = "+num2str(DataQEnd),0)
	IR1_AppendAnyGraph("IR3E_MainDataDisplay")
	DOWIndow AnalyseSDMIPDataGraph
	if(V_Flag)
		IR1_AppendAnyGraph("AnalyseSDMIPDataGraph")
	endif
	IR1_AppendAnyText("******************************************\r",0)	
	SetDataFolder OldDf
	SVAR/Z nbl=root:Packages:Irena:ResultsNotebookName	
	DoWindow/F $nbl
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3E_SaveResultsToFolder()
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()	
	SetDataFolder root:Packages:Irena:AnalyzeResults								//go into the folder
	NVAR SaveToNotebook=root:Packages:Irena:AnalyzeResults:SaveToNotebook
	NVAR SaveToWaves=root:Packages:Irena:AnalyzeResults:SaveToWaves
	NVAR SaveToFolder=root:Packages:Irena:AnalyzeResults:SaveToFolder
	if(!SaveToFolder)
		return 0
	endif	
	SVAR  DataFolderName=root:Packages:Irena:AnalyzeResults:DataFolderName
	SVAR  IntensityWaveName=root:Packages:Irena:AnalyzeResults:IntensityWaveName
	SVAR  QWavename=root:Packages:Irena:AnalyzeResults:QWavename
	SVAR  ErrorWaveName=root:Packages:Irena:AnalyzeResults:ErrorWaveName
	NVAR DataQEnd = root:Packages:Irena:AnalyzeResults:DataQEnd
	NVAR DataQstart = root:Packages:Irena:AnalyzeResults:DataQstart
	NVAR SDVolumeInRange 	= root:Packages:Irena:AnalyzeResults:SDVolumeInRange
	NVAR SDNumberDensity 	= root:Packages:Irena:AnalyzeResults:SDNumberDensity
	NVAR SDSpecSurfaceArea 	= root:Packages:Irena:AnalyzeResults:SDSpecSurfaceArea
	NVAR SDMean 			= root:Packages:Irena:AnalyzeResults:SDMean
	NVAR SDMode 			= root:Packages:Irena:AnalyzeResults:SDMode
	NVAR SDMedian 			= root:Packages:Irena:AnalyzeResults:SDMedian
	NVAR SDFWHM 			= root:Packages:Irena:AnalyzeResults:SDFWHM
	NVAR Rg 				= root:Packages:Irena:AnalyzeResults:SDRg
	Wave DistributionWV	 = root:Packages:Irena:AnalyzeResults:OriginalYDataWave
	Wave DimensionWV		 = root:Packages:Irena:AnalyzeResults:OriginalXDataWave
	SVAR  AnalysisMethodSelected = root:Packages:Irena:AnalyzeResults:AnalysisMethodSelected

	Wave/Z CumulativeSizeDist=root:Packages:Irena:AnalyzeResults:CumulativeSizeDist
	Wave/Z CumulativeSfcArea=root:Packages:Irena:AnalyzeResults:CumulativeSfcArea
	Wave/Z CumulativeDistDiameters=root:Packages:Irena:AnalyzeResults:CumulativeDistDiameters

	Wave/Z MIPPressure=root:Packages:Irena:AnalyzeResults:MIPPressure
	Wave/Z MIPVolume=root:Packages:Irena:AnalyzeResults:MIPVolume

	string IntrCrvNote
	variable LocOfUnd
	variable IndxOfData
	string NewIntrCrvName
	string NewSfcCrvName
	string NewDiaWvName
	//others can be created via Simple polots as needed... 
	If(!WaveExists(CumulativeSizeDist) ||!WaveExists(CumulativeSfcArea) || !WaveExists(CumulativeDistDiameters))
		print "Cannot save Cumulative data, they do not exist"	
	else
		IntrCrvNote=note(CumulativeSizeDist)
		//Wave OrigData = $(stringByKey("Cumulative Source Data",IntrCrvNote,"=",";"))
		LocOfUnd=strsearch(IntensityWaveName,"_",strlen(IntensityWaveName),3)+1
		IndxOfData=str2num(IntensityWaveName[LocOfUnd,inf])	
		SetDataFolder DataFolderName
		NewIntrCrvName= "CumulativeSizeDist_"+num2str(IndxOfData)
		NewSfcCrvName="CumulativeSfcArea_"+num2str(IndxOfData)
		NewDiaWvName="CumulativeDistDiameters_"+num2str(IndxOfData)
		if(checkName ("CumulativeSizeDist_"+num2str(IndxOfData),1)!=0)
			NewIntrCrvName= UniqueName("CumulativeSizeDist_"+num2str(IndxOfData),1,0)
			NewSfcCrvName="CumulativeSfcArea_"+NewIntrCrvName[14,inf]
			NewDiaWvName="CumulativeDistDiameters"+NewIntrCrvName[14,inf]
			DoALert 0, "Note that existing index of the result was already used, the data stored with increased index. See message in history area"
		endif
		
		Duplicate/O CumulativeSizeDist, $(NewIntrCrvName)
		Duplicate/O CumulativeSfcArea, $(NewSfcCrvName)
		Duplicate/O CumulativeDistDiameters, $(NewDiaWvName)
		print "Saved Cumulative data to     " + NewIntrCrvName +"     /     " + NewSfcCrvName +"     /     " +NewDiaWvName +"    in folder    "+DataFolderName
	endif
	if(!WaveExists(MIPPressure)||!WaveExists(MIPVolume))
		print "Cannot save MIP data, they do not exist"	
	else
		IntrCrvNote=note(MIPVolume)
		LocOfUnd=strsearch(IntensityWaveName,"_",strlen(IntensityWaveName),3)+1
		IndxOfData=str2num(IntensityWaveName[LocOfUnd,inf])		
		SetDataFolder DataFolderName
		NewIntrCrvName= "MIPVolume_"+num2str(IndxOfData)
		NewDiaWvName="MIPPressure_"+num2str(IndxOfData)
		if(checkName ("MIPVolume_"+num2str(IndxOfData),1)!=0)
			NewIntrCrvName= UniqueName("MIPVolume_"+num2str(IndxOfData),1,0)
			NewDiaWvName="MIPPressure_"+NewIntrCrvName[10,inf]
			DoALert 0, "Note that existing index of the result was already used, the data stored with increased index. See message in history area"
		endif
		
		Duplicate/O MIPVolume, $(NewIntrCrvName)
		Duplicate/O MIPPressure, $(NewDiaWvName)
		print "Saved MIP data to     " + NewIntrCrvName +"     /     " + NewDiaWvName +"    in folder    "+DataFolderName
	endif

	setDataFolder OldDf	
end
//*****************************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR3E_SaveResultsToWaves()
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()	
	NVAR SaveToNotebook=root:Packages:Irena:AnalyzeResults:SaveToNotebook
	NVAR SaveToWaves=root:Packages:Irena:AnalyzeResults:SaveToWaves
	NVAR SaveToFolder=root:Packages:Irena:AnalyzeResults:SaveToFolder
	if(!SaveToWaves)
		return 0
	endif
	SetDataFolder root:Packages:Irena:AnalyzeResults								//go into the folder
	SVAR  DataFolderName=root:Packages:Irena:AnalyzeResults:DataFolderName
	SVAR  IntensityWaveName=root:Packages:Irena:AnalyzeResults:IntensityWaveName
	SVAR  QWavename=root:Packages:Irena:AnalyzeResults:QWavename
	SVAR  ErrorWaveName=root:Packages:Irena:AnalyzeResults:ErrorWaveName
	NVAR DataQEnd = root:Packages:Irena:AnalyzeResults:DataQEnd
	NVAR DataQstart = root:Packages:Irena:AnalyzeResults:DataQstart
	NVAR SDVolumeInRange 	= root:Packages:Irena:AnalyzeResults:SDVolumeInRange
	NVAR SDNumberDensity 	= root:Packages:Irena:AnalyzeResults:SDNumberDensity
	NVAR SDSpecSurfaceArea 	= root:Packages:Irena:AnalyzeResults:SDSpecSurfaceArea
	NVAR SDMean 			= root:Packages:Irena:AnalyzeResults:SDMean
	NVAR SDMode 			= root:Packages:Irena:AnalyzeResults:SDMode
	NVAR SDMedian 			= root:Packages:Irena:AnalyzeResults:SDMedian
	NVAR SDFWHM 			= root:Packages:Irena:AnalyzeResults:SDFWHM
	NVAR RgVal = root:Packages:Irena:AnalyzeResults:SDRg
	Wave DistributionWV	 = root:Packages:Irena:AnalyzeResults:OriginalYDataWave
	Wave DimensionWV		 = root:Packages:Irena:AnalyzeResults:OriginalXDataWave
	
	SVAR  AnalysisMethodSelected = root:Packages:Irena:AnalyzeResults:AnalysisMethodSelected

	variable curlength
	if(stringmatch(AnalysisMethodSelected,"SizeDistribution"))
		//tabulate data for Guinier
		NewDATAFolder/O/S root:ResultsAnalysisSizeDist
		Wave/Z VolumeFraction
		if(!WaveExists(VolumeFraction))
			make/O/N=0 VolumeFraction, NumberDensity,SpecificSurfaceArea,MeanWv,ModeWv,MeadianWV,FWHM,Rg, TimeWave, TemperatureWave, PercentWave, OrderWave, MinSize, MaxSize
			make/O/N=0/T SampleName
			SetScale/P x 0,1,"A", MinSize, MaxSize, MeanWv,ModeWv,MeadianWV,FWHM, Rg
			SetScale/P x 0,1,"min", TimeWave
			SetScale/P x 0,1,"C", TemperatureWave
			SetScale/P x 0,1,"1/cm3", NumberDensity
			SetScale/P x 0,1,"cm2/cm3", SpecificSurfaceArea			
		endif
		curlength = numpnts(VolumeFraction)
		redimension/N=(curlength+1) SampleName,VolumeFraction, NumberDensity,SpecificSurfaceArea,MeanWv,ModeWv,MeadianWV,FWHM,Rg, TimeWave, TemperatureWave, PercentWave, OrderWave, MinSize, MaxSize 
		SampleName[curlength] = DataFolderName
		TimeWave[curlength]				=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzmin")
		TemperatureWave[curlength]  	=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzC")
		PercentWave[curlength] 			=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzpct")
		OrderWave[curlength]			= 	IN2G_IdentifyNameComponent(DataFolderName, "_xyz")
		VolumeFraction[curlength] 		= SDVolumeInRange
		NumberDensity[curlength] 		= SDNumberDensity
		SpecificSurfaceArea[curlength] 	= SDSpecSurfaceArea
		MeanWv[curlength] 				= SDMean
		ModeWv[curlength] 				= SDMode
		MeadianWV[curlength] 			= SDMedian
		FWHM[curlength] 				= SDFWHM
		Rg[curlength] 					= RgVal
		MinSize[curlength] 				= DataQstart
		MaxSize[curlength] 				= DataQEnd
		IR3E_ResAnalSizeDistResultsTableFnct()
//	elseif(stringmatch(SimpleModel,"Invariant"))
//		//tabulate data for Invariant
//		NewDATAFolder/O/S root:InvariantFitResults
//		Wave/Z InvariantWV
//		if(!WaveExists(InvariantWV))
//			make/O/N=0 InvariantWV, InvariantQmax, TimeWave, TemperatureWave, PercentWave, OrderWave
//			make/O/N=0/T SampleName
//			SetScale/P x 0,1,"(mol e-^2/cm^3)^3", InvariantWV
//			SetScale/P x 0,1,"1/A", InvariantQmax
//		endif
//		curlength = numpnts(InvariantWV)
//		redimension/N=(curlength+1) SampleName, InvariantWV, InvariantQmax, TimeWave, TemperatureWave, PercentWave, OrderWave 
//		SampleName[curlength] = DataFolderName
//		TimeWave[curlength]				=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzmin")
//		TemperatureWave[curlength]  	=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzC")
//		PercentWave[curlength] 			=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzpct")
//		OrderWave[curlength]				= 	IN2G_IdentifyNameComponent(DataFolderName, "_xyz")
//		InvariantWV[curlength] = Invariant
//		InvariantQmax[curlength] = InvQmaxUsed
//		IR3J_GetTableWithresults()

	endif
	setDataFolder OldDf	
	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3E_ResAnalSizeDistResultsTableFnct() : Table
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DoWIndow IR3E_ResAnalSizeDistResultsTable
	if(V_Flag)
		DoWIndow/F IR3E_ResAnalSizeDistResultsTable 
	else
		PauseUpdate    		// building window...	
		DFref oldDf= GetDataFolderDFR()	
		if(!DataFolderExists("root:ResultsAnalysisSizeDist:"))
			Abort "No Analysis of results - Size Distribution data exist."
		endif
		SetDataFolder root:ResultsAnalysisSizeDist:
		Wave/T SampleName
		Wave VolumeFraction,NumberDensity,SpecificSurfaceArea, ModeWv,MeanWv,MeadianWV,MinSize,MaxSize,FWHM,Rg, OrderWave,PercentWave, TemperatureWave,TimeWave
		Edit/K=1/W=(329,500,1721,957)/N=IR3E_ResAnalSizeDistResultsTable  SampleName,VolumeFraction,NumberDensity,SpecificSurfaceArea as "Analysis of Size Distribution results"
		AppendToTable ModeWv,MeanWv,MeadianWV,MinSize,MaxSize,FWHM,Rg,OrderWave,PercentWave
		AppendToTable TemperatureWave,TimeWave
		ModifyTable format(Point)=1,width(SampleName)=188,title(SampleName)="Data Folder"
		ModifyTable width(VolumeFraction)=106,title(VolumeFraction)="Vol. Fraction",width(NumberDensity)=92
		ModifyTable title(NumberDensity)="Num. Dens [1/A]",width(SpecificSurfaceArea)=96
		ModifyTable title(SpecificSurfaceArea)="Spec Sfc Area [cm2/cm3]",title(ModeWv)="Mode [A]"
		ModifyTable title(MeanWv)="Mean [A]",title(MeadianWV)="Meadian [A]",title(MinSize)="Min [A]"
		ModifyTable title(MaxSize)="Max [A]",title(FWHM)="FWHM [A]",title(Rg)="Rg [A]",title(OrderWave)="Order"
		ModifyTable title(PercentWave)="%",title(TemperatureWave)="Temp. [C]",title(TimeWave)="Time [min]"
		SetDataFolder oldDf
	endif
EndMacro

//**************************************************************************************
//**************************************************************************************
//  Size distribution specific functions


////**********************************************************************************************************
////**********************************************************************************************************

Function IR3E_SDCalculateStatistics()
	
	//for size distribution, calculate statistics... 
	Wave DistributionWV	 = root:Packages:Irena:AnalyzeResults:OriginalYDataWave
	Wave DimensionWV		 = root:Packages:Irena:AnalyzeResults:OriginalXDataWave
	NVAR EndSize 		= root:Packages:Irena:AnalyzeResults:DataQEnd
	NVAR StartSize 		= root:Packages:Irena:AnalyzeResults:DataQStart
	NVAR EndPnt 		= root:Packages:Irena:AnalyzeResults:DataQEndPoint
	NVAR StartPnt 		= root:Packages:Irena:AnalyzeResults:DataQstartPoint
	//these are values we want... 
	NVAR SDVolumeInRange 	= root:Packages:Irena:AnalyzeResults:SDVolumeInRange
	NVAR SDNumberDensity 	= root:Packages:Irena:AnalyzeResults:SDNumberDensity
	NVAR SDSpecSurfaceArea 	= root:Packages:Irena:AnalyzeResults:SDSpecSurfaceArea
	NVAR SDMean 			= root:Packages:Irena:AnalyzeResults:SDMean
	NVAR SDMode 			= root:Packages:Irena:AnalyzeResults:SDMode
	NVAR SDMedian 			= root:Packages:Irena:AnalyzeResults:SDMedian
	NVAR SDFWHM 			= root:Packages:Irena:AnalyzeResults:SDFWHM
	NVAR Rg = root:Packages:Irena:AnalyzeResults:SDRg
	
	SVAR XwvName = root:Packages:Irena:AnalyzeResults:QWavename
	SVAR YwvName = root:Packages:Irena:AnalyzeResults:IntensityWaveName

	variable popNumber=str2num(YwvName[strsearch(YwvName, "pop", 0)+3])
	
	//	wave w = CsrWaveRef(A,"IR1G_OneSampleEvaluationGraph" )
	//	string curNote = note(w)
	//	GR1_NumberOrVolumeDist=stringByKey("SizesDataFrom", curNote,"=",";")+CsrAwaveName
	Duplicate/Free/R=[StartPnt,EndPnt] DistributionWV, DistShort, DistShort2, DistDimShort, ParticleVolumes, ParticleSurface
	Duplicate/Free/R=[StartPnt,EndPnt] DimensionWV, DimensionShort, DimensionShort2
	//Rg calcualtion
	if(stringmatch(YwvName,"*Volume*") || stringmatch(YwvName,"*VolDist*"))
		Rg=IR2L_CalculateRg(DimensionShort,DistShort,1)		//Dimension is diameter, 3rd parameter is 1
		if(stringmatch(XwvName,"*Radi*") )
			Rg*=2							//convert radius calcaulted Rg to diameter calculated as needed.  
		endif
	endif
	if (stringmatch(YwvName,"*Number*") || stringmatch(YwvName,"*NumDist*"))
		IR1G_CreateAveVolSfcWvUsingNote(ParticleVolumes,DimensionShort,Note(ParticleVolumes),"Volume", popNumber)
		DistShort2 = DistShort * ParticleVolumes				//this is volume distribution
		Rg=IR2L_CalculateRg(DimensionShort,DistShort2,1)		//Dimension is diameter, 3rd parameter is 1
		if(stringmatch(XwvName,"*Radi*") )
			Rg*=2							//convert radius calcaulted Rg to diameter calculated as needed.  
		endif
	endif
	//ednf of Rg calculation. 
	DistDimShort = DistShort*DimensionShort
	//	GR1_Mean=IR1G_CalculateMean(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B))
	SDMean = areaXY(DimensionShort, DistDimShort,0,inf)/areaXY(DimensionShort, DistShort,0,inf)		//Sum P(R)*R*deltaR
	//	GR1_Mode=IR1G_CalculateMode(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B))
	duplicate/O DistShort, root:DistShort
	duplicate/O DimensionShort, root:DimensionShort
	FindPeak/P/Q DistShort
	if (V_Flag)		//peak not found
		SDMode=NaN
	else
		//print DimensionShort[13]
		//print DimensionShort[14]
		//print DimensionShort[13.9434755694068]
		//print DimensionShort[V_PeakLoc]
		//SDMode=DimensionShort[V_PeakLoc]								//location of maximum on the P(R)
		SDMode=DimensionShort[0.01*round(V_PeakLoc*100)]								//location of maximum on the P(R)
	endif
	//	GR1_Median=IR1G_CalculateMedian(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B))
	IN2G_IntegrateXY(DimensionShort, DistShort2)
	WaveStats/Q DistShort2
	SDMedian=DimensionShort[BinarySearchInterp(DistShort2, 0.5*V_max)]		//R for which cumulative probability=0.5
	


	//	GR1_Volume=IR1G_CalculateVolume(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B), CsrAwaveName)
	if(stringmatch(YwvName,"*Volume*") || stringmatch(YwvName,"*VolDist*"))
		//this is easy, just integrate
		SDVolumeInRange=areaXY(DimensionShort, DistShort, 0, inf)
	endif
	if (stringmatch(YwvName,"*Number*") || stringmatch(YwvName,"*NumDist*"))
		IR1G_CreateAveVolSfcWvUsingNote(ParticleVolumes,DimensionShort,Note(ParticleVolumes),"Volume", popNumber)
		DistShort2 = DistShort * ParticleVolumes				//this is volume distribution
		SDVolumeInRange=areaXY(DimensionShort, DistShort2, 0, inf)
	endif
	//	GR1_NumberDens=IR1G_CalculateNumber(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B), CsrAwaveName)
	if (stringmatch(YwvName,"*Number*") || stringmatch(YwvName,"*NumDist*"))
		//this is easy, just integrate
		SDNumberDensity=areaXY(DimensionShort, DistShort, 0, inf)
	endif
	if (stringmatch(YwvName,"*Volume*") || stringmatch(YwvName,"*VolDist*"))
		//print YwvName[strsearch(YwvName, "pop", 0)+3]
		IR1G_CreateAveVolSfcWvUsingNote(ParticleVolumes,DimensionShort,Note(DistributionWv),"Volume", popNumber)
		DistShort2 = DistShort / ParticleVolumes			//this is now number distribution
		SDNumberDensity=areaXY(DimensionShort, DistShort2, 0, inf)
	endif
	//	GR1_PorodSurface=IR1G_CalculateSurfaceArea(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B), CsrAwaveName)
	if(stringMatch(XwvName,"*Radi*"))				//this is really radius wave...
		DimensionShort2 =  2 * DimensionShort		//convert to diameters for next calculations
	endif
	IR1G_CreateAveVolSfcWvUsingNote(ParticleSurface,DimensionShort2,Note(DistributionWv),"Surface", popNumber)

	if (stringmatch(YwvName,"*Number*") || stringmatch(YwvName,"*NumDist*"))
		//this is easy, just integrate
		DistShort2 = DistShort * ParticleSurface
		variable MinDecSurfaceArea=areaXY(DimensionShort, DistShort2, 0, inf)
	endif
	if (stringmatch(YwvName,"*Volume*") || stringmatch(YwvName,"*VolDist*"))
		IR1G_CreateAveVolSfcWvUsingNote(ParticleVolumes,DimensionShort2,Note(DistributionWv),"Volume", popNumber)
		DistShort2 = DistShort / ParticleVolumes			//this is now number distribution
		DistShort2 = DistShort2 * ParticleSurface			//this is now specific surface area
		SDSpecSurfaceArea=areaXY(DimensionShort, DistShort2, 0, inf)
	elseif (stringmatch(YwvName,"*Number*") || stringmatch(YwvName,"*NumDist*"))
		DistShort2 = DistShort * ParticleSurface			//this is now specific surface area
		SDSpecSurfaceArea=areaXY(DimensionShort, DistShort2, 0, inf)
	endif
	//	GR1_FWHM=IR1G_FindFWHM(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B))
		FindPeak/P/Q DistShort
		if (V_Flag)		//peak not found
			SDFWHM = NaN
		else
			wavestats/Q/P DistShort
			variable maximum=V_max
			variable maxLoc=V_maxLoc
			Duplicate/O/R=[0,maxLoc]/Free DistShort, temp_wv1
			Duplicate/O/R=[0,maxLoc]/Free DimensionShort, temp_DWwv1
			wavestats/Q/P temp_wv1
			variable OneMin=V_min
			Duplicate/O/R=[maxLoc, numpnts(DistShort)-1]/Free DistShort, temp_wv2
			Duplicate/O/R=[maxLoc, numpnts(DistShort)-1]/Free DimensionShort, temp_DWwv2		
			wavestats/Q/P temp_wv2
			variable TwoMin=V_min			
			if (OneMin>(maximum/2) || TwoMin>(maximum/2))
				SDFWHM = NaN
			endif
			variable MinD
			FindLevel/P/Q temp_wv1, (maximum/2)
			if(numtype(V_levelX)!=0)
				MinD = temp_DWwv1[0]
			else
				MinD=temp_DWwv1[V_levelX]
			endif
			variable MaxD			
			FindLevel/P/Q temp_wv2, (maximum/2)
			if(numtype(V_levelX)!=0)
				MinD = temp_DWwv2[numpnts(temp_DWwv2)-1]
			else
				MaxD=temp_DWwv2[V_levelX]	
			endif
			SDFWHM = abs(MaxD-MinD)	
		endif

		//		IR1G_CreateCumulativeCurves(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B), CsrAwaveName)
		IR3E_SDCreateCumulativeCurves()
		IR3E_SDDisplayCumulativeCurves()
		
		IR3E_SDCreateMIPCurve()
		
		NVAR CalcMIPdata = root:Packages:Irena:AnalyzeResults:SDMIPCreateCurves
		if(CalcMIPdata)
			IR3E_SDCreateMIPCurve()
			DoWIndow AnalyseSDMIPDataGraph
			if(V_Flag)
				DoWIndow /F AnalyseSDMIPDataGraph
				AutoPositionWindow/R=IR3E_AnalyzeResultsPanel AnalyseSDMIPDataGraph
			else
				IR3E_SDMIPDataGraph()
			endif
		else
			KillWIndow/Z AnalyseSDMIPDataGraph
			KillWaves/Z MIPVolume, MIPDistDiameters, MIPPressure	
		endif
		
		


end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3E_SDMIPDataGraph()

	NVAR SDMIPCreateCurves = root:Packages:Irena:AnalyzeResults:SDMIPCreateCurves
	if(SDMIPCreateCurves<1)
		KillWindow/Z AnalyseSDMIPDataGraph
		KillWaves/Z MIPVOlume, MIPPressure
	else
		
		Wave/Z MIPVOlume    = root:Packages:Irena:AnalyzeResults:MIPVOlume
		Wave/Z MIPPressure  = root:Packages:Irena:AnalyzeResults:MIPPressure
		NVAR EndSize 		= root:Packages:Irena:AnalyzeResults:DataQEnd
		NVAR StartSize 		= root:Packages:Irena:AnalyzeResults:DataQStart
		SVAR DataFolderName = root:Packages:Irena:AnalyzeResults:DataFolderName
		if(SDMIPCreateCurves && WaveExists(MIPVOlume)&&WaveExists(MIPPressure))
	
			Display /K=1/W=(35,84,380,291)/N=AnalyseSDMIPDataGraph MIPVolume vs MIPPressure as "MIP curve for "+DataFolderName
			ModifyGraph log(bottom)=1
			Label left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intruded volume [fraction]"
			Label bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Pressure [Psi]"
			ModifyGraph mirror=1
			ModifyGraph mode=0,lsize=2,rgb=(0,0,0)
			Legend/C/N=text1/J/F=0/A=LT "\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"\\s(MIPVolume) MIP Volume for "+DataFolderName +"  for "+num2str(StartSize)+" < D [A] < " +num2str(EndSize)
			AutoPositionWindow/R=IR3E_AnalyzeResultsPanel AnalyseSDMIPDataGraph
		endif
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3E_SDCreateMIPCurve()

	DFref oldDf= GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:AnalyzeResults

	NVAR SDMIPCreateCurves = root:Packages:Irena:AnalyzeResults:SDMIPCreateCurves
	if(SDMIPCreateCurves<0.5)
		KillWindow/Z AnalyseSDMIPDataGraph
		KillWaves/Z MIPVOlume, MIPPressure
		setDataFolder OldDf	
		return 0
	else
		NVAR EndSize 		= root:Packages:Irena:AnalyzeResults:DataQEnd
		NVAR StartSize 		= root:Packages:Irena:AnalyzeResults:DataQStart
		NVAR EndP 			= root:Packages:Irena:AnalyzeResults:DataQEndPoint
		NVAR StartP 		= root:Packages:Irena:AnalyzeResults:DataQstartPoint
		NVAR MIPUserSigma	=root:Packages:Irena:AnalyzeResults:SDMIPsigma 
		NVAR MIPUserCosTheta=root:Packages:Irena:AnalyzeResults:SDMIPcosTheta
		SVAR XwvName 			= root:Packages:Irena:AnalyzeResults:QWavename
		SVAR YwvName 			= root:Packages:Irena:AnalyzeResults:IntensityWaveName
		variable popNumber=str2num(YwvName[strsearch(YwvName, "pop", 0)+3])
	
		Wave/Z DistributionWV	= root:Packages:Irena:AnalyzeResults:OriginalYDataWave
		Wave/Z DimensionWV		= root:Packages:Irena:AnalyzeResults:OriginalXDataWave
		if(!WaveExists(DistributionWV) || !WaveExists(DimensionWV) || strlen(XwvName)<1 || strlen(YwvName)<1)
			setDataFolder OldDf	
			return 0
		endif
		SVAR AnalysisMethodSelected = root:Packages:Irena:AnalyzeResults:AnalysisMethodSelected
		if(!stringMatch(AnalysisMethodSelected,"SizeDistribution"))
			setDataFolder OldDf	
			return 0
		endif
		
		Duplicate/O/R=(StartP, EndP) DistributionWv, MIPVolume, ParticleVolumes, ParticleSurfaces
		Duplicate/O/R=(StartP, EndP) DimensionWV, MIPDistDiameters, MIPPressure
		
	//	variable surface
		if (stringmatch(YwvName,"*Number*"))
			IR1G_CreateAveVolSfcWvUsingNote(ParticleVolumes,MIPDistDiameters,Note(DistributionWv),"Volume",popNumber)
			MIPVolume = DistributionWv * ParticleVolumes				//this is volume distribution
		endif
		if (stringmatch(YwvName,"*Volume*"))
			IR1G_CreateAveVolSfcWvUsingNote(ParticleVolumes,MIPDistDiameters,Note(DistributionWv),"Volume", popNumber)
		endif
	
		variable curPnts= numpnts(MIPDistDiameters)
		Redimension/N=(curPnts+1) MIPDistDiameters
		MIPDistDiameters[curPnts] =  MIPDistDiameters[curPnts-1] +  (MIPDistDiameters[curPnts-1] - MIPDistDiameters[curPnts-2])
		integrate MIPVolume /X=MIPDistDiameters
		Redimension/N=(curPnts) MIPVolume, MIPDistDiameters
		MIPVolume = MIPVolume[numpnts(MIPVolume)-1] - MIPVolume[p]		//invert, so the max is at small sizes...
	
	//	
	//	//record stuff to wave note...
		note/NOCR MIPVolume, "MIP Source Data="+GetWavesDataFolder(DistributionWv, 2 )+";"
		note/NOCR MIPVolume, "MIP Start Diameter="+num2str(DimensionWV[StartP])+";"
		note/NOCR MIPVolume, "MIP End Diameter="+num2str(DimensionWV[EndP])+";"
		note/NOCR MIPVolume, "MIP Calculated On="+Date()+" "+time()+";"
	
		note/NOCR MIPPressure, "MIP Source Data="+GetWavesDataFolder(DistributionWv, 2 )+";"
		note/NOCR MIPPressure, "MIP Start Diameter="+num2str(DimensionWV[StartP])+";"
		note/NOCR MIPPressure, "MIP End Diameter="+num2str(DimensionWV[EndP])+";"
		note/NOCR MIPPressure, "MIP Calculated On="+Date()+" "+time()+";"
		 
		IN2G_AppendorReplaceWaveNote("MIPVolume","Wname","MIPVolume")
		IN2G_AppendorReplaceWaveNote("MIPVolume","Units","cm3/cm3")
	
		IN2G_AppendorReplaceWaveNote("MIPDistDiameters","Wname","MIPDistDiameters")
		IN2G_AppendorReplaceWaveNote("MIPDistDiameters","Units","A")
	
		IN2G_AppendorReplaceWaveNote("MIPPressure","Wname","MIPPressure")
		IN2G_AppendorReplaceWaveNote("MIPPressure","Units","Psi")
		
		
		variable MIPSigma
		if(MIPUserSigma>300 && MIPUserSigma<750) //sigma in dynes/cm, should be around 485 dynes/cm = 485 mN/m2... Weird unit. Radlinski,  Oct 2007
			MIPSigma = MIPUserSigma
		else
			MIPSigma = MIPUserSigma
		endif
		variable MIPCosTheta					//this should be around -0.766, Radlinski, Oct 2007
		if(MIPUserCosTheta<-0.1 && MIPUserCosTheta>-1)
			MIPCosTheta = MIPUserCosTheta
		else
			MIPCosTheta = -0.766
		endif
		
		//Pc=2sigma cos(theta)/r
		variable TwoSigCosTheta =  -2 * MIPSigma * MIPCosTheta * 10
		MIPPressure = TwoSigCosTheta / (MIPDistDiameters / 20)
		//these units will be surely wrong, so here it goes: MIP sigma is in dynes/cm which should be equivalent to mN/m2
		// Cost(theta) = - 0.766 unitless
		//Diameters are in A in Irena, here are converted into nm and radii for this formula to work... 
		// and pressure needs to be in Psi (the hell, could we use SI units for once, please??? 
		// according to my info, p[kg/cm2] = 2 * sigma * cos(theta) / r [nm], approximately 7500/r [nm]
		// but 2 * sigma * cos(theta) ~ 750, so multiply by 10  
		MIPPressure = MIPPressure * 9.8e4 * 1.4504e-4		//here the first converst kg/cm2 into Pascals and the second Pa into psi... 
		
		Sort MIPPressure, MIPPressure, MIPVolume 
	
	endif
	
	setDataFolder OldDf	

end


//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3E_SDDisplayCumulativeCurves()
		
		DoWindow IR3E_MainDataDisplay
		if(!V_Flag)
			return 0
		endif
		NVAR DisplayMe = root:Packages:Irena:AnalyzeResults:SDCreateCumulativeCurves


		Wave/Z CumulativeSizeDist 		= root:Packages:Irena:AnalyzeResults:CumulativeSizeDist
		Wave/Z CumulativeSfcArea 			= root:Packages:Irena:AnalyzeResults:CumulativeSfcArea
		Wave/Z CumulativeDistDiameters 	= root:Packages:Irena:AnalyzeResults:CumulativeDistDiameters
		if(!WaveExists(CumulativeSizeDist)||!WaveExists(CumulativeSfcArea)||!WaveExists(CumulativeDistDiameters))
			print "Cumulative curves do nto exist"
			return 0
		endif	
		if(DisplayMe<1)
			RemoveFromGraph/Z/W=IR3E_MainDataDisplay  CumulativeSizeDist, CumulativeSfcArea	
			//KillWaves /Z  CumulativeSizeDist, CumulativeDistDiameters, CumulativeSfcArea
		else
			CheckDisplayed /W=IR3E_MainDataDisplay CumulativeSizeDist
			if(!V_Flag)
				AppendToGraph /W=IR3E_MainDataDisplay /L=CumulVolumeAxis CumulativeSizeDist vs CumulativeDistDiameters
			endif
			ModifyGraph /W=IR3E_MainDataDisplay freePos(CumulVolumeAxis)=-571
			Label /W=IR3E_MainDataDisplay CumulVolumeAxis "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Cumulative size dist [fraction]"
			ModifyGraph /W=IR3E_MainDataDisplay rgb(CumulativeSizeDist)=(0,0,0)
			ModifyGraph /W=IR3E_MainDataDisplay lstyle(CumulativeSizeDist)=3,lsize(CumulativeSizeDist)=2
	
			CheckDisplayed /W=IR3E_MainDataDisplay CumulativeSfcArea
			if(!V_Flag)
				AppendToGraph /W=IR3E_MainDataDisplay /L=SurfaceAreaAxis CumulativeSfcArea vs CumulativeDistDiameters
			endif
			ModifyGraph /W=IR3E_MainDataDisplay freePos(SurfaceAreaAxis)=-110
			Label /W=IR3E_MainDataDisplay SurfaceAreaAxis "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Cumulative surface area [cm\S2\M/cm\S3\M]"
			ModifyGraph /W=IR3E_MainDataDisplay rgb(CumulativeSfcArea)=(16385,16388,65535)
			ModifyGraph /W=IR3E_MainDataDisplay lstyle(CumulativeSfcArea)=6,lsize(CumulativeSfcArea)=2
		endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3E_SDCreateCumulativeCurves()

	DFref oldDf= GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:AnalyzeResults

	NVAR SDCreateCumulativeCurves = root:Packages:Irena:AnalyzeResults:SDCreateCumulativeCurves
	if(SDCreateCumulativeCurves<0.5)
		Killwaves/Z CumulativeSizeDist, CumulativeSfcArea, ParticleVolumes, ParticleSurfaces, CumulativeDistDiameters
		setDataFolder OldDf	
		return 0
	endif
	
	NVAR EndSize 		= root:Packages:Irena:AnalyzeResults:DataQEnd
	NVAR StartSize 		= root:Packages:Irena:AnalyzeResults:DataQStart
	NVAR EndP 			= root:Packages:Irena:AnalyzeResults:DataQEndPoint
	NVAR StartP 		= root:Packages:Irena:AnalyzeResults:DataQstartPoint
	SVAR XwvName 			= root:Packages:Irena:AnalyzeResults:QWavename
	SVAR YwvName 			= root:Packages:Irena:AnalyzeResults:IntensityWaveName
	variable popNumber=str2num(YwvName[strsearch(YwvName, "pop", 0)+3])
	Wave/Z DistributionWV	= root:Packages:Irena:AnalyzeResults:OriginalYDataWave
	Wave/Z DimensionWV		= root:Packages:Irena:AnalyzeResults:OriginalXDataWave
	if(!WaveExists(DistributionWV) || !WaveExists(DimensionWV) || strlen(XwvName)<1 || strlen(YwvName)<1)
		setDataFolder OldDf	
		return 0
	endif
	SVAR AnalysisMethodSelected = root:Packages:Irena:AnalyzeResults:AnalysisMethodSelected
	if(!stringMatch(AnalysisMethodSelected,"SizeDistribution"))
		setDataFolder OldDf	
		return 0
	endif
	
	Duplicate/O/R=(StartP, EndP) DistributionWv, CumulativeSizeDist, CumulativeSfcArea, ParticleVolumes, ParticleSurfaces
	Duplicate/O/R=(StartP, EndP) DimensionWV, CumulativeDistDiameters

	variable scaleDueToDiaRadChange=1
	NVAR InvertCumulativeDists=root:Packages:Irena:AnalyzeResults:InvertCumulativeDists
	
	variable surface
	if (stringmatch(YwvName,"*Number*"))
		IR1G_CreateAveVolSfcWvUsingNote(ParticleVolumes,CumulativeDistDiameters,Note(DistributionWv),"Volume", popNumber)
		CumulativeSizeDist = DistributionWv * ParticleVolumes						//this is volume distribution
		IR1G_CreateAveVolSfcWvUsingNote(ParticleSurfaces,CumulativeDistDiameters,Note(DistributionWv),"Surface", popNumber)
		CumulativeSfcArea = DistributionWv * ParticleSurfaces						//this is volume distribution
	endif
	if (stringmatch(YwvName,"*Volume*"))
		IR1G_CreateAveVolSfcWvUsingNote(ParticleVolumes,CumulativeDistDiameters,Note(DistributionWv),"Volume", popNumber)
		IR1G_CreateAveVolSfcWvUsingNote(ParticleSurfaces,CumulativeDistDiameters,Note(DistributionWv),"Surface", popNumber)
		CumulativeSfcArea = (DistributionWv/ParticleVolumes) * ParticleSurfaces		//this is volume distribution
	endif
	variable curPnts= numpnts(CumulativeDistDiameters)
	Redimension/N=(curPnts+1) CumulativeDistDiameters
	CumulativeDistDiameters[curPnts] =  CumulativeDistDiameters[curPnts-1] +  (CumulativeDistDiameters[curPnts-1] - CumulativeDistDiameters[curPnts-2])
	integrate CumulativeSizeDist /X=CumulativeDistDiameters
	integrate CumulativeSfcArea /X=CumulativeDistDiameters
	Redimension/N=(curPnts) CumulativeSizeDist, CumulativeSfcArea, CumulativeDistDiameters
	
	if(InvertCumulativeDists)
		CumulativeSizeDist = CumulativeSizeDist[numpnts(CumulativeSizeDist)-1] - CumulativeSizeDist[p]
		CumulativeSfcArea = CumulativeSfcArea[numpnts(CumulativeSfcArea)-1] - CumulativeSfcArea[p]		
	endif

	if(stringmatch(XwvName, "*Radi*"))	//name contains radius, so we need to multiply the radius by 2 and divide the otehr waves by two to keep calibration
		CumulativeDistDiameters*=2
		CumulativeSizeDist*=0.5
		CumulativeSfcArea*=0.5
	endif
	
	//record stuff to wave note...
	note/NOCR CumulativeSizeDist, "Cumulative Source Data="+GetWavesDataFolder(DistributionWv, 2 )+";"
	note/NOCR CumulativeSizeDist, "Cumulative Start Diameter="+num2str(DimensionWV[StartP])+";"
	note/NOCR CumulativeSizeDist, "Cumulative End Diameter="+num2str(DimensionWV[EndP])+";"
	note/NOCR CumulativeSizeDist, "Cumulative Calculated On="+Date()+" "+time()+";"

	note/NOCR CumulativeSfcArea, "Cumulative Source Data="+GetWavesDataFolder(DistributionWv, 2 )+";"
	note/NOCR CumulativeSfcArea, "Cumulative Start Diameter="+num2str(DimensionWV[StartP])+";"
	note/NOCR CumulativeSfcArea, "Cumulative End Diameter="+num2str(DimensionWV[EndP])+";"
	note/NOCR CumulativeSfcArea, "Cumulative Calculated On="+Date()+" "+time()+";"
	 
	IN2G_AppendorReplaceWaveNote("CumulativeSizeDist","Wname","CumulativeSizeDist")
	IN2G_AppendorReplaceWaveNote("CumulativeSizeDist","Units","cm3/cm3")

	IN2G_AppendorReplaceWaveNote("CumulativeSfcArea","Wname","CumulativeSfcArea")
	IN2G_AppendorReplaceWaveNote("CumulativeSizeDist","Units","cm2/cm3")

	IN2G_AppendorReplaceWaveNote("CumulativeDistDiameters","Wname","CumulativeDistDiameters")
	IN2G_AppendorReplaceWaveNote("CumulativeDistDiameters","Units","A")
	KillWaves/Z  ParticleVolumes
	setDataFolder OldDf	

end


//*****************************************************************************************************************
//*****************************************************************************************************************
