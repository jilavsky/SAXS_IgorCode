#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.11		//dated 10/25/2009


//*************************************************************************\
//* Copyright (c) 2005 - 2010, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.11 added license for ANL

//this is package for support of DND CAT beamline. 
// version 1.1 uses 1/T and I0/I0empty to correct the Sa2D and EF2d for the weird processing Steve does for the data. It was tested on data from new data format 
// used data 10 13 2009, tested against Glassy carbon standard and got my 30.7 cm^-1 as expected.
//


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function NI1_DNDCreateHelpNbk()
	String nb = "DND_Instructions"
	DoWindow DND_Instructions
	if(V_Flag)
		DoWindow /F DND_Instructions
		return 1
	endif
	NewNotebook/N=$nb/F=1/V=1/K=0/W=(459,208,999,491)
	Notebook $nb defaultTab=36, statusWidth=252
	Notebook $nb showRuler=1, rulerUnits=1, updating={1, 60}
	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	Notebook $nb newRuler=Title, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",12,3,(0,0,0)}
	Notebook $nb ruler=Title, text="Instructions for use of DND CAT special configuration\r"
	Notebook $nb ruler=Normal, text="\r"
	Notebook $nb text="1. Select \"DND/txt\" Image type\r"
	Notebook $nb text="2. Load one txt file located in .../APSCycle/YourName/Month/processing/plot_files, these are the files w"
	Notebook $nb text="ith the data you want. Note, you can load DND processed data from these files into the Irena package usi"
	Notebook $nb text="ng ASCII loader. Q is second column, Intensty is third and error is fourth. \r"
	Notebook $nb text="3. Select in the \"SAS 2D\"->\"Instrument configurations\"--> \"DND CAT\". This will configure the Nika proper"
	Notebook $nb text="ly, including wavelength, distance, etc.\r"
	Notebook $nb text="4. Create mask. You need to create it.\r"
	Notebook $nb text="4. Select the text file and load. Nika will parse parameters from this file and locate the tif file to b"
	Notebook $nb text="e loaded. Note, that if you changed the folder structure you may have to point Nika to location of the t"
	Notebook $nb text="iff files.\r"
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function NI1_DNDConfigureNika()

	//this function will configure Nika for use with DND CAT data
	string OldDf=getDataFolder(1)
	if(!DataFolderExists("root:DNDCAtLookupTables"))
		NI1_DNDCreateHelpNbk()
		Abort "Load some DND data in first to create string with header information"
	endif
	string ListOfheaders=""
	setDataFolder root:DNDCAtLookupTables
	ListOfheaders = DataFolderDir(8 )
	ListOfheaders = ReplaceString("STRINGS:", ListOfheaders, "" )
	ListOfheaders = ReplaceString(",", ListOfheaders, ";" )
	string Selectedheader
	Prompt Selectedheader, "Select header with proper calibration", popup, ListOfheaders
	DoPrompt "Select right configuration", Selectedheader
	if(V_Flag)
		setDataFolder OldDf
		abort
	endif

	//and now configrue items:
	NVAR Dist=root:Packages:Convert2Dto1D:SampleToCCDDistance
	Dist=NI1_DNDSampleToDetDistance(Selectedheader)
	
	NVAR wvlng=root:Packages:Convert2Dto1D:Wavelength
	wvlng=NI1_DNDWavelength(Selectedheader)
	NVAR PixX=root:Packages:Convert2Dto1D:PixelSizeX
	pixX=NI1_DNDPixelSize(Selectedheader)
	NVAR pixY=root:Packages:Convert2Dto1D:PixelSizeY
	pixY=NI1_DNDPixelSize(Selectedheader)
	
	NVAR BmX=root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BMY=root:Packages:Convert2Dto1D:BeamCenterY
	Wave Img=root:Packages:Convert2Dto1D:CCDImageToConvert
	//BmX=DimSize(Img, 0)-  NI1_DNDBeamCenterX(Selectedheader)
	BmX= NI1_DNDBeamCenterX(Selectedheader)
	BMY=DimSize(Img, 1) - 1 - NI1_DNDBeamCenterY(Selectedheader)			//fixed -1 JIL 10 14 09 since I again forgot about 0 numbering... 
	
	NVAR SaTh=root:Packages:Convert2Dto1D:SampleThickness
	NVAR UseSaTH=root:Packages:Convert2Dto1D:UseSampleThickness
	NVAR UseSaThF=root:Packages:Convert2Dto1D:UseSampleThicknFnct
	SVAR SaThFnct=root:Packages:Convert2Dto1D:SampleThicknFnct
	UseSaTh=1
	UseSaThF =1
	SaThFnct="NI1_DNDSampleThickness"
	
	NVAR CorrectionFactor=root:Packages:Convert2Dto1D:CorrectionFactor
	NVAR UseCorrectionFactor=root:Packages:Convert2Dto1D:UseCorrectionFactor
	UseCorrectionFactor=1
	NVAR UseSampleCorrectFnct = root:Packages:Convert2Dto1D:UseSampleCorrectFnct
	UseSampleCorrectFnct=1
	SVAR SampleCorrectFnct = root:Packages:Convert2Dto1D:SampleCorrectFnct
	SampleCorrectFnct ="NI1_DNDSampleCorrFnct"
	
