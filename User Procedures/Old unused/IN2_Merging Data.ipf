#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.10



//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/



Function IN2M_MergeTwoDataSets()
	//this function merges two data sets and creates new folder with the merged data
	
	IN2M_InitializeMerging()	//creates folder and string for data
	DoWindow IN2M_MergeDataPanel
	if(V_Flag)
		DoWindow/F IN2M_MergeDataPanel
	else
		IN2M_SetupPanel()		//sets up panel for data merging 
	endif
	DoWindow IN2M_MergeGraph
	if(V_Flag)
		DoWindow/F IN2M_MergeGraph
	else
		Execute("IN2M_MergeGraph()")
	ENDIF
	IN2G_AutoAlignGraphAndPanel()
end




//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IN2M_SetupPanel()	//sets up panel for data merging

	execute("IN2M_MergeDataPanel()")

end

Window IN2M_MergeDataPanel() : Panel
	setDataFolder root:Packages:IN2Merge:
	
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(569.25,43.25,1002.75,467.75) as "MergeDataPanel"
	SetDrawLayer UserBack
	SetDrawEnv fillfgc= (40960,65280,16384)
	DrawRect 12,82,422,182
	SetDrawEnv fillfgc= (65280,43520,32768)
	DrawRect 12,200,422,300
	SetDrawEnv fsize= 16,fstyle= 5,textrgb= (52224,0,0)
	DrawText 154,27,"Merge Data panel"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 24,76,410,76
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 24,194,410,194
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 24,312,410,312
	SetDrawEnv fsize= 20,fstyle= 1,textrgb= (0,0,52224)
	DrawText 361,112,"Set 1"
	SetDrawEnv fsize= 20,fstyle= 1,textrgb= (0,0,52224)
	DrawText 363,228,"Set 2"
	SetDrawEnv fillfgc= (0,65280,0)
	SetDrawEnv save
	DrawText 297,42,"Set data 1 is used "
	DrawText 325,58,"as BASIC"
	DrawText 286,72,"to get eval. parameters "

	PopupMenu DataType,pos={38,45},size={212,21},proc=IN2M_ChangeMergeParameters,title="Data Type To Merge:"
	PopupMenu DataType,mode=1,popvalue=stringByKey("MergeDataType",MergeData,"="),value= #"\"R_Int;SMR_Int;DSM_Int;M_SMR_Int;M_DSM_Int\""
	PopupMenu MergeData1,pos={15,89},size={431,21},proc=IN2M_ChangeMergeParameters,title="Select Data Set 1 to merge"
	PopupMenu MergeData1,mode=1,popvalue="---",value= #"IN2M_ListTheFolders()"
	SetVariable Qoffset1,pos={20,124},size={180,16},proc=IN2M_ChangeMergeParamVal,title="Q offset for Data set 1:"
	SetVariable Qoffset1,limits={-Inf,Inf,0.0001},value= root:Packages:IN2Merge:QshiftOne
	SetVariable MultiplierOne,pos={20,152},size={180,16},proc=IN2M_ChangeMergeParamVal,title="Multiplier for one:"
	SetVariable MultiplierOne,limits={-Inf,Inf,0.1},value= root:Packages:IN2Merge:MultiplierOne
	SetVariable BackgroundOne,pos={235,152},size={180,16},proc=IN2M_ChangeMergeParamVal,title="Background :"
	SetVariable BackgroundOne,limits={-Inf,Inf,1},value= root:Packages:IN2Merge:BackgroundOne
	PopupMenu MergeData2,pos={15,207},size={431,21},proc=IN2M_ChangeMergeParameters,title="Data Set 2 to merge"
	PopupMenu MergeData2,mode=1,popvalue="---",value= #"IN2M_ListTheFolders()"
	SetVariable Qoffset2,pos={20,240},size={180,16},proc=IN2M_ChangeMergeParamVal,title="Q offset for Data set 2:"
	SetVariable Qoffset2,limits={-Inf,Inf,0.0001},value=root:Packages:IN2Merge:QshiftTwo
	SetVariable MultiplierTwo,pos={20,275},size={180,16},proc=IN2M_ChangeMergeParamVal,title="Multiplier for two:"
	SetVariable MultiplierTwo,limits={-Inf,Inf,0.1},value= root:Packages:IN2Merge:MultiplierTwo
	SetVariable BackgroundTwo,pos={235,275},size={180,16},proc=IN2M_ChangeMergeParamVal,title="Background :"
	SetVariable BackgroundTwo,limits={-Inf,Inf,1},value= root:Packages:IN2Merge:BackgroundTwo
	PopupMenu SelectSubfolder,pos={11,325},size={219,21},proc=IN2M_ChangeMergeParameters,title="Select subfolder for the new data:"
	PopupMenu SelectSubfolder,mode=1,popvalue="---",value= #"\"---;\"+IN2M_ListOfFldrsInUSAXS()"
	SetVariable SelNewFolderNm,pos={19,360},size={400,16},proc=IN2M_ChangeMergeParamVal,title="Create fldr name for new data:"
	SetVariable SelNewFolderNm,limits={-Inf,Inf,1},value= root:Packages:IN2Merge:MergedFolderName
	Button DoMerge,pos={25,392},size={120,20},proc=IN2M_DoTheMerge,title="Do the Merge"
	Button KillThePanel,pos={336,390},size={80,20},proc=IN2M_ExitMerging,title="Exit"
	Button ClearGraph,pos={180,391},size={120,20},proc=IN2M_ClearGraph,title="Clear graph"
	Button TrimOne,pos={235,120},size={75,20},proc=IN2M_TrimData,title="Trim Data"
	Button TrimTwo,pos={235,238},size={75,20},proc=IN2M_TrimData,title="Trim Data"

