#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method.
#pragma version=2.61

//*************************************************************************\
//* Copyright (c) 2005 - 2023, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.61 3/24/2024 Added to Dectris detectors Eiger2_500k - 16M. Tested only on 16M, do not have other images for testing. 
//2.60 fix hdf5 plain file import, 2022-11-06, to handle 1st 2-3D data set in the file, difficult to support more flexible method. 
//2.59 add ability to flip/rotate image after load to let users tweak image orientation. 
//2.58 fix Eiger detector dimensions (lines ~800-850) - looks like dimensions of images were wrong and therefroe images did not look right. This related to tiff and cbf images, found on cbf images from user. 
//2.57 fix reading of edf header. Works now for Xenocs Pilatus 300k header. Singificant changes due to changing line breaks characters. 
//2.56 add Eiger detector support, tested on 16M background image. 
//2.55 fix edf file Xenocs loading, they changed \r\n into \n only and that broke parsing header... 
//2.54 Remove for MatrixOP /NTHR=0 since it is applicable to 3D matrices only 
//2.53 added FLOAT as Pilatus EDF file format option. Seems like we now have float values in there. 
//2.52 added 12ID-B tiff files, these are tiff files with associated metadata file. Location based on folder structure. 
//2.51 added passing through NXMetadata, NXSample, NXInstrument, NXUser
//2.50 removed mar345 support. Let's see if someone complains. 
//2.49 Modified NI1_MainListBoxProc to allow to easily remove "Blank" and Empty - and unmatch them... 
//2.48 added ALS RXoXS instrument support.
//2.47 removed DoubleClickConverts, not needed anymore. 
//2.46 improve print message fro Nexus when multi dimensional input ddata are used. 
//2.45 more fixes for Pilatus TVX ver 1.3 tiff header. Still mess... 
//2.44 moved to new Nexus suport provided by HDF5Gateway and IRNI_NexusSupport
//2.43 fixes for Pilatus Tiff file header 
//2.42 Added more or less universal FITS file loader (checked against data in Extension1 and 2), removed printing of wave note in history area. 
//2.41 Updated Pilatus img file to handle header (example contained 4096 bytes header) - added code which will find header length and skip it. 
//2.40 update to 9ID pinSAXS Nexus files
//2.39 removed Executes in preparation for Igor 7
//2.38 fixe3d bug in reading calibrated 2D data found by Igor 7 beta. 
//2.37 Created ADSC_A file type which has wavelength in A, not in nm as ADSC has. 
//2.36 modified PilatusHookFunction and added ImportedImageHookFunction function called after any image is loaded so users can modify the images after load. 
//2.35 adds Pilatus Cbf compressed files (finally solved the problem)... 
//2.34 adds ability to read 2D calibrated data format from NIST - NIST-DAT-128x128 pixels. For now there is also Qz, not sure what to do about it. 
//2.33 can read and write calibrated canSAS/nexus files. Can write new files or append to existing one (2D data for now). 
//   can revert log-q binning of 2D data. 
//2.32 Added right click "Refresh content" to Listboxes inmain panel as well as some othe rfunctionality
//2.31 fixed /NTHR=1 to /NTHR=0
//2.30 adds EQSANS calibrated data
//2.29 added Pilatus 3 200k (with dimensions 487,407) 
//2.28 attempted to add Pilatus cbf format, code is half way through but the example makes no sense and does not work... abandon until proper image is avbaialbel.  
//2.27 added double clicks to Empty and Dark Listboxes as well as maskListbox on main panel
//2.26 modified and tested various version of mpa formats. Found internal switch and combined all mpa formats into one. Should work until somone has another format. 
//2.25 added marCCD (mccd) file format - it is basically tiff file with header, which is not containing much useful information as far as I can figure out... 
//2.24 modified to compile even when xml xop is not available. 
//2.23 fixed bug on ESRF edf data format for Pilatus, where I assume 1024 bytes header, but it is actually n*512bytes with separator. Modified code to handle those. 
//2.22 fixes bug for Pilatus 300K and adds Pilatus 6M (untested)
//2.21 adds TPA XML based file loader
//2.20 double click on file name now displays the file.
//2.19 minor fix for too long names in Nexus file loaders. Users use abstracts for names... 
//2.18 fixed BSL file loader which was getting the detector dimensions wrong.  
//2.17 adds SSRLMatSAXS
//2.16 cleaned up the Nexus folder before loadin g new Nexus file, this place was getting dirty and files were growing really large. 
//2.15 modified for 9IDCSAXS nexus (big SAXS)
//2.14 added 128x128 ASCII file format for KWS2 SANS data
//2.13 set point 1023,1023 of mpa/bin to 0. Seems we have a problem here. This is not the right solution, but works for now. 
//2.12 try to catch failed loads... return 1 if load succeeded, 0 if not. Update upstrea to deal with the report...
//2.11 adds Pilatus 300k and 300k-w
//2.10 adds GE detector for 1ID loader
//2.09 adds Nexus file loader to support 15ID SAXS beamline, all aux data for now are in wave note and not used. Need to finish
//        fixed Pilatus loader bugs, start working on HDF5 loader, but this is mess for now... Need test data
//2.08 adds BSL changes per JOSH requests
//2.07 adds unfinished hdf file loader. Needs to be finished, but realistically, this will require much mre coding since we need to call browser to figrue out what users wants to read!
//2.06 added mutlithread and MatrixOp/NTHR=1 where seemed possible to use multile cores
//2.05 added license for ANL
//2.0 updated for Nika 1.42
//2.01 updated ADSCS reader per request from PReichert@lbl.gov on 11/25/09
//2.02 added Pilatus reader per request from PReichert@lbl.com on 1/1/2010
//2.03 added ESRFedf   2/1/2010
//2.04 adds mpa/UC (University of Cincinnati) type 3/24/2010
//2.05 add FITS file acording to X Mike's specs, 10/26/2010


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_UniversalLoader(PathName,FileName,FileType,NewWaveName)
	string PathName,FileName,FileType,NewWaveName
	
	string OldDf=GetDataFOlder(1)
	setDataFOlder root:Packages:Convert2Dto1D
	
	PathInfo $(PathName)
	if(!V_Flag)
		Abort "Path to data set incorrectly" 
	endif
	if(stringmatch(FileName,"*--none--*")||stringmatch(Filetype,"---"))
		Abort 
	endif
	string FileNameToLoad
	string NewNote=""
	string testLine
	variable RefNum, NumBytes, len, lineNumber
	variable Offset, dist00
	string headerStr=""
	variable i
	Variable LoadedOK=1			//set to 1 if loaded seemed OK
	NVAR UseCalib2DData=root:Packages:Convert2Dto1D:UseCalib2DData

	if(stringmatch(FileType,".tif") || stringmatch(FileType,"tiff") || stringmatch(FileType,"12IDB_tif"))
		FileNameToLoad= FileName
		if(cmpstr(FileName[strlen(FileName)-4,inf],".tif")!=0&&cmpstr(FileName[strlen(FileName)-5,inf],".tiff")!=0)
			FileNameToLoad= FileName+ ".tif"
		endif
		ImageLoad/P=$(PathName)/T=tiff/Q/O/N=$(NewWaveName) FileNameToLoad
		if(V_flag==0)		//return 0 if not succesuful.
			return 0
		endif
		wave LoadedWvHere=$(NewWaveName)
		Redimension/N=(-1,-1,0) 	LoadedWvHere			//this is fix for 3 layer tiff files...
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+".tif"+";"
		if(stringmatch(FileType,"12IDB_tif"))
			string AddOnNOte
			AddOnNOte = NI1_12IDBLoadMetadata(FileNameToLoad, LoadedWvHere)
			NewNote+=AddOnNOte+";"
		endif		

	elseif(cmpstr(FileType,"EQSANS400x400")==0)
		FileNameToLoad= FileName
		KillWaves/Z wave0,wave1,wave2,wave3,wave4
		LoadWave/Q/A/D/G/P=$(PathName)  FileNameToLoad
		Wave wave0
		Wave wave1
		Wave wave2
		wave wave3
		Duplicate/O wave0, Qx2D
		Duplicate/O wave1, Qy2D
		Duplicate/O wave2, Int2D
		Duplicate/O wave3, Err2D
		KillWaves/Z wave0,wave1,wave2,wave3,wave4
		redimension/N=(400,400) Qx2D, Qy2D, Int2D, Err2D
		ImageRotate/O/H Int2D
		ImageRotate/O/C Int2D
		Duplicate/O Int2D, $(NewWaveName)
		if(stringmatch(NewWaveName, "CCDImageToConvert"))
			//create Angles wave
			matrixOp/O AnglesWave = atan(Qy2D/Qx2D)
			AnglesWave += pi/2
			AnglesWave = Qx2D > 0 ? AnglesWave : AnglesWave+pi
			//create Q waves
			matrixOP/O Qx2D = powR(Qx2D,2)
			matrixOP/O Qy2D = powR(Qy2D,2)
			matrixOp/O Q2DWave = sqrt(Qx2D + Qy2D)
			//fix their data orientation...
			ImageRotate/O/H AnglesWave
			ImageRotate/O/H Q2DWave
			ImageRotate/O/H Err2D
			ImageRotate/O/C AnglesWave
			ImageRotate/O/C Q2DWave
			ImageRotate/O/C Err2D
			//get beam center, needed basically only for the drawings. 
			Wavestats/Q Q2DWave
			NVAR BeamCenterX = root:Packages:Convert2Dto1D:BeamCenterX
			NVAR BeamCenterY = root:Packages:Convert2Dto1D:BeamCenterY
			BeamCenterX = V_minRowLoc
	 		BeamCenterY = V_minColLoc
	 		//OK, now we need to fake at least SDD to make sure some drawings work well...
	 		NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance		//in millimeters
			NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength							//in A
			NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX								//in millimeters
			NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY								//in millimeters
			Wavelength = 2			//set to 2A, makes no sense for TOF instrument, but need to have something...
			Duplicate/O Q2DWave, Theta2DWave
			Multithread Theta2DWave = asin(Q2DWave / (4*pi/Wavelength))
			//Multithread Q2DWave = ((4*pi)/Wavelength)*sin(Theta2DWave)
			//Multithread Theta2DWave = atan(Theta2DWave/SampleToCCDDistance)/2
			//Multithread Theta2DWave = sqrt(((p-BeamCenterX)*PixelSizeX)^2 + ((q-BeamCenterY)*PixelSizeY)^2)
			//the distance of point 0,0 in mm is:
			dist00 = sqrt((BeamCenterX*PixelSizeX)^2 + (BeamCenterY*PixelSizeY)^2)
			//Theta2DWave[0][0] = atan(dist00/SampleToCCDDistance)/2
			//2*tan(Theta2DWave[0][0]) = dist00/SampleToCCDDistance
			SampleToCCDDistance = abs(dist00/(2*tan(Theta2DWave[0][0])))
			Duplicate/O Err2D, CCDImageToConvert_Errs
		endif
		Killwaves/Z Int2D, Qx2D, Qy2D, Err2D
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"EQSANS400x400"+";"
	elseif(cmpstr(FileType,"NIST_DAT_128x128")==0)
		FileNameToLoad= FileName
		KillWaves/Z wave0,wave1,wave2,wave3,wave4, wave5, wave6, wave7
		LoadWave/Q/A/D/G/P=$(PathName)  FileNameToLoad
		Wave wave0		//qx
		Wave wave1		//qy
		Wave wave2		//I(Qx,qy)
		wave wave3		//dI
		wave wave4		//Qz
		wave wave5		//SigmaQ_parallel???
		wave wave6		//SigmaQPerp
		wave wave7		//fsubS (beamstop shadow)
		Duplicate/O wave0, Qx2D
		Duplicate/O wave1, Qy2D
		Duplicate/O wave2, Int2D
		Duplicate/O wave3, Err2D
		KillWaves/Z wave0,wave1,wave2,wave3,wave4, wave5, wave6, wave7
		redimension/N=(128,128) Qx2D, Qy2D, Int2D, Err2D
		ImageRotate/O/H Int2D
		ImageRotate/O/C Int2D
		Duplicate/O Int2D, $(NewWaveName)
		if(stringmatch(NewWaveName, "CCDImageToConvert"))
			//create Angles wave
			matrixOp/O AnglesWave = atan(Qy2D/Qx2D)
			AnglesWave += pi/2
			AnglesWave = Qx2D > 0 ? AnglesWave : AnglesWave+pi
			//create Q waves
			matrixOP/O Qx2D = powR(Qx2D,2)
			matrixOP/O Qy2D = powR(Qy2D,2)
			matrixOp/O Q2DWave = sqrt(Qx2D + Qy2D)
			//fix their data orientation...
			ImageRotate/O/H AnglesWave
			ImageRotate/O/H Q2DWave
			ImageRotate/O/H Err2D
			ImageRotate/O/C AnglesWave
			ImageRotate/O/C Q2DWave
			ImageRotate/O/C Err2D
			//get beam center, needed basically only for the drawings. 
			Wavestats/Q Q2DWave
			NVAR BeamCenterX = root:Packages:Convert2Dto1D:BeamCenterX
			NVAR BeamCenterY = root:Packages:Convert2Dto1D:BeamCenterY
			BeamCenterX = V_minRowLoc
	 		BeamCenterY = V_minColLoc
	 		//OK, now we need to fake at least SDD to make sure some drawings work well...
	 		NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance		//in millimeters
			NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength							//in A
			NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX								//in millimeters
			NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY								//in millimeters
			Wavelength = 2			//set to 2A, makes no sense for TOF instrument, but need to have something...
			Duplicate/O Q2DWave, Theta2DWave
			Multithread Theta2DWave = asin(Q2DWave / (4*pi/Wavelength))
			//Multithread Q2DWave = ((4*pi)/Wavelength)*sin(Theta2DWave)
			//Multithread Theta2DWave = atan(Theta2DWave/SampleToCCDDistance)/2
			//Multithread Theta2DWave = sqrt(((p-BeamCenterX)*PixelSizeX)^2 + ((q-BeamCenterY)*PixelSizeY)^2)
			//the distance of point 0,0 in mm is:
			dist00 = sqrt((BeamCenterX*PixelSizeX)^2 + (BeamCenterY*PixelSizeY)^2)
			//Theta2DWave[0][0] = atan(dist00/SampleToCCDDistance)/2
			//2*tan(Theta2DWave[0][0]) = dist00/SampleToCCDDistance
			SampleToCCDDistance = abs(dist00/(2*tan(Theta2DWave[0][0])))
			Duplicate/O Err2D, CCDImageToConvert_Errs
		endif
		Killwaves/Z Int2D, Qx2D, Qy2D, Err2D
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"NIST_DAT_128x128"+";"
	elseif(cmpstr(FileType,"MarCCD")==0)
		FileNameToLoad= FileName
		ImageLoad/P=$(PathName)/T=tiff/O/N=$(NewWaveName) FileNameToLoad
		if(V_flag==0)		//return 0 if not succesuful.
			return 0
		endif
		wave LoadedWvHere=$(NewWaveName)
		Redimension/N=(-1,-1,0) 	LoadedWvHere			//this is fix for 3 layer tiff files...
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+".tif"+";"
	elseif(cmpstr(FileType,"SSRLMatSAXS")==0)
		FileNameToLoad= FileName
		if(cmpstr(FileName[strlen(FileName)-4,inf],".tif")!=0)
			FileNameToLoad= FileName+ ".tif"
		endif
		ImageLoad/P=$(PathName)/T=tiff/O/N=$(NewWaveName) FileNameToLoad
		if(V_flag==0)		//return 0 if not succesuful.
			return 0
		endif
		wave LoadedWvHere=$(NewWaveName)
		Redimension/N=(-1,-1,0) LoadedWvHere			//this is fix for 3 layer tiff files...
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"SSRLMatSAXS"+";"
		//now add the txt file...  
		FileNameToLoad = ReplaceString(".tif", FileNameToLoad, ".txt")
		open /Z/R/P=$(PathName) RefNum as FileNameToLoad
		if(V_Flag)
			DoALert 0, "Associated txt file not availabel, this is not SSRL Mat SAXS file format"
		else		//file opened
			do
				FReadLine RefNum, testLine
				lineNumber = 0
				len = strlen(testLine)
				if (len == 0)
					break						// No more lines to be read
				endif
				headerStr+=testLine
				lineNumber += 1
			while (lineNumber<50)
			close RefNum
			headerStr = ReplaceString("# General info", headerStr, "General_info:")
			headerStr = ReplaceString("# Temperature", headerStr, "Temperature:")
			headerStr = ReplaceString("# Counters", headerStr, "Counters:")
			headerStr = ReplaceString("# Motors", headerStr, "Motors:")
			headerStr = ReplaceString("\r\r", headerStr, "\r")
			headerStr = ReplaceString("\r", headerStr, ";")
			headerStr = ReplaceString(" ", headerStr, "")
			headerStr = ReplaceString(",", headerStr, ";")
			headerStr = ReplaceString(";;", headerStr, ";")
			print "Loaded header from associated txt file and stored to wave note:    " + headerStr
			NewNote+=headerStr
		endif
	elseif(cmpstr(FileType,"TPA/XML")==0)
#if	Exists("XMLopenfile")
		FileNameToLoad= FileName
		if(cmpstr(FileName[strlen(FileName)-4,inf],".xml")!=0)
			FileNameToLoad= FileName+ ".xml"
		endif
		string tempPthStr
		PathInfo $(PathName)
		RefNum=XMLopenfile (S_Path+FileNameToLoad)
		XMLelemlist(refnum)
		Wave/T W_ElementList
		string FrameInfo=W_ElementList[2][2]
		string ExpInfo=W_ElementList[1][2]
//		print FrameInfo
//		print ExpInfo
		variable NumpntsXxml, NumpntsYxml
		NumpntsXxml = NumberByKey("x", FrameInfo , ":"  , ";")
		NumpntsYxml = NumberByKey("y", FrameInfo , ":"  , ";")
//		//xmldocdump(refnum)
//		//data = XMLstrFmXpath(refnum,"//Acquisition/Frame/Data","","")
		XMLwaveFmXpath(refnum,"//Acquisition/Frame/Data","",";")
		XMLclosefile(refnum, 0)
		wave/T M_xmlcontent
		make/O/N=(numpnts(M_xmlcontent)) $(NewWaveName)
		Wave Data2D= $(NewWaveName)
		MultiThread Data2D = str2num(M_xmlcontent[p])
		KillWaves/Z M_xmlcontent
		redimension/N=(NumpntsXxml,NumpntsYxml) Data2D
		//note Data2D, ExpInfo+FrameInfo
		//print ExpInfo
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"TPA/XML"+";"
		//FrameInfo = ReplaceString(";", FrameInfo, "_")
		//ExpInfo = ReplaceString(";", ExpInfo, "_")
		NewNote += NI2_DictconvertKeySep(ExpInfo, ":", "=", ";")+";"
		NewNote += NI2_DictconvertKeySep(FrameInfo, ":", "=", ";")+";"
		NewNote = ReplaceString("\r", NewNote, "")
		NewNote = ReplaceString("\n", NewNote, "")
		NewNote = ReplaceString("2%", NewNote, " ")
		NI2_CreateWvNoteNbk(NewNote)
#else
	DoAlert 0, "XML xop is not installed, this feature is not available. Please install xops using latest Universal Installer.pxp or Java installer or install manually."
#endif
	elseif(cmpstr(FileType,".hdf")==0)
#if(exists("HDF5OpenFile")==4)
		FileNameToLoad= FileName
		pathInfo $(PathName)
		string FullFileName=S_Path+FileName
		string loadedWave=NI2_LoadGeneralHDFFile("Nika", FileName, PathName, NewWaveName)
		wave/Z LoadedWvHere=$(loadedWave)
		if(!WaveExists(LoadedWvHere))
			return 0
		endif
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+".hdf"+";"
#else
		DoALert 0, "Hdf5 xop not installed, please, run installed version 1.10 and higher and install xops"
