#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.01


//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.01 changed from CursorMovedHook to window hook function to avoid conflicts.

//Here we provide user with way to subtract data from DSM or M_DSM waves in Indra 2
//requested by Andrew Allen on 2/01/2003



Function IN2Q_SubtractBackground()
		
	IN2G_UniversalFolderScan("root:USAXS:", 5, "IN2G_CheckTheFolderName()")  //here we fix the folder names/sample names in wave notes if necessary
	IN2Q_SelectBckgSubtrData()			//user select folder, in which are data from which he wants to subtract background
	IN2Q_GetBckgSubtrParameters()		//select data and try to start properly the background subtraction
	IN2Q_TrimTheData()						//calls next routine to trim the data
			PauseForUser TrimGraphForBckgSbtr				//wait for end of trim procedure
	IN2Q_SubtractTheBackground()			//here we find way to claculate background
	
end

//reuse functions from desmearing and else as much as can be done
//***************************    Part 1   *******************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IN2Q_SelectBckgSubtrData()			//This procedure just sets folder where are the data
	
	string df
	Prompt df, "Select folder with data to subtract background for", popup, IN2Q_NextBckgDataToDo()+";"+IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, "*DSM_Int", 1)+";---;"+IN2G_FindFolderWithWaveTypes("root:", 10, "*", 1)
	DoPrompt "Subtract background folder selection", df
	if (V_Flag)
		Abort 
	endif	
			
	SetDataFolder df
	SVAR CurrentDSM=root:Packages:SubtrBckgWorkFldr:CurrentBckgFolder
	CurrentDSM = df
	IN2G_AppendAnyText("Background subtraction procedure started for  :"+ df)

end
 
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function/T IN2Q_NextBckgDataToDo()					//this returns next Folder in order to evaluate 

	string ListOfData=IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, "*DSM_Int", 1)	
	SVAR/Z LastBkg=root:Packages:SubtrBckgWorkFldr:CurrentBckgFolder	//global string for current folder info
	if (!SVAR_Exists(LastBkg))
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:SubtrBckgWorkFldr
		string/g root:packages:SubtrBckgWorkFldr:CurrentBckgFolder		//create if nesessary
		SVAR LastBkg=root:Packages:SubtrBckgWorkFldr:CurrentBckgFolder
		LastBkg=""
	endif
	variable start=FindListItem(LastBkg, ListOfData)
	if (start==-1)
		return StringFromList(0,ListOfdata)
	else
		ListOfdata=ListOfData[start,inf]
		return StringFromList(1,ListOfdata)
	endif
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
 //******Part 2/6********************************
Function IN2Q_GetBckgSubtrParameters()		//***************input IntwaveL,QwaveL,EwaveL,SelectedFunction,LslitLength,QminToE
	
	if (!DataFolderExists("root:Packages:SubtrBckgWorkFldr:"))
		NewDataFolder root:Packages:SubtrBckgWorkFldr		//create Desmear folder, if it does not exist
	endif

