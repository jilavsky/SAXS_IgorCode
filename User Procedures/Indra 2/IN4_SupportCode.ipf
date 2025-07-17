#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later


// here belongs any code which imports and exports data and does other stuff, except data reduction

//**********************************************************************************************************
//**********************************************************************************************************
// This is main processing function which deals with list of files to process... 

Function/S IN4_ProcessSelectedData(FileNameList)		//note, at this moment this seems to be called with list of 1 file each time 
	string FileNameList									//while th=is codeshoudl be able to handle a list fo files. 

	NVAR UsePython = root:Packages:Indra4:UsePythonCode
	SVAR BlankFileName = root:Packages:Indra4:BlankFileName
	variable i
	PathInfo Indra4DataPath
	string PathToData= S_path
	SVAR extensionStr=root:Packages:Indra4:DataSelListBoxExtString
	string ImportedFolders=""
	string PythonPath, RealSampleName, pathToIgor, cmdLine, FileName
	string SampleName,BlankName, PythonSampleFile, PythonBlankFile 
	string IgortemSampleName, returnedFilePathName
	NVAR Recalculate = root:Packages:Indra4:RecalcNexusData
	String recalculateStr="False"
	if(Recalculate)
		recalculateStr="True"
	endif
	NVAR IncludeSAXS = root:Packages:Indra4:IncludeSAXS
	NVAR IncludeWAXS = root:Packages:Indra4:IncludeWAXS
	
	if(Recalculate)			//Force recalculation. Using Python or Igor. 
		if(UsePython)
#if (IgorVersion()>9.99)
			//need to check if Python has been initialized, if not run this: IN4_InitializePython()
			IN4_InitializePython()	 
			//and now, let's process the list of the files. 
			for(i=0;i<itemsInList(FileNameList);i+=1)
				//set 1 - deal with USAXS data
				PythonPath = ParseFilePath(5, PathToData, "\\", 0, 0)
				PythonPath = RemoveEnding(PythonPath)
				PythonPath = ReplaceString("\\", PythonPath, "/")			
				SampleName = StringFromList(i,FileNameList)
				BlankName = BlankFileName
				PythonSampleFile = "[['"+PythonPath+"','"+SampleName+"'],]"
				PythonBlankFile = "[['"+PythonPath+"','"+BlankName+"'],]"	
				//examples of neededinput: 
				//string SampleFile="[['//Mac/Home/Desktop/Data/set1','CD2_R_0323.h5'],]"
				//string BlankFile="[['//Mac/Home/Desktop/Data/set1','TapeBlank_R_0317.h5'],]"
				RealSampleName = RemoveEnding(RemoveEnding(SampleName,extensionStr),".")	
				//create USAXS folders. 
				NewDataFolder/O/S  root:USAXS
				NewDataFolder/O/S  $("root:USAXS:"+RealSampleName)
				pathToIgor="root:USAXS:"+RealSampleName
				//for future debugging... 
				//cmdLine = "reduceFlyscanData("+PythonSampleFile+", "+PythonBlankFile+", pathToIgorFolder='"+pathToIgor+"', recalculateAllData=True, forceFirstBlank=True)"
				//print cmdLine
				Python/Z execute = "reduceFlyscanData("+PythonSampleFile+", "+PythonBlankFile+", pathToIgorFolder='"+pathToIgor+"', recalculateAllData="+recalculateStr+", forceFirstBlank=True)"
				if(V_Flag!=0)	//error in Python
					Abort "Python code for USAXS encoutered error, stopping. Use Igor code to check for problems"
				endif
				
				ImportedFolders += pathToIgor+";"
				
				//now SAXS, if user wants it. 
				if(IncludeSAXS)
					PythonPath = ReplaceString("_usaxs",PythonPath, "_saxs")
					PythonSampleFile = "[['"+PythonPath+"','"+SampleName+"'],]"
					PythonBlankFile = "[['"+PythonPath+"','"+BlankName+"'],]"	
					PythonSampleFile = ReplaceString(".h5", PythonSampleFile, ".hdf")
					PythonBlankFile =  ReplaceString(".h5", PythonBlankFile, ".hdf")
					
					NewDataFolder/O/S  root:SAXS
					NewDataFolder/O/S  $("root:SAXS:"+RealSampleName)
					pathToIgor="root:SAXS:"+RealSampleName
					//cmdLine = "reduceSWAXSData("+PythonSampleFile+", "+PythonBlankFile+", pathToIgorFolder='"+pathToIgor+"', recalculateAllData=True, forceFirstBlank=True)"
					Python/Z execute = "reduceSWAXSData("+PythonSampleFile+", "+PythonBlankFile+", pathToIgorFolder='"+pathToIgor+"', recalculateAllData="+recalculateStr+", forceFirstBlank=True)"
					if(V_Flag!=0)	//error in Python
						Abort "Python code for SAXS encoutered error, stopping. Use Igor code to check for problems"
					endif
					ImportedFolders += pathToIgor+";"
				endif
				if(IncludeWAXS)
					//now WAXS
					PythonPath = ReplaceString("_saxs",PythonPath, "_waxs")
					PythonSampleFile = "[['"+PythonPath+"','"+SampleName+"'],]"
					PythonBlankFile = "[['"+PythonPath+"','"+BlankName+"'],]"	
					PythonSampleFile = ReplaceString(".h5", PythonSampleFile, ".hdf")
					PythonBlankFile =  ReplaceString(".h5", PythonBlankFile, ".hdf")
					
					NewDataFolder/O/S  root:WAXS
					NewDataFolder/O/S  $("root:WAXS:"+RealSampleName)
					pathToIgor="root:WAXS:"+RealSampleName
					//cmdLine = "reduceSWAXSData("+PythonSampleFile+", "+PythonBlankFile+", pathToIgorFolder='"+pathToIgor+"', recalculateAllData=True, forceFirstBlank=True)"
					Python/Z execute = "reduceSWAXSData("+PythonSampleFile+", "+PythonBlankFile+", pathToIgorFolder='"+pathToIgor+"', recalculateAllData="+recalculateStr+", forceFirstBlank=True)"
					if(V_Flag!=0)	//error in Python
						Abort "Python code for WAXS encoutered error, stopping. Use Igor code to check for problems"
					endif				
					ImportedFolders += pathToIgor+";"
				endif
			endfor
#else
			Abort "You need Igor Pro 10 and Python environment with Matilda in order to use Python to reduce data"
#endif		
		else	//this is recalculating data using Igor Pro
				//USAXS is always
				for(i=0;i<itemsInList(FileNameList);i+=1)
					SampleName = StringFromList(i,FileNameList)
					returnedFilePathName = IN4_ProcessOneUSAXSScan(Samplename)
					//above includes also saving Nexus data if requested. 
					//print "Reduced USAXS data for :"+returnedFilePathName
					ImportedFolders +=returnedFilePathName+";"		
				endfor			
				//now SAXS, if user wants it. 
				if(IncludeSAXS)
 					//init the SAXS 
					SampleName = StringFromList(0,FileNameList)
					IgortemSampleName = ReplaceString(".h5", SampleName, ".hdf")
					IN4_initProcessSWAXSdata(IgortemSampleName, 1)			//this inits the processing, but does not process the files
					for(i=0;i<itemsInList(FileNameList);i+=1)				//and this processes the files one by one... 
						SampleName = StringFromList(i,FileNameList)
						IgortemSampleName = ReplaceString(".h5", SampleName, ".hdf")
						returnedFilePathName = IN4_processOneNikaFile(IgortemSampleName)
						// TODO" IN4_SaveSWAXSDataInNexus(DataPathStr, SAXSorWAXS, filenameInput)
						//print "Reduced SAXS data for :"+returnedFilePathName
						ImportedFolders +=returnedFilePathName+";"		
					endfor			
					KillWindow/Z CCDImageToConvert
					KillWindow/Z NI1A_Convert2Dto1DPanel
					KillWindow/Z LineuotDisplayPlot_Q
					KillWindow/Z CCDImageToConvertFig	
			    endif
				//now WAXS, if user wants it. 
				if(IncludeWAXS)
 					//init the SAXS 
					SampleName = StringFromList(0,FileNameList)
					IgortemSampleName = ReplaceString(".h5", SampleName, ".hdf")
					IN4_initProcessSWAXSdata(IgortemSampleName, 0)			//this inits the processing, but does not process the files
					for(i=0;i<itemsInList(FileNameList);i+=1)				//and this processes the files one by one... 
						SampleName = StringFromList(i,FileNameList)
						IgortemSampleName = ReplaceString(".h5", SampleName, ".hdf")
						returnedFilePathName = IN4_processOneNikaFile(IgortemSampleName)
						// TODO" IN4_SaveSWAXSDataInNexus(DataPathStr, SAXSorWAXS, filenameInput)
						//print "Reduced WAXS data for :"+returnedFilePathName
						ImportedFolders +=returnedFilePathName+";"		
					endfor			
					KillWindow/Z CCDImageToConvert
					KillWindow/Z NI1A_Convert2Dto1DPanel
					KillWindow/Z LineuotDisplayPlot_Q
					KillWindow/Z CCDImageToConvertFig	
			    endif
		endif
	else	//Import the data from list of files, do NOT recalculate. 
		if(UsePython)