EndMacro

Function IN2M_TrimData(ctrlName) : ButtonControl
	String ctrlName
	
	WAVE FirstColorWave
	WAVE SecondColorWave
	variable Start=pcsr(A)
	variable End1=pcsr(B)
	variable temp
	if (Start>End1)
		temp=Start
		Start=End1
		End1=temp
	endif
	
	if (cmpstr(ctrlname,"TrimOne")==0)
		if (cmpstr(CsrWave(A),"FirstIntModified")!=0)
			Abort "Cursor A is not on Set1"
		endif	
		if (cmpstr(CsrWave(B),"FirstIntModified")!=0)
			Abort "Cursor B is not on Set1"
		endif	
		FirstColorWave=5
		FirstColorWave[0,Start]=9
		FirstColorWave[End1,numpnts(FirstColorWave)-1]=9
	endif
	if (cmpstr(ctrlname,"TrimTwo")==0)
		if (cmpstr(CsrWave(A),"SecondIntModified")!=0)
			Abort "Cursor A is not on Set2"
		endif	
		if (cmpstr(CsrWave(B),"SecondIntModified")!=0)
			Abort "Cursor B is not on Set2"
		endif
		SecondColorWave=1.2	
		SecondColorWave[0,Start]=9
		SecondColorWave[End1,numpnts(FirstColorWave)-1]=9
	endif
//here goes trimming the data
End


Function/S IN2M_ListOfFldrsInUSAXS()

	return IN2G_CreateListOfItemsInFolder("root:USAXS",1)