#endif 
	elseif(cmpstr(FileType,"ESRFedf")==0)	//******************  ESRF edf 
			FileNameToLoad= FileName
			open /R/P=$(PathName) RefNum as FileNameToLoad
			testLine=""
			testLine=PadString (testLine, 40000, 0x20)
			FBinRead RefNum, testLine
			variable headerLength=(strsearch(testLine, "}", 0))
			headerLength = ceil(headerLength/512 ) * 512
			close RefNum
			//read the header and store in string
			open /R/P=$(PathName) RefNum as FileNameToLoad
			headerStr=PadString (headerStr, headerLength, 0x20)
			FBinRead RefNum, headerStr
			close RefNum
			headerStr=ReplaceString("\r", headerStr, "")
			headerStr=ReplaceString("\n", headerStr, "")
			headerStr=ReplaceString(" ;", headerStr, ";")
			headerStr=ReplaceString(" = ", headerStr, "=")
			headerStr=ReplaceString("{", headerStr, "")
			headerStr=ReplaceString("}", headerStr, "")
			headerStr=ReplaceString("    ", headerStr, "")
			
		//	print headerStr			
			variable NumPntsX=NumberByKey("Dim_1", headerStr  , "=" , ";")
			variable NumPntsY=NumberByKey("Dim_2", headerStr  , "=" , ";")
			string ESRF_ByteOrder=StringByKey("ByteOrder", headerStr  , "=" , ";")
			string ESRF_DataType=StringByKey("DataType", headerStr  , "=" , ";")
			variable ESRFDataType
			//Double Float;Single Float;32 bit signed integer;16 bit signed integer;8 bit signed integer;32 bit unsigned integer;16 bit unsigned integer;8 bit unsigned integer
			if(cmpstr(ESRF_DataType,"Double Float")==0)
				ESRFDataType=4
			elseif(cmpstr(ESRF_DataType,"FloatValue")==0)		//this one is tested, others NOT
				ESRFDataType=2
			elseif(cmpstr(ESRF_DataType,"32 bit signed integer")==0)
				ESRFDataType=32
			elseif(cmpstr(ESRF_DataType,"16 bit signed integer")==0)
				ESRFDataType=16
			elseif(cmpstr(ESRF_DataType,"8 bit signed integer")==0)
				ESRFDataType=8
			elseif(cmpstr(ESRF_DataType,"32 bit unsigned integer")==0)
				ESRFDataType=32+64
			elseif(cmpstr(ESRF_DataType,"16 bit unsigned integer")==0)
				ESRFDataType=16+64
			elseif(cmpstr(ESRF_DataType,"8 bit unsigned integer")==0)
				ESRFDataType=8+64
			endif
			variable ESRFFLoatType =1
			variable ESRFByteOrderV
			if(cmpstr(ESRF_ByteOrder,"LowByteFirst")==0)
				ESRFByteOrderV=1
			else
				ESRFByteOrderV=0
			endif
			
			if(ESRFDataType<5)	//float numbers
				GBLoadWave/Q/B=(ESRFByteOrderV)/T={ESRFDataType,4}/J=(ESRFFLoatType)/S=(headerLength)/W=1/P=$(PathName)/N=Loadedwave FileNameToLoad
			else
				GBLoadWave/Q/B=(ESRFByteOrderV)/T={ESRFDataType,4}/S=(headerLength)/W=1/P=$(PathName)/N=Loadedwave FileNameToLoad
			endif
			if(V_flag==0)		//check if we loaded at least some data...
				return 0
			endif
		wave Loadedwave0
		Redimension/N=(NumPntsX,NumPntsY) Loadedwave0
		duplicate/O Loadedwave0, $(NewWaveName)
		killwaves Loadedwave0
		//read header...
		NVAR ESRFEdf_ExposureTime=root:Packages:Convert2Dto1D:ESRFEdf_ExposureTime
		NVAR ESRFEdf_Center_1=root:Packages:Convert2Dto1D:ESRFEdf_Center_1
		NVAR ESRFEdf_Center_2=root:Packages:Convert2Dto1D:ESRFEdf_Center_2
		NVAR ESRFEdf_PSize_1=root:Packages:Convert2Dto1D:ESRFEdf_PSize_1
		NVAR ESRFEdf_PSize_2=root:Packages:Convert2Dto1D:ESRFEdf_PSize_2
		NVAR ESRFEdf_SampleDistance=root:Packages:Convert2Dto1D:ESRFEdf_SampleDistance
		NVAR ESRFEdf_SampleThickness=root:Packages:Convert2Dto1D:ESRFEdf_SampleThickness
		NVAR ESRFEdf_WaveLength=root:Packages:Convert2Dto1D:ESRFEdf_WaveLength
		NVAR ESRFEdf_Title=root:Packages:Convert2Dto1D:ESRFEdf_Title
		NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
		NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY
		NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
		NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
		NVAR SampleThickness=root:Packages:Convert2Dto1D:SampleThickness
		NVAR SampleI0=root:Packages:Convert2Dto1D:SampleI0
		NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance
		NVAR Wavelength=root:Packages:Convert2Dto1D:Wavelength
		NVAR XrayEnergy=root:Packages:Convert2Dto1D:XrayEnergy
		NVAR SampleMeasurementTime=root:Packages:Convert2Dto1D:SampleMeasurementTime
		testLine = ReplaceString("\r\n", testLine, "")
		testLine = ReplaceString("\n", testLine, "")
		testLine = ReplaceString("\t", testLine, "")
		testLine = ReplaceString("\r", testLine, "")
		testLine =  ReplaceString(" ", testLine, "")
		if(ESRFEdf_ExposureTime)
			//print StringByKey("\r\nExposureTime", testLine , " = ",";")
			//print StringFromList(1,StringByKey("\r\nExposureTime", testLine , " = ",";")," ")
			//SampleMeasurementTime=str2num(StringFromList(1,StringByKey("ExposureTime", testLine , "=",";")," "))
			SampleMeasurementTime=NumberByKey("ExposureTime", testLine , "=",";")
		endif
		if(ESRFEdf_Center_1)
			//BeamCenterX=str2num(StringFromList(1,StringByKey("Center_1", testLine , "=",";")," "))
			BeamCenterX=NumberByKey("Center_1", testLine , "=",";")
		endif
		if(ESRFEdf_Center_2)
			//eamCenterY=str2num(StringFromList(1,StringByKey("Center_2", testLine , "=",";")," "))
			BeamCenterY=NumberByKey("Center_2", testLine , "=",";")
		endif
		if(ESRFEdf_PSize_1)
			//PixelSizeX=str2num(StringFromList(1,StringByKey("PSize_1", testLine , "=",";")," "))*1e3	//convert to mm
			PixelSizeX=NumberByKey("PSize_1", testLine , "=",";")*1e3	//convert to mm
		endif
		if(ESRFEdf_PSize_2)
			//PixelSizeY=str2num(StringFromList(1,StringByKey("PSize_2", testLine , "=",";")," "))*1e3	//convert to mm
			PixelSizeY=NumberByKey("PSize_2", testLine , "=",";")*1e3	//convert to mm
		endif
		if(ESRFEdf_SampleDistance)
			//SampleToCCDDistance=str2num(StringFromList(1,StringByKey("SampleDistance", testLine , "=",";")," "))*1e3	//convert to mm
			SampleToCCDDistance=NumberByKey("SampleDistance", testLine , "=",";")*1e3	//convert to mm
		endif
		if(ESRFEdf_SampleThickness)
			//SampleThickness=str2num(StringFromList(1,StringByKey("SampleThickness", testLine , "=",";")," "))	//is in mm
			SampleThickness=NumberByKey("Thickness", testLine , "=",";")	//is in mm
			if(numtype(SampleThickness)!=0)
				SampleThickness=NumberByKey("SampleThickness", testLine , "=",";")	//is in mm
			endif 
		endif
		if(ESRFEdf_WaveLength)
			//Wavelength=str2num(StringFromList(1,StringByKey("WaveLength", testLine , "=",";")," "))*1e10	//convert to A
			Wavelength=NumberByKey("WaveLength", testLine , "=",";")*1e10	//convert to A
			XrayEnergy =  12.3984 /Wavelength
		endif
		//done reading header....
		if(ESRFEdf_Title)
			NewNote+="DataFileName="+replaceString("= ", StringByKey("Title", testLine , "=",";"),"")+" "+FileNameToLoad+";"
		else
			NewNote+="DataFileName="+FileNameToLoad+";"
		endif
		NewNote+="DataFileType="+"ESFRedf"+";"
		NewNote+=testLine
	elseif(cmpstr(FileType,"ascii128x128")==0)
		killwaves/Z Loadedwave0,Loadedwave1,Loadedwave2,Loadedwave3
		loadwave/P=$(PathName)/J/O/M/L={0,70,0,1,0}/V={"\t, "," $",0,0}/K=0/N=Loadedwave FileName
			if(V_flag==0)		//check if we loaded at least some data...
				return 0
			endif
		FileNameToLoad=FileName
		wave Loadedwave0
		matrixtranspose Loadedwave0
		make/d/o/n=(128,128) $(NewWaveName)
		wave tempp=$(NewWaveName)
		tempp=Loadedwave0
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"ascii128x128"+";"
		KillWaves Loadedwave0
	elseif(cmpstr(FileType,"FITS")==0)
		FileNameToLoad= FileName
		string FITSWaveLocationString =""
		string FITSWaveNoteString = ""
		FITSWaveLocationString = NI1_ReadFITSFIleFormat3(PathName, FileNameToLoad)
		if(strlen(FITSWaveLocationString)<5)
			abort "Cannot load FITS file"
		endif
		Wave LoadedWave0=$(FITSWaveLocationString)
		FITSWaveNoteString = note(LoadedWave0)
		note /K LoadedWave0
		duplicate/O Loadedwave0, $(NewWaveName)
		killwaves Loadedwave0
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"FITS"+";"
		NewNote+=FITSWaveNoteString
		KillDataFolder/Z root:Packages:Nika_FITS_Import	
	elseif(cmpstr(FileType,"GeneralBinary")==0)
		NVAR NIGBSkipHeaderBytes=root:Packages:Convert2Dto1D:NIGBSkipHeaderBytes
		NVAR NIGBSkipAfterEndTerm=root:Packages:Convert2Dto1D:NIGBSkipAfterEndTerm
		NVAR NIGBUseSearchEndTerm=root:Packages:Convert2Dto1D:NIGBUseSearchEndTerm
		NVAR NIGBNumberOfXPoints=root:Packages:Convert2Dto1D:NIGBNumberOfXPoints
		NVAR NIGBNumberOfYPoints=root:Packages:Convert2Dto1D:NIGBNumberOfYPoints
		NVAR NIGBSaveHeaderInWaveNote=root:Packages:Convert2Dto1D:NIGBSaveHeaderInWaveNote
	
		SVAR NIGBDataType=root:Packages:Convert2Dto1D:NIGBDataType
		SVAR NIGBSearchEndTermInHeader=root:Packages:Convert2Dto1D:NIGBSearchEndTermInHeader
		SVAR NIGBByteOrder=root:Packages:Convert2Dto1D:NIGBByteOrder
		SVAR NIGBFloatDataType=root:Packages:Convert2Dto1D:NIGBFloatDataType
		
		FileNameToLoad= FileName
		variable skipBytes=0
		if(NIGBUseSearchEndTerm)
			open /R/P=$(PathName) RefNum as FileNameToLoad
			testLine=""
			testLine=PadString (testLine, 40000, 0x20)
			FBinRead RefNum, testLine
			skipBytes=(strsearch(testLine, NIGBSearchEndTermInHeader, 0))+strlen(NIGBSearchEndTermInHeader)+NIGBSkipAfterEndTerm
			close RefNum
		else
			skipBytes=NIGBSkipHeaderBytes
			open /R/P=$(PathName) RefNum as FileNameToLoad
			testLine=""
			testLine=PadString (testLine, skipBytes, 0x20)
			FBinRead RefNum, testLine
			close RefNum
		endif
			testline=testline[0,skipBytes]
			if(stringmatch(testline, "*\r\n*"))
				testLine=ReplaceString("\r\n", testLine, ";" )
			elseif(stringmatch(testline, "*\r*"))
				testLine=ReplaceString("\r", testLine, ";" )
			elseif(stringmatch(testline, "*\n*"))
				testLine=ReplaceString("\n", testLine, ";" )
			endif
		variable LDataType
		//Double Float;Single Float;32 bit signed integer;16 bit signed integer;8 bit signed integer;32 bit unsigned integer;16 bit unsigned integer;8 bit unsigned integer
		if(cmpstr(NIGBDataType,"Double Float")==0)
			LDataType=4
		elseif(cmpstr(NIGBDataType,"Single Float")==0)
			LDataType=2
		elseif(cmpstr(NIGBDataType,"32 bit signed integer")==0)
			LDataType=32
		elseif(cmpstr(NIGBDataType,"16 bit signed integer")==0)
			LDataType=16
		elseif(cmpstr(NIGBDataType,"8 bit signed integer")==0)
			LDataType=8
		elseif(cmpstr(NIGBDataType,"32 bit unsigned integer")==0)
			LDataType=32+64
		elseif(cmpstr(NIGBDataType,"16 bit unsigned integer")==0)
			LDataType=16+64
		elseif(cmpstr(NIGBDataType,"8 bit unsigned integer")==0)
			LDataType=8+64
		endif
		if(LDataType==0)
			Abort "Wrong configuration of General Binary loader. BUG!"
		endif
		variable LByteOrder
		//High Byte First;Low Byte First
		if(cmpstr(NIGBByteOrder,"Low Byte First")==0)
			LByteOrder=1
		else
			LByteOrder=0
		endif
		variable LFloatType
		//NIGBFloatDataType IEEE,VAX
		if(cmpstr(NIGBFloatDataType,"IEEE")==0)
			LFloatType=1
		else
			LFloatType=2
		endif
		killwaves/Z Loadedwave0,Loadedwave1
		if(LDataType<5)	//float numbers, no sense to use Byte order
			GBLoadWave/Q/B=(LByteOrder)/T={LDataType,4}/J=(LFloatType)/S=(skipBytes)/W=1/P=$(PathName)/N=Loadedwave FileNameToLoad
		else
			GBLoadWave/Q/B=(LByteOrder)/T={LDataType,4}/S=(skipBytes)/W=1/P=$(PathName)/N=Loadedwave FileNameToLoad
		endif
			if(V_flag==0)		//check if we loaded at least some data...
				return 0
			endif
		wave Loadedwave0
		Redimension/N=(NIGBNumberOfXPoints,NIGBNumberOfYPoints) Loadedwave0
		duplicate/O Loadedwave0, $(NewWaveName)
		killwaves Loadedwave0
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"GeneralBinary"+";"
		if(NIGBSaveHeaderInWaveNote)
			NewNote+=testLine
		endif
	elseif(cmpstr(FileType,"GE binary")==0)		
		FileNameToLoad= FileName
		killwaves/Z Loadedwave0,Loadedwave1
		GBLoadWave/Q/B=(1)/T={80,4}/S=(8192)/W=1/P=$(PathName)/N=Loadedwave FileNameToLoad
			if(V_flag==0)		//check if we loaded at least some data...
				return 0
			endif
		wave Loadedwave0
		variable NumPntsInWv=numpnts(Loadedwave0)
		variable NumImages=NumPntsInWv/(2048*2048)
		make/O/N=(2048*2048) tempWvForLoad
		tempWvForLoad = 0
		variable iii
		For(iii=0;iii<NumImages;iii+=1)
			Multithread tempWvForLoad += Loadedwave0[p+iii*2048*2048]
		endfor
		if(NumImages>1)
			MatrixOp/O tempWvForLoad = tempWvForLoad/NumImages
		endif
		Redimension/N=(2048,2048) tempWvForLoad
		duplicate/O tempWvForLoad, $(NewWaveName)
		killwaves Loadedwave0, tempWvForLoad
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"GE binary"+";"
		NewNote+="GE binary images in the file="+num2str(NumImages)+";"
		print "Loaded GE file :"+FileNameToLoad+"   which contained "+num2str(NumImages)+"  images"
	elseif(cmpstr(FileType,"Pilatus/Eiger")==0)					//for Pilatus/Eiger... 
		//Pilatus parameters
		NVAR PilatusReadAuxTxtHeader=root:Packages:Convert2Dto1D:PilatusReadAuxTxtHeader
		SVAR PilatusFileType=root:Packages:Convert2Dto1D:PilatusFileType
		SVAR  PilatusType=root:Packages:Convert2Dto1D:PilatusType
		SVAR PilatusColorDepth=root:Packages:Convert2Dto1D:PilatusColorDepth
		NVAR PilatusSignedData=root:Packages:Convert2Dto1D:PilatusSignedData
		//now reading the stuff...
	       FileNameToLoad= FileName
	       //read TXT header file, available at ALS... 
	       if(PilatusReadAuxTxtHeader)
       	       //Print FileName
       	       Make/T /O headertxt0
       	       String txtFile
       	       txtFile = FileNameToLoad 
       	       txtFile =  ReplaceString("edf", FileNameToLoad, "txt")
       	      NVAR SampleI0 = root:Packages:Convert2Dto1D:SampleI0
       	      NVAR EmptyI0 = root:Packages:Convert2Dto1D:EmptyI0
       	       LoadWave/J /P=$(PathName) /N=headertxt /L={0,0,35,0,0}/B="F=-2;" ,txtFile
    	       	   if(cmpstr(NewWaveName, "EmptyData")==0)
      		        	EmptyI0 = str2num(headertxt0[1])
      		        else
              		SampleI0 = str2num(headertxt0[1])
              		//Print SampleI0
          		    endif
		endif
		
		//  read header in the file... , available ONLY for Tiff (4096 bytes) and edf (n*512 bytes)
		//see: http://www.esrf.eu/Instrumentation/software/data-analysis/OurSoftware/SAXS/SaxsHeader
		variable PilskipBytes
		variable headerLength1
		if(stringmatch(FileNameToLoad, "*.edf" )||(stringmatch(PilatusFileType,"edf")))
			open /R/P=$(PathName) RefNum as FileNameToLoad
			testLine=""
			testLine=PadString (testLine, 16800, 0x20)
			FBinRead RefNum, testLine
			close RefNum
			headerLength1=(strsearch(testLine, "}", 0))
			headerLength1 = ceil(headerLength1/512 ) * 512
			//PilskipBytes=1024
			PilskipBytes=headerLength1
		elseif(stringmatch(FileNameToLoad, "*.cbf" )||(stringmatch(PilatusFileType,"cbf")))
			open /R/P=$(PathName) RefNum as FileNameToLoad
			testLine=""
			testLine=PadString (testLine, 16800, 0x20)
			FBinRead RefNum, testLine
			close RefNum
			PilskipBytes=strsearch(testLine, "\014\032\004\325" , 0)		//this is string I found in test images
			if(PilskipBytes<5)	//string not found...
				PilskipBytes=strsearch(testLine, "\012\026\004\213" , 0)	//this is per http://www.bernstein-plus-sons.com/software/CBF/doc/CBFlib.html#3.2.2 what should be there. Go figure... 
			endif
			if(PilskipBytes<5)
				Abort "Failed to find start of binary section in the Cbf file"
			endif
			testLine = testLine[0, PilskipBytes]
		elseif(stringmatch(FileNameToLoad, "*.tif" )||stringmatch(FileNameToLoad, "*.tiff" ))
			PilskipBytes=4096
		elseif(stringmatch(FileNameToLoad, "*.img" ))//seems to have header also? , some edf files do haave extension img anyway :-?
			open /R/P=$(PathName) RefNum as FileNameToLoad
			testLine=""
			testLine=PadString (testLine, 16800, 0x20)
			FBinRead RefNum, testLine
			close RefNum
			//headerLength1=(strsearch(testLine, "}", 0))
			PilskipBytes=NumberByKey("HEADER_BYTES", testLine[2,100]  , "="  , ";")
			PilskipBytes = numtype(PilskipBytes)==0 ? PilskipBytes : 0
		else
			PilskipBytes=0
		endif
		if(PilskipBytes>0)
			open /R/P=$(PathName) RefNum as FileNameToLoad
			testLine=""
			testLine=PadString (testLine, PilskipBytes, 0x20)
			FBinRead RefNum, testLine
			//print testLine
			close RefNum
		else
			testLine=""
		endif
		//end read header
		//clean up header to make it more like our headers...
		if(stringmatch(FileNameToLoad, "*.cbf" ))
			testLine=ReplaceString("\r\n\r\n", testLine, ";")
			testLine=ReplaceString("\r\n", testLine, ";")
			testLine=ReplaceString("#", testLine, "")
			testLine=ReplaceString(";;;;", testLine, ";")
			testLine=ReplaceString(";;;", testLine, ";")
			testLine=ReplaceString(";;", testLine, ";")
			testLine = ReplaceString(":", testLine, "=")
			testLine = ReplaceString(" = ", testLine, "=")
			testLine = ReplaceString("= ", testLine, "=")
			testLine = NI1_ZapControlCodes(testLine)	
			testLine = NI1_ReduceSpaceRunsInString(testLine,1)
			testLine = "Start of Cbf header>>>;"+testLine+"<<<<End of Cbf header;"
		elseif(stringmatch(FileNameToLoad, "*.img" )&&(PilskipBytes>0))
			testLine=ReplaceString("\r\n\r\n", testLine, ";")
			testLine=ReplaceString("\r\n", testLine, ";")
			testLine=ReplaceString("#", testLine, "")
			testLine=ReplaceString("{", testLine, "")
			testLine=ReplaceString("}", testLine, "")
			testLine=ReplaceString(";;;;", testLine, ";")
			testLine=ReplaceString(";;;", testLine, ";")
			testLine=ReplaceString(";;", testLine, ";")
			testLine = ReplaceString(":", testLine, "=")
			testLine = ReplaceString(" = ", testLine, "=")
			testLine = ReplaceString("= ", testLine, "=")
			testLine = NI1_ZapControlCodes(testLine)	
			testLine = NI1_ReduceSpaceRunsInString(testLine,1)
			testLine = "Start of img header>>>;"+testLine+"<<<<End of img header;"
		elseif(stringmatch(FileNameToLoad, "*.tiff" )&&(PilskipBytes>0))
			testLine = ReplaceString("\n", testLine, "")
			testLine = ReplaceString("#", testLine, ";")
			testLine = ReplaceString(":", testLine, "=")
			testLine = NI1_RemoveNonASCII(testLine)
			testLine = NI1_ZapControlCodes(testLine)	
			testLine = NI1_ReduceSpaceRunsInString(testLine,1)
			testLine = ReplaceString(" = ", testLine, "=")
			testLine = ReplaceString(" ;", testLine, ";")
			testLine = "Start of tif header>>>;"+testLine+"<<<<End of tif header;"
			testLine=ReplaceString(";;;;", testLine, ";")
			testLine=ReplaceString(";;;", testLine, ";")
			testLine=ReplaceString(";;", testLine, ";")
		else
			testLine = ReplaceString("\n", testLine, "")
			testLine = ReplaceString("{", testLine, "Start of ESRF header>>>;")
			testLine = ReplaceString("}", testLine, "<<<<End of ESRF header;")
			testLine = ReplaceString(" = ", testLine, "=")
			testLine = ReplaceString(" ;", testLine, ";")
			testLine = NI1_ReduceSpaceRunsInString(testLine,1)
		endif
		//read the Pilatus file itself
		//2021-02 we have FLOAT which seem to be now also possible. Most likely single FLOAT? 	
		variable PilatusColorDepthVar
		if(StringMatch(PilatusColorDepth, "FLOAT"))
			PilatusColorDepthVar=2
		else
			PilatusColorDepthVar=str2num(PilatusColorDepth)
			//color depth can be 8, 16, or 32 signed integers or unsigned integer 64, but that is not supported by Igor, to denote them in Igor as unnsigned, need to add 64 ...
			if(PilatusColorDepthVar<64 && PilatusSignedData)   //PilatusSignedData=1 when unsigned integers, default signed integers
				PilatusColorDepthVar+=64		//now we have proper 8, 16, or 32 unsigned integers for Igor... 
			endif
		endif
          killwaves/Z Loadedwave0,Loadedwave1
          if(stringMatch(PilatusFileType,"edf"))
       	       GBLoadWave/B/T={PilatusColorDepthVar,PilatusColorDepthVar}/S=(PilskipBytes)/W=1 /P=$(PathName)/N=Loadedwave FileNameToLoad
          elseif(stringMatch(PilatusFileType,"cbf"))
              	//check if the cbf conforms to what we expect...
        	 	if(StringMatch(testLine , "*LITTLE_ENDIAN*") && StringMatch(testLine, "*x-CBF_BYTE_OFFSET*"))
					NI1A_LoadCbfCompresedImage(PathName,FileNameToLoad, "Loadedwave0")
				else
					abort "Unknown cbf file"
				endif
       	 elseif(stringMatch(PilatusFileType,"tiff")||stringMatch(PilatusFileType,"tif"))
       	       GBLoadWave/B=(1)/T={PilatusColorDepthVar,PilatusColorDepthVar}/S=(PilskipBytes)/W=1 /P=$(PathName)/N=Loadedwave FileNameToLoad
       	 elseif(stringMatch(PilatusFileType,"float-tiff"))
       	       GBLoadWave/B=(1)/T={4,4}/S=4096/W=1 /P=$(PathName)/N=Loadedwave FileNameToLoad
       	 elseif(stringMatch(PilatusFileType,"img"))
       	       GBLoadWave/B=(1)/T={PilatusColorDepthVar,PilatusColorDepthVar}/S=(PilskipBytes)/W=1 /P=$(PathName)/N=Loadedwave FileNameToLoad
	      	 endif
			if(V_flag==0)		//check if we loaded at least some data...
				return 0
			endif
              Wave LoadedWave0
           if(stringmatch(PilatusType,"Pilatus100k"))
 	             Redimension/N=(487,195) Loadedwave0
 	        elseif(stringmatch(PilatusType,"Pilatus1M"))
 	             Redimension/N=(981,1043) Loadedwave0
 	        elseif(stringmatch(PilatusType,"Pilatus300k"))
 	             Redimension/N=(487,619) Loadedwave0
 	        elseif(stringmatch(PilatusType,"Pilatus300k-w"))
 	             Redimension/N=(1475,195) Loadedwave0
 	        elseif(stringmatch(PilatusType,"Pilatus2M"))
 	             Redimension/N=(1475,1679) Loadedwave0
 	        elseif(stringmatch(PilatusType,"Pilatus6M"))
 	             Redimension/N=(2463,2527) Loadedwave0
 	        elseif(stringmatch(PilatusType,"Pilatus3_200k"))
 	             Redimension/N=(487,407) Loadedwave0   
 	        elseif(stringmatch(PilatusType,"Eiger500k"))			//Eiger500k;Eiger1M;Eiger4M;Eiger9M;Eiger16M
 	             Redimension/N=(512,1028) Loadedwave0   
 	        elseif(stringmatch(PilatusType,"Eiger1M"))
 	             //Redimension/N=(1062,1028) Loadedwave0
 	             Redimension/N=(1030,1065) Loadedwave0      	//4-18-2022 based on Decrtis pdf about Eiger det. 
 	        elseif(stringmatch(PilatusType,"Eiger4M"))
 	             //Redimension/N=(2162,2068) Loadedwave0   
 	             Redimension/N=(2070,2167) Loadedwave0      	//4-18-2022 based on Decrtis pdf about Eiger det. 
 	        elseif(stringmatch(PilatusType,"Eiger9M"))
 	             //Redimension/N=(3262,3108) Loadedwave0   
 	             Redimension/N=(3110,3269) Loadedwave0      	//4-18-2022 based on Decrtis pdf about Eiger det. 
 	        elseif(stringmatch(PilatusType,"Eiger16M"))
 	            Redimension/N=(4150,4371) Loadedwave0   	//this works for test 16M cbf. Are all images this way? 
 	        elseif(stringmatch(PilatusType,"Eiger2_500k"))			//Eiger2 
 	             Redimension/N=(512,1028) Loadedwave0   
 	        elseif(stringmatch(PilatusType,"Eiger2_1M"))
 	             Redimension/N=(1028,1062) Loadedwave0      	//3-24-2024 based on Decrtis www about Eiger det. 
 	        elseif(stringmatch(PilatusType,"Eiger2_4M"))
 	             Redimension/N=(2068,2162) Loadedwave0      	//3-24-2024 based on Decrtis www about Eiger det. 
 	        elseif(stringmatch(PilatusType,"Eiger2_9M"))
 	             Redimension/N=(3108,3262) Loadedwave0      	//3-24-2024 based on Decrtis www about Eiger det. 
 	        elseif(stringmatch(PilatusType,"Eiger2_16M"))
 	            Redimension/N=(4148,4362) Loadedwave0   		//3-24-2024 based on Decrtis www about Eiger det.  
 	        elseif(stringmatch(PilatusType,"Eiger2_1MW"))
 	            Redimension/N=(2068,512) Loadedwave0   		//3-24-2024 based on Decrtis www about Eiger det. 
 	        elseif(stringmatch(PilatusType,"Eiger2_2MW"))
 	            Redimension/N=(4148,512) Loadedwave0   		//3-24-2024 based on Decrtis www about Eiger det. 
 	        else
 	        	Abort "Unknown Pilatus Type"
 	        endif
         //     Loadedwave0[12][162] /= 100.0
              duplicate/O Loadedwave0, $(NewWaveName)
              //call Hook function 
              if(exists("PilatusHookFunction")==6)
              	Execute("PilatusHookFunction("+NewWaveName+")")
              endif
              killwaves Loadedwave0
              NewNote+="DataFileName="+FileNameToLoad+";"
              NewNote+="DataFileType="+PilatusType+";"
              NewNote+=testLine+";"
	elseif(cmpstr(FileType,"RIGK/Raxis")==0)
		FileNameToLoad= FileName
		string RigakuHeader = NI1A_ReadRigakuUsingStructure(PathName, FileNameToLoad)
		//print RigakuHeader
		//variable offsetFile = NI1A_FindFirstNonZeroChar(PathName, FileNameToLoad)
		variable offsetFile = NumberByKey("RecordLengthByte", RigakuHeader )
		//print "Found offset in the file to be: "+num2str(offsetFile)
		variable 	RigNumOfXPoint=NumberByKey("xDirectionPixNumber", RigakuHeader)
		variable 	RigNumOfYPoint=NumberByKey("yDirectionPixNumber", RigakuHeader)
		if (numtype(offsetFile)!=0 || offsetFile<250)		//check for meaningful offset
			//if not meaningful, caclualte offset from RigNumOfXPoint
			offsetFile = RigNumOfXPoint*2
			Print "Bad offset in the file header, assume offset is given (as should be) by x dimension of the image. Offset set to : "+num2str(offsetFile)
		endif
		killwaves/Z Loadedwave0,Loadedwave1
	//	GBLoadWave/B=0/T={16,4}/S=2048/W=1/P=$(PathName)/q=1/N=Loadedwave FileNameToLoad	//works for 1kx1k
	//	GBLoadWave/B=0/T={16,4}/S=3024/W=1/P=$(PathName)/q=1/N=Loadedwave FileNameToLoad	//works for 1.5k x 1.5k
		//fix for 1.5k x 1.5k images... In the test example I have seems to be offset 3000 bytes, but 
		GBLoadWave/B=0/T={16,4}/S=(offsetFile)/W=1/P=$(PathName)/q=1/N=Loadedwave FileNameToLoad
			if(V_flag==0)		//check if we loaded at least some data...
				return 0
			endif
		//changed on 7/20/2007... Looking for offset as first non 0 value. WOrks on 1kx1k and 1.5k x 1.5k images provided... 
		//11/2008 - the offset is given by one column length, per Rigaku file description. Set as that. BTW: Fit2D uses the same assumption. 
		wave Loadedwave0
		Redimension/N=(RigNumOfXPoint,RigNumOfYPoint) Loadedwave0
		duplicate/O Loadedwave0, $(NewWaveName)
		killwaves Loadedwave0
		wave w=$(NewWaveName)
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"RIGK/Raxis"+";"
		NewNote+=RigakuHeader
		//the header contains useful data, let's parse them in....
		NVAR Wavelength=root:Packages:Convert2Dto1D:Wavelength
		NVAR XrayEnergy=root:Packages:Convert2Dto1D:XrayEnergy
		NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
		NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
		PixelSizeX = NumberByKey("xDirectionPixelSizeMM", RigakuHeader)
		PixelSizeY = NumberByKey("yDirectionPixelSizeMM", RigakuHeader)
		Wavelength = NumberByKey("Wavelength", RigakuHeader)
		XrayEnergy = 12.398424437/Wavelength
		//now check if we need to convert negative values to high intensities...
		variable OutPutRatioHighLow
		OutPutRatioHighLow=NumberByKey("OutPutRatioHighLow", RigakuHeader)			//conversion factor, 0 if no conversion needed
		//seems to fail.. Lets default to 8 when not set...
		//most Rigaku instruments use multiplier of 8, assume that it is correct, but note, there are two which use 32. Life would be too easy without exceptions... 
		if(OutPutRatioHighLow==0)
			OutPutRatioHighLow=8
		endif
		wavestats/Q w
		if(V_min>=0)
			//nothing needed, let's not worry...
		elseif(OutPutRatioHighLow>0 && V_min<0)
			//fix the negative values...
			NI1A_RigakuFixNegValues(w,OutPutRatioHighLow)
		else
			Abort "Problem loading the Rigaku file format. Header and values do not agree... Please contact author (ilavsky@aps.anl.gov) and send the offending file with as much info as possible for evaluation"
		endif
		//now let's print the few parameters user shoudl need...
		print "**************************************************"
		print "***  Rigaku R axis file format header info  **"
		print "Camera length in the file is [mm] ="+StringByKey("CameraLength_mm", RigakuHeader)
		print "Beam center X position in the file is [pixel] ="+StringByKey("DirectBeamPositionX", RigakuHeader)
		print "Beam center Y position in the file is [pixel] ="+StringByKey("DirectBeamPositionY", RigakuHeader)
		print "**************************************************"
		print "**************************************************"
	elseif(cmpstr(FileType,"ibw")==0)
   	     PathInfo $(PathName)
   	     KillWaves/Z $(NewWaveName)
  	     FileNameToLoad=   FileName
   	     LoadWave /P=$(PathName)/H/O  FileNameToLoad
			if(V_flag==0)		//check if we loaded at least some data...
				return 0
			endif
   	     string LoadedName=StringFromList(0,S_waveNames)
   	     Wave CurLdWv=$(LoadedName)
   	     Rename CurLdWv, $(NewWaveName)
	elseif(cmpstr(FileType,"BSL/SAXS")==0 || cmpstr(FileType,"BSL/WAXS")==0)
   	     //Josh add
   	     NVAR BSLsumframes=$("root:Packages:NI1_BSLFiles:BSLsumframes")
   	     NVAR BSLsumseq=$("root:Packages:NI1_BSLFiles:BSLsumseq")
   	     NVAR BSLfromframe=$("root:Packages:NI1_BSLFiles:BSLfromframe")
   	     NVAR BSLtoframe=$("root:Packages:NI1_BSLFiles:BSLtoframe")
   	     
   	     PathInfo $(PathName)
   	     KillWaves/Z $(NewWaveName)
  	     FileNameToLoad=   FileName
   	     variable AveragedFrame=NI1_LoadBSLFiles(FileNameToLoad)
 		Wave/Z temp2DWave = $("root:Packages:NI1_BSLFiles:temp2DWave")
		if(!WaveExists(temp2DWave))
			return 0
		endif
		duplicate/O temp2DWave, $(NewWaveName)
		string AveFrame=""
		if(AveragedFrame==0)
			AveFrame="Averaged"
		elseif(BSLsumframes==1||BSLsumseq==1)
			AveFrame="summed frame "+num2str(BSLfromframe)+" to "+" frame "+num2str(BSLtoframe)
		else
			AveFrame="frame"+num2str(AveragedFrame)
		endif
		NewNote+="DataFileName="+FileNameToLoad+"_"+AveFrame+";"
		NewNote+="DataFileType="+FileType+";"
	elseif(UseCalib2DData&&cmpstr(FileType,"canSAS/Nexus")==0)
		//import CanSAS file format and convert to proper calibrated data.
		FileNameToLoad = FileName
		NI1_ReadCalibCanSASNexusFile(PathName, FileNameToLoad, NewWaveName)		
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"canSAS/Nexus"+";"
	elseif(cmpstr(FileType,"Nexus")==0)
		FileNameToLoad = FileName
		NEXUS_NexusNXsasDataReader(PathName, FileNameToLoad)
		Wave/Z Loadedwave0
		if(!WaveExists(Loadedwave0))
			return 0
		endif	
		duplicate/O Loadedwave0, $(NewWaveName)
		killwaves Loadedwave0
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"Nexus"+";"
	elseif(cmpstr(FileType,"Fuji/img")==0)
		string FujiHeader
      FileNameToLoad =  FileName
		FujiHeader = NI1_ReadFujiImgHeader(PathName, FileNameToLoad)
		NI1_ReadFujiImgFile(PathName, FileNameToLoad, FujiHeader)
		Wave/Z Loadedwave0
		if(!WaveExists(Loadedwave0))
			return 0
		endif
		duplicate/O Loadedwave0, $(NewWaveName)
		killwaves Loadedwave0
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"mp/bin"+";"
		NewNote+=FujiHeader
	elseif(cmpstr(FileType,"mpa")==0)
		FileNameToLoad= FileName
		testLine=""
		testLine=PadString (testLine, 300000, 0x20)
		open /R/P=$(PathName) RefNum as FileNameToLoad
		FreadLine/N=2048 /T=";" RefNum, testLine
		testLine=ReplaceString("\r\n", testLine, ";" )
		close RefNum
		testLine=ReplaceString("\n", testLine, ";" )
		testLine=ReplaceString(" ", testLine, "" )
		testLine=testLine[0,strsearch(testLine, "[DAT", 0 )-1]
		string mpatype=StringByKey("mpafmt", testLine, "=", ";")
		variable mparange=1024^2 //NumberByKey("range", testLine, "=", ";")
		numBytes=NumberByKey("range", testLine , "=" , ";")
		print "Found mpa type in the file: " + mpatype
		killwaves/Z Loadedwave0,Loadedwave1
		if(stringmatch(mpatype,"dat"))			//surprise, thsi is bin type... 
			testLine=""
			testLine=PadString (testLine, 300000, 0x20)
			open /R/P=$(PathName) RefNum as FileNameToLoad
			FBinRead RefNum, testLine
			Offset=(strsearch(testLine, "[CDAT0,1048576 ]", 0))+22
			close RefNum
			GBLoadWave/B/T={96,4}/S=(Offset)/W=1/P=$(PathName)/N=Loadedwave FileNameToLoad
				if(V_flag==0)		//check if we loaded at least some data...
					return 0
				endif
			wave Loadedwave0
			Redimension/N=(1024,1024) Loadedwave0
		elseif(stringmatch(mpatype,"asc"))
			variable MPAACSDataOffset=NI1_mpaFindFirstDataLine(pathName, FileNameToLoad) + 1
			LoadWave /J /D /O/N=Loadedwave /K=0 /L={0,MPAACSDataOffset,0,0,0}/P=$(PathName) FileNameToLoad
			if(V_flag==0)		//check if we loaded at least some data...
				return 0
			endif
			wave Loadedwave0
			Redimension/N=(1024,1024) Loadedwave0
		elseif(stringmatch(mpatype,"spe"))
			variable MPAACSDataOffsetSpe=NI1_mpaFindFirstDataLine(pathName, FileNameToLoad) + 8
			variable MPAACDNumPoints= NI1_MPASpeFindNumDataLines(pathName, FileNameToLoad)
	 		LoadWave /M /F={10, 8, 0}/O/N=Loadedwave/L={0,MPAACSDataOffsetSpe,0,0,0}/P=$(PathName) FileNameToLoad
			if(V_flag==0)		//check if we loaded at least some data...
				return 0
			endif
			wave Loadedwave0
			MatrixOp/O Loadedwave0 =Loadedwave0^t  
			//redimension/N=(MPAACDNumPoints) Loadedwave0
			//print sqrt(MPAACDNumPoints)
			Redimension/N=(sqrt(MPAACDNumPoints),sqrt(MPAACDNumPoints)) Loadedwave0
		elseif(stringmatch(mpatype,"csv"))
			Abort "CSV mpa file format is not finished, did not have functional test case example. Provide me the example and I'll finish this. " 
		endif
		duplicate/O Loadedwave0, $(NewWaveName)
		killwaves Loadedwave0
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"mpa type :"+mpatype+";"
		NewNote+=testLine

	elseif(cmpstr(FileType,"mp/bin")==0)
		FileNameToLoad= FileName
		open /R/P=$(PathName) RefNum as FileNameToLoad
		FreadLine/N=1024 /T=";" RefNum, testLine
		Offset=(strsearch(testLine, "]", strsearch(testLine,"CDAT",0)))+7
		testLine=ReplaceString("\r\n", testLine, ";" )
		numBytes=NumberByKey("range", testLine , "=" , ";")
		close RefNum
		killwaves/Z Loadedwave0,Loadedwave1
		GBLoadWave/B/T={96,4}/S=(Offset)/W=1/P=$(PathName)/N=Loadedwave FileNameToLoad
			if(V_flag==0)		//check if we loaded at least some data...
				return 0
			endif
		wave Loadedwave0
		Redimension/N=(sqrt(numBytes),sqrt(numBytes)) Loadedwave0
		duplicate/O Loadedwave0, $(NewWaveName)
		killwaves Loadedwave0
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"mp/bin"+";"
	elseif(cmpstr(FileType,"mpa/UC")==0)
		FileNameToLoad= FileName
		open /R/P=$(PathName) RefNum as FileNameToLoad
		testLine=""
		testLine=PadString (testLine, 20000, 0x20)
		FBinRead RefNum, testLine
		Offset=(strsearch(testLine, "[CDAT0,1048576 ]", 0))+22
		testLine=ReplaceString("\r\n", testLine, ";" )
		testLine=ReplaceString("\n", testLine, ";" )
		numBytes=NumberByKey("range", testLine , "=" , ";")
		close RefNum
		killwaves/Z Loadedwave0,Loadedwave1
		LoadWave/J/D/N=Loadedwave/K=0/P=$(PathName)/L={0,(2050+87),0,0,0} FileNameToLoad 
			if(V_flag==0)		//check if we loaded at least some data...
				return 0
			endif
		wave Loadedwave0
		Redimension/N=(1024,1024) Loadedwave0
		//Make/N=(1024,1024)/Free tempWvTxt2Num
		//tempWvTxt2Num = str2num(Loadedwave0[p,q])
		duplicate/O Loadedwave0, $(NewWaveName)
		killwaves Loadedwave0
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"mpa/UC"+";"
		Offset=(strsearch(testLine, "[DAT", 0))-1
		testLine=testLine[0,offset]
		NewNote+=testLine
	elseif(cmpstr(FileType,"ascii512x512")==0)
		killwaves/Z Loadedwave0,Loadedwave1,Loadedwave2,Loadedwave3
		loadwave/P=$(PathName)/J/O/M/N=Loadedwave FileName
			if(V_flag==0)		//check if we loaded at least some data...
				return 0
			endif
		FileNameToLoad=FileName
		wave Loadedwave0
		make/d/o/n=(512,512) $(NewWaveName)
		wave tempp=$(NewWaveName)
		tempp=Loadedwave0
		KillWaves Loadedwave0
	elseif(cmpstr(FileType,"DND/txt")==0)
		FileNameToLoad= FileName
		open /R/P=$(PathName) RefNum as FileNameToLoad
		HeaderStr=NI1_ReadDNDHeader(RefNum)		//read the header from the text file
		close RefNum
		//header string contains now all information from the text file... Now need to open the tiff file
		string tiffFilename=NI1_FindDNDTifFile(PathName,FileName,HeaderStr)
		//and also established data path "DNDDataPath" where teh data are
		LoadedOK=NI1A_UniversalLoader("DNDDataPath",tiffFilename,".tif",NewWaveName)
			if(!LoadedOK)		//check if we loaded at least some data...
				return 0
			endif
		//append wave note...
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"DND/txt"+";"
		NewNote+=HeaderStr
		//parse the header for DND CAT stuff to separate folder for use in data reduction
		NI1_ParseDNDHeader(HeaderStr, FileNameToLoad)
	elseif(cmpstr(FileType,"ASCII")==0)
		//LoadWave/G/M/D/N=junk/P=LinusPath theFile
		FileNameToLoad= FileName
		killwaves/Z Loadedwave0,Loadedwave1,Loadedwave2,Loadedwave3
		LoadWave/G/M/D/P=$(PathName)/A=Loadedwave FileNameToLoad
			if(V_flag==0)		//check if we loaded at least some data...
				return 0
			endif
		wave Loadedwave0
		duplicate/O Loadedwave0, $(NewWaveName)
		killwaves Loadedwave0
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"ASCII"+";"
		//now, if this was file with extension mtx then look for file with extension prm and load parameters from there
		if(stringmatch(FileName, "*.mtx" ))
			string NewFlNm = FileName[0,strlen(FileName)-5]+".prm"
			string templine
			variable tempFilNmNum, ii
			open/R/Z=1/P=$(PathName) tempFilNmNum as NewFlNm
			if(V_Flag==0)
				For(ii=0;ii<100;ii+=1)
					FreadLine tempFilNmNum, templine
					if(strlen(templine)<1)
						ii=101
					else
						templine = IN2G_ChangePartsOfString(templine,"  ","")
						templine = IN2G_ChangePartsOfString(templine,"\r","")
						templine = IN2G_ChangePartsOfString(templine,":","=")
						if(strlen(templine)>3)
							NewNote+=templine+";"
						endif
					endif
				endfor
				NVAR Wavelength=root:Packages:Convert2Dto1D:Wavelength
				NVAR XrayEnergy = root:Packages:Convert2Dto1D:XrayEnergy
				//12.398424437 
				//SampletoDetectorDistance=5419mm
				NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance
			//	SampleToCCDDistance = NumberByKey("SampletoDetectorDistance", NewNote  , "=", ";")
				//string tempstr=stringByKey("Sample to Detector Distance", NewNote  , "=", ";")
				SampleToCCDDistance = NumberByKey("Sample to Detector Distance", NewNote  , "=", ";") 
				//SampleToCCDDistance = str2num(tempstr[0,strlen(tempstr)-3])
				//TotalLiveTime=1800.000000seconds
				NVAR SampleI0 = root:Packages:Convert2Dto1D:SampleI0
				SampleI0 = NumberByKey("Total Monitor Counts", NewNote  , "=", ";") //TotalMonitorCounts
				NVAR SampleMeasurementTime = root:Packages:Convert2Dto1D:SampleMeasurementTime
			//	SampleMeasurementTime = str2num(stringByKey("Total Live Time", NewNote  , "=", ";")[0,11])
				SampleMeasurementTime = NumberByKey("Total Live Time", NewNote  , "=", ";") 

			endif
			close tempFilNmNum
		endif
		//end of special section for case or parameter file... This al section should be skipped for any other ASCIi files. 
	elseif(cmpstr(FileType,"BSRC/Gold")==0)
		FileNameToLoad= FileName
		killwaves/Z Loadedwave0,Loadedwave1
		GBLoadWave/J=2/T={80,80}/S=5632/W=1/U=2359296 /P=$(PathName)/N=Loadedwave FileNameToLoad
		//GBLoadWave/B/T={96,4}/S=430/W=1/U=(numBytes)/P=$(PathName)/N=Loadedwave FileNameToLoad
			if(V_flag==0)		//check if we loaded at least some data...
				return 0
			endif
		wave Loadedwave0
		Redimension/N=(1536,1536) Loadedwave0
		//Redimension/N=(sqrt(numBytes),sqrt(numBytes)) Loadedwave0
		duplicate/O Loadedwave0, $(NewWaveName)
		killwaves Loadedwave0
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"BSRC/Gold"+";"
	elseif(stringMatch(FileType,"*/Fit2D"))
		PathInfo $(PathName)