#if (IgorVersion()>9.99)
			// Python needs to be initialized
			IN4_InitializePython()	 
			//and now, let's process the list of the files. 
			for(i=0;i<itemsInList(FileNameList);i+=1)
			
				//set 1 - deal with USAXS data
				//Prep the Python paths to data... Bit of nightmare for now. 
				PythonPath = ParseFilePath(5, PathToData, "\\", 0, 0)	//get the path
				PythonPath = RemoveEnding(PythonPath)					//remove ending part, Python does not want it
				PythonPath = ReplaceString("\\", PythonPath, "/")		//switch to / for compatibility
				SampleName = StringFromList(i,FileNameList)				//this is sample name 
				BlankName = BlankFileName
				PythonSampleFile = "[['"+PythonPath+"','"+SampleName+"'],]"
				PythonBlankFile = "[['"+PythonPath+"','"+BlankName+"'],]"	
				RealSampleName = RemoveEnding(RemoveEnding(SampleName,extensionStr),".")	//TODO: sanitize properly sample name here to make it Igor friendly
				
				//create USAXS folders. 
				NewDataFolder/O/S  root:USAXS
				NewDataFolder/O/S  $("root:USAXS:"+RealSampleName)
				pathToIgor="root:USAXS:"+RealSampleName
				string UsaxsFolderStr = pathToIgor
				//for future debugging... 
				//cmdLine = "reduceFlyscanData("+PythonSampleFile+", "+PythonBlankFile+", pathToIgorFolder='"+pathToIgor+"', recalculateAllData=True, forceFirstBlank=True)"
				//print cmdLine
				Python/Z execute = "reduceFlyscanData("+PythonSampleFile+", "+PythonBlankFile+", pathToIgorFolder='"+pathToIgor+"', recalculateAllData="+recalculateStr+", forceFirstBlank=True)"
				if(V_Flag!=0)	//error in Python
					Abort "Python code for USAXS encoutered error, stopping. Use Igor code to check for problems"
				endif
				
				ImportedFolders += pathToIgor+";"
				
				//now SAXS, if user wants it. 
				if(IncludeSAXS)
					PythonPath = ReplaceString("_usaxs",PythonPath, "_saxs")
					PythonSampleFile = "[['"+PythonPath+"','"+SampleName+"'],]"
					PythonBlankFile = "[['"+PythonPath+"','"+BlankName+"'],]"	
					PythonSampleFile = ReplaceString(".h5", PythonSampleFile, ".hdf")
					PythonBlankFile =  ReplaceString(".h5", PythonBlankFile, ".hdf")
					
					NewDataFolder/O/S  root:SAXS
					NewDataFolder/O/S  $("root:SAXS:"+RealSampleName)
					pathToIgor="root:SAXS:"+RealSampleName
					//cmdLine = "reduceSWAXSData("+PythonSampleFile+", "+PythonBlankFile+", pathToIgorFolder='"+pathToIgor+"', recalculateAllData=True, forceFirstBlank=True)"
					Python/Z execute = "reduceSWAXSData("+PythonSampleFile+", "+PythonBlankFile+", pathToIgorFolder='"+pathToIgor+"', recalculateAllData="+recalculateStr+", forceFirstBlank=True)"
					if(V_Flag!=0)	//error in Python
						Abort "Python code for SAXS encoutered error, stopping. Use Igor code to check for problems"
					endif
					ImportedFolders += pathToIgor+";"
				endif
				if(IncludeWAXS)
					//now WAXS
					PythonPath = ReplaceString("_saxs",PythonPath, "_waxs")
					PythonSampleFile = "[['"+PythonPath+"','"+SampleName+"'],]"
					PythonBlankFile = "[['"+PythonPath+"','"+BlankName+"'],]"	
					PythonSampleFile = ReplaceString(".h5", PythonSampleFile, ".hdf")
					PythonBlankFile =  ReplaceString(".h5", PythonBlankFile, ".hdf")
					
					NewDataFolder/O/S  root:WAXS
					NewDataFolder/O/S  $("root:WAXS:"+RealSampleName)
					pathToIgor="root:WAXS:"+RealSampleName
					//cmdLine = "reduceSWAXSData("+PythonSampleFile+", "+PythonBlankFile+", pathToIgorFolder='"+pathToIgor+"', recalculateAllData=True, forceFirstBlank=True)"
					Python/Z execute = "reduceSWAXSData("+PythonSampleFile+", "+PythonBlankFile+", pathToIgorFolder='"+pathToIgor+"', recalculateAllData="+recalculateStr+", forceFirstBlank=True)"
					if(V_Flag!=0)	//error in Python
						Abort "Python code for WAXS encoutered error, stopping. Use Igor code to check for problems"
					endif				
					ImportedFolders += pathToIgor+";"
				endif
				//IN4_FixParamsAfterImport(UsaxsFolderStr)	//this deas nto work here, Python is not storing any wavenotes, yet. 

			endfor
#else
			Abort "You need Igor Pro 10 and Python environment with Matilda in order to use Python to reduce data"
#endif		
		 else // USING IGOR CODE, imports USAXS and if selected also SAXS and WAXS		
			for(i=0;i<itemsInList(FileNameList);i+=1)
			    FileName = StringFromList(i,FileNameList)
			    ImportedFolders += IN4_ImportDataSet(FileName)+";"
		    endfor

		 endif
	endif
	
	return ImportedFolders
end

//**********************************************************************************************************
//**********************************************************************************************************


