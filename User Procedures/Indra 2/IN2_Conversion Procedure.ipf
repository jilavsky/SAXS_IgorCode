#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.10


//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//Menu "Spec"
//	"---"
//	"Convert Old data NOT finished yet", IN2Z_ConvertAllScans()
//end
//need to finish conversion by copying USAXS basic waves to USAXS folder... 

Function IN2Z_ConvertAllScans()
	string dfStart
	Prompt dfStart, "Select folder, all subfolders will be also converted", popup, IN2G_FindFolderWithWaveTypes("root:", 30, "*", 1)
	
	DoPrompt "Select folder with data to convert",dfStart

	string dfStartShort=dfstart[0,strlen(dfStart)-2]

	IN2_USAXSInitPackage()		//initialize USAXS package
	string/g root:Packages:Indra3:USAXSRawDataFolder

	IN2Z_ConvertScans(dfStartShort, 10)

//	KillDataFolder dfStart
end

Function/S IN2Z_ConvertScans(dfStart, levels)
        string dfStart
        Variable levels
               
        dfStart+=":"
        
        String dfSave, templist
             
        dfSave = GetDataFolder(1)
        templist = DataFolderDir(1)

        SetDataFolder $dfStart

		IN2Z_ConvertOneScan() 		//this calls routine which makes the record of parameters

        levels -= 1
        if (levels <= 0)
                return ""
        endif
        
        String subDF
        Variable index = 0
        do
                String temp
                temp = PossiblyQuoteName(GetIndexedObjName(dfStart, 4, index))     // Name of next data folder.

                if (strlen(temp) == 0)
                        break                                                                           // No more data folders.
                endif	     		  
                subDF = dfStart + temp
                IN2Z_ConvertScans(subDF,levels)     // Recurse.
                index += 1
        while(1)
        
        SetDataFolder(dfSave)
        return ""
End




Function IN2Z_ConvertOneScan()
//this function converts current scan into Indra2 compatible form... 

	if ((stringMatch(GetDataFolder(0),"*spec*")==1)&&(stringMatch(GetDataFolder(0),"*OriginalData*")!=1))
	

		IN2Z_CreateStringsWithData()		//this creates strings which will be needed.

		SVAR NewWavenote
		IN2Z_AppendNoteToAllWaves(NewWavenote)	//this creates notes for all waves

		string FldrSampleRaw=IN2Z_CreateDataFolders()		//creates the folders and returns list of folder names
	
		string RawFldr=StringFromList(1,FldrSampleRaw)
		string USAXSFldr=StringFromList(0,FldrSampleRaw)
	
		IN2Z_CopyDataToRaw(RawFldr)				//copies data to Raw folder
		
		USAXSFldr=USAXSFldr[0,strlen(USAXSFldr)-2]
		IN2Z_CopyDataToUSAXS(USAXSFldr)			//copies data to USAXS folder
		
		IN2Z_CheckUPDParameters(USAXSFldr,RawFldr)
		
		IN2Z_FinishConversion(FldrSampleRaw)
	endif
end