//	NVAR UseSampleMeasTime=root:Packages:Convert2Dto1D:UseSampleMeasTime
//	NVAR UseSampleMeasTimeFnct=root:Packages:Convert2Dto1D:UseSampleMeasTimeFnct
//	SVAR SampleMeasTimeFnct=root:Packages:Convert2Dto1D:SampleMeasTimeFnct
//	NVAR SampleMeasurementTime=root:Packages:Convert2Dto1D:SampleMeasurementTime
//	UseSampleMeasTime=1
//	UseSampleMeasTimeFnct=1
//	SampleMeasTimeFnct = "NI1_DNDSampleMeasTime"

	NVAR UseSampleTransmission=root:Packages:Convert2Dto1D:UseSampleTransmission
	NVAR SampleTransmission=root:Packages:Convert2Dto1D:SampleTransmission
	SVAR SampleTransmFnct=root:Packages:Convert2Dto1D:SampleTransmFnct
	NVAR UseSampleTransmFnct=root:Packages:Convert2Dto1D:UseSampleTransmFnct
	NVAR UseEmptyMonitorFnct=root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
	NVAR UseSampleMonitorFnct=root:Packages:Convert2Dto1D:UseSampleMonitorFnct
	NVAR SampleI0=root:Packages:Convert2Dto1D:SampleI0
	SVAR EmptyMonitorFnct=root:Packages:Convert2Dto1D:EmptyMonitorFnct

	NVAR UseMonitorForEF=root:Packages:Convert2Dto1D:UseMonitorForEF
	SampleI0=1
	UseMonitorForEF=1
	UseSampleMonitorFnct=0
	UseEmptyMonitorFnct=1
	EmptyMonitorFnct="NI1_DNDEmptyCorrection"

	UseSampleTransmission=1
	UseSampleTransmFnct=1
	SampleTransmFnct="NI1_DNDSampleTransmission"
	
	NVAR DoGeometryCorrection=root:Packages:Convert2Dto1D:DoGeometryCorrection
	NVAR DoPolarizationCorrection=root:Packages:Convert2Dto1D:DoPolarizationCorrection
	NVAR UseSolidAngle=root:Packages:Convert2Dto1D:UseSolidAngle
	DoPolarizationCorrection=1
	DoGeometryCorrection=1
	UseSolidAngle=0
	
	NI1A_SetCalibrationFormula()

	
	setDataFolder OldDf
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function NI1_DNDEmptyCorrection(UselessString)
	string UselessString

	NVAR useEmptyField = root:Packages:Convert2Dto1D:useEmptyField
	variable target
	if(useEmptyField)
		SVAR CurrentEmptyName = root:Packages:Convert2Dto1D:CurrentEmptyName

		string Fixedname= RemoveEnding(CurrentEmptyName, ".txt") [0,31] 
		SVAR/Z curKwList=$("root:DNDCAtLookupTables:"+Fixedname)
		if(!SVAR_Exists(curKwList))
			Abort "Problem in NI1_DNDSampleTransmission routine, please contact auhtor of the code"
		endif
		variable IToverI0 = NumberByKey("Relative transmission it/i0",curKwList,"=",";")
			variable ctTime = NumberByKey("Exposure time (s)",curKwList,"=",";")
		if(numtype(ctTime)!=0)
			ctTime = NumberByKey("Mean exposure time (s)",curKwList,"=",";")
		endif
		variable I0 = NumberByKey("Incident intensity (cps)",curKwList,"=",";")
		if(numtype(I0)!=0)
			I0 = NumberByKey("Mean incident intensity (cps)",curKwList,"=",";")
		endif
		variable NormI0 = NumberByKey("Original normalization number (cps)",curKwList,"=",";")
		variable Itransmitted=NumberByKey("Transmitted intensity",curKwList,"=",";")
		if(numtype(Itransmitted)!=0)
			Itransmitted = NumberByKey("Mean transmitted intensity (cps)",curKwList,"=",";")
		endif
		variable normfct=NumberByKey("Image normalization scale factor (norm/i0)",curKwList,"=",";")
		if(numtype(normfct)!=0)
			normfct = NumberByKey("Mean image normalization scale factor sum(norm/i0)/n",curKwList,"=",";")
		endif
	
		 target =(normfct* Itransmitted *cttime)
	else
		target=1
	endif