Function/S IN4_ProcessOneUSAXSScan(Samplename)
	string Samplename
	//here do all steps to process one data set in USAXS.
	DFref oldDf= GetDataFolderDFR()
	
	//************ Blank first
	//check we have correct Blank data, it should be here, in this folder if it exists...
	variable importBlank=0
	SVAR BlankFileName = root:Packages:Indra4:BlankFileName		//this is what user wants as blank. 
	SVAR/Z filename = root:Packages:Indra4:BlankData:filename	//this is filename of the data imported last in this Blank folder.
	if(!SVAR_Exists(filename))									//nothing here, need to import it. 
		importBlank = 1
		string/g filename 
		filename = ""
	endif
	if(!stringmatch(filename,BlankFileName))					//wrong file in here, need to import correct one. 
		importBlank = 1
	endif
	Wave/Z R_Int = root:Packages:Indra4:BlankData:R_Int			//do R_Int data exist? These are BL_R_Int for the samples
	if(!WaveExists(R_Int))
		importBlank = 1
	endif
	
	string PathForUSAXSData
	if(importBlank)												//importing the data for blank. 
		NewDataFolder/O/S root:Packages:Indra4:BlankData
		print "Importing Blank from :" +BlankFileName
		IN4_ImportRawUSAXS(BlankFileName)							//import data
		IN4_CalculateRWaveIntensity("root:Packages:Indra4:BlankData")	//create R_int, R_error, old code is IN3_CalculateRWaveIntensity(0)
		IN4_calculateR_Qvec("root:Packages:Indra4:BlankData")			//need to create R_Qvec, IN3_calculateRwaveQvec()
		//IN4_CorrectTransmission("root:Packages:Indra4:BlankData")		//only for sample
		//IN4_ReplaceNaNs("root:Packages:Indra4:BlankData")				//may be we need this? Not sure yet. 
		IN4_SmoothRData("root:Packages:Indra4:BlankData")				//smooth the data, default for Blank. 
	else
		print "Proper blank found already"
	endif
	
	//************ sample data	
	//create folder for sample RAW data and import them. 
	NewDataFolder/O/S root:Packages:Indra4:SampleData
	IN4_ImportRawUSAXS(SampleName)
	IN4_CalculateRWaveIntensity("root:Packages:Indra4:SampleData")	//create R_int, R_error, old code is IN3_CalculateRWaveIntensity(0)
	IN4_calculateR_Qvec("root:Packages:Indra4:SampleData")			//need to create R_Qvec, IN3_calculateRwaveQvec()
	//IN4_SmoothRData("root:Packages:Indra4:SampleData")			//smooth the data, default for Blank. 
	IN4_CopyBlankAndCorrectTransm("root:Packages:Indra4:SampleData","root:Packages:Indra4:BlankData" )//only for sample
	//IN4_ReplaceNaNs("root:Packages:Indra4:SampleData")			//may be we need this? Not sure yet. 
	IN4_SubtractSampleAndBlank("root:Packages:Indra4:SampleData")	//subtract R_data - BL_R_data, calculate calibrations and apply. 						
	IN4_RebinDataIfNeeded("root:Packages:Indra4:SampleData")	
	IN4_DesmearData("root:Packages:Indra4:SampleData")
	IN4_SaveUSAXSDataInNexus(SampleName)
	PathForUSAXSData = IN4_CopyUSAXSToFolder("root:Packages:Indra4:SampleData", "_IN4")		//this copies the data into folder. use second string not to overwrite old data
	

	SetDataFolder oldDf
	return PathForUSAXSData
end

//**********************************************************************************************************
//**********************************************************************************************************
Function IN4_SaveSWAXSDataInNexus(DataPathStr, SAXSorWAXS, filenameInput)
    String filenameInput, DataPathStr
    variable SAXSorWAXS //SAXSorWAXS = 1 for SAXS, 2=waxs

    String location

	variable FileID, groupID
	string AttrString
	string tempPathStr
	if(SAXSorWAXS==1)	//SAXS
		tempPathStr = ReplaceString("_usaxs", DataPathStr, "_saxs")
	elseif(SAXSorWAXS==2)	//WAXS
		tempPathStr = ReplaceString("_usaxs", DataPathStr, "_waxs")
	else
		return 0
	endif
	
	newPath/O/C SWAXSPath, tempPathStr  

	HDF5OpenFile /P=SWAXSPath /Z fileID as filenameInput
	if(V_Flag!=0)	//failed to open, bail out.
		return 0
	endif


	HDF5CloseFile FileID

end

//**********************************************************************************************************
//**********************************************************************************************************
Function IN4_initProcessSWAXSdata(fileName, isSAXS)
	string fileName
	variable isSAXS		//set to 1 for SAXS, 0 for WAXS
		
	string fullPathToNewData=""

#if(exists("NI1_APSConfigureNika")==6)	
	//init Nika
	//call sequence of commands to process Nika image.
	SVAR BlankFileName = root:Packages:Indra4:BlankFileName		//this is what user wants as blank. 
	PathInfo Indra4DataPath		//this is USAXS data path
	string PathToData= S_path	//this is string with the USAXS path
	string SWAXSPathStr
	if(isSAXS)
	    SWAXSPathStr=ReplaceString("_usaxs", PathToData, "_saxs")
	else
	    SWAXSPathStr=ReplaceString("_usaxs", PathToData, "_waxs")
	endif
	//now start Nika
	NI1_APSConfigureNika()
	DoWIndow/hide=1 NI1_9IDCConfigPanel
	NVAR SAXSGenSmearedPinData = root:Packages:Convert2Dto1D:SAXSGenSmearedPinData
	SAXSGenSmearedPinData = 0
	NVAR SAXSDeleteTempPinData = root:Packages:Convert2Dto1D:SAXSDeleteTempPinData
	SAXSDeleteTempPinData = 1
	NVAR QvectorNumberPoints = root:Packages:Convert2Dto1D:QvectorNumberPoints
	NVAR USAXSSAXSselector = root:Packages:Convert2Dto1D:USAXSSAXSselector
	NVAR USAXSWAXSselector = root:Packages:Convert2Dto1D:USAXSWAXSselector
	NVAR QvectorMaxNumPnts = root:Packages:Convert2Dto1D:QvectorMaxNumPnts
	if(isSAXS)
		USAXSSAXSselector=1
		USAXSWAXSselector = 0
		QvectorNumberPoints = 200
	else
		USAXSSAXSselector=0
		USAXSWAXSselector = 1
		QvectorMaxNumPnts = 1
	endif
	variable i
	//now we need to do what is normally done in NI1_9IDCButtonProc when user selects the "Set default settings button...
	//first kill the Nexus loader file in case we are using same name for SAXS and WAXS...
	KillDataFolder/Z root:Packages:NexusImportTMP:
	//now we should be able to read this in without challenges?
	NI1A_Convert2Dto1DMainPanel()
	KillWindow/Z NI1A_Convert2Dto1DPanel
	NI1_Cleanup2Dto1DFolder() //make sure old grabrage is cleaned up.
	SVAR SampleNameMatchStr = root:Packages:Convert2Dto1D:SampleNameMatchStr
	SampleNameMatchStr = ""
	string selectedFile
	selectedFile = NI1_9IDCSetDefaultConfiguration(PathStr=SWAXSPathStr, FileNameStr=fileName)
	WAVE   SelectionsofCCDDataInCCDPath = root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers
	WAVE/T ListOfCCDDataInCCDPath       = root:Packages:Convert2Dto1D:ListOf2DSampleData
	SelectionsofCCDDataInCCDPath = 0
	//this selects in Main panel Listbox the file we want to import
	for(i = 0; i < numpnts(SelectionsofCCDDataInCCDPath); i += 1)
		if(stringmatch(selectedFile, ListOfCCDDataInCCDPath[i]))
			SelectionsofCCDDataInCCDPath[i] = 1
		endif
	endfor
	NI1A_DisplayOneDataSet()
	NI1_9IDCConfigNexus()
	NVAR ReadVals = root:Packages:Convert2Dto1D:ReadParametersFromEachFile
		//	if(ReadVals)
		//		for(i = 0; i < numpnts(SelectionsofCCDDataInCCDPath); i += 1)
		//			if(stringmatch(selectedFile, ListOfCCDDataInCCDPath[i]))
		//				SelectionsofCCDDataInCCDPath[i] = 1
		//			endif
		//		endfor
		//		NI1A_DisplayOneDataSet()
		//	endif
	DoWIndow/hide=1 CCDImageToConvertFig

	//and create mask automatically...
	if(isSAXS)
		NI1_9IDCCreateSAXSPixMask()
		TitleBox LoadBlankWarning, win=NI1_9IDCConfigPanel, title="\\Zr150>>>> Load Empty/Blank and set Slit legth; ... done   <<<<"
		//force user to find Slit length oif needed
		variable DesmearData           = 0
		NVAR   SAXSGenSmearedPinData = root:Packages:Convert2Dto1D:SAXSGenSmearedPinData
		//if(NVAR_Exists(DesmearData))
		//	if(DesmearData)
		SAXSGenSmearedPinData = 0 //user is generating desmeared data, likely does not need smeared SAXS data