//	SVAR MeasurementParameters
	SVAR/Z BckgSubtrParam
	if (!SVAR_Exists(BckgSubtrParam))
		string/g BckgSubtrParam=""
		SVAR BckgSubtrParam
	endif
	SVAR/Z BckgSubtrParamW=root:Packages:SubtrBckgWorkFldr:BckgSubtrParamW
	if (!SVAR_Exists(BckgSubtrParamW))
		string/g root:Packages:SubtrBckgWorkFldr:BckgSubtrParamW=""
		SVAR BckgSubtrParamW=root:Packages:SubtrBckgWorkFldr:BckgSubtrParamW
	endif	
	NVAR/Z FixedBackground=root:Packages:SubtrBckgWorkFldr:FixedBackground
	if (!NVAR_Exists(FixedBackground))
		variable/g root:Packages:SubtrBckgWorkFldr:FixedBackground=0
		NVAR FixedBackground=root:Packages:SubtrBckgWorkFldr:FixedBackground
	endif	
	variable/g root:Packages:SubtrBckgWorkFldr:UserSavedData
	NVAR UserSavedData=root:Packages:SubtrBckgWorkFldr:UserSavedData
	UserSavedData=0
	
	FixedBackground=NumberByKey("FixedBackground", BckgSubtrParamW,"=")
	if (numtype(FixedBackground)!=0)
		FixedBackground=0
	endif
	
	variable QminToE=numberByKey("QToStartExtrap",BckgSubtrParamW,"=")
	string SelectedFunction=stringByKey("BckgFunction",BckgSubtrParamW,"=")
	if (strlen(SelectedFunction)<1)		//no function selected yet
		SelectedFunction="flat"
	endif
	if (numtype(QminToE)==2)			//no Q min selected yet
		QminToE = 0.1
	endif
		

	string IntwaveL, QwaveL, EwaveL

	Prompt IntwaveL, "Which wave contains Intensity from which subtract Background?", popup, IN2Q_FindSMRwave("DSM_Int")+";"+WaveList("*", ";", "")
	Prompt QwaveL, "Which wave contains Q data?", popup, IN2Q_FindSMRwave("DSM_Qvec")+";"+WaveList("*", ";", "")
	Prompt SelectedFunction, "What function use for background fitting?", popup, SelectedFunction+";constant;flat;linear;Porod;PowerLaw w flat;"		//
	Prompt EwaveL, "Which wave contains errors?", popup, IN2Q_FindSMRwave("DSM_Error")+";"+WaveList("*", ";", "")	//StrVarOrDefault("SelectedFunction","flat")
	
	DoPrompt "Select parameters for desmearing", IntwaveL, QwaveL, EwaveL
	
	
	if (V_flag)
		Abort 
	endif
	//here we record the name of the Intensity wave name so we can figure out later on what was input
	BckgSubtrParam=ReplaceStringByKey("IntensityWvNm",BckgSubtrParam,IntwaveL,"=")
	BckgSubtrParam=ReplaceStringByKey("QvectorWvNm",BckgSubtrParam,QwaveL,"=")
	BckgSubtrParam=ReplaceStringByKey("ErrorWvNm",BckgSubtrParam,EwaveL,"=")
	
	string dFsaveL=GetDataFolder(1)				//get the forlder where we are
	IntwaveL=dFsaveL+IntwaveL				//create proper pointers to the data we want ot desmear 
	QwaveL=dFsaveL+QwaveL
	EwaveL=dFsaveL+EwaveL

	BckgSubtrParam=ReplaceStringByKey("Intensity",BckgSubtrParam,IntwaveL,"=")
	BckgSubtrParam=ReplaceStringByKey("Qvector",BckgSubtrParam,QwaveL,"=")
	BckgSubtrParam=ReplaceStringByKey("Error",BckgSubtrParam,EwaveL,"=")
	BckgSubtrParam=ReplaceStringByKey("DataSource",BckgSubtrParam,dFsaveL,"=")
	BckgSubtrParam=ReplaceStringByKey("BckgFunction",BckgSubtrParam,SelectedFunction,"=")
	
	setDataFolder root:Packages:SubtrBckgWorkFldr:					//Go to desmear folder

	IN2G_AppendAnyText("List of desmearing parameters used :\r"+BckgSubtrParam)

	BckgSubtrParamW=BckgSubtrParam
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function/T IN2Q_FindSMRwave(str)
	string str
	
	string str1=WaveList("M_"+str+"*",";","")
	string str2=WaveList(str+"*",";","")

	if (strlen(str1)>0)
		return str1+";"+str2
	else
		return str2
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//******Part 3/6********************************
Function IN2Q_TrimTheData()							//this function trims the data before desmearing.

	//root:Packages:SubtrBckgWorkFldr:BckgSubtrParamW	
	SVAR BckgSubtrParamW
	string IntwaveL, QwaveL, EwaveL 
	IntwaveL=stringByKey("Intensity",BckgSubtrParamW,"=")
	QwaveL= stringByKey("Qvector",BckgSubtrParamW,"=")
	EwaveL=stringByKey("Error",BckgSubtrParamW,"=")
	Wave Intensity = $IntwaveL
	Wave Qvector = $QwaveL
	Wave Error = $EwaveL 
	
	Duplicate/O Intensity, OrgIntwave
	Duplicate/O Qvector, OrgQwave
	Duplicate/O Error, OrgEwave
	
	IN2G_ReplaceNegValsByNaNWaves(OrgIntWave,OrgQwave,OrgEwave)		//here we remove negative values by setting them to NaNs
	IN2G_RemoveNaNsFrom3Waves(OrgIntWave,OrgQwave,OrgEwave)			//and here we remove NaNs all together

	PauseUpdate; Silent 1		// building window...
	Display/K=1 /W=(0.3*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("heigth"),60*IN2G_ScreenWidthHeight("width"),70*IN2G_ScreenWidthHeight("height")) OrgIntwave vs OrgQwave as "Trim the data"
	DoWindow/C TrimGraphForBckgSbtr 
	ModifyGraph mode=4,margin(top)=100, mirror=1, minor=1
	showinfo												//shows info
	ShowTools/A											//show tools
	cursor/P A, OrgIntwave, (BinarySearch(OrgQwave, 0.00015)+1)
	cursor/P B, OrgIntwave, (numpnts(OrgIntwave)-1)
	ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
	Button KillThisWindow pos={10,10}, size={100,25}, title="Kill window", proc=IN2G_KillGraphsTablesEnd
	Button ResetWindow pos={10,40}, size={100,25}, title="Reset window", proc=IN2G_ResetGraph
	ModifyGraph mode=3
	ModifyGraph log=1
	Label left "Intensity"
	Label bottom "Q vector"
	Button TrimData , pos={140, 10}, proc=IN2Q_Trim,title="Trim"
	Button TrimData size={100,25}
	Button KillTopGraph , pos={140, 40}, proc=IN2G_KillTopGraph,title="Continue"
	Button KillTopGraph size={100,25}
	Button RemovePointDSM pos={0,100}, size={140,20}, title="Remove pnt w/csrA", proc=IN2G_RemovePointWithCursorA
	ResumeUpdate
	ModifyGraph width=0, height=0