//print "Empty Corr factor = "+num2str(target)
	return target
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function NI1_DNDSampleTransmission(FileNameStr)
	string FileNameStr
	string Fixedname= RemoveEnding(FileNameStr, ".txt") [0,31] 
	SVAR/Z curKwList=$("root:DNDCAtLookupTables:"+Fixedname)
	if(!SVAR_Exists(curKwList))
		Abort "Problem in NI1_DNDSampleTransmission routine, please contact auhtor of the code"
	endif
	variable target
	variable IToverI0 = NumberByKey("Relative transmission it/i0",curKwList,"=",";")
		variable ctTime = NumberByKey("Exposure time (s)",curKwList,"=",";")
	if(numtype(ctTime)!=0)
		ctTime = NumberByKey("Mean exposure time (s)",curKwList,"=",";")
	endif
	variable I0 = NumberByKey("Incident intensity (cps)",curKwList,"=",";")
	if(numtype(I0)!=0)
		I0 = NumberByKey("Mean incident intensity (cps)",curKwList,"=",";")
	endif
	variable NormI0 = NumberByKey("Original normalization number (cps)",curKwList,"=",";")
	variable Itransmitted=NumberByKey("Transmitted intensity",curKwList,"=",";")
	if(numtype(Itransmitted)!=0)
		Itransmitted = NumberByKey("Mean transmitted intensity (cps)",curKwList,"=",";")
	endif
	variable normfct=NumberByKey("Image normalization scale factor (norm/i0)",curKwList,"=",";")
	if(numtype(normfct)!=0)
		normfct = NumberByKey("Mean image normalization scale factor sum(norm/i0)/n",curKwList,"=",";")
	endif

	 target =(normfct* Itransmitted *cttime)
	
	//Now if the suer uses empty field, we can be bit smarter...
	NVAR useEmptyField = root:Packages:Convert2Dto1D:useEmptyField
	if(useEmptyField)
		SVAR CurrentEmptyName = root:Packages:Convert2Dto1D:CurrentEmptyName
		string FixedEMptyname= RemoveEnding(CurrentEmptyName, ".txt") [0,31] 
		SVAR/Z curEmptyKwList=$("root:DNDCAtLookupTables:"+FixedEMptyname)
		if(!SVAR_Exists(curEmptyKwList))
			Abort "Problem in NI1_DNDSampleTransmission routine, please contact auhtor of the code"
		endif
		variable IToverI0Empty = NumberByKey("Relative transmission it/i0",curEmptyKwList,"=",";")
		//To get tranmission...
		// Take the poorly named "Relative transmission it/io" value from the sample's file and divide it by the same value from the empty's file.
		variable target2 = IToverI0 / IToverI0Empty
		if(numtype(target2!=0))
			DoAlert 1, "Failure in NI1_DNDSampleTransmission routine. This is a bug. Please report"
		endif
		Print "*********     This is only for your information   ****************"
		Print "Calculated transmission for sample : "+FileNameStr+" using empty measurement : "+CurrentEmptyName
		Print "                The transmission value is  = "+num2str(target2)
		Print "Note, that the data have been already corrected for transmission and this value is not used in data reduction"
		Print "****************************************************"
		
	endif

