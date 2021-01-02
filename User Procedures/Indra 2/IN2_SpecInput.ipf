#pragma rtGlobals=3		// Use modern global access method.
#pragma IgorVersion= 7.06  // Requires Igor Pro v7.06 or later.
#pragma version = 1.21


//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.21 added Scan Type match to enable loading of specific type of scans
//1.20 added Grapsrtring to extract information from spec file. 
//1.19 changed checkIntegrity logic not to check for first few points for I0 value. Due to autoranging that may fail. 
//1.18 updated to pass specMotors to USAXS folder as it is now needed later (and may be useful). 2/2013 JIL
//1.17 updated to pass I0 gain to UPD parameters so it can be used as we now have I0gain autoranging... Reading I0_range column if exists
// 4/18/2012 JIL
//This is part of Indra 2 macros for USAXS data evaluation at UNICAT APS Bonse-Hartman camera

constant LimitValForMoniToAssumeBeamDump=1000


Function IN2_RemoveUSAXSMacros()
	//kill windows as needed, needs to be smarter here???
	KillWIndow/Z RcurvePlotGraph
 	KillWIndow/Z USAXSDataReduction
 	


	Execute/P "DELETEINCLUDE \"IN2_Load Indra 2\""
	Execute/P "COMPILEPROCEDURES "
	SVAR strChange=root:Packages:USAXSItem1Str
	strChange= "Load USAXS Macros"
	BuildMenu "USAXS"
	DoWindow USAXSQuickManual
end

Function IN2_ImportData()										// Function which imports the data from SPEC for USAXS users
	
	close/A													//close open files, this closes local copy of data accidentally open after last load in case of crash
	specInitPackage()										//runs initialization, if needed
	IN2_USAXSInitPackage()									//runs initialization of USAXS packages if needed
	IN2_CopySpecFileLocally(0)								//this function copies SPEC file locally in ":tempjunk:junk.txt" or Mac equivalent

	string TempFileName=IN2_CreateTempFileName()			//this returns the propert pointer to the temp  file
	
	IN2_specScansList(TempFileName,"TempFilePath","*")		//creates list of scan lines commands and position list
															//replace "*" with "*uascan" to load USAXS data only

	IN2N_CreateShowNtbkForLogging(0)						//create notebook for logging
	IN2_GetInputAndCreateListPanel()	

end		


///*************************************
///*************************************
//here go functions for Import of data from USAXS
//****************************************


Function IN2_USAXSInitPackage()									//initialization of USAXS folderin Packages
	    
	NewDataFolder /O root:Packages								//create Packages folder
	NewDataFolder /O root:Packages:Indra3						//create USAXS folder there
	if (exists("root:Packages:Indra3:RawToUSAXS")!=2)				//create RawToUSAXS conversion if needed		
		// Conversiotn of waves from Raw data to USAXS data
		String /G root:Packages:Indra3:RawToUSAXS="AR_enc=XX;PD_range=XX;USAXS_PD=XX;Time=XX;Monitor=XX;"
		SVAR RawToUSAXS=root:Packages:Indra3:RawToUSAXS
		RawToUSAXS+="Energy=YY;Vfc=YY;Gain1=YY;Gain2=YY;Gain3=YY;Gain4=YY;Gain5=YY;"
		RawToUSAXS+="Bkg1=YY;Bkg2=YY;Bkg3=YY;Bkg4=YY;Bkg5=YY;"
		String/G root:Packages:Indra3:NewUSAXSSubfolder	=""		//create another string there
	endif
	
	SVAR /Z test=root:Packages:Indra3:USAXSSubfolder				//another string which we need
	if (!SVAR_Exists(test))
		string/g root:Packages:Indra3:USAXSSubfolder=""
		SVAR test=root:Packages:Indra3:USAXSSubfolder				//another string which we need
	endif
	
	string/g root:Packages:Indra3:ImmediatelyConvertUSAXSData="Yes"
	string/g root:Packages:Indra3:ScanTypeMatchString=""
end


Function IN2_CopySpecFileLocally(skipDialog)									//this function copies spec file locally to tempjunk folder
	variable skipDialog
	
	Variable refNum													//ref number of open file
	String TempFileName=IN2_CreateTempFileName()					//returns platform specific temp filename 

	if(skipDialog==0)
		if (cmpstr(IgorInfo(2),"P")>0) 										// for Windows IgorInfo(2)=1
			PathInfo RawDataPath
			if (V_Flag==0)												// gets which file we want to open
	        		Open/R/D/T=".DAT" refNum as ""
	      		 else
	       		Open/R/D/P=RawDataPath/T=".DAT" refNum as ""
	      		endif
		else																	//Mac
			PathInfo RawDataPath
			if (V_Flag==0)													// gets which file we want to open
	        		//Open/R/D/T="TEXT" refNum as ""
	        		Open/R/D/T="????" refNum as ""
	       	else
	       		//Open/R/D/P=RawDataPath/T="TEXT" refNum as ""
	       		Open/R/D/P=RawDataPath/T="????" refNum as ""
	       	endif
		endif	
	
	       if (strlen(S_fileName)==0)												//check if the file was opened and breaks from macro if the user hits cancel
	     //  	Abort "No file was opened"
	     		Abort 
	       endif
	else			//reopen old existing file...
		SVAR specUSAXSSourceFile=root:Packages:Indra3:specUSAXSSourceFile
		if (cmpstr(IgorInfo(2),"P")>0) 										// for Windows IgorInfo(2)=1
			PathInfo RawDataPath
			if (V_Flag==0)												// gets which file we want to open
	        		Open/R/T=".DAT" refNum as specUSAXSSourceFile
	      		 else
	       		Open/R/P=RawDataPath/T=".DAT" refNum as specUSAXSSourceFile
	      		endif
		else																	//Mac
			PathInfo RawDataPath
			if (V_Flag==0)													// gets which file we want to open
	        		Open/R/T="TEXT" refNum as specUSAXSSourceFile
	       	else
	       		Open/R/P=RawDataPath/T="TEXT" refNum as specUSAXSSourceFile
	       	endif
		endif	
	
	       if (strlen(S_fileName)==0)												//check if the file was opened and breaks from macro if the user hits cancel
	     //  	Abort "No file was opened"
	     		Abort 
	       endif
	endif
		       
      String fullFilePath = S_fileName        									// S_fileName set by Open
	
	SetDataFolder root:													//sets us in root and sets few parameters
	string Nname="SpecFileCopy"
	//*****************************opens the file
	if (cmpstr(IgorInfo(2),"P")>0) 											// for Windows IgorInfo(2)=1
	 	OpenNotebook/T=".DAT"/V=0/R/N=$Nname fullFilePath				//using notebook copies the file locally
 	else																	//Mac
		OpenNotebook/T="TEXT"/V=0/R/N=$Nname fullFilePath				//using notebook copies the file locally
	endif	

	SVAR /Z specDefaultFile=root:Packages:spec:specDefaultFile
	if (SVAR_exists(specDefaultFile)!=1)									// creates SpecDefaultFile for future use
			String /G root:Packages:spec:specDefaultFile
			SVAR specDefaultFile=root:Packages:spec:specDefaultFile
	endif
	
	string tempSpecDefaultFile = RemoveFromList("\\", fullFilePath,":")			//here we need to set the pointer to original file, so we know where the data came from
	variable numOfFold=ItemsInList(tempSpecDefaultFile,":")					//this mess gets file name and file path of the original data
	specDefaultFile = stringFromList(numOfFold-1, tempSpecDefaultFile, ":")
      NewPath/O RawDataPath, RemoveFromList(specDefaultFile, fullFilePath,":")

	String /G root:Packages:Indra3:specUSAXSSourceFile=specDefaultFile

	SaveNotebook/O/S=3 $Nname as TempFileName
	KillWIndow/Z $Nname 
	Close/A																// now the data are in the C:\temp\junk.txt file and rest of the time we work on this junk file
	
end


Function/S IN2_CreateTempFileName()						//This function returns proper platform specific temp name
	String TempFileName	
	
	//changes 10-18-2006 to allow this to function on systems where user has no right to write to Igor pro folder...
	//SpecialDirPath("Temporary", 0, 1, 0 )
	if (cmpstr(IgorInfo(2),"P")>0) 											// for Windows IgorInfo(2)=1
			//PathInfo Igor
			TempFileName=SpecialDirPath("Temporary", 0, 0, 0 )+"tempjunk:junk.txt"
			NewPath/C/O TempFilepath, SpecialDirPath("Temporary", 0, 0, 0 )+"tempjunk:"
	else																	//Mac
			//PathInfo Igor   ParseFilePath(mode, pathInStr, separatorStr, whichEnd, whichElement)
//			TempFileName=ParseFilePath(1,SpecialDirPath("Temporary", 0, 0, 0 )+"tempjunk:junk","*",0,0)
	//		NewPath/C/O TempFilepath, ParseFilePath(1,SpecialDirPath("Temporary", 0, 0, 0 ),"*",0,0)+"tempjunk"
			TempFileName=SpecialDirPath("Temporary", 0, 0, 0 )+"tempjunk:junk"
			NewPath/C/O TempFilepath, SpecialDirPath("Temporary", 0, 0, 0 )+"tempjunk"
	endif	
	return  TempFileName
end

Function/T IN2_specScansList(fileName,path,scanType)
		// creates lists of positions, scan lines and comment lines of the scans of a certain type from a spec data file
		// scanType is the spec scan name,  "all;ascan;hklscan;laserscan;uascan;sbuascan" or a wild carded version of one
	String fileName	//=StrVarOrDefault("root:Packages:spec:specDefaultFile","")
	String path	//=StrVarOrDefault("root:Packages:spec:specDefaultPath","home")
	String scanType	//="all"

	if (cmpstr("all",scanType)==0)
		scanType="*"
	else
		scanType = "  "+scanType+" *"
	endif
	Variable fileVar									// file ref number
	String line										// line of input from file
	String posList									// file positions of all scans
	String scanList=""
	String commentList=""
	Variable scanNum

	Open /R/P=$path/M="spec data file"/Z fileVar as fileName
	if (V_flag)
		Open /R/M="spec data file" fileVar as fileName
	endif
	FStatus(fileVar)
	String /G root:Packages:spec:specDefaultFile=S_fileName		// update defaults
	String /G root:Packages:spec:specDefaultPath=path

	posList = ListPosOfLineTypes(fileVar,"#S ")
	FSetPos fileVar, 0
	
	if (strlen(posList)<1)
		return ""
	endif

	Variable i = 0
	Variable N=ItemsInList(posList)
	do
		FSetPos fileVar, str2num(StringFromList(i, posList))+3	// position just after '#S '
		FReadLine fileVar, line
		line = ZapControlCodes(line)
		scanNum = str2num(line)
		if (stringmatch(line,num2istr(scanNum)+scanType))
			scanList += line+";"
		endif
		line=FindDataLineType(fileVar,"#C ",1)
		line = ZapControlCodes(line)
		commentList += line[2, inf] + ";"
		i += 1
	while(i<N)
	Close fileVar
	
	String /G root:Packages:spec:posList=posList
	String /G root:Packages:Indra3:CommentsList=commentList
	string /G	root:Packages:Indra3:CommandList = IN2G_ChangePartsOfString(scanList,"  "," ")
End


Function/T IN2_GetInputAndCreateList()			//this does dialog for user input which scans to load
											//and then retunrs the list of positison from which the scans are to be loaded
															//first create the list for input dialog
	string DialogList="all;range;"
	string DialogListForRangeSelection=""
	
	SVAR commentList = root:Packages:Indra3:CommentsList
	SVAR scanList = root:Packages:Indra3:CommandList 
	SVAR posList = root:Packages:spec:posList 
	SVAR ConvertUSAXSImmediately=root:Packages:Indra3:ImmediatelyConvertUSAXSData

	Variable Items=ItemsInList(scanList) , i = 0, j=0
	
	for(i=0;i<Items;i+=1)										// initialize variables;continue test
		DialogListForRangeSelection+=StringFromList(i, scanList)[0,10]+"  "
		DialogListForRangeSelection+=StringFromList(i, commentList)[0,30]+";"		// condition;update loop variables
	endfor													// execute body code until continue test is false
	
	DialogList+=DialogListForRangeSelection
	
	Variable DataToLoad
	Variable RangeFrom=0, RangeTo=0
	SVAR specUSAXSSourceFile=root:Packages:Indra3:specUSAXSSourceFile
	String PutDataWhere=PossiblyQuoteName(StringFromList(0,specUSAXSSourceFile,"."))
	String OverwriteIfExists="yes"
	String CnvUSAXS=ConvertUSAXSImmediately
	
	Prompt DataToLoad, "Select Data to load", popup, DialogList
	Prompt RangeFrom, "If range, select starting scan",popup, DialogListForRangeSelection
	Prompt RangeTo, "If range, select ending scan",popup, DialogListForRangeSelection
	Prompt PutDataWhere, "Modify raw data subfolder?"
	Prompt OverwriteIfExists, "If raw data folder exists, overwrite?", popup, "yes;no"
	Prompt CnvUSAXS, "Convert USAXS scans to USAXS data immediately?", popup, "Yes;No"
	
	DoPrompt "Select data which you want load from spec file", DataToLoad, RangeFrom, PutDataWhere, RangeTo, OverwriteIfExists, CnvUSAXS
	if (V_flag)
		abort 
	endif
	variable bla
	if (RangeFrom>RangeTo)
		bla=RangeFrom
		RangeFrom=RangeTo
		RangeTo=bla
	endif
	ConvertUSAXSImmediately=CnvUSAXS	
														//this sets parameters for data loading
	String /G root:Packages:Indra3:USAXSRawDataFolder="root:raw:"+PutDataWhere
	String /G root:Packages:Indra3:USAXSOverWriteRaw=OverwriteIfExists
	String /G root:Packages:Indra3:ListOfLoadedScans=""
	string buffer
	SVAR ListOfScans=root:Packages:Indra3:ListOfLoadedScans
	
		
	if (DataToLoad==1)						//this loads all data, therefore returns complete posList
		for(i=0;i<ItemsInList(posList);i+=1)	
			buffer=StringFromList(i+2,DialogList)
			ListOfScans+=buffer[0,2]+";"							
		endfor											
		return posList
	endif
	
	if (DataToLoad==2)						//this loads range of data
		string NewList=""
		for(i=RangeFrom-1;i<RangeTo;i+=1)					
			NewList+=StringFromList(i,posList)+";"	
			buffer=StringFromList(i+2,DialogList)
			ListOfScans+=buffer[0,2]+";"						
		endfor										
		return NewList
	endif

	buffer=StringFromList(DataToLoad-1,DialogList)
	ListOfScans+=buffer[0,2]+";"				
	return StringFromList(DataToLoad-3,posList)	 //this loads only one scan from the file

end


Function IN2_LoadDataFromTheSpec(ListOfDataToLoad)						//this function loads data using list of positions
	string ListOfDataToLoad

	string TempFileName=IN2_CreateTempFileName()							//creates properf temp name (platform specific)

	Variable fileVar															// file ref number
	if (cmpstr(IgorInfo(2),"P")>0) 												// for Windows IgorInfo(2)=1
			Open /R/T=".TXT"/M="spec data file"/Z fileVar as TempFileName
	else																		//Mac
			Open /R/T="TEXT"/M="spec data file"/Z fileVar as TempFileName
	endif		

	FStatus(fileVar)
	if (V_Flag==0)
		return 0																//no sucess with opening temp file
	endif
	SVAR SpecSource=root:Packages:Indra3:specUSAXSSourceFile			//this should be string with the spec source file
	SVAR df=root:Packages:Indra3:$"USAXSRawDataFolder"					//here we create the data folders for raw data
	
	if (!DataFolderExists("root:raw"))										//create folder for data
		NewDataFolder root:raw
	endif 
	if (!DataFolderExists(df))
		NewDataFolder $df
	endif 
	
	SetDataFolder df														//assumption here is that the data go upto first level under raw 

	//logging
	IN2G_AppendAnyText("\r")
	IN2N_InsertDateAndTime()
	IN2G_AppendAnyText("Imported data from SPEC file :  \t"+SpecSource)
	IN2G_AppendAnyText("Data saved in  :  \t\t"+GetDataFolder(1))
	
	
	Variable NumOfScansToLoad=ItemsInList(ListOfDataToLoad)
	Variable i, success=1													//The following cycle loads data
	for(i=0;i<NumOfScansToLoad;i+=1)										// initialize variables;continue test
		success=specReadFromSline(fileVar, str2num(StringFromList(i, ListOfDataToLoad)))	// condition;update loop variables
		if (success!=0)
			return 1															//no success - problems loading data
		endif
	endfor																// execute body code until continue test is false
	close/A

	//here we need to go to each folder and copy there more details
	SVAR ListOfComments=root:Packages:Indra3:CommentsList
	SVAR ListOfFolders=root:Packages:Indra3:ListOfLoadedScans
	string Folderbucket
	
	for(i=0;i<ItemsInList(ListOfFolders);i+=1)									//here we go in each folder and copy there comments 
		Folderbucket= ReduceSpaceRunsInString("spec"+StringFromList(i, ListOfFolders),0)	//from our copy of comments
		SetDataFolder $Folderbucket
		String/G SpecSourceFileName=SpecSource
		//this construction does not work, if the scan numbers are missing....