end
Function IN2M_DoTheMerge(ctrlName) : ButtonControl
	String ctrlName
	//here goes what is do to do the Merge
	
	SetDataFolder root:Packages:IN2Merge:
	
	Wave FirstIntModified
	Wave FirstQModified
	Wave FirstEModified
	Wave FirstColorWave
	Wave SecondIntModified
	Wave SecondQModified
	Wave SecondEModified
	Wave SecondColorWave
	
	SVAR MergeData
	SVAR MergedFolderName
	SVAR MergedDataSubfolder
	
	string NewDataFldr="root:USAXS:"
	string DataType=stringByKey("MergeDataType", MergeData,"=")
	
	if (cmpstr(MergedDataSubfolder,"---")!=0)
		NewDataFldr=NewDataFldr+PossiblyQuoteName(MergedDataSubfolder)+":"
	endif
	
	SetDataFolder $NewDataFldr
	
	if (DataFolderExists(MergedFolderName))
		Abort "The folder exists, should not!"
	endif
	
	NewDataFolder/S $MergedFolderName
	
	string NewIntName=DataType
	string NewQName
	string NewEName
	
	strswitch(DataType)	// string switch
	case "R_Int":		// execute if case matches expression
		NewQName="R_Qvec"
		NewEName="R_error"
		break					// exit from switch
	case "SMR_Int":		// execute if case matches expression
		NewQName="SMR_Qvec"
		NewEName="SMR_error"
		break
	case "DSM_Int":		// execute if case matches expression
		NewQName="DSM_Qvec"
		NewEName="DSM_error"
		break
	case "M_SMR_Int":		// execute if case matches expression
		NewQName="M_SMR_Qvec"
		NewEName="M_SMR_error"
		break
	case "M_DSM_Int":		// execute if case matches expression
		NewQName="M_DSM_Qvec"
		NewEName="M_DSM_error"
		break
	default:								// optional default expression executed
		Abort "This should not happen"				// when no case matches
	endswitch
	
	
	variable numPoints1 = numpnts(FirstIntModified)
	variable numPoints2 = numpnts(SecondIntModified)
	variable i
	For (i=0;i<numPoints1;i+=1)
		if (FirstColorWave[i]>8)
			FirstIntModified[i]=NaN
		endif
	endfor	
	For (i=0;i<numPoints1;i+=1)
		if (SecondColorWave[i]>8)
			SecondIntModified[i]=NaN
		endif
	endfor		
	IN2G_RemoveNaNsFrom3Waves(FirstIntModified,FirstQModified,FirstEModified)
	IN2G_RemoveNaNsFrom3Waves(SecondIntModified,SecondQModified,SecondEModified)
	
	Duplicate/O FirstIntModified, $NewIntName
	Duplicate/O FirstQModified, $NewQName
	Duplicate/O FirstEModified, $NewEName
	Wave NewInt=$NewIntName
	Wave NewQ=$NewQName
	Wave NewE=$NewEName

	numPoints1 = numpnts(FirstIntModified)
	numPoints2 = numpnts(SecondIntModified)
	Redimension/N=(numPoints1 + numPoints2) NewInt, NewQ, NewE
	
	NewInt [numPoints1, ] = SecondIntModified[p-numPoints1]
	NewQ[numPoints1, ] = SecondQModified[p-numPoints1] 
	NewE[numPoints1, ] = SecondEModified[p-numPoints1]
	
	Sort  NewQ, NewQ, NewInt, NewE
	
	IN2G_AppendStringToWaveNote(NewIntName,MergeData)
	IN2G_AppendStringToWaveNote(NewQName,MergeData)
	IN2G_AppendStringToWaveNote(NewEName,MergeData)
	
End

Function IN2M_ClearGraph(ctrlName) : ButtonControl
	String ctrlName

	//here goes procedure which clears the graph of all junk
	DoWindow /K IN2M_MergeGraph
	//kill the graph
	SetDataFolder root:Packages:IN2Merge
	KillWaves/Z /A
	DoWindow /K IN2M_MergeDataPanel
	
	IN2M_SetupPanel()		//sets up panel for data merging 

	Execute("IN2M_MergeGraph()")
	IN2G_AutoAlignGraphAndPanel()
	SVAR MergeData
	MergeData=ReplaceStringByKey("MergeFolderOne", MergeData, "","=",";")
	MergeData=ReplaceStringByKey("MergeFolderTwo", MergeData, "","=",";")
End

Function IN2M_ExitMerging(ctrlName) : ButtonControl
	String ctrlName

	//here we clear all the graphs and panel
      dowindow /K IN2M_MergeGraph
	if (strlen(WinList("IN2M_MergeDataPanel",";","WIN:64"))>0)	//Kills the controls when not needed anymore
			DoWindow/K  IN2M_MergeDataPanel
	endif

	SetDataFolder root:Packages:IN2Merge
	KillWaves /A
	SVAR MergeData
	MergeData=ReplaceStringByKey("MergeFolderOne", MergeData, " ","=",";")
	MergeData=ReplaceStringByKey("MergeFolderTwo", MergeData, " ","=",";")
//	MergeDataType=R_Int;MergeFolderOne=root:USAXS:'1216':S18_2A1WP:;MergeFolderTwo=root:USAXS:'1216':S21_5AP5WP:

End
//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************


Function IN2M_InitializeMerging()
	//this function creates needed data structure for merging to work properly
	
	NewDataFolder/O root:Packages			//create working folder, if needed
	NewDataFolder/O root:Packages:IN2Merge
	
	SetDataFolder root:Packages:IN2Merge
	string/g MergeData="MergeDataType=R_Int;MergeFolderOne=;MergeFolderTwo=;QshiftOne=0;"
	MergeData+="MultiplierOne=1;BackgroundOne=0;QshiftTwo=0;MultiplierTwo=1;BackgroundTwo=0;"
	string/G MergedFolderName=""
	
	SVAR/Z MergedDataSubfolder
	if (!SVAR_Exists(MergedDataSubfolder))
		string/G MergedDataSubfolder=""
	endif
	

	NVAR/Z QshiftOne
	NVAR/Z MultiplierOne
	NVAR/Z BackgroundOne
	NVAR/Z QshiftTwo
	NVAR/Z MultiplierTwo
	NVAR/Z BackgroundTwo
	
	if (!NVAR_Exists(QshiftOne))
		variable/G QshiftOne=0
	endif
	if (!NVAR_Exists(MultiplierOne))
		variable/G MultiplierOne=1
	endif
	if (!NVAR_Exists(BackgroundOne))
		variable/G BackgroundOne=0
	endif
	if (!NVAR_Exists(QshiftTwo))
		variable/G QshiftTwo=0
	endif
	if (!NVAR_Exists(MultiplierTwo))
		variable/G MultiplierTwo=1
	endif
	if (!NVAR_Exists(BackgroundTwo))
		variable/G BackgroundTwo=0
	endif