//print "Sample Transmission = "+num2str(target)

	return target
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function NI1_DNDSampleMeasTime(FileNameStr)
	string FileNameStr
	string Fixedname= RemoveEnding(FileNameStr, ".txt") [0,31] 
	SVAR/Z curKwList=$("root:DNDCAtLookupTables:"+Fixedname)
	if(!SVAR_Exists(curKwList))
		Abort "Problem in NI1_DNDSampleMeasTime routine, please contact auhtor of the code"
	endif
	variable target= NumberByKey("Exposure time (s)",curKwList,"=",";")
	return target
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function NI1_DNDSampleCorrFnct(FileNameStr)
	string FileNameStr
	string Fixedname= RemoveEnding(FileNameStr, ".txt") [0,31] 
	SVAR/Z curKwList=$("root:DNDCAtLookupTables:"+Fixedname)
	if(!SVAR_Exists(curKwList))
		Abort "Problem in NI1_DNDSampleCorrFnct routine, please contact auhtor of the code"
	endif
	variable Version=NumberByKey("Version of chewlog used",curKwList,"=",";")
	variable CF
	if(Version>=1.10)
		CF= NumberByKey("Calibration factor",curKwList,"=",";")
	else
		CF= NumberByKey(" CF ",curKwList,"=",";")
	endif
	//9/3/09 changed to add the other parameters here, so transmission is more meaningful, even though it will need to be set to 1 for now...

	variable target = CF* 10		//his calibration assumes thickness in cm. Nika uses mm... 

//print "Sample Corr factor = "+num2str(target)
	
	return target
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function NI1_DNDSampleThickness(FileNameStr)
	string FileNameStr
	string Fixedname= RemoveEnding(FileNameStr, ".txt") [0,31] 
	SVAR/Z curKwList=$("root:DNDCAtLookupTables:"+Fixedname)
	if(!SVAR_Exists(curKwList))
		Abort "Problem in NI1_DNDSampleThickness routine, please contact auhtor of the code"
	endif
	variable target= NumberByKey(" samp_thick ",curKwList,"=",";") * 10