//				else
//					NVAR USAXSSlitLength = root:Packages:Convert2Dto1D:USAXSSlitLength
//					USAXSSlitLength = NI1_9IDCFIndSlitLength()
//					NI1_9IDCSetLineWIdth()
//				endif
//			else
//				NVAR USAXSSlitLength = root:Packages:Convert2Dto1D:USAXSSlitLength
//				USAXSSlitLength = NI1_9IDCFIndSlitLength()
//				NI1_9IDCSetLineWIdth()
//			endif
	elseif(!isSAXS)		//WAXS
		NVAR UseLineProfile = root:Packages:Convert2Dto1D:UseLineProfile //uncheck just in case leftover from SAXS
		UseLineProfile = 0
		NVAR WAXSSubtractBlank = root:Packages:Convert2Dto1D:WAXSSubtractBlank
		NI1_9IDCWAXSBlankSUbtraction(WAXSSubtractBlank)
		NI1_9IDCCreateWAXSPixMask()
		TitleBox LoadBlankWarning, win=NI1_9IDCConfigPanel, title="\\Zr150>>>> Load Empty/Blank; ... done   <<<<"
	endif
	//end of mask creation
	//set user to Empty?Dasrk tab
	TabControl Convert2Dto1DTab, win=NI1A_Convert2Dto1DPanel, value=3
	NI1A_TabProc("NI1A_Convert2Dto1DPanel", 3)

	//OK, now we need to select Blank in Main panel, select sample in main panel and process the data. 
	//Simple ;-) 
	//load empty:
	string ADBlankFileName = ReplaceString(".h5",BlankFileName, ".hdf")
	NI1A_LoadEmptyOrDark("Empty", EmptyFileName =ADBlankFileName )
	KillWIndow/Z EmptyOrDarkImage
	//this is what button Process images does:
	NI1A_CheckParametersForConv()
	//set selections for using RAW/Converted data...
	NVAR LineProfileUseRAW      = root:Packages:Convert2Dto1D:LineProfileUseRAW
	NVAR LineProfileUseCorrData = root:Packages:Convert2Dto1D:LineProfileUseCorrData
	NVAR SectorsUseRAWData      = root:Packages:Convert2Dto1D:SectorsUseRAWData
	NVAR SectorsUseCorrData     = root:Packages:Convert2Dto1D:SectorsUseCorrData
	LineProfileUseRAW      = 0
	LineProfileUseCorrData = 1
	SectorsUseRAWData      = 0
	SectorsUseCorrData     = 1
	//selection done

#endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function/S IN4_processOneNikaFile(fileNameToLoad)
	string fileNameToLoad
		
#if(exists("NI1_APSConfigureNika")==6)			
	string DataWaveName          = "CCDImageToConvert"
	string DataWaveNameDis       = "CCDImageToConvert_dis" //name of copy (lin or log int) for display


	string	SelectedFileToLoad = fileNameToLoad //this is the file selected to be processed
	SVAR   UserSampleName        = root:Packages:Convert2Dto1D:UserSampleName
	UserSampleName     = RemoveEnding(RemoveListItem(ItemsInList(SelectedFileToLoad, ".") - 1, SelectedFileToLoad, "."))
	NI1A_ImportThisOneFile(SelectedFileToLoad)
	NI1A_LoadParamsUsingFncts(SelectedFileToLoad)
	WAVE/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	string Oldnote  = note(CCDImageToConvert)
	OldNote += NI1A_CalibrationNote()
	note/K CCDImageToConvert
	note CCDImageToConvert, OldNote
	NI1A_DezingerDataSetIfAskedFor(DataWaveName)
	NI1A_Convert2DTo1D()
	//NI1A_DisplayLoadedFile()
	//NI1A_DisplayTheRight2DWave()
	//NI1A_DoDrawingsInto2DGraph()
	//NI1A_CallImageHookFunction()
	//NI1_CalculateImageStatistics()
	//NEXUS_NikaSave2DData()

	
	
	SVAR LastProcessedDataSetFolder = root:Packages:Convert2Dto1D:LastProcessedDataSetFolder	
	return LastProcessedDataSetFolder
#endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function/S IN4_ImportDataSet(FileName)
	string FileName 	//assuminng this is USAXS data set!
	//need to open the HDF5 file and read the content into USAXS/SAXS/or WAXS folder. 
	//again, these are Matilda generated data, they are well known. 
	
	SVAR BlankFileName = root:Packages:Indra4:BlankFileName
	NVAR IncludeSAXS = root:Packages:Indra4:IncludeSAXS
	NVAR IncludeWAXS = root:Packages:Indra4:IncludeWAXS	
	variable i
	SVAR extensionStr=root:Packages:Indra4:DataSelListBoxExtString
	string pathToForData
	string SampleName,BlankName 
	string RealSampleName
	string ImportedFolders =""
	
	RealSampleName = RemoveEnding(RemoveEnding(FileName,extensionStr),".")	//TODO: sanitize properly sample name here to make it Igor friendly		
	RealSampleName = RealSampleName+"_NX"		//this adds _NX to the end to indicate, it came from Nexus file. 
	//USAXS data 
	PathInfo Indra4DataPath
	string PathToFileWithData = S_path
	
	NewDataFolder/O/S  root:USAXS
	NewDataFolder/O/S  $("root:USAXS:"+RealSampleName)
	pathToForData="root:USAXS:"+RealSampleName
	string USAXSFolderStr = pathToForData
	variable importSuccess
	//now we have location and we are there. Next is import from HDF5 file
	SampleName = FileName
	importSuccess = ReadMyNXcanSASUSAXS(FileName)
	if(importSuccess)
		ImportedFolders += pathToForData+";"
	endif
	print "Imported USAXS data for : "+ PathToFileWithData+SampleName

	if(IncludeSAXS)
		//now SAXS		
		SampleName = ReplaceString(".h5", FileName, ".hdf")
		NewDataFolder/O/S  root:SAXS
		NewDataFolder/O/S  $("root:SAXS:"+RealSampleName)
		pathToForData="root:SAXS:"+RealSampleName
		importSuccess = ReadMyNXcanSASSWAXS(PathToFileWithData, 1, SampleName)
		if(importSuccess)
			ImportedFolders += pathToForData+";"
		endif
		print "Imported SAXS data for : "+ PathToFileWithData+SampleName
	endif
	if(IncludeWAXS)
		//now WAXS
		SampleName = ReplaceString(".h5", FileName, ".hdf")	
		NewDataFolder/O/S  root:WAXS
		NewDataFolder/O/S  $("root:WAXS:"+RealSampleName)
		pathToForData="root:WAXS:"+RealSampleName
		importSuccess = ReadMyNXcanSASSWAXS(PathToFileWithData, 2, SampleName)		
		if(importSuccess)
			ImportedFolders += pathToForData+";"
		endif
		print "Imported WAXS data for : "+ PathToFileWithData+SampleName
	endif
	IN4_FixParamsAfterImport(UsaxsFolderStr)
	return  ImportedFolders

end

//**********************************************************************************************************
//**********************************************************************************************************
Function IN4_FixParamsAfterImport(UsaxsFolderStr)
	string UsaxsFolderStr
	
	//here we tweak various parameetrs after we import the data
	//also, can rename/add waves etc.
	//set the Blank name:
	SVAR BlankName = root:Packages:Indra4:BlankFileName
	Wave/Z DSM_Int = $(UsaxsFolderStr+":DSM_Int")
	if(WaveExists(DSM_Int))
		string mynote = note(DSM_Int)
		if(Strlen(mynote)>0)
			BlankName = StringByKey("BlankName", mynote, "=", ";" )
		else
			BlankName = ""
		endif
	endif	


end


//
//**********************************************************************************************************
//**********************************************************************************************************