//		String/G SpecComment=StringFromList(str2num(StringFromList(i, ListOfFolders))-1,ListOfComments)
		Wave AnyWave=$StringFromList(0, WaveList("*",";",""), ";")
		String/G SpecComment=stringByKey("COMMENT", note(AnyWave),"=")
		SpecComment=TrimLeadingWhiteSpace(SpecComment)
		SpecComment=TrimTraiingWhiteSpace(SpecComment)
		//logging
			IN2G_AppendAnyText("Data in :  \t"+GetDataFolder(1)+"   are     \t"+SpecComment)
		SetDataFolder df
	endfor											

	return 0														 		//if sucess with loading data
end

//********************************************end of functions to import data
//*******************************************************************************
//This function corrects the spec folder names if they should be duplicate

Function IN2_CheckForDuplicateFldrs()										//as the name says, check for duplicate folders

	SVAR RawFolder=root:Packages:Indra3:USAXSRawDataFolder
	SVAR Overwrite=root:Packages:Indra3:USAXSOverWriteRaw
	SVAR ListOfScans=root:Packages:Indra3:ListOfLoadedScans
	
	if (DataFolderExists(RawFolder))						//if the Raw data folder exists we need to bother
		String df=GetDataFolder(1)							//save were we are
		SetDataFolder $RawFolder							//go where we want to put data
		Variable i=0, imax=ItemsInList(ListOfScans), CurScan=0, Changed_deleted=0			//some variables
		String TestedName="", NewName
		For (i=0;i<imax;i+=1)								//cycle through all scans
			CurScan=str2num(stringFromList(i,ListOfScans))	//this is the number of curent scans
			TestedName="spec"+num2str(CurScan)			//this is name we test for
			if (DataFolderExists(TestedName))				//does the folder exist?
				if (!cmpstr(Overwrite, "yes"))								//if we want to overwrite, lets kill the old folder
					KillDataFolder(TestedName)
					Changed_deleted=1
				else
					NewName = "spec"+num2str(CurScan)+"0"		//new name will be scanxxx, where xx is the spec number + 00
					Newname = UniqueName(NewName,11,0)
					TestedName = RawFolder+":"+TestedName	
					RenameDataFolder $TestedName, $NewName
					Changed_deleted=2
				endif
			endif
		endfor
		if (Changed_deleted==1)							//folder deleted
		//	DoAlert 0, "At least one scan folder with the same scan name was deleted" 
		endif
		if (Changed_deleted==2)
		//	DoAlert 0, "At least one scan with the same scan name was renamed by adding 00, 01, etc after scan name"
		endif
	endif
end


//*******************************************************************************
// // Panel to generate conversion from RAW to USAXS
// 
Function IN2_RAWtoUSAXSParametersSetup(here)							//This offerss user panel to setup Raw to USAXS 
	variable here														//if here, then we need to call this function in the current folder
																	//table - for waves
	string/G root:Packages:Indra3:PanelSpecScanSelected				//create the global string needed
	SVAR param=root:Packages:Indra3:PanelSpecScanSelected
	SVAR/Z USAXSLastFolder=root:Packages:Indra3:USAXSRawDataFolder	//This is pointer to last USAXS used subfolder
	if (!SVAR_Exists(USAXSLastFolder))
		abort "Wrong call, needed parameter does not exist. Get help..."
	endif
	string ListOfSubfolders=IN2G_CreateListOfItemsInFolder(USAXSLastFolder,1)		//this is list of subfolders in the last USAXS folder
	variable i, imax=ItemsInList(ListOfSubfolders)
	string tempdf
	
	
	if (here)
		param=GetDataFolder(1)
	else
		For (i=0;i<imax;i+=1)								//Here we  will find first USAXS folder in there
			setDataFolder $USAXSLastFolder
			tempdf=StringFromList(i,ListOfSubfolders)
			setDataFolder $tempdf
			svar SpecCommand			
			if (stringMatch(SpecCommand,"*uascan*"))		//USAXS scan contains usaxs in the command
				param=GetDataFolder(1)
				break
			endif
		endfor
	endif
	
	//set the most likely waves in here
		
	SVAR TR_list=root:Packages:Indra3:RawToUSAXS
	
	if (cmpstr(StringByKey("USAXS_PD", TR_list, "="),"XX")==0)
		TR_List=ReplaceStringByKey("USAXS_PD", TR_list,  StringFromList(0,IN2_GetMeMostLikelyUSAXSWave("USAXS_PD")),"=")
	Endif
	if (cmpstr(StringByKey("Monitor", TR_list, "="),"XX")==0)
		TR_List=ReplaceStringByKey("Monitor", TR_list,  StringFromList(0,IN2_GetMeMostLikelyUSAXSWave("I0")),"=")
	Endif
	if (cmpstr(StringByKey("PD_range", TR_list, "="),"XX")==0)
		TR_List=ReplaceStringByKey("PD_range", TR_list,  StringFromList(0,IN2_GetMeMostLikelyUSAXSWave("PD_range")),"=")
	Endif
	if (cmpstr(StringByKey("AR_Enc", TR_list, "="),"XX")==0)
		TR_List=ReplaceStringByKey("AR_Enc", TR_list,  StringFromList(0,IN2_GetMeMostLikelyUSAXSWave("AR_Enc")),"=")
	Endif
	if (cmpstr(StringByKey("Time", TR_list, "="),"XX")==0)
		TR_List=ReplaceStringByKey("Time", TR_list,  StringFromList(0,IN2_GetMeMostLikelyUSAXSWave("seconds")),"=")
	Endif

	Execute ("IN2_RawToUSAXSPanel()")								//create panel
end
//
Window IN2_RawToUSAXSPanel() : Panel								//the panel
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(297.75,56.75,627,450)
	SetDrawLayer UserBack
	SetDrawEnv fstyle= 1
	DrawText 3,22,"Create \"conversion\" from SPEC data to USAXS data"
	SetDrawEnv fstyle= 1
	DrawText 3,97,"Select proper wave for each of following:"
	SetDrawEnv fsize= 10
	DrawText 20,366,"Note, that this sets default setting for this Igor file"
	SetDrawEnv fsize= 10
	DrawText 20,378,"If the data from different SPEC file are loaded"
	SetDrawEnv fsize= 10
	DrawText 20,390,"This macro may have to be rerun!!!"
	SetDrawEnv fsize= 10
	DrawText 20, 315,"If you are REALLY SURE, you can"
	SetDrawEnv fsize= 10
	DrawText 20, 330,"remove waves from RAW data"
	DrawLine 20,295,250,295
	DrawLine 20,340,250,340
	SetDrawEnv linethick= 3,linefgc= (0,65280,0)
	DrawRect 100,250,190,290
	Button RemoveSomeWaves,pos={200,305},size={60,20},proc=IN2_DeleteWavesFromRaw,title="Remove?", help={"Remove unneeded waves from RAW data to save space? Use with caution!!!"}
	Button KillMe,pos={110,260},size={65,20},proc=IN2G_KillPanel,title="Continue",help={"Click to continue"}
	PopupMenu SetSpecDataFldr,pos={20,25},size={170,21},proc=IN2_PopMenuProc_Fldr,title="Select Raw sub-Folder",help={"Select folder with RAW data which you need to convert to USAXS data"}
	PopupMenu SetSpecDataFldr,mode=1,popvalue=root:Packages:Indra3:USAXSRawDataFolder,value= #"\"XXX;\"+IN2G_CreateListOfItemsInFolder(\"root:raw\",1)"		//
	PopupMenu SelectSpecRun,pos={20,50},size={139,21},proc=IN2_PopMenuProc_SpecRun,title="Select Spec run",help={"Select folder with spec run containing USAXS data to be able to select appropriate waves. Should be selected properly."}
	PopupMenu SelectSpecRun,mode=1,popvalue=root:Packages:Indra3:PanelSpecScanSelected,value= #"\"XXX;\"+IN2G_CreateListOfItemsInFolder(GetDataFolder(1),1)"
	PopupMenu SelectPDWaveName,pos={10,100},size={174,21},proc=IN2_WavesPanelControl,title="Select Photodiode int. data",help={"Select wave name which contains photodiode data. Usually the first one in the popup, should be selected properly."}
	PopupMenu SelectPDWaveName,mode=1,popvalue=StringByKey("USAXS_PD", root:Packages:Indra3:RawToUSAXS,"="),value= #"StringByKey(\"USAXS_PD\", root:Packages:Indra3:RawToUSAXS,\"=\")+\";\"+IN2_GetMeMostLikelyUSAXSWave(\"FemtoPD\")+IN2_GetMeMostLikelyUSAXSWave(\"USAXS_PD\")+IN2_GetMeMostLikelyUSAXSWave(\"PD\")+IN2G_CreateListOfItemsInFolder(root:Packages:Indra3:PanelSpecScanSelected,2)"
	PopupMenu Monitor,pos={10,130},size={166,21},proc=IN2_WavesPanelControl,title="Select I0 monitor data",help={"Select wave name with IO data, usually the first selection, should be preselected properly."}
	PopupMenu Monitor,mode=1,popvalue=StringByKey("Monitor", root:Packages:Indra3:RawToUSAXS,"="),value= #"StringByKey(\"Monitor\", root:Packages:Indra3:RawToUSAXS,\"=\")+\";\"+IN2_GetMeMostLikelyUSAXSWave(\"I0\")+IN2G_CreateListOfItemsInFolder(root:Packages:Indra3:PanelSpecScanSelected,2)"
	PopupMenu PDrange,pos={10,160},size={165,21},proc=IN2_WavesPanelControl,title="Select PD range data",help={"Select wave name with PD range data. Should be preselected properly."}
	PopupMenu PDrange,mode=1,popvalue=StringByKey("PD_range", root:Packages:Indra3:RawToUSAXS,"="),value= #"StringByKey(\"PD_range\", root:Packages:Indra3:RawToUSAXS,\"=\")+\";\"+IN2G_CreateListOfItemsInFolder(root:Packages:Indra3:PanelSpecScanSelected,2)"
	PopupMenu AREnc,pos={10,190},size={193,21},proc=IN2_WavesPanelControl,title="Select Angle data (AR Enc)",help={"Select wave name with ARencoder data. Should be preselected properly."}
	PopupMenu AREnc,mode=1,popvalue=StringByKey("AR_enc", root:Packages:Indra3:RawToUSAXS,"="),value= #"StringByKey(\"AR_enc\", root:Packages:Indra3:RawToUSAXS,\"=\")+\";\"+IN2_GetMeMostLikelyUSAXSWave(\"ar_enc\")+IN2G_CreateListOfItemsInFolder(root:Packages:Indra3:PanelSpecScanSelected,2) "
	PopupMenu Timew,pos={10,220},size={143,21},proc=IN2_WavesPanelControl,title="Select Time data",help={"Select wave name with the wave containing measurement time, should be preselected properly"}
	PopupMenu Timew,mode=1,popvalue=StringByKey("Time", root:Packages:Indra3:RawToUSAXS,"="),value= #"StringByKey(\"time\", root:Packages:Indra3:RawToUSAXS,\"=\")+\";\"+IN2_GetMeMostLikelyUSAXSWave(\"sec\")+IN2G_CreateListOfItemsInFolder(root:Packages:Indra3:PanelSpecScanSelected,2) "
	DoUpdate
EndMacro

Function/T IN2_GetMeMostLikelyUSAXSWave(str)	//this returns the most likely waves from the wave names
	string str
	
	string strshort=str
	str="*"+str+"*"
	String dfSave, result=""
	dfSave=GetDataFolder(1)
	
	SVAR SpecFile=root:Packages:Indra3:PanelSpecScanSelected
	SetDataFolder $SpecFile
	if (strlen(WaveList(strshort,";",""))!=0)
		result=WaveList(strshort,";","")
	endif
	result+=WaveList(str,";","")
	SetDataFolder $dfSave
	return result