end	
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IN2Q_Trim(ctrlName) : ButtonControl
	String ctrlName
	
	variable AP=pcsr (A)
	variable BP=pcsr (B)
	
	deletePoints 0, AP, OrgIntwave, OrgQwave, OrgEwave
	variable newLength=numpnts(OrgIntwave)
	deletePoints (BP-AP+1), (newLength), OrgIntwave, OrgQwave, OrgEwave
	cursor/P A, OrgIntwave, 0
	cursor/P B, OrgIntwave, (numpnts(OrgIntwave)-1)

End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//******Part 4/6********************************
Function IN2Q_SubtractTheBackground()

	//root:Packages:SubtrBckgWorkFldr:BckgSubtrParamW	

	Wave OrgIntwave
	Wave OrgQwave
	Wave OrgEwave
	SVAR BckgSubtrParamW
	NVAR FixedBackground=root:Packages:SubtrBckgWorkFldr:FixedBackground
	
	Variable/G BckgStartQ=numberByKey("QToStartExtrap", BckgSubtrParamW, "=")
	String/G BackgroundFunction=stringByKey("BckgFunction", BckgSubtrParamW, "=")
	
	Duplicate/O OrgIntwave, BlaIntwave, ColorWave, BlaIntOutputwave
	Duplicate/O OrgQwave, BlaQwave
	Duplicate/O OrgEwave, BlaErrWave
	ColorWave=0				//make the colors to be one, this will change later...
	variable/G numOfPoints=numpnts(OrgQwave)
	
	PauseUpdate; Silent 1		// building window...
	Display/K=1 /W=(0.3*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("heigth"),60*IN2G_ScreenWidthHeight("width"),70*IN2G_ScreenWidthHeight("height")) BlaIntwave vs BlaQwave as "Check bckg functions sel."
	AppendToGraph BlaIntOutputwave vs BlaQwave
	DoWindow/C BckgSubtCheckGraph1 
	SetWindow BckgSubtCheckGraph1, hook(MyHook) = IN2Q_CheckBckgExtHook	// Install window hook
	ModifyGraph mode=4,	margin(top)=100, mirror=1, minor=1
	ModifyGraph marker(BlaIntwave)=8
	ModifyGraph rgb(BlaIntOutputwave)=(0,0,0)
	ModifyGraph marker(BlaIntOutputwave)=26
	ModifyGraph zColor(BlaIntwave)={ColorWave,0,2,Rainbow}
	showinfo												//shows info
	ShowTools/A											//show tools
	ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
	Button KillThisWindow pos={10,10}, size={100,25}, title="Kill window", proc=IN2G_KillGraphsTablesEnd
	Button ResetWindow pos={10,40}, size={100,25}, title="Reset window", proc=IN2G_ResetGraph
	ModifyGraph mode=3
	ModifyGraph log=1
	Label left "Intensity"
	Label bottom "Q vector"
	ShowTools