//		if(cmpstr(IgorInfo(2),"Windows")!=0)
//			Abort "This import tool works only on WIndows for now"
//		endif
//		FileNameToLoad=  S_path + FileName
//		LoadedOK=ReadMAR345UsingFit2D(FileNameToLoad, NewWaveName,FileType,PathName)
//			if(!LoadedOK)		//check if we loaded at least some data...
//				return 0
//			endif
		//string temp=StringFromList(ItemsInList(FileNameToLoad,":")-1,FileNameToLoad,":")
//		NewNote+="DataFileName="+StringFromList(ItemsInList(FileNameToLoad,":")-1,FileNameToLoad,":")+";"
//		NewNote+="DataFileType="+"marIP/Fit2D"+";"
	elseif(cmpstr(FileType,"MarIP/xop")==0)		//added 9/16/2008, needs ccp4xop ... 
		PathInfo $(PathName)
		FileNameToLoad=  S_path + FileName
#if(Exists("ccp4unpack"))	
		ccp4unpack/M /N=$(NewWaveName)/O  FileNameToLoad		//note: Fails for names too long... 
		LoadedOK=1		//??? how to check if it works?
//		ccp4unpack/M /N=$(NewWaveName)/P=$(PathName) /O  FileNameToLoad
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"MarIP/xop"+";"
		Wave tempWnNm=$(NewWaveName)		//here we fix the damn header from Mar IP file format... 
		string OldNote1234=note(tempWnNm)
		OldNote1234 = ReplaceString("\n", OldNote1234, ";")
		OldNote1234 = ReplaceString("     ", OldNote1234, ":")
		OldNote1234 = ReplaceString(" ", OldNote1234, "")
		variable iiii
		For(iiii=0;iiii<10;iiii+=1)
			OldNote1234 = ReplaceString("::", OldNote1234, ":")		
		endfor
		OldNote1234 = ReplaceString(";:;", OldNote1234, ";")
		OldNote1234 = ReplaceString(":;", OldNote1234, ";")
		note/K tempWnNm
		Note  tempWnNm ,OldNote1234
#endif
	elseif(cmpstr(FileType,"BrukerCCD")==0)
		PathInfo $(PathName)
		FileNameToLoad=  S_path + FileName
		//GBLoadWave/B/T={80,80}/S=7680/W=1/O/N=TempLoadWave FileNameToLoad
		LoadedOK=NI1_ReadBrukerCCD_SMARTFile(FileNameToLoad, NewWaveName)
			if(!LoadedOK)		//check if we loaded at least some data...
				return 0
			endif
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"BrukerCCD"+";"
	elseif(cmpstr(FileType,"WinView spe (Princeton)")==0)
		PathInfo $(PathName)
		FileNameToLoad=  S_path + FileName
		LoadedOK=NI1_LoadWinViewFile(FileNameToLoad, NewWaveName)
			if(!LoadedOK)		//check if we loaded at least some data...
				return 0
			endif
		NewNote+="DataFileName="+FileNameToLoad+";"
		NewNote+="DataFileType="+"WinView spe (Princeton)"+";"
	elseif(cmpstr(FileType,"ADSC")==0 || cmpstr(FileType,"ADSC_A")==0)
	//new version sent by Peter : PReichert@lbl.gov. Modified to read Io and other parameters from their ADSC file format. 
         FileNameToLoad= FileName
           variable dummy_i0
           wave/Z IonChamber_1, IonChamber_0, I1_I0
           variable dummy_i1_1,dummy_i1,dummy_i1_2, dummy_time,Ring
           LDataType=16+64
           LByteOrder=1
           LFloatType=1
           NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
           NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
           NVAR NIGBNumberOfXPoints=root:Packages:Convert2Dto1D:NIGBNumberOfXPoints
           NVAR NIGBNumberOfYPoints=root:Packages:Convert2Dto1D:NIGBNumberOfYPoints
           NVAR Wavelength=root:Packages:Convert2Dto1D:Wavelength
           NVAR XrayEnergy=root:Packages:Convert2Dto1D:XrayEnergy
	  		  NVAR SampleI0 = root:Packages:Convert2Dto1D:SampleI0

           Make/T /O textWave
           Make/T /O header0
           LoadWave/J /P=$(PathName) /N=header /L={0,0,39,0,0}/B="F=-2;" ,FileNameToLoad
			if(V_Flag==0)		//check if we loaded at least some data...
				return 0
			endif
	       skipBytes = NumberByKey("HEADER_BYTES",(header0[1]),"=")
	       variable dummy
	        for(i = 0; i < numpnts(header0);i=i+1)
	               dummy = NumberByKey("SIZE2",(header0[i]),"=")
	               if(dummy)
	               NIGBNumberOfXPoints = dummy
	               NIGBNumberOfYPoints = dummy
	               endif
	               dummy = NumberByKey("PIXEL_SIZE",(header0[i]),"=")
	               if(dummy)
	               PixelSizeX =  dummy
	               PixelSizeY =  dummy
	               endif
	               dummy = NumberByKey("HEADER_BYTES",(header0[i]),"=")
	               if(dummy)
	               skipBytes = dummy
	               endif
	                dummy = NumberByKey("RING_CURRENT",(header0[i]),"=")
	               if(dummy)
	               Ring = dummy
	               endif
	               dummy = NumberByKey("I1",(header0[i]),"=")
	               if(dummy)
	               dummy_i1  = dummy
	               endif
	               dummy = NumberByKey("I0",(header0[i]),"=")
	               if(dummy)
	               dummy_i0  = dummy
	               endif
	                dummy = NumberByKey("I1_1",(header0[i]),"=")
	               if(dummy)
	               dummy_i1_1  = dummy
	               endif
	                dummy = NumberByKey("I1_2",(header0[i]),"=")
	               if(dummy)
	               dummy_i1_2  = dummy
	               endif
	               dummy = NumberByKey("I0_1",(header0[i]),"=")
	               if(dummy)
	               dummy_i0  = dummy
	               endif
		   			dummy = NumberByKey("WAVELENGTH",(header0[i]),"=")
	               if(dummy)
	               	if(cmpstr(FileType,"ADSC")==0)			//ADSC_A has wavelength in A and should nto be scaled from nm. 
	              		 Wavelength =  dummy*10
	              	else
	              		 Wavelength =  dummy
	              	endif	
	               XrayEnergy = 12.398424437/Wavelength
	               endif
	          endfor
          if (dummy_i1_1 > 1)
              	if(dummy_i1_2 >1)
              		dummy_i1 = (dummy_i1_1+dummy_i1_2)/2.0
              	else
              		dummy_i1 = dummy_i1_1
              	endif
          elseif (dummy_i1 >1)
          else 
              	dummy_i1 = 1
          endif
          SampleI0 = dummy_i1
               //Print NIGBNumberOfYPoints
          killwaves/Z Loadedwave0,Loadedwave1
          GBLoadWave/Q/B=(LByteOrder)/T={LDataType,4}/S=(skipBytes)/W=1/P=$(PathName)/N=Loadedwave FileNameToLoad
			if(V_Flag==0)		//check if we loaded at least some data...
					return 0
			endif
         Wave LoadedWave0
         Redimension/N=(NIGBNumberOfXPoints,NIGBNumberOfYPoints) Loadedwave0
         duplicate/O Loadedwave0, $(NewWaveName)
           //slicing (Loadedwave0)
         killwaves Loadedwave0
         NewNote+="DataFileName="+FileNameToLoad+";"
         NewNote+="DataFileType="+"ADSC"+";"
	 	 
	else
		Abort "Uknown CCD image to load..."
	endif
	wave loadedwv=$(NewWaveName)
	//7-25-2022 2.59 added ability to flip/rotate images if needed
	// No;Transpose;FlipHor;FlipVert, Tran/FlipH
	SVAR/Z RotateFLipImageOnLoad=root:Packages:Convert2Dto1D:RotateFLipImageOnLoad
	if(SVAR_Exists(RotateFLipImageOnLoad))
		strswitch(RotateFLipImageOnLoad)	// string switch
			case "No":		// execute if case matches expression
					//nothing needed here
				break				// exit from switch
			case "Transpose":	// execute if case matches expression
				 MatrixOp/O loadedwv=loadedwv^t
				break
			case "FlipVert":	// execute if case matches expression
				 MatrixOp/O loadedwv=reverseCols(loadedwv)
				break
			case "FlipHor":	// execute if case matches expression
				 MatrixOp/O loadedwv=reverseRows(loadedwv)
				break
			case "Tran/FlipH":	// execute if case matches expression
				 MatrixOp/O loadedwv=reverseRows(loadedwv^t)
				break
			default:			// optional default expression executed
					//nothing needed here
		endswitch
	
	endif
	
	
	pathInfo $(PathName)
   if(exists("ImportedImageHookFunction")==6)
       Execute("ImportedImageHookFunction("+NewWaveName+")")
   endif
	wave loadedwv=$(NewWaveName)
	NewNote+= "DataFilePath="+S_path+";"
	string TempTimeStr
	sprintf TempTimeStr, "%d", datetime
	NewNote+= "DateTimeComp="+TempTimeStr+";"
	NewNote+=  note(loadedwv)+";"
	if(cmpstr(FileType,"Nexus")==0)
		NVAR NX_Index0Value = root:Packages:Irena_Nexus:NX_Index0Value
		NVAR NX_Index0Max = root:Packages:Irena_Nexus:NX_Index0Max
		NVAR NX_Index1Value = root:Packages:Irena_Nexus:NX_Index1Value
		NVAR NX_Index1Max = root:Packages:Irena_Nexus:NX_Index1Max
		if(NX_Index1Max>0)
			if(NX_Index0Max>0)
				print "Loaded file   " +FileNameToLoad+"  index : _"+num2str(NX_Index0Value)+"_"+num2str(NX_Index1Value)
			else
				print "Loaded file   " +FileNameToLoad+"  index : _"+num2str(NX_Index1Value)
			endif
		endif
	else
		print "Loaded file   " +FileNameToLoad
	endif
	//add wave to the image. 
	wave NewWv=$(NewWaveName)
	note/K NewWv
	note NewWv, newnote

	//add here options to get something done by instrument controls... 
	//this is used by support for ALS RXoXS support
	NVAR/Z UseRSoXSCodeModifications=root:Packages:Nika_RSoXS:UseRSoXSCodeModifications
	if(NVAR_Exists(UseRSoXSCodeModifications))
		if(UseRSoXSCodeModifications&&stringmatch(NewWaveName,"CCDImageToConvert"))
				NI1_RSoXSLoadHeaderValues()
		endif
	endif
	//this has restored proper Dark exposure time data for RSoXS ALS support. 


	setDataFolder OldDf
	
	return LoadedOK
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_MaskHDFLoader(PathName,FileName,FileType,NewWaveName)
	string PathName,FileName,FileType,NewWaveName
#if(exists("HDF5OpenFile")==4)	
	string OldDf=GetDataFOlder(1)
	setDataFOlder root:Packages:Convert2Dto1D
	
	PathInfo $(PathName)
	if(!V_Flag)
		Abort "Path to data set incorrectly" 
	endif
	if(stringmatch(FileName,"*--none--*")||stringmatch(Filetype,"---"))
		Abort 
	endif
	string FileNameToLoad
	string NewNote=""
	string testLine
	variable RefNum, NumBytes
	variable Offset
	string headerStr=""
	FileNameToLoad= FileName
	pathInfo $(PathName)
	string FullFileName=S_Path+FileName
	HDF5OpenFile   /Z RefNum  as FullFileName
	HDF5ListGroup /TYPE=2  RefNum, "/"	//for now lets handle only hdf files with one data set on root level...
	// we will need to develop some kind of panel and more controls here. need test file
	//print S_HDF5ListGroup
	if(ItemsInList(S_HDF5ListGroup)==1)
		HDF5LoadData /O RefNum, (StringFromList(0,S_HDF5ListGroup)) 	
	endif
	HDF5CloseFile  RefNum 
	wave/Z LoadedWvHere=$(StringFromList(0,S_HDF5ListGroup))
	NewNote+="DataFileName="+FileNameToLoad+";"
	NewNote+="DataFileType="+".hdf"+";"

	if(cmpstr(StringFromList(0,S_HDF5ListGroup), NewWaveName)!=0)
		Duplicate/O LoadedWvHere, $(NewWaveName)
	endif
	pathInfo $(PathName) 
	wave loadedwv=$(NewWaveName)
	NewNote+=";"+"DataFilePath="+S_path+";"+note(loadedwv)+";"
	print "Loaded file   " +FileNameToLoad
	wave NewWv=$(NewWaveName)
	note/K NewWv
	note NewWv, newnote
#else
		DoALert 0, "Hdf5 xop not installed, please, run installed version 1.10 and higher and install xops"
#endif 

end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_GBLoaderCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	if(cmpstr(ctrlName,"UseSearchEndTerm")==0)
		SetVariable SkipHeaderBytes,win=NI_GBLoaderPanel, disable=checked
		SetVariable NIGBSearchEndTermInHeader,win=NI_GBLoaderPanel, disable=!checked
		SetVariable NIGBSkipAfterEndTerm,win=NI_GBLoaderPanel, disable=!checked
	endif

End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_GBLoadSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	if(cmpstr(ctrlName,"SkipHeaderBytes")==0)
	
	endif

End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1_GBPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	if(cmpstr(ctrlName,"NIGBImageType")==0)
		SVAR NIGBDataType=root:Packages:Convert2Dto1D:NIGBDataType
		NIGBDataType=popStr
		variable WhichDataType
		if(cmpstr(NIGBDataType,"Double Float")==0 || cmpstr(NIGBDataType,"Single Float")==0)
			WhichDataType=1
		else
			WhichDataType=0
		endif
	//	PopupMenu NIGBByteOrder,win=NI_GBLoaderPanel, disable=WhichDataType
		PopupMenu NIGBFloatDataType,win=NI_GBLoaderPanel, disable=!WhichDataType
	endif
	
	if(cmpstr(ctrlName,"NIGBByteOrder")==0)
		SVAR NIGBByteOrder=root:Packages:Convert2Dto1D:NIGBByteOrder
		NIGBByteOrder=popStr
	endif

End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_GBLoaderPanelFnct() : Panel
	
	DoWindow  NI_GBLoaderPanel
	if(V_Flag)
		DoWindow/F NI_GBLoaderPanel
	else
		
	
		variable WhichDataType
		SVAR NIGBDataType=root:Packages:Convert2Dto1D:NIGBDataType
//		if(cmpstr(NIGBDataType,"Double Float")==0 || cmpstr(NIGBDataType,"Single Float")==0)
//			WhichDataType=1
//		else
//			WhichDataType=0
//		endif
		NVAR NIGBUseSearchEndTerm=root:Packages:Convert2Dto1D:NIGBUseSearchEndTerm
		SVAR NIGBDataType=root:Packages:Convert2Dto1D:NIGBDataType
		SVAR NIGBByteOrder=root:Packages:Convert2Dto1D:NIGBByteOrder
		SVAR NIGBFloatDataType=root:Packages:Convert2Dto1D:NIGBFloatDataType
		PauseUpdate    		// building window...
		NewPanel/K=1 /W=(240,98,644,414)/N=NI_GBLoaderPanel as "General Binary loader config panel"
		//DoWindow/C NI_GBLoaderPanel
		SetDrawLayer UserBack
		SetDrawEnv fsize= 18,fstyle= 3,textrgb= (0,0,65280)
		DrawText 28,36,"Nika General Binary Loader Config"
		SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,0,65280)
		DrawText 141,156,"Image type:"
		CheckBox UseSearchEndTerm,pos={234,54},size={158,14},proc=NI1_GBLoaderCheckProc,title="Use ASCII header terminator?"
		CheckBox UseSearchEndTerm,variable= root:Packages:Convert2Dto1D:NIGBUseSearchEndTerm, help={"Selectm if yo want to search for ASCII terminator of header. 40k of file searched!"}
		SetVariable SkipHeaderBytes,pos={16,53},size={200,16},proc=NI1_GBLoadSetVarProc,title="Skip Bytes :         ", help={"Number of bytes to skip"}
		SetVariable SkipHeaderBytes,value= root:Packages:Convert2Dto1D:NIGBSkipHeaderBytes, disable=NIGBUseSearchEndTerm
		SetVariable NIGBSearchEndTermInHeader,pos={12,86},size={330,16},title="Header terminator ", disable=!NIGBUseSearchEndTerm
		SetVariable NIGBSearchEndTermInHeader,help={"Input ASCII text which ends the ASCII header"}
		SetVariable NIGBSearchEndTermInHeader,value= root:Packages:Convert2Dto1D:NIGBSearchEndTermInHeader
		SetVariable NIGBSkipAfterEndTerm,pos={10,109},size={330,16},title="Skip another bytes after terminator?       "
		SetVariable NIGBSkipAfterEndTerm,value= root:Packages:Convert2Dto1D:NIGBSkipAfterEndTerm, disable=!NIGBUseSearchEndTerm
		SetVariable NIGBNumberOfXPoints,pos={40,164},size={250,16},title="X number of points    ", help={"Size of the data file to load in in X direction"}
		SetVariable NIGBNumberOfXPoints,value= root:Packages:Convert2Dto1D:NIGBNumberOfXPoints
		SetVariable NIGBNumberOfYPoints,pos={40,188},size={250,16},title="Y number of points    ", help={"Size of the data file to load in Y direction"}
		SetVariable NIGBNumberOfYPoints,value= root:Packages:Convert2Dto1D:NIGBNumberOfYPoints
		PopupMenu NIGBImageType,pos={77,213},size={122,21},proc=NI1_GBPopMenuProc,title="Data Type :  "
		PopupMenu NIGBImageType,help={"Select data type :"}
		PopupMenu NIGBImageType,mode=1,popvalue=NIGBDataType,value= #"\"Double Float;Single Float;32 bit signed integer;16 bit signed integer;8 bit signed integer;32 bit unsigned integer;16 bit unsigned integer;8 bit unsigned integer;\""
		PopupMenu NIGBByteOrder,pos={82,240},size={117,21},proc=NI1_GBPopMenuProc,title="Byte order : ", help={"Byte orider - high byte default (Motorola), or low byte first (Intel)"}
		PopupMenu NIGBByteOrder,mode=1,popvalue=NIGBByteOrder,value= #"\"High Byte First;Low Byte First;\""
		PopupMenu NIGBFloatDataType,pos={82,268},size={117,21},proc=NI1_GBPopMenuProc,title="Float type : "//, disable=!WhichDataType
		PopupMenu NIGBFloatDataType,mode=1,popvalue=NIGBFloatDataType,value= #"\"IEEE;VAX;\"", help={"IEEE Floating point or VAX floating point"}
		CheckBox NIGBSaveHeaderInWaveNote,pos={48,292},size={157,14},title="Save Header in Wave note? "
		CheckBox NIGBSaveHeaderInWaveNote,help={"Save all of the ASCII header in wave note?"}
		CheckBox NIGBSaveHeaderInWaveNote,variable= root:Packages:Convert2Dto1D:NIGBSaveHeaderInWaveNote
	endif