end
//
//Function IN2_PopMenuProc_Fldr(ctrlName,popNum,popStr) : PopupMenuControl		//sets folder to raw subfolder if selected
//	String ctrlName
//	Variable popNum
//	String popStr
//	
//	if (!stringmatch(popStr, "*--*"))
//		String df="root:raw:'"+popStr+"'"
//		SetDataFolder $df
//	endif
//End
//
//
//Function IN2_PopMenuProc_SpecRun(ctrlName,popNum,popStr) : PopupMenuControl	//sets folder to specXX folder in raw
//	String ctrlName
//	Variable popNum
//	String popStr
//
//	if (!stringmatch(popStr, "*--*" ))													//if valid folder selected go there
//		SVAR /Z SpecFile=root:Packages:Indra3:PanelSpecScanSelected				//set global string and creates it, if needed
//		if (!SVAR_Exists(SpecFile))
//			string/g root:Packages:Indra3:PanelSpecScanSelected
//			SVAR SpecFile=root:Packages:Indra3:PanelSpecScanSelected				//set global string and creates it, if needed
//		endif
//		SpecFile=GetDataFolder(1)+popStr											//this sets the global string
//		IN2_GenerateTheLiberalName("yes")										//this generates name for the folder where the data will go
//		IN2_GetDataTransferredTo()												//this pulls out the list of folders, where we already transferred the data
//	endif																		//and puts it into the panel
//End
//
//
//Function IN2_WavesPanelControl(ctrlName,popNum,popStr) : PopupMenuControl			//bunch of procedures for the panel control
//	String ctrlName															
//	Variable popNum
//	String popStr
//	
//	SVAR TR_list=root:Packages:Indra3:RawToUSAXS
//	
//	if (cmpstr(ctrlName,"SelectPDWaveName")==0)
//		TR_List=ReplaceStringByKey("USAXS_PD", TR_list,  popStr,"=")
//	Endif
//
//	if (cmpstr(ctrlName,"Monitor")==0)
//		TR_List=ReplaceStringByKey("Monitor", TR_list,  popStr,"=")
//	Endif
//	if (cmpstr(ctrlName,"PDrange")==0)
//		TR_List=ReplaceStringByKey("PD_range", TR_list,  popStr,"=")	
//	Endif
//	if (cmpstr(ctrlName,"AREnc")==0)
//		TR_List=ReplaceStringByKey( "AR_enc", TR_list, popStr,"=")
//	Endif
//	if (cmpstr(ctrlName,"Timew")==0)
//		TR_List=ReplaceStringByKey("Time", TR_list, popStr,"=")
//	Endif
//End
//
//
//Function IN2_DeleteWavesFromRaw(ctrlName) : ButtonControl					//this creates list of waves which will be deleted 
//	String ctrlName														//from raw
//
//	SVAR/Z str1=root:Packages:Indra3:ListOfWavesToDeleteFromRaw
//	SVAR/Z str2=root:Packages:Indra3:TempListOfWavesToDeleteFromRaw
//	
//	if(!SVAR_Exists(str1))
//		string/G root:Packages:Indra3:ListOfWavesToDeleteFromRaw
//		SVAR str1=root:Packages:Indra3:ListOfWavesToDeleteFromRaw
//	endif
//	if(!SVAR_Exists(str2))
//		string/G root:Packages:Indra3:TempListOfWavesToDeleteFromRaw
//		SVAR str2=root:Packages:Indra3:TempListOfWavesToDeleteFromRaw
//	endif
//	
//	//here goes procedure to delete waves
//	Execute "IN2_PanelToSelectDeleteWaves()"								//this creates the panel for user control
//End
//
//
//
//
//Function IN2_SelectWhichWavesToDelete1(ctrlName,popNum,popStr) : PopupMenuControl	//what this one does?
//	String ctrlName
//	Variable popNum
//	String popStr
//
//	SVAR TempDeleteList=root:Packages:Indra3:TempListOfWavesToDeleteFromRaw
//	if (!stringmatch(popStr,"----"))
//		TempDeleteList=popStr
//	endif
//End
//
//Function IN2_AddToDeleteList(ctrlName) : ButtonControl				//button control which adds wave name to delete list
//	String ctrlName
//
//	SVAR ListToDelete=root:Packages:Indra3:ListOfWavesToDeleteFromRaw
//	SVAR TempListToDelete=root:Packages:Indra3:TempListOfWavesToDeleteFromRaw
//
//	if (!stringmatch(ListToDelete, "*"+TempListToDelete+"*"))
//		ListToDelete+=TempListToDelete + ";"
//	endif
//End
//
//Window IN2_PanelToSelectDeleteWaves() : Panel								//panel for user to select waves to delete
//	PauseUpdate    		// building window...
//	NewPanel /K=1/W=(320.25,305,728.25,553.25)
//	SetDrawLayer UserBack
//	SetDrawEnv fsize= 16,fstyle= 1
//	DrawText 31,23,"Here you can select waves which will be "
//	SetDrawEnv fsize= 16,fstyle= 1
//	DrawText 30,45,"DELETED from raw data."
//	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (65280,16384,16384)
//	DrawText 63,72,"Use this ONLY when really sure!!"
//	SetDrawEnv fsize= 14,fstyle= 3
//	DrawText 16,151,"This is List of waves you want to delete:"
//	SetDrawEnv linepat= 2,linefgc= (65535,65535,65535),fillfgc= (52224,52224,52224)
//	DrawRect 24,195,217,240
//	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (65280,16384,16384)
//	DrawText 46,225,"Kill panel when done"
//	PopupMenu SelectWave,pos={8,93},size={169,21},proc=IN2_SelectWhichWavesToDelete1,title="Select wave to delete:"
//	PopupMenu SelectWave,mode=1,popvalue="----",value= #"\"----;\"+IN2G_CreateListOfItemsInFolder(root:Packages:Indra3:PanelSpecScanSelected,2)"
//	Button AppendToListToDelete,pos={279,93},size={120,20},proc=IN2_AddToDeleteList,title="Add to delete list"
//	SetVariable ListOfWavesToDelete,pos={12,158},size={400,19},title=" ",fSize=12
//	SetVariable ListOfWavesToDelete,limits={-Inf,Inf,1},value= root:Packages:Indra3:ListOfWavesToDeleteFromRaw
//	Button ClearDeleteList,pos={271,188},size={100,20},proc=IN2_ClearDeleteList,title="Clear Delete list"
//	DoUpdate
//EndMacro
//
//Function IN2_ClearDeleteList(ctrlName) : ButtonControl							//clear the delete list
//	String ctrlName
//
//	SVAR ListToClear=root:Packages:Indra3:ListOfWavesToDeleteFromRaw
//	
//	ListToClear=""
//End
//
////End of panel area
////*************************************************************************************************************
////*************************************************************************************************************
//
//Function IN2_ConvertSpecSetVarProc(sva) : SetVariableControl
//	STRUCT WMSetVariableAction &sva
//
//	switch( sva.eventCode )
//		case 1: // mouse up
//		case 2: // Enter key
//				IN2_CreateDialogForRangeSel()
//		case 3: // Live update
//			Variable dval = sva.dval
//			String sval = sva.sval
//			break
//		case -1: // control being killed
//			break
//	endswitch
//
//	return 0
//End
//
//
////*************************************************************************************************************
//// ***************Begining of RAW to USAXS conversion************************************************
//
//
//Function IN2_ConvertRAW_To_USAXSFnct()										//function to convert Raw to USAXS
//	string/G root:Packages:Indra3:NewUSAXSSubfolder=""
//	string/G root:Packages:Indra3:USAXSSubfolder=""							//setup global strings
//	string/G root:Packages:Indra3:NextRTUtoConvert="----"
//	string/G root:Packages:Indra3:ListOfTransfers=" -- "
//
//	string df1=GetdataFolder(1)						//next few lines can change the folder, including the FldrRAW
//	IN2_CheckForRawToUSAXSSet()					//check if tranfer table is somehow set
//	if (strlen(WinList("*RawTo*", ",", "")))				//if not, let user to set it
//		PauseForUser IN2_RawToUSAXSPanel  
//	endif
//	SetDataFolder $df1								//here we should have recovered if the input was needed
//
//	Execute ("IN2_ConvertRAW_To_USAXS()")			//give user the panel to do selective transfer
//end
//
//
//Window IN2_ConvertRAW_To_USAXS() : Panel			//the panel to convert Raw to USAXS one by one
//	PauseUpdate    		// building window...
//	NewPanel /K=1/W=(393.75,77,906,449)
//	SetDrawLayer UserBack
//	DrawRect 55,253,460,295
//	SetDrawEnv fsize= 16,fstyle= 1
//	DrawText 105,22,"Convert SPEC data to USAXS one by one"
//	SetDrawEnv fsize= 14,fstyle= 1
//	DrawText 19,318,"This is list of raw-to-USAXS conversions you selected: "
//	SetDrawEnv fsize= 16,fstyle= 5,textrgb= (65280,0,0)
//	DrawText 64,283,"When ready push button:"
//	SetDrawEnv fstyle= 1
//	DrawText 25,111,"The USAXS data go to root:USAXS folder, do you want subfolder?"
//	DrawLine 27,91,454,91
//	SetDrawEnv fsize= 10
//	DrawText 245,64,"These data were already copied to USAXS fldr:"
//	PopupMenu SelectSPECFile,pos={5,34},size={171,21},proc=IN2_PopMenuProc_Fldr,title="Select RAW sub-folder"
//	PopupMenu SelectSPECFile,mode=1,popvalue="----",value= #"\"----;\"+IN2G_CreateListOfItemsInFolder(\"root:raw\",1)"
//	PopupMenu SelectScanFolder,pos={5,64},size={154,21},proc=IN2_PopMenuProc_SpecRun,title="Select scan folder: "
//	PopupMenu SelectScanFolder,mode=1,popvalue="----",value= #"root:Packages:Indra3:NextRTUtoConvert+\";\"+IN2_FindFolderWithScanTypes(GetDataFolder(1), 2, \"uascan\",0)" //IN2G_CreateListOfItemsInFolder(GetDataFolder(1),1)"
//	SetVariable CreateFolderName,pos={34,222},size={400,19},title="Modify USAXS Folder name?"
//	SetVariable CreateFolderName,fSize=12
//	SetVariable CreateFolderName,limits={-Inf,Inf,1},value= root:Packages:Indra3:LiberalUSAXSFolderName
//	SetVariable ListOfRawToUSAXS,pos={20,323},size={450,16},title=" ",fSize=9
//	SetVariable ListOfRawToUSAXS,limits={-Inf,Inf,1},value= root:Packages:Indra3:RawToUSAXS
//	Button CallRawToUSAXSProc,pos={143,345},size={240,20},proc=IN2_CallRawToUSAXSProc,title="Change Raw-to-USAXS conv."
//	Button GenerateLibName,pos={33,194},size={220,20},proc=IN2_GenerateTheLiberalName,title="Generate USAXS Folder name"
//	Button DoRawToUSAXSConv,pos={269,265},size={180,20},proc=IN2_DoRawToUSAXSConversion,title="Do the conversion"
//	PopupMenu ListOfUSAXSfldrs,pos={23,117},size={211,21},proc=IN2_Set2USAXSSubFolder,title="Select subfolder for USAXS data:"
//	PopupMenu ListOfUSAXSfldrs,mode=2,popvalue=" ",value= #"root:Packages:Indra3:USAXSSubfolder+\";\"+\" ;\"+IN2_GenListOfFoldersInUSAXS()"
//	SetVariable NewUSAXSFldrname,pos={12,149},size={440,19},title="Create new subfolder for USAXS data?"
//	SetVariable NewUSAXSFldrname,fSize=12
//	SetVariable NewUSAXSFldrname,limits={-Inf,Inf,1},value= root:Packages:Indra3:NewUSAXSSubfolder
//	Button CreateNewFldr,pos={300,175},size={210,20},proc=IN2_SetUSAXSSubfolder,title="Create new USAXS subfolder"
//	SetVariable ShowTransferredTo,pos={230,68},size={260,16},title=" ",fSize=5
//	SetVariable ShowTransferredTo,limits={-Inf,Inf,1},value= root:Packages:Indra3:ListOfTransfers,noedit= 1
//EndMacro
//
////Function IN2_RefreshUSAXSLibName(ctrlName,varNum,varStr,varName) : SetVariableControl
////	String ctrlName			//variable control to refresh Liberal name in the panel on change of some parameters
////	Variable varNum
////	String varStr
////	String varName
////
////	 IN2_GenerateLibUSAXSFolderName()
////End
//
//Function/S IN2_FindFolderWithScanTypes(startDF, levels, ScanType, LongShortType)	//finds folders with scan types, scan type depends on SpecCommand
//        String startDF, ScanType                  // startDF requires trailing colon.
//        Variable levels, LongShortType		//set 1 for long type and 0 for short type return
//        			//returns the list of folders with specCommand with "uascan" in it - may not work yet for sbuascan 
//        String dfSave
//        String list = "", templist
//        
//        dfSave = GetDataFolder(1)
//        SetDataFolder startDF
//        
//       // templist = DataFolderDir(0)
//        templist = DataFolderDir(1)
//    	 SVAR/Z Command=specCommand
//    	 if (SVAR_exists (Command))
//        	if (stringmatch(Command,ScanType+"*"))
//			if (LongShortType)
//	            		list += startDF + ";"
//      		      	else
//      		      		list += GetDataFolder(0) + ";"
//        		endif
//        	endif
//        endif
//        
//        levels -= 1
//        if (levels <= 0)
//                return list
//        endif
//        
//        String subDF
//        Variable index = 0
//        do
//                String temp
//                temp = PossiblyQuoteName(GetIndexedObjName(startDF, 4, index))     	// Name of next data folder.
//                if (strlen(temp) == 0)
//                        break                                                                           			// No more data folders.
//                endif
//     	              subDF = startDF + temp + ":"
//            		 list += IN2_FindFolderWithScanTypes(subDF, levels, ScanType, LongShortType)       	// Recurse.
//                index += 1
//        while(1)
//        
//        SetDataFolder(dfSave)
//        return list
//End
//
//
//Function/T IN2_GetDataTransferredTo()										//this puts list of folders where the raw data were trnasferred to
//	SVAR subfolder=root:Packages:Indra3:PanelSpecScanSelected		
//	SVAR/Z ListR=root:Packages:Indra3:ListOfTransfers
//		if (!SVAR_Exists(ListR))
//			string/g root:Packages:Indra3:ListOfTransfers
//			SVAR ListR=root:Packages:Indra3:ListOfTransfers
//		endif
//		string str=subfolder
//		if (!stringmatch(str,"*--*"))
//			str +=":DataTransferredto"
//			SVAR/Z ListR1=$str
//			if(SVAR_Exists(ListR1))
//				ListR=ListR1
//			else
//				ListR= " -- "
//			endif
//		else
//			ListR="  --  "
//		endif
//end
//
//Function/T IN2_GenListOfFoldersInUSAXS()						//creates list of folders in the USAXS folder
//	string str="---"
//	if (DataFolderExists("root:USAXS"))
//		string df=GetDataFolder(1)
//		SetDataFolder root:USAXS
//		str=IN2G_ConvertDataDirToList(DataFolderDir(1))
//		SetDataFolder $df
//	endif
//	return str
//end
//
//
//Function IN2_SetUSAXSSubfolder(ctrlName) :ButtonControl		//sets the USAXS subfolder selected in the panel
//	String ctrlName
//		
//	SVAR USAXSsubf=root:Packages:Indra3:NewUSAXSSubfolder
//	SVAR USAXSsetTo=root:Packages:Indra3:USAXSSubfolder
//	string str = "root:USAXS:"+PossiblyQuoteName(CleanupName(USAXSsubf,1))
//	if (!DataFolderExists("root:USAXS"))
//		NewDataFolder root:USAXS
//	endif
//	if (!DataFolderExists(str))
//		NewDataFolder $str
//	endif
//	USAXSsetTo=USAXSsubf
//end	
//
Function/T IN2_GenerateLibUSAXSFolderName()			//complicated way to create unique & liberal name of USAXS data
	
	SVAR/Z LibName=root:Packages:Indra3:LiberalUSAXSFolderName			//global string with the name for panel
	if (!SVAR_Exists(LibName))
		string/G root:Packages:Indra3:LiberalUSAXSFolderName=""
		SVAR LibName=root:Packages:Indra3:LiberalUSAXSFolderName			//global string with the name for panel
	endif
	
	SVAR SpecDataFolder=root:Packages:Indra3:PanelSpecScanSelected	//pointer to raw specXX data 
	string ScanNumber=StringFromList(ItemsInList(SpecDataFolder,":")-1, SpecDataFolder , ":")	//this should give me specXXX
	ScanNumber="S"+ScanNumber[4,inf]+"_"									//and this SXXX
	string df=GetDataFolder(1)												//thats where we start
	string commentName=SpecDataFolder+":SpecComment"					//spec comment pointer
	SVAR comment=$commentName										//spec comment content
	SVAR/Z USAXSSFldr=root:Packages:Indra3:USAXSSubfolder				//USAXS subfolder where user wants to put data
	if(!SVAR_Exists(USAXSSFldr))											//create it if it does not exist
		string/g root:Packages:Indra3:USAXSSubfolder
		SVAR USAXSSFldr=root:Packages:Indra3:USAXSSubfolder				//USAXS subfolder where user wants to put data
		USAXSSFldr=""
	endif
	string USAXSpath="root:USAXS:"										//create pointer to the USAXS data subfolder
	if (strlen(USAXSSFldr)>1)
		USAXSpath+=possiblyquotename(USAXSSFldr)
	endif	
	LibName=ScanNumber+CleanupName(comment, 1 )									//clean it up
	
	if (DataFolderExists(USAXSpath ))										//go there..
		SetDataFolder $USAXSpath 
		if (CheckName(LibName, 11)!=0)				//this needs to be in root:USAXS:subfldr to work
			LibName+="_"
			LibName=UniqueName(LibName, 11, 0)			//check if the name exists and create unique name
		endif
		SetDataFolder $df								//go back
	endif
	Libname= PossiblyQuoteName(LibName)				//cleanup the name
	return Libname