//	SetVariable BackgroundStart,pos={10,80},size={300,18},proc=IN2Q_RecalcBkg,title="Start Bckg fitting at Q:   "
//	SetVariable BackgroundStart,limits={0,100,0},noedit=1,value= root:Packages:SubtrBckgWorkFldr:BckgStartQ
	SetVariable FixedBackground,pos={165,80},size={190,18},proc=IN2Q_RecalcBkg,title="Fixed Bckg value:   "
	SetVariable FixedBackground,limits={0,inf,(FixedBackground/10)},noedit=abs(cmpstr(BackgroundFunction,"constant")),value= root:Packages:SubtrBckgWorkFldr:FixedBackground
	PopupMenu BackgroundFnct,pos={130,50},size={178,21},proc=IN2Q_ChangeBkgFunction,title="Background fnct :   "
	PopupMenu BackgroundFnct,mode=1,value= "constant;flat;linear;PowerLaw w flat;Porod",popvalue=BackgroundFunction
	Button SaveBckgSubtr , pos={140, 10}, proc=IN2Q_SaveBckgSubtr,title="1. Save data"
	Button SaveBckgSubtr size={100,25}
	Button ExportBckgSubtr , pos={250, 10}, proc=IN2Q_ExportBckgSubtr,title="(2.) Export data"
	Button ExportBckgSubtr size={100,25}
	Button FinishBckgSubtr , pos={360, 10}, proc=IN2Q_RestartBckgSubtr,title="3. Restart"
	Button FinishBckgSubtr size={100,25}
	Button RemovePointDSM pos={0,80}, size={140,20}, title="Remove pnt w/csrA", proc=IN2G_RemovePointWithCursorA
	ResumeUpdate
	ModifyGraph width=0, height=0

	IN2Q_SetCsrAToExtendData()				//position cursor
	IN2Q_FitBkgToData(BlaIntwave, BlaIntOutputwave, BlaQwave, BlaErrWave, BckgStartQ, BackgroundFunction,0) 	//calculate the background
	
	SVAR CurrentBckgFolder
	string MyLegend=CurrentBckgFolder+"\r\\s(BlaIntwave) Input data\r\\s(BlaIntOutputwave) Data with subtracted background\r\\s(fit_BlaIntwave) Fit using background function"
	Legend/C/N=text0/J/A=LB MyLegend

end	
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IN2Q_CheckBckgExtHook(s)
	STRUCT WMWinHookStruct &s
	
//	Variable hookResult = 0	// 0 if we do not handle event, 1 if we handle it.

	switch(s.eventCode)
		case 7:					// Cursor moved
//			string/g root:Packages:Irena_desmearing:CsrMoveInfo
//			SVAR CsrMoveInfo=root:Packages:Irena_desmearing:CsrMoveInfo
//			CsrMoveInfo=info
			if(cmpstr(s.cursorName,"A")==0)
				Execute("IN2Q_CursorMoved()")
			endif
			break
	endswitch