EndMacro


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_PilatusLoaderPanelFnct() : Panel
	
	DoWindow  NI_PilatusLoaderPanel
	if(V_Flag)
		DoWindow/F NI_PilatusLoaderPanel
	else
		SVAR PilatusType=root:Packages:Convert2Dto1D:PilatusType
		if(strlen(PilatusType)<2)
			PilatusType="tiff"
		endif
		SVAR PilatusFileType=root:Packages:Convert2Dto1D:PilatusFileType
		SVAR PilatusColorDepth=root:Packages:Convert2Dto1D:PilatusColorDepth
		PauseUpdate    		// building window...
		NewPanel/K=1 /W=(240,98,644,414) as "Pilatus/Eiger loader config panel"
		DoWindow/C NI_PilatusLoaderPanel
		SetDrawLayer UserBack
		SetDrawEnv fsize= 18,fstyle= 3,textrgb= (0,0,65280)
		DrawText 28,36,"Nika Pilatus/Eiger Loader Config"
//		SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,0,65280)
		DrawText 10,250,"Use hook function :  "
		DrawText 10,265,"             PilatusHookFunction(FileNameToLoad)"
		DrawText 10,280,"to add functionality.  Called after loading the file."
		PopupMenu PilatusType,pos={15,70},size={122,21},proc=NI1_PilatusPopMenuProc,title="Detector Type :  "
		PopupMenu PilatusType,help={"Select detector type :"}
		PopupMenu PilatusType,mode=1,popvalue=PilatusType,value= #"\"Pilatus100k;Pilatus300k;Pilatus300k-w;Pilatus1M;Pilatus2M;Pilatus6M;Pilatus3_200k;Eiger500k;Eiger1M;Eiger4M;Eiger9M;Eiger16M;Eiger2_500k;Eiger2_1M;Eiger2_4M;Eiger2_9M;Eiger2_16M;Eiger2_1MW;Eiger2_2MW;\""

		PopupMenu PilatusFileType,pos={15,100},size={122,21},proc=NI1_PilatusPopMenuProc,title="File Type :  "
		PopupMenu PilatusFileType,help={"Select file type :"}
		PopupMenu PilatusFileType,mode=1,popvalue=PilatusFileType,value= #"\"tiff;edf;img;float-tiff;cbf;\""		//cbf removed as it is not working and cannot be tested... 

		PopupMenu PilatusColorDepth,pos={15,130},size={122,21},proc=NI1_PilatusPopMenuProc,title="Color depth :  "
		PopupMenu PilatusColorDepth,help={"Color depth (likely 32) :"}
		PopupMenu PilatusColorDepth,mode=1,popvalue=PilatusColorDepth,value= #"\"8;16;32;64;FLOAT;\""
		
		Button PilatusSetDefaultPars, pos={15,160}, size={250,20}, title="Set default device values", proc=NI1_Pilatus_ButtonProc
		Button PilatusSetDefaultPars, help={"Use this to set default pixel size"}

		CheckBox PilatusSignedData,pos={220,134},size={158,14},noproc,title="UnSigned integers?"
		CheckBox PilatusSignedData,variable= root:Packages:Convert2Dto1D:PilatusSignedData, help={"Are the stored data signed integer? "}
		CheckBox PilatusReadAuxTxtHeader,pos={15,190},size={158,14},noproc,title="Read Auxiliary txt file (ALS)?"
		CheckBox PilatusReadAuxTxtHeader,variable= root:Packages:Convert2Dto1D:PilatusReadAuxTxtHeader, help={"For ALS, try to read data from auxiliarty txt file "}
	endif
EndMacro
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_Pilatus_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			SVAR PilatusType=root:Packages:Convert2Dto1D:PilatusType
			NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX
			NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY
			if(StringMatch(PilatusType, "Pilatus*"))
				PixelSizeX = 0.172
				PixelSizeY=0.172
			elseif(StringMatch(PilatusType, "Eiger*"))
				PixelSizeX = 0.075
				PixelSizeY=0.075
			else
				PixelSizeX = 1
				PixelSizeY=1
			endif
			NVAR SelectedUncertainity = root:Packages:IrenaConfigFolder:SelectedUncertainity
			NVAR ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
			NVAR ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
			NVAR ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
			ErrorCalculationsUseOld = 0
			ErrorCalculationsUseStdDev=0
			ErrorCalculationsUseSEM=1
			SelectedUncertainity=2			//Set to SEM
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1_PilatusPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	if(cmpstr(ctrlName,"PilatusType")==0)
		SVAR PilatusType=root:Packages:Convert2Dto1D:PilatusType
		PilatusType=popStr
	endif
	if(cmpstr(ctrlName,"PilatusFileType")==0)
		SVAR PilatusFileType=root:Packages:Convert2Dto1D:PilatusFileType
		PilatusFileType=popStr
	endif
	if(cmpstr(ctrlName,"PilatusColorDepth")==0)
		SVAR PilatusColorDepth=root:Packages:Convert2Dto1D:PilatusColorDepth
		if(stringmatch("64",popstr))
			Abort "64 bit color depth is not supported on Igor, please contact author and provide example data to test"
		endif
		PilatusColorDepth=popStr
	endif
End


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1_ReadBrukerCCD_SMARTFile(FileToOpen, NewWaveName)	//returns wave with image in the current data folder, temp folder is deleted
	String FileToOpen
	String NewWaveName		
	
	//this is loader for Bruker (Siemens) CCD files produced by SMART program
	//modified from code provided by Jeff Grothaus-JT/PGI@PGI, grothaus.jt@pg.com  8/2004
	//Jan Ilavsky, 8/2004
	//The file format is following:
	// 1	ASCII header with a lot of information rarely used, read size (n x n) and number of bytes used
	// 2 	Binary data in either 8 or 16 bit size for n x n pixles 
	// 3 	overfolow pixles table - contains intensity and addresses for pixles, whose intensity was higher than fit in the 8 or 16 bits binary data

	if(strlen(NewWaveName)==0)
		Abort "Bad NewWaveName passed to ReadBrukerCCD_SmartFile routine"
	endif
	String DescriptionFromInput=""

	string OldDf=GetDataFolder(1)
	setDataFolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:BrukerImport 
	
	Variable fileID
	String FileData
	Variable StartOfImage			//header padded to multiple of 512 bytes: HDRBLKS * 512
	Variable SizeOfImage 			//in the real thing get this from the header ncols * nrows
	Variable StartOfOverflowTable 		//=SizeOfImage + Size of header
	Variable NumberOfOverflows    		//NOVERFL
	Variable SizeOfOverflowTable 		//noverfl * 16 chars per entry + 1
	Variable BytesPerPixel 			//get from NPIXELB
	Variable Timer
	Variable ElapsedTime
	String Center
	Variable pos
	Variable NumHeaderBlocks
	Variable NumHeaderElements	
	String CheckString
	String msgStr
	String DataName
	String XYDataName
	String NewFolderPath		//new data folder for this data set
	Variable NumCols
	Variable NumRows
	Variable SampDetDist		//DISTANC sample to detector in cm
	Variable Xcenter
	Variable Ycenter
	Variable BinFactor = 1
	String Description					//First line named TITLE
	String CreateDate		//CREATED, date & time file was created
	String FileType = "Bruker/Siemens SMART"
	
//Set description to input description
	Description = DescriptionFromInput

	Open /R /T="????" fileID  as FileToOpen
	FStatus fileID
//make sure file exists, it ought to...
	If(!V_Flag)
		print "File: " + S_Path + S_fileName + " doesn't exist."
			setDataFolder OldDf
			abort
	EndIf
//make sure that this really is a Siemens file.  Seems like first 18 bytes of file should read FORMAT:  86.
	FSetPos FileID, 0
	FReadLine /N=18 FileID, CheckString
//may be necessary to add code (and another input variable to function definition) so that this message
//does not choke a multifile open operation.  If multifile open is in progress write message to history area 
//and continue.
	If(!Stringmatch(CheckString, "FORMAT :        86"))		//8 spaces between colon and 86
		msgStr = "The first character in the file does not seem correct for a Siemens 2D data file. ... 'Yes' to continue or 'No' to quit."
		DoAlert 1, msgStr
		If (V_Flag == 2) 	//DoAlert sets V_flag, = 2 quit; = 1 continue
			setDataFolder OldDf
			abort
		EndIf
	EndIf

//get number of entrees in header.  The third header element, HDRBLKS indicates the  
//number of 512 byte blocks in header.  As of 5/1999 this is 15 blocks which is 96 header
//elements: 15 * 512 / 80.  If this routine fails, a default of 15 blocks is used.
	FSetPos FileID, 160		//third element in header starts here
	FReadLine /N=18 FileID, CheckString
	pos = strsearch(CheckString, "HDRBLKS:", 0)
	If(pos >= 0)
		CheckString = CheckString[pos + 8, strlen(CheckString)] 	//remove characters
		NumHeaderBlocks = str2num(CheckString)
	Else
		NumHeaderBlocks = 15		//default, this is the current standard 5/1999.
	EndIf
	NumHeaderElements = floor(NumHeaderBlocks * 512 / 80) 	//convert to number of header lines, 96 as of 5/1999
	DataName = NewWaveName
	Make /O /T /N=(NumHeaderElements, 2) SiemensHeader
	SiemensHeader = ""

	Variable HeaderLine = 0
	FSetPos FileID, 0
	Do
		FReadLine /N=80 fileID, FileData
		If(char2num(FileData) == 26)	//control-z, end of header marker
			break
		EndIf
		SiemensHeader[HeaderLine][0] = FileData[0,6]		//Variable Name
		SiemensHeader[HeaderLine][1] = FileData[8,79]		//Variable Contents
		HeaderLine += 1
	While (HeaderLine < NumHeaderElements)
//Load variables from header:
	NumRows = str2num(NI1_GetHeaderVal("NROWS", SiemensHeader))		//Number of rows
	NumCols = str2num(NI1_GetHeaderVal("NCOLS", SiemensHeader))			//Number of columns
	BytesPerPixel = str2num(NI1_GetHeaderVal("NPIXELB", SiemensHeader))	//Number of bytes per pixel
	CreateDate = (NI1_GetHeaderVal("CREATED", SiemensHeader))
	SampDetDist  = str2num(NI1_GetHeaderVal("DISTANC", SiemensHeader))
	Center = (NI1_GetHeaderVal("CENTER", SiemensHeader))
	Xcenter = str2num(Center)
	Ycenter = NumCols - str2num(Center[17,strlen(Center)])	//Siemens refs vs lower left, we do upper left corner
	NumberOfOverflows = str2num(NI1_GetHeaderVal("NOVERFL", SiemensHeader))	//Number of pixel overflows
	SizeOfOverflowTable = NumberOfOverflows * 16 + 1		//noverfl * 16 chars per entry
//Now only use description passed through DescriptionFromInput
	StartOfImage = NumHeaderBlocks * 512	//512 bytes per header block.
	SizeOfImage = NumRows * NumCols

//get image data
	Make /O /N=(SizeOfImage) ImageData
	ImageData = 0
	FSetPos FileID, StartOfImage
	Variable ImagePixel = 0
	Variable ImageDataPixel
	FBinRead /F=(BytesPerPixel) /U FileID, ImageData

//--------------------------------overflow table routine-----------------------------------
//if NumberOfOverflows is greater than zero, then load overflow table and add back to data
//otherwise skip this and continue with cleanup
	If(NumberOfOverflows > 0)
		StartOfOverflowTable = StartOfImage + SizeOfImage*BytesPerPixel
		FSetPos FileID, StartOfOverflowTable
	
		make /O/N=(NumberOfOverflows,2)  OverflowTable
		OverflowTable = 0
		variable oftInc = 0
		Do
			FReadLine /N=9 fileID, FileData
			OverflowTable[oftInc][0] = str2num(FileData)
			FReadLine /N=7 fileID, FileData
			OverflowTable[oftInc][1] = str2num(FileData)
			oftInc += 1
		While (oftInc <NumberOfOverflows)
		//add back overflow table
		oftInc = 0
		make /O /N=(NumberOfOverflows,3) oftcheck
		oftcheck = 0
		Variable DataPixel
	Do
		DataPixel = OverflowTable[oftInc][1]
		oftcheck[oftInc][0] = DataPixel
		oftcheck[oftInc][1] =  OverflowTable[oftInc][0]
		oftcheck[oftInc][2] = ImageData[DataPixel]
		ImageData[DataPixel] = OverflowTable[oftInc][0]
		oftInc += 1
		While (oftInc < NumberOfOverflows)
	EndIf
//--------------------------------overflow table routine-----------------------------------

//now that overflows have been added into the data set, convert image data to 2dim data set
	Redimension /U /N=(NumCols,NumRows) ImageData
	
	Close fileID
	string NewWaveNote=""
	NewWaveNote+="NumCols:"+num2str(NumCols)+";"
	NewWaveNote+="NumRows:"+num2str(NumRows)+";"
	NewWaveNote+="Xcenter:"+num2str(Xcenter)+";"
	NewWaveNote+="Ycenter:"+num2str(Ycenter)+";"
	NewWaveNote+="SampDetDist:"+num2str(SampDetDist)+";"
	NewWaveNote+="BinFactor:"+num2str(BinFactor)+";"
	NewWaveNote+="Description:"+Description+";"
	NewWaveNote+="CreateDate:"+CreateDate+";"
	NewWaveNote+="FileType:"+FileType+";"
	variable i
	For(i=0;i<numpnts(SiemensHeader);i+=1)
		NewWaveNote=ReplaceStringByKey(NI1_RemoveLeadTermSpaces(SiemensHeader[0][i]), NewWaveNote, NI1_RemoveLeadTermSpaces(SiemensHeader[1][i]), ":", ";")
	endfor
	note ImageData, NewWaveNote
	setDataFolder OldDf
	Duplicate/O 	ImageData, $(NewWaveName)
	KillWaves /Z OverflowTable, oftCheck, ImageData, SiemensHeader
	KillDataFolder root:Packages:BrukerImport
	
	return 1
	
End


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


static Function/S NI1_GetHeaderVal(HeadVar, SiemensHeader)
	String HeadVar
	Wave /T SiemensHeader
	Variable NumEntries = DimSize(SiemensHeader, 0)
	
	Variable inc = 0
	Variable pos
	Do
		pos = strsearch(SiemensHeader[inc][0], HeadVar, 0)
		If (pos >= 0)
			return SiemensHeader[inc][1]
		EndIf
		inc += 1
	While (inc < NumEntries)
	
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


static Function/S NI1_RemoveLeadTermSpaces(InputStr)	//removes leading and terminating spaces from string
	String InputStr
	
	string OutputStr=InputStr
	variable i
	for(i=strlen(OutputStr)-1;i>0;i-=1)	//removes terminating spaces
		if(cmpstr(OutputStr[i]," ")==0)
			OutputStr=OutputStr[0,i-1]
		else
			break	
		endif
	endfor
	if((cmpstr(OutputStr[0]," ")==0))
		Do
			OutputStr = OutputStr[1,inf]
		while (cmpstr(OutputStr[0]," ")==0)
	endif

	return OutputStr	
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


static Function/S NI1_FITSFindKey(WaveNoteStr,KeyStr)
	string WaveNoteStr,KeyStr

		variable startVal=0
		if(stringmatch(KeyStr, "BITPIX"))
			startVal = 120		//this seems to be there twice for some reason... 
		endif
		string testStr=WaveNoteStr[strsearch(WaveNoteStr, KeyStr, startVal ),strsearch(WaveNoteStr, "/", strsearch(WaveNoteStr, KeyStr, startVal ) )]
		testStr=ReplaceString("/", testStr, "")
		testStr=ReplaceString(" ", testStr, "")+";"
//print testStr		
		string ResultStr=StringByKey(KeyStr, testStr , "=")
		return ResultStr
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************



structure  RigakuHeader
	char DeviceName[10]
	char Version[10]
	char CrystalName[20]
	char CrystalSystem[12]
	float LatticeA  
	float LatticeB 
	float LatticeC  
	float LatticeAlpha  
	float LatticeBeta 
	float LatticeGamma  
	char SpaceGroup[12]
	float MosaicSpread  
	char Memo[80]
	char Reserve[84]

	char Date_[12]
	char MeasurePerson[20]
	char Xraytarget[4]
	float Wavelength  
	char Monochromator[20]
	float MonocromatorDq  
	char Collimator[20]
	char Filter[4]
	float CameraLength_mm  
	float XrayTubeVoltage  
	float XrayTubeCurrent
	char XrayFocus[12]
	char XrayOptics[80]
	int32 CameraShape	
	float WeissenbergOscillation
	char Reserve2[56]

	char MountAxis[4]
	char BeamAxis[4]
	float something7
	float StartSomething 
	float EndSomething
	int32 TimesOfOscillation
	float ExposureTime
	float DirectBeamPositionX
	float DirectBeamPositionY
	float Something8 
	float Something9
	float Something10
	float Something11
	char Reserve3[100]
	char Reserve3a[100]
	char Reserve3b[4]

	int32 xDirectionPixNumber
	int32 yDirectionPixNumber
	float xDirectionPixelSizeMM
	float yDirectionPixelSizeMM
	int32 RecordLengthByte
	int32 NumberOfRecord
	int32 ReadStartLine
	int32 IPNumber
	float OutPutRatioHighLow
	float FadingTime1
	float FadingTime2
	char HostComputerClass[10]
	char IPClass[10]
	int32 DataDirectionHorizontal
	int32 DataDirectionVertical
	int32 DataDirectionFrontBack

	float shft	//;         /* pixel shift, R-AXIS V */
	float ineo	//;         /* intensity ratio E/O R-AXIS V */
	int32  majc	//;         /* magic number to indicate next values are legit */
       int32  naxs	//;         /* Number of goniometer axes */
	float gvec1[5]//;   /* Goniometer axis vectors */
	float gvec2[5]//;   /* Goniometer axis vectors */
	float gvec3[5]//;   /* Goniometer axis vectors */
	float gst[5]//;       /* Start angles for each of 5 axes */
       float gend[5]//;      /* End angles for each of 5 axes */
       float goff[5]//;      /* Offset values for each of 5 axes */ 
       int32  saxs//;         /* Which axis is the scan axis? */
	char  gnom[40]//;     /* Names of the axes (space or comma separated?) */
//
///*
// * Most of below is program dependent.  Different programs use
// * this part of the header for different things.  So it is essentially 
// * a big "common block" area for dumping transient information.
// */
   char  file[16]//;     /* */
   char  cmnt[20]//;     /* */
   char  smpl[20]//;     /* */
   int32  iext//;         /* */
   int32  reso//;         /* */
   int32  save_//;         /* */
   int32  dint//;         /* */
   int32  byte//;         /* */
   int32  init//;         /* */
   int32  ipus//;         /* */
   int32  dexp//;         /* */
   int32  expn//;         /* */
   int32  posx[20]//;     /* */
   int32  posy[20]//;     /* */
   int16   xray//;         /* */
   char  res51[100]//;    /* reserved space for future use */
   char  res52[100]//;    /* reserved space for future use */
   char  res53[100]//;    /* reserved space for future use */
   char  res54[100]//;    /* reserved space for future use */
   char  res55[100]//;    /* reserved space for future use */
   char  res56[100]//;    /* reserved space for future use */
   char  res57[100]//;    /* reserved space for future use */
   char  res58[68]//;    /* reserved space for future use */
//
	
endstructure


structure  RigakuHeaderOld	//this is header acording to older document. It seems like Rigaku itself has no sense in this... 
	char DeviceName[10]
	char Version[10]
	char CrystalName[20]
	char CrystalSystem[12]
	float LatticeA  
	float LatticeB 
	float LatticeC  
	float LatticeAlpha  
	float LatticeBeta 
	float LatticeGamma  
	char SpaceGroup[12]
	float MosaicSpread  
	char Memo[80]
	char Reserve[84]

	char Date_[12]
	char MeasurePerson[20]
	char Xraytarget[4]
	float Wavelength  
	char Monochromator[20]
	float MonocromatorDq  
	char Collimator[20]
	char Filter[4]
	float CameraLength_mm  
	float XrayTubeVoltage  
	float XrayTubeCurrent
	char XrayFocus[10]			//note, first change between Rigaku header and RigakuheaderOld 
	char XrayOptics[80]
//	int32 CameraShape	
//	float WeissenbergOscillation
//	char Reserve2[56]
	char Reserve2[66]

	char MountAxis[4]
	char BeamAxis[4]
	float something7
	float StartSomething 
	float EndSomething
	int32 TimesOfOscillation
	float ExposureTime
	float DirectBeamPositionX
	float DirectBeamPositionY
	float Something8 
	float Something9
	float Something10
	float Something11
	char Reserve3[100]
	char Reserve3a[100]
	char Reserve3b[4]

	int32 xDirectionPixNumber
	int32 yDirectionPixNumber
	float xDirectionPixelSizeMM
	float yDirectionPixelSizeMM
	int32 RecordLengthByte				
	int32 NumberOfRecord
	int32 ReadStartLine
	int32 IPNumber
	float OutPutRatioHighLow
	float FadingTime1
	float FadingTime2
	char HostComputerClass[10]
	char IPClass[10]
	int32 DataDirectionHorizontal
	int32 DataDirectionVertical
	int32 DataDirectionFrontBack

	char   reserve4[100]
	char   reserve4a[80]
	//and these were created in the reserve?
//	float shft	//;         /* pixel shift, R-AXIS V */
//	float ineo	//;         /* intensity ratio E/O R-AXIS V */
//	int32  majc	//;         /* magic number to indicate next values are legit */
//       int32  naxs	//;         /* Number of goniometer axes */
//	float gvec1[5]//;   /* Goniometer axis vectors */
//	float gvec2[5]//;   /* Goniometer axis vectors */
//	float gvec3[5]//;   /* Goniometer axis vectors */
//	float gst[5]//;       /* Start angles for each of 5 axes */
//       float gend[5]//;      /* End angles for each of 5 axes */
//       float goff[5]//;      /* Offset values for each of 5 axes */ 
//       int32  saxs//;         /* Which axis is the scan axis? */
//	char  gnom[40]//;     /* Names of the axes (space or comma separated?) */
//
///*
// * Most of below is program dependent.  Different programs use
// * this part of the header for different things.  So it is essentially 
// * a big "common block" area for dumping transient information.
// */
   char  file[16]//;     /* */
//   char  cmnt[20]//;     /* */
//  char  smpl[20]//;     /* */
   int32  iext//;         /* */
   int32  reso//;         /* */
   int32  save_//;         /* */
   int32  dint//;         /* */
   int32  byte//;         /* */
//   int32  init//;         /* */
//   int32  ipus//;         /* */
//   int32  dexp//;         /* */
//   int32  expn//;         /* */
//   int32  posx[20]//;     /* */
//   int32  posy[20]//;     /* */
//   int16   xray//;         /* */
   char  res51[100]//;    /* reserved space for future use */
   char  res52[100]//;    /* reserved space for future use */
   char  res53[100]//;    /* reserved space for future use */
   char  res54[100]//;    /* reserved space for future use */
   char  res55[100]//;    /* reserved space for future use */
   char  res56[100]//;    /* reserved space for future use */
   char  res57[100]//;    /* reserved space for future use */
   char  res58[100]//;    /* reserved space for future use */
   char  res59[100]//;    /* reserved space for future use */
   char  res60[56]//;    /* reserved space for future use */
//
	
endstructure


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


static Function/T NI1A_ReadRigakuUsingStructure(PathName, FileNameToLoad)
		string PathName, FileNameToLoad
		
		string Headerline

		variable RefNum
		string testline
		variable testvar
		STRUCT RigakuHeader RH
		STRUCT RigakuHeaderOld RHOld
		open /R/P=$(PathName) RefNum as FileNameToLoad
		FBinRead/b=2 RefNum, RH
		close RefNum
		
	string NewKWList=""
//1 	Device Name 	Character 	10 	10
	NewKWList+= "Device Name:"+RH.DeviceName +";" 
////2 	Version 	Character 	10 	20
	NewKWList+= "Version:"+RH.Version+";" //	char Version[10]
////3 	Crystal name 	Character 	20 	40
	NewKWList+= "CrystalName:"+RH.CrystalName+";"//	char CrystalName[20]
////4 	Crystal system 	Character 	12 	52
	NewKWList+= "CrystalSystem:"+RH.CrystalSystem+";"//	char CrystalSystem[12]
////5 	ÇÅÅiÅÅj 	Real Number 	4 	56
	NewKWList+= "LatticeA:"+num2str(RH.LatticeA)+";"//	float LatticeA  
////6 	ÇÇÅiÅÅj 	Real Number 	4 	60
	NewKWList+= "LatticeB:"+num2str(RH.LatticeB)+";"//	float LatticeB 
///////7 	ÇÉÅiÅÅj 	Real Number 	4 	64
	NewKWList+= "LatticeC:"+num2str(RH.LatticeC)+";"//	float LatticeC  
//////8 	Éø 	Real Number 	4 	68
	NewKWList+= "LatticeAlpha:"+num2str(RH.LatticeAlpha)+";"//	float LatticeAlpha  
////////9 	É¿ 	Real Number 	4 	72
	NewKWList+= "LatticeBeta:"+num2str(RH.LatticeBeta)+";"//	float LatticeBeta  
//////10 	É¡ 	Real Number 	4 	76
	NewKWList+= "LatticeGamma:"+num2str(RH.LatticeGamma)+";"//	float LatticeGamma  
//////11 	Space group 	Character 	12 	88
	NewKWList+= "SpaceGroup:"+RH.SpaceGroup+";"//	char SpaceGroup[12]
//////12 	Mosaic spread 	Real Number 	4 	92
	NewKWList+= "MosaicSpread:"+num2str(RH.MosaicSpread)+";"//	float MosaicSpread  
//////13 	Memo 	Character 	80 	172

	NewKWList+= "Memo:"+RH.Memo+";"//	char Memo[80]
//////14 	Reserve 	Character 	84 	256
//	char Reserve[84]
//////15 	Date 	Character 	12 	268
	NewKWList+= "Date:"+RH.Date_+";"//	char Date_[12]
//////16 	Measure Person 	Character 	20 	288
	NewKWList+= "MeasurePerson:"+RH.MeasurePerson+";"//	char MeasurePerson[20]
//////17 	X-ray Target 	Character 	4 	292
	NewKWList+= "Xraytarget:"+RH.Xraytarget+";"//	char Xraytarget[4]
//////18 	Wavelength 	Real Number 	4 	296
	NewKWList+= "Wavelength:"+num2str(RH.Wavelength)+";"//	float Wavelength  
//////19 	Monochrometer Å@Å@ 	Character 	20 	316
	NewKWList+= "Monochromator:"+RH.Monochromator+";"//	char Monochromator[20]
//////20 	MonochromeÇQÉ∆ÅiÅãÅj 	Real Number 	4 	320
	NewKWList+= "MonocromatorDq:"+num2str(RH.MonocromatorDq)+";"//	float MonocromatorDq  
//////21 	Collimeter 	Character 	20 	340
	NewKWList+= "Collimator:"+RH.Collimator+";"//	char Collimator[20]