//print "Sample thickness = "+num2str(target)

	return target		//converted to mm
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function NI1_DNDSampleToDetDistance(FileNameStr)
	string FileNameStr
	string Fixedname= RemoveEnding(FileNameStr, ".txt") [0,31] 
	SVAR/Z curKwList=$("root:DNDCAtLookupTables:"+Fixedname)
	if(!SVAR_Exists(curKwList))
		Abort "Problem in NI1_DNDSampleToDetDistance routine, please contact auhtor of the code"
	endif
	variable target=NumberByKey("Sample to detector distance (mm)",curKwList,"=",";")
	return target
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function NI1_DNDPixelSize(FileNameStr)
	string FileNameStr
	string Fixedname= RemoveEnding(FileNameStr, ".txt") [0,31] 
	SVAR/Z curKwList=$("root:DNDCAtLookupTables:"+Fixedname)
	if(!SVAR_Exists(curKwList))
		Abort "Problem in NI1_DNDPixelSize routine, please contact auhtor of the code"
	endif
	variable target=NumberByKey("Pixel size (microns)",curKwList,"=",";")
	return target/1000			//convert to mm as needede by Nika
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function NI1_DNDWavelength(FileNameStr)
	string FileNameStr
	string Fixedname= RemoveEnding(FileNameStr, ".txt") [0,31] 
	SVAR/Z curKwList=$("root:DNDCAtLookupTables:"+Fixedname)
	if(!SVAR_Exists(curKwList))
		Abort "Problem in NI1_DNDWavelength routine, please contact auhtor of the code"
	endif
	variable target=NumberByKey("Wavelength (A)",curKwList,"=",";")
	return target
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function NI1_DNDBeamCenterX(FileNameStr)
	string FileNameStr
	string Fixedname= RemoveEnding(FileNameStr, ".txt") [0,31] 
	SVAR/Z curKwList=$("root:DNDCAtLookupTables:"+Fixedname)
	if(!SVAR_Exists(curKwList))
		Abort "Problem in NI1_DNDBeamCenterX routine, please contact auhtor of the code"
	endif
	variable beamCenterX=NumberByKey("X-coordinate location of direct beam (pix)",curKwList,"=",";")
	return beamCenterX
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function NI1_DNDBeamCenterY(FileNameStr)
	string FileNameStr
	string Fixedname= RemoveEnding(FileNameStr, ".txt") [0,31] 
	SVAR/Z curKwList=$("root:DNDCAtLookupTables:"+Fixedname)
	if(!SVAR_Exists(curKwList))
		Abort "Problem in NI1_DNDBeamCenterY routine, please contact auhtor of the code"
	endif
	variable beamCenterY=NumberByKey("Y-coordinate location of direct beam (pix)",curKwList,"=",";")
	return beamCenterY
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function/T NI1_ReadDNDHeader(RefNum)
	variable refNum
	//this function read line by line from the opened TXT file with DND CAT stuff....
	//and parses into usable Igor KW list
	string tempLine
	string KWListStr=""
	do
		FReadLine refNum, tempLine
		tempLine=ReplaceString("# ", tempLine, "")
		tempLine=ReplaceString("\t", tempLine, "=")
		tempLine=ReplaceString("\r", tempLine, "")
		KWListStr+=tempLine+";"
	
	while(!stringmatch(tempLine, "*2theta (degrees)*" ))

	return KWListStr
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function NI1_ParseDNDHeader(HeaderStr, FileNameToLoad)
	string HeaderStr, FileNameToLoad
	//whis creates, if necessary, strings in place where we can easier parse them for information...
	string OldDf=GetDataFolder(1)
	NewDataFolder/O/S root:DNDCAtLookupTables
		string Fixedname= RemoveEnding(FileNameToLoad, ".txt") [0,31] 
		SVAR/Z curKwList=$(Fixedname)
		if(SVAR_Exists(curKwList))
			print "Header record for file :   "+ Fixedname+"    already existed, it was ovewritten..."
		endif
		string/G $(Fixedname)
		SVAR curKWList=$(Fixedname)
		curKWList = HeaderStr
	setDataFolder OldDf
	return 0
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function/T NI1_FineDNDTifFile(TXTPathName,TXTFileName,HeaderStr)	
	string TXTPathName,TXTFileName,HeaderStr
	pathInfo $(TXTPathName)
	string CurrentPathString=S_path
	string DNDPath=StringByKey("2D image filename", HeaderStr , "=", ";")
	string TifFileName=StringFromList(ItemsInList(DNDPath,"/") - 1, DNDPath ,"/")
	if(stringMatch(StringFromList(0, DNDPath,"/"),"."))
		CurrentPathString = RemoveListItem(ItemsInList(CurrentPathString,":") - 1, CurrentPathString ,":")
		DNDPath = removeListItem(0,DNDPath,"/")
	endif
	DNDPath=RemoveListItem(ItemsInList(DNDPath,"/") - 1, DNDPath ,"/")
	DNDPath = ReplaceString("/", DNDPath, ":")
	CurrentPathString+=DNDPath
	//Found possible path to tif file
	//remove ending:
	TifFileName = RemoveListItem(1,TifFileName,".")+"tif"
	variable tempV
	NewPath/O/Z/Q tempPath, CurrentPathString
	if(V_Flag==0)		//path even exists
		open /R/Z/P=tempPath  tempV as TifFileName	//is the file there?
	endif
	variable openedFile=V_Flag		//if 0 both path and file exists there...	
	if(openedFile==0)	//file was opened, so change path to DNDDataPath and return file name
		close tempV
		NewPath/O/Q DNDDataPath, CurrentPathString
		return TifFileName
	else				//OK, path in teh header is wriong, test if Path alredy exists 
		pathInfo DNDDataPath
		if(V_Flag)		//path exists
			open /R/Z/P=DNDDataPath  tempV as TifFileName
			openedFile=V_Flag
			if(openedFile==0)	//path exists and points to the file
				close tempV
				return TifFileName
			endif
		endif	//path either does nto exist or does not point to the file
			open/R/D/T="????"/M=("Fine folder with file name :"+TifFileName) tempV as TifFileName
			openedFile=V_Flag
			if(openedFile==0)
				//close tempV
				 string PathStr = S_fileName
				PathStr=RemoveListItem(ItemsInList(PathStr,":") - 1, PathStr ,":")
				Newpath/O/Q DNDDataPath, PathStr
				return TifFileName
			else
				//somethign wrong happened here
				//close tempV
				Abort "Cannot find necessary tif file, aborting"
			endif
		
	endif
	//comment here.. .this may require more debugging. I suspect this will be failing, but somehow cannot test on mac. It seems to be too smart for its own good. 

end



//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