end
//
//
//
//Function IN2_CallRawToUSAXSProc(ctrlName) : ButtonControl		//call the Raw to USAXS panel
//	String ctrlName
//
//	Execute ("IN2_RawToUSAXSPanel()")						//call the panel
//End
//
//Function IN2_GenerateTheLiberalName(ctrlName) : ButtonControl		//Button which calls the Generate Liberal names - refresh
//	String ctrlName
//	
//	SVAR/Z newname=root:Packages:Indra3:LiberalUSAXSFolderName		//check if the needed global string exist 
//	if (!SVAR_Exists(newname))
//		string/g root:Packages:Indra3:LiberalUSAXSFolderName
//		SVAR newname=root:Packages:Indra3:LiberalUSAXSFolderName		//check if the needed global string exist 
//	endif
//	newname=IN2_GenerateLibUSAXSFolderName()						//sets the global string to liberal name
//End
//
Function IN2_CheckRawToUSAXSConversion()						//this checks, if the waves in the conversion table exists, if not calls the input panel

	string oldf=GetDataFolder(1)
	
	SVAR RawToUSAXS=root:Packages:Indra3:RawToUSAXS				//table for raw to USAXS conv.
	//assume, that we are in the proper folder
	variable OK=1
	string ListOfWaves=DataFolderDir(2)
	//AR_enc=ar_enc;PD_range=pd_range;USAXS_PD=USAXS_PD;Time=seconds;Monitor=I0
	if (!stringMatch(ListOfWaves, "*"+StringByKey("AR_enc", RawToUSAXS , "=")+"*"))
		OK=0
	endif
	if (!stringMatch(ListOfWaves, "*"+StringByKey("PD_range", RawToUSAXS , "=")+"*"))
		OK=0
	endif
	if (!stringMatch(ListOfWaves, "*"+StringByKey("USAXS_PD", RawToUSAXS , "=")+"*"))
		OK=0
	endif
	if (!stringMatch(ListOfWaves, "*"+StringByKey("Time", RawToUSAXS , "=")+"*"))
		OK=0
	endif
	if (!stringMatch(ListOfWaves, "*"+StringByKey("Monitor", RawToUSAXS , "=")+"*"))
		OK=0
	endif

	//if the OK is =0 we had problem...
	if (OK==0)
		SVAR param=root:Packages:Indra3:PanelSpecScanSelected
		SVAR USAXSLastFolder=root:Packages:Indra3:USAXSRawDataFolder	//This is pointer to last USAXS used subfolder
		param=GetDataFolder(1)
		IN2_RAWtoUSAXSParametersSetup(1)
		
		PauseForUser IN2_RawToUSAXSPanel
	
	endif
	
	SetDataFolder $oldf
