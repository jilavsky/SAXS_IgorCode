#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method.
//#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.12		//dated 4/12/2019


//*************************************************************************\
//* Copyright (c) 2005 - 2021, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.12 2019 fixes, fixed bug when names starting with number needed quoting. Note: Not long file name compatible yet, limits names to 32 charatcers. 
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
	DoWIndow DND_Instructions
	if(V_Flag)
		DOWIndow/F DND_Instructions
		return 0
	endif
	NewNotebook/N=$nb/F=1/V=1/K=1/ENCG={1,1}/W=(431,214,1179,1072)
	Notebook $nb defaultTab=36, magnification=125
	Notebook $nb showRuler=1, rulerUnits=1, updating={1, 60}
	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	Notebook $nb newRuler=Title, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",12,3,(0,0,0)}
	Notebook $nb ruler=Title, text="Instructions for use of DND CAT special configuration\r"
	Notebook $nb ruler=Normal, text="\r"
	Notebook $nb fStyle=1, text="0. ", fStyle=-1, text="Open Nika's main panel, if needed. \r"
	Notebook $nb fStyle=1, text="1.", fStyle=-1, text=" Select \"DND/txt\" as image type. Check \"Display only\" as processing method so you do not get errors if mask/parameters are not correct. \r"
	Notebook $nb fStyle=1, text="2. ", fStyle=-1
	Notebook $nb text="Using \"Select data path\" load one txt file located in .../APSCycle/YourName/Month/processing/plot_files,"
	Notebook $nb text=" these are the ", fStyle=5, text="txt", fStyle=-1, text=" files you want to see in the file list. "
	Notebook $nb fStyle=4, text="Nika will find tiff files on its own", fStyle=-1, text=". \r"
	Notebook $nb text="       ", fStyle=2
	Notebook $nb text=" Note, you can load DND processed 1D ASCII data from these files directly into the Irena package using A"
	Notebook $nb text="SCII loader. Q is second column, Intensty is third and error is fourth. Nika is needed only if you want "
	Notebook $nb text="to reprocess the 2D->1D data again, for example if you need sector averages, different mask, etc. \r"
	Notebook $nb fStyle=1, text="3.", fStyle=-1
	Notebook $nb text=" Now, run the Configuration function again... Select in the \"SAS 2D\"->\"Instrument configurations\"--> \"DN"
	Notebook $nb text="D CAT\". Select name.txt file with the same name as tiff file you want to process. This will configure th"
	Notebook $nb text="e Nika properly (", fStyle=1, text="for that detector!!!, there are 3 detecotrs on DND SAXS", fStyle=-1
	Notebook $nb text="), including wavelength, distance, etc. Correct checkboxes will be checked and functions set to provide "
	Notebook $nb text="same data processing as DND suggests to do (see below). \r"
	Notebook $nb fStyle=1, text="4.", fStyle=-1, text=" Create mask. ", fStyle=5
	Notebook $nb text="You need to create it or load it if you have already created it.", fStyle=-1
	Notebook $nb text=" Make sure you use the correct image file to create it - with the three different image files associated"
	Notebook $nb text=" with each sample, it is bit complicated. Nika does not like when mask and image dimension do not match."
	Notebook $nb text=" \r"
	Notebook $nb fStyle=1, text="5.", fStyle=-1
	Notebook $nb text=" Set Nika processing & output options you want = set tabs \"Sect.\", \"LineProf\" and \"Save/Exp\". Set Proces"
	Notebook $nb text="sing options (checkboxes), likely you need \"Process sel. files individually\" \r"
	Notebook $nb fStyle=1, text="6. ", fStyle=-1
	Notebook $nb text="To reduce image, select the text file with the same name as the tiff file you want to process and \""
	Notebook $nb fStyle=1, text="Process image(s)", fStyle=-1
	Notebook $nb text="\". Nika will parse parameters (wavelength, calibration values, thickenmss,...) from this txt file, locat"
	Notebook $nb text="e the tiff file, load it, and process as described. If you do circular average, you shoudl get what the "
	Notebook $nb text="text file contains. It si good to check that you actually get the same output before using Nika to do di"
	Notebook $nb text="fferent types of processing (e.g., sectors). If something does not match, let me know... \r"
	Notebook $nb text="\r"
	Notebook $nb fStyle=3, text="Here is DND description which Nika is trying to reproduce:\r"
	Notebook $nb fStyle=-1
	Notebook $nb text="What I do with the TIFF image to re-produce columns 3 and 4 in the *.txt files in the plot_files directo"
	Notebook $nb text="ry.\r"
	Notebook $nb text="I = (I_raw - 10) * CF / (it - itd) / t \r"
	Notebook $nb text="where: \r"
	Notebook $nb text="I_raw = the radial averaged counts from the masked tif image in ADU as produced by GSAS \r"
	Notebook $nb text="10 = the number of ADU units which are added to the image by Rayonix software before saving to prevent n"
	Notebook $nb text="egative values due to read noise. \r"
	Notebook $nb text="CF = Calibration factor = the scale factor to get absolute intensities based on my glassy carbon standar"
	Notebook $nb text="d \r"
	Notebook $nb text="it = Transmitted detector intensity, measured intensity on the beam stop diode in pAsec\r"
	Notebook $nb text="itd = Transmitted detector dark, the beam stop diode dark current in pAsec \r"
	Notebook $nb text="t = Sample thickness, thickness of the sample as entered by the user in cm\r"
	Notebook $nb text="\r"
	Notebook $nb text="It CF has not yet been determined, then the column headings for columns 3 and 4 will be \"I_ite (relative"
	Notebook $nb text=" units)\" and \"sigma(I_ite)\"  if the intensity calibration has been determined (i.e. CF <> 1.0) then thes"
	Notebook $nb text="e columns with be named \"I (1/cm)\" and \"sigma(I)\"\r"
	Notebook $nb text="\r"
	Notebook $nb text="Also if anyone wants to use the incident detector intensity to estimate sample thickness (i.e. measure t"
	Notebook $nb text="he sample transmission) they need to realize that the two detectors are completely different (ion chambe"
	Notebook $nb text="r and photodiode) and on different linear scales.  Thus they need to first\r"
	Notebook $nb text="calculate the ratio of (ii - iid)/(it - itd) with no sample in the beam then they can multiply this rati"
	Notebook $nb text="o by (it - itd)/(ii -iid) for the sample frames to get the transmission of the sample.\r"
	Notebook $nb text="\r"
	Notebook $nb fStyle=1, text="NOTE: ", fStyle=-1, text="records from the text file for each sample were here: \r"
	Notebook $nb text="\troot:DNDCAtLookupTables:\r"
	Notebook $nb text="User can use these to extract more information and do more calculations. \r"
	Notebook $nb text="\r"
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
	NI1_DNDCreateHelpNbk()
	if(!DataFolderExists("root:DNDCAtLookupTables"))
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

	//and now configure items:
	NVAR Dist=root:Packages:Convert2Dto1D:SampleToCCDDistance
	Dist=NI1_DNDSampleToDetDistance(Selectedheader)
	
	NVAR wvlng=root:Packages:Convert2Dto1D:Wavelength
	wvlng=NI1_DNDWavelength(Selectedheader)
	NVAR XrayEnergy = root:Packages:Convert2Dto1D:XrayEnergy
	XrayEnergy = 12.3984/wvlng
	NVAR PixX=root:Packages:Convert2Dto1D:PixelSizeX
	pixX=NI1_DNDPixelSize(Selectedheader)
	NVAR pixY=root:Packages:Convert2Dto1D:PixelSizeY
	pixY=NI1_DNDPixelSize(Selectedheader)
	
	NVAR BmX=root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BMY=root:Packages:Convert2Dto1D:BeamCenterY
	Wave Img=root:Packages:Convert2Dto1D:CCDImageToConvert
	//BmX=DimSize(Img, 0)-  NI1_DNDBeamCenterX(Selectedheader)
	BmX= NI1_DNDBeamCenterX(Selectedheader)
	//BMY=DimSize(Img, 1) - 1 - NI1_DNDBeamCenterY(Selectedheader)			//fixed -1 JIL 10 14 09 since I again forgot about 0 numbering... 
	BMY= NI1_DNDBeamCenterY(Selectedheader)			//changed, now in regular units?... 
	
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
	
	NVAR UseSubtractFixedOffset = root:Packages:Convert2Dto1D:UseSubtractFixedOffset
	NVAR SubtractFixedOffset = root:Packages:Convert2Dto1D:SubtractFixedOffset
	UseSubtractFixedOffset = 1
	SubtractFixedOffset = 10

	NVAR UseMonitorForEF=root:Packages:Convert2Dto1D:UseMonitorForEF
	SampleI0=1
	UseMonitorForEF=0
	UseSampleMonitorFnct=0
	UseEmptyMonitorFnct=0
	//EmptyMonitorFnct="NI1_DNDEmptyCorrection"

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
		//if(numtype(ctTime)!=0)
		//	ctTime = NumberByKey("Mean exposure time (s)",curKwList,"=",";")
		//endif
		variable I0 = NumberByKey("Incident detector intensity (pAs)",curKwList,"=",";")
		//if(numtype(I0)!=0)
		//	I0 = NumberByKey("Mean incident intensity (cps)",curKwList,"=",";")
		//endif
		//variable NormI0 = NumberByKey("Original normalization number (cps)",curKwList,"=",";")
		variable Itransmitted=NumberByKey("Transmitted detector intensity (pAs)",curKwList,"=",";")
		//if(numtype(Itransmitted)!=0)
		//	Itransmitted = NumberByKey("Mean transmitted intensity (cps)",curKwList,"=",";")
		//endif
		variable normfct=NumberByKey("Image normalization scale factor (norm/i0)",curKwList,"=",";")
		//if(numtype(normfct)!=0)
		//	normfct = NumberByKey("Mean image normalization scale factor sum(norm/i0)/n",curKwList,"=",";")
		//endif
		normfct =1
		
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
	//this thing calculate it-itd in DND formula:
