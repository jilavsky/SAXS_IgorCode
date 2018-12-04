#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.13



//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_StandardUSAXSPlots()
	//this function generates panel for standard USAXS plots, should be eventually the most useful plotting tool...
	//calls IN2S_InitializeStandardPlots() and executes IN2S_StandardPlotPanel()

	IN2G_UniversalFolderScan("root:USAXS:", 5, "IN2G_CheckTheFolderName()")  //here we fix the folder names/sample names in wave notes if necessary
		
	IN2S_InitializeStandardPlots()
	Execute ("IN2S_StandardPlotPanel()")

end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_InitializeStandardPlots()
	//initializes the data for Standard Plots
	//no functions called

	//first create place where to work
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:StandardPlots
	
	KillWIndow/Z IN2S_TopGraph
	KillWIndow/Z IN2S_BotGraph

	//now lets create string & variables
	KillWaves/A/Z
		 
	string/g StandardPlotsParameters=""
	string/g PlotTypeOne="---"
	string/g PlotTypeTwo="---"
	string/g DataTypeToPlot="SMR_Int"
	string/g ActiveData="---"
	string/g ListOfPlottedData=""
	string/g ListOfPlottedDataNames=""
	
	variable/g PlotOneYType=1
	variable/g PlotOneXType=1
	variable/g PlotTwoYType=1
	variable/g PlotTwoXType=1
	variable/g RemoveNegInt=1
	variable/g RemoveNegQval=1
	variable/g DeleteData=0
	
	NVAR/Z UseFontSize
	if(!NVAR_Exists(UseFontSize))
		variable/g UseFontSize=10
	endif
	
	variable/g IntensityMultiplier=1
	variable/g IntBackground=0
	variable/g Qoffset =0
	
	variable/g TopErrorBars=1
	variable/g BotErrorbars=1
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function/S IN2S_ListOfAvailableFolders()
	//generates list of available folders with the data as selected in popup
	//calls IN2G_FindFolderWithWaveTypes
	SetdataFolder root:Packages:StandardPlots:
	SVAR DataTypeToPlot
	return IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, DataTypeToPlot, 1)
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_UpdatePlotsParameters(key,val)
	string key, val
	//this does not seem to be used at all
	
	setDataFolder root:packages:StandardPlots:
	
	SVAR StandardPlotsParameters
	SVAR ActiveData
	
	if (cmpstr(ActiveData,"---")!=0)
		StandardPlotsParameters=ReplaceStringByKey(ActiveData+"_"+key, StandardPlotsParameters, val , "=" )
	endif
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_CopyWaves()
		//this function copies waves from their original folder into the local folder
		//works only on last item in the ListOfPlottedData, selects the proper data type
		
		setDataFolder root:Packages:StandardPlots:
		
		SVAR ListOfPlottedData
		SVAR DataTypeToPlot
		variable NumOfData=itemsInList(ListOfPlottedData)-1
		
		string IntWaveName="OrgIntData"+num2str(NumOfData)
		string QWaveName="OrgQData"+num2str(NumOfData)
		string EWaveName="OrgEData"+num2str(NumOfData)
		
		string pathToData=IN2S_FixThePopStr(stringFromList(NumOfData,ListOfPlottedData))
		
		string pathToInt=""
		string pathToQ=""
		string pathToE=""
		
	if (cmpstr(DataTypeToPlot,"SMR_Int")==0)
		pathToInt=pathToData+"SMR_Int"
		pathToQ=pathToData+"SMR_Qvec"
		pathToE=pathToData+"SMR_Error"
	endif

	if (cmpstr(DataTypeToPlot,"DSM_Int")==0)
		pathToInt=pathToData+"DSM_Int"
		pathToQ=pathToData+"DSM_Qvec"
		pathToE=pathToData+"DSM_Error"	
	endif

	if (cmpstr(DataTypeToPlot,"M_SMR_Int")==0)
		pathToInt=pathToData+"M_SMR_Int"
		pathToQ=pathToData+"M_SMR_Qvec"
		pathToE=pathToData+"M_SMR_Error"
	endif

	if (cmpstr(DataTypeToPlot,"M_DSM_Int")==0)
		pathToInt=pathToData+"M_DSM_Int"
		pathToQ=pathToData+"M_DSM_Qvec"
		pathToE=pathToData+"M_DSM_Error"
	endif

	if (cmpstr(DataTypeToPlot,"R_Int")==0)
		pathToInt=pathToData+"R_Int"
		pathToQ=pathToData+"R_Qvec"
		pathToE=pathToData+"R_Error"
	endif

	if (cmpstr(DataTypeToPlot,"Blank_R_Int")==0)
		pathToInt=pathToData+"Blank_R_Int"
		pathToQ=pathToData+"Blank_R_Qvec"
		pathToE=pathToData+"Blank_R_Error"
	endif

	if (cmpstr(DataTypeToPlot,"SizesNumberDistribution")==0)
		pathToInt=pathToData+"SizesNumberDistribution"
		pathToQ=pathToData+"SizeDistDiameter"
		pathToE=pathToData+"R_Error"
	endif

	if (cmpstr(DataTypeToPlot,"SizesVolumeDistribution")==0)
		pathToInt=pathToData+"SizesVolumeDistribution"
		pathToQ=pathToData+"SizeDistDiameter"
		pathToE=pathToData+"R_Error"
	endif

	if (cmpstr(pathToData,"---")!=0)	
		WAVE/Z OrgInt=$(pathToInt)
		WAVE/Z OrgQ=$(pathToQ)
		WAVE/Z OrgE=$(pathToE)
		if(!WaveExists(OrgInt)||!WaveExists(OrgQ)||!WaveExists(OrgE))	//here we make sure, that if the waves names are really screwed up, things will still work
			ListOfPlottedData=RemoveFromList(stringFromList(NumOfData,ListOfPlottedData), ListOfPlottedData)
			DoAlert 0, "There is something wrong with the data waves or their names, check the folder with data"
			abort
		endif
	
		Duplicate/O OrgInt, $IntWaveName
		Duplicate/O OrgQ, $QWaveName
		Duplicate/O OrgE, $EWaveName
	else
		ListOfPlottedData=RemoveFromList("---",ListOfPlottedData)
	endif	
	
	IN2S_CorrectOrgData()	//move out **************************************

end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_CalculateAllTopGraphWaves()
		//calls for each item in the listOfPlottedData IN2S_CalculateOneTopGraphWaves
		
	SVAR ListOfPlottedData
	
	variable numOfPlotedWaves=ItemsInList(ListOfPlottedData)
	variable i=0
	
	For (i=0;i<numOfPlotedWaves;i+=1)
		IN2S_CalculateOneTopGraphWaves(i)
	endfor
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_CalculateOneTopGraphWaves(WhichOne)
	variable WhichOne
		//calculates the topGraph waves for item in list
		// as called with 
	setDataFolder root:Packages:StandardPlots:
	
	SVAR PlotTypeOne
	SVAR ActiveData
	SVAR ListOfPlottedData
	SVAR DataTypeToPlot
	
	
	string OrgIntWvNm="ModIntData"+num2str(WhichOne)
	string OrgQWvNm="ModQData"+num2str(WhichOne)
	string OrgEWvNm="ModEData"+num2str(WhichOne)

	string IntWvNm="TopYData"+num2str(WhichOne)
	string QWvNm="TopXData"+num2str(WhichOne)
	string EWvNm="TopEData"+num2str(WhichOne)
	
	Wave OrgInt=$OrgIntWvNm
	Wave OrgQ=$OrgQWvNm
	Wave OrgE=$OrgEWvNm
	
	Duplicate/O OrgInt,$IntWvNm
	Duplicate/O OrgQ,$QWvNm
	Duplicate/O OrgE,$EWvNm
	
	Wave NewInt=$IntWvNm
	Wave NewQ=$QWvNm
	Wave NewE=$EWvNm
	
	if (cmpstr("Int-Q",PlotTypeOne)==0)
 
 	endif
	if (cmpstr("SizeDist",PlotTypeOne)==0)
 
 	endif
	
	if (cmpstr("Porod",PlotTypeOne)==0)
		if (stringmatch("*DSM*", DataTypeToPlot)==0)
			NewQ=NewQ^4
			NewInt=NewInt*NewQ
			NewE=NewE*NewQ
		else
			NewQ=NewQ^3
			NewInt=NewInt*NewQ
			NewE=NewE*NewQ
		endif
	endif
	if (cmpstr("Guinier",PlotTypeOne)==0)
			NewInt=ln(NewInt)
			NewE=0
			NewQ=NewQ^2
	endif
	if (cmpstr("Rg-Q",PlotTypeOne)==0)
			NewInt=ln(NewInt)
			NewE=0
			Duplicate/O NewQ, NewQ2
			NewQ2=NewQ^2			
			IN2S_DifferentiateXY (NewQ2, NewInt, "Different")
			Wave Different
			NewInt=Different
			KillWaves/Z Different, NewQ2
			NewInt=sqrt(abs(3*NewInt))
	endif	
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************


//	DifferentiateXY(xWave, yWave, yDestWaveName)
//		Produces derivative of XY pair.
//		The XY pair is assumed to be sorted.
//		You can sort with: Sort xWave, xWave, yWave
Function IN2S_DifferentiateXY(xWave, yWave, yDestWaveName)
	Wave xWave, yWave							// input X, Y waves
	String yDestWaveName						// name to use for output wave
	
	String xDestWaveName						// to hold name of temp dx/dp wave
	
	xDestWaveName = "DifferentiateXYTempX"
	
	Duplicate/O xWave, $xDestWaveName		// make clones
	Duplicate/O yWave, $yDestWaveName
	
	Wave xDest = $xDestWaveName
	Wave yDest = $yDestWaveName
	
	CopyScales/P yDest, xDest					// same dx, same Differentiate scale
	Differentiate xDest, yDest					// do differentiation
	yDest /= xDest								// take ratio
	KillWaves/Z xDest								// don't need dx/dp anymore