end
//
//
Function IN2_DoRawToUSAXSConversion(ctrlName) : ButtonControl			//this function converts data to USAXS
	String ctrlName
	//here we do raw to USAXS conversion
	SVAR RawToUSAXS=root:Packages:Indra3:RawToUSAXS				//table for raw to USAXS conv.
	SVAR RawFolder=root:Packages:Indra3:PanelSpecScanSelected			//which data we want to convert?
	SVAR/Z ListOfDeleteWaves=root:Packages:Indra3:ListOfWavesToDeleteFromRaw 	//want to delete something
	SVAR USAXSFolder=root:Packages:Indra3:LiberalUSAXSFolderName		//Liberal name for new USAXS folder
	SVAR USAXSSubFolder=root:Packages:Indra3:USAXSSubfolder			//USAxs SUBFOLDER
	
	
	string df=GetDataFolder(1)												//save where we are
	SetDataFolder $RawFolder												//go where we want to be

	IN2_CheckRawToUSAXSConversion()									//check if the RawToUSAXS conversion table is correct

	variable SScanIntegrity=IN2_CheckScanIntegrity()							//this function test for scan integrity
			//that is, if the number of scan points is ~ number in spec command and monitor count is >5000 for all points, 1 is returned
	if (SScanIntegrity)				//if =1 the the scan passed integrity check
		SVAR/Z DataTransferredto=DataTransferredto								//define global strings in the raw spec folder, where we want to work
		SVAR specCommand=specCommand
		SVAR SpecComment=SpecComment
		SVAR SpecMotors=SpecMotors
		SVAR SpecSourceFileName=SpecSourceFileName
		
		if (SVAR_Exists(ListOfDeleteWaves))								//here we delete waves if user chose to
			variable i=0
			string WaveNameDelete
			for(i=0;i<ItemsInList(ListOfDeleteWaves);i+=1)	
				WaveNameDelete=StringFromList(i,ListOfDeleteWaves)
				KillWaves/Z $WaveNameDelete						
			endfor										
		endif
		
		if (!DataFolderExists("root:USAXS"))									//this creates USAXS folder if it does not exist
			NewDataFolder root:USAXS
		endif
		
		string tempname="root:USAXS:"
		
		if (strlen(USAXSSubFolder)>2)												//this creates USAXS subfolder, if wantred and does not exist
			tempname="root:USAXS:"+PossiblyQuoteName(USAXSSubFolder)+":"
			if (!DataFolderExists(tempname))				//this creates USAXS folder if it does not exist
				NewDataFolder $tempname
			endif 
		endif
		
		//tempname+=possiblyquotename(USAXSFolder)						//this creates sample folder name
		tempname+=USAXSFolder						//this creates sample folder name, should be already checked...
	
		if (!DataFolderExists(tempname))									//this creates sample folder if it does not exist
			NewDataFolder $tempname
		endif
	
		if (!SVAR_Exists(DataTransferredto))								//here we save where we transferred the raw data
			string/G DataTransferredto
			SVAR DataTransferredto=DataTransferredto								//define global strings in the raw spec folder, where we want to work
		endif
		DataTransferredto+=tempname+";"
		
		string TempWaveName="", TempNewWaveName=""					//note for waves to be appended to each USAXS wave
		string  newnote="SpecCommand="+SpecCommand+";SpecComment="+SpecComment+";SpecScan="+GetDataFolder(0)+";"
		newnote+="USAXSDataFolder="+tempname+";RawFolder="+GetDataFolder(1)+";"		//remove ":" from folder poitners
		newnote+="UserSampleName="+USAXSFolder+";"
		string oldnote
		
		TempWaveName=StringByKey("AR_enc", RawToUSAXS,"=")		//this creates copy of ARencoder wave
		TempNewWaveName=tempname+":AR_encoder"
		Duplicate/O $TempWaveName, $TempNewWaveName
		oldnote=Note($TempNewWaveName)
		Note/K $TempNewWaveName
		note $TempNewWaveName, oldnote+newnote+"Wname=AR_encoder;"
		wave wv1=$TempNewWaveName
		
		TempWaveName=StringByKey("PD_range", RawToUSAXS,"=")		//this creates copy of PD range wave
		TempNewWaveName=tempname+":PD_range"
		Duplicate/O $TempWaveName, $TempNewWaveName
		oldnote=Note($TempNewWaveName)
		Note/K $TempNewWaveName
		note $TempNewWaveName, oldnote+newnote+"Wname=PD_range;"
		wave wv2=$TempNewWaveName
		
		TempWaveName=StringByKey("USAXS_PD", RawToUSAXS,"=")		//this creates copy of USAXS PD wave
		TempNewWaveName=tempname+":USAXS_PD"
		Duplicate/O $TempWaveName, $TempNewWaveName
		oldnote=Note($TempNewWaveName)
		Note/K $TempNewWaveName
		note $TempNewWaveName, oldnote+newnote+"Wname=USAXS_PD;"
		wave wv3=$TempNewWaveName
		
		TempWaveName=StringByKey("Time", RawToUSAXS,"=")		//this creates copy of measurement time wave
		TempNewWaveName=tempname+":MeasTime"
		Duplicate/O $TempWaveName, $TempNewWaveName
		oldnote=Note($TempNewWaveName)
		Note/K $TempNewWaveName
		note $TempNewWaveName, oldnote+newnote+"Wname=MeasTime;"
		wave wv4=$TempNewWaveName
		
		TempWaveName=StringByKey("Monitor", RawToUSAXS,"=")		//this creates copy of monitors wave
		TempNewWaveName=tempname+":Monitor"
		Duplicate/O $TempWaveName, $TempNewWaveName
		oldnote=Note($TempNewWaveName)
		Note/K $TempNewWaveName
		note $TempNewWaveName, oldnote+newnote+"Wname=Monitor;"
		wave wv5=$TempNewWaveName
		
		TempWaveName="I0_gain"										//this creates copy of I0 range wave
		TempNewWaveName=tempname+":I0_gain"
		Wave/Z testWV=$TempWaveName
		if(WaveExists(testWV))
			Duplicate/O $TempWaveName, $TempNewWaveName
			oldnote=Note($TempNewWaveName)
			Note/K $TempNewWaveName
			note $TempNewWaveName, oldnote+newnote+"Wname=I0_gain;"
		endif
		
		wave/Z wv6=$TempNewWaveName
		if(WaveExists(wv6))
			//clean up any NaNs from the waves here... 
			IN2G_RemoveNaNsFrom6Waves(Wv1,wv2,wv3,wv4,wv5,wv6)
		else
			//clean up any NaNs from the waves here... 
			IN2G_RemoveNaNsFrom5Waves(Wv1,wv2,wv3,wv4,wv5)
		endif
		string NewStringName=""
		NewStringName=tempname+":SpecCommand"				//here we copy specCommand to USAXS folder
		string/G $NewStringName=specCommand
		
		NewStringName=tempname+":SpecSourceFileName"			//here we copy SpecSourceFileName to USAXS folder
		string/G $NewStringName=SpecSourceFileName
	
		NewStringName=tempname+":SpecComment"				//here we copy specComent to USAXS folder
		string/G $NewStringName=SpecComment

		NewStringName=tempname+":SpecMotors"				//here we copy SpecMotors to USAXS folder
		string/G $NewStringName=SpecMotors

		//here goes extraction of some measurement parameters such as energy etc. 

		string MeasParam=""
		SVAR EPICS_PVs=EPICS_PVs		//I assume here, that UPD section starts with UPDmode keyword.
		MeasParam="DCM_energy="+StringByKey("DCM_energy",EPICS_PVs)+";"
		MeasParam+= IN2G_ChangePartsOfString( EPICS_PVs[strsearch(EPICS_PVs,"UPD",0), inf], ":", "=")
		NewStringName=tempname+":MeasurementParameters"
		string/g $NewStringName=MeasParam
		
		string UPDParam=""					//this creates list with UPD parameters from EPICS_PVs using the conversion in RawToUSAXS
		UPDParam="Vfc="+StringByKey(StringByKey("Vfc",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="Gain1="+StringByKey(StringByKey("Gain1",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="Gain2="+StringByKey(StringByKey("Gain2",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="Gain3="+StringByKey(StringByKey("Gain3",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="Gain4="+StringByKey(StringByKey("Gain4",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="Gain5="+StringByKey(StringByKey("Gain5",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="Bkg1="+StringByKey(StringByKey("Bkg1",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="Bkg2="+StringByKey(StringByKey("Bkg2",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="Bkg3="+StringByKey(StringByKey("Bkg3",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="Bkg4="+StringByKey(StringByKey("Bkg4",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="Bkg5="+StringByKey(StringByKey("Bkg5",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="Bkg1Err="+StringByKey(StringByKey("Bkg1Err",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="Bkg2Err="+StringByKey(StringByKey("Bkg2Err",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="Bkg3Err="+StringByKey(StringByKey("Bkg3Err",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="Bkg4Err="+StringByKey(StringByKey("Bkg4Err",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="Bkg5Err="+StringByKey(StringByKey("Bkg5Err",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="I0AmpDark="+StringByKey(StringByKey("I0AmpDark",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParam+="I0AmpGain="+StringByKey("I0AmpGain",EPICS_PVs)+";"
		UPDParam+="I00AmpGain="+StringByKey("I00AmpGain",EPICS_PVs)+";"
		UPDParam+="UPDsize="+StringByKey("UPDsize",EPICS_PVs)+";"
		//after 4/2012 we satrted to create I0_gain column of data. This cannot become stale as the value in header can, so let's use that if it is available...
		Wave/Z I0_gain
		if(WaveExists(I0_gain))
			UPDParam = ReplaceStringByKey("I0AmpGain", UPDParam, num2str(I0_gain[2]),"=",";")
		endif
		
		NewStringName=tempname+":UPDParameters"
		string/g $NewStringName=UPDParam
		//here we make pointer to original data:
		NewStringName=tempname+":PathToRawData"
		string/g $NewStringName=GetDataFolder(1)

		//logging
		IN2G_AppendAnyText("\r")
		IN2G_AppendAnyText("RAW data from:\t\t\t"+ RawFolder+" \rConverted to USAXS data :\t"+tempname)
		IN2G_AppendAnyText("Following are the parameters used :  "+RawToUSAXS)	

	endif
	
	SetDataFolder df
	//last specXX converted is in RawFolder, how do I find out which is next?
	string LspecName=stringFromList(ItemsInList(RawFolder , ":")-1, RawFolder,":")
	SVAR/Z SetNextScan=root:Packages:Indra3:NextRTUtoConvert
	if (!SVAR_Exists(SetNextScan))
		string/G root:Packages:Indra3:NextRTUtoConvert
		SVAR SetNextScan=root:Packages:Indra3:NextRTUtoConvert
	endif
	SetNextScan=IN2_GenNextScanToProcess(LspecName)

End
//
Function IN2_CheckScanIntegrity()		//checks if the scan has proper number of points and if beam did not dump
		//I assume I am in the folder where I need to be
	variable valid=1
	
	SVAR specCommand
	SVAR RawToUSAXS=root:Packages:Indra3:RawToUSAXS
	Wave Monitor=$stringByKey("Monitor",RawToUSAXS ,"=")
	
	variable WantedPoints=str2num(StringFromList(ItemsInList(specCommand," ")-2, specCommand ," ") )
	if (numpnts(Monitor)<(WantedPoints-5))			//assumption, differenc ein more than 3 points mean canceled scan
		DoAlert 1, "Number of points for "+GetDataFolder(1)+" is significantly smaller than should be, probably canceled scan. Do you want to skip the scan?"
	endif
	if (V_flag==1)
		Valid = 0
		return Valid
	endif
	if(Numpnts(Monitor)<5)
		return 0			//bad data set in any case, skip... 
	endif
	wavestats/Q/R=[numpnts(Monitor)/4,numpnts(Monitor)-5] Monitor
	if (V_min<LimitValForMoniToAssumeBeamDump)			//assumption - the monitor count below 5000 is beam dump
		DoAlert 1, "Monitor counts for "+GetDataFolder(1)+" is very low, probably beam dump. Do you want to skip the scan?"
	endif
	if (V_flag==1)
		Valid = 0
		return Valid
	endif
	return Valid
end
//
Function/T IN2_GenNextScanToProcess(scan)								//this returns next scanX in the folder or XX 
	string scan
	
	string DirListing=IN2G_ConvertDataDirToList(DataFolderDir(1))
	variable i=0, imax=ItemsInList(DirListing)
	for(i=0;i<imax;i+=1)	
		if (stringmatch(StringFromList(i,DirListing),scan))
			return StringFromList(i+1,DirListing)
		endif				
	endfor										
	return "XXX"
end

Function IN2_Set2USAXSSubFolder(ctrlName,popNum,popStr) : PopupMenuControl	//Generates the liberal name and puts it in the global string for future use
	String ctrlName
	Variable popNum
	String popStr
	
	SVAR/Z str=root:Packages:Indra3:USAXSSubfolder
	if (!SVAR_Exists(str))
		string/G root:Packages:Indra3:USAXSSubfolder
		SVAR str=root:Packages:Indra3:USAXSSubfolder
	endif
	str=popstr
	SVAR USAXSname=root:Packages:Indra3:LiberalUSAXSFolderName 
	USAXSname=IN2_GenerateLibUSAXSFolderName()
End
//
//
//
//**********This is set of macros which allows user to load set of scans
//********************************************************************************************
//********************************************************************************************
//
Function IN2_CovertRaw_To_USAXSAutoF(Automat)		
	variable automat //this will be set to 1, if called from routine which needs to have some parts skipped			
	//this function gets input from user which range of spec scans to convert to USAXS and does it in auto cycle
	//Automatic liberal names are generated for USAXS folders, based on SpecComment
	//assume, that RawToUSAX conversion is properly set, including delete
	//first we need local definitions of some strings:
	SVAR/Z FldrRAW=root:Packages:Indra3:PanelSpecScanSelected			//OK definitions of global strings to be used
	if (!SVAR_Exists(FldrRAW))
		string/G root:Packages:Indra3:PanelSpecScanSelected
		SVAR FldrRAW=root:Packages:Indra3:PanelSpecScanSelected			//OK definitions of global strings to be used
	endif
	
	SVAR ListOfRawLoaded=root:Packages:Indra3:ListOfLoadedScans
	
	SVAR/Z SubFldrUSAXS=root:Packages:Indra3:USAXSSubfolder
	if (!SVAR_Exists(SubFldrUSAXS))
		string/G root:Packages:Indra3:USAXSSubfolder
		SVAR SubFldrUSAXS=root:Packages:Indra3:USAXSSubfolder
	endif
	
	SVAR/Z USAXSFolder=root:Packages:Indra3:LiberalUSAXSFolderName
	if (!SVAR_Exists(USAXSFolder))
		string/G root:Packages:Indra3:LiberalUSAXSFolderName
		SVAR USAXSFolder=root:Packages:Indra3:LiberalUSAXSFolderName
	endif
	//this runs in root:raw so lets get there
	
	SetDataFolder root:raw											//here we need to start
	
	//Definitions
	string RawSubfolder, SpecList=ListOfRawLoaded, ListofScans, USAXSSubfolder,ListorRange, SpecStart, SpecEnd, FldrNamePrefix
	//	Variable 
	//Now we need to get user input, if automat is set to 0
	if (Automat)
		//if called automatically, we shoudl know where the data are
		SVAR USAXSDataSubldr=root:Packages:Indra3:USAXSRawDataFolder
		FldrRAW=USAXSDataSubldr
		SetDataFolder $USAXSDataSubldr
	else
		Prompt RawSubfolder, "Select subfolder with RAW data", popup, " -- ;"+IN2G_CreateListOfItemsInFolder("root:raw:",1)
	
		DoPrompt "Select RAW data subfolder", RawSubfolder					//select subfolder	
		if (V_Flag==1)
			abort
		endif
	
		FldrRAW="root:raw:"
		if(!stringmatch(RawSubfolder, "*--*"))									//if subfolder selected, go there
			SetDataFolder $RawSubfolder
			FldrRAW+=RawSubfolder
		endif
	endif


	String ExistingUSAXSsubfolder=""
	USAXSSubfolder=stringFromList(ItemsInList(GetDataFolder(1),":")-1, GetDataFolder(1),":")				//force user to use same folder for raw data
	if (cmpstr(USAXSSubfolder,"RAW")==0)
		USAXSSubfolder=""
	endif
												//get user input 
	Prompt ListorRange, "Convert to USAXS set of range of scans or the last loaded raw data? ", popup, "All of Last Loaded data set;Range"
	Prompt SpecStart, "Select RANGE start spec scan", popup, IN2G_CreateListOfScans(GetDataFolder(1))
	Prompt SpecEnd, "Select RANGE end spec scan", popup, IN2G_CreateListOfScans(GetDataFolder(1))
//	Prompt SpecList, "List the last loaded scans (Works ONLY for last loaded, you can remove some)"
	Prompt USAXSSubfolder, "USAXS DATA : Create NEW subfolder in root:USAXS: ?"
	Prompt ExistingUSAXSsubfolder, "Or select existing folder in root:USAXS: ", popup, " ;"+IN2G_CreateListOfItemsInFolder("root:USAXS",1)

	if (Automat)
		ListorRange="All of Last Loaded data set"
	else		
		DoPrompt "Select scans to convert to USAXS", ListorRange, SpecStart, SpecEnd, USAXSSubfolder, ExistingUSAXSsubfolder
		if (V_Flag==1)
			abort 
		endif
	endif
	string df1=GetdataFolder(1)						//next few lines can change the folder, including the FldrRAW
	IN2_CheckForRawToUSAXSSet()					//check if tranfer table is somehow set
	if (strlen(WinList("*RawTo*", ",", "")))
		PauseForUser IN2_RawToUSAXSPanel  		//if we are aiting for user input, wait
	endif											//this may actually change working folder 
	SetDataFolder $df1								
	FldrRAW=df1									//here we should have working folder recovered if the input was needed
	
	if (!DataFolderExists("root:USAXS"))				//check for USAXS folder
		NewdataFolder root:USAXS
	endif
	string USAXSdataFolder="root:USAXS:"
	SubFldrUSAXS=""
	if (strlen(USAXSSubfolder)!=0)						//create USAXS subfolder if user wants it.
		string mnm="root:USAXS:"+PossiblyQuoteName(USAXSSubFolder)
		NewDataFolder/O $mnm						
		SubFldrUSAXS=PossiblyQuoteName(USAXSSubFolder)
		USAXSdataFolder+=SubFldrUSAXS
	else
		if (cmpstr(" ",ExistingUSAXSsubfolder)!=0)
			USAXSSubfolder=ExistingUSAXSsubfolder
			SubFldrUSAXS=USAXSSubFolder
			USAXSdataFolder+=SubFldrUSAXS
		endif
	endif
	
	//now load the data
	string CurrentDataFldr=GetDataFolder(1)					//here we are
												//now we do the data transfer****************
	if (!cmpstr (ListorRange, "All of Last Loaded data set"))						//user selected list of scans loaded last 
		variable Scans=ItemsInList(SpecList)					//number of scans
		variable i=0
		string currentName, commentName, dfold, commandName, ListOfNonUSAXS=""		//some strings
		for(i=0;i<Scans;i+=1)	
			currentName="spec"+num2str(str2num(stringFromList(i,SpecList)))
			FldrNamePrefix="S"+num2str(str2num(stringFromList(i,SpecList)))+"_"
			FldrRAW=CurrentDataFldr+currentName				//this should be raw data folder
			commandName=FldrRAW+":specCommand"			//this is path to command
			SVAR command=$commandName
			if (stringmatch(command,"*uascan*"))					//the scan was usaxs scan
				commentName=FldrRAW+":specComment"			//this should be path to specComment
				SVAR comment=$commentName
				USAXSFolder=FldrNamePrefix+CleanupName(comment, 1 )		//here we need ot check for existence of such folder
			
				SetDataFolder $USAXSdataFolder		
				if (CheckName(USAXSFolder, 11)!=0)
					USAXSFolder+="_"
					USAXSFolder=UniqueName(USAXSFolder, 11, 0)
				endif
				SetDataFolder $CurrentDataFldr						//returned
				USAXSFolder=PossiblyQuoteName(USAXSFolder)		//this is liberal name with USAXS new folder for the data
			 
				 IN2_DoRawToUSAXSConversion("yes")					//do the transfer, after we created the stage above
			else
				ListOfNonUSAXS+=currentName+";"					//create list of scans which were not usaxs
			endif
		endfor										
		if (strlen(ListOfNoNUSAXS)!=0)
		//	DoAlert 0, "Following non-USAXS scans were not converted:   "+ListOfNonUSAXS	//show user which folders were non-usaxs
		endif
	else													//here we do range, now if I only remebered how..
		variable SpecStartV=str2num(SpecStart[4,9])		//this returns number of the first spec scan
		variable SpecEndV=str2num(SpecEnd[4,9])			//this is the last spec scan
		
		string commandName1, ListOfNonUSAXS1=""		
		variable Scans1=SpecEndV-SpecStartV				//number of scans to be processed
		for(i=SpecStartV;i<SpecEndV+1;i+=1)				//here we set the stage for processing
			currentName="spec"+num2str(i)				//current name of spec scan folder
			FldrNamePrefix="S"+num2str(i)+"_"
			FldrRAW=CurrentDataFldr+currentName				//this should be raw data folder
			commandName1=FldrRAW+":specCommand"			//this is path to command
			SVAR/Z command1=$commandName1
			if (SVAR_Exists(command1))
				if (stringmatch(command1,"*uascan*"))						//the scan was usaxs scan
					commentName=FldrRAW+":specComment"				//this should be path to specComment
					SVAR/Z comment=$commentName
					if (SVAR_Exists(comment))							//here we test if the data exist to skip non existent folders
						USAXSFolder=FldrNamePrefix+CleanupName(comment, 1 )				//here we need ot check for existence of such folder
						SetDataFolder $USAXSdataFolder					//go to USAXs folder
						if (CheckName(USAXSFolder, 11)!=0)
							USAXSFolder+="_"
							USAXSFolder=UniqueName(USAXSFolder, 11, 0)
						endif
						SetDataFolder $CurrentDataFldr
						USAXSFolder=PossiblyQuoteName(USAXSFolder)		//this is liberal name with USAXS new folder for the data
						IN2_DoRawToUSAXSConversion("yes")					//do the transfer			
					endif
				else
					ListOfNonUSAXS1+=currentName+";"						//create the list of non usaxs folders
				endif	
			endif
		endfor
		if (strlen(ListOfNoNUSAXS1)!=0)
				DoAlert 0, "Following non-USAXS scans were not converted:   "+ListOfNonUSAXS1		//return to user the list of non usaxs folders
		endif
	endif
end

Function IN2_CheckForRawToUSAXSSet()							//check that the conversion table is set somehow
	SVAR ConvList=root:Packages:Indra3:RawToUSAXS			//
	if (stringmatch(ConvList, "*XX*" ))
		IN2_RAWtoUSAXSParametersSetup(0) 						//OK get user to set this properly
	endif
end


//********************************UPD selection and conversion*********************************************
//****************************************************************************************************************

Function IN2_SetRawToUSAXSConv()								//preset conversion for UPD using UPD2selected
	
	SVAR List=root:Packages:Indra3:RawToUSAXS
	SVAR pointer1=root:Packages:Indra3:PanelSpecScanSelected
	//is the last item in this string :?
	string pointer2
	if (cmpstr(":", pointer1[strlen(pointer1)-1])==0)
		pointer2=pointer1+"EPICS_PVs"
	else
		pointer2=pointer1+":EPICS_PVs"
	endif
	SVAR EpicsPVs=$pointer2

	List=ReplaceStringByKey("Energy", List, "DCM_energy","=")


	if (NumberByKey("UPD2selected",EpicsPVs))
		List=ReplaceStringByKey("Vfc", List, "UPD2vfc","=")
		List=ReplaceStringByKey("Gain1", List, "UPD2gain1","=")
		List=ReplaceStringByKey("Gain2", List, "UPD2gain2","=")
		List=ReplaceStringByKey("Gain3", List, "UPD2gain3","=")
		List=ReplaceStringByKey("Gain4", List, "UPD2gain4","=")
		List=ReplaceStringByKey("Gain5", List, "UPD2gain5","=")
		List=ReplaceStringByKey("Bkg1", List, "UPD2bkg1","=")
		List=ReplaceStringByKey("Bkg2", List, "UPD2bkg2","=")
		List=ReplaceStringByKey("Bkg3", List, "UPD2bkg3","=")
		List=ReplaceStringByKey("Bkg4", List, "UPD2bkg4","=")
		List=ReplaceStringByKey("Bkg5", List, "UPD2bkg5","=")
		List=ReplaceStringByKey("Bkg1Err", List, "UPD2bkgErr1","=")
		List=ReplaceStringByKey("Bkg2Err", List, "UPD2bkgErr2","=")
		List=ReplaceStringByKey("Bkg3Err", List, "UPD2bkgErr3","=")
		List=ReplaceStringByKey("Bkg4Err", List, "UPD2bkgErr4","=")
		List=ReplaceStringByKey("Bkg5Err", List, "UPD2bkgErr5","=")
		List=ReplaceStringByKey("I0AmpDark", List, "I0AmpDark","=")
		List=ReplaceStringByKey("I0AmpGain", List, "I0AmpGain","=")
	else
		List=ReplaceStringByKey("Vfc", List, "UPDvfc","=")
		List=ReplaceStringByKey("Gain1", List, "UPDgain1","=")
		List=ReplaceStringByKey("Gain2", List, "UPDgain2","=")
		List=ReplaceStringByKey("Gain3", List, "UPDgain3","=")
		List=ReplaceStringByKey("Gain4", List, "UPDgain4","=")
		List=ReplaceStringByKey("Gain5", List, "UPDgain5","=")
		List=ReplaceStringByKey("Bkg1", List, "UPDbkg1","=")
		List=ReplaceStringByKey("Bkg2", List, "UPDbkg2","=")
		List=ReplaceStringByKey("Bkg3", List, "UPDbkg3","=")
		List=ReplaceStringByKey("Bkg4", List, "UPDbkg4","=")
		List=ReplaceStringByKey("Bkg5", List, "UPDbkg5","=")	
		List=ReplaceStringByKey("Bkg1Err", List, "UPDbkgErr1","=")
		List=ReplaceStringByKey("Bkg2Err", List, "UPDbkgErr2","=")
		List=ReplaceStringByKey("Bkg3Err", List, "UPDbkgErr3","=")
		List=ReplaceStringByKey("Bkg4Err", List, "UPDbkgErr4","=")
		List=ReplaceStringByKey("Bkg5Err", List, "UPDbkgErr5","=")	
		List=ReplaceStringByKey("I0AmpDark", List, "I0AmpDark","=")
		List=ReplaceStringByKey("I0AmpGain", List, "I0AmpGain","=")
	endif
end


//
//Window IN2_PhotodiodeConvPanel() : Panel						//this allows user intervention if needed becaused my conversion does not work automatically
//	PauseUpdate    		// building window...
//	NewPanel /K=1 /W=(356.25,40.25,783.75,733.25)
//	SetDrawLayer UserBack
//	SetDrawEnv fstyle= 5
//	DrawText 42,21,"Create \"conversion\" for SPEC to USAXS PhotoDiode parameters"
//	SetDrawEnv fstyle= 1
//	DrawText 3,97,"Select proper relationship for each of following:"
//	SetDrawEnv gstart
//	SetDrawEnv fsize= 10
//	DrawText 70,661,"Note, that this sets default setting for this Igor file"
//	SetDrawEnv fsize= 10
//	DrawText 70,673,"If the data from different SPEC file are loaded"
//	SetDrawEnv fsize= 10
//	DrawText 70,685,"This macro may have to be rerun!!!"
//	SetDrawEnv gstop
//	SetDrawEnv gstart
//	DrawRect 351,75,426,131
//	SetDrawEnv fstyle= 1,textrgb= (65280,0,0)
//	DrawText 364,100,"Kill panel"
//	SetDrawEnv fstyle= 1,textrgb= (65280,0,0)
//	DrawText 355,123,"When done!"
//	SetDrawEnv gstop
//	PopupMenu SetSpecDataFldr,pos={20,25},size={170,21},proc=IN2_PopMenuProc_Fldr,title="Select Raw sub-Folder"
//	PopupMenu SetSpecDataFldr,mode=2,popvalue="----",value= #"\"----;\"+IN2G_CreateListOfItemsInFolder(\"root:raw\",1)"
//	PopupMenu SelectSpecRun,pos={20,50},size={139,21},proc=IN2_PopMenuProc_SpecRun,title="Select Spec run"
//	PopupMenu SelectSpecRun,mode=2,popvalue="----",value= #"\"----;\"+IN2G_CreateListOfItemsInFolder(GetDataFolder(1),1)"
//	PopupMenu Energy,pos={49,130},size={228,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with Energy: "
//	PopupMenu Energy,mode=1,popvalue=StringByKey("Energy", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"Energ\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu VtoF,pos={18,102},size={251,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with V to f conversion: "
//	PopupMenu VtoF,mode=1,popvalue=StringByKey("Vfc", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"vfc\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu UPDGain1,pos={22,161},size={250,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with UPD gain 1: "
//	PopupMenu UPDGain1,mode=1,popvalue=StringByKey("Gain1", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"Gain1\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu UPDGain2,pos={22,188},size={250,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with UPD gain 2: "
//	PopupMenu UPDGain2,mode=1,popvalue=StringByKey("Gain2", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"Gain2\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu UPDGain3,pos={22,214},size={250,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with UPD gain 3: "
//	PopupMenu UPDGain3,mode=1,popvalue=StringByKey("Gain3", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"Gain3\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu UPDGain4,pos={22,242},size={250,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with UPD gain 4: "
//	PopupMenu UPDGain4,mode=1,popvalue=StringByKey("Gain4", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"Gain4\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu UPDGain5,pos={22,269},size={250,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with UPD gain 5: "
//	PopupMenu UPDGain5,mode=1,popvalue=StringByKey("Gain5", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"Gain5\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu UPDBkg1,pos={17,310},size={248,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with UPD bkg 1: "
//	PopupMenu UPDBkg1,mode=1,popvalue=StringByKey("Bkg1", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"bkg1\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu UPDBkg2,pos={17,340},size={248,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with UPD bkg 2: "
//	PopupMenu UPDBkg2,mode=1,popvalue=StringByKey("Bkg2", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"bkg2\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu UPDBkg3,pos={17,369},size={248,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with UPD bkg 3: "
//	PopupMenu UPDBkg3,mode=1,popvalue=StringByKey("Bkg3", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"bkg3\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu UPDBkg4,pos={17,398},size={248,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with UPD bkg 4: "
//	PopupMenu UPDBkg4,mode=1,popvalue=StringByKey("Bkg4", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"bkg4\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu UPDBkg5,pos={17,428},size={248,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with UPD bkg 5: "
//	PopupMenu UPDBkg5,mode=1,popvalue=StringByKey("Bkg5", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"bkg5\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu UPDBkg1Err,pos={20,470},size={276,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with UPD bkg 1 error: "
//	PopupMenu UPDBkg1Err,mode=9,popvalue=StringByKey("Bkg1Err", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"bkgErr1\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu UPDBkg2Err,pos={20,501},size={276,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with UPD bkg 2 error: "
//	PopupMenu UPDBkg2Err,mode=9,popvalue=StringByKey("Bkg2Err", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"bkgErr2\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu UPDBkg3Err,pos={20,529},size={276,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with UPD bkg 3 error: "
//	PopupMenu UPDBkg3Err,mode=9,popvalue=StringByKey("Bkg3Err", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"bkgErr3\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu UPDBkg4Err,pos={20,560},size={276,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with UPD bkg 4 error: "
//	PopupMenu UPDBkg4Err,mode=9,popvalue=StringByKey("Bkg4Err", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"bkgErr4\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu UPDBkg5Err,pos={20,590},size={276,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with UPD bkg 5 error: "
//	PopupMenu UPDBkg5Err,mode=9,popvalue=StringByKey("Bkg5Err", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"bkgErr5\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//	PopupMenu I0AmpDark,pos={20,620},size={276,21},proc=IN2_FixRawToUSAXS_All,title="Select Key with I0 dark current: "
//	PopupMenu I0AmpDark,mode=9,popvalue=StringByKey("I0AmpDark", root:Packages:Indra3:RawToUSAXS,"="),value= #"IN2G_GetMeMostLikelyEPICSKey(\"I0AmpDark\")+\";\"+IN2G_GetMeListOfEPICSKeys()"
//
//
//EndMacro


Function IN2_FixRawToUSAXS_All(ctrlName,popNum,popStr) : PopupMenuControl		//this is popup control for above panel
	String ctrlName
	Variable popNum
	String popStr

	SVAR str=root:Packages:Indra3:RawToUSAXS
	
	if (cmpstr(ctrlname,"Energy")==0)
		str=ReplaceStringByKey("Energy", str, popStr,"=")
	endif
	if (cmpstr(ctrlname,"VtoF")==0)
		str=ReplaceStringByKey("Vfc", str, popStr,"=")
	endif
	if (cmpstr(ctrlname,"UPDGain1")==0)
		str=ReplaceStringByKey("Gain1", str, popStr,"=")
	endif
	if (cmpstr(ctrlname,"UPDGain2")==0)
		str=ReplaceStringByKey("Gain2", str, popStr,"=")
	endif
	if (cmpstr(ctrlname,"UPDGain3")==0)
		str=ReplaceStringByKey("Gain3", str, popStr,"=")
	endif
	if (cmpstr(ctrlname,"UPDGain4")==0)
		str=ReplaceStringByKey("Gain4", str, popStr,"=")
	endif
	if (cmpstr(ctrlname,"UPDGain5")==0)
		str=ReplaceStringByKey("Gain5", str, popStr,"=")
	endif
	if (cmpstr(ctrlname,"UPDBkg1")==0)
		str=ReplaceStringByKey("Bkg1", str, popStr,"=")
	endif	
	if (cmpstr(ctrlname,"UPDBkg1Err")==0)
		str=ReplaceStringByKey("Bkg1Err", str, popStr,"=")
	endif	
	if (cmpstr(ctrlname,"UPDBkg2Err")==0)
		str=ReplaceStringByKey("Bkg2Err", str, popStr,"=")
	endif	
	if (cmpstr(ctrlname,"UPDBkg3Err")==0)
		str=ReplaceStringByKey("Bkg3Err", str, popStr,"=")
	endif	
	if (cmpstr(ctrlname,"UPDBkg4Err")==0)
		str=ReplaceStringByKey("Bkg4Err", str, popStr,"=")
	endif	
	if (cmpstr(ctrlname,"UPDBkg5Err")==0)
		str=ReplaceStringByKey("Bkg5Err", str, popStr,"=")
	endif	
	if (cmpstr(ctrlname,"UPDBkg2")==0)
		str=ReplaceStringByKey("Bkg2", str, popStr,"=")
	endif
	if (cmpstr(ctrlname,"UPDBkg3")==0)
		str=ReplaceStringByKey("Bkg3", str, popStr,"=")
	endif	
	if (cmpstr(ctrlname,"UPDBkg4")==0)
		str=ReplaceStringByKey("Bkg4", str, popStr,"=")
	endif	
	if (cmpstr(ctrlname,"UPDBkg5")==0)
		str=ReplaceStringByKey("Bkg5", str, popStr,"=")
	endif		
End


//****************************************Functions to transfer non USAXS data**********************************
//**********************************************************************************************************************



Function IN2_ConvertRawToOthersFnct()		//simple conversion of non usaxs data to allow user to use them

	SVAR Subfolder=root:Packages:Indra3:USAXSSubfolder
	Subfolder=""
	SVAR/Z ScanType=root:Packages:Indra3:ScanTypeName
	ScanType="ascan"
	if (!SVAR_exists(ScanType))
		string/G root:Packages:Indra3:ScanTypeName=""
		SVAR ScanType=root:Packages:Indra3:ScanTypeName
	endif
	SVAR/Z StringToClear=root:Packages:Indra3:ListOfTransfers
	if(!SVAR_Exists(StringToClear))
		string/g root:Packages:Indra3:ListOfTransfers
		SVAR StringToClear=root:Packages:Indra3:ListOfTransfers
	endif
	StringToClear=""
	Execute("IN2_ConvertRAW_To_Others()")				//panel
end

Window IN2_ConvertRAW_To_Others() : Panel					//panel to transfer non usaxs data 
	PauseUpdate    		// building window...
	NewPanel /K=1/W=(393.75,77.75,933.75,449)
	SetDrawLayer UserBack
	DrawRect 55,253,434,295
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 105,22,"Convert SPEC data to OTHER one by one"
	SetDrawEnv fsize= 16,fstyle= 5,textrgb= (65280,0,0)
	DrawText 64,283,"When ready push button:"
	SetDrawEnv fstyle= 1
	DrawText 25,111,"The data go to root:Others folder, do you want subfolder?"
	DrawLine 27,91,454,91
	SetDrawEnv fsize= 10
	DrawText 229,68,"These data were already copied to fldr:"
	PopupMenu SelectSPECFile,pos={17,34},size={171,21},proc=IN2_PopMenuProc_Fldr,title="Select RAW sub-folder"
	PopupMenu SelectSPECFile,mode=1,popvalue="----",value= #"\"----;\"+IN2G_CreateListOfItemsInFolder(\"root:raw\",1)"
	PopupMenu SelectScanFolder,pos={36,64},size={163,21},proc=IN2_PopMenuProc_SpecRun,title="Select scan folder: "
	PopupMenu SelectScanFolder,mode=1,popvalue="----",value= #"\"----;\"+IN2_FindFolderWithScanTypes(GetDataFolder(1), 2, root:Packages:Indra3:ScanTypeName,0)"
	SetVariable CreateFolderName,pos={34,222},size={400,19},title="Modify Folder name?"
	SetVariable CreateFolderName,fSize=12
	SetVariable CreateFolderName,limits={-Inf,Inf,1},value= root:Packages:Indra3:LiberalUSAXSFolderName
	Button GenerateLibName,pos={33,194},size={180,20},proc=IN2_GenerateTheLiberalOName,title="Generate Folder name"
	Button DoRawToOthersConv,pos={269,265},size={150,20},proc=IN2_DoRawToOthersConversion,title="Do the conversion"
	PopupMenu ListOfUSAXSfldrs,pos={23,117},size={190,21},proc=IN2_Set2USAXSSubFolder,title="Select subfolder for the data:"
	PopupMenu ListOfUSAXSfldrs,mode=2,popvalue=" ",value= #"root:Packages:Indra3:USAXSSubfolder+\";\"+\" ;\"+IN2_GenListOfFoldersInOthers()"
	SetVariable NewUSAXSFldrname,pos={12,149},size={360,19},title="Create new subfolder for the data?"
	SetVariable NewUSAXSFldrname,fSize=12
	SetVariable NewUSAXSFldrname,limits={-Inf,Inf,1},value= root:Packages:Indra3:NewUSAXSSubfolder
	Button CreateNewFldr,pos={329,171},size={150,20},proc=IN2_SetOthersSubfolder,title="Create the new subfolder"
	SetVariable ShowTransferredTo,pos={230,68},size={260,16},title=" ",fSize=5
	SetVariable ShowTransferredTo,limits={-Inf,Inf,1},value= root:Packages:Indra3:ListOfTransfers,noedit= 1
	PopupMenu SelectScanType,pos={223,32},size={195,21},proc=IN2_SelectScanTypeToList,title="Select Scan Type to list:"
	PopupMenu SelectScanType,mode=1,popvalue="-----",value= #"\"ascan;escan\""
EndMacro

Function IN2_GenerateTheLiberalOName(ctrlName) : ButtonControl		//generates the liberal name , button control
	String ctrlName
	
	SVAR/Z newname=root:Packages:Indra3:LiberalUSAXSFolderName
	if (!SVAR_Exists(newname))
		string/g root:Packages:Indra3:LiberalUSAXSFolderName
		SVAR newname=root:Packages:Indra3:LiberalUSAXSFolderName
	endif
	newname=IN2_GenerateLibOthersFolderName()
End


Function/T IN2_GenerateLibOthersFolderName()							//generates liberal name, used by button control above
	
	SVAR/Z LibName=root:Packages:Indra3:LiberalUSAXSFolderName		//customized version of USAXS macro above
	if (!SVAR_Exists(LibName))
		string/G root:Packages:Indra3:LiberalUSAXSFolderName=""
		SVAR LibName=root:Packages:Indra3:LiberalUSAXSFolderName		//customized version of USAXS macro above
	endif
	
	SVAR SpecDataFolder=root:Packages:Indra3:PanelSpecScanSelected
	string df=GetDataFolder(1)
	string commentName=SpecDataFolder+":SpecComment"
	SVAR comment=$commentName
	SVAR/Z USAXSSFldr=root:Packages:Indra3:USAXSSubfolder
	if(!SVAR_Exists(USAXSSFldr))
		string/g root:Packages:Indra3:USAXSSubfolder
		SVAR USAXSSFldr=root:Packages:Indra3:USAXSSubfolder
		USAXSSFldr=""
	endif
	string USAXSpath="root:Others:"
	if (strlen(USAXSSFldr)>1)
		USAXSpath+=possiblyquotename(USAXSSFldr)
	endif	
	LibName=CleanupName(comment, 1 )
	
	if (DataFolderExists(USAXSpath ))
		SetDataFolder $USAXSpath
		if (CheckName(LibName, 11)!=0)				//this needs to be in root:USAXS:subfldr to work
			LibName+="_"
			LibName=UniqueName(LibName, 11, 0)
		endif
		SetDataFolder $df
	endif
	Libname= PossiblyQuoteName(LibName)
	return Libname
end


Function IN2_SetOthersSubfolder(ctrlName) :ButtonControl		//button control to change subfolder
	String ctrlName
		
	SVAR USAXSsubf=root:Packages:Indra3:NewUSAXSSubfolder
	SVAR USAXSsetTo=root:Packages:Indra3:USAXSSubfolder
	string str = "root:Others:"+PossiblyQuoteName(CleanupName(USAXSsubf,1))		//this is folder where we want to put data
	if (!DataFolderExists("root:Others"))											//create Others
		NewDataFolder root:Others
	endif
	if (!DataFolderExists(str))													//create subfolder if wanted
		NewDataFolder $str
	endif
	USAXSsetTo=USAXSsubf													//set the global string to this value
end	

Function/T IN2_GenListOfFoldersInOthers()										//list of folders in others
	string str="---"															//used for user to be able to select subfolder in Others
	if (DataFolderExists("root:Others"))
		string df=GetDataFolder(1)
		SetDataFolder root:Others
		str=IN2G_ConvertDataDirToList(DataFolderDir(1))
		SetDataFolder $df
	endif
	return str
end

Function IN2_DoRawToOthersConversion(ctrlName) : ButtonControl			//this function converts data to others
	String ctrlName
	//here we do raw to USAXS conversion

	string df=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	SVAR RawToUSAXS=root:Packages:Indra3:RawToUSAXS
	SVAR RawFolder=root:Packages:Indra3:PanelSpecScanSelected			//which data we want to convert?
	SVAR/Z ListOfDeleteWaves=root:Packages:Indra3:ListOfWavesToDeleteFromRaw 	//want to delete something
	SVAR USAXSFolder=root:Packages:Indra3:LiberalUSAXSFolderName		//Liberal name for new USAXS folder
	SVAR USAXSSubFolder=root:Packages:Indra3:USAXSSubfolder			//USAxs SUBFOLDER

//	string df=GetDataFolder(1)
	SetDataFolder $RawFolder
	SVAR/Z DataTransferredto=DataTransferredto
	SVAR specCommand=specCommand
	SVAR SpecComment=SpecComment
	SVAR SpecSourceFileName=SpecSourceFileName
	
	if (SVAR_Exists(ListOfDeleteWaves))				//here we delete waves if user chose to
		variable i=0
		string WaveNameDelete
		for(i=0;i<ItemsInList(ListOfDeleteWaves);i+=1)	
			WaveNameDelete=StringFromList(i,ListOfDeleteWaves)
			KillWaves/Z $WaveNameDelete						
		endfor										
	endif
	
	if (!DataFolderExists("root:Others"))				//this creates USAXS folder if it does not exist
		NewDataFolder root:Others
	endif
	
	string tempname="root:Others:"
	
	if (strlen(USAXSSubFolder)>2)
		tempname="root:Others:"+PossiblyQuoteName(USAXSSubFolder)+":"
		if (!DataFolderExists(tempname))				//this creates USAXS folder if it does not exist
			NewDataFolder $tempname
		endif 
	endif
	//here we need to remove single quotes, if they are in the USAXS folder name, sicen the Igore possiblyQuoteName gets confused
	if (cmpstr(USAXSFolder[0],"'")==0)
		USAXSFOlder=UsaxsFolder[1,inf]
	endif
	if (cmpstr(USAXSFolder[strlen(USAXSFolder)-1],"'")==0)
		USAXSFOlder=UsaxsFolder[0,strlen(USAXSFolder)-2]
	endif
	tempname+=possiblyquotename(USAXSFolder)		//this creates sample folder name

	if (!DataFolderExists(tempname))					//this creates sample folder if it does not exist
		NewDataFolder $tempname
	endif

	if (!SVAR_Exists(DataTransferredto))				//here we save where we transferred the raw data
		string/G DataTransferredto
		SVAR DataTransferredto=DataTransferredto
	endif
	DataTransferredto+=tempname+";"
	
	string TempWaveName="", TempNewWaveName=""
	string  newnote="SpecCommand="+SpecCommand+";SpecComment="+SpecComment+";SpecFile="+SpecSourceFileName+";SpecScan="+GetDataFolder(0)+";"


	String Waves=IN2G_ConvertDataDirToList(DataFolderDir(2))
	Variable NumWaves=ItemsInList(Waves)
	
	For (i=0; i<NumWaves;i+=1)
	TempWaveName=StringFromList(i,Waves)		//this creates copies  of all waves, not deleted into the new folder
	TempNewWaveName=tempname+":"+StringFromList(i,Waves)
	Duplicate/O $TempWaveName, $TempNewWaveName
	note $TempNewWaveName, newnote
	endfor
	
	string NewStringName=""
	NewStringName=tempname+":SpecCommand"				//here we copy specCommand to USAX folder
	string/G $NewStringName=specCommand
	
	NewStringName=tempname+":SpecSourceFileName"			//here we copy SpecSourceFileName to USAX folder
	string/G $NewStringName=SpecSourceFileName

	NewStringName=tempname+":SpecComment"				//here we copy specCommand to USAX folder
	string/G $NewStringName=SpecComment

	//here goes extraction of some measurement parameters such as energy etc. 
	
	string MeasParam=""
	SVAR EPICS_PVs=EPICS_PVs		//I assume here, that UPD section starts with UPDmode keyword.
	MeasParam="DCM_energy="+StringByKey("DCM_energy",EPICS_PVs)+";"
	MeasParam+= EPICS_PVs[strsearch(EPICS_PVs,"UPDmode",0), inf]
	NewStringName=tempname+":MeasurementParameters"
	string/g $NewStringName=MeasParam
	
	string UPDParam=""					//this creates list with UPD parameters from EPICS_PVs using the conversion in RawToUSAXS
	UPDParam="Vfc="+StringByKey(StringByKey("Vfc",RawToUSAXS),EPICS_PVs)+";"
	UPDParam+="Gain1="+StringByKey(StringByKey("Gain1",RawToUSAXS),EPICS_PVs)+";"
	UPDParam+="Gain2="+StringByKey(StringByKey("Gain2",RawToUSAXS),EPICS_PVs)+";"
	UPDParam+="Gain3="+StringByKey(StringByKey("Gain3",RawToUSAXS),EPICS_PVs)+";"
	UPDParam+="Gain4="+StringByKey(StringByKey("Gain4",RawToUSAXS),EPICS_PVs)+";"
	UPDParam+="Gain5="+StringByKey(StringByKey("Gain5",RawToUSAXS),EPICS_PVs)+";"
	UPDParam+="Bkg1="+StringByKey(StringByKey("Bkg1",RawToUSAXS),EPICS_PVs)+";"
	UPDParam+="Bkg2="+StringByKey(StringByKey("Bkg2",RawToUSAXS),EPICS_PVs)+";"
	UPDParam+="Bkg3="+StringByKey(StringByKey("Bkg3",RawToUSAXS),EPICS_PVs)+";"
	UPDParam+="Bkg4="+StringByKey(StringByKey("Bkg4",RawToUSAXS),EPICS_PVs)+";"
	UPDParam+="Bkg5="+StringByKey(StringByKey("Bkg5",RawToUSAXS),EPICS_PVs)+";"
	UPDParam+="I0AmpDark="+StringByKey(StringByKey("I0AmpDark",RawToUSAXS),EPICS_PVs)+";"
	UPDParam+="UPDsize="+StringByKey(StringByKey("UPDsize",RawToUSAXS),EPICS_PVs)+";"
	NewStringName=tempname+":UPDParameters"
	string/g $NewStringName=UPDParam
	//here we make pointer to original data:
	NewStringName=tempname+":PathToRawData"
	string/g $NewStringName=GetDataFolder(1)
	
	SetDataFolder df
	//last specXX converted is in RawFolder, how do I find out which is next?
//	string LspecName=stringFromList(ItemsInList(RawFolder , ":")-1, RawFolder,":")
//	SVAR SetNextScan=root:Packages:Indra3:NextRTUtoConvert
//	SetNextScan=IN2_GenNextScanToProcess(LspecName)
End

Function IN2_SelectScanTypeToList(ctrlName,popNum,popStr) : PopupMenuControl		//this sets the global strin to value selected in panel
	String ctrlName
	Variable popNum
	String popStr

	SVAR ScanType=root:Packages:Indra3:ScanTypeName
	ScanType=popStr

End



//************************************************************
//	This macro extracts comments from Spec file
//***************************************************************


Function IN2_ExtractComments()					// scans spec file to extract #S lines and offer list of them
	
	    
	Variable refNum
	String TempFileName
//********************************lets set path for temp file
	if (cmpstr(IgorInfo(2),"P")>0) 											// for Windows IgorInfo(2)=1
			//PathInfo Igor
			TempFileName=SpecialDirPath("Temporary", 0, 0, 0 )+"tempjunk:junk.txt"
			NewPath/C/O TempFilepath, SpecialDirPath("Temporary", 0, 0, 0 )+"tempjunk:"
	else																		//Mac
			//PathInfo Igor
			TempFileName=SpecialDirPath("Temporary", 0, 0, 0 )+"tempjunk:junk"
			NewPath/C/O TempFilepath, SpecialDirPath("Temporary", 0, 0, 0 )+"tempjunk:"
	endif	
//********************Open file and get its parameters*******************************
	if (cmpstr(IgorInfo(2),"P")>0) 											// for Windows IgorInfo(2)=1
			PathInfo RawDataPath
			if (V_Flag==0)												// gets which file we want to open
        			Open/R/D/T=".DAT" refNum as ""
      			 else
       			Open/R/D/P=RawDataPath/T=".DAT" refNum as ""
      			endif
	else																	//Mac
		PathInfo RawDataPath
		if (V_Flag==0)													// gets which file we want to open
        		Open/R/D/T="TEXT" refNum as ""
       	else
       		Open/R/D/P=RawDataPath/T="TEXT" refNum as ""
       	endif
	endif	
	

       if (strlen(S_fileName)==0)					//check if the file was opened and breaks from macro if the user hits cancel
       	abort
       endif
       
      String fullFilePath = S_fileName        				// S_fileName set by Open
	
	SetDataFolder root:								//sets us in root and sets few parameters
	Variable/G extraProcess=0
	string Nname="SpecFileCopy"
//*****************************opens the file
	if (cmpstr(IgorInfo(2),"P")>0) 											// for Windows IgorInfo(2)=1
	 	OpenNotebook/T=".DAT"/V=0/R/N=$Nname fullFilePath		//using notebook copies the file locally
 	else																	//Mac
		OpenNotebook/T="TEXT"/V=0/R/N=$Nname fullFilePath		//using notebook copies the file locally
	endif	

	
	if (exists("root:specDefaultFile")!=2)							// creates SpecDefaultFile for future use
			String /G root:specDefaultFile
	endif
	
	string tempSpecDefaultFile = RemoveFromList("\\", fullFilePath,":")		//here we need to set the pointer to original file, so we know where the data came from
	variable numOfFold=ItemsInList(tempSpecDefaultFile,":")				//this mess gets file name and file path of the original data
	tempSpecDefaultFile = stringFromList(numOfFold-1, tempSpecDefaultFile, ":")
      NewPath/O RawDataPath, RemoveFromList(tempSpecDefaultFile, fullFilePath,":")

	SaveNotebook/O/S=3 $Nname as TempFileName
	KillWIndow/Z $Nname 
										// now the data are in the C:\temp\junk.txt file and rest of the time we work on this junk file
	
	Variable fileVar						// file ref number
	String line, line1						// line of input from file
	Variable scanNum					//parameter to vary thorugh all scans
	Variable NumberOfPositions=0

														// check if Mac or Windows and change file type for it
	if (cmpstr(IgorInfo(2),"P")>0) 												// for Windows IgorInfo(2)=1
			Open /R/T=".TXT"/M="spec data file"/Z fileVar as TempFileName
	else																		//Mac
			Open /R/T="TEXT"/M="spec data file"/Z fileVar as TempFileName
	endif		

		FStatus(fileVar)
														//lookup all the scans
		scanNum=1
	    
	FSetPos fileVar, 0
	string PosList=ListPosOfLineTypes(fileVar,"#S ")
	FSetPos fileVar, 0
	string PosList1=ListPosOfLineTypes(fileVar,"#C ")
	FSetPos fileVar, 0
	string PosList2=ListPosOfLineTypes(fileVar,"#D ")
	string PosListFinal=PosList+PosList1+PosList2
	NumberOfPositions=ItemsInList(PosListFinal) 
	
	make/O/N=(NumberOfPositions) SortingWave
	SortingWave[]=str2num(stringFromList(p,PosListFinal))
	sort SortingWave, SortingWave
	
	IN2_CreateNbkForSpecComments()
	
	SVAR CommentsBook=root:Packages:CommentsBook
	SVAR DarkCurrentsInclude=root:Packages:DarkCurrentsInclude
	SVAR CommentGrepString=root:Packages:CommentGrepString
	
	Notebook $CommentsBook selection={endOfFile, endOfFile}
	Notebook $CommentsBook text="Spec file:   " +fullFilePath+"\r"
	Notebook $CommentsBook text="\r"	
	
	Variable i,j=0
	i = 0
	do
		j =SortingWave[i]						// str2num(StringFromList(i, PosList))
	
			FSetPos fileVar, j
			FReadLine fileVar, line
			Notebook $CommentsBook selection={endOfFile, endOfFile}
			if (cmpstr(line[0,1],"#S")==0)
				line="\r"+line
			endif
			if (stringmatch(DarkCurrentsInclude,"no"))
				if(strlen(CommentGrepString)>0)
					if (GrepString(line, CommentGrepString))
						if (stringmatch(line, "*dark current*")==0)
							Notebook $CommentsBook text=line
						endif
					endif	
				else
					if(stringmatch(line, "*dark current*")==0)
						Notebook $CommentsBook text=line
					endif
				endif
			else
				if(strlen(CommentGrepString)>0)
					if (GrepString(line, CommentGrepString))
							Notebook $CommentsBook text=line
					endif	
				else
						Notebook $CommentsBook text=line
				endif
			endif
					
	i += 1
	while (i<NumberOfPositions)

	close fileVar
	
	KillWaves/Z SortingWave
	KillStrings CommentsBook, DarkCurrentsInclude, CommentGrepString
EndMacro


Function IN2_CreateNbkForSpecComments()
	
	
	String nbL="SpecComments"
	Prompt nbL, "Give me Name for the Notebook, 11 letters max"
	String DarkCurrentsYes="no"
	Prompt DarkCurrentsYes, "Include dark current comments?", popup, "no;yes"
	String CommentGrepStr=""
	Prompt CommentGrepStr, "Use grepString to select which comments?"

	DoPrompt "Create notebook for Spec comments name", nbl, DarkCurrentsYes, CommentGrepStr
	
	nbl=CleanupName(nbl,0)
	nbl=nbl[0,32]
	
	
	    
	if (strsearch(WinList("*",";","WIN:16"),nbL,0)==0) 		///Logbook exists
		nbl=UniqueName(nbl, 10,0)
	//	IN2_CreateNbkForSpecComments()
	endif
	KillWindow/Z $nbL
	NewNotebook/N=$nbL/F=1/V=1/W=(235.5,44.75,817.5,592.25) as nbL+":  Spec File Comments"

	DoWindow/C $nbL
	Notebook $nbL defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nbL showRuler=1, rulerUnits=1, updating={1, 60}
	Notebook $nbL newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",10,0,(0,0,0)}
	Notebook $nbL ruler=Normal,  justification=1, rulerDefaults={"Arial",14,1,(0,0,0)}
	Notebook $nbL text="This is Extraction of Commands and Comments from the Spec File.\r"
	Notebook $nbL text="\r"
	Notebook $nbL ruler=Normal
	Notebook $nbL ruler=Normal,  justification=0, rulerDefaults={"Arial",10,1,(0,0,0)}

	
	string/G root:Packages:CommentsBook=nbL
	string/G root:Packages:DarkCurrentsInclude=DarkCurrentsYes
	string/G root:Packages:CommentGrepString=CommentGrepStr
End


Function IN2_GetInputAndCreateListPanel()			//this does dialog for user input which scans to load
											//and then retunrs the list of positison from which the scans are to be loaded
															//first create the list for input dialog
	string OldDf=GetDataFOlder(1)
	setDataFOlder root:Packages:Indra3
	//initialize, should be in general initialization, but have to put it here for now
	variable ii
	string ListOFVariables="LoadSpec_All;LoadSpec_Selected;LoadSpec_Range;"
	ListOFVariables+="LoadSpec_OnlyUSAXS;LoadSpec_ConvertUSAXSData;LoadSpec_OverwriteRaw;"
	For(ii=0;ii<ItemsInList(ListOfVariables);ii+=1)
		NVAR/Z temp=$(StringFromList(ii, ListOfVariables))
		if (!NVAR_Exists(temp))
			variable/g $(StringFromList(ii, ListOfVariables))
			NVAR temp=$(StringFromList(ii, ListOfVariables))
			if(cmpstr(StringFromList(ii, ListOfVariables),"LoadSpec_OnlyUSAXS")==0 || cmpstr(StringFromList(ii, ListOfVariables),"LoadSpec_ConvertUSAXSData")==0 || cmpstr(StringFromList(ii, ListOfVariables),"LoadSpec_OverwriteRaw")==0)
				temp=1
			endif
		endif
	endfor

	string ListOFStrings="DialogListForRangeSelection;USAXSRawDataFolder;USAXSOverWriteRaw;ListOfLoadedScans;"
	For(ii=0;ii<ItemsInList(ListOFStrings);ii+=1)
		SVAR/Z tempStr=$(StringFromList(ii, ListOFStrings))
		if (!SVAR_Exists(tempStr))
			string/g $(StringFromList(ii, ListOFStrings))
			SVAR tempStr=$(StringFromList(ii, ListOFStrings))
			tempStr=""
		endif
	endfor


	//setup some starting conditions 
	NVAR LoadSpec_All=root:Packages:Indra3:LoadSpec_All
	NVAR LoadSpec_Selected=root:Packages:Indra3:LoadSpec_Selected
	NVAR LoadSpec_Range=root:Packages:Indra3:LoadSpec_Range
	NVAR LoadSpec_OnlyUSAXS=root:Packages:Indra3:LoadSpec_OnlyUSAXS
	SVAR ConvertUSAXSImmediately=root:Packages:Indra3:ImmediatelyConvertUSAXSData
	SVAR commentList = root:Packages:Indra3:CommentsList
	SVAR scanList = root:Packages:Indra3:CommandList 
	SVAR posList = root:Packages:spec:posList 
	SVAR DialogListForRangeSelection = root:Packages:Indra3:DialogListForRangeSelection 
	if (LoadSpec_All+LoadSpec_Selected+LoadSpec_Range==0)
		LoadSpec_All=1
	endif

	SVAR USAXSRawDataFolder=root:Packages:Indra3:USAXSRawDataFolder
	SVAR specUSAXSSourceFile=root:Packages:Indra3:specUSAXSSourceFile
	USAXSRawDataFolder=PossiblyQuoteName(StringFromList(0,specUSAXSSourceFile,"."))	//setup the pointer
	
	IN2_CreateDialogForRangeSel()
	KillWIndow/Z IN2_ConvertSpecScansPanel
 	IN2_ConvertSpecScans()
end

Function IN2_CreateDialogForRangeSel()

	setDataFOlder root:Packages:Indra3
	variable i
	NVAR LoadSpec_OnlyUSAXS=root:Packages:Indra3:LoadSpec_OnlyUSAXS
	SVAR commentList = root:Packages:Indra3:CommentsList	//contains list of comments for thesxe scans
	SVAR scanList = root:Packages:Indra3:CommandList 	//contains list of commands used to create these scans
	SVAR posList = root:Packages:spec:posList 			//contains list of positions for scans, where they start
	SVAR DialogListForRangeSelection = root:Packages:Indra3:DialogListForRangeSelection 
	SVAR ScanTypeMatchString = root:Packages:Indra3:ScanTypeMatchString
	string TempListOfPositions=""
	if(ItemsInList(scanList)!=ItemsInList(posList))
		abort "Problem in IN2_CreateDialogForRangeSel()"
	endif
	DialogListForRangeSelection = ""
	for(i=0;i<ItemsInList(scanList);i+=1)	
		if (LoadSpec_OnlyUSAXS)	
			if (stringmatch(StringFromList(i, scanList), "*uascan*" ))								
				DialogListForRangeSelection+="Scan "+StringFromList(0,StringFromList(i, scanList),"  ")+"  "
				DialogListForRangeSelection+=StringFromList(i, commentList)[0,30]+";"	
				TempListOfPositions+=StringFromList(i, posList)+";"
			endif	
		else
			if (stringmatch(StringFromList(i, scanList), "*"+ScanTypeMatchString+"*" ))								
				DialogListForRangeSelection+="Scan "+StringFromList(0,StringFromList(i, scanList)," ")+"  "+StringFromList(1,StringFromList(i, scanList)," ")+"  "+StringFromList(2,StringFromList(i, scanList)," ")+"  :>"
				DialogListForRangeSelection+=StringFromList(i, commentList)[0,30]+";"	
				TempListOfPositions+=StringFromList(i, posList)+";"
			endif
		endif
	endfor													

	Make/O/N=(ItemsInList(DialogListForRangeSelection)) ListBoxDataSelWv
	Make/O/T/N=(ItemsInList(DialogListForRangeSelection)) ListBoxData, ListBoxDataPositions
	ListBoxDataSelWv = 0
	FOr(i=0;i<ItemsInList(DialogListForRangeSelection);i+=1)
		ListBoxData[i] = stringFromList(i, DialogListForRangeSelection)
		ListBoxDataPositions[i] = (stringFromList(i, TempListOfPositions))
	endfor
end	

Function IN2_LoadSpecPanelCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	NVAR LoadSpec_All=root:Packages:Indra3:LoadSpec_All
	NVAR LoadSpec_Selected=root:Packages:Indra3:LoadSpec_Selected
	NVAR LoadSpec_OnlyUSAXS=root:Packages:Indra3:LoadSpec_OnlyUSAXS
	NVAR LoadSpec_Range=root:Packages:Indra3:LoadSpec_Range
	NVAR LoadSpec_ConvertUSAXSData=root:Packages:Indra3:LoadSpec_ConvertUSAXSData
	Wave  ListBoxDataSelWv  = root:Packages:Indra3:ListBoxDataSelWv
	SVAR ScanTypeMatchString = root:Packages:Indra3:ScanTypeMatchString
	
	if(cmpstr(ctrlName,"SpecLoad_OnlyUSAXS")==0)
		IN2_CreateDialogForRangeSel()
			LoadSpec_All = 0
			LoadSpec_Selected = 0
			LoadSpec_Range = 0
			ListBoxDataSelWv =0
			ScanTypeMatchString=""
	endif
	if(cmpstr(ctrlName,"ConvertToUSAXSData")==0)
	
	endif

	if(cmpstr(ctrlName,"SpecLoad_All")==0)
		if(LoadSpec_All)
			//LoadSpec_All = 0
			LoadSpec_Selected = 0
			LoadSpec_Range = 0
			ListBoxDataSelWv =1
			ListBox ConvertSPecScansListBox, mode = 0
		endif
	endif
	if(cmpstr(ctrlName,"SpecLoad_Selected")==0)
		if(LoadSpec_Selected)
			//LoadSpec_Selected = 0
			LoadSpec_Range = 0
			LoadSpec_All = 0
			ListBox ConvertSPecScansListBox, mode = 4
		endif
	
	endif
	if(cmpstr(ctrlName,"SpecLoad_Range")==0)
		if(LoadSpec_Range)
			LoadSpec_All = 0
			LoadSpec_Selected = 0
			//LoadSpec_Range = 0
			ListBox ConvertSPecScansListBox, mode = 3
		endif
	
	endif

	if(!(LoadSpec_All || LoadSpec_Selected || LoadSpec_Range))
		Button SpecLoadFile  disable = 2
	else
		Button SpecLoadFile  disable = 0
	endif

End

//Function IN2_SpecLoad_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//	
//	if(cmpstr(ctrlName,"ConvertDataImmediately")==0)
//	
//	endif
//
//End

Function  IN2_ConvertSpecScans()
	PauseUpdate    		// building window...
	NewPanel /K=1/W=(212.25,116.75,743.25,479.75) as "IN2_ConvertSpecScans"
	DoWindow/C IN2_ConvertSpecScansPanel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 1,textrgb= (0,0,65280)
	DrawText 136,31,"Load SPEC scans"
	Button SpecSelectFile help={"Select new spec data file through dialog" }, pos={50,35 }, size={150,20 }, title = "Load Spec file"
	Button SpecSelectFile  proc=IN2_SPecLoadButtonProc, help={"Get dialog to select the spec file - new or the same one"}
	Button SpecReloadFile help={"reload same spec data file" }, pos={50,60}, size={150,20 }, title = "Reload same Spec file"
	Button SpecReloadFile  proc=IN2_SPecLoadButtonProc, help={"Get dialog to select the spec file - new or the same one"}
	SetVariable SpecOriginalFile value = root:Packages:Indra3:specUSAXSSourceFile, noproc, help={"This is the name of the file loaded"}
	SetVariable SpecOriginalFile noedit=1, pos = {240,52}, size = {250,20}, title = "Spec file: ", frame=0

	CheckBox SpecLoad_All,pos={34,131},size={86,14},proc=IN2_LoadSpecPanelCheckProc,title="Load all scans"
	CheckBox SpecLoad_All,variable = root:Packages:Indra3:LoadSpec_All, help={"Check to load all data listed below. Note, the list will not be possible to control."}
	CheckBox SpecLoad_Selected,pos={162,131},size={122,14},proc=IN2_LoadSpecPanelCheckProc,title="Load selected scan(s)"
	CheckBox SpecLoad_Selected,variable = root:Packages:Indra3:LoadSpec_Selected, help={"Check to be able to select any combination of scans"}
	CheckBox SpecLoad_OnlyUSAXS,pos={15,90},size={210,14},proc=IN2_LoadSpecPanelCheckProc,title="Display and convert USAXS scans only?"
	CheckBox SpecLoad_OnlyUSAXS,variable = root:Packages:Indra3:LoadSpec_OnlyUSAXS, help={"Check to have only USAXS data listed, uncheck to have all data listed"}

	SetVariable ScanTypeMatchString value = root:Packages:Indra3:ScanTypeMatchString, proc=IN2_ConvertSpecSetVarProc, help={"Match string for scan types"}
	SetVariable ScanTypeMatchString pos = {10,110}, size = {250,20}, title = "Scan type match : ", frame=1


	CheckBox SpecLoad_Range,pos={313,131},size={115,14},proc=IN2_LoadSpecPanelCheckProc,title="Load range of scans"
	CheckBox SpecLoad_Range,variable = root:Packages:Indra3:LoadSpec_Range, help={"Check to be able to select continuous range of data, hold shift/option to select the second point in range"}
	CheckBox ConvertToUSAXSData,pos={277,85},size={172,14},proc=IN2_LoadSpecPanelCheckProc,title="Convert directly to USAXS data?"
	CheckBox ConvertToUSAXSData,variable = root:Packages:Indra3:LoadSpec_ConvertUSAXSData, help={"Check to have continue to Convert to USAXS data macro. Default values of parameters will be used."}
	CheckBox LoadSpecOverwriteRaw,pos={277,105},size={172,14},proc=IN2_LoadSpecPanelCheckProc,title="Overwrite raw data if they already exist?"
	CheckBox LoadSpecOverwriteRaw,variable = root:Packages:Indra3:LoadSpec_OverwriteRaw, help={"Check to have raw folder with the sama name overwritten if the exist"}
	ListBox ConvertSPecScansListBox size={500,150} , pos={10,160}, help={"Here are listed data which can be loaded. To list all/USAXS only use checkbox Load all scans"}
	ListBox ConvertSPecScansListBox frame=1, listWave= root:Packages:Indra3:ListBoxData, mode=1, selWave= root:Packages:Indra3:ListBoxDataSelWv

	SetVariable RawFOlderName value = root:Packages:Indra3:USAXSRawDataFolder, proc=IN2_SpecLoadSetVarProc, help={"Name of raw data subfolder" }
	SetVariable RawFOlderName pos = {20,330}, size = {250,20}, title = "Save data in: ", frame=1
	Button SpecLoadFile help={"Select spec data file" }, pos={350,330 }, size={150,20 }, title = "Load data"
	Button SpecLoadFile  proc=IN2_SPecLoadButtonProc, help={"Push to load the selected data. Note, that if not available you need to check one of the \"Load...\" buttons"}

	NVAR LoadSpec_All=root:Packages:Indra3:LoadSpec_All
	NVAR LoadSpec_Selected=root:Packages:Indra3:LoadSpec_Selected
	NVAR LoadSpec_Range=root:Packages:Indra3:LoadSpec_Range
	Wave  ListBoxDataSelWv  = root:Packages:Indra3:ListBoxDataSelWv
	
	if(LoadSpec_All)
		ListBoxDataSelWv =1
		ListBox ConvertSPecScansListBox, mode = 0
	endif
	if(LoadSpec_Selected)
		ListBox ConvertSPecScansListBox, mode = 4
	endif
	if(LoadSpec_Range)
		ListBox ConvertSPecScansListBox, mode = 3
	endif

	if(!(LoadSpec_All || LoadSpec_Selected || LoadSpec_Range))
		Button SpecLoadFile  disable = 2
	endif
EndMacro


//	NVAR LoadSpec_All=root:Packages:Indra3:LoadSpec_All
//	NVAR LoadSpec_Selected=root:Packages:Indra3:LoadSpec_Selected
//	NVAR LoadSpec_Range=root:Packages:Indra3:LoadSpec_Range
//	NVAR LoadSpec_OnlyUSAXS=root:Packages:Indra3:LoadSpec_OnlyUSAXS
//	SVAR ConvertUSAXSImmediately=root:Packages:Indra3:ImmediatelyConvertUSAXSData

Function IN2_SpecLoadButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	string TempFileName
	
	if(cmpstr(ctrlName,"SpecSelectFile")==0)
		IN2_CopySpecFileLocally(0)
		TempFileName=IN2_CreateTempFileName()			//this returns the propert pointer to the temp  file	
		IN2_specScansList(TempFileName,"TempFilePath","*")		//creates list of scan lines commands and position list
		IN2_CreateDialogForRangeSel()
		SVAR USAXSRawDataFolder=root:Packages:Indra3:USAXSRawDataFolder
		SVAR specUSAXSSourceFile=root:Packages:Indra3:specUSAXSSourceFile
		USAXSRawDataFolder=PossiblyQuoteName(StringFromList(0,specUSAXSSourceFile,"."))
	endif

	if(cmpstr(ctrlName,"SpecReloadFile")==0)
		IN2_CopySpecFileLocally(1)
		TempFileName=IN2_CreateTempFileName()			//this returns the proper pointer to the temp  file	
		IN2_specScansList(TempFileName,"TempFilePath","*")		//creates list of scan lines commands and position list
		IN2_CreateDialogForRangeSel()
		SVAR USAXSRawDataFolder=root:Packages:Indra3:USAXSRawDataFolder
		SVAR specUSAXSSourceFile=root:Packages:Indra3:specUSAXSSourceFile
		USAXSRawDataFolder=PossiblyQuoteName(StringFromList(0,specUSAXSSourceFile,"."))
	endif


	if(cmpstr(ctrlName,"SpecLoadFile")==0)
		NVAR LoadSpec_All=root:Packages:Indra3:LoadSpec_All
		NVAR LoadSpec_Selected=root:Packages:Indra3:LoadSpec_Selected
		NVAR LoadSpec_Range=root:Packages:Indra3:LoadSpec_Range
		if (LoadSpec_All+LoadSpec_Selected+LoadSpec_Range!=1)
			Abort "First select data to load"
		endif
		IN2_DoTheSpecFileConversion()
	endif



End


Function IN2_DoTheSpecFileConversion()


		Wave ListBoxDataSelWv=root:Packages:Indra3:ListBoxDataSelWv
		Wave/T ListBoxDataPositions=root:Packages:Indra3:ListBoxDataPositions
		Wave/T ListBoxData=root:Packages:Indra3:ListBoxData
		//we need to create now the ListOFLoadedScans, containing list of numbers
		//and list of positions, which is needed by spec.ipf to load the data
		
		//here we create the raw data folder
		SVAR ListOfScans=root:Packages:Indra3:ListOfLoadedScans
		SVAR USAXSRawDataFolder=root:Packages:Indra3:USAXSRawDataFolder
		if (cmpstr("root:raw:",USAXSRawDataFolder[0,8])!=0)
			USAXSRawDataFolder="root:raw:"+USAXSRawDataFolder
		endif
		//now the USAXSOverWriteRaw
		NVAR LoadSpec_OverwriteRaw=root:Packages:Indra3:LoadSpec_OverwriteRaw
		SVAR USAXSOverWriteRaw=root:Packages:Indra3:USAXSOverWriteRaw
		if(LoadSpec_OverwriteRaw)
			USAXSOverWriteRaw="yes"
		else
			USAXSOverWriteRaw="no"
		endif
		SVAR ConvertUSAXSImmediately=root:Packages:Indra3:ImmediatelyConvertUSAXSData   //if this is set to Yes, we need to call conversion routine
		NVAR LoadSpec_ConvertUSAXSData=root:Packages:Indra3:LoadSpec_ConvertUSAXSData
		if(LoadSpec_ConvertUSAXSData)
			ConvertUSAXSImmediately="yes"
		else
			ConvertUSAXSImmediately="no"
		endif

		//and now the list of positions to load in the Igor...
		SVAR ListOfLoadedScans=root:Packages:Indra3:ListOfLoadedScans
		ListOfLoadedScans = ""
		
		variable i, imax=numpnts(ListBoxDataSelWv)
		//check if using load all data, need to set the ListBoxDataSel to 1
		NVAR LoadSpec_All=root:Packages:Indra3:LoadSpec_All
		if(LoadSpec_All)
			ListBoxDataSelWv=1
		endif
		string buffer=""
		
		For(i=0;i<imax;i+=1)
			if(ListBoxDataSelWv[i])
				buffer+=(ListBoxDataPositions[i])+";"
				ListOfLoadedScans+=StringFromList(1, ListBoxData[i] , " ")+";"
			endif
		endfor	
		if(LoadSpec_All)	//and now we need to set them to 0 so they are not black in the panel...
			ListBoxDataSelWv=0
		endif

	IN2_FinishSPecLoad(buffer)
end



Function IN2_SpecLoadSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	if(cmpstr("RawFOlderName",ctrlName)==0)
		SVAR USAXSRawDataFolder=root:Packages:Indra3:USAXSRawDataFolder
		if(cmpstr(USAXSRawDataFolder[0],"'")==0)
			USAXSRawDataFolder=USAXSRawDataFolder[1,inf]
		endif
		if(cmpstr(USAXSRawDataFolder[strlen(USAXSRawDataFolder)-1],"'")==0)
			USAXSRawDataFolder=USAXSRawDataFolder[0,strlen(USAXSRawDataFolder)-2]
		endif
		USAXSRawDataFolder=PossiblyQuoteName(USAXSRawDataFolder)	
	endif


End


Function IN2_FinishSPecLoad(ListOfSpecDataToLoad)
	string ListOfSpecDataToLoad
	
//	string ListOfSpecDataToLoad=IN2_GetInputAndCreateList()	//here we need to get the input from user which spec files he wants to load
	
	IN2_CheckForDuplicateFldrs()								//here we check the scan folders
	
	variable success=IN2_LoadDataFromTheSpec(ListOfSpecDataToLoad)			//this loads data from the spec, returns 0 if OK 		
	
	if (success==1)													//success=0 if no problems otherwise do allert so we know...
		DoAlert 0, "There were problems with loading data" 
	endif
	
	
	SVAR ConvertUSAXSImmediately=root:Packages:Indra3:ImmediatelyConvertUSAXSData   //if this is set to Yes, we need to call conversion routine
 	
 	if (cmpstr(ConvertUSAXSImmediately,"Yes")==0)
		SVAR ConvList=root:Packages:Indra3:RawToUSAXS		//here we check if the conversion list is set properly 
		if (stringmatch(ConvList, "*XX*" ))							//well, who knows what is proper, but at least somehow
			IN2_RAWtoUSAXSParametersSetup(0) 					//so if this list has any XX in it, we push user into the 
			if (strlen(WinList("*RawTo*", ",", "")))						//conversion panel again
				PauseForUser IN2_RawToUSAXSPanel  				//and wait until the panel is killed
			endif
		endif
		if (stringmatch(ConvList, "*YY*" ))							//and here we push user into the second panel 
			IN2_SetRawToUSAXSConv()							//this panel does the PD paramteters and should not be needed
		endif													//it will be needed in special cases
	
 		//user want to run the conversion routine 
 		IN2_CovertRaw_To_USAXSAutoF(1)
 	endif
end		