end	

//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************



Function IN2M_ChangeMergeParameters(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	setDataFolder root:Packages:IN2Merge:
	
	SVAR MergeData
	if (cmpstr(ctrlName,"DataType")==0)
		MergeData=replaceStringByKey("MergeDataType",MergeData, popStr,"=")	
		MergeData=replaceStringByKey("MergeFolderOne",MergeData, "---","=")
		MergeData=replaceStringByKey("MergeFolderTwo",MergeData, "---","=")
		PopupMenu MergeData1,mode=1,popvalue="---"
		PopupMenu MergeData2,mode=1,popvalue="---"
	endif
	if (cmpstr("MergeData1",ctrlName)==0)
		MergeData=replaceStringByKey("MergeFolderOne",MergeData, popStr,"=")
		IN2M_CopyData()
		IN2M_UpdateWaves()
	endif
	if (cmpstr("MergeData2",ctrlName)==0)
		MergeData=replaceStringByKey("MergeFolderTwo",MergeData, popStr,"=")
		IN2M_CopyData()
		IN2M_UpdateWaves()
	endif
	if (cmpstr("SelectSubfolder",ctrlName)==0)
		SVAR MergedDataSubfolder
		if (cmpstr("---",popstr)!=0)
			MergedDataSubfolder=popStr
		endif
		SVAR MergedFolderName
		string varStr1=MergedFolderName
		if (strlen(varStr1)>0)
			IN2M_UpdateFolderName(varStr1)
		endif
	endif

End


Function/S IN2M_ListTheFolders()
	setDataFolder root:Packages:IN2Merge
	SVAR MergeData
	return IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, (stringByKey("MergeDataType",MergeData,"=")), 1)
end