End

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_SetTopAsType(type)
	string type
	//sets parameters in the folder according to the type requested
	//and sets checkBoxes to the proper state, needs to be called by different procedure
	setDataFolder root:Packages:StandardPlots:
	NVAR PlotOneYType
	NVAR PlotOneXType

	if (cmpstr(type, "linX-linY")==0)
		PlotOneYType=0
		PlotOneXType=0
	endif
	if (cmpstr(type, "linX-logY")==0)
		PlotOneYType=1
		PlotOneXType=0
	endif
	if (cmpstr(type, "logX-linY")==0)
		PlotOneYType=0
		PlotOneXType=1
	endif
	if (cmpstr(type, "logX-logY")==0)
		PlotOneYType=1
		PlotOneXType=1
	endif	
	CheckBox PlotOneY,value= PlotOneYType, win=IN2S_StandardPlotPanel
	CheckBox PlotOneX,value= PlotOneXType, win=IN2S_StandardPlotPanel
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_SetBotAsType(type)
	string type
	//sets parameters in the folder according to the type requested
	//and sets checkBoxes to the proper state, needs to be called by different procedure
	setDataFolder root:Packages:StandardPlots:
	NVAR PlotTwoYType
	NVAR PlotTwoXType

	if (cmpstr(type, "linX-linY")==0)
		PlotTwoYType=0
		PlotTwoXType=0
	endif
	if (cmpstr(type, "linX-logY")==0)
		PlotTwoYType=1
		PlotTwoXType=0
	endif
	if (cmpstr(type, "logX-linY")==0)
		PlotTwoYType=0
		PlotTwoXType=1
	endif
	if (cmpstr(type, "logX-logY")==0)
		PlotTwoYType=1
		PlotTwoXType=1
	endif	
	CheckBox PlotTwoY,value= PlotTwoYType, win=IN2S_StandardPlotPanel
	CheckBox PlotTwoX,value= PlotTwoXType, win=IN2S_StandardPlotPanel
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_CalculateAllBotGraphWaves()
		//calls for each item in the listOfPlottedData IN2S_CalculateOneTopGraphWaves

	SVAR ListOfPlottedData
	
	variable numOfPlotedWaves=ItemsInList(ListOfPlottedData)
	variable i=0
	
	For (i=0;i<numOfPlotedWaves;i+=1)
		IN2S_CalculateOneBotGraphWaves(i)
	endfor
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_CalculateOneBotGraphWaves(WhichOne)
	variable WhichOne
		//calculates the topGraph waves for item in list
		// as called with 

	setDataFolder root:Packages:StandardPlots:
	
	SVAR PlotTypeTwo
	SVAR ActiveData
	SVAR ListOfPlottedData
	SVAR DataTypeToPlot
	
	string OrgIntWvNm="ModIntData"+num2str(WhichOne)
	string OrgQWvNm="ModQData"+num2str(WhichOne)
	string OrgEWvNm="ModEData"+num2str(WhichOne)

	string IntWvNm="BotYData"+num2str(WhichOne)
	string QWvNm="BotXData"+num2str(WhichOne)
	string EWvNm="BotEData"+num2str(WhichOne)
	
	Wave OrgInt=$OrgIntWvNm
	Wave OrgQ=$OrgQWvNm
	Wave OrgE=$OrgEWvNm
	
	Duplicate/O OrgInt,$IntWvNm
	Duplicate/O OrgQ,$QWvNm
	Duplicate/O OrgE,$EWvNm
	
	Wave NewInt=$IntWvNm
	Wave NewQ=$QWvNm
	Wave NewE=$EWvNm
	
	if (cmpstr("Int-Q",PlotTypeTwo)==0)
	endif
	if (cmpstr("SizeDist",PlotTypeTwo)==0)
	endif
	
	if (cmpstr("Porod",PlotTypeTwo)==0)
		if (stringmatch(DataTypeToPlot,"*DSM*")==1)
			NewQ=NewQ^4
			NewInt=NewInt*NewQ
			NewE=NewE*NewQ
		else
			NewQ=NewQ^3
			NewInt=NewInt*NewQ
			NewE=NewE*NewQ
		endif
	endif
	if (cmpstr("Guinier",PlotTypeTwo)==0)
			NewInt=ln(NewInt)
			NewE=0
			NewQ=NewQ^2
	endif
	if (cmpstr("Rg-Q",PlotTypeTwo)==0)
			NewInt=ln(NewInt)
			NewE=0
			Duplicate/O NewQ, NewQ2
		NewQ2=NewQ^2			
		IN2S_DifferentiateXY (NewQ2, NewInt, "Different")
		Wave Different
		NewInt=Different
		KillWaves/Z Different, NewQ2
		NewInt=sqrt(abs(3*NewInt))
	endif
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************