//////22 	ÇjÉ¿ Filter 	Character 	4 	344
	NewKWList+= "v:"+RH.Filter+";"//	char Filter[4]
//////23 	Camera Length (mm) 	Real Number 	4 	348
	NewKWList+= "CameraLength_mm:"+num2str(RH.CameraLength_mm)+";"//	float CameraLength_mm  
//////24 	X-ray Pipe VolgageÅ@ 	Real Number 	4 	352
	NewKWList+= "XrayTubeVoltage:"+num2str(RH.XrayTubeVoltage)+";"//	float XrayTubeVoltage  
//////25 	X-ray  Electric Current 	Real Number 	4 	356
	NewKWList+= "XrayTubeCurrent:"+num2str(RH.XrayTubeCurrent)+";"//	float XrayTubeCurrent
//////26 	X-ray Focus 	Character 	12 	368
	NewKWList+= "XrayFocus:"+RH.XrayFocus+";"//	char XrayFocus[12]
//////27 	X-ray Optics 	Character 	80 	448
	NewKWList+= "XrayOptics:"+RH.XrayOptics+";"//	char XrayOptics[80]
//////28 	Camera Shape 	Integer 	4 	0:flat   452
	NewKWList+= "CameraShape:"+num2str(RH.CameraShape)+";"//	int32 CameraShape	
//////29 	Weissenberg Oscillation 	Real Number 	4   456	
	NewKWList+= "WeissenbergOscillation:"+num2str(RH.WeissenbergOscillation)+";"//	float WeissenbergOscillation
//////30 	Reserve 	Character 	56 	512
//	char Reserve2[56]
//////31 	Mount Axis 	Character 	4 	Å}reciprocal lattice axis		516
	NewKWList+= "MountAxis:"+RH.MountAxis+";"//	char MountAxis[4]
//////32 	Beam Axis 	Character 	4 	Å}lattice axis					520
	NewKWList+= "BeamAxis:"+RH.BeamAxis+";"//	char BeamAxis[4]
//////33 	É”0 	Real Number 	4 								524
//	float something7
////34 	É” Start 	Real Number 	4 			528
//	float StartSomething 
////35 	É” End 	Real Number 	4 	
//	float EndSomething
////36 	Times of Oscillation 	Integer 	4 	
//	int32 TimesOfOscillation
////37 	Exposure Time (minutes) 	Real Number 	4 	
	NewKWList+= "ExposureTime:"+num2str(RH.ExposureTime)+";"//	float ExposureTime
////38 	Direct Beam Position (x) 	Real Number 	4 	
	NewKWList+= "DirectBeamPositionX:"+num2str(RH.DirectBeamPositionX)+";"//	float DirectBeamPositionX
////39 	Direct Beam Position (y) 	Real Number 	4 	
	NewKWList+= "DirectBeamPositionY:"+num2str(RH.DirectBeamPositionY)+";"//	float DirectBeamPositionY
////40 	É÷ÅiÉ∆Åj 	Real Number 	4 	
//	float Something8 
////41 	É‘ 	Real Number 	4 	
//	float Something9
////42 	ÇQÉ∆ 	Real Number 	4 	
//	float Something10
////43 	É  	Real Number 	4 	
//	float Something11
////44 	Reserve 	Character 	180 	
//	char Reserve3[100]
//	char Reserve3a[80]
////45 	x Direction Pixel Number 	Integer 	4 	
	NewKWList+= "xDirectionPixNumber:"+num2str(RH.xDirectionPixNumber)+";"//	int32 xDirectionPixNumber
////46 	y Direction Pixel Number 	Integer 	4 	
	NewKWList+= "yDirectionPixNumber:"+num2str(RH.yDirectionPixNumber)+";"//	int32 yDirectionPixNumber
////47 	x Direction Pixel Size (mm) 	Real Number 	4 	
	NewKWList+= "xDirectionPixelSizeMM:"+num2str(RH.xDirectionPixelSizeMM)+";"//	float xDirectionPixelSizeMM
////48 	y Direction Pixel Size (mm) 	Real Number 	4 	
	NewKWList+= "yDirectionPixelSizeMM:"+num2str(RH.yDirectionPixelSizeMM)+";"//	float yDirectionPixelSizeMM
////49 	Record Length (Byte) 	Integer 	4 	
	NewKWList+= "RecordLengthByte:"+num2str(RH.RecordLengthByte)+";"//	int32 RecrodLengthByte
////50 	Number of Record 	Integer 	4 	
	NewKWList+= "NumberOfRecord:"+num2str(RH.NumberOfRecord)+";"//	int32 NumberOfRecord
////51 	Read Start Line 	Integer 	4 	
	NewKWList+= "ReadStartLine:"+num2str(RH.ReadStartLine)+";"//	int32 ReadStartLine
////52 	IP Number 	Integer 	4 	
	NewKWList+= "IPNumber:"+num2str(RH.IPNumber)+";"//	int32 IPNumber
////53 	Output Ratio (High/Low) 	Real Number 	4 	
	NewKWList+= "OutPutRatioHighLow:"+num2str(RH.OutPutRatioHighLow)+";"//	float OutPutRatioHighLow
////54 	Fading Time 1 	Real Number 	4 	Time to exposure completion to Read Start
	NewKWList+= "FadingTime1:"+num2str(RH.FadingTime1)+";"//	float FadingTime1
////55 	Fading Time 2 	Real Number 	4 	Time to exposure completion to Read End
	NewKWList+= "FadingTime2:"+num2str(RH.FadingTime2)+";"//	float FadingTime2
////56 	Host Computer Classification	Character 	10 	
	NewKWList+= "HostComputerClass:"+RH.HostComputerClass+";"//	char HostComputerClass[10]
////57 	IP Classification 	Character 	10 	
	NewKWList+= "IPClass:"+RH.IPClass+";"//	char IPClass[10]
////58 	Data Direction (horizontal direction) 	Integer 	4 	0: From Left to Right, 1: From Right to Left
	NewKWList+= "DataDirectionHorizontal:"+num2str(RH.DataDirectionHorizontal)+";"//	int32 DataDirectionHorizontal
////59 	Data Direction (vertical direction) 	Integer 	4 	0: From Down to Up,1: Up to Down
	NewKWList+= "DataDirectionVertical:"+num2str(RH.DataDirectionVertical)+";"//	int32 DataDirectionVertical
////60 	Data Direction (front and back) 	Integer 	4 	0:Front1:Back
	NewKWList+= "DataDirectionFrontBack:"+num2str(RH.DataDirectionFrontBack)+";"//	int32 DataDirectionFrontBack
////61 	Reserve 	Character 	10 	
	NewKWList+= "Byte:"+num2str(RH.byte)+";"//	int32 byte = is this endiness???
//	char Reserve4[10]
//
//print "NewRigakuHeader"
	variable newRecordLengt =  RH.RecordLengthByte
	variable NewOutputRatioHighLow =  RH.OutputRatioHighLow
		open /R/P=$(PathName) RefNum as FileNameToLoad
		FBinRead/b=2 RefNum, RHOld
		close RefNum
//print "OldRigakuHeader"
	variable oldRecordLengt =   RHOld.RecordLengthByte
	variable oldOutputRatioHighLow =   RHOld.OutputRatioHighLow

	if(newRecordLengt!=oldRecordLengt || NewOutputRatioHighLow!=oldOutputRatioHighLow)
		NVAR/Z RigakuRaxisHeaderWarning
		if(!NVAR_Exists (RigakuRaxisHeaderWarning))
			variable/g RigakuRaxisHeaderWarning
			DoAlert 0, "This Rigaku file has problem with header parameters reading, please send example of this file to author with some meaningful descrition"
		endif
	endif
	if(Rh.byte>0 || RHold.byte>0 )
		NVAR/Z RigakuRaxisHeaderWarning2
		if(!NVAR_Exists (RigakuRaxisHeaderWarning2))
			variable/g RigakuRaxisHeaderWarning2
			DoAlert 0, "This Rigaku file has byte set in the header. It may have different endiness. Please, send example to author and include descrition of file source"
		endif
	endif
	
	
	return NewKWList
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


static Function NI1A_RigakuFixNegValues(w,ratio)
	wave w
	variable ratio
	
	//string tempName=NameOfWave(w)
	w = w[p][q]>0? w[p][q] : abs(W[p][q]) * ratio

end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

structure  RigakuReadByte
	int32 TestByte
endstructure

Function NI1A_FindFirstNonZeroChar(PathName, FileNameToLoad)
	string PathName, FileNameToLoad

		STRUCT RigakuReadByte RH
		variable RefNum
		open /R/P=$(PathName) RefNum as FileNameToLoad
		FsetPos  RefNum, 2000
//		FsetPos  RefNum, 0
		
		Do
			FBinRead/b=2 RefNum, RH
		while (RH.TestByte <=0)
		FStatus RefNum
		close RefNum
		return V_filePos

end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_LoadWinViewFile(fName, NewWaveName)
	String fName											// fully qualified name of file to open
	String NewWaveName		

//	Variable refNum
//	if (strlen((OnlyWinFileName(fName)))<1)				// call dialog if no file name passed
//		Open /D/M=".spe file"/R/T="????" refNum		// use /D to get full path name
//		fName = S_filename
//	endif
//	if (strlen(fName)<1)									// no file name, quit
//		return ""
//	endif

	String wName = NI1_WinViewReadROI(fName,0,-1,0,-1)	// load file into wName
	if (strlen(wName)<1)
		return 0
	endif
	Wave/Z image = $wName
	variable LoadedOK
		if(WaveExists(image))
			LoadedOK=1
		endif

		String wnote = note(image)
		Variable xdim=NumberByKey("xdim", wnote,"=")
		Variable ydim=NumberByKey("ydim", wnote,"=")
		String bkgFile = StringByKey("bkgFile", wnote,"=")
		printf "for file '"+fName+"'"
		if (strlen(bkgFile)>0)
			printf ",             background file = '%s'",  bkgFile
		endif
		printf "\r"
		printf "total length = %d x %d  = %d points\r", xdim,ydim,xdim*ydim
		print "number type is  '"+NI1_WinViewFileTypeString(NumberByKey("numType", wnote,"="))+"'"
//		print "Created a 2-d wave    '"+wName+"'"
//		DoAlert 1, "Display this image"
//		if (V_Flag==1)
//			Graph_imageMake(image,NaN)
//		endif
		duplicate/O image, $(NewWaveName)
		killwaves image
//	endif
//	return GetWavesDataFolder(image,2)
	return LoadedOK
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//modified 2022-11-06 to handle 1st 2-3D data set in the file, difficult to support more flexible method. 

Function/S NI2_LoadGeneralHDFFile(CalledFrom, fileName, PathName, NewWaveName)
	string CalledFrom,  fileName, PathName, NewWaveName
	
	string oldDf=GetDataFolder (1)
	//2022-11-06 fix loading, make simple - load everything in temp folder, find first 2D data set, assume it is data copy where needed and dump the temp folder data. 
	string Status=""

#if Exists("HDF5OpenFile")	
	//Need to create temp folder to handle the whole group of stuff here...
	setDataFolder root:Packages:
	NewDataFolder/O/S root:Packages:TempHDFLoad
	KillWaves/A/Z												//clean the folder up
	PathInfo/S $(PathName)									//find the path to data file
	Status = H5GW_ReadHDF5("root:Packages:TempHDFLoad", S_path+Filename)
	if(strlen(Status)>0)
		print "HDF5 import failed, message: "+Status		//if not "" then error ocured, Handle somehow!
		return ""
	endif
	String base_name = StringFromList(0,FileName,".")			//part of the name without extension - assumes only one "." in name, same as H5GW reader used. 
	//now we have folder with data in root:Packages:TempHDFLoad:$(Filename) But without the extension... 
	//let's find first 2D data set here...
	SetDataFolder $("root:Packages:TempHDFLoad:"+base_name)					//this is where the hdf5 data now are in Igor
	string ListOf2DData = IN2G_Find2DDataInFolderTree(GetDataFolder(1))	//this finds all 2-3D waves in this location. 
	setDataFolder OldDf
	//now we have list of 2D waves - or 3D waves as HDF5 waves are written as 1xNxM...
	//Let's pick the first one, no idea if it is right but how to figure this out? 
	//Need to check if we even found anything first...
	if(ItemsInList(ListOf2DData,";")<1)
		Print ">>>>  No 2D data set found in "+S_path+Filename+" data file. \rNOTE: Igor 8 seems unable to load data written as 64 bit integers. "
		abort
	endif
	Wave Found2DWave = $(StringFromList(0,ListOf2DData))
	//now we need to fix this from 3D (1xNxM) to 2D (NxM) waves
	Duplicate/O Found2DWave, $(NewWaveName)
	wave Nika2DWave=$(NewWaveName)
	if(WaveDims(Nika2DWave)>2)
		variable D0, D1,D2
		D0=DimSize(Nika2DWave, 0)
		D1=DimSize(Nika2DWave, 1)
		D2=DimSize(Nika2DWave, 2)
		if(D0==1)
			Redimension /N=(D1, D2) Nika2DWave
		elseif(D2==1)
			Redimension /N=(D0, D1) Nika2DWave
		endif
		
	endif
	KillDataFolder/Z root:Packages:TempHDFLoad
	
	return NewWaveName
#else
	Abort "Hdf5 xop is not found. Reinstall xops using one of the Installers or link the hdf5.xop from Igor distribution to your Igor extensions folder"
#endif
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


proc NI1_BSLWindow()

	string DF
	DF=getdatafolder(1)
	setdatafolder root:Packages:
	execute/Z/Q "root:Packages:NI1_BSLFiles:BSLsumseq=0"
	execute/Z/Q "root:Packages:NI1_BSLFiles:BSLsumframes=0"
	
	DoWindow NI1_BSLpanel
	if(V_flag)
		DoWindow/F NI1_BSLpanel
		setvariable bslcurrentframes, win=NI1_BSLpanel, limits={1,root:Packages:NI1_BSLFiles:BSLFrames,1}
	else
	//Josh add:  o.k., we need to add a way to sum over a few selected frames.  this is prolly something that 
	//only I will use, but still
		SetDataFolder root:Packages:NI1_BSLFiles
		if(BSLcurrentframe==0)
			root:Packages:NI1_BSLFiles:BSLAverage=1
		endif
		NewPanel/K=1/W=(200,100,550,400)/N=NI1_BSLpanel
		
		setvariable pixels, win=NI1_BSLpanel, title="pixels count", value=root:Packages:NI1_BSLFiles:BSLpixels, pos={10,10}, size={120,20}, noedit=1
		setvariable bypixels, win=NI1_BSLpanel, title="by", value=root:Packages:NI1_BSLFiles:BSLpixels1, pos={140,10}, size={120,20},noedit=1
//		setvariable BSLFoundFrames, win=NI1_BSLpanel, title="Found frames", value=root:Packages:NI1_BSLFiles:BSLFoundFrames, pos={10,30}, size={120,20}, noedit=1
		setvariable bslframes, win=NI1_BSLpanel, title="Found Frames :", value=root:Packages:NI1_BSLFiles:BSLframes, pos={10,30}, size={160,20}, noedit=1
		setvariable bslcurrentframes, win=NI1_BSLpanel, title="Selected frame", value=root:Packages:NI1_BSLFiles:BSLcurrentframe, pos={10,50}, size={150,20}, limits={1,root:Packages:NI1_BSLFiles:BSLFoundFrames,1}
		checkbox bslgbformat, win=NI1_BSLpanel, title="Intel Format?", variable=root:Packages:NI1_BSLFiles:BSLGBformat, pos={170,30}, size={100,20} , proc=NI1_BSLCheckProc

		checkbox Average, win=NI1_BSLpanel, title="or - Average all frames?", variable=root:Packages:NI1_BSLFiles:BSLAverage, pos={170,50}, size={100,20} , proc=NI1_BSLCheckProc
		setvariable BSLIo, win=NI1_BSLpanel, title="Io", value=root:Packages:NI1_BSLFiles:BSLI1, pos={10,70}, size={120,20}
		setvariable BLSIs, win=NI1_BSLpanel, title="Is", value=root:Packages:NI1_BSLFiles:BSLI2, pos={160,70}, size={120,20}
		setvariable BSLIopos, win=NI1_BSLpanel, title="Io row", value=root:Packages:NI1_BSLFiles:BSLI1pos, pos={10,95}, size={120,20},proc=NI1_BSLsetvarProc, help={"row number starting from 1"},limits={1,inf,1}
		setvariable BLSIspos, win=NI1_BSLpanel, title="Is row", value=root:Packages:NI1_BSLFiles:BSLI2pos, pos={160,95}, size={120,20},proc=NI1_BSLsetvarProc, help={"row number starting from 1"},limits={1,inf,1}
		listbox saxsnote, win=NI1_BSLpanel, listwave=root:Packages:NI1_BSLFiles:BSLheadnote, pos={5,125}, size={295,85}
		// josh add
		checkbox sumoverframes,win=NI1_BSLpanel,title="sum over selected frames",variable=root:Packages:NI1_BSLFiles:BSLsumframes,pos={5,220},proc=NI1_BSLCheckProc
		checkbox sumoverseq,win=NI1_BSLpanel,title="sum over sequence",variable=root:Packages:NI1_BSLFiles:BSLsumseq,pos={200,220},proc=NI1_BSLCheckProc
		
		setvariable fromframe, win=NI1_BSLpanel,title="from frame",pos={5,260},size={180,20},variable=root:Packages:NI1_BSLFiles:BSLfromframe,disable=1
		setvariable toframe, win=NI1_BSLpanel,title="to frame",pos={200,260},size={180,20},variable=root:Packages:NI1_BSLFiles:BSLtoframe,disable=1
	endif
	setDataFolder Df
endmacro


Function NI1_BSLSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
//				controlInfo /W=NI1A_Convert2Dto1DPanel Select2DInputWave
//				Wave/T ListOf2DSampleData = root:Packages:Convert2Dto1D:ListOf2DSampleData
//				NI1_BSLloadbslinfo(ListOf2DSampleData[V_Value])
		case 2: // Enter key
				controlInfo /W=NI1A_Convert2Dto1DPanel Select2DInputWave
				Wave/T ListOf2DSampleData = root:Packages:Convert2Dto1D:ListOf2DSampleData
				NI1_BSLloadbslinfo(ListOf2DSampleData[V_Value])
				break
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			break
	endswitch

	return 0
End


//NI1_BSLloadbslinfo(SelectedWv, resetCounter)
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1_BSLCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
		//josh add the code for the sumover frames checkbox to enable/disable the from and to variable.
			
			Variable checked = cba.checked
			if(cmpstr(cba.ctrlname,"Average")==0)
				NVAR BSLcurrentframe = root:Packages:NI1_BSLFiles:BSLcurrentframe
				if(checked)
					BSLcurrentframe=0
				else
					BSLcurrentframe=1
				endif
				elseif(cmpstr(cba.ctrlname,"sumoverframes")==0)
					if(checked)
					setvariable fromframe, win=NI1_BSLpanel,disable=0
					setvariable toframe, win=NI1_BSLpanel,disable=0
					else
					setvariable fromframe, win=NI1_BSLpanel,disable=1
					setvariable toframe, win=NI1_BSLpanel,disable=1
					endif
				elseif(cmpstr(cba.ctrlname,"sumoverseq")==0&&checked==1)
				NI1_BSLgettimesequence()
				endif
				
				break
	endswitch

	return 0
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_BSLgettimesequence()
		setdatafolder root:Packages:NI1_BSLFiles
		NVAR BSLframes=$("root:Packages:NI1_BSLFiles:BSLframes")
		
		variable i,j,n
		string file
		wave/t ListOf2DSampleData=$("root:Packages:Convert2Dto1D:ListOf2DSampleData")
		wave ListOf2DSampleDataNumbers=$("root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers")
		wave BSLframelistsequence=$("root:Packages:NI1_BSLFiles:BSLframelistsequence")
		redimension/n=(BSLframes,5) BSLframelistsequence
		 BSLframelistsequence[][0]=p+1
		for(i=0;i<dimsize(ListOf2DSampleDataNumbers,0);i+=1)
			if(ListOf2DSampleDataNumbers[i])
				file=ListOf2DSampleData[i]
				break
			endif
		endfor
		getfilefolderinfo/P=$("Convert2Dto1DDataPath")/Z file[0,2]+"LOG."+file[7,9]
		if(V_flag==0)
			loadwave/D/J/M/L={0,29,0,1,0}/V={" ","$",0,0}/N=timseq/P=$("Convert2Dto1DDataPath") file[0,2]+"LOG."+file[7,9]
			wave timseq0
			for(i=0;i<(dimsize(timseq0,0));i+=1)
				if(numtype(timseq0[i][2])!=0)
					deletepoints/M=0 i,1, timseq0
					i-=1
				endif
			endfor			
			n=0			
			BSLframelistsequence[0][1]=timseq0[0][4]
			BSLframelistsequence[0][3]=timseq0[0][4]+timseq0[0][1]
			for(i=1;i<(dimsize(timseq0,0));i+=1)				
				for(j=0;j<timseq0[i][0];j+=1)
					n+=1
					BSLframelistsequence[n][1]=timseq0[i][4]
					BSLframelistsequence[n][4]=timseq0[i][5]
					if(j==0)
						BSLframelistsequence[n][3]=timseq0[i][4]+timseq0[i][1]+BSLframelistsequence[n-1][3]					
					else
						BSLframelistsequence[n][3]=timseq0[i][4]+BSLframelistsequence[n-1][3]
					endif
				endfor
				
			endfor
		
		else
			BSLframelistsequence[][0]=p
			BSLframelistsequence[][1]=0
			setdimlabel 1,1,$("Enter Exposure Times?"),BSLframelistsequence
		endif
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


function NI1_BSLbuttonProc(ctrlname):buttoncontrol
		string ctrlname
		if(cmpstr(ctrlname,"displaylog")==0)
			wave/t Listof2DSampleData=$("root:Packages:Convert2Dto1D:ListOf2DSampleData")
			wave Listof2DSampleDataNumbers=$("root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers")
			variable i
			string logfile
			for(i=0;i<(dimsize(Listof2DSampleData,0));i+=1)
				if(Listof2DSampleDataNumbers[i])
					logfile=Listof2DSampleData[i]
					logfile=logfile[0,2]+"LOG."+stringfromlist(1,logfile,".")
					break
				endif
			endfor
			loadwave/J/M/L={0,29,0,1,0}/V={" ","$",0,0}/N=timseq/P=$("Convert2Dto1DDataPath") logfile
			wave timseq0
			variable ,j,n
			n=-1
			for(i=0;i<dimsize(timseq0,0);i+=1)	
				for(j=0;j<timseq0[i][0];j+=1)
					n+=1
					make/o/d/n=(n+1) Timeseq
					Timeseq[n]=0
					Timeseq[n]=timseq0[i][4]+timseq0[i][1]
				endfor
			endfor
			DoWindow Frames0
			if(V_flag)
				killwindow Frames0
			endif
			edit/k=1/N=Frames Timeseq
		endif
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************



Function NI1_MainListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable i
	string items=""
	wave ListOf2DSampleDataNumbers=root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers
	wave/t ListOf2DSampleData=root:Packages:Convert2Dto1D:ListOf2DSampleData
	//NVAR DoubleClickConverts=root:Packages:Convert2Dto1D:DoubleClickConverts
	NVAR FIlesSortOrder=root:Packages:Convert2Dto1D:FIlesSortOrder
	switch (lba.eventCode)
		case 4:
			controlinfo/W=NI1A_Convert2Dto1Dpanel Select2DDataType
			if(cmpstr(S_Value,"BSL/SAXS")==0 || cmpstr(S_Value,"BSL/WAXS")==0)
				for(i=0;i<(dimsize(ListOf2DSampleDataNumbers,0));i+=1)
					if(ListOf2DSampleDataNumbers[i]==1)
						NI1_BSLloadbslinfo(ListOf2DSampleData[i])
						break //just display fist selected file
					endif
				endfor
				execute "NI1_BSLWindow()"
			endif
			break
		case 3:			//double click
			NI1A_ButtonProc("ProcessSelectedImages")			
			break
		case 1:
			if (lba.eventMod & 0x10)	// rightclick
				// list of items for PopupContextualMenu
				items = "Refresh Content;Select All;Deselect All;Sort;Sort2;Sort _001;Invert Sort _001;Reverse Sort;Reverse Sort2;Hide \"Blank\";Hide \"Empty\";Remove Hide;"	
				PopupContextualMenu items
				SVAR SampleNameMatchStr = root:Packages:Convert2Dto1D:SampleNameMatchStr
				// V_flag is index of user selected item
				switch (V_flag)
					case 1:	// "Refresh Content"
						//refresh content, but here it will depend where we call it from.
						ControlInfo/W=NI1A_Convert2Dto1DPanel Select2DInputWave
						variable oldSets=V_startRow
						NI1A_UpdateDataListBox()	
						ListBox Select2DInputWave,win=NI1A_Convert2Dto1DPanel,row=V_startRow
						break;
					case 2:	// "Select All;"
					      ListOf2DSampleDataNumbers = 1
						break;
					case 3:	// "Deselect All"
					      ListOf2DSampleDataNumbers = 0
						break;
					case 4:	// "Sort"
						FIlesSortOrder = 1
						break;
					case 5:	// "Sort2"
						FIlesSortOrder = 2
//						Execute("PopupMenu FIlesSortOrder,win=NI1A_Convert2Dto1DPanel, mode=(root:Packages:Convert2Dto1D:FIlesSortOrder+1),value= \"None;Sort;Sort2;_001.;Invert_001;Invert Sort;Invert Sort2;\"")
						PopupMenu FIlesSortOrder,win=NI1A_Convert2Dto1DPanel, mode=(FIlesSortOrder+1),value= "None;Sort;Sort2;_001.;Invert_001;Invert Sort;Invert Sort2;"
						NI1A_UpdateDataListBox()	
						break;
					case 6:	// "_001"
						FIlesSortOrder = 3
//						Execute("PopupMenu FIlesSortOrder,win=NI1A_Convert2Dto1DPanel, mode=(root:Packages:Convert2Dto1D:FIlesSortOrder+1),value= \"None;Sort;Sort2;_001.;Invert_001;Invert Sort;Invert Sort2;\"")
						PopupMenu FIlesSortOrder,win=NI1A_Convert2Dto1DPanel, mode=(FIlesSortOrder+1),value= "None;Sort;Sort2;_001.;Invert_001;Invert Sort;Invert Sort2;"
						NI1A_UpdateDataListBox()	
						break;
					case 7:	// "Invert _001"
						FIlesSortOrder = 4
//						Execute("PopupMenu FIlesSortOrder,win=NI1A_Convert2Dto1DPanel, mode=(root:Packages:Convert2Dto1D:FIlesSortOrder+1),value= \"None;Sort;Sort2;_001.;Invert_001;Invert Sort;Invert Sort2;\"")
						PopupMenu FIlesSortOrder,win=NI1A_Convert2Dto1DPanel, mode=(FIlesSortOrder+1),value= "None;Sort;Sort2;_001.;Invert_001;Invert Sort;Invert Sort2;"
						NI1A_UpdateDataListBox()	
						break;
					case 8:	// "Invert Sort"
						FIlesSortOrder = 5
//						Execute("PopupMenu FIlesSortOrder,win=NI1A_Convert2Dto1DPanel, mode=(root:Packages:Convert2Dto1D:FIlesSortOrder+1),value= \"None;Sort;Sort2;_001.;Invert_001;Invert Sort;Invert Sort2;\"")
						PopupMenu FIlesSortOrder,win=NI1A_Convert2Dto1DPanel, mode=(FIlesSortOrder+1),value= "None;Sort;Sort2;_001.;Invert_001;Invert Sort;Invert Sort2;"
						NI1A_UpdateDataListBox()	
						break;
					case 9:	// "Invert Sort2"
						FIlesSortOrder = 6