Function ReadMyNXcanSASSWAXS(DataPathStr, SAXSorWAXS, filenameInput)
    String filenameInput, DataPathStr
    variable SAXSorWAXS //SAXSorWAXS = 1 for SAXS, 2=waxs

    String location

	variable FileID, groupID
	string AttrString
	string tempPathStr
	if(SAXSorWAXS==1)	//SAXS
		tempPathStr = ReplaceString("_usaxs", DataPathStr, "_saxs")
	elseif(SAXSorWAXS==2)	//WAXS
		tempPathStr = ReplaceString("_usaxs", DataPathStr, "_waxs")
	else
		return 0
	endif
	
	newPath/O/C SWAXSPath, tempPathStr  

	HDF5OpenFile /P=SWAXSPath /R /Z fileID as filenameInput
	if(V_Flag!=0)	//failed to open, bail out.
		return 0
	endif

	//first we need to check this file matches our needs.  There are file attributes we can check...
	// f.attrs['Matilda_version']  = '1.0.0' # version 2025-07-06
	//	        f.attrs['instrument']       = '12IDE USAXS'
	//        f.attrs['creator']          = 'Matilda NeXus writer'
	//        f.attrs['Matilda_version']  = '1.0.0' # version 2025-07-06
	//        f.attrs['NeXus_version']    = '4.3.0' #2025-5-9 4.3.0 is rc, it is current. 
	string fileAttribs
	fileAttribs = IN4_ReadAttributesInDict(fileID,"/", 1)
	string file_instrument=StringByKey("instrument",fileAttribs,"=",";")
	string file_creator=StringByKey("creator",fileAttribs,"=",";")
	string file_Matilda_version=StringByKey("Matilda_version",fileAttribs,"=",";")
	if(!stringmatch(file_instrument,"12IDE USAXS"))
		Abort "These data are not from correct instrument"
	endif
	if(!stringmatch(file_creator,"Matilda NeXus writer"))
		Abort "These data are not prepared by Matilda"
	endif
	//check on Matilda version in the future, original release is 
	//Matilda_version = 1.0.0 
	//this let's us make future changes and also deal with Igor saved data differently, if needed. 
	
	

    location = "entry/QRS_data/"
    HDF5OpenGroup /Z fileID, location, groupID
    if (V_Flag==0)
    	IN4_LoadWaveAndAppendAttribs(groupID, "R_R_int", "Intensity")
    	IN4_LoadWaveAndAppendAttribs(groupID, "R_R_Qvec", "Q")
    	IN4_LoadWaveAndAppendAttribs(groupID, "R_R_error", "Error")
	    HDF5CloseGroup groupID
    endif

    // Check for 'entry/Blank_data/'
    location = "entry/Blank_data/"
    HDF5OpenGroup /Z fileID, location, groupID
    if (V_Flag==0)
    	IN4_LoadWaveAndAppendAttribs(groupID, "BL_R_int", "Intensity")
    	IN4_LoadWaveAndAppendAttribs(groupID, "BL_R_Qvec", "Q")
    	IN4_LoadWaveAndAppendAttribs(groupID, "BL_R_error", "Error")
	    HDF5CloseGroup groupID
    endif


	//HDF5ListGroup /F /TYPE=3 fileID, "/entry/"
	string AllsasDatagroups
	string AttributesList="canSAS_class=SASentry;NX_class=NXsubentry;"
	AllsasDatagroups = IN4_FindGroupsWithAttributes(fileID, "/entry/", AttributesList)

    // These are the real calibrated data in the file, proper NXcanSAS data set...
    if(ItemsInList(AllsasDatagroups)>1)
    	print "Found too many data groups, something is wrong here, picking up first :"+AllsasDatagroups
    endif
    string dataname= stringFromList(0,AllsasDatagroups)
    string DataNameStr = ReplaceString(".hdf",filenameInput,"")
    location = dataname+"/sasdata/" 
    HDF5OpenGroup /Z fileID, location, groupID
    if (V_Flag==0)
    	IN4_LoadWaveAndAppendAttribs(groupID, "r_"+DataNameStr, "I")
    	IN4_LoadWaveAndAppendAttribs(groupID, "q_"+DataNameStr, "Q")
    	IN4_LoadWaveAndAppendAttribs(groupID, "s_"+DataNameStr, "Idev")
    	IN4_LoadWaveAndAppendAttribs(groupID, "w_"+DataNameStr, "Qdev")

	    HDF5CloseGroup groupID
    	
    endif
    HDF5CloseFile fileID
	return 1
End

//**********************************************************************************************************
//**********************************************************************************************************

Function IN4_LoadWaveAndAppendAttribs(locID, IgorWaveName, H5DataName)
		variable locID
		String IgorWavename, H5DataName
		//this will load wave and append its attributes to wavenote
     	HDF5LoadData /Q/Z /N=$(IgorWaveName) /O locID, H5DataName 
     	if(V_Flag!=0)
     		DoAlert/T="HDF5 wave load failed" 0, "Loading "+H5DataName+" to "+IgorWaveName+" failed"
     		return 0
     	endif
		Wave/Z wv = $(IgorWavename)
		if(WaveExists(wv))
			redimension/D wv
			string AttrString
			AttrString = IN4_ReadAttributesInDict(locID,H5DataName, 0)
			Note/NOCR Wv,AttrString 
		endif		
end

//**********************************************************************************************************
//**********************************************************************************************************

Function IN4_AppendAttributesInWaveNote(locID, IgorWavename, H5DataName)
		variable locID
		String IgorWavename, H5DataName

		Wave/Z wv = $(IgorWavename)
		if(WaveExists(wv))
			string AttrString
			AttrString = IN4_ReadAttributesInDict(locID,H5DataName, 0)
			Note/NOCR Wv,AttrString 
		endif
end

//**********************************************************************************************************