//	return hookResult	// If non-zero, we handled event and Igor will ignore it.
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IN2Q_SetCsrAToExtendData()

	Wave BlaQwave=root:Packages:SubtrBckgWorkFldr:BlaQwave
	NVAR Wlength=root:Packages:SubtrBckgWorkFldr:numOfPoints
	NVAR BckgStart=root:Packages:SubtrBckgWorkFldr:BckgStartQ

	if (BckgStart<BlaQwave[Wlength-6])
		Cursor /P /W=BckgSubtCheckGraph1 A BlaIntwave BinarySearch(BlaQwave,BckgStart)
	else
		Cursor /P /W=BckgSubtCheckGraph1 A BlaIntwave (Wlength-10)
		BckgStart=BlaQwave(Wlength-10)
	endif		
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IN2Q_SaveBckgSubtr(ctrlName) : ButtonControl
	String ctrlName
	
	Wave  BlaIntOutputwave
	Wave  BlaQwave
	Wave  BlaErrWave
	SVAR FldrNam=root:Packages:SubtrBckgWorkFldr:CurrentBckgFolder
	NVAR FixedBackground
	SVAR BckgSubtrParamW
	NVAR UserSavedData
	string functionType=StringByKey("BckgFunction",BckgSubtrParamW,"=")
	NVAR BckgStartQ
	BckgSubtrParamW=ReplacenumberByKey("QToStartExtrap", BckgSubtrParamW, BckgStartQ,"=")
	SVAR BckgSubtrParam=$(FldrNam+"BckgSubtrParam")
	BckgSubtrParam=BckgSubtrParamW
	
	IN2G_AppendNoteToAllWaves("BackgroundSubtractedVal",num2str(FixedBackground))
	IN2G_AppendNoteToAllWaves("BackgroundSubtrFunction",functionType)

	IN2Q_RemoveNegFrom3Waves(BlaIntOutputwave,BlaQwave,BlaErrWave)

	string OrgIntName, OrgQvecName,OrgErrName
	OrgIntName=StringByKey("IntensityWvNm",BckgSubtrParamW,"=")
	OrgQvecName=StringByKey("QvectorWvNm",BckgSubtrParamW,"=")
	OrgErrName=StringByKey("ErrorWvNm",BckgSubtrParamW,"=")
	
	if (cmpstr(OrgIntName,"DSM_Int")==0)	
		Duplicate/O BlaIntOutputwave, $(FldrNam+"Bkg_Int")
		Duplicate/O BlaQwave, $(FldrNam+"Bkg_Qvec")
		Duplicate/O BlaErrWave, $(FldrNam+"Bkg_Error")
	elseif (cmpstr(OrgIntName,"M_DSM_Int")==0)
		Duplicate/O BlaIntOutputwave, $(FldrNam+"M_Bkg_Int")
		Duplicate/O BlaQwave, $(FldrNam+"M_Bkg_Qvec")
		Duplicate/O BlaErrWave, $(FldrNam+"M_Bkg_Error")
	else
		Duplicate/O BlaIntOutputwave, $(FldrNam+"Bkg_"+OrgIntName)
		Duplicate/O BlaQwave, $(FldrNam+"Bkg_"+OrgQvecName)
		Duplicate/O BlaErrWave, $(FldrNam+"Bkg_"+OrgErrName)
	endif
	UserSavedData=1
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IN2Q_ExportBckgSubtr(ctrlName) : ButtonControl
	String ctrlName
	
	string oldDf
	oldDf=getDataFolder(1)
	SVAR FldrNam=root:Packages:SubtrBckgWorkFldr:CurrentBckgFolder
	SVAR BckgSubtrParamW
	string OrgIntName, OrgQvecName,OrgErrName
	OrgIntName=StringByKey("IntensityWvNm",BckgSubtrParamW,"=")
	OrgQvecName=StringByKey("QvectorWvNm",BckgSubtrParamW,"=")
	OrgErrName=StringByKey("ErrorWvNm",BckgSubtrParamW,"=")

	setDataFolder FldrNam
	if (cmpstr(OrgIntName,"DSM_Int")==0)	
		IN2G_WriteSetOfData("BKG")
	elseif (cmpstr(OrgIntName,"M_DSM_Int")==0)
		IN2G_WriteSetOfData("M_BKG")
	else
		IN2Q_WriteSetOfData(OrgIntName,OrgQvecName,OrgErrName)
	endif
	
	setDataFolder oldDf
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IN2Q_RestartBckgSubtr(ctrlName) : ButtonControl
	String ctrlName

	NVAR UserSavedData
	if (UserSavedData==0)
		DoAlert 1, "Data not saved, really wish to continue and discard the data?"
		if (V_Flag==2)
			Abort
		endif 
	endif
	DoWindow/K BckgSubtCheckGraph1
	KillWaves/Z BlaIntwave, BlaQwave, BlaIntOutputwave, BlaErrWave
	IN2Q_SubtractBackground()
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IN2Q_WriteSetOfData(whichInt,whichQ,whichErr)		//this procedure saves selected data from current folder
	string whichInt,whichQ,whichErr
	
	PathInfo ExportDatapath
	NewPath/C/O/M="Select folder for exported data..." ExportDatapath
		if (V_flag!=0)
			abort
		endif
	
	string IncludeData="yes"
	
	Prompt IncludeData, "Evaluation and Description data include within file or separate?", popup, "within;separate"
	DoPrompt "Export Data dialog", IncludeData
	if (V_flag)
		abort
	endif

	
	string filename=IN2G_FixTheFileName2()
	if (cmpstr(IgorInfo(2),"P")>0) 										// for Windows this cmpstr (IgorInfo(2)...)=1
		filename=filename[0,30]										//30 letter should be more than enough...
	else																//running on Mac, need shorter name
		filename=filename[0,20]										//lets see if 20 letters will not cause problems...
	endif	
	filename=IN2G_GetUniqueFileName(filename)
	if (cmpstr(filename,"noname")==0)
		return 1
	endif
	string filename1
	Make/T/O WaveNoteWave 
	
	Wave BKG_QvecL=$(whichQ)
	Wave BKG_IntL=$(whichInt)
	Wave BKG_ErrorL=$(whichErr)
	
//	Proc Export Waves()
		filename1 = filename+".bkg"
			Duplicate/O BKG_QvecL, Exp_Qvec
			Duplicate/O BKG_IntL, Exp_Int
			Duplicate/O BKG_ErrorL, Exp_Error
			IN2G_TrimExportWaves(Exp_Qvec,Exp_Int, Exp_Error)
			
			IN2G_PasteWnoteToWave("Exp_Int", WaveNoteWave,"#   ")
		if (cmpstr(IncludeData,"within")==0)
			Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave,Exp_Qvec,Exp_Int, Exp_Error as filename1
		else
			Save/I/G/M="\r\n"/P=ExportDatapath Exp_Qvec,Exp_Int, Exp_Error as filename1				///P=Datapath			
			filename1 = filename1[0, strlen(filename1)-5]+"_dsm.txt"											//here we include description of the 
			Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1		//samples with this name
		endif		
	
	KillWaves/Z WaveNoteWave, Exp_Qvec, Exp_Int, Exp_Error
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//*****************************************************