//						Execute("PopupMenu FIlesSortOrder,win=NI1A_Convert2Dto1DPanel, mode=(root:Packages:Convert2Dto1D:FIlesSortOrder+1),value= \"None;Sort;Sort2;_001.;Invert_001;Invert Sort;Invert Sort2;\"")
						PopupMenu FIlesSortOrder,win=NI1A_Convert2Dto1DPanel, mode=(FIlesSortOrder+1),value= "None;Sort;Sort2;_001.;Invert_001;Invert Sort;Invert Sort2;"
						NI1A_UpdateDataListBox()	
						break;
					case 10:	// "Hide mathicng Blank"
						SampleNameMatchStr="^((?!(?i)Blank).)*$"
						NI1A_UpdateDataListBox()	
						break;
					case 11:	// "Hide mathicng Blank"
						SampleNameMatchStr="^((?!(?i)Empty).)*$"
						NI1A_UpdateDataListBox()	
						break;
					case 12:	// "Hide mathicng Blank"
						SampleNameMatchStr=""
						NI1A_UpdateDataListBox()	
						break;
					endswitch
			endif
		endswitch
	return 0
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//***************************************** **************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_MaskListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable i
	string items=""
	switch (lba.eventCode)
		case 3:		//double click
			NI1A_ButtonProc("LoadMask")
		break
		case 1:		
			if (lba.eventMod & 0x10)	// rightclick
				// list of items for PopupContextualMenu
				items = "Refresh Content;"	
				PopupContextualMenu items
				// V_flag is index of user selected item
				if(V_Flag)
					NI1A_UpdateEmptyDarkListBox()	
				endif
			endif
		break	
	endswitch	
	return 0
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//***************************************** **************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_EmpDarkListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	NVAR useDarkField=root:Packages:Convert2Dto1D:useDarkField
	NVAR useEmptyField=root:Packages:Convert2Dto1D:useEmptyField
	SVAR EmptyDarkNameMatchStr=root:Packages:Convert2Dto1D:EmptyDarkNameMatchStr
	string items = ""
	switch (lba.eventCode)
		case 3 :
			switch(useDarkField+useEmptyField)
			case 1:
				if(useDarkField)
					NI1A_ButtonProc("LoadDarkField")
				else	//empty
					NI1A_ButtonProc("LoadEmpty")
				endif
				break
			case 2:
				String FieldType
				FieldType ="Empty field"
				prompt FieldType, "Field type", popup, "Empty Field;Dark Field;"
				DoPrompt "Select type of field", FieldType
				//DoAlert /T="Double click Selection" 2, "Is this empty field (Yes), Dark field (No), or Cancel?" 
				if(!V_Flag)
					if(stringmatch(FieldType,"Empty Field"))
						NI1A_ButtonProc("LoadEmpty")
					elseif(stringmatch(FieldType,"Dark Field"))
						NI1A_ButtonProc("LoadDarkField")
					endif
				endif
				break
			default:
				//donothing
			endswitch
		break
		case 1:
			if (lba.eventMod & 0x10)	// rightclick
				// list of items for PopupContextualMenu
				items = "Refresh Content;Match \"Empty\";Match \"Blank\";Match \"Dark\";"	
				PopupContextualMenu items
				// V_flag is index of user selected item
				switch (V_flag)
					case 1:
						NI1A_UpdateEmptyDarkListBox()	
						break
					case 2:
						EmptyDarkNameMatchStr = "(?i)Empty"
						NI1A_UpdateEmptyDarkListBox()	
						break
					case 3:
						EmptyDarkNameMatchStr = "(?i)Blank"
						NI1A_UpdateEmptyDarkListBox()	
						break
 					case 4:
						EmptyDarkNameMatchStr = "(?i)Dark"
						NI1A_UpdateEmptyDarkListBox()	
						break
						
				endswitch
			endif
		break
	endswitch
	return 0
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//***************************************** **************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


static function NI1_BSLloadbslinfo(SelectedWv)
		string SelectedWv
		
		string OldDf=GetDataFolder(1)
		setdatafolder root:Packages:Convert2Dto1D:
		string filebeg
		string fileext
		string head1
		variable i
	//	wave ListOf2DSampleDataNumbers
	//	wave/t ListOf2DSampleData
	//	for(i=0;i<(dimsize(ListOf2DSampleData,0));i+=1)
	//		if(ListOf2DSampleDataNumbers[i]==1)
				filebeg=stringfromlist(0,SelectedWv,".")
				fileext=stringfromlist(1,SelectedWv,".")//ext for all
				head1=filebeg[0]+filebeg[1]+filebeg[2]
				//now we have first three characters i.e. A01
				string filewaxs, filesaxs, filecal, fileInfo
				fileInfo=head1+"000."+fileext
				filewaxs=head1+"003."+fileext
				filesaxs=head1+"001."+fileext
				filecal=head1+"002."+fileext
		             loadwave/N=header/J/K=1/M/L={0,2,0,0,8}/V={" ","$",0,1}/P=$("Convert2Dto1DDataPath") fileInfo
				wave header0
				
				NVAR waxschannels=$("root:Packages:NI1_BSLFiles:BSLwaxschannels")
				NVAR waxsframe=$("root:Packages:NI1_BSLFiles:BSLwaxsframes")
				NVAR saxsframe=$("root:Packages:NI1_BSLFiles:BSLframes")
				NVAR pixel=$("root:Packages:NI1_BSLFiles:BSLpixels")
				NVAR pixel1=$("root:Packages:NI1_BSLFiles:BSLpixels1")
				wave/t headnote=$("root:Packages:NI1_BSLFiles:BSLheadnote")
				NVAR currentframe=$("root:Packages:NI1_BSLFiles:BSLcurrentframe")
				NVAR fromframe=$("root:Packages:NI1_BSLFiles:BSLfromframe")
				NVAR toframe=$("root:Packages:NI1_BSLFiles:BSLtoframe")
				NVAR sumframes=$("root:Packages:NI1_BSLFiles:BSLsumframes")
				NVAR Average=$("root:Packages:NI1_BSLFiles:BSLaverage")
				NVAR BSLGBformat=$("root:Packages:NI1_BSLFiles:BSLGBformat")

				waxschannels=header0[4][1]
				waxsframe=header0[4][2]
				saxsframe=header0[0][3]
				pixel1=header0[0][1]		//changed 5/30/2012 per request from Olexander sicne the dimensions were switched for no square detectors. 
				pixel=header0[0][2]			
				//currentframe=1//reset current frame to 1
				//load the header notes
		
				loadwave/N=headernote/J/K=2/M/P=$("Convert2Dto1DDataPath") fileInfo
				wave/t headernote0
				
				headnote=headernote0
				//load calibration file
				
				GBLoadWave/O/Q/N=cal/T={2,96}/W=1/B=(BSLGBformat)/P=$("Convert2Dto1DDataPath") filecal
				wave cal0
		
				if(cal0[1]<1)
					GBLoadWave/O/Q/b=1/N=cal/T={2,96}/W=1/P=$("Convert2Dto1DDataPath") filecal
				endif
				NVAR I1=$("root:Packages:NI1_BSLFiles:BSLI1")
				NVAR I2=$("root:Packages:NI1_BSLFiles:BSLI2")
				NVAR I1pos=$("root:Packages:NI1_BSLFiles:BSLI1pos")
				NVAR I2pos=$("root:Packages:NI1_BSLFiles:BSLI2pos")
				if(I1pos==1)
				I1=cal0[currentframe-1]
				I2=cal0[saxsframe*(I2pos-1)+currentframe-1]
				elseif(I2pos==1)
				I2=cal0[currentframe-1]
				I1=cal0[saxsframe*(I1pos-1)+currentframe-1]
				else
				I1=cal0[saxsframe*(I1pos-1)+currentframe-1]
				I2=cal0[saxsframe*(I2pos-1)+currentframe-1]
				endif
				//JOSH ADD.............
				if(sumframes)
					I1=sum(cal0,	(fromframe-1),(toframe-1))
					I2=sum(cal0,(saxsframe-fromframe-1),(saxsframe-toframe-1))
				elseif(average)
					I1=sum(cal0,0,(saxsframe-1))/(saxsframe)
					I2=sum(cal0,(saxsframe),(saxsframe*2-1))/(saxsframe)
				endif
				NVAR SampleI0 = root:Packages:Convert2Dto1D:SampleI0
				SampleI0=I1
//				break
//			endif		
//		endfor
		setDataFolder OldDf
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1_LoadBSLFiles(SelectedFileToLoad)
	string SelectedFileToLoad

	string OldDf
	OldDf=getdatafolder(1)
	setdatafolder root:Packages:
	SetDataFolder root:Packages:NI1_BSLFiles

	//PathInfo $("Convert2Dto1DDataPath")
			
	getfilefolderinfo/P=$("Convert2Dto1DDataPath") SelectedFileToLoad
			
	NVAR BSLpixels=$("root:Packages:NI1_BSLFiles:BSLpixels1")
	NVAR BSLpixels1=$("root:Packages:NI1_BSLFiles:BSLpixels")
	NVAR BSLframes=$("root:Packages:NI1_BSLFiles:BSLframes")
	NVAR BSLcurrentframe=$("root:Packages:NI1_BSLFiles:BSLcurrentframe")
	NVAR BSLAverage = $("root:Packages:NI1_BSLFiles:BSLAverage")
	NVAR BSLsumframes = $("root:Packages:NI1_BSLFiles:BSLsumframes")
	NVAR BSLsumseq = $("root:Packages:NI1_BSLFiles:BSLsumseq")
	NVAR BSLfromframe = $("root:Packages:NI1_BSLFiles:BSLfromframe")
	NVAR BSLtoframe = $("root:Packages:NI1_BSLFiles:BSLtoframe")
	NVAR BSLGBformat=$("root:Packages:NI1_BSLFiles:BSLGBformat")
	getfilefolderinfo/P=$("Convert2Dto1DDataPath") SelectedFileToLoad
	BSLframes=V_logEOF/4/(BSLpixels*BSLpixels1)
	variable bsli
	if(BSLframes>=1)			
	//it is easier to load the file here they can be very large, that way it only loads once
	GBLoadWave/W=(BSLframes)/F=1/B=(BSLGBformat)/Q/T={2,4}/J=1/D=1/S=0/U=(BSLpixels*BSLpixels1)/N=saxs/P=$("Convert2Dto1DDataPath") SelectedFileToLoad
	
		if(BSLAverage)
			wave FirstFrame=$("saxs0")	
			Duplicate/O FirstFrame, saxs_average
			saxs_average[]=0
			for(bsli=0;bsli<BSLframes;bsli+=1)
				wave saxs=$("saxs"+num2str(bsli))
				saxs_average+= saxs
			endfor
			saxs_average/=BSLframes
			BSLcurrentframe=0
			//josh add sumover frames
		elseif(BSLsumframes)
		///check this........................
			wave SelFrame=$("saxs"+num2str(BSLfromframe-1))		//use numbering from 1 not from 0. It should be more user friendly. 
			Duplicate/O SelFrame, saxs_average
			for(bsli=(BSLfromframe);bsli<(BSLtoframe);bsli+=1)
			wave saxs=$("saxs"+num2str(bsli))
			saxs_average+=saxs
			endfor
		elseif(BSLsumseq)
		///check this........................
			wave SelFrame=$("saxs"+num2str(BSLfromframe-1))		//use numbering from 1 not from 0. It should be more user friendly. 
			Duplicate/O SelFrame, saxs_average
			for(bsli=(BSLfromframe);bsli<(BSLtoframe);bsli+=1)
			wave saxs=$("saxs"+num2str(bsli))
			saxs_average+=saxs
			endfor
		else
			wave SelFrame=$("saxs"+num2str(BSLcurrentframe-1))		//use numbering from 1 not from 0. It should be more user friendly. 
			Duplicate/O SelFrame, saxs_average
		endif
		redimension /N=(BSLpixels,BSLpixels1) saxs_average
	else
		Make/O/N=(100,100) saxs_average
		saxs_average = 0
		DoAlert  0, "No data in this BSL data file"
	endif
	Duplicate/O saxs_average, temp2DWave
	//attach wave note: use the wave BSLheadNote, but update it first in case we are processing larger number of files. 
	NI1_BSLloadbslinfo(SelectedFileToLoad)
	wave/t headnote=$("root:Packages:NI1_BSLFiles:BSLheadnote")
	variable i
	string tempNote=""
	For(i=0;i<numpnts(headnote);i+=1)
		tempNote+=headnote[i]+";"
	endfor
	note temp2DWave, tempNote
	setDataFolder OldDf
	return BSLcurrentframe
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

static Function/S NI1_ReadFujiImgHeader(PathName, filename)
	string PathName, filename
	
	string infFilename=filename[0,strlen(filename)-5]+".inf"
	variable FnVar
	open /P=$(PathName)/R/Z FnVar as infFilename
	if(V_Flag!=0)
		Abort "Inf file does not exist, cannot load Fuji image file"
	endif
	string Informations=""
	string tempstr, tempstr1, tempstr2
	freadline FnVar, tempstr
	Informations+="Header:"+tempstr+";"
	freadline FnVar, tempstr
	Informations+="OriginalFileName:"+tempstr+";"
	freadline FnVar, tempstr
	Informations+="PlateSize:"+tempstr+";"
	freadline FnVar, tempstr
	Informations+="PixelSizeX:"+tempstr+";"
	//BAS2000 can do either 100 or 200 micron sizes
	//BAS2500 50, 100 or 200 micron
	freadline FnVar, tempstr
	Informations+="PixelSizeY:"+tempstr+";"
	freadline FnVar, tempstr
	Informations+="BitsPerPixel:"+tempstr+";"
	//BAS2000 can do either 8 or 10 bits/pixel
	//BAS2500 8 or 16
	freadline FnVar, tempstr
	Informations+="PixelsInRaster:"+tempstr+";"
	freadline FnVar, tempstr
	Informations+="NumberOfRasters:"+tempstr+";"
	freadline FnVar, tempstr
	Informations+="Sensitivity:"+tempstr+";"
	//BAS2000 can be 400, 1000, 4000 or 10000 but user defined any value in this range is possible... 
	// BAS2500 For latitude 4, you may select sensitivity 1000, 4000 or 10000. For  latitude 5, sensitivity may be set to 4000, 10000 or 30000
	freadline FnVar, tempstr
	Informations+="Latitude:"+tempstr+";"
	//BAS2000 can do Latitude 1, 2, 3, or 4
	//BAS2500 can do 4 and 5
	freadline FnVar, tempstr
	Informations+="DateAndTime:"+tempstr+";"
	freadline FnVar, tempstr
	Informations+="NumberOfBytesInFile:"+tempstr+";"
	//from here the file format is different for BAS2000 and BAS2500
	freadline FnVar, tempstr1
	freadline FnVar, tempstr2
	if(stringmatch(tempstr2, "*IPR2500*" ))		//IPR2500
		Informations+="ImagePlateType:"+"IPR2500"+";"
		freadline FnVar, tempstr
		Informations+="ImageReaderType:"+"BAS2500"+";"
		//I do nto have BAS2500 file to test what else is in the inf file... 
	else			//BAS2000
		Informations+="NumberOfOverflowPixels:"+tempstr1+";"
		freadline FnVar, tempstr
		freadline FnVar, tempstr		
		Informations+="UserDescription:"+tempstr+";"
		freadline FnVar, tempstr
		Informations+="ImageSize:"+tempstr+";"
		freadline FnVar, tempstr
		Informations+="ImagePlateType:"+tempstr+";"
		freadline FnVar, tempstr
		Informations+="ImageReaderType:"+tempstr+";"
		freadline FnVar, tempstr
		Informations+="SomeKindOfComment:"+tempstr+";"
	endif
	
	Informations =ReplaceString("\r", Informations, "" )
	return Informations
	
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_FujiBASChangeEndiness()
			NVAR/Z FujiEndinessSetting = root:Packages:Convert2Dto1D:FujiEndinessSetting
			if(!NVAR_Exists(FujiEndinessSetting))
				variable/g root:Packages:Convert2Dto1D:FujiEndinessSetting
				NVAR FujiEndinessSetting = root:Packages:Convert2Dto1D:FujiEndinessSetting
				FujiEndinessSetting=0
			else
				FujiEndinessSetting=!FujiEndinessSetting
			endif
			

end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

static Function NI1_ReadFujiImgFile(PathName, filename, FujiFileHeader)
	string PathName, filename, FujiFileHeader

		//first - there can be 8, 10,  or 16 bits in the file per point and 
		// 16 bits can be byte swapped (little/big endian). Need to deal with them separately...
		variable BitsPerPixel
		BitsPerPixel=NumberByKey("BitsPerPixel", FujiFileHeader  , ":", ";")
		if(BitsPerPixel==8)
			//GBLoadWave/Q/B=1/T={8,4}/W=1/P=$(PathName)/N=Loadedwave filename
			//this does not look like signed 8 bit word, it is unsigned 8 bit word... 
			GBLoadWave/Q/B=1/T={72,4}/W=1/P=$(PathName)/N=Loadedwave filename
		elseif(BitsPerPixel==16)
		//	Abort "Only 8 bit image depth has been tested. Please, send details and case examples on this higher-buit depth images to Author (ilavsky@aps.anl.gov) to improve the reader"
			NVAR/Z FujiEndinessSetting = root:Packages:Convert2Dto1D:FujiEndinessSetting
			if(!NVAR_Exists(FujiEndinessSetting))
				variable/g root:Packages:Convert2Dto1D:FujiEndinessSetting
				NVAR FujiEndinessSetting = root:Packages:Convert2Dto1D:FujiEndinessSetting
				FujiEndinessSetting=0
			endif
			if(FujiEndinessSetting)
				GBLoadWave/T={16,16}/W=1 /P=$(PathName)/N=Loadedwave filename
				print "Fuji Image file reader read with high-byte first (Motorolla, little endian). If it is incorrect, issue following command from command line:   NI1_FujiBASChangeEndiness()  "
			else
//			//    low byte first:
				GBLoadWave/B/T={16,16}/W=1 /P=$(PathName)/N=Loadedwave filename	
				print "Fuji Image file reader read with low-byte first (Intel, big endian). If it is incorrect, issue following command from command line:   NI1_FujiBASChangeEndiness()  "
			endif
		else
			Abort "Seems like you have 10 bit image. This type of image is not yet supported. Please sedn test files to author"	
		endif
		variable NumPntsX=NumberByKey("PixelsInRaster", FujiFileHeader , ":", ";")
		variable NumPntsY=NumberByKey("NumberOfRasters", FujiFileHeader , ":", ";")
		Wave Loadedwave0
		redimension/D Loadedwave0
		variable Gval
		if(BitsPerPixel==8)		//thsi is binning of the image depth. 8 bits here
			Gval=(2^8)-1
		elseif(BitsPerPixel==10)	//10 bits here
			Gval=(2^10)-1
		else							//assume 16 bits...
			Gval=(2^16)-1
		endif

		//fix overflow pixels, hopefully this fixes them...  This followds IDL code by Heinz
		if(BitsPerPixel==8)
		
		elseif(BitsPerPixel==16)			//this should be signed integer, so we need to deal with this... 
			Loadedwave0 = (Loadedwave0[p]<0) ? (Loadedwave0[p]+ Gval) : Loadedwave0[p]
		endif
		//This is from H.Amenitsch, clearly he assumes only 16 bit depth
		//		  G =  2.^16										
		//		  raw =  10^(5*(raw/G)-0.5)						do the calculations
		//		  raw =  (float(pixelsizex)/100.)^2*raw
		// Mark Rivers description:
		//; PROCEDURE:
		//;   This function converts values measured by the BAS2000 scanner into
		//;   actual x-ray intensities according to the equation:
		//;
		//;       PSL = (4000/S)*10^(L*QSL)/1023 - 0.5)
		//;   where
		//;       PSL = x-ray intensity
		//;       S   = sensitivity setting
		//;       L   = latitude setting
		//;       QSL = measured value from BAS2000
		//;
		//;   This equation appears somewhere in the BAS2000 documentation?
		//This is Tom Irving... 
		//#define CONVERT	256
		//#define MAXPIXVALUE 1024
		//
		///*	Conversion for all Fuji scans is take pixel value, multiply by
		//	latitude (4 or 5 for 4 or 5 orders of magnitude) and divide by
		//	2^bitdepth where bitdepth is 10 or 16 for bas2000 and bas2500
		//	respectively and then take base 10 antilog. So to lineralize
		//	data you divide the input value which can be at most
		//	 MAXPIXVALUE =2^bitdepth by CONVERT and then take the
		//	 base 10 antilog
		//
		//        cooment JIL - I suspect that the formula should be:
		//;       PSL = (MaxSensitivity/Sensitivity)*10^(Latitude*(MeasuredData/BitDepth) - 0.5)


		variable Sensitivity=NumberByKey("Sensitivity", FujiFileHeader , ":", ";")
		variable Latitude=NumberByKey("Latitude", FujiFileHeader , ":", ";")
		
		variable MaxSensitivity=10000
		if(stringmatch(stringByKey("ImageReaderType:",FujiFileHeader , ":", ";"), "*BAS2000*"))
			MaxSensitivity=10000
		else		//assume BAS2500
			if (stringmatch(stringByKey("Latitude:",FujiFileHeader , ":", ";"), "*4*") )
				MaxSensitivity=10000
			else //latitude 5
				MaxSensitivity=30000
			endif
		endif
		variable FudgeToFit2D=2.3625
		//scale data to max sensitivity of the reader, so data from same instrument with different sensitivity can be compared... 
		variable tempVar = (MaxSensitivity/Sensitivity)/FudgeToFit2D
		//Loadedwave0 =  tempVar *10^(Latitude*(Loadedwave0[p]/Gval) - 0.5)
		MatrixOp/O Loadedwave0 =  tempVar *powR(10,(Latitude*(Loadedwave0/Gval) - 0.5))

		//Now, Heinz has this normalized somehow by area of pixel... Weird, I would assume I need to divide by area, not multiply. Leave it out for now... 
	//	variable pixelSizeX = NumberByKey("PixelSizeX", FujiFileHeader , ":", ";")
	//	variable pixelSizeY = NumberByKey("PixelSizeY", FujiFileHeader , ":", ";")
	//	variable MultConst = (pixelSizeX/100)*(pixelSizeY/100)
	//	Loadedwave0 = MultConst*Loadedwave0 
		redimension/N=(NumPntsX,NumPntsY) Loadedwave0

end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_ESRFEdfLoaderPanelFnct() : Panel
	
	DoWindow  NI1_ESRFEdfLoaderPanel
	if(V_Flag)
		DoWindow/F NI1_ESRFEdfLoaderPanel
	else
		NVAR ESRFEdf_ExposureTime=root:Packages:Convert2Dto1D:ESRFEdf_ExposureTime
		NVAR ESRFEdf_Center_1=root:Packages:Convert2Dto1D:ESRFEdf_Center_1
		NVAR ESRFEdf_Center_2=root:Packages:Convert2Dto1D:ESRFEdf_Center_2
		NVAR ESRFEdf_PSize_1=root:Packages:Convert2Dto1D:ESRFEdf_PSize_1
		NVAR ESRFEdf_PSize_2=root:Packages:Convert2Dto1D:ESRFEdf_PSize_2
		NVAR ESRFEdf_SampleDistance=root:Packages:Convert2Dto1D:ESRFEdf_SampleDistance
		NVAR ESRFEdf_SampleThickness=root:Packages:Convert2Dto1D:ESRFEdf_SampleThickness
		NVAR ESRFEdf_WaveLength=root:Packages:Convert2Dto1D:ESRFEdf_WaveLength
		NVAR ESRFEdf_Title=root:Packages:Convert2Dto1D:ESRFEdf_Title
		PauseUpdate    		// building window...
		NewPanel/K=1 /W=(240,98,600,300) as "ESRF EDF loader config panel"
		DoWindow/C NI1_ESRFEdfLoaderPanel
		SetDrawLayer UserBack
		SetDrawEnv fsize= 18,fstyle= 3,textrgb= (0,0,65280)
		DrawText 28,36,"Nika ESRF edf Loader Config"

		Checkbox ESRFEdf_Title,pos={15,70},size={122,21},noproc,title="Read Sample name? "
		Checkbox  ESRFEdf_Title,help={"Select if you want to read sample name from EDF file"}, variable=root:Packages:Convert2Dto1D:ESRFEdf_Title
		Checkbox ESRFEdf_ExposureTime,pos={15,85},size={122,21},noproc,title="Read Exposure time? "
		Checkbox  ESRFEdf_ExposureTime,help={"Select if you want to read exposure time from EDF file"}, variable=root:Packages:Convert2Dto1D:ESRFEdf_ExposureTime
		Checkbox ESRFEdf_SampleThickness,pos={15,100},size={122,21},noproc,title="Read Sample thickness? "
		Checkbox  ESRFEdf_SampleThickness,help={"Select if you want to read sample thickness from EDF file"}, variable=root:Packages:Convert2Dto1D:ESRFEdf_SampleThickness

	
		Checkbox ESRFEdf_SampleDistance,pos={195,70},size={122,21},noproc,title="Read SDD? "
		Checkbox  ESRFEdf_SampleDistance,help={"Select if you want to read sample to detector distance from EDF file"}, variable=root:Packages:Convert2Dto1D:ESRFEdf_SampleDistance
		Checkbox ESRFEdf_WaveLength,pos={195,85},size={122,21},noproc,title="Read Wavelength? "
		Checkbox  ESRFEdf_WaveLength,help={"Select if you want to read wavelength from EDF file"}, variable=root:Packages:Convert2Dto1D:ESRFEdf_WaveLength


		Checkbox ESRFEdf_PSize_1,pos={195,100},size={122,21},noproc,title="Read Pixel size X? "
		Checkbox  ESRFEdf_PSize_1,help={"Select if you want to read pixel size X from EDF file"}, variable=root:Packages:Convert2Dto1D:ESRFEdf_PSize_1
		Checkbox ESRFEdf_PSize_2,pos={195,115},size={122,21},noproc,title="Read Pixel size Y? "
		Checkbox  ESRFEdf_PSize_2,help={"Select if you want to read pixel size Y from EDF file"}, variable=root:Packages:Convert2Dto1D:ESRFEdf_PSize_2
	
		Checkbox ESRFEdf_Center_1,pos={195,130},size={122,21},noproc,title="Read beam center X? "
		Checkbox  ESRFEdf_Center_1,help={"Select if you want to read beam center X from EDF file"}, variable=root:Packages:Convert2Dto1D:ESRFEdf_Center_1
		Checkbox ESRFEdf_Center_2,pos={195,145},size={122,21},noproc,title="Read beam center Y? "
		Checkbox  ESRFEdf_Center_2,help={"Select if you want to read beam center Y from EDF file"}, variable=root:Packages:Convert2Dto1D:ESRFEdf_Center_2

	endif