//		I = (I_raw - 10) * CF / (it - itd) / t 
//	
//	where: 
//	I_raw = the radial averaged counts from the masked tif image in ADU as produced by GSAS 
//	10 = the number of ADU units which are added to the image by Rayonix
//	software before saving to prevent negative values due to read noise. 
//	CF = Calibration factor = the scale factor to get absolute intensities
//	based on my glassy carbon standard 
//	it = Transmitted detector intensity = is the measured intensity on the beam stop diode in picoamp * seconds
//# Transmitted detector intensity (pAs)	1091995.00000
//# Image AcquireTime (s)	0.90200
//# Exposure Time (s)	0.90000
//	itd = Transmitted detector dark = the beam stop diode dark current in	picoamp * seconds 
// # Transmitted detector dark (pAs)	212.40000

//	t = Sample thickness =  is the thickness of my glassy
//	carbon standard (or the sample if entered by the user) in cm

	variable target
	variable itpA = NumberByKey("Transmitted detector intensity (pAs)",curKwList,"=",";")
	//variable ctTime = NumberByKey("Exposure Time (s)",curKwList,"=",";")
	variable itdpA = NumberByKey("Transmitted detector dark (pAs)",curKwList,"=",";")
	
	target =(itpA - itdpA)

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
	//variable Version=NumberByKey("Version of chewlog used",curKwList,"=",";")
	variable CF
	//if(Version>=1.10)
	CF= NumberByKey("Calibration factor",curKwList,"=",";")
	//else
	//	CF= NumberByKey(" CF ",curKwList,"=",";")
	//endif
	variable target = CF		//this calibration assumes thickness in cm. Nika uses mm... 
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
	variable target= NumberByKey("Sample thickness (cm)",curKwList,"=",";") * 10

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
	Fixedname = PossiblyQuoteName(Fixedname)
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
	Fixedname = PossiblyQuoteName(Fixedname)
	SVAR/Z curKwList=$("root:DNDCAtLookupTables:"+Fixedname)
	if(!SVAR_Exists(curKwList))
		Abort "Problem in NI1_DNDPixelSize routine, please contact auhtor of the code"
	endif
	variable target=NumberByKey("X pixel size (mm)",curKwList,"=",";")
	return target			//convert to mm as needede by Nika
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
	Fixedname = PossiblyQuoteName(Fixedname)
	SVAR/Z curKwList=$("root:DNDCAtLookupTables:"+Fixedname)
	if(!SVAR_Exists(curKwList))
		Abort "Problem in NI1_DNDWavelength routine, please contact auhtor of the code"
	endif
	variable target=NumberByKey("Wavelength (Angstrom)",curKwList,"=",";")
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
	Fixedname = PossiblyQuoteName(Fixedname)
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
	Fixedname = PossiblyQuoteName(Fixedname)
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