Function IN2Z_CopyDataToUSAXS(USAXSFldr)
	string USAXSFldr
	//this function copies data to USAXS folder
	
	IN2Z_CpyMvOneWave("PD_Intensity",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("PD_Error",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("Qvec",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("R_Int",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("R_Qvec",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("R_error",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("SMR_Int",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("SMR_Error",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("SMR_Qvec",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("DSM_Int",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("DSM_Error",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("DSM_Qvec",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("M_SMR_Int",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("M_SMR_Error",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("M_SMR_Qvec",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("M_DSM_Int",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("M_DSM_Error",USAXSFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("M_DSM_Qvec",USAXSFldr,1)		//this moves wave into new folder

	IN2Z_CpyMvOneString("UPDParameters",USAXSFldr,1)		//this moves or copies string
	IN2Z_CpyMvOneString("ListOfASBParameters",USAXSFldr,1)		//this moves or copies string
	IN2Z_CpyMvOneString("MeasurementParameters",USAXSFldr,1)		//this moves or copies string
	SVAR/Z specCommand					//this removes spaces in the beggigning of SpecComment... problem
	variable i=0
	if (SVAR_Exists(specCommand))	
		for (i=0;i<4;i+=1)
			if (cmpstr(specCommand[0]," ")==0)
				specCommand=specCommand[1, strlen(specCommand)-1]
			endif
		endfor
	endif
	IN2Z_CpyMvOneString("specCommand",USAXSFldr,1)		//this moves or copies string
	IN2Z_CpyMvOneString("timeWritten",USAXSFldr,1)		//this moves or copies string	
	IN2Z_CpyMvOneString("specComment",USAXSFldr,1)		//this moves or copies string
	IN2Z_CpyMvOneString("SpecSourceFileName",USAXSFldr,1)		//this moves or copies string

	IN2Z_CpyMvOneVariable("BeamCenter",USAXSFldr,1)		//and this moves or copies one variable	
	IN2Z_CpyMvOneVariable("MaximumIntensity",USAXSFldr,1)		//and this moves or copies one variable	
	IN2Z_CpyMvOneVariable("wavelength",USAXSFldr,1)		//and this moves or copies one variable	
	IN2Z_CpyMvOneVariable("Transmission",USAXSFldr,1)		//and this moves or copies one variable	
	IN2Z_CpyMvOneVariable("Qshift",USAXSFldr,1)		//and this moves or copies one variable	
	IN2Z_CpyMvOneVariable("PeakWidth",USAXSFldr,1)		//and this moves or copies one variable	

end


Function IN2Z_CopyDataToRaw(RawFldr)
	string RawFldr
	//this function copies waves and data to RawFldr

	IN2Z_CpyMvOneWave("ar",RawFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("dy",RawFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("asrp",RawFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("ar_enc",RawFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("pd_range",RawFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("pd_counts",RawFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("pd_rate",RawFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("Epoch",RawFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("seconds",RawFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("bicron",RawFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("I00",RawFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("I0",RawFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("USAXS_PD",RawFldr,1)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("FemtoPD",RawFldr,1)		//this moves wave into new folder

	IN2Z_CpyMvOneString("specCommand",RawFldr,0)		//this moves or copies string
	IN2Z_CpyMvOneString("timeWritten",RawFldr,0)		//this moves or copies string
	IN2Z_CpyMvOneString("specComment",RawFldr,0)		//this moves or copies string
	IN2Z_CpyMvOneString("SpecSourceFileName",RawFldr,0)		//this moves or copies string
	IN2Z_CpyMvOneString("specMotors",RawFldr,1)		//this moves or copies string
	IN2Z_CpyMvOneString("EPICS_PVs",RawFldr,1)		//this moves or copies string
	

end

Function/T IN2Z_CreateDataFolders()
//this function creates the folders as needed
	
	string df=GetDataFolder(1)
	
	SVAR SpecComment
	string RawFldrNm="root:raw:Converted:"
	string RawFldrShort=GetDataFolder(0)
	String USAXSDataFldr="root:USAXS:Converted:"
	string USAXSFlderShort=SpecComment
	variable i=0
	
	if (!DataFolderExists("root:raw"))
		NewDataFolder root:raw
	endif
	if (!DataFolderExists("root:raw:Converted"))
		NewDataFolder root:raw:Converted
	endif
	if (!DataFolderExists("root:USAXS"))
		NewDataFolder root:USAXS
	endif
	if (!DataFolderExists("root:USAXS:Converted"))
		NewDataFolder root:USAXS:Converted
	endif
	
	SetDataFolder root:raw:Converted
	if (DataFolderExists(RawFldrShort))
		RawFldrShort=UniqueName(RawFldrShort,11,0)
	endif
		NewDataFolder $RawFldrShort

	SetdataFolder root:USAXS:Converted
	if (DataFolderExists(USAXSFlderShort))
		USAXSFlderShort=CleanupName(UniqueName(USAXSFlderShort,11,0),1)
	endif
		NewDataFolder/S $USAXSFlderShort
	
	USAXSDataFldr=GetDataFolder(1)

	SetDataFolder df
	RawFldrNm+=RawFldrShort
	
	
	return USAXSDataFldr+";"+RawFldrNm
end

Function IN2Z_CreateStringsWithData()
//this function converts variables into strings as needed in the Indra2

		
	string/G UPDParameters=""
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Vfc","VToFFactorL")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Gain1","Range1")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Gain2","Range2")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Gain3","Range3")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Gain4","Range4")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Gain5","Range5")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Bkg1","DarkCurrent1")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Bkg2","DarkCurrent2")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Bkg3","DarkCurrent3")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Bkg4","DarkCurrent4")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Bkg5","DarkCurrent5")

	string/g MeasurementParameters=""
	MeasurementParameters =  IN2Z_NVARRplcKwString("MeasurementParameters","Wavelength","wavelength")
	MeasurementParameters =  IN2Z_NVARRplcKwString("MeasurementParameters","SlitLength","SlitLength")
	MeasurementParameters =  IN2Z_NVARRplcKwString("MeasurementParameters","SDDistance","SampleToDetectorDistance")


	SVAR EPICS_PVs
	MeasurementParameters=ReplaceStringByKey("DCM_energy", MeasurementParameters, StringByKey("DCM_energy", EPICS_PVs),"=")
	MeasurementParameters+= EPICS_PVs[strsearch(EPICS_PVs,"UPD",0), inf]+";"

	MeasurementParameters=ChangePartsOfString(MeasurementParameters,":","=")

	SVAR specComment
	SVAR specCommand
	SVAR PathToBlankR
	SVAR Callibrated
	string/g ListOfASBParameters=""
	ListOfASBParameters =  IN2Z_NVARRplcKwString("ListOfASBParameters","Kfactor","Kfactor")
	ListOfASBParameters =  IN2Z_NVARRplcKwString("ListOfASBParameters","SaThickness","SampleThickness")
	ListOfASBParameters =  IN2Z_NVARRplcKwString("ListOfASBParameters","OmegaFactor","OmegaFactor")
	ListOfASBParameters =  IN2Z_NVARRplcKwString("ListOfASBParameters","BlankWidthUsed","PeakWidth")
	ListOfASBParameters =  IN2Z_SVARRplcKwString("ListOfASBParameters","Sample","specComment")
	ListOfASBParameters =  IN2Z_SVARRplcKwString("ListOfASBParameters","Calibrate","Callibrated")
	ListOfASBParameters =  IN2Z_SVARRplcKwString("ListOfASBParameters","Blank","PathToBlankR")

	ListOfASBParameters+="ASWidthUsed=0;"

	string/G NewWavenote=ListOfASBParameters+MeasurementParameters+";SpecScan="+GetDataFolder(0)+";"
	NewWavenote =  IN2Z_SVARRplcKwString("NewWavenote","SpecCommand","SpecCommand")
	NewWavenote =  IN2Z_SVARRplcKwString("NewWavenote","SpecComment","SpecComment")


end


Function IN2Z_AppendNoteToAllWaves(NoteString)	//this function appends or replaces note (key/note) 
	string NoteString							//to all waves in the folder
	
	string ListOfWaves=WaveList("*",";",""), temp
	variable i=0, imax=ItemsInList(ListOfWaves)
	For(i=0;i<imax;i+=1)
		temp=stringFromList(i,listOfWaves)
		note/K $temp
		note $temp, NoteString
	endfor
end


Function IN2Z_CpyMvOneWave(WvName,FldrName,CpyMv)	//copies or move one way to specified folder
	string WvName, FldrName								//set CpyMv to 0 for copy, 1 for move
	Variable CpyMv
	
	FldrName=IN2G_CheckFldrNmSemicolon(FldrName,1 )
	Wave Mywave=$WvName
	
	if (CpyMv)
		if (WaveExists(Mywave))
			MoveWave Mywave, $FldrName
		endif	
	else
		if (WaveExists(Mywave))
			FldrName=FldrName+WvName
			Duplicate/O Mywave, $FldrName
		endif
	endif
end

Function IN2Z_CpyMvOneString(StrName,FldrName,CpyMv)	//copies or move one way to specified folder
	string StrName, FldrName								//set CpyMv to 0 for copy, 1 for move
	Variable CpyMv
	
	FldrName=IN2G_CheckFldrNmSemicolon(FldrName,1 )
	FldrName+=StrName
	SVAR/Z MyString=$StrName
	
	if (CpyMv)
		if (SVAR_Exists(MyString))
			MoveString $StrName, $FldrName
		endif	
	else
		if (SVAR_Exists(MyString))
			string/g $FldrName = MyString 
		endif
	endif
end

Function IN2Z_CpyMvOneVariable(VarName,FldrName,CpyMv)	//copies or move one way to specified folder
	string VarName, FldrName								//set CpyMv to 0 for copy, 1 for move
	Variable CpyMv
	
	FldrName=IN2G_CheckFldrNmSemicolon(FldrName,1 )
	FldrName=FldrName+VarName
	NVAR/Z MyVar=$VarName
	
	if (CpyMv)
		if (NVAR_Exists(MyVar))
			MoveVariable $VarName, $FldrName
		endif	
	else
		if (NVAR_Exists(MyVar))
			Variable/g $FldrName = MyVar 
		endif
	endif
end

Function/S IN2Z_NVARRplcKwString(KWList,KeyWord,NVARname)	//thsi function replaces part of string if it exists
	string KWList,KeyWord,NVARname
	
	SVAR LKWList=$KWList
	NVAR/Z NewNumber=$NVARname
	
	if (NVAR_Exists(NewNumber))
		LKWList=ReplaceStringByKey(KeyWord, LKWList,num2str(NewNumber),"=")
	endif
	return LKWList
end

Function/S IN2Z_SVARRplcKwString(KWList,KeyWord,SVARname)	//thsi function replaces part of string if it exists
	string KWList,KeyWord,SVARname
	
	SVAR LKWList=$KWList
	SVAR/Z NewString=$SVARname
	
	if (SVAR_Exists(NewString))
		LKWList=ReplaceStringByKey(KeyWord, LKWList,NewString,"=")
	endif
	return LKWList
end

Function IN2Z_FinishConversion(FldrSampleRaw)
	string FldrSampleRaw

		string RawFldr=StringFromList(1,FldrSampleRaw)
		string USAXSFldr=StringFromList(0,FldrSampleRaw)

	SVAR RawToUSAXS=root:Packages:Indra3:RawToUSAXS				//table for raw to USAXS conv.

	SVAR/Z RawFolder=root:Packages:Indra3:PanelSpecScanSelected			//which data we want to convert?
	if (!SVAR_Exists(RawFolder))
		string/G root:Packages:Indra3:PanelSpecScanSelected
		SVAR RawFolder=root:Packages:Indra3:PanelSpecScanSelected
	endif
	RawFolder=RawFldr
	SVAR/Z USAXSFolder=root:Packages:Indra3:LiberalUSAXSFolderName		//Liberal name for new USAXS folder
	if (!SVAR_Exists(USAXSFolder))
		string/G root:Packages:Indra3:LiberalUSAXSFolderName
		SVAR USAXSFolder=root:Packages:Indra3:LiberalUSAXSFolderName
	endif
	USAXSFolder=stringFromList((ItemsInList(USAXSFldr,":")-1),USAXSFldr,":")
	SVAR/Z USAXSSubFolder=root:Packages:Indra3:USAXSSubfolder			//USAXS SUBFOLDER
	if (!SVAR_Exists(USAXSSubFolder))
		string/G root:Packages:Indra3:USAXSSubfolder
		SVAR USAXSSubFolder=root:Packages:Indra3:USAXSSubfolder
	endif
	USAXSSubFolder=stringFromList((ItemsInList(USAXSFldr,":")-2),USAXSFldr,":")

	if (StringMatch(RawToUSAXS,"*XX*"))
		IN2_RAWtoUSAXSParametersSetup(0)
		PauseForUser IN2_RawToUSAXSPanel
	endif 
	
	IN2Z_DoRawToUSAXSConversion("Yes")
end


Function IN2Z_CheckUPDParameters(USAXSFolder,RawFolder)
		string USAXSFolder, RawFolder
		
		USAXSFolder=IN2G_CheckFldrNmSemicolon(USAXSFolder,1)
		RawFolder=IN2G_CheckFldrNmSemicolon(RawFolder,1)
		string dfOld=getdataFolder(1)
		setDataFolder root:Packages:Indra3
		
		SVAR UPDParameters=$USAXSFolder+"UPDParameters"
		SVAR EPICS_PVs=$RawFolder+"EPICS_PVs"
		SVAR RawToUSAXS

	if (StringMatch(RawToUSAXS,"*YY*"))
		execute("IN2_PhotodiodeConvPanel()")
		PauseForUser IN2_PhotodiodeConvPanel
	endif 

		
	if (strlen(UPDParameters)<11)
		UPDParameters="Vfc="+StringByKey(StringByKey("Vfc",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParameters+="Gain1="+StringByKey(StringByKey("Gain1",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParameters+="Gain2="+StringByKey(StringByKey("Gain2",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParameters+="Gain3="+StringByKey(StringByKey("Gain3",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParameters+="Gain4="+StringByKey(StringByKey("Gain4",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParameters+="Gain5="+StringByKey(StringByKey("Gain5",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParameters+="Bkg1="+StringByKey(StringByKey("Bkg1",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParameters+="Bkg2="+StringByKey(StringByKey("Bkg2",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParameters+="Bkg3="+StringByKey(StringByKey("Bkg3",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParameters+="Bkg4="+StringByKey(StringByKey("Bkg4",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParameters+="Bkg5="+StringByKey(StringByKey("Bkg5",RawToUSAXS,"="),EPICS_PVs)+";"
		UPDParameters+="UPDsize="+StringByKey(StringByKey("UPDsize",RawToUSAXS,"="),EPICS_PVs)+";"
	endif
	
	setDataFolder dfOld
end


Function IN2Z_DoRawToUSAXSConversion(ctrlName) : ButtonControl			//this function converts data to USAXS
	String ctrlName
	//here we do raw to USAXS conversion
	SVAR RawToUSAXS=root:Packages:Indra3:RawToUSAXS				//table for raw to USAXS conv.
	SVAR RawFolder=root:Packages:Indra3:PanelSpecScanSelected			//which data we want to convert?
	SVAR/Z ListOfDeleteWaves=root:Packages:Indra3:ListOfWavesToDeleteFromRaw 	//want to delete something
	SVAR USAXSFolder=root:Packages:Indra3:LiberalUSAXSFolderName		//Liberal name for new USAXS folder
	SVAR USAXSSubFolder=root:Packages:Indra3:USAXSSubfolder			//USAxs SUBFOLDER

	string df=GetDataFolder(1)												//save where we are
	SetDataFolder $RawFolder												//go where we want to be
		if (SVAR_Exists(ListOfDeleteWaves))								//here we delete waves if user chose to
			variable i=0
			string WaveNameDelete
			for(i=0;i<ItemsInList(ListOfDeleteWaves);i+=1)	
				WaveNameDelete=StringFromList(i,ListOfDeleteWaves)
				KillWaves/Z $WaveNameDelete						
			endfor										
		endif
		
	string tempname="root:USAXS:"
		
	tempname="root:USAXS:"+USAXSSubFolder+":"
		
	tempname+=USAXSFolder										//this creates sample folder name
	
		string TempWaveName="", TempNewWaveName=""					//note for waves to be appended to each USAXS wave
		string  newnote=""												//remove ":" from folder poitners
		string oldnote
		
		TempWaveName=StringByKey("AR_enc", RawToUSAXS,"=")		//this creates copy of ARencoder wave
		TempNewWaveName=tempname+":AR_encoder"
		Duplicate/O $TempWaveName, $TempNewWaveName
		oldnote=Note($TempNewWaveName)
		Note/K $TempNewWaveName
		note $TempNewWaveName, oldnote+newnote+"Wname=AR_encoder;"
		
		TempWaveName=StringByKey("PD_range", RawToUSAXS,"=")		//this creates copy of PD range wave
		TempNewWaveName=tempname+":PD_range"
		Duplicate/O $TempWaveName, $TempNewWaveName
		oldnote=Note($TempNewWaveName)
		Note/K $TempNewWaveName
		note $TempNewWaveName, oldnote+newnote+"Wname=PD_range;"
		
		TempWaveName=StringByKey("USAXS_PD", RawToUSAXS,"=")		//this creates copy of USAXS PD wave
		TempNewWaveName=tempname+":USAXS_PD"
		Duplicate/O $TempWaveName, $TempNewWaveName
		oldnote=Note($TempNewWaveName)
		Note/K $TempNewWaveName
		note $TempNewWaveName, oldnote+newnote+"Wname=USAXS_PD;"
		
		TempWaveName=StringByKey("Time", RawToUSAXS,"=")		//this creates copy of measurement time wave
		TempNewWaveName=tempname+":MeasTime"
		Duplicate/O $TempWaveName, $TempNewWaveName
		oldnote=Note($TempNewWaveName)
		Note/K $TempNewWaveName
		note $TempNewWaveName, oldnote+newnote+"Wname=MeasTime;"
		
		TempWaveName=StringByKey("Monitor", RawToUSAXS,"=")		//this creates copy of monitors wave
		TempNewWaveName=tempname+":Monitor"
		Duplicate/O $TempWaveName, $TempNewWaveName
		oldnote=Note($TempNewWaveName)
		Note/K $TempNewWaveName
		note $TempNewWaveName, oldnote+newnote+"Wname=Monitor;"
			
	SetDataFolder df
	//last specXX converted is in RawFolder, how do I find out which is next?

End