Function IN2M_ChangeMergeParamVal(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	setDataFolder root:Packages:IN2Merge:
	SVAR MergeData
	SVAR MergedFolderName
	NVAR QshiftOne
	NVAR MultiplierOne
	NVAR BackgroundOne
	NVAR QshiftTwo
	NVAR MultiplierTwo
	NVAR BackgroundTwo

	if (cmpstr("Qoffset1",ctrlName)==0)
		MergeData=replaceStringByKey("QshiftOne",MergeData,num2str(varNum),"=")
		QshiftOne=varNum
		IN2M_UpdateWaves()
	endif
	if (cmpstr("MultiplierOne",ctrlName)==0)
		MergeData=replaceStringByKey("MultiplierOne",MergeData,num2str(varNum),"=")
		MultiplierOne=varNum
		IN2M_UpdateWaves()
	endif
	if (cmpstr("BackgroundOne",ctrlName)==0)
		MergeData=replaceStringByKey("BackgroundOne",MergeData,num2str(varNum),"=")
		BackgroundOne=varNum
		IN2M_UpdateWaves()
	endif
	if (cmpstr("Qoffset2",ctrlName)==0)
		MergeData=replaceStringByKey("QshiftTwo",MergeData,num2str(varNum),"=")
		QshiftTwo=varNum
		IN2M_UpdateWaves()
	endif
	if (cmpstr("MultiplierTwo",ctrlName)==0)
		MergeData=replaceStringByKey("MultiplierTwo",MergeData,num2str(varNum),"=")
		MultiplierTwo=varNum
		IN2M_UpdateWaves()
	endif
	if (cmpstr("BackgroundTwo",ctrlName)==0)
		MergeData=replaceStringByKey("BackgroundTwo",MergeData,num2str(varNum),"=")
		BackgroundTwo=varNum
		IN2M_UpdateWaves()
	endif
	if (cmpstr("SelNewFolderNm",ctrlname)==0)
		IN2M_UpdateFolderName(varStr)
//		string dfold=GetDataFolder(1)
//		string NewPlace="root:USAXS:"
//		SVAR MergedDataSubfolder
//		if (cmpstr("--",MergedDataSubfolder)!=0)
//			NewPlace+=MergedDataSubfolder
//		endif
//		setDataFolder $NewPlace
//		if (CheckName(varStr,11)!=0)
//			MergedFolderName=CleanupName(uniquename(varStr,11,0),1)
//		else
//			MergedFolderName=varStr
//		endif
//		setdataFolder dfold
	endif

End

Function IN2M_UpdateFolderName(varStr)
	string varStr
		SVAR MergedFolderName
		string dfold=GetDataFolder(1)
		string NewPlace="root:USAXS:"
		SVAR MergedDataSubfolder
		if (cmpstr("--",MergedDataSubfolder)!=0)
			NewPlace+=PossiblyQuoteName(MergedDataSubfolder)
		endif
		setDataFolder $NewPlace
		if (CheckName(varStr,11)!=0)
			MergedFolderName=CleanupName(uniquename(varStr,11,0),1)
		else
			MergedFolderName=varStr
		endif
		setdataFolder dfold
end

Function IN2M_CopyData()

	SetDataFolder root:Packages:IN2Merge
	
	SVAR MergeData
	string DataType=stringByKey("MergeDataType",MergeData,"=")
	string MergeFolderOne=stringByKey("MergeFolderOne",MergeData,"=")
	string MergeFoldertwo=stringByKey("MergeFoldertwo",MergeData,"=")

	string DataQ
	string DataE

	strswitch(DataType)	// string switch
	case "R_Int":		// execute if case matches expression
		DataQ="R_Qvec"
		DataE="R_error"
		break					// exit from switch
	case "SMR_Int":		// execute if case matches expression
		DataQ="SMR_Qvec"
		DataE="SMR_error"
		break
	case "DSM_Int":		// execute if case matches expression
		DataQ="DSM_Qvec"
		DataE="DSM_error"
		break
	case "M_SMR_Int":		// execute if case matches expression
		DataQ="M_SMR_Qvec"
		DataE="M_SMR_error"
		break
	case "M_DSM_Int":		// execute if case matches expression
		DataQ="M_DSM_Qvec"
		DataE="M_DSM_error"
		break
	default:								// optional default expression executed
		Abort "This should not happen"				// when no case matches
	endswitch
	
	if ((strlen(MergeFolderOne)!=0) && cmpstr(MergeFolderOne,"---")!=0)
		WAVE FirstInt=$(MergeFolderOne+DataType)
		WAVE FirstQ=$(MergeFolderOne+DataQ)
		WAVE FirstE=$(MergeFolderOne+DataE)
		Duplicate/O  FirstInt, root:Packages:IN2Merge:IntFirstOriginal
		WAVE IntFirstOriginal =root:Packages:IN2Merge:IntFirstOriginal
		Duplicate/O  FirstQ, root:Packages:IN2Merge:QFirstOriginal
		WAVE QFirstOriginal=root:Packages:IN2Merge:QFirstOriginal
		Duplicate/O  FirstE, root:Packages:IN2Merge:EFirstOriginal
		WAVE EFirstOriginal=root:Packages:IN2Merge:EFirstOriginal
		Duplicate/O IntFirstOriginal, FirstIntModified
		Duplicate/O QFirstOriginal, FirstQModified
		Duplicate/O EFirstOriginal, FirstEModified
		Duplicate/O IntFirstOriginal, FirstColorWave
		FirstColorWave=5
	endif

	if ((strlen(MergeFolderTwo)!=0) && cmpstr(MergeFolderTwo,"---")!=0)
		WAVE SecondInt=$(MergeFolderTwo+DataType)
		WAVE SecondQ=$(MergeFolderTwo+DataQ)
		WAVE SecondE=$(MergeFolderTwo+DataE)
		Duplicate/O  SecondInt, root:Packages:IN2Merge:IntSecondOriginal
		WAVE IntSecondOriginal=root:Packages:IN2Merge:IntSecondOriginal
		Duplicate/O  SecondQ, root:Packages:IN2Merge:QSecondOriginal
		WAVE QSecondOriginal=root:Packages:IN2Merge:QSecondOriginal
		Duplicate/O  SecondE, root:Packages:IN2Merge:ESecondOriginal
		WAVE ESecondOriginal=root:Packages:IN2Merge:ESecondOriginal
		Duplicate/O IntSecondOriginal, SecondIntModified
		Duplicate/O QSecondOriginal, SecondQModified
		Duplicate/O ESecondOriginal, SecondEModified
		Duplicate/O IntSecondOriginal, SecondColorWave
		SecondColorWave=1.2
	endif
	
	IN2M_UpdateWaves()
	DoWindow/K IN2M_MergeGraph
	Execute("IN2M_MergeGraph()")
	IN2G_AutoAlignGraphAndPanel()

end

Function IN2M_UpdateWaves()

	SVAR MergeData
	
	WAVE/Z IntFirstOriginal
	WAVE/Z QFirstOriginal
	WAVE/Z EFirstOriginal

	WAVE/Z IntSecondOriginal
	WAVE/Z QSecondOriginal
	WAVE/Z ESecondOriginal
	
	if(!WaveExists(IntFirstOriginal) || !WaveExists(IntSecondOriginal) )
		return 1
	endif
	WAVE FirstIntModified
	WAVE FirstQModified
	WAVE FirstEModified

	WAVE SecondIntModified
	WAVE SecondQModified
	WAVE SecondEModified

	if (WAVEexists(FirstIntModified))	
		FirstIntModified=(numberByKey("MultiplierOne",MergeData,"="))*(IntFirstOriginal-numberByKey("BackgroundOne",MergeData,"="))
		FirstQModified = QFirstOriginal - numberByKey("QshiftOne",MergeData,"=")
		FirstEModified = EFirstOriginal *numberByKey("MultiplierOne",MergeData,"=")
	endif

	if (WAVEexists(SecondIntModified))	
		SecondIntModified=(numberByKey("MultiplierTwo",MergeData,"="))*(IntSecondOriginal-numberByKey("BackgroundTwo",MergeData,"="))
		SecondQModified = QSecondOriginal- numberByKey("QshiftTwo",MergeData,"=")
		SecondEModified = ESecondOriginal *numberByKey("MultiplierTwo",MergeData,"=")
	endif
end

Function IN2M_RemovePointWithCursorA(ctrlname) : Buttoncontrol			// Removes point in wave
	string ctrlname
	
	variable pointNumberToBeRemoved=xcsr(A)				//this part should be done always
		Wave FixMe=CsrWaveRef(A)
		FixMe[pointNumberToBeRemoved]=NaN
																//if we need to fix more waves, it can be done here
		cursor/P A, $CsrWave(A), pointNumberToBeRemoved+1		//set the cursor to the right so we do not scare user
End

Window IN2M_MergeGraph() : Graph
	PauseUpdate; Silent 1		// building window...
	SetDataFolder root:Packages:IN2Merge:
	Display /k=1 /W=(0.3*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("heigth"),50*IN2G_ScreenWidthHeight("width"),70*IN2G_ScreenWidthHeight("height"))  as "Merging Graph"	
	if (exists("FirstIntModified")==1)
		AppendToGraph FirstIntModified vs FirstQModified 
		ErrorBars FirstIntModified Y,wave=(FirstEModified,FirstEModified)
		ModifyGraph zColor(FirstIntModified)={FirstColorWave,0,10,Rainbow}
	endif
	if (exists("SecondIntModified")==1)
		AppendToGraph SecondIntModified vs SecondQModified
		ErrorBars SecondIntModified Y,wave=(SecondEModified,SecondEModified)
		ModifyGraph zColor(SecondIntModified)={SecondColorWave,0,10,Rainbow}
	endif
	ModifyGraph/Z margin(top)=50
	ModifyGraph/Z mode=3, gaps=0
	ModifyGraph/Z marker(FirstIntModified)=19,marker(SecondIntModified)=17
	ModifyGraph/Z rgb(FirstIntModified)=(16384,65280,16384),rgb(SecondIntModified)=(65280,43520,0)
	ModifyGraph/Z msize=1
	ModifyGraph/Z log=1
	ModifyGraph/Z font="Times New Roman"
	ModifyGraph/Z minor=1
	ModifyGraph/Z fSize=12
	ModifyGraph mirror=1
	Label/Z left "Intensity"
	Label/Z bottom "Q vector"
	IN2G_GenerateLegendForGraph(10,1,1)
	showinfo												//shows info
	ShowTools/A											//show tools
	Button KillThisWindow pos={10,10}, size={100,25}, title="Kill window", proc=IN2G_KillGraphsAndTables
	Button ResetWindow pos={120,10}, size={100,25}, title="Reset window", proc=IN2G_ResetGraph
	Button RemovePoint pos={240,10}, size={100,25}, title="RmvPnt(csrA)", proc=IN2M_RemovePointWithCursorA

EndMacro