EndMacro

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//
//static Function NI2NX_NexusReader(FilePathName,Filename)
//		string FilePathName,Filename
//		
//		string OldDf=getDataFolder(1)
//		Variable fileID
//#if(exists("HDF5OpenFile")==4)
//		HDF5OpenFile /P=$(FilePathName)/R /Z fileID as Filename	// Displays a dialog
//		if (V_flag == 0)	// User selected a file?
//		    string PathString
//		    PathString=S_Path
//		 //   print "Opened file :" +PathString+fileName
//		    setDataFolder root:
//		    newDataFolder/O/S root:Packages
//		    //clean this folder of prior loaded data
//		    if(DataFolderExists("root:Packages:NexusImport"))
//		    	KillDataFolder/Z root:Packages:NexusImport
//		    endif
//		    newDataFolder/O/S root:Packages:NexusImport
//		    string/g StartFolderStr
//		    SVAR StartFolderStr=root:Packages:NexusImport:StartFolderStr
//		    KillDataFolder/Z $(FileName[0,30])
//		    NewDataFolder/O/S $(FileName[0,30])
//		    string LoadedWvStr=getDataFolder(1)
//		    HDF5LoadGroup /O /R /T /IMAG=1 :, fileID, "/"			
////			    string GroupsAvailable
////				HDF5ListGroup /F  /Type=1 fileID, "/"
////				GroupsAvailable= S_HDF5ListGroup
////				variable i
////				For(i=0;i<ItemsInList(GroupsAvailable,";");i+=1)
////					HDF5LoadGroup /CONT=1 /L=7 /O /R /T : , fileID, StringFromList(i,GroupsAvailable,";")
////				endfor
//			HDF5CloseFile fileID
//			string CurrFolder=getDataFolder(1)
//			string LoadedDataWvNm = NI2NX_CleanUpHDF5Structure(CurrFolder)
//			//print "Loaded following wave: "+GetDataFOlder(1)+LoadedDataWvNm
//			wave LoadedWave = $(LoadedWvStr+LoadedDataWvNm)
//			Duplicate/O LoadedWave, $("root:Packages:Convert2Dto1D:"+"Loadedwave0")
//		endif
//#else
//		DoALert 0, "Hdf5 xop not installed, please, run installed version 1.10 and higher and install xops"
//#endif 
//		SetDataFolder OldDF
////		KillDataFolder /Z CurrFolder 
//End
//
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
//
//static Function/S NI2NX_CleanUpHDF5Structure(Fldrname)
//	string FldrName
//	string StartDf=GetDataFolder(1)
//	SVAR StartFolderStr=root:Packages:NexusImport:StartFolderStr
//	StartFolderStr = Fldrname+"entry:"
//	IN2G_UniversalFolderScan(startDF, 50, "NI2NX_ConvertTxTwvToStringList(\""+Fldrname+"\")")
//	IN2G_UniversalFolderScan(startDF, 50, "NI2NX_ConvertNumWvToStringList(\""+Fldrname+"\")")
//	IN2G_UniversalFolderScan(startDF, 50, "NI2NX_FindThe2DData(\""+Fldrname+"\")")
//	//now we have moved the data to stringgs and main folder of the Nexus file name 
//	string ListOf2DWaves=WaveList("*", ";", "TEXT:0,DIMS:2" )
//	string a2DdataWave=stringFromList(0,ListOf2DWaves)
//	SVAR/Z StringVals=$(FldrName+"ListOfStrValues")
//	SVAR/Z NumVals=$(FldrName+"ListOfNumValues")
//	Wave DataWv=$(FldrName+a2DdataWave)
//	if(SVAR_Exists(StringVals))
//		note/NOCR DataWv, "NEXUS_StringDataStartHere;"+StringVals+"NEXUS_StringDataEndHere;"
//	endif
//	if(SVAR_Exists(NumVals))
//		note/NOCR DataWv, "NEXUS_VariablesDataStartHere;"+NumVals+"NEXUS_VariablesDataEndHere;"
//	endif
//	//here we moved the data to wavenotes of the data 	
//	//print the nexus note, so user know what they loaded...
//	//print ReplaceString(";", StringVals, "\r")  
//	//print ReplaceString(";", NumVals, "\r")
//	return a2DdataWave
//end
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
//
//
//Function NI2NX_FindThe2DData(Fldrname)
//	string Fldrname
//	
//	string ListOf2DWaves=WaveList("*", ";", "TEXT:0,DIMS:2" )
//	if(strlen(ListOf2DWaves)>0)
//		Wave DataWv=$(stringFromList(0,ListOf2DWaves))
//		Wave/Z test=$(Fldrname+stringFromList(0,ListOf2DWaves))
//		if(!WaveExists(test))
//			MoveWave DataWv, $(Fldrname)
//		endif
//	endif
//end
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
//
//Function NI2NX_ConvertTxTwvToStringList(Fldrname)
//	string Fldrname
//
//	SVAR StartFolderStr=root:Packages:NexusImport:StartFolderStr
//	string Newkey=GetDataFolder(1)[strlen(StartFolderStr),inf]
//	string ListOfTXTWaves=WaveList("*", ";", "TEXT:1" )
//      SVAR/Z ListOfStrValues = $(Fldrname+"ListOfStrValues")
//	if(!SVAR_Exists(ListOfStrValues))
//		string/g $(Fldrname+"ListOfStrValues")
//		SVAR/Z ListOfStrValues = $(Fldrname+"ListOfStrValues")
//	endif
//		variable i
//		for(i=0;i<ItemsInList(ListOfTXTWaves,";");i+=1)
//			ListOfStrValues+=Newkey+StringFromList(i, ListOfTXTWaves  , ";")+"="
//			Wave/T tempWv=$(StringFromList(i, ListOfTXTWaves  , ";"))
//			ListOfStrValues+=tempWv[0]+";"
//			KillWaves/Z tempWv
//		endfor
//end
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
//
//Function NI2NX_ConvertNumWvToStringList(Fldrname)
//	string  Fldrname
//	
//	SVAR StartFolderStr=root:Packages:NexusImport:StartFolderStr
//	string Newkey=GetDataFolder(1)[strlen(StartFolderStr),inf]
//	string ListOfNumWaves=WaveList("*", ";", "TEXT:0,DIMS:1" )
//      SVAR/Z ListOfNumValues = $(Fldrname+"ListOfNumValues")
//	if(!SVAR_Exists(ListOfNumValues))
//		string/g $(Fldrname+"ListOfNumValues")
//		SVAR/Z ListOfNumValues = $(Fldrname+"ListOfNumValues")
//	endif
//		variable i
//		for(i=0;i<ItemsInList(ListOfNumWaves,";");i+=1)
//			ListOfNumValues+=Newkey+StringFromList(i, ListOfNumWaves  , ";")+"="
//			Wave tempWv=$(StringFromList(i, ListOfNumWaves  , ";"))
//			ListOfNumValues+=num2str(tempWv[0])+";"
//			KillWaves/Z tempWv
//		endfor
//end
//
//
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI2_CreateWvNoteNbk(TextToDisplay)
	String TextToDisplay

		string OldNOte=TextToDisplay
		
		variable i
		String nb 	
		nb = "Sample_Information"
		DoWindow Sample_Information
		if(V_Flag)
			DoWindow /K Sample_Information
		endif
		NewNotebook/N=$nb/F=1/V=1/K=1/W=(700,10,1100,700)
		Notebook $nb defaultTab=36, statusWidth=252
		Notebook $nb showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
		Notebook $nb newRuler=Title, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",12,3,(0,0,0)}
		Notebook $nb ruler=Title, text="Header information for loaded file\r"
		Notebook $nb ruler=Normal, text="\r"
		For(i=0;i<ItemsInList(OldNOte,";");i+=1)
				Notebook $nb text=stringFromList(i,OldNOte,";")+ " \r"
		endfor
		Notebook $nb selection={startOfFile,startOfFile}
		Notebook $nb text=""
	
//	AutopositionWindow/M=0/R=CCDImageToConvertFig Sample_Information
//	print ReplaceString(";", OldNote, "\r") 


end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

static Function/S NI2_DictconvertKeySep(dict_in, old_sep, new_sep, list_sep)
	String dict_in, old_sep, new_sep, list_sep
	Variable pair_count = ItemsInList(dict_in, list_sep)
	Variable i
	String dict_out = ""
	for (i = 0; i < pair_count; i += 1)
		String curr_pair = StringFromList(i, dict_in, list_sep)
		curr_pair = ReplaceString(old_sep, ReplaceString(";", curr_pair, "_"), new_sep, 0, 1)
		dict_out = AddListItem(curr_pair, dict_out, list_sep, Inf)
	endfor
	return dict_out
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

//    **********         Mar  header - this is header per Rayonix for marTiff file used by mar225 tiff file (mccd)
structure Mar_Tiff_Flea_Header
		      //* File/header format parameters (256 bytes) */
		      UINT32        header_type;    				//* flag for header type  (can be used as 	magic number) */
		      char header_name[16];         			//* header name (MARCCD) */
		      UINT32        header_major_version; 		//* header_major_version (n.) */
		      UINT32        header_minor_version;       	//* header_minor_version (.n) */
		      UINT32        header_byte_order;			//* BIG_ENDIAN (Motorola,MIPS); LITTLE_ENDIAN (DEC, Intel) */
		      UINT32        data_byte_order;      		//* BIG_ENDIAN (Motorola,MIPS); LITTLE_ENDIAN (DEC, Intel) */
		      UINT32        header_size;
		      UINT32        frame_type;
		      UINT32        magic_number;  				//* in bytes             */
													//* flag for frame type */
													//* to be used as a flag - usually to indicate new file */
		      UINT32        compression_type;     		//* type of image compression    */
		      UINT32        compression1;		//* compression parameter 1 *//
		      UINT32        compression2;		//* compression parameter 2 *//
		      UINT32        compression3;		//* compression parameter 3 *//
		      UINT32        compression4;		//* compression parameter 4 *//
		      UINT32        compression5;
		      UINT32        compression6;
		      UINT32        nheaders;		  //* total number of headers  *//
		      UINT32        nfast;			//* number of pixels in one line *//
		      UINT32        nslow;			//* number of lines in image     *//
		      UINT32        depth;			//* number of bytes per pixel    *//
		      UINT32        record_length;  				//* number of pixels between succesive rows */
		      UINT32        signif_bits;    				//* true depth of data, in bits  */
		      UINT32        data_type;      				//* (signed,unsigned,float...) */
			UINT32        saturated_value;		 //* value marks pixel as saturated */
			UINT32        sequence;				//* TRUE or FALSE */
			UINT32        nimages;				//* total number of images - size of each is nfast*(nslow/nimages) */
		      UINT32        origin;					////* corner of origin           *//
			UINT32        overflow_location;		                              //* direction of fast axis     *//
			UINT32        orientation;		//* FOLLOWING_HEADER, FOLLOWING_DATA *//
			UINT32        view_direction;   //* direction to view frame      *//
			UINT32        over_8_bits;		//* # of pixels with counts > 255 *//
			UINT32        over_16_bits;		//* # of pixels with count > 65535 *//
			UINT32        multiplexed;		//* # of images in fast direction *//
			UINT32        nfastimages;		//* multiplex flag *//
			UINT32        nslowimages;		//* multiplex flag *//
			UINT32        darkcurrent_applied; //* flags correction has been applied -
							//* multiplex flag *// hold magic number ? *//
		      UINT32        bias_applied;     //* flags correction has been applied -	hold magic number ? *//
		      UINT32        flatfield_applied;  //* flags correction has been applied -		hold magic number ? *//      
		      UINT32        distortion_applied; //* flags correction has been applied -		hold magic number ? *//
		      UINT32        original_header_type; //* Header//frame type from file that		frame is read from *//
		      UINT32        file_saved;         //* Flag that file has been saved, should		be zeroed if modified *//
		      UINT32        n_valid_pixels;     //* Number of pixels holding valid data -		first N pixels *//
		      UINT32        defectmap_applied; //* flags correction has been applied -		hold magic number ? *//
		      UINT32        subimage_nfast;          //* when divided into subimages (eg.		frameshifted) *//
		      UINT32        subimage_nslow;       //* when divided into subimages (eg.		frameshifted) *//
		      UINT32        subimage_origin_fast; //* when divided into subimages (eg.		frameshifted) *//
		      UINT32        subimage_origin_slow; //* when divided into subimages (eg.		frameshifted) *//
		      UINT32        readout_pattern;
				//* BITCode-1=A,2=B,4=C,8= //* at this value and above, data //* Describes how this frame needs D *//
		      UINT32        saturation_level;		//are not reliable *//
		      UINT32        orientation_code;		//		to be rotated to make it "right" *//
			UINT32        frameshift_multiplexed;  //* frameshift multiplex flag *//
		      UINT32        prescan_nfast;
		//preceeding imaging pixels - fast direction *//
		      UINT32        prescan_nslow;
		//preceeding imaging pixels - slow direction *//
		      UINT32        postscan_nfast;
		//followng imaging pixels - fast direction *//
		      UINT32        postscan_nslow;
		//followng imaging pixels - slow direction *//
		      UINT32        prepost_trimmed;
		//scan pixels have been removed *//
		//* Number of non-image pixels
		//* Number of non-image pixels
		//* Number of non-image pixels
		//* Number of non-image pixels
		//* trimmed==1 means pre and post
		//char reserve1[(64-55)*sizeof(INT32)-16];
		char reserve1[70];
		//* Data statistics (128) *//
		UINT32        total_counts[2];
		//* 64 bit integer range = 1.85E19*//
		//* mean * 1000 *//
		//*rms*1000*//
		//* number of pixels with 0 value -
		//* number of pixels with saturated
		//* Flag that stats OK - ie data not
		UINT32		 special_counts1[2];
		UINT32		 special_counts2[2];
		UINT32		 min;
		UINT32		 max;
		INT32		mean;
		UINT32		 rms;
		UINT32		 n_zeros;

		//not included in stats in unsigned data *//
		      UINT32        n_saturated;
		//value - not included in stats *//
		      UINT32        stats_uptodate;
		//changed since last calculation *//
		        UINT32        pixel_noise[19];         //* 1000*base noise value (ADUs) *//
//		      char reserve2[(32-13-MAXIMAGES)*sizeof(INT32)];
//		      char reserve2[(32-13-MAXIMAGES)*sizeof(INT32)];
//		#if 0
		      //* More statistics (256) *//
//		      UINT16 percentile[128];
//		#else
		      //* Sample Changer info *//
		      char          barcode[16];
		      UINT32        barcode_angle;
		      UINT32        barcode_status;
		      //* Pad to 256 bytes *//
//		      char reserve2a[(64-6)*sizeof(INT32)];
		      char reserve2a[232];
//		#endif
		      //* Goniostat parameters (128 bytes) *//
		INT32 xtal_to_detector;		      //* 1000*distance in millimeters *//
		INT32 beam_x;		//* 1000*x beam position (pixels) *//
		INT32 beam_y;		//* 1000*y beam position (pixels) *//
		INT32 integration_time;		      //* integration time in milliseconds *//
		INT32 exposure_time;		//* exposure time in milliseconds *//
		INT32 readout_time;		//* readout time in milliseconds *//
		INT32 nreads;		//* number of readouts to get this image *//
		INT32 start_twotheta;		//* 1000*two_theta angle *//
		INT32 start_omega;		//* 1000*omega angle *//
		INT32 start_chi;		       //* 1000*gamma angle *//
		INT32 start_kappa;
		INT32 start_phi;
		INT32 start_delta;
		INT32 start_gamma;
		INT32 start_xtal_to_detector;     //* 1000*distance in mm (dist in um)*//
		INT32 rotation_axis;		//* active rotation axis (index into above ie.		0=twotheta,1=omega...) *//
	      INT32 rotation_range;
	      INT32 detector_rotx;
	      INT32 detector_roty;
		INT32 detector_rotz;
	      INT32 total_dose;
		 //* 1000*rotation angle *//
		 //* 1000*rotation of detector around X *//
		 //* 1000*rotation of detector around Y *//
		 //* 1000*rotation of detector around Z *//
		 //* Hz-sec (counts) integrated over full
		INT32 detector_type;
		INT32 pixelsize_x;
		INT32 pixelsize_y;
		//* detector type *//
		//* pixel size (nanometers) *//
		//* pixel size (nanometers) *//
		      //* 1000*chi angle *//
		//* 1000*kappa angle *//
		      //* 1000*phi angle *//
		//* 1000*delta angle *//
		//* 1000*gamma angle *//
		INT32 end_twotheta;
		INT32 end_omega;
		INT32 end_chi;
		INT32 end_kappa;
		INT32 end_phi;
		INT32 end_delta;
		INT32 end_gamma;
		INT32 end_xtal_to_detector; //* 1000*distance in mm (dist in um)*//
		//* 1000*two_theta angle *//
		      //* 1000*omega angle *//
		//* 1000*chi angle *//
		      //* 1000*kappa angle *//
		//* 1000*phi angle *//
		      //* 1000*delta angle *//
		//exposure *//
//		      char reserve3[(32-29)*sizeof(INT32)]; //* Pad Gonisotat parameters to 128 bytes *//
		     char reserve3[12]; 				//* Pad Gonisotat parameters to 128 bytes *//
		      //* Detector parameters (128 bytes) *//
		      //* 1000*mean bias value *//
		//* photons // 100 ADUs *//
		INT32 mean_bias;
		INT32 photons_per_100adu;
		INT32 measured_bias[1];   //* 1000*mean bias value for each image*//
  	  	INT32 measured_temperature[1];  //* Temperature of each detector in milliKelvins *//
		INT32 measured_pressure[1];     //* Pressure of each chamber in		microTorr *//
		//* Retired reserve4 when MAXIMAGES set to 9 from 16 and two fields removed,		and temp and pressure added
	     // char reserve4[(32-(5+3*MAXIMAGES))*sizeof(INT32)];
	      char reserve4[96];
		      //* X-ray source and optics parameters (128 bytes) *//
		      //* X-ray source parameters (14*4 bytes) *//
		INT32 source_type;
		INT32 source_dx;
		INT32 source_dy;
		INT32 source_wavelength;
		INT32 source_power;
		INT32 source_voltage;
		INT32 source_current;
		INT32 source_bias;
		INT32 source_polarization_x;      //* () *//
		INT32 source_polarization_y;      //* () *//
		INT32 source_intensity_0;   //* (arbitrary units) *//
		INT32 source_intensity_1;   //* (arbitrary units) *//
		char reserve_source[8];
		//* X-ray optics_parameters (8*4 bytes) *//
		INT32 optics_type;
		INT32 optics_dx;
		INT32 optics_dy;
		INT32 optics_wavelength;
		INT32 optics_dispersion;
		INT32 optics_crossfire_x;
		INT32 optics_crossfire_y;
		INT32 optics_angle;
		//* Optics type (code)*//
		      //* Optics param. - (size microns) *//
		      //* Optics param. - (size microns) *//
		      //* Optics param. - (size microns) *//
		      //* Optics param. - (*10E6) *//
		//* Optics param. - (microRadians) *//
		//* Optics param. - (microRadians) *//
		//* Optics param. - (monoch. 2theta -
		//* (code) - target, synch. etc *//
		      //* Optics param. - (size microns) *//
		      //* Optics param. - (size microns) *//
		      //* wavelength (femtoMeters) *//
		//* (Watts) *//
		//* (Volts) *//
		//* (microAmps) *//
		//* (Volts) *//
		//microradians) *//
	       INT32 optics_polarization_x;      //* () *//
		 INT32 optics_polarization_y;      //* () *//
	      char reserve_optics[16];
	      char reserve5[16]; //* Pad X-ray parameters to 128 bytes *//
		//* File parameters (1024 bytes) *//
		char filetitle[128];
		char filepath[128];
		char filename[64];
		//* Title
		//* path name for data file
		//* name of data file
	        char acquire_timestamp[32]; //* date and time of acquisition
		  char header_timestamp[32];  //* date and time of header update   *//
	        char save_timestamp[32];    //* date and time file saved         *//
		  char file_comment1[400];     //* comments  - can be used as desired     *//
		  char file_comment2[112];     //* comments  - can be used as desired     *//
	      char reserve6[1024-(128+128+64+(3*32)+512)]; //* Pad File parameters to		1024 bytes *//
		      //* Dataset parameters (512 bytes) *//
	        char dataset_comment1[400];  //* comments  - can be used as desired     *//
	        char dataset_comment2[112];  //* comments  - can be used as desired     *//
		      //* Reserved for user definable data - will not be used by Mar! *//
	      char user_data1[400];
	      char user_data2[112];
		      //* char pad[----] USED UP! *//     //* pad out to 3072 bytes *//
endstructure
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
static Function NI1_mpaFindFirstDataLine(pathName, filePath)
	String pathName		// Name of symbolic path or ""
	String filePath			// Name of file or partial path relative to symbolic path.
 
	Variable refNum
 
	Open/R/P=$pathName refNum as filePath
 
	String buffer, text
	Variable line = 0
 
	do
		FReadLine refNum, buffer
		if (strlen(buffer) == 0)
			Close refNum
			return -1						// The expected keyword was not found in the file
		endif
		text = buffer[0,5]
		if (CmpStr(text, "[CDAT0") == 0)		// Line does start with "[DATA" ?
			Close refNum
			return line + 1					// Success: The next line is the first data line.
		endif
		line += 1
	while(1)
 
	return -1		// We will never get here
End
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function NI1_MPASpeFindNumDataLines(pathName, filePath)
	String pathName		// Name of symbolic path or "" to display dialog.
	String filePath			// Name of file or "" to display dialog. Can also be full or partial path relative to symbolic path.
 

	Variable refNum
 
	Open/R/P=$pathName refNum as filePath
 	variable TicksStart=ticks
	String buffer, text
	Variable line = 0
 
	do
		FReadLine refNum, buffer
		if (strlen(buffer) == 0)
			Close refNum
			return -1						// The expected keyword was not found in the file
		endif
		text = buffer[0,5]
		if (CmpStr(text, "[CDAT0") == 0)		// Line does start with "[DATA" ?
			break
		endif
		line += 1
	while(1)
	do
		FReadLine refNum, buffer
		if (strlen(buffer) == 0)
			Close refNum
			return -1						// end of file reached
		endif
		text = buffer[0,4]
		if (CmpStr(text, "$DATA") == 0)		// Line does start with "[CDAT0?" ?
			break
		endif
		line += 1
	while(1)
 	line=0
	FReadLine refNum, buffer
	if (strlen(buffer) == 0)
		Close refNum
		return -1						// end of file reached
	endif
	variable startPnt, endPnt
	string tempStr=NI1_COnvertLineIntoList(buffer)
	StartPnt= str2num(StringFromList(0, tempStr , ";"))
	endPnt= str2num(StringFromList(1, tempStr , ";"))
	return endPnt
End

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
Function/S NI1_COnvertLineIntoList(LineWhiteSpaceSeparated)
	string LineWhiteSpaceSeparated
	
	string NewList
	NewList = ReplaceString("\r", LineWhiteSpaceSeparated, "")
	NewList = NI1_ReduceSpaceRunsInString(LineWhiteSpaceSeparated,1)
	NewList = NI1_TrimLeadingWhiteSpace(NewList)
	NewList = ReplaceString(" ", NewList, ";")
	return NewList+";"
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
Function/T NI1_ZapControlCodes(str)			// remove parts of string with ASCII code < 32
	String str
	Variable i = 0
	do
		if (char2num(str[i,i])<32 || char2num(str[i,i])>127)
			//print str[i,i], num2str(char2num(str[i,i]))
			str[i,i] = " "
			//str[i,i+1] = str[i+1,i+1]
		endif
		i += 1
	while(i<strlen(str))
	return str
End
Function/S NI1_RemoveNonASCII(strIn)
	string StrIn
	string StrOut=""
	variable i
	for(i=0;i<strlen(StrIn);i+=1)
		print StrIn[i]+"  =  "+num2str(char2num(StrIn[i]))
		if(char2num(StrIn[i])<=127)
			StrOut[i]=StrIn[i]
		else
			StrOut[i]=" "		
		endif
	endfor
	return StrOut
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
Function/T NI1_ReduceSpaceRunsInString(str,minRun)
	String str
	Variable minRun

	String spaces = PadString("  ", 16, 0x20)	// spaces contains 256 spaces
	String new = spaces[0,minRun-1]				// replacement string
	Variable i = strlen(spaces)-1
	do
		str = ReplaceString(spaces[0,i], str, new) 	//ChangePartsOfString(str,spaces[0,i],new)
		i -= 1
	while(i>=minRun)
	return str
End
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
Function/T NI1_TrimLeadingWhiteSpace(str)	// remove any leading white space from str
	String str
	Variable i
	i = -1
	do
		i += 1
	while (char2num(str[i])<=32)
	return str[i,strlen(str)-1]
End

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
Function NI1_ReadCalibCanSASNexusFile(PathName, FileNameToLoad, NewWaveName)
	string PathName, FileNameToLoad, NewWaveName
	
	//this part of the code reads content by grabbing it from the file directly. 
	string FileContent=NI1_ListNexusCanSASContent(PathName, FileNameToLoad)
	variable fileID, UsedQXY, UsedAzimAngle, UnbinnedQx, UnbinnedQy, HaveMask, HaveErrors, i
	string TempStr, TempStr1, TempQWaveList
	TempQWaveList = ""
	UsedQXY = 0
	UsedAzimAngle = 0
	string QUnits = "1/Angstrom"
	print "Need finishing NI1_ReadCalibCanSASNexusFile"
	print "We need to add check on if data are produced by Nika or python, Nika images are not transpozed..."
	if (stringmatch(NewWaveName,"CCDImageToConvert"))
			//DataIdentification = "DataWv:"+TempDataPath+";"+"QWv:"+TempQPath+";"+"IdevWv:"+TempIdevPath+";"+"MaskWv:"+TempMaskPath+";"
			//  DataWv:/sasentry01/sasdata01/I;QWv:/sasentry01/sasdata01/Q;IdevWv:;MaskWv:;
			HDF5OpenFile/P=$(PathName)/R fileID as FileNameToLoad
			//load data - Intensity
			TempStr = StringByKey("DataWv", FileContent, ":", ",")
			HDF5LoadData /N=CCDImageToConvert /TRAN=1  /O  fileID , TempStr 			//  /TRAN=1 makes orientation same as in HDVView, true for all but Nika 2D data. Or export Nika transposed? 
			Wave CCDImageToConvert
 			//load data - Qvector
			TempStr = StringByKey("QWv", FileContent, ":", ",")
			if(ItemsInList(TempStr)<2)	//only Q wave
				HDF5LoadData /N=Q2Dwave /TRAN=1  /O  fileID , TempStr 
			else		//assume Qx, Qy, optionally Qz
				For(i=0;i<ItemsInList(TempStr);i+=1)
					TempStr1=stringfromList(i,TempStr)
					if(stringmatch(TempStr1,"*Qx"))
						HDF5LoadData /N=Qx2D  /O  fileID , TempStr1 
						TempQWaveList+="Qx"
					elseif(stringmatch(TempStr1,"*Qy"))
						HDF5LoadData /N=Qy2D  /O  fileID , TempStr1 
						TempQWaveList+="Qy"
					elseif(stringmatch(TempStr1,"*Qz"))
						HDF5LoadData /N=Qz2D  /O  fileID , TempStr1 
						TempQWaveList+="Qz"
					endif
				endfor
				UsedQXY=1	
			endif
			QUnits =  StringByKey("QUnits", FileContent, ":", ",")
			TempStr = StringByKey("IdevWv", FileContent, ":", ",")
			if(strlen(TempStr)>2)	//only Q wave
				HDF5LoadData /N=CCDImageToConvert_Errs  /TRAN=1 /O  fileID , TempStr 
				HaveErrors=1
			endif
			TempStr = StringByKey("MaskWv", FileContent, ":", ",")
			if(strlen(TempStr)>2)	//only Q wave
				HDF5LoadData /N=M_ROIMask  /TRAN=1 /O  fileID , TempStr 
				Wave M_ROIMask
				M_ROIMask = !M_ROIMask		//again, opposite logic for Nexus and Igor. 
				HaveMask=1
			endif
			TempStr = StringByKey("AzimAngles", FileContent, ":", ",")
			if(strlen(TempStr)>2)	//Azimuthal wave exists
				HDF5LoadData /N=AnglesWave  /TRAN=1 /O  fileID , TempStr 
				UsedAzimAngle=1
			endif
			TempStr = StringByKey("UnbinnedQx", FileContent, ":", ",")
			if(strlen(TempStr)>2)	//Original Qx vector exists
				HDF5LoadData /N=UnbinnedQxW  /TRAN=1 /O  fileID , TempStr 
				UnbinnedQx=1
			endif
			TempStr = StringByKey("UnbinnedQy", FileContent, ":", ",")
			if(strlen(TempStr)>2)	//Original Qy vector exists
				HDF5LoadData /N=UnbinnedQyW  /TRAN=1 /O  fileID , TempStr 
				UnbinnedQy=1
			endif
			HDF5CloseFile fileID  
			//TitleOfData
			SVAR UserSampleName = root:Packages:Convert2Dto1D:UserSampleName
			UserSampleName = StringByKey("TitleOfData", FileContent, ":", ",")
			
			NVAR ReverseBinnedData=root:Packages:Convert2Dto1D:ReverseBinnedData
			NVAR BeamCenterX = root:Packages:Convert2Dto1D:BeamCenterX
			NVAR BeamCenterY = root:Packages:Convert2Dto1D:BeamCenterY
			variable QxIndex, QyIndex
			//add this if exists: Qx_indices:0;Qy_indices:1;
			QxIndex =  NumberByKey("Qx_indices", FileContent, ":", ",")
			QyIndex =  NumberByKey("Qy_indices", FileContent, ":", ",")
			if(UsedQXY)
				Wave Qx2D
				Wave Qy2D
				Wave/Z Qz2D
				if(!WaveExists(Qz2D))
					Duplicate/Free Qy2D, Qz2D
					Qz2D = 0
				endif
				//now, these Qx, Qy loaded here as Qx2D and Qy2D should really be vectors per definition. They could also be 2D images with Qx, Qy, and Qz...
				if(WaveDims(Qx2D)<2)	//assume the others follow or this makes no sense...
					//I think this is related to transposing the above images to make them same orientation as in Python. 
					// wavestats Qx2D
 					// wavestats Qy2D
					reverse Qx2D /D=rQx2D
					reverse Qy2D /D=rQy2D
					//MatrixOp/O rQx2D = Qx2D
					//MatrixOp/O rQy2D = Qy2D
					Wave CCDImageToConvert				
					Duplicate/Free CCDImageToConvert, tempQx2D, tempQy2D, tempQz2D
					//if(stringMatch(TempQWaveList,"QyQx"))
					if(QxIndex==0 && QyIndex==1)
						tempQx2D[][] = rQx2D[q]
						tempQy2D[][] = rQy2D[p]
						tempQz2D[][] = 0
					elseif(QxIndex==1 && QyIndex==0)
						tempQx2D[][] = rQx2D[p]
						tempQy2D[][] = rQy2D[q]
						tempQz2D[][] = 0
					else
						Abort "Cannot assign Qx and Qy properly in NI1_ReadCalibCanSASNexusFile"
					endif
					Duplicate/O tempQx2D, Qx2D
					Duplicate/O tempQy2D, Qy2D
					Duplicate/O tempQz2D, Qz2D
				endif
				
				
				//convert Q in appropriate units...
				strswitch(QUnits)	
					case "1/Angstrom":	
						//this is OK, nothing to do... 
						break
					case "1/nm":
						MatrixOp /O Qx2D = Qx2D/10
						MatrixOp /O Qy2D = Qy2D/10
						MatrixOp /O Qz2D = Qz2D/10
						break
					case "1/m":
						MatrixOp /O Qx2D = Qx2D/(1e10)
						MatrixOp /O Qy2D = Qy2D/(1e10)
						MatrixOp /O Qz2D = Qz2D/(1e10)
						break
				endswitch
				if(!UsedAzimAngle)
					MatrixOP/O AnglesWave = atan(Qy2D/Qx2D)
					//AnglesWave += pi/2		//this does not seem to work with current test image, not sure why. 
					AnglesWave = Qx2D > 0 ? AnglesWave : AnglesWave+pi
				endif
				//create Q waves
				matrixOP/O Qx2D = powR(Qx2D,2)
				matrixOP/O Qy2D = powR(Qy2D,2)
				matrixOP/O Qz2D = powR(Qz2D,2)
				matrixOp/O Q2DWave = sqrt(Qx2D + Qy2D + Qz2D)
				Wavestats/Q Q2DWave
				BeamCenterX = V_minRowLoc
		 		BeamCenterY = V_minColLoc
		 		//need to make sure az wave has 0 to the rigth side... 
				if(AnglesWave [V_minRowLoc][DimSize(AnglesWave, 1 )-3] >0.2)		//this should be pretty much 0, this is left from beam ceneter, 0 direction in NIka's terminology
					AnglesWave -= pi/2		
					AnglesWave = Qx2D > 0 ? AnglesWave : AnglesWave+pi
		 		endif
		 		
		 		//now we need to deal with metadata. This is stupid, but lets use 1D system where data are loaded in Igor and pouched from Igor
 				string NewFileDataLocation = NEXUS_ImportAFile(PathName, FileNameToLoad)			//import file as HFD5 in Igor 
				if(strlen(NewFileDataLocation)<1)
					Abort "Import of the data failed"
				else
					NewFileDataLocation+=":"						//needs ending ":" and it is not there...
				endif
				TempStr = StringByKey("sasentryGroup", FileContent, ":", ",")				//sasdata group name /sasentry/sasdata/
				//TempStr = ReplaceString("/",(TempStr[1,strlen(TempStr)-1]),",")			//sasentry/sasdata
				TempStr = (TempStr[1,strlen(TempStr)-1])											//sasentry/sasdata
				TempStr = StringFromList(0,TempStr,"/")											//sasdata group name
				string OldDf=GetDataFolder(1)
				string IPPathToMetadata = NewFileDataLocation+TempStr+":"
				//setDataFolder IPPathToMetadata
				string StringWithInstrumentData 	= NEXUS_Read_Instrument(IPPathToMetadata)	
				string StringWithUserData 			= NEXUS_Read_User(IPPathToMetadata)	
				string StringWithSampleData 		= NEXUS_Read_Sample(IPPathToMetadata)	
				String Metadata = "DataName="+UserSampleName+";"
				Metadata += StringWithSampleData+StringWithUserData+StringWithInstrumentData
				if(strlen(Metadata)>1)
					note/NOCR CCDImageToConvert, "NEXUS_MetadataStartHere;"+Metadata+"NEXUS_MetadataEndHere"
				endif
				KillDataFolder IPPathToMetadata
			else		//used just Q, need to create AzimuthalWave
				Wave Q2Dwave
				//Wave Qvector
				//convert Q in appropriate units...
				strswitch(QUnits)	
					case "1/Angstrom":	
						//this is OK, nothing to do... 
						break
					case "1/nm":
						MatrixOp /O Q2Dwave = Q2Dwave/10
						break
					case "1/m":
						MatrixOp /O Q2Dwave = Q2Dwave/(1e10)
						break
				endswitch
				Wavestats/Q Q2DWave
				BeamCenterX = V_minRowLoc
		 		BeamCenterY = V_minColLoc
				if(!UsedAzimAngle)
					Duplicate/O Q2Dwave, AnglesWave
					Multithread AnglesWave = abs(atan2((BeamCenterY-q),(BeamCenterX-p))-pi)		
				endif	
			endif
			
			
			Redimension/S AnglesWave
			Wave CCDImageToConvert
			Wave/Z UnbinnedQxW
			Wave/Z UnbinnedQyW
			Wave/Z CCDImageToConvert_Errs