Function IN2S_StandardUSAXSPlotsPopup(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	//popup procedure used to control all popups in this procedure
	
	setDataFolder root:Packages:StandardPlots:
	SVAR StandardPlotsParameters
		SVAR ListOfPlottedData
//		SVAR ListOfPlottedDataNames
		SVAR DataTypeToPlot
		SVAR ActiveData
		SVAR PlotTypeOne
		SVAR PlotTypeTwo
		NVAR IntensityMultiplier
		NVAR IntBackground
		NVAR Qoffset
		NVAR RemoveNegInt
		NVAR RemoveNegQval
		NVAR DeleteData
		
	if (cmpstr("SelectDataType",ctrlName)==0)
//		DoAlert 1, "Do you really want to reset graphs?"
//		if (V_flag==1)
//			IN2S_InitializeStandardPlots()
			DataTypeToPlot=popStr
			IN2S_UpdatePlotsParameters("DataType",popStr)
//			execute("IN2S_StandardPlotPanel()")
//		endif
	endif
	
	if (cmpstr("AddDataToPlot",ctrlName)==0)
		ListOfPlottedData+=popStr+DataTypeToPlot+":"+";"
//		ListOfPlottedData+=popStr+";"
		IN2S_CopyWaves()
//		StandardPlotsParameters=ReplaceStringByKey(popStr+"_DataType", StandardPlotsParameters, DataTypeToPlot , "=" )	//here we record the type of data for this one dataset
		DoWindow IN2S_TopGraph
		if (V_flag==1)
			IN2S_FixPlotAxis("Top","Set")
			IN2S_CalculateAllTopGraphWaves()
			IN2S_AppendTopWaves()		
			IN2S_GraphLegendAndColors()
			IN2S_SetTopAxis()
			IN2S_FixPlotAxis("Top","Reset")
		endif
		DoWindow IN2S_BotGraph
		if (V_flag==1)
			IN2S_FixPlotAxis("Bot","Set")
			IN2S_CalculateAllBotGraphWaves()
			IN2S_AppendBotWaves()	
			IN2S_GraphLegendAndColors()
			IN2S_SetBotAxis()
			IN2S_FixPlotAxis("Bot","Reset")
		endif	
	endif
	
	if (cmpstr("SelectActiveData",ctrlName)==0)
		ActiveData=popStr
		IntensityMultiplier=NumberByKey(ActiveData+"IntensityMultiplier", StandardPlotsParameters , "=" )
		Qoffset=NumberByKey(ActiveData+"Qoffset", StandardPlotsParameters , "=" )
		IntBackground=NumberByKey(ActiveData+"IntBackground", StandardPlotsParameters , "=" )
		RemoveNegInt=NumberByKey(ActiveData+"RemoveNegInt", StandardPlotsParameters , "=" )
		RemoveNegQval=NumberByKey(ActiveData+"RemoveNegQval", StandardPlotsParameters , "=" )
		DeleteData=NumberByKey(ActiveData+"DeleteData", StandardPlotsParameters , "=" )
//		if (numtype(IntensityMultiplier)!=0)
//			IntensityMultiplier=1
//		endif
//		if (numtype(Qoffset)!=0)
//			Qoffset=0
//		endif
//		if (numtype(IntBackground)!=0)
//			IntBackground=0
//		endif
//		if (numtype(RemoveNegInt)!=0)
//			RemoveNegInt=1
//		endif
//		if (numtype(RemoveNegQval)!=0)
//			RemoveNegQval=1
//		endif
		CheckBox RemvNegInt,value= RemoveNegInt, win=IN2S_StandardPlotPanel
		CheckBox RemvNegQ,value= RemoveNegQval, win=IN2S_StandardPlotPanel
		CheckBox DeleteData,value= DeleteData, win=IN2S_StandardPlotPanel

	endif

	if (cmpstr("TopType",ctrlName)==0)
		if (cmpstr(popStr,"---")!=0)
			PlotTypeOne=popStr
			IN2S_CalculateAllTopGraphWaves()
			IN2S_SetTopAxisType()
			IN2S_CreateTopGraph()
			IN2S_AppendTopWaves()
			IN2S_SetTopAxis()
		else
			PlotTypeOne=popStr
			KillWIndow/Z IN2S_TopGraph		
		endif
	endif
	
	if (cmpstr("BottomY",ctrlName)==0)
		PlotTypeTwo=popStr
	endif

	if (cmpstr("UseFontSize",ctrlName)==0)
		NVAR UseFontSize=root:Packages:StandardPlots:UseFontSize
		UseFontSize = str2num(popStr)
			DoWindow IN2S_TopGraph
			if(V_Flag)
				IN2S_CalculateAllTopGraphWaves()
				IN2S_SetTopAxisType()
				IN2S_CreateTopGraph()
				IN2S_AppendTopWaves()
				IN2S_SetTopAxis()
			endif
			DoWindow IN2S_BotGraph
			if(V_Flag)
				IN2S_CalculateAllBotGraphWaves()
				IN2S_SetBotAxisType()
				IN2S_CreateBotGraph()
				IN2S_AppendBotWaves()		
				IN2S_SetBotAxis()
			endif
	endif

	if (cmpstr("BottomType",ctrlName)==0)
		if (cmpstr(popStr,"---")!=0)
			PlotTypeTwo=popStr
			IN2S_CalculateAllBotGraphWaves()
			IN2S_SetBotAxisType()
			IN2S_CreateBotGraph()
			IN2S_AppendBotWaves()		
			IN2S_SetBotAxis()
		else	
			PlotTypeTwo=popStr
			KillWIndow/Z IN2S_BotGraph			
		endif
	endif	
End

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function/T IN2S_FixThePopStr(popStr)
	string popStr
	
	variable i, imax
	imax=ItemsInList(popStr,":")
	string tempStr
	tempStr=""
	
	For(i=0;i<imax-1;i+=1)
		tempStr+=StringFromList(i, popStr , ":")+":"
	endfor
	return tempStr
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_StandardPlotVariables(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	//Variables  procedure used to control all variables in this procedure
	
	setDataFolder root:packages:StandardPlots
	SVAR ListOfPlottedData
	SVAR ActiveData
	SVAR StandardPlotsParameters
	
	variable ModifiedData=WhichListItem(ActiveData , ListOfPlottedData)
	
	NVAR IntensityMultiplier
	NVAR IntBackground
	NVAR Qoffset

	if (cmpstr("IntModifier",ctrlName)==0)
		IntensityMultiplier=varNum	
		SetVariable IntModifier,limits={0,Inf,(varNum/20)}
	endif
	if (cmpstr("Qoffset",ctrlName)==0)
		Qoffset=varNum
		if (varNum==0)
			SetVariable Qoffset,limits={-Inf,Inf,0.0001}		
		else
			SetVariable Qoffset,limits={-Inf,Inf,varNum/10}
		endif
	endif
	if (cmpstr("IntBackground",ctrlName)==0)
		IntBackground=varNum	
		if (varNum==0)
			SetVariable IntBackground,limits={-Inf,Inf,1}		
		else
			SetVariable IntBackground,limits={-Inf,Inf,varNum/10}
		endif
	endif
	
	StandardPlotsParameters=ReplaceNumberByKey(ActiveData+"IntensityMultiplier", StandardPlotsParameters, IntensityMultiplier ,"=")
	StandardPlotsParameters=ReplaceNumberByKey(ActiveData+"Qoffset", StandardPlotsParameters, Qoffset ,"=")
	StandardPlotsParameters=ReplaceNumberByKey(ActiveData+"IntBackground", StandardPlotsParameters, IntBackground ,"=")

	IN2S_CorrectOrgData()				//remove??????
	IN2S_CalculateAllTopGraphWaves()		//remove ????????
	IN2S_CalculateAllBotGraphWaves()		//remove ?????????
End

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Window IN2S_StandardPlotPanel() : Panel
	KillWIndow/Z IN2S_StandardPlotPanel
	//creates panel, closes the old one, if it exists
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(543.75,49.25,963,688.25) as "Standard Plot panel"
//	ShowTools
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 5,textrgb= (65280,0,0)
	DrawText 73,18,"Standard USAXS plots panel"
	SetDrawEnv linethick= 4,linefgc= (0,0,65280)
	DrawLine 9,118,383,118
	SetDrawEnv fsize= 14,fstyle= 5,textrgb= (0,0,65280)
	DrawText 8,143,"Modify data :"
	SetDrawEnv linethick= 4,linefgc= (0,0,65280)
	DrawLine 9,279,383,279
	SetDrawEnv fsize= 14,fstyle= 5,textrgb= (0,0,65280)
	DrawText 8,306,"TOP plot control:"
	SetDrawEnv fsize= 14,fstyle= 5,textrgb= (0,0,65280)
	DrawText 10,406,"BOTTOM plot control:"
	DrawLine 9,479,383,479
	DrawText 10,511,"Other data controls:"
	Button ResetStandardPlots,pos={350,15},size={50,20},proc=IN2S_PlotFitsBtnControl,title="Reset", help={"Click to reset this tool and erase graphs"}
	PopupMenu SelectDataType,pos={12,42},size={173,21},proc=IN2S_StandardUSAXSPlotsPopup,title="Select data type:", help={"Select data type to add into the graphs"}
	PopupMenu SelectDataType,mode=1,popvalue=root:Packages:StandardPlots:DataTypeToPlot,value= #"\"SMR_Int;DSM_Int;R_Int;Blank_R_Int;M_SMR_Int;M_DSM_Int;SizesNumberDistribution;SizesVolumeDistribution\""
	PopupMenu AddDataToPlot,pos={1,75},size={138,21},proc=IN2S_StandardUSAXSPlotsPopup,title="Add Data to Plot"
	PopupMenu AddDataToPlot,mode=3,popvalue="---",value= #"\"---;\"+IN2S_ListOfAvailableFolders()", help={"Select data to add into the plot. Note, the data are added automatically."}
	PopupMenu SelectActiveData,pos={0,152},size={354,21},proc=IN2S_StandardUSAXSPlotsPopup,title="Selected:", help={"Select data which you want to modify"}
	PopupMenu SelectActiveData,mode=1,popvalue="---",value= #"\"---;\"+root:Packages:StandardPlots:ListOfPlottedData"
//	PopupMenu SelectActiveData,mode=1,popvalue="---",value= #"\"---;\"+IN2S_CreateListOfData()"
	SetVariable IntModifier,pos={64,187},size={180,16},proc=IN2S_StandardPlotVariables,title="Multiply Intensity by: ", help={"Multiply intensity by this number"}
	SetVariable IntModifier,limits={-Inf,Inf,( root:Packages:StandardPlots:IntensityMultiplier/20)},value= root:Packages:StandardPlots:IntensityMultiplier
	SetVariable IntBackground,pos={64,217},size={180,16},proc=IN2S_StandardPlotVariables,title="Subtract background: ", help={"Subtract flat background from the selected data."}
	SetVariable IntBackground,limits={-Inf,Inf,0.0001},value= root:Packages:StandardPlots:IntBackground
	SetVariable Qoffset,pos={64,247},size={180,16},proc=IN2S_StandardPlotVariables,title="Set Q offset: ", help={"Shift data by this Q offset value."}
	SetVariable Qoffset,limits={-Inf,Inf,0.0001},value= root:Packages:StandardPlots:Qoffset
	PopupMenu TopType,pos={4,320},size={188,21},proc=IN2S_StandardUSAXSPlotsPopup,title="Select TOP graph type: ", help={"Select type of plot to use for top plot"}
	PopupMenu TopType,mode=1,popvalue="---",value= #"\"---;Int-Q;SizeDist;Porod;Guinier;Rg-Q\""
	CheckBox PlotOneY,pos={280,300},size={73,14},proc=IN2S_StandardPlotsCheck,title="Log Y axis?", help={"Log vertical axis?"}
	CheckBox PlotOneY,value= root:Packages:StandardPlots:PlotOneYType
	CheckBox PlotOneX,pos={280,330},size={73,14},proc=IN2S_StandardPlotsCheck,title="Log X axis?", help={"Log horizontal axis?"}
	CheckBox PlotOneX,value= root:Packages:StandardPlots:PlotOneXType
	CheckBox PlotOneErrors,pos={280,360},size={73,14},proc=IN2S_StandardPlotsCheck,title="Error bars?", help={"Error bars?"}
	CheckBox PlotOneErrors,value= root:Packages:StandardPlots:TopErrorBars
	PopupMenu BottomType,pos={2,422},size={212,21},proc=IN2S_StandardUSAXSPlotsPopup,title="Select BOTTOM graph type: ", help={"Select type of plot to use for bottom plot."}
	PopupMenu BottomType,mode=1,popvalue="---",value= #"\"---;Int-Q;SizeDist;Porod;Guinier;Rg-Q\""
	CheckBox PlotTwoY,pos={280,400},size={73,14},proc=IN2S_StandardPlotsCheck,title="Log Y axis?", help={"Log vertical axis?"}
	CheckBox PlotTwoY,value= root:Packages:StandardPlots:PlotTwoYType
	CheckBox PlotTwoX,pos={280,430},size={73,14},proc=IN2S_StandardPlotsCheck,title="Log X axis?", help={"Log horizontal axis?"}
	CheckBox PlotTwoX,value= root:Packages:StandardPlots:PlotTwoXType
	CheckBox PlotTwoErrors,pos={280,460},size={73,14},proc=IN2S_StandardPlotsCheck,title="Error bars?", help={"Error bars?"}
	CheckBox PlotTwoErrors,value= root:Packages:StandardPlots:BotErrorBars
	CheckBox RemvNegQ,pos={280,180},size={96,14},proc=IN2S_StandardPlotsCheck,title="Rmv Q<0.0002?", help={"Remove Q values smaller than this value?"}
	CheckBox RemvNegQ,value= root:packages:StandardPlots:RemoveNegQval
	CheckBox RemvNegInt,pos={280,210},size={73,14},proc=IN2S_StandardPlotsCheck,title="Rmv Int<0?", help={"Remove negative intensities?"}
	CheckBox RemvNegInt,value= root:packages:StandardPlots:RemoveNegInt
	CheckBox DeleteData,pos={280,240},size={73,14},proc=IN2S_StandardPlotsCheck,title="Rmv from grph?", help={"Make this data set invisible in the graph?"}
	CheckBox DeleteData,value= root:packages:StandardPlots:DeleteData

	PopupMenu UseFontSize,pos={170,490},size={212,21},proc=IN2S_StandardUSAXSPlotsPopup,title="Select Legend font size ", help={"Select  size for font to be used in legend"}
	PopupMenu UseFontSize,mode=1,popvalue=num2str(root:Packages:StandardPlots:UseFontSize),value= "6;8;10;12;14;16;"

	Button SetCsrANaN,pos={8,526},size={180,20},proc=IN2G_SetPointWithCsrAToNaN,title="Set point w/csr A to NaN", help={"Set point on which is the c ursor A (circle) to NaN?"}
	Button RemvPntSmlrA,pos={200,526},size={180,20},proc=IN2G_SetPointsSmallerCsrAToNaN,title="Set pnts Q< csr(A) to NaN", help={"Set points with Qs smaller than the point with cursor A to NaN"}
	Button RemvPntsBtwnCsrs,pos={8,556},size={180,20},proc=IN2G_SetPointsBetweenCsrsToNaN,title="Set pnts btwn A-B to NaN", help={"Set points between the cursors to NaN"}
	Button RemvPntsLrgrB,pos={200,556},size={180,20},proc=IN2G_SetPointsLargerCsrBToNaN,title="Set pnts Q> csr(A) to NaN", help={"Set points with Q larger than point with cursor A (circle) to NaN"}

EndMacro
//**********************************************************************************
//**********************************************************************************
//**********************************************************************************


Function/T IN2S_CreateListOfData()

		SVAR ListOfPlottedData=root:Packages:StandardPlots:ListOfPlottedData
		SVAR StandardPlotsParameters=root:Packages:StandardPlots:StandardPlotsParameters
		string tempStr
		string currentDataSet
		variable i, imax
		imax=ItemsInList(ListOfPlottedData)
		tempStr=""
		For(i=0;i<imax;i+=1)
			currentDataSet=StringFromList(i, ListOfPlottedData)
			tempStr+=currentDataSet+StringByKey(currentDataSet+"_DataType" ,StandardPlotsParameters, "=")+";"
		endfor
		return tempStr
end
//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_StandardPlotsCheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	//controls checkboxes, all in this procedure
	setDataFolder root:Packages:StandardPlots:
	NVAR PlotOneYType
	NVAR PlotOneXType
	NVAR PlotTwoYType
	NVAR PlotTwoXType
	NVAR RemoveNegQval
	NVAR RemoveNegInt
	NVAR TopErrorBars
	NVAR BotErrorBars
	NVAR DeleteData
//	NVAR RemoveNegatives
	
	SVAR StandardPlotsParameters
	SVAR ActiveData
	

	if (cmpstr(ctrlName,"PlotOneErrors")==0)
		if (checked==1)
			TopErrorBars=1
		else
			TopErrorBars=0
		endif
		CheckBox PlotOneErrors,value= TopErrorBars, win=IN2S_StandardPlotPanel
//		IN2S_CorrectOrgData()
//		IN2S_CalculateAllTopGraphWaves()
//		IN2S_CalculateAllBotGraphWaves()
		DoWIndow IN2S_TopGraph
		if(!V_Flag)
			return 0
		endif
		IN2S_AppendTopWaves()
		IN2S_SetTopAxis()
	endif

	if (cmpstr(ctrlName,"PlotTwoErrors")==0)
		if (checked==1)
			BotErrorBars=1
		else
			BotErrorBars=0
		endif
		CheckBox PlotTwoErrors,value= BotErrorBars, win=IN2S_StandardPlotPanel
//		IN2S_CorrectOrgData()
//		IN2S_CalculateAllTopGraphWaves()
//		IN2S_CalculateAllBotGraphWaves()
		DoWIndow IN2S_BotGraph
		if(!V_Flag)
			return 0
		endif
		IN2S_AppendBotWaves()
		IN2S_SetBotAxis()
	endif

	if (cmpstr(ctrlName,"RemvNegInt")==0)
		if (checked==1)
			RemoveNegInt=1
		else
			RemoveNegInt=0
		endif
		StandardPlotsParameters=ReplaceNumberByKey(ActiveData+"RemoveNegInt", StandardPlotsParameters, RemoveNegInt ,"=")
		CheckBox RemvNegInt,value= RemoveNegInt, win=IN2S_StandardPlotPanel
		IN2S_CorrectOrgData()
		IN2S_CalculateAllTopGraphWaves()
		IN2S_CalculateAllBotGraphWaves()
	endif
	
	if (cmpstr(ctrlName,"DeleteData")==0)
		if (checked==1)
			DeleteData=1
		else
			DeleteData=0
		endif
		StandardPlotsParameters=ReplaceNumberByKey(ActiveData+"DeleteData", StandardPlotsParameters, DeleteData ,"=")
		CheckBox DeleteData,value= DeleteData, win=IN2S_StandardPlotPanel
		IN2S_CorrectOrgData()
		IN2S_CalculateAllTopGraphWaves()
		IN2S_CalculateAllBotGraphWaves()
	endif
	
	if (cmpstr(ctrlName,"RemvNegQ")==0)
		if (checked==1)
			RemoveNegQval=1
		else
			RemoveNegQval=0
		endif
		StandardPlotsParameters=ReplaceNumberByKey(ActiveData+"RemoveNegQval", StandardPlotsParameters, RemoveNegQval ,"=")
		CheckBox RemvNegQ,value= RemoveNegQval, win=IN2S_StandardPlotPanel
		IN2S_CorrectOrgData()
		IN2S_CalculateAllTopGraphWaves()
		IN2S_CalculateAllBotGraphWaves()
	endif

	if (cmpstr(ctrlName,"PlotOneY")==0)
		if (checked==1)
			PlotOneYType=1
			DoWindow IN2S_TopGraph
			if (V_flag==1)
				ModifyGraph/W=IN2S_TopGraph log(left)=1
				SetAxis/W=IN2S_TopGraph /A left
			endif
		else
			PlotOneYType=0
			DoWindow IN2S_TopGraph
			if (V_flag==1)
				ModifyGraph/W=IN2S_TopGraph log(left)=0
				IN2G_AutoscaleAxisFromZero("IN2S_TopGraph", "left","up")
			endif
		endif
	endif

	if (cmpstr(ctrlName,"PlotOneX")==0)
		if (checked==1)
			PlotOneXType=1
			DoWindow IN2S_TopGraph
			if (V_flag==1)
				ModifyGraph/W=IN2S_TopGraph log(bottom)=1
				SetAxis/W=IN2S_TopGraph /A bottom
			endif
		else
			PlotOneXType=0
			DoWindow IN2S_TopGraph
			if (V_flag==1)
				ModifyGraph/W=IN2S_TopGraph log(bottom)=0
				IN2G_AutoscaleAxisFromZero("IN2S_TopGraph","bottom","up")
			endif
		endif
	endif


	if (cmpstr(ctrlName,"PlotTwoY")==0)
		if (checked==1)
			PlotTwoYType=1
			DoWindow IN2S_BotGraph
			if (V_flag==1)
				ModifyGraph/W=IN2S_BotGraph log(left)=1
				SetAxis/W=IN2S_BotGraph /A left
			endif
		else
			PlotTwoYType=0
			DoWindow IN2S_BotGraph
			if (V_flag==1)
				ModifyGraph/W=IN2S_BotGraph log(left)=0
				IN2G_AutoscaleAxisFromZero("IN2S_BotGraph","left","up")
			endif
		endif
	endif

	if (cmpstr(ctrlName,"PlotTwoX")==0)
		if (checked==1)
			PlotTwoXType=1
			DoWindow IN2S_BotGraph
			if (V_flag==1)
				ModifyGraph/W=IN2S_BotGraph log(bottom)=1
				SetAxis/W=IN2S_BotGraph /A bottom
			endif
		else
			PlotTwoXType=0
			DoWindow IN2S_BotGraph
			if (V_flag==1)
				ModifyGraph/W=IN2S_BotGraph log(bottom)=0
				IN2G_AutoscaleAxisFromZero("IN2S_BotGraph","bottom","up")
			endif
		endif
	endif

//	NVAR RemoveNegatives=root:Packages:StandardPlots:RemoveNegatives
//	if (cmpstr("RemoveNegatives",ctrlname)==0)
//		if (checked)
//			RemoveNegatives=1
//		else
//			RemoveNegatives=0
//		endif
//		CheckBox RemoveNegatives,value= RemoveNegatives, win=IN2S_SizeDistPanelProc
//	endif
End

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_CreateTopGraph()
		//creates Top Graph, if it exists, it is first deleted
 	KillWIndow/Z IN2S_TopGraph
  	PauseUpdate    //*************************Graph section**********************************
	Display/k=1 /W=(0.3*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("height"),55*IN2G_ScreenWidthHeight("width"),47*IN2G_ScreenWidthHeight("height")) as "Top Graph"		
	DoWindow/C IN2S_TopGraph
	ModifyGraph mode=4,	margin(top)=20, mirror=1, minor=1
	showinfo												//shows info
	ShowTools/A											//show tools
	ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
	AutoPositionWindow/M=1 /R=IN2S_TopGraph IN2S_StandardPlotPanel 
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_SetTopAxis()
	NVAR PlotOneYType
	NVAR PlotOneXType
	//this procedure changes axis in the top graph acording to the variables set
	//uses IN2G_AutoscaleAxisFromZero
	if (PlotOneYType)
		ModifyGraph/W=IN2S_TopGraph log(left)=1
	else
		IN2G_AutoscaleAxisFromZero("IN2S_TopGraph","left","up")
	endif
	if (PlotOneXType)
		ModifyGraph/W=IN2S_TopGraph log(bottom)=1
	else
		IN2G_AutoscaleAxisFromZero("IN2S_TopGraph", "bottom","up")
	endif
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_SetBotAxis()
	NVAR PlotTwoYType
	NVAR PlotTwoXType
	//this procedure changes axis in the bot graph acording to the variables set
	//uses IN2G_AutoscaleAxisFromZero
	
	if (PlotTwoYType)
		ModifyGraph/W=IN2S_BotGraph log(left)=1
	else
		IN2G_AutoscaleAxisFromZero("IN2S_BotGraph","left","up")
	endif
	if (PlotTwoXType)
		ModifyGraph/W=IN2S_BotGraph log(bottom)=1
	else
		IN2G_AutoscaleAxisFromZero("IN2S_BotGraph","bottom","up")
	endif
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_CreateBotGraph()
		//creates Bot Graph, if it exists, it is first deleted

 	KillWIndow/Z IN2S_BotGraph
  	PauseUpdate    //*************************Graph section**********************************
	Display/k=1 /W=(0.3*IN2G_ScreenWidthHeight("width"),53*IN2G_ScreenWidthHeight("height"),55*IN2G_ScreenWidthHeight("width"),95*IN2G_ScreenWidthHeight("height")) as "Bottom Graph"		
	DoWindow/C IN2S_BotGraph
	ModifyGraph mode=4,	margin(top)=20, mirror=1, minor=1
	showinfo												//shows info
	ShowTools/A											//show tools
	ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
//	AutoPositionWindow/M=1 /R=IN2S_BotGraph IN2S_StandardPlotPanel 
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_AppendTopWaves()
	//append waves to the top graph
	//assumes that the graph exists
	SVAR ListOfPlottedData
	NVAR TopErrorBars
	variable items=ItemsInList(ListOfPlottedData)
	DoWindow/F IN2S_TopGraph
	DoWindow IN2S_TopGraph
	if(!V_Flag)
		return 0
	endif
	RemoveFromGraph/W=IN2S_TopGraph/Z TopYData0,TopYData1,TopYData2, TopYData3, TopYData4, TopYData5, TopYData6
	RemoveFromGraph/W=IN2S_TopGraph/Z TopYData7,TopYData8,TopYData9, TopYData10, TopYData11, TopYData12, TopYData13
	RemoveFromGraph/W=IN2S_TopGraph/Z TopYData14,TopYData15,TopYData16, TopYData17, TopYData18, TopYData19, TopYData20
	variable i=0
	For (i=0;i<items;i+=1)
		Wave wv=$("TopYData"+num2str(i))
		Wave er=$("TopEData"+num2str(i))
		Wave xwv=$("TopXData"+num2str(i))
		AppendToGraph/W=IN2S_TopGraph wv vs xwv
		DoUpdate
		string test="TopYData"+num2str(i)
		if (TopErrorBars)
			ErrorBars/W=IN2S_TopGraph $test, Y,wave=(er,er)
		endif
	endfor
	IN2S_LabelAxis("Top")
	IN2S_GraphLegendAndColors()
	IN2S_AppendButtonsToGraphs("Top")
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_AppendBotWaves()
	//append waves to the bot graph
	//assumes that the graph exists

	SVAR ListOfPlottedData
	variable items=ItemsInList(ListOfPlottedData)
	NVAR BotErrorBars
	DoWindow IN2S_BotGraph
	if(!V_Flag)
		return 0
	endif

	DoWindow/F IN2S_BotGraph	
	RemoveFromGraph/W=IN2S_BotGraph/Z BotYData0,BotYData1,BotYData2, BotYData3, BotYData4, BotYData5, BotYData6
	RemoveFromGraph/W=IN2S_BotGraph/Z BotYData7,BotYData8,BotYData9, BotYData10, BotYData11, BotYData12, BotYData13
	RemoveFromGraph/W=IN2S_BotGraph/Z BotYData14,BotYData15,BotYData16, BotYData17, BotYData18, BotYData19, BotYData20
	variable i=0
	For (i=0;i<items;i+=1)
		Wave wv=$("BotYData"+num2str(i))
		Wave er=$("BotEData"+num2str(i))
		Wave xwv=$("BotXData"+num2str(i))
		AppendToGraph/W=IN2S_BotGraph wv vs xwv
		DoUpdate
		string test="BotYData"+num2str(i)
		if (BotErrorBars)
			ErrorBars/W=IN2S_BotGraph $test, Y,wave=(er,er)
		endif
	endfor
	IN2S_LabelAxis("Bot")
	IN2S_GraphLegendAndColors()
	IN2S_AppendButtonsToGraphs("Bot")
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_GraphLegendAndColors()
	//appends legend using IN2G_GenerateLegendForGraph
	//and creates colors and markers
	ModifyGraph mode=4,	margin(top)=20, mirror=1, minor=1
	NVAR UseFontSize=root:Packages:StandardPlots:UseFontSize

	ModifyGraph/Z msize=1, mode=4, marker[0]=1, marker[1]=3,marker[2]=5, marker[3]=7,marker[4]=9, marker[5]=11,marker[6]=13, marker[7]=30,marker[8]=35
	ModifyGraph/Z rgb[0]=(0,0,0),rgb[1]=(65280,16320,16320),rgb[2]=(65280,50000,16320),rgb[3]=(16320,65280,65280), rgb[4]=(0,43520,65280),rgb[5]=(32640,65280,0),rgb[6]=(0,32640,0),rgb[7]=(0,16320,65280),rgb[8]=(65280,0,52240)
	ModifyGraph/Z rgb[9]=(0,0,0),rgb[10]=(65280,0,0),rgb[11]=(0,0,0),rgb[12]=(0,0,0), rgb[13]=(0,0,0),rgb[14]=(0,0,0),rgb[15]=(0,0,0),rgb[16]=(0,0,0),rgb[17]=(0,0,0)
	IN2G_GenerateLegendForGraph(UseFontSize,1,1)
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_LabelAxis(TopBot)
	string TopBot
	//this function labels axis as needed
	//here we need to include proper labels for proper graph types
	setDataFolder  root:Packages:StandardPlots:
	SVAR PlotTypeOne
	SVAR PlotTypeTwo
	
	if (cmpstr(TopBot,"Top")==0)
		if (cmpstr("Int-Q",PlotTypeOne)==0)
			Label/W=IN2S_TopGraph left "Intensity"
			Label/W=IN2S_TopGraph bottom "Q, 1/Angstrom"	
//			IN2G_AppendSizeTopWave("IN2S_TopGraph",TopXData0, TopYData0,0,0,-10)
		endif
		if (cmpstr("SizeDist",PlotTypeOne)==0)
			Label/W=IN2S_TopGraph left "Distribution"
			Label/W=IN2S_TopGraph bottom "Diameter Angstrom"	
		endif
		if (cmpstr("Porod",PlotTypeOne)==0)
			Label/W=IN2S_TopGraph left "Int * Q^p (p=3 for SMR, 4 for DSM)"
			Label/W=IN2S_TopGraph bottom "Q^p, (p=3 for SMR, 4 for DSM), 1/Angstrom^p"
		endif		
		if (cmpstr("Guinier",PlotTypeOne)==0)
			Label/W=IN2S_TopGraph left "ln (Int)"
			Label/W=IN2S_TopGraph bottom "Q^2, 1/Angstrom2"	
		endif		
		if (cmpstr("Rg-Q",PlotTypeOne)==0)
			Label/W=IN2S_TopGraph left "Rg, Angstrom"
			Label/W=IN2S_TopGraph bottom "Q, 1/Angstrom"	
		endif		
	endif
	if (cmpstr(TopBot,"Bot")==0)
		if (cmpstr("Int-Q",PlotTypeTwo)==0)
			Label/W=IN2S_BotGraph left "Intensity"
			Label/W=IN2S_BotGraph bottom "Q vector"	
//			IN2G_AppendSizeTopWave("IN2S_BotGraph",BotXData0, BotYData0,0,0,-10)
		endif
		if (cmpstr("SizeDist",PlotTypeTwo)==0)
			Label/W=IN2S_BotGraph left "Distribution"
			Label/W=IN2S_BotGraph bottom "Diameter Angstrom"	
		endif
		if (cmpstr("Porod",PlotTypeTwo)==0)
			Label/W=IN2S_BotGraph left "Int * Q^p, (p=3 for SMR, 4 for DSM)"
			Label/W=IN2S_BotGraph bottom "Q^p, (p=3 for SMR, 4 for DSM), 1/Angstrom^p"	
		endif		
		if (cmpstr("Guinier",PlotTypeTwo)==0)
			Label/W=IN2S_BotGraph left "ln (Int) "
			Label/W=IN2S_BotGraph bottom "Q^2, 1/Angstrom"	
		endif		
		if (cmpstr("Rg-Q",PlotTypeTwo)==0)
			Label/W=IN2S_BotGraph left "Rg, Angstrom"
			Label/W=IN2S_BotGraph bottom "Q, 1/Angstrom"	
		endif		
	endif
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_CorrectOrgData()
		//corrects the data - recalculates all data from Original waves into modified waves
		//using parameters in the list
	setDataFolder root:Packages:StandardPlots
	
	SVAR ListOfPlottedData
	variable NumberOfWaves=ItemsInList(ListOfPlottedData)
	SVAR StandardPlotsParameters
	variable i=0
	variable IntensityMultiplier
	variable Qoffset
	variable IntBackground
	string currentData
	variable RemoveNegIntTemp
	variable RemoveNegQvalTemp
	variable DeleteData

	NVAR RemoveNegInt
	NVAR RemoveNegQval
	
	For (i=0;i<NumberOfWaves;i+=1)
	
		WAVE CurrentInt=$("OrgIntData"+num2str(i))
		WAVE CurrentQ=$("OrgQData"+num2str(i))
		WAVE CurrentE=$("OrgEData"+num2str(i))
		
		currentData=StringFromList(i, ListOfPlottedData)
		
		IntensityMultiplier=NumberByKey(currentData+"IntensityMultiplier", StandardPlotsParameters , "=" )
		Qoffset=NumberByKey(currentData+"Qoffset", StandardPlotsParameters , "=" )
		IntBackground=NumberByKey(currentData+"IntBackground", StandardPlotsParameters , "=" )
		RemoveNegIntTemp=NumberByKey(currentData+"RemoveNegInt", StandardPlotsParameters , "=" )
		RemoveNegQvalTemp=NumberByKey(currentData+"RemoveNegQval", StandardPlotsParameters , "=" )
		DeleteData=NumberByKey(currentData+"DeleteData", StandardPlotsParameters , "=" )
		
		if (numtype(IntensityMultiplier)!=0)
			IntensityMultiplier=1
		endif
		if (numtype(DeleteData)!=0)
			DeleteData=0
		endif
		if (numtype(Qoffset)!=0)
			Qoffset=0
		endif
		if (numtype(IntBackground)!=0)
			IntBackground=0
		endif
		if (numtype(RemoveNegIntTemp)!=0)
			RemoveNegIntTemp=RemoveNegInt
		endif
		if (numtype(RemoveNegQvalTemp)!=0)
			RemoveNegQvalTemp=RemoveNegQval
		endif

		Duplicate/O  CurrentInt, $("ModIntData"+num2str(i))
		Duplicate/O  CurrentQ, $("ModQData"+num2str(i))
		Duplicate/O  CurrentE, $("ModEData"+num2str(i))
		
		Wave modInt=$("ModIntData"+num2str(i))
		Wave modQ=$("ModQData"+num2str(i))
		Wave modE=$("ModEData"+num2str(i))
		
		if (RemoveNegIntTemp)
			IN2S_RemoveNegInt(modInt)
		endif
		if (RemoveNegQvalTemp)
			IN2S_RemoveNegQval(modQ)
		endif
		
		modInt=(modInt-IntBackground)*IntensityMultiplier
		modQ=modQ-Qoffset
		modE=modE*IntensityMultiplier
		
		if (DeleteData)
			modInt=NaN
		endif
		
		StandardPlotsParameters=ReplaceNumberByKey(currentData+"IntensityMultiplier", StandardPlotsParameters , IntensityMultiplier,"=" )
		StandardPlotsParameters=ReplaceNumberByKey(currentData+"Qoffset", StandardPlotsParameters ,Qoffset, "=" )
		StandardPlotsParameters=ReplaceNumberByKey(currentData+"IntBackground", StandardPlotsParameters ,IntBackground, "=" )
		StandardPlotsParameters=ReplaceNumberByKey(currentData+"RemoveNegInt", StandardPlotsParameters ,RemoveNegIntTemp, "=" )
		StandardPlotsParameters=ReplaceNumberByKey(currentData+"RemoveNegQval", StandardPlotsParameters ,RemoveNegQvalTemp, "=" )
		StandardPlotsParameters=ReplaceNumberByKey(currentData+"DeleteData", StandardPlotsParameters ,DeleteData, "=" )

	endfor
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_RemoveNegInt(modInt)	//removes negative intensities
		Wave modInt
		variable i
		For(i=0;i<numpnts(modInt);i+=1)
			if (modInt[i]<0)
				modInt[i]=NaN
			endif
		endfor
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_RemoveNegQval(modQ)	//removes Qs smaller than 0.00015
		Wave modQ
		variable limits=BinarySearch(modQ, 0.00015 )
		modQ[0,limits]=NaN
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_SetBotAxisType() 
		//sets axis types (log/lin) acording to type of plot selected. Used to reset
		//the axis to usual style when plot type changed.
		//uses IN2S_SetBotAsType
	setDataFolder root:Packages:StandardPlots:
	
	SVAR PlotTypeTwo
		
	if (cmpstr("Int-Q",PlotTypeTwo)==0)
			IN2S_SetBotAsType("LogX-LogY")		
	endif

	if (cmpstr("SizeDist",PlotTypeTwo)==0)
			IN2S_SetBotAsType("LinX-LinY")		
	endif
	
	if (cmpstr("Porod",PlotTypeTwo)==0)
		IN2S_SetBotAsType("LinX-LinY")		
	endif
	if (cmpstr("Guinier",PlotTypeTwo)==0)
			IN2S_SetBotAsType("LinX-linY")		
	endif
	if (cmpstr("Rg-Q",PlotTypeTwo)==0)
		IN2S_SetBotAsType("LogX-linY")		
	endif
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_SetTopAxisType()
		//sets axis types (log/lin) acording to type of plot selected. Used to reset
		//the axis to usual style when plot type changed.
		//uses IN2S_SetTopAsType
	
	setDataFolder root:Packages:StandardPlots:
	
	SVAR PlotTypeOne
	if (cmpstr("Int-Q",PlotTypeOne)==0)
		IN2S_SetTopAsType("LogX-logY")		
	endif

	if (cmpstr("SizeDist",PlotTypeOne)==0)
		IN2S_SetTopAsType("LinX-LinY")		
	endif
	
	if (cmpstr("Porod",PlotTypeOne)==0)
		IN2S_SetTopAsType("LinX-linY")		
	endif
	if (cmpstr("Guinier",PlotTypeOne)==0)
		IN2S_SetTopAsType("LinX-linY")		
	endif
	if (cmpstr("Rg-Q",PlotTypeOne)==0)
		IN2S_SetTopAsType("LogX-linY")		
	endif	
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_PlotFitsBtnControl(ctrlName) : ButtonControl
	String ctrlName

	setDataFolder root:Packages:StandardPlots:
	
	//here goes what happens if I push FitPorod button
	//	Button FitPorodTop,pos={89,23},size={50,20},proc=IN2S_PlotFitsBtnControl,title="Fit Porod"
	//	Button FitPorodBot,pos={89,23},size={50,20},proc=IN2S_PlotFitsBtnControl,title="Fit Porod"

	if (cmpstr(ctrlName,"ResetStandardPlots")==0)
			IN2S_InitializeStandardPlots()
			execute("IN2S_StandardPlotPanel()")
	endif

	if (cmpstr(ctrlName,"FitPorodTop")==0)
		IN2S_FitPorodFnct("Top")
	endif
	if (cmpstr(ctrlName,"FitPorodBot")==0)
		IN2S_FitPorodFnct("Bot")
	endif
	if (cmpstr(ctrlName,"FitGuinierTop")==0)
		IN2S_FitGuinierFnct("Top")
	endif
	if (cmpstr(ctrlName,"FitGuinierBot")==0)
		IN2S_FitGuinierFnct("Bot")
	endif
	if (cmpstr(ctrlName,"SizeDistPanelTop")==0)
		IN2S_SizeDistPanel("Top")
	endif	
	if (cmpstr(ctrlName,"SizeDistPanelBot")==0)
		IN2S_SizeDistPanel("Bot")
	endif
End

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************
//Panel for size distributions
Function IN2S_SizeDistPanel(which)
	string which
	
	IN2S_InitializeSizeDistCalc()
	
	SVAR/Z gwhich=root:Packages:StandardPlots:which
	if (!SVAR_Exists(gwhich))
		string/G root:Packages:StandardPlots:which
		SVAR gwhich=root:Packages:StandardPlots:which
	endif
	gwhich=which
	
	KillWIndow/Z IN2S_SizeDistPanelProc
 	Execute("IN2S_SizeDistPanelProc()")
end

Function IN2S_CalculateSizeDistparam(ctrlName) : ButtonControl
	String ctrlName

	NVAR CalibrationFactor=root:Packages:StandardPlots:CalibrationFactor
	NVAR VolumeFraction=root:Packages:StandardPlots:VolumeFraction
	NVAR NumberDensity=root:Packages:StandardPlots:NumberDensity
	NVAR SpecificSurface=root:Packages:StandardPlots:SpecificSurface
	NVAR VWMeanDiameter=root:Packages:StandardPlots:VWMeanDiameter
	NVAR NWMeanDiameter=root:Packages:StandardPlots:NWMeanDiameter
	NVAR VWStandardDeviation=root:Packages:StandardPlots:VWStandardDeviation
	NVAR NWStandardDeviation=root:Packages:StandardPlots:NWStandardDeviation
	NVAR RemoveNegatives=root:Packages:StandardPlots:RemoveNegatives
	SVAR which=root:Packages:StandardPlots:which
	
	//first make sure we are in the appropriate graph window 
	If (cmpstr(which,"Top")==0)
		DoWIndow/F IN2S_TopGraph
	endif
	If (cmpstr(which,"Bot")==0)
		DoWIndow/F IN2S_BotGraph
	endif
	
	//here we calculate what is needed
	//First pull the wave names
	if (cmpstr(CsrWave(A), CsrWave(B))!=0)
		Abort "Cursors are not on the same data or not in the graph at all" 
	endif
	
//	//Here we need to check for cursors, if they are in the graph...
	variable StartPoint=pcsr(A)
	variable EndPoint=pcsr(B)
//	if (numtype(StartPoint)==2 || numtype(EndPoint)==2)
//		abort "Cursors not in the graph"
//	endif
	
	Wave FD=CsrWaveRef(A)			//, "IN2S_TopGraph"
	Wave Ddist=CsrXWaveRef(A)
	
	VolumeFraction=CalibrationFactor*IN2G_VolumeFraction(FD,Ddist,StartPoint,EndPoint, RemoveNegatives)
	NumberDensity=CalibrationFactor*IN2G_NumberDensity(FD,Ddist,StartPoint,EndPoint, RemoveNegatives)
	SpecificSurface=CalibrationFactor*IN2G_SpecificSurface(FD,Ddist,StartPoint,EndPoint, RemoveNegatives)
	VWMeanDiameter=CalibrationFactor*IN2G_VWMeanDiameter(FD,Ddist,StartPoint,EndPoint, RemoveNegatives)
	NWMeanDiameter=CalibrationFactor*IN2G_NWMeanDiameter(FD,Ddist,StartPoint,EndPoint, RemoveNegatives)
	VWStandardDeviation=CalibrationFactor*IN2G_VWStandardDeviation(FD,Ddist,StartPoint,EndPoint, RemoveNegatives)
	NWStandardDeviation=CalibrationFactor*IN2G_NWStandardDeviation(FD,Ddist,StartPoint,EndPoint, RemoveNegatives)
	//I wish I knew if the calibration factor was this easy for all these parameters
	
End


Window IN2S_SizeDistPanelProc() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(764.25,47,1064.25,395.75) as "IN2S_SizeDistPanelProc"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 5,textrgb= (0,0,65280)
	DrawText 35,27,"Size distribution calculations"
	DrawText 12,53,"Select range of data to evaluate using cursors"
	DrawText 213,235,"A^2/A^3"
	DrawText 213,210,"1/A^3"
	DrawText 213,260,"A"
	DrawText 213,310,"A"
	DrawText 213,285,"A"
	DrawText 213,336,"A"
	SetVariable Calfactor,pos={27,68},size={150,16},title="Scaling factor: "
	SetVariable Calfactor,limits={-Inf,Inf,0},value= root:Packages:StandardPlots:CalibrationFactor
	Button Calculate,pos={84,124},size={100,20},proc=IN2S_CalculateSizeDistparam,title="Calculate"
	CheckBox RemoveNegatives,pos={103,97},size={122,14},proc=IN2S_StandardPlotsCheck,title="Remove negative f(D)"
	CheckBox RemoveNegatives,value= root:Packages:StandardPlots:RemoveNegatives
	SetVariable VolumeFraction,pos={5,170},size={200,16},title="Volume fraction : "
	SetVariable VolumeFraction,limits={0,0,0},value= root:Packages:StandardPlots:VolumeFraction
	SetVariable NumberDensity,pos={5,195},size={200,16},title="Number density : "
	SetVariable NumberDensity,limits={0,0,0},value= root:Packages:StandardPlots:NumberDensity
	SetVariable SpecificSurface,pos={5,220},size={200,16},title="Specific Surface: "
	SetVariable SpecificSurface,limits={0,0,0},value= root:Packages:StandardPlots:SpecificSurface
	SetVariable VWMeanDiameter,pos={5,245},size={200,16},title="Vol. wght. Mean Dia :"
	SetVariable VWMeanDiameter,limits={0,0,0},value= root:Packages:StandardPlots:VWMeanDiameter
	SetVariable NWMeanDiameter,pos={5,295},size={200,16},title="Num. wght. Mean Dia :"
	SetVariable NWMeanDiameter,limits={0,0,0},value= root:Packages:StandardPlots:NWMeanDiameter
	SetVariable VWStandardDev,pos={5,270},size={200,16},title="Vol. wght. Standard dev :"
	SetVariable VWStandardDev,limits={0,0,0},value= root:Packages:StandardPlots:VWStandardDeviation
	SetVariable NWStandardDeviation,pos={5,321},size={200,16},title="Num. wght. Standard dev.:"
	SetVariable NWStandardDeviation,limits={0,0,0},value= root:Packages:StandardPlots:NWStandardDeviation
EndMacro




Function IN2S_InitializeSizeDistCalc()

	NVAR/Z CalibrationFactor=root:Packages:StandardPlots:CalibrationFactor
	if (!NVAR_Exists(CalibrationFactor))
		variable/G root:Packages:StandardPlots:CalibrationFactor=1
		NVAR CalibrationFactor=root:Packages:StandardPlots:CalibrationFactor
	endif

	NVAR/Z RemoveNegatives=root:Packages:StandardPlots:RemoveNegatives
	if (!NVAR_Exists(RemoveNegatives))
		variable/G root:Packages:StandardPlots:RemoveNegatives=0
		NVAR RemoveNegatives=root:Packages:StandardPlots:RemoveNegatives
	endif

	NVAR/Z VolumeFraction=root:Packages:StandardPlots:VolumeFraction
	if (!NVAR_Exists(VolumeFraction))
		variable/G root:Packages:StandardPlots:VolumeFraction
		NVAR VolumeFraction=root:Packages:StandardPlots:VolumeFraction
	endif

	NVAR/Z NumberDensity=root:Packages:StandardPlots:NumberDensity
	if (!NVAR_Exists(NumberDensity))
		variable/G root:Packages:StandardPlots:NumberDensity
		NVAR NumberDensity=root:Packages:StandardPlots:NumberDensity
	endif

	NVAR/Z SpecificSurface=root:Packages:StandardPlots:SpecificSurface
	if (!NVAR_Exists(SpecificSurface))
		variable/G root:Packages:StandardPlots:SpecificSurface
		NVAR SpecificSurface=root:Packages:StandardPlots:SpecificSurface
	endif

	NVAR/Z VWMeanDiameter=root:Packages:StandardPlots:VWMeanDiameter
	if (!NVAR_Exists(VWMeanDiameter))
		variable/G root:Packages:StandardPlots:VWMeanDiameter
		NVAR VWMeanDiameter=root:Packages:StandardPlots:VWMeanDiameter
	endif

	NVAR/Z NWMeanDiameter=root:Packages:StandardPlots:NWMeanDiameter
	if (!NVAR_Exists(NWMeanDiameter))
		variable/G root:Packages:StandardPlots:NWMeanDiameter
		NVAR NWMeanDiameter=root:Packages:StandardPlots:NWMeanDiameter
	endif

	NVAR/Z VWStandardDeviation=root:Packages:StandardPlots:VWStandardDeviation
	if (!NVAR_Exists(VWStandardDeviation))
		variable/G root:Packages:StandardPlots:VWStandardDeviation
		NVAR VWStandardDeviation=root:Packages:StandardPlots:VWStandardDeviation
	endif

	NVAR/Z NWStandardDeviation=root:Packages:StandardPlots:NWStandardDeviation
	if (!NVAR_Exists(NWStandardDeviation))
		variable/G root:Packages:StandardPlots:NWStandardDeviation
		NVAR NWStandardDeviation=root:Packages:StandardPlots:NWStandardDeviation
	endif

end


//**********************************************************************************
//**********************************************************************************
//**********************************************************************************


Function IN2S_FitPorodFnct(which)
		string which 						//Top is top graph, bot is bottom graph

	setdataFolder root:Packages:StandardPlots
	string GraphName
	string Ename
	string Qname
	string IntName
	
	if (cmpstr(which,"top")==0)
		DoWindow/F IN2S_TopGraph
		GraphName="IN2S_TopGraph"
		Ename="TopEData"
		Qname="TopXData"
		IntName="TopYData"
	else
		DoWindow/F IN2S_BotGraph	
		GraphName="IN2S_BotGraph"
		Ename="BotEData"
		Qname="BotXData"
		IntName="BotYData"
	endif
	
	string WvAref=CsrWave(A, GraphName)
	string WvBref=CsrWave(B, GraphName)
	if (cmpstr(WvAref,WvBref)!=0)
		Abort "cursors are not on the same data"
	endif
	
	Wave IntWave=CsrWaveRef(A, GraphName)
	variable selectedSetNumber=str2num(WvAref[8,inf])	
	Wave EWave=$(Ename+num2str(selectedSetNumber))
	Wave QWave=$(Qname+num2str(selectedSetNumber))
	IntName+=num2str(selectedSetNumber)
	
	CurveFit line IntWave[pcsr(A),pcsr(B)] /X=QWave /W=EWave /I=1 /D 
	
	Wave FitWave=$("fit_"+IntName)
	
	string oldNote=note(IntWave)
	string oldComment=StringByKey("COMMENT", oldNote , "=")
	string newComment="Comment="+"Fitted on "+oldComment + ";Wname=Porod Fit"
	
	note FitWave, newComment
	
	Wave W_coef
	variable PorodConst=W_coef[0]
	variable background=W_coef[1]
	string Results="     Porod fit results: \r Porod constant : "+num2str(PorodConst)
	Results+="\r Background : "+num2str(background)
	variable attachTo=(pcsr(A)+pcsr(B))/2
	attachTo=floor(attachTo)
	attachTo=QWave[attachTo]
	Tag/C/N=PorodTag/F=0/S=3/L=2 $("fit_"+IntName), attachTo,Results
	
	IN2S_GraphLegendAndColors()
	
//	OK, here we are done with	the graph in which we were doing the fit.
//now let us see if we can put the data in other graphs

	string NextPlot
	string NextPlotType
	string NextGraphName
	string NextXwaveName
	string NextYwaveName
	SVAR PlotTypeOne
	SVAR PlotTypeTwo
	
	if (cmpstr(which,"Top")==0)
		NextPlot="Bot"
		NextGraphName="IN2S_BotGraph"
		NextPlotType=PlotTypeTwo
		NextXwaveName="BotXData"+num2str(selectedSetNumber)
		NextYwaveName="BotYData"+num2str(selectedSetNumber)
	else
		NextPlot="Top"
		NextGraphName="IN2S_TopGraph"
		NextPlotType=PlotTypeOne
		NextXwaveName="TopXData"+num2str(selectedSetNumber)
		NextYwaveName="TopYData"+num2str(selectedSetNumber)
	endif

	DoWindow/F $NextGraphName
	if (V_flag==0)
		abort
	endif
	
	Wave NextYwv=$NextYwaveName
	Wave NextXwv=$NextXwaveName
	string NewYwvName="Transferred"+NextYwaveName
	Duplicate/O NextYwv, $NewYwvName
	Wave NewYwv=$NewYwvName
	SVAR PlottedDataType=root:Packages:StandardPlots:DataTypeToPlot
	
	if (cmpstr(NextPlotType,"Int-Q")==0)

		NewYwv=(PorodConst/(NextXwv^3))+background
	
		if (cmpstr(PlottedDataType,"DSM_Int")==0)
			NewYwv=(PorodConst/(NextXwv^4))+background
		endif
		
		if (cmpstr(PlottedDataType,"M_DSM_Int")==0)
			NewYwv=(PorodConst/(NextXwv^4))+background
		endif
		
		RemoveFromGraph/Z  $NewYwvName
		AppendToGraph NewYwv vs NextXwv
			
	 	newComment="Comment="+"Fitted on "+oldComment + ";Wname= Transferred Porod Fit"
		note/K NewYwv
		note NewYwv, newComment

		IN2S_GraphLegendAndColors()
	endif
	
end


//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_AppendButtonsToGraphs(TopBot)
	string TopBot
	//this function appends buttons to graphs as needed
	//here we need to include buttons definitions for proper graph types
	setDataFolder  root:Packages:StandardPlots:
	SVAR PlotTypeOne
	SVAR PlotTypeTwo
	WAVE OrgQData0
	WAVE OrgIntData0
	
	if (cmpstr(TopBot,"Top")==0)
		if (cmpstr("Int-Q",PlotTypeOne)==0)
			// Append buttons definitions here
		endif
		if (cmpstr("SizeDist",PlotTypeOne)==0)
			// Append buttons definitions here
			Button SizeDistPanelTop,pos={70,1},size={100,20},proc=IN2S_PlotFitsBtnControl,title="Calculations Panel"				
		endif
		if (cmpstr("Porod",PlotTypeOne)==0)
			// Append buttons definitions here
			Button FitPorodTop,pos={89,23},size={50,20},proc=IN2S_PlotFitsBtnControl,title="Fit Porod"	
		endif		
		if (cmpstr("Guinier",PlotTypeOne)==0)
			Button FitGuinierTop,pos={89,23},size={60,20},proc=IN2S_PlotFitsBtnControl,title="Fit Guinier"	
//			IN2G_AppendGuinierTopWave("IN2S_TopGraph",ModQData0, ModIntData0,0,0,0)
			// Append buttons definitions here
		endif		
		if (cmpstr("Rg-Q",PlotTypeOne)==0)
			// Append buttons definitions here
		endif		
	endif
	if (cmpstr(TopBot,"Bot")==0)
		if (cmpstr("Int-Q",PlotTypeTwo)==0)
			// Append buttons definitions here
		endif
		if (cmpstr("SizeDist",PlotTypeTwo)==0)
			// Append buttons definitions here
			Button SizeDistPanelBot,pos={70,1},size={100,20},proc=IN2S_PlotFitsBtnControl,title="Calculations Panel"				
		endif
		if (cmpstr("Porod",PlotTypeTwo)==0)
			// Append buttons definitions here
			Button FitPorodBot,pos={89,23},size={50,20},proc=IN2S_PlotFitsBtnControl,title="Fit Porod"
		endif		
		if (cmpstr("Guinier",PlotTypeTwo)==0)
			Button FitGuinierBot,pos={89,23},size={60,20},proc=IN2S_PlotFitsBtnControl,title="Fit Guinier"
//			IN2G_AppendGuinierTopWave("IN2S_BotGraph",ModQData0, ModIntData0,0,0,0)
			// Append buttons definitions here
		endif		
		if (cmpstr("Rg-Q",PlotTypeTwo)==0)
			// Append buttons definitions here
		endif		
	endif
end

//**********************************************************************************
//**********************************************************************************
//**********************************************************************************

Function IN2S_FitGuinierFnct(which)
		string which 						//Top is top graph, bot is bottom graph

	setdataFolder root:Packages:StandardPlots
	string GraphName
	string Ename
	string Qname
	string IntName
	
	if (cmpstr(which,"top")==0)
		DoWindow/F IN2S_TopGraph
		GraphName="IN2S_TopGraph"
		Ename="TopEData"
		Qname="TopXData"
		IntName="TopYData"
	else
		DoWindow/F IN2S_BotGraph	
		GraphName="IN2S_BotGraph"
		Ename="BotEData"
		Qname="BotXData"
		IntName="BotYData"
	endif
	
	string WvAref=CsrWave(A, GraphName)
	string WvBref=CsrWave(B, GraphName)
	if (cmpstr(WvAref,WvBref)!=0)
		Abort "cursors are not on the same data"
	endif
	
	Wave IntWave=CsrWaveRef(A, GraphName)
	variable selectedSetNumber=str2num(WvAref[8,inf])	
	Wave EWave=$(Ename+num2str(selectedSetNumber))
	Wave QWave=$(Qname+num2str(selectedSetNumber))
	IntName+=num2str(selectedSetNumber)
	
	CurveFit line IntWave[pcsr(A),pcsr(B)] /X=QWave /I=1 /D 
	
	Wave FitWave=$("fit_"+IntName)
	
	string oldNote=note(IntWave)
	string oldComment=StringByKey("COMMENT", oldNote , "=")
	string newComment="Comment="+"Fitted on "+oldComment + ";Wname=Guinier Fit"
	
	note FitWave, newComment
	
	Wave W_coef
	Wave W_sigma
	variable LnInt=W_coef[0]
	variable Rgslope=W_coef[1]
	
	variable Int0=exp(LnInt)
	variable IntError=0.5*(abs(exp(LnInt+W_sigma[0])-Int0)+abs(exp(LnInt-W_sigma[0])-Int0))
	variable Rg=sqrt(-Rgslope*3)
	variable RgError=0.5*(abs(sqrt((-Rgslope+W_sigma[1])*3)-Rg)+abs(sqrt((-Rgslope-W_sigma[1])*3)-Rg))
	variable RgQmin=Rg*sqrt(QWave[pcsr(A)])
	variable RgQmax=Rg*sqrt(QWave[pcsr(B)])
	
	string Results="     Guinier fit results: \r I (q=0): "+num2str(Int0)+" +/-  "+num2str(IntError)
	Results+="\r Rg : "+num2str(Rg)+"  +/-  "+num2str(RgError)
	Results+="\r"+num2str(RgQmin)+ "< Rg * q < "+num2str(RgQmax)
	variable attachTo=(pcsr(A)+pcsr(B))/2
	attachTo=floor(attachTo)
	attachTo=QWave[attachTo]
	Tag/C/N=GuinierTag/F=0/S=3/L=2 $("fit_"+IntName), attachTo,Results
	
	IN2S_GraphLegendAndColors()
	
//	OK, here we are done with	the graph in which we were doing the fit.
//now let us see if we can put the data in other graphs

	string NextPlot
	string NextPlotType
	string NextGraphName
	string NextXwaveName
	string NextYwaveName
	SVAR PlotTypeOne
	SVAR PlotTypeTwo
	
	if (cmpstr(which,"Top")==0)
		NextPlot="Bot"
		NextGraphName="IN2S_BotGraph"
		NextPlotType=PlotTypeTwo
		NextXwaveName="BotXData"+num2str(selectedSetNumber)
		NextYwaveName="BotYData"+num2str(selectedSetNumber)
	else
		NextPlot="Top"
		NextGraphName="IN2S_TopGraph"
		NextPlotType=PlotTypeOne
		NextXwaveName="TopXData"+num2str(selectedSetNumber)
		NextYwaveName="TopYData"+num2str(selectedSetNumber)
	endif

	DoWindow/F $NextGraphName
	if (V_flag==0)
		abort
	endif
	
	Wave NextYwv=$NextYwaveName
	wavestats/Q NextYwv
	variable MinOnNextYwv=V_min
	Wave NextXwv=$NextXwaveName
	string NewYwvName="Transferred"+NextYwaveName
	Duplicate/O NextYwv, $NewYwvName
	Wave NewYwv=$NewYwvName
	
	if (cmpstr(NextPlotType,"Int-Q")==0)
		NewYwv=exp(lnInt + Rgslope*(NextXwv^2))
//		variable start=binarysearch(NewYwv,MinOnNextYwv)
		GetAxis/Q left
		variable start=binarysearch(NewYwv,V_min)
		NewYwv[start, inf]=NaN
		RemoveFromGraph/Z  $NewYwvName
		AppendToGraph NewYwv vs NextXwv
			
	 	newComment="Comment="+"Fitted on "+oldComment + ";Wname= Transferred Guinier Fit"
		note/K NewYwv
		note NewYwv, newComment

		IN2S_GraphLegendAndColors()
	endif
	
end


Function IN2S_FixPlotAxis(Which,SetReset)	//sets parameters and resets the axis before and after working on graph
		string Which, SetReset
		//Which can be Top or Bot; SetReset can be Set or Reset
	
	if (cmpstr(SetReset,"Set")==0)		//set parameters so we remember axis settings
		if (cmpstr(Which,"Top")==0)		//here it is top graph
			DoWindow IN2S_TopGraph
			if (V_flag)		//OK, window exists
				GetAxis/W=IN2S_TopGraph left
				variable/g TopLeftMax=V_max
				variable/g TopLeftMin=V_min
				GetAxis/W=IN2S_TopGraph bottom
				variable/g TopBottomMax=V_max
				variable/g TopBottomMin=V_min
			else				//does not exist, so lets kill the variables
				KillVariables/Z TopLeftMax, TopLeftMin, TopBottomMax, TopBottomMin
			endif
		else								//and here it is bottom graph
			DoWindow IN2S_BotGraph
			if (V_flag)		//OK, window exists
				GetAxis/W=IN2S_BotGraph left
				variable/g BotLeftMax=V_max
				variable/g BotLeftMin=V_min
				GetAxis/W=IN2S_BotGraph bottom
				variable/g BotBottomMax=V_max
				variable/g BotBottomMin=V_min
			else				//does not exist, so lets kill the variables
				KillVariables/Z BotLeftMax, BotLeftMin, BotBottomMax, BotBottomMin
			endif
		endif
	else						//here we need to reset the axis from parameters
		if (cmpstr(Which,"Top")==0)		//here it is top graph
			NVAR/Z TopLeftMax
			if (!NVAR_exists(TopLeftMax))		//check, that the parameters exist, assume if exists on, exist all
				return 0
			endif
			NVAR TopLeftMin
			NVAR TopBottomMin
			NVAR TopBottomMax
			DoWindow IN2S_TopGraph
			if (V_flag)		//OK, window exists
				SetAxis/W=IN2S_TopGraph left, TopLeftMin, TopLeftMax
				SetAxis/W=IN2S_TopGraph bottom, TopBottomMin, TopBottomMax				
			endif		
		else								//and here bottom graph
			NVAR/Z BotLeftMax
			if (!NVAR_exists(BotLeftMax))		//check, that the parameters exist, assume if exists on, exist all
				return 0
			endif
			NVAR BotLeftMin
			NVAR BotBottomMin
			NVAR BotBottomMax
			DoWindow IN2S_BotGraph
			if (V_flag)		//OK, window exists
				SetAxis/W=IN2S_BotGraph left, BotLeftMin, BotLeftMax
				SetAxis/W=IN2S_BotGraph bottom, BotBottomMin, BotBottomMax				
			endif		
		endif
	endif
end