Function/T NI1_FindDNDTifFile(TXTPathName,TXTFileName,HeaderStr)	
	string TXTPathName,TXTFileName,HeaderStr
	pathInfo $(TXTPathName)
	string CurrentPathString=S_path
	//print CurrentPathString
	string ThisFileNameDND = ReplaceString("/",StringByKey("Filename", HeaderStr , "=", ";"),":")
	//print ThisFileNameDND
	string DNDPath=ReplaceString("/",StringByKey("Image filename", HeaderStr , "=", ";"),":")
	//print DNDPath
	string TifFileName=StringFromList(ItemsInList(DNDPath,":") - 1, DNDPath ,":")
	//print 	TifFileName
	//strip the file name from the DND path
	DNDPath = removeListItem(ItemsInList(DNDPath,":") - 1, DNDPath , ":")
	//print DNDPath
	//find "working folder" DND is using
	string tmpFldrsToRemove = removeListItem( ItemsInList(ThisFileNameDND,":") - 1, ThisFileNameDND , ":")
	//print tmpFldrsToRemove
	CurrentPathString = RemoveFromList(tmpFldrsToRemove, CurrentPathString , ":")
	//print CurrentPathString
	//this is the working directory of DND system... 
	string StartOfFilePath=StringFromList(0,DNDPath,":")
	if(stringMatch(StartOfFilePath,".."))		//we need to go up and remove the .. from name... 
		DNDPath = removeListItem(0, DNDPath, ":")
		CurrentPathString = removeListItem(ItemsInList(CurrentPathString,":") - 1, CurrentPathString , ":")
		//print CurrentPathString	
	endif

		//abort
		//	if(stringMatch(StringFromList(0, DNDPath,"/"),"."))
		//		CurrentPathString = RemoveListItem(ItemsInList(CurrentPathString,":") - 1, CurrentPathString ,":")
		//		DNDPath = removeListItem(0,DNDPath,"/")
		//	endif
		//	DNDPath=RemoveListItem(ItemsInList(DNDPath,"/") - 1, DNDPath ,"/")
		//	DNDPath = ReplaceString("/", DNDPath, ":")
			//Make the path to tiff files
	
	CurrentPathString+=DNDPath
	//print CurrentPathString	
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