Function IN2Q_RecalcBkg (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable

	WAVE BlaIntwave
	Wave BlaIntOutputwave
	WAVE BlaQwave
	WAVE BlaErrWave
	NVAR BckgStartQ
	SVAR BackgroundFunction
	NVAR numOfPoints
	NVAR FixedBackground=root:Packages:SubtrBckgWorkFldr:FixedBackground
	
	Redimension/N=(numOfPoints) BlaIntwave, BlaQwave, BlaErrWave
	IN2Q_FitBkgToData(BlaIntwave, BlaIntOutputwave, BlaQwave, BlaErrWave, BckgStartQ, BackgroundFunction,0)
	SetVariable FixedBackground,limits={0,inf,(FixedBackground/10)}

End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IN2Q_ChangeBkgFunction(ctrlname, popNum, popStr)  : PopupMenuControl 	
	string ctrlName
	variable popNum
	string popStr
	
	SVAR BackgroundFunction=BackgroundFunction
	BackgroundFunction=popStr
	WAVE BlaIntwave=BlaIntwave
	WAVE BlaIntOutputwave
	WAVE BlaQwave=BlaQwave
	Wave BlaErrWave=BlaErrWave
	NVAR BckgStartQ=BckgStartQ
	NVAR numOfPoints=numOfPoints
	SVAR BckgSubtrParamW
	NVAR FixedBackground=root:Packages:SubtrBckgWorkFldr:FixedBackground

	if (cmpstr(popStr,"constant")==0)
		SetVariable FixedBackground,noedit=0,limits={0,inf,(FixedBackground/20)}
	else
		SetVariable FixedBackground,noedit=1, limits={0,inf,0}
	endif
	
	BckgSubtrParamW=ReplaceStringByKey("BckgFunction",BckgSubtrParamW,BackgroundFunction,"=")
	
	Redimension/N=(numOfPoints) BlaIntwave, BlaQwave, BlaErrWave
	IN2Q_FitBkgToData(BlaIntwave, BlaIntOutputwave, BlaQwave, BlaErrWave, BckgStartQ, BackgroundFunction,0)
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IN2Q_FitBkgToData(Int_wave, IntOutputwave, Q_vct, Err_wave, Qstart, SelectedFunction, RecordFitParam) 
	wave Int_wave, Q_vct, Err_wave, IntOutputwave
	variable Qstart, RecordFitParam		//RecordFitParam=1 when we should record fit parameters in logbook
	string SelectedFunction
	

	WAVE ColorWave=ColorWave
	WAVE/Z W_coef=W_coef
		if (WaveExists(W_coef)!=1)					
			make/N=2 W_coef
		endif
	W_coef=0		//reset for recording purposes...
	
	NVAR FixedBackground
	
	string ProblemsWithQ=""
	string ProblemWithFit=""
	string ProblemsWithInt=""
	variable DataLengths=numpnts(Q_vct)-1							//get number of original data points
	variable ExtendByQ=0
	variable NumNewPoints=0
	variable FitFrom=binarySearch(Q_vct, Qstart)					//get at which point of Q start fitting for extension
	if (FitFrom<=0)		                 								//error in selection of Q fitting range
		FitFrom=DataLengths-10
		ProblemsWithQ="I did reset Fitting Q range for you..."
	endif
	//There seems to be bug, which prevents me from using /D in FuncFit and cursor control
	//therefore we will have to now handle this ourselves...
	//FIrst check if the wave exists
	Wave/Z fit_BlaIntwave
	if (!WaveExists(fit_BlaIntwave))
		Make/O/N=200 fit_BlaIntwave
	endif
	//Now we need to set it's x scaling to the range of Q values we need to study
	SetScale/I x Q_vct[FitFrom],Q_vct[DataLengths-1],"", fit_BlaIntwave
	//reset the fit wave to constant value
	fit_BlaIntwave=Int_wave[DataLengths-1]
		
	if(exists("ColorWave")==1)
		ColorWave=0
		ColorWave[FitFrom,DataLengths-1]=1
	endif
	
	variable i=0, ii=0	
	variable/g V_FitError=0					//this is way to avoid bombing due to numerical problems
	variable/g V_FitOptions=4				//this should suppress the window showing progress (4) & force robust fitting (6)
										//using robust fitting caused problems, do not use...
//	variable/g V_FitTol=0.00001				//and this should force better fit
	variable/g V_FitMaxIters=50
//	variable/g V_FitNumIters
	
	DoWindow BckgSubtCheckGraph1
	if (V_flag)
		RemoveFromGraph /W=BckgSubtCheckGraph1 /Z Fit_BlaIntwave
	endif
	//***********here start different ways to extend the data

	if (cmpstr(SelectedFunction,"flat")==0)				//flat background, for some reason only way this works is 
	//lets setup parameters for FuncFit
		if (exists("W_coef")!=1)					//using my own function to fit. Crazy!!
			make/N=2 W_coef
		endif
		Redimension/D/N=1 W_coef
		Make/O/N=1 E_wave
		E_wave[0]=1e-6
		W_coef[0]=Int_wave[((FitFrom+DataLengths)/2)]			//here is starting guesses
		K0=W_coef[0]										//another way to get starting guess in
	 	V_FitError=0											//this is way to avoid bombing due to numerical problems
		//now lets do the fitting
		FuncFit/N/Q IN2D_FlatFnct W_coef Int_wave [FitFrom, DataLengths-1] /I=1 /W=Err_Wave /E=E_Wave /X=Q_vct	//Here we get the fit to the Int_wave in
		//now check for the convergence
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Linear fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]								//extend Int
			EndFor
			fit_BlaIntwave=W_coef[0]
			IntOutputwave=Int_wave-W_coef[0]
			FixedBackground=W_coef[0]
		endif
	endif



	if (cmpstr(SelectedFunction,"constant")==0)				//flat background, for some reason only way this works is 
	//lets setup parameters for FuncFit
		fit_BlaIntwave=FixedBackground
		IntOutputwave=Int_wave-FixedBackground
	endif

	if (cmpstr(SelectedFunction,"Porod")==0)				//Porod background
		if (exists("W_coef")!=1)
			make/N=2 W_coef
		endif
		Redimension/D/N=2 W_coef
		variable estimate1_w0=Int_wave[(DataLengths-1)]
		variable estimate1_w1=Q_vct[(FitFrom)]^4*Int_wave[(FitFrom)]
		W_coef={estimate1_w0,estimate1_w1}							//here are starting guesses, may need to be fixed.
		K0=estimate1_w0
		K1=estimate1_w1
	 	V_FitError=0					//this is way to avoid bombing due to numerical problems
		//now lets do the fitting	
		FuncFit/N/Q IN2D_Porod W_coef Int_wave [FitFrom, DataLengths-1] /I=1 /W=Err_Wave /X=Q_vct			//Porod function here
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Porod fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]=W_coef[0]+W_coef[1]/(Q_vct[DataLengths+i])^4		//extend Int
			endfor
			fit_BlaIntwave=W_coef[0]+W_coef[1]/(x)^4
			IntOutputwave=Int_wave-W_coef[0]
			FixedBackground=W_coef[0]
		endif
	endif


	if (cmpstr(SelectedFunction,"linear")==0)					//fit line
		CurveFit/N/Q line Int_wave [FitFrom, DataLengths-1] /I=1 /W=Err_Wave /X=Q_vct		//linear function here
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Linear fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)^2	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]+W_coef[1]*Q_vct[DataLengths+i]			//extend Int
			endfor
			fit_BlaIntwave=W_coef[0]+W_coef[1]*x	
			IntOutputwave=Int_wave-(W_coef[0]+W_coef[1]*Q_vct[p])
			FixedBackground=W_coef[0]+W_coef[1]*Q_vct[inf]
		endif
	endif

	if (cmpstr(SelectedFunction,"PowerLaw w flat")==0)				//fit polynom 3rd degree
		if (exists("W_coef")!=1)
			make/N=3 W_coef
		endif
		Make/O/T CTextWave={"K1 > 0"," K2 < 0","K0 > 0", "K2 > -6"}
		Redimension/D/N=3 W_coef
	 	V_FitError=0					//this is way to avoid bombing due to numerical problems
			Curvefit/N/Q power Int_wave [FitFrom, DataLengths-1] /I=1 /C=CTextWave/X=Q_vct /W=Err_Wave		
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Power Law with flat fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]+W_coef[1]*(Q_vct[DataLengths+i]^W_coef[2])
			endfor
				fit_BlaIntwave=W_coef[0]+W_coef[1]*(x^W_coef[2])
				IntOutputwave=Int_wave-W_coef[0]
				FixedBackground=W_coef[0]
			endif
		endif

		wavestats/Q Int_wave
		if (V_min<0)
			ProblemsWithInt="Extrapolated Intensity <0, select different function" 
		endif

	string ErrorMessages=""
	if (strlen(ProblemsWithQ)!=0)
		ErrorMessages=ProblemsWithQ+"\r"
	endif
	if (strlen(ProblemsWithInt)!=0)
		ErrorMessages=ProblemsWithInt+"\r"
	endif
	if (strlen(ProblemWithFit)!=0)
		ErrorMessages+=ProblemWithFit
	endif
	
	Variable/G ExtrapolationFunctionProblem
	NVAR ExtrapolationFunctionProblem
	ExtrapolationFunctionProblem=0
	
	DoWindow BckgSubtCheckGraph1
	if (V_flag)
		AppendToGraph /W=BckgSubtCheckGraph1 fit_BlaIntwave
		ModifyGraph /W=BckgSubtCheckGraph1 /Z rgb(fit_BlaIntwave)=(0,0,65280), lstyle(fit_BlaIntwave)=3

		//Error messages
		//First remove the old one
		if (stringMatch(WinRecreation("",0),"*/N=ErrorMessageTextBox*"))
			TextBox/W=BckgSubtCheckGraph1/K/N=ErrorMessageTextBox
		endif
		if (strlen(ErrorMessages)!=0)
			TextBox/W=BckgSubtCheckGraph1/C/N=ErrorMessageTextBox/B=(65280,32512,16384)/D=3/A=RT "\\Z09"+ErrorMessages
			ExtrapolationFunctionProblem=1
		endif
	endif

	DoWindow BckgSubtCheckGraph1
	if (!V_flag)
		If (strlen(ErrorMessages)!=0)
			DoAlert 0,  ErrorMessages
		endif
	endif
	Wave/Z W_sigma
	
	//Now recording results, if asked for
	if (RecordFitParam)
		NVAR NumOfIterationsIs=NumOfIterationsIs
		IN2G_AppendAnyText("Record of results from Background subtraction ")
		IN2G_AppendAnyText("Used function: "+SelectedFunction)
		IN2G_AppendAnyText("Final background = "+num2str(FixedBackground))
	endif