Function IN4_ImportRawUSAXS(filenameInput)	//this reads RAW USAXS data,  
    String filenameInput

    String location
	variable FileID, groupID
	string AttrString
	//assumes we are in the correct folder, ths is so we can use same code to import Blank
	HDF5OpenFile /P=Indra4DataPath /R /Z fileID as filenameInput
	if(V_Flag!=0)
		Abort "Import of data "+filenameInput +" failed in IN4_ImportRawUSAXS"
	endif
	
	string FileAttr = IN4_ReadAttributesInDict(fileID,"/", 1)
	string scan_mode=StringByKey("scan_mode", FileAttr , "=", ";")
	string instrumentName=StringByKey("instrument", FileAttr , "=", ";")
	if(StringMatch(scan_mode, "USAXS fly scan" )&&StringMatch(instrumentName, "12IDE USAXS") )
		print "importing 12IDE Flyscan from file "+filenameInput
		//now we need to import the data from Flyscan. These are values named same as in Python
		IN4_LoadWaveAndAppendAttribs(fileID, "ARangles", "/entry/flyScan/AR_PulsePositions")
		//ARangles is too long, 8k points instead of 7999 as the other arrays. Delete first point
		Wave ArAngles
		DeletePoints 0, 1, ArAngles
		IN4_LoadWaveAndAppendAttribs(fileID, "TimePerPoint", "/entry/flyScan/mca1")
		IN4_LoadWaveAndAppendAttribs(fileID, "Monitor", "/entry/flyScan/mca2")
		IN4_LoadWaveAndAppendAttribs(fileID, "UPD_array", "/entry/flyScan/mca3")
		//these are range change records
		IN4_LoadWaveAndAppendAttribs(fileID, "AmpGain", "/entry/flyScan/changes_DDPCA300_ampGain")
		IN4_LoadWaveAndAppendAttribs(fileID, "AmpReqGain", "/entry/flyScan/changes_DDPCA300_ampReqGain")
		IN4_LoadWaveAndAppendAttribs(fileID, "Channel", "/entry/flyScan/changes_DDPCA300_mcsChan")
		variable/g vtof = IN4_ReadVariable(fileID,"/entry/flyScan/mca_clock_frequency")
		variable/g FS_scanTime = IN4_ReadVariable(fileID,"/entry/flyScan/FS_ScanTime")
		vTof = 1e6	//overwrite as recorded value is wrong. 
		//        #metadata
		string keys_to_keep = "AR_center, ARenc_0, DCM_energy, DCM_theta, I0Gain,detector_distance,timeStamp,I0AmpGain,trans_pin_counts,trans_pin_gain,trans_pin_time,trans_I0_counts,trans_I0_gain,"
		keys_to_keep += "UPDsize, trans_I0_counts, trans_I0_gain, upd_bkg0, upd_bkg1,upd_bkg2,upd_bkg3,upd_bkgErr0,upd_bkgErr1,upd_bkgErr2,upd_bkgErr3,upd_bkgErr4,upd_bkg_err0,"
		keys_to_keep += "upd_bkg4,DDPCA300_gain0,DDPCA300_gain1,DDPCA300_gain2,DDPCA300_gain3,DDPCA300_gain4,upd_amp_change_mask_time0,upd_amp_change_mask_time1,upd_amp_change_mask_time2,upd_amp_change_mask_time3,upd_amp_change_mask_time4"
		string/g metadata = IN4_ReadGroupItemsToDict(fileID,"/entry/metadata",keys_to_keep)
		metadata=ReplaceStringByKey("ScanType",metadata, "Flyscan", "=",";")

		string/g metadata_all = IN4_ReadGroupItemsToDict(fileID,"/entry/metadata","")
		//        # we need this key to be there also... Copy of the other one. 
		//        metadata_dict["I0Gain"]=I0Gain
		string I0Gain=StringByKey("I0AmpGain", metadata, "=", ";")   
		metadata=ReplaceStringByKey("I0Gain",metadata, I0Gain, "=",";")
		//        #Instrument
		keys_to_keep="monochromator,energy,wavelength"
		string/g instrument = IN4_ReadGroupItemsToDict(fileID,"/entry/instrument",keys_to_keep)
		//        # sample
		string/g sample = IN4_ReadGroupItemsToDict(fileID,"/entry/sample","")
		//now we should have same data as Python. 
		string/g filename = filenameInput
		string/g blankname = ""
	else
		print "Step scan not done yet. "
	endif

    HDF5CloseFile fileID

end


//**********************************************************************************************************
//**********************************************************************************************************

Function ReadMyNXcanSASUSAXS(filenameInput)
    String filenameInput

    String location

	variable FileID, groupID
	string AttrString

	HDF5OpenFile /P=Indra4DataPath /R /Z fileID as filenameInput
	if(V_Flag!=0)	//failed to open, bail out.
		return 0
	endif
		
	//first we need to check this file matches our needs.  There are file attributes we can check...
	// f.attrs['Matilda_version']  = '1.0.0' # version 2025-07-06
	//	        f.attrs['instrument']       = '12IDE USAXS'
	//        f.attrs['creator']          = 'Matilda NeXus writer'
	//        f.attrs['Matilda_version']  = '1.0.0' # version 2025-07-06
	//        f.attrs['NeXus_version']    = '4.3.0' #2025-5-9 4.3.0 is rc, it is current. 
	// or if rewritten by Indra: 
	//	AttrList = "default=entry;filename="+filenameInput+";instrument=12IDE USAXS;creator=Indra Nexus writer;"
	//AttrList += "Indra_version=4.0.0;NeXus_version=4.3.0;file_time="+stringByKey("timeStamp",metadata,"=",";")+";"
	string fileAttribs
	fileAttribs = IN4_ReadAttributesInDict(fileID,"/", 1)
	string file_instrument=StringByKey("instrument",fileAttribs,"=",";")
	string file_creator=StringByKey("creator",fileAttribs,"=",";")
	string file_Matilda_version=StringByKey("Matilda_version",fileAttribs,"=",";")
	string file_Indra_version=StringByKey("Indra_version",fileAttribs,"=",";")
	if(!stringmatch(file_instrument,"12IDE USAXS"))
		Abort "These data are not from correct instrument"
	endif
	if(stringmatch(file_creator,"Matilda NeXus writer")==0 && stringmatch(file_creator,"Indra Nexus writer")==0)
		Abort "These data are not prepared by Matilda"
	endif
	//check on Matilda version in the future, original release is 
	//Matilda_version = 1.0.0 
	//Indra_version=4.0.0
	//this let's us make future changes and also deal with Igor saved data differently, if needed. 


    location = "entry/QRS_data/"
    HDF5OpenGroup /Z fileID, location, groupID
    if (V_Flag==0)
    	IN4_LoadWaveAndAppendAttribs(groupID, "R_int", "Intensity")
    	IN4_LoadWaveAndAppendAttribs(groupID, "R_Qvec", "Q")
    	IN4_LoadWaveAndAppendAttribs(groupID, "R_error", "Error")
	    HDF5CloseGroup groupID
    endif

    // Check for 'entry/Blank_data/'
    location = "entry/Blank_data/"
    HDF5OpenGroup /Z fileID, location, groupID
    if (V_Flag==0)
    	IN4_LoadWaveAndAppendAttribs(groupID, "BL_R_int", "Intensity")
    	IN4_LoadWaveAndAppendAttribs(groupID, "BL_R_Qvec", "Q")
    	IN4_LoadWaveAndAppendAttribs(groupID, "BL_R_error", "Error")
	    HDF5CloseGroup groupID
    endif

	string AllsasDatagroups
	string AttributesList="canSAS_class=SASentry;NX_class=NXsubentry;"
	AllsasDatagroups = IN4_FindGroupsWithAttributes(fileID, "/entry/", AttributesList)
    // Find the first SASentries with '_SMR'
    location = removeending(GrepList(AllsasDatagroups,  "_SMR"),";")+"/sasdata/"
    HDF5OpenGroup /Z fileID, location, groupID
    if (V_Flag==0)
    	IN4_LoadWaveAndAppendAttribs(groupID, "SMR_Int", "I")
    	IN4_LoadWaveAndAppendAttribs(groupID, "SMR_Qvec", "Q")
    	IN4_LoadWaveAndAppendAttribs(groupID, "SMR_Error", "Idev")
    	IN4_LoadWaveAndAppendAttribs(groupID, "SMR_dQ", "dQw")
    	//separately deal with slit length
    	HDF5LoadData /Q /N=SlitLengthWave /O groupID, "dQl" 
	    HDF5CloseGroup groupID

    	wave SlitLengthWave
    	variable/g Slitlength = SLitLengthWave[0]
    	killWaves SlitLengthWave
    	//Add slit length to SMR_Int
    	WAVE SMR_Int
    	string oldnote = note(SMR_Int)
    	oldNote+="SlitLength="+num2str(Slitlength)+";"   
    	note/K/NOCR SMR_Int, oldNote
    endif

    // Find the first SASentries without '_SMR'
    location = ReplaceString("_SMR", location,"") 
    HDF5OpenGroup /Z fileID, location, groupID
    if (V_Flag==0)
    	IN4_LoadWaveAndAppendAttribs(groupID, "DSM_Int", "I")
    	IN4_LoadWaveAndAppendAttribs(groupID, "DSM_Qvec", "Q")
    	IN4_LoadWaveAndAppendAttribs(groupID, "DSM_Error", "Idev")
    	IN4_LoadWaveAndAppendAttribs(groupID, "DSM_dQ", "Qdev")
	    HDF5CloseGroup groupID
    	
    endif
    HDF5CloseFile fileID
	return 1
End

//**********************************************************************************************************
//**********************************************************************************************************