//			//now need to check, if the data are not rebinned... 
			if(UnbinnedQx && UnbinnedQy&&ReverseBinnedData)
				if(HaveMask)
					if(HaveErrors)
						NI1_RevertBinnedDataSet(CCDImageToConvert, Q2DWave, AnglesWave, BeamCenterX, BeamCenterY, UnbinnedQxW, UnbinnedQyW, Mask=M_ROIMask, Idev2D=CCDImageToConvert_Errs )		//[Mask, Idev2D] 
					else
						NI1_RevertBinnedDataSet(CCDImageToConvert, Q2DWave, AnglesWave, BeamCenterX, BeamCenterY, UnbinnedQxW, UnbinnedQyW, Mask=M_ROIMask)		//[Mask, Idev2D] 		
					endif
				else
					if(HaveErrors)
						NI1_RevertBinnedDataSet(CCDImageToConvert, Q2DWave, AnglesWave, BeamCenterX, BeamCenterY, UnbinnedQxW, UnbinnedQyW, Idev2D=CCDImageToConvert_Errs )		//[Mask, Idev2D] 
					else
						NI1_RevertBinnedDataSet(CCDImageToConvert, Q2DWave, AnglesWave, BeamCenterX, BeamCenterY, UnbinnedQxW, UnbinnedQyW)		//[Mask, Idev2D] 
					endif
				endif
			endif
			
	 		NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance		//in millimeters
			NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength							//in A
			NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX								//in millimeters
			NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY								//in millimeters
			Wavelength = 1			
			Duplicate/O Q2DWave, Theta2DWave
			Multithread Theta2DWave = asin(Q2DWave / (4*pi/Wavelength))
			variable dist00 = sqrt((BeamCenterX*PixelSizeX)^2 + (BeamCenterY*PixelSizeY)^2)
			SampleToCCDDistance = abs(dist00/(2*tan(Theta2DWave[0][0])))							
			killwaves/Z Qx2D, Qy2D
	elseif (stringmatch(NewWaveName,"OriginalCCD"))		//this is for mask... 
			HDF5OpenFile/P=$(PathName)/R fileID as FileNameToLoad
			//load data - Intensity
			TempStr = StringByKey("DataWv", FileContent, ":", ",")
			HDF5LoadData /N=OriginalCCD /TRAN=1  /O  fileID , TempStr 
			HDF5CloseFile fileID  
	else
		Abort "this should not really happen, these are calibrated data and no other image is appropriate"
	
	endif


end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI1_RevertBinnedDataSet(Int2D, Q2DWave, AnglesWave,BeamCenterX, BeamCenterY, UnbinnedQx, UnbinnedQy,[Mask, Idev2D] )
	wave Int2D, Q2DWave, AnglesWave,UnbinnedQx, UnbinnedQy, Mask, Idev2D
	variable BeamCenterX, BeamCenterY

	variable  useMask, useIdev
	useMask= !ParamIsDefault(Mask) 
	useIdev= !ParamIsDefault(Idev2D) 
	//first, create vectors of QxBinned, QyBinned
	make/O/N=(dimsize(Q2DWave,0)) QxBinned
	make/O/N=(dimsize(Q2DWave,1)) QyBinned
	QyBinned = Q2DWave[p][BeamCenterY]
	QyBinned = (AnglesWave[p][BeamCenterY]<pi) ?   QyBinned[p] : -1*QyBinned[p]
	
	QxBinned = Q2DWave[BeamCenterX][p]
	QxBinned = (AnglesWave[BeamCenterX][p]<(pi)) ?   QxBinned[p] : -1*QxBinned[p]
		//next need to create new full size Azimuthal Wave and Qwave,
	Make/o/N=(numpnts(UnbinnedQx), numpnts(UnbinnedQy)) 	UnbinnedQy2D, UnbinnedQx2D
	UnbinnedQx2D[][] = UnbinnedQx[q]
	UnbinnedQy2D[][] = UnbinnedQy[p]
	MatrixOP/O/O AnglesWaveFull = atan(UnbinnedQy2D/UnbinnedQx2D)
	AnglesWaveFull -= pi/2
	AnglesWaveFull = abs(AnglesWaveFull)
	AnglesWaveFull = UnbinnedQx2D[p][q] > 0 ? AnglesWaveFull : AnglesWaveFull+pi
	//AnglesWaveFull = (numtype(AnglesWaveFull[p][q])==2 && UnbinnedQy2D[p][q] > 0) ? AnglesWaveFull : 0
	//AnglesWaveFull = (numtype(AnglesWaveFull[p][q])==2 && UnbinnedQy2D[p][q] < 0) ? AnglesWaveFull : pi

	//create Q waves
	matrixOp/O Q2DWaveFull = sqrt(UnbinnedQx2D*UnbinnedQx2D + UnbinnedQy2D*UnbinnedQy2D)
	Duplicate/O AnglesWaveFull, Int2DFull
	Int2DFull = Int2D[BinarySearchInterp(QyBinned, UnbinnedQy[p])][BinarySearchInterp(QxBinned, UnbinnedQx[q])]
	if(useMask) 
		Duplicate/O AnglesWaveFull, MaskFull
		MaskFull = Mask[BinarySearchInterp(QyBinned, UnbinnedQy[p])][BinarySearchInterp(QxBinned, UnbinnedQx[q])]
		Duplicate/O MaskFull, Mask
	endif
	if(useIdev) 
		Duplicate/O AnglesWaveFull, Idev2DFull
		Idev2DFull = Idev2D[BinarySearchInterp(QyBinned, UnbinnedQy[p])][BinarySearchInterp(QxBinned, UnbinnedQx[q])]
		Duplicate/O Idev2DFull, Idev2D
	endif
	Duplicate/O Int2DFull, Int2D
	Duplicate/O AnglesWaveFull, AnglesWave
	Duplicate/O Q2DWaveFull, Q2DWave
	Wavestats/Q Q2DWaveFull
	NVAR BCX = root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BCY = root:Packages:Convert2Dto1D:BeamCenterY
	BCX = V_minRowLoc
	BCY = V_minColLoc
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

static Function/S NI1_ListNexusCanSASContent(PathName, FileNameToLoad)
	string PathName, FileNameToLoad
	
	variable GroupID
	Variable fileID, result
	variable i, j
	string AttribList, PathToData, ListOfDataSets, ListOfGroups, DataIdentification
	string tempStr, TempDataPath, TempQPath, TempMaskPath, TempIdevPath, tempStr2, TempAzAPath
	string OrigQxPath, OrigQyPath
	TempDataPath=" "
	TempQPath=" "
	TempAzAPath=" "
	TempMaskPath=" "
	TempIdevPath=" "
	OrigQxPath=" "
	OrigQyPath=" "
	DataIdentification=" "
	string QUnits="1/angstrom"		
	string tempStrUnits, tempStr65
	string TitleOfData=""
	
	HDF5OpenFile/P=$(PathName)/R fileID as FileNameToLoad
	if (V_flag != 0)
		Print "HDF5OpenFile failed"
		return ""
	endif
	HDF5ListGroup /F /R /TYPE=1  /Z fileID , "/"
	ListOfGroups = S_HDF5ListGroup
	string GroupName, SignalNameAtrr, QNamesAtrr, tempGroupName, sasentryGroup
	For (i=0;i<ItemsInList(ListOfGroups);i+=1)
		GroupName = stringfromlist(i,ListOfGroups)
		AttribList = NI1_HdfReadAllAttributes(fileID, GroupName,0)
		if(stringMatch(StringByKey("NX_class", AttribList),"NXentry") && stringMatch(StringByKey("canSAS_class", AttribList),"SASentry"))
			//this is sasentry here... need to get title from here as that is location where it should be... 
			sasentryGroup = GroupName
			HDF5LoadData/Z/O/Q/N=TempWvName fileID , GroupName+"/title"
			Wave/T/Z TempWvName
			if(WaveExists(TempWvName))
				TitleOfData = TempWvName[0]
			//elseif
				//TitleOfData=stringByKey("title",AttribList)
			elseif(strlen(TitleOfData)<1)	//no title in the file...
				TitleOfData = stringFromList(0,FileNameToLoad,".")
			endif
		elseif(stringMatch(StringByKey("NX_class", AttribList),"NXdata") && stringMatch(StringByKey("canSAS_class", AttribList),"SASdata"))	
			//this is sasData with some data in it... 
			PathToData = stringfromlist(i,ListOfGroups)
			HDF5ListGroup /F /TYPE=2  /Z fileID , PathToData
			ListOfDataSets = S_HDF5ListGroup
			SignalNameAtrr=stringByKey("signal",AttribList)
			QNamesAtrr=stringByKey("I_axes",AttribList)
			TempDataPath = RemoveEnding(GrepList(ListOfDataSets, "I$",0,";"), ";") 
			if(StringMatch(QNamesAtrr, "Q,Q" ))
				TempQPath = RemoveEnding(GrepList(ListOfDataSets, "Q$",0,";"), ";") 
				if(strlen(TempQPath)>1)		//Name ending with Q was found, we are done. 			
					//need to locate Q units here also... QUnits
					tempStrUnits = NI1_HdfReadAllAttributes(fileID, TempQPath,1)
					QUnits = StringByKey("units", tempStrUnits, ":", ";")
				else		//we could have Qx, Qy, Qz
					tempStr65 = RemoveEnding(GrepList(ListOfDataSets, "Qx$",0,";"), ";")
					TempQPath = tempStr65+";"
					TempQPath += RemoveEnding(GrepList(ListOfDataSets, "Qy$",0,";"), ";")+";"
					TempQPath += RemoveEnding(GrepList(ListOfDataSets, "Qz$",0,";"), ";")+";"
					//need to locate Q units here also... QUnits
					tempStrUnits = NI1_HdfReadAllAttributes(fileID, tempStr65,1)			
					QUnits = StringByKey("units", tempStrUnits, ":", ";")
				endif
			elseif(StringMatch(QNamesAtrr, "Qx,Qy" )||StringMatch(QNamesAtrr, "Qy,Qx" ))
					tempStr65 = RemoveEnding(GrepList(ListOfDataSets, "Qx$",0,";"), ";")
					TempQPath = tempStr65+";"
					TempQPath += RemoveEnding(GrepList(ListOfDataSets, "Qy$",0,";"), ";")+";"
					//need to locate Q units here also... QUnits
					tempStrUnits = NI1_HdfReadAllAttributes(fileID, tempStr65,1)			
					QUnits = StringByKey("units", tempStrUnits, ":", ";")
			endif
			TempAzAPath  =   RemoveEnding(GrepList(ListOfDataSets, "AzimAngles",0,";"), ";") 
			TempMaskPath =   RemoveEnding(GrepList(ListOfDataSets, "Mask",0,";"), ";") 
			TempIdevPath =   RemoveEnding(GrepList(ListOfDataSets, "Idev",0,";"), ";") 

			DataIdentification = "sasentryGroup:"+sasentryGroup+","
			DataIdentification += "TitleOfData:"+TitleOfData+"," 
			DataIdentification += "DataWv:"+TempDataPath+","+"QWv:"+TempQPath+","+"IdevWv:"+TempIdevPath+","
			DataIdentification += "MaskWv:"+TempMaskPath+","+"AzimAngles:"+TempAzAPath+","+"QUnits:"+QUnits+","
			//add this if exists: Qx_indices:0;Qy_indices:1;
			DataIdentification += "Qx_indices:"+StringByKey("Qx_indices", AttribList, ":", ";")+"," 
			DataIdentification += "Qy_indices:"+StringByKey("Qy_indices", AttribList, ":", ";")+"," 
			//DataIdentification += "UnbinnedQx:"+OrigQxPath+","+"UnbinnedQy:"+OrigQyPath+","
			break
									//			For(j=0;j<ItemsInList(ListOfDataSets);j+=1)
									//				tempGroupName = stringfromlist(j,ListOfDataSets)
									//				tempStr = NI1_HdfReadAllAttributes(fileID, stringfromlist(j,ListOfDataSets),1)
									//				if(stringmatch(stringByKey("signal",AttribList),"I"))			//I is intensity data
									//					TempDataPath = stringfromlist(j,ListOfDataSets)
									//					tempStr2 = stringByKey("axes", tempStr)
									//					if(stringmatch(tempStr2,"Q"))
									//						TempQPath = TempDataPath[0,strlen(TempDataPath)-2]+"Q"
									//					elseif(stringmatch(tempStr2,"Qx,Qy"))
									//						TempQPath = TempDataPath[0,strlen(TempDataPath)-2]+"Qx"+";"
									//						TempQPath += TempDataPath[0,strlen(TempDataPath)-2]+"Qy"
									//					else
									//						abort "Problem identifying Q axes"
									//					endif
									//					if(StringMatch(ListOfDataSets,"*Mask*"))
									//						TempMaskPath = TempDataPath[0,strlen(TempDataPath)-2]+"Mask"
									//					endif
									//					if(StringMatch(ListOfDataSets,"*Idev*"))
									//						TempIdevPath = TempDataPath[0,strlen(TempDataPath)-2]+"Idev"
									//					endif
									//					if(StringMatch(ListOfDataSets,"*AzimAngles*"))
									//						TempAzAPath = TempDataPath[0,strlen(TempDataPath)-2]+"AzimAngles"
									//					endif
									//					if(StringMatch(ListOfDataSets,"*UnbinnedQx*"))
									//						OrigQxPath = TempDataPath[0,strlen(TempDataPath)-2]+"UnbinnedQx"
									//					endif
									//					if(StringMatch(ListOfDataSets,"*UnbinnedQy*"))
									//						OrigQyPath = TempDataPath[0,strlen(TempDataPath)-2]+"UnbinnedQy"
									//					endif
									//					DataIdentification = "DataWv:"+TempDataPath+","+"QWv:"+TempQPath+","+"IdevWv:"+TempIdevPath+","
									//					DataIdentification += "MaskWv:"+TempMaskPath+","+"AzimAngles:"+TempAzAPath+","
									//					DataIdentification += "UnbinnedQx:"+OrigQxPath+","+"UnbinnedQy:"+OrigQyPath+","
									//				endif			
									//			endfor
		endif

	endfor
	HDF5CloseFile fileID  
	if(strlen(DataIdentification)<5)
		abort "Do not understand canSAS version/data in NI1_ListNexusCanSASContent"
	endif
	return DataIdentification
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

static Function/S NI1_HdfReadAllAttributes(fileID, Location, isDataSet)
	variable fileID
	String Location
	variable isDataSet
	
	variable DataType
	DataType = 1	//group
	if(isDataSet)
		DataType = 2
	endif
	HDF5ListAttributes /TYPE=(DataType)/Z  fileID , Location
	if(V_Flag!=0)
		Print "Reading attributes failed"
		abort 
	endif
	string ListofAttributesNames, KeyWordAttribsList
	KeyWordAttribsList = ""
	ListofAttributesNames = S_HDF5ListAttributes				//Set to a semicolon-separated list of attribute names.
	variable i
	For(i=0;i<itemsinlist(ListofAttributesNames);i+=1)
		killwaves/Z attribValue
		HDF5LoadData /A=stringfromlist(i,ListofAttributesNames)  /N=attribValue  /O /Q   /TYPE=(DataType) fileID , Location
		Wave  attribValue
		if(WaveType(attribValue ,1)==2)
			Wave/T  attribValueT=attribValue
			string TempKey=""
			if(numpnts(attribValueT)>1)
				variable j
				For(j=0;j<numpnts(attribValueT);j+=1)
					TempKey += attribValueT[j]+","
				endfor 
				TempKey=RemoveEnding(TempKey, ",")
			else
				TempKey = attribValueT[0]
			endif
			KeyWordAttribsList+=stringfromlist(i,ListofAttributesNames)+":"+TempKey+";"
		else
			KeyWordAttribsList+=stringfromlist(i,ListofAttributesNames)+":"+num2str(attribValue[0])+";"
		endif
		
	endfor
	return KeyWordAttribsList
end


//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

//			loads Cbf file and uncompresses it
//*************************************************************************************************

Function NI1A_LoadCbfCompresedImage(PathName,FileNameToLoad, WaveNameToCreate)
	string PathName,  FileNameToLoad, WaveNameToCreate
	//this function loads and uncompresses the Cbf compressed file format using:
	// conversions="x-CBF_BYTE_OFFSET";Content-Transfer-Encoding=BINARY;X-Binary-Element-Type="signed 32-bit integer";X-Binary-Element-Byte-Order=LITTLE_ENDIAN;
	//It searches for start of binary data, checks how much data there should be and creates 1D wave (stream) with the data in the current data folder. 
	variable SkipBytes
	variable filevar
	variable bufSize 
	variable sizeToExpect
	string testLine
	//locate start of the binary data
	open /R/P=$(PathName) filevar as FileNameToLoad
	testLine=""
	testLine=PadString (testLine, 16800, 0x20)
	FBinRead filevar, testLine
	close filevar
	SkipBytes=strsearch(testLine, "\014\032\004\325" , 0)+4		//this is tring I found in test images
	if(SkipBytes<5)															//string not found...
		SkipBytes=strsearch(testLine, "\012\026\004\213" , 0)+4	//this is per http://www.bernstein-plus-sons.com/software/CBF/doc/CBFlib.html#3.2.2 what should be there. Go figure... 
	endif
	if(SkipBytes<5)
		Abort "Failed to find start of binary section in the Cbf file"	//string still not found. This is problem. 
	endif
	//now how much data are we expecting???
	testLine=ReplaceString("\r\n\r\n", testLine, ";")
	testLine=ReplaceString("\r\n", testLine, ";")
	testLine=ReplaceString("#", testLine, "")
	testLine=ReplaceString(";;;;", testLine, ";")
	testLine=ReplaceString(";;;", testLine, ";")
	testLine=ReplaceString(";;", testLine, ";")
	testLine = ReplaceString(":", testLine, "=")
	sizeToExpect = NumberByKey("X-Binary-Number-of-Elements", testLine, "=", ";")
	//read the data in binary free wave so we can use them here
	Open /Z/R/P=$(PathName)/T="????" filevar as FileNameToLoad
	if (V_flag)
		close filevar
		Abort "Cannot open file, something is wrong here"				// could not open file
	endif
	FSetPos fileVar, SkipBytes											//start of the image
	FStatus fileVar
	bufSize = V_logEOF-V_filePos										//this is how much data we have in the image starting at the binary data start
	make/B/O/N=(bufSize)/Free BufWv										//signed 1 byte wave for the data
	make/O/N=(sizeToExpect)/Free ResultImage							//here go the converted signed integers. Note, they can be 8, 16, or 32 bits. 64bits not supported here. 
	FBinRead/B=1/F=1 fileVar, BufWv										//read 1 Byte each into singed integers wave
	close filevar
	//and decompress the data here 	
	variable i, j, PixelValue, ReadValue
	j=0																		// j is index of the signed 1 byte wave (stream of data in) 
	PixelValue = 0														//value in current pixel in image. 
		//http://www.bernstein-plus-sons.com/software/CBF/doc/CBFlib.html#3.2.2
		//	The "byte_offset" decompression algorithm is the following:
		//
		//Start with a base pixel value of 0.
		//Read the next byte as delta
		//If -127 ≤ delta ≤ 127, add delta to the base pixel value, make that the new base pixel value, place it on the output array and return to step 2.
		//If delta is 80 hex, read the next two bytes as a little_endian 16-bit number and make that delta.
		//If -32767 ≤ delta ≤ 32767, add delta to the base pixel value, make that the new base pixel value, place it on the output array and return to step 2.
		//If delta is 8000 hex, read the next 4 bytes as a little_endian 32-bit number and make that delta
		//If -2147483647 ≤ delta ≤ 2147483647, add delta to the base pixel value, make that the new base pixel value, place it on the output array and return to step 2.
		//If delta is 80000000 hex, read the next 8 bytes as a little_endian 64-bit number and make that delta, add delta to the base pixel value, make that the new base pixel value, place it on the output array and return to step 2.

	For(i=0;i<(sizeToExpect);i+=1)									//i is index for output wave
		//if(j>bufSize-1)
		//	break															//just in case, we run our of j. Should never happen
		//endif
		ReadValue = BufWv[j]											//read 1 Byte integer
		if(abs(ReadValue)<128)										//this is useable value within +/- 127
			PixelValue += ReadValue									//add to prior pixel value
			ResultImage[i] = PixelValue								//store in output stream
			j+=1															// move to another j point 
		elseif(ReadValue==-128)										// This is indicator that the difference did not fit in 1Byte, read 2 bytes and use those.
			j+=1															// move to another point to start reading the 2 bytes
			ReadValue = NI1A_Conv2Bytes(BufWv[j],BufWv[j+1])	//read and convert 2 Bytes in integer
			if(abs(ReadValue)<32768)									//this is useable value, use these two bytes
				PixelValue += ReadValue								//add to prior pixel value
				ResultImage[i] = PixelValue							//store in output stream
				j+=2														//move to another j point  
			elseif(ReadValue==-32768)								// This is indicator that the difference did not fit in 2Bytes, read 4 bytes and use those.
				j+=2														//move to another point to start reading the 4 bytes 
				ReadValue = NI1A_Conv4Bytes(BufWv[j],BufWv[j+1], BufWv[j+2], BufWv[j+3])		//read and convert next 4 Bytes in integer
				if(abs(ReadValue)<2147483648)						//this is correct value for 32 bits
					PixelValue += ReadValue							//add to prior pixel value
					ResultImage[i] = PixelValue						//store in output stream
					j+=4													//move to another j point 
				else														//abort, do not support 64 byte integers (no such detector exists... 
					abort "64 bits data are not supported"
				endif
			else
				print "error"
			endif
		else
			print "error"
		endif
	endfor
	Duplicate/O ResultImage, $(WaveNameToCreate)					//create wave user requested. Note, this is 1D wave and needs to be redimensioned to 2D wave (image). Could be done here... 
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

static Function NI1A_Conv2Bytes(B1,B2)		
	variable B1, B2
	//takes two signed integer bytes, and converts them to 16 bit signed integer, little-endian, two's complement signed interpretation
	//assume B1 is first byte for little-endian should be unsigned integer as it is the smaller part of the data
	//assume B2 contains the larger valeus and sign
	variable unsB1=(B1>=0) ? B1 : (256 + B1)	//this should convert two's complement signed interpretation to Usigned interpretation
	// see : http://en.wikipedia.org/wiki/Signed_number_representations
	//good description is also : http://www.mathcs.emory.edu/~cheung/Courses/561/Syllabus/1-Intro/2-data-repr/signed.html
	return unsB1 + 256*B2
end
static Function NI1A_Conv4Bytes(B1,B2, B3, B4)		
	variable B1, B2, B3, B4
	//takes four signed integer bytes, and converts them to 32 bit signed integer, little-endian, two's complement signed interpretation
	//assume B1, B2, B3 are first bytes for little-endian should be unsigned integer as it is the smaller part of the data
	//assume B4 contains the larger valeus and sign
	variable unsB1=(B1>=0) ? B1 : (256 + B1)	//this should convert two's complement signed interpretation to Usigned interpretation
	variable unsB2=(B2>=0) ? B2 : (256 + B2)	//this should convert two's complement signed interpretation to Usigned interpretation
	variable unsB3=(B3>=0) ? B3 : (256 + B3)	//this should convert two's complement signed interpretation to Usigned interpretation
	// see : http://en.wikipedia.org/wiki/Signed_number_representations
	//good description is also : http://www.mathcs.emory.edu/~cheung/Courses/561/Syllabus/1-Intro/2-data-repr/signed.html
	return unsB1 + 256*unsB2 + 256*256*unsB3 + 256*256*256*B4
end