end 
////****************************************************


//*****************************************************

Function IN2Q_CursorMoved()
	
//	SVAR info=root:Packages:SubtrBckgWorkFldr:CsrMoveInfo
	String oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SubtrBckgWorkFldr:

//	Variable isB = cmpstr(StringByKey("CURSOR",info), "A")
	string info= csrinfo(A)
	
//	if (isB==0)
		String tName= StringByKey("TNAME", info)
		if( strlen(tName) )	// cursor still on
			//Result needs to be passed to the rest of the procedures
			//but before we need to check that the cursor has not moved on last 5 points
			Wave w= TraceNameToWaveRef("BckgSubtCheckGraph1", tName)
			Variable pointNum= NumberByKey("POINT",info)
			NVAR Wlength=root:Packages:SubtrBckgWorkFldr:numOfPoints
			NVAR BckgStart=root:Packages:SubtrBckgWorkFldr:BckgStartQ

			if (pointNum>Wlength-6)
				Cursor /P /W=BckgSubtCheckGraph1 A BlaIntwave (Wlength-6)
			endif		
		
			BckgStart = hcsr(A)
		
			IN2Q_RecalcBackgroundExt()
		endif
//	endif	
	SetDataFolder oldDf
End


//**********************************************************
Function IN2Q_RecalcBackgroundExt()

	WAVE BlaIntwave
	WAVE BlaIntOutputwave
	WAVE BlaQwave
	WAVE BlaErrWave
	NVAR BckgStartQ
	SVAR BackgroundFunction
	NVAR numOfPoints
	
	Redimension/N=(numOfPoints) BlaIntwave, BlaQwave, BlaErrWave
	IN2Q_FitBkgToData(BlaIntwave, BlaIntOutputwave, BlaQwave, BlaErrWave, BckgStartQ, BackgroundFunction,0)

End


//**********************************************************************************************
//**********************************************************************************************
Function IN2Q_RemoveNegFrom3Waves(Wv1,wv2,wv3)							//removes NaNs from 3 waves
	Wave Wv1, Wv2, Wv3					//assume same number of points in the waves
	
	variable i=0, imax=numpnts(Wv1)
	for (i=imax;i>=0;i-=1)
		if (Wv1[i]<=0)
			Deletepoints i, 1, Wv1, Wv2, Wv3
		endif
		if (Wv2[i]<=0)
			Deletepoints i, 1, Wv1, Wv2, Wv3
		endif
		if (Wv3[i]<=0)
			Deletepoints i, 1, Wv1, Wv2, Wv3
		endif	
	endfor
end