Function IN4_SaveUSAXSDataInNexus(filenameInput)
    String filenameInput

    String location
	variable FileID, groupID
	string AttrString, AttrList
	//check if user wants to save data
	NVAR ShouldSave=root:Packages:Indra4:SaveRereducedDataToNexus
	if(!ShouldSave)
		return 0
	endif
	
	//we assume we are in the right folder, we can also use this to save Blank data (entry/QRS_data)
	HDF5OpenFile /P=Indra4DataPath /Z fileID as filenameInput
	if(V_Flag!=0)
		Abort "Opening of Nexus file "+filenameInput +" failed in IN4_SaveUSAXSDataInNexus"
	endif
	SVAR blankname
	SVAR filename
	SVAR metadata
	SVAR sample
	string sampleName=removeending(filename,".h5")
	sampleName = removeending(RemoveListItem(ItemsInList(sampleName,"_")-1,sampleName,"_"),"_")
	make/Free/T/N=1 twv
	make/Free/N=1 numwv

	// add attributes to /
	AttrList = "default=entry;file_name="+filenameInput+";instrument=12IDE USAXS;creator=Indra Nexus writer;"
	AttrList += "Indra_version=4.0.0;NeXus_version=4.3.0;file_time="+stringByKey("timeStamp",metadata,"=",";")+";"
	IN4_NXwriteGrpAttribList(fileID,"/", AttrList)
	//create /entry and add stuff to it. 
	location = "entry/"
	HDF5createGroup /Z fileID, location, groupID
    if (V_Flag==0)
		AttrList = "NX_class=NXentry;canSAS_class=SASentry;default="+sampleName+";"
		IN4_NXwriteGrpAttribList(fileID,location, AttrList)
		twv[0] = "NXsas"
		IN4_NXwriteDataSetWAttribs(groupID,twv,"definition", "")
	    HDF5CloseGroup groupID
    endif

	//create data in various folders. 
	Wave/Z R_int
	Wave/Z R_Qvec
	Wave/Z R_error
	if(WaveExists(R_int))
		location = "entry/QRS_data/"
		HDF5createGroup /Z fileID, location, groupID
	    if (V_Flag==0)
	    	//IN4_LoadWaveAndAppendAttribs(groupID, "R_int", "Intensity")
	    	IN4_NXwriteDataSetWAttribs(groupID,R_int,"Intensity", "units=arb;long_name=Intensity;")
	    	//IN4_LoadWaveAndAppendAttribs(groupID, "R_Qvec", "Q")
	    	IN4_NXwriteDataSetWAttribs(groupID,R_Qvec,"Q", "units=1/angstrom;long_name=Q;")
	    	//IN4_LoadWaveAndAppendAttribs(groupID, "R_error", "Error")
	    	IN4_NXwriteDataSetWAttribs(groupID,R_error,"Error", "units=arb;long_name=Error;")
		    HDF5CloseGroup groupID
	    endif
	endif
	
	Wave/Z BL_R_Error
	Wave/Z BL_R_Int
	Wave/Z BL_R_Qvec
	if(WaveExists(BL_R_Int))
		location = "entry/Blank_data/"
		HDF5createGroup /Z fileID, location, groupID
	    if (V_Flag==0)
	    	//IN4_LoadWaveAndAppendAttribs(groupID, "R_int", "Intensity")
	    	IN4_NXwriteDataSetWAttribs(groupID,BL_R_Int,"Intensity", "units=arb;long_name=Intensity;blankname="+blankname+";")
	    	//IN4_LoadWaveAndAppendAttribs(groupID, "R_Qvec", "Q")
	    	IN4_NXwriteDataSetWAttribs(groupID,BL_R_Qvec,"Q", "units=1/angstrom;long_name=Q;")
	    	//IN4_LoadWaveAndAppendAttribs(groupID, "R_error", "Error")
	    	IN4_NXwriteDataSetWAttribs(groupID,BL_R_Error,"Error", "units=arb;long_name=Error;")
		    HDF5CloseGroup groupID
	    endif
	endif

	Wave/Z SMR_Int
	Wave/Z SMR_Qvec
	Wave/Z SMR_dQ
	Wave/Z SMR_Error
	if(WaveExists(SMR_Int))
		location = "entry/"+sampleName+"_SMR/"
		HDF5createGroup /Z fileID, location, groupID
	    if (V_Flag==0)
			//append attributes here. 
			AttrList = "NX_class=NXsubentry;canSAS_class=SASentry;default=sasdata;title="+sampleName+";"
			IN4_NXwriteGrpAttribList(fileID,location, AttrList)
			twv[0] = "NXcanSAS"
			IN4_NXwriteDataSetWAttribs(groupID,twv,"definition", "")
			twv[0] = sampleName
			IN4_NXwriteDataSetWAttribs(groupID,twv,"title", "")
			twv[0] = "run_identifier"
			IN4_NXwriteDataSetWAttribs(groupID,twv,"run", "")
		    HDF5CloseGroup groupID
	    endif
		location = "entry/"+sampleName+"_SMR/sasdata/"
		HDF5createGroup /Z fileID, location, groupID
	    if (V_Flag==0)
			//append attributes here. 
			AttrList = "NX_class=NXdata;canSAS_class=SASdata;signal=I;I_axes=Q;"
			IN4_NXwriteGrpAttribList(fileID,location, AttrList)
			AttrList = "units=1/cm;uncertainties=Idev;long_name=Intensity[cm2/cm3];"
			AttrList += "Kfactor="+stringByKey("Kfactor",metadata,"=",";")+";"
			AttrList += "OmegaFactor="+stringByKey("OmegaFactor",metadata,"=",";")+";"
			AttrList += "blankname="+blankname+";"
			AttrList += "thickness="+stringByKey("thickness",sample,"=",";")+";"
			AttrList += "label=label;"  	
			IN4_NXwriteDataSetWAttribs(groupID,SMR_Int,"I", AttrList)
			AttrList = "units=1/angstrom;resolutions=dQw,dQl;long_name=Q (A^-1);"
			IN4_NXwriteDataSetWAttribs(groupID,SMR_Qvec,"Q", AttrList)
			AttrList = "units=1/angstrom;long_name=dQw (A^-1);"
			IN4_NXwriteDataSetWAttribs(groupID,SMR_dQ,"dQw", AttrList)
			AttrList = "units=cm2/cm3;long_name=Uncertainties;"
			IN4_NXwriteDataSetWAttribs(groupID,SMR_Error,"Idev", AttrList)
			numwv[0] = numberByKey("SlitLength",metadata,"=",";") 
			AttrList = "units=1/angstrom;long_name=dQl (A^-1);"
			IN4_NXwriteDataSetWAttribs(groupID,numwv,"dQl", AttrList)
		    HDF5CloseGroup groupID
	    endif
	endif
	Wave/Z DSM_Int
	Wave/Z DSM_Qvec
	Wave/Z DSM_dQ
	Wave/Z DSM_Error
	if(WaveExists(DSM_Int))
		location = "entry/"+sampleName+"/"
		HDF5createGroup /Z fileID, location, groupID
	    if (V_Flag==0)
			//append attributes here. 
			AttrList = "NX_class=NXsubentry;canSAS_class=SASentry;default=sasdata;title="+sampleName+";"
			IN4_NXwriteGrpAttribList(fileID,location, AttrList)
			twv[0] = "NXcanSAS"
			IN4_NXwriteDataSetWAttribs(groupID,twv,"definition", "")
			twv[0] = sampleName
			IN4_NXwriteDataSetWAttribs(groupID,twv,"title", "")
			twv[0] = "run_identifier"
			IN4_NXwriteDataSetWAttribs(groupID,twv,"run", "")
		    HDF5CloseGroup groupID
	    endif
		location = "entry/"+sampleName+"/sasdata/"
		HDF5createGroup /Z fileID, location, groupID
	    if (V_Flag==0)
			//append attributes here. 
			AttrList = "NX_class=NXdata;canSAS_class=SASdata;signal=I;I_axes=Q;"
			IN4_NXwriteGrpAttribList(fileID,location, AttrList)
			AttrList = "units=1/cm;uncertainties=Idev;long_name=Intensity (cm2/cm3);"
			AttrList += "Kfactor="+stringByKey("Kfactor",metadata,"=",";")+";"
			AttrList += "OmegaFactor="+stringByKey("OmegaFactor",metadata,"=",";")+";"
			AttrList += "blankname="+blankname+";"
			AttrList += "thickness="+stringByKey("thickness",sample,"=",";")+";"
			AttrList += "label="+sampleName+";"  	
			IN4_NXwriteDataSetWAttribs(groupID,DSM_Int,"I", AttrList)
			AttrList = "units=1/angstrom;resolutions=Qdev;long_name=Q (A^-1);"
			IN4_NXwriteDataSetWAttribs(groupID,DSM_Qvec,"Q", AttrList)
			AttrList = "units=1/angstrom;long_name=dQ (A^-1);"
			IN4_NXwriteDataSetWAttribs(groupID,DSM_dQ,"Qdev", AttrList)
			AttrList = "units=cm2/cm3;long_name=Uncertainties;"
			IN4_NXwriteDataSetWAttribs(groupID,DSM_Error,"Idev", AttrList)
		    HDF5CloseGroup groupID
	    endif
	    
	endif

	HDF5CloseFile FileID
end
//**********************************************************************************************************
//**********************************************************************************************************
Function IN4_NXwriteDataSetWAttribs(locID,DataInWave,NXDataName, AttrList)
	variable locID
	wave DataInWave
	string NXDataName, AttrList
	//save the data
	HDF5SaveData /O  DataInWave, locID, NXDataName
	variable i, items
	string tempStr, AttrName, AttrVal
	items = ItemsInList(AttrList,";")
	make/T/Free/N=1 groupAttribute
	For(i=0;i<items;i+=1)
		tempStr = StringFromList(i,AttrList,";")
		AttrName=StringFromList(0,tempStr,"=")
		AttrVal=StringFromList(1,tempStr,"=")
		groupAttribute = AttrVal
		HDF5SaveData /O/A=AttrName/STRF={0,1,0} groupAttribute, locID, NXDataName
	endfor	
end

//**********************************************************************************************************
//**********************************************************************************************************

Function IN4_NXwriteGrpAttribList(locID,NXlocation, AttrList)
	variable locID
	string NXlocation, AttrList
	//save the data
	variable i, items
	string tempStr, AttrName, AttrVal
	items = ItemsInList(AttrList,";")
	make/T/Free/N=1 groupAttribute
	For(i=0;i<items;i+=1)
		tempStr = StringFromList(i,AttrList,";")
		AttrName=StringFromList(0,tempStr,"=")
		AttrVal=StringFromList(1,tempStr,"=")
		groupAttribute = AttrVal
		HDF5SaveData /O/A=AttrName/STRF={0,1,0} groupAttribute, locID, NXlocation
	endfor	
end

//**********************************************************************************************************
//**********************************************************************************************************

Function/S IN4_FindGroupsWithAttributes(locID, pathToLoc, AttributesList)
			variable locID
			string AttributesList, PathToLoc
		//AttributesList="canSAS_class=SASentry;NX_class=NXsubentry;"
		//PathToLoc = "/entry/"
			
		string ListOfMatchingGroups=""
		HDF5ListGroup /F/Z /TYPE=3 locID, PathToLoc
		if(V_Flag!=0)
			return ""
		endif
		//S_HDF5ListGroup is list all groups here...
		if(ItemsInList(S_HDF5ListGroup)<1)
			return ""
		endif
		string TempGroup, tempGroupAttrList, tempstr
		variable i, ii, matches
		For(i=0;i<ItemsInList(S_HDF5ListGroup);i+=1)
			matches = 0
			TempGroup = StringFromList(i,S_HDF5ListGroup)
			tempGroupAttrList = IN4_ReadAttributesInDict(locID,TempGroup, 1)
			if(ItemsInList(tempGroupAttrList)>0)
				For(ii=0;ii<ItemsInList(AttributesList);ii+=1)
					tempstr = StringFromList(ii,AttributesList)
					if(stringmatch(tempGroupAttrList,"*"+tempstr+"*"))
						matches+=1
					endif
				endfor
				if(matches==ItemsInList(AttributesList))
					ListOfMatchingGroups+=TempGroup+";"
				endif
			endif
		endfor
		return ListOfMatchingGroups
end


//**********************************************************************************************************
//**********************************************************************************************************

Function/S IN4_ReadAttributesInDict(locID,ItemNamePath, isGroup)
			variable locID, isGroup
			string ItemNamePath
			//will read attributes from the item located above. 
			//get all attributes:
			variable type
			Variable i, imax
			string tempAttrName, AttributesDict=""
			type = isGroup ?  1 : 2
			HDF5ListAttributes /TYPE=(type) /Z locID, ItemNamePath
			if(V_Flag!=0)
				return ""
			endif
			imax = ItemsInList(S_HDF5ListAttributes)
			For(i=0;i<imax;i+=1)
				tempAttrName = StringFromList(i,S_HDF5ListAttributes)
				
		
			HDF5LoadData /Q /O /A=tempAttrName /TYPE=(type) /N=tempAttributeWave /Z locID, ItemNamePath	
				if (V_Flag == 0)
					Wave testWave = tempAttributeWave
					if (WaveType(testWave) == 0)
						Wave/T testWavestr = tempAttributeWave
						AttributesDict+=tempAttrName+"="+testWavestr[0]+";"		// Attribute is string, not numeric
					else
						AttributesDict+=tempAttrName+"="+num2str(testWave[0])+";"
					endif
					KillWaves/Z tempAttributeWave
				endif
			endfor
			
	return AttributesDict		
end			

//**********************************************************************************************************
//**********************************************************************************************************
Function/S IN4_ReadGroupItemsToDict(locID,PathToGroup,ListOfItemsToKeep)
	variable locID
	string PathToGroup,ListOfItemsToKeep
	//this will load group into itemized list while optionally keeping only list of keys to keep
	string ListOfItems, itemName, itemPathName
	string resultDict=""
	variable groupID, i
	HDF5OpenGroup /Z locID, PathToGroup, groupID
	if(V_Flag!=0)
		return ""
	endif
	HDF5ListGroup/R groupID, "."
	ListOfItems = S_HDF5ListGroup
	if(ItemsInList(ListOfItems)<1)
		return ""
	endif
	//ListOfItemsToKeep
	For(i=0;i<ItemsInList(ListOfItems);i+=1)
		itemName=stringFromList(i,ListOfItems)	//recursive, so can be something like monochromator/energy, need to match the last value...
		itemPathName=itemName
		if(stringmatch(itemName,"*/*"))
			itemName = StringFromList(ItemsInList(itemName, "/")-1, itemName, "/")
		endif
		if (grepString(ListOfItemsToKeep,itemName)||ItemsInList(ListOfItemsToKeep)<1)
			HDF5LoadData /Q /O /N=tempWv /Z groupID, itemPathName	
			if (V_Flag == 0)
				Wave testWave = tempWv
				if (WaveType(testWave) == 0)
					Wave/T testWavestr = tempWv
					resultDict+=itemName+"="+testWavestr[0]+";"		// Attribute is string, not numeric
					KillWaves/Z testWavestr
				else
					resultDict+=itemName+"="+num2str(testWave[0],"%.15g")+";"
					KillWaves/Z testWave
				endif
			endif
		endif
	endfor
	HDF5CloseGroup groupID
	return resultDict

end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IN4_ReadVariable(locID,PathToItem)
	variable locID
	string PathToItem
	variable result
	HDF5LoadData /Q /O /N=tempWv /Z locID, PathToItem	
	if (V_Flag == 0)
		Wave testWave = tempWv
		if (WaveType(testWave) == 0)
			Wave/T testWavestr = tempWv
			result=NaN		// Attribute is string, not numeric
			KillWaves/Z testWavestr
		else
			result = testWave[0]
			KillWaves/Z testWave
		endif
	endif
	return result

end

//**********************************************************************************************************
//**********************************************************************************************************
